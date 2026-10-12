// Spike 021 — Dart 3.13 의 새 규칙과 strict 계열이 언어 버전 3.11 프로젝트에서 보고되는가.
//
// 1부 (연습용 패키지, 저장소 밖): 같은 표식을 SDK 하한 `^3.11.1` · `^3.13.0` 패키지에 두고
//   새 규칙 10개 + `strict-inference` 를 켜 분석한다. 3.13 문법(primary constructor)으로만
//   쓸 수 있는 표식은 따로 둔다. 한 파일에 `// @dart=3.11` 을 단 칸도 본다.
// 2부 (사용 프로젝트의 복사본): `flutter_starter_kit` 의 복사본을 작업 중인 저장소에 물려
//   B0 원본 옵션 + 기본 표식, B1 새 규칙 + strict-inference + 새 규칙 표식 (하한 원본 ^3.11.1),
//   B2 B1 과 같되 복사본의 하한만 ^3.13.0 (+ 3.13 문법 표식) 을 분석한다.
//
// 실행 (저장소 루트에서):
//   fvm dart .planning/spikes/021-new-rules-language-gate/probe.dart <작업 폴더> <사용 프로젝트 원본>
//
// 작업 폴더는 저장소 밖에 둔다. 원본은 읽기만 한다. 결과 파일에는 사용 프로젝트의 경로 ·
// 진단 메시지 · 코드 조각을 남기지 않는다 (줄 단위 기록은 <작업 폴더>/private/).
import 'dart:convert';
import 'dart:io';

import 'consumer.dart';

/// 새 규칙 10개 (SDK 3.13.0 CHANGELOG 의 Linter 절 + `no_raw_types` · `no_dynamic_casts`).
const newRules = [
  'async_return_with_no_await',
  'empty_container_bodies',
  'initialize_in_field_declaration',
  'unnecessary_const_in_enum_constructor',
  'unnecessary_primary_constructor_body',
  'unnecessary_type_name_in_constructor',
  'use_declaring_parameters',
  'use_primary_constructors',
  'no_raw_types',
  'no_dynamic_casts',
];

/// 규칙 소스(tag 3.13.4)를 읽어 세운 추정. 실행 결과와 다를 수 있다 — 판정에 넣지 않고 `=` / `≠` 로 견준다.
///   gate   — `registerNodeProcessors` 첫머리에서 `Feature.primary_constructors` 가 꺼져 있으면 돌아간다
///   syntax — 막는 조건은 없지만 primary constructor 문법이 있어야만 걸린다
///   open   — 막는 조건이 없다
const guess = {
  'async_return_with_no_await': 'open',
  'empty_container_bodies': 'gate',
  'initialize_in_field_declaration': 'gate',
  'unnecessary_const_in_enum_constructor': 'gate',
  'unnecessary_primary_constructor_body': 'syntax',
  'unnecessary_type_name_in_constructor': 'gate',
  'use_declaring_parameters': 'gate',
  'use_primary_constructors': 'gate',
  'no_raw_types': 'open',
  'no_dynamic_casts': 'open',
  'strict-inference': 'open',
};

/// 3.11 문법으로 쓸 수 있는 표식 — 파일 이름이 겨냥한 규칙이다 (다른 규칙도 걸릴 수 있다).
const oldSamples = {
  'async_return_with_no_await.dart': '''
/// 표식 — async 함수가 Future 를 await 없이 돌려준다.
Future<String> asyncReturnMarker(Future<String> value) async {
  return value;
}
''',
  'empty_container_bodies.dart': '''
/// 표식 — 몸통이 빈 클래스.
class EmptyBodyMarker {}
''',
  'unnecessary_const_in_enum_constructor.dart': '''
/// 표식 — enum 생성자의 const.
enum ConstEnumMarker {
  /// a.
  a(1),

  /// b.
  b(2);

  const ConstEnumMarker(this.i);

  /// 값.
  final int i;
}
''',
  'unnecessary_type_name_in_constructor.dart': '''
/// 표식 — 생성자 선언에 적은 타입 이름.
class TypeNameMarker {
  /// 기본 생성자.
  TypeNameMarker();

  /// 이름 있는 생성자.
  TypeNameMarker.named();
}
''',
  'use_primary_constructors.dart': '''
/// 표식 — 생성자 하나와 필드로 된 클래스.
class PointMarker {
  /// 생성자.
  PointMarker(this.x, this.y);

  /// x.
  final int x;

  /// y.
  final int y;
}
''',
  'no_raw_types.dart': '''
/// 표식 — 타입 인자를 생략한 제네릭 타입.
class BoxMarker<T> {}

/// 타입 인자 없이 선언한 변수.
BoxMarker rawBoxMarker = BoxMarker<int>();
''',
  'no_dynamic_casts.dart': '''
/// 표식 — dynamic 에서의 암묵적 cast.
int dynamicCastMarker(dynamic x) {
  final int y = x;
  return y;
}
''',
  'strict_inference.dart': '''
/// 표식 — 추론이 실패해 dynamic 이 되는 자리 (strict-inference).
List<Object?> strictInferenceMarker() {
  final empty = [];
  return empty;
}
''',
};

/// 3.13 문법(primary constructor)으로만 쓸 수 있는 표식. 상류 문서의 예시를 옮겼다.
const newSyntaxSamples = {
  'initialize_in_field_declaration.dart': '''
/// 표식 — primary constructor 의 초기화 목록.
class InitInFieldMarker(int x) {
  this : y = x;

  /// y.
  int y;
}
''',
  'unnecessary_const_in_enum_constructor_primary.dart': '''
/// 표식 — enum primary constructor 의 const.
enum const ConstEnumPrimaryMarker(final int i) {
  /// a.
  a(1),

  /// b.
  b(2);
}
''',
  'unnecessary_primary_constructor_body.dart': '''
/// 표식 — 빈 primary constructor 몸통.
class BodyMarker(final int i) {
  this;
}
''',
  'use_declaring_parameters.dart': '''
/// 표식 — 선언 매개변수로 쓸 수 있는 매개변수.
class DeclaringMarker(int i) {
  /// i.
  final int i;

  this : i = i;
}
''',
};

const controlSample = {
  'control_avoid_print.dart': '''
/// 대조 — 오래된 규칙(avoid_print)은 언어 버전과 상관없이 걸린다.
void printMarker() {
  print('marker');
}
''',
};

late final String spikeDir;
late final Repo repo;
late final String work;

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln('사용법: fvm dart <이 스크립트> <작업 폴더 — 저장소 밖> <사용 프로젝트 원본>');
    exit(64);
  }
  spikeDir = File.fromUri(Platform.script).parent.path;
  repo = Repo.fromSpikeDir(spikeDir);
  work = Directory(args[0]).absolute.path;
  final source = Directory(args[1]).resolveSymbolicLinksSync();
  if (work.startsWith(repo.root) || work.startsWith(source)) {
    stderr.writeln('작업 폴더는 저장소와 원본 밖에 둔다');
    exit(64);
  }
  final repoBefore = await repo.fingerprint();
  final consumer = Consumer(work: work, repo: repo, source: source);

  final log = StringBuffer();
  void say(String line) {
    stdout.writeln(consumer.scrubText(line));
    log.writeln(consumer.scrubText(line));
  }

  final dartVersion = Platform.version.split(' ').first;
  say('# Spike 021 — 새 규칙과 언어 버전');
  say('SDK: $dartVersion');
  say('');

  // 1부 ------------------------------------------------------------------
  say('## 1부 — 연습용 패키지 (규칙 10 + strict-inference + avoid_print)');
  final partA = <String, Map<String, List<String>>>{};
  final partAExit = <String, int>{};
  Future<void> fixture(String id, String constraint, Map<String, String> files) async {
    final result = await analyzeFixture(id, constraint, files);
    partA[id] = result.byFile;
    partAExit[id] = result.exitCode;
    say('- $id (sdk $constraint): exit ${result.exitCode}, ${result.elapsedMs} ms, 진단 ${result.count}건');
  }

  await fixture('p311old', '^3.11.1', {...oldSamples, ...controlSample});
  await fixture('p313old', '^3.13.0', {
    ...oldSamples,
    ...controlSample,
    'at311/empty_container_bodies.dart': '// @dart=3.11\n${oldSamples['empty_container_bodies.dart']}',
  });
  await fixture('p313new', '^3.13.0', newSyntaxSamples);
  await fixture('p311new', '^3.11.1', newSyntaxSamples);
  say('');

  say('### 파일마다 나온 진단 코드');
  say('| 표식 파일 | 3.11 (`^3.11.1`) | 3.13 (`^3.13.0`) |');
  say('|---|---|---|');
  String codes(List<String>? list) => list == null || list.isEmpty ? '—' : list.join(', ');
  for (final f in [...oldSamples.keys, ...controlSample.keys]) {
    say('| `$f` | ${codes(partA['p311old']![f])} | ${codes(partA['p313old']![f])} |');
  }
  say('| `at311/empty_container_bodies.dart` (`// @dart=3.11`) | — | ${codes(partA['p313old']!['at311/empty_container_bodies.dart'])} |');
  for (final f in newSyntaxSamples.keys) {
    say('| `$f` (3.13 문법) | ${codes(partA['p311new']![f])} | ${codes(partA['p313new']![f])} |');
  }
  say('');

  bool firesIn(String id, String rule) => partA[id]!.entries
      .where((e) => !e.key.startsWith('at311/'))
      .any((e) => e.value.any((c) => rule == 'strict-inference' ? c.startsWith('inference_failure_') : c == rule));
  final observed = <String, Map<String, Object>>{};
  say('### 규칙마다 — 3.11 에서 보고되는가 (소스를 읽은 추정과 견줌)');
  say('| 규칙 | 추정 | 3.11 | 3.13 | 견줌 |');
  say('|---|---|---|---|---|');
  for (final rule in [...newRules, 'strict-inference']) {
    final at311 = firesIn('p311old', rule) || firesIn('p311new', rule);
    final at313 = firesIn('p313old', rule) || firesIn('p313new', rule);
    final g = guess[rule]!;
    final expected311 = g == 'open';
    final match = at311 == expected311 && at313;
    observed[rule] = {'guess': g, 'at311': at311, 'at313': at313, 'matchesGuess': match};
    say('| `$rule` | $g | ${at311 ? '보고' : '없음'} | ${at313 ? '보고' : '없음'} | ${match ? '=' : '≠'} |');
  }
  final syntaxErrors311 = partA['p311new']!.values.expand((c) => c).where((c) => !newRules.contains(c)).toSet();
  say('- 3.13 문법 표식을 `^3.11.1` 에서 분석했을 때 나온 다른 코드: ${syntaxErrors311.toList()..sort()}');
  say('');

  // 2부 ------------------------------------------------------------------
  say('## 2부 — 사용 프로젝트의 복사본');
  consumer.copy();
  await consumer.pointToRepo();
  final facts = consumerFacts(consumer);
  say('- 복사한 파일 ${consumer.copiedFiles}개, Dart 파일 ${facts['dartFiles']}, SDK 제약 ${facts['sdk']}');
  say('- woody_lints 를 받은 자리: ${consumer.woodySource()}');
  final shots = <Shot>[];
  Future<Shot> shoot(String id) async {
    final s = await consumer.analyze(id);
    consumer.ensureRepoSource(s);
    shots.add(s);
    say('- $id: exit ${s.exitCode}, ${s.elapsedMs} ms, 줄 ${s.diags.length} (표식 ${s.marker.length} · 프로젝트 ${s.project.length}), '
        'plugin 폴더 ${s.pluginFolders} · riverpod_lint ${s.pluginVersion}${s.pluginHeader ? ' · **plugin 실패 머리말**' : ''}');
    return s;
  }

  final oldMarkerFiles = {for (final e in oldSamples.entries) 'new_rules/${e.key}': e.value};
  final newMarkerFiles = {for (final e in newSyntaxSamples.entries) 'new_rules_313/${e.key}': e.value};
  consumer.addExampleMarkers();

  // B0 — 원본 옵션 그대로 (019 의 V2 와 같은 모양, 이번에는 작업 중인 저장소를 받는다)
  consumer.setOptions(consumer.originalOptions);
  final b0 = await shoot('B0');

  // B1 — 새 규칙 + strict-inference, 하한은 원본(^3.11.1)
  consumer.addMarkers(oldMarkerFiles);
  consumer.setOptions(consumer.optionsWith(rules: newRules, language: {'strict-inference': true}));
  final b1 = await shoot('B1');

  // B2 — 같은 옵션, 복사본의 하한만 ^3.13.0. 3.13 문법 표식을 더한다.
  consumer.setPubspec(consumer.pubspecWithSdk('^3.13.0'));
  await consumer.pubGet();
  consumer.addMarkers(newMarkerFiles);
  final b2 = await shoot('B2');

  // 되돌린다 (복사본이지만 다음 spike 가 같은 함수를 쓴다)
  consumer.removeMarkers([...oldMarkerFiles.keys, ...newMarkerFiles.keys]);
  consumer.setOptions(consumer.originalOptions);
  consumer.setPubspec(consumer.originalPubspec);
  say('');

  bool isTarget(String code) => newRules.contains(code) || code.startsWith('inference_failure_');
  final expected = expectedLines('${repo.root}/example/expected_diagnostics.txt')
      .map((l) => l.replaceFirst('lib/', Diag.markerDir))
      .toList()
    ..sort();
  final b0Marker = b0.marker.map((d) => d.text).toList()..sort();

  say('### 규칙마다 — 표식 · 프로젝트의 줄 (B1 = 하한 3.11, B2 = 하한 3.13)');
  say('| 규칙 | B1 표식 | B1 프로젝트 | B2 표식 | B2 프로젝트 |');
  say('|---|---|---|---|---|');
  int count(Shot s, Iterable<Diag> ds, String rule) => ds
      .where((d) => rule == 'strict-inference' ? d.code.startsWith('inference_failure_') : d.code == rule)
      .length;
  final perRule = <String, Map<String, int>>{};
  for (final rule in [...newRules, 'strict-inference']) {
    final row = {
      'B1marker': count(b1, b1.marker, rule),
      'B1project': count(b1, b1.project, rule),
      'B2marker': count(b2, b2.marker, rule),
      'B2project': count(b2, b2.project, rule),
    };
    perRule[rule] = row;
    say('| `$rule` | ${row['B1marker']} | ${row['B1project']} | ${row['B2marker']} | ${row['B2project']} |');
  }
  final b2ProjectByArea = <String, Map<String, int>>{};
  for (final d in b2.project.where((d) => isTarget(d.code))) {
    b2ProjectByArea.putIfAbsent(d.code, () => {}).update(d.area, (v) => v + 1, ifAbsent: () => 1);
  }
  say('- B2 프로젝트의 줄을 자리별로: $b2ProjectByArea');
  final strictCodes = <String, int>{};
  for (final d in [...b1.diags, ...b2.diags].where((d) => d.code.startsWith('inference_failure_'))) {
    strictCodes.update(d.code, (v) => v + 1, ifAbsent: () => 1);
  }
  say('- strict-inference 의 코드 (B1 + B2): $strictCodes');

  // 하한을 올린 것만으로 다른 규칙의 줄이 달라졌는가 (대상 규칙 밖, 프로젝트의 줄)
  Map<String, int> others(Shot s) {
    final out = <String, int>{};
    for (final d in s.project.where((d) => !isTarget(d.code))) {
      out.update(d.code, (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }

  final o1 = others(b1);
  final o2 = others(b2);
  say('- 대상 밖 규칙의 프로젝트 줄: B0 ${others(b0)}, B1 $o1, B2 $o2');
  final otherMarkerB1 = b1.marker.where((d) => !isTarget(d.code) && d.path.contains('/new_rules/')).map((d) => d.code).toList()..sort();
  say('- 새 규칙 표식에 걸린 대상 밖 규칙 (B1): $otherMarkerB1');
  say('');

  final repoAfter = await repo.fingerprint();
  final checks = <String, bool>{
    'K1 대조: avoid_print 가 두 하한의 연습용 패키지에서 걸린다': (partA['p311old']!['control_avoid_print.dart'] ?? []).contains('avoid_print') &&
        (partA['p313old']!['control_avoid_print.dart'] ?? []).contains('avoid_print'),
    'K2 대조: 3.13 패키지에서 empty_container_bodies 표식이 걸린다 (표식이 유효하다)':
        (partA['p313old']!['empty_container_bodies.dart'] ?? []).contains('empty_container_bodies'),
    'K3 복사본의 woody_lints 가 모든 회차에서 작업 중인 저장소를 가리킨다': shots.every((s) => s.woodySource == 'repo'),
    'K4 B0 의 표식 줄이 example 정답지 ${expected.length}줄과 같다': const ListEquality().equals(b0Marker, expected),
    'K5 모든 회차에서 plugin 이 준비됐다 (폴더 1, 실패 머리말 없음)': shots.every((s) => s.pluginFolders == 1 && !s.pluginHeader),
    'K6 B1 에서 막는 조건이 없는 규칙의 표식이 걸린다 (async_return_with_no_await)': count(b1, b1.marker, 'async_return_with_no_await') > 0,
    'K7 저장소가 그대로다 (git status · .dart_tool · package_config · pubspec.lock)': repoAfter == repoBefore,
  };
  say('# 판정');
  say('| 확인 | 결과 |');
  say('|---|---|');
  for (final e in checks.entries) {
    say('| ${e.key} | ${e.value ? '성립' : '**깨짐**'} |');
  }
  final ok = checks.values.every((v) => v);
  final mismatches = observed.entries.where((e) => e.value['matchesGuess'] != true).map((e) => e.key).toList();
  say('');
  say(ok ? '판정에 넣은 확인 ${checks.length}건이 모두 성립했다.' : '성립하지 않은 확인이 있다.');
  say('소스를 읽은 추정과 다른 규칙: ${mismatches.isEmpty ? '없음' : mismatches}');

  final results = Directory('$spikeDir/results')..createSync(recursive: true);
  File('${results.path}/probe-$dartVersion.json').writeAsStringSync(consumer.scrubText(const JsonEncoder.withIndent('  ').convert({
    'date': DateTime.now().toUtc().toIso8601String(),
    'dart': dartVersion,
    'partA': {'exitCodes': partAExit, 'byFile': partA},
    'observed': observed,
    'consumerFacts': facts,
    'shots': shots.map((s) => s.toJson()).toList(),
    'perRule': perRule,
    'b2ProjectByArea': b2ProjectByArea,
    'strictCodes': strictCodes,
    'otherRulesProject': {'B0': others(b0), 'B1': o1, 'B2': o2},
    'checks': checks,
  })));
  File('${results.path}/probe-$dartVersion.log').writeAsStringSync(log.toString());
  exit(ok ? 0 : 1);
}

/// 사용 프로젝트에 관한 수와 설정값만 (019 의 `facts` 를 줄였다).
Map<String, Object> consumerFacts(Consumer c) {
  var dartFiles = 0;
  for (final name in ['lib', 'test', 'bin']) {
    final d = Directory('${c.dir}/$name');
    if (!d.existsSync()) continue;
    dartFiles += d.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).length;
  }
  final sdk = RegExp(r'\n  sdk: (\S+)\n').firstMatch(c.originalPubspec)?.group(1) ?? '?';
  return {'dartFiles': dartFiles, 'sdk': sdk};
}

class FixtureResult {
  int exitCode = -1;
  int elapsedMs = 0;
  int count = 0;
  final byFile = <String, List<String>>{};
}

/// 저장소 밖에 순수 Dart 패키지를 만들고 분석한다 (의존성 없음).
Future<FixtureResult> analyzeFixture(String id, String constraint, Map<String, String> files) async {
  final dir = Directory('$work/fixtures/$id');
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  Directory('${dir.path}/lib').createSync(recursive: true);
  File('${dir.path}/pubspec.yaml')
      .writeAsStringSync('name: spike_language_gate\npublish_to: none\nenvironment:\n  sdk: $constraint\n');
  File('${dir.path}/analysis_options.yaml').writeAsStringSync([
    'analyzer:',
    '  language:',
    '    strict-inference: true',
    'linter:',
    '  rules:',
    ...[...newRules, 'avoid_print'].map((r) => '    - $r'),
    '',
  ].join('\n'));
  for (final e in files.entries) {
    final f = File('${dir.path}/lib/${e.key}');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(e.value);
  }
  final dart = Platform.resolvedExecutable;
  final pub = await Process.run(dart, ['--suppress-analytics', 'pub', 'get'], workingDirectory: dir.path);
  if (pub.exitCode != 0) {
    stderr.writeln('pub get 실패 ($id)');
    exit(69);
  }
  final state = Directory('$work/state/$id');
  if (state.existsSync()) state.deleteSync(recursive: true);
  state.createSync(recursive: true);
  final result = FixtureResult();
  final watch = Stopwatch()..start();
  final r = await Process.run(dart, ['--suppress-analytics', 'analyze', '--format=json'],
      workingDirectory: dir.path, environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path});
  result.elapsedMs = watch.elapsedMilliseconds;
  result.exitCode = r.exitCode;
  final jsonLine = '${r.stdout}'.split('\n').lastWhere((l) => l.startsWith('{'), orElse: () => '');
  if (jsonLine.isEmpty) return result;
  for (final d in ((jsonDecode(jsonLine) as Map)['diagnostics'] as List).cast<Map<String, dynamic>>()) {
    var file = '${(d['location'] as Map)['file']}';
    final prefix = '${dir.path}/lib/';
    if (!file.startsWith(prefix)) continue;
    file = file.substring(prefix.length);
    result.byFile.putIfAbsent(file, () => []).add('${d['code']}');
    result.count++;
  }
  for (final v in result.byFile.values) {
    v.sort();
  }
  return result;
}

/// 목록이 같은지 (순서까지).
class ListEquality {
  const ListEquality();
  bool equals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
