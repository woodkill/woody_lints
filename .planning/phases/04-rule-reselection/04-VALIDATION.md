---
phase: "4"
slug: "rule-reselection"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-13"
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> 출처: `04-RESEARCH.md` § "Validation Architecture", § 4 (`tool/verify.dart` 의 변경), § 8 (D-07 의 비공개 정보 점검), § "Common Pitfalls". 시간 값은 조사 단계의 추정이다 (실측 1회 약 32분은 spike 021 ~ 023 의 그룹 · apply 시간에서 셈한 추정). `tool/measure_rules.dart`, `RULES.md`, `tool/verify.dart` 의 새 단계는 아직 없으므로 아래 명령 가운데 그것들을 가리키는 것은 이 phase 가 만든 뒤에야 돈다.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 없음 — Dart 테스트 패키지를 두지 않는다 (02-CONTEXT.md D-11). 검증 명령 `tool/verify.dart` (정답지 비교 + 단계 검사), 루트 `fvm dart analyze`, `tool/measure_rules.dart` 의 자기 판정(회차 `valid` · 저장소 지문), `04-RESEARCH.md` § 8 의 grep 점검이 하네스다 |
| **Config file** | `tool/verify.dart` 의 `fixtures` 표와 새 단계가 읽는 목록, `RULES.md` 의 마커 구역 (이 phase 가 만든다), 정답지 다섯 (`example/expected_diagnostics.txt`, `fixtures/{base_only,base_riverpod,base_codegen,overrides}/expected_diagnostics.txt`) |
| **Quick run command** | `fvm dart analyze && fvm dart run tool/verify.dart` |
| **Full suite command** | 위 둘 + `04-RESEARCH.md` § 8 의 점검 (1) ~ (4) + (로컬만) `fvm dart run tool/measure_rules.dart` 의 실측 · `--report` 단언 |
| **Estimated runtime** | ~25 seconds (루트 분석 약 1초 + `verify.dart` plugin 준비된 상태 약 22초. 처음 실행은 약 69초). 실측 1회는 약 32분 (추정, 로컬만). GitHub runner 의 job 은 약 3분 30초 ~ 4분 7초 (Phase 03 기록) |

---

## Sampling Rate

- **After every task commit:** `fvm dart analyze` + `fvm dart run tool/verify.dart` + § 8 의 (1) ~ (3). 결정 묶음 커밋은 `--update` 전에 보통 실행으로 정답지 diff 를 먼저 본다
- **After every plan wave:** 위 + § 8 의 (4), `example/lib` 와 `fixtures/*/lib` 의 샘플이 같은지 (`suppress/` 제외), 실측 wave 는 `measure_rules.dart` 의 지문 비교 · 회차 `valid` 전부
- **Before `/gsd-verify-work`:** 로컬 `verify` 종료 코드 0 · 모든 단계 통과, 첫 push 뒤 GitHub `verify` 성공 1회 이상, `--report` 단언 전부 통과, § 8 전부 0, `example/README.md` 의 새 지워 보기 기록
- **Max feedback latency:** 30 seconds (로컬 `verify` 재실행. 실측은 표본 추출 대상이 아니다 — wave 하나에 한 번)

---

## Per-Task Verification Map

Task ID / Plan / Wave / Threat Ref 는 계획(`04-01` ~ `04-10-PLAN.md`, 2026-10-13)으로 채웠다. gap 수정 plan `04-11` · `04-12` 의 행 다섯은 gap 계획 때 더했고, 2회차 gap 수정 plan `04-13` 의 행 셋은 재검증(gaps_found 10/11, WR-10) 뒤의 gap 계획 때 더했다 (2026-10-13). Task ID 는 `<plan>-T<n>` 이고, 명령은 각 PLAN 의 `<automated>` 에 그대로 있다 (여기는 요지). W0 항목(`tool/verify.dart` 새 단계 · `tool/measure_rules.dart` · `RULES.md` 마커)은 wave 1 · 2 의 plan 이 만든다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 04-01-T1 | 04-01 | 1 | RULES-01 | T-04-01 | N/A | 단계 검사 (CI) | `fvm dart run tool/verify.dart` → `[3/10] 배포 파일의 구성 … 통과` (겹침 검사). 보조: `grep -E '^\s*- [A-Za-z0-9_]+' lib/base.yaml \| wc -l` = 6 이고 그 여섯이 이 패키지만의 규칙; M20 (`avoid_print` 를 더하면 `[3/10]` 만 실패) | ✅ | ✅ green |
| 04-01-T1 | 04-01 | 1 | RULES-02 | T-04-01 | N/A | grep (CI 가능) | `grep -c -E 'require_trailing_commas\|public_member_api_docs\|trailing_commas' lib/base.yaml` → 0, `^\s*#\s*-\s` 줄 0, `formatter:` 줄 0 | ✅ | ✅ green |
| 04-04-T2 | 04-04 | 3 | RULES-03 | T-04-11 | N/A | 데이터 검사 (로컬) | `fvm dart run tool/measure_rules.dart --report --in tool/measurements/*-R1.json` → exit 0 (행 133 · 결정 대상 121 행의 빈 칸 0 · 참조 회차 valid); 04-09-T1 의 `--report --write` 가 `RULES.md` § 실측 기록에 그 표 | ✅ | ✅ green |
| 04-04-T2 | 04-04 | 3 | RULES-04 | T-04-11 | N/A | 데이터 검사 (로컬) | 같은 `--report` + python 단언: `no_dynamic_casts` · `no_raw_types` · `strict-inference` 행에 값, `strict-inference` 강도 `warning` | ✅ | ✅ green |
| 04-04-T2 | 04-04 | 3 | RULES-05 | T-04-12 | 무효 회차의 수치가 표에 쓰이지 않는다 | 데이터 검사 (로컬) | python 단언: 모든 회차 `valid: true`, 회차마다 `dart` · `flutter` · `baseSet` · `plugin` · `languageVersion` · `sdkConstraint` · `dartFiles`, 행이 참조하는 회차 모두 valid; 0줄 행은 `markerDetected` 가 정해져 있다 (04-03-T1 이 표식 전부의 검출을 example/ 로 확인) | ✅ | ✅ green |
| 04-01-T2 · 04-06-T1 ~ T3 · 04-07-T1 ~ T2 · 04-08-T3 | 04-01 · 04-06 · 04-07 · 04-08 | 1 · 5 · 6 · 7 | RULES-06 | T-04-02 · T-04-16 · T-04-20 | N/A | 단계 검사 (CI) + python | `[3/10]` (c) `RULES.md` ↔ `lib/base.yaml`; M21 · M22 · M25 로 헛통과 아님; 묶음 커밋마다 python 단언 "더한 규칙 == `04-DECISIONS.md` 의 켬" | ✅ | ✅ green |
| 04-06-T1 | 04-06 | 5 | RULES-07 | T-04-17 | N/A | grep + python + 사람 확인 | `grep -c '성능 향상' lib/base.yaml` → 0 (D-18); python 단언 "켠 이유(`RULES.md`) == 사유 주석(`base.yaml`)" (A5 를 자동화); 문장의 사실 여부는 04-05 checkpoint 에서 소유자가 본다 | ✅ | ✅ green |
| 04-07-T3 · 04-08-T3 · 04-09-T1 | 04-07 · 04-08 · 04-09 | 6 · 7 · 8 | RULES-08 | T-04-21 | N/A | 데이터 검사 (로컬) | `fvm dart run tool/measure_rules.dart --audit` → exit 0, 04-07 에서 `보류 1`, 04-08 · 04-09 에서 `보류 0` (후보 133 ∪ B-7 31 ⊆ 켠 ∪ 켜지 않음, 접두사 7종) | ✅ | ✅ green |
| 04-06-T1 ~ T3 · 04-07-T1 ~ T2 · 04-09-T1 | 04-06 · 04-07 · 04-09 | 5 · 6 · 8 | DOCS-11 | T-04-17 | N/A | 데이터 검사 | 묶음 커밋의 python 단언: 켠 규칙 행의 칸 여섯이 비어 있지 않고 `(실측 전` 없음, 실측 칸 == R1 `counts`; `--audit` (d) | ✅ | ✅ green |
| 04-01-T2 | 04-01 | 1 | (D-12 WR-01) | T-04-02 | N/A | 단계 검사 (CI) | M23 · M24: `lib/recommended.yaml` · `lib/analysis_options.yaml` 에 규칙 세 줄 → `[3/10]` 실패; 04-09-T2 가 `03-REVIEW-DISPOSITION.md` WR-01 을 `fixed` 로 | ✅ | ✅ green |
| 04-01-T2 · 04-04-T3 · 04-05-T1 · 04-08-T2 · 04-09-T1 ~ T2 · 04-10-T1 | 04-01 · 04-04 · 04-05 · 04-08 · 04-09 · 04-10 | 1 · 3 · 4 · 7 · 8 · 9 | (D-07) | T-04-03 · T-04-06 · T-04-11 · T-04-15 · T-04-23 · T-04-25 · T-04-26 | 비공개 사용 프로젝트의 경로 · 메시지 · 코드가 저장소와 `.planning/` 에 없다 | grep (커밋 전) | § 8 (1) ~ (3) 모두 0 (04-04-T3 · 04-10-T1 은 (4) 도 — 원본 경로는 환경변수로만); 도구 출력 구조에 경로 · 메시지 필드 없음 (`"message"` 0) | ✅ | ✅ green |
| 04-02-T1 ~ T2 · 04-04-T2 | 04-02 · 04-04 | 1 · 3 | (D-09) | T-04-04 · T-04-05 · T-04-08 · T-04-12 | 측정 도구가 원본 · 저장소를 바꾸지 않는다 | 자기 판정 (로컬) | `--work` 가 저장소 안이면 exit 64 (아무것도 만들지 않음); smoke · 실측 전후 저장소 `git status` 동일; 단계마다 지문 비교 (다르면 exit 1); 원본 `git status --porcelain` 줄 수 전후 동일 | ✅ | ✅ green |
| 04-01-T1 | 04-01 | 1 | (D-20) | T-04-01 | N/A | 실행 기록 | 삭제 커밋에서 `fvm dart run tool/verify.dart --update` → `바뀐 정답지가 없다`, 정답지 다섯이 `19ae5ec` · `91bbeec` · `9ed0fe5` 와 `git diff --quiet`; 04-01-T2 가 README 확인 기록 (i) 로 남긴다 | ✅ | ✅ green |
| 04-06-T2 ~ T3 · 04-07-T1 ~ T2 | 04-06 · 04-07 | 5 · 6 | (D-10) | T-04-16 · T-04-20 | N/A | 정답지 비교 (CI) + python | 묶음 커밋의 python 단언: 정답지 다섯의 `+lib/` 줄 규칙 집합 == 더한 규칙, `-` 0, `exit` 불변 (`strict-inference` 때 `base_codegen` 만 `exit 2`); 04-09-T2 의 M25 와 확인 기록 (ii) | ✅ | ✅ green |
| 04-10-T1 ~ T3 | 04-10 | 9 | (D-22) | T-04-26 · T-04-27 · T-04-28 | workflow 가 읽기 권한만 가진다; `main` · tag 불변 | e2e (GitHub, 읽기 전용 조회) | push 전 점검(비공개 · fast-forward · `gh auth status`) → 소유자 확인 checkpoint → `git push origin gsd/v2.0-package-rework` → `gh run list` 의 HEAD run 이 `completed success`, 로그에 `점검 통과 (10개 중 10개)` 와 `[3/10] … 통과`, `main` `90a2736` · `v1.3.0` · PR 0 | ✅ | ✅ green |
| 04-11-T1 | 04-11 (gap) | 10 | RULES-03 · RULES-05 | T-04-29 · T-04-30 | `--recount --write` 가 회차(`runs`)를 바꾸지 않는다; 다시 센 값의 출처가 `conditions.recount` 에 남는다 | 데이터 검사 (로컬) + 출력 모드 | `jq` 로 R1 JSON 의 `rows.sort_pub_dependencies.counts["pubspec.yaml"]` = 2 · `fixSkipped` · `conditions.recount`; `runs` · 다른 행 · 다른 칸이 `bcc8c91` 과 같음(`jq -S` diff 0); `--recount --in …` → `바뀐 행이 없다`; `--report --in …` rc 0 이고 출력 == `RULES.md` 실측 기록, `sort_pub_dependencies` 행 `2 (0·0·0·2)` · `재지 않음`, 가린 줄 `-48 (-1·-46·-1·0)`; 단언 (7) 의 실패 방향 — G1 · G1-strip 의 `pubspec.yaml` 자리를 `analysis_options.yaml` 로 옮긴 임시 JSON 으로 `--report --in` rc 1 · `값에 넣지 않은 자리에 진단이 있는 행 1개: sort_pub_dependencies (analysis_options.yaml)`; `--summary style` 의 행 `켬 · 손으로 고칠 줄 2 (≤ 50)`; `--audit` 80 · 0 · 91 · 0 그대로; `fvm dart run tool/verify.dart` 10/10 | ✅ | ✅ green |
| 04-11-T2 | 04-11 (gap) | 10 | RULES-01 · RULES-06 | T-04-31 | 상류 YAML 에서 규칙 0개면 두 도구가 `FormatException` (70) | 단계 검사 (CI) + 함수 단위 탐침 | M26 (`lib/base.yaml` 의 `no_raw_types` 뒤 열 0 주석 + `- avoid_print` + `- prefer_mixin`) → `[3/10]` 만 실패, `+ avoid_print` · `+ prefer_mixin`, rc 1; `.dart_tool/woody_gap_probe/probe.dart` 가 들여쓰기 4칸에서 `control verify 2 measure 2`, 2칸에서 두 `FormatException`; README 에 `| M26 |` · `WR-06 은 함수 단위로 확인했다`; 되돌린 뒤 10/10 | ✅ | ✅ green |
| 04-12-T1 | 04-12 (gap) | 11 | RULES-06 · RULES-08 · DOCS-11 | T-04-32 · T-04-33 | pubspec 순서 변경이 lock · 다른 진단을 바꾸지 않는다 | 정답지 비교 (CI) + 단계 검사 | `lib/base.yaml` 81개(`sort_pub_dependencies` 가 `sort_constructors_first` 바로 다음), `RULES.md` 켠 81 · 켜지 않음 90, 사유 문장이 두 파일에서 같음; pubspec 여섯 10행 `flutter_riverpod` → 11행 `flutter:`; 정답지 다섯 `+pubspec.yaml:11  info  sort_pub_dependencies` 한 줄뿐(`944ca1c` 와 diff), lock 여섯 불변; `--audit` 81 · 0 · 90 · 0; `--report` 출력 == 실측 기록; verify 10/10 · `--update` `바뀐 정답지가 없다`; `example/pubspec.yaml` 만 되돌리면 `[5/10]` · `[6/10]` 실패 (헛통과 아님) | ✅ | ✅ green |
| 04-12-T2 | 04-12 (gap) | 11 | RULES-03 · RULES-07 · RULES-08 | T-04-33 · T-04-34 | 결정 표 · CHANGELOG 가 같은 사유 · 같은 값 | grep (커밋 전) | CHANGELOG `### 추가한 규칙` 75 (사유 == `lib/base.yaml`) · `### 새로 생기는 경고` 75 (`| info | 2건 | 재지 않음 |`) · 각주 · 도구 수정 불릿, 1.3.0 아래 == `90a2736`; `04-DECISIONS.md` 의 `sort_pub_dependencies` 행 `… | 결정 안 함 (표식 불가) | 켬 | 권고 이유 승인 (재결정 …` 하나, `켬` 81 · `안 켬` 38, 다른 행 · 패널(184 ~ 280행) · 245행 == `479ad21`; 비공개 점검 (1) · (3) 0 | ✅ | ✅ green |
| 04-12-T3 | 04-12 (gap) | 11 | (WR-05 · CR-03) | T-04-34 | N/A | grep + 합계 (커밋 전) | README `expected_diagnostics.txt` 행의 줄 수 · 여섯 표의 줄 수 여섯 · 파일 표 각 행의 줄 수가 정답지에서 센 값과 같고 파일 표 합계 == 정답지 진단 줄 수; REQUIREMENTS.md RULES-13 바로 아래 `재측정 전에 먼저 고칠 것` 한 줄(그 밖은 `f5962c3` — 적힌 그대로는 04-11 의 RULES-01 · 05 완료 표시 4줄 때문에 실패, 기준을 `548e3e1` 로 바꾼 판으로 판정); DISPOSITION CR-03 `deferred` (frontmatter · 표); verify 10/10 | ✅ | ✅ green |
| 04-13-T1 | 04-13 (gap 2회차) | 12 | RULES-01 · RULES-06 | T-04-35 · T-04-36 · T-04-38 | `declaredRuleNames` 가 `linter:` 블록 안의 읽지 못하는 줄을 건너뛰지 않고 `FormatException` (70) 으로 멈춘다; 실험이 바꾼 `lib/base.yaml` 은 되돌려진다 | 단계 검사 (CI) + 깨기 실험 | M27 (`- 'avoid_print'`) · M28 (`- "prefer_mixin"`) → `[3/10]` 만 실패 rc 1 (`+ avoid_print` 겹침 1 · `+ prefer_mixin`); M29 (`- avoid_print: true`) · M30 (이름 없는 `-`) → rc 70, stdout 비어 있음, stderr `` `linter:` 블록의 106행을 읽지 못했다 ``; 옛 패턴은 `readRuleNameAt` 에만 1회이고 그 본문은 `c06d8d5` 와 같음, `tool/measure_rules.dart` == `c06d8d5`; README 04-13 소절 · M27 ~ M30 · 70 행 · `[3/10]` 설명 (`9eb8ee5` 에서 지워진 줄 2); 되돌린 `lib/base.yaml` == `6d64bee`; 보통 실행 10/10 · `--audit` 81 · 0 · 90 · 0. 실패 방향: 고치기 전 코드에서 M27 rc 0 (10/10), M29 rc 1 | ✅ | ⬜ pending |
| 04-13-T2 | 04-13 (gap 2회차) | 12 | DOCS-11 (IN-08 · IN-10) | T-04-37 | N/A | grep + 감사 (커밋 전) | `RULES.md` `sort_pub_dependencies` 행의 실측 칸 `2 (pubspec.yaml 2 — lib · test · bin 은 0)`, 헤더 그대로, `6d64bee` 와의 diff 가 그 행 하나(`<` 1 · `>` 1), 켠 규칙 표 81행; README `lib/added_rules.dart` 행 `1.3.0 부터 켜 둔 규칙 6개 …`, 옛 범위 문구 0; `--audit` 81 · 0 · 90 · 0; `--report --in …` rc 0 이고 출력 == 실측 기록; verify 10/10 · `[3/10]` 통과 | ✅ | ⬜ pending |
| 04-13-T3 | 04-13 (gap 2회차) | 12 | (WR-09) | T-04-37 | N/A | grep (커밋 전) | REQUIREMENTS.md RULES-13 바로 아래 `재측정 전에 먼저 고칠 것` 메모 둘(첫째 == `2c9c5a7` 의 CR-03 줄, 둘째에 `fixSkipped` · `measureFix` · `fixCell` · `04-REVIEW.md WR-09; 소유자 결정 2026-10-13`), 줄 수 `2c9c5a7` + 1 — 파일 전체 비교 없음(마무리가 체크박스를 고친다, 04-12-T3 의 교훈); DISPOSITION WR-09 `deferred` 세 곳(frontmatter · 표 행의 사유 · `open: 17` == `disposition: open` 수), `e89ad75` 와의 diff `<` 3 · `>` 3; verify 10/10 | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `tool/measure_rules.dart` — RULES-03 · 04 · 05 · 08 의 데이터 검사(`--report` · `--audit` 단언)를 포함해 만든다 → 04-02 (핵심 · 단계) · 04-03 (표식 · 출력 모드), wave 1 · 2
- [x] `tool/verify.dart` 의 새 단계 `[3/10] 배포 파일의 구성` — RULES-01 · 06, D-12 WR-01 의 확인 → 04-01-T1 (tracer), wave 1
- [x] `RULES.md` 의 마커 구역 넷 — RULES-06 확인의 대상 → 04-01-T1, wave 1
- 프레임워크 설치: 없음

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 후보마다 채택 / 미채택 결정 | RULES-06 (로드맵 D13) | 소유자가 정한다 — 이 phase 는 소유자 검토 없이 끝나지 않는다 (CONTEXT D-04) | 묶음마다 터미널 요약(규칙 / 경고 / `dart fix` 로 사라진 줄 / 고친 뒤 새 error / 권고 / 이유)을 보이고 "권고대로" 또는 바꿀 규칙을 받는다. strict 3개 · `unnecessary_ignore` · import 쌍 · fire-and-forget · 비호환 쌍 · 상태 출처가 갈리는 규칙은 하나씩 묻는다 |
| 사유 주석이 사실과 맞다 | RULES-07 | 문장의 사실 여부는 grep 으로 가를 수 없다 | checkpoint 에서 `lib/base.yaml` 의 규칙별 한 줄 주석과 `RULES.md` 의 켠 이유를 나란히 보인다 |
| 실측 실행 | RULES-03 · 04 · 05 | 비공개 사용 프로젝트가 있어야 돈다 — CI 에서 돌지 않는다 (D-09) | 소유자가 원본 경로를 `--source` 로 주고 로컬에서 실행. 결과의 판정은 위의 `--report` 단언이 자동으로 한다 |
| 실측 task 의 `<automated>` 재실행 (04-04-T2 · 04-04-T3 · 04-08-T2) | RULES-03 · 04 · 05 · (D-07) | 원본 경로 · 작업 폴더를 환경변수(`WOODY_MEASURE_SOURCE` · `WOODY_MEASURE_WORK`)로 받아야 돈다 — 감사 때 다시 돌리지 않았다 | 실행 기록으로 판정한다: 04-04-T2 는 고친 뒤 rc 0, 04-04-T3 은 (3b) 범위만 바꾼 판 rc 0 (`04-04-SUMMARY.md`), 04-08-T2 는 적힌 그대로 rc 0 (HEAD = `9a5176b`, `04-08-SUMMARY.md`). 그 결과물은 아래 감사의 `--report` · `--audit` · R1 JSON 단언이 지금 상태에서 다시 본다 |
| 첫 push 와 GitHub `verify` | (D-22) · RULES-01 · RULES-06 | 공개 저장소에 올리는 것은 소유자 확인(one-way)이 필요하다 | 04-10 Task 2 에서 소유자가 `push` 를 골랐다. run 38351171683 `completed success` (job 210초, 로그에 `[3/10] 배포 파일의 구성 ... 통과` · `점검 통과 (10개 중 10개)`) |

---

## 감사 기록 (2026-10-13, phase 실행 뒤)

phase 실행이 끝난 뒤(HEAD `432c7fe`) 표의 행마다 지금 상태에서 자동 점검을 실제로 돌렸다. 작업 트리를 건드리는 실험은 저장소 밖 로컬 복제본에서 했다.

**요구사항별 점검 (지금 상태) — 모두 통과**

| 행 | 돌린 것 | 결과 |
|---|---|---|
| RULES-01 · 06 · (D-12) | `fvm dart run tool/verify.dart`; 복제본에서 M23 (`lib/recommended.yaml` 에 규칙 줄) · M24 (`lib/analysis_options.yaml` 에 규칙 줄) | rc 0 · `점검 통과 (10개 중 10개)`; M23 · M24 모두 rc 1 이고 실패 단계는 `[3/10]` 하나, 출력에 그 파일 이름 |
| RULES-02 | `grep` 셋 (`lib/base.yaml`) | 0 · 0 · 0 |
| RULES-03 · 04 · 05 | `--report --in tool/measurements/2026-10-13-R1.json`; python 단언 | rc 0; 회차 52개 모두 `valid: true` 이고 필드 일곱이 다 있음, 행 133개가 참조하는 회차 모두 유효, 0줄 행 가운데 `markerDetected` 가 비어 있는 행 0, `strict-inference` 강도 `warning` · `no_dynamic_casts` · `no_raw_types` 값 있음 |
| RULES-07 | `grep -c '성능 향상'`; python 대조 | 0; `RULES.md` 켠 규칙 표 80행과 `lib/base.yaml` 80개가 같은 집합, 켠 이유 ↔ 사유 주석 불일치 0 |
| RULES-08 · DOCS-11 | `--audit` | rc 0 · `감사 통과 — 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0` |
| (D-07) | 04-10-T1 의 § 8 점검 (1) ~ (3); push 범위 전체(`79f27e5..0db0fdd`)의 추가된 줄 | (3b) 의 계획 문서 자기 패턴 줄을 뺀 판 rc 0; push 범위 전체에서 실제 홈 폴더 경로 · 임시 폴더 경로 · 이메일 · 토큰 값 0 (한 줄이 걸려 `0db0fdd` 로 고친 뒤) |
| (D-09) | `--work ./val_probe_work` (저장소 안) | rc 64, 폴더를 만들지 않음 |
| (D-10) | `example/lib` ↔ `fixtures/*/lib` 대조 (`suppress/` · `relative_imports_rule.dart` 제외, 그 파일은 패키지 이름을 맞춰 따로) | 다섯 모두 차이 0 |
| (D-20) | 복제본에서 `verify.dart --update` | rc 0 · `바뀐 정답지가 없다`, 작업 트리 변경 0 |
| (D-22) | 04-10-T3 `<automated>` | 적힌 그대로 rc 1 (마무리 커밋 `432c7fe` 때문에 로컬이 원격보다 1 앞섬), `$(git rev-parse HEAD)` 를 push 한 `0db0fdd` 로 바꾼 판 rc 0 |

**task 별 `<automated>` (복제본, 적힌 그대로)**

- HEAD 에서 돌리면 19개 모두 rc 1 이다. 대부분 0 ~ 1초 만에 끝난다. 각 task 가 자기 시점의 상태(규칙 6개, `보류 1`, 초안의 빈 결정 칸, `git log -1` 의 제목 등)를 고정해서 보기 때문이다. 뒤 plan 이 계획대로 바꾼 것이며 결함이 아니다.
- 그래서 task 마다 자기 커밋으로 되돌린 복제본에서 다시 돌렸다. **rc 0 은 8개**다: 04-01-T1 (`2956e2a`), 04-02-T1 (`78c02cb`), 04-02-T2 (`c8e873f`), 04-03-T1 (`2fa9767`), 04-03-T2 (`d0ec40e`), 04-05-T1 (`0362628`), 04-07-T3 (`ba58060`), 04-09-T2 (`2b2b475`).
- **rc 1 은 7개**이고, 모두 실행 때 기록된 단언 결함이다. 고친 판은 그때 rc 0 이었다:
  - 04-01-T2: M21 의 기호 `-` → `+` (`04-01-SUMMARY.md` Deviations 2)
  - 04-06-T1: 사유 주석만 고친 줄도 규칙 추가로 셈
  - 04-06-T2: diff 문맥 줄의 `exit` 도 셈
  - 04-06-T3 · 04-07-T1 · 04-07-T2: `relative_imports_rule.dart` 때문에 `diff -rq` 실패 (`example/README.md` 72행의 예외)
  - 04-09-T1: 평가표의 칸 맞춤을 읽지 못하는 정규식 (`04-09-SUMMARY.md` Deviations 1)
- 이번 감사의 `bash -x` 추적에서도 처음 실패한 자리가 위와 같았다.
- 다시 돌리지 않은 것은 셋이다. 04-04-T2 · 04-04-T3 · 04-08-T2 는 비공개 원본이 필요하다 (위 Manual-Only). 04-10-T1 은 executor 기록을 쓴다 (적힌 그대로 rc 1 — (3b), 고친 판 rc 0).
- 계획 파일은 고치지 않았다. 뒤 phase 가 이 명령들을 옮겨 쓸 때는 위 결함을 함께 고친다.

---

## 감사 기록 (2026-10-13, gap 수정 실행 뒤)

gap 수정 plan 04-11 · 04-12 의 실행이 끝난 뒤(HEAD `f8dc71c`) 새 행 다섯을 감사했다. 앞 감사와 같은 방식이다. task 마다 자기 커밋으로 되돌린 로컬 복제본(`git clone --local` + `git checkout --detach`)에서 `<automated>` 를 적힌 그대로 `bash -x` 로 돌렸다. 복제본은 감사 뒤 지웠다.

**task 별 `<automated>` (복제본, 적힌 그대로)**

| Task | 커밋 | rc | 걸린 시간 | 비고 |
|---|---|---|---|---|
| 04-11-T1 | `b567100` | 0 | 76초 | 복제본에 루트 `fvm dart pub get` 을 먼저 했다 (아래) |
| 04-11-T2 | `c06d8d5` | 0 | 100초 | 같음. M26 · WR-06 탐침을 다시 일으켜 같은 결과 |
| 04-12-T1 | `6d64bee` | 0 | 126초 | 같음. 헛통과 확인(`example/pubspec.yaml` 만 되돌림)까지 다시 돌았다 |
| 04-12-T2 | `fb6386a` | 0 | 80초 | — |
| 04-12-T3 | `9eb8ee5` | 1 | 0초 | 단언 결함 — `diff <(git show f5962c3:.planning/REQUIREMENTS.md) …` 구간. 04-11 의 마무리 커밋 `548e3e1` 이 RULES-01 · 05 를 완료로 표시해 4줄(체크박스 2 · 추적 표 2)이 다르다. 기준만 `548e3e1` 로 바꾼 판은 rc 0 (86초). 실행 때 executor 의 기록과 같다 (`04-12-SUMMARY.md`) |

- 복제본에는 `.dart_tool` 이 없다 (git 이 무시하는 폴더). 그래서 `fvm dart analyze` 로 시작하는 세 명령(04-11-T1 · T2, 04-12-T1)이 첫 감사에서 0 ~ 1초 만에 rc 1 이었다. 단언 결함이 아니라 준비 차이다. 루트 `fvm dart pub get` 뒤 다시 돌린 결과가 위 표다. 본 작업 폴더에는 이미 `.dart_tool` 이 있어 executor 의 실행에서는 이 차이가 없었다.
- 다섯 모두 실행 뒤 복제본의 `git status --porcelain` 이 0줄이다. 깨기 실험(M26 · 탐침 · 헛통과 확인 · 단언 (7) 의 변형 JSON)이 스스로 되돌렸다.

**지금 상태 (HEAD) — 모두 통과**

| 돌린 것 | 결과 |
|---|---|
| `fvm dart run tool/verify.dart` | rc 0 · `점검 통과 (10개 중 10개)` |
| 루트 `fvm dart analyze` | `No issues found!` |
| `--audit` | rc 0 · `감사 통과 — 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0` |
| `--report --in tool/measurements/2026-10-13-R1.json` | rc 0, 출력 == `RULES.md` 실측 기록 |
| `--recount --in …` (쓰지 않음) | `다시 센 행 133개 — 바뀐 행이 없다` |
| python 대조 | `lib/base.yaml` 81개 == `RULES.md` 켠 규칙 표 81행, 켠 이유 ↔ 사유 주석 불일치 0; `grep -c '성능 향상' lib/base.yaml` 0 |
| 04-11-T2 · 04-12-T2 `<automated>` (HEAD, 적힌 그대로) | 둘 다 rc 0 |

- 계획 파일은 고치지 않았다. 04-12-T3 의 결함은 "앞 gap plan 의 요구사항 완료 표시가 고정 커밋 비교를 깬다" 는 꼴이다. 뒤에 같은 꼴의 단언을 쓸 때는 기준 커밋을 dispatch 시점 HEAD 로 잡는다.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies (checkpoint task 6개는 소유자 결정 · 경로 입력 — Manual-Only)
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 30s (`verify.dart` 약 20초, plugin 준비 전 첫 실행만 약 69초)
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** validated 2026-10-13 (phase 실행 뒤 감사 — gap 0)

**Approval (gap 수정 뒤):** validated 2026-10-13 (04-11 · 04-12 의 task 다섯 감사 — gap 0, 04-12-T3 은 단언 결함 하나를 고친 판으로 판정)

## Validation Audit 2026-10-13

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
