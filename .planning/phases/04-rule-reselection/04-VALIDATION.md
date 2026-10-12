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

Task ID / Plan / Wave / Threat Ref 는 계획(`04-01` ~ `04-10-PLAN.md`, 2026-10-13)으로 채웠다. Task ID 는 `<plan>-T<n>` 이고, 명령은 각 PLAN 의 `<automated>` 에 그대로 있다 (여기는 요지). W0 항목(`tool/verify.dart` 새 단계 · `tool/measure_rules.dart` · `RULES.md` 마커)은 wave 1 · 2 의 plan 이 만든다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 04-01-T1 | 04-01 | 1 | RULES-01 | T-04-01 | N/A | 단계 검사 (CI) | `fvm dart run tool/verify.dart` → `[3/10] 배포 파일의 구성 … 통과` (겹침 검사). 보조: `grep -E '^\s*- [A-Za-z0-9_]+' lib/base.yaml \| wc -l` = 6 이고 그 여섯이 이 패키지만의 규칙; M20 (`avoid_print` 를 더하면 `[3/10]` 만 실패) | ❌ W0 → 04-01-T1 이 만든다 | ⬜ pending |
| 04-01-T1 | 04-01 | 1 | RULES-02 | T-04-01 | N/A | grep (CI 가능) | `grep -c -E 'require_trailing_commas\|public_member_api_docs\|trailing_commas' lib/base.yaml` → 0, `^\s*#\s*-\s` 줄 0, `formatter:` 줄 0 | ✅ (명령만) | ⬜ pending |
| 04-04-T2 | 04-04 | 3 | RULES-03 | T-04-11 | N/A | 데이터 검사 (로컬) | `fvm dart run tool/measure_rules.dart --report --in tool/measurements/*-R1.json` → exit 0 (행 133 · 결정 대상 121 행의 빈 칸 0 · 참조 회차 valid); 04-09-T1 의 `--report --write` 가 `RULES.md` § 실측 기록에 그 표 | ❌ W0 → 04-02 · 04-03 이 만든다 | ⬜ pending |
| 04-04-T2 | 04-04 | 3 | RULES-04 | T-04-11 | N/A | 데이터 검사 (로컬) | 같은 `--report` + python 단언: `no_dynamic_casts` · `no_raw_types` · `strict-inference` 행에 값, `strict-inference` 강도 `warning` | ❌ W0 → 04-02 | ⬜ pending |
| 04-04-T2 | 04-04 | 3 | RULES-05 | T-04-12 | 무효 회차의 수치가 표에 쓰이지 않는다 | 데이터 검사 (로컬) | python 단언: 모든 회차 `valid: true`, 회차마다 `dart` · `flutter` · `baseSet` · `plugin` · `languageVersion` · `sdkConstraint` · `dartFiles`, 행이 참조하는 회차 모두 valid; 0줄 행은 `markerDetected` 가 정해져 있다 (04-03-T1 이 표식 전부의 검출을 example/ 로 확인) | ❌ W0 → 04-02 · 04-03 | ⬜ pending |
| 04-01-T2 · 04-06-T1 ~ T3 · 04-07-T1 ~ T2 · 04-08-T3 | 04-01 · 04-06 · 04-07 · 04-08 | 1 · 5 · 6 · 7 | RULES-06 | T-04-02 · T-04-16 · T-04-20 | N/A | 단계 검사 (CI) + python | `[3/10]` (c) `RULES.md` ↔ `lib/base.yaml`; M21 · M22 · M25 로 헛통과 아님; 묶음 커밋마다 python 단언 "더한 규칙 == `04-DECISIONS.md` 의 켬" | ❌ W0 → 04-01-T1 | ⬜ pending |
| 04-06-T1 | 04-06 | 5 | RULES-07 | T-04-17 | N/A | grep + python + 사람 확인 | `grep -c '성능 향상' lib/base.yaml` → 0 (D-18); python 단언 "켠 이유(`RULES.md`) == 사유 주석(`base.yaml`)" (A5 를 자동화); 문장의 사실 여부는 04-05 checkpoint 에서 소유자가 본다 | ✅ (명령만) | ⬜ pending |
| 04-07-T3 · 04-08-T3 · 04-09-T1 | 04-07 · 04-08 · 04-09 | 6 · 7 · 8 | RULES-08 | T-04-21 | N/A | 데이터 검사 (로컬) | `fvm dart run tool/measure_rules.dart --audit` → exit 0, 04-07 에서 `보류 1`, 04-08 · 04-09 에서 `보류 0` (후보 133 ∪ B-7 31 ⊆ 켠 ∪ 켜지 않음, 접두사 7종) | ❌ W0 → 04-03-T2 | ⬜ pending |
| 04-06-T1 ~ T3 · 04-07-T1 ~ T2 · 04-09-T1 | 04-06 · 04-07 · 04-09 | 5 · 6 · 8 | DOCS-11 | T-04-17 | N/A | 데이터 검사 | 묶음 커밋의 python 단언: 켠 규칙 행의 칸 여섯이 비어 있지 않고 `(실측 전` 없음, 실측 칸 == R1 `counts`; `--audit` (d) | ❌ W0 → 04-01-T1 (`RULES.md`) | ⬜ pending |
| 04-01-T2 | 04-01 | 1 | (D-12 WR-01) | T-04-02 | N/A | 단계 검사 (CI) | M23 · M24: `lib/recommended.yaml` · `lib/analysis_options.yaml` 에 규칙 세 줄 → `[3/10]` 실패; 04-09-T2 가 `03-REVIEW-DISPOSITION.md` WR-01 을 `fixed` 로 | ❌ W0 → 04-01-T1 | ⬜ pending |
| 04-01-T2 · 04-04-T3 · 04-05-T1 · 04-08-T2 · 04-09-T1 ~ T2 · 04-10-T1 | 04-01 · 04-04 · 04-05 · 04-08 · 04-09 · 04-10 | 1 · 3 · 4 · 7 · 8 · 9 | (D-07) | T-04-03 · T-04-06 · T-04-11 · T-04-15 · T-04-23 · T-04-25 · T-04-26 | 비공개 사용 프로젝트의 경로 · 메시지 · 코드가 저장소와 `.planning/` 에 없다 | grep (커밋 전) | § 8 (1) ~ (3) 모두 0 (04-04-T3 · 04-10-T1 은 (4) 도 — 원본 경로는 환경변수로만); 도구 출력 구조에 경로 · 메시지 필드 없음 (`"message"` 0) | ✅ (명령만) | ⬜ pending |
| 04-02-T1 ~ T2 · 04-04-T2 | 04-02 · 04-04 | 1 · 3 | (D-09) | T-04-04 · T-04-05 · T-04-08 · T-04-12 | 측정 도구가 원본 · 저장소를 바꾸지 않는다 | 자기 판정 (로컬) | `--work` 가 저장소 안이면 exit 64 (아무것도 만들지 않음); smoke · 실측 전후 저장소 `git status` 동일; 단계마다 지문 비교 (다르면 exit 1); 원본 `git status --porcelain` 줄 수 전후 동일 | ❌ W0 → 04-02-T1 | ⬜ pending |
| 04-01-T1 | 04-01 | 1 | (D-20) | T-04-01 | N/A | 실행 기록 | 삭제 커밋에서 `fvm dart run tool/verify.dart --update` → `바뀐 정답지가 없다`, 정답지 다섯이 `19ae5ec` · `91bbeec` · `9ed0fe5` 와 `git diff --quiet`; 04-01-T2 가 README 확인 기록 (i) 로 남긴다 | ✅ | ⬜ pending |
| 04-06-T2 ~ T3 · 04-07-T1 ~ T2 | 04-06 · 04-07 | 5 · 6 | (D-10) | T-04-16 · T-04-20 | N/A | 정답지 비교 (CI) + python | 묶음 커밋의 python 단언: 정답지 다섯의 `+lib/` 줄 규칙 집합 == 더한 규칙, `-` 0, `exit` 불변 (`strict-inference` 때 `base_codegen` 만 `exit 2`); 04-09-T2 의 M25 와 확인 기록 (ii) | ✅ (장치), ❌ (샘플 — 그 plan 이 만든다) | ⬜ pending |
| 04-10-T1 ~ T3 | 04-10 | 9 | (D-22) | T-04-26 · T-04-27 · T-04-28 | workflow 가 읽기 권한만 가진다; `main` · tag 불변 | e2e (GitHub, 읽기 전용 조회) | push 전 점검(비공개 · fast-forward · `gh auth status`) → 소유자 확인 checkpoint → `git push origin gsd/v2.0-package-rework` → `gh run list` 의 HEAD run 이 `completed success`, 로그에 `점검 통과 (10개 중 10개)` 와 `[3/10] … 통과`, `main` `90a2736` · `v1.3.0` · PR 0 | ✅ (`.github/workflows/verify.yml`) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tool/measure_rules.dart` — RULES-03 · 04 · 05 · 08 의 데이터 검사(`--report` · `--audit` 단언)를 포함해 만든다 → 04-02 (핵심 · 단계) · 04-03 (표식 · 출력 모드), wave 1 · 2
- [ ] `tool/verify.dart` 의 새 단계 `[3/10] 배포 파일의 구성` — RULES-01 · 06, D-12 WR-01 의 확인 → 04-01-T1 (tracer), wave 1
- [ ] `RULES.md` 의 마커 구역 넷 — RULES-06 확인의 대상 → 04-01-T1, wave 1
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
