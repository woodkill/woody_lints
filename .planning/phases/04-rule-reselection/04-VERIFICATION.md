---
phase: 04-rule-reselection
verified: 2026-10-13T13:20:36Z
status: passed
score: 11/11 must-haves verified
covered_files:
  - .planning/REQUIREMENTS.md
  - .planning/phases/04-rule-reselection/04-01-PLAN.md
  - .planning/phases/04-rule-reselection/04-01-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-02-PLAN.md
  - .planning/phases/04-rule-reselection/04-02-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-03-PLAN.md
  - .planning/phases/04-rule-reselection/04-03-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-04-PLAN.md
  - .planning/phases/04-rule-reselection/04-04-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-05-PLAN.md
  - .planning/phases/04-rule-reselection/04-05-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-06-PLAN.md
  - .planning/phases/04-rule-reselection/04-06-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-07-PLAN.md
  - .planning/phases/04-rule-reselection/04-07-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-08-PLAN.md
  - .planning/phases/04-rule-reselection/04-08-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-09-PLAN.md
  - .planning/phases/04-rule-reselection/04-09-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-10-PLAN.md
  - .planning/phases/04-rule-reselection/04-10-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-11-PLAN.md
  - .planning/phases/04-rule-reselection/04-11-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-12-PLAN.md
  - .planning/phases/04-rule-reselection/04-12-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-13-PLAN.md
  - .planning/phases/04-rule-reselection/04-13-SUMMARY.md
  - .planning/phases/04-rule-reselection/04-DECISIONS.md
  - .planning/phases/04-rule-reselection/04-REVIEW-DISPOSITION.md
  - CHANGELOG.md
  - RULES.md
  - example/README.md
  - example/expected_diagnostics.txt
  - example/pubspec.yaml
  - fixtures/base_codegen/expected_diagnostics.txt
  - fixtures/base_codegen/pubspec.yaml
  - fixtures/base_only/expected_diagnostics.txt
  - fixtures/base_only/pubspec.yaml
  - fixtures/base_riverpod/expected_diagnostics.txt
  - fixtures/base_riverpod/pubspec.yaml
  - fixtures/overrides/expected_diagnostics.txt
  - fixtures/overrides/pubspec.yaml
  - fixtures/recommended/pubspec.yaml
  - lib/analysis_options.yaml
  - lib/base.yaml
  - lib/codegen.yaml
  - lib/recommended.yaml
  - lib/riverpod.yaml
  - tool/measure_rules.dart
  - tool/measurements/2026-10-13-R1.json
  - tool/verify.dart
covered_digest: "v3:sha256:24720f51440a88648404063c7991676be51ee3e865169c24890ba7440e52fadd"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 10/11
  gaps_closed:
    - "진실 6 (04-01 must-have, D-11) — 기반 세트가 켜는 규칙이나 `RULES.md` 에 없는 규칙을 `lib/base.yaml` 에 더하면 `[3/10]` 이 실패한다. 따옴표 이름(M27 · M28)은 `[3/10]` 만 실패 rc 1, 읽지 못하는 줄(M29 ~ M31, 짝이 다른 따옴표, 이름 뒤의 다른 말)은 rc 70 — 블록 안에서 건너뛰는 분기가 없다 (WR-10 닫힘)"
  gaps_remaining: []
  regressions: []
---

# Phase 4: Rule Reselection 재검증 보고서 (gap 수정 2회차 04-13 뒤)

**Phase 목표:** 배포 파일의 규칙 하나하나가 `flutter_starter_kit` 실측을 본 소유자의 결정으로 켜져 있고, 켠 이유와 켜지 않은 이유가 기록으로 남아 있다
**검증 시각:** 2026-10-13T13:20:36Z
**상태:** passed
**재검증:** 예 — gap 수정 plan 04-13 (`67d1bc7` · `76dee2f` · `8f4e257`, 마무리 `accee5a`) 과 재리뷰 `363356d` 뒤, HEAD `363356d`

검증은 모두 verifier 임시 폴더 안에 `git clone --local` 로 만든 복제본에서 했다. 복제본 루트에서 `fvm dart pub get` 을 먼저 했다. 변경은 한 번에 하나만 만들고, 돌린 직후 `git checkout -- <파일>` 로 되돌렸으며, 실험마다 `git diff --quiet HEAD -- lib RULES.md` 가 참인 것을 봤다. 작업 트리는 이 파일을 쓴 것 말고는 바꾸지 않았다. 측정 도구의 `--stage` 는 돌리지 않았고 비공개 사용 프로젝트는 건드리지 않았다. 실측 값은 커밋된 `tool/measurements/2026-10-13-R1.json` 과 출력 모드(`--audit` · `--recount` · `--report`)로 판정했다.

## 목표 달성

### 관찰 가능한 진실

| # | 진실 | 상태 | 근거 |
|---|------|------|------|
| 1 | (성공 기준 1) 후보 규칙마다 실측 진단 건수와 `dart fix` 건수를 표 하나에서 본다 — strict 계열 포함 | ✓ VERIFIED (회귀 확인) | 지난 검증(`e89ad75`) 뒤로 `tool/measurements/` · `tool/measure_rules.dart` · `lib/` · CHANGELOG · 샘플 · 정답지는 바뀌지 않았다 (`git diff --quiet e89ad75 HEAD -- …` 참). 복제본에서 `--report --in tool/measurements/2026-10-13-R1.json` rc 0, 출력 206줄이 `RULES.md` 의 `woody:measurements` 마커 사이와 `diff` 0줄 |
| 2 | (성공 기준 2) 수치마다 회차를 따라갈 수 있고, 회차에 SDK · 기반 세트 · plugin 버전이 있으며, 무효 회차의 수치는 쓰이지 않았다 | ✓ VERIFIED (회귀 확인) | R1 JSON 은 지난 검증 때와 바이트 단위로 같다 (위 `git diff --quiet`). `--recount --in …` rc 0 `다시 센 행 133개 — 바뀐 행이 없다`. 지난 보고서의 회차 판정(52회차 모두 유효 · 조건 필드 완비)이 그대로다 |
| 3 | (성공 기준 3) 후보마다 소유자의 결정이 기록되어 있고, 배포 파일의 켠 규칙이 채택 목록과 같다 | ✓ VERIFIED | `04-DECISIONS.md` 결정 표(782행 `## 결정` 아래) 133행의 `결정` 칸: `켬` 81 · `안 켬` 38 · `결정 안 함` 14 (v2 RULES-09 4 · RULES-10 7 · RULES-11 1, 표식 불가 2). `켬` 81 == Ruby YAML 파서로 읽은 `lib/base.yaml` 81 (차집합 양쪽 0, 중복 0). 배포 YAML 다섯 가운데 `linter.rules` 가 있는 파일은 `lib/base.yaml` 하나 (나머지 넷은 0) — 사용 프로젝트가 받는 이 패키지의 규칙은 81개뿐이다 |
| 4 | (성공 기준 4) 배포 파일에 기반 세트 겹침과 주석 처리된 설정 3개가 없고, 사유 주석이 사실과 맞다 | ✓ VERIFIED | `lints` 6.1.0 core · recommended 와 `flutter_lints` 6.0.0 flutter (102개) 와 `lib/base.yaml` 81개의 교집합 0. `lib/*.yaml` 다섯에서 `require_trailing_commas` · `public_member_api_docs` · `formatter` 0건. 사유 주석 81개가 `RULES.md` 켠 규칙 표의 `켠 이유` 칸과 글자 그대로 같다 (불일치 0). 사유가 사실인지는 지난 보고서의 판정(샘플 · 정답지)이 그대로이고, 그 파일들은 바뀌지 않았다 |
| 5 | (성공 기준 5) 켠 규칙마다 이유와 실측 건수의 근거 문서, 켜지 않은 규칙과 그 사유의 목록이 있다 | ✓ VERIFIED | `RULES.md` 켠 규칙 81행 · 켜지 않은 규칙 90행, 두 표에 겹친 이름 0. `--audit` rc 0 `감사 통과 — 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0`. `sort_pub_dependencies` 행의 실측 칸이 이제 `2 (pubspec.yaml 2 — lib · test · bin 은 0)` (IN-08) — 평가표 `2 (0·0·0·2)` 와 같은 값이고 0줄처럼 읽히지 않는다 |
| 6 | (04-01, 지난 gap) 기반 세트 규칙이나 `RULES.md` 에 없는 규칙을 `lib/base.yaml` 에 더하면 `[3/10]` 이 실패한다 (D-11) | ✓ VERIFIED (지난 gap 닫힘) | 아래 "진실 6 판정". 따옴표 이름 둘은 `[3/10]` 만 실패 rc 1, 읽지 못하는 줄 다섯 꼴은 rc 70, 열 0 주석(M26)은 그대로 rc 1. 건너뛰는 분기가 코드에 없다 |
| 7 | (04-02 · 04-04) 측정 도구가 회차 조건을 기록하고 저장소 밖에서만 돌며, 결과에 사용 프로젝트의 경로 · 메시지가 없다 | ✓ VERIFIED (회귀 확인) | `tool/measure_rules.dart` 는 `c06d8d5` 와 같고 R1 JSON 은 지난 검증과 같다. 지난 검증 뒤 바뀐 파일(`tool/verify.dart` · `example/README.md` · `RULES.md` · `.planning/`)의 더한 줄에 절대 경로 꼴 0 |
| 8 | (04-03 · 04-09) `RULES.md` 실측 기록이 `--report` 출력과 같고, `--audit` 이 통과한다 | ✓ VERIFIED | 진실 1 · 5 의 `diff` 0줄 · `--audit` rc 0 |
| 9 | (04-06 ~ 04-08, 04-12) 결정이 배포 파일에 반영되고, 새로 켠 규칙은 정답지에 줄이 있으며 검증이 통과한다 | ✓ VERIFIED | 깨끗한 복제본 `fvm dart run tool/verify.dart` rc 0, `점검 통과 (10개 중 10개)` (plugin 준비 포함 73초). 루트 `fvm dart analyze` → `No issues found!`, `fvm dart format --output=none --set-exit-if-changed tool` rc 0. 헛통과가 아님: 아래 "동작 확인" 의 깨기 실험 12개 가운데 11개가 rc 1 또는 70 |
| 10 | (04-09 · 04-12) CHANGELOG `### 추가한 규칙` · `### 새로 생기는 경고` 가 새로 켠 규칙과 실측에 맞다 | ✓ VERIFIED (회귀 확인) | CHANGELOG 는 지난 검증 뒤로 바뀌지 않았다. `## 2.0.0` 의 `### 추가한 규칙` 불릿 75줄 == 81 − 1.3.0 의 6 |
| 11 | (04-10 · 제약) `main` 은 1.3.0 그대로다; 브랜치 CI 가 통과했다 | ✓ VERIFIED (04-10 시점) | `origin/main` = `90a2736`, `version: 1.3.0`, `git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` 참. 마지막 CI `38351171683` completed · success (head `0db0fdd`). push 하지 않은 커밋이 36개다 — 같은 10단계를 깨끗한 복제본에서 돌려 통과했다 (진실 9). 정보로만 적는다 |

**점수:** 11개 중 11개 verified (present, behavior-unverified 0)

진실 6 · 9 는 동작을 주장하는 진실이라 grep 이 아니라 깨기 실험으로 판정했다.

### 진실 6 판정 (지난 gap, WR-10) — 닫힘

04-13 must-have 진실 1 · 2 의 원문: "`[3/10] 배포 파일의 구성` 은 `lib/base.yaml` 의 `linter:` 블록 안에서 따옴표로 감싼 규칙 이름도 읽는다 …", "`declaredRuleNames` 는 `linter:` 블록 안의 비주석 · 비공백 줄을 조용히 건너뛰지 않는다 … 결함 꼴(읽지 못한 줄을 건너뜀)이 인용된 입력 하나가 아니라 통째로 닫힌다". 복제본(HEAD `363356d`)에서 `lib/base.yaml` 의 `- no_raw_types` 줄 뒤(106행)에 한 줄씩 더해 돌렸다.

| 입력 (106행) | rc | 결과 |
|---|---|---|
| M27 `    - 'avoid_print' # 기반 세트와 겹침 (따옴표)` | 1 | `[3/10]` 만 실패. 겹침 `avoid_print  (flutter_lints-6.0.0 flutter.yaml)`, `+ avoid_print  (base.yaml 에만)`, `점검 실패 (10개 중 1개)` (24초) |
| M28 `    - "prefer_mixin" # RULES.md 켠 규칙 표에 없음 (큰따옴표)` | 1 | `[3/10]` 만 실패. `+ prefer_mixin  (base.yaml 에만)` 하나, 겹침 블록 없음 (24초) |
| M29 `    - avoid_print: true # …` | 70 | stdout 0바이트, stderr `` 파일 모양이 예상과 다르다: `linter:` 블록의 106행을 읽지 못했다 — … (04-REVIEW.md WR-10): - avoid_print: true # 읽지 못하는 꼴 (맵 항목) `` (3초) |
| M30 `    -` 와 다음 줄 `      avoid_print # …` | 70 | 같은 문구, 끝이 `: -` (2초) |
| M31 `    avoid_print: true # …` (대시 없는 맵 형식) | 70 | 같은 문구, 끝이 그 줄 (3초) |
| (검증자 추가) `    - 'avoid_print" # 따옴표 짝이 다름` | 70 | 같은 문구 (3초) |
| (검증자 추가) `    - avoid_print extra` | 70 | 같은 문구 (3초) |
| M26 회귀: 열 0 주석 `# 실험 중` + `avoid_print` + `prefer_mixin` | 1 | `[3/10]` 만 실패, 겹침 1 · `+ avoid_print` · `+ prefer_mixin` (24초) — 04-11 의 수정이 그대로다 |
| (검증자 추가) `linter:` 키를 `"linter":` 로 | 1 | `[2/10]` (`- 규칙이름` 줄을 하나도 세지 못했다) · `[3/10]` (`- … (RULES.md 에만)` 81줄) 실패 — 블록 자체를 못 찾는 꼴도 통과하지 않는다 |

코드: `tool/verify.dart` 의 `declaredRuleNames` 루프에서 블록 안의 비주석 · 비공백 줄은 `rulesKeyPattern` 에 맞으면 `continue`, `rulePattern` 에 맞으면 이름을 더하고, 아니면 `throw FormatException` 이다 — 세 갈래뿐이다. 진실 3 의 "`readRuleNameAt` 과 `tool/measure_rules.dart` 는 바뀌지 않았다" 는 `c06d8d5` 와의 `diff` 0 · `git diff --quiet` 참으로 확인했다.

04-13 의 `<automated>` 셋을 PLAN 에서 뽑아 그 task 의 커밋으로 되돌린 복제본에서 `bash` 로 돌렸다: Task 1 @`67d1bc7` rc 0 (91초, M27 ~ M31 을 실제로 돌리는 단언 포함), Task 2 @`76dee2f` rc 0 (26초), Task 3 @`8f4e257` rc 0 (22초). SUMMARY 의 주장(M27 ~ M31 결과, 보통 실행 10/10, `--audit` 81 · 0 · 90 · 0, `readRuleNameAt` · `tool/measure_rules.dart` 불변)은 모두 실행으로 맞다. 시간만 몇 초 다르다.

### 주장 판정

#### 1. WR-11 (`lib/codegen.yaml` · `lib/riverpod.yaml` 의 규칙이 `[3/10]` 을 지나친다) — 경고 (gap 아님)

- **재현 (복제본):**
  - `lib/codegen.yaml` 끝에 `linter:` / `  rules:` / `    - avoid_print # 기반 세트와 겹침` / `    - prefer_mixin # RULES.md 켠 규칙 표에 없음` → `점검 통과 (10개 중 10개)` rc 0 (23초).
  - `lib/riverpod.yaml` 끝에 같은 꼴로 `- prefer_mixin` → rc 0 (23초).
  - `lib/codegen.yaml` 끝에 `- avoid_positional_boolean_parameters` → `[3/10]` 통과, `[5/10]` · `[9/10]` · `[10/10]` 만 실패 rc 1 (정답지에 없는 `lib/style_rules.dart:76` · `:113  info  avoid_positional_boolean_parameters`). 조각의 규칙이 실제로 사용 프로젝트까지 간다는 증거다. 정답지 차이는 `--update` 로 굳힐 수 있다.
  - 대조 M23: `lib/recommended.yaml` 끝에 `linter: rules: - prefer_mixin` → `[3/10]` 실패 rc 1 (23초).
- **M23 · M24 와 다른 점:** 04-01 의 진실은 "`lib/recommended.yaml` 이나 `lib/analysis_options.yaml` 에 규칙을 적으면 `[3/10]` 이 실패한다" 이다. 이것은 (a) 묶음 · 별칭이 `include:` 만 담는지에 대한 검사이고, 대조 실험대로 지금도 맞다. `codegen.yaml` · `riverpod.yaml` 은 묶음 · 별칭이 아니라 조각이라 (a) 의 대상이 아니다.
- **진실의 범위:** must-have 원문은 모두 `lib/base.yaml` 을 이름으로 적는다.
  - 04-01 진실 3: "(b) `lib/base.yaml` 의 규칙이 기반 세트와 겹치지 않는지 (c) `RULES.md` 켠 규칙 표 == `lib/base.yaml` 규칙 목록인지".
  - 지난 진실 6: "… 규칙을 `lib/base.yaml` 에 더하면".
  - 04-13 진실 1: "`lib/base.yaml` 의 `linter:` 블록 안에서".
  - D-11 (1) · (2) 도 `lib/base.yaml` 이다.
  - 조각 파일에 대한 검사를 약속한 must-have 는 없다 (PLAN 13개의 must_haves 를 `codegen` · `riverpod.yaml` · `조각` 으로 찾아 0건).
  - 그래서 WR-11 의 입력은 어느 진실도 거짓으로 만들지 않는다. 지난 보고서의 판정 규칙("진실이 다룬다고 말하는 입력에서 거짓이 되면 gap")에 따라 경고다.
- **성공 기준 3 · 4 는 지금 상태로 성립한다:** 조각 넷에 `linter.rules` 가 0 (Ruby 파서). 배포 파일 전체에서 켜는 이 패키지의 규칙은 `lib/base.yaml` 의 81개뿐이고, 채택 목록과 같으며, 기반 세트와 겹치지 않는다. 깨지는 것은 저장소 관례(규칙은 `lib/base.yaml` 에만 — 03-REVIEW.md WR-01)를 벗어난 앞으로의 편집을 검사가 막지 못한다는 점이다.
- **처리:** 소유자 결정 2026-10-13 — Phase 5 의 VERIFY-06 과 함께, 처리 기록 deferred, ROADMAP Phase 5 Notes. `04-REVIEW-DISPOSITION.md` 의 WR-11 이 frontmatter · 표 행 모두 `deferred` 이고 사유가 적혀 있다. 고치는 비용은 작다 — 리뷰의 Fix(`rulesFile` 밖 조각에 `declaredRuleNames` 를 돌려 비어 있지 않으면 실패)와, 같은 파서를 쓰므로 따옴표 · 읽지 못하는 줄 처리도 같다. Phase 5 의 VERIFY-06 이 D-11 (2) 의 방식을 이어 쓸 때 함께 닫는다 (ROADMAP Phase 5 Notes 의 불릿). 이 보고서의 판정은 경고 그대로다 — 어느 must-have 진실도 거짓으로 만들지 않으므로 frontmatter `deferred` (gap 을 미루는 목록)에는 넣지 않았다.

#### 2. IN-12 (04-13 소절의 "두 규칙은 샘플에 걸리지 않는다") — 정보

- **사실 확인:** `example/README.md` 307행 "… 정답지 단계가 통과한 까닭은 M20 · M26 과 같다 — 조각의 복사본은 기반 세트와 겹친 규칙을 경고하지 않고, 두 규칙은 샘플에 걸리지 않는다." 그런데 `example/expected_diagnostics.txt` 12행이 `lib/base_rules.dart:22  info  avoid_print` 다. 그래서 `avoid_print` 에 대해서는 틀린 문장이다. 정답지 단계가 통과한 실제 까닭은 같은 파일 258행(M20 읽는 법)대로, 기반 세트가 이미 켜서 진단이 달라지지 않기 때문이다.
- **판정:** M 기록의 실행 결과(종료 코드 · 실패 단계 · 출력)는 맞고, 04-13 진실 4 가 약속한 것은 그 결과다. 틀린 것은 까닭을 설명하는 종속절 하나다. DOCS-11 의 근거 문서(`RULES.md`)나 RULES-07 의 사유 주석(`lib/base.yaml`)이 아니라 검증 장치의 실험 기록이므로 목표의 기록 정확성(성공 기준 4 · 5)에 닿지 않는다. 한 문장을 고치면 된다 (리뷰의 Fix).

#### 3. IN-13 · IN-14 (`readRuleNameAt` 의 이름 누락, `FormatException` 문구에 파일 이름 없음) — 정보, 소유자 결정 존중

- **IN-13 재현 (복제본):**
  - `    - 'invariant_booleans'` → rc 1, `[2/10]` · `[3/10]` 실패. `[2/10]` 의 줄은 `build/woody_rule_check/base/analysis_options.yaml:106  warning  removed_lint` 로 이름이 없다.
  - 따옴표 없는 `- invariant_booleans` → 같은 rc 1 · 같은 단계 실패이고, 줄 끝에 `(invariant_booleans)` 가 붙는다.
  - 판정은 같고 출력만 다르다. `[3/10]` 은 `+ invariant_booleans  (base.yaml 에만)` 으로 이름을 보여 준다.
- **IN-14:** stderr 문구에 파일 이름이 없다 — 위 M29 ~ M31 의 출력 그대로다. 종료 코드 70 과 "106행을 읽지 못했다" 는 맞다. 지금 `lib/base.yaml` 에 `plugins:` 가 없어 복사본의 행 번호와 원본의 행 번호가 같다.
- **판정:** 04-13-PLAN 의 prohibition "`tool/verify.dart` 의 `readRuleNameAt` … 은 바이트 하나 바꾸지 않는다 (소유자 결정 2026-10-13 §1 의 NOT approved)" 가 있다. 그리고 둘 다 거짓 통과가 아니라 실패 출력의 꾸밈 문제다. 어느 진실도 거짓으로 만들지 않는다.

#### 4. 04-13-SUMMARY 의 주장 — 모두 맞음

위 "진실 6 판정" 의 표와 `<automated>` 재실행이 근거다.

- M27 · M28 은 rc 1 `[3/10]` 만, M29 ~ M31 은 rc 70 · stdout 0바이트 · `106행을 읽지 못했다`.
- 보통 실행 10/10.
- `--audit` `켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0`.
- `readRuleNameAt` 은 `c06d8d5` 와 같고, `tool/measure_rules.dart` 도 같다.
- IN-08 의 `RULES.md` 칸, IN-10 의 `example/README.md` 39행 문장, WR-09 메모(`.planning/REQUIREMENTS.md` 89행)와 `04-REVIEW-DISPOSITION.md` 의 WR-09 `deferred` (frontmatter · 표 133행)가 있다.
- 처리 기록의 `open:` 은 지금 18 이다. 04-13 Task 3 시점의 17 에서 재리뷰가 새 발견 넷(WR-11 · IN-12 ~ 14)을 더하고 고쳐진 둘(WR-10 · IN-08)을 뺀 19 에서, 소유자 결정으로 WR-11 이 `deferred` 가 되어 18 이다. Task 3 단언은 `8f4e257` 에서 rc 0 이었다.
- 04-12 진실이 적은 옛 실측 칸 `0 · 0 · 0 (pubspec.yaml 2줄)` 은 소유자가 승인한 IN-08 (04-13 진실 5) 로 바뀌었다. 상태를 고정한 옛 단언이 설계대로 HEAD 에서 맞지 않는 것이지 회귀가 아니다.

#### 5. 지난 보고서의 경고 · 사람 확인 항목 — 그대로

- **WR-09 · CR-03:** 코드는 그대로 해당한다 (`tool/measure_rules.dart` 가 `c06d8d5` 와 같다). 둘 다 소유자 `deferred` 다 — `.planning/REQUIREMENTS.md` RULES-13 아래 88행(CR-03) · 89행(WR-09) 메모, 처리 기록 frontmatter `disposition: deferred`. 커밋된 R1 값은 바뀌지 않아 지금의 수치 · 사유에는 영향이 없다 (지난 보고서의 판정이 그대로 성립한다).
- **사람 확인:** 지난 보고서도 없었고 이번에도 없다. PLAN 에 `<human-check>` 블록이 없다.

### 필요한 산출물

| 산출물 | 기대 | 상태 | 상세 |
|---|---|---|---|
| `lib/base.yaml` | 이 패키지가 더하는 규칙만, 사유 주석과 함께 | ✓ VERIFIED | 81개, 겹침 0, 주석 처리된 설정 0, 지난 검증 뒤 바뀌지 않음 |
| `lib/codegen.yaml` · `lib/riverpod.yaml` · `lib/recommended.yaml` · `lib/analysis_options.yaml` | 규칙 없음 | ✓ VERIFIED | `linter.rules` 0 (지킴 장치는 묶음 · 별칭에만 — WR-11 경고) |
| `RULES.md` | 켠 규칙 · 켜지 않은 규칙 · 실측 기록 | ✓ VERIFIED | 81 · 90행, 사유 81개 일치, 실측 구역 == `--report` |
| `tool/verify.dart` | `[3/10]` 이 따옴표 이름을 읽고 읽지 못하는 줄에서 70 | ✓ VERIFIED | 깨기 실험 9개 (위 표) |
| `tool/measure_rules.dart` | 측정 · 보고서 · 감사 · 재계산 | ✓ VERIFIED (경고 둘) | `c06d8d5` 와 같음. WR-09 · CR-03 은 다음 재측정에서만 |
| `tool/measurements/2026-10-13-R1.json` | R1 결과 | ✓ VERIFIED | 지난 검증과 같음, `--recount` 바뀐 행 없음 |
| `example/README.md` | 04-13 소절 M27 ~ M31, 종료 코드 70 행, IN-10 문장 | ✓ VERIFIED (정보 하나) | 실행 결과와 맞음. 307행 종속절은 IN-12 |
| `.planning/phases/04-rule-reselection/04-DECISIONS.md` | 후보 133 결정 | ✓ VERIFIED | `켬` 81 == 배포 81 |
| `CHANGELOG.md` | 2.0.0 추가한 규칙 · 새로 생기는 경고 | ✓ VERIFIED | 바뀌지 않음, 75줄 |
| `.planning/REQUIREMENTS.md` · `04-REVIEW-DISPOSITION.md` | WR-09 메모 · `deferred` | ✓ VERIFIED | 89행 · 133행 · frontmatter |

### 핵심 연결

| From | To | Via | 상태 | 상세 |
|---|---|---|---|---|
| `tool/verify.dart` `declaredRuleNames` | `lib/base.yaml` | `rulesKeyPattern` · `rulePattern` · `FormatException` | ✓ WIRED | 건너뛰는 분기 없음, M27 ~ M31 동작 |
| `checkShippedComposition` (b) · (c) | `RULES.md` 켠 규칙 표 · 기반 세트 YAML | `declaredRuleNames(baseText)` | ✓ WIRED | 따옴표 이름이 겹침 · 표 일치에 든다 (M27 · M28) |
| `main` | 종료 코드 70 | `on FormatException` → `파일 모양이 예상과 다르다: …` | ✓ WIRED | M29 ~ M31 rc 70 |
| `checkShippedComposition` (b) · (c) | `lib/codegen.yaml` · `lib/riverpod.yaml` | (없음) | ⚠ 범위 밖 | 어느 must-have 도 약속하지 않은 연결. WR-11 경고 |
| `tool/measure_rules.dart --report --write` · `--audit` | `RULES.md` | 생성 · 감사 | ✓ WIRED | `diff` 0, 감사 rc 0 |
| `04-DECISIONS.md` 결정 | `lib/base.yaml` | 반영 | ✓ WIRED | 81 == 81 |

### 데이터 흐름 (Level 4)

| 산출물 | 값 | 출처 | 실데이터 | 상태 |
|---|---|---|---|---|
| `RULES.md` 평가표 | 133행 건수 | R1 JSON `rows` | 예 | ✓ FLOWING (`--report` == 구역) |
| `RULES.md` 켠 규칙 표 `sort_pub_dependencies` | `2 (pubspec.yaml 2 — …)` | R1 행 `counts["pubspec.yaml"]` 2 | 예 | ✓ FLOWING |
| CHANGELOG 경고 표 | 75행 | R1 JSON | 예 | ✓ FLOWING (바뀌지 않음) |

### 동작 확인

| 동작 | 명령 | 결과 | 상태 |
|---|---|---|---|
| HEAD 검증 | `fvm dart run tool/verify.dart` (깨끗한 복제본) | rc 0, 10개 중 10개, 73초 | ✓ PASS |
| 루트 분석 · 포맷 | `fvm dart analyze` · `fvm dart format --output=none --set-exit-if-changed tool` | `No issues found!` · rc 0 | ✓ PASS |
| 감사 | `--audit` | rc 0, 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0 | ✓ PASS |
| 재계산 | `--recount --in …` | rc 0, 133행 바뀐 행 없음 | ✓ PASS |
| 보고서 재생성 | `--report --in …` 과 `RULES.md` 구역 `diff` | rc 0, 0줄 | ✓ PASS |
| 따옴표 이름 (M27 · M28) | 106행에 한 줄 | rc 1, `[3/10]` 만 | ✓ PASS |
| 읽지 못하는 줄 (M29 ~ M31 + 짝 다른 따옴표 · 이름 뒤 다른 말) | 106행에 한 줄 | rc 70, stdout 0바이트 | ✓ PASS |
| 열 0 주석 (M26) | 회귀 확인 | rc 1, `[3/10]` 만 | ✓ PASS |
| 블록 키를 따옴표로 | `"linter":` | rc 1, `[2/10]` · `[3/10]` | ✓ PASS |
| 묶음에 규칙 (M23 꼴) | `lib/recommended.yaml` 끝에 `linter: rules: - prefer_mixin` | rc 1, `[3/10]` | ✓ PASS |
| 조각에 규칙 (WR-11) | `lib/codegen.yaml` · `lib/riverpod.yaml` 끝에 `linter: rules:` | rc 0 · rc 0 | ⚠ 경고 (must-have 범위 밖) |
| 조각 규칙이 사용 프로젝트에 간다 | `lib/codegen.yaml` 에 `- avoid_positional_boolean_parameters` | `[5/10]` · `[9/10]` · `[10/10]` 실패 rc 1 | 정보 (WR-11 의 영향 확인) |
| 04-13 `<automated>` | Task 1 @`67d1bc7` · 2 @`76dee2f` · 3 @`8f4e257` | rc 0 · 0 · 0 | ✓ PASS |

### Probe 실행

Step 7c: 해당 없음 — 이 phase 는 `scripts/*/tests/probe-*.sh` 를 선언하지 않는다. 확인 장치는 `tool/verify.dart` 와 `tool/measure_rules.dart` 의 출력 모드이고, 위 "동작 확인" 에서 검증자가 직접 돌렸다.

### 요구사항 범위

| 요구사항 | Plan | 설명 | 상태 | 근거 |
|---|---|---|---|---|
| RULES-01 | 04-01, 04-10, 04-11, 04-13 | 기반 세트 중복 선언 삭제 | ✓ SATISFIED | 102개 기반 세트와 교집합 0 (독립 파서), `[3/10]` (b) 가 따옴표 이름까지 막는다 |
| RULES-02 | 04-01 | 주석 처리된 설정 3개 삭제 | ✓ SATISFIED | `lib/*.yaml` 다섯에 0건 |
| RULES-03 | 04-02 ~ 04-04, 04-09, 04-11, 04-12 | 후보마다 실측 건수 · `dart fix` 건수 표 | ✓ SATISFIED | 133행 평가표 == `--report`; `sort_pub_dependencies` 의 `dart fix` 는 `재지 않음` (상한 2, 지난 보고서) |
| RULES-04 | 04-02 ~ 04-04 | strict 계열이 같은 표에 | ✓ SATISFIED | 세 행 그대로 (R1 · `RULES.md` 바뀌지 않은 구역) |
| RULES-05 | 04-02 ~ 04-04, 04-11 | 회차 조건 기록 · 유효 회차만 | ✓ SATISFIED | R1 바이트 불변, `--recount` 바뀐 행 없음 |
| RULES-06 | 04-01, 04-05 ~ 04-08, 04-10 ~ 04-13 | 소유자 결정이 배포 파일에 반영 | ✓ SATISFIED | `켬` 81 == 배포 81, `[3/10]` (c) 가 따옴표 이름까지 견준다 |
| RULES-07 | 04-06, 04-09, 04-12 | 남기는 규칙의 사유 주석이 사실 | ✓ SATISFIED | 사유 81개 == `RULES.md` 켠 이유, 샘플 · 정답지 불변 |
| RULES-08 | 04-03, 04-07 ~ 04-09, 04-11, 04-12 | 미채택 규칙과 사유 목록 | ✓ SATISFIED | 켜지 않은 규칙 90행, 감사 통과 |
| DOCS-11 | 04-03, 04-06 ~ 04-09, 04-12, 04-13 | 켠 규칙마다 이유와 실측 건수 | ✓ SATISFIED | 81행 모두 이유 · 건수 · 회차, `sort_pub_dependencies` 칸은 합계가 앞 |

아홉 개 모두 증거로 충족이다. REQUIREMENTS.md 추적 표에서 RULES-02 ~ 05 · 07 · 08 이 `Gaps Found` 인 것은 지난 `gaps_found` 때 도구가 Phase 4 ID 를 되돌렸기 때문이다. 이 보고서는 REQUIREMENTS.md 를 고치지 않았다 — 표시를 Complete 로 돌리는 것은 orchestrator 의 일이다. REQUIREMENTS.md 가 Phase 4 에 둔 ID 는 위 9개이고, 모두 어느 plan 의 `requirements` 에 있다. 고아 요구사항은 없다.

### 발견한 안티 패턴

| 파일 | 행 | 패턴 | 심각도 | 영향 |
|---|---|---|---|---|
| `tool/verify.dart` | 1369 ~ 1382, 1420 ~ 1424 | (b) · (c) 가 `rulesFile` 하나만 읽음 — 조각의 규칙을 보지 않음 (WR-11) | ⚠️ Warning (deferred — Phase 5 VERIFY-06) | 관례를 벗어난 앞으로의 편집에서만. 지금 조각에 규칙 0 |
| `tool/measure_rules.dart` | 4985 ~ 4997 외 | `fixSkipped` 를 원인 확인 없이 적음 (WR-09) | ⚠️ Warning (deferred) | 다음 재측정의 망가진 입력에서만 |
| `tool/measure_rules.dart` | 273 ~ 280 외 | `currentRules` 가 1.3.0 의 6개 (CR-03) | ⚠️ Warning (deferred) | 다음 재측정에서만 |
| `example/README.md` | 307 | `avoid_print` 에 맞지 않는 까닭 종속절 (IN-12) | ℹ️ Info | 실험 기록의 설명 한 줄 |
| `tool/verify.dart` | 857 ~ 865, 912 ~ 916 | 두 파서가 따옴표 줄을 다르게 읽음 · 예외 문구에 파일 이름 없음 (IN-13 · IN-14) | ℹ️ Info | 출력만. 소유자가 `readRuleNameAt` 을 고치지 않기로 함 |

지난 검증 뒤 바뀐 파일 셋(`tool/verify.dart` · `example/README.md` · `RULES.md`)에 `TBD` · `FIXME` · `XXX` 0, 더한 줄의 절대 경로 꼴 0 (`.planning/` 포함).

Step 7 의 재검증 증거 기준: carried-forward gap(진실 6)은 결정적 재현으로 닫혔다. WR-11 은 새 범위이고 rc 0 재현이 있지만 어느 must-have 진실도 거짓으로 만들지 않아 경고다. IN-12 ~ 14 는 출력 · 설명 문구라 정보다.

### 경고 (gap 아님)

- **WR-11** — 위 "주장 판정 1". 소유자 결정 2026-10-13 — Phase 5 의 VERIFY-06 과 함께, 처리 기록 deferred, ROADMAP Phase 5 Notes. 고칠 때 `example/README.md` 에 `lib/codegen.yaml` 입력의 M 기록을 더하는 것이 이 저장소의 관례다.
- **WR-09 · CR-03** — 소유자 `deferred`, RULES-13 메모. 다음 재측정(v2) 전에 고칠 것.
- **WR-01 · WR-03 · WR-04 · WR-07 · WR-08** — 리뷰 지적 그대로 `open`. 측정 도구의 안전장치에 관한 것이고 `tool/measure_rules.dart` 는 바뀌지 않았다. 지금 커밋된 값과는 관계없다 (지난 보고서의 WR-01 판정 그대로).
- **push 하지 않은 커밋 36개** — CI 는 `0db0fdd` 까지만 봤다. 같은 10단계가 깨끗한 복제본에서 통과한다. 릴리스 전 push 때 CI 결과를 다시 볼 것 (Phase 5 부터 push 는 소유자에게 묻는다 — D-22).

### Advisory (새 범위, 증거 없음)

없음 — 이번에 새로 본 지적(WR-11 · IN-12 · IN-13 · IN-14)은 모두 복제본에서 재현하거나 파일로 확인했다.

### 사람 확인 필요

없음.

### Gap 요약

지난 gap 하나(진실 6, WR-10)가 닫혔다. `declaredRuleNames` 는 `lib/base.yaml` 의 `linter:` 블록 안에서 받는 꼴 둘 말고는 모두 멈춘다. 받는 꼴은 들여쓴 `rules:` 와, 따옴표 없음 · 홑 · 겹 따옴표 목록 항목 + 선택적 `# 주석` 이다. 따옴표 이름은 겹침 · `RULES.md` 일치 검사에 들어간다. 계획이 적은 다섯 입력과 검증자가 더한 넷이 모두 거짓 통과 없이 rc 1 또는 70 이다. 성공 기준 1 ~ 5 는 지금 상태로 성립하고, 지난 검증 뒤로 배포 파일 · 실측 · 결정 · CHANGELOG · 샘플은 바뀌지 않았다.

재리뷰의 새 Warning WR-11 은 사실이다 (조각 `lib/codegen.yaml` · `lib/riverpod.yaml` 에 규칙을 적으면 rc 0). 그러나 must-have 와 D-11 은 모두 `lib/base.yaml` 을 이름으로 적고, 조각을 지키겠다는 진실은 없다. 지금 조각에는 규칙이 없다. 그래서 phase 목표를 깨지 않는 경고로 두었다. 처리는 소유자 결정 2026-10-13 — Phase 5 의 VERIFY-06 과 함께, 처리 기록 deferred, ROADMAP Phase 5 Notes.

**다음 phase 가 알아야 할 것:**

- WR-11 은 Phase 5 의 VERIFY-06 과 함께 닫는다 (소유자 결정 2026-10-13 — Phase 5 의 VERIFY-06 과 함께, 처리 기록 deferred, ROADMAP Phase 5 Notes). VERIFY-06 이 D-11 (2) 의 비교를 README 로 넓힐 때 비교 대상 규칙 목록을 `lib/base.yaml` 하나로 잡으면 같은 빈자리가 README 쪽에도 생긴다. 배포 YAML 다섯 전체에서 규칙을 모으거나, `lib/base.yaml` 밖 조각에 규칙이 없음을 먼저 확인한다.
- `declaredRuleNames` 가 예외를 던질 수 있게 되었다. 조각 파일에 이 함수를 돌리면 rc 70 경로를 탄다. 그 문구에는 파일 이름이 없다 (IN-14). `rulesFile` 을 바꾸거나 다른 파일에 쓸 때는 문구에 파일 이름을 넣을 것.

---

_검증: 2026-10-13T13:20:36Z_
_검증자: Claude (gsd-verifier)_
