---
phase: 05-documentation
plan: 01
subsystem: testing
tags: [dart, verify, tool-verify, analysis_options, riverpod_lint, review-disposition]

requires:
  - phase: 03-preset-split
    provides: "조각 셋 · 묶음 · 별칭 구조와 `[2/N]` 규칙 검사(`stripPlugins`), 03-REVIEW WR-02 지적"
  - phase: 04-rule-reselection
    provides: "`[3/10]` 배포 파일의 구성 (a) · (b) · (c), `declaredRuleNames` 의 WR-10 판, 04-REVIEW WR-11 · IN-14 지적"
provides:
  - "줄 단위 `stripPlugins` — `plugins:` 섹션을 빈 줄로 바꿔 복사본의 줄 번호를 원본과 같게 한다"
  - "줄 끝 주석 · 맵 형식(`riverpod_lint:` / `version:`)을 받는 `readShippedPluginConstraint` — 05-03 의 README 검사 (f) 가 같은 값을 쓴다"
  - "`[3/10]` (b′) — `lib/base.yaml` 밖 조각의 `linter:` 블록에 규칙이 있으면 실패"
  - "`declaredRuleNames` · `countDeclaredRules` 의 `{required String shownAs}` — 70 문구에 파일 이름"
  - "`example/README.md` 의 (05-01) 소절, M32 ~ M37"
  - "03 WR-02 · 04 WR-11 · IN-14 처리 기록 `fixed`"
affects: [05-02, 05-03, 05-06]

actuals:
  tokens: 5070
  tasks: 3
  commits: 3
plan_head_before: 2c026dd7b74af4698d257c0b5f196b078a7a0f31
plan_head_after: 2be345e9c4b291d7b3fa45582b6b07e6a6809660

tech-stack:
  added: []
  patterns:
    - "옵션 파일 reader 는 줄 단위로 걷고(`\\r\\n` → `\\n`), 지우지 않고 빈 줄로 바꿔 줄 번호를 보존한다"
    - "규칙은 `lib/base.yaml` 에만 — (b′) 가 `ruleCheckTargets` 에서 `rulesFile` 을 뺀 조각 전부를 본다"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - example/README.md
    - .planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md
    - .planning/phases/04-rule-reselection/04-REVIEW-DISPOSITION.md

key-decisions:
  - "WR-11 은 B안(\"규칙은 lib/base.yaml 에만\" 을 [3/10] (b′) 검사로)으로 닫았다 — includeOnlyFiles · rulesFile · RULES.md 머리 문장 · M 기록의 (base.yaml 에만) 기호가 모두 그 관례 위에 있다"
  - "stripPlugins 는 plugins: 섹션을 지우지 않고 빈 줄로 바꾼다 — [2/10] 진단 줄 번호가 원본과 같아 fragmentLineHint 를 한 문장으로 줄였다 (M37 :13)"

patterns-established:
  - "지워 보기 기록은 실제로 돌린 단계 · 종료 코드 · stderr 문구로 적고, 예외가 난 자리처럼 코드에서 읽은 것은 그렇다고 적는다"

requirements-completed: [VERIFY-06, DOCS-10]

coverage:
  - id: D1
    description: "lib/riverpod.yaml 의 plugin 줄 끝 주석(M32) · 마지막 줄바꿈 없음(M33)에서 검증이 종료 코드 0 · 점검 통과 (10개 중 10개)"
    requirement: "DOCS-10"
    verification:
      - kind: integration
        ref: "05-01-PLAN.md Task 1 <automated> (fvm dart run tool/verify.dart, M32 · M33 변형 후)"
        status: pass
    human_judgment: false
  - id: D2
    description: "선언 줄을 지우면(M34) 종료 코드 70 · stdout 0 바이트 · stderr 'lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다' — reader 헛통과 아님"
    requirement: "DOCS-10"
    verification:
      - kind: integration
        ref: "05-01-PLAN.md Task 1 <automated> (M34)"
        status: pass
    human_judgment: false
  - id: D3
    description: "[3/10] (b′) 가 lib/codegen.yaml(M35) · lib/riverpod.yaml(M37) 의 규칙을 파일 이름과 함께 실패로 알린다"
    requirement: "VERIFY-06"
    verification:
      - kind: integration
        ref: "05-01-PLAN.md Task 2 <automated> (M35 · M37)"
        status: pass
    human_judgment: false
  - id: D4
    description: "읽지 못하는 줄의 70 문구에 파일 이름(lib/codegen.yaml)이 들어간다 (M36, IN-14)"
    requirement: "VERIFY-06"
    verification:
      - kind: integration
        ref: "05-01-PLAN.md Task 2 <automated> (M36)"
        status: pass
    human_judgment: false
  - id: D5
    description: "[2/10] 진단 줄 번호가 원본과 같다 — riverpod/analysis_options.yaml:13 (두 줄 앞당긴 :11 은 0줄, M37)"
    verification:
      - kind: integration
        ref: "05-01-PLAN.md Task 2 <automated> (M37 의 N37 · N37-2 단언)"
        status: pass
    human_judgment: false
  - id: D6
    description: "03 WR-02 · 04 WR-11 · IN-14 처리 기록이 fixed 와 실제 fix(tool) 커밋 해시를 가리킨다, open 12 · 17"
    verification:
      - kind: other
        ref: "05-01-PLAN.md Task 3 <automated>"
        status: pass
    human_judgment: false
  - id: D7
    description: "example/README.md (05-01) 소절의 문장(읽는 법)이 실행 결과와 출처를 정확히 구분해 적었는지"
    verification: []
    human_judgment: true
    rationale: "산문의 정확성 · 어투는 자동 단언이 행 수와 고정 문구만 본다"

duration: 9min
completed: 2026-10-14
status: complete
---

# Phase 5 Plan 01: 검증 명령의 plugin 선언 reader · 다른 조각의 규칙 검사 Summary

**줄 단위 `stripPlugins`(빈 줄 치환, 줄 번호 보존)와 줄 끝 주석 · 맵 형식을 받는 `readShippedPluginConstraint` 로 03-REVIEW WR-02 의 거짓 70 을 없애고, `[3/10]` (b′) 와 파일 이름이 든 70 문구로 04-REVIEW WR-11 · IN-14 를 닫았다 — M32 ~ M37 을 실제로 돌려 `example/README.md` 에 기록**

## Performance

- **Duration:** 약 9분 (작업 시작 기록 이후. 필수 문서 읽기는 그 전)
- **Started:** 2026-10-13T16:54:48Z
- **Completed:** 2026-10-13T17:03:16Z (KST 2026-10-14)
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments

- `stripPlugins` 가 `\r\n` → `\n` 뒤 줄 단위로 걸으며 `plugins:` 섹션(여는 줄 포함, 다음 들여쓰기 없는 비주석 줄 앞까지)을 빈 줄로 바꾼다. 바꾼 뒤에도 `^plugins:` 가 남으면 지금과 같은 문구 `… 의 \`plugins:\` 섹션을 빼지 못했다` 로 던진다.
- `readShippedPluginConstraint` 가 받는 꼴: 들여쓴 스칼라 줄 `riverpod_lint: <값>` (줄 끝 `# 주석` 가능), 맵 형식 `riverpod_lint:` 다음의 첫 비주석 줄 `version: <값>`. 그 밖은 `lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다` (문구 불변).
- `fragmentLineHint` 둘째 문장 → `복사본의 줄 번호는 원본과 같다 (\`plugins:\` 섹션은 빈 줄로 바꿔 복사한다).`
- `[3/10]` (b′): `ruleCheckTargets.where((t) => t != rulesFile)` 의 조각마다 `declaredRuleNames(…, shownAs: target)` — 규칙이 있으면 `` `<조각>` 에 규칙이 있다 (N) — 규칙은 `lib/base.yaml` 에만 적는다. `` 와 옮길 곳 안내.
- `declaredRuleNames` · `countDeclaredRules` 가 `{required String shownAs}` 를 받고, 70 문구가 `$shownAs 의 \`linter:\` 블록의 N행을 읽지 못했다 — … (04-REVIEW-DISPOSITION.md WR-10): …` 이다. 부르는 자리: `shownAs: rulesFile` 둘(`[2/10]` 규칙 수, `[3/10]` (b)), `shownAs: target` 하나((b′)).

## 지워 보기 M32 ~ M37 의 실제 결과 (2026-10-14, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9)

| # | 변경 | 실패한 단계 | 종료 코드 | stdout / stderr |
|---|------|-------------|-----------|-----------------|
| M32 | `lib/riverpod.yaml` plugin 줄 끝 ` # 하한` | 없음 | 0 | `점검 통과 (10개 중 10개)` |
| M33 | `lib/riverpod.yaml` 마지막 줄바꿈 삭제 | 없음 | 0 | `점검 통과 (10개 중 10개)` |
| M34 | `lib/riverpod.yaml` 의 `riverpod_lint:` 줄 삭제 | 단계 줄 없음 (`[4/10]` 의 선언 읽기에서 예외 — 코드에서 읽음) | 70 | stdout 0 바이트, stderr `파일 모양이 예상과 다르다: lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다` |
| M35 | `lib/codegen.yaml` 끝에 규칙 둘 (`avoid_print`, `prefer_mixin`) | `[3/10]` 만 | 1 | `` `lib/codegen.yaml` 에 규칙이 있다 (2) — 규칙은 `lib/base.yaml` 에만 적는다. ``, `점검 실패 (10개 중 1개)`, 19초 |
| M36 | `lib/codegen.yaml` 끝에 `avoid_print: true` (맵 항목) | 단계 줄 없음 (`[3/10]` (b′) 에서 예외 — 코드에서 읽음) | 70 | stdout 0 바이트, stderr `` 파일 모양이 예상과 다르다: lib/codegen.yaml 의 `linter:` 블록의 10행을 읽지 못했다 — … (04-REVIEW-DISPOSITION.md WR-10): avoid_print: true ``, 3초 |
| M37 | `lib/riverpod.yaml` 끝에 `- unnecessary_await_in_return` (원본 13행) | `[2/10]` · `[3/10]` | 1 | `[2/10]` 진단 줄 `build/woody_rule_check/riverpod/analysis_options.yaml:13  warning  deprecated_lint  (unnecessary_await_in_return)` (Phase 3 은 `:11`), `` `lib/riverpod.yaml` 에 규칙이 있다 (1) ``, `점검 실패 (10개 중 2개)`, 19초 |

모든 변형은 돌린 직후 `git checkout -- <파일>` 로 되돌렸고, 각 task 끝에 `lib/` 가 HEAD 와 같고 보통 실행이 종료 코드 0 · `점검 통과 (10개 중 10개)` 인 것을 봤다.

## Task Commits

1. **Task 1 (tracer): WR-02 — reader 둘 · fragmentLineHint · M32 ~ M34** — `1831c04` `fix(tool): plugin 선언의 줄 끝 주석 · 마지막 줄바꿈 없음에서 검증이 70 으로 멈추던 결함 수정 (03-REVIEW WR-02)`
2. **Task 2: WR-11 · IN-14 — (b′) · shownAs · M35 ~ M37** — `dc42790` `fix(tool): [3/10] 이 lib/base.yaml 밖 조각의 규칙을 잡고, 읽지 못하는 줄의 문구에 파일 이름을 넣음 (04-REVIEW WR-11 · IN-14)`
3. **Task 3: 처리 기록 셋** — `2be345e` `docs(review): 03 WR-02 · 04 WR-11 · IN-14 처리 기록을 fixed 로 (05-01, D-19)`

## `<automated>` 결과

PLAN 에서 awk 로 뽑아 `bash <파일>` 로 돌렸다. 고친 사본은 필요 없었다.

| Task | 그대로 돌린 rc | 고친 사본 rc | 비고 |
|------|----------------|--------------|------|
| 1 | 0 (커밋 전), 0 (커밋 뒤 tracer gate 재실행) | — | — |
| 2 | 0 (커밋 전) | — | — |
| 3 | 0 (커밋 3 직후, SUMMARY 전) | — | `git log -1` 이 커밋 3 을 보는 때에 돌렸다 |

## Files Created/Modified

- `tool/verify.dart` — `stripPlugins` · `readShippedPluginConstraint` 다시 씀, `fragmentLineHint`, `declaredRuleNames` · `countDeclaredRules` 시그니처, `checkShippedComposition` (b′), 머리 주석 · `includeOnlyFiles` · `checkRuleNames` 문서 주석
- `example/README.md` — 종료 코드 70 설명과 `[3/10]` 단계 설명을 넓힘, 소절 `### 추가 실측 — plugin 선언의 꼴과 다른 조각의 규칙 (05-01)` (M32 ~ M37 여섯 행 · 읽는 법 · 되돌림 확인), 맨 끝 각주에 05-CONTEXT.md
- `.planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md` — WR-02 `fixed`
- `.planning/phases/04-rule-reselection/04-REVIEW-DISPOSITION.md` — WR-11 · IN-14 `fixed`, `open: 17`

## Decisions Made

- WR-11 은 PLAN 대로 B안. 새 상수는 두지 않고 `ruleCheckTargets` · `rulesFile` 이 대상을 정한다.
- `checkShippedComposition` 문서 첫 문장 "확인 셋을 모두 돌리고" 를 "확인을 모두 돌리고" 로 고쳤다 — (b′) 가 더해져 넷이 되었다 (문서 정확성, 동작 변화 없음).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Task 3 의 표 행 치환이 한글을 이중 인코딩함 (작업 중 바로잡음)**
- **Found during:** Task 3
- **Issue:** `04-REVIEW-DISPOSITION.md` 의 WR-11 · IN-14 표 행을 `perl -CSD` 로 바꿔 한글이 깨졌다 (커밋 전 `git diff` 에서 발견)
- **Fix:** `-CSD` 없이 두 행을 다시 치환, `iconv -f UTF-8 -t UTF-8` 로 확인
- **Files modified:** `.planning/phases/04-rule-reselection/04-REVIEW-DISPOSITION.md`
- **Committed in:** `2be345e` (깨진 판은 커밋되지 않았다)

**Total deviations:** 1 auto-fixed (Rule 1, 커밋 전). **Impact:** 없음.

그 밖에 PLAN 과 다른 점: Task 2 의 README 단계 설명에 넣을 `<날짜>` 는 실측일 `2026-10-14` (KST) 로 적었다. 실측 줄의 날짜도 같다.

## Issues Encountered

None.

## Known Stubs

없음.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-02 가 `lib/riverpod.yaml` 의 주석(줄 끝 주석 포함)을 고칠 수 있다 — M32 · M33 이 그 꼴을 실행으로 통과했다.
- 05-03 의 README 비교 (d) 는 `lib/base.yaml` 하나만 봐도 된다 — (b′) 가 다른 조각의 규칙을 막는다. (f) 는 `readShippedPluginConstraint` 를 그대로 부른다.
- 요구사항 VERIFY-06 · DOCS-10 은 05-02 · 05-03 · 05-06 도 선언하므로 이 plan 에서 완료 표시하지 않았다 (`requirements.ready-ids` 0/2).

## Self-Check: PASSED

- 수정 파일 넷 존재 확인, 커밋 `1831c04` · `dc42790` · `2be345e` 가 HEAD 의 조상, `lib/` 가 HEAD 와 같다.
- 절대 경로 grep (`tool/verify.dart` · `example/README.md` · 처리 기록 둘) 0줄.

---
*Phase: 05-documentation*
*Completed: 2026-10-14*
