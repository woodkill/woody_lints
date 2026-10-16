// spike 011 — 배포 파일을 나눈 뒤 저장소 루트의 분석이 어떻게 되는가.
//
// 실행: fvm dart run .planning/spikes/011-root-analysis-after-split/probe.dart <작업 폴더>
//
// 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 에 저장소의 모양(pubspec.yaml, 루트 옵션
// 파일, lib/, tool/verify.dart, example/)을 복사하고, replica 루트에서 인자 없이
// `dart analyze` 를 돌린다 — 커밋 전 린터와 같은 실행이다. 실행마다 빈 상태 폴더를 주어
// "루트 분석이 plugin 을 준비했는가" 를 `.plugin_manager` 아래 폴더 수로 본다.
import 'dart:io';

import '../009-preset-plugin-via-include/replica.dart';

/// 옛 주소 한 줄.
const oldUri = 'include: package:woody_lints/analysis_options.yaml\n';

/// 루트 옵션 파일 내용을 만든다 — [include] 한 줄과 [excludes] 제외 목록.
String rootOptions({
  String include = 'package:flutter_lints/flutter.yaml',
  List<String> excludes = const [],
}) =>
    'include: $include\n'
    '${excludes.isEmpty ? '' : 'analyzer:\n  exclude:\n${excludes.map((e) => "    - '$e'\n").join()}'}';

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final checks = Checks();
  stdout.writeln('Dart ${Platform.version.split(' ').first} on ${Platform.operatingSystem}');
  stdout.writeln('');

  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final expected = Expected.read(replica.repoRoot);
    final root = replica.root;
    final currentRootOptions = File('${replica.repoRoot}/analysis_options.yaml').readAsStringSync();

    /// replica 루트에서 인자 없이 분석한다. 진단마다 메시지를 함께 찍는다.
    Future<Run> atRoot(String id, String title) async {
      final run = await replica.analyze(id: id, title: title, cwd: root, quiet: true);
      for (var i = 0; i < run.lines.length && i < 12; i++) {
        stdout.writeln('     ${run.lines[i]} — ${run.messages[i]}');
      }
      if (run.lines.length > 12) stdout.writeln('     … 그 밖 ${run.lines.length - 12}줄');
      return run;
    }

    void setRoot(String body) => File('$root/analysis_options.yaml').writeAsStringSync(body);

    /// [run] 이 진단 0건 · exit 0 · plugin 준비 없음인지 적는다.
    void expectClean(String label, Run run) => checks.add(
          label,
          run.jsonOk && run.lines.isEmpty && run.exitCode == 0 && run.pluginFolders == 0,
          'exit ${run.exitCode}, ${run.lines.length}줄, plugin 폴더 ${run.pluginFolders}개, ${run.seconds}초',
        );

    replica.create();
    Directory('$root/tool').createSync();
    File('${replica.repoRoot}/tool/verify.dart').copySync('$root/tool/verify.dart');
    replica.writeLibUnsplit(shipped.original);
    replica.addFixture('example', options: oldUri);
    await replica.getPackages(root);
    await replica.getPackages('$root/example');

    stdout.writeln('# 1부. 지금의 구조 (한 파일) — 루트의 제외가 왜 있는지 다시 본다');
    final r0 = await atRoot('R0', '한 파일, 루트 옵션은 저장소의 것 그대로 (lib 제외 + example 제외)');
    expectClean('R0 지금의 저장소 모양은 깨끗하다', r0);
    setRoot(rootOptions(excludes: ['example/**']));
    final r1 = await atRoot('R1', '한 파일, 루트에서 lib/analysis_options.yaml 제외를 걷어냄');
    checks.add(
      'R1 한 파일 구조에서 제외를 걷어내면 plugins_in_inner_options 가 난다',
      r1.lines.any((l) =>
          l.startsWith('lib/analysis_options.yaml:') && l.endsWith('  plugins_in_inner_options')),
      'exit ${r1.exitCode}, ${r1.lines.length}줄, plugin 폴더 ${r1.pluginFolders}개',
    );

    stdout.writeln('');
    stdout.writeln('# 2부. 나눈 구조 — 제외를 걷어낸다 (PRESET-06)');
    replica.writeLibSplit(shipped);
    setRoot(rootOptions(excludes: ['example/**']));
    final r2 = await atRoot('R2', '나눈 구조(package: 주소), lib 제외 없음');
    expectClean('R2 나눈 구조에서 제외를 걷어내도 루트 분석이 깨끗하다 (plugins_in_inner_options 없음)', r2);
    setRoot(currentRootOptions);
    final r3 = await atRoot('R3', '나눈 구조, 루트 옵션은 저장소의 것 그대로 (제외를 남겨 둠)');
    expectClean('R3 제외를 남겨 둬도 깨끗하다', r3);
    replica.writeLibSplit(shipped, relative: true);
    setRoot(rootOptions(excludes: ['example/**']));
    final r2rel = await atRoot('R2-rel', '나눈 구조(상대 경로), lib 제외 없음');
    expectClean('R2-rel 상대 경로로 불러도 깨끗하다', r2rel);

    stdout.writeln('');
    stdout.writeln('# 2부-2. 가장자리 — 조각 파일을 일부러 망가뜨리면 루트 분석이 알아채는가');
    replica.writeLibSplit(shipped, extra: {
      'recommended.yaml': Replica.includeList(['base', 'no_such_fragment', 'codegen']),
    });
    final r5 = await atRoot('R5', '묶음이 없는 조각을 부름, lib 제외 없음');
    checks.add(
      'R5 묶음이 없는 조각을 부르면 루트 분석이 별칭 파일에 진단을 붙인다',
      r5.lines.any((l) => l.startsWith('lib/analysis_options.yaml:')),
      'exit ${r5.exitCode}, ${r5.lines.length}줄',
    );
    replica.writeLibSplit(shipped);

    stdout.writeln('');
    stdout.writeln('# 3부. 패키지를 받기 전 (저장소를 새로 받은 직후)');
    void dropRootPackages() {
      final tool = Directory('$root/.dart_tool');
      if (tool.existsSync()) tool.deleteSync(recursive: true);
      final lock = File('$root/pubspec.lock');
      if (lock.existsSync()) lock.deleteSync();
    }

    dropRootPackages();
    replica.writeLibUnsplit(shipped.original);
    setRoot(currentRootOptions);
    final c0 = await atRoot('C0', '한 파일, 저장소의 루트 옵션 (지금의 모양, pub get 전)');
    replica.writeLibSplit(shipped);
    setRoot(rootOptions(excludes: ['example/**']));
    final c1 = await atRoot('C1', '나눈 구조(package: 주소), lib 제외 없음, pub get 전');
    replica.writeLibSplit(shipped, relative: true);
    final c2 = await atRoot('C2', '나눈 구조(상대 경로), lib 제외 없음, pub get 전');
    checks.add(
      'C1 · C2 는 pub get 전에 C0 보다 진단이 는다 (늘면 기록할 사실, 줄지 않으면 성립)',
      c1.lines.length >= c0.lines.length && c2.lines.length >= c0.lines.length,
      'C0 ${c0.lines.length}줄 exit ${c0.exitCode} / C1 ${c1.lines.length}줄 exit ${c1.exitCode} / C2 ${c2.lines.length}줄 exit ${c2.exitCode}',
    );
    replica.writeLibSplit(shipped);
    await replica.getPackages(root);

    stdout.writeln('');
    stdout.writeln('# 4부. 연습용 프로젝트 폴더가 여럿 — example/ 옆에 fixtures/<이름>/ 둘');
    replica.addFixture('fixtures/base_riverpod', options: Replica.includeList(['base', 'riverpod']));
    replica.addFixture('fixtures/base_only', options: 'include: package:woody_lints/base.yaml\n');
    setRoot(rootOptions(excludes: ['example/**', 'fixtures/**']));
    final f0 = await atRoot('F0', 'fixtures 는 pub get 전, 루트에 fixtures/** 제외');
    expectClean('F0 pub get 전에도 fixtures/** 한 줄로 섞이지 않는다', f0);
    await replica.getPackages('$root/fixtures/base_riverpod');
    await replica.getPackages('$root/fixtures/base_only');
    setRoot(rootOptions(excludes: ['example/**']));
    final f1 = await atRoot('F1', 'fixtures 는 pub get 후, 루트에 fixtures 제외 없음');
    checks.add(
      'F1 제외하지 않으면 fixtures 의 진단이 루트 분석에 섞인다',
      f1.lines.any((l) => l.startsWith('fixtures/')),
      'exit ${f1.exitCode}, ${f1.lines.length}줄 (fixtures/ ${f1.lines.where((l) => l.startsWith('fixtures/')).length}줄), plugin 폴더 ${f1.pluginFolders}개, ${f1.seconds}초',
    );
    setRoot(rootOptions(excludes: ['example/**', 'fixtures/**']));
    final f2 = await atRoot('F2', 'fixtures 는 pub get 후, 루트에 fixtures/** 제외 한 줄');
    expectClean('F2 fixtures/** 한 줄이면 폴더가 둘이어도 섞이지 않는다', f2);

    final inRiverpod = await replica.analyze(
      id: 'F3',
      title: 'fixtures/base_riverpod 안에서 인자 없이 (루트에 fixtures/** 제외가 있는 채)',
      cwd: '$root/fixtures/base_riverpod',
      quiet: true,
    );
    checks.same('F3 루트의 제외는 fixtures/base_riverpod 안에서의 분석을 건드리지 않는다',
        inRiverpod, expected.predicted(riverpod: true, codegen: false), 2);
    final inBase = await replica.analyze(
      id: 'F4',
      title: 'fixtures/base_only 안에서 인자 없이',
      cwd: '$root/fixtures/base_only',
      quiet: true,
    );
    checks.same('F4 fixtures/base_only 안에서의 분석도 예상과 같다',
        inBase, expected.predicted(riverpod: false, codegen: false), 2);
    checks.add('F4 기본만 받는 폴더는 plugin 을 준비하지 않는다', inBase.pluginFolders == 0,
        '폴더 ${inBase.pluginFolders}개');

    stdout.writeln('');
    stdout.writeln('# 4부-2. 옵션 파일에 plugins: 를 직접 적은 폴더 (끄는 설정용 연습 프로젝트의 모양)');
    replica.addFixture(
      'fixtures/overrides',
      options: 'include: package:woody_lints/recommended.yaml\n'
          '\n'
          'plugins:\n'
          '  riverpod_lint:\n'
          '    version: ^3.1.3\n'
          '    diagnostics:\n'
          '      provider_parameters: false\n',
    );
    setRoot(rootOptions(excludes: ['example/**', 'fixtures/**']));
    final f5 = await atRoot('F5', 'fixtures/overrides 는 pub get 전, 루트에 fixtures/** 제외');
    expectClean('F5 plugins: 를 직접 적은 폴더도 제외하면 루트 분석에 걸리지 않는다 (pub get 전)', f5);
    await replica.getPackages('$root/fixtures/overrides');
    final f6 = await atRoot('F6', 'fixtures/overrides 는 pub get 후, 루트에 fixtures/** 제외');
    expectClean('F6 pub get 후에도 걸리지 않는다', f6);
    Directory('$root/fixtures/overrides').deleteSync(recursive: true);

    stdout.writeln('');
    stdout.writeln('# 5부. 루트 옵션 파일이 이 패키지의 조각을 include 한다면 (tool/ 에 자기 규칙 적용)');
    // 겹따옴표 한 줄 — flutter_lints 는 켜지 않고 base.yaml 은 켜는 `prefer_single_quotes` 로
    // "0건" 이 "깨끗하다" 인지 "규칙이 적용되지 않았다" 인지를 가른다.
    final marker = File('$root/tool/quote_marker.dart');
    setRoot(rootOptions(excludes: ['example/**', 'fixtures/**']));
    final g0 = await atRoot('G0', '지금처럼 flutter_lints 만 include');
    expectClean('G0 flutter_lints 만 include 하면 tool/verify.dart 가 깨끗하다', g0);
    setRoot(rootOptions(
        include: 'package:woody_lints/base.yaml', excludes: ['example/**', 'fixtures/**']));
    final g1 = await atRoot('G1', 'base.yaml 을 include');
    final byRule = <String, int>{};
    for (final l in g1.lines) {
      final rule = l.split('  ').last;
      byRule[rule] = (byRule[rule] ?? 0) + 1;
    }
    stdout.writeln('   규칙별: ${byRule.entries.map((e) => '${e.key} ${e.value}').join(', ')}');
    checks.add('G1 base.yaml 을 include 해도 plugin 을 준비하지 않는다', g1.pluginFolders == 0,
        'exit ${g1.exitCode}, ${g1.lines.length}줄, plugin 폴더 ${g1.pluginFolders}개');
    marker.writeAsStringSync('/// 표식.\nconst String marker = "m";\n');
    setRoot(rootOptions(excludes: ['example/**', 'fixtures/**']));
    final g3 = await atRoot('G3', '겹따옴표 표식 파일을 두고 flutter_lints 만 include');
    expectClean('G3 flutter_lints 만으로는 겹따옴표가 걸리지 않는다 (대조)', g3);
    setRoot(rootOptions(
        include: 'package:woody_lints/base.yaml', excludes: ['example/**', 'fixtures/**']));
    final g4 = await atRoot('G4', '겹따옴표 표식 파일을 두고 base.yaml 을 include');
    checks.add(
      'G4 base.yaml 을 include 하면 이 패키지의 규칙이 tool/ 에 실제로 적용된다',
      g4.lines.length == 1 && g4.lines.single == 'tool/quote_marker.dart:2  info  prefer_single_quotes',
      'exit ${g4.exitCode}, ${g4.lines.length}줄',
    );
    marker.deleteSync();
    setRoot(rootOptions(
        include: 'package:woody_lints/recommended.yaml', excludes: ['example/**', 'fixtures/**']));
    final g2 = await atRoot('G2', 'recommended.yaml 을 include');
    checks.add(
      'G2 묶음을 include 하면 루트 분석이 plugin 을 준비한다 (루트에서 쓰지 않는 이유)',
      g2.pluginFolders == 1,
      'exit ${g2.exitCode}, ${g2.lines.length}줄, plugin 폴더 ${g2.pluginFolders}개, ${g2.seconds}초',
    );

    checks.printSummary();
    replica.writeResults('probe', extra: {'checks': checks.toJson()});
    if (!checks.allOk) exitCode = 1;
  });
}
