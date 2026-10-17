---
phase: 05-documentation
plan: 12
subsystem: testing
tags: [dart, verify, yaml, line-splitter, gap-closure, docs]

requires:
  - phase: 05-documentation
    provides: "05-10 · 05-11 의 닫힌 목록 검사와 (d′) · (e) ~ (g) 문장, 05-VERIFICATION.md 3회차 gap 과 05-REVIEW.md 재리뷰 (WR-11 ~ WR-14 · IN-08 · IN-09)"
provides:
  - "tool/verify.dart 의 splitYamlLines (const LineSplitter().convert) — 옵션 YAML 을 줄로 나누는 자리 여섯과 pubspecReleaseVersion 이 YAML · analyzer 와 같은 줄 경계(CR · LF · CRLF)로 읽는다"
  - "example/README.md 의 소절 (05-12) — 지워 보기 M79 ~ M85 와 회귀 입력 넷"
  - "README 382행 · example/README.md 116 · 395 · 518 · 549행 · tool/verify.dart 의 (e) · (f) · (g) 주석이 실제 검사 범위를 말한다"
affects: [05-13, verify-work, release]

actuals:
  tokens: 8277
  tasks: 2
  commits: 2
plan_head_before: 3d5bd97fb1d7d8efa0718dfa52b97026ba09cb88
plan_head_after: d8b61b0bb12b02f3dd3574652fd4d13d87e1a98b

tech-stack:
  added: []
  patterns:
    - "YAML 텍스트를 줄로 나눌 때는 splitYamlLines 하나를 쓴다 — split · replaceAll 로 줄을 나누지 않는다"
    - "pubspec 의 키는 나눈 줄을 한 줄씩 정규식에 건다 — 여러 줄 정규식은 U+2028 · U+2029 도 줄 경계로 본다"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - example/README.md
    - README.md

key-decisions:
  - "옵션 YAML 과 pubspec 을 줄로 나누는 자리는 모두 splitYamlLines (LineSplitter) 하나를 쓴다 — CR 하나도 줄을 나눈다 (소유자 결정 G3-Q1 · G3-R2-Q1, 도우미로 모은 것은 planner 재량)"
  - "WR-12 · WR-13 · WR-14 · IN-08 은 문장 · 주석만 고치고 검사 코드는 그대로 둔다 (소유자 결정 G3-Q2 · G3-Q3)"

patterns-established:
  - "줄 나누기 규칙은 이름 붙은 한 곳(splitYamlLines)에 둔다 — 자동 검증이 주석이 아닌 줄의 splitYamlLines( 8개(정의 하나 · 쓰는 곳 일곱)로 센다"

requirements-completed: [VERIFY-06, DOCS-06]

coverage:
  - id: D1
    description: "YAML 을 줄로 나누는 자리 여섯과 pubspecReleaseVersion 이 splitYamlLines 를 쓰고, CR 뒤에 숨긴 규칙 · 옵션 · 키 · plugin 이 [3/10] 실패다 (M79 ~ M85), 회귀 넷과 기준 실행은 앞 기록 그대로"
    requirement: "VERIFY-06"
    verification:
      - kind: integration
        ref: "05-12-PLAN.md Task 1 <automated> (복제본 전체 실행 M79 ~ M82 · 함수 단위 M83 ~ M85 · 함수 직접 호출 일곱 · 회귀 M37 · M33 · M45 · M61)"
        status: pass
    human_judgment: false
  - id: D2
    description: "README 382행 · example/README.md 116 · 395 · 518 · 549행 · tool/verify.dart 의 (e) · (f) · (g) 주석이 실제 검사 범위를 말하고 코드 줄은 Task 1 커밋과 같다"
    requirement: "DOCS-06"
    verification:
      - kind: other
        ref: "05-12-PLAN.md Task 2 <automated> (새 구절 개수 · 옛 조각 0 · 코드 줄 동일 · 작업 트리 검증 10/10)"
        status: pass
    human_judgment: false

duration: 20min
completed: 2026-10-14
status: complete
---

# Phase 5 Plan 12: CR 줄바꿈을 YAML 과 같게 나누기 · 3회차 gap 의 문장 맞춤 Summary

**`tool/verify.dart` 에 `splitYamlLines` (`const LineSplitter().convert`) 를 두고, 옵션 YAML 을 줄로 나누는 자리 여섯과 `pubspecReleaseVersion` 이 이 도우미를 쓰도록 바꿨다. 이제 주석 줄 끝의 CR 뒤에 숨긴 규칙 · 옵션 · 키 · plugin 이 `[3/10]` 에서 실패한다 (M79 ~ M85). WR-12 ~ WR-14 · IN-08 · IN-09 는 문장 다섯 줄과 주석 줄만 고쳐 닫았다.**

## Performance

- **Duration:** 약 20분
- **Started:** 2026-10-14T12:38:54Z
- **Completed:** 2026-10-14T12:58Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- **도우미와 자리 여섯 (G3-Q1).** `List<String> splitYamlLines(String text) => const LineSplitter().convert(text);` 를 `checkLibHasNoDart` 뒤에 두었다. 다음 여섯 자리가 이 도우미로 줄을 나눈다.
  - `stripPlugins` · `findUnexpectedKeys` 는 `replaceAll('\r\n', '\n').split('\n')` 대신 쓴다.
  - `declaredRuleNames` · `enabledLanguageOptions` 는 `split('\n')` 대신 쓴다.
  - `checkRuleNames` 의 `copyLines` 는 `content.split('\n')` 대신 쓴다.
  - `readShippedPluginConstraint` 는 네 줄 연쇄를 한 줄로 바꿨다.
- **`pubspecReleaseVersion` (G3-R2-Q1).** `splitYamlLines` 로 나눈 줄을 한 줄씩 `versionLine` 정규식(옛 정규식 글자 그대로, `multiLine` 만 뺐다)에 건다. 처음 맞는 줄에서 멈춘다. 다시 잇기 · 글자 치환 · 여러 줄 정규식은 쓰지 않는다. 그 뒤의 따옴표 · `-dev` 처리는 그대로다.
- **문서 주석 정리.** `stripPlugins` 문서 주석의 받는 꼴을 `CR 하나 · CRLF 줄바꿈 ([splitYamlLines] — YAML 과 같다)` 로 고쳤다. `copyLines` 위에는 "복사본은 LF 로 이은 것이라 analyzer 가 말하는 줄 번호와 같다" 를 더했다.
- **지워 보기 기록.** 복제본에서 지워 보기 일곱(M79 ~ M85)과 회귀 입력 넷을 돌려, 결과를 `example/README.md` 의 새 소절 `### 추가 실측 — CR 하나로 나뉜 줄 (05-12)` 에 적었다. 소절은 05-10 둘째 소절 뒤 · 각주 앞에 있고, 기존 줄은 지우지 않았다.
- **문장과 주석 (G3-Q2 · G3-Q3).** README 1줄, `example/README.md` 4줄, `tool/verify.dart` 의 주석 줄(문서 주석 넷 고침, 함수 안 두 줄 더함)을 실제 검사 범위로 맞췄다. 코드 줄은 Task 1 커밋과 글자가 같다.

## 지워 보기 결과 (복제본, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9)

| # | 입력 | 결과 | 걸린 시간 |
|---|------|------|-----------|
| 기준 | 변경 없음 | 0 · `점검 통과 (10개 중 10개)` | 69초 (plugin 준비 포함) |
| M79 | `lib/base.yaml` 93행 끝 CR + `    - prefer_mixin` | 1 · `[3/10]` 만 실패 · `  + prefer_mixin  (base.yaml 에만)` 두 줄 (RULES.md 표 · README 목록) · 10개 중 1개 | 25초 |
| M80 | 같은 자리 CR + `    - always_specify_types` | 1 · `[2/10]` 실패(`  build/woody_rule_check/base/analysis_options.yaml:94  warning  incompatible_lint  (always_specify_types)`) · `[3/10]` 실패(`+ always_specify_types  (base.yaml 에만)`) · 정답지 단계 다섯 실패 · 10개 중 7개 | 24초 |
| M81 | `lib/codegen.yaml` 9행 끝 CR + `  language:` + CR + `    strict-casts: true` | 1 · `[3/10]` 실패(`analyzer:` 바로 아래 받지 않는 줄 · `  10행:   language:`) · 정답지 단계 셋(`[5/10]` · `[9/10]` · `[10/10]`)이 `invalid_assignment` 한 줄씩으로 실패 · 10개 중 4개 | 24초 |
| M82 | 같은 자리 CR 로 나뉜 `language:` / `strict-inference: true` / `formatter:` / `trailing_commas: preserve` | 1 · `[3/10]` 만 · `  12행: formatter:` 와 `  10행:   language:` · 10개 중 1개 | 24초 |
| M83 | `lib/codegen.yaml` 3행 끝 CR + `linter:` / `  rules:` / `    - prefer_mixin` (함수 단위) | `passed=false` · `  4행: linter:` · `` `lib/codegen.yaml` 에 규칙이 있다 (1) `` · `  prefer_mixin` | 1초 이하 |
| M84 | `lib/base.yaml` 4행 끝 CR + `formatter:` · `plugins:` 블록 (함수 단위) | `passed=false` · `(2)` · `  5행: formatter:` · `  7행: plugins:` | 1초 이하 |
| M85 | `lib/riverpod.yaml` 끝 `  # memo` + CR + `  custom_lint: ^0.7.0` (함수 단위) | `passed=false` · `  7행:   custom_lint: ^0.7.0` | 1초 이하 |
| 회귀 M37 | `lib/riverpod.yaml` 끝 deprecated 규칙 블록 (8행) | 1 · `  build/woody_rule_check/riverpod/analysis_options.yaml:8  warning  deprecated_lint  (unnecessary_await_in_return)` · 10개 중 2개 | 24초 |
| 회귀 M33 | `lib/riverpod.yaml` 마지막 줄바꿈 삭제 | 0 · 10개 중 10개 | 24초 |
| 회귀 M45 | `lib/codegen.yaml` 끝 `linter: {rules: [prefer_mixin]}` | 70 · stdout 0 바이트 · stderr `lib/codegen.yaml 의 10행: `linter:` 줄에 값이 붙어 있다 …` | 3초 |
| 회귀 M61 | `lib/base.yaml` 끝 `strict-casts: yes` | 70 · stdout 0 바이트 · stderr `` lib/base.yaml 의 `language:` 블록의 98행을 읽지 못했다 … `` | 4초 |
| 되돌린 뒤 | 변경 없음 | 0 · 10개 중 10개 | 24초 |

- 고치기 전 결과는 검증자의 기록이다 (M79 · M82 는 10/10, M80 · M81 은 `[3/10]` 통과, M83 ~ M85 는 `passed=true`, M80 의 줄 끝 이름은 `(no_dynamic_casts)`). 이번에 고치기 전 스크립트로 다시 재지는 않았다.
- M80 에서 `[6/10]` recommended 가 통과한 것은 이 단계가 같은 실행의 `example` 결과와 견주기 때문이다.

**함수 직접 호출 일곱** (하네스 `units` 모드, 복제본):

```
declared=[a]
options={strict-casts: true}
keys=[2행: formatter:]
crlf=[2행: formatter:]
strip=false
plugin=^3.1.9
pubspec=2.0.0
```

**자동 검증 (계획의 `<automated>` 를 글자 그대로 뽑아 `bash -x` 로 실행):**
- Task 1 은 커밋 `d771c0c` 직후 종료 코드 0, 231초.
- Task 2 는 커밋 `d8b61b0` 직후 종료 코드 0, 25초.
- 고친 판은 만들지 않았다 — 적힌 그대로 통과했다.

## Task Commits

1. **Task 1 (tracer): YAML 을 줄로 나누는 자리 여섯과 pubspecReleaseVersion 을 splitYamlLines 로, M79 ~ M85 기록.** 커밋 `d771c0c` (fix). 제목 머리: `fix(tool): YAML 을 줄로 나누는 자리를 `.
2. **Task 2: 문장 · 주석만 실제 검사 범위로.** 커밋 `d8b61b0` (docs). 제목 머리: `docs: 3회차 gap 의 문장 맞춤 — `.

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 을 담은 커밋 (docs).

## 고친 문장과 주석 자리 (Task 2 — 05-13 의 처리 기록이 가리킨다)

- **README.md 382행 (WR-13).** 마지막 문장의 `줄의 값을 견준다 — ` 뒤를 고쳤다. 새 문장: 키는 따옴표 · 콜론 앞 공백 없이 `ref:` · `version:` · `riverpod_lint:` 글자 그대로인 줄만 후보다. `"ref":` · `'riverpod_lint':` · `ref :` 꼴은 YAML 로는 같은 키지만 견주지 않는다. 문장 끝은 "예시는 … 펜스 안의 블록 꼴로, 키는 글자 그대로 둔다." 다.
- **example/README.md 116행.** 네 군데를 고쳤다.
  - WR-12 (G3-Q3): 표시 구역이 든 절의 괄호에 정의를 더했다. 제목 · 펜스 판정은 HTML 주석 안의 `#` 줄과 네 칸 이상 들여 쓴 펜스 줄을 가리지 않는다.
  - WR-13: (f) · (g) 구절에 키 글자 구절을 더했다.
  - WR-14: (e) 구절을 고쳤다. `package:woody_lints/` 뒤가 `<이름>.yaml` 꼴이 아니거나, `.yaml` · `.yml` 로 끝나는 다른 패키지의 주소면 실패한다. 확장자가 다른 다른 패키지의 주소는 보지 않는다.
  - 괄호 출처를 `WR-07 · WR-14 · IN-08` 로 고쳤다.
  - 닫힌 목록 구절(`철자가 다른 키 · 열 0 에서 시작하지 않는 키도 실패 …`)은 그대로 두었다 (G3 IN 3 — 고친 뒤 참이다).
- **example/README.md 395행 (WR-13).** (f) · (g) 불릿의 굵은 머리 뒤에 키 글자 문장을 더했다. 끝은 "소유자 결정 G3-Q2 로 검사는 넓히지 않고 이 문장을 좁혔다" 다.
- **example/README.md 518행 (IN-09).** `- **M35 · M37 · M46 은 이제 `[3/10]` 에 블록 둘(최상위 · 규칙)을 찍는다.** 05-01 · 05-07 소절의 그 행은 그때의 기록이다 (05-REVIEW.md IN-09).`
- **example/README.md 549행 (WR-12).** 「절의 경계」 불릿 끝에 정의를 더했다. HTML 주석 안의 `# 메모` 와 네 칸 이상 들여 쓴 펜스 줄을 제목 · 펜스로 본다. 끝은 "소유자 결정 G3-Q3 로 검사는 고치지 않고 이 정의를 적었다" 다.
- **tool/verify.dart (주석 줄만).** `checkShippedComposition` 문서 주석의 줄 넷과 함수 안 줄 둘이다.
  - (e) bullet 둘째 줄 (WR-14) 을 고쳤다.
  - (f) · (g) bullet 의 같은 줄 둘 (WR-13) 을 `값의 따옴표 · 줄 끝 주석을 벗겨 읽고 … (키는 따옴표 · 콜론 앞 공백 없이 글자 그대로인 줄만 후보 …)` 로 고쳤다.
  - 범위 밖 문장 (IN-08 · WR-13 · WR-14 — 문장 부호가 붙으면 `woody_lints` 주소는 실패, 다른 패키지의 주소는 후보가 아니다; 따옴표 키 · 콜론 앞 공백) 을 고쳤다.
  - 함수 안 (f) 주석 블록 끝과 (g) 주석 블록 끝에 키 글자 줄을 하나씩 더했다.
  - (d′) 의 주석은 그대로 두었다.

## Files Created/Modified

- `tool/verify.dart`:
  - `splitYamlLines` 를 더하고, 줄 나누기 자리 여섯과 `pubspecReleaseVersion` 을 바꿨다 (Task 1).
  - (e) · (f) · (g) 를 말하는 주석 줄을 고쳤다 (Task 2).
- `example/README.md`:
  - 소절 (05-12) 를 더했다 (Task 1, 36줄 더함).
  - 116 · 395 · 518 · 549행을 줄 안에서 고쳤다 (Task 2, 4/4).
- `README.md`: 382행을 고쳤다 (Task 2, 1/1).

## Decisions Made

- 줄 나누기는 한 도우미로 모았다 (G3-Q1 이 planner 재량으로 맡긴 선택을 계획대로 따랐다). README 378 · 379행과 `example/README.md` 116행의 닫힌 목록 구절은 고친 뒤 참이라 그대로 두었다.

## Deviations from Plan

None - plan executed exactly as written.

- 기록 소절의 숫자(결과 · 걸린 시간)는 계획이 허용한 대로 같은 절차의 별도 복제본 실행에서 옮겼다. 그 뒤 커밋 직후 `<automated>` 를 글자 그대로 따로 돌려 같은 판정을 확인했다.

## 승인 밖 같은 모양 (보고만 — 고치지 않았다)

- **`tool/measure_rules.dart`.** `split('\n')` 으로 YAML · 옵션 텍스트를 나누는 자리가 그대로 있다 (계획의 flagged_assumptions 에 적힌 셋 — `environmentSdk` 의 pubspec, `insertRules`, `noteIncompatibleLint` 의 옵션 파일). 같은 파일의 그 밖의 `split('\n')` 은 이번에 가르지 않았다. 소유자 결정 G3-R2-Q2 "두기" 대로 손대지 않았다.
- **`stripPlugins` 끝의 `^plugins:` 여러 줄 확인과 (e) 의 여러 줄 정규식.** 손대지 않았다 (NOT approved).
- **`tool/verify.dart` 안의 나머지 `split('\n')` 다섯.** `normalizeDiagnostics` 의 stdout, `parse_error` 줄 찾기, stderr 머리 두 곳, plugin 실패 stderr 를 나눈다. 모두 YAML 이 아니라 도구 출력을 나누므로 같은 모양이 아니라고 판단했다.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-13 (처리 기록 · push) 이 이 두 커밋을 가리킨다: WR-11 · IN-09 `fixed` (`d771c0c` · `d8b61b0`), WR-12 · WR-13 · WR-14 `skipped` (문장만, `d8b61b0`).
- 요구사항 VERIFY-06 · DOCS-06 은 05-13 도 선언하므로 이 plan 에서 완료로 표시하지 않았다 (마지막 plan 이 표시한다).
- 작업 트리 검증: 종료 코드 0 · `점검 통과 (10개 중 10개)` (Task 2 의 `<automated>` 안에서 확인).

## Self-Check: PASSED

- FOUND: `tool/verify.dart`, `example/README.md`, `README.md`
- FOUND: `d771c0c`, `d8b61b0` (HEAD 의 조상)
- 고정 커밋 비교 (`lib` · `CHANGELOG.md` · `RULES.md` · `fixtures` · `pubspec.yaml` · `.claude/CLAUDE.md` · `tool/measure_rules.dart`) 모두 같음

---
*Phase: 05-documentation*
*Completed: 2026-10-14*
