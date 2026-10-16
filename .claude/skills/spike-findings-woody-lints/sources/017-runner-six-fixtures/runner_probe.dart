// spike 017 · 018 — GitHub runner 에서 연습용 프로젝트 여섯을 차례로 / 동시에 돌린다.
//
// runner:  dart run .planning/spikes/017-runner-six-fixtures/runner_probe.dart <작업 폴더> <seq|par>
// 로컬:    fvm dart run .planning/spikes/017-runner-six-fixtures/runner_probe.dart <작업 폴더> <seq|par>
//
// 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 의 `lib/` 를 나눈 모양으로 두고
// 03-CONTEXT.md D-03 의 여섯 조합을 만든 뒤 한 가지 방식으로 돌린다 (spike 014 의 A 와 P).
//   seq  폴더마다 따로, 상태 폴더도 따로, 차례로 — 처음 실행과 재실행
//   par  같은 배치를 한꺼번에 띄움 — 처음 실행과 재실행
// 방식을 job 하나에 하나만 두는 까닭: runner 의 job 은 새 가상 머신이라 pub cache 가 비어 있고,
// "plugin 넷이 같은 패키지를 동시에 처음 받는" 경우는 그 job 의 첫 분석에서만 볼 수 있다.
// 로컬(014)의 동시 실행은 pub cache 가 채워진 상태였다.
import 'dart:convert';
import 'dart:io';

import '../009-preset-plugin-via-include/replica.dart';
import '../014-multi-fixture-plugin-cost/probe.dart' show Fx, bundle, overrides, secs;

/// plugin 폴더의 lock 에서 버전을 읽어 올 패키지.
const pluginPackages = ['riverpod_lint', 'analyzer', 'analysis_server_plugin'];

/// 방식 하나를 한 번 돌린 기록.
class Pass {
  /// [wall] 은 그 방식 전체의 벽시계 시간, [runs] 는 프로젝트별 실행이다.
  Pass(this.tag, this.wall, this.runs);

  /// `seq-cold` 같은 이름.
  final String tag;

  /// 처음부터 끝까지 걸린 시간.
  final Duration wall;

  /// 프로젝트별 실행 (연습용 프로젝트 목록과 같은 순서).
  final List<Run> runs;

  /// 프로젝트별 시간을 더한 값.
  Duration get sum => runs.fold(Duration.zero, (a, r) => a + r.elapsed);
}

/// 파일의 첫 `KEY=값` 줄에서 값을 읽는다. 없으면 null.
String? readKeyValue(String path, String key) {
  final file = File(path);
  if (!file.existsSync()) return null;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('$key=')) return line.substring(key.length + 1).replaceAll('"', '');
  }
  return null;
}

/// `/proc/meminfo` 의 전체 메모리(MB). Linux 가 아니면 null.
int? totalMemoryMb() {
  final file = File('/proc/meminfo');
  if (!file.existsSync()) return null;
  final match = RegExp(r'^MemTotal:\s+(\d+) kB', multiLine: true).firstMatch(file.readAsStringSync());
  return match == null ? null : int.parse(match.group(1)!) ~/ 1024;
}

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final mode = args.length > 1 ? args[1] : '';
  if (mode != 'seq' && mode != 'par') {
    stderr.writeln('둘째 인자는 seq 또는 par 다 (받은 값: "$mode")');
    exit(64);
  }
  final env = Platform.environment;
  final onGitHub = env['GITHUB_ACTIONS'] == 'true';
  final machine = <String, Object?>{
    'dart': Platform.version.split(' ').first,
    'os': Platform.operatingSystem,
    'osRelease': readKeyValue('/etc/os-release', 'PRETTY_NAME'),
    'processors': Platform.numberOfProcessors,
    'memoryMb': totalMemoryMb(),
    'githubActions': env['GITHUB_ACTIONS'],
    'imageOs': env['ImageOS'],
    'imageVersion': env['ImageVersion'],
    'label': env['SPIKE_OS_LABEL'],
    'sample': env['SPIKE_SAMPLE'],
    'mode': mode,
  };
  stdout.writeln('Dart ${machine['dart']} on ${machine['osRelease'] ?? machine['os']}, '
      '프로세서 ${machine['processors']}개, 메모리 ${machine['memoryMb'] ?? '?'}MB, '
      '이미지 ${machine['imageOs'] ?? '-'} ${machine['imageVersion'] ?? '-'}, 방식 $mode');
  stdout.writeln('');

  final checks = Checks();
  final total = Stopwatch()..start();
  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final expected = Expected.read(replica.repoRoot);
    final root = replica.root;
    final withoutPp = [for (final l in expected.lines) if (!l.endsWith('  provider_parameters')) l];
    final fixtures = <Fx>[
      Fx('example (옛 주소)', 'example', 'include: package:woody_lints/analysis_options.yaml\n',
          expected.lines, expected.exitCode, plugin: true),
      Fx('recommended', 'fixtures/recommended', bundle, expected.lines, expected.exitCode, plugin: true),
      Fx('base_only', 'fixtures/base_only', 'include: package:woody_lints/base.yaml\n',
          expected.predicted(riverpod: false, codegen: false), 2, plugin: false),
      Fx('overrides', 'fixtures/overrides', overrides, withoutPp, 2, plugin: true),
      Fx('base_riverpod', 'fixtures/base_riverpod', Replica.includeList(['base', 'riverpod']),
          expected.predicted(riverpod: true, codegen: false), 2, plugin: true),
      Fx('base_codegen', 'fixtures/base_codegen', Replica.includeList(['base', 'codegen']),
          expected.predicted(riverpod: false, codegen: true), 0, plugin: false),
    ];
    String short(Fx fx) => fx.rel.split('/').last;
    String state(String tag, Fx fx) => '${replica.work}/state/$tag-${short(fx)}';

    replica.create();
    replica.writeLibSplit(shipped);
    final prep = Stopwatch()..start();
    await replica.getPackages(root);
    final rootGetMs = prep.elapsedMilliseconds;
    stdout.writeln('# 준비. 저장소 루트의 pub get ${secs(prep.elapsed)}초');
    final pubGetMs = <String, int>{};
    for (final fx in fixtures) {
      replica.addFixture(fx.rel, options: fx.options);
      final one = Stopwatch()..start();
      await replica.getPackages('$root/${fx.rel}');
      pubGetMs[fx.name] = one.elapsedMilliseconds;
      stdout.writeln('   ${fx.name}: ${secs(one.elapsed)}초');
    }
    prep.stop();
    stdout.writeln('   준비 합계 ${secs(prep.elapsed)}초');

    /// 여섯을 한 번 돈다. [fresh] 가 참이면 상태 폴더를 비우고 시작한다 (처음 실행).
    Future<Pass> pass(String tag, String stateTag, {required bool together, required bool fresh}) async {
      if (fresh) {
        for (final fx in fixtures) {
          replica.freshState('$stateTag-${short(fx)}');
        }
      }
      Future<Run> one(Fx fx) => replica.analyze(
            id: '$tag-${short(fx)}',
            title: '${fx.name}${fx.plugin ? '' : ' (plugin 없음)'}',
            cwd: '$root/${fx.rel}',
            stateDir: state(stateTag, fx),
            quiet: true,
          );
      final wall = Stopwatch()..start();
      final runs = together
          ? await Future.wait([for (final fx in fixtures) one(fx)])
          : [for (final fx in fixtures) await one(fx)];
      wall.stop();
      for (var i = 0; i < fixtures.length; i++) {
        final fx = fixtures[i];
        final run = runs[i];
        checks.same('$tag ${fx.name} 의 진단이 예상과 같다', run, fx.want, fx.wantExit);
        // plugin 을 쓰는 프로젝트는 그 실행에서 plugin 이 준비됐어야 하고, 쓰지 않는 프로젝트는 폴더가 없어야 한다.
        final prepared = fx.plugin
            ? run.pluginFolders == 1 && run.pluginSnapshot && !run.pluginFailed
            : run.pluginFolders == 0;
        checks.add('$tag ${fx.name} 의 plugin 준비가 예상과 같다', prepared,
            'plugin 폴더 ${run.pluginFolders}개${run.pluginFailed ? ', 실패 머리말 있음' : ''}');
      }
      final result = Pass(tag, wall.elapsed, runs);
      stdout.writeln('   $tag 벽시계 ${secs(result.wall)}초 (하나씩의 합 ${secs(result.sum)}초)');
      return result;
    }

    final passes = <Pass>[];
    stdout.writeln('');
    if (mode == 'seq') {
      stdout.writeln('# seq. 차례로 — 처음 실행 (상태 폴더는 프로젝트마다 따로, 비어 있음)');
      passes.add(await pass('seq-cold', 'seq', together: false, fresh: true));
      stdout.writeln('');
      stdout.writeln('# seq. 같은 상태 폴더로 재실행');
      passes.add(await pass('seq-warm', 'seq', together: false, fresh: false));
    } else {
      stdout.writeln('# par. 여섯을 한꺼번에 — 처음 실행 (상태 폴더는 프로젝트마다 따로, 비어 있음)');
      passes.add(await pass('par-cold', 'par', together: true, fresh: true));
      stdout.writeln('');
      stdout.writeln('# par. 같은 상태 폴더로 한꺼번에 재실행');
      passes.add(await pass('par-warm', 'par', together: true, fresh: false));
    }
    total.stop();

    // plugin 쪽에서 실제로 풀린 버전 — plugin 을 쓰는 프로젝트의 상태 폴더마다 읽어 모은다.
    final versions = <String, Set<String>>{for (final p in pluginPackages) p: {}};
    for (final fx in fixtures.where((f) => f.plugin)) {
      for (final folder in Replica.pluginFolders(state(mode, fx))) {
        for (final p in pluginPackages) {
          final v = Replica.lockedVersion(folder, p);
          if (v != null) versions[p]!.add(v);
        }
      }
    }
    stdout.writeln('');
    stdout.writeln('plugin 쪽 버전: '
        '${[for (final p in pluginPackages) '$p ${versions[p]!.isEmpty ? '?' : versions[p]!.join(' / ')}'].join(', ')}');
    stdout.writeln('스크립트 전체 ${secs(total.elapsed)}초 (준비 ${secs(prep.elapsed)}초 포함)');
    checks.printSummary();

    final summary = <String, Object?>{
      ...machine,
      'rootPubGetMs': rootGetMs,
      'fixturePubGetMs': pubGetMs,
      'prepMs': prep.elapsedMilliseconds,
      'totalMs': total.elapsedMilliseconds,
      'pluginVersions': {for (final p in pluginPackages) p: versions[p]!.toList()},
      'passes': [
        for (final p in passes)
          {
            'tag': p.tag,
            'wallMs': p.wall.inMilliseconds,
            'sumMs': p.sum.inMilliseconds,
            'perFixtureMs': {
              for (var i = 0; i < fixtures.length; i++) fixtures[i].name: p.runs[i].elapsed.inMilliseconds,
            },
            'exitCodes': {for (var i = 0; i < fixtures.length; i++) fixtures[i].name: p.runs[i].exitCode},
            'lineCounts': {for (var i = 0; i < fixtures.length; i++) fixtures[i].name: p.runs[i].lines.length},
            'pluginFolders': {
              for (var i = 0; i < fixtures.length; i++) fixtures[i].name: p.runs[i].pluginFolders,
            },
            'stderrHeads': {
              for (var i = 0; i < fixtures.length; i++)
                if (p.runs[i].stderrText.isNotEmpty)
                  fixtures[i].name: p.runs[i].stderrText.split('\n').take(6).join('\n'),
            },
          },
      ],
      'checksOk': checks.allOk,
      'failed': checks.failed,
      'checkCount': checks.toJson().length,
    };
    // 로그에서 한 줄로 집어낼 수 있게 표시를 붙여 찍는다 (spike 006 의 방식).
    stdout.writeln('SPIKE017_RESULT ${jsonEncode(summary)}');

    if (!onGitHub) {
      final file = File('${replica.spikeDir}/results/local-$mode.json');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(summary)}\n');
      stdout.writeln('원본 결과: ${replica.scrub(file.path)}');
    }

    final stepSummary = env['GITHUB_STEP_SUMMARY'];
    if (stepSummary != null && stepSummary.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln('### spike 017 — ${machine['label'] ?? '?'} · $mode · sample ${machine['sample'] ?? '?'}')
        ..writeln()
        ..writeln('| 방식 | 벽시계 | 하나씩의 합 | 확인 |')
        ..writeln('|---|---|---|---|');
      for (final p in passes) {
        buffer.writeln('| ${p.tag} | ${secs(p.wall)}s | ${secs(p.sum)}s | '
            '${checks.failed.any((f) => f.startsWith('${p.tag} ')) ? '실패' : '통과'} |');
      }
      File(stepSummary).writeAsStringSync(buffer.toString(), mode: FileMode.append);
    }
    if (!checks.allOk) exitCode = 1;
  });
}
