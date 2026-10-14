---
phase: "5"
slug: "documentation"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
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

Task ID / Plan / Wave / Threat Ref 는 계획(`05-NN-PLAN.md`)이 확정된 뒤 채웠다. Automated Command 칸은 조사 문서에서 옮긴 요구사항별 확인 방법이고, 실제로 돈 명령은 각 task 의 `<automated>` 다. Status 의 근거는 아래 「감사 결과 (2026-10-14)」 표다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 05-01 Task 1 | 05-01 | 1 | (WR-02) | T-05-01 · T-05-02 | N/A | 지워 보기 | `lib/riverpod.yaml` 의 plugin 줄 끝 주석 (M32) · 마지막 줄바꿈 삭제 (M33) → `verify` 종료 코드 0, 선언 삭제 (M34) → 여전히 70 (reader 가 no-op 아님) | ✅ | ✅ green |
| 05-01 Task 2 | 05-01 | 1 | (WR-11 · IN-14 · WR-02 줄 번호 보존) | T-05-01 · T-05-03 | N/A | 지워 보기 | `lib/codegen.yaml` 에 규칙 한 줄 (M35) → 종료 코드 1, `[3/10]` 실패. 읽지 못하는 줄 (M36) → 70, stderr 에 `lib/codegen.yaml`. `lib/riverpod.yaml` 끝에 deprecated 규칙 (M37) → `[2/10]` 실패의 진단 줄 번호 == 원본 줄 번호(빈 줄 치환) · `[3/10]` 실패 `lib/riverpod.yaml 에 규칙이 있다 (1)` ((b′) 의 대상 범위) | ✅ | ✅ green |
| 05-03 Task 1 | 05-03 | 3 | DOCS-01 | T-05-09 | N/A | grep + 검사 (g) | 설치 블록에 `dev_dependencies` · `git:` · `ref: v2.0.0` · `flutter pub get`, 설치 절에 `ref: main` 없음. `[3/10]` 통과 | ✅ | ✅ green |
| 05-03 Task 1 | 05-03 | 3 | DOCS-02 | T-05-11 | N/A | grep + 검사 (e) | include 블록 넷(묶음 · 기본만 · 기본 + Riverpod · 기본 + codegen)이 `fixtures/{recommended,base_only,base_riverpod,base_codegen}/analysis_options.yaml` 의 include 줄을 담는다. README 의 모든 `package:woody_lints/<이름>.yaml` 이 `lib/` 에 있다 | ✅ | ✅ green |
| 05-03 Task 1 | 05-03 | 3 | DOCS-03 | T-05-11 | N/A | grep + 검사 (f) | 세 층 × 규칙 / plugin 진단의 예시 (`: false`, `diagnostics:`, `ignore_for_file: riverpod_lint/`, `ignore: riverpod_lint/`), 끄기 블록의 `version:` 이 `lib/riverpod.yaml` 과 같다 | ✅ | ✅ green |
| 05-03 Task 1 | 05-03 | 3 | DOCS-04 | T-05-12 | N/A | grep | tag 쪽 `ref:` 수정 + `flutter pub get`, `ref: main` 쪽 `flutter pub upgrade woody_lints`, main → tag 전환, `--enforce-lockfile` 과 종료 코드 65 | ✅ | ✅ green |
| 05-03 Task 1 | 05-03 | 3 | DOCS-05 | T-05-10 · T-05-12 | 복구 안내가 사용자의 다른 상태를 지우라고 하지 않는다 | grep + 사람 확인 | 문제 해결 넷 — plugin 경고가 안 보일 때, Analysis Server 재시작, `dart analyze` ↔ `flutter analyze` (3.47.5 · 2026-09-20), tag 를 고정해도 바뀌는 것 (plugin 버전 · 기반 세트 caret) | ✅ | ✅ green |
| 05-03 Task 1 | 05-03 | 3 | DOCS-06 | T-05-11 | N/A | grep + 검사 (d) | `require_trailing_commas` · `trailing_commas` 가 README 에 0줄, `invalid_annotation_target` 설명 있음. `[3/10]` 통과 | ✅ | ✅ green |
| 05-04 Task 2 | 05-04 | 3 | DOCS-07 | T-05-15 | N/A | grep (확인만) | `head -1 CHANGELOG.md` = `## 2.0.0 - 미출시`, 칸 제목 순서가 `VERSIONING.md` § "CHANGELOG 항목 형식" 과 같다 | ✅ | ✅ green |
| 05-04 Task 1 | 05-04 | 3 | DOCS-08 | T-05-14 | N/A | grep + 사람 확인 (diff 대조) | `## 1.1.0` · `## 1.2.0` · `## 1.2.1` · `## 1.2.2` · `## 1.2.3` · `## 1.2.4` · `## 1.2.5` 제목 7개, 커밋 번호 `2249a0b` · `ec66e3f` · `21c5689` · `31c8cb1` · `9451f6b` · `212365d` · `dbcd20b`, `^## ` 제목이 내림차순 | ✅ | ✅ green |
| 05-04 Task 2 | 05-04 | 3 | DOCS-09 | T-05-15 | N/A | grep (확인만) | `### 새로 생기는 경고` 표의 규칙 행 수 == `### 추가한 규칙` 불릿 수 (2026-10-14 셈 75 · 75 — `fb6386a` 가 `sort_pub_dependencies` 행을 더한 뒤의 값; 조사 문서의 74 는 그 전), `실측: flutter_starter_kit` 한 줄 | ✅ | ✅ green |
| 05-02 Task 1 | 05-02 | 2 | DOCS-10 (YAML 쪽) | T-05-05 · T-05-06 | N/A | grep + 실행 | `lib/base.yaml` 의 영어 템플릿 주석(옛 1 ~ 12 · 15 · 108 ~ 112행) 없음, 배포 YAML 다섯의 첫 줄이 `#`, `lib/codegen.yaml` 머리 주석 신설, `--update` → `바뀐 정답지가 없다` | ✅ | ✅ green |
| 05-03 Task 1 | 05-03 | 3 | DOCS-10 (README 쪽) | T-05-13 | N/A | grep | README 에 템플릿 HTML 주석 · 옛 "핵심가치" 절 없음 | ✅ | ✅ green |
| 05-03 Task 2 | 05-03 | 3 | VERIFY-06 (검사) | T-05-11 | N/A | 실행 + 마커 삭제 확인 | `[3/10]` (d) ~ (g) 가 Task 1 의 README 와 일치해 `점검 통과 (10개 중 10개)`; start 마커를 지운 README 에서 `[3/10]` 실패 · `구역이 없다` (README 먼저, 검사 다음 — 다른 커밋) | ✅ | ✅ green |
| 05-06 Task 1 | 05-06 | 4 | VERIFY-06 (헛통과 아님) | T-05-21 · T-05-22 | N/A | 지워 보기 | README 표시 구역에서 규칙 이름 삭제 (M38) → 종료 코드 1 · `[3/10]` 실패. 뒤쪽 블록의 프리셋 주소 오타 · plugin 버전 어긋남 · `ref:` 어긋남 · start 마커 삭제 (M39 ~ M42) 각각 실패 | ✅ | ✅ green |
| 05-02 Task 2 | 05-02 | 2 | (D-09) | T-05-08 | N/A | grep | `.claude/CLAUDE.md` 에 `포함된 규칙 목록` · `템플릿에서 온 영어 주석 … 그대로 둔다` 가 0줄 | ✅ | ✅ green |
| 05-01 Task 3 | 05-01 | 1 | (D-19 — 03 WR-02 · 04 WR-11 · IN-14) | T-05-04 | N/A | grep | `03-REVIEW-DISPOSITION.md` WR-02 · `04-REVIEW-DISPOSITION.md` WR-11 · IN-14 행이 `fixed` 와 05-01 의 커밋 해시로 바뀜, `open:` 수 (03 그대로 12, 04 18 → 17) | ✅ | ✅ green |
| 05-04 Task 2 | 05-04 | 3 | (D-19 — 01 WR-05) | T-05-15 | N/A | grep | `01-REVIEW-DISPOSITION.md` WR-05 행이 `fixed` 와 05-04 의 CHANGELOG 커밋 해시로 바뀜, `open: 13` → `12` | ✅ | ✅ green |
| 05-01 ~ 05-04 · 05-06 각 task · 05-05 Task 1 | 05-05 | 5 | (D-20) | T-05-04 · T-05-07 · T-05-13 · T-05-16 · T-05-17 | 비공개 사용 프로젝트의 경로 · 메시지 · 코드가 저장소와 `.planning/` 에 없다 | grep (커밋 전 · push 전 범위 전체) | 각 task 의 `<automated>` 에 절대 경로 grep; 05-05 Task 1 이 올릴 범위 전체에 `05-RESEARCH.md` § 6 의 (1) · (2) · (3) 을 돌려 모두 0줄 | ✅ | ✅ green |
| 05-05 Task 2 · 3 | 05-05 | 5 | (D-21) | T-05-18 · T-05-20 | workflow 가 읽기 권한만 가진다 | e2e (GitHub, 읽기 전용 조회) | 소유자 확인 뒤 첫 push → `gh run list --workflow verify.yml --limit 1` → `completed success` | ✅ | ✅ green |
| 05-07 Task 1 | 05-07 | 6 | VERIFY-06 (gap 1 · IN-06) | T-05-24 · T-05-25 · T-05-26 | N/A | 지워 보기 (복제본) | README 표시 구역에 옛 꼴 `- require_trailing_commas: 자동 코드 정렬 최적화` (M43) → `(1)`, `* `extra`` 와 `- `Extra_Rule`` (M44) → `(2)` — 종료 코드 1 · `[3/10]` 실패 · `구역에 읽지 못하는 줄이 있다` · 이름 비교 블록 없음; 낱말 `RulesMdBlock` 0 (`grep -wF`); 복제본 기준 실행 10/10; 마커 처리는 `readMarkerBlock` 하나 | ✅ | ✅ green |
| 05-07 Task 2 | 05-07 | 6 | VERIFY-06 · DOCS-06 (gap 2 · WR-04) | T-05-24 · T-05-25 · T-05-26 | N/A | 지워 보기 (복제본) | `lib/codegen.yaml` 끝 `linter: {rules: [prefer_mixin]}` (M45) → 70 · 빈 stdout · stderr 의 파일 이름 · 행; 줄 끝 주석을 단 블록 꼴 (M46) → `[3/10]` 실패 1 (과잉 수정 아님); README 378행 문장 | ✅ | ✅ green |
| 05-07 Task 3 | 05-07 | 6 | VERIFY-06 (WR-02) | T-05-26 · T-05-29 | N/A | 지워 보기 (복제본) | `version: "^3.1.3"` (M47) · `ref: v1.9.0 # 예시` (M48) → 벗긴 값 줄; `riverpod_lint: ^3.1` (M49) → 읽지 못하는 줄 `(1)`; 맞는 값에 따옴표 · 주석만 붙은 맵 키 줄 (M50) → 10/10 | ✅ | ✅ green |
| 05-08 Task 1 | 05-08 | 7 | VERIFY-06 (`RULES.md` 표 reader — 소유자 승인 Q1; measure 주석 — R2-Q4) | T-05-27 · T-05-30 · T-05-39 | N/A | 지워 보기 (복제본) + diff | `RULES.md` 켠 규칙 구역에 backtick 없는 행 (M51) · 대문자 이름 행 (M52) → `(1)`, 불릿과 행이 있는 구역의 `없음 — …` (M53) → `(2)` — `[3/10]` 실패 · `구역에 읽지 못하는 줄이 있다` · 표 비교 블록 없음; `없음 — …` 빈 표 줄로 기준 실행 10/10; `tool/measure_rules.dart` 는 `c06d8d5` 대비 `///` 줄만 바뀜 | ✅ | ✅ green |
| 05-08 Task 2 | 05-08 | 7 | VERIFY-06 (WR-01 · W1 둘째 입력 R2-Q3 · WR-03) | T-05-28 · T-05-30 | N/A | 지워 보기 (복제본) | 주소 `codegen.yml` (M54) → `꼴이 아닌 것이 있다 (1)`; `package:woody_lint/riverpod.yaml` 과 `package:woody-lints/base.yaml` (M55) → 다른 패키지의 주소 `(2)`; `~~~` 펜스 (M56) · 긴 펜스 안의 짧은 펜스 짝 (M57) · `~~~` 안의 백틱 펜스 짝 (M58) → 값 줄 `  ref: v1.9.0` | ✅ | ✅ green |
| 05-08 Task 3 | 05-08 | 7 | VERIFY-06 (`enabledLanguageOptions` — R2-Q2) | T-05-30 · T-05-38 | N/A | 지워 보기 (복제본) | `lib/base.yaml` 끝 `language: {…}` (M59) · `analyzer: {language: {…}}` (M60) · `strict-casts: yes` (M61) → 70 · 파일 이름 · 행 · 원인; 줄 끝 주석을 단 블록 꼴 (M62) → 종료 코드 1 · `+ strict-casts` (과잉 수정 아님) | ✅ | ✅ green |
| 05-09 Task 1 | 05-09 | 8 | VERIFY-06 (WR-05 · R2-Q1 · IN-01 · IN-05) | T-05-31 · T-05-36 | N/A | 지워 보기 (복제본) | `riverpod_lint: "^3.1.9"` (M63) · `pubspec.yaml` 따옴표 version (M67) → 10/10; 고정 버전 `3.1.9` 를 네 자리에 (M64) · 키 줄에 주석 · 맵 안에서 `version:` 이 뒤 (M65) → `[3/10]` · `[4/10]` 통과 · 70 아님; 범위 제약 (M66) → 70 · 원인 문구; 분모 4 인 단계 번호 0줄 | ✅ | ✅ green |
| 05-09 Task 2 | 05-09 | 8 | DOCS-06 · DOCS-07 (W4 · IN-02 · IN-03 · IN-04 · IN-07) | T-05-32 | 배포 YAML 의 선언 값이 바뀌지 않는다 | grep + 실행 | README 의 `^3.1.9` 는 코드 블록 두 줄에만; 382행이 함께 고칠 자리 셋; 45 · 91행 · CHANGELOG 92행 새 문장; `lib/riverpod.yaml` 비주석 내용 불변 · 정답지 불변; 검증 10/10 | ✅ | ✅ green |
| 05-09 Task 3 | 05-09 | 8 | (Q4 처리 기록 · D-20 · D-21) | T-05-33 · T-05-34 · T-05-35 · T-05-37 | 비공개 정보가 공개 저장소에 올라가지 않는다; workflow 는 읽기 권한만 | grep (push 범위 전체) + e2e (GitHub) | 처리 기록 fixed 12 · deferred 1 · open 0 (해시가 실제 수정 커밋); 범위 `92d478a..HEAD` 비공개 점검 셋 + 이력(`git log -p`) 0 — push 전에 첫째 자동 검증 명령으로 돌려 0 일 때만; `git push origin gsd/v2.0-package-rework` → `verify` success · 로그 두 줄 | ✅ | ✅ green |
| 05-10 Task 1 | 05-10 | 9 | VERIFY-06 · DOCS-06 (2회차 gap · WR-10 — 소유자 결정 G2-Q1 · G2-Q4) | T-05-40 · T-05-41 · T-05-42 · T-05-43 · T-05-46 · T-05-47 · T-05-54 | N/A | 지워 보기 (복제본) | `lib/codegen.yaml` 끝 `linter :` (M68) · `"linter":` (M69), `lib/riverpod.yaml` 끝 `linter :` (M70), codegen `analyzer:` 아래 `language:` (M71), 끝 `formatter:` (M72), 열 0 밖의 최상위 (M73) → 종료 코드 1 · `[3/10]` 실패 · `최상위에 받지 않는 줄이 있다` / `바로 아래에 받지 않는 줄이 있다` · 10개 중 1개, M68 ~ M70 에 `에 규칙이 있다` 없음; `lib/riverpod.yaml` 의 `plugins:` 아래 `custom_lint` · 따옴표 키 (M78) → 종료 코드 1 · `plugins:` 바로 아래 블록 `(2)`; 회귀 M45 · M36 · M34 · M59 · M60 · M61 · M66 → 70, M46 · M62 → 실패, M65 · M63 → 10/10; `declaredRuleNames` · (e) ~ (g) · `fencedLines` 의 코드 줄 `644897f` 그대로; README 378행 | ✅ | ⬜ pending |
| 05-10 Task 2 | 05-10 | 9 | VERIFY-06 (표시 구역 밖 목록 줄 — 소유자 결정 G2-Q3) | T-05-43 · T-05-44 · T-05-46 · T-05-47 | N/A | 지워 보기 (복제본) | end 마커 뒤 `- `bogus_after_marker`` (M74) → `(1)`; `*` · `+` · `1.` · `1)` · `> -` (M75) → `(5)`; 앞 · 다음 절의 불릿 (M76) → 10/10; 펜스 뒤 불릿 (M77) → `(1)` · 펜스 안 줄 제외; start 마커 삭제 · 구역 안 옛 꼴 → 각자의 블록만 | ✅ | ⬜ pending |
| 05-10 Task 3 | 05-10 | 9 | DOCS-06 (WR-07 · WR-08 · WR-09 · IN-08 — 소유자 결정 G2-Q2 · G2-Q5) | T-05-45 | 검사는 넓히지 않는다 | grep + 실행 | README 382행 · `example/README.md` 116 · 358 · 395 · 436행의 새 구절 있음 · 옛 구절 0; `tool/verify.dart` 의 (e) ~ (g) 주석 새 조각 15 · 옛 조각 0, 코드 줄(주석 줄을 뺀 줄)은 Task 2 커밋과 같고 여덟 구간은 `644897f` 와 같음 (코드 한 글자 변경 · 주석 미변경은 실패); `example/README.md` 변경 `4/4`; 작업 트리 검증 10/10 | ✅ | ⬜ pending |
| 05-11 Task 1 | 05-11 | 10 | (처리 기록 — G2-Q1 · G2-Q2) | T-05-48 | N/A | grep | 처리 기록 fixed 13 · skipped 4 · deferred 1 · open 0 (WR-10 → 05-10 Task 1, 넷 → 05-10 Task 3 의 실제 커밋, skipped 이유 G2-Q2); 앞 회차 행 · 제목 · `recorded:` 불변; CHANGELOG 불변 | ✅ | ⬜ pending |
| 05-11 Task 2 | 05-11 | 10 | VERIFY-06 (CI) · (D-20 · D-21) | T-05-49 · T-05-50 · T-05-51 · T-05-52 · T-05-53 | 비공개 정보가 공개 저장소에 올라가지 않는다; workflow 는 읽기 권한만 | grep (push 범위 전체) + e2e (GitHub) | 범위 `8789cfe..HEAD` 비공개 점검 + 이력 0, 심은 경로는 `LEAK?` 로 잡힘 — push 전에 첫째 자동 검증으로 돌려 0 일 때만; `git push origin gsd/v2.0-package-rework` → origin 머리의 `verify` success · 로그 두 줄; `main` · tag · PR 불변 | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `tool/verify.dart` — `stripPlugins` · `readShippedPluginConstraint` · `fragmentLineHint` 고침 (WR-02, `1831c04`), `declaredRuleNames` 의 파일 이름 인자 (IN-14) · `[3/10]` (b′) (WR-11) (`dc42790`), `[3/10]` (d) ~ (g) (VERIFY-06 — README 재작성 `3a248d0` 뒤의 다른 커밋 `84f937a`, 05-03 Task 2)
- [x] `README.md` 의 표시 구역 — VERIFY-06 확인의 대상 (`3a248d0`, 이름 81개)
- [x] `example/README.md` 의 새 소절 — M32 ~ M37 (`1831c04` · `dc42790`), M38 ~ M42 (`1d28346`)
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

- [x] All tasks have `<automated>` verify or Wave 0 dependencies (05-05 Task 2 는 소유자 결정 checkpoint — 자동 검증 대상 아님)
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [ ] Feedback latency < 30s — 로컬 `verify.dart` 한 번은 약 19 ~ 25초로 맞지만, 지워 보기를 담은 `<automated>` 는 45 ~ 126초 (아래 표). 지워 보기 수만큼 `verify.dart` 를 다시 돌리기 때문이다
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** validated 2026-10-14 (orchestrator 감사 — 아래 표 둘; gap 수정 05-07 ~ 05-09 포함)

---

## 감사 결과 (2026-10-14)

방법: 저장소를 `git clone --local` 로 복제하고 루트 `fvm dart pub get` 을 한 뒤, task 마다 **그 task 의 커밋으로 되돌린 상태**에서 계획의 `<automated>` 한 줄을 뽑아 적힌 그대로 `bash -x` 로 돌렸다 (복제본에는 GSD 상태 파일이 없어 작업 트리가 깨끗하다). 원격을 보는 05-05 의 둘은 본 작업 폴더에서 돌렸다. 매 실행 뒤 복제본의 `git status --porcelain` 은 0줄이었다.

| Task | 기준 커밋 | 적힌 그대로 rc | 고친 판 rc | 시간 | 메모 |
|------|-----------|----------------|------------|------|------|
| 05-01 T1 | `1831c04` | 0 | — | 117초 | M32 · M33 rc 0, M34 rc 70 |
| 05-01 T2 | `dc42790` | 0 | — | 71초 | M35 rc 1, M36 rc 70, M37 rc 1 (`:N` 원본 줄 번호) |
| 05-01 T3 | `2be345e` | 0 | — | 0초 | HEAD 제목 단언 — 마무리 커밋 뒤에는 SHA 고정 판으로만 통과 (HEAD `297375a` 에서 적힌 그대로 rc 1, `2be345e` 고정 rc 0) |
| 05-02 T1 | `209e3af` | 0 | — | 45초 | `--update` → `바뀐 정답지가 없다` |
| 05-02 T2 | `403c584` | **1** | 0 | 0초 | 단언 결함: `grep -E '^-[^-]'` 는 지운 Markdown 불릿 줄(diff 에서 `-- …`)을 세지 못해 늘 0 → diff 머리(`--- a/`)만 빼고 `^-` 로 센 판 rc 0. 실제 diff 는 `--numstat` 2 · 2 |
| 05-03 T1 | `3a248d0` | 0 | — | 23초 | README 절 아홉 · 표시 구역 81개 · 코드 블록 값 |
| 05-03 T2 | `84f937a` | 0 | — | 45초 | start 마커 삭제 → `[3/10]` 실패 · `구역이 없다` |
| 05-04 T1 | `024a36c` | 0 | — | 0초 | 그 뒤 Task 2 가 2.0.0 항목을 고쳐 HEAD 에서는 `fb6386a` 비교 단언이 깨진다 (상태 고정 — 계획대로) |
| 05-04 T2 | `6abea40` | 0 | — | 0초 | |
| 05-06 T1 | `1d28346` | 0 | — | 126초 | M38 ~ M42 모두 rc 1 · `[3/10]` 만 실패 |
| 05-05 T1 | HEAD `72d7015` (본 작업 폴더) | 1 | 1 | — | 적힌 그대로는 GSD 도구 상태 파일 4건(`.planning/config.json` 수정, `state.json` · `milestone.lock` · `research/.cache/`) 때문에 `test -z "$(git status --porcelain)"` 에서 실패. 그 4건만 거른 판도 지금은 rc 1 — push 뒤 범위가 `92d478a..72d7015` (마무리 커밋 2개)로 줄어 PLAN · RESEARCH 가 범위 밖이다 (push 전 점검이라 상태 고정). push 전 executor 실행에서는 거른 판 rc 0 (`05-05-SUMMARY.md`) |
| 05-05 T3 | `92d478a` 고정 (본 작업 폴더) | 1 | 0 | — | 적힌 그대로는 같은 4건과 HEAD (마무리 커밋 2개가 origin 보다 앞섬) 때문에 실패. 4건을 거르고 `git rev-parse HEAD` 를 push 한 `92d478a` 로 고정한 판 rc 0 — origin 작업 브랜치 == `92d478a`, head 둘, tag `v1.3.0` 하나, PR 0, run 38460138720 `success`, 로그 두 줄 |

독립 확인 (orchestrator, 2026-10-14): GitHub run 38460138720 은 `completed` · `success` (push 이벤트, headSha `92d478a`), 로그에 `[3/10] 배포 파일의 구성 ................ 통과` 와 `점검 통과 (10개 중 10개)`. push 범위 `0db0fdd..92d478a` (65커밋, 59파일) 의 추가된 줄 전체에서 절대 경로 꼴 0줄, 이메일 꼴 0개, 커밋 메시지 65개 0줄, 비공개 사용 프로젝트는 이름만 35줄(경로 꼴 0).

남은 수동 확인은 위 Manual-Only 넷이다 — `/gsd-verify-work 5` 에서 소유자가 본다.

## 감사 결과 — gap 수정 05-07 · 05-08 · 05-09 (2026-10-14)

방법은 위와 같다: `git clone --local` 복제본 하나에서 task 마다 그 task 의 커밋으로 `git checkout --detach` → 루트 `fvm dart pub get --no-example` → 계획의 `<automated>` 를 적힌 그대로 `bash -x` → `git checkout -- . && git clean -fdq -e .dart_tool`. 끝난 뒤 복제본의 `git status --porcelain` 은 0줄이었다. 원격을 보는 05-09 Task 3 의 둘째 `<automated>` 는 본 작업 폴더에서 돌렸다.

| Task | 기준 커밋 | 적힌 그대로 rc | 고친 판 rc | 시간 | 메모 |
|------|-----------|----------------|------------|------|------|
| 05-07 T1 | `5f43726` | 0 | — | 119초 | M43 `(1)` · M44 `(2)`, 복제본 기준 실행 10/10 |
| 05-07 T2 | `057bef2` | 0 | — | 99초 | M45 rc 70 · 빈 stdout, M46 rc 1 (`lib/codegen.yaml` 에 규칙이 있다) |
| 05-07 T3 | `73f1c66` | 0 | — | 165초 | M47 · M48 벗긴 값 줄, M49 읽지 못하는 줄 `(1)`, M50 10/10 |
| 05-08 T1 | `812c477` | 0 | — | 142초 | M51 · M52 `(1)`, M53 `(2)`; `tool/measure_rules.dart` 는 `c06d8d5` 대비 `///` 줄만 |
| 05-08 T2 | `63fe3d9` | 0 | — | 193초 | M54 꼴이 아닌 주소, M55 다른 패키지 주소 `(2)`, M56 ~ M58 값 줄 `ref: v1.9.0` |
| 05-08 T3 | `a14be4f` | 0 | — | 107초 | M59 ~ M61 rc 70, M62 rc 1 (`+ strict-casts`) |
| 05-09 T1 | `644897f` | 0 | — | 242초 | M63 · M67 10/10, M64 · M65 70 아님, M66 rc 70 · 원인 문구 |
| 05-09 T2 | `e46cff4` | 0 | — | 70초 | README 의 `^3.1.9` 는 코드 블록 두 줄, `057bef2` 대비 README 5 · 5, 검증 10/10 |
| 05-09 T3 (첫째) | `8789cfe` | 0 | — | 25초 | 처리 기록 fixed 12 · deferred 1 · open 0, 범위 `92d478a..8789cfe` 비공개 점검 0 |
| 05-09 T3 (둘째) | `8789cfe` 고정 (본 작업 폴더) | 1 | 0 | 11초 | 적힌 그대로는 HEAD 단언 — 로컬 마무리 커밋(`c42dc33` · `c401d82` · `445ce22`)이 origin 보다 앞서 `origin == HEAD` 가 거짓 (상태 고정). `git rev-parse HEAD` 두 자리를 push 한 `8789cfe` 로 바꾼 판 rc 0 — origin 작업 브랜치 == `8789cfe`, head 둘, tag `v1.3.0` 하나, PR 0, run 38502214557 `success`, 로그 두 줄. executor 는 push · CI 직후(마무리 커밋 전)에 적힌 그대로 rc 0 (`05-09-SUMMARY.md`) |

독립 확인 (orchestrator, 2026-10-14): GitHub run 38502214557 은 `completed` · `success` (headSha `8789cfe`, job 02:39:59Z ~ 02:44:13Z), 로그에 `[3/10] 배포 파일의 구성 ................ 통과` 와 `점검 통과 (10개 중 10개)`. push 범위 `92d478a..8789cfe` (25커밋) 의 추가된 줄에서 절대 경로 꼴 0줄, 이메일 꼴 0줄, 비공개 사용 프로젝트는 이미 있던 "실측: … (Dart 파일 474개)" 줄의 인용 3줄뿐(경로 꼴 0).

## Validation Audit 2026-10-13

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
