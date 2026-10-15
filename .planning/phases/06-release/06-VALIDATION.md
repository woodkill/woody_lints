---
phase: "6"
slug: "release"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-15"
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> 출처: `06-RESEARCH.md` § "Validation Architecture", § 1 (REL-03 검사 (i) 의 자리 · tag 이름의 출처), § 2 (D-06 다섯 입력), § 3 (smoke 스크립트), § 5 (lock 여섯), § 6 (손질 다섯 · IN-12 · IN-14), § 8 (릴리스 명령 · 비공개 점검). 시간 값은 조사 단계의 값이다 (`verify.dart` 는 plugin 준비된 상태 약 22초, smoke 는 약 45초 · 네트워크). `[3/10]` 의 (i), `--tag` 인자, `tool/smoke.dart` 는 아직 없으므로 아래 명령 가운데 그것들을 가리키는 것은 이 phase 가 만든 뒤에야 돈다. 아래 명령은 조사 문서의 초안이며, 정확한 명령은 계획(`06-NN-PLAN.md`)의 `<automated>` 가 정한다.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 없음 — Dart 테스트 패키지를 두지 않는다 (02-CONTEXT.md D-11). 검증 명령 `tool/verify.dart` (단계 10개 — `[3/10]` 에 (i) 버전 일치 검사가 더해진다), 새 `tool/smoke.dart`, 루트 `fvm dart analyze`, `fvm dart format --output=none --set-exit-if-changed tool`, 비공개 점검 (1) ~ (3), `example/README.md` 의 지워 보기 기록(M92 ~), git · gh 의 읽기 명령이 하네스다 |
| **Config file** | `tool/verify.dart` 의 상수, `.fvmrc`, 정답지 다섯 (`example/expected_diagnostics.txt` 등) |
| **Quick run command** | `fvm dart analyze && fvm dart run tool/verify.dart` |
| **Full suite command** | 위 둘 + `fvm dart format --output=none --set-exit-if-changed tool` + (릴리스 커밋 뒤) `fvm dart run tool/verify.dart --tag v2.0.0` + 비공개 점검 (1) ~ (3) + `fvm dart run tool/smoke.dart <ref>` (네트워크) |
| **Estimated runtime** | ~25 seconds (루트 분석 약 1초 + `verify.dart` plugin 준비된 상태 약 22초). smoke 는 약 45초 (GitHub 에서 받기 · `flutter create` · 두 주소 분석) |

---

## Sampling Rate

- **After every task commit:** `fvm dart analyze` + `fvm dart format --output=none --set-exit-if-changed tool` + `fvm dart run tool/verify.dart` (종료 코드 0, `점검 통과 (10개 중 10개)`) + 비공개 점검 (1) · (2)
- **After every plan wave:** 위 + 그 wave 의 지워 보기(M 번호)를 복제본에서 실제로 만들어 돌리고 되돌림 (`git status --porcelain` 빈 출력). 릴리스 커밋 wave 는 `--tag v2.0.0` 10/10 과 lock 여섯 · `pubspec.yaml` 의 `git diff --stat`
- **Before `/gsd-verify-work`:** 브랜치 push 뒤 GitHub `verify` 성공, 예행 smoke 통과, tag push 뒤 tag 실행 성공 (로그의 tag 모드 줄), `smoke.dart v2.0.0` 통과, `ls-remote` 증거, PR 실행 · 병합 · `workflow_dispatch` 실행 성공, push 범위 전체 비공개 점검 0줄
- **Max feedback latency:** 30 seconds (로컬 `verify` 재실행). smoke 는 네트워크라 wave 단위로만 돌린다

---

## Per-Task Verification Map

Task ID / Plan / Wave / Threat Ref 는 계획(`06-NN-PLAN.md`)이 확정된 뒤 채운다. 아래는 요구사항별 확인 방법이며 조사 문서에서 옮긴 것이다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 계획 뒤 채움 | — | — | REL-03 | — | N/A | 실행 | 평소 모드: `fvm dart run tool/verify.dart` 종료 코드 0, `점검 통과 (10개 중 10개)`, stderr 에 평소 모드 줄 (지금 상태 `2.0.0-dev` · `## 2.0.0 - 미출시` 가 통과) | ❌ W0 (`[3/10]` (i)) | ⬜ pending |
| 계획 뒤 채움 | — | — | REL-03 | — | N/A | 실행 | tag 모드: 릴리스 커밋에서 `fvm dart run tool/verify.dart --tag v2.0.0` 종료 코드 0 | ❌ W0 (`--tag`) | ⬜ pending |
| 계획 뒤 채움 | — | — | REL-03 | — | N/A | 지워 보기 (복제본) | D-06 다섯 입력 (tag 이름만 다름 · `-dev` 남음 · CHANGELOG 버전만 다름 · 날짜 자리 `미출시` · tag 가 `v` + 버전 꼴 아님) 각각 실패 — M92 ~ M96. 적어도 하나는 전체 실행으로 종료 코드 1 · `[3/10]` 실패 · `점검 실패 (10개 중 1개)` | ❌ W0 | ⬜ pending |
| 계획 뒤 채움 | — | — | REL-03 | — | N/A | 실행 | 사용법: `--tag` 값 없음 · 모르는 인자 → 종료 코드 64 | ❌ W0 | ⬜ pending |
| 계획 뒤 채움 | — | — | REL-03 | — | N/A | 원격 (gh 읽기) | CI 의 tag 트리거가 검사를 부른다: tag 실행 로그에 tag 모드 줄 (`버전 일치 검사: tag v2.0.0` 꼴) 과 `점검 통과` | 원격 — tag push 뒤 | ⬜ pending |
| 계획 뒤 채움 | — | — | (IN-12) | — | N/A | 지워 보기 (복제본) | `lib/base.yaml` 의 `include:` 값을 다음 줄에 → 고친 뒤 통과 (M97). M78 회귀 블록은 그대로 실패 | ❌ W0 (`keysSeenByLineReader`) | ⬜ pending |
| 계획 뒤 채움 | — | — | (IN-14 · 05-UAT 5) | — | N/A | grep | `tool/verify.dart` 머리 주석의 종료 코드 목록과 `compareLineReadersWithYaml` 문서 주석이 255 경우를 적는다. `example/README.md` 에 `판이 같은지는 재지 않았다` 1회, "블록 하나로 실패한다" 문장이 실제 범위로 좁혀짐 | ❌ | ⬜ pending |
| 계획 뒤 채움 | — | — | (IN-13 · 05-UAT 2 · 4 · D-14) | — | N/A | grep + `[3/10]` | `pubspec.yaml` 주석이 `lib/base.yaml` 을 가리킴, README 에 `병합 여부는 확인하지 않았다` 0줄 · `3.47.2` 언급, 355행 근처 재시작 문장에 출처 표시, 「설치」 · 「생성 파일 제외」 · 「프로젝트 전체」 에 기존 include 를 바꾸고 같은 키는 합친다는 문장. `fvm dart run tool/verify.dart` 10/10 | ❌ | ⬜ pending |
| 계획 뒤 채움 | — | — | (D-11 · D-12) | — | N/A | grep | `VERSIONING.md` 에 `## 릴리스 절차` 절, 절 안에 `fvm dart pub get` (lock 여섯) · `pub upgrade` 를 하지 않는다 · 정답지가 plugin 새 버전에 깨졌을 때 단락 · `--tag` · `smoke.dart` · `ls-remote` · merge commit. README 381행 근처 `VERSIONING.md` 안내 줄에 `릴리스 절차` | ❌ | ⬜ pending |
| 계획 뒤 채움 | — | — | REL-02 | — | N/A | 실행 + diff | 릴리스 커밋: `pubspec.yaml` `version: 2.0.0`, CHANGELOG 1행 `## 2.0.0 - YYYY-MM-DD`, lock 여섯이 각각 woody_lints 의 `version:` 한 줄만 바뀜, 검증 10/10 · `--tag v2.0.0` 10/10 | ❌ (릴리스 커밋) | ⬜ pending |
| 계획 뒤 채움 | — | — | REL-02 | — | 올린 tag 를 옮기거나 지우지 않는다 | git (원격 읽기) | `git cat-file -t v2.0.0` = `tag`; `git ls-remote --tags origin` 에 `refs/tags/v2.0.0` 과 `refs/tags/v2.0.0^{}` (= `git rev-parse 'v2.0.0^{commit}'`); `git show v2.0.0:pubspec.yaml` 의 version 과 `git show v2.0.0:CHANGELOG.md` 1행의 버전이 `2.0.0` | 원격 — tag push 뒤 | ⬜ pending |
| 계획 뒤 채움 | — | — | REL-02 (D-02) | — | `main` 을 강제로 되감지 않는다 | git · gh (읽기) | `git merge-base --is-ancestor v2.0.0 origin/main`; `origin/main` 의 머리 커밋 부모가 둘 (merge commit); `gh pr view` 의 병합 정보 | 원격 — 병합 뒤 | ⬜ pending |
| 계획 뒤 채움 | — | — | REL-04 | — | 새 `PUB_CACHE` · 새 analyzer 상태 폴더 · 저장소 밖 임시 폴더만 쓴다 | 실행 (네트워크) | 예행: `fvm dart run tool/smoke.dart <릴리스 커밋 sha>` 종료 코드 0 — 두 주소 각각 기본 규칙 위반 · `riverpod_lint` 위반 둘 다 보고, lock 의 `resolved-ref` = sha | ❌ W0 (`tool/smoke.dart`) | ⬜ pending |
| 계획 뒤 채움 | — | — | REL-04 | — | 같음 | 실행 (네트워크) | tag: `fvm dart run tool/smoke.dart v2.0.0` 종료 코드 0, `resolved-ref` = `git rev-parse 'v2.0.0^{commit}'` | 원격 — tag 뒤 | ⬜ pending |
| 계획 뒤 채움 | — | — | (02-UAT 4 · 6, D-03) | — | workflow 가 읽기 권한만 가진다 | 원격 (gh 읽기 + 화면) | PR 을 연 직후 `pull_request` event 의 `verify` 실행 성공; 병합 뒤 `workflow_dispatch` event 의 실행 성공 | 원격 | ⬜ pending |
| 계획 뒤 채움 | — | — | (04 D-07 · 05 D-21) | — | 비공개 사용 프로젝트의 경로 · 기능 이름이 공개 저장소에 없다 | grep (push 전) | 05-05 Task 1 의 비공개 점검 (1) ~ (3) — phase 폴더와 제외 목록만 바꿈 (smoke 의 위반 파일 경로 제외 포함) — 모두 0줄 | ✅ (명령만) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tool/verify.dart` — `[3/10]` (i) 버전 일치 검사, `main` 의 `--tag` 인자와 CI 환경변수 읽기, stderr 모드 줄, IN-12 고친 판, IN-14 주석
- [ ] `tool/smoke.dart` — 예행(D-07) 전에 있어야 한다
- [ ] `example/README.md` 의 새 소절 — M92 ~ 의 지워 보기 기록
- 프레임워크 설치: 없음

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| README 를 사람이 그대로 따라 한다 (`flutter create` 빈 프로젝트) | REL-04 (D-09 (1), D-10, 05-UAT 1번) | "따라 할 수 있다" 는 스크립트로 가를 수 없다. 스크립트는 README 단계를 옮겨 적은 것이라 README 가 바뀌어도 스스로 알아채지 못한다 | 예행 때 한 번 손으로 따라 하고, 막힌 자리와 결과를 SUMMARY 에 적는다. 막히면 README 를 고친 커밋으로 예행을 다시 한다 |
| `base.yaml` 만 받는 프로젝트에 「프로젝트 전체」 의 `plugins:` 블록을 붙이면 plugin 이 켜지는가 | (D-14) | 예행 때 한 번 재는 항목 | 결과대로 README 「프로젝트 전체」 에 한 문장을 단다 |
| tag push 직전 확인 | REL-02 (D-01 5번) | 되돌릴 수 없는 원격 작업 (one-way) | 로컬 `--tag v2.0.0` 10/10 · 예행 통과 · 비공개 점검 0줄을 보인 뒤 소유자의 승인을 받는다 |
| `main` 병합 직전 확인 | REL-02 (D-02) | `ref: main` 프로젝트 5개에 닿는 원격 작업 (one-way) | tag smoke · `ls-remote` · PR 실행 성공을 보인 뒤 소유자의 승인을 받는다 |
| Actions → verify 화면의 `Run workflow` 버튼 | (02-UAT 6번, D-03) | GitHub 웹 화면의 버튼은 gh 로 볼 수 없다 | 병합 뒤 소유자가 화면에서 버튼을 확인한다 (실행 자체는 `gh workflow run` 으로도 만든다) |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
