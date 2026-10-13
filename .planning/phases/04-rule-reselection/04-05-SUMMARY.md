---
phase: 04-rule-reselection
plan: 05
subsystem: testing
tags: [lint-rules, owner-decision, rule-selection, checkpoint]

requires:
  - phase: 04-rule-reselection
    provides: "04-04 — 회차 R1 결과 tool/measurements/2026-10-13-R1.json (후보 133행, 회차 50개 모두 유효)"
provides:
  - ".planning/phases/04-rule-reselection/04-DECISIONS.md — 묶음 패널 5개 · 개별 질문 9개 · 결정 표 133행 (켬 80 · 안 켬 35 · 결정 안 함 5 · v2 12 · 보류 1)"
  - "D-18 사유 문구 (승인) — 04-06 · 04-07 의 lib/base.yaml 사유 주석과 RULES.md 켠 이유의 입력"
affects: [04-06, 04-07, 04-08, 04-09, 04-10]

actuals:
  tokens: 17001
  tasks: 3
  commits: 2
plan_head_before: ccebf7f2be89ffa73d042603af09bdae58fc1b11
plan_head_after: cd02f8976b9e1e8b106d15b425b5875e62420401

tech-stack:
  added: []
  patterns:
    - "패널의 실측 표는 --summary 출력을 자리 표시로 끼워 넣어 원문 그대로 옮기고, 결정 표는 결과 JSON 의 행 집합에서 만든다 (손으로 옮겨 적지 않는다)"
    - "결정 표의 사유 칸은 '권고 이유 승인 — …' 로 적어 Claude 의 말과 소유자의 말을 가른다 (T-04-14)"

key-files:
  created:
    - .planning/phases/04-rule-reselection/04-DECISIONS.md
  modified: []

key-decisions:
  - "소유자가 규칙별 채택을 정했다 (2026-10-13, 로드맵 D13) — 묶음 1 ~ 5 모두 권고대로, 질문 1 ~ 6 모두 권고와 같은 답. 켬 80 · 안 켬 35, 결정 안 함 5 (표식 불가 4 · 표식 미검출 1), v2 12, 보류 1 (unnecessary_ignore, 04-08). 원본은 04-DECISIONS.md 의 결정 표"
  - "strict 계열은 no_dynamic_casts · no_raw_types 를 켜고 strict-inference 는 켜지 않는다 — warning 이라 받는 쪽 dart analyze 가 바로 실패하고 106줄 모두 test · dart fix 0. fixtures/base_codegen 의 exit 0 은 그대로다"
  - "import 스타일은 prefer_relative_imports 를 켠다 (flutter_starter_kit 의 lib 에서 상대 경로 615 대 package 9). always_use_package_imports 는 켜지 않는다"
  - "fire-and-forget 은 unawaited_futures (남김) · discarded_futures 를 켜고 unnecessary_unawaited 는 켜지 않는다 (dart fix 가 error 9건을 남긴다)"
  - "지금 켜 둔 5개는 모두 남기고, prefer_const_constructors · prefer_const_literals_to_create_immutables · always_declare_return_types 의 사유 문구는 D-18 제안대로 고친다 (승인 문구는 04-DECISIONS.md 의 '표 밖의 응답과 메모')"
  - "unnecessary_underscores 는 후보가 아니다 (lints 6.1.0 recommended 에 있다) — 질문 7 의 답은 '그대로 둔다' 이고 결정 표 밖에 기록했다"

patterns-established:
  - "개별 질문이 후보 행이 없는 규칙을 가리키면 답의 선택지를 '그대로 둔다 / 끈다' 로 바꾸고 결정 표 밖의 메모에 적는다 — 결정 표는 결과 JSON 의 행 집합과 같아야 한다"

requirements-completed: [RULES-06]

coverage:
  - id: D1
    description: "04-DECISIONS.md 초안 — 제목, 묶음 1 ~ 5, 질문 1 ~ 9, 결정 절, 권고 줄 24개, D-19 · D-05 · Pitfall 3 · D-18 · v2 · 보류 문구, 결정 표 133행과 비운 결정 칸, 절대 경로 꼴 0줄, 초안 커밋"
    requirement: "RULES-06"
    verification:
      - kind: other
        ref: "04-05-PLAN.md Task 1 <automated> — 초안 커밋 0362628 뒤 TASK1_RC=0"
        status: pass
    human_judgment: false
  - id: D2
    description: "결정 표의 켬 / 안 켬 115행이 소유자 응답으로 차 있고 사유가 비지 않는다 — v2 12 · 보류 1 · 결정 안 함 5 는 초안 그대로"
    requirement: "RULES-06"
    verification:
      - kind: other
        ref: "04-05-PLAN.md <verification> 의 python3 -I 셈 — 'decisions ok', VERIFY_RC=0"
        status: pass
    human_judgment: true
    rationale: "결정 칸이 소유자의 응답과 같은지(권고가 결정으로 둔갑하지 않았는지)는 응답 원문과 견주는 사람의 확인이다 — 응답은 orchestrator 를 거쳐 왔다"
  - id: D3
    description: "패널 · 결정 표 · SUMMARY 에 사용 프로젝트의 경로 · 메시지 · 코드 조각이 없다 (D-07)"
    verification:
      - kind: other
        ref: "비공개 점검 (1) 절대 경로 꼴 grep — 초안 0줄, 결정 뒤 0줄"
        status: pass
    human_judgment: true
    rationale: "grep 은 절대 경로 꼴만 본다 — 메시지 · 코드 조각이 없다는 판단은 패널이 --summary 출력(건수와 이름)만 담는다는 것을 사람이 본다"

duration: 21min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 05: 규칙별 채택 결정 Summary

**회차 R1 의 묶음별 터미널 요약으로 소유자가 후보 133개의 채택을 정했다 — 묶음 5개 모두 권고대로, 개별 질문 7개 답, 켬 80 · 안 켬 35 · 결정 안 함 5 · v2 12 · 보류 1 (`unnecessary_ignore`, 04-08) 을 `04-DECISIONS.md` 의 결정 표에 기록**

## Performance

- **Duration:** 21분 (소유자 응답을 기다린 시간 포함)
- **Started:** 2026-10-13T01:53:41Z
- **Completed:** 2026-10-13T02:14:53Z
- **Tasks:** 3 (Task 1 auto, Task 2 · 3 막는 checkpoint — 응답은 한 메시지로 받음)
- **Files modified:** 1 (+ 이 SUMMARY 와 state 파일)

## Accomplishments

- `04-DECISIONS.md` 초안 (`0362628`, 857줄):
  - 머리: 실측 조건 · 읽는 법 · 묻는 방식 · 권고의 잣대 · 권고 합계 표
  - 묶음 패널 다섯: 용어 풀이 → 찾아본 것 → `--summary` 출력 원문 → 권고 표 → 굵은 `**권고:**` → 선택지
  - 질문 아홉 (질문 3 의 D-19, 질문 7 의 `use_super_parameters` 선례, 질문 8 의 "결정을 묻지 않는다", 질문 9 의 04-08 보류)
  - 결정 표 133행
- `검토` 로 나온 행 61개에 Claude 가 권고 · 이유를 붙였다 (버그 방지 25, 지금 켜 둔 5, 제외 권장 24, strict 3, import 2, fire 2). 도구가 판정한 72행은 그 판정이 권고다.
- 소유자 응답으로 결정 표의 `결정` · `사유` 115행을 채웠다 (`cd02f89`, 868줄). D-18 의 승인 문구와 질문 7 의 답은 표 아래 "표 밖의 응답과 메모" 에 적었다.

## 소유자 응답

2026-10-13, orchestrator 가 묶음 1 ~ 5 · 질문 1 ~ 9 의 패널을 원문 그대로 보인 뒤 선택지 질문으로 받았다. 소유자는 어느 항목에도 사유를 따로 덧붙이지 않았다.

| 묶음 · 질문 | 응답 |
|---|---|
| 묶음 1 버그 방지 (`bug`) | 권고대로 — 켬 23 · 안 켬 2 (`avoid_equals_and_hash_code_on_mutable_classes`, `avoid_implementing_value_types`) |
| 묶음 2 성능 (`perf`) | 권고대로 — 켬 8 |
| 묶음 3 가독성·스타일 (`style`) | 권고대로 — 켬 39, 결정 안 함 (표식 불가) 2 그대로 |
| 묶음 4 지금 켜 둔 5개 (`current`) | 권고대로 — 5개 모두 남김, D-18 사유 문구 수정 제안 승인 |
| 묶음 5 제외 권장 (`excluded`) | 권고대로 — 안 켬 28, 결정 안 함 3 그대로 |
| 질문 1 `no_dynamic_casts` | 켬 |
| 질문 2 `no_raw_types` | 켬 |
| 질문 3 `strict-inference` | 안 켬 |
| 질문 4 import | (a) `prefer_relative_imports` 켬 · `always_use_package_imports` 안 켬 |
| 질문 5 fire-and-forget | `unawaited_futures` 켬 · `discarded_futures` 켬 · `unnecessary_unawaited` 안 켬 |
| 질문 6 함께 쓸 수 없는 쌍 | `prefer_double_quotes` 안 켬 · `unnecessary_final` 안 켬 |
| 질문 7 `unnecessary_underscores` | 그대로 둔다 (결정 표 밖) |
| 질문 8 v2 12개 | 묻지 않음 (숫자만 보임) |
| 질문 9 `unnecessary_ignore` | 보류 (04-08) 를 알림 |

**켬 80개:** `always_declare_return_types`, `async_return_with_no_await`, `avoid_bool_literals_in_conditional_expressions`, `avoid_catching_errors`, `avoid_double_and_int_checks`, `avoid_dynamic_calls`, `avoid_escaping_inner_quotes`, `avoid_final_parameters`, `avoid_js_rounded_ints`, `avoid_multiple_declarations_per_line`, `avoid_redundant_argument_values`, `avoid_setters_without_getters`, `avoid_slow_async_io`, `avoid_type_to_string`, `avoid_unused_constructor_parameters`, `avoid_void_async`, `cancel_subscriptions`, `cast_nullable_to_non_nullable`, `combinators_ordering`, `conditional_uri_does_not_exist`, `deprecated_member_use_from_same_package`, `directives_ordering`, `discarded_futures`, `document_ignores`, `flutter_style_todos`, `join_return_with_assignment`, `leading_newlines_in_multiline_strings`, `literal_only_boolean_expressions`, `matching_super_parameters`, `missing_whitespace_between_adjacent_strings`, `no_adjacent_strings_in_list`, `no_dynamic_casts`, `no_literal_bool_comparisons`, `no_raw_types`, `no_runtimetype_tostring`, `no_self_assignments`, `noop_primitive_operations`, `omit_obvious_local_variable_types`, `only_throw_errors`, `parameter_assignments`, `prefer_asserts_in_initializer_lists`, `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`, `prefer_constructors_over_static_methods`, `prefer_final_in_for_each`, `prefer_final_locals`, `prefer_if_elements_to_conditional_expressions`, `prefer_int_literals`, `prefer_null_aware_method_calls`, `prefer_relative_imports`, `prefer_single_quotes`, `simple_directive_paths`, `simplify_variable_pattern`, `sized_box_shrink_expand`, `sort_constructors_first`, `sort_unnamed_constructors_first`, `specify_nonobvious_property_types`, `switch_on_type`, `test_types_in_equals`, `throw_in_finally`, `tighten_type_of_initializing_formals`, `type_annotate_public_apis`, `unawaited_futures`, `unnecessary_breaks`, `unnecessary_lambdas`, `unnecessary_library_directive`, `unnecessary_null_aware_operator_on_extension_on_nullable`, `unnecessary_null_checks`, `unnecessary_parenthesis`, `unnecessary_raw_strings`, `unnecessary_statements`, `use_colored_box`, `use_enums`, `use_is_even_rather_than_modulo`, `use_named_constants`, `use_raw_strings`, `use_setters_to_change_properties`, `use_string_buffers`, `use_truncating_division`.

- 그중 지금 켜 둔 6개를 남긴 것 (`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `always_declare_return_types`, `prefer_final_locals`, `prefer_single_quotes`, `unawaited_futures`) — 새로 켜는 규칙은 74개다.
- **안 켬 35개**, **결정 안 함 5개** (표식 불가: `sort_pub_dependencies`, `use_test_throws_matchers`, `require_trailing_commas`, `package_prefixed_library_names`; 표식 미검출: `remove_deprecations_in_breaking_versions`), **v2 12개**, **보류 1개** (`unnecessary_ignore`).

## Task Commits

1. **Task 1: 04-DECISIONS.md 초안** — `0362628` (docs)
2. **Task 2: 묶음 승인 checkpoint** — 커밋 없음 (응답은 Task 3 의 커밋에 함께)
3. **Task 3: 개별 질문 checkpoint + 결정 기록** — `cd02f89` (docs)

**Plan metadata:** SUMMARY 커밋과 마무리 커밋 (docs)

## 검증 명령 결과

- Task 1 `<automated>` (초안 커밋 뒤): `TASK1_RC=0`. 이 명령의 python 단언 "그 밖의 결정 칸은 비었거나 `결정 안 함 (표식`" 은 초안 상태를 보는 것이라, 결정을 채운 뒤에는 계획대로 실패한다 — 결정 뒤의 판정은 아래 `<verification>` 셈이다.
- `<verification>` 의 python3 -I 셈 (결정 커밋 전):
  ```text
  {'켬': 80, '안 켬': 35, '보류': 1, '결정 안 함 (표식 불가)': 4, 'v2': 12, '결정 안 함 (표식 미검출)': 1}
  켬 80 (이름 목록 — 위의 소유자 응답 절과 같다)
  decisions ok
  ```
  `VERIFY_RC=0`.
- 비공개 점검 (1) 절대 경로 꼴: 초안 0줄, 결정 뒤 0줄.
- 루트 `fvm dart analyze`: 초안 커밋 전 rc 0, 결정 커밋 전 rc 0 (둘 다 `No issues found!`).
- 결정 커밋 `docs(04): 소유자 결정 기록 — 묶음 5 · 개별 질문 7 (2026-10-13)` 있음.

## Files Created/Modified

- `.planning/phases/04-rule-reselection/04-DECISIONS.md` — 묶음 패널 · 개별 질문 패널 · 결정 표 (규칙 / 묶음 / 권고 / 결정 / 사유) · 표 밖의 응답과 메모. 04-06 · 04-07 · 04-08 의 입력.

## Decisions Made

- 위 key-decisions — 모두 소유자의 응답이다. Claude 가 정한 것은 권고뿐이고, 그 권고는 표의 `권고` 칸에만 있다. `사유` 칸에는 소유자가 쓴 말이 아니라는 것을 `권고 이유 승인 — …` 로 드러냈다.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] 질문 7 의 대상이 후보가 아니었다**
- **Found during:** Task 1
- **Issue:** 계획은 질문 7 에서 `--summary status` 의 `unnecessary_underscores` 를 켬 / 안 켬 으로 묻게 했다. 그런데 이 규칙은 `lints` 6.1.0 의 recommended 에 있어 이미 켜져 있다. 실측 도구도 이 규칙의 행을 만들지 않았다 (`bundleRules` 주석). 그래서 출력은 0행이었다.
- **Fix:** 질문 7 의 선택지를 `그대로 둔다` / `끈다` 로 바꿨다. 끄는 데 드는 비용(맵 형식, WR-03)과 `use_super_parameters` 선례를 보였고, 답은 결정 표 밖의 메모에 적었다. 결정 표는 결과 JSON 의 133행 그대로이다 — Task 1 검사가 후보 밖의 행을 막는다.
- **Files modified:** `04-DECISIONS.md`
- **Commit:** `0362628`, `cd02f89`

**2. [Rule 1 - Bug] 결정 대상 수가 120 이 아니라 115**
- **Found during:** Task 1
- **Issue:** must_haves 는 "121 − `unnecessary_ignore` = 120 개에 켬 / 안 켬". 계획 본문은 `결정 안 함 (표식 미검출)` 만 따로 둔다. 그러나 R1 에서 도구가 `결정 안 함` 으로 판정한 행은 5개다 — 표식 미검출 1에 더해 표식 불가 4 (`noFileProbe`, 04-04 SUMMARY 의 "결정 안 함이 될 규칙 5개").
- **Fix:** 표식 불가 4행에는 `결정 안 함 (표식 불가)` 를 적었다. 이 값은 Task 1 검사의 `결정 안 함 (표식` 접두어와 맞는다. 켬 / 안 켬 을 받은 행은 115개다. `<verification>` 셈도 `결정 안 함 (표식 …)` 전체를 빼고 셌다.
- **Files modified:** `04-DECISIONS.md`
- **Commit:** `0362628`

---

**Total deviations:** 2 (Rule 1 둘 — 둘 다 계획 문장과 R1 데이터의 차이)
**Impact on plan:** 결정의 내용은 바뀌지 않았다. 04-06 Task 1 의 precondition 이 "120" 을 세면 115 로 읽어야 한다.

## Issues Encountered

- 각 묶음의 `text` 블록 끝에 도구가 찍은 `**권고:**` 줄은 `검토` 행을 세지 않아 "켬 0개" 처럼 읽힌다. 문서의 "읽는 법" 에 그 줄이 무엇인지 적었다.

## User Setup Required

None.

## Next Phase Readiness

- 04-06 · 04-07 이 결정 표의 `결정` 칸(`켬` 80)과 묶음 id 로 `lib/base.yaml` · 샘플 · 정답지 · `RULES.md` 를 반영한다.
- 새로 켜는 규칙은 74개이고, 지금 켜 둔 6개는 남긴다. 사유 문구는 "표 밖의 응답과 메모" 의 D-18 승인 문구를 쓴다.
- `strict-inference` 를 켜지 않으므로 `fixtures/base_codegen` 의 `exit 0` 은 그대로다. CHANGELOG 의 `### 올리기 전에` 에 warning 불릿도 생기지 않는다.
- `prefer_final_locals` 를 남기므로 `fixtures/overrides` 의 끄기 시연은 그대로다 (Pitfall 3).
- `unnecessary_ignore` 는 04-08 에서 다시 재서 묻는다.
- 04-06 의 precondition 이 결정 대상을 "120" 으로 세면 115 로 맞춘다 (Deviations 2).

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*

## Self-Check: PASSED

- `.planning/phases/04-rule-reselection/04-DECISIONS.md` 있음 (868줄)
- 커밋 `0362628` · `cd02f89` 가 HEAD 의 조상
- `lib/` · `RULES.md` · `example/` · `fixtures/` · `CHANGELOG.md` · `tool/` 는 HEAD 와 같다 (이 plan 의 diff 는 04-DECISIONS.md 하나)
