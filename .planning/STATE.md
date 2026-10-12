---
gsd_state_version: "1.0"
milestone: v2.0
milestone_name: Package Rework
current_phase: 04
current_phase_name: Rule Reselection
status: executing
stopped_at: Completed 04-01-PLAN.md
last_updated: "2026-10-12T23:22:48.161Z"
last_activity: 2026-10-13
last_activity_desc: Phase 04 execution started
state_head: 33f8781fe17e841b6daf2acb52a0e0d4319af39b
progress:
  total_phases: 6
  completed_phases: 3
  total_plans: 23
  completed_plans: 14
  percent: 50
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-12)

**Core value:** 사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.
**Current focus:** Phase 04 — Rule Reselection

## Current Position

Phase: 04 (Rule Reselection) — EXECUTING
Plan: 2 of 10
Status: Ready to execute
Last activity: 2026-10-13 — Phase 04 execution started

Progress: [█████░░░░░] 50%

## Performance Metrics

**Velocity:**
- Total plans completed: 13
- Average duration: - min
- Total execution time: 0.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 4 | - | - |
| 2 | 5 | - | - |
| 3 | 4 | - | - |

**Recent Trend:**
- Last 5 plans: -
- Trend: -

*Updated after each plan completion*
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 01 P01 | 7 min | 3 tasks | 0 files |
| Phase 01 P02 | 6 min | 2 tasks | 1 files |
| Phase 01 P03 | 4 min | 3 tasks | 4 files |
| Phase 01 P04 | 3 min | 2 tasks | 3 files |
| Phase 02 P01 | 8 min | 2 tasks | 14 files |
| Phase 02 P02 | 15 min | 2 tasks | 2 files |
| Phase 02 P03 | 7 min | 2 tasks | 2 files |
| Phase 02 P04 | 7 min | 2 tasks | 1 files |
| Phase 02 P05 | 9 min | 3 tasks | 4 files |
| Phase 03 P01 | 5 min | 2 tasks | 2 files |
| Phase 03 P02 | 4 min | 2 tasks | 9 files |
| Phase 03 P03 | 17 min | 3 tasks | 64 files |
| Phase 03 P04 | 18 min | 3 tasks | 4 files |
| Phase 04 P01 | 15min | 2 tasks | 11 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Pre-roadmap]: 묶음의 정식 이름은 `recommended.yaml` 이고, 옛 URI `analysis_options.yaml` 은 이를 include 하는 별칭이다 (기본 + Riverpod + codegen 의미 유지)
- [Pre-roadmap]: 기본 규칙 조각 파일의 이름은 `base.yaml` 이다
- [Pre-roadmap]: `lib/` 와 `pubspec.yaml` 변경은 milestone 브랜치에 쌓고 릴리스 때만 `main` 에 합친다
- [Pre-roadmap]: 검증 판정은 기대 진단 비교(golden comparison)가 주 수단이다
- [Roadmap]: 구조 변경(Phase 3)과 내용 변경(Phase 4)을 섞지 않고, 하네스(Phase 2)를 둘보다 먼저 세운다
- [Roadmap]: GSD 자동 tag(`git.create_tag`)를 끄고 마일스톤 번호를 `v2.0` 으로 맞췄다. `v` tag 는 패키지 릴리스에만 쓴다
- [Phase 01]: v1.3.0 annotated tag 를 90a2736 에 붙여 origin 에 올렸다 (소유자 응답 push, 2026-10-11T04:25:38Z). 이 tag 는 옮기거나 지우지 않는다 — 잘못이 발견되면 새 이름(v1.3.1 등)을 쓴다
- [Phase 01]: Phase 1 에서 origin 에 올린 것은 tag v1.3.0 하나다. 브랜치 gsd/v2.0-package-rework 와 .planning/ 은 원격에 없다
- [Phase 01]: 버전 정책과 CHANGELOG 항목 형식의 기준 문서는 저장소 루트 `VERSIONING.md` 다. 다음 릴리스는 2.0.0 이다 — 이번 릴리스의 가장 큰 등급이 SDK 하한 상향(major)이다
- [Phase 01]: `VERSIONING.md` 의 절 제목 넷(`## 판정 순서` / `## 기준표` / `## 실제 사례` / `## CHANGELOG 항목 형식`)과 CHANGELOG 형식 문자열은 검증 명령과 뒤 phase 가 읽는 고정 문자열이다. 바꾸려면 검증 명령도 함께 바꾼다
- [Phase 01]: 저장소 고정 SDK 는 Flutter 3.47.5 / Dart 3.13.4 다 (`.fvmrc`, `.vscode/settings.json`). 이후 검증과 실측은 `fvm dart …` 로 이 SDK 위에서 돈다
- [Phase 01]: milestone 브랜치의 `pubspec.yaml` 은 `sdk: ^3.13.0` / `version: 2.0.0-dev` 다. 릴리스 때 `-dev` 를 뗀다 (Phase 6). `main` 과 origin 은 1.3.0 그대로이고 이 변경은 어디에도 push 하지 않았다
- [Phase 01]: `CHANGELOG.md` 의 `## 2.0.0 - 미출시` 항목이 만들어졌다. 이후 phase 는 자기 변경을 이 항목에 적고, `### 새로 생기는 경고` 의 자리 표시 `(Phase 4 실측 후 채움)` 은 Phase 4 가 실측 표로 바꾼다
- [Phase 01]: `VERSIONING.md` 판정 순서 1번은 세 조건이다 — 설정 파일·SDK 를 고쳐야 하나 / `flutter_lints` 나 `riverpod_lint` 를 다음 major 로 올리나 (6 → 7, 3 → 4) / 이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나. 새 규칙은 warning · error 등급이어도 2번(minor), 같은 major 안의 plugin 하한 상향(`^3.1.3` → `^3.1.9`)도 2번(minor)이다 (소유자 결정 2건, 2026-10-11, UAT G-01-1)
- [Phase 01]: 판정 순서 1번 문장은 `01-CONTEXT.md` 70행의 "최종 문구" 와 글자 그대로 같은 조건 문구를 쓰는 고정 문자열이다. 바꾸려면 두 파일과 plan 01-04 의 검증 명령을 함께 바꾼다
- [Phase 01]: 리뷰 WR-03 은 open 이다 — major 행 누락(기준표 40·41행)만 01-04 가 닫았다. README/CHANGELOG 만 고침(47행)과 새 프리셋 추가(45행)는 D-05 를 건드리는 소유자 결정이 필요하다. WR-01 · WR-02 · WR-04 는 fixed
- [Phase 01]: `VERSIONING.md` 의 "자동 검사" 는 등급 기준이 아니라 받는 쪽이 겪는 일의 설명이다 — `dart analyze` 는 `--fatal-warnings` 기본 켜짐 / `--fatal-infos` 기본 꺼짐 (Dart 3.13.4), `flutter analyze` 는 둘 다 기본 켜짐 (Flutter 3.47.5), 2026-10-11 확인
- [Phase 01]: UAT 12개 완료 (2026-10-11). 처리 기록표의 WR-03 메모가 리뷰 도구 재실행으로 비워진 것은 소유자가 받아들였다 — `01-VERIFICATION.md` 의 `overrides` 에 기록. 같은 메모는 `01-04-SUMMARY.md`, `01-REVIEW.md` 의 WR-03 본문에 남아 있다
- [Phase 01]: `VERSIONING.md` 30행에 "plugin 이나 기반 세트의 하한을 올릴 때는 새 버전이 요구하는 Dart 버전을 본다" 는 전제 한 문장을 더하는 일은 나중으로 미뤘다 — ROADMAP 의 Backlog `Phase 999.1`
- [Phase 02]: 검증 명령 `tool/verify.dart` 의 종료 코드는 0 모두 통과 / 1 단계 실패 / 64 사용법 오류(모르는 인자, CI 에서 `--update`) / 69 `pub get` 실패 / 70 예외로 끝남 이다. 78(SDK 불일치)은 plan 02-02 가 더한다
- [Phase 02]: 정답지 `example/expected_diagnostics.txt` 는 `exit 2` + 16줄이고, 실제 저장소에서 `--update` 로 만든 결과가 `02-RESEARCH.md` 권고 2 의 복사본 실측과 한 줄도 다르지 않았다 (Dart 3.13.4, `riverpod_lint` 3.1.9, 2026-10-12). 줄 번호가 샘플 파일의 모양에 묶여 있으므로 샘플을 고치면 `--update` 로 갱신하고 diff 를 검토한다
- [Phase 02]: 검증 명령의 전용 상태 폴더는 `.dart_tool/woody_verify/example/` 이고 그 `.plugin_manager` 아래 폴더는 정확히 하나였다. 스크립트는 이 폴더를 지우지 않는다 — 지우는 것은 plugin 준비 실패 뒤의 복구 수단이다
- [Phase 02]: 루트 `fvm dart pub get` 은 `example/` 도 함께 풀지만 `example/pubspec.lock` 을 바꾸지 않았다. lock 은 `example/` 에서 `fvm dart pub get` 으로 만들어 커밋했고 스크립트는 `--enforce-lockfile` 로 받는다. `example/` 에서 `flutter pub get` 은 돌리지 않는다
- [Phase 02]: `tool/verify.dart` 의 plugin 준비 실패 분기와 도구 사망 분기는 plan 02-01 에서 실제로 일으켜 보지 않았다 (`02-01-SUMMARY.md` coverage D9). 정답지와 다름 / 정답지 없음 / 형식 오류 70 / lock 어긋남 69 / 인자 오류 64 는 실행으로 확인했다
- [Phase 02]: 검증 명령 `tool/verify.dart` 는 준비(SDK 확인 → CI 의 `--update` 거부 → 저장소 루트 pub get → `example/` pub get) 뒤 단계 4개(`lib/` 에 `.dart` 없음 / 배포 파일의 규칙 이름 / `example/` 옵션 파일 / 정답지 비교)를 모두 돌리고 화면을 한 번에 stdout 으로 찍는다. 첫 줄은 늘 `SDK` 줄이고 진행 표시와 준비 단계의 안내는 stderr 다. 종료 코드는 0 / 1 / 64 / 69 / 70 / 78 (78 = 실행 중인 SDK 가 `.fvmrc` 와 다름)
- [Phase 02]: 스크립트의 `dart pub get` 은 늘 `--no-example` 로 돌린다 — 기본값이면 저장소 루트의 pub get 이 `example/` 도 함께 풀어 어긋난 `example/pubspec.lock` 을 다시 쓰고, 그 뒤의 `--enforce-lockfile` 이 통과해 lock 어긋남(종료 코드 69)을 놓친다 (Dart 3.13.4, 2026-10-12 실측)
- [Phase 02]: `--update` 는 바뀌는 줄을 화면에 내보낸 뒤 정답지를 쓰고, 정답지 첫 줄을 `# 실측: Flutter X / Dart Y, riverpod_lint Z, 날짜` 형식으로 다시 쓴다. plugin 준비 실패와 도구 사망에서는 `--update` 여도 정답지를 건드리지 않는다
- [Phase 02]: `tool/verify.dart` 의 plugin 준비 실패 분기와 도구 사망 분기를 plan 02-02 에서 실제로 일으켜 확인했다 — 전용 상태 폴더의 plugin.aot 을 0바이트로 자른 실행(머리말이 stderr 셋째 줄, dart analyze exit 0)과 상태 폴더를 읽기 전용 빈 폴더로 바꾼 실행(exit 255, stdout 에 JSON 없음). 네트워크가 끊긴 경우의 plugin 실패와 상태 폴더를 통째로 지우는 복구는 해 보지 않았다
- [Phase 02]: D-12 의 SDK 판별은 실행 파일에서 다섯 단계 위의 `flutter.version.json` 이 1순위, `FLUTTER_ROOT` 가 2순위이고, 2순위는 그 SDK 의 `dartSdkVersion` 이 실행 중인 Dart 와 같을 때만 받아들인다. `.fvmrc` 불일치의 78 은 실행으로 확인했고 `FLUTTER_ROOT` 경로와 'Flutter SDK 의 dart 가 아니다' 경로는 실행해 보지 못했다 (plan 02-04 의 CI 에서 본다)
- [Phase 02]: 화면의 plugin 버전은 전용 상태 폴더의 plugin 폴더가 정확히 하나일 때만 읽고 그 밖은 `?` 와 이유를 찍는다. 폴더 0개는 서버가 plugin 준비 전에 죽었을 때도 나온다 (2026-10-12 실측). 지금은 첫 fixture 의 값을 찍는다 — Phase 3 가 fixture 를 더하면 fixture 별로 찍을지 정한다
- [Phase 02]: 지워 보기 9건(M1 ~ M9)을 실제 저장소에서 하나씩 만들어 돌렸고 아홉 건 모두 계획이 예상한 단계와 종료 코드로 실패했다 — 규칙 삭제 · errors 블록 삭제 · exclude 2종 삭제는 단계 4, include 삭제는 단계 3 과 4, deprecated 규칙은 단계 2, lib 의 .dart 는 단계 1, CI 의 --update 는 64, SDK 불일치는 78 (Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12). 기록은 example/README.md 의 "검증이 실제로 잡아내는지 확인한 기록" 절이고 변경은 모두 커밋하지 않고 되돌렸다
- [Phase 02]: example/ 의 include 줄을 지운 변경은 dart analyze 의 종료 코드가 정답지와 같은 2 다 — 경고 16줄이 사라지는 대신 invalid_annotation_target warning 이 되살아난다. 같은 상태에서 dart analyze 를 따로 돌려 exit 2 를 확인했다. 종료 코드만으로는 잡지 못하고 단계 3(옵션 파일)과 단계 4(정답지 줄 비교)가 잡는다
- [Phase 02]: 화면의 plugin 줄은 전용 상태 폴더에 남아 있는 값을 읽는다 — include 줄을 지운 실행에서 riverpod_lint 진단이 하나도 없었는데도 riverpod_lint 3.1.9 가 찍혔다. 그 줄은 plugin 이 그 실행에서 돌았다는 표시가 아니고, plugin 이 빠졌는지는 정답지의 riverpod_lint 줄이 빠지는지로 본다
- [Phase 02]: example/README.md 와 CHANGELOG 2.0.0 항목의 "그 밖의 변경" 은 GitHub Actions workflow 를 이미 있는 것으로 적는다. workflow 파일은 plan 02-04 가 만든다 — 02-04 가 실행 명령이나 SDK 를 맞추는 방법을 다르게 정하면 README 의 그 문장을 함께 고친다
- [Phase 02]: CI workflow 는 .github/workflows/verify.yml 이고 02-RESEARCH.md 권고 9 의 구성 그대로다 — 트리거 셋(push · pull_request · workflow_dispatch, 필터 없음), 권한은 contents: read 뿐, concurrency 로 겹치는 실행 취소, timeout-minutes 10, step 은 checkout → flutter-action(.fvmrc) → 검증 명령 하나. 캐시 · 예약 실행 · Flutter 버전 숫자 · tag 필터 · 별도 pub get step 은 없다. action 은 major tag (actions/checkout@v7 최신 v7.0.1, subosito/flutter-action@v2 최신 v2.23.0, 2026-10-12 조회)
- [Phase 02]: 작업 브랜치 gsd/v2.0-package-rework 를 origin 에 한 번 올렸다 (2026-10-11T17:04Z, 1ed61cd → 1f06c55, fast-forward 23커밋, 명령은 브랜치 이름 하나만 준 git push 한 줄). main 은 90a2736, tag 는 v1.3.0 하나 그대로이고 PR 은 없다. plan 02-04 의 마무리 커밋(SUMMARY · STATE · ROADMAP)은 origin 에 없다 — Phase 3 부터의 push 는 다시 소유자에게 묻는다 (D-09)
- [Phase 02]: GitHub runner 에서의 첫 전체 실행이 한 번에 성공했다 — run 38158088016 (verify, push, ubuntu-24.04 이미지), job 1분 54초 (Flutter 설치 60초, 검증 명령 47초 중 example/ 분석 약 44초). 화면은 로컬과 같았다: Flutter 3.47.5 / Dart 3.13.4, flutter_lints 6.0.0 / lints 6.1.0, riverpod_lint 3.1.9, 단계 4개 통과. timeout 10분은 넉넉하다
- [Phase 02]: runner 는 FLUTTER_ROOT 환경변수를 설치한 SDK 의 자리로 넘겨준다. 그래서 D-12 의 SDK 확인이 1순위 경로(실행 파일에서 다섯 단계 위)로 통과했는지 2순위(FLUTTER_ROOT)로 통과했는지는 CI 로그로 가를 수 없다 — 둘 다 같은 SDK 를 가리킨다. Flutter SDK 가 아닌 dart 로 실행했을 때의 안내 경로는 여전히 실행해 보지 못했다
- [Phase 02]: workflow 의 pull_request 트리거와 수동 실행 버튼은 선언만 했고 일으켜 보지 않았다 (PR 은 열지 않고, 버튼은 workflow 파일이 main 에 들어간 뒤에야 보인다). push 에 필터가 없으므로 tag 를 올려도 이 workflow 가 돈다 — Phase 6 (REL-03) 이 tag 전용 검사를 더할 때 함께 본다
- [Phase 02]: run 38158088016 에 예고가 붙었다 — ubuntu-latest 라벨이 2026-10-19 부터 Ubuntu 26 으로 옮겨 간다. spike 006 과 이 실행은 ubuntu-24.04 에서 쟀다. 그 뒤 CI 가 처음 실패하면 저장소 변경보다 runner 이미지 변경을 먼저 의심한다
- [Phase 02]: 정답지 비교는 같은 줄의 건수까지 견준다 (subtractLines) — 한 줄에 같은 규칙이 두 번 걸리면 정답지에도 그 줄이 두 번 있어야 통과한다. 고치기 전에는 M10 · M11 이 종료 코드 0 으로 통과했고 고친 뒤 둘 다 종료 코드 1 이다 (02-VERIFICATION.md Gap 1, CR-01 닫음, 2026-10-12 실측)
- [Phase 02]: [2/4] 는 배포 파일의 최상위 linter: 블록에서 규칙을 하나도 읽지 못하면 실패한다 (countDeclaredRules, 지금은 12개). 규칙을 include 뒤의 파일로 옮긴 모양(M14)에서 [4/4] 는 16줄 그대로 통과하고 [2/4] 만 실패했다 — Phase 3 은 규칙을 옮길 때 shippedOptionsPath 와 stripPlugins 단계를 함께 고쳐야 한다. 세 코드 밖 진단의 처리(WR-03 의 다른 절반)는 열어 둔다
- [Phase 02]: 필터 없는 push: 가 tag push 에서도 도는 것은 그대로 둔다 (소유자 결정 2026-10-12, WR-07). workflow 주석과 02-CONTEXT.md D-10 덧붙임에 기록했고 설정은 1f06c55 와 같다. Phase 6 이 tags: 만 적으면 브랜치 push 에서 돌지 않게 된다
- [Phase 02]: plan 02-05 의 세 커밋(37316e3, 40776b5, 008ea3f)은 push 하지 않았다 — origin/gsd/v2.0-package-rework 는 1f06c55 그대로다. 바뀐 스크립트는 로컬(Flutter 3.47.5 / Dart 3.13.4)에서만 돌려 봤고 GitHub runner 에서는 다음 push 때 처음 돈다
- [Phase 02]: 정답지 갱신(--update)은 같은 실행에서 다른 단계가 실패하면 정답지를 쓰지 않고 그 사실을 화면에 찍는다 (종료 코드 1, WR-01 case 1). plugin 버전이 ? 인 실행의 갱신(case 2)은 막지 않는다 — 소유자 결정으로 열어 둔다. 쓴 뒤에는 '정답지를 썼다: 경로' 줄이 찍힌다
- [Phase 02]: UAT 9개 완료 (2026-10-12) — 통과 7, 뒤로 미룸 2, 문제 0. 미룬 둘(4번 PR 에서 verify, 6번 수동 실행 버튼)은 릴리스 때에만 볼 수 있어 ROADMAP 의 Phase 6 Notes 에 적었다. 9번은 소유자 결정이다 — `--update` 가 망가진 결과를 정답지로 쓰는 남은 경로와 README 80행 · 30행 · `[2/4]` 실패 문구는 Phase 3 에서 정답지를 새로 쓰기 전에 가장 먼저 닫는다 (ROADMAP 의 Phase 3 Notes)
- [Phase 02]: UAT 중 작업 브랜치를 두 번 더 올렸다 (2026-10-12T02:32Z, 소유자 확인 뒤, `1f06c55` → `cb5701a` → `ead9573`, 둘 다 fast-forward, 명령은 브랜치 이름 하나만 준 git push 한 줄). 1차 실행 38196218993 은 2차가 올라오자 `cancelled` (concurrency 동작 확인), 2차 실행 38196232990 은 `success` · 2분 · 로그에 `점검 통과 (4개 중 4개)` — plan 02-05 의 스크립트가 GitHub runner 에서도 통과한다. origin 의 작업 브랜치는 `ead9573` 이고 그 뒤의 커밋(UAT 완료, 로드맵 메모, phase 완료)은 origin 에 없다 — 위의 "origin 은 1f06c55 그대로" 두 줄은 이 줄로 갈음한다. `main` 은 `90a2736`, tag 는 `v1.3.0` 하나, PR 은 0건 그대로다. Phase 3 부터의 push 는 다시 소유자에게 묻는다 (D-09)
- [Phase 02]: 실행해 보지 못했던 세 경로를 UAT 에서 복사본으로 실행했다 (2026-10-12, Flutter SDK 밖으로 복제한 Dart 3.13.4) — Flutter SDK 가 아닌 dart 는 안내 두 줄과 종료 코드 78, `FLUTTER_ROOT` 가 다른 버전(3.41.9)을 가리켜도 78, 맞는 버전(3.47.5)을 가리키면 단계 4개 통과. 분석 서버를 꺼서 도구를 죽이면 `[2/4]` 와 `[4/4]` 가 `도구가 죽었다 — … exit 255` 로 실패하고 종료 코드 1 이며 `--update` 를 붙여도 정답지를 쓰지 않는다. 위의 "실행해 보지 못했다" 두 줄은 이 줄로 갈음한다
- [Phase 03]: [2/4] 의 통과 조건은 규칙 검사 복사본의 dart analyze 가 exit 0 이고 진단 0건 하나다. 닫지 않은 따옴표 · rules: 오타 · 겹친 규칙 + 없는 진단 코드의 세 입력에서 --update 가 고치기 전에는 셋 다 종료 코드 0 으로 정답지를 썼고, 고친 뒤에는 셋 다 종료 코드 1 · [2/4] 실패 · 정답지 hash 불변이다 (2026-10-12 실측, example/README.md 의 M15 ~ M17)
- [Phase 03]: 깨진 YAML(exit 3 + JSON 진단 0건)은 같은 폴더를 형식 인자 없이 재실행한 출력의 parse_error 줄을 경로를 가려 보여 준다 (readParseErrorLines). 그 줄은 따옴표를 뗀 46행이 아니라 파서가 막힌 47행을 가리킨다. 03-02 는 깨진 옵션 파일 문구의 shippedOptionsPath 를 조각 이름으로 바꿔야 한다
- [Phase 03]: lib/ 는 조각 셋(base.yaml · codegen.yaml · riverpod.yaml) + 묶음 recommended.yaml + 옛 주소 별칭 analysis_options.yaml 의 다섯이다. 조각은 90a2736 의 배포 파일을 sed 줄 범위로 잘라 만들었고 이어 붙이면 원본과 같다(diff 종료 코드 0). 옛 주소를 쓰는 example/ 의 정답지는 19ae5ec 그대로이고 검증 명령은 점검 통과 (4개 중 4개)다 (2026-10-12)
- [Phase 03]: [2/4] 는 lib/*.yaml 집합 확인(expectedLibYamls) 뒤 조각 셋을 build/woody_rule_check/<조각 이름>/analysis_options.yaml 로 복사해 한 번에 분석한다. riverpod.yaml 끝에 숨긴 deprecated 규칙은 riverpod/analysis_options.yaml:11 로(원본 13행, plugins: 두 줄을 빼서 2 앞당겨짐), 여분 lib/_probe_extra.yaml 은 집합 확인이 잡았다. 새 조각을 더하면 ruleCheckTargets 와 expectedLibYamls 를 함께 고친다
- [Phase 03]: 루트 analysis_options.yaml 의 exclude 는 'example/**' 하나이고 lib/analysis_options.yaml 제외 없이 루트 fvm dart analyze 가 exit 0 · No issues found 다 (Dart 3.13.4, 2026-10-12, PRESET-06). 03-03 이 'fixtures/**' 를 더한다. 이 plan 의 두 커밋(89d6073, 933b26f)은 push 하지 않았다
- [Phase 03]: 검증 명령은 연습용 프로젝트 여섯을 Fixture 표 순서(example → recommended → base_only → base_riverpod → base_codegen → overrides)로 차례로 돌려 단계 9개를 찍는다. recommended 는 자기 정답지 없이 같은 실행의 example 결과와 견주고, 새 정답지 넷(base_only exit 2 · 18줄, base_riverpod exit 2 · 21줄, base_codegen exit 0 · 13줄, overrides exit 2 · 18줄)은 --update 로 처음 써 03-RESEARCH.md 권고 11 의 전문과 줄 단위로 같았다 (2026-10-12)
- [Phase 03]: 검증 명령의 --update 는 바뀐 정답지만 쓰고 끝에 '정답지를 썼다 (N개):' 와 목록을 찍는다. 바뀐 것이 없으면 '바뀐 정답지가 없다 — 쓰지 않았다' 이고 머리 주석의 날짜도 다시 쓰지 않는다. plugin 을 쓰지 않는 fixture 의 머리 주석과 plugin 값은 '해당 없음' 이다
- [Phase 03]: [3/9] 는 fixtures/overrides 의 version: 줄을 lib/riverpod.yaml 의 riverpod_lint 선언과 견준다 — 03-04 는 두 줄을 같은 커밋에서 함께 올려야 한다 (overrides 만 ^3.1.9 로 바꾼 실행에서 [3/9] 만 실패 확인)
- [Phase 03]: M18 (묶음에서 riverpod.yaml 제거)에서 실패한 것은 [4/9] example 하나다 — recommended 는 example 과 같이 깨져 통과하고, overrides 는 자기 plugins: 선언으로 plugin 이 돌아 통과했다 (계획 예상과 다름). 묶음의 Riverpod 조각은 example 의 정답지가 지킨다. M19 (overrides 의 version 제거)는 [3/9] 와 [9/9] 가 잡는다
- [Phase 03]: 연습용 프로젝트 여섯의 검증 시간은 로컬 처음 실행(상태 폴더 비움) 69초, 재실행 20 ~ 23초다. plugin 폴더는 example 1 · recommended 1 · base_only 0 · base_riverpod 1 · base_codegen 0 · overrides 1. 이 plan 의 커밋 셋(91bbeec, 9ed0fe5, 25e980e)은 push 하지 않았다
- [Phase 03]: riverpod_lint 하한을 ^3.1.9 로 올렸다 (lib/riverpod.yaml 과 fixtures/overrides 의 version 을 같은 커밋 166d0be 에서). 정답지 다섯의 hash 가 올리기 전과 같고 --update 는 '바뀐 정답지가 없다' 였다 (Dart 3.13.4, 풀린 버전 3.1.9, 2026-10-12)
- [Phase 03]: Phase 3 의 첫 push 는 소유자 응답 push 뒤 git push origin gsd/v2.0-package-rework 한 줄로 했다 (2026-10-12T12:12:44Z, 0d20c10..166d0be, 24커밋, fast-forward). 두 번째 push 는 D-09 대로 묻지 않고 했다 (12:18:00Z, 166d0be..79f27e5). main 은 90a2736, tag 는 v1.3.0 하나, PR 0건 그대로다. 03-04 의 마무리 커밋은 origin 에 없고 Phase 4 부터의 push 는 다시 소유자에게 묻는다
- [Phase 03]: GitHub verify 가 연습용 프로젝트 여섯으로 두 번 성공했다 — run 38247615476 job 4분 7초 (검증 182초), run 38248171220 job 3분 33초 (검증 147초), ubuntu-24.04 20261004.327.1. 추정 약 4분 15초 (D-03) 를 대신한다. 360초 이하라 timeout-minutes 10 그대로 두고 workflow 25행 주석만 실측으로 고쳤다
- [Phase 03]: UAT 4건 완료 (2026-10-12) — 통과 4, 문제 0. 1번은 소유자 결정이다 — 성공 기준 3 후반 "생성 파일의 진단이 보고되지 않는다" 를 Dart 3.13.x 의 규칙 진단에 대한 말로 읽고, README 가 그 범위와 직접 적는 방법을 밝히도록 ROADMAP 의 Phase 5 Notes 에 적었다 (`1ba1b31`). 2번 판단형 금지 사항은 plan 기준 16건이다 (검증 보고서의 "17건" 은 수 착오) — 근거 명령 16개를 다시 돌려 모두 통과했다. 3 · 4번은 SUMMARY coverage 의 사람 판단 항목(CHANGELOG 2.0.0, `example/README.md`)을 UAT 에 더한 것이다. `03-VERIFICATION.md` 는 `passed`
- [Phase 04]: 검증 명령 [3/10] (c) 의 기호는 RULES.md 를 정답지, lib/base.yaml 을 실제 결과로 놓는다 — + 는 base.yaml 에만, - 는 RULES.md 에만 있는 이름 (04-01)
- [Phase 04]: readRulesMdBlock 은 이름과 형식 오류 행을 함께 돌려주는 RulesMdBlock 을 돌려준다 — 첫 칸 이름이 둘인 행을 예외가 아닌 단계 실패로 알리기 위해 (04-01)

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 4] D13: 규칙별 채택은 소유자 검토 지점이다. 실측 표 없이는 결정하지 않는다
- [Phase 1] 리뷰 지적 13건이 열려 있다 (`01-REVIEW-DISPOSITION.md`, 합계 16). 그중 WR-03 의 남은 두 경우 — README/CHANGELOG 만 고친 변경, 새 프리셋 파일 추가 — 는 `VERSIONING.md` 의 판정 순서와 기준표가 다른 등급을 내며 D-05 를 건드리는 소유자 결정이 필요하다. 2.0.0 의 등급(major)에는 영향이 없다
- [Phase 3] `riverpod_lint` 하한을 `^3.1.9` 로 올릴 때(PRESET-05): 3.1.9 는 Dart 3.13 이상을 요구한다. 지금은 `sdk: ^3.13.0` 이라 문제없지만 `VERSIONING.md` 에 이 전제가 적혀 있지 않다 (Backlog `Phase 999.1`)
- [Phase 2] 리뷰 지적 15건이 열려 있다 (`02-REVIEW-DISPOSITION.md`, 합계 17 — WR-01 ~ WR-06 · WR-08 · IN-01 ~ IN-08). `02-VERIFICATION.md` 의 "다음 phase 가 알아야 할 것" 1 ~ 7 이 Phase 3 · 4 · 6 에 걸리는 것을 추렸다. WR-06 은 Phase 6 이 `version` 을 올릴 때 종료 코드 69 로 만난다
- [Phase 3] 리뷰 지적 14건이 열려 있다 (`03-REVIEW-DISPOSITION.md`, warning 8 · info 6). 그중 검증 장치의 빈틈 셋은 Phase 4 · 5 가 배포 YAML 을 고칠 때 밟는 자리다 — WR-01 `[2/9]` 가 묶음 · 별칭을 보지 않아 거기 적은 규칙을 놓친다 (거짓 통과), WR-02 `riverpod_lint` 줄 끝 주석 · 마지막 줄바꿈 없음에서 종료 코드 70 (거짓 실패), WR-03 `base.yaml` 의 맵 형식 규칙(`rule: false`)에서 `[2/9]` 거짓 실패. Phase 4 계획 때 먼저 닫을지 정한다 (`03-VERIFICATION.md` Gaps Summary) — 정함 (2026-10-13, `04-CONTEXT.md` D-12): WR-01 은 plan 04-01 의 `[3/10]` 이 닫고, WR-02 는 Phase 5 의 첫 일, WR-03 은 목록 형식 관례로 피하고 열어 둔다
- [Phase 6] `main` 병합은 `ref: main` 사용 프로젝트 5개에 새 버전을 배포하는 일이다. tag 와 병합의 순서를 계획 때 정한다
- [Phase 6] Phase 2 에서 미룬 확인 둘 — PR 에서 `verify` 가 도는지, 수동 실행 버튼 (ROADMAP 의 Phase 6 Notes)

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-10-12T23:22:48.130Z
Stopped at: Completed 04-01-PLAN.md
Resume file: None
