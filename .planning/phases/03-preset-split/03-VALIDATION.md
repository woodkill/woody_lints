---
phase: "3"
slug: "preset-split"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-12"
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> 출처: `03-RESEARCH.md` § "Validation Architecture", § "계획이 정해야 할 것 — 근거와 권고" (권고 6, 9, 10, 11), § "spike 012 가 성공 기준 3 에 거는 조건". 시간 값은 spike 014 의 로컬 실측과 spike 017 의 GitHub runner 실측이다. 정답지 줄 수는 조사 단계의 scratch 복사본 실측(2026-10-12, Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9)이다. `fixtures/` 와 단계 9개는 아직 없으므로 아래 명령 가운데 새 fixture 를 가리키는 것은 이 phase 가 만든 뒤에야 돈다.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 없음 — Dart 테스트 패키지를 두지 않는다 (02-CONTEXT.md D-11). 검증 명령 `tool/verify.dart` 와 정답지가 테스트 하네스다 |
| **Config file** | `example/expected_diagnostics.txt` (바꾸지 않음, 기준 `19ae5ec`), 새 fixture 의 정답지 넷 (이 phase 가 만든다), `.github/workflows/verify.yml` (YAML 은 바꾸지 않음, 기준 `008ea3f`) |
| **Quick run command** | `fvm dart run tool/verify.dart` |
| **Full suite command** | 같은 명령 (단계 전부). CI 는 `dart run tool/verify.dart` |
| **Estimated runtime** | ~20 seconds (로컬 재실행. plugin 을 쓰는 fixture 넷 약 3.5초씩 + 쓰지 않는 둘 약 3초씩, spike 014). plugin 을 처음 준비하는 실행(첫 실행, 하한 상향 직후)은 fixture 마다 더 걸린다. GitHub runner 의 job 은 약 3분 20초 ~ 4분 20초 (spike 017) |

---

## Sampling Rate

- **After every task commit:** `fvm dart run tool/verify.dart` + 커밋 전 린터 `fvm dart analyze` (루트, 약 0.6초)
- **After every plan wave:** 같은 명령 + 그 커밋의 고정 단언 (`git diff --quiet <기준 커밋> -- <경로>`. 기준 커밋은 `03-RESEARCH.md` § "계획이 고정할 기준 커밋" 의 표를 따른다)
- **Before `/gsd-verify-work`:** 로컬 exit 0 · 모든 단계 통과, `example/expected_diagnostics.txt` 가 `19ae5ec` 그대로, GitHub 에서 성공한 `verify` 실행 1회 이상 (D-09), "가장 먼저 할 일" 의 세 입력이 모두 `--update` 에서 exit 1 로 재현됨, `example/README.md` 의 지워 보기 기록
- **Max feedback latency:** 30 seconds (로컬 재실행)

---

## Per-Task Verification Map

Task ID / Plan / Wave / Threat Ref 는 계획(`03-NN-PLAN.md`)이 확정된 뒤 채운다. 아래는 요구사항별 확인 방법이며 조사 문서에서 옮긴 것이다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 계획 뒤 채움 | — | — | (가장 먼저 할 일) | — | 망가진 배포 파일의 결과가 정답지로 굳지 않는다 | integration (변경을 만들고 되돌림) | 세 입력(닫지 않은 따옴표 / `rules:` 오타 / 겹친 규칙 + 없는 진단 코드)을 하나씩 넣고 `fvm dart run tool/verify.dart --update` → 규칙 이름 단계 실패, exit 1, `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt` 통과. 넣은 변경은 되돌린다 | ✅ (`tool/verify.dart`) | ⬜ pending |
| 계획 뒤 채움 | — | — | PRESET-04 | — | N/A | integration + git | `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt && fvm dart run tool/verify.dart` → exit 0, `example` 줄 통과 | ✅ (`example/`) | ⬜ pending |
| 계획 뒤 채움 | — | — | PRESET-08 | — | N/A | integration | 같은 명령 → `recommended (묶음)` 줄 통과 — 같은 실행의 `example` 결과와 줄 · 종료 코드가 같다 | ❌ W0 (`fixtures/recommended/`) | ⬜ pending |
| 계획 뒤 채움 | — | — | PRESET-01, VERIFY-05 | — | N/A | integration (대조군) | 같은 명령 → `base_only (기본만)` 줄 통과. 정답지는 `exit 2` + 18줄 — `riverpod_lint` 줄 0, 생성 파일 규칙 진단 4줄과 `invalid_annotation_target` 1줄 있음 | ❌ W0 (`fixtures/base_only/`) | ⬜ pending |
| 계획 뒤 채움 | — | — | PRESET-02 | — | N/A | integration | 같은 명령 → `base_riverpod` 줄 통과. 정답지는 `exit 2` + 21줄 (`riverpod_lint` 3줄 포함) | ❌ W0 (`fixtures/base_riverpod/`) | ⬜ pending |
| 계획 뒤 채움 | — | — | PRESET-03 | — | N/A | integration | 같은 명령 → `base_codegen` 줄 통과. 정답지는 `exit 0` + 13줄 — 생성 파일 줄 0, `invalid_annotation_target` 0. **범위: Dart 3.13.4 의 규칙 진단** (spike 012 — plugin 진단에는 묶음의 생성 파일 제외가 통하지 않는다) | ❌ W0 (`fixtures/base_codegen/`) | ⬜ pending |
| 계획 뒤 채움 | — | — | PRESET-05 | — | plugin 선언은 범위 지정(`^`)이고 하한이 3.1.9 다 | static + integration | `grep -c 'riverpod_lint: \^3.1.9' lib/riverpod.yaml` → 1, 하한 상향 커밋 앞뒤로 정답지 전부가 같다 (`git diff --quiet <앞 커밋> -- example/expected_diagnostics.txt fixtures/*/expected_diagnostics.txt`), `fvm dart run tool/verify.dart` exit 0 | ❌ W0 (`lib/riverpod.yaml`) | ⬜ pending |
| 계획 뒤 채움 | — | — | PRESET-06 | — | N/A | integration | `grep -c 'lib/analysis_options.yaml' analysis_options.yaml` → 0, 루트 `fvm dart analyze` → `No issues found!`, exit 0 (`plugins_in_inner_options` 없음) | ✅ (루트 `analysis_options.yaml`) | ⬜ pending |
| 계획 뒤 채움 | — | — | PRESET-07 | — | N/A | integration (대조군) | 같은 명령 → `overrides (끄는 설정)` 줄 통과. 끈 진단만 정답지에서 빠지고, 끄지 않은 같은 위반의 대조 줄은 남는다 (세 층 × 규칙 · plugin) | ❌ W0 (`fixtures/overrides/`) | ⬜ pending |
| 계획 뒤 채움 | — | — | (D-09) | — | workflow 가 읽기 권한만 가진다 (`permissions: contents: read`, 바꾸지 않음) | e2e (GitHub, 읽기 전용 조회) | 소유자 확인 뒤 push → `gh run list --workflow verify.yml --limit 1` → `completed success`, job 시간이 `timeout-minutes: 10` 안 | ✅ (`.github/workflows/verify.yml`) | ⬜ pending |

요구사항 ID 는 없지만 같은 방식으로 확인하는 것: 파일 분리 커밋은 구조 변경만 한다 — 조각을 원래 줄 순서로 이어 붙이면 `git show 90a2736:lib/analysis_options.yaml` 과 같다 (`03-RESEARCH.md` Pattern 1). `pubspec.yaml` 은 모든 커밋에서 `git diff --quiet 968a5bb -- pubspec.yaml`.

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tool/verify.dart` — 규칙 이름 단계의 통과 조건("exit 0 이고 진단 0건"), 규칙 검사 대상을 조각 셋으로, `stripPlugins` 가 `plugins:` 없는 파일을 받아들이도록, fixture 표 · 단계 9개 · fixture 마다 한 줄 · plugin 없는 fixture 의 `해당 없음` · `--update` 일괄 쓰기
- [ ] `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml`, 별칭이 된 `lib/analysis_options.yaml` — PRESET-01 ~ 05, 08
- [ ] 루트 `analysis_options.yaml` — `lib/analysis_options.yaml` 제외 삭제, `fixtures/**` 제외 — PRESET-06
- [ ] `fixtures/{recommended,base_only,overrides,base_riverpod,base_codegen}/` 전체 + 정답지 넷 — PRESET-01 ~ 03, 07, 08, VERIFY-05
- [ ] `.gitignore` 의 `!fixtures/*/pubspec.lock`
- [ ] `example/README.md` — 30행 · 81행, 단계 설명, fixture 표, 지워 보기 기록 M15 ~ M19
- [ ] `CHANGELOG.md` 의 `## 2.0.0 - 미출시` 항목
- [ ] Framework install: 없음

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| "가장 먼저 할 일" 의 세 입력에서 `--update` 가 정답지를 쓰지 않는다 — 고치기 전과 뒤의 결과를 기록으로 남긴다 | (가장 먼저 할 일) | 배포 파일을 일부러 망가뜨려 실패를 본 뒤 커밋하지 않고 되돌리는 일이라 상시 도는 검사로 남지 않는다 | 입력마다 `fvm dart run tool/verify.dart --update` 의 종료 코드 · 실패한 단계 · 정답지 변경 여부를 `example/README.md` 의 지워 보기 표에 M15 ~ M17 로 적는다. 끝에 `git status` 로 남은 변경이 없음을 확인한다 |
| 새 fixture 가 헛통과가 아니다 — 묶음에서 Riverpod 조각을 빼면 `example` 과 `recommended` 가 함께 실패하고, `overrides` 에서 plugin 의 `version` 줄을 빼면 끈 진단이 되살아난다 | PRESET-07, PRESET-08 | 위와 같다 | `lib/recommended.yaml` 의 `riverpod.yaml` include 줄, `fixtures/overrides/analysis_options.yaml` 의 `version:` 줄을 각각 임시로 지우고 같은 명령을 돌려 차이를 M18 · M19 로 기록한 뒤 되돌린다. 결과는 조사 단계의 예측(spike 010 · 012 의 모양)이므로 실제 값으로 적는다 |
| 이 phase 의 첫 push | (D-09) | 공개 저장소에 올리는 일은 되돌릴 수 없어 소유자 확인을 받는다 | 확인 요청에 올릴 커밋 목록, 실행할 명령(브랜치 이름 하나만, `--force` · `--tags` · `--all` 없음), 되돌릴 수 없다는 점, `.planning/` 이 함께 올라간다는 점을 쉬운 말로 적는다. 같은 phase 의 뒤 push 는 묻지 않고 실행한 뒤 보고한다 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
