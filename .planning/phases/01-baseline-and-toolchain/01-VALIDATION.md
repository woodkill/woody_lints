---
phase: "1"
slug: "baseline-and-toolchain"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
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

Task ID / Plan / Wave / Threat Ref 는 계획(PLAN.md)이 확정되면 그 값으로 채운다. 아래 행은 요구사항 단위의 검증 계약이다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 계획 확정 후 | — | — | REL-01 | 계획 확정 후 | tag 가 `90a2736` 을 가리키고 push 한 것은 tag 하나뿐이다 | smoke (shell, 읽기 전용 네트워크) | `git ls-remote --tags origin 'v1.3.0^{}' \| grep -q '^90a2736b8d998c84467faf562a0fec720b797eaf'` | ✅ | ⬜ pending |
| 계획 확정 후 | — | — | REL-01 | — | N/A | smoke (shell) | `git show v1.3.0:pubspec.yaml \| grep -qx 'version: 1.3.0'` | ✅ | ⬜ pending |
| 계획 확정 후 | — | — | BASE-01 | 계획 확정 후 | `fvm use` 가 `.fvmrc` 와 `.vscode/settings.json` 두 파일만 바꾼다 | smoke (shell) | `grep -q '"flutter": "3.47.5"' .fvmrc && grep -q '".fvm/versions/3.47.5"' .vscode/settings.json && fvm dart --version 2>&1 \| grep -q '3.13.4'` | ✅ | ⬜ pending |
| 계획 확정 후 | — | — | BASE-02 | — | N/A | smoke (shell) | `grep -qx '  sdk: \^3.13.0' pubspec.yaml && grep -qx 'version: 2.0.0-dev' pubspec.yaml` | ✅ | ⬜ pending |
| 계획 확정 후 | — | — | BASE-02 | 계획 확정 후 | `sdk` 하한 상향이 `main` 에 들어가지 않는다 | smoke (shell, 읽기 전용 네트워크) | `git fetch origin --quiet && git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` | ✅ | ⬜ pending |
| 계획 확정 후 | — | — | BASE-02 | — | N/A | integration (shell, 저장소 밖 임시 사용 프로젝트) | 임시 프로젝트에서 `/Users/woody/fvm/versions/3.41.9/bin/dart pub get` 이 rc≠0 이고 출력에 `requires SDK version ^3.13.0, version solving failed` 가 있다 | ✅ (task 안에서 생성) | ⬜ pending |
| 계획 확정 후 | — | — | BASE-03 | — | N/A | 구조 검사 (shell) + manual | `test -f VERSIONING.md && grep -q '판정 순서' VERSIONING.md && grep -q '기준표' VERSIONING.md` (문구는 실제 절 제목에 맞춘다) | ✅ | ⬜ pending |
| 계획 확정 후 | — | — | BASE-04 | — | N/A | smoke (shell) | `head -1 CHANGELOG.md \| grep -qx '## 2.0.0 - 미출시' && grep -q '^지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)$' CHANGELOG.md && grep -q '^### 새로 생기는 경고$' CHANGELOG.md` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

모든 검사가 이미 설치된 git 2.56.0 / FVM 4.3.1 / FVM 캐시의 Dart SDK 로 돈다. 설치하거나 새로 만들 테스트 파일이 없다. BASE-02 의 임시 사용 프로젝트는 그 task 안에서 저장소 밖에 만들고, 출력 원문을 실행 요약에 붙인다.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 소유자가 `VERSIONING.md` 를 읽고 어떤 변경이 major / minor / patch 인지 판정할 수 있다 | BASE-03 | "읽고 판정할 수 있다"는 사람의 이해 여부다. 명령으로는 문서의 존재와 구조까지만 확인된다 | `VERSIONING.md` 의 판정 순서를 1.3.0 사례와 2.0.0 사례에 대입해 본다. 결과가 minor / major 로 나오고 그 이유가 납득되면 통과다 |
| `v1.3.0` tag 를 GitHub 에 올리기 전 소유자 확인 | REL-01 | 되돌릴 수 없는 작업이다 (D-18 의 one-way). 올린 tag 는 옮기지 않기로 했다 | 실행 에이전트가 올릴 것의 목록, 실행할 명령, 되돌릴 수 없다는 점을 쉬운 말로 보인다. 소유자가 명시적으로 승인한 뒤에만 `git push origin v1.3.0` 을 실행한다 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
