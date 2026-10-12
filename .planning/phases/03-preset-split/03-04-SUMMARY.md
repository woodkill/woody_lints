---
phase: 03-preset-split
plan: 04
subsystem: infra
tags: [riverpod_lint, plugin-constraint, github-actions, ci, push, verify-harness]

# Dependency graph
requires:
  - phase: 03-preset-split
    provides: "03-03 의 연습용 프로젝트 여섯 · 단계 9개 · [3/9] 의 선언 대조(pluginConstraintToken), 03-02 의 lib/riverpod.yaml 조각"
provides:
  - "lib/riverpod.yaml 10행 `  riverpod_lint: ^3.1.9` 와 fixtures/overrides/analysis_options.yaml 의 `    version: ^3.1.9` (범위 지정, D-01)"
  - "CHANGELOG 2.0.0 `### 그 밖의 변경` 의 하한 상향 불릿 (minor)"
  - "origin/gsd/v2.0-package-rework 가 0d20c10 → 166d0be → 79f27e5 로 전진 (fast-forward 두 번)"
  - "GitHub verify 의 성공한 run 둘 — 38247615476 (job 247초) · 38248171220 (job 213초)"
  - ".github/workflows/verify.yml 25행 주석의 실측 시간 (YAML 은 008ea3f 와 같다)"
affects: [phase-04-rule-selection, phase-05-docs, phase-06-release, .github/workflows/verify.yml]

# Actuals (#2632) — chars/4 over the files the two task commits changed (SUMMARY 제외)
actuals:
  tokens: 1341
  tasks: 3
  commits: 2
plan_head_before: a940d3fc5d260aee5c9113b0fb4fdbbe01b5dc1f
plan_head_after: 79f27e57b59d738e8cf58d64d4d2263835b418a5

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "plugin 선언을 올릴 때는 조각과 끄는 설정용 fixture 의 version 을 같은 커밋에서 올린다 — 하나만 올리면 [3/9] 가 실패한다"
    - "workflow 의 정상 시간 주석은 run id 와 실측 날짜를 함께 적는다"

key-files:
  created:
    - .planning/phases/03-preset-split/03-04-SUMMARY.md
  modified:
    - lib/riverpod.yaml
    - fixtures/overrides/analysis_options.yaml
    - CHANGELOG.md
    - .github/workflows/verify.yml

key-decisions:
  - "riverpod_lint 하한을 ^3.1.9 로 올렸다 (lib/riverpod.yaml 과 fixtures/overrides 의 version 을 같은 커밋 166d0be 에서). 정답지 다섯의 hash 가 올리기 전과 같고 --update 는 '바뀐 정답지가 없다' 였다 (Flutter 3.47.5 / Dart 3.13.4, 풀린 버전 3.1.9, 2026-10-12)"
  - "Phase 3 의 첫 push 는 소유자 응답 push 뒤 git push origin gsd/v2.0-package-rework 한 줄로 했다 (2026-10-12T12:12:44Z, 0d20c10..166d0be, 24커밋, fast-forward). 두 번째 push 는 D-09 대로 묻지 않고 했다 (12:18:00Z, 166d0be..79f27e5). main 은 90a2736, tag 는 v1.3.0 하나, PR 0건 그대로다"
  - "GitHub verify 가 연습용 프로젝트 여섯으로 두 번 성공했다 — run 38247615476 job 4분 7초 (검증 단계 182초), run 38248171220 job 3분 33초 (검증 단계 147초), 이미지 ubuntu-24.04 20261004.327.1. 360초를 넘지 않아 timeout-minutes 10 그대로 두고 workflow 25행 주석만 실측으로 고쳤다"
  - "이 plan 의 마무리 커밋(SUMMARY · STATE · ROADMAP · REQUIREMENTS)은 origin 에 없다. Phase 4 부터의 push 는 다시 소유자에게 묻는다 (D-09)"

patterns-established:
  - "plugin 하한 상향 커밋: 조각 선언 → (fixture 를 올리기 전 실행으로 [3/9] 실패 확인) → fixture version → 보통 실행 · --update · 정답지 hash 대조"

requirements-completed: [PRESET-05]

coverage:
  - id: D1
    description: "riverpod_lint 선언이 조각과 overrides 두 자리에서 ^3.1.9 (범위 지정)이고 lib · fixture 옵션 파일에 ^3.1.3 이 없다; 이어 붙인 조각이 90a2736 원본과 10행 한 줄만 다르다"
    requirement: "PRESET-05"
    verification:
      - kind: integration
        ref: "03-04-PLAN.md Task 1 <automated> (커밋 166d0be 뒤 종료 코드 0, ; 로 이어진 구간은 따로 다시 돌림)"
        status: pass
    human_judgment: false
  - id: D2
    description: "하한 상향 앞뒤로 정답지 다섯이 같다 — hash 다섯 불변, --update '바뀐 정답지가 없다', version ^3.1.8 로 바꾼 실행은 [3/9] 만 실패"
    requirement: "PRESET-05"
    verification:
      - kind: integration
        ref: "fvm dart run tool/verify.dart / --update; git diff --quiet 9ed0fe5 -- <정답지 다섯>"
        status: pass
    human_judgment: false
  - id: D3
    description: "첫 push 는 소유자 확인(push) 뒤 한 줄 명령으로, 두 번째 push 는 묻지 않고 — 둘 다 fast-forward, main · tag · PR 불변"
    verification:
      - kind: other
        ref: "git ls-remote --heads/--tags origin, gh pr list --state all (03-04-PLAN.md Task 3 <automated>)"
        status: pass
    human_judgment: true
    rationale: "push 가 소유자 확인 뒤에만 실행되었다는 순서는 대화 기록으로만 보인다 — 원격 상태는 자동으로 쟀다"
  - id: D4
    description: "GitHub verify 가 두 커밋에서 completed success, 로그에 [1/9] ~ [9/9] 통과 · 점검 통과 (9개 중 9개), job 시간이 timeout 안, workflow 주석이 실측 시간 · run id 를 말하고 YAML 은 008ea3f 와 같다"
    requirement: "VERIFY-04"
    verification:
      - kind: e2e
        ref: "03-04-PLAN.md Task 3 <automated> (종료 코드 0, ID1=38247615476 T1=247 ID2=38248171220 T2=213 TM=10)"
        status: pass
    human_judgment: false

# Metrics
duration: 18min
completed: 2026-10-12
status: complete
---

# Phase 3 Plan 04: riverpod_lint 하한 ^3.1.9 와 Phase 3 의 첫 push · runner 실측 Summary

**`riverpod_lint` 하한을 조각과 끄는 설정용 연습 프로젝트 두 자리에서 함께 `^3.1.9` 로 올렸고 정답지 다섯은 한 줄도 바뀌지 않았다. 소유자 확인 뒤 작업 브랜치를 GitHub 에 두 번 fast-forward 로 올렸고, 자동 점검 `verify` 가 연습용 프로젝트 여섯으로 두 번 성공했다 (job 4분 7초 · 3분 33초). workflow 주석을 그 실측으로 고쳤다**

**GitHub 자동 점검 시간:** 추정은 약 4분 15초였다 (CONTEXT D-03). 실측은 4분 7초 (run 38247615476) 와 3분 33초 (run 38248171220) 다. 쉽게 말하면, GitHub 이 연습용 프로젝트 여섯을 처음부터 끝까지 검사하는 데 4분 안팎이 걸린다. 그중 약 1분은 Flutter 설치이고, 나머지 2분 반 ~ 3분이 검사다. 시간 제한 10분에는 넉넉히 든다.

## Performance

- **Duration:** 약 18 min (소유자 응답을 기다린 시간 제외)
- **Started:** 2026-10-12T12:04:55Z
- **Completed:** 2026-10-12T12:23Z
- **Tasks:** 3 (Task 2 는 소유자 결정)
- **Files modified:** 4 (+ 이 SUMMARY)

## Accomplishments

- `lib/riverpod.yaml` 10행을 `  riverpod_lint: ^3.1.9` 로 고쳤다. 파일은 10줄 그대로다. `fixtures/overrides/analysis_options.yaml` 의 `version:` 도 `^3.1.9` 로 고쳤다. 두 줄은 같은 커밋 `166d0be` 에 들어 있다.
- 정답지 다섯은 하한 상향 앞뒤로 그대로다. `--update` 는 쓰지 않았다고 찍었고, 머리 주석의 날짜도 다시 쓰지 않았다.
- 선언이 어긋나면 `[3/9]` 가 잡는다는 것을 실측으로 확인했다. 조각만 올린 실행과 `^3.1.8` 로 바꾼 실행 모두 `[3/9]` 만 실패했다.
- 소유자 확인(`push`) 뒤 브랜치를 두 번 올렸다. GitHub 의 `verify` 가 두 번 모두 `점검 통과 (9개 중 9개)` 로 성공했다.
- `.github/workflows/verify.yml` 25행 주석을 실측으로 고쳤다. YAML 설정은 `008ea3f` 와 같다.

## Task 1 — 하한 상향 (Flutter 3.47.5 / Dart 3.13.4, 2026-10-12)

### 하한 상향 전 기준

- HEAD: `a940d3fc5d260aee5c9113b0fb4fdbbe01b5dc1f`. 03-03 의 마무리 커밋이고, 하한 상향 전의 마지막 커밋이다.
- 정답지를 마지막으로 바꾼 커밋: `9ed0fe5deb7245d6fd21636e1c8c198afddabb42` (03-03 Task 2).
- `git status --short -- lib fixtures example tool`: 비어 있음.

| 정답지 | 상향 전 `git hash-object` | 상향 후 |
|---|---|---|
| `example/expected_diagnostics.txt` | `facd4a7e15cd7cff91a02b5d455810ccfa0feb56` | 같음 |
| `fixtures/base_only/expected_diagnostics.txt` | `ef48a68124a32254cda2148a2b0f21298c1dd637` | 같음 |
| `fixtures/base_riverpod/expected_diagnostics.txt` | `6a33435bd7ff80437175dcd1c3788fab42cac350` | 같음 |
| `fixtures/base_codegen/expected_diagnostics.txt` | `047a80b0483015c205e961d2f17ff7489a14e690` | 같음 |
| `fixtures/overrides/expected_diagnostics.txt` | `90392cb23d43dda9ef928c402bb52e8397f15709` | 같음 |

### `overrides` 를 올리기 전의 실행 (조각만 `^3.1.9`): 종료 코드 1, 49초

```text
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/9] lib/ 에 .dart 파일 없음 .......... 통과
[2/9] 배포 파일의 규칙 이름 ............ 통과
[3/9] 연습용 프로젝트 옵션 파일 ........ 실패
[4/9] example (옛 주소) ................ 통과
[5/9] recommended (묶음) ............... 통과
[6/9] base_only (기본만) ............... 통과
[7/9] base_riverpod .................... 통과
[8/9] base_codegen ..................... 통과
[9/9] overrides (끄는 설정) ............ 통과

`fixtures/overrides/analysis_options.yaml` 이 정해진 내용이 아니다 — 주석·빈 줄을 뺀 내용 (9줄):
  …
      version: ^3.1.3
  …
  정해진 내용:
    …
    version: ^3.1.9
    …

점검 실패 (9개 중 1개)
```

진단은 다섯 정답지 단계 모두 통과했다. 두 선언 모두 3.1.9 로 풀렸기 때문이다. 49초는 plugin 을 다시 준비한 첫 실행의 시간이다 (A-04-1).

### 둘 다 올린 뒤

- 보통 실행: 종료 코드 0, 31초. `plugin     riverpod_lint 3.1.9`, `[1/9]` ~ `[9/9]` 모두 통과, `점검 통과 (9개 중 9개)`.
- `--update`: 종료 코드 0, 22초. `[4/9]` · `[6/9]` ~ `[9/9]` 이 `바뀐 줄 없음` 이고, 끝에 `바뀐 정답지가 없다 — 쓰지 않았다` 를 찍었다.
- `git diff --quiet 9ed0fe5 -- <정답지 다섯>`: 통과.
- 커밋 뒤의 되돌리는 실행: `version: ^3.1.8` 로 바꾸자 종료 코드 1, `[3/9]` 만 실패, `점검 실패 (9개 중 1개)` 였다. 화면에는 실제 `version: ^3.1.8` 과 정해진 `version: ^3.1.9` 가 찍혔다. 저장해 둔 복사본으로 되돌렸고 `git status` 는 비어 있다.
- 루트 `fvm dart analyze`: `No issues found!`.

## Task 2 — 첫 push 의 소유자 확인 (checkpoint:decision, gate blocking-human)

실행자가 돌려보낸 결정 패널의 원문이다.

> **Current Task — Task 2:** 이 phase 의 첫 push — 작업 브랜치 `gsd/v2.0-package-rework` 를 GitHub 에 올릴지 정한다 (D-09, 되돌릴 수 없다)
>
> 쉽게 말하면, "GitHub 에 올린다" 는 내 컴퓨터에만 있는 이 브랜치의 새 커밋들을 GitHub 저장소에 복사하는 일입니다. 공개 저장소에 한 번 올라간 내용은 브랜치를 지워도 남의 복제본이나 캐시에 남을 수 있어서 **되돌릴 수 없습니다**. 그래서 이 phase 에서 처음 올리기 전에 한 번 묻습니다.
>
> `push` 라고 답하시면 Phase 3 안에서 같은 브랜치에 한 번 더 올리는 것(Task 3 의 workflow 주석 커밋)은 다시 묻지 않고 올린 뒤 보고합니다. `--force`, `main`, tag, 다른 브랜치는 이 확인에 들어 있지 않으므로 하지 않습니다.
>
> **실행할 명령 (한 줄):** `git push origin gsd/v2.0-package-rework`
> - 브랜치 이름 하나만 주고, `--force` · `--tags` · `--all` · `-u` 는 붙이지 않습니다.
> - `main` 은 `90a2736` 그대로, tag 는 `v1.3.0` 하나 그대로이고, PR 은 열지 않습니다.
>
> **원격 상태** (2026-10-12T12:10:27Z, `git fetch origin --quiet` 의 종료 코드 0):
> - 원격 작업 브랜치는 `0d20c10` 이고 로컬 HEAD 의 조상입니다. fast-forward 로 올라가며 force 는 필요 없습니다.
> - `gh auth status` 는 로그인 상태입니다.
> - PR 은 0건입니다.

```
=== git ls-remote --heads origin
0d20c10860fc42df52c066cc3e1ec1738f0a712b	refs/heads/gsd/v2.0-package-rework
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
=== git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
```

> **올라갈 커밋 24개** (`git log --oneline origin/gsd/v2.0-package-rework..HEAD` 원문):

```
166d0be feat(03-04): riverpod_lint 하한을 ^3.1.9 로 올린다
a940d3f docs(03-03): 연습용 프로젝트 여섯 plan 03-03 완료 — 검증 명령을 Fixture 표 · 단계 9개로 넓히고 fixtures/ 다섯과 정답지 넷을 --update 로 처음 써 권고 11 과 줄 단위로 같음을 확인했으며 M18 · M19 를 기록했다 (03-03-SUMMARY.md)
25e980e docs(03-03): example/README.md 를 연습용 프로젝트 여섯 · 단계 아홉 개로 고치고 M18 · M19 를 기록한다
9ed0fe5 feat(03-03): base_riverpod · base_codegen · overrides 연습용 프로젝트와 정답지 셋을 더해 단계 9개로 늘린다
91bbeec feat(03-03): 검증 명령을 연습용 프로젝트 표 기반으로 바꾸고 recommended · base_only 를 더한다
f01228a docs(03-02): 프리셋 나누기 plan 03-02 완료 — 조각 셋 · 묶음 · 옛 주소 별칭으로 나누고 [2/4] 를 조각 셋으로 넓혔으며 루트 분석의 배포 파일 제외를 걷어냈다 (03-02-SUMMARY.md)
933b26f feat(03-02): 루트 분석의 lib/analysis_options.yaml 제외를 걷어내고 CHANGELOG 에 프리셋 분리를 적는다
89d6073 feat(03-02): 배포 파일을 base / riverpod / codegen 조각과 recommended 묶음으로 나누고 옛 주소는 별칭으로 둔다
6029ee9 docs(03-01): 가장 먼저 할 일 plan 03-01 완료 — [2/4] 의 통과 조건을 exit 0 · 진단 0건으로 좁혀 --update 가 망가진 배포 파일의 결과를 쓰지 못한다 (03-01-SUMMARY.md)
533868a docs(03-01): example/README.md 의 --update 안전장치 · 단계 설명을 코드에 맞추고 M15 ~ M17 을 기록한다
998cc32 fix(03-01): --update 가 망가진 배포 파일의 결과를 정답지로 쓰지 못하게 [2/4] 를 넓힌다
127416c docs(03): Phase 3 계획 완료를 STATE 에 기록
8f8fc33 docs(03): checker 지적에 따라 03-02 · 03-03 계획을 고친다 (revision 1)
390867a docs(03): Phase 3 (Preset Split) 계획 — plan 넷, wave 넷
00032dc docs(03): Phase 3 패턴 지도(PATTERNS.md) 작성
66a1753 docs(03): Phase 3 검증 계획 문서(VALIDATION.md) 작성
759bddf docs(03): Phase 3 (Preset Split) 조사 — spike 009 ~ 019 의 결과와 scratch 실측을 계획용으로 정리
190c433 docs(spike-wrap-up): spike 017 ~ 019 의 실측 결과를 프로젝트 skill 에 반영
db84b07 docs(spikes): spike 017 ~ 019 에서 굳어진 관례 반영
91a0893 docs(spike-019): VALIDATED — 실제 사용 프로젝트에서도 나누기 전후가 줄 단위로 같다
2016e9e docs(spike-018): MANIFEST 에 018 의 판정과 요구 사항을 적는다
0144db9 ci: spike 017 · 018 임시 workflow 제거
d8c2869 docs(spike-018): VALIDATED — 다음 runner 이미지(Ubuntu 26.04)에서 검증이 지금과 같은 결과를 낸다
58782d4 docs(spike-017): VALIDATED — 연습용 프로젝트 여섯은 runner 에서 차례로 돌려도 약 3분 20초 ~ 4분 20초다
```

> **push 로 더해지거나 바뀌는 파일 118개의 폴더별 수** (루트의 파일은 `.gitignore/` 처럼 끝에 `/` 가 붙어 찍힌다):

```
  18 .claude/skills
   1 .gitignore/
  10 .planning/phases
   1 .planning/REQUIREMENTS.md
   1 .planning/ROADMAP.md
  18 .planning/spikes
   1 .planning/STATE.md
   1 analysis_options.yaml/
   1 CHANGELOG.md/
   1 example/README.md
  11 fixtures/base_codegen
  11 fixtures/base_only
  11 fixtures/base_riverpod
  16 fixtures/overrides
  10 fixtures/recommended
   1 lib/analysis_options.yaml
   1 lib/base.yaml
   1 lib/codegen.yaml
   1 lib/recommended.yaml
   1 lib/riverpod.yaml
   1 tool/verify.dart
```

> `.planning/` 의 조사 · 계획 · SUMMARY 문서와 `.claude/skills/spike-findings-woody-lints/` 도 함께 올라갑니다.
>
> **비밀 · 절대 경로 · 이메일 검사:** `/Users/` · `ghp_` · `github_pat_` · `PRIVATE KEY` · 이메일을 찾았고 `noreply@anthropic.com` 은 뺐습니다. **9건이 걸렸습니다** (원문 아래). 9줄 모두 계획 문서 안에서 `/Users/` 를 "적지 않는다" 는 규칙이나 grep 패턴 문자열로 언급한 줄입니다. 토큰 문자열이나 이메일은 걸리지 않았습니다.

```
2914:+    - statement: "README 의 기록에 로컬 절대 경로(`/Users/…`)나 토큰을 적지 않는다 — `.planning/` 과 함께 공개 저장소에 올라간다 (02-CONTEXT.md D-08)"
3068:+    <automated>R=example/README.md; grep -qF '같은 실행에서 다른 단계가 실패했으면 정답지를 쓰지 않고' "$R" && … && ! grep -v '^#' "$R" | grep -q '/Users/' && ! grep -qi 'gho_' "$R" && … (03-01-PLAN.md Task 2 의 <automated> 한 줄 — 매우 길어 가운데를 줄임)
3069:+    <fails_when>non-zero exit — … `/Users/` 나 토큰 흔적이 있으면 공개 저장소에 올리면 안 되는 것; … (03-01-PLAN.md)
3077:+    - README 의 비주석 줄에 `/Users/` 가 없고 토큰 흔적이 없으며 파일 끝이 개행이다
3101:+| T-03-02 | Information Disclosure | `readParseErrorLines` 의 출력 (재실행의 stdout · stderr) 과 README 의 M15 ~ M17 기록 | medium | mitigate | 재실행 줄은 `scrubPaths(…, repoRoot)` 로 경로를 가린 뒤에만 화면에 낸다 (Task 1 action 1-(2)); README 는 Task 2 verify 가 비주석 줄의 `/Users/` 와 토큰 흔적 0건을 잰다 |
4159:+    <automated>R=example/README.md; grep -qxF '## 연습용 프로젝트 여섯' "$R" && … && ! grep -v '^#' "$R" | grep -q '/Users/' && ! grep -qi 'gho_' "$R" && … (03-03-PLAN.md Task 3 의 <automated> — 가운데를 줄임)
4160:+    <fails_when>non-zero exit — … `/Users/` 나 토큰이 있으면 공개 금지; … (03-03-PLAN.md)
4194:+| T-03-12 | Information Disclosure | 새 파일(README 표 · 기록, 정답지 머리 주석, 스크립트 화면)에 로컬 절대 경로가 남음 | low | mitigate | 정답지는 상대 경로만 (`normalizeDiagnostics`), 화면은 `scrubPaths`; Task 3 verify 가 README 의 `/Users/` · 토큰 0건을 잰다 |
6606:+| 03-01-T2 | 03-01 | 1 | (가장 먼저 할 일) | T-03-02 | README 의 기록에 절대 경로 · 토큰이 없다 | doc + integration | `example/README.md` 의 30행 · 81행 · 158행 새 문구 grep, `| M15 |` ~ `| M17 |` 3행, `실측 (03-01):` 줄, `/Users/` 0건; `fvm dart run tool/verify.dart` exit 0 | ✅ (`example/README.md`) | ⬜ pending |
```

> **선택지:**
> 1. `push` — 올린다.
>    - 장점: GitHub runner 에서 여섯이 통과하는지와 몇 분 걸리는지를 실제로 봅니다 (D-09 가 phase 를 끝내기 전에 요구한 확인). 원격이 로컬을 따라잡습니다.
>    - 단점: 올린 커밋과 `.planning/` 문서는 되돌릴 수 없습니다. 자동 점검이 실패하면 고친 커밋을 다시 올려야 합니다 (그 push 는 묻지 않습니다).
> 2. `hold` — 올리지 않고 여기서 멈춘다.
>    - 장점: 원격에 아무것도 남지 않고, 커밋 목록을 더 살펴볼 수 있습니다.
>    - 단점: D-09 의 runner 확인을 하지 못해 phase 를 끝내지 못합니다. Task 3 은 하지 않습니다.

**소유자의 답: `push`**

- 소유자는 orchestrator 가 직접 물은 질문에 답했다. 질문은 "작업 브랜치 gsd/v2.0-package-rework 의 커밋 24개를 GitHub 에 올릴까요? (되돌릴 수 없음, main 은 건드리지 않음)" 였고, 소유자가 고른 것은 "push (Recommended)" 다.
- 그 선택지의 설명은 다음과 같았다: "git push origin gsd/v2.0-package-rework 한 줄로 올리고, GitHub 자동 점검이 여섯 프로젝트에서 통과하는지와 걸린 시간을 잰다. workflow 주석을 고친 두 번째 push 는 묻지 않고 한다."
- 시각: 응답 메시지를 받은 시각이 2026-10-12T12:12:19Z 다. 메시지에 시각이 따로 적혀 있지 않아 실행자가 받은 직후 `date -u` 로 기록했다.
- orchestrator 는 묻기 전에 다시 확인했다고 전했다. 확인한 것은 넷이다: fetch 성공, `0d20c10` 가 HEAD 의 조상, 24커밋 · HEAD `166d0be`, 추가된 줄에서 `/Users/woody` · `/private/tmp` · `admin@` 가 0건.

## Task 3 — push 둘과 GitHub run 둘

### precondition (2026-10-12T12:12:19Z)

다섯 조건 모두 충족했다.
- `git fetch origin --quiet`: 성공.
- `git merge-base --is-ancestor origin/gsd/v2.0-package-rework HEAD`: 0.
- 현재 브랜치: `gsd/v2.0-package-rework`.
- `.planning` 밖의 추적 파일 변경: 없음.
- `gh auth status`: 로그인 상태.

### 첫 push — 2026-10-12T12:12:44Z

```
$ git push origin gsd/v2.0-package-rework
To github.com:woodkill/woody_lints.git
   0d20c10..166d0be  gsd/v2.0-package-rework -> gsd/v2.0-package-rework
```

### run 1 — 하한 상향 커밋 `166d0be`

- run id `38247615476`, event `push`, `completed` / `success`.
- URL: https://github.com/woodkill/woody_lints/actions/runs/38247615476
- 만들어진 시각: 2026-10-12T12:12:51Z.
- job `verify` (ID 114805365974): 12:12:54Z → 12:17:01Z, **247초 = 4분 7초**.
  - Set up job 1초, checkout 1초, flutter-action 59초, 검증 182초.
- runner 이미지 줄: `Image: ubuntu-24.04`, `Version: 20261004.327.1`. 이미지 버전 줄 앞에는 runner 버전 줄 `Version: 20261002.596` 이 있다.
- 주석: "The ubuntu-latest label will migrate to Ubuntu 26 beginning October 19, 2026." (Phase 2 에서 본 예고와 같다)
- 로그 발췌 (`gh run view 38247615476 --log` 에서 타임스탬프 앞부분을 뗐다):

```text
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9
[1/9] lib/ 에 .dart 파일 없음 .......... 통과
[2/9] 배포 파일의 규칙 이름 ............ 통과
[3/9] 연습용 프로젝트 옵션 파일 ........ 통과
[4/9] example (옛 주소) ................ 통과
[5/9] recommended (묶음) ............... 통과
[6/9] base_only (기본만) ............... 통과
[7/9] base_riverpod .................... 통과
[8/9] base_codegen ..................... 통과
[9/9] overrides (끄는 설정) ............ 통과
점검 통과 (9개 중 9개)
```

### workflow 주석 커밋 `79f27e5`

- 247초는 360초 이하다. 그래서 `timeout-minutes: 10` 은 그대로 두고 25행 주석만 바꿨다.
- 바뀐 줄: `    # 정상 약 4분 7초 (연습용 프로젝트 여섯, 2026-10-12 실측 run 38247615476). 멈춰 있는 경우만 막는다.`
- 바뀌기 전 줄: `# 정상 약 2분 (spike 006). …`
- python yaml 비교 결과 `008ea3f` 와 설정이 같다 (`YAML_SAME`).

### 두 번째 push — 2026-10-12T12:18:00Z (D-09 — 묻지 않음)

```
$ git push origin gsd/v2.0-package-rework
To github.com:woodkill/woody_lints.git
   166d0be..79f27e5  gsd/v2.0-package-rework -> gsd/v2.0-package-rework
```

### run 2 — workflow 주석 커밋 `79f27e5`

- run id `38248171220`, event `push`, `completed` / `success`.
- URL: https://github.com/woodkill/woody_lints/actions/runs/38248171220
- 만들어진 시각: 2026-10-12T12:18:05Z. run 1 은 이미 끝난 뒤라 `concurrency` 로 취소된 run 은 없다.
- job `verify`: 12:18:07Z → 12:21:40Z, **213초 = 3분 33초**.
  - Set up job 1초, checkout 1초, flutter-action 61초, 검증 147초.
- 이미지 줄: `Image: ubuntu-24.04`, `Version: 20261004.327.1`.
- 로그의 버전 3줄과 `[1/9]` ~ `[9/9]` 는 run 1 과 같고, 아홉 줄 모두 `통과`, `점검 통과 (9개 중 9개)` 다.

전체 로그는 scratch 폴더 `executor-0304-Hii3IL/` 의 `run1.log` · `run2.log` 에 있다 (저장소 밖).

### 원격 확인 (읽기 전용, 2026-10-12T12:22:18Z)

```
=== git ls-remote --heads origin
79f27e57b59d738e8cf58d64d4d2263835b418a5	refs/heads/gsd/v2.0-package-rework
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
=== git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
=== gh pr list --state all --limit 5
(출력 없음 — 0건)
```

Task 3 `<automated>` 의 종료 코드는 0 이었다. 끝에 덧붙인 출력: `ID1=38247615476 T1=247 ID2=38248171220 T2=213 TM=10`.

## Task Commits

1. **Task 1: riverpod_lint 하한 ^3.1.9** - `166d0be` (feat) — `lib/riverpod.yaml`, `fixtures/overrides/analysis_options.yaml`, `CHANGELOG.md` 셋. 정답지는 들어 있지 않다.
2. **Task 2: 첫 push 확인** - 커밋 없음 (소유자 결정 `push`)
3. **Task 3: workflow 주석 실측** - `79f27e5` (docs) — `.github/workflows/verify.yml` 하나.

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP · REQUIREMENTS 의 커밋 (docs). origin 에는 올리지 않았다.

**push:** 2회 (계획대로). 실패 분기 (a) ~ (d) 는 어느 것도 일어나지 않았다.

## Files Created/Modified

- `lib/riverpod.yaml` — 10행 `^3.1.3` → `^3.1.9`
- `fixtures/overrides/analysis_options.yaml` — `version: ^3.1.9`
- `CHANGELOG.md` — `### 그 밖의 변경` 끝에 하한 상향 불릿 한 줄
- `.github/workflows/verify.yml` — 25행 주석 (YAML 불변)

## Decisions Made

- 25행 주석에는 run 1 (하한 상향 커밋) 의 job 시간을 적었다. 계획이 정한 "첫 run 의 시간과 id" 다. run 2 의 시간은 이 SUMMARY 와 STATE 에만 적었다.
- 소유자 응답의 시각은 메시지에 적혀 있지 않았다. 그래서 실행자가 받은 직후 `date -u` 로 잰 값을 썼다.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- `[3/9]` 실패 화면의 "정해진 내용:" 아래 줄들은 들여쓰기가 없어진 채 찍힌다. 실제 내용 쪽은 들여쓰기가 남는다.
  - 판정과 종료 코드에는 영향이 없는 표시상의 일이다.
  - 03-03 의 코드에서 온 것이고, 이 plan 의 범위 밖이라 고치지 않았다.
- Task 1 의 `<automated>` 는 `git diff --quiet 008ea3f -- .github/workflows/verify.yml` 을 포함한다. 그래서 Task 3 이 workflow 주석을 고친 지금은 그 한 구간이 다를 수밖에 없다. Task 1 의 gate 는 Task 1 커밋 직후(`166d0be`)에 돌려 종료 코드 0 이었다.
- 계획의 `<automated>` 셋은 `; RC=$?;` 로 이어진 꼴이라, 앞 구간이 실패해도 마지막 구간 기준으로 통과할 수 있다. 그래서 Task 1 은 `--update` 구간과 `^3.1.8` 구간을 따로 다시 돌렸다. 결과는 RU=0, 정답지 diff 0, RD=1 이고 `[3/9]` 만 실패했다.
- 계획의 `<automated>` 안 `mktemp` 은 `TMPDIR` 을 실행자 scratch 폴더로 돌려 실행했다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 3 의 plan 넷이 모두 끝났다. 다음은 phase 검증 (`/gsd-verify-work 3`) 이다.
- origin 의 작업 브랜치는 `79f27e5` 다. 이 plan 의 마무리 커밋은 origin 에 없다. Phase 4 부터의 push 는 다시 소유자에게 묻는다 (D-09).
- runner 시간은 job 213 ~ 247초 (검증 단계 147 ~ 182초) 다. Phase 4 가 규칙을 늘려도 정답지 줄 수만 바뀌므로 시간은 거의 같을 것으로 본다 (추정).
- `ubuntu-latest` 가 2026-10-19 부터 Ubuntu 26 으로 옮겨 간다. 이번 두 run 은 `ubuntu-24.04` 20261004.327.1 이었다. 그 뒤 실패하면 로그의 `Image` · `Version` 을 이 값과 spike 018 의 26.04 값(20260927.149.1)과 견준다.

## Self-Check: PASSED

- FOUND: `lib/riverpod.yaml`, `fixtures/overrides/analysis_options.yaml`, `CHANGELOG.md`, `.github/workflows/verify.yml`
- FOUND: `166d0be`, `79f27e5` (HEAD 의 조상). `git rev-list --count a940d3f..HEAD` = 2 (SUMMARY 커밋 전).
- Task 3 `<automated>` 종료 코드 0. Task 1 `<automated>` 는 `166d0be` 직후 종료 코드 0.
- plan `<verification>`: `^3.1.9` 두 자리가 맞고, 정답지 다섯 불변, `example` = `19ae5ec`, run 둘 `completed success`, `origin/main` = `90a2736`, tag `v1.3.0` 뿐, PR 0. 03-VALIDATION.md 의 03-04-T1 · T3 행이 이 plan 의 Task 1 · 3 을 가리킨다.

---
*Phase: 03-preset-split*
*Completed: 2026-10-12*
