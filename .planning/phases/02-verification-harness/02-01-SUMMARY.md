---
phase: 02-verification-harness
plan: 01
subsystem: testing
tags: [dart-analyze, golden, expected-diagnostics, riverpod_lint, flutter_lints, analyzer-plugin, fixture, verify-script]

# Dependency graph
requires:
  - phase: 01-baseline-and-toolchain
    provides: "저장소 고정 SDK Flutter 3.47.5 / Dart 3.13.4 (`.fvmrc`), `pubspec.yaml` 의 `sdk: ^3.13.0` / `version: 2.0.0-dev` (`968a5bb`), 1.3.0 기준점 `90a2736` — 이 plan 의 '범위 밖 파일 불변' 비교 기준"
  - phase: spikes-001-008
    provides: "`dart analyze` 실행 형태, plugin 준비 실패 판정, 전용 상태 폴더, `dart pub get --enforce-lockfile`, 루트 `example/**` 제외 (`.claude/skills/spike-findings-woody-lints/`)"
provides:
  - "`example/` — 사용 프로젝트와 같은 모양의 연습용 Flutter 패키지 (옵션 파일은 옛 URI — `package:woody_lints` 의 `analysis_options.yaml` — 를 include 하는 한 줄, dev 의존성 `woody_lints: path: ..`, 커밋된 `pubspec.lock`)"
  - "`example/expected_diagnostics.txt` — 정답지 `exit 2` + 16줄 (배포 파일의 규칙 12개 + 기반 세트만의 `prefer_is_empty` + `riverpod_lint` 3건, 규칙마다 정확히 한 줄)"
  - "`tool/verify.dart` — `fvm dart run tool/verify.dart [--update]`. 클래스 `Expected` · `AnalyzeOutcome` · `StepResult` · `Difference`, 함수 `normalizeDiagnostics` · `runPubGet` · `analyzeFixture` · `compareFixture` · `findDifference` · `writeExpected` · `formatStepLine` · `main`. 종료 코드 0 / 1 / 64 / 69 / 70"
  - "루트 `analysis_options.yaml` 의 `flutter_lints` 기반 세트(`flutter.yaml`) include 와 `'example/**'` 제외, `.gitignore` 의 `example/pubspec.lock` 예외 줄(`!` 부정 패턴) · `build/`"
  - "런타임 폴더 `.dart_tool/woody_verify/example/` (fixture 전용 Analysis Server 상태 폴더, gitignore 대상, 스크립트가 지우지 않는다)"
affects: [02-02, 02-03, 02-04, phase-3-presets, phase-4-rules, phase-5-docs]

# Actuals (#2632)
actuals:
  tokens: 7105     # chars/4 — 바뀐 14개 파일의 문자 수 28422 (`wc -m`). 생성물 `example/pubspec.lock` (7804자)을 빼면 5154. plan 의 estimate 는 60000 이었다
  tasks: 2         # Task 1 (tracer), Task 2 (auto)
  commits: 2       # MEASURED: git rev-list --count 6b416c6b2860685b3ae74fc077f457fa1c6b4680..HEAD (SUMMARY 작성 시점)
plan_head_before: 6b416c6b2860685b3ae74fc077f457fa1c6b4680
plan_head_after: 74fafb285b3826fc26536974dce4598ab376e8bf

# Tech tracking
tech-stack:
  added:
    - "`flutter_riverpod` 3.4.3 (`^3.0.0`) — `example/` 의 의존성으로만. 저장소 `pubspec.yaml` 에는 더하지 않았다"
  patterns:
    - "정답지 비교 판정 순서: stderr 에 plugin 머리말(`contains`) → 도구 사망(exit ∉ {0, 2, 3} 또는 stdout 에 JSON 없음) → 빠진 줄 / 남는 줄 / exit. 앞의 두 실패에서는 `--update` 도 정답지를 건드리지 않는다"
    - "단계 함수는 `exit()` 하지 않고 `StepResult` 를 돌려주며 `main` 이 모아 요약한다. `exit()` 즉시 종료는 준비 단계(인자 오류 64, pub get 실패 69)에서만 쓰고 그 전에 stdout / stderr 를 flush 한다 (`quit`)"
    - "fixture 는 목록(`fixtures`)으로 돌고 fixture 마다 상태 폴더가 따로다 (`<repoRoot>/.dart_tool/woody_verify/<fixture>/`). 순서대로 분석한다"
    - "저장소 루트는 `File.fromUri(Platform.script).parent.parent.path` — 어느 cwd 에서 실행해도 같은 파일을 본다 (`example/` 에서 실행해 확인)"

key-files:
  created:
    - tool/verify.dart
    - example/pubspec.yaml
    - example/pubspec.lock
    - example/analysis_options.yaml
    - example/expected_diagnostics.txt
    - example/lib/main.dart
    - example/lib/added_rules.dart
    - example/lib/base_rules.dart
    - example/lib/riverpod_rules.dart
    - example/lib/should_not_appear.dart
    - example/lib/generated/sample.g.dart
    - example/lib/generated/sample.freezed.dart
  modified:
    - analysis_options.yaml
    - .gitignore

key-decisions:
  - "검증 명령 `tool/verify.dart` 의 종료 코드는 0 모두 통과 / 1 단계 실패 / 64 사용법 오류(모르는 인자, CI 에서 `--update`) / 69 `pub get` 실패 / 70 예외로 끝남 이다. 78(SDK 불일치)은 plan 02-02 가 더한다"
  - "정답지 `example/expected_diagnostics.txt` 는 `exit 2` + 16줄이고 실제 저장소에서 `--update` 로 만든 결과가 `02-RESEARCH.md` 권고 2 의 복사본 실측과 한 줄도 다르지 않았다 (A4 확인; Dart 3.13.4, `riverpod_lint` 3.1.9, 2026-10-12). 줄 번호가 샘플 파일의 모양에 묶여 있으므로 샘플을 고치면 `--update` 로 갱신하고 diff 를 검토한다"
  - "전용 상태 폴더는 `<repoRoot>/.dart_tool/woody_verify/example/` 이고 그 `.plugin_manager` 아래 폴더는 정확히 하나였다 (A2 확인). 스크립트는 이 폴더를 지우지 않는다"
  - "루트 `fvm dart pub get` 은 `example/` 도 함께 풀지만 (`Resolving dependencies in ./example...`) `example/pubspec.lock` 을 바꾸지 않았다 — lock 은 `example/` 에서 `fvm dart pub get` 으로 한 번 만들어 커밋했고 스크립트는 `--enforce-lockfile` 로 받는다"
  - "`tool/verify.dart` 는 `dart format` 을 적용한 모양으로 커밋한다. 루트 `analysis_options.yaml` 이 `flutter_lints` 를 include 하므로 스크립트는 `print` 대신 `stdout.writeln` / `stderr.writeln` 만 쓴다"

patterns-established:
  - "정답지 형식: `# 실측:` · `# 형식:` 머리 주석 → `exit N` → `상대경로:줄  강도  규칙이름` (칸 사이 공백 2개, 문자열 정렬 — `:13` 이 `:7` 보다 앞). `--update` 는 `# 실측:` 줄만 새로 쓰고 나머지 `#` 줄은 보존한다"
  - "화면: `[n/N] <label> ..... 통과|실패` (결과 단어가 같은 열에 오도록 점 채움, 한글은 2칸으로 센다) → 실패한 단계의 detail → `점검 통과 (N개 중 N개)` / `점검 실패 (N개 중 M개)`"
  - "위반 샘플은 위반마다 바로 위 `///` 주석에 `` `규칙이름` — 무엇을 어겼는지 `` 를 적고, 한 줄에 규칙 하나만 걸리게 둔다"

requirements-completed: [VERIFY-01]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "저장소 루트에서 검증 명령(`tool/verify.dart` 를 `fvm dart run` 으로)을 실행하면 `example/` 의 `dart analyze` 결과가 커밋된 정답지와 비교되어, 같으면 `[1/1] example/ 정답지 비교 … 통과` / `점검 통과 (1개 중 1개)` 와 종료 코드 0 으로 끝난다"
    requirement: "VERIFY-01"
    verification:
      - kind: integration
        ref: "plan 02-01 Task 1 <automated> verify (본 실행 RC=0, `[1/1] … 통과`, `점검 통과 (1개 중 1개)`, import 는 dart:io / dart:convert 뿐, `.plugin_manager` 폴더 1개, 루트 analyze `No issues found`) → rc=0 (커밋 전 · 커밋 뒤 tracer gate 재실행 둘 다)"
        status: pass
      - kind: integration
        ref: "plan 02-01 Task 2 <automated> verify 의 앞부분 (RC=0, `[1/1] … 통과`) → rc=0"
        status: pass
    human_judgment: false
  - id: D2
    description: "정답지가 `exit 2` + 16줄이다 — 배포 파일의 규칙 12개, 기반 세트만 켜는 `prefer_is_empty`, `riverpod_lint` 3건(`missing_provider_scope` warning, `provider_parameters` warning, `avoid_public_notifier_properties` info)이 각각 정확히 한 줄"
    requirement: "VERIFY-01"
    verification:
      - kind: integration
        ref: "plan 02-01 Task 2 <automated> verify (비주석 줄 17, 규칙 이름 16개 각 1회, `added_rules` 6줄 / `base_rules` 7줄, plugin 3줄의 강도) → rc=0"
        status: pass
      - kind: other
        ref: "diff <(sed -n '400,416p' .planning/phases/02-verification-harness/02-RESEARCH.md) <(grep -v '^#' example/expected_diagnostics.txt) → 출력 없음 (17줄 동일)"
        status: pass
    human_judgment: false
  - id: D3
    description: "`invalid_annotation_target` 샘플(`should_not_appear.dart`)과 생성 파일 샘플(`example/lib/generated/sample.g.dart`, `sample.freezed.dart`)이 `example/` 에 있지만 정답지에 그 진단이 없다. (배포 파일의 해당 줄을 지우면 나타나는지 — 헛통과가 아님 — 는 plan 02-03 이 확인한다)"
    requirement: "VERIFY-01"
    verification:
      - kind: integration
        ref: "plan 02-01 Task 2 <automated> verify (샘플 파일 7개, `@immutable` / `print(\"g\")` / `print(\"f\")` 존재, 17줄에 16개 이름이 각 1회라 다른 줄이 끼어들 자리가 없음) → rc=0; `grep -c invalid_annotation_target` = 0, `grep -c lib/generated/` = 0"
        status: pass
    human_judgment: false
  - id: D4
    description: "`example/pubspec.lock` 이 커밋되어 있고(`.gitignore` 의 `!` 부정 패턴 예외 줄), 루트 `pubspec.lock` 과 `build/` 는 그대로 무시된다"
    requirement: "VERIFY-01"
    verification:
      - kind: other
        ref: "git check-ignore example/pubspec.lock → rc=1; git check-ignore -q pubspec.lock → rc=0; git check-ignore -q build/x → rc=0; git ls-files example | grep pubspec.lock → example/pubspec.lock"
        status: pass
    human_judgment: false
  - id: D5
    description: "`example/analysis_options.yaml` 은 옛 URI 를 include 하는 한 줄이다 — 아래 ref 의 문자열 그대로 (`pub get` 2회와 분석 여러 번 뒤에도 그대로)"
    requirement: "VERIFY-01"
    verification:
      - kind: other
        ref: "test \"$(grep -v '^#' example/analysis_options.yaml | grep -v '^$')\" = 'include: package:woody_lints/analysis_options.yaml' → rc=0 (Task 1 verify 의 일부); wc -l → 1"
        status: pass
    human_judgment: false
  - id: D6
    description: "루트 `fvm dart analyze` 가 `No issues found` 다 — `example/` 이 루트 분석에 섞이지 않고 `tool/verify.dart` 가 기반 세트 규칙을 통과한다"
    verification:
      - kind: other
        ref: "fvm dart analyze → `Analyzing woody_lints... No issues found!` (두 task 커밋 직전, 두 verify 안에서 각각)"
        status: pass
    human_judgment: false
  - id: D7
    description: "`lib/` 는 `90a2736` 과, `pubspec.yaml` · `README.md` 는 `968a5bb` 와 차이가 없다"
    verification:
      - kind: other
        ref: "git diff --quiet 90a2736 -- lib && git diff --quiet 968a5bb -- pubspec.yaml README.md → rc=0 (두 verify 의 마지막 단언, 커밋 뒤에도 재확인)"
        status: pass
    human_judgment: false
  - id: D8
    description: "`tool/verify.dart` 의 실패·준비 경로: 정답지와 다르면 두 목록과 갱신 안내를 찍고 종료 코드 1, 정답지가 없으면 1, 정답지 형식이 틀리면 70, lock 과 `pubspec.yaml` 이 어긋나면 69, 모르는 인자와 CI 의 `--update` 는 64"
    verification:
      - kind: manual_procedural
        ref: "실제 실행: Task 2 갱신 전 실행 → `정답지에 없는데 나온 경고 (15)` rc=1; 정답지를 잠시 치운 실행 → rc=1; 정답지 첫 줄을 진단 줄로 바꾼 실행 → rc=70; `example/pubspec.yaml` 의 제약을 잠시 `^2.0.0` 으로 바꾼 실행 → rc=69; `CI=true … --update` → rc=64; `--bogus` → rc=64. 임시 변경은 모두 되돌렸다 (`git status` 깨끗)"
        status: pass
    human_judgment: false
  - id: D9
    description: "`tool/verify.dart` 의 'plugin 준비 실패' 분기(stderr 머리말)와 '도구가 죽었다' 분기(exit ∉ {0, 2, 3} / JSON 없음)"
    verification: []
    human_judgment: true
    rationale: "이 plan 에서는 두 분기를 실제로 일으켜 보지 않았다 — 네트워크 차단이나 깨진 `plugin.aot`, exit 255 재현이 필요하다. 조건식은 spike 002 / 008 의 실측을 옮긴 것이지만 이 스크립트 안에서의 동작은 코드로만 존재한다"

# Metrics
duration: 8min
completed: 2026-10-12
status: complete
---

# Phase 2 Plan 01: example/ 정답지와 tool/verify.dart 의 비교 경로 Summary

**`example/` 연습용 프로젝트의 `dart analyze` 결과를 커밋된 정답지(`exit 2` + 규칙 16개 각 한 줄)와 견주는 `tool/verify.dart` — plugin 준비 실패와 도구 사망을 정답지 비교보다 먼저 가르고, `--update` 는 바뀐 줄을 보여 준 뒤 다시 쓴다**

쉬운 말로: "이 연습용 프로젝트를 검사하면 이런 경고가 이만큼 나와야 한다" 를 적은 파일(정답지)과, 실제로 검사해 그 파일과 맞춰 보는 명령이 생겼다. `lib/` 를 바꾸기 전의 1.3.0 동작이 16줄로 고정됐다.

## Performance

- **Duration:** 8 min (시작 → 두 task 커밋 · 자체 점검까지. SUMMARY 작성과 상태 갱신 시간은 넣지 않았다)
- **Started:** 2026-10-11T16:07:46Z (한국 시각 2026-10-12 01:07)
- **Completed:** 2026-10-11T16:15:24Z (자체 점검을 마친 시각)
- **Tasks:** 2 (Task 1 tracer, Task 2 auto)
- **Files modified:** 14 (새 파일 12, 고친 파일 2)
- **실행 위치:** 본 작업 폴더의 `gsd/v2.0-package-rework` 브랜치 (worktree 아님 — `fvm use` 후속 조치 없음)

## Accomplishments

- `example/` 을 사용 프로젝트와 같은 모양으로 만들었다 — 옵션 파일은 옛 URI include 한 줄, `woody_lints` 는 `path: ..`, lock 커밋.
- `tool/verify.dart` 의 정답지 비교 경로가 실제 저장소에서 돈다 — 처음 실행 16초(plugin 받기 + 컴파일 포함), 재실행 8초 · 3초.
- 정답지가 `exit 2` + 16줄로 고정됐다. 규칙 16개가 각각 정확히 한 줄이고, 조사 단계의 복사본 실측(`02-RESEARCH.md` 권고 2)과 한 줄도 다르지 않다.
- "나오면 안 되는" 샘플 3파일이 `example/` 에 있고 정답지에는 나타나지 않는다.
- 루트 분석은 `No issues found` — `example/` 이 섞이지 않고, 스크립트는 기반 세트 규칙을 통과한다.
- `lib/`, `pubspec.yaml`, `README.md` 는 건드리지 않았다. push 와 tag 는 하지 않았다.

## Task Commits

1. **Task 1: 끝에서 끝까지 — plugin warning 한 건이 정답지와 비교된다** — `ac5cced` (feat)
   - `.gitignore`, `analysis_options.yaml`, `example/analysis_options.yaml`, `example/expected_diagnostics.txt`, `example/lib/main.dart`, `example/pubspec.lock`, `example/pubspec.yaml`, `tool/verify.dart` (8개 — `git show --name-only --format= ac5cced`)
2. **Task 2: 샘플을 규칙 12개 + 기반 세트 1개 + plugin 3개 + "나오면 안 되는" 3파일로 확장** — `74fafb2` (feat)
   - `example/expected_diagnostics.txt`, `example/lib/added_rules.dart`, `example/lib/base_rules.dart`, `example/lib/generated/sample.freezed.dart`, `example/lib/generated/sample.g.dart`, `example/lib/riverpod_rules.dart`, `example/lib/should_not_appear.dart` (7개 — `git show --name-only --format= 74fafb2`)

두 커밋 모두 삭제된 파일이 없다. `.dart_tool/`, `example/.dart_tool/`, 루트 `pubspec.lock` 은 스테이징되지 않았다.

**Plan metadata:** `f7c0e49` (docs: 이 SUMMARY 와 STATE / ROADMAP). 그 뒤 SUMMARY 의 문구만 다듬은 `docs(02-01)` 커밋이 하나 더 있다 — 백틱 안의 설정 줄·명령을 `gsd-tools verify-summary` 가 파일 경로로 읽어 "없는 파일" 5건으로 보고해서(오탐), 뜻은 그대로 두고 표기만 바꿨다

## Task 1 의 실측 기록

### tracer feedback gate

Task 1 은 `type="tracer"` 다. 설정이 interactive + `human_verify_mode: end-of-phase` 이고 `<verify>` 가 `<automated>` 뿐이라, 커밋 뒤 `<automated>` 를 처음부터 다시 돌려 rc=0 (`RC=0 U=64 B=64`) 을 확인하고 Task 2 로 넘어갔다. checkpoint 는 만들지 않았다.

### 루트 `pub get` 이 `example/pubspec.lock` 을 바꿨는가 — 바꾸지 않았다

순서: `example/` 에서 `fvm dart pub get` 한 번 (`Changed 35 dependencies!`, rc=0) → 루트에서 `fvm dart pub get` 한 번.

```text
$ fvm dart pub get        (저장소 루트)
Resolving dependencies...
Downloading packages...
Got dependencies!
Resolving dependencies in `./example`...
Downloading packages...
Got dependencies in `./example`.
```

계획이 짐작한 대로 루트 `pub get` 은 `example/` 도 함께 푼다. `example/pubspec.lock` 의 sha1 은 앞뒤가 같았다 (`ae950cd29dff88b971cf84405e2cf278680d96e0`). 다시 받을 일이 없었다. `example/analysis_options.yaml` 도 한 줄 그대로다 (`flutter pub get` 은 돌리지 않았다).

lock 에 풀린 버전: `flutter_lints` 6.0.0, `lints` 6.1.0, `flutter_riverpod` 3.4.3, `riverpod` 3.4.3, `woody_lints` 2.0.0-dev (path `..`).

### 첫 `--update` 의 화면 출력 (원문, 16초)

```text
$ fvm dart run tool/verify.dart --update
정답지 갱신: example/expected_diagnostics.txt
+ lib/main.dart:5  warning  missing_provider_scope
exit 기대 없음 (정답지 없음), 실제 2

[1/1] example/ 정답지 비교 ............. 통과

점검 통과 (1개 중 1개)
```

만들어진 정답지 (`<interfaces>` 의 예시와 같다 — 날짜만 실행한 날):

```text
# 실측: Dart 3.13.4, 2026-10-12
# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: fvm dart run tool/verify.dart --update
exit 2
lib/main.dart:5  warning  missing_provider_scope
```

### 재실행 두 번 (둘 다 종료 코드 0)

```text
$ fvm dart run tool/verify.dart        (1회차, 8초)
[1/1] example/ 정답지 비교 ............. 통과

점검 통과 (1개 중 1개)

$ fvm dart run tool/verify.dart        (2회차, 3초)
[1/1] example/ 정답지 비교 ............. 통과

점검 통과 (1개 중 1개)
```

시간은 `date +%s` 의 차(초 단위, `fvm` 기동과 `pub get --enforce-lockfile` 포함)다. 1회차가 8초로 2회차(3초)보다 길었던 이유는 따로 캐 보지 않았다.

### `.plugin_manager` 의 `ls` (A2 의 확인)

```text
$ ls -la .dart_tool/woody_verify/example/.plugin_manager/
drwxr-xr-x  6ca435cd085d36f4d7125df05f3f8257
$ ls -d .dart_tool/woody_verify/example/.plugin_manager/*/ | wc -l
1
```

폴더가 **하나** 다 — `ANALYZER_STATE_LOCATION_OVERRIDE` 가 실제 저장소의 `.dart_tool/woody_verify/example/` 자리에서도 듣는다. 이 plan 의 실행 전체(분석 12번 남짓)를 마친 뒤에도 하나였다. 그 폴더의 `pubspec.lock` 에 풀린 plugin 은 `riverpod_lint` `3.1.9` 다. 상태 폴더 안에는 `.analysis-driver`, `.instrumentation`, `.plugin_manager`, `.prompts` 가 생겼다 (모두 점으로 시작).

### 인자 처리

```text
$ CI=true fvm dart run tool/verify.dart --update
CI 에서는 --update 를 쓰지 않는다 — 로컬에서 갱신해 커밋하세요.
(종료 코드 64)

$ fvm dart run tool/verify.dart --bogus
모르는 인자: --bogus
사용법: fvm dart run tool/verify.dart [--update]
(종료 코드 64)
```

## Task 2 의 실측 기록

### 갱신 전 — 실패 (종료 코드 1)

```text
$ fvm dart run tool/verify.dart
[1/1] example/ 정답지 비교 ............. 실패

정답지에는 있는데 나오지 않은 경고 (0)

정답지에 없는데 나온 경고 (15)
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
  lib/riverpod_rules.dart:17  warning  provider_parameters
  lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (1개 중 1개)
```

### `--update` — `+ ` 줄 15개 (종료 코드 0)

```text
$ fvm dart run tool/verify.dart --update
정답지 갱신: example/expected_diagnostics.txt
+ lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
+ lib/added_rules.dart:18  info  always_declare_return_types
+ lib/added_rules.dart:24  info  prefer_final_locals
+ lib/added_rules.dart:29  info  prefer_single_quotes
+ lib/added_rules.dart:33  info  unawaited_futures
+ lib/added_rules.dart:7  info  prefer_const_constructors
+ lib/base_rules.dart:12  info  sort_child_properties_last
+ lib/base_rules.dart:17  info  use_build_context_synchronously
+ lib/base_rules.dart:22  info  avoid_print
+ lib/base_rules.dart:30  info  control_flow_in_finally
+ lib/base_rules.dart:34  info  slash_for_doc_comments
+ lib/base_rules.dart:38  info  prefer_is_empty
+ lib/base_rules.dart:8  info  sized_box_for_whitespace
+ lib/riverpod_rules.dart:17  warning  provider_parameters
+ lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties

[1/1] example/ 정답지 비교 ............. 통과

점검 통과 (1개 중 1개)
```

exit 는 2 그대로라 exit 줄은 나오지 않았다.

### 갱신 뒤 — 통과 (종료 코드 0)

```text
$ fvm dart run tool/verify.dart
[1/1] example/ 정답지 비교 ............. 통과

점검 통과 (1개 중 1개)
```

### 갱신 뒤 정답지 전문 (`example/expected_diagnostics.txt`, 19줄)

```text
# 실측: Dart 3.13.4, 2026-10-12
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
lib/main.dart:5  warning  missing_provider_scope
lib/riverpod_rules.dart:17  warning  provider_parameters
lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties
```

### `02-RESEARCH.md` 권고 2 와의 대조 (A4) — 같음

`diff <(sed -n '400,416p' 02-RESEARCH.md) <(grep -v '^#' example/expected_diagnostics.txt)` 의 출력이 없다. `exit 2` 와 16줄의 파일:줄 · 강도 · 규칙 이름이 전부 같다. 다른 줄이 없으므로 "실제 출력이 기준" 규칙을 쓸 일이 없었다.

눈으로 본 것: 규칙 16개가 각각 정확히 한 줄, `invalid_annotation_target` 줄 0개, `lib/generated/` 줄 0개, `lib/main.dart:` 1줄 (warning), `lib/riverpod_rules.dart:` 2줄 (warning 1 · info 1), `lib/added_rules.dart:` 6줄, `lib/base_rules.dart:` 7줄.

## `tool/verify.dart` 의 종료 코드

| exit | 뜻 | 이 plan 에서 실제로 본 것 |
|---|---|---|
| 0 | 단계가 모두 통과 (`--update` 로 갱신한 실행 포함) | 통과 실행, `--update` 두 번 |
| 1 | 단계 중 하나라도 실패 — 정답지와 다름, 정답지 없음, plugin 준비 실패, 도구 사망 | 정답지와 다름 (Task 2 갱신 전), 정답지 없음. **plugin 준비 실패와 도구 사망은 일으켜 보지 않았다** |
| 64 | 사용법 오류 — 모르는 인자, CI 에서 `--update` | `--bogus`, `CI=true … --update` |
| 69 | 하위 명령 실패 — `example/` 의 `dart pub get --enforce-lockfile` 이 실패 (검증을 시작하지 않는다) | `example/pubspec.yaml` 의 제약을 잠시 `^2.0.0` 으로 바꿔 lock 과 어긋나게 한 실행 (pub 의 exit 65 → 안내 → 69). 되돌렸고 lock 의 sha1 은 그대로였다 |
| 70 | 스크립트가 예외로 끝남 — `FormatException` / `FileSystemException` / `ProcessException` | 정답지 첫 줄을 진단 줄로 바꾼 실행 (`파일 모양이 예상과 다르다: 첫 줄이 exit N 이 아니다`). 나머지 두 예외는 일으켜 보지 않았다 |
| 78 | (plan 02-02) 실행 중인 SDK 가 `.fvmrc` 와 다름 | 아직 없다 |

69 의 화면 (stderr, 저장소 경로는 `<repo>` 로 가렸다):

```text
`example/pubspec.yaml` 을 바꿨으면 `cd example && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요.
pub get 실패 (<repo>/example): exit 65
Unable to satisfy `pubspec.yaml` using `pubspec.lock`.

To update `pubspec.lock` run `dart pub get` without
`--enforce-lockfile`.
```

## Files Created/Modified

- `tool/verify.dart` (495줄) — 검증 명령. `dart:convert` · `dart:io` 만 쓴다
- `example/pubspec.yaml` — 연습용 Flutter 패키지 (`flutter_riverpod ^3.0.0`, dev `woody_lints: path: ..`)
- `example/pubspec.lock` — `fvm dart pub get` 이 만든 lock (커밋, 35개 패키지)
- `example/analysis_options.yaml` — 옛 URI(`package:woody_lints` 의 `analysis_options.yaml`)를 include 하는 한 줄
- `example/expected_diagnostics.txt` — 정답지 (`exit 2` + 16줄)
- `example/lib/main.dart` — `missing_provider_scope` (warning)
- `example/lib/added_rules.dart` — 이 패키지가 실제로 추가하는 규칙 6개
- `example/lib/base_rules.dart` — 기반 세트와 겹치는 규칙 6개 + `prefer_is_empty`
- `example/lib/riverpod_rules.dart` — `avoid_public_notifier_properties` (info), `provider_parameters` (warning)
- `example/lib/should_not_appear.dart` — 함수에 붙인 `@immutable` (`invalid_annotation_target`, 억제돼야 함)
- `example/lib/generated/sample.g.dart`, `sample.freezed.dart` — `print("g")` / `print("f")` (exclude 돼야 함)
- `analysis_options.yaml` (루트) — `flutter_lints` 기반 세트(`flutter.yaml`) include 와 `'example/**'` 제외를 더했다. 기존 `lib/analysis_options.yaml` 제외와 그 주석은 그대로다
- `.gitignore` — `example/pubspec.lock` 예외 줄(`!` 부정 패턴)과 `build/` (각각 한국어 이유 주석). 기존 영어 주석은 그대로다

## Decisions Made

- **종료 코드 0 / 1 / 64 / 69 / 70** (계획대로). 예외 세 가지는 모두 70 으로 합쳤다.
- **`--update` 의 바뀐 줄은 `compareFixture` 가 파일을 쓰기 직전에 직접 stdout 에 찍는다.** `StepResult.detailLines` 로 돌려주면 `main` 이 요약 단계에서야 찍게 되어 "먼저 보여 주고 덮어쓴다" (D-14) 의 순서가 뒤집힌다.
- **정답지가 없을 때의 exit 줄은 `exit 기대 없음 (정답지 없음), 실제 N`** 이다. 계획은 불일치 문구(`exit 기대 N, 실제 M`)만 정했고 "처음 만들 때 exit 변화가 보인다" 고만 적었다.
- **detail 의 들여쓰기는 D-13 미리보기를 따랐다** — 제목 줄(`정답지에 없는데 나온 경고 (N)`)은 첫 칸, 그 아래 경고 줄만 2칸 들여쓴다. plan 02-02 의 미리보기(141-149행)와 같은 모양이다.
- **`dart format` 을 `tool/verify.dart` 에 적용했다.** 저장소에 포맷터 설정은 없지만 처음 생기는 Dart 파일을 SDK 기본 모양으로 두었다.
- **`normalizeDiagnostics` 는 JSON 이지만 진단 모양이 아닌 입력(`TypeError`)도 null 로 돌려준다** — 잡히지 않는 오류로 죽지 않고 "도구가 죽었다" 단계로 보고된다.
- **`interfaces` 에 없던 공개 이름을 더했다:** `Difference`, `findDifference`, `writeExpected`, `formatDate`, `measureWidth`, `formatStepLine`, `quit`, `compareFixture` (마지막 것은 plan 02-04 의 산출물 목록에 있는 이름이다), 상수 `pluginFailureHeader` · `fixtures` · `expectedFileName` · `updateCommand` · `formatHeaderLine` · `measuredPrefix` · `resultColumn`. `interfaces` 가 정한 모양(`Expected`, `normalizeDiagnostics`, `runPubGet`, `analyzeFixture`, `AnalyzeOutcome`, `StepResult`)은 그대로다.

## Deviations from Plan

계획과 다른 결과는 없다. 정답지는 계획이 기대한 `exit 2` + 16줄 그대로 나왔고, 두 `<automated>` verify 가 고친 것 없이 처음에 통과했다. 자동 수정(Rule 1~3)은 없었다.

적어 둘 작은 것 둘:

**1. 계획 문구와 조사 문서 전문의 어긋남 — `example/lib/main.dart`**
- **Found during:** Task 1 action 1
- **Issue:** 계획은 "`///` 주석 2줄 … 5행이 `void main() {` 이고 `missing_provider_scope` 가 그 줄에 걸린다" 고 적었다. `02-RESEARCH.md` § Code Examples 6 의 전문은 `///` 주석이 **한 줄** 이고 `void main() {` 은 4행, `runApp(…)` 이 5행이다.
- **처리:** 계획이 "전문 그대로" 를 요구하므로 전문을 글자 그대로 옮겼다. 진단은 5행(`runApp` 줄)에 걸려 정답지는 계획의 예시와 같은 `lib/main.dart:5` 다. 결과에 차이가 없어 고친 것이 없다.
- **Committed in:** `ac5cced`

**2. `sample.freezed.dart` 의 주석 한 단어**
- **Found during:** Task 2 action 1
- **Issue:** 조사 문서는 `sample.g.dart` 의 전문만 싣고 "`sample.freezed.dart` 도 같은 꼴, `"f"`" 라고 적었다. 주석을 그대로 베끼면 freezed 파일이 `**/*.g.dart` exclude 로 빠진다고 적히게 된다.
- **처리:** 주석의 패턴만 `**/*.freezed.dart` 로 바꿨다. 줄 수와 `print("f")` 의 자리(4행)는 같다.
- **Committed in:** `74fafb2`

---

**Total deviations:** 0 auto-fixed. 기록용 메모 2건 (결과에 영향 없음).
**Impact on plan:** 없음. 범위를 넘은 변경도 없다.

## Issues Encountered

- `dart format` 이 처음 쓴 `tool/verify.dart` 의 줄바꿈을 고쳤다 (동작 변화 없음, 고친 뒤 루트 분석 `No issues found`).
- 그 밖의 문제는 없었다.

## 확인하지 않은 것

- **plugin 준비 실패 분기와 도구 사망 분기** — 코드는 있지만 이 plan 에서 실제로 일으켜 보지 않았다 (coverage 의 D9). pub 서버에 닿지 못하게 하거나 `plugin.aot` 을 잘라야 재현된다.
- **재실행 1회차가 8초였던 이유** (2회차는 3초).
- **GitHub runner 에서의 실행** — plan 02-04 의 일이다.
- **D-03 샘플이 헛통과가 아닌지** (배포 파일의 `errors:` 블록이나 exclude 줄을 지우면 정답지와 달라지는지) — plan 02-03 의 일이다. 이 plan 은 "샘플이 있고 정답지에는 없다" 까지만 확인했다.

## Threat Model 대응

| Threat ID | 처리 |
|---|---|
| T-02-01 (mitigate) | `example/pubspec.lock` 커밋 + 스크립트의 `dart pub get --enforce-lockfile`. 받은 패키지는 조사 문서 감사표의 OK 항목뿐이다 (`flutter_riverpod` 3.4.3, `flutter_lints` 6.0.0, `lints` 6.1.0 과 그 전이 의존성). lock 과 어긋나면 69 로 멈추는 것을 실제로 봤다 |
| T-02-02 (mitigate) | 루트 `'example/**'` 제외를 `example/` 과 **같은 커밋** (`ac5cced`) 에 넣었다. 두 verify 가 `No issues found` 를 확인했다 |
| T-02-SC (accept) | 저장소 `pubspec.yaml` 에 의존성을 더하지 않았다. 패키지 install 이 실패한 일은 없다 |

계획의 threat model 에 없는 새 표면(네트워크 endpoint, 인증 경로, 신뢰 경계의 스키마 변경)은 만들지 않았다.

## Known Stubs

없음. 바뀐 파일에 `TODO` / `FIXME` / 자리 표시가 없다. `.planning/WINDOWS.md` 에 더할 항목도 없다 (stub · 건너뛴 테스트 · 돌리지 않은 `<verify>` 가 없다).

## User Setup Required

None - 외부 서비스 설정이 필요 없다.

## Next Phase Readiness

**plan 02-02 가 이어받을 것:**

- `main` 은 단계 줄을 **단계가 끝나는 대로** stdout 에 찍는다. 02-02 가 맨 위에 버전 3줄(D-07)을 두려면 — plugin 버전은 분석이 끝난 뒤에야 읽힌다 — 단계 줄을 모았다가 찍도록 바꿔야 한다.
- `--update` 의 바뀐 줄도 `compareFixture` 안에서 바로 stdout 에 찍힌다. "stdout 의 첫 줄이 `SDK` 줄" 을 지키려면 이 출력의 순서도 함께 본다.
- exit 불일치 문구는 지금 `exit 기대 N, 실제 M` 이다. 02-02 가 `종료 코드: 정답지 N, 실제 M` 으로 바꾼다.
- 정답지 머리 주석은 지금 `# 실측: Dart 3.13.4, 2026-10-12` 이다. 02-02 가 Flutter / `riverpod_lint` 버전을 더한 형식으로 바꾼다.
- 단계 목록은 `main` 의 `steps` (함수 목록)이고 `[n/N]` 은 그 길이에서 계산된다. 단계를 앞에 끼워 넣으면 번호가 따라 바뀐다.
- 준비 단계는 지금 `example/` 의 `pub get` 뿐이다. 규칙 검사에 필요한 **루트 `dart pub get`** 은 스크립트에 아직 없다.
- 결과 단어의 열은 `resultColumn = 40` 이다. 02-02 의 가장 긴 label 에서도 점이 3개 이상 남는지 본다.

**요구사항:** `VERIFY-01` 은 plan 02-02 도 함께 선언한다. 02-02 의 SUMMARY 가 생기기 전이라 `REQUIREMENTS.md` 에는 아직 완료로 표시하지 않았다 (`requirements.ready-ids` → `0/1`).

**blocker:** 없음.

## Self-Check: PASSED

- 만든 파일 14개가 모두 디스크에 있다 (`[ -f … ]` → 전부 FOUND): `tool/verify.dart`, `example/` 의 11개, `analysis_options.yaml`, `.gitignore`.
- 커밋 `ac5cced`, `74fafb2` 가 HEAD 의 조상이다 (`git merge-base --is-ancestor` → 둘 다 FOUND).
- `gsd-tools check evaluation-scope --plan 02-01 --commits-only` → `status: resolved`, commits 2개 (이 브랜치).
- 두 task 의 `<automated>` verify 를 각각 다시 돌려 rc=0. plan 의 `<verification>` 항목 — 정답지 비교 통과, 16줄, 루트 분석 깨끗, 범위 밖 파일 불변 — 을 커밋 뒤에도 확인했다.
- `git status --short` 에 이 plan 의 파일이 남아 있지 않다. 남은 항목은 물려받은 것(`.planning/config.json`, `.planning/state.json`, `.planning/research/.cache/`, `.planning/milestone.lock`)과 실행 시작 때 이미 바뀌어 있던 `.planning/STATE.md` 뿐이다.

---
*Phase: 02-verification-harness*
*Completed: 2026-10-12*
