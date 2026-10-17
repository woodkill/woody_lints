---
phase: 06-release
plan: 01
subsystem: testing
tags: [dart, verify-harness, release, version-agreement, github-actions]

requires:
  - phase: 05-documentation
    provides: "[3/10] 의 확인 (a) ~ (h), compareLineReadersWithYaml, IN-12 · IN-14 · 05-UAT 5번의 미룬 손질"
provides:
  - "[3/10] 의 버전 일치 확인 (i) — checkVersionAgreement · pubspecVersionText · changelogTop · changelogFile"
  - "main 의 --tag vX.Y.Z 인자, GITHUB_REF_TYPE · GITHUB_REF_NAME 로 읽는 tag 모드, stderr 의 `버전 일치 검사:` 모드 줄"
  - "keysSeenByLineReader 의 keyLikePattern (IN-12), 종료 코드 255 주석 (IN-14)"
  - "example/README.md 의 새 소절 (06-01) M92 ~ M97, 종료 코드 표 255 행 · 64 · 70 행 구절, 116행 (i) 구절"
  - ".github/workflows/verify.yml 7행 주석의 현재형 (trigger 는 그대로)"
affects: [06-02, 06-03, 06-04, 06-05, 06-07]

actuals:
  tokens: 9566
  tasks: 3
  commits: 3
plan_head_before: 36692498df6761089ab229cc04bf2ea86da1f3ef
plan_head_after: b0ff2d283d5bd21c7d60e22a0673041a00aa4eff

tech-stack:
  added: []
  patterns:
    - "값의 어긋남은 [3/10] 의 블록 하나(머리 줄 · 빈 줄 · 안내 줄), 파일 모양이 다르면 FormatException → 70"
    - "CI 로그에서 모드를 가르는 줄은 stderr 에 — stdout 첫 줄은 늘 SDK 줄"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - .github/workflows/verify.yml
    - example/README.md

key-decisions:
  - "tag 모드는 pubspec.yaml 의 원문(pubspecVersionText)과 꼬리 없이 정확히 견주고, pubspecReleaseVersion 은 바꾸지 않았다 (D-04 (2))"
  - "--tag 의 다음 인자가 -- 로 시작하면 값이 없는 것으로 보고 64 — --tag --update 를 tag 이름 --update 로 읽지 않는다 (계획보다 한 가지 더 막음)"
  - "pubspecVersionText 는 version: 값이 비어 있어도 읽지 못한 것으로 보고 같은 FormatException (70)"

patterns-established:
  - "tag 이름의 출처: --tag 인자 우선, 없으면 GITHUB_REF_TYPE=tag 일 때의 GITHUB_REF_NAME, 둘 다 없으면 평소 모드"

requirements-completed: [REL-03]

coverage:
  - id: D1
    description: "[3/10] 의 버전 일치 확인 (i) 와 --tag 인자 · CI 환경변수 · stderr 모드 줄 (평소 10/10, --tag v2.0.0 블록 둘, --tag 2.0.0 블록 하나, 환경변수 tag 모드, 인자 우선, 64 둘)"
    requirement: REL-03
    verification:
      - kind: integration
        ref: "06-01-PLAN.md Task 1 <automated> (fvm dart run tool/verify.dart 여덟 번)"
        status: pass
    human_judgment: false
  - id: D2
    description: "workflow 7행 주석만 현재형 — 나머지 줄 79f27e5 와 같음, trigger 셋 그대로, branches · tags 키 없음"
    requirement: REL-03
    verification:
      - kind: other
        ref: "06-01-PLAN.md Task 1 <automated> (md5 · 줄 수 · grep)"
        status: pass
    human_judgment: false
  - id: D3
    description: "IN-12 (keyLikePattern) 과 IN-14 · 05-UAT 5번의 문장 — 복제본에서 include 값을 다음 줄에 쓴 입력 10/10, M78 블록 그대로"
    verification:
      - kind: integration
        ref: "06-01-PLAN.md Task 2 <automated> (복제본 전체 실행 + 함수 단위 하네스)"
        status: pass
    human_judgment: false
  - id: D4
    description: "example/README.md 의 M92 ~ M97 기록 · 116행 · 종료 코드 표, 릴리스 상태 복제본에서 하네스로 다시 단언"
    requirement: REL-03
    verification:
      - kind: integration
        ref: "06-01-PLAN.md Task 3 <automated> (새 복제본 둘, M93 전체 실행, 하네스 열한 번)"
        status: pass
    human_judgment: false

duration: 17min
completed: 2026-10-15
status: complete
---

# Phase 6 Plan 01: 버전 일치 확인 (i) Summary

**`tool/verify.dart` 의 `[3/10]` 이 tag 이름(`--tag` 또는 GitHub 의 `GITHUB_REF_NAME`) · `pubspec.yaml` 원문 · `CHANGELOG.md` 최상단 `## X.Y.Z - YYYY-MM-DD` 를 견주는 확인 (i) 를 얻었고, 모드 줄을 stderr 에 남기며, IN-12 · IN-14 를 닫고, 복제본에서 깨뜨린 다섯 입력과 IN-12 전후를 M92 ~ M97 로 기록했다**

## Performance

- **Duration:** 17 min
- **Started:** 2026-10-15T04:56:01Z
- **Completed:** 2026-10-15T05:13:15Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments

- 평소 모드(인자 · 환경변수 없음)는 꼬리를 뗀 version 과 CHANGELOG 버전만 견주어 지금 상태(`2.0.0-dev` · `미출시`)에서 10/10, tag 모드는 `vX.Y.Z` 꼴 · 원문 정확히 · CHANGELOG 버전 · 날짜 자리 꼴을 본다.
- stderr 모드 줄 셋(`평소 (…)` · `tag <이름> (--tag)` · `tag <이름> (GITHUB_REF_NAME)`) — 06-05 가 진짜 tag push 로그에서 찾을 줄.
- `include:` 값을 다음 줄에 쓴 `lib/base.yaml` 이 더는 `[3/10]` 에서 거짓 실패하지 않는다 (M97). M78 의 블록은 그대로.
- 종료 코드 255 의 경우가 머리 주석 · 문서 주석 · `example/README.md` 표 · 읽는 법에 적혔다 (코드는 그대로, D-13).

## Task Commits

1. **Task 1: [3/10] 에 버전 일치 확인 (i) 와 --tag · CI 환경변수 · 모드 줄, workflow 7행** — `d2aaf7c` (fix) `fix(tool): [3/10] 에 버전 일치 확인 (i) 과 --tag 인자 — tag · pubspec · CHANGELOG 최상단 버전 (REL-03)`
2. **Task 2: IN-12 · IN-14 · 05-UAT 5번** — `971a6f2` (fix) `fix(tool): keysSeenByLineReader 가 값 없는 최상위 키 아래의 스칼라 값 줄을 키로 담지 않음 (IN-12); 종료 코드 255 와 YAML 범위의 문장 (IN-14 · 05-UAT 5번, D-13)`
3. **Task 3: 지워 보기 M92 ~ M97 기록** — `b0ff2d2` (test) `test(example): 지워 보기 M92 ~ M97 — 버전 일치 다섯 입력과 include 값의 줄, 종료 코드 표 · [3/10] 설명 (06-01, D-06)`

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 을 담는 `docs(06-01)` 커밋.

## `<automated>` 결과

| Task | 적힌 그대로 rc | 고친 판 | 걸린 시간 |
|------|----------------|---------|-----------|
| 1 | 0 | 없음 | 130초 |
| 2 | 0 | 없음 | 76초 |
| 3 | 0 | 없음 | 168초 |

각 `<automated>` 는 그 task 의 커밋 직후, 다음 task 를 시작하기 전에 돌렸다 (계획 파일에서 `<verify>` 안의 글자를 그대로 뽑아 `bash` 로).

### (1) Task 1 의 실행 여덟 (작업 트리, 파일을 바꾸지 않는 실행)

| # | 실행 | 종료 코드 | stderr 모드 줄 |
|---|------|-----------|----------------|
| 1 | 인자 없음 | 0 · `점검 통과 (10개 중 10개)` · stdout 첫 줄 `SDK` | `버전 일치 검사: 평소 (…)` |
| 2 | `--tag v2.0.0` | 1 · `[3/10]` 만 실패 · 블록 둘(`-dev` 꼬리, 날짜 자리 `미출시`) | `버전 일치 검사: tag v2.0.0 (--tag)` |
| 3 | `--tag 2.0.0` | 1 · 꼴 블록 하나 | `버전 일치 검사: tag 2.0.0 (--tag)` |
| 4 | `GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v2.0.0` | 1 · `-dev` 블록 포함 | `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` |
| 5 | `GITHUB_REF_TYPE=branch …` | 0 | `버전 일치 검사: 평소 (…)` |
| 6 | 환경변수 `v9.9.9` + `--tag v2.0.0` | 1 | `버전 일치 검사: tag v2.0.0 (--tag)` (인자 우선) |
| 7 | `--tag` (값 없음) | 64 · stdout 빈 출력 · `사용법: fvm dart run tool/verify.dart [--update] [--tag vX.Y.Z]` | — |
| 8 | `--bogus` | 64 · `모르는 인자: --bogus` | — |

### (2) Task 2 의 복제본 실행 둘

- `lib/base.yaml` 의 `include:` 값을 다음 줄로 내린 복제본의 전체 실행: 종료 코드 0 · `점검 통과 (10개 중 10개)`.
- M78 입력(`  "zz_quoted_plugin": ^0.1.0` 한 줄)의 함수 단위 실행: `passed=false`, 그 원문이 (a′) 줄과 (h) 블록의 `줄 단위 reader 에만:` 으로 두 번, `YAML 에만: zz_quoted_plugin` 한 번.

### (3) Task 3 의 실험 (경로는 `<복제본>`)

복제본 HEAD `971a6f2`, `fvm dart pub get --no-example` 1초. 하네스는 `fvm dart run --packages=<복제본>/.dart_tool/package_config.json <하네스> <복제본> [tag]`.

| 실험 | 입력 | 결과 | 시간 |
|------|------|------|------|
| 기준 (a) | HEAD 상태 전체 실행 | 0 · 10/10 · stderr 평소 줄 | 71초 |
| 기준 (b) | 릴리스 상태, 하네스 `v2.0.0` · tag 없이 | 둘 다 `passed=true` | 1초 이하 |
| M92 | 하네스 `v2.0.1` | `passed=false`, pubspec 블록 · CHANGELOG 블록 | 1초 |
| M93 | pubspec `-dev` 그대로, CHANGELOG 1행만 날짜, 전체 실행 `--tag v2.0.0` | 1 · `[3/10]` 만 · `-dev` 꼬리 블록 하나 · `점검 실패 (10개 중 1개)` · stderr `(--tag)` | 33초 |
| M94 | 1행 `## 2.1.0 - 2026-10-15` | tag 모드 CHANGELOG 블록 하나, 평소 모드 `(2.0.0 → 2.0.0)` 블록 하나 | 1초 이하 |
| M95 | 1행 `## 2.0.0 - 미출시` | 날짜 자리 블록 `미출시` | 1초 |
| M96 | 하네스 `2.0.0` · `release-2.0.0` | 각각 꼴 블록 하나뿐 | 1초 |
| 가장자리 | ` - ` 두 번 · `TBD` · `2026-1-5` · `# Changelog` 머리 줄 | 날짜 자리 블록 하나씩, 머리 줄은 `passed=true` | 1초 이하 |
| M97 | `include:` 값을 다음 줄에; (가) Task 1 커밋의 `tool/verify.dart` (나) HEAD (다) 따옴표 값 | (가) `passed=false` · `줄 단위 reader 에만: package:flutter_lints/flutter.yaml` · `YAML 에만: (없음)` (나) `passed=true` (다) `passed=true` | 1초 |
| 회귀 M78 | `  riverpod_lint: ` 뒤 한 줄 | `passed=false`, (a′) `6행:   "zz_quoted_plugin": ^0.1.0`, (h) 블록 그대로 | 1초 |
| 되돌린 뒤 | 전체 실행 | 0 · 10/10 | 32초 |

복제본의 `git status --porcelain` 빈 출력, `build/woody_rule_check` 없음, 복제본 · 하네스 폴더 지움. 작업 트리는 건드리지 않았다.

## Files Created/Modified

- `tool/verify.dart` — (i) 와 reader 둘 · 상수 하나, `main` 의 `--tag` · 환경변수 · 모드 줄, 머리 주석, `keyLikePattern`, 255 주석
- `.github/workflows/verify.yml` — 7행 주석만 현재형
- `example/README.md` — 종료 코드 표 255 행 · 64 · 70 행 구절, 116행 (i) 구절, (05-14) 읽는 법 문장, 새 소절 (06-01), 각주

## Decisions Made

- `pubspecVersionText` 는 `version:` 값이 비어 있으면(따옴표만 등) 읽지 못한 것으로 보고 `pubspecReleaseVersion` 과 같은 문구의 `FormatException` 을 던진다.
- 사용법 줄은 `main` 안의 상수 `usage` 하나를 두 곳(`--tag` 값 없음 · 모르는 인자)이 함께 쓴다 — 글자가 갈라지지 않게.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - 입력 방어] `--tag` 다음 인자가 `--` 로 시작하면 값 없음으로 본다**
- **Found during:** Task 1
- **Issue:** 계획은 "다음 인자가 없거나 빈 문자열이면 64" 다. 그대로면 `--tag --update` 가 tag 이름 `--update` 로 읽혀 `[3/10]` 실패(1)가 되고 `--update` 도 사라진다.
- **Fix:** 다음 인자가 `--` 로 시작해도 `--tag 에 값이 없다` + 사용법 + 64.
- **Files modified:** `tool/verify.dart`
- **Verification:** Task 1 `<automated>` rc 0 (값 없음 · `--bogus` 의 64 그대로)
- **Committed in:** `d2aaf7c`

---

**Total deviations:** 1 auto-fixed (Rule 2 하나)
**Impact on plan:** 사용법 오류로 잡는 경우를 하나 넓혔을 뿐이고, 계획이 단언한 동작은 모두 그대로다.

## Issues Encountered

- 계획 파일에서 `<automated>` 를 뽑을 때 산문 안의 `` `<automated>` `` 표기에 걸려 처음에는 엉뚱한 구간이 잡혔다. `<verify>` 바로 안의 `<automated>` 만 뽑도록 고쳐 세 개를 얻었다 (계획 파일은 고치지 않았다).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 06-02 (`README.md` · `VERSIONING.md`): 로컬 확인 명령은 `fvm dart run tool/verify.dart --tag vX.Y.Z` 이고, 모드 줄 글자는 `버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)` · `버전 일치 검사: tag <이름> (--tag)` · `버전 일치 검사: tag <이름> (GITHUB_REF_NAME)` 이다. (i) 의 안내 줄 둘이 `VERSIONING.md 「릴리스 절차」` 를 가리킨다 — 그 절 이름을 바꾸면 안내 줄도 고친다. `README.md` 에 펜스 코드 블록을 새로 더하면 (e) ~ (g) 의 후보가 된다.
- 06-03 (`tool/smoke.dart`): `tool/verify.dart` 의 공개 함수 서명이 `checkShippedComposition(String repoRoot, {String? tag})` 로 바뀌었다 (기존 호출은 그대로 돈다). 사용법 줄은 `main` 안의 상수 `usage`.
- 06-04: 릴리스 상태(`version: 2.0.0` · 날짜)에서 `--tag v2.0.0` 함수 단위는 통과였다. 전체 실행은 lock 여섯을 다시 받아야 69 를 넘는다.
- ROADMAP 의 Phase 6 줄 `**Plans**:` 괄호 문구 · 진행 표는 `roadmap.update-plan-progress` 뒤에 확인만 했다 (아래 STATE 단계 참고 — orchestrator 가 마지막에 고친다). `requirements.mark-complete` 는 부르지 않았다 (REL-03 은 06-05 · 06-07 도 선언).

---
*Phase: 06-release*
*Completed: 2026-10-15*

## Self-Check: PASSED
