---
phase: "2"
slug: "verification-harness"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-11"
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> 출처: `02-RESEARCH.md` § "Validation Architecture", § "계획이 정해야 할 것 — 근거와 권고" (권고 3, 5, 10). 시간 값은 조사 단계의 스크래치 복사본 실측과 spike 006 의 GitHub runner 실측이다. 이 저장소 본문에는 아직 `example/`, `tool/`, `.github/` 가 없으므로 아래 명령은 모두 이 phase 가 만든 뒤에야 돈다.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 없음 — Dart 테스트 패키지를 두지 않는다 (D-11). 검증 명령 `tool/verify.dart` 자체가 이 phase 의 테스트 하네스다 |
| **Config file** | `example/expected_diagnostics.txt` (정답지), `.github/workflows/verify.yml` — 둘 다 이 phase 가 만든다 |
| **Quick run command** | `fvm dart run tool/verify.dart` |
| **Full suite command** | 같은 명령 (단계 4개 전부). CI 는 `dart run tool/verify.dart` |
| **Estimated runtime** | ~5 seconds (로컬 재실행 기준. plugin 을 처음 준비하는 실행은 로컬 약 15초, GitHub runner 의 첫 분석 약 43초 · job 전체 약 2분) |

---

## Sampling Rate

- **After every task commit:** `fvm dart run tool/verify.dart` (스크립트가 생긴 뒤부터) + 커밋 전 린터 `fvm dart analyze` (루트)
- **After every plan wave:** 같은 명령 + 원격에 올린 뒤 `gh run list --workflow verify.yml --limit 1` 로 CI 결과 확인 (workflow 파일이 생긴 뒤부터)
- **Before `/gsd-verify-work`:** 로컬 exit 0, GitHub 에서 성공한 실행 1회 이상, VERIFY-08 · D-03 의 "지워 보기" 기록이 남아 있다
- **Max feedback latency:** 30 seconds (로컬)

---

## Per-Task Verification Map

Task ID / Plan / Wave / Threat Ref 는 계획(`02-NN-PLAN.md`)이 확정된 뒤 채운다. 아래는 요구사항별 확인 방법이며 조사 문서에서 옮긴 것이다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 계획 뒤 채움 | — | — | VERIFY-01 | — | N/A | integration (analyzer 실행) | `fvm dart run tool/verify.dart` → 정답지 비교 단계 통과, exit 0 | ❌ W0 (`example/`, `tool/verify.dart`) | ⬜ pending |
| 계획 뒤 채움 | — | — | VERIFY-02 | — | N/A | integration (변경을 만들고 되돌림) | 배포 파일에 `- unnecessary_await_in_return` 을 임시로 넣고 같은 명령 → 규칙 이름 단계 실패, exit 1. 넣은 줄은 되돌린다 | ❌ W0 | ⬜ pending |
| 계획 뒤 채움 | — | — | VERIFY-03 | — | N/A | smoke | `fvm dart run tool/verify.dart; echo $?` → 0 | ❌ W0 | ⬜ pending |
| 계획 뒤 채움 | — | — | VERIFY-04 | — | workflow 가 읽기 권한만 갖고(`permissions: contents: read`) job 에 `timeout-minutes` 가 있다 | e2e (GitHub, 읽기 전용 조회) | 원격에 올린 뒤 `gh run list --workflow verify.yml --limit 1` → `completed success`; workflow 파일에 `timeout-minutes:` 와 `contents: read` | ❌ W0 (`.github/workflows/verify.yml`) | ⬜ pending |
| 계획 뒤 채움 | — | — | VERIFY-07 | — | N/A | integration (변경을 만들고 되돌림) | `lib/` 에 `.dart` 파일 하나를 임시로 두고 같은 명령 → `lib/` 단계 실패, exit 1. 파일은 지운다 | ❌ W0 | ⬜ pending |
| 계획 뒤 채움 | — | — | VERIFY-08 | — | N/A | manual-with-record (변경을 만들고 되돌리며 diff 를 기록) | `02-RESEARCH.md` 권고 3 의 표를 실제 저장소에서 재현하고 기록을 남긴다 (아래 "Manual-Only Verifications") | ❌ W0 (기록 자리) | ⬜ pending |

요구사항 ID 는 없지만 같은 방식으로 확인하는 것: SDK 불일치 시 검증을 시작하지 않는다 (D-12), CI 환경에서 `--update` 가 거부된다 (D-14) — `CI=true fvm dart run tool/verify.dart --update` 가 0 이 아닌 종료 코드와 안내문을 낸다.

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `example/` 전체 (pubspec, lock, 옵션 파일, 샘플 Dart 파일, 정답지) — VERIFY-01, VERIFY-08
- [ ] `tool/verify.dart` — VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-07
- [ ] `.github/workflows/verify.yml` — VERIFY-04
- [ ] 루트 `analysis_options.yaml` 의 `example/**` 제외 — 커밋 전 린터가 깨끗하려면 `example/` 과 같은 변경에 든다
- [ ] `.gitignore` 의 `example/pubspec.lock` 예외 (D-05)
- [ ] "지워 보기" 기록 자리 — VERIFY-08, D-03
- [ ] Framework install: 없음

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 배포 파일에서 규칙 하나를 지운 변경과 `example/` 의 include 줄을 지운 변경이 각각 검증에서 실패한다 | VERIFY-08 | 변경을 만들어 실패를 본 뒤 커밋하지 않고 되돌리는 일이라 상시 도는 검사로 남지 않는다. 상시 대조군 fixture 는 Phase 3 (VERIFY-05) 의 일이다 | 규칙 삭제는 이 패키지가 실제로 추가하는 6개 중 하나로 한다 (D-01). 변경마다 `fvm dart run tool/verify.dart` 를 돌려 정답지와의 차이를 기록하고 되돌린다. 끝에 `git status` 로 남은 변경이 없음을 확인한다 |
| "나오면 안 되는 경고" 샘플이 헛통과가 아니다 — 배포 파일의 해당 설정을 지우면 정답지와 달라진다 | VERIFY-08 (D-03) | 위와 같다 | `analyzer.exclude` 의 두 항목과 `analyzer.errors` 블록을 각각 임시로 지우고 같은 명령을 돌려 차이를 기록한 뒤 되돌린다. `errors:` 는 한 줄이 아니라 블록째 지운다 (조사 문서 권고 3) |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
