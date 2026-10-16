---
spike: 022
idea: rule-reselection-measurement
name: dart-fix-dry-run-count
type: standard
validates: "Given 후보 규칙을 켠 flutter_starter_kit 복사본이 있고, when 규칙마다 진단 수 · 묶음 dart fix --dry-run 의 수 · 단독(--code) dry-run 의 수 · 소스를 되돌리고 --apply --code 한 뒤 남은 줄을 견주면, then 평가표의 'dart fix 로 고칠 수 있는 건수' 를 어느 숫자로 적어야 하는지가 정해진다"
verdict: VALIDATED
related: [020, 021]
tags: [dart-fix, fix-status, real-consumer, bulk-fix]
---

# Spike 022: dart-fix-dry-run-count

## What This Validates

Given 후보 규칙을 켠 `flutter_starter_kit` 의 복사본이 있고, when 규칙마다 넷 — 진단 수, 규칙을 모두 켠 채 한 번 돌린 `dart fix --dry-run` 의 수(묶음 dry), `dart fix --dry-run --code=<규칙>` 의 수(단독 dry), 소스를 원본으로 되돌리고 `dart fix --apply --code=<규칙>` 한 뒤 다시 분석해 남은 그 규칙의 줄 — 을 견주면, then 평가표의 "`dart fix` 로 고칠 수 있는 건수" 를 어느 숫자로 적어야 하는지가 정해진다.

ROADMAP.md Phase 4 "Spike first" 의 넷째 항목이다 — "fix 가능으로 표기된 규칙이 실제로 `dart fix` 로 고쳐지는지 (`dart fix --dry-run`). `sort_pub_dependencies` 는 출처마다 `hasFix` 와 `needsFix` 로 어긋난다."

## Research

**`dart fix --help`** (Dart 3.13.4): `-n, --dry-run` (바꾸지 않고 미리 보기), `--apply`, `--code=<code1,code2,...>` (진단 코드 하나 또는 여럿만). dry-run 의 출력은 파일 경로 줄 아래에 `  <코드> - N fix(es)` 줄이 붙는 모양이고, 맨 위에 `N proposed fixes in M files.` 한 줄이 있다. apply 는 `N fixes made in M files.` 를 찍는다. 종료 코드는 고칠 것이 있어도 0 이었다.

**`fixStatus` 와 `dart fix` 는 같은 것을 말하지 않는다.** tag 3.13.4 의 `pkg/analysis_server/lib/src/services/correction/fix_internal.dart` 가 lint 코드마다 고치는 방법(producer)을 등록하고, 등록에 일괄 적용 여부가 붙어 있다 — 예: `alwaysPutControlBodyOnNewLine: [UseCurlyBraces.nonBulk]`, `alwaysSpecifyTypesAddType: [AddTypeAnnotation.bulkFixable]`, `asyncReturnWithNoAwait: [AddAwait.return_]`, `discardedFutures: [AddAsync.discardedFutures, WrapInUnawaited.new]`. `dart fix` 는 일괄 적용할 수 있는 것만 쓴다 (IDE 의 빠른 수정은 하나씩 쓸 수 있다). `rules.json` 의 `hasFix` 는 "등록이 있다" 는 데까지다. 등록의 일괄 적용 여부를 규칙마다 소스로 확인하지는 않았다 — 아래의 실행 결과가 그것을 대신한다.

| 출처 | `sort_pub_dependencies` 의 fix | 날짜 |
|---|---|---|
| `rules.json` (tag 3.13.4) | `needsFix` | — |
| `fix_internal.dart` (tag 3.13.4) | 등록 없음 | — |
| dart.dev 의 `linter_rules.json` (site-www `main`) | `hasFix` | 2026-10-12 받음 |

로드맵의 "출처마다 `hasFix` 와 `needsFix` 로 어긋난다" 는 tag 와 사이트(`main`)의 차이다. Dart 3.13.4 의 `dart fix` 는 이 규칙을 고치지 않는다 (아래 2부 — 진단 2, dry-run 0).

| 방법 | 무엇을 세나 | 장점 | 단점 |
|---|---|---|---|
| 규칙을 모두 켜고 `dart fix --dry-run` 한 번 (묶음 dry) | 일괄 적용을 되풀이한 결과의 규칙별 수 | 한 번에 끝난다 (복사본에서 15 ~ 28초) | 한 수정이 다른 규칙의 진단을 새로 만들거나 없앤다 (1부) |
| 규칙마다 `--dry-run --code=<규칙>` (단독 dry) | 그 규칙만 고칠 때의 **수정 수** | 다른 규칙과 섞이지 않는다 | 규칙 하나에 6 ~ 17초 (중앙값 6.9초). 수정 수가 사라지는 진단 수가 아니다 (2부) |
| 소스를 되돌리고 `--apply --code=<규칙>` 뒤 다시 분석 | 실제로 사라진 줄, 새로 생긴 다른 진단 | "고칠 수 있다" 를 결과로 본다 | 규칙 하나에 약 30초 (복사 · `pub get` · apply 7 ~ 18초 · 분석 20초) |

**고른 방법:** 셋을 같은 복사본에서 모두 돌려 견준다. 묶음 dry 는 묶음마다 한 번, 단독 dry 는 진단이나 묶음 dry 가 0 이 아닌 규칙마다(61번 — 진단이 있는 58개 + 진단은 0 인데 묶음 dry 에만 나온 G4 의 셋), apply 는 시간 때문에 아홉 규칙만 한다 (단독 dry 와 진단이 다른 규칙 넷 + 수가 큰 규칙).

## How to Run

```bash
# 저장소 루트에서. 작업 폴더는 저장소와 원본 밖에 둔다. 원본은 읽기만 한다.
fvm dart .planning/spikes/022-dart-fix-dry-run-count/probe.dart <작업 폴더> <flutter_starter_kit 원본>
# K5 (저장소 불변) 의 원인을 가른 대조 — 약 45초
fvm dart .planning/spikes/022-dart-fix-dry-run-count/repo_guard.dart <작업 폴더> <flutter_starter_kit 원본>
```

`probe.dart` 는 약 15분이다 (분석 13번 · dart fix 75번). 결과는 `results/probe-<Dart 버전>.{json,log}`, 대조는 `results/repo_guard-<Dart 버전>.json`. dart fix 의 화면 그대로는 `<작업 폴더>/private/` 에만 남는다 (비공개 프로젝트의 파일 경로가 들어 있다). 공용 조각은 `../021-new-rules-language-gate/consumer.dart` 이고, 표식은 021 의 `oldSamples` 를 import 한다.

켠 규칙 119개는 FEATURES.md 의 후보 표에 이름이 있는 규칙 가운데 Dart 3.13.4 에서 켜지고(020 의 실제 상태) 기반 세트와 `lib/base.yaml` 에 없는 118개에, 021 이 잰 `use_primary_constructors` (후보 표에는 없다)를 더한 것이다. 비호환 쌍(020)이 갈리도록 묶음 넷으로 나눴다 — G1 106개, G2 4개(G1 과 비호환인 쪽), G3 2개(`base.yaml` 의 `prefer_single_quotes` · `prefer_final_locals` 와 비호환인 쪽), G4 7개(언어 버전 3.13 에서만 도는 규칙 — 021. 복사본의 하한을 `^3.13.0` 으로 올렸다).

## What to Expect

- 1부: 묶음 dry 와 단독 dry 가 갈리는 규칙이 있다 (`unnecessary_type_name_in_constructor` 3 대 4, `use_declaring_parameters` 3 대 0).
- 2부: `hasFix` 인데 dart fix 가 0 인 규칙 다섯, 단독 dry 와 진단 수가 다른 규칙들, apply 가 다른 진단(일부는 error)을 만드는 규칙들.
- 판정 다섯 가운데 K5 는 첫 실행에서 깨진다 — 아래 Investigation Trail 3.

## Investigation Trail

1. **연습용 패키지로 출력 모양을 먼저 봤다.** 021 의 3.13 패키지를 복사해 `dart fix --dry-run` 을 돌리자, 진단이 하나도 없는 `use_declaring_parameters` 에 수정 3건이 잡혔다. `use_primary_constructors` 의 수정이 클래스를 primary constructor 로 바꾸면 그 매개변수에 `use_declaring_parameters` 진단이 새로 생기고, dart fix 가 그것까지 이어서 고친 것이다. 그래서 묶음 dry · 단독 dry · apply 를 함께 재기로 했다.
2. **dart fix 는 plugin 을 준비하지 않는다.** 실행마다 빈 상태 폴더를 줬다. dart fix 는 그 폴더에 `.analysis-driver` 등을 쓰지만(복사본에서 항목 9,000 ~ 16,000개) `.plugin_manager` 는 만들지 않았다. 같은 옵션의 `dart analyze` 는 만들었다 (plugin 폴더 1). `riverpod_lint` 의 진단은 dart fix 의 출력에 없었다 (표식의 plugin 진단 3줄).
3. **K5 (저장소가 그대로다) 가 깨졌다 — 원인은 이 실행 밖이었다.** `probe.dart` 가 도는 동안(약 15분) 다음 spike 023 의 스크립트를 저장소 안 `.planning/spikes/023-existing-ignore-comments/` 에 새로 만들었고, 그 폴더가 `git status` 의 지문을 바꿨다. 저장소의 `.dart_tool/` · 루트 `package_config.json` · `pubspec.lock` 의 시각은 실행 전 날짜 그대로였다. 추정으로 끝내지 않고 `repo_guard.dart` 를 따로 돌렸다 — 저장소를 건드리지 않는 동안 복사 · `pub get` (path: 저장소) → 하한 `^3.13.0` 의 `pub get` → `dart analyze` → `dart fix --dry-run` → `dart fix --apply --code=use_primary_constructors` → 원래 하한의 `pub get` 을 한 단계씩 하고 그때마다 지문을 견줬다. **여섯 단계 모두 저장소가 그대로였다** (`results/repo_guard-3.13.4.json`). 멈춤 조건("복사본의 `pub get` 이나 분석이 작업 중인 저장소를 바꾸면 멈춘다")에 해당하지 않는다. `probe.dart` 를 다시 돌리지는 않았다 — 저장소 밖의 수치는 K5 와 상관없다.
4. 첫 실행이 끝까지 갔다 (재실행 없음). 판정에 넣지 않은 수치를 해석할 때 0 은 다루지 않았다 — 이 spike 에는 후보 규칙마다의 표식이 없다 (진단도 묶음 dry 도 0 인 58개 규칙은 "0 의 뜻을 가르지 않았다").
5. 결과를 정리하며 `rows` 가 119개인 것을 보고 후보 표의 118개와 견줬다 — 더 들어간 하나는 G4 에 넣은 `use_primary_constructors` 다 (FEATURES.md 의 후보 표에 없다).

## Results

**판정: VALIDATED** — "고칠 수 있는 건수" 를 어느 숫자로 적어야 하는지가 정해졌다. 판정에 넣은 확인 5건 가운데 4건이 첫 실행에서 성립했고, K5 는 이 실행 밖의 원인(Investigation Trail 3)으로 깨졌다가 `repo_guard.dart` 로 다시 확인했다. Dart 3.13.4, `riverpod_lint` 3.1.9, 2026-10-12.

| 확인 | 결과 |
|---|---|
| K1 1부 대조: 단독 dry 의 수가 그 규칙의 진단 수와 같다 (`use_primary_constructors` 4 = 4) | 성립 |
| K2 2부의 모든 분석에서 `woody_lints` 가 작업 중인 저장소를 가리켰다 | 성립 |
| K3 2부의 모든 분석에서 `example/` 정답지 16줄이 표식의 줄에 모두 들어 있다 | 성립 |
| K4 2부의 모든 분석에서 plugin 이 준비됐다 | 성립 |
| K5 저장소가 그대로다 | 첫 실행 **깨짐** → `repo_guard.dart` 의 여섯 단계 모두 성립 |

### 1. 묶음 dry 는 쓰지 않는다 — 규칙끼리 섞인다 (1부, 연습용 표식, 언어 버전 3.13)

| 코드 | 진단 | 묶음 dry | 단독 dry | 묶음 apply 뒤 진단 |
|---|---|---|---|---|
| `use_primary_constructors` | 4 | 4 | 4 | 0 |
| `empty_container_bodies` | 2 | 2 | 2 | 0 |
| `unnecessary_type_name_in_constructor` | 4 | **3** | 4 | 0 |
| `use_declaring_parameters` | **0** | **3** | 0 | 0 |
| `unnecessary_const_in_enum_constructor` | 1 | 1 | 1 | 0 |
| `async_return_with_no_await` | 1 | 0 | 0 | 1 |
| `no_raw_types`, `no_dynamic_casts` | 1 · 1 | 0 · 0 | 0 · 0 | 1 · 1 |

- 묶음 dry 는 "13 proposed fixes" 이고 apply 도 "13 fixes made" 다. 그 13 은 진단 13줄(`async_return_with_no_await` · `no_raw_types` · `no_dynamic_casts` 를 빼면 11줄)과 같은 것이 아니다 — 한 규칙의 수정이 다른 규칙의 진단을 지우고(`unnecessary_type_name_in_constructor` 의 하나) 새로 만든다(`use_declaring_parameters` 셋).
- 2부에서도 같다. `omit_obvious_local_variable_types` 진단 236 · 단독 dry 236 · 묶음 dry **12** (`omit_local_variable_types` 의 수정이 먼저 덮는다), `directives_ordering` 163 · 160 · **261**, `prefer_double_quotes` 20,353 · 20,353 · **40,707** (`base.yaml` 의 `prefer_single_quotes` 와 서로를 되고친다), G2 의 묶음 dry 에는 후보도 아닌 `undefined_identifier` 59 · `no_leading_underscores_for_local_identifiers` 228 의 수정이 섞였다.

### 2. `hasFix` 는 "dart fix 가 고친다" 가 아니다 (2부)

`rules.json` 이 `hasFix` 로 적었는데 진단이 있고 dart fix(단독 dry)가 0 인 규칙:

| 규칙 | 진단 | 단독 dry |
|---|---|---|
| `always_put_control_body_on_new_line` | 398 | 0 (`UseCurlyBraces.nonBulk`) |
| `async_return_with_no_await` | 30 | 0 |
| `discarded_futures` | 11 | 0 |
| `prefer_foreach` | 3 | 0 |
| `unreachable_from_main` | 2 | 0 |

`needsFix` · `noFix` 인 규칙은 모두 0 이었다 (`sort_pub_dependencies` 2 → 0 포함). 반대 방향(`needsFix` 인데 고쳐진 것)은 없었다. `migrate_design_widgets` 는 `rules.json` 에 없지만(020) 단독 dry 159 = 진단 159 다.

### 3. 단독 dry 의 수는 "수정 수" 다 — 사라지는 진단 수와 다를 수 있다 (2부, apply)

소스를 원본으로 되돌리고 규칙 하나만 `--apply --code=` 한 뒤 다시 분석했다. "다른 코드의 증감" 은 같은 묶음을 켠 분석과 견준 것이다.

| 규칙 | 진단 | 단독 dry | apply 뒤 남은 그 규칙 | 사라진 줄 | apply 뒤 다른 코드의 증감 |
|---|---|---|---|---|---|
| `always_put_required_named_parameters_first` | 32 | **16** | 0 | 32 | `lines_longer_than_80_chars` +3 |
| `avoid_redundant_argument_values` | 123 | **155** | 0 | 123 | `unnecessary_lambdas` +1 |
| `comment_references` | 196 | **10** | 96 | 100 | `migrate_design_widgets` +1, `unused_import` +1, `unnecessary_import` +2 |
| `diagnostic_describe_all_properties` | 123 | 46 | 0 | 123 | **error 148** (`undefined_method` 77, `undefined_class` 40, `creation_with_non_type` 31), `lines_longer_than_80_chars` +32 |
| `always_specify_types` | 9,382 | 8,913 | 469 | 8,913 | **error** `ambiguous_import` 5 · `argument_type_not_assignable` 1, `unnecessary_import` +36, `implementation_imports` +3, `specify_nonobvious_local_variable_types` −4,070 |
| `specify_nonobvious_local_variable_types` | 4,103 | 4,070 | 33 | 4,070 | **error** `ambiguous_import` 3 · `argument_type_not_assignable` 1, `unnecessary_import` +4, `implementation_imports` +1, `always_specify_types` −4,070 |
| `use_primary_constructors` (하한 3.13) | 969 | 969 | 0 | 969 | `use_declaring_parameters` +332, `initialize_in_field_declaration` +30, `prefer_const_constructors_in_immutables` +3, `unnecessary_type_name_in_constructor` −249, `unnecessary_const_in_enum_constructor` −2 |
| `prefer_double_quotes` (G3) | 20,353 | 20,353 | 0 | 20,353 | `prefer_single_quotes` **+20,352** |
| `unnecessary_final` (G3) | 6,709 | 6,709 | 0 | 6,709 | `prefer_final_locals` **+6,263** |

- **수정 하나가 진단 여럿을 지우거나(16 → 32, 10 → 100), 진단 하나에 수정이 여럿 붙는다(155 → 123).** 단독 dry 의 수를 "고칠 수 있는 진단 수" 로 적으면 틀린다.
- **apply 가 코드를 깨뜨리는 규칙이 있다.** `diagnostic_describe_all_properties` 는 import 되지 않은 이름을 써서 error 148줄을 만들었다. `always_specify_types` · `specify_nonobvious_local_variable_types` 는 타입 이름을 쓰려고 import 를 더하다 `ambiguous_import` error 를 남겼다. 이 셋의 dart fix 결과는 "자동으로 고쳐진다" 가 아니라 "고친 뒤 손볼 곳이 생긴다" 다.
- `base.yaml` 의 규칙과 반대인 규칙(G3)은 고친 만큼 반대 진단이 생긴다. 사용 프로젝트가 프리셋 규칙을 끄지 않고는 쓸 수 없다 (020 의 비호환 쌍).

### 4. 걸린 시간 (복사본, Dart 파일 469개)

| 실행 | 시간 |
|---|---|
| `dart analyze` (빈 상태 폴더, plugin 준비 포함) | 약 20초 |
| 묶음 dry (G1 106개 · G2 4개 · G3 2개 · G4 7개) | 28.5 · 24.6 · 28.2 · 15.1초 |
| 단독 dry (61번) | 5.9 ~ 17.2초, 중앙값 6.9초 |
| apply 한 번 (`--code`) | 7.5 ~ 17.7초 |

### Phase 4 의 평가표에 주는 것

| 열 | 값 | 근거 |
|---|---|---|
| "`dart fix` 로 고칠 수 있는 건수" | 소스를 원본으로 둔 복사본에서 그 규칙만 `dart fix --apply --code=<규칙>` 한 뒤 다시 분석해, **사라진 그 규칙의 줄 수** | 3. 단독 dry 의 수는 수정 수다 |
| 함께 적을 것 | apply 뒤 새로 생긴 다른 진단 — 특히 error 의 수 | 3. 셋이 error 를 만든다 |
| 쓰지 않는 것 | `rules.json` 의 `fixStatus` (등록 여부일 뿐), 묶음 dry 의 수 (규칙끼리 섞인다) | 1, 2 |
| 언어 버전 3.13 에서만 도는 규칙 | 하한을 올린 복사본에서 같은 방법으로 (021) | 3 의 `use_primary_constructors` |

- 후보마다 apply 를 하면 규칙 하나에 약 30초다. 이번 2부에서 진단이 0 이 아닌 규칙이 58개, 그중 `hasFix` 가 40개, 단독 dry 가 0 이 아닌 것이 36개였다 — 36개를 apply 하면 20분 남짓이다.
- 단독 dry 는 apply 전에 "0 인지" 를 가르는 데는 쓸 수 있다 — 이번 아홉 규칙에서 단독 dry 가 0 이 아니면 apply 도 그 규칙의 줄을 줄였다. 0 이면(위 2의 다섯) apply 할 것이 없다.
- `riverpod_lint` 의 진단은 dart fix 로 고쳐지지 않는다 (plugin 을 준비하지 않는다 — Dart 3.13.4).

**놀란 것:** 단독 dry 와 실제로 사라진 줄이 두 방향으로 다 어긋난 것, 그리고 dart fix 가 error 를 남긴 셋. "fix 가능" 을 한 숫자로 적으면 사용 프로젝트를 올릴 때 일을 적게 잡는다.

**재지 않은 것:** 아홉 규칙 밖의 apply, 진단이 0 인 58개 규칙의 0 의 뜻(이 spike 에는 규칙마다의 표식이 없다), dart fix 를 두 번 돌렸을 때 결과가 흔들리는지(G3 의 반대 쌍 말고), `discarded_futures` 등의 빠른 수정을 IDE 에서 하나씩 쓸 때, 다른 SDK.
