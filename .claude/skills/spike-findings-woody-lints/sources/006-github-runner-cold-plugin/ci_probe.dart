// spike 006 — GitHub Linux runner 의 cold 실행에서 plugin 진단이 빠짐없이 나오는지와 걸리는 시간을 잰다.
//
// runner 에서:  dart run .planning/spikes/006-github-runner-cold-plugin/ci_probe.dart
// 로컬 연습:    fvm dart run .planning/spikes/006-github-runner-cold-plugin/ci_probe.dart <상태 폴더>
//
// 상태 폴더를 주면 모든 실행에 `ANALYZER_STATE_LOCATION_OVERRIDE` 를 걸어 `~/.dartServer` 를 건드리지 않는다.
// 주지 않으면 첫 실행은 기본 자리(`~/.dartServer`)를 그대로 쓴다 — 평범한 CI job 이 겪는 그대로를 보려는 것이다.
// 이 모드는 GitHub Actions 안에서만 허용한다.
import 'dart:convert';
import 'dart:io';

/// 실행 한 번의 기록.
class Run {
  /// [label] 은 표에 찍을 이름이다. [lines] 는 정답지 형식으로 정규화한 진단 줄이다.
  Run({
    required this.label,
    required this.exitCode,
    required this.elapsed,
    required this.lines,
    required this.jsonOk,
    required this.stderrText,
    required this.missing,
    required this.unexpected,
    required this.expectedExit,
  });

  /// 표에 찍을 이름.
  final String label;

  /// `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 걸린 시간.
  final Duration elapsed;

  /// 정규화한 진단 줄 (정렬됨).
  final List<String> lines;

  /// stdout 이 JSON 으로 읽혔는지.
  final bool jsonOk;

  /// stderr 원문.
  final String stderrText;

  /// 기대에는 있는데 나오지 않은 줄.
  final List<String> missing;

  /// 기대에 없는데 나온 줄.
  final List<String> unexpected;

  /// 기대한 종료 코드.
  final int expectedExit;

  /// 기대와 완전히 같은지.
  bool get matches =>
      jsonOk && missing.isEmpty && unexpected.isEmpty && exitCode == expectedExit;

  /// 결과 파일에 쓸 map.
  Map<String, Object?> toJson() => {
        'label': label,
        'exitCode': exitCode,
        'expectedExit': expectedExit,
        'elapsedMs': elapsed.inMilliseconds,
        'jsonOk': jsonOk,
        'matches': matches,
        'diagnostics': lines.length,
        'missing': missing,
        'unexpected': unexpected,
        'stderrHead': stderrText.split('\n').take(6).join('\n'),
      };
}

/// 기대 진단 파일 (`exit N` 한 줄 + 진단 줄들).
class Expected {
  /// 파일을 읽어 종료 코드와 줄 목록으로 나눈다.
  factory Expected.read(File file) {
    final lines = file
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();
    if (lines.isEmpty || !lines.first.startsWith('exit ')) {
      throw FormatException('첫 줄이 `exit N` 이 아니다: ${file.path}');
    }
    final code = int.parse(lines.first.substring('exit '.length));
    return Expected._(code, lines.skip(1).toList()..sort());
  }

  Expected._(this.exitCode, this.lines);

  /// 기대한 종료 코드.
  final int exitCode;

  /// 기대한 진단 줄 (정렬됨).
  final List<String> lines;
}

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

/// [fixtureDir] 에서 `dart [globalArguments] analyze --format=json` 을 한 번 실행하고 기대와 견준다.
Future<Run> runAnalyze({
  required String label,
  required String fixtureDir,
  required Expected expected,
  String? stateDir,
  List<String> globalArguments = const [],
}) async {
  final watch = Stopwatch()..start();
  final result = await Process.run(
    Platform.resolvedExecutable,
    [...globalArguments, 'analyze', '--format=json'],
    workingDirectory: fixtureDir,
    environment: {
      if (stateDir != null) 'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir,
    },
  );
  watch.stop();
  final lines = normalizeDiagnostics(result.stdout as String, fixtureDir);
  final actual = lines ?? const <String>[];
  final run = Run(
    label: label,
    exitCode: result.exitCode,
    elapsed: watch.elapsed,
    lines: actual,
    jsonOk: lines != null,
    stderrText: (result.stderr as String).trim(),
    missing: expected.lines.where((l) => !actual.contains(l)).toList(),
    unexpected: actual.where((l) => !expected.lines.contains(l)).toList(),
    expectedExit: expected.exitCode,
  );
  final seconds = (run.elapsed.inMilliseconds / 1000).toStringAsFixed(1);
  stdout.writeln('${run.matches ? '통과' : '실패'}  $label: exit ${run.exitCode} (기대 ${run.expectedExit}), '
      '${seconds}s, 진단 ${actual.length}건, 빠진 줄 ${run.missing.length}, 남는 줄 ${run.unexpected.length}');
  for (final l in run.missing) {
    stdout.writeln('    - $l');
  }
  for (final l in run.unexpected) {
    stdout.writeln('    + $l');
  }
  if (run.stderrText.isNotEmpty) {
    stdout.writeln('    stderr: ${run.stderrText.split('\n').take(3).join(' / ')}');
  }
  return run;
}

/// [fixtureDir] 에서 `dart pub get` 을 돌리고 걸린 시간을 돌려준다. 실패하면 프로그램을 끝낸다.
Future<Duration> runPubGet(String fixtureDir) async {
  final watch = Stopwatch()..start();
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['pub', 'get'],
    workingDirectory: fixtureDir,
  );
  watch.stop();
  if (result.exitCode != 0) {
    stderr.writeln('pub get 실패 ($fixtureDir): exit ${result.exitCode}\n${result.stderr}');
    exit(69);
  }
  return watch.elapsed;
}

/// plugin 상태 폴더에서 실제로 풀린 `riverpod_lint` 버전들을 읽는다.
Set<String> readResolvedPluginVersions(Directory stateRoot) {
  final manager = Directory('${stateRoot.path}/.plugin_manager');
  final versions = <String>{};
  if (!manager.existsSync()) return versions;
  for (final entity in manager.listSync()) {
    final lock = File('${entity.path}/pubspec.lock');
    if (!lock.existsSync()) continue;
    final lines = lock.readAsLinesSync();
    final start = lines.indexOf('  riverpod_lint:');
    if (start < 0) continue;
    for (final line in lines.skip(start + 1)) {
      if (!line.startsWith('    ')) break;
      final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
      if (match != null) versions.add(match.group(1)!);
    }
  }
  return versions;
}

Future<void> main(List<String> args) async {
  final env = Platform.environment;
  final onGitHub = env['GITHUB_ACTIONS'] == 'true';
  final stateBase = args.isNotEmpty ? Directory(args[0]) : null;
  if (stateBase == null && !onGitHub) {
    stderr.writeln('로컬에서는 상태 폴더를 꼭 준다 (기본 자리 ~/.dartServer 를 쓰지 않으려고).');
    stderr.writeln('사용법: fvm dart run ci_probe.dart <상태 폴더>');
    exit(64);
  }

  final spikeDir = File.fromUri(Platform.script).parent;
  final spikesDir = spikeDir.parent;
  final basicFixture = Directory('${spikesDir.path}/001-analyze-invocation-form/fixture').absolute.path;
  final fullFixture = Directory('${spikesDir.path}/003-riverpod-lint-severity-matrix/fixture').absolute.path;
  final Expected expectedBasic;
  final Expected expectedFull;
  try {
    expectedBasic = Expected.read(File('${spikeDir.path}/expected_001.txt'));
    expectedFull = Expected.read(File('${spikeDir.path}/expected_003.txt'));
  } on FileSystemException catch (e) {
    stderr.writeln('기대 진단 파일을 읽지 못했다: ${e.message} (${e.path})');
    exit(66);
  } on FormatException catch (e) {
    stderr.writeln('기대 진단 파일 형식이 틀렸다: ${e.message}');
    exit(65);
  }

  // 첫 실행이 쓸 상태 폴더. null 이면 기본 자리(~/.dartServer)를 쓴다.
  final home = env['HOME'] ?? env['USERPROFILE'] ?? '';
  final firstState = stateBase == null ? null : '${stateBase.path}/first';
  final firstStateRoot = Directory(firstState ?? '$home/.dartServer');
  final coldBase = stateBase?.path ??
      '${env['RUNNER_TEMP'] ?? Directory.systemTemp.path}/spike006-cold';

  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem} '
      '(${Platform.numberOfProcessors} cores)');
  stdout.writeln('GITHUB_ACTIONS=${env['GITHUB_ACTIONS']} CI=${env['CI']} '
      'DASH__SUPPRESS_ANALYTICS=${env['DASH__SUPPRESS_ANALYTICS']}');
  stdout.writeln('첫 실행 전 상태 폴더: '
      '${firstStateRoot.existsSync() ? '있음 (${firstStateRoot.path})' : '없음 (${firstStateRoot.path})'}');
  stdout.writeln('');

  final runs = <Run>[];
  final pubGet = <String, int>{};
  try {
    pubGet['basic'] = (await runPubGet(basicFixture)).inMilliseconds;
    stdout.writeln('pub get (기본 fixture): ${(pubGet['basic']! / 1000).toStringAsFixed(1)}s');

    // 1) 진짜 첫 실행: 상태 폴더도 비었고 plugin 이 기대는 패키지도 아직 받지 않았다.
    //    전역 인자를 주지 않는다 — CI 에서 dart 가 스스로 사용 통계를 끄는지 본다.
    runs.add(await runAnalyze(
      label: 'A1 첫 실행 (기본 방식)',
      fixtureDir: basicFixture,
      expected: expectedBasic,
      stateDir: firstState,
    ));
    // 2) 같은 상태 폴더로 다시 (warm)
    runs.add(await runAnalyze(
      label: 'A2 재실행 (--suppress-analytics)',
      fixtureDir: basicFixture,
      expected: expectedBasic,
      stateDir: firstState,
      globalArguments: const ['--suppress-analytics'],
    ));
    // 3) 상태 폴더만 비운 cold 를 세 번 더 (pub cache 는 채워진 상태). 기본 방식으로 돌려 255 를 센다.
    for (var n = 1; n <= 3; n++) {
      final dir = Directory('$coldBase/cold-$n');
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      dir.createSync(recursive: true);
      runs.add(await runAnalyze(
        label: 'C$n 상태 폴더만 비움 (기본 방식)',
        fixtureDir: basicFixture,
        expected: expectedBasic,
        stateDir: dir.path,
      ));
    }

    // 4) 규칙 15개짜리 fixture — 패키지 루트가 달라 plugin 을 한 번 더 준비한다.
    pubGet['full'] = (await runPubGet(fullFixture)).inMilliseconds;
    stdout.writeln('pub get (15개 fixture): ${(pubGet['full']! / 1000).toStringAsFixed(1)}s');
    runs.add(await runAnalyze(
      label: 'B1 15개 fixture 첫 실행 (--suppress-analytics)',
      fixtureDir: fullFixture,
      expected: expectedFull,
      stateDir: firstState,
      globalArguments: const ['--suppress-analytics'],
    ));
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: $e');
    exit(70);
  } on FileSystemException catch (e) {
    stderr.writeln('파일 작업 실패: ${e.message} (${e.path})');
    exit(74);
  }

  final pluginVersions = readResolvedPluginVersions(firstStateRoot);
  final crashed = runs.where((r) => r.exitCode == 255).length;
  final failed = runs.where((r) => !r.matches).toList();
  stdout.writeln('');
  stdout.writeln('riverpod_lint 실제 버전: ${pluginVersions.isEmpty ? '?' : pluginVersions.join(', ')}');
  stdout.writeln('종료 코드 255: ${runs.length}번 중 $crashed번');
  stdout.writeln('기대와 같은 실행: ${runs.length - failed.length}/${runs.length}');

  final summary = {
    'dart': Platform.version.split(' ').first,
    'os': Platform.operatingSystem,
    'cores': Platform.numberOfProcessors,
    'githubActions': env['GITHUB_ACTIONS'],
    'ci': env['CI'],
    'sample': env['SPIKE_SAMPLE'],
    'pubGetMs': pubGet,
    'riverpodLint': pluginVersions.toList(),
    'crashed255': crashed,
    'runs': [for (final r in runs) r.toJson()],
  };
  // 로그에서 한 줄로 집어낼 수 있게 표시를 붙여 찍는다.
  stdout.writeln('SPIKE006_RESULT ${jsonEncode(summary)}');

  final stepSummary = env['GITHUB_STEP_SUMMARY'];
  if (stepSummary != null && stepSummary.isNotEmpty) {
    final buffer = StringBuffer()
      ..writeln('### spike 006 — sample ${env['SPIKE_SAMPLE'] ?? '?'}')
      ..writeln()
      ..writeln('| 실행 | 결과 | exit | 시간 | 진단 | 빠진 줄 |')
      ..writeln('|---|---|---|---|---|---|');
    for (final r in runs) {
      buffer.writeln('| ${r.label} | ${r.matches ? '통과' : '실패'} | ${r.exitCode} | '
          '${(r.elapsed.inMilliseconds / 1000).toStringAsFixed(1)}s | ${r.lines.length} | ${r.missing.length} |');
    }
    try {
      File(stepSummary).writeAsStringSync(buffer.toString(), mode: FileMode.append);
    } on FileSystemException catch (e) {
      stderr.writeln('step summary 를 쓰지 못했다: ${e.message}');
    }
  }

  if (failed.isNotEmpty) exitCode = 1;
}
