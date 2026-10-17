---
phase: 04-rule-reselection
plan: 09
subsystem: docs
tags: [rules-md, changelog, measure_rules, verify, review-disposition, roadmap]

requires:
  - phase: 04-rule-reselection
    provides: "04-06 · 04-07 의 결정 반영(켠 규칙 80), 04-08 의 회차 R1 JSON (B0 · G1 · G4 · UI …) 과 unnecessary_ignore 안 켬 결정"
provides:
  - "RULES.md § 실측 기록 (woody:measurements) — --report --write 가 생성한 회차 표와 후보 133개 평가표"
  - "CHANGELOG 2.0.0 ### 새로 생기는 경고 — 새로 켠 규칙 74개의 | 규칙 | 강도 | 실측 | dart fix | 표와 실측 줄"
  - "example/README.md M25 (새로 켠 규칙 하나를 지운 변경) 와 확인 기록 (ii)"
  - "03-REVIEW-DISPOSITION.md WR-01 fixed · WR-02 deferred · WR-03 open"
  - "ROADMAP Phase 4 Spike first 완료 표시 · 평가표 칸 문구(D-02) · Phase 5 Notes 첫 일(WR-02)"
affects: [05-documentation, 06-release]

actuals:
  tokens: 25363
  tasks: 2
  commits: 2
plan_head_before: 3dc9d1f666e2073a09d2a858c907ece156b784d5
plan_head_after: 2b2b475248ce0c1e7c4196284e8bb4d165c7f9fb

tech-stack:
  added: []
  patterns:
    - "CHANGELOG 의 새로 생기는 경고 표는 R1 JSON 에서 계산해 넣는다 — 행 순서는 ### 추가한 규칙 의 순서, 실측 = counts 의 lib + test + bin 합계, dart fix = fixRemoved (실측 0 이면 해당 없음)"

key-files:
  created: []
  modified:
    - RULES.md
    - CHANGELOG.md
    - example/README.md
    - .planning/ROADMAP.md
    - .planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md

key-decisions:
  - "CHANGELOG 새로 생기는 경고 표는 칸 맞춤 없이 | 규칙 | 강도 | 실측 | dart fix | 로 쓴다 — 계획의 단언과 artifacts 의 contains 가 이 글자 그대로를 찾는다 (VERSIONING.md 의 예시는 칸을 맞췄지만 표의 뜻은 같다)"
  - "M25 에 쓴 규칙은 no_self_assignments — 샘플 한 줄(lib/bug_prevention_rules.dart:124)이 정답지 다섯 모두에 있고 다른 규칙과 겹치지 않는다"

patterns-established:
  - "지워 보기 기록에서 recommended ([6/10]) 는 자기 정답지 없이 같은 실행의 example 결과와 견주므로, 규칙 하나를 지운 변경에서는 통과한다 (M18 · M25)"

requirements-completed: [RULES-03, RULES-05, RULES-07, RULES-08, DOCS-11]

coverage:
  - id: D1
    description: "RULES.md § 실측 기록이 --report --write 로 생성되어 회차 표와 후보 133개 평가표가 있고, --audit 이 감사 통과 · 보류 0 이다"
    requirement: "RULES-05"
    verification:
      - kind: other
        ref: "04-09-PLAN.md Task 1 <automated> (평가표 정규식 한 곳을 칸 맞춤 허용으로 고친 판 — Deviations 1)"
        status: pass
      - kind: other
        ref: "fvm dart run tool/measure_rules.dart --audit"
        status: pass
    human_judgment: false
  - id: D2
    description: "CHANGELOG 2.0.0 의 새로 생기는 경고 표 74행이 R1 JSON 의 합계 · fixRemoved 와 같고, 실측 줄과 RULES.md 안내 줄이 있으며 1.3.0 아래가 그대로다"
    requirement: "DOCS-11"
    verification:
      - kind: other
        ref: "04-09-PLAN.md Task 1 <automated> 의 python 단언 (D1 ok)"
        status: pass
    human_judgment: false
  - id: D3
    description: "example/README.md 의 M25 와 확인 기록 (ii), 03-REVIEW-DISPOSITION.md 의 WR-01 ~ 03, ROADMAP 의 D-23 세 군데"
    verification:
      - kind: other
        ref: "04-09-PLAN.md Task 2 <automated> (적힌 그대로 rc 0)"
        status: pass
    human_judgment: false
  - id: D4
    description: "RULES.md 평가표 · CHANGELOG 표 · README 문장이 읽기에 맞는지 (문구 품질)"
    verification: []
    human_judgment: true
    rationale: "문장의 읽기 품질은 단언이 보지 않는다 — 소유자가 읽어야 한다"

duration: 7min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 9: 근거 문서 마무리 Summary

**`RULES.md` § 실측 기록을 `--report --write` 로 생성(회차 표 + 후보 133개 평가표, `--audit` 감사 통과 · 보류 0)하고, CHANGELOG 2.0.0 의 새로 생기는 경고를 새로 켠 규칙 74개의 표로 채웠으며, 지워 보기 M25 · 확인 기록 (ii) · Phase 3 리뷰 WR-01 ~ 03 처리 · 로드맵 D-23 을 적었다.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-10-13T04:53:42Z
- **Completed:** 2026-10-13T05:00:30Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- `RULES.md` 의 `woody:measurements` 구역을 도구가 생성했다 — `### 회차` (R1-B0 · B0-313 · G1 ~ G4 · marker · strip · apply-* · UI-base · UI 등, 모두 유효) 와 `### 평가표` (후보 133행), 표식을 둘 수 없던 4개의 줄, 실측 한 줄, "손으로 고치지 않는다" 문장.
- `--audit` 요약 줄: `감사 통과 — 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0` (종료 코드 0).
- CHANGELOG `### 새로 생기는 경고`: 표 74행 (새로 켠 규칙 74 = `lib/base.yaml` 80 − 원래 6, `strict-inference` 안 켬이라 그 행 없음, `unnecessary_ignore` 안 켬이라 그 행 없음). 강도는 모두 info. 실측이 있는 규칙 32개, 0건(`해당 없음`) 42개. 표 아래 `실측: flutter_starter_kit (Dart 파일 474개), Flutter 3.47.5, 2026-10-13` 과 `자리별 건수(lib · test · bin)와 회차는 RULES.md 의 실측 기록에 있다.` `###` 절 순서는 올리기 전에 → 추가한 규칙 → 그 밖의 변경 → 새로 생기는 경고 (뺀 규칙 없음).
- 행 이름 (`### 추가한 규칙` 순서): prefer_relative_imports, async_return_with_no_await, avoid_catching_errors, avoid_double_and_int_checks, avoid_dynamic_calls, avoid_js_rounded_ints, avoid_type_to_string, avoid_unused_constructor_parameters, avoid_void_async, cancel_subscriptions, cast_nullable_to_non_nullable, conditional_uri_does_not_exist, deprecated_member_use_from_same_package, discarded_futures, literal_only_boolean_expressions, matching_super_parameters, missing_whitespace_between_adjacent_strings, no_adjacent_strings_in_list, no_self_assignments, only_throw_errors, parameter_assignments, switch_on_type, test_types_in_equals, throw_in_finally, unnecessary_statements, no_dynamic_casts, no_raw_types, avoid_slow_async_io, no_runtimetype_tostring, noop_primitive_operations, prefer_const_declarations, sized_box_shrink_expand, use_colored_box, use_string_buffers, use_truncating_division, avoid_bool_literals_in_conditional_expressions, avoid_escaping_inner_quotes, avoid_final_parameters, avoid_multiple_declarations_per_line, avoid_redundant_argument_values, avoid_setters_without_getters, combinators_ordering, directives_ordering, document_ignores, flutter_style_todos, join_return_with_assignment, leading_newlines_in_multiline_strings, no_literal_bool_comparisons, omit_obvious_local_variable_types, prefer_asserts_in_initializer_lists, prefer_constructors_over_static_methods, prefer_final_in_for_each, prefer_if_elements_to_conditional_expressions, prefer_int_literals, prefer_null_aware_method_calls, simple_directive_paths, simplify_variable_pattern, sort_constructors_first, sort_unnamed_constructors_first, specify_nonobvious_property_types, tighten_type_of_initializing_formals, type_annotate_public_apis, unnecessary_breaks, unnecessary_lambdas, unnecessary_library_directive, unnecessary_null_aware_operator_on_extension_on_nullable, unnecessary_null_checks, unnecessary_parenthesis, unnecessary_raw_strings, use_enums, use_is_even_rather_than_modulo, use_named_constants, use_raw_strings, use_setters_to_change_properties.
- M25: `lib/base.yaml` 에서 `no_self_assignments` 줄 하나를 지우고 검증 명령을 돌렸다 — 실패한 단계는 `[3/10]` (`- no_self_assignments  (RULES.md 에만)`) 과 `[5/10]` · `[7/10]` · `[8/10]` · `[9/10]` · `[10/10]` (정답지 다섯 모두 `lib/bug_prevention_rules.dart:124  info  no_self_assignments` 가 "나오지 않은 경고 (1)"). `[6/10]` recommended 는 통과 (같은 실행의 example 결과와 견주므로 — M18 과 같은 까닭). 요약 `점검 실패 (10개 중 6개)`, 종료 코드 1, 21초. `git checkout -- lib/base.yaml` 뒤 `git diff --quiet -- lib` 통과, 보통 실행 종료 코드 0 · `점검 통과 (10개 중 10개)`. 지운 채로 `--update` 는 돌리지 않았다.
- 확인 기록 (ii) — 묶음 커밋마다 정답지 다섯의 `+lib/` 줄 (커밋마다 `git diff` 로 다시 셈): B1 `9cff42e` 0 (샘플 0) · B2 `354959c` 25 × 5 (샘플 25) · B3 `52402df` 2 × 5 (샘플 2) · B4 `6c0bc83` 8 × 5 (샘플 8) · B5 `944ca1c` 41 × 4 와 overrides 50 (샘플 39 — 같은 커밋에서 켠 규칙이 기존 샘플에 걸린 줄: 다섯 모두 2, overrides 는 9 더; 새 규칙 39개 밖의 이름 0) · B6 `ba58060` 0. `-lib/` 줄은 모두 0, `exit` 줄 변화 없음. 04-08 은 묶음 커밋 없음.
- `03-REVIEW-DISPOSITION.md`: WR-01 `fixed` · WR-02 `deferred` · WR-03 `open`, 셋에 `note:`; 본문 표의 WR-01 · WR-02 행과 `open: 14` → `12` 도 맞춤 (`total: 14` 그대로).
- ROADMAP: Phase 4 `**Spike first**` 에 2026-10-12 완료 문구, Notes 의 평가표 칸 문구를 D-02 대로, 쌍 문구를 "쌍마다 둘만 켜서 확인한다 (spike 020)" 로, Phase 5 Notes 첫 불릿에 WR-02 를 가장 먼저 할 일로.

## Task Commits

1. **Task 1: RULES.md 실측 기록 · --audit · CHANGELOG 표 (D1)** - `3238ab0` (docs) — `docs(rules): RULES.md 실측 기록 생성과 CHANGELOG 새로 생기는 경고 표 — 회차 R1`
2. **Task 2: M25 · 확인 기록 (ii) · DISPOSITION · ROADMAP (D2)** - `2b2b475` (docs) — `docs(04): 지워 보기 M25 · 확인 기록 (ii) · 03 리뷰 WR-01 ~ 03 처리 · 로드맵 D-23`

**Plan metadata:** 이 SUMMARY 를 담는 커밋 (docs(04-09))

### 검증 명령 (`<automated>`) 결과

| Task | 적힌 그대로 rc | 고친 판 rc | 무엇을 바꿨나 |
|------|----------------|-----------|---------------|
| 1 | 1 | 0 | 평가표 행 이름을 읽는 정규식 하나 (`\x60 \|` → `\x60 +\|`) — 생성된 평가표는 칸을 맞춰 이름 뒤에 공백이 여럿이다. CHANGELOG 쪽 정규식은 그대로 둠 |
| 2 | 0 | — | — |

두 블록 모두 해당 task 커밋 직후, 다른 커밋 전에 `bash` 로 돌렸다.

## Files Created/Modified

- `RULES.md` - `woody:measurements` 구역 생성 (도구가 씀)
- `CHANGELOG.md` - 2.0.0 의 `### 새로 생기는 경고` 표와 두 줄
- `example/README.md` - M25 행, M25 측정 조건 문장, 읽는 법 불릿, 확인 기록 (ii)
- `.planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md` - WR-01 ~ 03 의 disposition · note, 본문 표 두 행, `open` 수
- `.planning/ROADMAP.md` - Phase 4 Spike first · Notes 두 불릿, Phase 5 Notes 첫 불릿

## Decisions Made

- CHANGELOG 표는 칸 맞춤 없이 쓴다 (아래 Deviations 2).
- M25 의 규칙은 `no_self_assignments` (샘플이 정답지 다섯 모두에 한 줄씩, `// @dart=3.11` 파일이 아님).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - 검증 명령의 단언 결함] Task 1 의 평가표 행 정규식이 칸 맞춤 표를 읽지 못한다**
- **Found during:** Task 1 (`<automated>`)
- **Issue:** `re.finditer(r'^\| \x60([a-z0-9_-]+)\x60 \|', tbl)` 은 이름 뒤에 공백이 하나일 때만 맞는다. `--report --write` 가 생성한 평가표는 칸을 맞춰 공백이 여럿이라 0행을 읽어 `평가표 행` 단언이 실패했다 (적힌 그대로 rc 1). 생성 절은 손으로 고치지 않으므로 표를 바꿀 수 없다.
- **Fix:** 그 정규식 하나만 `\x60 +\|` 로 바꾼 판을 돌려 rc 0 (`D1 ok`). 평가표 이름 집합 = R1 JSON 의 `rows` 133개.
- **Files modified:** 없음 (계획 파일은 고치지 않았다)
- **Committed in:** 해당 없음

**2. [Rule 1 - 구현] CHANGELOG 표를 칸 맞춤 없이 다시 씀 · 커밋 D1 을 amend**
- **Found during:** Task 1 (`<automated>`)
- **Issue:** 처음에는 VERSIONING.md 의 예시처럼 칸을 맞춘 표를 썼는데, 단언 `'| 규칙 | 강도 | 실측 | dart fix |' in tail` 과 artifacts 의 `contains` 가 이 글자 그대로를 찾아 실패했다.
- **Fix:** 칸 맞춤을 걷어 `| 규칙 | 강도 | 실측 | dart fix |` · `|---|---|---|---|` 로 다시 썼다 (값은 그대로). 아직 아무것도 올리지 않은 상태에서 커밋 D1 을 `git commit --amend --no-edit` 로 고쳤다 — 처음 커밋 `d14e708` 은 브랜치에 남지 않고 `3238ab0` 이 D1 이다. 메시지는 바꾸지 않았다.
- **Files modified:** CHANGELOG.md
- **Committed in:** `3238ab0`

**3. [기록 - 파일 형식 맞춤] `03-REVIEW-DISPOSITION.md` 의 본문 표와 `open` 수도 고침**
- **Found during:** Task 2
- **Issue:** 계획은 frontmatter 의 `disposition` · `note` 만 적었지만, 같은 파일의 본문 표(`| WR-01 | warning | open | - |`)와 `open: 14` 가 같은 사실을 따로 적는다. disposition 스크립트는 다시 돌 때 결정된 행의 Source 칸을 지키지만 `note:` 같은 추가 키를 지키는지는 알려져 있지 않다.
- **Fix:** 본문 표의 WR-01 → `fixed` / `04-01 tool/verify.dart [3/10] (example/README.md M23 · M24)`, WR-02 → `deferred` / `Phase 5 의 첫 일 — DOCS-10 전에 닫는다 (04-CONTEXT.md D-12)`, WR-03 행은 그대로, `open: 12` (`total: 14` 그대로). 다른 항목 · 제목 · 설명 줄은 건드리지 않았다.
- **Files modified:** .planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md
- **Committed in:** `2b2b475`

**4. [기록 - 계획 문구와 실제 결과] M25 에서 `[6/10]` 은 통과한다**
- **Found during:** Task 2
- **Issue:** 계획은 "`[5/10]` ~ `[10/10]` 실패 (정답지 다섯 모두)" 라고 적었지만 `[5/10]` ~ `[10/10]` 은 여섯 단계이고, `[6/10]` recommended 는 자기 정답지 없이 같은 실행의 example 결과와 견주므로 통과했다.
- **Fix:** README 의 M25 행에 "`[3/10]` 과 `[5/10]` ~ `[10/10]` 가운데 정답지 단계 다섯 (`[5/10]` · `[7/10]` ~ `[10/10]`). `[6/10]` 은 통과" 로 실제대로 적고, 읽는 법 불릿에 M18 과 같은 까닭을 적었다. Task 2 의 단언은 적힌 그대로 통과한다.
- **Files modified:** example/README.md
- **Committed in:** `2b2b475`

---

**Total deviations:** 2 auto-fixed (Rule 1 — 단언 결함 하나, 구현 하나) + 기록 2
**Impact on plan:** 산출물의 내용은 계획대로다. 계획의 Task 1 단언은 생성된 평가표에 대해 적힌 그대로는 통과하지 않는다 — 뒤 plan 이나 검증이 같은 식을 옮겨 쓰면 같은 곳에서 걸린다.

## Issues Encountered

None — 비공개 점검 (1) · (3) 은 두 커밋 전에 모두 0줄이었다. 측정은 새로 하지 않았다 (`--report` 가 종료 코드 0 이었다).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 04-10 (RULES-01 · RULES-06) 이 남았다.
- Phase 5 는 ROADMAP Notes 의 첫 불릿대로 WR-02 를 DOCS-10 전에 닫는다. CHANGELOG 의 새로 생기는 경고 표는 Phase 5 가 그대로 읽을 수 있다.

## Self-Check: PASSED

- FOUND: RULES.md, CHANGELOG.md, example/README.md, .planning/ROADMAP.md, .planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md
- FOUND (HEAD 의 조상): `3238ab0`, `2b2b475`
- 커밋 수: `git rev-list --count 3dc9d1f..HEAD` = 2

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*
