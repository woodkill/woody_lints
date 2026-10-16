// spike 010 — 옛 주소 → 묶음 → 조각의 3단 include 에서 plugin 이 로드되는가.
//
// 실행: fvm dart run .planning/spikes/010-alias-three-level-include/probe.dart <작업 폴더>
//
// 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 의 `lib/` 를 Phase 3 이 만들 모양
// (조각 셋 + 묶음 `recommended.yaml` + 옛 주소의 한 줄짜리 별칭)으로 두고, `example/` 의
// 샘플을 옛 주소와 묶음 주소로 분석해 저장소의 정답지와 한 줄씩 견준다.
import 'dart:io';

import '../009-preset-plugin-via-include/replica.dart';

/// 옛 주소 한 줄.
const oldUri = 'include: package:woody_lints/analysis_options.yaml\n';

/// 묶음의 정식 주소 한 줄.
const bundleUri = 'include: package:woody_lints/recommended.yaml\n';

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final checks = Checks();
  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem}');

  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final expected = Expected.read(replica.repoRoot);
    final example = '${replica.root}/example';
    stdout.writeln('정답지 exit ${expected.exitCode} + ${expected.lines.length}줄');
    stdout.writeln('');

    replica.create();
    replica.writeLibSplit(shipped);
    replica.addFixture('example', options: oldUri);
    await replica.getPackages(example);

    /// [options] 로 분석해 정답지와 같고 plugin 을 한 번 준비했는지 적는다.
    Future<Run> expectSame(String id, String title, String options,
        {String? constraint, bool showLines = false}) async {
      replica.setOptions('example', options);
      final run = await replica.analyze(id: id, title: title, cwd: example, quiet: !showLines);
      checks.same('$id 이 저장소의 정답지와 같다', run, expected.lines, expected.exitCode);
      checks.add(
        '$id 이 plugin 을 한 번 준비했다',
        run.pluginFolders == 1 && run.pluginSnapshot && !run.pluginFailed,
        '폴더 ${run.pluginFolders}개, riverpod_lint ${run.pluginVersion} (선언 ${run.pluginConstraint})',
      );
      if (constraint != null) {
        checks.add('$id 의 plugin 선언이 $constraint 로 전해졌다',
            run.pluginConstraint == constraint, '실제 ${run.pluginConstraint}');
      }
      return run;
    }

    stdout.writeln('# 1부. 묶음과 별칭이 `package:` 주소로 부른다 (조사가 권한 모양)');
    stdout.writeln('lib/analysis_options.yaml:');
    stdout.write(File('${replica.root}/lib/analysis_options.yaml').readAsStringSync());
    stdout.writeln('lib/recommended.yaml:');
    stdout.write(File('${replica.root}/lib/recommended.yaml').readAsStringSync());
    final alias = await expectSame('A-alias', '옛 주소 한 줄 (3단: 별칭 → 묶음 → 조각)', oldUri,
        constraint: '^3.1.3', showLines: true);
    await expectSame('A-bundle', '묶음 주소 한 줄 (2단: 묶음 → 조각)', bundleUri,
        constraint: '^3.1.3');

    replica.setOptions('example', oldUri);
    final warm = await replica.analyze(
      id: 'A-alias-warm',
      title: 'A-alias 를 같은 상태 폴더로 한 번 더 (재실행)',
      cwd: example,
      stateDir: '${replica.work}/state/A-alias',
      quiet: true,
    );
    checks.same('옛 주소의 재실행에서도 같은 진단이 나온다', warm, alias.lines, alias.exitCode);

    stdout.writeln('');
    stdout.writeln('# 2부. 묶음과 별칭이 상대 경로로 부른다');
    replica.writeLibSplit(shipped, relative: true);
    stdout.writeln('lib/analysis_options.yaml:');
    stdout.write(File('${replica.root}/lib/analysis_options.yaml').readAsStringSync());
    stdout.writeln('lib/recommended.yaml:');
    stdout.write(File('${replica.root}/lib/recommended.yaml').readAsStringSync());
    await expectSame('R-alias', '옛 주소 한 줄, 상대 경로 3단', oldUri);
    await expectSame('R-bundle', '묶음 주소 한 줄, 상대 경로 2단', bundleUri);

    stdout.writeln('');
    stdout.writeln('# 2부-2. 섞어 쓰기 — 별칭은 상대 경로, 묶음은 `package:` 주소');
    replica.writeLibSplit(shipped, extra: {'analysis_options.yaml': 'include: recommended.yaml\n'});
    await expectSame('M-alias', '옛 주소 한 줄, 별칭만 상대 경로', oldUri);

    stdout.writeln('');
    stdout.writeln('# 3부. 깊이 — 별칭 앞에 징검다리 파일을 셋 더 둔다 (6단)');
    replica.writeLibSplit(shipped, extra: {
      'hop1.yaml': 'include: package:woody_lints/hop2.yaml\n',
      'hop2.yaml': 'include: package:woody_lints/hop3.yaml\n',
      'hop3.yaml': 'include: package:woody_lints/analysis_options.yaml\n',
    });
    await expectSame('D-six', 'hop1 → hop2 → hop3 → 별칭 → 묶음 → 조각',
        'include: package:woody_lints/hop1.yaml\n');

    stdout.writeln('');
    stdout.writeln('# 4부. 같은 파일에 두 길로 닿는다 — 옛 주소와 조각을 함께 include');
    replica.writeLibSplit(shipped);
    await expectSame(
      'P-twice',
      '옛 주소 + riverpod.yaml + base.yaml 을 목록으로',
      'include:\n'
          '  - package:woody_lints/analysis_options.yaml\n'
          '  - package:woody_lints/riverpod.yaml\n'
          '  - package:woody_lints/base.yaml\n',
    );

    stdout.writeln('');
    stdout.writeln('# 5부. plugin 하한을 올린다 (PRESET-05) — riverpod.yaml 의 선언만 ^3.1.9 로');
    replica.writeLibSplit(shipped, constraint: '^3.1.9');
    await expectSame('B-bump', '옛 주소 한 줄, riverpod_lint: ^3.1.9', oldUri, constraint: '^3.1.9');

    stdout.writeln('');
    stdout.writeln('# 6부. 대조 — 묶음에서 riverpod.yaml 을 뺀다 (별칭이 묶음을 그대로 따르는지)');
    replica.writeLibSplit(shipped, extra: {
      'recommended.yaml': Replica.includeList(['base', 'codegen']),
    });
    replica.setOptions('example', oldUri);
    final without = await replica.analyze(
      id: 'N-no-riverpod',
      title: '옛 주소 한 줄, 묶음이 base + codegen 만 부름',
      cwd: example,
      quiet: true,
    );
    checks.same('묶음에서 riverpod.yaml 을 빼면 옛 주소에서 riverpod_lint 3줄이 사라진다', without,
        expected.predicted(riverpod: false, codegen: true), 0);
    checks.add('그때는 plugin 을 준비하지 않는다', without.pluginFolders == 0,
        '폴더 ${without.pluginFolders}개');

    stdout.writeln('');
    stdout.writeln('# 7부. 대조 — 별칭이 없는 파일을 부른다 (조용히 통과하지 않는지)');
    replica.writeLibSplit(shipped, extra: {
      'analysis_options.yaml': 'include: package:woody_lints/no_such_bundle.yaml\n',
    });
    final missing = await replica.analyze(
      id: 'N-missing',
      title: '옛 주소 한 줄, 별칭이 없는 파일을 include',
      cwd: example,
    );
    for (var i = 0; i < missing.lines.length; i++) {
      stdout.writeln('       ${missing.lines[i]} — ${replica.scrub(missing.messages[i])}');
    }
    checks.add(
      '별칭의 include 가 깨지면 연습용 프로젝트의 옵션 파일에 진단이 붙는다',
      missing.lines.any((l) => l.startsWith('analysis_options.yaml:')),
      'exit ${missing.exitCode}, ${missing.lines.length}줄, plugin 폴더 ${missing.pluginFolders}개',
    );

    checks.printSummary();
    replica.writeResults('probe', extra: {
      'expectedExit': expected.exitCode,
      'expectedLines': expected.lines,
      'checks': checks.toJson(),
    });
    if (!checks.allOk) exitCode = 1;
  });
}
