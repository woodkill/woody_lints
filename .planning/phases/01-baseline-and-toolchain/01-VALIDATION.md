---
phase: "1"
slug: "baseline-and-toolchain"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-11"
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> 출처: `01-RESEARCH.md` § "Validation Architecture", § "Code Examples" 의 "전체 검증 묶음". 명령은 모두 2026-10-11 에 이 머신에서 실측한 것이다.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 없음 — Dart 코드가 없는 설정 전용 패키지다. 검증은 셸 명령의 종료 코드와 출력 비교로 한다 |
| **Config file** | none — 이 phase 는 `tool/` 을 만들지 않는다 (검증 스크립트는 Phase 2 의 일) |
| **Quick run command** | 아래 "Per-Task Verification Map" 의 요구사항별 한 줄 명령 |
| **Full suite command** | `01-RESEARCH.md` § "Code Examples" 의 "전체 검증 묶음" 블록 (SC1 ~ SC5) |
| **Estimated runtime** | ~15 seconds (네트워크를 읽는 `git ls-remote` / `git fetch` 와 `dart pub get` 포함) |

---

## Sampling Rate

- **After every task commit:** 그 task 가 맡은 요구사항의 한 줄 명령을 돌린다
- **After every plan wave:** "전체 검증 묶음" 블록 전체를 돌린다 (SC3c 는 임시 사용 프로젝트가 남아 있을 때만)
- **Before `/gsd-verify-work`:** 묶음 전체가 PASS 이고, 소유자가 `VERSIONING.md` 를 읽고 1.3.0 / 2.0.0 사례의 판정에 동의했다
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

Task ID / Plan / Wave / Threat Ref 는 2026-10-11 확정된 계획(`01-01-PLAN.md`, `01-02-PLAN.md`, `01-03-PLAN.md`, gap 수정 계획 `01-04-PLAN.md`)의 값이다. Task ID 는 `{plan}-T{n}` (plan 안의 n 번째 task). 명령은 각 plan 의 `<automated>` 와 같고, 긴 복합 명령은 plan 을 가리킨다.

커밋 계약 (2026-10-11 리비전): 실행자(gsd-executor)는 action → verify → 커밋 순서로 task 커밋을 만든다. 그래서 각 plan 의 `<automated>` 는 HEAD 를 읽지 않고 작업 트리를 `90a2736` 과 비교하거나 probe 전후의 상태를 비교한다 — 커밋 전(실행자 순서)과 커밋 뒤(아래 "After every task commit" 재실행) 판정이 같다. 커밋 범위·제목(`docs(01-02):`, `chore(01-03):`, `feat(01-03)!:`)은 각 task 의 acceptance_criteria "커밋 뒤" 항목이 SUMMARY 로 확인한다. 작업 트리 청결 검사는 `.planning/` 을 뺀 범위(`-- . ':(exclude).planning'`)로 본다 — 실행자 bookkeeping 이 거짓 실패를 내지 않게 한다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 01-01-T1 | 01-01 | 1 | REL-01 | T-01-01, T-01-03 | 로컬 tag 가 annotated 이고 `90a2736` = `origin/main` 을 가리킨다 (push 전 4중 점검) | smoke (shell, `git fetch` 읽기 전용) | `git fetch origin --quiet && test "$(git cat-file -t v1.3.0)" = tag && test "$(git rev-parse 'v1.3.0^{commit}')" = 90a2736b8d998c84467faf562a0fec720b797eaf && test "$(git rev-parse 'v1.3.0^{commit}')" = "$(git rev-parse origin/main)"` | ✅ | ✅ green |
| 01-01-T1 | 01-01 | 1 | REL-01 | — | N/A | smoke (shell) | `PS=$(git show v1.3.0:pubspec.yaml) && printf '%s\n' "$PS" \| grep -qx 'version: 1.3.0'` | ✅ | ✅ green |
| 01-01-T3 | 01-01 | 1 | REL-01 | T-01-01, T-01-02 | 원격 tag 가 `90a2736` 을 가리키고 push 한 것은 tag 하나뿐이다 (브랜치는 `main` 하나) | smoke (shell, 읽기 전용 네트워크) | `TAGS=$(git ls-remote --tags origin) && printf '%s\n' "$TAGS" \| grep -qF "$(printf '90a2736b8d998c84467faf562a0fec720b797eaf\trefs/tags/v1.3.0^{}')" && HEADS=$(git ls-remote --heads origin) && test "$(printf '%s\n' "$HEADS" \| wc -l \| tr -d ' ')" = 1` | ✅ | ✅ green |
| 01-03-T1 | 01-03 | 3 | BASE-01 | T-01-07 | `fvm use` 가 `.fvmrc` 와 `.vscode/settings.json` 두 파일만 바꾼다 (커밋 파일 목록이 정확히 둘) | smoke (shell) | `grep -q '"flutter": "3.47.5"' .fvmrc && grep -q '"dart.flutterSdkPath": ".fvm/versions/3.47.5"' .vscode/settings.json && fvm flutter --version 2>/dev/null \| grep -q '^Flutter 3.47.5 ' && fvm dart --version 2>&1 \| grep -q 'version: 3.13.4 '` (+ 작업 트리 `git diff --numstat 90a2736 -- .fvmrc .vscode/settings.json` 두 줄 `1 1`, `.gitignore` 등 다른 추적 파일 불변 — 01-03-PLAN.md Task 1; 커밋 파일 목록 2 는 acceptance "커밋 뒤") | ✅ | ✅ green |
| 01-03-T2 | 01-03 | 3 | BASE-02 | — | N/A | smoke (shell) | `grep -qxF '  sdk: ^3.13.0' pubspec.yaml && grep -qxF 'version: 2.0.0-dev' pubspec.yaml` (+ 작업 트리 `git diff --numstat 90a2736 -- pubspec.yaml` `2 2`, 루트 `fvm dart pub get` rc=0 — 01-03-PLAN.md Task 2 첫 automated; 커밋 파일 목록 2 는 acceptance "커밋 뒤") | ✅ | ✅ green |
| 01-03-T3 | 01-03 | 3 | BASE-02 | T-01-06 | `sdk` 하한 상향이 `main` 에 들어가지 않는다 | smoke (shell, 읽기 전용 네트워크) | `git fetch origin --quiet && test "$(git rev-parse origin/main)" = 90a2736b8d998c84467faf562a0fec720b797eaf && git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` | ✅ | ✅ green |
| 01-03-T2 | 01-03 | 3 | BASE-02 | T-01-08 | 임시 프로젝트는 저장소 밖(`mktemp -d`)에 두고, probe 전후의 `git status --short -- . ':(exclude).planning'` 이 같다 | integration (shell, 저장소 밖 임시 사용 프로젝트, `path:` 의존) | 임시 프로젝트에서 `/Users/woody/fvm/versions/3.41.9/bin/dart pub get` (없으면 3.41.4 → 3.41.2) 이 rc=1 이고 출력에 `requires SDK version ^3.13.0, version solving failed` 가 있다; `/Users/woody/fvm/versions/3.47.5/bin/dart pub get` 은 rc=0 이고 lock 에 `version: "2.0.0-dev"` — 01-03-PLAN.md Task 2 둘째 automated | ✅ (task 안에서 생성) | ✅ green |
| 01-03-T3 | 01-03 | 3 | BASE-02, REL-01 | T-01-09 | 옛 SDK 프로젝트가 GitHub 의 `ref: v1.3.0` 으로 1.3.0 을 받는다 — CHANGELOG "올리기 전에" 의 실증 | integration (shell, 저장소 밖 임시 사용 프로젝트, `git:` + `ref: v1.3.0`, 읽기 전용 네트워크) | 옛 SDK `dart pub get` rc=0, lock 에 `resolved-ref: "90a2736b8d998c84467faf562a0fec720b797eaf"` 와 `version: "1.3.0"` — 01-03-PLAN.md Task 3 automated | ✅ (task 안에서 생성) | ✅ green |
| 01-02-T1 | 01-02 | 2 | BASE-03 | T-01-04 | 기준표가 D-05 의 11행과 글자 단위로 같다 (행 누락·변형 없음) | 구조 검사 (shell) + manual (`<human-check>` → end-of-phase UAT) | `test -f VERSIONING.md && head -1 VERSIONING.md \| grep -qx '# 버전 정책 (Versioning)' && grep -qx '## 판정 순서' VERSIONING.md && grep -qx '## 기준표' VERSIONING.md && grep -qx '## 실제 사례' VERSIONING.md` + 기준표 절 등급 행 `wc -l` = 11 + 11행 `grep -F` 글자 대조 + D-10 풀이 셋 — 01-02-PLAN.md Task 1 | ✅ | ✅ green |
| 01-02-T2 | 01-02 | 2 | BASE-04 | — | N/A | 구조 검사 (shell) | `grep -qx '## CHANGELOG 항목 형식' VERSIONING.md && grep -qF '## X.Y.Z - YYYY-MM-DD' VERSIONING.md && grep -qF '### 새로 생기는 경고' VERSIONING.md && grep -qF '실측: flutter_starter_kit (Dart 파일 N개), Flutter X.Y.Z, YYYY-MM-DD' VERSIONING.md` (+ 4열 헤더, 2.1.0 예시 — 01-02-PLAN.md Task 2) | ✅ | ✅ green |
| 01-03-T2 | 01-03 | 3 | BASE-04 | — | N/A | smoke (shell) | `head -1 CHANGELOG.md \| grep -qxF '## 2.0.0 - 미출시' && grep -qxF '지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)' CHANGELOG.md && grep -qxF '### 새로 생기는 경고' CHANGELOG.md` (+ 마지막 11행 = `git show 90a2736:CHANGELOG.md` — 01-03-PLAN.md Task 2 첫 automated) | ✅ | ✅ green |
| 01-04-T1 | 01-04 | 4 | BASE-03 | T-01-11 | `01-CONTEXT.md` 의 D-02 · D-09 ① 원문이 지워지지 않는다 — 수정은 주석 줄 추가로만 (`23d2674` 대비 삭제 0 / 추가 2) | 구조 검사 (shell) | `01-04-PLAN.md` Task 1 `<automated>` 한 줄 전체 (검사 라벨 `T1-01` ~ `T1-21`) — `23d2674` 대비 `diff` 의 삭제 0 · 추가 2, 주석 줄 번호 38 · 70, D-04 줄 · D-09 3. 줄 · D-05 표 12줄 보존, D-09 ① 주석의 최종 문구 대조, 범위 밖 파일(`lib` `README.md` `analysis_options.yaml` `pubspec.yaml` `.fvmrc` `.vscode` `CHANGELOG.md` `.gitignore`) 불변. 통과하면 출력 없이 rc=0, 실패하면 `FAIL: <라벨> …` 한 줄 | ✅ | ✅ green |
| 01-04-T2 | 01-04 | 4 | BASE-03 | T-01-10, T-01-12 | 문구 수정 중 기준표 11행(D-05)과 `## CHANGELOG 항목 형식` 절이 바뀌지 않는다 (`23d2674` 와 바이트 대조); `01-REVIEW-DISPOSITION.md` frontmatter 가 깨지지 않고 WR-03 이 잘못 닫히지 않는다 | 대입 계산 (shell) + manual (`<human-check>` → end-of-phase UAT) | `01-04-PLAN.md` Task 2 `<automated>` 한 줄 전체 (검사 라벨 `T2-01` ~ `T2-37`) — 문서에서 판정 순서 1 · 2번을 읽어 두 사례와 기준표 여덟 행을 대입해 등급을 계산하고 문서에 적힌 등급과 비교한다. 통과 출력: `substitution: 1.3.0 computed=minor documented=minor / 2.0.0 computed=major documented=major` 와 `table: 38=major/major 39=major/major 40=major/major 41=major/major 42=major/major 43=minor/minor 44=minor/minor 46=minor/minor`. 45 · 47 · 48행은 단정하지 않는다 (WR-03 의 남은 범위). **처리 기록 검사(`T2-28` ~ `T2-36`)는 task 커밋 `6b9eec8` 시점의 `01-REVIEW-DISPOSITION.md` 를 본다** — 그 뒤 코드 리뷰 게이트가 이 파일을 다시 만들기 때문에(2026-10-11 재리뷰 뒤 열림 13 / 합계 16) 지금 파일로 돌리면 위 두 줄을 찍은 뒤 `FAIL: T2-32 DISPOSITION frontmatter open: 7 없음` 에서 멈춘다 (rc=1). 다시 돌릴 때는 명령 맨 앞의 `D=` 를 `git show 6b9eec8:.planning/phases/01-baseline-and-toolchain/01-REVIEW-DISPOSITION.md` 를 받아 둔 사본 경로로 바꾼다 (2026-10-11 재리뷰 뒤 확인: rc=0, 출력 두 줄 같음) | ✅ | ✅ green (처리 기록 검사는 `6b9eec8` 시점 기준) |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

모든 검사가 이미 설치된 git 2.56.0 / FVM 4.3.1 / FVM 캐시의 Dart SDK 로 돈다. 설치하거나 새로 만들 테스트 파일이 없다. BASE-02 의 임시 사용 프로젝트는 그 task 안에서 저장소 밖에 만들고, 출력 원문을 실행 요약에 붙인다.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 소유자가 `VERSIONING.md` 를 읽고 어떤 변경이 major / minor / patch 인지 판정할 수 있다 | BASE-03 | "읽고 판정할 수 있다"는 사람의 이해 여부다. 명령으로는 문서의 존재와 구조까지만 확인된다 | `VERSIONING.md` 의 판정 순서를 1.3.0 사례와 2.0.0 사례에 대입해 본다. 결과가 minor / major 로 나오고 그 이유가 납득되면 통과다. 01-04 (UAT G-01-1 수정) 뒤에는 `/gsd-verify-work 1` 로 UAT 1번을 다시 하며 세 가지를 더 대입한다 — 맨 앞자리가 바뀌는 큰 업그레이드 둘(`flutter_lints` 6 → 7, `riverpod_lint` 3 → 4)은 1번에서 major, 맨 앞자리가 같은 작은 업그레이드(`riverpod_lint` `^3.1.3` → `^3.1.9`)는 2번에서 minor 가 나오고 설명이 납득되면 통과다 (`01-04-PLAN.md` Task 2 `<human-check>`) |
| `v1.3.0` tag 를 GitHub 에 올리기 전 소유자 확인 | REL-01 | 되돌릴 수 없는 작업이다 (D-18 의 one-way). 올린 tag 는 옮기지 않기로 했다 | 실행 에이전트가 올릴 것의 목록, 실행할 명령, 되돌릴 수 없다는 점을 쉬운 말로 보인다. 소유자가 명시적으로 승인한 뒤에만 `git push origin v1.3.0` 을 실행한다 |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 30s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** validated 2026-10-11 — 자동 명령 10개를 phase 실행 뒤 다시 돌려 모두 통과했고, 임시 프로젝트 실측 2건은 `01-03-SUMMARY.md` 의 출력 원문으로 확인했다. 사람 확인 2건 중 REL-01 (push 전 소유자 확인)은 2026-10-11 에 수행되었고, BASE-03 (소유자의 `VERSIONING.md` 읽기 판정)은 phase 끝 UAT 에 남아 있다. 재감사 2026-10-11 (01-04 실행 뒤) — `01-04-T1` / `01-04-T2` 두 행을 더했고, 두 `<automated>` 를 bash · zsh 에서 다시 돌려 모두 rc=0 이었다 (Task 2 출력은 위 표의 두 줄과 같다). `VERSIONING.md` 를 읽는 기존 행 `01-02-T1` · `01-02-T2` 도 다시 돌려 통과했다. BASE-03 의 사람 확인은 UAT 1번 재실행으로 남아 있다. 같은 날 코드 리뷰 게이트가 `01-REVIEW-DISPOSITION.md` 를 다시 만든 뒤에는 `01-04-T2` 를 지금 파일로 돌리면 `T2-32` 에서 멈춘다 — 판정 순서 대입 계산(출력 두 줄)은 그대로 통과하고, 멈추는 곳은 task 커밋 시점의 처리 기록 상태를 고정해 보는 검사다. 위 표의 `01-04-T2` 행에 다시 돌리는 방법을 적었다

## Validation Audit 2026-10-11

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
