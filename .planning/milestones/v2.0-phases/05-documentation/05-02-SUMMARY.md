---
phase: 05-documentation
plan: 02
subsystem: config
tags: [yaml, analysis_options, riverpod_lint, docs, claude-md]

requires:
  - phase: 05-documentation
    provides: "05-01 의 줄 끝 주석을 받는 readShippedPluginConstraint · 줄 단위 stripPlugins (WR-02)"
  - phase: 04-rule-reselection
    provides: "lib/base.yaml 의 분류 주석 넷 · 규칙 81줄과 사유 주석 (RULES-07), 정답지 다섯 (6d64bee)"
provides:
  - "배포 YAML 다섯의 짧은 한국어 머리 주석 (base 4줄 · riverpod 3줄 · codegen 3줄 · recommended 3줄 · analysis_options 3줄)"
  - "lib/base.yaml 의 템플릿 영어 주석 0줄"
  - "lib/riverpod.yaml 10행의 줄 끝 주석 (하한을 올리면 fixtures/overrides 의 version: 도)"
  - ".claude/CLAUDE.md 71 · 181행의 새 문장 (D-09)"
affects: [05-03, 05-05]

actuals:
  tokens: 1940
  tasks: 2
  commits: 2
plan_head_before: 297375afad9a1b3fc2c1029687fbc4eed0e4b6f2
plan_head_after: 403c584801ea4b045ac0956029aea2b76cd18e6e

tech-stack:
  added: []
  patterns:
    - "배포 YAML 머리 주석은 2 ~ 4줄: 무엇을 주는지 · include 주소 · 왜 이 모양인지 한 줄 · 자세한 것은 README / RULES.md"

key-files:
  created: []
  modified:
    - lib/base.yaml
    - lib/riverpod.yaml
    - lib/codegen.yaml
    - lib/recommended.yaml
    - lib/analysis_options.yaml
    - .claude/CLAUDE.md

key-decisions:
  - "lib/recommended.yaml · lib/analysis_options.yaml 에도 README.md 를 가리키는 # 줄을 하나씩 더했다 — must_haves 의 '자세한 것은 README' 를 다섯 파일 모두에서 지키려고 (include 줄은 그대로)"
  - ".claude/CLAUDE.md 71행의 괄호는 '[3/10] 이 lib/base.yaml · RULES.md · README 표시 구역의 일치를 본다' 로 적었다 — CHANGELOG 는 검증이 보지 않으므로 '세 곳' 이라는 모호한 표현을 피함"

patterns-established:
  - "YAML 주석에는 사용법 · 문제 해결을 두지 않고 README 절 이름으로 가리킨다 (D-08)"

requirements-completed: [DOCS-10]

coverage:
  - id: D1
    description: "배포 YAML 다섯의 첫 줄이 # 머리 주석이고 base · riverpod · codegen 의 # 줄이 2 ~ 4, base.yaml 에 템플릿 영어 주석 0줄, 규칙 · 분류 · include · analyzer: 줄이 고정 커밋과 같다"
    requirement: "DOCS-10"
    verification:
      - kind: integration
        ref: "05-02-PLAN.md Task 1 <automated> (커밋 전 rc 0, HEAD 에서 다시 rc 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "주석만 바뀌어 검증이 점검 통과 (10개 중 10개), --update 가 '바뀐 정답지가 없다 — 쓰지 않았다', 정답지 다섯이 6d64bee 와 같다; riverpod.yaml 10행의 줄 끝 주석 위에서 [4/10] 통과"
    requirement: "DOCS-10"
    verification:
      - kind: integration
        ref: "fvm dart run tool/verify.dart · fvm dart run tool/verify.dart --update (Task 1 <automated> 안)"
        status: pass
    human_judgment: false
  - id: D3
    description: ".claude/CLAUDE.md 가 cd76cc8 과 두 줄(71 · 181행)만 다르다"
    verification:
      - kind: other
        ref: "05-02-PLAN.md Task 2 <automated> 의 고친 사본 (as-written 은 단언 결함으로 rc 1 — 아래 표)"
        status: pass
    human_judgment: false
  - id: D4
    description: "머리 주석의 문장이 읽기 쉽고 사실과 맞는지 (어투 · 길이)"
    verification: []
    human_judgment: true
    rationale: "자동 단언은 줄 수와 고정 문구만 본다 — 문장의 질은 사람이 읽어야 한다"

duration: 4min
completed: 2026-10-14
status: complete
---

# Phase 5 Plan 02: 배포 YAML 머리 주석과 CLAUDE.md 두 줄 Summary

**배포 YAML 다섯의 머리 주석을 실제 구성(조각 셋 · 묶음 · 옛 이름 별칭)을 말하는 2 ~ 4줄 한국어로 다시 쓰고 `lib/base.yaml` 의 템플릿 영어 주석을 지웠다. `lib/riverpod.yaml` 의 캐시 · 재시작 · 실측 문장은 README 로 넘기고 10행에 줄 끝 주석을 달았다. 검증은 10개 중 10개 통과, 정답지는 그대로다. `.claude/CLAUDE.md` 는 71 · 181행 두 줄만 고쳤다.**

## Performance

- **Duration:** 약 4분 (작업 시작 기록 이후. 필수 문서 읽기는 그 전)
- **Started:** 2026-10-13T17:07:59Z
- **Completed:** 2026-10-13T17:12:09Z (KST 2026-10-14)
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- `lib/base.yaml` 112행 → 95행: 영어 템플릿(옛 1 ~ 12 · 15 · 106 ~ 112행)을 지우고 머리 4줄을 새로 썼다. `include:` · `linter:` · `  rules:` · 분류 주석 넷 · 규칙 81줄은 `6d64bee` 와 글자 그대로 같고, 파일은 `no_raw_types` 줄로 끝난다.
- `lib/riverpod.yaml`: 주석 8줄을 3줄로 줄였다. "왜 최상위 `plugins:` 인가"(옛 `analyzer: plugins:` 경고)만 남겼다. plugin 캐시 · 재시작 · `flutter analyze` 실측 문장은 지우고 README 「문제 해결」을 가리킨다. 10행에는 `  riverpod_lint: ^3.1.9 # …` 줄 끝 주석을 달았다(값 · 들여쓰기는 그대로).
- `lib/codegen.yaml`: 머리 주석 3줄을 새로 두었다(이 파일에는 원래 주석이 0줄이었다). 끝의 빈 줄을 지웠고, `analyzer:` 블록 여섯 줄은 그대로다. exclude 경고는 "닿지 않을 수 있다" 로 적었다. 단정형이 아니다.
- `lib/recommended.yaml` · `lib/analysis_options.yaml`: README 를 가리키는 `#` 줄을 하나씩 더했다. include 줄은 그대로다.
- `.claude/CLAUDE.md`: 71 · 181행만 바꿨다. `git diff --numstat cd76cc8` 결과는 `2 2` 이고 전체 줄 수는 같다.

## 새 머리 주석 (글자 그대로)

`lib/base.yaml` (4줄)
```
# woody_lints 기본 규칙 — flutter_lints 6 의 기반 세트(package:flutter_lints/flutter.yaml) 위에 이 패키지가 더 켜는 규칙을 준다.
# 이 조각만 받으려면 package:woody_lints/base.yaml 을 include 한다.
# 규칙은 이 파일에만 적는다 — 검증 명령의 "배포 파일의 구성" 단계가 RULES.md 켠 규칙 표 · README 의 규칙 목록과 같은지 견주므로 세 곳을 같은 커밋에서 고친다.
# 규칙마다 켠 이유와 실측 건수는 RULES.md, 사용법은 README.md 에 있다.
```

`lib/riverpod.yaml` (3줄 + 10행)
```
# woody_lints 의 Riverpod 조각 — riverpod_lint analyzer plugin 을 켠다. 이 조각만 받으려면 package:woody_lints/riverpod.yaml 을 include 한다.
# plugins: 는 최상위 키여야 한다 — riverpod_lint 3.x 는 analysis_server_plugin 방식만 지원하고, 옛 `analyzer: plugins:` 선언은 아무것도 로드하지 않는다.
# plugin 캐시 · Analysis Server 재시작 · `dart analyze` 와 `flutter analyze` 의 차이는 README.md 「문제 해결」에 있다.
plugins:
  riverpod_lint: ^3.1.9 # 하한을 올리면 fixtures/overrides/analysis_options.yaml 의 version: 도 같은 커밋에서 올린다 — 검증 명령의 "연습용 프로젝트 옵션 파일" 단계가 둘을 견준다
```

`lib/codegen.yaml` (3줄)
```
# woody_lints 의 코드 생성 조각 — freezed · json_serializable 의 invalid_annotation_target 을 끄고(analyzer.errors), 생성 파일 *.freezed.dart · *.g.dart 를 분석에서 뺀다(analyzer.exclude).
# 이 조각만 받으려면 package:woody_lints/codegen.yaml 을 include 한다.
# 여기 적은 exclude 는 SDK 에 따라 사용 프로젝트의 plugin 진단(베타에서는 규칙 진단에도)에 닿지 않을 수 있다 — 사용 프로젝트에 직접 적는 방법은 README.md 「생성 파일 제외」에 있다.
```

`lib/recommended.yaml` (3줄, 셋째 줄이 새 줄)
```
# woody_lints 묶음 — 기본 규칙 + Riverpod plugin + 코드 생성 설정을 한 번에 받는다.
# 조각을 골라 받으려면 아래 셋 가운데 필요한 것만 include 한다.
# 프리셋 고르기와 사용법은 README.md 에 있다.
```

`lib/analysis_options.yaml` (3줄, 셋째 줄이 새 줄)
```
# 옛 주소 (package:woody_lints/analysis_options.yaml) 의 별칭 — 묶음(recommended.yaml) 과 같다.
# 새 프로젝트는 package:woody_lints/recommended.yaml 을 include 한다.
# 이미 이 주소를 쓰는 사용 프로젝트가 깨지지 않도록 남겨 둔 파일이다 — 자세한 것은 README.md.
```

## 검증 출력

- `fvm dart analyze` → `No issues found!` (커밋 1 · 커밋 2 전 모두)
- `fvm dart run tool/verify.dart` → `[1/10]` ~ `[10/10]` 모두 통과, `점검 통과 (10개 중 10개)`
- `fvm dart run tool/verify.dart --update` → `바뀐 정답지가 없다 — 쓰지 않았다`, 이어서 `점검 통과 (10개 중 10개)`. 실행 뒤 `git status` 에 `example` · `fixtures` 의 변경이 없다

## Task Commits

1. **Task 1: 배포 YAML 다섯의 머리 주석** — `209e3af` `docs(lib): 배포 YAML 다섯의 머리 주석을 실제 구성에 맞게 — 템플릿 주석 삭제, codegen.yaml 머리 신설 (DOCS-10)` (5 files, +13 −31)
2. **Task 2: `.claude/CLAUDE.md` 71 · 181행** — `403c584` `docs(claude): 규칙 추가 절차와 템플릿 주석 지시 두 줄을 DOCS-10 · D-01 에 맞게 (D-09)` (+2 −2)

## `<automated>` 결과

PLAN 에서 `grep '<automated>' | sed -n Np` 로 뽑아 `bash <파일>` 로 돌렸다.

| Task | 그대로 돌린 rc | 고친 사본 rc | 무엇을 왜 고쳤나 |
|------|----------------|--------------|------------------|
| 1 | 0 (커밋 전), 0 (HEAD `403c584` 에서 다시) | — | — |
| 2 | 1 (커밋 2 직후, amend 뒤에도 1) | 0 (커밋 2 직후, amend 뒤에도 0) | 지운 줄을 세는 `grep -E '^-[^-]'` 이 문제였다. `.claude/CLAUDE.md` 의 줄은 Markdown 불릿 `- …` 이라 diff 에서 지운 줄이 `-- …` 가 되고, 이 정규식이 그 줄을 늘 빼서 0을 센다(단언 결함). 고친 사본은 diff 머리 `--- a/` 만 빼고 `^-` 를 센다(`grep -vE '^--- a/' \| grep -E '^-'`). 더한 줄 쪽 `^\+[^+]` 는 `+- …` 를 잡으므로 그대로 두었다. 실제 diff 는 지운 줄 2 · 더한 줄 2 다 |

## Files Created/Modified

- `lib/base.yaml`: 머리 4줄 새로 씀, 템플릿 영어 주석과 끝의 빈 줄 삭제
- `lib/riverpod.yaml`: 머리 8줄 → 3줄, 10행 줄 끝 주석
- `lib/codegen.yaml`: 머리 3줄 신설, 끝의 빈 줄 삭제
- `lib/recommended.yaml`: README 를 가리키는 `#` 줄 하나
- `lib/analysis_options.yaml`: 남겨 둔 이유와 README 를 말하는 `#` 줄 하나
- `.claude/CLAUDE.md`: 71 · 181행

## Decisions Made

- `lib/recommended.yaml` · `lib/analysis_options.yaml` 에 `#` 줄을 하나씩 더했다. PLAN 은 "그대로 두거나 한 줄 더한다" 였다. must_haves 의 "자세한 것은 README" 를 다섯 파일 모두 지키도록 더하는 쪽을 골랐다.
- `.claude/CLAUDE.md` 71행의 괄호는 처음에 "세 곳의 일치를 본다" 로 커밋했다. 하지만 CHANGELOG 는 검증이 보지 않으므로 "`lib/base.yaml` · `RULES.md` · README 표시 구역의 일치를 본다" 로 고쳐 push 전의 커밋 2 를 amend 했다(`6c55dc3` → `403c584`). `6c55dc3` 은 브랜치에 남지 않는다.

## Deviations from Plan

### 단언 결함 (작업물이 아니라 검사의 결함)

**1. Task 2 `<automated>` 의 지운 줄 세기가 Markdown 불릿 줄을 놓침**
- **Found during:** Task 2, 커밋 직후 검사
- **Issue:** `grep -E '^-[^-]'` 는 `-- …` 꼴의 지운 줄을 세지 못해 늘 0이 된다. 그래서 as-written 검사는 이 파일에서 통과할 수 없다.
- **Fix:** PLAN 은 고치지 않았다. scratch 에 고친 사본을 만들어 두 판을 모두 돌렸다(위 표).
- **Committed in:** 해당 없음 (검사만)

그 밖에는 PLAN 대로 했다.

**Total deviations:** 검사 결함 1 (작업물 변경 없음). **Impact:** 없음.

## Issues Encountered

- 참고: `lib/base.yaml` 머리 셋째 줄과 새 71행은 "README 의 규칙 목록(표시 구역)" 을 검증이 견준다고 적는다. 이 README 비교 (d) 는 05-03 이 더한다. 지금 `[3/10]` 은 `lib/base.yaml` ↔ `RULES.md` 만 본다. 두 문장은 PLAN 지시대로 05-03 이후의 상태를 적은 것이다.
- 참고: DOCS-10 의 README 쪽(README 의 템플릿 HTML 주석 삭제)은 05-03 의 몫이다. 05-03 의 frontmatter 는 DOCS-10 을 선언하지 않는다. `requirements.ready-ids` 가 `1/1 ready` 여서 오케스트레이터 지시대로 이 plan 에서 완료 표시했다.

## Known Stubs

없음.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-03 은 README 「문제 해결」에 plugin 캐시 · Analysis Server 재시작 · `dart analyze` 와 `flutter analyze` 의 차이를, 「생성 파일 제외」에 직접 적는 방법을 적어야 한다. 이번에 YAML 주석이 이 두 절 이름을 가리키도록 바꿨다.
- 05-05 의 push 전 비공개 훑기 대상에 이 plan 의 파일 여섯이 들어간다. 지금 절대 경로 grep 결과는 0줄이다.

## Self-Check: PASSED

- 수정 파일 여섯이 있고, 커밋 `209e3af` · `403c584` 가 HEAD 의 조상이다(아래 확인 명령).
- 다섯 YAML · `.claude/CLAUDE.md` · 이 SUMMARY 에서 절대 경로 grep 결과는 0줄이다.

---
*Phase: 05-documentation*
*Completed: 2026-10-14*
