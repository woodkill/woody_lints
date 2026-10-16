---
phase: 04-rule-reselection
plan: 08
subsystem: lint-config
tags: [analysis_options, lint-rules, measurement, unnecessary_ignore, rules-md]

requires:
  - phase: 04-rule-reselection
    provides: "04-07 의 반영 B (켠 규칙 80) 가 들어간 lib/base.yaml, RULES.md 의 unnecessary_ignore 보류 행, 회차 R1 JSON (B0 · G1 · G4 …)"
provides:
  - "R1 JSON 에 회차 UI-base · UI (둘 다 유효), rows.unnecessary_ignore.countsUI = 1 · 34 · 1, conditions.unnecessaryIgnoreNames (코드 이름 7종, 합계 36)"
  - "04-DECISIONS.md `## 질문 9 (재측정)` 패널과 결정 표의 unnecessary_ignore 행 (안 켬)"
  - "RULES.md 켜지 않은 규칙 표의 unnecessary_ignore 소유자 결정 행 — --audit 보류 0"
  - "tool/measure_rules.dart addExampleMarkers 가 샘플의 자기 패키지 주소를 복사본 표식 폴더 주소로 바꿔 쓴다"
affects: [04-09, 04-10]

actuals:
  tokens: 12577
  tasks: 3
  commits: 4

plan_head_before: 41ce11203ab319da4779baa51d4022b6e797d257
plan_head_after: 479ad216781c826bba43620aa3b972aca41454c2

tech-stack:
  added: []
  patterns:
    - "표식으로 옮기는 example 샘플이 `package:woody_lints_example/` 를 부르면 `package:<복사본 패키지>/woody_probe_marker/` 로 바꿔 쓴다 — 저장소 파일은 읽기만"

key-files:
  created: []
  modified:
    - tool/measure_rules.dart
    - tool/measurements/2026-10-13-R1.json
    - .planning/phases/04-rule-reselection/04-DECISIONS.md
    - RULES.md

key-decisions:
  - "unnecessary_ignore 는 안 켬 — 소유자가 질문 9 (재측정) 패널의 권고대로 골랐고 사유를 덧붙이지 않았다; 사유 칸은 패널의 권고 이유(messages.yaml experimental · 선례는 기반 세트가 켠 것 · 36줄 중 30줄은 켜지 않은 lines_longer_than_80_chars 의 주석)를 승인한 것 (04-08)"
  - "재측정 값은 UI 36줄 (lib 1 · test 34 · bin 1) — G1 의 12줄과 다른 것은 G1 에서 켜져 있던 lines_longer_than_80_chars 를 소유자가 안 켬으로 정했기 때문이다 (04-08)"

patterns-established:
  - "켜지 않은 규칙 표의 재측정 행은 `소유자 결정 — <사유> (상태: … ; 재측정 UI N줄)`"

requirements-completed: [RULES-06, RULES-08, DOCS-11]

coverage:
  - id: D1
    description: "결정을 반영한 저장소에서 unnecessary_ignore 를 다시 재 회차 UI-base · UI 가 R1 JSON 에 유효하게 합쳐졌다 (countsUI · unnecessaryIgnoreNames)"
    requirement: RULES-06
    verification:
      - kind: other
        ref: "04-08-PLAN Task 2 <automated> 적힌 그대로, HEAD = 9a5176b, rc 0 (+SEGFAIL1 판 rc 0, SEGFAIL1 안 찍힘)"
        status: pass
    human_judgment: false
  - id: D2
    description: "소유자의 답(안 켬)이 RULES.md 와 04-DECISIONS.md 결정 표에 반영되고 --audit 보류가 0 이다"
    requirement: RULES-08
    verification:
      - kind: other
        ref: "fvm dart run tool/measure_rules.dart --audit — rc 0, 감사 통과 — 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0; grep -c '| 보류' RULES.md = 0"
        status: pass
    human_judgment: false
  - id: D3
    description: "검증 명령이 RULES.md 와 배포 파일의 일치를 포함해 모두 통과한다"
    requirement: DOCS-11
    verification:
      - kind: other
        ref: "fvm dart run tool/verify.dart — rc 0, 점검 통과 (10개 중 10개) (HEAD = 479ad21 의 작업 트리)"
        status: pass
    human_judgment: false

duration: 17min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 08: unnecessary_ignore 재측정과 결정 Summary

**결정(켠 규칙 80)이 반영된 저장소를 복사본이 받은 채 `unnecessary_ignore` 를 다시 재(회차 `UI` 36줄 = lib 1 · test 34 · bin 1, G1 은 12), 질문 9 (재측정) 패널로 물어 소유자가 `안 켬` 을 골랐고, `RULES.md` 의 마지막 보류 행이 소유자 결정 행이 되어 `--audit` 이 보류 0 으로 통과한다.**

## Performance

- **Duration:** 약 17분 (소유자 응답 대기 포함)
- **Started:** 2026-10-13T04:29:13Z
- **Completed:** 2026-10-13T04:46Z
- **Tasks:** 3 (Task 1 은 orchestrator 가 미리 받은 답)
- **Files modified:** 4

## Accomplishments

- 회차 `UI-base` · `UI` 둘 다 `valid: true` — `woodySource: repo`, `expectedCovered: true` (`example/` 정답지 92줄이 모두 표식에), plugin 폴더 1. 프로젝트 줄 960 → 996, 늘어난 36줄이 모두 `unnecessary_ignore` 다.
- `countsUI` = lib 1 · test 34 · bin 1 (합계 36). 회차 `G1` 의 값은 12 (1 · 10 · 1).
- `unnecessaryIgnoreNames` (코드 이름과 건수만): `ignore_for_file:lines_longer_than_80_chars` 30, `ignore_for_file:avoid_print` 1, `ignore:use_build_context_synchronously` 1, `ignore:subtype_of_sealed_class` 1, `ignore:unused_import` 1, `ignore:argument_type_not_assignable` 1, `ignore:unused_element_parameter` 1.
- 소유자 답: **안 켬** — 권고대로, 소유자의 사유 없음 (2026-10-13). `RULES.md` 행은 `소유자 결정 — … (상태: messages.yaml experimental / rules.json · dart.dev stable; 재측정 UI 36줄)`.
- `--audit`: `감사 통과 — 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0`.

## Task Commits

1. **Task 2 (추가, Rule 1): 표식 샘플의 자기 패키지 주소 바꿈** - `cb040e5` (fix)
2. **Task 2: 회차 UI · UI-base 재측정 → R1 JSON** - `bcc8c91` (feat)
3. **Task 2: 질문 9 (재측정) 패널** - `9a5176b` (docs)
4. **Task 3: 커밋 C — unnecessary_ignore 미채택** - `479ad21` (docs)

**Plan metadata:** SUMMARY · STATE · ROADMAP 은 이 파일 뒤의 metadata 커밋에 넣는다.

## 검증 결과

| 검증 | 결과 |
|---|---|
| Task 2 `<automated>` 적힌 그대로 (HEAD = `9a5176b`) | rc 0 |
| Task 2 `<automated>` + SEGFAIL1 (` && OUT=$(` 앞) | rc 0, SEGFAIL1 안 찍힘 |
| 고친 판 | 필요 없음 |
| `fvm dart run tool/measure_rules.dart --audit` (커밋 C 뒤) | rc 0, `감사 통과 — 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0` |
| `grep -c '\| 보류' RULES.md` | `0` (grep rc 1 — 맞는 줄 없음) |
| `fvm dart run tool/verify.dart` (커밋 C 뒤) | rc 0, `점검 통과 (10개 중 10개)` |
| 결정 표의 `unnecessary_ignore` 행 | `안 켬` 과 사유가 채워져 있다 |
| 비공개 점검 (1) · (2) · (3) — JSON · 04-DECISIONS.md · RULES.md | 0줄 / `LEAK?` 0 / `"message"` 0. (3) 의 화면 문구 패턴은 PLAN · RESEARCH 의 패턴 설명 10줄에만 걸리고 이 plan 이 쓴 파일에는 0줄 |

- 커밋 C 뒤에 Task 2 `<automated>` 를 다시 돌리면 `git log -1 -- "$F"` 가 커밋 C 를 가리켜 실패한다 (알려진 결함 꼴 (a)). 그래서 패널 커밋 직후, HEAD = `9a5176b` 에서 돌렸다.

## Files Created/Modified

- `tool/measure_rules.dart` — `addExampleMarkers` 가 `package:woody_lints_example/` 를 복사본 패키지의 표식 폴더 주소로 바꿔 쓰고, `examplePackageName` 을 더했다
- `tool/measurements/2026-10-13-R1.json` — 회차 `UI-base` · `UI`, `rows.unnecessary_ignore.countsUI`, `conditions.unnecessaryIgnoreNames` (앞 회차 50개는 그대로, 모두 52)
- `.planning/phases/04-rule-reselection/04-DECISIONS.md` — `## 질문 9 (재측정)` 절, 결정 표 행 · 머리 문장 · 표 밖의 메모
- `RULES.md` — 켜지 않은 규칙 표의 `unnecessary_ignore` 행 (보류 → 소유자 결정)

## Decisions Made

- 소유자: `unnecessary_ignore` 안 켬 (권고대로, 사유 없음). 사유 칸은 `권고 이유 승인 — 질문 9 (재측정) — …` 로 적어 Claude 의 패널 문장이 소유자의 말로 읽히지 않게 했다.
- CHANGELOG 는 고치지 않았다 — 04-07 도 안 켬 규칙을 CHANGELOG 에 적지 않았다 (켠 규칙만 `### 추가한 규칙`).
- `RULES.md` 의 "결정을 미룬 규칙은 접두사 대신 `보류` 로 시작" 안내 문장은 그대로 두었다 — 표의 행이 아니고 형식 설명이다.
- `## 질문 9 (재측정)` 의 `dart fix 11` 은 G1 상태(12줄)에서 잰 apply 값이다. 이 단계는 apply 를 다시 돌리지 않아 36줄의 `dart fix` 값은 재지 않았고, 패널에 그렇게 적었다.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] 재측정 회차가 둘 다 무효였다 — 표식으로 옮긴 `relative_imports_rule.dart` 가 복사본에서 깨진다**
- **Found during:** Task 2 (첫 재측정)
- **Issue:** 04-06 이 더한 `example/lib/relative_imports_rule.dart` 는 `package:woody_lints_example/` 로 자기 자신을 import 한다. `addExampleMarkers` 가 이 파일을 그대로 복사본의 표식 폴더로 옮기면 그 패키지가 없어 `uri_does_not_exist` 가 되고, 정답지의 `prefer_relative_imports` 줄이 표식에 없어 `UI-base` · `UI` 가 `정답지 줄이 표식에 다 없다` 로 무효였다 (도구 rc 1).
- **Fix:** 무효 회차를 쓴 JSON 을 그 파일 하나만 `git checkout --` 으로 되돌렸다. `addExampleMarkers` 가 `.dart` 샘플 안의 `package:<example 패키지>/` 를 `package:<복사본 패키지>/woody_probe_marker/` 로 바꿔 쓰도록 고쳤다. 저장소 파일은 읽기만 하고 복사본의 표식만 바뀐다. 그 뒤 다시 잰 두 회차가 모두 유효하다.
- **Files modified:** `tool/measure_rules.dart`
- **Verification:** `fvm dart format --set-exit-if-changed` 0, `fvm dart analyze tool` 이상 없음, 재측정 rc 0 · 두 회차 유효, 표식 92줄 = 정답지 92줄.
- **Committed in:** `cb040e5` (계획에 없던 따로 된 커밋)

---

**Total deviations:** 1 auto-fixed (Rule 1)
**Impact on plan:** 재측정이 성립하려면 필요했다. 측정 순서(반영 뒤 재측정 → 질문 → 반영)는 그대로다.

## Issues Encountered

- 작업 폴더는 04-04 의 `<work>` 를 그대로 썼다 (`pristine/` · `consumer/` 있음, `--source` 불필요). 원본 프로젝트의 경로는 받지 않았고 건드리지 않았다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 04-09 의 precondition (결정 표의 `unnecessary_ignore` 행이 채워짐, `--audit` 보류 0) 을 만족한다.
- 뒤 plan 이 example 샘플을 표식으로 쓰는 회차를 다시 돌리면 `cb040e5` 의 바꿔 쓰기가 필요하다 — 이미 도구에 들어 있다.

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*

## Self-Check: PASSED

- 커밋 `cb040e5` · `bcc8c91` · `9a5176b` · `479ad21` 모두 HEAD 의 조상, 수정 파일 넷 모두 있음, 이 파일의 비공개 경로 점검 0줄 · `LEAK?` 0.
