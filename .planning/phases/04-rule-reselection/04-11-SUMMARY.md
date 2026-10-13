---
phase: 04-rule-reselection
plan: 11
subsystem: tooling
tags: [dart, measure_rules, verify, gap-closure, sort_pub_dependencies]

requires:
  - phase: 04-rule-reselection
    provides: "R1 결과 JSON (bcc8c91), RULES.md 실측 기록 (3238ab0), tool/measure_rules.dart (cb040e5), tool/verify.dart (2956e2a)"
provides:
  - "측정 도구의 값 자리 valueAreas (lib · test · bin · pubspec.yaml) 와 --report 단언 (7)"
  - "--recount [--write] 출력 모드 — 회차를 그대로 두고 행을 다시 센다"
  - "R1 JSON 의 sort_pub_dependencies 행 2 (0·0·0·2) · fixSkipped, conditions.recount"
  - "RULES.md 실측 기록 재생성 (실측 (lib·test·bin·pubspec), 부호째 찍는 가린 줄, 각주 둘)"
  - "[3/10] 의 declaredRuleNames 가 열 0 주석 뒤의 규칙도 읽음 (CR-02)"
  - "상류 YAML 0규칙 guard — 두 도구가 FormatException (WR-06)"
  - "example/README.md 04-11 소절 (M26, WR-06 함수 단위 확인)"
affects: [04-12, phase-05]

actuals:
  tokens: 58893
  tasks: 2
  commits: 2
plan_head_before: 268b823a76a155b016f7de7d606d9ccd09344bac
plan_head_after: c06d8d531f0c963ce4fc1c46eb96ffbdaad2392b

tech-stack:
  added: []
  patterns:
    - "파생값(행)은 원자료(회차의 countByAreaCode)에서 --recount 로 다시 센다 — 비공개 프로젝트를 다시 돌리지 않는다"
    - "재지 않은 값은 수로 지어내지 않고 사유 칸(fixSkipped)과 표의 재지 않음 · 각주로 적는다"

key-files:
  created: []
  modified:
    - tool/measure_rules.dart
    - tool/measurements/2026-10-13-R1.json
    - RULES.md
    - tool/verify.dart
    - example/README.md

key-decisions:
  - "04-11: 측정 도구의 값 자리는 valueAreas (lib · test · bin · pubspec.yaml) 넷이다 — projectAreas 셋은 Dart 파일 수 · 표식 · 무시 주석 걷기에만 쓴다. --report 단언 (7) 이 값 밖 자리(marker · generated 제외)의 같은 규칙 코드를 잡는다"
  - "04-11: R1 의 행은 --recount 로 커밋된 회차에서 다시 셌다 — 바뀐 행은 sort_pub_dependencies 하나 (0·0·0·0 → 0·0·0·2), runs 는 그대로, dart fix 칸은 재지 않음 (fixSkipped). --summary style 의 도구 판정은 켬 · 손으로 고칠 줄 2 (≤ 50)"
  - "04-11: [3/10] 의 declaredRuleNames 는 주석 · 빈 줄을 건너뛴다 (CR-02, M26 이 [3/10] 만으로 실패). 상류 YAML 에서 규칙 0개면 tool/verify.dart · tool/measure_rules.dart 둘 다 FormatException (WR-06)"

patterns-established:
  - "출력 모드의 --write 는 --report (RULES.md) 와 --recount (결과 JSON) 에만 붙는다"
  - "음수가 될 수 있는 자리별 칸은 countCell 이 부호째 찍는다"

requirements-completed: [RULES-01, RULES-03, RULES-05, RULES-06, RULES-08]

coverage:
  - id: D1
    description: "측정 도구가 pubspec.yaml 자리의 진단을 값에 넣고(valueAreas), R1 의 sort_pub_dependencies 가 --recount 로 2 (0·0·0·2) · fixSkipped 로 다시 세어졌으며, runs · 다른 행 · 다른 칸은 bcc8c91 과 같다"
    requirement: RULES-03
    verification:
      - kind: other
        ref: "04-11-PLAN.md Task 1 <automated> (jq 단언 · bcc8c91 과의 jq -S diff · --recount 재실행 '바뀐 행이 없다')"
        status: pass
    human_judgment: false
  - id: D2
    description: "--report 단언 (7) 이 값에 넣지 않은 자리의 진단을 잡는다 — 변형 JSON(G1 · G1-strip 의 pubspec.yaml 자리를 analysis_options.yaml 로 옮김)에서 종료 코드 1 · '행 1개: sort_pub_dependencies (analysis_options.yaml)'"
    requirement: RULES-05
    verification:
      - kind: other
        ref: "04-11-PLAN.md Task 1 <automated> 의 T7 변형 JSON 구간"
        status: pass
    human_judgment: false
  - id: D3
    description: "RULES.md 실측 기록이 --report --write 로 다시 만들어졌다 — sort_pub_dependencies 2 (0·0·0·2) · 재지 않음, 가린 줄 -48 (-1·-46·-1·0) · -12 (-1·-10·-1·0), 각주 셋, 마커 밖은 3238ab0 과 같음"
    requirement: RULES-08
    verification:
      - kind: other
        ref: "04-11-PLAN.md Task 1 <automated> (--report 출력 == 마커 사이, 마커 밖 diff 0)"
        status: pass
    human_judgment: false
  - id: D4
    description: "--summary style 이 sort_pub_dependencies 를 켬 · '손으로 고칠 줄 2 (≤ 50) — dart fix 는 재지 않음' 으로 판정, 머리 줄 '켬 40 · 안 켬 0 · 검토 0 · 결정 안 함 1'"
    requirement: RULES-03
    verification:
      - kind: other
        ref: "fvm dart run tool/measure_rules.dart --summary style --in tool/measurements/2026-10-13-R1.json (Task 1 <automated>)"
        status: pass
    human_judgment: false
  - id: D5
    description: "[3/10] 이 열 0 주석 뒤의 규칙을 읽는다 — M26 입력에서 [3/10] 만 실패, 겹침 1 · + avoid_print · + prefer_mixin, 점검 실패 (10개 중 1개), 종료 코드 1"
    requirement: RULES-06
    verification:
      - kind: integration
        ref: "04-11-PLAN.md Task 2 <automated> (M26 perl 변경 → fvm dart run tool/verify.dart → 되돌림)"
        status: pass
    human_judgment: false
  - id: D6
    description: "기반 세트 YAML 에서 규칙 0개면 readUpstreamRules · readUpstreamSets 가 FormatException — 탐침에서 control verify 2 measure 2, 들여쓰기 2칸에서 두 FormatException"
    requirement: RULES-01
    verification:
      - kind: unit
        ref: "04-11-PLAN.md Task 2 <automated> 의 .dart_tool/woody_gap_probe/probe.dart 구간"
        status: pass
    human_judgment: false
  - id: D7
    description: "example/README.md 04-11 소절(M26 행, WR-06 불릿, 종료 코드 70 행 · [3/10] 설명 보강)의 문장이 실제 실행 결과를 옳게 옮겼는가"
    requirement: RULES-06
    verification:
      - kind: other
        ref: "04-11-PLAN.md Task 2 <automated> 의 README grep 단언"
        status: pass
    human_judgment: true
    rationale: "grep 은 문구의 존재만 본다 — '고치기 전에는 열 단계를 모두 통과했다' 는 04-VERIFICATION.md 의 재현을 옮긴 것이고, 검증 명령 전체의 종료 코드 70 경로는 코드에서 읽은 것이라 사람이 읽고 확인한다"

duration: 9min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 11: 측정 도구 · 검증 도구 gap 수정 Summary

**측정 도구가 `pubspec.yaml` 자리를 규칙의 값에 넣고(`valueAreas`, 단언 (7)), 커밋된 R1 회차에서 `--recount` 로 `sort_pub_dependencies` 를 0 → 2 (0·0·0·2) · `dart fix` 재지 않음으로 다시 세어 `RULES.md` 실측 기록을 다시 만들었으며, `[3/10]` 이 열 0 주석 뒤의 규칙을 읽고 상류 YAML 0규칙에서 두 도구가 멈춘다 — 비공개 프로젝트는 돌리지 않았다**

## Performance

- **Duration:** 9 min
- **Started:** 2026-10-13T08:21:41Z
- **Completed:** 2026-10-13T08:31:07Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- gap 1 (CR-01) 의 missing 1 · 2 를 닫았다 — `tool/measure_rules.dart` 에 `pubspecArea` · `valueAreas` 를 두고 값 계산(`ruleCounts` · `subtractCounts` · `total` · `ruleCodesIn` · `countsUI` · `areaTriple`)을 넷째 자리로 넓혔고, `--report` 단언 (7) 이 같은 꼴의 누락을 잡는다.
- `--recount [--write]` 로 R1 JSON 의 행을 다시 셌다. 화면(쓰지 않는 첫 실행):
  - `sort_pub_dependencies: counts 0·0·0·0 → 0·0·0·2 · fixSkipped 적음`
  - `다시 센 행 133개 — 바뀐 행 1개`
  - `--write` 뒤의 재실행은 `다시 센 행 133개 — 바뀐 행이 없다`. `conditions.recount` = `{date: 2026-10-13, changedRows: [sort_pub_dependencies]}`. JSON 의 다른 변화는 값 칸에 `pubspec.yaml: 0` 키가 더해진 것뿐이다 (`runs` · 다른 칸 · 다른 행의 값은 `bcc8c91` 과 `jq -S` diff 0).
- `RULES.md` 실측 기록을 `--report --write` 로 다시 만들었다. `sort_pub_dependencies` 행:
  `` | `sort_pub_dependencies` | 가독성·스타일 | stable (messages.yaml) | info | 2 (0·0·0·2) | — | 재지 않음 | — | 0 | — | — | R1-G1, R1-G1-strip | `` (칸 맞춤 공백은 줄였다). 가린 줄은 부호째 `document_ignores -48 (-1·-46·-1·0)`, `unnecessary_ignore -12 (-1·-10·-1·0)` (WR-02). 각주에 `dart fix 를 재지 않은 행: sort_pub_dependencies — …` 와 `가린 줄이 음수인 행은 …: document_ignores -48, unnecessary_ignore -12` 가 더해졌고, `표식을 둘 수 없어 …` 각주에서 `sort_pub_dependencies` 가 빠졌다 (세 이름).
- `--summary style` 의 `sort_pub_dependencies` 는 `켬 · 손으로 고칠 줄 2 (≤ 50) — dart fix 는 재지 않음`, 머리 줄 `권고: 켬 40 · 안 켬 0 · 검토 0 · 결정 안 함 1`. `--audit` 은 `감사 통과 — 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0` 그대로 (규칙을 켜는 일은 04-12).
- gap 2 (CR-02) 를 닫았다 — `tool/verify.dart` 의 `declaredRuleNames` 가 주석 · 빈 줄을 건너뛴다. M26 을 실제로 돌린 결과: 종료 코드 1, `[3/10] 배포 파일의 구성 … 실패` 만(`[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 통과), 찍힌 규칙 이름은 겹침 `avoid_print  (flutter_lints-6.0.0 flutter.yaml)` 과 `+ avoid_print  (base.yaml 에만)` · `+ prefer_mixin  (base.yaml 에만)`, 요약 `점검 실패 (10개 중 1개)`, 23초. 되돌린 뒤 보통 실행 21초 · `점검 통과 (10개 중 10개)`.
- WR-06 을 두 도구 모두에서 막았다. 탐침의 두 결과 — 들여쓰기 4칸: `control verify 2 measure 2`; 2칸: `verify FormatException lints core.yaml 에서 규칙을 하나도 읽지 못했다 — 상류 YAML 의 형식이 바뀌었다 (04-REVIEW.md WR-06)`, `measure FormatException core.yaml 에서 규칙을 하나도 읽지 못했다 — …`. 탐침 폴더는 지웠다.
- `example/README.md` 에 04-11 소절(M26 행, WR-06 불릿)을 더하고 종료 코드 표 70 행과 `[3/10]` 설명을 보강했다.

## Task Commits

1. **Task 1: valueAreas · 단언 (7) · fixSkipped · 부호째 찍는 가린 줄 · --recount — R1 행 재계산, RULES.md 재생성 (tracer)** - `b567100` (fix)
2. **Task 2: [3/10] 열 0 주석(CR-02) · 상류 YAML 0규칙 guard(WR-06) — README M26** - `c06d8d5` (fix)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP · REQUIREMENTS 의 커밋 (docs)

## 검증 명령 (`<automated>`) 실행 기록

| Task | 실행 시점 | 적힌 그대로 rc |
|------|-----------|----------------|
| 1 | 커밋 전 | 0 |
| 1 | 커밋 `b567100` 직후 (tracer 재확인) | 0 |
| 1 | 마지막 HEAD `c06d8d5` | 0 |
| 2 | 커밋 `c06d8d5` 직후 (계획대로) | 0 |

두 명령 모두 PLAN 에서 그대로 뽑아 저장소 루트에서 `bash` 로 돌렸다. 고친 판은 필요 없었다.

## Files Created/Modified

- `tool/measure_rules.dart` - `pubspecArea` · `valueAreas`, `--recount` 모드(`recountRows` · `runRecount` · `repoRelative`), 단언 (7), `fixSkipped` 처리(`fixCell` · `recommend` · 단언 (2) · 각주), 부호째 `countCell`, `areaTriple` 의 `areas` 매개변수, 헤더 둘, `noFileProbe` 문구, `readUpstreamSets` 의 0규칙 guard
- `tool/measurements/2026-10-13-R1.json` - 행 값 칸의 `pubspec.yaml` 키, `sort_pub_dependencies` 의 `pubspec.yaml: 2` · `fixSkipped`, `conditions.recount`
- `RULES.md` - `woody:measurements` 구역 재생성 (마커 밖은 그대로)
- `tool/verify.dart` - `declaredRuleNames` 의 주석 · 빈 줄 건너뛰기, `readUpstreamRules` 의 0규칙 guard
- `example/README.md` - 04-11 소절 (M26, WR-06), 종료 코드 70 행, `[3/10]` 설명

## Decisions Made

- `recountRows` 는 값 칸(`counts` · `counts313` · `ignored`)을 모든 행에 다시 쓰되(`pubspec.yaml` 키를 더하기 위해), 바뀐 행은 값이 달라진 행만 센다 — 0 키를 더한 것은 바뀐 것으로 세지 않는다.
- 단언 (7) 의 문구는 규칙마다 한 번, 자리가 여럿이면 괄호 안에 쉼표로 잇는다 (N 은 행의 수).
- `--recount --write` 의 안내는 저장소 상대 경로로 찍고, 저장소 밖 파일이면 파일 이름만 찍는다 (D-07).

## Deviations from Plan

None - plan executed exactly as written.

계획의 문구 밖에서 정한 작은 것 둘은 결정이지 deviation 이 아니다: (1) `--recount` 의 끝 줄은 바뀐 행이 없을 때 `다시 센 행 133개 — 바뀐 행이 없다` 로 한 줄에 합쳤다 (계획의 두 문구를 함께 담음). (2) `example/README.md` 의 WR-06 불릿에서 "검증 명령에서는 종료 코드 70 … 로 끝난다" 뒤에 "(코드에서 읽은 경로다 — 위 까닭으로 검증 명령 전체로는 돌려 보지 못했다)" 를 덧붙였다 — `main` 의 `FormatException` 처리(종료 코드 70)와 `checkShippedComposition` 에 지역 catch 가 없음을 코드로 확인했지만, 실행으로 본 것은 함수 단위 탐침뿐이라서다.

## Issues Encountered

None.

## 이 plan 이 다루지 않은 것

- `04-REVIEW.md` 의 다른 지적 — CR-03 은 04-12 가 v2 메모로 다룬다. WR-01 · WR-03 · WR-04 · WR-07 · WR-08 · IN-01 ~ IN-07 은 이 plan 이 다루지 않았고 `open` 으로 남는다.
- `sort_pub_dependencies` 를 켜는 일(배포 파일 · 샘플 · 정답지 · `RULES.md` 켠 규칙 표 · `CHANGELOG.md`)은 04-12 의 일이다. 이 plan 은 `lib/` · 샘플 · 정답지 · `CHANGELOG.md` 를 바꾸지 않았다 (`944ca1c` · `3238ab0` · `ac5cced` 와 `git diff --quiet`).
- 비공개 사용 프로젝트는 돌리지 않았다 — 측정 도구의 단계(`--stage`)를 돌리지 않고 출력 모드만 썼다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 04-12 가 이 경로 위에서 소유자의 재결정(`sort_pub_dependencies` 켬)을 배포 파일과 문서에 반영할 수 있다 — 실측 기록과 `--summary` 판정이 이미 2줄 · 켬 이다.
- 이 plan 의 상태 고정 단언(`--audit` 의 켠 80 · 켜지 않음 91, 고정 커밋과의 `git diff --quiet`, `RULES.md` 마커 밖 == `3238ab0`)은 04-12 뒤에는 거짓이 된다 — 뒤의 감사는 task 커밋(`b567100` · `c06d8d5`)으로 되돌린 복제본에서 재실행한다.

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*
