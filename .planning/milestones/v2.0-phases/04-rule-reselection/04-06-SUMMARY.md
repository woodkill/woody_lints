---
phase: 04-rule-reselection
plan: 06
subsystem: lint-config
tags: [analysis_options, lint-rules, golden-files, verify-harness]

requires:
  - phase: 04-rule-reselection
    provides: "04-05 의 소유자 결정 표 (04-DECISIONS.md `## 결정`) 와 회차 R1 실측 JSON"
provides:
  - "lib/base.yaml — 지금 켜 둔 6개의 사유 주석 수정 (D-18), 새로 켠 27개 (버그 방지 23 · import 1 · fire-and-forget 1 · strict 2)"
  - "RULES.md — 켠 규칙 표 33행의 실측 · dart fix · 회차 칸, 켜지 않은 규칙 표에 소유자 결정 · 비호환 5행"
  - "샘플 example/lib/bug_prevention_rules.dart · relative_imports_rule.dart · strict_rules.dart 와 fixture 다섯 복사본, 정답지 다섯에 27줄"
  - "CHANGELOG 2.0.0 의 `### 추가한 규칙` 27 불릿과 그 밖의 변경 불릿 하나"
affects: [04-07, 04-08, 04-09, 04-10]

actuals:
  tokens: 17000
  tasks: 3
  commits: 3

plan_head_before: f26ed5ed464bbde318af01a9d6c357ce1855aaaf
plan_head_after: 52402df0eaf55b254acdd28fa59c52e479d3333f

tech-stack:
  added: []
  patterns:
    - "자기 패키지 이름을 적어야 하는 샘플(prefer_relative_imports)은 별도 파일 하나에 두고, 그 파일만 프로젝트마다 패키지 이름이 다르다 — 나머지 샘플은 글자 그대로 복사"
    - "RULES.md 켠 규칙 표의 행은 lib/base.yaml 의 사유 주석과 R1 JSON 에서 스크립트로 만든다 (켠 이유 == 사유 주석을 글자로 보장)"

key-files:
  created:
    - example/lib/bug_prevention_rules.dart
    - example/lib/relative_imports_rule.dart
    - example/lib/strict_rules.dart
    - fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/lib/bug_prevention_rules.dart
    - fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/lib/relative_imports_rule.dart
    - fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/lib/strict_rules.dart
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
  - "지금 켜 둔 6개는 모두 남겼고 뺀 규칙이 없다 — Pitfall 3 해당 없음, fixtures/overrides 는 prefer_final_locals: false 그대로, CHANGELOG 에 ### 뺀 규칙 절 없음 (04-06)"
  - "prefer_relative_imports 의 샘플은 lib/relative_imports_rule.dart 하나에 두고 그 파일만 프로젝트마다 자기 패키지 이름을 적는다 — fixture 의 패키지 이름이 프로젝트마다 달라 한 벌을 글자 그대로 복사하면 규칙이 걸리지 않거나 uri 오류가 난다. 다른 샘플은 글자 그대로 복사 (04-06)"
  - "prefer_relative_imports 는 lib/base.yaml 의 # 가독성 및 스타일 아래, RULES.md 분류 가독성·스타일 로 두었다 — import 스타일 규칙이라서. 나머지 새 규칙은 # 버그 방지 아래 (strict 둘은 # strict 소주석 아래, 분류 버그 방지 (strict)) (04-06)"
  - "strict-inference 는 켜지 않았다 — lib/base.yaml 에 analyzer: language: 블록 없음, RULES.md 켠 analyzer 옵션은 없음 그대로, fixtures/base_codegen 의 exit 0 그대로, CHANGELOG 에 --fatal-warnings 불릿 없음 (04-06)"
  - "conditional_uri_does_not_exist 샘플은 import 가 아니라 조건부 export 로 둔다 — import 로 두면 쓰지 않는 import 라 unused_import warning 이 같은 줄에 걸려 base_codegen 의 exit 가 바뀐다 (04-06)"

patterns-established:
  - "묶음 커밋 하나 = lib/base.yaml + RULES.md + CHANGELOG + 샘플 6벌 + --update 정답지 다섯 (Pitfall 9)"
  - "샘플은 먼저 보통 실행으로 + 줄을 규칙별로 센 뒤(한 규칙 한 줄) --update 로 쓴다"

requirements-completed: [RULES-06, RULES-07, DOCS-11]

coverage:
  - id: D1
    description: "지금 켜 둔 6개의 결정과 D-18 사유 문구가 lib/base.yaml 과 RULES.md 에 반영되어 있다 (커밋 B1)"
    requirement: RULES-07
    verification:
      - kind: other
        ref: "04-06-PLAN Task 1 <automated> — added-rule 단언을 이름 집합 차로 고친 판 (Deviations 1), rc 0, SEGFAIL1 없음"
        status: pass
    human_judgment: false
  - id: D2
    description: "버그 방지 23 · prefer_relative_imports · discarded_futures 가 켜지고 정답지 다섯에 규칙마다 1줄씩 25줄이 생겼다 (커밋 B2)"
    requirement: RULES-06
    verification:
      - kind: other
        ref: "04-06-PLAN Task 2 <automated> — exit 줄 단언을 +/- 줄로 좁히고 복사본 비교를 패키지 이름 정규화로 바꾼 판 (Deviations 2 · 3), rc 0, SEGFAIL1 없음"
        status: pass
    human_judgment: false
  - id: D3
    description: "strict 계열 결정(no_dynamic_casts · no_raw_types 켬, strict-inference 안 켬)이 반영되고 정답지 다섯에 2줄이 생겼다 (커밋 B3)"
    requirement: RULES-06
    verification:
      - kind: other
        ref: "04-06-PLAN Task 3 <automated> — 복사본 비교를 패키지 이름 정규화로 바꾼 판 (Deviations 3), rc 0, SEGFAIL1 없음; [3/10] 통과"
        status: pass
    human_judgment: false
  - id: D4
    description: "RULES.md 켠 규칙 표 33행에 분류 · 켠 이유 · 실측 · dart fix · 회차가 채워져 있다"
    requirement: DOCS-11
    verification:
      - kind: other
        ref: "fvm dart run tool/verify.dart — [3/10] 통과, 점검 통과 (10개 중 10개); Task 1 ~ 3 의 python 단언 (켠 이유 == 사유 주석, 실측 == R1 counts)"
        status: pass
    human_judgment: false
  - id: D5
    description: "샘플 파일의 사유 문장과 RULES.md 켠 이유 문장이 읽기에 맞는지 (문구 품질)"
    verification: []
    human_judgment: true
    rationale: "글자 일치는 자동으로 확인했지만, 사유 문장이 규칙의 뜻을 바르게 설명하는지는 사람이 읽어야 한다"

duration: 16min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 06: 반영 A — 지금 켜 둔 6개 · 버그 방지 · import · fire-and-forget · strict Summary

**`lib/base.yaml` 에 소유자 결정 27개를 켜고(버그 방지 23 · `prefer_relative_imports` · `discarded_futures` · `no_dynamic_casts` · `no_raw_types`) 지금 켜 둔 6개의 사유 주석을 D-18 대로 고쳤으며, 규칙마다 위반 샘플 한 줄이 정답지 다섯에 들어가 `RULES.md` 33행과 함께 세 묶음 커밋으로 반영했다 — `strict-inference` 는 안 켬, 뺀 규칙 0.**

## Performance

- **Duration:** 16 min
- **Started:** 2026-10-13T02:32:47Z
- **Completed:** 2026-10-13T02:49:09Z
- **Tasks:** 3
- **Files modified:** 8 수정 + 18 생성 (샘플 3종 × 6벌)

## Accomplishments

- Precondition 확인: 결정 표 133행, 빈 `결정` 칸 0 — 켬 80 · 안 켬 35 · 결정 안 함 (표식 …) 5 · v2 12 · 보류 1. orchestrator 의 사전 집계와 같다.
- B1: 6개 모두 남김. const 규칙 둘의 "성능 향상" 문구와 `always_declare_return_types` 의 범위를 승인된 D-18 문구로 고쳤다. `prefer_final_locals` · `prefer_single_quotes` · `unawaited_futures` 는 지금 문장 그대로.
- B2: 새 규칙 25개, 정답지 다섯 각각 `+` 25줄 · `-` 0줄 (머리 주석의 날짜 한 줄 제외), `exit` 변화 없음.
- B3: 새 lint 2개, 정답지 다섯 각각 `+` 2줄 · `-` 0줄, `exit` 변화 없음 (`base_codegen` 은 `exit 0` 그대로).
- `RULES.md` 켠 규칙 표 33행 = `lib/base.yaml` 33개, 켠 이유 == 사유 주석 (글자 그대로), `(실측 전` 0.

## Task Commits

1. **Task 1: 지금 켜 둔 6개 묶음 (B1)** - `9cff42e` (chore)
2. **Task 2: 버그 방지 + import + fire-and-forget (B2)** - `354959c` (feat)
3. **Task 3: strict 계열 (B3)** - `52402df` (feat)

**Plan metadata:** SUMMARY 커밋과 STATE · ROADMAP 커밋은 이 파일 뒤에 따로 한다.

## 묶음별 결정 반영

| 묶음 | 켬 (새로) | 안 켬 | 뺀 규칙 |
|---|---|---|---|
| 지금 켜 둔 6개 (`current` + `unawaited_futures`) | 0 (6개 모두 남김) | 0 | 0 |
| 버그 방지 (`bug`) | 23 — `async_return_with_no_await`, `avoid_catching_errors`, `avoid_double_and_int_checks`, `avoid_dynamic_calls`, `avoid_js_rounded_ints`, `avoid_type_to_string`, `avoid_unused_constructor_parameters`, `avoid_void_async`, `cancel_subscriptions`, `cast_nullable_to_non_nullable`, `conditional_uri_does_not_exist`, `deprecated_member_use_from_same_package`, `literal_only_boolean_expressions`, `matching_super_parameters`, `missing_whitespace_between_adjacent_strings`, `no_adjacent_strings_in_list`, `no_self_assignments`, `only_throw_errors`, `parameter_assignments`, `switch_on_type`, `test_types_in_equals`, `throw_in_finally`, `unnecessary_statements` | 2 — `avoid_equals_and_hash_code_on_mutable_classes`, `avoid_implementing_value_types` | 0 |
| import (`import`) | 1 — `prefer_relative_imports` | 1 — `always_use_package_imports` (`비호환` 접두사) | 0 |
| fire-and-forget (`fire`) | 1 — `discarded_futures` (`unawaited_futures` 는 남김) | 1 — `unnecessary_unawaited` | 0 |
| strict (`strict`) | 2 — `no_dynamic_casts`, `no_raw_types` | 1 — `strict-inference` | 0 |
| **합계** | **27** | **5** | **0** |

orchestrator 의 사전 읽기(B1 · B2 · B3)와 결정 표 읽기가 같다 — 다른 점 없음.

## 정답지의 바뀐 줄 (정답지 다섯 각각)

| 커밋 | `+lib/` 줄 | `-lib/` 줄 | `exit` 줄 | 샘플 수 | 기존 샘플에 걸린 줄 (Pitfall 5) |
|---|---|---|---|---|---|
| B1 `9cff42e` | 0 | 0 | 변화 없음 | 0 (샘플 변화 없음, 정답지 파일 자체가 바뀌지 않음) | — |
| B2 `354959c` | 25 | 0 | 변화 없음 | 25 (`bug_prevention_rules.dart` 24 + `relative_imports_rule.dart` 1) | 0 |
| B3 `52402df` | 2 | 0 | 변화 없음 | 2 (`strict_rules.dart`) | 0 |

- B2 의 정답지 diff 는 파일마다 `+26 / -1` 이다 — `+lib/` 25줄과 머리 주석 `# 실측:` 의 날짜(2026-10-12 → 2026-10-13) 한 줄.
- B3 는 같은 날이라 머리 주석이 그대로이고 `+2 / -0` 이다.
- `fixtures/recommended` 는 정답지가 없고 같은 실행의 `example` 과 견주어 통과했다.
- `strict-inference` 를 켜지 않았으므로 `inference_failure_on_*` 줄은 없고 `fixtures/base_codegen` 의 첫 줄은 `exit 0` 그대로다.

## 각 task 의 `<automated>` 결과 (HEAD 가 그 task 의 커밋일 때 돌림)

| Task | 쓰인 그대로 | 쓰인 그대로 + SEGFAIL1 | 고친 판 | 고친 판 + SEGFAIL1 |
|---|---|---|---|---|
| 1 (B1) | rc 1 — added-rule 단언 실패 | rc 0 이지만 `SEGFAIL1` 찍힘 (첫 체인 실패) | rc 0 | rc 0, `SEGFAIL1` 없음 |
| 2 (B2) | rc 1 — `exit 줄이 바뀜` 단언 실패 | rc 0 이지만 `SEGFAIL1` 찍힘 | rc 0 | rc 0, `SEGFAIL1` 없음 |
| 3 (B3) | rc 1 — 복사본 `diff -rq` 에서 `exit 1` | rc 1 (같은 `exit 1`, `SEGFAIL1` 앞에서 끝남) | rc 0 | rc 0, `SEGFAIL1` 없음 |

고친 판은 아래 Deviations 1 ~ 3 의 세 곳만 바꿨다. 나머지 단언(결정 표와의 일치, 정답지 `+` 줄 집합 == 더한 규칙, 켠 이유 == 사유 주석, 실측 == R1 `counts`, 커밋 제목, 커밋되지 않은 변경 없음, 루트 분석, `점검 통과 (10개 중 10개)`, `[3/10]` 통과, `--update` 의 `바뀐 정답지가 없다`)은 쓰인 그대로 돌았다.

## Pitfall 3 · `strict-inference` · `base_codegen`

- **Pitfall 3:** 해당 없음 — `prefer_final_locals` 를 남겼다. `fixtures/overrides/analysis_options.yaml` 의 `prefer_final_locals: false`, `tool/verify.dart` 의 `optionsLines`, `example/README.md` 는 그대로다.
- **`strict-inference`:** 채택하지 않음 (소유자 결정 질문 3). `analyzer: language:` 블록 없음, `RULES.md` 켠 analyzer 옵션 구역은 `없음 — …` 그대로, 켜지 않은 규칙 표에 `소유자 결정 — …` 행. CHANGELOG `### 올리기 전에` 에 warning 불릿 없음.
- **`base_codegen` 의 `exit`:** `exit 0` 그대로 (세 커밋 모두 변화 없음).

## Files Created/Modified

- `lib/base.yaml` — 사유 주석 3줄 수정, 규칙 27개 추가 (`# strict` 소주석 한 줄 포함)
- `RULES.md` — 켠 규칙 표 33행 채움, 켜지 않은 규칙 표 5행 추가
- `CHANGELOG.md` — `### 추가한 규칙` 27 불릿, `### 그 밖의 변경` 불릿 하나 (사유 주석 수정)
- `example/lib/bug_prevention_rules.dart` + 복사본 다섯 — 버그 방지 23 · `discarded_futures` 샘플 (글자 그대로 복사)
- `example/lib/relative_imports_rule.dart` + 다섯 — `prefer_relative_imports` 샘플 (프로젝트마다 자기 패키지 이름)
- `example/lib/strict_rules.dart` + 복사본 다섯 — strict lint 2개 샘플
- 정답지 다섯 — `--update` 로만 썼다

## Decisions Made

- `prefer_relative_imports` 의 자리와 분류: `# 가독성 및 스타일` · `가독성·스타일`. 계획 문장은 새 규칙을 `# 버그 방지` 아래에 두라고 했지만 import 스타일은 버그 방지가 아니다. 검증 단언은 자리를 보지 않는다.
- `RULES.md` 의 0줄 실측 칸은 `0 · 0 · 0 (표식 검출)` 로 적었다 (R1 JSON 의 `markerDetected`). `dart fix` 칸은 `fixRemoved` 가 null 이면 `해당 없음`, 0 이고 단독 dry 0 이면 `0 (dry 0)`. `회차` 는 `runs` 의 id 에 `R1-` 를 붙였다.
- `matching_super_parameters` 샘플은 super 매개변수 하나만 이름이 다르게 두었다 — 둘 다 다르면 같은 줄에 같은 규칙이 두 번 걸려 `+` 줄이 26이 된다 (보통 실행에서 확인 뒤 고침).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Task 1 의 "이 커밋은 규칙을 더하지 않는다" 단언이 사유 주석 수정을 규칙 추가로 읽는다**
- **Found during:** Task 1 검증
- **Issue:** 단언이 `lib/base.yaml` diff 의 `+    - 규칙` 줄을 모두 "더한 규칙" 으로 센다. D-18 의 사유 주석은 규칙과 같은 줄에 있어 문구를 고치면 그 줄이 `-` / `+` 로 함께 나온다 — 계획이 요구한 변경으로는 이 단언을 넘을 수 없다.
- **Fix:** 고친 판은 `+` 줄 이름 집합에서 `-` 줄 이름 집합을 뺀 것이 비었는지 본다 (규칙을 더하지 않았다는 원래 뜻). 저장소 파일은 바꾸지 않았다.
- **Verification:** 고친 판 rc 0, SEGFAIL1 없음. 더한 이름 0.
- **Committed in:** 해당 없음 (검증 명령만 고침)

**2. [Rule 1 - Bug] Task 2 의 `exit` 줄 단언이 diff 의 문맥 줄을 센다**
- **Found during:** Task 2 검증
- **Issue:** `l[1:].startswith('exit ')` 가 `+` / `-` 줄만이 아니라 문맥 줄(` exit 2`)도 잡는다. B2 는 정답지 머리 주석의 날짜가 바뀌어 hunk 가 맨 위에 생기고, 3행의 `exit 2` 가 문맥 줄로 들어간다.
- **Fix:** 고친 판은 첫 글자가 `+` 또는 `-` 인 줄만 본다. Task 3 의 같은 식에도 같은 수정을 했다 (B3 는 날짜가 같아 쓰인 그대로도 python 단언은 통과했다).
- **Verification:** 고친 판 rc 0. 정답지 다섯의 `+` / `-` 줄에 `exit` 없음.
- **Committed in:** 해당 없음

**3. [Rule 3 - Blocking] `prefer_relative_imports` 샘플은 복사본 다섯을 글자 그대로 둘 수 없다**
- **Found during:** Task 2
- **Issue:** 이 규칙은 자기 패키지를 `package:` 주소로 import 할 때만 걸린다. 연습용 프로젝트 여섯은 패키지 이름이 모두 다르다 (`woody_lints_example`, `woody_lints_fixture_<이름>`). 계획대로 `package:woody_lints_example/…` 한 벌을 복사하면 fixture 다섯에서는 uri 오류가 나고 규칙이 걸리지 않는다. 샘플을 example 에만 두면 `recommended` 가 example 과 달라져 `[6/10]` 이 실패한다.
- **Fix:** 샘플을 `lib/relative_imports_rule.dart` 한 파일에 따로 두고, 그 파일만 프로젝트마다 import 줄의 패키지 이름이 다르다 (같은 줄 번호, 같은 진단). 다른 샘플 파일은 글자 그대로 복사했다. `bug_prevention_rules.dart` 머리 주석에 이 사실과 규칙 이름을 적었다 (Task 2 의 "샘플 doc 줄" 단언이 이 파일을 본다).
- **Verification:** 보통 실행에서 정답지 다섯 모두 `lib/relative_imports_rule.dart:3  info  prefer_relative_imports` 1줄. 고친 판의 복사본 비교는 `relative_imports_rule.dart` 를 뺀 `diff -rq` 와, 그 파일의 패키지 이름을 `woody_lints_example` 로 바꾼 뒤 example 과 같은지 본다 — 다섯 모두 같다. Task 2 · 3 의 쓰인 그대로의 `diff -rq` 는 이 파일 때문에 실패한다.
- **Files modified:** `example/lib/relative_imports_rule.dart`, `fixtures/*/lib/relative_imports_rule.dart`
- **Committed in:** `354959c`

**4. [기록] `lib/base.yaml` 의 빈 줄 두 개에 있던 뒤쪽 공백이 지워졌다**
- 편집 도구가 줄 끝 공백을 지웠다 — B1 에서 `# 성능` 묶음 뒤, B2 에서 `# 가독성 및 스타일` 묶음 뒤의 빈 줄. 규칙 · 주석 내용에는 변화가 없고 B2 의 `-` 줄 하나가 이것이다 (Task 2 의 "뺀 규칙" 단언은 규칙 줄만 보므로 통과).

---

**Total deviations:** 3 auto-fixed (Rule 1 둘 — 검증 명령의 단언, Rule 3 하나 — 샘플 구성) + 기록 1
**Impact on plan:** 결정 반영과 1:1 대응은 계획대로다. 계획의 검증 명령은 세 곳이 쓰인 그대로 통과하지 않는다 — 04-09 의 확인 기록이나 뒤 plan 이 같은 식을 옮겨 쓰면 같은 곳에서 걸린다 (특히 복사본 `diff -rq`, 04-07 의 샘플 묶음에도 해당).

## Issues Encountered

- 계획이 예시로 든 `conditional_uri_does_not_exist` 표식(조건부 import)은 쓰지 않는 import 라 `unused_import` warning 이 같은 줄에 붙는다 — warning 은 `base_codegen` 의 `exit 0` 을 바꾼다. 조건부 **export** 로 바꿔 그 규칙 하나만 걸리게 했다.
- `switch_on_type` 샘플의 `case` 는 `case const (int):` 로 적었다 — `case int:` 는 기반 세트의 다른 규칙이 같은 자리에서 볼 수 있어 피했다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 04-07 (성능 · 가독성·스타일 · 제외 권장 · 켜지 않은 규칙 표의 나머지)이 이어서 할 수 있다. 04-07 이 켜는 스타일 규칙(예: `directives_ordering`, `omit_obvious_local_variable_types`)은 이 plan 의 샘플 파일에도 걸릴 수 있다 — Pitfall 5 대로 같은 규칙의 줄이면 받아들인다.
- 04-07 의 샘플도 `diff -rq example/lib fixtures/*/lib` 를 쓰면 `relative_imports_rule.dart` 에서 걸린다 — 그 파일을 빼거나 패키지 이름을 맞춰 견줘야 한다.

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*

## Self-Check: PASSED

- 생성 파일 18개 모두 있음, 커밋 `9cff42e` · `354959c` · `52402df` · `25d5dd2` 모두 HEAD 의 조상, `example/lib/added_rules.dart` 는 `74fafb2` 와 같음.
