// spike 013 — 규칙이 `base.yaml` 로 옮겨 간 뒤의 규칙 검사 (검증 명령의 [2/4] 단계).
//
// 실행: fvm dart run .planning/spikes/013-rule-check-after-split/probe.dart <작업 폴더>
//
// 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 의 `lib/` 를 나눈 모양으로 두고,
// `tool/verify.dart` 의 규칙 검사와 같은 실행을 흉내 낸다 — 대상 파일을
// `build/woody_rule_check/` 아래에 `analysis_options.yaml` 이름으로 복사하고, replica
// 루트에서 그 폴더를 인자로 분석한다 (spike 005, 007). 실행마다 빈 상태 폴더를 준다.
import 'dart:io';

import '../009-preset-plugin-via-include/replica.dart';

/// 규칙 검사용 복사본을 두는 자리 (replica 루트 기준, `tool/verify.dart` 와 같다).
const ruleCheckDir = 'build/woody_rule_check';

/// 검증 명령이 실패로 치는 세 코드.
const ruleProblemCodes = ['deprecated_lint', 'removed_lint', 'undefined_lint'];

/// 끼워 넣을 문제 규칙 — deprecated, removed, 없는 규칙 (spike 005 가 Dart 3.13.4 에서 확인).
const problemRules = ['unnecessary_await_in_return', 'avoid_returning_null', 'no_such_rule_zz9'];

/// 규칙 목록의 마지막 줄 — 이 줄 바로 아래에 끼워 넣는다.
const lastRuleMarker = '    - control_flow_in_finally';

/// [body] 의 규칙 목록 끝에 [lines] 를 끼워 넣는다.
String insertAfterLastRule(String body, List<String> lines) {
  final at = body.indexOf(lastRuleMarker);
  if (at < 0) throw const FormatException('규칙 목록의 마지막 줄을 찾지 못했다');
  final lineEnd = body.indexOf('\n', at) + 1;
  return body.substring(0, lineEnd) + lines.map((l) => '$l\n').join() + body.substring(lineEnd);
}

/// [body] 에서 [from] 을 [to] 로 한 번 바꾼다. 없으면 [FormatException].
String swap(String body, String from, String to) {
  if (!body.contains(from)) throw FormatException('바꿀 자리를 찾지 못했다: $from');
  return body.replaceFirst(from, to);
}

/// `tool/verify.dart` 의 `countDeclaredRules` 와 같은 셈 — 최상위 `linter:` 블록의 `- 이름` 줄 수.
int countDeclaredRules(String options) {
  final rulePattern = RegExp(r'^\s*-\s*[A-Za-z0-9_]+');
  var inLinter = false;
  var count = 0;
  for (final line in options.split('\n')) {
    if (RegExp(r'^linter:').hasMatch(line)) {
      inLinter = true;
    } else if (RegExp(r'^\S').hasMatch(line)) {
      inLinter = false;
    } else if (inLinter && rulePattern.hasMatch(line)) {
      count++;
    }
  }
  return count;
}

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final checks = Checks();
  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem}');
  stdout.writeln('');

  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final root = replica.root;
    final base = shipped.baseYaml;
    final withProblems = insertAfterLastRule(base, [for (final r in problemRules) '    - $r']);
    final hiddenRules = '\nlinter:\n  rules:\n${problemRules.map((r) => '    - $r\n').join()}';

    replica.create();
    replica.writeLibSplit(shipped);
    await replica.getPackages(root);

    /// [copies] (복사본 폴더 기준 경로 → 내용)를 두고 규칙 검사와 같은 실행을 한다.
    Future<Run> ruleCheck(String id, String title, Map<String, String> copies) async {
      final dir = Directory('$root/$ruleCheckDir');
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      copies.forEach((path, body) {
        File('${dir.path}/$path')
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(body);
      });
      try {
        final run = await replica.analyze(
            id: id, title: title, cwd: root, arguments: [ruleCheckDir], quiet: true);
        for (var i = 0; i < run.lines.length; i++) {
          stdout.writeln('     ${run.lines[i]} — ${run.messages[i]}');
        }
        if (run.stderrText.isNotEmpty) {
          stdout.writeln('   stderr 전문: ${run.stderrText.replaceAll('\n', ' / ')}');
        }
        return run;
      } finally {
        Directory('$root/build').deleteSync(recursive: true);
      }
    }

    /// [run] 의 진단 중 세 코드에 드는 줄.
    List<String> problems(Run run) =>
        [for (final l in run.lines) if (ruleProblemCodes.any((c) => l.endsWith('  $c'))) l];

    stdout.writeln('# 1부. 대상이 base.yaml — plugins: 가 없어 빼는 단계 없이 그대로 복사한다');
    stdout.writeln('   base.yaml 의 규칙 수(검증 명령의 셈): ${countDeclaredRules(base)}, '
        'plugins: 가 있는가: ${base.contains(RegExp(r'^plugins:', multiLine: true))}');
    final k0 = await ruleCheck('K0', 'base.yaml 그대로', {'analysis_options.yaml': base});
    checks.add('K0 깨끗한 base.yaml 은 0건이고 plugin 을 준비하지 않는다',
        k0.jsonOk && k0.lines.isEmpty && k0.exitCode == 0 && k0.pluginFolders == 0,
        'exit ${k0.exitCode}, ${k0.lines.length}줄, plugin 폴더 ${k0.pluginFolders}개, ${k0.seconds}초');

    final k1 = await ruleCheck(
        'K1', 'base.yaml 에 문제 규칙 셋을 끼움', {'analysis_options.yaml': withProblems});
    final firstLine = withProblems.split('\n').indexOf('    - ${problemRules.first}') + 1;
    checks.same('K1 세 코드가 끼운 줄 번호 그대로 나온다', k1, [
      '$ruleCheckDir/analysis_options.yaml:$firstLine  warning  deprecated_lint',
      '$ruleCheckDir/analysis_options.yaml:${firstLine + 1}  warning  removed_lint',
      '$ruleCheckDir/analysis_options.yaml:${firstLine + 2}  warning  undefined_lint',
    ], 2);
    final lastRuleLine = base.split('\n').indexWhere((l) => l.startsWith(lastRuleMarker)) + 1;
    stdout.writeln('   lib/base.yaml 의 마지막 규칙은 $lastRuleLine행, 끼운 규칙은 복사본의 '
        '$firstLine ~ ${firstLine + 2}행 (그대로 복사하므로 줄 번호가 원본과 같다)');

    stdout.writeln('');
    stdout.writeln('# 2부. 다른 파일을 대상으로 두면');
    final k2 = await ruleCheck('K2', 'codegen.yaml 그대로', {'analysis_options.yaml': shipped.codegenYaml});
    checks.add('K2 codegen.yaml 을 대상으로 두어도 0건이고 plugin 을 준비하지 않는다',
        k2.lines.isEmpty && k2.exitCode == 0 && k2.pluginFolders == 0,
        'exit ${k2.exitCode}, ${k2.lines.length}줄, plugin 폴더 ${k2.pluginFolders}개');
    final k3 = await ruleCheck('K3', 'riverpod.yaml 그대로 (plugins: 를 담은 채)',
        {'analysis_options.yaml': shipped.riverpodYaml()});
    checks.add('K3 riverpod.yaml 을 그대로 대상으로 두면 plugin 을 준비한다 (대상으로 삼지 않을 이유)',
        k3.pluginFolders == 1,
        'exit ${k3.exitCode}, ${k3.lines.length}줄, plugin 폴더 ${k3.pluginFolders}개, ${k3.seconds}초');
    final k4 = await ruleCheck('K4', 'recommended.yaml 그대로 (조각 셋을 부르는 목록)',
        {'analysis_options.yaml': File('$root/lib/recommended.yaml').readAsStringSync()});
    stdout.writeln('   → exit ${k4.exitCode}, ${k4.lines.length}줄, plugin 폴더 ${k4.pluginFolders}개, ${k4.seconds}초');
    final k5 = await ruleCheck('K5', '별칭(lib/analysis_options.yaml) 그대로',
        {'analysis_options.yaml': File('$root/lib/analysis_options.yaml').readAsStringSync()});
    stdout.writeln('   → exit ${k5.exitCode}, ${k5.lines.length}줄, plugin 폴더 ${k5.pluginFolders}개, ${k5.seconds}초');
    checks.add('K4 · K5 묶음이나 별칭을 대상으로 두면 include 를 거쳐 plugin 까지 준비한다',
        k4.pluginFolders == 1 && k5.pluginFolders == 1,
        '묶음 ${k4.pluginFolders}개 · 별칭 ${k5.pluginFolders}개');

    stdout.writeln('');
    stdout.writeln('# 3부. 다른 조각에 숨은 규칙 — riverpod.yaml 끝에 linter: 블록과 문제 규칙 셋을 둔다');
    replica.writeLibSplit(shipped, extra: {'riverpod.yaml': shipped.riverpodYaml() + hiddenRules});
    final k6 = await ruleCheck('K6', '대상은 base.yaml 하나 (지금의 검사를 경로만 바꾼 모양)',
        {'analysis_options.yaml': base});
    checks.add('K6 base.yaml 만 보면 다른 조각에 적힌 문제 규칙은 한 건도 잡히지 않는다',
        k6.lines.isEmpty && k6.exitCode == 0, 'exit ${k6.exitCode}, ${k6.lines.length}줄');

    final strippedRiverpod = (shipped.riverpodYaml() + hiddenRules)
        .replaceAll(RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true), '');
    final k7 = await ruleCheck('K7', '조각마다 하위 폴더에 복사해 한 번에 (base/, riverpod/ — plugins: 는 뺌)', {
      'base/analysis_options.yaml': withProblems,
      'riverpod/analysis_options.yaml': strippedRiverpod,
    });
    checks.add(
      'K7 하위 폴더에 나눠 두고 한 번 돌리면 두 파일의 문제 규칙이 모두 잡힌다',
      problems(k7).where((l) => l.startsWith('$ruleCheckDir/base/')).length == 3 &&
          problems(k7).where((l) => l.startsWith('$ruleCheckDir/riverpod/')).length == 3 &&
          k7.pluginFolders == 0,
      'base/ ${problems(k7).where((l) => l.startsWith('$ruleCheckDir/base/')).length}줄, '
          'riverpod/ ${problems(k7).where((l) => l.startsWith('$ruleCheckDir/riverpod/')).length}줄, '
          'plugin 폴더 ${k7.pluginFolders}개, ${k7.seconds}초',
    );

    stdout.writeln('');
    stdout.writeln('# 3부-2. 같은 상태를 사용 프로젝트 쪽에서 보면 (정답지 비교가 잡는 것)');
    replica.addFixture('example', options: 'include: package:woody_lints/analysis_options.yaml\n');
    await replica.getPackages('$root/example');
    final expected = Expected.read(replica.repoRoot);
    final k8 = await replica.analyze(
        id: 'K8', title: 'example (옛 주소), riverpod.yaml 에 문제 규칙 셋이 숨어 있음', cwd: '$root/example', quiet: true);
    final k8diff = diffLines(expected.lines, k8.lines);
    stdout.writeln('   정답지와의 차이 ${k8diff.length}줄, exit ${k8.exitCode}');
    for (final d in k8diff) {
      final i = k8.lines.indexOf(d.substring(2));
      stdout.writeln('       $d${i < 0 ? '' : ' — ${k8.messages[i]}'}');
    }
    checks.add(
      'K8 정답지 비교는 없는 규칙만 잡고 deprecated · removed 는 놓친다',
      k8diff.length == 1 && k8diff.single.endsWith('  included_file_warning'),
      '차이 ${k8diff.length}줄',
    );
    replica.writeLibSplit(shipped);

    stdout.writeln('');
    stdout.writeln('# 4부. 깨진 입력 — 세 코드 밖의 신호로 드러나는 것');
    final broken = <String, (String, String, String)>{
      'B1': ('닫지 않은 따옴표 (깨진 YAML)', 'analysis_options.yaml', insertAfterLastRule(base, ["    - 'unclosed"])),
      'B2': ('rules: 키의 오타 (ruels:)', 'analysis_options.yaml', swap(base, '  rules:\n', '  ruels:\n')),
      'B3': ('겹친 규칙 (avoid_print 를 한 번 더)', 'analysis_options.yaml', insertAfterLastRule(base, ['    - avoid_print'])),
      'B4': ('linter: 키의 오타 (lintr:)', 'analysis_options.yaml', swap(base, '\nlinter:\n', '\nlintr:\n')),
      'B5': (
        '목록과 맵을 섞음 (규칙 하나를 `이름: false` 로)',
        'analysis_options.yaml',
        insertAfterLastRule(base, ['    prefer_single_quotes: false']),
      ),
      'B6': (
        'codegen.yaml 의 진단 코드 오타 (invalid_annotation_targett)',
        'analysis_options.yaml',
        swap(shipped.codegenYaml, 'invalid_annotation_target: ignore', 'invalid_annotation_targett: ignore'),
      ),
    };
    final signals = <String, Map<String, Object?>>{};
    for (final entry in broken.entries) {
      final (title, path, body) = entry.value;
      final run = await ruleCheck(entry.key, title, {path: body});
      if (run.exitCode == 3 && run.lines.isEmpty) {
        // JSON 에 아무것도 없는데 exit 3 이다 — 같은 입력을 기계용 출력으로 한 번 더 돌려 본다.
        final dir = Directory('$root/$ruleCheckDir')..createSync(recursive: true);
        File('${dir.path}/$path').writeAsStringSync(body);
        final machine = await Process.run(
          Platform.resolvedExecutable,
          ['--suppress-analytics', 'analyze', '--format=machine', ruleCheckDir],
          workingDirectory: root,
          environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': replica.freshState('${entry.key}-machine')},
        );
        Directory('$root/build').deleteSync(recursive: true);
        final out = replica.scrub('${machine.stdout}${machine.stderr}'.trim());
        stdout.writeln('   --format=machine 으로는 (exit ${machine.exitCode}): ${out.isEmpty ? '(출력 없음)' : out.replaceAll('\n', ' / ')}');
      }
      final counted = countDeclaredRules(body);
      final outside = [for (final l in run.lines) if (!ruleProblemCodes.any((c) => l.endsWith('  $c'))) l];
      stdout.writeln('   → exit ${run.exitCode}, JSON ${run.jsonOk ? '있음' : '없음'}, 진단 ${run.lines.length}줄 '
          '(세 코드 ${problems(run).length}, 그 밖 ${outside.length}), 검증 명령의 규칙 셈 $counted');
      signals[entry.key] = {
        'title': title,
        'exitCode': run.exitCode,
        'jsonOk': run.jsonOk,
        'lines': run.lines,
        'countDeclaredRules': counted,
      };
      final passesToday =
          run.jsonOk && [0, 2, 3].contains(run.exitCode) && problems(run).isEmpty && counted > 0;
      checks.add(
        '${entry.key} 지금의 판정(세 코드 + 규칙 0개)으로는 ${passesToday ? '통과로 찍힌다' : '실패로 잡힌다'} — $title',
        true,
        'exit ${run.exitCode}, 그 밖의 진단 ${outside.length}줄: ${outside.map((l) => l.split('  ').last).toSet().join(', ')}',
      );
    }

    checks.printSummary();
    replica.writeResults('probe', extra: {
      'problemRules': problemRules,
      'baseDeclaredRules': countDeclaredRules(base),
      'brokenInputs': signals,
      'checks': checks.toJson(),
    });
    if (!checks.allOk) exitCode = 1;
  });
}
