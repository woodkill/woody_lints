---
phase: 06-release
plan: 12
subsystem: verification
tags: [verify-dart, changelog, markdown, first-line-rule, two-reader, gap-closure, REL-03]

requires:
  - phase: 06-release
    provides: "06-08 의 Markdown 첫 h2 reader (changelogTop · firstElement), 06-VERIFICATION.md 2회차 gap (a · a3 · b · b2), 06-REVIEW.md WR-02 · WR-05 · IN-09, 소유자 결정 G7-Q1 · G7-Q2"
provides:
  - "tool/verify.dart 의 topHeadingLine · changelogTopOf(String raw) — CHANGELOG 첫 줄의 엄격한 제목 + Markdown 첫 h2 일치 (둘째 reader)"
  - "checkVersionAgreement 의 changelogGuide 블록 — 첫 줄 · 둘째 reader 실패는 70 이 아니라 [3/10] 블록"
  - "VERSIONING.md 「CHANGELOG 항목 형식」 의 첫 줄 규칙 한 줄, pubspec.yaml 19 · 21행 · skill 세 줄의 새 문장 (IN-09)"
  - "example/README.md 의 (06-12) 소절 — M107 ~ M115, M100 ~ M106 재측정, 가장자리 다섯, 회귀 넷, 읽는 법 여섯"
affects: [06-13, 06-14 (처리 기록 WR-02 · WR-05 · IN-09 fixed, IN-08 deferred · push gate), 06-15 (main 병합 · REL-03 표시), 다음 릴리스의 tag gate]

actuals:
  tokens: 14423
  tasks: 2
  commits: 2
plan_head_before: 6a19a2cd71d6ed4f61bad993a3f2ef1cd334951c
plan_head_after: 317d3ffde20b20a8bbd36e9f21ecd472cc715ebb

tech-stack:
  added: []
  patterns:
    - "형식 규칙(최상단 항목 = 파일 첫 줄)을 주 reader 로, 해석기를 둘째 reader 로 — 두 reader 가 갈리면 [3/10] 블록이 두 값을 함께 보인다"
    - "순수 함수(changelogTopOf) + 파일 읽기 한 줄(changelogTop) — 문자열 하네스가 BOM · CRLF 같은 파일로 못 만드는 입력을 직접 본다"

key-files:
  created: []
  modified:
    - tool/verify.dart
    - pubspec.yaml
    - VERSIONING.md
    - .claude/skills/spike-findings-woody-lints/SKILL.md
    - .claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md
    - .claude/skills/spike-findings-woody-lints/references/rule-status-check.md
    - example/README.md

key-decisions:
  - "CHANGELOG 최상단은 U+FEFF 를 뗀 파일 첫 줄이 ^## (\\d+\\.\\d+\\.\\d+) - (\\S.*?)[ \\t]*$ 꼴이고 Markdown 첫 h2 와 같을 때만 통과한다 (소유자 결정 G7-Q1 (나))"
  - "첫 줄 · 둘째 reader 실패는 FormatException 70 이 아니라 [3/10] 블록 [message, '', changelogGuide] 이고 CHANGELOG 쪽 비교만 건너뛴다 (planner 선택 — 두 reader 의 값을 보인다)"
  - "변형 꼴의 GITHUB_REF_NAME 경로는 대표 여섯의 세 경로 전체 실행으로 갈음했다 (main 이 같은 값을 --tag 와 같은 인자로 넘긴다 — planner 선택)"

patterns-established:
  - "검증 명령이 읽는 Markdown 문서의 기준 줄은 렌더러 모두가 같게 그리는 자리(파일 첫 줄의 ATX)로 못박고, 해석기는 일치 확인에만 쓴다"

requirements-completed: [REL-03]

coverage:
  - id: D1
    description: "changelogTopOf — 첫 줄 규칙 + 둘째 reader, 실패는 [3/10] 블록; 작업 트리의 평소 · --tag v2.0.0 · 환경변수 tag 10/10, --tag v2.0.1 블록 둘, 문자열 하네스 열여섯 줄(ok 6 · err 10)"
    requirement: "REL-03"
    verification:
      - kind: integration
        ref: "06-12-PLAN.md Task 1 <automated> (적힌 그대로) rc 0 — 커밋 전, 80초"
        status: pass
    human_judgment: false
  - id: D2
    description: "거짓이 된 문장 고침 — verify.dart 머리 주석 6 · 34 ~ 42행 · 문서 주석, pubspec.yaml 19 · 21행 (2/2), skill 세 줄 (각 1/1), VERSIONING.md 한 줄 (1/0)"
    requirement: "REL-03"
    verification:
      - kind: other
        ref: "06-12-PLAN.md Task 1 <automated> 의 양성 · 부정 grep 과 numstat 단언 rc 0"
        status: pass
    human_judgment: false
  - id: D3
    description: "복제본 지워 보기 M107 ~ M115 · M100 ~ M106 재측정 · 가장자리 · 회귀를 example/README.md 에 기록, (06-08) 읽는 법 (2) · (3) · 117행 · 70 행 고침"
    requirement: "REL-03"
    verification:
      - kind: integration
        ref: "06-12-PLAN.md Task 2 <automated> (적힌 그대로) rc 0 — 새 복제본, 커밋 전, 531초"
        status: pass
    human_judgment: false

duration: 28min
completed: 2026-10-17
status: complete
---

# Phase 06 Plan 12: CHANGELOG 첫 줄 고정 Summary

**`[3/10]` (i) 의 CHANGELOG 최상단 reader 를 "U+FEFF 뗀 파일 첫 줄의 엄격한 `## X.Y.Z - <날짜 자리>` + `package:markdown` 첫 h2 일치" 로 바꿔, 해석기와 GitHub 화면이 갈리던 한 글자 setext · 블록 안 `<!--` 꼴을 모두 `[3/10]` 블록으로 실패시키고, 복제본에서 M107 ~ M115 로 기록했다**

## Performance

- **Duration:** 28 min
- **Started:** 2026-10-17 00:49 KST
- **Completed:** 2026-10-17 01:17 KST
- **Tasks:** 2 / 2
- **Files modified:** 7

## Task 결과

| Task | `<automated>` rc (적힌 그대로) | 걸린 시간 | 커밋 |
|------|-------------------------------|-----------|------|
| 1 | 0 (커밋 전에 실행) | 80초 | `85e1b0d` |
| 2 | 0 (커밋 전에, 백그라운드 `bash -x`, rc 는 파일로) | 531초 | `317d3ff` |

커밋 (SHA · 제목):

- `85e1b0d` — `fix(tool): [3/10] 의 CHANGELOG 최상단 reader 를 파일 첫 줄로 고정 — Markdown 첫 h2 와 같아야 통과 (WR-02 · WR-05 · IN-09, REL-03)`
- `317d3ff` — `test(example): 지워 보기 M107 ~ M115 — CHANGELOG 첫 줄 규칙 (06-12, REL-03)`

## (1) Task 1 — 작업 트리의 네 실행 · 문자열 하네스 · 고친 전후

작업 트리(HEAD = 릴리스 상태 `2.0.0` · 1행 `## 2.0.0 - 2026-10-15`):

| 실행 | 종료 코드 | 마지막 줄 | stderr 모드 줄 |
|------|-----------|-----------|----------------|
| `fvm dart run tool/verify.dart` | 0 | `점검 통과 (10개 중 10개)` | `버전 일치 검사: 평소 …` |
| `… --tag v2.0.0` | 0 | `점검 통과 (10개 중 10개)` | `버전 일치 검사: tag v2.0.0 (--tag)` |
| `GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v2.0.0 …` | 0 | `점검 통과 (10개 중 10개)` | `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` |
| `… --tag v2.0.1` | 1 | `점검 실패 (10개 중 1개)` — `[3/10]` 만 실패 | (단언은 출력 쪽) |

`--tag v2.0.1` 의 블록 둘: `` tag `v2.0.1` 의 버전 (2.0.1) 과 `pubspec.yaml` 의 version (2.0.0) 이 다르다. `` · `` tag `v2.0.1` 의 버전 (2.0.1) 과 `CHANGELOG.md` 최상단 버전 (2.0.0) 이 다르다. `` — 안내 줄 `VERSIONING.md 「릴리스 절차」` 둘, 첫 줄 블록 0 (첫 줄이 꼴에 맞아 CHANGELOG 쪽은 버전 어긋남 블록).

문자열 하네스 열여섯 줄 (실제 출력 그대로):

```
base ok 2.0.0|2026-10-15
unreleased ok 2.0.0|미출시
bom ok 2.0.0|2026-10-15
crlf ok 2.0.0|2026-10-15
trail ok 2.0.0|2026-10-15
twice ok 2.0.0|2026-10-15 - 추가
preamble err `CHANGELOG.md` 의 첫 줄이 최상단 제목 `## X.Y.Z - <날짜 자리>` 꼴이 아니다: `# Changelog`
setext1 err `CHANGELOG.md` 의 첫 줄이 최상단 제목 `## X.Y.Z - <날짜 자리>` 꼴이 아니다: `2.1.0 - 미출시`
bqcomment err `CHANGELOG.md` 의 첫 줄이 최상단 제목 `## X.Y.Z - <날짜 자리>` 꼴이 아니다: `> <!--`
bold err `CHANGELOG.md` 의 첫 줄이 최상단 제목 `## X.Y.Z - <날짜 자리>` 꼴이 아니다: `## **2.0.0** - 2026-10-15`
vprefix err `CHANGELOG.md` 의 첫 줄이 최상단 제목 `## X.Y.Z - <날짜 자리>` 꼴이 아니다: `## v2.0.0 - 2026-10-15`
empty err `CHANGELOG.md` 의 첫 줄이 최상단 제목 `## X.Y.Z - <날짜 자리>` 꼴이 아니다: (빈 줄)
blankfirst err `CHANGELOG.md` 의 첫 줄이 최상단 제목 `## X.Y.Z - <날짜 자리>` 꼴이 아니다: (빈 줄)
emptyslot err `CHANGELOG.md` 의 첫 줄이 최상단 제목 `## X.Y.Z - <날짜 자리>` 꼴이 아니다: `## 2.0.0 -`
closing err `CHANGELOG.md` 첫 줄의 제목과 Markdown 해석의 첫 h2 가 다르다 — 첫 줄: `2.0.0 - 2026-10-15 ##` / 첫 h2: `2.0.0 - 2026-10-15`
backslash err `CHANGELOG.md` 첫 줄의 제목과 Markdown 해석의 첫 h2 가 다르다 — 첫 줄: `2.0.0 - 2026\-10\-15` / 첫 h2: `2.0.0 - 2026-10-15`
```

고친 전후:

- `pubspec.yaml` 19행 — 전 `… YAML 해석 결과와 견줄 때만 쓴다 — analyzer · pub 과 같은 해석기.` → 후 `… YAML 해석 결과와 견줄 때와 [3/10] (i) 가 version 을 읽을 때 쓴다 — analyzer · pub 과 같은 해석기 (06-REVIEW.md IN-09).`; 21행 — 전 `markdown 은 … 최상단 제목을 GitHub 화면과 같게 읽을 때만 쓴다 — HTML 주석 · 펜스 …` → 후 `markdown 은 tool/verify.dart 가 CHANGELOG.md 첫 줄의 최상단 제목을 Markdown 해석의 첫 h2 와 견주는 둘째 reader 로만 쓴다 — 첫 줄 규칙이 해석기와 GitHub 화면의 갈림을 막는다 (06-VERIFICATION.md 2회차 gap, 소유자 결정 G7-Q1).` (`2/2`, 20 · 22행 그대로)
- `VERSIONING.md` — 82행(` - ` 한 번 하위 불릿) 바로 뒤에 `  - 최상단 항목의 제목은 **파일의 첫 줄**이다 — …` 한 줄 (`1/0`, `## ` 절 수 불변)
- skill 세 줄 (같은 글자, 각 `1/1`) — 전 `` `package:yaml` 은 YAML 대조에만, `package:markdown` 은 CHANGELOG 최상단 제목을 GitHub 화면과 같게 읽는 데만 (D-11, 2026-10-15 G4-Q1 · 2026-10-16 G6-Q1) `` → 후 `` `package:yaml` 은 YAML 대조와 `pubspec.yaml` 의 version 읽기에, `package:markdown` 은 CHANGELOG 첫 줄의 최상단 제목을 Markdown 해석의 첫 h2 와 견주는 둘째 reader 로만 (D-11, 2026-10-15 G4-Q1 · 2026-10-16 G6-Q1 · G7-Q1 · IN-09) ``
- `tool/verify.dart` — 머리 주석 6행 끝 · 34 ~ 42행 (IN-09 와 `GitHub 화면의 갈림을 막는다` 를 한 줄에), `topHeadingLine` · `changelogTopOf` 와 문서 주석 여섯 문단, `changelogTop` 은 한 줄, `checkVersionAgreement` 의 `changelogGuide` · nullable `top` · `on FormatException catch` 블록, 문서 주석 두 곳, `checkShippedComposition` (i) bullet. 옛 문구 `2단 제목(h2)이 없다` · ` - ` 가 없다 · `indexOf(' - ')` 는 지웠다. `fvm dart analyze` 깨끗, `fvm dart format --set-exit-if-changed tool` 통과.

## (2) Task 2 — 복제본의 상태 A · C (경로는 `<복제본>`)

절차: `git clone --local` 한 `<복제본>` 의 toplevel 을 단언한 뒤 `fvm dart pub get --no-example` (1초). 하네스 파일은 복제본 밖 임시 폴더 — `fvm dart run --packages=<복제본>/.dart_tool/package_config.json <하네스> <복제본> [tag]`. 고치기 전 판은 `git show <Task 1 커밋>~1:tool/verify.dart` (06-08 판). 상태 A = HEAD 그대로, 상태 C = `pubspec.yaml` 3행 `version: 2.0.1` · README `ref: v2.0.1` 둘 · lock 여섯 `fvm dart pub get` (2초, `"2.0.1"`).

대표 여섯의 세 경로 전체 실행 (고친 판) — 모두 종료 코드 1 · `[3/10] 배포 파일의 구성 … 실패` 만 · `점검 실패 (10개 중 1개)` · 안내 줄 `VERSIONING.md 「CHANGELOG 항목 형식」` 하나 · 모드 줄(`(--tag)` · `(GITHUB_REF_NAME)` · `평소`):

| # | 상태 · 입력 | 블록 머리 줄 (세 경로 같음) | 걸린 시간 (tag / env / 평소) | 고치기 전 판 (하네스 두 모드) |
|---|-------------|-----------------------------|------------------------------|-------------------------------|
| M107 | A · `2.1.0 - 미출시` / `-` | `… 꼴이 아니다: \`2.1.0 - 미출시\`` | 70초 (첫 실행, plugin 준비) / 23초 / 24초 | `passed=true` · `passed=true` |
| M108 | A · `2.0.1 - 2026-10-20` / `-` | `… 꼴이 아니다: \`2.0.1 - 2026-10-20\`` | 23 / 23 / 23초 | `passed=true` · `passed=true` |
| M113 | A · `# Changelog` | `… 꼴이 아니다: \`# Changelog\`` | 22 / 23 / 22초 | `passed=true` · `passed=true` |
| M114 | A · 1행 `## **2.0.0** - 2026-10-15` | `… 꼴이 아니다: \`## **2.0.0** - 2026-10-15\`` | 23 / 22 / 22초 | `passed=true` · `passed=true` |
| M110 | C · `> <!--` / `## 2.0.1 - 2026-10-16` / `-->` | `… 꼴이 아니다: \`> <!--\`` | 22 / 22 / 22초 | `passed=true` · `passed=true` |
| M112 | C · `<!-- a --> x <!--` / 빈 줄 / `## 2.0.1 - …` / 빈 줄 / `-->` | `… 꼴이 아니다: \`<!-- a --> x <!--\`` | 21 / 23 / 21초 | `passed=true` · `passed=true` |

함수 단위 (고친 판 두 모드 → 고치기 전 판 두 모드):

- M107 변형 `- ` · `-` + 탭, M109 인용 · 목록 setext, M110 변형 (인용 + 빈 줄 · 닫지 않음), M111 셋 (목록 · 목록 + 빈 줄 · 중첩 — 중첩은 `\`- a\``), M112 변형 (빈 줄 없음) — 모두 `passed=false` 첫 줄 블록 → 고치기 전 `passed=true` (거짓 통과).
- M115 닫는 `##` · 가장자리 백슬래시 — 문구 B (`첫 줄: \`2.0.0 - 2026-10-15 ##\` / 첫 h2: \`2.0.0 - 2026-10-15\`` · `첫 줄: \`2.0.0 - 2026\-10\-15\` / 첫 h2: \`2.0.0 - 2026-10-15\``) → 고치기 전 `passed=true`.
- 가장자리: raw `<h2>` 첫 줄 블록 (전 `passed=true`), `## v2.0.0 - …` 첫 줄 블록 (전은 버전 어긋남 블록), 뒤 공백 셋 두 판 `passed=true`, 앞 빈 줄 `(빈 줄)` 블록 (전 `passed=true`).
- 회귀 (고친 판): M92 블록 둘 · 안내 둘 · 첫 줄 블록 0, M93 꼴 `-dev` 꼬리 블록, M95 날짜 자리 블록 · 첫 줄 블록 0, M96 꼴 블록 — 앞 기록과 같다.

재측정에서 바뀐 것: **M103 4칸 · M104 `===` 대조가 통과에서 실패로**; M100 ~ M102 · M103 1 ~ 3칸 · M104 `---` · M106 은 06-08 판의 버전 어긋남(· 날짜 자리) 블록에서 첫 줄 블록으로 문구가 바뀜 (방향은 같음); **M105 BOM 바이트는 그대로 통과**.

끝: 복제본 `git status --porcelain` 빈 출력, 복제본 · 하네스 폴더 지움, 작업 트리 `fvm dart analyze` 깨끗 · 평소 실행 10/10 (22초), `build/woody_rule_check` 없음.

## (4) planner 선택 (그대로 따름)

- 블록 vs 70: 첫 줄 · 둘째 reader 실패는 `[3/10]` 블록 (`[message, '', changelogGuide]`) — 올바른 파일에서 검사가 본 값이 정책과 다른 것은 이 저장소에서 늘 `[3/10]` 실패였고, 문구 B 가 두 reader 의 값을 함께 보인다. pubspec 쪽 `FormatException` 은 그대로 70.
- 변형의 환경변수 경로: 대표 여섯의 세 경로 전체 실행으로 갈음 (`main` 이 같은 값을 `--tag` 와 같은 인자로 넘긴다).
- 정규식: `^## (\d+\.\d+\.\d+) - (\S.*?)[ \t]*$` — 버전 세 숫자, 날짜 자리 비어 있지 않음, 뒤 공백 · 탭 뗌, ` - ` 두 번은 날짜 자리로 넘겨 tag 모드의 `YYYY-MM-DD` 가 잡는다.

## Decisions Made

- 위 key-decisions 셋 (소유자 결정 G7-Q1 (나) · G7-Q2 IN-09 와 planner 선택을 그대로 구현).

## Deviations from Plan

**1. [Rule 2 - 기록 완전성] 보충 함수 단위 측정을 새 복제본 하나에서 더 돌렸다**
- **Found during:** Task 2 (기록 쓰기 전)
- **Issue:** `<automated>` 는 action 의 기대 가운데 일부만 단언한다 — M103 2칸 · 3칸은 돌리지 않고, M107 탭 변형 · M109 목록 · M106 등은 한 모드나 한 판만 본다. 기록의 "두 모드 · 전 → 후" 문장을 실제 결과로 채우려면 값이 모자랐다.
- **Fix:** 같은 절차(`set -u`, toplevel 단언, 하네스, 고치기 전 판 = Task 1 커밋의 부모)로 상태 A · C 의 모든 입력을 고친 판 · 고치기 전 판 × tag · tag 없이로 한 번 더 쟀다 (121초, 결과는 기대와 모두 같음 — M103 2 · 3칸도 1칸과 같은 꼴). 끝에 복제본 · 하네스를 지웠다. 기록의 "걸린 시간" 에 적었다.
- **Files modified:** 없음 (측정만) · **Commit:** 기록은 `317d3ff`

**2. [방법] Task 2 의 측정 실행으로 `<automated>` 의 실험 부분을 그대로 썼다**
- **Found during:** Task 2 action 1 ~ 3
- **Issue:** action 1 ~ 3 의 측정과 `<automated>` 의 실험 부분이 같은 명령이다.
- **Fix:** 기록을 쓰기 전에 `<automated>` 에서 README 단언 앞부분만 뺀 판을 `bash -x` (시각을 붙인 `PS4`)로 돌려 결과 · 걸린 시간을 얻었다 (rc 0, 534초). 기록을 쓴 뒤 `<automated>` 를 적힌 그대로 새 복제본에서 다시 돌렸다 (rc 0, 531초).
- **Commit:** `317d3ff`

**Total deviations:** 2 (측정 보충 1, 방법 1). **Impact:** 코드 · 기록 범위는 계획 그대로이고, 기록의 수치가 모두 실제 실행에서 왔다.

## Issues Encountered

- 측정 스크립트에 `TMPDIR` 를 내 임시 폴더로 줘도 스크립트 안쪽의 `mktemp -d` 는 시스템 임시 폴더에 만들었다 (macOS). 계획의 스크립트가 끝에 그 폴더들을 지우는 것을 경로로 확인했다 — 남은 것 없음.

## Known Stubs

없음.

## Threat Flags

없음 — 새 네트워크 · 파일 접근 표면 없음 (GitHub 렌더 API 같은 네트워크 확인을 쓰지 않았다).

## Next Phase Readiness

- Ready for 06-13 (`tool/smoke.dart` — 파일이 겹치지 않는다). 06-14 가 처리 기록에 WR-02 · WR-05 · IN-09 `fixed` (`85e1b0d` · `317d3ff`) 와 IN-08 `deferred` (근거: 위 기록의 읽는 법 (5)) 를 적는다. REL-03 표시는 06-15 가 한다 (이 plan 은 `requirements.mark-complete` 를 부르지 않았다).
- 기록 문서 · 커밋에 실제 홈 폴더 · 임시 폴더 경로 0줄, 저장소에 없는 경로 꼴 0줄 (추가된 줄의 `lib/…` 은 모두 있는 파일).

## Self-Check: PASSED

- FOUND: 수정한 일곱 파일 모두 존재
- FOUND: `85e1b0d`, `317d3ff` (HEAD 의 조상)
- Task 1 · Task 2 `<automated>` 적힌 그대로 rc 0 (각 커밋 전)
