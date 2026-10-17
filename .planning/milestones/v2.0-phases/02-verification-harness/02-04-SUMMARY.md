---
phase: 02-verification-harness
plan: 04
subsystem: infra
tags: [github-actions, ci, workflow, flutter-action, fvmrc, dart-analyze, verify-script, git-push, riverpod_lint]

# Dependency graph
requires:
  - phase: 02-verification-harness
    provides: "plan 02-02 — 완성된 검증 명령 tool/verify.dart (준비 + 단계 4개 + 버전 3줄, 종료 코드 0 / 1 / 64 / 69 / 70 / 78, D-12 의 SDK 확인과 FLUTTER_ROOT fallback)"
  - phase: 02-verification-harness
    provides: "plan 02-03 — example/README.md 의 기록 절과 CHANGELOG 의 '그 밖의 변경' (둘 다 CI workflow 를 이미 있는 것으로 적어 두었다)"
  - phase: 02-verification-harness
    provides: "plan 02-01 — example/ 연습용 프로젝트와 정답지 (exit 2 + 16줄), 커밋된 example/pubspec.lock"
  - phase: 01-baseline-and-toolchain
    provides: "저장소 고정 SDK (.fvmrc = Flutter 3.47.5), 불변 비교 기준 90a2736 (lib/) · 968a5bb (pubspec.yaml, README.md), push 증거 형식"
provides:
  - "CI workflow .github/workflows/verify.yml — 모든 브랜치의 push · pull_request · 수동 실행에서 검증 명령 한 줄을 돌린다 (읽기 권한, concurrency, timeout 10분, .fvmrc 로 SDK 설치, 캐시 없음)"
  - "origin 의 작업 브랜치 gsd/v2.0-package-rework 가 Phase 2 의 커밋을 담는다 (1ed61cd → 1f06c55, fast-forward 23커밋)"
  - "GitHub Actions 의 성공한 실행 1회 — run 38158088016 (verify, push, 1분 54초, ubuntu-24.04 이미지)"
  - "runner 에서의 첫 전체 실행 기록 — 버전 3줄, 단계 4줄, 요약 줄, 단계별 시간, runner 가 준 환경변수"
affects: [phase-3-presets, phase-4-rules, phase-5-docs, phase-6-release]

# Actuals (#2632)
actuals:
  tokens: 212      # chars/4 — 계획 시작 커밋부터 task 커밋까지의 diff 에서 더한 줄 849자. 새 파일 하나(814자)뿐이다. plan 의 estimate 는 35000 이었다
  tasks: 2
  commits: 1       # MEASURED: git rev-list --count 3669681c3919be88ffa7f11b1340c662dab21f75..HEAD (SUMMARY 작성 시점)
plan_head_before: 3669681c3919be88ffa7f11b1340c662dab21f75
plan_head_after: 1f06c558bcf9d5cf8ef644fba8cd9a006497e83f

# Tech tracking
tech-stack:
  added:
    - "actions/checkout@v7 (최신 v7.0.1, GitHub Actions)"
    - "subosito/flutter-action@v2 (최신 v2.23.0, GitHub Actions)"
  patterns:
    - "workflow 는 로컬과 같은 명령 한 줄을 돌리는 껍데기다 — 판정 로직, pub get, 버전 표시는 전부 스크립트 안에 있다"
    - "workflow 의 주석은 설정 윗줄의 독립 줄로 둔다. 설정 줄은 값으로 끝난다 (줄 끝 주석 없음)"
    - "push 전: fetch → fast-forward 확인 → 브랜치 이름 확인 → 추적 파일 깨끗함 → 올릴 범위의 비밀 패턴 검사. push 뒤: 원격 브랜치 · tag · PR 목록을 원문으로 남긴다"
    - "run 은 올린 커밋의 SHA 로 찾는다 (같은 브랜치의 앞선 run 이 취소로 보일 수 있다)"

key-files:
  created:
    - .github/workflows/verify.yml
  modified: []

key-decisions:
  - "CI workflow 는 .github/workflows/verify.yml 이고 02-RESEARCH.md 권고 9 의 구성 그대로다 — 트리거 셋(push · pull_request · workflow_dispatch, 필터 없음), 권한은 contents: read 뿐, concurrency 로 겹치는 실행 취소, timeout-minutes 10, step 은 checkout → flutter-action(.fvmrc) → 검증 명령 하나. 캐시 · 예약 실행 · Flutter 버전 숫자 · tag 필터 · 별도 pub get step 은 없다"
  - "action 은 major tag 로 쓴다 — actions/checkout@v7 (최신 v7.0.1, 2026-07-20), subosito/flutter-action@v2 (최신 v2.23.0, 2026-03-25). 2026-10-12 에 다시 조회했고 조사 때와 같았다. SHA 고정은 하지 않았다"
  - "작업 브랜치를 origin 에 한 번 올렸다 (2026-10-12 02:04 KST, 1ed61cd → 1f06c55, fast-forward 23커밋). main 은 90a2736, tag 는 v1.3.0 하나 그대로이고 PR 은 없다. 이 계획의 마무리 커밋(SUMMARY · STATE · ROADMAP)은 올리지 않았다 — Phase 3 부터의 push 는 다시 소유자에게 묻는다 (D-09)"
  - "GitHub runner 에서의 첫 전체 실행이 한 번에 성공했다 — run 38158088016, job 1분 54초 (Flutter 설치 60초, 검증 명령 47초 중 example/ 분석 약 44초). 화면은 로컬과 같았다: Flutter 3.47.5 / Dart 3.13.4, flutter_lints 6.0.0 / lints 6.1.0, riverpod_lint 3.1.9, 단계 4개 통과. timeout 10분은 넉넉하다"
  - "runner 는 FLUTTER_ROOT 환경변수를 설치한 SDK 의 자리로 넘겨준다. 그래서 D-12 의 SDK 확인이 1순위 경로(실행 파일에서 다섯 단계 위)로 통과했는지 2순위(FLUTTER_ROOT)로 통과했는지는 이 로그로 가를 수 없다 — 둘 다 같은 SDK 를 가리킨다. 'Flutter SDK 의 dart 가 아니다' 안내 경로는 여전히 실행해 보지 못했다"
  - "run 에 예고가 붙었다 — ubuntu-latest 라벨이 2026-10-19 부터 Ubuntu 26 으로 옮겨 간다. 이번 실행의 이미지는 ubuntu-24.04 다. 옮겨 간 뒤의 첫 실행은 새 환경에서의 첫 실측이 된다"
  - "pull_request 트리거와 수동 실행 버튼은 선언만 했고 일으켜 보지 않았다 — PR 은 열지 않고 (D-10), 버튼은 workflow 파일이 main 에 들어간 뒤에야 보인다 (D-06)"

patterns-established:
  - "원격에 쓰는 일의 기록은 실행한 명령 한 줄, 출력 원문, 앞뒤 SHA, 시각(UTC)을 함께 둔다"
  - "CI 실행의 기록은 run id · 주소 · 결론 · 시간 · runner 이미지와, 로그에서 뽑은 화면 원문을 둔다"

requirements-completed: [VERIFY-04]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "CI workflow 파일이 권고 9 의 구성 그대로다 — 트리거 셋, contents: read, concurrency, timeout-minutes 10, action 두 개, .fvmrc 로 SDK 설치, 검증 명령 한 줄. 예약 실행 · 캐시 · 버전 숫자 · matrix · tag 필터가 없다"
    requirement: "VERIFY-04"
    verification:
      - kind: other
        ref: "Task 1 의 automated verify — 설정 줄 17개를 줄 전체로 재는 grep, 주석을 뺀 본문의 uses 2개 · run 1개, 금지 문자열 0, 파일 끝 개행, 루트 fvm dart analyze 의 No issues found, lib 와 pubspec.yaml · README.md 불변 (rc=0, 커밋 전)"
        status: pass
    human_judgment: false
  - id: D2
    description: "작업 브랜치가 git push origin 에 브랜치 이름 하나만 준 명령 한 줄로 origin 에 올라갔고, main 은 90a2736 그대로이며 tag 는 v1.3.0 하나뿐이고 PR 이 없다"
    requirement: "VERIFY-04"
    verification:
      - kind: e2e
        ref: "Task 2 의 automated verify — ls-remote --heads 2줄, main = 90a2736, 원격 tip 이 HEAD 의 조상이고 workflow · 스크립트 · 정답지 · README 네 파일을 담음, tag 2줄(v1.3.0 과 그 peeled 줄), gh pr list 0건 (rc=0, 2026-10-11T17:07:03Z)"
        status: pass
    human_judgment: false
  - id: D3
    description: "GitHub 에서 올린 커밋의 verify 실행이 completed / success 로 끝났고, 로그에 버전 3줄 · 단계 4줄(모두 통과) · '점검 통과 (4개 중 4개)' 가 있다"
    requirement: "VERIFY-04"
    verification:
      - kind: e2e
        ref: "gh run view 38158088016 — conclusion success, headSha 1f06c558…, job verify 1분 54초. 로그의 '검증' step 원문은 아래 (4)"
        status: pass
    human_judgment: false
  - id: D4
    description: "runner 에서 D-12 의 SDK 확인이 통과하고 (종료 코드 78 이 아님) 전체 스크립트가 timeout 10분 안에 끝난다 (조사 문서의 가정 A1 · A3)"
    verification:
      - kind: e2e
        ref: "같은 run — '검증' step 이 17:05:18Z 에 시작해 17:06:05Z 에 끝남 (47초), 첫 화면 줄이 'SDK        Flutter 3.47.5 / Dart 3.13.4'"
        status: pass
    human_judgment: false
  - id: D5
    description: "pull request 를 열면 같은 workflow 가 돌고, workflow 파일이 main 에 들어간 뒤 GitHub 화면에 수동 실행 버튼이 보인다"
    requirement: "VERIFY-04"
    verification: []
    human_judgment: true
    rationale: "두 트리거는 파일에 선언되어 있지만 이 phase 에서는 일으킬 수 없다 — PR 은 열지 않기로 했고 (D-10), 수동 실행 버튼은 기본 브랜치에 파일이 있어야 보인다 (D-06). 필터 없는 pull_request 가 모든 base 브랜치의 PR 에서 도는지는 문서가 직접 말하지 않은 가정이다 (조사 문서의 A5). Phase 6 에서 처음 확인된다"

# Metrics
duration: 7min
completed: 2026-10-12
status: complete
---

# Phase 2 Plan 04: GitHub Actions 로 검증 명령 돌리기 Summary

**`.github/workflows/verify.yml` 이 push · PR · 수동 실행에서 검증 명령(`tool/verify.dart`) 한 줄을 돌리고, 작업 브랜치를 origin 에 올린 첫 실행(run 38158088016)이 1분 54초에 단계 4개 통과로 끝났다**

쉬운 말로: 로컬에서 돌리던 검증 명령을 이제 GitHub 이 대신 돌려 준다. 작업 중인 브랜치를 GitHub 에 올렸고(같은 브랜치에 커밋을 더 올린 것이다), 올리자마자 GitHub 이 새 가상 컴퓨터에서 같은 검증을 돌려 "점검 통과" 를 냈다. `main` 과 릴리스 이름표(tag)는 건드리지 않았다.

## Performance

- **Duration:** 7 min
- **Started:** 2026-10-11T17:01:52Z (2026-10-12 02:01 KST)
- **Completed:** 2026-10-11T17:08:30Z (2026-10-12 02:08 KST)
- **Tasks:** 2
- **Files modified:** 1 (새 파일 `.github/workflows/verify.yml`, 35줄)
- **push:** 1회. 실패 · 재시도 · 고친 커밋 없음

## Accomplishments

- CI workflow 를 만들었다. 모든 브랜치의 push, pull request, 수동 실행에서 검증 명령 한 줄을 돌리고, 저장소를 읽기만 하며, 같은 브랜치에 새로 올리면 앞선 실행을 취소하고, 10분이 넘으면 끊는다.
- SDK 는 `.fvmrc` 하나로 맞춘다. workflow 에 Flutter 버전 숫자가 없다.
- 작업 브랜치를 origin 에 올렸다 (`1ed61cd` → `1f06c55`, fast-forward). 올라간 커밋은 23개다.
- GitHub 의 `verify` 실행이 그 커밋에서 성공했다. 화면의 버전 3줄과 단계 4줄이 로컬과 같았다.
- `main` (`90a2736`), tag (`v1.3.0` 하나), PR (없음) 은 그대로다.
- 02-03 이 미리 적어 둔 두 문장 — `CHANGELOG.md` 의 "GitHub Actions workflow 를 추가" 와 `example/README.md` 의 "CI 에서는 FVM 없이 … 로 돌린다. SDK 는 `.fvmrc` 의 버전으로 맞춘다" — 이 이제 저장소와 맞는다. workflow 의 명령과 SDK 를 맞추는 방법이 그 문장 그대로라 README 는 고치지 않았다.

## Task Commits

1. **Task 1: CI workflow 파일 작성** — `1f06c55` (ci)
2. **Task 2: 브랜치 push 와 GitHub 실행 확인** — 커밋 없음 (추적 파일을 바꾸지 않는다. 원격 ref `refs/heads/gsd/v2.0-package-rework` 만 앞으로 갔다)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP · REQUIREMENTS 를 담는 마무리 커밋 (docs). push 뒤에 만들어지므로 origin 에는 없다.

## Files Created/Modified

- `.github/workflows/verify.yml` — CI workflow. 트리거 셋, 읽기 권한, concurrency, timeout 10분, checkout → flutter-action(`.fvmrc`) → 검증 명령

## (1) action 버전 확인

2026-10-11T17:01:58Z (2026-10-12 02:01 KST) 에 조회했다.

```text
$ gh api repos/actions/checkout/releases/latest --jq .tag_name
v7.0.1  published_at=2026-07-20T15:10:05Z
$ gh api repos/subosito/flutter-action/releases/latest --jq .tag_name
v2.23.0  published_at=2026-03-25T10:34:12Z
$ gh api repos/actions/checkout/git/ref/tags/v7
refs/tags/v7 3d3c42e5aac5ba805825da76410c181273ba90b1 commit
$ gh api repos/subosito/flutter-action/git/ref/tags/v2
refs/tags/v2 1a449444c387b1966244ae4d4f8c696479add0b2 commit
```

- 출력의 `published_at` 은 같은 응답에서 함께 뽑은 값이다 (jq 식에 필드를 하나 더했다).
- major 가 조사 때와 같다 (`v7`, `v2`). major tag 가 가리키는 커밋도 조사 문서에 적힌 값과 같다. workflow 는 major tag 를 쓰고 SHA 로 고정하지 않았다.
- `flutter-action` 의 `v2` 입력 정의를 다시 읽었다: `channel` 기본 `stable`, `cache` 기본 `"false"`, `pub-cache` 기본 빈 값. workflow 는 캐시 입력을 주지 않는다.

## (2) push 전 — 원격 상태와 올린 것

계획의 precondition 을 적힌 그대로 돌렸다 (2026-10-11T17:03:22Z).

```text
$ git fetch origin --quiet
rc=0
$ git merge-base --is-ancestor origin/gsd/v2.0-package-rework HEAD
rc=0
$ git rev-parse --abbrev-ref HEAD
gsd/v2.0-package-rework
$ git status --short --untracked-files=no -- . ':(exclude).planning'
(출력 없음, rc=0)
$ gh auth status          # token 줄은 뺐다
github.com
  ✓ Logged in to github.com account woodkill (keyring)
  - Active account: true
  - Git operations protocol: https
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
```

```text
$ git remote -v
origin	git@github.com:woodkill/woody_lints.git (fetch)
origin	git@github.com:woodkill/woody_lints.git (push)
$ git ls-remote --heads origin
1ed61cd904eebad1a7b6fdb6e5e80edf9029f179	refs/heads/gsd/v2.0-package-rework
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
$ git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
$ git rev-parse HEAD
1f06c558bcf9d5cf8ef644fba8cd9a006497e83f
```

- `gh` 의 "Git operations protocol: https" 는 `gh` 가 스스로 git 을 부를 때의 설정이다. 이 push 는 `origin` 의 SSH 주소로 나갔다.
- push 관련 git 설정(`push.default`, `push.followTags`, `remote.pushDefault`, `remote.origin.push`, 브랜치의 upstream)은 모두 설정되어 있지 않다. 그대로 두었다.

올린 것 — 23커밋 (`git log --oneline origin/gsd/v2.0-package-rework..HEAD`):

```text
1f06c55 ci(02-04): 검증 명령을 돌리는 GitHub Actions workflow 추가
3669681 docs(02-03): 02-03 계획 완료 — 지워 보기 9건의 기록과 CHANGELOG 의 그 밖의 변경
2a9725e docs(02-03): example/README.md 에 검증 기록을 쓰고 CHANGELOG 에 그 밖의 변경 추가
0dcb71f docs(02-02): 02-02 계획 완료 — 검증 명령의 단계 4개, 버전 3줄, 안내형 화면
19ae5ec feat(02-02): tool/verify.dart 에 버전 표시와 안내형 화면 추가
d707988 feat(02-02): tool/verify.dart 에 SDK 확인과 단계 1~3 추가
f71bc40 docs(02-01): SUMMARY 의 백틱 표기를 고쳐 verify-summary 오탐 5건을 없앰
f7c0e49 docs(02-01): 02-01 계획 완료 — example/ 정답지 16줄과 tool/verify.dart 의 비교 경로
74fafb2 feat(02-01): example/ 위반 샘플을 규칙 12개 + plugin 3건 + 나오면 안 되는 샘플로 확장
ac5cced feat(02-01): 검증용 example/ 과 tool/verify.dart 의 정답지 비교 경로 추가
6b416c6 docs(02): Phase 2 는 외부 API 연동이 없음을 선언 (02-COVERAGE.md)
dc36b8c docs(02): Phase 2 계획 완료를 STATE 에 기록
2624366 docs(02): 02-04 workflow 주석을 설정 윗줄로 통일하고 verify 의 pubspec.yaml 기준 커밋을 Phase 1 의 968a5bb 로 고침
27aa26d docs(02): checker 지적에 따라 Phase 2 계획 수정 (verify 종료 코드 구조, stdout 판정, 범위 근거, Open Questions 해소)
4405f6a docs(02): Phase 2 실행 계획 4개 작성 (example/ 정답지, tool/verify.dart, 지워 보기 기록, CI)
e548166 docs(02): Phase 2 패턴 문서(PATTERNS.md) 작성
26a63d9 docs(02): Phase 2 검증 계획 문서(VALIDATION.md) 작성
d6d8078 docs(02): Phase 2 검증 하네스 조사 문서 작성
3dc1884 docs(spike-wrap-up): spike 007, 008 의 실측 결과를 프로젝트 skill 에 반영
532607b docs(spikes): spike 007, 008 에서 굳어진 관례 반영
51afa9a docs(spike-008): VALIDATED — md5 없이 plugin 버전을 읽으려면 전용 상태 폴더를 준다
775f2a7 docs(spike-007): VALIDATED — 루트에 example/ 이 생기면 루트 분석에 섞이고, example/** 제외 한 줄로 막힌다
cd76cc8 docs(spike-wrap-up): spike 6개의 실측 결과를 프로젝트 skill 로 묶음
```

`.planning/` 밖에서 이 범위가 바꾼 파일: `.github/workflows/verify.yml`, `tool/verify.dart`, `example/` 12개, `.gitignore`, `CHANGELOG.md`, 루트 `analysis_options.yaml`, `.claude/CLAUDE.md` (수정), 그리고 `.claude/skills/spike-findings-woody-lints/` 아래 58개 (새 파일 — spike 기록을 묶은 프로젝트 skill 과 그 읽기용 사본).

push 전에 올릴 범위를 검사했다.

- 비밀 패턴(GitHub · AWS · Slack · Google 토큰 꼴, 개인 키 머리말, workflow 의 secrets 참조)을 이 계획의 커밋과 23커밋 전체의 diff · 커밋 메시지에서 찾았다: 0건.
- `.env` · 키 파일 이름: 없음.
- 로컬 절대 경로가 든 더한 줄: 2줄, 둘 다 `02-RESEARCH.md` (하나는 FVM 이 설치한 dart 의 경로, 하나는 D-08 의 공개 범위를 옮겨 적은 문장). D-08 이 받아들인 종류다. 이 계획이 만든 workflow 파일에는 없다.
- `.claude/skills/spike-findings-woody-lints/` 는 D-08 이 논의 때 적은 공개 범위 목록(`.planning/`, `.claude/CLAUDE.md`, `VERSIONING.md`)에는 없던 폴더다. 그 뒤 spike wrap-up 커밋이 만든 것이고 내용은 이미 공개된 `.planning/spikes/` 의 요약과 사본이다. D-08 의 "브랜치를 그대로 올린다" 에 따라 함께 올라갔다.

## (3) push

```text
$ git push origin gsd/v2.0-package-rework
To github.com:woodkill/woody_lints.git
   1ed61cd..1f06c55  gsd/v2.0-package-rework -> gsd/v2.0-package-rework
rc=0
```

- 시각: 2026-10-11T17:04:05Z 에 시작해 17:04:09Z 에 끝났다 (2026-10-12 02:04 KST).
- 원격 브랜치: `1ed61cd904eebad1a7b6fdb6e5e80edf9029f179` → `1f06c558bcf9d5cf8ef644fba8cd9a006497e83f`.
- 명령은 위의 한 줄이고 한 번만 실행했다. 실행할 때 환경변수 `GIT_TERMINAL_PROMPT=0` 을 앞에 붙였다 — 인증 창이 뜨면 기다리지 않고 실패로 끝나게 하려는 것이고, 무엇이 올라가는지는 바꾸지 않는다. 인증 요청은 없었다.
- `[rejected]` 없음. force 계열 · `--tags` · `--all` · `-u` · 다른 브랜치 · tag 는 쓰지 않았다.

## (4) GitHub 실행

| 항목 | 값 |
|---|---|
| run id | 38158088016 |
| 주소 | https://github.com/woodkill/woody_lints/actions/runs/38158088016 |
| workflow / event | verify / push |
| 브랜치 / 커밋 | gsd/v2.0-package-rework / 1f06c558bcf9d5cf8ef644fba8cd9a006497e83f |
| 상태 / 결론 | completed / success (attempt 1) |
| 만들어진 시각 | 2026-10-11T17:04:11Z (push 가 끝난 2초 뒤) |
| job `verify` | 17:04:14Z ~ 17:06:08Z — 1분 54초 (`gh run list` 의 run 전체 시간은 1분 57초) |
| runner 이미지 | ubuntu-24.04, 20261004.327.1 |

```text
$ gh run list --workflow verify.yml --limit 5
completed	success	ci(02-04): 검증 명령을 돌리는 GitHub Actions workflow 추가	verify	gsd/v2.0-package-rework	push	38158088016	1m57s	2026-10-11T17:04:11Z
```

이 workflow 의 run 은 이것 하나다. 취소된 run 은 없다.

step 별 시간 (`gh run view --json jobs`):

| step | 시작 → 끝 (UTC) | 걸린 시간 |
|---|---|---|
| Set up job | 17:04:15 → 17:04:16 | 1초 |
| actions/checkout@v7 | 17:04:16 → 17:04:18 | 2초 |
| subosito/flutter-action@v2 | 17:04:18 → 17:05:18 | 60초 |
| 검증 | 17:05:18 → 17:06:05 | 47초 |
| 뒷정리 | 17:06:06 | 1초 미만 |

로그의 "검증" step 원문 (`gh run view 38158088016 --log`, 색 제어 문자는 뺐다):

```text
2026-10-11T17:05:18.7445945Z ##[group]Run dart run tool/verify.dart
2026-10-11T17:05:18.7446357Z dart run tool/verify.dart
2026-10-11T17:05:18.7512094Z shell: /usr/bin/bash -e {0}
2026-10-11T17:05:18.7512417Z env:
2026-10-11T17:05:18.7512772Z   FLUTTER_ROOT: /opt/hostedtoolcache/flutter/stable-3.47.5-x64/flutter
2026-10-11T17:05:18.7513185Z   PUB_CACHE: /home/runner/.pub-cache
2026-10-11T17:05:18.7513455Z ##[endgroup]
2026-10-11T17:05:21.5256302Z example/ 분석 중…
2026-10-11T17:06:05.9743307Z SDK        Flutter 3.47.5 / Dart 3.13.4
2026-10-11T17:06:05.9746091Z 기반 세트  flutter_lints 6.0.0 / lints 6.1.0
2026-10-11T17:06:05.9746774Z plugin     riverpod_lint 3.1.9
2026-10-11T17:06:05.9747133Z 
2026-10-11T17:06:05.9747455Z [1/4] lib/ 에 .dart 파일 없음 .......... 통과
2026-10-11T17:06:05.9748019Z [2/4] 배포 파일의 규칙 이름 ............ 통과
2026-10-11T17:06:05.9749021Z [3/4] example/ 옵션 파일 ............... 통과
2026-10-11T17:06:05.9749592Z [4/4] example/ 정답지 비교 ............. 통과
2026-10-11T17:06:05.9755921Z 
2026-10-11T17:06:05.9756647Z 점검 통과 (4개 중 4개)
```

로그에서 읽히는 것.

- **버전 3줄이 로컬과 같다.** `.fvmrc` 하나로 Flutter 3.47.5 / Dart 3.13.4 가 설치됐고 (`flutter-action` 이 받은 입력은 `flutter-version-file: .fvmrc`, 설치 자리는 `stable-3.47.5-x64`), 기반 세트는 커밋된 lock 그대로이며, plugin 은 `riverpod_lint` 3.1.9 로 풀렸다.
- **plugin 줄은 이번 실행에서 생긴 값이다.** runner 는 저장소를 새로 받으므로 전용 상태 폴더가 비어 있는 채로 시작했다. 02-03 이 적은 "남아 있던 값을 읽는다" 는 경우가 아니다. `[4/4]` 가 통과했으므로 정답지의 `riverpod_lint` 3줄도 나왔다.
- **시간.** 준비(SDK 확인 · pub get 2회)와 단계 1 ~ 3 이 약 3초 (17:05:18 → "example/ 분석 중…" 17:05:21), `example/` 분석이 약 44초 (17:05:21 → 17:06:05) 다. spike 006 이 잰 첫 분석 약 43초와 같은 크기다. job 전체 1분 54초는 spike 006 의 약 2분과 같고, timeout 10분의 5분의 1 이다 (조사 문서의 가정 A3 — 넉넉하다).
- **D-12 의 SDK 확인이 통과했다** (조사 문서의 가정 A1). 종료 코드 78 이 아니고 첫 화면 줄이 `SDK` 줄이다. 다만 **어느 경로로 통과했는지는 이 로그로 가를 수 없다.** runner 는 `FLUTTER_ROOT` 를 설치한 SDK 의 자리로 넘겨주므로, 1순위(실행 파일에서 다섯 단계 위의 `flutter.version.json`)가 통했든 2순위(`FLUTTER_ROOT`)가 받았든 같은 SDK 의 같은 값이 나온다. 스크립트는 어느 쪽이었는지 화면에 찍지 않는다. `flutter-action` 이 PATH 에 두는 `dart` 가 SDK 안의 `bin/cache/dart-sdk/bin/dart` 를 띄운다면 1순위가 통했을 것이라는 것은 추론이지 이 실행으로 확인한 것이 아니다.
- **stderr.** 로그에 섞여 보이는 stderr 줄은 진행 표시 "example/ 분석 중…" 하나다. plugin 준비 실패의 머리말은 없다 (있었다면 `[4/4]` 가 실패한다).
- **예고(annotation) 하나.** `The ubuntu-latest label will migrate to Ubuntu 26 beginning October 19, 2026.` (https://github.com/actions/runner-images/issues/14748). 이번 실행의 이미지는 ubuntu-24.04 다. workflow 는 `ubuntu-latest` 를 쓰므로 그 뒤의 실행은 Ubuntu 26 에서 돈다 — spike 006 과 이 실행이 잰 환경이 아니다.

## (5) push 뒤 — 원격 확인

2026-10-11T17:07:03Z (2026-10-12 02:07 KST).

```text
$ git ls-remote --heads origin
1f06c558bcf9d5cf8ef644fba8cd9a006497e83f	refs/heads/gsd/v2.0-package-rework
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
$ git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
$ gh pr list --state all --limit 5
(출력 없음, rc=0)
$ gh pr list --state all --limit 5 --json number --jq length
0
$ gh run list --limit 5
completed	success	ci(02-04): 검증 명령을 돌리는 GitHub Actions workflow 추가	verify	gsd/v2.0-package-rework	push	38158088016	1m57s	2026-10-11T17:04:11Z
completed	success	docs(spikes): spike 관례 문서 추가	spike-006-cold-plugin	gsd/v2.0-package-rework	push	38136362920	5m41s	2026-10-11T11:45:31Z
```

- 원격 브랜치는 정확히 두 개다. `main` 은 `90a2736` 그대로, 작업 브랜치는 올린 커밋이다.
- tag 는 `v1.3.0` 의 두 줄(tag 객체와 그것이 가리키는 커밋)뿐이다. 새 tag 가 올라가지 않았다.
- PR 은 열려 있는 것도 닫힌 것도 없다.

## (6) 실패 · 재시도

없다. push 1회, run 1회, 첫 시도에 성공했다. 계획이 준비해 둔 복구 경로(종료 코드 78 의 경로 탐색 수정, `gh run rerun`, 정답지 불일치의 멈춤, timeout 초과의 멈춤)는 하나도 쓰지 않았다.

## 검증 (커밋 전 · 뒤)

Task 1 의 커밋 전.

```text
Task 1 automated verify      → rc=0
$ fvm dart analyze           → No issues found!
$ fvm dart run tool/verify.dart
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

점검 통과 (4개 중 4개)
rc=0
```

- workflow 파일을 YAML 로 읽어 구조를 확인했다 (ruby 의 YAML 파서): 최상위 키 `name` · `on` · `permissions` · `concurrency` · `jobs`, step 3개, `timeout-minutes` 는 숫자 10, `cancel-in-progress` 는 참. 탭 문자와 줄 끝 공백은 없다. 설정 줄 끝의 주석도 없다.
- Task 1 의 커밋 뒤, push 전: 원격 브랜치는 `1ed61cd` 였다 (위 (2) 의 `ls-remote`) — 이 task 는 push 하지 않았다.
- Task 2 의 automated verify → rc=0 (2026-10-11T17:07:03Z). 원격 tip 과 로컬 HEAD 가 모두 `1f06c55` 였다.
- `lib/` 는 `90a2736` 과, `pubspec.yaml` · 루트 `README.md` 는 `968a5bb` 와 같다.

## Decisions Made

- workflow 의 구성과 주석 문구는 계획이 적은 그대로다 (02-RESEARCH.md 권고 9, 줄 끝 주석 셋을 윗줄로 옮긴 형태).
- action 은 major tag (`v7`, `v2`). 오늘 다시 조회한 최신이 조사 때와 같아 바꿀 것이 없었다.
- `example/README.md` 의 CI 문장은 고치지 않았다 — 올린 workflow 의 명령과 SDK 를 맞추는 방법이 그 문장과 같다.
- 마무리 커밋은 올리지 않는다. 계획이 "push 뒤에 생기므로 origin 에는 없다 — 정상" 으로 정했고 VERIFY-04 는 성공한 실행 한 번으로 채워졌다.

## Deviations from Plan

None - plan executed exactly as written.

계획에 없던 확인을 몇 가지 더 했다 (결과를 바꾸지 않는다): workflow 파일의 YAML 파싱, 올릴 범위의 비밀 패턴 · 절대 경로 검사, major tag 가 가리키는 커밋 조회, push 관련 git 설정 조회.

## Issues Encountered

None.

## 확인하지 못한 것

- **pull request 에서의 실행.** 트리거는 선언되어 있지만 PR 을 열지 않았다 (D-10). 필터 없는 `pull_request` 가 모든 base 브랜치의 PR 에서 도는지는 문서가 직접 말하지 않은 가정이다.
- **수동 실행 버튼.** workflow 파일이 `main` 에 들어간 뒤에야 보인다 (D-06). 이 phase 에서는 볼 수 없다.
- **tag push 에서의 실행.** `push` 에 필터가 없으므로 tag 를 올려도 이 workflow 가 돈다 (GitHub 문서의 서술). 일으켜 보지 않았다. workflow 의 주석 "tag 트리거는 Phase 6 (REL-03)" 은 계획이 정한 문구 그대로인데, "지금은 tag 에서 돌지 않는다" 로 읽힐 수 있다 — 실제로는 돌고, Phase 6 이 더하는 것은 tag 전용 검사다.
- **D-12 가 runner 에서 통과한 경로** (1순위인지 `FLUTTER_ROOT` 인지), 그리고 Flutter SDK 가 아닌 dart 로 실행했을 때의 안내. 위 (4) 참조.
- **실패하는 CI 실행.** 성공한 실행만 있다. runner 에서 단계가 실패했을 때의 화면, 종료 코드 69 가 옮기는 pub 의 stderr 에 runner 의 경로가 어떻게 보이는지는 보지 않았다.
- **`concurrency` 의 취소.** 같은 브랜치에 연달아 올리지 않았으므로 취소되는 run 을 보지 않았다.
- **Ubuntu 26 runner.** 2026-10-19 뒤의 `ubuntu-latest`.
- **run 을 다시 돌렸을 때** (재시도, 다른 시각)의 결과. 한 번 돌렸다. spike 006 의 60번 중 60번에 기댄다.

## Threat 처리

| Threat | 처리 |
|---|---|
| T-02-09 (mitigate) — 서드파티 action 공급망 | action 은 `actions/checkout` 과 `subosito/flutter-action` 둘뿐이고 major tag 다. 오늘 릴리스와 major tag 의 커밋을 다시 조회했다 ((1)). 토큰 권한은 읽기뿐이다 |
| T-02-10 (mitigate) — `GITHUB_TOKEN` 권한 | `permissions:` 에 `contents: read` 한 줄만 있다. Task 1 verify 의 grep 이 통과했다 |
| T-02-11 (mitigate) — runner 시간 | `timeout-minutes: 10`, `cancel-in-progress: true`. 실제 job 은 1분 54초였다 |
| T-02-12 (accept) — `.planning/` 등의 공개 | D-08 로 받아들인 것이다. 올릴 범위에서 비밀 패턴 0건을 확인했다. D-08 의 목록에 없던 `.claude/skills/` 폴더가 함께 올라간 것은 (2) 에 적었다 |
| T-02-13 (mitigate) — 잘못된 push | 명령은 브랜치 이름 하나만 준 한 줄, 한 번. precondition 통과 뒤에 실행했고 push 뒤 heads 2줄 · `main` = `90a2736` · tag = `v1.3.0` 뿐임을 확인했다 |
| T-02-SC (accept) | runner 가 받은 것은 커밋된 lock 의 패키지와 `riverpod_lint` 3.1.9 다. 저장소 `pubspec.yaml` 은 바뀌지 않았다 |

새로 생긴 표면은 계획의 threat model 이 든 것뿐이다. `actions/checkout` 은 기본값대로 `persist-credentials: true` 로 돌았다 (로그에 보인다) — 읽기 전용 토큰이 job 이 끝날 때까지 runner 의 git 설정에 남는다는 뜻이고, 이 workflow 에는 그 뒤에 도는 서드파티 step 이 `flutter-action` 하나다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Phase 2 의 plan 4개가 모두 끝났다.** 검증 명령이 로컬과 GitHub 양쪽에서 같은 결과를 낸다.

**origin 에 없는 것 (로컬에만 있다):**

- 이 계획의 마무리 커밋 (이 SUMMARY, STATE, ROADMAP, REQUIREMENTS). 다음에 브랜치를 올릴 때 함께 올라간다.
- Phase 3 부터의 push 는 D-09 의 범위 밖이다 — 다시 소유자에게 묻는다.

**뒤 phase 가 알아야 할 것:**

- 브랜치에 커밋을 올릴 때마다 CI 가 돈다. Phase 3 · 4 가 `lib/` 를 바꾸고 올리면 정답지와 다를 때 CI 가 빨갛게 된다 — 그것이 하네스의 목적이다. 정답지를 일부러 바꾼 커밋은 로컬에서 `--update` 로 갱신해 함께 올린다 (CI 는 `--update` 를 거부한다).
- workflow 는 `ubuntu-latest` 를 쓴다. 2026-10-19 뒤 첫 실행이 실패하면 저장소 변경보다 runner 이미지 변경을 먼저 의심한다 (run 의 "Set up job" 로그에 이미지 이름이 찍힌다).
- Phase 6 (REL-03) 이 tag 트리거와 버전 일치 검사를 더한다. 지금도 tag push 에서 workflow 가 돈다는 점을 그때 함께 본다.
- `riverpod_lint` plugin 의 버전은 묶여 있지 않다. 새 3.x 가 나와 정답지의 plugin 줄이 달라지면 저장소 변경 없이 CI 가 실패한다 — 화면의 `plugin` 줄이 원인을 보여 준다 (Phase 3 의 D6 이 묶을지 정한다).

## Self-Check: PASSED

```text
FOUND: .github/workflows/verify.yml
FOUND: 1f06c55                      (HEAD 의 조상)
ON ORIGIN: 1f06c55                  (origin/gsd/v2.0-package-rework 의 조상)
check evaluation-scope --plan 02-04 --commits-only → status resolved, commits 1개 (1f06c55)
stub 검색 (TODO / FIXME / placeholder) → 없음
Task 1 · Task 2 의 automated verify → 둘 다 rc=0
```

---
*Phase: 02-verification-harness*
*Completed: 2026-10-12*
