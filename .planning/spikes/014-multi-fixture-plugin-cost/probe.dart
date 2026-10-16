// spike 014 — 연습용 프로젝트가 여섯일 때 분석에 드는 시간과, 배치 방식에 따른 차이.
//
// 실행: fvm dart run .planning/spikes/014-multi-fixture-plugin-cost/probe.dart <작업 폴더>
//
// 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 의 `lib/` 를 나눈 모양으로 두고
// 03-CONTEXT.md D-03 의 여섯 조합을 만든 뒤 네 가지 방식으로 돌린다.
//   A  폴더마다 따로 두고 상태 폴더도 따로 (지금 검증 명령의 방식을 여섯으로 늘린 것)
//   A' 폴더마다 따로 두되 상태 폴더는 하나를 함께 씀
//   P  A 를 동시에 띄움
//   B  작업 폴더 하나에서 옵션 파일만 바꿔 가며 (상태 폴더 하나)
// 방식마다 진단이 예상과 같은지도 함께 본다 — 빨라도 결과가 틀리면 쓸 수 없다.
import 'dart:io';

import '../009-preset-plugin-via-include/replica.dart';

/// 묶음 주소 한 줄.
const bundle = 'include: package:woody_lints/recommended.yaml\n';

/// 끄는 설정용 옵션 — 묶음 + plugin 진단 하나를 끔.
const overrides = '$bundle\n'
    'plugins:\n'
    '  riverpod_lint:\n'
    '    version: ^3.1.3\n'
    '    diagnostics:\n'
    '      provider_parameters: false\n';

/// 연습용 프로젝트 하나.
class Fx {
  /// [want] 와 [wantExit] 는 이 조합이 내야 하는 진단과 종료 코드다.
  Fx(this.name, this.rel, this.options, this.want, this.wantExit, {required this.plugin});

  /// 표에 찍을 이름.
  final String name;

  /// replica 루트 기준 폴더.
  final String rel;

  /// 옵션 파일 내용.
  final String options;

  /// 내야 하는 진단 줄.
  final List<String> want;

  /// 내야 하는 종료 코드.
  final int wantExit;

  /// plugin 을 쓰는 조합인지.
  final bool plugin;
}

/// 초(소수 한 자리).
String secs(Duration d) => (d.inMilliseconds / 1000).toStringAsFixed(1);

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final checks = Checks();
  final timings = <String, Map<String, Object?>>{};
  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem}, '
      '프로세서 ${Platform.numberOfProcessors}개');
  stdout.writeln('');

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

    replica.create();
    replica.writeLibSplit(shipped);
    await replica.getPackages(root);

    stdout.writeln('# 준비. 연습용 프로젝트 여섯의 pub get (pub cache 는 채워진 상태)');
    final getWatch = Stopwatch()..start();
    for (final fx in fixtures) {
      replica.addFixture(fx.rel, options: fx.options);
      final one = Stopwatch()..start();
      await replica.getPackages('$root/${fx.rel}');
      stdout.writeln('   ${fx.name}: ${secs(one.elapsed)}초');
    }
    getWatch.stop();
    stdout.writeln('   합계 ${secs(getWatch.elapsed)}초');
    timings['pubGet'] = {'totalMs': getWatch.elapsedMilliseconds};

    /// [fxs] 를 차례로 돌린다. 상태 폴더는 [stateOf] 가 정한다. 걸린 시간의 합을 돌려준다.
    Future<Duration> sequential(String tag, List<Fx> fxs, String Function(Fx) stateOf,
        {String Function(Fx)? cwdOf, void Function(Fx)? before}) async {
      var total = Duration.zero;
      final per = <String, int>{};
      for (final fx in fxs) {
        before?.call(fx);
        final run = await replica.analyze(
          id: '$tag-${fx.rel.split('/').last}',
          title: '${fx.name}${fx.plugin ? '' : ' (plugin 없음)'}',
          cwd: cwdOf?.call(fx) ?? '$root/${fx.rel}',
          stateDir: stateOf(fx),
          quiet: true,
        );
        checks.same('$tag ${fx.name} 의 진단이 예상과 같다', run, fx.want, fx.wantExit);
        total += run.elapsed;
        per[fx.name] = run.elapsed.inMilliseconds;
      }
      stdout.writeln('   $tag 합계 ${secs(total)}초');
      timings[tag] = {'totalMs': total.inMilliseconds, 'perFixtureMs': per};
      return total;
    }

    /// 이름이 [name] 인 상태 폴더의 경로 (지우지 않는다).
    String state(String name) => '${replica.work}/state/$name';

    stdout.writeln('');
    stdout.writeln('# A. 폴더마다 따로, 상태 폴더도 따로 — 처음 실행');
    for (final fx in fixtures) {
      replica.freshState('A-${fx.rel.split('/').last}');
    }
    final aCold = await sequential('A-cold', fixtures, (fx) => state('A-${fx.rel.split('/').last}'));
    stdout.writeln('');
    stdout.writeln('# A. 같은 상태 폴더로 재실행');
    final aWarm = await sequential('A-warm', fixtures, (fx) => state('A-${fx.rel.split('/').last}'));

    stdout.writeln('');
    stdout.writeln("# A'. 폴더마다 따로, 상태 폴더는 하나를 함께 — 처음 실행");
    replica.freshState('shared');
    final sCold = await sequential('S-cold', fixtures, (_) => state('shared'));
    final sharedFolders = Replica.pluginFolders(state('shared')).length;
    stdout.writeln('   함께 쓴 상태 폴더의 plugin 폴더 ${sharedFolders}개');
    stdout.writeln('');
    stdout.writeln("# A'. 재실행");
    final sWarm = await sequential('S-warm', fixtures, (_) => state('shared'));
    checks.add("A' 상태 폴더를 함께 쓰면 plugin 폴더가 plugin 을 쓰는 프로젝트 수만큼 생긴다",
        sharedFolders == fixtures.where((f) => f.plugin).length, '실제 ${sharedFolders}개');

    stdout.writeln('');
    stdout.writeln('# P. A 를 동시에 — plugin 을 쓰는 넷, 처음 실행 (상태 폴더는 따로)');
    Future<Duration> parallel(String tag, List<Fx> fxs) async {
      for (final fx in fxs) {
        replica.freshState('$tag-${fx.rel.split('/').last}');
      }
      final wall = Stopwatch()..start();
      final runs = await Future.wait([
        for (final fx in fxs)
          replica.analyze(
            id: '$tag-${fx.rel.split('/').last}',
            title: fx.name,
            cwd: '$root/${fx.rel}',
            stateDir: state('$tag-${fx.rel.split('/').last}'),
            quiet: true,
          ),
      ]);
      wall.stop();
      for (var i = 0; i < fxs.length; i++) {
        checks.same('$tag ${fxs[i].name} 의 진단이 예상과 같다', runs[i], fxs[i].want, fxs[i].wantExit);
      }
      stdout.writeln('   $tag 벽시계 ${secs(wall.elapsed)}초 '
          '(하나씩의 합 ${secs(runs.fold(Duration.zero, (a, r) => a + r.elapsed))}초)');
      timings[tag] = {
        'wallMs': wall.elapsedMilliseconds,
        'perFixtureMs': {for (var i = 0; i < fxs.length; i++) fxs[i].name: runs[i].elapsed.inMilliseconds},
      };
      return wall.elapsed;
    }

    final p4 = await parallel('P4-cold', fixtures.where((f) => f.plugin).toList());
    stdout.writeln('');
    stdout.writeln('# P. 여섯을 모두 동시에, 처음 실행');
    final p6 = await parallel('P6-cold', fixtures);

    stdout.writeln('');
    stdout.writeln('# B. 작업 폴더 하나에서 옵션 파일만 바꿔 가며 (상태 폴더 하나) — 처음 실행');
    replica.addFixture('fixtures/work', options: bundle);
    await replica.getPackages('$root/fixtures/work');
    replica.freshState('B');
    final bCold = await sequential('B-cold', fixtures, (_) => state('B'),
        cwdOf: (_) => '$root/fixtures/work',
        before: (fx) => replica.setOptions('fixtures/work', fx.options));
    final workFolders = Replica.pluginFolders(state('B')).length;
    stdout.writeln('   상태 폴더의 plugin 폴더 ${workFolders}개');
    stdout.writeln('');
    stdout.writeln('# B. 재실행');
    final bWarm = await sequential('B-warm', fixtures, (_) => state('B'),
        cwdOf: (_) => '$root/fixtures/work',
        before: (fx) => replica.setOptions('fixtures/work', fx.options));
    checks.add('B 작업 폴더 하나를 돌려 쓰면 plugin 폴더가 하나다', workFolders == 1, '실제 ${workFolders}개');

    stdout.writeln('');
    stdout.writeln('# C. 샘플을 복사하지 않고 lib/ 를 example/lib 로 가는 링크로 둔다');
    replica.addFixture('fixtures/linked', options: bundle);
    Directory('$root/fixtures/linked/lib').deleteSync(recursive: true);
    Link('$root/fixtures/linked/lib').createSync('../../example/lib');
    await replica.getPackages('$root/fixtures/linked');
    final linked = await replica.analyze(
        id: 'C-linked', title: 'lib 가 심볼릭 링크', cwd: '$root/fixtures/linked', quiet: true);
    for (final l in linked.lines.take(3)) {
      stdout.writeln('     ${replica.scrub(l)}');
    }
    final linkedSame = diffLines(expected.lines, linked.lines).isEmpty;
    stdout.writeln('   정답지와 ${linkedSame ? '같다' : '다르다'} — exit ${linked.exitCode}, ${linked.lines.length}줄, '
        'plugin ${linked.pluginLines.length}줄');
    timings['C-linked'] = {'sameAsExpected': linkedSame, 'firstLines': linked.lines.take(3).map(replica.scrub).toList()};

    stdout.writeln('');
    stdout.writeln('# 시간 요약 (로컬, 초)');
    stdout.writeln('pub get 여섯           ${secs(getWatch.elapsed)}');
    stdout.writeln('A  폴더 · 상태 따로    처음 ${secs(aCold)} / 재실행 ${secs(aWarm)}');
    stdout.writeln("A' 상태 폴더 함께      처음 ${secs(sCold)} / 재실행 ${secs(sWarm)}");
    stdout.writeln('P  동시에              plugin 넷 ${secs(p4)} / 여섯 ${secs(p6)} (벽시계, 처음)');
    stdout.writeln('B  작업 폴더 하나      처음 ${secs(bCold)} / 재실행 ${secs(bWarm)}');

    checks.printSummary();
    replica.writeResults('probe', extra: {
      'processors': Platform.numberOfProcessors,
      'timings': timings,
      'checks': checks.toJson(),
    });
    if (!checks.allOk) exitCode = 1;
  });
}
