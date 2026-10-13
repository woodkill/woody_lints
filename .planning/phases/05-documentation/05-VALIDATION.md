---
phase: "5"
slug: "documentation"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-13"
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> 출처: `05-RESEARCH.md` § "Validation Architecture", § 1 (WR-02), § 2 (WR-11 · IN-14 · VERIFY-06 의 `[3/10]` 설계), § 6 (비공개 점검 · 종료 코드 관례), § "Common Pitfalls". 시간 값은 조사 단계의 값이다 (`verify.dart` 는 plugin 준비된 상태 약 20 ~ 23초). `[3/10]` 의 (b′) · (d) ~ (g), README 의 표시 구역 `woody:readme-rules` 는 아직 없으므로 아래 명령 가운데 그것들을 가리키는 것은 이 phase 가 만든 뒤에야 돈다. 아래 grep 은 조사 문서의 초안이며, 정확한 명령은 계획(`05-NN-PLAN.md`)의 `<automated>` 가 정한다.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 없음 — Dart 테스트 패키지를 두지 않는다 (02-CONTEXT.md D-11). 검증 명령 `tool/verify.dart` (단계 10개 — `[3/10]` 에 (b′) · (d) ~ (g) 가 더해진다), 루트 `fvm dart analyze`, `fvm dart format --output=none --set-exit-if-changed tool`, `05-RESEARCH.md` § 6 의 grep 점검, `example/README.md` 의 지워 보기 기록(M32 ~)이 하네스다 |
| **Config file** | `tool/verify.dart` 의 상수 (`rulesFile` · `expectedLibYamls` · `includeOnlyFiles` · 새 README 표시 구역 이름), `README.md` 의 표시 구역 (이 phase 가 만든다), `RULES.md` 의 표시 구역 넷, 정답지 다섯 |
| **Quick run command** | `fvm dart analyze && fvm dart run tool/verify.dart` |
| **Full suite command** | 위 둘 + `fvm dart format --output=none --set-exit-if-changed tool` + `05-RESEARCH.md` § 6 (1) · (2) 의 grep + (YAML 주석 커밋 뒤) `fvm dart run tool/verify.dart --update` 가 `바뀐 정답지가 없다` |
| **Estimated runtime** | ~25 seconds (루트 분석 약 1초 + `verify.dart` plugin 준비된 상태 약 20 ~ 23초. 처음 실행은 약 69초). GitHub runner 의 job 은 약 3분 30초 ~ 4분 (Phase 03 · 04 기록) |

---

## Sampling Rate

- **After every task commit:** `fvm dart analyze` + `fvm dart format --output=none --set-exit-if-changed tool` + `fvm dart run tool/verify.dart` (종료 코드 0, `점검 통과 (10개 중 10개)`) + § 6 (1) · (2)
- **After every plan wave:** 위 + 그 wave 의 지워 보기(M 번호)를 실제로 만들어 돌리고 되돌림 (`git status` · `git diff` 비어 있음). YAML 주석 wave 는 `--update` 가 `바뀐 정답지가 없다`
- **Before `/gsd-verify-work`:** 로컬 `verify` 종료 코드 0 · 모든 단계 통과, 첫 push 뒤 GitHub `verify` 성공 1회 이상, M32 ~ 의 새 지워 보기 기록, § 6 범위 전체 0줄
- **Max feedback latency:** 30 seconds (로컬 `verify` 재실행)

---

## Per-Task Verification Map

Task ID / Plan / Wave / Threat Ref 는 계획(`05-NN-PLAN.md`)이 확정된 뒤 채운다. 아래는 요구사항별 확인 방법이며 조사 문서에서 옮긴 것이다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 05-01 Task 1 | 05-01 | 1 | (WR-02) | T-05-01 · T-05-02 | N/A | 지워 보기 | `lib/riverpod.yaml` 의 plugin 줄 끝 주석 (M32) · 마지막 줄바꿈 삭제 (M33) → `verify` 종료 코드 0, 선언 삭제 (M34) → 여전히 70 (reader 가 no-op 아님) | ❌ W0 (`stripPlugins` · `readShippedPluginConstraint` · `fragmentLineHint`) | ⬜ pending |
| 05-01 Task 2 | 05-01 | 1 | (WR-11 · IN-14 · WR-02 줄 번호 보존) | T-05-01 · T-05-03 | N/A | 지워 보기 | `lib/codegen.yaml` 에 규칙 한 줄 (M35) → 종료 코드 1, `[3/10]` 실패. 읽지 못하는 줄 (M36) → 70, stderr 에 `lib/codegen.yaml`. `lib/riverpod.yaml` 끝에 deprecated 규칙 (M37) → `[2/10]` 실패의 진단 줄 번호 == 원본 줄 번호(빈 줄 치환) · `[3/10]` 실패 `lib/riverpod.yaml 에 규칙이 있다 (1)` ((b′) 의 대상 범위) | ❌ W0 (`[3/10]` (b′), `declaredRuleNames(shownAs)`) | ⬜ pending |
| 05-03 Task 1 | 05-03 | 3 | DOCS-01 | T-05-09 | N/A | grep + 검사 (g) | 설치 블록에 `dev_dependencies` · `git:` · `ref: v2.0.0` · `flutter pub get`, 설치 절에 `ref: main` 없음. `[3/10]` 통과 | ❌ (README 재작성) | ⬜ pending |
| 05-03 Task 1 | 05-03 | 3 | DOCS-02 | T-05-11 | N/A | grep + 검사 (e) | include 블록 넷(묶음 · 기본만 · 기본 + Riverpod · 기본 + codegen)이 `fixtures/{recommended,base_only,base_riverpod,base_codegen}/analysis_options.yaml` 의 include 줄을 담는다. README 의 모든 `package:woody_lints/<이름>.yaml` 이 `lib/` 에 있다 | ❌ | ⬜ pending |
| 05-03 Task 1 | 05-03 | 3 | DOCS-03 | T-05-11 | N/A | grep + 검사 (f) | 세 층 × 규칙 / plugin 진단의 예시 (`: false`, `diagnostics:`, `ignore_for_file: riverpod_lint/`, `ignore: riverpod_lint/`), 끄기 블록의 `version:` 이 `lib/riverpod.yaml` 과 같다 | ❌ | ⬜ pending |
| 05-03 Task 1 | 05-03 | 3 | DOCS-04 | T-05-12 | N/A | grep | tag 쪽 `ref:` 수정 + `flutter pub get`, `ref: main` 쪽 `flutter pub upgrade woody_lints`, main → tag 전환, `--enforce-lockfile` 과 종료 코드 65 | ❌ | ⬜ pending |
| 05-03 Task 1 | 05-03 | 3 | DOCS-05 | T-05-10 · T-05-12 | 복구 안내가 사용자의 다른 상태를 지우라고 하지 않는다 | grep + 사람 확인 | 문제 해결 넷 — plugin 경고가 안 보일 때, Analysis Server 재시작, `dart analyze` ↔ `flutter analyze` (3.47.5 · 2026-09-20), tag 를 고정해도 바뀌는 것 (plugin 버전 · 기반 세트 caret) | ❌ | ⬜ pending |
| 05-03 Task 1 | 05-03 | 3 | DOCS-06 | T-05-11 | N/A | grep + 검사 (d) | `require_trailing_commas` · `trailing_commas` 가 README 에 0줄, `invalid_annotation_target` 설명 있음. `[3/10]` 통과 | ❌ | ⬜ pending |
| 05-04 Task 2 | 05-04 | 3 | DOCS-07 | T-05-15 | N/A | grep (확인만) | `head -1 CHANGELOG.md` = `## 2.0.0 - 미출시`, 칸 제목 순서가 `VERSIONING.md` § "CHANGELOG 항목 형식" 과 같다 | ✅ | ⬜ pending |
| 05-04 Task 1 | 05-04 | 3 | DOCS-08 | T-05-14 | N/A | grep + 사람 확인 (diff 대조) | `## 1.1.0` · `## 1.2.0` · `## 1.2.1` · `## 1.2.2` · `## 1.2.3` · `## 1.2.4` · `## 1.2.5` 제목 7개, 커밋 번호 `2249a0b` · `ec66e3f` · `21c5689` · `31c8cb1` · `9451f6b` · `212365d` · `dbcd20b`, `^## ` 제목이 내림차순 | ❌ | ⬜ pending |
| 05-04 Task 2 | 05-04 | 3 | DOCS-09 | T-05-15 | N/A | grep (확인만) | `### 새로 생기는 경고` 표의 규칙 행 수 == `### 추가한 규칙` 불릿 수 (2026-10-14 셈 75 · 75 — `fb6386a` 가 `sort_pub_dependencies` 행을 더한 뒤의 값; 조사 문서의 74 는 그 전), `실측: flutter_starter_kit` 한 줄 | ✅ | ⬜ pending |
| 05-02 Task 1 | 05-02 | 2 | DOCS-10 (YAML 쪽) | T-05-05 · T-05-06 | N/A | grep + 실행 | `lib/base.yaml` 의 영어 템플릿 주석(옛 1 ~ 12 · 15 · 108 ~ 112행) 없음, 배포 YAML 다섯의 첫 줄이 `#`, `lib/codegen.yaml` 머리 주석 신설, `--update` → `바뀐 정답지가 없다` | ❌ | ⬜ pending |
| 05-03 Task 1 | 05-03 | 3 | DOCS-10 (README 쪽) | T-05-13 | N/A | grep | README 에 템플릿 HTML 주석 · 옛 "핵심가치" 절 없음 | ❌ | ⬜ pending |
| 05-03 Task 2 | 05-03 | 3 | VERIFY-06 (검사) | T-05-11 | N/A | 실행 + 마커 삭제 확인 | `[3/10]` (d) ~ (g) 가 Task 1 의 README 와 일치해 `점검 통과 (10개 중 10개)`; start 마커를 지운 README 에서 `[3/10]` 실패 · `구역이 없다` (README 먼저, 검사 다음 — 다른 커밋) | ❌ W0 (`[3/10]` (d) ~ (g), 표시 구역) | ⬜ pending |
| 05-06 Task 1 | 05-06 | 4 | VERIFY-06 (헛통과 아님) | T-05-21 · T-05-22 | N/A | 지워 보기 | README 표시 구역에서 규칙 이름 삭제 (M38) → 종료 코드 1 · `[3/10]` 실패. 뒤쪽 블록의 프리셋 주소 오타 · plugin 버전 어긋남 · `ref:` 어긋남 · start 마커 삭제 (M39 ~ M42) 각각 실패 | ❌ W0 (`[3/10]` (d) ~ (g), 표시 구역) | ⬜ pending |
| 05-02 Task 2 | 05-02 | 2 | (D-09) | T-05-08 | N/A | grep | `.claude/CLAUDE.md` 에 `포함된 규칙 목록` · `템플릿에서 온 영어 주석 … 그대로 둔다` 가 0줄 | ❌ | ⬜ pending |
| 05-01 Task 3 | 05-01 | 1 | (D-19 — 03 WR-02 · 04 WR-11 · IN-14) | T-05-04 | N/A | grep | `03-REVIEW-DISPOSITION.md` WR-02 · `04-REVIEW-DISPOSITION.md` WR-11 · IN-14 행이 `fixed` 와 05-01 의 커밋 해시로 바뀜, `open:` 수 (03 그대로 12, 04 18 → 17) | ❌ | ⬜ pending |
| 05-04 Task 2 | 05-04 | 3 | (D-19 — 01 WR-05) | T-05-15 | N/A | grep | `01-REVIEW-DISPOSITION.md` WR-05 행이 `fixed` 와 05-04 의 CHANGELOG 커밋 해시로 바뀜, `open: 13` → `12` | ❌ | ⬜ pending |
| 05-01 ~ 05-04 · 05-06 각 task · 05-05 Task 1 | 05-05 | 5 | (D-20) | T-05-04 · T-05-07 · T-05-13 · T-05-16 · T-05-17 | 비공개 사용 프로젝트의 경로 · 메시지 · 코드가 저장소와 `.planning/` 에 없다 | grep (커밋 전 · push 전 범위 전체) | 각 task 의 `<automated>` 에 절대 경로 grep; 05-05 Task 1 이 올릴 범위 전체에 `05-RESEARCH.md` § 6 의 (1) · (2) · (3) 을 돌려 모두 0줄 | ✅ (명령만) | ⬜ pending |
| 05-05 Task 2 · 3 | 05-05 | 5 | (D-21) | T-05-18 · T-05-20 | workflow 가 읽기 권한만 가진다 | e2e (GitHub, 읽기 전용 조회) | 소유자 확인 뒤 첫 push → `gh run list --workflow verify.yml --limit 1` → `completed success` | ✅ (`.github/workflows/verify.yml`) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tool/verify.dart` — `stripPlugins` · `readShippedPluginConstraint` · `fragmentLineHint` 고침 (WR-02), `declaredRuleNames` 의 파일 이름 인자 (IN-14), `[3/10]` (b′) (WR-11), `[3/10]` (d) ~ (g) (VERIFY-06 — README 재작성 커밋 뒤의 다른 커밋, 05-03 Task 2)
- [ ] `README.md` 의 표시 구역 — VERIFY-06 확인의 대상
- [ ] `example/README.md` 의 새 소절 — M32 ~ 의 지워 보기 기록
- 프레임워크 설치: 없음

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| README 의 include · 끄기 예시가 연습용 프로젝트와 같은 모양이다 | DOCS-02 · DOCS-03 | 예시 블록 통째 비교는 D-02 에서 고르지 않았다 (설명 주석까지 묶인다) | 실행자가 README 에 옮길 때 `fixtures/*/analysis_options.yaml` · `fixtures/overrides/lib/suppress/*.dart` 와 한 번 대조하고 SUMMARY 에 적는다 |
| README 만 보고 따라 할 수 있다 | 성공 기준 1 · 2 | "따라 할 수 있다" 는 grep 으로 가를 수 없다 | `/gsd-verify-work` 에서 소유자가 README 를 읽고 설치 · 프리셋 고르기 · 끄기 · 버전 올리기 순서를 확인한다 |
| CHANGELOG 복원 항목이 diff 와 맞다 | DOCS-08 | 문장의 사실 여부는 grep 으로 가를 수 없다 | 항목마다 적힌 커밋을 `git show` 로 열어 적힌 변경과 대조한다 (커밋 메시지를 옮기지 않았는지 포함) |
| 단정 / 출처 구분 | DOCS-03 ~ DOCS-05 | 실측으로 확인한 것만 단정형인지는 사람이 본다 | SDK 에 따라 다른 동작에 SDK 버전과 날짜가 붙었는지, 읽은 것 · 추론이 그렇다고 적혔는지 확인한다 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
