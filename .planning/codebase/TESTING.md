---
last_mapped_commit: 8ac96b71e9d394c5d1dfb132814ee87379519c69
last_mapped_at: 2026-10-17
---
# Testing Patterns

**Analysis Date:** 2026-10-17

이 저장소에는 `package:test` 기반 단위 테스트가 없다 — `test/` 폴더 없음, `pubspec.yaml` 의 `dev_dependencies` 는 `markdown` · `yaml` 둘뿐 (`pubspec.yaml` 23-25행). 검증은 "연습용 프로젝트를 실제 analyzer 로 분석해 정답지와 견주는" 스냅샷(golden file) 방식의 검증 명령 `tool/verify.dart` 와, 릴리스 때의 smoke test `tool/smoke.dart` 로 한다.

## Test Framework

**Runner:**
- `tool/verify.dart` (단일 Dart 스크립트, 3223줄) — `dart analyze` 를 하위 프로세스로 돌린다.
- SDK: `.fvmrc` 의 Flutter `3.47.5` (Dart 3.13.4 — `example/expected_diagnostics.txt` 1행의 실측 줄). 실행 중 SDK 가 `.fvmrc` 와 다르면 단계 시작 전에 종료 코드 78 (`tool/verify.dart` 30행, `ensurePinnedSdk` 574행).
- Config: 연습용 프로젝트 표 `const fixtures = <Fixture>[...]` (`tool/verify.dart` 57-120행 부근) — 폴더 · 화면 라벨 · 옵션 파일의 정해진 내용 · plugin 사용 여부 · 정답지 경로.

**Assertion Library:**
- 없음. 정답지 파일(`expected_diagnostics.txt`)과의 줄 단위 다중집합 비교(건수까지)와, 파일끼리의 대조(`[3/10]`)가 단언 역할이다.

**Run Commands:**

```bash
fvm dart run tool/verify.dart                  # 전체 검증 (10단계)
fvm dart run tool/verify.dart --update         # 정답지 다섯을 실제 결과로 갱신 (로컬 전용)
fvm dart run tool/verify.dart --tag vX.Y.Z     # [3/10] 버전 일치를 tag 모드로 (tag 달기 전)
fvm dart pub get                               # pubspec.yaml 이 바뀐 뒤 먼저 한 번 (안 하면 컴파일 오류 254)
fvm dart run tool/smoke.dart <ref> [--keep]    # 릴리스 smoke test (GitHub 에서 받기)
dart run tool/verify.dart                      # CI (FVM 없이)
```

출처: `tool/verify.dart` 11-18행, `example/README.md` 「실행」, `README.md` 386행, `tool/smoke.dart` 4-6행, `.github/workflows/verify.yml` 36-37행.

커버리지 도구: 해당 없음.

## Test File Organization

**Location:**
- 연습용 프로젝트 여섯: `example/` 과 `fixtures/base_only/` · `fixtures/base_riverpod/` · `fixtures/base_codegen/` · `fixtures/recommended/` · `fixtures/overrides/`. 저장소 루트 분석은 둘을 뺀다 (`analysis_options.yaml` 8-12행).
- 각 폴더: `analysis_options.yaml` (받는 조합), `pubspec.yaml` (루트를 `path: ../..` 로 받음), `pubspec.lock` (커밋 — `.gitignore` 의 `!example/pubspec.lock`, `!fixtures/*/pubspec.lock`), `lib/` 샘플, `expected_diagnostics.txt` (정답지; `fixtures/recommended/` 만 없음).

**Naming:**
- 샘플 (각 연습용 프로젝트의 `lib/` 안, 원본은 `example/lib/`): `<분류>_rules.dart` — `added_rules.dart`, `base_rules.dart`, `bug_prevention_rules.dart`, `performance_rules.dart`, `style_rules.dart`, `strict_rules.dart`, `riverpod_rules.dart`, `relative_imports_rule.dart`, `final_parameters_rule.dart`.
- 나오면 안 되는 것: `example/lib/should_not_appear.dart` (`invalid_annotation_target` 꺼짐 확인), `example/lib/generated/sample.g.dart` · `sample.freezed.dart` (exclude 확인).
- 끄는 방법 샘플: `fixtures/overrides/lib/suppress/` 5파일 (`lint_file.dart`, `lint_line.dart`, `plugin_file_prefixed.dart`, `plugin_file_unprefixed.dart`, `plugin_line.dart`).

**Structure:**

```
example/                          # 옛 주소 (include: package:woody_lints/analysis_options.yaml)
├── analysis_options.yaml
├── expected_diagnostics.txt      # 정답지 (exit 2, 93줄)
├── pubspec.yaml / pubspec.lock
└── lib/  (원본 샘플)
fixtures/
├── recommended/    # recommended.yaml — 정답지 없음, 같은 실행의 example 결과와 견줌
├── base_only/      # base.yaml 만 (plugin 안 씀)
├── base_riverpod/  # base + riverpod
├── base_codegen/   # base + codegen (plugin 안 씀, exit 0)
└── overrides/      # 묶음 + 끄는 설정 + lib/suppress/
```

표와 줄 수는 `example/README.md` 「연습용 프로젝트 여섯」.

## Test Structure

**단계 (`tool/verify.dart` 4-9행, `example/README.md` 「검증 명령의 종료 코드」 아래 문단):**

| 단계 | 이름 | 무엇을 견주나 |
|------|------|----------------|
| `[1/10]` | `lib/` 에 `.dart` 없음 | `checkLibHasNoDart` |
| `[2/10]` | 조각 셋의 규칙 이름 | `lib/base.yaml` · `codegen.yaml` · `riverpod.yaml` 을 `plugins:` 없이 `build/woody_rule_check/` 에 복사해 `dart analyze` — 종료 코드 0 · 진단 0 이어야 함 (deprecated / removed / 없는 규칙, 겹친 규칙, 모르는 키, 깨진 YAML). 규칙을 하나도 못 세도 실패 (`checkRuleNames` 1230행) |
| `[3/10]` | 배포 파일의 구성 | analyzer 없이 파일끼리: 묶음 · 별칭이 include 만, `lib/base.yaml` ↔ 기반 세트 겹침 없음, ↔ `RULES.md` 켠 규칙 표, ↔ `README.md` `woody:readme-rules`, 조각의 최상위 키 닫힌 목록, README 의 `package:woody_lints/` 주소 · plugin 버전 · `ref:`, 줄 단위 reader ↔ `package:yaml`, tag · `pubspec.yaml` version · `CHANGELOG.md` 첫 줄 제목(↔ `package:markdown` 첫 h2) 일치 (`checkShippedComposition` 2401행) |
| `[4/10]` | 연습용 프로젝트의 옵션 파일 | 주석 · 빈 줄을 뺀 내용을 `Fixture.optionsLines` 와 통째로 (`checkFixtureOptions` 1382행). `overrides` 의 `version:` ↔ `lib/riverpod.yaml` 선언 |
| `[5/10]` ~ `[10/10]` | 연습용 프로젝트마다 | `dart analyze` 결과 ↔ 정답지. 순서 example → recommended → base_only → base_riverpod → base_codegen → overrides (`compareFixture` 2780행) |

- 한 단계가 실패해도 나머지를 모두 돌린다 (`example/README.md` 「검증 명령의 종료 코드」 아래 문단).
- 단계 앞 준비: SDK 확인, 루트와 여섯 폴더의 `pub get` (lock 강제 — 실패 시 69) (`tool/verify.dart` 19-20행, `runPubGet` 613행).

**분석 실행 형태 (`analyzeFixture`, 703-720행):**

```dart
final result = await Process.run(
  Platform.resolvedExecutable,
  ['--suppress-analytics', 'analyze', '--format=json'],
  workingDirectory: cwd,
  environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir},
);
```

- 경로 인자를 주지 않는다 — 하위 폴더를 인자로 주면 plugin 진단을 잃는다 (spike 001, 699-702행 주석).
- 상태 폴더는 `.dart_tool/woody_verify/<폴더>/` 로 fixture 마다 따로 — 합치면 plugin 폴더가 여럿이 되어 버전을 못 읽는다 (spike 014). 지우지 않는다 (지우면 다음 실행이 약 15초 더 걸림; plugin 준비 실패 뒤의 복구 수단) (`tool/verify.dart` 22-25행).
- plugin 진단은 `dart analyze` 로 본다. Flutter 3.47.5 의 `flutter analyze` 는 plugin 진단을 내지 않았다 (`README.md` 367-372행). 종료 코드 기준도 다르다 (`dart analyze` 는 `--fatal-warnings` 만 기본).

**정답지 형식 (`example/README.md` 「정답지 형식」, `example/expected_diagnostics.txt`):**

```text

# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13

# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: fvm dart run tool/verify.dart --update

exit 2
lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
lib/added_rules.dart:18  info  always_declare_return_types
```

- `exit N` 은 `dart analyze` 의 종료 코드(info 만 0, warning 2, error 3). 줄은 문자열 정렬, 칸 사이 공백 두 칸, 메시지 문구는 적지 않는다. 같은 줄이 여러 건이면 건수까지 견준다 (M10 · M11).
- 손으로 쓰지 않는다 — `--update` 로만 만든다.

**Patterns:**
- Setup: 연습용 프로젝트는 커밋된 lock 으로 `pub get` 만 한다. 그 폴더들에서 `flutter pub get` 은 쓰지 않는다 (옵션 파일에 `build/**` 제외를 써넣어 `[4/10]` 이 실패) — 손으로 받을 땐 `dart pub get` (`example/README.md` 「실행」 끝 문단).
- Teardown: `build/woody_rule_check/` 를 만들었다가 지운다 (`tool/verify.dart` 22행, `.gitignore` 의 `build/`).
- "나오지 않는다" 는 줄 수로 세지 않고, 받지 않은 설정이 적용되지 않았을 때 남는 줄로 증명한다 (`example/README.md` 「연습용 프로젝트 여섯」).

## Mocking

**Framework:** 없음.

**Patterns:**
- mock 대신 실제 SDK · 실제 analyzer · 실제 `riverpod_lint` plugin 을 쓴다. 입력을 바꾸는 방식은 "옵션 파일 조합 × 같은 샘플" 이다.
- plugin 을 쓰지 않는 fixture(`base_only`, `base_codegen`)는 plugin 폴더 0개가 정상이고, 정답지 머리 주석에 `riverpod_lint 해당 없음` 이 적힌다.

**What to Mock:** 해당 없음.

**What NOT to Mock:**
- `dart analyze` 결과 — 규칙 상태(도는지 · deprecated 인지)는 `rules.json` 이 아니라 실제 분석과 `messages.yaml` 로 정한다 (`.claude/skills/spike-findings-woody-lints/references/rule-status-check.md`).

## Fixtures and Factories

**Test Data (샘플 작성 규칙, `example/lib/style_rules.dart` 1-20행):**

```dart
// woody_lints 2.0.0 에서 새로 켠 가독성·스타일 규칙을 규칙마다 한 건씩 어긴다. 한 줄에서 규칙 하나만 걸리게 둔다.
...
/// show 로 받은 이름을 쓰는 자리 (쓰지 않으면 unused_shown_name 이 함께 걸린다).
double trigonometry() => sin(0) + cos(0);
```

- 규칙마다 위반 한 건, 한 줄에 규칙 하나. 샘플마다 `/// \`규칙이름\` — 설명.` 문서 주석.
- 언어 버전 3.13 에서 돌지 않는 규칙(`avoid_final_parameters`)은 별도 파일 `example/lib/final_parameters_rule.dart` 를 언어 버전 3.11 로 둔다.
- 생성 파일 샘플(`example/lib/generated/`)에는 plugin 위반을 두지 않는다 — `analyzer.exclude` 가 이 SDK 에서 plugin 진단에 통하지 않는다 (spike 012).

**Location:**
- 원본은 `example/lib/`. `fixtures/*/lib/` 는 글자 그대로의 복사본(줄 번호가 같아야 함). 예외: `fixtures/*/lib/relative_imports_rule.dart` 3행의 패키지 이름은 그 폴더 `pubspec.yaml` 의 `name:` — `cp` 로 덮어쓰지 말 것 (`example/README.md` 「연습용 프로젝트 여섯」).
- `pubspec.lock` 복사본은 `path` 줄만 `"../.."`.
- 샘플을 고치면 다섯 복사본과 정답지(`--update`)를 함께 고친다.

## Coverage

**Requirements:** 수치 목표 없음. 대신 네 조합(Riverpod 받음/안 받음 × codegen 받음/안 받음)이 모두 fixture 로 채워져 있어야 한다 (`example/README.md` 표).

**규칙 커버리지:** `lib/base.yaml` 의 규칙마다 샘플 위반이 있는 것이 관례 (M22 는 샘플 없는 규칙 추가가 `[3/10]` 에서만 잡힘을 보인다).

## Test Types

**Unit Tests:** 없음 (`package:test` 미사용).

**Integration Tests (`tool/verify.dart`):** 위 10단계.

**--update 안전장치 (`tool/verify.dart` 12-15행, 3121-3144행 부근, `example/README.md` 「실행」):**
- CI(`CI=true` 또는 `GITHUB_ACTIONS=true`)에서는 거부, 종료 코드 64 (M8).
- 같은 실행에서 한 단계라도 실패하면 어느 정답지도 쓰지 않고 `다른 단계가 실패해 정답지를 쓰지 않았다` + 종료 코드 1 (M12, M15 ~ M17).
- 바뀐 것만 쓰고, 쓰기 전에 바뀌는 줄(`- ` / `+ `)을 화면에 보여 준 뒤 `정답지를 썼다 (N개):` 목록을 찍는다. 갱신된 정답지의 `git diff` 가 "이 변경으로 생기거나 사라진 경고" 의 기록이다.

**일부러 깨 보기 (mutation 기록):**
- `example/README.md` 「검증이 실제로 잡아내는지 확인한 기록」 — 틀린 상태를 하나씩 만들어 검증이 실패하는지 본 기록. 표 칸: `#` (M1, M2, …) · 변경 · 실패한 단계 · 정답지와의 차이 · 종료 코드 · 항목(요구사항 · 결정 ID). M1 ~ M115 남짓, 「추가 실측 — …」 소절로 이어 쓴다 (예: M20 기반 세트와 겹침 → `[3/10]`, M29 맵 항목 → 70).
- 검증 로직을 바꾸면 새 M 번호 행을 더한다: 변경 하나씩, 실측 SDK · 날짜를 표 위에 적는다.

**CI (`.github/workflows/verify.yml`):**
- 트리거: 필터 없는 `push`(모든 브랜치 · tag), `pull_request`, `workflow_dispatch`.
- `ubuntu-latest`, `timeout-minutes: 10` (정상 약 4분 7초), `actions/checkout@v7`, `subosito/flutter-action@v2` (`flutter-version-file: .fvmrc`), 그리고 `dart run tool/verify.dart`. 판정 로직은 스크립트에만 둔다.
- tag push 에서는 `GITHUB_REF_TYPE` · `GITHUB_REF_NAME` 으로 `[3/10]` 이 tag 모드가 된다.
- `permissions: contents: read`, 같은 ref 의 앞선 실행은 취소.

**E2E / 릴리스 smoke (`tool/smoke.dart`):**
- `<ref>` 를 커밋으로 벗긴 뒤, 저장소 밖 임시 폴더에 `flutter create` 빈 프로젝트를 만들고 README 「설치」 블록대로 git 의존성을 넣어, 새 `PUB_CACHE` 로 `flutter pub get`, 두 주소(`recommended.yaml` · `analysis_options.yaml`)를 각각 새 상태 폴더에서 `dart analyze --format=json` (`tool/smoke.dart` 8-20행).
- 판정: 일부러 넣은 위반 `prefer_single_quotes`(이 패키지 규칙) · `provider_parameters`(riverpod_lint)가 두 주소 모두에 있음; include 사슬 진단(`include_file_not_found` · `included_file_warning` · `included_file_parse_error`) 없음; 종료 코드 3 인데 JSON 에 error 가 없으면 실패; lock 의 `resolved-ref` 가 기대 커밋 (`tool/smoke.dart` 22-33행).
- 저장소 안에는 아무것도 만들지 않고, 어떻게 끝나도 임시 폴더를 지운다. 쓰임새: `VERSIONING.md` 「릴리스 절차」 4 · 7단계.

**측정 도구 (`tool/measure_rules.dart`):** 테스트가 아니라 규칙 평가표용 실측 (단계 `state` · `baseline` · `groups` · `markers` · `ignore` · `fix` · `unnecessary-ignore`). 사용 프로젝트 복사본을 저장소 밖 `--work` 폴더에서 잰다. `--report` 의 단언 (1) ~ (7) 이 어긋나면 종료 코드 1 (`tool/measure_rules.dart` 1-30행).

## Common Patterns

**Async Testing:**

```dart
Future<StepResult> compareFixture({...}) async { ... }   // 단계는 Future<StepResult>
```

- 연습용 프로젝트는 차례로 분석한다(병렬 아님) — 상태 폴더 · plugin 준비 충돌 방지 (`tool/verify.dart` 54-56행 주석).

**Error Testing:**
- plugin 준비 실패는 stderr 에 `An error occurred while executing an analyzer plugin:` 가 있는지 `contains` 로 판정해 그 단계의 실패로 보고한다 (`pluginFailureHeader`, spike 002 · 008).
- `dart analyze` 종료 코드가 허용 집합(`analyzeExitCodes`) 밖이거나 JSON 을 못 읽으면 "도구가 죽었다" 로 실패 (`tool/verify.dart` 2830-2841행, 1263-1273행).
- 깨진 YAML 은 종료 코드 3 · 진단 0 으로 나오므로 형식 인자 없이 한 번 더 돌려 `parse_error` 줄을 보여 준다 (`readParseErrorLines` 1193행).

---

*Testing analysis: 2026-10-17*
