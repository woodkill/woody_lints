---
phase: 06-release
plan: 15
subsystem: release
tags: [release, github, pull-request, merge-commit, github-actions, gap-closure]

requires:
  - phase: 06-release
    provides: "06-14 의 PR #3 (main ← gsd/v2.0-package-rework, head 0461741, MERGEABLE / CLEAN), push 실행 38934754393 · pull_request 실행 38935292307 success; 06-12 · 06-13 의 고침 커밋 85e1b0d · 9d96778 · ea2d664"
provides:
  - "PR #3 merged — https://github.com/woodkill/woody_lints/pull/3"
  - "origin/main = merge commit 3418989cbb32ec1a84919dcaa82a5df238fa4155 (부모 0038572 · 0461741), 고침 커밋 셋 · 작업 브랜치 · v2.0.0 이 main 의 조상"
  - "main push 실행 38936761858 success, 평소 모드, 10/10"
affects: [06 재검증 (/gsd-verify-work 06), 다음 릴리스 (main 에서 시작), /gsd-complete-milestone (Keep branches)]

actuals:
  tokens: 0
  tasks: 2
  commits: 0
plan_head_before: 4ee0c5552a5f3248818adad51d9019e76ba6f9e6
plan_head_after: 4ee0c5552a5f3248818adad51d9019e76ba6f9e6

tech-stack:
  added: []
  patterns:
    - "gap 수정 2회차의 main 병합도 gh pr merge --merge 만 — 첫 부모 = 앞 병합 커밋(0038572), 제목 머리로 찾은 고침 커밋 셋이 merge-base --is-ancestor 로 main 의 조상인지 본다 (06-11 과 같은 꼴)"

key-files:
  created: []
  modified: []

key-decisions:
  - "소유자 응답 merge (2026-10-16T17:01:23Z, orchestrator 가 dispatch 전에 물음) 뒤에만 gh pr merge 3 --merge — main = 2.0.0 + 06 gap 수정 2회차 (merge commit 3418989), 받는 쪽 변화 없음 (규칙 · version 2.0.0 · CHANGELOG · tag 그대로)"

patterns-established: []

requirements-completed: [REL-02, REL-03, REL-04]

coverage:
  - id: D1
    description: "소유자 확인 (merge) 뒤 merge commit 으로 PR #3 병합 — 부모 둘(첫 부모 0038572, 둘째 0461741), 고침 커밋 셋 · 작업 브랜치 · v2.0.0 이 origin/main 의 조상, main 의 pubspec 2.0.0 + markdown · CHANGELOG 1행 그대로 · 고침 글자 셋(changelogTopOf( · 파일의 첫 줄 · allowMalformed: true), PR MERGED · mergeCommit == origin/main, head 둘 · tag 4줄 그대로"
    requirement: "REL-04"
    verification:
      - kind: integration
        ref: "06-15-PLAN.md Task 2 <automated> (적힌 그대로) rc 0 — main push 실행 뒤, metadata 커밋 전 (17:08:23Z ~ 17:08:35Z)"
        status: pass
    human_judgment: false
  - id: D2
    description: "main push 실행 38936761858 completed · success, 로그에 버전 일치 검사: 평소 · 점검 통과 (10개 중 10개) — 첫 줄 규칙의 [3/10] 이 main 에서 거짓 실패를 내지 않는다"
    requirement: "REL-03"
    verification:
      - kind: e2e
        ref: "06-15-PLAN.md Task 2 <automated> (적힌 그대로) rc 0 — gh run view 38936761858 의 conclusion · --log 두 줄"
        status: pass
    human_judgment: false
  - id: D3
    description: "tag 는 v1.3.0 · v2.0.0 네 줄 그대로이고 새 tag 가 없다 (REL-02 의 tag v2.0.0 유지)"
    requirement: "REL-02"
    verification:
      - kind: integration
        ref: "06-15-PLAN.md Task 2 <automated> (적힌 그대로) rc 0 — git ls-remote --tags origin 4줄 · v2.0.0^{} == v2.0.0^{commit}"
        status: pass
    human_judgment: false

duration: 약 6분
completed: 2026-10-16
status: complete
---

# Phase 6 Plan 15: 06 gap 수정 2회차 main 병합 Summary

**소유자의 `merge` 응답 뒤 `gh pr merge 3 --merge` 로 merge commit `3418989` 를 만들었다. 부모는 `0038572` (06-11 의 merge commit) · `0461741` (PR head) 둘이다. 06-12 · 06-13 의 고침 커밋 셋(`85e1b0d` · `9d96778` · `ea2d664`), 작업 브랜치, `v2.0.0` 이 모두 `main` 의 조상이 되었다. `main` 의 push 실행 `38936761858` 도 평소 모드로 10/10 통과했다. tag · 버전 · CHANGELOG 는 그대로이고, 받는 쪽 규칙도 바뀌지 않았다.**

## Performance

- **Duration:** 약 6분 (17:02:42Z ~ 17:08:43Z)
- **Started:** 2026-10-16T17:02:42Z
- **Completed:** 2026-10-16T17:08:35Z (Task 2 `<automated>` 끝)
- **Tasks:** 2 (checkpoint:decision — dispatch 전에 응답됨 · auto)
- **Files modified:** 0 (저장소 추적 파일 기준. 이 plan 이 남긴 것은 원격 `main` · PR 상태 · Actions 실행뿐이다)

시각 순서 (소유자 확인이 병합보다 앞섰다는 기록):

| 시각 (UTC) | 한국 시각 | 일 |
|------------|-----------|----|
| 17:01:23Z 직후 | 02:01 (10-17) | orchestrator 재확인 — `origin/main` = `0038572`, 원격 작업 브랜치 = `0461741`, PR #3 `OPEN` · head `0461741` · `MERGEABLE/CLEAN`, main 대상 열린 PR 1건 |
| 17:01:23Z | 02:01:23 (10-17) | 소유자 응답 `merge` (Task 1, orchestrator 가 dispatch 전에 물음) |
| 17:02:42Z ~ 17:02:45Z | 02:02:42 ~ 02:02:45 | 실행자의 Task 1 · Task 2 precondition 재확인 — 그대로 |
| 17:03:33Z ~ 17:03:36Z | 02:03:33 ~ 02:03:36 | 병합 직전 재확인 (Task 2 의 1) — `origin/main` = `0038572`, PR `OPEN MERGEABLE CLEAN 0461741…` |
| 17:03:36Z ~ 17:03:40Z | 02:03:36 ~ 02:03:40 | `gh pr merge 3 --merge …` rc 0 (GitHub `mergedAt` 17:03:39Z) |
| 17:03:42Z | 02:03:42 | `main` push 실행 38936761858 생성 |
| 17:03:45Z ~ 17:08:00Z | 02:03:45 ~ 02:08:00 | `main` push 실행의 job `verify` (4분 15초) |
| 17:03:50Z | 02:03:50 | 병합 확인 (부모 둘 · `merge-base` 다섯 · `main` 의 파일 · `ls-remote`) |
| 17:08:05Z | 02:08:05 | `gh run watch 38936761858 --exit-status` rc 0 |
| 17:08:23Z ~ 17:08:35Z | 02:08:23 ~ 02:08:35 | Task 2 `<automated>` rc 0 |

## Task 1 — 소유자 확인 (dispatch 전에 끝남)

**확인 요청 (orchestrator 가 dispatch 전에 소유자에게 쉬운 말로 보였다):** 계획 Task 1 `<action>` 의 여섯 가지.

- 합칠 것: PR #3 (https://github.com/woodkill/woody_lints/pull/3), 작업 브랜치 `gsd/v2.0-package-rework` 의 06-11 병합 뒤 커밋 21개 (06 재검증 · 리뷰 · gap 계획 기록, 06-12 의 첫 줄 규칙 · 지워 보기 M107 ~ M115, orchestrator 의 U+FEFF 표기 커밋 `e6a4cbc`, 06-13 의 smoke 여섯 고침, 06-14 의 처리 기록). 지금 `main` 은 `0038572` 다.
- 받는 쪽에 바뀌는 것: 없다. 규칙 · `version: 2.0.0` · CHANGELOG 항목은 그대로다. 그래서 새 tag · 버전도 없다 (VERSIONING.md 기준표 "저장소 안쪽만 바뀜 → 올리지 않음").
- 명령: `gh pr merge 3 --merge`. squash · rebase 는 쓰지 않는다 (D-02 — 커밋 번호를 새로 만든다). 브랜치는 지우지 않는다.
- 되돌릴 수 없다는 점: `main` 을 되감지 않는다. 문제가 보이면 다음 커밋으로 고친다.
- 점검 결과: 브랜치 push 실행 `38934754393` · PR 실행 `38935292307` success 10/10, `MERGEABLE/CLEAN`, `main` 보호 없음. 06-12 의 M107 ~ M115, 06-13 의 하네스와 `v2.0.0` smoke, 처리 기록 아홉 `fixed` · IN-08 `deferred` · open 0.
- 합친 뒤 할 일: Task 2 (부모 둘 · 조상 · `main` 의 파일 · `main` 실행).

질문: PR #3 를 지금 merge commit 방식으로 `main` 에 합칠까 — 선택지는 `merge — 합친다` (권고) / `hold — 합치지 않는다`.

**소유자 응답:**

- **`merge` (합친다)**, 2026-10-16T17:01:23Z (2026-10-17 02:01:23 KST). orchestrator 가 dispatch 전에 물었다.
- 사유: 소유자가 따로 쓰지 않았다. 권고 이유 승인 — 다음 릴리스의 gate 고침(첫 줄 규칙) · smoke 고침이 `main` 에 들어가고 06 gap 수정 2회차가 끝난다.

**precondition 재확인 (실행자, 17:02:42Z ~ 17:02:45Z, 읽기만):** `git fetch origin --quiet` 뒤 `origin/main` = `00385725e043bce0d3523a59ff8543603e5d1bd8`, `origin/gsd/v2.0-package-rework` = `0461741202008704d285d57aaaec9a8907c306d4` 였다. `gh pr list --state open --base main --head gsd/v2.0-package-rework` 는 1건(#3)이었고 `OPEN` · `MERGEABLE` · `CLEAN`, headRefOid 가 원격 작업 브랜치와 같았다. 06-14-SUMMARY 에 두 실행의 success 가 있었다. orchestrator 가 본 값과 모두 같았다.

## Task 2 — 병합 · 확인 · `main` 실행

**직전 재확인 (17:03:33Z ~ 17:03:36Z):** `origin/main` = `0038572…`, PR #3 `OPEN MERGEABLE CLEAN 0461741202008704d285d57aaaec9a8907c306d4`. 두 조건이 참일 때만 병합하도록 한 셸 안에 `&&` 로 묶었다.

**병합 (17:03:36Z ~ 17:03:40Z, rc 0):**

```text
gh pr merge 3 --merge --subject "fix: main 에 06 gap 수정 2회차 병합 — CHANGELOG 첫 줄 규칙 · smoke 디코딩 · 제한 · 판정 · 중단 (PR #3)" --body "<아래 본문>"
```

출력은 stdout · stderr 모두 0바이트다 (tty 가 아닌 셸에서 `gh pr merge` 는 아무것도 찍지 않는다. 06-06 · 06-11 과 같다). GitHub 의 `mergedAt` 은 `2026-10-16T17:03:39Z`, `mergedBy` 는 `woodkill` 이다. `--squash` · `--rebase` · `--delete-branch` · `--admin` · `--auto` 는 쓰지 않았다. merge commit 본문 (GitHub 에 그대로 들어갔다 — `git log -1 --format=%B origin/main` 로 확인):

```text
작업 브랜치 gsd/v2.0-package-rework 의 06 gap 수정 2회차(06-12 · 06-13)와 처리 기록을 main 에 합친다.

- tool/verify.dart 의 [3/10] 버전 일치 검사가 CHANGELOG.md 최상단 항목을 파일의 첫 줄에서 읽고, Markdown 해석의 첫 h2 와 같을 때만 통과한다 (WR-02 · WR-05 · IN-09)
- VERSIONING.md 「CHANGELOG 항목 형식」 에 최상단 항목의 제목은 파일의 첫 줄이라는 한 줄을 더한다
- tool/smoke.dart 가 UTF-8 아닌 출력을 받아들이고, 시간 제한을 출력 수집까지 넓히고, 종료 코드 3 · error 없음을 실패로 보고, SIGINT 의 띄우는 창 · 자손 정리의 안내와 재확인 · 예외 안내의 가리기를 고친다 (WR-04 · WR-06 · IN-04 ~ IN-07)
- 받는 쪽에 바뀌는 것 없음 — 규칙 · version 2.0.0 · CHANGELOG 항목 그대로, 저장소 안쪽(검증 스크립트 · smoke · VERSIONING.md 형식 한 줄 · 기록)만 바뀜. 새 tag · 버전 없음
- merge commit 으로 합침 (squash · rebase 아님, D-02) — 작업 브랜치는 지우지 않는다
- 소유자 결정 G7-Q1 ~ G7-Q3 (G7-Q3 병합 직전 확인 — merge)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01FMQRSJydizwp5HqzzNuetV
```

본문은 병합 전에 훑었다. 절대 경로 · 홈 · 임시 폴더 꼴, 계정 이메일, 비공개 사용 프로젝트 이름은 0이었다. 발견 ID 는 고침 커밋 제목의 괄호(`85e1b0d` · `9d96778` · `ea2d664`)에서 옮겼다.

**확인 (17:03:50Z, `git fetch origin --quiet` 뒤):**

```text
origin/main = 3418989cbb32ec1a84919dcaa82a5df238fa4155
$ git log -1 --format=%P origin/main
00385725e043bce0d3523a59ff8543603e5d1bd8 0461741202008704d285d57aaaec9a8907c306d4
subject = fix: main 에 06 gap 수정 2회차 병합 — CHANGELOG 첫 줄 규칙 · smoke 디코딩 · 제한 · 판정 · 중단 (PR #3)   (committer GitHub)
merge-base --is-ancestor 85e1b0d origin/main -> 0 (85e1b0d1b18e74b02ff20004d30894d8c1153b25; fix(tool): [3/10] 의 CHANGELOG 최상단 reader 를 파일 첫 줄로 고정 — Mark)
merge-base --is-ancestor 9d96778 origin/main -> 0 (9d967784e5b4ef08513857f424bb5a7f63357f59; fix(tool): smoke runProcess 의 UTF-8 아닌 출력 허용 · 제한을 출력 수집까지, )
merge-base --is-ancestor ea2d664 origin/main -> 0 (ea2d6647460a87e11583ec6ee43b65e78a38000f; fix(tool): smoke SIGINT 의 띄우는 창 · killTree 의 안내와 재확인 · 예외 안내)
merge-base --is-ancestor 0461741202008704d285d57aaaec9a8907c306d4 origin/main -> 0 (0461741202008704d285d57aaaec9a8907c306d4; docs(review): 06 처리 기록 2회차 — WR-02 · WR-04 ~ WR-06 · IN-04 ~)
merge-base --is-ancestor v2.0.0 origin/main -> 0 (704bf56fb028debe16f107bc9a8e6c9bdc5bccc2; chore(release): 2.0.0 — version · CHANGELOG 날짜 · lock 여섯 · p)
$ git show origin/main:pubspec.yaml | grep -n -e '^version:' -e markdown
3:version: 2.0.0
21:# markdown 은 tool/verify.dart 가 CHANGELOG.md 첫 줄의 최상단 제목을 Markdown 해석의 첫 h2 와 견주는 둘째 reader 로만 쓴다 — …
24:  markdown: ^7.3.1
$ git show origin/main:CHANGELOG.md | head -1
## 2.0.0 - 2026-10-15
$ git show origin/main:tool/verify.dart | grep -c -F 'changelogTopOf('
2
$ git show origin/main:VERSIONING.md | grep -n -F '파일의 첫 줄'
83:  - 최상단 항목의 제목은 **파일의 첫 줄**이다 — …
$ git show origin/main:tool/smoke.dart | grep -n -F 'allowMalformed: true'
486:/// 출력은 `Utf8Decoder(allowMalformed: true)` 로 받는다 — …
525:    const decoder = Utf8Decoder(allowMalformed: true);
$ gh pr view 3 --json state,mergedAt,mergedBy,mergeCommit
MERGED, mergedAt 2026-10-16T17:03:39Z, mergedBy woodkill, mergeCommit 3418989cbb32ec1a84919dcaa82a5df238fa4155
$ git ls-remote --heads origin
0461741202008704d285d57aaaec9a8907c306d4	refs/heads/gsd/v2.0-package-rework
3418989cbb32ec1a84919dcaa82a5df238fa4155	refs/heads/main
$ git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
753f52057079702a9bf64226e1dc4a5bb858e0ee	refs/tags/v2.0.0
704bf56fb028debe16f107bc9a8e6c9bdc5bccc2	refs/tags/v2.0.0^{}
v2.0.0^{commit} = 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2
```

(괄호 안 제목은 확인용으로 60자에서 잘랐고, 긴 주석 줄은 `…` 로 줄였다.) 부모는 둘이다. 첫 부모는 06-11 의 merge commit `0038572`, 둘째 부모는 병합 전 작업 브랜치 머리 `0461741` 다. 고침 커밋 셋은 범위 `54d9ae9..origin/gsd/v2.0-package-rework` 에서 제목 머리로 찾았다 (`-- tool/verify.dart` 에서 하나, `-- tool/smoke.dart` 에서 둘 — `<automated>` 가 같은 방식으로 다시 찾았다). 작업 브랜치는 원격에 남아 있다 (Keep branches). tag 4줄도 그대로다. 로컬 `main` 브랜치는 건드리지 않았다. `grep` 은 zsh wrapper 를 피해 시스템 grep 으로 돌렸다.

**`main` 의 push 실행:** run **38936761858** (event push, headBranch `main`, headSha `3418989`), 17:03:42Z 생성, `completed` · **`success`**. job `verify` 는 17:03:45Z ~ 17:08:00Z (4분 15초) 이다. 이미지는 `ubuntu-24.04` / `20261012.334.1` (runner `20261012.601`) 이다. `gh run watch 38936761858 --exit-status` 는 rc 0 으로 끝났다 (17:08:05Z). 로그:

```text
2026-10-16T17:04:49.7799262Z 버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)
2026-10-16T17:07:57.8916763Z [3/10] 배포 파일의 구성 ................ 통과
2026-10-16T17:07:57.8922914Z 점검 통과 (10개 중 10개)
```

`workflow_dispatch` 는 만들지 않았다 (06-06 에서 확인함).

## `<automated>` 결과

계획 파일에서 줄 머리 `<automated>` 블록 하나(Task 2, 3036바이트)를 python `-I` 로 그대로 뽑았다. HTML 엔티티는 0이었고 `bash -n` 도 통과했다. 저장소 루트에서 `bash` 로 돌렸다.

| 블록 | 돌린 시점 | 적힌 그대로 | 고친 판 |
|---|---|---|---|
| Task 2 | 병합 · `main` push 실행 완료 뒤, metadata 커밋 전, 17:08:23Z ~ 17:08:35Z | 0 | 해당 없음 |

## Task Commits

1. **Task 1: 소유자 확인** — 커밋 없음 (응답 `merge`, dispatch 전)
2. **Task 2: 병합 · 확인 · `main` 실행** — 커밋 없음 (원격: merge commit `3418989`, run 38936761858)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP · REQUIREMENTS 의 커밋 (docs). push 하지 않는다. 로컬에만 있는 기록 커밋(`4ee0c55` 와 이 커밋)을 올릴지는 phase 끝에 orchestrator 가 소유자에게 묻는다.

## Files Created/Modified

- 없음 (저장소 추적 파일). 이 plan 의 기록 커밋은 `.planning/` 만 바꾼다.

## Decisions Made

- 소유자 응답 `merge` 뒤에만 `gh pr merge 3 --merge` 를 실행했다. 이제 `main` = 2.0.0 + 06 gap 수정 2회차 (merge commit `3418989`) 이다. 받는 쪽 규칙 · 버전 · tag 는 바뀌지 않았다. `main` 은 되감지 않는다.

## Deviations from Plan

None - plan executed exactly as written. (`--body` 의 글자는 임시 폴더의 파일에 먼저 써서 비공개 글자를 훑은 뒤 `--body "$(cat …)"` 로 넘겼다 — 플래그와 결과는 계획과 같다.)

## Issues Encountered

- `gh pr merge` 는 tty 가 아닌 셸에서 아무것도 찍지 않는다. 병합 결과는 `gh pr view` 의 `MERGED` · `mergeCommit` 과 `git log -1 --format=%P origin/main` 으로 남겼다.
- `main` push 실행의 annotation 하나: "The ubuntu-latest label will migrate to Ubuntu 26 beginning October 19, 2026" (actions/runner-images#14748). 이번 실행은 `ubuntu-24.04` 이미지에서 돌았다. 결과에는 영향이 없고, 이 plan 의 범위 밖이라 고치지 않았다 — 10-19 뒤 CI 가 실패하면 프로젝트 skill 의 Ubuntu 26.04 runner 항목을 먼저 본다.

## User Setup Required

None — 네트워크(GitHub)만 필요하다.

## Next Phase Readiness

- 06 gap 수정 2회차(06-12 ~ 06-15)가 끝났다. 다음은 `/gsd-verify-work 06` 의 재검증이다 (두 사람 확인 항목 — `Run workflow` 버튼 · 판정 등급 prohibition — 도 거기서).
- `origin/main` = `3418989` (merge commit), 원격 작업 브랜치 = `0461741` 다. 로컬 작업 브랜치는 기록 커밋 둘(`4ee0c55` 와 이 plan 의 metadata 커밋)이 앞서고, 둘 다 push 하지 않았다. 로컬 `main` 은 옛 값 그대로다.
- PR #3 는 `MERGED` 이고, 작업 브랜치는 원격에 남아 있다 (Keep branches).
- REL-02 · REL-03 · REL-04 는 이 plan 이 선언한 마지막 plan 이므로 metadata 단계에서 `requirements.mark-complete` 로 표시한다.

---
*Phase: 06-release*
*Completed: 2026-10-16*

## Self-Check: PASSED

- FOUND: PR #3 `MERGED`, mergeCommit `3418989…` == `origin/main`
- FOUND: `origin/main` 부모 둘 (`0038572…` · `0461741…`), `merge-base --is-ancestor` 다섯 (`85e1b0d` · `9d96778` · `ea2d664` · `origin/gsd/v2.0-package-rework` · `v2.0.0`) 모두 0
- FOUND: `main` 의 `pubspec.yaml` 3행 `version: 2.0.0` · 24행 `  markdown: ^7.3.1`, CHANGELOG 1행 `## 2.0.0 - 2026-10-15`, 고침 글자 셋
- FOUND: run 38936761858 `completed` · `success`, 로그 두 줄
- FOUND: `ls-remote --heads` 둘, `--tags` 4줄 (`v2.0.0^{}` = `704bf56…`)
- `<automated>` rc 0 (적힌 그대로)
- commits: 0 (`git rev-list --count 4ee0c55..HEAD` = 0 — SUMMARY 작성 시점, metadata 커밋 전; 저장소 파일 변경 없는 plan)
