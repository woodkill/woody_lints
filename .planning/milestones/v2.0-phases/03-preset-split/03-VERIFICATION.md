---
phase: 03-preset-split
verified: 2026-10-12T13:17:37Z
status: passed
score: 15/15 must-haves verified
covered_files: [".github/workflows/verify.yml", ".gitignore", ".planning/phases/03-preset-split/03-01-PLAN.md", ".planning/phases/03-preset-split/03-01-SUMMARY.md", ".planning/phases/03-preset-split/03-02-PLAN.md", ".planning/phases/03-preset-split/03-02-SUMMARY.md", ".planning/phases/03-preset-split/03-03-PLAN.md", ".planning/phases/03-preset-split/03-03-SUMMARY.md", ".planning/phases/03-preset-split/03-04-PLAN.md", ".planning/phases/03-preset-split/03-04-SUMMARY.md", "CHANGELOG.md", "analysis_options.yaml", "example/README.md", "fixtures/base_codegen/analysis_options.yaml", "fixtures/base_codegen/expected_diagnostics.txt", "fixtures/base_codegen/lib/added_rules.dart", "fixtures/base_codegen/lib/base_rules.dart", "fixtures/base_codegen/lib/generated/sample.freezed.dart", "fixtures/base_codegen/lib/generated/sample.g.dart", "fixtures/base_codegen/lib/main.dart", "fixtures/base_codegen/lib/riverpod_rules.dart", "fixtures/base_codegen/lib/should_not_appear.dart", "fixtures/base_codegen/pubspec.lock", "fixtures/base_codegen/pubspec.yaml", "fixtures/base_only/analysis_options.yaml", "fixtures/base_only/expected_diagnostics.txt", "fixtures/base_only/lib/added_rules.dart", "fixtures/base_only/lib/base_rules.dart", "fixtures/base_only/lib/generated/sample.freezed.dart", "fixtures/base_only/lib/generated/sample.g.dart", "fixtures/base_only/lib/main.dart", "fixtures/base_only/lib/riverpod_rules.dart", "fixtures/base_only/lib/should_not_appear.dart", "fixtures/base_only/pubspec.lock", "fixtures/base_only/pubspec.yaml", "fixtures/base_riverpod/analysis_options.yaml", "fixtures/base_riverpod/expected_diagnostics.txt", "fixtures/base_riverpod/lib/added_rules.dart", "fixtures/base_riverpod/lib/base_rules.dart", "fixtures/base_riverpod/lib/generated/sample.freezed.dart", "fixtures/base_riverpod/lib/generated/sample.g.dart", "fixtures/base_riverpod/lib/main.dart", "fixtures/base_riverpod/lib/riverpod_rules.dart", "fixtures/base_riverpod/lib/should_not_appear.dart", "fixtures/base_riverpod/pubspec.lock", "fixtures/base_riverpod/pubspec.yaml", "fixtures/overrides/analysis_options.yaml", "fixtures/overrides/expected_diagnostics.txt", "fixtures/overrides/lib/added_rules.dart", "fixtures/overrides/lib/base_rules.dart", "fixtures/overrides/lib/generated/sample.freezed.dart", "fixtures/overrides/lib/generated/sample.g.dart", "fixtures/overrides/lib/main.dart", "fixtures/overrides/lib/riverpod_rules.dart", "fixtures/overrides/lib/should_not_appear.dart", "fixtures/overrides/lib/suppress/lint_file.dart", "fixtures/overrides/lib/suppress/lint_line.dart", "fixtures/overrides/lib/suppress/plugin_file_prefixed.dart", "fixtures/overrides/lib/suppress/plugin_file_unprefixed.dart", "fixtures/overrides/lib/suppress/plugin_line.dart", "fixtures/overrides/pubspec.lock", "fixtures/overrides/pubspec.yaml", "fixtures/recommended/analysis_options.yaml", "fixtures/recommended/lib/added_rules.dart", "fixtures/recommended/lib/base_rules.dart", "fixtures/recommended/lib/generated/sample.freezed.dart", "fixtures/recommended/lib/generated/sample.g.dart", "fixtures/recommended/lib/main.dart", "fixtures/recommended/lib/riverpod_rules.dart", "fixtures/recommended/lib/should_not_appear.dart", "fixtures/recommended/pubspec.lock", "fixtures/recommended/pubspec.yaml", "lib/analysis_options.yaml", "lib/base.yaml", "lib/codegen.yaml", "lib/recommended.yaml", "lib/riverpod.yaml", "tool/verify.dart"]
covered_digest: "v3:sha256:840d846936128c61b11ac38de9c780ccf5f17af838d52e266ca0c0dd05f3f911"
behavior_unverified: 0
overrides_applied: 0
deferred:
  - truth: "PRESET-07 의 'README 에 적힌 대로' — 지금 README 에는 끄는 방법이 없다 (fixture 쪽은 이 phase 에서 확인됨)"
    addressed_in: "Phase 5"
    evidence: "DOCS-03 'README 에 규칙을 한 줄 / 파일 / 프로젝트 단위로 끄는 방법과 plugin 진단을 끄는 방법이 있다', Phase 5 성공 기준 2 '… 재정의 방법은 Phase 3 의 fixture 가 확인한 것과 같다'"
  - truth: "새 문서가 정식 이름 package:woody_lints/recommended.yaml 을 안내한다 — README 60행은 아직 옛 주소를 안내한다"
    addressed_in: "Phase 5"
    evidence: "Phase 5 Notes 'README 는 묶음의 정식 이름 package:woody_lints/recommended.yaml 을 안내하고, 옛 이름은 \"예전 이름\"으로만 적는다', DOCS-02"
human_verification:
  - test: "성공 기준 3 후반의 범위를 확인한다 — codegen.yaml 을 받아도 생성 파일(*.g.dart)의 riverpod_lint (plugin) 진단은 보고된다"
    expected: "소유자가 '생성 파일의 진단이 보고되지 않는다' 를 Dart 3.13.4 의 규칙 진단에 대한 말로 받아들인다 (spike 012 의 읽기, 03-03 계획의 범위 문구). 받아들이지 않으면 ROADMAP 성공 기준 3 의 문구를 고치거나 Phase 5 README 에서 범위를 밝히는 일을 정한다"
    why_human: "계획이 범위를 좁혔지만 ROADMAP 의 문구는 고쳐지지 않았다. 검증자가 직접 재 보니 묶음을 받은 프로젝트의 lib/generated/plugin_violation.g.dart:4 에 warning provider_parameters 가 나왔다 (ignore_for_file: type=lint 머리를 단 같은 파일은 0줄). 1.3.0 도 같은 동작이고 이 패키지가 고칠 수 있는 것이 아니어서 판정은 문구 해석의 문제다"
  - test: "판단형(judgment-tier) 금지 사항 17건의 검증자 판정을 훑어본다 (아래 '금지 사항' 표)"
    expected: "17건 모두 '어기지 않음' 판정에 동의한다"
    why_human: "plan 의 prohibitions 가 모두 verification: judgment, status: unresolved 다. 검증자의 판정은 근거를 붙였지만 권위가 없는 LLM 판정이다 (ADR-550 D4)"
---

# Phase 3: Preset Split 검증 보고서

**Phase Goal:** 사용 프로젝트가 기본 / Riverpod / codegen 조각을 골라 include 하거나 `recommended.yaml` 묶음 한 줄로 전부 받을 수 있고, 옛 URI 한 줄을 쓰는 프로젝트는 분리 전과 똑같은 구성을 받는다
**Verified:** 2026-10-12T13:17:37Z
**Status:** human_needed
**Re-verification:** No — 첫 검증

## 검증 방법

SUMMARY 의 주장은 근거로 쓰지 않았다. 모든 실험은 HEAD 를 `git archive` 로 뽑은 복사본과, 그 옆에 따로 만든 사용 프로젝트 모양의 임시 프로젝트에서 했다 (Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, `dart analyze` — `flutter analyze` 는 쓰지 않았다). 저장소의 작업 트리는 읽기만 했고, 끝난 뒤 `git status --short --untracked-files=no` 는 `.planning/config.json` 하나뿐이었다.

1. 복사본에서 `dart run tool/verify.dart` — 종료 코드 0, `점검 통과 (9개 중 9개)` (처음 실행 67초)
2. `tool/verify.dart` 와 무관하게, 직접 만든 사용 프로젝트 7개에서 `dart --suppress-analytics analyze --format=json` (프로젝트마다 전용 상태 폴더). 샘플 소스는 `example/lib` 그대로
3. 깨 보기 12건 — 배포 파일 · fixture 옵션을 하나씩 망가뜨려 검증 명령이 실패하는지 보고, 그 경로만 되돌렸다
4. 루트 분석과 그 반대 사실(분리 전 단일 파일을 넣으면 경고가 나는지)
5. git 이력 · 원격 상태 · GitHub run 로그 확인

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | (SC1) 옛 URI 한 줄만 쓰는 `example/` 의 기대 진단이 분리 전후로 한 줄도 바뀌지 않고, `recommended.yaml` 을 include 해도 같은 진단이 나온다 | ✓ VERIFIED | `example/expected_diagnostics.txt` 의 마지막 변경은 Phase 2 의 `19ae5ec` (`git diff --quiet 19ae5ec HEAD` 통과). 직접 만든 사용 프로젝트 넷 — **분리 전 `90a2736` 의 옛 주소**, HEAD 의 옛 주소, `recommended.yaml`, 조각 셋을 목록으로 직접 include — 의 결과가 모두 정답지와 `diff` 0 (`exit 2` + 16줄, plugin 폴더 1개). 검증 명령 `[4/9]` · `[5/9]` 통과 |
| 2 | (SC2) `base.yaml` 만 include 한 대조군에서 기본 규칙 진단은 나오고, `riverpod_lint` 진단은 안 나오며, codegen 설정이 적용되지 않는다 | ✓ VERIFIED | `fixtures/base_only/expected_diagnostics.txt` = `exit 2` + 18줄: 기본 규칙 13줄, `riverpod_lint` 0줄, 생성 파일 샘플 4줄과 `lib/should_not_appear.dart:5 warning invalid_annotation_target` 이 **남아 있다**. `[6/9]` 통과. 깨 보기 E4 (`base.yaml` 이 `codegen.yaml` 을 include) 에서 `[6/9]` · `[7/9]` 가 실패 — 대조군이 헛통과가 아니다 |
| 3 | (SC3) `riverpod.yaml` 을 include 한 구성에서 `riverpod_lint` 진단이 나오고 하한이 `^3.1.9` 이며, `codegen.yaml` 을 include 한 구성에서 생성 파일의 진단이 나오지 않는다 | ✓ VERIFIED (범위: 규칙 진단) | `lib/riverpod.yaml` 10행 `riverpod_lint: ^3.1.9`, `lib/` · `fixtures/` 에 `3.1.3` 0건. `base_riverpod` 정답지에 plugin 3줄, 직접 만든 `riverpod.yaml` **단독** 프로젝트에서도 plugin 3줄. `base_codegen` = `exit 0` + 13줄, 생성 파일 줄 0. 깨 보기 E2b (`plugins:` 키 오타) → `[4/9]` · `[7/9]` 실패, E3 (`*.g.dart` 제외 삭제) → `[4/9]` · `[8/9]` · `[9/9]` 실패. **단서:** 생성 파일 안의 plugin 진단은 제외되지 않는다 (직접 측정 — Human Verification 1) |
| 4 | (SC4) 루트 `analysis_options.yaml` 에서 배포 파일 exclude 를 걷어낸 상태로 루트 분석이 경고 없이 통과한다 (`plugins_in_inner_options` 포함) | ✓ VERIFIED | 루트 exclude 는 `example/**` · `fixtures/**` 둘뿐. 복사본 루트의 `dart analyze` → `No issues found!`, 종료 코드 0, plugin 폴더 0. 반대 사실: `lib/analysis_options.yaml` 을 분리 전 64행 파일로 바꾸면 같은 명령이 `lib/analysis_options.yaml:58:3 - … plugins_in_inner_options`, 종료 코드 2 — 기준이 헛통과가 아니다 |
| 5 | (SC5) 재정의 fixture 에서 규칙 하나를 끄는 설정과 plugin 진단 하나를 끄는 설정이 각각 그 진단만 사라지게 한다 | ✓ VERIFIED | `fixtures/overrides/expected_diagnostics.txt`: 프로젝트 전체에서 끈 `prefer_final_locals` (`added_rules.dart:24`) · `missing_provider_scope` (`main.dart:5`) 만 빠지고, 같은 plugin 의 `provider_parameters` · `avoid_public_notifier_properties` 와 나머지 규칙 줄은 남는다. 파일 · 한 줄 주석으로 끈 자리는 없고 대조 줄(`lint_line.dart:6`, `plugin_line.dart:13`)과 접두사 없는 주석이 끄지 못한 줄(`plugin_line.dart:11`, `plugin_file_unprefixed.dart:8`)은 있다. 깨 보기 E5 (`diagnostics: missing_provider_scope: false` 삭제) → `[3/9]` · `[9/9]` 실패, `[9/9]` 의 차이는 "정답지에 없는데 나온 경고 (1)" |
| 6 | 조각 셋은 `90a2736` 의 단일 파일을 잘라 옮긴 것이고 내용 변경이 없다 | ✓ VERIFIED | `base.yaml` 1-41행 + `codegen.yaml` + `riverpod.yaml` + `base.yaml` 42-47행을 이어 붙여 원본과 `diff` → 58행 `^3.1.3` → `^3.1.9` 한 줄만 다르다. 정렬한 줄 집합의 차이도 그 한 줄뿐 |
| 7 | 묶음은 조각 셋을 `package:` 주소 목록으로 include 하고, 옛 주소는 묶음을 include 하는 별칭이며, 조각은 서로를 include 하지 않는다 | ✓ VERIFIED | `lib/recommended.yaml` = 머리 주석 2줄 + `include:` 목록 3개. `lib/analysis_options.yaml` = 머리 주석 2줄 + `include: package:woody_lints/recommended.yaml`. `base.yaml` 만 `flutter_lints` 를 include, `codegen.yaml` · `riverpod.yaml` 에 `include:` 없음 |
| 8 | 규칙 검사 `[2/9]` 가 새 위치(조각)의 deprecated 규칙을 잡고, 망가진 배포 파일로는 `--update` 가 정답지를 쓰지 못한다 | ✓ VERIFIED | 깨 보기 E6 (`base.yaml` 에 `unnecessary_await_in_return`) → `[2/9]` 실패, `build/woody_rule_check/base/analysis_options.yaml:40 warning deprecated_lint`. `codegen.yaml` 5행 따옴표를 깨고 `--update` → 종료 코드 1, `[2/9]` 실패, `parse_error` 줄 표시, `다른 단계가 실패해 정답지를 쓰지 않았다`, 정답지 다섯의 `shasum` 불변 |
| 9 | 검증 명령이 단계 9개를 돌려 통과하고, `recommended` 는 자기 정답지 없이 같은 실행의 `example` 결과와 견준다 | ✓ VERIFIED | 복사본 두 번 실행 모두 `점검 통과 (9개 중 9개)`, 종료 코드 0, 단계 이름이 계획과 같다. `fixtures/recommended/` 에 `expected_diagnostics.txt` 가 없다 |
| 10 | 새 fixture 가 헛통과가 아니다 (M18 · M19) | ✓ VERIFIED | E1 (묶음에서 `riverpod.yaml` include 삭제) → `[4/9] example` 실패 (`종료 코드: 정답지 2, 실제 0`, 빠진 경고 3). M18 의 기록대로 이 경우를 잡는 것은 `example` 하나뿐이다. E5 는 M19 와 같은 꼴로 `[3/9]` · `[9/9]` 실패 |
| 11 | fixture 의 plugin 선언이 조각의 선언과 같아야 통과한다 | ✓ VERIFIED | E7 (`riverpod.yaml` 만 `^3.1.8` 로) → `[3/9]` 실패, 나머지 통과 |
| 12 | 하한 상향은 파일 분리와 다른 커밋이고, 그 앞뒤로 정답지가 바뀌지 않았다 | ✓ VERIFIED | 분리 `89d6073` 의 `lib/riverpod.yaml` 은 `^3.1.3`. 상향 `166d0be` 의 파일은 `CHANGELOG.md` · `fixtures/overrides/analysis_options.yaml` · `lib/riverpod.yaml` 셋. `fixtures/*/expected_diagnostics.txt` 의 이력은 `91bbeec` · `9ed0fe5` (03-03) 뿐, `example` 정답지는 `19ae5ec` 뿐 |
| 13 | GitHub `verify` 가 fixture 여섯으로 시간 제한 안에 통과했다 | ✓ VERIFIED | `gh run list`: 38247615476 (`166d0be`) success 4m11s, 38248171220 (`79f27e5`) success 3m36s, `timeout-minutes: 10`. 38248171220 로그에 `[1/9]` ~ `[9/9]` 통과, `점검 통과 (9개 중 9개)`, `plugin riverpod_lint 3.1.9`. HEAD 와 `79f27e5` 의 차이는 `.planning/` 뿐 |
| 14 | `main` · tag · PR 이 그대로이고, workflow 는 주석 한 줄만 바뀌었다 | ✓ VERIFIED | `git ls-remote origin`: `refs/heads/main` = `90a2736`, tag 는 `v1.3.0` 하나. `gh pr list --state all` 0건. `git diff 008ea3f HEAD -- .github/workflows/verify.yml` 은 25행 주석 한 줄 |
| 15 | `example/` 의 샘플 · 설정 · 정답지와 `pubspec.yaml` 은 바뀌지 않았고, CHANGELOG 에 분리 · 별칭 · 루트 제외 · 하한 상향이 적혀 있다 | ✓ VERIFIED | `git diff --quiet` 통과: `74fafb2 -- example/lib`, `ac5cced -- example/{analysis_options.yaml,pubspec.yaml,pubspec.lock}`, `968a5bb -- pubspec.yaml`. `CHANGELOG.md` `## 2.0.0 - 미출시` 에 불릿 넷과 `### 올리기 전에` 의 옛 주소 안내 |

**Score:** 15/15 truths verified (0 present, behavior-unverified)

동작에 기대는 진실(`--update` 가 쓰지 않는다, 끈 진단만 사라진다, 대조군에서 안 나온다)은 모두 검증자가 직접 실행해 관찰했다. 존재만으로 판정한 동작 진실은 없다.

### 목표의 "골라 include" — fixture 밖의 조합

fixture 여섯이 다루지 않는 조합도 직접 재 보았다. 계획이 요구한 것은 아니고 기록이다.

| 직접 만든 사용 프로젝트 | 결과 |
|---|---|
| `riverpod.yaml` 단독 | `exit 2`, plugin 3줄 + `invalid_annotation_target` 1줄. 기본 규칙 0줄 — 조각이 `base.yaml` 없이도 plugin 을 싣는다 |
| `codegen.yaml` 단독 | `exit 0`, 0줄, plugin 폴더 0 |
| `riverpod.yaml` + `codegen.yaml` | `exit 2`, plugin 3줄만 |

### Deferred Items

| # | Item | Addressed In | Evidence |
|---|------|-------------|----------|
| 1 | PRESET-07 의 "README 에 적힌 대로" — README 에 아직 끄는 방법이 없다 | Phase 5 | DOCS-03, Phase 5 성공 기준 2 "재정의 방법은 Phase 3 의 fixture 가 확인한 것과 같다" |
| 2 | README 60행이 아직 옛 주소 `package:woody_lints/analysis_options.yaml` 을 안내한다 | Phase 5 | Phase 5 Notes "README 는 묶음의 정식 이름 … 을 안내하고", DOCS-02 |

### Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `lib/base.yaml` | 기본 규칙 조각, `flutter_lints` include | ✓ VERIFIED | 47줄, 규칙 12개 + 주석 처리 2개, 원본에서 잘라 옮김 |
| `lib/codegen.yaml` | `invalid_annotation_target: ignore` + 생성 파일 제외 2줄 | ✓ VERIFIED | 6줄 내용 (D-02) |
| `lib/riverpod.yaml` | `plugins: riverpod_lint: ^3.1.9` | ✓ VERIFIED | 최상위 `plugins:`, 범위 지정 (D-01) |
| `lib/recommended.yaml` | 조각 셋을 include 하는 묶음 | ✓ VERIFIED | `package:` 주소 목록 |
| `lib/analysis_options.yaml` | 옛 주소 별칭 | ✓ VERIFIED | include 한 줄 |
| `analysis_options.yaml` (루트) | `lib/analysis_options.yaml` 제외 없음 | ✓ VERIFIED | exclude 는 `example/**` · `fixtures/**` |
| `tool/verify.dart` | Fixture 표, 단계 9개, `[2/9]` 조각 셋, `[3/9]` 옵션 고정, `--update` 일괄 · 안전장치 | ✓ VERIFIED | 실행 · 깨 보기로 확인 (WR-01 ~ WR-03 은 아래) |
| `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/` | 옵션 파일 · 샘플 · lock · 정답지 넷 | ✓ VERIFIED | `lib/` 는 `example/lib` 와 `diff -r` 동일 (`overrides` 는 `lib/suppress/` 5파일만 더함). 옵션 파일에 `build/**` 없음, `resolution: workspace` 없음 |
| `.gitignore` | `!fixtures/*/pubspec.lock` | ✓ VERIFIED | 있음 |
| `.github/workflows/verify.yml` | 주석 한 줄만 실측값으로 | ✓ VERIFIED | `정상 약 4분 7초 (… run 38247615476)` |

### Key Link Verification

| From | To | Via | Status | Details |
|---|---|---|---|---|
| `lib/analysis_options.yaml` | `recommended.yaml` → 조각 셋 | 3단 include | ✓ WIRED | 옛 주소 프로젝트에 plugin 폴더 1개 · plugin 3줄 |
| `tool/verify.dart` `ruleCheckTargets` | `lib/{base,codegen,riverpod}.yaml` | 복사본 폴더 분석 | ✓ WIRED | E6 에서 base 의 deprecated 규칙을 잡음 |
| `tool/verify.dart` `[3/9]` | `lib/riverpod.yaml` 의 선언 | `readShippedPluginConstraint` | ✓ WIRED | E7 |
| `tool/verify.dart` `recommended` | 같은 실행의 `example` 결과 | `reference` | ✓ WIRED | `fixtures/recommended/` 에 정답지 없음, 통과 |
| `checkRuleNames` 실패 | `--update` 쓰기 막기 | `failed.isNotEmpty` | ✓ WIRED | 깨진 YAML `--update` 에서 정답지 hash 불변 |
| `.github/workflows/verify.yml` | `tool/verify.dart` | `run: dart run tool/verify.dart` | ✓ WIRED | run 로그에 단계 9줄 |

### Data-Flow Trace (Level 4)

해당 없음 — 화면에 동적 데이터를 그리는 코드가 없다. 대신 "사용 프로젝트가 받는 구성" 을 직접 만든 사용 프로젝트의 `dart analyze` 결과로 추적했다 (Truth 1 · 3, 위 조합 표).

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|---|---|---|---|
| 검증 명령 전체 | `dart run tool/verify.dart` (복사본) | exit 0, `점검 통과 (9개 중 9개)` | ✓ PASS |
| 분리 전 = 분리 후 = 묶음 | 사용 프로젝트 넷에서 `dart --suppress-analytics analyze --format=json` | 넷 모두 `example` 정답지와 diff 0 | ✓ PASS |
| 루트 분석 | 복사본 루트에서 `dart analyze` | `No issues found!`, exit 0 | ✓ PASS |
| 루트 분석 반대 사실 | 분리 전 파일을 넣고 `dart analyze` | `plugins_in_inner_options`, exit 2 | ✓ PASS (기대대로 실패) |
| `--update` 안전장치 | `codegen.yaml` 깨고 `dart run tool/verify.dart --update` | exit 1, 정답지 hash 불변 | ✓ PASS |
| E1 묶음이 riverpod 조각을 잃음 | `verify.dart` | exit 1, `[4/9]` 실패 | ✓ PASS |
| E2 riverpod 조각의 `plugins:` 섹션 삭제 | `verify.dart` | exit 70, 단계 출력 없음 (`riverpod_lint 선언을 찾지 못했다`) | ✓ PASS (빨간불이지만 단계 화면 없음) |
| E2b `plugins:` 키 오타 | `verify.dart` | exit 1, `[4/9]` · `[7/9]` 실패 | ✓ PASS |
| E3 `*.g.dart` 제외 삭제 | `verify.dart` | exit 1, `[4/9]` · `[8/9]` · `[9/9]` 실패 | ✓ PASS |
| E4 `base.yaml` 이 `codegen.yaml` 을 include | `verify.dart` | exit 1, `[6/9]` · `[7/9]` 실패 (`[2/9]` 는 통과) | ✓ PASS |
| E5 plugin 진단 끄기 삭제 | `verify.dart` | exit 1, `[3/9]` · `[9/9]` 실패 | ✓ PASS |
| E6 base 에 deprecated 규칙 | `verify.dart` | exit 1, `[2/9]` 실패 | ✓ PASS |
| E7 조각 선언만 바꿈 | `verify.dart` | exit 1, `[3/9]` 실패 | ✓ PASS |

### Probe Execution

`scripts/*/tests/probe-*.sh` 는 없고 계획도 probe 를 선언하지 않았다. 해당 없음.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|---|---|---|---|---|
| PRESET-01 | 03-03 | `base.yaml` 만으로 기본 규칙만 받는다 | ✓ SATISFIED | Truth 2 |
| PRESET-02 | 03-03 | `riverpod.yaml` 로 plugin 을 받는다 | ✓ SATISFIED | Truth 3, `riverpod.yaml` 단독 프로젝트 |
| PRESET-03 | 03-03 | `codegen.yaml` 로 생성 파일 제외 등을 받는다 | ✓ SATISFIED | Truth 3 (규칙 진단 범위 — Human Verification 1) |
| PRESET-04 | 03-01, 03-02 | 옛 URI 가 분리 전과 같은 구성을 받는다 | ✓ SATISFIED | Truth 1 — `90a2736` 으로 받은 결과와 HEAD 로 받은 결과가 줄 단위로 같다 |
| PRESET-05 | 03-04 | 하한 `^3.1.9` | ✓ SATISFIED | Truth 3 · 12 |
| PRESET-06 | 03-02 | 루트 분석이 배포 파일을 빼지 않고 경고 없이 통과 | ✓ SATISFIED | Truth 4 |
| PRESET-07 | 03-03 | 끄는 방법이 README 에 적힌 대로 동작함이 fixture 로 확인 | ✓ SATISFIED (fixture 쪽) | Truth 5. README 쪽은 Phase 5 로 미룸 (Deferred 1) |
| PRESET-08 | 03-02, 03-03 | `recommended.yaml` 한 줄로 전부 받고 옛 URI 와 같다 | ✓ SATISFIED | Truth 1 · 9 |
| VERIFY-05 | 03-03 | `base.yaml` 대조군에서 Riverpod / codegen 이 적용되지 않음 | ✓ SATISFIED | Truth 2, E4 |

REQUIREMENTS.md 가 Phase 3 에 둔 ID 는 위 9개이고 모두 어느 plan 의 `requirements` 에 있다. 고아 요구사항은 없다.

### 금지 사항 (judgment-tier prohibitions)

plan 의 prohibitions 17건은 모두 `verification: judgment` 다. 아래는 검증자의 판정이고 권위가 없다 — Human Verification 2 로 소유자 확인을 요청한다.

| Plan | 금지 사항 (요약) | 판정 | 근거 |
|---|---|---|---|
| 03-01 | `lib/` 를 바꾸지 않는다 | 어기지 않음 | `998cc32` · `533868a` 의 파일에 `lib/` 없음 |
| 03-01 | `example/` 샘플 · 정답지를 덮어쓴 채 두지 않는다 | 어기지 않음 | Truth 15 |
| 03-01 | README 에 로컬 절대 경로 · 토큰 없음 | 어기지 않음 | `git grep '/Users/\|/home/runner\|/private/tmp'` (`.planning` · `.claude` 밖) 0건 |
| 03-02 | 조각은 잘라 만들고 손으로 고치지 않는다 · 조각에 머리 주석을 더하지 않는다 | 어기지 않음 | Truth 6 (원본과 하한 한 줄만 다름) |
| 03-02 | 이 plan 에서 `^3.1.3` 을 올리지 않는다 | 어기지 않음 | `89d6073:lib/riverpod.yaml` 은 `^3.1.3` |
| 03-02 | 루트 주석 · CHANGELOG 에 SDK 에 묶인 이유("plugin 을 준비하지 않도록")를 적지 않는다 | 어기지 않음 | 두 파일에 "준비" 0건 |
| 03-02 | 묶음 · 별칭을 규칙 검사 대상에 넣지 않는다 | 어기지 않음 | `ruleCheckTargets` 는 조각 셋 |
| 03-03 | `example/` 을 바꾸지 않는다, 새 fixture 샘플은 글자 그대로 복사본 | 어기지 않음 | `diff -r` 동일, Truth 15 |
| 03-03 | 정답지는 `--update` 로 만든다, 생성 파일 샘플에 plugin 위반 없음 | 어기지 않음 (앞쪽은 이력으로만) | 정답지 머리 주석이 `--update` 형식, 생성 파일 샘플에 riverpod 0건 |
| 03-03 | fixture 에서 `flutter pub get` 금지, workspace 멤버 금지 | 어기지 않음 | 옵션 파일에 `build/**` 없음, `resolution:` 없음 |
| 03-03 | `recommended` 에 정답지 없음, 상태 폴더 합치지 않음, 접두사 없는 샘플을 고치지 않음 | 어기지 않음 | 파일 없음, `plugin` 줄이 `3.1.9`, `plugin_line.dart:10` 그대로 |
| 03-03 | 절대 경로 없음, 생성 파일 제외를 "전부 막는다" 로 적지 않음 | 어기지 않음 | 위 grep, CHANGELOG 문구 |
| 03-04 | push 는 소유자 확인 뒤 한 줄로, force 금지 | 어기지 않음 (순서는 기록으로만) | 원격 브랜치 `79f27e5` 가 HEAD 의 조상, 03-04-SUMMARY 의 checkpoint 기록 |
| 03-04 | 정답지를 이 plan 에서 다시 쓰지 않는다 | 어기지 않음 | `166d0be` · `79f27e5` 에 정답지 없음 |
| 03-04 | 정확 고정 금지, `pubspec.yaml` 에 `riverpod_lint` 금지 | 어기지 않음 | `^3.1.9`, `pubspec.yaml` 에 riverpod 0건 |
| 03-04 | PR · `main` · tag 금지, workflow YAML 설정 불변 | 어기지 않음 | Truth 14 |

### 코드 리뷰(03-REVIEW.md) 지적의 재판정

리뷰의 심각도를 물려받지 않고, "사용 프로젝트가 include 로 받는 것" 에 닿는지로 다시 판정했다. WR-01 ~ WR-03 은 복사본에서 직접 재현했다.

| ID | 재현 | 목표를 막나 | 판정 |
|---|---|---|---|
| WR-01 `[2/N]` 이 묶음 · 별칭을 보지 않음 | 재현함 — `recommended.yaml` 끝에 `linter: rules: - unnecessary_await_in_return` 을 붙이면 `점검 통과 (9개 중 9개)`, exit 0 | 아니다. 지금 두 파일은 include 줄만 담는다 (Truth 7). ROADMAP Notes 의 "새 위치(base.yaml)에서 계속 잡는다" 는 E6 으로 성립한다. 앞으로 묶음 · 별칭에 규칙을 적는 변경을 막는 장치가 없을 뿐이다 | ⚠️ WARNING — 검증 장치의 빈틈. Phase 4 · 5 에서 배포 YAML 을 고치기 전에 닫는 편이 좋다. 같은 이유로 E4 (조각이 다른 조각을 include) 도 `[2/9]` 가 아니라 정답지 비교만 잡는다 |
| WR-02 `riverpod_lint` 줄 끝 주석 / 마지막 줄바꿈 없음 → exit 70 | 재현함 — 둘 다 exit 70, 단계 화면 없음 | 아니다. 받는 구성은 그대로이고, 검증은 초록이 아니라 빨강으로 실패한다(거짓 통과가 아니다). E2 (`plugins:` 섹션 삭제) 도 같은 exit 70 이다 | ⚠️ WARNING — Phase 5 가 배포 YAML 의 주석을 고칠 때(성공 기준 5) 밟을 수 있다 |
| WR-03 `base.yaml` 의 맵 형식 규칙 → `[2/9]` 거짓 실패 | 재현함 — 12줄을 `rule: true` 로 바꾸면 `[4/9]` ~ `[9/9]` 통과, `[2/9]` 실패, exit 1 | 아니다. 지금 `base.yaml` 은 목록 형식이다. 거짓 실패라 빨강 쪽이다 | ⚠️ WARNING — Phase 4 가 기반 세트 규칙을 `rule: false` 로 끄기로 하면 검증 명령부터 고쳐야 한다 |
| WR-04 ~ WR-08, IN-01 ~ IN-06 | 재현하지 않음 | 리뷰 문구로 보아 어느 것도 받는 구성을 바꾸지 않는다 (안내 문구 · 견고성 · 공급망 고정 · 주석) | ℹ️ INFO — 03-REVIEW-DISPOSITION.md 에서 다룬다 |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|---|---|---|---|---|
| (이 phase 가 바꾼 파일 전체) | — | `TBD` / `FIXME` / `XXX` | — | 0건 |
| (이 phase 가 바꾼 파일 전체) | — | `TODO` / `HACK` / `PLACEHOLDER` | — | 0건 |
| `tool/verify.dart` | `ruleCheckTargets` | 묶음 · 별칭 미검사 (WR-01) | ⚠️ Warning | 앞으로의 회귀를 놓칠 수 있음, 지금 구성에는 영향 없음 |
| `tool/verify.dart` | `stripPlugins` · `readShippedPluginConstraint` | 한 가지 글자 모양에만 맞는 정규식 (WR-02) | ⚠️ Warning | 실패는 빨강으로 남음 |
| `tool/verify.dart` | `countDeclaredRules` | 목록 형식만 셈 (WR-03) | ⚠️ Warning | Phase 4 의 맵 형식에서 거짓 실패 |

fixture 의 `lib/` 에 있는 위반 코드는 일부러 넣은 것이라 결함으로 세지 않았다.

### Human Verification Required

#### 1. 성공 기준 3 후반 "생성 파일의 진단이 보고되지 않는다" 의 범위

**Test:** 묶음(또는 `codegen.yaml`)을 받는 프로젝트의 `lib/generated/x.g.dart` 에 `ref.watch(family([7]))` 같은 `provider_parameters` 위반을 두고 `dart analyze` 한다.
**Expected:** 검증자가 잰 결과는 `lib/generated/x.g.dart:4 warning provider_parameters` 가 **나온다** (같은 파일에 `// ignore_for_file: type=lint` 머리를 달면 0줄). 규칙 진단은 제외된다. 소유자가 성공 기준 3 을 "Dart 3.13.4 의 규칙 진단" 으로 읽는 것(spike 012, 03-03 계획의 범위 문구)에 동의하는지 정한다.
**Why human:** 계획이 범위를 좁혔지만 ROADMAP 문구는 그대로다. 1.3.0 도 같은 동작이고 plugin 쪽 `analyzer` 가 제외 패턴을 푸는 방식에서 오므로 이 패키지가 고칠 수 없다. 판정은 문구 해석의 문제다. 동의하지 않으면 ROADMAP 문구를 고치거나, Phase 5 README 에 범위를 적는 일을 정한다.

#### 2. 판단형 금지 사항 17건

**Test:** 위 "금지 사항" 표의 판정과 근거를 훑어본다.
**Expected:** 17건 모두 "어기지 않음" 에 동의한다. 03-04 의 push 순서(소유자 확인 뒤)는 원격 상태로는 fast-forward 만 확인되고, 순서 자체는 03-04-SUMMARY 의 checkpoint 기록과 대화로만 보인다.
**Why human:** prohibitions 가 `verification: judgment` 라 검증자의 판정은 권위가 없다.

### Gaps Summary

막는 gap 은 없다. 다섯 성공 기준과 계획의 진실 15개를 모두 직접 실행으로 확인했다. 분리 전 커밋(`90a2736`)으로 받은 사용 프로젝트와 HEAD 의 옛 주소 · 묶음 · 조각 셋 직접 목록이 줄 단위로 같다. 대조군과 재정의 fixture 는 깨 보기에서 실패해 헛통과가 아니다.

`human_needed` 인 까닭은 둘이다. 성공 기준 3 의 "생성 파일" 문구를 규칙 진단 범위로 읽을지 소유자의 확인이 필요하다. 그리고 판단형 금지 사항 17건은 소유자가 훑어볼 항목이다.

검증 장치의 빈틈 셋(WR-01 · WR-02 · WR-03)은 지금 사용 프로젝트가 받는 구성에는 닿지 않는다. 셋 다 배포 YAML 을 고치는 Phase 4 · 5 에서 밟을 수 있는 자리다. WR-01 만 "초록인데 틀린" 쪽(거짓 통과)이고, WR-02 · WR-03 은 "빨강인데 틀린" 쪽(거짓 실패)이다. Phase 4 를 계획할 때 먼저 닫을지 정하기를 권한다.

---

_Verified: 2026-10-12T13:17:37Z_
_Verifier: Claude (gsd-verifier)_
