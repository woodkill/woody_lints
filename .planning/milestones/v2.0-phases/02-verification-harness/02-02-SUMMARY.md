---
phase: 02-verification-harness
plan: 02
subsystem: testing
tags: [dart-analyze, verify-script, golden, deprecated-lint, analyzer-plugin, riverpod_lint, flutter_lints, fvm, exit-codes]

# Dependency graph
requires:
  - phase: 02-verification-harness
    provides: "plan 02-01 — `example/` 연습용 프로젝트, 정답지 `exit 2` + 16줄, `tool/verify.dart` 의 정답지 비교 경로 (`Expected` · `AnalyzeOutcome` · `StepResult` · `normalizeDiagnostics` · `runPubGet` · `analyzeFixture` · `compareFixture`), 전용 상태 폴더, `.gitignore` 의 `build/`"
  - phase: 01-baseline-and-toolchain
    provides: "저장소 고정 SDK Flutter 3.47.5 / Dart 3.13.4 (`.fvmrc`), 불변 비교 기준 `90a2736` (`lib/`) · `968a5bb` (`pubspec.yaml`, `README.md`)"
  - phase: spikes-001-008
    provides: "규칙 검사의 복사본 방식(005 · 007), plugin 준비 실패의 stderr 머리말과 상태 폴더의 plugin 버전 읽기(002 · 008)"
provides:
  - "`tool/verify.dart` 완성본 — 준비(SDK 확인 · CI 의 `--update` 거부 · 저장소 루트 pub get · `example/` pub get) + 단계 4개 + 버전 3줄 + 안내형 화면 + `--update`. 종료 코드 0 / 1 / 64 / 69 / 70 / 78"
  - "함수 `readFlutterVersion` · `ensurePinnedSdk` · `checkLibHasNoDart` · `stripPlugins` · `checkRuleNames` · `checkFixtureOptions` · `compareFixture` · `readLockVersion` · `pluginFolders` · `readPluginVersion` · `formatVersionLines` · `formatMeasuredLine`, 클래스 `SdkInfo` · `PluginVersion`"
  - "화면 계약: stdout 의 첫 세 줄은 `SDK` / `기반 세트` / `plugin`, 그 뒤 빈 줄 · `[1/4]` ~ `[4/4]` · 단계별 내용 · `점검 통과|실패 (4개 중 N개)`. 진행 표시와 준비 단계의 안내는 stderr"
  - "정답지 머리 주석 형식 `# 실측: Flutter X / Dart Y, riverpod_lint Z, YYYY-MM-DD` (`example/expected_diagnostics.txt` 첫 줄)"
  - "런타임 임시 폴더 — 규칙 검사 복사본 자리 (`build/` 아래 `woody_rule_check`). 단계 2 가 만들고 `finally` 로 지운다"
affects: [02-03, 02-04, phase-3-presets, phase-4-rules, phase-5-docs, phase-6-release]

# Actuals (#2632)
actuals:
  tokens: 6008     # chars/4 — `git diff f71bc40..HEAD` 의 더한 줄 + 뺀 줄 24031자. 바뀐 두 파일의 전체 문자 수로 세면 33204자 / 4 = 8301. plan 의 estimate 는 55000 이었다
  tasks: 2
  commits: 2       # MEASURED: git rev-list --count f71bc40317deeaa9fae4d28de9edd20cc39492ce..HEAD (SUMMARY 작성 시점)
plan_head_before: f71bc40317deeaa9fae4d28de9edd20cc39492ce
plan_head_after: 19ae5ec6b10ff5798b4ab2f5e6e55ac7e5a8bc61

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "화면은 단계를 모두 돌린 뒤 한 번에 stdout 으로 찍는다 — plugin 버전이 분석 뒤에야 읽히고 첫 줄이 `SDK` 줄이어야 해서다. 진행 표시(`example/ 분석 중…`)와 준비 단계의 안내는 stderr"
    - "`--update` 는 바뀌는 줄을 `StepResult.detailLines` 로 돌려주고 쓰기를 `applyUpdate` 로 미룬다 — `main` 이 화면을 flush 한 뒤에 쓴다 (D-14: 조용히 덮어쓰지 않는다)"
    - "스크립트의 `dart pub get` 에는 늘 `--no-example` 을 붙인다 — 폴더마다 따로 받고, fixture 는 `--enforce-lockfile` 로만 받는다"
    - "규칙 검사: 배포 파일을 `plugins:` 없이 저장소 안의 복사본 폴더에 `analysis_options.yaml` 이름으로 쓰고, 루트에서 그 폴더를 인자로 분석한다. 상태 폴더 환경변수는 주지 않는다"
    - "다른 도구의 stderr 를 화면에 옮길 때 저장소 절대 경로를 `<repo>` 로 가린다 (`scrubPaths`). 스크립트가 직접 만드는 경로는 저장소 기준 상대 경로다 (`relativize`)"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - example/expected_diagnostics.txt

key-decisions:
  - "검증 명령 `tool/verify.dart` 는 준비(SDK 확인 → CI 의 `--update` 거부 → 저장소 루트 pub get → `example/` pub get) 뒤 단계 4개를 모두 돌리고 화면을 한 번에 stdout 으로 찍는다. stdout 의 첫 줄은 늘 `SDK` 줄이고 진행 표시와 준비 단계의 안내는 stderr 다. 종료 코드는 0 / 1 / 64 / 69 / 70 / 78 이다"
  - "스크립트의 `dart pub get` 은 늘 `--no-example` 로 돌린다 — 기본값이면 저장소 루트의 pub get 이 `example/` 도 함께 풀어 어긋난 `example/pubspec.lock` 을 다시 쓰고, 그 뒤의 `--enforce-lockfile` 이 통과해 lock 어긋남(종료 코드 69)을 놓친다 (Dart 3.13.4, 2026-10-12 실측)"
  - "`--update` 는 바뀌는 줄을 화면에 내보낸 뒤 정답지를 쓰고, 머리 주석 첫 줄을 `# 실측: Flutter X / Dart Y, riverpod_lint Z, 날짜` 로 다시 쓴다. plugin 준비 실패와 도구 사망에서는 `--update` 여도 정답지를 건드리지 않는다 (잘린 plugin.aot 으로 확인)"
  - "`tool/verify.dart` 의 plugin 준비 실패 분기와 도구 사망 분기를 plan 02-02 에서 실제로 일으켜 확인했다 — 전용 상태 폴더의 plugin.aot 을 0바이트로 자른 실행(머리말이 stderr 셋째 줄, exit 0)과 상태 폴더를 읽기 전용 빈 폴더로 바꾼 실행(exit 255, stdout 에 JSON 없음). 네트워크가 끊긴 경우의 plugin 실패는 일으켜 보지 않았다"
  - "D-12 의 SDK 판별은 실행 파일에서 다섯 단계 위의 `flutter.version.json` 이 1순위, `FLUTTER_ROOT` 가 2순위다. 2순위는 그 SDK 의 `dartSdkVersion` 이 실행 중인 Dart 와 같을 때만 받아들인다. `.fvmrc` 불일치의 종료 코드 78 은 실행으로 확인했고, `FLUTTER_ROOT` 경로와 'Flutter SDK 의 dart 가 아니다' 경로는 실행해 보지 못했다 (plan 02-04 의 CI 로그에서 본다)"
  - "plugin 버전은 전용 상태 폴더의 plugin 폴더가 정확히 하나일 때만 읽고 그 밖은 `?` 와 이유를 찍는다. 폴더가 0개인 경우는 서버가 plugin 준비에 이르기 전에 죽었을 때도 나온다 (상태 폴더를 읽기 전용으로 바꾼 실행에서 실측)"

patterns-established:
  - "단계 줄 아래의 내용은 단계별로 '무엇이 어긋났는지 → 빈 줄 → 다음에 할 일' 순서다. 규칙 이름 · 명령 · 경로는 영어 그대로, 문장은 한국어"
  - "정답지 비교의 실패 내용: (어긋났을 때만) `종료 코드: 정답지 N, 실제 M` → `정답지에는 있는데 나오지 않은 경고 (N)` → `정답지에 없는데 나온 경고 (N)` → `--update` 안내"
  - "버전 줄의 라벨은 값이 11번째 칸에서 시작하도록 맞춘다 (`기반 세트` 9칸 + 공백 2칸)"

requirements-completed: [VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-07]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "저장소 루트에서 검증 명령 한 번으로 단계 4개가 모두 돌고, 네 줄이 모두 통과이며 마지막 줄이 `점검 통과 (4개 중 4개)`, 종료 코드 0 이다. 실행 뒤 규칙 검사 복사본 폴더가 남지 않는다"
    requirement: "VERIFY-03"
    verification:
      - kind: integration
        ref: "plan 02-02 Task 1 <automated> verify → rc=0 (RC=0 U=64 T=0 P=1). 커밋 전, 커밋 뒤 두 번"
        status: pass
    human_judgment: false
  - id: D2
    description: "`lib/` 에 `.dart` 파일을 두면 `[1/4]` 가 실패하고 경로가 화면에 나오며 종료 코드가 1 이다. 나머지 세 단계도 함께 돈다"
    requirement: "VERIFY-07"
    verification:
      - kind: integration
        ref: "plan 02-02 Task 1 <automated> verify 의 probe 부분 (P=1, `[1/4] … 실패`, probe 경로, `점검 실패 (4개 중 1개)`, 지운 뒤 lib 가 90a2736 과 같음) → rc=0"
        status: pass
    human_judgment: false
  - id: D3
    description: "배포 파일에 deprecated / removed / 없는 규칙이 있으면 `[2/4]` 가 실패한다 — 세 진단 코드가 각각 한 줄씩 규칙 이름과 함께 나온다. 깨끗한 지금의 배포 파일은 통과한다"
    requirement: "VERIFY-02"
    verification:
      - kind: manual_procedural
        ref: "배포 파일 40행 아래에 unnecessary_await_in_return · avoid_returning_null · no_such_rule_for_verify 세 줄을 잠시 더한 실행 → `[2/4] … 실패`, deprecated_lint (41행) · removed_lint (42행) · undefined_lint (43행), 종료 코드 1. 되돌린 뒤 lib 가 90a2736 과 같고 복사본 폴더 없음"
        status: pass
      - kind: integration
        ref: "plan 02-02 Task 1 <automated> verify 의 `[2/4] … 통과` 와 복사본 폴더 부재 단언 → rc=0"
        status: pass
    human_judgment: false
  - id: D4
    description: "`example/analysis_options.yaml` 이 include 한 줄이 아니면 `[3/4]` 가 실패하고 되돌리는 방법을 안내한다"
    verification:
      - kind: manual_procedural
        ref: "옵션 파일 끝에 analyzer / exclude / build 제외 세 줄을 잠시 더한 실행 → `[3/4] … 실패`, 남은 4줄 표시, `[4/4]` 는 통과, 종료 코드 1. `git checkout` 으로 되돌림"
        status: pass
    human_judgment: false
  - id: D5
    description: "실행 중인 SDK 가 `.fvmrc` 와 다르면 검증을 시작하지 않고 올바른 명령을 안내하며 종료 코드 78 로 끝난다"
    verification:
      - kind: manual_procedural
        ref: "`.fvmrc` 의 flutter 값을 잠시 0.0.0 으로 바꾸고 FVM 이 링크해 둔 SDK 의 dart 로 직접 실행 → stdout 비어 있음, stderr 두 줄, 종료 코드 78. 되돌림"
        status: pass
    human_judgment: false
  - id: D6
    description: "D-12 의 나머지 두 경로 — Flutter SDK 가 아닌 dart 로 실행했을 때의 안내와, `FLUTTER_ROOT` fallback 으로 버전 파일을 찾는 경로"
    verification: []
    human_judgment: true
    rationale: "이 컴퓨터에는 FVM 밖의 dart 가 없어 두 경로를 일으켜 보지 못했다. 코드로만 있다. GitHub runner 에서 1순위 경로가 통하는지는 plan 02-04 의 첫 CI 실행이 보여 준다"
  - id: D7
    description: "stdout 의 첫 세 줄이 실제로 쓰인 버전이다 — SDK(Flutter 3.47.5 / Dart 3.13.4), 기반 세트(flutter_lints 6.0.0 / lints 6.1.0), plugin(riverpod_lint 3.1.9). plugin 버전은 전용 상태 폴더에서 읽는다"
    requirement: "VERIFY-03"
    verification:
      - kind: integration
        ref: "plan 02-02 Task 2 <automated> verify (stdout 1 · 2 · 3번째 줄의 형식, 정답지 첫 줄의 형식, 비주석 17줄) → rc=0. 커밋 전, 커밋 뒤 두 번"
        status: pass
    human_judgment: false
  - id: D8
    description: "화면이 안내형으로 읽힌다 — 버전 3줄 → 단계 4줄 → 달라진 경고 두 목록 → 다음에 할 일 → 요약 (D-13 미리보기와 같은 구성)"
    requirement: "VERIFY-03"
    verification:
      - kind: manual_procedural
        ref: "배포 파일의 prefer_final_locals 줄을 잠시 주석 처리한 실행의 화면 원문 (아래 'human-check 용 실패 화면')"
        status: pass
    human_judgment: true
    rationale: "D-13 은 소유자가 고른 화면 구성이다. 문자열과 순서는 실행으로 확인했지만 '무엇이 달라졌고 다음에 무엇을 하면 되는지 화면만 보고 아는가' 는 소유자의 판단이다 (plan 의 human-check)"
  - id: D9
    description: "`--update` 가 바뀌는 줄을 보여 준 뒤 정답지를 쓰고 머리 주석을 버전 · 날짜 형식으로 다시 쓴다. 같은 상태에서는 `정답지와 같다 — 바뀐 줄 없음` 이 나오고 진단 16줄과 `exit 2` 는 그대로다. CI 에서는 종료 코드 64 로 거부된다"
    requirement: "VERIFY-01"
    verification:
      - kind: integration
        ref: "plan 02-02 Task 2 <automated> verify 의 정답지 첫 줄 정규식과 비주석 17줄 단언 → rc=0; Task 1 <automated> verify 의 U=64"
        status: pass
      - kind: manual_procedural
        ref: "`--update` 실행 → `git diff --stat` 이 정답지 1줄 변경(첫 줄뿐); 정답지의 exit 줄을 잠시 0 으로 바꾼 뒤 `--update` → `종료 코드: 정답지 0, 실제 2` 를 보여 주고 exit 2 로 되돌려 씀"
        status: pass
    human_judgment: false
  - id: D10
    description: "plugin 준비 실패 분기 — stderr 에 머리말이 있으면 정답지 비교보다 먼저 'plugin 준비 실패' 로 알리고, plugin 줄에 덧말을 붙이며, `--update` 여도 정답지를 쓰지 않는다"
    requirement: "VERIFY-01"
    verification:
      - kind: manual_procedural
        ref: "전용 상태 폴더의 plugin.aot 을 0바이트로 자른 실행 세 번 (보통 실행 둘, `--update` 하나) → `[4/4] … 실패`, 종료 코드 1, 정답지의 sha1 불변. 원본을 되돌려 놓은 뒤 통과 (5초)"
        status: pass
    human_judgment: false
  - id: D11
    description: "도구 사망 분기 — dart analyze 가 0 / 2 / 3 밖의 종료 코드로 끝나거나 stdout 에 JSON 이 없으면 '도구가 죽었다' 로 따로 알린다"
    requirement: "VERIFY-01"
    verification:
      - kind: manual_procedural
        ref: "전용 상태 폴더를 읽기 전용 빈 폴더로 바꾼 실행 → exit 255, stdout 에 JSON 없음, `[4/4] … 실패`, plugin 줄은 물음표와 이유, 종료 코드 1. 상태 폴더를 되돌린 뒤 통과"
        status: pass
    human_judgment: false
  - id: D12
    description: "`example/pubspec.yaml` 과 lock 이 어긋나면 검증을 시작하지 않고 종료 코드 69 로 끝나며 lock 은 바뀌지 않는다 (저장소 루트 pub get 을 더한 뒤에도)"
    verification:
      - kind: manual_procedural
        ref: "`example/pubspec.yaml` 의 flutter_riverpod 제약을 잠시 2.x 로 바꾼 실행 → stderr 안내, 종료 코드 69, lock 의 sha1 ae950cd… 불변. 되돌림"
        status: pass
    human_judgment: false
  - id: D13
    description: "`lib/` 는 `90a2736` 과, `pubspec.yaml` · `README.md` 는 `968a5bb` 와 차이가 없고, 루트 `fvm dart analyze` 가 `No issues found` 다"
    verification:
      - kind: other
        ref: "git diff --quiet 90a2736 -- lib && git diff --quiet 968a5bb -- pubspec.yaml README.md → rc=0 (두 커밋 직전, 커밋 뒤); fvm dart analyze → No issues found!"
        status: pass
    human_judgment: false

# Metrics
duration: 15min
completed: 2026-10-12
status: complete
---

# Phase 2 Plan 02: 검증 명령의 단계 4개와 안내형 화면 Summary

**`tool/verify.dart` 가 SDK 확인(D-12) 뒤 단계 4개 — `lib/` 에 `.dart` 없음 / 배포 파일의 규칙 이름 / `example/` 옵션 파일 / 정답지 비교 — 를 모두 돌리고, 실제로 쓰인 버전 3줄과 단계별 "다음에 할 일" 을 한 화면에 찍는다**

쉬운 말로: 검증 명령이 "어떤 SDK · 기반 세트 · plugin 으로 검사했는지" 를 먼저 보여 주고, 네 가지를 차례로 검사한 뒤, 어긋난 것이 있으면 무엇이 어떻게 달라졌고 다음에 무엇을 하면 되는지 한국어로 알려 준다.

## Performance

- **Duration:** 15 min (시작 → 두 task 커밋과 커밋 뒤 재확인까지. SUMMARY 작성과 상태 갱신 시간은 넣지 않았다)
- **Started:** 2026-10-11T16:23:36Z (한국 시각 2026-10-12 01:23)
- **Completed:** 2026-10-11T16:39:10Z
- **Tasks:** 2
- **Files modified:** 2 (`tool/verify.dart` 495줄 → 1010줄, `example/expected_diagnostics.txt` 첫 줄)
- **실행 위치:** 본 작업 폴더의 `gsd/v2.0-package-rework` 브랜치 (worktree 아님)
- **검증 명령 한 번의 시간:** 약 5초 (plugin 이 이미 준비된 상태, `date +%s` 의 차)

## Accomplishments

- 검증 명령 하나가 단계 4개를 모두 돌리고 요약한다. 하나가 실패해도 나머지를 돌린다.
- 준비 단계가 생겼다 — 실행 중인 SDK 가 `.fvmrc` 와 다르면 시작하지 않고(78), CI 의 `--update` 를 거부하고(64), 저장소 루트와 `example/` 의 패키지를 받는다(실패하면 69).
- 배포 파일의 deprecated / removed / 없는 규칙을 잡는 단계가 생겼고, 세 가지를 실제로 넣어 세 줄이 나오는 것을 봤다.
- 화면 맨 위에 실제로 쓰인 버전이 찍힌다: Flutter 3.47.5 / Dart 3.13.4, flutter_lints 6.0.0 / lints 6.1.0, riverpod_lint 3.1.9.
- 02-01 이 "일으켜 보지 않았다" 고 남긴 두 분기 — plugin 준비 실패, 도구 사망 — 를 실제로 일으켜 화면을 확인했다.
- 정답지 머리 주석이 실측 조건(SDK / plugin / 날짜)을 담는다. 진단 16줄과 `exit 2` 는 바뀌지 않았다.
- `lib/`, `pubspec.yaml`, `README.md` 는 건드리지 않았다. push 와 tag 는 하지 않았다.

## Task Commits

1. **Task 1: 준비 단계(D-12, 루트 pub get)와 단계 1~3** — `d707988` (feat) — `tool/verify.dart`
2. **Task 2: D-07 버전 3줄, D-13 안내형 화면, `--update` 의 머리 주석** — `19ae5ec` (feat) — `tool/verify.dart`, `example/expected_diagnostics.txt`

두 커밋 모두 삭제된 파일이 없다 (`git show --diff-filter=D` 가 비어 있음).

**Plan metadata:** 이 SUMMARY 와 STATE / ROADMAP / REQUIREMENTS 를 담는 `docs(02-02)` 커밋 (이 파일을 쓴 직후에 만든다)

## (1) 통과 화면 원문

stdout 만 (종료 코드 0):

```text
$ fvm dart run tool/verify.dart 2>/dev/null
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

점검 통과 (4개 중 4개)
```

같은 실행의 stderr 는 한 줄이다:

```text
example/ 분석 중…
```

## (2) `lib/` 에 `.dart` 파일을 둔 실행의 실패 화면 원문

Task 1 verify 가 `touch` 로 만든 probe 파일(lib 아래 `_verify_probe.dart`)을 둔 채 돌린 실행이다. `2>&1` 로 받아 stderr 의 진행 줄이 맨 위에 섞여 있다. 종료 코드 1.

```text
example/ 분석 중…
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/4] lib/ 에 .dart 파일 없음 .......... 실패
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

lib/ 에 .dart 파일이 있다 (1)
  lib/_verify_probe.dart

`lib/` 에는 YAML 만 둔다 — 스크립트는 `tool/`, 연습용 코드는 `example/` 에 둔다.

점검 실패 (4개 중 1개)
```

verify 가 파일을 지운 뒤 `git status --short --untracked-files=all -- lib` 는 비어 있고 `git diff --quiet 90a2736 -- lib` 는 rc=0 이다.

## (3) CI 에서의 `--update` — stderr 원문과 종료 코드

```text
$ CI=true fvm dart run tool/verify.dart --update
CI 에서는 --update 를 쓰지 않는다 — 로컬에서 갱신해 커밋하세요.
(종료 코드 64, stdout 0바이트)
```

`GITHUB_ACTIONS=true` 로도 같은 줄과 64 가 나왔다. 모르는 인자:

```text
$ fvm dart run tool/verify.dart --bogus
모르는 인자: --bogus
사용법: fvm dart run tool/verify.dart [--update]
(종료 코드 64)
```

SDK 확인(78)이 CI 거부(64)보다 앞이다 — 순서는 인자 해석 → SDK 확인 → CI 의 `--update` 거부 → 저장소 루트 pub get → `example/` pub get.

## (4) `--update` 의 "바뀐 줄 없음" 출력과 정답지 첫 줄

```text
$ fvm dart run tool/verify.dart --update 2>/dev/null
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

정답지 갱신: example/expected_diagnostics.txt
정답지와 같다 — 바뀐 줄 없음
머리 주석: # 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12

점검 통과 (4개 중 4개)
```

이 실행이 정답지를 바꾼 것은 첫 줄 하나다 (Task 2 커밋 전의 `git diff --stat`: `1 file changed, 1 insertion(+), 1 deletion(-)`):

```text
-# 실측: Dart 3.13.4, 2026-10-12
+# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12
```

둘째 줄(`# 형식: …`), `exit 2`, 진단 16줄은 02-01 과 같다 (비주석 줄 17개). plugin 버전은 계획이 예상한 3.1.9 그대로 풀렸다. 커밋 뒤 같은 날 `--update` 를 다시 돌리면 같은 화면이 나오고 작업 트리는 바뀌지 않는다.

종료 코드가 어긋났을 때의 문구도 봤다 — 정답지의 `exit 2` 를 잠시 `exit 0` 으로 바꾼 실행:

```text
[4/4] example/ 정답지 비교 ............. 실패

종료 코드: 정답지 0, 실제 2

정답지에는 있는데 나오지 않은 경고 (0)

정답지에 없는데 나온 경고 (0)

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 1개)
```

그 상태에서 `--update` 는 `정답지 갱신: …` 아래에 `종료 코드: 정답지 0, 실제 2` 를 보여 준 뒤 `exit 2` 로 되돌려 썼다 (HEAD 와의 차이는 다시 첫 줄 하나).

## (5) 종료 코드 표

| exit | 뜻 | 이 plan 에서 실제로 본 것 |
|---|---|---|
| 0 | 단계 4개 모두 통과 (`--update` 로 갱신한 실행 포함) | 통과 실행 여러 번, `--update` 세 번 |
| 1 | 단계 중 하나라도 실패 (plugin 준비 실패, 도구 사망 포함) | `[1/4]` · `[2/4]` · `[3/4]` · `[4/4]` 각각의 실패, plugin 준비 실패, 도구 사망 |
| 64 | 사용법 오류 (모르는 인자, CI 에서 `--update`) | `--bogus`, `CI=true … --update`, `GITHUB_ACTIONS=true … --update` |
| 69 | 하위 명령 실패 (pub get) — 검증을 시작하지 않음 | `example/pubspec.yaml` 과 lock 이 어긋난 실행. 저장소 루트 pub get 의 실패는 일으켜 보지 않았다 |
| 70 | 스크립트가 예외로 끝남 (파일 형식 · 파일 작업 · 프로세스 실행 실패) | 상태 폴더 자리에 일반 파일을 둔 실행 (`FileSystemException`). `FormatException` 은 02-01 에서 봤고 `ProcessException` 은 일으켜 보지 않았다 |
| 78 | 실행 중인 SDK 가 `.fvmrc` 와 다름 — 검증을 시작하지 않음 (D-12) | `.fvmrc` 를 잠시 0.0.0 으로 바꾼 실행 |

78 의 화면 (`.fvmrc` 의 flutter 값을 잠시 `0.0.0` 으로 바꾸고, FVM 이 저장소에 링크해 둔 SDK 의 dart 로 직접 실행. `fvm dart` 는 `.fvmrc` 를 읽어 SDK 를 고르므로 쓰지 않았다):

```text
(stdout 비어 있음)
실행 중인 SDK 는 Flutter 3.47.5 인데 .fvmrc 는 0.0.0 다.
저장소 루트에서 `fvm dart run tool/verify.dart` 로 실행하세요.
(종료 코드 78)
```

계획은 이 경로를 자동 verify 에 넣지 않고 plan 02-03 의 M9 로 미뤘다. 여기서는 새로 쓴 코드가 도는지만 한 번 봤다 — 기록용 실행은 02-03 이 다시 한다. `.fvmrc` 는 `git checkout` 으로 되돌렸다.

70 의 화면 (전용 상태 폴더 자리에 빈 일반 파일을 둔 실행):

```text
파일 작업 실패: Creation failed (.dart_tool/woody_verify/example)
(종료 코드 70, stdout 비어 있음)
```

## (6) 저장소 루트 `pub get` 이 `example/pubspec.lock` 을 건드리는가

**어긋나 있지 않으면 건드리지 않는다. 어긋나 있으면 기본값의 루트 pub get 이 lock 을 다시 써 버린다.** 그래서 스크립트의 pub get 에 `--no-example` 을 붙였다 (Deviations 1).

02-01 은 "루트 pub get 은 `example/` 도 함께 풀지만 lock 을 바꾸지 않았다" 를 lock 이 맞는 상태에서 쟀다. 이 plan 은 계획의 지시("바꾼다면 … `--enforce-lockfile` 이 65 로 걸리는지 본 뒤 SUMMARY 에 적는다")대로 어긋난 상태를 쟀다. `example/pubspec.yaml` 의 `flutter_riverpod` 제약을 잠시 `^2.0.0` 으로 바꾼 뒤:

```text
### A. 저장소 루트에서 fvm dart pub get (기본값)
Resolving dependencies...
Downloading packages...
Got dependencies!
Resolving dependencies in `./example`...
Downloading packages...
Got dependencies in `./example`.
rc=0
example/pubspec.lock 의 sha1: ae950cd2… → 7cef3227…   (git diff --stat: 5 insertions, 162 deletions)

### B. 이어서 example/ 에서 fvm dart pub get --enforce-lockfile
  flutter_riverpod 2.6.1 (3.4.3 available)
  …
Got dependencies!
rc=0        ← 65 로 걸리지 않는다. 어긋남을 놓친다

### C. lock 만 되돌린 뒤, 저장소 루트에서 fvm dart pub get --no-example
Resolving dependencies...
Downloading packages...
Got dependencies!
example/pubspec.lock 의 sha1: ae950cd2… 그대로

### D. 이어서 example/ 에서 fvm dart pub get --enforce-lockfile
Would change 22 dependencies.
…
Unable to satisfy `pubspec.yaml` using `pubspec.lock`.
rc=65       ← 의도한 대로 걸린다
```

`--no-example` 을 넣은 스크립트로 같은 어긋남을 다시 돌린 결과 (stdout 비어 있음, 종료 코드 69, lock 의 sha1 불변):

```text
`example/pubspec.yaml` 을 바꿨으면 `cd example && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요.
pub get 실패 (<repo>/example): exit 65
Unable to satisfy `pubspec.yaml` using `pubspec.lock`.

To update `pubspec.lock` run `dart pub get` without
`--enforce-lockfile`.
```

(위 `pub get 실패 (…)` 줄의 절대 경로는 Task 1 시점의 출력이다. Task 2 가 이 자리를 `example/` 로 바꿨고, 바꾼 뒤의 69 화면은 다시 받아 보지 않았다.)

`example/pubspec.yaml` 과 lock 은 `git checkout` 으로 되돌렸고 sha1 은 `ae950cd29dff88b971cf84405e2cf278680d96e0` 다.

덧붙여: 저장소 루트의 `.dart_tool` 아래 package_config.json 을 잠시 치운 채(저장소를 막 받은 상태의 흉내) 스크립트를 돌리면 준비 단계가 그 파일을 다시 만들고 네 단계가 모두 통과했다.

## (7) human-check 용 실패 화면 원문과 되돌린 뒤의 `git status`

배포 파일 30행의 `- prefer_final_locals` 줄을 잠시 주석 처리한 실행 (stdout, 종료 코드 1):

```text
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

정답지에는 있는데 나오지 않은 경고 (1)
  lib/added_rules.dart:24  info  prefer_final_locals

정답지에 없는데 나온 경고 (0)

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 1개)
```

`02-CONTEXT.md` 의 미리보기와 다른 점은 단계가 3개가 아니라 4개라는 것(`[3/4] example/ 옵션 파일` 이 더해짐)과 점의 개수뿐이다.

되돌린 뒤 (`git checkout -- lib/analysis_options.yaml`):

```text
$ git diff --quiet 90a2736 -- lib && echo "lib == 90a2736"
lib == 90a2736
$ git status --short --untracked-files=all -- lib
(출력 없음)
$ git status --short          (Task 2 커밋 전이라 이 plan 의 두 파일이 보인다)
 M .planning/config.json
 M example/expected_diagnostics.txt
 M tool/verify.dart
?? .planning/milestone.lock
?? .planning/research/.cache/
?? .planning/state.json
```

`.planning/` 의 네 항목은 물려받은 것이다 (건드리지 않았다).

**human-check 는 소유자의 판단을 기다린다.** 설정이 `human_verify_mode: end-of-phase` 라 checkpoint 로 멈추지 않았다.

## 계획에 없던 확인 — 단계 2 · 3 의 실패, plugin 준비 실패, 도구 사망

### `[2/4]` — deprecated / removed / 없는 규칙 (Task 2 커밋 뒤의 스크립트)

배포 파일 40행 아래에 세 줄을 잠시 더했다 (`unnecessary_await_in_return`, `avoid_returning_null`, `no_such_rule_for_verify`). 종료 코드 1.

```text
[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 실패
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

배포 파일에 쓸 수 없는 규칙이 있다 (3)
  build/woody_rule_check/analysis_options.yaml:41  warning  deprecated_lint  (unnecessary_await_in_return)
  build/woody_rule_check/analysis_options.yaml:42  warning  removed_lint  (avoid_returning_null)
  build/woody_rule_check/analysis_options.yaml:43  warning  undefined_lint  (no_such_rule_for_verify)

`lib/analysis_options.yaml` 에서 그 규칙을 지우거나 바꾼다 (복사본의 줄 번호는 원본과 같다).

정답지에는 있는데 나오지 않은 경고 (0)

정답지에 없는데 나온 경고 (1)
  analysis_options.yaml:1  warning  included_file_warning

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 2개)
```

`[4/4]` 도 함께 실패한 것은 **없는 규칙** 때문이다 — include 경유로는 없는 규칙만 `included_file_warning` 으로 보고된다는 spike 005 의 기록과 같다. deprecated 한 줄만 넣은 실행(Task 1 시점)에서는 `[2/4]` 만 실패하고 `[4/4]` 는 통과했다 (`점검 실패 (4개 중 1개)`) — plan 02-03 의 M6 가 기대하는 모양이다. 실행 뒤 복사본 폴더는 남지 않았고 `lib/` 는 `90a2736` 과 같다.

### `[3/4]` — 옵션 파일에 `flutter pub get` 의 흔적 (Task 1 시점의 스크립트, 버전 줄이 생기기 전)

```text
[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 실패
[4/4] example/ 정답지 비교 ............. 통과

`example/analysis_options.yaml` 이 include 한 줄이 아니다 — 주석·빈 줄을 뺀 내용 (4줄):
  include: package:woody_lints/analysis_options.yaml
  analyzer:
    exclude:
      - build/**

`example/analysis_options.yaml` 을 include 한 줄로 되돌린다:
  include: package:woody_lints/analysis_options.yaml
`flutter pub get` 을 돌렸다면: git checkout -- example/analysis_options.yaml

점검 실패 (4개 중 1개)
```

`flutter pub get` 자체는 돌리지 않았다 — 그 명령이 써넣는 세 줄을 Edit 로 더했다.

### plugin 준비 실패 분기 — 잘린 plugin.aot

전용 상태 폴더의 plugin 폴더(1개) 안 `bin` 의 plugin.aot (15,197,408 바이트)을 scratchpad 에 `cp -p` 로 떠 두고 0바이트로 잘랐다. 3초, 종료 코드 1.

```text
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9 (이번 실행에서는 plugin 이 뜨지 않았다)

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

plugin 준비 실패 — riverpod_lint 진단 없이 끝났다 (dart analyze exit 0). stderr:
  File truncated before or at offset 0x0.
  Loading dynamic library failed: dlopen(<repo>/.dart_tool/woody_verify/example/.plugin_manager/6ca435cd085d36f4d7125df05f3f8257/bin/plugin.aot, 0x0001): tried: '<repo>/.dart_tool/woody_verify/example/.plugin_manager/6ca435cd085d36f4d7125df05f3f8257/bin/plugin.aot' (), '/System/Volumes/Preboot/Cryptexes/OS<repo>/.dart_tool/woody_verify/example/.plugin_manager/6ca435cd085d36f4d7125df05f3f8257/bin/plugin.aot' (no such file), '<repo>/.dart_tool/woody_verify/example/.plugin_manager/6ca435cd085d36f4d7125df05f3f8257/bin/plugin.aot' ()
  An error occurred while executing an analyzer plugin: IsolateSpawnException: Unable to spawn isolate: The uri(file://<repo>/.dart_tool/woody_verify/example/.plugin_manager/6ca435cd085d36f4d7125df05f3f8257/bin/plugin.aot) provided to `Isolate.spawnUri()` does not contain a valid AOT snapshot.
  
  An error occurred while executing an analyzer plugin: Unrecorded error while starting the plugin.
  #0      PluginSession.start (package:analysis_server/src/plugin/plugin_isolate.dart:499)
  <asynchronous suspension>
  #1      PluginIsolate.start (package:analysis_server/src/plugin/plugin_isolate.dart:229)
  <asynchronous suspension>
  #2      PluginManager.addPluginToContextRoot (package:analysis_server/src/plugin/plugin_manager.dart:215)
  <asynchronous suspension>

네트워크를 확인하세요.
전용 상태 폴더 `.dart_tool/woody_verify/example` 를 지우고 다시 실행하세요 (약 15초).

점검 실패 (4개 중 1개)
```

- spike 008 이 적은 대로 머리말이 stderr 의 **셋째 줄** 에 왔고 `dart analyze` 의 종료 코드는 0 이었다 — `contains` 로 찾는 판정이 실제 스크립트 안에서 걸렸다.
- `<repo>` 는 스크립트가 가린 것이다. 화면(stdout)에 저장소 절대 경로는 0번 나왔다 (`grep -c`).
- 같은 상태에서 `--update` 를 돌려도 종료 코드 1 이고 정답지의 sha1 이 그대로였다 — plugin 이 죽은 실행은 정답지를 쓰지 않는다.
- 원본을 `cp -p` 로 되돌리니(sha1 일치) 다음 실행이 5초에 통과했다. 상태 폴더를 통째로 지우는 복구(안내 문구의 방법)는 해 보지 않았다 — spike 008 의 실측에 기댄다.

### 도구 사망 분기 — 읽기 전용 상태 폴더

전용 상태 폴더의 이름을 잠시 바꿔 두고 그 자리에 `chmod 555` 한 빈 폴더를 두었다. 2초, 종료 코드 1. (커밋된 스크립트로 다시 받은 출력이다.)

```text
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint ? (이 상태 폴더에 plugin 이 준비되지 않았다 — 상태 폴더 환경변수가 듣지 않았을 수 있다)

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

도구가 죽었다 — dart analyze 가 exit 255 로 끝났다 (stdout 에 JSON 없음).
  stderr: Unhandled exception: / PathAccessException: Creation failed, path = '<repo>/.dart_tool/woody_verify/example/.instrumentation' (OS Error: Permission denied, errno = 13)

다시 실행해 보세요. 되풀이되면 위의 stderr 를 확인하세요.

점검 실패 (4개 중 1개)
```

- Analysis Server 가 상태 폴더에 쓰지 못해 죽었다 (exit 255, JSON 없음). spike 001 이 본 255(사용 통계 타이밍)와 원인은 다르지만 스크립트가 보는 모양은 같다.
- plugin 폴더가 0개라 버전이 `?` 로 찍혔다 — 버전 읽기의 "0개" 가지도 이 실행으로 확인됐다.
- 폴더를 되돌린 뒤 plugin 폴더는 1개이고 다음 실행이 통과했다.

## Files Created/Modified

- `tool/verify.dart` (1010줄, 이전 495줄) — 검증 명령 전체. import 는 `dart:convert` · `dart:io` 뿐이다
- `example/expected_diagnostics.txt` — 첫 줄(머리 주석)만 바뀜

## Decisions Made

- **화면은 한 번에, stdout 으로.** 단계 줄을 단계가 끝나는 대로 찍던 02-01 의 방식을 버렸다. 기다리는 동안에는 stderr 에 `example/ 분석 중…` 한 줄만 나온다.
- **`--update` 의 쓰기를 미뤘다.** `compareFixture` 는 바뀌는 줄을 `detailLines` 로, 쓰기를 `applyUpdate` 로 돌려주고 `main` 이 stdout 을 flush 한 뒤 쓴다. 02-01 처럼 함수 안에서 바로 찍으면 `SDK` 줄보다 앞에 나오게 된다.
- **`--update` 화면에 `머리 주석: …` 한 줄을 더했다.** 정답지에 무엇이 적히는지(실측 조건)를 쓰기 전에 보여 준다.
- **단계 2 의 실패 줄 끝에 규칙 이름을 괄호로 붙였다.** 진단 줄(`경로:줄  강도  코드`)에는 규칙 이름이 없어서, 복사본의 그 줄에서 읽는다. 앞부분은 정규화한 줄 그대로다.
- **단계 2 도 "도구가 죽었다" 를 종료 코드로도 본다.** 계획은 stdout 에 JSON 이 없을 때만 적었지만 단계 4 와 같은 기준(0 / 2 / 3 밖)을 썼다.
- **다른 도구의 stderr 는 `<repo>` 로 가린다.** 상대 경로로 바꾸면 dlopen 의 후보 목록처럼 다른 접두사 뒤에 붙은 경로가 실제로 있는 경로처럼 보인다.
- **plugin 폴더가 0개일 때의 이유 문구를 넓혔다.** 계획의 문구는 "상태 폴더 환경변수가 듣지 않았다" 였는데, 서버가 plugin 준비 전에 죽은 실행에서도 0개였다. 지금 문구는 "이 상태 폴더에 plugin 이 준비되지 않았다 — 상태 폴더 환경변수가 듣지 않았을 수 있다" 다.
- **`compareFixture` 의 인자는 02-01 의 꼴을 유지했다** (`repoRoot` · `fixture` · `update` 에 `sdk` 를 더함). 계획의 `interfaces` 는 `fixtureDir` · `stateDir` · `update` 로 적었지만, 라벨과 상대 경로를 만들려면 저장소 루트와 fixture 이름이 필요하다. 나머지 일곱 함수의 인자는 `interfaces` 대로다.
- **`interfaces` 에 없던 공개 이름:** 클래스 `SdkInfo` · `PluginVersion`, 함수 `ensurePinnedSdk` · `readVersionFile` · `relativize` · `scrubPaths` · `readPluginVersion` · `readRuleNameAt` · `formatVersionLines` · `formatMeasuredLine`, 상수 `shippedOptionsPath` · `ruleCheckDir` · `ruleProblemCodes` · `includeNotFoundCode` · `fixtureIncludeLine` · `runCommand` · `analyzeExitCodes` · `versionColumn` · `pluginPackage`. `StepResult` 에 `plugin` · `pluginFailed` · `applyUpdate` 가, `runPubGet` 에 선택 인자 `shownAs` 가, `writeExpected` 에 인자 `measured` 가 더해졌다.
- **버전 줄의 plugin 값은 첫 fixture 의 상태 폴더에서 읽은 것이다.** fixture 가 하나라 지금은 갈릴 일이 없다. Phase 3 가 fixture 를 더하면 fixture 별로 찍을지 정해야 한다 (코드에 주석으로 남겼다).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] 저장소 루트 `pub get` 이 어긋난 `example/pubspec.lock` 을 다시 써서 lock 검사가 무력해진다**
- **Found during:** Task 1 (action 2 — 루트 pub get 을 더하기 전에 계획이 시킨 관찰)
- **Issue:** `dart pub get` 은 기본값으로 `example/` 도 함께 푼다 (`--[no-]example`, defaults to on). `example/pubspec.yaml` 이 lock 과 어긋나 있으면 루트 pub get 이 lock 을 조용히 다시 쓰고, 뒤따르는 `--enforce-lockfile` 이 rc=0 으로 통과한다. 계획대로 루트 pub get 을 앞에 두기만 하면 02-01 이 확인한 종료 코드 69 (T-02-01 의 mitigation) 가 더는 나오지 않고 커밋된 lock 이 작업 트리에서 바뀐다.
- **Fix:** `runPubGet` 이 늘 `--no-example` 을 붙인다. 순서는 계획대로 루트 → `example/` 그대로다.
- **Files modified:** `tool/verify.dart`
- **Verification:** 위 (6) 의 A ~ D 와, 고친 스크립트로 같은 어긋남을 돌려 종료 코드 69 · lock 의 sha1 불변
- **Committed in:** `d707988`

**2. [Rule 2 - Missing Critical] `FLUTTER_ROOT` fallback 이 다른 SDK 를 가리켜도 확인을 통과한다**
- **Found during:** Task 1 (action 1)
- **Issue:** 계획의 fallback 은 실행 파일 근처에 버전 파일이 없으면 `FLUTTER_ROOT` 아래의 파일을 그대로 믿는다. Flutter SDK 가 아닌 dart 로 실행하면서 `FLUTTER_ROOT` 가 3.47.5 를 가리키면 D-12 의 확인이 "같다" 로 통과한다. `FLUTTER_ROOT` 는 threat model 의 T-02-05 (mitigate) 가 든 입력이다.
- **Fix:** fallback 으로 읽은 파일의 `dartSdkVersion` 이 실행 중인 Dart (`Platform.version` 의 첫 토큰) 와 같을 때만 받아들인다. 1순위 경로는 그대로다.
- **Files modified:** `tool/verify.dart`
- **Verification:** 실행으로 확인하지 못했다 (coverage 의 D6). 로컬의 버전 파일은 `dartSdkVersion` 이 `3.13.4`, `fvm dart --version` 도 `3.13.4` 라 같은 릴리스에서는 두 값이 같다는 것만 봤다
- **Committed in:** `d707988`

---

**Total deviations:** 2 auto-fixed (Rule 1 하나, Rule 2 하나). 계획의 문구와 다르게 정한 작은 것들은 위 Decisions Made 에 적었다.
**Impact on plan:** 범위를 넘은 변경은 없다. 1번은 02-01 이 세운 lock 검사를 지키는 데 필요했다. 2번이 runner 에서 문제가 되려면 1순위 경로가 실패하고 **동시에** 두 버전 문자열의 형식이 달라야 한다 — 그 경우 종료 코드 78 로 바로 드러나고 plan 02-04 가 그 복구 경로를 이미 적어 두었다.

## Issues Encountered

- Task 1 의 첫 분석에서 `curly_braces_in_flow_control_structures` 가 한 건 나왔다 (`dart format` 이 `if (…) return null;` 을 두 줄로 나눈 자리). 식을 한 줄 `return` 으로 고쳤다.
- 단계 3 의 실패 화면이 처음에는 들여쓰기를 뗀 줄을 보여 줘서 YAML 의 모양이 보이지 않았다. 판정은 `trim()` 한 줄로, 화면은 들여쓰기를 살린 줄로 나눴다.
- 그 밖의 문제는 없었다.

## 돌린 것과 돌리지 않은 것

**돌렸다 (출력은 위에 있다):** 통과 실행, `--update` (같은 상태 / exit 줄이 어긋난 상태 / plugin 이 죽은 상태), `lib/` 의 probe 파일, 배포 파일에 문제 규칙 1개 · 3개, 옵션 파일에 세 줄 추가, `.fvmrc` 불일치 (78), CI 의 `--update` 두 가지 환경변수 (64), 모르는 인자 (64), lock 어긋남 (69), 상태 폴더 자리에 파일 (70), 잘린 plugin.aot (plugin 준비 실패), 읽기 전용 상태 폴더 (도구 사망), 루트 package_config 가 없는 상태에서의 실행, 두 task 의 `<automated>` verify (커밋 전과 뒤), 루트 `fvm dart analyze`.

**돌리지 않았다:**

- **Flutter SDK 가 아닌 dart 로의 실행과 `FLUTTER_ROOT` fallback** — 이 컴퓨터에 FVM 밖의 dart 가 없다. 코드로만 있다.
- **규칙 검사의 `include_file_not_found` 가지** — 스크립트가 늘 루트 pub get 을 먼저 돌려서 스크립트를 통해서는 일으킬 수 없었다. 그 진단이 실제로 나오는지는 `02-RESEARCH.md` 의 복사본 실측(M5b)에만 있다.
- **`stripPlugins` 가 `plugins:` 를 못 찾는 경우 (종료 코드 70)** 와 **`lib/` 가 없는 경우** — 배포 파일을 그만큼 바꿔 보지 않았다.
- **plugin 버전이 `?` 가 되는 나머지 두 가지** — plugin 폴더가 2개 이상인 경우, 폴더는 하나인데 lock 을 못 읽는 경우.
- **네트워크가 끊긴 상태의 plugin 준비 실패** (머리말이 첫 줄에 오는 모양) 와 **상태 폴더를 통째로 지우는 복구**.
- **`ProcessException` 의 70**, **저장소 루트 pub get 의 실패 (69)**.
- **저장소 밖 폴더에서의 실행** — 02-01 이 `example/` 에서 실행해 본 것이 전부다.
- **GitHub runner 에서의 실행** — plan 02-04 의 일이다.
- **human-check 의 판단** — 화면은 받아 두었고 판단은 소유자의 몫이다.

## Threat Model 대응

| Threat ID | 처리 |
|---|---|
| T-02-03 (mitigate) | 단계 2 의 `try … finally` 가 복사본 폴더를 지우고, `build/` 가 비면 그것도 지운다. Task 1 verify 가 실행 뒤 부재를 단언했고, 문제 규칙을 넣어 실패한 실행 뒤에도 남지 않았다 |
| T-02-04 (accept) | 실제로 풀린 plugin 버전(3.1.9)이 화면 셋째 줄과 정답지 머리 주석에 찍힌다. 전용 상태 폴더로 IDE 와 분리된 것은 02-01 그대로다 |
| T-02-05 (mitigate) | 허용 인자는 `--update` 하나이고 그 밖은 64. 모든 `Process.run` 은 인자 배열이다. `stripPlugins` 는 섹션을 못 찾으면 `FormatException` 을 던진다 (실행으로는 보지 않았다). `FLUTTER_ROOT` 에는 Deviations 2 의 조건을 더했다 |
| T-02-06 (accept) | 바꾼 것 없음. 읽기 전용 상태 폴더의 실행은 멈추지 않고 2초에 끝났다 |
| T-02-SC (accept) | 패키지를 설치하지 않았다. pub get 에 붙인 `--no-example` 은 받는 패키지를 바꾸지 않는다 |

계획의 threat model 에 없는 새 표면(네트워크 endpoint, 인증 경로, 신뢰 경계의 스키마 변경)은 만들지 않았다.

## Known Stubs

없음. 바뀐 두 파일에 `TODO` / `FIXME` / 자리 표시가 없다 (`grep -n -iE`). 건너뛴 테스트와 돌리지 않은 `<verify>` 도 없어 `.planning/WINDOWS.md` 에 더할 항목이 없다.

## User Setup Required

None - 외부 서비스 설정이 필요 없다.

## Next Phase Readiness

**plan 02-03 이 이어받을 것:**

- 검증 명령은 지금 종료 코드 0 이고 `점검 통과 (4개 중 4개)` 다. FVM 이 링크해 둔 SDK 의 dart (M9 가 쓰는 경로)로 78 이 나오는 것을 한 번 봤다.
- M6 (deprecated 한 줄) 의 실패 줄은 계획이 기대한 문자열 뒤에 규칙 이름이 괄호로 붙는다: `…:41  warning  deprecated_lint  (unnecessary_await_in_return)`.
- M2 (include 줄 삭제) 는 이 plan 에서 해 보지 않았다. 옵션 파일에 줄을 **더한** 경우만 봤다.
- 화면을 `2>&1` 로 받으면 맨 위에 stderr 의 `example/ 분석 중…` 이 섞인다. 화면만 받으려면 stdout 만 받는다.
- plugin 준비 실패 화면의 stderr 원문은 스크립트가 이미 `<repo>` 로 가린다.
- README 에 옮길 종료 코드 표는 위 (5) 다.

**plan 02-04 가 이어받을 것:**

- runner 에서 D-12 가 어느 경로로 통과하는지(1순위인지 `FLUTTER_ROOT` 인지)는 화면에 찍히지 않는다. 78 로 실패하면 stderr 의 두 줄 중 어느 것인지로 가른다 — "Flutter SDK 의 dart 가 아니다" 면 버전 파일을 못 찾았거나 fallback 의 `dartSdkVersion` 이 맞지 않은 것이다.
- 화면에 runner 의 절대 경로가 남는 자리는 pub 이 낸 stderr 를 그대로 옮기는 69 의 안내뿐이다 (가리지 않았다).

**요구사항:** `VERIFY-01` · `VERIFY-02` · `VERIFY-03` · `VERIFY-07` 을 이 plan 이 선언했다. `VERIFY-02` 의 기록용 재현(M6)과 `VERIFY-08` 은 plan 02-03 의 일이다.

**blocker:** 없음.

## Self-Check: PASSED

- 바뀐 파일 둘과 이 SUMMARY 가 디스크에 있다 (`[ -f … ]` → 전부 FOUND): `tool/verify.dart`, `example/expected_diagnostics.txt`.
- 커밋 `d707988`, `19ae5ec` 가 HEAD 의 조상이다 (`git merge-base --is-ancestor` → 둘 다 FOUND).
- `gsd-tools check evaluation-scope --plan 02-02 --commits-only` → `status: resolved`, commits 2개 (이 브랜치). `git rev-list --count` 로 잰 값도 2 다.
- 두 task 의 `<automated>` verify 를 Task 2 커밋 뒤에 처음부터 다시 돌려 둘 다 rc=0 (Task 1: `RC=0 U=64 T=0 P=1`, Task 2: `RC=0`).
- plan 의 `<verification>` 과 `<success_criteria>` — 버전 3줄 + 단계 4개 통과 + 종료 코드 0, `lib/` 의 `.dart` 로 `[1/4]` 실패 · 1, CI 의 `--update` 64, 모르는 인자 64, 실행 뒤 복사본 폴더 없음, 정답지 첫 줄의 형식과 16줄 불변, `feat(02-02):` 커밋 2개, `lib/` · `pubspec.yaml` 불변, push 없음 — 을 모두 확인했다.
- `git status --short` 에 이 plan 의 코드 파일이 남아 있지 않다. 임시로 바꿨던 `lib/analysis_options.yaml`, `.fvmrc`, `example/analysis_options.yaml`, `example/pubspec.yaml`, 전용 상태 폴더는 모두 되돌렸고 그 뒤 검증 명령이 종료 코드 0 이다.

---
*Phase: 02-verification-harness*
*Completed: 2026-10-12*
