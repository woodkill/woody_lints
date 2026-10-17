---
phase: 06-release
plan: 11
subsystem: release
tags: [release, github, pull-request, merge-commit, github-actions, gap-closure]

requires:
  - phase: 06-release
    provides: "06-10 의 PR #2 (main ← gsd/v2.0-package-rework, head 75f102f, MERGEABLE / CLEAN), push 실행 38887002394 · pull_request 실행 38887576984 success; 06-08 · 06-09 의 고침 커밋 6aa78fe · 2c5b73b · 4286d48"
provides:
  - "PR #2 merged — https://github.com/woodkill/woody_lints/pull/2"
  - "origin/main = merge commit 00385725e043bce0d3523a59ff8543603e5d1bd8 (부모 5ee5a12 · 75f102f), 고침 커밋 셋 · 작업 브랜치 · v2.0.0 이 main 의 조상"
  - "main push 실행 38888830252 success, 평소 모드, 10/10"
affects: [06 재검증 (/gsd-verify-work 06), 다음 릴리스 (main 에서 시작), /gsd-complete-milestone (Keep branches)]

actuals:
  tokens: 0
  tasks: 2
  commits: 0
plan_head_before: fd7bcce6b58ae80a03dd8c18e861acbb2cca4ed6
plan_head_after: fd7bcce6b58ae80a03dd8c18e861acbb2cca4ed6

tech-stack:
  added: []
  patterns:
    - "gap 수정의 main 병합도 gh pr merge --merge 만 — 병합 뒤 부모 둘(첫 부모 = 앞 병합 커밋) · 제목 머리로 찾은 고침 커밋이 merge-base --is-ancestor 로 main 의 조상인지 본다"

key-files:
  created: []
  modified: []

key-decisions:
  - "소유자 응답 merge (2026-10-16T10:38:32Z, orchestrator 가 dispatch 전에 물음) 뒤에만 gh pr merge 2 --merge — main = 2.0.0 + 06 gap 수정 (merge commit 0038572), 받는 쪽 변화 없음 (규칙 · version 2.0.0 · CHANGELOG · tag 그대로)"

patterns-established: []

requirements-completed: [REL-03, REL-04]

coverage:
  - id: D1
    description: "소유자 확인 (merge) 뒤 merge commit 으로 PR #2 병합 — 부모 둘(첫 부모 5ee5a12, 둘째 75f102f), 고침 커밋 셋 · 작업 브랜치 · v2.0.0 이 origin/main 의 조상, main 의 pubspec 2.0.0 + markdown · CHANGELOG 1행 그대로, PR MERGED · mergeCommit == origin/main, head 둘 · tag 4줄 그대로"
    requirement: "REL-04"
    verification:
      - kind: integration
        ref: "06-11-PLAN.md Task 2 <automated> (적힌 그대로) rc 0 — main push 실행 뒤, metadata 커밋 전"
        status: pass
    human_judgment: false
  - id: D2
    description: "main push 실행 38888830252 completed · success, 로그에 버전 일치 검사: 평소 · 점검 통과 (10개 중 10개) — 고친 [3/10] (h) · (i) 가 main 에서 거짓 실패를 내지 않는다"
    requirement: "REL-03"
    verification:
      - kind: e2e
        ref: "06-11-PLAN.md Task 2 <automated> (적힌 그대로) rc 0 — gh run view 38888830252 의 conclusion · --log 두 줄"
        status: pass
    human_judgment: false

duration: 약 6분
completed: 2026-10-16
status: complete
---

# Phase 6 Plan 11: 06 gap 수정 main 병합 Summary

**소유자의 `merge` 응답 뒤 `gh pr merge 2 --merge` 로 merge commit `0038572` 를 만들었다. 부모는 `5ee5a12` (06-06 의 merge commit) · `75f102f` (PR head) 둘이다. 06-08 · 06-09 의 고침 커밋 셋(`6aa78fe` · `2c5b73b` · `4286d48`), 작업 브랜치, `v2.0.0` 이 모두 `main` 의 조상이 되었다. `main` 의 push 실행 `38888830252` 도 평소 모드로 10/10 통과했다. tag · 버전 · CHANGELOG 는 그대로이고, 받는 쪽 규칙도 바뀌지 않았다.**

## Performance

- **Duration:** 약 6분 (10:40:16Z ~ 10:46Z)
- **Started:** 2026-10-16T10:40:16Z
- **Completed:** 2026-10-16T10:45:49Z (Task 2 `<automated>` 끝)
- **Tasks:** 2 (checkpoint:decision — dispatch 전에 응답됨 · auto)
- **Files modified:** 0 (저장소 추적 파일 기준. 이 plan 이 남긴 것은 원격 `main` · PR 상태 · Actions 실행뿐이다)

시각 순서 (소유자 확인이 병합보다 앞섰다는 기록):

| 시각 (UTC) | 한국 시각 | 일 |
|------------|-----------|----|
| 10:38Z | 19:38 | orchestrator 재확인 — `origin/main` = `5ee5a12`, PR #2 `OPEN` · head `75f102f` · `MERGEABLE` · `CLEAN` |
| 10:38:32Z | 19:38:32 | 소유자 응답 `merge` (Task 1, orchestrator 가 dispatch 전에 물음) |
| 10:40:16Z ~ 10:40:19Z | 19:40:16 ~ 19:40:19 | 실행자의 Task 1 precondition 재확인 — 그대로 |
| 10:40:49Z ~ 10:40:52Z | 19:40:49 ~ 19:40:52 | 병합 직전 재확인 (Task 2 의 1) — `origin/main` = `5ee5a12`, PR `OPEN MERGEABLE CLEAN 75f102f…` |
| 10:40:52Z ~ 10:40:56Z | 19:40:52 ~ 19:40:56 | `gh pr merge 2 --merge …` rc 0 (GitHub `mergedAt` 10:40:54Z) |
| 10:40:57Z | 19:40:57 | `main` push 실행 38888830252 생성 |
| 10:41:00Z ~ 10:45:19Z | 19:41:00 ~ 19:45:19 | `main` push 실행의 job `verify` (4분 19초) |
| 10:41:07Z | 19:41:07 | 병합 확인 (부모 둘 · `merge-base` 다섯 · `ls-remote`) |
| 10:45:37Z ~ 10:45:49Z | 19:45:37 ~ 19:45:49 | Task 2 `<automated>` rc 0 |

## Task 1 — 소유자 확인 (dispatch 전에 끝남)

**확인 요청 (orchestrator 가 dispatch 전에 소유자에게 보였다):** 계획 Task 1 `<action>` 의 여섯 가지를 쉬운 말로 보였다.

- 합칠 것: PR #2 (https://github.com/woodkill/woody_lints/pull/2), 작업 브랜치 커밋 18개 (`origin/main..origin/gsd/v2.0-package-rework`).
- 받는 쪽에 바뀌는 것: 없다. `lib/` · `version: 2.0.0` · CHANGELOG 는 그대로이고, `pubspec.yaml` 에서는 dev 의존성 `markdown` 줄과 그 주석만 바뀐다. 그래서 새 tag · 버전도 없다 (VERSIONING.md 기준표 "저장소 안쪽만 바뀜 → 올리지 않음").
- 명령: `gh pr merge 2 --merge`. squash · rebase 는 쓰지 않는다 (D-02 — 커밋 번호를 새로 만든다). 브랜치는 지우지 않는다.
- 되돌릴 수 없다는 점: `main` 을 되감지 않는다.
- 점검 결과: 브랜치 push 실행 `38887002394` success, PR 실행 `38887576984` success, `MERGEABLE` / `CLEAN`, `main` 보호 없음. 06-08 에서 M98 ~ M106 으로 실패 방향을 확인했고, 06-09 에서 smoke 가 `v2.0.0` 을 다시 통과했다.
- 합친 뒤 할 일: Task 2 (부모 둘 · 조상 · `main` 실행).

질문: "PR #2 를 지금 merge commit 방식으로 main 에 합칠까요?" — 선택지는 `합친다 (merge)` (권고) / `합치지 않는다 (hold)`.

**소유자 응답:**

- **`merge` (합친다)**, 2026-10-16T10:38:32Z (19:38:32 KST). 방식은 AskUserQuestion 이고, orchestrator 가 dispatch 전에 물었다.
- 사유: 소유자가 따로 쓰지 않았다. 권고 이유 승인 — 다음 릴리스의 gate 고침 · smoke 고침이 `main` 에 들어가고 06 gap 수정이 끝난다.

**precondition 재확인 (실행자, 10:40:16Z ~ 10:40:19Z, 읽기만):** `git fetch origin --quiet` 뒤 `origin/main` = `5ee5a1289dd5ebd26219f66ea494849b8a1a0436` 이었다. `gh pr list --state open --base main --head gsd/v2.0-package-rework` 는 1건이었다. PR #2 는 `OPEN` · `MERGEABLE` · `CLEAN` 이고 headRefOid `75f102f1aaa060c88e8962dff445078767bf20ff` 가 `origin/gsd/v2.0-package-rework` 와 같았다. 06-10-SUMMARY 에는 두 실행의 success 가 있었다. orchestrator 가 10:38Z 에 본 값과 모두 같았다.

## Task 2 — 병합 · 확인 · `main` 실행

**직전 재확인 (10:40:49Z ~ 10:40:52Z):** `origin/main` = `5ee5a12…`. PR #2 는 `OPEN MERGEABLE CLEAN 75f102f1aaa060c88e8962dff445078767bf20ff` 였다. 두 조건이 참일 때만 병합하도록 한 셸 안에 묶었다.

**병합 (10:40:52Z ~ 10:40:56Z, rc 0):**

```text
gh pr merge 2 --merge --subject "fix: main 에 06 gap 수정 병합 — [3/10] 버전 reader 해석기 값 · smoke 판정 · 시간 제한 (PR #2)" --body "<아래 본문>"
```

출력은 0바이트다 (tty 가 아닌 셸에서 `gh pr merge` 는 아무것도 찍지 않는다. 06-06 과 같다). GitHub 의 `mergedAt` 은 `2026-10-16T10:40:54Z`, `mergedBy` 는 `woodkill` 이다. `--squash` · `--rebase` · `--delete-branch` · `--admin` · `--auto` 는 쓰지 않았다. merge commit 본문 (GitHub 에 그대로 들어갔다):

```text
작업 브랜치 gsd/v2.0-package-rework 의 06 gap 수정(06-08 · 06-09)과 처리 기록을 main 에 합친다.

- tool/verify.dart 의 [3/10] 버전 일치 검사가 pubspec.yaml 의 version 을 package:yaml 이 읽은 값에서, CHANGELOG.md 최상단 버전을 package:markdown 해석의 첫 h2 에서 읽는다 (CR-01 · WR-02 · IN-03)
- tool/smoke.dart 의 판정이 include 사슬 진단을 실패로 보고, 단계마다 시간 제한과 임시 폴더 정리를 둔다 (WR-01 · WR-03 · IN-01 · IN-02)
- 받는 쪽에 바뀌는 것 없음 — lib/ 의 규칙 · version 2.0.0 · CHANGELOG 그대로, 저장소 안쪽(검증 스크립트 · smoke · 개발용 의존성 markdown · 기록)만 바뀜. 새 tag · 버전 없음
- merge commit 으로 합침 (squash · rebase 아님, D-02) — 작업 브랜치는 지우지 않는다
- 소유자 결정 G6-Q3 (병합 직전 확인 — merge)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01FMQRSJydizwp5HqzzNuetV
```

본문은 병합 전에 훑었다. 절대 경로 · 홈 · 임시 폴더 꼴, 계정 이메일, 비공개 사용 프로젝트 이름은 0이었다.

**확인 (10:41:07Z, `git fetch origin --quiet` 뒤):**

```text
origin/main = 00385725e043bce0d3523a59ff8543603e5d1bd8
$ git log -1 --format=%P origin/main
5ee5a1289dd5ebd26219f66ea494849b8a1a0436 75f102f1aaa060c88e8962dff445078767bf20ff
subject = fix: main 에 06 gap 수정 병합 — [3/10] 버전 reader 해석기 값 · smoke 판정 · 시간 제한 (PR #2)   (committer GitHub)
merge-base --is-ancestor 6aa78fe1422b0450bb01f5db3cee2f34b0b454bf origin/main -> 0 (fix(tool): [3/10] 의 version · CHANGELOG 최상단 reader 를 해석기 값으로)
merge-base --is-ancestor 2c5b73b43a0eb7fbe712373051dd276627391adc origin/main -> 0 (fix(tool): smoke 판정 — include 사슬 진단을 실패로, judge 가 사유와 표시 문구를)
merge-base --is-ancestor 4286d48b980e581c10ab8164debcbe072234e27a origin/main -> 0 (fix(tool): smoke 단계마다 시간 제한(69)과 임시 폴더 정리(finally · SIGINT, )
merge-base --is-ancestor 75f102f1aaa060c88e8962dff445078767bf20ff origin/main -> 0 (docs(review): 06 처리 기록 — CR-01 · WR-01 ~ WR-03 · IN-01 ~ IN-)
merge-base --is-ancestor v2.0.0 origin/main -> 0 (chore(release): 2.0.0 — version · CHANGELOG 날짜 · lock 여섯 · p)
$ git show origin/main:pubspec.yaml | grep -n ...
3:version: 2.0.0
24:  markdown: ^7.3.1
$ git show origin/main:CHANGELOG.md | head -1
## 2.0.0 - 2026-10-15
$ gh pr view 2 --json state,mergedAt,mergedBy,mergeCommit
MERGED, mergedAt 2026-10-16T10:40:54Z, mergedBy woodkill, mergeCommit 00385725e043bce0d3523a59ff8543603e5d1bd8
$ git ls-remote --heads origin
75f102f1aaa060c88e8962dff445078767bf20ff	refs/heads/gsd/v2.0-package-rework
00385725e043bce0d3523a59ff8543603e5d1bd8	refs/heads/main
$ git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
753f52057079702a9bf64226e1dc4a5bb858e0ee	refs/tags/v2.0.0
704bf56fb028debe16f107bc9a8e6c9bdc5bccc2	refs/tags/v2.0.0^{}
v2.0.0^{commit} = 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2
```

(괄호 안 제목은 확인용으로 60자에서 잘랐다.) 부모는 둘이다. 첫 부모는 06-06 의 merge commit `5ee5a12`, 둘째 부모는 병합 전 작업 브랜치 머리 `75f102f` 다. 고침 커밋 셋은 범위 `01419f9..origin/gsd/v2.0-package-rework` 에서 제목 머리로 찾았다 (`-- tool/verify.dart` 에서 하나, `-- tool/smoke.dart` 에서 둘). 셋 다 06-10 의 처리 기록에 적힌 sha 와 같다. 작업 브랜치는 원격에 남아 있다 (Keep branches). tag 4줄도 그대로다. 로컬 `main` 브랜치는 건드리지 않았다.

`pubspec.yaml` 의 두 줄은 이 셸(zsh)의 `grep` wrapper 에서 `-e` 두 개로 한 번에 보았더니 3행만 나왔다. 그래서 `markdown` 줄은 `grep -n markdown` (24행) 과 `bash -c` 안의 `/usr/bin/grep -qx '  markdown: ^7.3.1'` (rc 0) 으로 다시 확인했다. `<automated>` 는 `bash` 로 돌리므로 `/usr/bin/grep` 을 쓰고, 그 단언도 통과했다.

**`main` 의 push 실행:** run **38888830252** (event push, headBranch `main`, headSha `0038572`), `completed` · **`success`**. job `verify` 는 10:41:00Z ~ 10:45:19Z (4분 19초) 이다. 이미지는 `ubuntu-24.04` / `20261012.334.1` (runner provisioner `20261012.601`) 이다. `gh run watch 38888830252 --exit-status` 는 백그라운드에서 rc 0 으로 끝났다 (10:45:23Z). 로그:

```text
2026-10-16T10:42:05.3067061Z 버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)
2026-10-16T10:45:17.4758298Z [3/10] 배포 파일의 구성 ................ 통과
2026-10-16T10:45:17.4765120Z 점검 통과 (10개 중 10개)
```

`workflow_dispatch` 는 만들지 않았다 (06-06 에서 확인함).

## `<automated>` 결과

계획 파일에서 줄 머리 `<automated>` 블록 하나(Task 2, 2939바이트)를 python `-I` 로 그대로 뽑았다. HTML 엔티티는 0이었다. 저장소 루트에서 `bash` 로 돌렸다.

| 블록 | 돌린 시점 | 적힌 그대로 | 고친 판 |
|---|---|---|---|
| Task 2 | 병합 · `main` push 실행 뒤, metadata 커밋 전, 10:45:37Z ~ 10:45:49Z | 0 | 해당 없음 |

## Task Commits

1. **Task 1: 소유자 확인** — 커밋 없음 (응답 `merge`, dispatch 전)
2. **Task 2: 병합 · 확인 · `main` 실행** — 커밋 없음 (원격: merge commit `0038572`, run 38888830252)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP · REQUIREMENTS 의 커밋 (docs). push 하지 않는다. 로컬에만 있는 기록 커밋(`fd7bcce` 와 이 커밋)을 올릴지는 phase 끝에 orchestrator 가 소유자에게 묻는다.

## Files Created/Modified

- 없음 (저장소 추적 파일). 이 plan 의 기록 커밋은 `.planning/` 만 바꾼다.

## Decisions Made

- 소유자 응답 `merge` 뒤에만 `gh pr merge 2 --merge` 를 실행했다. 이제 `main` = 2.0.0 + 06 gap 수정 (merge commit `0038572`) 이다. 받는 쪽 규칙 · 버전 · tag 는 바뀌지 않았다. `main` 은 되감지 않는다.

## Deviations from Plan

**1. [지시 해석] merge commit 메시지는 계획의 `--subject` · `--body` 를 썼다** — orchestrator 지시 5번에는 "merge commit 메시지는 `gh pr merge` 의 기본값 (06-06 과 같게 — 06-06-SUMMARY 확인)" 이라고 적혀 있었다. 그런데 06-06-SUMMARY 를 확인해 보니 06-06 은 `--subject` · `--body` 를 주었다. 이 plan 의 Task 2 의 1 과 constraints ("병합 커밋의 제목 · 본문은 Conventional Commits — 영어 prefix, 한국어 제목 · 본문, attribution trailer") 도 그 꼴을 요구한다. 지시 3번도 "명령은 계획 글자 그대로" 다. 그래서 계획 글자대로 `--merge --subject … --body …` 를 썼다. GitHub 기본 제목 `Merge pull request #2 from …` 은 Conventional Commits 가 아니다. 병합 방식(`--merge`, merge commit)은 같고, 다른 플래그는 쓰지 않았다.

**2. [시스템 규칙] merge commit 본문의 attribution 은 두 줄** — 06-06 은 `Co-Authored-By` 한 줄이었다. 이번에는 현재 attribution 지시(orchestrator 지시 5번)대로 `Co-Authored-By` · `Claude-Session` 두 줄을 붙였다.

---

**Total deviations:** 2 (지시 해석 1, 시스템 규칙 1). **Impact:** 병합 방식과 결과에는 영향이 없다. 범위 밖 작업도 없다.

## Issues Encountered

- `gh pr merge` 는 tty 가 아닌 셸에서 아무것도 찍지 않는다. 병합 결과는 `gh pr view` 의 `MERGED` · `mergeCommit` 과 `git log -1 --format=%P origin/main` 으로 남겼다.
- zsh 의 `grep` wrapper 에서 `-x` 와 `-e` 두 개를 함께 주니 `  markdown: ^7.3.1` 줄이 나오지 않았다. 원인은 패턴 가운데의 `^` 해석으로 보인다. `bash` 의 `/usr/bin/grep` 에서는 맞으므로 `<automated>` 결과에는 영향이 없다.

## User Setup Required

None — 네트워크(GitHub)만 필요하다.

## Next Phase Readiness

- 06 gap 수정(06-08 ~ 06-11)이 끝났다. 다음은 `/gsd-verify-work 06` 의 재검증이다.
- `origin/main` = `0038572` (merge commit), 원격 작업 브랜치 = `75f102f` 다. 로컬 작업 브랜치는 기록 커밋 둘(`fd7bcce` 와 이 plan 의 metadata 커밋)이 앞서고, 둘 다 push 하지 않았다. 로컬 `main` 은 옛 값 그대로다.
- PR #2 는 `MERGED` 이고, 작업 브랜치는 원격에 남아 있다 (Keep branches).
- REL-03 · REL-04 는 이 plan 이 선언한 마지막 plan 이므로 metadata 단계에서 `requirements.mark-complete` 로 표시한다.

---
*Phase: 06-release*
*Completed: 2026-10-16*

## Self-Check: PASSED

- FOUND: PR #2 `MERGED`, mergeCommit `0038572…` == `origin/main`
- FOUND: `origin/main` 부모 둘 (`5ee5a12…` · `75f102f…`), `merge-base --is-ancestor` 다섯 (`6aa78fe` · `2c5b73b` · `4286d48` · `origin/gsd/v2.0-package-rework` · `v2.0.0`) 모두 0
- FOUND: run 38888830252 `completed` · `success`, 로그 두 줄
- FOUND: `ls-remote --heads` 둘, `--tags` 4줄 (`v2.0.0^{}` = `704bf56…`)
- `<automated>` rc 0 (적힌 그대로)
- commits: 0 (`git rev-list --count fd7bcce..HEAD` = 0 — SUMMARY 작성 시점, metadata 커밋 전; 저장소 파일 변경 없는 plan)
