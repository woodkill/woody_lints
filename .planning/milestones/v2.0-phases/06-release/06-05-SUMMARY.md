---
phase: 06-release
plan: 05
subsystem: release
tags: [release, git-tag, annotated-tag, github-actions, smoke-test, riverpod_lint]

requires:
  - phase: 06-release
    provides: "06-04 의 예행 통과 커밋 704bf56 (= origin/gsd/v2.0-package-rework), CI run 38690710677 success, 06-03 의 tool/smoke.dart, 06-01 의 tag 모드 (GITHUB_REF_NAME)"
provides:
  - "원격 annotated tag v2.0.0 (tag 객체 753f520…) → 릴리스 커밋 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2"
  - "tag push 의 GitHub verify 실행 38844667011 success — 로그에 `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` · `점검 통과 (10개 중 10개)`"
  - "tag smoke `fvm dart run tool/smoke.dart v2.0.0` rc 0 — resolved-ref == v2.0.0^{commit}, 두 주소 각각 규칙 · plugin 진단"
  - "README 손 따라 하기 (05-UAT 1번) — 막힌 자리 없음, 작은 점 둘 (문서만)"
affects: [06-06 PR · main 병합, 06-07 처리 기록 (05-UAT 1번)]

actuals:
  tokens: 0
  tasks: 3
  commits: 0
plan_head_before: 5076ed5f295a1480075ce66ef48b418ff2351d44
plan_head_after: 5076ed5f295a1480075ce66ef48b418ff2351d44

tech-stack:
  added: []
  patterns:
    - "tag 를 달 커밋 = 예행 통과 커밋 = origin 의 작업 브랜치 머리 — 4중 점검을 확인 요청 앞에, push 는 소유자의 `tag` 뒤 tag 이름 하나만"
    - "tag 실행은 `headBranch` 가 tag 이름 (`v2.0.0`) 인 push 실행으로 고른다 — VERSIONING 「릴리스 절차」 6번과 같다"

key-files:
  created: []
  modified: []

key-decisions:
  - "소유자 응답 `tag` (2026-10-16T03:15:24Z) 뒤에만 `git push origin v2.0.0` — tag v2.0.0 은 704bf56 을 가리키고 옮기거나 지우지 않는다 (잘못이면 v2.0.1)"
  - "README 손 따라 하기의 작은 점 둘 (넣는 자리에 따른 sort_pub_dependencies, 「설치」 블록이 dev_dependencies 머리 줄까지 보여 줌) 은 문서만의 문제로 보고 tag 를 그대로 올렸다 — 나중에 README 만 고치며 새 번호가 필요 없다"

patterns-established:
  - "tag 실행 확인: gh run list --event push 에서 headSha == 릴리스 커밋 · headBranch == tag 이름 → gh run watch --exit-status → 로그의 tag 모드 줄"

requirements-completed: [REL-02, REL-03, REL-04]

coverage:
  - id: D1
    description: "로컬 annotated tag v2.0.0 이 예행 통과 커밋 704bf56 을 가리키고 4중 점검 넷이 통과했으며, 그때 원격에는 v2.0.0 이 없었다"
    requirement: "REL-02"
    verification:
      - kind: integration
        ref: "06-05-PLAN.md Task 1 <automated> (tag 생성 뒤, 확인 요청 전)"
        status: pass
    human_judgment: false
  - id: D2
    description: "git ls-remote --tags origin 4줄에 `704bf56…<TAB>refs/tags/v2.0.0^{}`, --heads 둘 그대로 (main = 90a2736), tag 의 version · CHANGELOG 1행이 2.0.0"
    requirement: "REL-02"
    verification:
      - kind: integration
        ref: "06-05-PLAN.md Task 3 <automated> (push · CI · smoke 뒤)"
        status: pass
    human_judgment: false
  - id: D3
    description: "tag push 의 verify 실행 38844667011 (headBranch v2.0.0) success, 로그에 tag 모드 줄 · [3/10] 통과 · 10/10"
    requirement: "REL-03"
    verification:
      - kind: integration
        ref: "06-05-PLAN.md Task 3 <automated> (gh run view --log)"
        status: pass
    human_judgment: false
  - id: D4
    description: "fvm dart run tool/smoke.dart v2.0.0 rc 0 — 빈 프로젝트가 ref: v2.0.0 으로 받아 두 주소 각각 prefer_single_quotes · provider_parameters, resolved-ref == 704bf56"
    requirement: "REL-04"
    verification:
      - kind: integration
        ref: "fvm dart run tool/smoke.dart v2.0.0 (03:16:34Z, rc 0) 와 06-05-PLAN.md Task 3 <automated> 안의 재실행"
        status: pass
    human_judgment: false
  - id: D5
    description: "README 를 사람이 따라 할 수 있는지 (05-UAT 1번) — orchestrator 가 README 대로 돌리고 소유자가 화면을 보았다; 막힌 자리 없음"
    requirement: "REL-04"
    verification:
      - kind: manual_procedural
        ref: "Task 2 확인 요청의 README 손 따라 하기 (1) ~ (6), 2026-10-16T03:11:51Z ~ 03:12:34Z"
        status: pass
    human_judgment: true
    rationale: "문서를 사람이 그대로 따라 할 수 있는지는 소유자가 화면을 보고 판단했다 — 스크립트가 대신할 수 없는 확인 (D-10)"

duration: 약 8분 (작업 시간 — 소유자 응답 대기 약 19시간 제외)
completed: 2026-10-16
status: complete
---

# Phase 6 Plan 05: tag v2.0.0 · 소유자 확인 · tag 확인 Summary

**예행 통과 커밋 `704bf56` 에 annotated tag `v2.0.0` 을 달고 4중 점검을 했다. 소유자의 `tag` 응답 뒤 `git push origin v2.0.0` 한 줄로 tag 이름 하나만 GitHub 에 올렸다. 원격의 `refs/tags/v2.0.0^{}` 가 릴리스 커밋이다. tag push 가 만든 `verify` 실행(`headBranch` `v2.0.0`)은 tag 모드 줄과 함께 10/10 으로 통과했다. 빈 프로젝트도 `ref: v2.0.0` 으로 받아 두 주소 모두에서 규칙 진단과 plugin 진단을 냈다.**

## Performance

- **Duration:** 작업 약 8분 (Task 1 약 2분, Task 3 약 6분). 소유자 응답을 기다린 시간(2026-10-15T08:18Z ~ 2026-10-16T03:15Z)은 빼고 셌다.
- **Started:** 2026-10-15T08:16:22Z
- **Completed:** 2026-10-16T03:21:49Z (Task 3 `<automated>` 끝)
- **Tasks:** 3 (auto · checkpoint:decision · auto)
- **Files modified:** 0 (저장소 추적 파일 기준. 생긴 것은 git ref `refs/tags/v2.0.0` 뿐이다)

시각 순서 (소유자 확인이 push 보다 앞섰다는 기록):

| 시각 (UTC) | 한국 시각 | 일 |
|------------|-----------|----|
| 2026-10-15T08:16:45Z | 10-15 17:16:45 | 재확인 — 예행 통과 커밋 == origin 머리, CI success, 원격에 `v2.0.0` 없음 (Task 1) |
| 2026-10-15T08:16:58Z ~ 08:17:23Z | 17:16:58 ~ 17:17:23 | 작업 트리 `verify.dart --tag v2.0.0` rc 0 · 10/10 (Task 1) |
| 2026-10-15T08:17:28Z | 17:17:28 | 로컬 annotated tag 생성 (Task 1) |
| 2026-10-15T08:17:34Z | 17:17:34 | 4중 점검 PASS (Task 1) |
| 2026-10-15T08:17:49Z ~ 08:18:19Z | 17:17:49 ~ 17:18:19 | Task 1 `<automated>` rc 0 |
| 2026-10-16T03:11:51Z ~ 03:12:34Z | 10-16 12:11:51 ~ 12:12:34 | README 손 따라 하기 — orchestrator 가 돌리고 소유자가 화면을 봄 (Task 2) |
| 2026-10-16T03:15:24Z | 12:15:24 | 소유자 응답 `tag` (Task 2) |
| 2026-10-16T03:15:59Z | 12:15:59 | push 직전 재확인 — 원격에 `v2.0.0` 없음, `v2.0.0^{commit}` == origin 머리 (Task 3) |
| 2026-10-16T03:16:07Z ~ 03:16:09Z | 12:16:07 ~ 12:16:09 | `git push origin v2.0.0` (Task 3) |
| 2026-10-16T03:16:11Z | 12:16:11 | tag 실행 38844667011 생성 |
| 2026-10-16T03:16:14Z | 12:16:14 | 원격 확인 `ls-remote --tags` · `--heads` (Task 3) |
| 2026-10-16T03:16:15Z ~ 03:20:35Z | 12:16:15 ~ 12:20:35 | tag 실행의 job `verify` (4분 20초) |
| 2026-10-16T03:16:34Z ~ 03:17:37Z | 12:16:34 ~ 12:17:37 | `fvm dart run tool/smoke.dart v2.0.0` rc 0, 63초 |
| 2026-10-16T03:20:58Z ~ 03:21:49Z | 12:20:58 ~ 12:21:49 | Task 3 `<automated>` rc 0 |

## Task 1 — 재확인 · 로컬 tag · 4중 점검

예행 통과 커밋: 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2 (06-04-SUMMARY 의 값, 그 줄은 한 번 나온다)

재확인 (2026-10-15T08:16:45Z, `git fetch origin --quiet` 뒤):

- `git rev-parse origin/gsd/v2.0-package-rework` → `704bf56fb028debe16f107bc9a8e6c9bdc5bccc2`. 이 커밋은 HEAD 의 조상이다. HEAD(`5076ed5`, 06-04 의 metadata 커밋)와는 `.planning/` 밖에서 차이가 없다 (`git diff --quiet`).
- `git show 704bf56:pubspec.yaml | grep -nx 'version: 2.0.0'` → `3:version: 2.0.0`. `git show 704bf56:CHANGELOG.md | head -1` → `## 2.0.0 - 2026-10-15`
- CI: run `38690710677` — `completed` · `success`, headSha `704bf56…` (06-04 의 브랜치 실행)
- `fvm dart run tool/verify.dart --tag v2.0.0`: rc 0, 25초, `점검 통과 (10개 중 10개)`, stderr `버전 일치 검사: tag v2.0.0 (--tag)`
- 원격: `--heads` 둘(`main` = `90a2736…`, 작업 브랜치 = `704bf56…`), `--tags` 는 `v1.3.0` 두 줄뿐, PR 0. 로컬 `git tag -l v2.0.0` 은 비어 있었다 (앞선 실행이 남긴 것 없음).

tag 명령 (08:17:28Z, rc 0):

```text
git tag -a v2.0.0 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2 -m "woody_lints 2.0.0" -m "SDK 하한 ^3.13.0, 프리셋 분리(base · riverpod · codegen · recommended), 규칙 재선정 — CHANGELOG 2.0.0"
```

`-a` (annotated) 로 만들었고 `-m` 은 두 번 줬다. `-s` 는 쓰지 않았다.

4중 점검 (2026-10-15T08:17:34Z = 17:17:34 +0900):

```text
$ git cat-file -t v2.0.0
tag
$ git rev-parse 'v2.0.0^{commit}'
704bf56fb028debe16f107bc9a8e6c9bdc5bccc2
$ git rev-parse v2.0.0
753f52057079702a9bf64226e1dc4a5bb858e0ee
$ git show v2.0.0:pubspec.yaml | grep -nx 'version: 2.0.0'
3:version: 2.0.0
$ git show v2.0.0:CHANGELOG.md | head -1
## 2.0.0 - 2026-10-15
$ git tag -n99 v2.0.0
v2.0.0          woody_lints 2.0.0
    
    SDK 하한 ^3.13.0, 프리셋 분리(base · riverpod · codegen · recommended), 규칙 재선정 — CHANGELOG 2.0.0
$ git for-each-ref refs/tags/v2.0.0 --format='%(objecttype) %(refname:short) -> %(*objectname:short) %(taggerdate:short)'
tag v2.0.0 -> 704bf56 2026-10-15
```

넷 다 PASS 였다. 이 task 에서는 push 하지 않았다. 저장소 파일 변경은 0 이다 (`git status --short --untracked-files=no -- . ':(exclude).planning'` 빈 출력).

## Task 2 — 소유자 확인

**확인 요청:** orchestrator 가 계획 Task 2 의 다섯 가지를 쉬운 말로 소유자에게 보였다 — 올릴 것 (tag `v2.0.0` 하나, 커밋 `704bf56`), 실행할 명령 (`git push origin v2.0.0`), 되돌릴 수 없다는 점 (`main` 은 이번에 옮기지 않음 포함), 점검 결과 (위 4중 점검 · CI · `--tag` 10/10 · 예행 · D-14 · 비공개 점검), README 손 따라 하기. 내용은 Task 1 의 값과 06-04 의 값으로 채웠다. 고정 SDK 의 두 실행 파일 경로는 소유자 화면에만 보였다.

**소유자 응답:**

- 소유자가 "추천은 어떤거?" 라고 물었다. orchestrator 는 `tag` 를 권했고, 근거로 셋을 들었다 — 막힌 자리가 없다 / 찾은 두 점은 문서 다듬기라 규칙에 영향이 없고 나중에 README 만 고쳐도 새 번호가 필요 없다 / `readme` 를 고르면 push · CI · 예행을 다시 해야 하고 오늘 회선이 불안정했다.
- 소유자는 권고안 "올린다" 를 골랐다 → **`tag`**. 시각 2026-10-16T03:15:24Z (12:15:24 KST).
- 사유: 권고 이유 승인 — 막힌 자리 없음, 작은 점 둘은 문서만의 문제

**README 손 따라 하기 (05-UAT 1번 · D-09 (1) · D-10):** 소유자가 "Claude 가 대신 따라 하고 화면을 보인다" 를 골랐다. 그래서 orchestrator 가 2026-10-16T03:11:51Z ~ 03:12:34Z 에 돌렸고 소유자가 화면을 보았다.

- 조건: `<고정 SDK 의 flutter>` · `<고정 SDK 의 dart>` (Flutter 3.47.5 / Dart 3.13.4, 저장소 루트 `fvm flutter --version --machine` 의 `flutterRoot` 아래 것. `.fvmrc` 와 같다). pub cache 와 analyzer 상태 폴더는 작업 폴더 안에 따로 두었다 — README 에 없는 차이다. 입력한 명령은 README 그대로다. `ref:` 만 tag 대신 릴리스 커밋 sha 로 넣었다 (tag 가 아직 원격에 없었다).
- (1) `<고정 SDK 의 flutter> create --platforms=android smoke_hand` → rc 0, 1초. 템플릿 옵션 파일은 `include:` · `analyzer: exclude:` (`build/**` · `android/**`) · 빈 `linter: rules:` 로, README 「설치」 의 새 문장과 같다.
- (2) 이미 있는 `dev_dependencies:` 아래에 README 「설치」 블록 네 줄을 넣었다 (`ref:` 만 릴리스 커밋 sha). `dependencies:` 에는 `flutter_riverpod: ^3.0.0` 을 넣었다. `<고정 SDK 의 flutter> pub get` → rc 0, 5초. lock 은 `source: git` · README 의 url · `resolved-ref` = `704bf56…` · `version: "2.0.0"` 이었다. 프로젝트 폴더에 새 폴더는 생기지 않았다.
- (3) `include:` 줄만 `package:woody_lints/recommended.yaml` 로 바꿨다. `analyzer:` · `linter:` 는 그대로 두었다.
- (4) 앱의 Dart 파일 하나에 `example/` 의 위반 글자를 그대로 넣었다 (겹따옴표 상수, `familyProvider([42])`).
- (5) `<고정 SDK 의 dart> analyze` → rc 2, 19초, plugin 실패 머리말 0. `prefer_single_quotes` (info) 와 `provider_parameters` (warning) 가 둘 다 나왔고, 템플릿 main 파일의 `missing_provider_scope` 도 나왔다.
- (6) 「프로젝트 전체」 의 `prefer_final_locals: false` 와 `plugins:` 블록, 「생성 파일 제외」 의 두 줄을 기존 `linter: rules:` · `analyzer: exclude:` 에 합쳤다. 최상위 키는 4개이고 중복 · YAML 오류는 없었다. rc 2, 17초. `missing_provider_scope` 와 `prefer_final_locals` 는 사라졌다. 끄는 줄을 빼면 `prefer_final_locals` 가 다시 나오는 것도 따로 확인했다. 두 위반은 남았다.
- **결과: 막힌 자리 없음.**
- 작은 점 둘 (막힘은 아니다. 소유자가 "나중에 문서만" 으로 받아들였다):
  - ① 블록 맨 위에 넣은 탓에 `sort_pub_dependencies` (info) 2줄이 나왔다. README 는 넣을 자리를 말하지 않는다.
  - ② README 「설치」 블록이 `dev_dependencies:` 머리 줄까지 보여 준다. 본문이 "그 아래에 적는다" 고 하니 기존 키 아래로 읽힌다.

**손으로 한 단계 ↔ `tool/smoke.dart` 의 단계 (D-10, checker W5):**

| 단계 | 손 (README 따라 하기) | `tool/smoke.dart` | 판정에 영향 |
|------|------------------------|-------------------|-------------|
| 빈 앱 만들기 | `flutter create --platforms=android smoke_hand` (템플릿의 pub 받기 포함) | `flutter create --no-pub --platforms=android --project-name smoke_app` (첫 받기를 README 의 `pub get` 한 번으로 두려고 `--no-pub`) | 없음 |
| pubspec 에 넣는 자리 | `dependencies:` · `dev_dependencies:` 각 블록 맨 위 | `cupertino_icons` 뒤 · `flutter_lints` 뒤 (알파벳순) | 없음 — 어느 쪽이든 `sort_pub_dependencies` (info) 2줄이 나온다 (smoke 는 템플릿 자신의 줄에, 06-03 Issues) |
| 넣는 내용 | README 「설치」 블록 (`ref:` = 릴리스 커밋 sha) + `flutter_riverpod: ^3.0.0` | README 「설치」 블록 (`ref:` = 준 ref) + `flutter_riverpod` | 없음 |
| 받기 | `flutter pub get` (평소 cache 가 아닌 작업 폴더 안 cache) | `flutter pub get` (새 `PUB_CACHE`) | 없음 — 둘 다 lock `resolved-ref` = 기대 커밋 |
| `include:` | `recommended.yaml` 한 줄만 바꿈 | `recommended.yaml` 과 옛 주소 `analysis_options.yaml` 두 주소 | 없음 — smoke 가 더 넓다 |
| 위반 글자 | `example/` 의 겹따옴표 상수 · `familyProvider([42])` | 같은 글자 (위반 파일 하나) | 없음 |
| 분석 | `dart analyze` | 주소마다 `dart analyze --format=json` (새 상태 폴더) | 없음 — 판정한 두 진단이 같다 |
| 끄기 · 제외 합치기 | (6) 을 더 했다 | 범위 밖 (D-14 측정은 06-04 가 따로 했다) | 없음 |

판정이 달라지는 차이는 없다 → `script` 가 아니다.

## Task 3 — push · 원격 확인 · tag 실행 · tag smoke

push 직전 재확인 (2026-10-16T03:15:59Z): `git ls-remote --tags origin` 은 `v1.3.0` 두 줄뿐이었다. `git rev-parse 'v2.0.0^{commit}'` 과 `origin/gsd/v2.0-package-rework` 는 둘 다 `704bf56fb028debe16f107bc9a8e6c9bdc5bccc2` 이었고, `git cat-file -t v2.0.0` = `tag`, 현재 브랜치는 `gsd/v2.0-package-rework` 였다.

push (2026-10-16T03:16:07Z 시작, 03:16:09Z 끝 = 12:16:07 +0900):

```text
$ git push origin v2.0.0
To github.com:woodkill/woody_lints.git
 * [new tag]         v2.0.0 -> v2.0.0
rc=0
```

`--tags` · `--follow-tags` · 브랜치 이름 · 인자 없는 `git push` 는 쓰지 않았다. 작업 브랜치의 metadata 커밋(`5076ed5`)과 이 plan 의 기록 커밋은 올리지 않았다 (06-06 이 올린다).

원격 확인 (2026-10-16T03:16:14Z = 12:16:14 +0900):

```text
$ git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
753f52057079702a9bf64226e1dc4a5bb858e0ee	refs/tags/v2.0.0
704bf56fb028debe16f107bc9a8e6c9bdc5bccc2	refs/tags/v2.0.0^{}
rc=0
$ git ls-remote --heads origin
704bf56fb028debe16f107bc9a8e6c9bdc5bccc2	refs/heads/gsd/v2.0-package-rework
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
rc=0
$ git show v2.0.0:pubspec.yaml | grep -nx 'version: 2.0.0'
3:version: 2.0.0
$ git show v2.0.0:CHANGELOG.md | head -1
## 2.0.0 - 2026-10-15
```

읽는 법: annotated tag 는 `ls-remote` 에 두 줄로 나온다. 첫 줄 `753f520…` 는 tag 객체 자체의 sha 로, 로컬 `git rev-parse v2.0.0` 과 같다. 둘째 줄 `refs/tags/v2.0.0^{}` 이 tag 가 가리키는 **커밋** `704bf56…` 이다 — 판정은 이 줄로 한다. `--heads` 는 둘 그대로다 (`main` = `90a2736`, 작업 브랜치 = 릴리스 커밋). 브랜치는 따라 올라가지 않았다. tag 의 version 과 CHANGELOG 최상단 버전은 tag 이름과 같은 2.0.0 이다 (ROADMAP 성공 기준 2).

본 체크아웃의 `git tag -l v2.0.0` → `v2.0.0` (worktree 가 아닌 본 체크아웃에서 실행).

**CI 의 tag 실행 (D-01 6, D-06):**

- `gh run list --workflow verify.yml --event push --limit 20 --json databaseId,status,conclusion,headSha,headBranch,createdAt` 에서 `headSha == 704bf56…` 인 실행이 둘 나왔다:
  - `38844667011` — **`headBranch` `v2.0.0`**, 생성 2026-10-16T03:16:11Z (tag 실행)
  - `38690710677` — `headBranch` `gsd/v2.0-package-rework`, 생성 2026-10-15T06:08:59Z (06-04 의 브랜치 실행)
- **A3 확인:** tag 실행의 `headBranch` 실제 값은 tag 이름 `v2.0.0` 이다. VERSIONING.md 「릴리스 절차」 6번의 필터 설명("`headBranch` 가 tag 이름인 실행")과 같다. 문서는 고치지 않았다.
- `gh run watch 38844667011 --exit-status` → rc 0 (03:20:41Z 끝). `gh run view` → `completed` · `success`, event `push`. job `verify` 는 03:16:15Z ~ 03:20:35Z (4분 20초), 이미지 `ubuntu-24.04` / `20261012.334.1`.
- 로그 (`gh run view 38844667011 --log`):
  - `2026-10-16T03:17:20.9943545Z 버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)`
  - `2026-10-16T03:20:32.4842606Z [3/10] 배포 파일의 구성 ................ 통과`
  - `2026-10-16T03:20:32.4851483Z 점검 통과 (10개 중 10개)`
- tag 모드 줄이 있으므로 CI 의 tag 트리거가 (i) 를 tag 모드로 불렀다 (ROADMAP 성공 기준 1 의 CI 쪽).
- 실행 annotation: `The ubuntu-latest label will migrate to Ubuntu 26 beginning October 19, 2026.` — 아래 Next Phase Readiness.

**tag smoke (D-01 7)** `fvm dart run tool/smoke.dart v2.0.0`: 03:16:34Z ~ 03:17:37Z, **rc 0, 63초**, stderr 0바이트, 화면에 경로 0줄. 화면은 아래와 같다 (경로 없음. 앱 안의 두 Dart 파일 이름은 "템플릿 main" · "위반 파일" 로 바꿔 적었다):

```text
SDK Flutter 3.47.5 / Dart 3.13.4
기대 커밋: 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2 (git rev-parse 'v2.0.0^{commit}')
flutter create: exit 0, 1.1s
flutter pub get: exit 0, 6.3s — lock: source git, url https://github.com/woodkill/woody_lints.git, resolved-ref 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2

## recommended — package:woody_lints/recommended.yaml
   dart analyze exit 2, 31.8s, 머리말 없음, plugin 폴더 1, riverpod_lint 3.1.9
   <템플릿 main>:4  warning  missing_provider_scope
   <위반 파일>:12  warning  provider_parameters
   <위반 파일>:5  info  prefer_single_quotes
   <위반 파일>:8  info  specify_nonobvious_property_types
   pubspec.yaml:36  info  sort_pub_dependencies
   pubspec.yaml:48  info  sort_pub_dependencies
   판정: prefer_single_quotes 있음 · provider_parameters 있음

## alias — package:woody_lints/analysis_options.yaml
   dart analyze exit 2, 22.2s, 머리말 없음, plugin 폴더 1, riverpod_lint 3.1.9
   <템플릿 main>:4  warning  missing_provider_scope
   <위반 파일>:12  warning  provider_parameters
   <위반 파일>:5  info  prefer_single_quotes
   <위반 파일>:8  info  specify_nonobvious_property_types
   pubspec.yaml:36  info  sort_pub_dependencies
   pubspec.yaml:48  info  sort_pub_dependencies
   판정: prefer_single_quotes 있음 · provider_parameters 있음

smoke 통과 (ref v2.0.0 → 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2, recommended 6줄 / 옛 주소 6줄, riverpod_lint 3.1.9)
임시 폴더를 지웠다
```

pub 은 annotated tag 도 가리키는 커밋의 번호로 lock 에 적는다 — `resolved-ref` = `git rev-parse 'v2.0.0^{commit}'` = `704bf56…` (D-09 (3)). 두 주소의 6줄은 06-04 예행 · 06-03 통과 실행과 같다 (ROADMAP 성공 기준 3).

## `<automated>` 결과

계획 파일에서 줄 머리 `<verify>` … `</verify>` 구간 안의 줄 머리 `<automated>` 블록만 python `-I` 로 그대로 뽑았다 (Task 1 1606바이트, Task 3 2221바이트). 저장소 루트에서 `bash` 로 돌렸고, 고친 판은 만들지 않았다.

| Task | 돌린 시점 | rc |
|---|---|---|
| Task 1 | 로컬 tag 생성 · 4중 점검 뒤, 확인 요청 전 (2026-10-15T08:17:49Z ~ 08:18:19Z, 30초) | 0 |
| Task 3 | push · tag 실행 success · tag smoke 뒤, metadata 커밋 전 (2026-10-16T03:20:58Z ~ 03:21:49Z, 51초 — 안에서 smoke 를 한 번 더 돌렸다) | 0 |

## Task Commits

1. **Task 1: 재확인 · 로컬 tag · 4중 점검** — 커밋 없음 (git ref `refs/tags/v2.0.0` 만, tag 객체 `753f520`)
2. **Task 2: 소유자 확인** — 커밋 없음 (응답 `tag`)
3. **Task 3: push · 확인** — 커밋 없음 (원격 ref 와 run 38844667011)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 의 커밋 (docs). push 하지 않는다 (06-06 이 올린다).

## Files Created/Modified

- 없음 (저장소 추적 파일). 이 plan 의 기록 커밋은 `.planning/` 만 바꾼다.

## Decisions Made

- tag 는 06-04 의 예행 통과 커밋 `704bf56` 에 달았다 (D-07). `.planning/` 기록 커밋(`5076ed5`)에는 달지 않았다.
- 소유자 응답 `tag` 뒤에만 `git push origin v2.0.0` 을 실행했다. 올린 tag 는 옮기거나 지우지 않는다 (잘못이면 `v2.0.1`).
- README 손 따라 하기의 작은 점 둘은 문서만의 문제로 두고 tag 를 그대로 올렸다. 소유자가 "나중에 문서만" 으로 받아들였다.

## Deviations from Plan

None - plan executed exactly as written.

계획 밖에서 한 일 둘을 적어 둔다 (편차는 아니다):
- README 손 따라 하기는 소유자가 아니라 orchestrator 가 돌렸고 소유자가 화면을 보았다. 소유자가 고른 방식이다. 계획은 이 경우("orchestrator 가 대신 돌린다")를 따로 적지 않았다.
- Task 1 의 SUMMARY 초안은 저장소 밖 내 임시 폴더의 메모로 두었고, 확인 응답 뒤에 이 파일로 옮겼다. 응답 전에는 저장소 안에 아무것도 쓰지 않았다.

## Issues Encountered

None. 회선은 정상 속도였다 (`pub get` 6.3초, smoke 63초).

## User Setup Required

None - 네트워크(GitHub · pub.dev)만 필요하다.

## Next Phase Readiness

- **06-06 (PR · `main` 병합):** 원격 tag `v2.0.0` → `704bf56`. 원격 작업 브랜치도 `704bf56` 이다. 로컬은 `5076ed5` (06-04 metadata) 와 이 plan 의 metadata 커밋, 이렇게 둘이 앞선다 — 06-06 의 push gate 범위 `v2.0.0^{commit}..HEAD` 에 이 둘이 들어간다. 원격 `main` 은 `90a2736` 그대로고 PR 은 0 이다.
- 이 SUMMARY 에는 앱 안 Dart 파일 경로를 적지 않았다 ("템플릿 main" · "위반 파일" 로 바꿈). 고정 SDK 경로도 `<고정 SDK 의 …>` 로만 적었다.
- GitHub 이 tag 실행에 `ubuntu-latest` 라벨이 2026-10-19 부터 Ubuntu 26 으로 옮겨 간다는 annotation 을 달았다. 06-06 의 `pull_request` · `main` push · `workflow_dispatch` 실행이 그 날 뒤에 돌면 runner 이미지가 바뀐다 (skill `spike-findings-woody-lints` 의 Ubuntu 26.04 runner 항목).
- README 「설치」 의 작은 점 둘(넣는 자리, `dev_dependencies:` 머리 줄)은 다음 문서 커밋 후보다. 06-07 의 05-UAT 1번 처리 기록에 "막힌 자리 없음, 작은 점 둘" 로 적을 재료다.
- `requirements.mark-complete` 는 부르지 않았다 (REL-02 는 06-06, REL-03 · 04 는 06-07 이 마지막으로 선언한다).

---
*Phase: 06-release*
*Completed: 2026-10-16*

## Self-Check: PASSED

- FOUND: 로컬 `v2.0.0` (`git cat-file -t` = `tag`, `^{commit}` = `704bf56…`)
- FOUND: 원격 `refs/tags/v2.0.0^{}` = `704bf56…`, `--heads` 둘
- FOUND: run 38844667011 success (`headBranch` `v2.0.0`), 로그 세 줄
- Task 1 · Task 3 `<automated>` rc 0 (위 표), smoke rc 0
- commits: 0 (`git rev-list --count 5076ed5..HEAD` = 0 — SUMMARY 작성 시점, metadata 커밋 전)
