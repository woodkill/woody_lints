---
phase: 04-rule-reselection
plan: 13
subsystem: testing
tags: [verify, dart-analyze, yaml, gap-closure, docs]

requires:
  - phase: 04-rule-reselection
    provides: "04-11 의 CR-02 수정(declaredRuleNames 의 주석 · 빈 줄 건너뛰기, M26), 04-12 의 sort_pub_dependencies 켬 (lib/base.yaml 81개, 6d64bee)"
provides:
  - "declaredRuleNames 가 따옴표 이름을 읽고 linter: 블록 안의 읽지 못하는 줄에서 FormatException (종료 코드 70) 으로 멈춘다 — 건너뛰는 분기 없음"
  - "example/README.md 의 04-13 소절 M27 ~ M31 (실제 실행 결과)"
  - "RULES.md sort_pub_dependencies 실측 칸 `2 (pubspec.yaml 2 — lib · test · bin 은 0)` (IN-08)"
  - "example/README.md 파일 표 lib/added_rules.dart 행 '1.3.0 부터 켜 둔 규칙 6개' (IN-10)"
  - "REQUIREMENTS.md RULES-13 아래 WR-09 메모 · 04-REVIEW-DISPOSITION.md WR-09 deferred"
affects: [04-rule-reselection 재검증, 05 문서, v2 재측정 (RULES-13)]

actuals:
  tokens: 5438
  tasks: 3
  commits: 3
plan_head_before: 4efb0ce3945a322ad6fc1078d2df9e32c629dd24
plan_head_after: 8f4e257bf79baf22546198b2b2dbabcd872d1daa

tech-stack:
  added: []
  patterns:
    - "읽거나 멈추거나: 검증 도구가 손으로 쓴 YAML 을 정규식으로 읽을 때 받는 꼴을 닫힌 목록으로 두고, 그 밖의 줄은 건너뛰지 않고 행 번호와 줄을 담은 FormatException (main 의 종료 코드 70)"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - example/README.md
    - RULES.md
    - .planning/REQUIREMENTS.md
    - .planning/phases/04-rule-reselection/04-REVIEW-DISPOSITION.md

key-decisions:
  - "04-13: [3/10] 의 declaredRuleNames 는 linter: 블록 안에서 들여쓴 rules: 키 줄과 목록 항목(- 이름 · - '이름' · - \"이름\", 뒤에 # 주석 가능)만 받고 그 밖의 줄은 FormatException → 종료 코드 70 (WR-10, M27 · M28 은 [3/10] 만 실패, M29 ~ M31 은 70)"
  - "04-13: 03-REVIEW.md WR-03 의 입력 꼴(맵 형식 규칙)은 이제 [2/10] 의 거짓 실패가 아니라 종료 코드 70 으로 멈춘다 (M31) — 03-REVIEW-DISPOSITION.md 의 그 행은 손대지 않았다"
  - "04-13: WR-09 는 코드를 고치지 않고 REQUIREMENTS.md RULES-13 의 둘째 메모와 처리 기록 deferred 로 남겼다 (open 18 → 17)"

patterns-established:
  - "결함 꼴 닫기: 재리뷰가 같은 결함 꼴의 둘째 입력을 찾으면 그 입력만이 아니라 받는 꼴 밖의 모든 줄을 멈춤으로 바꾸고, `-` 로 시작하지 않는 줄(M31)처럼 반쪽 구현을 가르는 입력을 함께 돌린다"

requirements-completed: [RULES-01, RULES-06, DOCS-11]

coverage:
  - id: D1
    description: "declaredRuleNames 가 따옴표 규칙 이름을 읽어 M27 (홑따옴표 avoid_print) · M28 (큰따옴표 prefer_mixin) 에서 [3/10] 만 실패 · 종료 코드 1"
    requirement: RULES-01
    verification:
      - kind: integration
        ref: "04-13-PLAN.md Task 1 <automated> (M27 · M28 을 lib/base.yaml 106행에 더해 fvm dart run tool/verify.dart)"
        status: pass
    human_judgment: false
  - id: D2
    description: "linter: 블록 안의 읽지 못하는 줄(M29 - avoid_print: true, M30 이름 없는 -, M31 대시 없는 맵 형식 줄)에서 stdout 없이 stderr 한 줄과 종료 코드 70"
    requirement: RULES-06
    verification:
      - kind: integration
        ref: "04-13-PLAN.md Task 1 <automated> (M29 ~ M31 의 rc 70 · 빈 stdout · stderr 의 `블록의 106행을 읽지 못했다`)"
        status: pass
    human_judgment: false
  - id: D3
    description: "지금의 lib/base.yaml 81개는 그대로 읽혀 보통 실행 점검 통과 (10개 중 10개), --audit 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0, readRuleNameAt · tool/measure_rules.dart 불변"
    requirement: RULES-01
    verification:
      - kind: integration
        ref: "fvm dart run tool/verify.dart; fvm dart run tool/measure_rules.dart --audit (Task 1 · 2 · 3 <automated>)"
        status: pass
    human_judgment: false
  - id: D4
    description: "example/README.md 의 04-13 소절(M27 ~ M31 표 · 읽는 법 불릿 둘 · 종료 코드 70 행 · [3/10] 설명 덧붙임)이 실제 실행 결과와 맞고 독자에게 읽힌다"
    requirement: RULES-06
    verification:
      - kind: other
        ref: "04-13-PLAN.md Task 1 <automated> 의 README 단언"
        status: pass
    human_judgment: true
    rationale: "문구의 존재는 단언이 보지만, 설명이 읽는 사람에게 정확하고 이해되는지는 사람이 판단한다"
  - id: D5
    description: "RULES.md sort_pub_dependencies 실측 칸 IN-08 · example/README.md added_rules.dart 문장 IN-10 (텍스트만)"
    requirement: DOCS-11
    verification:
      - kind: other
        ref: "04-13-PLAN.md Task 2 <automated> (6d64bee 와의 diff 2줄, --audit, --report == 실측 기록, verify 10/10)"
        status: pass
    human_judgment: false
  - id: D6
    description: "WR-09 의 RULES-13 메모 한 줄과 04-REVIEW-DISPOSITION.md 세 곳의 deferred"
    verification:
      - kind: other
        ref: "04-13-PLAN.md Task 3 <automated> (메모 둘 · deferred 둘 · open 17 · e89ad75 와의 diff 3 · 3)"
        status: pass
    human_judgment: false

duration: 7min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 13: [3/10] 의 따옴표 규칙 이름 · 읽지 못하는 줄 (WR-10), IN-08 · IN-10, WR-09 메모 Summary

**`declaredRuleNames` 가 `- 'avoid_print'` · `- "prefer_mixin"` 을 읽어 `[3/10]` 의 겹침 · `RULES.md` 일치 검사에 넣고, `linter:` 블록 안의 그 밖의 줄(맵 항목 · 이름 없는 `-` · 대시 없는 맵 형식 줄)은 건너뛰지 않고 행 번호를 담은 `FormatException` → 종료 코드 70 으로 멈춘다 — M27 ~ M31 을 실제로 돌려 README 에 기록**

## Performance

- **Duration:** 약 7 min
- **Started:** 2026-10-13T12:23:17Z
- **Completed:** 2026-10-13T12:30Z
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments

- WR-10 (04-VERIFICATION.md 진실 6 의 partial) 을 결함 꼴째 닫았다 — 블록 안의 비주석 · 비공백 줄은 읽거나(`rulesKeyPattern` `^\s+rules:\s*(?:#.*)?$`, `rulePattern` `^\s*-\s+(['"]?)([A-Za-z0-9_]+)\1(?:\s+#.*)?\s*$`) 멈춘다. 건너뛰는 분기가 없다.
- 지금의 81개는 그대로 읽힌다 — 보통 실행 종료 코드 0 · `점검 통과 (10개 중 10개)` (약 20초), `--audit` `감사 통과 — 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0`.
- 소유자가 묶은 문서 지적 셋을 텍스트로 처리했다 — IN-08 (`RULES.md` 한 칸), IN-10 (README 문장 하나), WR-09 (RULES-13 메모 · `deferred`).

## M27 ~ M31 의 실제 결과 (Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13)

다섯 변경 모두 `lib/base.yaml` 의 `- no_raw_types` 줄 바로 뒤(106행)에 더하고 돌린 직후 백업으로 되돌렸다.

| # | 더한 줄 | 종료 코드 | 실패 단계 / 찍힌 것 | 시간 |
|---|---------|-----------|---------------------|------|
| M27 | `    - 'avoid_print' # 기반 세트와 겹침 (따옴표)` | 1 | `[3/10]` 만 실패 (`[2/10]` · `[5/10]` ~ `[10/10]` 통과). 겹침 1 `avoid_print  (flutter_lints-6.0.0 flutter.yaml)`, `+ avoid_print  (base.yaml 에만)`, `점검 실패 (10개 중 1개)` | 19초 |
| M28 | `    - "prefer_mixin" # RULES.md 켠 규칙 표에 없음 (큰따옴표)` | 1 | `[3/10]` 만 실패, 겹침 블록 없음, `+ prefer_mixin  (base.yaml 에만)` 하나, `점검 실패 (10개 중 1개)` | 20초 |
| M29 | `    - avoid_print: true # 읽지 못하는 꼴 (맵 항목)` | 70 | stdout 비어 있음. stderr: `` 파일 모양이 예상과 다르다: `linter:` 블록의 106행을 읽지 못했다 — 목록 항목(`- 이름` · `- '이름'` · `- "이름"`, 뒤에 `# 주석` 가능)과 `rules:` 만 받는다 (04-REVIEW.md WR-10): - avoid_print: true # 읽지 못하는 꼴 (맵 항목) `` | 2초 |
| M30 | `    -` / `      avoid_print # 읽지 못하는 꼴 (이름이 다음 줄)` | 70 | stdout 비어 있음. stderr 같은 문구, 끝이 `(04-REVIEW.md WR-10): -` | 3초 |
| M31 | `    avoid_print: true # 읽지 못하는 꼴 (맵 형식 — 대시 없음)` | 70 | stdout 비어 있음. stderr 같은 문구, 끝이 `(04-REVIEW.md WR-10): avoid_print: true # 읽지 못하는 꼴 (맵 형식 — 대시 없음)` | 3초 |

예외가 난 단계(M29 · M30 은 `[2/10]` 의 `countDeclaredRules(rulesCopy)`, M31 은 `[2/10]` 이 깨진 YAML 로 먼저 돌아간 뒤 `[3/10]` 의 `declaredRuleNames(baseText)`)는 코드에서 읽은 것이고, 실행에서 본 것은 종료 코드 · stdout · stderr 다. 각 실험 뒤 `git diff --quiet 6d64bee -- lib/base.yaml` 참, `build/woody_rule_check` 없음을 확인했다.

## Task Commits

1. **Task 1: declaredRuleNames 의 따옴표 이름 · 읽지 못하는 줄 (tracer)** — `67d1bc7` (fix)
2. **Task 2: RULES.md IN-08 · example/README.md IN-10** — `76dee2f` (docs)
3. **Task 3: WR-09 RULES-13 메모 · DISPOSITION deferred** — `8f4e257` (docs)

**Plan metadata:** 마무리 커밋 (docs(04-13)) — SUMMARY · STATE · ROADMAP · REQUIREMENTS

### 검증 명령 결과 (PLAN 의 `<automated>` 를 파일로 뽑아 `bash` 로, 각 task 커밋 직후)

| Task | 적힌 그대로 rc | 고친 판 rc | 걸린 시간 |
|------|----------------|------------|-----------|
| 1 | 0 | 없음 | 86초 |
| 2 | 0 | 없음 | 21초 |
| 3 | 0 | 없음 | 19초 |

Task 1 은 tracer 다 — 커밋 뒤 `<verify>` 를 끝에서 끝까지 다시 돌린 것이 위의 rc 0 이고, 그 뒤에 Task 2 · 3 을 진행했다.

## Files Created/Modified

- `tool/verify.dart` — `declaredRuleNames` 하나: 새 `rulePattern` (group(2) 가 이름), `rulesKeyPattern`, 행 번호를 세는 루프, 읽지 못하는 줄의 `FormatException`, 고친 doc 주석. 시그니처 · `countDeclaredRules` · `readRuleNameAt` (옛 패턴은 거기에만 남음) · import 는 그대로 (+32 −8)
- `example/README.md` — 04-13 소절과 M27 ~ M31, 종료 코드 70 행 · `[3/10]` 설명 덧붙임 (Task 1); 파일 표 `lib/added_rules.dart` 행 (Task 2)
- `RULES.md` — 켠 규칙 표 `sort_pub_dependencies` 행의 실측 칸 하나. `6d64bee` 와의 diff 2줄 (지워진 1 · 더해진 1)
- `.planning/REQUIREMENTS.md` — RULES-13 아래 WR-09 메모 한 줄 (`2c9c5a7` + 1줄)
- `.planning/phases/04-rule-reselection/04-REVIEW-DISPOSITION.md` — WR-09 `deferred` 세 곳. `e89ad75` 와의 diff 지워진 3 · 더해진 3

## Decisions Made

- 예외 메시지는 80칸에 맞춰 인접 문자열 리터럴 셋으로 나눠 적었다 (계획이 허용한 방식 — 검증은 stderr 로 문구를 본다).

## Deviations from Plan

None - plan executed exactly as written. 세 task 의 검증 명령 모두 적힌 그대로 종료 코드 0 이었고 고친 판은 없다.

계획 본문의 planner 측정값과 다른 실측값(값만 다름): M27 23초 → 19초, M28 22초 → 20초, M29 3초 → 2초, M30 2초 → 3초. README 에는 실측값을 적었다.

## Issues Encountered

None.

## 열어 두는 것 (이 plan 이 다루지 않음)

- 04-REVIEW.md 의 `open` 지적: WR-01 · WR-03 · WR-04 · WR-07 · WR-08, IN-01 ~ IN-07 · IN-09 · IN-11.
- IN-10 의 둘째 절반 — `example/lib/added_rules.dart` 3행 머리 주석과 `fixtures/*/lib/added_rules.dart` 복사본 다섯 (소유자 결정 §2 로 그대로 둠).
- IN-08 의 다른 안 — `RULES.md` 헤더를 넷으로 나누기.
- 03-REVIEW.md WR-03 의 입력(맵 형식 규칙)은 이제 `[2/10]` 의 "규칙을 하나도 세지 못했다" 실패 대신 종료 코드 70 으로 멈춘다 (M31 이 같은 꼴). `03-REVIEW-DISPOSITION.md` 의 그 행(`open`)은 손대지 않았다.
- 04-REVIEW-DISPOSITION.md 의 WR-10 · IN-08 · IN-10 행은 손대지 않았다 — 마무리의 재리뷰가 다룬다.
- 앞 plan 의 상태 고정 단언 가운데 04-12 Task 1 의 것(`RULES.md` 의 옛 실측 칸)은 이 plan 의 Task 2 뒤로는 그 task 의 커밋(`6d64bee`)으로 되돌린 복제본에서만 참이다 (설계대로). 이 plan 의 Task 1 단언(README `9eb8ee5` 와의 지워진 줄 2)도 Task 2 뒤에는 3 이 되어 `67d1bc7` 의 복제본에서만 참이다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 4 의 코드 리뷰 · 재검증은 orchestrator 가 한다. 이 plan 의 커밋은 push 하지 않았다 (Phase 5 부터의 push 는 소유자에게 묻는다 — D-22).

## Self-Check: PASSED

- FOUND: tool/verify.dart, example/README.md, RULES.md, .planning/REQUIREMENTS.md, .planning/phases/04-rule-reselection/04-REVIEW-DISPOSITION.md
- FOUND: 67d1bc7, 76dee2f, 8f4e257 (HEAD 의 조상)
- 비공개 점검: 세 task 의 검증 명령 안의 `git grep` (절대 경로 꼴) 이 바뀐 파일 다섯에서 종료 코드 1 (짝 없음)

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*
