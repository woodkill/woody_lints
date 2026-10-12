---
phase: 04-rule-reselection
plan: 02
subsystem: testing
tags: [dart-analyze, dart-fix, measurement, analyzer-plugin, riverpod-lint, rule-selection]

requires:
  - phase: 04-rule-reselection
    provides: "04-01 — lib/base.yaml 의 규칙 6개, RULES.md 뼈대, tool/verify.dart [3/10]"
  - phase: spikes
    provides: "spike 020 ~ 023 의 스크립트 조각 (Repo · Diag · Shot · Consumer, messages.yaml 읽기, dart fix 세기, 무시 주석 걷어내기)"
provides:
  - "tool/measure_rules.dart — 규칙 실측 도구 (CLI · state 단계 · 복사본 단계 여섯 · 회차 유효성 · 저장소 지문, dart:io · dart:convert 만)"
  - "결과 JSON schema 1 — conditions · runs[] · rows{} (후보 133행), 건수와 조건만"
  - "후보 133 상수와 시작 때의 수 단언, 비호환 쌍 10개 상수"
affects: [04-03, 04-04, 04-05, 04-06, 04-07, 04-08, 04-09]

actuals:
  tokens: 28109
  tasks: 2
  commits: 2
plan_head_before: 3daada95768407bb2d755d3e14277eabee8a7a06
plan_head_after: c8e873fd8cc8e77b47b72a408b28ce3c05409119

tech-stack:
  added: []
  patterns:
    - "단계 경계마다 저장소 지문 비교 (RepoGuard.step) — 다르면 그 자리에서 종료 코드 1"
    - "회차 유효성은 멈춤이 아니라 표시 — valid: false 회차를 저장하고 행의 invalidRuns 에 적은 뒤 종료 코드 1"
    - "복원의 출처는 <work>/pristine/ — 원본(--source)은 File.copySync 의 원본 인자로만 쓴다"
    - "단계가 기대는 앞 회차를 인자 검증 때 결과 파일(읽기만)로 확인 — 없으면 64"

key-files:
  created:
    - tool/measure_rules.dart
  modified: []

key-decisions:
  - "결과 JSON 의 회차에 options(켠 규칙 이름 · 언어 옵션 · sdk)와 projectBySeverity 를 더 적는다 — fix 단계가 다른 실행에서 before 회차의 옵션을 되살리고 새 error 를 세려면 필요하다 (경로 · 메시지는 여전히 없다)"
  - "stripIgnores 는 표식 폴더(이 저장소의 샘플)를 건드리지 않는다 — 걷어낸 회차에서도 정답지 줄 ⊆ 표식 줄 대조가 그대로 성립한다"
  - "include 한 줄짜리 옵션 파일(example/)에는 linter: rules: 블록을 새로 붙이고, 원본의 rules: 가 목록 형식이면 목록으로, 맵 형식이면 맵으로 끼운다"
  - "unnecessary_underscores (묶음 status) 는 기반 세트(lints recommended)에 들어 있어 후보가 아니다 — bundles 상수에만 있고 행은 없다"

patterns-established:
  - "실측 도구의 출력 구조가 비공개 정보의 첫째 장치다 — Shot.toJson 에 경로 · 메시지 필드가 없고, 원문은 <work>/private/ 에만"
  - "같은 run id 로 다시 돌리면 같은 id 의 회차를 바꿔 쓴다 — 네트워크로 무효가 된 회차는 그 단계만 다시 돌려 고친다"

requirements-completed: [RULES-03, RULES-04, RULES-05]

coverage:
  - id: D1
    description: "CLI 인자 검증 — 인자 없음 · --work 저장소 안 · 모르는 --rules · pristine 없이 --source 없는 baseline · 모르는 --stage 가 모두 64 이고 아무것도 만들지 않음"
    requirement: "RULES-05"
    verification:
      - kind: integration
        ref: "04-02-PLAN.md Task 1 <automated> (R0 ~ R4 = 64, build/_probe_work · <work> 없음, git status 전후 같음)"
        status: pass
    human_judgment: false
  - id: D2
    description: "state 단계 — 후보 133행, 상태 stable 129 · testing 2 · experimental 1, analysis 전부 ok, upstream 전부 null, 비호환 쌍 10/10 confirmed, 기반 세트 lints-6.1.0 · flutter_lints-6.0.0"
    requirement: "RULES-04"
    verification:
      - kind: integration
        ref: "04-02-PLAN.md Task 1 <automated> (python 단언 'state ok', 결과 JSON 의 \"message\" 0번)"
        status: pass
    human_judgment: false
  - id: D3
    description: "복사본 단계 여섯이 example/ 을 사용 프로젝트 삼아 끝에서 끝까지 — 회차 아홉 모두 valid, 저장소 git status 불변"
    requirement: "RULES-03"
    verification:
      - kind: integration
        ref: "04-02-PLAN.md Task 2 <automated> 1 (consumer ok) · 2 (fix ok), git diff --quiet HEAD -- lib example fixtures tool/verify.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "회차 유효성 — 무효 회차를 표시하고 종료 코드 1 (멈추지 않음)"
    requirement: "RULES-05"
    verification:
      - kind: integration
        ref: "첫 smoke 의 G1-strip (네트워크 끊김으로 plugin 준비 실패 → valid: false, 실행 종료 코드 1)"
        status: pass
    human_judgment: false
  - id: D5
    description: "저장소 지문이 바뀌었을 때 종료 코드 1 로 멈추는 분기"
    verification: []
    human_judgment: true
    rationale: "실행 중 저장소를 일부러 바꾸는 실험을 하지 않았다 — 분기는 코드로만 있고 실행으로 일으켜 보지 않았다"

duration: 27min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 02: 규칙 실측 도구 `tool/measure_rules.dart` Summary

**spike 020 ~ 023 의 조각을 한 파일로 이은 실측 도구 — 후보 133개의 상태 · 상류 세트 · 비호환 쌍을 재는 `state` 단계와, 저장소 밖 복사본에서 기준선 · 그룹 · 표식 · 무시 주석 · `dart fix` · `unnecessary_ignore` 를 재는 단계 여섯을, 단계마다의 저장소 지문과 회차 유효성 판정과 함께 갖췄다**

## Performance

- **Duration:** 약 27분
- **Started:** 2026-10-12T23:29:16Z
- **Completed:** 2026-10-12T23:56:12Z
- **Tasks:** 2
- **Files modified:** 1 (새 파일 `tool/measure_rules.dart`, 3073행)

## Accomplishments

- 인자 검증: `--work` 는 늘 필수이고 저장소 밖이어야 한다 (링크를 푼 경로로 견준다). `--source` 는 `<work>/pristine/` 이 없을 때만 필수, `--rules` 는 후보 이름과 `@probes` 만, `--stage` 는 허용 목록만. 틀리면 종료 코드 64 이고 저장소에도 작업 폴더에도 아무것도 만들지 않는다. `--summary` · `--report` · `--write` · `--audit` 는 받아들이되 `아직 구현되지 않았다` 와 64 (04-03 몫).
- 후보 133 상수: FEATURES.md B-1 ~ B-6 의 125 (절마다 29 · 8 · 42 · 9 · 4 · 33) + `use_primary_constructors` + 지금 켠 6 + `strict-inference`. 시작할 때 이름 133 · 중복 없음 · G1 113 · G2 4 · G3 2 · G4 7 · current 6 · option 1 · v2 12 를 단언한다.
- `state` 단계: tag 3.13.4 `messages.yaml` 을 받아(실패 시 spike 020 결과로 대신) 상태를 읽고, 하한 `^3.13.0` 패키지 분석으로 deprecated / removed / 없는 이름을 가르고, 비호환 쌍 10개를 쌍마다 둘만 켜 확인하고, 저장소 루트의 `lints` · `flutter_lints` YAML 로 상류 세트를 적는다. 한 번에 약 6초.
- 복사본 단계 여섯과 `validate` — 회차마다 날짜 · Dart · Flutter · 기반 세트(저장소 · 복사본) · plugin · 언어 버전 · SDK 제약 · Dart 파일 수 · 옵션 · `woodySource` · `expectedCovered` · `valid` 를 적는다.
- 결과 JSON 에는 경로 · 메시지가 없다 (`"message"` 0번, `/Users/` · `/private/` · `/var/folders` 0줄). 줄 전문 · `dart fix` 화면 원문 · pub get 실패 원문은 `<work>/private/` 에만.

## Smoke 실행 결과 (example/ 을 사용 프로젝트로, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13)

작업 폴더는 계획대로 `${TMPDIR}/woody_measure_smoke_02` (`<work>` — 링크를 거치는 자리라 진단 경로의 base 둘 처리가 함께 확인됐다).

| 회차 | valid | 프로젝트 줄 | 표식 줄 | 시간 |
|------|-------|-------------|---------|------|
| B0 | true | 17 | 16 | 15.1초 |
| B0-313 | true | 17 | 16 | 15.3초 |
| G1 (`--rules` 셋) | true | 17 | 16 | 16.0초 |
| G1-marker | true | 17 | 19 | 15.8초 |
| B0-strip | true | 17 | 16 | 15.7초 |
| G1-strip | true | 17 | 16 | 16.6초 |
| apply-prefer_const_constructors | true | 16 | 16 | 15.8초 |
| UI-base | true | 17 | 16 | 15.7초 |
| UI | true | 17 | 16 | 16.8초 |

- `prefer_const_constructors`: counts lib 1, `aloneDry` 1, **`fixRemoved` 1**, `newErrors` 0, `otherDelta` {}.
- `no_dynamic_casts` · `no_raw_types` · `async_return_with_no_await`: counts 0 · ignored 0 · `markerDetected` true · severity info (표식 셋이 G1-marker 의 표식 줄 16 → 19).
- `unnecessary_ignore.countsUI` lib 0 · test 0 · bin 0, `unnecessaryIgnoreNames` {} (example/ 에 무시 주석이 없다).
- `state` (run id T1): 상태 stable 129 · testing 2 · experimental 1 (`messages.yaml@3.13.4`), analysis 전부 ok, upstream 전부 null, 쌍 10/10.

## 검증 명령 결과

- Task 1 `<automated>`: 계획의 명령 그대로 rc 0. `;` 구간은 R0 ~ R4 를 따로 찍어 모두 64 임을 봤고(앞 구간의 정적 확인이 실패하면 R0 이 64 가 아니게 되어 뒤 단언이 잡는다), `state` 실행 RS 0, python `state ok`. Task 2 변경 뒤에도 다시 돌려 rc 0.
- Task 2 `<automated>` 1: 첫 실행 RB 0 · **RG 1** (아래 Issues) → 네트워크 확인 뒤 작업 폴더를 지우고 처음부터 다시 돌려 RB 0 · RG 0 · `consumer ok`, 전체 rc 0 (1분 39초).
- Task 2 `<automated>` 2: RF 0 · RU 0 · `fix ok` · 정답지와 배포 파일 `git diff --quiet` 통과, 전체 rc 0 (57초).
- 추가 확인: 앞 회차(B0) 없이 `--stage groups` → 종료 코드 64, 작업 폴더에 새 파일 없음.
- 각 커밋 전 루트 `fvm dart analyze` `No issues found!`, `fvm dart format --set-exit-if-changed tool` 0.

## Task Commits

1. **Task 1: CLI 껍데기 · 이어 받는 클래스 · 후보 133 상수 · state 단계 · 결과 JSON · 저장소 지문** — `78c02cb` (feat)
2. **Task 2: 복사본 단계 여섯과 회차 유효성** — `c8e873f` (feat)

**Plan metadata:** 마무리 커밋 (docs: SUMMARY · STATE · ROADMAP · REQUIREMENTS)

## Files Created/Modified

- `tool/measure_rules.dart` — 규칙 실측 도구 (새 파일). 저장소 안의 다른 파일은 바꾸지 않았다.

## Decisions Made

- 회차 JSON 에 `options` (켠 후보 규칙 이름 · 언어 옵션 · sdk) 와 `projectBySeverity` 를 더했다. `fix` 단계는 다른 실행에서 돌 수 있어 메모리의 Shot 대신 결과 JSON 의 before 회차로 옵션을 되살리고 새 error 를 센다. Shot.toJson 의 `pluginVersion` 키는 회차 칸 이름에 맞춰 `plugin` 으로 바꿨다.
- `stripIgnores` 는 표식 폴더를 건드리지 않는다 (spike 023 은 `ignore_probe/` 를 함께 걷어냈다). 표식은 이 저장소의 샘플이고, 정답지 대조를 걷어낸 회차에서도 그대로 쓰기 위해서다.
- 프로젝트 값(`counts` · `ignored` · `countsUI`)은 `lib` · `test` · `bin` 자리만 센다. `newErrors` · `otherDelta` 는 표식이 아닌 진단 전부(생성 파일 · 옵션 파일 포함)로 센다 — apply 가 어디에 error 를 만들든 보이게.
- `severity` 는 그 규칙의 첫 진단(프로젝트 줄 먼저, 없으면 표식 줄)에서 읽는다. markers 단계는 아직 null 인 행의 강도를 표식 진단으로 채운다.
- 행에 `invalidRuns` 와 `incompatibleLintRuns` 칸을 더했다 — 무효 회차를 참조하는 행의 표시, G3 처럼 옵션 파일 줄에 붙은 `incompatible_lint` 의 근거.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] include 한 줄짜리 옵션 파일에서 `optionsWith` 가 멈춤**
- **Found during:** Task 2 (설계 시 확인)
- **Issue:** spike 의 `optionsWith` 는 `\n  rules:\n` 을 정확히 한 번 요구하는데 `example/analysis_options.yaml` 은 include 한 줄이라 smoke 가 시작조차 못 한다. 또 원본이 목록 형식이면 맵 항목을 끼우면 YAML 이 깨진다.
- **Fix:** `insertRules` · `insertLanguage` — `rules:` 가 한 번이면 그 블록의 형식으로 끼우고, `linter:` 가 아예 없으면 블록을 새로 붙이고, 그 밖의 모양은 `FormatException` (사용 프로젝트가 바뀌면 멈추는 성질은 유지).
- **Files modified:** `tool/measure_rules.dart`
- **Committed in:** `78c02cb`

**2. [Rule 2 - Missing Critical] 단계가 기대는 앞 회차가 없을 때의 거부**
- **Found during:** Task 2
- **Issue:** 계획은 단계를 따로 돌리게 했지만, 앞 회차(B0 · G<n>) 없이 `groups` · `ignore` · `fix` 를 돌리면 단계 중간에 예외로 끝난다.
- **Fix:** `checkStageInputs` — 인자 검증 때 결과 파일을 읽기만 해서 확인하고, 없으면 종료 코드 64 와 빠진 회차 목록.
- **Committed in:** `c8e873f`

**3. [Rule 1 - Bug 예방] `--work` 와 `--source` 가 서로의 안에 있는 경우를 거부**
- **Issue:** 작업 폴더가 원본 안이면 복사가 자기 자신을 다시 복사한다 (spike 022 도 막았다).
- **Fix:** 64 로 거부. **Committed in:** `78c02cb`

### 계획과 다르게 적은 값

- `use_primary_constructors` 의 `section` 은 `B-7` 이다. 계획은 `B-1` ~ `B-6` / `current` / `option` 으로 적었지만 이 이름은 FEATURES.md B-7 에만 있어, 출처를 그대로 적었다 (묶음은 `v2`, `deferredTo` RULES-10).
- `ruleProbes313` 은 계획대로 빈 맵이고 `ruleProbes` 는 셋뿐이다 (04-03 이 더한다).

### 실행이 끊긴 일

- Task 2 의 첫 smoke 도중 API 네트워크 오류로 이 에이전트의 실행이 한 번 끊겼다가 이어졌다. 편집은 끊기기 전에 모두 들어가 있었고(`git diff` 829줄, 루트 분석 · 포맷 깨끗) 반쯤 쓰다 만 함수는 없었다. 같은 시각의 네트워크 끊김이 smoke 의 한 회차를 무효로 만들었다 (아래 Issues) — 작업 폴더를 지우고 첫 검증 명령을 처음부터 다시 돌렸다.

---

**Total deviations:** 3 auto-fixed (Rule 3 하나, Rule 2 하나, Rule 1 하나) + 값 표기 1
**Impact on plan:** 범위는 계획 그대로다. 결과 JSON 에 칸 넷(`options` · `projectBySeverity` · `invalidRuns` · `incompatibleLintRuns`)이 더해졌다 — 04-03 의 `--summary` · `--report` 가 읽을 수 있다.

## Issues Encountered

- **첫 smoke 의 `G1-strip` 무효 (RG 1).** plugin 준비가 pub.dev 에 닿지 못했다 — 상태 폴더의 plugin `dart pub upgrade` 가 `Got socket error trying to find package riverpod_lint at https://pub.dev` 로 exit 69, 분석은 106.9초에 머리말과 함께 끝났고 표식 줄이 16 → 13 (plugin 3줄 빠짐). 도구는 계획대로 멈추지 않고 그 회차만 `valid: false`(정답지 줄이 표식에 다 없다, plugin 준비 실패 머리말)로 적은 뒤 종료 코드 1 을 냈다 — D4 의 실행 증거다. 같은 시각에 이 에이전트의 API 연결도 끊겼다. `pub.dev` 응답 200 을 확인하고 다시 돌린 실행은 모든 회차가 유효했다. 지문 단언은 이 실패에서도 깨지지 않았다 (저장소 쪽 원인 아님).
- 저장소 지문: GSD 상태 파일(`.planning/config.json` 수정 · `state.json` · `milestone.lock` · `research/.cache/`)이 처음부터 있었지만 smoke 동안 바뀌지 않아 전후 `git status` 가 같았다. GSD 상태 갱신은 smoke 가 모두 끝난 뒤에만 했다.
- `messages.yaml` 을 받지 못할 때의 fallback(spike 020 결과)은 실행으로 일으켜 보지 않았다 — 이번 실행은 모두 받았다.

## Known Stubs

| 파일 | 자리 | 이유 |
|------|------|------|
| `tool/measure_rules.dart` | `ruleProbes` (셋) · `ruleProbes313` (빈 맵) | 규칙별 표식 약 60개는 plan 04-03 이 더한다 (계획이 정한 범위) |
| `tool/measure_rules.dart` | `--summary` · `--report` · `--write` · `--audit` → `아직 구현되지 않았다` 와 64 | 출력 모드는 plan 04-03 이 구현한다 |

## User Setup Required

None - 외부 서비스 설정 없음. 실측에는 네트워크가 필요하다 (plugin 준비 · `messages.yaml`).

## Next Phase Readiness

- 04-03 이 표식 상수와 `--summary` · `--report` · `--audit` 를 더한다. 결과 JSON 의 모양(schema 1)은 이 SUMMARY 의 칸 그대로다.
- 04-04 (실측 R1) 는 `flutter_starter_kit` 의 원본을 `--source` 로 주고 `--work` 를 소유자가 다시 찾을 수 있는 저장소 밖 자리로 준다. 네트워크가 끊기면 회차가 무효로 표시되므로, 그 단계만 같은 run id 로 다시 돌리면 같은 id 의 회차가 바뀌어 쓰인다.

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*

## Self-Check: PASSED

- `tool/measure_rules.dart` 있음 (3073행)
- 커밋 `78c02cb` · `c8e873f` 모두 HEAD 의 조상
- `lib` · `example` · `fixtures` · `tool/verify.dart` · `RULES.md` · `CHANGELOG.md` 가 HEAD 와 같고 `tool/measurements/` 없음
