---
gsd_state_version: "1.0"
milestone: v2.0
milestone_name: Package Rework
current_phase: 05
current_phase_name: Documentation
status: Phase 05 재검증 human_needed 92/92 — 사람 확인 6건 대기 (/gsd-verify-work 05)
stopped_at: Completed 05-15-PLAN.md
last_updated: "2026-10-14T22:40:12.054Z"
last_activity: 2026-10-15
last_activity_desc: Phase 05 4회차 gap 수정 실행 · 재검증 human_needed 92/92 (경고 셋 IN-12 · IN-13 · IN-14)
state_head: 6ed2f9886ebbf4617fe0c05e915d7e3bb7ff05f5
progress:
  total_phases: 6
  completed_phases: 4
  total_plans: 41
  completed_plans: 41
  percent: 67
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-13)

**Core value:** 사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.
**Current focus:** Phase 05 — Documentation

## Current Position

Phase: 05 (Documentation) — EXECUTING
Plan: 15 of 15
Status: Phase 05 재검증 human_needed 92/92 — 사람 확인 6건 대기 (/gsd-verify-work 05)
Last activity: 2026-10-15 — Phase 05 4회차 gap 수정 실행 · 재검증 human_needed 92/92 (경고 셋 IN-12 · IN-13 · IN-14)

Progress: [███████░░░] 67%

## Performance Metrics

**Velocity:**
- Total plans completed: 26
- Average duration: - min
- Total execution time: 0.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 4 | - | - |
| 2 | 5 | - | - |
| 3 | 4 | - | - |
| 04 | 13 | - | - |

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
| Phase 04 P02 | 27min | 2 tasks | 1 files |
| Phase 04 P03 | 27min | 2 tasks | 1 files |
| Phase 04 P04 | 40min | 3 tasks | 3 files |
| Phase 04 P05 | 21min | 3 tasks | 1 files |
| Phase 04 P06 | 16min | 3 tasks | 26 files |
| Phase 04 P07 | 17min | 3 tasks | 26 files |
| Phase 04 P08 | 17min | 3 tasks | 4 files |
| Phase 04 P09 | 7min | 2 tasks | 5 files |
| Phase 04 P10 | 10min | 3 tasks | 1 files |
| Phase 04 P11 | 9min | 2 tasks | 5 files |
| Phase 04 P12 | 10min | 3 tasks | 18 files |
| Phase 04 P13 | 7min | 3 tasks | 5 files |
| Phase 05 P01 | 9min | 3 tasks | 4 files |
| Phase 05 P02 | 4min | 2 tasks | 6 files |
| Phase 05 P03 | 13min | 2 tasks | 2 files |
| Phase 05 P04 | 3min | 2 tasks | 2 files |
| Phase 05 P06 | 9min | 1 tasks | 1 files |
| Phase 05 P05 | 2h 16m | 3 tasks | 0 files |
| Phase 05 P07 | 23min | 3 tasks | 3 files |
| Phase 05 P08 | 30min | 3 tasks | 3 files |
| Phase 05 P09 | 20min | 3 tasks | 6 files |
| Phase 05 P10 | 27 min | 3 tasks | 3 files |
| Phase 05 P11 | 7 min | 2 tasks | 1 files |
| Phase 05 P12 | 20 min | 2 tasks | 3 files |
| Phase 05 P13 | 7 min | 2 tasks | 1 files |
| Phase 05 P14 | 18min | 2 tasks | 7 files |
| Phase 05 P15 | 8 min | 2 tasks | 1 files |

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
- [Phase 04]: 실측 도구 tool/measure_rules.dart 의 결과 JSON(schema 1)은 회차마다 options(켠 규칙 이름 · 언어 옵션 · sdk)와 projectBySeverity 를 담는다 — fix 단계가 다른 실행에서 before 회차의 옵션을 되살리고 새 error 를 센다. 경로 · 메시지는 없다 (04-02)
- [Phase 04]: 실측 도구의 회차는 네트워크가 끊기면 plugin 준비 실패로 valid: false 가 되고 종료 코드 1 이다 (04-02 smoke 의 G1-strip, 2026-10-13 실측). 같은 run id 로 그 단계만 다시 돌리면 같은 id 의 회차를 바꿔 쓴다 (04-02)
- [Phase 04]: 실측 도구의 표식은 ruleProbes 73 · ruleProbes313 7 이고, Dart 파일 하나로 어길 수 없는 넷(sort_pub_dependencies · use_test_throws_matchers · require_trailing_commas · package_prefixed_library_names)은 noFileProbe 에 이유와 함께 둔다 — markers 단계는 이들을 표식 불가로 따로 알리고 conditions.noFileProbe 에 적는다. example/ 복사본에서 표식이 있는 규칙 82개 모두 검출 (04-03)
- [Phase 04]: avoid_final_parameters 는 언어 버전 3.13 에서 꺼진다(Feature.primary_constructors, 보통 매개변수의 final 은 error) — 표식은 그 파일만 // @dart=3.11 이고, 하한을 3.13 으로 올리면(RULES-10) 이 규칙은 돌지 않는다. avoid_type_to_string 은 tag 3.13.4 의 SDK 에서 x.runtimeType.toString() 에 걸리지 않는다 (04-03)
- [Phase 04]: 실측 도구의 출력 모드는 --summary <묶음> · --report [--write] · --audit 이다. --report 는 단언 여섯이 모두 맞을 때만 Markdown 을 내고 --write 는 그때만 RULES.md 의 woody:measurements 를 바꿔 쓴다. --audit 은 후보 133 ∪ B-7 31 이 RULES.md 의 세 표에 있는지 본다 — 04-01 뼈대에서는 빠짐 158 · 빈 칸 6 으로 종료 코드 1 (04-03)
- [Phase 04]: bundles 상수는 묶음 id → 한국어 이름 12개이고 하나씩 묻는 묶음의 규칙 표는 bundleRules 다. dart fix 단계는 단독 dry 0 인 행의 newErrors 를 0 으로 적는다 — --report 단언 (2) 를 실제 데이터에서 넘기 위해서다 (04-03)
- [Phase 04]: 실측 회차 R1 (2026-10-13, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9) 의 결과 tool/measurements/2026-10-13-R1.json 은 회차 50개가 모두 유효하고 평가표의 단일 출처다. 결정 대상 121행 가운데 줄이 있는 행 54, 0줄 67 (표식 검출 62 · 표식 미검출 1 · 표식 불가 4) — 결정 안 함이 될 규칙 5개 (04-04)
- [Phase 04]: 실측 도구의 fix 단계는 analyzer 옵션 strict-inference 도 그 회차의 inference_failure_on_* 코드를 모두 --code= 로 주어 잰다 — R1 에서 test 106줄, 단독 dry 0, 사라진 줄 0, 새 error 0. --report 의 옵션 행 예외는 걷었다 (04-04)
- [Phase 04]: 비공개 점검 (3) 의 dart fix 화면 문구 grep 은 이 phase 의 PLAN · RESEARCH 에 적힌 자기 패턴 10줄에 걸린다 — 04-04 는 PLAN · RESEARCH 를 뺀 범위로 0줄을 확인했다. 04-09 · 04-10 의 같은 점검도 같은 10줄을 만난다 (04-04)
- [Phase 04]: 소유자가 규칙별 채택을 정했다 (2026-10-13, 로드맵 D13) — 묶음 1 ~ 5 모두 권고대로, 질문 1 ~ 6 모두 권고와 같은 답. 켬 80 (새로 켜는 74 + 지금 켜 둔 6 남김) · 안 켬 35 · 결정 안 함 5 (표식 불가 4 · 표식 미검출 1) · v2 12 · 보류 1 (unnecessary_ignore, 04-08). 원본은 04-DECISIONS.md 의 결정 표 (04-05)
- [Phase 04]: strict 계열은 no_dynamic_casts · no_raw_types 를 켜고 strict-inference 는 켜지 않는다 (warning, 106줄 모두 test) — fixtures/base_codegen 의 exit 0 은 그대로다. import 는 prefer_relative_imports, fire-and-forget 은 unawaited_futures · discarded_futures 를 켜고 unnecessary_unawaited 는 켜지 않는다 (04-05)
- [Phase 04]: 지금 켜 둔 5개의 사유 문구는 D-18 제안대로 고친다 (승인) — 문구는 04-DECISIONS.md 의 표 밖의 응답과 메모. unnecessary_underscores 는 후보가 아니라(기반 세트) 그대로 둔다 (04-05)
- [Phase 04]: 결정 대상은 120 이 아니라 115 다 — 도구가 결정 안 함으로 판정한 행이 표식 불가 4 · 표식 미검출 1 의 다섯이다. 04-06 의 precondition 이 120 을 세면 115 로 읽는다 (04-05)
- [Phase 04]: 반영 A 커밋 셋(B1 9cff42e · B2 354959c · B3 52402df): 지금 켜 둔 6개 모두 남기고 사유 주석 셋을 D-18 문구로 고쳤으며, 새로 켠 규칙은 27개(버그 방지 23 · prefer_relative_imports · discarded_futures · no_dynamic_casts · no_raw_types)이고 뺀 규칙 0 · strict-inference 안 켬이라 base_codegen 의 exit 0 그대로다 (04-06)
- [Phase 04]: prefer_relative_imports 샘플은 example/lib/relative_imports_rule.dart 하나에 두고 그 파일만 프로젝트마다 자기 패키지 이름이 다르다 — 다른 샘플은 글자 그대로 복사한다. 04-07 이후의 diff -rq example/lib fixtures/*/lib 확인은 이 파일을 빼거나 패키지 이름을 맞춰 견준다 (04-06)
- [Phase 04]: 04-06 계획의 검증 명령은 세 곳이 쓰인 그대로 통과하지 않는다 — 사유 주석 수정을 규칙 추가로 읽는 단언, diff 문맥 줄의 exit 를 세는 단언, relative_imports_rule.dart 때문에 실패하는 diff -rq. 고친 판으로 세 task 모두 rc 0 (04-06-SUMMARY Deviations)
- [Phase 04]: 반영 B 커밋 셋(B4 6c0bc83 · B5 944ca1c · B6 ba58060): 성능 8 · 가독성·스타일 39 를 켜 켠 규칙 80, 뺀 규칙 0 — 정답지 +lib/ 는 B4 8줄, B5 41줄(overrides 50줄), exit 변화 없음 (04-07)
- [Phase 04]: RULES.md 켜지 않은 규칙 표 완성 — tool/measure_rules.dart --audit 이 감사 통과 (켠 80 · 옵션 0 · 켜지 않음 91 · 보류 1, 보류는 unnecessary_ignore) (04-07)
- [Phase 04]: 기존 샘플에 새 규칙이 걸린 줄은 받아들였다 (Pitfall 5) — 다섯 정답지 모두 join_return_with_assignment · specify_nonobvious_property_types 각 1줄, overrides 는 suppress 의 document_ignores 6 · specify_nonobvious_property_types 3 더 (04-07)
- [Phase 04]: avoid_final_parameters 샘플은 언어 버전 3.11 로 둔 lib/final_parameters_rule.dart 한 파일에 있다 — 연습용 프로젝트가 sdk ^3.13.0 이라 다른 파일에서는 규칙이 돌지 않고 final 매개변수가 error 다 (04-07)
- [Phase 04]: 04-07 계획의 Task 1 · 2 검증 명령은 relative_imports_rule.dart 때문에 복사본 diff -rq 에서 쓰인 그대로 실패한다 (04-06 과 같은 결함) — 고친 판으로 rc 0, Task 3 은 쓰인 그대로 rc 0 (04-07-SUMMARY)
- [Phase 04]: unnecessary_ignore 는 안 켬 — 결정 반영 뒤 재측정 UI 36줄 (lib 1 · test 34 · bin 1, G1 은 12), 소유자가 질문 9 (재측정) 권고대로 고름 (사유 없음, 04-08)
- [Phase 04]: 04-09: CHANGELOG 2.0.0 새로 생기는 경고 표는 새로 켠 규칙 74행(R1 JSON 의 lib + test + bin 합계 · fixRemoved), 칸 맞춤 없이 쓴다
- [Phase 04]: 04-09: 03 리뷰 WR-01 fixed · WR-02 deferred (Phase 5 첫 일) · WR-03 open; M25 는 no_self_assignments 로 [3/10] 과 정답지 단계 다섯이 함께 실패함을 확인
- [Phase 04]: 04-10: Phase 4 의 첫 push 는 소유자 답 push 뒤 git push origin gsd/v2.0-package-rework 한 줄로 했다 (2026-10-13T05:23:45Z, 79f27e5..0db0fdd, 64커밋, fast-forward, 둘째 push 없음). main 90a2736, tag v1.3.0 하나, PR 0건 그대로다. 04-10 의 마무리 커밋은 origin 에 없고 Phase 5 부터의 push 는 다시 소유자에게 묻는다
- [Phase 04]: 04-10: GitHub verify run 38351171683 이 단계 10개로 성공했다 (job 3분 30초, 검증 146초, ubuntu-24.04 20261004.327.1). [3/10] 은 runner 의 pub cache 에서도 상류 YAML 을 읽어 readUpstreamRules 를 고치지 않았다
- [Phase 04]: 04-10: push 범위 전체 점검에서 03-04-SUMMARY 한 줄이 홈 폴더 경로 접두어와 소유자 이메일 앞부분을 적고 있어 소유자 결정으로 새 커밋 0db0fdd 에서 말로 바꿨다 (옛 커밋 기록은 다시 쓰지 않음). 다음 push 점검은 범위 전체에 돌린다
- [Phase 04]: gap 수정 계획 전 소유자 결정 (2026-10-13, 모두 권고대로) — `sort_pub_dependencies` 는 켬으로 재결정 (실측 2줄, 모두 `pubspec.yaml`; 첫 결정 안 켬은 측정 도구가 그 자리를 세지 않아 생긴 0 을 근거로 했다), WR-02 · WR-05 · WR-06 은 gap 수정에 함께 넣음, CR-03 은 코드를 고치지 않고 REQUIREMENTS 의 RULES-13 옆 메모와 처리 기록 deferred 로 미룸. 나머지 리뷰 지적(WR-01 · 03 · 04 · 07 · 08, IN-01 ~ 07)은 open. 화면(UI) 설계 검사는 로드맵의 "회차 UI" 글자에 걸린 오탐이라 건너뜀
- [Phase 04]: gap 수정 계획 04-11 (wave 10, 측정 도구 · 검증 도구) · 04-12 (wave 11, 켬 반영 · 문서 수치 · CR-03 메모) — 비공개 프로젝트는 다시 돌리지 않고 커밋된 R1 회차에서 행을 다시 센다 (`--recount`), `sort_pub_dependencies` 의 `dart fix` 칸은 `재지 않음`. plan checker 2회차 통과 (b9f42b9, 8e49bcb)
- [Phase 04]: 04-11: 측정 도구의 값 자리는 valueAreas (lib · test · bin · pubspec.yaml) 넷이고 projectAreas 셋은 Dart 파일 수 · 표식 · 무시 주석 걷기에만 쓴다. --report 단언 (7) 이 값 밖 자리의 같은 규칙 코드를 잡는다 (b567100)
- [Phase 04]: 04-11: R1 의 행을 --recount 로 커밋된 회차에서 다시 셌다 — 바뀐 행은 sort_pub_dependencies 하나 (0·0·0·0 → 0·0·0·2), runs 그대로, dart fix 칸은 재지 않음 (fixSkipped). --summary style 판정은 켬 · 손으로 고칠 줄 2 (≤ 50). 비공개 프로젝트는 돌리지 않았다
- [Phase 04]: 04-11: [3/10] 의 declaredRuleNames 는 주석 · 빈 줄을 건너뛴다 (CR-02, M26 이 [3/10] 만으로 실패, 점검 실패 (10개 중 1개)). 상류 YAML 에서 규칙 0개면 tool/verify.dart · tool/measure_rules.dart 둘 다 FormatException (WR-06, c06d8d5)
- [Phase 04]: 04-12: sort_pub_dependencies 를 켰다 (소유자 재결정 2026-10-13 의 반영, 6d64bee) — lib/base.yaml 81개 == RULES.md 켠 규칙 81 == 결정 표 켬 81, --audit 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0
- [Phase 04]: 04-12: 샘플은 연습용 프로젝트 여섯의 pubspec.yaml 에서 dependencies 의 flutter_riverpod 를 flutter 앞에 둔 것이고 정답지 다섯에 pubspec.yaml:11  info  sort_pub_dependencies 한 줄씩 생겼다 (exit 줄 · 다른 줄 · pubspec.lock 그대로). example/pubspec.yaml 만 되돌리면 [5/10] · [6/10] 이 실패한다
- [Phase 04]: 04-12: CR-03 은 코드를 고치지 않고 REQUIREMENTS.md RULES-13 아래 메모와 처리 기록 deferred 로 남겼다 (소유자 결정 2026-10-13). example/README.md 의 줄 수는 정답지와 같다 (합계 93, WR-05)
- [Phase 04]: gap 수정 2회차 계획 전 소유자 결정 (2026-10-13, 모두 권고대로) — WR-10 (`[3/10]` 이 따옴표 규칙 이름을 읽지 못함)은 고친다: 따옴표 이름을 읽고, `linter:` 블록 안에서 읽지 못하는 줄은 조용히 건너뛰지 않고 검증을 멈춘다 (입력 하나가 아니라 결함의 꼴을 닫음). IN-08 (`RULES.md` 의 `sort_pub_dependencies` 칸) · IN-10 (`example/README.md` 의 "규칙 6개" 문장)은 문장만 고치고 샘플 머리 주석은 그대로 둔다. WR-09 는 코드를 고치지 않고 RULES-13 메모 한 줄과 처리 기록 deferred. 화면(UI) 설계 검사는 "회차 UI" 오탐이라 건너뜀
- [Phase 04]: gap 수정 계획 04-13 (wave 12) — Task 1 `declaredRuleNames` (M27 ~ M31: 따옴표 둘은 `[3/10]` 만 실패, 맵 항목 · 이름 없는 `-` · 대시 없는 맵 줄은 종료 코드 70), Task 2 IN-08 · IN-10, Task 3 WR-09 메모 · DISPOSITION. plan checker 2회차 통과 (a0322ac, 5aeeb4c)
- [Phase 04]: 04-13: [3/10] 의 declaredRuleNames 는 linter: 블록 안에서 들여쓴 rules: 키 줄과 목록 항목(따옴표 없음 · 홑따옴표 · 큰따옴표, 뒤에 # 주석 가능)만 받고 그 밖의 줄은 FormatException 으로 종료 코드 70 (WR-10 — M27 · M28 은 [3/10] 만 실패, M29 ~ M31 은 70; 67d1bc7)
- [Phase 04]: 04-13: 03-REVIEW.md WR-03 의 입력 꼴(맵 형식 규칙)은 이제 종료 코드 70 으로 멈춘다 (M31) — 03-REVIEW-DISPOSITION.md 는 손대지 않았다. WR-09 는 RULES-13 의 둘째 메모와 처리 기록 deferred (open 17, 8f4e257). IN-08 · IN-10 은 텍스트만 (76dee2f)
- [Phase 04]: Phase 4 재검증 passed 11/11 (2026-10-13). 리뷰 WR-11 ([3/10] 의 겹침 · RULES.md 일치가 lib/base.yaml 만 읽음) 은 gap 이 아닌 경고이고, 소유자 결정으로 Phase 5 의 VERIFY-06 과 함께 고친다 — 처리 기록 deferred, ROADMAP Phase 5 Notes
- [Phase 05]: 계획 6개 · wave 5 — 05-01 verify.dart WR-02 · WR-11 (B안, 규칙은 lib/base.yaml 에만) · IN-14 (M32 ~ M37), 05-02 배포 YAML 머리 주석 · CLAUDE.md 두 줄, 05-03 README 재작성 → [3/10] (d) ~ (g) 두 커밋, 05-04 CHANGELOG 복원 · 2.0.0 두 칸, 05-06 지워 보기 M38 ~ M42, 05-05 첫 push (소유자 확인). plan checker 2회차 통과 (de67ffb, edcdf7c)
- [Phase 05]: CHANGELOG 2.0.0 의 `### 새로 생기는 경고` 표는 75행이다 (조사 문서의 74 는 04-12 전 값). 05-04 는 수를 박지 않고 "표 행 수 == 추가한 규칙 불릿 수" 로 단언한다
- [Phase 05]: 05-01: WR-11 은 B안 — [3/10] (b′) 가 lib/base.yaml 밖 조각의 linter: 블록에 규칙이 있으면 실패, 규칙은 lib/base.yaml 에만
- [Phase 05]: 05-01: stripPlugins 는 plugins: 섹션을 빈 줄로 바꿔 줄 번호를 보존하고 readShippedPluginConstraint 는 줄 끝 주석 · 맵 형식을 받는다 (M32 · M33 통과, M34 70, M37 진단 줄 :13)
- [Phase 05]: 05-02: lib/recommended.yaml · lib/analysis_options.yaml 에도 README.md 를 가리키는 # 줄을 하나씩 더했다 — 다섯 파일 모두 머리 주석이 README 를 가리킨다
- [Phase 05]: 05-02: .claude/CLAUDE.md 71행은 [3/10] 이 lib/base.yaml · RULES.md · README 표시 구역의 일치를 본다고 적었다 — CHANGELOG 는 검증 대상이 아니다
- [Phase 05]: 05-03: pub workspace 공식 문서에 멤버 패키지의 analysis_options.yaml 해석 문장이 없어(2026-10-14 읽음) README 는 분석에 관한 문장 하나를 옮기고 "이 패키지로는 돌려 보지 않았다" 고 적었다
- [Phase 05]: 05-03: README 의 복사해 쓰는 값(include 주소 · version: · ref:)은 코드 블록 안에 두고, [3/10] (f) · (g) 는 코드 블록 안만 읽는다 — 읽은 값이 0개면 실패
- [Phase 05]: 05-03: plugin 복구 안내는 이 프로젝트의 .plugin_manager/<hash>/ (또는 bin/plugin.aot) 로 범위를 좁혔다 — 기본 자리 전체 삭제는 안내하지 않는다
- [Phase 05]: 05-04: CHANGELOG 1.1.0 ~ 1.2.5 를 버전마다 한 항목으로 복원했다 — diff 로 확인한 변경만, RESEARCH 표에 없던 9bf0d86 (1.1.0 README) · a97fd20 (1.2.4 의 FVM 설정)을 더했다
- [Phase 05]: 05-04: 2.0.0 올리기 전에는 불릿 넷(받는 때 = main 병합 뒤 flutter pub upgrade woody_lints, README 버전 올리기 링크), 그 밖의 변경은 불릿 여덟(저장소 안쪽 한 줄). 01 WR-05 fixed, open 12
- [Phase 05]: 05-06: README 검사 (d) ~ (g) 의 지워 보기 M38 ~ M42 다섯 모두 종료 코드 1 · [3/10] 만 실패 · 점검 실패 (10개 중 1개), 각 19초 — (e) 는 첫 주소(50행)가 아닌 뒤쪽 주소(78행)의 오타를 잡았다. (f) · (g) 의 코드 블록 한정은 fencedLines 코드를 읽은 것이고 실행으로 가르지 않았다
- [Phase 05]: 05-05: 소유자 결정 "push" (권고안 승인, 2026-10-14) — Phase 5 의 첫 push 는 git push origin gsd/v2.0-package-rework 한 줄로 했다 (2026-10-13T20:06:03Z UTC, 0db0fdd..92d478a, 65커밋 — Phase 4 gap 수정 38 · Phase 5 27, fast-forward, 둘째 push 없음). main 90a2736, tag v1.3.0 하나, PR 0건 그대로다. 05-05 의 SUMMARY · 메타데이터 커밋은 origin 에 없다
- [Phase 05]: 05-05: GitHub verify run 38460138720 이 단계 10개로 성공했다 (job 3분 31초, 검증 148초, ubuntu-24.04 20261004.327.1) — README 검사 (d) ~ (g) 가 runner 에서도 통과해 고치지 않았다 (VERIFY-06 의 CI 쪽)
- [Phase 05]: gap 수정 계획 전 소유자 결정 (2026-10-14, 모두 권고대로) — gap 둘(README 표시 구역 reader · `linter:` flow 표기)에 더해, 같은 모양(읽지 못하는 줄을 건너뜀) 넷(WR-01 · WR-02 · WR-03 · RULES.md 표 reader), 문장 넷(W4 · IN-04 · IN-02 · IN-03 · IN-07, IN-07 은 문장만 낮춤), 거짓 실패 · 정리 넷(WR-05 · IN-01 · IN-05 · IN-06)을 함께 고친다. WR-06 (`.claude/CLAUDE.md` 의 낡은 지시)은 D-09 대로 deferred
- [Phase 05]: gap 수정 계획 2회차 소유자 결정 (2026-10-14, 모두 권고대로) — plugin 선언은 `^X.Y.Z` 와 고정 버전 `X.Y.Z` 를 받고 범위 제약만 원인을 말하며 멈춘다, `enabledLanguageOptions` 의 flow 표기 · 읽지 못하는 줄도 멈춘다(05-08), README 의 `package:` 이름이 `woody_lints` 가 아니면 실패(05-08), `measure_rules.dart` 의 `readRulesTable` · `readUpstreamRules.readSet` 은 그대로 두고 주석 한 줄만 고친다
- [Phase 05]: gap 수정 계획 05-07 (wave 6, gap 둘 · README 코드 블록 값, M43 ~ M50) · 05-08 (wave 7, RULES.md 표 · 주소 · 펜스 · 옵션 reader, M51 ~ M62) · 05-09 (wave 8, plugin 선언 · 문장 · 처리 기록 · push, M63 ~ M67). Fable 크레딧 소진으로 planner · checker 를 Opus 로 돌렸다 (소유자 결정). plan checker 2회차 통과 (6f91b2c, ea65d2e, 303d559)
- [Phase 05]: 05-07: README 표시 구역 woody:readme-rules 안에서 받는 줄은 빈 줄 · **분류** 소제목 · `- `이름`` 불릿 셋뿐이고 그 밖의 줄은 [3/10] 실패다 (gaps 1, M43 · M44). 마커 처리는 readMarkerBlock 하나, 결과 타입은 MarkerBlock (IN-06; 5f43726)
- [Phase 05]: 05-07: linter: 줄에 # 주석 밖의 값이 붙은 flow 표기는 종료 코드 70 으로 멈추고 줄 끝 주석만 붙은 블록 꼴은 그대로 받는다 (gaps 2, M45 70 · M46 [3/10] 실패 1). README 378행은 블록 목록 · flow 표기를 가른다 (DOCS-06; 057bef2)
- [Phase 05]: 05-07: README 코드 블록의 (f) · (g) 는 키 줄을 모두 후보로 잡아 unquotedScalar 와 줄 끝 주석 벗기기 뒤 꼴을 보고, 꼴이 틀린 값은 읽지 못하는 줄 (N) 로 실패한다. 값 없는 맵 키 줄은 후보가 아니다 (WR-02, M47 ~ M49 실패 · M50 10/10; 73f1c66)
- [Phase 05]: 05-08: RULES.md 표 구역 안에서 받는 줄은 0번째 줄의 머리 줄 · 1번째 줄의 구분 줄 · 첫 칸이 backtick 이름 하나인 데이터 행 · 데이터 행이 없는 구역의 '없음 — …' 한 줄뿐이고 그 밖의 줄은 [3/10] 실패다 (M51 ~ M53; 812c477). measure_rules.dart 의 readRulesTable 은 문서 주석만 고쳤다
- [Phase 05]: 05-08: README (e) 는 package:woody_lints/ 뒤의 후보 가운데 <이름>.yaml 꼴이 아닌 것과 이름이 woody_lints 가 아닌 패키지의 .yaml · .yml 주소를 실패시키고, fencedLines 는 펜스의 문자 · 길이를 기억해 같은 문자만으로 된 · 같거나 긴 줄에서만 닫는다 (M54 ~ M58; 63fe3d9)
- [Phase 05]: 05-08: lib/base.yaml 의 analyzer: · language: 줄에 값이 붙었거나 language: 블록에 <이름>: true|false 가 아닌 줄이 있으면 종료 코드 70, 줄 끝 주석을 단 블록 꼴은 받아 [3/10] 비교로 간다 (M59 ~ M61 70 · M62 1; a14be4f)
- [Phase 05]: 05-09: lib/riverpod.yaml 의 riverpod_lint 선언은 따옴표를 벗겨 ^X.Y.Z 와 고정 버전 X.Y.Z 를 받고, 맵 꼴에서는 키 줄보다 깊은 줄 가운데서 version: 을 찾으며(키 순서 무관, 키 줄의 # 주석은 값이 아님), 범위 제약 등 그 밖의 꼴은 '꼴만 받는다' 와 읽은 값을 담은 문구로 종료 코드 70 이다 (05-REVIEW WR-05, 소유자 결정 R2-Q1 — M63 ~ M66). pubspecReleaseVersion 도 따옴표 version 을 받는다 (IN-01, M67; 644897f)
- [Phase 05]: 05-09: 05 리뷰 처리 기록은 fixed 12 · deferred 1 (WR-06 — D-09, 마일스톤 끝 /gsd-map-codebase) · open 0 이다 (8789cfe). README 의 산문은 plugin 버전 숫자 대신 lib/riverpod.yaml 의 선언을 가리키고, plugin 하한을 올릴 때 함께 고칠 자리 셋은 README 「이 저장소를 고치는 사람에게」 한 곳에 있다 (e46cff4)
- [Phase 05]: 05-09: gap 수정 05-07 ~ 05-09 를 git push origin gsd/v2.0-package-rework 한 줄로 올렸다 (2026-10-14T02:39:51Z, 92d478a..8789cfe, 25커밋, fast-forward, 둘째 push 없음, D-21 — 실행 뒤 보고). GitHub verify run 38502214557 success, job 4분 14초 (ubuntu-24.04 20261004.327.1), 로그에 [3/10] 통과와 점검 통과 (10개 중 10개). main 90a2736 · tag v1.3.0 하나 · PR 0 그대로이고 05-09 의 메타데이터 커밋은 origin 에 없다
- [Phase 05]: gap 수정 05-07 · 05-08 · 05-09 뒤 재검증 gaps_found 50/53 (2026-10-14) — 지난 gap 둘은 닫혔고, declaredRuleNames 가 열 0 의 linter: 글자로만 블록을 찾아 linter : · "linter": 철자로 적은 조각의 규칙을 건너뛰는 새 gap 1건 (VERIFY-06). 재리뷰 WR-07 ~ WR-10 · IN-08 은 verifier 판정 경고 · 정보, 처리 기록 open 5
- [Phase 05]: 2회차 gap 수정 계획 전 소유자 결정 (2026-10-14, 모두 권고대로) — gap(다른 철자의 `linter` 키)은 조각마다 받는 키를 닫힌 목록으로 막는다 (최상위 키 + `lib/codegen.yaml` 의 `analyzer:` 아래 `errors` · `exclude`, G2-Q1 — WR-10 도 함께 닫음). README 코드 블록 보조 검사 지적 넷(WR-07 · WR-08 · WR-09 · IN-08)은 검사를 넓히지 않고 README · `example/README.md` 문장을 실제 범위로 좁혀 skipped 로 둔다 (G2-Q2). 「받는 규칙」 표시 구역 밖(같은 절)의 목록 줄은 `[3/10]` 실패로 더한다 (G2-Q3)
- [Phase 05]: 2회차 gap 계획 중 소유자 결정 (2026-10-14, 모두 권고대로) — `lib/riverpod.yaml` 의 `plugins:` 아래 키도 `riverpod_lint` 만 받는다 (G2-Q4, 재현: 다른 plugin 키를 더해도 `[3/N]` passed=true), `tool/verify.dart` 의 (e) ~ (g) 문서 주석도 같은 범위로 좁힌다 (G2-Q5, 주석만)
- [Phase 05]: 2회차 gap 수정 계획 05-10 (wave 9, 닫힌 목록 · 표시 구역 밖 목록 줄 · 문장 좁히기, M68 ~ M78) · 05-11 (wave 10, 처리 기록 · push). 닫힌 목록 밖의 키는 종료 코드 70 이 아니라 `[3/10]` 실패다 — 70 이면 M45 · M35 · M46 의 확인된 결과가 바뀐다 (planner 판단). Fable 크레딧 소진으로 planner · checker 를 Opus 로 돌렸다 (소유자 결정). plan checker 2회차 통과 (6784f30, de44389, d691a6f)
- [Phase 05]: 05-10: 조각의 닫힌 목록(allowedTopLevelKeys · allowedChildKeys)은 종료 코드 70 이 아니라 [3/10] 실패로 알린다 — 예외 없이 블록만 더해 앞 기록의 70 · 실패가 그대로 남는다 (G2-Q1; M68 ~ M73, 회귀 입력 11개)
- [Phase 05]: 05-10: lib/riverpod.yaml 의 plugins: 바로 아래는 riverpod_lint 하나만 받는다 — 다른 plugin 키는 [3/10] 실패 (G2-Q4; M78 전체 실행에서는 따옴표 키 zz_quoted_plugin 을 pub.dev 에서 찾지 못해 plugin 을 쓰는 정답지 단계 넷도 함께 실패)
- [Phase 05]: 05-10: README 표시 구역이 든 절은 start 마커 앞의 가장 가까운 제목 다음 줄부터 end 마커 뒤의 첫 제목 앞까지이고(펜스 안의 # 줄은 제목이 아니다), 그 절의 구역 밖 목록 줄은 [3/10] 실패다 (G2-Q3; M74 ~ M77)
- [Phase 05]: 05-10: (e) · (f) · (g) 는 코드를 넓히지 않고 README 382행 · example/README 116 · 358 · 395 · 436행 · tool/verify.dart 주석 줄만 실제 범위로 좁혔다 (G2-Q2 · G2-Q5 — 코드 줄은 Task 2 커밋과 같다)
- [Phase 05]: 05-11: 05 리뷰 처리 기록은 fixed 13 · skipped 4 (WR-07 · WR-08 · WR-09 · IN-08 — G2-Q2, 문장을 검사 범위에 맞춤, 05-10 Task 3 d2d74c4) · deferred 1 (WR-06, D-09) · open 0 이다 — WR-10 은 05-10 Task 1 (02966c4) 의 닫힌 목록으로 fixed (G2-Q1, b8519d4). CHANGELOG 는 저장소 안쪽 변경이라 그대로
- [Phase 05]: 05-11: 2회차 gap 수정을 git push origin gsd/v2.0-package-rework 한 줄로 올렸다 (2026-10-14T06:33:56Z, 8789cfe..b8519d4, 19커밋, fast-forward, 둘째 push 없음, D-21 — 실행 뒤 보고). GitHub verify run 38522962086 success, job 4분 11초 (ubuntu-24.04 20261004.327.1), 로그에 [3/10] 통과와 점검 통과 (10개 중 10개) — 닫힌 목록 (a′) · 구역 밖 목록 줄 (d′) 이 runner 에서도 통과. main 90a2736 · tag v1.3.0 하나 · PR 0 그대로이고 05-11 의 메타데이터 커밋은 origin 에 없다
- [Phase 05]: 3회차 gap 수정 계획 전 소유자 결정 (2026-10-14, 모두 권고대로) — gap 1(WR-11, 주석 줄 끝 CR 뒤에 숨긴 규칙 · 키)은 `tool/verify.dart` 에서 YAML 을 줄로 나누는 자리를 모두 `LineSplitter` 하나로 맞춘다 (G3-Q1 — 막힌 셋 + `stripPlugins` · `readShippedPluginConstraint` · 진단 줄 번호로 규칙 이름을 읽는 곳). gap 2(WR-13 · WR-14)와 IN-08 의 남은 주석은 검사를 넓히지 않고 문장만 코드에 맞춘다 (G3-Q2). WR-12 는 문장에 정의를 적고 IN-09 는 읽는 법 한 줄을 넓힌다 — 코드는 바꾸지 않는다 (G3-Q3)
- [Phase 05]: 3회차 gap 계획 중 소유자 결정 (2026-10-14, 모두 권고대로) — `pubspecReleaseVersion` 도 같은 도우미로 줄을 나눠 한 줄씩 읽는다 (G3-R2-Q1, 재현: 지금 정규식은 주석 안 U+2028 뒤의 `version: 9.9.9` 를 읽음), 측정 도구 `tool/measure_rules.dart` 의 줄 나누기는 둔다 (G3-R2-Q2)
- [Phase 05]: 3회차 gap 수정 계획 05-12 (wave 11, `splitYamlLines` 도우미로 YAML 줄 나누기 일곱 자리 · 지워 보기 M79 ~ M85 · 문장 맞춤) · 05-13 (wave 12, 처리 기록 fixed 15 · skipped 7 · deferred 1 · open 0, push). Fable 크레딧 소진으로 planner · checker 를 Opus 로 돌렸다 (소유자 결정 G3-Q4). plan checker 1회차 통과 — info 2 (M80 의 교정 근거는 `stripPlugins`, Task 1 단언은 Task 1 커밋 시점에서 감사) (b986fc5, 207ef2d)
- [Phase 05]: 05-12: 옵션 YAML 과 pubspec 을 줄로 나누는 자리는 모두 splitYamlLines (LineSplitter) 하나를 쓴다 — CR 하나도 줄을 나눈다 (소유자 결정 G3-Q1 · G3-R2-Q1)
- [Phase 05]: 05-12: WR-12 · WR-13 · WR-14 · IN-08 은 문장 · 주석만 고치고 검사 코드는 그대로 둔다 (소유자 결정 G3-Q2 · G3-Q3)
- [Phase 05]: 05-13: 05 리뷰 처리 기록은 fixed 15 · skipped 7 · deferred 1 · open 0 이다 — WR-11 은 05-12 Task 1 (d771c0c) 로 fixed (G3-Q1 · G3-R2-Q1), IN-09 는 05-12 Task 2 (d8b61b0) 로 fixed (G3-Q3), WR-12 는 정의만 적어 skipped (G3-Q3), WR-13 · WR-14 는 문장을 검사 범위에 맞춰 skipped (G3-Q2), WR-06 은 deferred 그대로 (c2f275a). CHANGELOG 는 저장소 안쪽 변경이라 그대로
- [Phase 05]: 05-13: 3회차 gap 수정을 git push origin gsd/v2.0-package-rework 한 줄로 올렸다 (2026-10-14T13:03:22Z, b8519d4..c2f275a, 14커밋, fast-forward, 둘째 push 없음, D-21 — 실행 뒤 보고). GitHub verify run 38568654401 success, job 2분 54초 (ubuntu-24.04 20261012.334.1 — 이미지가 바뀌었고 통과), 로그에 [3/10] 통과와 점검 통과 (10개 중 10개) — splitYamlLines 줄 나누기가 runner 에서도 통과. main 90a2736 · tag v1.3.0 하나 · PR 0 그대로이고 05-13 의 SUMMARY · 메타데이터 커밋은 origin 에 없다
- [Phase 05]: 4회차 gap 수정 계획 전 소유자 결정 (2026-10-14 ~ 15, 모두 권고대로) — gap 1(WR-15 · WR-16 · 검증자 R1 ~ R3, 여러 줄 스칼라 · 중복 키를 줄 단위 reader 가 YAML 과 다르게 읽음)은 길 B: 루트 `pubspec.yaml` 의 `dev_dependencies` 에 `yaml` 을 두고, 줄 단위 reader 가 읽은 규칙 · 옵션 · 키 · plugin · version 을 `package:yaml` 해석 결과와 견줘 다르면 실패 — 줄 단위 reader 는 그대로 둔다. Phase 2 의 D-11(`dart:io` · `dart:convert` 만)을 이 목적에 한해 다시 정함 (G4-Q1). IN-10 은 문장만, IN-11 은 주석만 (G4-Q2). 모델은 Fable 로 시작해 크레딧 소진으로 Opus (G4-Q3)
- [Phase 05]: 4회차 gap 계획 중 소유자 결정 (2026-10-15, 모두 권고대로) — skill `spike-findings-woody-lints` 의 "`dart:io` · `dart:convert` 만 쓴다 (D-11)" 세 줄(SKILL.md 52 · analyze-run-and-verdict.md 13 · rule-status-check.md 14)을 제자리에서 고침 (G4-R2-Q1 · G4-R3-Q1), README 380행 · `example/README.md` 11행에 "`pubspec.yaml` 이 바뀐 뒤에는 `fvm dart pub get` 먼저" 를 더함 (G4-R2-Q2, 재현: 받아 둔 트리에서 그대로 돌리면 종료 코드 254 컴파일 오류). `.claude/CLAUDE.md` 261행(pubspec 설명에 `dev_dependencies` 없음)은 WR-06 과 함께 D-09 로 미룸
- [Phase 05]: 4회차 gap 수정 계획 05-14 (wave 13, `pubspec.yaml` dev_dependencies `yaml` · `[3/10]` 의 확인 (h) `compareLineReadersWithYaml` · 지워 보기 M86 ~ M91 · IN-10 · IN-11 문장 · skill 세 줄 · README 380 / `example/README.md` 11행) · 05-15 (wave 14, 처리 기록 WR-15 · WR-16 · IN-11 fixed · IN-10 skipped · open 0, push). planner · checker 는 Opus. plan checker 1회차 warning 4 (W1 아래 키 단언 · 더한 코드 줄 한정 · skill 셋째 줄 · 낡은 줄 번호) → 수정 1회 → 2회차 통과 — info 2 (05-15 push 앞 확인 없음은 D-21 그대로, 05-14 추정이 예산과 같음) (f52a920, c9ea115, e170e64)
- [Phase 05]: 05-14: [3/10] (h) compareLineReadersWithYaml 이 줄 단위 reader 다섯의 값을 package:yaml (dev_dependencies) 의 loadYaml 결과와 견주고, 다르거나 YAML 로 읽지 못하면 [3/10] 실패 블록 (G4-Q1)
- [Phase 05]: 05 리뷰 처리 기록은 fixed 18 · skipped 8 · deferred 1 · open 0 이다 — WR-15 · WR-16 fixed (77e0b88, G4-Q1), IN-11 fixed (0f62057, G4-Q2), IN-10 skipped (G4-Q2 문장을 실제 범위에 맞춤), WR-06 은 deferred 그대로
- [Phase 05]: 4회차 gap 수정을 git push origin gsd/v2.0-package-rework 한 줄로 올렸다 (c2f275a..2336ba0, 16커밋, fast-forward, D-21) — verify run 38639587080 success, job 4분 13초, CHANGELOG 는 그대로
- [Phase 05]: Phase 05 재리뷰 경고 IN-12 · IN-13 · IN-14 는 Phase 6 (Release) 로 미룸 (소유자 결정 2026-10-15, 권고안) — 셋 다 막는 쪽이고 Phase 6 이 pubspec.yaml version 을 바꿀 때 함께 고침; 처리 기록 deferred · ROADMAP Phase 6 Notes

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 1] 리뷰 지적 12건이 열려 있다 (`01-REVIEW-DISPOSITION.md`, 합계 16 — WR-05 는 05-04 가 닫음). 그중 WR-03 의 남은 두 경우 — README/CHANGELOG 만 고친 변경, 새 프리셋 파일 추가 — 는 `VERSIONING.md` 의 판정 순서와 기준표가 다른 등급을 내며 D-05 를 건드리는 소유자 결정이 필요하다. 2.0.0 의 등급(major)에는 영향이 없다
- [Phase 3] `riverpod_lint` 하한을 `^3.1.9` 로 올릴 때(PRESET-05): 3.1.9 는 Dart 3.13 이상을 요구한다. 지금은 `sdk: ^3.13.0` 이라 문제없지만 `VERSIONING.md` 에 이 전제가 적혀 있지 않다 (Backlog `Phase 999.1`)
- [Phase 2] 리뷰 지적 15건이 열려 있다 (`02-REVIEW-DISPOSITION.md`, 합계 17 — WR-01 ~ WR-06 · WR-08 · IN-01 ~ IN-08). `02-VERIFICATION.md` 의 "다음 phase 가 알아야 할 것" 1 ~ 7 이 Phase 3 · 4 · 6 에 걸리는 것을 추렸다. WR-06 은 Phase 6 이 `version` 을 올릴 때 종료 코드 69 로 만난다
- [Phase 3] 리뷰 지적 14건이 열려 있다 (`03-REVIEW-DISPOSITION.md`, warning 8 · info 6). 그중 검증 장치의 빈틈 셋은 Phase 4 · 5 가 배포 YAML 을 고칠 때 밟는 자리다 — WR-01 `[2/9]` 가 묶음 · 별칭을 보지 않아 거기 적은 규칙을 놓친다 (거짓 통과), WR-02 `riverpod_lint` 줄 끝 주석 · 마지막 줄바꿈 없음에서 종료 코드 70 (거짓 실패), WR-03 `base.yaml` 의 맵 형식 규칙(`rule: false`)에서 `[2/9]` 거짓 실패. Phase 4 계획 때 먼저 닫을지 정한다 (`03-VERIFICATION.md` Gaps Summary) — 정함 (2026-10-13, `04-CONTEXT.md` D-12): WR-01 은 plan 04-01 의 `[3/10]` 이 닫고, WR-02 는 Phase 5 의 첫 일, WR-03 은 목록 형식 관례로 피하고 열어 둔다. 04-13 뒤에는 `lib/base.yaml` 의 맵 형식 규칙 줄에서 `[3/10]` 이 거짓 통과 대신 종료 코드 70 으로 멈춘다 (README M31)
- [Phase 4] 리뷰 지적 18건이 열려 있다 (`04-REVIEW-DISPOSITION.md`, 합계 28 — open 18 · deferred 3 · fixed 7). deferred 셋: WR-11 (`[3/10]` 의 겹침 · `RULES.md` 일치가 `lib/base.yaml` 만 읽음) 은 Phase 5 의 VERIFY-06 과 함께 (ROADMAP Phase 5 Notes), CR-03 · WR-09 (측정 도구) 는 다음 재측정(RULES-13) 전에
- [Phase 6] `main` 병합은 `ref: main` 사용 프로젝트 5개에 새 버전을 배포하는 일이다. tag 와 병합의 순서를 계획 때 정한다
- [Phase 6] Phase 2 에서 미룬 확인 둘 — PR 에서 `verify` 가 도는지, 수동 실행 버튼 (ROADMAP 의 Phase 6 Notes)
- [Phase 5] `.claude/CLAUDE.md` 70 · 173 · 313행이 이미 걷어낸 루트 `analysis_options.yaml` exclude 를 "유지해야 한다" 고 지시한다 (05-REVIEW WR-06, D-09 로 deferred — 마일스톤 끝 `/gsd-map-codebase`). 그 전에 루트 exclude 를 건드리는 작업이 오면 그 지시를 따르지 않는다. `tool/measure_rules.dart` 의 `readRulesTable` · `tool/verify.dart` 의 `readUpstreamRules.readSet` 은 읽지 못하는 줄을 건너뛰는 꼴로 열어 둠 (소유자 결정 2026-10-14). 같은 파일 261행의 pubspec 설명에 4회차 gap 이 더할 `dev_dependencies` 가 없다 — 같은 D-09 로 미룸 (2026-10-15)

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-10-14T21:27:54.701Z
Stopped at: Completed 05-15-PLAN.md
Resume file: None
