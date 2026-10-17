---
phase: 06-release
plan: 08
subsystem: testing
tags: [dart, verify, package-yaml, package-markdown, changelog, pubspec, rel-03]

# Dependency graph
requires:
  - phase: 06-release
    provides: "06-01 의 [3/10] (i) 버전 일치 검사 · --tag · GITHUB_REF_NAME 모드, 06-07 까지의 릴리스 상태(2.0.0 · ## 2.0.0 - 2026-10-15)"
provides:
  - "[3/10] (i) 가 pubspec version 을 package:yaml 값(pubspecYamlVersion)에서, CHANGELOG 최상단을 package:markdown 해석의 첫 h2 (changelogTop, 깊이 무관) 에서 읽는다"
  - "(h) 의 pubspec 비교가 줄 단위 reader 의 원문 전체(pubspecVersionText ↔ version) — 머리 줄 (pubspecVersionText ↔ version)"
  - "pubspecReleaseVersion = releaseHead(pubspecVersionText) — 줄 단위 reader 하나 (IN-03)"
  - "dev_dependencies 의 markdown ^7.3.1 (lock 여섯 불변)"
  - "example/README.md 의 지워 보기 M98 ~ M106 소절 (06-08) 과 네 자리의 문장 (11행 · 70 행 · 117행 · 621행)"
  - "skill 세 줄의 의존성 규칙이 yaml · markdown 둘을 말한다 (G6-R2-Q1)"
affects: [06-09, 06-10, 06-11, release-gate, tool/verify.dart]

# Actuals (#2632)
actuals:
  tokens: 17654
  tasks: 2
  commits: 2
plan_head_before: 97848cd6303bb7978f0a5425c202142ca4721811
plan_head_after: c6187cd816e4b5407179c83d2e8250be1a4529d7

# Tech tracking
tech-stack:
  added: ["markdown 7.3.1 (dev_dependencies, publisher tools.dart.dev)"]
  patterns:
    - "값은 해석기(YAML · Markdown)에서 읽고, 남긴 줄 단위 reader 는 원문 전체를 해석기 값과 견주어 다르면 [3/10] 실패 (05 의 길 B)"
    - "CHANGELOG 최상단 = GitHub Flavored 해석의 문서 순서 첫 h2, 깊이 무관"

key-files:
  created: []
  modified:
    - pubspec.yaml
    - tool/verify.dart
    - example/README.md
    - .claude/skills/spike-findings-woody-lints/SKILL.md
    - .claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md
    - .claude/skills/spike-findings-woody-lints/references/rule-status-check.md

key-decisions:
  - "[3/10] (i) 는 pubspec version 을 package:yaml 값에서, CHANGELOG 최상단을 package:markdown (GitHub Flavored) 해석의 첫 h2 (깊이 무관) 에서 읽고, (h) 는 줄 단위 reader 의 원문 전체를 YAML version 과 견준다 — 두 겹 (G6-Q1)"
  - "raw HTML <h2> 는 해석기가 글자로 두어 CHANGELOG 최상단 검사 범위 밖으로 문장으로만 적었다 — VERSIONING.md 가 정한 꼴 밖"

patterns-established:
  - "고치기 전 판은 task 커밋의 부모 tool/verify.dart 를 복제본에 꺼내 같은 하네스로 번갈아 잰다"

requirements-completed: [REL-03]  # 이 plan 은 requirements.mark-complete 를 부르지 않는다 — REL-03 은 06-10 · 06-11 도 선언하므로 마지막 plan 이 표시한다

coverage:
  - id: D1
    description: "[3/10] (i) · (h) 의 version · CHANGELOG reader 가 해석기 값을 쓰고, 릴리스 상태의 작업 트리에서 평소 · --tag v2.0.0 · GITHUB_REF_NAME 이 10/10, --tag v2.0.1 이 블록 둘로 실패"
    requirement: "REL-03"
    verification:
      - kind: integration
        ref: "06-08-PLAN.md Task 1 <automated> (고친 판 — 따옴표 · lock 창 · grep -e 세 군데) rc 0"
        status: pass
    human_judgment: false
  - id: D2
    description: "M98 ~ M106 이 새 복제본에서 고친 판 실패 · 고치기 전 판 통과로 다시 재어지고 example/README.md 에 기록"
    requirement: "REL-03"
    verification:
      - kind: integration
        ref: "06-08-PLAN.md Task 2 <automated> (고친 판 — 따옴표 네 군데) rc 0"
        status: pass
    human_judgment: false

# Metrics
duration: 25min
completed: 2026-10-16
status: complete
---

# Phase 6 Plan 08: [3/10] 의 version · CHANGELOG reader 를 해석기 값으로 Summary

**`[3/10]` (i) 가 pubspec version 을 `package:yaml` 값에서, CHANGELOG 최상단을 `package:markdown` (GitHub Flavored) 해석의 첫 h2(깊이 무관)에서 읽고, (h) 가 줄 단위 reader 의 원문 전체를 YAML 과 견주게 되어 — 여러 줄 스칼라 · HTML 주석 · 펜스 · 들여 쓴 ATX · setext · 인용 · 목록 꼴의 거짓 통과가 닫혔다 (M98 ~ M106)**

## Performance

- **Duration:** 25 min
- **Started:** 2026-10-16T09:30:41Z
- **Completed:** 2026-10-16T09:56:40Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- `tool/verify.dart`: `releaseHead` · `pubspecYamlVersion` · `firstElement` 를 새로 두고, `pubspecReleaseVersion` 을 `releaseHead(pubspecVersionText(repoRoot))` 한 줄로 (IN-03), `changelogTop` 을 U+FEFF 떼기 → `md.Document(gitHubFlavored, encodeHtml: false).parseLines(splitYamlLines(…))` → 첫 h2 의 `textContent` 로, (h) 다섯째 비교를 원문 전체(`(pubspecVersionText ↔ version)`)로, (i) 를 `pubspecYamlVersion` 만 쓰고 `YamlException` 을 블록(`… version 을 견주지 못했다 — …`)으로 바꿨다. 머리 주석 6행 · 의존성 문단 · 세 함수와 (h) · (i) bullet 의 문서 주석이 새 동작을 말한다.
- `pubspec.yaml`: `dev_dependencies` 에 `markdown: ^7.3.1` 을 `yaml: ^3.1.4` 앞에, 이유 주석 두 줄(G6-Q1). 지운 줄 0.
- skill 세 줄(SKILL.md 52행 · analyze-run-and-verdict.md 13행 · rule-status-check.md 14행)이 같은 새 문장 — 개발용 의존성 둘(`package:yaml` 은 YAML 대조, `package:markdown` 은 CHANGELOG 최상단 제목). 파일마다 `1/1`.
- `example/README.md`: 새 소절 `### 추가 실측 — 여러 줄 스칼라 안의 version 과 Markdown 구조 안의 제목 (06-08)` (M98 ~ M106 아홉 행 · 가장자리 셋 · 회귀 넷 · 읽는 법 여섯 · 걸린 시간 · 되돌림), 네 자리의 문장 (11행 · 종료 코드 표 70 행 · 117행 (i) 구절 · 621행 (h) 다섯째 비교).

### (1) Task 1 — 작업 트리(HEAD = 릴리스 상태)의 네 실행

| 실행 | 종료 코드 | stderr 모드 줄 | 요약 |
|------|-----------|----------------|------|
| `fvm dart run tool/verify.dart` | 0 | `버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)` | `점검 통과 (10개 중 10개)` (21초) |
| `… --tag v2.0.0` | 0 | `버전 일치 검사: tag v2.0.0 (--tag)` | `점검 통과 (10개 중 10개)` (21초) |
| `GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v2.0.0 …` | 0 | `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` | `점검 통과 (10개 중 10개)` (21초) |
| `… --tag v2.0.1` | 1 | `버전 일치 검사: tag v2.0.1 (--tag)` | `[3/10]` 만 실패, 블록 둘(`` tag `v2.0.1` 의 버전 (2.0.1) 과 `pubspec.yaml` 의 version (2.0.0) 이 다르다. `` · `` … `CHANGELOG.md` 최상단 버전 (2.0.0) 이 다르다. ``), 안내 줄 둘, `점검 실패 (10개 중 1개)` (22초) |

- pub.dev API `packages/markdown/publisher` 의 응답 `{"publisherId":"tools.dart.dev"}` (실행 때 다시 확인), 최신 7.3.1 · SDK `^3.9.0` · 의존성 `args` · `meta`.
- 루트 `pubspec.lock` 의 `markdown`: `dependency: "direct dev"` · `source: hosted` · `url: "https://pub.dev"` · `version: "7.3.1"` (`fvm dart pub get --no-example` 이 `args 2.7.0` · `markdown 7.3.1` · `meta 1.19.0` 을 더함).
- lock 여섯(`example/` · `fixtures/` 다섯) 불변 — `git status --porcelain -- example fixtures` 빈 출력, 여섯 모두 `markdown` 글자 없음. `build/woody_rule_check` 남지 않음.

### (2) Task 2 — 복제본의 상태 A · B · C (경로는 `<복제본>`)

복제본은 `git clone --local`, 첫 변형 전에 `git -C <복제본> rev-parse --show-toplevel` 이 복제본인지 단언, `fvm dart pub get --no-example` (1초 이하, 뒤에 복제본 `git status` 빈 출력). 하네스는 복제본 밖의 Dart 파일 하나, `fvm dart run --packages=<복제본>/.dart_tool/package_config.json <하네스> <복제본> [tag]`. 고치기 전 판은 `git show <Task 1 커밋>~1:tool/verify.dart` 를 복제본에 꺼낸 것.

| 상태 · 꼴 | 고친 판 | 고치기 전 판 |
|-----------|---------|--------------|
| A 기준 (HEAD) | `v2.0.0` · tag 없이 `passed=true` | 같음 |
| A M103 ATX 1 · 2 · 3칸 | `passed=false` — `v2.0.0` 블록 둘(`… 최상단 버전 (2.1.0) 이 다르다.` · 날짜 자리 `미출시`), tag 없이 블록 하나(`(2.0.0 → 2.0.0) … (2.1.0)`) | `passed=true` |
| A M103 대조 4칸 | `passed=true` | `passed=true` |
| A M104 setext `---` | `passed=false` (M103 과 같은 블록) | `passed=true` |
| A M104 대조 `===` | `passed=true` | `passed=true` |
| A M105 U+FEFF 머리(바이트 `efbbbf`) | `passed=true` | `passed=true` |
| A M106 `>` · `-` 안의 h2 | `passed=false` (M103 과 같은 블록) | `passed=true` |
| A 가장자리 `# Changelog` | `passed=true` | `passed=true` |
| A 가장자리 `## **2.0.0** - …` | `passed=true` | `passed=false` (`(**2.0.0**)`) — 통과로 바뀐 입력 |
| A 가장자리 raw `<h2>2.0.1 - …</h2>` | `passed=true` | `passed=true` — 범위 밖 |
| A 회귀 M92 · M93 꼴 · M95 · M96 | 앞 기록과 같은 블록 (M92 안내 둘, M93 `-dev` 꼬리, M95 `미출시`, M96 꼴) | (같음) |
| B M98 겹따옴표 + lock 여섯 다시 받음 — 전체 실행 | `--tag v2.0.0` rc 1 (73초) · `GITHUB_REF_NAME` rc 1 (29초): (h) `(pubspecVersionText ↔ version)` `줄 단위 reader: 2.0.0` · `YAML: 2.0.0-dev` + (i) `-dev` 꼬리; 평소 rc 1 (33초): (h) 하나뿐; 셋 모두 `[3/10]` 만 · 10개 중 1개 · 각 모드 줄 | 하네스 `v2.0.0` · tag 없이 `passed=true` (전체 실행은 검증자 c5b 기록 rc 0 인용) |
| B M99 홑따옴표 | `passed=false` (`v2.0.0` 블록 둘, tag 없이 (h) 하나) | `passed=true` |
| C M100 HTML 주석 + 2.0.1 · README `ref:` 둘 · lock 여섯 — 전체 실행 | `--tag v2.0.1` rc 1 (35초) · `GITHUB_REF_NAME` rc 1 (26초): `` tag `v2.0.1` 의 버전 (2.0.1) 과 `CHANGELOG.md` 최상단 버전 (2.0.0) 이 다르다. `` 하나 · 안내 하나; 평소 rc 1 (25초): `(2.0.1 → 2.0.1) … (2.0.0)` | 하네스 `v2.0.1` · tag 없이 `passed=true` (검증자 cA2 기록 rc 0 인용) |
| C M101 백틱 펜스 · M102 `~~~` 펜스 | `passed=false` (M100 과 같은 블록, 두 펜스 글자까지 같음) | `passed=true` |

lock 다시 받기는 B · C 각 3초, 함수 단위는 각 0.7 ~ 1.0초, 되돌린 뒤 복제본 전체 실행 rc 0 · 10/10 (24초). 끝에 복제본 `git status --porcelain` 빈 출력 · `build/woody_rule_check` 없음, 복제본 · 하네스 폴더를 지웠다.

## Task Commits

1. **Task 1: pubspec · tool/verify.dart · skill 세 줄** — `6aa78fe` `fix(tool): [3/10] 의 version · CHANGELOG 최상단 reader 를 해석기 값으로 — pubspec 은 YAML, CHANGELOG 는 Markdown 첫 h2 (CR-01 · WR-02 · IN-03, REL-03)`
2. **Task 2: example/README.md 의 M98 ~ M106** — `c6187cd` `test(example): 지워 보기 M98 ~ M106 — 여러 줄 스칼라 안의 version 과 Markdown 구조 안의 제목 (06-08, REL-03)`

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 의 커밋 (docs)

## Files Created/Modified

- `pubspec.yaml` — `dev_dependencies` 의 `markdown: ^7.3.1` 과 이유 주석 두 줄
- `tool/verify.dart` — 두 reader 와 (h) · (i), import 넷, 문서 주석
- `example/README.md` — 새 소절 (06-08) · 11행 · 70 행 · 117행 · 621행
- `.claude/skills/spike-findings-woody-lints/SKILL.md` · `references/analyze-run-and-verdict.md` · `references/rule-status-check.md` — 의존성 규칙 한 줄씩

### (4) 고친 전후 — skill 세 줄 · 11행 (G6-R2-Q1)

- skill 세 줄, 전: `… 에 더해, YAML 대조에만 `package:yaml` 을 개발용 의존성(`dev_dependencies`)으로 쓴다 (D-11, 2026-10-15 G4-Q1)` → 후: `… 에 더해, 개발용 의존성(`dev_dependencies`) 둘을 쓴다 — `package:yaml` 은 YAML 대조에만, `package:markdown` 은 CHANGELOG 최상단 제목을 GitHub 화면과 같게 읽는 데만 (D-11, 2026-10-15 G4-Q1 · 2026-10-16 G6-Q1)`. 옛 구절은 세 파일에 남지 않았다.
- `example/README.md` 11행, 전: `… `package:yaml` 을 찾지 못하고 …` → 후: `… `package:yaml` · `package:markdown` (개발용 의존성 둘 — YAML 대조 · CHANGELOG 최상단 제목 읽기) 을 찾지 못하고 …` (`fvm dart pub get` 안내 · 254 · `2026-10-15 실측, Dart 3.13.4` 는 그대로). 626행과 622 ~ 631행은 HEAD 와 byte 단위로 같다. `.claude/CLAUDE.md` 불변.
- raw HTML `<h2>` 는 범위 밖으로 두었다 — `changelogTop` 문서 주석과 새 소절의 가장자리 · 읽는 법 (3) 에 문장으로만 적고 검사를 넓히지 않았다.

## Decisions Made

- 위 key-decisions 둘. 그 밖은 계획대로.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Task 1 `<automated>` 의 결함 셋 — 고친 판으로 실행**
- **Found during:** Task 1 검증
- **Issue:** 적힌 그대로의 실행은 rc 2 (구문 오류). (a) `"$(…)\" = N` 꼴 네 군데의 `\"` 가 닫는 따옴표를 글자로 만들어 구문이 깨짐; (b) 루트 lock 의 `markdown` 항목에서 `version:` 은 머리 줄의 7줄 아래인데 `grep -A6` 이라 늘 실패 (yaml 항목도 같은 꼴); (c) `grep -qxF "$NEWS"` 의 `$NEWS` 가 `- ` 로 시작해 grep 이 옵션으로 읽음 (`invalid option -- ` rc 2).
- **Fix:** (a) `\"` → `"` 네 군데, (b) `grep -A6` → `grep -A7`, (c) `grep -qxF -e "$NEWS"` 세 군데. 단언의 뜻은 그대로.
- **Verification:** 고친 판 rc 0 (Task 1 커밋 전 작업 트리에서).
- **Committed in:** 해당 없음 (검증 명령만)

**2. [Rule 3 - Blocking] Task 2 `<automated>` 의 `\"` 네 군데 — 고친 판으로 실행**
- **Found during:** Task 2 검증
- **Issue:** 적힌 그대로의 실행은 rc 2 — 같은 `)\" = N` 꼴 네 군데(M92 안내 수 · 평소 `-dev` 0줄 · README `ref: v2.0.1` 둘 · 상태 C 안내 수)에서 따옴표가 어긋나 상태 A 뒤의 `test` 가 `too many arguments` 로 끝났다 (그 사이 따옴표 밖으로 나온 backtick 글자가 `-dev: command not found` 같은 줄을 냈다 — 부작용 없음).
- **Fix:** `)\" = ` → `)" = ` 네 군데. python 글자 치환 안의 `\"` 는 그대로.
- **Verification:** 고친 판 rc 0 (309초).
- **Committed in:** 해당 없음 (검증 명령만)

**3. [Rule 2 - Correctness] tag 이름이 `vX.Y.Z` 꼴이 아닐 때도 YAML 블록을 버리지 않음**
- **Found during:** Task 1
- **Issue:** 계획의 (i) 는 `YamlException` 을 블록으로 더한 뒤, 꼴이 아닌 tag 에서는 블록 하나만 돌려주는 기존 `return` 이 앞의 블록을 버린다.
- **Fix:** 그 `return` 에 `...blocks` 를 앞에 두었다. pubspec 이 YAML 로 읽히면 `blocks` 가 비어 M96 의 결과는 그대로다 (회귀 M96 통과).
- **Files modified:** `tool/verify.dart`
- **Committed in:** `6aa78fe`

**4. [문서] (i) bullet 의 평소 모드 문구**
- `checkShippedComposition` 문서 주석 (i) bullet 의 "tag 가 없으면 [pubspecReleaseVersion] == …" 도 새 동작대로 "[pubspecYamlVersion] 의 꼬리를 뗀 값 == …" 으로 고쳤다 (계획의 5번은 tag 쪽 구절만 적었다). `6aa78fe`.

---

**Total deviations:** 4 (검증 명령 고친 판 2, 정확성 1, 문서 1)
**Impact on plan:** 코드 · 기록의 범위는 계획 그대로이고, 검증 명령의 결함은 단언의 뜻을 바꾸지 않고 고쳤다.

## Issues Encountered

- 적힌 그대로의 Task 2 검증 명령이 중간에 끊겨 자기 복제본 · 하네스 폴더를 지우지 못하고 기본 임시 폴더에 남겼다. `TMPDIR` 를 내 임시 폴더로 주었지만 macOS 의 `mktemp -d` (template 없음)는 `TMPDIR` 가 아니라 사용자 임시 폴더를 쓴다. 남은 두 폴더(복제본의 origin 이 이 저장소인 것 · 그 복제본을 import 하는 하네스)를 확인하고 지웠다. Task 1 검증 명령의 `mktemp` 파일 넷과 고친 판 Task 2 의 두 폴더도 기본 임시 폴더에 생겼다가 같은 명령 안에서 지워졌고, Task 1 커밋 전의 함수 단위 탐침 하나가 Dart 의 `Directory.systemTemp` 에 폴더 하나를 만들었다가 지웠다. 저장소 안에는 아무것도 남지 않았다.
- 네트워크 정지 없음.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 06-09 (`tool/smoke.dart` 만) 가 같은 작업 트리에서 돌 수 있다 — 06-08 은 `tool/smoke.dart` 를 건드리지 않았다.
- 06-10 이 처리 기록에서 CR-01 · WR-02 · IN-03 을 이 plan 의 커밋(`6aa78fe` · `c6187cd`)으로 닫을 수 있다. REL-03 표시는 마지막으로 선언한 plan 이 한다.

---
*Phase: 06-release*
*Completed: 2026-10-16*

## Self-Check: PASSED

- 파일: `pubspec.yaml` · `tool/verify.dart` · `example/README.md` · skill 세 파일 모두 있음
- 커밋: `6aa78fe` · `c6187cd` 이 HEAD 의 조상
- 고친 판 Task 1 · Task 2 `<automated>` rc 0, 두 task 뒤 `.planning` 밖 `git status --porcelain` 빈 출력, `fvm dart analyze` 깨끗
