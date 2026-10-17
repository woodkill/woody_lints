---
phase: 06-release
plan: 04
subsystem: release
tags: [release, version, changelog, pubspec-lock, git-push, github-actions, smoke-test, riverpod_lint]

requires:
  - phase: 06-release
    provides: "06-01 의 `tool/verify.dart --tag` 와 모드 줄, 06-02 의 README 측정 문장 · VERSIONING 「릴리스 절차」, 06-03 의 `tool/smoke.dart`"
provides:
  - "릴리스 커밋 704bf56 — version 2.0.0 · CHANGELOG 2026-10-15 · lock 여섯 · pubspec 주석 (IN-13) · VERSIONING 「실제 사례」 67 · 69행"
  - "origin/gsd/v2.0-package-rework == 704bf56, GitHub verify run 38690710677 success (평소 모드 10/10)"
  - "예행 통과 커밋 704bf56 — 06-05 가 tag v2.0.0 을 다는 커밋"
  - "D-14 측정의 재확인 — base.yaml + plugins: 블록에서 riverpod_lint 가 켜진다 (README 문장 그대로)"
affects: [06-05 tag 와 소유자 확인, 06-06 PR · main, 06-07 처리 기록]

actuals:
  tokens: 1424
  tasks: 3
  commits: 1
plan_head_before: 272c0b4541e10fb2bd0999a1660cec22dfa7154c
plan_head_after: 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2

tech-stack:
  added: []
  patterns:
    - "릴리스 커밋 → push gate (범위 2336ba0 부터의 더해진 줄 전부) → 브랜치 이름 하나의 push → CI → 예행 smoke 를 같은 커밋으로"
    - "예행이 네트워크 정지로 무효가 되면 같은 커밋으로 처음부터 다시 돈다 — 릴리스 커밋 · push · CI 는 그대로 유효"

key-files:
  created: []
  modified:
    - pubspec.yaml
    - CHANGELOG.md
    - VERSIONING.md
    - example/pubspec.lock
    - fixtures/base_codegen/pubspec.lock
    - fixtures/base_only/pubspec.lock
    - fixtures/base_riverpod/pubspec.lock
    - fixtures/overrides/pubspec.lock
    - fixtures/recommended/pubspec.lock

key-decisions:
  - "CHANGELOG 날짜 = 릴리스 커밋 날 (2026-10-15) — tag 가 다음 날 달려도 고치지 않는다; VERSIONING 67행 날짜도 같은 값"
  - "예행 1회차(네트워크 정지, orchestrator 가 멈춘 받기를 끊음)는 무효로 보고 같은 커밋으로 다시 돌렸다 — README · 스크립트를 고칠 근거로 쓰지 않았다"

patterns-established:
  - "push gate 는 push 명령 바로 앞에서 글자 그대로 — rc 0 일 때만 같은 셸 호출 안에서 push"

requirements-completed: [REL-02, REL-04]

coverage:
  - id: D1
    description: "릴리스 커밋 하나에 version 2.0.0 · pubspec 13행 주석 · CHANGELOG 날짜 · VERSIONING 67 · 69행 · lock 여섯(각 1/1)이 들어 있고 평소 · --tag v2.0.0 두 모드가 10/10"
    requirement: "REL-02"
    verification:
      - kind: integration
        ref: "06-04-PLAN.md Task 1 <automated> (릴리스 커밋 직후, 기준 HEAD~1)"
        status: pass
    human_judgment: false
  - id: D2
    description: "push gate 통과 뒤 git push origin gsd/v2.0-package-rework, origin == HEAD, main · tag · PR 그대로, GitHub verify success 와 로그 세 줄"
    requirement: "REL-02"
    verification:
      - kind: integration
        ref: "06-04-PLAN.md Task 2 <automated> 둘 (push gate 는 push 직전, 둘째는 CI 뒤)"
        status: pass
    human_judgment: false
  - id: D3
    description: "예행 smoke (704bf56) 통과 — 두 주소 각각 prefer_single_quotes · provider_parameters, resolved-ref == sha; D-14 측정이 README 문장과 같다"
    requirement: "REL-04"
    verification:
      - kind: integration
        ref: "06-04-PLAN.md Task 3 <automated> (2회차 smoke 뒤)"
        status: pass
    human_judgment: false

duration: 140min
completed: 2026-10-15
status: complete
---

# Phase 6 Plan 04: 릴리스 커밋 · push · 예행 Summary

**릴리스 커밋 `704bf56` (`version: 2.0.0`, `## 2.0.0 - 2026-10-15`, lock 여섯, IN-13, VERSIONING 「실제 사례」 현재형)을 push gate 뒤 작업 브랜치에 올렸다. GitHub `verify` 는 평소 모드 10/10 으로 통과했고, 같은 커밋을 빈 프로젝트가 GitHub 에서 받는 예행 smoke 와 D-14 측정이 모두 통과했다. 이 커밋이 tag `v2.0.0` 을 달 커밋이다.**

예행 통과 커밋: 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2

## Performance

- **Duration:** 약 140분 (그 가운데 약 112분은 무효가 된 예행 1회차 — 아래 Issues)
- **Started:** 2026-10-15T05:49:51Z
- **Completed:** 2026-10-15T08:10Z 무렵
- **Tasks:** 3
- **Files modified:** 9 (릴리스 커밋 하나)

## Task 1 — 릴리스 커밋

- 커밋 `704bf56fb028debe16f107bc9a8e6c9bdc5bccc2` — `chore(release): 2.0.0 — version · CHANGELOG 날짜 · lock 여섯 · pubspec 주석 (IN-13) · VERSIONING 실제 사례`
- numstat: `pubspec.yaml` 2/2 · `CHANGELOG.md` 1/1 · `VERSIONING.md` 2/2 · lock 여섯 각 1/1 (`example`, `fixtures/base_codegen` · `base_only` · `base_riverpod` · `overrides` · `recommended`) — 정확히 9 파일
- `pubspec.yaml`: `version: 2.0.0-dev` → `version: 2.0.0`; 13행 `# lib/analysis_options.yaml 이 …` → `# lib/base.yaml 이 \`include: package:flutter_lints/flutter.yaml\` 을` (IN-13)
- `CHANGELOG.md` 1행: `## 2.0.0 - 미출시` → `## 2.0.0 - 2026-10-15`. **CHANGELOG 날짜 = 릴리스 커밋 날** (커밋 시각 2026-10-15 14:52 +0900). 오늘 날짜도 2026-10-15 로 같다. tag 가 다음 날 달려도 이 날짜는 고치지 않는다.
- `VERSIONING.md` 「실제 사례」:
  - 67행 전: `` - `2.0.0` (미출시, 다음 릴리스) — 지원 SDK 하한을 `^3.10.4` 에서 `^3.13.0` 으로 올린다 → major (1번에서 멈춤). ``
  - 67행 후: `` - `2.0.0` (2026-10-15, tag `v2.0.0`) — 지원 SDK 하한을 `^3.10.4` 에서 `^3.13.0` 으로 올린다 → major (1번에서 멈춤). ``
  - 69행 전: `  - 그래서 다음 릴리스는 **2.0.0** 이다. 이번 릴리스에 들어가는 변경 중 가장 큰 등급이 SDK 하한 상향(major)이기 때문이다.`
  - 69행 후: `  - 그래서 **2.0.0** 으로 냈다. 이번 릴리스에 들어가는 변경 중 가장 큰 등급이 SDK 하한 상향(major)이기 때문이다.`
  - 70 · 126행과 `## 릴리스 절차` 는 그대로다.
- lock: 루트에서 `fvm dart pub get` 한 번(rc 0) 뒤 여섯 폴더에서 각각 `fvm dart pub get` (옵션 없음, 모두 rc 0). 바뀐 줄은 lock 마다 `woody_lints` 항목의 `version: "2.0.0-dev"` → `"2.0.0"` 하나뿐이고, 다른 패키지 줄은 바뀌지 않았다.
- 검증: `fvm dart analyze` No issues. `fvm dart run tool/verify.dart` rc 0 · 10/10 · stderr `버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)`. `--tag v2.0.0` rc 0 · 10/10 · `[3/10] 배포 파일의 구성 … 통과` · stderr `버전 일치 검사: tag v2.0.0 (--tag)`. README 의 `ref: v2.0.0` 은 18 · 339행 두 곳이고 그대로다.

## Task 2 — push gate · push · CI

- 범위: `2336ba0..704bf56`, 커밋 35개, fast-forward. 첫 커밋 제목 `docs(05-15): 4회차 gap 처리 기록 · push 05-15 SUMMARY — …`, 마지막 커밋은 릴리스 커밋이다. 바뀐 파일 41개(`.planning/` 27, 밖 14), 더해진 줄 6237줄.
- push 전 원격: head 둘(`main` = `90a2736…`, 작업 브랜치 = `2336ba0…`), tag `v1.3.0` 하나, PR 0, `gh auth status` 통과, `.planning/` 밖 트리 깨끗.
- 로컬 검증 (push 전 다시): analyze No issues, `dart format --set-exit-if-changed tool` 0 changed, 평소 모드 rc 0 · 10/10, `--tag v2.0.0` rc 0 · 10/10.
- **push gate** (Task 2 의 첫 `<automated>`, 글자 그대로): 06:07:26Z 시작 → 06:07:30Z 에 **rc 0**. 점검 (1) · (2) · (3) 모두 0 이었고 범위에 orchestrator 상태 파일은 없었다.
- **push**: 06:07:30Z 시작, `git push origin gsd/v2.0-package-rework` 한 줄, rc 0, 06:08:56Z 끝. 출력:
  ```
  To github.com:woodkill/woody_lints.git
     2336ba0..704bf56  gsd/v2.0-package-rework -> gsd/v2.0-package-rework
  ```
  push gate 가 push 보다 먼저 끝났다 (06:07:30Z ≤ 06:07:30Z 시작, 같은 셸 호출에서 gate rc 0 일 때만 push).
- **CI**: run `38690710677` (workflow `verify`, push 이벤트), 결론 `completed` · `success`. job `verify` 는 06:09:02Z ~ 06:12:39Z (3분 37초, `timeout-minutes` 10 안), 이미지 `ubuntu-24.04` / `20261004.327.1`. 로그 세 줄:
  - `버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)`
  - `[3/10] 배포 파일의 구성 ................ 통과`
  - `점검 통과 (10개 중 10개)`
- push 뒤 원격: 작업 브랜치 = `704bf56…` (HEAD 와 같다), `main` = `90a2736…`, tag `v1.3.0` 하나, PR 0. 둘째 push 는 없었다.

## Task 3 — 예행 · D-14

- 로컬 일치 검사: `fvm dart run tool/verify.dart --tag v2.0.0` rc 0 · 10/10 · tag 모드 줄 (Task 1 · 2 · 3 의 `<automated>` 에서 모두 같음).
- **예행 smoke (2회차, 유효)** `fvm dart run tool/smoke.dart 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2`: 08:06:42Z ~ 08:07:23Z, **rc 0, 41초**, stderr 0바이트, 화면에 경로 0줄. 화면 (경로 없음, 위반 파일 이름은 "위반 파일" 로 줄여 적었다):
  ```
  SDK Flutter 3.47.5 / Dart 3.13.4
  기대 커밋: 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2 (git rev-parse '704bf56fb028debe16f107bc9a8e6c9bdc5bccc2^{commit}')
  flutter create: exit 0, 0.5s
  flutter pub get: exit 0, 5.3s — lock: source git, url https://github.com/woodkill/woody_lints.git, resolved-ref 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2

  ## recommended — package:woody_lints/recommended.yaml
     dart analyze exit 2, 17.6s, 머리말 없음, plugin 폴더 1, riverpod_lint 3.1.9
     (6줄) 템플릿 main 4행 warning missing_provider_scope, 위반 파일 12행 warning provider_parameters,
           위반 파일 5행 info prefer_single_quotes, 위반 파일 8행 info specify_nonobvious_property_types,
           pubspec.yaml:36 · :48 info sort_pub_dependencies
     판정: prefer_single_quotes 있음 · provider_parameters 있음

  ## alias — package:woody_lints/analysis_options.yaml
     dart analyze exit 2, 16.3s, 머리말 없음, plugin 폴더 1, riverpod_lint 3.1.9
     (6줄, recommended 와 같음)
     판정: prefer_single_quotes 있음 · provider_parameters 있음

  smoke 통과 (ref 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2 → 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2, recommended 6줄 / 옛 주소 6줄, riverpod_lint 3.1.9)
  임시 폴더를 지웠다
  ```
  lock 의 `resolved-ref` 가 sha 와 같다 (D-09 (3)). 두 주소의 6줄은 06-03 의 통과 실행과 같다.
- **D-14 측정** (`--keep` 실행 rc 0, 38초 뒤 같은 빈 프로젝트에서): 옵션 파일을 계획의 열세 줄(`include: package:woody_lints/base.yaml` + 템플릿의 `analyzer: exclude:` + README 「프로젝트 전체」 의 `linter:` · `plugins:` 블록)로 바꿨다. 새 상태 폴더와 그 폴더의 pub cache 를 주고 **고정 SDK 의 dart** 로 분석했다. 그 dart 는 저장소 루트 `fvm flutter --version --machine` 의 `flutterRoot` 아래 것으로, Flutter 3.47.5 · `Dart SDK version: 3.13.4 (stable)` 이다.
  - 종료 코드 2, 16초, plugin 준비 실패 머리말 0, plugin 폴더 1
  - 진단 5줄: 위반 파일 12행 WARNING `provider_parameters` (plugin 이 켜졌다), 위반 파일 5행 INFO `prefer_single_quotes`, 위반 파일 8행 INFO `specify_nonobvious_property_types`, `pubspec.yaml:36` · `:48` INFO `sort_pub_dependencies`
  - `missing_provider_scope` 는 없다 (끈 것). `prefer_final_locals` 도 없다.
  - **README 「프로젝트 전체」 측정 문장과 같은 결과다** ("`riverpod_lint` 가 켜진다 … `provider_parameters` 가 나왔고 `missing_provider_scope` 는 꺼졌다"). 그래서 README 를 고치지 않았다.
  - 남긴 폴더는 측정 직후 통째로 지웠다.
- Task 3 `<automated>` (글자 그대로, 08:08:45Z ~ 08:10:06Z): **rc 0**, 81초. 이 명령도 안에서 smoke `--keep` 과 D-14 측정을 한 번 더 했고, 남긴 폴더를 지웠다. 저장소 안에 `app` · `pub-cache` 는 생기지 않았다.
- 사람이 README 를 따라 하는 확인(05-UAT 1번 · D-09 (1))은 이 plan 이 하지 않는다. 06-05 의 tag 직전 checkpoint 에서 소유자가 한다.

## `<automated>` 결과

계획 파일에서 줄 머리의 `<verify>` … `</verify>` 구간 안, 줄 머리 `<automated>` 블록만 python `-I` 로 그대로 뽑아(Task 1 2696 · Task 2 1669 / 1536 · Task 3 3024바이트) 저장소 루트에서 `bash` 로 돌렸다. 고친 판은 만들지 않았다.

| Task | 돌린 시점 | rc |
|---|---|---|
| Task 1 | 릴리스 커밋 직후, Task 2 의 어떤 일보다 먼저 (05:52:20Z ~ 06:00:02Z, 기준 `HEAD~1`) | 0 |
| Task 2 첫째 (push gate) — 첫 시도 | 06:06:41Z — 뽑기 결함으로 산문이 뽑혀 bash 문법 오류 rc 2, **push 하지 않음** (아래 Deviation 1) | 2 (명령이 아님) |
| Task 2 첫째 (push gate) | push 직전 06:07:26Z ~ 06:07:30Z | 0 → push |
| Task 2 둘째 | CI success 뒤, metadata 커밋 전 (06:13:50Z) | 0 |
| Task 3 | 예행 2회차 · D-14 뒤, metadata 커밋 전 (08:08:45Z ~ 08:10:06Z) | 0 |

## Task Commits

1. **Task 1: 릴리스 커밋** — `704bf56` (chore) `chore(release): 2.0.0 — version · CHANGELOG 날짜 · lock 여섯 · pubspec 주석 (IN-13) · VERSIONING 실제 사례`
2. **Task 2: push gate · push · CI** — 커밋 없음 (원격 갱신과 run 38690710677)
3. **Task 3: 예행 · D-14** — 커밋 없음 (README 를 고칠 일이 없었다)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 의 커밋 (docs). push 하지 않는다 (06-06 이 올린다).

## Files Created/Modified

- `pubspec.yaml` — `version: 2.0.0`, 13행 주석 `lib/base.yaml`
- `CHANGELOG.md` — 1행 `## 2.0.0 - 2026-10-15`
- `VERSIONING.md` — 「실제 사례」 67 · 69행 현재형
- lock 여섯 — `woody_lints` 의 `version: "2.0.0"`

## Decisions Made

- CHANGELOG 날짜는 릴리스 커밋 날(2026-10-15)이고 그대로 둔다. VERSIONING 67행도 같은 값이다.
- 예행 1회차는 무효로 보고, 같은 커밋으로 smoke · D-14 · Task 3 `<automated>` 를 처음부터 다시 돌렸다 (coordinator 지시). 릴리스 커밋 · push · CI 는 그대로 유효하다.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `<automated>` 뽑기 도구가 산문의 `<verify>` · `<automated>` 글자에 걸림**
- **Found during:** Task 2 (push gate 첫 시도)
- **Issue:** 내 뽑기 스크립트의 정규식 `<verify>(.*?)</verify>` 가 Task 2 action 산문의 "아래 `<verify>` 의 **첫** `<automated>`" 에서 시작했다. 그래서 첫 블록으로 산문이 뽑혀 bash 문법 오류(rc 2)가 났다. 단언이 실패한 것이 아니라 명령이 아닌 글이 돈 것이다. gate 가 0 이 아니어서 push 는 하지 않았다.
- **Fix:** 줄 머리에 오는 `<verify>` · `</verify>` · `<automated>` 만 잡도록 정규식을 고쳤다 (계획 파일은 고치지 않았다). 다시 뽑은 Task 1 블록은 앞과 같은 2696바이트였다 — Task 1 의 rc 0 은 유효하다.
- **Verification:** 네 블록의 머리글자가 각각 `B=$(git log …`, `git fetch origin --quiet && test …` ×2, `git fetch origin --quiet && SHA=…` 이고, 다시 뽑은 push gate 가 rc 0 이었다.
- **Committed in:** 해당 없음 (도구는 저장소 밖)

---

**Total deviations:** 1 auto-fixed (Rule 3 1건)
**Impact on plan:** 없음 — push 는 적힌 그대로의 gate 가 rc 0 일 때만 했다.

## Issues Encountered

- **예행 smoke 1회차 무효 (네트워크 정지):** 06:14Z 무렵 시작한 회차에서 `flutter pub get` 이 약 70분 걸렸다 (lock 기록 07:24Z, 보통 5 ~ 7초). 이어진 `recommended` 주소의 plugin 준비 `dart pub upgrade` 는 41분 동안 진전이 없었다. 소유자 결정으로 orchestrator 가 08:05:51Z 에 그 받기 프로세스 하나만 끊었다. 그래서 그 회차는 rc 1(`recommended: plugin 준비 실패`)로 끝났고, `alias` 쪽은 18 ~ 19초에 통과했다. 저장소 · 릴리스 커밋의 문제가 아니므로 README · 스크립트를 고치지 않았다. 08:06:42Z 에 같은 명령으로 다시 돌린 회차는 rc 0 · 41초(`pub get` 5.3초)였고, 위 Task 3 의 결과가 그 회차의 것이다.
- Task 1 `<automated>` 가 462초, Task 2 의 로컬 두 모드가 135초 · 172초로 06-03 때보다 길었다. 같은 시간대의 느린 회선과 같은 원인으로 보지만 재지 않았다. 결과는 모두 10/10 이다.

## User Setup Required

None - 네트워크(GitHub · pub.dev)만 필요하다.

## Next Phase Readiness

- **06-05 (tag · 소유자 확인):** tag `v2.0.0` 은 **704bf56fb028debe16f107bc9a8e6c9bdc5bccc2** 에 단다 (= `origin/gsd/v2.0-package-rework`, 예행 통과 커밋). 원격에는 아직 `v2.0.0` 이 없다 (Task 3 `<automated>` 확인). 원격 `main` = `90a2736`, tag 는 `v1.3.0` 하나, PR 0 이다.
- CHANGELOG 날짜 `2026-10-15` 는 tag 날짜와 달라도 고치지 않는다 (고치면 릴리스 커밋이 바뀌어 예행을 다시 해야 한다).
- 사람이 README 를 따라 하는 확인(05-UAT 1번)은 06-05 의 tag 직전 checkpoint 에서 한다. 그 시점에는 `ref: v2.0.0` 이 없으므로 `ref:` 만 `704bf56…` 으로 바꿔 따라 한다.
- 이 metadata 커밋은 push 하지 않았다 — 로컬이 origin 보다 1커밋 앞선다. 06-05 · 06-06 의 `origin == HEAD` 단언과 push gate 범위에 이 커밋이 들어간다.
- 회선이 다시 느려지면 smoke 의 받기 단계가 오래 멈출 수 있다. 1회차처럼 끊으면 rc 1 로 끝나지만 저장소 문제는 아니다.

---
*Phase: 06-release*
*Completed: 2026-10-15*

## Self-Check: PASSED

- FOUND: `pubspec.yaml`, `CHANGELOG.md`, `VERSIONING.md`, lock 여섯
- FOUND: `704bf56` (`git merge-base --is-ancestor … HEAD`), `origin/gsd/v2.0-package-rework` == `704bf56`
- 세 task 의 `<automated>` 넷 rc 0 (위 표)
