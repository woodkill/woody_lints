---
phase: 04-rule-reselection
plan: 03
subsystem: testing
tags: [dart-analyze, measurement, rule-selection, markers, report, audit]

requires:
  - phase: 04-rule-reselection
    provides: "04-02 — tool/measure_rules.dart (state 단계 · 복사본 단계 여섯 · 결과 JSON schema 1 · 회차 유효성)"
  - phase: spikes
    provides: "spike 021 oldSamples · newSyntaxSamples, spike 023 markers, spike 022 결과 JSON 의 0줄 후보 62개"
provides:
  - "규칙별 표식 — ruleProbes 73 · ruleProbes313 7 · noFileProbe 4 (이유와 함께), --rules @probes"
  - "--summary <묶음> — D-06 터미널 요약 (D-05 의 기계적 권고)"
  - "--report [--write] — RULES.md § 실측 기록 의 Markdown 과 단언 여섯 (RULES-03 · 04 · 05 의 자동 판정)"
  - "--audit — 후보 133 ∪ B-7 31 이 RULES.md 의 세 표에 있는지 (RULES-08 · DOCS-11 의 자동 판정)"
  - "b7Rules 상수 31개 (spike 020 결과 JSON 과 대조)"
affects: [04-04, 04-05, 04-06, 04-07, 04-08, 04-09]

actuals:
  tokens: 20160
  tasks: 2
  commits: 2
plan_head_before: be39223c735e4dec635409e98bc8e2d87c6effea
plan_head_after: d0ec40e9788928c530252da7fbdf859b7b5e5f7f

tech-stack:
  added: []
  patterns:
    - "표식 파일 하나에 언어 버전 주석(// @dart=3.11 · // @dart=2.19)을 두어, 규칙이 언어 버전으로 막히거나 그 문법이 error 인 자리를 피한다"
    - "출력 모드는 결과 JSON 의 건수 · 이름 · 회차 조건 칸만 읽는다 — 출력에 경로 · 메시지가 들어갈 자리가 없다"
    - "--report 는 단언을 모두 본 뒤 하나라도 어긋나면 stdout 을 비우고 RULES.md 를 건드리지 않는다"

key-files:
  created: []
  modified:
    - tool/measure_rules.dart

key-decisions:
  - "Dart 파일 하나로 어길 수 없는 규칙 넷을 noFileProbe 에 이유와 함께 둔다 — sort_pub_dependencies (pubspec), use_test_throws_matchers (package:test_api 의 fail()), require_trailing_commas (언어 버전 3.7 이상에서 돌지 않음), package_prefixed_library_names (tag 3.13.4 의 규칙 소스가 곧바로 return)"
  - "avoid_final_parameters 의 표식은 그 파일만 // @dart=3.11 로 둔다 — 언어 버전 3.13 에서는 이 규칙이 꺼지고 보통 매개변수의 final 이 error(extraneous_modifier) 다. 하한을 3.13 으로 올리면(RULES-10) 이 규칙은 돌지 않는다"
  - "avoid_type_to_string 은 x.runtimeType.toString() 에 걸리지 않았다 (dart:core 의 Type 이 toString 을 선언) — 표식은 Type 을 implements 한 클래스의 toString() 이다"
  - "G1 의 marker 실행에 G4 넷의 3.11 판 표식을 함께 넣어, 지금 하한에서 걸리는지를 행의 markerDetectedCurrent 에 적는다 (D-15 의 값 둘 가운데 지금 하한 쪽의 근거)"
  - "bundles 는 묶음 id → 한국어 이름 12개로 바꾸고, 하나씩 묻는 묶음의 규칙 표는 bundleRules 로 옮겼다 — current 묶음은 unawaited_futures 가 fire 로 가서 5행이다"
  - "dart fix 단계는 단독 dry 가 0 인 행의 newErrors 를 0 으로 적고(apply 하지 않았으니 새 error 도 없다), --report 의 단언 (2) 는 analyzer 옵션 행(strict-inference)에 fixRemoved · newErrors 를 묻지 않는다"

patterns-established:
  - "표식 상수의 이름은 시작할 때 후보인지 · 표식과 표식 불가가 겹치지 않는지 · 3.13 표식이 G4 인지 단언한다"
  - "출력 모드는 한 번에 하나, 단계용 인자(--source · --stage · --rules · --probe-all · --out)와 함께 주면 64"

requirements-completed: [RULES-03, RULES-04, RULES-05, RULES-08, DOCS-11]

coverage:
  - id: D1
    description: "규칙별 표식 — example/ 복사본의 groups,markers --rules @probes --probe-all 실행에서 표식이 있는 규칙 82개(지금 켠 6개 포함) 전부 markerDetected true, marker 회차 셋 모두 valid, spike 022 의 0줄 후보 가운데 표식도 표식 불가도 아닌 것 0"
    requirement: "RULES-05"
    verification:
      - kind: integration
        ref: "04-03-PLAN.md Task 1 <automated> (probes ok 82) — 두 번째 커밋 뒤에도 다시 돌려 rc 0"
        status: pass
    human_judgment: false
  - id: D2
    description: "--summary <묶음> — 머리 줄 · 표 · 굵은 권고 줄 · 선택지, 0줄 표기, bug 묶음 행 수 일치, v2 의 v2 (RULES- 12줄, 모르는 묶음과 JSON 없음은 64"
    requirement: "RULES-03"
    verification:
      - kind: integration
        ref: "04-03-PLAN.md Task 2 <automated> — rc 0"
        status: pass
    human_judgment: false
  - id: D3
    description: "--report 의 실패 경로 — 미완 JSON 에서 종료 코드 1 · stdout 비움 · stderr 의 값이 없는 행, --report --write 뒤 RULES.md hash 그대로"
    requirement: "RULES-05"
    verification:
      - kind: integration
        ref: "04-03-PLAN.md Task 2 <automated> — rc 0"
        status: pass
    human_judgment: false
  - id: D4
    description: "--report 의 통과 경로와 --write 의 바꿔 쓰기 (회차 표 · 평가표 133행 · 마커 유지 · 두 번 써도 같음)"
    requirement: "RULES-04"
    verification:
      - kind: other
        ref: "저장소 밖 하네스 — smoke JSON 의 빈 칸을 채운 합성 JSON 으로 --report (rc 0, 평가표 133행), RULES.md 사본에 writeReport 두 번"
        status: pass
    human_judgment: true
    rationale: "실제 사용 프로젝트의 데이터로 쓰는 경로는 계획대로 04-09 가 확인한다 — 여기서는 합성 데이터와 사본에서만 돌렸다"
  - id: D5
    description: "--audit — 04-01 뼈대의 RULES.md 에서 종료 코드 1 과 RULES.md 에 없는 후보 158개 · 빈 칸이 있는 켠 규칙 6개"
    requirement: "RULES-08"
    verification:
      - kind: integration
        ref: "04-03-PLAN.md Task 2 <automated> — rc 0"
        status: pass
      - kind: other
        ref: "저장소 밖 하네스 — 모든 후보를 채운 RULES.md 사본에서 감사 통과 (보류 1, 종료 코드 0), 이유 접두사 · 두 번 · 켜진 B-7 을 넣은 사본에서 셋 다 잡고 1"
        status: pass
    human_judgment: false
  - id: D6
    description: "세 모드의 출력에 절대 경로 꼴이 없고 저장소 git status 전후 같음, tool/measurements/ 없음 (D-07)"
    requirement: "DOCS-11"
    verification:
      - kind: integration
        ref: "04-03-PLAN.md Task 1 · Task 2 <automated> 의 git status · grep 단언"
        status: pass
    human_judgment: false

duration: 27min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 03: 규칙별 표식과 실측 도구의 출력 모드 Summary

**0줄을 해석할 규칙별 표식 80개(3.11 판 73 · 3.13 판 7)와 표식 불가 4개를 `example/` 복사본에서 전부 검출되게 갖추고, 소유자 검토용 `--summary`, `RULES.md` 실측 기록을 단언과 함께 만드는 `--report [--write]`, 후보 164개가 `RULES.md` 에 있는지 세는 `--audit` 을 더했다**

## Performance

- **Duration:** 약 27분
- **Started:** 2026-10-13T00:28Z
- **Completed:** 2026-10-13T00:55Z
- **Tasks:** 2
- **Files modified:** 1 (`tool/measure_rules.dart`, 3073행 → 4903행)

## Accomplishments

- **표식 수:** `ruleProbes` 73 · `ruleProbes313` 7 · `noFileProbe` 4. `--rules @probes` 는 둘의 이름 합 76 이다. 결과 JSON 의 `hasProbe` 행은 82 (지금 켠 6개는 `example/lib/added_rules.dart` 가 표식).
- 범위: spike 022 의 0줄 후보 62개 가운데 표식 불가 둘(`use_test_throws_matchers`, `require_trailing_commas`)을 뺀 60개 전부, 021 · 023 의 나머지(`empty_container_bodies` · `unnecessary_type_name_in_constructor` · `unnecessary_const_in_enum_constructor` · `use_primary_constructors` · `discarded_futures` · `lines_longer_than_80_chars` · `cast_nullable_to_non_nullable` · `unnecessary_ignore`, `strict-inference`), B-6 의 7개 가운데 여섯(`package_prefixed_library_names` 는 표식 불가).
- G4 의 7개는 `ruleProbes313` 에 (primary constructor 문법 셋 + 3.11 문법으로도 쓰이는 넷), 넷의 3.11 판은 `ruleProbes` 에 같은 상수로 둔다 (DRY). G1 의 marker 실행이 3.11 판을 넣어 `markerDetectedCurrent` 를 적는다.
- markers 단계는 `표식 불가 (<이유>)` 를 `표식 없음` 과 따로 알리고 `conditions.noFileProbe` 에 이름 목록을 적는다.
- `--summary <묶음>`: 머리 줄 `[<이름>] N개 — 권고: 켬 · 안 켬 · 검토 · 결정 안 함 … 실측 <run id> (날짜, Flutter, flutter_starter_kit Dart 파일 K개)`, 열 너비를 맞춘 표, `**권고:**` 줄, 선택지 한 줄. 25행이 넘는 묶음(style 41 · excluded 31)은 "dart fix 가 다 고치는 것 / 손으로 고칠 줄 50 이하 / 그 밖" 셋으로 나눈다. perf · style 머리 줄에 `(50 은 추정)`.
- `--report`: 단언 (1) 행 133 = 후보, (2) 결정 대상 121 행의 빈 칸(0줄이면 `markerDetected`, 표식 불가는 예외로 목록에), (3) strict 셋의 행과 `strict-inference` 의 warning, (4) G4 7개의 `counts313`, (5) 참조 회차의 존재와 유효, (6) 회차 조건 일곱 칸. 통과하면 회차 표(첫 칸은 평문 `R1-B0` 꼴) · 상태 출처 · 비호환 쌍 줄 · 평가표(첫 칸만 backtick 이름) · 끝의 두 줄.
- `--audit`: 켠 규칙 · 켠 옵션 · 켜지 않은 규칙 세 구역을 `tool/verify.dart` 의 `readRulesMdBlock` 과 같은 규약으로 읽어 판정 (a) ~ (e). 지금의 `RULES.md` 에서는 `RULES.md 에 없는 후보 158개` 와 `빈 칸이 있는 켠 규칙 6개` 로 종료 코드 1.

## Task Commits

1. **Task 1: 규칙별 표식 상수와 example/ 복사본에서의 검출 확인** — `2fa9767` (feat)
2. **Task 2: 출력 모드 --summary · --report [--write] · --audit** — `d0ec40e` (feat)

**Plan metadata:** SUMMARY 커밋과 마무리 커밋 (docs)

## 검증 명령 결과

- Task 1 `<automated>`: rc 0 (`probes ok 82`). 작업 폴더 `${TMPDIR:-/tmp}/woody_measure_smoke_03`, 회차 B0 · B0-313 · G1 · G2 · G4 · G1-marker · G2-marker · G4-marker 모두 유효, 결과 JSON 의 `"message"` 0번, 저장소 `git status` 전후 같음.
- Task 2 `<automated>`: rc 0 — RZ 64 · RN 64 · RB 0, bug 묶음 25행, v2 의 `v2 (RULES-` 12줄, `--report` 1 · stdout 비움 · `값이 없는 행`, `--report --write` 1 · `RULES.md` hash 그대로, `--audit` 1 · `RULES.md 에 없는 후보 158개`.
- 두 번째 커밋 뒤 두 명령을 차례로 다시 돌려 둘 다 rc 0.
- 추가로 돌린 것: 모르는 묶음 외의 사용법 오류(`--write` 단독, `--summary` 와 `--stage`, 출력 모드 둘, `--audit --in`) 모두 64, `schema: 2` JSON 70, 무효 회차를 참조한 행은 `회차 무효` 와 `결정 안 함`. 통과 경로는 저장소 밖 하네스에서 합성 JSON 과 `RULES.md` 사본으로만 확인했다 (coverage D4 · D5).
- 각 커밋 전 루트 `fvm dart analyze` `No issues found!`, `fvm dart format --set-exit-if-changed tool` 0.

## Files Created/Modified

- `tool/measure_rules.dart` — 표식 상수 셋, markers 단계의 표식 불가 · 지금 하한 표식, 출력 모드 셋과 그 도움 함수, `b7Rules`, `bundles` (id → 이름) / `bundleRules`. 저장소 안의 다른 파일은 바꾸지 않았다.

## Decisions Made

- **표식 불가 넷** — `sort_pub_dependencies` (pubspec 을 본다), `use_test_throws_matchers` (규칙 소스가 `package:test_api/src/frontend/expect.dart` 의 `fail` 을 찾는다 — 복사본이 `flutter_test` 를 import 하지 않는 `lib/` 의 파일로는 어길 수 없다), `require_trailing_commas` (규칙 소스가 언어 버전 3.7 이상이면 돌지 않는다 — 계획의 검증 명령은 표식이 있는 규칙 전부의 검출을 요구하므로 미검출 표식을 둘 수 없다; 0줄은 `0 (표식 불가)` 와 `결정 안 함` 으로 나온다), `package_prefixed_library_names` (tag 3.13.4 의 규칙 소스가 `visitLibraryDirective` 에서 곧바로 return 한다 — dart-lang/linter#3395).
- **언어 버전 주석이 있는 표식 둘** — `avoid_final_parameters` 는 `// @dart=3.11` (3.13 에서는 규칙이 꺼지고 그 문법이 error), `prefer_mixin` 은 `// @dart=2.19` (3.0 이상에서 class 를 with 로 섞는 것이 error `class_used_as_mixin`). 둘 다 표식 파일 안에서만 쓰는 장치이고, D-10 샘플로 옮길 때 다시 본다.
- `remove_deprecations_in_breaking_versions` 는 사용 프로젝트 `pubspec.yaml` 의 `version` 이 x.0.0 / 0.x.0 일 때만 돈다 (규칙 소스). `example/` (0.0.0) 에서는 걸렸다 — 04-04 에서 걸리지 않으면 그 0줄은 "규칙이 돌지 않음" 이다 (표식이 그 뜻을 가른다).
- `bundles` 를 묶음 id → 한국어 이름으로 바꿨다 (04-05 가 이 상수의 id 를 쓴다). `current` 묶음의 이름은 계획대로 `지금 켜 둔 5개` — `unawaited_futures` 가 `fire` 묶음에서 따로 물어진다.
- 권고 잣대 앞에 두 칸을 더했다 — 값이 없는 행(`결정 안 함 · 값이 없다 — 재지 않음`), 무효 회차를 참조한 행(`결정 안 함 · 회차 무효 — <id>`). `dart fix` 칸은 0줄이면 `해당 없음`, 줄이 있는데 fix 단계를 안 돌았으면 `재지 않음`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] dart fix 단계가 단독 dry 0 인 행의 `newErrors` 를 null 로 남김**
- **Found during:** Task 2 (`--report` 단언 (2) 설계)
- **Issue:** 단언 (2) 는 줄이 있는 행에 `newErrors` 를 요구하는데, 04-02 의 `measureFix` 는 dry 0 인 행에 null 을 적어 실제 실측(04-04)에서 단언이 늘 실패하게 되어 있었다.
- **Fix:** dry 0 이면 `newErrors` 0 (apply 하지 않았으니 새 error 도 없다).
- **Committed in:** `d0ec40e`

**2. [Rule 1 - Bug] analyzer 옵션 행은 fix 단계가 돌지 않아 단언 (2) 를 넘을 수 없음**
- **Issue:** `measureFix` 는 `strict-inference` (옵션) 를 건너뛴다 — 줄이 있으면 `fixRemoved` · `newErrors` 가 영영 null 이다.
- **Fix:** 단언 (2) 에서 옵션 행에는 두 칸을 묻지 않고, 표의 `dart fix` 칸은 `해당 없음`.
- **Committed in:** `d0ec40e`

**3. [Rule 3 - Blocking] `avoid_final_parameters` · `avoid_type_to_string` 의 첫 표식이 걸리지 않음** — 아래 Issues.

### 계획과 다르게 적은 것

- `bundles` 를 id → 이름으로 바꾸면서 04-02 의 규칙 표는 `bundleRules` 로 이름을 바꿨다 (계획은 이름표를 `bundles` 에 두라고만 했다).
- `markerDetectedCurrent` 행 칸 하나를 더했다 (schema 는 1 그대로 — 행 칸은 `putIfAbsent` 로 채워진다). 계획이 `ruleProbes` 에 두라고 한 G4 넷의 3.11 판을 쓰는 자리다.
- 023 `markers` 의 `lines_longer_than_80_chars_ignored` (파일 맨 위 `// ignore_for_file:`) 는 계획의 "맨 위 `// ignore_for_file:` 을 쓰지 않는다" 를 따라 옮기지 않았다. `discarded_futures` 의 줄 단위 무시 주석 판은 그대로 옮겼다.
- 선택지는 계획의 action 대로 한 줄(`선택지: (1) … (2) … (3) …`)이다.

---

**Total deviations:** 3 auto-fixed (Rule 1 둘, Rule 3 하나) + 값 표기 4
**Impact on plan:** 범위는 계획 그대로다. 1 · 2 가 없으면 04-09 의 `--report` 가 실제 데이터에서 늘 실패했을 것이다.

## Issues Encountered

- **처음 쓴 표식 가운데 둘이 걸리지 않았다** (첫 marker 실행, 표식이 있는 규칙 82개 중 80개 검출) — 고친 표식의 이름: `avoid_final_parameters`, `avoid_type_to_string`.
  - `avoid_final_parameters`: `example/` 의 하한이 `^3.13.0` 이라 규칙이 꺼져 있었고(`Feature.primary_constructors`), 표식 줄에 `extraneous_modifier` error 가 났다 → 파일만 `// @dart=3.11`.
  - `avoid_type_to_string`: tag 3.13.4 의 SDK 에서 `x.runtimeType.toString()` 은 `Type.toString` 으로 풀려 규칙이 보는 `Object.toString` 이 아니다 (상류 테스트는 mock SDK 에서 이것을 lint 로 본다). 변형 넷을 한 번에 넣어 잰 결과 `Type` 을 implements 한 클래스의 `toString()` 만 걸렸다 → 그 하나로 줄였다.
  - 그 밖의 표식 78개는 첫 실행에서 걸렸다. marker 실행 셋의 표식 줄에 error 는 0이다.
- 네트워크 오류로 무효가 된 회차는 없었다.
- 규칙 소스는 tag 3.13.4 의 `pkg/linter/lib/src/rules/` 에서 저장소 밖 임시 폴더로 받아 읽었다 (Context7 은 쓰지 않았다).

## Known Stubs

None — 04-02 가 남긴 두 stub (`ruleProbes` 셋 · `ruleProbes313` 빈 맵, 출력 모드의 `아직 구현되지 않았다`) 을 이 plan 이 채웠다.

## User Setup Required

None - 외부 서비스 설정 없음. 실측과 표식 확인에는 네트워크가 필요하다 (plugin 준비).

## Next Phase Readiness

- 04-04 (실측 R1) 는 `--stage all` 로 돈다 — markers 단계가 0줄 후보에 표식을 넣는다. 실측 뒤 `--summary <묶음> --work <작업 폴더>` 또는 `--in` 으로 04-05 의 checkpoint 요약을 바로 찍을 수 있다.
- 04-09 는 `--report --write` 의 쓰는 경로를 실제 데이터로 처음 돈다. 단언 (2) 가 어긋나면 stderr 에 행 이름과 빠진 칸의 수가 나온다.
- `--audit` 은 04-06 ~ 04-08 이 `RULES.md` 를 채운 뒤 통과해야 한다 (지금은 158개 빠짐 · 빈 칸 6).

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*

## Self-Check: PASSED

- `tool/measure_rules.dart` 있음 (4903행)
- 커밋 `2fa9767` · `d0ec40e` 모두 HEAD 의 조상
- `lib` · `example` · `fixtures` · `tool/verify.dart` · `RULES.md` · `CHANGELOG.md` 가 HEAD 와 같고 `tool/measurements/` 없음
- 두 task 의 `<automated>` 를 두 번째 커밋 뒤에 다시 돌려 둘 다 rc 0
