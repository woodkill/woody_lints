---
phase: 03-preset-split
plan: 01
subsystem: testing
tags: [dart-analyze, verify-harness, golden-file, analysis-options]

# Dependency graph
requires:
  - phase: 02-verification-harness
    provides: "tool/verify.dart 의 [2/4] 규칙 검사와 --update 안전장치(다른 단계가 실패하면 정답지를 쓰지 않는다, 02-05)"
provides:
  - "[2/4] 의 새 통과 조건 — 규칙 검사 복사본의 dart analyze 가 exit 0 이고 진단 0건"
  - "깨진 옵션 파일 가지 — exit != 0 이고 JSON 진단 0건이면 형식 인자 없이 재실행해 parse_error 줄을 보여 줌 (readParseErrorLines, parseErrorCode)"
  - "example/README.md 의 M15 ~ M17 (세 입력의 고치기 전 · 뒤 실측)"
affects: [03-02, 03-03, 03-04, tool/verify.dart, example/README.md]

# Actuals (#2632)
actuals:
  tokens: 5120
  tasks: 2
  commits: 2
plan_head_before: 127416c63a0b6b5a1443067152830fe52c9bd1a6
plan_head_after: 533868af5f586f3c5a4f4c6e0b1d411f596916e0

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "규칙 검사의 통과는 'exit 0 이고 진단 0건' 하나 — 특정 코드만 골라 실패로 치지 않는다"
    - "JSON 출력에 나오지 않는 옵션 파일의 error 진단은 형식 인자 없는 재실행으로 원인 줄을 찾고 scrubPaths 로 경로를 가린다"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - example/README.md

key-decisions:
  - "[2/4] 의 통과 조건은 복사본의 dart analyze 가 exit 0 이고 진단 0건 하나다. 세 코드(deprecated_lint / removed_lint / undefined_lint) 밖의 옵션 경고와 깨진 YAML 도 실패다 — ruleProblemCodes 상수는 지웠다"
  - "깨진 옵션 파일 가지의 조건은 plan 대로 exitCode != 0 && lines.isEmpty 다 (RESEARCH 뼈대의 exitCode == 3 보다 넓다 — exit 2 + 0건 같은 어긋남도 같은 가지가 잡는다)"
  - "세 코드 밖의 진단에도 readRuleNameAt 로 규칙 이름을 붙인다 — duplicate_rule 줄에 (avoid_print) 가 붙는다"

patterns-established:
  - "판정 순서: 도구 사망 → 깨진 옵션 파일 → include_file_not_found → 규칙 0개 → 진단이 하나라도 있음 → 통과"

requirements-completed: [PRESET-04]

coverage:
  - id: D1
    description: "세 입력(닫지 않은 따옴표 / rules: 오타 / 겹친 규칙 + 없는 진단 코드)에서 --update 가 종료 코드 1 · [2/4] 실패 · '다른 단계가 실패해 정답지를 쓰지 않았다' 로 끝나고 정답지 git hash 가 그대로다; 보통 실행은 [2/4] 와 [4/4] 둘 다 실패"
    requirement: "PRESET-04"
    verification:
      - kind: integration
        ref: "03-01-PLAN.md Task 1 <automated> (세 입력을 perl -pi 로 넣고 --update · 보통 실행, 되돌림)"
        status: pass
    human_judgment: false
  - id: D2
    description: "원본 배포 파일(90a2736)에서 새 통과 조건으로도 보통 실행이 종료 코드 0 · 점검 통과 (4개 중 4개)"
    requirement: "PRESET-04"
    verification:
      - kind: integration
        ref: "fvm dart run tool/verify.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "example/README.md 의 30행 · 81행 · 158행이 코드와 같고 M15 ~ M17 이 실측 값으로 기록됨, 절대 경로 · 토큰 없음"
    requirement: "PRESET-04"
    verification:
      - kind: other
        ref: "03-01-PLAN.md Task 2 <automated> (grep 단언 + 기준 커밋 비교 + 검증 명령 exit 0)"
        status: pass
    human_judgment: false

# Metrics
duration: 5min
completed: 2026-10-12
status: complete
---

# Phase 3 Plan 01: `--update` 의 망가진 배포 파일 경로 닫기 Summary

**`tool/verify.dart` 의 `[2/4]` 를 "복사본의 dart analyze 가 exit 0 이고 진단 0건" 으로 좁히고 깨진 YAML 은 형식 인자 없는 재실행의 `parse_error` 줄로 알려, 세 입력 모두에서 `--update` 가 정답지를 쓰지 못하게 했다**

## Performance

- **Duration:** 약 5 min
- **Started:** 2026-10-12T11:26:53Z
- **Completed:** 2026-10-12T11:31:35Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- `checkRuleNames` 의 판정을 (1) 도구 사망 → (2) 깨진 옵션 파일 (`exit != 0 && 진단 0건`, `readParseErrorLines` 의 줄을 보여 줌) → (3) `include_file_not_found` → (4) 규칙 0개 → (5) 진단이 하나라도 있으면 실패 → (6) 통과 의 순서로 바꿨다. `ruleProblemCodes` 를 지우고 `parseErrorCode` 를 더했다.
- 세 입력에서 `--update` 가 고치기 전에는 셋 다 종료 코드 0 · 정답지를 썼고, 고친 뒤에는 셋 다 종료 코드 1 · 정답지 hash 불변이다 (아래 표). 원본 배포 파일은 새 조건으로도 `점검 통과 (4개 중 4개)`.
- `example/README.md` 의 `--update` 안전장치 문단 · 단계 설명 문단 · `막지 않는 것도 있다` 문단을 코드에 맞추고 새 소절에 M15 ~ M17 을 기록했다.

## 세 입력의 고치기 전 · 뒤 (이 저장소에서 잼, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12)

입력은 `lib/analysis_options.yaml` 에만, 한 번에 하나씩 넣고 실행 직후 `git checkout -- lib/analysis_options.yaml example/expected_diagnostics.txt` 로 되돌렸다. 실행 전 정답지 hash 는 `facd4a7e15cd7cff91a02b5d455810ccfa0feb56`.

### 고치기 전 (`127416c` 의 스크립트, action 0)

| 입력 | `--update` 종료 코드 | `[2/4]` | `정답지를 썼다` | 정답지 hash | 보통 실행 |
|---|---|---|---|---|---|
| A 닫지 않은 따옴표 (46행) | 0 | 통과 | 찍힘 | 바뀜 → `d5a1879…` (`exit 3` + `lib/should_not_appear.dart:5  warning  invalid_annotation_target` 1줄) | 1, `[4/4]` 만 실패, `점검 실패 (4개 중 1개)` |
| B `rules:` → `ruels:` (21행) | 0 | 통과 | 찍힘 | 바뀜 → `3da4e63…` (추가 규칙 6줄 빠짐 + `analysis_options.yaml:1  warning  included_file_warning`) | 1, `[4/4]` 만 실패 |
| C 겹친 규칙 + 없는 진단 코드 | 0 | 통과 | 찍힘 | 바뀜 → `fd305b1…` (16줄 + `included_file_warning` 2줄) | 1, `[4/4]` 만 실패 |

RESEARCH 권고 6 의 scratch 값과 같다 (A-01-1 의 가정이 맞았다).

### 고친 뒤 (`998cc32`, action 4)

| 입력 | `--update` 종료 코드 | `[2/4]` | `정답지를 썼다` | 정답지 hash | 보통 실행 |
|---|---|---|---|---|---|
| A | 1 | 실패 (`parse_error` 줄) | 안 찍힘 — `다른 단계가 실패해 정답지를 쓰지 않았다` | 불변 (`facd4a7…`) | 1, `[2/4]` · `[4/4]` 실패, `점검 실패 (4개 중 2개)` |
| B | 1 | 실패 (`…:21  warning  unsupported_option`) | 안 찍힘 | 불변 | 1, `[2/4]` · `[4/4]` 실패, `점검 실패 (4개 중 2개)` |
| C | 1 | 실패 (`…:41  warning  duplicate_rule  (avoid_print)`, `…:46  warning  unrecognized_error_code`) | 안 찍힘 | 불변 | 1, `[2/4]` · `[4/4]` 실패, `점검 실패 (4개 중 2개)` |
| 원본 그대로 | — | 통과 | — | 불변 | 0, `점검 통과 (4개 중 4개)` |

입력 A 의 `[2/4]` 화면 (경로를 가린 그대로 — 재실행 출력에 절대 경로가 없었다):

```text
규칙 검사의 dart analyze 가 exit 3 로 끝났는데 JSON 에 진단이 없다 — 배포 파일의 YAML 이 깨졌을 수 있다 (닫지 않은 따옴표, 잘못된 들여쓰기 등).
  error - analysis_options.yaml:47:8 - While parsing a block collection, expected '-'. - parse_error

`lib/analysis_options.yaml` 의 그 줄을 고친다 (복사본의 줄 번호는 원본과 같다).
```

`parse_error` 줄은 따옴표를 뗀 46행이 아니라 파서가 막힌 47행을 가리킨다. 입력 C 의 줄 번호(41 · 46)는 plan 이 예상한 값과 같다.

## Task Commits

1. **Task 1: `[2/4]` 의 통과 조건을 "exit 0 이고 진단 0건" 으로** - `998cc32` (fix)
2. **Task 2: `example/README.md` 를 코드에 맞추고 M15 ~ M17 기록** - `533868a` (docs)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 의 커밋 (docs)

## Files Created/Modified

- `tool/verify.dart` — 머리 주석 4행, `parseErrorCode` 상수, `readParseErrorLines(String repoRoot)`, `checkRuleNames` 의 새 가지 둘과 규칙 0개 문구, `ruleProblemCodes` 삭제
- `example/README.md` — 30행(`--update` 안전장치), 81행(단계 설명), 158행(`막지 않는 것도 있다`), 새 소절 `### 추가 실측 — 망가진 배포 파일의 \`--update\` (03-01)` 과 M15 ~ M17

## Decisions Made

- 깨진 옵션 파일 가지의 조건은 plan 의 `result.exitCode != 0 && lines.isEmpty` 를 따랐다 (RESEARCH 뼈대는 `== 3`). 도구 사망 가지가 먼저 `{0, 2, 3}` 밖을 걸러내므로 실제로 걸리는 것은 exit 2 · 3 에 진단 0건인 경우다.
- `readParseErrorLines` 는 stdout 과 stderr 를 합쳐 `parse_error` 를 담은 줄만 고르고, `trim()` 뒤 `scrubPaths` 로 가린다. 상태 폴더 환경변수는 주지 않는다 (규칙 검사는 plugin 을 준비하지 않는다).
- 정답지와 `lib/` 는 건드리지 않았다 — `git diff --quiet 90a2736 -- lib`, `19ae5ec -- example/expected_diagnostics.txt`, `74fafb2 -- example/lib`, `968a5bb -- pubspec.yaml` 모두 통과.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. Task 1 은 `type="tracer"` 였고, interactive · `end-of-phase` · `<automated>` 만 있는 경우라 verify 를 다시 돌려 통과한 뒤 Task 2 로 넘어갔다 (checkpoint 없음).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 03-02 (프리셋 나누기) 가 `shippedOptionsPath` · `stripPlugins` · `countDeclaredRules` 의 대상을 조각 셋으로 바꿀 때, 이 plan 의 판정 순서와 `readParseErrorLines` 는 그대로 쓴다 — 재실행은 `ruleCheckDir` 폴더 전체를 보므로 하위 폴더 셋으로 나뉘어도 `parse_error` 줄을 찾는다 (경로에 조각 이름이 들어간다). 깨진 옵션 파일 문구의 `$shippedOptionsPath` 는 03-02 가 조각 이름으로 바꿔야 한다.
- 이 plan 의 커밋은 push 하지 않았다 (D-09 — Phase 3 의 push 는 소유자에게 묻는다).
- PRESET-04 는 03-02 도 선언하므로 REQUIREMENTS.md 의 체크는 03-02 가 끝난 뒤에 된다 (`requirements.ready-ids` 0/1).

## Self-Check: PASSED

- FOUND: `tool/verify.dart`, `example/README.md`
- FOUND: `998cc32` (파일 `tool/verify.dart` 하나), `533868a` (파일 `example/README.md` 하나)
- Task 1 · Task 2 의 `<automated>` 를 plan 에 적힌 그대로 돌려 둘 다 종료 코드 0
- `build/woody_rule_check` 남지 않음, `git status --short -- lib example` 비어 있음

---
*Phase: 03-preset-split*
*Completed: 2026-10-12*
