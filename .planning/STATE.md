---
gsd_state_version: "1.0"
milestone: v2.0
milestone_name: Package Rework
current_phase: 1
current_phase_name: Baseline and Toolchain
status: planning
stopped_at: Phase 1 context gathered
last_updated: "2026-10-11T02:29:22.572Z"
last_activity: 2026-10-11
last_activity_desc: Roadmap 작성 (6 phases, v1 요구사항 43/43 매핑)
state_head: add8780327232284e3760a0865504c3735c5889c
progress:
  total_phases: 6
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-11)

**Core value:** 사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.
**Current focus:** Phase 1 — Baseline and Toolchain

## Current Position

Phase: 1 of 6 (Baseline and Toolchain)
Plan: Not started
Status: Ready to plan
Last activity: 2026-10-11 — Roadmap 작성 (6 phases, v1 요구사항 43/43 매핑)

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

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 1] D4: `v1.3.0` tag 의 원격 push 는 실행 시점에 소유자의 명시적 확인이 필요하다
- [Phase 1] D8: 버전 정책 세부와 다음 버전 번호가 정해지지 않았다 (조사 권고 2.0.0)
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

Last session: 2026-10-11T02:29:22.563Z
Stopped at: Phase 1 context gathered
Resume file: .planning/phases/01-baseline-and-toolchain/01-CONTEXT.md
