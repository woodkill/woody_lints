---
gsd_state_version: "1.0"
milestone: v2.0
milestone_name: Package Rework
current_phase: 02
current_phase_name: Verification Harness
status: executing
stopped_at: Completed 02-02-PLAN.md
last_updated: "2026-10-11T16:43:05.651Z"
last_activity: 2026-10-12
last_activity_desc: Phase 02 execution started
state_head: 19ae5ec6b10ff5798b4ab2f5e6e55ac7e5a8bc61
progress:
  total_phases: 6
  completed_phases: 1
  total_plans: 8
  completed_plans: 6
  percent: 17
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-11)

**Core value:** 사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.
**Current focus:** Phase 02 — Verification Harness

## Current Position

Phase: 02 (Verification Harness) — EXECUTING
Plan: 3 of 4
Status: Ready to execute
Last activity: 2026-10-12 — Phase 02 execution started

Progress: [██░░░░░░░░] 17%

## Performance Metrics

**Velocity:**
- Total plans completed: 4
- Average duration: - min
- Total execution time: 0.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 4 | - | - |

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

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 2] Spike 선행: plugin 실패 시 종료 코드, `riverpod_lint` 15개 규칙의 심각도, GitHub cold runner 동작이 확인되지 않았다
- [Phase 3] Spike 선행: 이 저장소 구조에서의 include 경유 plugin 로드와 3단 include 가 확인되지 않았다. 실패하면 URI 결정을 소유자와 다시 본다
- [Phase 4] D13: 규칙별 채택은 소유자 검토 지점이다. 실측 표 없이는 결정하지 않는다
- [Phase 1] 리뷰 지적 13건이 열려 있다 (`01-REVIEW-DISPOSITION.md`, 합계 16). 그중 WR-03 의 남은 두 경우 — README/CHANGELOG 만 고친 변경, 새 프리셋 파일 추가 — 는 `VERSIONING.md` 의 판정 순서와 기준표가 다른 등급을 내며 D-05 를 건드리는 소유자 결정이 필요하다. 2.0.0 의 등급(major)에는 영향이 없다
- [Phase 3] `riverpod_lint` 하한을 `^3.1.9` 로 올릴 때(PRESET-05): 3.1.9 는 Dart 3.13 이상을 요구한다. 지금은 `sdk: ^3.13.0` 이라 문제없지만 `VERSIONING.md` 에 이 전제가 적혀 있지 않다 (Backlog `Phase 999.1`)
- [Phase 6] `main` 병합은 `ref: main` 사용 프로젝트 5개에 새 버전을 배포하는 일이다. tag 와 병합의 순서를 계획 때 정한다

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-10-11T16:43:05.633Z
Stopped at: Completed 02-02-PLAN.md
Resume file: None
