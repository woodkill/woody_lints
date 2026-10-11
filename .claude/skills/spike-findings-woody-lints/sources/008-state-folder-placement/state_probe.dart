// spike 008 — Analysis Server 의 상태 폴더(plugin 을 받아 두는 곳)를 어디에 둘지 정하는 데 필요한 것을 잰다.
//
// 실행: fvm dart run .planning/spikes/008-state-folder-placement/state_probe.dart <작업 폴더> [부 ...]
//   부: placement  상태 폴더를 프로젝트 밖 / 안의 점 폴더 / 안의 평범한 폴더에 둘 때
//       hash       `.plugin_manager` 아래 폴더 이름이 어느 경로의 md5 인지 (심볼릭 링크, 한글 경로)
//       inside     그 폴더 안에 무엇이 있고, 재실행 때 어느 파일의 시각이 바뀌는지
//       contention 같은 상태 폴더를 두 `dart analyze` 가 동시에 쓸 때
//       race       처음 실행 둘을 동시에 띄우는 것만 15번 (실패한 쪽의 stderr 전문을 남긴다)
//       window     둘째의 시작을 8.5~11.5초 늦춰, 첫째가 plugin 을 쓰는 무렵에 겹치게 한다
//       corrupt    컴파일된 plugin 파일을 일부러 잘라 두고 분석한다
//       server     오래 떠 있는 Analysis Server(IDE 를 흉내 냄)와 함께 쓸 때
//   부를 주지 않으면 전부 돌린다 (약 23분).
//
// 저장소의 파일은 읽기만 한다. 연습용 프로젝트는 spike 001 의 것을 <작업 폴더> 에 복사해 쓴다.
// 상태 폴더는 모두 <작업 폴더> 아래에 두고 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 넘긴다.
// `~/.dartServer` 는 건드리지 않는다.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

/// `dart analyze` 한 번의 기록.
class Outcome {
  /// [lines] 는 정답지 형식으로 정규화한 진단 줄이다.
  Outcome({
    required this.exitCode,
    required this.elapsed,
    required this.lines,
    required this.jsonOk,
    required this.stderrHead,
    required this.stderrText,
    required this.ok,
  });

  /// 종료 코드.
  final int exitCode;

  /// 걸린 시간.
  final Duration elapsed;

  /// 정규화한 진단 줄 (정렬됨).
  final List<String> lines;

  /// stdout 이 JSON 으로 읽혔는지.
  final bool jsonOk;

  /// stderr 의 앞 두 줄 (경로를 가린 것).
  final String stderrHead;

  /// stderr 전문 (경로를 가린 것).
  final String stderrText;

  /// spike 002 가 찾은 plugin 준비 실패의 머리말이 stderr 에 있는지.
  bool get hasPluginHeader =>
      stderrText.contains('An error occurred while executing an analyzer plugin:');

  /// 기대 진단과 종료 코드가 모두 같은지.
  final bool ok;

  /// 초 단위 시간 문자열.
  String get seconds => (elapsed.inMilliseconds / 1000).toStringAsFixed(1);

  /// 한 줄 요약.
  String get summary => '${ok ? '통과' : '실패'} (exit $exitCode, ${seconds}s, '
      '${jsonOk ? '진단 ${lines.length}건' : 'JSON 없음'}'
      '${stderrHead.isEmpty ? '' : ', stderr: $stderrHead'})';

  /// 결과 파일에 쓸 map.
  Map<String, Object?> toJson() => {
        'ok': ok,
        'exitCode': exitCode,
        'elapsedMs': elapsed.inMilliseconds,
        'jsonOk': jsonOk,
        'lines': lines,
        'stderrHead': stderrHead,
        if (!ok) 'hasPluginHeader': hasPluginHeader,
        if (!ok) 'stderr': stderrText,
      };
}

/// stdout 의 JSON 을 정답지 형식 줄 목록으로 바꾼다. 읽지 못하면 null.
///
/// [bases] 중 하나로 시작하는 경로는 그 뒤만 남긴다 (심볼릭 링크로 들어간 경우 두 가지 경로가 다 올 수 있다).
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
  if (decoded is! Map<String, dynamic> || decoded['diagnostics'] is! List) return null;
  final lines = <String>[];
  for (final d in decoded['diagnostics'] as List) {
    final location = (d as Map<String, dynamic>)['location'] as Map<String, dynamic>;
    var file = location['file'] as String;
    for (final base in bases) {
      if (file.startsWith('$base/')) {
        file = file.substring(base.length + 1);
        break;
      }
    }
    final line = ((location['range'] as Map)['start'] as Map)['line'];
    lines.add('$file:$line  ${(d['severity'] as String).toLowerCase()}  ${d['code']}');
  }
  return lines..sort();
}

/// 조건이 참이 될 때까지 [limit] 동안 기다린다. 끝까지 거짓이면 false.
Future<bool> waitUntil(bool Function() test, Duration limit) async {
  final end = DateTime.now().add(limit);
  while (DateTime.now().isBefore(end)) {
    if (test()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  return test();
}

/// 실험에 쓰는 경로와 공통 동작을 맡는다.
class Probe {
  /// [work] 는 심볼릭 링크를 푼 작업 폴더다.
  Probe({
    required this.repoRoot,
    required this.sourceFixture,
    required this.work,
    required this.expected,
  });

  /// 저장소 루트의 절대 경로 (읽기만 한다).
  final String repoRoot;

  /// spike 001 의 연습용 프로젝트 경로.
  final String sourceFixture;

  /// 작업 폴더의 절대 경로.
  final String work;

  /// 연습용 프로젝트의 기대 진단.
  final Expected expected;

  /// 결과 파일에 쓸 기록.
  final record = <String, Object?>{};

  /// 결과에 남지 않도록 로컬 경로를 가린다.
  String scrub(String text) {
    final home = Platform.environment['HOME'] ?? '';
    var out = text.replaceAll(work, '<work>').replaceAll(repoRoot, '<repo>');
    if (home.isNotEmpty) out = out.replaceAll(home, '~');
    return out;
  }

  /// spike 001 의 연습용 프로젝트를 [dir] 에 복사하고 패키지를 받는다. 이미 있으면 그대로 쓴다.
  Future<String> makeFixture(String dir) async {
    if (File('$dir/.dart_tool/package_config.json').existsSync()) return dir;
    Directory('$dir/lib/src').createSync(recursive: true);
    for (final name in ['analysis_options.yaml', 'lib/main.dart', 'lib/src/counter.dart']) {
      File('$sourceFixture/$name').copySync('$dir/$name');
    }
    final pubspec = File('$sourceFixture/pubspec.yaml').readAsStringSync();
    const from = 'path: ../../../..';
    if (!pubspec.contains(from)) {
      throw const FormatException('spike 001 의 pubspec.yaml 에서 path 줄을 찾지 못했다');
    }
    File('$dir/pubspec.yaml').writeAsStringSync(pubspec.replaceAll(from, 'path: $repoRoot'));
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['pub', 'get'],
      workingDirectory: dir,
    );
    if (result.exitCode != 0) {
      stderr.writeln('pub get 실패 (${scrub(dir)}): exit ${result.exitCode}\n${scrub('${result.stderr}')}');
      exit(69);
    }
    return dir;
  }

  /// 빈 상태 폴더를 만든다.
  String freshState(String name) {
    final dir = Directory('$work/state/$name');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    return dir.path;
  }

  /// [cwd] 에서 `dart --suppress-analytics analyze --format=json` 을 한 번 돌린다.
  Future<Outcome> analyze({required String cwd, required String stateDir}) async {
    final watch = Stopwatch()..start();
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['--suppress-analytics', 'analyze', '--format=json'],
      workingDirectory: cwd,
      environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir},
    );
    watch.stop();
    final resolved = Directory(cwd).resolveSymbolicLinksSync();
    final lines = normalizeDiagnostics(result.stdout as String, {cwd, resolved}.toList());
    final actual = lines ?? const <String>[];
    final same = actual.length == expected.lines.length &&
        List.generate(actual.length, (i) => actual[i] == expected.lines[i]).every((b) => b);
    return Outcome(
      exitCode: result.exitCode,
      elapsed: watch.elapsed,
      lines: actual,
      jsonOk: lines != null,
      stderrHead: scrub((result.stderr as String).trim().split('\n').take(2).join(' / ')),
      stderrText: scrub((result.stderr as String).trim()),
      ok: lines != null && same && result.exitCode == expected.exitCode,
    );
  }

  /// 상태 폴더의 `.plugin_manager` 아래 폴더들.
  List<Directory> pluginFolders(String stateDir) {
    final manager = Directory('$stateDir/.plugin_manager');
    if (!manager.existsSync()) return const [];
    return manager.listSync().whereType<Directory>().toList();
  }

  /// plugin 폴더의 `pubspec.lock` 에서 풀린 `riverpod_lint` 버전을 읽는다. 없으면 null.
  String? readPluginVersion(Directory pluginFolder) {
    final lock = File('${pluginFolder.path}/pubspec.lock');
    if (!lock.existsSync()) return null;
    final lines = lock.readAsLinesSync();
    final start = lines.indexOf('  riverpod_lint:');
    if (start < 0) return null;
    for (final line in lines.skip(start + 1)) {
      if (!line.startsWith('    ')) break;
      final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
      if (match != null) return match.group(1);
    }
    return null;
  }

  /// python3 으로 [path] 의 md5 두 가지를 계산한다: UTF-8 바이트, UTF-16 code unit 의 아래 8비트.
  Future<(String, String)> referenceMd5(String path) async {
    const script = 'import hashlib,sys\n'
        'p=sys.argv[1]\n'
        'print(hashlib.md5(p.encode("utf-8")).hexdigest())\n'
        'u=p.encode("utf-16-le")\n'
        'print(hashlib.md5(bytes(u[i] for i in range(0,len(u),2))).hexdigest())\n';
    final result = await Process.run('python3', ['-c', script, path]);
    if (result.exitCode != 0) return ('?', '?');
    final out = (result.stdout as String).trim().split('\n');
    return (out[0], out.length > 1 ? out[1] : '?');
  }

  // ---------------------------------------------------------------- placement

  /// 상태 폴더를 세 자리에 두고 처음 실행과 재실행을 잰다.
  Future<void> runPlacement() async {
    stdout.writeln('# placement — 상태 폴더를 어디에 두는가');
    final fx = await makeFixture('$work/fx');
    final places = {
      '프로젝트 밖': '$work/state/placement-outside',
      '프로젝트 안의 점 폴더 (.dart_tool/woody_verify_state)': '$fx/.dart_tool/woody_verify_state',
      '프로젝트 안의 평범한 폴더 (verify_state)': '$fx/verify_state',
    };
    final rows = <Map<String, Object?>>[];
    stdout.writeln('| 자리 | 처음 실행 | 재실행 | 재실행 2 | plugin 폴더 수 | 읽은 버전 |');
    stdout.writeln('|---|---|---|---|---|---|');
    for (final entry in places.entries) {
      final dir = Directory(entry.value);
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      dir.createSync(recursive: true);
      final cold = await analyze(cwd: fx, stateDir: dir.path);
      final warm = await analyze(cwd: fx, stateDir: dir.path);
      final warm2 = await analyze(cwd: fx, stateDir: dir.path);
      final folders = pluginFolders(dir.path);
      final versions = folders.map(readPluginVersion).whereType<String>().toSet();
      stdout.writeln('| ${entry.key} | ${cold.summary} | ${warm.summary} | ${warm2.summary} | '
          '${folders.length} | ${versions.isEmpty ? '?' : versions.join(', ')} |');
      for (final o in [cold, warm, warm2]) {
        if (!o.ok) {
          for (final l in o.lines) {
            stdout.writeln('    $l');
          }
        }
      }
      rows.add({
        'place': entry.key,
        'cold': cold.toJson(),
        'warm': warm.toJson(),
        'warm2': warm2.toJson(),
        'pluginFolders': folders.length,
        'versions': versions.toList(),
      });
    }
    // 프로젝트 안에 만든 상태 폴더는 다음 부에 섞이지 않게 지운다.
    for (final path in ['$fx/verify_state', '$fx/.dart_tool/woody_verify_state']) {
      final dir = Directory(path);
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
    record['placement'] = rows;
    stdout.writeln('');
  }

  // --------------------------------------------------------------------- hash

  /// `.plugin_manager` 아래 폴더 이름이 어느 문자열의 md5 인지 본다.
  Future<void> runHash() async {
    stdout.writeln('# hash — plugin 폴더 이름은 무엇의 md5 인가');
    final fx = await makeFixture('$work/fx');
    final link = Link('$work/fx-link');
    if (link.existsSync()) link.deleteSync();
    link.createSync(fx);
    final korean = await makeFixture('$work/한글 폴더/fx');
    final cases = {
      '평범한 경로': fx,
      '심볼릭 링크를 거친 경로 (작업 디렉터리를 링크로 줌)': link.path,
      '한글이 든 경로': korean,
    };
    final rows = <Map<String, Object?>>[];
    var index = 0;
    for (final entry in cases.entries) {
      index++;
      final state = freshState('hash-$index');
      final outcome = await analyze(cwd: entry.value, stateDir: state);
      final names = pluginFolders(state).map((d) => d.uri.pathSegments.where((s) => s.isNotEmpty).last).toList();
      final resolved = Directory(entry.value).resolveSymbolicLinksSync();
      final (givenUtf8, givenLow) = await referenceMd5(entry.value);
      final (resolvedUtf8, resolvedLow) = await referenceMd5(resolved);
      final name = names.length == 1 ? names.single : names.join(',');
      final matches = <String>[
        if (name == givenUtf8) '준 경로의 md5(UTF-8)',
        if (name == resolvedUtf8 && resolved != entry.value) '링크를 푼 경로의 md5(UTF-8)',
        if (name == givenLow && givenLow != givenUtf8) '준 경로의 md5(code unit 아래 8비트)',
        if (name == resolvedLow && resolvedLow != resolvedUtf8 && resolved != entry.value)
          '링크를 푼 경로의 md5(code unit 아래 8비트)',
      ];
      stdout.writeln('## ${entry.key}');
      stdout.writeln('   작업 디렉터리: ${scrub(entry.value)}'
          '${resolved == entry.value ? '' : '  →  링크를 풀면 ${scrub(resolved)}'}');
      stdout.writeln('   분석: ${outcome.summary}');
      stdout.writeln('   폴더 이름: $name');
      stdout.writeln('   일치: ${matches.isEmpty ? '없음' : matches.join(', ')}');
      rows.add({
        'case': entry.key,
        'cwd': scrub(entry.value),
        'resolved': scrub(resolved),
        'outcome': outcome.toJson(),
        'folderNames': names,
        'md5': {
          'givenUtf8': givenUtf8,
          'givenLow8': givenLow,
          'resolvedUtf8': resolvedUtf8,
          'resolvedLow8': resolvedLow,
        },
        'matches': matches,
      });
    }
    record['hash'] = rows;
    stdout.writeln('');
  }

  // ------------------------------------------------------------------- inside

  /// plugin 폴더 안의 파일, 프로젝트 경로가 적힌 곳, 재실행 때 시각이 바뀌는 파일을 본다.
  Future<void> runInside() async {
    stdout.writeln('# inside — plugin 폴더 안에 무엇이 있는가');
    final fx = await makeFixture('$work/fx');
    final state = freshState('inside');
    await analyze(cwd: fx, stateDir: state);
    final folders = pluginFolders(state);
    if (folders.length != 1) {
      stdout.writeln('plugin 폴더가 ${folders.length}개다 — 이 부를 건너뛴다');
      return;
    }
    final folder = folders.single.path;
    const watched = [
      'pubspec.yaml',
      'pubspec.lock',
      '.dart_tool/package_config.json',
      'bin/plugin.dart',
      'bin/plugin.aot',
      'bin/depfile.txt',
    ];
    Map<String, DateTime?> stamp() => {
          for (final name in watched)
            name: File('$folder/$name').existsSync() ? File('$folder/$name').lastModifiedSync() : null,
        };
    final entries = Directory(folder)
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path.substring(folder.length + 1))
        .where((p) => !p.startsWith('.dart_tool/pub/') && !p.contains('/.dart_tool/'))
        .toList()
      ..sort();
    stdout.writeln('파일: ${entries.join(', ')}');

    // 프로젝트 경로가 적힌 파일이 있는가 (있으면 md5 없이도 폴더를 고를 수 있다)
    final mentions = <String, int>{};
    for (final name in watched) {
      final file = File('$folder/$name');
      if (!file.existsSync() || name.endsWith('.aot')) continue;
      final count = fx.allMatches(file.readAsStringSync()).length;
      mentions[name] = count;
    }
    stdout.writeln('프로젝트 경로가 적힌 횟수: '
        '${mentions.entries.map((e) => '${e.key}=${e.value}').join(', ')}');
    stdout.writeln('pubspec.yaml 전문:');
    for (final l in File('$folder/pubspec.yaml').readAsLinesSync()) {
      stdout.writeln('    ${scrub(l)}');
    }

    final before = stamp();
    await Future<void>.delayed(const Duration(seconds: 2));
    final warm = await analyze(cwd: fx, stateDir: state);
    final after = stamp();
    final changed = [for (final name in watched) if (before[name] != after[name]) name];
    stdout.writeln('재실행: ${warm.summary}');
    stdout.writeln('재실행으로 수정 시각이 바뀐 파일: ${changed.isEmpty ? '없음' : changed.join(', ')}');
    record['inside'] = {
      'files': entries,
      'fixturePathMentions': mentions,
      'warm': warm.toJson(),
      'modifiedByWarmRun': changed,
    };
    stdout.writeln('');
  }

  // --------------------------------------------------------------- contention

  /// 같은 상태 폴더를 두 `dart analyze` 가 함께 쓸 때를 잰다.
  Future<void> runContention() async {
    stdout.writeln('# contention — 같은 상태 폴더를 두 실행이 함께 쓸 때');
    final fx = await makeFixture('$work/fx');
    final rows = <Map<String, Object?>>[];

    Future<void> pair(String label, String stateA, String stateB, Duration offset) async {
      final first = analyze(cwd: fx, stateDir: stateA);
      final second = Future<void>.delayed(offset).then((_) => analyze(cwd: fx, stateDir: stateB));
      final a = await first;
      final b = await second;
      stdout.writeln('| $label | ${a.summary} | ${b.summary} |');
      rows.add({'label': label, 'first': a.toJson(), 'second': b.toJson()});
    }

    stdout.writeln('| 경우 | 첫째 | 둘째 |');
    stdout.writeln('|---|---|---|');
    for (var n = 1; n <= 5; n++) {
      final state = freshState('pair-cold-$n');
      await pair('처음 실행 둘을 동시에 #$n', state, state, Duration.zero);
    }
    for (final seconds in [3, 8, 12]) {
      final state = freshState('pair-stagger-$seconds');
      await pair('처음 실행, 둘째를 $seconds초 늦게', state, state, Duration(seconds: seconds));
    }
    final warmState = freshState('pair-warm');
    await analyze(cwd: fx, stateDir: warmState);
    for (var n = 1; n <= 8; n++) {
      await pair('준비된 상태에서 둘을 동시에 #$n', warmState, warmState, Duration.zero);
    }
    for (var n = 1; n <= 2; n++) {
      await pair('대조군: 상태 폴더를 따로 주고 처음 실행 둘을 동시에 #$n',
          freshState('pair-separate-$n-a'), freshState('pair-separate-$n-b'), Duration.zero);
    }
    final failed = rows.where((r) =>
        !((r['first'] as Map)['ok'] as bool) || !((r['second'] as Map)['ok'] as bool));
    stdout.writeln('');
    stdout.writeln('실패가 있은 쌍: ${failed.length}/${rows.length}');
    record['contention'] = rows;
    stdout.writeln('');
  }

  // --------------------------------------------------------------------- race

  /// 빈 상태 폴더 하나를 두 실행이 함께 쓰게 하고, 실패한 쪽의 stderr 전문을 남긴다.
  ///
  /// [offsets] 의 값마다 한 쌍을 돌린다. 값은 둘째 실행을 늦추는 시간이다.
  Future<void> _runPairs(String key, List<Duration> offsets) async {
    final fx = await makeFixture('$work/fx');
    final rows = <Map<String, Object?>>[];
    var failedRuns = 0;
    var withHeader = 0;
    for (var n = 1; n <= offsets.length; n++) {
      final offset = offsets[n - 1];
      final state = freshState('$key-$n');
      final first = analyze(cwd: fx, stateDir: state);
      final second = Future<void>.delayed(offset).then((_) => analyze(cwd: fx, stateDir: state));
      final pair = [await first, await second];
      final delay = (offset.inMilliseconds / 1000).toStringAsFixed(1);
      stdout.writeln('#$n (둘째를 $delay초 늦게)  '
          '첫째 ${pair[0].ok ? '통과' : '실패'} (exit ${pair[0].exitCode}, ${pair[0].seconds}s, '
          '진단 ${pair[0].lines.length}건)  둘째 ${pair[1].ok ? '통과' : '실패'} '
          '(exit ${pair[1].exitCode}, ${pair[1].seconds}s, 진단 ${pair[1].lines.length}건)');
      for (final o in pair.where((o) => !o.ok)) {
        failedRuns++;
        if (o.hasPluginHeader) withHeader++;
        stdout.writeln('    진단: ${o.lines.join(' | ')}');
        stdout.writeln('    spike 002 의 머리말이 stderr 에 있음: ${o.hasPluginHeader ? '예' : '아니오'}');
        for (final l in o.stderrText.split('\n').take(40)) {
          stdout.writeln('    stderr> $l');
        }
      }
      rows.add({
        'n': n,
        'offsetMs': offset.inMilliseconds,
        'first': pair[0].toJson(),
        'second': pair[1].toJson(),
      });
    }
    stdout.writeln('');
    stdout.writeln('실패한 실행: ${rows.length * 2}번 중 $failedRuns번 '
        '(그중 spike 002 의 머리말이 있은 것 $withHeader번)');
    record[key] = rows;
    stdout.writeln('');
  }

  /// 처음 실행 둘을 동시에 띄우는 것만 15번 되풀이한다.
  Future<void> runRace() async {
    stdout.writeln('# race — 빈 상태 폴더 하나를 처음 실행 둘이 동시에 쓸 때 (15번)');
    await _runPairs('race', List.filled(15, Duration.zero));
  }

  /// 첫째가 plugin 을 컴파일해 쓰는 무렵에 둘째가 그 파일을 보도록 시작 시각을 조금씩 옮긴다.
  Future<void> runWindow() async {
    stdout.writeln('# window — 첫째가 plugin.aot 을 쓰는 무렵에 둘째가 들어올 때');
    await _runPairs('window', [
      for (final ms in [8500, 9000, 9500, 10000, 10500, 11000, 11500]) ...[
        Duration(milliseconds: ms),
        Duration(milliseconds: ms),
      ],
    ]);
  }

  // ------------------------------------------------------------------ corrupt

  /// 컴파일된 plugin 파일이 잘린 채 남았을 때를 일부러 만든다 (동시 실행에서 한 번 본 실패의 재현).
  Future<void> runCorrupt() async {
    stdout.writeln('# corrupt — plugin.aot 이 잘린 채 남았을 때');
    final fx = await makeFixture('$work/fx');
    final state = freshState('corrupt');
    final prepared = await analyze(cwd: fx, stateDir: state);
    stdout.writeln('준비: ${prepared.summary}');
    final folders = pluginFolders(state);
    if (folders.length != 1) {
      stdout.writeln('plugin 폴더가 ${folders.length}개다 — 이 부를 건너뛴다');
      return;
    }
    final snapshot = File('${folders.single.path}/bin/plugin.aot');
    final originalSize = snapshot.lengthSync();
    snapshot.writeAsBytesSync(const []);
    stdout.writeln('plugin.aot 을 0바이트로 잘랐다 (원래 $originalSize바이트). depfile.txt 는 그대로 둔다.');

    void report(String label, Outcome o) {
      stdout.writeln('$label: ${o.ok ? '통과' : '실패'} (exit ${o.exitCode}, ${o.seconds}s, '
          '${o.jsonOk ? '진단 ${o.lines.length}건' : 'JSON 없음'})');
      if (o.ok) return;
      stdout.writeln('    진단: ${o.lines.join(' | ')}');
      stdout.writeln('    spike 002 의 머리말이 stderr 에 있음: ${o.hasPluginHeader ? '예' : '아니오'}');
      final lines = o.stderrText.split('\n');
      stdout.writeln('    stderr 는 ${lines.length}줄이다. 앞 12줄:');
      for (final l in lines.take(12)) {
        stdout.writeln('    stderr> $l');
      }
    }

    final broken = await analyze(cwd: fx, stateDir: state);
    report('잘린 채로 분석', broken);
    final again = await analyze(cwd: fx, stateDir: state);
    report('한 번 더', again);
    stdout.writeln('    그 뒤 plugin.aot 크기: ${snapshot.existsSync() ? '${snapshot.lengthSync()}바이트' : '없음'}');
    if (snapshot.existsSync()) snapshot.deleteSync();
    final healed = await analyze(cwd: fx, stateDir: state);
    report('plugin.aot 만 지운 뒤', healed);
    record['corrupt'] = {
      'prepared': prepared.toJson(),
      'truncated': broken.toJson(),
      'truncatedAgain': again.toJson(),
      'afterDeletingSnapshot': healed.toJson(),
    };
    stdout.writeln('');
  }

  // ------------------------------------------------------------------- server

  /// 오래 떠 있는 Analysis Server 와 상태 폴더를 함께 쓸 때를 잰다 (IDE 가 프로젝트를 열어 둔 상황).
  Future<void> runServer() async {
    stdout.writeln('# server — 오래 떠 있는 Analysis Server 와 함께 쓸 때');
    final fx = await makeFixture('$work/fx');
    final state = freshState('server');
    final process = await Process.start(
      Platform.resolvedExecutable,
      ['language-server'],
      workingDirectory: fx,
      environment: {
        'ANALYZER_STATE_LOCATION_OVERRIDE': state,
        'DASH__SUPPRESS_ANALYTICS': 'true',
      },
    );
    final received = StringBuffer();
    final outSub = process.stdout.transform(utf8.decoder).listen(received.write);
    final errSub = process.stderr.transform(utf8.decoder).listen((_) {});
    var exited = false;
    unawaited(process.exitCode.then((_) => exited = true));

    void send(Map<String, Object?> message) {
      final body = utf8.encode(jsonEncode(message));
      process.stdin.add(utf8.encode('Content-Length: ${body.length}\r\n\r\n'));
      process.stdin.add(body);
    }

    final result = <String, Object?>{};
    try {
      final uri = Uri.file(fx).toString();
      send({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {
          'processId': pid,
          'rootUri': uri,
          'capabilities': <String, Object?>{},
          'workspaceFolders': [
            {'uri': uri, 'name': 'fx'},
          ],
        },
      });
      final initialized =
          await waitUntil(() => received.toString().contains('"id":1'), const Duration(seconds: 30));
      stdout.writeln('서버가 initialize 에 답함: ${initialized ? '예' : '아니오'}');
      result['initialized'] = initialized;
      if (!initialized) return;
      send({'jsonrpc': '2.0', 'method': 'initialized', 'params': <String, Object?>{}});

      bool hasSnapshot() =>
          pluginFolders(state).any((f) => File('${f.path}/bin/plugin.aot').existsSync());
      final watch = Stopwatch()..start();
      final prepared = await waitUntil(hasSnapshot, const Duration(seconds: 120));
      stdout.writeln('서버가 plugin 을 준비함: ${prepared ? '예 (${watch.elapsed.inSeconds}초)' : '아니오'}');
      final sawPlugin = await waitUntil(
          () => received.toString().contains('missing_provider_scope'), const Duration(seconds: 60));
      stdout.writeln('서버가 plugin 진단을 보냄 (missing_provider_scope): ${sawPlugin ? '예' : '아니오'}');
      result['serverPreparedPlugin'] = prepared;
      result['serverSentPluginDiagnostic'] = sawPlugin;
      if (!prepared) return;

      // 1) 서버가 떠 있는 동안 같은 상태 폴더로 명령줄 분석을 세 번
      final during = <Outcome>[];
      for (var n = 1; n <= 3; n++) {
        final o = await analyze(cwd: fx, stateDir: state);
        during.add(o);
        stdout.writeln('서버가 떠 있는 동안의 명령줄 분석 #$n: ${o.summary}');
      }
      // 2) 명령줄 쪽이 plugin 을 다시 컴파일하게 만든다 (depfile 이 없으면 기존 snapshot 을 쓰지 않는다)
      final folder = pluginFolders(state).single.path;
      final depfile = File('$folder/bin/depfile.txt');
      final snapshot = File('$folder/bin/plugin.aot');
      final snapshotBefore = snapshot.lastModifiedSync();
      if (depfile.existsSync()) depfile.deleteSync();
      final recompile = await analyze(cwd: fx, stateDir: state);
      final recompiled = snapshot.existsSync() && snapshot.lastModifiedSync() != snapshotBefore;
      stdout.writeln('depfile 을 지운 뒤의 명령줄 분석: ${recompile.summary}'
          ' — plugin.aot 이 새로 만들어짐: ${recompiled ? '예' : '아니오'}');
      final afterRecompile = await analyze(cwd: fx, stateDir: state);
      stdout.writeln('그 뒤의 명령줄 분석: ${afterRecompile.summary}');
      stdout.writeln('그동안 서버 프로세스가 살아 있음: ${exited ? '아니오' : '예'}');

      // 3) 서버가 아직 답하는지
      send({'jsonrpc': '2.0', 'id': 2, 'method': 'shutdown'});
      final answered =
          await waitUntil(() => received.toString().contains('"id":2'), const Duration(seconds: 15));
      stdout.writeln('서버가 shutdown 요청에 답함: ${answered ? '예' : '아니오'}');
      send({'jsonrpc': '2.0', 'method': 'exit'});
      result.addAll({
        'cliWhileServerRunning': [for (final o in during) o.toJson()],
        'cliForcedRecompile': recompile.toJson(),
        'snapshotRewritten': recompiled,
        'cliAfterRecompile': afterRecompile.toJson(),
        'serverAliveAfter': !exited,
        'serverAnsweredShutdown': answered,
      });
    } finally {
      process.kill();
      await outSub.cancel();
      await errSub.cancel();
      record['server'] = result;
      stdout.writeln('');
    }
  }
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('사용법: fvm dart run state_probe.dart <작업 폴더> [placement|hash|inside|contention|race|window|corrupt|server ...]');
    exit(64);
  }
  const allParts = ['placement', 'hash', 'inside', 'contention', 'race', 'window', 'corrupt', 'server'];
  final parts = args.length > 1 ? args.skip(1).toList() : allParts;
  final unknown = parts.where((p) => !allParts.contains(p)).toList();
  if (unknown.isNotEmpty) {
    stderr.writeln('모르는 부: ${unknown.join(', ')} (쓸 수 있는 것: ${allParts.join(', ')})');
    exit(64);
  }

  final spikeDir = File.fromUri(Platform.script).parent;
  final spikesDir = spikeDir.parent;
  final repoRoot = spikesDir.parent.parent.absolute.path;
  final sourceFixture = '${spikesDir.path}/001-analyze-invocation-form/fixture';
  final Expected expected;
  try {
    expected =
        Expected.read(File('${spikesDir.path}/006-github-runner-cold-plugin/expected_001.txt'));
  } on FileSystemException catch (e) {
    stderr.writeln('기대 진단 파일을 읽지 못했다: ${e.message} (${e.path})');
    exit(66);
  } on FormatException catch (e) {
    stderr.writeln('기대 진단 파일 형식이 틀렸다: ${e.message}');
    exit(65);
  }

  final Probe probe;
  try {
    final workDir = Directory(args[0])..createSync(recursive: true);
    probe = Probe(
      repoRoot: repoRoot,
      sourceFixture: sourceFixture,
      work: workDir.resolveSymbolicLinksSync(),
      expected: expected,
    );
  } on FileSystemException catch (e) {
    stderr.writeln('작업 폴더를 만들지 못했다: ${e.message} (${e.path})');
    exit(73);
  }

  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem}');
  stdout.writeln('');
  try {
    for (final part in parts) {
      switch (part) {
        case 'placement':
          await probe.runPlacement();
        case 'hash':
          await probe.runHash();
        case 'inside':
          await probe.runInside();
        case 'contention':
          await probe.runContention();
        case 'race':
          await probe.runRace();
        case 'window':
          await probe.runWindow();
        case 'corrupt':
          await probe.runCorrupt();
        case 'server':
          await probe.runServer();
      }
    }
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

  // 일부만 다시 돌렸을 때 앞선 결과를 지우지 않도록 합쳐 쓴다.
  try {
    final resultsFile = File('${spikeDir.path}/results/state_probe.json');
    resultsFile.parent.createSync(recursive: true);
    var merged = <String, Object?>{};
    if (resultsFile.existsSync()) {
      try {
        merged = jsonDecode(resultsFile.readAsStringSync()) as Map<String, Object?>;
      } on FormatException {
        merged = {};
      }
    }
    merged
      ..['dart'] = Platform.version.split(' ').first
      ..['os'] = Platform.operatingSystem
      ..addAll(probe.record);
    resultsFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(merged)}\n');
  } on FileSystemException catch (e) {
    stderr.writeln('결과 파일을 쓰지 못했다: ${e.message}');
    exitCode = 74;
  }
}
