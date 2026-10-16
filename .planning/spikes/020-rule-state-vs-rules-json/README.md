---
spike: 020
idea: rule-reselection-measurement
name: rule-state-vs-rules-json
type: standard
validates: "Given SDK tag 3.13.4 의 rules.json 에 있는 규칙 전부를 저장소 밖 패키지(sdk ^3.13.0 · ^3.11.1)의 옵션 파일에 적고, when Dart 3.13.4 로 분석하면, then rules.json 의 state 와 실제로 보고되는 상태가 어긋나는 규칙과 incompatible_lint 쌍이 확정된다"
verdict: VALIDATED
related: [005, 013, 019]
tags: [rules-json, deprecated-lint, rule-check, incompatible-lint]
---

# Spike 020: rule-state-vs-rules-json

## What This Validates

Given SDK tag 3.13.4 의 `rules.json` (와 같은 tag 의 `messages.yaml`)에 있는 규칙 이름 전부를 옵션 파일 하나에 적은 패키지가 있고, when 그 패키지를 Dart 3.13.4 로 분석하면 (SDK 하한 `^3.13.0` 과 `^3.11.1` 두 벌), then 규칙마다 `rules.json` 이 적은 `state` 와 실제로 보고되는 상태(`deprecated_lint` / `removed_lint` / `undefined_lint`)가 같은지, 선언된 `incompatible` 쌍이 실제로 보고되는지가 확정된다.

물으려는 것은 ROADMAP.md Phase 4 Notes 의 한 문장이다 — "규칙 메타데이터는 SDK tag 고정 `rules.json` 을 기준으로 삼는다". 평가표의 열 가운데 `state` 와 "상류 세트 포함 여부" 를 이 파일에서 옮겨도 되는가. 005 는 이 파일이 `unnecessary_await_in_return` 을 `stable` 로 적었지만 실제로는 deprecated 라는 것을 찾았다 (규칙 하나만 봤다).

## Research

**상류가 이 파일에 붙인 경고.** 같은 tag 의 `pkg/linter/tool/machine/README.md` 첫머리 (2026-10-12 읽음):

> The `rules.json` file is unsupported and deprecated, and should **not** be relied on.
> … In the future, it will stop receiving updates and will be removed without notice.
> … Some of the information in the `rules.json` file is instead available in the `pkg/linter/messages.yaml` file.

`rules.json` 은 규칙 소스와 `messages.yaml` 에서 생성되고 dart.dev 사이트가 주로 쓴다고 적혀 있다. 규칙의 상태는 `messages.yaml` 의 항목마다 `state:` 블록으로 적혀 있다 (예: `unnecessaryAwaitInReturn` 의 `stable: "2.1"` · `deprecated: "3.13"`). 규칙 소스(`pkg/linter/lib/src/rules/unnecessary_ignore.dart`)에는 상태가 없다.

**상태의 종류.** `analyzer` 14.5.0 (pub cache — plugin 쪽에서 풀린 것이고 SDK 에 든 analyzer 는 14.1.0-dev 다)의 `lib/analysis_rule/rule_state.dart` 가 정의하는 것은 여섯이다 — `stable`, `experimental`, `deprecated`, `removed`, `internal` ("Dart SDK 안에서만 쓴다"), `testing` ("experimental, temporary, and have no stability guarantees … not recommended for general use").

| 출처 | 무엇 | 쓸 수 있는 것 | 한계 |
|---|---|---|---|
| `rules.json` (tag 3.13.4) | 생성된 규칙 목록 262개. `state`, `incompatible`, `sets`, `fixStatus`, `sinceDartSdk` | `incompatible` | 상류가 "믿지 말라" 고 적었다. 아래 결과대로 틀린 칸과 빈 칸이 있다 |
| `messages.yaml` (tag 3.13.4) | 진단 코드의 원본. 275개 이름(같은 규칙의 코드는 `sharedName` 으로 묶인다) | `state` 의 deprecated · removed, experimental · testing · internal 표시 | yaml 이라 줄 단위로 읽었다. stable / experimental 은 다른 출처와 갈린다 |
| 실제 분석 | 옵션 파일에 이름을 적고 `dart analyze` | deprecated · removed · 없는 이름 — 그 SDK 와 그 하한에서의 실제 | stable 과 experimental 을 가르지 못한다 (둘 다 아무 진단도 없다) |
| dart.dev 의 `linter_rules.json` (site-www `main`) | 사이트의 원본 | — | SDK `main` 을 따라간다. 3.13.4 와 다르다 (STACK.md) |
| pub cache 의 `lints` 6.1.0 · `flutter_lints` 6.0.0 YAML | 기반 세트의 실제 규칙 목록 | 상류 세트 열 | 저장소 루트가 받은 버전의 것이다 |

**고른 방법:** 세 출처를 한 스크립트에서 견준다. 실제 분석은 005 의 `make_rules_package` 모양(규칙만 적은 옵션 파일 + `sdk:` 하한을 적은 `pubspec.yaml`)을 저장소 **밖** 작업 폴더에 만든다 — 하한이 pubspec 에서 오므로 저장소 안에 둘 필요가 없다 (005 의 Constraints: pubspec 이 **없으면** 보고되지 않는다). 옵션 파일의 3행부터 규칙 하나씩이라 진단의 줄 번호로 규칙을 찾는다.

## How to Run

```bash
# 저장소 루트에서. 작업 폴더는 저장소 밖에 둔다 (상류 파일 셋을 받아 <작업 폴더>/upstream/ 에 둔다)
fvm dart .planning/spikes/020-rule-state-vs-rules-json/probe.dart <작업 폴더>
```

분석 15번(규칙 전부 × 하한 둘, 선언된 쌍마다 하나씩 12번)이 각 0.5초 안팎이다. 상류 파일을 받는 데 네트워크가 필요하다. 결과는 `results/probe-<Dart 버전>.{json,log}` 에 쓴다.

## What to Expect

- 하한 `^3.13.0` 에서 `deprecated_lint` 6, `removed_lint` 14, `undefined_lint` 12, `incompatible_lint` 10 (진단은 옵션 파일에만 나온다)
- 표에서 `rules.json` 이 실제와 다른 줄은 `unnecessary_await_in_return` 하나와, `rules.json` 에 없는데 실제로 등록된 둘(`migrate_design_widgets`, `erase_dart_type_extension_types`)
- 판정 7건이 모두 성립하고 스크립트의 종료 코드가 0

## Investigation Trail

1. **상류 파일을 먼저 읽었다.** `rules.json` 262개의 `state` 는 stable 232 · removed 14 · experimental 11 · deprecated 5 이고, `fixStatus` 는 `hasFix` 165 · `noFix` 67 · `needsFix` 26 · `needsEvaluation` 4 다 (STACK.md 의 셈과 같다). **`sets` 가 262개 모두 빈 목록이다.** machine/README.md 에서 "unsupported and deprecated" 경고를 찾았고, 상태의 원본이 `messages.yaml` 이라는 것을 알았다.
2. **첫 실행** (`results/probe-3.13.4-run1.*`) — 스크립트가 만든 이름 변환에 버그 둘이 있었다. `messages.yaml` 의 `linesLongerThan80Chars` 를 `lines_longer_than80_chars` 로 바꿔(숫자 앞의 `_` 를 빠뜨림) 없는 규칙이 하나 생겼고, 상류 YAML 의 `prefer_iterable_whereType` · `prefer_for_elements_to_map_fromIterable` (대문자가 섞인 이름 — 두 메타데이터는 소문자로 적는다)을 찾지 못했다. 둘 다 고쳤다. 이 실행의 분석 결과(진단 수와 코드)는 두 이름을 빼면 둘째와 같다.
3. **첫 실행에서 뜻밖의 칸 — `incompatible` 쌍 12개 가운데 10개만 보고됐다.** 빠진 둘(`prefer_final_locals × unnecessary_final`, `prefer_final_parameters × unnecessary_final`)은 모두 `unnecessary_final` 이 끼어 있다. 진단을 보면 `unnecessary_final` 줄에는 `prefer_final_in_for_each` 와의 충돌 하나만 붙어 있었다. 둘째 실행에서 쌍마다 둘만 켠 패키지를 따로 만들어 돌렸다 — **12쌍 모두 보고됐다.** 규칙 전부를 켠 실행에서 한 줄에 붙은 `incompatible_lint` 는 최대 1개였다. analyzer 는 규칙 한 줄에 충돌을 하나만 알린다 (원인을 소스로 확인하지는 않았다 — 두 실행의 결과로 세운 해석이다).
4. **stable / experimental 이 갈린 넷을 dart.dev 의 사이트 데이터와도 견줬다** (site-www `main` 의 `linter_rules.json`, 2026-10-12 받음). 스크립트 밖에서 한 확인이고 결과 파일에는 없다.

## Results

**판정: VALIDATED** — 물으려던 것(어긋나는 규칙과 incompatible 쌍)이 확정됐다. 판정에 넣은 확인 7건이 모두 성립했다 (대조 넷: 없는 이름 → `undefined_lint`, `unnecessary_await_in_return` → 하한 `^3.13.0` 에서만 `deprecated_lint`, `avoid_returning_null` → `removed_lint`, 둘만 켠 `prefer_single_quotes × prefer_double_quotes` → `incompatible_lint`. 그리고 옵션 파일 밖의 진단 0, 저장소 불변). Dart 3.13.4, 2026-10-12.

결과는 로드맵의 문장을 **뒤집는다** — 평가표의 `state` 열과 상류 세트 열은 `rules.json` 에서 그대로 옮기면 안 된다.

### 1. deprecated · removed — `rules.json` 은 하나가 틀렸고 `messages.yaml` 은 실제와 같다

| 규칙 | `rules.json` | `messages.yaml` | 실제 (`^3.13.0`) | 실제 (`^3.11.1`) |
|---|---|---|---|---|
| `unnecessary_await_in_return` | **stable** | deprecated (3.13) | deprecated | 진단 없음 |
| `avoid_private_typedef_functions` | deprecated | deprecated (3.13) | deprecated | 진단 없음 |
| `one_member_abstracts` | deprecated | deprecated (3.13) | deprecated | 진단 없음 |
| `prefer_final_parameters`, `avoid_null_checks_in_equality_operators`, `use_if_null_to_convert_nulls_to_bools` | deprecated | deprecated (3.11) | deprecated | deprecated |
| removed 14개 (`avoid_as`, `avoid_returning_null` …) | removed | removed | removed | removed |

- `messages.yaml` 의 deprecated 6 · removed 14 는 실제와 하나도 다르지 않다. `rules.json` 은 deprecated 를 5개로 적었다 — 005 가 찾은 그 하나다.
- **하한 `^3.11.1` (= `flutter_starter_kit` 의 하한)에서는 3.13 에 deprecated 된 셋이 아무 진단도 내지 않는다.** 사용 프로젝트 쪽에서는 그 규칙이 deprecated 라는 신호를 받지 못한다. 이 패키지의 규칙 검사(`tool/verify.dart` 의 `[2/9]`)는 저장소의 하한 `^3.13.0` 으로 돌므로 잡는다.

### 2. 이름 — `rules.json` 에 없는데 실제로 켜지는 규칙이 있다

| 이름 | `messages.yaml` | `rules.json` | 실제 |
|---|---|---|---|
| `migrate_design_widgets` | **testing** (3.13) | 없음 | 켜진다 (진단 없음) |
| `erase_dart_type_extension_types` | internal (3.3) | 없음 | 켜진다 (진단 없음) |
| `analyzer_*` 8개, `no_solo_tests`, `no_trailing_spaces`, `visit_registered_nodes` | internal | 없음 | `undefined_lint` |

- `migrate_design_widgets` 는 FEATURES.md 의 후보 표에 올라 있는 규칙이다 (3.13, 채택 1/7). tag 3.13.4 의 원본은 이 규칙을 `testing` 으로 적었다. `analyzer` 14.5.0 의 `RuleState.testing` 설명은 "안정성 보장이 없고 일반적인 사용을 권하지 않는다" 이다. dart.dev 의 사이트 데이터(`main`)는 같은 규칙을 `stable` 로 적었다.
- `rules.json` 의 이름은 소문자다 (`prefer_iterable_wheretype`). 상류 세트 YAML 은 `prefer_iterable_whereType` 으로 적고, 둘 다 analyzer 가 받는다 (소문자 이름을 적은 이 실행에 `undefined_lint` 가 없었고, 기반 세트는 대문자 이름으로 늘 켜져 있다). 이름을 견줄 때는 소문자로 맞춘다.

### 3. stable / experimental — 분석으로는 가를 수 없고, 출처끼리 넷이 다르다

experimental 규칙을 켜도 아무 진단이 없다 (`annotate_redeclares` 등 11개 모두). 이 구분은 메타데이터에만 있다. 세 출처가 갈린 규칙:

| 규칙 | `rules.json` (tag 3.13.4) | `messages.yaml` (tag 3.13.4) | dart.dev 사이트 (`main`, 2026-10-12) | 상류 세트 |
|---|---|---|---|---|
| `unnecessary_ignore` | stable | experimental (3.8) | stable | — |
| `unnecessary_underscores` | stable | experimental (3.7) | stable | `lints` recommended |
| `use_primary_constructors` | experimental | testing (3.13) | (없음) | — |
| `migrate_design_widgets` | (없음) | testing (3.13) | stable | — |

- `use_super_parameters` 는 세 출처 모두 experimental 인데 `lints` 6.1.0 의 recommended 에 들어 있다 — 지금 이 패키지를 쓰는 모든 프로젝트에서 이미 켜져 있다. "experimental 이라 채택하지 않는다" 는 기준을 세우면 기반 세트와 부딪친다.
- `unnecessary_ignore` 는 로드맵 D13 이 이름을 적은 후보다. 어느 출처를 쓰느냐에 따라 표의 `state` 가 달라진다.

### 4. 상류 세트 — `rules.json` 의 `sets` 는 전부 비어 있다

`rules.json` 262개 모두 `sets: []` 다. 상류 세트 열은 저장소 루트가 받은 YAML 에서 읽어야 한다 (STACK.md 가 이미 그렇게 적었다). `lints` 6.1.0 의 core 35, recommended 58, `flutter_lints` 6.0.0 의 flutter 10, 합 102개 이름이 두 메타데이터에 모두 있다 (대소문자를 맞춘 뒤).

### 5. incompatible — 선언은 맞다. 다만 한꺼번에 켜면 일부가 가려진다

| 실행 | 보고된 쌍 |
|---|---|
| `rules.json` 이 선언한 12쌍 | — |
| 규칙 전부를 한 파일에 켬 | 10쌍. 한 줄에 `incompatible_lint` 는 최대 1개 |
| 쌍마다 둘만 켬 | **12쌍 모두** (`incompatible_lint` 는 뒤에 적은 규칙의 줄에 붙는다) |
| 선언되지 않았는데 보고된 쌍 | 0 |

- 가려진 둘은 `unnecessary_final` 과 `prefer_final_locals` / `prefer_final_parameters` 다. `prefer_final_locals` 는 지금 `base.yaml` 에 켜져 있다.
- 후보를 한꺼번에 켠 옵션 파일에서 `incompatible_lint` 가 0 이라고 "충돌 없음" 으로 읽으면 놓칠 수 있다. 한 규칙이 둘 이상과 충돌하면 하나만 보인다. 이 실행은 메시지의 짝 이름으로 쌍을 셌다.

### Phase 4 의 평가표에 주는 것

| 열 | 출처 | 근거 |
|---|---|---|
| `state` — deprecated / removed / 없는 이름 | 후보를 적은 옵션 파일을 **저장소 하한(`^3.13.0`)의 pubspec 옆에서** 분석한 결과 (규칙 검사의 방식) | 1, 2. `rules.json` 은 하나가 틀렸다 |
| `state` — stable / experimental / testing | tag 3.13.4 의 `messages.yaml`. 출처끼리 갈리는 규칙(위 3번의 넷)은 셋을 함께 적는다 | 3. 분석으로는 가를 수 없다 |
| 상류 세트 포함 여부 | 저장소 루트의 package_config 가 가리키는 `lints` · `flutter_lints` 의 YAML | 4. `rules.json` 의 `sets` 는 비어 있다 |
| `incompatible` | `rules.json` 의 선언 (12쌍 모두 맞았다). 확인은 쌍마다 둘만 켜서 | 5 |
| `fixStatus` | → spike 022 | — |

**놀란 것:** 상류가 `rules.json` 을 스스로 "믿지 말라" 고 적어 두었다는 것, 그리고 `migrate_design_widgets` (후보 표에 있는 규칙)가 원본에서 `testing` 이라는 것. 로드맵과 조사 문서는 이 경고를 인용하지 않았다.

**재지 않은 것:** stable / experimental 이 갈린 넷의 "진짜" 상태 (분석으로 가를 수 없다), `sinceDartSdk` 의 정확성, 사이트 데이터의 나머지 규칙, 다른 SDK 에서의 결과, `messages.yaml` 의 `internal` 규칙이 왜 둘은 켜지고 나머지는 없는 이름인지.
