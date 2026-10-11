---
phase: 01-baseline-and-toolchain
plan: 04
subsystem: docs
tags: [versioning, semver, decision-order, gap-closure, uat, review-disposition, riverpod_lint, flutter_lints]

# Dependency graph
requires:
  - phase: 01-02
    provides: "`VERSIONING.md` — 판정 순서 · 기준표 · 실제 사례 · CHANGELOG 항목 형식. 이 plan 이 그 가운데 판정 순서 1번과 사유·사례 문구를 고쳤다"
  - phase: 01-03
    provides: "저장소 고정 SDK Flutter 3.47.5 / Dart 3.13.4 — `fvm dart analyze` 와 문서에 적은 `--fatal-*` 기본값의 기준 SDK"
provides:
  - "`VERSIONING.md` 판정 순서 1번 = 세 조건 (설정·SDK 고침 / `flutter_lints` · `riverpod_lint` 다음 major 상향 / 이미 켜져 있던 규칙의 심각도 warning 이상 상향) — 기준표의 major 다섯 행(38-42행)을 모두 묻는다"
  - "판정 순서를 두 사례와 기준표 여덟 행에 대입해 등급을 계산하는 검증 명령 (plan 01-04 Task 2 `<automated>`) — 문자열 존재가 아니라 계산값과 문서값을 비교한다"
  - "`01-CONTEXT.md` 의 D-02 · D-09 ① 수정 주석 (38행, 70행) — 원문 보존, 소유자 결정 2건과 최종 문구 기록"
  - "`01-REVIEW-DISPOSITION.md`: WR-01 · WR-02 · WR-04 fixed, WR-03 open + 부분 해소 메모, `open: 7`"
affects: [phase-3-presets, phase-4-rules, phase-5-docs, phase-6-release]

# Actuals (#2632)
actuals:
  tokens: 2082     # chars/4 — `git diff b30fb3b..HEAD` 의 문자 수 8331 (추적 파일 3개의 실제 diff). plan 의 estimate 는 45000 이었다
  tasks: 2         # Task 1 (auto), Task 2 (auto)
  commits: 2       # MEASURED: git rev-list --count b30fb3b74d46475099281eea35f54a2a8b69c789..HEAD (SUMMARY 작성 시점)
plan_head_before: b30fb3b74d46475099281eea35f54a2a8b69c789
plan_head_after: 6b9eec8d840884ffe8cafa3bcfcd624b908a4b2c

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "결정 문구를 다듬을 때는 원문을 지우지 않고 바로 아래에 `**수정 (날짜, gap id):**` 주석 줄을 덧붙인다 — 기준 커밋 대비 `diff` 의 삭제 줄 0 을 검증으로 고정한다"
    - "정책 문서의 검증은 문구 존재가 아니라 대입 계산으로 한다 — 판정 순서 문장을 읽어 조건이 어느 번호에 있는지 알아낸 뒤 사례·기준표 행의 사실을 넣어 등급을 계산하고 문서에 적힌 등급과 비교한다"
    - "검증 명령은 HEAD 가 아니라 고정 커밋(`23d2674`)과 비교한다 — 커밋 전·후 판정이 같다"

key-files:
  created:
    - .planning/phases/01-baseline-and-toolchain/01-04-SUMMARY.md
  modified:
    - VERSIONING.md
    - .planning/phases/01-baseline-and-toolchain/01-CONTEXT.md
    - .planning/phases/01-baseline-and-toolchain/01-REVIEW-DISPOSITION.md

key-decisions:
  - "`VERSIONING.md` 판정 순서 1번은 세 조건이다 — 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하나 / `flutter_lints` 나 `riverpod_lint` 를 다음 major 로 올리나 (6 → 7, 3 → 4) / 이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나. 규칙을 새로 켜는 것은 처음부터 warning · error 등급이어도 2번(minor)이고, 같은 major 안의 plugin 하한 상향(`^3.1.3` → `^3.1.9`)도 2번(minor)이다 (소유자 결정 2건, 2026-10-11)"
  - "판정 순서 1번 문장은 `01-CONTEXT.md` 70행의 \"최종 문구\" 와 글자 그대로 같은 조건 문구를 쓰는 고정 문자열이다. 바꾸려면 두 파일과 plan 01-04 의 검증 명령을 함께 바꾼다"
  - "리뷰 WR-03 은 open 이다 — major 행 누락(기준표 40·41행)만 닫혔다. README/CHANGELOG 만 고침(47행 patch vs 4번 올리지 않음)과 새 프리셋 추가(45행 minor vs 3번 patch)는 D-05 를 건드리는 소유자 결정이 필요하다"
  - "`VERSIONING.md` 의 \"자동 검사\" 는 등급 기준이 아니라 받는 쪽이 겪는 일의 설명이다. `dart analyze` 는 `--fatal-warnings` 기본 켜짐 / `--fatal-infos` 기본 꺼짐 (Dart 3.13.4), `flutter analyze` 는 둘 다 기본 켜짐 (Flutter 3.47.5) — 2026-10-11 확인"

patterns-established:
  - "결정 원문 보존 주석: `01-CONTEXT.md` 의 D-NN 아래에 들여쓴 `- **수정 (YYYY-MM-DD, UAT G-NN-N):**` 한 줄"
  - "리뷰 지적을 일부만 닫을 때는 disposition 을 `open` 으로 두고 Source 칸에 \"어디까지 닫았고 무엇이 남았나\" 를 적는다. 오래 남는 기록은 SUMMARY 에도 남긴다"

requirements-completed: [BASE-03]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "`01-CONTEXT.md` 의 D-02(37행)와 D-09 ①(69행) 바로 아래에 `수정 (2026-10-11, UAT G-01-1)` 주석이 한 줄씩 있고(38행, 70행), 원문·D-04·D-05 표·D-09 3. 은 글자 그대로다 — 추가 2줄, 삭제 0줄"
    requirement: "BASE-03"
    verification:
      - kind: other
        ref: "plan 01-04 Task 1 <automated> verify (T1-01 ~ T1-21: `23d2674` 대비 diff 삭제 0 · 추가 2, 주석 줄 번호 38 70, 원문 4문장 보존, 최종 문구 대조, D-05 표 12줄 대조, 범위 밖 파일 불변) → 출력 없음, rc=0 (bash · zsh, 커밋 전·후)"
        status: pass
      - kind: other
        ref: "git show --name-only --format= 83f9768 → `.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md` 한 줄"
        status: pass
    human_judgment: false
  - id: D2
    description: "`VERSIONING.md` 판정 순서 1번이 세 조건으로 기준표의 major 다섯 행(38-42행)을 모두 묻고, 1.3.0 · 2.0.0 두 사례와 기준표 여덟 행(38-44행, 46행)을 대입한 계산값이 문서에 적힌 등급과 같다 (46행은 2번 minor)"
    requirement: "BASE-03"
    verification:
      - kind: other
        ref: "plan 01-04 Task 2 <automated> verify 의 대입 검사 (T2-07 ~ T2-16) → `substitution: 1.3.0 computed=minor documented=minor / 2.0.0 computed=major documented=major`, `table: 38=major/major 39=major/major 40=major/major 41=major/major 42=major/major 43=minor/minor 44=minor/minor 46=minor/minor`, rc=0 (bash · zsh, 커밋 전·후)"
        status: pass
    human_judgment: false
  - id: D3
    description: "1.3.0 사례가 1번의 세 조건을 모두 답하고 warning 등급 새 규칙을 2번에서 다루는 이유가 적혀 있다; 판정 순서 아래 단락이 다음 major 상향(1번)과 같은 major 안 상향(2번)을 갈라 적는다; 기준표 사유의 major 범위가 1번과 같고 \"에만\" 이 없다 (WR-04); \"자동 검사\" 가 어느 명령인지와 등급 기준이 아님이 적혀 있다 (WR-02)"
    requirement: "BASE-03"
    verification:
      - kind: other
        ref: "plan 01-04 Task 2 <automated> verify 의 문구 검사 (T2-17 ~ T2-27) → rc=0; `wc -l VERSIONING.md` = 127"
        status: pass
    human_judgment: false
  - id: D4
    description: "`VERSIONING.md` 의 기준표 13줄(헤더·구분선·등급 행 11)과 `## CHANGELOG 항목 형식` 절이 `23d2674` 와 바이트 단위로 같다 (D-05, D-12 ~ D-16 불변)"
    requirement: "BASE-03"
    verification:
      - kind: other
        ref: "plan 01-04 Task 2 <automated> verify (T2-04 표 줄 대조, T2-05 등급 행 11, T2-06 CHANGELOG 절 대조) → rc=0; 별도 `diff <(git show 23d2674:VERSIONING.md | sed …) <(sed … VERSIONING.md)` 두 번 → 차이 없음"
        status: pass
    human_judgment: false
  - id: D5
    description: "`01-REVIEW-DISPOSITION.md` 에서 WR-01 · WR-02 · WR-04 가 frontmatter 와 표 모두 fixed, WR-03 은 open 이고 Source 칸에 부분 해소 메모가 있으며 `open: 7` / `total: 10` 이다"
    verification:
      - kind: other
        ref: "plan 01-04 Task 2 <automated> verify (T2-28 ~ T2-36: awk 로 frontmatter disposition 넷, `grep -qx 'open: 7'`, `grep -qxF` 로 표 네 행) → rc=0"
        status: pass
    human_judgment: false
  - id: D6
    description: "소유자가 `VERSIONING.md` 의 판정 순서에 1.3.0 · 2.0.0 두 사례와 새로 들어간 두 경우(`flutter_lints` 6 → 7, `riverpod_lint` 3 → 4), 같은 major 안의 상향(3.1.3 → 3.1.9)을 직접 대입해 문서대로 나오고 설명이 납득됨을 확인한다 (UAT 1번 재실행)"
    requirement: "BASE-03"
    verification: []
    human_judgment: true
    rationale: "\"읽고 판정할 수 있다\" (ROADMAP Phase 1 success criterion 4) 는 사람의 이해 여부다. 자동 검사는 대입 계산 결과까지 확인하지만 설명이 납득되는지는 소유자만 안다. plan 01-04 Task 2 의 `<human-check>` — `workflow.human_verify_mode: end-of-phase` 에 따라 `/gsd-verify-work 1` 로 넘긴다"

# Metrics
duration: 3min
completed: 2026-10-11
status: complete
---

# Phase 1 Plan 04: VERSIONING 판정 순서 1번 수정 (UAT G-01-1) Summary

**`VERSIONING.md` 판정 순서 1번을 기준표의 major 다섯 행을 모두 묻는 세 조건(설정·SDK 고침 / `flutter_lints` · `riverpod_lint` 다음 major 상향 / 이미 켜져 있던 규칙의 심각도 상향)으로 고쳐, 1.3.0 을 문자 그대로 대입해도 minor 가 나오게 했다 — 결정 원문은 `01-CONTEXT.md` 에 주석으로 보존**

## Performance

- **Duration:** 3 min (219초)
- **Started:** 2026-10-11T08:17:36Z
- **Completed:** 2026-10-11T08:21:15Z
- **Tasks:** 2 / 2
- **Files modified:** 3 (`VERSIONING.md`, `01-CONTEXT.md`, `01-REVIEW-DISPOSITION.md`)
- **실행 방식:** 순차 실행 (main checkout `/Users/woody/dv/woody/woody_lints`, 브랜치 `gsd/v2.0-package-rework`). worktree 가 아니므로 `fvm dart analyze` 는 저장소 루트에서 그대로 돌았다

## Accomplishments

- **UAT gap G-01-1 을 닫았다.** 판정 순서 1번의 둘째 조건 "자동 검사가 막힐 수 있나" 는 기준표 42행의 **결과 칸**만 질문으로 옮긴 문구라, 1.3.0 사례(warning 11 / error 1 등급 규칙을 처음 켠 변경)를 대입하면 major 로 읽혔다. 이를 **변경 종류** 문구 "이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나" 로 좁혔다 (소유자 결정 1, UAT 뒤)
- **1번이 기준표의 major 다섯 행을 모두 묻는다.** 좁히면서 빠지게 되는 `flutter_lints` 6 → 7 (40행)과 `riverpod_lint` 3 → 4 (41행)를 1번의 둘째 조건으로 넣었다 (소유자 결정 2, 계획 검토 뒤). "다음 major 로" 와 "맨 앞자리가 바뀜" 한정이 46행(같은 major 안의 하한 상향)을 2번에 남긴다
- **1.3.0 사례가 세 조건을 모두 답한다** (minor 그대로). 새로 켜진 `riverpod_lint` 3.1.3 규칙 15개 가운데 11개가 warning, 1개가 error 라는 사실과, 그것을 1번이 아니라 2번에서 다루는 이유(새 규칙은 CHANGELOG "새로 생기는 경고" 표의 `강도` 열로 미리 알린다)를 적었다
- **기준표 사유를 1번과 같은 범위로 맞췄다** — "에만" 제거 (WR-04), D-04 의 이유를 변경 종류 기준으로 다시 씀, "자동 검사" 가 어느 명령인지 설명 추가 (WR-02)
- **결정 이력을 지우지 않고 남겼다.** `01-CONTEXT.md` 의 D-02 · D-09 ① 원문은 글자 그대로이고, 바로 아래 주석 두 줄이 무엇을 왜 다듬었는지 적는다
- **검증이 문구 존재가 아니라 계산이다.** 검증 명령이 문서에서 1번·2번 문장을 읽어 두 사례와 기준표 여덟 행의 등급을 계산하고 문서에 적힌 등급과 비교한다 — phase 검증자가 지적한 "Insufficient assertions" 를 이 plan 범위에서 해소

## Task Commits

Each task was committed atomically:

1. **Task 1: 01-CONTEXT.md 에 D-02 셋째 문장과 D-09 ① 의 문구 수정을 주석으로 기록** — `83f9768` (docs)
   - SHA: `83f97687ef83a8b1e53f07030d0a0a726cdcba78`
   - 제목: `docs(01-04): D-02 · D-09 ① 문구 수정을 CONTEXT 에 주석으로 기록 (UAT G-01-1)`
   - 파일: `.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md` (1 file changed, 2 insertions(+))
2. **Task 2: VERSIONING.md 판정 순서 1번 수정 + 리뷰 기록 갱신** — `6b9eec8` (docs)
   - SHA: `6b9eec8d840884ffe8cafa3bcfcd624b908a4b2c`
   - 제목: `docs(01-04): VERSIONING.md 판정 순서 1번이 기준표의 major 다섯 행을 모두 묻게 고침 (UAT G-01-1)`
   - 파일: `VERSIONING.md`, `.planning/phases/01-baseline-and-toolchain/01-REVIEW-DISPOSITION.md` (2 files changed, 17 insertions(+), 13 deletions(-))

**Plan metadata:** 이 SUMMARY 와 `STATE.md` / `ROADMAP.md` 를 담는 `docs(01-04):` 커밋 (이 파일을 쓴 직후 만든다)

`git log --oneline b30fb3b..HEAD` (SUMMARY 작성 시점):

```text
6b9eec8 docs(01-04): VERSIONING.md 판정 순서 1번이 기준표의 major 다섯 행을 모두 묻게 고침 (UAT G-01-1)
83f9768 docs(01-04): D-02 · D-09 ① 문구 수정을 CONTEXT 에 주석으로 기록 (UAT G-01-1)
```

## Files Created/Modified

- `VERSIONING.md` — 문구 수정 7곳 (A-1 ~ A-7). 123줄 → 127줄. 기준표 13줄과 `## CHANGELOG 항목 형식` 절은 불변
- `.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md` — 주석 2줄 추가 (38행 D-02 아래, 70행 D-09 ① 아래). 275줄 → 277줄. 삭제 0
- `.planning/phases/01-baseline-and-toolchain/01-REVIEW-DISPOSITION.md` — WR-01 · WR-02 · WR-04 `open` → `fixed` (frontmatter + 표), `open: 10` → `open: 7`, WR-03 표 행의 Source 칸에 메모

## Task 1 증거

### `diff` 결과 — 추가 2 / 삭제 0

기준 커밋 `23d2674` 의 `01-CONTEXT.md` 와 작업 트리 파일을 `diff` 한 결과:

```text
deleted(<)=0  added(>)=2
```

`git diff --numstat` (커밋 전): `2	0	.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md`

주석 줄의 자리 (`grep -n '수정 (2026-10-11, UAT G-01-1)'`): **38행** (D-02 바로 아래, 2칸 들여쓰기), **70행** (D-09 ① 바로 아래, 7칸 들여쓰기).

### automated verify

plan 의 `<automated>` 블록을 그대로 추출해 실행했다. 통과하면 출력이 없다.

| 시점 | 셸 | 출력 | 종료 코드 |
|------|----|------|-----------|
| 커밋 전 | bash | (없음) | 0 |
| 커밋 전 | zsh | (없음) | 0 |
| Task 2 편집 뒤 | bash | (없음) | 0 |
| 두 커밋 뒤 | bash | (없음) | 0 |

## Task 2 증거

### automated verify 출력 원문

```text
substitution: 1.3.0 computed=minor documented=minor / 2.0.0 computed=major documented=major
table: 38=major/major 39=major/major 40=major/major 41=major/major 42=major/major 43=minor/minor 44=minor/minor 46=minor/minor
```

종료 코드 0. bash 와 zsh 에서 같은 두 줄이 나왔고, 커밋 전과 커밋 뒤에 다시 돌려도 같았다. 앞줄은 G-01-1 의 truth("문자 그대로 대입하면 실제 사례 절이 적은 등급과 같은 답이 나온다")를, 뒷줄은 소유자 둘째 결정("1번이 기준표의 major 다섯 행을 모두 묻고 46행은 2번에 남는다")을 계산으로 확인한 것이다. 45 · 47 · 48행은 계산하지 않는다 (WR-03 의 남은 범위).

### `wc -l VERSIONING.md`

```text
     127 VERSIONING.md
```

기대값 127 (123 + A-2 의 2줄 + A-5 의 1줄 + A-6 의 1줄) 과 같다. 7곳 외의 변경은 없다 — `git diff --numstat` 은 `9	5	VERSIONING.md`.

### 판정 순서 1번 (수정 뒤, 25행)

```text
1. 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하나, `flutter_lints` 나 `riverpod_lint` 를 다음 major 로 올리나 (6 → 7, 3 → 4 처럼 맨 앞자리가 바뀜), 이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나 → major. 맨 앞자리(major) 를 올린다.
```

`01-CONTEXT.md` 70행의 "최종 문구" 와 같은 조건 문구다 (Task 1 T1-14 와 Task 2 T2-15 · T2-27 이 같은 문자열로 대조).

### 수정 7곳의 자리 (수정 뒤 줄 번호)

| 항목 | 줄 | 내용 |
|------|----|------|
| A-1 | 25 | 판정 순서 1번 — 세 조건 |
| A-2 | 30 | 설명 단락 — 다음 major 상향은 1번, 같은 major 안 상향은 2번, 새 규칙은 2번 |
| A-3 | 54 | 기준표 사유 첫 불릿 — major 범위를 1번과 같게, "에만" 제거 |
| A-4 | 56 | 기준표 사유 셋째 불릿 — D-04 의 이유를 변경 종류 기준으로 |
| A-5 | 57 | 기준표 사유 넷째 불릿 (신규) — "자동 검사" 설명 |
| A-6 | 64-65 | 1.3.0 사례 — 세 조건의 답 + warning 등급 새 규칙 (하위 불릿 3개가 됨) |
| A-7 | 68 | 2.0.0 사례 — 어느 조건이 "예" 인지 |

### 불변 확인 (D-05, D-12 ~ D-16)

- 기준표의 표 줄(`|` 로 시작) 13줄: `git show 23d2674:VERSIONING.md` 의 같은 부분과 `diff` → 차이 없음
- `## CHANGELOG 항목 형식` 절 전체: 같은 방법으로 `diff` → 차이 없음

### 리뷰 기록 변경 (`01-REVIEW-DISPOSITION.md`)

| Finding | 이전 | 이후 | Source 칸 |
|---------|------|------|-----------|
| WR-01 | open | **fixed** | `01-04-PLAN.md (UAT G-01-1)` |
| WR-02 | open | **fixed** | `01-04-PLAN.md (UAT G-01-1)` |
| WR-03 | open | **open (유지)** | `01-04-PLAN.md (UAT G-01-1) 가 major 행 누락(기준표 40·41행)만 닫음. README/CHANGELOG 만 고침(47행)과 새 프리셋 추가(45행)는 남음` |
| WR-04 | open | **fixed** | `01-04-PLAN.md (UAT G-01-1)` |

frontmatter: `open: 10` → `open: 7`, `total: 10` 그대로, `recorded:` 그대로. WR-05 · WR-06 · IN-01 ~ IN-04 는 건드리지 않았다 (모두 open).

## WR-03 부분 해소 기록

리뷰 WR-03 은 판정 순서와 기준표가 다른 답을 내는 세 경우를 들었다. 세 경우 가운데 `flutter_lints` / `riverpod_lint` major 상향(기준표 40·41행)은 소유자 결정(2026-10-11, 계획 검토 뒤)으로 이 plan 이 1번 질문에 넣어 닫았다. README/CHANGELOG 만 고침(47행 patch vs 4번 올리지 않음)과 새 프리셋 추가(45행 minor vs 3번 patch)는 남아 있고 D-05 를 건드리는 소유자 결정이 필요하다.

- 그래서 WR-03 의 disposition 은 `open` 그대로다
- `01-REVIEW-DISPOSITION.md` 의 Source 칸에도 같은 메모가 있지만, 그 파일의 보존 보장은 `deferred` 사유에만 적혀 있다. 오래 남는 기록은 이 SUMMARY 다
- 이 plan 은 판정 순서 3 · 4번과 기준표 45 · 47 · 48행을 건드리지 않았고, 검증 명령도 그 행에 대해 아무것도 단정하지 않는다 — 남은 두 경우를 더 나쁘게도 만들지 않았다
- 다음에 WR-03 을 여는 사람이 정할 것: (1) README/CHANGELOG 만 고친 변경은 patch 인가 올리지 않는가, (2) 새 프리셋 파일 추가는 판정 순서의 몇 번에서 잡히게 할 것인가, (3) `VERSIONING.md` 자신을 고친 경우는 48행의 "저장소 안쪽" 에 드는가

## WR-02 축소 이유

리뷰는 '자동 검사' 의 정의를 요구했지만, 소유자가 택한 방향 (나) 에서는 자동 검사가 등급 경계가 아니라 받는 쪽이 겪는 일의 설명이 되므로 어느 명령을 기준으로 삼는다는 '정의' 대신 `dart analyze` / `flutter analyze` 의 실측 동작을 적는 '설명' 으로 해소했다 — 사용 프로젝트 5개의 CI 명령은 이 저장소에서 알 수 없다.

## Plan 검증 결과

### `fvm dart analyze` (커밋 전 린터)

두 task 모두 커밋 직전에 저장소 루트에서 한 번씩 돌렸다 (Dart 3.13.4).

```text
Analyzing woody_lints...
No issues found!
```

### origin 불변 · push 없음

```text
$ git rev-parse origin/main
90a2736b8d998c84467faf562a0fec720b797eaf
```

기대값 `90a2736b8d998c84467faf562a0fec720b797eaf` 과 같다 (네트워크 없이 로컬 ref 로 확인). 브랜치 `gsd/v2.0-package-rework` 에는 upstream 이 설정되어 있지 않고, 이 plan 은 아무것도 push 하지 않았다. 로컬 `main` ref 의 마지막 reflog 항목은 2026-10-11 10:28:57 +0900 의 커밋으로, 이 plan 실행 전의 것이다 — 건드리지 않았다.

### 범위 밖 파일

`git diff --quiet 23d2674 -- lib README.md analysis_options.yaml pubspec.yaml .fvmrc .vscode CHANGELOG.md .gitignore` → rc=0 (두 task 의 T1-21 · T2-37 과 별도 실행 모두). 버전 번호는 올리지 않았다 (`pubspec.yaml` 은 `2.0.0-dev` 그대로).

### must_haves 의 prohibitions

| 금지 사항 | 확인 |
|-----------|------|
| `lib/`, `README.md`, 루트 `analysis_options.yaml`, `pubspec.yaml`, `.fvmrc`, `.vscode/`, `CHANGELOG.md`, `.gitignore` 불변; 버전 불변; `main` · origin 불변; push 없음 | 위 `git diff --quiet 23d2674 -- …` rc=0, `git rev-parse origin/main` = `90a2736…`, upstream 없음. 두 task 커밋이 담은 파일은 합쳐서 셋뿐이다 |
| D-04 · D-05 · D-09 3. 불변; WR-03 은 major 행 누락만 닫고 open 유지 | T1-08 (D-04 원문) · T1-09 (D-09 3. 원문) · T1-19 (CONTEXT 의 D-05 표 12줄) · T2-04 ~ T2-06 (VERSIONING 기준표·CHANGELOG 절) · T2-31 (WR-03 = open) 모두 통과 |
| `01-CONTEXT.md` 의 기존 줄을 지우거나 고치지 않는다 | T1-04 (`diff` 의 `<` 줄 0) · T1-05 (추가 정확히 2) 통과 |

판정은 사람 검토 대상이다 (`verification: judgment`). 위는 실행자가 모은 증거다.

### threat_model 의 mitigate 항목

| Threat | 적용한 완화 | 결과 |
|--------|-------------|------|
| T-01-10 (기준표·CHANGELOG 절 변조) | Task 2 verify 가 표 줄 전부와 CHANGELOG 절 전체를 `23d2674` 와 대조하고 등급 행 11 을 다시 센다 (T2-04 ~ T2-06) | 통과 |
| T-01-11 (결정 원문의 소리 없는 재작성) | 수정은 주석 줄 추가로만 했다. Task 1 verify 가 삭제 줄 0, 원문 문장 보존, 주석의 날짜·gap id·근거 파일 경로를 확인한다 (T1-04 ~ T1-18) | 통과 |
| T-01-12 (DISPOSITION frontmatter 손상) | frontmatter 는 값 셋과 `open:` 수만, 표는 네 행만 바꿨다. Source 메모에 세로줄 문자 없음. verify 가 frontmatter(awk)와 표(grep) 양쪽을 확인한다 (T2-28 ~ T2-36) | 통과 |

`accept` 항목(T-01-13, T-01-SC)은 조치 대상이 아니다. 이 plan 은 어떤 패키지도 설치하지 않았다.

### 소유자 읽기 검증 → end-of-phase UAT

Task 2 의 `<human-check>` 는 mid-flight 로 멈추지 않고 넘겼다 (`workflow.human_verify_mode: end-of-phase`). 소유자가 `/gsd-verify-work 1` 로 UAT 1번을 다시 하며 확인할 것:

1. **1.3.0** — 1번의 세 조건이 모두 "아니오" → 2번 "예" → minor. 새로 켜진 규칙에 warning 등급이 있었다는 사실이 적혀 있고, 그것이 왜 1번이 아니라 2번인지 문서만 읽고 납득되는가
2. **2.0.0** — 1번의 첫째 조건(SDK 를 올려야 한다)이 "예" → major
3. **새로 들어간 두 경우** — 맨 앞자리가 바뀌는 큰 업그레이드(`flutter_lints` 6 → 7, `riverpod_lint` 3 → 4)는 1번의 둘째 조건에서 "예" → major 로, 기준표의 그 두 줄과 같은가
4. **같은 major 안 상향** — 맨 앞자리가 같은 작은 업그레이드(3.1.3 → 3.1.9)는 1번에서 "아니오" 로 지나가 2번에서 "예" → minor 로, 기준표의 그 줄과 같은가

`01-UAT.md` 의 G-01-1 은 이 SUMMARY 가 있으면 `/gsd-verify-work` 재실행 때 resolved 로 정리된다.

### `01-VALIDATION.md` 에 아직 없는 행

`01-VALIDATION.md` 의 per-task 표에 `01-04-T1` / `01-04-T2` 행이 아직 없다 (지금 있는 것은 `01-01` ~ `01-03` 의 행뿐이다). 행 추가는 실행 뒤 `/gsd-validate-phase 1` 의 일이다. 재료:

| Task ID | Plan | Wave | Requirement | Threat ref | automated 요약 |
|---------|------|------|-------------|------------|----------------|
| 01-04-T1 | 01-04 | 4 | BASE-03 | T-01-11 | CONTEXT 주석 2줄 추가·삭제 0·원문 보존 (`23d2674` 대비 `diff`, 줄 번호 38 70 고정, 최종 문구 대조) |
| 01-04-T2 | 01-04 | 4 | BASE-03 | T-01-10, T-01-12 | 판정 순서 대입 계산: 두 사례 + 기준표 여덟 행, 기준표·CHANGELOG 절 바이트 대조, DISPOSITION 상태 |

두 task 의 검증은 `구조 검사 (shell)` 이고 Task 2 는 여기에 manual (`<human-check>` → end-of-phase UAT) 이 붙는다.

## Decisions Made

- **판정 순서 1번 = 세 조건.** 소유자 결정 2건(2026-10-11)을 그대로 옮겼다. 실행 중 새로 정한 것은 없다 — plan 의 문구를 글자 그대로 썼다
- **WR-03 은 open 유지.** 남은 두 경우는 D-05 를 건드리는 소유자 결정이라 이 plan 의 범위 밖이다
- **"자동 검사" 는 설명으로.** `dart analyze` 와 `flutter analyze` 중 어느 쪽을 "기준" 으로 삼는다고 적지 않았다

## Deviations from Plan

None - plan executed exactly as written.

두 task 의 `<action>` 문구를 글자 그대로 옮겼고, 두 `<automated>` verify 가 첫 실행에 통과했다. 자동 수정(Rule 1 ~ 3)도 구조 변경 질문(Rule 4)도 없었다.

**Total deviations:** 0
**Impact on plan:** 없음

## Issues Encountered

None.

## Known Stubs

없음. 이 plan 이 바꾼 세 파일에 자리 표시·TODO·빈 값은 새로 생기지 않았다. (`CHANGELOG.md` 11행의 `(Phase 4 실측 후 채움)` 은 01-03 이 `.planning/WINDOWS.md` 에 이미 기록한 것이고 이 plan 은 `CHANGELOG.md` 를 건드리지 않았다.)

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 01 의 plan 네 개가 모두 SUMMARY 를 가졌다. 다음 단계는 소유자의 `/gsd-verify-work 1` (UAT 1번 재실행 — 위 "소유자 읽기 검증" 의 네 항목) 이다
- Phase 3 / 4 가 plugin 하한 상향·규칙 추가의 등급을 매길 때 `VERSIONING.md` 의 판정 순서와 기준표·사례가 같은 답을 낸다: 같은 major 안의 `riverpod_lint` 하한 상향(`^3.1.3` → `^3.1.9`)과 warning 등급 규칙 추가는 minor 다
- **남은 것 (이 plan 의 범위 밖):** 리뷰 WR-03 의 두 경우(47행, 45행), WR-05, WR-06, IN-01 ~ IN-04 는 open 이다. Phase 5 가 README/CHANGELOG 를 다시 쓰기 전에 WR-03 의 첫째 경우(README 만 고친 커밋의 등급)를 소유자가 정해 두면 좋다

---
*Phase: 01-baseline-and-toolchain*
*Completed: 2026-10-11*

## Self-Check: PASSED

| 항목 | 결과 |
|------|------|
| `.planning/phases/01-baseline-and-toolchain/01-04-SUMMARY.md` 존재 | FOUND |
| `VERSIONING.md` 존재 (127줄) | FOUND |
| `.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md` 존재 | FOUND |
| `.planning/phases/01-baseline-and-toolchain/01-REVIEW-DISPOSITION.md` 존재 | FOUND |
| 커밋 `83f9768` 이 HEAD 의 조상 | FOUND |
| 커밋 `6b9eec8` 이 HEAD 의 조상 | FOUND |
| Task 1 `<automated>` 재실행 (두 커밋 뒤) | rc=0, 출력 없음 |
| Task 2 `<automated>` 재실행 (두 커밋 뒤) | rc=0, `substitution:` · `table:` 두 줄 |
| `git rev-list --count b30fb3b..HEAD` (SUMMARY 작성 시점) | 2 — frontmatter `commits: 2` 와 같음 |
