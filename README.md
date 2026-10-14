# woody_lints

Flutter 프로젝트가 `analysis_options.yaml` 의 `include` 한 줄로 받는 analyzer 설정 패키지다. `flutter_lints` 의 기반 세트 위에 이 패키지가 더 켜는 규칙(이름은 아래 「받는 규칙」)과, Riverpod 프로젝트를 위한 `riverpod_lint` plugin · 코드 생성(freezed · json_serializable)을 위한 설정을 준다. 규칙마다 켠 이유와 실측 건수는 [`RULES.md`](RULES.md) 에 있다.

## 요구 SDK

Dart 3.13 이상(Flutter 3.47 이상)이 필요하다. 이 패키지의 `pubspec.yaml` 이 `sdk: ^3.13.0` 이라, 그보다 낮은 SDK 를 쓰는 프로젝트에서는 `flutter pub get` 이 SDK 버전이 맞지 않는다며 실패한다. Dart 3.13 미만인 프로젝트는 `ref: v1.3.0` 에 머문다.

## 설치

사용 프로젝트의 `pubspec.yaml` 에서 `dev_dependencies:` 아래에 이 저장소를 tag 로 적는다.

```yaml
dev_dependencies:
  woody_lints:
    git:
      url: https://github.com/woodkill/woody_lints.git
      ref: v2.0.0
```

그리고 패키지를 받는다.

```sh
flutter pub get
```

받았는지는 `pubspec.lock` 으로 확인한다. `woody_lints` 항목이 생기고, 그 안에 `source: git` 과 받은 커밋(`resolved-ref`)이 적힌다. 패키지는 pub cache 에 놓이므로 프로젝트 폴더 안에는 새 폴더가 생기지 않는다.

받은 뒤에는 아래 「프리셋 고르기」에서 고른 include 를 프로젝트 루트의 `analysis_options.yaml` 에 적는다.

명령에 대한 메모 둘.

- 이 문서의 설치 · 버전 올리기 실측(spike 015)은 `dart pub get` / `dart pub upgrade` 로 했다. 두 명령(`dart pub` 과 `flutter pub`)이 같은 `pubspec.lock` 과 패키지 목록을 만든 것은 확인했다(spike 004). "같은 pub 이 돈다" 는 그 일치에서 읽은 추론이다.
- `flutter pub get` 은 Flutter 프로젝트의 옵션 파일에 `build/**` 와, 프로젝트에 있는 플랫폼 폴더(`android/**` 등)의 제외 줄을 덧붙인다. Flutter 3.47.5 의 `AnalysisOptionsMigration` 이 하는 일이고, 끄는 옵션은 없으며, 이미 제외되어 있으면 덧붙이지 않는다. 이 패키지의 문제가 아니다. 상류에 이 동작을 고치는 변경이 있다 — [flutter#191151](https://flutter.googlesource.com/mirrors/flutter/+/c7a822e59b5b37c4fa74f0cc71e9d1f4e25ac7ff) (병합 여부는 확인하지 않았다).

## 프리셋 고르기

이 패키지는 옵션 파일을 다섯 준다. 조각 셋(`base.yaml` 기본 규칙, `riverpod.yaml` Riverpod plugin, `codegen.yaml` 코드 생성 설정), 셋을 한 번에 받는 묶음 `recommended.yaml`, 그리고 예전 이름이다. 프로젝트가 Riverpod 과 코드 생성을 쓰는지로 고른다.

| | 코드 생성을 쓴다 | 코드 생성을 쓰지 않는다 |
|---|---|---|
| **Riverpod 을 쓴다** | `recommended.yaml` (묶음) | `base.yaml` + `riverpod.yaml` |
| **Riverpod 을 쓰지 않는다** | `base.yaml` + `codegen.yaml` | `base.yaml` |

사용 프로젝트 루트의 `analysis_options.yaml` 에 아래 블록 가운데 하나를 적는다. 블록은 이 저장소의 연습용 프로젝트(`fixtures/`)가 쓰는 옵션 파일과 글자가 같다. 블록 아래에 적은 "받는 것" 은 그 연습용 프로젝트의 정답지로 확인한 것이다 (Dart 3.13.4). 묶음(`recommended`)에는 자기 정답지가 없다 — 검증 명령이 그 결과를 같은 실행의 `example/` (옛 주소로 같은 구성을 받는 연습용 프로젝트) 결과와 견주고, `example/` 은 자기 정답지와 견준다.

### 묶음 — Riverpod 과 코드 생성을 모두 쓴다

```yaml
include: package:woody_lints/recommended.yaml
```

기본 규칙, `riverpod_lint` plugin, 코드 생성 설정을 모두 받는다.

### 기본만

```yaml
include: package:woody_lints/base.yaml
```

`riverpod_lint` 진단은 나오지 않는다. freezed · json_serializable 의 어노테이션을 쓰면 `invalid_annotation_target` 이 warning 으로 나오고, 생성 파일(`*.g.dart` 등)에서도 규칙 진단이 나온다.

### 기본 + Riverpod

```yaml
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml
```

`riverpod_lint` plugin 이 돈다. 코드 생성 설정은 받지 않으므로 "기본만" 처럼 `invalid_annotation_target` 과 생성 파일의 규칙 진단이 나온다.

### 기본 + codegen

```yaml
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/codegen.yaml
```

`invalid_annotation_target` 이 꺼지고 생성 파일의 규칙 진단이 나오지 않는다 (Dart 3.13.4 의 결과 — SDK 에 따라 다르다, 아래 「생성 파일 제외」). plugin 은 받지 않는다.

### 예전 이름과 돌려 본 범위

`package:woody_lints/analysis_options.yaml` 은 **예전 이름**이다. 묶음 `recommended.yaml` 과 같은 구성이고, 그 한 줄을 쓰는 프로젝트는 고칠 것이 없다. 새 프로젝트는 `recommended.yaml` 을 쓴다.

위 조합을 돌려 본 것은 Riverpod 3.x 를 쓰는 프로젝트와 pub workspace 가 아닌 프로젝트다. pub workspace 에 대해 공식 문서는 분석과 관련해 이렇게 적는다 — "Using workspaces for large repositories reduces the amount of memory required for analysis, hence improving performance." ([Pub workspaces](https://dart.dev/tools/pub/workspaces), 2026-10-14 읽음). 같은 문서는 멤버 패키지의 `analysis_options.yaml` 이 어떻게 풀리는지는 말하지 않는다. pub workspace 의 멤버 패키지에서는 이 패키지로는 돌려 보지 않았다.

## 받는 규칙

아래는 `lib/base.yaml` 의 `linter: rules:` 에 적힌 규칙 이름이다. `flutter_lints` 의 기반 세트에 더해 켜진다. 규칙마다 켠 이유와 실측 건수는 [`RULES.md`](RULES.md) 의 「켠 규칙」에, 켜지 않은 규칙과 그 이유는 「켜지 않은 규칙」에 있다. 분류는 `lib/base.yaml` 의 분류 주석을 따른다 — 검증 명령은 이름만 견주고 분류는 보지 않는다.

<!-- woody:readme-rules:start -->

**성능**

- `prefer_const_constructors`
- `prefer_const_literals_to_create_immutables`
- `avoid_slow_async_io`
- `no_runtimetype_tostring`
- `noop_primitive_operations`
- `prefer_const_declarations`
- `sized_box_shrink_expand`
- `use_colored_box`
- `use_string_buffers`
- `use_truncating_division`

**가독성 및 스타일**

- `always_declare_return_types`
- `prefer_final_locals`
- `prefer_single_quotes`
- `prefer_relative_imports`
- `avoid_bool_literals_in_conditional_expressions`
- `avoid_escaping_inner_quotes`
- `avoid_final_parameters`
- `avoid_multiple_declarations_per_line`
- `avoid_redundant_argument_values`
- `avoid_setters_without_getters`
- `combinators_ordering`
- `directives_ordering`
- `document_ignores`
- `flutter_style_todos`
- `join_return_with_assignment`
- `leading_newlines_in_multiline_strings`
- `no_literal_bool_comparisons`
- `omit_obvious_local_variable_types`
- `prefer_asserts_in_initializer_lists`
- `prefer_constructors_over_static_methods`
- `prefer_final_in_for_each`
- `prefer_if_elements_to_conditional_expressions`
- `prefer_int_literals`
- `prefer_null_aware_method_calls`
- `simple_directive_paths`
- `simplify_variable_pattern`
- `sort_constructors_first`
- `sort_pub_dependencies`
- `sort_unnamed_constructors_first`
- `specify_nonobvious_property_types`
- `tighten_type_of_initializing_formals`
- `type_annotate_public_apis`
- `unnecessary_breaks`
- `unnecessary_lambdas`
- `unnecessary_library_directive`
- `unnecessary_null_aware_operator_on_extension_on_nullable`
- `unnecessary_null_checks`
- `unnecessary_parenthesis`
- `unnecessary_raw_strings`
- `use_enums`
- `use_is_even_rather_than_modulo`
- `use_named_constants`
- `use_raw_strings`
- `use_setters_to_change_properties`

**버그 방지**

- `unawaited_futures`
- `async_return_with_no_await`
- `avoid_catching_errors`
- `avoid_double_and_int_checks`
- `avoid_dynamic_calls`
- `avoid_js_rounded_ints`
- `avoid_type_to_string`
- `avoid_unused_constructor_parameters`
- `avoid_void_async`
- `cancel_subscriptions`
- `cast_nullable_to_non_nullable`
- `conditional_uri_does_not_exist`
- `deprecated_member_use_from_same_package`
- `discarded_futures`
- `literal_only_boolean_expressions`
- `matching_super_parameters`
- `missing_whitespace_between_adjacent_strings`
- `no_adjacent_strings_in_list`
- `no_self_assignments`
- `only_throw_errors`
- `parameter_assignments`
- `switch_on_type`
- `test_types_in_equals`
- `throw_in_finally`
- `unnecessary_statements`

**strict — Dart 3.13 에서 strict-casts · strict-raw-types 옵션을 대신하는 lint (info)**

- `no_dynamic_casts`
- `no_raw_types`

<!-- woody:readme-rules:end -->

### 조각마다의 설정

규칙 밖에서 조각이 주는 설정이다.

`riverpod.yaml` 은 `riverpod_lint` analyzer plugin 을 켠다.

```yaml
plugins:
  riverpod_lint: ^3.1.9
```

`codegen.yaml` 은 freezed · json_serializable 의 어노테이션에 붙는 `invalid_annotation_target` 을 끄고, 생성 파일을 분석에서 뺀다.

```yaml
analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - '**/*.freezed.dart'
    - '**/*.g.dart'
```

`invalid_annotation_target` 을 `analyzer.errors` 로 되살리면(또는 `codegen.yaml` 을 받지 않으면) 기본 심각도는 warning 이다 (spike 009). 이 제외가 사용 프로젝트의 생성 파일에 닿는 범위는 SDK 에 따라 다르다 — 아래 「생성 파일 제외」.

`formatter:` 설정은 어느 프리셋에도 넣지 않는다. include 로 받은 `formatter:` 는 사용 프로젝트의 `dart format` 결과를 바꾸므로, 버전을 올릴 때 포맷 변경이 대량으로 생길 수 있다.

## 규칙 · plugin 진단 끄기

세 층(프로젝트 전체 · 파일 · 한 줄) × 둘(규칙 · `riverpod_lint` 진단)로 끈다. 아래 예시는 연습용 프로젝트 `fixtures/overrides/` 의 옵션 파일과 소스에 있는 줄 그대로이고, 그 정답지가 "끈 것만 사라지고 옆의 같은 위반은 남는다" 를 고정한다.

### 프로젝트 전체

사용 프로젝트의 `analysis_options.yaml` 에 적는다. 규칙은 맵 문법(`이름: false`)으로, plugin 진단은 `plugins:` 아래에 `version` 과 `diagnostics:` 를 함께 적어 끈다.

```yaml
include: package:woody_lints/recommended.yaml

# 프로젝트 전체에서 끄기 — 규칙 하나 (맵 문법) 와 plugin 진단 하나 (version 을 함께 적는다).
linter:
  rules:
    prefer_final_locals: false

plugins:
  riverpod_lint:
    version: ^3.1.9
    diagnostics:
      missing_provider_scope: false
```

`version:` 에는 프리셋의 선언(`lib/riverpod.yaml` 의 `riverpod_lint:` 값 — 위 「조각마다의 설정」 블록의 값)과 같은 값을 적는다. 사용 프로젝트가 적은 `riverpod_lint` 선언이 프리셋의 선언을 통째로 대신하므로, 여기 적은 값이 그 프로젝트의 plugin 버전 선언이 된다 (spike 012).

### 파일 하나

파일 맨 위에 적는다. plugin 진단은 `riverpod_lint/` 접두사를 붙인다. 첫째 줄이 규칙, 둘째 줄이 plugin 진단의 꼴이다 (`fixtures/overrides/lib/suppress/` 의 `lint_file.dart` · `plugin_file_prefixed.dart` 1행).

```dart
// ignore_for_file: prefer_single_quotes
// ignore_for_file: riverpod_lint/provider_parameters
```

### 한 줄

끌 줄 바로 위에 적는다. 규칙은 이렇게 끈다 (`lint_line.dart`).

```dart
// ignore: prefer_single_quotes
const String lintLineOff = "a";
```

plugin 진단은 접두사를 붙여 윗줄에 적거나 같은 줄 끝에 적는다 (`plugin_line.dart` — 둘 다 꺼진다).

```dart
  // ignore: riverpod_lint/provider_parameters
  final a = ref.watch(lineFamily([1]));
  final c = ref.watch(lineFamily([3])); // ignore: riverpod_lint/provider_parameters
```

이 패키지는 `document_ignores` 를 켜므로, 무시 주석 바로 위에 이유를 적은 주석이 없으면 그 무시 주석에 info 가 하나 붙는다 (연습용 프로젝트 정답지의 `document_ignores` 줄에서 읽은 것).

### 꺼지지 않는 모양

1. `plugins:` 에 `version` 없이 `diagnostics:` 만 적으면 **경고 없이 무시**된다 — 진단이 그대로 나오고 아무 알림도 없다 (spike 012).
2. 접두사 없는 주석은 plugin 진단을 끄지 못한다. `// ignore: provider_parameters` 와 `// ignore_for_file: provider_parameters` 는 안 꺼진다 — 연습용 프로젝트의 정답지에 `plugin_line.dart:11` 과 `plugin_file_unprefixed.dart:8` 의 줄이 남는다.
3. `analyzer.errors` 로는 plugin 진단을 끌 수 없다. `analyzer: errors:` 에 `provider_parameters: ignore` 를 적으면 꺼지지 않고 `unrecognized_error_code` 경고가 붙는다 (`riverpod_lint/` 접두사를 붙여도 같다 — spike 012).

### 덧붙임

- `diagnostics:` 에 `false` 대신 `info` · `warning` · `error` 를 적으면 그 진단의 강도가 바뀐다 (spike 012 — `info` 로 잰 것).
- 한 주석에 규칙과 plugin 진단을 함께 적을 수 있다 — `// ignore: prefer_single_quotes, riverpod_lint/provider_parameters` 가 둘 다 껐다 (spike 012).
- 한 `rules:` 블록 안에 목록(`- 이름`)과 맵(`이름: false`)을 섞으면 YAML 이 깨진다. `dart analyze` 가 종료 코드 3 으로 끝나고 진단을 내지 않는다 (spike 013). 프리셋의 `rules:` 는 목록이고 사용 프로젝트의 `rules:` 는 맵이어도 된다 — 파일이 다르면 섞여도 된다.
- 파일 머리의 `// ignore_for_file: type=lint` 는 규칙 진단과 plugin 진단을 모두 끄고, `// ignore_for_file: type=warning` 은 둘 다 끄지 못한다 (spike 012 — 손으로 쓴 샘플로 잰 것).

## 생성 파일 제외

생성 파일(`*.g.dart`, `*.freezed.dart`)을 분석에서 빼려면 사용 프로젝트의 `analysis_options.yaml` 에 직접 적는다.

```yaml
analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
```

이유: 지금은 진단이 없는 생성 파일이라도, 규칙이 늘거나 생성기가 `ignore_for_file` 머리를 달지 않는 파일에서는 줄이 날 수 있다.

프리셋(`codegen.yaml`)에도 같은 제외가 있지만, 그 제외가 사용 프로젝트의 파일에 통하는 범위는 SDK 버전에 따라 다르다. 나누기 전의 1.3.0 도 같다.

- Dart 3.13.x (3.13.4 로 잼): 규칙 진단에는 통했고 `riverpod_lint` 진단에는 통하지 않았다 (spike 012).
- 베타 3.14 (Flutter 3.49.0-0.2.pre / Dart 3.14.0-211.1.beta, 2026-10-12): 규칙 진단에도 통하지 않았다 (spike 016).
- 사용 프로젝트의 옵션 파일에 직접 적은 제외는 두 SDK 에서 규칙 진단과 plugin 진단을 모두 막았다 (spike 012 · 016). 직접 확인한 줄은 `'**/*.g.dart'` 이고, `'**/*.freezed.dart'` 는 같은 꼴이라 같다고 읽은 것이다.
- plugin 진단 쪽은 SDK 가 아니라 분석마다 pub.dev 에서 풀리는 plugin 쪽 `analyzer` 를 따르므로, SDK 를 올리지 않아도 결과가 바뀔 수 있다 (추정 — 아래 「tag 를 고정해도 바뀌는 것」).

상류는 이것을 버그로 다루고 있다 — <https://github.com/dart-lang/sdk/issues/64549>.

## 버전 올리기

받는 방식에 따라 방법이 다르다.

### tag 로 고정한 프로젝트

`pubspec.yaml` 의 `ref:` 를 새 tag 로 고치고 `flutter pub get` 을 한다. `ref:` 를 고친 뒤의 `pub get` 은 그 ref 의 커밋으로 옮긴다 (spike 015 — 잰 전환은 `main` → 브랜치 → tag 이고, tag → 새 tag 는 같은 동작으로 읽은 것이다).

`pubspec.lock` 을 커밋하고 CI 에서 `pub get --enforce-lockfile` 을 쓰는 프로젝트는 `ref:` 를 고친 뒤 `pub get` 으로 갱신한 lock 도 함께 커밋한다. `ref:` 만 고치고 lock 을 그대로 두면 `--enforce-lockfile` 이 종료 코드 65 로 멈춘다 (spike 015).

### `ref: main` 을 따르는 프로젝트

```sh
flutter pub upgrade woody_lints
```

`flutter pub get` 으로는 새 커밋을 받지 않는다. lock 이 받은 커밋을 못박고 있어서, `main` 이 나아가도 `pub get` 은 그 커밋에 머문다 (spike 015).

받는 때: `main` 에 새 버전이 합쳐져도 사용 프로젝트에 곧바로 닿지 않는다. 각 프로젝트가 `pub upgrade woody_lints` 를 하는 순간 받는다. lock 에 `woody_lints` 항목이 없는 프로젝트의 첫 `pub get` 은 그때의 `main` 을 받는다 (spike 015 — lock 파일 자체가 없는 경우는 재지 않았다).

### `ref: main` 에서 tag 로 옮기기

`ref:` 를 tag 로 고치고 `flutter pub get` 을 한다 (위 tag 갈래와 같은 동작 — spike 015 에서 읽은 것). lock 을 커밋하는 프로젝트는 갱신된 lock 도 함께 커밋한다.

```yaml
dev_dependencies:
  woody_lints:
    git:
      url: https://github.com/woodkill/woody_lints.git
      ref: v2.0.0
```

### 1.3.0 → 2.0.0 에서 권하는 일

`CHANGELOG.md` 2.0.0 의 「올리기 전에」 는 꼭 할 일만 적고 이 절을 가리킨다.

- tag 로 옮긴다 — 위 「`ref: main` 에서 tag 로 옮기기」.
- 생성 파일 제외를 사용 프로젝트의 옵션 파일에 직접 적는다 — 위 「생성 파일 제외」.
- `dev_dependencies` 에 따로 적힌 `riverpod_lint` 줄은 **필요 없다 — 지워도 된다.** 그 줄이 있을 때와 뺐을 때 `dart analyze` 의 진단이 같았고, plugin 은 양쪽 모두 3.1.9 로 풀렸다 — 그 줄의 lock 은 3.1.3 이었다 (spike 019, 사용 프로젝트 하나, 2026-10-12). plugin 은 옵션 파일의 `plugins:` 로 받고, `riverpod_lint` 3.1.9 의 pub.dev 설치 안내도 `plugins:` 만 말한다 (2026-10-13 읽음). 그 줄이 IDE 나 다른 도구에 쓰이는지는 보지 않았다 — 지울지는 읽는 사람이 정한다.
- `CHANGELOG.md` 2.0.0 의 「새로 생기는 경고」 표를 보고, `dart fix --apply` 로 고칠 수 있는 것을 고친다. `dart fix` 는 `riverpod_lint` 진단을 고치지 않는다 (spike 022).

## 문제 해결

### plugin 경고가 안 보일 때

1. `flutter analyze` 로 보고 있다 → `dart analyze` 로 본다 (아래 「`dart analyze` 와 `flutter analyze`」).
2. plugin 준비가 실패했다. stderr 에 `An error occurred while executing an analyzer plugin:` 머리말이 있다 (첫 줄이 아닐 수 있다). 이때도 종료 코드는 남은 진단대로 0 이나 2 가 그대로 나올 수 있어서, 종료 코드만으로는 알 수 없다. plugin 은 분석할 때 pub 서버에서 풀리므로 네트워크가 필요하다 — 이미 준비되어 있어도 pub 서버에 닿지 못하면 plugin 진단 없이 끝난다 (spike 002 · 008).
3. plugin 설정(끄기 · 강도)이 듣지 않는다 → 옵션 파일에 `version` 없이 `diagnostics:` 만 적었는지 본다. 그 설정은 경고 없이 무시된다 (spike 012).

### Analysis Server 재시작

`plugins:` 를 바꾼 뒤(프리셋을 바꾸거나 위의 끄는 설정을 적은 뒤)에는 IDE 의 Dart Analysis Server 를 재시작해야 반영된다.

plugin 은 Analysis Server 의 상태 폴더 아래 `.plugin_manager/<hash>/` 에 받아 컴파일된다. 기본 자리는 `~/.dartServer` 다 (읽은 것 — Analysis Server 문서와 1.3.0 의 주석. 이 자리에서 잰 것은 아니다).

컴파일된 `plugin.aot` 이 깨진 채 남으면 지울 때까지 분석마다 plugin 준비가 실패한다 (spike 008 — 전용 상태 폴더에서 잰 것). 복구는 **이 프로젝트의 `<hash>` 폴더만**(또는 그 안의 `bin/plugin.aot` 만) 지우고 다시 분석하는 것이다. 기본 자리는 IDE 와 다른 프로젝트가 함께 쓰는 폴더이므로 통째로 지우지 않는다. 어느 `<hash>` 가 이 프로젝트의 것인지는 폴더 안의 내용이나 파일 시각으로는 고를 수 없었다 (spike 008). `<hash>` 는 프로젝트 폴더의 경로(링크를 푼 경로)를 md5 한 값이고, 경로가 영문 · 숫자뿐이면 그 경로 글자를 그대로 md5 한 값과 같다 (spike 001 · 008 에서 읽은 것).

### `dart analyze` 와 `flutter analyze`

- Flutter 3.47.5 의 `flutter analyze` 는 plugin 진단을 내지 않았다 (3.41.9 는 냈다, 2026-09-20 실측).
- 베타 Flutter 3.49.0-0.2.pre (Dart 3.14.0-211.1.beta) 의 `flutter analyze` 는 plugin 진단을 내지만 규칙 진단을 겹쳐 셌고, 그 수가 실행마다 달랐다 (2026-10-12, spike 016).
- 그래서 plugin 진단은 `dart analyze` 로 확인한다.
- 종료 코드의 기준도 다르다. `dart analyze` 는 `--fatal-warnings` 가 기본으로 켜져 있고 `--fatal-infos` 는 꺼져 있다. `flutter analyze` 는 둘 다 켜져 있다 (Dart 3.13.4 / Flutter 3.47.5, 2026-10-11).

### tag 를 고정해도 바뀌는 것

`ref:` 를 tag 로 고정해도 다음은 그대로 머물지 않는다.

- `riverpod_lint` plugin — 분석할 때마다 pub.dev 에서 프리셋이 선언한 범위(`lib/riverpod.yaml` 의 `riverpod_lint:` 값) 안의 최신으로 풀린다. 사용 프로젝트의 `pubspec.lock` 이 묶지 못한다 (2026-10-12 에는 `^3.1.3` 선언도 3.1.9 로 풀렸다 — spike 010).
- 기반 세트 — 이 패키지의 `pubspec.yaml` 은 `flutter_lints: ^6.0.0` 으로 caret 범위다. 그 범위 안의 새 릴리스는 사용 프로젝트가 lock 을 갱신할 때 들어올 수 있다.
- 생성 파일 제외의 plugin 쪽 — plugin 이 쓰는 `analyzer` 의 릴리스로 위 「생성 파일 제외」의 plugin 칸이 바뀔 수 있다 (추정).

## 이 저장소를 고치는 사람에게

- 규칙은 `lib/base.yaml` 에만 적는다. 조각마다 받는 최상위 키가 정해져 있다 — `lib/base.yaml` 은 `include` · `linter` · `analyzer`, `lib/codegen.yaml` 은 `analyzer` (그 바로 아래는 `errors` · `exclude`), `lib/riverpod.yaml` 은 `plugins` (그 바로 아래는 `riverpod_lint`) 만 받는다. 그 밖의 최상위 줄(다른 조각의 `linter:`, 철자가 다른 `linter :` · `"linter":`, `formatter:`, 열 0 에서 시작하지 않는 최상위 키 등)과 그 바로 아래의 다른 키(`lib/codegen.yaml` 의 `language:`, `lib/riverpod.yaml` 의 다른 plugin 등)는 `[3/10]` 단계가 실패하고, `linter:` 줄에 값이 붙은 flow 표기(`linter: {rules: [...]}`)는 종료 코드 70 으로 멈춘다.
- 규칙을 더하거나 빼면 `lib/base.yaml`, `RULES.md` 의 켠 규칙 표, 이 README 의 표시 구역(「받는 규칙」의 목록) 세 곳을 같은 커밋에서 고친다. 어긋나면 검증이 실패한다.
- 검증은 `fvm dart run tool/verify.dart` 로 돌린다. 단계와 종료 코드, 지워 보기 기록은 [`example/README.md`](example/README.md) 에 있다.
- 버전 등급과 CHANGELOG 항목 형식은 [`VERSIONING.md`](VERSIONING.md) 를 따른다.
- 릴리스 버전(`pubspec.yaml` 의 `version:`)을 올릴 때는 이 README 의 `ref:` 예시 둘(「설치」 · 「`ref: main` 에서 tag 로 옮기기」)을 같은 커밋에서 고친다. `lib/riverpod.yaml` 의 plugin 하한을 올릴 때는 `lib/riverpod.yaml` 의 선언, `fixtures/overrides/analysis_options.yaml` 의 `version:`, 이 README 의 plugin 버전 예시 둘(「조각마다의 설정」 · 「규칙 · plugin 진단 끄기」)을 같은 커밋에서 고친다. `[4/10]` 이 `fixtures/overrides/analysis_options.yaml` 의 `version:` 을, `[3/10]` 이 이 README 의 펜스(`` ``` `` · `~~~`) 코드 블록 안에서 키가 줄 머리에 오는 `ref:` · `version:` · `riverpod_lint:` 줄의 값을 견준다 — flow 표기(`{…}`) 안의 키, 네 칸 들여 쓴 코드 블록 · 인용(`>`) 안의 펜스에 적은 값은 견주지 않으므로 예시는 지금처럼 펜스 안의 블록 꼴로 둔다.
