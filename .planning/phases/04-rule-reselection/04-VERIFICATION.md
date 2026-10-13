---
phase: 04-rule-reselection
verified: 2026-10-13T09:20:48Z
status: gaps_found
score: 10/11 must-haves verified
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
  - .planning/phases/04-rule-reselection/04-DECISIONS.md
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
  - lib/base.yaml
  - tool/measure_rules.dart
  - tool/measurements/2026-10-13-R1.json
  - tool/verify.dart
covered_digest: "v3:sha256:8508e213a7b4eb9d554cf5f67398f6e417c068e61fed69ee558ff19f0c1a6e26"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 8/11
  gaps_closed:
    - "gap 1 — 소유자가 후보 규칙마다 실측 진단 건수를 표 하나에서 볼 수 있고(성공 기준 1), 켜지 않은 규칙의 사유가 사실로 기록되어 있다(성공 기준 5) — `sort_pub_dependencies` 행 (missing 셋 모두 닫힘)"
    - "gap 2 의 missing 두 항목 — 열 0 주석이 `linter:` 블록을 닫지 않는다(CR-02), `example/README.md` M26 기록"
  gaps_remaining:
    - "진실 6 (04-01 must-have, D-11) — 같은 진실이 다른 입력(따옴표로 감싼 규칙 이름, 04-REVIEW.md WR-10)으로 다시 거짓 통과한다"
  regressions: []
gaps:
  - truth: "기반 세트가 켜는 규칙이나 `RULES.md` 에 없는 규칙을 `lib/base.yaml` 에 더하면 `[3/10] 배포 파일의 구성` 이 실패한다 (04-01 must-have, D-11)"
    status: partial
    reason: "CR-02 입력(열 0 주석 뒤에 더함)은 이제 `[3/10]` 만 실패한다(rc 1). 그러나 `no_raw_types` 뒤에 `    - 'avoid_print' # 기반 세트와 겹침 (따옴표)` 한 줄을 더하면 검증 전체가 `점검 통과 (10개 중 10개)` rc 0 이다. YAML 에서 `'avoid_print'` 는 `avoid_print` 와 같은 문자열이고 analyzer 는 그 규칙을 켠다. `declaredRuleNames` 의 `rulePattern` (`^\\s*-\\s*([A-Za-z0-9_]+)`)이 따옴표에서 맞지 않아 그 줄을 조용히 건너뛰므로 겹침 검사(b)와 `RULES.md` 일치 검사(c)가 보지 못한다. 지금의 배포 YAML 다섯에는 따옴표로 감싼 규칙 이름이 없어 지금 판정(81개, 겹침 0, 표 일치)은 맞다 — CR-02 와 같은 범위의 구멍이다."
    artifacts:
      - path: "tool/verify.dart"
        issue: "`declaredRuleNames` (879 ~ 899행) — `linter:` 블록 안의 `- ` 줄에서 이름을 읽지 못하면 실패하지 않고 건너뛴다; `rulePattern` 이 따옴표 이름을 받지 않는다"
    missing:
      - "`rulePattern` 이 `'이름'` · `\"이름\"` 을 받게 하고, `linter:` 블록 안의 `- ` 줄인데 이름을 읽지 못하면 `FormatException` 으로 실패한다 (조용히 건너뛰지 않는다 — 다른 입력 꼴에도 닫힌다)"
      - "`example/README.md` 의 M 기록에 따옴표 입력(겹치는 `'avoid_print'`)에서 `[3/10]` 만 실패하는 것을 더한다"
---

# Phase 4: Rule Reselection 재검증 보고서

**Phase 목표:** 배포 파일의 규칙 하나하나가 `flutter_starter_kit` 실측을 본 소유자의 결정으로 켜져 있고, 켠 이유와 켜지 않은 이유가 기록으로 남아 있다
**검증 시각:** 2026-10-13T09:20:48Z
**상태:** gaps_found
**재검증:** 예 — gap 수정 plan 04-11 · 04-12 뒤 (HEAD `e89ad75`)

검증은 모두 검증자 임시 폴더(scratchpad 아래 `verifier-` 로 시작하는 폴더)에 `git clone --local` 로 만든 복제본에서 했다. 복제본마다 루트 `fvm dart pub get` 을 먼저 했다. 작업 트리는 바꾸지 않았다 — 검증 전후 저장소의 `git status --porcelain` 은 시작할 때의 넷(`.planning/config.json` 수정, 추적하지 않는 `.planning/state.json` · `.planning/milestone.lock` · `.planning/research/.cache/`)에 이 파일 하나가 더해질 뿐이다. 측정 도구의 `--stage` 는 돌리지 않았고, 비공개 사용 프로젝트는 건드리지 않았다. 판정은 커밋된 `tool/measurements/2026-10-13-R1.json` 과 출력 모드(`--audit` · `--recount` · `--report` · `--summary`)로 했다.

## 목표 달성

### 관찰 가능한 진실

| # | 진실 | 상태 | 근거 |
|---|------|------|------|
| 1 | (성공 기준 1) 후보 규칙마다 실측 진단 건수와 `dart fix` 건수를 표 하나에서 본다 — strict 계열 포함 | ✓ VERIFIED (지난 gap 1 닫힘) | 평가표 133행. `sort_pub_dependencies` 행이 `2 (0·0·0·2)` · `재지 않음` (`RULES.md` 376행), 각주 418행이 재지 않은 까닭을 적는다. strict 셋: `no_dynamic_casts` info `0 (표식 1)`, `no_raw_types` info `0 (표식 1)`, `strict-inference` warning `106 (0·106·0·0)` · `0 (dry 0)`. `dart fix` 칸이 수가 아닌 행은 이 한 행뿐이고, 재지 않은 값을 지어내지 않았다(아래 "gap 1 판정") |
| 2 | (성공 기준 2) 수치마다 회차를 따라갈 수 있고, 회차에 SDK · 기반 세트 · plugin 버전이 있으며, 무효 회차의 수치는 쓰이지 않았다 | ✓ VERIFIED | R1 JSON 회차 52개 모두 `valid: true` · `expectedCovered: true`, 조건 필드(dart · flutter · baseSet · plugin · languageVersion · sdkConstraint · dartFiles · date) 빠진 회차 0. 행이 참조한 회차가 없거나 무효인 행 0, 행이 참조한 G 회차의 `options` 에 그 규칙이 없는 행 0. 04-11 앞(`b567100^`)과 지금의 `runs` 가 같다(파이썬 비교 `True`). 재계산 이력은 `conditions.recount = {date: 2026-10-13, changedRows: [sort_pub_dependencies]}` |
| 3 | (성공 기준 3) 후보마다 소유자의 채택 / 미채택 결정이 기록되어 있고, 배포 파일의 켠 규칙이 채택 목록과 같다 | ✓ VERIFIED | `04-DECISIONS.md` 결정 표 133행: `켬` 81 · `안 켬` 38 · v2 12 · `결정 안 함 (표식 불가)` 2 (`require_trailing_commas` · `package_prefixed_library_names`, D-02 설계대로). `켬` 81개 == Ruby YAML 파서로 읽은 `lib/base.yaml` 규칙 81개 (차집합 0, 중복 0). `sort_pub_dependencies` 는 882행에 `켬` 과 재결정 사유 · 첫 결정 이력을 같은 행에 적었다 |
| 4 | (성공 기준 4) 배포 파일에 기반 세트 겹침과 주석 처리된 설정 3개가 없고, 사유 주석이 사실과 맞다 | ✓ VERIFIED | `lints` 6.1.0 core · recommended 와 `flutter_lints` 6.0.0 flutter (102개)와 `lib/base.yaml` 81개의 교집합 0. `lib/*.yaml` 에 `require_trailing_commas` · `public_member_api_docs` · `formatter` 0건 (grep rc 1). 새 사유 주석(`sort_pub_dependencies` — `pubspec.yaml` 의 dependencies 를 이름 순으로)은 정답지 다섯의 `pubspec.yaml:11  info  sort_pub_dependencies` 와, `example/pubspec.yaml` 을 되돌리면 그 줄이 사라지는 실험(아래 동작 확인)으로 사실이다 |
| 5 | (성공 기준 5) 켠 규칙마다 이유와 실측 건수의 근거 문서, 켜지 않은 규칙과 그 사유의 목록이 있다 | ✓ VERIFIED (지난 gap 1 닫힘) | `RULES.md` 켠 규칙 81행(사유 81개가 `lib/base.yaml` 주석과 글자 그대로 같음) · 켜지 않은 규칙 90행, 두 표에 겹친 이름 0, 후보 133개 모두 두 표 가운데 하나에 있다. 틀린 근거 "실제 프로젝트 0줄" 은 `sort_pub_dependencies` 의 결정 근거로는 저장소 어디에도 남지 않았다(`git grep` — 남은 곳은 `use_test_throws_matchers` 의 사유와 계획 문서뿐이고, 그 행의 값은 네 자리 모두 0 이라 사실이다). `--audit` rc 0 `켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0` |
| 6 | (04-01) 기반 세트 규칙이나 `RULES.md` 에 없는 규칙을 `lib/base.yaml` 에 더하면 `[3/10]` 이 실패한다 | ✗ FAILED (partial) | CR-02 입력(열 0 주석 + `avoid_print` + `prefer_mixin`): `[3/10]` 만 실패, 겹침 `avoid_print (flutter_lints-6.0.0 flutter.yaml)` · `+ avoid_print` · `+ prefer_mixin`, rc 1 — 닫힘. 그러나 따옴표 입력 `- 'avoid_print'`: `점검 통과 (10개 중 10개)` rc 0 — WR-10 재현 (아래 "WR-10 판정") |
| 7 | (04-02 · 04-04) 측정 도구가 회차 조건을 기록하고 저장소 밖에서만 돌며, 결과에 사용 프로젝트의 경로 · 메시지가 없다 | ✓ VERIFIED (회귀 확인) | `--stage` 는 지시대로 돌리지 않았다. R1 JSON 의 `/` 가 든 문자열 238개가 모두 `lib/woody_probe_marker/` 표식 줄이다. 04-11 은 회차를 다시 재지 않았다 — `runs` 가 R1 커밋 `e3651ec` 의 50회차와 바이트 단위로 같고(뒤에 더한 것은 04-08 의 UI · UI-base 뿐) |
| 8 | (04-03 · 04-09) `RULES.md` 실측 기록이 `--report` 출력과 같고, `--audit` 이 통과한다 | ✓ VERIFIED | 복제본에서 `--report --in tool/measurements/2026-10-13-R1.json` rc 0, 출력 206줄이 `RULES.md` 의 `woody:measurements` 마커 사이(219 ~ 424행)와 `diff` 0줄. `--recount --in …` → `다시 센 행 133개 — 바뀐 행이 없다` rc 0. `--audit` rc 0 |
| 9 | (04-06 ~ 04-08, 04-12) 결정이 배포 파일에 반영되고, 새로 켠 규칙은 정답지에 줄이 있으며 검증이 통과한다 | ✓ VERIFIED | 깨끗한 복제본 `fvm dart run tool/verify.dart` rc 0, `점검 통과 (10개 중 10개)` (72초). 루트 `fvm dart analyze` → `No issues found!`. 헛통과 아님: `example/pubspec.yaml` 만 `548e3e1` 판으로 되돌리면 `[5/10]` · `[6/10]` 실패 rc 1; `lib/base.yaml` 에서 `sort_pub_dependencies` 줄만 지우면 `[3/10]` (`- sort_pub_dependencies (RULES.md 에만)`) · `[5/10]` · `[7/10]` ~ `[10/10]` 실패 rc 1 |
| 10 | (04-09 · 04-12) CHANGELOG `### 추가한 규칙` · `### 새로 생기는 경고` 가 새로 켠 규칙과 실측에 맞다 | ✓ VERIFIED | `### 추가한 규칙` 75줄 == `lib/base.yaml` 81 − 1.3.0 에서 남은 6 (사유 문장 75개 모두 `lib/base.yaml` 과 같다). `### 새로 생기는 경고` 75행, 이름 집합이 같고 건수(네 자리 합) · 강도가 R1 JSON 과 75행 모두 같다. `sort_pub_dependencies | info | 2건 | 재지 않음` 과 185행 각주. `## 1.3.0` 아래는 그대로 |
| 11 | (04-10 · 제약) 브랜치가 push 되어 CI 가 통과했고, `main` 은 1.3.0 그대로다 | ✓ VERIFIED (04-10 시점) | `origin/main` = `90a2736`, `pubspec.yaml` `version: 1.3.0`. 마지막 CI `38351171683` completed · success (head `0db0fdd`). gap 수정 커밋 24개는 아직 push 되지 않아 CI 가 보지 않았다 — 같은 10단계를 깨끗한 복제본에서 돌려 통과(진실 9). 정보로만 적는다 |

**점수:** 11개 중 10개 verified (present, behavior-unverified 0)

진실 6 · 9 는 동작을 주장하는 진실이라 grep 이 아니라 깨기 실험으로 판정했다 (아래 "동작 확인").

### gap 1 판정 (`sort_pub_dependencies`, CR-01) — 닫힘

지난 보고서의 `missing` 셋을 하나씩 봤다.

1. **측정 도구가 `pubspec.yaml` 자리를 값에 넣거나, 넣지 않으면 `--report` 가 실패한다 — 닫힘.** `tool/measure_rules.dart` 1734행 `const valueAreas = ['lib', 'test', 'bin', pubspecArea];`. R1 행 `counts = {lib 0, test 0, bin 0, pubspec.yaml 2}`. 04-11 앞의 JSON 과 견주면 133행 모두 `counts` · `ignored` (· `counts313` 7행)에 `pubspec.yaml` 키가 더해졌을 뿐이고, 그 키를 빼면 값이 바뀐 행은 0 이다. 값이 바뀐 것은 `sort_pub_dependencies` 하나다. 되돌림 실험: 복제본에서 `valueAreas` 를 `['lib', 'test', 'bin']` 으로 되돌리고 `--report` 를 돌리면 rc 1 `값에 넣지 않은 자리에 진단이 있는 행 1개: sort_pub_dependencies (pubspec.yaml)` (단언 (7)). 고친 도구에 `pubspec.yaml` 값을 지운 JSON 을 주면 `--recount` 가 `sort_pub_dependencies: counts 0·0·0·0 → 0·0·0·2` 를 찍는다.
   - 덧붙임: `valueAreas` 를 되돌린 도구의 `--recount` 는 `바뀐 행이 없다` 를 찍었다 (행의 `pubspec.yaml` 키를 견주지 않는 것으로 보인다). 같은 회귀를 단언 (7) 이 잡으므로 결론은 바뀌지 않는다.
2. **`RULES.md` 실측 기록을 다시 만든다 — 닫힘.** 위 진실 8.
3. **소유자에게 실측(2줄)을 보이고 다시 묻고, 결정과 문서를 맞춘다 — 닫힘.** `04-DECISIONS.md` 882행(결정 표: `켬`, 재결정 사유, 첫 결정 `안 켬` 과 그 근거가 사실이 아니었다는 이력)과 933행(표 밖 메모: 묶음 3 패널의 `0 (표식 불가)` 가 틀린 값이었다는 설명, 고친 도구의 판정 `켬 (손으로 고칠 줄 2 ≤ 50)`). `--summary style` 의 실제 출력도 `sort_pub_dependencies | 2 (0·0·0·2) | 재지 않음 | — | 켬 | 손으로 고칠 줄 2 (≤ 50) — dart fix 는 재지 않음` 이다. `lib/base.yaml` 59행 · `RULES.md` 켠 규칙 표 49행 · CHANGELOG 70 · 163 · 185행이 그 결정대로다. 소유자가 실제로 그렇게 답했다는 것은 이 기록으로만 확인된다 (검증자는 대화를 볼 수 없다).
   - 245행의 묶음 3 패널은 그때 소유자에게 보인 표 그대로 `0 (표식 불가)` 를 담고 있다. 같은 문서 933행이 그 값이 틀렸다고 적으므로 기록으로서는 따라갈 수 있다 (정보).

`dart fix` 칸: `sort_pub_dependencies` 는 R1 의 fix 단계가 이 규칙의 값을 0 으로 본 채 돌아 단독 dry 도 apply 도 하지 않았다. 04-11 앞의 JSON 에서 값이 0 보다 큰 56행은 모두 `aloneDry` 가 있고, `sort_pub_dependencies` 는 값 0 · `aloneDry` null · `apply-sort_pub_dependencies` 회차 없음이다 — 각주의 문장은 사실이다. 비공개 프로젝트를 다시 재지 않는다는 D-07 아래에서 수를 지어내지 않고 `재지 않음` 과 가장 나쁜 경우(손으로 2곳)를 적었고, 소유자는 그것을 보고 정했다. 성공 기준 1 의 "`dart fix` 로 고칠 수 있는 건수" 가 이 한 행에서는 수가 아니라 상한(0 ~ 2)으로만 보인다는 점은 기록해 둔다.

### gap 2 판정 (`[3/10]` 열 0 주석, CR-02) — missing 은 닫힘, 진실은 partial 로 남음

- **missing 1 (주석 · 빈 줄이 블록을 닫지 않는다) — 닫힘.** `tool/verify.dart` 884 ~ 886행. 복제본에서 M26 입력(마지막 규칙 뒤 열 0 주석 `# 실험 중 (열 0 주석)` + `    - avoid_print # 기반 세트와 겹침` + `    - prefer_mixin # RULES.md 켠 규칙 표에 없음`) → `[3/10]` 만 실패, 겹침 1 · `+ avoid_print` · `+ prefer_mixin`, `점검 실패 (10개 중 1개)` rc 1.
- **missing 2 (README M 기록) — 닫힘.** `example/README.md` 278행 M26.
- **진실 6 자체 — partial.** 아래 WR-10.

### WR-10 판정 (`[3/10]` 이 따옴표 규칙 이름을 읽지 못함) — gap (진실 6, partial)

- **재현:** 복제본에서 `no_raw_types` 줄 뒤에 `    - 'avoid_print' # 기반 세트와 겹침 (따옴표)` 한 줄 → `[1/10]` ~ `[10/10]` 모두 통과, `점검 통과 (10개 중 10개)` rc 0. `avoid_print` 는 기반 세트가 이미 켜므로 정답지 단계도 차이를 보지 못한다. `declaredRuleNames` 의 `rulePattern` 은 따옴표에서 맞지 않아 그 줄을 조용히 버린다.
- **지금 저장소가 그 꼴을 쓰는가:** 쓰지 않는다. `lib/*.yaml` 다섯에서 `^\s*-\s*['"]` 에 맞는 줄은 `lib/codegen.yaml` 5 · 6행의 `analyzer.exclude` glob 둘뿐이고, `linter:` 블록을 가진 파일은 `lib/base.yaml` 하나다 (Ruby 파서: 규칙 81개, 나머지 넷은 `linter.rules` 없음). 지금 판정(81개, 겹침 0, 표 일치)은 독립 파서로도 맞다.
- **범위:** 지난 보고서가 CR-02 를 잡은 범위와 같다. 성공 기준 3 · 4 는 지금 상태로 성립한다(진실 3 · 4). 깨지는 것은 04-01 must-have 의 일반 명제("더하면 `[3/10]` 이 실패한다")와 D-11 이 막으려던 앞으로의 어긋남이다. CR-02 도 "지금 저장소가 쓰지 않는 입력 꼴(블록 안 열 0 주석)" 에서만 열리는 구멍이었고 지난 보고서는 그것을 gap (partial)로 적었다. 같은 잣대로 WR-10 도 gap (partial)이다.
- **판정 규칙 (WR-09 와 가르는 기준):** 명시된 must-have 진실이나 성공 기준이 그 진실이 다룬다고 말하는 입력에서 거짓이 되면 gap 이다. 진실 6 은 "규칙을 더하면" 이라는 일반 명제이고, `- 'avoid_print'` 는 analyzer 가 규칙을 켜는 올바른 YAML 이다.
- **닫는 비용:** 작다. 리뷰가 낸 수정(따옴표를 받고, 블록 안의 `- ` 줄에서 이름을 읽지 못하면 실패)은 따옴표만이 아니라 "읽지 못한 목록 줄을 조용히 건너뛴다" 는 결함 꼴 자체를 막는다.
- **소유자가 범위 밖으로 볼 경우:** 프로젝트 관례(`.claude/CLAUDE.md` — "목록 형식(`- rule`)을 유지한다")가 따옴표 없는 이름이므로 이 입력을 범위 밖으로 볼 근거는 있다. 그렇게 정하면 아래 override 를 frontmatter 에 더한다.

```yaml
overrides:
  - must_have: "기반 세트가 켜는 규칙이나 RULES.md 에 없는 규칙을 lib/base.yaml 에 더하면 [3/10] 배포 파일의 구성 이 실패한다 (04-01 must-have, D-11)"
    reason: "따옴표로 감싼 규칙 이름은 저장소 관례(따옴표 없는 목록 형식) 밖의 입력이고 지금 배포 YAML 에 없다 — WR-10 은 열린 리뷰 지적으로 추적한다"
    accepted_by: "{소유자}"
    accepted_at: "{ISO timestamp}"
```

### WR-09 판정 (`--recount` 의 `fixSkipped`) — 경고 (gap 아님)

- **재현:** 복제본에서 R1 JSON 의 `directives_ordering` 에서 `aloneDry` · `fixRemoved` · `newErrors` 와 `apply-directives_ordering` 회차(행의 `runs` 참조 포함)를 지운 사본을 만들었다 (fix 단계가 중간에 죽은 꼴). `--report` → rc 1 `값이 없는 행 1개: directives_ordering (빠진 칸: fixRemoved 1 · newErrors 1)`. `--recount --write` → `directives_ordering: counts 3·163·0·0 → 3·163·0·0 · fixSkipped 적음`. 다시 `--report` → rc 0, 평가표 `166 (3·163·0·0) | … | 재지 않음`, 각주에 "R1 의 fix 단계는 이 규칙의 값이 0 으로 집계된 채 돌아 …" (그 사본에서는 사실이 아님). `--summary style` 권고가 `안 켬 | 손으로 고칠 줄 166 (> 50)` 으로 뒤집힌다. 리뷰의 주장대로다.
- **지금 `RULES.md` · CHANGELOG 의 수치나 사유가 틀리게 되는가:** 아니다. 커밋된 R1 에서 `fixSkipped` 가 붙은 행은 `sort_pub_dependencies` 하나이고, 그 문장은 사실이다(위 gap 1 판정의 `dart fix` 칸). `--summary style` 의 실제 출력에서 `directives_ordering` 은 `166 | 166 | 0 | 켬 | 손으로 고칠 줄 0` 이다.
- **범위:** 앞으로 망가진 입력(WR-08 꼴로 fix 단계가 죽은 결과)에 `--recount --write` 를 돌릴 때만 열린다. 04-11 의 must-have 는 `fixSkipped` 를 R1 의 그 행에 대해서만 말하고, "원인을 확인한 뒤에만 적는다" 는 일반 명제를 세우지 않았다. 그래서 진실이 거짓이 되지 않으며 경고로 둔다. 다음 재측정(v2 · RULES-13, CR-03 과 같은 때) 전에 고치는 것이 맞다.

### CR-03 판정 (재측정 시 0줄) — 경고, 소유자 `deferred`

- **메모:** 있다. `.planning/REQUIREMENTS.md` 88행, RULES-13 아래 "재측정 전에 먼저 고칠 것: … `currentRules` … 기준선을 어떻게 잡을지 설계부터 정한다 (04-REVIEW.md CR-03; 소유자 결정 2026-10-13 …)". `04-REVIEW-DISPOSITION.md` 의 CR-03 행이 `deferred` 와 사유다.
- **코드:** 그대로 해당한다. `tool/measure_rules.dart` 273행 `const currentRules = [` (1.3.0 의 6개).
- **지금 커밋된 R1 값:** 영향 없다. R1 의 50회차는 `e3651ec` 의 것과 바이트 단위로 같고, 그 커밋에서 `lib/base.yaml` 의 규칙은 6개였다. 뒤에 더한 UI · UI-base 회차에서 쓰는 값은 `unnecessary_ignore` 의 `countsUI` 뿐이다 (지난 보고서와 같은 결론, 이번에 다시 확인).

### 필요한 산출물

| 산출물 | 기대 | 상태 | 상세 |
|---|---|---|---|
| `lib/base.yaml` | 이 패키지가 더하는 규칙만, 사유 주석과 함께 | ✓ VERIFIED | 81개, 겹침 0, 주석 처리된 설정 0, 따옴표 이름 0 |
| `RULES.md` | 켠 규칙 · 켜지 않은 규칙 · 실측 기록 | ✓ VERIFIED | 81 · 90행, 실측 구역 == `--report` |
| `tool/verify.dart` | `[3/10] 배포 파일의 구성` | ⚠ 구멍 (gap) | 열 0 주석은 닫힘, 따옴표 이름을 보지 못함 |
| `tool/measure_rules.dart` | 측정 · 요약 · 보고서 · 감사 · 재계산 | ✓ VERIFIED (경고 둘) | `valueAreas` · 단언 (7) 동작 확인. WR-09 · CR-03 은 다음 재측정에만 |
| `tool/measurements/2026-10-13-R1.json` | R1 결과 | ✓ VERIFIED | 회차 그대로, 행 `sort_pub_dependencies` 만 값이 바뀜 |
| `example/pubspec.yaml` 과 `fixtures/*/pubspec.yaml` · 정답지 다섯 | `sort_pub_dependencies` 샘플 | ✓ VERIFIED | 정답지 다섯에 `pubspec.yaml:11  info  sort_pub_dependencies`, 되돌리면 `[5/10]` · `[6/10]` 실패 |
| `example/README.md` | M26 · 줄 수 표 (WR-05) | ✓ VERIFIED | 정답지 진단 줄 93 · 95 · 98 · 104 · 90 == 표의 값 |
| `.planning/phases/04-rule-reselection/04-DECISIONS.md` | 후보 133 결정 | ✓ VERIFIED | `켬` 81 == 배포 81, 재결정 행 · 메모 |
| `CHANGELOG.md` | 2.0.0 추가한 규칙 · 새로 생기는 경고 | ✓ VERIFIED | 75 · 75행 일치 |

### 핵심 연결

| From | To | Via | 상태 | 상세 |
|---|---|---|---|---|
| `tool/verify.dart` `[3/10]` | `lib/base.yaml` · `RULES.md` | `declaredRuleNames` · 표 파싱 | ⚠ PARTIAL | 일반 입력 · 열 0 주석은 연결됨, 따옴표 이름은 끊김 |
| R1 JSON 원자료 (`countByAreaCode`) | R1 JSON 행 · `RULES.md` | `ruleCounts` (`valueAreas`) · `--recount` | ✓ WIRED | `pubspec.yaml` 2 가 행 · 평가표 · CHANGELOG 까지 흐른다; 끊으면 단언 (7) 이 멈춘다 |
| `tool/measure_rules.dart --report --write` | `RULES.md` 실측 구역 | 생성 | ✓ WIRED | `diff` 0 |
| `tool/measure_rules.dart --audit` | `RULES.md` 세 표 | 감사 | ✓ WIRED | rc 0, 보류 0 |
| `04-DECISIONS.md` 결정 | `lib/base.yaml` | 반영 | ✓ WIRED | 켬 81 == 배포 81 |
| `example/pubspec.yaml` 샘플 | 정답지 다섯 | `dart analyze` · `--update` | ✓ WIRED | 되돌림 실험으로 확인 |

### 데이터 흐름 (Level 4)

| 산출물 | 값 | 출처 | 실데이터 | 상태 |
|---|---|---|---|---|
| `RULES.md` 평가표 | 133행 건수 | R1 JSON `rows` ← `countByAreaCode` − 기준선 | 예 | ✓ FLOWING |
| `RULES.md` 평가표 `sort_pub_dependencies` | `2 (0·0·0·2)` | `countByAreaCode["pubspec.yaml"]` 2 | 예 | ✓ FLOWING (지난 검증의 DISCONNECTED 해소) |
| CHANGELOG 경고 표 | 75행 | R1 JSON `rows.counts` 네 자리 합 | 예 | ✓ FLOWING |

### 동작 확인

| 동작 | 명령 | 결과 | 상태 |
|---|---|---|---|
| 지금 HEAD 검증 | `fvm dart run tool/verify.dart` (깨끗한 복제본) | rc 0, 10개 중 10개, 72초 | ✓ PASS |
| 루트 분석 | `fvm dart analyze` (복제본 루트) | `No issues found!` rc 0 | ✓ PASS |
| 감사 | `fvm dart run tool/measure_rules.dart --audit` | rc 0, 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0 | ✓ PASS |
| 재계산 (쓰지 않음) | `--recount --in tool/measurements/2026-10-13-R1.json` | 133행, 바뀐 행 없음, rc 0 | ✓ PASS |
| 보고서 재생성 | `--report --in …` 과 `RULES.md` 구역 `diff` | rc 0, `diff` 0줄 | ✓ PASS |
| 스타일 요약 | `--summary style --in …` | `sort_pub_dependencies` 켬 · 손으로 고칠 줄 2 (≤ 50) | ✓ PASS |
| 단언 (7) 이 CR-01 회귀를 잡음 | 복제본에서 `valueAreas` 에서 `pubspecArea` 를 뺀 뒤 `--report` | rc 1, `sort_pub_dependencies (pubspec.yaml)` | ✓ PASS |
| `[3/10]` 열 0 주석 (M26) | 열 0 주석 뒤 `avoid_print` · `prefer_mixin` | `[3/10]` 만 실패, rc 1 | ✓ PASS |
| `[3/10]` 따옴표 이름 (WR-10) | `- 'avoid_print'` 한 줄 | 10개 중 10개 통과, rc 0 | ✗ FAIL |
| 샘플 헛통과 아님 | `example/pubspec.yaml` 만 `548e3e1` 판으로 | `[5/10]` · `[6/10]` 실패, rc 1 | ✓ PASS |
| 배포 · 표 어긋남 검출 | `lib/base.yaml` 에서 `sort_pub_dependencies` 줄만 지움 | `[3/10]` (`RULES.md 에만`) · 정답지 단계 다섯 실패, rc 1 | ✓ PASS |
| WR-09 재현 | 위 "WR-09 판정" 의 변형 JSON | `--recount --write` 뒤 `--report` rc 0 · 권고 뒤집힘 | ⚠ 경고 (미래 입력) |

### Probe 실행

Step 7c: 해당 없음 — 이 phase 는 `scripts/*/tests/probe-*.sh` 를 선언하지 않는다. 확인 장치는 `tool/verify.dart` 와 `tool/measure_rules.dart` 의 출력 모드이고, 위 "동작 확인" 에서 검증자가 직접 돌렸다.

### 요구사항 범위

| 요구사항 | Plan | 설명 | 상태 | 근거 |
|---|---|---|---|---|
| RULES-01 | 04-01, 04-10, 04-11 | 기반 세트 중복 선언 삭제 | ✓ SATISFIED | 102개 기반 세트와 교집합 0 (독립 파서). 앞으로를 막는 `[3/10]` 은 gap (WR-10) |
| RULES-02 | 04-01 | 주석 처리된 설정 3개 삭제 | ✓ SATISFIED | `lib/*.yaml` 에 0건 |
| RULES-03 | 04-02 ~ 04-04, 04-09, 04-11, 04-12 | 후보마다 실측 건수 · `dart fix` 건수 표 | ✓ SATISFIED | 133행, `sort_pub_dependencies` `2 (0·0·0·2)` · `재지 않음` (상한 2) |
| RULES-04 | 04-02 ~ 04-04 | strict 계열이 같은 표에 | ✓ SATISFIED | 세 행 모두 값과 함께 |
| RULES-05 | 04-02 ~ 04-04, 04-11 | 회차 조건 기록 · 유효 회차만 사용 | ✓ SATISFIED | 52회차 유효, 조건 완비, 회차 바이트 불변, `conditions.recount` |
| RULES-06 | 04-01, 04-05 ~ 04-08, 04-10 ~ 04-12 | 소유자 결정이 배포 파일에 반영 | ✓ SATISFIED | 켬 81 == 배포 81 |
| RULES-07 | 04-06, 04-09, 04-12 | 남기는 규칙의 사유 주석이 사실 | ✓ SATISFIED | 81개 문장 일치, 새 사유는 샘플로 확인 |
| RULES-08 | 04-03, 04-07 ~ 04-09, 04-11, 04-12 | 미채택 규칙과 사유 목록 | ✓ SATISFIED | 90행, 틀린 근거 제거 |
| DOCS-11 | 04-03, 04-06 ~ 04-09, 04-12 | 켠 규칙마다 이유와 실측 건수 | ✓ SATISFIED | 81행 모두 이유 · 건수 · 회차 |

아홉 개 모두 증거로 충족이다. REQUIREMENTS.md 추적 표에서 RULES-02 · RULES-04 가 `Gaps Found` 인 것은 앞서 `revert-phase` 가 Phase 4 ID 를 모두 되돌린 뒤 gap plan 이 두 ID 를 다시 선언하지 않았기 때문이다 — 증거상 둘 다 충족이다 (이 보고서는 REQUIREMENTS.md 를 고치지 않았다). REQUIREMENTS.md 가 Phase 4 에 둔 ID 는 위 9개이고 모두 어느 plan 의 `requirements` 에 있다. 고아 요구사항 없음.

### 발견한 안티 패턴

| 파일 | 행 | 패턴 | 심각도 | 영향 |
|---|---|---|---|---|
| `tool/verify.dart` | 880 · 894 ~ 896 | 읽지 못한 `- ` 줄을 조용히 건너뜀 (따옴표 이름) | 🛑 Blocker (carried-forward 진실 6) | gap |
| `tool/measure_rules.dart` | 4985 ~ 4997 외 | `fixSkipped` 를 원인 확인 없이 고정 문장으로 적음 (WR-09) | ⚠️ Warning | 다음 재측정의 망가진 입력에서만 |
| `tool/measure_rules.dart` | 273 ~ 280 외 | `currentRules` 가 1.3.0 의 6개 (CR-03) | ⚠️ Warning (deferred) | 다음 재측정에서만 |
| `RULES.md` | 10 · 49 | 켠 규칙 표 머리가 `실측 (lib · test · bin)` — `sort_pub_dependencies` 칸이 `0 · 0 · 0 (pubspec.yaml 2줄)` (IN-08) | ℹ️ Info | 수는 칸에 적혀 있어 사실은 맞다; 읽기 혼동 |
| `lib/base.yaml` | 15 | 가리킬 대상이 없어진 템플릿 문장 (IN-05) | ℹ️ Info | Phase 5 머리 주석 정리 때 |

gap 수정 범위(`0db0fdd..HEAD`, `.planning` 밖 18파일)에 `TBD` · `FIXME` · `XXX` 0, 절대 경로 0. 같은 범위의 `.planning` 추가 줄에도 절대 경로 0.

Step 7 의 재검증 증거 기준: 진실 6 의 Blocker 는 지난 gap 2 와 같은 진실(carried-forward)이고 결정적 재현(rc 0 거짓 통과)이 있다. WR-09 는 새 범위이고 재현했지만 어느 진실도 거짓으로 만들지 않아 경고다.

### 경고 (gap 아님)

- **WR-09 · CR-03** — 위 판정. 둘 다 다음 재측정(v2, RULES-13) 전에 고칠 것. CR-03 은 REQUIREMENTS.md 에 메모가 있고, WR-09 는 그 메모에 함께 적어 두면 같은 때 다뤄진다.
- **WR-01 · WR-03 · WR-04 · WR-07 · WR-08** — 리뷰 지적 그대로 열려 있다. 지금 커밋된 값과 관련해서는 WR-01 만 다시 봤다(진실 2 — 행이 참조한 G 회차가 그 규칙을 켬, 어긋남 0). 나머지는 도구의 안전장치에 관한 것이라 phase 목표 판정에 쓰지 않았다.
- **push 하지 않은 gap 수정 커밋 24개** — CI 는 `0db0fdd` 까지만 봤다. 같은 10단계가 깨끗한 복제본에서 통과한다. 릴리스 전 push 때 CI 결과를 다시 볼 것.
- **알려진 단언 결함** — 04-12 Task 3 의 `<automated>` 는 `f5962c3` 기준이라 적힌 그대로 실패하고 `548e3e1` 기준이면 통과한다 (04-VALIDATION.md "gap 수정 실행 뒤"). 앞 plan 의 상태 고정 단언이 HEAD 에서 실패하는 것도 설계대로다. 회귀가 아니다.

### Advisory (새 범위, 증거 없음)

없음 — 이번에 새로 본 지적(WR-09 · WR-10)은 모두 복제본에서 재현했다.

### 사람 확인 필요

없음. `sort_pub_dependencies` 재결정은 `04-DECISIONS.md` 에 기록되어 있고, 그 기록대로 배포 파일 · 문서가 맞춰졌다. WR-10 을 닫을지 override 로 받을지는 gap 의 처리 방식 선택이다 (위 "WR-10 판정").

### Gap 요약

지난 gap 1 은 닫혔다. 측정 도구가 `pubspec.yaml` 자리의 진단을 값에 넣고(되돌리면 단언 (7) 이 멈춘다), R1 행은 회차를 바꾸지 않고 다시 셌으며, 소유자의 재결정(`켬`)이 배포 파일 · `RULES.md` · CHANGELOG · 결정 표 · 샘플과 정답지에 같은 커밋 흐름으로 반영되었다. 목표의 두 쪽 — 켠 규칙 81개와 켜지 않은 규칙 90개(후보 133 + 그 밖의 38) — 모두 실측과 사유가 사실로 기록되어 있다. 성공 기준 1 ~ 5 는 지금 상태로 모두 성립한다.

남은 것은 하나다. 지난 gap 2 의 `missing` 은 모두 닫혔지만, 같은 진실("규칙을 더하면 `[3/10]` 이 실패한다")이 따옴표로 감싼 규칙 이름에서 다시 거짓 통과한다(WR-10, rc 0 재현). 지금 배포 YAML 은 그 꼴을 쓰지 않으므로 지금의 판정은 맞고, 깨지는 것은 D-11 이 막으려던 앞으로의 어긋남이다 — 지난 보고서가 CR-02 를 gap (partial)로 둔 것과 같은 범위다. 수정은 `declaredRuleNames` 한 곳이고(읽지 못한 목록 줄은 실패), 소유자가 이 입력을 관례 밖으로 본다면 위 override 로 받을 수 있다.

---

_검증: 2026-10-13T09:20:48Z_
_검증자: Claude (gsd-verifier)_
