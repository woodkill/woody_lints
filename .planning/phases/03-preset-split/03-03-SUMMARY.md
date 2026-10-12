---
phase: 03-preset-split
plan: 03
subsystem: testing
tags: [verify-harness, fixtures, golden, riverpod_lint, analysis-options, preset-split]

# Dependency graph
requires:
  - phase: 03-preset-split
    provides: "03-02 의 lib/ 다섯 파일(조각 셋 · 묶음 · 별칭)과 [2/4] 규칙 검사(조각 셋 · lib/*.yaml 집합 확인), 03-01 의 --update 안전장치"
provides:
  - "tool/verify.dart 의 Fixture 표 (example → recommended → base_only → base_riverpod → base_codegen → overrides), 단계 3 + N = 9개"
  - "[3/9] 연습용 프로젝트 옵션 파일 — 여섯 파일을 한 단계에서 통째로 견주고 overrides 의 version: 을 lib/riverpod.yaml 의 선언과 견준다 (pluginConstraintToken, readShippedPluginConstraint)"
  - "recommended 는 자기 정답지 없이 같은 실행의 example 결과와 견준다 (Expected.fromOutcome, StepResult.outcome)"
  - "PluginVersion.notApplicable (해당 없음), summarizePluginVersion, StepResult.resultWord (바뀐 줄 없음 / 갱신), --update 의 일괄 쓰기와 '정답지를 썼다 (N개):' 목록"
  - "fixtures/ 다섯 폴더와 정답지 넷 — base_only exit 2 · 18줄, base_riverpod exit 2 · 21줄, base_codegen exit 0 · 13줄, overrides exit 2 · 18줄"
  - "fixtures/overrides/lib/suppress/ 5파일 — 끄는 방법 여섯 칸과 접두사 없는 주석이 끄지 못하는 모양"
  - ".gitignore 의 !fixtures/*/pubspec.lock, 루트 analysis_options.yaml 의 'fixtures/**'"
  - "example/README.md 의 '연습용 프로젝트 여섯' 절 · 단계 9개 설명 · M18 · M19, CHANGELOG 검증 불릿"
affects: [03-04, phase-04-rule-selection, phase-05-docs, phase-06-release, tool/verify.dart, fixtures/]

# Actuals (#2632)
actuals:
  tokens: 34264
  tasks: 3
  commits: 3
plan_head_before: f01228afaa48e96dfeb3cee9976456f67662562a
plan_head_after: 25e980e74671c1304dd9bf8333bf2bd68815bfdf

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "연습용 프로젝트 표(Fixture) 하나가 pub get 대상 · [3/N] 의 옵션 파일 · 정답지 자리 · 상태 폴더(.dart_tool/woody_verify/<path>/) · 화면 라벨을 정한다"
    - "대조군은 남는 줄로 증명한다 — base_only 의 생성 파일 4줄 · invalid_annotation_target 1줄, overrides 의 대조 줄 4줄"
    - "자기 정답지 없는 fixture(recommended)는 같은 실행의 앞선 fixture 결과와 견준다"
    - "fixture 의 선언이 조각과 같아야 하는 줄은 optionsLines 에 토큰으로 두고 [3/N] 이 조각에서 읽은 값으로 바꿔 견준다"

key-files:
  created:
    - fixtures/recommended/analysis_options.yaml
    - fixtures/base_only/expected_diagnostics.txt
    - fixtures/base_riverpod/expected_diagnostics.txt
    - fixtures/base_codegen/expected_diagnostics.txt
    - fixtures/overrides/analysis_options.yaml
    - fixtures/overrides/expected_diagnostics.txt
    - fixtures/overrides/lib/suppress/plugin_line.dart
  modified:
    - tool/verify.dart
    - analysis_options.yaml
    - .gitignore
    - example/README.md
    - CHANGELOG.md

key-decisions:
  - "검증 명령은 연습용 프로젝트 여섯을 Fixture 표 순서(example → recommended → base_only → base_riverpod → base_codegen → overrides)로 차례로 돌려 단계 9개를 찍는다. 단계 수는 results.length 로 셈하고, recommended 는 자기 정답지 없이 같은 실행의 example 결과와 견준다 (2026-10-12, 점검 통과 (9개 중 9개))"
  - "새 정답지 넷(base_only exit 2 · 18줄, base_riverpod exit 2 · 21줄, base_codegen exit 0 · 13줄, overrides exit 2 · 18줄)은 --update 로 처음 썼고 03-RESEARCH.md 권고 11 의 전문과 줄 단위로 같았다 (Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12). plugin 을 쓰지 않는 둘의 머리 주석은 riverpod_lint 해당 없음 이다"
  - "--update 는 바뀐 정답지만 쓰고 끝에 '정답지를 썼다 (N개):' 와 목록을 찍는다. 바뀐 것이 없으면 '바뀐 정답지가 없다 — 쓰지 않았다' 이고 머리 주석의 날짜도 다시 쓰지 않는다 (정답지 hash 불변 확인)"
  - "[3/9] 는 overrides 의 version: 줄을 lib/riverpod.yaml 의 riverpod_lint 선언으로 바꿔 견준다 — 03-04 가 하한을 올릴 때 fixtures/overrides/analysis_options.yaml 의 version 도 함께 올리지 않으면 [3/9] 가 실패한다 (^3.1.9 로만 바꾼 실행에서 [3/9] 만 실패 확인)"
  - "M18 (묶음에서 riverpod.yaml 제거)에서 실패한 것은 [4/9] example 하나였다 — recommended 는 example 과 똑같이 깨져 통과했고, overrides 는 자기 옵션 파일의 plugins: 선언으로 plugin 이 돌아 통과했다 (계획 A-03-2 의 예상 '[9/9] overrides 실패' 와 다름). 묶음의 Riverpod 조각은 example 의 정답지 하나가 지킨다"
  - "M19 (overrides 의 version: 제거)는 [3/9] 와 [9/9] 가 함께 잡는다 — version 없는 끄기가 경고 없이 무시되어 lib/main.dart:5 missing_provider_scope 가 되살아났다 (2026-10-12)"
  - "연습용 프로젝트 여섯의 검증 시간은 로컬에서 처음 실행(상태 폴더를 비움) 69초, 재실행 20 ~ 23초다. plugin 폴더는 example 1 · recommended 1 · base_only 0 · base_riverpod 1 · base_codegen 0 · overrides 1 이다 (2026-10-12)"

patterns-established:
  - "새 연습용 프로젝트는 fixtures/<이름>/ 에 example/lib 의 글자 그대로 복사본과 path 만 바꾼 lock 으로 만들고, fixtures 표에 한 행을 더한다 — 상태 폴더 · 옵션 파일 검사 · 단계 수가 따라온다"
  - "example/lib 의 샘플을 고치면 fixtures/ 다섯 복사본도 함께 고치고 --update 로 정답지 다섯을 한 번에 다시 쓴다"

requirements-completed: [PRESET-01, PRESET-02, PRESET-03, PRESET-07, PRESET-08, VERIFY-05]

coverage:
  - id: D1
    description: "검증 명령이 연습용 프로젝트 여섯 · 단계 9개를 돌려 종료 코드 0, 점검 통과 (9개 중 9개), 단계 라벨이 must_haves 첫 truth 와 같다"
    requirement: "VERIFY-05"
    verification:
      - kind: integration
        ref: "fvm dart run tool/verify.dart (03-03-PLAN.md Task 2 · 3 <automated>)"
        status: pass
    human_judgment: false
  - id: D2
    description: "recommended (묶음 한 줄) 가 자기 정답지 없이 같은 실행의 example 결과와 같다"
    requirement: "PRESET-08"
    verification:
      - kind: integration
        ref: "[5/9] recommended (묶음) 통과 + test ! -e fixtures/recommended/expected_diagnostics.txt (03-03-PLAN.md Task 1 <automated>)"
        status: pass
    human_judgment: false
  - id: D3
    description: "base_only 대조군 — exit 2 · 18줄, riverpod_lint 0줄, 생성 파일 4줄과 invalid_annotation_target 1줄이 남는다"
    requirement: "PRESET-01"
    verification:
      - kind: integration
        ref: "03-03-PLAN.md Task 1 <automated> (정답지 줄 단언 + [6/6] 통과), 권고 11 전문과 diff 같음"
        status: pass
    human_judgment: false
  - id: D4
    description: "base_riverpod — exit 2 · 21줄 (plugin 3줄 포함, 생성 파일 4줄 · invalid_annotation_target 1줄 남음)"
    requirement: "PRESET-02"
    verification:
      - kind: integration
        ref: "03-03-PLAN.md Task 2 <automated>, 권고 11 전문과 diff 같음"
        status: pass
    human_judgment: false
  - id: D5
    description: "base_codegen — exit 0 · 13줄, 생성 파일 · invalid_annotation_target · plugin 줄 0 (Dart 3.13.4 의 규칙 진단 기준)"
    requirement: "PRESET-03"
    verification:
      - kind: integration
        ref: "03-03-PLAN.md Task 2 <automated>, 권고 11 전문과 diff 같음"
        status: pass
    human_judgment: false
  - id: D6
    description: "overrides — 끈 자리 여섯이 없고 대조 줄 넷(lint_line:6, plugin_line:11 · 13, plugin_file_unprefixed:8)이 남는다; prefer_final_locals: true · version 제거 · version 값 변경에서 [3/9] 가 실패"
    requirement: "PRESET-07"
    verification:
      - kind: integration
        ref: "03-03-PLAN.md Task 2 <automated> (break-and-restore 포함) + M19 · version ^3.1.9 실행"
        status: pass
    human_judgment: false
  - id: D7
    description: "example/README.md 의 '연습용 프로젝트 여섯' 절 · 단계 9개 설명 · M18 · M19 기록, CHANGELOG 불릿 (문장이 소유자에게 읽히는지는 문서 판단)"
    requirement: "VERIFY-05"
    verification:
      - kind: other
        ref: "03-03-PLAN.md Task 3 <automated>"
        status: pass
    human_judgment: true
    rationale: "grep 은 문구의 존재만 본다. M18 의 '계획과 다른 결과' 문장과 표가 소유자에게 읽히는지는 사람이 본다"

# Metrics
duration: 17min
completed: 2026-10-12
status: complete
---

# Phase 3 Plan 03: 연습용 프로젝트 여섯 · 단계 9개 Summary

**`tool/verify.dart` 를 `Fixture` 표 기반으로 바꿔 `example` 과 `fixtures/` 다섯(묶음 · 기본만 · 기본 + Riverpod · 기본 + codegen · 끄는 설정)을 차례로 분석하는 단계 9개로 넓히고, 정답지 넷을 `--update` 로 처음 썼다 — 넷 모두 03-RESEARCH.md 권고 11 의 전문과 줄 단위로 같고, 묶음은 자기 정답지 없이 같은 실행의 `example` 결과와 견준다**

## Performance

- **Duration:** 약 17 min
- **Started:** 2026-10-12T11:43:05Z
- **Completed:** 2026-10-12T12:00:03Z
- **Tasks:** 3
- **Files modified:** 64 (새로 59, 고침 5)

## Accomplishments

- `tool/verify.dart`: `class Fixture` (`path` · `label` · `optionsLines` · `usesPlugin` · `expectedPath`) 와 `const fixtures` 여섯. `fixtureIncludeLine` 을 지우고 `[3/9]` 의 `checkFixtureOptions(repoRoot, fixtures)` 가 여섯 옵션 파일을 한 단계로 통째로 견준다. `compareFixture(…, fixture, reference)` 는 `expectedPath == null` 이면 같은 실행의 `example` 결과와 견준다. `PluginVersion.notApplicable()` (`해당 없음`), `summarizePluginVersion`, `StepResult.outcome` · `resultWord`, `Expected.fromOutcome`, `pluginConstraintToken` · `readShippedPluginConstraint`. 단계 수는 `results.length`.
- `--update` 는 바뀐 정답지만 쓰고 `정답지를 썼다 (N개):` + 목록을 찍는다. 바뀐 것이 없으면 `바뀐 정답지가 없다 — 쓰지 않았다` (정답지 hash 불변).
- `fixtures/` 다섯 폴더: `lib/` 는 `example/lib` 의 복사본 7파일 (`diff -rq` 같음), lock 은 270행 `path: "../.."` 만 다른 복사본, 다섯 모두 `fvm dart pub get --no-example --enforce-lockfile` exit 0. `overrides` 만 `lib/suppress/` 5파일 (RESEARCH Code Examples 4 와 글자 그대로 같음 — 스크립트로 견줌).
- 정답지 넷 — 권고 11 의 전문과 줄 단위로 같다 (A-03-1 성립, 다른 곳 없음).
- `.gitignore` 의 `!fixtures/*/pubspec.lock` (`git check-ignore -v` 가 11행을 가리킴), 루트 `analysis_options.yaml` 의 `'fixtures/**'` — 루트 `fvm dart analyze` → `No issues found!`.
- `example/README.md`: `## 연습용 프로젝트 여섯` (6행 표 + 네 경우 표 + 다섯 불릿), `--update` 문단, 실행 시간, 종료 코드 표, 단계 9개 설명, `### 추가 실측 — 새 연습용 프로젝트가 헛통과가 아닌지 (03-03)` (M18 · M19). CHANGELOG 검증 불릿.

## 실행 기록 (Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12)

### Task 1 의 첫 `--update` (단계 6개, `base_only` 정답지를 처음 씀, 23초, 종료 코드 0)

```text
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/6] lib/ 에 .dart 파일 없음 .......... 통과
[2/6] 배포 파일의 규칙 이름 ............ 통과
[3/6] 연습용 프로젝트 옵션 파일 ........ 통과
[4/6] example (옛 주소) ................ 바뀐 줄 없음
[5/6] recommended (묶음) ............... 통과
[6/6] base_only (기본만) ............... 갱신

정답지 갱신 대상: fixtures/base_only/expected_diagnostics.txt
종료 코드: 정답지 없음, 실제 2
+ lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
… (18줄 — 아래 정답지 전문과 같음)
+ lib/should_not_appear.dart:5  warning  invalid_annotation_target
머리 주석: # 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 해당 없음, 2026-10-12

정답지를 썼다 (1개):
  fixtures/base_only/expected_diagnostics.txt

점검 통과 (6개 중 6개)
```

바로 뒤의 보통 실행은 12초 · `점검 통과 (6개 중 6개)`, 다시 돌린 `--update` 는 `[4/6]` · `[6/6]` 이 `바뀐 줄 없음`, `바뀐 정답지가 없다 — 쓰지 않았다`, 정답지 hash 불변.

### Task 2 의 `--update` (단계 9개, 정답지 셋을 처음 씀, 46초, 종료 코드 0)

```text
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/9] lib/ 에 .dart 파일 없음 .......... 통과
[2/9] 배포 파일의 규칙 이름 ............ 통과
[3/9] 연습용 프로젝트 옵션 파일 ........ 통과
[4/9] example (옛 주소) ................ 바뀐 줄 없음
[5/9] recommended (묶음) ............... 통과
[6/9] base_only (기본만) ............... 바뀐 줄 없음
[7/9] base_riverpod .................... 갱신
[8/9] base_codegen ..................... 갱신
[9/9] overrides (끄는 설정) ............ 갱신

정답지 갱신 대상: fixtures/base_riverpod/expected_diagnostics.txt
종료 코드: 정답지 없음, 실제 2
+ … (21줄)
머리 주석: # 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12

정답지 갱신 대상: fixtures/base_codegen/expected_diagnostics.txt
종료 코드: 정답지 없음, 실제 0
+ … (13줄)
머리 주석: # 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 해당 없음, 2026-10-12

정답지 갱신 대상: fixtures/overrides/expected_diagnostics.txt
종료 코드: 정답지 없음, 실제 2
+ … (18줄)
머리 주석: # 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12

정답지를 썼다 (3개):
  fixtures/base_riverpod/expected_diagnostics.txt
  fixtures/base_codegen/expected_diagnostics.txt
  fixtures/overrides/expected_diagnostics.txt

점검 통과 (9개 중 9개)
```

(화면의 `+ …` 줄은 아래 전문과 같다 — 여기서는 줄였다.)

### 정답지 넷의 전문

`fixtures/base_only/expected_diagnostics.txt` (`exit 2` · 18줄):

```text
# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 해당 없음, 2026-10-12
# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: fvm dart run tool/verify.dart --update
exit 2
lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
lib/added_rules.dart:18  info  always_declare_return_types
lib/added_rules.dart:24  info  prefer_final_locals
lib/added_rules.dart:29  info  prefer_single_quotes
lib/added_rules.dart:33  info  unawaited_futures
lib/added_rules.dart:7  info  prefer_const_constructors
lib/base_rules.dart:12  info  sort_child_properties_last
lib/base_rules.dart:17  info  use_build_context_synchronously
lib/base_rules.dart:22  info  avoid_print
lib/base_rules.dart:30  info  control_flow_in_finally
lib/base_rules.dart:34  info  slash_for_doc_comments
lib/base_rules.dart:38  info  prefer_is_empty
lib/base_rules.dart:8  info  sized_box_for_whitespace
lib/generated/sample.freezed.dart:4  info  avoid_print
lib/generated/sample.freezed.dart:4  info  prefer_single_quotes
lib/generated/sample.g.dart:4  info  avoid_print
lib/generated/sample.g.dart:4  info  prefer_single_quotes
lib/should_not_appear.dart:5  warning  invalid_annotation_target
```

`fixtures/base_riverpod/expected_diagnostics.txt` (`exit 2` · 21줄): 머리 주석 `# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12` + 같은 `# 형식:` 줄, `exit 2`, 위 `base_only` 의 18줄에 아래 3줄을 더해 정렬한 것 (`lib/generated/…` 다음, `lib/should_not_appear.dart` 앞):

```text
lib/main.dart:5  warning  missing_provider_scope
lib/riverpod_rules.dart:17  warning  provider_parameters
lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties
```

`fixtures/base_codegen/expected_diagnostics.txt` (`exit 0` · 13줄): 머리 주석 `riverpod_lint 해당 없음`, `exit 0`, 위 `base_only` 의 첫 13줄(`lib/added_rules.dart` 6줄 + `lib/base_rules.dart` 7줄)과 같다.

`fixtures/overrides/expected_diagnostics.txt` (`exit 2` · 18줄):

```text
# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12
# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: fvm dart run tool/verify.dart --update
exit 2
lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
lib/added_rules.dart:18  info  always_declare_return_types
lib/added_rules.dart:29  info  prefer_single_quotes
lib/added_rules.dart:33  info  unawaited_futures
lib/added_rules.dart:7  info  prefer_const_constructors
lib/base_rules.dart:12  info  sort_child_properties_last
lib/base_rules.dart:17  info  use_build_context_synchronously
lib/base_rules.dart:22  info  avoid_print
lib/base_rules.dart:30  info  control_flow_in_finally
lib/base_rules.dart:34  info  slash_for_doc_comments
lib/base_rules.dart:38  info  prefer_is_empty
lib/base_rules.dart:8  info  sized_box_for_whitespace
lib/riverpod_rules.dart:17  warning  provider_parameters
lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties
lib/suppress/lint_line.dart:6  info  prefer_single_quotes
lib/suppress/plugin_file_unprefixed.dart:8  warning  provider_parameters
lib/suppress/plugin_line.dart:11  warning  provider_parameters
lib/suppress/plugin_line.dart:13  warning  provider_parameters
```

권고 11 과의 비교: 넷 모두 `diff` 출력 없음 (base_only 는 머리 주석까지 파일 통째로, 나머지 셋은 진단 줄 · `exit` 줄을 RESEARCH 의 줄 범위에서 만든 기대값과 견줌). A-03-1 의 "다르면 까닭을 적는다" 에 해당하는 것은 없다.

### 시간과 plugin 폴더

| 실행 | 시간 |
|---|---|
| 상태 폴더 `.dart_tool/woody_verify/` 를 옆으로 옮겨 비운 첫 실행 (plugin 을 쓰는 넷이 각각 받아 컴파일) | 69초 |
| 그 직후 재실행 | 23초 |
| 그 밖의 재실행 (Task 2 · 3 중) | 22초 · 22초 · 22초 (M19 를 되돌린 직후의 실행 포함) · 32초 (`overrides` 의 `version` 을 바꿨다 되돌린 직후) |
| 참고: 단계 6개일 때의 재실행 | 12초 |

옮겨 둔 옛 상태 폴더는 첫 실행을 잰 뒤 지웠다 (새 상태 폴더가 그 자리를 대신한다 — 스크립트가 지우지 않는 전용 폴더이고 `.gitignore` 의 `.dart_tool/` 대상).

plugin 폴더 (`.dart_tool/woody_verify/<경로>/.plugin_manager/*/`): `example` 1, `fixtures/recommended` 1, `fixtures/base_only` 0, `fixtures/base_riverpod` 1, `fixtures/base_codegen` 0, `fixtures/overrides` 1. 화면의 `plugin` 줄은 넷이 같은 값이라 `riverpod_lint 3.1.9`.

### `[3/9]` 지워 보기 (커밋하지 않고 되돌림 — 아직 추적 전이라 scratch 의 복사본으로 되돌리고 `cmp` 로 같음 확인)

| 변경 | 종료 코드 | 실패 단계 | 결과 줄 |
|---|---|---|---|
| `overrides` 의 `prefer_final_locals: false` → `true` | 1 (`점검 실패 (9개 중 2개)`) | `[3/9]`, `[9/9]` | `` `fixtures/overrides/analysis_options.yaml` 이 정해진 내용이 아니다 — 주석·빈 줄을 뺀 내용 (9줄): `` … / `[9/9]`: `정답지에 없는데 나온 경고 (1)` `lib/added_rules.dart:24  info  prefer_final_locals` |
| (계획 밖) `overrides` 의 `version: ^3.1.3` → `^3.1.9` | 1 (`점검 실패 (9개 중 1개)`) | `[3/9]` 만 | 실제 `version: ^3.1.9` / 정해진 `version: ^3.1.3` — 진단은 같아 `[9/9]` 통과 |

### M18 · M19 (Task 3, `git checkout` 으로 되돌림)

| # | 변경 | 종료 코드 | 실패 단계 | 차이 | 시간 |
|---|---|---|---|---|---|
| M18 | `lib/recommended.yaml` 에서 `- package:woody_lints/riverpod.yaml` 삭제 | 1 (`점검 실패 (9개 중 1개)`) | `[4/9] example` 만 | `종료 코드: 정답지 2, 실제 0`, `- ` plugin 3줄 | 17초 |
| M19 | `fixtures/overrides/analysis_options.yaml` 에서 `    version: ^3.1.3` 삭제 | 1 (`점검 실패 (9개 중 2개)`) | `[3/9]`, `[9/9]` | `[9/9]`: `+ lib/main.dart:5  warning  missing_provider_scope` | 23초 |

되돌린 뒤 보통 실행 22초 · `점검 통과 (9개 중 9개)`.

## Task Commits

1. **Task 1: 연습용 프로젝트 표 · recommended · base_only** - `91bbeec` (feat) — `tool/verify.dart`, `analysis_options.yaml`, `.gitignore`, `fixtures/recommended/**` (10파일), `fixtures/base_only/**` (11파일). `pubspec.lock` 둘이 커밋에 들어 있다 (`git show --stat`).
2. **Task 2: base_riverpod · base_codegen · overrides 와 정답지 셋, 단계 9개** - `9ed0fe5` (feat) — `tool/verify.dart` 와 세 폴더 38파일 (lock 셋 · 정답지 셋 · `lib/suppress/` 5파일 포함).
3. **Task 3: example/README.md · CHANGELOG** - `25e980e` (docs).

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP · REQUIREMENTS 의 커밋 (docs)

## Files Created/Modified

- `tool/verify.dart` — Fixture 표, `[3/N]` 통합 검사, `recommended` 비교, `해당 없음`, plugin 줄 요약, `--update` 일괄 쓰기, 선언 대조 (1267 → 1545행)
- `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/` — `pubspec.yaml` · `pubspec.lock` · `analysis_options.yaml` · `lib/` 7파일, 정답지 넷 (`recommended` 는 없음), `overrides/lib/suppress/` 5파일
- `analysis_options.yaml` — exclude `'fixtures/**'`, 주석 "example/ 과 fixtures/"
- `.gitignore` — `!fixtures/*/pubspec.lock` + 주석
- `example/README.md` — 여섯 · 아홉 구조, M18 · M19
- `CHANGELOG.md` — 검증 불릿 한 줄

## Decisions Made

- `expectedPath` 에는 문자열 대신 기존 상수 `expectedFileName` 을 썼다 (같은 값, 이름 하나를 두 곳에 적지 않으려고).
- 실패 내용(`detailLines`)의 첫 줄에 fixture 경로를 붙였다 (`fixtures/overrides/expected_diagnostics.txt 와 다르다.` 등) — 단계 줄 아래에 모아 찍으므로 여섯 가운데 어느 것의 실패인지 보이게.
- `recommended` 의 종료 코드 어긋남 줄은 `종료 코드: example 2, 실제 0` 꼴로 바꿔 찍는다 (정답지 파일이 없으므로).
- `--update` 에서 `updaters` 가 비었으면 다른 단계가 실패했어도 `바뀐 정답지가 없다 — 쓰지 않았다` 를 찍는다 (쓸 것이 없으니 거부 문구가 필요 없다). 쓸 것이 있고 실패가 있으면 기존 거부 문구 그대로.
- `Expected.fromOutcome` 은 `lines == null` 이면 `StateError` — 부르는 쪽(`compareFixture`)이 먼저 거른다.

## Deviations from Plan

None — 계획의 동작 그대로 구현했다. 계획의 예상과 다른 **실측 결과** 하나는 아래 Issues 에 적었다 (코드 변경 없음).

## Issues Encountered

- **M18 에서 `[9/9] overrides` 가 실패하지 않았다.** 계획 A-03-2 는 "`example` 과 `overrides` 실패, `recommended` 통과" 를 예상했지만 실제로는 `[4/9] example` 하나만 실패했다 (`점검 실패 (9개 중 1개)`). `overrides` 는 끄는 설정을 위해 자기 옵션 파일의 `plugins:` 에 `riverpod_lint` 를 `version` 과 함께 다시 적으므로, 묶음이 Riverpod 조각을 잃어도 그 선언으로 plugin 이 돈다 — spike 012 의 "적은 값이 그 프로젝트의 plugin 버전 선언이 된다" 와 맞는 결과다 (까닭을 따로 갈라 재지는 않았다). README 의 M18 행과 읽는 법에 실제 값으로 적었다. 결과: 묶음의 Riverpod 조각을 지키는 것은 `example` 의 정답지 하나다. Task 3 gate 의 문자열(`` `recommended` 는 통과한다 ``)은 실제 값과 맞아 그대로 통과했다.
- 계획의 `<automated>` 셋은 `; RC=$?;` 로 이어진 꼴이라 마지막 구간의 종료 코드만 남는다. 구간마다 종료 코드를 찍게 바꾼 사본으로도 돌려 모든 구간이 0 (M 실행 구간의 `RD=1` 은 기대값) 인 것을 확인했다.
- plan 의 `<automated>` 를 zsh 에서 돌리면 빈 glob(`ls -d …/*/`)이 명령을 끊으므로 `bash` 로 돌렸다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 03-04: `lib/riverpod.yaml` 10행을 `^3.1.9` 로 올릴 때 `fixtures/overrides/analysis_options.yaml` 의 `version: ^3.1.3` 도 **같은 커밋에서** 올려야 `[3/9]` 가 통과한다 (`^3.1.9` 로 overrides 만 바꾼 실행에서 `[3/9]` 만 실패 확인 — 반대 방향도 같은 비교다). 정답지 다섯은 바뀌지 않을 것으로 본다 (두 선언 모두 3.1.9 로 풀림 — spike 010 · 012, 이 plan 의 version 실행).
- 03-04 의 GitHub runner 실행: 로컬 첫 실행 69초 · 재실행 약 22초. runner 의 값은 아직 없다 (spike 017 의 추정은 job 약 3분 20초 ~ 4분 20초).
- Phase 4: 규칙을 바꾸면 정답지 다섯이 함께 바뀐다 — `--update` 한 번이 바뀐 것만 쓰고 목록을 찍는다. `example/lib` 샘플을 고치면 `fixtures/` 다섯 복사본도 함께 고친다.
- Phase 6: 루트 `pubspec.yaml` 의 `version` 을 올리면 lock 여섯이 모두 어긋난다 (`example/` + `fixtures/` 다섯).
- 이 plan 의 커밋 셋은 push 하지 않았다. `main` 은 `90a2736` 그대로다.

## Self-Check: PASSED

- FOUND: `tool/verify.dart`, `analysis_options.yaml`, `.gitignore`, `fixtures/recommended/analysis_options.yaml`, `fixtures/base_only/expected_diagnostics.txt`, `fixtures/base_riverpod/expected_diagnostics.txt`, `fixtures/base_codegen/expected_diagnostics.txt`, `fixtures/overrides/expected_diagnostics.txt`, `fixtures/overrides/lib/suppress/plugin_line.dart`, `example/README.md`, `CHANGELOG.md`
- FOUND: `91bbeec`, `9ed0fe5`, `25e980e` (HEAD 의 조상); `git rev-list --count f01228a..HEAD` = 3
- Task 2 · Task 3 의 `<automated>` 를 마지막 커밋 뒤에 다시 돌려 둘 다 종료 코드 0 (Task 1 의 것은 단계 6개 상태를 단언하므로 Task 1 커밋 전에 돌려 0). plan `<verification>` 의 기준 커밋 비교(`19ae5ec` 정답지, `74fafb2` example/lib, `ac5cced` example 설정, `968a5bb` pubspec · README, `008ea3f` workflow, `lib` 은 03-02 그대로) 모두 통과, `fixtures/recommended/expected_diagnostics.txt` 없음, `build/` 없음, `git status --short -- lib fixtures tool example` 비어 있음

---
*Phase: 03-preset-split*
*Completed: 2026-10-12*
