---
gsd_state_version: "1.0"
milestone: v2.0
milestone_name: Package Rework
current_phase: 01
current_phase_name: Baseline and Toolchain
status: verifying
stopped_at: Completed 01-04-PLAN.md
last_updated: "2026-10-11T08:26:09.863Z"
last_activity: 2026-10-11
last_activity_desc: Phase 01 execution started
state_head: e7a0457f22318a28512240a1c7c4d7fc95a6b93d
progress:
  total_phases: 6
  completed_phases: 0
  total_plans: 4
  completed_plans: 4
  percent: 0
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-11)

**Core value:** 사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.
**Current focus:** Phase 01 — Baseline and Toolchain

## Current Position

Phase: 01 (Baseline and Toolchain) — EXECUTING
Plan: 4 of 4
Status: Phase complete — ready for verification
Last activity: 2026-10-11 — Phase 01 execution started

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Velocity:**
- Total plans completed: 0
- Average duration: - min
- Total execution time: 0.0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| - | - | - | - |

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

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 2] Spike 선행: plugin 실패 시 종료 코드, `riverpod_lint` 15개 규칙의 심각도, GitHub cold runner 동작이 확인되지 않았다
- [Phase 3] Spike 선행: 이 저장소 구조에서의 include 경유 plugin 로드와 3단 include 가 확인되지 않았다. 실패하면 URI 결정을 소유자와 다시 본다
- [Phase 4] D13: 규칙별 채택은 소유자 검토 지점이다. 실측 표 없이는 결정하지 않는다
- [Phase 6] `main` 병합은 `ref: main` 사용 프로젝트 5개에 새 버전을 배포하는 일이다. tag 와 병합의 순서를 계획 때 정한다

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-10-11T08:23:32.796Z
Stopped at: Completed 01-04-PLAN.md
Resume file: None
