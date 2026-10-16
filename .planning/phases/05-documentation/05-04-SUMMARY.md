---
phase: 05-documentation
plan: 04
subsystem: docs
tags: [changelog, keep-a-changelog, git-history, review-disposition]

requires:
  - phase: 05-documentation
    provides: "05-03 의 README 절 제목 `## 버전 올리기` — 2.0.0 「올리기 전에」 가 가리키는 자리"
  - phase: 04-rule-reselection
    provides: "CHANGELOG 2.0.0 의 `### 추가한 규칙` 75 불릿 · `### 새로 생기는 경고` 표 75행 (fb6386a)"
provides:
  - "CHANGELOG 1.1.0 ~ 1.2.5 복원 항목 7개 (버전마다 날짜 · 커밋 번호 · diff 로 확인한 변경)"
  - "2.0.0 `### 올리기 전에` 불릿 넷 (받는 때 · README 링크), `### 그 밖의 변경` 불릿 여덟 (저장소 안쪽 한 줄)"
  - "01-REVIEW-DISPOSITION.md WR-05 fixed (open 12)"
affects: [05-05, 05-06, 06-release]

actuals:
  tokens: 2660
  tasks: 2
  commits: 3
plan_head_before: dd7ad0a21fbf8e13b0537d0f761763ce3207ffe9
plan_head_after: 6abea40

tech-stack:
  added: []
  patterns:
    - "복원 항목: 제목 `## X.Y.Z` (날짜 없음) → 한 줄 `YYYY-MM-DD, 커밋 \\`해시\\` (tag 없음)` → 옛 불릿. 저장소 안쪽 변경은 \"사용하는 프로젝트에는 영향 없음\" 으로 끝맺는다"

key-files:
  created: []
  modified:
    - CHANGELOG.md
    - .planning/phases/01-baseline-and-toolchain/01-REVIEW-DISPOSITION.md

key-decisions:
  - "05-04: CHANGELOG 1.1.0 항목에 같은 날 README 커밋 9bf0d86 (flutter pub upgrade woody_lints 안내)을, 1.2.4 항목에 그 사이의 FVM 설정 커밋 a97fd20 (2026-01-30) 을 적었다 — 05-RESEARCH.md § 3 표에 없던 커밋이고 diff 로 확인했다"
  - "05-04: 2.0.0 「올리기 전에」 의 받는 때는 flutter pub 으로 적고 근거를 spike 015 (2026-10-12) 로 둔다 — README 「버전 올리기」 와 같은 명령, 권하는 일의 내용은 README 에만"

patterns-established:
  - "CHANGELOG 의 저장소 안쪽 변경은 버전 항목마다 \"저장소 안쪽: … — 사용하는 프로젝트에는 영향 없음\" 한 줄로 모은다"

requirements-completed: [DOCS-07, DOCS-08, DOCS-09]

coverage:
  - id: D1
    description: "CHANGELOG 1.1.0 ~ 1.2.5 복원 7항목 — 내림차순, 날짜 · 커밋 줄 7, (tag 없음) 7, 1.2.1 · 1.2.2 설정 변경 없음, 1.2.4 옛 방식 analyzer: plugins:, 1.1.0 기반 세트 두 주소, 1.3.0 · 1.0.0 · 2.0.0 은 fb6386a 와 같음"
    requirement: "DOCS-08"
    verification:
      - kind: other
        ref: "05-04-PLAN.md Task 1 <automated> (커밋 024a36c 직후, Task 2 편집 전 rc 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "복원 항목의 문장마다 적힌 커밋의 diff 와 맞는지, 커밋 메시지가 옮겨지지 않았는지"
    requirement: "DOCS-08"
    verification: []
    human_judgment: true
    rationale: "PLAN Task 1 의 human-check — 자동 단언은 핵심 글자와 Update pubspec 0줄만 본다"
  - id: D3
    description: "2.0.0 형식 · 수치 확인 (1행 · 3행 · ### 넷 순서, 추가한 규칙 75 == 표 75, 실측 줄), 올리기 전에 불릿 넷, 그 밖의 변경 불릿 여덟, WR-05 fixed · open 12"
    requirement: "DOCS-07"
    verification:
      - kind: other
        ref: "05-04-PLAN.md Task 2 <automated> (커밋 6abea40 직후 rc 0)"
        status: pass
    human_judgment: false
  - id: D4
    description: "새로 생기는 경고 표 · 실측 한 줄이 fb6386a 와 글자 그대로 같다"
    requirement: "DOCS-09"
    verification:
      - kind: other
        ref: "05-04-PLAN.md Task 2 <automated> 의 diff 단언"
        status: pass
    human_judgment: false

duration: 3min
completed: 2026-10-14
status: complete
---

# Phase 5 Plan 04: CHANGELOG 복원 7항목과 2.0.0 두 칸 정리 Summary

**CHANGELOG 의 1.0.0 과 1.3.0 사이 버전 일곱(1.1.0 ~ 1.2.5)을 커밋마다 `git show` 의 diff 로 다시 읽어 버전마다 한 항목으로 복원했다. 2.0.0 「올리기 전에」 에는 `ref: main` 프로젝트가 받는 때(`main` 병합 뒤 `flutter pub upgrade woody_lints`)와 README 「버전 올리기」 링크를 더했다. 「그 밖의 변경」 은 저장소 안쪽 줄 다섯을 한 줄로 합쳐 불릿 10개를 8개로 줄였다. Phase 1 리뷰 WR-05 는 fixed 로 닫았다.**

## Performance

- **Duration:** 약 3분 (작업 시작 기록 이후. 필수 문서 읽기와 diff 읽기는 그 전)
- **Started:** 2026-10-13T17:35:02Z
- **Completed:** 2026-10-13T17:38Z (KST 2026-10-14)
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- `CHANGELOG.md` 에 `## 1.2.5` ~ `## 1.1.0` 일곱을 `## 1.3.0` 과 `## 1.0.0` 사이에 넣었다 (+51줄).
- `### 올리기 전에` 의 불릿을 2개에서 4개로 늘렸다. 권하는 일(`dart fix --apply` 등)은 이 칸에 적지 않았다.
- `### 그 밖의 변경` 의 불릿을 10개에서 8개로 줄였다. 받는 쪽에 보이는 여섯은 남겼고, 저장소 안쪽 한 줄을 만들었고, 이 phase 의 문서 변경을 새 불릿 하나로 적었다.
- DOCS-07 · DOCS-09 는 확인만 했다. `### 추가한 규칙` 불릿 75 == `### 새로 생기는 경고` 표 행 75 이고, `실측: flutter_starter_kit` 한 줄이 있다. 두 절과 1 ~ 3행은 `fb6386a` 와 같다.

## 복원 항목 — 읽은 커밋과 diff

날짜는 `git log -1 --format=%ad --date=short` 의 값이다. 커밋 메시지는 옮기지 않았다.

| 버전 | 날짜 | 버전 커밋 | 함께 읽은 커밋 | diff 에서 본 것 (적은 것) |
|---|---|---|---|---|
| 1.2.5 | 2026-03-23 | `dbcd20b` | — | `formatter:` 두 줄 · `require_trailing_commas` · `public_member_api_docs` 를 주석 처리했다 (삭제가 아니다) |
| 1.2.4 | 2026-02-27 | `212365d` | `a97fd20` (2026-01-30) | `public_member_api_docs` 추가. `analyzer:` 블록 신설: 옛 방식 `plugins: - riverpod_lint`, `errors: invalid_annotation_target: ignore`, `exclude:` 둘. 템플릿 `# analyzer:` 세 줄 삭제. `.fvmrc` 3.38.9 → 3.41.2, `.vscode/settings.json` 경로 변경. `a97fd20` 은 `.fvmrc` · `.vscode/settings.json` 신설과 `.gitignore` 의 `.fvm/` |
| 1.2.3 | 2026-01-28 | `9451f6b` | `1693a97` (같은 날) | `slash_for_doc_comments` 추가, README 규칙 목록 한 줄. `1693a97` 은 `.gitignore` 의 `.DS_Store` |
| 1.2.2 | 2026-01-03 | `31c8cb1` | `7b7455e` (같은 날) | `pubspec.yaml` 의 버전 숫자만 바뀜. `7b7455e` 은 README 의 의존성 블록 분리와 설치 순서 문구 |
| 1.2.1 | 2025-12-30 | `21c5689` | `9950fd1` (같은 날) | 버전 숫자만 바뀜. `9950fd1` 은 README 의 설치 확인 방법 추가와 포맷터 절을 목록 항목으로 바꾼 것 |
| 1.2.0 | 2025-12-24 | `ec66e3f` | `423936c` (같은 날, README 제목 단계만 — 적지 않음) | `include:` 와 `linter:` 사이에 `formatter:` / `trailing_commas: preserve` 두 줄. README 에 포맷터 절 |
| 1.1.0 | 2025-12-22 | `2249a0b` | `126aa43` (내용), `9bf0d86` (README) | `126aa43`: `include:` 가 `package:lints/recommended.yaml` → `package:flutter_lints/flutter.yaml`, `dev_dependencies` 의 `lints: ^6.0.0` → `flutter_lints: ^6.0.0`. `2249a0b` 는 버전 숫자만. `9bf0d86`: README 에 `flutter pub upgrade woody_lints` 안내 |

### 05-RESEARCH.md § 3 와 다르게 적은 곳

- **1.1.0:** 표에 없는 `9bf0d86` (같은 날 README, `2249a0b` 뒤 · 1.2.0 전)을 diff 로 확인해 한 줄 적었다.
- **1.2.4:** 표는 `a97fd20` 을 "같은 버전의 다른 커밋" 칸에 두었다. 항목의 저장소 안쪽 줄에는 그 커밋의 신설 셋(`.fvmrc` 3.38.9 · `.vscode/settings.json` · `.gitignore` 의 `.fvm/`)과 버전 커밋의 3.41.2 변경을 함께 적었다.
- **1.0.0 (적지 않음, 참고):** 표의 1.0.0 행은 규칙 12개가 "1.3.0 과 같은 이름" 이라고 적었다. 실제 `d98b45a` 에는 `slash_for_doc_comments` 가 없고 `require_trailing_commas` 가 켜져 있었다 (1.2.3 이 앞의 것을 더했고 1.2.5 가 뒤의 것을 주석 처리했다). `## 1.0.0` 항목은 계획대로 건드리지 않았다.
- CONTEXT `<specifics>` 와 다른 곳 넷(1.2.4 의 옛 `plugins:`, `.vscode/settings.json`, 1.1.0 의 `dev_dependencies` 자리, 1.2.2 본문을 옮기지 않음)은 모두 RESEARCH 대로 반영했다.

## 2.0.0 의 두 칸 (결과)

`### 올리기 전에` (불릿 넷):

1. Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다. (그대로)
2. 옛 주소 한 줄을 쓰는 프로젝트는 고칠 것이 없다. … (그대로)
3. 받는 때: `ref: main` 을 따르는 프로젝트는 `main` 에 2.0.0 이 합쳐진 뒤 `flutter pub upgrade woody_lints` 를 하는 순간 받는다. `flutter pub get` 으로는 받지 않고 … (spike 015, 2026-10-12 실측)
4. 올리면서 권하는 일은 README 의 「버전 올리기」 절에 있다 — `[README.md](README.md#버전-올리기)`.

`### 그 밖의 변경` (불릿 10 → 8):

| 순서 | 불릿 | 처리 |
|---|---|---|
| 1 | 프리셋 분리 (`base.yaml` …) | 글자 그대로 |
| 2 | 옛 주소 `package:woody_lints/analysis_options.yaml` 별칭 | 글자 그대로 |
| 3 | `riverpod_lint` 하한 `^3.1.3` → `^3.1.9` | 글자 그대로 |
| 4 | 기반 세트와 겹치는 선언 6개 · 주석 처리된 설정 3개 삭제 | 글자 그대로 |
| 5 | 규칙 근거 문서 `RULES.md` 추가 | 옛 불릿에서 `RULES.md` 쪽만 남김 (`[3/10]` 은 6번 줄로) |
| 6 | 1.3.0 규칙 6개 유지 · 사유 주석 셋 수정 | 글자 그대로 |
| 7 | README 재작성 · 배포 YAML 다섯의 머리 주석 · 1.1.0 ~ 1.2.5 복원 | 새 불릿 |
| 8 | 저장소 안쪽: 연습 프로젝트 여섯 · `tool/verify.dart` · workflow, 루트 분석 설정, `tool/measure_rules.dart` · `tool/measurements/`, 결함 수정 — 사용하는 프로젝트에는 영향 없음 | 옛 90 · 93 · 96 뒷부분 · 97 · 99 를 합침 |

## Task Commits

1. **Task 1: 1.1.0 ~ 1.2.5 복원** — `024a36c` `docs(changelog): 1.1.0 ~ 1.2.5 항목 7개를 git 이력에서 복원 (DOCS-08)` (+51, `CHANGELOG.md` 만)
2. **Task 2 (커밋 2): 2.0.0 두 칸** — `06f62a5` `docs(changelog): 2.0.0 의 올리기 전에에 받는 때를, 그 밖의 변경을 받는 쪽 기준으로 정리 (D-06 · D-07)` (+5 −5, `CHANGELOG.md` 만)
3. **Task 2 (커밋 3): WR-05** — `6abea40` `docs(review): 01 WR-05 를 fixed 로 — CHANGELOG 올리기 전에 가 ref: main 의 받는 때를 적음 (D-06 · D-19)` (`01-REVIEW-DISPOSITION.md` 만)

## `<automated>` 결과

PLAN 에서 `grep '<automated>' | sed -n Np` 로 뽑아 `bash <파일>` 로 돌렸다.

| Task | 그대로 돌린 rc | 고친 사본 rc | 무엇을 왜 고쳤나 |
|------|----------------|--------------|------------------|
| 1 | 0 (커밋 `024a36c` 직후, Task 2 편집 전) | — | — |
| 2 | 0 (커밋 `6abea40` 직후) | — | — |

- 커밋 전에는 커밋 제목 단언(Task 1) · 해시 단언(Task 2)을 뗀 앞부분만 돌려 rc 0 을 봤다.
- Task 1 의 검사를 지금 HEAD 에서 다시 돌리면 실패한다. `## 1.3.0` 위가 `fb6386a` 와 같다는 단언이 Task 2 의 편집 전에만 성립하기 때문이다. 대신 `024a36c` 와 지금의 `## 1.3.0` 아래를 견줬고 같다 (복원 항목은 Task 2 에서 바뀌지 않았다).

## Files Created/Modified

- `CHANGELOG.md` — 복원 항목 7개, 2.0.0 의 `### 올리기 전에` · `### 그 밖의 변경`
- `.planning/phases/01-baseline-and-toolchain/01-REVIEW-DISPOSITION.md` — WR-05 frontmatter `fixed` + `note:`, 표 행, `open: 12`

## Decisions Made

- 복원 항목에 RESEARCH 표에 없던 커밋 둘(`9bf0d86`, `a97fd20`)을 적었다. 둘 다 그 버전 사이에 든 커밋이고 diff 로 확인했다.
- 받는 때의 명령은 README 「버전 올리기」 와 같은 `flutter pub` 꼴로 적었다. spike 015 가 잰 것은 `dart pub` 이고, README 도 같은 근거로 `flutter pub` 을 안내한다.
- 합친 저장소 안쪽 줄에 괄호 둘을 더했다 — 검증 명령의 「배포 파일 구성 · README 검사 단계 포함」과 루트 분석 설정의 「`lib/analysis_options.yaml` 제외를 걷어냄」이다. 옛 불릿의 사실이 합치면서 사라지지 않게 했다.

## Deviations from Plan

None - plan executed exactly as written. 위 "Decisions Made" 의 커밋 둘과 괄호 둘은 PLAN 이 정한 항목 · 줄 안에 더한 사실이다.

## Issues Encountered

None.

## Known Stubs

없음.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-05 (push 전 비공개 훑기): `CHANGELOG.md` · 이 SUMMARY · 세 커밋 메시지의 절대 경로 grep 은 0줄이다. 비공개 사용 프로젝트의 정보는 기존 `실측: flutter_starter_kit …` 한 줄 밖에 더하지 않았다.
- Phase 6: 2.0.0 제목의 `미출시` 는 그대로다. REL-03 은 최상단 제목만 읽으므로 복원 항목에 영향이 없다.
- 01-REVIEW-DISPOSITION 의 남은 open 은 12건이다 (WR-03 그대로).

## Self-Check: PASSED

- `CHANGELOG.md` · `01-REVIEW-DISPOSITION.md` 가 있고, 커밋 `024a36c` · `06f62a5` · `6abea40` 은 HEAD 의 조상이다.
- `git rev-list --count dd7ad0a..6abea40` = 3.

---
*Phase: 05-documentation*
*Completed: 2026-10-14*
