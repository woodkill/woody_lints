---
phase: 05-documentation
plan: 07
subsystem: testing
tags: [verify-dart, readme, gap-closure, dart-analyze]

requires:
  - phase: 05-documentation
    provides: "05-01 의 (b′), 05-03 의 README 검사 (d) ~ (g), 05-06 의 지워 보기 M38 ~ M42"
provides:
  - "readMarkerBlock · MarkerBlock — 마커 구역 처리 한 곳 (IN-06)"
  - "줄 규칙이 닫힌 readBulletBlock — README 표시 구역의 읽지 못하는 줄은 [3/10] 실패 (gaps 1)"
  - "linter: 줄의 flow 표기에서 FormatException (종료 코드 70) 을 내는 declaredRuleNames (gaps 2)"
  - "unquotedScalar 와 따옴표 · 줄 끝 주석 · 꼴을 보는 (f) · (g) (WR-02)"
  - "example/README.md 의 소절 (05-07) — 지워 보기 M43 ~ M50"
affects: [05-08, 05-09]

actuals:
  tokens: 9800
  tasks: 3
  commits: 3
plan_head_before: 7785392073fc4afba728d9640d4e3000af8715cd
plan_head_after: 73f1c66f7bde92b7b9a9561dab4954b711d9e0c4

tech-stack:
  added: []
  patterns:
    - "reader 는 받는 줄의 꼴을 닫힌 목록으로 두고, 그 밖의 줄은 건너뛰지 않고 실패(단계 실패 또는 종료 코드 70)로 알린다"
    - "지워 보기는 git clone --local 복제본에 작업 트리의 미커밋 변경을 git diff HEAD 로 옮겨 돌린다"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - example/README.md
    - README.md

key-decisions:
  - "README 표시 구역 안에서 받는 줄은 빈 줄 · `**분류**` 소제목 · `- `이름`` 불릿 셋뿐이고, 그 밖의 줄은 `구역에 읽지 못하는 줄이 있다 (N)` 으로 [3/10] 실패다 (gaps 1, M43 · M44)"
  - "`linter:` 줄에 `#` 주석 밖의 값이 붙어 있으면(flow 표기) 종료 코드 70 으로 멈추고, 줄 끝 주석만 붙은 블록 꼴은 그대로 받는다 (gaps 2, M45 · M46)"
  - "README 코드 블록의 (f) · (g) 는 키 줄을 모두 후보로 잡아 unquotedScalar 로 따옴표를, 정규식으로 줄 끝 주석을 벗긴 값의 꼴을 보고, 값 없는 맵 키 줄은 후보로 치지 않는다 (WR-02, M47 ~ M50)"

patterns-established:
  - "MarkerBlock: 마커 구역 reader 의 결과는 names · malformed 둘이고, 마커 찾기는 readMarkerBlock 한 곳에 있다"

requirements-completed: [VERIFY-06, DOCS-06]

coverage:
  - id: D1
    description: "README 표시 구역 안의 읽지 못하는 줄(옛 README 꼴 · 다른 불릿 기호 · 이름 꼴이 아닌 불릿)이 [3/10] 실패로 잡히고, 마커 처리가 readMarkerBlock 하나에 있다 (gaps 1, IN-06)"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-07-PLAN.md Task 1 <automated> (복제본 M43 · M44 + 기준 실행 10/10)"
        status: pass
    human_judgment: false
  - id: D2
    description: "lib/codegen.yaml 의 flow 표기 `linter: {rules: [prefer_mixin]}` 가 종료 코드 70 · stderr 의 파일 이름 · 행 번호 · 원문으로 멈추고, 줄 끝 주석을 단 블록 꼴은 [3/10] 실패 그대로다 (gaps 2)"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-07-PLAN.md Task 2 <automated> (복제본 M45 · M46 + 기준 실행 10/10)"
        status: pass
    human_judgment: false
  - id: D3
    description: "README 「이 저장소를 고치는 사람에게」 의 '규칙은 lib/base.yaml 에만' 불릿이 블록 목록([3/10] 실패)과 flow 표기(종료 코드 70)를 가른다"
    requirement: DOCS-06
    verification:
      - kind: other
        ref: "05-07-PLAN.md Task 2 <automated> (grep -qxF 새 불릿, numstat 3a248d0 1/1)"
        status: pass
    human_judgment: false
  - id: D4
    description: "README 코드 블록의 (f) · (g) 가 따옴표 · 줄 끝 주석을 벗겨 읽고 꼴이 틀린 값을 실패시키며, 맞는 값의 따옴표와 주석만 붙은 맵 키 줄은 받는다 (WR-02)"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-07-PLAN.md Task 3 <automated> (복제본 M47 ~ M50 + 기준 실행 10/10)"
        status: pass
    human_judgment: false
  - id: D5
    description: "example/README.md 의 소절 (05-07) — M43 ~ M50 의 실제 결과 기록과 113행 · 116행 덧붙임의 문장"
    verification:
      - kind: other
        ref: "Task 1 ~ 3 <automated> 의 행 수 · 문구 grep, 절대 경로 grep 0줄"
        status: pass
    human_judgment: true
    rationale: "기록 문장의 정확성(읽는 법 불릿의 '코드에서 읽은 것' 과 '돌린 것' 의 구분)은 grep 이 보지 못한다"

duration: 23min
completed: 2026-10-14
status: complete
---

# Phase 5 Plan 07: gap 수정 — README 표시 구역 · flow 표기 · 코드 블록 값의 읽지 못하는 줄 Summary

**`tool/verify.dart` 의 README 불릿 reader · `linter:` 줄 · README 코드 블록 값 reader 가 읽지 못하는 입력을 건너뛰지 않고 `[3/10]` 실패나 종료 코드 70 으로 알린다 — 마커 처리는 `readMarkerBlock` 하나, 따옴표 벗기기는 `unquotedScalar` 하나, 지워 보기 M43 ~ M50 을 복제본에서 돌려 기록했다**

## Performance

- **Duration:** 23 min
- **Started:** 2026-10-14T01:13:11Z
- **Completed:** 2026-10-14T01:36:00Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments

- gaps 1 닫음: `readBulletBlock` 이 구역 안에서 빈 줄 · `**분류**` 소제목 · `- `이름`` 불릿만 받고, 그 밖의 줄을 `MarkerBlock.malformed` 에 담아 (d) 가 `` `README.md` 의 `woody:readme-rules` 구역에 읽지 못하는 줄이 있다 (N): `` 로 실패시킨다. `RulesMdBlock` 은 `MarkerBlock` 이 되었고 마커 `indexOf` 는 `readMarkerBlock` 한 곳에만 있다 (IN-06).
- gaps 2 닫음: `declaredRuleNames` 가 `linter:` 줄이 `^linter:[ \t]*(?:#.*)?$` 에 맞지 않으면 `FormatException` — 종료 코드 70. 문서 주석의 옛 "flow 는 `[2/N]` 이 잡는다" 문장을 걷었다.
- README 378행의 단정을 고친 동작에 맞췄다 (DOCS-06): 블록 목록이면 `[3/10]` 실패, flow 표기면 종료 코드 70.
- WR-02: (f) · (g) 가 코드 블록의 키 줄을 모두 후보로 잡고 따옴표 · 줄 끝 주석을 벗긴 값의 꼴을 보며, 꼴이 틀린 줄은 `읽지 못하는 … 줄이 있다 (N)` 으로 실패. 새 함수 `unquotedScalar` (05-09 가 다시 쓴다).
- 지금 README · RULES.md · lib YAML 로는 작업 트리의 기준 실행이 종료 코드 0 · `점검 통과 (10개 중 10개)` 그대로다.

### 지워 보기 M43 ~ M50 의 실제 결과 (모두 `git clone --local` 복제본, 2026-10-14, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9)

| # | 변경 | 종료 코드 | 실패한 단계 | 찍힌 줄 (요지) | 시간 |
|---|------|-----------|-------------|----------------|------|
| M43 | README 표시 구역에 `- require_trailing_commas: 자동 코드 정렬 최적화` | 1 | `[3/10]` 만 | `구역에 읽지 못하는 줄이 있다 (1)` + 그 줄, `점검 실패 (10개 중 1개)`, 이름 비교 블록 없음 | 24초 |
| M44 | 같은 자리에 `* `extra`` · `- `Extra_Rule`` | 1 | `[3/10]` 만 | `구역에 읽지 못하는 줄이 있다 (2)` + 두 줄, 이름 비교 블록 없음 | 23초 |
| M45 | `lib/codegen.yaml` 10행 `linter: {rules: [prefer_mixin]}` | 70 | 단계 줄 없음 (stdout 0 바이트) | stderr: `파일 모양이 예상과 다르다: lib/codegen.yaml 의 10행: `linter:` 줄에 값이 붙어 있다 — … (05-REVIEW.md WR-04): linter: {rules: [prefer_mixin]}` | 3초 |
| M46 | `lib/codegen.yaml` 끝에 `linter: # …` / `  rules:` / `    - prefer_mixin` | 1 | `[3/10]` 만 | `` `lib/codegen.yaml` 에 규칙이 있다 (1) `` + `prefer_mixin` | 23초 |
| M47 | 234행 `    version: "^3.1.3"` | 1 | `[3/10]` 만 | 선언과 다른 값 블록에 `  ^3.1.3`, 읽지 못하는 줄 블록 없음 | 23초 |
| M48 | 18행 `      ref: v1.9.0 # 예시` | 1 | `[3/10]` 만 | `  ref: v1.9.0`, 읽지 못하는 줄 블록 없음 | 23초 |
| M49 | 198행 `  riverpod_lint: ^3.1` | 1 | `[3/10]` 만 | `` 읽지 못하는 `version:` · `riverpod_lint:` 줄이 있다 (1) `` + `riverpod_lint: ^3.1` | 23초 |
| M50 | 18행 `ref: 'v2.0.0'` · 234행 `version: "^3.1.9"` · 233행 `  riverpod_lint: # 끄기 설정의 plugin 선언` | 0 | 없음 | `점검 통과 (10개 중 10개)` | 23초 |

복제본의 첫 실행(plugin 준비 포함)은 68 ~ 69초, 되돌린 뒤의 보통 실행은 22 ~ 24초 · 10개 중 10개였다. 작업 트리의 기준 실행도 종료 코드 0 · `점검 통과 (10개 중 10개)` 다.

## Task Commits

1. **Task 1: gaps 1 — readMarkerBlock · MarkerBlock, readBulletBlock 의 줄 규칙, M43 · M44** - `5f43726` (fix)
2. **Task 2: gaps 2 — linter: 줄의 flow 표기를 70 으로, README 378행, M45 · M46** - `057bef2` (fix)
3. **Task 3: (f) · (g) 의 따옴표 · 줄 끝 주석 · 꼴과 unquotedScalar, M47 ~ M50** - `73f1c66` (fix)

**Plan metadata:** 이 SUMMARY 와 함께 커밋 (docs)

## Files Created/Modified

- `tool/verify.dart` - `MarkerBlock` · `readMarkerBlock` · `unquotedScalar` 추가, `readBulletBlock` 줄 규칙, `declaredRuleNames` 의 flow 분기, (d) · (f) · (g) 의 실패 블록
- `example/README.md` - 113행 · 116행 덧붙임, 소절 `### 추가 실측 — README 목록 · flow 표기 · 코드 블록 값의 읽지 못하는 줄 (05-07)` (M43 ~ M50)
- `README.md` - 378행 '규칙은 `lib/base.yaml` 에만' 불릿의 둘째 문장 (한 줄 교체)

## Decisions Made

- 계획에 적힌 대로 했다. (d) 의 분류 검사, (f) 를 `riverpod_lint:` 맵 아래로 좁히기, `.claude/CLAUDE.md` 수정, 승인 목록 밖 reader 변경은 하지 않았다 (P-07).
- M45 의 시간(3초)이 짧은 것은 `main` 이 `[1/10]` ~ `[4/10]` 을 연습용 프로젝트 분석보다 먼저 돌리고 `[3/10]` 의 예외로 끝나기 때문이다 (`main` 의 단계 순서를 읽은 것).

## Deviations from Plan

None - plan executed exactly as written.

세 task 의 `<automated>` 는 모두 적힌 그대로 통과했다 (고친 판 없음):

| Task | 적힌 그대로 (커밋 전) | 적힌 그대로 (커밋 뒤 · 끝의 재실행) |
|------|----------------------|--------------------------------------|
| 1 (tracer) | rc 0 | rc 0 (tracer 게이트 재실행) · rc 0 (끝) |
| 2 | rc 0 | rc 0 (끝) |
| 3 | rc 0 | rc 0 (끝) |

**Total deviations:** 0
**Impact on plan:** 없음.

## Issues Encountered

None. 지워 보기는 모두 복제본에서 했고 작업 트리의 `README.md` · `lib` · `RULES.md` 는 변형하지 않았다. 끝에 `git diff --quiet 209e3af -- lib` · `git diff --quiet 76dee2f -- RULES.md` 가 참이고 `git diff --numstat 3a248d0 -- README.md` 는 `1/1` 이다. 저장소 파일 · 커밋 메시지에 실제 홈 폴더 경로나 임시 폴더 경로는 0줄이다.

## 열린 채 남는 것

- (f) 의 `version:` 을 `riverpod_lint:` 맵 아래로 좁히는 일 (05-REVIEW WR-02 부수 문제, 소유자 승인 밖) — README 에 pubspec 예시 블록을 넣으면 그 `version:` 도 견준다. 지금 README 에는 없다.
- 펜스 판정(`~~~`, 펜스 길이)과 `RULES.md` 표 reader 의 줄 규칙은 05-08 이 고친다.
- `lib/base.yaml` 의 flow 표기가 `[2/10]` 의 `countDeclaredRules` 자리에서 70 으로 멈춘다는 것은 코드에서 읽은 것이고 돌리지 않았다.
- VERIFY-06 · DOCS-06 의 완료 표시는 05-09 가 한다 (같은 ID 를 선언한 마지막 gap plan).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-08 (RULES.md 표 reader · 주소 · 펜스 · 옵션 reader, M51 ~ M62) 준비됨 — `readRulesMdBlock` 은 이미 `readMarkerBlock` 위에 있어 줄 규칙만 고치면 된다.
- 05-09 는 `unquotedScalar` 를 plugin 선언 · pubspec reader 에 다시 쓴다. 05-09 Task 2 · 3 이 찾는 커밋 제목(`05-VERIFICATION gaps 2`, `fix(tool): README 코드 블록의 version · ref 값`)은 계획의 글자 그대로다.

---
*Phase: 05-documentation*
*Completed: 2026-10-14*

## Self-Check: PASSED

- FOUND: tool/verify.dart, example/README.md, README.md
- FOUND: 5f43726, 057bef2, 73f1c66 (HEAD 의 조상)
