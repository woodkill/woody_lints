// spike 001 — `dart analyze` 를 실행 형태별로 돌려 plugin 진단이 나오는지 표로 찍는다.
//
// 실행: fvm dart run .planning/spikes/001-analyze-invocation-form/matrix.dart <상태 폴더> [cold 반복 횟수]
//
// 상태 폴더는 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 넘긴다. 실행 형태마다 빈 폴더에서
// 시작하므로 `~/.dartServer` 를 건드리지 않고 "처음 실행(cold)"을 만들 수 있다.
import 'dart:convert';
import 'dart:io';

/// riverpod_lint 가 내는 진단 이름. 연습용 프로젝트에는 이 두 건만 심어 두었다.
const pluginCodes = {
  'missing_provider_scope',
  'avoid_public_notifier_properties',
};

/// `dart analyze` 를 부르는 형태 하나 (작업 디렉터리 + 인자).
class Invocation {
  /// [label] 은 표에 찍을 이름, [workingDirectory] 는 실행 위치, [arguments] 는 경로 인자다.
  const Invocation(this.label, this.workingDirectory, this.arguments);

  /// 표에 찍을 이름.
  final String label;

  /// `dart analyze` 를 실행할 디렉터리.
  final String workingDirectory;

  /// `dart analyze --format=json` 뒤에 붙일 경로 인자.
  final List<String> arguments;
}

/// 실행 한 번의 결과.
class RunResult {
  /// 실행 결과를 담는다. [lines] 는 정답지 형식(`경로:줄  강도  규칙`)으로 정규화한 진단이다.
  const RunResult({
    required this.exitCode,
    required this.elapsed,
    required this.lines,
    required this.stderrText,
    required this.parseError,
  });

  /// `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 걸린 시간.
  final Duration elapsed;

  /// 정규화한 진단 줄 (정렬됨).
  final List<String> lines;

  /// stderr 전체.
  final String stderrText;

  /// stdout 을 JSON 으로 읽지 못했을 때의 설명. 읽었으면 null.
  final String? parseError;

  /// plugin 진단 줄만 고른다.
  List<String> get pluginLines =>
      lines.where((l) => pluginCodes.contains(l.split(RegExp(r'\s+')).last)).toList();
}

/// stdout 의 JSON 을 정답지 형식 줄 목록으로 바꾼다. 경로는 [fixtureDir] 기준 상대 경로로 만든다.
List<String> normalizeDiagnostics(String stdoutText, String fixtureDir) {
  final jsonLine = stdoutText
      .split('\n')
      .lastWhere((l) => l.trimLeft().startsWith('{'), orElse: () => '');
  if (jsonLine.isEmpty) {
    throw const FormatException('stdout 에 JSON 줄이 없다');
  }
  final decoded = jsonDecode(jsonLine);
  if (decoded is! Map<String, dynamic> || decoded['diagnostics'] is! List) {
    throw const FormatException('diagnostics 배열이 없다');
  }
  final prefix = fixtureDir.endsWith('/') ? fixtureDir : '$fixtureDir/';
  final lines = <String>[];
  for (final d in decoded['diagnostics'] as List) {
    final location = (d as Map<String, dynamic>)['location'] as Map<String, dynamic>;
    final file = location['file'] as String;
    final line = ((location['range'] as Map)['start'] as Map)['line'];
    final relative = file.startsWith(prefix) ? file.substring(prefix.length) : file;
    final severity = (d['severity'] as String).toLowerCase();
    lines.add('$relative:$line  $severity  ${d['code']}');
  }
  return lines..sort();
}

/// [invocation] 형태로 `dart analyze --format=json` 을 한 번 실행한다.
Future<RunResult> runAnalyze(
  Invocation invocation,
  Directory stateDir,
  String fixtureDir,
) async {
  final watch = Stopwatch()..start();
  final ProcessResult result;
  try {
    result = await Process.run(
      Platform.resolvedExecutable,
      ['analyze', '--format=json', ...invocation.arguments],
      workingDirectory: invocation.workingDirectory,
      environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir.path},
    );
  } on ProcessException catch (e) {
    return RunResult(
      exitCode: -1,
      elapsed: watch.elapsed,
      lines: const [],
      stderrText: e.toString(),
      parseError: '프로세스를 띄우지 못했다',
    );
  }
  watch.stop();
  var lines = <String>[];
  String? parseError;
  try {
    lines = normalizeDiagnostics(result.stdout as String, fixtureDir);
  } on FormatException catch (e) {
    parseError = e.message;
  }
  return RunResult(
    exitCode: result.exitCode,
    elapsed: watch.elapsed,
    lines: lines,
    stderrText: result.stderr as String,
    parseError: parseError,
  );
}

/// 결과 한 줄을 표의 칸들로 바꾼다.
String formatRow(String label, String phase, RunResult r) {
  final seconds = (r.elapsed.inMilliseconds / 1000).toStringAsFixed(1);
  final plugin = '${r.pluginLines.length}/${pluginCodes.length}';
  final stderrNote = r.stderrText.trim().isEmpty ? '-' : '${r.stderrText.trim().split('\n').length}줄';
  final note = r.parseError ?? '';
  return '| $label | $phase | ${r.exitCode} | ${seconds}s | ${r.lines.length} | $plugin | $stderrNote | $note |';
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('사용법: dart run matrix.dart <상태 폴더> [cold 반복 횟수]');
    exit(64);
  }
  final stateBase = Directory(args[0]);
  final repeat = args.length > 1 ? int.tryParse(args[1]) ?? 1 : 1;

  final spikeDir = File.fromUri(Platform.script).parent;
  final fixtureDir = Directory('${spikeDir.path}/fixture').absolute.path;
  final repoRoot = spikeDir.parent.parent.parent.absolute.path;
  final fixtureFromRoot = fixtureDir.substring(repoRoot.length + 1);

  if (!File('$fixtureDir/.dart_tool/package_config.json').existsSync()) {
    stderr.writeln('연습용 프로젝트에 패키지가 없다. 먼저 실행: (cd $fixtureDir && fvm dart pub get)');
    exit(66);
  }

  final invocations = <Invocation>[
    Invocation('A. fixture 에서 인자 없음', fixtureDir, const []),
    Invocation('B. fixture 에서 `.`', fixtureDir, const ['.']),
    Invocation('C. fixture 에서 `lib`', fixtureDir, const ['lib']),
    Invocation('D. fixture 에서 `lib/src`', fixtureDir, const ['lib/src']),
    Invocation('E. fixture 에서 `lib/main.dart`', fixtureDir, const ['lib/main.dart']),
    Invocation('F. fixture 에서 파일 2개', fixtureDir, const ['lib/main.dart', 'lib/src/counter.dart']),
    Invocation('G. fixture 에서 절대 경로(자기 자신)', fixtureDir, [fixtureDir]),
    Invocation('H. 저장소 루트에서 상대 경로', repoRoot, [fixtureFromRoot]),
    Invocation('I. 저장소 루트에서 절대 경로', repoRoot, [fixtureDir]),
    Invocation('J. 저장소 루트에서 `<fixture>/lib`', repoRoot, ['$fixtureFromRoot/lib']),
    Invocation('K. fixture 의 부모에서 `fixture`', spikeDir.absolute.path, const ['fixture']),
  ];

  stdout.writeln('Dart ${Platform.version.split(' ').first}, 상태 폴더 ${stateBase.path}');
  stdout.writeln('');
  stdout.writeln('| 실행 형태 | 상태 | exit | 시간 | 진단 수 | plugin 진단 | stderr | 비고 |');
  stdout.writeln('|---|---|---|---|---|---|---|---|');

  final record = <Map<String, Object?>>[];
  var index = 0;
  for (final invocation in invocations) {
    index++;
    // 형태 A 만 cold 를 여러 번 반복해 흔들림(flakiness)을 본다.
    final coldRuns = invocation.label.startsWith('A.') ? repeat : 1;
    for (var n = 1; n <= coldRuns; n++) {
      final stateDir = Directory('${stateBase.path}/case-$index-$n');
      if (stateDir.existsSync()) stateDir.deleteSync(recursive: true);
      stateDir.createSync(recursive: true);

      final cold = await runAnalyze(invocation, stateDir, fixtureDir);
      stdout.writeln(formatRow(invocation.label, 'cold #$n', cold));
      final warm = await runAnalyze(invocation, stateDir, fixtureDir);
      stdout.writeln(formatRow(invocation.label, 'warm #$n', warm));

      for (final entry in {'cold': cold, 'warm': warm}.entries) {
        record.add({
          'label': invocation.label,
          'workingDirectory': invocation.workingDirectory,
          'arguments': invocation.arguments,
          'phase': entry.key,
          'run': n,
          'exitCode': entry.value.exitCode,
          'elapsedMs': entry.value.elapsed.inMilliseconds,
          'lines': entry.value.lines,
          'stderr': entry.value.stderrText,
          'parseError': entry.value.parseError,
        });
      }
    }
  }

  final resultsFile = File('${spikeDir.path}/results/matrix.json');
  try {
    resultsFile.parent.createSync(recursive: true);
    resultsFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(record)}\n');
    stdout.writeln('');
    stdout.writeln('원본 결과: ${resultsFile.path}');
  } on FileSystemException catch (e) {
    stderr.writeln('결과 파일을 쓰지 못했다: ${e.message}');
    exit(74);
  }
}
