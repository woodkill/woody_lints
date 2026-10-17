---
phase: 05-documentation
plan: 08
subsystem: testing
tags: [verify-dart, rules-md, readme, gap-closure, dart-analyze]

requires:
  - phase: 05-documentation
    provides: "05-07 의 readMarkerBlock · MarkerBlock · unquotedScalar, 지워 보기 M43 ~ M50"
provides:
  - "줄 규칙이 닫힌 readRulesMdBlock — RULES.md 표 구역 안의 읽지 못하는 줄은 [3/10] 실패"
  - "(e) 의 꼴 검사(`<이름>.yaml`)와 woody_lints 가 아닌 패키지 주소 검사"
  - "펜스 문자 · 길이를 기억하는 fencedLines"
  - "flow 표기 · 읽지 못하는 옵션 줄에서 FormatException (70) 을 내는 enabledLanguageOptions(options, shownAs:)"
  - "tool/measure_rules.dart 의 readRulesTable 문서 주석 (코드는 그대로)"
  - "example/README.md 의 소절 (05-08) — 지워 보기 M51 ~ M62"
affects: [05-09]

actuals:
  tokens: 5714
  tasks: 3
  commits: 3
plan_head_before: 6dc5f08c26414c1093eafa953e75259747c128d7
plan_head_after: a14be4f72ca06a1f225c07a2b437a2aa7b2c63f4

tech-stack:
  added: []
  patterns:
    - "reader 는 받는 줄의 꼴을 닫힌 목록으로 두고, 그 밖의 줄은 건너뛰지 않고 실패(단계 실패 또는 종료 코드 70)로 알린다 — RULES.md 표 · README 주소 · 펜스 · analyzer 옵션까지"
    - "GFM 표 칸 안의 `|` 는 code span 안에서도 `\\|` 로 적는다"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - tool/measure_rules.dart
    - example/README.md

key-decisions:
  - "RULES.md 표 구역 안에서 받는 줄은 0번째 줄의 머리 줄 · 1번째 줄의 구분 줄 · 첫 칸이 backtick 이름 하나인 데이터 행 · 데이터 행이 없는 구역의 `없음 — …` 한 줄뿐이고, 그 밖의 줄은 `구역에 읽지 못하는 줄이 있다 (N)` 으로 [3/10] 실패다 (M51 ~ M53)"
  - "README (e) 는 `package:woody_lints/` 뒤의 후보를 모두 모아 `<이름>.yaml` 꼴이 아닌 것과, 이름이 woody_lints 가 아닌 패키지의 `.yaml` · `.yml` 주소를 따로 실패시킨다 (M54 · M55)"
  - "fencedLines 는 여는 펜스의 문자(백틱 · `~`)와 길이를 기억하고 같은 문자만으로 된 · 같거나 긴 줄에서만 닫는다 (M56 ~ M58)"
  - "lib/base.yaml 의 `analyzer:` · `language:` 줄에 값이 붙었거나 `language:` 블록에 `<이름>: true|false` 가 아닌 줄이 있으면 종료 코드 70, 줄 끝 주석을 단 블록 꼴은 받는다 (M59 ~ M62)"

patterns-established:
  - "verify.dart 의 마커 구역 reader 둘(readRulesMdBlock · readBulletBlock)이 모두 닫힌 줄 규칙을 쓴다"

requirements-completed: [VERIFY-06]

coverage:
  - id: D1
    description: "RULES.md 표 구역 안의 읽지 못하는 줄(backtick 없는 행 · 대문자 이름 · 불릿 · 행이 있는 구역의 `없음 — …`)이 [3/10] 실패로 잡히고, 지금 RULES.md 로는 10개 중 10개다"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-08-PLAN.md Task 1 <automated> (복제본 M51 ~ M53 + 기준 실행 10/10)"
        status: pass
    human_judgment: false
  - id: D2
    description: "tool/measure_rules.dart 의 readRulesTable 문서 주석이 '보다 느슨한 옛 규약' 을 말하고, c06d8d5 대비 바뀐 줄은 모두 `///` 줄이다"
    verification:
      - kind: other
        ref: "05-08-PLAN.md Task 1 <automated> (git diff -U0 c06d8d5 의 비 `///` 줄 0)"
        status: pass
    human_judgment: false
  - id: D3
    description: "README 의 꼴이 틀린 주소(codegen.yml) · 다른 패키지의 주소(woody_lint · woody-lints) · `~~~` 와 긴 펜스 블록 안의 낡은 ref 가 [3/10] 실패로 잡힌다"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-08-PLAN.md Task 2 <automated> (복제본 M54 ~ M58 + 기준 실행 10/10)"
        status: pass
    human_judgment: false
  - id: D4
    description: "lib/base.yaml 의 analyzer: · language: flow 표기와 읽지 못하는 옵션 줄이 종료 코드 70 으로 멈추고, 줄 끝 주석을 단 블록 꼴은 [3/10] 비교로 간다"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-08-PLAN.md Task 3 <automated> (복제본 M59 ~ M62 + 기준 실행 10/10)"
        status: pass
    human_judgment: false
  - id: D5
    description: "example/README.md 의 소절 (05-08) — M51 ~ M62 의 실제 결과 기록과 113행 · 116행 덧붙임의 문장"
    verification:
      - kind: other
        ref: "Task 1 ~ 3 <automated> 의 행 수 · 문구 grep, 절대 경로 grep 0줄"
        status: pass
    human_judgment: true
    rationale: "기록 문장의 정확성('돌린 것' 과 '코드에서 읽은 것 · 따져 본 것' 의 구분)과 표의 렌더링은 grep 이 보지 못한다"

duration: 30min
completed: 2026-10-14
status: complete
---

# Phase 5 Plan 08: gap 수정 — RULES.md 표 · README 주소 · 펜스 · analyzer 옵션 reader Summary

**`tool/verify.dart` 의 `RULES.md` 표 reader · README 주소 검사 (e) · 펜스 판정 `fencedLines` · 켠 analyzer 옵션 reader 가 읽지 못하는 입력을 건너뛰지 않고 `[3/10]` 실패나 종료 코드 70 으로 알린다 — 지워 보기 M51 ~ M62 를 복제본에서 돌려 기록했고, `tool/measure_rules.dart` 는 문서 주석만 고쳤다**

## Performance

- **Duration:** 30 min
- **Started:** 2026-10-14T01:48:44Z
- **Completed:** 2026-10-14T02:19:23Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments

- `readRulesMdBlock` 의 줄 규칙: 머리 줄(0번째 줄, 첫 칸에 backtick 없음) · 구분 줄(1번째 줄) · 첫 칸이 `` `[a-z0-9_-]+` `` 하나인 데이터 행 · 데이터 행이 없는 구역의 `없음 — …` 한 줄만 받는다. 그 밖은 `` `RULES.md` 의 `woody:<구역>` 구역에 읽지 못하는 줄이 있다 (N): `` 블록으로 실패 (소유자 승인 Q1). 옛 "첫 칸의 이름이 둘 이상" 문구는 없어졌다.
- `tool/measure_rules.dart` 의 `readRulesTable` 문서 주석이 "`readRulesMdBlock` 보다 느슨한 옛 규약" 이라고 사실대로 말한다 — 코드 줄은 하나도 바뀌지 않았다 (R2-Q4).
- (e): `package:woody_lints/` 뒤의 후보를 넓게 모아 `<이름>.yaml` 꼴이 아닌 것을 따로 실패시키고(WR-01), `package:<이름>/….ya?ml` 가운데 이름이 `woody_lints` 가 아닌 것도 실패시킨다(W1, R2-Q3 — hyphen 이름도 후보).
- `fencedLines`: 백틱 · `~` 펜스의 문자와 길이를 기억하고 같은 문자만으로 된 · 같거나 긴 줄에서만 닫는다 (WR-03).
- `enabledLanguageOptions(String options, {required String shownAs})`: `analyzer:` · `language:` 줄의 flow 표기와 `language:` 블록의 읽지 못하는 줄에서 파일 이름 · 행 · 원문을 담은 `FormatException` (70). (c) 는 `final enabledOptions = enabledLanguageOptions(baseText, shownAs: rulesFile);` 로 부른다 (R2-Q2).
- 지금 README · `RULES.md` · `lib/base.yaml` 로는 세 복제본의 기준 실행 모두 종료 코드 0 · `점검 통과 (10개 중 10개)` 다.

### 지워 보기 M51 ~ M62 의 실제 결과 (모두 `git clone --local` 복제본, 2026-10-14, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9)

| # | 변경 | 종료 코드 | 실패한 단계 | 찍힌 줄 (요지) | 시간 |
|---|------|-----------|-------------|----------------|------|
| M51 | `RULES.md` 켠 규칙 구역 끝에 backtick 없는 행 `\| prefer_mixin \| 성능 \| … \|` | 1 | `[3/10]` 만 | `` `RULES.md` 의 `woody:enabled-rules` 구역에 읽지 못하는 줄이 있다 (1) `` + 그 행, 표 비교 블록 없음, `점검 실패 (10개 중 1개)` | 23초 |
| M52 | 같은 자리에 `` \| `Prefer_Mixin` \| … \| `` | 1 | `[3/10]` 만 | 같은 머리 줄 `(1)` + 그 행, 표 비교 블록 없음 | 22초 |
| M53 | 같은 자리에 `` - `prefer_mixin` `` 과 `없음 — 켠 규칙이 없다.` | 1 | `[3/10]` 만 | 같은 머리 줄 `(2)` + 두 줄, 표 비교 블록 없음 | 23초 |
| M54 | README 78행 `codegen.yaml` → `codegen.yml` | 1 | `[3/10]` 만 | `` … `<이름>.yaml` 꼴이 아닌 것이 있다 (1) `` + `package:woody_lints/codegen.yml`, `lib/` 에 없다는 블록 없음 | 23초 |
| M55 | 67행 `woody-lints/base.yaml` · 68행 `woody_lint/riverpod.yaml` | 1 | `[3/10]` 만 | `` `woody_lints` 가 아닌 패키지의 `.yaml` 주소가 있다 (2) `` + 두 주소 | 24초 |
| M56 | 「설치」 블록을 `~~~yaml` / `~~~` 로, `ref: v1.9.0` | 1 | `[3/10]` 만 | `ref: vX.Y.Z` 예시가 다르다 + `ref: v1.9.0` | 23초 |
| M57 | 같은 블록을 백틱 넷으로 열고 닫고 안쪽에 백틱 셋 두 줄, `ref: v1.9.0` | 1 | `[3/10]` 만 | M56 과 같음 | 24초 |
| M58 | 같은 블록을 `~~~` 로 열고 닫고 안쪽에 백틱 셋 두 줄, `ref: v1.9.0` | 1 | `[3/10]` 만 | M56 과 같음 | 23초 |
| M59 | `lib/base.yaml` 끝에 `analyzer:` / `  language: {strict-casts: true}` | 70 | 단계 줄 없음 (stdout 0 바이트) | stderr: `` lib/base.yaml 의 97행: `language:` 줄에 값이 붙어 있다 — … : language: {strict-casts: true} `` | 3초 |
| M60 | 끝에 `analyzer: {language: {strict-casts: true}}` | 70 | 단계 줄 없음 | stderr: `` lib/base.yaml 의 96행: `analyzer:` 줄에 값이 붙어 있다 — … `` | 3초 |
| M61 | 끝에 `analyzer:` / `  language:` / `    strict-casts: yes` | 70 | 단계 줄 없음 | stderr: `` lib/base.yaml 의 `language:` 블록의 98행을 읽지 못했다 — … : strict-casts: yes `` | 3초 |
| M62 | 끝에 줄 끝 주석을 단 블록 꼴 (`strict-casts: true # 켬`) | 1 | `[3/10]` 과 정답지 단계 다섯 (`recommended` 는 통과) | `[3/10]`: `` 켠 analyzer 옵션 표와 … 가 다르다. `` + `+ strict-casts  (base.yaml 에만)`; 정답지 단계: 실제 종료 코드 3 · `lib/strict_rules.dart:6  error  invalid_assignment`; `점검 실패 (10개 중 6개)`; stderr 에 `파일 모양이 예상과 다르다` 없음 | 23초 |

복제본의 첫 실행(plugin 준비 포함)은 69초 · 81초 · 69초, 되돌린 뒤의 보통 실행은 22 ~ 23초 · 10개 중 10개였다.

## Task Commits

1. **Task 1: RULES.md 표 reader 의 줄 규칙, readRulesTable 문서 주석, M51 ~ M53** - `812c477` (fix)
2. **Task 2: (e) 주소의 꼴 · 패키지 이름, fencedLines 의 문자 · 길이, M54 ~ M58** - `63fe3d9` (fix)
3. **Task 3: enabledLanguageOptions 의 flow 표기 · 읽지 못하는 옵션 줄 → 70, M59 ~ M62** - `a14be4f` (fix)

**Plan metadata:** 이 SUMMARY 와 함께 커밋 (docs)

## Files Created/Modified

- `tool/verify.dart` - `readRulesMdBlock` 줄 규칙, (c) 의 malformed 문구, (e) 의 꼴 · 다른 패키지 블록, `fencedLines`, `enabledLanguageOptions` 의 시그니처 · 예외와 (c) 의 호출, `checkShippedComposition` 머리 문서 주석의 (c) · (e) 불릿
- `tool/measure_rules.dart` - `readRulesTable` 문서 주석 (`///` 줄만)
- `example/README.md` - 113행 · 116행 덧붙임, 소절 `### 추가 실측 — RULES.md 표 · analyzer 옵션 · README 주소 · 펜스의 꼴 (05-08)` (M51 ~ M62)

## Decisions Made

- 계획의 설계 선택대로 `없음 — …` 줄은 데이터 행이 없는 구역에서 하나일 때만 받는다 — 지금 `woody:enabled-options` 의 꼴이고 `RULES.md` 는 고치지 않았다.
- `readRulesMdBlock` 은 읽지 못한 줄을 구역 안의 줄 순서대로 돌려준다 (`없음 — …` 줄을 끝에 따로 덧붙이지 않고 자리로 정렬) — M53 의 두 줄이 원문 순서로 찍힌다.
- M54 ~ M62 의 "고치기 전" 수치는 다시 재지 않았다 — 05-REVIEW.md WR-01 · WR-03 의 재현, 05-VERIFICATION.md W1 · plan-checker 의 실행, 소유자의 함수 단위 확인을 출처로 적었다.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `example/README.md` 113행(종료 코드 표의 행) 덧붙임의 `|` 를 `\|` 로 적음**
- **Found during:** Task 3
- **Issue:** 계획이 113행에 덧붙이라고 한 글자 `` `language:` 블록에 `<이름>: true|false` 가 아닌 줄이 있는 경우 `` 는 GFM 표 칸 안에 있어, code span 안의 `|` 도 칸을 나눈다 — 그대로 적으면 그 행의 나머지(` 가 아닌 줄이 …` 부터 행 끝까지)가 넘치는 칸으로 버려져 렌더링이 깨진다.
- **Fix:** 113행에는 `true\|false` 로 적었다 (GFM 에서 `|` 로 보인다). 같은 뜻의 문장을 (05-08) 소절의 읽는 법 불릿(표 밖)에 `` `language:` 블록에 `<이름>: true|false` 가 아닌 줄이 있는 경우 (M61) `` 로 적었다. M51 · M52 · M59 ~ M61 의 표 칸 안의 `|` 도 `\|` 로 적고, 소절 머리에 "표 칸 안의 `\|` 는 원문의 `|` 다" 를 적었다.
- **Files modified:** example/README.md
- **Verification:** Task 3 `<automated>` 의 `grep -qF '`language:` 블록에 `<이름>: true|false` 가 아닌 줄이 있는 경우'` 는 적힌 그대로 통과한다 — 다만 그 grep 이 맞는 줄은 113행이 아니라 소절의 불릿(441행)이다. 113행에 덧붙임이 있는 것은 `grep -nF '`<이름>: true\|false` 가 아닌 줄이 있는 경우'` 로 따로 확인했다 (113행 1줄).
- **Committed in:** `a14be4f`

세 task 의 `<automated>` 는 모두 적힌 그대로 통과했다 (고친 판 없음):

| Task | 적힌 그대로 (커밋 전) | 적힌 그대로 (세 커밋 뒤 · 끝의 재실행) |
|------|----------------------|--------------------------------------|
| 1 | rc 0 | rc 0 |
| 2 | rc 0 | rc 0 |
| 3 | rc 0 | rc 0 |

**Total deviations:** 1 auto-fixed (Rule 1 — 문서 렌더링)
**Impact on plan:** 기록의 뜻은 같다. 113행의 글자만 계획의 글자와 `\` 하나가 다르다.

## Issues Encountered

None. 지워 보기는 모두 복제본에서 했고 작업 트리의 `README.md` · `lib` · `RULES.md` 는 변형하지 않았다. 끝에 `git diff --quiet 209e3af -- lib` · `git diff --quiet 76dee2f -- RULES.md` · `git diff --quiet HEAD -- README.md` 가 참이다 (세 `<automated>` 의 단언). 저장소 파일 · 커밋 메시지에 실제 홈 폴더 경로나 임시 폴더 경로는 0줄이다.

## 열린 채 남는 것

- `tool/measure_rules.dart` 의 `readRulesTable` 동작 — 여전히 `|` 밖의 줄과 backtick 없는 첫 칸을 건너뛴다 (소유자 결정 R2-Q4, 문서 주석만 고침).
- `tool/verify.dart` 의 `readUpstreamRules` 안 `readSet` 동작 — `    - 이름` 꼴이 아닌 줄을 건너뛴다 (소유자 결정 R2-Q4).
- (d) 의 분류 검사 (IN-07 의 다른 안) — 넣지 않았다 (P-07).
- M57 · M58 이 가른다고 적은 "길이 · 문자를 보지 않는 구현" 과 M52 의 "대소문자를 무시하는 구현" 은 따져 본 것이고 그런 구현을 돌리지는 않았다.
- VERIFY-06 의 완료 표시는 05-09 가 한다 (같은 ID 를 선언한 마지막 gap plan).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-09 (plugin 선언의 따옴표 · 고정 버전 · 맵 순서 · 범위, pubspec 의 따옴표, 문장 · 처리 기록 · push, M63 ~ M67) 준비됨. 05-09 Task 3 이 찾는 커밋 제목 `fix(tool): README 의 꼴이 틀린 프리셋 주소 · 다른 패키지 주소를` 은 `63fe3d9` 이고 `tool/verify.dart` 를 바꾼다.

---
*Phase: 05-documentation*
*Completed: 2026-10-14*

## Self-Check: PASSED

- FOUND: tool/verify.dart, tool/measure_rules.dart, example/README.md
- FOUND: 812c477, 63fe3d9, a14be4f (HEAD 의 조상)
