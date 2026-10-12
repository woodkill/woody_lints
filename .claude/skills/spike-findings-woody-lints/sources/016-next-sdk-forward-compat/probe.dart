// spike 016 — 다음 SDK (Flutter 베타) 에서 프리셋 구조가 지금과 같은 동작을 하는가.
//
// 같은 스크립트를 SDK 둘로 돌려 견준다. **저장소 밖**을 작업 디렉터리로 두고 스크립트의 절대
// 경로를 준다 — 저장소 루트에서 `dart run` 을 하면 그 SDK 가 루트의 패키지를 다시 풀 수 있다.
//
//   cd <저장소 밖의 폴더>
//   <저장소>/.fvm/flutter_sdk/bin/cache/dart-sdk/bin/dart <이 파일의 절대 경로> <작업 폴더 1>   # 기준
//   ~/fvm/versions/<베타>/bin/cache/dart-sdk/bin/dart <이 파일의 절대 경로> <작업 폴더 2>       # 베타
//
// 저장소의 파일은 읽기만 한다. 칸마다 "기준 SDK (Dart 3.13.4) 에서의 값" 을 적어 두고 실제와
// 견줘 `=` / `≠` 로 찍는다. 기준 SDK 에서 `≠` 가 나오면 스크립트나 세상이 달라진 것이고,
// 베타에서 `≠` 가 나오면 그것이 이 spike 가 찾는 것이다. 결과는 `results/probe-<Dart 버전>.json`.
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
/// (`provider_parameters`)을 함께 둔다. spike 012 · 015 가 쓴 것과 같다.
const generatedBody = '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generatedFamily = Provider.family<int, Object?>((ref, value) => 0);

final generatedConsumer = Provider<int>((ref) => ref.watch(generatedFamily(["g1"])));
''';

/// 규칙 검사용 복사본을 두는 자리 (replica 루트 기준, `tool/verify.dart` 와 같다).
const ruleCheckDir = 'build/woody_rule_check';

/// 끼워 넣을 문제 규칙 — Dart 3.13.4 에서 deprecated, removed, 없는 규칙 (spike 005 · 013).
const problemRules = ['unnecessary_await_in_return', 'avoid_returning_null', 'no_such_rule_zz9'];

/// 규칙 목록의 마지막 줄 — 이 줄 바로 아래에 끼워 넣는다.
const lastRuleMarker = '    - control_flow_in_finally';

/// 저장소 `pubspec.yaml` 의 SDK 하한 줄.
const sdkLine = '  sdk: ^3.13.0\n';

/// 기준 SDK 에서 plugin 쪽에 풀린 버전 (2026-10-12, spike 012 · 015).
const baselinePluginVersions = 'riverpod_lint 3.1.9 / analyzer 14.5.0 / analysis_server_plugin 0.3.24';

/// [body] 의 규칙 목록 끝에 [lines] 를 끼워 넣는다.
String insertAfterLastRule(String body, List<String> lines) {
  final at = body.indexOf(lastRuleMarker);
  if (at < 0) throw const FormatException('규칙 목록의 마지막 줄을 찾지 못했다');
  final lineEnd = body.indexOf('\n', at) + 1;
  return body.substring(0, lineEnd) + lines.map((l) => '$l\n').join() + body.substring(lineEnd);
}

/// 칸마다 "기준 SDK 에서의 값" 과 실제를 모아 끝에 표로 찍는다. 판정(통과 · 실패)이 아니다.
class Observations {
  final _items = <(String, String, String)>[];

  /// [label] 칸의 기준값 [baseline] 과 실제 [actual] 을 적는다.
  void add(String label, String baseline, String actual) {
    _items.add((label, baseline, actual));
    stdout.writeln('   ${baseline == actual ? '=' : '≠'} $label — $actual'
        '${baseline == actual ? '' : ' (기준: $baseline)'}');
  }

  /// [run] 의 줄과 종료 코드를 [want] / [wantExit] 와 견줘 적고, 다른 줄을 찍는다.
  void same(String label, Run run, List<String> want, int wantExit) {
    final diff = diffLines(want, run.lines);
    add(
      label,
      'exit $wantExit, ${want.length}줄, 차이 0줄',
      run.jsonOk
          ? 'exit ${run.exitCode}, ${run.lines.length}줄, 차이 ${diff.length}줄'
          : 'exit ${run.exitCode}, JSON 없음',
    );
    for (final d in diff) {
      stdout.writeln('       $d');
    }
  }

  /// [run] 이 plugin 을 준비했는지를 적는다. [folders] 는 기준 SDK 에서의 plugin 폴더 수다.
  void plugin(String label, Run run, {required int folders}) => add(
        label,
        folders == 0 ? '폴더 0개' : '폴더 $folders개, plugin.aot 있음, 실패 머리말 없음',
        run.pluginFolders == 0 && !run.pluginFailed
            ? '폴더 0개'
            : '폴더 ${run.pluginFolders}개, plugin.aot ${run.pluginSnapshot ? '있음' : '없음'}, '
                '실패 머리말 ${run.pluginFailed ? '있음' : '없음'}',
      );

  /// 기준과 다른 칸의 이름.
  List<String> get different => [for (final i in _items) if (i.$2 != i.$3) i.$1];

  /// 결과 파일에 쓸 목록.
  List<Map<String, Object?>> toJson() => [
        for (final i in _items)
          {'label': i.$1, 'baseline': i.$2, 'actual': i.$3, 'same': i.$2 == i.$3},
      ];

  /// 끝에 찍는 표.
  void printTable() {
    stdout.writeln('');
    stdout.writeln('# 기준 SDK (Dart 3.13.4) 의 값과 견줌');
    for (final i in _items) {
      stdout.writeln(i.$2 == i.$3 ? '= ${i.$1} — ${i.$3}' : '≠ ${i.$1} — ${i.$3} (기준: ${i.$2})');
    }
    stdout.writeln(different.isEmpty
        ? '모든 칸이 기준과 같다 (${_items.length}칸)'
        : '기준과 다른 칸 ${different.length}개 / ${_items.length}칸');
  }
}

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final checks = Checks();
  final obs = Observations();
  final dartVersion = Platform.version.split(' ').first;
  stdout.writeln('Dart $dartVersion on ${Platform.operatingSystem}');
  stdout.writeln('');

  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final expected = Expected.read(replica.repoRoot);
    final root = replica.root;
    final example = '$root/example';
    final pubspecOriginal = File('${replica.repoRoot}/pubspec.yaml').readAsStringSync();
    if (!pubspecOriginal.contains(sdkLine)) {
      throw const FormatException('저장소 pubspec.yaml 에서 SDK 하한 줄을 찾지 못했다');
    }

    void setRoot(String body) => File('$root/analysis_options.yaml').writeAsStringSync(body);

    /// plugin 을 쓰는 실행의 상태 폴더에서 plugin 쪽에 풀린 버전을 읽는다.
    String pluginVersions(String stateName) {
      final folders = Replica.pluginFolders('${replica.work}/state/$stateName');
      if (folders.length != 1) return 'plugin 폴더 ${folders.length}개 — 읽지 못함';
      String v(String package) => Replica.lockedVersion(folders.single, package) ?? '?';
      return 'riverpod_lint ${v('riverpod_lint')} / analyzer ${v('analyzer')} / '
          'analysis_server_plugin ${v('analysis_server_plugin')}';
    }

    /// replica 루트에서 인자 없이 분석한다 (커밋 전 린터와 같은 실행).
    Future<Run> atRoot(String id, String title) async {
      final run = await replica.analyze(id: id, title: title, cwd: root, quiet: true);
      for (var i = 0; i < run.lines.length && i < 12; i++) {
        stdout.writeln('     ${run.lines[i]} — ${run.messages[i]}');
      }
      return run;
    }

    /// `example/` 을 [options] 로 분석한다. [state] 를 주면 그 상태 폴더를 이어 쓴다.
    Future<Run> atExample(String id, String title, String options,
        {String? state, bool showLines = false}) {
      replica.setOptions('example', options);
      return replica.analyze(
        id: id,
        title: title,
        cwd: example,
        stateDir: state == null ? null : '${replica.work}/state/$state',
        quiet: !showLines,
      );
    }

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
        return run;
      } finally {
        Directory('$root/build').deleteSync(recursive: true);
      }
    }

    /// 규칙 검사의 결과를 한 줄로 적는다 — 종료 코드와 진단의 규칙 이름들.
    String ruleSummary(Run run) {
      final codes = [for (final l in run.lines) l.split('  ').last]..sort();
      return 'exit ${run.exitCode}, ${run.lines.length}줄${codes.isEmpty ? '' : ' (${codes.join(', ')})'}';
    }

    /// 생성 파일 샘플의 두 진단이 [run] 에 나왔는지를 `규칙 … / plugin …` 으로 적는다.
    String cells(Run run) {
      bool has(String code) =>
          run.lines.any((l) => l.startsWith('$generatedSample:') && l.endsWith('  $code'));
      return '규칙 ${has('prefer_single_quotes') ? '나옴' : '안 나옴'} / '
          'plugin ${has('provider_parameters') ? '나옴' : '안 나옴'}';
    }

    replica.create();
    replica.writeLibUnsplit(shipped.original);
    replica.addFixture('example', options: oldUri);
    await replica.getPackages(root);
    await replica.getPackages(example);

    stdout.writeln('# 1부. 한 파일 구조 (1.3.0 의 모양 — 사용 프로젝트가 지금 받는 것)');
    final uOld = await atExample('U-old', '한 파일 구조, 옛 주소 한 줄', oldUri, showLines: true);
    obs.same('U-old 한 파일 구조의 진단이 정답지와 같다', uOld, expected.lines, expected.exitCode);
    obs.plugin('U-old plugin 준비', uOld, folders: 1);
    obs.add('plugin 쪽에서 풀린 버전', baselinePluginVersions, pluginVersions('U-old'));
    setRoot("include: package:flutter_lints/flutter.yaml\nanalyzer:\n  exclude:\n    - 'example/**'\n");
    final r1 = await atRoot('R1', '한 파일 구조, 루트에서 lib/analysis_options.yaml 제외를 걷어냄');
    final inner = r1.lines.where((l) => l.endsWith('  plugins_in_inner_options')).length;
    obs.add('R1 한 파일 구조에서 루트의 lib 제외를 걷어내면', 'plugins_in_inner_options 1건, exit 2',
        'plugins_in_inner_options $inner건, exit ${r1.exitCode}');

    stdout.writeln('');
    stdout.writeln('# 2부. 나눈 구조 (Phase 3 이 지을 모양)');
    replica.writeLibSplit(shipped);
    final r2 = await atRoot('R2', '나눈 구조, 루트에 lib 제외 없음');
    obs.add('R2 나눈 구조의 루트 분석', 'exit 0, 0줄, plugin 폴더 0개',
        'exit ${r2.exitCode}, ${r2.lines.length}줄, plugin 폴더 ${r2.pluginFolders}개');
    final sAlias =
        await atExample('S-alias', '옛 주소 한 줄 (3단: 별칭 → 묶음 → 조각)', oldUri, showLines: true);
    obs.same('S-alias 옛 주소의 진단이 정답지와 같다', sAlias, expected.lines, expected.exitCode);
    obs.plugin('S-alias plugin 준비', sAlias, folders: 1);
    final sBundle = await atExample('S-bundle', '묶음 주소 한 줄', bundleUri);
    obs.same('S-bundle 묶음 주소의 진단이 정답지와 같다', sBundle, expected.lines, expected.exitCode);
    obs.plugin('S-bundle plugin 준비', sBundle, folders: 1);
    final sBase = await atExample('S-base-only', 'base.yaml 만', Replica.includeList(['base']));
    obs.same('S-base-only 기본만', sBase, expected.predicted(riverpod: false, codegen: false), 2);
    obs.plugin('S-base-only plugin 준비', sBase, folders: 0);
    final sRiverpod = await atExample(
        'S-base-riverpod', 'base.yaml + riverpod.yaml', Replica.includeList(['base', 'riverpod']));
    obs.same('S-base-riverpod 기본 + Riverpod', sRiverpod,
        expected.predicted(riverpod: true, codegen: false), 2);
    obs.plugin('S-base-riverpod plugin 준비', sRiverpod, folders: 1);
    final sCodegen = await atExample(
        'S-base-codegen', 'base.yaml + codegen.yaml', Replica.includeList(['base', 'codegen']));
    obs.same('S-base-codegen 기본 + codegen', sCodegen,
        expected.predicted(riverpod: false, codegen: true), 0);
    obs.plugin('S-base-codegen plugin 준비', sCodegen, folders: 0);

    stdout.writeln('');
    stdout.writeln('# 3부. 규칙 검사 — 지금 규칙 12개 중 이 SDK 에서 deprecated / removed 가 된 것');
    final base = shipped.baseYaml;
    final withProblems = insertAfterLastRule(base, [for (final r in problemRules) '    - $r']);
    final pubspecFile = File('$root/pubspec.yaml');
    final kBase = await ruleCheck('K-base', 'base.yaml 그대로, SDK 하한 ^3.13.0 (저장소의 것)',
        {'analysis_options.yaml': base});
    obs.add('K-base 지금 규칙 (하한 ^3.13.0)', 'exit 0, 0줄', ruleSummary(kBase));
    final kProblem = await ruleCheck('K-problem', 'base.yaml 에 문제 규칙 셋을 끼움, 하한 ^3.13.0',
        {'analysis_options.yaml': withProblems});
    obs.add('K-problem 문제 규칙 셋 (하한 ^3.13.0)',
        'exit 2, 3줄 (deprecated_lint, removed_lint, undefined_lint)', ruleSummary(kProblem));
    checks.add('K-problem 없는 규칙이 보고된다 (규칙 검사가 이 SDK 에서 동작한다)',
        kProblem.lines.any((l) => l.endsWith('  undefined_lint')), ruleSummary(kProblem));
    try {
      // deprecated / removed 는 pubspec 의 SDK 하한이 그 버전 이상일 때만 보고된다 (spike 005).
      // 하한만 올려 "이 패키지가 하한을 올리면 보일 것" 을 본다. pub get 은 다시 하지 않는다.
      for (final floor in ['^3.14.0', '^3.99.0']) {
        pubspecFile.writeAsStringSync(pubspecOriginal.replaceFirst(sdkLine, '  sdk: $floor\n'));
        final k = await ruleCheck('K-base-$floor', 'base.yaml 그대로, SDK 하한 $floor',
            {'analysis_options.yaml': base});
        obs.add('K-base 지금 규칙 (하한 $floor)', 'exit 0, 0줄', ruleSummary(k));
      }
    } finally {
      pubspecFile.writeAsStringSync(pubspecOriginal);
    }

    stdout.writeln('');
    stdout.writeln('# 4부. 생성 파일 제외 — 패턴을 적은 곳에 따라');
    final sample = File('$example/$generatedSample')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(generatedBody);
    final xNone = await atExample(
        'X-none', '제외 없음 (base.yaml + riverpod.yaml)', Replica.includeList(['base', 'riverpod']),
        state: 'S-base-riverpod');
    obs.add('X-none 제외 없음', '규칙 나옴 / plugin 나옴', cells(xNone));
    checks.add('X-none 제외가 없으면 생성 파일 샘플의 규칙 진단이 나온다 (대조)',
        cells(xNone).startsWith('규칙 나옴'), cells(xNone));
    final xBundle =
        await atExample('X-bundle', '패키지의 codegen.yaml (묶음으로 받음)', bundleUri, state: 'S-bundle');
    obs.add('X-bundle 패키지의 codegen.yaml 이 주는 제외', '규칙 안 나옴 / plugin 나옴', cells(xBundle));
    final leaked = generatedLines.where(xBundle.lines.contains).length;
    obs.add('X-bundle 에서 example 의 생성 파일 샘플 4줄', '0줄 나옴', '$leaked줄 나옴');
    final xOwn = await atExample(
        'X-own', '묶음 + 사용 프로젝트의 옵션 파일에 직접', '$bundleUri$ownExclude',
        state: 'S-bundle');
    obs.add('X-own 사용 프로젝트가 직접 적은 제외', '규칙 안 나옴 / plugin 안 나옴', cells(xOwn));
    // 기준이 "패턴을 적은 파일의 폴더" 인지 — 같은 내용의 파일을 폴더만 달리 두어 본다 (spike 012).
    final localAtRoot = File('$example/local_excludes.yaml')..writeAsStringSync(ownExclude);
    final xRoot = await atExample(
        'X-local-root',
        '프로젝트 루트의 local_excludes.yaml 을 include',
        '${Replica.includeList(['base', 'riverpod'])}  - local_excludes.yaml\n',
        state: 'S-base-riverpod');
    obs.add('X-local-root 프로젝트 루트의 파일에 적은 제외', '규칙 안 나옴 / plugin 안 나옴', cells(xRoot));
    localAtRoot.deleteSync();
    final localInSub = File('$example/config/local_excludes.yaml')
      ..parent.createSync()
      ..writeAsStringSync(ownExclude);
    final xSub = await atExample(
        'X-local-sub',
        '하위 폴더의 config/local_excludes.yaml 을 include',
        '${Replica.includeList(['base', 'riverpod'])}  - config/local_excludes.yaml\n',
        state: 'S-base-riverpod');
    obs.add('X-local-sub 하위 폴더의 파일에 적은 제외', '규칙 안 나옴 / plugin 나옴', cells(xSub));
    localInSub.parent.deleteSync(recursive: true);
    replica.writeLibUnsplit(shipped.original);
    final xOld = await atExample('X-old', '한 파일 구조 (1.3.0 의 모양)', oldUri, state: 'U-old');
    obs.add('X-old 한 파일 구조가 주는 제외', '규칙 안 나옴 / plugin 나옴', cells(xOld));
    sample.deleteSync();

    obs.printTable();
    checks.printSummary();
    replica.writeResults('probe-$dartVersion', extra: {
      'expectedExit': expected.exitCode,
      'expectedLines': expected.lines,
      'pluginVersions': pluginVersions('S-bundle'),
      'observations': obs.toJson(),
      'checks': checks.toJson(),
    });
    if (!checks.allOk) exitCode = 1;
  });
}
