---
phase: 05-documentation
plan: 10
subsystem: testing
tags: [verify-dart, readme, gap-closure, closed-key-list, marker-section, docs-narrowing]

requires:
  - phase: 05-documentation
    provides: "05-09 의 tool/verify.dart (644897f) — declaredRuleNames · enabledLanguageOptions · readShippedPluginConstraint · fencedLines · readMarkerBlock · readBulletBlock, example/README.md 의 M1 ~ M67"
provides:
  - "tool/verify.dart 의 allowedTopLevelKeys · allowedChildKeys · findUnexpectedKeys 와 [3/N] (a′) — 조각마다 받는 최상위 키(와 codegen 의 analyzer: · riverpod 의 plugins: 바로 아래 키)의 닫힌 목록"
  - "tool/verify.dart 의 findMarkerRange · markFencedLines · findListLinesOutsideMarkers 와 [3/N] (d′) — README 표시 구역이 든 절의 구역 밖 목록 줄"
  - "README 378 · 382행, example/README.md 116 · 358 · 395 · 436행, tool/verify.dart 의 (e) · (f) · (g) 주석 줄 — 실제 검사 범위"
  - "example/README.md 의 소절 (05-10) 둘 — 지워 보기 M68 ~ M78 과 회귀 확인"
affects: [05-11, 05-verification, 06-release]

actuals:
  tokens: 13444
  tasks: 3
  commits: 3
plan_head_before: 1b49c74199c041eff6ef858d8d6af298ffcb0cb2
plan_head_after: d2d74c49b983c141b51eb82ca9232d8f38d90341

tech-stack:
  added: []
  patterns:
    - "배포 조각이 받는 키는 닫힌 목록으로 둔다 — 목록 밖의 키(읽지 못하는 철자 포함)는 YAML 로 올바른 정책 위반이라 종료 코드 70 이 아니라 [3/N] 실패로 알리고, 예외 없이 뒤 검사가 그대로 돈다"
    - "README 의 마커 구역 검사는 구역 안(reader)과 구역이 든 절의 구역 밖(목록 줄)을 따로 본다 — 절의 경계는 제목 이름이 아니라 마커에서 가장 가까운 제목으로 잡고, 펜스 안의 # 줄은 제목이 아니다"
    - "검사를 넓히지 않기로 한 자리는 문서 문장과 코드 주석을 구현이 실제로 보는 범위로 좁히고, 코드 줄이 앞 커밋과 같음을 주석 줄을 뺀 비교로 보인다"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - README.md
    - example/README.md

key-decisions:
  - "조각의 닫힌 목록(allowedTopLevelKeys · allowedChildKeys)은 종료 코드 70 이 아니라 [3/10] 실패로 알린다 — 예외 없이 블록만 더해 앞 기록의 70 (M45 · M36 꼴 · M34 · M60 · M59 · M61 · M66) 과 실패 (M46 · M62) 가 그대로 남는다 (G2-Q1)"
  - "lib/riverpod.yaml 의 plugins: 바로 아래는 riverpod_lint 하나만 받는다 — 다른 plugin 키(따옴표 키 포함)는 [3/10] 실패 (G2-Q4, M78)"
  - "README 표시 구역이 든 절은 start 마커 앞의 가장 가까운 제목 다음 줄부터 end 마커 뒤의 첫 제목 앞까지다 — 제목 수준을 가리지 않고, 펜스 안의 # 줄은 제목이 아니며, 목록 줄은 - · * · + · 1. · 1) 과 인용 안의 목록 (G2-Q3, M74 ~ M77)"
  - "(e) · (f) · (g) 는 코드를 넓히지 않고 문장 다섯 줄과 tool/verify.dart 의 주석 줄만 좁혔다 — tool/verify.dart 의 주석이 아닌 줄은 Task 2 커밋과 글자가 같다 (G2-Q2 · G2-Q5)"

patterns-established:
  - "조각을 새로 만들면 ruleCheckTargets · expectedLibYamls · allowedTopLevelKeys 를 함께 고친다 — 셋의 문서 주석이 서로를 가리킨다"
  - "마커 문자열은 findMarkerRange 한 곳에만 둔다 — readMarkerBlock 과 findListLinesOutsideMarkers 가 쓴다; 펜스 규칙은 fencedLines 와 markFencedLines 를 함께 고친다"

requirements-completed: [VERIFY-06, DOCS-06]

coverage:
  - id: D1
    description: "다른 철자의 linter 키(M68 · M69 · M70) · codegen 의 analyzer: language: (M71) · formatter: (M72) · 열 0 밖의 최상위 키(M73) 가 각각 종료 코드 1 · [3/10] 만 실패 · 정해진 블록과 항목 줄 · 10개 중 1개이고, M68 ~ M70 에 다른 조각의 규칙 블록이 없다"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-10-PLAN.md Task 1 <automated> (복제본 기준 실행 + M68 ~ M73 · M78 + 회귀 입력 11개) — 커밋 02966c4 직후 rc 0"
        status: pass
    human_judgment: false
  - id: D2
    description: "lib/riverpod.yaml 의 plugins: 아래 custom_lint · 따옴표 키(M78) 가 종료 코드 1 · [3/10] 의 plugins: 바로 아래 블록 (2) · 항목 줄 둘이고 최상위 블록이 없다"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-10-PLAN.md Task 1 <automated>"
        status: pass
    human_judgment: false
  - id: D3
    description: "회귀 입력 11개 — M45 · M36 꼴 · M34 · M60 · M59 · M61 · M66 은 종료 코드 70 · stdout 0 바이트 · 앞 기록의 stderr, M46 은 블록 둘로 실패, M62 는 + strict-casts 로 실패하고 닫힌 목록 블록 없음, M65 · M63 은 10개 중 10개"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-10-PLAN.md Task 1 <automated>"
        status: pass
    human_judgment: false
  - id: D4
    description: "README 표시 구역이 든 절의 구역 밖 목록 줄 — M74 (1) · M75 (5) · M77 (1, 펜스 안 줄 제외) 이 [3/10] 만 실패, M76 (앞 · 다음 절) 은 10개 중 10개, start 마커 삭제 · 구역 안 옛 꼴은 각자의 블록만"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-10-PLAN.md Task 2 <automated> (복제본 기준 실행 + M74 ~ M77 + 회귀 입력 둘) — 커밋 204e401 직후 rc 0"
        status: pass
    human_judgment: false
  - id: D5
    description: "README 378 · 382행, example/README.md 116 · 358 · 395 · 436행, tool/verify.dart 의 (e) · (f) · (g) 주석 줄이 실제 검사 범위를 말하고, tool/verify.dart 의 코드 줄은 Task 2 커밋과 같으며 여덟 구간의 코드 줄은 644897f 와 같다; 작업 트리 검증 10개 중 10개"
    requirement: DOCS-06
    verification:
      - kind: other
        ref: "05-10-PLAN.md Task 3 <automated> — 커밋 d2d74c4 직후 rc 0 (24초)"
        status: pass
    human_judgment: false
  - id: D6
    description: "고친 README · example/README.md 문장이 읽는 사람에게 실제 검사 범위를 오해 없이 전하는지 (문장의 읽힘)"
    requirement: DOCS-06
    verification: []
    human_judgment: true
    rationale: "자동 검증은 글자의 있고 없음만 본다 — 문장이 소유자에게 정확하고 읽기 쉬운지는 사람이 판단한다"

duration: 27min
completed: 2026-10-14
status: complete
---

# Phase 5 Plan 10: 조각의 닫힌 목록 · 구역 밖 목록 줄 · (e) ~ (g) 문장 좁히기 Summary

**`[3/10]` 이 조각마다 받는 키의 닫힌 목록(codegen 은 `analyzer` → `errors` · `exclude`, riverpod 은 `plugins` → `riverpod_lint`, base 는 `include` · `linter` · `analyzer`)과 README 표시 구역이 든 절의 구역 밖 목록 줄을 실패로 알리고, (e) · (f) · (g) 의 설명은 코드를 넓히지 않고 실제 범위로 좁혔다 — 05-VERIFICATION 2회차 gap 과 05-REVIEW WR-10 을 닫는다**

## Performance

- **Duration:** 27 min
- **Started:** 2026-10-14T05:59:58Z
- **Completed:** 2026-10-14T06:27:15Z
- **Tasks:** 3
- **Files modified:** 3 (`tool/verify.dart`, `README.md`, `example/README.md`)

## Accomplishments

- **gap 을 닫았다.** `lib/codegen.yaml` · `lib/riverpod.yaml` 에 `linter :` · `"linter":` 로 적은 규칙(M68 ~ M70)이 이제 `[3/10]` 실패다 — 고치기 전에는 셋 모두 10개 중 10개였다 (검증자의 기록). `declaredRuleNames` 의 정규식은 그대로이고, 화면에 다른 조각의 규칙 블록이 없다 (철자 정규식으로 고친 구현을 가른다).
- **WR-10 을 닫았다.** codegen 의 `analyzer: language:` (M71) 와 `formatter:` (M72) 가 `[3/10]` 실패다. 열 0 에서 시작하지 않는 최상위 키(M73)와 riverpod 의 다른 plugin 키(M78, G2-Q4)도 실패다.
- **앞 기록이 그대로다.** 회귀 입력 11개가 앞 기록의 종료 코드 · stderr · 실패 블록을 그대로 냈다 — 닫힌 목록은 예외를 던지지 않고 뒤 검사를 건너뛰게 하지 않는다.
- **표시 구역 밖 목록 줄 (G2-Q3).** end 마커 뒤 불릿(M74)과 `*` · `+` · `1.` · `1)` · 인용 안 목록(M75), 펜스 뒤 불릿(M77)이 실패이고, 앞 절 · 다음 절의 불릿(M76)은 통과다.
- **문장 · 주석 좁히기 (G2-Q2 · G2-Q5).** README 382행, `example/README.md` 116 · 358 · 395 · 436행, `tool/verify.dart` 의 주석 줄이 (e) · (f) · (g) 가 실제로 보는 범위만 말한다. 코드 줄은 그대로다.

## Task Commits

1. **Task 1 (tracer): 조각의 닫힌 목록 (a′), README 378행, M68 ~ M73 · M78 · 회귀 입력 11개** — `02966c4` (fix)
2. **Task 2: 표시 구역이 든 절의 구역 밖 목록 줄 (d′), M74 ~ M77 · 회귀 입력 둘** — `204e401` (fix)
3. **Task 3: (e) · (f) · (g) 를 말하는 문장 다섯 줄과 주석 줄을 실제 범위로** — `d2d74c4` (docs)

커밋 제목 머리 확인: `git log --format='%H %s' -- tool/verify.dart` 에서 `fix(tool): 조각마다 받는 최상위 키와 ` 는 `02966c4`, `fix(tool): README 표시 구역이 든 절에서 구역 밖의 목록 줄을 ` 는 `204e401` 을 찾는다.

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP · REQUIREMENTS 를 담은 `docs(05-10): …` 커밋

## 자동 검증 (`<automated>` 를 계획에 적힌 그대로)

| Task | 돌린 때 | 그대로 rc | 고친 판 rc | 이유 |
|------|---------|-----------|------------|------|
| 1 | 커밋 `02966c4` 직후 (복제본 실행 19번) | 0 | — | 고친 판이 필요 없었다 |
| 2 | 커밋 `204e401` 직후 (복제본 실행 7번) | 0 | — | 고친 판이 필요 없었다 |
| 3 | 커밋 `d2d74c4` 직후 (작업 트리 실행 1번, 24초) | 0 | — | 고친 판이 필요 없었다 |

Task 1 은 tracer 다 — `<verify>` 가 `<automated>` 뿐이고 `human_verify_mode` 가 `end-of-phase` 라 다시 돌려 통과한 뒤 Task 2 로 넘어갔다. 각 task 의 기록용 실행은 같은 입력을 따로 만든 스크립트로 복제본에서 먼저 돌렸고 (아래 결과), `<automated>` 는 그 뒤에 따로 돌렸다.

## 지워 보기 — 실제 결과 (복제본, 2026-10-14, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9)

### Task 1 — 닫힌 목록

| 입력 | 종료 코드 | 실패한 단계 · 찍힌 줄 | 시간 |
|------|-----------|------------------------|------|
| 기준 실행 | 0 | `점검 통과 (10개 중 10개)` | 77초 (plugin 준비 포함) |
| M68 codegen 끝 `linter :` | 1 | `[3/10]` 만 — `` `lib/codegen.yaml` 의 최상위에 받지 않는 줄이 있다 (1) — 받는 키: analyzer `` · `  10행: linter :`, 규칙 블록 없음, 10개 중 1개 | 23초 |
| M69 codegen 끝 `"linter":` | 1 | `[3/10]` 만 — 같은 블록 · `  10행: "linter":`, 규칙 블록 없음, 10개 중 1개 | 23초 |
| M70 riverpod 끝 `linter :` | 1 | `[3/10]` 만 — `` `lib/riverpod.yaml` 의 최상위에 받지 않는 줄이 있다 (1) — 받는 키: plugins `` · `  6행: linter :`, 규칙 블록 없음, 10개 중 1개 | 22초 |
| M71 codegen `analyzer:` 아래 `language:` | 1 | `[3/10]` 만 — `` `lib/codegen.yaml` 의 `analyzer:` 바로 아래에 받지 않는 줄이 있다 (1) — 받는 키: errors · exclude `` · `  5행:   language:`, 최상위 블록 없음 | 23초 |
| M72 codegen 끝 `formatter:` | 1 | `[3/10]` 만 — 최상위 블록 (1) · `  10행: formatter:` | 22초 |
| M73 codegen 전체 두 칸 들여쓰기 + `  linter:` | 1 | `[3/10]` 만 — 최상위 블록 (1) · `  4행:   analyzer:`, `[2/10]` 포함 나머지 통과 | 22초 |
| M78 riverpod `plugins:` 아래 `custom_lint` · `"zz_quoted_plugin"` | 1 | `[3/10]` — `` `lib/riverpod.yaml` 의 `plugins:` 바로 아래에 받지 않는 줄이 있다 (2) — 받는 키: riverpod_lint `` · `  6행:   custom_lint: ^0.7.0` · `  7행:   "zz_quoted_plugin": ^0.1.0`, 최상위 블록 없음, stderr 에 `파일 모양이 예상과 다르다` 없음. 그리고 `[5/10]` · `[6/10]` · `[8/10]` · `[10/10]` 이 plugin 준비 실패 (원인 줄: `zz_quoted_plugin` 을 pub.dev 에서 찾지 못해 version solving 실패), 10개 중 5개 | 13초 |
| 회귀 M45 (flow `linter: {…}`) | 70 | stdout 0 바이트, stderr `lib/codegen.yaml 의 10행: `linter:` 줄에 값이 붙어 있다` | 4초 |
| 회귀 M46 (블록 꼴 `linter: # …`) | 1 | `[3/10]` 만 — 최상위 블록 (1) · `  10행: linter: # 블록 꼴 — 줄 끝 주석은 받는다` 과 `` `lib/codegen.yaml` 에 규칙이 있다 (1) `` 둘, 10개 중 1개 | 22초 |
| 회귀 M36 꼴 (`avoid_print: true`) | 70 | stdout 0 바이트, stderr `` lib/codegen.yaml 의 `linter:` 블록의 12행을 읽지 못했다 `` | 3초 |
| 회귀 M34 (선언 줄 삭제) | 70 | stdout 0 바이트, stderr `lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다` | 3초 |
| 회귀 M60 | 70 | stdout 0 바이트, stderr `lib/base.yaml 의 96행: `analyzer:` 줄에 값이 붙어 있다` | 4초 |
| 회귀 M59 | 70 | stdout 0 바이트, stderr `lib/base.yaml 의 97행: `language:` 줄에 값이 붙어 있다` | 3초 |
| 회귀 M61 | 70 | stdout 0 바이트, stderr `` lib/base.yaml 의 `language:` 블록의 98행을 읽지 못했다 `` | 3초 |
| 회귀 M62 | 1 | `[3/10]` 의 `+ strict-casts  (base.yaml 에만)` 과 정답지 단계 다섯의 `invalid_assignment`, 10개 중 6개 (앞 기록과 같다), 닫힌 목록 블록 없음 | 23초 |
| 회귀 M66 (범위 제약) | 70 | stdout 0 바이트, stderr `꼴만 받는다` 문구 | 3초 |
| 회귀 M65 (맵 꼴) | 0 | 10개 중 10개 | 22초 |
| 회귀 M63 (따옴표 선언) | 0 | 10개 중 10개 | 23초 |
| 되돌린 뒤 | 0 | 10개 중 10개 | 59초 |

### Task 2 — 구역 밖 목록 줄

| 입력 | 종료 코드 | 실패한 단계 · 찍힌 줄 | 시간 |
|------|-----------|------------------------|------|
| 기준 실행 (89 · 93 · 188 · 190행 전제 확인) | 0 | 10개 중 10개 | 69초 (plugin 준비 포함) |
| M74 end 마커 뒤 `` - `bogus_after_marker` `` | 1 | `[3/10]` 만 — `` `README.md` 의 `woody:readme-rules` 표시 구역이 든 절에 구역 밖의 목록 줄이 있다 (1): `` · `` 189행: - `bogus_after_marker` ``, 이름 비교 블록 없음 | 24초 |
| M75 `*` · `+` · `1.` · `1)` · `> -` | 1 | `[3/10]` 만 — (5) · 93 · 190 · 191 · 192 · 193행 | 23초 |
| M76 앞 절 끝 · 다음 절 첫 줄의 불릿 | 0 | 10개 중 10개 | 23초 |
| M77 펜스(`# …` · `- in_fence`) 뒤 불릿 | 1 | `[3/10]` 만 — (1) · `` 193행: - `bogus_after_fence` ``, `in_fence` 없음 | 23초 |
| 회귀 start 마커 삭제 | 1 | `구역이 없다` 블록만, 10개 중 1개 | 23초 |
| 회귀 구역 안 옛 꼴 | 1 | `구역에 읽지 못하는 줄이 있다 (1)` 블록만, 10개 중 1개 | 22초 |
| 되돌린 뒤 | 0 | 10개 중 10개 | 23초 |

두 복제본 모두 끝에 `git status --short` 빈 출력, `README.md` · `lib` · `RULES.md` (Task 1 은 `pubspec.yaml` · `fixtures` 도) 를 HEAD 와 견준 `git diff --stat` 빈 출력, `build/woody_rule_check` 없음을 확인하고 지웠다.

## Files Created/Modified

- `tool/verify.dart` — 상수 `allowedTopLevelKeys` · `allowedChildKeys`, 함수 `findUnexpectedKeys` · `findMarkerRange` · `markFencedLines` · `findListLinesOutsideMarkers`, `checkShippedComposition` 의 (a′) · (d′), `readMarkerBlock` 이 `findMarkerRange` 를 쓴다 (동작 같음), (e) · (f) · (g) 를 말하는 주석 줄
- `README.md` — 「이 저장소를 고치는 사람에게」 378행 (닫힌 목록), 382행 마지막 문장 (견주는 범위)
- `example/README.md` — 116행 덧붙임 둘과 고친 구절 넷, 358 · 395 · 436행, 소절 `### 추가 실측 — 조각의 최상위 키와 `analyzer:` 아래 키의 닫힌 목록 (05-10)` · `### 추가 실측 — 표시 구역이 든 절의 구역 밖 목록 줄 (05-10)`

## 고친 문장 · 주석 자리 (05-11 의 처리 기록이 가리킬 것)

- **README 378행** (Task 1, `02966c4`): "조각마다 받는 최상위 키가 정해져 있다 — …" 로 바꿈. 받는 키, `[3/10]` 실패가 되는 입력(다른 조각의 `linter:`, 철자가 다른 키, `formatter:`, 열 0 밖의 키, codegen 의 `language:`, riverpod 의 다른 plugin), 종료 코드 70 이 되는 flow 표기.
- **README 382행** (Task 3, `d2d74c4`): 마지막 문장 "검증 명령이 모두 견준다 (…)" → `[4/10]` 은 `fixtures/overrides` 의 `version:` 을, `[3/10]` 은 펜스 코드 블록 안에서 키가 줄 머리에 오는 `ref:` · `version:` · `riverpod_lint:` 줄의 값을 견주고, flow 표기 안의 키 · 네 칸 들여 쓴 코드 블록 · 인용 안의 펜스는 견주지 않는다 (WR-08 · WR-09).
- **`example/README.md` 116행** (Task 3): (e) 의 주소 구절 둘(`package:woody_lints/` · `package:` 로 정확히 시작, 문장 부호의 결과 — WR-07 · IN-08), (f) · (g) 의 구절 둘(펜스 코드 블록 안 줄 머리 키, flow · 들여 쓴 블록 · 인용 안 펜스는 보지 않음 — WR-08 · WR-09). Task 1 · 2 가 같은 줄에 덧붙인 구절 둘은 따로다.
- **`example/README.md` 358행** (Task 3): "(e) 는 README 전체에서 `package:woody_lints/` 로 시작하는 주소를 모은다" (WR-07).
- **`example/README.md` 395행** (Task 3): (f) · (g) 불릿의 머리와 끝 문장 (WR-08 · WR-09).
- **`example/README.md` 436행** (Task 3): (e) 불릿의 머리, 후보의 끝 글자, 다른 패키지 주소의 조건, 범위 밖의 꼴 문장 (WR-07 · IN-08).
- **`tool/verify.dart` 주석 줄** (Task 3): 머리 주석 6행의 README 구절, `readmeFile` · `fencedLines` · `unquotedScalar` · `pubspecReleaseVersion` · `checkShippedComposition` 의 문서 주석 (`fencedLines` 와 `checkShippedComposition` 앞에 두 줄씩 더함), 함수 안 `//` 주석 일곱 (`(d) ~ (g)`, `(e)` 둘, `(f) · (g)`, `(f)`, `(g)` 둘). 주석이 아닌 줄은 Task 2 커밋과 같다.

## Decisions Made

- 닫힌 목록은 `[3/10]` 실패이고 종료 코드 70 이 아니다 — 계획 `<design>` 첫 절 그대로. 회귀 입력 11개가 그 확인이다.
- `findUnexpectedKeys` 는 열 0 줄을 볼 때마다 아래 키 기억(지금 키 · 바로 아래 들여쓰기)을 지운다 — 받지 않는 최상위 줄 아래의 줄은 다시 담지 않는다 (M68 은 `(1)` 이고 `rules:` 줄을 따로 담지 않는다).
- (a′) 의 안내 줄은 지역 상수 `allowedKeysHint` 하나로 두어 최상위 · 아래 블록이 함께 쓴다.

## Deviations from Plan

None — plan executed exactly as written. 세 `<automated>` 모두 적힌 그대로 종료 코드 0 이었고 고친 판이 필요 없었다.

계획과 다르게 나온 관찰 하나 (단언 대상이 아니라 기록만 한 것): M78 의 전체 실행에서 plugin 을 쓰는 정답지 단계 넷이 plugin 준비 실패로 함께 실패한 것은 계획이 적은 대로이나, 원인 줄은 계획이 예상한 `custom_lint ^0.7.0` 과 `riverpod_lint ^3.1.9` 의 의존성 충돌이 아니라 따옴표 키의 이름 `zz_quoted_plugin` 을 pub.dev 에서 찾지 못한 것이었다 — analyzer 가 따옴표 키를 그 이름의 plugin 으로 받았다. pub 은 먼저 막힌 이름 하나만 말하므로 `custom_lint` 쪽이 풀렸는지는 이 실행으로 알 수 없다. `example/README.md` 의 M78 행과 읽는 법에 본 그대로 적었다.

## Issues Encountered

None.

## 승인 밖이라 남긴 같은 모양의 입력 (소유자 결정 Round 2 — 그대로 둔다)

- 「받는 규칙」 절에 표 · 산문 · HTML 로 적은 규칙 이름 — (d′) 는 목록 줄만 본다
- `lib/base.yaml` 의 `include:` 값 — 닫힌 목록은 키 이름만 본다
- 둘째 마커 쌍 — `findMarkerRange` 는 첫 마커를 찾는다
- `lib/base.yaml` 의 `analyzer:` 아래 키 — 목록으로 묶지 않았다 (G2-Q1 의 범위 밖)
- codegen `errors:` 의 심각도 재정의 — 닫힌 목록은 `errors:` 아래 더 깊은 줄을 보지 않는다
- CHANGELOG 98행, README 214행 — 손대지 않았다
- WR-06 은 `deferred` 그대로 (D-09)

## Known Stubs

None — 새 코드에 빈 값 · placeholder 가 없다.

## Threat Flags

None — 새 네트워크 · 인증 · 파일 접근 자리가 없다. `tool/verify.dart` 는 저장소 안의 파일을 읽기만 하고, import 는 `dart:convert` · `dart:io` 둘 그대로다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-11 (처리 기록 WR-10 `fixed` · WR-07 ~ WR-09 · IN-08 `skipped`, push 전 비공개 점검, `git push`, GitHub `verify`) 이 이 위에 얹힌다. 커밋 셋은 위 제목으로 찾는다.
- VERIFY-06 은 05-11 이 표시한다 (이 plan 은 DOCS-06 만 표시했다).
- 05-VERIFICATION.md 의 사람 확인 넷은 gap plan 뒤 `/gsd-verify-work` 로 간다.

---
*Phase: 05-documentation*
*Completed: 2026-10-14*
