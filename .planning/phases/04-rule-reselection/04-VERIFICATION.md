---
phase: 04-rule-reselection
verified: 2026-10-13T06:40:00Z
status: gaps_found
score: 8/11 must-haves verified
covered_files:
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
  - CHANGELOG.md
  - RULES.md
  - example/README.md
  - example/expected_diagnostics.txt
  - lib/base.yaml
  - tool/measure_rules.dart
  - tool/measurements/2026-10-13-R1.json
  - tool/verify.dart
covered_digest: "v3:sha256:5209ec878155ee9abdd93ab7ef047f445ee6d538bbeedd858fdbd8cde1f2db6f"
behavior_unverified: 0
overrides_applied: 0
gaps:
  - truth: "소유자가 후보 규칙마다 실측 진단 건수를 표 하나에서 볼 수 있고(성공 기준 1), 켜지 않은 규칙의 사유가 사실로 기록되어 있다(성공 기준 5) — `sort_pub_dependencies` 행"
    status: failed
    reason: "커밋된 R1 JSON 에서 이 규칙을 켠 회차(G1 · G1-marker · G1-strip 과 apply-* 27개, 모두 30회차)의 `countByAreaCode[\"pubspec.yaml\"]` 은 `sort_pub_dependencies: 2` 이고 기준선 B0 에는 없다. 그런데 측정 도구는 `lib` · `test` · `bin` 자리만 규칙의 값으로 더해(`projectAreas`) 행의 `counts` 가 0 · 0 · 0 이다. 평가표는 `0 (표식 불가)` 를, 켜지 않은 규칙 표와 결정 표는 '실제 프로젝트 0줄' 을 사유로 적는다. 소유자는 이 틀린 0 을 근거로 `안 켬` 을 골랐다. 같은 꼴로 값이 빠진 후보 규칙은 이것 하나다 (`analysis_options.yaml` 자리의 `incompatible_lint` 2줄은 후보 행이 아니다)."
    artifacts:
      - path: "tool/measure_rules.dart"
        issue: "`const projectAreas = ['lib', 'test', 'bin']` (1721행) — `Diag.area` 가 `pubspec.yaml` 을 자리로 돌려주지만 값에 더하지 않는다. `ruleCounts` 가 0 인데 다른 자리에 그 코드가 있어도 `--report` 단언이 실패하지 않는다"
      - path: "RULES.md"
        issue: "133행 사유 '실제 프로젝트 0줄이고 …' 가 R1 과 다르다. 376행 평가표 칸 `0 (표식 불가)` 도 틀린 값이다"
      - path: ".planning/phases/04-rule-reselection/04-DECISIONS.md"
        issue: "245행(패널) · 882행(결정 표)의 0 과 '실제 프로젝트 0줄' 사유가 R1 과 다르다"
    missing:
      - "측정 도구가 `pubspec.yaml` 자리의 진단을 규칙의 값에 넣거나, 최소한 행의 값이 0 인데 다른 자리에 그 규칙 코드가 있으면 `--report` 가 실패하게 한다 (커밋된 R1 JSON 의 `countByAreaCode` 에 2줄이 이미 있으므로 비공개 프로젝트를 다시 잴 필요는 없을 수 있다 — 행 재계산 방식은 planner 가 정한다)"
      - "`--report --write` 로 `RULES.md` 실측 기록을 다시 만든다"
      - "소유자에게 실측(2줄, 모두 `pubspec.yaml`)을 보이고 `sort_pub_dependencies` 를 다시 묻는다 — 결정을 `04-DECISIONS.md` 에 적고 `RULES.md` 켜지 않은 규칙 표의 사유(또는 켠 규칙 표 · `lib/base.yaml` · CHANGELOG)를 그 결정과 실측대로 고친다"
  - truth: "기반 세트가 켜는 규칙이나 `RULES.md` 에 없는 규칙을 `lib/base.yaml` 에 더하면 `[3/10] 배포 파일의 구성` 이 실패한다 (04-01 must-have, D-11)"
    status: partial
    reason: "주석 없이 더하면 `[3/10]` 이 실패한다(대조 실험 rc 1). 그러나 `linter:` 블록 안에 열 0 주석 한 줄을 두고 그 뒤에 `- avoid_print`(기반 세트와 겹침) · `- prefer_mixin`(`RULES.md` 켠 규칙 표에 없음)을 더하면 검증 전체가 `점검 통과 (10개 중 10개)` rc 0 이다. YAML 파서는 그 두 규칙을 읽어 82개로 센다 — analyzer 가 켜는 규칙을 `declaredRuleNames` 가 보지 못한다. 지금의 `lib/base.yaml` 에는 블록 안 열 0 주석이 없어 지금 판정(80개, 겹침 0, 표 일치)은 맞다."
    artifacts:
      - path: "tool/verify.dart"
        issue: "`declaredRuleNames` (878 ~ 894행) 가 들여쓰기 없는 주석 줄에서 `linter:` 블록을 닫는다"
    missing:
      - "주석 줄과 빈 줄은 블록을 닫지 않게 한다 (`enabledLanguageOptions` 와 같은 처리)"
      - "`example/README.md` 의 M 기록에 '열 0 주석 + 겹치는 규칙' 입력에서 `[3/10]` 이 실패하는 것을 더한다"
---

# Phase 4: Rule Reselection 검증 보고서

**Phase 목표:** 배포 파일의 규칙 하나하나가 `flutter_starter_kit` 실측을 본 소유자의 결정으로 켜져 있고, 켠 이유와 켜지 않은 이유가 기록으로 남아 있다
**검증 시각:** 2026-10-13T06:40:00Z
**상태:** gaps_found
**재검증:** 아니오 — 첫 검증

검증은 모두 검증자 임시 폴더(scratchpad 아래 `verifier-` 로 시작하는 폴더)에 `git clone --local` 로 만든 복제본에서 했다. 작업 트리는 바꾸지 않았다. 비공개 사용 프로젝트의 원본은 돌리지 않았고, 커밋된 `tool/measurements/2026-10-13-R1.json` 과 `--report` · `--audit` 로 판정했다. 측정 도구 smoke 는 `--source <복제본>/example` 로 돌렸다.

## 목표 달성

### 관찰 가능한 진실

| # | 진실 | 상태 | 근거 |
|---|------|------|------|
| 1 | (성공 기준 1) 후보 규칙마다 실측 진단 건수와 `dart fix` 건수를 표 하나에서 본다 — strict 계열 포함 | ✗ FAILED (133행 중 1행) | 평가표 133행, strict 셋(`no_dynamic_casts` info 0 · `no_raw_types` info 0 · `strict-inference` warning 106) 모두 있다. 그러나 `sort_pub_dependencies` 행이 실측 2줄(`pubspec.yaml`)을 `0 (표식 불가)` 로 보인다 — CR-01 재확인, 아래 "CR-01 판정" |
| 2 | (성공 기준 2) 수치마다 회차를 따라갈 수 있고, 회차에 SDK · 기반 세트 · plugin 버전이 있으며, 무효 회차의 수치는 쓰이지 않았다 | ✓ VERIFIED | R1 JSON 회차 52개 모두 `valid: true` · `expectedCovered: true`, 조건 필드(dart · flutter · baseSet · plugin · languageVersion · sdkConstraint · dartFiles · date) 빠진 회차 0. 행이 참조한 회차가 없거나 무효인 행 0. 행이 참조한 G 회차의 `options` 에 그 규칙이 없는 경우 0 (WR-01 꼴 없음) |
| 3 | (성공 기준 3) 후보마다 소유자의 채택 / 미채택 결정이 기록되어 있고, 배포 파일의 켠 규칙이 채택 목록과 같다 | ✓ VERIFIED | `04-DECISIONS.md` 결정 표 133행: 소유자 응답 119행 + v2 12 + 규칙이 돌지 않아 결정하지 않은 2 (`require_trailing_commas` · `package_prefixed_library_names`, 로드맵 Notes · D-02 의 설계대로). Ruby YAML 파서로 읽은 `lib/base.yaml` 규칙 80개 == `RULES.md` 켠 규칙 표 80행, 두 표에 겹친 이름 0 |
| 4 | (성공 기준 4) 배포 파일에 기반 세트 겹침과 주석 처리된 설정 3개가 없고, 사유 주석이 사실과 맞다 | ✓ VERIFIED | `lints` 6.1.0 core · recommended 와 `flutter_lints` 6.0.0 flutter (102개)와의 교집합 0. `lib/*.yaml` 에 `require_trailing_commas` · `public_member_api_docs` · `formatter` 0건. 사유 표본 확인: `avoid_final_parameters` 의 "언어 버전 3.13 에서는 돌지 않는다" 를 복제본에서 `// @dart=3.11` 을 지우고 돌려 규칙 대신 `extraneous_modifier` error 가 나는 것으로 확인. `prefer_const_*` 의 lints#205 는 `flutter_lints` 5.0.0 CHANGELOG 의 세 규칙 제거와 같다. `strict_top_level_inference` 는 `lints` 6.1.0 `core.yaml` 에 있다 |
| 5 | (성공 기준 5) 켠 규칙마다 이유와 실측 건수의 근거 문서, 켜지 않은 규칙과 그 사유의 목록이 있다 | ✗ FAILED (91행 중 1행) | `RULES.md` 켠 규칙 80행(사유 80개가 `lib/base.yaml` 주석과 글자 그대로 같음) · 켜지 않은 규칙 91행, `--audit` rc 0. 그러나 `sort_pub_dependencies` 의 사유 "실제 프로젝트 0줄" 이 R1 과 다르다 |
| 6 | (04-01) 기반 세트 규칙이나 `RULES.md` 에 없는 규칙을 `lib/base.yaml` 에 더하면 `[3/10]` 이 실패한다 | ✗ FAILED (partial) | 대조군(주석 없이 더함): `[3/10]` 실패, rc 1. 열 0 주석 뒤에 더함: 10개 중 10개 통과, rc 0 — CR-02 재현 |
| 7 | (04-02 · 04-04) 측정 도구가 회차 조건을 기록하고 저장소 밖에서만 돌며, 결과에 사용 프로젝트의 경로 · 메시지가 없다 | ✓ VERIFIED | smoke(`--stage baseline,groups`, 46초) rc 0, 회차 3개 유효, 복제본의 `git status --porcelain` 전후 0줄. R1 JSON 안의 `/` 가 든 문자열은 `lib/woody_probe_marker/` 표식 줄뿐 |
| 8 | (04-03 · 04-09) `RULES.md` 실측 기록이 `--report` 출력과 같고, `--audit` 이 통과한다 | ✓ VERIFIED | 복제본에서 `--report --in tool/measurements/2026-10-13-R1.json` rc 0, `RULES.md` 의 `woody:measurements` 구역과 `diff` 0줄. `--audit` rc 0 `켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0` |
| 9 | (04-06 ~ 04-08) 결정이 배포 파일에 반영되고, 새로 켠 규칙은 정답지에 줄이 있으며 검증이 통과한다 | ✓ VERIFIED | 깨끗한 복제본 `fvm dart run tool/verify.dart` rc 0, `점검 통과 (10개 중 10개)` (68.8초) |
| 10 | (04-09) CHANGELOG `### 새로 생기는 경고` 가 새로 켠 규칙과 실측에 맞다 | ✓ VERIFIED | 표 74행 == `lib/base.yaml` − 1.3.0 의 6개. 건수(lib + test + bin 합)와 강도가 R1 JSON 과 74행 모두 같다 |
| 11 | (04-10 · 제약) 브랜치가 push 되어 CI 가 통과했고, `main` 은 1.3.0 그대로다 | ✓ VERIFIED | `gh run view 38351171683`: `completed` · `success`, head `0db0fdd`, 브랜치 `gsd/v2.0-package-rework`. `origin/main` = `90a2736` (1.3.0), `pubspec.yaml` `version: 1.3.0`. PR 0 |

**점수:** 11개 중 8개 verified (present, behavior-unverified 0)

### CR-01 판정 (`sort_pub_dependencies`)

- 커밋된 R1 JSON 에서 이 규칙을 켠 30회차의 `countByAreaCode["pubspec.yaml"]` 이 `{"sort_pub_dependencies": 2}` 이고, 이 규칙을 켜지 않은 B0 · B0-313 · B0-strip 에는 없다. 행의 `counts` 는 `{"lib": 0, "test": 0, "bin": 0}`, `severity` 는 `info` 다.
- 2줄은 도구가 만든 것이 아니다. 도구는 `woody_lints` 를 `pubspec_overrides.yaml` 로 돌리고(`pointToRepo`), `pubspec.yaml` 은 언어 3.13 회차에서만 바꾼다. G1 은 언어 3.11 회차이므로 원본 그대로의 `pubspec.yaml` 이다.
- 같은 꼴로 0 이 된 후보는 없다. Dart 파일 밖 자리는 `pubspec.yaml` (`sort_pub_dependencies` 2)과 `analysis_options.yaml` (`incompatible_lint` 2, G3 · 쌍 회차)뿐이고, `incompatible_lint` 은 후보 행이 아니다. 같은 사유 문구를 쓴 `use_test_throws_matchers` 의 0줄은 `test` 자리를 센 값이라 사실이다.
- 목표의 두 조건 모두 이 행에서 성립하지 않는다. "켜지 않은 이유가 기록으로 남아 있다" — 기록은 있지만 그 근거("실제 프로젝트 0줄")가 실측과 다르다. "실측을 본 소유자의 결정" — 소유자가 본 수치가 실측이 아니었다. 사유의 둘째 부분("`lib/` 샘플로 걸리는 것을 보일 수 없다")은 사실이지만, 소유자가 첫째 근거 없이도 같은 결정을 했을지는 기록에서 알 수 없다.
- 상태: 문서(`RULES.md` 133 · 376행, `04-DECISIONS.md`)를 고쳐야 목표가 성립하므로 `gaps_found` 다. 고치는 과정에 소유자의 재결정이 들어간다 (gap 1 의 `missing` 셋째 항목).

### CR-02 판정 (`[3/10]` 거짓 통과)

- 지금 상태의 정확성: 맞다. `lib/base.yaml` 의 `linter:` 블록(17 ~ 104행) 안에는 열 0 주석이 없다. Ruby YAML 파서가 읽은 규칙 80개와 `declaredRuleNames` 가 센 80개가 같고, 겹침 0 · 표 일치다.
- 장치의 구멍: 있다. 복제본에서 `no_raw_types` 뒤에 `# 실험 중 (열 0 주석)` 한 줄과 `- avoid_print` · `- prefer_mixin` 을 더하면 검증 전체가 10개 중 10개 통과(rc 0)다. YAML 파서는 82개를 읽는다.
- 리뷰의 주장 가운데 틀린 것: 리뷰는 `- cascade_invocations` 를 더해도 "검증 전체가 통과한다" 고 적었다. 같은 입력을 돌리면 `[3/10]` 은 통과하지만 `example/` 샘플이 이 규칙에 걸려 `[5/10]` · `[7/10]` ~ `[10/10]` 이 실패한다(10개 중 5개, rc 1). 정답지가 잡지 못하는 경우는 기반 세트와 겹치는 규칙, 그리고 샘플이 걸리지 않는 규칙이다.
- 목표에 닿는지: 지금의 성공 기준 3 · 4 는 독립 파서로 성립한다. 깨지는 것은 04-01 must-have 의 일반 명제("더하면 실패한다")와 D-11 이 막으려던 앞으로의 어긋남이다. 그래서 gap 2 는 `partial` 로 적었다.

### CR-03 판정 (재측정 시 0줄)

- 지금 커밋된 R1 값: 영향 없다. R1 JSON 은 `e3651ec` (10:43)에 커밋되었고, `lib/base.yaml` 에 규칙을 더한 커밋은 `9cff42e` (11:34)부터다. R1 의 B0 · B0-313 · B0-strip 의 `lib` · `test` · `bin` 자리에는 채택한 74개의 코드가 하나도 없다. 04-08 의 UI-base 에는 채택 규칙의 코드가 27개 있지만, 그 회차에서 쓴 값은 `unnecessary_ignore` 의 `countsUI` 뿐이다.
- 재측정에서 생기는 결함: 재현했다. 복제본에서 `--source <복제본>/example --stage baseline,groups --rules directives_ordering,unnecessary_lambdas` 를 돌리면 B0 · G1 모두 `lib` 에 두 규칙이 1줄씩 있고 행의 값은 0 · 0 · 0 이다.
- 영향 범위: 다음 재측정(v2 의 RULES-13 · Dart 3.14)에만 해당한다. 이 마일스톤의 다음 phase(5 Documentation, 6 Release)에는 재측정이 없다. 이 phase 의 목표에는 닿지 않으므로 gap 이 아니라 경고로 둔다 (아래 "경고").

### 필요한 산출물

| 산출물 | 기대 | 상태 | 상세 |
|---|---|---|---|
| `lib/base.yaml` | 이 패키지가 더하는 규칙만, 사유 주석과 함께 | ✓ VERIFIED | 80개, 겹침 0, 주석 처리된 설정 0 |
| `RULES.md` | 켠 규칙 · 켜지 않은 규칙 · 실측 기록 | ⚠ 1행 사실과 다름 | `sort_pub_dependencies` (133 · 376행) |
| `tool/verify.dart` | `[3/10] 배포 파일의 구성` | ⚠ 구멍 | 열 0 주석 뒤 규칙을 보지 못함 |
| `tool/measure_rules.dart` | 측정 · 요약 · 보고서 · 감사 | ⚠ 2건 | `pubspec.yaml` 자리 누락(CR-01), 지금 저장소 재측정 시 0(CR-03) |
| `tool/measurements/2026-10-13-R1.json` | R1 결과 | ✓ VERIFIED (원자료) | 원자료(`countByAreaCode`)는 맞고, 행 `sort_pub_dependencies.counts` 만 틀림 |
| `.planning/phases/04-rule-reselection/04-DECISIONS.md` | 후보 133 결정 | ⚠ 1행 근거 틀림 | 245 · 882행 |
| `CHANGELOG.md` | 2.0.0 새로 생기는 경고 | ✓ VERIFIED | 74행 일치 |

### 핵심 연결

| From | To | Via | 상태 | 상세 |
|---|---|---|---|---|
| `tool/verify.dart` `[3/10]` | `lib/base.yaml` · `RULES.md` | `declaredRuleNames` · 표 파싱 | ⚠ PARTIAL | 일반 입력에서는 연결됨, 열 0 주석 뒤는 끊김 |
| `tool/measure_rules.dart --report --write` | `RULES.md` 실측 구역 | 생성 | ✓ WIRED | `diff` 0 |
| `tool/measure_rules.dart --audit` | `RULES.md` 세 표 | 감사 | ✓ WIRED | rc 0, 보류 0 |
| R1 JSON 원자료 | R1 JSON 행 · `RULES.md` | `ruleCounts` (`projectAreas`) | ✗ 1행 끊김 | `pubspec.yaml` 자리 버림 |
| `04-DECISIONS.md` 결정 | `lib/base.yaml` | 반영 | ✓ WIRED | 켬 80 == 배포 80 |

### 데이터 흐름 (Level 4)

| 산출물 | 값 | 출처 | 실데이터 | 상태 |
|---|---|---|---|---|
| `RULES.md` 평가표 | 133행 건수 | R1 JSON `rows` ← `countByAreaCode` − 기준선 | 예 | ✓ FLOWING (1행 제외) |
| `RULES.md` 평가표 `sort_pub_dependencies` | 0 | `ruleCounts` 가 `pubspec.yaml` 자리를 버림 | 원자료 2 → 0 | ✗ DISCONNECTED |
| CHANGELOG 경고 표 | 74행 | R1 JSON `rows.counts` 합 | 예 | ✓ FLOWING |

### 동작 확인

| 동작 | 명령 | 결과 | 상태 |
|---|---|---|---|
| 지금 HEAD 검증 | `fvm dart run tool/verify.dart` (깨끗한 복제본) | rc 0, 10개 중 10개 | ✓ PASS |
| 감사 | `fvm dart run tool/measure_rules.dart --audit` | rc 0, 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0 | ✓ PASS |
| 보고서 재생성 | `--report --in tool/measurements/2026-10-13-R1.json` 과 `RULES.md` 구역 `diff` | rc 0, `diff` 0줄 | ✓ PASS |
| `[3/10]` 겹침 검출 (대조군) | 주석 없이 `avoid_print` · `prefer_mixin` 추가 후 verify | `[3/10]` 실패, rc 1 | ✓ PASS |
| `[3/10]` 겹침 검출 (열 0 주석) | 열 0 주석 뒤 같은 두 줄 추가 후 verify | 10개 중 10개 통과, rc 0 | ✗ FAIL |
| 사유 주석 사실성 | `example/lib/final_parameters_rule.dart` 의 `// @dart=3.11` 제거 후 `dart analyze` | `extraneous_modifier` error 1, `avoid_final_parameters` 없음 | ✓ PASS |
| 측정 도구 smoke | `--source <복제본>/example --stage baseline,groups --rules directives_ordering,unnecessary_lambdas` | rc 0, 회차 3개 유효, 두 행 값 0 (CR-03 재현) | ✓ 실행 / ⚠ 값 |
| CI | `gh run view 38351171683` | completed · success | ✓ PASS |

### Probe 실행

Step 7c: 해당 없음 — 이 phase 는 `scripts/*/tests/probe-*.sh` 를 선언하지 않는다. phase 의 확인 장치는 `tool/verify.dart` 와 `tool/measure_rules.dart --report` · `--audit` 이고, 위 "동작 확인" 에서 직접 돌렸다.

### 요구사항 범위

| 요구사항 | Plan | 설명 | 상태 | 근거 |
|---|---|---|---|---|
| RULES-01 | 04-01, 04-10 | 기반 세트 중복 선언 6개 삭제 | ✓ SATISFIED | 겹침 0 (독립 파서) |
| RULES-02 | 04-01 | 주석 처리된 설정 3개 삭제 | ✓ SATISFIED | `lib/*.yaml` 에 0건 |
| RULES-03 | 04-02 ~ 04-04, 04-09 | 후보마다 실측 건수 · `dart fix` 건수 표 | ✗ BLOCKED (1행) | `sort_pub_dependencies` 0 ↔ 원자료 2 |
| RULES-04 | 04-02 ~ 04-04 | strict 계열이 같은 표에 | ✓ SATISFIED | 세 행 모두 값과 함께 |
| RULES-05 | 04-02 ~ 04-04 | 회차 조건 기록 · 유효 회차만 사용 | ✓ SATISFIED | 52회차 유효, 조건 필드 완비 |
| RULES-06 | 04-01, 04-05 ~ 04-08, 04-10 | 소유자 결정이 배포 파일에 반영 | ✓ SATISFIED | 켬 80 == 배포 80 (단, gap 1 의 재결정 결과에 따라 바뀔 수 있음) |
| RULES-07 | 04-06, 04-09 | 남기는 규칙의 사유 주석이 사실 | ✓ SATISFIED | 표본 확인 · 80개 문장 일치 |
| RULES-08 | 04-03, 04-07 ~ 04-09 | 미채택 규칙과 사유 목록 | ✗ BLOCKED (1행) | `sort_pub_dependencies` 사유가 실측과 다름 |
| DOCS-11 | 04-03, 04-06 ~ 04-09 | 켠 규칙마다 이유와 실측 건수 | ✓ SATISFIED | 80행 모두 이유 · 건수 · 회차 |

REQUIREMENTS.md 가 Phase 4 에 둔 ID 는 위 9개이고, 모두 plan 의 `requirements` 에 있다. 고아 요구사항 없음.

### 발견한 안티 패턴

| 파일 | 행 | 패턴 | 심각도 | 영향 |
|---|---|---|---|---|
| `tool/measure_rules.dart` | 1721 | 규칙 값 자리가 `lib` · `test` · `bin` 으로 고정 | 🛑 Blocker | gap 1 의 원인 |
| `tool/verify.dart` | 885 ~ 887 | 열 0 주석이 `linter:` 블록을 닫음 | ⚠️ Warning | gap 2 |
| `tool/measure_rules.dart` | 269 ~ 276 외 | "지금 켜 둔 규칙" 이 1.3.0 의 6개로 고정 | ⚠️ Warning | 다음 재측정에서만 (CR-03) |
| `lib/base.yaml` | 15 | 가리킬 대상이 없어진 템플릿 문장 | ℹ️ Info | Phase 5 (DOCS-10) 머리 주석 정리와 함께 |

이 phase 에서 바뀐 파일(저장소 기준 `.planning` 밖 71개)에 `TBD` · `FIXME` · `XXX` 표식 0, 공개 산출물(`RULES.md` · `CHANGELOG.md` · `README.md` · `tool/` · `lib/` · `example/` · `fixtures/`)에 절대 경로 0. phase 문서의 절대 경로 패턴은 모두 누출 점검 명령의 정규식이다.

### 경고 (gap 아님)

- **CR-03** — 위 판정. 다음 재측정 전에 고쳐야 한다. 이 마일스톤 안의 phase 가 다루지 않으므로 v2 (RULES-13) 의 선행 작업으로 기록해 두는 것이 맞다.
- **결정하지 않은 2행** — `require_trailing_commas` · `package_prefixed_library_names` 는 `04-DECISIONS.md` 에서 `결정 안 함 (표식 불가)` 이고 `RULES.md` 에는 `규칙이 돌지 않음` 으로 적혔다. 켜도 아무것도 보고하지 않는 규칙이라 설계(D-02)대로이고, 사유도 기록되어 있다. 다만 `require_trailing_commas` 의 "Dart 파일 하나로는 어길 수 없다" 는 파일 머리 `// @dart=3.6` 으로 반증될 수 있다 (리뷰 IN-06, 이 검증에서 돌리지는 않았다).
- 리뷰의 나머지 WR-01 ~ WR-08 은 지금 커밋된 값에 영향이 없음을 확인한 것(WR-01: 행의 그룹 회차가 그 규칙을 켬 — 위 진실 2)만 다시 봤다. 나머지는 도구의 안전장치 · 문서 수치(`example/README.md` 정답지 줄 수 등)에 관한 것으로 phase 목표의 판정에 쓰지 않았다.

### 사람 확인 필요

gap 1 을 닫는 과정에 소유자의 재결정이 들어간다 (`sort_pub_dependencies` — 실측 2줄, 모두 `pubspec.yaml`, `dart fix` 칸은 재지 않음). 상태는 문서와 도구를 고쳐야 하므로 `gaps_found` 이고, 이 재결정은 gap 1 의 `missing` 에 적었다.

### Gap 요약

목표 가운데 "켠 규칙" 쪽은 성립한다. 배포 파일의 80개는 독립 파서로 읽어도 기반 세트와 겹치지 않고, `RULES.md` 와 같으며, 결정 표의 `켬` 과 같고, 사유와 실측 · 회차가 모두 붙어 있다. 회차 52개는 모두 유효하고 조건이 기록되어 있다.

"켜지 않은 이유" 쪽에서 한 행이 깨진다. 측정 도구가 `pubspec.yaml` 에서 나온 진단을 규칙의 값에 넣지 않아, `sort_pub_dependencies` 의 실측 2줄이 표와 결정 패널에 0 으로 실렸고, 소유자의 `안 켬` 결정과 `RULES.md` 의 사유가 그 0 을 근거로 쓴다 (gap 1). 원자료는 커밋된 JSON 에 이미 있다.

검증 장치 `[3/10]` 은 지금 상태를 옳게 판정하지만, 열 0 주석 뒤에 더한 규칙을 보지 못해 앞으로의 겹침 · 표 불일치를 놓칠 수 있다 (gap 2, partial). 두 gap 은 원인이 다르다 — gap 1 은 측정 도구의 집계 자리, gap 2 는 검증 도구의 블록 경계다.

---

_검증: 2026-10-13T06:40:00Z_
_검증자: Claude (gsd-verifier)_
