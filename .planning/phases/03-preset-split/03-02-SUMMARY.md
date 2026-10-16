---
phase: 03-preset-split
plan: 02
subsystem: config
tags: [analysis-options, preset-split, include-chain, verify-harness, riverpod_lint]

# Dependency graph
requires:
  - phase: 03-preset-split
    provides: "03-01 의 [2/4] 판정 순서(도구 사망 → 깨진 옵션 파일 → include_file_not_found → 규칙 0개 → 진단 있음 → 통과)와 readParseErrorLines"
provides:
  - "lib/ 의 YAML 다섯 — 조각 base.yaml (47줄) · codegen.yaml (7줄) · riverpod.yaml (10줄), 묶음 recommended.yaml, 옛 주소 별칭 analysis_options.yaml (3줄)"
  - "tool/verify.dart 의 ruleCheckTargets · rulesFile · expectedLibYamls · ruleCheckLabel · fragmentLineHint 상수와 stripPlugins(options, {shownAs}) · checkLibYamlSet · fragmentName · fragmentNameOfLine"
  - "[2/4] 가 조각 셋을 build/woody_rule_check/{base,codegen,riverpod}/analysis_options.yaml 로 복사해 폴더 하나를 인자로 한 번에 분석"
  - "루트 analysis_options.yaml 의 exclude 는 'example/**' 하나 (lib/analysis_options.yaml 제외 걷어냄)"
  - "CHANGELOG 2.0.0 의 프리셋 분리 · 옛 주소 별칭 · 루트 제외 정리 불릿과 올리기 전에 의 옛 주소 안내"
affects: [03-03, 03-04, phase-04-rule-selection, phase-05-docs, tool/verify.dart, lib/]

# Actuals (#2632)
actuals:
  tokens: 6351
  tasks: 2
  commits: 2
plan_head_before: 6029ee98d39b4ed45d30602ea5edb208b66546a9
plan_head_after: 933b26f0072b1b526dcef48732a9486db750b49e

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "조각은 sed 줄 범위로 잘라 만들고 이어 붙여 원본(90a2736)과 diff 로 견준다 (Pattern 1)"
    - "규칙 검사 대상은 조각 셋 전부, lib/*.yaml 집합 확인으로 새 조각이 대상에서 빠지면 실패"
    - "진단 줄 경로의 하위 폴더 이름(build/woody_rule_check/<이름>/)으로 그 조각의 복사본 줄을 골라 규칙 이름을 읽는다"

key-files:
  created:
    - lib/base.yaml
    - lib/codegen.yaml
    - lib/riverpod.yaml
    - lib/recommended.yaml
  modified:
    - lib/analysis_options.yaml
    - tool/verify.dart
    - analysis_options.yaml
    - CHANGELOG.md
    - example/README.md

key-decisions:
  - "lib/ 는 조각 셋(base · codegen · riverpod) + 묶음 recommended.yaml + 옛 주소 별칭 analysis_options.yaml 의 다섯 파일이다. 조각은 90a2736 의 lib/analysis_options.yaml 을 sed 줄 범위(1~41+59~64 / 42~48 / 49~58)로 잘라 만들었고 이어 붙이면 원본과 같다 (diff 종료 코드 0)"
  - "[2/4] 는 lib/ 의 YAML 집합 확인을 먼저 하고, 조각 셋을 build/woody_rule_check/<조각 이름>/analysis_options.yaml 로 복사해 폴더 하나를 인자로 한 번 분석한다. 규칙 0개 확인은 rulesFile(lib/base.yaml)에만 건다"
  - "stripPlugins 는 plugins: 섹션이 있으면 빼고 없으면 그대로 돌려주며, 뺀 뒤에도 ^plugins: 가 남으면 FormatException 이다. riverpod.yaml 의 복사본은 plugins: 두 줄을 뺀 것이라 그 뒤에 적은 줄은 원본보다 2 앞당겨진다 — 실패 문구에 그렇게 적었다"
  - "루트 analysis_options.yaml 의 exclude 는 'example/**' 하나이고, lib/analysis_options.yaml 제외 없이 루트 fvm dart analyze 가 exit 0 · No issues found 다 (Dart 3.13.4, 2026-10-12). 주석에는 SDK 에 묶인 이유(plugin 준비)를 적지 않았다"

patterns-established:
  - "새 조각을 더하면 tool/verify.dart 의 ruleCheckTargets 와 expectedLibYamls 를 함께 고친다 — 안 고치면 [2/4] 의 집합 확인이 실패한다"
  - "[2/4] 실패 문구는 진단 줄의 폴더 이름을 조각 이름으로 읽게 안내한다 (lib/<이름>.yaml)"

requirements-completed: [PRESET-04, PRESET-06, PRESET-08]

coverage:
  - id: D1
    description: "lib/ 가 조각 셋 + 묶음 + 별칭의 다섯 파일이고, 조각을 이어 붙이면 90a2736 의 원본과 같으며, base.yaml 의 규칙 줄 번호(23 ~ 40행)가 원본과 같다"
    requirement: "PRESET-08"
    verification:
      - kind: other
        ref: "{ sed -n '1,41p' lib/base.yaml; cat lib/codegen.yaml lib/riverpod.yaml; sed -n '42,47p' lib/base.yaml; } | diff - <(git show 90a2736:lib/analysis_options.yaml)"
        status: pass
      - kind: other
        ref: "03-02-PLAN.md Task 1 <automated>"
        status: pass
    human_judgment: false
  - id: D2
    description: "옛 주소 한 줄을 쓰는 example/ 의 정답지가 나누기 전후로 그대로이고 검증 명령이 종료 코드 0 · 점검 통과 (4개 중 4개)"
    requirement: "PRESET-04"
    verification:
      - kind: integration
        ref: "fvm dart run tool/verify.dart && git diff --quiet 19ae5ec -- example/expected_diagnostics.txt"
        status: pass
    human_judgment: false
  - id: D3
    description: "[2/4] 가 riverpod.yaml 끝에 숨긴 deprecated 규칙과 lib/ 의 여분 YAML 을 잡는다 (종료 코드 1)"
    requirement: "PRESET-04"
    verification:
      - kind: integration
        ref: "03-02-PLAN.md Task 1 <automated> 의 지워 보기 둘 (riverpod.yaml 에 linter 블록 추가, lib/_probe_extra.yaml) — 되돌림 확인 포함"
        status: pass
    human_judgment: false
  - id: D4
    description: "루트 analysis_options.yaml 에 lib/analysis_options.yaml 제외가 없고 루트 fvm dart analyze 가 exit 0 · No issues found, plugins_in_inner_options 없음"
    requirement: "PRESET-06"
    verification:
      - kind: other
        ref: "03-02-PLAN.md Task 2 <automated>"
        status: pass
    human_judgment: false
  - id: D5
    description: "CHANGELOG 2.0.0 항목과 example/README.md 5행이 나눈 구조를 말한다 (문장이 읽는 사람에게 맞는지는 문서 판단)"
    requirement: "PRESET-08"
    verification:
      - kind: other
        ref: "03-02-PLAN.md Task 2 <automated> (grep 단언 + 옛 항목 꼬리 불변)"
        status: pass
    human_judgment: true
    rationale: "grep 은 문구의 존재만 본다. 불릿의 등급 판정(minor)과 문장이 소유자에게 읽히는지는 사람이 본다"

# Metrics
duration: 4min
completed: 2026-10-12
status: complete
---

# Phase 3 Plan 02: 프리셋 나누기 (조각 셋 · 묶음 · 옛 주소 별칭) Summary

**`lib/analysis_options.yaml` 을 sed 줄 범위로 잘라 `base.yaml` · `codegen.yaml` · `riverpod.yaml` 조각과 `recommended.yaml` 묶음, 3줄짜리 옛 주소 별칭으로 나누고, 같은 커밋에서 `[2/4]` 규칙 검사를 조각 셋 · `lib/*.yaml` 집합 확인으로 넓혔다 — 옛 주소 `example/` 정답지는 한 줄도 바뀌지 않았고 루트 분석은 배포 파일 제외 없이 0건이다**

## Performance

- **Duration:** 약 4 min
- **Started:** 2026-10-12T11:34:52Z
- **Completed:** 2026-10-12T11:38:36Z
- **Tasks:** 2
- **Files modified:** 9 (새로 4, 고침 5)

## Accomplishments

- 조각 셋을 `sed` 로만 만들었다 (`base.yaml` 47줄 = 옛 1~41 + 59~64행, `codegen.yaml` 7줄 = 42~48행, `riverpod.yaml` 10줄 = 49~58행). 이어 붙인 결과가 `git show 90a2736:lib/analysis_options.yaml` 과 `diff` 출력 없이 **종료 코드 0**. `base.yaml` 23행 `prefer_const_constructors`, 40행 `control_flow_in_finally` — 규칙 줄 번호가 원본과 같다.
- 묶음 `recommended.yaml` (주석 2줄 + base → riverpod → codegen 의 `package:` 목록)과 별칭 `lib/analysis_options.yaml` (주석 2줄 + `include: package:woody_lints/recommended.yaml`)을 RESEARCH Code Examples 2 그대로 썼다.
- `tool/verify.dart`: `shippedOptionsPath` 를 지우고 `ruleCheckTargets` · `rulesFile` · `expectedLibYamls` 를 두었다. `stripPlugins(options, {required shownAs})` 는 "있으면 뺀다" + 뺀 뒤 `^plugins:` 가 남으면 `FormatException`. `checkLibYamlSet` 이 `[2/4]` 의 첫 확인이다. 복사본은 `build/woody_rule_check/{base,codegen,riverpod}/analysis_options.yaml` 셋이고 분석은 폴더 하나를 인자로 한 번.
- 루트 `analysis_options.yaml` 을 권고 7 의 문장(`fixtures/**` 없이)으로 다시 써 `lib/analysis_options.yaml` 제외를 걷어냈다. 루트 `fvm dart analyze` → `No issues found!`, exit 0.
- CHANGELOG 2.0.0 의 `### 그 밖의 변경` 에 세 불릿, `### 올리기 전에` 에 옛 주소 안내 한 줄. `example/README.md` 5행의 배포 파일 문구를 조각 · 묶음 · 별칭으로.

## 실행 기록 (Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12)

Pattern 1 (Task 1 직후와 plan 끝 두 번):

```text
{ sed -n '1,41p' lib/base.yaml; cat lib/codegen.yaml lib/riverpod.yaml; sed -n '42,47p' lib/base.yaml; } | diff - <(git show 90a2736:lib/analysis_options.yaml)
(출력 없음) pattern1-rc=0
```

검증 명령 화면 (`933b26f`, 종료 코드 0):

```text
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

점검 통과 (4개 중 4개)
```

지워 보기 (커밋하지 않고 되돌림 — `riverpod.yaml` 은 scratch 의 복사본으로 되돌리고 `cmp` 로 같음 확인, `_probe_extra.yaml` 은 지움, `build/woody_rule_check` 남지 않음):

| 입력 | 종료 코드 | `[2/4]` 결과 줄 |
|---|---|---|
| (a) `lib/riverpod.yaml` 끝에 `linter:` / `  rules:` / `    - unnecessary_await_in_return` | 1 (`점검 실패 (4개 중 1개)`, `[4/4]` 는 통과) | `build/woody_rule_check/riverpod/analysis_options.yaml:11  warning  deprecated_lint  (unnecessary_await_in_return)` |
| (b) 빈 파일 `lib/_probe_extra.yaml` | 1 (`점검 실패 (4개 중 1개)`) | `` `lib/` 의 YAML 이 정해진 다섯과 다르다. `` / `더 있는 것 (1)` / `  lib/_probe_extra.yaml` |
| (c, 계획 밖 추가 확인) `lib/codegen.yaml` 끝에 닫지 않은 따옴표 `    - 'unclosed` | 1 (`점검 실패 (4개 중 2개)`, `[4/4]` 도 실패 — exit 2 → 3 과 생성 파일 · `invalid_annotation_target` 5줄) | `  error - codegen/analysis_options.yaml:9:1 - Unexpected end of file. - parse_error` |

- (a) 의 줄 번호는 plan 의 예상대로 11 이다 — 원본 `riverpod.yaml` 에서는 13행이고, 복사본이 `plugins:` 두 줄(9 ~ 10행)을 뺀 만큼 앞당겨졌다. 실패 문구 끝의 안내(`fragmentLineHint`)가 이 어긋남을 적는다.
- (c) 는 03-01 이 넘긴 "깨진 옵션 파일 문구의 `$shippedOptionsPath`" 를 조각 이름 안내로 바꾼 뒤, 형식 인자 없는 재실행의 `parse_error` 경로가 하위 폴더 이름(`codegen/`)을 담는지 보려고 돌렸다. 담는다 — 안내 "진단 줄의 폴더 이름이 조각 이름이다" 가 이 가지에서도 맞다.

루트 분석 (Task 2, 제외를 걷어낸 뒤):

```text
$ fvm dart analyze
Analyzing woody_lints...
No issues found!
(종료 코드 0, 출력에 plugins_in_inner_options 없음)
```

`find .dart_tool -maxdepth 2 -name .plugin_manager` 는 분석 전후 모두 아무것도 내지 않았다 (참고용 — 루트 분석의 상태 폴더는 기본 자리 `~/.dartServer` 다. 판정에 쓰지 않았다).

## Task Commits

1. **Task 1: 조각 셋 · 묶음 · 별칭으로 나누고 `[2/4]` 를 조각 셋으로** - `89d6073` (feat) — `lib/{base,codegen,riverpod,recommended,analysis_options}.yaml`, `tool/verify.dart` 여섯 파일. 그 커밋의 `lib/riverpod.yaml` 10행은 `  riverpod_lint: ^3.1.3`.
2. **Task 2: 루트 제외 걷어내기 · CHANGELOG · README 문구** - `933b26f` (feat) — `analysis_options.yaml`, `CHANGELOG.md`, `example/README.md` 세 파일.

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP · REQUIREMENTS 의 커밋 (docs)

## Files Created/Modified

- `lib/base.yaml` — 기본 규칙 조각 (옛 1~41 + 59~64행, 손대지 않음)
- `lib/codegen.yaml` — `analyzer.errors` / `analyzer.exclude` 조각 (옛 42~48행)
- `lib/riverpod.yaml` — plugin 설명 주석 8줄 + `plugins: riverpod_lint: ^3.1.3` (옛 49~58행)
- `lib/recommended.yaml` — 묶음 (주석 2줄 + 조각 셋 include 목록)
- `lib/analysis_options.yaml` — 옛 주소 별칭 3줄
- `tool/verify.dart` — 머리 주석 4행, 상수 다섯(`ruleCheckTargets`, `rulesFile`, `expectedLibYamls`, `ruleCheckLabel`, `fragmentLineHint`), `stripPlugins` 시그니처 · 동작, 새 함수 `fragmentName` · `fragmentNameOfLine` · `checkLibYamlSet`, `checkRuleNames` 의 복사 · 규칙 이름 읽기 · 문구
- `analysis_options.yaml` — 권고 7 의 주석, exclude `'example/**'` 하나
- `CHANGELOG.md` — 2.0.0 항목에 네 줄
- `example/README.md` — 5행 문구

## Decisions Made

- `checkLibYamlSet` 은 `StepResult?` (같으면 null) 로 했다. 단계 이름을 두 함수가 함께 쓰도록 `ruleCheckLabel` 상수를 두었다.
- 진단 줄에서 조각을 고르는 정규식은 `ruleCheckDir` 를 `RegExp.escape` 로 넣어 만든다 (`fragmentNameOfLine`) — 경로 상수가 바뀌어도 함께 따라간다.
- 실패 문구의 "복사본의 줄 번호는 원본과 같다" 에 `riverpod.yaml` 의 예외를 덧붙였다 (아래 Deviations 1).
- `readParseErrorLines` 와 `finally` 의 삭제는 그대로다 — 폴더 전체를 다시 돌리고 통째로 지운다.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] 실패 문구의 "줄 번호는 원본과 같다" 가 `riverpod.yaml` 에서 틀린다**
- **Found during:** Task 1 (action 4 의 문구 교체)
- **Issue:** plan 의 안내 꼴 "`lib/<이름>.yaml` 에서 그 줄을 고친다 (복사본의 줄 번호는 원본과 같다)" 는 `riverpod.yaml` 의 `plugins:` 섹션 뒤에 적은 줄에서 틀린다 — 지워 보기 (a) 가 원본 13행을 11행으로 보고한다 (plan 도 그렇게 예상했다).
- **Fix:** 안내 문장(`fragmentLineHint`)에 "`riverpod.yaml` 은 `plugins:` 섹션을 빼고 복사하므로 그 섹션 뒤에 적은 줄만 뺀 줄 수만큼 앞당겨진다" 를 덧붙였다. 복사 방식(섹션을 빈 줄로 바꾸지 않고 지움)은 plan · RESEARCH Code Examples 6 그대로다.
- **Files modified:** `tool/verify.dart`
- **Verification:** 지워 보기 (a) 의 화면에 그 문장이 찍히고 Task 1 `<automated>` 종료 코드 0
- **Committed in:** `89d6073`

03-01 이 넘긴 깨진 옵션 파일 문구의 `$shippedOptionsPath` 는 plan action 4 ("문구의 `$shippedOptionsPath` 는 모두 바꾼다") 의 범위라 deviation 이 아니다 — 같은 안내 문장으로 바꿨고 지워 보기 (c) 로 확인했다.

---

**Total deviations:** 1 auto-fixed (Rule 1 1건)
**Impact on plan:** 문구 정확성만 고쳤다. 동작 · 범위 변경 없음.

## Issues Encountered

None. Task 1 은 `type="tracer"` 였고, interactive · `end-of-phase` · `<automated>` 만 있는 경우라 verify 를 다시 돌려 통과한 뒤 Task 2 로 넘어갔다 (checkpoint 없음). 커밋 훅은 돌지 않았다 (설정된 훅 없음).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 03-03 (fixture 다섯 · 단계 9개): `[2/4]` 의 함수 · 상수는 이름 그대로 `[2/9]` 로 옮겨 쓸 수 있다. 루트 `analysis_options.yaml` 에 `'fixtures/**'` 한 줄과 그 주석의 "example/ 과 fixtures/" 를 더하는 일이 남았다. `example/README.md` 는 5행만 고쳤다 — 다른 문단(단계 설명 등)의 `lib/analysis_options.yaml` 언급은 03-03 이 fixture 와 함께 고친다.
- 03-04: `lib/riverpod.yaml` 10행만 `^3.1.9` 로 — 그 줄은 `  riverpod_lint: ^3.1.3` 그대로다. CHANGELOG 에 `3.1.9` 는 아직 없다.
- 이 plan 의 커밋은 push 하지 않았다 (D-09). `main` 은 `90a2736` 그대로다.
- REQUIREMENTS.md 에는 PRESET-04 · PRESET-06 만 체크했다 (`requirements.ready-ids` → ready 2, blocked 1). PRESET-08 은 03-03 도 선언하므로 03-03 의 SUMMARY 뒤에 체크된다.

## Self-Check: PASSED

- FOUND: `lib/base.yaml`, `lib/codegen.yaml`, `lib/riverpod.yaml`, `lib/recommended.yaml`, `lib/analysis_options.yaml`, `tool/verify.dart`, `analysis_options.yaml`, `CHANGELOG.md`, `example/README.md`
- FOUND: `89d6073`, `933b26f` (HEAD 의 조상)
- Task 1 · Task 2 의 `<automated>` 를 plan 에 적힌 그대로 돌려 둘 다 종료 코드 0. plan `<verification>` 의 기준 커밋 비교 다섯(`968a5bb` pubspec, `74fafb2` example/lib, `ac5cced` example 설정 셋, `008ea3f` workflow, `19ae5ec` 정답지) 모두 통과
- `git status --short -- lib tool example` 비어 있음, `build/` 없음

---
*Phase: 03-preset-split*
*Completed: 2026-10-12*
