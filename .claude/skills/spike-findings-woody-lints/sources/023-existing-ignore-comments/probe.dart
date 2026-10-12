// Spike 023 — `flutter_starter_kit` 에 이미 있는 `// ignore` 주석이 무엇을 가리는가.
//
// 복사본에서 주석을 둔 채 / 걷어낸 채로 분석해 견준다. 주석은 줄째로 지우지 않고 주석 부분만
// 빈 문자열로 바꿔 줄 번호를 지킨다. 생성 파일(`*.g.dart`, `*.freezed.dart`)은 사용 프로젝트가
// 스스로 분석에서 빼므로 건드리지 않는다.
//
//   I0 원본 옵션, 주석 그대로        — 지금 사용 프로젝트가 보는 것 (기준선)
//   I1 원본 옵션, 주석을 걷어냄       — 기준선이 주석 덕분에 0 인 부분
//   I2 후보 규칙 + unnecessary_ignore, 주석 그대로
//   I3 후보 규칙 + unnecessary_ignore, 주석을 걷어냄
//   I4 원본 옵션 + unnecessary_ignore, 주석 그대로 — 지금 규칙에서 필요 없는 주석
//
// 후보 규칙은 주석이 가리키는 규칙 가운데 지금 켜져 있지 않은 것 (`lines_longer_than_80_chars`,
// `discarded_futures`, `cast_nullable_to_non_nullable`) 이다.
//
// 실행 (저장소 루트에서):
//   fvm dart .planning/spikes/023-existing-ignore-comments/probe.dart <작업 폴더> <사용 프로젝트 원본>
import 'dart:convert';
import 'dart:io';

import '../021-new-rules-language-gate/consumer.dart';

const candidates = ['lines_longer_than_80_chars', 'discarded_futures', 'cast_nullable_to_non_nullable'];

/// 무시 주석 — `// ignore: a, b` 와 `// ignore_for_file: a, b`.
final ignorePattern = RegExp(r'//\s*(ignore_for_file|ignore)\s*:\s*(.*)$');

/// 표식 — 후보 규칙마다 위반 하나와, 주석으로 가린 같은 위반 하나. 그리고 아무것도 가리지 않는 주석.
const markers = {
  'ignore_probe/discarded_futures.dart': '''
/// 표식 — 동기 함수에서 Future 를 버린다.
void discardMarker() {
  Future<void>.delayed(Duration.zero);
}

/// 표식 — 같은 위반을 무시 주석으로 가렸다 (주석을 걷어낸 실행에서만 보인다).
void discardIgnoredMarker() {
  // ignore: discarded_futures
  Future<void>.delayed(Duration.zero);
}
''',
  'ignore_probe/lines_longer_than_80_chars.dart': '''
/// 표식 — 80자를 넘는 줄.
const longLineMarker = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
''',
  'ignore_probe/lines_longer_than_80_chars_ignored.dart': '''
// ignore_for_file: lines_longer_than_80_chars
/// 표식 — 같은 위반을 파일 단위 무시 주석으로 가렸다.
const longLineIgnoredMarker = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
''',
  'ignore_probe/cast_nullable_to_non_nullable.dart': '''
/// 표식용 타입.
class CastBaseMarker {}

/// 표식용 하위 타입.
class CastChildMarker extends CastBaseMarker {}

/// 표식 — nullable 값을 non-nullable 하위 타입으로 as.
CastChildMarker castMarker(CastBaseMarker? value) => value as CastChildMarker;
''',
  'ignore_probe/unnecessary_ignore.dart': '''
/// 표식 — 아무것도 가리지 않는 무시 주석.
// ignore: avoid_print
int unnecessaryIgnoreMarker() => 1;
''',
};

late final String spikeDir;
late final Consumer consumer;
final log = StringBuffer();

void say(String line) {
  final s = consumer.scrubText(line);
  stdout.writeln(s);
  log.writeln(s);
}

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln('사용법: fvm dart <이 스크립트> <작업 폴더 — 저장소 밖> <사용 프로젝트 원본>');
    exit(64);
  }
  spikeDir = File.fromUri(Platform.script).parent.path;
  final repo = Repo.fromSpikeDir(spikeDir);
  final work = Directory(args[0]).absolute.path;
  final source = Directory(args[1]).resolveSymbolicLinksSync();
  if (work.startsWith(repo.root) || work.startsWith(source)) {
    stderr.writeln('작업 폴더는 저장소와 원본 밖에 둔다');
    exit(64);
  }
  final repoBefore = await repo.fingerprint();
  consumer = Consumer(work: work, repo: repo, source: source);
  final dartVersion = Platform.version.split(' ').first;
  say('# Spike 023 — 이미 있는 무시 주석');
  say('SDK: $dartVersion');
  say('');

  consumer.copy();
  await consumer.pointToRepo();
  consumer.addExampleMarkers();
  consumer.addMarkers(markers);

  // 1. 주석 세기 — 자리 · 종류 · 코드별 건수만
  final inventory = countIgnores();
  say('## 무시 주석 (복사본의 lib · test · bin, 표식 제외)');
  say('- 주석이 있는 줄: 손으로 쓴 파일 ${inventory.lines['hand']} · 생성 파일 ${inventory.lines['gen']} '
      '(파일 수 ${inventory.files['hand']} · ${inventory.files['gen']})');
  say('- `type=lint` 를 단 손으로 쓴(이름이 `.g.dart` · `.freezed.dart` 가 아닌) 파일 ${inventory.typeLintHand}개, '
      '그중 머리 5줄에 GENERATED 가 있는 것 ${inventory.typeLintHandGenerated}개');
  say('| 자리 | 종류 | 코드 | 건수 |');
  say('|---|---|---|---|');
  for (final e in (inventory.codes.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))) {
    final parts = e.key.split('|');
    say('| ${parts[0]} | ${parts[1]} | `${parts[2]}` | ${e.value} |');
  }
  say('');

  // 2. 분석
  final shots = <String, Shot>{};
  Future<Shot> shoot(String id, {required List<String> rules, required bool stripped}) async {
    consumer.refreshSources();
    consumer.addExampleMarkers();
    consumer.addMarkers(markers);
    var strippedCount = 0;
    if (stripped) strippedCount = stripIgnores();
    consumer.setOptions(consumer.optionsWith(rules: rules));
    final s = await consumer.analyze(id);
    consumer.ensureRepoSource(s);
    shots[id] = s;
    say('- $id: 주석 ${stripped ? '걷어냄 ($strippedCount줄)' : '그대로'}, 더 켠 규칙 ${rules.isEmpty ? '없음' : rules.join(', ')} → '
        'exit ${s.exitCode}, 줄 ${s.diags.length} (표식 ${s.marker.length} · 프로젝트 ${s.project.length}), ${s.elapsedMs} ms');
    return s;
  }

  say('## 분석');
  final i0 = await shoot('I0', rules: [], stripped: false);
  final i1 = await shoot('I1', rules: [], stripped: true);
  final i2 = await shoot('I2', rules: [...candidates, 'unnecessary_ignore'], stripped: false);
  final i3 = await shoot('I3', rules: [...candidates, 'unnecessary_ignore'], stripped: true);
  await shoot('I4', rules: ['unnecessary_ignore'], stripped: false);
  consumer.refreshSources();
  consumer.setOptions(consumer.originalOptions);
  say('');

  Map<String, int> projectByCode(Shot s) {
    final out = <String, int>{};
    for (final d in s.project) {
      out.update(d.code, (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }

  // 주석을 걷어낸 실행에서 새로 나온 줄이 어떤 파일에서 왔는지 — `type=lint` 를 단 파일 / 그 밖
  Map<String, Map<String, int>> newLinesByFileKind(Shot before, Shot after) {
    final had = before.project.map((d) => d.text).toSet();
    final out = <String, Map<String, int>>{};
    for (final d in after.project.where((d) => !had.contains(d.text))) {
      final kind = inventory.typeLintFiles.contains(d.path) ? 'type=lint 파일' : '그 밖';
      out.putIfAbsent(kind, () => {}).update(d.code, (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }

  say('## 견줌');
  say('- I0 프로젝트: ${projectByCode(i0)}');
  say('- I1 프로젝트: ${projectByCode(i1)}');
  say('- I1 에서 새로 나온 줄 (파일 종류별): ${newLinesByFileKind(i0, i1)}');
  say('');
  say('| 규칙 | I2 (주석 그대로) | I3 (주석 걷어냄) | 주석이 가린 줄 | I2 표식 | I3 표식 |');
  say('|---|---|---|---|---|---|');
  final perRule = <String, Map<String, int>>{};
  for (final rule in candidates) {
    final a = i2.project.where((d) => d.code == rule).length;
    final b = i3.project.where((d) => d.code == rule).length;
    final ma = i2.marker.where((d) => d.code == rule).length;
    final mb = i3.marker.where((d) => d.code == rule).length;
    perRule[rule] = {'withIgnores': a, 'stripped': b, 'hidden': b - a, 'markerWith': ma, 'markerStripped': mb};
    say('| `$rule` | $a | $b | ${b - a} | $ma | $mb |');
  }
  final i3New = newLinesByFileKind(i2, i3);
  say('- I3 에서 새로 나온 줄 (파일 종류별, 후보 규칙 밖 포함): $i3New');
  say('');

  // unnecessary_ignore — 메시지의 따옴표 안 규칙 이름만 센다 (메시지 자체는 남기지 않는다)
  say('## unnecessary_ignore');
  final unnecessary = <String, Map<String, int>>{};
  for (final id in ['I2', 'I4']) {
    final lines = File('$work/private/$id.txt').readAsLinesSync();
    final counts = <String, int>{};
    for (final d in shots[id]!.diags.where((d) => d.code.startsWith('unnecessary_ignore'))) {
      counts.update('${d.area}:${d.code}', (v) => v + 1, ifAbsent: () => 1);
    }
    unnecessary[id] = counts;
    say('- $id: $counts (private 기록 ${lines.length}줄)');
  }
  final named = await unnecessaryIgnoreNames(work, ['I2', 'I4']);
  say('- 필요 없다고 보고된 주석의 코드 (프로젝트, I4): ${named['I4']}');
  say('- 같은 것 (프로젝트, I2 — 후보 규칙을 켠 뒤): ${named['I2']}');
  say('');

  final repoAfter = await repo.fingerprint();
  final expected = expectedLines('${repo.root}/example/expected_diagnostics.txt')
      .map((l) => l.replaceFirst('lib/', Diag.markerDir))
      .toSet();
  final all = shots.values.toList();
  final checks = <String, bool>{
    'K1 모든 회차에서 woody_lints 가 작업 중인 저장소를 가리켰다': all.every((s) => s.woodySource == 'repo'),
    'K2 모든 회차에서 example 정답지 16줄이 표식의 줄에 들어 있다': all.every((s) => s.marker.map((d) => d.text).toSet().containsAll(expected)),
    'K3 모든 회차에서 plugin 이 준비됐다': all.every((s) => s.pluginFolders == 1 && !s.pluginHeader),
    'K4 대조: 후보 규칙마다 가리지 않은 표식이 I2 에서 걸린다': candidates.every((r) => perRule[r]!['markerWith']! >= 1),
    'K5 대조: 가린 표식이 I2 에서 숨고 I3 에서 보인다 (discarded_futures, lines_longer_than_80_chars)':
        perRule['discarded_futures']!['markerStripped']! == perRule['discarded_futures']!['markerWith']! + 1 &&
            perRule['lines_longer_than_80_chars']!['markerStripped']! == perRule['lines_longer_than_80_chars']!['markerWith']! + 1,
    'K6 대조: 아무것도 가리지 않는 표식 주석이 I4 에서 unnecessary_ignore 로 잡힌다':
        shots['I4']!.marker.any((d) => d.path.endsWith('ignore_probe/unnecessary_ignore.dart') && d.code.startsWith('unnecessary_ignore')),
    'K7 저장소가 그대로다': repoAfter == repoBefore,
  };
  say('# 판정');
  say('| 확인 | 결과 |');
  say('|---|---|');
  for (final e in checks.entries) {
    say('| ${e.key} | ${e.value ? '성립' : '**깨짐**'} |');
  }
  final ok = checks.values.every((v) => v);
  say('');
  say(ok ? '판정에 넣은 확인 ${checks.length}건이 모두 성립했다.' : '성립하지 않은 확인이 있다.');

  final results = Directory('$spikeDir/results')..createSync(recursive: true);
  File('${results.path}/probe-$dartVersion.json').writeAsStringSync(consumer.scrubText(const JsonEncoder.withIndent('  ').convert({
    'date': DateTime.now().toUtc().toIso8601String(),
    'dart': dartVersion,
    'inventory': inventory.toJson(),
    'shots': all.map((s) => s.toJson()).toList(),
    'perRule': perRule,
    'newLinesI1': newLinesByFileKind(i0, i1),
    'newLinesI3': i3New,
    'unnecessaryIgnore': unnecessary,
    'unnecessaryIgnoreNames': named,
    'checks': checks,
  })));
  File('${results.path}/probe-$dartVersion.log').writeAsStringSync(log.toString());
  exit(ok ? 0 : 1);
}

class Inventory {
  final lines = <String, int>{'hand': 0, 'gen': 0};
  final files = <String, int>{'hand': 0, 'gen': 0};
  final codes = <String, int>{};
  int typeLintHand = 0;
  int typeLintHandGenerated = 0;

  /// `type=lint` 를 단 손으로 쓴 파일의 상대 경로 — 결과 파일에는 쓰지 않는다 (줄을 가르는 데만 쓴다).
  final typeLintFiles = <String>{};

  Map<String, Object> toJson() => {
        'lines': lines,
        'files': files,
        'codes': codes,
        'typeLintHand': typeLintHand,
        'typeLintHandGenerated': typeLintHandGenerated,
      };
}

Iterable<File> analyzedDartFiles({bool includeGenerated = false}) sync* {
  for (final top in ['lib', 'test', 'bin']) {
    final d = Directory('${consumer.dir}/$top');
    if (!d.existsSync()) continue;
    for (final f in d.listSync(recursive: true).whereType<File>()) {
      final rel = f.path.substring(consumer.dir.length + 1);
      if (!rel.endsWith('.dart') || rel.startsWith(Diag.markerDir)) continue;
      final generated = rel.endsWith('.g.dart') || rel.endsWith('.freezed.dart');
      if (generated && !includeGenerated) continue;
      yield f;
    }
  }
}

Inventory countIgnores() {
  final inv = Inventory();
  for (final f in analyzedDartFiles(includeGenerated: true)) {
    final rel = f.path.substring(consumer.dir.length + 1);
    final origin = rel.endsWith('.g.dart') || rel.endsWith('.freezed.dart') ? 'gen' : 'hand';
    final text = f.readAsLinesSync();
    var any = false;
    var typeLint = false;
    for (final line in text) {
      final m = ignorePattern.firstMatch(line);
      if (m == null) continue;
      any = true;
      inv.lines.update(origin, (v) => v + 1);
      for (final raw in m.group(2)!.split(',')) {
        final code = raw.trim().split(RegExp(r'\s')).first;
        if (code.isEmpty) continue;
        if (code == 'type=lint' && m.group(1) == 'ignore_for_file') typeLint = true;
        inv.codes.update('$origin|${m.group(1)}|$code', (v) => v + 1, ifAbsent: () => 1);
      }
    }
    if (any) inv.files.update(origin, (v) => v + 1);
    if (typeLint && origin == 'hand') {
      inv.typeLintHand++;
      inv.typeLintFiles.add(rel);
      if (text.take(5).any((l) => l.contains('GENERATED'))) inv.typeLintHandGenerated++;
    }
  }
  return inv;
}

/// 분석되는 파일(생성 파일과 표식 제외)에서 무시 주석 부분만 지운다. 줄 번호는 그대로다.
/// 표식 폴더의 `ignore_probe/` 도 지운다 — 가린 표식이 보이는지가 대조다.
int stripIgnores() {
  var n = 0;
  final targets = [
    ...analyzedDartFiles(),
    ...Directory('${consumer.dir}/${Diag.markerDir}ignore_probe').listSync().whereType<File>(),
  ];
  for (final f in targets) {
    final lines = f.readAsLinesSync();
    var changed = false;
    for (var i = 0; i < lines.length; i++) {
      final m = ignorePattern.firstMatch(lines[i]);
      if (m == null) continue;
      lines[i] = lines[i].substring(0, m.start).trimRight();
      changed = true;
      n++;
    }
    if (changed) f.writeAsStringSync('${lines.join('\n')}\n');
  }
  return n;
}

/// unnecessary_ignore 진단의 메시지에서 따옴표 안의 코드 이름만 뽑아 센다 (프로젝트의 줄).
/// 메시지는 `consumer.analyze` 가 남기지 않으므로 같은 상태를 한 번 더 분석하지 않고,
/// 진단의 자리에 있는 주석을 복사본에서 다시 읽어 코드 이름을 센다.
Future<Map<String, Map<String, int>>> unnecessaryIgnoreNames(String work, List<String> ids) async {
  // I2 · I4 는 주석을 걷어내지 않은 회차라 원본의 소스와 같다 — 원본에서 다시 복사해 읽는다.
  consumer.refreshSources();
  final out = <String, Map<String, int>>{};
  for (final id in ids) {
    final counts = <String, int>{};
    final lines = File('$work/private/$id.txt').readAsLinesSync();
    for (final l in lines) {
      final m = RegExp(r'^(\S+):(\d+)  \S+  (unnecessary_ignore\S*)$').firstMatch(l);
      if (m == null || m.group(1)!.startsWith(Diag.markerDir)) continue;
      final file = File('${consumer.dir}/${m.group(1)}');
      if (!file.existsSync()) continue;
      final src = file.readAsLinesSync();
      final lineNo = int.parse(m.group(2)!);
      // 줄 단위 주석은 그 줄이나 바로 위 줄에 있다
      String? found;
      for (final i in [lineNo - 1, lineNo - 2]) {
        if (i < 0 || i >= src.length) continue;
        final im = ignorePattern.firstMatch(src[i]);
        if (im != null) {
          // 코드 이름만 — 주석 뒤에 붙은 설명 글은 남기지 않는다
          final codes = im.group(2)!.split(',').map((c) => c.trim().split(RegExp(r'\s')).first).where((c) => c.isNotEmpty);
          found = '${im.group(1)}:${codes.join(',')}';
          break;
        }
      }
      counts.update(found ?? '(찾지 못함)', (v) => v + 1, ifAbsent: () => 1);
    }
    out[id] = counts;
  }
  return out;
}
