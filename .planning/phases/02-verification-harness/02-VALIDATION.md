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

Task ID / Plan / Wave / Threat Ref 는 2026-10-11 확정된 계획(`02-01-PLAN.md` ~ `02-04-PLAN.md`)의 값이다. Task ID 는 `{plan}-T{n}` (plan 안의 n 번째 task). 명령은 각 plan 의 `<automated>` 에서 요구사항에 해당하는 조각을 옮긴 것이고, 긴 복합 명령은 plan 을 가리킨다. 모든 명령은 저장소 루트에서 돌린다.

커밋 계약 (Phase 1 과 같다): 실행자(gsd-executor)는 action → verify → 커밋 순서로 task 커밋을 만든다. 각 plan 의 `<automated>` 는 HEAD 를 읽지 않고 명령 출력과 작업 트리 파일만 보거나 고정 커밋 `90a2736` 과 비교한다 — 커밋 전(실행자 순서)과 커밋 뒤(아래 "After every task commit" 재실행) 판정이 같다. 02-04-T2 는 push 한 커밋(`origin/gsd/v2.0-package-rework` 의 tip)을 기준으로 run 을 찾으므로 실행자의 metadata 커밋이 뒤에 생겨도 판정이 같다. 작업 트리 청결 검사는 `.planning/` 을 뺀 범위로 본다. 임시 변경(VERIFY-02 · VERIFY-07 · VERIFY-08 의 지워 보기)은 같은 명령 안에서 만들고 되돌리며, 되돌림은 `git diff --quiet 90a2736 -- lib` · include 한 줄 대조 · `git status` 청결로 증명한다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 02-01-T1 | 02-01 | 1 | VERIFY-01 | T-02-01, T-02-02 | `example/pubspec.lock` 이 커밋 대상이고 루트 lock 은 무시된다 (`!example/pubspec.lock`); `example/**` 제외로 루트 분석이 깨끗하다 | integration (tracer — analyzer 실행, plugin 준비) | `OUT=$(fvm dart run tool/verify.dart 2>&1); RC=$?; test "$RC" = 0 && printf '%s\n' "$OUT" \| grep -qE '^\[1/1\] example/ 정답지 비교 \.+ 통과$'` + 정답지 비주석 2줄(`exit 2`, `lib/main.dart:N  warning  missing_provider_scope`) + `.plugin_manager` 폴더 1개 + `! git check-ignore -q example/pubspec.lock` + `fvm dart analyze` No issues found — 02-01-PLAN.md Task 1 | ❌ W0 (`example/`, `tool/verify.dart`) | ⬜ pending |
| 02-01-T2 | 02-01 | 1 | VERIFY-01 | — | N/A | integration (analyzer 실행) | `G=$(grep -v '^#' example/expected_diagnostics.txt \| grep -v '^$') && test "$(printf '%s\n' "$G" \| head -1)" = 'exit 2' && test "$(printf '%s\n' "$G" \| wc -l \| tr -d ' ')" = 17` + 규칙 16개 각 정확히 1줄 (`for r in …`) + `added_rules` 6 · `base_rules` 7 + `fvm dart run tool/verify.dart` exit 0 — 02-01-PLAN.md Task 2 | ❌ W0 | ⬜ pending |
| 02-02-T1 | 02-02 | 2 | VERIFY-03 | T-02-03, T-02-05 | `build/woody_rule_check` 가 실행 뒤 남지 않는다; 허용 인자는 `--update` 뿐 (모르는 인자 64) | smoke (shell, 단계 4개 전부) | `OUT=$(fvm dart run tool/verify.dart 2>&1); RC=$?; test "$RC" = 0 && printf '%s\n' "$OUT" \| grep -qxF '점검 통과 (4개 중 4개)' && test ! -e build/woody_rule_check` — 02-02-PLAN.md Task 1 | ❌ W0 | ⬜ pending |
| 02-02-T1 | 02-02 | 2 | VERIFY-07 | — | N/A | integration (변경을 만들고 되돌림 — 같은 명령 안에서) | `touch lib/_verify_probe.dart && fvm dart run tool/verify.dart >/dev/null 2>&1; P=$?; rm -f lib/_verify_probe.dart; test "$P" = 1 && git diff --quiet 90a2736 -- lib && test -z "$(git status --short --untracked-files=all -- lib)"` — 02-02-PLAN.md Task 1 (실제 실패 화면의 기록은 02-03-T1 의 M7) | ❌ W0 | ⬜ pending |
| 02-02-T1 | 02-02 | 2 | VERIFY-02 | T-02-03 | 규칙 검사 복사본은 `plugins:` 없이 저장소 안 `build/woody_rule_check/` 에만 쓰고 `finally` 로 지운다 | 구조 검사 (shell) + integration (02-03-T1 M6 이 실제 실패를 재현) | `grep -qF 'woody_rule_check' tool/verify.dart && grep -qF 'include_file_not_found' tool/verify.dart && test ! -e build/woody_rule_check` (깨끗한 배포 파일은 `[2/4] … 통과`); 실패 재현: 배포 파일에 `    - unnecessary_await_in_return` 을 임시로 넣고 같은 명령 → `[2/4] … 실패` + `deprecated_lint`, `[4/4] … 통과`, exit 1 — 02-03-PLAN.md Task 1 M6 (되돌린 뒤 `git diff --quiet 90a2736 -- lib`) | ❌ W0 | ⬜ pending |
| 02-02-T2 | 02-02 | 2 | VERIFY-01, VERIFY-03 | T-02-04 | 실제로 풀린 `riverpod_lint` 버전이 전용 상태 폴더에서 읽혀 화면과 정답지 머리 주석에 찍힌다 (D-07) | smoke (shell) + manual (`<human-check>` → end-of-phase UAT: 화면이 D-13 미리보기대로 읽히는가) | `OUT=$(fvm dart run tool/verify.dart 2>&1); RC=$?; test "$RC" = 0 && printf '%s\n' "$OUT" \| grep -qE '^SDK +Flutter 3\.47\.5 / Dart 3\.13\.4$' && printf '%s\n' "$OUT" \| grep -qE '^plugin +riverpod_lint [0-9]+\.[0-9]+\.[0-9]+$' && head -1 example/expected_diagnostics.txt \| grep -qE '^# 실측: Flutter 3\.47\.5 / Dart 3\.13\.4, riverpod_lint [0-9]+\.[0-9]+\.[0-9]+, [0-9]{4}-[0-9]{2}-[0-9]{2}$'` — 02-02-PLAN.md Task 2 | ❌ W0 | ⬜ pending |
| 02-03-T1 | 02-03 | 3 | VERIFY-08 | T-02-07 | 지워 보기 변경이 하나도 남지 않는다 — `lib` = `90a2736`, include 한 줄, `.fvmrc` 3.47.5, `lib/*.dart` 0건, `git status` 청결 | manual-with-record (변경 9건을 만들고 되돌리며 출력을 기록) + smoke (되돌림 증명) | `grep -q '"flutter": "3.47.5"' .fvmrc && git diff --quiet 90a2736 -- lib pubspec.yaml && test "$(find lib -name '*.dart' \| wc -l \| tr -d ' ')" = 0 && test "$(grep -v '^#' example/analysis_options.yaml \| grep -v '^$')" = 'include: package:woody_lints/analysis_options.yaml' && test -z "$(git status --short --untracked-files=all -- lib example .fvmrc analysis_options.yaml .gitignore tool)" && test ! -e build/woody_rule_check && OUT=$(fvm dart run tool/verify.dart 2>&1); RC=$?; test "$RC" = 0` — 02-03-PLAN.md Task 1 (M1 ~ M9 의 출력 원문은 SUMMARY) | ❌ W0 (`tool/verify.dart`) | ⬜ pending |
| 02-03-T2 | 02-03 | 3 | VERIFY-08 | T-02-08 | 기록에 로컬 절대 경로·토큰이 없다 | 구조 검사 (shell) + manual (`<human-check>` → end-of-phase UAT: 기록이 읽히는가) | `grep -qxF '## 검증이 실제로 잡아내는지 확인한 기록' example/README.md && test "$(grep '^\| M[1-9] \|' example/README.md \| wc -l \| tr -d ' ')" = 9 && grep -qF 'lib/should_not_appear.dart:5  warning  invalid_annotation_target' example/README.md && grep -qF 'deprecated_lint' example/README.md && grep -qF '커밋하지 않고 되돌렸다' example/README.md && ! grep -v '^#' example/README.md \| grep -q '/Users/'` + CHANGELOG `### 그 밖의 변경` 칸 순서와 옛 항목 불변 — 02-03-PLAN.md Task 2 | ❌ W0 (`example/README.md`) | ⬜ pending |
| 02-04-T1 | 02-04 | 4 | VERIFY-04 | T-02-09, T-02-10, T-02-11 | workflow 가 읽기 권한만 갖고(`contents: read`), `timeout-minutes: 10` 과 `concurrency.cancel-in-progress` 가 있으며, 예약 트리거·캐시·버전 숫자가 없다 | 구조 검사 (shell) | `F=.github/workflows/verify.yml; grep -qE '^\s+contents: read$' "$F" && grep -qE '^\s+timeout-minutes: 10$' "$F" && grep -qE '^\s+cancel-in-progress: true$' "$F" && grep -qE '^\s+workflow_dispatch:' "$F" && grep -qE '^\s+pull_request:' "$F" && grep -qE '^\s+flutter-version-file: \.fvmrc$' "$F" && grep -qE '^\s+run: dart run tool/verify\.dart$' "$F" && ! grep -v '^\s*#' "$F" \| grep -qE 'schedule:\|cron\|cache:\|flutter-version:\|3\.47\.5\|matrix\|tags:'` — 02-04-PLAN.md Task 1 | ❌ W0 (`.github/workflows/verify.yml`) | ⬜ pending |
| 02-04-T2 | 02-04 | 4 | VERIFY-04 | T-02-12, T-02-13 | push 는 브랜치 이름 하나만 (fast-forward), `main` 과 tag 는 그대로, PR 없음 | e2e (GitHub, push 뒤 읽기 전용 조회) | `git fetch origin --quiet && HEADS=$(git ls-remote --heads origin) && test "$(printf '%s\n' "$HEADS" \| wc -l \| tr -d ' ')" = 2 && printf '%s\n' "$HEADS" \| grep -qF "$(printf '90a2736b8d998c84467faf562a0fec720b797eaf\trefs/heads/main')" && R=$(git rev-parse origin/gsd/v2.0-package-rework) && git merge-base --is-ancestor "$R" HEAD && RUN=$(gh run list --workflow verify.yml --branch gsd/v2.0-package-rework --limit 20 --json status,conclusion,headSha --jq "[.[] \| select(.headSha == \"$R\")] \| .[0] \| \"\(.status) \(.conclusion)\"") && test "$RUN" = 'completed success'` + tags `v1.3.0` 뿐 + `gh pr list` 0 — 02-04-PLAN.md Task 2 | ❌ W0 (원격 run) | ⬜ pending |

요구사항 ID 는 없지만 같은 방식으로 확인하는 것: SDK 불일치 시 검증을 시작하지 않는다 (D-12) — 02-03-T1 의 M9 (`.fvmrc` 를 임시로 `0.0.0` 으로 바꾸고 `.fvm/flutter_sdk/bin/dart run tool/verify.dart` → exit 78, 되돌림은 `grep -q '"flutter": "3.47.5"' .fvmrc`); CI 환경에서 `--update` 가 거부된다 (D-14) — 02-01-T1 · 02-02-T1 의 `CI=true fvm dart run tool/verify.dart --update >/dev/null 2>&1; test "$?" = 64` 와 02-03-T1 의 M8.

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `example/` 전체 (pubspec, lock, 옵션 파일, 샘플 Dart 7개, 정답지) — VERIFY-01, VERIFY-08 — plan 02-01 (Wave 1)
- [ ] `tool/verify.dart` — VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-07 — 정답지 비교 경로는 plan 02-01 (Wave 1), 단계 4개 · D-07 · D-12 · D-13 · D-14 는 plan 02-02 (Wave 2)
- [ ] `.github/workflows/verify.yml` — VERIFY-04 — plan 02-04 (Wave 4)
- [ ] 루트 `analysis_options.yaml` 의 `example/**` 제외 (+ `include: package:flutter_lints/flutter.yaml`) — 커밋 전 린터가 깨끗하려면 `example/` 과 같은 커밋에 든다 — plan 02-01 Task 1
- [ ] `.gitignore` 의 `!example/pubspec.lock` (D-05) 과 `build/` — plan 02-01 Task 1
- [ ] "지워 보기" 기록 자리 `example/README.md` — VERIFY-08, D-03 — plan 02-03 (Wave 3)
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
