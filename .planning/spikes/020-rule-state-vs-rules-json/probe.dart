// Spike 020 — Phase 4 평가표의 `state` · `incompatible` · 상류 세트 열을 SDK tag 의
// `rules.json` 에서 옮겨도 되는가.
//
// 세 출처를 견준다.
//   1. `pkg/linter/tool/machine/rules.json` (SDK tag 3.13.4) — 로드맵이 적은 출처
//   2. `pkg/linter/messages.yaml` (같은 tag) — 규칙 소스가 생성되는 원본
//   3. 실제 분석 — 규칙 이름 전부를 옵션 파일에 적은 패키지를 Dart 3.13.4 로 분석한다
//      (SDK 하한 `^3.13.0` 과 `^3.11.1` 두 벌. deprecated / removed 는 하한에 따라 보고된다 — 005)
// 상류 세트(core / recommended / flutter)는 저장소 루트가 받은 `lints` · `flutter_lints` 의
// YAML 을 읽어 견준다.
//
// 실행 (저장소 루트에서):
//   fvm dart .planning/spikes/020-rule-state-vs-rules-json/probe.dart <작업 폴더>
//
// 작업 폴더는 저장소 밖에 둔다. 상류 파일을 받아 `<작업 폴더>/upstream/` 에 두고,
// 분석할 패키지 둘을 `<작업 폴더>/pkg13`, `<작업 폴더>/pkg11` 에 만든다.
// 저장소의 파일은 읽기만 한다. 결과는 spike 폴더의 `results/` 에 쓴다.
import 'dart:convert';
import 'dart:io';

const sdkTag = '3.13.4';
const upstreamBase = 'https://raw.githubusercontent.com/dart-lang/sdk/$sdkTag/pkg/linter';
const upstreamFiles = {
  'rules.json': '$upstreamBase/tool/machine/rules.json',
  'messages.yaml': '$upstreamBase/messages.yaml',
  'machine-README.md': '$upstreamBase/tool/machine/README.md',
};

/// 분석이 제대로 돌았는지 가르는 대조 — 결과가 알려진 이름 셋.
const controlUndefined = 'no_such_rule_zz9';
const controlDeprecated = 'unnecessary_await_in_return'; // 3.13 deprecated (005)
const controlRemoved = 'avoid_returning_null'; // 3.3 removed (005)

late final String repoRoot;
late final String spikeDir;
late final String work;

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln('사용법: fvm dart <이 스크립트> <작업 폴더 — 저장소 밖>');
    exit(64);
  }
  spikeDir = File.fromUri(Platform.script).parent.path;
  repoRoot = Directory('$spikeDir/../../..').resolveSymbolicLinksSync();
  work = Directory(args[0]).absolute.path;
  if (work.startsWith(repoRoot)) {
    stderr.writeln('작업 폴더는 저장소 밖에 둔다: ${scrub(work)}');
    exit(64);
  }
  final repoBefore = await repoFingerprint();

  final log = StringBuffer();
  void say(String line) {
    stdout.writeln(line);
    log.writeln(line);
  }

  say('# Spike 020 — rules.json 의 state 와 실제 상태');
  say('SDK: ${Platform.version.split(' ').first}');
  say('');

  // 1. 상류 파일
  final upstream = <String, Map<String, Object>>{};
  for (final entry in upstreamFiles.entries) {
    final file = File('$work/upstream/${entry.key}');
    if (!file.existsSync()) {
      file.parent.createSync(recursive: true);
      await download(entry.value, file);
    }
    final bytes = file.readAsBytesSync();
    upstream[entry.key] = {'url': entry.value, 'bytes': bytes.length, 'fnv64': digest(bytes)};
  }
  final readme = File('$work/upstream/machine-README.md').readAsStringSync();
  final readmeWarns = readme.contains('unsupported and deprecated');
  say('## 상류 파일 (tag $sdkTag)');
  for (final e in upstream.entries) {
    say('- ${e.key}: ${e.value['bytes']} bytes, fnv64 ${e.value['fnv64']}');
  }
  say('- machine/README.md 에 "unsupported and deprecated" 문구: ${readmeWarns ? '있다' : '없다'}');
  say('');

  // 2. 두 메타데이터 출처
  final json = readRulesJson('$work/upstream/rules.json');
  final messages = readMessagesYaml('$work/upstream/messages.yaml');
  final names = {...json.keys, ...messages.keys}.toList()..sort();

  // 3. 상류 세트 (저장소 루트가 받은 버전)
  final sets = readUpstreamSets();
  say('## 상류 세트 (저장소 루트의 package_config)');
  for (final e in sets.sources.entries) {
    say('- ${e.key}: ${e.value}');
  }
  say('- 규칙 수: core ${sets.core.length}, recommended(직접) ${sets.recommended.length}, flutter(직접) ${sets.flutter.length}');
  say('');

  // 4. 실제 분석 — 하한 두 벌
  final listed = [...names, controlUndefined];
  final actual13 = await analyzeAll('pkg13', '^3.13.0', listed);
  final actual11 = await analyzeAll('pkg11', '^3.11.1', listed);

  // 5. 견주기
  final rows = <Map<String, Object?>>[];
  for (final name in names) {
    final j = json[name];
    final m = messages[name];
    rows.add({
      'name': name,
      'json': j?.state,
      'messages': m?.latest,
      'messagesStates': m?.states,
      'messagesConsistent': m?.consistent,
      'actual13': actual13.byRule[name] ?? const <String>[],
      'actual11': actual11.byRule[name] ?? const <String>[],
      'jsonIncompatible': j?.incompatible ?? const <String>[],
      'jsonSets': j?.sets ?? const <String>[],
      'jsonFixStatus': j?.fixStatus,
      'jsonSince': j?.since,
      'upstreamSet': sets.of(name),
    });
  }

  String actualState(List<String> codes) {
    if (codes.contains('undefined_lint')) return 'undefined';
    if (codes.contains('removed_lint')) return 'removed';
    if (codes.contains('deprecated_lint')) return 'deprecated';
    return 'stable-or-experimental';
  }

  bool agrees(String? meta, String actual) {
    if (meta == null) return actual == 'undefined';
    if (actual == 'stable-or-experimental') return meta == 'stable' || meta == 'experimental';
    return meta == actual;
  }

  final jsonMismatch = <String>[];
  final messagesMismatch = <String>[];
  final jsonVsMessages = <String>[];
  for (final r in rows) {
    final name = r['name'] as String;
    final a = actualState(r['actual13'] as List<String>);
    r['actualState13'] = a;
    r['actualState11'] = actualState(r['actual11'] as List<String>);
    if (!agrees(r['json'] as String?, a)) jsonMismatch.add(name);
    if (!agrees(r['messages'] as String?, a)) messagesMismatch.add(name);
    if (r['json'] != r['messages']) jsonVsMessages.add(name);
  }

  say('## 규칙 이름');
  say('- rules.json ${json.length}개, messages.yaml ${messages.length}개, 합집합 ${names.length}개');
  say('- rules.json 에만: ${json.keys.where((n) => !messages.containsKey(n)).toList()}');
  say('- messages.yaml 에만: ${messages.keys.where((n) => !json.containsKey(n)).toList()}');
  say('- messages.yaml 에서 같은 규칙의 코드끼리 state 가 다른 것: '
      '${messages.entries.where((e) => !e.value.consistent).map((e) => e.key).toList()}');
  say('');

  say('## 분석 (Dart ${Platform.version.split(' ').first})');
  for (final a in [actual13, actual11]) {
    say('- ${a.label} (sdk ${a.constraint}): exit ${a.exitCode}, 진단 ${a.diagnostics.length}건, '
        '${a.elapsedMs} ms, 코드별 ${a.countByCode()}');
    if (a.unmapped.isNotEmpty) say('  - 규칙 줄에 대응하지 않은 진단: ${a.unmapped}');
  }
  say('');

  say('## state — rules.json · messages.yaml · 실제 (하한 ^3.13.0)');
  say('| 규칙 | rules.json | messages.yaml | 실제 ^3.13.0 | 실제 ^3.11.1 |');
  say('|---|---|---|---|---|');
  for (final r in rows) {
    final name = r['name'] as String;
    if (r['json'] == 'stable' && r['messages'] == 'stable' && r['actualState13'] == 'stable-or-experimental') {
      continue; // 셋이 모두 stable 인 줄은 표에서 뺀다 (결과 파일에는 있다)
    }
    say('| `$name` | ${r['json'] ?? '—'} | ${r['messages'] ?? '—'} | ${r['actualState13']} | ${r['actualState11']} |');
  }
  say('');
  say('- 실제와 어긋난 rules.json: ${jsonMismatch.length}개 $jsonMismatch');
  say('- 실제와 어긋난 messages.yaml: ${messagesMismatch.length}개 $messagesMismatch');
  say('- rules.json ≠ messages.yaml: ${jsonVsMessages.length}개 $jsonVsMessages');
  say('');

  // incompatible
  final declared = <String>{};
  for (final r in rows) {
    for (final other in r['jsonIncompatible'] as List<String>) {
      final pair = ([r['name'] as String, other]..sort()).join(' × ');
      declared.add(pair);
    }
  }
  final reported = actual13.incompatiblePairs;
  say('## incompatible — rules.json 의 선언과 실제 `incompatible_lint`');
  say('- rules.json 이 선언한 쌍 ${declared.length}개, 전부 켠 실행에서 보고된 쌍 ${reported.length}개');
  say('- 선언됐는데 전부 켠 실행에서 보고되지 않은 쌍: ${(declared.difference(reported).toList()..sort())}');
  say('- 보고됐는데 선언되지 않은 쌍: ${(reported.difference(declared).toList()..sort())}');
  // 규칙 한 줄에는 incompatible_lint 가 하나만 붙는 것으로 보인다 (첫 실행). 쌍마다 둘만 켠
  // 패키지로 다시 본다 — 선언된 쌍이 실제로 보고되는지를 가른다.
  final pairResults = <String, List<String>>{};
  var pairIndex = 0;
  for (final pair in (declared.toList()..sort())) {
    final two = pair.split(' × ');
    final a = await analyzeAll('pair${pairIndex++}', '^3.13.0', two);
    pairResults[pair] = a.diagnostics.map((d) => '${d['line']} ${d['code']}').toList();
  }
  final pairReported = pairResults.entries
      .where((e) => e.value.any((v) => v.endsWith('incompatible_lint')))
      .map((e) => e.key)
      .toSet();
  say('- 쌍마다 둘만 켠 실행에서 보고된 쌍: ${pairReported.length}개 / ${declared.length}개');
  for (final e in pairResults.entries) {
    say('  - ${e.key}: ${e.value.isEmpty ? '진단 없음' : e.value.join(', ')}');
  }
  final perLine = <int, int>{};
  for (final d in actual13.diagnostics.where((d) => d['code'] == 'incompatible_lint')) {
    perLine.update(d['line'] as int, (v) => v + 1, ifAbsent: () => 1);
  }
  say('- 전부 켠 실행에서 한 줄에 붙은 incompatible_lint 의 최대 수: '
      '${perLine.values.fold<int>(0, (m, v) => v > m ? v : m)}');
  say('');

  // 상류 세트
  final jsonSetsNonEmpty = rows.where((r) => (r['jsonSets'] as List).isNotEmpty).length;
  final inUpstream = rows.where((r) => r['upstreamSet'] != null).toList();
  say('## 상류 세트 — rules.json 의 `sets` 와 실제 YAML');
  say('- rules.json 에서 `sets` 가 비어 있지 않은 규칙: $jsonSetsNonEmpty개');
  say('- 실제 YAML 에 든 규칙: ${inUpstream.length}개 '
      '(core ${sets.core.length} / recommended ${sets.recommended.length} / flutter ${sets.flutter.length})');
  final upstreamNotInNames =
      sets.all.where((n) => !names.contains(n.toLowerCase())).toList()..sort();
  say('- 상류 YAML 에 있는데 두 메타데이터 어디에도 없는 이름: $upstreamNotInNames');
  final upstreamBad = inUpstream
      .where((r) => r['actualState13'] != 'stable-or-experimental' || r['messages'] != 'stable')
      .map((r) => '${r['name']}(${r['messages']}, ${r['actualState13']})')
      .toList();
  say('- 상류 세트에 든 규칙 가운데 messages.yaml 이 stable 이 아니거나 실제로 경고가 나는 것: $upstreamBad');
  say('');

  // 판정
  final checks = <String, bool>{
    'K1 두 분석 모두 JSON 을 냈다': actual13.jsonOk && actual11.jsonOk,
    'K2 대조: $controlUndefined → undefined_lint (두 하한)':
        (actual13.byRule[controlUndefined] ?? []).contains('undefined_lint') &&
            (actual11.byRule[controlUndefined] ?? []).contains('undefined_lint'),
    'K3 대조: $controlDeprecated → ^3.13.0 에서 deprecated_lint, ^3.11.1 에서 없음':
        (actual13.byRule[controlDeprecated] ?? []).contains('deprecated_lint') &&
            !(actual11.byRule[controlDeprecated] ?? []).contains('deprecated_lint'),
    'K4 대조: $controlRemoved → removed_lint (두 하한)':
        (actual13.byRule[controlRemoved] ?? []).contains('removed_lint') &&
            (actual11.byRule[controlRemoved] ?? []).contains('removed_lint'),
    'K5 옵션 파일 밖의 진단이 없다 (패키지의 lib 는 깨끗하다)':
        actual13.outsideOptions == 0 && actual11.outsideOptions == 0,
    'K6 저장소가 그대로다 (git status · 루트 package_config)': await repoFingerprint() == repoBefore,
    'K7 대조: 쌍마다 둘만 켠 실행에서 prefer_single_quotes × prefer_double_quotes 가 보고된다':
        pairReported.contains('prefer_double_quotes × prefer_single_quotes'),
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
  File('${results.path}/probe-${Platform.version.split(' ').first}.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(scrubJson({
    'date': DateTime.now().toUtc().toIso8601String(),
    'dart': Platform.version.split(' ').first,
    'upstream': upstream,
    'readmeWarnsUnsupported': readmeWarns,
    'upstreamSets': sets.sources,
    'analyses': [actual13.toJson(), actual11.toJson()],
    'jsonMismatch': jsonMismatch,
    'messagesMismatch': messagesMismatch,
    'jsonVsMessages': jsonVsMessages,
    'incompatibleDeclared': (declared.toList()..sort()),
    'incompatibleReported': (reported.toList()..sort()),
    'incompatiblePairwise': pairResults,
    'checks': checks,
    'rules': rows,
  })));
  File('${results.path}/probe-${Platform.version.split(' ').first}.log').writeAsStringSync(scrub(log.toString()));
  exit(ok ? 0 : 1);
}

// 상류 파일 받기 ------------------------------------------------------------

Future<void> download(String url, File to) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      stderr.writeln('받지 못했다 ($url): HTTP ${response.statusCode}');
      exit(69);
    }
    await response.pipe(to.openWrite());
  } finally {
    client.close();
  }
}

// rules.json -------------------------------------------------------------

class JsonRule {
  JsonRule(this.state, this.incompatible, this.sets, this.fixStatus, this.since);
  final String state;
  final List<String> incompatible;
  final List<String> sets;
  final String fixStatus;
  final String since;
}

Map<String, JsonRule> readRulesJson(String path) {
  final list = jsonDecode(File(path).readAsStringSync()) as List;
  return {
    for (final r in list.cast<Map<String, dynamic>>())
      r['name'] as String: JsonRule(
        r['state'] as String,
        (r['incompatible'] as List).cast<String>(),
        (r['sets'] as List).cast<String>(),
        '${r['fixStatus']}',
        '${r['sinceDartSdk']}',
      ),
  };
}

// messages.yaml ----------------------------------------------------------

class MessagesRule {
  final List<Map<String, String>> states = [];

  /// 같은 규칙(같은 sharedName)의 코드끼리 state 가 같은가.
  bool get consistent => states.every((s) => _same(s, states.first));

  /// 가장 늦은 버전에 붙은 상태. 같은 버전이면 removed > deprecated > stable > experimental.
  String get latest {
    const rank = {'experimental': 0, 'internal': 0, 'testing': 0, 'stable': 1, 'deprecated': 2, 'removed': 3};
    final s = states.first;
    var best = s.keys.first;
    for (final k in s.keys) {
      final c = compareVersion(s[k]!, s[best]!);
      if (c > 0 || (c == 0 && (rank[k] ?? 0) > (rank[best] ?? 0))) best = k;
    }
    return best;
  }

  static bool _same(Map<String, String> a, Map<String, String> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
}

/// `LinterLintCode:` 아래의 항목을 줄 단위로 읽는다. yaml 패키지를 쓰지 않으므로
/// 들여쓰기 2칸 = 코드 이름, 4칸 = 속성, 6칸 = state 의 항목이라는 모양에 기댄다.
Map<String, MessagesRule> readMessagesYaml(String path) {
  final lines = File(path).readAsLinesSync();
  final start = lines.indexOf('LinterLintCode:');
  if (start < 0) throw const FormatException('messages.yaml 에 LinterLintCode: 가 없다');
  final out = <String, MessagesRule>{};
  String? code;
  String? shared;
  Map<String, String>? state;
  var inState = false;
  final sharedWithoutState = <String>{};
  void flush() {
    if (code == null) return;
    final name = snake(shared ?? code!);
    if (state == null) {
      // 같은 sharedName 을 쓰는 코드는 그중 하나만 state 를 적는다 — 끝에서 짝이 있는지 본다.
      if (shared == null) throw FormatException('state 도 sharedName 도 없는 항목: $code');
      sharedWithoutState.add(name);
      return;
    }
    (out[name] ??= MessagesRule()).states.add(state!);
  }

  for (final line in lines.skip(start + 1)) {
    if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#')) break; // 다음 최상위 키
    final entry = RegExp(r'^  (\w+):\s*$').firstMatch(line);
    if (entry != null) {
      flush();
      code = entry.group(1);
      shared = null;
      state = null;
      inState = false;
      continue;
    }
    final sharedMatch = RegExp(r'^    sharedName: (\w+)\s*$').firstMatch(line);
    if (sharedMatch != null) shared = sharedMatch.group(1);
    if (RegExp(r'^    state:\s*$').hasMatch(line)) {
      inState = true;
      state = {};
      continue;
    }
    if (inState) {
      final s = RegExp(r'^      (\w+): "?([^"\s]+)"?\s*$').firstMatch(line);
      if (s != null) {
        state![s.group(1)!] = s.group(2)!;
        continue;
      }
      inState = false;
    }
  }
  flush();
  final orphans = sharedWithoutState.where((n) => !out.containsKey(n)).toList();
  if (orphans.isNotEmpty) throw FormatException('state 를 적은 짝이 없는 sharedName: $orphans');
  return out;
}

/// `linesLongerThan80Chars` → `lines_longer_than_80_chars`.
/// 첫 실행은 숫자 앞에 `_` 를 넣지 않아 `lines_longer_than80_chars` 를 만들었다.
String snake(String camel) => camel
    .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
    .replaceAllMapped(RegExp(r'([a-z])(\d+)'), (m) => '${m.group(1)}_${m.group(2)}');

int compareVersion(String a, String b) {
  final pa = a.split('.').map(int.parse).toList();
  final pb = b.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

// 상류 세트 --------------------------------------------------------------

class UpstreamSets {
  final core = <String>{};
  final recommended = <String>{};
  final flutter = <String>{};
  final sources = <String, String>{};
  Set<String> get all => {...core, ...recommended, ...flutter};

  /// 상류 YAML 은 `prefer_iterable_whereType` 처럼 대문자가 섞인 이름을 쓰고
  /// rules.json · messages.yaml 은 소문자다 (첫 실행에서 서로 찾지 못했다). 소문자로 견준다.
  String? of(String name) {
    bool has(Set<String> s) => s.any((n) => n.toLowerCase() == name.toLowerCase());
    return has(core)
        ? 'core'
        : has(recommended)
            ? 'recommended'
            : has(flutter)
                ? 'flutter'
                : null;
  }
}

UpstreamSets readUpstreamSets() {
  final config = jsonDecode(File('$repoRoot/.dart_tool/package_config.json').readAsStringSync())
      as Map<String, dynamic>;
  String root(String package) {
    final p = (config['packages'] as List).cast<Map<String, dynamic>>().firstWhere(
          (p) => p['name'] == package,
          orElse: () => throw FormatException('package_config 에 $package 가 없다 — 저장소 루트에서 pub get'),
        );
    final path = Directory.fromUri(Uri.parse(p['rootUri'] as String)).path;
    return path.endsWith('/') ? path : '$path/';
  }

  Set<String> rulesOf(String file) => File(file)
      .readAsLinesSync()
      .map((l) => RegExp(r'^    - (\w+)').firstMatch(l)?.group(1))
      .whereType<String>()
      .toSet();

  final sets = UpstreamSets();
  final lints = root('lints');
  final flutterLints = root('flutter_lints');
  sets.sources['lints'] = Uri.directory(lints).pathSegments.where((s) => s.isNotEmpty).last;
  sets.sources['flutter_lints'] = Uri.directory(flutterLints).pathSegments.where((s) => s.isNotEmpty).last;
  sets.core.addAll(rulesOf('${lints}lib/core.yaml'));
  sets.recommended.addAll(rulesOf('${lints}lib/recommended.yaml'));
  sets.flutter.addAll(rulesOf('${flutterLints}lib/flutter.yaml'));
  return sets;
}

// 분석 ------------------------------------------------------------------

class Analysis {
  Analysis(this.label, this.constraint);
  final String label;
  final String constraint;
  int exitCode = -1;
  int elapsedMs = 0;
  bool jsonOk = false;
  int outsideOptions = 0;
  final diagnostics = <Map<String, Object>>[];
  final byRule = <String, List<String>>{};
  final unmapped = <String>[];
  final incompatiblePairs = <String>{};

  Map<String, int> countByCode() {
    final out = <String, int>{};
    for (final d in diagnostics) {
      out.update('${d['code']}', (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }

  Map<String, Object> toJson() => {
        'label': label,
        'constraint': constraint,
        'exitCode': exitCode,
        'elapsedMs': elapsedMs,
        'jsonOk': jsonOk,
        'outsideOptions': outsideOptions,
        'countByCode': countByCode(),
        'unmapped': unmapped,
        'diagnostics': diagnostics,
      };
}

/// 규칙 이름 전부를 옵션 파일에 적은 패키지를 만들고 분석한다.
/// 옵션 파일의 3행부터가 규칙 하나씩이라 진단의 줄 번호로 규칙을 찾는다.
Future<Analysis> analyzeAll(String label, String constraint, List<String> rules) async {
  final dir = Directory('$work/$label');
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  Directory('${dir.path}/lib').createSync(recursive: true);
  File('${dir.path}/pubspec.yaml')
      .writeAsStringSync('name: spike_rule_state\npublish_to: none\nenvironment:\n  sdk: $constraint\n');
  File('${dir.path}/lib/a.dart').writeAsStringSync('/// 분석 대상이 비지 않게 두는 파일.\nint answer() => 42;\n');
  final options = StringBuffer('linter:\n  rules:\n');
  for (final r in rules) {
    options.writeln('    - $r');
  }
  File('${dir.path}/analysis_options.yaml').writeAsStringSync(options.toString());

  final dart = Platform.resolvedExecutable;
  final pub = await Process.run(dart, ['--suppress-analytics', 'pub', 'get'], workingDirectory: dir.path);
  if (pub.exitCode != 0) {
    stderr.writeln('pub get 실패 ($label): ${pub.stderr}');
    exit(69);
  }
  final state = Directory('$work/state-$label');
  if (state.existsSync()) state.deleteSync(recursive: true);
  state.createSync(recursive: true);

  final a = Analysis(label, constraint);
  final watch = Stopwatch()..start();
  final result = await Process.run(dart, ['--suppress-analytics', 'analyze', '--format=json'],
      workingDirectory: dir.path, environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path});
  a.elapsedMs = watch.elapsedMilliseconds;
  a.exitCode = result.exitCode;
  final jsonLine = '${result.stdout}'.split('\n').lastWhere((l) => l.startsWith('{'), orElse: () => '');
  if (jsonLine.isEmpty) return a;
  a.jsonOk = true;
  final decoded = jsonDecode(jsonLine) as Map<String, dynamic>;
  for (final d in (decoded['diagnostics'] as List).cast<Map<String, dynamic>>()) {
    final location = d['location'] as Map<String, dynamic>;
    final file = '${location['file']}';
    final line = ((location['range'] as Map)['start'] as Map)['line'] as int;
    final code = '${d['code']}';
    final message = '${d['problemMessage']}';
    if (!file.endsWith('/analysis_options.yaml')) {
      a.outsideOptions++;
      continue;
    }
    a.diagnostics.add({'line': line, 'severity': '${d['severity']}'.toLowerCase(), 'code': code, 'message': message});
    final index = line - 3;
    if (index < 0 || index >= rules.length) {
      a.unmapped.add('$line $code');
      continue;
    }
    (a.byRule[rules[index]] ??= []).add(code);
    if (code == 'incompatible_lint') {
      final quoted = RegExp(r"'(\w+)'").allMatches(message).map((m) => m.group(1)!).toList();
      if (quoted.length >= 2) a.incompatiblePairs.add((quoted.take(2).toList()..sort()).join(' × '));
    }
  }
  return a;
}

// 저장소 지문 · 경로 가리기 ------------------------------------------------

Future<String> repoFingerprint() async {
  final status = await Process.run('git', ['status', '--porcelain'], workingDirectory: repoRoot);
  final config = File('$repoRoot/.dart_tool/package_config.json');
  return '${status.stdout}|${config.existsSync() ? digest(config.readAsBytesSync()) : '-'}';
}

String digest(List<int> bytes) {
  var hash = 0xcbf29ce484222325;
  for (final unit in bytes) {
    hash = (hash ^ unit) * 0x100000001b3;
  }
  String half(int v) => (v & 0xffffffff).toRadixString(16).padLeft(8, '0');
  return half(hash >> 32) + half(hash);
}

String scrub(String text) {
  final home = Platform.environment['HOME'] ?? '/nonexistent-home';
  return text.replaceAll(work, '<work>').replaceAll(repoRoot, '<repo>').replaceAll(home, '~');
}

Object? scrubJson(Object? value) {
  if (value is String) return scrub(value);
  if (value is List) return value.map(scrubJson).toList();
  if (value is Map) return value.map((k, v) => MapEntry('$k', scrubJson(v)));
  return value;
}
