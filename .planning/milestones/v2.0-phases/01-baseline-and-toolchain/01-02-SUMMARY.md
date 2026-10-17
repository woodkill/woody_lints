---
phase: 01-baseline-and-toolchain
plan: 02
subsystem: docs
tags: [versioning, semver, changelog, policy, markdown]

# Dependency graph
requires:
  - phase: 01-01
    provides: "기준 ref `v1.3.0` → `90a2736` — 이 plan 의 verify 가 `README.md` / `CHANGELOG.md` / `lib/` / 루트 `analysis_options.yaml` 이 그 커밋과 같은지 비교한다"
provides:
  - "저장소 루트 `VERSIONING.md` — 버전 정책(판정 순서 4단계, 기준표 11행, 실제 사례)과 CHANGELOG 항목 형식"
  - "다음 릴리스 번호 2.0.0 이 문서에 확정되어 있다 (SDK 하한 상향 = major)"
  - "CHANGELOG 항목의 고정 형식 문자열 — `## X.Y.Z - YYYY-MM-DD`, `지원 SDK: …`, 다섯 칸 이름, 4열 헤더 `| 규칙 | 강도 | 실측 | dart fix |`, `실측: flutter_starter_kit (Dart 파일 N개), Flutter X.Y.Z, YYYY-MM-DD`"
affects: [01-03, phase-3-presets, phase-4-rules, phase-5-docs, phase-6-release]

# Actuals (#2632)
actuals:
  tokens: 1344     # chars/4 — VERSIONING.md 5375자 (wc -m). 바이트로는 9621 이다. plan 의 estimate 는 30000 이었다
  tasks: 2         # Task 1 (auto), Task 2 (auto)
  commits: 2       # MEASURED: git rev-list --count 1623da1f61da4dc701ed0883560a93b0412630fc..HEAD (SUMMARY 작성 시점)
plan_head_before: 1623da1f61da4dc701ed0883560a93b0412630fc
plan_head_after: 712e42cbd7dc59c1a65deafb131b250c10a04061

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "정책 문서의 절 제목과 형식 문자열을 고정해 두고, 검증 명령이 그 문자열을 `grep -qx` / `grep -qF` 로 읽는다"
    - "다른 문서에서 표나 예시를 옮길 때는 옮긴 뒤 원문과 `diff` 로 글자 단위 대조한다"

key-files:
  created:
    - VERSIONING.md
    - .planning/phases/01-baseline-and-toolchain/01-02-SUMMARY.md
  modified: []

key-decisions:
  - "버전 정책과 CHANGELOG 항목 형식의 기준 문서는 저장소 루트 `VERSIONING.md` 다. 다음 릴리스는 2.0.0 이다 — 이번 릴리스의 가장 큰 등급이 SDK 하한 상향(major)이다"
  - "`VERSIONING.md` 의 절 제목 넷(`## 판정 순서` / `## 기준표` / `## 실제 사례` / `## CHANGELOG 항목 형식`)과 CHANGELOG 형식 문자열은 검증 명령과 뒤 phase 가 읽는 고정 문자열이다. 바꾸려면 검증 명령도 함께 바꾼다"

patterns-established:
  - "CHANGELOG 버전 항목: 제목 `## X.Y.Z - YYYY-MM-DD` (` - ` 는 한 번만, 미출시는 날짜 자리에 `미출시`) → `지원 SDK:` 줄(항상) → 해당하는 칸만 → `### 새로 생기는 경고`(항상)"
  - "버전 등급은 판정 순서 1 → 4 를 위에서부터 물어 처음 \"예\" 에서 멈춘다. 한 릴리스에 변경이 여럿이면 가장 큰 등급을 쓴다"

requirements-completed: [BASE-03, BASE-04]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "`VERSIONING.md` 에 머리말(세 자리 풀이)·판정 순서 4단계·기준표 11행·실제 사례가 있고, 기준표가 CONTEXT D-05 의 표와 글자 단위로 같다"
    requirement: "BASE-03"
    verification:
      - kind: other
        ref: "plan 01-02 Task 1 <automated> verify (절 제목 셋, 기준표 등급 행 수 11, 11행 grep -F, D-10 풀이 셋, 사례 문자열, 파일 끝 개행) → rc=0, 커밋 전·후 두 번"
        status: pass
      - kind: other
        ref: "sed -n '43,55p' 01-CONTEXT.md | sed 's/^  //' 과 VERSIONING.md 기준표 절의 표 13줄을 diff → 차이 없음"
        status: pass
    human_judgment: false
  - id: D2
    description: "`VERSIONING.md` 의 `## CHANGELOG 항목 형식` 절에 D-12 의 뼈대(제목 형식·`지원 SDK:`·다섯 칸), D-13 의 4열 표와 실측 한 줄, 소유자가 고른 2.1.0 예시, 적용 범위(D-15, D-16)가 있다"
    requirement: "BASE-04"
    verification:
      - kind: other
        ref: "plan 01-02 Task 2 <automated> verify (절 제목, 형식 문자열 9개, 4열 헤더 정규식, 2.1.0 예시, 기준표 행 수 11 유지) → rc=0, 커밋 전·후 두 번"
        status: pass
      - kind: other
        ref: "sed -n '211,226p' 01-CONTEXT.md 와 VERSIONING.md 의 markdown 펜스 안쪽 16줄을 diff → 차이 없음"
        status: pass
    human_judgment: false
  - id: D3
    description: "소유자가 `VERSIONING.md` 의 판정 순서를 1.3.0 과 2.0.0 사례에 직접 대입해 minor / major 를 얻고, 문서만 읽고 이유에 납득한다 (ROADMAP success criterion 4)"
    requirement: "BASE-03"
    verification: []
    human_judgment: true
    rationale: "\"읽고 판정할 수 있다\" 는 사람의 이해 여부다. 명령으로는 문서의 존재와 구조까지만 확인된다. plan 의 Task 1 <human-check> 가 end-of-phase UAT 로 넘어간다"
  - id: D4
    description: "이 plan 의 두 커밋이 담는 파일은 `VERSIONING.md` 하나다. `README.md`, `CHANGELOG.md`, `lib/`, 루트 `analysis_options.yaml` 은 `90a2736` 과 같다"
    verification:
      - kind: other
        ref: "git diff --quiet 90a2736 -- README.md CHANGELOG.md lib analysis_options.yaml → rc=0"
        status: pass
      - kind: other
        ref: "git diff --name-only 1623da1..712e42c → VERSIONING.md 한 줄"
        status: pass
    human_judgment: false

# Metrics
duration: 6min
completed: 2026-10-11
status: complete
---

# Phase 1 Plan 02: 버전 정책 문서(VERSIONING.md) Summary

**저장소 루트에 `VERSIONING.md` 를 만들어 버전 등급 판정 순서 4단계·기준표 11행·실제 사례(1.3.0 → minor, 2.0.0 → major, 다음 릴리스 2.0.0)와 CHANGELOG 항목 형식(필수 두 칸 + 해당 칸만, 4열 실측 표)을 한 파일에 적었다**

## Performance

- **Duration:** 6 min (397초)
- **Started:** 2026-10-11T04:38:03Z
- **Completed:** 2026-10-11T04:44:40Z (작업·검증 종료 시점. SUMMARY 작성과 상태 갱신 시간은 포함하지 않는다)
- **Tasks:** 2 (auto 2)
- **Files modified:** 1 (`VERSIONING.md` 신규, 123줄 / 9621바이트)

## Accomplishments

- `VERSIONING.md` 가 저장소 루트에 있다. 첫 줄은 `# 버전 정책 (Versioning)` 이고 `##` 절 넷이 고정 제목 그대로다: `## 판정 순서`, `## 기준표`, `## 실제 사례`, `## CHANGELOG 항목 형식`
- 기준표는 CONTEXT D-05 의 표 11행과 글자 단위로 같다 (원문과 `diff` 로 대조, 차이 없음)
- 판정 순서는 major → minor → patch → 올리지 않음 이고 각 줄에 `맨 앞자리(major)` / `가운데 자리(minor)` / `맨 뒷자리(patch)` 가 붙어 있다
- 실제 사례에 1.3.0 → minor, 2.0.0 → major 가 있고 "다음 릴리스는 **2.0.0**" 과 `2.0.0-dev` 규칙이 적혀 있다. 옛 판정과 지금 정책이 다른 1.2.3 / 1.2.4 도 넣었다
- CHANGELOG 항목 형식 절에 제목 형식, `지원 SDK:` 줄, 다섯 칸, 4열 표, 실측 한 줄, 소유자가 고른 2.1.0 예시(원문과 `diff` 차이 없음), 적용 범위가 있다
- `README.md`, `CHANGELOG.md`, `lib/`, 루트 `analysis_options.yaml` 은 바뀌지 않았다. 아무것도 push 하지 않았다

## Task Commits

task 마다 커밋 하나, 순서는 action → verify → 커밋이다.

1. **Task 1: VERSIONING.md 를 만든다 — 머리말, 판정 순서, 기준표, 실제 사례** - `b1d6b80` (docs)
   - 전체 SHA `b1d6b800edfcd31596bc10f9da531caa768d62c8`
   - 제목 `docs(01-02): 버전 정책 문서(VERSIONING.md) 추가 — 판정 순서·기준표·실제 사례`
2. **Task 2: VERSIONING.md 에 `## CHANGELOG 항목 형식` 절을 덧붙인다** - `712e42c` (docs)
   - 전체 SHA `712e42cbd7dc59c1a65deafb131b250c10a04061`
   - 제목 `docs(01-02): VERSIONING.md 에 CHANGELOG 항목 형식 절 추가`

**Plan metadata:** 이 SUMMARY 와 `STATE.md` / `ROADMAP.md` / `REQUIREMENTS.md` 를 담는 `docs(01-02)` 커밋 하나 (이 문서 작성 뒤에 만들어지므로 해시는 여기에 적지 않는다)

커밋 수 측정 (SUMMARY 작성 시점):

```text
$ cat .git/gsd-plan-head-before-01-02
1623da1f61da4dc701ed0883560a93b0412630fc
$ git rev-list --count 1623da1f61da4dc701ed0883560a93b0412630fc..HEAD
2
$ git log --format='%h %s' 1623da1f61da4dc701ed0883560a93b0412630fc..HEAD
712e42c docs(01-02): VERSIONING.md 에 CHANGELOG 항목 형식 절 추가
b1d6b80 docs(01-02): 버전 정책 문서(VERSIONING.md) 추가 — 판정 순서·기준표·실제 사례
$ git diff --name-only 1623da1f61da4dc701ed0883560a93b0412630fc..HEAD
VERSIONING.md
```

## Files Created/Modified

- `VERSIONING.md` - 버전 정책(판정 순서·기준표·실제 사례)과 CHANGELOG 항목 형식. UTF-8, LF, 파일 끝 개행 있음
- `.planning/phases/01-baseline-and-toolchain/01-02-SUMMARY.md` - 이 기록

## Task 1 증거

파일 상태와 verify (커밋 전, 2026-10-11T04:41Z 무렵):

```text
$ ls -la VERSIONING.md
-rw-r--r--@ 1 woody  staff  6090 10월 11 13:41 VERSIONING.md
$ wc -l VERSIONING.md
      71 VERSIONING.md
$ file VERSIONING.md
VERSIONING.md: Unicode text, UTF-8 text
$ tail -c 1 VERSIONING.md | xxd -p
0a
$ bash verify-t1.sh        # plan 의 Task 1 <automated> 한 줄 그대로 (plan 원문과 diff 없음을 확인한 사본)
Task 1 <automated> verify rc=0
$ sed -n '/^## 기준표$/,/^## /p' VERSIONING.md | grep -E '^\| .+ \| (major|minor|patch|올리지 않음) \| .+ \|$' | wc -l | tr -d ' '
11
```

acceptance criteria:

| 기준 | 결과 | 근거 |
|------|------|------|
| `head -1 VERSIONING.md` 가 `# 버전 정책 (Versioning)` | PASS | 출력 `# 버전 정책 (Versioning)` |
| `grep -x` 로 세 절 제목이 각각 한 줄 | PASS | `grep -cx` = 1 / 1 / 1 |
| 기준표 등급 행 11, CONTEXT.md 43-55행과 글자 단위로 같음 | PASS | 행 수 11. `sed -n '43,55p' 01-CONTEXT.md \| sed 's/^  //'` 와 표 13줄(헤더 + 구분선 + 11행)을 `diff` → 차이 없음 |
| 번호 목록 4개가 major → minor → patch → 올리지 않음 순서, 각 줄에 풀이 | PASS | 아래 원문 |
| 사례에 1.3.0 → minor, 2.0.0 → major, 1.2.3, "다음 릴리스는 2.0.0", `2.0.0-dev` | PASS | 아래 원문 |
| README 링크 없음, `git diff --quiet 90a2736 -- README.md CHANGELOG.md lib analysis_options.yaml` rc=0 | PASS | Markdown 링크 0개. `README` 라는 글자는 기준표의 `주석·README·CHANGELOG·사유 문구만 고침` 행에만 있다. diff rc=0 |
| 커밋 뒤: `git show --name-only --format= HEAD` 가 `VERSIONING.md` 한 줄 | PASS | `b1d6b80` → `VERSIONING.md` |
| 커밋 뒤: 제목이 `docs(01-02): ` 로 시작하고 한국어 | PASS | 위 제목 |

판정 순서 번호 목록 (문서 원문):

```text
1. 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하나, 자동 검사가 막힐 수 있나 → major. 맨 앞자리(major) 를 올린다.
2. 규칙 목록이나 exclude / errors 설정, plugin 버전이 바뀌었나 → minor. 가운데 자리(minor) 를 올린다.
3. `lib/` 나 `pubspec.yaml` 이 바뀌긴 했나 → patch. 맨 뒷자리(patch) 를 올린다.
4. 아니면 → 버전을 올리지 않는다.
```

실제 사례의 주요 줄 (문서 원문):

```text
- `1.3.0` (2026-09-20, `90a2736`) — 그때까지 로드되지 않던 `riverpod_lint` 를 처음 켰다 → minor (2번에서 멈춤).
- `2.0.0` (미출시, 다음 릴리스) — 지원 SDK 하한을 `^3.10.4` 에서 `^3.13.0` 으로 올린다 → major (1번에서 멈춤).
  - 그래서 다음 릴리스는 **2.0.0** 이다. 이번 릴리스에 들어가는 변경 중 가장 큰 등급이 SDK 하한 상향(major)이기 때문이다.
  - 2.0.0 을 준비하는 동안(milestone 브랜치)에는 `pubspec.yaml` 의 `version` 을 `2.0.0-dev` 로 두고, 릴리스 때 `-dev` 를 뗀다. …
- `1.2.3` (2026-01-28, `9451f6b`) — `slash_for_doc_comments` 규칙을 추가했는데 당시에는 patch 로 냈다 → 지금 정책이면 minor (2번에서 멈춤).
- `1.2.4` (2026-02-27, `212365d`) — `public_member_api_docs` 규칙을 추가하고 `analyzer:` 의 exclude / errors 설정을 넣었는데 당시에는 patch 로 냈다 → 지금 정책이면 minor (2번에서 멈춤).
```

사례에 적은 날짜·커밋·내용은 RESEARCH 의 표를 옮기기 전에 `git log` / `git show` 로 다시 확인했다: 네 커밋의 날짜와 `version` 이 표와 같고, `pubspec.yaml` 의 `sdk` 는 `d98b45a` 부터 `90a2736` 까지 줄곧 `^3.10.4` 였다 (1.3.0 에서 SDK 하한이 바뀌지 않았다는 근거).

## Task 2 증거

파일 상태와 verify (커밋 전, 2026-10-11T04:44Z 무렵):

```text
$ ls -la VERSIONING.md
-rw-r--r--@ 1 woody  staff  9621 10월 11 13:44 VERSIONING.md
$ wc -l VERSIONING.md
     123 VERSIONING.md
$ tail -c 1 VERSIONING.md | xxd -p
0a
$ bash verify-t2.sh        # plan 의 Task 2 <automated> 한 줄 그대로 (plan 원문과 diff 없음을 확인한 사본)
Task 2 <automated> verify rc=0
$ bash verify-t1.sh        # Task 2 가 Task 1 결과를 망치지 않았는지
Task 1 <automated> verify rc=0
$ sed -n '/^## 기준표$/,/^## /p' VERSIONING.md | grep -E '^\| .+ \| (major|minor|patch|올리지 않음) \| .+ \|$' | wc -l | tr -d ' '
11
```

acceptance criteria:

| 기준 | 결과 | 근거 |
|------|------|------|
| `grep -x '## CHANGELOG 항목 형식'` 이 한 줄 | PASS | `grep -cx` = 1 |
| 절에 `## X.Y.Z - YYYY-MM-DD`, `지원 SDK:`, `(변경 없음)`, `(이전: …)`, 다섯 칸 이름, `없음` | PASS | 열 개 문자열 각각 `grep -qF` PASS |
| "` - ` 는 한 번만" 과 REL-03 (Phase 6 일치 검사) 언급 | PASS | `한 번만`, `REL-03`, `Phase 6` 각각 PASS |
| 4열 헤더, `실측: flutter_starter_kit (Dart 파일 N개), Flutter X.Y.Z, YYYY-MM-DD`, `dart fix` 열이 "고쳐지는 건수" | PASS | 세 문자열 각각 PASS |
| 2.1.0 가상 예시가 CONTEXT 210-227행과 같은 내용으로 펜스 안에 있음 | PASS | 펜스 안쪽 16줄과 CONTEXT.md 211-226행을 `diff` → 차이 없음 |
| D-16 문장 (1.3.0 / 1.0.0 항목은 그대로, Phase 5 에서 보완) | PASS | 절의 마지막 불릿 |
| `git diff --quiet 90a2736 -- CHANGELOG.md README.md lib analysis_options.yaml` rc=0 | PASS | rc=0 |
| 커밋 뒤: `git show --name-only --format= HEAD` 가 `VERSIONING.md` 한 줄, 제목이 `docs(01-02): ` 로 시작 | PASS | `712e42c` → `VERSIONING.md` |
| 영어 칸 이름 `### Added` / `### Removed` 를 형식으로 쓰지 않음 | PASS | `grep -nE '^### (Added\|Removed)'` 출력 없음. "쓰지 않는다" 는 설명 문장에만 나온다 |

## Plan 검증 결과

| 항목 | 결과 |
|------|------|
| Task 1 verify | PASS — rc=0 (커밋 전), rc=0 (Task 2 뒤 재실행), rc=0 (두 커밋 뒤 재실행) |
| Task 2 verify | PASS — rc=0 (커밋 전), rc=0 (커밋 뒤 재실행) |
| 기준표 등급 행 수 | 11 |
| ROADMAP success criterion 5 (CHANGELOG 형식이 문서로 정해짐) | 구조는 PASS — 4열 표, 실측 한 줄, 칸 목록이 문서에 있다. 형식이 Phase 4 실측 표를 담기에 충분한지는 Phase 4 에서 드러난다 (plan 의 "플래그된 가정") |
| ROADMAP success criterion 4 (소유자가 읽고 판정, 다음 번호 2.0.0) | 번호 2.0.0 은 문서에 있다. "읽고 판정" 은 end-of-phase UAT 로 넘겼다 (아래) |
| 커밋 계약 (task 커밋 2개, 저장소 파일은 `VERSIONING.md` 하나, push 없음) | PASS — `rev-list --count` = 2, `git diff --name-only` = `VERSIONING.md`, 원격 브랜치는 `origin/main` (`90a2736`) 그대로 |

### `fvm dart analyze` (커밋 전 린터)

두 task 모두 커밋 전에 저장소 루트에서 돌렸다. 메인 체크아웃에서 실행했으므로 plan 이 가정한 "worktree 에서 FVM 이 SDK 를 못 찾는 경우" 는 해당되지 않았다.

```text
$ fvm dart --version
Dart SDK version: 3.11.0 (stable) (Mon Feb 9 00:38:07 2026 -0800) on "macos_arm64"
$ fvm dart analyze          # Task 1 커밋 전
Analyzing woody_lints...
No issues found!
analyze rc=0
$ fvm dart analyze          # Task 2 커밋 전
Analyzing woody_lints...
No issues found!
analyze rc=0
```

SDK 는 `.fvmrc` 의 Flutter 3.41.2 (Dart 3.11.0) 다. 3.47.5 로 올리는 것은 plan 01-03 의 일이다.

### 소유자 읽기 검증 → end-of-phase UAT

`workflow.human_verify_mode` 가 `end-of-phase` 라서 이 plan 은 중간에 멈추지 않았다. Task 1 의 `<human-check>` 는 실행하지 않았고, phase 끝의 UAT 에서 소유자가 한다 (frontmatter `coverage` 의 D3, `human_judgment: true`).

- **할 일:** `VERSIONING.md` 의 `## 판정 순서` 를 두 사례에 직접 대입한다 — (1) "1.3.0: 그때까지 로드되지 않던 `riverpod_lint` 를 처음 켰다", (2) "2.0.0: 지원 SDK 하한을 `^3.10.4` → `^3.13.0` 으로 올렸다"
- **기대:** (1) 은 1번에서 "아니오", 2번에서 "예" → minor. (2) 는 1번에서 "예" → major. 두 결과가 `## 실제 사례` 와 같고, 문서만 읽고 이유에 납득된다. 다음 릴리스 번호 2.0.0 이 문서에 적혀 있다

### must_haves 의 prohibitions

| 금지 사항 | 지켰는가 | 근거 |
|-----------|----------|------|
| 이 phase 에서 `README.md` 와 `lib/`, 루트 `analysis_options.yaml` 은 바꾸지 않는다. VERSIONING.md 로 가는 링크·요약은 Phase 5 에서 넣는다 (D-11) | 지켰다 | `git diff --quiet 90a2736 -- README.md CHANGELOG.md lib analysis_options.yaml` rc=0. 두 커밋이 담은 파일은 `VERSIONING.md` 하나다. `VERSIONING.md` 에 Markdown 링크가 없다 |

### threat_model 의 mitigate 항목

| Threat | 적용한 완화 |
|--------|-------------|
| T-01-04 (기준표가 D-05 와 어긋남, 행 누락·변형) | Task 1 verify 가 등급 행 수 11 과 11행 전부를 `grep -F` 로 대조했다 (rc=0). 그에 더해 CONTEXT.md 43-55행 원문과 표 전체를 `diff` 로 비교했다 (차이 없음). 소유자 읽기 검증은 UAT 로 넘겼다 |

T-01-05 (`flutter_starter_kit` 이름 노출) 와 T-01-SC (패키지 설치) 는 plan 이 accept 로 둔 항목이다. 이 plan 은 패키지를 설치하지 않았고 아무것도 push 하지 않았다.

## Decisions Made

정책의 내용(D-01 ~ D-16)은 CONTEXT 에서 이미 정해져 있었고, 이 plan 은 그것을 문서로 옮겼다. 실행 중에 새로 정한 정책은 없다. 문장과 구성은 CONTEXT 가 Claude's Discretion 으로 둔 범위에서 아래처럼 정했다.

- **판정 순서 각 줄의 꼴.** plan 의 action 은 `→ major (맨 앞자리)` 꼴을, acceptance criteria 는 각 줄에 `맨 앞자리(major)` 가 그대로 있을 것을 요구했다. 둘을 함께 채우려고 `→ major. 맨 앞자리(major) 를 올린다.` 로 썼다. D-09 의 질문 문구는 그대로다
- **2.0.0 사례의 시제.** plan 의 예문은 "올렸다" 였지만 문서에는 "올린다" 로 썼다. 이 커밋 시점에 `pubspec.yaml` 은 아직 `^3.10.4` 이고 (하한 변경은 plan 01-03), 항목에 "미출시, 다음 릴리스" 라고 적혀 있어 현재형이 어느 시점에 읽어도 맞다
- **"다음 릴리스는 2.0.0" 과 `2.0.0-dev` 문장의 자리.** 2.0.0 사례 불릿의 하위 불릿으로 두었다. "그래서" 가 가리키는 것이 바로 위의 2.0.0 판정이 되도록 한 것이다
- **덧붙인 설명 두 가지.** (1) 판정 순서 아래에 "한 릴리스에 변경이 여럿이면 가장 큰 등급을 쓴다, 올린 자리의 뒷자리는 0 으로 돌린다" 를 적었다. 앞부분은 D-06 의 이유("가장 큰 등급이 SDK 하한 상향")를 규칙으로 풀어 쓴 것이고, 뒷부분은 `1.3.0` → `2.0.0` 이 되는 셈법이다. (2) CHANGELOG 형식 절에 4열의 뜻(`강도` = 심각도, `실측` = 경고 건수)을 한 줄씩 적었다. D-13 은 열 이름과 `dart fix` 의 뜻만 정했고, 나머지 두 열의 뜻은 소유자가 고른 예시와 CONTEXT 의 "Phase 4 평가표의 열(심각도, 실측 건수, `dart fix` 가능 건수)과 대응한다" 에서 가져왔다
- **사례를 넷으로.** 필수인 1.3.0, 2.0.0 에 plan 이 권한 1.2.3 과 선택 사항이던 1.2.4 를 더했다. 뒤의 둘은 "옛 판정과 지금 정책이 다른 것" 으로 따로 묶었다

## Deviations from Plan

deviation rule 1 ~ 4 에 해당하는 것은 없다 (버그 수정, 빠진 필수 기능 추가, 막힘 해소, 구조 변경 모두 없음). plan 의 예문과 문서 문장이 다른 곳은 위 "Decisions Made" 에 전부 적었다.

**Total deviations:** 0
**Impact on plan:** 없음. 파일 범위, 커밋 수, 커밋 제목, 검증 명령 모두 plan 에 적힌 그대로다.

## Issues Encountered

실행을 막은 문제는 없었다. 아래는 소유자와 뒤 phase 가 알아야 할 점이다.

- **1.3.0 사례의 "자동 검사가 막힐 수 있나" 는 문서에 근거를 적지 않았다.** 판정 순서 1번은 두 가지를 묻는다 (설정·SDK 를 고쳐야 하나 / 자동 검사가 막힐 수 있나). 1.3.0 에 대해 확인된 것은 앞의 것뿐이다 — SDK 하한이 `^3.10.4` 그대로였고 받는 쪽이 고칠 설정이 없었다. `riverpod_lint` 규칙들의 심각도는 아직 확인되지 않았다 (ROADMAP Phase 2 의 spike 항목: "조사 문서끼리 info 와 warning 으로 어긋나 있고 실측된 것은 규칙 1개뿐"). 그래서 문서의 1.3.0 사례는 확인된 사실만 적고 심각도는 말하지 않는다
- **정책의 빈칸 하나 (해결하지 않고 남긴다).** 기준표는 "규칙을 넣거나 뺌 → minor" 와 "규칙 심각도를 warning 이상으로 올림 → major" 를 따로 둔다. **처음부터 warning 인 규칙을 새로 켜는 경우**는 표에 없고, 판정 순서 1번의 "자동 검사가 막힐 수 있나" 에 "예" 로 읽힐 수 있다. D-09 는 1.3.0 을 minor 로 확정했으므로 그대로 적었다. Phase 2 의 spike 에서 `riverpod_lint` 에 warning 규칙이 확인되면 이 경우를 기준표에 한 줄 더할지 소유자가 정해야 한다. UAT 에서 1.3.0 사례를 대입할 때 걸릴 수 있는 지점이다
- **2.1.0 예시는 원문 그대로다.** 소유자가 고른 예시는 `### 추가한 규칙` 에 `rule_a` 하나만 있는데 "새로 생기는 경고" 표에는 `rule_a` 와 `rule_b` 가 있다. "그대로 따른다" 는 지시대로 고치지 않았다
- **문서의 세 문장은 plan 01-03 이 끝나야 저장소 상태와 맞는다.** `2.0.0-dev`, `^3.13.0`, `## 2.0.0 - 미출시` 항목은 이 plan 의 커밋 시점에는 아직 `pubspec.yaml` / `CHANGELOG.md` 에 없다. 문서는 이것들을 규칙과 미출시 항목으로 적었다
- **`grep -c '^## ' VERSIONING.md` 는 4 가 아니라 5 다.** 펜스 안의 예시 제목 `## 2.1.0 - 2026-12-01` 이 줄 맨 앞에서 시작하기 때문이다. 절 제목을 세는 검사는 plan 처럼 `grep -qx '## 판정 순서'` 꼴로 한다

## Known Stubs

없음. `VERSIONING.md` 의 `미출시`, `X.Y.Z`, `N개`, `rule_a` 는 형식을 보이는 자리 표시이고 문서의 내용이다. 채워야 할 빈 값이 아니다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- plan 01-03 이 시작할 수 있다. `CHANGELOG.md` 의 `## 2.0.0 - 미출시` 항목은 `VERSIONING.md` 의 `## CHANGELOG 항목 형식` 을 따라 쓰면 된다 (제목의 ` - ` 한 번, `지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)`, `### 올리기 전에`, `### 새로 생기는 경고`)
- 01-03 Task 3 의 SC4 검사는 `grep -qx` 네 줄로 통과한다 (네 절 제목이 고정 문자열 그대로다)
- STATE 의 "[Phase 1] D8: 버전 정책 세부와 다음 버전 번호가 정해지지 않았다" 는 해소되었다 — 정책은 `VERSIONING.md`, 번호는 2.0.0
- 남은 사람 판정: 소유자 읽기 검증 (end-of-phase UAT), 그리고 위 "정책의 빈칸" 을 Phase 2 spike 뒤에 다시 볼지
- 유지할 약속: 릴리스 전까지 origin 에는 `main` 과 tag 외에 아무것도 올리지 않는다. 이 plan 은 push 하지 않았다
- 막힌 것 없음

## Self-Check: PASSED

SUMMARY 작성 뒤 다시 확인했다 (2026-10-11T04:47:31Z):

| 주장 | 확인 | 결과 |
|------|------|------|
| `VERSIONING.md` 가 있다 | `[ -f VERSIONING.md ]`, `wc -l` = 123, 9621바이트 | FOUND |
| 이 SUMMARY 파일이 있다 | `[ -f .planning/phases/01-baseline-and-toolchain/01-02-SUMMARY.md ]` | FOUND |
| task 커밋 `b1d6b80` 이 HEAD 의 조상이다 | `git merge-base --is-ancestor b1d6b80 HEAD` | FOUND |
| task 커밋 `712e42c` 가 HEAD 의 조상이다 | `git merge-base --is-ancestor 712e42c HEAD` | FOUND |
| task 커밋 2개 | `git rev-list --count 1623da1f61da4dc701ed0883560a93b0412630fc..HEAD` = `2` | 일치 |
| `plan_head_after` | `git rev-parse HEAD` = `712e42cbd7dc59c1a65deafb131b250c10a04061` | 일치 |
| Task 1 / Task 2 verify | 다시 실행, 둘 다 rc=0 | PASS |
| must_haves artifact (`VERSIONING.md` 에 `## 기준표`, 80줄 이상) | `grep -cx '## 기준표'` = 1, 123줄 | PASS |
| 이 plan 의 커밋이 이 브랜치에 있다 | `gsd-tools check evaluation-scope --plan 01-02 --commits-only` → `status: resolved`, 커밋 2개 | PASS |
| frontmatter 와 `coverage` 블록이 읽힌다 | `gsd-tools verify-summary` → `passed: true`, `gsd-tools uat classify-coverage` → 4건 분류 (D1 / D2 / D4 자동, D3 사람) | PASS |

---
*Phase: 01-baseline-and-toolchain*
*Completed: 2026-10-11*
