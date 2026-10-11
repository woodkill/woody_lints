// spike 007 — 저장소 루트에 `example/` 이 생기면 루트 분석이 어떻게 달라지는지 본다.
//
// 실행: fvm dart run .planning/spikes/007-root-analysis-with-example/probe.dart <작업 폴더>
//
// 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 에 저장소의 모양(pubspec.yaml,
// 루트 analysis_options.yaml, lib/analysis_options.yaml)을 복사하고 그 안에서 실험한다.
// `example/` 은 spike 001 의 연습용 프로젝트를 복사해 만든다.
// 실행마다 빈 상태 폴더를 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 넘겨, plugin 준비가
// 일어났는지를 `.plugin_manager` 아래 폴더 수로 본다. `~/.dartServer` 는 건드리지 않는다.
import 'dart:convert';
import 'dart:io';

/// 배포 파일에 끼워 넣을 문제 규칙 (deprecated 2, removed 1, 없는 규칙 1 — spike 005 와 같다).
const problemRules = [
  'unnecessary_await_in_return',
  'prefer_final_parameters',
  'avoid_returning_null',
  'no_such_rule_zz9',
];

/// 연습용 프로젝트가 내는 plugin(`riverpod_lint`) 진단의 규칙 이름.
const pluginCodes = ['missing_provider_scope', 'avoid_public_notifier_properties'];

/// 규칙 검사용 복사본을 두는 자리 (replica 루트 기준, spike 005 와 같다).
const ruleCheckDir = 'build/woody_rule_check';

/// `dart analyze` 한 번의 기록.
class Run {
  /// [lines] 는 replica 루트 기준 상대 경로로 정규화한 진단 줄이다.
  Run({
    required this.id,
    required this.title,
    required this.exitCode,
    required this.elapsed,
    required this.lines,
    required this.jsonOk,
    required this.stderrText,
    required this.pluginFolders,
    required this.pluginSnapshot,
  });

  /// 짧은 이름.
  final String id;

  /// 표에 찍을 설명.
  final String title;

  /// `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 걸린 시간.
  final Duration elapsed;

  /// 정답지 형식으로 정규화한 진단 줄 (정렬됨).
  final List<String> lines;

  /// stdout 이 JSON 으로 읽혔는지.
  final bool jsonOk;

  /// stderr 원문 (경로를 가린 것).
  final String stderrText;

  /// 상태 폴더의 `.plugin_manager` 아래에 생긴 폴더 수. 0 이면 plugin 을 준비하지 않았다.
  final int pluginFolders;

  /// 컴파일된 plugin(`plugin.aot`)이 생겼는지.
  final bool pluginSnapshot;

  /// `example/` 아래 파일에 대한 진단.
  List<String> get exampleLines => lines.where((l) => l.startsWith('example/')).toList();

  /// plugin 진단.
  List<String> get pluginLines =>
      lines.where((l) => pluginCodes.any((c) => l.endsWith('  $c'))).toList();

  /// 규칙 검사용 복사본에 대한 진단.
  List<String> get ruleCheckLines => lines.where((l) => l.startsWith('$ruleCheckDir/')).toList();

  /// 그 밖의 진단.
  List<String> get otherLines => lines
      .where((l) => !l.startsWith('example/') && !l.startsWith('$ruleCheckDir/'))
      .toList();

  /// 결과 파일에 쓸 map.
  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'exitCode': exitCode,
        'elapsedMs': elapsed.inMilliseconds,
        'jsonOk': jsonOk,
        'pluginFolders': pluginFolders,
        'pluginSnapshot': pluginSnapshot,
        'lines': lines,
        'stderr': stderrText,
      };
}

/// stdout 의 JSON 을 정답지 형식 줄 목록으로 바꾼다. 읽지 못하면 null.
List<String>? normalizeDiagnostics(String stdoutText, String baseDir) {
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
  final prefix = '$baseDir/';
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

/// 배포 파일 내용에 문제 규칙 4개를 끼워 넣는다.
String injectProblemRules(String shipped) {
  const marker = '    - control_flow_in_finally';
  final at = shipped.indexOf(marker);
  if (at < 0) throw const FormatException('배포 파일에서 끼워 넣을 자리를 찾지 못했다');
  final lineEnd = shipped.indexOf('\n', at) + 1;
  final extra = problemRules.map((r) => '    - $r\n').join();
  return shipped.substring(0, lineEnd) + extra + shipped.substring(lineEnd);
}

/// 옵션 파일 내용에서 최상위 `plugins:` 섹션을 뺀다 (spike 005 의 python3 패턴을 Dart 로 옮긴 것).
String stripPlugins(String options) {
  final stripped =
      options.replaceAll(RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true), '');
  if (stripped == options) throw const FormatException('plugins: 섹션을 찾지 못했다');
  return stripped;
}

/// replica 를 만들고 고치고 분석하는 일을 맡는다.
class Probe {
  /// [repoRoot] 는 읽기만 한다. [work] 아래에 모든 것을 만든다.
  Probe({required this.repoRoot, required this.fixture, required this.work});

  /// 저장소 루트의 절대 경로.
  final String repoRoot;

  /// spike 001 의 연습용 프로젝트 경로.
  final String fixture;

  /// 작업 폴더의 절대 경로 (심볼릭 링크를 푼 것).
  final String work;

  /// 지금까지의 실행 기록.
  final runs = <Run>[];

  /// 저장소의 모양을 복사한 폴더.
  String get replica => '$work/replica';

  /// replica 안의 `example/`.
  String get example => '$replica/example';

  /// 결과에 남지 않도록 로컬 경로를 가린다.
  String scrub(String text) {
    final home = Platform.environment['HOME'] ?? '';
    var out = text
        .replaceAll(replica, '<replica>')
        .replaceAll(work, '<work>')
        .replaceAll(repoRoot, '<repo>');
    if (home.isNotEmpty) out = out.replaceAll(home, '~');
    return out;
  }

  /// 저장소의 `pubspec.yaml`, 루트 옵션 파일, 배포 파일을 replica 로 복사한다.
  void createReplica() {
    final dir = Directory(replica);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    Directory('$replica/lib').createSync(recursive: true);
    for (final name in ['pubspec.yaml', 'analysis_options.yaml', 'lib/analysis_options.yaml']) {
      File('$repoRoot/$name').copySync('$replica/$name');
    }
  }

  /// spike 001 의 연습용 프로젝트를 `example/` 로 복사한다. 의존성 경로만 `..` 로 바꾼다.
  void addExample() {
    Directory('$example/lib/src').createSync(recursive: true);
    for (final name in ['analysis_options.yaml', 'lib/main.dart', 'lib/src/counter.dart']) {
      File('$fixture/$name').copySync('$example/$name');
    }
    final pubspec = File('$fixture/pubspec.yaml').readAsStringSync();
    const from = 'path: ../../../..';
    if (!pubspec.contains(from)) {
      throw const FormatException('spike 001 의 pubspec.yaml 에서 path 줄을 찾지 못했다');
    }
    File('$example/pubspec.yaml').writeAsStringSync(pubspec.replaceAll(from, 'path: ..'));
  }

  /// `example/` 에서 받은 패키지를 지워 `pub get` 전 상태로 돌린다.
  void removeExamplePackages() {
    final tool = Directory('$example/.dart_tool');
    if (tool.existsSync()) tool.deleteSync(recursive: true);
    final lock = File('$example/pubspec.lock');
    if (lock.existsSync()) lock.deleteSync();
  }

  /// replica 의 루트 옵션 파일을 "저장소의 원본 + [globs] 제외"로 다시 쓴다.
  void setRootExcludes(List<String> globs) {
    final original = File('$repoRoot/analysis_options.yaml').readAsStringSync();
    if (!original.endsWith('    - lib/analysis_options.yaml\n')) {
      throw const FormatException('루트 옵션 파일의 끝이 예상한 exclude 항목이 아니다');
    }
    File('$replica/analysis_options.yaml')
        .writeAsStringSync(original + globs.map((g) => "    - '$g'\n").join());
  }

  /// 규칙 검사용 복사본(`plugins:` 를 뺀 배포 파일)을 쓴다.
  void writeRuleCopy({required bool withProblems}) {
    final shipped = File('$repoRoot/lib/analysis_options.yaml').readAsStringSync();
    final body = stripPlugins(withProblems ? injectProblemRules(shipped) : shipped);
    Directory('$replica/$ruleCheckDir').createSync(recursive: true);
    File('$replica/$ruleCheckDir/analysis_options.yaml').writeAsStringSync(body);
  }

  /// 규칙 검사용 복사본을 지운다.
  void removeRuleCopy() {
    final build = Directory('$replica/build');
    if (build.existsSync()) build.deleteSync(recursive: true);
  }

  /// [dir] 에서 `dart pub get` 을 돌린다. 실패하면 프로그램을 끝낸다.
  Future<void> getPackages(String dir) async {
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['pub', 'get'],
      workingDirectory: dir,
    );
    if (result.exitCode != 0) {
      stderr.writeln('pub get 실패 (${scrub(dir)}): exit ${result.exitCode}\n${scrub('${result.stderr}')}');
      exit(69);
    }
  }

  /// [cwd] 에서 `dart --suppress-analytics analyze --format=json [arguments]` 를 한 번 돌린다.
  Future<Run> analyze({
    required String id,
    required String title,
    required String cwd,
    List<String> arguments = const [],
  }) async {
    final state = Directory('$work/state/$id');
    if (state.existsSync()) state.deleteSync(recursive: true);
    state.createSync(recursive: true);

    final watch = Stopwatch()..start();
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['--suppress-analytics', 'analyze', '--format=json', ...arguments],
      workingDirectory: cwd,
      environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path},
    );
    watch.stop();

    final manager = Directory('${state.path}/.plugin_manager');
    final folders = manager.existsSync() ? manager.listSync().whereType<Directory>().toList() : const <Directory>[];
    final lines = normalizeDiagnostics(result.stdout as String, replica);
    final run = Run(
      id: id,
      title: title,
      exitCode: result.exitCode,
      elapsed: watch.elapsed,
      lines: lines ?? const [],
      jsonOk: lines != null,
      stderrText: scrub((result.stderr as String).trim()),
      pluginFolders: folders.length,
      pluginSnapshot: folders.any((f) => File('${f.path}/bin/plugin.aot').existsSync()),
    );
    runs.add(run);
    _printRun(run);
    return run;
  }

  void _printRun(Run run) {
    final seconds = (run.elapsed.inMilliseconds / 1000).toStringAsFixed(1);
    stdout.writeln('## ${run.id} — ${run.title}');
    stdout.writeln('   exit ${run.exitCode}, ${seconds}s, '
        '진단 ${run.jsonOk ? '${run.lines.length}건' : 'JSON 없음'} '
        '(example ${run.exampleLines.length}, 그중 plugin ${run.pluginLines.length}, '
        '규칙 검사 ${run.ruleCheckLines.length}, 그 밖 ${run.otherLines.length}), '
        'plugin 준비 폴더 ${run.pluginFolders}개${run.pluginSnapshot ? ' (plugin.aot 있음)' : ''}');
    for (final l in run.lines) {
      stdout.writeln('     $l');
    }
    if (run.stderrText.isNotEmpty) {
      stdout.writeln('   stderr: ${run.stderrText.split('\n').take(3).join(' / ')}');
    }
  }
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('사용법: fvm dart run probe.dart <작업 폴더>');
    exit(64);
  }
  final spikeDir = File.fromUri(Platform.script).parent;
  final repoRoot = spikeDir.parent.parent.parent.absolute.path;
  final fixture = '${spikeDir.parent.path}/001-analyze-invocation-form/fixture';
  if (!File('$fixture/pubspec.yaml').existsSync()) {
    stderr.writeln('spike 001 의 연습용 프로젝트를 찾지 못했다: $fixture');
    exit(66);
  }

  final Probe probe;
  try {
    final workDir = Directory(args[0])..createSync(recursive: true);
    probe = Probe(
      repoRoot: repoRoot,
      fixture: fixture,
      work: workDir.resolveSymbolicLinksSync(),
    );
  } on FileSystemException catch (e) {
    stderr.writeln('작업 폴더를 만들지 못했다: ${e.message} (${e.path})');
    exit(73);
  }

  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem}');
  stdout.writeln('');

  try {
    // 0) example 이 없는 지금의 모양
    probe.createReplica();
    await probe.getPackages(probe.replica);
    stdout.writeln('# 1부. 루트에서 인자 없이 (커밋 전 린터와 같은 실행)');
    await probe.analyze(id: 'A0', title: 'example 없음 (지금의 저장소)', cwd: probe.replica);

    // 1) example 을 두되 아직 패키지를 받지 않았다 (새로 받은 저장소의 모양)
    probe.addExample();
    await probe.analyze(id: 'A1', title: 'example 있음, pub get 전, 루트 제외 없음', cwd: probe.replica);
    probe.setRootExcludes(['example/**']);
    await probe.analyze(
        id: 'A4', title: "example 있음, pub get 전, 루트에 'example/**' 제외", cwd: probe.replica);
    probe.setRootExcludes([]);

    // 2) example 에서 패키지를 받았다
    await probe.getPackages(probe.example);
    await probe.analyze(id: 'A2', title: 'example 있음, pub get 후, 루트 제외 없음', cwd: probe.replica);
    probe.setRootExcludes(['example/**']);
    await probe.analyze(
        id: 'A3', title: "example 있음, pub get 후, 루트에 'example/**' 제외", cwd: probe.replica);
    probe.setRootExcludes(['example']);
    await probe.analyze(
        id: 'A5', title: "example 있음, pub get 후, 루트에 'example' 제외", cwd: probe.replica);
    probe.setRootExcludes(['example', 'example/**']);
    await probe.analyze(
        id: 'A6',
        title: "example 있음, pub get 후, 루트에 'example' 과 'example/**' 제외",
        cwd: probe.replica);

    stdout.writeln('');
    stdout.writeln('# 2부. example 안에서 인자 없이 (검증 명령이 하는 실행)');
    probe.setRootExcludes([]);
    await probe.analyze(id: 'E2', title: '루트 제외 없음', cwd: probe.example);
    probe.setRootExcludes(['example/**']);
    await probe.analyze(id: 'E3', title: "루트에 'example/**' 제외", cwd: probe.example);
    probe.setRootExcludes(['example', 'example/**']);
    await probe.analyze(id: 'E6', title: "루트에 'example' 과 'example/**' 제외", cwd: probe.example);

    stdout.writeln('');
    stdout.writeln('# 2부-2. 루트에서 example 을 인자로 (채택하지 않은 형태. 루트 제외가 이 형태를 막는지 본다)');
    probe.setRootExcludes([]);
    await probe.analyze(id: 'H2', title: '루트 제외 없음', cwd: probe.replica, arguments: ['example']);
    probe.setRootExcludes(['example/**']);
    await probe.analyze(
        id: 'H3', title: "루트에 'example/**' 제외", cwd: probe.replica, arguments: ['example']);

    stdout.writeln('');
    stdout.writeln('# 3부. 규칙 검사 (문제 규칙 4개를 끼우고 plugins: 를 뺀 복사본을 $ruleCheckDir/ 에 둔다)');
    probe.writeRuleCopy(withProblems: true);
    probe.setRootExcludes([]);
    await probe.analyze(id: 'R2a', title: '루트 제외 없음, 루트에서 인자 없이', cwd: probe.replica);
    await probe.analyze(
        id: 'R2b', title: '루트 제외 없음, 루트에서 그 폴더를 인자로', cwd: probe.replica, arguments: [ruleCheckDir]);
    probe.setRootExcludes(['example/**']);
    await probe.analyze(id: 'R3a', title: "루트에 'example/**' 제외, 루트에서 인자 없이", cwd: probe.replica);
    await probe.analyze(
        id: 'R3b',
        title: "루트에 'example/**' 제외, 루트에서 그 폴더를 인자로",
        cwd: probe.replica,
        arguments: [ruleCheckDir]);

    stdout.writeln('');
    stdout.writeln('# 4부. 문제 없는 복사본 (검증이 통과할 때의 모양)');
    probe.writeRuleCopy(withProblems: false);
    probe.setRootExcludes([]);
    await probe.analyze(
        id: 'P2b', title: '루트 제외 없음, 루트에서 그 폴더를 인자로', cwd: probe.replica, arguments: [ruleCheckDir]);
    probe.setRootExcludes(['example/**']);
    await probe.analyze(id: 'P3a', title: "루트에 'example/**' 제외, 루트에서 인자 없이", cwd: probe.replica);
    probe.removeRuleCopy();

    final resultsFile = File('${spikeDir.path}/results/probe.json');
    resultsFile.parent.createSync(recursive: true);
    resultsFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert({
          'dart': Platform.version.split(' ').first,
          'os': Platform.operatingSystem,
          'runs': [for (final r in probe.runs) r.toJson()],
        })}\n');
    stdout.writeln('');
    stdout.writeln('원본 결과: .planning/spikes/007-root-analysis-with-example/results/probe.json');
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    exitCode = 65;
  } on FileSystemException catch (e) {
    stderr.writeln('파일 작업 실패: ${e.message} (${probe.scrub(e.path ?? '')})');
    exitCode = 74;
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: ${probe.scrub('$e')}');
    exitCode = 70;
  }
}
