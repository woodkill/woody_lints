// spike 012 — 규칙과 plugin 진단을 끄는 방법이 각각 "끈 것만" 사라지게 하는가.
//
// 실행: fvm dart run .planning/spikes/012-plugin-suppression-matrix/probe.dart <작업 폴더>
//
// 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 의 `lib/` 를 나눈 모양으로 두고,
// `example/` 의 샘플에 `lib/suppress/` 와 생성 파일 하나를 더해 분석한다. 끈 자리 옆에는
// 끄지 않은 같은 위반을 두어 "꺼졌다" 가 헛통과가 아님을 본다 (03-CONTEXT.md D-04).
//
// 규칙은 `prefer_single_quotes` (info), plugin 진단은 `provider_parameters` (warning) 로 잰다.
import 'dart:io';

import '../009-preset-plugin-via-include/replica.dart';

/// 묶음 주소 한 줄.
const bundle = 'include: package:woody_lints/recommended.yaml\n';

/// 규칙 이름.
const psq = 'prefer_single_quotes';

/// plugin 진단 이름.
const pp = 'provider_parameters';

/// 연습용 프로젝트에 더하는 샘플 (경로 → 내용). 위반 자리는 고유한 글자로 찾는다.
const samples = <String, String>{
  'lib/suppress/lint_line.dart': '''
/// 한 줄 주석으로 규칙 끄기.
// ignore: prefer_single_quotes
const String lintLineOff = "a";

/// 끄지 않은 같은 위반 (대조).
const String lintLineOn = "b";
''',
  'lib/suppress/lint_file.dart': '''
// ignore_for_file: prefer_single_quotes

/// 파일 주석으로 규칙 끄기.
const String lintFileOff = "c";
''',
  'lib/suppress/plugin_line.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final lineFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 한 줄 주석으로 plugin 진단 끄기 — 접두사 있음 / 없음 / 같은 줄 끝 / 끄지 않음.
final lineConsumer = Provider<int>((ref) {
  // ignore: riverpod_lint/provider_parameters
  final a = ref.watch(lineFamily([1]));
  // ignore: provider_parameters
  final b = ref.watch(lineFamily([2]));
  final c = ref.watch(lineFamily([3])); // ignore: riverpod_lint/provider_parameters
  final d = ref.watch(lineFamily([4]));
  return a + b + c + d;
});
''',
  'lib/suppress/plugin_file_prefixed.dart': '''
// ignore_for_file: riverpod_lint/provider_parameters
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final prefixedFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 파일 주석(접두사 있음)으로 plugin 진단 끄기.
final prefixedConsumer = Provider<int>((ref) => ref.watch(prefixedFamily([5])));
''',
  'lib/suppress/plugin_file_unprefixed.dart': '''
// ignore_for_file: provider_parameters
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final unprefixedFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 파일 주석(접두사 없음)으로 plugin 진단 끄기.
final unprefixedConsumer = Provider<int>((ref) => ref.watch(unprefixedFamily([6])));
''',
  'lib/suppress/mixed_line.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final mixedFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 한 줄에 규칙 위반과 plugin 위반이 함께 있다.
final mixedConsumer = Provider<int>((ref) {
  // ignore: prefer_single_quotes, riverpod_lint/provider_parameters
  final a = ref.watch(mixedFamily(["m1"]));
  final b = ref.watch(mixedFamily(["m2"]));
  return a + b;
});
''',
  'lib/suppress/type_lint_file.dart': '''
// ignore_for_file: type=lint
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final typeLintFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 생성 코드가 흔히 다는 `type=lint` 가 plugin 진단도 끄는지.
final typeLintConsumer = Provider<int>((ref) => ref.watch(typeLintFamily(["t1"])));
''',
  'lib/suppress/type_warning_file.dart': '''
// ignore_for_file: type=warning
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final typeWarningFamily = Provider.family<int, Object?>((ref, value) => 0);

/// `type=warning` 이 plugin 진단을 끄는지 (규칙 위반은 남아야 한다).
final typeWarningConsumer = Provider<int>((ref) => ref.watch(typeWarningFamily(["t2"])));
''',
  'lib/generated/riverpod_violation.g.dart': '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generatedFamily = Provider.family<int, Object?>((ref, value) => 0);

final generatedConsumer = Provider<int>((ref) => ref.watch(generatedFamily(["g1"])));
''',
};

/// 표의 한 칸: 어느 파일의 어느 자리에서 어느 진단이 나오는지.
class Cell {
  /// [guess] 는 소스를 읽어 세운 추정이다 (참이면 "나온다").
  const Cell(this.label, this.file, this.needle, this.code, this.guess, {this.control = false});

  /// 표에 찍을 이름.
  final String label;

  /// 연습용 프로젝트 기준 경로.
  final String file;

  /// 그 줄을 찾는 고유한 글자.
  final String needle;

  /// 진단의 규칙 이름.
  final String code;

  /// 추정 — 진단이 나오는가.
  final bool guess;

  /// 끄지 않은 대조 자리인지. 대조 자리에서 진단이 나오지 않으면 그 실행은 믿을 수 없다.
  final bool control;

  /// 이 자리의 정답지 형식 줄 머리 (`경로:줄  `).
  String get head {
    final lines = samples[file]!.split('\n');
    final at = lines.indexWhere((l) => l.contains(needle));
    if (at < 0) throw FormatException('$file 에서 $needle 을 찾지 못했다');
    return '$file:${at + 1}  ';
  }

  /// [run] 에 이 자리의 진단이 있는가.
  bool reportedIn(Run run) =>
      run.lines.any((l) => l.startsWith(head) && l.endsWith('  $code'));
}

/// 주석으로 끄는 칸과 생성 파일 칸 — 묶음만 받은 실행(J0)에서 본다.
const cells = <Cell>[
  Cell('규칙 · 한 줄 `// ignore: 이름`', 'lib/suppress/lint_line.dart', '"a"', psq, false),
  Cell('  대조 (끄지 않음)', 'lib/suppress/lint_line.dart', '"b"', psq, true, control: true),
  Cell('규칙 · 파일 `// ignore_for_file: 이름`', 'lib/suppress/lint_file.dart', '"c"', psq, false),
  Cell('plugin · 한 줄 `// ignore: riverpod_lint/이름`', 'lib/suppress/plugin_line.dart', '[1]', pp, false),
  Cell('plugin · 한 줄, 접두사 없음 `// ignore: 이름`', 'lib/suppress/plugin_line.dart', '[2]', pp, true),
  Cell('plugin · 같은 줄 끝 `… // ignore: riverpod_lint/이름`', 'lib/suppress/plugin_line.dart', '[3]', pp, false),
  Cell('  대조 (끄지 않음)', 'lib/suppress/plugin_line.dart', '[4]', pp, true, control: true),
  Cell('plugin · 파일 `// ignore_for_file: riverpod_lint/이름`', 'lib/suppress/plugin_file_prefixed.dart', '[5]', pp, false),
  Cell('plugin · 파일, 접두사 없음 `// ignore_for_file: 이름`', 'lib/suppress/plugin_file_unprefixed.dart', '[6]', pp, true),
  Cell('한 주석에 둘을 함께 — 규칙 쪽', 'lib/suppress/mixed_line.dart', '"m1"', psq, false),
  Cell('한 주석에 둘을 함께 — plugin 쪽', 'lib/suppress/mixed_line.dart', '"m1"', pp, false),
  Cell('  대조 — 규칙 쪽', 'lib/suppress/mixed_line.dart', '"m2"', psq, true, control: true),
  Cell('  대조 — plugin 쪽', 'lib/suppress/mixed_line.dart', '"m2"', pp, true, control: true),
  Cell('`// ignore_for_file: type=lint` — 규칙 쪽', 'lib/suppress/type_lint_file.dart', '"t1"', psq, false),
  Cell('`// ignore_for_file: type=lint` — plugin 쪽', 'lib/suppress/type_lint_file.dart', '"t1"', pp, true),
  Cell('`// ignore_for_file: type=warning` — 규칙 쪽', 'lib/suppress/type_warning_file.dart', '"t2"', psq, true),
  Cell('`// ignore_for_file: type=warning` — plugin 쪽', 'lib/suppress/type_warning_file.dart', '"t2"', pp, false),
  Cell('생성 파일 제외(`**/*.g.dart`) — 규칙 쪽', 'lib/generated/riverpod_violation.g.dart', '"g1"', psq, false),
  Cell('생성 파일 제외(`**/*.g.dart`) — plugin 쪽', 'lib/generated/riverpod_violation.g.dart', '"g1"', pp, false),
];

/// 더한 샘플 밖의 줄만 고른다 (`example/` 의 원래 샘플이 낸 줄).
List<String> original(Run run) =>
    [for (final l in run.lines) if (!samples.keys.any((f) => l.startsWith('$f:'))) l];

/// [lines] 중 규칙 이름이 [code] 인 줄.
List<String> withCode(Iterable<String> lines, String code) =>
    [for (final l in lines) if (l.endsWith('  $code')) l];

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final checks = Checks();
  final table = <Map<String, Object?>>[];
  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem}');
  stdout.writeln('');

  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final expected = Expected.read(replica.repoRoot);
    final example = '${replica.root}/example';

    replica.create();
    replica.writeLibSplit(shipped);
    replica.addFixture('example', options: bundle);
    samples.forEach((path, body) {
      File('$example/$path')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(body);
    });
    await replica.getPackages(example);

    /// [options] 로 한 번 분석한다. 진단 줄은 늘어놓지 않는다.
    Future<Run> run(String id, String title, String options) {
      replica.setOptions('example', options);
      return replica.analyze(id: id, title: title, cwd: example, quiet: true);
    }

    /// [cell] 의 실제 결과를 표에 적고 찍는다. 추정과 다르면 `≠` 를 붙인다.
    void observe(String runId, Cell cell, Run r, {bool? guess}) {
      final actual = cell.reportedIn(r);
      final want = guess ?? cell.guess;
      table.add({
        'run': runId,
        'cell': cell.label.trim(),
        'at': '${cell.head.trim()} ${cell.code}',
        'reported': actual,
        'guess': want,
      });
      stdout.writeln('   ${actual == want ? ' ' : '≠'} ${actual ? '나옴   ' : '안 나옴'}  ${cell.label}'
          '${actual == want ? '' : '   ← 추정은 ${want ? '나옴' : '안 나옴'}'}');
    }

    stdout.writeln('# 1부. 주석으로 끄기와 생성 파일 제외 — 묶음만 받은 실행');
    final j0 = await run('J0', '묶음 한 줄 (끄는 설정 없음)', bundle);
    for (final cell in cells) {
      observe('J0', cell, j0);
    }
    checks.same('J0 더한 샘플 밖의 줄은 저장소의 정답지 그대로다',
        Run(
          id: 'J0-original',
          title: '',
          exitCode: j0.exitCode,
          elapsed: j0.elapsed,
          lines: original(j0),
          messages: const [],
          jsonOk: j0.jsonOk,
          stderrText: '',
          pluginFolders: j0.pluginFolders,
          pluginSnapshot: j0.pluginSnapshot,
          pluginVersion: j0.pluginVersion,
          pluginConstraint: j0.pluginConstraint,
        ),
        expected.lines,
        expected.exitCode);
    checks.add('J0 대조 자리(끄지 않은 위반)는 모두 나온다',
        cells.where((c) => c.control).every((c) => c.reportedIn(j0)),
        '대조 ${cells.where((c) => c.control).length}칸');

    stdout.writeln('');
    stdout.writeln('# 1부-2. 대조 — codegen 조각을 받지 않으면 생성 파일의 위반이 나오는가');
    final x2 = await run('X2', 'base.yaml + riverpod.yaml (codegen 없음)',
        Replica.includeList(['base', 'riverpod']));
    for (final cell in cells.where((c) => c.file.contains('/generated/'))) {
      observe('X2', cell, x2, guess: true);
    }
    checks.add(
      'X2 생성 파일의 위반은 제외가 없으면 규칙 · plugin 둘 다 나온다 (제외가 가린 것이 맞다)',
      cells.where((c) => c.file.contains('/generated/')).every((c) => c.reportedIn(x2)),
    );

    stdout.writeln('');
    stdout.writeln('# 2부. 프로젝트 전체에서 끄기');
    final allPsq = withCode(j0.lines, psq);
    final allPp = withCode(j0.lines, pp);
    stdout.writeln('   J0 의 $psq ${allPsq.length}줄, $pp ${allPp.length}줄, 전체 ${j0.lines.length}줄');

    final j1 = await run('J1', '규칙을 맵 문법으로 끔 (prefer_single_quotes: false)',
        '${bundle}\nlinter:\n  rules:\n    prefer_single_quotes: false\n');
    checks.same('J1 규칙을 끄면 그 규칙의 줄만 사라진다', j1,
        [for (final l in j0.lines) if (!l.endsWith('  $psq')) l], j0.exitCode);

    final j2 = await run(
        'J2',
        'plugin 진단을 끔 — version 을 다시 적음',
        '${bundle}\nplugins:\n  riverpod_lint:\n    version: ^3.1.3\n    diagnostics:\n'
            '      provider_parameters: false\n');
    checks.same('J2 version 과 함께 끄면 그 plugin 진단의 줄만 사라진다', j2,
        [for (final l in j0.lines) if (!l.endsWith('  $pp')) l], j0.exitCode);
    checks.add('J2 다른 plugin 진단은 남는다',
        withCode(j2.lines, 'missing_provider_scope').length == 1 &&
            withCode(j2.lines, 'avoid_public_notifier_properties').length == 1,
        'plugin 폴더 ${j2.pluginFolders}개, 선언 ${j2.pluginConstraint}');

    final j3 = await run(
        'J3',
        'plugin 진단을 끔 — version 을 적지 않음',
        '${bundle}\nplugins:\n  riverpod_lint:\n    diagnostics:\n'
            '      provider_parameters: false\n');
    final j3diff = diffLines(j0.lines, j3.lines);
    stdout.writeln('   J0 과의 차이 ${j3diff.length}줄, $pp ${withCode(j3.lines, pp).length}줄 남음, '
        'plugin 폴더 ${j3.pluginFolders}개');
    for (final d in j3diff.take(8)) {
      stdout.writeln('       $d');
    }
    for (var i = 0; i < j3.lines.length; i++) {
      if (j3.lines[i].startsWith('analysis_options.yaml:')) {
        stdout.writeln('       ${j3.lines[i]} — ${j3.messages[i]}');
      }
    }
    checks.add('J3 version 을 빼면 꺼지지 않는다 (조사가 임시 프로젝트에서 본 함정)',
        withCode(j3.lines, pp).length == allPp.length,
        '$pp ${withCode(j3.lines, pp).length}줄 (J0 은 ${allPp.length}줄)');

    final j4 = await run(
        'J4',
        'plugin 진단을 끔 — 묶음과 다른 version (^3.1.9) 을 적음',
        '${bundle}\nplugins:\n  riverpod_lint:\n    version: ^3.1.9\n    diagnostics:\n'
            '      provider_parameters: false\n');
    checks.same('J4 다른 version 을 적어도 꺼진다', j4,
        [for (final l in j0.lines) if (!l.endsWith('  $pp')) l], j0.exitCode);
    checks.add('J4 서버가 받은 선언은 사용 프로젝트가 적은 것이다',
        j4.pluginConstraint == '^3.1.9', '실제 ${j4.pluginConstraint}');

    stdout.writeln('');
    stdout.writeln('# 3부. 참고 — 표에 없는 다른 길');
    final e1 = await run('E1', 'analyzer.errors 에 이름만 (provider_parameters: ignore)',
        '${bundle}\nanalyzer:\n  errors:\n    provider_parameters: ignore\n');
    stdout.writeln('   $pp ${withCode(e1.lines, pp).length}줄 남음 (J0 은 ${allPp.length}줄)');
    for (var i = 0; i < e1.lines.length; i++) {
      if (e1.lines[i].startsWith('analysis_options.yaml:')) {
        stdout.writeln('       ${e1.lines[i]} — ${e1.messages[i]}');
      }
    }
    final e2 =await run('E2', 'analyzer.errors 에 접두사를 붙여 (riverpod_lint/provider_parameters: ignore)',
        '${bundle}\nanalyzer:\n  errors:\n    riverpod_lint/provider_parameters: ignore\n');
    stdout.writeln('   $pp ${withCode(e2.lines, pp).length}줄 남음 (J0 은 ${allPp.length}줄)');
    for (var i = 0; i < e2.lines.length; i++) {
      if (e2.lines[i].startsWith('analysis_options.yaml:')) {
        stdout.writeln('       ${e2.lines[i]} — ${e2.messages[i]}');
      }
    }
    final s1 = await run(
        'S1',
        'diagnostics 에 강도를 적음 (provider_parameters: info)',
        '${bundle}\nplugins:\n  riverpod_lint:\n    version: ^3.1.3\n    diagnostics:\n'
            '      provider_parameters: info\n');
    final s1pp = withCode(s1.lines, pp);
    stdout.writeln('   $pp ${s1pp.length}줄, 강도 ${s1pp.map((l) => l.split('  ')[1]).toSet().join(' / ')}');

    stdout.writeln('');
    stdout.writeln('# 4부. 사용 프로젝트 자신의 analyzer.exclude');
    final x3 = await run('X3', "묶음 + analyzer.exclude: ['lib/suppress/**']",
        "${bundle}\nanalyzer:\n  exclude:\n    - 'lib/suppress/**'\n");
    final x3suppress = x3.lines.where((l) => l.startsWith('lib/suppress/')).toList();
    final j0suppress = j0.lines.where((l) => l.startsWith('lib/suppress/')).toList();
    checks.add('X3 사용 프로젝트가 직접 적은 제외는 규칙과 plugin 이 둘 다 따른다',
        x3suppress.isEmpty && j0suppress.isNotEmpty,
        'lib/suppress/ 아래 ${x3suppress.length}줄 (J0 은 ${j0suppress.length}줄)');
    checks.add('X3 묶음에서 받은 제외와 합쳐진다 (생성 파일 샘플의 규칙 진단이 여전히 없다)',
        !x3.lines.any((l) => l.startsWith('lib/generated/sample.')));

    stdout.writeln('');
    stdout.writeln('# 5부. 예상 밖 — 묶음에서 받은 생성 파일 제외를 plugin 이 따르지 않는다. 어디에 적어야 따르는가');
    final generated = cells.where((c) => c.file.contains('/generated/')).toList();
    const ownExclude = "analyzer:\n  exclude:\n    - '**/*.g.dart'\n";

    /// 생성 파일 두 칸(규칙 쪽, plugin 쪽)을 [guessLint] / [guessPlugin] 추정과 함께 적는다.
    void observeGenerated(String id, Run r, {required bool guessLint, required bool guessPlugin}) {
      observe(id, generated[0], r, guess: guessLint);
      observe(id, generated[1], r, guess: guessPlugin);
    }

    replica.writeLibUnsplit(shipped.original);
    final gOld = await run('G-old', '나누지 않은 한 파일 (1.3.0 의 모양), 옛 주소 한 줄',
        'include: package:woody_lints/analysis_options.yaml\n');
    observeGenerated('G-old', gOld, guessLint: false, guessPlugin: true);
    checks.add('G-old 나누기 전의 구조에서도 같다 (나눠서 생긴 일이 아니다)',
        !generated[0].reportedIn(gOld) && generated[1].reportedIn(gOld));
    replica.writeLibSplit(shipped);

    final gOwn = await run(
        'G-own', '묶음 + 사용 프로젝트의 옵션 파일에 같은 제외를 직접 적음', '${bundle}\n$ownExclude');
    observeGenerated('G-own', gOwn, guessLint: false, guessPlugin: false);
    checks.add('G-own 사용 프로젝트의 옵션 파일에 직접 적으면 plugin 도 따른다',
        !generated[0].reportedIn(gOwn) && !generated[1].reportedIn(gOwn));

    File('$example/local_excludes.yaml').writeAsStringSync(ownExclude);
    final gRoot = await run(
        'G-local-root',
        'base + riverpod + 프로젝트 루트의 local_excludes.yaml 을 include',
        '${Replica.includeList(['base', 'riverpod'])}  - local_excludes.yaml\n');
    observeGenerated('G-local-root', gRoot, guessLint: false, guessPlugin: false);

    Directory('$example/config').createSync();
    File('$example/config/local_excludes.yaml').writeAsStringSync(ownExclude);
    final gSub = await run(
        'G-local-sub',
        'base + riverpod + 하위 폴더의 config/local_excludes.yaml 을 include',
        '${Replica.includeList(['base', 'riverpod'])}  - config/local_excludes.yaml\n');
    observeGenerated('G-local-sub', gSub, guessLint: false, guessPlugin: true);
    checks.add(
      'G-local-root · G-local-sub plugin 은 제외 패턴을 그것을 적은 파일의 폴더 기준으로 푼다',
      !generated[1].reportedIn(gRoot) && generated[1].reportedIn(gSub),
      '루트의 파일: ${generated[1].reportedIn(gRoot) ? '나옴' : '안 나옴'}, '
          '하위 폴더의 파일: ${generated[1].reportedIn(gSub) ? '나옴' : '안 나옴'}',
    );
    checks.add(
      'G-local-root · G-local-sub 규칙 쪽(분석 서버)은 두 경우 모두 제외한다',
      !generated[0].reportedIn(gRoot) && !generated[0].reportedIn(gSub),
    );
    File('$example/local_excludes.yaml').deleteSync();
    Directory('$example/config').deleteSync(recursive: true);

    stdout.writeln('');
    stdout.writeln('# 추정과 실제');
    final off = table.where((r) => r['reported'] != r['guess']).toList();
    stdout.writeln('${table.length}칸 중 추정과 다른 칸 ${off.length}개');
    for (final r in off) {
      stdout.writeln('  ≠ [${r['run']}] ${r['cell']} — 실제 ${r['reported'] == true ? '나옴' : '안 나옴'}');
    }

    checks.printSummary();
    replica.writeResults('probe', extra: {
      'rule': psq,
      'pluginDiagnostic': pp,
      'cells': table,
      'reference': {
        'E1 ppLeft': withCode(e1.lines, pp).length,
        'E2 ppLeft': withCode(e2.lines, pp).length,
        'S1 ppLines': s1pp,
        'J0 ppLines': allPp,
        'J0 psqLines': allPsq,
      },
      'checks': checks.toJson(),
    });
    if (!checks.allOk) exitCode = 1;
  });
}
