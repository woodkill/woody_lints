// woody_lints 검증 명령 — 배포 설정이 기대한 대로 적용되는지를 단계 4개로 확인한다.
//
//   [1/4] lib/ 에 .dart 파일이 없는지
//   [2/4] 배포 파일(lib/analysis_options.yaml)에 deprecated / removed / 없는 규칙이 없는지
//   [3/4] example/analysis_options.yaml 이 include 한 줄인지
//   [4/4] example/ 을 `dart analyze` 로 분석한 결과가 커밋된 정답지와 같은지
//
// 실행: fvm dart run tool/verify.dart [--update]
//   --update  정답지(example/expected_diagnostics.txt)를 실제 결과로 다시 쓴다.
//             바뀐 줄을 먼저 화면에 보여 준다. CI 에서는 동작하지 않는다.
//
// 단계에 앞서 준비를 한다: 실행 중인 SDK 가 .fvmrc 와 같은지 확인하고, 저장소 루트와
// example/ 의 패키지를 받는다. 준비가 실패하면 검증을 시작하지 않는다.
//
// lib/ 는 읽기만 한다. 규칙 검사 동안 build/woody_rule_check/ 를 만들었다가 지운다.
// .dart_tool/woody_verify/ 를 만들고 지우지 않는다 — Analysis Server 가 plugin 을 받아
// 컴파일해 두는 전용 상태 폴더라, 지우면 다음 실행이 처음부터 다시 준비한다 (약 15초).
// 지우는 것은 plugin 준비 실패 뒤의 복구 수단이다.
//
// 종료 코드: 0 모두 통과 / 1 단계 실패 / 64 사용법 오류 / 69 pub get 실패 / 70 예외로 끝남
//            / 78 실행 중인 SDK 가 .fvmrc 와 다름
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

/// 규칙이 적힌 배포 파일 (저장소 루트 기준). 읽기만 한다.
const shippedOptionsPath = 'lib/analysis_options.yaml';

/// 규칙 검사용 복사본을 두는 폴더 (저장소 루트 기준).
///
/// 저장소 안이어야 루트 `pubspec.yaml` 의 SDK 하한이 적용되어 deprecated / removed
/// 규칙이 보고된다. 점으로 시작하는 폴더는 분석되지 않는다 (spike 005).
const ruleCheckDir = 'build/woody_rule_check';

/// 배포 파일에 있으면 안 되는 규칙 상태의 진단 코드 (deprecated / removed / 없는 규칙).
const ruleProblemCodes = ['deprecated_lint', 'removed_lint', 'undefined_lint'];

/// 복사본의 `include:` 가 풀리지 않았을 때의 진단 코드 — 루트 `pub get` 이 안 된 상태다.
const includeNotFoundCode = 'include_file_not_found';

/// fixture 의 옵션 파일에 있어야 하는 단 한 줄 (사용 프로젝트와 같은 모양).
const fixtureIncludeLine = 'include: package:woody_lints/analysis_options.yaml';

/// 이 스크립트를 올바른 SDK 로 실행하는 명령 (안내 문구에 쓴다).
const runCommand = 'fvm dart run tool/verify.dart';

/// `dart analyze` 가 진단의 강도에 따라 내는 종료 코드 (0 info 이하 / 2 warning / 3 error).
///
/// 이 밖의 값은 "도구가 죽었다" 로 본다 (spike 001, 002).
const analyzeExitCodes = [0, 2, 3];

/// 정답지 파일 이름 (fixture 폴더 바로 아래에 둔다).
const expectedFileName = 'expected_diagnostics.txt';

/// 정답지를 다시 만드는 명령 (안내 문구에 쓴다).
const updateCommand = '$runCommand --update';

/// 처음 만드는 정답지에 넣는 형식 설명 줄.
const formatHeaderLine = '# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: $updateCommand';

/// `# 실측:` 머리 주석의 접두사. `--update` 가 이 줄만 새로 쓴다.
const measuredPrefix = '# 실측:';

/// 단계 줄에서 결과 단어(통과 / 실패)가 오는 열.
const resultColumn = 40;

/// 버전 줄에서 값이 시작하는 열 (라벨 `기반 세트` 의 폭 9칸 + 공백 2칸).
const versionColumn = 11;

/// 배포 파일이 최상위 `plugins:` 에 선언한 analyzer plugin 의 패키지 이름.
const pluginPackage = 'riverpod_lint';

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

/// 전용 상태 폴더에서 읽은 plugin(`riverpod_lint`) 버전.
///
/// 읽었으면 [version] 이, 못 읽었으면 그 이유 [reason] 이 있다.
class PluginVersion {
  /// 읽은 버전.
  PluginVersion.resolved(String this.version) : reason = null;

  /// 읽지 못했다. [reason] 은 화면에 그대로 찍는 한 줄이다.
  PluginVersion.unknown(String this.reason) : version = null;

  /// 풀린 버전 (예: `3.1.9`). 못 읽었으면 null.
  final String? version;

  /// 못 읽은 이유. 읽었으면 null.
  final String? reason;

  /// 화면과 정답지 머리 주석에 쓰는 값. 못 읽었으면 `?` 다.
  String get text => version ?? '?';
}

/// 검사 단계 하나의 결과. `main` 이 모아 화면에 찍고 종료 코드를 정한다.
class StepResult {
  /// [detailLines] 는 단계 줄들 아래에 그대로 찍을 줄이다.
  StepResult({
    required this.label,
    required this.passed,
    this.detailLines = const [],
    this.plugin,
    this.pluginFailed = false,
    this.applyUpdate,
  });

  /// 단계 이름 (예: `example/ 정답지 비교`).
  final String label;

  /// 통과했는지.
  final bool passed;

  /// 화면에 그대로 찍을 줄 — 실패의 내용과 다음에 할 일, `--update` 가 바꾸는 줄.
  final List<String> detailLines;

  /// 이 단계의 분석 뒤에 읽은 plugin 버전. 정답지 비교 단계만 채운다.
  final PluginVersion? plugin;

  /// 이 단계의 분석에서 plugin 준비 실패의 머리말을 봤는지.
  final bool pluginFailed;

  /// `--update` 의 정답지 쓰기. `main` 이 [detailLines] 를 화면에 내보낸 뒤에 부른다.
  final void Function()? applyUpdate;
}

/// 정답지와 실제 결과의 차이.
class Difference {
  /// [exitNote] 는 종료 코드가 어긋났을 때만 채운다.
  Difference({
    required this.missing,
    required this.unexpected,
    required this.exitNote,
  });

  /// 정답지에는 있는데 나오지 않은 줄. 같은 줄이 여러 건이면 건수 차이만큼 들어 있다.
  final List<String> missing;

  /// 정답지에 없는데 나온 줄. 같은 줄이 여러 건이면 건수 차이만큼 들어 있다.
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

/// 실행 중인 SDK 의 버전 (Flutter / Dart).
class SdkInfo {
  /// [flutter] 는 `frameworkVersion`, [dart] 는 `dartSdkVersion` 이다.
  SdkInfo({required this.flutter, required this.dart});

  /// Flutter 버전 (예: `3.47.5`).
  final String flutter;

  /// Dart 버전 (예: `3.13.4`).
  final String dart;
}

/// 실행 중인 dart 가 속한 Flutter SDK 의 `bin/cache/flutter.version.json` 을 읽는다.
///
/// 1순위는 실행 파일에서 다섯 단계 위다 (`<root>/bin/cache/dart-sdk/bin/dart` → `<root>`).
/// 2순위는 환경변수 `FLUTTER_ROOT` 다 — 설치본의 배치가 다른 경우(GitHub runner)의
/// 대비이고, 그 SDK 의 `dartSdkVersion` 이 실행 중인 Dart 와 같을 때만 받아들인다
/// (다른 SDK 를 가리키는 환경변수로 확인을 통과하지 않게). 못 찾으면 null 을 돌려준다.
Map<String, dynamic>? readFlutterVersion() {
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 4; i++) {
    dir = dir.parent;
  }
  final nearby = readVersionFile(dir.path);
  if (nearby != null) return nearby;

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null || flutterRoot.isEmpty) return null;
  final fallback = readVersionFile(flutterRoot);
  final runningDart = Platform.version.split(' ').first;
  return fallback?['dartSdkVersion'] == runningDart ? fallback : null;
}

/// [flutterRoot] 아래의 `bin/cache/flutter.version.json` 을 읽는다. 없으면 null.
Map<String, dynamic>? readVersionFile(String flutterRoot) {
  final file = File('$flutterRoot/bin/cache/flutter.version.json');
  if (!file.existsSync()) return null;
  final decoded = jsonDecode(file.readAsStringSync());
  return decoded is Map<String, dynamic> ? decoded : null;
}

/// 실행 중인 SDK 가 `.fvmrc` 와 같은지 확인하고 그 버전을 돌려준다 (D-12).
///
/// Flutter SDK 의 dart 가 아니거나 버전이 다르면 올바른 명령을 안내하고 exit 78 로
/// 끝낸다 (검증을 시작하지 않는다). `.fvmrc` 의 모양이 틀리면 [FormatException] 이다.
Future<SdkInfo> ensurePinnedSdk(String repoRoot) async {
  final version = readFlutterVersion();
  final running = version?['frameworkVersion'];
  if (version == null || running is! String) {
    stderr.writeln('Flutter SDK 의 dart 가 아니다.');
    stderr.writeln('저장소 루트에서 `$runCommand` 로 실행하세요.');
    await quit(78);
  }
  final pinned = jsonDecode(File('$repoRoot/.fvmrc').readAsStringSync());
  final expected = pinned is Map<String, dynamic> ? pinned['flutter'] : null;
  if (expected is! String) {
    throw const FormatException('`.fvmrc` 에 `flutter` 값이 없다');
  }
  if (running != expected) {
    stderr.writeln('실행 중인 SDK 는 Flutter $running 인데 .fvmrc 는 $expected 다.');
    stderr.writeln('저장소 루트에서 `$runCommand` 로 실행하세요.');
    await quit(78);
  }
  final dart = version['dartSdkVersion'];
  return SdkInfo(
    flutter: running,
    dart: dart is String ? dart : Platform.version.split(' ').first,
  );
}

/// [path] 가 [repoRoot] 아래면 저장소 기준 상대 경로로 바꾼다 (화면에 절대 경로를 남기지 않는다).
String relativize(String path, String repoRoot) =>
    path.startsWith('$repoRoot/') ? path.substring(repoRoot.length + 1) : path;

/// [dir] 에서 `dart pub get` 을 돌린다.
///
/// [enforceLockfile] 이면 `--enforce-lockfile` 을 붙여 커밋된 `pubspec.lock`
/// 그대로 받는다. 실패하면 안내를 적고 exit 69 로 끝낸다 (검증을 시작하지 않는다).
///
/// 늘 `--no-example` 을 붙인다. 기본값대로 두면 저장소 루트의 `pub get` 이 `example/` 도
/// 함께 풀어 어긋난 `example/pubspec.lock` 을 조용히 다시 쓰고, 그 뒤의
/// `--enforce-lockfile` 이 통과해 버린다 (Dart 3.13.4, 2026-10-12 실측).
///
/// [shownAs] 는 실패 안내에 [dir] 대신 적을 이름이다 (화면에 절대 경로를 남기지 않는다).
Future<void> runPubGet(
  String dir, {
  required bool enforceLockfile,
  String? shownAs,
}) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    'pub',
    'get',
    '--no-example',
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
  stderr.writeln('pub get 실패 (${shownAs ?? dir}): exit ${result.exitCode}');
  stderr.writeln('${result.stderr}'.trimRight());
  await quit(69);
}

/// `pubspec.lock` 형식의 [lockFile] 에서 [package] 의 풀린 버전을 읽는다. 없으면 null.
///
/// `example/pubspec.lock` 의 `flutter_lints` / `lints` 와, 상태 폴더의
/// `.plugin_manager/<hash>/pubspec.lock` 의 `riverpod_lint` 를 같은 파서로 읽는다.
String? readLockVersion(File lockFile, String package) {
  if (!lockFile.existsSync()) return null;
  final lines = lockFile.readAsLinesSync();
  final start = lines.indexOf('  $package:');
  if (start < 0) return null;
  for (final line in lines.skip(start + 1)) {
    if (!line.startsWith('    ')) break;
    final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}

/// 상태 폴더 [stateDir] 의 `.plugin_manager` 아래 폴더들 (Analysis Server 가 plugin 을 받아 둔 곳).
List<Directory> pluginFolders(String stateDir) {
  final manager = Directory('$stateDir/.plugin_manager');
  if (!manager.existsSync()) return const [];
  return manager.listSync().whereType<Directory>().toList();
}

/// 전용 상태 폴더 [stateDir] 에서 실제로 풀린 plugin 버전을 읽는다 (D-07).
///
/// 분석이 끝난 뒤에 부른다 — 처음 실행에서는 분석 전에 폴더가 없다. plugin 폴더가
/// 정확히 하나일 때만 읽는다. 폴더 이름은 분석 대상 경로의 해시라 어느 것이 자기
/// 폴더인지 고를 방법이 없다 (spike 008). [shownAs] 는 안내에 적을 상태 폴더 경로다.
PluginVersion readPluginVersion(String stateDir, {required String shownAs}) {
  final folders = pluginFolders(stateDir);
  if (folders.isEmpty) {
    // 서버가 plugin 준비에 이르기 전에 죽었을 때도 이 모양이다 (2026-10-12 실측).
    return PluginVersion.unknown(
      '이 상태 폴더에 plugin 이 준비되지 않았다 — 상태 폴더 환경변수가 듣지 않았을 수 있다',
    );
  }
  if (folders.length > 1) {
    return PluginVersion.unknown(
      '저장소 경로가 바뀐 적 있다 — 상태 폴더 `$shownAs` 를 지우고 다시 실행',
    );
  }
  final version = readLockVersion(
    File('${folders.single.path}/pubspec.lock'),
    pluginPackage,
  );
  return version == null
      ? PluginVersion.unknown('plugin 을 받지 못했다')
      : PluginVersion.resolved(version);
}

/// 다른 도구가 낸 [text] 안의 저장소 절대 경로를 `<repo>` 로 가린다 (CI 로그에 runner 경로를 남기지 않는다).
String scrubPaths(String text, String repoRoot) {
  var scrubbed = text;
  final roots = {repoRoot, Directory(repoRoot).resolveSymbolicLinksSync()};
  for (final root in roots) {
    scrubbed = scrubbed.replaceAll(root, '<repo>');
  }
  return scrubbed;
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

/// [from] 에서 [remove] 의 줄을 건수만큼 뺀 나머지를 돌려준다.
///
/// 같은 줄이 여러 번 있을 수 있다 — 정답지 한 줄에는 열(column)이 없어서 한 줄에 같은
/// 규칙이 두 번 걸리면 똑같은 줄 둘이 된다. [remove] 에 n 번 있는 줄은 [from] 에서
/// 정확히 n 번만 빼고, [from] 의 순서를 지킨다.
List<String> subtractLines(List<String> from, List<String> remove) {
  final remaining = <String, int>{};
  for (final line in remove) {
    remaining[line] = (remaining[line] ?? 0) + 1;
  }
  final rest = <String>[];
  for (final line in from) {
    final left = remaining[line] ?? 0;
    if (left > 0) {
      remaining[line] = left - 1;
    } else {
      rest.add(line);
    }
  }
  return rest;
}

/// 정답지([expected])와 실제 결과를 견준다. 정답지가 없으면(null) 전부 "남는 줄" 이다.
///
/// 줄의 있고 없음이 아니라 건수를 견준다 — 같은 줄이 정답지에 두 번, 실제에 한 번이면
/// 한 줄이 "나오지 않은 줄" 이다 ([subtractLines]).
Difference findDifference(
  Expected? expected,
  List<String> actual,
  int actualExit,
) {
  final expectedLines = expected?.lines ?? const <String>[];
  final String? exitNote;
  if (expected == null) {
    exitNote = '종료 코드: 정답지 없음, 실제 $actualExit';
  } else if (expected.exitCode != actualExit) {
    exitNote = '종료 코드: 정답지 ${expected.exitCode}, 실제 $actualExit';
  } else {
    exitNote = null;
  }
  return Difference(
    missing: subtractLines(expectedLines, actual),
    unexpected: subtractLines(actual, expectedLines),
    exitNote: exitNote,
  );
}

/// 오늘 날짜를 `YYYY-MM-DD` 로 만든다.
String formatDate(DateTime date) {
  String pad(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${pad(date.month)}-${pad(date.day)}';
}

/// 정답지 머리의 `# 실측:` 줄을 만든다 — 어떤 SDK · plugin 버전으로 언제 잰 결과인지.
String formatMeasuredLine(SdkInfo sdk, PluginVersion plugin, DateTime date) =>
    '$measuredPrefix Flutter ${sdk.flutter} / Dart ${sdk.dart}, '
    '$pluginPackage ${plugin.text}, ${formatDate(date)}';

/// 정답지 [file] 을 실제 결과로 다시 쓴다.
///
/// `# 실측:` 줄만 [measured] 로 새로 쓰고 나머지 `#` 줄은 그대로 둔다. 정답지가
/// 없었으면 ([previous] 가 null) 형식 설명 줄도 함께 넣는다.
void writeExpected(
  File file,
  Expected? previous,
  List<String> actual,
  int actualExit,
  String measured,
) {
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

/// [1/4] `lib/` 아래에 `.dart` 파일이 없는지 본다 (VERIFY-07).
///
/// 모든 깊이를 본다. `lib/` 가 없으면 통과다 — 배포 파일이 없는 상태는 규칙 검사가 잡는다.
StepResult checkLibHasNoDart(String repoRoot) {
  const label = 'lib/ 에 .dart 파일 없음';
  final lib = Directory('$repoRoot/lib');
  if (!lib.existsSync()) return StepResult(label: label, passed: true);
  final found =
      lib
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => relativize(f.path, repoRoot))
          .where((p) => p.endsWith('.dart'))
          .toList()
        ..sort();
  if (found.isEmpty) return StepResult(label: label, passed: true);
  return StepResult(
    label: label,
    passed: false,
    detailLines: [
      'lib/ 에 .dart 파일이 있다 (${found.length})',
      ...found.map((p) => '  $p'),
      '',
      '`lib/` 에는 YAML 만 둔다 — 스크립트는 `tool/`, 연습용 코드는 `example/` 에 둔다.',
    ],
  );
}

/// 옵션 파일 내용에서 최상위 `plugins:` 섹션을 뺀다 (spike 007).
///
/// `plugins:` 줄과 그 바로 아래에 이어지는 들여쓴 줄만 지운다. 못 찾으면
/// [FormatException] 을 던진다 — `plugins:` 를 담은 채 분석하면 plugin 을 준비한다
/// (11초 + 네트워크).
String stripPlugins(String options) {
  final stripped = options.replaceAll(
    RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true),
    '',
  );
  if (stripped == options) {
    throw const FormatException('$shippedOptionsPath 에서 `plugins:` 섹션을 찾지 못했다');
  }
  return stripped;
}

/// 복사본의 진단 줄 [line] 이 가리키는 줄에서 규칙 이름을 읽는다. 못 읽으면 null.
String? readRuleNameAt(String line, List<String> copyLines) {
  final number = int.tryParse(
    RegExp(r':(\d+)  ').firstMatch(line)?.group(1) ?? '',
  );
  if (number == null || number < 1 || number > copyLines.length) return null;
  return RegExp(r'^\s*-\s*([A-Za-z0-9_]+)')
      .firstMatch(copyLines[number - 1])
      ?.group(1);
}

/// [2/4] 배포 파일에 deprecated / removed / 없는 규칙이 있는지 본다 (VERIFY-02).
///
/// analyzer 는 규칙의 상태를 `analysis_options.yaml` 이라는 이름의 파일에 직접 적힌
/// 규칙에 대해서만 온전히 보고한다 (include 경유로는 없는 규칙만). 그래서 배포 파일을
/// `plugins:` 없이 [ruleCheckDir] 에 그 이름으로 복사하고, 저장소 루트에서 그 폴더를
/// 인자로 분석한다. 복사본은 어떤 경우에도 지운다. 배포 파일은 읽기만 한다.
Future<StepResult> checkRuleNames(String repoRoot) async {
  const label = '배포 파일의 규칙 이름';
  final copy = stripPlugins(
    File('$repoRoot/$shippedOptionsPath').readAsStringSync(),
  );
  final checkDir = Directory('$repoRoot/$ruleCheckDir');
  try {
    checkDir.createSync(recursive: true);
    File('${checkDir.path}/analysis_options.yaml').writeAsStringSync(copy);
    // plugin 을 준비하지 않으므로 상태 폴더는 주지 않는다. 폴더 인자는 이 검사에서만 쓴다.
    final result = await Process.run(Platform.resolvedExecutable, [
      '--suppress-analytics',
      'analyze',
      '--format=json',
      ruleCheckDir,
    ], workingDirectory: repoRoot);
    final lines = normalizeDiagnostics(result.stdout as String, [
      repoRoot,
      Directory(repoRoot).resolveSymbolicLinksSync(),
    ]);

    if (lines == null || !analyzeExitCodes.contains(result.exitCode)) {
      final stderrHead = (result.stderr as String)
          .trim()
          .split('\n')
          .take(2)
          .join(' / ');
      return StepResult(
        label: label,
        passed: false,
        detailLines: [
          '도구가 죽었다 — 규칙 검사의 dart analyze 가 exit ${result.exitCode} 로 끝났다'
              '${lines == null ? ' (stdout 에 JSON 없음)' : ''}.',
          '  stderr: ${stderrHead.isEmpty ? '(비어 있음)' : stderrHead}',
        ],
      );
    }

    // include 가 풀리지 않으면 규칙을 보지 못한 것이다 — "문제 없음" 으로 넘기지 않는다.
    final unresolved = lines
        .where((l) => l.endsWith('  $includeNotFoundCode'))
        .toList();
    if (unresolved.isNotEmpty) {
      return StepResult(
        label: label,
        passed: false,
        detailLines: [
          '루트 `pub get` 이 안 되어 규칙 검사를 하지 못했다 — 복사본의 include 가 풀리지 않았다.',
          ...unresolved.map((l) => '  $l'),
          '',
          '저장소 루트에서 `fvm dart pub get` 을 돌린 뒤 다시 실행하세요.',
        ],
      );
    }

    final problems = lines
        .where((l) => ruleProblemCodes.any((code) => l.endsWith('  $code')))
        .toList();
    if (problems.isEmpty) return StepResult(label: label, passed: true);

    final copyLines = copy.split('\n');
    return StepResult(
      label: label,
      passed: false,
      detailLines: [
        '배포 파일에 쓸 수 없는 규칙이 있다 (${problems.length})',
        for (final line in problems)
          switch (readRuleNameAt(line, copyLines)) {
            final name? => '  $line  ($name)',
            null => '  $line',
          },
        '',
        '`$shippedOptionsPath` 에서 그 규칙을 지우거나 바꾼다 '
            '(복사본의 줄 번호는 원본과 같다).',
      ],
    );
  } finally {
    if (checkDir.existsSync()) checkDir.deleteSync(recursive: true);
    final parent = checkDir.parent;
    if (parent.existsSync() && parent.listSync().isEmpty) parent.deleteSync();
  }
}

/// [3/4] fixture 의 옵션 파일이 include 한 줄인지 본다.
///
/// 주석과 빈 줄을 뺀 나머지가 정확히 [fixtureIncludeLine] 한 줄이어야 한다.
/// `flutter pub get` 이 써넣는 `build/**` 제외와 include 삭제를 잡는다 (spike 004).
StepResult checkFixtureOptions(String fixtureDir) {
  final name = fixtureDir.split('/').last;
  final label = '$name/ 옵션 파일';
  final optionsPath = '$name/analysis_options.yaml';
  final file = File('$fixtureDir/analysis_options.yaml');
  // 판정은 앞뒤 공백을 뗀 줄로 하고, 화면에는 들여쓰기를 살린 줄을 보여 준다.
  final rest = file.existsSync()
      ? file
            .readAsLinesSync()
            .map((l) => l.trimRight())
            .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'))
            .toList()
      : null;
  if (rest != null &&
      rest.length == 1 &&
      rest.single.trim() == fixtureIncludeLine) {
    return StepResult(label: label, passed: true);
  }
  return StepResult(
    label: label,
    passed: false,
    detailLines: [
      if (rest == null)
        '`$optionsPath` 이 없다.'
      else ...[
        '`$optionsPath` 이 include 한 줄이 아니다 — 주석·빈 줄을 뺀 내용 (${rest.length}줄):',
        if (rest.isEmpty) '  (없음)' else ...rest.map((l) => '  $l'),
      ],
      '',
      '`$optionsPath` 을 include 한 줄로 되돌린다:',
      '  $fixtureIncludeLine',
      '`flutter pub get` 을 돌렸다면: git checkout -- $optionsPath',
    ],
  );
}

/// [4/4] fixture 하나를 분석해 정답지와 견준다 (VERIFY-01).
///
/// 판정 순서는 바꾸지 않는다: plugin 준비 실패 → 도구가 죽음 → 정답지 비교.
/// [update] 이면 바뀌는 줄을 `detailLines` 에 담고 정답지 쓰기를 `applyUpdate` 로
/// 돌려준다 — 쓰는 것은 `main` 이 그 줄을 화면에 내보낸 뒤다. 앞의 두 실패에서는
/// [update] 여도 정답지를 건드리지 않는다. [sdk] 는 정답지 머리 주석에 적는다.
Future<StepResult> compareFixture({
  required String repoRoot,
  required String fixture,
  required bool update,
  required SdkInfo sdk,
}) async {
  final label = '$fixture/ 정답지 비교';
  final fixtureDir = '$repoRoot/$fixture';
  final stateDir = '$repoRoot/.dart_tool/woody_verify/$fixture';
  final shownStateDir = relativize(stateDir, repoRoot);
  Directory(stateDir).createSync(recursive: true);

  // 기다리는 동안의 진행 표시. 화면(stdout)에는 섞지 않는다.
  stderr.writeln('$fixture/ 분석 중…');
  final outcome = await analyzeFixture(
    fixtureDir: fixtureDir,
    stateDir: stateDir,
  );
  // 버전은 분석이 끝난 뒤에 읽는다 (처음 실행에서는 분석 전에 plugin 폴더가 없다).
  final plugin = readPluginVersion(stateDir, shownAs: shownStateDir);

  // 1) plugin 준비 실패 — 종료 코드로는 알 수 없고 stderr 의 머리말로만 드러난다.
  if (outcome.hasPluginHeader) {
    return StepResult(
      label: label,
      passed: false,
      plugin: plugin,
      pluginFailed: true,
      detailLines: [
        'plugin 준비 실패 — $pluginPackage 진단 없이 끝났다 '
            '(dart analyze exit ${outcome.exitCode}). stderr:',
        ...scrubPaths(
          outcome.stderrText,
          repoRoot,
        ).split('\n').map((l) => '  $l'),
        '',
        '네트워크를 확인하세요.',
        '전용 상태 폴더 `$shownStateDir` 를 지우고 다시 실행하세요 (약 15초).',
      ],
    );
  }

  // 2) 도구가 죽음 — 정답지와 "다르다" 가 아니라 결과 자체가 없다.
  final actual = outcome.lines;
  if (actual == null || !analyzeExitCodes.contains(outcome.exitCode)) {
    final stderrHead = scrubPaths(
      outcome.stderrText,
      repoRoot,
    ).split('\n').take(2).join(' / ');
    return StepResult(
      label: label,
      passed: false,
      plugin: plugin,
      detailLines: [
        '도구가 죽었다 — dart analyze 가 exit ${outcome.exitCode} 로 끝났다'
            '${actual == null ? ' (stdout 에 JSON 없음)' : ''}.',
        '  stderr: ${stderrHead.isEmpty ? '(비어 있음)' : stderrHead}',
        '',
        '다시 실행해 보세요. 되풀이되면 위의 stderr 를 확인하세요.',
      ],
    );
  }

  // 3) 정답지 비교.
  final expectedFile = File('$fixtureDir/$expectedFileName');
  final expected = expectedFile.existsSync()
      ? Expected.read(expectedFile)
      : null;
  final difference = findDifference(expected, actual, outcome.exitCode);
  final exitNote = difference.exitNote;

  if (update) {
    // 조용히 덮어쓰지 않는다 — 무엇이 바뀌는지 보여 주고, 그 뒤에 쓴다.
    final measured = formatMeasuredLine(sdk, plugin, DateTime.now());
    return StepResult(
      label: label,
      passed: true,
      plugin: plugin,
      detailLines: [
        '정답지 갱신: $fixture/$expectedFileName',
        if (difference.isEmpty)
          '정답지와 같다 — 바뀐 줄 없음'
        else ...[
          ?exitNote,
          ...difference.missing.map((l) => '- $l'),
          ...difference.unexpected.map((l) => '+ $l'),
        ],
        '머리 주석: $measured',
      ],
      applyUpdate: () => writeExpected(
        expectedFile,
        expected,
        actual,
        outcome.exitCode,
        measured,
      ),
    );
  }

  if (expected == null) {
    return StepResult(
      label: label,
      passed: false,
      plugin: plugin,
      detailLines: ['정답지가 없다. 처음이면 `$updateCommand` 로 만든다.'],
    );
  }
  if (difference.isEmpty) {
    return StepResult(label: label, passed: true, plugin: plugin);
  }

  return StepResult(
    label: label,
    passed: false,
    plugin: plugin,
    detailLines: [
      if (exitNote != null) ...[exitNote, ''],
      '정답지에는 있는데 나오지 않은 경고 (${difference.missing.length})',
      ...difference.missing.map((l) => '  $l'),
      '',
      '정답지에 없는데 나온 경고 (${difference.unexpected.length})',
      ...difference.unexpected.map((l) => '  $l'),
      '',
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

/// 화면 맨 위의 버전 세 줄(SDK / 기반 세트 / plugin)을 만든다 (D-07).
///
/// 정답지가 깨졌을 때 원인이 저장소 변경인지 새 버전인지 화면에서 바로 보이게 한다.
/// [pluginFailed] 이면 plugin 줄에 덧말을 붙인다 — 그 실행에서 읽힌 버전은 앞선
/// 실행이 남긴 값일 수 있다.
List<String> formatVersionLines({
  required SdkInfo sdk,
  required String? flutterLints,
  required String? lints,
  required PluginVersion plugin,
  required bool pluginFailed,
}) {
  String formatRow(String label, String value) =>
      '$label${' ' * (versionColumn - measureWidth(label))}$value';
  final reason = plugin.reason;
  return [
    formatRow('SDK', 'Flutter ${sdk.flutter} / Dart ${sdk.dart}'),
    formatRow(
      '기반 세트',
      'flutter_lints ${flutterLints ?? '?'} / lints ${lints ?? '?'}',
    ),
    formatRow(
      'plugin',
      '$pluginPackage ${plugin.text}'
          '${reason == null ? '' : ' ($reason)'}'
          '${pluginFailed ? ' (이번 실행에서는 plugin 이 뜨지 않았다)' : ''}',
    ),
  ];
}

/// 인자를 읽고, 준비(SDK 확인 · pub get)를 한 뒤, 단계를 모두 돌리고 화면을 한 번에 찍는다.
///
/// 화면(버전 3줄 · 단계 줄 · 실패의 내용 · 요약)은 전부 stdout 이고 첫 줄은 늘 `SDK`
/// 줄이다 — plugin 버전은 분석이 끝나야 읽히므로 단계를 모두 돌린 뒤에 찍는다.
/// 사용법 오류, 준비 단계의 안내, 진행 표시는 stderr 다.
Future<void> main(List<String> args) async {
  final unknown = args.where((a) => a != '--update').toList();
  if (unknown.isNotEmpty) {
    stderr.writeln('모르는 인자: ${unknown.join(' ')}');
    stderr.writeln('사용법: $runCommand [--update]');
    await quit(64);
  }
  final update = args.contains('--update');

  // tool/ 의 부모가 저장소 루트다. 어느 폴더에서 실행해도 같은 파일을 본다.
  final repoRoot = File.fromUri(Platform.script).parent.parent.path;

  try {
    // 준비 1 — 실행 중인 SDK 가 .fvmrc 와 다르면 검증을 시작하지 않는다 (D-12).
    final sdk = await ensurePinnedSdk(repoRoot);

    // 준비 2 — 정답지 갱신은 로컬에서 사람이 diff 를 보고 커밋한다 (D-14).
    final env = Platform.environment;
    if (update && (env['CI'] == 'true' || env['GITHUB_ACTIONS'] == 'true')) {
      stderr.writeln('CI 에서는 --update 를 쓰지 않는다 — 로컬에서 갱신해 커밋하세요.');
      await quit(64);
    }

    // 준비 3 — 저장소 루트의 패키지. 규칙 검사의 복사본이 `flutter_lints` 를 include 하므로
    // 루트의 package_config 가 있어야 한다 (없으면 include 가 풀리지 않아 규칙을 못 본다).
    await runPubGet(repoRoot, enforceLockfile: false, shownAs: '저장소 루트');

    // 준비 4 — fixture 의 패키지는 커밋된 lock 그대로 받는다.
    for (final fixture in fixtures) {
      await runPubGet(
        '$repoRoot/$fixture',
        enforceLockfile: true,
        shownAs: '$fixture/',
      );
    }

    // 단계는 하나가 실패해도 나머지를 모두 돌린다. fixture 는 순서대로 분석한다
    // (빈 상태 폴더에 처음 실행 둘을 동시에 띄우면 드물게 깨진다 — spike 008).
    final steps = <Future<StepResult> Function()>[
      () async => checkLibHasNoDart(repoRoot),
      () => checkRuleNames(repoRoot),
      for (final fixture in fixtures) ...[
        () async => checkFixtureOptions('$repoRoot/$fixture'),
        () => compareFixture(
          repoRoot: repoRoot,
          fixture: fixture,
          update: update,
          sdk: sdk,
        ),
      ],
    ];
    final results = <StepResult>[];
    for (final step in steps) {
      results.add(await step());
    }

    // 화면 — 버전 3줄, 단계 줄, 단계별 내용, 요약 순으로 한 번에 찍는다.
    // 기반 세트는 fixture 의 lock 에서, plugin 은 첫 fixture 의 상태 폴더에서 읽은 값이다
    // (fixture 가 늘어 값이 갈릴 수 있게 되면 fixture 별로 찍는다 — Phase 3).
    final baseLock = File('$repoRoot/${fixtures.first}/pubspec.lock');
    final plugin =
        results.map((r) => r.plugin).nonNulls.firstOrNull ??
        PluginVersion.unknown('정답지 비교를 돌리지 못했다');
    formatVersionLines(
      sdk: sdk,
      flutterLints: readLockVersion(baseLock, 'flutter_lints'),
      lints: readLockVersion(baseLock, 'lints'),
      plugin: plugin,
      pluginFailed: results.any((r) => r.pluginFailed),
    ).forEach(stdout.writeln);
    stdout.writeln('');
    for (var i = 0; i < results.length; i++) {
      stdout.writeln(formatStepLine(i + 1, results.length, results[i]));
    }
    for (final result in results.where((r) => r.detailLines.isNotEmpty)) {
      stdout.writeln('');
      result.detailLines.forEach(stdout.writeln);
    }

    // `--update` 의 쓰기는 바뀌는 줄을 화면에 내보낸 뒤에 한다 (D-14).
    await stdout.flush();
    for (final result in results) {
      result.applyUpdate?.call();
    }

    final failed = results.where((r) => !r.passed).toList();
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
    stderr.writeln(
      '파일 작업 실패: ${e.message} (${relativize(e.path ?? '', repoRoot)})',
    );
    exitCode = 70;
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: $e');
    exitCode = 70;
  }
}
