# Roadmap: woody_lints

## Milestones

- ✅ **v2.0 Package Rework** — Phases 1-6 (shipped 2026-10-17, 패키지 릴리스 `v2.0.0`) — [기록](milestones/v2.0-ROADMAP.md)

`v2.0` 은 GSD 마일스톤 번호이고, 패키지 릴리스 tag(`vX.Y.Z`)와 따로 간다. `git.create_tag` 는 꺼져 있어 GSD 는 tag 를 만들지 않는다.

## Phases

<details>
<summary>✅ v2.0 Package Rework (Phases 1-6) — SHIPPED 2026-10-17</summary>

- [x] Phase 1: Baseline and Toolchain (4/4 plans) — completed 2026-10-11
- [x] Phase 2: Verification Harness (5/5 plans) — completed 2026-10-12
- [x] Phase 3: Preset Split (4/4 plans) — completed 2026-10-12
- [x] Phase 4: Rule Reselection (13/13 plans) — completed 2026-10-13
- [x] Phase 5: Documentation (15/15 plans) — completed 2026-10-15
- [x] Phase 6: Release (15/15 plans) — completed 2026-10-17

전체 phase 내용: `milestones/v2.0-ROADMAP.md`, 요구사항: `milestones/v2.0-REQUIREMENTS.md`, 감사: `milestones/v2.0-MILESTONE-AUDIT.md`, phase 기록: `milestones/v2.0-phases/`

</details>

다음 마일스톤은 `/gsd-new-milestone` 으로 시작한다. Phase 번호는 7 부터 이어 간다.

## Backlog

### Phase 999.1: Follow-up — Phase 01 deferred UAT follow-up: Test 8 (BACKLOG)

**Goal:** Phase 01 검증 때 미룬 UAT 항목의 후속 작업을 마친다
**Source phase:** 01
**Deferred at:** 2026-10-11, `/gsd-verify-work 1` 세션 완료 시점
**Follow-ups:**
- [ ] Test 8: pass, 문장은 나중에 — (기록자 풀이) 8번은 통과이고, VERSIONING.md 30행에 전제 한 문장을 더하는 일만 나중으로 미룬다. 더할 내용: plugin 이나 기반 세트의 하한을 올릴 때는 새 하한 버전이 요구하는 Dart 버전을 보고, 그것이 이 패키지의 SDK 하한보다 높으면 판정 순서 1번의 첫째 조건(SDK 를 고쳐야 하나)이 예 다. 근거: riverpod_lint 3.1.9 는 Dart 3.13 이상, 3.1.3 은 3.10 이상을 요구한다 (01-VERIFICATION.md 의 coincidental_reliance_items) (deferred 2026-10-11)

### Phase 999.2: Follow-up — Phase 06 재리뷰 경고 IN-10 · IN-11 (BACKLOG)

**Goal:** gap 수정 2회차 뒤 재리뷰(`06-REVIEW.md`)가 찾은 info 둘을 다음에 그 파일을 손댈 때 고친다
**Source phase:** 06
**Deferred at:** 2026-10-17, `/gsd-execute-phase 06 --gaps-only` 검증 꼬리 (소유자 결정 — 미룸; verifier 판정 경고, 명시된 진실 밖)
**Follow-ups:**
- [ ] IN-10: `example/README.md` (06-08) 소절의 읽는 법 (4) · (5) 와 11행의 의존성 괄호를 06-12 뒤 동작에 맞춘다 — 지금 (5) 는 `# Changelog` 머리말이 통과한다고 현재형으로 말하지만 첫 줄 규칙 뒤로는 실패한다 (M113)
- [ ] IN-11: `tool/smoke.dart` 의 `killTree` 재확인 — SIGSTOP 이 성공한 pid 를 기록하고 SIGKILL 직전 표에 아직 남은 것은 사슬과 상관없이 끊어, 얼린 뒤 중간 프로세스가 먼저 끝난 자기 자손이 SIGCONT 로 풀려 살아남지 않게 한다 (reviewer · verifier 재현: P → A → B 에서 A 가 첫 표 직후 끝나면 B 가 남음); 06-13 must_have 4 의 "사슬 밖은 SIGCONT" 문장과 머리 주석의 범위 문장도 함께 고친다

### Phase 999.3: Follow-up — Phase 06 deferred UAT follow-up: Test 3 (BACKLOG)

**Goal:** Phase 06 검증 때 미룬 VERSIONING.md 문구 정리를 마친다
**Source phase:** 06
**Deferred at:** 2026-10-17, `/gsd-verify-work 06` 세션 완료 시점
**Follow-ups:**
- [ ] Test 3: VERSIONING.md 「판정 순서」 3번과 기준표에 'pubspec.yaml 의 dev_dependencies · 저장소 도구용 주석만 바뀐 것은 받는 쪽에 닿지 않으므로 저장소 안쪽(올리지 않음)' 을 정리한다 — 2.0.0 뒤 gap 수정(markdown dev 의존성 · 주석 3줄)이 버전을 올리지 않은 근거를 문서가 그대로 뒷받침하게. 지금은 3번("pubspec.yaml 이 바뀌긴 했나 → patch")과 기준표 "주석만 고침 → patch" 를 글자대로 읽으면 2.0.1 이고, 계획서가 근거로 든 "저장소 안쪽만 바뀜" 행에는 pubspec.yaml 이 없다. STATE Blockers 의 [Phase 1] WR-03 남은 두 경우(README · CHANGELOG 만 고친 변경, 새 프리셋 추가 — 판정 순서와 기준표가 다른 등급)와 같은 종류라 함께 본다 (deferred 2026-10-17)
