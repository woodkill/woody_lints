---
phase: 04-rule-reselection
plan: 12
subsystem: lint-config
tags: [analysis_options, sort_pub_dependencies, golden, changelog, gap-closure]

requires:
  - phase: 04-rule-reselection
    provides: "04-11 의 측정 도구 수정과 R1 재계산 (b567100 — sort_pub_dependencies 2 (0·0·0·2) · 재지 않음), [3/10] 의 열 0 주석 처리 (c06d8d5)"
provides:
  - "lib/base.yaml 규칙 81개 — sort_pub_dependencies 를 사유 주석과 함께 켬"
  - "RULES.md 켠 규칙 표 81행 · 켜지 않은 규칙 표 90행 (틀린 0 을 근거로 한 행 삭제)"
  - "연습용 프로젝트 여섯의 pubspec.yaml 샘플과 정답지 다섯의 pubspec.yaml:11  info  sort_pub_dependencies"
  - "CHANGELOG 2.0.0 의 추가한 규칙 75 · 새로 생기는 경고 75 · 각주 · 도구 수정 불릿"
  - "04-DECISIONS.md 결정 표의 재결정 행 (켬 81 · 안 켬 38) 과 메모"
  - "example/README.md 의 파일 표 · 줄 수 (WR-05)"
  - "CR-03 의 v2 메모 (REQUIREMENTS.md RULES-13 아래) 와 처리 기록 deferred"
affects: [phase-05, phase-06]

actuals:
  tokens: 67155
  tasks: 3
  commits: 3
plan_head_before: 548e3e18ddde972e431d05a593af8dda5bab04f1
plan_head_after: 9eb8ee5e708fa7926b7e440954aa8549504a9229

tech-stack:
  added: []
  patterns:
    - "Dart 파일로 어길 수 없는 규칙의 샘플은 연습용 프로젝트의 pubspec.yaml 에 둔다 — 정답지에 pubspec.yaml:줄 형식으로 남는다"
    - "README 의 줄 수는 정답지에서 다시 세어 쓰고, 파일 표 줄 수 칸의 합계가 정답지 진단 줄 수와 같아야 한다"

key-files:
  created: []
  modified:
    - lib/base.yaml
    - RULES.md
    - example/pubspec.yaml
    - fixtures/recommended/pubspec.yaml
    - fixtures/base_only/pubspec.yaml
    - fixtures/base_riverpod/pubspec.yaml
    - fixtures/base_codegen/pubspec.yaml
    - fixtures/overrides/pubspec.yaml
    - example/expected_diagnostics.txt
    - fixtures/base_only/expected_diagnostics.txt
    - fixtures/base_riverpod/expected_diagnostics.txt
    - fixtures/base_codegen/expected_diagnostics.txt
    - fixtures/overrides/expected_diagnostics.txt
    - CHANGELOG.md
    - .planning/phases/04-rule-reselection/04-DECISIONS.md
    - example/README.md
    - .planning/REQUIREMENTS.md
    - .planning/phases/04-rule-reselection/04-REVIEW-DISPOSITION.md

key-decisions:
  - "04-12: sort_pub_dependencies 를 켰다 (소유자 재결정 2026-10-13 의 반영, 6d64bee) — lib/base.yaml 81개 == RULES.md 켠 규칙 81 == 결정 표 켬 81, --audit 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0"
  - "04-12: 샘플은 연습용 프로젝트 여섯의 pubspec.yaml 에서 dependencies 의 flutter_riverpod 를 flutter 앞에 둔 것이고 정답지 다섯에 pubspec.yaml:11  info  sort_pub_dependencies 한 줄씩 생겼다 (exit 줄 · 다른 줄 · pubspec.lock 그대로). example/pubspec.yaml 만 되돌리면 [5/10] · [6/10] 이 실패한다"
  - "04-12: CR-03 은 코드를 고치지 않고 REQUIREMENTS.md RULES-13 아래 메모와 처리 기록 deferred 로 남겼다 (소유자 결정 2026-10-13)"

patterns-established:
  - "Dart 파일 밖 규칙의 샘플: pubspec.yaml 의 항목 순서처럼 lock 에 영향이 없는 변경으로 어긴다"

requirements-completed: [RULES-03, RULES-06, RULES-07, RULES-08, DOCS-11]

coverage:
  - id: D1
    description: "lib/base.yaml 에 sort_pub_dependencies 가 사유 주석과 함께 sort_constructors_first 와 sort_unnamed_constructors_first 사이에 있고 규칙 81개, RULES.md 켠 규칙 표에 같은 사유 · 0 · 0 · 0 (pubspec.yaml 2줄) · 재지 않음 행, 켜지 않은 규칙 표 90행"
    requirement: RULES-06
    verification:
      - kind: other
        ref: "04-12-PLAN.md Task 1 <automated> (커밋 6d64bee 직후와 9eb8ee5 에서)"
        status: pass
    human_judgment: false
  - id: D2
    description: "연습용 프로젝트 여섯의 pubspec.yaml 샘플이 정답지 다섯에 pubspec.yaml:11  info  sort_pub_dependencies 를 한 줄씩 만들고, example/pubspec.yaml 만 되돌리면 [5/10] · [6/10] 이 실패한다 (헛통과 아님)"
    requirement: RULES-08
    verification:
      - kind: integration
        ref: "fvm dart run tool/verify.dart (Task 1 <automated> 의 되돌림 구간 포함)"
        status: pass
    human_judgment: false
  - id: D3
    description: "CHANGELOG 2.0.0 항목에 sort_pub_dependencies 불릿(75) · 표 행(75) · 각주 · 도구 수정 불릿, 1.3.0 아래 그대로"
    requirement: RULES-03
    verification:
      - kind: other
        ref: "04-12-PLAN.md Task 2 <automated>"
        status: pass
    human_judgment: false
  - id: D4
    description: "04-DECISIONS.md 의 재결정 행 · 머리 문단 문장 · 메모 불릿이 소유자가 본 문구로만 적혔고 패널 원문은 그대로다"
    requirement: RULES-07
    verification:
      - kind: other
        ref: "04-12-PLAN.md Task 2 <automated> (479ad21 과의 패널 · 다른 행 diff)"
        status: pass
    human_judgment: true
    rationale: "단언은 문구의 존재와 다른 행의 불변만 본다 — 재결정 사유가 소유자의 응답(권고대로, 사유 덧붙임 없음)을 넘어서지 않는지는 사람이 읽고 확인한다"
  - id: D5
    description: "example/README.md 의 파일 표 · 연습용 프로젝트 여섯 표의 줄 수가 정답지와 같다 (합계 93), RULES-13 아래 CR-03 메모, 처리 기록 CR-03 deferred"
    requirement: DOCS-11
    verification:
      - kind: other
        ref: "04-12-PLAN.md Task 3 <automated> 의 고친 판 (REQUIREMENTS 비교 base 548e3e1)"
        status: pass
    human_judgment: true
    rationale: "적힌 그대로의 명령은 REQUIREMENTS 비교 base 결함으로 rc 1 — 고친 판만 통과했다. 파일 표 역할 칸의 문장(샘플 파일 머리 주석의 요약)은 사람이 읽고 확인한다"

duration: 10min
completed: 2026-10-13
status: complete
---

# Phase 4 Plan 12: sort_pub_dependencies 켬 반영 · 문서 수치 · CR-03 메모 Summary

**소유자 재결정(켬)대로 `lib/base.yaml` 에 `sort_pub_dependencies` 를 더해 규칙 81개가 되었고, 연습용 프로젝트 여섯의 `pubspec.yaml` 순서 위반 샘플이 정답지 다섯에 `pubspec.yaml:11  info  sort_pub_dependencies` 한 줄씩을 만들었으며, `RULES.md` · CHANGELOG · 결정 표가 같은 사유와 실측(2줄, 모두 `pubspec.yaml`, `dart fix` 재지 않음)을 적는다 — `example/README.md` 의 수치(WR-05)를 맞추고 CR-03 은 v2 메모 · `deferred` 로 남겼다**

## Performance

- **Duration:** 10 min
- **Started:** 2026-10-13T08:36:29Z
- **Completed:** 2026-10-13T08:46:11Z
- **Tasks:** 3
- **Files modified:** 18

## Accomplishments

- gap 1 의 missing 3 (소유자 재결정의 반영)을 닫았다 — 결정 묶음 커밋 하나(D-20)에 규칙 · 표 · 샘플 · 정답지가 함께 들어 있다.
- `--update` 가 찍은 다섯 줄 (정답지마다 같은 줄):
  - `정답지 갱신 대상: example/expected_diagnostics.txt` / `+ pubspec.yaml:11  info  sort_pub_dependencies`
  - `정답지 갱신 대상: fixtures/base_only/expected_diagnostics.txt` / `+ pubspec.yaml:11  info  sort_pub_dependencies`
  - `정답지 갱신 대상: fixtures/base_riverpod/expected_diagnostics.txt` / `+ pubspec.yaml:11  info  sort_pub_dependencies`
  - `정답지 갱신 대상: fixtures/base_codegen/expected_diagnostics.txt` / `+ pubspec.yaml:11  info  sort_pub_dependencies`
  - `정답지 갱신 대상: fixtures/overrides/expected_diagnostics.txt` / `+ pubspec.yaml:11  info  sort_pub_dependencies`
  - 끝 줄 `정답지를 썼다 (5개):` · `점검 통과 (10개 중 10개)`. 머리 주석 날짜는 같은 날이라 그대로였고 `exit` 줄과 다른 진단 줄은 바뀌지 않았다 (`git diff` 가 정답지마다 `+1` 줄).
- 갱신 전 보통 실행: `[5/10]` · `[7/10]` ~ `[10/10]` 이 모두 `정답지에 없는데 나온 경고 (1)` + 그 줄 하나로만 실패, `[3/10]` · `[6/10]` 통과, `점검 실패 (10개 중 5개)`.
- 헛통과 확인 (`example/pubspec.yaml` 만 `ac5cced` 의 것으로 되돌림): 종료 코드 1, `[5/10] example (옛 주소) … 실패` 에 `정답지에는 있는데 나오지 않은 경고 (1)`, `[6/10] recommended (묶음) … 실패` 에 `example 에 없는데 여기서 나온 경고 (1)`, 두 곳 모두 `pubspec.yaml:11  info  sort_pub_dependencies`, `점검 실패 (10개 중 2개)`. 바로 샘플판으로 되돌렸고 `git diff` 0 이다. Task 1 의 검증 명령도 같은 되돌림을 커밋 뒤 두 번 더 돌려 통과했다.
- `--audit`: `감사 통과 — 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0`. `--report --in tool/measurements/2026-10-13-R1.json` 종료 코드 0, 출력 == `RULES.md` 실측 기록. `fvm dart analyze` `No issues found!`.
- CHANGELOG 2.0.0: 추가한 규칙 불릿 75 · 새로 생기는 경고 75행(`| \`sort_pub_dependencies\` | info | 2건 | 재지 않음 |`) · 자리별 건수 문구에 `pubspec` · 2건이 `pubspec.yaml` 의 줄이고 `dart fix` 를 재지 않았다는 각주 · 도구 수정 불릿(CR-01 · CR-02 · WR-06 · `--recount`).
- `04-DECISIONS.md`: 결정 표 `켬` 81 · `안 켬` 38, `sort_pub_dependencies` 행은 `켬` 과 재결정 사유 · 첫 결정(안 켬)의 이력, `use_test_throws_matchers` 행 · 패널(184 ~ 280행) · 권고의 합계 표는 `479ad21` 과 같다.
- `example/README.md` 에 적은 수치 (정답지에서 다시 셈): 파일 표 `added_rules` 6 · `base_rules` 7 · `main` 1 · `riverpod_rules` 3 · `should_not_appear` 0 · `generated/` 0 · `bug_prevention_rules` 25 · `performance_rules` 8 · `style_rules` 38 · `strict_rules` 2 · `final_parameters_rule` 1 · `relative_imports_rule` 1 · `pubspec.yaml` 1 = 93, `expected_diagnostics.txt` 행 `exit 2` + 93줄. 연습용 프로젝트 여섯 표 93 · 93 · 95 · 104 · 98 · 90.
- CR-03: `.planning/REQUIREMENTS.md` 의 RULES-13 바로 아래에 "재측정 전에 먼저 고칠 것" 한 줄, `04-REVIEW-DISPOSITION.md` 의 CR-03 이 frontmatter · 표 모두 `deferred` 와 사유, `open: 18` → `17`. 측정 도구 코드는 바꾸지 않았다.

## Task Commits

1. **Task 1: sort_pub_dependencies 켬 — lib/base.yaml · RULES.md 표 · pubspec.yaml 샘플 여섯 · 정답지 다섯 (D-20)** - `6d64bee` (feat)
2. **Task 2: CHANGELOG 2.0.0 항목과 04-DECISIONS.md 의 재결정 기록** - `fb6386a` (docs)
3. **Task 3: example/README.md 수치 · 파일 표 (WR-05), RULES-13 옆 CR-03 메모, CR-03 deferred** - `9eb8ee5` (docs)

**Plan metadata:** 이 SUMMARY 의 커밋과 STATE · ROADMAP · REQUIREMENTS 의 커밋 (docs)

## 검증 명령 (`<automated>`) 실행 기록

PLAN 에서 그대로 뽑아 저장소 루트에서 `bash` 로 돌렸다 (종료 코드는 파일로 받음).

| Task | 실행 시점 | 적힌 그대로 rc | 고친 판 rc | 원인 |
|------|-----------|----------------|------------|------|
| 1 | 커밋 `6d64bee` 직후 (계획대로) | 0 | - | - |
| 1 | 마지막 task HEAD `9eb8ee5` | 0 | - | - |
| 2 | 커밋 전 | 0 | - | - |
| 2 | 커밋 `fb6386a` 직후 | 0 | - | - |
| 2 | 마지막 task HEAD `9eb8ee5` | 0 | - | - |
| 3 | 커밋 전 | (돌리지 않음) | 0 | - |
| 3 | 커밋 `9eb8ee5` 직후 · 마무리 커밋 전 | 1 | 0 | 단언 결함 — `.planning/REQUIREMENTS.md` 를 `f5962c3` 과 견주지만, 04-11 의 마무리 커밋 `548e3e1` 이 RULES-01 · RULES-05 를 이미 완료로 표시했다(체크박스 2줄 · 추적 표 2행). 고친 판은 `git show f5962c3:"$Q"` 하나만 `git show 548e3e1:"$Q"` 로 바꾼 것 |

적힌 그대로의 실패 구간은 `diff <(git show f5962c3:"$Q") <(grep -v '^  - 재측정 전에 먼저 고칠 것' "$Q")` 이고 차이는 위 4줄뿐이다 (같은 비교를 `548e3e1` 로 하면 rc 0). 일은 바꾸지 않았다.

## Files Created/Modified

- `lib/base.yaml` - `# 가독성 및 스타일` 에 `sort_pub_dependencies` 한 줄 (규칙 81개)
- `RULES.md` - 켠 규칙 표에 행 추가, 켜지 않은 규칙 표에서 행 삭제 (실측 기록은 그대로)
- `example/pubspec.yaml`, `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/pubspec.yaml` - `dependencies` 의 `flutter_riverpod` 를 `flutter` 앞으로 (lock 여섯은 그대로)
- `example/expected_diagnostics.txt`, `fixtures/{base_only,base_riverpod,base_codegen,overrides}/expected_diagnostics.txt` - `pubspec.yaml:11  info  sort_pub_dependencies` 한 줄씩
- `CHANGELOG.md` - 2.0.0 의 불릿 · 표 행 · 각주 · 도구 수정 불릿
- `.planning/phases/04-rule-reselection/04-DECISIONS.md` - 재결정 행 · 머리 문단 문장 · 메모 불릿
- `example/README.md` - 파일 표의 새 행 여섯 · `riverpod_rules` · `pubspec.yaml` · 정답지 줄 수, 연습용 프로젝트 여섯 표의 줄 수
- `.planning/REQUIREMENTS.md` - RULES-13 아래 CR-03 메모 한 줄
- `.planning/phases/04-rule-reselection/04-REVIEW-DISPOSITION.md` - CR-03 `deferred` (frontmatter · 표 · `open` 수)

`files_modified` 가 18개로 기준(15)을 넘지만 나누지 않았다 — Task 1 의 13개는 D-20 이 한 커밋에 묶는 기계적 변경(두 줄 순서 바꿈 × 6, `--update` 가 다시 쓴 정답지 × 5, 규칙 한 줄, 표 두 행)이고, Task 2 · 3 의 5개는 같은 결정의 기록이라 wave 를 하나 더 두어 떼어 낼 이득이 없다 (04-06 · 04-07 의 26개와 같은 꼴).

## Decisions Made

- 소유자의 결정(2026-10-13, 켬 · CR-03 은 메모와 deferred)을 반영했을 뿐 새로 정한 규칙 결정은 없다. 결정 표 `사유` 칸과 메모 불릿은 계획의 문구 그대로다 (소유자가 덧붙이지 않은 이유를 더하지 않음).
- `example/README.md` 파일 표의 역할 칸은 각 샘플 파일의 머리 주석을 한 문장으로 줄였다 (아래 deviation 1).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - 사실 맞춤] `bug_prevention_rules.dart` 역할 칸의 규칙 수**
- **Found during:** Task 3
- **Issue:** 계획은 역할을 "04-06 에 켠 버그 방지 규칙 25개를 한 건씩 어긴다" 로 적으라 했지만, 정답지의 그 파일 25줄은 04-06 의 규칙 24개(`discarded_futures` 포함) 각 1줄과 135행의 04-07 규칙 `join_return_with_assignment` 1줄이다 (`parameter_assignments` 와 같은 줄).
- **Fix:** "04-06 에 켠 버그 방지 규칙 24개(`discarded_futures` 포함)를 한 건씩 어긴다 — 135행은 `parameter_assignments` 와 04-07 의 `join_return_with_assignment` 에 함께 걸려 정답지에 두 줄이다" 로 적었다. 줄 수 칸은 25 그대로.
- **Files modified:** `example/README.md`
- **Verification:** Task 3 의 줄 수 단언(고친 판 rc 0), 정답지의 규칙별 집계
- **Committed in:** `9eb8ee5`

**2. [표기] CHANGELOG 각주 앞의 빈 줄**
- **Found during:** Task 2
- **Issue:** 계획은 "자리별 건수 …" 줄 다음에 각주 한 줄을 더하라 했다. 빈 줄 없이 붙이면 Markdown 에서 한 문단으로 합쳐진다.
- **Fix:** 두 줄 사이에 빈 줄을 두어 다른 줄들처럼 문단을 나눴다. 문장은 계획 그대로.
- **Files modified:** `CHANGELOG.md`
- **Verification:** Task 2 `<automated>` rc 0
- **Committed in:** `fb6386a`

**3. [단언 결함] Task 3 `<automated>` 의 REQUIREMENTS 비교 base** — 위 실행 기록 표. 일은 바꾸지 않고 고친 판으로 확인했다 (orchestrator 가 미리 짚은 결함).

---

**Total deviations:** 3 (사실 맞춤 1, 표기 1, 단언 결함 1)
**Impact on plan:** 결정 · 수치 · 커밋 구성은 계획대로다. 다른 줄(`pubspec.yaml:11` 의 줄 번호, 정답지 줄 수 93 · 95 · 104 · 98 · 90, `--audit` 의 수)은 모두 계획이 적은 값과 같았다.

## Issues Encountered

None.

## 이 plan 이 다루지 않은 것

- 리뷰 지적 가운데 WR-01 · WR-03 · WR-04 · WR-07 · WR-08 · IN-01 ~ IN-07 은 소유자가 이 gap 계획에 넣지 않아 고치지 않았고 `open` 으로 남는다. CR-01 · CR-02 · WR-02 · WR-05 · WR-06 의 `fixed` 기록은 마무리의 리뷰 재실행이 한다 (처리 기록의 그 행들은 손대지 않음).
- `use_test_throws_matchers` 는 재결정 대상이 아니라 `안 켬` 그대로다.
- 비공개 사용 프로젝트는 돌리지 않았다 — 측정 도구는 출력 모드(`--audit` · `--report`)만 썼다. push 는 하지 않았다.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 4 의 gap 수정 plan 둘(04-11 · 04-12)이 끝났다 — 마무리의 리뷰 재실행과 재검증으로 넘어간다.
- 사용 프로젝트 5개는 2.0.0 을 받을 때 `pubspec.yaml` 에 info 2줄(`sort_pub_dependencies`)을 새로 받는다 — CHANGELOG 각주에 적었다.
- 이 plan 의 상태 고정 단언(`944ca1c` · `479ad21` 과의 diff, `켬` 81 · `안 켬` 38)은 뒤의 변경으로 거짓이 될 수 있다 — 뒤의 감사는 task 커밋(`6d64bee` · `fb6386a` · `9eb8ee5`)으로 되돌린 복제본에서 재실행한다.

---
*Phase: 04-rule-reselection*
*Completed: 2026-10-13*

## Self-Check: PASSED

- 수정한 파일 18개 모두 있음, task 커밋 `6d64bee` · `fb6386a` · `9eb8ee5` 가 HEAD 의 조상, 계획 범위 파일의 비공개 점검 (1) 0줄.
