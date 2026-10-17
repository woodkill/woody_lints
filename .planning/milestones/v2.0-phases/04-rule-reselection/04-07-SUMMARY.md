---
phase: 04-rule-reselection
plan: 07
subsystem: lint-config
tags: [analysis_options, lint-rules, golden-files, verify-harness, rules-md]

requires:
  - phase: 04-rule-reselection
    provides: "04-06 의 반영 A (켠 규칙 33), 04-DECISIONS.md 결정 표 (e42e984 의 결정 안 함 3행 답 포함), 회차 R1 실측 JSON"
provides:
  - "lib/base.yaml — 성능 8 · 가독성·스타일 39 를 더해 켠 규칙 80"
  - "샘플 example/lib/performance_rules.dart · style_rules.dart · final_parameters_rule.dart 와 fixture 다섯 복사본, 정답지 다섯에 B4 8줄 · B5 41 / 50줄"
  - "RULES.md — 켠 규칙 표 80행, 켜지 않은 규칙 표 91행 (보류 1), --audit 감사 통과"
  - "CHANGELOG 2.0.0 의 `### 추가한 규칙` 에 47 불릿 더함 (모두 74)"
affects: [04-08, 04-09, 04-10]

actuals:
  tokens: 19369
  tasks: 3
  commits: 3

plan_head_before: e42e984f20d79a9a173b141615b2263d1ffbdb8d
plan_head_after: ba580602d6c333769670a99e4e89e975d8b49f8d

tech-stack:
  added: []
  patterns:
    - "언어 버전 3.13 에서 돌지 않는 규칙의 샘플은 그 파일만 `// @dart=3.11` 로 둔다 (final_parameters_rule.dart) — 다른 샘플 파일의 언어 버전은 그대로"
    - "켜지 않은 규칙 표의 행은 결정 표 · R1 JSON · measure_rules.dart 의 noFileProbe · b7Rules 에서 스크립트로 만든다"

key-files:
  created:
    - example/lib/performance_rules.dart
    - example/lib/style_rules.dart
    - example/lib/final_parameters_rule.dart
    - fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/lib/performance_rules.dart
    - fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/lib/style_rules.dart
    - fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/lib/final_parameters_rule.dart
  modified:
    - lib/base.yaml
    - RULES.md
    - CHANGELOG.md
    - example/expected_diagnostics.txt
    - fixtures/base_only/expected_diagnostics.txt
    - fixtures/base_riverpod/expected_diagnostics.txt
    - fixtures/base_codegen/expected_diagnostics.txt
    - fixtures/overrides/expected_diagnostics.txt

key-decisions:
  - "성능 8개 · 가독성·스타일 39개를 켰다 — 결정 표의 perf · style 켬 그대로, excluded 켬 0 · status 0행이라 그 밖에 더한 규칙이 없고 뺀 규칙 0 (04-07)"
  - "기존 샘플에 새 규칙이 걸린 줄은 받아들였다 (Pitfall 5, 같은 커밋에서 켠 규칙) — 정답지 다섯 모두 join_return_with_assignment · specify_nonobvious_property_types 각 1줄, overrides 는 suppress 의 document_ignores 6 · specify_nonobvious_property_types 3줄 더. 끄는 설정의 시연은 그대로 성립한다 (04-07)"
  - "avoid_final_parameters 의 샘플은 언어 버전 3.11 로 둔 final_parameters_rule.dart 한 파일에 있다 — 연습용 프로젝트가 sdk ^3.13.0 이라 다른 파일에서는 규칙이 돌지 않고 final 매개변수가 error 다 (04-07)"
  - "omit_obvious_property_types 는 RULES.md 에 소유자 결정이 아니라 비호환 접두사로 적었다 — 켠 type_annotate_public_apis 와 함께 쓸 수 없다는 것이 소유자가 승인한 사유 그대로다 (04-07)"
  - "unnecessary_underscores 는 결정 표에 행이 없어 RULES.md 켜지 않은 규칙 표에 기반 세트 행으로 적고 상태 출처의 갈림(messages.yaml experimental 3.7 · rules.json · dart.dev stable)을 덧붙였다 — lib/base.yaml 에는 더하지 않았다 (04-07)"

patterns-established:
  - "켜지 않은 규칙 표의 v2 행은 `v2 로 미룸 (RULES-NN) — 실측 N줄 (...)`, G4 는 `· 3.13 하한 N줄`, testing 상태는 `· 상태 testing`"

requirements-completed: [RULES-06, RULES-08, DOCS-11]

coverage:
  - id: D1
    description: "성능 8개가 lib/base.yaml · RULES.md · CHANGELOG 에 반영되고 정답지 다섯에 규칙마다 1줄씩 8줄이 생겼다 (커밋 B4)"
    requirement: RULES-06
    verification:
      - kind: other
        ref: "04-07-PLAN Task 1 <automated> 의 고친 판 (orchestrator note 3 의 ① ~ ④), HEAD = 6c0bc83, rc 0, SEGFAIL1 없음"
        status: pass
    human_judgment: false
  - id: D2
    description: "가독성·스타일 39개가 반영되고 정답지에 샘플 39줄과 기존 샘플에 걸린 같은 규칙의 줄이 생겼다 (커밋 B5)"
    requirement: RULES-06
    verification:
      - kind: other
        ref: "04-07-PLAN Task 2 <automated> 의 고친 판, HEAD = 944ca1c, rc 0, SEGFAIL1 없음"
        status: pass
    human_judgment: false
  - id: D3
    description: "RULES.md 켜지 않은 규칙 표가 완성되어 --audit 이 보류 1 (unnecessary_ignore) 만 남기고 통과한다 (커밋 B6)"
    requirement: RULES-08
    verification:
      - kind: other
        ref: "04-07-PLAN Task 3 <automated> 쓰인 그대로, HEAD = ba58060, rc 0; fvm dart run tool/measure_rules.dart --audit — 감사 통과 — 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 1"
        status: pass
    human_judgment: false
  - id: D4
    description: "RULES.md 켠 규칙 표 80행의 분류 · 켠 이유 · 실측 · dart fix · 회차가 모두 차 있다"
    requirement: DOCS-11
    verification:
      - kind: other
        ref: "fvm dart run tool/verify.dart — [3/10] 통과, 점검 통과 (10개 중 10개); Task 1 · 2 python 단언 (켠 이유 == 사유 주석, 실측 == R1 counts)"
        status: pass
    human_judgment: false
  - id: D5
    description: "새 사유 주석 47개와 켜지 않은 규칙 표의 문장이 읽기에 맞는지 (문구 품질)"
    verification: []
    human_judgment: true
    rationale: "결정 표 사유가 `도구 판정: 손으로 고칠 줄 N` 인 성능 · 스타일 규칙은 사유 주석을 FEATURES.md 의 '잡는 것' 에서 새로 썼다 — 글자 일치는 자동으로 확인했지만 문장이 규칙의 뜻을 바르게 설명하는지는 사람이 읽어야 한다"

duration: 17min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 07: 반영 B — 성능 · 가독성·스타일 · 켜지 않은 규칙 표 완성 Summary

**`lib/base.yaml` 에 성능 8개 · 가독성·스타일 39개를 켜(켠 규칙 80) 규칙마다 위반 샘플 한 줄을 정답지 다섯에 넣고, `RULES.md` 켜지 않은 규칙 표를 제외 권장 · 비호환 쌍 · v2 12 · B-7 31 · 보류 1 로 채워 `--audit` 이 `보류 1개: unnecessary_ignore` 만 남기고 통과한다.**

## Performance

- **Duration:** 17 min
- **Started:** 2026-10-13T03:55:38Z
- **Completed:** 2026-10-13T04:12:55Z
- **Tasks:** 3
- **Files modified:** 8 수정 + 18 생성 (샘플 3종 × 6벌)

## Accomplishments

- 결정 표 다시 읽음: 133행 = 켬 80 · 안 켬 38 · 결정 안 함 14 (v2 12 + 규칙이 돌지 않음 2) · 보류 1. orchestrator 의 사전 집계와 같다.
- B4: 성능 8개, 정답지 다섯 각각 `+lib/` 8줄 · `-lib/` 0 · `exit` 변화 없음.
- B5: 가독성·스타일 39개, 정답지 `+lib/` example · base_only · base_riverpod · base_codegen 각 41줄, overrides 50줄, `-lib/` 0 · `exit` 변화 없음 (`base_codegen` 은 `exit 0` 그대로).
- B6: `RULES.md` 켜지 않은 규칙 표에 77행 더함 (제외 권장 31 · 쌍 2 · v2 12 · B-7 31 · 보류 1). `RULES.md` 만 바뀌었다.
- `example/lib/added_rules.dart` 는 `74fafb2` 와 같다.

## Task Commits

1. **Task 1: 성능 묶음 (B4)** - `6c0bc83` (feat)
2. **Task 2: 가독성·스타일 묶음 + 제외 권장에서 켠 것 (B5)** - `944ca1c` (feat)
3. **Task 3: 켜지 않은 규칙 표 완성 (B6)** - `ba58060` (docs)

**Plan metadata:** SUMMARY 커밋과 STATE · ROADMAP 커밋은 이 파일 뒤에 따로 한다.

## 묶음별 결정 반영

| 묶음 | 켬 (새로) | 안 켬 | 결정 안 함 · 보류 | 뺀 규칙 |
|---|---|---|---|---|
| 성능 (`perf`) | 8 — `avoid_slow_async_io`, `no_runtimetype_tostring`, `noop_primitive_operations`, `prefer_const_declarations`, `sized_box_shrink_expand`, `use_colored_box`, `use_string_buffers`, `use_truncating_division` | 0 | 0 | 0 |
| 가독성·스타일 (`style`) | 39 — `avoid_bool_literals_in_conditional_expressions`, `avoid_escaping_inner_quotes`, `avoid_final_parameters`, `avoid_multiple_declarations_per_line`, `avoid_redundant_argument_values`, `avoid_setters_without_getters`, `combinators_ordering`, `directives_ordering`, `document_ignores`, `flutter_style_todos`, `join_return_with_assignment`, `leading_newlines_in_multiline_strings`, `no_literal_bool_comparisons`, `omit_obvious_local_variable_types`, `prefer_asserts_in_initializer_lists`, `prefer_constructors_over_static_methods`, `prefer_final_in_for_each`, `prefer_if_elements_to_conditional_expressions`, `prefer_int_literals`, `prefer_null_aware_method_calls`, `simple_directive_paths`, `simplify_variable_pattern`, `sort_constructors_first`, `sort_unnamed_constructors_first`, `specify_nonobvious_property_types`, `tighten_type_of_initializing_formals`, `type_annotate_public_apis`, `unnecessary_breaks`, `unnecessary_lambdas`, `unnecessary_library_directive`, `unnecessary_null_aware_operator_on_extension_on_nullable`, `unnecessary_null_checks`, `unnecessary_parenthesis`, `unnecessary_raw_strings`, `use_enums`, `use_is_even_rather_than_modulo`, `use_named_constants`, `use_raw_strings`, `use_setters_to_change_properties` | 2 — `sort_pub_dependencies`, `use_test_throws_matchers` (소유자 결정, B5 에서 표에) | 0 | 0 |
| 상태 갈림 (`status`) | 0 (0행 — `unnecessary_underscores` 는 후보가 아니다, 질문 7 "그대로 둔다") | 0 | 0 | 0 |
| 제외 권장 (`excluded`) | 0 | 29 — 소유자 결정 28 (그중 `dart fix` error 건수로 적은 4: `always_specify_types` 6 · `diagnostic_describe_all_properties` 148 · `omit_local_variable_types` 4 · `specify_nonobvious_local_variable_types` 4, 그리고 `remove_deprecations_in_breaking_versions`) + 비호환 1 (`omit_obvious_property_types`) | 2 — `require_trailing_commas`, `package_prefixed_library_names` (규칙이 돌지 않음, 표식 불가) | 0 |
| 함께 쓸 수 없는 쌍 (`pairs`) | 0 | 2 — `prefer_double_quotes`, `unnecessary_final` (비호환) | 0 | 0 |
| v2 (`v2`) | 0 | 0 | 12 — `v2 로 미룸 (RULES-09 · 10 · 11)` 숫자만 | 0 |
| UI (`ui`) | 0 | 0 | 1 — `unnecessary_ignore` 보류 (04-08) | 0 |
| B-7 (후보 밖) | 0 | 31 — deprecated 6 · removed 14 · 없음 2 · experimental 9 (상태만) | 0 | 0 |
| **합계 (이 plan)** | **47** | **64** | **15** | **0** |

`unnecessary_underscores` 는 결정 표에 행이 없다 — 켜지 않은 규칙 표에 `기반 세트 — \`lints\` 6.1.0 \`recommended.yaml\` 이 켠다 — 상태 출처가 갈린다 (\`messages.yaml\` experimental 3.7 · \`rules.json\` · dart.dev stable)` 한 행을 B5 에서 더했다 (D-02). Task 2 의 python 단언 `if 'unnecessary_underscores' in rows` 는 결정 표에 그 이름이 없어 건너뛴다.

## 정답지의 바뀐 줄 (정답지 다섯 각각)

| 커밋 | `+lib/` 줄 | `-lib/` 줄 | `exit` 줄 | 샘플 수 | 기존 샘플에 걸린 줄 (Pitfall 5) |
|---|---|---|---|---|---|
| B4 `6c0bc83` | 8 (다섯 모두) | 0 | 변화 없음 | 8 (`performance_rules.dart`) | 0 |
| B5 `944ca1c` | example · base_only · base_riverpod · base_codegen 41, overrides 50 | 0 | 변화 없음 | 39 (`style_rules.dart` 38 + `final_parameters_rule.dart` 1) | 다섯 모두 2: `bug_prevention_rules.dart:135 join_return_with_assignment`, `riverpod_rules.dart:13 specify_nonobvious_property_types`. overrides 는 9 더: `suppress/lint_file.dart:1` · `suppress/plugin_file_prefixed.dart:1` · `suppress/plugin_file_unprefixed.dart:1` · `suppress/plugin_line.dart:8` · `:10` · `:12` 의 `document_ignores` 6, `suppress/plugin_file_prefixed.dart:5` · `suppress/plugin_file_unprefixed.dart:5` · `suppress/plugin_line.dart:4` 의 `specify_nonobvious_property_types` 3 |
| B6 `ba58060` | 0 (정답지 파일 그대로) | 0 | 변화 없음 | 0 | — |

- 기존 샘플에 걸린 줄은 모두 같은 커밋에서 켠 규칙의 줄이라 Research 의 규칙대로 받아들였다 (샘플을 고치지 않음). `added_rules.dart` 에는 걸린 줄이 없다.
- `suppress/lint_line.dart:2` 의 무시 주석은 바로 윗줄이 `///` 주석이라 `document_ignores` 가 걸리지 않았다 (규칙이 윗줄의 `//` 주석을 사유로 본다). 끄는 설정 다섯 칸의 시연(꺼진 줄이 정답지에 없고 대조 줄이 있다)은 그대로다.
- 같은 날이라 정답지 머리 주석의 날짜 줄은 바뀌지 않았다.
- `fixtures/recommended` 는 정답지가 없고 같은 실행의 `example` 과 견주어 통과했다.

## `--audit` 출력 (B6 뒤)

```text
감사 통과 — 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 1
보류 1개: unnecessary_ignore
```

켜지 않음 91 = 기반 세트 7 (04-01 의 6 + `unnecessary_underscores`) · 04-06 의 5 · B5 의 2 · B6 의 77. 접두사별: 소유자 결정 34 · removed 14 · v2 로 미룸 12 · experimental 9 · 기반 세트 7 · deprecated 6 · 비호환 4 · 규칙이 돌지 않음 2 · 없음 2 · 보류 1.

## 각 task 의 `<automated>` 결과 (HEAD 가 그 task 의 커밋일 때 돌림)

| Task | 적힌 그대로 | +SEGFAIL1 | 고친 판 | 고친 판 + SEGFAIL1 |
|---|---|---|---|---|
| 1 (B4) | rc 1 — 복사본 `diff -rq` 의 `exit 1` (`relative_imports_rule.dart`) | rc 1 (같은 `exit 1`, `SEGFAIL1` 앞에서 끝남) | rc 0 | rc 0, `SEGFAIL1` 없음 |
| 2 (B5) | rc 1 — 같은 `exit 1` | rc 1 (같음) | rc 0 | rc 0, `SEGFAIL1` 없음 |
| 3 (B6) | rc 0 | rc 0, `SEGFAIL1` 없음 | rc 0 (④ 만 바꿈) | rc 0, `SEGFAIL1` 없음 |

- `SEGFAIL1` 판은 ` || echo SEGFAIL1` 을 ` && OUT=$(` 바로 앞(첫 `&&` 사슬의 끝)에 넣었다. Task 1 · 2 는 사슬 안의 `for … do … || exit 1; done` 이 셸 전체를 끝내므로 `SEGFAIL1` 이 찍히기 전에 rc 1 로 끝난다.
- Task 1 · 2 의 python 단언 부분만 따로 돌리면 쓰인 그대로도 `B4 ok` · `B5 ok` 를 찍는다 — 실패는 ③ 하나다. 이번 커밋들은 `lib/base.yaml` 의 기존 줄을 고치지 않아 ① · ② 는 쓰인 그대로도 걸리지 않았다.
- 고친 판은 orchestrator note 3 의 ① ~ ④ 만 바꿨다: ① 더한 규칙 = `+` 이름 − `-` 이름, 뺀 규칙 = `-` 이름 − `+` 이름; ② `exit` 은 첫 글자가 `+` / `-` 인 줄만; ③ `diff -rq -x relative_imports_rule.dart` (overrides 는 `suppress` 줄도 뺌) 와 패키지 이름을 `woody_lints_example` 로 바꾼 `relative_imports_rule.dart` 의 `cmp`; ④ `git log -1 …` 을 task 커밋 SHA 로 고정.

## Files Created/Modified

- `lib/base.yaml` — `# 성능` 아래 8개, `# 가독성 및 스타일` 아래 39개 (사유 주석 포함)
- `RULES.md` — 켠 규칙 표 47행, 켜지 않은 규칙 표 80행 (B5 3 · B6 77), 접두사 목록 아래 `보류` 설명 한 줄
- `CHANGELOG.md` — `### 추가한 규칙` 47 불릿
- `example/lib/performance_rules.dart` + 복사본 다섯 — 성능 8개 샘플
- `example/lib/style_rules.dart` + 복사본 다섯 — 가독성·스타일 38개 샘플 (맨 위 directive 넷 포함)
- `example/lib/final_parameters_rule.dart` + 복사본 다섯 — `avoid_final_parameters` (언어 버전 3.11)
- 정답지 다섯 — `--update` 로만 썼다

## Decisions Made

- 성능 · 스타일 규칙의 사유 주석은 결정 표의 사유(`도구 판정: 손으로 고칠 줄 N (≤ 50)`)가 아니라 FEATURES.md § B-2 · § B-3 의 "잡는 것" 에서 썼다 — 켠 이유로 읽혀야 해서다. `prefer_const_declarations` 는 결정 문서의 덧붙임대로 "성능" 이 아니라 관례로 적었다 (lints#205).
- `style_rules.dart` 의 맨 위 directive 넷(`library;` · `show sin, cos` · `dart:collection` 이 `dart:math` 뒤 · `export './performance_rules.dart'`)이 샘플이다. `simple_directive_paths` 는 쓰지 않는 import 의 warning 을 피하려고 import 가 아니라 export 로 두었다.
- `no_runtimetype_tostring` 은 다른 값의 `runtimeType` (`value.runtimeType.toString()`)에는 걸리지 않아(보통 실행에서 0줄) 클래스 안의 `runtimeType.toString()` 으로 바꿨다.
- `prefer_null_aware_method_calls` 샘플은 매개변수가 아닌 public final 필드로 두었다 — 매개변수는 null 검사 뒤 승격되어 `callback!` 에 `unnecessary_non_null_assertion` warning 이 붙고 `base_codegen` 의 `exit 0` 이 바뀐다.
- `prefer_const_declarations` 를 함께 켠 탓에 `avoid_multiple_declarations_per_line` 샘플은 상수가 아닌 값(`x`, `x + 1`)으로 두었다.
- 켜지 않은 규칙 표의 문구: 제외 권장 안 켬은 `소유자 결정 — <결정 표 사유에서 "권고 이유 승인 — " 를 뗀 것>`, dart fix error 를 남기는 4개는 `소유자 결정 — dart fix 가 error N건을 남긴다 (R1)` (`always_specify_types` 는 켠 `omit_obvious_local_variable_types` 와도 함께 쓸 수 없다는 말을 덧붙임). `sort_pub_dependencies` · `use_test_throws_matchers` · `remove_deprecations_in_breaking_versions` 의 사유는 orchestrator 지시대로 결정 표 문장을 그대로 옮겨 `(04-07 실행 전 질문)` 이 남아 있다.
- v2 G4 의 "지금 하한" 값은 넷(`empty_container_bodies` 등, `markerDetectedCurrent: false`)을 `돌지 않음 — 표식까지 0줄`, 셋(`use_declaring_parameters` · `initialize_in_field_declaration` · `unnecessary_primary_constructor_body`)을 `표식 없음 — 3.13 문법이라 지금 하한에 넣지 않았다` 로 나눠 적었다 (결정 문서의 `0 (돌지 않음)` / `0 (표식 없음)` 구분).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Task 1 · 2 의 복사본 `diff -rq` 가 `relative_imports_rule.dart` 에서 실패한다 (04-06 Deviations 3 과 같은 결함)**
- **Found during:** Task 1 · 2 검증
- **Issue:** fixture 마다 자기 패키지 이름을 적는 `relative_imports_rule.dart` 때문에 `diff -rq example/lib fixtures/$f/lib` 가 늘 다르다.
- **Fix:** 고친 판의 ③ (위 표). 저장소 파일은 바꾸지 않았고 PLAN 도 고치지 않았다.
- **Verification:** 고친 판 rc 0, SEGFAIL1 없음.
- **Committed in:** 해당 없음 (검증 명령만 고침)

**2. [Rule 3 - Blocking] `avoid_final_parameters` 샘플을 `style_rules.dart` 에 둘 수 없다**
- **Found during:** Task 2
- **Issue:** 연습용 프로젝트 여섯은 `sdk: ^3.13.0` 이다. 언어 버전 3.13 에서는 이 규칙이 돌지 않고 보통 매개변수의 `final` 이 error 라, `style_rules.dart` 에 두면 규칙 줄 대신 error 가 생겨 `exit` 이 바뀐다 (04-03 SUMMARY 의 같은 사실).
- **Fix:** 샘플을 `// @dart=3.11` 을 단 `lib/final_parameters_rule.dart` 한 파일에 두고 여섯 프로젝트에 글자 그대로 복사했다. `style_rules.dart` 머리 주석에 이 사실과 규칙 이름을 적었다 (Task 2 의 "샘플 doc 줄" 단언은 `*_rules.dart` 를 본다). 계획의 `files_modified` 에 없는 파일이다.
- **Verification:** 보통 실행에서 정답지 다섯 모두 `lib/final_parameters_rule.dart:6  info  avoid_final_parameters` 1줄, error 없음.
- **Files modified:** `example/lib/final_parameters_rule.dart`, `fixtures/*/lib/final_parameters_rule.dart`
- **Committed in:** `944ca1c`

**3. [Rule 1 - Bug] `omit_obvious_property_types` 를 `비호환` 접두사로 적었다**
- **Found during:** Task 3
- **Issue:** 계획은 제외 권장의 안 켬을 `소유자 결정 — <사유>` 로 적으라 했지만, 이 규칙의 승인된 사유는 "`type_annotate_public_apis` 와 함께 쓸 수 없다" 이고 B5 에서 그 규칙을 켰다. `RULES.md` 의 접두사 안내에서 그 경우는 `비호환` 이다 (04-06 의 `always_use_package_imports` 와 같은 꼴).
- **Fix:** `비호환 — 켠 \`type_annotate_public_apis\` 와 함께 쓸 수 없다 (소유자 결정 2026-10-13, 사용 프로젝트에서 켜면 716줄)`. Task 3 의 단언과 `--audit` 은 접두사 집합만 본다.
- **Committed in:** `ba58060`

**4. [기록] B6 커밋 메시지를 한 번 고쳤다 (amend)**
- 처음 메시지의 "소유자 결정 27" 이 틀려(28) push 전에 메시지만 고쳤다. 내용은 같다. 처음 해시 `d2d2c0c` 는 브랜치에 없다.

---

**Total deviations:** 3 auto-fixed (Rule 1 둘 — 검증 명령의 결함 · 접두사 분류, Rule 3 하나 — 샘플 파일 하나 더) + 기록 1
**Impact on plan:** 결정 반영과 1:1 대응은 계획대로다 (`+` 줄 규칙 집합 == 더한 규칙). 샘플 수와 `+` 줄 수는 B5 에서 다르다 — 기존 샘플에 같은 규칙이 걸린 2줄(overrides 11줄) 때문이고 위 표에 모두 적었다.

## Issues Encountered

- 계획의 Task 2 문장은 `excluded` 의 켬과 `status` 를 함께 다루지만 둘 다 0이었다 — 제외 권장 묶음에서 켠 규칙이 없어 `performance_rules.dart` · `bug_prevention_rules.dart` 에 더한 것이 없다 (기존 파일의 줄 번호 그대로).
- 04-08 이 `unnecessary_ignore` 를 다시 잴 때: 이 plan 이 켠 `document_ignores` 는 `unnecessary_ignore` 의 apply 와 줄 수가 얽힌다 (결정 문서 묶음 3 의 덧붙임).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 04-08 (`unnecessary_ignore` 재측정 · 질문)이 이어서 할 수 있다 — `RULES.md` 의 그 행은 `보류 — …` 이고 `--audit` 의 보류 1 이 그것이다.
- 뒤 plan 이 같은 꼴의 `<automated>` 를 쓰면 복사본 비교는 `relative_imports_rule.dart` 를 빼고 견줘야 한다. `final_parameters_rule.dart` 는 여섯이 글자 그대로 같아 `diff -rq` 에 걸리지 않는다.

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*

## Self-Check: PASSED

- 생성 파일(샘플 3종 × 6벌) 모두 있음, 커밋 `6c0bc83` · `944ca1c` · `ba58060` 모두 HEAD 의 조상, `example/lib/added_rules.dart` 는 `74fafb2` 와 같음, 이 파일의 비공개 경로 점검 0줄.
