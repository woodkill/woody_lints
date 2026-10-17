---
phase: 02-verification-harness
plan: 03
subsystem: testing
tags: [dart-analyze, verify-script, golden, mutation-check, deprecated-lint, riverpod_lint, changelog, fvm, exit-codes]

# Dependency graph
requires:
  - phase: 02-verification-harness
    provides: "plan 02-02 — 완성된 검증 명령 `tool/verify.dart` (준비 + 단계 4개 + 버전 3줄 + 안내형 화면, 종료 코드 0 / 1 / 64 / 69 / 70 / 78)"
  - phase: 02-verification-harness
    provides: "plan 02-01 — `example/` 연습용 프로젝트와 정답지 (`exit 2` + 16줄), '나오면 안 되는 경고' 샘플 3파일"
  - phase: 01-baseline-and-toolchain
    provides: "불변 비교 기준 `90a2736` (`lib/`) · `968a5bb` (`pubspec.yaml`, `README.md`), 저장소 고정 SDK Flutter 3.47.5 / Dart 3.13.4, CHANGELOG 의 2.0.0 항목과 `VERSIONING.md` 의 칸 순서"
provides:
  - "`example/README.md` — 연습용 프로젝트 설명, 실행·갱신 명령, 파일 역할 표, 정답지 형식, 검증 명령의 종료 코드 표, 지워 보기 9건(M1 ~ M9)의 기록"
  - "지워 보기 9건의 실측 결과 — 실제 저장소에서 변경을 하나씩 만들어 돌린 화면 원문 (이 SUMMARY) 과 표 (`example/README.md`)"
  - "`CHANGELOG.md` 2.0.0 항목의 `### 그 밖의 변경` 칸 (불릿 한 줄)"
affects: [02-04, phase-3-presets, phase-4-rules, phase-5-docs]

# Actuals (#2632)
actuals:
  tokens: 2122     # chars/4 — 계획 시작 커밋부터 task 커밋까지의 diff 에서 더한 줄 + 뺀 줄 8490자. 바뀐 두 파일의 전체 문자 수로 세면 9161자 / 4 = 2290. plan 의 estimate 는 45000 이었다
  tasks: 2
  commits: 1       # MEASURED: git rev-list --count 0dcb71fbdebcae92a12d2bd58da95d0d20e032f8..HEAD (SUMMARY 작성 시점)
plan_head_before: 0dcb71fbdebcae92a12d2bd58da95d0d20e032f8
plan_head_after: 2a9725e18cb1dd14d1e325f5533a0b80b99c0828

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "지워 보기: 변경 하나 → 검증 명령 실행 → 그 파일만 git checkout 으로 되돌림 → git status 확인 → 다음 변경. 둘 이상을 겹치지 않는다"
    - "화면을 기록할 때 stdout 과 stderr 를 따로 받는다 — 함께 받으면 stderr 의 진행 줄이 화면 맨 위에 섞인다"
    - "기록 표의 '정답지와의 차이' 칸은 정답지 줄 형식 그대로, 빠진 줄은 빼기 기호, 남는 줄은 더하기 기호를 앞에 붙인다"

key-files:
  created:
    - example/README.md
  modified:
    - CHANGELOG.md

key-decisions:
  - "지워 보기 9건(M1 ~ M9)을 실제 저장소에서 하나씩 만들어 돌렸고 아홉 건 모두 계획이 예상한 단계와 종료 코드로 실패했다 (Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12). 기록은 example/README.md 의 '검증이 실제로 잡아내는지 확인한 기록' 절이고 변경은 모두 커밋하지 않고 되돌렸다"
  - "example/ 의 include 줄을 지운 변경은 dart analyze 의 종료 코드가 정답지와 같은 2 다 — 같은 상태에서 dart analyze 를 따로 돌려 확인했다. 종료 코드만으로는 잡지 못하고 단계 3(옵션 파일)과 단계 4(정답지 줄 비교)가 잡는다"
  - "deprecated 규칙 unnecessary_await_in_return 을 배포 파일에 넣은 변경은 단계 4(정답지 비교)가 통과하고 단계 2(규칙 이름)만 실패한다 — 두 단계는 서로를 대신하지 못한다"
  - "화면의 plugin 줄은 전용 상태 폴더에 남아 있는 값을 읽는다. include 줄을 지운 실행에서 riverpod_lint 진단이 하나도 없었는데도 3.1.9 가 찍혔다 — 그 줄은 plugin 이 그 실행에서 돌았다는 표시가 아니다"
  - "example/README.md 와 CHANGELOG 의 '그 밖의 변경' 은 GitHub Actions workflow 를 이미 있는 것으로 적는다. workflow 파일은 plan 02-04 가 만든다 — 02-04 가 끝나기 전까지 이 두 문장은 저장소보다 앞서 있다"

patterns-established:
  - "저장소 본문의 기록 절은 첫 줄에 실측 조건(SDK / plugin 버전 / 날짜)을 두고, 실행한 명령과 '되돌렸다' 는 문장을 함께 적는다"
  - "기록에는 재지 않은 것도 적는다 (기반 세트가 켜는 규칙의 삭제, 한 줄만 지운 errors 블록)"

requirements-completed: [VERIFY-08]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "배포 파일에서 이 패키지가 실제로 추가하는 규칙 하나(prefer_final_locals)를 지우면 단계 4 가 실패하고 그 규칙의 줄 하나가 '정답지에는 있는데 나오지 않은 경고' 에 나온다. 종료 코드 1"
    requirement: "VERIFY-08"
    verification:
      - kind: manual_procedural
        ref: "M1 — 배포 파일 30행 삭제 후 검증 명령 실행. 화면 원문은 아래 'M1'. 되돌린 뒤 lib 가 90a2736 과 같고 검증 명령이 다시 종료 코드 0"
        status: pass
    human_judgment: false
  - id: D2
    description: "example/ 옵션 파일의 include 줄을 지우면 단계 3 과 단계 4 가 함께 실패한다 — 빠진 줄 16, 남는 줄 1. dart analyze 의 종료 코드는 2 그대로라 종료 코드만으로는 잡지 못한다"
    requirement: "VERIFY-08"
    verification:
      - kind: manual_procedural
        ref: "M2 — 옵션 파일을 빈 파일로 만든 뒤 검증 명령 실행 (화면 원문은 아래 'M2'). 같은 상태에서 dart analyze 를 따로 돌려 exit 2, 진단 1건을 확인 (아래 'M2 의 종료 코드를 직접 잰 실행')"
        status: pass
    human_judgment: false
  - id: D3
    description: "'나오면 안 되는 경고' 샘플이 헛통과가 아니다 — 배포 파일의 errors 블록, g.dart 제외, freezed.dart 제외를 각각 지우면 그 샘플의 경고가 '정답지에 없는데 나온 경고' 에 나온다"
    requirement: "VERIFY-08"
    verification:
      - kind: manual_procedural
        ref: "M3 · M4 · M5 — 각각 한 가지만 지운 실행 세 번. 화면 원문은 아래. 실행마다 되돌린 뒤 lib 가 90a2736 과 같음"
        status: pass
    human_judgment: false
  - id: D4
    description: "deprecated 규칙을 배포 파일에 넣으면 단계 2 가 실패하고 단계 4 는 통과한다 (VERIFY-02 의 기록용 재현)"
    verification:
      - kind: manual_procedural
        ref: "M6 — 배포 파일 40행 아래에 unnecessary_await_in_return 한 줄 추가. 화면 원문은 아래 'M6'. 실행 뒤 복사본 폴더 없음, 되돌린 뒤 검증 명령 종료 코드 0"
        status: pass
    human_judgment: false
  - id: D5
    description: "lib/ 의 .dart 파일은 단계 1 이 잡고 (종료 코드 1), CI 의 --update 는 준비 단계에서 거부되며 (64), .fvmrc 와 다른 SDK 는 준비 단계에서 거부된다 (78)"
    verification:
      - kind: manual_procedural
        ref: "M7 · M8 · M9 — 화면 원문은 아래. M8 뒤 정답지의 sha1 불변, M9 뒤 .fvmrc 의 sha1 이 원본과 같음"
        status: pass
    human_judgment: false
  - id: D6
    description: "지워 보기의 변경이 하나도 남지 않았다 — lib/ 는 90a2736 과 같고, example/ 옵션 파일은 include 한 줄이며, .fvmrc 는 3.47.5 이고, lib/ 에 .dart 파일이 없고, 복사본 폴더가 없으며, 검증 명령이 종료 코드 0 이다"
    requirement: "VERIFY-08"
    verification:
      - kind: other
        ref: "plan 02-03 Task 1 <automated> verify → rc=0. 아홉 실행 직후, Task 2 커밋 뒤 두 번"
        status: pass
    human_judgment: false
  - id: D7
    description: "example/README.md 에 여섯 제목이 정해진 문자열로 있고, 기록 절에 실측 조건 줄 · 표 헤더 · M1 ~ M9 아홉 행 · '커밋하지 않고 되돌렸다' 가 있으며, 종료 코드 표에 여섯 행이 있고, 로컬 절대 경로와 토큰이 없다"
    requirement: "VERIFY-08"
    verification:
      - kind: other
        ref: "plan 02-03 Task 2 <automated> verify → rc=0. 커밋 전, 커밋 뒤 두 번"
        status: pass
    human_judgment: false
  - id: D8
    description: "example/README.md 의 기록 절이 읽힌다 — 표만 보고 (1) 규칙 하나를 지우면 어느 줄이 빠지는지 (2) include 를 지우면 16줄이 사라지는 대신 다른 warning 이 나타나 종료 코드가 그대로라는 점 (3) deprecated 규칙은 규칙 이름 검사가 잡는다는 점을 안다"
    requirement: "VERIFY-08"
    verification: []
    human_judgment: true
    rationale: "기록의 존재와 문자열은 자동으로 확인했지만 '몇 달 뒤 이 절만 보고 검증이 무엇을 잡고 무엇을 못 잡는지 아는가' 는 독자(소유자)의 판단이다 (plan 의 human-check)"
  - id: D9
    description: "CHANGELOG 2.0.0 항목에 '그 밖의 변경' 칸이 '올리기 전에' 와 '새로 생기는 경고' 사이에 있고, 삼단 제목은 정확히 3개이며, 1.3.0 / 1.0.0 항목은 90a2736 과 글자 그대로 같다"
    verification:
      - kind: other
        ref: "plan 02-03 Task 2 <automated> verify 의 CHANGELOG 부분 → rc=0"
        status: pass
    human_judgment: false
  - id: D10
    description: "CHANGELOG 와 example/README.md 가 말하는 GitHub Actions workflow 가 저장소에 실제로 있다"
    verification: []
    human_judgment: true
    rationale: "이 plan 이 끝난 시점에 workflow 파일은 없다 (.github 폴더 없음). 계획이 같은 phase 의 plan 02-04 에 맡긴 것이고, 02-04 의 verify 가 파일의 존재로 뒷받침한다. 02-04 가 끝나기 전에는 참이 아니다"

# Metrics
duration: 7min
completed: 2026-10-12
status: complete
---

# Phase 2 Plan 03: 지워 보기 9건의 기록과 CHANGELOG 한 칸 Summary

**배포 파일과 `example/` 에 틀린 상태를 하나씩 일부러 만들어 검증 명령이 아홉 번 모두 예상한 단계에서 실패하는 것을 실제 저장소에서 확인했고, 그 결과를 `example/README.md` 에 표로 남겼다**

쉬운 말로: 자동 점검이 "통과" 만 내면 점검을 안 하는 것과 구별이 안 된다. 그래서 일부러 틀리게 만든 아홉 가지를 하나씩 돌려 점검이 정말 "실패" 를 내는지 봤다. 아홉 가지 모두 실패를 냈고, 틀리게 만든 것은 전부 원래대로 돌려놓았다.

## Performance

- **Duration:** 7 min (시작 → Task 2 커밋과 커밋 뒤 재확인까지. SUMMARY 작성과 상태 갱신 시간은 넣지 않았다)
- **Started:** 2026-10-11T16:46:10Z (한국 시각 2026-10-12 01:46)
- **Completed:** 2026-10-11T16:53:41Z
- **Tasks:** 2
- **Files modified:** 2 (새 파일 `example/README.md` 137줄, `CHANGELOG.md` 4줄 추가)
- **실행 위치:** 본 작업 폴더의 `gsd/v2.0-package-rework` 브랜치 (worktree 아님)
- **검증 명령 한 번의 시간:** 약 5초 (plugin 이 이미 준비된 상태, 초 단위 시계의 차)

## Accomplishments

- 지워 보기 9건을 실제 저장소에서 하나씩 만들어 돌렸다. **아홉 건 모두 계획이 예상한 단계와 종료 코드로 실패했다** — 예상과 다른 결과는 없었다.
- include 줄을 지운 변경(M2)에서 `dart analyze` 의 종료 코드가 2 그대로라는 것을 화면에서 읽은 데 더해, 같은 상태에서 따로 돌려 직접 쟀다.
- `example/README.md` 를 만들었다 — 이 폴더가 무엇인지, 어떻게 돌리고 갱신하는지, 파일마다 정답지 몇 줄을 맡는지, 종료 코드의 뜻, 그리고 아홉 건의 기록.
- `CHANGELOG.md` 의 2.0.0 항목에 `### 그 밖의 변경` 한 칸을 더했다. 다른 줄은 건드리지 않았다.
- 임시 변경은 하나도 남지 않았다. `lib/`, `pubspec.yaml`, 루트 `README.md`, `.fvmrc`, `tool/verify.dart`, `example/` 의 기존 파일은 그대로다. push 와 tag 는 하지 않았다.

## Task Commits

1. **Task 1: 지워 보기 9건** — task 커밋 없음 (계획의 커밋 계약대로 — 추적 파일 변경 0)
2. **Task 2: `example/README.md` 와 CHANGELOG** — `2a9725e` (docs) — `CHANGELOG.md`, `example/README.md`

커밋에 삭제된 파일이 없다.

**Plan metadata:** 이 SUMMARY 와 STATE / ROADMAP / REQUIREMENTS 를 담는 `docs(02-03)` 커밋 (이 파일을 쓴 직후에 만든다)

## (1) 지워 보기 9건 — 결과 표

실측 조건: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12, macOS arm64.

| # | 변경 | 실패한 단계 | 빠진 줄 / 남는 줄 | 종료 코드 | 시간 | 계획의 예상과 같은가 |
|---|------|-------------|-------------------|-----------|------|----------------------|
| M1 | 배포 파일 30행 (prefer_final_locals) 삭제 | 4 | 빠진 줄 1, 남는 줄 0 | 1 | 5초 | 같다 |
| M2 | example 옵션 파일을 빈 파일로 | 3 과 4 | 빠진 줄 16, 남는 줄 1 | 1 | 2초 | 같다 |
| M3 | 배포 파일 43-44행 (errors 블록 두 줄) 삭제 | 4 | 빠진 줄 0, 남는 줄 1 | 1 | 5초 | 같다 |
| M4 | 배포 파일 47행 (g.dart 제외) 삭제 | 4 | 빠진 줄 0, 남는 줄 2 | 1 | 5초 | 같다 |
| M5 | 배포 파일 46행 (freezed.dart 제외) 삭제 | 4 | 빠진 줄 0, 남는 줄 2 | 1 | 5초 | 같다 |
| M6 | 배포 파일 40행 아래에 deprecated 규칙 한 줄 추가 | 2 (4 는 통과) | 정답지와 같다. 단계 2 가 deprecated_lint 한 줄 | 1 | 5초 | 같다 |
| M7 | lib 아래에 빈 probe .dart 파일 생성 | 1 | 정답지와 같다. 단계 1 이 경로 한 줄 | 1 | 5초 | 같다 |
| M8 | 변경 없이 CI=true 로 --update | 단계에 이르지 않음 | 해당 없음 (stdout 0바이트) | 64 | 1초 미만 | 같다 |
| M9 | .fvmrc 의 flutter 값을 0.0.0 으로 | 단계에 이르지 않음 | 해당 없음 (stdout 0바이트) | 78 | 1초 미만 | 같다 |

- 시간은 초 단위 시계(`date +%s`)의 차다. 0 으로 나온 것을 "1초 미만" 으로 적었다.
- 아홉 실행 모두 stderr 에 plugin 준비 실패의 머리말이 없었고, D-15 의 멈춤 조건(변경을 만들었는데 단계 4 가 통과하고 M6 도 아님)에 해당한 실행도 없었다.
- **M9 는 FVM 이 저장소에 링크해 둔 SDK 의 dart 로 직접 돌렸다** (`fvm spawn` 은 쓰지 않았다). 명령은 아래 M9 의 블록에 있다.

## (2) 화면 원문

stdout 과 stderr 를 따로 받았다. 아래 블록의 화면은 stdout 이고, M1 ~ M7 의 stderr 는 모두 진행 표시 한 줄(`example/ 분석 중…`)뿐이었다. 화면에 저장소 절대 경로는 한 번도 나오지 않았다 (가릴 것이 없었다).

### M1 — 규칙 하나를 지운 변경 (VERIFY-08)

```text
변경:
-    - prefer_final_locals # 데이터의 불변성 보장

$ fvm dart run tool/verify.dart
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

정답지에는 있는데 나오지 않은 경고 (1)
  lib/added_rules.dart:24  info  prefer_final_locals

정답지에 없는데 나온 경고 (0)

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 1개)

(종료 코드 1, 5초)
```

plan 02-02 Task 2 의 human-check 가 요구한 실패 화면이 이것이다. 02-02 는 그 줄을 주석 처리해서 봤고 여기서는 줄을 지워서 봤다 — 화면은 글자 그대로 같다.

### M2 — include 줄을 지운 변경 (VERIFY-08)

```text
변경:
-include: package:woody_lints/analysis_options.yaml
(옵션 파일 0바이트)

$ fvm dart run tool/verify.dart
SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 실패
[4/4] example/ 정답지 비교 ............. 실패

`example/analysis_options.yaml` 이 include 한 줄이 아니다 — 주석·빈 줄을 뺀 내용 (0줄):
  (없음)

`example/analysis_options.yaml` 을 include 한 줄로 되돌린다:
  include: package:woody_lints/analysis_options.yaml
`flutter pub get` 을 돌렸다면: git checkout -- example/analysis_options.yaml

정답지에는 있는데 나오지 않은 경고 (16)
  lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
  lib/added_rules.dart:18  info  always_declare_return_types
  lib/added_rules.dart:24  info  prefer_final_locals
  lib/added_rules.dart:29  info  prefer_single_quotes
  lib/added_rules.dart:33  info  unawaited_futures
  lib/added_rules.dart:7  info  prefer_const_constructors
  lib/base_rules.dart:12  info  sort_child_properties_last
  lib/base_rules.dart:17  info  use_build_context_synchronously
  lib/base_rules.dart:22  info  avoid_print
  lib/base_rules.dart:30  info  control_flow_in_finally
  lib/base_rules.dart:34  info  slash_for_doc_comments
  lib/base_rules.dart:38  info  prefer_is_empty
  lib/base_rules.dart:8  info  sized_box_for_whitespace
  lib/main.dart:5  warning  missing_provider_scope
  lib/riverpod_rules.dart:17  warning  provider_parameters
  lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties

정답지에 없는데 나온 경고 (1)
  lib/should_not_appear.dart:5  warning  invalid_annotation_target

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 2개)

(종료 코드 1, 2초)
```

**종료 코드만으로는 못 잡는다.** 화면에 `종료 코드: 정답지 N, 실제 M` 줄이 없다 — 스크립트는 둘이 다를 때만 그 줄을 찍으므로 실제 `dart analyze` 의 종료 코드가 정답지의 2 와 같았다는 뜻이다. 이것은 화면에서 읽은 추론이라, 아래에서 따로 쟀다.

이 실행에서 눈에 띈 것 하나: `plugin` 줄이 `riverpod_lint 3.1.9` 로 찍혔다. 그런데 riverpod_lint 의 경고 3줄은 빠진 16줄 안에 있다. 그 줄은 전용 상태 폴더에 남아 있는 값을 읽는 것이라, plugin 이 이 실행에서 돌았다는 표시가 아니다. 실행 시간이 2초로 짧은 것도 같은 쪽을 가리키지만, plugin 이 뜨지 않았다는 것 자체를 따로 확인하지는 않았다.

### M2 의 종료 코드를 직접 잰 실행 (계획에 없던 확인)

M2 를 되돌리고 깨끗한 것을 확인한 뒤, 같은 변경을 한 번 더 만들어 스크립트가 쓰는 것과 같은 꼴의 `dart analyze` 를 `example/` 에서 따로 돌렸다 (같은 SDK 의 dart, 같은 전용 상태 폴더).

```text
$ (example/ 에서) ANALYZER_STATE_LOCATION_OVERRIDE=<repo>/.dart_tool/woody_verify/example dart --suppress-analytics analyze --format=json
exit=2
stderr 0바이트
진단 1건:
  lib/should_not_appear.dart:5  WARNING  invalid_annotation_target
```

정답지의 `exit 2` 와 실제 종료 코드가 둘 다 2 다. include 가 사라져 경고 16줄이 없어졌는데도 종료 코드는 같다.

### M3 — errors 블록을 지운 변경 (D-03, annotation 샘플)

```text
변경:
-  errors:
-    invalid_annotation_target: ignore

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

정답지에는 있는데 나오지 않은 경고 (0)

정답지에 없는데 나온 경고 (1)
  lib/should_not_appear.dart:5  warning  invalid_annotation_target

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 1개)

(종료 코드 1, 5초. 버전 3줄은 M1 과 같다)
```

블록째 지웠다 (Pitfall 5). 한 줄만 지운 경우(`included_file_warning` 이 섞인다는 조사 문서의 실측)는 다시 재지 않았다.

### M4 — g.dart 제외를 지운 변경 (D-03, 생성 파일 샘플)

```text
변경:
-    - '**/*.g.dart'

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

정답지에는 있는데 나오지 않은 경고 (0)

정답지에 없는데 나온 경고 (2)
  lib/generated/sample.g.dart:4  info  avoid_print
  lib/generated/sample.g.dart:4  info  prefer_single_quotes

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 1개)

(종료 코드 1, 5초. 버전 3줄은 M1 과 같다)
```

### M5 — freezed.dart 제외를 지운 변경 (D-03, 생성 파일 샘플)

```text
변경:
-    - '**/*.freezed.dart'

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 실패

정답지에는 있는데 나오지 않은 경고 (0)

정답지에 없는데 나온 경고 (2)
  lib/generated/sample.freezed.dart:4  info  avoid_print
  lib/generated/sample.freezed.dart:4  info  prefer_single_quotes

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (4개 중 1개)

(종료 코드 1, 5초. 버전 3줄은 M1 과 같다)
```

### M6 — deprecated 규칙을 넣은 변경 (VERIFY-02 의 재현)

```text
변경 (40행 control_flow_in_finally 바로 아래):
+    - unnecessary_await_in_return

[1/4] lib/ 에 .dart 파일 없음 .......... 통과
[2/4] 배포 파일의 규칙 이름 ............ 실패
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

배포 파일에 쓸 수 없는 규칙이 있다 (1)
  build/woody_rule_check/analysis_options.yaml:41  warning  deprecated_lint  (unnecessary_await_in_return)

`lib/analysis_options.yaml` 에서 그 규칙을 지우거나 바꾼다 (복사본의 줄 번호는 원본과 같다).

점검 실패 (4개 중 1개)

(종료 코드 1, 5초. 버전 3줄은 M1 과 같다)
```

정답지 비교는 통과했고 규칙 이름 단계만 실패했다 — 계획이 "분담의 증거" 라고 부른 모양 그대로다. 실패 줄 끝의 괄호 안 규칙 이름은 02-02 가 미리 알려 준 대로다. 실행 뒤 복사본 폴더와 그 부모 폴더(build)는 남지 않았다.

### M7 — lib 에 .dart 파일을 둔 변경 (VERIFY-07)

```text
변경: lib 아래에 0바이트 파일 _probe.dart 를 만듦

[1/4] lib/ 에 .dart 파일 없음 .......... 실패
[2/4] 배포 파일의 규칙 이름 ............ 통과
[3/4] example/ 옵션 파일 ............... 통과
[4/4] example/ 정답지 비교 ............. 통과

lib/ 에 .dart 파일이 있다 (1)
  lib/_probe.dart

`lib/` 에는 YAML 만 둔다 — 스크립트는 `tool/`, 연습용 코드는 `example/` 에 둔다.

점검 실패 (4개 중 1개)

(종료 코드 1, 5초. 버전 3줄은 M1 과 같다)
```

### M8 — CI 에서의 --update (D-14)

```text
$ CI=true fvm dart run tool/verify.dart --update
(stdout 0바이트)
stderr:
CI 에서는 --update 를 쓰지 않는다 — 로컬에서 갱신해 커밋하세요.

(종료 코드 64, 1초 미만)
```

실행 앞뒤로 정답지의 sha1 이 같다 (`164b31c2…`). `GITHUB_ACTIONS=true` 쪽은 이 plan 에서 돌리지 않았다 (02-02 가 봤다).

### M9 — .fvmrc 와 다른 SDK (D-12)

```text
변경:
-  "flutter": "3.47.5"
+  "flutter": "0.0.0"

$ .fvm/flutter_sdk/bin/dart run tool/verify.dart
(stdout 0바이트)
stderr:
실행 중인 SDK 는 Flutter 3.47.5 인데 .fvmrc 는 0.0.0 다.
저장소 루트에서 `fvm dart run tool/verify.dart` 로 실행하세요.

(종료 코드 78, 1초 미만)
```

## (3) 되돌림 확인

변경마다 실행 직후 그 파일만 되돌리고(추적 파일은 그 경로 하나에 `git checkout --`, probe 파일은 `rm`) 확인한 뒤에 다음 변경을 만들었다. 둘을 겹친 적이 없다. 작업 트리 전체를 건드리는 명령(`git checkout .`, `git restore .`, `git reset --hard`, `git stash`, `git clean`)은 쓰지 않았다.

| # | 되돌린 방법 | 직후의 확인 |
|---|-------------|-------------|
| M1 | 배포 파일 경로에 git checkout | 그 경로의 `git status --short` 가 비어 있음, lib 가 90a2736 과 같음, sha1 `9767b846…`, 검증 명령 종료 코드 0 |
| M2 | example 옵션 파일 경로에 git checkout | 그 경로의 status 가 비어 있음, sha1 `923b0448…`, 정답지와 lock 의 sha1 불변, 검증 명령 종료 코드 0 |
| M2 재측정 | 같은 경로에 git checkout | example 전체의 status 가 비어 있음 (untracked 포함), sha1 `923b0448…` |
| M3 | 배포 파일 경로에 git checkout | status 가 비어 있음, lib 가 90a2736 과 같음, sha1 `9767b846…` |
| M4 | 위와 같음 | 위와 같음 |
| M5 | 위와 같음 | 위와 같음 |
| M6 | 위와 같음 | 위와 같음 + build 폴더 없음, 검증 명령 종료 코드 0 |
| M7 | probe 파일을 rm | lib 의 status 가 비어 있음 (untracked 포함), lib 의 .dart 0개, lib 가 90a2736 과 같음 |
| M8 | 변경 없음 | 실행 앞뒤의 status 가 비어 있음, 정답지의 sha1 불변 |
| M9 | .fvmrc 경로에 git checkout | status 가 비어 있음, sha1 `26de9899…` (원본과 같음) |

끝의 전체 확인 (아홉 실행 뒤, Task 2 를 시작하기 전):

```text
$ git status --short --untracked-files=all -- lib example .fvmrc analysis_options.yaml .gitignore tool
(출력 없음)
$ test -e build/woody_rule_check   → 없음
$ test -e lib/_probe.dart          → 없음
$ fvm dart run tool/verify.dart    → 점검 통과 (4개 중 4개), 종료 코드 0
Task 1 <automated> verify          → rc=0

$ git status --short          (물려받은 네 항목뿐이다)
 M .planning/config.json
?? .planning/milestone.lock
?? .planning/research/.cache/
?? .planning/state.json
```

`.planning/` 의 네 항목은 물려받은 것이다 (스테이징 · 커밋 · 되돌리기 · 삭제 어느 것도 하지 않았다).

## (4) 기대(RESEARCH 권고 3)와 다른 결과가 있었는가

**없었다.** 실패한 단계, 빠진 줄 / 남는 줄의 개수와 문자열, 종료 코드가 아홉 건 모두 계획의 표와 같다. 조사 문서의 복사본 실측과 견줘 다른 점은 값이 아니라 부수적인 것 둘이다.

- M2 의 시간: 조사 문서는 0.8초(`dart analyze` 한 번), 여기서는 2초(검증 명령 전체 — 준비와 단계 넷).
- M6 의 실패 줄 끝에 규칙 이름이 괄호로 붙는다 (02-02 가 더한 것, 계획의 예상 문자열 뒤에 온다).

검증 명령이 잡지 못한 변경은 없었다. `tool/verify.dart` 는 고치지 않았다.

## Files Created/Modified

- `example/README.md` (새 파일, 137줄) — 절 여섯 개: 제목과 소개 / 실행 / 파일 / 정답지 형식 / 검증 명령의 종료 코드 / 검증이 실제로 잡아내는지 확인한 기록
- `CHANGELOG.md` — 2.0.0 항목에 4줄 추가 (`### 그 밖의 변경` 제목, 빈 줄, 불릿 한 줄, 빈 줄)

## Decisions Made

- **화면을 stdout 과 stderr 로 따로 받았다.** 계획의 명령은 둘을 한 파일로 받는 꼴이었지만, 02-02 가 남긴 대로 함께 받으면 stderr 의 진행 줄이 화면 맨 위에 섞인다. 따로 받은 뒤 계획이 말한 이름의 파일(m1 ~ m9 의 out)로도 합쳐 두었다 (scratchpad, 저장소 밖).
- **M2 의 종료 코드를 따로 쟀다.** "종료 코드만으로는 못 잡는다" 가 이 plan 의 핵심 문장인데 화면만으로는 `종료 코드:` 줄이 **없다**는 데서 읽어 내는 추론이었다. 같은 변경을 한 번 더 만들어 `dart analyze` 의 종료 코드 2 를 직접 봤다. 변경은 그때도 하나였고 바로 되돌렸다.
- **README 의 종료 코드 표는 두 칸이다** (종료 코드 / 뜻). 02-02 의 표에 있던 셋째 칸("이 plan 에서 실제로 본 것")은 그 plan 의 기록이라 옮기지 않았다. 뜻의 문구는 02-02 그대로다.
- **README 의 파일 표에 두 행을 더했다** (옵션 파일, pubspec). 계획이 든 파일만으로는 폴더의 파일 목록이 완성되지 않아서다.
- **README 의 기록 절에 계획이 요구하지 않은 문장 넷을 더했다:** M3 ~ M5 가 무엇의 확인인지, M3 을 블록째 지운 이유, `plugin` 줄이 plugin 이 돌았다는 표시가 아니라는 점, 이 기록이 재지 않은 것. 그리고 항목 번호(VERIFY-NN, D-NN)가 어느 문서의 것인지 한 줄.
- **실측 날짜는 로컬 날짜 2026-10-12 로 적었다.** 정답지 머리 주석이 쓰는 날짜와 같은 기준이다 (UTC 로는 2026-10-11).

## Deviations from Plan

### Auto-fixed Issues

없음 — Rule 1 ~ 3 으로 고친 것이 없다. 계획의 문구와 다르게 한 작은 것들은 위 Decisions Made 에 적었다 (출력을 받는 방법, M2 의 추가 측정, README 에 더한 행과 문장).

---

**Total deviations:** 0 auto-fixed
**Impact on plan:** 범위를 넘은 변경은 없다. M2 의 추가 측정은 기록의 핵심 문장을 추론이 아닌 측정으로 바꾼 것이고 저장소에 남긴 것이 없다.

## Issues Encountered

없음. 아홉 실행이 모두 한 번에 예상대로 나왔고 두 task 의 `<automated>` verify 가 첫 실행에서 통과했다.

## 돌린 것과 돌리지 않은 것

**돌렸다 (출력은 위에 있다):** 시작 전의 통과 실행, M1 ~ M9, M2 의 종료 코드 재측정, M1 · M2 · M6 뒤의 통과 확인, 두 task 의 `<automated>` verify (Task 2 는 커밋 전과 뒤, Task 1 은 아홉 실행 직후와 커밋 뒤), 루트 `fvm dart analyze` (No issues found).

**돌리지 않았다:**

- **`invalid_annotation_target: ignore` 한 줄만 지운 변경** — 조사 문서의 복사본 실측(`included_file_warning` 이 하나 더 섞인다)에 기댔다. README 에도 "다시 재지 않았다" 고 적었다.
- **기반 세트가 이미 켜는 규칙(예: avoid_print)을 지운 변경** — 계획이 재지 않기로 한 것이다 (D-01 의 추론, Phase 4 에서 확인). README 에 적었다.
- **`GITHUB_ACTIONS=true` 로의 `--update`** — 02-02 가 봤다. 이 plan 은 `CI=true` 만 돌렸다.
- **`fvm spawn` 으로의 M9** — 링크된 SDK 의 dart 가 있어 필요하지 않았다.
- **README 가 "사전 실측" 이라고 적은 두 가지** — 처음 실행의 약 15초와, 네트워크가 끊기면 plugin 경고 없이 끝난다는 것. 이 plan 에서 다시 재지 않았고 spike 의 기록을 옮겼다.
- **M2 에서 plugin 이 실제로 뜨지 않았는지** — riverpod_lint 진단 0건과 짧은 실행 시간만 봤다.
- **human-check 의 판단** — 기록 절이 읽히는지는 소유자의 몫이다. 설정이 `human_verify_mode: end-of-phase` 라 checkpoint 로 멈추지 않았다.
- **push 와 tag** — 하지 않았다.

## Threat Model 대응

| Threat ID | 처리 |
|---|---|
| T-02-07 (mitigate, high) | 변경마다 그 경로만 되돌리고 status 를 확인했다 (위 (3) 의 표). Task 1 verify 가 lib 가 90a2736 과 같음 · include 한 줄 · `.fvmrc` 값 · status 청결 · lib 의 .dart 0건 · 복사본 폴더 부재를 증명했다 (rc=0, 두 번). Task 1 의 task 커밋은 없다. Task 2 커밋에 든 파일은 README 와 CHANGELOG 둘뿐이다 |
| T-02-08 (mitigate, medium) | 화면 출력에 절대 경로가 없었다. `example/README.md` 와 `CHANGELOG.md` 에 홈 폴더 경로 · 토큰 접두사 · 세션 주소 · 다른 프로젝트 이름 · 이메일이 없다 (`grep -n` 0건, Task 2 verify 의 두 단언 포함). M2 재측정의 JSON 원문에는 절대 경로가 있어 이 SUMMARY 에는 정리한 줄만 옮겼다 |
| T-02-SC (accept) | 패키지를 설치하지 않았다. 스크립트의 pub get 은 lock 그대로다 (실행 뒤 lock 의 sha1 `ae950cd2…` 불변) |

계획의 threat model 에 없는 새 표면(네트워크 endpoint, 인증 경로, 신뢰 경계의 스키마 변경)은 만들지 않았다.

## Known Stubs

없음. 바뀐 두 파일에 `TODO` / `FIXME` / 자리 표시가 새로 생기지 않았다 (`grep -n -iE` 0건). CHANGELOG 의 `(Phase 4 실측 후 채움)` 은 Phase 1 이 둔 자리 표시이고 계획이 건드리지 말라고 한 줄이다. 건너뛴 테스트와 돌리지 않은 `<verify>` 가 없어 `.planning/WINDOWS.md` 에 더한 항목이 없다.

다만 stub 은 아니어도 **저장소보다 앞선 문장이 둘 있다** — 아래 Next Phase Readiness 의 첫 항목.

## User Setup Required

None - 외부 서비스 설정이 필요 없다.

## Next Phase Readiness

**plan 02-04 가 이어받을 것:**

- **`CHANGELOG.md` 의 "GitHub Actions workflow 를 추가" 와 `example/README.md` 의 "CI 에서는 FVM 없이 … 로 돌린다. SDK 는 `.fvmrc` 의 버전으로 맞춘다" 는 지금은 참이 아니다.** 저장소에 `.github` 폴더가 없다. 계획이 02-04 에 맡긴 것이고 02-04 가 workflow 를 만들면 참이 된다. 02-04 가 workflow 의 실행 명령이나 SDK 를 맞추는 방법을 다르게 정하면 README 의 그 두 문장을 함께 고쳐야 한다.
- 검증 명령은 지금 종료 코드 0 이고 `점검 통과 (4개 중 4개)` 다. 02-04 가 올릴 브랜치에 임시 변경은 없다.
- `example/README.md` 는 공개 저장소에 올라갈 파일이다. 절대 경로 · 토큰 · 세션 주소 · 다른 프로젝트 이름이 없음을 확인했다. `.planning/` 의 두 문서 경로(REQUIREMENTS, 02-CONTEXT)를 가리키는 한 줄이 있다 — D-08 에 따라 `.planning/` 도 함께 올라가므로 끊긴 링크가 아니다.

**Phase 3 · 4 가 이어받을 것:**

- include 가 통째로 사라지는 사고는 종료 코드로는 보이지 않는다 (2 그대로). 프리셋을 나눈 뒤에도 판정은 줄 단위 비교에 기댄다.
- 화면의 `plugin` 줄은 plugin 이 그 실행에서 돌았다는 증거가 아니다. plugin 이 빠졌는지는 정답지의 riverpod_lint 줄(3줄)이 빠지는지로 본다. Phase 3 가 fixture 를 더하면서 이 줄의 뜻을 다시 볼 만하다.
- 기반 세트가 켜는 규칙을 배포 파일에서 지웠을 때 정답지가 그대로인지는 아직 아무도 재지 않았다 (Phase 4 의 중복 선언 정리 때 처음 확인된다).
- 샘플 파일의 줄 번호가 README 의 표와 M2 의 블록에 그대로 적혀 있다. Phase 3 · 4 에서 샘플이나 정답지를 고치면 README 의 기록 절은 "2026-10-12 의 기록" 으로 남는다 — 고쳐 쓸 대상이 아니라 그때의 실측이다.

**요구사항:** `VERIFY-08` 을 이 plan 이 선언했다.

**blocker:** 없음.

## Self-Check: PASSED

- 만든 파일과 고친 파일, 이 SUMMARY 가 디스크에 있다 (`[ -f … ]` → 전부 FOUND): `example/README.md`, `CHANGELOG.md`.
- 커밋 `2a9725e` 가 HEAD 의 조상이다 (`git merge-base --is-ancestor` → FOUND).
- `gsd-tools check evaluation-scope --plan 02-03 --commits-only` → `status: resolved`, commits 1개 (이 브랜치). `git rev-list --count` 로 잰 값도 1 이다.
- 두 task 의 `<automated>` verify 를 Task 2 커밋 뒤에 처음부터 다시 돌려 둘 다 rc=0.
- plan 의 `<verification>` 과 `<success_criteria>` — 지워 보기 9건의 결과가 SUMMARY (원문) 와 README (표) 에 있음, lib 가 90a2736 과 같음, example 옵션 파일이 include 한 줄, `.fvmrc` 가 3.47.5, lib 의 .dart 0건, 검증 명령 종료 코드 0, CHANGELOG 에 `### 그 밖의 변경` 한 칸과 옛 항목 불변, `docs(02-03):` task 커밋 1개, push 없음 — 을 모두 확인했다.
- `gsd-tools verify-summary` → `passed: true`, Missing files 0건.
- `git status --short` 에 이 plan 의 파일이 남아 있지 않다 (물려받은 `.planning/` 네 항목뿐).

---
*Phase: 02-verification-harness*
*Completed: 2026-10-12*
