// woody_lints 규칙 실측 도구 — Phase 4 평가표(RULES-03 · RULES-04)의 값을 재서, 건수와 조건만
// 담은 결과 JSON 으로 남긴다 (04-CONTEXT.md D-02 · D-07 · D-09).
//
// 후보는 133개다 (lint 132 + analyzer 옵션 `strict-inference`). 단계는 일곱이고 `--stage` 로 고른다.
//
//   state               후보의 상태(저장소 하한 `^3.13.0` 패키지 분석 + tag 3.13.4 `messages.yaml`),
//                       상류 세트(저장소 루트가 받은 lints · flutter_lints), 비호환 쌍 10개의 쌍별 확인
//   baseline            사용 프로젝트를 저장소 밖 작업 폴더에 복사하고 기준선 B0 · B0-313 을 잰다
//   groups              후보를 그룹 G1 ~ G4 로 나눠 켜고 잰다 (값 = 그룹 실행 − 같은 하한의 기준선)
//   markers             프로젝트 줄이 0 인 후보에 표식을 넣어 "진짜 0" 인지 가른다 (D-03)
//   ignore              무시 주석을 걷어낸 실행과의 차이로 주석이 가린 줄을 잰다
//   fix                 규칙 하나씩 `dart fix --apply --code=<규칙>` 한 뒤 사라진 줄을 잰다
//                       (`strict-inference` 는 그 회차의 `inference_failure_on_*` 코드를 모두 준다)
//   unnecessary-ignore  결정을 반영한 뒤 `unnecessary_ignore` 를 따로 잰다 (D-17 — `all` 에 들지 않는다)
//
// 실행: fvm dart run tool/measure_rules.dart --work <저장소 밖 작업 폴더> [--source <사용 프로젝트>]
//         [--stage a,b,…] [--rules a,b,…] [--probe-all] [--run-id R1] [--out <경로>]
//   --source  사용 프로젝트의 원본 폴더. 복사가 필요할 때만(작업 폴더에 `pristine/` 이 없을 때) 필수다.
//             원본은 읽기만 한다 — 복사의 원본 인자로만 쓴다.
//   --work    늘 필수. 저장소 밖이어야 한다 (안이면 단계마다 견주는 저장소 지문의 git status 가 깨진다).
//   --out     기본 tool/measurements/<YYYY-MM-DD>-<run id>.json. 모든 단계와 마지막 지문 비교가 끝난
//             뒤에만 쓴다 — 실행 중에는 저장소 안에 아무것도 만들지 않는다.
//
// 출력 모드 (분석을 돌리지 않는다 — 한 번에 하나):
//   --summary <묶음>   묶음 하나의 터미널 요약 (D-06). 묶음 id 는 `bundles` 상수의 키
//   --report [--write] RULES.md § 실측 기록 의 Markdown 을 stdout 으로 — 단언 (1) ~ (7) 가운데
//                      하나라도 어긋나면 종료 코드 1 이고 아무것도 쓰지 않는다. --write 면 통과했을
//                      때만 RULES.md 의 woody:measurements 구역을 바꿔 쓴다
//   --recount [--write] [--in <결과 JSON> | --work <작업 폴더>] [--run-id R1]
//                      회차는 그대로 두고 행의 counts · counts313 · ignored 를 회차의
//                      countByAreaCode 에서 다시 센다 (자리 집계가 바뀌었을 때, 04-REVIEW.md CR-01).
//                      --write 면 같은 결과 JSON 에 다시 쓴다
//   --audit            후보 133 과 B-7 31 이 RULES.md 의 세 표에 모두 있는지 (RULES-08 · DOCS-11)
//   결과 JSON 은 --in <경로>, 없으면 <work>/results/<run id>.json, 그것도 없으면
//   tool/measurements/*-<run id>.json (정확히 하나) 에서 찾는다 (--audit 은 JSON 을 읽지 않는다).
//
// 비공개 사용 프로젝트의 경로 · 진단 메시지 · 코드 조각은 결과 JSON · 화면 · 예외 문구 어디에도
// 쓰지 않는다. 진단 줄 전문과 `dart fix` 화면 원문은 `<작업 폴더>/private/` 에만 쓴다.
// spike 020 ~ 023 의 스크립트 조각(.claude/skills/spike-findings-woody-lints/sources/)을 이 파일
// 하나에 옮겨 넣었다 — tool/ 에 import 할 다른 Dart 파일을 두지 않는다.
//
// 종료 코드: 0 모든 회차가 유효 / 1 판정 실패(저장소 지문이 바뀜 · 유효하지 않은 회차 · 단언 실패 ·
//            감사 실패) / 64 사용법 (출력 모드의 결과 JSON 을 찾지 못함 포함) / 69 하위 명령(pub get ·
//            dart analyze · dart fix)이 돌지 않음 / 70 예외로 끝남 (결과 JSON 의 schema 가 1 이 아님 ·
//            RULES.md 의 마커 없음 포함)
import 'dart:convert';
import 'dart:io';

/// 상태를 읽는 SDK tag — 저장소 고정 SDK (Dart 3.13.4) 와 같다.
const sdkTag = '3.13.4';

/// 상태(stable / experimental / testing / deprecated / removed)를 읽는 상류 파일 (D-02, spike 020).
const messagesUrl =
    'https://raw.githubusercontent.com/dart-lang/sdk/$sdkTag/pkg/linter/messages.yaml';

/// `messages.yaml` 을 받지 못할 때 대신 읽는 spike 020 의 결과 (같은 tag 에서 읽은 상태).
const spike020Results =
    '.planning/spikes/020-rule-state-vs-rules-json/results/probe-3.13.4.json';

/// plugin 준비가 실패했을 때 stderr 에 찍히는 머리말 (spike 002). 첫 줄이 아닐 수 있다 (spike 008).
const pluginFailureHeader =
    'An error occurred while executing an analyzer plugin:';

/// 언어 버전 3.13 에서만 도는 규칙을 잴 때의 복사본 하한 (spike 021).
const sdk313 = '^3.13.0';

/// 단계 이름 — 이 순서로 돈다 (`--stage` 에 적은 순서와 상관없다).
const allStages = [
  'state',
  'baseline',
  'groups',
  'markers',
  'ignore',
  'fix',
  'unnecessary-ignore',
];

/// `--stage all` 이 뜻하는 단계 — `unnecessary-ignore` 는 결정을 반영한 뒤 따로 돈다 (D-17).
const defaultStages = [
  'state',
  'baseline',
  'groups',
  'markers',
  'ignore',
  'fix',
];

/// 복사본(`<work>/consumer/`)에서 도는 단계.
const consumerStages = [
  'baseline',
  'groups',
  'markers',
  'ignore',
  'fix',
  'unnecessary-ignore',
];

/// 분석을 돌리지 않고 결과 JSON(또는 `RULES.md`)만 읽는 출력 모드 — 한 번에 하나만 준다.
const outputModes = ['--summary', '--report', '--recount', '--audit'];

/// 결과 JSON 의 모양 번호. 바꾸면 04-03 의 `--summary` · `--report`, 04-04 의 회차 기록,
/// RULES-13 때의 재측정 diff 를 함께 고친다.
const schemaVersion = 1;

// 후보 ------------------------------------------------------------------
//
// 이름은 .planning/research/FEATURES.md 의 B-1 ~ B-6 표 첫 칸의 backtick 이름 전부다 (125개).
// 절마다 이렇게 뽑았다 (2026-10-13 셈 B-1 29 · B-2 8 · B-3 42 · B-4 9 · B-5 4 · B-6 33):
//
//   sed -n '/^### B-1\./,/^### B-2\./p' .planning/research/FEATURES.md \
//     | grep -E '^\| `' | cut -d'|' -f2 | grep -o -E '`[a-z0-9_]+`' | tr -d '`'
//
// B-6 의 245 · 246 · 253행은 한 칸에 이름이 여럿이라 전부 받는다 (spike 022 는 첫 이름만 받아 7개를
// 빠뜨렸다 — 04-RESEARCH.md Pitfall 1). 여기에 B-7 에만 있는 `use_primary_constructors` (RULES-10 의
// 언어 버전 3.13 전용 6개에 든다), 지금 켜 둔 6개, analyzer 옵션 `strict-inference` 를 더해 133개다
// (04-RESEARCH.md § 2). FEATURES.md 는 런타임에 읽지 않는다 — 시작할 때 수를 단언한다.

/// FEATURES.md 의 절 → 그 절 표의 첫 칸 이름 (표의 순서 그대로).
const featureSections = <String, List<String>>{
  'B-1': [
    'discarded_futures',
    'unnecessary_unawaited',
    'async_return_with_no_await',
    'avoid_void_async',
    'cancel_subscriptions',
    'avoid_dynamic_calls',
    'cast_nullable_to_non_nullable',
    'avoid_type_to_string',
    'switch_on_type',
    'test_types_in_equals',
    'throw_in_finally',
    'no_self_assignments',
    'no_adjacent_strings_in_list',
    'missing_whitespace_between_adjacent_strings',
    'unnecessary_statements',
    'literal_only_boolean_expressions',
    'avoid_unused_constructor_parameters',
    'parameter_assignments',
    'avoid_catching_errors',
    'only_throw_errors',
    'always_use_package_imports',
    'prefer_relative_imports',
    'conditional_uri_does_not_exist',
    'deprecated_member_use_from_same_package',
    'matching_super_parameters',
    'avoid_equals_and_hash_code_on_mutable_classes',
    'avoid_implementing_value_types',
    'avoid_double_and_int_checks',
    'avoid_js_rounded_ints',
  ],
  'B-2': [
    'prefer_const_declarations',
    'use_colored_box',
    'sized_box_shrink_expand',
    'use_string_buffers',
    'no_runtimetype_tostring',
    'avoid_slow_async_io',
    'noop_primitive_operations',
    'use_truncating_division',
  ],
  'B-3': [
    'prefer_final_in_for_each',
    'avoid_final_parameters',
    'type_annotate_public_apis',
    'directives_ordering',
    'combinators_ordering',
    'avoid_redundant_argument_values',
    'unnecessary_lambdas',
    'unnecessary_parenthesis',
    'unnecessary_breaks',
    'unnecessary_null_checks',
    'unnecessary_null_aware_operator_on_extension_on_nullable',
    'unnecessary_raw_strings',
    'use_raw_strings',
    'unnecessary_library_directive',
    'unnecessary_ignore',
    'document_ignores',
    'avoid_bool_literals_in_conditional_expressions',
    'no_literal_bool_comparisons',
    'prefer_if_elements_to_conditional_expressions',
    'prefer_null_aware_method_calls',
    'prefer_int_literals',
    'avoid_multiple_declarations_per_line',
    'avoid_escaping_inner_quotes',
    'leading_newlines_in_multiline_strings',
    'use_enums',
    'use_named_constants',
    'use_is_even_rather_than_modulo',
    'tighten_type_of_initializing_formals',
    'join_return_with_assignment',
    'prefer_asserts_in_initializer_lists',
    'prefer_constructors_over_static_methods',
    'sort_unnamed_constructors_first',
    'sort_constructors_first',
    'sort_pub_dependencies',
    'avoid_setters_without_getters',
    'use_setters_to_change_properties',
    'use_test_throws_matchers',
    'simple_directive_paths',
    'simplify_variable_pattern',
    'specify_nonobvious_property_types',
    'omit_obvious_local_variable_types',
    'flutter_style_todos',
  ],
  'B-4': [
    'unnecessary_type_name_in_constructor',
    'migrate_design_widgets',
    'empty_container_bodies',
    'unnecessary_const_in_enum_constructor',
    'use_declaring_parameters',
    'initialize_in_field_declaration',
    'unnecessary_primary_constructor_body',
    'no_dynamic_casts',
    'no_raw_types',
  ],
  'B-5': [
    'public_member_api_docs',
    'comment_references',
    'missing_code_block_language_in_doc_comment',
    'deprecated_consistency',
  ],
  'B-6': [
    'require_trailing_commas',
    'eol_at_end_of_file',
    'lines_longer_than_80_chars',
    'always_put_control_body_on_new_line',
    'always_specify_types',
    'prefer_double_quotes',
    'unnecessary_final',
    'omit_local_variable_types',
    'specify_nonobvious_local_variable_types',
    'omit_obvious_property_types',
    'avoid_types_on_closure_parameters',
    'always_put_required_named_parameters_first',
    'avoid_catches_without_on_clauses',
    'avoid_positional_boolean_parameters',
    'avoid_classes_with_only_static_members',
    'avoid_annotating_with_dynamic',
    'avoid_returning_this',
    'use_to_and_as_if_applicable',
    'prefer_mixin',
    'prefer_asserts_with_message',
    'avoid_field_initializers_in_const_classes',
    'prefer_foreach',
    'cascade_invocations',
    'prefer_expression_function_bodies',
    'close_sinks',
    'prefer_void_to_null',
    'use_decorated_box',
    'unreachable_from_main',
    'diagnostic_describe_all_properties',
    'do_not_use_environment',
    'library_names',
    'package_prefixed_library_names',
    'remove_deprecations_in_breaking_versions',
  ],
};

/// 절마다 기대하는 이름 수 (2026-10-13 셈) — 상수를 고치다 이름을 빠뜨리면 시작할 때 멈춘다.
const featureSectionSizes = {
  'B-1': 29,
  'B-2': 8,
  'B-3': 42,
  'B-4': 9,
  'B-5': 4,
  'B-6': 33,
};

/// FEATURES.md B-7 에만 있지만 후보에 넣는 이름 — RULES-10 의 언어 버전 3.13 전용 6개에 든다.
const extraCandidates = {'use_primary_constructors': 'B-7'};

/// 지금 `lib/base.yaml` 이 켜 둔 이 패키지만의 규칙 (04-01 뒤의 6개).
const currentRules = [
  'prefer_const_constructors',
  'prefer_const_literals_to_create_immutables',
  'always_declare_return_types',
  'prefer_final_locals',
  'prefer_single_quotes',
  'unawaited_futures',
];

/// 후보로 재는 analyzer 옵션 (D-19). `analyzer: language: strict-inference: true` 로 켠다.
const strictInference = 'strict-inference';

/// G1 의 규칙과 비호환인 쪽 (spike 022 의 G2 — 넷끼리는 비호환이 아니다).
const g2Rules = [
  'always_specify_types',
  'prefer_relative_imports',
  'specify_nonobvious_local_variable_types',
  'type_annotate_public_apis',
];

/// `lib/base.yaml` 의 `prefer_single_quotes` · `prefer_final_locals` 와 비호환인 쪽 (spike 022 의 G3).
const g3Rules = ['prefer_double_quotes', 'unnecessary_final'];

/// 언어 버전 3.13 에서만 도는 규칙 (spike 021) — 복사본의 하한을 `^3.13.0` 으로 올려 잰다.
const g4Rules = [
  'empty_container_bodies',
  'unnecessary_type_name_in_constructor',
  'unnecessary_const_in_enum_constructor',
  'use_primary_constructors',
  'initialize_in_field_declaration',
  'use_declaring_parameters',
  'unnecessary_primary_constructor_body',
];

/// 검토 묶음의 id → 한국어 이름 (D-04 · D-06). `--summary <id>` 와 행의 `bundle` 이 이 id 를 쓴다.
const bundles = <String, String>{
  'bug': '버그 방지',
  'perf': '성능',
  'style': '가독성·스타일',
  'current': '지금 켜 둔 5개',
  'excluded': '제외 권장',
  'strict': 'strict 계열',
  'import': 'import 스타일',
  'fire': 'fire-and-forget',
  'pairs': '함께 쓸 수 없는 쌍',
  'status': '상태 출처가 갈리는 규칙',
  'v2': 'v2 로 미룸',
  'ui': 'unnecessary_ignore',
};

/// 하나씩 묻는 묶음 (D-04 · D-05) → 그 묶음의 규칙. 나머지 묶음은 절과 그룹에서 정해진다.
///
/// `status` 의 `unnecessary_underscores` 는 상태 출처가 갈리는 규칙이지만(D-05) 기반 세트
/// (lints recommended)에 들어 있어 후보가 아니다 — 이 표에만 있고 평가표의 행은 없다.
const bundleRules = <String, List<String>>{
  'import': ['always_use_package_imports', 'prefer_relative_imports'],
  'fire': ['unawaited_futures', 'discarded_futures', 'unnecessary_unawaited'],
  'strict': ['no_dynamic_casts', 'no_raw_types', strictInference],
  'pairs': ['prefer_double_quotes', 'unnecessary_final'],
  'status': ['unnecessary_underscores'],
  'ui': ['unnecessary_ignore'],
};

/// 하나씩 묻는 묶음의 이름 — 그 묶음의 행은 `askIndividually: true` 다.
const individualBundles = {'strict', 'import', 'fire', 'pairs', 'status', 'ui'};

/// 재되 이번 phase 에서 결정하지 않는 규칙 → 미룬 요구사항 (묶음 `v2`).
const deferredRules = {
  'public_member_api_docs': 'RULES-09',
  'comment_references': 'RULES-09',
  'missing_code_block_language_in_doc_comment': 'RULES-09',
  'deprecated_consistency': 'RULES-09',
  'empty_container_bodies': 'RULES-10',
  'unnecessary_type_name_in_constructor': 'RULES-10',
  'unnecessary_const_in_enum_constructor': 'RULES-10',
  'use_primary_constructors': 'RULES-10',
  'initialize_in_field_declaration': 'RULES-10',
  'use_declaring_parameters': 'RULES-10',
  'unnecessary_primary_constructor_body': 'RULES-10',
  'migrate_design_widgets': 'RULES-11',
};

/// 절에서 정해지는 묶음 (위의 표에 이름이 없는 규칙).
const sectionBundles = {
  'B-1': 'bug',
  'B-2': 'perf',
  'B-3': 'style',
  'B-6': 'excluded',
};

/// 평가표의 행 하나 — 후보 규칙(또는 analyzer 옵션)과 그 분류.
class Candidate {
  /// [deferredTo] 는 v2 로 미룬 규칙에만 있다.
  const Candidate({
    required this.name,
    required this.section,
    required this.group,
    required this.bundle,
    this.deferredTo,
  });

  /// 규칙 이름 (옵션이면 `strict-inference`).
  final String name;

  /// FEATURES.md 의 절 (`B-1` ~ `B-6`, B-7 에만 있는 `use_primary_constructors` 는 `B-7`),
  /// 또는 `current` / `option`.
  final String section;

  /// 실행 그룹 — `G1` ~ `G4`, `current` (기준선에서 잰다), `option` (G1 실행에서 켠다).
  final String group;

  /// 검토 묶음 — `bug` / `perf` / `style` / `current` / `excluded` / `strict` / `import` /
  /// `fire` / `pairs` / `status` / `v2` / `ui`.
  final String bundle;

  /// 미룬 요구사항 (`RULES-09` / `RULES-10` / `RULES-11`) 또는 null.
  final String? deferredTo;

  /// 묶음에 넣지 않고 하나씩 묻는 행인지 (D-05).
  bool get askIndividually => individualBundles.contains(bundle);

  /// lint 규칙이 아니라 analyzer 옵션인지.
  bool get isOption => group == 'option';
}

/// 후보 133개 — 위의 상수에서 만든다. 수는 [checkCandidates] 가 단언한다.
final List<Candidate> candidates = buildCandidates();

/// 이름 → 후보.
final Map<String, Candidate> candidateByName = {
  for (final c in candidates) c.name: c,
};

/// lint 후보 132개의 이름 (옵션 제외, [candidates] 순서).
List<String> get lintCandidateNames => [
  for (final c in candidates)
    if (!c.isOption) c.name,
];

/// 상수에서 후보 목록을 만든다. 묶음을 정하지 못한 이름이 있으면 [StateError] 다.
List<Candidate> buildCandidates() {
  String groupOf(String name) {
    if (currentRules.contains(name)) return 'current';
    if (name == strictInference) return 'option';
    if (g2Rules.contains(name)) return 'G2';
    if (g3Rules.contains(name)) return 'G3';
    if (g4Rules.contains(name)) return 'G4';
    return 'G1';
  }

  String bundleOf(String name, String section) {
    for (final e in bundleRules.entries) {
      if (e.value.contains(name)) return e.key;
    }
    if (deferredRules.containsKey(name)) return 'v2';
    if (section == 'current') return 'current';
    final bySection = sectionBundles[section];
    if (bySection == null) {
      throw StateError('묶음을 정하지 못한 후보: $name ($section)');
    }
    return bySection;
  }

  Candidate make(String name, String section) {
    final group = groupOf(name);
    return Candidate(
      name: name,
      section: section,
      group: group,
      bundle: bundleOf(name, section),
      deferredTo: deferredRules[name],
    );
  }

  return [
    for (final e in featureSections.entries)
      for (final name in e.value) make(name, e.key),
    for (final e in extraCandidates.entries) make(e.key, e.value),
    for (final name in currentRules) make(name, 'current'),
    make(strictInference, 'option'),
  ];
}

/// 후보의 수를 단언한다 — 어긋난 것을 돌려준다 (비어 있으면 통과).
List<String> checkCandidates() {
  final problems = <String>[];
  void expect(String what, int actual, int expected) {
    if (actual != expected) problems.add('$what: $actual (기대 $expected)');
  }

  for (final e in featureSectionSizes.entries) {
    expect('절 ${e.key}', featureSections[e.key]?.length ?? 0, e.value);
  }
  final names = candidates.map((c) => c.name).toList();
  expect('후보', names.length, 133);
  expect('중복 없는 후보', names.toSet().length, 133);
  int count(bool Function(Candidate c) test) => candidates.where(test).length;
  expect('G1', count((c) => c.group == 'G1'), 113);
  expect('G2', count((c) => c.group == 'G2'), 4);
  expect('G3', count((c) => c.group == 'G3'), 2);
  expect('G4', count((c) => c.group == 'G4'), 7);
  expect('current', count((c) => c.group == 'current'), 6);
  expect('option', count((c) => c.group == 'option'), 1);
  expect('v2', count((c) => c.bundle == 'v2'), 12);
  expect(
    'v2 의 deferredTo',
    count((c) => c.bundle == 'v2' && c.deferredTo != null),
    12,
  );
  // 표식 상수 — 후보가 아닌 이름 · 표식과 표식 불가에 함께 있는 이름 · 지금 켜 둔 규칙의 표식.
  final known = names.toSet();
  for (final name in {
    ...ruleProbes.keys,
    ...ruleProbes313.keys,
    ...noFileProbe.keys,
  }) {
    if (!known.contains(name)) problems.add('표식 상수에 후보가 아닌 이름: $name');
  }
  for (final name in noFileProbe.keys) {
    if (ruleProbes.containsKey(name) || ruleProbes313.containsKey(name)) {
      problems.add('표식이 있는데 표식 불가에도 있다: $name');
    }
  }
  for (final name in currentRules) {
    if (ruleProbes.containsKey(name)) problems.add('지금 켜 둔 규칙의 표식: $name');
  }
  for (final name in ruleProbes313.keys) {
    if (!g4Rules.contains(name)) problems.add('G4 가 아닌 3.13 표식: $name');
  }
  // B-7 — 31개, 상태별 수, 후보와 겹치지 않음.
  expect('B-7', b7Rules.length, 31);
  for (final e in b7StateCounts.entries) {
    expect(
      'B-7 ${e.key}',
      b7Rules.values.where((v) => v == e.key).length,
      e.value,
    );
  }
  for (final name in b7Rules.keys) {
    if (known.contains(name)) problems.add('B-7 이 후보와 겹친다: $name');
  }
  for (final id in {...bundleRules.keys, ...candidates.map((c) => c.bundle)}) {
    if (!bundles.containsKey(id)) problems.add('이름이 없는 묶음: $id');
  }
  return problems;
}

/// 비호환 선언 쌍 10개 — spike 020 결과 JSON 의 `rules[].jsonIncompatible` (tag 3.13.4 의
/// `rules.json` 이 선언한 것)을 후보 133 ∪ 지금 켜 둔 6 으로 걸러 2026-10-13 에 셌다. 상류
/// `rules.json` 은 받지 않는다 — `state` 단계가 쌍마다 둘만 켠 분석으로 확인한다 (spike 020:
/// 한 옵션 파일에 모두 켜면 규칙 한 줄에 `incompatible_lint` 가 하나만 붙어 일부 쌍이 보이지 않았다).
const incompatiblePairs = [
  ('always_specify_types', 'avoid_types_on_closure_parameters'),
  ('always_specify_types', 'omit_local_variable_types'),
  ('always_specify_types', 'omit_obvious_local_variable_types'),
  ('always_specify_types', 'omit_obvious_property_types'),
  ('always_use_package_imports', 'prefer_relative_imports'),
  ('omit_local_variable_types', 'specify_nonobvious_local_variable_types'),
  ('omit_obvious_property_types', 'type_annotate_public_apis'),
  ('prefer_double_quotes', 'prefer_single_quotes'),
  ('prefer_final_in_for_each', 'unnecessary_final'),
  ('prefer_final_locals', 'unnecessary_final'),
];

/// 2026-10-13 에 lint 후보 132개의 `messages.yaml` 상태를 센 값 (spike 020 의 결과와 같다).
const expectedStateCounts = {'stable': 129, 'testing': 2, 'experimental': 1};

/// 재지 않고 `RULES.md` 의 켜지 않은 규칙 표에 상태만 적는 이름 (FEATURES.md B-7, D-01) → 상태.
///
/// FEATURES.md 256 ~ 273행 산문의 backtick 이름 가운데 deprecated 6 · removed 14 · Dart 3.13 에
/// 없는 2 · experimental 9 = 31. 2026-10-13 에 spike 020 결과 JSON 의 `rules[].messages` ·
/// `actualState13` 과 대조했다 — deprecated · removed 는 두 값이 같고, 없는 둘은 그 JSON 에 이름이
/// 없으며, experimental 9 는 `messages: experimental` 이다. `--audit` 이 이 이름들도 찾는다.
const b7Rules = <String, String>{
  'avoid_null_checks_in_equality_operators': 'deprecated',
  'avoid_private_typedef_functions': 'deprecated',
  'one_member_abstracts': 'deprecated',
  'prefer_final_parameters': 'deprecated',
  'unnecessary_await_in_return': 'deprecated',
  'use_if_null_to_convert_nulls_to_bools': 'deprecated',
  'always_require_non_null_named_parameters': 'removed',
  'avoid_as': 'removed',
  'avoid_returning_null': 'removed',
  'avoid_returning_null_for_future': 'removed',
  'avoid_unstable_final_fields': 'removed',
  'enable_null_safety': 'removed',
  'invariant_booleans': 'removed',
  'iterable_contains_unrelated_type': 'removed',
  'list_remove_unrelated_type': 'removed',
  'package_api_docs': 'removed',
  'prefer_bool_in_asserts': 'removed',
  'prefer_equal_for_default_values': 'removed',
  'super_goes_last': 'removed',
  'unsafe_html': 'removed',
  'future_sync_value': '없음',
  'unnecessary_this_alias': '없음',
  'annotate_redeclares': 'experimental',
  'avoid_futureor_void': 'experimental',
  'implicit_reopen': 'experimental',
  'invalid_case_patterns': 'experimental',
  'no_default_cases': 'experimental',
  'unnecessary_async': 'experimental',
  'unsafe_variance': 'experimental',
  'use_late_for_private_fields_and_variables': 'experimental',
  'var_with_no_type_annotation': 'experimental',
};

/// [b7Rules] 의 상태별 수 — 상수를 고치다 이름을 빠뜨리면 시작할 때 멈춘다.
const b7StateCounts = {
  'deprecated': 6,
  'removed': 14,
  '없음': 2,
  'experimental': 9,
};

// 표식 --------------------------------------------------------------------
//
// 규칙 이름 → 그 규칙을 어기는 Dart 소스. markers 단계가
// `lib/woody_probe_marker/rule_probe/<규칙>.dart` 로 넣는다 (D-03).
//
// 범위 (D-03, RULES-05): spike 022 에서 프로젝트 줄이 0 이었던 후보 62개(022 결과 JSON 의
// `rows[].diagProject == 0`), spike 021 `oldSamples` · `newSyntaxSamples` 와 023 `markers` 의 나머지,
// 022 가 빠뜨린 B-6 의 7개(그날의 복사본에서 0줄일 수 있어 미리 둔다). 지금 켜 둔 6개(`current`)는
// 표식을 두지 않는다 — `example/lib/added_rules.dart` 의 줄이 그 표식이다 (baseline 단계).
//
// 표식 하나는 그 규칙을 **확실히** 어기는 선언이다. 다른 규칙도 함께 어겨도 된다 — 표식 줄은
// `area == 'marker'` 로 갈라져 프로젝트 값에 섞이지 않는다. 파일 맨 위 `// ignore_for_file:` 을
// 쓰지 않고, `package:flutter/material.dart` 나 `dart:*` 만 import 한다 (복사본은 Flutter 앱이다).
// 근거는 FEATURES.md 의 "잡는 것" 과 tag 3.13.4 의 규칙 소스(`pkg/linter/lib/src/rules/<규칙>.dart`).
// 채택되면 D-10 의 샘플로 옮긴다 — 그때는 한 줄에 규칙 하나만 걸리게 고친다.

// 언어 버전 3.11 문법으로도 쓸 수 있는 G4 의 넷 — 3.11 판과 3.13 판이 같은 코드다 (spike 021 의
// `oldSamples`. 3.13 패키지에서 걸리고 3.11 패키지에서는 막는 조건 때문에 걸리지 않았다).
const _emptyContainerBodiesProbe = '''
/// 표식 — 몸통이 빈 클래스.
class EmptyBodyMarker {}
''';

const _unnecessaryConstInEnumProbe = '''
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
''';

const _unnecessaryTypeNameProbe = '''
/// 표식 — 생성자 선언에 적은 타입 이름.
class TypeNameMarker {
  /// 기본 생성자.
  TypeNameMarker();

  /// 이름 있는 생성자.
  TypeNameMarker.named();
}
''';

const _usePrimaryConstructorsProbe = '''
/// 표식 — 생성자 하나와 필드로 된 클래스.
class PointMarker {
  /// 생성자.
  PointMarker(this.x, this.y);

  /// x.
  final int x;

  /// y.
  final int y;
}
''';

/// 언어 버전 3.11 로 컴파일되는 표식 (G1 ~ G4 어디에나 넣을 수 있다).
/// 출발점은 spike 021 `probe.dart` 의 `oldSamples` 와 spike 023 `probe.dart` 의 `markers` 다.
///
/// G4 의 넷(`empty_container_bodies` · `unnecessary_const_in_enum_constructor` ·
/// `unnecessary_type_name_in_constructor` · `use_primary_constructors`)은 G1 의 marker 실행에도
/// 넣어 지금 하한에서 걸리는지를 행의 `markerDetectedCurrent` 에 적는다 (D-15 의 값 둘 가운데
/// "지금 하한" 쪽의 근거). G4 의 marker 실행은 [ruleProbes313] 의 판을 쓴다.
const ruleProbes = <String, String>{
  // B-1 버그 방지 ---------------------------------------------------------
  'async_return_with_no_await': '''
/// 표식 — async 함수가 Future 를 await 없이 돌려준다.
Future<String> asyncReturnMarker(Future<String> value) async {
  return value;
}
''',
  'avoid_double_and_int_checks': '''
/// 표식 — is double 검사 뒤의 is int 검사 (web 에서 뜻이 달라진다).
String numberKindMarker(num x) {
  if (x is double) {
    return 'double';
  } else if (x is int) {
    return 'int';
  }
  return 'other';
}
''',
  'avoid_js_rounded_ints': '''
/// 표식 — JavaScript 에서 정밀도가 깨지는 정수 리터럴.
const int jsRoundedMarker = 9007199254740993;
''',
  'avoid_type_to_string': '''
// 표식 — Type 을 implements 한 클래스의 toString(). `x.runtimeType.toString()` 은 tag 3.13.4 의
// SDK 에서 걸리지 않았다 — dart:core 의 Type 이 toString() 을 선언해, 규칙이 보는 "Object 의
// toString" 이 아니다 (2026-10-13, example/ 복사본).

/// 표식용 — Type 을 implements 하는 클래스.
class TypeLikeMarker implements Type {}

/// Type 의 toString() 결과에 기대는 코드.
String typeLikeNameMarker() => TypeLikeMarker().toString();
''',
  'avoid_unused_constructor_parameters': '''
/// 표식 — 쓰이지 않는 생성자 매개변수.
class UnusedParameterMarker {
  /// 생성자.
  UnusedParameterMarker(int unused);
}
''',
  'avoid_void_async': '''
/// 표식 — 반환 타입이 void 인 async 함수.
void voidAsyncMarker() async {
  await Future<void>.value();
}
''',
  'cancel_subscriptions': '''
import 'dart:async';

/// 표식 — cancel 하지 않는 StreamSubscription.
void subscriptionMarker(Stream<int> stream) {
  final StreamSubscription<int> subscription = stream.listen((_) {});
  subscription.pause();
}
''',
  'cast_nullable_to_non_nullable': '''
/// 표식용 타입.
class CastBaseMarker {}

/// 표식용 하위 타입.
class CastChildMarker extends CastBaseMarker {}

/// 표식 — nullable 값을 non-nullable 하위 타입으로 as.
CastChildMarker castMarker(CastBaseMarker? value) => value as CastChildMarker;
''',
  'conditional_uri_does_not_exist': '''
// 표식 — 조건부 import 가 가리키는 파일이 없다.
// (쓰지 않는 import 라 unused_import 도 함께 걸린다 — 고른 쪽이 없는 파일이면 이름을 못 찾는다.)
import 'dart:math' if (dart.library.io) 'woody_missing_probe_target.dart';

/// 값.
const int conditionalImportMarker = 1;
''',
  'deprecated_member_use_from_same_package': '''
/// 표식용 deprecated 함수.
@Deprecated('표식')
int deprecatedValueMarker() => 1;

/// 표식 — 같은 패키지 안에서 deprecated 멤버를 쓴다.
int useDeprecatedMarker() => deprecatedValueMarker();
''',
  'discarded_futures': '''
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
  'literal_only_boolean_expressions': '''
/// 표식 — 리터럴만으로 이루어진 조건식.
int literalConditionMarker() {
  if (1 > 2) {
    return 0;
  }
  return 1;
}
''',
  'matching_super_parameters': '''
/// 표식용 부모 클래스.
class SuperBaseMarker {
  /// 생성자.
  SuperBaseMarker(this.first, this.second);

  /// 첫째.
  final int first;

  /// 둘째.
  final int second;
}

/// 표식 — super 매개변수의 이름이 부모 생성자와 다르다 (순서 착오).
class SuperChildMarker extends SuperBaseMarker {
  /// 생성자.
  SuperChildMarker(super.second, super.first);
}
''',
  'no_dynamic_casts': '''
/// 표식 — dynamic 에서의 암묵적 cast.
int dynamicCastMarker(dynamic x) {
  final int y = x;
  return y;
}
''',
  'no_self_assignments': '''
/// 표식 — 자기 자신을 대입한다.
class SelfAssignMarker {
  /// 값.
  int value = 0;

  /// 같은 값을 다시 넣는다.
  void reset() {
    value = value;
  }
}
''',
  'parameter_assignments': '''
/// 표식 — 매개변수에 다시 대입한다.
int parameterAssignMarker(int x) {
  x = x + 1;
  return x;
}
''',
  'switch_on_type': '''
/// 표식 — runtimeType 으로 switch.
String switchTypeMarker(Object value) {
  switch (value.runtimeType) {
    case int:
      return 'int';
    default:
      return 'other';
  }
}
''',
  'test_types_in_equals': '''
/// 표식 — operator == 에서 인자의 타입을 검사하지 않는다.
class EqualsMarker {
  /// 생성자.
  const EqualsMarker(this.value);

  /// 값.
  final int value;

  @override
  bool operator ==(Object other) => (other as EqualsMarker).value == value;

  @override
  int get hashCode => value.hashCode;
}
''',
  'throw_in_finally': '''
/// 표식 — finally 안의 throw.
int throwInFinallyMarker() {
  try {
    return int.parse('1');
  } finally {
    throw StateError('표식');
  }
}
''',
  'unnecessary_statements': '''
/// 표식 — 효과가 없는 문장.
void statementMarker(int x) {
  x + 1;
}
''',
  // B-2 성능 --------------------------------------------------------------
  'avoid_slow_async_io': '''
import 'dart:io';

/// 표식 — 느린 dart:io async 메서드.
Future<bool> slowIoMarker() => File('woody_probe_missing.txt').exists();
''',
  'noop_primitive_operations': '''
/// 표식 — 효과 없는 원시 타입 연산.
int noopIntMarker(int x) => x.toInt();

/// 표식 — 문자열의 toString().
String noopStringMarker(String s) => s.toString();
''',
  'sized_box_shrink_expand': '''
import 'package:flutter/material.dart';

/// 표식 — SizedBox.shrink 로 쓸 수 있는 SizedBox.
Widget shrinkMarker() => const SizedBox(width: 0, height: 0);
''',
  'use_colored_box': '''
import 'package:flutter/material.dart';

/// 표식 — 색만 지정한 Container.
Widget coloredMarker() => Container(color: Colors.red, child: const Text('a'));
''',
  'use_string_buffers': '''
/// 표식 — 루프 안의 문자열 누적 연결.
String bufferMarker(List<String> parts) {
  var joined = '';
  for (final part in parts) {
    joined += part;
  }
  return joined;
}
''',
  'use_truncating_division': '''
/// 표식 — (a / b).toInt().
int truncatingDivisionMarker(int a, int b) => (a / b).toInt();
''',
  // B-3 가독성·스타일 ------------------------------------------------------
  'avoid_final_parameters': '''
// @dart=3.11
// 이 파일만 언어 버전 3.11 로 둔다 — 3.13 에서는 primary constructor 기능이 켜져 이 규칙이 돌지 않고
// (규칙 소스의 Feature.primary_constructors 조건) 보통 매개변수의 final 이 error(extraneous_modifier)
// 다. 3.11 은 사용 프로젝트의 지금 하한과 같다 — 하한을 3.13 으로 올리면 이 규칙은 꺼진다 (RULES-10).

/// 표식 — 매개변수 선언의 final.
int finalParameterMarker(final int x) => x;
''',
  'avoid_multiple_declarations_per_line': '''
/// 표식 — 한 줄에 변수 여러 개 선언.
int multipleDeclarationsMarker() {
  var a = 1, b = 2;
  return a + b;
}
''',
  'avoid_setters_without_getters': '''
/// 표식 — getter 없는 setter.
class SetterOnlyMarker {
  int _value = 0;

  /// setter 만 있다.
  set value(int v) {
    _value = v;
  }

  /// 값을 읽는다.
  int read() => _value;
}
''',
  'combinators_ordering': '''
// 표식 — show 의 이름이 정렬되어 있지 않다.
import 'dart:math' show sin, cos;

/// show 로 받은 이름을 쓰는 자리.
double combinatorsMarker() => sin(0) + cos(0);
''',
  'flutter_style_todos': '''
/// 표식 — Flutter 형식이 아닌 TODO.
// TODO: 표식
const int todoMarker = 1;
''',
  'leading_newlines_in_multiline_strings': '''
/// 표식 — 개행으로 시작하지 않는 여러 줄 문자열.
const String multilineMarker = """첫 줄
둘째 줄""";
''',
  'no_literal_bool_comparisons': '''
/// 표식 — bool 리터럴과의 비교.
bool boolComparisonMarker(bool b) => b == true;
''',
  'prefer_asserts_in_initializer_lists': '''
/// 표식 — 생성자 본문의 assert.
class AssertBodyMarker {
  /// 생성자.
  AssertBodyMarker(this.value) {
    assert(value > 0);
  }

  /// 값.
  final int value;
}
''',
  'prefer_final_in_for_each': '''
/// 표식 — 다시 대입하지 않는 for-in 변수에 final 이 없다.
int forEachMarker(List<int> values) {
  var sum = 0;
  for (var value in values) {
    sum += value;
  }
  return sum;
}
''',
  'prefer_null_aware_method_calls': '''
/// 표식 — null 검사 뒤의 f!() 호출.
void nullAwareCallMarker(void Function()? callback) {
  if (callback != null) callback!();
}
''',
  'simple_directive_paths': '''
// 표식 — 되돌아가는 `../` 가 낀 directive 경로 (자기 자신을 import 한다).
import '../rule_probe/simple_directive_paths.dart' as self_probe;

/// 값.
int simpleDirectiveMarker() => 1;

/// import 한 이름을 쓰는 자리.
int simpleDirectiveUseMarker() => self_probe.simpleDirectiveMarker();
''',
  'simplify_variable_pattern': '''
/// 표식 — 변수 pattern 에 같은 이름의 getter 를 다시 적는다.
int variablePatternMarker(Object value) {
  if (value case Duration(inSeconds: var inSeconds)) {
    return inSeconds;
  }
  return 0;
}
''',
  'sort_constructors_first': '''
/// 표식 — 생성자보다 앞에 둔 멤버.
class SortConstructorsMarker {
  /// 값.
  int get value => 1;

  /// 생성자.
  SortConstructorsMarker();
}
''',
  'sort_unnamed_constructors_first': '''
/// 표식 — 이름 없는 생성자보다 앞에 둔 이름 있는 생성자.
class SortUnnamedMarker {
  /// 이름 있는 생성자.
  SortUnnamedMarker.named();

  /// 이름 없는 생성자.
  SortUnnamedMarker();
}
''',
  'specify_nonobvious_property_types': '''
/// 표식 — 타입이 자명하지 않은 top-level 변수의 타입 누락.
final nonObviousPropertyMarker = int.parse('1');
''',
  'tighten_type_of_initializing_formals': '''
/// 표식 — assert 로 null 아님을 검사하는 nullable 초기화 매개변수.
class TightenMarker {
  /// 생성자.
  TightenMarker(this.value) : assert(value != null);

  /// 값.
  final String? value;
}
''',
  'unnecessary_breaks': '''
/// 표식 — 불필요한 break.
int breakMarker(int x) {
  var y = x;
  switch (x) {
    case 1:
      y++;
      break;
    default:
      y--;
  }
  return y;
}
''',
  'unnecessary_ignore': '''
/// 표식 — 아무것도 가리지 않는 무시 주석.
// ignore: avoid_print
int unnecessaryIgnoreMarker() => 1;
''',
  'unnecessary_library_directive': '''
// 표식 — 문서 주석도 annotation 도 없는 library 지시문.
library;

/// 값.
const int libraryDirectiveMarker = 1;
''',
  'unnecessary_null_aware_operator_on_extension_on_nullable': '''
/// 표식용 — nullable 타입의 extension.
extension NullableExtensionMarker on int? {
  /// null 이면 0.
  int get orZero => this ?? 0;
}

/// 표식 — nullable 대상 extension 에 쓴 ?.
int? nullAwareExtensionMarker(int? x) => x?.orZero;
''',
  'use_enums': '''
/// 표식 — enum 처럼 쓰는 클래스.
class EnumLikeMarker {
  const EnumLikeMarker._(this.value);

  /// 첫째.
  static const EnumLikeMarker first = EnumLikeMarker._(1);

  /// 둘째.
  static const EnumLikeMarker second = EnumLikeMarker._(2);

  /// 값.
  final int value;
}
''',
  'use_is_even_rather_than_modulo': '''
/// 표식 — % 2 == 0.
bool evenMarker(int x) => x % 2 == 0;
''',
  'use_named_constants': '''
/// 표식 — Duration.zero 대신 쓴 const Duration().
Duration namedConstantMarker() => const Duration();
''',
  // B-4 Dart 3.13 의 새 규칙 ------------------------------------------------
  'empty_container_bodies': _emptyContainerBodiesProbe,
  'no_raw_types': '''
/// 표식 — 타입 인자를 생략한 제네릭 타입.
class BoxMarker<T> {}

/// 타입 인자 없이 선언한 변수.
BoxMarker rawBoxMarker = BoxMarker<int>();
''',
  'unnecessary_const_in_enum_constructor': _unnecessaryConstInEnumProbe,
  'unnecessary_type_name_in_constructor': _unnecessaryTypeNameProbe,
  'use_primary_constructors': _usePrimaryConstructorsProbe,
  // B-5 API 문서 (v2 로 미룸 — 재기는 한다) ---------------------------------
  'deprecated_consistency': '''
/// 표식 — deprecated 클래스의 deprecated 아닌 생성자.
@Deprecated('표식')
class DeprecatedClassMarker {
  /// 생성자.
  DeprecatedClassMarker();
}
''',
  'missing_code_block_language_in_doc_comment': '''
/// 표식 — 언어를 적지 않은 doc comment 코드 블록.
///
/// ```
/// codeBlockMarker();
/// ```
void codeBlockMarker() {}
''',
  'public_member_api_docs': '''
// 표식 — 문서 주석이 없는 공개 멤버.
int publicDocsMarker() => 1;
''',
  // B-6 제외 권장 -----------------------------------------------------------
  'avoid_catches_without_on_clauses': '''
/// 표식 — on 절 없는 catch.
int catchMarker() {
  try {
    return int.parse('x');
  } catch (e) {
    return 0;
  }
}
''',
  'avoid_field_initializers_in_const_classes': '''
/// 표식 — const 클래스의 필드 초기화.
class ConstFieldInitMarker {
  /// 생성자.
  const ConstFieldInitMarker();

  /// 값.
  final int value = 1;
}
''',
  'avoid_returning_this': '''
/// 표식 — this 를 돌려주는 메서드.
class ReturnThisMarker {
  /// 자기 자신을 돌려준다.
  ReturnThisMarker touch() {
    return this;
  }
}
''',
  'cascade_invocations': '''
/// 표식 — 같은 대상에 이어지는 호출 (cascade 로 쓸 수 있다).
List<int> cascadeMarker() {
  final values = <int>[];
  values.add(1);
  values.add(2);
  return values;
}
''',
  'close_sinks': '''
import 'dart:async';

/// 표식 — close 하지 않는 sink.
void sinkMarker() {
  final controller = StreamController<int>();
  controller.add(1);
}
''',
  'eol_at_end_of_file': '''
/// 표식 — 끝에 줄바꿈이 없는 파일.
const int eolMarker = 1;''',
  'library_names': '''
/// 표식 — lower_case_with_underscores 가 아닌 라이브러리 이름.
library WoodyLibraryNameMarker;

/// 값.
const int libraryNameMarker = 1;
''',
  'lines_longer_than_80_chars': '''
/// 표식 — 80자를 넘는 줄.
const longLineMarker = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
''',
  'prefer_asserts_with_message': '''
/// 표식 — 메시지 없는 assert.
void assertMessageMarker(int x) {
  assert(x > 0);
}
''',
  'prefer_expression_function_bodies': '''
/// 표식 — return 하나뿐인 블록 몸통.
int expressionBodyMarker() {
  return 1;
}
''',
  'prefer_mixin': '''
// @dart=2.19
// 표식 — mixin 이 아닌 클래스를 with 로 섞는다. 언어 버전 3.0 이상에서는 그 자체가 error 라
// (class_used_as_mixin) 이 파일만 2.19 로 둔다 — 규칙은 언어 버전으로 막히지 않는다.

/// 섞이는 쪽.
class LegacyMixinMarker {}

/// 표식 — 클래스를 with 로 섞는다.
class UsesLegacyMixinMarker with LegacyMixinMarker {}
''',
  'prefer_void_to_null': '''
/// 표식 — void 대신 쓴 Null.
Future<Null> nullFutureMarker() async {}
''',
  'remove_deprecations_in_breaking_versions': '''
/// 표식 — 사용 프로젝트의 version 이 x.0.0 / 0.x.0 일 때 남은 @Deprecated.
@Deprecated('표식')
const int removeDeprecationMarker = 1;
''',
  'use_to_and_as_if_applicable': '''
/// 표식용 — 변환된 값.
class ToAsTargetMarker {
  /// 생성자.
  ToAsTargetMarker(this.source);

  /// 원래 값.
  final ToAsMarker source;
}

/// 표식 — 이름이 to / as 로 시작하지 않는 변환 메서드.
class ToAsMarker {
  /// 변환한다.
  ToAsTargetMarker convert() => ToAsTargetMarker(this);
}
''',
  // G2 ----------------------------------------------------------------------
  'type_annotate_public_apis': '''
/// 표식 — 타입 표기가 없는 공개 API 매개변수.
void typeAnnotateMarker(value) {}
''',
  // analyzer 옵션 ------------------------------------------------------------
  strictInference: '''
/// 표식 — 추론이 실패해 dynamic 이 되는 자리 (strict-inference).
List<Object?> strictInferenceMarker() {
  final empty = [];
  return empty;
}
''',
};

/// 언어 버전 3.13 문법으로 재는 G4 의 표식 — G4 실행(하한 `^3.13.0`)에만 넣는다. primary
/// constructor 문법이 든 셋은 지금 하한의 복사본에 넣으면 `experiment_not_enabled` error 가 난다
/// (Pitfall 6). 나머지 넷은 3.11 판([ruleProbes])과 같은 코드다 — 하한 3.13 에서만 걸린다.
/// 출발점은 spike 021 `probe.dart` 의 `newSyntaxSamples` · `oldSamples`.
const ruleProbes313 = <String, String>{
  'empty_container_bodies': _emptyContainerBodiesProbe,
  'unnecessary_type_name_in_constructor': _unnecessaryTypeNameProbe,
  'use_primary_constructors': _usePrimaryConstructorsProbe,
  'unnecessary_const_in_enum_constructor':
      '$_unnecessaryConstInEnumProbe'
      '''

/// 표식 — enum primary constructor 의 const.
enum const ConstEnumPrimaryMarker(final int i) {
  /// a.
  a(1),

  /// b.
  b(2);
}
''',
  'initialize_in_field_declaration': '''
/// 표식 — primary constructor 의 초기화 목록.
class InitInFieldMarker(int x) {
  this : y = x;

  /// y.
  int y;
}
''',
  'use_declaring_parameters': '''
/// 표식 — 선언 매개변수로 쓸 수 있는 매개변수.
class DeclaringMarker(int i) {
  /// i.
  final int i;

  this : i = i;
}
''',
  'unnecessary_primary_constructor_body': '''
/// 표식 — 빈 primary constructor 몸통.
class BodyMarker(final int i) {
  this;
}
''',
};

/// Dart 파일 하나(복사본의 `lib/woody_probe_marker/` 아래, `package:flutter/material.dart` 와
/// `dart:*` 만 import)로는 어길 수 없는 규칙 → 이유. 표식을 두지 않는다 — markers 단계는 이
/// 규칙을 `표식 없음` 으로 세지 않고 `표식 불가 (<이유>)` 로 따로 알리며 `markerDetected` 를
/// null 로 둔다. 이름 목록은 결과 JSON 의 `conditions.noFileProbe` 에 적혀 검증 명령과 `--report`
/// 가 같은 예외 집합을 읽는다.
const noFileProbe = <String, String>{
  'sort_pub_dependencies':
      'pubspec.yaml 을 본다 — Dart 파일 표식으로는 어길 수 없다 (값은 pubspec.yaml 자리에서 센다)',
  'use_test_throws_matchers':
      'package:test_api 의 fail() 을 찾는다 — flutter_test 를 import 하지 않는 lib/ 의 '
      '파일로는 어길 수 없다',
  'require_trailing_commas':
      '언어 버전 3.7 이상의 라이브러리에서는 돌지 않는다 (규칙 소스의 language37 조건) — '
      '사용 프로젝트의 하한에서 걸리는 파일이 없다',
  'package_prefixed_library_names':
      '규칙 소스(tag 3.13.4)의 visitLibraryDirective 가 곧바로 return 한다 — 아무것도 '
      '보고하지 않는다 (dart-lang/linter#3395)',
};

/// `--rules @probes` 가 뜻하는 이름 — [ruleProbes] ∪ [ruleProbes313] 의 이름 전부.
List<String> probeRuleNames() =>
    ({...ruleProbes.keys, ...ruleProbes313.keys}.toList()..sort());

// 인자 --------------------------------------------------------------------

/// 사용법 오류 — 종료 코드 64. 저장소에도 작업 폴더에도 아무것도 만들기 전에 던진다.
class UsageError implements Exception {
  /// [message] 는 화면에 그대로 찍는다.
  UsageError(this.message);

  /// 한 줄 설명.
  final String message;

  @override
  String toString() => message;
}

/// 하위 명령(pub get · dart analyze · dart fix)이 돌지 않았다 — 종료 코드 69.
class SubcommandFailure implements Exception {
  /// [message] 는 경로를 가린 뒤 찍는다.
  SubcommandFailure(this.message);

  /// 한 줄 설명.
  final String message;

  @override
  String toString() => message;
}

/// 사용법 한 덩어리.
const usage = '''
사용법: fvm dart run tool/measure_rules.dart --work <저장소 밖 작업 폴더> [--source <사용 프로젝트>]
          [--stage state,baseline,groups,markers,ignore,fix,unnecessary-ignore|all]
          [--rules a,b,…|@probes] [--probe-all] [--run-id R1] [--out <경로>]
   또는 (분석을 돌리지 않는 출력 모드):
        fvm dart run tool/measure_rules.dart --summary <묶음> [--in <결과 JSON> | --work <작업 폴더>] [--run-id R1]
        fvm dart run tool/measure_rules.dart --report [--write] [--in <결과 JSON> | --work <작업 폴더>] [--run-id R1]
        fvm dart run tool/measure_rules.dart --recount [--write] [--in <결과 JSON> | --work <작업 폴더>] [--run-id R1]
        fvm dart run tool/measure_rules.dart --audit
   묶음: bug, perf, style, current, excluded, strict, import, fire, pairs, status, v2, ui''';

/// 읽기만 한 인자 — 값이 있는 인자와 플래그 (검증 전).
class RawArgs {
  /// [values] 는 `--key` → 값, [flags] 는 준 플래그다.
  RawArgs(this.values, this.flags);

  /// 값이 있는 인자.
  final Map<String, String> values;

  /// 준 플래그.
  final Set<String> flags;

  /// 준 인자인지 (값 · 플래그 어느 쪽이든).
  bool has(String key) => values.containsKey(key) || flags.contains(key);

  /// 준 출력 모드 (`--summary` · `--report` · `--recount` · `--audit`).
  List<String> get outputModesGiven => [
    for (final m in outputModes)
      if (has(m)) m,
  ];
}

/// 인자를 값과 플래그로 나눠 읽는다. 모르는 인자 · 값 없는 인자 · 두 번 준 인자는 [UsageError].
RawArgs readRawArgs(List<String> args) {
  const valued = {
    '--source',
    '--work',
    '--stage',
    '--rules',
    '--run-id',
    '--out',
    '--in',
    '--summary',
  };
  const flags = {'--probe-all', '--report', '--recount', '--write', '--audit'};
  final values = <String, String>{};
  final seenFlags = <String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    final eq = arg.indexOf('=');
    final key = arg.startsWith('--') && eq > 0 ? arg.substring(0, eq) : arg;
    if (valued.contains(key)) {
      String value;
      if (eq > 0 && arg.startsWith('--')) {
        value = arg.substring(eq + 1);
      } else {
        if (i + 1 >= args.length || args[i + 1].startsWith('--')) {
          throw UsageError('값이 없는 인자: $key');
        }
        value = args[++i];
      }
      if (value.isEmpty) throw UsageError('값이 빈 인자: $key');
      if (values.containsKey(key)) throw UsageError('두 번 준 인자: $key');
      values[key] = value;
    } else if (flags.contains(arg)) {
      seenFlags.add(arg);
    } else {
      throw UsageError('모르는 인자: $arg');
    }
  }
  return RawArgs(values, seenFlags);
}

/// `--run-id` 를 읽는다 (기본 `R1`).
String readRunId(RawArgs raw) {
  final runId = raw.values['--run-id'] ?? 'R1';
  if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(runId)) {
    throw UsageError('--run-id 는 영문 · 숫자 · . _ - 만 쓴다: "$runId"');
  }
  return runId;
}

/// 읽은 인자 (단계를 돌리는 실행).
class Options {
  /// 검증은 [parseArgs] 가 한다.
  Options({
    required this.work,
    required this.source,
    required this.stages,
    required this.rules,
    required this.probeAll,
    required this.runId,
    required this.out,
  });

  /// 작업 폴더의 절대 경로 (저장소 밖).
  final String work;

  /// 사용 프로젝트 원본의 링크를 푼 절대 경로, 또는 null.
  final String? source;

  /// 돌릴 단계 — [allStages] 의 순서.
  final List<String> stages;

  /// 범위를 좁힌 규칙 이름, 또는 null (후보 전부).
  final Set<String>? rules;

  /// markers 단계가 범위의 규칙 전부에 표식을 넣는지.
  final bool probeAll;

  /// 회차 묶음의 id (결과 파일 이름).
  final String runId;

  /// `--out` 으로 준 경로 (절대), 또는 null (기본 자리).
  final String? out;

  /// 이 실행에 복사본 단계가 있는지.
  bool get hasConsumerStage => stages.any(consumerStages.contains);

  /// [name] 이 이번 범위에 드는지.
  bool inScope(String name) => rules == null || rules!.contains(name);
}

/// 단계를 돌리는 실행의 인자를 읽고 검증한다. 틀리면 [UsageError] 다 — 이 함수는 파일을
/// 만들지 않는다. 출력 모드(`--summary` · `--report` · `--audit`)는 [parseOutputArgs] 가 읽는다.
Options parseArgs(List<String> args, Repo repo) {
  final raw = readRawArgs(args);
  final values = raw.values;
  final seenFlags = raw.flags;
  if (raw.outputModesGiven.isNotEmpty) {
    throw UsageError('출력 모드는 단계와 함께 돌지 않는다 — parseOutputArgs 로 읽는다');
  }
  if (raw.has('--write')) throw UsageError('--write 는 --report 와 함께만 쓴다');
  if (raw.has('--in')) {
    throw UsageError('--in 은 출력 모드(--summary · --report)에만 쓴다');
  }

  final workArg = values['--work'];
  if (workArg == null) throw UsageError('--work 는 늘 필요하다');
  final work = absoluteNormalized(workArg);
  if (isWithin(resolveLoosely(work), repo.root)) {
    throw UsageError('--work 는 저장소 밖이어야 한다 — 지문의 git status 가 깨진다');
  }

  final stageArg = values['--stage'] ?? 'all';
  final requested = <String>{};
  for (final s in stageArg.split(',').map((s) => s.trim())) {
    if (s == 'all') {
      requested.addAll(defaultStages);
    } else if (allStages.contains(s)) {
      requested.add(s);
    } else {
      throw UsageError('모르는 단계: "$s" (허용: ${allStages.join(', ')}, all)');
    }
  }
  final stages = [
    for (final s in allStages)
      if (requested.contains(s)) s,
  ];

  Set<String>? rules;
  final rulesArg = values['--rules'];
  if (rulesArg != null) {
    rules = <String>{};
    for (final r in rulesArg.split(',').map((r) => r.trim())) {
      if (r == '@probes') {
        rules.addAll(probeRuleNames());
      } else if (candidateByName.containsKey(r)) {
        rules.add(r);
      } else {
        throw UsageError('후보에 없는 규칙: "$r"');
      }
    }
    if (rules.isEmpty) throw UsageError('--rules 가 비었다 (@probes 에 이름이 없다)');
  }

  final runId = readRunId(raw);

  String? source;
  final sourceArg = values['--source'];
  if (sourceArg != null) {
    final dir = Directory(absoluteNormalized(sourceArg));
    if (!dir.existsSync()) throw UsageError('--source 폴더가 없다');
    if (!File('${dir.path}/pubspec.yaml').existsSync()) {
      throw UsageError('--source 폴더에 pubspec.yaml 이 없다');
    }
    source = dir.resolveSymbolicLinksSync();
    final resolvedWork = resolveLoosely(work);
    if (isWithin(resolvedWork, source) || isWithin(source, resolvedWork)) {
      throw UsageError('--work 와 --source 는 서로의 안에 둘 수 없다');
    }
  }
  final hasConsumer = stages.any(consumerStages.contains);
  if (hasConsumer &&
      source == null &&
      !Directory('$work/pristine').existsSync()) {
    throw UsageError('복사가 필요하다 — 작업 폴더에 pristine/ 이 없으니 --source 를 준다');
  }

  final outArg = values['--out'];
  return Options(
    work: work,
    source: source,
    stages: stages,
    rules: rules,
    probeAll: seenFlags.contains('--probe-all'),
    runId: runId,
    out: outArg == null ? null : absoluteNormalized(outArg),
  );
}

/// 출력 모드의 인자 — 분석을 돌리지 않고 결과 JSON(또는 `RULES.md`)만 읽는다.
class OutputOptions {
  /// 검증은 [parseOutputArgs] 가 한다.
  OutputOptions({
    required this.mode,
    required this.bundle,
    required this.write,
    required this.inPath,
    required this.work,
    required this.runId,
  });

  /// `--summary` / `--report` / `--recount` / `--audit`.
  final String mode;

  /// `--summary` 의 묶음 id ([bundles] 의 키), 그 밖에는 null.
  final String? bundle;

  /// `--report --write` · `--recount --write` 인지.
  final bool write;

  /// `--in` 으로 준 결과 JSON (절대), 또는 null.
  final String? inPath;

  /// `--work` 로 준 작업 폴더 (절대), 또는 null — `<work>/results/<run id>.json` 을 찾는다.
  final String? work;

  /// 찾을 결과의 run id.
  final String runId;
}

/// 출력 모드의 인자를 검증한다 — 모드는 하나만, 단계용 인자는 받지 않는다. 틀리면 [UsageError].
OutputOptions parseOutputArgs(RawArgs raw) {
  final modes = raw.outputModesGiven;
  if (modes.length != 1) {
    throw UsageError('출력 모드는 하나만 준다: ${modes.join(', ')}');
  }
  final mode = modes.single;
  for (final key in [
    '--source',
    '--stage',
    '--rules',
    '--probe-all',
    '--out',
  ]) {
    if (raw.has(key)) throw UsageError('$key 는 출력 모드($mode)에 쓰지 않는다');
  }
  if (raw.has('--write') && mode != '--report' && mode != '--recount') {
    throw UsageError('--write 는 --report · --recount 와 함께만 쓴다');
  }
  if (mode == '--audit') {
    for (final key in ['--in', '--work', '--run-id']) {
      if (raw.has(key)) {
        throw UsageError('--audit 은 RULES.md 만 읽는다 — $key 를 쓰지 않는다');
      }
    }
  }
  String? bundle;
  if (mode == '--summary') {
    bundle = raw.values['--summary'];
    if (!bundles.containsKey(bundle)) {
      throw UsageError('모르는 묶음: "$bundle" (허용: ${bundles.keys.join(', ')})');
    }
  }
  final inArg = raw.values['--in'];
  final workArg = raw.values['--work'];
  return OutputOptions(
    mode: mode,
    bundle: bundle,
    write: raw.has('--write'),
    inPath: inArg == null ? null : absoluteNormalized(inArg),
    work: workArg == null ? null : absoluteNormalized(workArg),
    runId: readRunId(raw),
  );
}

/// [path] 를 절대 경로로 만들고 `.` · `..` 를 푼다 (끝의 `/` 는 뗀다).
String absoluteNormalized(String path) {
  final p = Directory(path).absolute.uri.normalizePath().toFilePath();
  return p.length > 1 && p.endsWith('/') ? p.substring(0, p.length - 1) : p;
}

/// 아직 없을 수 있는 [path] 의 링크를 푼다 — 있는 가장 가까운 조상의 링크를 풀고 나머지를 잇는다.
String resolveLoosely(String path) {
  var head = path;
  final tail = <String>[];
  while (!Directory(head).existsSync() && !File(head).existsSync()) {
    final cut = head.lastIndexOf('/');
    if (cut <= 0) return path;
    tail.insert(0, head.substring(cut + 1));
    head = head.substring(0, cut);
  }
  final resolved = Directory(head).existsSync()
      ? Directory(head).resolveSymbolicLinksSync()
      : File(head).resolveSymbolicLinksSync();
  return [resolved, ...tail].join('/');
}

/// [path] 가 [root] 자신이거나 그 아래인지 (`/a/bc` 는 `/a/b` 의 아래가 아니다).
bool isWithin(String path, String root) =>
    path == root || path.startsWith(root.endsWith('/') ? root : '$root/');

// 저장소 · 진단 · 분석 한 번 --------------------------------------------------

/// 작업 중인 저장소 (spike 021 `consumer.dart` 의 `Repo`).
class Repo {
  /// [root] 는 링크를 푼 절대 경로다.
  Repo(this.root);

  /// 링크를 푼 절대 경로.
  final String root;

  /// 저장소가 바뀌었는지 보는 지문 — git 이 보는 변경, 무시되는 `.dart_tool/` 의 맨 위 이름들,
  /// 루트 `package_config.json` · `pubspec.lock` 의 해시.
  Future<String> fingerprint() async {
    final status = await Process.run('git', [
      'status',
      '--porcelain',
    ], workingDirectory: root);
    if (status.exitCode != 0) {
      throw SubcommandFailure('git status 가 돌지 않았다 (exit ${status.exitCode})');
    }
    String fileDigest(String rel) {
      final f = File('$root/$rel');
      return f.existsSync() ? digest(f.readAsBytesSync()) : '-';
    }

    final tool = Directory('$root/.dart_tool');
    final top = tool.existsSync()
        ? (tool.listSync().map((e) => e.path.split('/').last).toList()..sort())
              .join(',')
        : '-';
    return [
      '${status.stdout}',
      top,
      fileDigest('.dart_tool/package_config.json'),
      fileDigest('pubspec.lock'),
    ].join('|');
  }
}

/// 정답지 형식 한 줄 (`상대경로:줄  강도  규칙이름`) 과 그 자리.
class Diag {
  /// [path] 는 복사본 기준 상대 경로다 (떼지 못하면 절대 경로 그대로).
  Diag(this.path, this.line, this.severity, this.code);

  /// 복사본 기준 상대 경로.
  final String path;

  /// 1부터 세는 줄 번호.
  final int line;

  /// 소문자 강도 (`info` / `warning` / `error`).
  final String severity;

  /// 진단 코드.
  final String code;

  /// 표식을 넣는 폴더 (복사본 기준).
  static const markerDir = 'lib/woody_probe_marker/';

  /// marker / generated / lib / test / bin / 그 밖의 파일 이름.
  String get area {
    if (path.startsWith(markerDir)) return 'marker';
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return 'generated';
    }
    final slash = path.indexOf('/');
    return slash < 0 ? path : path.substring(0, slash);
  }

  /// 프로젝트 값을 나누는 자리 (`lib` · `test` · `bin`) 에 드는지.
  bool get inProjectArea => projectAreas.contains(area);

  /// 정답지 형식 한 줄.
  String get text => '$path:$line  $severity  $code';
}

/// Dart 소스 자리 — 파일 수 · 표식 · 무시 주석 걷기에 쓴다.
const projectAreas = ['lib', 'test', 'bin'];

/// `pubspec.yaml` 에 보고되는 진단의 자리 (`Diag.area` 가 파일 이름 그대로 돌려준다).
const pubspecArea = 'pubspec.yaml';

/// 규칙의 값을 나누는 자리 (D-02) — Dart 소스 자리 셋 + `pubspec.yaml` 에 보고되는
/// 규칙(`sort_pub_dependencies`)의 자리. 04-REVIEW.md CR-01.
const valueAreas = ['lib', 'test', 'bin', pubspecArea];

/// [code] 가 후보 [rule] 의 진단인지 — `strict-inference` 는 `inference_failure_on_*` 전부다.
bool codeMatchesRule(String code, String rule) => rule == strictInference
    ? code.startsWith('inference_failure_on_')
    : code == rule;

/// 분석 한 번의 결과 (spike 021 `consumer.dart` 의 `Shot`).
class Shot {
  /// [id] 는 회차 이름이다 (`B0`, `G1`, `apply-<규칙>` …).
  Shot(this.id);

  /// 회차 이름.
  final String id;

  /// `dart analyze` 의 종료 코드.
  int exitCode = -1;

  /// 걸린 시간.
  int elapsedMs = 0;

  /// stdout 에서 JSON 을 읽었는지.
  bool jsonOk = false;

  /// stderr 에 plugin 준비 실패의 머리말이 있었는지.
  bool pluginHeader = false;

  /// 상태 폴더의 `.plugin_manager` 아래 폴더 수.
  int pluginFolders = -1;

  /// 풀린 `riverpod_lint` 버전 (plugin 폴더가 하나일 때만 읽는다).
  String pluginVersion = '?';

  /// `woody_lints` 를 받은 자리 — `repo` / `git` / `?`.
  String woodySource = '?';

  /// 진단 전부.
  final diags = <Diag>[];

  /// 표식 폴더의 진단.
  Iterable<Diag> get marker => diags.where((d) => d.area == 'marker');

  /// 표식이 아닌 진단 (생성 파일 · 옵션 파일 포함).
  Iterable<Diag> get project => diags.where((d) => d.area != 'marker');

  /// 자리 → 규칙 → 건수.
  Map<String, Map<String, int>> countByAreaCode([Iterable<Diag>? only]) {
    final out = <String, Map<String, int>>{};
    for (final d in only ?? diags) {
      final m = out.putIfAbsent(d.area, () => <String, int>{});
      m.update(d.code, (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }

  /// 표식이 아닌 진단의 강도 → 코드 → 건수 (`dart fix` 뒤 새 error 를 셀 때 쓴다).
  Map<String, Map<String, int>> projectBySeverity() {
    final out = <String, Map<String, int>>{};
    for (final d in project) {
      out
          .putIfAbsent(d.severity, () => <String, int>{})
          .update(d.code, (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }

  /// 결과 파일에 쓰는 모양 — 사용 프로젝트의 경로와 메시지가 없다. 표식의 줄은 이 저장소의
  /// 샘플이라 전문을 남긴다.
  Map<String, Object> toJson() => {
    'id': id,
    'exitCode': exitCode,
    'elapsedMs': elapsedMs,
    'jsonOk': jsonOk,
    'pluginHeader': pluginHeader,
    'pluginFolders': pluginFolders,
    'plugin': pluginVersion,
    'woodySource': woodySource,
    'lines': {
      'all': diags.length,
      'marker': marker.length,
      'project': project.length,
    },
    'countByAreaCode': countByAreaCode(),
    'projectBySeverity': projectBySeverity(),
    'projectDigest': digest(
      utf8.encode((project.map((d) => d.text).toList()..sort()).join('\n')),
    ),
    'markerLines': (marker.map((d) => d.text).toList()..sort()),
  };
}

/// 회차 하나 — 분석 결과([Shot])와 그 조건, 유효성 (RULES-05).
class Run {
  /// 조건은 회차를 만든 순간의 복사본에서 읽는다.
  Run({
    required this.shot,
    required this.conditions,
    required this.options,
    required this.expectedCovered,
    required this.valid,
    this.ignoresStripped = 0,
    this.markersReported,
  });

  /// 분석 결과.
  final Shot shot;

  /// `date` · `at` · `dart` · `flutter` · `baseSet` · `languageVersion` · `sdkConstraint` · `dartFiles`.
  final Map<String, Object?> conditions;

  /// 그 회차의 옵션 — 켠 후보 규칙 이름 · analyzer 언어 옵션 · SDK 하한(바꾸지 않았으면 null).
  final Map<String, Object?> options;

  /// 그 시점의 `example/` 정답지 줄이 표식 줄에 다 있는지.
  final bool expectedCovered;

  /// 회차를 써도 되는지 — 받은 자리 · 정답지 · plugin · JSON 이 모두 성립.
  final bool valid;

  /// 걷어낸 무시 주석 수 (0 이면 둔 채로 잰 회차).
  final int ignoresStripped;

  /// marker 회차에서 규칙 → 표식 검출 여부 (표식 없음은 null). 그 밖의 회차는 null.
  final Map<String, bool?>? markersReported;

  /// 결과 JSON 의 `runs[]` 항목 — [Shot.toJson] 에 조건과 판정을 더한다.
  Map<String, Object?> toJson() {
    final shotJson = shot.toJson();
    return {
      'id': shot.id,
      ...conditions,
      'options': options,
      ...shotJson..remove('id'),
      'ignoresStripped': ignoresStripped,
      'expectedCovered': expectedCovered,
      'markersReported': markersReported,
      'valid': valid,
    };
  }
}

// 결과 JSON ---------------------------------------------------------------

/// `<work>/results/<run id>.json` — 읽어서 합쳐 쓴다 (없으면 새로).
class Results {
  /// [path] 의 파일을 [data] 로 다룬다.
  Results._(this.path, this.data);

  /// 결과 파일의 경로.
  final String path;

  /// JSON 그대로.
  final Map<String, dynamic> data;

  /// 파일이 있으면 읽고, 없으면 새 뼈대를 만든다. 후보의 행은 늘 133개로 맞춘다.
  factory Results.load(String path, String runId) {
    final file = File(path);
    Map<String, dynamic> data;
    if (file.existsSync()) {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map<String, dynamic> ||
          decoded['schema'] != schemaVersion) {
        throw const FormatException('결과 JSON 의 schema 가 1 이 아니다');
      }
      if (decoded['runId'] != runId) {
        throw FormatException('결과 JSON 의 runId 가 ${decoded['runId']} 다');
      }
      data = decoded;
    } else {
      data = {
        'schema': schemaVersion,
        'runId': runId,
        'conditions': <String, dynamic>{
          'date': localDate(),
          'dart': null,
          'flutter': null,
          'baseSet': <String, dynamic>{'repo': null, 'consumer': null},
          'plugin': null,
          'languageVersion': null,
          'sdkConstraint': null,
          'dartFiles': null,
          'stateSource': null,
          'incompatiblePairs': <Object>[],
          'unnecessaryIgnoreNames': null,
          'noFileProbe': null,
        },
        'runs': <Object>[],
        'rows': <String, dynamic>{},
      };
    }
    final results = Results._(path, data);
    results._syncRows();
    return results;
  }

  /// 회차 묶음 전체의 조건.
  Map<String, dynamic> get conditions =>
      data['conditions'] as Map<String, dynamic>;

  /// 회차 목록.
  List<dynamic> get runs => data['runs'] as List<dynamic>;

  /// 규칙 이름 → 행.
  Map<String, dynamic> get rows => data['rows'] as Map<String, dynamic>;

  /// 행 하나.
  Map<String, dynamic> row(String name) => rows[name] as Map<String, dynamic>;

  /// [id] 회차 (없으면 null).
  Map<String, dynamic>? run(String id) {
    for (final r in runs.cast<Map<String, dynamic>>()) {
      if (r['id'] == id) return r;
    }
    return null;
  }

  /// 회차를 더한다 — 같은 id 가 있으면 바꾼다.
  void addRun(Run run) {
    final json = run.toJson();
    final i = runs.indexWhere((r) => (r as Map)['id'] == run.shot.id);
    if (i >= 0) {
      runs[i] = json;
    } else {
      runs.add(json);
    }
  }

  /// 행의 `runs` 에 회차 id 를 더한다 (중복 없이).
  void noteRun(String rule, String runId) {
    final list = row(rule)['runs'] as List<dynamic>;
    if (!list.contains(runId)) list.add(runId);
  }

  /// 후보마다 행을 두고 분류 칸을 상수에 맞춘다 (잰 값은 건드리지 않는다).
  void _syncRows() {
    for (final c in candidates) {
      final row = (rows[c.name] as Map<String, dynamic>?) ?? emptyRow();
      for (final e in emptyRow().entries) {
        row.putIfAbsent(e.key, () => e.value);
      }
      row['section'] = c.section;
      row['group'] = c.group;
      row['bundle'] = c.bundle;
      row['deferredTo'] = c.deferredTo;
      row['askIndividually'] = c.askIndividually;
      row['hasProbe'] = c.group == 'current' || hasProbe(c);
      rows[c.name] = row;
    }
  }

  /// 아직 재지 않은 행 — 값 칸은 null.
  static Map<String, dynamic> emptyRow() => {
    'section': null,
    'group': null,
    'bundle': null,
    'deferredTo': null,
    'askIndividually': null,
    'state': null,
    'upstream': null,
    'incompatible': <Object>[],
    'incompatibleLintRuns': <Object>[],
    'severity': null,
    'counts': null,
    'counts313': null,
    'aloneDry': null,
    'fixRemoved': null,
    'newErrors': null,
    'otherDelta': null,
    'ignored': null,
    'markerDetected': null,
    'markerDetectedCurrent': null,
    'hasProbe': null,
    'countsUI': null,
    'runs': <Object>[],
    'invalidRuns': <Object>[],
  };

  /// 보기 좋게 들여 쓴 JSON (끝에 줄바꿈).
  String encode() => '${const JsonEncoder.withIndent('  ').convert(data)}\n';

  /// 작업 폴더에 쓴다.
  void save() {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(encode());
  }

  /// 이 실행이 더하거나 바꾼 회차 가운데 유효하지 않은 것의 id.
  List<String> invalidRuns(Iterable<String> ids) => [
    for (final id in ids)
      if (run(id)?['valid'] != true) id,
  ];
}

/// [c] 에 표식이 있는지 — G4 는 3.13 문법 표식도 쓴다. [noFileProbe] 의 규칙은 false 다.
bool hasProbe(Candidate c) =>
    ruleProbes.containsKey(c.name) ||
    (c.group == 'G4' && ruleProbes313.containsKey(c.name));

/// 오늘 날짜 (로컬, `YYYY-MM-DD`).
String localDate() => DateTime.now().toIso8601String().substring(0, 10);

// 사용 프로젝트의 복사본 ------------------------------------------------------

/// 사용 프로젝트의 복사본 (spike 021 `consumer.dart` 의 `Consumer`).
///
/// 원본(`source`)은 `<work>/pristine/` 으로 한 번 복사할 때 [File.copySync] 의 원본 인자로만 쓴다.
/// 그 뒤의 복원은 모두 `pristine/` 에서 한다 — 그래서 뒤의 실행은 `--source` 없이 돈다.
class Consumer {
  /// [work] 는 저장소 밖 작업 폴더의 절대 경로다.
  Consumer({required this.work, required this.repo, this.source})
    : dir = '$work/consumer',
      pristine = '$work/pristine';

  /// 작업 폴더.
  final String work;

  /// 작업 중인 저장소.
  final Repo repo;

  /// 원본의 경로 — 인자로 받는다. 스크립트에 적지 않는다.
  final String? source;

  /// 분석하는 복사본.
  final String dir;

  /// 원본 그대로의 사본 — 복원의 출처.
  final String pristine;

  /// 복사본에서 바꿔 쓰는 폴더.
  static const trees = ['lib', 'test', 'bin', 'assets'];

  /// 맨 위에서 옮기는 파일.
  static const topFiles = [
    'pubspec.yaml',
    'pubspec.lock',
    'analysis_options.yaml',
    'l10n.yaml',
  ];

  /// 마지막 `pub get` 을 한 때의 `pubspec.yaml` 내용 (같으면 다시 받지 않는다).
  String? _resolvedPubspec;

  String get _dart => Platform.resolvedExecutable;

  /// 원본의 `pubspec.yaml`.
  String get originalPubspec =>
      File('$pristine/pubspec.yaml').readAsStringSync();

  /// 원본의 `analysis_options.yaml`.
  String get originalOptions =>
      File('$pristine/analysis_options.yaml').readAsStringSync();

  /// 원본의 SDK 제약 (`environment:` 블록의 `sdk:`).
  String get originalSdkConstraint => environmentSdk(originalPubspec).value;

  /// 지금 복사본의 SDK 제약.
  String get sdkConstraint =>
      environmentSdk(File('$dir/pubspec.yaml').readAsStringSync()).value;

  /// 원본을 `pristine/` 으로 옮기고 그것으로 복사본을 새로 만든다. 원본은 읽기만 한다.
  void copy() {
    final from = source;
    if (from == null) throw StateError('복사할 원본(--source)이 없다');
    _reset(pristine);
    for (final name in topFiles) {
      final file = File('$from/$name');
      if (file.existsSync()) file.copySync('$pristine/$name');
    }
    for (final name in trees) {
      _copyTree(from, pristine, name);
    }
    if (!File('$pristine/analysis_options.yaml').existsSync() ||
        !originalOptions.contains(
          'include: package:woody_lints/analysis_options.yaml',
        )) {
      throw const FormatException(
        '복사본의 옵션 파일이 옛 주소를 include 하지 않는다 — 사용 프로젝트가 바뀌었다',
      );
    }
    environmentSdk(originalPubspec); // 모양이 다르면 여기서 멈춘다
    rebuild();
  }

  /// `pristine/` 에서 복사본을 통째로 새로 만든다 (패키지는 다시 받아야 한다).
  void rebuild() {
    _reset(dir);
    for (final name in topFiles) {
      final file = File('$pristine/$name');
      if (file.existsSync()) file.copySync('$dir/$name');
    }
    for (final name in trees) {
      _copyTree(pristine, dir, name);
    }
    _resolvedPubspec = null;
  }

  void _reset(String path) {
    final d = Directory(path);
    if (d.existsSync()) d.deleteSync(recursive: true);
    d.createSync(recursive: true);
  }

  int _copyTree(String fromRoot, String toRoot, String name) {
    final from = Directory('$fromRoot/$name');
    if (!from.existsSync()) return 0;
    var n = 0;
    for (final f
        in from
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()) {
      final to = File('$toRoot/$name${f.path.substring(from.path.length)}');
      to.parent.createSync(recursive: true);
      f.copySync(to.path);
      n++;
    }
    return n;
  }

  /// `dart fix --apply` · 표식 · 주석 걷어내기로 바뀐 소스를 원본의 것으로 되돌린다 (표식은 다시 넣는다).
  void refreshSources() {
    for (final name in trees) {
      final d = Directory('$dir/$name');
      if (d.existsSync()) d.deleteSync(recursive: true);
      _copyTree(pristine, dir, name);
    }
  }

  /// SDK 하한만 바꾸고 패키지를 다시 받는다 (`null` 이면 원본 그대로).
  /// `pubspec.yaml` 만 바꾸고 `pub get` 을 하지 않으면 `package_config.json` 의 `languageVersion`
  /// 이 앞의 값으로 남는다 (spike 022).
  Future<void> useSdk(String? constraint) async {
    final text = constraint == null
        ? originalPubspec
        : pubspecWithSdk(constraint);
    if (text == _resolvedPubspec &&
        File('$dir/.dart_tool/package_config.json').existsSync()) {
      return;
    }
    setPubspec(text);
    await pubGet();
  }

  /// 복사본 패키지 자신의 언어 버전 (`package_config.json`).
  String languageVersion() {
    final config = File('$dir/.dart_tool/package_config.json');
    if (!config.existsSync()) return '?';
    final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
    final name = RegExp(
      r'^name: (\S+)',
      multiLine: true,
    ).firstMatch(originalPubspec)?.group(1);
    final p = (json['packages'] as List).cast<Map<String, dynamic>>().where(
      (p) => p['name'] == name,
    );
    return p.length == 1 ? '${p.single['languageVersion']}' : '?';
  }

  /// `woody_lints` 를 작업 중인 저장소로 돌리고 패키지를 받는다.
  Future<void> pointToRepo() async {
    File('$dir/pubspec_overrides.yaml').writeAsStringSync(
      'dependency_overrides:\n  woody_lints:\n    path: ${repo.root}\n',
    );
    _resolvedPubspec = null;
    await pubGet();
  }

  /// 복사본에서 `dart pub get` — 실패하면 [SubcommandFailure] (종료 코드 69).
  Future<void> pubGet() async {
    final r = await Process.run(_dart, [
      '--suppress-analytics',
      'pub',
      'get',
      '--no-example',
    ], workingDirectory: dir);
    if (r.exitCode != 0) {
      File('${_private()}/pub-get.txt')
          .writeAsStringSync('${r.stdout}\n--- stderr\n${r.stderr}');
      throw SubcommandFailure(
        '복사본의 pub get 이 실패했다 (exit ${r.exitCode}) — 원문은 <work>/private/pub-get.txt',
      );
    }
    _resolvedPubspec = File('$dir/pubspec.yaml').readAsStringSync();
  }

  /// `package_config.json` 의 `woody_lints` 가 가리키는 자리 — `repo` / `git` / `?`.
  String woodySource() {
    final config = File('$dir/.dart_tool/package_config.json');
    if (!config.existsSync()) return '?';
    final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
    final p = (json['packages'] as List)
        .cast<Map<String, dynamic>>()
        .where((p) => p['name'] == 'woody_lints')
        .toList();
    if (p.length != 1) return '?';
    final uri = '${p.single['rootUri']}';
    if (uri.contains('/git/woody_lints-')) return 'git';
    final d = packageRootDir(dir, uri);
    if (!d.existsSync()) return '?';
    return d.resolveSymbolicLinksSync() == repo.root ? 'repo' : '?';
  }

  /// 받은 자리가 작업 중인 저장소가 아니면 [StateError] — 부르는 쪽이 매번 부른다.
  void ensureRepoSource(Shot shot) {
    if (shot.woodySource != 'repo') {
      throw StateError(
        '${shot.id}: woody_lints 가 작업 중인 저장소를 가리키지 않는다 (${shot.woodySource})',
      );
    }
  }

  /// 복사본의 옵션 파일을 [text] 로 바꾼다.
  void setOptions(String text) =>
      File('$dir/analysis_options.yaml').writeAsStringSync(text);

  /// 복사본의 `pubspec.yaml` 을 [text] 로 바꾼다.
  void setPubspec(String text) =>
      File('$dir/pubspec.yaml').writeAsStringSync(text);

  /// 원본 옵션 파일에 규칙을 더 켜고, 필요하면 `analyzer.language` 를 더한 문자열.
  ///
  /// 규칙은 원본의 `rules:` 뒤에 그 블록의 형식(목록 `- r` / 맵 `r: true`)으로 끼운다.
  /// 원본에 `linter:` 가 없으면(include 한 줄짜리 옵션 파일) 블록을 새로 붙인다.
  String optionsWith({
    List<String> rules = const [],
    Map<String, bool> language = const {},
  }) {
    var text = originalOptions;
    if (!text.endsWith('\n')) text = '$text\n';
    if (rules.isNotEmpty) text = insertRules(text, rules);
    if (language.isNotEmpty) text = insertLanguage(text, language);
    return text;
  }

  /// 원본 `pubspec.yaml` 의 SDK 하한만 바꾼 문자열.
  String pubspecWithSdk(String constraint) =>
      environmentSdk(originalPubspec).replace(constraint);

  /// 표식 — 이 저장소 `example/lib` 의 샘플을 `lib/woody_probe_marker/` 로 (저장소는 읽기만).
  /// 샘플이 자기 패키지를 `package:` 로 부르는 주소(`relative_imports_rule.dart` — 04-06 에서
  /// 더함)는 복사본 패키지의 표식 폴더 주소로 바꿔 쓴다. 그대로 두면 복사본에 없는 패키지라
  /// `uri_does_not_exist` 가 되고 정답지의 `prefer_relative_imports` 줄이 표식에서 빠진다.
  void addExampleMarkers() {
    final from = Directory('${repo.root}/example/lib');
    final self = 'package:${examplePackageName(repo.root)}/';
    final name = RegExp(
      r'^name: (\S+)',
      multiLine: true,
    ).firstMatch(originalPubspec)?.group(1);
    if (name == null) throw StateError('복사본 pubspec.yaml 의 name: 을 읽지 못했다');
    final markerPackage =
        'package:$name/${Diag.markerDir.substring('lib/'.length)}';
    for (final f in from.listSync(recursive: true).whereType<File>()) {
      final to = File(
        '$dir/${Diag.markerDir}${f.path.substring(from.path.length + 1)}',
      );
      to.parent.createSync(recursive: true);
      final text = f.readAsStringSync();
      if (f.path.endsWith('.dart') && text.contains(self)) {
        to.writeAsStringSync(text.replaceAll(self, markerPackage));
      } else {
        f.copySync(to.path);
      }
    }
  }

  /// 표식을 더한다 — `lib/woody_probe_marker/<상대 경로>`.
  void addMarkers(Map<String, String> files) {
    for (final e in files.entries) {
      final to = File('$dir/${Diag.markerDir}${e.key}');
      to.parent.createSync(recursive: true);
      to.writeAsStringSync(e.value);
    }
  }

  /// 표식 파일을 지운다.
  void removeMarkers(Iterable<String> relPaths) {
    for (final rel in relPaths) {
      final f = File('$dir/${Diag.markerDir}$rel');
      if (f.existsSync()) f.deleteSync();
    }
  }

  /// 분석되는 Dart 파일 수 — `lib` · `test` · `bin` 의 손으로 쓴 파일과 생성 파일 (표식 제외).
  Map<String, int> dartFiles() {
    final out = {for (final a in projectAreas) a: 0, 'generated': 0};
    for (final top in projectAreas) {
      final d = Directory('$dir/$top');
      if (!d.existsSync()) continue;
      for (final f in d.listSync(recursive: true).whereType<File>()) {
        final rel = f.path.substring(dir.length + 1);
        if (!rel.endsWith('.dart') || rel.startsWith(Diag.markerDir)) continue;
        final generated =
            rel.endsWith('.g.dart') || rel.endsWith('.freezed.dart');
        out.update(generated ? 'generated' : top, (v) => v + 1);
      }
    }
    return out;
  }

  /// 복사본을 작업 디렉터리로 두고 경로 인자 없이 분석한다. 실행마다 빈 상태 폴더를 준다.
  /// 줄 전문은 `<work>/private/<id>.txt` 에만 쓴다.
  Future<Shot> analyze(String id) async {
    final shot = Shot(id)..woodySource = woodySource();
    final state = Directory('$work/state/$id');
    if (state.existsSync()) state.deleteSync(recursive: true);
    state.createSync(recursive: true);
    final watch = Stopwatch()..start();
    final r = await Process.run(
      _dart,
      ['--suppress-analytics', 'analyze', '--format=json'],
      workingDirectory: dir,
      environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path},
    );
    shot.elapsedMs = watch.elapsedMilliseconds;
    shot.exitCode = r.exitCode;
    shot.pluginHeader = '${r.stderr}'.contains(pluginFailureHeader);
    final manager = Directory('${state.path}/.plugin_manager');
    final folders = manager.existsSync()
        ? manager.listSync().whereType<Directory>().toList()
        : <Directory>[];
    shot.pluginFolders = folders.length;
    if (folders.length == 1) {
      final lock = File('${folders.single.path}/pubspec.lock');
      if (lock.existsSync()) {
        final m = RegExp(
          r'\n  riverpod_lint:\n(?:    .*\n)*?    version: "([^"]+)"',
        ).firstMatch(lock.readAsStringSync());
        shot.pluginVersion = m?.group(1) ?? '?';
      }
    }
    // 작업 폴더가 링크를 거치면 진단 경로가 준 경로로도 푼 경로로도 올 수 있다 (Pitfall 7).
    final bases = {dir, Directory(dir).resolveSymbolicLinksSync()};
    final parsed = parseDiagnostics('${r.stdout}', bases);
    if (parsed != null) {
      shot.jsonOk = true;
      shot.diags.addAll(parsed);
    }
    File('${_private()}/$id.txt').writeAsStringSync(
      '${(shot.diags.map((d) => d.text).toList()..sort()).join('\n')}\n'
      '--- exit ${r.exitCode}\n--- stderr\n${r.stderr}',
    );
    return shot;
  }

  /// `<work>/private/` (없으면 만든다) — 저장소 밖에만 두는 원문의 자리.
  String _private() {
    final d = Directory('$work/private')..createSync(recursive: true);
    return d.path;
  }

  /// 결과에 쓸 문자열에서 로컬 경로를 가린다 (원본의 경로가 가장 먼저).
  String scrubText(String text) =>
      scrubPaths(text, source: source, work: work, repoRoot: repo.root);
}

/// 문자열에서 원본 · 작업 폴더 · 저장소 · 홈 경로를 `<consumer-source>` · `<work>` · `<repo>` · `~` 로.
/// 링크를 푼 꼴도 함께 가린다.
String scrubPaths(
  String text, {
  String? source,
  String? work,
  required String repoRoot,
}) {
  final home = Platform.environment['HOME'];
  final pairs = <(String, String)>[
    if (source != null) (source, '<consumer-source>'),
    if (work != null) (work, '<work>'),
    if (work != null) (resolveLoosely(work), '<work>'),
    (repoRoot, '<repo>'),
    if (home != null && home.length > 1) (home, '~'),
  ];
  var out = text;
  for (final (from, to) in pairs) {
    if (from.isNotEmpty) out = out.replaceAll(from, to);
  }
  return out;
}

/// `dart analyze --format=json` 의 stdout 을 진단 목록으로 읽는다. JSON 이 없으면 null.
/// [bases] 중 하나로 시작하는 경로는 그 뒤만 남긴다 (`tool/verify.dart` 의 `normalizeDiagnostics`).
List<Diag>? parseDiagnostics(String stdoutText, Iterable<String> bases) {
  final jsonLine = stdoutText
      .split('\n')
      .lastWhere((l) => l.trimLeft().startsWith('{'), orElse: () => '');
  if (jsonLine.isEmpty) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(jsonLine);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic> || decoded['diagnostics'] is! List) {
    return null;
  }
  final out = <Diag>[];
  try {
    for (final d in (decoded['diagnostics'] as List)) {
      final diagnostic = d as Map<String, dynamic>;
      final location = diagnostic['location'] as Map<String, dynamic>;
      var file = location['file'] as String;
      for (final base in bases) {
        if (file.startsWith('$base/')) {
          file = file.substring(base.length + 1);
          break;
        }
      }
      final line = ((location['range'] as Map)['start'] as Map)['line'] as int;
      out.add(
        Diag(
          file,
          line,
          (diagnostic['severity'] as String).toLowerCase(),
          '${diagnostic['code']}',
        ),
      );
    }
  } on TypeError {
    // JSON 이기는 하지만 진단의 모양이 아니다 — 읽지 못한 것으로 친다.
    return null;
  }
  return out;
}

/// `package_config.json` 의 `rootUri` 를 폴더로 푼다 — 상대 경로면 `.dart_tool/` 기준이다.
Directory packageRootDir(String packageDir, String rootUri) {
  final uri = Uri.parse(rootUri);
  if (uri.hasScheme) return Directory.fromUri(uri);
  return Directory.fromUri(
    Uri.directory('$packageDir/.dart_tool/').resolveUri(uri),
  );
}

/// `pubspec.yaml` 의 `environment:` 블록 안의 `sdk:` 줄.
class SdkLine {
  /// [index] 는 [lines] 안의 줄 번호(0부터)다.
  SdkLine(this.lines, this.index, this.match);

  /// 파일의 줄 전부.
  final List<String> lines;

  /// `sdk:` 줄의 위치.
  final int index;

  /// `^(\s+sdk:\s*)(\S+)(\s*)$` 의 매치.
  final RegExpMatch match;

  /// 제약 값 (둘러싼 따옴표는 뗀다).
  String get value =>
      match.group(2)!.replaceAll(RegExp(r'''^['"]|['"]$'''), '');

  /// 그 줄의 값만 [constraint] 로 바꾼 파일 내용.
  String replace(String constraint) {
    final copy = [...lines];
    copy[index] = '${match.group(1)}$constraint${match.group(3)}';
    return copy.join('\n');
  }
}

/// `environment:` 블록(그 줄부터 다음 들여쓰기 없는 줄 전까지) 안에서만 `sdk:` 를 찾는다.
/// 블록이나 `sdk:` 줄이 정확히 한 번이 아니면 [FormatException] — 사용 프로젝트가 바뀌면
/// 조용히 엉뚱한 것을 재지 않고 멈춘다. 파일 전체에서 찾으면 `flutter: sdk: flutter` 도 걸린다.
SdkLine environmentSdk(String pubspec) {
  final lines = pubspec.split('\n');
  final starts = [
    for (var i = 0; i < lines.length; i++)
      if (RegExp(r'^environment:\s*$').hasMatch(lines[i])) i,
  ];
  if (starts.length != 1) {
    throw FormatException(
      'pubspec.yaml 의 environment: 블록이 ${starts.length}번 나온다',
    );
  }
  final pattern = RegExp(r'^(\s+sdk:\s*)(\S+)(\s*)$');
  final hits = <SdkLine>[];
  for (var i = starts.single + 1; i < lines.length; i++) {
    final l = lines[i];
    if (l.isNotEmpty && !l.startsWith(' ') && !l.startsWith('\t')) {
      if (!l.startsWith('#') && l.trim().isNotEmpty) break;
    }
    final m = pattern.firstMatch(l);
    if (m != null) hits.add(SdkLine(lines, i, m));
  }
  if (hits.length != 1) {
    throw FormatException(
      'pubspec.yaml 의 environment: 블록에 sdk: 줄이 ${hits.length}번 나온다',
    );
  }
  return hits.single;
}

/// 옵션 파일의 `rules:` 블록에 [rules] 를 끼운다 (그 블록의 형식으로).
String insertRules(String text, List<String> rules) {
  final rulesLine = RegExp(r'^  rules:[ \t]*\r?$', multiLine: true);
  final hits = rulesLine.allMatches(text).toList();
  if (hits.length > 1) {
    throw FormatException('옵션 파일에 rules: 가 ${hits.length}번 나온다');
  }
  if (hits.isEmpty) {
    if (RegExp(r'^linter:', multiLine: true).hasMatch(text)) {
      throw const FormatException('옵션 파일에 linter: 는 있는데 rules: 가 없다');
    }
    return '${text}linter:\n  rules:\n${rules.map((r) => '    - $r\n').join()}';
  }
  final at = hits.single.end + 1; // 줄바꿈 뒤
  final rest = text.substring(at);
  final firstEntry = rest
      .split('\n')
      .firstWhere(
        (l) => l.trim().isNotEmpty && !l.trim().startsWith('#'),
        orElse: () => '',
      );
  final listForm = firstEntry.trimLeft().startsWith('- ');
  final entries = rules
      .map((r) => listForm ? '    - $r\n' : '    $r: true\n')
      .join();
  return '${text.substring(0, at)}$entries$rest';
}

/// 옵션 파일의 `analyzer:` 블록에 `language:` 를 더한다 (없으면 블록을 새로 붙인다).
String insertLanguage(String text, Map<String, bool> language) {
  final entries = language.entries
      .map((e) => '    ${e.key}: ${e.value}\n')
      .join();
  final analyzerLine = RegExp(r'^analyzer:[ \t]*\r?$', multiLine: true);
  final hits = analyzerLine.allMatches(text).toList();
  if (hits.length > 1) {
    throw FormatException('옵션 파일에 analyzer: 가 ${hits.length}번 나온다');
  }
  if (hits.isEmpty) {
    if (RegExp(r'^analyzer:', multiLine: true).hasMatch(text)) {
      throw const FormatException('옵션 파일의 analyzer: 모양을 읽지 못했다');
    }
    return '${text}analyzer:\n  language:\n$entries';
  }
  if (RegExp(r'^  language:', multiLine: true).hasMatch(text)) {
    throw const FormatException('옵션 파일에 이미 analyzer: language: 가 있다');
  }
  final at = hits.single.end + 1;
  return '${text.substring(0, at)}  language:\n$entries${text.substring(at)}';
}

/// [from] 이 정확히 한 번 나오는지 확인하고 바꾼다 — 사용 프로젝트가 바뀌면 조용히 엉뚱한 것을
/// 재지 않고 멈춘다.
String replaceOnce(String text, String from, String to) {
  final count = from.allMatches(text).length;
  if (count != 1) {
    throw FormatException('바꿀 자리가 $count번 나온다: ${jsonEncode(from)}');
  }
  return text.replaceFirst(from, to);
}

/// 64비트 FNV-1a — 식별용 해시이지 보안 해시가 아니다. 빈 목록은 `cbf29ce484222325`.
String digest(List<int> bytes) {
  var hash = 0xcbf29ce484222325;
  for (final unit in bytes) {
    hash = (hash ^ unit) * 0x100000001b3;
  }
  String half(int v) => (v & 0xffffffff).toRadixString(16).padLeft(8, '0');
  return half(hash >> 32) + half(hash);
}

/// `example/pubspec.yaml` 의 패키지 이름 (`woody_lints_example`) — 표식으로 옮길 때 바꿔 쓸 주소.
String examplePackageName(String repoRoot) {
  final name = RegExp(r'^name: (\S+)', multiLine: true)
      .firstMatch(File('$repoRoot/example/pubspec.yaml').readAsStringSync())
      ?.group(1);
  if (name == null) throw StateError('example/pubspec.yaml 의 name: 을 읽지 못했다');
  return name;
}

/// 정답지 파일에서 진단 줄만 (`#` 머리 주석과 `exit N` 줄을 뺀다).
List<String> expectedLines(String path) => File(path)
    .readAsLinesSync()
    .where(
      (l) =>
          l.trim().isNotEmpty && !l.startsWith('#') && !l.startsWith('exit '),
    )
    .toList();

// SDK · 기반 세트 -----------------------------------------------------------

/// 실행 중인 dart 가 속한 Flutter SDK 의 `bin/cache/flutter.version.json` 을 읽는다
/// (`tool/verify.dart` 의 `readFlutterVersion` 과 같다 — 서로 import 하지 않는다).
Map<String, dynamic>? readFlutterVersion() {
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 4; i++) {
    dir = dir.parent;
  }
  final nearby = readVersionFile(dir.path);
  if (nearby != null) return nearby;
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null || flutterRoot.isEmpty) return null;
  final fallback = readVersionFile(flutterRoot);
  final runningDart = Platform.version.split(' ').first;
  return fallback?['dartSdkVersion'] == runningDart ? fallback : null;
}

/// [flutterRoot] 아래의 `bin/cache/flutter.version.json` 을 읽는다. 없으면 null.
Map<String, dynamic>? readVersionFile(String flutterRoot) {
  final file = File('$flutterRoot/bin/cache/flutter.version.json');
  if (!file.existsSync()) return null;
  final decoded = jsonDecode(file.readAsStringSync());
  return decoded is Map<String, dynamic> ? decoded : null;
}

/// 실행 중인 Dart 버전.
String dartVersion() => Platform.version.split(' ').first;

/// 실행 중인 Flutter 버전 (못 찾으면 `?`).
String flutterVersion() {
  final v = readFlutterVersion();
  return '${v?['flutterVersion'] ?? v?['frameworkVersion'] ?? '?'}';
}

/// [packageDir] 의 `package_config.json` 에서 `lints` · `flutter_lints` 의 폴더 이름
/// (`lints-6.1.0` 꼴)을 읽는다 (04-RESEARCH.md § 1). 파일이 없으면 [FormatException].
Map<String, String> baseSetVersions(String packageDir) {
  final file = File('$packageDir/.dart_tool/package_config.json');
  if (!file.existsSync()) {
    throw const FormatException('package_config.json 이 없다 — 그 폴더에서 pub get');
  }
  final config = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final out = <String, String>{};
  for (final p in (config['packages'] as List).cast<Map<String, dynamic>>()) {
    final name = p['name'] as String;
    if (name != 'lints' && name != 'flutter_lints') continue;
    final dir = packageRootDir(packageDir, p['rootUri'] as String);
    // 폴더 이름이 '<패키지>-<버전>' 이다 (pub cache 의 hosted 패키지).
    out[name] = dir.absolute.path.split('/').where((s) => s.isNotEmpty).last;
  }
  return {
    for (final k in ['lints', 'flutter_lints'])
      if (out.containsKey(k)) k: out[k]!,
  };
}

/// 상류 세트 (core / recommended / flutter) — spike 020 의 `UpstreamSets`.
class UpstreamSets {
  /// `lints` 의 `core.yaml`.
  final core = <String>{};

  /// `lints` 의 `recommended.yaml` (직접 적은 것).
  final recommended = <String>{};

  /// `flutter_lints` 의 `flutter.yaml` (직접 적은 것).
  final flutter = <String>{};

  /// 패키지 이름 → 폴더 이름 (`lints-6.1.0`).
  final sources = <String, String>{};

  /// 상류 YAML 은 `prefer_iterable_whereType` 처럼 대문자가 섞인 이름을 쓴다 — 소문자로 견준다.
  String? of(String name) {
    bool has(Set<String> s) =>
        s.any((n) => n.toLowerCase() == name.toLowerCase());
    if (has(core)) return 'core';
    if (has(recommended)) return 'recommended';
    if (has(flutter)) return 'flutter';
    return null;
  }
}

/// [packageDir] 가 받은 `lints` · `flutter_lints` 의 YAML 에서 세트를 읽는다 (spike 020).
/// `tool/verify.dart` 의 `readUpstreamRules` 와 같은 모양이다 — 서로 import 하지 않는다.
UpstreamSets readUpstreamSets(String packageDir) {
  final file = File('$packageDir/.dart_tool/package_config.json');
  if (!file.existsSync()) {
    throw const FormatException('package_config.json 이 없다 — 저장소 루트에서 pub get');
  }
  final config = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  String root(String package) {
    final p = (config['packages'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (p) => p['name'] == package,
          orElse: () => throw FormatException(
            'package_config 에 $package 가 없다 — 저장소 루트에서 pub get',
          ),
        );
    final path = packageRootDir(packageDir, p['rootUri'] as String).path;
    return path.endsWith('/') ? path : '$path/';
  }

  Set<String> rulesOf(String path) =>
      File(path)
          .readAsLinesSync()
          .map((l) => RegExp(r'^    - (\w+)').firstMatch(l)?.group(1))
          .whereType<String>()
          .toSet();

  final sets = UpstreamSets();
  final lints = root('lints');
  final flutterLints = root('flutter_lints');
  String last(String p) => p.split('/').where((s) => s.isNotEmpty).last;
  sets.sources['lints'] = last(lints);
  sets.sources['flutter_lints'] = last(flutterLints);
  sets.core.addAll(rulesOf('${lints}lib/core.yaml'));
  sets.recommended.addAll(rulesOf('${lints}lib/recommended.yaml'));
  sets.flutter.addAll(rulesOf('${flutterLints}lib/flutter.yaml'));
  return sets;
}

// 상태 (messages.yaml) ------------------------------------------------------

/// `messages.yaml` 의 규칙 하나 — 코드마다의 state 맵 (spike 020).
class MessagesRule {
  /// 같은 규칙(같은 sharedName)의 코드마다 state 하나.
  final List<Map<String, String>> states = [];

  /// 같은 규칙의 코드끼리 state 가 같은가.
  bool get consistent => states.every((s) => _same(s, states.first));

  /// 가장 늦은 버전에 붙은 상태. 같은 버전이면 removed > deprecated > stable > experimental.
  String get latest {
    const rank = {
      'experimental': 0,
      'internal': 0,
      'testing': 0,
      'stable': 1,
      'deprecated': 2,
      'removed': 3,
    };
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
/// 들여쓰기 2칸 = 코드 이름, 4칸 = 속성, 6칸 = state 의 항목이라는 모양에 기댄다 (spike 020).
/// 받은 파일은 읽기만 한다. `LinterLintCode:` 가 없으면 [FormatException].
Map<String, MessagesRule> readMessagesYaml(String path) {
  final lines = File(path).readAsLinesSync();
  final start = lines.indexOf('LinterLintCode:');
  if (start < 0) {
    throw const FormatException('messages.yaml 에 LinterLintCode: 가 없다');
  }
  final out = <String, MessagesRule>{};
  String? code;
  String? shared;
  Map<String, String>? state;
  var inState = false;
  final sharedWithoutState = <String>{};
  void flush() {
    final c = code;
    if (c == null) return;
    final name = snake(shared ?? c);
    final s = state;
    if (s == null) {
      // 같은 sharedName 을 쓰는 코드는 그중 하나만 state 를 적는다 — 끝에서 짝이 있는지 본다.
      if (shared == null) {
        throw FormatException('state 도 sharedName 도 없는 항목: $c');
      }
      sharedWithoutState.add(name);
      return;
    }
    (out[name] ??= MessagesRule()).states.add(s);
  }

  final entryPattern = RegExp(r'^  (\w+):\s*$');
  final sharedPattern = RegExp(r'^    sharedName: (\w+)\s*$');
  final statePattern = RegExp(r'^    state:\s*$');
  final stateItem = RegExp(r'^      (\w+): "?([^"\s]+)"?\s*$');
  for (final line in lines.skip(start + 1)) {
    if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#')) {
      break; // 다음 최상위 키
    }
    final entry = entryPattern.firstMatch(line);
    if (entry != null) {
      flush();
      code = entry.group(1);
      shared = null;
      state = null;
      inState = false;
      continue;
    }
    final sharedMatch = sharedPattern.firstMatch(line);
    if (sharedMatch != null) shared = sharedMatch.group(1);
    if (statePattern.hasMatch(line)) {
      inState = true;
      state = {};
      continue;
    }
    if (inState) {
      final s = stateItem.firstMatch(line);
      if (s != null) {
        state![s.group(1)!] = s.group(2)!;
        continue;
      }
      inState = false;
    }
  }
  flush();
  final orphans = sharedWithoutState.where((n) => !out.containsKey(n)).toList();
  if (orphans.isNotEmpty) {
    throw FormatException('state 를 적은 짝이 없는 sharedName: $orphans');
  }
  return out;
}

/// `linesLongerThan80Chars` → `lines_longer_than_80_chars` (숫자 앞에도 `_`).
String snake(String camel) => camel
    .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
    .replaceAllMapped(
      RegExp(r'([a-z])(\d+)'),
      (m) => '${m.group(1)}_${m.group(2)}',
    );

/// 점으로 나눈 버전 비교 (`3.13` 과 `3.13.0` 은 같다).
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

/// [url] 을 받아 [to] 에 쓴다 (HTTP 200 이 아니면 [HttpException]). 끝까지 받은 뒤에만 이름을 붙인다.
Future<void> download(String url, File to) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  final part = File('${to.path}.part');
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close().timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
    }
    to.parent.createSync(recursive: true);
    await response.pipe(part.openWrite());
    part.renameSync(to.path);
  } finally {
    client.close(force: true);
    if (part.existsSync()) part.deleteSync();
  }
}

/// 규칙 이름 → `messages.yaml` 의 상태. 받지 못하면 spike 020 의 결과를 읽는다.
/// 돌려주는 값의 둘째는 `conditions.stateSource` 다.
Future<(Map<String, String>, String)> readRuleStates(
  String work,
  String repoRoot,
) async {
  final file = File('$work/upstream/messages.yaml');
  if (!file.existsSync()) {
    try {
      await download(messagesUrl, file);
    } on Exception catch (e) {
      stderr.writeln(
        'messages.yaml 을 받지 못했다 (${e.runtimeType}) — spike 020 의 결과로 대신한다',
      );
    }
  }
  if (file.existsSync()) {
    final rules = readMessagesYaml(file.path);
    return (
      {for (final e in rules.entries) e.key: e.value.latest},
      'messages.yaml@$sdkTag',
    );
  }
  final json = jsonDecode(
    File('$repoRoot/$spike020Results').readAsStringSync(),
  ) as Map<String, dynamic>;
  final states = <String, String>{};
  for (final r in (json['rules'] as List).cast<Map<String, dynamic>>()) {
    final m = r['messages'];
    if (m is String) states[r['name'] as String] = m;
  }
  return (states, 'spike-020 (2026-10-12)');
}

// state 단계 --------------------------------------------------------------

/// 규칙만 적은 패키지(`<work>/pkg13/`, 하한 `^3.13.0`)를 분석한 옵션 파일의 진단 —
/// (줄 번호, 코드). 옵션 파일 밖의 진단 수도 돌려준다.
Future<(List<(int, String)>, int)> analyzeRulePackage(
  String work,
  String stateId,
  List<String> rules,
) async {
  final dir = '$work/pkg13';
  final options = StringBuffer('linter:\n  rules:\n');
  for (final r in rules) {
    options.writeln('    - $r');
  }
  File('$dir/analysis_options.yaml').writeAsStringSync(options.toString());
  final state = Directory('$work/state/$stateId');
  if (state.existsSync()) state.deleteSync(recursive: true);
  state.createSync(recursive: true);
  final r = await Process.run(
    Platform.resolvedExecutable,
    ['--suppress-analytics', 'analyze', '--format=json'],
    workingDirectory: dir,
    environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path},
  );
  final diags = parseDiagnostics('${r.stdout}', {
    dir,
    Directory(dir).resolveSymbolicLinksSync(),
  });
  if (diags == null) {
    throw SubcommandFailure(
      'state 단계의 dart analyze 가 JSON 을 내지 않았다 (exit ${r.exitCode})',
    );
  }
  final inOptions = [
    for (final d in diags)
      if (d.path == 'analysis_options.yaml') (d.line, d.code),
  ];
  return (inOptions, diags.length - inOptions.length);
}

/// `state` 단계 — 후보 133개의 상태 · 상류 세트 · 비호환 쌍을 채운다 (D-02, spike 020).
/// `rules.json` 의 `state` · `sets` · `fixStatus` 는 쓰지 않는다.
Future<void> measureState(Options opts, Repo repo, Results results) async {
  final (states, stateSource) = await readRuleStates(opts.work, repo.root);
  results.conditions['stateSource'] = stateSource;
  final lints = lintCandidateNames;
  final counts = <String, int>{};
  for (final name in lints) {
    final s = states[name] ?? 'missing';
    counts.update(s, (v) => v + 1, ifAbsent: () => 1);
  }
  final sameAsExpected =
      counts.length == expectedStateCounts.length &&
      expectedStateCounts.entries.every((e) => counts[e.key] == e.value);
  if (!sameAsExpected) {
    stderr.writeln(
      '경고: 후보의 상태 분포가 2026-10-13 의 셈과 다르다 — $counts (기대 $expectedStateCounts)',
    );
  }

  // 저장소와 같은 하한의 패키지에서 deprecated / removed / 없는 이름을 가른다 (spike 005 · 020).
  final pkg = Directory('${opts.work}/pkg13');
  if (pkg.existsSync()) pkg.deleteSync(recursive: true);
  Directory('${pkg.path}/lib').createSync(recursive: true);
  File('${pkg.path}/pubspec.yaml').writeAsStringSync(
    'name: woody_rule_state\npublish_to: none\nenvironment:\n  sdk: $sdk313\n',
  );
  File('${pkg.path}/lib/a.dart')
      .writeAsStringSync('/// 분석 대상이 비지 않게 두는 파일.\nint answer() => 42;\n');
  final pub = await Process.run(Platform.resolvedExecutable, [
    '--suppress-analytics',
    'pub',
    'get',
  ], workingDirectory: pkg.path);
  if (pub.exitCode != 0) {
    throw SubcommandFailure('state 단계의 pub get 이 실패했다 (exit ${pub.exitCode})');
  }
  final (all, outside) = await analyzeRulePackage(
    opts.work,
    'state-all',
    lints,
  );
  if (outside != 0) {
    stderr.writeln('경고: 규칙 패키지의 옵션 파일 밖에 진단이 $outside건 있다');
  }
  final analysisCodes = <String, Set<String>>{};
  for (final (line, code) in all) {
    final index = line - 3; // 옵션 파일의 3행부터 규칙 하나씩
    if (index < 0 || index >= lints.length) continue;
    analysisCodes.putIfAbsent(lints[index], () => {}).add(code);
  }
  String analysisOf(String name) {
    final codes = analysisCodes[name] ?? const <String>{};
    if (codes.contains('undefined_lint')) return 'undefined';
    if (codes.contains('removed_lint')) return 'removed';
    if (codes.contains('deprecated_lint')) return 'deprecated';
    return 'ok';
  }

  // 쌍마다 둘만 켜서 확인한다.
  final pairs = <Map<String, Object>>[];
  final partners = <String, Set<String>>{};
  var i = 0;
  for (final (a, b) in incompatiblePairs) {
    final (diags, _) = await analyzeRulePackage(opts.work, 'state-pair${i++}', [
      a,
      b,
    ]);
    final confirmed = diags.any((d) => d.$2 == 'incompatible_lint');
    pairs.add({'a': a, 'b': b, 'confirmed': confirmed});
    if (confirmed) {
      partners.putIfAbsent(a, () => {}).add(b);
      partners.putIfAbsent(b, () => {}).add(a);
    }
  }
  results.conditions['incompatiblePairs'] = pairs;

  final sets = readUpstreamSets(repo.root);
  final inUpstream = <String>[];
  for (final c in candidates) {
    final row = results.row(c.name);
    if (c.isOption) {
      row['state'] = {'kind': 'option', 'messages': null, 'analysis': null};
      row['upstream'] = null;
      continue;
    }
    row['state'] = {
      'kind': 'lint',
      'messages': states[c.name],
      'analysis': analysisOf(c.name),
    };
    final upstream = sets.of(c.name);
    row['upstream'] = upstream;
    if (upstream != null) inUpstream.add(c.name);
    row['incompatible'] = (partners[c.name]?.toList() ?? <String>[])..sort();
  }
  if (inUpstream.isNotEmpty) {
    stderr.writeln('경고: 상류 세트에 든 후보가 있다 — $inUpstream');
  }
  final unconfirmed = pairs.where((p) => p['confirmed'] != true).toList();
  if (unconfirmed.isNotEmpty) {
    stderr.writeln('경고: 따로 켜도 incompatible_lint 가 붙지 않은 쌍 — $unconfirmed');
  }
  stdout.writeln(
    'state: 후보 ${candidates.length}개, 상태 $counts ($stateSource), '
    '비호환 쌍 ${pairs.length - unconfirmed.length}/${pairs.length} 확인',
  );
}

// 실행 ------------------------------------------------------------------

/// 단계마다 저장소 지문을 견준다 — 다르면 그 자리에서 종료 코드 1 (spike 022 `repo_guard.dart`).
class RepoGuard {
  /// [last] 는 첫 단계 전의 지문이다.
  RepoGuard(this.repo, this.results, this.last);

  /// 작업 중인 저장소.
  final Repo repo;

  /// 단계가 끝날 때마다 작업 폴더에 쓰는 결과.
  final Results results;

  /// 마지막으로 본 지문.
  String last;

  /// [body] 를 돌리고 지문을 견준다. 같으면 결과를 작업 폴더에 쓴다.
  Future<void> step(String name, Future<void> Function() body) async {
    stderr.writeln('$name 단계…');
    await body();
    final now = await repo.fingerprint();
    if (now != last) {
      results.save();
      stderr.writeln('$name: 저장소가 바뀌었다 — 이 실행을 쓰지 않는다');
      await stdout.flush();
      await stderr.flush();
      exit(1);
    }
    last = now;
    results.save();
  }
}

/// 이 실행의 공용 상태.
class Context {
  /// 단계 함수가 함께 쓴다.
  Context(this.opts, this.repo, this.results, this.consumer);

  /// 인자.
  final Options opts;

  /// 작업 중인 저장소.
  final Repo repo;

  /// 결과.
  final Results results;

  /// 복사본.
  final Consumer consumer;

  /// 이 실행이 더하거나 바꾼 회차 id.
  final touchedRuns = <String>[];

  /// 복사본을 이번 실행에서 준비했는지.
  bool consumerReady = false;
}

// 그룹 ------------------------------------------------------------------

/// 실행 그룹 → 그 그룹이 주인인 lint 후보 (G1 113 · G2 4 · G3 2 · G4 7).
final Map<String, List<String>> groups = {
  for (final g in ['G1', 'G2', 'G3', 'G4'])
    g: [
      for (final c in candidates)
        if (c.group == g) c.name,
    ],
};

/// 그룹 실행 하나의 옵션 — 켤 규칙 · analyzer 언어 옵션 · 복사본의 SDK 하한.
class GroupRun {
  /// [sdk] 가 null 이면 원본의 하한 그대로다.
  GroupRun(this.id, this.rules, this.language, this.sdk);

  /// `G1` ~ `G4`.
  final String id;

  /// 원본 옵션 파일에 더 켜는 규칙.
  final List<String> rules;

  /// `analyzer: language:` 에 더하는 옵션.
  final Map<String, bool> language;

  /// 복사본의 SDK 하한 (null 이면 원본 그대로).
  final String? sdk;

  /// 같은 하한의 기준선 회차 (값 = 그룹 실행 − 기준선).
  String get baselineId => sdk == null ? 'B0' : 'B0-313';

  /// 회차 기록의 `options`.
  Map<String, Object?> get optionsJson => {
    'rules': rules,
    'language': language,
    'sdk': sdk,
  };
}

/// 이번 범위([Options.rules])의 그룹 실행. G1 실행에는 G4 의 규칙도 함께 켜 지금 하한의 값을
/// 잰다 (규칙이 돌지 않아 0 이어야 한다 — D-15 의 값 둘). `strict-inference` 는 G1 에서 켠다.
List<GroupRun> groupRunsFor(Options opts) {
  List<String> scoped(Iterable<String> names) => [
    for (final n in names)
      if (opts.inScope(n)) n,
  ];
  final g1 = scoped([...groups['G1']!, ...groups['G4']!]);
  final language = opts.inScope(strictInference)
      ? {strictInference: true}
      : <String, bool>{};
  return [
    if (g1.isNotEmpty || language.isNotEmpty)
      GroupRun('G1', g1, language, null),
    for (final g in ['G2', 'G3'])
      if (scoped(groups[g]!).isNotEmpty)
        GroupRun(g, scoped(groups[g]!), {}, null),
    if (scoped(groups['G4']!).isNotEmpty)
      GroupRun('G4', scoped(groups['G4']!), {}, sdk313),
  ];
}

/// 행의 값이 나오는 회차 — `current` 는 기준선 B0, `option` 은 G1, 그 밖은 자기 그룹.
String primaryRunId(Candidate c) => switch (c.group) {
  'current' => 'B0',
  'option' => 'G1',
  final g => g,
};

/// 결과 파일에 이미 있는 회차 id (파일이 없으면 빈 집합). 읽기만 한다.
Set<String> existingRunIds(Options opts) {
  final file = File('${opts.work}/results/${opts.runId}.json');
  if (!file.existsSync()) return {};
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic> || decoded['runs'] is! List) return {};
  return {
    for (final r in (decoded['runs'] as List).whereType<Map<String, dynamic>>())
      '${r['id']}',
  };
}

/// 단계가 기대는 앞 회차(기준선 · 그룹 실행)가 이번 실행에서 생기거나 결과 파일에 있는지
/// 확인한다. 없으면 [UsageError] (종료 코드 64 — 아직 아무것도 만들지 않았다).
void checkStageInputs(Options opts, Set<String> existing) {
  final produced = <String>{...existing};
  final missing = <String>{};
  void need(Iterable<String> ids, String stage) {
    for (final id in ids) {
      if (!produced.contains(id)) missing.add('$stage ← $id');
    }
  }

  final groupIds = groupRunsFor(opts).map((g) => g.id).toList();
  final hasG4 = groupIds.contains('G4');
  for (final stage in opts.stages) {
    switch (stage) {
      case 'baseline':
        produced.addAll(['B0', 'B0-313']);
      case 'groups':
        need(['B0', if (hasG4) 'B0-313'], stage);
        produced.addAll(groupIds);
      case 'markers':
        if (!opts.probeAll) need(groupIds, stage);
      case 'ignore':
        need(['B0', ...groupIds], stage);
        produced.addAll(['B0-strip', for (final g in groupIds) '$g-strip']);
      case 'fix':
        need({
          for (final c in candidates)
            if (opts.inScope(c.name)) primaryRunId(c),
        }, stage);
    }
  }
  if (missing.isNotEmpty) {
    throw UsageError(
      '먼저 돌려야 하는 회차가 결과(${opts.runId})에 없다 — ${missing.join(', ')}',
    );
  }
}

// 회차 유효성 --------------------------------------------------------------

/// 회차가 유효한지 — RULES-05 의 조건을 코드로. 무효여도 멈추지 않고 그 회차와 그 회차를
/// 참조하는 행에 표시만 한다. 그 시점의 `example/` 정답지 줄(`lib/` → `lib/woody_probe_marker/`)
/// 이 표식 줄에 다 있어야 한다 — 결정을 반영해 정답지가 늘어도 그대로 쓰인다.
Run validate(
  Context ctx,
  Shot shot,
  Map<String, Object?> options, {
  int ignoresStripped = 0,
  Map<String, bool?>? markersReported,
}) {
  final c = ctx.consumer;
  final expected = expectedLines(
    '${ctx.repo.root}/example/expected_diagnostics.txt',
  ).map((l) => l.replaceFirst('lib/', Diag.markerDir)).toSet();
  final markerTexts = shot.marker.map((d) => d.text).toSet();
  final covered = expected.every(markerTexts.contains);
  final valid =
      shot.woodySource == 'repo' &&
      covered &&
      shot.pluginFolders == 1 &&
      !shot.pluginHeader &&
      shot.jsonOk;
  final now = DateTime.now();
  final run = Run(
    shot: shot,
    conditions: {
      'date': now.toIso8601String().substring(0, 10),
      'at': now.toUtc().toIso8601String(),
      'dart': dartVersion(),
      'flutter': flutterVersion(),
      'baseSet': {
        'repo': baseSetVersions(ctx.repo.root),
        'consumer': baseSetVersions(c.dir),
      },
      'languageVersion': c.languageVersion(),
      'sdkConstraint': c.sdkConstraint,
      'dartFiles': c.dartFiles(),
    },
    options: options,
    expectedCovered: covered,
    valid: valid,
    ignoresStripped: ignoresStripped,
    markersReported: markersReported,
  );
  ctx.results.addRun(run);
  if (!ctx.touchedRuns.contains(shot.id)) ctx.touchedRuns.add(shot.id);
  final why = [
    if (shot.woodySource != 'repo') '받은 자리 ${shot.woodySource}',
    if (!covered) '정답지 줄이 표식에 다 없다',
    if (shot.pluginFolders != 1) 'plugin 폴더 ${shot.pluginFolders}개',
    if (shot.pluginHeader) 'plugin 준비 실패 머리말',
    if (!shot.jsonOk) 'JSON 없음 (exit ${shot.exitCode})',
  ];
  stdout.writeln(
    '${shot.id}: ${(shot.elapsedMs / 1000).toStringAsFixed(1)}초 · '
    '프로젝트 ${shot.project.length}줄 · 표식 ${shot.marker.length}줄 · '
    '${valid ? '유효' : '무효 (${why.join(', ')})'}',
  );
  return run;
}

/// 회차 JSON 에서 [rule] 의 프로젝트 줄 수 — `lib` · `test` · `bin` · `pubspec.yaml` 자리별
/// ([valueAreas]).
Map<String, int> ruleCounts(Map<String, dynamic> run, String rule) {
  final byArea = run['countByAreaCode'] as Map<String, dynamic>;
  return {
    for (final a in valueAreas)
      a: ((byArea[a] as Map<String, dynamic>?) ?? const {}).entries
          .where((e) => codeMatchesRule(e.key, rule))
          .fold<int>(0, (s, e) => s + (e.value as int)),
  };
}

/// 자리별 수의 차이 (`a − b`).
Map<String, int> subtractCounts(Map<String, int> a, Map<String, int> b) => {
  for (final k in valueAreas) k: (a[k] ?? 0) - (b[k] ?? 0),
};

/// 자리별 수의 합 ([valueAreas] — 키가 없는 옛 모양은 0 으로 읽는다).
int total(Map<String, dynamic>? counts) => counts == null
    ? 0
    : valueAreas.fold<int>(0, (s, a) => s + ((counts[a] as int?) ?? 0));

/// 회차 JSON 의 표식이 아닌 진단 — 코드 → 건수 (자리를 합친다).
Map<String, int> nonMarkerByCode(Map<String, dynamic> run) {
  final out = <String, int>{};
  final byArea = run['countByAreaCode'] as Map<String, dynamic>;
  for (final e in byArea.entries) {
    if (e.key == 'marker') continue;
    for (final c in (e.value as Map<String, dynamic>).entries) {
      out.update(
        c.key,
        (v) => v + (c.value as int),
        ifAbsent: () => c.value as int,
      );
    }
  }
  return out;
}

/// [shot] 에서 [rule] 의 첫 진단의 강도 (프로젝트 줄 먼저, 없으면 표식 줄). 없으면 null.
String? firstSeverity(Shot shot, String rule) {
  for (final d in [...shot.project, ...shot.marker]) {
    if (codeMatchesRule(d.code, rule)) return d.severity;
  }
  return null;
}

/// 옵션 파일 줄에 붙은 `incompatible_lint` 를 그 줄의 규칙 이름으로 돌려 행에 적는다 (G3 의 근거).
void noteIncompatibleLint(Context ctx, Shot shot, String optionsText) {
  final lines = optionsText.split('\n');
  final rulePattern = RegExp(r'^\s+(?:- )?([a-z0-9_]+)\s*(?::.*)?$');
  for (final d in shot.diags) {
    if (d.path != 'analysis_options.yaml' || d.code != 'incompatible_lint') {
      continue;
    }
    if (d.line < 1 || d.line > lines.length) continue;
    final name = rulePattern.firstMatch(lines[d.line - 1])?.group(1);
    if (name == null || !candidateByName.containsKey(name)) continue;
    final list = ctx.results.row(name)['incompatibleLintRuns'] as List<dynamic>;
    if (!list.contains(shot.id)) list.add(shot.id);
  }
}

/// 행에 회차를 적는다 — 무효 회차는 `invalidRuns` 에도 적는다.
void noteRowRun(Context ctx, String rule, Run run) {
  ctx.results.noteRun(rule, run.shot.id);
  final invalid = ctx.results.row(rule)['invalidRuns'] as List<dynamic>;
  invalid.remove(run.shot.id);
  if (!run.valid) invalid.add(run.shot.id);
}

/// 그룹 실행 [g] 의 옵션 파일 내용.
String groupOptions(Consumer c, GroupRun g) =>
    g.rules.isEmpty && g.language.isEmpty
    ? c.originalOptions
    : c.optionsWith(rules: g.rules, language: g.language);

/// 회차 JSON 의 `options` 로 [GroupRun] 을 되살린다 (`dart fix` 의 before 와 같은 옵션).
GroupRun groupRunFromJson(String id, Map<String, dynamic> run) {
  final o = run['options'] as Map<String, dynamic>;
  return GroupRun(
    id,
    (o['rules'] as List).cast<String>(),
    (o['language'] as Map<String, dynamic>).cast<String, bool>(),
    o['sdk'] as String?,
  );
}

/// 그룹 [g] 에서 [rules] 의 표식 파일 (`rule_probe/<규칙>.dart`). 표식이 없는 이름은 빠진다.
Map<String, String> probesFor(GroupRun g, Iterable<String> rules) {
  final out = <String, String>{};
  for (final r in rules) {
    final src = g.id == 'G4'
        ? (ruleProbes313[r] ?? ruleProbes[r])
        : ruleProbes[r];
    if (src != null) out['rule_probe/$r.dart'] = src;
  }
  return out;
}

/// 그룹 [g] 가 주인인 후보 (이번 범위 안).
List<Candidate> ownedBy(Options opts, GroupRun g) => [
  for (final c in candidates)
    if (opts.inScope(c.name) && primaryRunId(c) == g.id) c,
];

/// 회차 JSON 을 꺼낸다 — 없으면 [StateError] (입력 확인을 지났다면 일어나지 않는다).
Map<String, dynamic> requireRun(Context ctx, String id) =>
    ctx.results.run(id) ?? (throw StateError('회차 $id 가 결과에 없다 — 앞 단계를 먼저 돌린다'));

// 복사본 단계 --------------------------------------------------------------

/// 복사본을 준비한다 — 원본이 주어졌고 기준선을 잰다면(또는 `pristine/` 이 없으면) 새로 복사하고,
/// 복사본이 없으면 `pristine/` 에서 다시 만들고, `woody_lints` 가 저장소를 가리키게 한다.
Future<void> prepareConsumer(Context ctx) async {
  final c = ctx.consumer;
  final pristineExists = Directory(c.pristine).existsSync();
  if (ctx.opts.source != null &&
      (!pristineExists || ctx.opts.stages.contains('baseline'))) {
    c.copy();
  } else if (!File('${c.dir}/pubspec.yaml').existsSync()) {
    c.rebuild();
  }
  if (!File('${c.dir}/pubspec_overrides.yaml').existsSync() ||
      c.woodySource() != 'repo') {
    c.setPubspec(c.originalPubspec);
    await c.pointToRepo();
  }
}

/// 복사본 단계 하나를 돌린다 (단계의 저장소 지문은 [RepoGuard] 가 견준다).
Future<void> runConsumerStage(Context ctx, String stage) async {
  if (!ctx.consumerReady) {
    await prepareConsumer(ctx);
    ctx.consumerReady = true;
  }
  switch (stage) {
    case 'baseline':
      await measureBaseline(ctx);
    case 'groups':
      await measureGroups(ctx);
    case 'markers':
      await measureMarkers(ctx);
    case 'ignore':
      await measureIgnore(ctx);
    case 'fix':
      await measureFix(ctx);
    case 'unnecessary-ignore':
      await measureUnnecessaryIgnore(ctx);
    default:
      throw StateError('모르는 단계: $stage');
  }
}

/// 원본 소스 · 원본 옵션 · 원본 하한으로 되돌린다 (단계의 끝).
Future<void> restoreConsumer(Consumer c) async {
  c.refreshSources();
  c.setOptions(c.originalOptions);
  await c.useSdk(null);
}

/// `baseline` — 기준선 B0 (원본 하한) 과 B0-313 (하한만 `^3.13.0`). 지금 켜 둔 6개의 값 ·
/// 강도 · 표식 검출을 B0 에서 정한다 (그 규칙들은 `path:` 로 받은 `lib/base.yaml` 이 이미 켠다).
Future<void> measureBaseline(Context ctx) async {
  final c = ctx.consumer;
  final r = ctx.results;
  c.refreshSources();
  c.setOptions(c.originalOptions);
  c.setPubspec(c.originalPubspec);
  await c.pointToRepo();
  c.addExampleMarkers();
  const noOptions = {'rules': <String>[], 'language': <String, bool>{}};
  final b0 = await c.analyze('B0');
  final run = validate(ctx, b0, {...noOptions, 'sdk': null});
  final cond = r.conditions;
  cond['sdkConstraint'] = c.originalSdkConstraint;
  cond['languageVersion'] = c.languageVersion();
  cond['dartFiles'] = c.dartFiles();
  (cond['baseSet'] as Map<String, dynamic>)['consumer'] = baseSetVersions(
    c.dir,
  );
  cond['plugin'] = b0.pluginVersion;

  final b0Json = r.run('B0')!;
  const sample = '${Diag.markerDir}added_rules.dart';
  for (final cand in candidates.where((x) => x.group == 'current')) {
    if (!ctx.opts.inScope(cand.name)) continue;
    final row = r.row(cand.name);
    row['counts'] = ruleCounts(b0Json, cand.name);
    row['severity'] = firstSeverity(b0, cand.name);
    // 표식으로 넣은 example 샘플이 곧 이 규칙들의 표식이다 (D-03).
    row['hasProbe'] = true;
    row['markerDetected'] = b0.marker.any(
      (d) => d.path == sample && d.code == cand.name,
    );
    noteRowRun(ctx, cand.name, run);
  }

  await c.useSdk(sdk313);
  final b313 = await c.analyze('B0-313');
  validate(ctx, b313, {...noOptions, 'sdk': sdk313});
  await c.useSdk(null);
}

/// `groups` — 그룹마다 켜고 잰다. 값 = 그룹 실행의 프로젝트 줄 − 같은 하한의 기준선, 자리별.
/// G4 는 `counts313` 에, 같은 7개를 G1 실행에서 잰 지금 하한의 값은 `counts` 에 적는다.
Future<void> measureGroups(Context ctx) async {
  final c = ctx.consumer;
  final r = ctx.results;
  for (final g in groupRunsFor(ctx.opts)) {
    c.refreshSources();
    c.addExampleMarkers();
    await c.useSdk(g.sdk);
    final optionsText = groupOptions(c, g);
    c.setOptions(optionsText);
    final shot = await c.analyze(g.id);
    final run = validate(ctx, shot, g.optionsJson);
    noteIncompatibleLint(ctx, shot, optionsText);
    final groupJson = r.run(g.id)!;
    final baseJson = requireRun(ctx, g.baselineId);
    for (final cand in ownedBy(ctx.opts, g)) {
      final row = r.row(cand.name);
      final value = subtractCounts(
        ruleCounts(groupJson, cand.name),
        ruleCounts(baseJson, cand.name),
      );
      row[g.id == 'G4' ? 'counts313' : 'counts'] = value;
      row['severity'] = firstSeverity(shot, cand.name) ?? row['severity'];
      noteRowRun(ctx, cand.name, run);
    }
    if (g.id == 'G1') {
      // 언어 버전 3.13 전용 규칙의 지금 하한 값 (0 이어야 한다 — 규칙이 돌지 않음).
      for (final name in g.rules.where(groups['G4']!.contains)) {
        r.row(name)['counts'] = subtractCounts(
          ruleCounts(groupJson, name),
          ruleCounts(baseJson, name),
        );
        noteRowRun(ctx, name, run);
      }
    }
  }
  await restoreConsumer(c);
}

/// `markers` — 프로젝트 줄이 0 인(`--probe-all` 이면 범위의 전부) 후보에 표식을 넣고 그룹마다
/// 한 번 더 분석한다 (D-03). 표식 줄은 `area` 로 갈라지므로 프로젝트 값에 섞이지 않는다.
Future<void> measureMarkers(Context ctx) async {
  final c = ctx.consumer;
  final r = ctx.results;
  // 검증 명령과 `--report` 가 같은 예외 집합을 읽는 자리.
  r.conditions['noFileProbe'] = noFileProbe.keys.toList()..sort();
  final noProbe = <String>[];
  final unprobeable = <String>[];
  for (final g in groupRunsFor(ctx.opts)) {
    final targets = <String>[];
    for (final cand in ownedBy(ctx.opts, g)) {
      final row = r.row(cand.name);
      final counts = row[g.id == 'G4' ? 'counts313' : 'counts'];
      if (ctx.opts.probeAll ||
          (counts is Map<String, dynamic> && total(counts) == 0)) {
        targets.add(cand.name);
      }
    }
    // G1 실행은 G4 의 규칙도 켠다 — 그 규칙들의 3.11 판 표식으로 지금 하한에서 걸리는지 본다.
    final currentBoundTargets = g.id == 'G1'
        ? [
            for (final name in g.rules.where(groups['G4']!.contains))
              if (ruleProbes.containsKey(name)) name,
          ]
        : <String>[];
    if (targets.isEmpty && currentBoundTargets.isEmpty) continue;
    final probes = {
      ...probesFor(g, targets),
      for (final name in currentBoundTargets)
        'rule_probe/$name.dart': ruleProbes[name]!,
    };
    for (final t in targets) {
      if (probes.containsKey('rule_probe/$t.dart')) continue;
      r.row(t)['markerDetected'] = null;
      final reason = noFileProbe[t];
      if (reason != null) {
        unprobeable.add(t);
        stderr.writeln('표식 불가: $t ($reason)');
      } else {
        noProbe.add(t);
        stderr.writeln('표식 없음: $t');
      }
    }
    if (probes.isEmpty) continue;
    c.refreshSources();
    c.addExampleMarkers();
    await c.useSdk(g.sdk);
    c.setOptions(groupOptions(c, g));
    c.addMarkers(probes);
    final id = '${g.id}-marker';
    final shot = await c.analyze(id);
    bool detected(String t) => shot.marker.any(
      (d) =>
          d.path == '${Diag.markerDir}rule_probe/$t.dart' &&
          codeMatchesRule(d.code, t),
    );
    final reported = <String, bool?>{
      for (final t in targets)
        t: probes.containsKey('rule_probe/$t.dart') ? detected(t) : null,
      for (final t in currentBoundTargets) t: detected(t),
    };
    final run = validate(ctx, shot, g.optionsJson, markersReported: reported);
    for (final t in targets.where((t) => reported[t] != null)) {
      final row = r.row(t);
      row['markerDetected'] = reported[t];
      row['severity'] ??= firstSeverity(shot, t);
      noteRowRun(ctx, t, run);
    }
    for (final t in currentBoundTargets) {
      r.row(t)['markerDetectedCurrent'] = reported[t];
      noteRowRun(ctx, t, run);
    }
  }
  if (noProbe.isNotEmpty) {
    stderr.writeln('표식 없음 ${noProbe.length}개: ${noProbe.join(', ')}');
  }
  if (unprobeable.isNotEmpty) {
    stderr.writeln('표식 불가 ${unprobeable.length}개: ${unprobeable.join(', ')}');
  }
  await restoreConsumer(c);
}

/// 무시 주석 — `// ignore: a, b` 와 `// ignore_for_file: a, b` (spike 023).
final ignorePattern = RegExp(r'//\s*(ignore_for_file|ignore)\s*:\s*(.*)$');

/// 분석되는 손으로 쓴 Dart 파일 (`lib` · `test` · `bin`, 생성 파일과 표식 폴더 제외).
Iterable<File> analyzedDartFiles(Consumer c) sync* {
  for (final top in projectAreas) {
    final d = Directory('${c.dir}/$top');
    if (!d.existsSync()) continue;
    for (final f in d.listSync(recursive: true).whereType<File>()) {
      final rel = f.path.substring(c.dir.length + 1);
      if (!rel.endsWith('.dart') || rel.startsWith(Diag.markerDir)) continue;
      if (rel.endsWith('.g.dart') || rel.endsWith('.freezed.dart')) continue;
      yield f;
    }
  }
}

/// 분석되는 파일에서 무시 주석 부분만 지운다 — 줄은 남겨 줄 번호를 지킨다 (spike 023).
/// 생성 파일과 표식 폴더(이 저장소의 샘플)는 건드리지 않는다. 지운 주석 수를 돌려준다.
int stripIgnores(Consumer c) {
  var n = 0;
  for (final f in analyzedDartFiles(c)) {
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

/// `ignore` — 주석을 걷어낸 기준선 B0-strip 과 그룹마다의 `G<n>-strip`. 가린 줄 =
/// strip 실행의 그 규칙 프로젝트 줄 − 주석을 둔 실행의 줄 (자리별).
Future<void> measureIgnore(Context ctx) async {
  final c = ctx.consumer;
  final r = ctx.results;

  c.refreshSources();
  c.addExampleMarkers();
  final stripped0 = stripIgnores(c);
  await c.useSdk(null);
  c.setOptions(c.originalOptions);
  final b0s = await c.analyze('B0-strip');
  final run0 = validate(ctx, b0s, {
    'rules': <String>[],
    'language': <String, bool>{},
    'sdk': null,
  }, ignoresStripped: stripped0);
  final b0Json = requireRun(ctx, 'B0');
  final b0sJson = r.run('B0-strip')!;
  for (final cand in candidates.where((x) => x.group == 'current')) {
    if (!ctx.opts.inScope(cand.name)) continue;
    r.row(cand.name)['ignored'] = subtractCounts(
      ruleCounts(b0sJson, cand.name),
      ruleCounts(b0Json, cand.name),
    );
    noteRowRun(ctx, cand.name, run0);
  }

  for (final g in groupRunsFor(ctx.opts)) {
    c.refreshSources();
    c.addExampleMarkers();
    final stripped = stripIgnores(c);
    await c.useSdk(g.sdk);
    c.setOptions(groupOptions(c, g));
    final id = '${g.id}-strip';
    final shot = await c.analyze(id);
    final run = validate(ctx, shot, g.optionsJson, ignoresStripped: stripped);
    final withComments = requireRun(ctx, g.id);
    final strippedJson = r.run(id)!;
    for (final cand in ownedBy(ctx.opts, g)) {
      r.row(cand.name)['ignored'] = subtractCounts(
        ruleCounts(strippedJson, cand.name),
        ruleCounts(withComments, cand.name),
      );
      noteRowRun(ctx, cand.name, run);
    }
  }
  await restoreConsumer(c);
}

/// `dart fix` 한 번의 결과 — 코드별 수정 수 (화면 원문은 `<work>/private/` 에만).
class FixRun {
  /// [id] 는 원문 파일 이름이다.
  FixRun(this.id);

  /// 원문 파일 이름 (`fix-<규칙>` · `fix-apply-<규칙>`).
  final String id;

  /// `dart fix` 의 종료 코드.
  int exitCode = -1;

  /// 걸린 시간.
  int elapsedMs = 0;

  /// 코드 → 수정 수 (파일을 합친다).
  final byCode = <String, int>{};

  /// [code] 의 수정 수.
  int countOf(String code) => byCode[code] ?? 0;

  /// 후보 [rule] 의 수정 수 — `strict-inference` 는 `inference_failure_on_*` 코드의 합이다.
  int countForRule(String rule) => byCode.entries
      .where((e) => codeMatchesRule(e.key, rule))
      .fold<int>(0, (s, e) => s + e.value);
}

/// 회차 JSON 에서 후보 [rule] 에 드는 프로젝트 진단 코드 (표식 자리를 뺀다, 이름 순).
/// 규칙은 그 이름 하나, `strict-inference` 는 그 회차에 나온 `inference_failure_on_*` 들이다.
List<String> ruleCodesIn(Map<String, dynamic> run, String rule) {
  final byArea = run['countByAreaCode'] as Map<String, dynamic>;
  final codes = <String>{
    for (final a in valueAreas)
      for (final e
          in ((byArea[a] as Map<String, dynamic>?) ?? const {}).entries)
        if (codeMatchesRule(e.key, rule) && (e.value as int) > 0) e.key,
  };
  return codes.toList()..sort();
}

/// 복사본에서 `dart fix --dry-run|--apply --code=<code> …` 를 한 번 (빈 상태 폴더).
/// 출력의 `  <코드> - N fix(es)` 줄을 센다 (spike 022 의 정규식).
Future<FixRun> dryRun(
  Context ctx,
  String id,
  List<String> codes, {
  bool apply = false,
}) async {
  final c = ctx.consumer;
  final state = Directory('${ctx.opts.work}/state/$id');
  if (state.existsSync()) state.deleteSync(recursive: true);
  state.createSync(recursive: true);
  final result = FixRun(id);
  final watch = Stopwatch()..start();
  final r = await Process.run(
    Platform.resolvedExecutable,
    [
      '--suppress-analytics',
      'fix',
      apply ? '--apply' : '--dry-run',
      for (final code in codes) '--code=$code',
    ],
    workingDirectory: c.dir,
    environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path},
  );
  result.elapsedMs = watch.elapsedMilliseconds;
  result.exitCode = r.exitCode;
  final out = '${r.stdout}';
  final private = Directory('${ctx.opts.work}/private')
    ..createSync(recursive: true);
  File(
    '${private.path}/$id.txt',
  ).writeAsStringSync('$out\n--- exit ${r.exitCode}\n--- stderr\n${r.stderr}');
  final fixLine = RegExp(r'^  (\S+) - (\d+) fix(?:es)?$');
  for (final line in out.split('\n')) {
    final m = fixLine.firstMatch(line.trimRight());
    if (m == null) continue;
    final n = int.parse(m.group(2)!);
    result.byCode.update(m.group(1)!, (v) => v + n, ifAbsent: () => n);
  }
  if (r.exitCode != 0) {
    throw SubcommandFailure(
      'dart fix 가 돌지 않았다 ($id, exit ${r.exitCode}) — 원문은 <work>/private/$id.txt',
    );
  }
  return result;
}

/// 후보 하나를 [codes] 로 apply 하고 다시 분석해 `fixRemoved` · `newErrors` · `otherDelta` 를
/// 적는다. `dart fix` 는 표식 폴더의 사본도 고쳐 정답지 줄을 지우므로 표식은 apply **뒤에** 넣는다.
Future<void> applyRule(
  Context ctx,
  Candidate cand,
  GroupRun g,
  Map<String, dynamic> before,
  int projectLines,
  List<String> codes,
) async {
  final c = ctx.consumer;
  final row = ctx.results.row(cand.name);
  await dryRun(ctx, 'fix-apply-${cand.name}', codes, apply: true);
  c.addExampleMarkers();
  c.addMarkers(probesFor(g, groups[g.id] ?? const []));
  final id = 'apply-${cand.name}';
  final shot = await c.analyze(id);
  final run = validate(ctx, shot, g.optionsJson);
  final after = ctx.results.run(id)!;
  final remaining = total(ruleCounts(after, cand.name));
  row['fixRemoved'] = projectLines - remaining;

  Map<String, int> errorsOf(Map<String, dynamic> json) =>
      ((((json['projectBySeverity'] as Map<String, dynamic>?) ??
                      const {})['error']
                  as Map<String, dynamic>?) ??
              const {})
          .map((k, v) => MapEntry(k, v as int));
  final errorsBefore = errorsOf(before);
  final errorsAfter = errorsOf(after);
  row['newErrors'] = errorsAfter.entries
      .where((e) => !codeMatchesRule(e.key, cand.name))
      .map((e) => e.value - (errorsBefore[e.key] ?? 0))
      .where((d) => d > 0)
      .fold<int>(0, (s, d) => s + d);

  final b = nonMarkerByCode(before);
  final a = nonMarkerByCode(after);
  final delta = <String, int>{};
  for (final code in {...a.keys, ...b.keys}) {
    if (codeMatchesRule(code, cand.name)) continue;
    final d = (a[code] ?? 0) - (b[code] ?? 0);
    if (d != 0) delta[code] = d;
  }
  row['otherDelta'] = Map.fromEntries(
    delta.entries.toList()..sort((x, y) => x.key.compareTo(y.key)),
  );
  noteRowRun(ctx, cand.name, run);
}

/// `fix` — 프로젝트 줄 > 0 인 후보마다 원본 소스(표식 없음)에서 단독 dry 를 돌려 `aloneDry` 를
/// 적고, 0 이 아니면 apply 해 사라진 그 규칙의 줄을 잰다 (D-02, spike 022). `current` 는 B0 를
/// before 로 원본 옵션으로 돈다. 단독 dry 의 수는 apply 할 규칙을 고르는 데만 쓴다.
/// analyzer 옵션 `strict-inference` 는 G1 에 나온 `inference_failure_on_*` 코드를 모두 `--code=`
/// 로 한 번에 준다 (옵션은 코드 이름이 아니라 `dart fix` 가 받지 못한다).
Future<void> measureFix(Context ctx) async {
  final c = ctx.consumer;
  final r = ctx.results;
  for (final cand in candidates) {
    if (!ctx.opts.inScope(cand.name)) continue;
    final row = r.row(cand.name);
    final beforeId = primaryRunId(cand);
    final before = requireRun(ctx, beforeId);
    final counts = row[cand.group == 'G4' ? 'counts313' : 'counts'];
    if (counts is! Map<String, dynamic>) {
      stderr.writeln('fix: ${cand.name} 의 값이 없다 — 건너뛴다');
      continue;
    }
    final projectLines = total(counts);
    if (projectLines == 0) {
      row['aloneDry'] = null;
      row['fixRemoved'] = null; // 해당 없음
      row['newErrors'] = null;
      row['otherDelta'] = null;
      continue;
    }
    final g = groupRunFromJson(beforeId, before);
    c.refreshSources();
    await c.useSdk(g.sdk);
    c.setOptions(groupOptions(c, g));
    final codes = ruleCodesIn(before, cand.name);
    if (codes.isEmpty) {
      // 줄이 있는데 코드가 없을 수 없다 — `--code=` 없이 돌면 모든 진단을 고치므로 막는다.
      throw StateError('fix: ${cand.name} 의 진단 코드를 $beforeId 에서 찾지 못했다');
    }
    final dry = await dryRun(ctx, 'fix-${cand.name}', codes);
    row['aloneDry'] = dry.countForRule(cand.name);
    if (dry.countForRule(cand.name) == 0) {
      // 0 (dry 0) — apply 하지 않는다. 고친 것이 없으니 새로 생긴 error 도 0 이다 (`--report` 의
      // 단언 (2) 는 줄이 있는 행에 `newErrors` 가 있기를 요구한다).
      row['fixRemoved'] = 0;
      row['newErrors'] = 0;
      row['otherDelta'] = <String, int>{};
    } else {
      await applyRule(ctx, cand, g, before, projectLines, codes);
    }
    r.save(); // 규칙 하나마다 작업 폴더에 — 중간에 죽어도 앞의 규칙은 남는다
  }
  await restoreConsumer(c);
}

/// [shot] 의 `unnecessary_ignore` 진단이 가리킨 주석에서 코드 이름만 뽑아 센다 (spike 023).
/// 메시지 · 경로 · 설명 글은 남기지 않는다 — 이름 꼴이 아닌 것은 `(이름 아님)` 으로 센다.
Map<String, int> unnecessaryIgnoreNames(Consumer c, Shot shot) {
  final counts = <String, int>{};
  final namePattern = RegExp(r'^(?:[a-z0-9_]+/)?[a-z0-9_]+$|^type=lint$');
  for (final d in shot.project) {
    if (!d.code.startsWith('unnecessary_ignore') || !d.inProjectArea) continue;
    final file = File('${c.dir}/${d.path}');
    if (!file.existsSync()) continue;
    final src = file.readAsLinesSync();
    String? found;
    // 줄 단위 주석은 그 줄이나 바로 위 줄에 있다.
    for (final i in [d.line - 1, d.line - 2]) {
      if (i < 0 || i >= src.length) continue;
      final m = ignorePattern.firstMatch(src[i]);
      if (m == null) continue;
      final codes = m
          .group(2)!
          .split(',')
          .map((x) => x.trim().split(RegExp(r'\s')).first)
          .where((x) => x.isNotEmpty)
          .map((x) => namePattern.hasMatch(x) ? x : '(이름 아님)');
      found = '${m.group(1)}:${codes.join(',')}';
      break;
    }
    counts.update(found ?? '(찾지 못함)', (v) => v + 1, ifAbsent: () => 1);
  }
  return counts;
}

/// `unnecessary-ignore` — 결정을 반영한 뒤 따로 잰다 (D-17). 복사본은 `path:` 로 작업 중인
/// 저장소를 받으므로 그때의 `lib/base.yaml` 이 그대로 적용된다. `countsUI` = UI − UI-base.
Future<void> measureUnnecessaryIgnore(Context ctx) async {
  final c = ctx.consumer;
  final r = ctx.results;
  const rule = 'unnecessary_ignore';
  c.refreshSources();
  c.addExampleMarkers();
  await c.useSdk(null);
  c.setOptions(c.originalOptions);
  final base = await c.analyze('UI-base');
  final baseRun = validate(ctx, base, {
    'rules': <String>[],
    'language': <String, bool>{},
    'sdk': null,
  });

  c.refreshSources();
  c.addExampleMarkers();
  final options = {
    'rules': [rule],
    'language': <String, bool>{},
    'sdk': null,
  };
  c.setOptions(c.optionsWith(rules: [rule]));
  final ui = await c.analyze('UI');
  final uiRun = validate(ctx, ui, options);

  int areaCount(Shot s, String area) =>
      s.diags.where((d) => d.area == area && d.code.startsWith(rule)).length;
  r.row(rule)['countsUI'] = {
    for (final a in valueAreas) a: areaCount(ui, a) - areaCount(base, a),
  };
  r.conditions['unnecessaryIgnoreNames'] = unnecessaryIgnoreNames(c, ui);
  noteRowRun(ctx, rule, baseRun);
  noteRowRun(ctx, rule, uiRun);
  await restoreConsumer(c);
}

// 출력 모드 ----------------------------------------------------------------
//
// 분석을 돌리지 않는다. 결과 JSON 에는 사용 프로젝트의 경로 · 메시지가 없고(04-02), 아래 함수는
// 건수 · 규칙 이름 · 회차 조건 칸만 읽는다 — 출력에 경로 · 메시지가 들어갈 자리가 없다 (D-07).

/// `RULES.md` 의 실측 기록 구역 (`--report --write` 가 바꿔 쓴다).
const measurementsStart = '<!-- woody:measurements:start -->';

/// 실측 기록 구역의 끝.
const measurementsEnd = '<!-- woody:measurements:end -->';

/// 켜지 않은 규칙 표의 이유 접두사 (04-RESEARCH.md § 3 의 7종 + 임시 `보류`).
const disabledReasonPrefixes = [
  '기반 세트',
  '비호환',
  'experimental',
  'testing',
  'v2 로 미룸',
  'deprecated',
  'removed',
  '없음',
  '규칙이 돌지 않음',
  '소유자 결정',
  '보류',
];

/// 상태 출처가 갈리는 후보 → `messages.yaml` 밖 출처의 값 (D-02 — 출처마다 적는다, spike 020).
/// `unnecessary_underscores` 도 갈리지만 기반 세트라 후보가 아니다.
const stateSourceNotes = {
  'unnecessary_ignore': 'rules.json · dart.dev 는 stable',
  'use_primary_constructors': 'rules.json 은 experimental',
  'migrate_design_widgets': 'rules.json 에 없다',
};

/// 성능 · 가독성·스타일 묶음의 "켬" 잣대 — 손으로 고칠 줄이 이 값 이하 (D-05, 추정 값).
const manualFixLimit = 50;

/// 결과 JSON 을 찾는다 — `--in`, `<work>/results/<run id>.json`,
/// `<저장소>/tool/measurements/*-<run id>.json` (정확히 하나) 순. 없으면 [UsageError] (64).
String locateResults(OutputOptions o, Repo repo) {
  final inPath = o.inPath;
  if (inPath != null) {
    if (!File(inPath).existsSync()) throw UsageError('--in 의 결과 JSON 이 없다');
    return inPath;
  }
  final work = o.work;
  if (work != null) {
    final file = File('$work/results/${o.runId}.json');
    if (file.existsSync()) return file.path;
  }
  final dir = Directory('${repo.root}/tool/measurements');
  final found = dir.existsSync()
      ? (dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('-${o.runId}.json'))
            .map((f) => f.path)
            .toList()
          ..sort())
      : <String>[];
  if (found.length == 1) return found.single;
  if (found.length > 1) {
    throw UsageError(
      'tool/measurements/ 에 ${o.runId} 의 결과가 ${found.length}개다 — --in 으로 하나를 준다',
    );
  }
  throw UsageError(
    '결과 JSON 을 찾지 못했다 (run id ${o.runId}) — --in 이나 --work 로 준다',
  );
}

/// 결과 JSON 을 읽는다. 모양이 다르거나 `schema` 가 1 이 아니면 [FormatException] (70).
Map<String, dynamic> loadResultsJson(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('결과 JSON 의 맨 위가 객체가 아니다');
  }
  if (decoded['schema'] != schemaVersion) {
    throw FormatException(
      '결과 JSON 의 schema 가 $schemaVersion 이 아니다 (${decoded['schema']})',
    );
  }
  if (decoded['conditions'] is! Map<String, dynamic> ||
      decoded['runs'] is! List ||
      decoded['rows'] is! Map<String, dynamic>) {
    throw const FormatException('결과 JSON 에 conditions · runs · rows 가 없다');
  }
  return decoded;
}

/// [value] 가 JSON 객체면 그것, 아니면 null.
Map<String, dynamic>? asMap(Object? value) =>
    value is Map<String, dynamic> ? value : null;

/// 회차 id → 회차.
Map<String, Map<String, dynamic>> runsByIdOf(Map<String, dynamic> data) => {
  for (final r in (data['runs'] as List).whereType<Map<String, dynamic>>())
    '${r['id']}': r,
};

/// 행이 참조하는 회차 가운데 결과에 없거나 유효하지 않은 것 (RULES-05).
List<String> invalidReferences(
  Map<String, dynamic> row,
  Map<String, Map<String, dynamic>> runsById,
) => [
  for (final id in ((row['runs'] as List?) ?? const []).map((e) => '$e'))
    if (runsById[id]?['valid'] != true) id,
];

/// 자리별 수를 [areas] 순서로 `·` 로 잇는다 — 기본은 값의 자리 넷 `lib·test·bin·pubspec`,
/// 회차 표의 Dart 파일 칸은 [projectAreas] 셋을 넘긴다 (`pubspec.yaml` 은 Dart 파일이 아니다).
String areaTriple(
  Map<String, dynamic> counts, [
  List<String> areas = valueAreas,
]) => areas.map((a) => '${counts[a] ?? 0}').join('·');

/// 자리별 수의 칸 — 합계가 0 이 아니면 부호째 `N (l·t·b·p)` (가린 줄은 음수일 수 있다 —
/// 04-REVIEW.md WR-02), 0 이면 `0 (<zeroNote>)` (null 이면 `0`), 값이 없으면 `—`.
String countCell(Map<String, dynamic>? counts, String? zeroNote) {
  if (counts == null) return '—';
  final n = total(counts);
  if (n != 0) return '$n (${areaTriple(counts)})';
  return zeroNote == null ? '0' : '0 ($zeroNote)';
}

/// 0줄의 뜻 (D-03) — 표식이 걸렸는지로 가른다.
String zeroNote(String name, Object? detected) {
  if (noFileProbe.containsKey(name)) return '표식 불가';
  return switch (detected) {
    true => '표식 1',
    false => '표식 미검출',
    _ => '표식 없음',
  };
}

/// 언어 버전 3.13 전용 규칙의 지금 하한 0줄의 뜻 — G1 marker 실행의 3.11 판 표식 (D-15).
String currentBoundNote(Object? detected) => switch (detected) {
  true => '표식 1',
  false => '돌지 않음',
  _ => '표식 없음',
};

/// 경고 칸 — 합계 (lib·test·bin·pubspec) 와 0줄의 뜻. G4 는 지금 하한과 3.13 하한의 값 둘,
/// `unnecessary_ignore` 는 재측정 값(`countsUI`)을 덧붙이고, `strict-inference` 는 강도를 붙인다.
/// 행이 참조하는 회차에 무효가 있으면 수치 대신 `회차 무효` (RULES-05).
String warningCell(
  String name,
  Map<String, dynamic> row,
  Map<String, Map<String, dynamic>> runsById,
) {
  if (invalidReferences(row, runsById).isNotEmpty) return '회차 무효';
  final counts = asMap(row['counts']);
  if (row['group'] == 'G4') {
    final now = countCell(
      counts,
      currentBoundNote(row['markerDetectedCurrent']),
    );
    final at313 = countCell(
      asMap(row['counts313']),
      zeroNote(name, row['markerDetected']),
    );
    return '$now / 3.13 하한 $at313';
  }
  var cell = countCell(counts, zeroNote(name, row['markerDetected']));
  final ui = asMap(row['countsUI']);
  if (ui != null) cell = '$cell / UI ${countCell(ui, null)}';
  if (name == strictInference && row['severity'] != null) {
    cell = '$cell · ${row['severity']}';
  }
  return cell;
}

/// 행의 값 칸 (G4 는 하한 3.13 의 값이 `dart fix` 의 기준이다).
Map<String, dynamic>? valueCounts(Map<String, dynamic> row) =>
    asMap(row[row['group'] == 'G4' ? 'counts313' : 'counts']);

/// `dart fix` 칸 — 사라진 줄 (`fixRemoved`). 0줄이면 `해당 없음`, 재지 않은 행(`fixSkipped`)은
/// `재지 않음`, 단독 dry 가 0 이면 `0 (dry 0)`.
String fixCell(Map<String, dynamic> row) {
  final counts = valueCounts(row);
  if (counts == null) return '—';
  if (total(counts) == 0) return '해당 없음';
  if (row['fixSkipped'] is String) return '재지 않음';
  if (row['aloneDry'] == 0) return '0 (dry 0)';
  final removed = row['fixRemoved'];
  return removed is int ? '$removed' : '재지 않음';
}

/// 고친 뒤 새로 생긴 error 칸.
String errorCell(Map<String, dynamic> row) {
  final n = row['newErrors'];
  return n is int ? '$n' : '—';
}

/// 손으로 고칠 줄 = 경고 합계 − `dart fix` 로 사라진 줄 (D-05).
int manualLines(Map<String, dynamic> row) =>
    total(valueCounts(row)) - ((row['fixRemoved'] as int?) ?? 0);

/// 권고와 이유 — D-05 의 기계적 잣대. 위에서부터 첫 번째로 맞는 것.
(String, String) recommend(
  String name,
  Map<String, dynamic> row,
  Map<String, Map<String, dynamic>> runsById,
) {
  final deferredTo = row['deferredTo'];
  if (deferredTo != null) return ('v2 ($deferredTo)', '결정하지 않음 — 숫자만');
  final counts = valueCounts(row);
  if (counts == null) return ('결정 안 함', '값이 없다 — 재지 않음');
  final invalid = invalidReferences(row, runsById);
  if (invalid.isNotEmpty) return ('결정 안 함', '회차 무효 — ${invalid.join(', ')}');
  if (total(counts) == 0 && row['markerDetected'] != true) {
    final reason = noFileProbe[name];
    if (reason != null) return ('결정 안 함', '표식 불가 — $reason');
    return row['markerDetected'] == false
        ? ('결정 안 함', '표식 미검출 — 규칙이 돌지 않음')
        : ('결정 안 함', '표식 없음 — 0줄의 뜻을 가르지 못한다');
  }
  final messages = asMap(row['state'])?['messages'];
  if (messages == 'experimental' || messages == 'testing') {
    final note = name == 'unnecessary_ignore'
        ? ' — 출처마다 다름: messages.yaml experimental / rules.json · dart.dev stable'
        : '';
    return ('안 켬', '$messages (messages.yaml)$note');
  }
  final clashes = [
    for (final other in ((row['incompatible'] as List?) ?? const []))
      if (currentRules.contains(other)) '$other',
  ];
  if (clashes.isNotEmpty) {
    return ('안 켬', '비호환 — ${clashes.join(', ')} 과 함께 쓸 수 없다');
  }
  final newErrors = row['newErrors'];
  if (newErrors is int && newErrors > 0) {
    return ('안 켬', 'dart fix 가 error $newErrors건을 남긴다');
  }
  final bundle = row['bundle'];
  if (bundle == 'perf' || bundle == 'style') {
    final manual = manualLines(row);
    // `dart fix` 를 재지 않은 행은 손으로 고칠 줄 = 경고 전부다 — 그 사실을 이유에 붙인다.
    final skipped = row['fixSkipped'] is String ? ' — dart fix 는 재지 않음' : '';
    return manual <= manualFixLimit
        ? ('켬', '손으로 고칠 줄 $manual (≤ $manualFixLimit)$skipped')
        : ('안 켬', '손으로 고칠 줄 $manual (> $manualFixLimit)$skipped');
  }
  return ('검토', '실제 문제를 가리키는가 — 사람이 본다');
}

/// 터미널에서 [text] 가 차지하는 칸 수 (한글 등 전각 문자는 2칸) — `tool/verify.dart` 의
/// `measureWidth` 와 같은 셈법이다 (import 하지 않고 옮겼다).
int measureWidth(String text) {
  var width = 0;
  for (final rune in text.runes) {
    final wide =
        (rune >= 0x1100 && rune <= 0x115F) ||
        (rune >= 0x2E80 && rune <= 0xA4CF) ||
        (rune >= 0xAC00 && rune <= 0xD7A3) ||
        (rune >= 0xF900 && rune <= 0xFAFF) ||
        (rune >= 0xFF00 && rune <= 0xFF60);
    width += wide ? 2 : 1;
  }
  return width;
}

/// 칸 너비를 맞춘 Markdown 표 (머리 · 구분선 · 행).
List<String> renderTable(List<String> header, List<List<String>> rows) {
  final widths = <int>[];
  for (var i = 0; i < header.length; i++) {
    var w = measureWidth(header[i]);
    for (final r in rows) {
      final cw = measureWidth(r[i]);
      if (cw > w) w = cw;
    }
    widths.add(w);
  }
  String line(List<String> cells) {
    final padded = [
      for (var i = 0; i < cells.length; i++)
        '${cells[i]}${' ' * (widths[i] - measureWidth(cells[i]))}',
    ];
    return '| ${padded.join(' | ')} |';
  }

  return [
    line(header),
    '|${widths.map((w) => '-' * (w + 2)).join('|')}|',
    ...rows.map(line),
  ];
}

/// `conditions.dartFiles` 의 합 (표식 제외, 생성 파일 포함), 없으면 `?`.
String dartFileTotal(Map<String, dynamic> conditions) {
  final files = asMap(conditions['dartFiles']);
  if (files == null) return '?';
  return '${files.values.whereType<int>().fold<int>(0, (s, v) => s + v)}';
}

/// `--summary <묶음>` 의 줄 (D-06) — 머리 줄, 표, 굵은 `권고:` 줄, 선택지.
List<String> summaryLines(Map<String, dynamic> data, String bundleId) {
  final conditions = data['conditions'] as Map<String, dynamic>;
  final rows = data['rows'] as Map<String, dynamic>;
  final runsById = runsByIdOf(data);
  final picked = <(String, Map<String, dynamic>)>[
    for (final e in rows.entries)
      if (asMap(e.value)?['bundle'] == bundleId) (e.key, e.value),
  ];
  final tally = {'켬': 0, '안 켬': 0, '검토': 0, '결정 안 함': 0};
  final table = <(String, Map<String, dynamic>, List<String>)>[];
  for (final (name, row) in picked) {
    final (rec, reason) = recommend(name, row, runsById);
    final key = tally.containsKey(rec)
        ? rec
        : '결정 안 함'; // v2 (RULES-NN) 는 결정 안 함
    tally[key] = tally[key]! + 1;
    // 무효 회차를 참조하는 행은 수치를 쓰지 않는다 (RULES-05).
    final invalid = invalidReferences(row, runsById).isNotEmpty;
    table.add((
      name,
      row,
      [
        name,
        warningCell(name, row, runsById),
        invalid ? '—' : fixCell(row),
        invalid ? '—' : errorCell(row),
        rec,
        reason,
      ],
    ));
  }
  final estimated = bundleId == 'perf' || bundleId == 'style'
      ? ' ($manualFixLimit 은 추정)'
      : '';
  final lines = <String>[
    '[${bundles[bundleId]}] ${picked.length}개 — 권고: 켬 ${tally['켬']} · '
        '안 켬 ${tally['안 켬']} · 검토 ${tally['검토']} · 결정 안 함 ${tally['결정 안 함']}'
        '$estimated        실측 ${data['runId']} (${conditions['date']}, '
        'Flutter ${conditions['flutter']}, flutter_starter_kit Dart 파일 '
        '${dartFileTotal(conditions)}개)',
    '',
  ];
  const header = [
    '규칙',
    '경고 (lib·test·bin·pubspec)',
    'dart fix',
    '고친 뒤 error',
    '권고',
    '이유',
  ];
  if (table.length > 25) {
    // 행이 많은 묶음은 셋으로 나눈다 (D-06 의 재량).
    String part(Map<String, dynamic> row) {
      final n = total(valueCounts(row));
      final removed = row['fixRemoved'];
      if (n > 0 && removed is int && removed >= n) return 'dart fix 가 다 고치는 것';
      if (manualLines(row) <= manualFixLimit) {
        return '손으로 고칠 줄 $manualFixLimit 이하';
      }
      return '그 밖';
    }

    for (final title in [
      'dart fix 가 다 고치는 것',
      '손으로 고칠 줄 $manualFixLimit 이하',
      '그 밖',
    ]) {
      final members = [
        for (final (_, row, cells) in table)
          if (part(row) == title) cells,
      ];
      lines.add('#### $title (${members.length}개)');
      lines.add('');
      lines.addAll(members.isEmpty ? ['(없음)'] : renderTable(header, members));
      lines.add('');
    }
  } else {
    lines.addAll(
      renderTable(header, [for (final (_, _, cells) in table) cells]),
    );
    if (table.isEmpty) lines.add('(이 묶음의 후보 행이 없다)');
    lines.add('');
  }
  lines.add(
    '**권고:** 표의 권고 열대로 — 켬 ${tally['켬']}개, 안 켬 ${tally['안 켬']}개 '
    '(검토 ${tally['검토']}개는 사람이 정한다).',
  );
  lines.add('선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류');
  return lines;
}

/// `--summary <묶음>` — 소유자 검토용 터미널 요약을 stdout 으로 (D-06).
void printSummary(Map<String, dynamic> data, String bundleId) {
  for (final line in summaryLines(data, bundleId)) {
    stdout.writeln(line);
  }
}

/// `--report` 의 결과 — 단언이 어긋난 것([problems]) 또는 Markdown.
class Report {
  /// [problems] 가 비어 있을 때만 [markdown] 이 있다.
  Report(this.problems, this.markdown);

  /// 어긋난 단언 (한 줄씩).
  final List<String> problems;

  /// `RULES.md` § 실측 기록 에 들어갈 Markdown, 또는 null.
  final String? markdown;
}

/// 기반 세트 버전 맵([baseSetVersions] — 이름 → pub cache 폴더 이름 `<패키지>-<버전>`)을
/// `lints-6.1.0 · flutter_lints-6.0.0` 꼴로.
String baseSetText(Object? versions) {
  final m = asMap(versions);
  if (m == null || m.isEmpty) return '?';
  return [
    for (final k in ['lints', 'flutter_lints'])
      if (m.containsKey(k)) '${m[k]}',
  ].join(' · ');
}

/// 행의 상태 칸 — 분석이 deprecated / removed / 없음을 내면 그것, 아니면 `messages.yaml` 의 값.
/// 출처가 갈리는 넷은 다른 출처의 값을 덧붙인다 (D-02).
String stateCell(String name, Map<String, dynamic> row) {
  final state = asMap(row['state']);
  if (state == null) return '—';
  if (state['kind'] == 'option') return 'analyzer 옵션';
  final analysis = state['analysis'];
  if (analysis != null && analysis != 'ok') {
    return analysis == 'undefined' ? '없음' : '$analysis';
  }
  final note = stateSourceNotes[name];
  final messages = '${state['messages']} (messages.yaml)';
  return note == null ? messages : '$messages · $note';
}

/// `--report` — 단언 (1) ~ (7) 을 모두 보고, 통과하면 `RULES.md` § 실측 기록 의 Markdown
/// (회차 표 + 전체 평가표)을 만든다 (RULES-03 · RULES-04 · RULES-05).
Report buildReport(Map<String, dynamic> data) {
  final problems = <String>[];
  final conditions = data['conditions'] as Map<String, dynamic>;
  final rows = data['rows'] as Map<String, dynamic>;
  final runsById = runsByIdOf(data);
  final listedUnprobeable = conditions['noFileProbe'];
  final unprobeable = <String>{
    for (final e
        in listedUnprobeable is List
            ? listedUnprobeable
            : noFileProbe.keys.toList())
      '$e',
  };

  // (1) 행 133 이 후보와 같다.
  final expected = candidates.map((c) => c.name).toSet();
  final missingNames = expected.where((n) => !rows.containsKey(n)).toList()
    ..sort();
  final extraNames = rows.keys.where((n) => !expected.contains(n)).toList()
    ..sort();
  if (rows.length != candidates.length ||
      missingNames.isNotEmpty ||
      extraNames.isNotEmpty) {
    problems.add(
      '행이 후보 ${candidates.length}개와 다르다 — 행 ${rows.length}개, '
      '빠진 이름 ${missingNames.length}개: ${missingNames.join(', ')}; '
      '후보가 아닌 이름 ${extraNames.length}개: ${extraNames.join(', ')}',
    );
  }

  // (2) 결정 대상 121 행의 빈 칸.
  final lacking = <String, List<String>>{};
  final excepted = <String>[];
  for (final c in candidates) {
    if (c.deferredTo != null) continue;
    final row = asMap(rows[c.name]);
    if (row == null) continue; // (1) 이 잡는다
    final lack = <String>[
      for (final key in ['state', 'counts', 'ignored'])
        if (row[key] == null) key,
      if (((row['runs'] as List?) ?? const []).isEmpty) 'runs',
    ];
    final counts = asMap(row['counts']);
    if (counts != null && total(counts) > 0) {
      if (row['severity'] == null) lack.add('severity');
      // analyzer 옵션(`strict-inference`)도 그 진단 코드로 dart fix 단계를 돈다. 재지 않은 사유
      // (`fixSkipped`)가 적힌 행은 빈 `fixRemoved` · `newErrors` 를 빠진 칸으로 세지 않는다.
      final skipped = row['fixSkipped'] is String;
      if (row['fixRemoved'] == null && !skipped) lack.add('fixRemoved');
      if (row['newErrors'] == null && !skipped) lack.add('newErrors');
    } else if (counts != null && row['markerDetected'] == null) {
      if (unprobeable.contains(c.name)) {
        excepted.add(c.name);
      } else {
        lack.add('markerDetected');
      }
    }
    if (lack.isNotEmpty) lacking[c.name] = lack;
  }
  if (lacking.isNotEmpty) {
    final byField = <String, int>{};
    for (final lack in lacking.values) {
      for (final key in lack) {
        byField.update(key, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    problems.add(
      '값이 없는 행 ${lacking.length}개: ${lacking.keys.join(', ')} '
      '(빠진 칸: ${byField.entries.map((e) => '${e.key} ${e.value}').join(' · ')})',
    );
  }
  if (excepted.isNotEmpty && problems.isNotEmpty) {
    problems.add('(표식 불가라 0줄의 표식 칸을 묻지 않은 행: ${excepted.join(', ')})');
  }

  // (3) strict 계열 셋의 행, strict-inference 는 warning (또는 0줄).
  for (final name in ['no_dynamic_casts', 'no_raw_types', strictInference]) {
    if (!rows.containsKey(name)) problems.add('$name 행이 없다');
  }
  final strict = asMap(rows[strictInference]);
  if (strict != null &&
      total(asMap(strict['counts'])) > 0 &&
      strict['severity'] != 'warning') {
    problems.add(
      'strict-inference 의 강도가 warning 이 아니다 (${strict['severity']})',
    );
  }

  // (4) 언어 버전 3.13 전용 7개의 하한 3.13 값.
  final no313 = [
    for (final name in g4Rules)
      if (asMap(rows[name])?['counts313'] == null) name,
  ];
  if (no313.isNotEmpty) {
    problems.add('counts313 이 없는 G4 행 ${no313.length}개: ${no313.join(', ')}');
  }

  // (5) 행이 참조하는 회차가 모두 있고 유효하다.
  final badRefs = <String>[
    for (final e in rows.entries)
      if (asMap(e.value) != null &&
          invalidReferences(
            e.value as Map<String, dynamic>,
            runsById,
          ).isNotEmpty)
        '${e.key} (${invalidReferences(e.value as Map<String, dynamic>, runsById).join(', ')})',
  ];
  if (badRefs.isNotEmpty) {
    problems.add(
      '없거나 유효하지 않은 회차를 참조한 행 ${badRefs.length}개: ${badRefs.join(', ')}',
    );
  }

  // (6) 회차마다의 조건.
  const runKeys = [
    'dart',
    'flutter',
    'baseSet',
    'plugin',
    'languageVersion',
    'sdkConstraint',
    'dartFiles',
  ];
  final badRuns = <String>[
    for (final r in runsById.values)
      if (runKeys.any((k) => r[k] == null))
        '${r['id']} (${runKeys.where((k) => r[k] == null).join('·')})',
  ];
  if (badRuns.isNotEmpty) {
    problems.add('조건이 빈 회차 ${badRuns.length}개: ${badRuns.join(', ')}');
  }

  // (7) 값에 넣지 않은 자리의 진단 — 행이 참조한 회차에서 `marker` · `generated` · [valueAreas]
  // 밖의 자리에 그 규칙 코드가 있으면 값이 그 줄을 빠뜨린 것이다 (04-REVIEW.md CR-01). 같은 규칙 ·
  // 같은 자리는 회차가 여럿이어도 한 번만 적는다.
  final outsideAreas = <String, Set<String>>{};
  for (final c in candidates) {
    if (c.deferredTo != null) continue;
    final row = asMap(rows[c.name]);
    if (row == null) continue; // (1) 이 잡는다
    for (final id in ((row['runs'] as List?) ?? const []).map((e) => '$e')) {
      final byArea = asMap(runsById[id]?['countByAreaCode']);
      if (byArea == null) continue; // (5) 가 잡는다
      for (final area in byArea.entries) {
        if (area.key == 'marker' ||
            area.key == 'generated' ||
            valueAreas.contains(area.key)) {
          continue;
        }
        final codes = asMap(area.value) ?? const <String, dynamic>{};
        final hit = codes.entries.any(
          (e) =>
              codeMatchesRule(e.key, c.name) && e.value is int && e.value != 0,
        );
        if (hit) outsideAreas.putIfAbsent(c.name, () => {}).add(area.key);
      }
    }
  }
  if (outsideAreas.isNotEmpty) {
    final names = outsideAreas.keys.toList()..sort();
    problems.add(
      '값에 넣지 않은 자리에 진단이 있는 행 ${names.length}개: '
      '${names.map((n) => '$n (${(outsideAreas[n]!.toList()..sort()).join(', ')})').join(', ')}',
    );
  }

  if (problems.isNotEmpty) return Report(problems, null);

  final runId = data['runId'];
  final out = <String>['### 회차', ''];
  out.addAll(
    renderTable(
      [
        '회차',
        '날짜',
        'Dart',
        'Flutter',
        '기반 세트 (저장소 / 복사본)',
        'riverpod_lint',
        '언어 버전',
        'SDK 제약',
        'Dart 파일 (lib·test·bin, 생성)',
        '유효',
      ],
      [
        for (final r in runsById.values)
          [
            '$runId-${r['id']}',
            '${r['date']}',
            '${r['dart']}',
            '${r['flutter']}',
            '${baseSetText(asMap(r['baseSet'])?['repo'])} / '
                '${baseSetText(asMap(r['baseSet'])?['consumer'])}',
            '${r['plugin']}',
            '${r['languageVersion']}',
            '${r['sdkConstraint']}',
            '${areaTriple(asMap(r['dartFiles'])!, projectAreas)}, '
                '생성 ${asMap(r['dartFiles'])!['generated'] ?? 0}',
            r['valid'] == true ? '예' : '아니오',
          ],
      ],
    ),
  );
  final pairs = ((conditions['incompatiblePairs'] as List?) ?? const [])
      .whereType<Map<String, dynamic>>()
      .toList();
  final confirmed = pairs.where((p) => p['confirmed'] == true).length;
  out
    ..add('')
    ..add(
      '상태 출처: ${conditions['stateSource'] ?? '?'} · 비호환 쌍: 쌍마다 둘만 켠 분석에서 '
      '${pairs.length}개 가운데 $confirmed개 확인',
    )
    ..add('')
    ..add('### 평가표')
    ..add('');
  final names = rows.keys.toList()..sort();
  out.addAll(
    renderTable(
      [
        '규칙',
        '분류',
        '상태',
        '강도',
        '실측 (lib·test·bin·pubspec)',
        '3.13 하한',
        'dart fix',
        '고친 뒤 error',
        '가린 줄',
        '상류 세트',
        '함께 쓸 수 없는 규칙',
        '회차',
      ],
      [
        for (final name in names)
          () {
            final row = rows[name] as Map<String, dynamic>;
            final isG4 = row['group'] == 'G4';
            var measured = isG4
                ? countCell(
                    asMap(row['counts']),
                    currentBoundNote(row['markerDetectedCurrent']),
                  )
                : countCell(
                    asMap(row['counts']),
                    zeroNote(name, row['markerDetected']),
                  );
            final ui = asMap(row['countsUI']);
            if (ui != null) measured = '$measured / ${countCell(ui, null)}';
            return [
              '`$name`',
              bundles[row['bundle']] ?? '${row['bundle']}',
              stateCell(name, row),
              '${row['severity'] ?? '—'}',
              measured,
              isG4
                  ? countCell(
                      asMap(row['counts313']),
                      zeroNote(name, row['markerDetected']),
                    )
                  : '—',
              fixCell(row),
              errorCell(row),
              countCell(asMap(row['ignored']), null),
              '${row['upstream'] ?? '—'}',
              ((row['incompatible'] as List?) ?? const []).isEmpty
                  ? '—'
                  : (row['incompatible'] as List).join(', '),
              ((row['runs'] as List?) ?? const [])
                  .map((id) => '$runId-$id')
                  .join(', '),
            ];
          }(),
      ],
    ),
  );
  final unprobedZero = [
    for (final name in names)
      if (unprobeable.contains(name) &&
          asMap(rows[name])?['markerDetected'] == null &&
          total(asMap(asMap(rows[name])?['counts'])) == 0)
        name,
  ];
  out.add('');
  if (unprobedZero.isNotEmpty) {
    out
      ..add(
        '표식을 둘 수 없어 0줄의 뜻을 가르지 못한 규칙: ${unprobedZero.join(', ')} '
        '(이유는 tool/measure_rules.dart 의 noFileProbe)',
      )
      ..add('');
  }
  // `dart fix` 를 재지 않은 행과 그 사유 (RULES-03 의 "dart fix 로 고칠 수 있는 건수" 를 사실대로).
  final fixSkipped = [
    for (final name in names)
      if (asMap(rows[name])?['fixSkipped'] is String)
        '$name — ${asMap(rows[name])!['fixSkipped']}',
  ];
  if (fixSkipped.isNotEmpty) {
    out
      ..add('dart fix 를 재지 않은 행: ${fixSkipped.join(' / ')}')
      ..add('');
  }
  // 가린 줄이 음수인 행 — 무시 주석 자체를 보는 규칙 (04-REVIEW.md WR-02).
  final negativeIgnored = [
    for (final name in names)
      if (total(asMap(asMap(rows[name])?['ignored'])) < 0)
        '$name ${total(asMap(asMap(rows[name])?['ignored']))}',
  ];
  if (negativeIgnored.isNotEmpty) {
    out
      ..add(
        '가린 줄이 음수인 행은 무시 주석 자체를 보는 규칙이다 — 주석을 걷어내면 그 규칙의 줄도 '
        '함께 사라진다: ${negativeIgnored.join(', ')}',
      )
      ..add('');
  }
  out
    ..add(
      '실측: flutter_starter_kit (Dart 파일 ${dartFileTotal(conditions)}개), '
      'Flutter ${conditions['flutter']}, ${conditions['date']} — 자리별 건수는 무시 주석을 둔 채 잰 값'
      ' · pubspec 자리는 pubspec.yaml 파일에 보고된 줄',
    )
    ..add('')
    ..add('이 절은 tool/measure_rules.dart --report --write 가 생성한다. 손으로 고치지 않는다.');
  return Report(const [], '${out.join('\n')}\n');
}

/// `RULES.md` 의 `woody:measurements` 마커 사이를 [markdown] 으로 바꿔 쓴다 (마커는 남긴다).
/// 마커가 없으면 [FormatException] (70) — 파일을 건드리지 않는다.
void writeReport(String repoRoot, String markdown) {
  final file = File('$repoRoot/RULES.md');
  if (!file.existsSync()) throw const FormatException('RULES.md 가 없다');
  final lines = file.readAsLinesSync();
  final start = lines.indexOf(measurementsStart);
  final end = lines.indexOf(measurementsEnd);
  if (start < 0 || end < 0 || end < start) {
    throw const FormatException('RULES.md 에 woody:measurements 마커가 없다');
  }
  final next = [
    ...lines.sublist(0, start + 1),
    ...markdown.trimRight().split('\n'),
    ...lines.sublist(end),
  ];
  file.writeAsStringSync('${next.join('\n')}\n');
}

/// `RULES.md` 표의 행 하나 — 첫 칸의 이름과 칸 전부.
class RulesTableRow {
  /// [cells] 는 앞뒤 공백을 뗀 칸이다.
  RulesTableRow(this.name, this.cells);

  /// 첫 칸의 backtick 이름.
  final String name;

  /// 칸 전부 (첫 칸 포함).
  final List<String> cells;
}

/// `RULES.md` 의 마커 구역 [block] 의 표 — `tool/verify.dart` 의 `readRulesMdBlock` 과 같은
/// 규약: `|` 로 시작하는 줄의 첫 칸에서 backtick 하나로 감싼 `[a-z0-9_-]+` 를 이름으로 읽고,
/// 없으면 건너뛰고(헤더 · 구분선 · 평문), 둘 이상이면 형식 오류 줄로 모은다. 마커가 없으면 null.
(List<RulesTableRow>, List<String>)? readRulesTable(
  List<String> lines,
  String block,
) {
  final start = lines.indexOf('<!-- woody:$block:start -->');
  final end = lines.indexOf('<!-- woody:$block:end -->');
  if (start < 0 || end < 0 || end < start) return null;
  final rows = <RulesTableRow>[];
  final malformed = <String>[];
  final namePattern = RegExp(r'`([a-z0-9_-]+)`');
  for (final line in lines.sublist(start + 1, end)) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('|')) continue;
    var body = trimmed.substring(1);
    if (body.endsWith('|')) body = body.substring(0, body.length - 1);
    final cells = body.split('|').map((c) => c.trim()).toList();
    final found = namePattern
        .allMatches(cells.first)
        .map((m) => m.group(1)!)
        .toList();
    if (found.isEmpty) continue;
    if (found.length > 1) {
      malformed.add(trimmed);
    } else {
      rows.add(RulesTableRow(found.single, cells));
    }
  }
  return (rows, malformed);
}

/// `--audit` — 후보 133 과 B-7 31 이 `RULES.md` 의 세 표에 모두 있는지, 켜지 않은 규칙의 이유가
/// 접두사로 시작하는지, 켠 규칙 행에 빈 칸이 없는지 본다 (RULES-08 · DOCS-11). 종료 코드를 돌려준다.
int audit(String repoRoot) {
  final file = File('$repoRoot/RULES.md');
  if (!file.existsSync()) throw const FormatException('RULES.md 가 없다');
  final lines = file.readAsLinesSync();
  const blocks = ['enabled-rules', 'enabled-options', 'disabled-rules'];
  final tables = <String, List<RulesTableRow>>{};
  final problems = <String>[];
  for (final block in blocks) {
    final table = readRulesTable(lines, block);
    if (table == null) {
      throw FormatException('RULES.md 에 마커 구역 woody:$block 이 없다');
    }
    tables[block] = table.$1;
    if (table.$2.isNotEmpty) {
      problems.add(
        '첫 칸에 이름이 둘 이상인 줄 ${table.$2.length}개 ($block): ${table.$2.join(' / ')}',
      );
    }
  }
  final enabled = tables['enabled-rules']!;
  final options = tables['enabled-options']!;
  final disabled = tables['disabled-rules']!;

  // (a) 후보 133 ∪ B-7 31 이 세 표 가운데 하나에 있다.
  final listed = {
    for (final t in tables.values)
      for (final r in t) r.name,
  };
  final universe = [...candidates.map((c) => c.name), ...b7Rules.keys];
  final missing = universe.where((n) => !listed.contains(n)).toList()..sort();
  if (missing.isNotEmpty) {
    problems.add('RULES.md 에 없는 후보 ${missing.length}개: ${missing.join(', ')}');
  }

  // (b) 한 이름이 두 번(두 표에, 또는 한 표에 두 번) 적히지 않았다.
  final seen = <String, int>{};
  for (final t in tables.values) {
    for (final r in t) {
      seen.update(r.name, (v) => v + 1, ifAbsent: () => 1);
    }
  }
  final twice = [
    for (final e in seen.entries)
      if (e.value > 1) e.key,
  ]..sort();
  if (twice.isNotEmpty) {
    problems.add('두 번 적힌 이름 ${twice.length}개: ${twice.join(', ')}');
  }

  // (c) 켜지 않은 규칙의 이유는 접두사로 시작한다.
  String reasonOf(RulesTableRow r) => r.cells.length > 1 ? r.cells[1] : '';
  final badReasons = [
    for (final r in disabled)
      if (!disabledReasonPrefixes.any(reasonOf(r).startsWith)) r.name,
  ];
  if (badReasons.isNotEmpty) {
    problems.add('이유 접두사가 아니다: ${badReasons.join(', ')}');
  }

  // (d) 켠 규칙 행의 칸 여섯이 모두 차 있다 (DOCS-11).
  final emptyCells = [
    for (final r in enabled)
      if (r.cells.length != 6 ||
          r.cells.any((c) => c.isEmpty || c.startsWith('(실측 전')))
        r.name,
  ];
  if (emptyCells.isNotEmpty) {
    problems.add(
      '빈 칸이 있는 켠 규칙 ${emptyCells.length}개: ${emptyCells.join(', ')}',
    );
  }

  // (e) B-7 은 켜지 않았다.
  final enabledB7 = [
    for (final r in [...enabled, ...options])
      if (b7Rules.containsKey(r.name)) r.name,
  ];
  if (enabledB7.isNotEmpty) {
    problems.add('켜진 B-7 규칙 ${enabledB7.length}개: ${enabledB7.join(', ')}');
  }

  if (problems.isNotEmpty) {
    stdout.writeln('감사 실패 — RULES.md (RULES-08 · DOCS-11)');
    for (final p in problems) {
      stdout.writeln('  $p');
    }
    return 1;
  }
  final held = [
    for (final r in disabled)
      if (reasonOf(r).startsWith('보류')) r.name,
  ];
  stdout.writeln(
    '감사 통과 — 켠 ${enabled.length} · 옵션 ${options.length} · '
    '켜지 않음 ${disabled.length} · 보류 ${held.length}',
  );
  if (held.isNotEmpty) stdout.writeln('보류 ${held.length}개: ${held.join(', ')}');
  return 0;
}

/// `--recount` — 회차(`runs`)는 그대로 두고 행의 `counts` · `counts313` · `ignored` 를 회차의
/// `countByAreaCode` 에서 단계가 쓰는 식 그대로 다시 센다 (자리 집계가 바뀌었을 때 — 04-REVIEW.md
/// CR-01). 바뀐 행마다 한 줄을 [out] (기본 stdout) 에 찍고 바뀐 행의 이름을 돌려준다. 값 칸에
/// `pubspec.yaml` 키가 0 으로 더해지는 것은 바뀐 것으로 세지 않는다. 어느 회차가 결과에 없으면 그
/// 칸은 건드리지 않는다. 다시 센 뒤 줄이 있는데 `dart fix` 를 잰 흔적(단독 dry · 사라진 줄 ·
/// `apply-<규칙>` 회차)이 없는 미루지 않은 행에는 `fixSkipped` 사유를 적는다. 화면에는 규칙 이름과
/// 건수만 찍는다 (D-07).
List<String> recountRows(Map<String, dynamic> data, {StringSink? out}) {
  final sink = out ?? stdout;
  final rows = data['rows'] as Map<String, dynamic>;
  final runsById = runsByIdOf(data);
  final runId = '${data['runId']}';

  Map<String, int>? countsOf(String id, String rule) {
    final run = runsById[id];
    return run == null ? null : ruleCounts(run, rule);
  }

  Map<String, int>? diff(String a, String b, String rule) {
    final x = countsOf(a, rule);
    final y = countsOf(b, rule);
    return x == null || y == null ? null : subtractCounts(x, y);
  }

  bool same(Object? before, Map<String, int> after) {
    final b = asMap(before);
    if (b == null) return false;
    return valueAreas.every((a) => ((b[a] as int?) ?? 0) == after[a]);
  }

  String cell(Object? counts) {
    final m = asMap(counts);
    return m == null ? '—' : areaTriple(m);
  }

  final changed = <String>[];
  var recounted = 0;
  for (final c in candidates) {
    final row = asMap(rows[c.name]);
    if (row == null) continue;
    recounted++;
    // 단계가 쓰는 식 — measureBaseline · measureGroups · measureIgnore 와 같다.
    final fresh = <String, Map<String, int>?>{};
    switch (c.group) {
      case 'current':
        fresh['counts'] = countsOf('B0', c.name);
        fresh['ignored'] = diff('B0-strip', 'B0', c.name);
      case 'G4':
        fresh['counts313'] = diff('G4', 'B0-313', c.name);
        // G1 실행이 G4 의 규칙도 켠다 — 지금 하한의 값.
        fresh['counts'] = diff('G1', 'B0', c.name);
        fresh['ignored'] = diff('G4-strip', 'G4', c.name);
      default:
        final g = primaryRunId(c);
        fresh['counts'] = diff(g, 'B0', c.name);
        fresh['ignored'] = diff('$g-strip', g, c.name);
    }
    final notes = <String>[];
    final countsBefore = row['counts'];
    var countsChanged = false;
    for (final e in fresh.entries) {
      final after = e.value;
      if (after == null) continue; // 회차가 없다 — 건드리지 않는다
      final before = row[e.key];
      if (!same(before, after)) {
        if (e.key == 'counts') {
          countsChanged = true;
        } else {
          notes.add('${e.key} ${cell(before)} → ${areaTriple(after)}');
        }
      }
      row[e.key] = after;
    }
    if (c.deferredTo == null &&
        total(valueCounts(row)) > 0 &&
        row['fixRemoved'] == null &&
        row['aloneDry'] == null &&
        !runsById.containsKey('apply-${c.name}')) {
      final reason =
          '$runId 의 fix 단계는 이 규칙의 값이 0 으로 집계된 채 돌아 단독 dry 도 apply 도 하지 '
          '않았다 — 손으로 고칠 줄은 경고 전부로 본다';
      if (row['fixSkipped'] != reason) {
        row['fixSkipped'] = reason;
        notes.add('fixSkipped 적음');
      }
    }
    if (countsChanged || notes.isNotEmpty) {
      changed.add(c.name);
      sink.writeln(
        '${c.name}: counts ${cell(countsBefore)} → ${cell(row['counts'])}'
        '${notes.map((n) => ' · $n').join()}',
      );
    }
  }
  sink.writeln(
    changed.isEmpty
        ? '다시 센 행 $recounted개 — 바뀐 행이 없다'
        : '다시 센 행 $recounted개 — 바뀐 행 ${changed.length}개',
  );
  return changed;
}

/// [path] 를 저장소 상대 경로로 — 저장소 밖이면 파일 이름만 (절대 경로를 찍지 않는다, D-07).
String repoRelative(String path, String repoRoot) =>
    path.startsWith('$repoRoot/')
    ? path.substring(repoRoot.length + 1)
    : '(저장소 밖) ${path.split('/').last}';

/// `--recount [--write]` — 다시 세고, `--write` 이고 바뀐 행이 있을 때만 `conditions.recount`
/// (`date` · `changedRows`, 앞의 기록과 합집합) 를 적어 읽은 그 파일에 다시 쓴다.
int runRecount(OutputOptions o, Repo repo) {
  final path = locateResults(o, repo);
  final data = loadResultsJson(path);
  final changed = recountRows(data);
  if (!o.write) return 0;
  if (changed.isEmpty) {
    stderr.writeln('바뀐 행이 없다 — 쓰지 않았다');
    return 0;
  }
  final conditions = data['conditions'] as Map<String, dynamic>;
  final previous = asMap(conditions['recount'])?['changedRows'];
  final names = <String>{
    if (previous is List) ...previous.map((e) => '$e'),
    ...changed,
  }.toList()..sort();
  conditions['recount'] = <String, dynamic>{
    'date': localDate(),
    'changedRows': names,
  };
  // `Results.encode` 와 같은 모양 (들여쓰기 두 칸 + 끝 줄바꿈).
  File(
    path,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(data)}\n');
  stderr.writeln('결과 JSON 을 다시 썼다: ${repoRelative(path, repo.root)}');
  return 0;
}

/// 출력 모드 하나를 돌리고 종료 코드를 돌려준다 — 0 통과 (`--recount` 는 바뀐 행이 있든 없든) /
/// 1 단언 · 감사 실패 / 64 사용법 (결과 JSON 없음 포함) / 70 파일 모양 (`schema` 가 1 이 아님 ·
/// 마커 없음).
int runOutputMode(OutputOptions o, Repo repo) {
  if (o.mode == '--audit') return audit(repo.root);
  if (o.mode == '--recount') return runRecount(o, repo);
  final data = loadResultsJson(locateResults(o, repo));
  if (o.mode == '--summary') {
    printSummary(data, o.bundle!);
    return 0;
  }
  final report = buildReport(data);
  final markdown = report.markdown;
  if (markdown == null) {
    for (final p in report.problems) {
      stderr.writeln('실측 기록을 만들 수 없다 — $p');
    }
    return 1;
  }
  if (o.write) {
    writeReport(repo.root, markdown);
    stderr.writeln('RULES.md 의 실측 기록을 바꿔 썼다 (woody:measurements)');
  } else {
    stdout.write(markdown);
  }
  return 0;
}

/// 도구의 입구.
Future<void> main(List<String> args) async {
  // tool/ 의 부모가 저장소 루트다 (`tool/verify.dart` 와 같은 셈법).
  final repoRoot = Directory(File.fromUri(Platform.script).parent.parent.path)
      .resolveSymbolicLinksSync();
  final repo = Repo(repoRoot);
  String? work;
  String? source;
  String scrub(String text) =>
      scrubPaths(text, source: source, work: work, repoRoot: repoRoot);

  try {
    final problems = checkCandidates();
    if (problems.isNotEmpty) {
      stderr.writeln('후보 상수가 어긋났다 — ${problems.join('; ')}');
      await stderr.flush();
      exit(70);
    }
    final Options opts;
    try {
      final raw = readRawArgs(args);
      if (raw.outputModesGiven.isNotEmpty) {
        // 출력 모드 — 분석을 돌리지 않고, 저장소에는 `--report --write` 의 RULES.md 와
        // `--recount --write` 의 결과 JSON 말고 쓰지 않는다.
        final code = runOutputMode(parseOutputArgs(raw), repo);
        await stdout.flush();
        await stderr.flush();
        exit(code);
      }
      opts = parseArgs(args, repo);
      // 앞 단계의 회차가 필요한 단계 — 결과 파일은 읽기만 한다 (아직 아무것도 만들지 않는다).
      checkStageInputs(opts, existingRunIds(opts));
    } on UsageError catch (e) {
      stderr.writeln(scrub(e.message));
      stderr.writeln(usage);
      await stderr.flush();
      exit(64);
    }
    work = opts.work;
    source = opts.source;

    // 인자 검증이 끝난 뒤에만 작업 폴더를 만든다.
    Directory(opts.work).createSync(recursive: true);
    final results = Results.load(
      '${opts.work}/results/${opts.runId}.json',
      opts.runId,
    );
    results.conditions['dart'] = dartVersion();
    results.conditions['flutter'] = flutterVersion();
    (results.conditions['baseSet'] as Map<String, dynamic>)['repo'] =
        baseSetVersions(repoRoot);
    final consumer = Consumer(work: opts.work, repo: repo, source: opts.source);
    final ctx = Context(opts, repo, results, consumer);
    final guard = RepoGuard(repo, results, await repo.fingerprint());

    for (final stage in opts.stages) {
      if (stage == 'state') {
        await guard.step('state', () => measureState(opts, repo, results));
      } else {
        await guard.step(stage, () => runConsumerStage(ctx, stage));
      }
    }

    // 저장소 안에는 지문 비교가 모두 끝난 뒤에만 쓴다 (Pitfall 2).
    final out =
        opts.out ??
        '$repoRoot/tool/measurements/'
            '${results.conditions['date']}-${opts.runId}.json';
    if (out != results.path) {
      File(out).parent.createSync(recursive: true);
      File(out).writeAsBytesSync(File(results.path).readAsBytesSync());
    }
    final invalid = results.invalidRuns(ctx.touchedRuns);
    stdout.writeln(
      '결과: ${scrub(results.path)} (회차 ${ctx.touchedRuns.length}개, '
      '유효하지 않은 회차 ${invalid.length}개${invalid.isEmpty ? '' : ' — ${invalid.join(', ')}'})',
    );
    await stdout.flush();
    await stderr.flush();
    exit(invalid.isEmpty ? 0 : 1);
  } on UsageError catch (e) {
    stderr.writeln(scrub(e.message));
    await stderr.flush();
    exit(64);
  } on SubcommandFailure catch (e) {
    stderr.writeln(scrub(e.message));
    await stderr.flush();
    exit(69);
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${scrub(e.message)}');
    await stderr.flush();
    exit(70);
  } on FileSystemException catch (e) {
    stderr.writeln('파일 작업 실패: ${scrub(e.message)} (${scrub(e.path ?? '')})');
    await stderr.flush();
    exit(70);
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: ${scrub('$e')}');
    await stderr.flush();
    exit(70);
  } on StateError catch (e) {
    stderr.writeln('멈췄다: ${scrub(e.message)}');
    await stderr.flush();
    exit(70);
  } on HttpException catch (e) {
    stderr.writeln('받기 실패: ${scrub(e.message)}');
    await stderr.flush();
    exit(70);
  }
}
