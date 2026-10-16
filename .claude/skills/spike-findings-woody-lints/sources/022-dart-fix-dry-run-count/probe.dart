// Spike 022 — 평가표의 "`dart fix` 로 고칠 수 있는 건수" 를 어떻게 세는가.
//
// 같은 프로젝트에서 넷을 견준다.
//   진단      — `dart analyze --format=json` 의 규칙별 줄 수
//   묶음 dry  — 규칙을 모두 켠 채 `dart fix --dry-run` 한 번의 규칙별 수
//   단독 dry  — `dart fix --dry-run --code=<규칙>` 의 수
//   apply 뒤  — 소스를 원본으로 되돌리고 `dart fix --apply --code=<규칙>` 한 뒤 다시 분석해 남은 줄
//
// 1부: 021 의 연습용 표식(3.13 패키지) — 공개해도 되는 작은 예
// 2부: `flutter_starter_kit` 의 복사본 — 후보 규칙 118개(FEATURES.md 의 후보 표 ∩ 실제로 켜지는 규칙
//       − 기반 세트 − base.yaml)와 021 의 `use_primary_constructors` 를 비호환 쌍이 갈리도록 묶음 넷으로 나눠 켠다
//
// 실행 (저장소 루트에서):
//   fvm dart .planning/spikes/022-dart-fix-dry-run-count/probe.dart <작업 폴더> <사용 프로젝트 원본>
import 'dart:convert';
import 'dart:io';

import '../021-new-rules-language-gate/consumer.dart';
import '../021-new-rules-language-gate/probe.dart' show oldSamples, newRules;

/// FEATURES.md 의 후보 표에 이름이 있는 규칙 가운데, Dart 3.13.4 에서 켜지고(020 의 실제 상태)
/// 기반 세트와 `lib/base.yaml` 에 없는 것 — 2026-10-12 에 020 의 결과로 셈했다.
/// 비호환 쌍(020)이 한 묶음에 들지 않게 나눈다.
const groups = <String, List<String>>{
  'G1': [
    'always_put_control_body_on_new_line', 'always_put_required_named_parameters_first',
    'always_use_package_imports', 'async_return_with_no_await', 'avoid_annotating_with_dynamic',
    'avoid_bool_literals_in_conditional_expressions', 'avoid_catches_without_on_clauses',
    'avoid_catching_errors', 'avoid_classes_with_only_static_members', 'avoid_double_and_int_checks',
    'avoid_dynamic_calls', 'avoid_equals_and_hash_code_on_mutable_classes', 'avoid_escaping_inner_quotes',
    'avoid_final_parameters', 'avoid_implementing_value_types', 'avoid_js_rounded_ints',
    'avoid_multiple_declarations_per_line', 'avoid_positional_boolean_parameters',
    'avoid_redundant_argument_values', 'avoid_returning_this', 'avoid_setters_without_getters',
    'avoid_slow_async_io', 'avoid_type_to_string', 'avoid_types_on_closure_parameters',
    'avoid_unused_constructor_parameters', 'avoid_void_async', 'cancel_subscriptions',
    'cast_nullable_to_non_nullable', 'close_sinks', 'combinators_ordering', 'comment_references',
    'conditional_uri_does_not_exist', 'deprecated_consistency', 'deprecated_member_use_from_same_package',
    'diagnostic_describe_all_properties', 'directives_ordering', 'discarded_futures',
    'do_not_use_environment', 'document_ignores', 'eol_at_end_of_file', 'flutter_style_todos',
    'join_return_with_assignment', 'leading_newlines_in_multiline_strings', 'library_names',
    'lines_longer_than_80_chars', 'literal_only_boolean_expressions', 'matching_super_parameters',
    'migrate_design_widgets', 'missing_code_block_language_in_doc_comment',
    'missing_whitespace_between_adjacent_strings', 'no_adjacent_strings_in_list', 'no_dynamic_casts',
    'no_literal_bool_comparisons', 'no_raw_types', 'no_runtimetype_tostring', 'no_self_assignments',
    'noop_primitive_operations', 'omit_local_variable_types', 'omit_obvious_local_variable_types',
    'omit_obvious_property_types', 'only_throw_errors', 'parameter_assignments',
    'prefer_asserts_in_initializer_lists', 'prefer_const_declarations',
    'prefer_constructors_over_static_methods', 'prefer_final_in_for_each', 'prefer_foreach',
    'prefer_if_elements_to_conditional_expressions', 'prefer_int_literals', 'prefer_null_aware_method_calls',
    'prefer_void_to_null', 'public_member_api_docs', 'remove_deprecations_in_breaking_versions',
    'require_trailing_commas', 'simple_directive_paths', 'simplify_variable_pattern',
    'sized_box_shrink_expand', 'sort_constructors_first', 'sort_pub_dependencies',
    'sort_unnamed_constructors_first', 'specify_nonobvious_property_types', 'switch_on_type',
    'test_types_in_equals', 'throw_in_finally', 'tighten_type_of_initializing_formals', 'unnecessary_breaks',
    'unnecessary_ignore', 'unnecessary_lambdas', 'unnecessary_library_directive',
    'unnecessary_null_aware_operator_on_extension_on_nullable', 'unnecessary_null_checks',
    'unnecessary_parenthesis', 'unnecessary_raw_strings', 'unnecessary_statements', 'unnecessary_unawaited',
    'unreachable_from_main', 'use_colored_box', 'use_decorated_box', 'use_enums',
    'use_is_even_rather_than_modulo', 'use_named_constants', 'use_raw_strings',
    'use_setters_to_change_properties', 'use_string_buffers', 'use_test_throws_matchers',
    'use_truncating_division',
  ],
  // G1 의 규칙과 비호환인 쪽
  'G2': ['always_specify_types', 'prefer_relative_imports', 'specify_nonobvious_local_variable_types', 'type_annotate_public_apis'],
  // base.yaml 의 규칙(prefer_single_quotes, prefer_final_locals)과 비호환인 쪽
  'G3': ['prefer_double_quotes', 'unnecessary_final'],
  // 언어 버전 3.13 에서만 도는 규칙 (021) — 복사본의 하한을 ^3.13.0 으로 올려 잰다
  'G4': [
    'empty_container_bodies', 'unnecessary_type_name_in_constructor', 'unnecessary_const_in_enum_constructor',
    'use_primary_constructors', 'initialize_in_field_declaration', 'use_declaring_parameters',
    'unnecessary_primary_constructor_body',
  ],
};

/// apply 로 확인할 규칙의 최대 수 (시간 때문에).
const maxApply = 8;

late final String spikeDir;
late final Repo repo;
late final String work;
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
  repo = Repo.fromSpikeDir(spikeDir);
  work = Directory(args[0]).absolute.path;
  final source = Directory(args[1]).resolveSymbolicLinksSync();
  if (work.startsWith(repo.root) || work.startsWith(source)) {
    stderr.writeln('작업 폴더는 저장소와 원본 밖에 둔다');
    exit(64);
  }
  final repoBefore = await repo.fingerprint();
  consumer = Consumer(work: work, repo: repo, source: source);
  final dartVersion = Platform.version.split(' ').first;
  say('# Spike 022 — dart fix 의 건수');
  say('SDK: $dartVersion');
  say('');

  // 1부 ------------------------------------------------------------------
  say('## 1부 — 연습용 표식 (언어 버전 3.13, 새 규칙 10개)');
  final fx = await fixturePart();
  say('');

  // 2부 ------------------------------------------------------------------
  say('## 2부 — 사용 프로젝트의 복사본');
  consumer.copy();
  await consumer.pointToRepo();
  consumer.addExampleMarkers();
  say('- 복사한 파일 ${consumer.copiedFiles}개, 받은 자리 ${consumer.woodySource()}, 언어 버전 ${consumer.languageVersion()}');
  final rows = <String, Map<String, Object?>>{};
  final groupRuns = <String, Object>{};
  final shots = <Shot>[];
  for (final g in groups.entries) {
    final sdk = g.key == 'G4' ? '^3.13.0' : null;
    await consumer.useSdk(sdk);
    consumer.setOptions(consumer.optionsWith(rules: g.value));
    final shot = await consumer.analyze('${g.key}-analyze');
    consumer.ensureRepoSource(shot);
    shots.add(shot);
    final combined = await dryRun('${g.key}-dry');
    say('- ${g.key} (${g.value.length}개, 언어 버전 ${consumer.languageVersion()}): 분석 ${shot.elapsedMs} ms · 줄 ${shot.diags.length} '
        '(표식 ${shot.marker.length}), 묶음 dry-run ${combined.ms} ms · ${combined.total}건 · 상태 폴더 항목 ${combined.stateEntries}');
    groupRuns[g.key] = {
      'sdk': sdk ?? 'original',
      'languageVersion': consumer.languageVersion(),
      'analyze': shot.toJson(),
      'combined': combined.toJson(),
    };
    for (final rule in g.value) {
      final diagProject = shot.project.where((d) => d.code == rule).length;
      final diagMarker = shot.marker.where((d) => d.code == rule).length;
      final comb = combined.countOf(rule);
      DryRun? alone;
      if (diagProject + diagMarker > 0 || comb > 0) alone = await dryRun('${g.key}-dry-$rule', code: rule);
      rows[rule] = {
        'group': g.key,
        'diag': diagProject + diagMarker,
        'diagProject': diagProject,
        'diagByArea': shot.countByAreaCode(shot.diags.where((d) => d.code == rule)).map((k, v) => MapEntry(k, v[rule])),
        'combined': comb,
        'alone': alone?.countOf(rule),
        'aloneOther': alone == null ? null : alone.total - alone.countOf(rule),
        'aloneMs': alone?.ms,
        'aloneByArea': alone?.areaOf(rule),
      };
    }
    // 묶음 dry-run 에 나왔지만 이 묶음의 후보가 아닌 코드 (기반 세트 · base.yaml 의 규칙 등)
    final extra = combined.codes().where((c) => !g.value.contains(c)).toList()..sort();
    say('  - 묶음 dry-run 에 나온 후보 밖 코드: ${{for (final c in extra) c: combined.countOf(c)}}');
  }
  await consumer.useSdk(null);
  consumer.setOptions(consumer.originalOptions);
  say('');

  say('### 규칙마다 — 진단 · 묶음 dry · 단독 dry (0 이 아닌 줄만)');
  say('| 규칙 | 묶음 | fixStatus (rules.json) | 진단 | 묶음 dry | 단독 dry | 단독 dry 의 다른 코드 |');
  say('|---|---|---|---|---|---|---|');
  final fixStatus = readFixStatus();
  for (final e in rows.entries) {
    final r = e.value;
    if (r['diag'] == 0 && r['combined'] == 0) continue;
    say('| `${e.key}` | ${r['group']} | ${fixStatus[e.key] ?? '—'} | ${r['diag']} | ${r['combined']} | ${r['alone'] ?? '—'} | ${r['aloneOther'] ?? '—'} |');
  }
  final zeroDiag = rows.entries.where((e) => e.value['diag'] == 0 && e.value['combined'] == 0).map((e) => e.key).toList();
  say('- 진단도 dry-run 도 0 인 규칙 ${zeroDiag.length}개 (표식 없이 잰 0 — 이 spike 는 0 의 뜻을 가르지 않는다)');
  say('');

  // apply — 단독 dry 와 진단이 다른 규칙, 그리고 수가 큰 규칙
  final withFix = rows.entries.where((e) => (e.value['alone'] as int? ?? 0) > 0).toList();
  final differ = withFix.where((e) => e.value['alone'] != e.value['diag']).map((e) => e.key).toList();
  final biggest = (withFix.toList()..sort((a, b) => (b.value['alone'] as int).compareTo(a.value['alone'] as int)))
      .map((e) => e.key)
      .toList();
  final applyRules = <String>{
    ...differ.take(maxApply ~/ 2),
    ...biggest.take(maxApply),
    if (rows['sort_pub_dependencies']?['diag'] != 0) 'sort_pub_dependencies',
  }.take(maxApply + 1).toList();
  say('### apply — 소스를 원본으로 되돌리고 규칙 하나씩 (${applyRules.length}개)');
  say('| 규칙 | 진단 | 단독 dry | apply 뒤 남은 그 규칙 | apply 뒤 다른 코드의 증감 | apply 의 종료 코드 |');
  say('|---|---|---|---|---|---|');
  final applied = <String, Object>{};
  for (final rule in applyRules) {
    final g = rows[rule]!['group'] as String;
    consumer.refreshSources();
    consumer.addExampleMarkers();
    await consumer.useSdk(g == 'G4' ? '^3.13.0' : null);
    consumer.setOptions(consumer.optionsWith(rules: groups[g]!));
    final before = shots.firstWhere((s) => s.id == '$g-analyze');
    final apply = await dryRun('apply-$rule', code: rule, apply: true);
    final after = await consumer.analyze('apply-$rule-analyze');
    consumer.ensureRepoSource(after);
    final remaining = after.diags.where((d) => d.code == rule).length;
    final delta = <String, int>{};
    for (final d in before.diags) {
      delta.update(d.code, (v) => v - 1, ifAbsent: () => -1);
    }
    for (final d in after.diags) {
      delta.update(d.code, (v) => v + 1, ifAbsent: () => 1);
    }
    delta.removeWhere((k, v) => v == 0 || k == rule);
    applied[rule] = {
      'diag': rows[rule]!['diag'],
      'alone': rows[rule]!['alone'],
      'remaining': remaining,
      'otherDelta': delta,
      'applyExit': apply.exitCode,
      'applyMs': apply.ms,
      'applySummary': apply.summary,
    };
    say('| `$rule` | ${rows[rule]!['diag']} | ${rows[rule]!['alone']} | $remaining | ${delta.isEmpty ? '—' : delta} | ${apply.exitCode} |');
  }
  consumer.refreshSources();
  await consumer.useSdk(null);
  consumer.setOptions(consumer.originalOptions);
  say('');

  final repoAfter = await repo.fingerprint();
  final expected = expectedLines('${repo.root}/example/expected_diagnostics.txt')
      .map((l) => l.replaceFirst('lib/', Diag.markerDir))
      .toSet();
  final checks = <String, bool>{
    'K1 1부 대조: 단독 dry-run 의 수가 그 규칙의 진단 수와 같다 (use_primary_constructors)':
        fx['alone_use_primary_constructors'] == fx['diag_use_primary_constructors'],
    'K2 2부의 모든 분석에서 woody_lints 가 작업 중인 저장소를 가리켰다': shots.every((s) => s.woodySource == 'repo'),
    'K3 2부의 모든 분석에서 example 정답지 16줄이 표식의 줄에 모두 들어 있다 (후보 규칙이 표식에 줄을 더할 수 있다)':
        shots.every((s) => s.marker.map((d) => d.text).toSet().containsAll(expected)),
    'K4 2부의 모든 분석에서 plugin 이 준비됐다': shots.every((s) => s.pluginFolders == 1 && !s.pluginHeader),
    'K5 저장소가 그대로다': repoAfter == repoBefore,
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
    'fixture': fx,
    'groups': groupRuns,
    'rows': rows,
    'applied': applied,
    'checks': checks,
  })));
  File('${results.path}/probe-$dartVersion.log').writeAsStringSync(log.toString());
  exit(ok ? 0 : 1);
}

// dart fix ---------------------------------------------------------------

class DryRun {
  DryRun(this.id);
  final String id;
  int exitCode = -1;
  int ms = 0;
  int total = 0;
  int stateEntries = -1;
  String summary = '';

  /// 자리 → 코드 → 건수.
  final byAreaCode = <String, Map<String, int>>{};

  Set<String> codes() => byAreaCode.values.expand((m) => m.keys).toSet();
  int countOf(String code) => byAreaCode.values.fold(0, (s, m) => s + (m[code] ?? 0));
  Map<String, int> areaOf(String code) =>
      {for (final e in byAreaCode.entries) if ((e.value[code] ?? 0) > 0) e.key: e.value[code]!};

  Map<String, Object> toJson() => {
        'exitCode': exitCode,
        'ms': ms,
        'total': total,
        'stateEntries': stateEntries,
        'summary': summary,
        'byAreaCode': byAreaCode,
      };
}

/// `dart fix` 를 복사본에서 한 번. 출력은 파일 경로 줄과 `  <코드> - N fix(es)` 줄이다.
/// 화면 그대로는 `<작업 폴더>/private/` 에만 쓴다.
Future<DryRun> dryRun(String id, {String? code, bool apply = false, String? dir}) async {
  final where = dir ?? consumer.dir;
  final state = Directory('$work/state/$id');
  if (state.existsSync()) state.deleteSync(recursive: true);
  state.createSync(recursive: true);
  final result = DryRun(id);
  final watch = Stopwatch()..start();
  final r = await Process.run(
      Platform.resolvedExecutable,
      ['--suppress-analytics', 'fix', apply ? '--apply' : '--dry-run', if (code != null) '--code=$code'],
      workingDirectory: where,
      environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path});
  result.ms = watch.elapsedMilliseconds;
  result.exitCode = r.exitCode;
  result.stateEntries = state.listSync(recursive: true).length;
  final out = '${r.stdout}';
  final private = Directory('$work/private')..createSync(recursive: true);
  File('${private.path}/$id.txt').writeAsStringSync('$out\n--- stderr\n${r.stderr}');
  String? area;
  for (final line in out.split('\n')) {
    final m = RegExp(r'^  (\S+) - (\d+) fix(?:es)?$').firstMatch(line);
    if (m != null && area != null) {
      final n = int.parse(m.group(2)!);
      result.byAreaCode.putIfAbsent(area, () => {}).update(m.group(1)!, (v) => v + n, ifAbsent: () => n);
      result.total += n;
      continue;
    }
    if (RegExp(r'^\S+\.(dart|yaml)$').hasMatch(line.trim()) && !line.startsWith(' ')) {
      area = Diag(line.trim(), 0, '', '').area;
    }
    final s = RegExp(r'^(\d+ (?:proposed )?fix(?:es)? (?:made )?in \d+ files?\.|Nothing to fix!)').firstMatch(line.trim());
    if (s != null) result.summary = s.group(1)!;
  }
  return result;
}

/// rules.json (tag 3.13.4) 의 `fixStatus` — 020 의 결과 파일에서 읽는다.
Map<String, String> readFixStatus() {
  final path = '$spikeDir/../020-rule-state-vs-rules-json/results/probe-3.13.4.json';
  final rules = (jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>)['rules'] as List;
  return {for (final r in rules.cast<Map<String, dynamic>>()) r['name'] as String: '${r['jsonFixStatus']}'};
}

// 1부 ------------------------------------------------------------------

/// 021 의 3.11 문법 표식을 3.13 패키지에 두고 진단 · 묶음 dry · 단독 dry · 묶음 apply 를 견준다.
Future<Map<String, Object>> fixturePart() async {
  final dir = Directory('$work/fixture');
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  Directory('${dir.path}/lib').createSync(recursive: true);
  File('${dir.path}/pubspec.yaml')
      .writeAsStringSync('name: spike_dart_fix\npublish_to: none\nenvironment:\n  sdk: ^3.13.0\n');
  File('${dir.path}/analysis_options.yaml')
      .writeAsStringSync('linter:\n  rules:\n${newRules.map((r) => '    - $r\n').join()}');
  void writeSamples() {
    for (final e in oldSamples.entries) {
      File('${dir.path}/lib/${e.key}').writeAsStringSync(e.value);
    }
  }

  writeSamples();
  final dart = Platform.resolvedExecutable;
  await Process.run(dart, ['--suppress-analytics', 'pub', 'get'], workingDirectory: dir.path);

  Future<Map<String, int>> diagCounts() async {
    final r = await Process.run(dart, ['--suppress-analytics', 'analyze', '--format=json'], workingDirectory: dir.path);
    final line = '${r.stdout}'.split('\n').lastWhere((l) => l.startsWith('{'), orElse: () => '{"diagnostics":[]}');
    final out = <String, int>{};
    for (final d in ((jsonDecode(line) as Map)['diagnostics'] as List).cast<Map<String, dynamic>>()) {
      out.update('${d['code']}', (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }

  final diag = await diagCounts();
  final combined = await dryRun('fx-dry', dir: dir.path);
  final alone = <String, int>{};
  for (final rule in {...diag.keys, ...combined.codes()}) {
    alone[rule] = (await dryRun('fx-dry-$rule', code: rule, dir: dir.path)).countOf(rule);
  }
  final applyAll = await dryRun('fx-apply', apply: true, dir: dir.path);
  final afterAll = await diagCounts();
  writeSamples();

  say('| 코드 | 진단 | 묶음 dry | 단독 dry | 묶음 apply 뒤 진단 |');
  say('|---|---|---|---|---|');
  for (final code in ({...diag.keys, ...combined.codes(), ...afterAll.keys}.toList()..sort())) {
    say('| `$code` | ${diag[code] ?? 0} | ${combined.countOf(code)} | ${alone[code] ?? '—'} | ${afterAll[code] ?? 0} |');
  }
  say('- 묶음 dry-run: ${combined.summary} / 묶음 apply: ${applyAll.summary} (exit ${applyAll.exitCode}), dart fix 의 상태 폴더 항목 ${combined.stateEntries}');
  return {
    'diag': diag,
    'combined': combined.toJson(),
    'alone': alone,
    'applyAll': applyAll.toJson(),
    'afterApplyAll': afterAll,
    'alone_use_primary_constructors': alone['use_primary_constructors'] ?? -1,
    'diag_use_primary_constructors': diag['use_primary_constructors'] ?? -2,
  };
}
