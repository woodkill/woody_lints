---
phase: 06-release
plan: 06
subsystem: release
tags: [release, github, pull-request, merge-commit, github-actions, workflow_dispatch]

requires:
  - phase: 06-release
    provides: "06-05 의 원격 annotated tag v2.0.0 → 704bf56, tag 실행 38844667011 success, tag smoke 통과; 06-04 · 06-05 의 .planning/ 기록 커밋 5076ed5 · ad09d6e"
provides:
  - "PR #1 (main ← gsd/v2.0-package-rework) merged — https://github.com/woodkill/woody_lints/pull/1"
  - "origin/main = merge commit 5ee5a1289dd5ebd26219f66ea494849b8a1a0436 (부모 90a2736 · ad09d6e), v2.0.0 이 main 의 조상"
  - "pull_request 실행 38845784725 · main push 실행 38850611790 · workflow_dispatch 실행 38850984674 — 셋 다 success, 평소 모드, 10/10"
affects: [06-07 처리 기록 (02-UAT 4 · 6번), phase 6 UAT (Run workflow 버튼), /gsd-complete-milestone (Keep branches)]

actuals:
  tokens: 0
  tasks: 3
  commits: 0
plan_head_before: ad09d6e0e973843a52232ab68496bcdf22082def
plan_head_after: ad09d6e0e973843a52232ab68496bcdf22082def

tech-stack:
  added: []
  patterns:
    - "main 병합은 gh pr merge --merge 만 — 병합 뒤 부모 둘 · merge-base --is-ancestor v2.0.0 origin/main 으로 tag 커밋이 이력에 남았는지 본다"
    - "main 의 push 실행과 workflow_dispatch 실행은 concurrency group 이 같다 (verify-refs/heads/main) — push 실행이 끝난 뒤에 dispatch 한다 (안 그러면 cancel-in-progress 가 push 실행을 취소한다)"

key-files:
  created: []
  modified: []

key-decisions:
  - "소유자 응답 merge (2026-10-16T04:25:06Z) 뒤에만 gh pr merge 1 --merge — main = 2.0.0 (merge commit 5ee5a12), ref: main 프로젝트는 pub upgrade 때 받는다"
  - "workflow_dispatch 는 main push 실행이 끝난 뒤에 돌렸다 — 같은 concurrency group 이라 먼저 돌리면 push 실행이 취소된다"

patterns-established:
  - "PR 본문은 --body-file 의 임시 파일로 주고 create 전에 경로 · 비공개 이름 · 이메일 꼴을 grep 한다"

requirements-completed: [REL-02]

coverage:
  - id: D1
    description: "push gate rc 0 뒤 작업 브랜치 push (704bf56..ad09d6e), 브랜치 실행 38845719589 success"
    requirement: "REL-02"
    verification:
      - kind: integration
        ref: "06-06-PLAN.md Task 1 첫째 <automated> (push gate, push 직전)"
        status: pass
    human_judgment: false
  - id: D2
    description: "PR #1 열림 · head == HEAD · MERGEABLE/CLEAN, pull_request 실행 38845784725 success · 로그에 평소 모드 · [3/10] 통과 · 10/10 (02-UAT 4번)"
    requirement: "REL-02"
    verification:
      - kind: integration
        ref: "06-06-PLAN.md Task 1 둘째 <automated> (병합 전)"
        status: pass
    human_judgment: false
  - id: D3
    description: "소유자 확인 (merge) 뒤 merge commit 으로 병합 — 부모 둘 · v2.0.0 과 작업 브랜치가 origin/main 의 조상 · head 둘 · tag 4줄, main push 실행 · workflow_dispatch 실행 success (02-UAT 6번의 자동화 부분)"
    requirement: "REL-02"
    verification:
      - kind: integration
        ref: "06-06-PLAN.md Task 3 <automated> (metadata 커밋 전)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Actions → verify 화면의 Run workflow 버튼이 보이는지 (02-UAT 6번의 화면 부분)"
    requirement: "REL-02"
    verification: []
    human_judgment: true
    rationale: "GitHub 웹 화면의 버튼은 사람이 눈으로 본다 — 계획의 <human-check>, phase 끝 UAT 로 모은다"

duration: 약 18분 (작업 시간 — 소유자 응답 대기 03:34Z ~ 04:25Z 제외)
completed: 2026-10-16
status: complete
---

# Phase 6 Plan 06: main 병합 · pull_request · workflow_dispatch Summary

**push gate 를 통과한 뒤 남은 기록 커밋 둘을 올리고 PR #1 (`main` ← `gsd/v2.0-package-rework`) 을 열었다. 그 PR 의 `pull_request` 실행이 평소 모드로 10/10 통과했다. 소유자의 `merge` 응답 뒤 `gh pr merge 1 --merge` 로 merge commit `5ee5a12` 를 만들었다. 부모는 `90a2736` · `ad09d6e` 둘이고, tag `v2.0.0` 을 단 커밋이 `main` 의 이력에 그대로 남았다. 이어서 `main` 의 push 실행과 `gh workflow run` 이 만든 `workflow_dispatch` 실행도 둘 다 10/10 으로 통과했다.**

## Performance

- **Duration:** 작업 약 18분. Task 1 약 7분 (03:28Z ~ 03:35Z), Task 3 약 11분 (04:25Z ~ 04:36Z). 소유자 응답을 기다린 시간(03:34Z ~ 04:25Z)은 뺐다.
- **Started:** 2026-10-16T03:28:03Z
- **Completed:** 2026-10-16T04:35:14Z (Task 3 `<automated>` 끝)
- **Tasks:** 3 (auto · checkpoint:decision · auto)
- **Files modified:** 0 (저장소 추적 파일 기준. 이 plan 이 남긴 것은 원격 ref · PR · Actions 실행뿐이다)

시각 순서 (소유자 확인이 병합보다 앞섰다는 기록):

| 시각 (UTC) | 한국 시각 | 일 |
|------------|-----------|----|
| 03:28:44Z ~ 03:28:46Z | 12:28:44 ~ 12:28:46 | push gate (Task 1 첫째 `<automated>`) rc 0 |
| 03:28:46Z ~ 03:28:49Z | 12:28:46 ~ 12:28:49 | `git push origin gsd/v2.0-package-rework` |
| 03:28:51Z | 12:28:51 | 브랜치 실행 38845719589 생성 |
| 03:29:34Z ~ 03:29:37Z | 12:29:34 ~ 12:29:37 | `gh pr create` → PR #1 |
| 03:29:39Z | 12:29:39 | `pull_request` 실행 38845784725 생성 |
| 03:29:41Z ~ 03:33:51Z | 12:29:41 ~ 12:33:51 | PR 실행의 job `verify` (4분 10초) |
| 03:34:24Z ~ 03:34:35Z | 12:34:24 ~ 12:34:35 | Task 1 둘째 `<automated>` rc 0 → checkpoint 로 돌아감 |
| 04:25:06Z | 13:25:06 | 소유자 응답 `merge` (Task 2) |
| 04:25:28Z | 13:25:28 | 병합 직전 재확인 — PR `OPEN` · `MERGEABLE` · `CLEAN`, `origin/main` = `90a2736` |
| 04:26:02Z ~ 04:26:06Z | 13:26:02 ~ 13:26:06 | `gh pr merge 1 --merge …` (GitHub `mergedAt` 04:26:05Z) |
| 04:26:13Z | 13:26:13 | 병합 확인 (부모 둘 · `merge-base` 둘 · `ls-remote`) |
| 04:26:15Z | 13:26:15 | `main` push 실행 38850611790 생성 |
| 04:26:17Z ~ 04:30:21Z | 13:26:17 ~ 13:30:21 | `main` push 실행의 job `verify` (4분 4초) |
| 04:30:33Z ~ 04:30:35Z | 13:30:33 ~ 13:30:35 | `gh workflow run verify.yml --ref main` |
| 04:30:35Z | 13:30:35 | `workflow_dispatch` 실행 38850984674 생성 |
| 04:30:38Z ~ 04:34:45Z | 13:30:38 ~ 13:34:45 | dispatch 실행의 job `verify` (4분 7초) |
| 04:35:02Z ~ 04:35:14Z | 13:35:02 ~ 13:35:14 | Task 3 `<automated>` rc 0 |

## Task 1 — push · PR · `pull_request` 실행

**precondition (03:28Z 경, 읽기만):** `git ls-remote --tags origin` 은 4줄이었고 `704bf56fb028debe16f107bc9a8e6c9bdc5bccc2\trefs/tags/v2.0.0^{}` 이 `git rev-parse 'v2.0.0^{commit}'` 과 같았다. 06-05-SUMMARY 에는 run `38844667011` success 와 `smoke 통과` 가 있었다. `gh pr list --state all --base main` 은 0건이었다. 셋 모두 참이다.

**push (D-21 — 실행한 뒤 보고):** 범위는 `origin/gsd/v2.0-package-rework..HEAD` = `5076ed5` · `ad09d6e` 이다 (06-04 · 06-05 의 `.planning/` 기록 커밋). push gate 범위 `v2.0.0^{commit}..HEAD` 와 같다.

- push gate (계획 Task 1 의 첫 `<automated>`, 글자 그대로): **rc 0**, 03:28:44Z ~ 03:28:46Z. push 보다 먼저 돌렸다.
- push 03:28:46Z ~ 03:28:49Z:

```text
$ git push origin gsd/v2.0-package-rework
To github.com:woodkill/woody_lints.git
   704bf56..ad09d6e  gsd/v2.0-package-rework -> gsd/v2.0-package-rework
```

  내 셸 줄은 push 의 종료 코드를 담지 못했다 (PIPESTATUS 가 비어 있었다). 그래서 push 가 됐는지는 바로 다음 `git ls-remote --heads origin` 의 `ad09d6e…\trefs/heads/gsd/v2.0-package-rework` 와 `origin/gsd/v2.0-package-rework == HEAD` 로 확인했다.
- 브랜치 실행 **38845719589** (event push, headSha `ad09d6e`): `completed` · `success`, job 03:28:53Z ~ 03:33:18Z. 로그에는 `버전 일치 검사: 평소 (…)` (03:29:57Z), `[3/10] 배포 파일의 구성 ................ 통과`, `점검 통과 (10개 중 10개)` (03:33:15Z) 가 있다.

**PR:**

- 명령: `gh pr create --base main --head gsd/v2.0-package-rework --title "release: 2.0.0 — v2.0 Package Rework 를 main 에 병합" --body-file <임시 파일>` → `https://github.com/woodkill/woody_lints/pull/1`
- 번호 **#1**, URL https://github.com/woodkill/woody_lints/pull/1, 제목 `release: 2.0.0 — v2.0 Package Rework 를 main 에 병합`
- `gh pr view 1`: head `gsd/v2.0-package-rework`, base `main`, headRefOid `ad09d6e0e973843a52232ab68496bcdf22082def` (== HEAD), `OPEN`, `MERGEABLE`. `mergeStateStatus` 는 실행 중에 `UNSTABLE` 이었고 끝난 뒤 `CLEAN` 이 되었다.
- `main` 에 들어간 커밋 수는 `git rev-list --count origin/main..HEAD` = **392** 다.
- 본문 점검 (create 전에 본문 파일을 훑었다): (1) 절대 경로 · 홈 · 임시 폴더 꼴 0, (2) 저장소에 없는 `(lib|test|bin|assets)/…` 꼴 경로 0 (그 꼴의 경로 자체가 없다), (3) 영어 리뷰 문구 꼴 0, 비공개 사용 프로젝트 이름 0, 이메일 꼴 0.

PR 본문 전문:

```markdown
## 요약

작업 브랜치 `gsd/v2.0-package-rework` 의 v2.0 Package Rework 를 `main` 에 합친다. 패키지 버전은 `2.0.0` 이다 (`pubspec.yaml`, `CHANGELOG.md` 1행 `## 2.0.0 - 2026-10-15`).

## 무엇이 바뀌나

- **SDK 하한 `^3.13.0` (major)** — Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.
- **프리셋 분리** — `package:woody_lints/base.yaml` (기본 규칙), `riverpod.yaml` (`riverpod_lint` plugin), `codegen.yaml` (생성 파일 제외와 `invalid_annotation_target: ignore`), `recommended.yaml` (셋을 한 번에). 옛 주소 `package:woody_lints/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 별칭으로 남아 뜻(기본 + Riverpod + codegen)이 같다.
- **규칙 재선정** — CHANGELOG 2.0.0 「추가한 규칙」 의 75개를 새로 켰다. 1.3.0 부터 켜 둔 6개는 모두 남겼다. 기반 세트와 겹치던 선언 6개와 주석 처리된 설정 3개는 배포 파일에서 지웠다 (기반 세트가 여전히 켜므로 받는 쪽 영향 없음). `riverpod_lint` 하한은 `^3.1.9`.
- **검증 명령과 CI** — `tool/verify.dart` (단계 10개, 연습용 프로젝트 여섯의 정답지 비교, 배포 파일 구성 · README · 버전 일치 검사) 와 GitHub Actions workflow `verify` (push · pull_request · workflow_dispatch). 릴리스 smoke test `tool/smoke.dart`.
- **문서** — README 다시 씀, 규칙 근거 문서 `RULES.md`, 버전 정책과 릴리스 절차 `VERSIONING.md`, CHANGELOG 2.0.0 (1.1.0 ~ 1.2.5 항목 복원 포함).

## 이미 끝난 확인

- tag `v2.0.0` (annotated) → 릴리스 커밋 `704bf56` 이 origin 에 올라가 있다 (`git ls-remote --tags origin` 의 `refs/tags/v2.0.0^{}` 줄).
- tag push 의 `verify` 실행 [38844667011](https://github.com/woodkill/woody_lints/actions/runs/38844667011) success — 로그에 `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` · `점검 통과 (10개 중 10개)`.
- `tool/smoke.dart v2.0.0` 통과 — 빈 Flutter 프로젝트가 `ref: v2.0.0` 으로 받아(`resolved-ref` = `704bf56`) 두 주소(`recommended.yaml` · 옛 주소) 각각에서 규칙 진단 `prefer_single_quotes` 와 plugin 진단 `provider_parameters` 를 냈다.

## 합치는 방식

**merge commit 으로만 합친다** (`gh pr merge --merge`). squash · rebase 는 커밋 번호를 새로 만들어 tag `v2.0.0` 을 단 커밋이 `main` 의 이력에서 빠지므로 쓰지 않는다. 작업 브랜치는 지우지 않는다.

## 받는 쪽 영향

- `ref: main` 을 따르는 프로젝트는 이 PR 이 합쳐진 뒤 **`flutter pub upgrade woody_lints` 를 하는 순간** 2.0.0 을 받는다. `flutter pub get` 만으로는 `pubspec.lock` 에 적힌 1.3.0 커밋에 머문다.
- 올리기 전에 볼 것은 CHANGELOG 2.0.0 의 「올리기 전에」 와 README 의 「버전 올리기」 절에 있다.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**`pull_request` 실행 (D-03 (4), 02-UAT 4번):** run **38845784725**, event `pull_request`, headSha `ad09d6e`, `completed` · **`success`**. job `verify` 는 03:29:41Z ~ 03:33:51Z (4분 10초) 이고, 이미지는 `ubuntu-24.04` / `20261012.334.1` (runner `20261012.601`) 이다. 로그 세 줄:

```text
2026-10-16T03:30:42.0537445Z 버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)
2026-10-16T03:33:49.5617206Z [3/10] 배포 파일의 구성 ................ 통과
2026-10-16T03:33:49.5628587Z 점검 통과 (10개 중 10개)
```

PR 실행은 평소 모드로 돌았다. A5 (`pull_request` 의 `GITHUB_REF_TYPE` 은 `branch`) 가 맞았으므로 `ciTag` 를 고칠 둘째 push 는 필요 없었다.

## Task 2 — 소유자 확인

**확인 요청:** orchestrator 가 계획 Task 2 의 다섯 가지를 쉬운 말로 보였다 — 합칠 것 (PR #1, 커밋 392개, 지금 `main` = `90a2736`), 명령과 squash · rebase 를 쓰지 않는 이유, 되돌릴 수 없는 점, 점검 결과, 합친 뒤에 할 일. 내용은 Task 1 의 값으로 채웠다.

**소유자 응답:**

- 소유자는 권고안 "합친다" 를 골랐다 → **`merge`**. 시각 2026-10-16T04:25:06Z (13:25:06 KST).
- 사유: 권고 이유 승인 — tag 로 받아 보는 확인과 PR 검사가 모두 통과한 상태

## Task 3 — 병합 · 확인 · `main` 실행 · 수동 실행

**직전 재확인 (04:25:28Z):** PR #1 은 `OPEN` · `MERGEABLE` · `CLEAN` 이었고, headRefOid `ad09d6e` == HEAD, `origin/main` = `90a2736b8d998c84467faf562a0fec720b797eaf` 였다.

**병합 (04:26:02Z ~ 04:26:06Z, rc 0):**

```text
gh pr merge 1 --merge --subject "chore(release): main 에 2.0.0 병합 — v2.0 Package Rework (PR #1)" --body "<아래 본문>"
```

`gh pr merge` 는 tty 가 아닌 셸에서 stdout · stderr 를 아무것도 찍지 않았다 (출력 0바이트, rc 0). GitHub 의 `mergedAt` 은 `2026-10-16T04:26:05Z`, `mergedBy` 는 `woodkill` 이다. `--squash` · `--rebase` · `--delete-branch` · `--admin` · `--auto` 는 쓰지 않았다. merge commit 본문 (GitHub 에 그대로 들어갔다):

```text
작업 브랜치 gsd/v2.0-package-rework 의 v2.0 Package Rework 를 main 에 합친다.

- tag v2.0.0 → 704bf56 (릴리스 커밋) 이 이 merge commit 의 이력에 그대로 남는다
- merge commit 으로 합침 (squash · rebase 아님, D-02) — 작업 브랜치는 지우지 않는다
- ref: main 을 따르는 프로젝트는 다음 flutter pub upgrade woody_lints 때 2.0.0 을 받는다 (pub get 만으로는 lock 의 커밋에 머문다)

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

**확인 (04:26:13Z, `git fetch origin --quiet` 뒤):**

```text
origin/main = 5ee5a1289dd5ebd26219f66ea494849b8a1a0436
$ git log -1 --format=%P origin/main
90a2736b8d998c84467faf562a0fec720b797eaf ad09d6e0e973843a52232ab68496bcdf22082def
subject = chore(release): main 에 2.0.0 병합 — v2.0 Package Rework (PR #1)   (committer GitHub)
$ git merge-base --is-ancestor v2.0.0 origin/main                          → 0 (참)
$ git merge-base --is-ancestor origin/gsd/v2.0-package-rework origin/main  → 0 (참)
$ git show origin/main:pubspec.yaml | grep -nx 'version: 2.0.0'
3:version: 2.0.0
$ git show origin/main:CHANGELOG.md | head -1
## 2.0.0 - 2026-10-15
$ gh pr view 1 --json state,mergedAt,mergeCommit
MERGED, mergedAt 2026-10-16T04:26:05Z, mergeCommit 5ee5a1289dd5ebd26219f66ea494849b8a1a0436
$ git ls-remote --heads origin
ad09d6e0e973843a52232ab68496bcdf22082def	refs/heads/gsd/v2.0-package-rework
5ee5a1289dd5ebd26219f66ea494849b8a1a0436	refs/heads/main
$ git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
753f52057079702a9bf64226e1dc4a5bb858e0ee	refs/tags/v2.0.0
704bf56fb028debe16f107bc9a8e6c9bdc5bccc2	refs/tags/v2.0.0^{}
```

부모는 둘이다. 첫 부모가 옛 `main` `90a2736`, 둘째 부모가 PR head `ad09d6e` 이다. tag 를 단 커밋 `704bf56` 은 `main` 의 이력에 그대로 있다 (D-02). 작업 브랜치는 지우지 않았고 (Keep branches), tag 4줄도 그대로다. 로컬 `main` 브랜치는 건드리지 않았다.

**`main` 의 push 실행:** run **38850611790** (event push, headBranch `main`, headSha `5ee5a12`), `completed` · **`success`**. job 은 04:26:17Z ~ 04:30:21Z (4분 4초) 이고, 이미지는 `ubuntu-24.04` / `20261012.334.1` 이다. 로그:

```text
2026-10-16T04:27:18.3105238Z 버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)
2026-10-16T04:30:19.6101328Z [3/10] 배포 파일의 구성 ................ 통과
2026-10-16T04:30:19.6110090Z 점검 통과 (10개 중 10개)
```

**수동 실행 (D-03 (6), 02-UAT 6번의 자동화 부분):** push 실행이 끝난 뒤 (04:30:23Z) `gh workflow run verify.yml --ref main` 을 한 번 돌렸다 (04:30:33Z, rc 0, 출력 `https://github.com/woodkill/woody_lints/actions/runs/38850984674`). run **38850984674** (event `workflow_dispatch`, headBranch `main`, headSha `5ee5a12`), `completed` · **`success`**. job 은 04:30:38Z ~ 04:34:45Z (4분 7초) 이고, 이미지는 `ubuntu-24.04` / `20261012.334.1` 이다. 로그:

```text
2026-10-16T04:31:38.6235212Z 버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)
2026-10-16T04:34:44.2677096Z [3/10] 배포 파일의 구성 ................ 통과
2026-10-16T04:34:44.2681677Z 점검 통과 (10개 중 10개)
```

`Run workflow` 버튼이 화면에 보이는지는 계획의 `<human-check>` 다 — phase 끝 UAT 에서 소유자가 Actions → `verify` 화면에서 본다.

**runner 이미지:** 실행 넷(브랜치 · PR · `main` push · dispatch) 모두 `ubuntu-24.04` / `20261012.334.1` (runner `20261012.601`) 이었다. Ubuntu 26 으로 옮겨 가는 날(2026-10-19) 전이다.

## `<automated>` 결과

계획 파일에서 줄 머리 `<verify>` … `</verify>` 구간 안의 줄 머리 `<automated>` 블록만 python `-I` 로 그대로 뽑았다 (Task 1 첫째 1630바이트, 둘째 1577바이트, Task 3 2191바이트). 저장소 루트에서 `bash` 로 돌렸고, 고친 판은 만들지 않았다.

| 블록 | 돌린 시점 | rc |
|---|---|---|
| Task 1 첫째 (push gate) | push 직전, 03:28:44Z ~ 03:28:46Z | 0 |
| Task 1 둘째 | 브랜치 · PR 실행이 끝난 뒤, 병합 전 (`main` = `90a2736`, PR `OPEN`), 03:34:24Z ~ 03:34:35Z | 0 |
| Task 3 | 병합 · `main` push 실행 · dispatch 실행 뒤, metadata 커밋 전, 04:35:02Z ~ 04:35:14Z | 0 |

## Task Commits

1. **Task 1: push · PR · `pull_request` 실행** — 커밋 없음 (원격: 작업 브랜치 `704bf56..ad09d6e`, PR #1, run 38845719589 · 38845784725)
2. **Task 2: 소유자 확인** — 커밋 없음 (응답 `merge`)
3. **Task 3: 병합 · 확인 · 실행** — 커밋 없음 (원격: merge commit `5ee5a12`, run 38850611790 · 38850984674)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 의 커밋 (docs). push 하지 않는다.

## Files Created/Modified

- 없음 (저장소 추적 파일). 이 plan 의 기록 커밋은 `.planning/` 만 바꾼다.

## Decisions Made

- 소유자 응답 `merge` 뒤에만 `gh pr merge 1 --merge` 를 실행했다. `main` = 2.0.0 (merge commit `5ee5a12`) 이고, `ref: main` 프로젝트는 `pub upgrade` 때 받는다. `main` 은 되감지 않는다.
- `workflow_dispatch` 는 `main` push 실행이 끝난 뒤에 돌렸다 (아래 Deviations 2).

## Deviations from Plan

**1. [시스템 규칙] PR 본문의 attribution 은 한 줄** — 계획 constraints 와 Task 1 의 2 는 PR 본문 끝에 "attribution 두 줄(🤖 줄과 세션 링크)" 을 적었다. 지금 시스템이 정한 PR 본문의 끝은 `🤖 Generated with [Claude Code](https://claude.com/claude-code)` 한 줄뿐이라 세션 링크 줄은 넣지 않았다 (orchestrator 지시 5번). merge commit 본문과 metadata 커밋 끝에는 `Co-Authored-By` 한 줄만 붙였다.

**2. [Rule 1 - 순서] `workflow_dispatch` 를 `main` push 실행이 끝난 뒤에 돌렸다** — 계획의 순서(3 → 4)대로지만, 계획은 3 의 실행이 끝나기를 기다린 뒤 4 를 하라고는 적지 않았다. workflow 의 concurrency group 은 `${{ github.workflow }}-${{ github.ref }}` 이고 `cancel-in-progress: true` 다. push 실행과 dispatch 실행은 둘 다 `refs/heads/main` 이라 group 이 같다. 그래서 push 실행이 도는 동안 dispatch 를 만들면 push 실행이 `cancelled` 가 된다. 그래서 `gh run watch 38850611790` 이 끝난 뒤(04:30:23Z) dispatch 했다. 두 실행 모두 success 다. 파일 변경은 없다.

---

**Total deviations:** 2 (시스템 규칙 1, 순서 1). **Impact:** 결과에는 영향이 없다. 범위 밖 작업도 없다.

## Issues Encountered

- push 명령 줄의 `push_rc=` 가 비어 찍혔다 (내 셸 줄의 PIPESTATUS). push 가 됐는지는 `ls-remote` 와 `origin == HEAD` 로 확인했다. 이어서 돌린 Task 1 둘째 `<automated>` 도 같은 것을 단언하고 rc 0 이었다.
- `gh pr merge` 는 tty 가 아닌 셸에서 아무것도 찍지 않는다. 병합 결과는 `gh pr view` 의 `MERGED` · `mergeCommit` 과 `git log -1 --format=%P origin/main` 으로 남겼다.

## User Setup Required

None — 네트워크(GitHub)만 필요하다.

## Next Phase Readiness

- **06-07 (처리 기록):** 02-UAT 4번 → run `38845784725` (`pull_request`, PR #1, 평소 모드 10/10). 02-UAT 6번 → 자동화 부분은 run `38850984674` (`workflow_dispatch`, `main`, 10/10) 이고, `Run workflow` 버튼의 화면 확인은 phase UAT 에 남는다. `main` push 실행은 `38850611790` 이다.
- `origin/main` = `5ee5a12` (merge commit). 원격 작업 브랜치 = `ad09d6e`. 로컬 작업 브랜치는 이 plan 의 metadata 커밋 하나가 앞서고, 그 커밋은 push 하지 않았다. 로컬 `main` 은 옛 값 그대로다.
- PR #1 은 `MERGED` 이고 작업 브랜치는 원격에 남아 있다 (`/gsd-complete-milestone` 이 병합 · 삭제를 다시 제안하면 Keep branches).
- `requirements.mark-complete` 는 부르지 않았다 (orchestrator 지시 9번 — phase 끝 검증이 판정한다).

---
*Phase: 06-release*
*Completed: 2026-10-16*

## Self-Check: PASSED

- FOUND: PR #1 `MERGED`, mergeCommit `5ee5a12…` == `origin/main`
- FOUND: `origin/main` 부모 둘 (`90a2736…` · `ad09d6e…`), `merge-base --is-ancestor v2.0.0 origin/main` · `origin/gsd/v2.0-package-rework origin/main` 둘 다 0
- FOUND: run 38845719589 · 38845784725 · 38850611790 · 38850984674 모두 `completed` · `success`
- FOUND: `ls-remote --heads` 둘, `--tags` 4줄 (`v2.0.0^{}` = `704bf56…`)
- `<automated>` 셋 rc 0 (위 표)
- commits: 0 (`git rev-list --count ad09d6e..HEAD` = 0 — SUMMARY 작성 시점, metadata 커밋 전)
