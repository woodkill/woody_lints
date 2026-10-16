// spike 009 — 이름이 `analysis_options.yaml` 이 아닌 조각의 `plugins:` 가 include 로 들어오는가.
//
// 실행: fvm dart run .planning/spikes/009-preset-plugin-via-include/probe.dart <작업 폴더>
//
// 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 에 저장소의 모양을 복사하고, 배포 파일을
// 조각 셋으로 잘라 넣은 뒤 `example/` 의 샘플을 조합 넷으로 분석한다. 대조 기준은 같은 내용을
// 한 파일에 그대로 둔 모양이다 (Phase 2 의 지워 보기 M3 ~ M5 와 같은 방식).
import 'dart:io';

import 'replica.dart';

/// 옛 주소 한 줄 — 나누지 않은 기준 실행이 쓴다.
const oldUri = 'include: package:woody_lints/analysis_options.yaml\n';

/// 조합 하나: 이름, Riverpod 조각을 받는지, codegen 조각을 받는지.
typedef Combo = ({String name, bool riverpod, bool codegen});

/// 03-CONTEXT.md D-03 의 "네 경우".
const combos = <Combo>[
  (name: 'base', riverpod: false, codegen: false),
  (name: 'base+riverpod', riverpod: true, codegen: false),
  (name: 'base+codegen', riverpod: false, codegen: true),
  (name: 'all', riverpod: true, codegen: true),
];

/// [combo] 가 include 할 조각 이름.
List<String> fragmentsOf(Combo combo) =>
    ['base', if (combo.riverpod) 'riverpod', if (combo.codegen) 'codegen'];

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final checks = Checks();
  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem}');

  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final expected = Expected.read(replica.repoRoot);
    final example = '${replica.root}/example';
    stdout.writeln('배포 파일의 규칙 ${shipped.declaredRuleCount}개, 정답지 exit ${expected.exitCode} + ${expected.lines.length}줄');
    stdout.writeln('');

    replica.create();
    replica.writeLibUnsplit(shipped.original);
    replica.addFixture('example', options: oldUri);
    await replica.getPackages(example);

    stdout.writeln('# 1부. 나누지 않은 한 파일 (대조 기준). 연습용 프로젝트는 옛 주소 한 줄');
    final unsplit = <String, Run>{};
    for (final combo in combos) {
      replica.writeLibUnsplit(shipped.combined(riverpod: combo.riverpod, codegen: combo.codegen));
      final run = await replica.analyze(
        id: 'U-${combo.name}',
        title: '한 파일에 ${fragmentsOf(combo).join(' + ')} 의 내용',
        cwd: example,
      );
      unsplit[combo.name] = run;
      checks.same(
        'U-${combo.name} 이 정답지에서 셈한 예상과 같다',
        run,
        expected.predicted(riverpod: combo.riverpod, codegen: combo.codegen),
        combo.riverpod || !combo.codegen ? 2 : 0,
      );
    }
    checks.same('U-all 이 저장소의 정답지와 같다 (replica 가 저장소를 재현한다)',
        unsplit['all']!, expected.lines, expected.exitCode);

    stdout.writeln('');
    stdout.writeln('# 2부. 조각 셋으로 나눈 모양. 연습용 프로젝트가 조각을 골라 include');
    replica.writeLibSplit(shipped);
    final split = <String, Run>{};
    for (final combo in combos) {
      final names = fragmentsOf(combo);
      replica.setOptions(
        'example',
        names.length == 1
            ? 'include: package:woody_lints/${names.single}.yaml\n'
            : Replica.includeList(names),
      );
      final run = await replica.analyze(
        id: 'S-${combo.name}',
        title: 'include ${names.map((n) => '$n.yaml').join(' + ')}',
        cwd: example,
      );
      split[combo.name] = run;
      final reference = unsplit[combo.name]!;
      checks.same('S-${combo.name} 이 한 파일로 둔 같은 내용(U-${combo.name})과 같다',
          run, reference.lines, reference.exitCode);
      checks.add(
        'S-${combo.name} 의 plugin 준비 폴더가 ${combo.riverpod ? 1 : 0}개다',
        run.pluginFolders == (combo.riverpod ? 1 : 0) && !run.pluginFailed,
        '실제 ${run.pluginFolders}개${run.pluginFailed ? ', stderr 에 plugin 실패 머리말' : ''}',
      );
      checks.add(
        'S-${combo.name} 의 riverpod_lint 진단이 ${combo.riverpod ? 3 : 0}줄이다',
        run.pluginLines.length == (combo.riverpod ? 3 : 0),
        '실제 ${run.pluginLines.length}줄',
      );
    }
    checks.same('S-all 이 저장소의 정답지와 같다',
        split['all']!, expected.lines, expected.exitCode);

    stdout.writeln('');
    stdout.writeln('# 3부. 가장자리');
    final all = split['all']!;

    final warm = await replica.analyze(
      id: 'S-all-warm',
      title: 'S-all 을 같은 상태 폴더로 한 번 더 (재실행)',
      cwd: example,
      stateDir: '${replica.work}/state/S-all',
      quiet: true,
    );
    checks.same('재실행에서도 같은 진단이 나온다', warm, all.lines, all.exitCode);

    replica.setOptions('example', Replica.includeList(['codegen', 'riverpod', 'base']));
    final reordered = await replica.analyze(
      id: 'S-order',
      title: 'include 순서를 뒤집음 (codegen + riverpod + base)',
      cwd: example,
      quiet: true,
    );
    checks.same('include 순서를 뒤집어도 같다', reordered, all.lines, all.exitCode);

    replica.setOptions('example', Replica.includeList(['base']));
    final listOfOne = await replica.analyze(
      id: 'S-list-of-one',
      title: '조각 하나를 목록 문법으로 include',
      cwd: example,
      quiet: true,
    );
    checks.same('조각 하나는 한 줄 문법과 목록 문법이 같다',
        listOfOne, split['base']!.lines, split['base']!.exitCode);

    replica.setOptions('example', 'include: package:woody_lints/riverpod.yaml\n');
    final riverpodOnly = await replica.analyze(
      id: 'S-riverpod-only',
      title: 'riverpod.yaml 만 include (기본 조각 없이)',
      cwd: example,
    );
    checks.add(
      'riverpod.yaml 만 받아도 plugin 이 돈다',
      riverpodOnly.pluginLines.length == 3 && riverpodOnly.pluginFolders == 1,
      'plugin ${riverpodOnly.pluginLines.length}줄, 폴더 ${riverpodOnly.pluginFolders}개, 전체 ${riverpodOnly.lines.length}줄',
    );

    replica.setOptions('example', '');
    final none = await replica.analyze(
      id: 'S-none',
      title: '옵션 파일이 비어 있음 (대조 — plugin 이 다른 길로 들어오지 않는다)',
      cwd: example,
    );
    checks.add(
      '아무것도 include 하지 않으면 plugin 진단도 준비도 없다',
      none.pluginLines.isEmpty && none.pluginFolders == 0,
      'plugin ${none.pluginLines.length}줄, 폴더 ${none.pluginFolders}개, 전체 ${none.lines.length}줄',
    );

    checks.printSummary();
    replica.writeResults('probe', extra: {
      'declaredRules': shipped.declaredRuleCount,
      'expectedExit': expected.exitCode,
      'expectedLines': expected.lines,
      'checks': checks.toJson(),
    });
    if (!checks.allOk) exitCode = 1;
  });
}
