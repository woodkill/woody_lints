---
phase: 01-baseline-and-toolchain
plan: 01
subsystem: release
tags: [git, tag, annotated-tag, github, release-baseline]

# Dependency graph
requires: []
provides:
  - "원격(origin) annotated tag `v1.3.0` → 커밋 `90a2736b8d998c84467faf562a0fec720b797eaf` (pubspec version 1.3.0)"
  - "뒤 phase 의 \"`main` 은 1.3.0 그대로\" 검사가 비교할 기준 ref `v1.3.0`"
  - "tag push 증거 형식 (push 출력 + `ls-remote --tags` / `--heads` 원문) — Phase 6 smoke test 가 재사용"
affects: [01-02, 01-03, phase-6-release, consumer-projects]

# Actuals (#2632)
actuals:
  tokens: 0        # task 가 바꾼 추적 파일이 0개다 (git ref 만 만들었다). 이 SUMMARY 등 `.planning/` bookkeeping 은 세지 않았다
  tasks: 3         # Task 1 (tracer), Task 2 (checkpoint:decision), Task 3 (auto)
  commits: 0       # MEASURED: git rev-list --count 3d1d462a613356bcc95f581dc16da6403648af27..HEAD (SUMMARY 작성 시점)
plan_head_before: 3d1d462a613356bcc95f581dc16da6403648af27
plan_head_after: 3d1d462a613356bcc95f581dc16da6403648af27

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "릴리스 tag 는 annotated(`git tag -a`, `-m` 두 번)로 만들고, push 는 tag 이름 하나만(`git push origin vX.Y.Z`) 한다"
    - "원격 tag 판정은 `git ls-remote --tags origin` 의 peeled 줄(`refs/tags/vX.Y.Z^{}`)이 가리키는 커밋 SHA 로 한다"
    - "원격 쓰기 뒤에는 `git ls-remote --heads origin` 으로 브랜치가 따라 올라가지 않았는지 확인한다"

key-files:
  created:
    - .planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md
  modified: []

key-decisions:
  - "`v1.3.0` annotated tag 를 `90a2736` 에 붙여 origin 에 올렸다 (소유자 응답 `push`, 2026-10-11T04:25:38Z). 이 tag 는 옮기거나 지우지 않는다 — 잘못이 발견되면 새 이름(`v1.3.1` 등)을 쓴다"
  - "이 phase 에서 origin 에 올린 것은 tag `v1.3.0` 하나다. 브랜치 `gsd/v2.0-package-rework` 와 `.planning/` 은 원격에 없다"

patterns-established:
  - "tag push 증거: push 출력 원문 + `ls-remote --tags` 두 줄(tag 객체 SHA, `^{}` 커밋 SHA) + `ls-remote --heads` 를 날짜·시각과 함께 SUMMARY 에 붙인다"

requirements-completed: [REL-01]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "원격 annotated tag `v1.3.0` 이 1.3.0 커밋 `90a2736` 을 가리킨다"
    requirement: "REL-01"
    verification:
      - kind: other
        ref: "git ls-remote --tags origin → `90a2736b8d998c84467faf562a0fec720b797eaf<TAB>refs/tags/v1.3.0^{}` (Task 3 <automated> verify, rc=0)"
        status: pass
      - kind: other
        ref: "git cat-file -t v1.3.0 → tag ; git rev-parse 'v1.3.0^{commit}' → 90a2736… ; = git rev-parse origin/main (Task 1 <automated> verify, rc=0)"
        status: pass
      - kind: other
        ref: "git show v1.3.0:pubspec.yaml | grep -nx 'version: 1.3.0' → 3:version: 1.3.0"
        status: pass
    human_judgment: false
  - id: D2
    description: "push 뒤에도 원격 브랜치는 `refs/heads/main` 하나다 — 작업 브랜치와 `.planning/` 은 올라가지 않았다"
    requirement: "REL-01"
    verification:
      - kind: other
        ref: "git ls-remote --heads origin → 정확히 한 줄 `90a2736…<TAB>refs/heads/main` (Task 3 <automated> verify, rc=0)"
        status: pass
    human_judgment: false
  - id: D3
    description: "`git push origin v1.3.0` 은 소유자가 checkpoint 에서 `push` 를 택한 뒤에만 실행되었고, 확인 요청에는 올릴 것·명령·되돌릴 수 없음이 쉬운 말로 적혀 있었다"
    verification: []
    human_judgment: true
    rationale: "확인 패널은 orchestrator 가 소유자에게 보였고, 이 실행자는 그 요약과 전달받은 응답만 갖고 있다. 시각 순서(응답 04:25:38Z < push 04:27:13Z)는 기록으로 남지만, 패널 문안이 쉬운 말로 충분했는지는 소유자만 판단할 수 있다"

# Metrics
duration: 7min
completed: 2026-10-11
status: complete
---

# Phase 1 Plan 01: v1.3.0 기준점 tag Summary

**1.3.0 커밋 `90a2736` 에 annotated tag `v1.3.0` 을 붙이고, 소유자 확인 뒤 `git push origin v1.3.0` 한 줄로 GitHub 에 올렸다 — 원격 `refs/tags/v1.3.0^{}` = `90a2736`, 원격 브랜치는 `main` 하나 그대로**

## Performance

- **Duration:** 7 min (453초. 이 중 약 3분 20초는 소유자 응답을 기다린 시간)
- **Started:** 2026-10-11T04:21:14Z
- **Completed:** 2026-10-11T04:28:47Z (작업·검증 종료 시점. SUMMARY 작성과 상태 갱신 시간은 포함하지 않는다)
- **Tasks:** 3 (tracer 1, checkpoint:decision 1, auto 1)
- **Files modified:** 0 (저장소 추적 파일 기준. 생긴 것은 git ref 뿐이다)

시각 순서 (소유자 확인이 push 보다 앞섰다는 기록):

| 시각 (UTC) | 한국 시각 | 일 |
|------------|-----------|----|
| 2026-10-11T04:21:51Z | 13:21:51 | 로컬 tag 생성 (Task 1) |
| 2026-10-11T04:22:01Z | 13:22:01 | 4중 점검 PASS (Task 1) |
| 2026-10-11T04:25:38Z | 13:25:38 | 소유자 응답 `push` (Task 2) |
| 2026-10-11T04:27:05Z | 13:27:05 | push 직전 재확인 — 원격에 tag 없음, Task 1 verify rc=0 |
| 2026-10-11T04:27:13Z ~ 04:27:16Z | 13:27:13 ~ 13:27:16 | `git push origin v1.3.0` (Task 3) |
| 2026-10-11T04:27:23Z | 13:27:23 | 원격 확인 (Task 3) |

## Accomplishments

- 로컬 annotated tag `v1.3.0` (tag 객체 `80e2112578b7a9870e43476a2893bc4972d4a3a9`) 이 커밋 `90a2736b8d998c84467faf562a0fec720b797eaf` 을 가리킨다. 그 커밋은 `origin/main` 과 같고 `pubspec.yaml` 의 version 은 `1.3.0` 이다
- 같은 tag 가 GitHub(origin) 에 올라갔다. `git ls-remote --tags origin` 의 `refs/tags/v1.3.0^{}` 줄이 `90a2736…` 이다 (REL-01)
- 원격 브랜치는 `refs/heads/main` 하나 그대로다. 작업 브랜치 `gsd/v2.0-package-rework` 와 `.planning/` 은 올라가지 않았다
- 저장소 추적 파일은 하나도 바뀌지 않았다. `main` 의 `lib/` 와 `pubspec.yaml` 은 1.3.0 그대로다

## Task Commits

이 plan 의 커밋 계약대로 task 커밋은 없다. 세 task 모두 추적 파일을 바꾸지 않았고, tag ref 를 만들거나 올리는 것은 커밋이 아니다.

1. **Task 1: 로컬 annotated tag `v1.3.0` 을 `90a2736` 에 만들고 4중 점검** - 커밋 없음 (git ref `refs/tags/v1.3.0` 만 생성)
2. **Task 2: 소유자 확인 (checkpoint:decision, gate blocking-human)** - 커밋 없음 (결정 기록만)
3. **Task 3: `git push origin v1.3.0` 과 원격 확인** - 커밋 없음 (원격 ref `refs/tags/v1.3.0` 만 생성)

**Plan metadata:** 이 SUMMARY 와 `STATE.md` / `ROADMAP.md` / `REQUIREMENTS.md` 를 담는 `docs(01-01)` 커밋 하나 (이 문서 작성 뒤에 만들어지므로 해시는 여기에 적지 않는다)

커밋 수 측정 (SUMMARY 작성 시점):

```text
$ cat .git/gsd-plan-head-before-01-01
3d1d462a613356bcc95f581dc16da6403648af27
$ git rev-list --count 3d1d462a613356bcc95f581dc16da6403648af27..HEAD
0
$ git rev-parse HEAD
3d1d462a613356bcc95f581dc16da6403648af27
```

## Files Created/Modified

- `.planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md` - 이 증거 기록
- 저장소 파일(`lib/`, `pubspec.yaml`, `README.md` 등): 변경 없음

파일이 아닌 산출물:

- git ref `refs/tags/v1.3.0` (로컬과 origin 양쪽) → tag 객체 `80e2112578b7a9870e43476a2893bc4972d4a3a9` → 커밋 `90a2736b8d998c84467faf562a0fec720b797eaf`
- tag 메시지: 제목 `woody_lints 1.3.0`, 본문 `2.0.0 작업 전 기준점. Dart 3.13 미만 프로젝트는 이 tag 에 머문다`

## Task 1 증거 — 로컬 tag 생성과 4중 점검

앞선 실행자가 남긴 출력 원문이다. 고치지 않고 그대로 붙였다.

사전 확인 — precondition 과 사실 확인 (2026-10-11T04:21Z):

```text
$ git remote -v
origin	git@github.com:woodkill/woody_lints.git (fetch)
origin	git@github.com:woodkill/woody_lints.git (push)
$ git ls-remote --tags origin

rc=0        # 출력 없음 = 원격에 tag 없음 → precondition 충족
$ git fetch origin --quiet
rc=0
$ git rev-parse origin/main
90a2736b8d998c84467faf562a0fec720b797eaf
$ git show -s --format='%H %ad %an%n%s' --date=iso 90a2736
90a2736b8d998c84467faf562a0fec720b797eaf 2026-09-20 02:56:04 +0900 Woody Moon
feat: riverpod_lint 를 최상위 plugins: 방식으로 전환 (1.3.0)
$ git show 90a2736:pubspec.yaml | grep -n '^version:'
3:version: 1.3.0
$ git tag -l
(없음)
$ git config --get push.default / push.followTags / tag.gpgSign / remote.pushDefault
push.default=<unset>
push.followTags=<unset>
tag.gpgSign=<unset>
remote.pushDefault=<unset>
$ git ls-remote --heads origin
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
```

tag 생성 (2026-10-11T04:21:51Z = 2026-10-11 13:21:51 +0900):

```text
$ git tag -a v1.3.0 90a2736 -m "woody_lints 1.3.0" -m "2.0.0 작업 전 기준점. Dart 3.13 미만 프로젝트는 이 tag 에 머문다"
rc=0
```

4중 점검 (2026-10-11T04:22:01Z):

```text
$ git fetch origin --quiet
rc=0
$ git cat-file -t v1.3.0
tag
PASS (a) annotated
$ git rev-parse 'v1.3.0^{commit}'
90a2736b8d998c84467faf562a0fec720b797eaf
PASS (b) -> 90a2736
$ git rev-parse origin/main
90a2736b8d998c84467faf562a0fec720b797eaf
PASS (c) = origin/main
$ git show v1.3.0:pubspec.yaml | grep -nx 'version: 1.3.0'
3:version: 1.3.0
PASS (d) version 1.3.0
$ git tag -n99 v1.3.0
v1.3.0          woody_lints 1.3.0
    
    2.0.0 작업 전 기준점. Dart 3.13 미만 프로젝트는 이 tag 에 머문다
$ git for-each-ref refs/tags --format='%(objecttype) %(refname:short) -> %(*objectname:short) %(taggerdate:short)'
tag v1.3.0 -> 90a2736 2026-10-11
$ git rev-parse v1.3.0   # tag 객체 자체의 SHA
80e2112578b7a9870e43476a2893bc4972d4a3a9
$ git cat-file -p v1.3.0
object 90a2736b8d998c84467faf562a0fec720b797eaf
type commit
tag v1.3.0
tagger Woody Moon <woodkill@gmail.com> 1791692511 +0900

woody_lints 1.3.0

2.0.0 작업 전 기준점. Dart 3.13 미만 프로젝트는 이 tag 에 머문다
$ git ls-remote --tags origin
rc=0        # 출력 없음 = 원격에 아직 tag 없음 (이 task 는 push 하지 않음)
$ git status --short --untracked-files=no -- . ':(exclude).planning'
(출력 없음 — 저장소 파일 변경 없음)
```

plan 의 `<automated>` verify 와 tracer gate 재실행 (2026-10-11T04:22:17Z), push 가 없었다는 확인:

```text
Task 1 <automated> verify rc=0
Tracer feedback gate re-run rc=0
$ git ls-remote origin
90a2736b8d998c84467faf562a0fec720b797eaf	HEAD
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
```

앞선 실행자의 메모: deviation 없음. 인증 게이트 없음 (SSH 로 `git fetch` / `git ls-remote` 가 동작했다). 메인 체크아웃에서 실행했다 (worktree 가 아니다).

메인 체크아웃의 `git tag -l` (plan 의 worktree 가정 확인 항목 — 실행 위치가 메인 체크아웃이라 가정 자체가 해당되지 않지만 결과를 남긴다. 2026-10-11T04:26:52Z):

```text
$ git rev-parse --show-toplevel
/Users/woody/dv/woody/woody_lints
$ git tag -l
v1.3.0
```

## Task 2 기록 — 소유자 확인 (checkpoint:decision, gate blocking-human)

**결정:** tag `v1.3.0` 을 지금 GitHub(origin) 에 올릴까?

**확인 요청 문안 (요약).** 패널은 orchestrator 가 소유자에게 직접 보였다. 이 실행자가 전달받은 것은 문안의 요약이며, 아래가 그 요약이다. 패널에는 쉬운 한국어로 다음이 적혀 있었다:

- **올릴 것:** 커밋 `90a2736` 에 붙은 tag `v1.3.0` 하나. 브랜치는 올라가지 않고 `.planning/` 파일도 올라가지 않는다
- **실행할 명령:** `git push origin v1.3.0`
- **되돌리지 않는 점:** 한 번 올린 tag 는 옮기거나 지우지 않는다. 실수였다면 `v1.3.1` 같은 새 이름을 쓴다
- **점검 결과:** 4중 점검 결과 네 가지 (annotated / `90a2736` / `origin/main` 과 같음 / version 1.3.0)
- **선택지:** `push` / `hold`, 권고는 `push`

**확인 요청 문안 (원문).** orchestrator 가 2026-10-11 에 소유자에게 보인 패널 그대로다. 실행자가 SUMMARY 를 쓴 뒤 orchestrator 가 덧붙였다.

````markdown
### CHECKPOINT: Decision Required

**Plan:** 01-01 tag `v1.3.0` 만들기
**Progress:** 작업 3개 중 1개 완료. GitHub 에는 아직 아무것도 올리지 않았습니다.

**결정할 것: 이름표 `v1.3.0` 을 지금 GitHub 에 올릴까요?**

용어 풀이:
- **tag(이름표)**: 특정 저장 시점에 붙이는 책갈피입니다. "1.3.0 판은 바로 여기"라고 표시해 둡니다.
- **push(올리기)**: 내 컴퓨터에만 있는 것을 GitHub 로 보내는 일입니다.

지금 상태는 이름표가 **내 컴퓨터에만** 있는 상태입니다. 에이전트 보고를 믿지 않고 제가 직접 다시 확인했습니다.

| 확인한 것 | 결과 |
|---|---|
| 이름표가 메모가 붙은 정식 종류인가 | 맞음 |
| 1.3.0 커밋(`90a2736`)을 가리키나 | 맞음 |
| GitHub `main` 이 가리키는 곳과 같은가 | 같음 |
| 그 시점의 `pubspec.yaml` 이 `version: 1.3.0` 인가 | 맞음 |
| GitHub 에 이미 올라간 것이 있나 | 없음 (`main` 한 줄만 있음) |

**올리면 일어나는 일**
- 실행할 명령은 `git push origin v1.3.0` 하나입니다. 이름표 하나만 올라갑니다.
- 작업 중인 브랜치, `.planning/` 문서, 다른 파일은 올라가지 않습니다.
- 사용 프로젝트 5개에는 아무 변화가 없습니다. 이름표는 `main` 을 건드리지 않습니다.

**되돌릴 수 없는 점**
한 번 올린 이름표는 옮기거나 지우지 않기로 정했습니다. 사용 프로젝트가 이 이름표의 커밋 번호를 기억하기 때문입니다. 잘못 붙였다면 `v1.3.0` 이름은 버리고 `v1.3.1` 같은 새 이름을 써야 합니다.

| 선택 | 이렇게 됩니다 |
|---|---|
| `push` (올린다) | 이름표를 GitHub 에 올리고 확인한 뒤, 나머지 plan(01-02 문서, 01-03 SDK 정렬)을 이어서 실행합니다. |
| `hold` (올리지 않는다) | 여기서 멈춥니다. 내 컴퓨터의 이름표는 그대로 두며, 원하면 흔적 없이 지울 수 있습니다. 01-02 와 01-03 은 시작하지 않습니다. |

**권고: `push`.** 점검이 모두 통과했고, GitHub 에 같은 이름의 이름표가 없어 충돌할 것이 없습니다. 이 이름표가 있어야 Dart 3.13 미만 프로젝트가 1.3.0 에 머물 수 있고, 01-03 의 마지막 확인도 이 이름표를 씁니다.

---

**→ Select: `push` / `hold`**
````

**소유자 응답:** `push`

**응답 시각:** 2026-10-11T04:25:38Z (2026-10-11 13:25:38 +0900)

소유자는 패널에 정확히 `push` 라는 단어로 답했다. 이 응답은 orchestrator 가 받아 이 실행자에게 전달했다.

`hold` 가 아니었으므로 Task 3 을 실행했다. 참고로 push 전에 로컬 tag 를 흔적 없이 지우는 명령은 `git tag -d v1.3.0` 이었다. push 한 지금은 쓰지 않는다 (tag 는 옮기거나 지우지 않는다).

## Task 3 증거 — push 와 원격 확인

push 직전 재확인 (2026-10-11T04:26:52Z ~ 04:27:05Z). 로컬 tag 가 그대로이고, push 범위를 넓히는 git 설정이 없고, 원격에 아직 tag 가 없다:

```text
$ git rev-parse --show-toplevel
/Users/woody/dv/woody/woody_lints
$ git rev-parse --abbrev-ref HEAD
gsd/v2.0-package-rework
$ git rev-parse HEAD
3d1d462a613356bcc95f581dc16da6403648af27
$ git cat-file -t v1.3.0
tag
$ git rev-parse 'v1.3.0^{commit}'
90a2736b8d998c84467faf562a0fec720b797eaf
$ git rev-parse v1.3.0
80e2112578b7a9870e43476a2893bc4972d4a3a9
$ git remote -v
origin	git@github.com:woodkill/woody_lints.git (fetch)
origin	git@github.com:woodkill/woody_lints.git (push)
$ git config --get-all <key>
push.default=<unset>
push.followTags=<unset>
remote.pushDefault=<unset>
remote.origin.push=<unset>
remote.origin.mirror=<unset>
tag.gpgSign=<unset>
$ ls .git/hooks | grep -v '\.sample$'
(없음 — 활성 hook 없음. pre-push hook 도 없다)
$ git ls-remote origin
90a2736b8d998c84467faf562a0fec720b797eaf	HEAD
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
rc=0
Task 1 <automated> verify re-run: rc=0
$ git rev-parse origin/main
90a2736b8d998c84467faf562a0fec720b797eaf
```

push (2026-10-11T04:27:13Z 시작, 04:27:16Z 종료 = 2026-10-11 13:27:13 +0900):

```text
$ git push origin v1.3.0
To github.com:woodkill/woody_lints.git
 * [new tag]         v1.3.0 -> v1.3.0
rc=0
```

원격 확인 (2026-10-11T04:27:23Z = 2026-10-11 13:27:23 +0900):

```text
$ git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
rc=0
$ git ls-remote --heads origin
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
rc=0
$ git ls-remote origin
90a2736b8d998c84467faf562a0fec720b797eaf	HEAD
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
rc=0
$ git show v1.3.0:pubspec.yaml | grep -nx 'version: 1.3.0'
3:version: 1.3.0
Task 3 <automated> verify rc=0
```

읽는 법: annotated tag 는 `ls-remote` 에 두 줄로 나온다. 첫 줄 `80e2112…` 는 tag 객체 자체의 SHA 이고 (로컬 `git rev-parse v1.3.0` 과 같다), 둘째 줄 `refs/tags/v1.3.0^{}` 이 tag 가 가리키는 **커밋**이다. 판정은 둘째 줄로 한다.

push 뒤 로컬 상태 (2026-10-11T04:27:23Z):

```text
$ git rev-parse v1.3.0 'v1.3.0^{commit}'
80e2112578b7a9870e43476a2893bc4972d4a3a9
90a2736b8d998c84467faf562a0fec720b797eaf
$ git cat-file -t v1.3.0
tag
$ git status --short --untracked-files=no -- . ':(exclude).planning'
(출력 없음 — 저장소 파일 변경 없음)
$ git rev-parse HEAD
3d1d462a613356bcc95f581dc16da6403648af27
$ git branch -r
  origin/HEAD -> origin/main
  origin/main
```

### Task 3 acceptance criteria

| 기준 | 결과 | 근거 |
|------|------|------|
| `git push origin v1.3.0` 출력에 `[new tag]` 와 `v1.3.0 -> v1.3.0` | PASS | ` * [new tag]         v1.3.0 -> v1.3.0` |
| `ls-remote --tags` 에 `refs/tags/v1.3.0` 줄과 `refs/tags/v1.3.0^{}` 줄이 각각 하나, `^{}` 줄 SHA = `90a2736…` | PASS | tag 객체 줄 1개, peeled 줄 1개, 전체 2줄. peeled SHA `90a2736b8d998c84467faf562a0fec720b797eaf` |
| `ls-remote --heads` 가 정확히 한 줄, ref 는 `refs/heads/main` | PASS | 한 줄, `refs/heads/main` |
| `git show v1.3.0:pubspec.yaml` 에 `version: 1.3.0` 줄 | PASS | `3:version: 1.3.0` |
| SUMMARY 에 push 출력과 두 `ls-remote` 출력 원문, 날짜·시각 | PASS | 이 절 |

## Plan 검증 결과

| 항목 | 결과 |
|------|------|
| Task 1 verify (로컬 4중 점검) | PASS — rc=0 (04:22:17Z), push 직전 재실행도 rc=0 (04:27:05Z) |
| Task 3 verify (원격 `^{}` 줄 + heads 1줄) | PASS — rc=0 (04:27:23Z) |
| ROADMAP success criterion 1 (`ls-remote --tags` 에 `v1.3.0`, tag 의 pubspec version 1.3.0) | PASS |
| 소유자 확인(Task 2)이 push(Task 3)보다 앞섰다 | 응답 04:25:38Z < push 04:27:13Z |
| 커밋 계약 (task 커밋 0개, 추적 파일 변경 0건) | PASS — `rev-list --count` = 0, `git status` (`.planning/` 제외) 출력 없음 |

### must_haves 의 prohibitions

| 금지 사항 | 지켰는가 | 근거 |
|-----------|----------|------|
| origin 에 올리는 것은 tag `v1.3.0` 하나뿐 (브랜치, 다른 tag, `--tags` / `--follow-tags`, 인자 없는 `git push` 금지) | 지켰다 | 이 plan 에서 origin 에 쓴 명령은 `git push origin v1.3.0` 한 번뿐이다. 나머지 원격 명령(`git fetch`, `git ls-remote`)은 읽기 전용이다. push 뒤 `ls-remote origin` 은 `HEAD`, `refs/heads/main`, tag 두 줄만 보인다 |
| push 한 tag `v1.3.0` 은 옮기거나 지우지 않는다 | 지켰다 | push 뒤 tag 를 건드린 명령이 없다. 로컬과 원격의 tag 객체 SHA 가 `80e2112…` 로 같다. 이 약속은 앞으로도 유지해야 한다 |

### threat_model 의 mitigate 항목

| Threat | 적용한 완화 |
|--------|-------------|
| T-01-01 (tag 가 엉뚱한 커밋을 가리킴) | 4중 점검 전부 PASS 뒤에만 확인 요청으로 갔고, push 직전에 한 번 더 돌렸으며, push 뒤 `ls-remote` 의 `^{}` 줄로 재확인했다 |
| T-01-02 (브랜치와 `.planning/` 공개) | push 명령은 `git push origin v1.3.0` 한 줄. push 범위를 넓히는 설정(`push.followTags`, `remote.origin.push`, `remote.origin.mirror`)이 모두 unset 임을 직전에 확인했다. push 뒤 `ls-remote --heads` 는 `main` 한 줄이다 |
| T-01-03 (작성자·날짜 없는 lightweight tag) | `git tag -a` 로 만들었고 `git cat-file -t v1.3.0` = `tag`. `git tag -n99` 에 제목/본문 두 단락이 보인다 |

## Decisions Made

- **tag `v1.3.0` 을 origin 에 올렸다.** 소유자가 checkpoint 에서 `push` 를 택했다 (2026-10-11T04:25:38Z). 이 결정으로 STATE 의 "[Phase 1] D4: `v1.3.0` tag 의 원격 push 는 소유자의 명시적 확인이 필요하다" 항목이 해소된다
- **tag 는 고정이다.** 올린 `v1.3.0` 은 옮기거나 지우지 않는다. 사용 프로젝트의 `pubspec.lock` 이 tag 가 가리키는 커밋을 `resolved-ref` 로 기록하기 때문이다. 잘못이 발견되면 새 이름(`v1.3.1` 등)을 쓴다
- 그 밖에는 plan 을 그대로 따랐다 (tag 메시지는 논의의 기본값 두 단락, `-s` 서명 없음)

## Deviations from Plan

None - plan executed exactly as written.

**Total deviations:** 0
**Impact on plan:** 없음. push 명령, 확인 명령, 커밋 계약 모두 plan 에 적힌 그대로다.

## Authentication Gates

없음. `git@github.com:woodkill/woody_lints.git` 에 대한 SSH 인증이 `fetch`, `ls-remote`, `push` 모두에서 프롬프트 없이 동작했다.

## Issues Encountered

- **확인 패널의 문안 원문이 이 문서에 없다.** plan 의 `<output>` 은 "Task 2 의 확인 요청 문안" 을 요구하지만, 패널은 orchestrator 가 소유자에게 보였고 이 실행자는 그 요약만 전달받았다. 위 "Task 2 기록" 에는 전달받은 요약을 요약이라고 밝혀 적었다. 원문을 남기려면 orchestrator 가 그 절에 덧붙이면 된다. 소유자 응답과 시각은 전달받은 그대로 기록했다
  - **해소 (2026-10-11):** orchestrator 가 "Task 2 기록" 절에 패널 원문을 덧붙였다. 이제 요약과 원문이 함께 있다
- 실행이 두 실행자로 나뉘었다 (Task 1 과 checkpoint 까지 → 소유자 응답 → 이 실행자가 Task 3 과 SUMMARY). checkpoint 흐름상 정상이며, Task 1 의 증거는 앞선 실행자의 출력 원문을 그대로 붙였다

## Known Stubs

없음. 이 plan 은 파일을 만들거나 고치지 않았다 (이 SUMMARY 제외).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- plan 01-02 (`VERSIONING.md`) 와 01-03 (SDK 정렬) 이 시작할 수 있다. 둘 다 이 plan 에 `depends_on` 으로 묶여 있었고, 소유자 확인과 push 가 끝났다
- 사용 프로젝트는 이제 `ref: v1.3.0` 으로 1.3.0 에 고정할 수 있다. Dart 3.13 미만 프로젝트는 이 tag 에 머문다
- 뒤 phase 의 "`main` 의 `lib/` 와 `pubspec.yaml` 은 1.3.0 그대로" 검사는 `v1.3.0` 과 비교하면 된다 (예: `git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml`)
- 유지할 약속: `v1.3.0` 은 옮기거나 지우지 않는다. 그리고 릴리스(Phase 6) 전까지 origin 에는 `main` 과 tag 외에 아무것도 올리지 않는다 — 인자 없는 `git push` 는 현재 브랜치와 `.planning/` 을 공개 저장소에 올린다
- 막힌 것 없음

## Self-Check: PASSED

SUMMARY 작성 뒤 다시 확인했다 (2026-10-11T04:30:46Z):

| 주장 | 확인 | 결과 |
|------|------|------|
| 이 SUMMARY 파일이 있다 | `[ -f .planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md ]` | FOUND |
| 원격 tag `v1.3.0` → `90a2736` | `git ls-remote --tags origin` 의 `refs/tags/v1.3.0^{}` 줄 = `90a2736b8d998c84467faf562a0fec720b797eaf` | FOUND |
| 원격 브랜치는 `main` 하나 | `git ls-remote --heads origin` 한 줄 (`refs/heads/main`) | FOUND |
| 로컬 tag 가 annotated 이고 `90a2736` 을 가리킨다 | `git cat-file -t v1.3.0` = `tag`, `git rev-parse 'v1.3.0^{commit}'` = `90a2736…` | FOUND |
| task 커밋 0개 | `git rev-list --count 3d1d462a613356bcc95f581dc16da6403648af27..HEAD` = `0` | 일치 |
| 이 문서에 `refs/tags/v1.3.0^{}` 가 있다 (must_haves artifact `contains`) | `grep -cF 'refs/tags/v1.3.0^{}'` = 7 | FOUND |
| frontmatter 와 `coverage` 블록이 읽힌다 | `gsd-tools verify-summary` → `passed: true`, `gsd-tools uat classify-coverage` → 3건 분류 | PASS |

확인할 task 커밋 해시는 없다 (커밋 계약상 0개).

---
*Phase: 01-baseline-and-toolchain*
*Completed: 2026-10-11*
