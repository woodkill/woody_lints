---
phase: 06-release
plan: 14
subsystem: release
tags: [review-disposition, push, github-actions, pull-request, rel-03, rel-04, gap-closure]

# Dependency graph
requires:
  - phase: 06-release
    provides: "06-12 Task 1 (85e1b0d) 의 CHANGELOG 첫 줄 고정, 06-13 Task 1 · 2 (9d96778 · ea2d664) 의 smoke 고침"
provides:
  - "06-REVIEW-DISPOSITION.md 아홉 발견 fixed · IN-08 deferred · open 0 (total 16) — Source 칸이 06-12 · 06-13 의 task 커밋 sha 와 G7-Q1 의 이유를 가리킴"
  - "origin/gsd/v2.0-package-rework == 0461741 (724d17a..0461741, 11커밋)"
  - "GitHub verify — push 실행 38934754393 · pull_request 실행 38935292307 둘 다 success · 10/10"
  - "PR #3 (main ← gsd/v2.0-package-rework) 열림, MERGEABLE / CLEAN — 병합은 06-15"
affects: [06-15, release-gate]

# Actuals (#2632)
actuals:
  tokens: 533
  tasks: 2
  commits: 1
plan_head_before: 6d8c0b774d44148acba2c6d109b195d094c180ad
plan_head_after: 0461741202008704d285d57aaaec9a8907c306d4

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "처리 기록의 세 자리(frontmatter disposition · 표의 행 · open:)를 한 커밋에서 함께 고친다 (06-07 · 06-10 의 선례)"
    - "넣지 않은 발견은 deferred 와 소유자 결정의 이유를 Source 칸에 적는다"

key-files:
  created: []
  modified:
    - .planning/phases/06-release/06-REVIEW-DISPOSITION.md

key-decisions:
  - "06 리뷰 2회차의 열 발견을 닫았다 — WR-02 · WR-05 · IN-09 는 06-12 Task 1 (85e1b0d), IN-04 · WR-06 · WR-04 는 06-13 Task 1 (9d96778), IN-05 · IN-06 · IN-07 은 06-13 Task 2 (ea2d664) 로 fixed, IN-08 은 deferred (G7-Q1 — 첫 줄 규칙 아래에서는 거짓 통과 방향이 해석기 판에 기대지 않는다); open 0 · total 16; 버전 · CHANGELOG 는 그대로 (저장소 안쪽만 바뀜, G7-Q3 NOT)"
  - "작업 브랜치를 push gate 0 뒤 한 줄로 올리고(724d17a..0461741, 11커밋, 2026-10-16T16:47:56Z 무렵) PR #3 (main ←) 를 열었다 — push 실행 38934754393 · pull_request 실행 38935292307 둘 다 success 10/10, MERGEABLE / CLEAN; 병합은 06-15 의 소유자 확인 뒤"

patterns-established: []

requirements-completed: [REL-03, REL-04]  # 이 plan 은 requirements.mark-complete 를 부르지 않는다 — 06-15 도 선언하므로 마지막 plan 이 표시한다

coverage:
  - id: D1
    description: "06-REVIEW-DISPOSITION.md 의 열 발견 가운데 아홉이 fixed 와 실제 task 커밋 sha 로, IN-08 이 deferred 와 G7-Q1 의 이유로 기록되고 open 0 · total 16, 지운 줄 21, 제목 · recorded · 형식 설명 · 앞 회차 여섯 행 불변"
    requirement: "REL-03"
    verification:
      - kind: other
        ref: "06-14-PLAN.md Task 1 <automated> (적힌 그대로) rc 0 — 커밋 전, 커밋 뒤, PR 실행 뒤 세 번"
        status: pass
    human_judgment: false
  - id: D2
    description: "push gate 0 뒤 작업 브랜치 push, HEAD 의 push 실행 success · 로그 세 줄, PR #3 열림 · MERGEABLE, pull_request 실행 success · 로그 세 줄, origin/main · tag 그대로"
    requirement: "REL-04"
    verification:
      - kind: e2e
        ref: "06-14-PLAN.md Task 2 첫 <automated> (push gate, 적힌 그대로) rc 0 — push 직전, push 와 같은 명령 사슬"
        status: pass
      - kind: e2e
        ref: "06-14-PLAN.md Task 2 둘째 <automated> (적힌 그대로) rc 0 — metadata 커밋 전"
        status: pass
    human_judgment: false

# Metrics
duration: 11min
completed: 2026-10-17
status: complete
---

# Phase 6 Plan 14: 06 처리 기록 2회차 닫기 · 작업 브랜치 push · PR Summary

**06 리뷰 2회차의 열 발견 가운데 아홉이 06-12 · 06-13 의 task 커밋(`85e1b0d` · `9d96778` · `ea2d664`)과 함께 `fixed`, IN-08 이 G7-Q1 의 이유와 함께 `deferred` (open 0) 로 기록되었고, push gate 0 뒤 작업 브랜치를 올려 GitHub `verify` 가 첫 줄 규칙의 `[3/10]` 으로 push · pull_request 두 실행 모두 10/10 — PR #3 (`main` ←) 가 `MERGEABLE` / `CLEAN` 으로 열려 06-15 의 병합 확인을 기다린다**

## Performance

- **Duration:** 약 11 min
- **Started:** 2026-10-16T16:46:28Z
- **Completed:** 2026-10-16T16:57Z
- **Tasks:** 2 (커밋 1 — Task 2 는 원격 작업만)
- **Files modified:** 1

## Accomplishments

### (1) Task 1 — 처리 기록 (`0461741`)

커밋: `0461741` `docs(review): 06 처리 기록 2회차 — WR-02 · WR-04 ~ WR-06 · IN-04 ~ IN-07 · IN-09 fixed, IN-08 deferred (gap 수정 06-12 · 06-13, open 0)`. 해시는 범위 `54d9ae9..HEAD` 에서 제목 머리로 찾았다 — `85e1b0d` (06-12 Task 1, `-- tool/verify.dart`; 같은 범위의 `e6a4cbc` 는 제목 머리가 달라 잡히지 않음), `9d96778` (06-13 Task 1) · `ea2d664` (06-13 Task 2) (`-- tool/smoke.dart`). 세 값이 06-12 · 06-13 SUMMARY 의 sha 와 같다.

- frontmatter: 열 `disposition: open` → 아홉 `disposition: fixed` · IN-08 `disposition: deferred`, `open: 10` → `open: 0`. `total: 16` · `recorded:` · 제목 16줄 · 끝의 형식 설명은 글자 그대로.
- 표의 열 행, 전: 열 행 모두 `| ID | severity | open | - |` 꼴 → 후:

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-02 | warning | fixed | 06-12-PLAN.md Task 1 (85e1b0d) — changelogTop 이 CHANGELOG.md 의 첫 줄(U+FEFF 뗀 뒤)을 엄격한 최상단 제목 ## X.Y.Z - 날짜 자리 로 요구하고 package:markdown 의 첫 h2 와 같아야 통과 — 한 글자 밑줄의 setext 는 첫 줄이 제목이 아니라 [3/10] 블록으로 실패; M107 ~ M109 (소유자 결정 G7-Q1 (나)) |
| WR-04 | warning | fixed | 06-13-PLAN.md Task 1 (9d96778) — judge 가 종료 코드 3 인데 JSON 에 error 줄이 없으면 실패 사유를 더하고 includeErrorCodes 에 included_file_parse_error 를 더함 (소유자 결정 G7-Q2) |
| WR-05 | warning | fixed | 06-12-PLAN.md Task 1 (85e1b0d) — 같은 첫 줄 규칙 — 인용 · 목록 · 단락 안에서 연 HTML 주석 여는 글자는 첫 줄이 제목이 아니라 [3/10] 블록으로 실패; M110 ~ M112 (소유자 결정 G7-Q1 (나)) |
| WR-06 | warning | fixed | 06-13-PLAN.md Task 1 (9d96778) — runProcess 의 제한이 종료 코드와 출력 수집 전체(Future.wait)에 걸려 파이프를 붙든 자손이 있어도 제한 안에 timedOut (소유자 결정 G7-Q2) |
| IN-04 | info | fixed | 06-13-PLAN.md Task 1 (9d96778) — runProcess 가 Utf8Decoder(allowMalformed: true) 로 UTF-8 아닌 출력을 U+FFFD 로 받아 처리되지 않은 비동기 예외(255)가 finally 를 건너뛰지 않음; 하네스 (06-VERIFICATION.md 2회차 gap, 소유자 결정 G7-Q2) |
| IN-05 | info | fixed | 06-13-PLAN.md Task 2 (ea2d664) — pendingSpawn · awaitRunningChild 로 처리기가 띄우는 중인 하위 명령을 기다려 끊고, finally 가 cleanup 뒤에 처리기를 내림 (소유자 결정 G7-Q2) |
| IN-06 | info | fixed | 06-13-PLAN.md Task 2 (ea2d664) — killTree 가 표를 읽지 못하면 stderr 한 줄, SIGKILL 직전 표를 다시 읽어 사슬에 남은 pid 만 끊고 사슬 밖은 SIGCONT, 머리 주석에 부모가 먼저 끝난 자손은 끊지 못한다는 범위 (소유자 결정 G7-Q2) |
| IN-07 | info | fixed | 06-13-PLAN.md Task 2 (ea2d664) — scrubNamesFor 하나를 runSmoke 와 main 의 예외 안내 둘이 함께 씀 (SDK root · 홈 · 저장소 · 임시 폴더) (소유자 결정 G7-Q2) |
| IN-08 | info | deferred | 소유자 결정 G7-Q1 — 판 고정은 하지 않는다: 첫 줄 규칙 아래에서는 거짓 통과 방향이 해석기 판에 기대지 않는다 (첫 줄이 엄격한 제목이어야 하고 package:markdown 은 첫 줄과의 일치만 보는 둘째 reader 다); 2026-10-16 |
| IN-09 | info | fixed | 06-12-PLAN.md Task 1 (85e1b0d) — 다섯 자리(skill 세 줄 · pubspec.yaml 19행 · tool/verify.dart 머리 주석)의 문장이 package:yaml 을 YAML 대조와 pubspec.yaml 의 version 읽기에 쓴다고 말함 (소유자 결정 G7-Q2) |

- `git diff --numstat` 21 · 21 (frontmatter `disposition` 10 + `open:` 1 + 표 10).
- **IN-08 의 이유:** 소유자 결정 G7-Q1 — 첫 줄 규칙 아래에서는 `[3/10]` 이 먼저 파일 첫 줄을 엄격한 제목으로 요구하므로, `markdown` · `yaml` 의 판이 바뀌어도 거짓 통과(틀린 최상단을 통과시키는 방향)는 생기지 않는다; `package:markdown` 은 첫 줄과의 일치만 보는 둘째 reader 다. 판이 바뀌어 생길 수 있는 것은 거짓 실패 쪽뿐이고 그때는 CI 가 빨개져 드러난다.
- **CHANGELOG · 버전을 그대로 둔 판단:** 바뀐 것은 검증 스크립트(`tool/verify.dart`) · smoke(`tool/smoke.dart`) · `VERSIONING.md` 의 형식 문서 한 줄 · `pubspec.yaml` 의 주석 · skill 세 줄 · 기록뿐이다. VERSIONING.md 기준표 "저장소 안쪽만 바뀜 (`.fvmrc`, CI, `example/`, 검증 스크립트) → 올리지 않음" 에 해당하고, 형식 문서 한 줄은 받는 쪽에 닿지 않는다. 소유자 결정 G7-Q1 · G7-Q3 NOT ("버전 번호와 CHANGELOG 항목은 그대로"). `pubspec.yaml` 은 `version: 2.0.0`, CHANGELOG 1행은 `## 2.0.0 - 2026-10-15` 그대로.

### (2) Task 2 — push · CI · PR

**precondition (Task 1 커밋 뒤, 16:47:37Z):** `git fetch` 뒤 `origin/main` = `00385725e043bce0d3523a59ff8543603e5d1bd8`, `main` 으로 열린 PR 0, 브랜치 `gsd/v2.0-package-rework`, `gh auth status` 통과 (`repo` · `workflow` 범위), Task 1 커밋이 HEAD.

**push gate (적힌 그대로 rc 0 — 한 번은 따로, 한 번은 push 와 `&&` 로 이은 같은 명령 사슬에서 바로 앞):** 범위 `724d17a..0461741` (11커밋, 바뀐 파일 18개). 더해진 줄 전부에서 (1) 절대 경로 · 홈 · 임시 폴더 꼴 0줄, (2) `LEAK?` 0 (같은 자리에서 일부러 심은 경로가 잡혔다), (3) `fixes? made in|proposed fixes in` 0줄; orchestrator 상태 파일 셋은 범위에 없음; `.planning/` 밖 작업 트리 깨끗. 덧붙여 더해진 줄과 커밋 메시지에서 noreply trailer 밖의 이메일 글자 0줄.

- 첫 커밋: `6898e59 docs(06): gap 수정 2회차 계획 06-12 ~ 06-15 — CHANGELOG 첫 줄 고정 · smoke 여섯 고침 · 처리 기록 · main 병합`
- 마지막 커밋: `0461741 docs(review): 06 처리 기록 2회차 — WR-02 · WR-04 ~ WR-06 · IN-04 ~ IN-07 · IN-09 fixed, IN-08 deferred (gap 수정 06-12 · 06-13, open 0)`
- 범위 안에 06-12 뒤 U+FEFF 표기 정리 커밋 `e6a4cbc` (orchestrator, 소유자 승인, 동작 같음)가 들어 있다 — 어느 발견의 고침도 아니라 처리 기록은 가리키지 않는다.

**push (D-21 — 실행 뒤 보고):** `git push origin gsd/v2.0-package-rework` 한 줄, 2026-10-16T16:47:54Z ~ 16:47:58Z, 출력 `724d17a..0461741  gsd/v2.0-package-rework -> gsd/v2.0-package-rework` (fast-forward). 뒤에 `origin/gsd/v2.0-package-rework` == HEAD `0461741202008704d285d57aaaec9a8907c306d4`.

**브랜치 push 실행:** run `38934754393` (verify, push) — `completed` · `success`, job 16:48:03Z → 16:51:05Z (3분 2초), 이미지 `ubuntu-24.04` · `20261012.334.1`. 로그 세 줄 — 첫 줄 규칙으로 바뀐 `[3/10]` 이 Linux runner 의 새 checkout 에서 거짓 실패 없이 통과:

```
버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)
[3/10] 배포 파일의 구성 ................ 통과
점검 통과 (10개 중 10개)
```

**PR:** #3 https://github.com/woodkill/woody_lints/pull/3 (2026-10-16T16:52:13Z 생성). head `gsd/v2.0-package-rework` · base `main` · `headRefOid` == `0461741`. 생성 직후 `MERGEABLE` / `UNSTABLE` (PR 실행이 도는 중), 실행 뒤 `MERGEABLE` / `CLEAN`.

제목: `fix: CHANGELOG 최상단 reader 를 파일 첫 줄로 고정 · smoke 의 디코딩 · 제한 · 판정 · 중단 · 가리기 — 06 gap 수정 2회차 (REL-03 · REL-04)`

본문 전문:

```markdown
## 무엇이 바뀌나

Phase 6 의 gap 수정 2회차(06-12 · 06-13)를 `main` 에 합친다. 06-VERIFICATION.md 2회차 gap 과 06-REVIEW 의 열 발견이 모두 처리되었다 (`06-REVIEW-DISPOSITION.md` — fixed 15, deferred 1, open 0).

- **`tool/verify.dart` 의 `[3/10]` (06-12, WR-02 · WR-05 · IN-09)**
  - (i) 버전 일치 검사가 `CHANGELOG.md` 최상단 버전을 파일 첫 줄(U+FEFF 뗀 뒤)의 `## X.Y.Z - …` 제목에서 읽고, Markdown 해석(`package:markdown`)의 첫 h2 와 같아야 통과한다 (06-VERIFICATION.md 2회차 gap, 소유자 결정 G7-Q1 (나)).
  - 첫 줄이 제목이 아니거나(한 글자 밑줄의 setext, 인용 · 목록 · 단락 안에서 연 HTML 주석 등) 두 reader 가 다르면 `[3/10]` 이 안내 블록과 함께 실패한다. `# Changelog` 같은 머리말은 두지 않는다 — `VERSIONING.md` 「CHANGELOG 항목 형식」 에 한 줄을 더했다.
  - IN-09: 의존성 문장 다섯 자리(skill 세 줄 · `pubspec.yaml` 주석 · `tool/verify.dart` 머리 주석)가 `package:yaml` 을 YAML 대조와 version 읽기에 쓴다고 바로 적는다.
  - `example/README.md` 에 지워 보기 M107 ~ M115 와 재측정 기록.
  - 06-12 뒤 U+FEFF 표기 정리 (`e6a4cbc`), 동작 같음.
- **`tool/smoke.dart` (06-13, IN-04 · WR-06 · WR-04 · IN-05 · IN-06 · IN-07, 소유자 결정 G7-Q2)**
  - 하위 명령의 UTF-8 아닌 출력을 깨진 글자로 받아 처리되지 않은 예외로 끝나지 않는다 (IN-04).
  - 시간 제한이 종료 코드와 출력 수집 전체에 걸린다 — 파이프를 붙든 자손이 있어도 제한 안에 끝난다 (WR-06).
  - 종료 코드 3 인데 JSON 에 error 줄이 없으면 실패하고, include 받는 파일의 깨진 YAML(`included_file_parse_error`)도 실패 사유로 본다 (WR-04).
  - Ctrl-C (SIGINT) 가 띄우는 중인 하위 명령을 기다려 끊고, 처리기는 정리 뒤에 내린다 (IN-05).
  - `killTree` 가 프로세스 표를 읽지 못하면 한 줄로 알리고, 끊기 직전 표를 다시 읽는다 (IN-06).
  - 예외 안내도 SDK 경로 · 홈 · 저장소 · 임시 폴더를 가린다 (IN-07).
- **IN-08 (`markdown` · `yaml` 판 고정)은 `deferred`** — 소유자 결정 G7-Q1: 첫 줄 규칙 아래에서는 거짓 통과 방향이 해석기 판에 기대지 않는다 (첫 줄이 엄격한 제목이어야 하고 `package:markdown` 은 첫 줄과의 일치만 보는 둘째 reader 다).

## 받는 쪽에 바뀌는 것 없음

- `lib/` · `pubspec.yaml` 의 `version` (2.0.0) · `CHANGELOG.md` 항목 · tag 는 그대로다. 검증 스크립트 · smoke · 형식 문서 한 줄 · 기록만 바뀌었다 — VERSIONING.md 기준표 "저장소 안쪽만 바뀜 (`.fvmrc`, CI, `example/`, 검증 스크립트) → 올리지 않음" (소유자 결정 G7-Q3).
- 이미 올린 `v2.0.0` 과 지금 `main` 의 `CHANGELOG.md` 는 첫 줄이 `## 2.0.0 - 2026-10-15` 라 첫 줄 규칙을 그대로 통과한다 (06-VERIFICATION.md, 실행 전 확인). tag 는 만들거나 옮기지 않는다.

## 합치는 방법

- **merge commit 으로만 합친다** — squash · rebase 금지 (06-CONTEXT.md D-02, 06-06 · 06-11 과 같다). 브랜치는 지우지 않는다.
- 병합 직전에 소유자에게 한 번 더 확인한다 (06-15).

## 검증

- 로컬: `fvm dart run tool/verify.dart` 점검 통과 (10개 중 10개), `fvm dart analyze` 깨끗.
- GitHub `verify` (push): 이 브랜치의 HEAD 에서 success — 첫 줄 규칙의 `[3/10]` 이 runner 의 새 checkout 에서 통과, 10/10.
- push 전 범위의 더해진 줄 전부에 비공개 점검 셋(절대 경로 · 임시 폴더 꼴, 저장소에 없는 소스 경로, 리뷰 도구의 문구) 0.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

https://claude.ai/code/session_01FMQRSJydizwp5HqzzNuetV
```

PR 본문은 만들기 전에 절대 경로 · 임시 폴더 꼴 · 이메일 0줄, 저장소 소스 경로 꼴(확장자 붙은) 0개를 확인했다. 로컬 검증 줄은 이 plan 안에서 PR 전에 다시 돌린 결과다 (`fvm dart run tool/verify.dart` 종료 코드 0, `fvm dart analyze` No issues found).

**pull_request 실행:** run `38935292307` (verify, `pull_request`) — `completed` · `success`, job 16:52:19Z → 16:56:11Z (3분 52초), 이미지 `ubuntu-24.04`. 로그 세 줄 (평소 모드 — tag 모드로 돌지 않음):

```
버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)
[3/10] 배포 파일의 구성 ................ 통과
점검 통과 (10개 중 10개)
```

**원격 상태 (둘째 `<automated>`, metadata 커밋 전, 16:56:42Z):** `origin/main` = `0038572` 그대로, 원격 head 둘(`main` · 작업 브랜치), tag 4줄(`v1.3.0` · `v2.0.0` 과 각 `^{}`, `v2.0.0^{}` = `704bf56`) 그대로, `pubspec.yaml` · CHANGELOG · VERSIONING 은 처리 기록 커밋 뒤 불변, version `2.0.0`, CHANGELOG 1행 불변, `VERSIONING.md` 는 `v2.0.0` 대비 `1/0`. PR 은 합치지 않았다.

### `<automated>` 종료 코드

| 자리 | 적힌 그대로 | 고친 판 |
|------|-------------|---------|
| Task 1 (커밋 전) | 0 | 해당 없음 |
| Task 1 (Task 1 커밋 뒤) | 0 | 해당 없음 |
| Task 1 다시 (PR 실행 뒤) | 0 | 해당 없음 |
| Task 2 첫째 — push gate (push 전, 따로 한 번 · push 와 이은 사슬에서 한 번) | 0 · 0 | 해당 없음 |
| Task 2 둘째 — 원격 단언 (PR 실행 뒤, metadata 커밋 전) | 0 | 해당 없음 |

세 명령은 계획에서 줄 머리의 `<automated>` 태그만 python `-I` 로 꺼내 내 임시 폴더의 파일로 저장해 `bash -n` 뒤 `bash` 로 돌렸다. 고친 곳은 없다.

## Task Commits

1. **Task 1: 06-REVIEW-DISPOSITION.md — 아홉 발견 fixed · IN-08 deferred** — `0461741` (docs)
2. **Task 2: push gate → push → CI → PR → pull_request 실행** — 커밋 없음 (원격 작업)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 의 커밋 (docs) — push 하지 않는다

## Files Created/Modified

- `.planning/phases/06-release/06-REVIEW-DISPOSITION.md` — frontmatter 아홉 `disposition: fixed` · IN-08 `disposition: deferred`, `open: 0`, 표 열 행

## Decisions Made

- 위 key-decisions 둘. 그 밖은 계획대로.

## Deviations from Plan

None - plan executed exactly as written.

참고(편차 아님): push gate 는 계획대로 push 전에 한 번 돌렸고, push 명령 바로 앞에서 `&&` 로 한 번 더 돌렸다 (orchestrator 지시 — 범위에 Task 1 커밋이 든 뒤 push 직전 재실행). PR 생성 직후의 `mergeStateStatus` 는 `UNSTABLE` 이었고 PR 실행이 끝난 뒤 `CLEAN` 이 되었다 (06-10 과 같음). 작업 트리의 GSD 도구 상태 넷은 스테이징하지 않았다.

## Issues Encountered

- 없음. 네트워크 정지 없음. 임시 파일(검증 명령 사본 셋 · PR 본문)은 내 임시 폴더 안에만 두었고 끝에 지운다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 06-15: PR #3 가 `MERGEABLE` / `CLEAN` 이고 head 는 `0461741` 다. 병합(`gh pr merge 3 --merge`) 직전에 소유자 확인이 필요하다 (blocking-human). 이 plan 의 metadata 커밋은 origin 에 없다 — 그 커밋이 올라가면 PR head 가 바뀌어 실행이 다시 돈다.
- REL-03 · REL-04 표시는 06-15 가 한다.

---
*Phase: 06-release*
*Completed: 2026-10-17*

## Self-Check: PASSED

- 파일: `.planning/phases/06-release/06-REVIEW-DISPOSITION.md` 있음, 이 SUMMARY 있음
- 커밋: `0461741` 이 HEAD, `git rev-list --count 6d8c0b7..HEAD` = 1 (metadata 커밋 전)
- 원격: `origin/gsd/v2.0-package-rework` == `0461741`, run `38934754393` · `38935292307` success, PR #3 open · MERGEABLE / CLEAN
