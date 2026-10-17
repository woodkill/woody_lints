---
phase: 05-documentation
plan: 14
subsystem: testing
tags: [dart, yaml, package-yaml, verify, analysis-options, gap-closure]

requires:
  - phase: 05-documentation
    provides: "05-12 · 05-13 의 tool/verify.dart (d8b61b0) — 줄 단위 reader 다섯 · splitYamlLines · [3/10] (a′) ~ (g)"
provides:
  - "pubspec.yaml 의 dev_dependencies 에 yaml ^3.1.4 (이유 주석 두 줄) — 받는 쪽 의존성 그래프에는 들어가지 않는다"
  - "tool/verify.dart [3/10] 의 마지막 확인 (h) compareLineReadersWithYaml — 줄 단위 reader 다섯의 값을 package:yaml 의 loadYaml 결과와 견줌, YAML 로 읽지 못하는 파일도 실패"
  - "example/README.md 의 소절 `### 추가 실측 — 여러 줄 문자열 안의 줄 (05-14)` (M86 ~ M91 · 회귀 확인 · 읽는 법)"
  - "skill 세 줄 · README 380행 · example/README.md 11행이 새 의존성과 `pub get` 순서를 말함 (G4-R2-Q1 · G4-R2-Q2 · G4-R3-Q1)"
  - "README 382행 · example/README.md 116 · 395행 · tool/verify.dart 주석 셋의 IN-10 · IN-11 문장 (G4-Q2)"
affects: [05-15, verify-work, phase-06-release]

actuals:
  tokens: 9158
  tasks: 2
  commits: 2
plan_head_before: 41fb7b47a1810eb21349a83f5de1ded925aa04dd
plan_head_after: 0f620572b7e1b8c6d07f4b92be5b20cb36b5a708

tech-stack:
  added: ["yaml 3.1.4 (dev_dependencies, pub.dev, publisher tools.dart.dev)"]
  patterns:
    - "줄 단위 reader 는 그대로 두고, 같은 파일을 진짜 해석기(package:yaml)로 읽은 값과 견주는 한 겹을 더한다 — 다르면 [3/N] 실패 블록"
    - "reader 가 본 키는 reader 의 본문을 바꾸지 않고 받는 키를 비워 두 번 불러 얻는다 (keysSeenByLineReader)"

key-files:
  created: []
  modified:
    - pubspec.yaml
    - tool/verify.dart
    - example/README.md
    - README.md
    - .claude/skills/spike-findings-woody-lints/SKILL.md
    - .claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md
    - .claude/skills/spike-findings-woody-lints/references/rule-status-check.md

key-decisions:
  - "(h) 의 불일치와 YAML 로 읽지 못하는 파일은 종료 코드 70 이 아니라 [3/10] 실패 블록 — 계획의 설계 그대로 (G4-Q1 이 planner 재량으로 맡김)"
  - "아래 키는 allowedChildKeys 의 둘만이 아니라 값 없는 최상위 키 모두에서 견줌 — M86 의 linter: · M89 의 analyzer: 아래가 드러남"
  - "YamlException 만 잡고 블록 하나로 알린 뒤 그 파일의 다른 비교는 건너뜀 — 그 밖의 예외는 main 이 받음"

patterns-established:
  - "검사가 본 값 ≠ YAML 이 본 값 자체를 실패로 — 꼴을 하나씩 막지 않는다 (소유자 결정 G4-Q1, 길 B)"

requirements-completed: [VERIFY-06, DOCS-06]

coverage:
  - id: D1
    description: "[3/10] (h) — 줄 단위 reader 다섯(규칙 · 최상위 키와 그 아래 키 · analyzer 옵션 · riverpod_lint 선언 · version)의 값을 YAML 해석 결과와 견주어 다르거나 읽지 못하면 실패 (M86 ~ M91, 선언만 다른 입력, 같은 키 두 번), 맞는 파일은 거짓 실패 없음 (CRLF · CR), 앞 기록 그대로 (M79 · M37 · M45 · M61 · M66)"
    requirement: "VERIFY-06"
    verification:
      - kind: integration
        ref: "05-14-PLAN.md Task 1 <automated> (복제본 지워 보기 — 적힌 그대로 실행, 238초)"
        status: pass
    human_judgment: false
  - id: D2
    description: "dev_dependencies 의 yaml — 새 복제본의 pub get 없는 첫 실행(CI 꼴) 10/10, 받는 쪽 lock 불변, 낡은 package config 의 254 → pub get 뒤 64"
    requirement: "VERIFY-06"
    verification:
      - kind: integration
        ref: "05-14-PLAN.md Task 1 <automated> (같은 실행)"
        status: pass
    human_judgment: false
  - id: D3
    description: "skill 세 줄 · README 380행 · example/README.md 11행 (새 의존성 · pub get 순서) 과 (05-14) 소절의 기록"
    requirement: "DOCS-06"
    verification:
      - kind: other
        ref: "05-14-PLAN.md Task 1 <automated> (줄 전체 · numstat · 표 칸 수 · M1 ~ M85 불변 단언)"
        status: pass
    human_judgment: false
  - id: D4
    description: "README 382행 · example/README.md 116 · 395행 · tool/verify.dart 주석 셋의 IN-10 · IN-11 문장, 코드 줄 불변, 작업 트리 검증 10/10"
    requirement: "DOCS-06"
    verification:
      - kind: other
        ref: "05-14-PLAN.md Task 2 <automated> (적힌 그대로 실행, 21초)"
        status: pass
    human_judgment: false

duration: 18min
completed: 2026-10-15
status: complete
---

# Phase 05 Plan 14: 줄 단위 reader 와 YAML 해석 결과의 대조 Summary

**`tool/verify.dart` 의 `[3/10]` 에 확인 (h) `compareLineReadersWithYaml` 을 더해, 줄 단위 reader 다섯이 읽은 규칙 · 키 · analyzer 옵션 · riverpod_lint 선언 · version 을 개발용 의존성 `yaml` 3.1.4 의 `loadYaml` 결과와 건수까지 견주고 다르거나 YAML 로 읽지 못하면 실패시킴 — 여러 줄 문자열 안에 숨긴 입력 여섯(M86 ~ M91)이 모두 실패, 기준은 10개 중 10개**

## Performance

- **Duration:** 18 min
- **Started:** 2026-10-14T20:56:44Z
- **Completed:** 2026-10-14T21:15:09Z (KST 2026-10-15)
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- `pubspec.yaml` 맨 끝(17행 뒤)에 빈 줄 · 주석 두 줄(`analyzer · pub 과 같은 해석기`, `의존성 그래프에 들어가지 않는다`, `G4-Q1`) · `dev_dependencies:` · `  yaml: ^3.1.4` 만 더했다. 1 ~ 17행은 그대로다. 바꾼 직후 작업 트리에서 `fvm dart pub get --no-example` 을 돌렸고 루트 `pubspec.lock` 의 `yaml` 은 `direct dev` · pub.dev · 3.1.4 다 (lock 과 `.dart_tool/` 은 무시 대상이라 스테이징하지 않았다).
- `tool/verify.dart`: import 셋(`dart:convert` · `dart:io` · `package:yaml/yaml.dart`), 머리 주석의 `[3/N]` 설명 끝 구절과 의존성 문단(D-11 을 이 목적에 한해 다시 정함, `pub get` 순서), `findListLinesOutsideMarkers` 뒤 · `/// [3/N] 배포 파일의 구성` 문서 주석 앞에 새 선언 일곱(`yamlAgreementHint` · `keysSeenByLineReader` · `keysSeenByYaml` · `yamlRuleNames` · `yamlLanguageOptions` · `yamlPluginConstraint` · `compareLineReadersWithYaml`, 모두 한국어 문서 주석), `checkShippedComposition` 문서 주석의 (h) bullet, `return StepResult(` 바로 앞의 `// (h) …` 주석 한 줄과 호출 `  compareLineReadersWithYaml(repoRoot).forEach(addBlock);`. `d8b61b0` 대비 지운 코드 줄은 0, reader · 도우미 열셋의 코드 줄은 그대로다.
- (h) 가 견주는 다섯 가지와 블록 꼴: 조각 셋마다 규칙(`declaredRuleNames` ↔ `linter.rules`), 최상위 키(`findUnexpectedKeys ↔ 최상위 맵`), 값 없는 최상위 키마다 바로 아래 키(`findUnexpectedKeys ↔ <키> 맵`), `lib/base.yaml` 의 analyzer 옵션(`enabledLanguageOptions ↔ analyzer.language`), `lib/riverpod.yaml` 의 선언(`readShippedPluginConstraint ↔ plugins.riverpod_lint`), 그리고 `pubspec.yaml` 의 version(`pubspecReleaseVersion ↔ version`). 블록은 머리 줄 `` `<경로>` 의 <무엇> — 줄 단위 reader 와 YAML 이 다르게 읽었다 (<reader> ↔ <YAML 자리>) ``, 두 값 줄(`  줄 단위 reader 에만: …` · `  YAML 에만: …` 또는 `  줄 단위 reader: …` · `  YAML: …`), 빈 줄, 안내 줄이다. YAML 로 읽지 못하면 `` `<경로>` 을 YAML 로 읽지 못했다 — <N>행: <메시지> `` 블록 하나.
- 복제본 실측(05-14 소절에 기록): 새 복제본의 `pub get` 없는 첫 실행 69초 · 종료 코드 0 · 10개 중 10개 · 뒤의 `git status --porcelain` 빈 출력; M86 · M87 · M88 · M89 각 23초 · 종료 코드 1 · `[3/10]` 만 · `점검 실패 (10개 중 1개)` 와 정해진 블록; M90 · M91 함수 단위 `passed=false`; 계획 검증 — 선언만 다른 입력 블록 하나(`줄 단위 reader: ^3.1.9` · `YAML: ^3.2.0`), 같은 키 두 번 블록 하나(`10행: Duplicate mapping key.`), CRLF · CR 변형 `passed=true`; 회귀 M79 23초 · M37 22초(둘 다 (h) 블록 없음), M45 4초 · M61 3초 · M66 2초(종료 코드 70 · 빈 stdout · 앞 기록의 stderr); M68 · M69 · M70 · M73 · M78 은 (a′) 줄 그대로에 (h) 블록이 더해짐; 낡은 package config 로 `--bogus` 254, `pub get` 뒤 64; 되돌린 뒤 22초 · 10/10.
- 실행 안내 · skill (G4-R2-Q1 · G4-R2-Q2 · G4-R3-Q1): skill 세 줄(`SKILL.md` 52행 · `references/analyze-run-and-verdict.md` 13행 · `references/rule-status-check.md` 14행)을 정해진 줄 전체로, README 380행에 `pubspec.yaml` 이 바뀐 뒤 `fvm dart pub get` 을 먼저 한 번 돌린다는 구절, `example/README.md` 「실행」 절 11행에 같은 뜻의 문장 (줄을 끼우지 않아 116 · 395행 자리 그대로).
- 문장 · 주석 (G4-Q2, Task 2): README 382행 · `example/README.md` 116 · 395행에 "펜스 안에서 네 칸 이상 들여 쓴 `` ``` `` · `~~~` 줄은 그 펜스를 닫는 것으로 보아 그 뒤의 같은 블록 값은 견주지(보지) 않는다" 구절 (IN-10). `tool/verify.dart` 주석 자리 셋 — `fencedLines` 문서 주석 끝에 닫는 줄의 들여쓰기를 보지 않는다는 줄 하나, `checkShippedComposition` 문서 주석의 범위 밖 문장 끝(`IN-08 · IN-10 — 소유자 결정 G2-Q2 · G2-Q5 · G3-Q2 · G4-Q2`), `stripPlugins` 문서 주석 `복사본의 줄 번호가 원본과 같다 (끝의 빈 줄은 빠질 수 있다 — 05-REVIEW.md IN-11, 소유자 결정 G4-Q2)` (IN-11). 코드 줄은 Task 1 커밋과 글자 그대로 같다.

## Task Commits

1. **Task 1 (tracer): dev_dependencies 의 yaml 과 [3/10] (h) compareLineReadersWithYaml, 지워 보기 M86 ~ M91 · 회귀 기록, skill 세 줄 · README 380행 · example/README.md 11행** — `77e0b88` (fix) — 제목 머리 `fix(tool): 줄 단위 reader 가 읽은 값을 YAML 해석 결과와 견줌 `
2. **Task 2: 문장 · 주석만 (IN-10 · IN-11)** — `0f62057` (docs) — 제목 머리 `docs: 4회차 gap 의 문장 맞춤 — `

05-15 의 처리 기록 매핑: WR-15 · WR-16 → `77e0b88`, IN-10 · IN-11 → `0f62057`.

## 자동 검증 (`<automated>`) 결과

| 검증 | 돌린 시점 | 판 | rc | 걸린 시간 |
|------|-----------|----|----|-----------|
| Task 1 `<automated>` | Task 1 커밋 직후, Task 2 시작 전 | 적힌 그대로 (계획 파일에서 뽑아 `bash -x`) | 0 | 238초 |
| Task 2 `<automated>` | Task 2 커밋 직후, metadata 커밋 전 | 적힌 그대로 | 0 | 21초 |

고친 판은 필요하지 않았다. 커밋 전마다 `fvm dart analyze` 는 `No issues found!`, `fvm dart format --output=none --set-exit-if-changed tool` 은 종료 코드 0, 고친 파일의 BOM 바이트는 0 이었다. Tracer 게이트: interactive · `end-of-phase` · `<automated>` 만이라 Task 1 검증을 다시 돌려 통과한 뒤 Task 2 로 넘어갔다.

## Files Created/Modified

- `pubspec.yaml` — dev_dependencies 의 `yaml: ^3.1.4` 와 이유 주석 두 줄
- `tool/verify.dart` — import · 머리 주석 · 새 선언 일곱 · (h) 호출 한 줄 (Task 1), 주석 자리 셋 (Task 2)
- `example/README.md` — 11행 문장 · (05-14) 소절 (Task 1), 116 · 395행 구절 (Task 2)
- `README.md` — 380행 구절 (Task 1), 382행 구절 (Task 2)
- `.claude/skills/spike-findings-woody-lints/SKILL.md` · `references/analyze-run-and-verdict.md` · `references/rule-status-check.md` — 의존성 규칙 한 줄씩

## Decisions Made

- 계획의 설계를 그대로 따랐다 — (h) 는 `[3/10]` 실패, YAML 로 읽지 못하는 파일도 블록 하나(`YamlException` 만 잡음), 아래 키는 값 없는 최상위 키 모두에서 견줌, reader 가 본 키는 `findUnexpectedKeys` 를 받는 키 없이 두 번 불러 얻음.
- 구현 재량: 블록을 만드는 지역 함수(`compareLists` · `addValueBlock` · `load`)와 지역 상수(`disagree` · `pluginFragment`)를 `compareLineReadersWithYaml` 안에 두었다 (계획의 "지역 함수 · 지역 변수는 구현 재량").

## Deviations from Plan

None - plan executed exactly as written.

## 승인 밖 같은 모양 (보고만)

새로 찾은 것은 없다. 계획의 「승인 밖 같은 모양」 목록(`stripPlugins` · `readRuleNameAt` 의 복사본 줄, `readUpstreamRules`, `significantLines` 를 쓰는 (a) · `[4/10]`, `.claude/CLAUDE.md` 261행, `05-VALIDATION.md` 의 Test Infrastructure 문장, skill 의 spike 실측 스크립트 문장들)은 그대로 두었다.

## Issues Encountered

- 네트워크 오류 없음 — `fvm dart pub get --no-example` 와 복제본의 `dart run` 이 `yaml` 3.1.4 를 처음 시도에 받았다.
- Task 1 `<automated>` 를 돌릴 때 준 `TMPDIR` 은 명령 안의 `mktemp -d` 에 먹지 않아 복제본이 시스템 임시 폴더에 생겼다 — 명령이 끝에 그 폴더를 지웠고 저장소 · 기록에는 경로가 남지 않았다 (절대 경로 꼴 0줄 단언 통과).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-15 (처리 기록 WR-15 · WR-16 · IN-11 `fixed` · IN-10 `skipped` 와 push) 가 이 위에 얹힌다. 작업 트리에는 GSD 도구 상태 넷(`.planning/config.json` 수정, `.planning/state.json` · `.planning/milestone.lock` · `.planning/research/.cache/`)만 남는다.
- VERIFY-06 · DOCS-06 의 `requirements.mark-complete` 는 부르지 않았다 — 마지막으로 선언한 plan 05-15 가 표시한다.
- verifier 에게: 앞 plan 들의 단언 가운데 이 plan 뒤로 낡는 것 — 05-07 ~ 05-13 의 `git diff --quiet 968a5bb -- pubspec.yaml` (새 기준은 `77e0b88`), "import 둘", M 행 수 85 (이제 91), 05-12 Task 2 의 `example/README.md` `4/4` 와 README 단언, `example/README.md` "줄을 더하기만" 꼴 (11행이 바뀜). Task 1 의 `<automated>` 도 Task 2 뒤에는 상태 고정 단언(README hunk 1개 등)이라 rc 1 이 된다.
- GitHub runner 에서의 `yaml` 받기는 05-15 의 push 뒤 `verify` run 이 확인한다 (로컬 새 복제본의 CI 꼴 실행은 10/10).

---
*Phase: 05-documentation*
*Completed: 2026-10-15*

## Self-Check: PASSED

- 수정 파일 일곱 모두 있음 (FOUND), task 커밋 `77e0b88` · `0f62057` 모두 HEAD 의 조상 (FOUND), 두 task 의 `<automated>` rc 0.
