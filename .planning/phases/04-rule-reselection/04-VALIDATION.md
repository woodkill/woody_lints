---
phase: "4"
slug: "rule-reselection"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-13"
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> 출처: `04-RESEARCH.md` § "Validation Architecture", § 4 (`tool/verify.dart` 의 변경), § 8 (D-07 의 비공개 정보 점검), § "Common Pitfalls". 시간 값은 조사 단계의 추정이다 (실측 1회 약 32분은 spike 021 ~ 023 의 그룹 · apply 시간에서 셈한 추정). `tool/measure_rules.dart`, `RULES.md`, `tool/verify.dart` 의 새 단계는 아직 없으므로 아래 명령 가운데 그것들을 가리키는 것은 이 phase 가 만든 뒤에야 돈다.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 없음 — Dart 테스트 패키지를 두지 않는다 (02-CONTEXT.md D-11). 검증 명령 `tool/verify.dart` (정답지 비교 + 단계 검사), 루트 `fvm dart analyze`, `tool/measure_rules.dart` 의 자기 판정(회차 `valid` · 저장소 지문), `04-RESEARCH.md` § 8 의 grep 점검이 하네스다 |
| **Config file** | `tool/verify.dart` 의 `fixtures` 표와 새 단계가 읽는 목록, `RULES.md` 의 마커 구역 (이 phase 가 만든다), 정답지 다섯 (`example/expected_diagnostics.txt`, `fixtures/{base_only,base_riverpod,base_codegen,overrides}/expected_diagnostics.txt`) |
| **Quick run command** | `fvm dart analyze && fvm dart run tool/verify.dart` |
| **Full suite command** | 위 둘 + `04-RESEARCH.md` § 8 의 점검 (1) ~ (4) + (로컬만) `fvm dart run tool/measure_rules.dart` 의 실측 · `--report` 단언 |
| **Estimated runtime** | ~25 seconds (루트 분석 약 1초 + `verify.dart` plugin 준비된 상태 약 22초. 처음 실행은 약 69초). 실측 1회는 약 32분 (추정, 로컬만). GitHub runner 의 job 은 약 3분 30초 ~ 4분 7초 (Phase 03 기록) |

---

## Sampling Rate

- **After every task commit:** `fvm dart analyze` + `fvm dart run tool/verify.dart` + § 8 의 (1) ~ (3). 결정 묶음 커밋은 `--update` 전에 보통 실행으로 정답지 diff 를 먼저 본다
- **After every plan wave:** 위 + § 8 의 (4), `example/lib` 와 `fixtures/*/lib` 의 샘플이 같은지 (`suppress/` 제외), 실측 wave 는 `measure_rules.dart` 의 지문 비교 · 회차 `valid` 전부
- **Before `/gsd-verify-work`:** 로컬 `verify` 종료 코드 0 · 모든 단계 통과, 첫 push 뒤 GitHub `verify` 성공 1회 이상, `--report` 단언 전부 통과, § 8 전부 0, `example/README.md` 의 새 지워 보기 기록
- **Max feedback latency:** 30 seconds (로컬 `verify` 재실행. 실측은 표본 추출 대상이 아니다 — wave 하나에 한 번)

---

## Per-Task Verification Map

Task ID / Plan / Wave / Threat Ref 는 계획(`04-NN-PLAN.md`)이 확정된 뒤 채운다. 아래는 요구사항별 확인 방법이며 조사 문서에서 옮긴 것이다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 계획 뒤 채움 | — | — | RULES-01 | — | N/A | 단계 검사 (CI) | `fvm dart run tool/verify.dart` → 새 단계의 기반 세트 겹침 확인 통과. 보조: `lib/base.yaml` 에서 `sized_box_for_whitespace` · `sort_child_properties_last` · `slash_for_doc_comments` · `use_build_context_synchronously` · `avoid_print` · `control_flow_in_finally` 선언 줄이 0 | ❌ W0 (새 단계) | ⬜ pending |
| 계획 뒤 채움 | — | — | RULES-02 | — | N/A | grep (CI 가능) | `grep -c -E 'require_trailing_commas\|public_member_api_docs\|trailing_commas' lib/base.yaml` → 0 | ✅ (명령만) | ⬜ pending |
| 계획 뒤 채움 | — | — | RULES-03 | — | N/A | 데이터 검사 (로컬) | `measure_rules.dart --report` 가 후보 행 수와 빈 칸 0 을 단언 (exit 0), `RULES.md` § 실측 기록에 그 표 | ❌ W0 (`tool/measure_rules.dart`) | ⬜ pending |
| 계획 뒤 채움 | — | — | RULES-04 | — | N/A | 데이터 검사 (로컬) | 같은 `--report` 가 `no_dynamic_casts` · `no_raw_types` · `strict-inference` 행을 단언 | ❌ W0 | ⬜ pending |
| 계획 뒤 채움 | — | — | RULES-05 | — | 무효 회차의 수치가 표에 쓰이지 않는다 | 데이터 검사 (로컬) | `--report` 가 `valid` 가 아닌 회차를 참조한 행 0 을 단언, 회차마다 SDK / 기반 세트 / plugin 버전 필드가 있다 | ❌ W0 | ⬜ pending |
| 계획 뒤 채움 | — | — | RULES-06 | — | N/A | 단계 검사 (CI) | `fvm dart run tool/verify.dart` → 새 단계의 `RULES.md` ↔ `lib/base.yaml` 확인 통과. 지워 보기 기록으로 헛통과가 아님을 보인다 | ❌ W0 (새 단계, `RULES.md`) | ⬜ pending |
| 계획 뒤 채움 | — | — | RULES-07 | — | N/A | grep + 사람 확인 | `grep -c '성능 향상' lib/base.yaml` → 0 (D-18). 나머지 사유 주석은 checkpoint 에서 소유자가 `RULES.md` 의 켠 이유와 함께 본다 | ✅ (명령만) | ⬜ pending |
| 계획 뒤 채움 | — | — | RULES-08 | — | N/A | 데이터 검사 (로컬) | `--report` 가 (후보 − 켠 규칙 − 켜지 않은 규칙 표의 이름 − v2 로 미룸) = 0개 와 B-7 의 상태 행을 단언 | ❌ W0 | ⬜ pending |
| 계획 뒤 채움 | — | — | DOCS-11 | — | N/A | 데이터 검사 | `RULES.md` 의 켠 규칙 구역의 모든 행에 빈 칸이 없다 (`--report` 또는 `awk -F'|'` 한 줄) | ❌ W0 (`RULES.md`) | ⬜ pending |
| 계획 뒤 채움 | — | — | (D-12 WR-01) | — | N/A | 단계 검사 (CI) | 새 단계가 `lib/recommended.yaml` · `lib/analysis_options.yaml` 에 `include:` 밖의 내용이 있으면 실패. 지워 보기 기록 | ❌ W0 (새 단계) | ⬜ pending |
| 계획 뒤 채움 | — | — | (D-07) | — | 비공개 사용 프로젝트의 경로 · 메시지 · 코드가 저장소와 `.planning/` 에 없다 | grep (커밋 전) | `04-RESEARCH.md` § 8 의 (1) ~ (4) 모두 0줄 / `LEAK?` 0 | ✅ (명령만) | ⬜ pending |
| 계획 뒤 채움 | — | — | (D-09) | — | 측정 도구가 원본 · 저장소를 바꾸지 않는다 | 자기 판정 (로컬) | `measure_rules.dart` 의 단계마다 저장소 지문 전후 동일, 작업 폴더가 저장소 밖이 아니면 시작 전 exit 1 | ❌ W0 | ⬜ pending |
| 계획 뒤 채움 | — | — | (D-20) | — | N/A | 실행 기록 | 삭제 커밋에서 `fvm dart run tool/verify.dart --update` → 바뀐 정답지 없음, `git diff --stat -- '*expected_diagnostics.txt'` 비어 있음 | ✅ | ⬜ pending |
| 계획 뒤 채움 | — | — | (D-10) | — | N/A | 정답지 비교 (CI) | 묶음 커밋의 정답지 `git diff` 에서 더한 줄이 새 규칙의 샘플과 하나씩 대응, `fvm dart run tool/verify.dart` exit 0 | ✅ (장치), ❌ (샘플) | ⬜ pending |
| 계획 뒤 채움 | — | — | (D-22) | — | workflow 가 읽기 권한만 가진다 | e2e (GitHub, 읽기 전용 조회) | 소유자 확인 뒤 첫 push → `gh run list --workflow verify.yml --limit 1` → `completed success` | ✅ (`.github/workflows/verify.yml`) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tool/measure_rules.dart` — RULES-03 · 04 · 05 · 08 의 데이터 검사(`--report` 단언)를 포함해 만든다
- [ ] `tool/verify.dart` 의 새 단계 — RULES-01 · 06, D-12 WR-01 의 확인
- [ ] `RULES.md` 의 마커 구역 — RULES-06 확인의 대상
- 프레임워크 설치: 없음

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 후보마다 채택 / 미채택 결정 | RULES-06 (로드맵 D13) | 소유자가 정한다 — 이 phase 는 소유자 검토 없이 끝나지 않는다 (CONTEXT D-04) | 묶음마다 터미널 요약(규칙 / 경고 / `dart fix` 로 사라진 줄 / 고친 뒤 새 error / 권고 / 이유)을 보이고 "권고대로" 또는 바꿀 규칙을 받는다. strict 3개 · `unnecessary_ignore` · import 쌍 · fire-and-forget · 비호환 쌍 · 상태 출처가 갈리는 규칙은 하나씩 묻는다 |
| 사유 주석이 사실과 맞다 | RULES-07 | 문장의 사실 여부는 grep 으로 가를 수 없다 | checkpoint 에서 `lib/base.yaml` 의 규칙별 한 줄 주석과 `RULES.md` 의 켠 이유를 나란히 보인다 |
| 실측 실행 | RULES-03 · 04 · 05 | 비공개 사용 프로젝트가 있어야 돈다 — CI 에서 돌지 않는다 (D-09) | 소유자가 원본 경로를 `--source` 로 주고 로컬에서 실행. 결과의 판정은 위의 `--report` 단언이 자동으로 한다 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
