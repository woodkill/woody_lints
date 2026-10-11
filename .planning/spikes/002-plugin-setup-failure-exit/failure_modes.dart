// spike 002 — plugin 준비가 실패했을 때 `dart analyze` 가 무엇을 돌려주는지 경우별로 찍는다.
//
// 실행: fvm dart run .planning/spikes/002-plugin-setup-failure-exit/failure_modes.dart <상태 폴더> [경우 id ...]
//
// 경우마다 fixture/analysis_options.yaml 을 바꿔 쓰고, 끝나면 원래 내용으로 되돌린다.
// 상태 폴더는 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 넘겨 `~/.dartServer` 를 건드리지 않는다.
// 분석 통계 전송은 끈다 (`DASH__SUPPRESS_ANALYTICS=true`) — spike 001 에서 본 종료 코드 255 를 피한다.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// 정상 설정. 배포 파일을 include 한 줄로 받는다.
const okOptions = 'include: package:woody_lints/analysis_options.yaml\n';

/// 아무도 듣지 않는 주소. pub 서버에 닿지 못하는 상황을 만든다.
const unreachablePub = {'PUB_HOSTED_URL': 'http://127.0.0.1:9'};

/// 확인할 경우 하나.
class Scenario {
  /// [options] 는 이 경우에 쓸 `analysis_options.yaml` 내용이다.
  /// [primeFirst] 가 true 면 정상 설정으로 한 번 돌려 plugin 을 준비해 둔 뒤 이 경우를 돌린다.
  const Scenario({
    required this.id,
    required this.title,
    required this.options,
    this.environment = const {},
    this.primeFirst = false,
  });

  /// 짧은 이름 (결과 파일 이름에 쓴다).
  final String id;

  /// 표에 찍을 설명.
  final String title;

  /// `analysis_options.yaml` 내용.
  final String options;

  /// 추가 환경변수.
  final Map<String, String> environment;

  /// 먼저 정상 설정으로 plugin 을 준비해 둘지.
  final bool primeFirst;
}

/// 실행 한 번의 결과.
class Outcome {
  /// 결과를 담는다.
  const Outcome({
    required this.exitCode,
    required this.timedOut,
    required this.elapsed,
    required this.stdoutText,
    required this.stderrText,
    required this.lines,
    required this.jsonOk,
    required this.pluginSnapshot,
  });

  /// 종료 코드. 시간 초과면 -1.
  final int exitCode;

  /// 시간 제한에 걸려 죽였는지.
  final bool timedOut;

  /// 걸린 시간.
  final Duration elapsed;

  /// stdout 원문 (경로는 `<fixture>`, `<state>` 로 바꿔 둔다).
  final String stdoutText;

  /// stderr 원문 (경로는 `<fixture>`, `<state>` 로 바꿔 둔다).
  final String stderrText;

  /// 정답지 형식으로 정규화한 진단 줄.
  final List<String> lines;

  /// stdout 이 JSON 으로 읽혔는지.
  final bool jsonOk;

  /// 상태 폴더에 컴파일된 plugin(`plugin.aot`)이 생겼는지.
  final bool pluginSnapshot;

  /// 결과 파일에 쓸 map.
  Map<String, Object?> toJson() => {
        'exitCode': exitCode,
        'timedOut': timedOut,
        'elapsedMs': elapsed.inMilliseconds,
        'jsonOk': jsonOk,
        'pluginSnapshot': pluginSnapshot,
        'lines': lines,
        'stdout': stdoutText,
        'stderr': stderrText,
      };
}

const scenarios = [
  Scenario(
    id: 's0-control',
    title: '대조군: 정상 설정',
    options: okOptions,
  ),
  Scenario(
    id: 's1-bad-version-info',
    title: '없는 버전(^99.0.0) + 다른 경고는 info 뿐',
    options: '${okOptions}\nplugins:\n  riverpod_lint: ^99.0.0\n',
  ),
  Scenario(
    id: 's2-bad-version-nothing',
    title: '없는 버전(^99.0.0) + 다른 경고 없음',
    options: 'plugins:\n  riverpod_lint: ^99.0.0\n',
  ),
  Scenario(
    id: 's3-bad-version-warning',
    title: '없는 버전(^99.0.0) + 다른 경고에 warning 있음',
    options:
        '${okOptions}\nanalyzer:\n  errors:\n    avoid_print: warning\n\nplugins:\n  riverpod_lint: ^99.0.0\n',
  ),
  Scenario(
    id: 's4-unknown-package-info',
    title: '없는 plugin 패키지를 하나 더 선언 + info',
    options: '${okOptions}\nplugins:\n  woody_no_such_plugin_zz9: ^1.0.0\n',
  ),
  Scenario(
    id: 's5-offline-cold-info',
    title: 'pub 서버에 닿지 못함, 처음 실행 + info',
    options: okOptions,
    environment: unreachablePub,
  ),
  Scenario(
    id: 's6-offline-cold-nothing',
    title: 'pub 서버에 닿지 못함, 처음 실행 + 다른 경고 없음',
    options: 'plugins:\n  riverpod_lint: ^3.1.3\n',
    environment: unreachablePub,
  ),
  Scenario(
    id: 's7-offline-warm-info',
    title: 'pub 서버에 닿지 못함, plugin 은 이미 준비됨 + info',
    options: okOptions,
    environment: unreachablePub,
    primeFirst: true,
  ),
  Scenario(
    id: 's8-old-plugin-info',
    title: '옛 plugin 버전(3.1.0 고정) + info',
    options: '${okOptions}\nplugins:\n  riverpod_lint: 3.1.0\n',
  ),
  Scenario(
    id: 's9-compile-error-info',
    title: '패키지는 받아지지만 컴파일이 실패하는 plugin 을 하나 더 선언 + info',
    options: '${okOptions}\nplugins:\n  broken_plugin:\n    path: __SPIKE_DIR__/broken_plugin\n',
  ),
];

/// stdout 의 JSON 을 정답지 형식 줄 목록으로 바꾼다. 읽지 못하면 null.
List<String>? normalizeDiagnostics(String stdoutText, String fixtureDir) {
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
  if (decoded is! Map<String, dynamic> || decoded['diagnostics'] is! List) return null;
  final prefix = '$fixtureDir/';
  final lines = <String>[];
  for (final d in decoded['diagnostics'] as List) {
    final location = (d as Map<String, dynamic>)['location'] as Map<String, dynamic>;
    final file = location['file'] as String;
    final line = ((location['range'] as Map)['start'] as Map)['line'];
    final relative = file.startsWith(prefix) ? file.substring(prefix.length) : file;
    lines.add('$relative:$line  ${(d['severity'] as String).toLowerCase()}  ${d['code']}');
  }
  return lines..sort();
}

/// 상태 폴더 아래에 컴파일된 plugin 이 있는지 본다.
bool hasPluginSnapshot(Directory stateDir) {
  final manager = Directory('${stateDir.path}/.plugin_manager');
  if (!manager.existsSync()) return false;
  return manager
      .listSync(recursive: true)
      .any((e) => e is File && e.path.endsWith('/bin/plugin.aot'));
}

/// fixture 에서 `dart analyze --format=json` 을 한 번 실행한다.
Future<Outcome> runAnalyze({
  required String fixtureDir,
  required Directory stateDir,
  required Map<String, String> environment,
  Duration limit = const Duration(minutes: 5),
}) async {
  final watch = Stopwatch()..start();
  final process = await Process.start(
    Platform.resolvedExecutable,
    ['analyze', '--format=json'],
    workingDirectory: fixtureDir,
    environment: {
      'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir.path,
      'DASH__SUPPRESS_ANALYTICS': 'true',
      ...environment,
    },
  );
  final out = process.stdout.transform(utf8.decoder).join();
  final err = process.stderr.transform(utf8.decoder).join();
  var timedOut = false;
  final code = await process.exitCode.timeout(limit, onTimeout: () {
    timedOut = true;
    process.kill(ProcessSignal.sigkill);
    return -1;
  });
  watch.stop();

  final spikePath = Directory(fixtureDir).parent.path;
  String scrub(String text) => text
      .replaceAll(stateDir.path, '<state>')
      .replaceAll(fixtureDir, '<fixture>')
      .replaceAll(spikePath, '<spike>');
  final stdoutText = await out;
  final lines = normalizeDiagnostics(stdoutText, fixtureDir);
  return Outcome(
    exitCode: code,
    timedOut: timedOut,
    elapsed: watch.elapsed,
    stdoutText: scrub(stdoutText).trim(),
    stderrText: scrub(await err).trim(),
    lines: lines ?? const [],
    jsonOk: lines != null,
    pluginSnapshot: hasPluginSnapshot(stateDir),
  );
}

/// 표의 한 줄을 만든다.
String formatRow(Scenario s, String phase, Outcome o) {
  final seconds = (o.elapsed.inMilliseconds / 1000).toStringAsFixed(1);
  final exit = o.timedOut ? '시간 초과' : '${o.exitCode}';
  final diagnostics = o.jsonOk ? '${o.lines.length}' : 'JSON 없음';
  final hasPluginDiagnostic = o.lines.any((l) => l.endsWith('missing_provider_scope'));
  final stderrLines = o.stderrText.isEmpty ? 0 : o.stderrText.split('\n').length;
  return '| ${s.id} | ${s.title} | $phase | $exit | ${seconds}s | $diagnostics | '
      '${hasPluginDiagnostic ? '있음' : '없음'} | ${o.pluginSnapshot ? '있음' : '없음'} | $stderrLines줄 |';
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('사용법: dart run failure_modes.dart <상태 폴더> [경우 id ...]');
    exit(64);
  }
  final stateBase = Directory(args[0]);
  final only = args.skip(1).toSet();

  final spikeDir = File.fromUri(Platform.script).parent;
  final fixtureDir = Directory('${spikeDir.path}/fixture').absolute.path;
  final optionsFile = File('$fixtureDir/analysis_options.yaml');
  final resultsDir = Directory('${spikeDir.path}/results');
  if (!File('$fixtureDir/.dart_tool/package_config.json').existsSync()) {
    stderr.writeln('연습용 프로젝트에 패키지가 없다. 먼저 실행: (cd $fixtureDir && fvm dart pub get)');
    exit(66);
  }

  final original = optionsFile.readAsStringSync();
  final record = <String, Object?>{};

  stdout.writeln('Dart ${Platform.version.split(' ').first}');
  stdout.writeln('');
  stdout.writeln('| id | 경우 | 실행 | exit | 시간 | 진단 수 | plugin 진단 | plugin.aot | stderr |');
  stdout.writeln('|---|---|---|---|---|---|---|---|---|');

  try {
    resultsDir.createSync(recursive: true);
    for (final s in scenarios) {
      if (only.isNotEmpty && !only.contains(s.id)) continue;
      final stateDir = Directory('${stateBase.path}/${s.id}');
      if (stateDir.existsSync()) stateDir.deleteSync(recursive: true);
      stateDir.createSync(recursive: true);

      if (s.primeFirst) {
        optionsFile.writeAsStringSync(okOptions);
        final primed = await runAnalyze(
          fixtureDir: fixtureDir,
          stateDir: stateDir,
          environment: const {},
        );
        stdout.writeln(formatRow(s, '준비(정상)', primed));
      }

      // `__SPIKE_DIR__` 는 이 spike 폴더의 절대 경로로 바꿔 쓴다 (path plugin 용).
      optionsFile.writeAsStringSync(s.options.replaceAll('__SPIKE_DIR__', spikeDir.absolute.path));
      final first = await runAnalyze(
        fixtureDir: fixtureDir,
        stateDir: stateDir,
        environment: s.environment,
      );
      stdout.writeln(formatRow(s, '1회차', first));
      final second = await runAnalyze(
        fixtureDir: fixtureDir,
        stateDir: stateDir,
        environment: s.environment,
      );
      stdout.writeln(formatRow(s, '2회차', second));

      record[s.id] = {
        'title': s.title,
        'options': s.options,
        'environment': s.environment,
        'primeFirst': s.primeFirst,
        'first': first.toJson(),
        'second': second.toJson(),
      };
      File('${resultsDir.path}/${s.id}.stderr.txt').writeAsStringSync(
        '# ${s.title}\n# 1회차 exit=${first.exitCode}\n${first.stderrText}\n\n'
        '# 2회차 exit=${second.exitCode}\n${second.stderrText}\n',
      );
    }
    final resultsFile = File('${resultsDir.path}/failure_modes.json');
    // 일부 경우만 다시 돌렸을 때 앞선 결과를 지우지 않도록 합쳐 쓴다.
    var merged = <String, Object?>{};
    if (resultsFile.existsSync()) {
      try {
        merged = jsonDecode(resultsFile.readAsStringSync()) as Map<String, Object?>;
      } on FormatException {
        merged = {};
      }
    }
    merged.addAll(record);
    resultsFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(merged)}\n');
    stdout.writeln('');
    stdout.writeln('원본 결과: ${resultsFile.path}');
  } on FileSystemException catch (e) {
    stderr.writeln('파일 작업 실패: ${e.message} (${e.path})');
    exitCode = 74;
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: $e');
    exitCode = 70;
  } finally {
    // 어떤 경우에도 연습용 프로젝트의 옵션 파일을 원래대로 돌려놓는다.
    optionsFile.writeAsStringSync(original);
  }
}
