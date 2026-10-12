// spike 015 — 나눈 구조를 `path:` 가 아니라 git 의존성으로 받아도 plugin 이 로드되는가.
//
// 실행: fvm dart run .planning/spikes/015-git-dependency-preset-load/probe.dart <작업 폴더>
//
// 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 를 **로컬 git 저장소**로 만들어 커밋하고,
// replica 밖에 둔 사용 프로젝트(<작업 폴더>/consumer-git)가 그 저장소를 `git:` 의존성으로 받는다.
// GitHub 에는 아무것도 올리지 않는다. 받은 패키지는 <작업 폴더>/pub-cache 에 놓인다
// (`PUB_CACHE` 를 따로 줘서 `~/.pub-cache` 의 git 폴더를 건드리지 않는다).
import 'dart:convert';
import 'dart:io';

import '../009-preset-plugin-via-include/replica.dart';

/// 옛 주소 한 줄.
const oldUri = 'include: package:woody_lints/analysis_options.yaml\n';

/// 묶음의 정식 주소 한 줄.
const bundleUri = 'include: package:woody_lints/recommended.yaml\n';

/// 사용 프로젝트가 직접 적는 생성 파일 제외.
const ownExclude = "analyzer:\n  exclude:\n    - '**/*.g.dart'\n";

/// 생성 파일 샘플의 자리.
const generatedSample = 'lib/generated/riverpod_violation.g.dart';

/// 생성 파일 샘플 — 한 줄에 규칙 위반(`prefer_single_quotes`)과 plugin 위반
/// (`provider_parameters`)을 함께 둔다. spike 012 가 쓴 것과 같다.
const generatedBody = '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generatedFamily = Provider.family<int, Object?>((ref, value) => 0);

final generatedConsumer = Provider<int>((ref) => ref.watch(generatedFamily(["g1"])));
''';

/// replica 밖에 둔 사용 프로젝트. `woody_lints` 를 받는 방식만 바꿔 가며 쓴다.
class Consumer {
  /// [name] 은 작업 폴더 아래의 폴더 이름이다.
  Consumer(this.replica, this.name);

  /// 작업 폴더와 저장소 자리를 아는 replica.
  final Replica replica;

  /// 폴더 이름.
  final String name;

  /// 이 프로젝트의 절대 경로.
  String get dir => '${replica.work}/$name';

  /// 실험용 pub cache. `~/.pub-cache` 대신 쓴다.
  String get pubCache => '${replica.work}/pub-cache';

  /// 저장소 `example/` 의 샘플과 lock 을 복사하고 `woody_lints` 를 [dependency] 로 받게 한다.
  void create(String dependency) {
    final target = Directory(dir);
    if (target.existsSync()) target.deleteSync(recursive: true);
    final source = Directory('${replica.repoRoot}/example/lib');
    for (final f in source.listSync(recursive: true).whereType<File>()) {
      final copy = File('$dir/lib${f.path.substring(source.path.length)}');
      copy.parent.createSync(recursive: true);
      f.copySync(copy.path);
    }
    File('${replica.repoRoot}/example/pubspec.lock').copySync('$dir/pubspec.lock');
    setDependency(dependency);
  }

  /// `pubspec.yaml` 의 `woody_lints:` 아래를 [dependency] (들여쓰기 4칸의 줄들)로 다시 쓴다.
  void setDependency(String dependency) {
    final pubspec = File('${replica.repoRoot}/example/pubspec.yaml').readAsStringSync();
    const from = '    path: ..\n';
    if (!pubspec.contains(from)) {
      throw const FormatException('example 의 pubspec.yaml 에서 path 줄을 찾지 못했다');
    }
    File('$dir/pubspec.yaml').writeAsStringSync(pubspec.replaceAll(from, dependency));
  }

  /// 옵션 파일을 [body] 로 다시 쓴다.
  void setOptions(String body) => File('$dir/analysis_options.yaml').writeAsStringSync(body);

  /// 생성 파일 샘플을 둔다.
  void addGeneratedSample() {
    final file = File('$dir/$generatedSample');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(generatedBody);
  }

  /// 이 프로젝트에서 `dart pub [args]` 를 실험용 pub cache 로 돌린다.
  Future<ProcessResult> pub(List<String> args) => Process.run(
        Platform.resolvedExecutable,
        ['pub', ...args],
        workingDirectory: dir,
        environment: {'PUB_CACHE': pubCache},
      );

  /// `pubspec.lock` 의 `woody_lints` 항목 (키 → 값). 없으면 빈 map.
  Map<String, String> lockEntry() {
    final lines = File('$dir/pubspec.lock').readAsLinesSync();
    final start = lines.indexOf('  woody_lints:');
    final out = <String, String>{};
    if (start < 0) return out;
    for (final line in lines.skip(start + 1)) {
      if (!line.startsWith('    ')) break;
      final match = RegExp(r'^\s+([a-z-]+): "?([^"]*)"?$').firstMatch(line);
      if (match != null && match.group(2)!.isNotEmpty) out[match.group(1)!] = match.group(2)!;
    }
    return out;
  }

  /// `.dart_tool/package_config.json` 에 적힌 `woody_lints` 의 자리. 없으면 null.
  String? packageRoot() {
    final file = File('$dir/.dart_tool/package_config.json');
    if (!file.existsSync()) return null;
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic> || decoded['packages'] is! List) return null;
    for (final p in decoded['packages'] as List) {
      if (p is Map<String, dynamic> && p['name'] == 'woody_lints') return p['rootUri'] as String?;
    }
    return null;
  }
}

/// replica 에서 `git [args]` 를 돌리고 stdout 을 돌려준다. 실패하면 프로그램을 끝낸다 (69).
///
/// 사용자의 git 설정(서명, hook)에 기대지 않도록 전역 설정을 끄고, 커밋의 이름과 시각을 고정한다.
Future<String> git(Replica replica, List<String> args) async {
  final result = await Process.run('git', args, workingDirectory: replica.root, environment: {
    'GIT_CONFIG_GLOBAL': '/dev/null',
    'GIT_CONFIG_NOSYSTEM': '1',
    'GIT_AUTHOR_NAME': 'spike',
    'GIT_AUTHOR_EMAIL': 'spike@example.invalid',
    'GIT_COMMITTER_NAME': 'spike',
    'GIT_COMMITTER_EMAIL': 'spike@example.invalid',
    'GIT_AUTHOR_DATE': '2026-10-12T00:00:00Z',
    'GIT_COMMITTER_DATE': '2026-10-12T00:00:00Z',
  });
  if (result.exitCode != 0) {
    stderr.writeln('git ${args.join(' ')} 실패: exit ${result.exitCode}\n'
        '${replica.scrub('${result.stderr}')}');
    exit(69);
  }
  return (result.stdout as String).trim();
}

/// replica 의 지금 내용을 모두 커밋하고 그 커밋의 해시를 돌려준다.
Future<String> commit(Replica replica, String message) async {
  await git(replica, ['add', '-A']);
  await git(replica, ['commit', '-q', '-m', message]);
  return git(replica, ['rev-parse', 'HEAD']);
}

/// [lines] 에 생성 파일 샘플의 [code] 진단이 있는가.
bool reported(List<String> lines, String code) =>
    lines.any((l) => l.startsWith('$generatedSample:') && l.endsWith('  $code'));

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final checks = Checks();
  final pubLog = <Map<String, Object?>>[];
  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem}');

  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final expected = Expected.read(replica.repoRoot);
    final viaGit = Consumer(replica, 'consumer-git');
    final viaPath = Consumer(replica, 'consumer-path');
    stdout.writeln('정답지 exit ${expected.exitCode} + ${expected.lines.length}줄');
    stdout.writeln('');

    final cache = Directory(viaGit.pubCache);
    if (cache.existsSync()) cache.deleteSync(recursive: true);

    /// [consumer] 에서 pub 을 돌려 화면과 기록에 남긴다.
    Future<ProcessResult> pub(Consumer consumer, String id, List<String> pubArgs) async {
      final watch = Stopwatch()..start();
      final result = await consumer.pub(pubArgs);
      watch.stop();
      final entry = consumer.lockEntry();
      final seconds = (watch.elapsedMilliseconds / 1000).toStringAsFixed(1);
      stdout.writeln('## $id — ${consumer.name}: dart pub ${pubArgs.join(' ')}');
      stdout.writeln('   exit ${result.exitCode}, ${seconds}s, lock: source ${entry['source']}, '
          'ref ${entry['ref'] ?? '-'}, resolved-ref ${entry['resolved-ref'] ?? '-'}');
      final err = replica.scrub('${result.stderr}'.trim());
      if (result.exitCode != 0 && err.isNotEmpty) {
        stdout.writeln('   stderr: ${err.split('\n').take(6).join(' / ')}');
      }
      pubLog.add({
        'id': id,
        'consumer': consumer.name,
        'args': pubArgs,
        'exitCode': result.exitCode,
        'elapsedMs': watch.elapsedMilliseconds,
        'lock': {for (final e in entry.entries) e.key: replica.scrub(e.value)},
        'packageRoot': replica.scrub(consumer.packageRoot() ?? ''),
        'stdout': replica.scrub('${result.stdout}'.trim()),
        'stderr': err,
      });
      return result;
    }

    /// git 의존성 선언 — [ref] 를 따른다.
    String gitDependency(String ref) =>
        '    git:\n      url: ${replica.root}\n      ref: $ref\n';

    /// [consumer] 를 [options] 로 분석해 [want] / [wantExit] 와 견준다.
    Future<Run> expectLines(Consumer consumer, String id, String title, String options,
        List<String> want, int wantExit,
        {required int pluginFolders, bool showLines = false}) async {
      consumer.setOptions(options);
      final run =
          await replica.analyze(id: id, title: title, cwd: consumer.dir, quiet: !showLines);
      checks.same('$id 의 진단이 기대와 같다', run, want, wantExit);
      checks.add(
        pluginFolders == 1 ? '$id 이 plugin 을 한 번 준비했다' : '$id 은 plugin 을 준비하지 않았다',
        run.pluginFolders == pluginFolders &&
            (pluginFolders == 0 || run.pluginSnapshot) &&
            !run.pluginFailed,
        pluginFolders == 0
            ? '폴더 ${run.pluginFolders}개'
            : '폴더 ${run.pluginFolders}개, riverpod_lint ${run.pluginVersion} (선언 ${run.pluginConstraint})',
      );
      return run;
    }

    stdout.writeln('# 1부. 기준 — git 의존성 + 한 파일 구조 (사용 프로젝트가 지금 받는 모양)');
    replica.create();
    replica.writeLibUnsplit(shipped.original);
    await git(replica, ['init', '-q', '-b', 'main']);
    final shaA = await commit(replica, 'A: 한 파일 구조');
    stdout.writeln('커밋 A (한 파일 구조): $shaA');
    viaGit.create(gitDependency('main'));
    final firstGet = await pub(viaGit, 'pub-1', ['get', '--no-example']);
    if (firstGet.exitCode != 0) {
      stderr.writeln('git 의존성의 pub get 이 실패했다 — 아래 실험을 할 수 없다.');
      exitCode = 69;
      return;
    }
    final rootA = viaGit.packageRoot() ?? '';
    stdout.writeln('   woody_lints 의 자리: ${replica.scrub(rootA)}');
    checks.add('git 의존성으로 받은 패키지가 pub cache 의 git 폴더에 놓였다',
        rootA.contains('${viaGit.pubCache}/git/'), replica.scrub(rootA));
    checks.add(
      'lock 이 git 출처와 커밋 A 를 가리킨다',
      viaGit.lockEntry()['source'] == 'git' && viaGit.lockEntry()['resolved-ref'] == shaA,
      'source ${viaGit.lockEntry()['source']}, resolved-ref ${viaGit.lockEntry()['resolved-ref']}',
    );
    await expectLines(viaGit, 'G-old', 'git 의존성, 한 파일 구조, 옛 주소 한 줄', oldUri,
        expected.lines, expected.exitCode,
        pluginFolders: 1, showLines: true);

    stdout.writeln('');
    stdout.writeln('# 2부. main 이 나눈 구조로 나아간다 — 받는 쪽의 lock 은 언제 따라가는가');
    replica.writeLibSplit(shipped);
    final shaB = await commit(replica, 'B: 나눈 구조');
    stdout.writeln('커밋 B (나눈 구조): $shaB');
    await pub(viaGit, 'pub-2', ['get', '--no-example']);
    checks.add('main 이 나아가도 pub get 은 lock 의 커밋(A)에 머문다',
        viaGit.lockEntry()['resolved-ref'] == shaA, 'resolved-ref ${viaGit.lockEntry()['resolved-ref']}');
    final enforceStale = await pub(viaGit, 'pub-3', ['get', '--no-example', '--enforce-lockfile']);
    checks.add('그때의 --enforce-lockfile 은 통과한다 (lock 이 여전히 맞는 풀이다)',
        enforceStale.exitCode == 0, 'exit ${enforceStale.exitCode}');
    await pub(viaGit, 'pub-4', ['upgrade', 'woody_lints', '--no-example']);
    final rootB = viaGit.packageRoot() ?? '';
    checks.add('pub upgrade woody_lints 가 커밋 B 로 옮긴다',
        viaGit.lockEntry()['resolved-ref'] == shaB && rootB != rootA,
        'resolved-ref ${viaGit.lockEntry()['resolved-ref']}, 자리 ${replica.scrub(rootB)}');

    stdout.writeln('');
    stdout.writeln('# 3부. git 의존성 + 나눈 구조');
    final gAlias = await expectLines(viaGit, 'G-alias',
        'git 의존성, 옛 주소 한 줄 (3단: 별칭 → 묶음 → 조각)', oldUri,
        expected.lines, expected.exitCode,
        pluginFolders: 1, showLines: true);
    checks.add('G-alias 의 plugin 선언이 ^3.1.3 으로 전해졌다',
        gAlias.pluginConstraint == '^3.1.3', '실제 ${gAlias.pluginConstraint}');
    await expectLines(viaGit, 'G-bundle', 'git 의존성, 묶음 주소 한 줄', bundleUri,
        expected.lines, expected.exitCode,
        pluginFolders: 1);
    await expectLines(
        viaGit,
        'G-base-riverpod',
        'git 의존성, base.yaml + riverpod.yaml',
        Replica.includeList(['base', 'riverpod']),
        expected.predicted(riverpod: true, codegen: false),
        2,
        pluginFolders: 1);
    await expectLines(viaGit, 'G-base-only', 'git 의존성, base.yaml 만',
        Replica.includeList(['base']), expected.predicted(riverpod: false, codegen: false), 2,
        pluginFolders: 0);
    final pluginFolder = Replica.pluginFolders('${replica.work}/state/G-bundle');
    final pluginAnalyzer =
        pluginFolder.length == 1 ? Replica.lockedVersion(pluginFolder.single, 'analyzer') : null;
    final pluginServer = pluginFolder.length == 1
        ? Replica.lockedVersion(pluginFolder.single, 'analysis_server_plugin')
        : null;
    stdout.writeln('plugin 쪽에서 풀린 analyzer $pluginAnalyzer / analysis_server_plugin $pluginServer');

    stdout.writeln('');
    stdout.writeln('# 4부. 대조 — `ref:` 를 바꾸면 그 ref 의 내용을 받는다');
    await git(replica, ['checkout', '-q', '-b', 'no-riverpod']);
    replica.writeLibSplit(shipped, extra: {
      'recommended.yaml': Replica.includeList(['base', 'codegen']),
    });
    final shaC = await commit(replica, 'C: 묶음에서 riverpod.yaml 을 뺀다');
    await git(replica, ['checkout', '-q', 'main']);
    // 릴리스 tag 와 같은 annotated tag 로 만든다 — tag 자신의 해시가 커밋의 해시와 다르다.
    await git(replica, ['tag', '-a', 'v9.9.9', '-m', '릴리스 tag 흉내', shaB]);
    final tagObject = await git(replica, ['rev-parse', 'v9.9.9']);
    stdout.writeln('커밋 C (브랜치 no-riverpod): $shaC, annotated tag v9.9.9 ($tagObject) → B');
    viaGit.setDependency(gitDependency('no-riverpod'));
    final enforceChanged =
        await pub(viaGit, 'pub-5', ['get', '--no-example', '--enforce-lockfile']);
    checks.add('`ref:` 만 고친 직후의 --enforce-lockfile 은 실패한다',
        enforceChanged.exitCode != 0, 'exit ${enforceChanged.exitCode}');
    await pub(viaGit, 'pub-6', ['get', '--no-example']);
    checks.add('`ref:` 를 고치고 pub get 을 하면 그 ref 의 커밋(C)으로 옮긴다',
        viaGit.lockEntry()['resolved-ref'] == shaC, 'resolved-ref ${viaGit.lockEntry()['resolved-ref']}');
    await expectLines(viaGit, 'N-ref', 'git 의존성, ref: no-riverpod, 옛 주소 한 줄', oldUri,
        expected.predicted(riverpod: false, codegen: true), 0,
        pluginFolders: 0);
    viaGit.setDependency(gitDependency('v9.9.9'));
    await pub(viaGit, 'pub-7', ['get', '--no-example']);
    checks.add(
      '`ref:` 에 tag 를 적고 pub get 을 하면 그 tag 의 커밋(B)으로 옮긴다',
      viaGit.lockEntry()['resolved-ref'] == shaB && viaGit.packageRoot() == rootB,
      'resolved-ref ${viaGit.lockEntry()['resolved-ref']}',
    );
    viaGit.setDependency(gitDependency('main'));
    await pub(viaGit, 'pub-8', ['get', '--no-example']);

    stdout.writeln('');
    stdout.writeln('# 5부. 생성 파일 제외 — git 과 path 를 나란히');
    viaPath.create('    path: ../replica\n');
    final pathGet = await pub(viaPath, 'pub-9', ['get', '--no-example']);
    if (pathGet.exitCode != 0) {
      stderr.writeln('path 의존성의 pub get 이 실패했다 — 5부를 할 수 없다.');
      exitCode = 69;
      return;
    }
    stdout.writeln('   woody_lints 의 자리: ${replica.scrub(viaPath.packageRoot() ?? '')}');
    await expectLines(viaPath, 'P-alias', 'path 의존성, 옛 주소 한 줄 (같은 스크립트의 대조)', oldUri,
        expected.lines, expected.exitCode,
        pluginFolders: 1);
    viaGit.addGeneratedSample();
    viaPath.addGeneratedSample();
    final variants = <(String, String, String)>[
      ('none', '제외 없음 (base.yaml + riverpod.yaml)', Replica.includeList(['base', 'riverpod'])),
      ('bundle', '패키지의 codegen.yaml (묶음으로 받음)', bundleUri),
      ('own', '묶음 + 사용 프로젝트의 옵션 파일에 직접', '$bundleUri$ownExclude'),
    ];
    final table = <Map<String, Object?>>[];
    for (final (key, title, options) in variants) {
      final runs = <String, Run>{};
      for (final (mode, consumer, state) in [
        ('git', viaGit, 'G-bundle'),
        ('path', viaPath, 'P-alias'),
      ]) {
        consumer.setOptions(options);
        runs[mode] = await replica.analyze(
          id: 'X-$key-$mode',
          title: '$mode 의존성, $title',
          cwd: consumer.dir,
          stateDir: '${replica.work}/state/$state',
          quiet: true,
        );
      }
      final viaGitRun = runs['git']!;
      final viaPathRun = runs['path']!;
      final diff = diffLines(viaPathRun.lines, viaGitRun.lines);
      checks.add('X-$key 의 git 실행이 path 실행과 한 줄도 다르지 않다',
          diff.isEmpty && viaGitRun.exitCode == viaPathRun.exitCode && viaGitRun.jsonOk,
          '${viaGitRun.lines.length}줄, exit ${viaGitRun.exitCode} / ${viaPathRun.exitCode}');
      for (final d in diff) {
        stdout.writeln('       $d');
      }
      String cell(Run run, String code) => reported(run.lines, code) ? '나옴' : '안 나옴';
      table.add({
        'variant': key,
        'title': title,
        'git': {
          'rule': cell(viaGitRun, 'prefer_single_quotes'),
          'plugin': cell(viaGitRun, 'provider_parameters'),
        },
        'path': {
          'rule': cell(viaPathRun, 'prefer_single_quotes'),
          'plugin': cell(viaPathRun, 'provider_parameters'),
        },
      });
    }
    stdout.writeln('');
    stdout.writeln('| `**/*.g.dart` 제외를 적은 곳 | git: 규칙 | git: plugin | path: 규칙 | path: plugin |');
    stdout.writeln('|---|---|---|---|---|');
    for (final row in table) {
      final g = row['git']! as Map<String, String>;
      final p = row['path']! as Map<String, String>;
      stdout.writeln(
          '| ${row['title']} | ${g['rule']} | ${g['plugin']} | ${p['rule']} | ${p['plugin']} |');
    }
    Map<String, String> gitCells(String key) =>
        table.firstWhere((r) => r['variant'] == key)['git']! as Map<String, String>;
    checks.add('제외가 없으면 생성 파일 샘플의 규칙 · plugin 진단이 둘 다 나온다 (대조)',
        gitCells('none')['rule'] == '나옴' && gitCells('none')['plugin'] == '나옴');
    checks.add('사용 프로젝트가 직접 적은 제외는 git 의존성에서도 둘 다 막는다',
        gitCells('own')['rule'] == '안 나옴' && gitCells('own')['plugin'] == '안 나옴');
    checks.add(
      'pub cache 에 놓인 codegen.yaml 의 제외는 규칙 진단만 막는다 (spike 012 의 path 결과와 같다)',
      gitCells('bundle')['rule'] == '안 나옴' && gitCells('bundle')['plugin'] == '나옴',
      '규칙 ${gitCells('bundle')['rule']}, plugin ${gitCells('bundle')['plugin']}',
    );

    final cacheGit = Directory('${viaGit.pubCache}/git');
    final cacheFolders = cacheGit.existsSync()
        ? (cacheGit.listSync().whereType<Directory>().map((d) => d.path.split('/').last).toList()
          ..sort())
        : <String>[];
    stdout.writeln('');
    stdout.writeln('pub cache 의 git 폴더: ${cacheFolders.join(', ')}');

    checks.printSummary();
    replica.writeResults('probe', extra: {
      'expectedExit': expected.exitCode,
      'expectedLines': expected.lines,
      'commits': {'A': shaA, 'B': shaB, 'C': shaC},
      'pluginAnalyzer': pluginAnalyzer,
      'pluginServer': pluginServer,
      'pubCacheGitFolders': cacheFolders,
      'pub': pubLog,
      'generatedTable': table,
      'checks': checks.toJson(),
    });
    if (!checks.allOk) exitCode = 1;
  });
}
