---
phase: 04-rule-reselection
plan: 04
subsystem: testing
tags: [dart-analyze, dart-fix, measurement, rule-selection, flutter_starter_kit]

requires:
  - phase: 04-rule-reselection
    provides: "04-01 — RULES.md 뼈대와 검증 명령 [3/10]"
  - phase: 04-rule-reselection
    provides: "04-02 · 04-03 — tool/measure_rules.dart (단계 일곱, 결과 JSON schema 1, 표식 80 · 표식 불가 4, --summary · --report · --audit)"
provides:
  - "tool/measurements/2026-10-13-R1.json — 회차 R1, 후보 133행의 건수 · 조건만 담은 기록 (schema 1)"
  - "fix 단계가 analyzer 옵션 strict-inference 도 그 진단 코드(inference_failure_on_*)로 잰다"
  - "CHANGELOG 2.0.0 그 밖의 변경에 실측 도구 불릿"
affects: [04-05, 04-06, 04-07, 04-08, 04-09, 04-10]

actuals:
  tokens: 284359
  tasks: 3
  commits: 1
plan_head_before: 91f987b4bdc4a32987574edfbeed4ccc1717258a
plan_head_after: e3651ec5e05c0875bc5ec5bca692a13569a7e0d4

tech-stack:
  added: []
  patterns:
    - "실측은 두 번의 백그라운드 실행(state · baseline · groups · markers · ignore / fix)으로 나누고, 실행 중에는 저장소에서 아무것도 하지 않는다"
    - "analyzer 옵션의 dart fix 칸은 그 회차에 나온 진단 코드를 모두 --code= 로 준 단독 dry · apply 로 잰다"

key-files:
  created:
    - tool/measurements/2026-10-13-R1.json
  modified:
    - tool/measure_rules.dart
    - CHANGELOG.md

key-decisions:
  - "회차 R1 (2026-10-13, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9) 의 회차 50개가 모두 유효하고, 이 JSON 이 평가표의 단일 출처다 (D-14)"
  - "strict-inference 의 dart fix 칸은 inference_failure_on_* 코드로 잰 값이다 — test 106줄, 단독 dry 0, 사라진 줄 0, 새 error 0. 04-03 이 옵션 행을 건너뛰게 한 것을 이 plan 의 검증에 맞춰 바꿨다"
  - "결정 대상 121행 가운데 0줄이 67행이고, 그중 결정 안 함이 될 규칙은 5개다 — 표식 불가 4 (noFileProbe), 표식 미검출 1 (remove_deprecations_in_breaking_versions — 사용 프로젝트의 version 이 x.0.0 이 아니라 규칙이 돌지 않는다)"

patterns-established:
  - "검증 명령의 grep 이 PLAN · RESEARCH 문서에 적힌 자기 패턴에 걸리면 그 문서를 뺀 범위로 다시 돌리고 SUMMARY 에 둘 다 적는다"

requirements-completed: [RULES-03, RULES-04, RULES-05]

coverage:
  - id: D1
    description: "회차 R1 결과 JSON — 행 133, 회차 50개 모두 valid, 회차마다 조건 여덟 칸, 결정 대상 121행의 값 · 0줄의 markerDetected, G4 7개의 counts313, strict 셋의 값, --report 단언 통과"
    requirement: "RULES-03"
    verification:
      - kind: integration
        ref: "04-04-PLAN.md Task 2 <automated> (python 단언 R1 ok, --report rc 0, 원본 git status 0줄 그대로, 루트 분석 깨끗) — TASK2_RC=0"
        status: pass
    human_judgment: false
  - id: D2
    description: "no_dynamic_casts · no_raw_types · strict-inference 의 행이 값과 함께 있고 strict-inference 는 warning"
    requirement: "RULES-04"
    verification:
      - kind: integration
        ref: "04-04-PLAN.md Task 2 <automated> python 단언"
        status: pass
    human_judgment: false
  - id: D3
    description: "회차 조건(Dart · Flutter · 기반 세트 둘 · plugin · 언어 버전 · SDK 제약 · Dart 파일 수 · 날짜)과 valid, 0줄 후보의 markerDetected"
    requirement: "RULES-05"
    verification:
      - kind: integration
        ref: "04-04-PLAN.md Task 2 <automated> python 단언 · --report 단언 (5) (6)"
        status: pass
    human_judgment: false
  - id: D4
    description: "비공개 정보 점검 (1) ~ (4) 와 커밋 · CHANGELOG · 검증 명령 10개 중 10개"
    requirement: "RULES-03"
    verification:
      - kind: integration
        ref: "04-04-PLAN.md Task 3 <automated> — (3) 의 fixes-made-in grep 만 PLAN · RESEARCH 의 자기 패턴 줄을 뺀 범위로 (아래 Deviations 2). TASK3_RC=0"
        status: pass
    human_judgment: true
    rationale: "점검 (3) 의 grep 을 계획 그대로 돌리면 PLAN · RESEARCH 에 적힌 패턴 자체에 10줄 걸린다 — 그 10줄이 사용 프로젝트의 화면이 아니라는 판단은 사람이 확인한다"

duration: 40min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 04: 회차 R1 실측 Summary

**`flutter_starter_kit` 복사본(Dart 파일 412개 + 생성 파일 62개)에서 후보 133개를 한 번에 재어, 회차 50개가 모두 유효한 R1 결과 JSON(건수 · 조건만)을 `tool/measurements/2026-10-13-R1.json` 으로 커밋했다 — 표식 보충 0, 결정 안 함이 될 규칙 5개, `strict-inference` 의 dart fix 칸까지 채움**

## Performance

- **Duration:** 약 40분
- **Started:** 2026-10-13T01:03:17Z
- **Completed:** 2026-10-13T01:43:57Z
- **Tasks:** 3 (Task 1 은 실행 전에 답을 받음)
- **Files modified:** 3

## Accomplishments

- **회차 R1 · valid:** 회차 50개 — `B0` · `B0-313` · `G1` ~ `G4` · `G1-marker` · `G2-marker` · `G4-marker` · `B0-strip` · `G1-strip` ~ `G4-strip` (14개)와 `apply-*` 36개 — 모두 `valid: true`. `G3-marker` 는 없다 (G3 에 표식이 필요한 0줄 후보가 없었다).
- **걸린 시간:** 첫 실행(state · baseline · groups · markers · ignore) 331초, 둘째 실행(fix) 1,841초, strict-inference 의 fix 재실행 10초. 분석 한 번은 21.9 ~ 31.6초.
- **`conditions`:** 날짜 2026-10-13, Dart 3.13.4, Flutter 3.47.5, plugin `riverpod_lint` 3.1.9, 기반 세트 저장소 · 복사본 모두 `lints-6.1.0` / `flutter_lints-6.0.0`, 복사본 언어 버전 3.11 · SDK 제약 `^3.11.1`, Dart 파일 `lib` 172 · `test` 239 · `bin` 1 (생성 파일 62 따로), `stateSource` = `messages.yaml@3.13.4` (상류 파일을 받았다 — fallback 아님).
- **state 단계:** 후보 133개, 상태 stable 129 · experimental 1 · testing 2 (나머지 1행은 analyzer 옵션), 비호환 쌍 10/10 확인.
- **기준선:** B0 프로젝트 0줄 · 표식 16줄, B0-313 프로젝트 27줄 · 표식 16줄 (spike 021 의 `prefer_initializing_formals` 27줄과 같은 수).
- **표식:** 첫 실행에 `표식 없음` 줄이 없었다 — 보충한 표식 0개, `noFileProbe` 에 더한 것 0개. 표식 불가 4개(`sort_pub_dependencies`, `use_test_throws_matchers`, `require_trailing_commas`, `package_prefixed_library_names`)는 04-03 의 이유 그대로.
- **결정 대상 121행:** 줄이 있는 행 54, 0줄 67 — 0줄 가운데 표식 검출 62, 표식 미검출 1 (`remove_deprecations_in_breaking_versions` — 04-03 이 예고한 대로 사용 프로젝트의 `version` 이 x.0.0 / 0.x.0 이 아니라 규칙이 돌지 않는다), 표식 불가 4. **`결정 안 함` 이 될 규칙 5개.** 뒤로 미룬 12행(RULES-09 · 10 · 11)은 결정 대상이 아니다.
- **언어 버전 3.13 전용 7개:** 지금 하한 값은 모두 0, `counts313` 은 `use_primary_constructors` 785 · `empty_container_bodies` 432 · `unnecessary_type_name_in_constructor` 281 · `unnecessary_const_in_enum_constructor` 2 · 나머지 셋 0.
- **strict 셋:** `no_dynamic_casts` 0줄 · `no_raw_types` 0줄 (둘 다 info, 표식 검출), `strict-inference` warning · `test` 106줄 · dart fix 사라진 줄 0 (단독 dry 0).
- **무시 주석이 가린 줄이 있는 행 16개**, dart fix apply 뒤 새 error 가 생긴 규칙 6개 (`diagnostic_describe_all_properties` 148, `migrate_design_widgets` 12, `unnecessary_unawaited` 9, `always_specify_types` 6, `omit_local_variable_types` 4, `specify_nonobvious_local_variable_types` 4).
- 원본의 `git status --porcelain` 은 실측 전후 모두 0줄. 도구가 단계마다 견준 저장소 지문은 세 실행 모두 바뀌지 않았다 (종료 코드 0).

## Task Commits

1. **Task 1: 원본 경로와 작업 폴더** — 소유자가 orchestrator 를 통해 두 경로를 줌 (AskUserQuestion, 권고안 둘 다 선택). 커밋 없음.
2. **Task 2: 회차 R1 실측** — 커밋 없음 (계획대로 Task 3 에서 함께).
3. **Task 3: 비공개 점검 뒤 JSON · 도구 · CHANGELOG 커밋** — `e3651ec` (feat)

**Plan metadata:** SUMMARY 커밋과 마무리 커밋 (docs)

## 검증 명령 결과

- Task 2 `<automated>`: 첫 시도 rc 1 — python 단언의 `('strict-inference', '값 없음')` (아래 Deviations 1). 도구를 고치고 strict-inference 만 fix 단계를 다시 돌린 뒤 rc 0 (`R1 ok`, `--report` rc 0, 원본 `git status` 0줄 그대로, 저장소 변경은 JSON · 도구 · `.planning/` 뿐, 루트 분석 `No issues found!`).
- Task 3 `<automated>`: 점검 (3) 의 `fixes? made in` grep 을 계획 그대로 돌리면 10줄 — 전부 이 phase 의 PLAN 여섯 · RESEARCH 의 줄이고 그 패턴 자체이거나 출력 모양의 설명이다. PLAN · RESEARCH 를 뺀 범위는 0줄. 그 한 칸만 바꿔 돌린 나머지 전부 통과 — (1) 0줄, (2) `LEAK?` 없음, (3) `"message"` 0, (4) 0건, CHANGELOG 불릿 · `###` 절 3 · 자리 표시 그대로, HEAD 제목과 `R1.json`, 커밋되지 않은 변경 없음, 루트 분석 깨끗, 검증 명령 `점검 통과 (10개 중 10개)` (TASK3_RC=0).
- 커밋 전 `fvm dart format --output=none --set-exit-if-changed tool` 0.

## Files Created/Modified

- `tool/measurements/2026-10-13-R1.json` — 회차 R1 의 결과 (schema 1, 행 133, 회차 50). 도구가 마지막 지문 비교 뒤 작업 폴더의 `results/R1.json` 을 저장소로 옮긴 것과 바이트까지 같다.
- `tool/measure_rules.dart` — fix 단계가 analyzer 옵션 행도 잰다 (`ruleCodesIn`, `FixRun.countForRule`, `dryRun` 이 코드 목록을 받음, `--report` 의 옵션 예외 제거, 표의 dart fix 칸이 옵션 행도 값으로).
- `CHANGELOG.md` — `### 그 밖의 변경` 끝에 실측 도구 불릿 하나.

## Decisions Made

- strict-inference 의 dart fix 칸을 "해당 없음" 으로 두지 않고 잰 값으로 채웠다 — 계획의 python 단언이 줄이 있는 결정 대상 행 모두에 `fixRemoved` · `newErrors` 를 요구하고, 그 규칙에 걸리는 코드(`inference_failure_on_function_invocation` 106줄)는 `dart fix --code=` 가 받는 진단 코드다. 결과는 고칠 것 없음(단독 dry 0)이라 사라진 줄 0 · 새 error 0 이다.
- 그 밖은 계획대로 — 작업 폴더는 저장소 밖 `<work>`, 원본은 `<consumer-source>` 이고 어느 파일에도 적지 않았다.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] fix 단계가 analyzer 옵션 행을 건너뛰어 Task 2 의 단언이 실패**
- **Found during:** Task 2 (4. 판정)
- **Issue:** 04-03 이 `measureFix` 에서 `strict-inference` 를 건너뛰고 `--report` 단언 (2) 에서 옵션 행을 예외로 두었다. 계획의 python 단언은 예외를 두지 않아 `('strict-inference', '값 없음')` 으로 실패했다 (`--report` 는 rc 0).
- **Fix:** `measureFix` 가 옵션 행도 돌고, 진단 코드는 before 회차(G1)에서 그 후보에 드는 코드를 모아 `--code=` 로 모두 준다. 코드가 하나도 없으면 `--code=` 없는 dart fix 가 모든 진단을 고치므로 `StateError` 로 막는다. `newErrors` · `otherDelta` 의 자기 제외를 `codeMatchesRule` 로, `--report` 의 옵션 예외와 dart fix 칸의 옵션 분기를 걷었다. `--stage fix --rules strict-inference --run-id R1` 로 그 행만 다시 쟀다 (10초, 회차 추가 없음 — 단독 dry 0 이라 apply 하지 않았다).
- **Files modified:** `tool/measure_rules.dart`
- **Verification:** Task 2 `<automated>` rc 0, 루트 분석 깨끗, format 0
- **Committed in:** `e3651ec`

**2. [Rule 3 - Blocking] 점검 (3) 의 grep 이 계획 문서의 자기 패턴에 걸림**
- **Found during:** Task 3 (1. 비공개 점검)
- **Issue:** 점검 (3) 의 dart fix 화면 문구 grep (대상에 `.planning/phases/04-rule-reselection` 이 든다) 이 04-02 · 04-04 · 04-09 · 04-10 PLAN 과 04-RESEARCH 의 10줄에 걸린다 — 8줄은 이 점검 명령 자체, 2줄은 dart fix 출력 모양의 설명(04-02 의 것은 이 저장소 `example/` 의 apply 결과)이다. 사용 프로젝트의 화면이 아니다.
- **Fix:** 그 10줄이 든 PLAN · RESEARCH 는 고치지 않고(다른 plan 의 문서), PLAN · RESEARCH 를 뺀 범위로 같은 grep 을 돌려 0줄을 확인했다. 결과 JSON · `RULES.md` · SUMMARY 에는 0줄이다.
- **Files modified:** 없음
- **Verification:** 계획 그대로 10줄 / PLAN · RESEARCH 를 뺀 범위 0줄을 둘 다 기록 (coverage D4 는 사람 확인)

---

**Total deviations:** 2 (Rule 1 하나, Rule 3 하나)
**Impact on plan:** 1 은 평가표의 한 행을 채우는 변경이고 다른 132행의 값은 바뀌지 않았다. 2 는 검증 명령의 범위 문제이고 커밋 내용과 무관하다. 04-09 · 04-10 의 같은 점검도 같은 10줄에 걸릴 것이다.

## Issues Encountered

- 네트워크 오류로 무효가 된 회차는 없었다 — 다시 돌린 단계는 Deviations 1 의 strict-inference fix 하나뿐이다.
- apply 가 예외로 끝난 규칙은 없었다.

## User Setup Required

None - 작업 폴더 `<work>` 는 지우지 않고 남겼다 (04-08 이 `<work>/pristine/` 을 다시 쓴다).

## Next Phase Readiness

- 04-05 는 `--summary <묶음> --in tool/measurements/2026-10-13-R1.json` 으로 소유자 검토 화면을 찍는다. `결정 안 함` 5개는 표식 불가 4 · 표식 미검출 1 이다.
- `unnecessary_ignore` 의 재측정(`--stage unnecessary-ignore`)은 결정을 반영한 뒤 따로 돈다 (D-17) — R1 에는 없다.
- 04-09 · 04-10 의 비공개 점검 (3) 은 PLAN · RESEARCH 의 자기 패턴 10줄에 걸린다 (Deviations 2).

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*

## Self-Check: PASSED

- `tool/measurements/2026-10-13-R1.json` 있음, 커밋 `e3651ec` 가 HEAD 의 조상
- `tool` · `CHANGELOG.md` · `lib` · `example` · `fixtures` · `RULES.md` 가 HEAD 와 같다
- 이 SUMMARY 를 쓴 뒤 비공개 점검 (1) 0줄, (2) `LEAK?` 없음, (4) 0건, (3) 의 화면 문구 0줄
