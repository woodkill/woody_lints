// woody_lints 검증 명령 — example/ 을 `dart analyze` 로 분석한 결과를 커밋된 정답지와 비교한다.
//
// 실행: fvm dart run tool/verify.dart [--update]
//   --update  정답지(example/expected_diagnostics.txt)를 실제 결과로 다시 쓴다.
//             바뀐 줄을 먼저 화면에 보여 준다. CI 에서는 동작하지 않는다.
//
// lib/ 는 읽기만 한다. .dart_tool/woody_verify/ 를 만들고 지우지 않는다 —
// Analysis Server 가 plugin 을 받아 컴파일해 두는 전용 상태 폴더라, 지우면 다음 실행이
// 처음부터 다시 준비한다 (약 15초). 지우는 것은 plugin 준비 실패 뒤의 복구 수단이다.
//
// 종료 코드: 0 모두 통과 / 1 단계 실패 / 64 사용법 오류 / 69 pub get 실패 / 70 예외로 끝남
import 'dart:convert';
import 'dart:io';

/// plugin 준비가 실패했을 때 stderr 에 찍히는 머리말 (spike 002).
///
/// 첫 줄이 아닐 수 있으므로 `contains` 로 찾는다 (spike 008).
const pluginFailureHeader =
    'An error occurred while executing an analyzer plugin:';

/// 정답지와 견줄 연습용 프로젝트 폴더들 (저장소 루트 기준).
///
/// 지금은 `example` 하나다. fixture 마다 상태 폴더를 따로 주고 순서대로 분석한다.
const fixtures = ['example'];

/// 정답지 파일 이름 (fixture 폴더 바로 아래에 둔다).
const expectedFileName = 'expected_diagnostics.txt';

/// 정답지를 다시 만드는 명령 (안내 문구에 쓴다).
const updateCommand = 'fvm dart run tool/verify.dart --update';

/// 처음 만드는 정답지에 넣는 형식 설명 줄.
const formatHeaderLine = '# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: $updateCommand';

/// `# 실측:` 머리 주석의 접두사. `--update` 가 이 줄만 새로 쓴다.
const measuredPrefix = '# 실측:';

/// 단계 줄에서 결과 단어(통과 / 실패)가 오는 열.
const resultColumn = 40;

/// 정답지 파일 (`#` 머리 주석 + `exit N` 한 줄 + 진단 줄들).
class Expected {
  /// 파일을 읽어 머리 주석, 종료 코드, 진단 줄로 나눈다.
  ///
  /// `#` 줄은 [headerLines] 에 보관하고 빈 줄은 버린다. 첫 비주석 줄이
  /// `exit N` 이 아니면 [FormatException] 을 던진다.
  factory Expected.read(File file) {
    final headerLines = <String>[];
    final body = <String>[];
    for (final raw in file.readAsLinesSync()) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#')) {
        headerLines.add(line);
      } else {
        body.add(line);
      }
    }
    final code = body.isNotEmpty && body.first.startsWith('exit ')
        ? int.tryParse(body.first.substring('exit '.length))
        : null;
    if (code == null) {
      throw FormatException('첫 줄이 `exit N` 이 아니다: ${file.path}');
    }
    return Expected._(headerLines, code, body.skip(1).toList()..sort());
  }

  Expected._(this.headerLines, this.exitCode, this.lines);

  /// `#` 로 시작하는 줄 (순서 보존).
  final List<String> headerLines;

  /// 기대한 `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 기대한 진단 줄 (정렬됨).
  final List<String> lines;
}

/// `dart analyze` 한 번의 결과.
class AnalyzeOutcome {
  /// [lines] 는 정답지 형식으로 정규화한 진단 줄이다. stdout 에 JSON 이 없으면 null.
  AnalyzeOutcome({
    required this.exitCode,
    required this.lines,
    required this.stderrText,
  });

  /// `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 정규화한 진단 줄 (정렬됨). null 이면 stdout 에 JSON 이 없었다 (도구가 죽음).
  final List<String>? lines;

  /// stderr 원문.
  final String stderrText;

  /// plugin 준비 실패의 머리말이 stderr 에 들어 있는지.
  bool get hasPluginHeader => stderrText.contains(pluginFailureHeader);
}

/// 검사 단계 하나의 결과. `main` 이 모아 요약하고 종료 코드를 정한다.
class StepResult {
  /// [detailLines] 는 실패했을 때 화면에 그대로 찍을 줄이다.
  StepResult({
    required this.label,
    required this.passed,
    this.detailLines = const [],
  });

  /// 단계 이름 (예: `example/ 정답지 비교`).
  final String label;

  /// 통과했는지.
  final bool passed;

  /// 실패 시 화면에 그대로 찍을 줄 (빠진 경고, 남는 경고, 안내).
  final List<String> detailLines;
}

/// 정답지와 실제 결과의 차이.
class Difference {
  /// [exitNote] 는 종료 코드가 어긋났을 때만 채운다.
  Difference({
    required this.missing,
    required this.unexpected,
    required this.exitNote,
  });

  /// 정답지에는 있는데 나오지 않은 줄.
  final List<String> missing;

  /// 정답지에 없는데 나온 줄.
  final List<String> unexpected;

  /// 종료 코드가 어긋났을 때의 한 줄. 같으면 null.
  final String? exitNote;

  /// 어긋난 것이 하나도 없는지.
  bool get isEmpty => missing.isEmpty && unexpected.isEmpty && exitNote == null;
}

/// stdout 의 JSON 을 정답지 형식 줄 목록으로 바꾼다.
///
/// JSON 을 읽지 못하면 null 을 돌려준다 (진단 0건인 `[]` 과 구별한다).
/// [bases] 중 하나로 시작하는 경로는 그 뒤만 남긴다 — 심볼릭 링크를 거쳐
/// 들어간 폴더는 준 경로와 링크를 푼 경로가 다 올 수 있어 목록으로 받는다.
List<String>? normalizeDiagnostics(String stdoutText, List<String> bases) {
  final jsonLine = stdoutText
      .split('\n')
      .lastWhere((l) => l.trimLeft().startsWith('{'), orElse: () => '');
  if (jsonLine.isEmpty) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(jsonLine);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic> || decoded['diagnostics'] is! List) {
    return null;
  }
  final lines = <String>[];
  try {
    for (final d in decoded['diagnostics'] as List) {
      final diagnostic = d as Map<String, dynamic>;
      final location = diagnostic['location'] as Map<String, dynamic>;
      var file = location['file'] as String;
      for (final base in bases) {
        if (file.startsWith('$base/')) {
          file = file.substring(base.length + 1);
          break;
        }
      }
      final line = ((location['range'] as Map)['start'] as Map)['line'];
      final severity = (diagnostic['severity'] as String).toLowerCase();
      lines.add('$file:$line  $severity  ${diagnostic['code']}');
    }
  } on TypeError {
    // JSON 이기는 하지만 진단의 모양이 아니다 — 읽지 못한 것으로 친다.
    return null;
  }
  return lines..sort();
}

/// stdout 과 stderr 를 비운 뒤 [code] 로 끝낸다 (준비 단계에서만 쓴다).
Future<Never> quit(int code) async {
  await stdout.flush();
  await stderr.flush();
  exit(code);
}

/// [dir] 에서 `dart pub get` 을 돌린다.
///
/// [enforceLockfile] 이면 `--enforce-lockfile` 을 붙여 커밋된 `pubspec.lock`
/// 그대로 받는다. 실패하면 안내를 적고 exit 69 로 끝낸다 (검증을 시작하지 않는다).
Future<void> runPubGet(String dir, {required bool enforceLockfile}) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    'pub',
    'get',
    if (enforceLockfile) '--enforce-lockfile',
  ], workingDirectory: dir);
  if (result.exitCode == 0) return;
  if (enforceLockfile && result.exitCode == 65) {
    // 65 = pubspec.yaml 과 pubspec.lock 이 어긋났다 (spike 004).
    final name = dir.split('/').last;
    stderr.writeln(
      '`$name/pubspec.yaml` 을 바꿨으면 '
      '`cd $name && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요.',
    );
  }
  stderr.writeln('pub get 실패 ($dir): exit ${result.exitCode}');
  stderr.writeln('${result.stderr}'.trimRight());
  await quit(69);
}

/// [fixtureDir] 에서 `dart --suppress-analytics analyze --format=json` 을 돌린다.
///
/// 경로 인자를 주지 않는다 — 하위 폴더를 인자로 주면 plugin 진단을 잃는다 (spike 001).
/// [stateDir] 는 이 fixture 만 쓰는 Analysis Server 상태 폴더이고 미리 만들어 둔다.
Future<AnalyzeOutcome> analyzeFixture({
  required String fixtureDir,
  required String stateDir,
}) async {
  final cwd = Directory(fixtureDir).absolute.path;
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['--suppress-analytics', 'analyze', '--format=json'],
    workingDirectory: cwd,
    environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir},
  );
  return AnalyzeOutcome(
    exitCode: result.exitCode,
    lines: normalizeDiagnostics(result.stdout as String, [
      cwd,
      Directory(cwd).resolveSymbolicLinksSync(),
    ]),
    stderrText: (result.stderr as String).trim(),
  );
}

/// 정답지([expected])와 실제 결과를 견준다. 정답지가 없으면(null) 전부 "남는 줄" 이다.
Difference findDifference(
  Expected? expected,
  List<String> actual,
  int actualExit,
) {
  final expectedLines = expected?.lines ?? const <String>[];
  final String? exitNote;
  if (expected == null) {
    exitNote = 'exit 기대 없음 (정답지 없음), 실제 $actualExit';
  } else if (expected.exitCode != actualExit) {
    exitNote = 'exit 기대 ${expected.exitCode}, 실제 $actualExit';
  } else {
    exitNote = null;
  }
  return Difference(
    missing: expectedLines.where((l) => !actual.contains(l)).toList(),
    unexpected: actual.where((l) => !expectedLines.contains(l)).toList(),
    exitNote: exitNote,
  );
}

/// 오늘 날짜를 `YYYY-MM-DD` 로 만든다.
String formatDate(DateTime date) {
  String pad(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${pad(date.month)}-${pad(date.day)}';
}

/// 정답지 [file] 을 실제 결과로 다시 쓴다.
///
/// `# 실측:` 줄만 새로 쓰고 나머지 `#` 줄은 그대로 둔다. 정답지가 없었으면
/// ([previous] 가 null) 형식 설명 줄도 함께 넣는다.
void writeExpected(
  File file,
  Expected? previous,
  List<String> actual,
  int actualExit,
) {
  final dartVersion = Platform.version.split(' ').first;
  final measured =
      '$measuredPrefix Dart $dartVersion, ${formatDate(DateTime.now())}';
  final header = <String>[];
  if (previous == null) {
    header
      ..add(measured)
      ..add(formatHeaderLine);
  } else {
    var replaced = false;
    for (final line in previous.headerLines) {
      if (!line.startsWith(measuredPrefix)) {
        header.add(line);
      } else if (!replaced) {
        header.add(measured);
        replaced = true;
      }
    }
    if (!replaced) header.insert(0, measured);
  }
  final sorted = [...actual]..sort();
  file.writeAsStringSync(
    [...header, 'exit $actualExit', ...sorted].map((l) => '$l\n').join(),
  );
}

/// fixture 하나를 분석해 정답지와 견준다. [update] 이면 바뀐 줄을 보여 준 뒤 정답지를 다시 쓴다.
///
/// 판정 순서는 바꾸지 않는다: plugin 준비 실패 → 도구가 죽음 → 정답지 비교.
/// 앞의 두 실패에서는 [update] 여도 정답지를 건드리지 않는다.
Future<StepResult> compareFixture({
  required String repoRoot,
  required String fixture,
  required bool update,
}) async {
  final label = '$fixture/ 정답지 비교';
  final fixtureDir = '$repoRoot/$fixture';
  final stateDir = '$repoRoot/.dart_tool/woody_verify/$fixture';
  Directory(stateDir).createSync(recursive: true);

  final outcome = await analyzeFixture(
    fixtureDir: fixtureDir,
    stateDir: stateDir,
  );

  // 1) plugin 준비 실패 — 종료 코드로는 알 수 없고 stderr 의 머리말로만 드러난다.
  if (outcome.hasPluginHeader) {
    return StepResult(
      label: label,
      passed: false,
      detailLines: [
        'plugin 준비 실패 — riverpod_lint 진단 없이 끝났다. '
            '(dart analyze exit ${outcome.exitCode})',
        ...outcome.stderrText.split('\n').map((l) => '  $l'),
        '',
        '네트워크를 확인하세요.',
        '전용 상태 폴더 `$stateDir` 를 지우고 다시 실행하세요 (약 15초).',
      ],
    );
  }

  // 2) 도구가 죽음 — 정답지와 "다르다" 가 아니라 결과 자체가 없다.
  final actual = outcome.lines;
  if (actual == null || !const [0, 2, 3].contains(outcome.exitCode)) {
    final stderrHead = outcome.stderrText.split('\n').take(2).join(' / ');
    return StepResult(
      label: label,
      passed: false,
      detailLines: [
        '도구가 죽었다 — dart analyze 가 exit ${outcome.exitCode} 로 끝났다'
            '${actual == null ? ' (stdout 에 JSON 없음)' : ''}.',
        '  stderr: ${stderrHead.isEmpty ? '(비어 있음)' : stderrHead}',
      ],
    );
  }

  // 3) 정답지 비교.
  final expectedFile = File('$fixtureDir/$expectedFileName');
  final expected = expectedFile.existsSync()
      ? Expected.read(expectedFile)
      : null;
  final difference = findDifference(expected, actual, outcome.exitCode);

  if (update) {
    // 조용히 덮어쓰지 않는다 — 무엇이 바뀌는지 먼저 보여 준다.
    stdout.writeln('정답지 갱신: $fixture/$expectedFileName');
    if (difference.isEmpty) {
      stdout.writeln('정답지와 같다 — 바뀐 줄 없음');
    } else {
      for (final line in difference.missing) {
        stdout.writeln('- $line');
      }
      for (final line in difference.unexpected) {
        stdout.writeln('+ $line');
      }
      final exitNote = difference.exitNote;
      if (exitNote != null) stdout.writeln(exitNote);
    }
    stdout.writeln('');
    writeExpected(expectedFile, expected, actual, outcome.exitCode);
    return StepResult(label: label, passed: true);
  }

  if (expected == null) {
    return StepResult(
      label: label,
      passed: false,
      detailLines: ['정답지가 없다. 처음이면 `$updateCommand` 로 만든다.'],
    );
  }
  if (difference.isEmpty) return StepResult(label: label, passed: true);

  final exitNote = difference.exitNote;
  return StepResult(
    label: label,
    passed: false,
    detailLines: [
      '정답지에는 있는데 나오지 않은 경고 (${difference.missing.length})',
      ...difference.missing.map((l) => '  $l'),
      '',
      '정답지에 없는데 나온 경고 (${difference.unexpected.length})',
      ...difference.unexpected.map((l) => '  $l'),
      '',
      if (exitNote != null) ...[exitNote, ''],
      '일부러 바꾼 것이면 정답지를 갱신하세요:',
      '  $updateCommand',
    ],
  );
}

/// 터미널에서 [text] 가 차지하는 칸 수를 센다 (한글 등 전각 문자는 2칸).
int measureWidth(String text) {
  var width = 0;
  for (final rune in text.runes) {
    final wide =
        (rune >= 0x1100 && rune <= 0x115F) ||
        (rune >= 0x2E80 && rune <= 0xA4CF) ||
        (rune >= 0xAC00 && rune <= 0xD7A3) ||
        (rune >= 0xF900 && rune <= 0xFAFF) ||
        (rune >= 0xFF00 && rune <= 0xFF60);
    width += wide ? 2 : 1;
  }
  return width;
}

/// 단계 줄 `[n/N] <label> ..... 통과|실패` 를 만든다. 결과 단어가 같은 열에 오도록 점으로 채운다.
String formatStepLine(int index, int total, StepResult result) {
  final head = '[$index/$total] ${result.label} ';
  final room = resultColumn - measureWidth(head);
  final dots = '.' * (room < 3 ? 3 : room);
  return '$head$dots ${result.passed ? '통과' : '실패'}';
}

/// 인자를 읽고, 준비(pub get)를 한 뒤, 단계를 모두 돌리고 요약한다.
Future<void> main(List<String> args) async {
  final unknown = args.where((a) => a != '--update').toList();
  if (unknown.isNotEmpty) {
    stderr.writeln('모르는 인자: ${unknown.join(' ')}');
    stderr.writeln('사용법: fvm dart run tool/verify.dart [--update]');
    await quit(64);
  }
  final update = args.contains('--update');
  final env = Platform.environment;
  if (update && (env['CI'] == 'true' || env['GITHUB_ACTIONS'] == 'true')) {
    stderr.writeln('CI 에서는 --update 를 쓰지 않는다 — 로컬에서 갱신해 커밋하세요.');
    await quit(64);
  }

  // tool/ 의 부모가 저장소 루트다. 어느 폴더에서 실행해도 같은 파일을 본다.
  final repoRoot = File.fromUri(Platform.script).parent.parent.path;

  try {
    // 준비 — 커밋된 lock 그대로 받는다. 실패하면 검증을 시작하지 않는다.
    for (final fixture in fixtures) {
      await runPubGet('$repoRoot/$fixture', enforceLockfile: true);
    }

    // 단계는 하나가 실패해도 나머지를 모두 돌린다. fixture 는 순서대로 분석한다
    // (빈 상태 폴더에 처음 실행 둘을 동시에 띄우면 드물게 깨진다 — spike 008).
    final steps = <Future<StepResult> Function()>[
      for (final fixture in fixtures)
        () => compareFixture(
          repoRoot: repoRoot,
          fixture: fixture,
          update: update,
        ),
    ];
    final results = <StepResult>[];
    for (var i = 0; i < steps.length; i++) {
      final result = await steps[i]();
      results.add(result);
      stdout.writeln(formatStepLine(i + 1, steps.length, result));
    }

    final failed = results.where((r) => !r.passed).toList();
    for (final result in failed) {
      stdout.writeln('');
      result.detailLines.forEach(stdout.writeln);
    }
    stdout.writeln('');
    if (failed.isEmpty) {
      stdout.writeln('점검 통과 (${results.length}개 중 ${results.length}개)');
    } else {
      stdout.writeln('점검 실패 (${results.length}개 중 ${failed.length}개)');
      exitCode = 1;
    }
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    exitCode = 70;
  } on FileSystemException catch (e) {
    stderr.writeln('파일 작업 실패: ${e.message} (${e.path ?? ''})');
    exitCode = 70;
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: $e');
    exitCode = 70;
  }
}
