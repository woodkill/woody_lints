// spike 016 의 뒤따른 실험 — 루트 분석이 plugin 을 준비하는 까닭을 떼어 본다.
//
// probe.dart 의 베타 실행에서 예상 밖의 결과가 나왔다: 저장소 루트에서 인자 없이 돌린 분석이
// `plugins_in_inner_options` 를 내지 않고 plugin 을 준비했다. 원인이 `lib/` 의 옵션 파일인지
// `example/` 인지를 가르기 위해 둘을 하나씩 넣고 빼며 같은 실행을 한다.
//
// probe.dart 와 같은 방식으로 SDK 마다 한 번씩 돌린다 (저장소 밖을 작업 디렉터리로, 절대 경로로).
// 결과는 `results/root-<Dart 버전>.json`.
import 'dart:io';

import '../009-preset-plugin-via-include/replica.dart';

/// 옛 주소 한 줄.
const oldUri = 'include: package:woody_lints/analysis_options.yaml\n';

/// 묶음의 정식 주소 한 줄.
const bundleUri = 'include: package:woody_lints/recommended.yaml\n';

/// 루트 옵션 파일 내용 — 기반 세트를 include 하고 [excludes] 를 제외한다.
String rootOptions(List<String> excludes) =>
    'include: package:flutter_lints/flutter.yaml\n'
    '${excludes.isEmpty ? '' : 'analyzer:\n  exclude:\n${excludes.map((e) => "    - '$e'\n").join()}'}';

/// 한 경우 — `lib/` 의 모양, `example/` 의 유무, 루트의 제외 목록.
class Case {
  /// [lib] 는 `empty` / `unsplit` / `split` / `split-no-alias` 중 하나다.
  const Case(this.id, this.lib, this.example, this.excludes, this.note, {this.options = oldUri});

  /// 짧은 이름.
  final String id;

  /// `lib/` 의 모양.
  final String lib;

  /// `example/` 을 두는가 (패키지를 받은 상태로).
  final bool example;

  /// 루트 옵션 파일의 제외 목록.
  final List<String> excludes;

  /// 표에 찍을 설명.
  final String note;

  /// `example/` 의 옵션 파일 내용.
  final String options;
}

/// `example/` 이 없는 경우를 먼저 돌린다 — `example/` 은 한 번 만들면 끝까지 둔다.
const cases = <Case>[
  Case('E0', 'empty', false, [], 'lib 비어 있음 (대조)'),
  Case('U1', 'unsplit', false, [], '한 파일 구조, 제외 없음'),
  Case('U2', 'unsplit', false, ['lib/analysis_options.yaml'], '한 파일 구조, lib 의 옵션 파일 제외'),
  Case('S1', 'split', false, [], '나눈 구조, 제외 없음'),
  Case('S2', 'split', false, ['lib/analysis_options.yaml'], '나눈 구조, 별칭 제외'),
  Case('S3', 'split-no-alias', false, [], '나눈 구조에서 별칭 파일만 뺌 (조각 · 묶음만)'),
  Case('X1', 'empty', true, ['example/**'], 'example 만, example 제외'),
  Case('X2', 'empty', true, [], 'example 만, 제외 없음'),
  Case('X3', 'split-no-alias', true, ['example/**'], 'example 이 묶음을 부름 (plugin 에 닿음), example 제외',
      options: bundleUri),
  Case('X4', 'split-no-alias', true, [], 'example 이 묶음을 부름 (plugin 에 닿음), 제외 없음',
      options: bundleUri),
  Case('T0', 'unsplit', true, ['lib/analysis_options.yaml', 'example/**'], '지금의 저장소 모양'),
  Case('T1', 'split', true, ['example/**'], 'Phase 3 이 지을 모양 (lib 제외를 걷어냄)'),
  Case('T2', 'split', true, ['lib/analysis_options.yaml', 'example/**'], '나눈 구조, 제외를 남겨 둠'),
];

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  final checks = Checks();
  final dartVersion = Platform.version.split(' ').first;
  final table = <Map<String, Object?>>[];
  stdout.writeln('Dart $dartVersion on ${Platform.operatingSystem}');
  stdout.writeln('');

  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final root = replica.root;

    replica.create();
    await replica.getPackages(root);
    var exampleReady = false;

    for (final c in cases) {
      switch (c.lib) {
        case 'empty':
          replica.writeLib({});
        case 'unsplit':
          replica.writeLibUnsplit(shipped.original);
        case 'split':
          replica.writeLibSplit(shipped);
        case 'split-no-alias':
          replica.writeLibSplit(shipped);
          File('$root/lib/analysis_options.yaml').deleteSync();
      }
      if (c.example && !exampleReady) {
        replica.addFixture('example', options: oldUri);
        await replica.getPackages('$root/example');
        exampleReady = true;
      }
      if (c.example) replica.setOptions('example', c.options);
      File('$root/analysis_options.yaml').writeAsStringSync(rootOptions(c.excludes));

      final run = await replica.analyze(
        id: c.id,
        title: '${c.note} — lib: ${c.lib}, example: ${c.example ? '있음' : '없음'}, '
            '제외: ${c.excludes.isEmpty ? '없음' : c.excludes.join(' · ')}',
        cwd: root,
        quiet: true,
      );
      for (var i = 0; i < run.lines.length && i < 6; i++) {
        stdout.writeln('     ${run.lines[i]} — ${run.messages[i]}');
      }
      if (run.lines.length > 6) stdout.writeln('     … 그 밖 ${run.lines.length - 6}줄');
      final codes = <String, int>{};
      for (final l in run.lines) {
        final code = l.split('  ').last;
        codes[code] = (codes[code] ?? 0) + 1;
      }
      table.add({
        'id': c.id,
        'note': c.note,
        'lib': c.lib,
        'example': c.example,
        'excludes': c.excludes,
        'exitCode': run.exitCode,
        'lines': run.lines.length,
        'codes': codes,
        'pluginFolders': run.pluginFolders,
        'pluginConstraint': run.pluginConstraint,
        'seconds': run.seconds,
      });
    }

    final e0 = table.first;
    checks.add('E0 lib 가 비어 있으면 0건이고 plugin 을 준비하지 않는다 (대조)',
        e0['lines'] == 0 && e0['exitCode'] == 0 && e0['pluginFolders'] == 0,
        'exit ${e0['exitCode']}, ${e0['lines']}줄, plugin 폴더 ${e0['pluginFolders']}개');

    stdout.writeln('');
    stdout.writeln('| id | lib | example | 루트의 제외 | exit | 진단 | plugin 폴더 | 시간 |');
    stdout.writeln('|---|---|---|---|---|---|---|---|');
    for (final row in table) {
      final codes = (row['codes']! as Map<String, int>)
          .entries
          .map((e) => '${e.key} ${e.value}')
          .join(', ');
      stdout.writeln('| ${row['id']} | ${row['lib']} | ${row['example'] == true ? '있음' : '없음'} | '
          '${(row['excludes']! as List).isEmpty ? '없음' : (row['excludes']! as List).join(' · ')} | '
          '${row['exitCode']} | ${row['lines']}줄${codes.isEmpty ? '' : ' ($codes)'} | '
          '${row['pluginFolders']} | ${row['seconds']}s |');
    }

    checks.printSummary();
    replica.writeResults('root-$dartVersion', extra: {'cases': table, 'checks': checks.toJson()});
    if (!checks.allOk) exitCode = 1;
  });
}
