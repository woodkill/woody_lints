---
phase: 05-documentation
plan: 09
subsystem: testing
tags: [verify-dart, readme, changelog, review-disposition, gap-closure, github-actions, push]

requires:
  - phase: 05-documentation
    provides: "05-07 의 unquotedScalar · readMarkerBlock, 05-08 의 (e) · fencedLines · enabledLanguageOptions, 05-05 의 첫 push (92d478a)"
provides:
  - "따옴표 · 고정 버전 · 맵 안의 키 순서를 받고 범위 제약은 원인을 말하며 멈추는 readShippedPluginConstraint"
  - "따옴표 version 을 받는 pubspecReleaseVersion"
  - "tool/verify.dart 문서 주석의 [1/N] · [2/N] 표기"
  - "example/README.md 의 소절 (05-09) — 지워 보기 M63 ~ M67"
  - "README 45 · 91 · 239 · 372 · 382행, CHANGELOG 2.0.0 첫 불릿, lib/riverpod.yaml 5행 주석"
  - "05-REVIEW-DISPOSITION.md — fixed 12 · deferred 1 · open 0"
  - "origin/gsd/v2.0-package-rework = 8789cfe, GitHub verify run 38502214557 success"
affects: [05-verification, 06-release]

actuals:
  tokens: 5257
  tasks: 3
  commits: 3
plan_head_before: 3519da67443ea34e9a5fed65fa32a7617e3b743d
plan_head_after: 8789cfee6d121c64fb8728b070d0a39386bef012

tech-stack:
  added: []
  patterns:
    - "배포 YAML 의 값을 읽는 reader 는 YAML 이 같은 값으로 보는 꼴(따옴표 · 줄 끝 주석 · 맵 안의 키 순서)을 받고, 받지 않기로 한 꼴은 '없다' 가 아니라 읽은 값과 받는 꼴을 말하며 멈춘다"
    - "따옴표 벗기기는 unquotedScalar 하나 — README 코드 블록 (f) · (g), plugin 선언, pubspec version 이 모두 부른다"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - example/README.md
    - README.md
    - CHANGELOG.md
    - lib/riverpod.yaml
    - .planning/phases/05-documentation/05-REVIEW-DISPOSITION.md

key-decisions:
  - "lib/riverpod.yaml 의 riverpod_lint 선언은 따옴표를 벗겨 ^X.Y.Z 와 고정 버전 X.Y.Z 를 받고, 범위 제약 등 그 밖의 꼴은 '꼴만 받는다' 와 읽은 값을 담은 문구로 종료 코드 70 이다 (05-REVIEW WR-05, 소유자 결정 R2-Q1 — M63 ~ M66)"
  - "맵 꼴의 plugin 선언은 키 줄보다 깊이 들여쓴 줄 가운데서 version: 을 찾는다 — 키 순서를 가리지 않고, 키 줄의 # 주석은 값이 아니다 (M65)"
  - "05 리뷰 처리 기록은 fixed 12 · deferred 1 (WR-06 — D-09, 마일스톤 끝 /gsd-map-codebase) · open 0 이다"
  - "gap 수정 05-07 ~ 05-09 를 git push origin gsd/v2.0-package-rework 한 줄로 올렸다 (2026-10-14T02:39:51Z, 92d478a..8789cfe, 25커밋, fast-forward, D-21 — 실행 뒤 보고). GitHub verify run 38502214557 success, job 4분 14초, 로그에 [3/10] 통과와 점검 통과 (10개 중 10개). main 90a2736 · tag v1.3.0 하나 · PR 0 그대로"

patterns-established:
  - "plugin 하한을 올릴 때 함께 고칠 자리(lib/riverpod.yaml 의 선언, fixtures/overrides 의 version:, README 의 plugin 버전 예시 둘)는 README 「이 저장소를 고치는 사람에게」 한 곳에 적고, lib/riverpod.yaml 5행 주석이 그곳을 가리킨다"

requirements-completed: [VERIFY-06, DOCS-06, DOCS-07]

coverage:
  - id: D1
    description: "readShippedPluginConstraint 가 따옴표 선언(M63) · 고정 버전 네 자리(M64) · 키 줄 주석과 뒤에 둔 version:(M65)을 받아 10개 중 10개이고, 범위 제약(M66)은 종료 코드 70 · stdout 0 바이트 · stderr 에 '꼴만 받는다' 와 그 값으로 멈춘다"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-09-PLAN.md Task 1 <automated> (복제본 기준 실행 + M63 ~ M67)"
        status: pass
    human_judgment: false
  - id: D2
    description: "pubspecReleaseVersion 이 version: \"2.0.0-dev\" (M67) 를 받아 10개 중 10개이고, tool/verify.dart 에 [1/4] · [2/4] 가 0줄이다"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-09-PLAN.md Task 1 <automated>"
        status: pass
    human_judgment: false
  - id: D3
    description: "README 산문에 지금의 plugin 버전 숫자가 없고(코드 블록 두 줄에만), 382행이 함께 고칠 자리를 모두 적으며, 45 · 91행과 CHANGELOG 2.0.0 첫 불릿이 사실과 같다; lib/riverpod.yaml 의 비주석 내용은 209e3af 그대로"
    requirement: DOCS-06
    verification:
      - kind: other
        ref: "05-09-PLAN.md Task 2 <automated> (커밋 전 · push 뒤 두 번)"
        status: pass
    human_judgment: false
  - id: D4
    description: "CHANGELOG 2.0.0 그 밖의 변경 첫 불릿이 '옮기기만 했다' 를 나누는 변경 자체로 한정한다"
    requirement: DOCS-07
    verification:
      - kind: other
        ref: "05-09-PLAN.md Task 2 <automated> (numstat 06f62a5 1/1, 옛 단정 0줄)"
        status: pass
    human_judgment: false
  - id: D5
    description: "05-REVIEW-DISPOSITION.md 의 fixed 12 행이 정해진 plan · task 의 커밋(e69470e 뒤, 정해진 파일을 바꿈)을 가리키고 WR-06 이 deferred (D-09) 다"
    verification:
      - kind: other
        ref: "05-09-PLAN.md Task 3 첫째 <automated> (chk 12행)"
        status: pass
    human_judgment: false
  - id: D6
    description: "push 전 범위 92d478a..HEAD 의 비공개 점검이 0이고, push 뒤 origin 의 작업 브랜치 == HEAD, GitHub verify 가 success 이며 로그에 [3/10] 통과와 점검 통과 (10개 중 10개)가 있다; main · tag · PR 그대로"
    requirement: VERIFY-06
    verification:
      - kind: integration
        ref: "05-09-PLAN.md Task 3 첫째 <automated> (push 전) · 둘째 <automated> (push · CI 직후)"
        status: pass
    human_judgment: false
  - id: D7
    description: "example/README.md 의 소절 (05-09) — M63 ~ M67 의 실제 결과와 읽는 법 불릿, 113행 · 116행 덧붙임의 문장"
    verification:
      - kind: other
        ref: "Task 1 <automated> 의 행 수 · 문구 grep, 절대 경로 grep 0줄"
        status: pass
    human_judgment: true
    rationale: "기록 문장의 정확성('돌린 것' 과 '코드에서 읽은 것 · 따져 본 것' 의 구분)과 표의 렌더링은 grep 이 보지 못한다"

duration: 20min
completed: 2026-10-14
status: complete
---

# Phase 5 Plan 09: gap 수정 — plugin 선언 · pubspec version reader, 문장 넷, 처리 기록, push Summary

**`readShippedPluginConstraint` 가 따옴표 · 고정 버전 · 맵 안의 키 순서를 받고 범위 제약은 읽은 값과 받는 꼴을 말하며 종료 코드 70 으로 멈추며, `pubspecReleaseVersion` 이 따옴표 version 을 받는다 (지워 보기 M63 ~ M67). README 의 산문은 plugin 버전 숫자 대신 `lib/riverpod.yaml` 의 선언을 가리키고 함께 고칠 자리를 한 곳에 적는다. 05 리뷰 처리 기록은 fixed 12 · deferred 1 · open 0 이고, gap 수정 25커밋을 올려 GitHub `verify` 가 단계 10개로 성공했다**

## Performance

- **Duration:** 20 min
- **Started:** 2026-10-14T02:25:55Z
- **Completed:** 2026-10-14T02:45:36Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments

- WR-05: `readShippedPluginConstraint` 가 키 줄을 `^([ \t]+)riverpod_lint:[ \t]*(.*?)(?:[ \t]+#.*)?[ \t]*$` 로 찾고, `#` 으로 시작하는 값은 빈 값으로 본다. 값이 있으면 스칼라, 없으면 맵 꼴 — 키 줄보다 깊이 들여쓴 줄이 이어지는 동안 그 가운데 `version:` 줄을 찾는다 (키 순서 무관). 잡은 값을 `unquotedScalar` 로 벗겨 `^\^?\d+\.\d+\.\d+$` 이면 돌려주고, 아니면 `` lib/riverpod.yaml 의 riverpod_lint 선언 `<값>` 을 읽지 못했다 — `^X.Y.Z` 나 `X.Y.Z` 꼴만 받는다 (범위 제약은 받지 않는다, 05-REVIEW.md WR-05) `` 로 `FormatException` (70). 선언이 없으면 지금의 `선언을 찾지 못했다` 그대로 (M34 동작).
- IN-01: `pubspecReleaseVersion` 이 `version:` 값을 줄 끝 주석과 따옴표를 벗겨 읽고 `^(\d+\.\d+\.\d+)(?:[-+].*)?$` 의 그룹 1 을 돌려준다.
- IN-05: 문서 주석의 `[2/4]` 넷 · `[1/4]` 하나를 `` `[2/N]` `` · `` `[1/N]` `` 으로.
- W4 · IN-02 · IN-03 · IN-04 · IN-07: README 239 · 372행이 `lib/riverpod.yaml` 의 `riverpod_lint:` 값을 가리키고 (372행의 spike 010 실측 기록은 그대로), 382행이 `ref:` 예시 둘과 plugin 하한의 함께 고칠 자리 셋을 모두 적으며, `lib/riverpod.yaml` 5행 주석이 같은 셋과 README 를 가리킨다. 45행은 묶음에 자기 정답지가 없다는 것, 91행은 검증 명령이 이름만 견준다는 것을 적는다. CHANGELOG 2.0.0 첫 불릿은 '옮기기만 했다' 를 나누는 변경 자체로 한정한다.
- 처리 기록: `05-REVIEW-DISPOSITION.md` 가 fixed 12 · deferred 1 (WR-06) · open 0 · total 13.
- push 와 CI: 범위 `92d478a..8789cfe` (25커밋) 를 올렸고 GitHub `verify` 가 성공했다.

### 지워 보기 M63 ~ M67 의 실제 결과 (모두 `git clone --local` 복제본, 2026-10-14, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9)

| # | 변경 | 종료 코드 | 실패한 단계 | 찍힌 줄 (요지) | 시간 |
|---|------|-----------|-------------|----------------|------|
| M63 | `lib/riverpod.yaml` 5행 `^3.1.9` → `"^3.1.9"` | 0 | 없음 | `점검 통과 (10개 중 10개)`, plugin 표시줄 `riverpod_lint 3.1.9` | 23초 |
| M64 | 고정 버전 `3.1.9` 를 네 자리에 (`lib/riverpod.yaml` 5행, README 198 · 234행, `fixtures/overrides` 10행) | 0 | 없음 | `[3/10]` · `[4/10]` 통과, `점검 통과 (10개 중 10개)`, stderr 는 `분석 중…` 여섯 줄뿐 | 59초 |
| M65 | 5행을 맵 꼴 네 줄로 (키 줄에 주석만, `diagnostics:` · `missing_provider_scope: true` 뒤에 `version: ^3.1.9`) | 0 | 없음 | `[3/10]` · `[4/10]` 통과, `점검 통과 (10개 중 10개)`, stderr 는 `분석 중…` 여섯 줄뿐 | 60초 |
| M66 | 5행 `^3.1.9` → `">=3.1.9 <4.0.0"` | 70 | 단계 줄 없음 (stdout 0 바이트) | stderr 한 줄: `` 파일 모양이 예상과 다르다: lib/riverpod.yaml 의 riverpod_lint 선언 `>=3.1.9 <4.0.0` 을 읽지 못했다 — `^X.Y.Z` 나 `X.Y.Z` 꼴만 받는다 (범위 제약은 받지 않는다, 05-REVIEW.md WR-05) ``, `선언을 찾지 못했다` 없음 | 2초 |
| M67 | `pubspec.yaml` 3행 `version: 2.0.0-dev` → `version: "2.0.0-dev"` | 0 | 없음 | `점검 통과 (10개 중 10개)` | 23초 |

복제본의 첫 실행(plugin 준비 포함)은 68초, 되돌린 뒤의 보통 실행은 22초 · 10개 중 10개였다. M64 · M65 가 59 · 60초로 길었던 까닭은 재지 않았다 (plugin 선언의 글자가 바뀐 실행이다). Task 1 의 `<automated>` 는 같은 변형을 다른 복제본에서 다시 돌려 rc 0 이었다 (239초).

### push 와 GitHub verify

- **push 전 점검 (Task 3 첫째 `<automated>`, push 전 rc 0):** 처리 기록 13행 · 해시 12개(`chk`), 범위 `92d478a..HEAD` 의 비공개 점검 — (1) 바뀐 파일의 HEAD 내용 0줄, (1′) `git log -p` 의 더한 줄 0줄, (2) `LEAK?` 0개, (3) `dart fix` 문구 0줄 — 과 GSD 상태 넷 밖의 깨끗한 트리, 로컬 분석 `No issues found` · 검증 `점검 통과 (10개 중 10개)`. 따로 범위의 더한 줄과 커밋 메시지에서 소유자 이메일 0줄을 확인했다.
- **precondition:** `git fetch origin` 뒤 `origin/gsd/v2.0-package-rework` = `92d478a1e55871d0a75f802596e261538482e9ba` 이고 HEAD 의 조상, 원격 head 둘(`main` = `90a2736b…`, 작업 브랜치), tag `v1.3.0` 하나, PR 0, `gh auth status` 통과 (`repo` · `workflow` scope).
- **push:** `git push origin gsd/v2.0-package-rework` 한 줄 (옵션 없음), 2026-10-14T02:39:51Z, `92d478a..8789cfe`, 25커밋, fast-forward. 첫 커밋 `ce245a5 docs(05-05): 05-05 SUMMARY — 첫 push …`, 마지막 `8789cfe docs(review): 05 리뷰 처리 기록 …`. 바뀐 파일 20개. 둘째 push 없음.
- **GitHub verify:** run `38502214557` (push, ubuntu-24.04 이미지 `20261004.327.1`), 결론 `success`, job 4분 14초 (02:39:59Z ~ 02:44:13Z) — `timeout-minutes` 10분 안. 검증 명령 약 193초. 로그 두 줄: `[3/10] 배포 파일의 구성 ................ 통과`, `점검 통과 (10개 중 10개)`. 화면은 로컬과 같았다 (`Flutter 3.47.5 / Dart 3.13.4`, `riverpod_lint 3.1.9`).
- **push 뒤 (Task 3 둘째 `<automated>`, CI 성공 직후 · 메타데이터 커밋 전, rc 0):** origin 의 작업 브랜치 == HEAD (`8789cfe`), `92d478a` 는 그 조상, 원격 head 둘 · `main` `90a2736`, tag `v1.3.0` 하나, `gh pr list --state all` 0건, HEAD 의 run 이 `completed` · `success` 이고 로그에 두 줄이 있다.

## Task Commits

1. **Task 1: readShippedPluginConstraint · pubspecReleaseVersion · 단계 번호, M63 ~ M67** - `644897f` (fix)
2. **Task 2: README · CHANGELOG · riverpod 주석의 문장 넷** - `e46cff4` (docs)
3. **Task 3: 05 리뷰 처리 기록 fixed 12 · deferred 1, push, GitHub verify** - `8789cfe` (docs)

**Plan metadata:** 이 SUMMARY 와 함께 커밋 (docs) — 로컬에만 있고 push 하지 않는다

### 처리 기록의 해시 매핑

| Finding | Disposition | 커밋 | 바꾼 파일 (`chk` 가 본 것) |
|---------|-------------|------|-----------------------------|
| WR-01 | fixed | 05-08 Task 2 `63fe3d9` | `tool/verify.dart` |
| WR-02 | fixed | 05-07 Task 3 `73f1c66` | `tool/verify.dart` |
| WR-03 | fixed | 05-08 Task 2 `63fe3d9` | `tool/verify.dart` |
| WR-04 | fixed | 05-07 Task 2 `057bef2` | `tool/verify.dart` |
| WR-05 | fixed | 05-09 Task 1 `644897f` | `tool/verify.dart` |
| WR-06 | deferred | — (D-09, 마일스톤 끝 `/gsd-map-codebase`, 소유자 결정 2026-10-14) | — |
| IN-01 | fixed | 05-09 Task 1 `644897f` | `tool/verify.dart` |
| IN-02 | fixed | 05-09 Task 2 `e46cff4` | `CHANGELOG.md` |
| IN-03 | fixed | 05-09 Task 2 `e46cff4` | `README.md` |
| IN-04 | fixed | 05-09 Task 2 `e46cff4` | `README.md` |
| IN-05 | fixed | 05-09 Task 1 `644897f` | `tool/verify.dart` |
| IN-06 | fixed | 05-07 Task 1 `5f43726` | `tool/verify.dart` |
| IN-07 | fixed | 05-09 Task 2 `e46cff4` | `README.md` |

## Files Created/Modified

- `tool/verify.dart` - `readShippedPluginConstraint` (본문 · 문서 주석), `pubspecReleaseVersion` (본문 · 문서 주석), 문서 주석 다섯 줄의 단계 번호
- `example/README.md` - 113행 · 116행 덧붙임, 소절 `### 추가 실측 — plugin 선언의 따옴표 · 고정 버전 · 맵 순서 · 범위, pubspec 의 따옴표 (05-09)` (M63 ~ M67)
- `README.md` - 45 · 91 · 239 · 372 · 382행 (다섯 줄 교체, 줄 수 그대로)
- `CHANGELOG.md` - 2.0.0 `### 그 밖의 변경` 첫 불릿 (한 줄 교체)
- `lib/riverpod.yaml` - 5행의 줄 끝 주석 (선언 값 `^3.1.9` 그대로)
- `.planning/phases/05-documentation/05-REVIEW-DISPOSITION.md` - frontmatter 13개 disposition · `open: 0`, 표 13행의 Disposition · Source

## Decisions Made

- 계획에 적힌 대로 했다. `.claude/CLAUDE.md` 수정 (WR-06), (d) 의 분류 검사 (IN-07 의 다른 안), 05-VERIFICATION.md W7 은 손대지 않았다 (P-07).
- 단계 번호는 `` `[2/N]` `` · `` `[1/N]` `` 처럼 백틱으로 감쌌다 — 계획의 "파일의 다른 문서 주석과 같은 꼴" (그 주석들은 `` `[3/N]` `` · `` `[4/N]` `` 꼴). 백틱 없는 `[2/4]` 는 dartdoc 에서 참조 링크 문법이기도 하다.
- 맵 꼴에서 `version:` 줄의 값이 비어 있거나 `#` 으로 시작하면 그 줄을 건너뛰고 맵 안을 계속 찾는다 — 찾지 못하면 `선언을 찾지 못했다` 다. 키 줄이 여럿이면 처음 선언을 찾은 키 줄의 값을 쓴다 (지금 파일에는 키 줄이 하나다).
- README 382행의 절 이름은 실제 제목에 맞췄다 — 「설치」 (9행), 「`ref: main` 에서 tag 로 옮기기」 (324행), 「조각마다의 설정」 (190행), 「규칙 · plugin 진단 끄기」 (216행). 계획의 글자와 같다.

## Deviations from Plan

None - plan executed exactly as written.

네 `<automated>` 는 모두 적힌 그대로 통과했다 (고친 판 없음):

| 검증 | 적힌 그대로 (task 커밋 전 · push 전) | 적힌 그대로 (뒤의 재실행) |
|------|--------------------------------------|---------------------------|
| Task 1 | rc 0 (239초) | 다시 돌리지 않았다 — Task 2 가 `lib/riverpod.yaml` 주석을 바꿔 `git diff --quiet 209e3af -- lib` 가 그 뒤로는 거짓이 되도록 짜인 단언이다 (Task 1 커밋 시점의 상태를 본다) |
| Task 2 | rc 0 | rc 0 (push · CI 뒤, 메타데이터 커밋 전) |
| Task 3 첫째 | rc 0 (push 전) | rc 0 (push · CI 뒤, 메타데이터 커밋 전) |
| Task 3 둘째 | — (push 뒤에만 참) | rc 0 (CI 성공 직후, HEAD = `8789cfe` = origin) |

**Total deviations:** 0
**Impact on plan:** 없음.

## Issues Encountered

None. 지워 보기는 모두 복제본에서 했고 작업 트리의 `README.md` · `lib` · `RULES.md` · `pubspec.yaml` · `fixtures` 는 변형하지 않았다. 저장소 파일 · 커밋 메시지 · 이 SUMMARY 에 실제 홈 폴더 경로나 임시 폴더 경로는 0줄이다.

## 열린 채 남는 것

- 05-VERIFICATION.md W7 (`pubspec.yaml` 13 ~ 15행 주석) — 손대지 않았다 (소유자 결정 2026-10-14).
- 05-REVIEW WR-02 부수 문제 — (f) 의 `version:` 을 `riverpod_lint:` 맵 아래로 좁히는 일 (소유자 승인 밖). README 에 pubspec 예시 블록을 넣으면 그 `version:` 도 견준다. 지금 README 에는 없다.
- WR-06 — `.claude/CLAUDE.md` 의 어긋난 지시는 마일스톤 끝 `/gsd-map-codebase` 에서 고친다 (D-09, deferred).
- 05-08 SUMMARY 의 열린 항목 그대로 — `tool/measure_rules.dart` 의 `readRulesTable` 동작, `readUpstreamRules` 안 `readSet` 동작 (소유자 결정 R2-Q4), (d) 의 분류 검사 (P-07), M52 · M57 · M58 이 가른다고 적은 느슨한 구현은 따져 본 것.
- 이 plan 에서 따져 본 것 — M64 가 가른다고 적은 "`^X.Y.Z` 만 받는 구현" 과 M65 가 가른다고 적은 "키 순서를 보는 구현" · "키 줄의 `# 주석` 을 값으로 잡는 구현" 은 돌리지 않았다. M64 · M65 의 실행 시간(59 · 60초)이 늘어난 까닭도 재지 않았다.
- 메타데이터 커밋(이 SUMMARY · STATE · ROADMAP · REQUIREMENTS)은 origin 에 없다 — 원격의 작업 브랜치는 `8789cfe` 다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 5 의 gap 수정 계획 셋(05-07 ~ 05-09)이 모두 끝났다 — 재검증(`/gsd-verify-work` 또는 phase 검증) 준비됨. 리뷰 처리 기록은 open 0 이다.

---
*Phase: 05-documentation*
*Completed: 2026-10-14*

## Self-Check: PASSED

- FOUND: tool/verify.dart, example/README.md, README.md, CHANGELOG.md, lib/riverpod.yaml, .planning/phases/05-documentation/05-REVIEW-DISPOSITION.md
- FOUND: 644897f, e46cff4, 8789cfe (HEAD 의 조상, origin 의 작업 브랜치 끝)
