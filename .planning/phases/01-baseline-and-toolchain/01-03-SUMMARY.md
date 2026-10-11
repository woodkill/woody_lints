---
phase: 01-baseline-and-toolchain
plan: 03
subsystem: toolchain
tags: [fvm, flutter-3.47.5, dart-3.13, sdk-constraint, pubspec, changelog, pub-get]

# Dependency graph
requires:
  - phase: 01-01
    provides: "원격 annotated tag `v1.3.0` → `90a2736` — Task 3 이 `origin/main` 불변 검사의 기준 ref 로 쓰고, 옛 SDK 프로젝트가 `ref: v1.3.0` 으로 실제로 받을 수 있는지 GitHub 에서 확인했다"
  - phase: 01-02
    provides: "`VERSIONING.md` 의 `## CHANGELOG 항목 형식` — 2.0.0 항목이 이 형식의 첫 적용이다"
provides:
  - "저장소 고정 SDK: Flutter 3.47.5 / Dart 3.13.4 (`.fvmrc`, `.vscode/settings.json`)"
  - "milestone 브랜치의 지원 SDK 하한 `sdk: ^3.13.0` 과 `version: 2.0.0-dev` (`pubspec.yaml`)"
  - "`CHANGELOG.md` 최상단 항목 `## 2.0.0 - 미출시` — 이후 phase 가 자기 변경을 적어 나갈 자리"
  - "BASE-02 실측 증거: Dart 3.11.0 / 3.11.1 / 3.11.5 에서 `path:` 의존 `pub get` 이 rc=1 `version solving failed`, Dart 3.13.4 에서 rc=0"
  - "옛 SDK 프로젝트가 GitHub 의 `ref: v1.3.0` 으로 1.3.0 을 받는다는 실측 (Dart 3.11.x 세 버전, rc=0)"
affects: [phase-2-harness, phase-3-presets, phase-4-rules, phase-5-docs, phase-6-release]

# Actuals (#2632)
actuals:
  tokens: 354      # chars/4 — `git diff 427b001..HEAD | wc -m` = 1415자 (추적 파일 4개의 실제 diff). plan 의 estimate 는 45000 이었다
  tasks: 3         # Task 1 (auto), Task 2 (auto), Task 3 (auto, 파일 변경 없음)
  commits: 2       # MEASURED: git rev-list --count 427b00170c5aefc24f91e4bea8c7a49ce4c7edd1..HEAD (SUMMARY 작성 시점)
plan_head_before: 427b00170c5aefc24f91e4bea8c7a49ce4c7edd1
plan_head_after: 968a5bb048005dac69ed65268615d174b54a02bb

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "SDK 하한 증거는 저장소 밖 `mktemp -d` 임시 프로젝트에서 FVM 캐시의 SDK 를 절대 경로로 직접 불러(`/Users/woody/fvm/versions/<버전>/bin/dart pub get`) 만든다 — 실패 쪽과 성공 쪽을 같은 디렉터리에서 돌린다"
    - "추적 파일 변경 범위는 작업 트리를 기준 커밋 `90a2736` 과 `git diff --numstat` 으로 비교해 판정한다 — 커밋 전후 결과가 같다"
    - "저장소 고정 SDK 를 바꿀 때는 `fvm use <버전>` 한 번으로 `.fvmrc` 와 `.vscode/settings.json` 을 함께 바꾸고, 직후 `git status` 로 바뀐 추적 파일이 그 둘뿐인지 본다"

key-files:
  created:
    - .planning/phases/01-baseline-and-toolchain/01-03-SUMMARY.md
    - .planning/WINDOWS.md
  modified:
    - .fvmrc
    - .vscode/settings.json
    - pubspec.yaml
    - CHANGELOG.md

key-decisions:
  - "저장소 고정 SDK 는 Flutter 3.47.5 / Dart 3.13.4 다 (`.fvmrc`, `.vscode/settings.json`). 이후 검증과 실측은 `fvm dart …` 로 이 SDK 위에서 돈다"
  - "milestone 브랜치의 `pubspec.yaml` 은 `sdk: ^3.13.0` / `version: 2.0.0-dev` 다. 릴리스 때 `-dev` 를 뗀다 (Phase 6). `main` 과 origin 은 1.3.0 그대로이고 이 변경은 어디에도 push 하지 않았다"
  - "`CHANGELOG.md` 의 `## 2.0.0 - 미출시` 항목이 만들어졌다. 이후 phase 는 자기 변경을 이 항목에 적고, `### 새로 생기는 경고` 의 자리 표시 `(Phase 4 실측 후 채움)` 은 Phase 4 가 실측 표로 바꾼다"

patterns-established:
  - "하한 증거 형식: 명령 · SDK 버전 · 출력 원문 · 종료 코드 · 날짜를 SUMMARY 에 그대로 붙인다 (Phase 6 smoke test 가 재사용)"
  - "pub 오류의 `* Try using the Dart SDK version: 3.13.5` 는 pub 이 추천하는 최신 버전이지 이 패키지의 하한이 아니다 — 문서에는 `Dart 3.13 이상` 으로만 적는다"

requirements-completed: [BASE-01, BASE-02]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "`.fvmrc` 가 `\"flutter\": \"3.47.5\"`, `.vscode/settings.json` 이 `.fvm/versions/3.47.5` 를 가리키고, 저장소 루트에서 `fvm flutter --version` 이 Flutter 3.47.5 / Dart 3.13.4 를 보고한다"
    requirement: "BASE-01"
    verification:
      - kind: other
        ref: "plan 01-03 Task 1 <automated> verify (두 파일 grep, `fvm flutter --version` 첫 줄, `fvm dart --version`, 작업 트리 대 90a2736 numstat `1 1` ×2, `.gitignore`/`README.md`/`lib`/`analysis_options.yaml` 불변) → rc=0"
        status: pass
      - kind: other
        ref: "git show --name-only --format= 3a15da8 → `.fvmrc`, `.vscode/settings.json` 두 줄"
        status: pass
    human_judgment: false
  - id: D2
    description: "milestone 브랜치의 `pubspec.yaml` 이 `sdk: ^3.13.0` / `version: 2.0.0-dev` 이고 나머지 15행은 90a2736 과 같다"
    requirement: "BASE-02"
    verification:
      - kind: other
        ref: "plan 01-03 Task 2 첫 번째 <automated> verify (`grep -qxF` 두 줄, pubspec numstat `2 2`, 루트 `fvm dart pub get` rc=0, `fvm dart analyze` No issues found) → rc=0"
        status: pass
    human_judgment: false
  - id: D3
    description: "이 패키지를 `path:` 로 의존한 임시 프로젝트의 `dart pub get` 이 Dart 3.11.x 에서 rc=1 `requires SDK version ^3.13.0, version solving failed` 로 끝나고 Dart 3.13.4 에서는 rc=0 이다"
    requirement: "BASE-02"
    verification:
      - kind: other
        ref: "plan 01-03 Task 2 두 번째 <automated> verify (mktemp 임시 프로젝트, 3.41.9 rc=1 + 오류 문구, 3.47.5 rc=0 + lock `version: \"2.0.0-dev\"`, probe 전후 git status 동일) → rc=0"
        status: pass
      - kind: other
        ref: "수동 실행 3회: /Users/woody/fvm/versions/{3.41.9,3.41.4,3.41.2}/bin/dart pub get → 셋 다 rc=1, 같은 오류 문구 (Dart 3.11.5 / 3.11.1 / 3.11.0)"
        status: pass
    human_judgment: false
  - id: D4
    description: "`CHANGELOG.md` 첫 줄이 `## 2.0.0 - 미출시` 이고 D-14 의 내용이 그대로 있으며, 기존 1.3.0 / 1.0.0 항목 11행은 90a2736 과 글자 단위로 같다"
    requirement: "BASE-02"
    verification:
      - kind: other
        ref: "plan 01-03 Task 2 첫 번째 <automated> verify (첫 줄, `grep -qxF` 세 줄, CHANGELOG numstat 삭제 0, `git show 90a2736:CHANGELOG.md` = `tail -n 11 CHANGELOG.md`) → rc=0"
        status: pass
    human_judgment: false
  - id: D5
    description: "`origin/main` 의 `lib/` 와 `pubspec.yaml` 은 `v1.3.0` 과 같고 원격 브랜치는 `main` 하나다 — 하한 상향은 milestone 브랜치에만 있고 push 하지 않았다"
    requirement: "BASE-02"
    verification:
      - kind: other
        ref: "plan 01-03 Task 3 <automated> verify (`git rev-parse origin/main` = 90a2736…, `git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` rc=0, `ls-remote --heads` 1줄) → rc=0"
        status: pass
      - kind: other
        ref: "음성 대조: git diff --quiet v1.3.0 HEAD -- lib pubspec.yaml → rc=1 (milestone 브랜치의 pubspec.yaml 은 다르다)"
        status: pass
    human_judgment: false
  - id: D6
    description: "옛 SDK(Dart 3.11.x) 프로젝트가 GitHub 의 `ref: v1.3.0` 으로 1.3.0 을 받는다 — CHANGELOG '올리기 전에' 의 안내가 실제로 성립한다"
    requirement: "BASE-02"
    verification:
      - kind: other
        ref: "plan 01-03 Task 3 <automated> verify (`git:` + `ref: v1.3.0` 임시 프로젝트, 3.41.9 `dart pub get` rc=0, lock `resolved-ref: \"90a2736…\"`, `version: \"1.3.0\"`) → rc=0"
        status: pass
    human_judgment: false

# Metrics
duration: 4min
completed: 2026-10-11
status: complete
---

# Phase 1 Plan 03: SDK 정렬 (Flutter 3.47.5 / Dart 3.13 하한) Summary

**`fvm use 3.47.5` 로 저장소 고정 SDK 를 Flutter 3.47.5 (Dart 3.13.4) 로 올리고, milestone 브랜치의 `pubspec.yaml` 을 `sdk: ^3.13.0` / `version: 2.0.0-dev` 로 바꾸면서 CHANGELOG 에 `## 2.0.0 - 미출시` 항목을 같은 커밋으로 만들었다 — Dart 3.11.x 의 `pub get` 은 `version solving failed` (rc=1) 로 거부되고, 같은 옛 SDK 가 GitHub 의 `ref: v1.3.0` 으로는 1.3.0 을 받는다**

쉬운 말로 풀면 세 가지다.

1. 이 저장소를 열 때 쓰는 Flutter 를 최신(3.47.5)으로 맞췄다. 받는 쪽에는 영향이 없다.
2. "이 패키지는 Dart 3.13 이상에서만 받을 수 있다" 고 적었다. 그보다 낮은 프로젝트는 `pub get` (의존성 내려받기) 때 분명한 오류를 본다. 이 변경은 작업 브랜치에만 있고 GitHub 에 올리지 않았다.
3. 그런 프로젝트가 이름표 `v1.3.0` 에 머물 수 있다는 CHANGELOG 의 말이 참인지 GitHub 에서 실제로 받아 보아 확인했다.

## Performance

- **Duration:** 4 min (278초)
- **Started:** 2026-10-11T04:50:36Z
- **Completed:** 2026-10-11T04:55:14Z (작업·검증 종료 시점. SUMMARY 작성과 상태 갱신 시간은 포함하지 않는다)
- **Tasks:** 3 (auto 3 — Task 3 은 파일을 바꾸지 않는 확인 task)
- **Files modified:** 4 (`.fvmrc`, `.vscode/settings.json`, `pubspec.yaml`, `CHANGELOG.md` — 합계 +16 / -4 줄)

## Accomplishments

- `.fvmrc` 가 `"flutter": "3.47.5"`, `.vscode/settings.json` 이 `"dart.flutterSdkPath": ".fvm/versions/3.47.5"` 다. 두 파일 모두 한 줄씩만 바뀌었고 끝 개행 없음이 유지되었다 (BASE-01)
- 저장소 루트에서 `fvm flutter --version` 이 `Flutter 3.47.5` / `Dart 3.13.4`, `fvm dart --version` 이 `3.13.4` 를 보고한다 (ROADMAP success criterion 2)
- milestone 브랜치의 `pubspec.yaml` 이 `sdk: ^3.13.0` / `version: 2.0.0-dev` 다. 바뀐 것은 정확히 두 줄이다 (BASE-02)
- `CHANGELOG.md` 맨 위에 `## 2.0.0 - 미출시` 항목이 D-14 문구 그대로 있고, 기존 1.3.0 / 1.0.0 항목 11행은 한 글자도 바뀌지 않았다
- 저장소 밖 임시 프로젝트에서 Dart 3.11.5 / 3.11.1 / 3.11.0 의 `dart pub get` 이 모두 rc=1 `… requires SDK version ^3.13.0, version solving failed.` 로 끝났고, Dart 3.13.4 에서는 rc=0 으로 `woody_lints 2.0.0-dev` 를 받았다
- `origin/main` 은 `90a2736` 그대로이고 `lib/` · `pubspec.yaml` 이 `v1.3.0` 과 같다. 원격 브랜치는 `main` 하나다. 이 plan 은 아무것도 push 하지 않았다
- 옛 SDK 세 버전 모두 GitHub 의 `ref: v1.3.0` 으로 `woody_lints 1.3.0` (`resolved-ref: 90a2736…`) 을 받았다 — CHANGELOG "올리기 전에" 의 안내가 실제로 성립한다

## Task Commits

Each task was committed atomically (action → verify → 커밋 순서):

1. **Task 1: `fvm use 3.47.5` 로 저장소 고정 SDK 를 올림 (BASE-01)** - `3a15da8` (chore)
   - 전체 SHA `3a15da8e695f90dc4017c084eb904c5d90c65e99`
   - 제목 `chore(01-03): 저장소 고정 Flutter 를 3.47.5 (Dart 3.13.4) 로 올림`
   - 파일 `.fvmrc`, `.vscode/settings.json`
2. **Task 2: `pubspec.yaml` 의 sdk 하한 · version 과 CHANGELOG 2.0.0 항목 (BASE-02)** - `968a5bb` (feat, breaking)
   - 전체 SHA `968a5bb048005dac69ed65268615d174b54a02bb`
   - 제목 `feat(01-03)!: 지원 SDK 하한을 Dart 3.13 으로 올림 (2.0.0-dev)`
   - 파일 `pubspec.yaml`, `CHANGELOG.md`
3. **Task 3: 받는 쪽 관점 확인** - 커밋 없음 (저장소 파일을 바꾸지 않는다 — plan 의 커밋 계약)

**Plan metadata:** 이 SUMMARY 와 `STATE.md` / `ROADMAP.md` / `REQUIREMENTS.md` / `WINDOWS.md` 를 담는 `docs(01-03)` 커밋 하나 (이 문서 작성 뒤에 만들어지므로 해시는 여기에 적지 않는다)

커밋 수 측정 (SUMMARY 작성 시점):

```text
$ cat .git/gsd-plan-head-before-01-03
427b00170c5aefc24f91e4bea8c7a49ce4c7edd1
$ git rev-list --count 427b00170c5aefc24f91e4bea8c7a49ce4c7edd1..HEAD
2
$ git log --oneline 427b00170c5aefc24f91e4bea8c7a49ce4c7edd1..HEAD
968a5bb feat(01-03)!: 지원 SDK 하한을 Dart 3.13 으로 올림 (2.0.0-dev)
3a15da8 chore(01-03): 저장소 고정 Flutter 를 3.47.5 (Dart 3.13.4) 로 올림
$ git rev-parse HEAD
968a5bb048005dac69ed65268615d174b54a02bb
$ git diff --stat 427b001..HEAD
 .fvmrc                |  2 +-
 .vscode/settings.json |  2 +-
 CHANGELOG.md          | 12 ++++++++++++
 pubspec.yaml          |  4 ++--
 4 files changed, 16 insertions(+), 4 deletions(-)
```

## Files Created/Modified

- `.fvmrc` - 저장소 고정 Flutter 버전. `3.41.2` → `3.47.5`
- `.vscode/settings.json` - VS Code Dart 확장의 SDK 경로. `.fvm/versions/3.41.2` → `.fvm/versions/3.47.5`
- `pubspec.yaml` - `version: 1.3.0` → `2.0.0-dev`, `sdk: ^3.10.4` → `^3.13.0`
- `CHANGELOG.md` - 맨 위에 `## 2.0.0 - 미출시` 항목 12줄 삽입 (기존 11행 불변)
- `.planning/phases/01-baseline-and-toolchain/01-03-SUMMARY.md` - 이 증거 기록
- `.planning/WINDOWS.md` - 새로 생긴 defect 기록부. CHANGELOG 의 자리 표시 한 건을 `open` 으로 적었다 (아래 "Known Stubs")

커밋하지 않은 gitignore 대상 산출물 (저장소 루트에 생기거나 바뀜):

- `.fvm/flutter_sdk` → `/Users/woody/fvm/versions/3.47.5`, `.fvm/versions/3.47.5` → 같은 곳 (심링크)
- `.fvm/fvm_config.json`, `.fvm/release`, `.fvm/version`
- `pubspec.lock` (`sdks: dart: ">=3.13.0 <4.0.0"`), `.dart_tool/`

## Task 1 증거 — `fvm use 3.47.5`

실행 위치 (2026-10-11T04:51Z):

```text
$ git worktree list --porcelain | sed -n '1s/^worktree //p'
/Users/woody/dv/woody/woody_lints
$ git rev-parse --show-toplevel
/Users/woody/dv/woody/woody_lints
IS_MAIN=yes
$ git status --short --untracked-files=no -- . ':(exclude).planning'
(출력 없음 — 저장소 추적 파일 깨끗)
$ fvm --version
4.3.1
```

**`IS_MAIN=yes`** — 메인 체크아웃에서 실행했다 (worktree 가 아니다). 그래서 plan 의 Task 1 7단계(worktree 후속)는 해당하지 않는다.

`fvm use` 출력 원문 (2026-10-11T04:51:33Z, 옵션 없음. 입력 프롬프트는 나오지 않았다 — 표준 입력을 `/dev/null` 로 닫고 실행했다):

```text
$ fvm use 3.47.5
Dependencies resolved offline.
✓ Updated VSCode folder Flutter SDK path setting.
✓ Project now uses Flutter SDK : SDK Version : 3.47.5
rc=0
```

`fvm use` 직후 바뀐 추적 파일 — 정확히 두 줄 (Pitfall 7, 가정 A1 확인):

```text
$ git status --short --untracked-files=no -- . ':(exclude).planning' | sort
 M .fvmrc
 M .vscode/settings.json
```

`.gitignore` 등 다른 추적 파일은 바뀌지 않았다. 되돌린 파일이 없고, `.vscode/settings.json` 은 `fvm use` 가 직접 다시 썼다 (손으로 쓰는 대비책은 쓰지 않았다).

내용 검사:

```text
$ git diff -- .fvmrc .vscode/settings.json      # `diff --git` / `index` 머리 줄은 생략
--- a/.fvmrc
+++ b/.fvmrc
@@ -1,3 +1,3 @@
 {
-  "flutter": "3.41.2"
+  "flutter": "3.47.5"
 }
\ No newline at end of file
--- a/.vscode/settings.json
+++ b/.vscode/settings.json
@@ -1,3 +1,3 @@
 {
-  "dart.flutterSdkPath": ".fvm/versions/3.41.2"
+  "dart.flutterSdkPath": ".fvm/versions/3.47.5"
 }
\ No newline at end of file
$ git diff --numstat 90a2736 -- .fvmrc .vscode/settings.json
1	1	.fvmrc
1	1	.vscode/settings.json
$ tail -c 1 .fvmrc | xxd -p ; tail -c 1 .vscode/settings.json | xxd -p
7d
7d
```

SDK 검사:

```text
$ fvm flutter --version
Flutter 3.47.5 • channel stable • git@github.com:flutter/flutter.git
Framework • revision 6a19cca564 (3주 전) • 2026-09-17 14:13:22 -0400
Engine • hash ab598368592da0064197e2bc15c7f5b0a2c6bb1f (revision af7e796e16) (24 days ago) • 2026-09-16 18:35:09.000Z
Tools • Dart 3.13.4 • DevTools 2.60.0
$ fvm dart --version
Dart SDK version: 3.13.4 (stable) (Tue Sep 15 01:01:15 2026 -0700) on "macos_arm64"
$ ls -la .fvm .fvm/versions                     # 이름과 링크 대상만 추림
flutter_sdk -> /Users/woody/fvm/versions/3.47.5
fvm_config.json
release
version
versions/3.47.5 -> /Users/woody/fvm/versions/3.47.5
```

린트와 plan 의 `<automated>` verify (커밋 전):

```text
$ fvm dart analyze
Analyzing woody_lints...
No issues found!
rc=0
Task 1 <automated> verify rc=0
$ git ls-files pubspec.lock .fvm .dart_tool
(출력 없음)
```

커밋 뒤:

```text
$ git show --name-only --format='%s' 3a15da8
chore(01-03): 저장소 고정 Flutter 를 3.47.5 (Dart 3.13.4) 로 올림

.fvmrc
.vscode/settings.json
```

### Task 1 acceptance criteria

| 기준 | 결과 | 근거 |
|------|------|------|
| `.fvmrc` 에 `"flutter": "3.47.5"` 가 있고 `3.41.2` 가 없다 | PASS | `grep -c '3.41.2' .fvmrc` = 0 |
| `.vscode/settings.json` 에 `"dart.flutterSdkPath": ".fvm/versions/3.47.5"` | PASS | 위 diff |
| `fvm flutter --version` 에 `Flutter 3.47.5` 와 `Dart 3.13.4`, `fvm dart --version` 에 `3.13.4` | PASS | 위 출력 |
| numstat 이 정확히 두 줄, 모두 `1	1` | PASS | 위 출력 |
| `fvm use` 직후 추적 파일 변경이 두 줄이었다는 기록 | PASS | 이 절 |
| `fvm dart analyze` 에 `No issues found!` | PASS | 위 출력 |
| 커밋 뒤 파일 두 줄, 제목이 `chore(01-03): ` 로 시작 | PASS | `3a15da8` |
| `pubspec.lock`, `.fvm/`, `.dart_tool/` 이 커밋에 없다 | PASS | `git ls-files` 출력 없음 |
| SUMMARY 에 `IS_MAIN` 값 | PASS | `yes` — 메인 체크아웃 후속 명령은 필요 없다 |

## Task 2 증거 — sdk 하한과 CHANGELOG 2.0.0 항목

편집 뒤 diff (커밋 전):

```text
$ git diff --numstat 90a2736 -- pubspec.yaml CHANGELOG.md
12	0	CHANGELOG.md
2	2	pubspec.yaml
$ sed -n '3p;11p' pubspec.yaml
version: 2.0.0-dev
  sdk: ^3.13.0
$ grep -c riverpod_lint pubspec.yaml
0
$ grep -n -A1 '^dependencies:' pubspec.yaml
16:dependencies:
17-  flutter_lints: ^6.0.0
$ grep -n -F -e … CHANGELOG.md        # D-14 의 여섯 줄이 이 순서로
1:## 2.0.0 - 미출시
3:지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)
5:### 올리기 전에
7:- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.
9:### 새로 생기는 경고
11:(Phase 4 실측 후 채움)
$ grep -c -e '### 추가한 규칙' -e '### 뺀 규칙' -e '### 그 밖의 변경' CHANGELOG.md
0
$ tail -c 1 pubspec.yaml | xxd -p ; tail -c 1 CHANGELOG.md | xxd -p
0a
0a
```

루트 해석과 린트 (3.47.5, 2026-10-11T04:52Z):

```text
$ fvm dart pub get
Resolving dependencies...
Downloading packages...
Got dependencies!
rc=0
$ grep -A1 '^sdks:' pubspec.lock
sdks:
  dart: ">=3.13.0 <4.0.0"
$ fvm dart analyze
Analyzing woody_lints...
No issues found!
rc=0
Task 2 첫 번째 <automated> verify rc=0
```

### BASE-02 실측 — 저장소 밖 임시 프로젝트 (`path:` 의존)

날짜 2026-10-11T04:53:04Z. 임시 디렉터리는 `mktemp -d` 로 저장소 밖에 만들었다.

```text
PROBE=/var/folders/_b/qf4zy5t11299_51q1x933dk00000gn/T/tmp.cc2kbsAeWz
ROOT=/Users/woody/dv/woody/woody_lints      # git rev-parse --show-toplevel
$ cat "$PROBE/pubspec.yaml"
name: consumer_probe
version: 0.0.1
publish_to: none
environment:
  sdk: ^3.10.0
dev_dependencies:
  woody_lints:
    path: /Users/woody/dv/woody/woody_lints
```

각 실행 전 `$PROBE` 의 `.dart_tool` 과 `pubspec.lock` 을 지웠다.

**실패 쪽 1 — Flutter 3.41.9 / Dart 3.11.5:**

```text
$ /Users/woody/fvm/versions/3.41.9/bin/dart --version
Dart SDK version: 3.11.5 (stable) (Wed Apr 15 00:36:32 2026 -0700) on "macos_arm64"
$ /Users/woody/fvm/versions/3.41.9/bin/dart pub get
Resolving dependencies...
The current Dart SDK version is 3.11.5.

Because consumer_probe depends on woody_lints from path which requires SDK version ^3.13.0, version solving failed.


You can try the following suggestion to make the pubspec resolve:
* Try using the Dart SDK version: 3.13.5. See https://dart.dev/get-dart.
rc=1
```

**실패 쪽 2 — Flutter 3.41.4 / Dart 3.11.1:**

```text
$ /Users/woody/fvm/versions/3.41.4/bin/dart --version
Dart SDK version: 3.11.1 (stable) (Tue Feb 24 00:03:07 2026 -0800) on "macos_arm64"
$ /Users/woody/fvm/versions/3.41.4/bin/dart pub get
Resolving dependencies...
The current Dart SDK version is 3.11.1.

Because consumer_probe depends on woody_lints from path which requires SDK version ^3.13.0, version solving failed.


You can try the following suggestion to make the pubspec resolve:
* Try using the Dart SDK version: 3.13.5. See https://dart.dev/get-dart.
rc=1
```

**실패 쪽 3 — Flutter 3.41.2 / Dart 3.11.0:**

```text
$ /Users/woody/fvm/versions/3.41.2/bin/dart --version
Dart SDK version: 3.11.0 (stable) (Mon Feb 9 00:38:07 2026 -0800) on "macos_arm64"
$ /Users/woody/fvm/versions/3.41.2/bin/dart pub get
Resolving dependencies...
The current Dart SDK version is 3.11.0.

Because consumer_probe depends on woody_lints from path which requires SDK version ^3.13.0, version solving failed.


You can try the following suggestion to make the pubspec resolve:
* Try using the Dart SDK version: 3.13.5. See https://dart.dev/get-dart.
rc=1
```

`* Try using the Dart SDK version: 3.13.5` 는 pub 이 추천하는 최신 버전이지 이 패키지의 하한이 아니다. 하한은 `^3.13.0` 이고 아래처럼 3.13.4 에서 성공한다. 이 문구는 문서에 옮기지 않았다.

**성공 쪽 — Flutter 3.47.5 / Dart 3.13.4:**

```text
$ /Users/woody/fvm/versions/3.47.5/bin/dart --version
Dart SDK version: 3.13.4 (stable) (Tue Sep 15 01:01:15 2026 -0700) on "macos_arm64"
$ /Users/woody/fvm/versions/3.47.5/bin/dart pub get
Resolving dependencies...
Downloading packages...
+ flutter_lints 6.0.0
+ lints 6.1.0
+ woody_lints 2.0.0-dev from path /Users/woody/dv/woody/woody_lints
Changed 3 dependencies!
rc=0
# $PROBE/pubspec.lock 발췌 (woody_lints 항목과 sdks 절)
  woody_lints:
    dependency: "direct dev"
    description:
      path: "/Users/woody/dv/woody/woody_lints"
      relative: false
    source: path
    version: "2.0.0-dev"
sdks:
  dart: ">=3.13.0 <4.0.0"
```

probe 가 저장소 안에 쓰지 않았다는 확인 (probe 전후 출력이 같다 — 이 시점은 커밋 전이라 두 줄이 보이는 것이 정상이다):

```text
$ git status --short -- . ':(exclude).planning'      # probe 전
 M CHANGELOG.md
 M pubspec.yaml
$ git status --short -- . ':(exclude).planning'      # probe 뒤
 M CHANGELOG.md
 M pubspec.yaml
```

plan 의 두 번째 `<automated>` verify 는 위와 별도로 적힌 그대로 한 번 더 돌렸다 (자기 임시 디렉터리를 새로 만든다):

```text
Task 2 두 번째 <automated> verify rc=0   (OLD=3.41.9, PROBE=/var/folders/_b/qf4zy5t11299_51q1x933dk00000gn/T/tmp.cc8DNyADnG)
```

커밋 뒤:

```text
$ git show --name-only --format='%s' 968a5bb
feat(01-03)!: 지원 SDK 하한을 Dart 3.13 으로 올림 (2.0.0-dev)

CHANGELOG.md
pubspec.yaml
$ git log -1 --format=%B 968a5bb | grep -c '^검증'
1
```

### Task 2 acceptance criteria

| 기준 | 결과 | 근거 |
|------|------|------|
| `pubspec.yaml` 3행 `version: 2.0.0-dev`, 11행 `  sdk: ^3.13.0`, 나머지 15행 불변 | PASS | numstat `2	2` |
| `riverpod_lint` 없음, `flutter_lints: ^6.0.0` 이 `dependencies:` 아래 | PASS | 위 출력 |
| CHANGELOG 첫 줄과 D-14 의 여섯 줄이 이 순서로 | PASS | 1, 3, 5, 7, 9, 11행 |
| CHANGELOG 마지막 11행이 `git show 90a2736:CHANGELOG.md` 와 같고, 해당 없는 세 칸은 없다 | PASS | verify 의 `tail -n 11` 비교 rc=0, `grep -c` = 0 |
| `fvm dart pub get` rc=0, `fvm dart analyze` 에 `No issues found!` | PASS | 위 출력 |
| Dart 3.11.x rc=1 + 오류 문구, Dart 3.13.4 rc=0 + lock `version: "2.0.0-dev"` — 원문·버전·날짜가 SUMMARY 에 | PASS | 실패 쪽 3개, 성공 쪽 1개 |
| probe 전후 `git status` 출력이 같다 | PASS | 위 출력 |
| 커밋 뒤 파일 두 줄, 제목이 `feat(01-03)!: ` 로 시작, 본문에 `검증` 절 | PASS | `968a5bb` |
| `git ls-files pubspec.lock .fvm .dart_tool` 이 비어 있다 | PASS | 출력 없음 |

## Task 3 증거 — 받는 쪽 관점 확인

### `origin/main` 은 1.3.0 그대로다 (2026-10-11T04:53:49Z)

```text
$ git fetch origin --quiet
rc=0
$ git rev-parse origin/main
90a2736b8d998c84467faf562a0fec720b797eaf
$ git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml
rc=0                                    # 0 = 같음
$ git diff --quiet v1.3.0 HEAD -- lib pubspec.yaml   # 음성 대조
rc=1                                    # 1 = 다름 — milestone 브랜치는 달라야 정상이다
$ git diff --stat v1.3.0 HEAD -- lib pubspec.yaml
 pubspec.yaml | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
$ git ls-remote --heads origin
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
rc=0
$ git ls-remote origin
90a2736b8d998c84467faf562a0fec720b797eaf	HEAD
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
$ git branch -r
  origin/HEAD -> origin/main
  origin/main
$ git rev-parse --abbrev-ref HEAD ; git rev-parse HEAD
gsd/v2.0-package-rework
968a5bb048005dac69ed65268615d174b54a02bb
$ git diff --quiet v1.3.0 main -- lib pubspec.yaml   # 로컬 main 도 같다
rc=0
```

milestone 브랜치와 1.3.0 의 차이는 `pubspec.yaml` 두 줄뿐이고 `lib/` 는 같다. 원격에는 `main` 과 tag `v1.3.0` 만 있다.

### 옛 SDK 가 GitHub 의 `ref: v1.3.0` 에 머물 수 있다 (2026-10-11T04:54:04Z)

공개 저장소를 HTTPS 로 읽기만 했다 (인증 없음, 쓰기 없음).

```text
P=/var/folders/_b/qf4zy5t11299_51q1x933dk00000gn/T/tmp.C3kW329KwH
$ cat "$P/pubspec.yaml"
name: consumer_tag_probe
version: 0.0.1
publish_to: none
environment:
  sdk: ^3.10.0
dev_dependencies:
  woody_lints:
    git:
      url: https://github.com/woodkill/woody_lints.git
      ref: v1.3.0
```

**Flutter 3.41.9 / Dart 3.11.5** (plan 의 규칙으로 고른 옛 SDK):

```text
$ /Users/woody/fvm/versions/3.41.9/bin/dart --version
Dart SDK version: 3.11.5 (stable) (Wed Apr 15 00:36:32 2026 -0700) on "macos_arm64"
$ /Users/woody/fvm/versions/3.41.9/bin/dart pub get
Resolving dependencies...
Downloading packages...
+ flutter_lints 6.0.0
+ lints 6.1.0
+ woody_lints 1.3.0 from git https://github.com/woodkill/woody_lints.git at 90a273
Changed 3 dependencies!
rc=0
# $P/pubspec.lock 발췌 (woody_lints 항목과 sdks 절)
  woody_lints:
    dependency: "direct dev"
    description:
      path: "."
      ref: "v1.3.0"
      resolved-ref: "90a2736b8d998c84467faf562a0fec720b797eaf"
      url: "https://github.com/woodkill/woody_lints.git"
    source: git
    version: "1.3.0"
sdks:
  dart: ">=3.10.4 <4.0.0"
```

plan 이 요구한 것은 한 버전이지만 나머지 둘에서도 같은 디렉터리로 돌렸다 (각 실행 전 `.dart_tool`, `pubspec.lock` 삭제). 출력은 Dart 버전 줄만 다르고 나머지는 위와 같다.

| SDK | Dart | `dart pub get` | 받은 것 | lock `resolved-ref` |
|-----|------|----------------|---------|---------------------|
| Flutter 3.41.9 | 3.11.5 | rc=0 | `woody_lints 1.3.0 from git … at 90a273` | `90a2736b8d998c84467faf562a0fec720b797eaf` |
| Flutter 3.41.4 | 3.11.1 | rc=0 | `woody_lints 1.3.0 from git … at 90a273` | `90a2736b8d998c84467faf562a0fec720b797eaf` |
| Flutter 3.41.2 | 3.11.0 | rc=0 | `woody_lints 1.3.0 from git … at 90a273` | `90a2736b8d998c84467faf562a0fec720b797eaf` |

"Dart 3.13 미만 프로젝트는 `ref: v1.3.0` 에 머문다" 는 CHANGELOG 의 안내가 참이다.

plan 의 `<automated>` verify (적힌 그대로, 자기 임시 디렉터리를 새로 만든다):

```text
Task 3 <automated> verify rc=0   (OLD=3.41.9, P=/var/folders/_b/qf4zy5t11299_51q1x933dk00000gn/T/tmp.1kZ2J99VRf)
$ git status --short --untracked-files=no -- . ':(exclude).planning'
(출력 없음 — Task 1 · Task 2 커밋이 끝났고 이 task 는 파일을 바꾸지 않았다)
```

### 전체 검증 묶음 SC1 ~ SC5 (2026-10-11T04:54:47Z)

RESEARCH "전체 검증 묶음" 을 그대로 돌렸다. SC4 만 plan 01-02 가 확정한 네 절 제목으로 바꿨다.

| 항목 | 명령 | 결과 |
|------|------|------|
| SC1 | `git ls-remote --tags origin 'v1.3.0^{}' \| grep -q '^90a2736b8d998c84467faf562a0fec720b797eaf'` | PASS |
| SC1b | `git show v1.3.0:pubspec.yaml \| grep -qx 'version: 1.3.0'` | PASS |
| SC2 | `fvm flutter --version 2>/dev/null \| grep -q '^Flutter 3.47.5 ' && fvm dart --version 2>&1 \| grep -q 'version: 3.13.4 '` | PASS |
| SC2b | `grep -q '"dart.flutterSdkPath": ".fvm/versions/3.47.5"' .vscode/settings.json` | PASS |
| SC3a | `grep -qx '  sdk: \^3.13.0' pubspec.yaml && grep -qx 'version: 2.0.0-dev' pubspec.yaml` | PASS |
| SC3b | `git fetch origin --quiet && git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` | PASS |
| SC3c | Task 2 의 임시 프로젝트 결과 인용 — `/Users/woody/fvm/versions/3.41.9/bin/dart pub get` rc=1, 출력에 `requires SDK version ^3.13.0` (3.41.4, 3.41.2 도 같음) | PASS |
| SC4 | `test -f VERSIONING.md && grep -qx '## 판정 순서' VERSIONING.md && grep -qx '## 기준표' VERSIONING.md && grep -qx '## 실제 사례' VERSIONING.md && grep -qx '## CHANGELOG 항목 형식' VERSIONING.md` | PASS |
| SC5 | `head -1 CHANGELOG.md \| grep -qx '## 2.0.0 - 미출시' && grep -q '^지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)$' CHANGELOG.md && grep -q '^### 새로 생기는 경고$' CHANGELOG.md` | PASS |

SC4 와 SC5 는 문서의 존재와 구조까지만 본다. 내용 판정(소유자가 읽고 납득하는가)은 plan 01-02 가 end-of-phase 확인으로 넘긴 그대로다.

### Task 3 acceptance criteria

| 기준 | 결과 | 근거 |
|------|------|------|
| `origin/main` = `90a2736…`, `v1.3.0` 대 `origin/main` rc=0, `v1.3.0` 대 `HEAD` rc=1 | PASS | 위 출력 |
| `git ls-remote --heads origin` 이 `refs/heads/main` 한 줄 | PASS | 위 출력 |
| `git:` + `ref: v1.3.0` 임시 프로젝트의 옛 SDK `pub get` rc=0, `woody_lints 1.3.0 from git`, lock 세 값 | PASS | 위 출력 (세 SDK) |
| SC1 ~ SC5 표, SC4 는 네 절 제목으로 | PASS | 위 표 |
| "후속 작업" 절 | PASS | 아래 |
| `.claude/CLAUDE.md`, `README.md`, `lib/`, 루트 `analysis_options.yaml` 불변 | PASS | `git diff --quiet 427b001 HEAD -- .claude/CLAUDE.md README.md lib analysis_options.yaml .gitignore VERSIONING.md` rc=0, `git status` 출력 없음 |

## 후속 작업

이 phase 범위 밖이라 고치지 않고 적어만 둔다. 어느 것도 이 phase 의 success criteria 에 영향이 없다.

### (a) `.claude/CLAUDE.md` 의 옛 SDK 버전 서술 — 소유자 결정

2026-10-11 실행 시점에 `grep -n '3\.41\.2\|3\.10\.4' .claude/CLAUDE.md` 로 다시 셌다. 합계 **14줄**이고 plan 이 적은 줄 번호와 같다.

| 서술 | 개수 | 줄 번호 |
|------|------|---------|
| `3.41.2` (저장소 고정 Flutter) | 9 | 40, 74, 75, 79, 100, 101, 209, 210, 238 |
| caret 붙은 `^3.10.4` (SDK 하한) | 4 | 39, 166, 262, 314 |
| caret 없는 평문 `3.10.4` ("Dart SDK 3.10.4 이상") | 1 | 83 |

이 14줄은 이 plan 뒤 사실과 어긋난다 (지금은 3.47.5 / `^3.13.0`). **이 phase 는 그 파일을 고치지 않았다** — CONTEXT 가 정한 파일 목록 밖이다. 손으로 고칠지 `/gsd-map-codebase` 로 다시 만들지는 소유자가 정한다.

위 grep 패턴에 걸리지 않지만 읽다가 본 것도 적는다. milestone 브랜치 기준으로 낡은 서술이다 (`main` 기준으로는 아직 참이다).

- 73행, 197행 — `pubspec.yaml` 의 version 을 `1.3.0` 으로 적는다. milestone 브랜치는 `2.0.0-dev` 다
- 154행 — "`CHANGELOG.md` 에는 `1.3.0` 과 `1.0.0` 항목만 있다". milestone 브랜치에는 `2.0.0` 항목이 생겼다
- 40행 — "이 Flutter 에 번들된 Dart SDK 의 정확한 버전은 저장소에서 확인되지 않음". 지금 고정 SDK 의 Dart 는 3.13.4 로 확인되었다

같은 옛 값이 `.planning/codebase/` 의 일곱 문서에도 있다 (metadata 커밋 뒤 2026-10-11 에 `grep -c '3\.41\.2\|3\.10\.4' .planning/codebase/*.md` 로 셌다, 합계 25줄: `STACK.md` 6, `CONVENTIONS.md` 5, `STRUCTURE.md` 5, `ARCHITECTURE.md` 3, `CONCERNS.md` 2, `INTEGRATIONS.md` 2, `TESTING.md` 2). `.claude/CLAUDE.md` 의 해당 절들은 이 문서들에서 만들어진 것이라(`source:codebase/STACK.md` 등의 표시가 있다) 둘은 함께 움직인다. 실행 workflow 에는 plan 뒤에 이 codebase 문서를 갱신하는 단계가 있지만 **이번에는 하지 않았다** — `.claude/CLAUDE.md` 와 같은 결정(손으로 고칠지, `/gsd-map-codebase` 로 다시 만들지)에 묶여 있고 그 결정은 소유자의 것이다. `.claude/CLAUDE.md` 만 손으로 고치면 다음 재생성 때 이 문서들의 옛 값으로 되돌아갈 수 있다.

### (b) 메인 체크아웃의 `fvm use 3.47.5 --skip-pub-get` — 필요 없다

`IS_MAIN=yes` 였다. `fvm use 3.47.5` 를 메인 체크아웃 루트에서 직접 실행했으므로 `.fvm/versions/3.47.5` 링크가 이미 그 자리에 있고, success criterion 2 (`fvm flutter --version` 이 저장소 루트에서 3.47.5) 도 그 자리에서 확인했다. 추가 명령은 없다.

plan 이 남긴 가정 "FVM 이 `.fvm/` 링크 없이 `.fvmrc` 만으로 3.47.5 를 실행하는가" 는 **이번에 시험되지 않았다**. 링크가 있는 상태에서만 돌렸기 때문이다. 이 가정은 참인지 거짓인지 모르는 채로 남는다. 저장소를 새로 clone 하거나 worktree 를 만들면 `.fvm/` 이 없는 상태가 되므로, 그때 `fvm use 3.47.5 --skip-pub-get` 을 한 번 돌리면 확실하다 (`.fvmrc` 가 이미 3.47.5 라 추적 파일 diff 는 없을 것으로 예상하나 이것도 확인하지 않았다).

### (c) FVM 레지스트리 `~/fvm/projects.json`

`fvm use` 가 이 파일을 고쳤다 (수정 시각 2026-10-11 13:51, 742바이트). 저장소 루트 `/Users/woody/dv/woody/woody_lints` 가 등록되어 있다. 임시 프로젝트 경로는 등록되지 않았다 — probe 는 `fvm` 을 거치지 않고 SDK 의 `dart` 를 직접 불렀다. 죽은 항목이 생기지 않았으므로 `fvm cleanup` 은 필요 없다.

### (d) 저장소 밖에 남은 것

지워도 되는 임시 디렉터리 넷 (macOS 가 주기적으로 비운다):

- `/var/folders/_b/qf4zy5t11299_51q1x933dk00000gn/T/tmp.cc2kbsAeWz` — Task 2 `path:` probe
- `/var/folders/_b/qf4zy5t11299_51q1x933dk00000gn/T/tmp.cc8DNyADnG` — Task 2 verify 가 만든 probe
- `/var/folders/_b/qf4zy5t11299_51q1x933dk00000gn/T/tmp.C3kW329KwH` — Task 3 `git:` probe
- `/var/folders/_b/qf4zy5t11299_51q1x933dk00000gn/T/tmp.1kZ2J99VRf` — Task 3 verify 가 만든 probe

그리고 pub 이 `git:` 의존을 해석하면서 `~/.pub-cache/git/` 에 `woody_lints` 의 clone 을 둔다 (threat model T-01-09, 공개 저장소 읽기 전용).

### (e) 편집기

`.vscode/settings.json` 의 SDK 경로가 바뀌었다. VS Code 를 열어 둔 채였다면 창을 다시 불러와야 새 경로가 반영될 수 있다 (이 실행에서는 확인하지 않았다).

## Plan 검증 결과

| 항목 | 결과 |
|------|------|
| Task 1 verify (BASE-01) | PASS — rc=0 |
| Task 2 verify ×2 (BASE-02) | PASS — 둘 다 rc=0 |
| Task 3 verify (`origin/main` = `v1.3.0`, 브랜치 1개, `ref: v1.3.0` 해석) | PASS — rc=0 |
| ROADMAP success criterion 2 | PASS — 저장소 루트(메인 체크아웃)에서 Flutter 3.47.5 / Dart 3.13.4, `.vscode/settings.json` 도 같은 버전 |
| ROADMAP success criterion 3 | PASS — `sdk: ^3.13.0`, Dart 3.11.x `pub get` 이 SDK 불일치 오류, `origin/main` 은 `v1.3.0` 과 같음 |
| 커밋 계약 (task 커밋 2개, Task 3 은 커밋 없음) | PASS — `rev-list --count` = 2 |

### must_haves 의 prohibitions

| 금지 사항 | 지켰는가 | 근거 |
|-----------|----------|------|
| `main` / `origin/main` 의 `lib/` 와 `pubspec.yaml` 은 릴리스 전까지 1.3.0 그대로 — `sdk: ^3.13.0` 과 `version: 2.0.0-dev` 는 milestone 브랜치에만 커밋하고 어디로도 push 하지 않는다 | 지켰다 | 두 커밋은 `gsd/v2.0-package-rework` 에만 있다. 이 plan 이 원격에 대해 실행한 명령은 `git fetch`, `git ls-remote`, pub 의 HTTPS clone 뿐이고 전부 읽기다 — `git push` 는 한 번도 실행하지 않았다. 원격 저장소는 `origin` 하나이고, 실행 뒤 `ls-remote origin` 은 `HEAD`, `refs/heads/main` (`90a2736`), tag 두 줄만 보인다. 로컬 `main` 도 `v1.3.0` 과 `lib/` · `pubspec.yaml` 이 같다 |
| 기존 CHANGELOG 1.3.0 / 1.0.0 항목은 한 글자도 고치지 않는다 | 지켰다 | `git diff --numstat 90a2736 -- CHANGELOG.md` = `12	0` (삭제 0). `git show 90a2736:CHANGELOG.md` 와 `tail -n 11 CHANGELOG.md` 가 같다. 제목에 날짜를 붙이지 않았다 |

### threat_model 의 mitigate 항목

| Threat | 적용한 완화 |
|--------|-------------|
| T-01-06 (`environment.sdk` 가 `main` 에 들어감) | 커밋은 milestone 브랜치에만, push 없음. Task 3 verify 가 `origin/main` = `90a2736` 과 `git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` rc=0 을 확인했다 |
| T-01-07 (`fvm use` 가 예상 밖 추적 파일을 바꿈) | `fvm use` 직후 추적 파일 변경이 정확히 두 줄임을 확인했다. numstat `1 1` ×2, `.gitignore` 등 불변, 커밋 파일 수 2 |
| T-01-08 (임시 프로젝트가 저장소 안에 생기거나 lock 이 커밋됨) | `mktemp -d` 로 저장소 밖에 만들었다. probe 전후 `git status` 가 같았고 Task 3 뒤에는 비어 있다. `git ls-files pubspec.lock .fvm .dart_tool` 출력 없음 |

## Decisions Made

- **저장소 고정 SDK 는 Flutter 3.47.5 / Dart 3.13.4 다.** 이후 검증과 실측은 `fvm dart …` 로 이 SDK 위에서 돈다. 3.41.x 로는 저장소 루트의 `pub get` 이 더는 되지 않는다 (하한이 `^3.13.0` 이다)
- **milestone 브랜치의 `pubspec.yaml` 은 `sdk: ^3.13.0` / `version: 2.0.0-dev` 다.** 릴리스 때 `-dev` 를 뗀다 (Phase 6). `main` 과 origin 은 1.3.0 그대로다
- **CHANGELOG 의 2.0.0 항목은 이제 있다.** 이후 phase 는 자기 변경을 이 항목에 적는다. `### 새로 생기는 경고` 의 자리 표시는 Phase 4 가 실측 표로 바꾼다
- 그 밖에는 plan 을 그대로 따랐다 (`pubspec.yaml` 에 줄 끝 주석을 넣지 않았다 — 이유는 CHANGELOG 항목과 커밋 본문에 있다)

## Deviations from Plan

None - plan executed exactly as written.

plan 이 허용한 범위 안에서 고른 것 두 가지를 적어 둔다 (deviation 이 아니다).

- Task 2 의 실패 쪽 증거는 "가능하면 셋 모두" 를 따라 3.41.9 / 3.41.4 / 3.41.2 세 SDK 에서 다 남겼다
- Task 3 의 `ref: v1.3.0` 확인은 plan 이 한 SDK 만 요구했지만 세 SDK 에서 모두 돌렸다. 추가 비용이 없고 "Dart 3.13 미만" 이라는 안내의 범위를 더 넓게 뒷받침한다

**Total deviations:** 0
**Impact on plan:** 없음. 바뀐 추적 파일 넷, 커밋 둘, push 없음 — 모두 plan 에 적힌 그대로다.

## Authentication Gates

없음. `git fetch` / `git ls-remote` 는 SSH 로, pub 의 `git:` 해석은 공개 저장소 HTTPS 로 프롬프트 없이 동작했다.

## Issues Encountered

None

## Known Stubs

| 파일 | 줄 | 내용 | 사유 |
|------|----|------|------|
| `CHANGELOG.md` | 11 | `(Phase 4 실측 후 채움)` — `### 새로 생기는 경고` 칸의 자리 표시 | 의도된 자리다 (CONTEXT D-14). 규칙을 아직 바꾸지 않았고 실측 수치가 없어 지금은 채울 수 없다. Phase 4 가 실측 표로 바꾼다 |

이 자리 표시는 plan 의 목표(SDK 정렬과 2.0.0 항목 만들기)를 막지 않는다. 다만 릴리스 전에는 반드시 채워져야 하므로 `.planning/WINDOWS.md` 에 `open` 으로 한 건 적었다 (`gsd-tools windows append --kind stub --phase 01 --file CHANGELOG.md --line 11`, id 1). 이 파일은 이번에 처음 생겼고, 열린 항목이 있는 동안 `/gsd-ship` 을 막는다 — Phase 4 가 표를 채운 뒤 닫으면 된다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 1 의 plan 세 개가 모두 끝났다 (01-01 tag, 01-02 정책 문서, 01-03 SDK 정렬). phase 검증으로 넘어갈 수 있다
- Phase 2 부터의 검증과 실측은 지원 대상 SDK(Flutter 3.47.5 / Dart 3.13.4) 위에서 돈다. 저장소 루트에서 `fvm dart pub get` 과 `fvm dart analyze` 가 통과한다
- Phase 3 ~ 5 는 자기 변경을 `CHANGELOG.md` 의 `## 2.0.0 - 미출시` 항목에 적는다. 형식은 `VERSIONING.md` 의 `## CHANGELOG 항목 형식` 이다
- Phase 6 의 일치 검사(REL-03)는 `pubspec.yaml` 의 `2.0.0-dev` 와 CHANGELOG 제목의 `2.0.0` 이 다른 것을 보게 된다 — 완성 전 tag 를 막으려고 일부러 둔 차이다. 릴리스 때 `-dev` 를 떼고 `미출시` 를 날짜로 바꾼다
- 유지할 약속: 릴리스 전까지 origin 에는 `main` 과 tag 외에 아무것도 올리지 않는다. 인자 없는 `git push` 는 현재 브랜치와 `.planning/` 을 공개 저장소에 올리고, `main` 으로의 병합은 `ref: main` 사용 프로젝트 5개에 `sdk: ^3.13.0` 을 배포한다 (Flutter 를 고정하지 않은 4개의 `pub get` 이 깨질 수 있다)
- 소유자 결정이 남은 것: `.claude/CLAUDE.md` 의 옛 버전 서술 14줄 (위 "후속 작업" (a))
- 막힌 것 없음

## Self-Check: PASSED

SUMMARY 작성 뒤 다시 확인했다 (2026-10-11T04:59:26Z):

| 주장 | 확인 | 결과 |
|------|------|------|
| 바뀐 추적 파일 넷이 있다 | `[ -f ]` — `.fvmrc`, `.vscode/settings.json`, `pubspec.yaml`, `CHANGELOG.md` | FOUND ×4 |
| 이 SUMMARY 파일이 있다 | `[ -f .planning/phases/01-baseline-and-toolchain/01-03-SUMMARY.md ]` | FOUND |
| `.planning/WINDOWS.md` 가 있다 | `[ -f .planning/WINDOWS.md ]` | FOUND |
| task 커밋 `3a15da8` 이 HEAD 의 조상이다 | `git merge-base --is-ancestor 3a15da8 HEAD` | FOUND |
| task 커밋 `968a5bb` 가 HEAD 의 조상이다 | `git merge-base --is-ancestor 968a5bb HEAD` | FOUND |
| task 커밋 2개 | `git rev-list --count 427b00170c5aefc24f91e4bea8c7a49ce4c7edd1..HEAD` = `2` | 일치 |
| `plan_head_after` | `git rev-parse HEAD` = `968a5bb048005dac69ed65268615d174b54a02bb` | 일치 |
| Task 1 verify, Task 2 첫 번째 verify | 커밋 뒤 다시 실행, 둘 다 rc=0 (작업 트리를 `90a2736` 과 비교하므로 커밋 전후 판정이 같다) | PASS |
| must_haves artifact (plan frontmatter 가 이 문서에 요구한 pub 오류 문구 — BASE-02 실측 절에 원문이 있다) | 그 문구를 `grep -c` 로 셈 = 7 | PASS |
| 원격은 그대로다 | `git ls-remote origin` → `HEAD`, `refs/heads/main` (`90a2736`), tag 두 줄 | PASS |
| 이 plan 의 커밋이 이 브랜치에 있다 | `gsd-tools check evaluation-scope --plan 01-03 --commits-only` → `status: resolved`, 커밋 2개 | PASS |
| frontmatter 와 `coverage` 블록이 읽힌다 | `gsd-tools verify-summary` → `passed: true`, `gsd-tools uat classify-coverage` → 6건 분류, 전부 자동 | PASS |

Task 2 두 번째 verify 와 Task 3 verify 는 여기서 다시 돌리지 않았다 (임시 프로젝트와 네트워크를 다시 쓴다). 각 task 에서 돌린 결과(rc=0)가 위 절에 있다.

---
*Phase: 01-baseline-and-toolchain*
*Completed: 2026-10-11*
