---
phase: 05-documentation
plan: 06
subsystem: testing
tags: [dart, verify, tool-verify, readme, break-test]

requires:
  - phase: 05-documentation
    provides: "05-03 의 README 재작성과 `[3/10]` README 검사 (d) ~ (g) (`readBulletBlock` · `fencedLines` · `pubspecReleaseVersion`), 05-01 의 (05-01) 소절 형식"
provides:
  - "`example/README.md` 의 소절 `### 추가 실측 — README 의 규칙 목록 · 주소 · plugin 버전 · ref (05-06)` 과 M38 ~ M42 다섯 행 (실제로 돌린 단계 · 종료 코드 · 찍힌 줄)"
  - "`example/README.md` 의 단계 설명 `[3/10]` 에 README 검사 넷, 종료 코드 70 설명에 `pubspec.yaml` 의 `version:` 을 읽지 못한 경우"
affects: [05-05]

actuals:
  tokens: 1700
  tasks: 1
  commits: 1
plan_head_before: 1018aba5aae1ffa4310e2eddd055777f548cfb4e
plan_head_after: 1d283466bcd1beeef5bef577154743ac66bc42b2

tech-stack:
  added: []
  patterns:
    - "지워 보기는 변형 → sanity 캡처 → 실행 캡처 → `git checkout -- README.md` → 판정 순서로, 내용 기준 perl 변형(줄 끝 앵커 `[ \\t]*$`)으로 돌린다"

key-files:
  created: []
  modified:
    - example/README.md

key-decisions:
  - "05-06: README 검사 (d) ~ (g) 의 지워 보기 M38 ~ M42 다섯 모두 종료 코드 1 · [3/10] 만 실패 · 점검 실패 (10개 중 1개), 각 19초 — (e) 는 첫 주소(50행)가 아닌 뒤쪽 주소(78행)의 오타를 잡았다. (f) · (g) 의 코드 블록 한정은 fencedLines 코드를 읽은 것이고 실행으로 가르지 않았다"

patterns-established:
  - "검사가 첫 일치만 보는지 전체를 보는지는 첫 등장이 아닌 뒤쪽 등장을 바꾼 지워 보기로 가른다"

requirements-completed: [VERIFY-06]

coverage:
  - id: D1
    description: "README 검사 (d) ~ (g) 가 헛통과가 아니다 — M38 ~ M42 다섯 모두 종료 코드 1 · `[3/10] 배포 파일의 구성 … 실패` · 기대한 문구, 기록은 `example/README.md` 의 (05-06) 소절"
    requirement: "VERIFY-06"
    verification:
      - kind: integration
        ref: "05-06-PLAN.md Task 1 <automated> (fvm dart run tool/verify.dart 를 변형 다섯 + 보통 실행 한 번, 쓰인 그대로 rc 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "단계 설명 `[3/10]` 의 README 검사 넷과 종료 코드 70 의 `pubspec.yaml` 경우 덧붙임, 읽는 법의 문장(코드에서 읽은 것과 실행으로 가른 것의 구분)"
    requirement: "VERIFY-06"
    verification:
      - kind: other
        ref: "05-06-PLAN.md Task 1 <automated> 의 grep 단언 (`아래 M38 ~ M42` · `woody:readme-rules` · `pubspec.yaml` 에서 `version:` 을 읽지 못한 경우 · `fencedLines`)"
        status: pass
    human_judgment: true
    rationale: "grep 은 문자열이 있는지만 본다 — 문장이 코드와 실행 결과를 정확히 옮겼는지(P-02 의 '확인' 쓰임)는 사람이 읽어야 한다"
  - id: D3
    description: "지워 보기로 바꾼 `README.md` 는 커밋되지 않았다 — 되돌린 뒤 `README.md` · `lib/` · `tool/` 이 HEAD 와 같고 보통 실행이 종료 코드 0 · `점검 통과 (10개 중 10개)`"
    verification:
      - kind: integration
        ref: "05-06-PLAN.md Task 1 <automated> 끝의 git diff --quiet HEAD -- README.md lib tool · git status --porcelain · 보통 실행"
        status: pass
    human_judgment: false

duration: 9min
completed: 2026-10-14
status: complete
---

# Phase 05 Plan 06: README 검사 (d) ~ (g) 의 지워 보기 M38 ~ M42 Summary

**README 의 표시 구역 이름 삭제 · 뒤쪽 블록 주소 오타 · 끄기 블록 `^3.1.3` · `ref: v1.3.0` · start 마커 삭제를 실제로 돌려 다섯 모두 `[3/10]` 만 종료 코드 1 로 실패함을 `example/README.md` 에 글자 그대로 기록했다**

## Performance

- **Duration:** 9 min
- **Started:** 2026-10-13T17:41:22Z
- **Completed:** 2026-10-13T17:50Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- 지워 보기 다섯을 하나씩 돌렸다 (Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-14). 다섯 모두 sanity 0 · 종료 코드 1 · `[3/10] 배포 파일의 구성 ................ 실패` · 나머지 아홉 단계 통과 · `점검 실패 (10개 중 1개)` · 19초였다.
- `example/README.md` 의 05-01 소절 뒤 · 각주 앞에 (05-06) 소절을 더했다 — 6열 표 M38 ~ M42, 실행한 명령 문단, 읽는 법 불릿 일곱, 되돌림 문장.
- 단계 설명(116행)의 `[3/10]` 괄호 끝에 README 검사 넷을, 종료 코드 70 설명(113행)에 `pubspec.yaml` 에서 `version:` 을 읽지 못한 경우를 덧붙였다. M1 ~ M37 행과 그 문구는 그대로다 (diff 의 삭제 줄은 그 두 줄뿐).

### M38 ~ M42 의 실제 결과

| # | 변경 (바꾸기 전 행) | 실패한 단계 | 종료 코드 | `[3/10]` 이 찍은 줄 (화면 그대로, 앞 공백 포함) | 걸린 시간 |
|---|---------------------|-------------|-----------|------------------------------------------------|-----------|
| M38 | 표시 구역의 `` - `prefer_single_quotes` `` 삭제 (112행) | `[3/10]` 만 | 1 | `` `README.md` 의 규칙 목록과 `lib/base.yaml` 의 규칙 목록이 다르다. `` / `  + prefer_single_quotes  (base.yaml 에만)` / `` `README.md` 의 목록 · `RULES.md` 의 표 · `lib/base.yaml` 을 같은 커밋에서 고친다. `` | 19초 |
| M39 | 기본 + codegen 블록 `codegen.yaml` → `codegn.yaml` (78행, 첫 주소 50행이 아님) | `[3/10]` 만 | 1 | `` `README.md` 가 가리키는 프리셋 주소가 `lib/` 에 없다 (1): `` / `  package:woody_lints/codegn.yaml` / `` `lib/` 의 파일 이름과 `README.md` 의 주소를 같은 커밋에서 고친다. `` | 19초 |
| M40 | 끄기 블록 `version: ^3.1.9` → `^3.1.3` (234행) | `[3/10]` 만 | 1 | `` `README.md` 의 코드 블록에 적힌 riverpod_lint 버전이 `lib/riverpod.yaml` 의 선언(^3.1.9)과 다르다: `` / `  ^3.1.3` / `` `README.md` 의 끄기 예시 · `lib/riverpod.yaml` · `fixtures/overrides/analysis_options.yaml` 을 같은 커밋에서 고친다. `` | 19초 |
| M41 | `ref: v2.0.0` 두 줄 → `ref: v1.3.0` (18행 · 333행) | `[3/10]` 만 | 1 | `` `README.md` 의 `ref: vX.Y.Z` 예시가 `pubspec.yaml` 의 version (2.0.0) 과 다르다: `` / `  ref: v1.3.0` / `` 릴리스 버전을 올릴 때 `README.md` 의 `ref:` 예시도 같은 커밋에서 고친다. `` | 19초 |
| M42 | `<!-- woody:readme-rules:start -->` 삭제 (93행) | `[3/10]` 만 | 1 | `` `README.md` 의 `woody:readme-rules` 구역이 없다 — 05-CONTEXT.md D-01 `` / 사이 안내 한 줄 | 19초 |

되돌린 뒤의 보통 실행은 종료 코드 0 · `점검 통과 (10개 중 10개)` · 19초. `<automated>` 전체(변형 다섯 + 보통 실행)는 114초.

## Task Commits

1. **Task 1: 지워 보기 M38 ~ M42 를 실제로 돌려 example/README.md 에 기록하고 단계 설명에 README 검사를 덧붙임** — `1d28346` (docs)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 을 담은 다음 커밋 (docs)

## Files Created/Modified

- `example/README.md` — (05-06) 소절 · M38 ~ M42 행 다섯, 단계 설명 `[3/10]` 과 종료 코드 70 설명 덧붙임

## Verification

| 검사 | 쓰인 그대로 rc | 고친 판 rc |
|------|----------------|------------|
| 05-06-PLAN.md Task 1 `<automated>` (한 줄을 그대로 뽑아 `bash` 로) | 0 | 해당 없음 (고치지 않았다) |

- 절대 경로 꼴 grep (`example/README.md`): 0줄. 마지막 바이트 `0a`.
- 행 수: M38 ~ M42 5 · M32 ~ M37 6 · M27 ~ M31 5.
- 저장소 루트 `fvm dart analyze`: `No issues found!`
- 매 실행 뒤 `git status --porcelain -- README.md lib tool` 비어 있음.

## Decisions Made

- 표의 `[3/10]` 줄은 화면 줄의 앞 공백 두 칸을 뗀 꼴로 적고 그 사실을 소절에 밝혔다 — M21 · M26 등 앞 소절의 관례(`+ prefer_single_quotes  (base.yaml 에만)`)와 같게.
- 블록 한정은 "코드를 읽은 것이고 실행으로 가른 것은 아니다" 로 적었다 (P-02). 산문의 옛 값 두 줄(7행 `ref: v1.3.0`, 372행 `^3.1.3`)은 앵커 정규식에도 맞지 않아 지금 README 로는 두 구현을 가를 수 없다.
- M41 에서 값 줄이 하나인 까닭, `- ` 쪽 기호, (e) · (f) · (g) 의 0개 경로는 코드에서 읽은 것이라 적었다 — 이번에 돌리지 않았다.

## Deviations from Plan

### 문구 조정 (Rule 1 범위 밖, 기록용)

**1. 단계 설명의 (f) 문구에 `riverpod_lint:` 를 더함**
- **Found during:** Task 1 (단계 설명 덧붙임)
- **Issue:** 계획의 문구는 "README 코드 블록의 `version:` 이 … 같은지" 였으나, `tool/verify.dart` 의 (f) 는 `version:` 과 `riverpod_lint:` 줄을 함께 읽는다 (M40 에서 198행 `riverpod_lint: ^3.1.9` 도 읽힌다).
- **Fix:** "`version:` (과 `riverpod_lint:`) 값이" 로 적었다. `<automated>` 의 단언에는 영향이 없다.
- **Files modified:** `example/README.md`
- **Committed in:** `1d28346`

**2. 종료 코드 70 덧붙임의 자리**
- 계획은 "괄호 끝에" 더하라고 했다. 기존 괄호는 `… — 문구에 파일 이름이 들어간다 — 포함)` 으로 끝나므로, 기존 글자를 고치지 않으려고 `포함)` 바로 앞에 `, \`pubspec.yaml\` 에서 \`version:\` 을 읽지 못한 경우` 를 끼웠다.

---

**Total deviations:** 0 auto-fixed, 문구 조정 2 (기존 문구는 지우지 않음)
**Impact on plan:** 없음 — `<automated>` 는 쓰인 그대로 rc 0.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-05 (첫 push, 소유자 확인)가 남았다. VERIFY-06 의 완료 표시는 05-05 가 한다 (이 plan 은 REQUIREMENTS.md 를 건드리지 않았다).
- push 전 범위 전체의 비공개 점검(D-20)은 05-05 의 일이다. 이 plan 의 파일 · 커밋 메시지에는 저장소 상대 경로만 있다.

## Self-Check: PASSED

- FOUND: `example/README.md` (소절 · M38 ~ M42 행)
- FOUND: `1d28346` (HEAD 의 조상)
- `<automated>` rc 0, 되돌린 뒤 `README.md` · `lib` · `tool` 이 HEAD 와 같음

---
*Phase: 05-documentation*
*Completed: 2026-10-14*
