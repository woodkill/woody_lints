---
spike: 021
idea: rule-reselection-measurement
name: new-rules-language-gate
type: standard
validates: "Given Dart 3.13 의 새 규칙 10개와 strict-inference 를 어기는 표식이 있고, when 같은 표식을 SDK 하한 ^3.11.1 · ^3.13.0 패키지와 flutter_starter_kit 복사본(^3.11.1, 그리고 하한만 ^3.13.0 으로 바꾼 것)에서 분석하면, then 규칙마다 언어 버전 3.11 에서 보고되는지가 갈린다"
verdict: VALIDATED
related: [019, 020]
tags: [language-version, linter-rules, strict-mode, real-consumer, marker, primary-constructors]
---

# Spike 021: new-rules-language-gate

## What This Validates

Given Dart 3.13 에 새로 생긴 규칙 10개(`no_raw_types`, `no_dynamic_casts` 포함)와 `strict-inference` 마다 그것을 어기는 표식이 있고, when 같은 표식을 언어 버전 3.11 패키지와 3.13 패키지, 그리고 `flutter_starter_kit` 의 복사본(하한 `^3.11.1`)에서 분석하면, then 규칙마다 "3.11 에서도 보고된다 / 3.13 에서만 보고된다" 가 갈린다.

ROADMAP.md Phase 4 "Spike first" 의 첫째 항목이다 — "0건이 '깨끗하다' 인지 '규칙이 동작하지 않는다' 인지가 여기서 갈린다". 셋째 항목의 나머지(복사본의 `path:` 가 **작업 중인 저장소 자체**를 가리킬 때 저장소가 바뀌지 않는가 — 019 가 재지 않고 남겼다)를 같은 실행에서 본다.

## Research

**SDK 3.13.0 CHANGELOG** (tag 3.13.4 의 `CHANGELOG.md`, 2026-10-12 읽음):

- "Dart 3.13 adds primary constructors to the language. To use this feature, set your package's SDK constraint lower bound to 3.13 or greater (`sdk: '^3.13.0'`)." — 문법 기능은 패키지의 SDK 하한(= 언어 버전)으로 켜진다.
- Linter 절의 새 규칙 7개(`async_return_with_no_await`, `empty_container_bodies`, `initialize_in_field_declaration`, `unnecessary_const_in_enum_constructor`, `unnecessary_primary_constructor_body`, `unnecessary_type_name_in_constructor`, `use_declaring_parameters`)와 experimental `use_primary_constructors` ("when Dart 3.13 primary constructor feature is enabled"), 그리고 Analyzer 절의 `no_raw_types` · `no_dynamic_casts` (`strict-raw-types` · `strict-casts` 옵션을 대신한다).
- 3.12.0 의 Language 절 "Private named parameters" 와 Linter 절 "The `prefer_initializing_formals` lint rule highlights named parameters that could be private named parameters" — 2부에서 뜻밖에 만난 것의 출처다 (→ Results 4).

**규칙 소스** (tag 3.13.4 의 `pkg/linter/lib/src/rules/<규칙>.dart`):

| 규칙 | 소스에서 읽은 것 | 추정 |
|---|---|---|
| `empty_container_bodies`, `initialize_in_field_declaration`, `unnecessary_const_in_enum_constructor`, `unnecessary_type_name_in_constructor`, `use_declaring_parameters`, `use_primary_constructors` | `registerNodeProcessors` 첫머리 `if (!context.isFeatureEnabled(Feature.primary_constructors)) return;` | 3.11 에서 돌지 않는다 (gate) |
| `unnecessary_primary_constructor_body` | 막는 조건 없음. primary constructor 몸통을 본다 | 3.13 문법이 있어야 걸린다 (syntax) |
| `async_return_with_no_await`, `no_raw_types`, `no_dynamic_casts` | 막는 조건 없음 | 3.11 에서도 걸린다 (open) |
| `prefer_initializing_formals` (기반 세트) | `_privateNamedParametersEnabled = context.isFeatureEnabled(...)` — 꺼져 있으면 private 이름은 보지 않는다 | (2부에서 만난 뒤에 읽었다) |

- `use_primary_constructors.dart` 는 자기 상태를 `state: .testing(since: .new(3, 13, 0))` 로 적는다 — 020 의 "`messages.yaml` 은 testing, `rules.json` 은 experimental" 에서 규칙 소스도 testing 쪽이다.
- 표식의 코드는 `messages.yaml` 의 각 규칙 문서에 있는 "produces this diagnostic" 예시를 옮겼다. 3.11 문법으로 쓸 수 있는 것은 그렇게 고쳐 썼다 (`enum` 의 `const` 생성자, 이름 붙은 생성자 등). `use_primary_constructors` 는 문서가 없어(`hasPublishedDocs: false`) 소스의 조건(비리다이렉트 생성자 하나)에 맞춰 썼다.

| 방법 | 장점 | 단점 | 고름 |
|---|---|---|---|
| 연습용 패키지에서 하한만 바꿔 같은 표식 분석 | 원인이 언어 버전 하나로 좁혀진다. 공개해도 되는 결과 | 실제 프로젝트의 수는 모른다 | 1부 |
| 사용 프로젝트 복사본에 같은 표식을 넣고 분석 | 실제 하한(`^3.11.1`)에서 0줄의 뜻을 가른다 | 비공개라 건수만 남는다 | 2부 B1 |
| 복사본의 하한을 올려 다시 분석 | 규칙을 채택했을 때 사용 프로젝트가 하한을 올리면 보게 될 수 | 하한을 올리는 것 자체가 다른 규칙도 바꿀 수 있다 → 대상 밖 규칙의 줄을 함께 센다 | 2부 B2 |

## How to Run

```bash
# 저장소 루트에서. 작업 폴더는 저장소와 원본 밖에 둔다. 원본은 읽기만 한다.
fvm dart .planning/spikes/021-new-rules-language-gate/probe.dart <작업 폴더> <flutter_starter_kit 원본>
```

약 65초 (1부 분석 넷이 각 0.5초, 2부 분석 셋이 각 약 20초 — 빈 상태 폴더라 plugin 준비 포함). 결과는 `results/probe-<Dart 버전>.{json,log}` 에 쓴다. 사용 프로젝트의 줄 단위 기록은 `<작업 폴더>/private/` 에만 남는다.

`consumer.dart` 는 022 · 023 이 함께 쓴다 — 복사본 만들기, `pubspec_overrides.yaml` 로 작업 중인 저장소에 물리기, 받은 자리 확인과 버리기(`ensureRepoSource`), 저장소 지문, 분석 한 번(`Shot`), 결과에서 경로 가리기.

## What to Expect

- 1부: 6개 규칙이 3.11 패키지에서 아무것도 내지 않고 3.13 패키지에서 같은 표식에 걸린다. `async_return_with_no_await`, `no_raw_types`, `no_dynamic_casts`, `strict-inference` 는 두 하한에서 같다.
- 2부: B0 의 표식 16줄이 `example/` 정답지와 같고, B1 에서 위의 6개는 표식까지 0줄, B2 에서 수백 줄.
- 판정 7건이 모두 성립하고, 소스를 읽은 추정과 다른 칸은 하나(`unnecessary_primary_constructor_body`).

## Investigation Trail

1. **조사**: CHANGELOG 에서 primary constructor 가 SDK 하한으로 켜진다는 것을 읽고, 새 규칙의 소스 10개를 받아 `Feature.` 를 grep 했다 — 6개가 기능이 꺼져 있으면 돌아간다. 추정을 스크립트의 `guess` 표에 적고 판정에는 넣지 않았다 (016 의 방식).
2. **표식을 둘로 나눴다.** 3.11 문법으로 쓸 수 있는 것(`oldSamples`)과 primary constructor 문법이어야만 쓸 수 있는 것(`newSyntaxSamples`). 뒤의 것을 3.11 패키지에서 분석하면 `experiment_not_enabled` error 가 난다 — 그 실행(p311new)은 exit 3 이고, 표식이 유효한지는 3.13 패키지(p313new)에서 본다.
3. **첫 실행에서 끝까지 갔다** (재실행 없음). 추정과 다른 칸이 하나 나왔다 — `unnecessary_primary_constructor_body` 가 3.11 패키지에서도 보고됐다. `experiment_not_enabled` error 가 난 그 파일에서 파서가 primary constructor 몸통을 읽어 냈고 규칙이 돌았다. 이 규칙에는 막는 조건이 없으므로 소스와 어긋나지 않는다 — "3.13 문법이 없으면 걸릴 자리가 없다" 는 추정이 "문법 오류인 파일에서는 걸린다" 로 좁혀진 것이다. 오류 없이 컴파일되는 3.11 프로젝트에는 이 규칙이 걸릴 코드가 없다.
4. **2부에서 뜻밖의 줄** — 복사본의 하한만 `^3.13.0` 으로 바꾼 B2 에서, 켜지도 않은 규칙 `prefer_initializing_formals` (기반 세트 `lints` recommended) 가 프로젝트에서 27줄을 냈다 (B0 · B1 은 0). 스크립트가 "대상 밖 규칙의 프로젝트 줄" 을 B0 · B1 · B2 에서 함께 셌기 때문에 보였다. 그 뒤 CHANGELOG 3.12.0 과 규칙 소스를 읽었다 — 3.12 의 private named parameters 기능이 켜지면 이 규칙이 "private named parameter 로 바꿀 수 있는 이름 붙은 매개변수" 도 보도록 넓어졌다. 줄의 자리를 하나씩 읽어 확인하지는 않았다 (비공개 프로젝트의 줄은 `private/` 에만 있다).

## Results

**판정: VALIDATED** — 규칙마다 3.11 에서 보고되는지가 갈렸다. 판정에 넣은 확인 7건이 모두 성립했다. Dart 3.13.4, `riverpod_lint` 3.1.9, 2026-10-12.

| 확인 | 결과 |
|---|---|
| K1 대조: `avoid_print` 가 두 하한의 연습용 패키지에서 걸린다 | 성립 |
| K2 대조: 3.13 패키지에서 `empty_container_bodies` 표식이 걸린다 (표식이 유효하다) | 성립 |
| K3 복사본의 `woody_lints` 가 모든 회차에서 작업 중인 저장소를 가리킨다 | 성립 |
| K4 B0 의 표식 줄이 `example/` 정답지 16줄과 같다 | 성립 |
| K5 모든 회차에서 plugin 이 준비됐다 (폴더 1, 실패 머리말 없음) | 성립 |
| K6 B1 에서 막는 조건이 없는 규칙의 표식이 걸린다 | 성립 |
| K7 저장소가 그대로다 (git status · `.dart_tool` 의 맨 위 이름 · 루트 `package_config.json` · `pubspec.lock`) | 성립 |

### 1. 규칙마다 — 언어 버전 3.11 에서 보고되는가 (1부, 연습용 패키지)

| 규칙 | 3.11 (`^3.11.1`) | 3.13 (`^3.13.0`) | 왜 |
|---|---|---|---|
| `async_return_with_no_await` | 보고 | 보고 | 막는 조건 없음 |
| `no_raw_types` | 보고 | 보고 | 막는 조건 없음 |
| `no_dynamic_casts` | 보고 | 보고 | 막는 조건 없음 |
| `strict-inference` (`inference_failure_on_*`) | 보고 | 보고 | 분석 옵션. 막는 조건 없음 |
| `empty_container_bodies` | **없음** | 보고 | primary constructor 기능이 꺼져 있으면 돌지 않는다 |
| `unnecessary_type_name_in_constructor` | **없음** | 보고 | 〃 |
| `unnecessary_const_in_enum_constructor` | **없음** | 보고 | 〃 |
| `use_primary_constructors` (testing) | **없음** | 보고 | 〃 |
| `initialize_in_field_declaration` | **없음** | 보고 (3.13 문법에서만) | 〃 + primary constructor 몸통만 본다 |
| `use_declaring_parameters` | **없음** | 보고 (3.13 문법에서만) | 〃 |
| `unnecessary_primary_constructor_body` | 문법 오류인 파일에서만 | 보고 (3.13 문법에서만) | 막는 조건은 없고 3.13 문법이 있어야 걸린다 |

- **`// @dart=3.11` 한 줄이면 3.13 패키지 안에서도 그 파일은 막힌다** (`at311/empty_container_bodies.dart` 에 아무 진단도 없었다). 막는 단위는 패키지가 아니라 라이브러리의 언어 버전이다.
- 3.13 에서 이 규칙들은 넓게 걸린다. 생성자가 없는 클래스(`class BoxMarker<T> {}`)에 `empty_container_bodies` 와 `use_primary_constructors` 가, 클래스 이름으로 선언한 생성자마다 `unnecessary_type_name_in_constructor` 가 걸렸다 (enum 생성자 포함).

### 2. 사용 프로젝트의 복사본 — 0줄의 뜻 (2부)

`flutter_starter_kit` 의 복사본(Dart 파일 469개, SDK 제약 `^3.11.1`)을 작업 중인 저장소에 물렸다. 줄 수는 표식 / 프로젝트로 나눴다.

| 규칙 | B1 표식 (하한 3.11) | B1 프로젝트 | B2 표식 (하한 3.13) | B2 프로젝트 | 읽는 법 |
|---|---|---|---|---|---|
| `async_return_with_no_await` | 1 | **30** (lib 16 · test 14) | 1 | 30 | 지금 하한에서 그대로 잰 값 |
| `strict-inference` | 1 | **106** (test 106, 전부 `inference_failure_on_function_invocation`) | 1 | 106 | 〃 |
| `no_raw_types` | 1 | 0 | 1 | 0 | 표식이 걸렸으니 **진짜 0** |
| `no_dynamic_casts` | 1 | 0 | 1 | 0 | 〃 |
| `use_primary_constructors` | **0** | 0 | 5 | **968** (lib 258 · test 707 · bin 3) | 3.11 의 0 은 **규칙이 돌지 않은 0** |
| `empty_container_bodies` | **0** | 0 | 2 | **615** (test 615) | 〃 |
| `unnecessary_type_name_in_constructor` | **0** | 0 | 4 | **281** (lib 220 · test 59 · bin 2) | 〃 |
| `unnecessary_const_in_enum_constructor` | **0** | 0 | 2 | 2 (lib 2) | 〃 |
| `initialize_in_field_declaration` | 0 | 0 | 2 | 0 | 3.13 의 0 은 진짜 0 — 프로젝트에 primary constructor 가 없다 |
| `use_declaring_parameters` | 0 | 0 | 1 | 0 | 〃 |
| `unnecessary_primary_constructor_body` | 0 | 0 | 1 | 0 | 〃 |

- B0 (원본 옵션 + 기본 표식): 16줄, 표식 16 · 프로젝트 0, `exit 2`, 20.6초 — 019 의 V2 와 같다. 이번에는 replica 가 아니라 나눈 뒤의 저장소 자체를 받았다.
- B1 은 156줄 (표식 20 · 프로젝트 136), B2 는 2,067줄 (표식 38 · 프로젝트 2,029). 세 회차 모두 plugin 폴더 1, `riverpod_lint` 3.1.9, 약 20.5초.
- B2 의 표식 38줄 = 기본 표식 16 + 새 규칙과 strict-inference 21 + 3.13 문법 표식(`use_declaring_parameters.dart` 의 `this : i = i;`)에 걸린 `prefer_initializing_formals` 1. **기본 표식 16줄은 하한을 올려도 B0 과 한 줄도 다르지 않았다** — 하한을 올린 것이 이 패키지의 지금 규칙과 plugin 진단을 바꾸지 않았다 (표식으로 본 범위).
- 새 규칙 표식에 걸린 다른 규칙(기반 세트 · 이 패키지의 규칙)은 B1 에서 없었다.

### 3. 복사본이 작업 중인 저장소 자체를 가리켜도 저장소는 그대로다

`pubspec_overrides.yaml` 의 `path:` 에 저장소 루트의 절대 경로를 적고 `dart pub get --no-example` 을 세 번(물릴 때, B2 의 하한을 바꾼 뒤) 했다. 받은 자리(`package_config.json` 의 `rootUri`, 링크를 푼 경로)는 세 회차 모두 저장소였다 (K3). 스크립트 전후로 저장소의 `git status`, `.dart_tool/` 의 맨 위 이름, 루트 `package_config.json` · `pubspec.lock` 의 해시가 같았다 (K7). 019 가 "저장소 자체를 가리킨 실행은 재지 않았다" 로 남긴 자리다 — replica 를 따로 만들 필요가 없다.

### 4. 하한을 올리는 것만으로 기반 세트의 규칙이 줄을 낸다

| 회차 | 대상(새 규칙 10 + strict-inference) 밖의 프로젝트 줄 |
|---|---|
| B0 (하한 3.11, 원본 옵션) | 0 |
| B1 (하한 3.11, 새 규칙 켬) | 0 |
| B2 (하한 3.13, 새 규칙 켬) | `prefer_initializing_formals` **27** |

`prefer_initializing_formals` 는 `lints` 6.1.0 의 recommended 에 들어 있어 지금도 켜져 있다. Dart 3.12 의 private named parameters 기능이 켜지면(언어 버전 3.12 이상) 이 규칙이 "private named parameter 로 바꿀 수 있는 이름 붙은 매개변수" 도 본다 (CHANGELOG 3.12.0, 규칙 소스의 `_privateNamedParametersEnabled`). 사용 프로젝트가 SDK 하한을 올리는 순간 이 패키지와 상관없이 생기는 줄이다.

### Phase 4 의 실측과 결정에 주는 것

- **새 규칙 6개(위 표의 "없음")는 `flutter_starter_kit` 의 지금 하한에서 0줄이 "규칙이 돌지 않은 0" 이다.** 그 하한으로 잰 0 을 평가표에 "0건" 으로 적으면 틀린다. 값은 두 개를 적는다 — 지금 하한에서(0, 돌지 않음) / 하한을 3.13 으로 올린 복사본에서(B2 의 값). 채택하면 사용 프로젝트는 하한을 올리는 날 그 줄을 한꺼번에 받는다.
- 하한을 올린 복사본의 기준선은 하한을 올린 채 다시 잰다. 하한 3.11 의 기준선(0줄)을 그대로 쓰면 `prefer_initializing_formals` 27줄이 후보 규칙의 값에 섞인다.
- `initialize_in_field_declaration`, `use_declaring_parameters`, `unnecessary_primary_constructor_body` 는 primary constructor 를 쓰는 코드만 본다. 지금의 프로젝트에서는 하한을 올려도 0 이다 (표식은 걸렸다).
- `no_raw_types`, `no_dynamic_casts` 는 지금 하한에서도 돌고 프로젝트의 줄이 0 이다 (표식이 걸린 진짜 0). strict-inference 는 `test/` 에서만 106줄이다.
- 이 spike 가 쓴 표식과 `consumer.dart` 의 방법(그 규칙을 어기는 표식, 받은 자리가 저장소가 아니면 회차를 버림)이 Phase 4 의 성공 기준 2 를 채우는 모양이다.

**놀란 것:** `prefer_initializing_formals` 27줄. 사용 프로젝트가 하한을 올리는 일은 이 패키지의 릴리스와 별개인데, CHANGELOG 의 "새로 생기는 경고" 를 하한을 올린 복사본으로 재면 이 줄이 섞인다.

**재지 않은 것:** 3.12 하한(private named parameters 만 켜지고 primary constructor 는 꺼진 자리), 학습용 프로젝트 넷, 새 규칙의 `dart fix` (→ 022), 하한을 올린 복사본에서 이 패키지의 지금 규칙 12개가 달라지는지(B2 에서 대상 밖 줄은 `prefer_initializing_formals` 하나였다 — 이 패키지의 규칙은 아니다), `prefer_initializing_formals` 27줄의 자리 하나하나, 다음 SDK.
