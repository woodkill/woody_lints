---
phase: 02-verification-harness
plan: 05
subsystem: testing
tags: [dart, dart-analyze, golden-comparison, verify-script, github-actions, gap-closure]

# Dependency graph
requires:
  - phase: 02-verification-harness (plan 02-01 ~ 02-04)
    provides: 검증 명령 `tool/verify.dart` (단계 4개), `example/` 과 정답지, 지워 보기 기록 M1 ~ M9, CI workflow
provides:
  - 건수를 세는 정답지 비교 (`subtractLines` → `findDifference`) — 같은 줄이 여러 건인 입력에서도 "다르면 실패" 가 참이다
  - `--update` 의 안전장치 — 같은 실행에서 다른 단계가 실패하면 정답지를 쓰지 않고 화면에 그 사실을 찍는다
  - 규칙 이름 단계의 규칙 0개 실패 (`countDeclaredRules`)
  - `example/README.md` 의 추가 실측 기록 M10 ~ M14
  - workflow `push:` 주석의 바로잡음과 02-CONTEXT.md D-10 덧붙임
affects: [03-preset-split, 04-rule-selection, 06-release]

actuals:
  tokens: 5578
  tasks: 3
  commits: 3
plan_head_before: 2b9d334f7fbb087c5dfb4366f5f91b0095157614
plan_head_after: 008ea3f07b6e4b895023b2fbfb3d141c97ffd433

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "정답지 비교는 집합이 아니라 건수(multiset) 차집합이다 — `subtractLines(from, remove)`"
    - "`--update` 의 쓰기는 `main` 이 실행 전체의 결과를 본 뒤에만 한다 (단계는 쓰기를 `applyUpdate` 로 돌려주기만 한다)"
    - "검사가 본 대상이 0개면 통과가 아니라 실패다 (`countDeclaredRules == 0`)"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - example/README.md
    - .github/workflows/verify.yml
    - .planning/phases/02-verification-harness/02-CONTEXT.md

key-decisions:
  - "정답지 비교는 같은 줄의 건수까지 견준다 — 한 줄에 같은 규칙이 두 번 걸리면 정답지에도 그 줄이 두 번 있어야 통과한다 (CR-01 닫음)"
  - "`--update` 는 같은 실행에서 다른 단계가 실패하면 정답지를 쓰지 않는다 (종료 코드 1). plugin 버전이 `?` 인 실행의 `--update` (WR-01 case 2) 는 막지 않는다 — 소유자 결정으로 열어 둔다"
  - "`[2/4]` 는 배포 파일의 최상위 `linter:` 블록에서 규칙을 하나도 읽지 못하면 실패한다. Phase 3 이 규칙을 다른 파일로 옮기면 이 단계의 대상 파일도 함께 옮겨야 한다 (M14 로 확인)"
  - "필터 없는 `push:` 가 tag push 에서도 도는 것은 그대로 둔다 — workflow 주석과 02-CONTEXT.md D-10 덧붙임에 기록 (소유자 결정 C, 2026-10-12)"

patterns-established:
  - "gap 닫기의 실측은 M1 ~ M9 와 같은 자리(`example/README.md` 기록 절)에 새 소절로 덧붙이고, 옛 표는 고치지 않는다"
  - "`--update` 를 작업 트리에서 돌린 실험 뒤에는 결과와 상관없이 정답지를 `git checkout --` 으로 되돌린다"

requirements-completed: [VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-04, VERIFY-08]

coverage:
  - id: D1
    description: "정답지 비교가 같은 줄의 건수 차이를 두 방향 모두 실패로 보고한다 (M10 · M11, 종료 코드 1)"
    requirement: "VERIFY-01"
    verification:
      - kind: integration
        ref: "02-05-PLAN.md Task 1 <automated> (깨끗한 통과 + M10 · M11 재현 + 되돌림 증명) — 커밋 전 1회, tracer gate 1회, 끝에 1회 모두 exit 0"
        status: pass
    human_judgment: false
  - id: D2
    description: "`--update` 가 다른 단계가 실패한 실행에서는 정답지를 쓰지 않고(git hash 불변), 정답지만 다른 정상 실행에서는 쓴다. CI 에서는 64"
    requirement: "VERIFY-03"
    verification:
      - kind: integration
        ref: "02-05-PLAN.md Task 2 <automated> (M12 · M12 대조 · CI=true · M13) — 커밋 전 1회, 끝에 1회 exit 0"
        status: pass
    human_judgment: false
  - id: D3
    description: "`[2/4]` 가 규칙을 하나도 읽지 못하면 파일 이름을 찍고 실패한다 (M13 · M14)"
    requirement: "VERIFY-02"
    verification:
      - kind: integration
        ref: "02-05-PLAN.md Task 2 <automated> 의 M13 단언 exit 0; M14 는 action 에서 1회 실행 (exit 1, `[2/4]` 실패)"
        status: pass
    human_judgment: false
  - id: D4
    description: "workflow 의 `push:` 주석이 실제 동작(모든 브랜치와 tag)과 Phase 6 의 함정을 말하고, 설정은 `1f06c55` 와 같다. D-10 아래에 덧붙임 한 줄이 있다"
    requirement: "VERIFY-04"
    verification:
      - kind: other
        ref: "02-05-PLAN.md Task 3 <automated> (PyYAML 로 주석 뺀 YAML 동일성, 02-04 설정 줄 단언, CONTEXT diff 추가 1줄) exit 0"
        status: pass
    human_judgment: false
  - id: D5
    description: "`example/README.md` 의 `### 추가 실측` 소절 (M10 ~ M14) 이 몇 달 뒤의 소유자에게 읽히는가"
    requirement: "VERIFY-08"
    verification:
      - kind: other
        ref: "02-05-PLAN.md Task 3 <automated> 의 README 구조 · 문자열 단언 exit 0"
        status: pass
    human_judgment: true
    rationale: "문자열과 행 수는 자동으로 봤지만, 소절만 읽고 무엇이 막혔는지 아는지는 독자의 판단이다 (plan 의 <human-check>, end-of-phase UAT)"

# Metrics
duration: 9min
completed: 2026-10-12
status: complete
---

# Phase 2 Plan 05: 정답지 비교의 건수 세기와 `--update` · 규칙 0개 안전장치 Summary

**`tool/verify.dart` 의 정답지 비교를 건수를 세는 차집합(`subtractLines`)으로 바꿔 02-VERIFICATION.md Gap 1 을 닫고, `--update` 가 다른 단계가 실패한 실행의 결과를 정답지로 굳히지 않게, 규칙 검사가 규칙 0개를 통과로 찍지 않게 고친 뒤 M10 ~ M14 로 실제 저장소에서 확인했다**

## Performance

- **Duration:** 약 9분
- **Started:** 2026-10-12T00:59:34Z (한국 시각 2026-10-12 09:59)
- **Completed:** 2026-10-12T01:08Z (SUMMARY 를 쓰기 직전 기준)
- **Tasks:** 3 / 3
- **Files modified:** 4 (`tool/verify.dart`, `example/README.md`, `.github/workflows/verify.yml`, `02-CONTEXT.md`)
- **실측 조건:** Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64, `fvm dart run tool/verify.dart`. 로컬 날짜 2026-10-12

## Accomplishments

- 정답지 비교가 "이 줄이 있나" 가 아니라 "몇 번 있나" 까지 본다. 같은 줄이 정답지에 2개 · 실제 1건이면 `정답지에는 있는데 나오지 않은 경고 (1)`, 반대면 `정답지에 없는데 나온 경고 (1)` 로 실패한다 (종료 코드 1). 고치기 전에는 두 입력 모두 종료 코드 0 이었다
- `--update` 는 같은 실행에서 다른 단계가 실패했으면 정답지를 쓰지 않고 `다른 단계가 실패해 정답지를 쓰지 않았다 — 실패를 먼저 고친 뒤 다시 실행하세요.` 를 찍는다. 정답지만 다른 정상 실행에서는 전처럼 쓰고 `정답지를 썼다: example/expected_diagnostics.txt` 를 찍는다
- `[2/4]` 가 배포 파일에서 규칙을 하나도 읽지 못하면 파일 이름을 찍고 실패한다. 지금의 파일은 12개로 세어 통과한다
- `example/README.md` 에 설명 네 군데와 `### 추가 실측` 소절 (M10 ~ M14), workflow 의 `push:` 주석 바로잡음, 02-CONTEXT.md D-10 덧붙임 한 줄
- 실험으로 만든 변경은 모두 되돌렸다 — `lib` = `90a2736`, 정답지 = `19ae5ec`, 마지막 실행 `점검 통과 (4개 중 4개)` · 종료 코드 0

## Task Commits

1. **Task 1: `findDifference` 를 건수를 세는 차집합으로** — `37316e3` (fix) — `tool/verify.dart`
2. **Task 2: `--update` 안전장치(A)와 규칙 0개 실패(B)** — `40776b5` (fix) — `tool/verify.dart`
3. **Task 3: README 기록 M10 ~ M14, workflow 주석, D-10 덧붙임** — `008ea3f` (docs) — `example/README.md`, `.github/workflows/verify.yml`, `.planning/phases/02-verification-harness/02-CONTEXT.md`

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP · REQUIREMENTS 를 담는 `docs(02-05)` 커밋 (해시는 실행자의 최종 보고에 있다)

push 는 하지 않았다. `git rev-parse origin/gsd/v2.0-package-rework` 는 `1f06c558bcf9d5cf8ef644fba8cd9a006497e83f` 그대로다. tag 와 PR 도 만들지 않았다.

## Files Created/Modified

- `tool/verify.dart` (1010 → 1099줄) — 새 함수 `subtractLines`, `countDeclaredRules`; `StepResult.updateTarget`; `findDifference` (건수 비교), `checkRuleNames` (규칙 0개 실패), `compareFixture` (update 가지의 첫 줄 `정답지 갱신 대상:` 과 `updateTarget`), `main` (`--update` 쓰기 직전의 실패 확인과 `정답지를 썼다:` 줄). import 는 `dart:convert` · `dart:io` 그대로
- `example/README.md` (137 → 162줄) — 5행 · 65행에 "건수까지 견준다", `--update` 불릿 한 줄, 단계 설명 문단에 `[2/4]` 의 규칙 0개, 기록 절에 `### 추가 실측 — 건수 비교 · --update 안전장치 · 규칙 0개 (gap 닫기 02-05)` 소절. M1 ~ M9 표와 그 읽는 법은 그대로다
- `.github/workflows/verify.yml` — 5행 주석 한 줄을 주석 세 줄로. 설정 줄은 그대로 (주석을 뺀 YAML 이 `1f06c55` 와 같다)
- `.planning/phases/02-verification-harness/02-CONTEXT.md` — D-10 의 81행 바로 아래에 `- 덧붙임 (2026-10-12, gap 닫기 02-05): …` 한 줄. D-10 원문은 그대로 (`b2c0131` 과의 diff 가 추가 1줄)

## 실측 — 화면 원문

출력은 stdout 과 stderr 를 따로 받았다 (세션 scratchpad, 저장소 밖). 아래는 stdout 이고, stderr 는 모든 실행에서 `example/ 분석 중…` 한 줄이었다 (`CI=true` 실행은 따로 적는다). 화면에 절대 경로는 나오지 않았다. 모든 실행의 머리 세 줄은 같다:

```text
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9
```

### 결과 한눈에

| 이름 | 계획의 기대 | 실제 | 같은가 |
|---|---|---|---|
| 시작 전 (precondition) | 종료 코드 0, `점검 통과 (4개 중 4개)` | 종료 코드 0, 같은 줄, 7초 | 같다 |
| M10 고치기 전 | `[4/4] 통과`, exit 0 (헛통과) | `[4/4] 통과`, exit 0, 5초 | 같다 |
| M11 고치기 전 | `[4/4] 통과`, exit 0 (헛통과) | `[4/4] 통과`, exit 0, 5초 | 같다 |
| M10 고친 뒤 | `[4/4] 실패`, 나오지 않은 경고 (1) = 그 줄, 나온 경고 (0), exit 1 | 그대로, `점검 실패 (4개 중 1개)`, exit 1, 6초 | 같다 |
| M11 고친 뒤 | `[4/4] 실패`, 나온 경고 (1) = `lib/dup_probe.dart:2  info  avoid_print`, 나오지 않은 경고 (0), exit 1 | 그대로, exit 1, 5초 | 같다 |
| M12 고치기 전 (계획 밖, 더 잰 것) | (계획 표: 정답지를 `exit 2` + `invalid_annotation_target` 1줄로 덮어쓴다) | 덮어썼다 — hash `facd4a7…` → `1459d4e…`, exit 1, 2초. 되돌림 | 같다 |
| M12 고친 뒤 | `[3/4] 실패`, `[4/4] 통과`, 쓰지 않았다는 문구, hash 불변, exit 1 | 그대로 — hash 전후 `facd4a7e15cd7cff91a02b5d455810ccfa0feb56`, exit 1, 3초 | 같다 |
| M12 대조 | 단계 4개 통과, `- ` 한 줄, `정답지를 썼다: …`, 비주석 17줄 · 그 줄 1회, exit 0 | 그대로, exit 0, 5초. 쓰인 파일은 `19ae5ec` 와 한 글자도 다르지 않았다 (날짜가 같은 날이라 머리 주석도 같다) | 같다 |
| `CI=true … --update` | 64 | 64, stdout 0바이트, stderr `CI 에서는 --update 를 쓰지 않는다 — 로컬에서 갱신해 커밋하세요.`, 1초 미만, 정답지 불변 | 같다 |
| M13 고치기 전 (계획 밖, 더 잰 것) | (계획 표: `[2/4] 통과`, `[4/4] 실패` 빠진 줄 6, exit 1) | 그대로, `점검 실패 (4개 중 1개)`, exit 1, 6초 | 같다 |
| M13 고친 뒤 | `[2/4] 실패` + 문구(파일 이름 포함), `[4/4] 실패` 빠진 줄 6, exit 1 | 그대로, `점검 실패 (4개 중 2개)`, exit 1, 5초 | 같다 |
| M14 고친 뒤 | `[2/4] 실패` + 문구, `[1/4]` · `[3/4]` · `[4/4]` 통과 (16줄 그대로 — 복사본 실측에 기댄 기대), exit 1 | 그대로 — `[4/4]` 는 **통과** (차이 없음), `점검 실패 (4개 중 1개)`, exit 1, 6초 | 같다 (실제 저장소에서 처음 잰 값이 복사본 기대와 일치) |

기대와 다른 결과는 하나도 없었다.

### M10 — 정답지에 같은 줄 2개 (실제 1건)

변경: 정답지 끝에 `lib/base_rules.dart:22  info  avoid_print` 한 줄 추가 (비주석 18줄).

고치기 전 (`2b9d334` 의 스크립트, exit 0, 5초):

```text
[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

점검 통과 (4개 중 4개)
```

고친 뒤 (exit 1, 6초):

```text
[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

정답지에는 있는데 나오지 않은 경고 (1)
  lib/base_rules.dart:22  info  avoid_print

정답지에 없는데 나온 경고 (0)

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 1개)
```

되돌림: `git checkout -- example/expected_diagnostics.txt` → `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt` 0.

### M11 — 한 줄에 `avoid_print` 2건 (정답지에는 그 줄 1개)

변경: `example/lib/dup_probe.dart` (1행 `// gap 닫기 실측용 임시 파일 — 한 줄에 같은 규칙(avoid_print)이 두 번 걸린다.`, 2행 `void twoPrints() { print('x'); print('y'); }`) + 정답지 끝에 `lib/dup_probe.dart:2  info  avoid_print` 한 줄.

고치기 전 (exit 0, 5초): 단계 넷 모두 `통과`, `점검 통과 (4개 중 4개)` — M10 의 고치기 전 화면과 같다.

고친 뒤 (exit 1, 5초):

```text
[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

정답지에는 있는데 나오지 않은 경고 (0)

정답지에 없는데 나온 경고 (1)
  lib/dup_probe.dart:2  info  avoid_print

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 1개)
```

되돌림: `rm -f example/lib/dup_probe.dart`, `git checkout -- example/expected_diagnostics.txt` → 파일 없음, 정답지 = `19ae5ec`.

### M12 — 빈 옵션 파일에서 `--update`

변경: `: > example/analysis_options.yaml`.

고치기 전 (`37316e3` 의 스크립트, exit 1, 2초): `[3/4] 실패` · `[4/4] 통과`, detail 첫 줄 `정답지 갱신: example/expected_diagnostics.txt`, `- ` 16줄과 `+ lib/should_not_appear.dart:5  warning  invalid_annotation_target`, `점검 실패 (4개 중 1개)`. **정답지를 썼다** — `git hash-object` 가 `facd4a7e15cd7cff91a02b5d455810ccfa0feb56` → `1459d4e9500eb4c975b4fbf7988cb31f677c44d4`, 쓰인 내용은 머리 주석 두 줄 + `exit 2` + `lib/should_not_appear.dart:5  warning  invalid_annotation_target`. 바로 되돌렸다. 이 실행은 계획의 절차에 없고 내가 더 잰 것이다 (02-REVIEW.md WR-01 의 복사본 재현을 실제 저장소에서 본 것).

고친 뒤 (exit 1, 3초, hash 전후 `facd4a7e15cd7cff91a02b5d455810ccfa0feb56` — 불변):

```text
[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 실패
[4/4] example/ 정답지 비교 ............. 통과

`example/analysis_options.yaml` 이 include 한 줄이 아니다 — 주석·빈 줄을 뺀 내용 (0줄):
  (없음)

`example/analysis_options.yaml` 을 include 한 줄로 되돌린다:
  include: package:woody_lints/analysis_options.yaml
`flutter pub get` 을 돌렸다면: git checkout -- example/analysis_options.yaml

정답지 갱신 대상: example/expected_diagnostics.txt
- lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
- lib/added_rules.dart:18  info  always_declare_return_types
- lib/added_rules.dart:24  info  prefer_final_locals
- lib/added_rules.dart:29  info  prefer_single_quotes
- lib/added_rules.dart:33  info  unawaited_futures
- lib/added_rules.dart:7  info  prefer_const_constructors
- lib/base_rules.dart:12  info  sort_child_properties_last
- lib/base_rules.dart:17  info  use_build_context_synchronously
- lib/base_rules.dart:22  info  avoid_print
- lib/base_rules.dart:30  info  control_flow_in_finally
- lib/base_rules.dart:34  info  slash_for_doc_comments
- lib/base_rules.dart:38  info  prefer_is_empty
- lib/base_rules.dart:8  info  sized_box_for_whitespace
- lib/main.dart:5  warning  missing_provider_scope
- lib/riverpod_rules.dart:17  warning  provider_parameters
- lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties
+ lib/should_not_appear.dart:5  warning  invalid_annotation_target
머리 주석: # 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12

다른 단계가 실패해 정답지를 쓰지 않았다 — 실패를 먼저 고친 뒤 다시 실행하세요.

점검 실패 (4개 중 1개)
```

되돌림: `git checkout -- example/analysis_options.yaml example/expected_diagnostics.txt` → 정답지 = `19ae5ec`, `git diff --quiet HEAD -- example` 0.

### M12 대조 — 정답지만 다른 실행의 `--update` (정상 경로)

변경: M10 과 같다 (정답지에 같은 줄 2개). exit 0, 5초:

```text
[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

정답지 갱신 대상: example/expected_diagnostics.txt
- lib/base_rules.dart:22  info  avoid_print
머리 주석: # 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12

정답지를 썼다: example/expected_diagnostics.txt

점검 통과 (4개 중 4개)
```

쓰인 파일: 비주석 17줄 (`exit 2` + 16), `lib/base_rules.dart:22  info  avoid_print` 1회. `git diff 19ae5ec` 가 비어 있었다 (같은 날이라 `# 실측:` 줄도 같다). 그래도 `git checkout -- example/expected_diagnostics.txt` 를 했다.

`CI=true fvm dart run tool/verify.dart --update`: 종료 코드 64, stdout 0바이트, stderr `CI 에서는 --update 를 쓰지 않는다 — 로컬에서 갱신해 커밋하세요.`, 정답지 불변.

### M13 — `linter:` → `lintr:`

변경: `perl -pi -e 's/^linter:$/lintr:/' lib/analysis_options.yaml`.

고치기 전 (`37316e3` 의 스크립트, exit 1, 6초): `[2/4] 통과`, `[4/4] 실패` — `정답지에는 있는데 나오지 않은 경고 (6)` (아래와 같은 6줄), `점검 실패 (4개 중 1개)`. 계획이 든 "지금의 결과" 와 같다 (계획 밖, 내가 더 잰 것).

고친 뒤 (exit 1, 5초):

```text
[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 실패
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

`lib/analysis_options.yaml` 에서 규칙을 하나도 읽지 못했다 — 최상위 `linter:` 아래 `rules:` 목록이 비어 있거나 없다.

`linter:` / `rules:` 키와 들여쓰기를 확인하세요. 규칙을 include 뒤의 다른 파일로 옮겼으면 이 단계의 대상 파일을 그 파일로 바꿉니다.

정답지에는 있는데 나오지 않은 경고 (6)
  lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
  lib/added_rules.dart:18  info  always_declare_return_types
  lib/added_rules.dart:24  info  prefer_final_locals
  lib/added_rules.dart:29  info  prefer_single_quotes
  lib/added_rules.dart:33  info  unawaited_futures
  lib/added_rules.dart:7  info  prefer_const_constructors

정답지에 없는데 나온 경고 (0)

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 2개)
```

되돌림: `git checkout -- lib/analysis_options.yaml` → `git diff --quiet 90a2736 -- lib` 0.

### M14 — 규칙 목록을 include 뒤의 파일로 (Phase 3 의 모양)

변경: 새 파일 `lib/_probe_rules.yaml` (1행 `include: package:flutter_lints/flutter.yaml`, 2행 빈 줄, 그 뒤 배포 파일 20 ~ 40행의 `linter:` 블록 21줄 — 합쳐 23줄), 배포 파일은 13행을 `include: package:woody_lints/_probe_rules.yaml` 로 바꾸고 20 ~ 41행을 지움. `analyzer:` 와 `plugins:` 는 배포 파일에 남겼다. 계획은 Edit 도구를 들었지만 같은 변경을 `sed` 두 줄로 만들었다 (결과 파일을 눈으로 확인).

고친 뒤 (exit 1, 6초):

```text
[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 실패
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

`lib/analysis_options.yaml` 에서 규칙을 하나도 읽지 못했다 — 최상위 `linter:` 아래 `rules:` 목록이 비어 있거나 없다.

`linter:` / `rules:` 키와 들여쓰기를 확인하세요. 규칙을 include 뒤의 다른 파일로 옮겼으면 이 단계의 대상 파일을 그 파일로 바꿉니다.

점검 실패 (4개 중 1개)
```

`[4/4]` 는 통과였다 — 3단 include (`example` → 배포 파일 → `_probe_rules.yaml` → `flutter_lints`) 에서 정답지 16줄이 그대로 나왔고 `riverpod_lint` 줄 3개도 포함이다. 계획이 "복사본 실측에 기댄 기대" 라고 한 값과 같았고, 실제 저장소에서 잰 것은 이번이 처음이다. **고치기 전 스크립트로는 이 모양을 다시 재지 않았다** — "단계 4개 모두 통과, exit 0" 은 02-VERIFICATION.md 의 복사본 실측을 인용한 것이다 (계획이 그렇게 정했다).

되돌림: `rm lib/_probe_rules.yaml`, `git checkout -- lib/analysis_options.yaml` → `git diff --quiet 90a2736 -- lib` 0, `git status --short --untracked-files=all -- lib` 빈 출력.

### 함수 단위로 본 것 (저장소 밖 임시 스크립트)

테스트 프레임워크가 없어 (D-11: 의존성 없음) scratchpad 의 임시 Dart 파일에서 `tool/verify.dart` 를 import 해 한 번씩 불렀다. 저장소에 남긴 것은 없다.

| 호출 | 결과 |
|---|---|
| `subtractLines(['a','a','b'], ['a'])` | `[a, b]` |
| `subtractLines(['b','a','a','c'], ['a','a','a','x'])` | `[b, c]` (순서 유지, 넘치게 빼도 음수가 되지 않음) |
| `findDifference(null, ['x','x','y'], 2)` | `missing` `[]`, `unexpected` `[x, x, y]`, `종료 코드: 정답지 없음, 실제 2` |
| `countDeclaredRules(배포 파일)` / `plugins:` 를 뺀 복사본 | 12 / 12 |
| `linter:` → `lintr:` | 0 |
| `analyzer.exclude` 에만 `- foo_bar` | 0 (블록 밖) |
| `rules:` 아래 주석 처리된 줄만 | 0 |
| 맵 형식 `avoid_print: true` | 0 — 계획이 "확인되지 않은 것" 으로 둔 모양이다. 조용히 통과가 아니라 실패 쪽으로 간다 |

## 되돌림과 끝 상태의 확인

실험마다 그 경로만 되돌린 직후 고정 커밋과 견줬다 (위 각 절의 "되돌림"). 세 커밋 뒤에 다시 본 것:

| 확인 | 결과 |
|---|---|
| `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt` | 0 (비주석 17줄 = `exit 2` + 16) |
| `git diff --quiet 90a2736 -- lib` | 0, `find lib -name '*.dart'` 0개, `lib/` 에는 `analysis_options.yaml` 하나 |
| `git diff --quiet 2a9725e -- CHANGELOG.md` | 0 |
| `git diff --quiet 968a5bb -- pubspec.yaml README.md` | 0 |
| `git diff --quiet 3a15da8 -- .fvmrc` | 0 |
| `example/lib/dup_probe.dart`, `lib/_probe_rules.yaml`, `build/woody_rule_check` | 셋 다 없음 |
| `git status --short --untracked-files=all -- lib example tool .github` | 빈 출력 |
| `.dart_tool/woody_verify/example/.plugin_manager/` 아래 폴더 | 1개 (상태 폴더는 지우지 않았다) |
| 마지막 `fvm dart run tool/verify.dart` | 종료 코드 0, `점검 통과 (4개 중 4개)`, 5초 |
| 루트 `fvm dart analyze` | `No issues found!` |
| `fvm dart format --output=none --set-exit-if-changed tool` | 0 |

세 task 의 `<automated>` verify 는 계획에 적힌 글자 그대로 돌렸고 모두 첫 실행에 exit 0 이었다 — Task 1 은 커밋 전 · tracer gate · 끝에 한 번씩(세 번), Task 2 는 커밋 전과 끝에(두 번), Task 3 은 커밋 전에 한 번. 고쳐서 돌린 check 는 없다.

`git status --short` 에 남은 것은 실행 전부터 있던 것뿐이다: ` M .planning/config.json` (도구가 쓴 임시 키 — 커밋하지 않는다), `?? .planning/milestone.lock`, `?? .planning/research/.cache/`, `?? .planning/state.json` (도구 상태 — 건드리지 않았다). ` M .planning/STATE.md` 는 이 plan 의 마무리 커밋에 들어간다.

## 코드 리뷰 발견의 처리 — 닫는 것과 열어 두는 것

이 메모는 여기에만 적는다. `02-REVIEW-DISPOSITION.md` 는 건드리지 않았다 (검증 꼬리가 다시 만든다).

| ID | 처리 | 내용 |
|---|---|---|
| CR-01 | **닫음** (Task 1, `37316e3`) | 건수를 세는 차집합. M10 · M11 이 종료 코드 1 로 실패한다. 02-VERIFICATION.md Gap 1 의 missing 1 (코드) 과 missing 2 (실행 기록 — 위 화면과 README M10 · M11) |
| WR-01 | **case 1 만 닫음** (Task 2, `40776b5`) | 다른 단계가 실패한 실행의 `--update` 는 쓰지 않는다 (M12). **case 2 는 열어 둔다 — 이 설계는 case 2 를 막지 않는다.** 단계 4개가 모두 통과하고 plugin 줄만 `?` 인 실행은 지금도 정답지를 쓰고 머리 주석에 `riverpod_lint ?` 를 적는다 (소유자가 승인하지 않은 범위. Phase 3 의 plugin 없는 fixture 에 영향이 있다). case 2 는 이번에 다시 재지 않았다 — 코드에 그 분기가 없다는 것만 확인했다 |
| WR-03 | **"규칙 0개" 절반만 닫음** (Task 2, `40776b5`) | 규칙을 하나도 읽지 못하면 `[2/4]` 실패 (M13 · M14). 세 코드(`deprecated_lint` / `removed_lint` / `undefined_lint`) 밖의 진단 — `duplicate_rule`, `incompatible_lint`, `unrecognized_error_code` 등 — 을 실패로 치거나 화면에 찍는 절반은 **열어 둔다** (넣지 않았다) |
| WR-07 | **닫음** (Task 3, `008ea3f`) | workflow 주석 + 02-CONTEXT.md D-10 덧붙임. 동작은 바꾸지 않았다 (소유자 결정 C). tag push 에서 도는 것은 GitHub 문서의 서술이고 이번에도 일으켜 보지 않았다 |
| WR-02 · WR-04 · WR-05 · WR-06, IN-01 ~ IN-06 | 손대지 않음 | 계획의 범위 밖 |

금지 사항 넷 (P13 ~ P16) 에 대해 한 일: workflow 는 주석만 바꿨다 (PyYAML 비교 동일, `push:` 아래에 키 없음). plugin `?` 거부 분기와 세 코드 밖 진단의 처리는 넣지 않았다 (두 커밋의 추가 줄에서 해당 문자열 0건). D-10 원문은 그대로이고 덧붙임 한 줄만 더했다. 02-01 ~ 02-04 PLAN.md 와 `02-REVIEW-DISPOSITION.md` 는 건드리지 않았다. 확정은 소유자의 일이다 (`status: unresolved` 그대로).

## Decisions Made

- **TDD 의 RED 는 "고치기 전의 헛통과 실행" 으로 삼았다.** 이 저장소에는 테스트 프레임워크가 없고 D-11 이 의존성 추가를 막는다. Task 1 · 2 는 `tdd="true"` 지만 계획의 커밋 계약이 task 마다 `fix(02-05):` 하나(`tool/verify.dart` 한 파일)이므로 `test(…)` 커밋을 따로 만들지 않았다. RED 의 증거는 고치기 전 스크립트로 돌린 M10 · M11 (exit 0), M12 (정답지 덮어씀), M13 (`[2/4] 통과`) 이고 GREEN 은 고친 뒤의 같은 입력이다. plan 의 type 은 `execute` 이고 `workflow.tdd_mode` 는 꺼져 있어 gate 검사 대상은 아니다
- **M12 와 M13 의 고치기 전 실행을 더 쟀다.** 계획은 M10 · M11 만 고치기 전을 다시 보라고 했다. A · B 도 "고치기 전에 틀렸다" 를 같은 저장소에서 본 뒤 고치는 편이 기록이 한결같아서다. M12 의 고치기 전 실행은 정답지를 실제로 덮어쓰므로 직후에 되돌리고 `19ae5ec` 와 견줬다. M14 의 고치기 전은 계획대로 재지 않았다
- **`countDeclaredRules` 는 줄을 한 번 훑으며 블록 안팎을 가른다.** `linter:` 로 시작하는 줄에서 블록이 열리고 들여쓰기 없는 다음 줄에서 닫힌다 (계획의 정의 그대로). 들여쓰기 없는 주석 줄도 블록을 닫는다 — 지금의 배포 파일에는 블록 안에 그런 줄이 없다
- **`--update` 불릿의 문구를 계획과 다르게 썼다** (아래 Deviations 1)
- **README 소절에 계획이 요구하지 않은 것을 더했다:** 걸린 시간 한 줄, M12 · M13 의 고치기 전 결과, "막지 않는 것" 불릿 (WR-01 case 2 와 WR-03 의 다른 절반). 몇 달 뒤의 독자가 이 소절만 보고 "이제 다 막혔다" 로 읽지 않게 하려는 것이다
- **CHANGELOG 에 적지 않았다.** 2.0.0 항목의 `### 그 밖의 변경` 이 이미 `tool/verify.dart` 를 "사용하는 프로젝트에는 영향 없음" 으로 적었고, 이번 변경은 아직 어느 릴리스에도 들어가지 않은 그 도구의 고침이다 (VERSIONING.md 기준표 "저장소 안쪽만 바뀜 = 올리지 않음"). `git diff --quiet 2a9725e -- CHANGELOG.md` 0
- **broken-windows ledger (`.planning/WINDOWS.md`) 에는 적지 않았다.** stub · 건너뛴 테스트 · 돌리지 못한 verify 가 없다

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] README 의 `--update` 불릿이 실제 화면과 다르게 읽히는 문구를 고쳐 썼다**
- **Found during:** Task 3 (README 설명 네 군데)
- **Issue:** 계획이 준 불릿은 "다른 단계(`[1/4]` ~ `[3/4]`, 또는 plugin 준비 실패 · 도구 사망)가 실패했으면 정답지를 쓰지 않고 `다른 단계가 실패해 정답지를 쓰지 않았다` 를 찍는다" 였다. plugin 준비 실패와 도구 사망에서는 `[4/4]` 가 `applyUpdate` 없이 실패로 돌아오므로, fixture 가 하나인 지금은 그 문구가 **찍히지 않는다** (쓰지 않는 것은 맞다). 그대로 적으면 문서가 화면과 어긋난다
- **Fix:** 불릿을 "다른 단계(`[1/4]` ~ `[3/4]`)가 실패했으면 … 를 찍는다. plugin 준비 실패와 도구 사망에서는 전과 같이 쓰지 않는다 — 그때는 이 문구 대신 `[4/4]` 의 실패 내용이 찍힌다" 로 썼다. 쓴 뒤의 문구(`정답지를 썼다: …`)도 한 문장 더했다
- **근거의 종류:** 코드 읽기다 (`compareFixture` 의 앞 두 가지가 `applyUpdate` 를 돌려주지 않고, `main` 은 `updaters` 가 비면 아무 줄도 찍지 않는다). plugin 준비 실패에서 `--update` 를 **실행해 보지는 않았다** (02-02 가 "정답지를 건드리지 않는다" 를 실행으로 확인한 적은 있다)
- **Files modified:** `example/README.md`
- **Verification:** Task 3 `<automated>` exit 0 (필요한 문자열은 모두 그대로 있다)
- **Committed in:** `008ea3f`

---

**Total deviations:** 1 auto-fixed (문서 정확성 1)
**Impact on plan:** 범위를 넘은 코드 변경은 없다. 그 밖에 계획의 글자와 다르게 한 작은 것은 Decisions Made 에 적었다 — M14 의 배포 파일 변경을 Edit 가 아니라 `sed` 로 만든 것, M12 · M13 의 고치기 전 실행을 더 잰 것, README 소절에 문장을 더한 것.

## Issues Encountered

- 끝의 청결 확인에서 내가 쓴 반복문 하나가 zsh 의 단어 나눔 규칙 때문에 `git diff --quiet <커밋> -- <경로>` 를 한 인자로 넘겨 다섯 번 모두 `fatal: 애매한 인자` (128) 를 냈다. 저장소의 문제가 아니라 내 확인 명령의 문제였고, 다섯 비교를 한 줄씩 따로 다시 돌려 모두 0 을 봤다 (위 표). 계획의 `<automated>` 와는 상관없다 (그쪽은 `bash` 로 돌렸고 같은 비교가 통과했다)
- 그 밖에는 없다. 실험 열두 번이 모두 한 번에 예상대로 나왔다

## 돌린 것과 돌리지 않은 것

**돌렸다:** 시작 전의 통과 실행; M10 · M11 의 고치기 전과 뒤; M12 의 고치기 전과 뒤; M12 대조; `CI=true … --update`; M13 의 고치기 전과 뒤; M14 (고친 뒤만); 각 실험 뒤의 되돌림 확인; 통과 확인 실행 3회; 세 task 의 `<automated>` verify (위에 적은 횟수); 함수 단위 호출 2회; 루트 `fvm dart analyze`, `fvm dart format`.

**돌리지 않았다 · 못 했다:**
- M14 의 고치기 전 실행 (계획대로 02-VERIFICATION.md 의 복사본 실측을 인용)
- WR-01 case 2 (plugin 버전 `?` 인 실행의 `--update`) — 범위 밖이고 다시 재지 않았다
- plugin 준비 실패 · 도구 사망에서의 `--update` — 그 분기의 코드는 바꾸지 않았고 다시 일으켜 보지 않았다
- GitHub 에서의 실행 — push 하지 않았다. 바뀐 스크립트가 runner (Linux) 에서 도는 것은 다음 push 때 처음 본다. tag push 에서 workflow 가 도는지도 일으켜 보지 않았다
- 맵 형식 `rules:` 가 실제 분석에서 어떻게 되는지 — `countDeclaredRules` 가 0 을 돌려주는 것만 함수 호출로 봤다
- `<human-check>` (README 소절이 읽히는가) — end-of-phase UAT 의 일이다

## 알아 둘 것

- **`verify context-drift` 가 경고를 낼 수 있다.** 02-CONTEXT.md 를 고쳤으므로 02-RESEARCH.md · 02-PATTERNS.md 가 CONTEXT 보다 오래된 것으로 보일 수 있다. 참고용 경고이고 01-04 가 01-CONTEXT.md 에 같은 방식으로 주석을 남긴 선례가 있다. 이번 실행에서 그 명령을 돌려 보지는 않았다
- **Phase 3 에게:** 규칙을 `base.yaml` 로 옮기면 `[2/4]` 가 바로 실패한다 (M14). `shippedOptionsPath` 를 규칙이 실제로 적힌 파일로 옮겨야 하고, 그 파일에 `plugins:` 가 없으면 `stripPlugins` 가 `FormatException` (종료 코드 70) 을 내므로 그 단계도 함께 고쳐야 한다 (02-VERIFICATION.md "Phase 3 가 알아야 할 것" 첫째 줄, rule-status-check.md Constraints)
- **Phase 4 에게:** 한 줄에 같은 규칙이 두 번 걸리는 샘플을 만들면 정답지에 똑같은 줄이 두 번 적힌다. 이제 그 건수가 맞아야 통과한다
- **정답지 형식의 한계는 그대로다.** 줄 · 강도 · 규칙이 같고 메시지만 다른 두 진단은 구별하지 않는다 (D-04 가 메시지를 적지 않기로 정한 결과)

## User Setup Required

None - 외부 서비스 설정이 필요 없다.

## Next Phase Readiness

- Gap 1 을 닫는 코드와 실행 기록이 모두 있다. 다음은 Phase 2 의 재검증 (`/gsd-verify-work 2`) 이다 — 02-VERIFICATION.md 의 사람 확인 1 ~ 5 · 7 과 이 plan 의 `<human-check>` 가 거기로 간다
- 로컬 브랜치는 origin (`1f06c55`) 보다 앞서 있다. 다음 push 는 Phase 3 부터 D-09 대로 소유자에게 묻는다
- 열려 있는 것: WR-01 case 2, WR-03 의 다른 절반, WR-02 · WR-04 · WR-05 · WR-06, IN-01 ~ IN-06, 금지 사항 P13 ~ P16 의 소유자 확정

## Self-Check: PASSED

- FOUND: `tool/verify.dart`, `example/README.md`, `.github/workflows/verify.yml`, `.planning/phases/02-verification-harness/02-CONTEXT.md`
- FOUND (HEAD 의 조상): `37316e3`, `40776b5`, `008ea3f`
- `git rev-list --count 2b9d334..HEAD` = 3 (SUMMARY 를 쓰기 전, task 커밋 셋)

---
*Phase: 02-verification-harness*
*Completed: 2026-10-12*
