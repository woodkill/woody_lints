---
phase: 04-rule-reselection
plan: 01
subsystem: testing
tags: [dart-analyze, analysis-options, verify-harness, rules-md, flutter-lints]

requires:
  - phase: 03-preset-split
    provides: "조각 셋 · 묶음 · 별칭 구조, 연습용 프로젝트 여섯과 정답지 다섯, 단계 9개의 tool/verify.dart"
provides:
  - "lib/base.yaml — 이 패키지만의 규칙 6개 (겹침 6 · 주석 3 삭제)"
  - "RULES.md 뼈대 — 마커 구역 넷 (enabled-rules · enabled-options · disabled-rules · measurements)"
  - "tool/verify.dart [3/10] 배포 파일의 구성 (checkShippedComposition) — include-만 · 기반 세트 겹침 · RULES.md 일치"
  - "example/README.md M20 ~ M24 실제 실행 기록과 확인 기록 (i)"
affects: [04-02, 04-03, 04-05, 04-06, 04-07, 04-08, 04-09]

actuals:
  tokens: 12226
  tasks: 2
  commits: 2
plan_head_before: 5cf60378105da6ac537f55a35e342fade63ed533
plan_head_after: 33f8781fe17e841b6daf2acb52a0e0d4319af39b

tech-stack:
  added: []
  patterns:
    - "RULES.md 마커 구역 — <!-- woody:<name>:start/end --> 사이 표의 첫 칸 backtick 이름 하나를 기계가 읽는다"
    - "verify.dart 의 파일끼리 견주는 단계 — analyzer 없이 확인 셋을 모두 돌려 details 를 모은 StepResult 하나"

key-files:
  created:
    - RULES.md
  modified:
    - lib/base.yaml
    - tool/verify.dart
    - example/lib/base_rules.dart
    - fixtures/recommended/lib/base_rules.dart
    - fixtures/base_only/lib/base_rules.dart
    - fixtures/base_riverpod/lib/base_rules.dart
    - fixtures/base_codegen/lib/base_rules.dart
    - fixtures/overrides/lib/base_rules.dart
    - example/README.md
    - CHANGELOG.md

key-decisions:
  - "[3/10] (c) 의 기호는 RULES.md 를 정답지, lib/base.yaml 을 실제 결과로 놓는다 — + 는 base.yaml 에만, - 는 RULES.md 에만. M21 (표에서 행 삭제) 은 + 로 찍힌다"
  - "readRulesMdBlock 은 List 대신 RulesMdBlock(names, malformed) 을 돌려준다 — 첫 칸에 이름이 둘인 행을 예외가 아닌 단계 실패로 알리려면 이름과 형식 오류를 함께 돌려줘야 한다"

patterns-established:
  - "규칙을 켜고 끌 때 RULES.md 켠 규칙 표와 lib/base.yaml 을 같은 커밋에서 고친다 — [3/10] 이 CI 에서 어긋남을 잡는다"
  - "켜지 않은 규칙 표의 이유는 접두사 7종 가운데 하나로 시작한다 (RULES.md 머리 문단)"

requirements-completed: [RULES-01, RULES-02, RULES-06]

coverage:
  - id: D1
    description: "lib/base.yaml 에 이 패키지만의 규칙 6개만 남기고 겹침 6 · 주석 3 을 지움, 정답지 다섯 불변"
    requirement: "RULES-01"
    verification:
      - kind: other
        ref: "04-01-PLAN.md Task 1 <automated> (grep 단언 · fvm dart run tool/verify.dart --update → 바뀐 정답지가 없다 · 정답지 git diff --quiet)"
        status: pass
    human_judgment: false
  - id: D2
    description: "주석 처리된 설정 3개(require_trailing_commas, public_member_api_docs, formatter: trailing_commas)가 lib/base.yaml 에 없다"
    requirement: "RULES-02"
    verification:
      - kind: other
        ref: "04-01-PLAN.md Task 1 <automated> (grep -c ... = 0)"
        status: pass
    human_judgment: false
  - id: D3
    description: "tool/verify.dart [3/10] 배포 파일의 구성 — 통과 시 10개 중 10개, M20 ~ M24 에서 [3/10] 만 실패"
    requirement: "RULES-06"
    verification:
      - kind: integration
        ref: "fvm dart run tool/verify.dart (rc 0, 점검 통과 (10개 중 10개))"
        status: pass
      - kind: integration
        ref: "04-01-PLAN.md Task 2 <automated> (M20 ~ M24, M21 기호만 + 로 고쳐 실행)"
        status: pass
    human_judgment: false
  - id: D4
    description: "RULES.md 뼈대의 문구와 접두사 7종이 뒤 plan 이 쓰기에 알맞은지"
    verification:
      - kind: other
        ref: "04-01-PLAN.md Task 1 <automated> (마커 넷 · 절 제목 · 행 수 단언)"
        status: pass
    human_judgment: true
    rationale: "구조는 grep 으로 단언했지만 머리 문단과 접두사 설명 문장의 읽기 좋음은 사람이 본다"

duration: 15min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 01: 배포 파일 정리와 [3/10] 배포 파일의 구성 단계 Summary

**`lib/base.yaml` 에서 기반 세트와 겹치는 6개와 주석 3개를 지워도 정답지 다섯이 한 줄도 바뀌지 않음을 `--update` 로 확인하고, 그 겹침과 `RULES.md` 어긋남 · 묶음/별칭의 규칙을 잡는 검증 단계 `[3/10]` 을 더함**

## Performance

- **Duration:** 약 15분
- **Started:** 2026-10-12T23:06:34Z
- **Completed:** 2026-10-12T23:21:13Z
- **Tasks:** 2
- **Files modified:** 11 (새 파일 1 — `RULES.md`)

## Accomplishments

- `lib/base.yaml` 의 `linter: rules:` 가 `prefer_const_constructors` · `prefer_const_literals_to_create_immutables` · `always_declare_return_types` · `prefer_final_locals` · `prefer_single_quotes` · `unawaited_futures` 6개만 남았다. 지운 줄 말고는 공백 줄(4칸)까지 글자 그대로다.
- `fvm dart run tool/verify.dart --update` 가 종료 코드 0 에 `바뀐 정답지가 없다 — 쓰지 않았다` 를 찍었고, 정답지 다섯이 `19ae5ec` · `91bbeec` · `9ed0fe5` 와 `git diff --quiet` 로 같았다 (D-20).
- `RULES.md` 뼈대: 켠 규칙 6행, 켠 analyzer 옵션 "없음", 켜지 않은 규칙 6행(`기반 세트 —` 접두사), 실측 기록 자리, 마커 네 쌍이 각각 한 번씩 나온다.
- `tool/verify.dart` 에 `checkShippedComposition` 과 보조 함수 `declaredRuleNames` · `significantLines` · `includeOnlyFiles` · `readUpstreamRules` · `readRulesMdBlock` · `enabledLanguageOptions` · `shippedCompositionLabel` · `rulesMdFile` 을 더했다. 보통 실행 결과는 종료 코드 0, `[3/10] 배포 파일의 구성 ... 통과`, `점검 통과 (10개 중 10개)` 이고 약 19초 걸린다.
- M20 ~ M24 를 실제로 돌려 `example/README.md` 에 기록했다 (아래 표).

## M20 ~ M24 실제 결과

모두 Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13. 다섯 모두 종료 코드 1, `점검 실패 (10개 중 1개)`, 실행마다 19초.

| # | 변경 | 실패한 단계 | 찍힌 줄의 규칙 이름 |
|---|------|-------------|---------------------|
| M20 | `lib/base.yaml` 에 `avoid_print` 더함 | `[3/10]` 만 (`[2/10]`, `[5/10]` ~ `[10/10]` 통과) | 겹침 `avoid_print  (flutter_lints-6.0.0 flutter.yaml)`, 그리고 `+ avoid_print  (base.yaml 에만)` |
| M21 | `RULES.md` 켠 규칙 표에서 `prefer_single_quotes` 행 지움 | `[3/10]` 만 | `+ prefer_single_quotes  (base.yaml 에만)` |
| M22 | `lib/base.yaml` 에만 `avoid_slow_async_io` 더함 | `[3/10]` 만 (정답지 단계 통과 — 샘플에 걸리지 않음) | `+ avoid_slow_async_io  (base.yaml 에만)` |
| M23 | `lib/recommended.yaml` 끝에 `linter:` / `rules:` / `- unnecessary_await_in_return` | `[3/10]` 만 | `` `lib/recommended.yaml` 는 include 만 담아야 한다 `` (7줄 / 정해진 4줄) |
| M24 | `lib/analysis_options.yaml` 끝에 같은 세 줄 | `[3/10]` 만 | `` `lib/analysis_options.yaml` 는 include 만 담아야 한다 `` (4줄 / 정해진 1줄) |

대조 실행 셋(기록은 README 의 읽는 법 불릿): `RULES.md` 표에 `avoid_slow_async_io` 행을 더하면 `- avoid_slow_async_io  (RULES.md 에만)`, 첫 칸에 이름 둘인 행은 형식 오류 문구, `woody:enabled-options` 시작 마커를 지우면 `구역이 없다 — 04-CONTEXT.md D-08`. 셋 다 종료 코드 1 이었다. 모든 변경은 되돌렸고 끝의 보통 실행은 종료 코드 0, `점검 통과 (10개 중 10개)` 였다.

## Task Commits

1. **Task 1: 겹침 6 · 주석 3 삭제 + RULES.md 뼈대 + verify.dart [3/10]** — `2956e2a` (chore, 커밋 A)
2. **Task 2: example/README.md 단계 10개 · M20 ~ M24 기록 · CHANGELOG 불릿** — `33f8781` (docs)

**Plan metadata:** 마무리 커밋 (docs: SUMMARY · STATE · ROADMAP · REQUIREMENTS)

## 검증 명령 결과

- Task 1 `<automated>`: `;` 로 나뉜 구간을 하나씩 따로 돌렸다 (마지막 구간의 종료 코드만 보이는 모양이라서). 앞 구간(grep 단언 · `fvm dart analyze` `No issues found!` · `fvm dart format --set-exit-if-changed tool` 0) rc 0, 보통 실행 rc 0 · 10개 중 10개, `--update` rc 0 · `바뀐 정답지가 없다 — 쓰지 않았다`, 정답지 다섯 `git diff --quiet` 통과, `build/woody_rule_check` 없음.
- Task 2 `<automated>`: 구간마다 실패 검사를 붙여 돌렸다. M20 ~ M24 의 R 값이 모두 1, 마지막 보통 실행 RC 0, 전체 rc 0 (117초). 단 M21 의 `grep -qF -e '- prefer_single_quotes'` 는 `'+ prefer_single_quotes'` 로 바꿔 돌렸다 (아래 Deviations 2).

## Files Created/Modified

- `RULES.md` — 규칙 근거 문서 뼈대 (마커 구역 넷, 접두사 7종)
- `lib/base.yaml` — 겹침 6 · 주석 3 삭제, 남은 규칙 6개
- `tool/verify.dart` — `[3/10]` 배포 파일의 구성 단계와 보조 함수, 머리 주석 · doc 주석의 단계 번호
- `example/lib/base_rules.dart` 와 `fixtures/*/lib/base_rules.dart` 다섯 — 머리 주석 3 ~ 4행만 (줄 수 · 5행 이하 그대로)
- `example/README.md` — 단계 10개 표기, "추가 실측 — 배포 파일의 구성 (04-01)" 소절
- `CHANGELOG.md` — `### 그 밖의 변경` 에 불릿 둘

## Decisions Made

- `[3/10]` (c) 의 `+` / `-` 는 `RULES.md` 를 정답지, `lib/base.yaml` 을 실제 결과로 놓는다 — 계획의 (c) 정의(`+ <이름> (base.yaml 에만)` / `- <이름> (RULES.md 에만)`) 그대로다.
- `readRulesMdBlock` 은 `RulesMdBlock(names, malformed)` 을 돌려준다. 계획은 `List<String>?` 이라 적었지만 형식 오류 행을 "단계 실패로 알린다" 는 같은 계획의 요구를 함께 채우려면 둘을 돌려줘야 했다. 04-03 이 옮겨 쓸 규약(첫 칸 backtick 이름 하나, 없으면 건너뜀, 둘 이상이면 형식 오류)은 같다.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] 단계 번호가 밀린 doc 주석 다섯 자리를 함께 고침**
- **Found during:** Task 1
- **Issue:** 계획은 머리 주석과 104 · 110행만 적었지만, `Fixture` 의 doc 주석 두 곳, `checkFixtureOptions`, `readShippedPluginConstraint`, `compareFixture` 의 doc 주석도 옛 번호(`[3/N]` 옵션 파일, `[4/N] ~ [N/N]` 정답지)였다.
- **Fix:** `[4/N]` · `[5/N] ~ [N/N]` 으로 고쳤다. 동작은 바뀌지 않는다. `[2/4]` 라고 적힌 옛 doc 주석(규칙 이름 단계)은 번호가 그대로 2 라서 건드리지 않았다.
- **Files modified:** `tool/verify.dart`
- **Committed in:** `2956e2a`

**2. [Rule 1 - Bug] 계획이 예상한 M21 의 기호가 틀림 — 코드는 고치지 않고 기록과 검증 명령의 한 단언만 바로잡음**
- **Found during:** Task 2
- **Issue:** 계획은 M21 (표에서 `prefer_single_quotes` 행 삭제) 이 `- prefer_single_quotes  (RULES.md 에만)` 을 찍는다고 적고 `<automated>` 가 그 문자열을 grep 한다. 그러나 행을 지우면 그 이름은 `lib/base.yaml` 에만 남으므로, 같은 계획이 정한 (c) 의 기호로는 `+` 다 (M22 와 같은 쪽). 두 기대는 함께 성립할 수 없다.
- **Fix:** 실제 출력 `+ prefer_single_quotes  (base.yaml 에만)` 을 README 에 적고 "계획의 예상과 다르다" 를 읽는 법 불릿에 남겼다. `-` 쪽은 `RULES.md` 에 행을 더한 대조 실행으로 확인해 함께 적었다. Task 2 `<automated>` 는 그 grep 하나만 `+` 로 바꿔 돌렸고 나머지는 그대로다.
- **Files modified:** `example/README.md`
- **Committed in:** `33f8781`

**3. [Rule 3 - Blocking] Write 가 공백만 있는 두 줄을 빈 줄로 바꿈**
- **Found during:** Task 1
- **Issue:** `lib/base.yaml` 을 Write 로 쓰자 26 · 35행(원래 4칸 공백 줄)이 빈 줄로 바뀌었다 ("글자 하나 바꾸지 않는다" 위반).
- **Fix:** perl 로 4칸을 되살렸다. 최종 diff 는 지운 줄 11개뿐이다.
- **Committed in:** `2956e2a`

---

**Total deviations:** 3 auto-fixed (Rule 1 둘, Rule 3 하나)
**Impact on plan:** 기능 범위는 바뀌지 않았다. 2번은 뒤 plan(04-06 이후의 M25, 04-09 기록)이 같은 기호 규약을 쓰도록 README 에 근거를 남겼다.

## Issues Encountered

- 두 `<automated>` 명령은 `;` 로 이어진 구간이 있어 그대로 돌리면 마지막 구간의 종료 코드만 남는다. 구간을 나눠(Task 1) 또는 구간마다 실패 검사를 붙여(Task 2) 돌렸다. 계획의 검증 명령을 쓰는 다음 실행에도 같은 주의가 필요하다.
- Task 2 `<automated>` 는 백업에 `mktemp` 기본 자리(시스템 임시 폴더)를 쓴다. 계획이 정한 명령이라 그대로 두었고, 만든 파일은 그 명령이 지운다.

## Known Stubs

| 파일 | 자리 | 이유 |
|------|------|------|
| `RULES.md` | 켠 규칙 표 6행의 실측 · dart fix · 회차 칸 `(실측 전 — 04-06 이 채운다)` | 실측은 04-02 ~ 04-04, 채우기는 04-06 의 일이다 (계획이 정한 자리 표시). `.planning/WINDOWS.md` 에 stub 으로 올렸다 |
| `RULES.md` | 실측 기록 구역의 `(tool/measure_rules.dart --report --write 가 생성한다 …)` | 04-09 의 `--report --write` 가 채운다 |

## User Setup Required

None - 외부 서비스 설정 없음.

## Next Phase Readiness

- 04-02 (`tool/measure_rules.dart`) 가 같은 작업 트리에서 이어 돈다. `readUpstreamRules` 의 doc 주석이 measure_rules.dart 의 `readUpstreamSets` 와 같은 동작이라고 적어 두었다 (서로 import 하지 않는다).
- 결정 묶음 커밋은 `RULES.md` 켠 규칙 표와 `lib/base.yaml` 을 같은 커밋에서 고쳐야 `[3/10]` 이 통과한다.

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*

## Self-Check: PASSED

- 파일 다섯(`RULES.md`, `lib/base.yaml`, `tool/verify.dart`, `example/README.md`, `CHANGELOG.md`) 모두 있음
- 커밋 `2956e2a` · `33f8781` 모두 HEAD 의 조상
- SUMMARY 의 절대 경로 꼴 grep 0줄
