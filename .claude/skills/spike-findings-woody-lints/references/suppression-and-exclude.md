# 진단 끄기와 생성 파일 제외

사용 프로젝트가 규칙과 plugin(`riverpod_lint`) 진단을 프로젝트 전체 / 파일 하나 / 한 줄에서 끄는 방법, 꺼지지 않는 모양, 그리고 `analyzer.exclude` 가 plugin 진단에 통하는 조건이다. 끄는 설정용 연습 프로젝트(03-CONTEXT.md D-03 의 4번, PRESET-07)와 Phase 5 의 README(끄는 방법 안내, 생성 파일 안내)가 기대는 사실이다.

모든 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64, 2026-10-12 실측이다. 규칙은 `prefer_single_quotes` (info), plugin 진단은 `provider_parameters` (warning) 로 쟀다. 묶음(`recommended.yaml`)을 받는 replica 의 연습용 프로젝트에서 세 번 돌렸고, 주석으로 끄기와 생성 파일 제외(스크립트의 1부)의 결과가 세 번 모두 같았다.

## Requirements

MANIFEST.md 의 `preset-split-include-behavior` 에서 이 영역에 걸리는 것.

소유자가 이전에 확정한 것 (출처는 03-CONTEXT.md).

- `invalid_annotation_target: ignore` 와 생성 파일 제외 두 줄은 `codegen.yaml` 에 둔다 (D-02). `riverpod_lint` 선언은 범위 지정이다 (D-01)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 하고, 스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다

spike 에서 나와 실제 구현이 지켜야 하는 것.

- 끄는 설정용 연습 프로젝트는 끈 자리 옆에 끄지 않은 같은 위반을 둔다. plugin 진단은 주석에 `riverpod_lint/` 접두사를 붙이고, 프로젝트 전체에서 끌 때는 `version` 을 함께 적는다. `version` 을 뺀 설정은 경고 없이 무시되고, `analyzer.errors` 로는 plugin 진단을 끌 수 없다 (012)
- **`codegen.yaml` 이 주는 생성 파일 제외는 규칙 진단에만 통하고 plugin 진단에는 통하지 않는다.** plugin 이 쓰는 `analyzer` 14.4.0 이상이 제외 패턴을 그것을 적은 파일의 폴더 기준으로 풀기 때문이고, 나누기 전(1.3.0)에도 같다. 사용 프로젝트가 자기 옵션 파일에 직접 적은 제외는 plugin 도 따른다. 성공 기준 3 의 "생성 파일의 진단이 보고되지 않는다" 는 규칙 진단에 대한 말로 읽는다 (012)

이 spike 의 결과는 어느 쪽이든 기록하고 계속 진행하는 항목이었다 (03-CONTEXT.md D-07). 판정은 PARTIAL 이다 — 끄는 방법 여섯 칸은 성립했고, 묶음이 주는 생성 파일 제외가 plugin 진단에 통하지 않았다.

이 문서의 D-NN 은 모두 03-CONTEXT.md 의 것이다. "성공 기준 3" 은 ROADMAP.md Phase 3 의 셋째 성공 기준이다: "`riverpod.yaml` 을 include 한 구성에서 `riverpod_lint` 진단이 보고되고 plugin 버전 하한이 `^3.1.9` 이며, `codegen.yaml` 을 include 한 구성에서 생성 파일(`*.g.dart`, `*.freezed.dart`)의 진단이 보고되지 않는다". "묶음이 주는 제외", "`codegen.yaml` 이 주는 제외", "프리셋이 주는 제외" 는 같은 것을 가리킨다 — `codegen.yaml` 에 적히는 `analyzer.exclude` 두 줄이고, 나누기 전에는 `lib/analysis_options.yaml` 에 적혀 있다.

## How to Build It

### 1. 끄는 방법 여섯 칸

03-CONTEXT.md D-04 의 표가 그대로 성립했다. 주석으로 끄는 네 칸은 끈 자리만 사라지고 옆의 같은 위반이 남았고, 프로젝트 전체에서 끄는 두 칸은 그 규칙 · 그 진단의 줄만 모두 사라지고 **다른** 규칙 · 다른 plugin 진단의 줄이 남았다. 여섯 칸을 같은 규칙과 같은 진단으로, 옵션 파일을 바꿔 가며 따로 쟀다 — 한 프로젝트에 함께 담을 때 걸리는 점은 8번에 있다.

| 층 | 규칙 | plugin 진단 |
|---|---|---|
| 프로젝트 전체 | 옵션 파일의 `linter: rules:` 에 `이름: false` (맵 문법) — 그 규칙의 4줄만 사라짐 | 옵션 파일의 `plugins: riverpod_lint:` 에 `version` 과 `diagnostics: {이름: false}` — 그 진단의 7줄만 사라지고 다른 plugin 진단 2줄은 남음 |
| 파일 하나 | `// ignore_for_file: 이름` | `// ignore_for_file: riverpod_lint/이름` |
| 한 줄 | `// ignore: 이름` | `// ignore: riverpod_lint/이름` (윗줄에 적든 같은 줄 끝에 적든 같다) |

- 한 주석에 규칙과 plugin 진단을 함께 적을 수 있다 — `// ignore: prefer_single_quotes, riverpod_lint/provider_parameters` 가 둘 다 껐다.

### 2. 프로젝트 전체에서 끄는 옵션 파일

규칙 하나를 끈다 (맵 문법).

```yaml
include: package:woody_lints/recommended.yaml

linter:
  rules:
    prefer_single_quotes: false
```

plugin 진단 하나를 끈다 (`version` 을 함께 적는다).

```yaml
include: package:woody_lints/recommended.yaml

plugins:
  riverpod_lint:
    version: ^3.1.3
    diagnostics:
      provider_parameters: false
```

- 두 옵션은 **따로** 돌렸다. 둘을 한 옵션 파일에 함께 적은 실행은 하지 않았다.
- 판정 방식: 끄지 않은 실행(25줄)에서 그 진단의 줄만 뺀 것과 전체를 견줬다. 규칙을 끄면 21줄, plugin 진단을 끄면 18줄이고 종료 코드는 둘 다 2 그대로였다.
- **`version` 은 묶음과 다른 값을 적어도 꺼진다** (`^3.1.9` 로 쟀다). 서버가 받은 선언은 사용 프로젝트가 적은 것이었다 — 같은 이름의 선언이 통째로 바뀐다. 적은 값이 그 프로젝트의 plugin 버전 선언이 된다.
- 그래서 끄는 설정용 연습 프로젝트는 묶음의 하한을 `^3.1.9` 로 올린 뒤에도 자기 옵션 파일에 적은 값을 쓴다. `^3.1.3` 을 적은 실행과 `^3.1.9` 를 적은 실행의 진단은 같았다 (둘 다 3.1.9 로 풀렸다). 하한을 올리는 커밋에서 이 프로젝트의 `version` 도 함께 올릴지는 계획이 정한다.
- `diagnostics:` 에 강도를 적으면 그 강도로 바뀐다 — `provider_parameters: info` 로 7줄이 모두 info 가 됐다.
- 사용 프로젝트의 `rules:` 는 맵 문법이고 `base.yaml` 의 `rules:` 는 목록 문법이다. 파일이 다르면 섞여도 된다. **같은 `rules:` 블록 안에 목록과 맵을 섞으면 YAML 이 깨진다** (013 — exit 3, JSON 의 진단 0건).

### 3. 주석으로 끄는 샘플 — 끈 자리 옆에 끄지 않은 같은 위반

"꺼졌다" 가 헛통과가 아니려면 끈 자리 옆의 같은 위반이 정답지에 남아야 한다. spike 가 쓴 샘플이다 (`sources/012-plugin-suppression-matrix/probe.dart` 의 `samples`).

```dart
// lib/suppress/lint_line.dart
/// 한 줄 주석으로 규칙 끄기.
// ignore: prefer_single_quotes
const String lintLineOff = "a";

/// 끄지 않은 같은 위반 (대조).
const String lintLineOn = "b";
```

```dart
// lib/suppress/plugin_line.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final lineFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 한 줄 주석으로 plugin 진단 끄기 — 접두사 있음 / 없음 / 같은 줄 끝 / 끄지 않음.
final lineConsumer = Provider<int>((ref) {
  // ignore: riverpod_lint/provider_parameters
  final a = ref.watch(lineFamily([1]));
  // ignore: provider_parameters
  final b = ref.watch(lineFamily([2]));
  final c = ref.watch(lineFamily([3])); // ignore: riverpod_lint/provider_parameters
  final d = ref.watch(lineFamily([4]));
  return a + b + c + d;
});
```

위의 첫 줄(`// lib/suppress/…`)은 여기서 붙인 파일 이름이고 샘플에는 없다. 묶음만 받은 실행에서 `lib/suppress/` 아래에 남은 줄은 8줄이다.

```text
lib/suppress/lint_line.dart:6  info  prefer_single_quotes
lib/suppress/mixed_line.dart:10  info  prefer_single_quotes
lib/suppress/mixed_line.dart:10  warning  provider_parameters
lib/suppress/plugin_file_unprefixed.dart:8  warning  provider_parameters
lib/suppress/plugin_line.dart:11  warning  provider_parameters
lib/suppress/plugin_line.dart:13  warning  provider_parameters
lib/suppress/type_warning_file.dart:8  info  prefer_single_quotes
lib/suppress/type_warning_file.dart:8  warning  provider_parameters
```

| 남은 줄 | 뜻 |
|---|---|
| `lint_line.dart:6` | 끄지 않은 대조 자리. 끈 3행은 나오지 않았다 |
| `plugin_line.dart:11` | **접두사 없는 `// ignore: provider_parameters` 는 끄지 못한다** |
| `plugin_line.dart:13` | 끄지 않은 대조 자리. 접두사를 붙인 9행 · 12행은 나오지 않았다 |
| `plugin_file_unprefixed.dart:8` | **접두사 없는 `// ignore_for_file: provider_parameters` 는 끄지 못한다** |
| `mixed_line.dart:10` 두 줄 | 끄지 않은 대조 자리. 한 주석(8행)으로 둘을 함께 끈 9행은 나오지 않았다 |
| `type_warning_file.dart:8` 두 줄 | `// ignore_for_file: type=warning` 은 규칙도 plugin 진단도 끄지 못한다 (→ 5번) |

나오지 않은 파일: `lint_file.dart` (`// ignore_for_file: prefer_single_quotes`), `plugin_file_prefixed.dart` (`// ignore_for_file: riverpod_lint/provider_parameters`), `type_lint_file.dart` (`// ignore_for_file: type=lint`).

- 샘플 전문과 칸의 정의(`cells`)는 사본에 있다. 줄 번호는 spike 의 샘플 기준이다.
- 이 실행에서 더한 샘플 밖의 줄은 저장소의 정답지 16줄 그대로였다.

### 4. 꺼지지 않는 모양

| 적은 것 | 결과 |
|---|---|
| `// ignore: provider_parameters` (접두사 없음) | 꺼지지 않는다. 그 주석에 붙는 진단도 없다 |
| `// ignore_for_file: provider_parameters` (접두사 없음) | 꺼지지 않는다. 그 주석에 붙는 진단도 없다 |
| `plugins: riverpod_lint: diagnostics: {…: false}` (`version` 없음) | **꺼지지 않고, 경고도 없다.** 끄지 않은 실행과 25줄이 한 줄도 다르지 않았다 |
| `analyzer: errors: {provider_parameters: ignore}` | 꺼지지 않고 `analysis_options.yaml:5  warning  unrecognized_error_code` 가 붙는다 |
| `analyzer: errors: {riverpod_lint/provider_parameters: ignore}` | 위와 같다 |

- **`version` 을 뺀 설정은 조용히 무시된다.** 연습용 프로젝트에 "꺼지지 않는 모양" 을 정답지에 남는 줄로 고정해 둘 가치가 있다 (012 의 권고). 3번의 `plugin_line.dart:11` 과 `plugin_file_unprefixed.dart:8` 이 접두사 쪽의 그런 줄이다.
- plugin 진단을 끄는 길은 `plugins:` 의 `diagnostics:` 와 주석뿐이다.

### 5. `// ignore_for_file: type=…`

| 파일 머리 | 규칙 진단 | plugin 진단 |
|---|---|---|
| `// ignore_for_file: type=lint` | 꺼짐 | **꺼짐** |
| `// ignore_for_file: type=warning` | 남음 | **남음** |

- plugin 안에서 `riverpod_lint` 의 진단은 종류가 `LINT` 다. JSON 에 `type: STATIC_WARNING` 으로 나오는 것(003)은 서버가 plugin 진단을 옮겨 적을 때 붙는 값이고 주석 판정에는 쓰이지 않는다. 소스를 읽고 세운 추정(`type=warning` 이 끌 것)과 반대였다.
- `riverpod_generator` 4.0.9 의 산출물은 `type=lint` 를 달고 나온다. spike 003 의 산출물 6개가 모두 10행에 `// ignore_for_file: type=lint, type=warning` 을 갖고 있다. `type=lint` 가 plugin 진단을 끄므로 그런 파일에서는 제외가 통하지 않아도 plugin 진단이 나오지 않을 것이다 — 위 표는 `type=lint` 만 단 손으로 쓴 샘플로 쟀고, 둘을 함께 단 실제 산출물에 위반을 넣어 돌린 것은 아니다. 다른 생성기(freezed, json_serializable)의 머리는 확인하지 않았다.

### 6. `analyzer.exclude` — 어디에 적었느냐에 따라 갈린다

생성 파일 샘플 `lib/generated/riverpod_violation.g.dart` 에 규칙 위반과 plugin 위반을 한 줄에 두고(머리 주석 없음) 쟀다.

| `**/*.g.dart` 제외를 적은 곳 | 규칙 진단 | plugin 진단 |
|---|---|---|
| 없음 (`base.yaml` + `riverpod.yaml`) | 나옴 | 나옴 |
| 패키지의 `codegen.yaml` (묶음으로 받음) | 안 나옴 | **나옴** |
| 패키지의 `analysis_options.yaml` (나누기 전, 1.3.0 의 모양) | 안 나옴 | **나옴** |
| 사용 프로젝트의 `analysis_options.yaml` 에 직접 | 안 나옴 | 안 나옴 |
| 사용 프로젝트 루트의 `local_excludes.yaml` (include 로 부름) | 안 나옴 | 안 나옴 |
| 사용 프로젝트의 `config/local_excludes.yaml` (include 로 부름) | 안 나옴 | **나옴** |

묶음을 받았는데도 남은 줄.

```text
lib/generated/riverpod_violation.g.dart:5  warning  provider_parameters
```

- **plugin 은 제외 패턴을 "그 패턴을 적은 파일의 폴더" 기준으로 푼다.** 표의 아래 두 줄은 같은 내용의 파일을 폴더만 달리 둔 것이고 결과가 갈렸다. 그래서 패키지 안에 적힌 `**/*.g.dart` 는 패키지 폴더 아래에서만 맞고 사용 프로젝트의 생성 파일에는 맞지 않는다. 분석 서버(규칙 쪽)는 사용 프로젝트 루트 기준으로 풀어 제외한다.
- **나눠서 생긴 일이 아니다.** 나누기 전의 한 파일 구조에서도 같다 — 1.3.0 이 이미 이렇게 동작한다.
- 사용 프로젝트가 자기 옵션 파일에 직접 적은 제외는 규칙과 plugin 이 둘 다 따르고, 묶음에서 받은 제외와 합쳐진다 (`lib/suppress/**` 를 직접 적으면 그 아래 8줄이 0줄이 되고, 생성 파일 샘플의 규칙 진단도 여전히 없다).

Phase 3 의 계획이 이 결과로 정할 것.

- **성공 기준 3 의 "생성 파일의 진단이 보고되지 않는다" 는 규칙 진단에 대해서만 참이다.** 지금의 `example/` 샘플(생성 파일에 규칙 위반만 있다)로는 성립한다. 생성 파일에 plugin 위반을 두면 `codegen.yaml` 을 받아도 그 줄이 나온다.
- 이 동작을 연습용 프로젝트에 있는 그대로 고정할지는 계획이 정한다 (D-07 의 "따르지 않는다로 나오면 그 동작을 있는 그대로 고정한다").

### 7. Phase 5 의 README 에 적을 것

- 생성 파일 제외는 **사용 프로젝트의 `analysis_options.yaml` 에도 직접 적으라고 안내한다.** plugin 진단에는 프리셋의 제외가 이미 통하지 않는다.
- `// ignore_for_file: type=lint` 를 단 생성 파일에서는 제외와 상관없이 plugin 진단이 나오지 않는다. `riverpod_generator` 4.0.9 의 산출물이 이 머리를 단다 (다른 생성기는 확인하지 않았다).
- plugin 진단을 프로젝트 전체에서 끌 때 `version` 을 함께 적는다. 묶음과 같지 않아도 되지만 적은 값이 그 프로젝트의 plugin 버전 선언이 된다.
- 주석으로 plugin 진단을 끌 때는 `riverpod_lint/` 접두사를 붙인다.
- `diagnostics:` 에 `info` / `warning` / `error` 를 적어 강도를 바꿀 수 있다.

### 8. 한 프로젝트에 여섯 칸을 함께 담을 때 걸리는 점

spike 는 여섯 칸을 **같은** 규칙(`prefer_single_quotes`)과 **같은** plugin 진단(`provider_parameters`)으로, 옵션 파일을 바꿔 가며 따로 쟀다. 옵션 파일이 하나인 실제 연습용 프로젝트에 그대로 옮기면 맞물리지 않는다.

- 프로젝트 전체에서 끈 진단은 그 프로젝트의 **모든** 자리에서 사라진다. `provider_parameters` 를 옵션 파일에서 끄면 7줄이 모두 사라졌고, 그 안에는 `lib/suppress/` 의 대조 줄(`plugin_line.dart:13` 등)과 접두사 없는 주석의 줄도 들어 있다. 주석 칸의 "끄지 않은 같은 위반" 이 정답지에 남지 않게 된다. `prefer_single_quotes` 를 끈 실행(4줄이 모두 사라짐)도 같다.
- 그래서 한 프로젝트에 담으려면 프로젝트 전체에서 끄는 규칙 · 진단을 주석으로 끄는 규칙 · 진단과 **다른 것**으로 고르거나, 프로젝트를 둘로 나눈다. 어느 쪽으로 할지, 무엇을 끌지는 계획이 정한다 (D-04 — 기본값은 프로젝트 하나다).
- 프로젝트 전체 칸의 대조는 "같은 진단의 옆자리" 가 아니라 "다른 진단이 남는다" 다. plugin 쪽은 `missing_provider_scope` 와 `avoid_public_notifier_properties` 가 한 줄씩 남는 것으로 확인했다.
- 규칙을 끄는 설정과 plugin 진단을 끄는 설정을 한 옵션 파일에 함께 적은 실행은 하지 않았다. 여섯 칸을 한 프로젝트에 담아 돌린 것도 아니다. 그 프로젝트의 정답지는 `--update` 로 처음 쓰고 위의 표들과 견줘 읽는다.

## What to Avoid

- **`version` 없이 `diagnostics:` 만 적는 것.** 꺼지지 않고 경고도 없다. 가장 알아채기 어려운 모양이다.
- **plugin 진단을 접두사 없는 주석으로 끄는 것.** `// ignore:` 도 `// ignore_for_file:` 도 `riverpod_lint/` 가 있어야 한다.
- **plugin 진단을 `analyzer.errors` 로 끄거나 강도를 바꾸려는 것.** 접두사를 붙이든 안 붙이든 `unrecognized_error_code` warning 만 는다.
- **JSON 의 `type` 을 보고 `// ignore_for_file: type=warning` 이 plugin 진단을 끌 것이라고 미루어 보는 것.** 끄는 것은 `type=lint` 다.
- **"`codegen.yaml` 을 받으면 생성 파일의 진단이 전부 사라진다" 고 적는 것.** 규칙 진단에만 참이다.
- **끈 자리만 두고 대조 자리를 두지 않는 것.** 샘플이 통째로 분석되지 않아도 "꺼졌다" 로 보인다.
- **주석 칸의 대조에 쓰는 진단을 같은 프로젝트의 옵션 파일에서 끄는 것.** 대조 줄이 함께 사라진다 (→ 8번).
- **끈 설정마다 줄 수만 세는 것.** 다른 줄이 함께 사라져도 모른다. 끄지 않은 실행에서 그 진단의 줄만 뺀 것과 전체를 견준다.
- **소스를 읽을 때 SDK 의 analyzer 와 plugin 의 analyzer 를 섞는 것.** 버전이 다르고 제외 패턴의 기준 폴더가 다르다.

## Constraints

- 분석 서버(규칙, 옵션 파일의 진단)는 Dart 3.13.4 에 든 analyzer(14.1.0-dev)를 쓰고, plugin 은 pub.dev 에서 풀린 것을 쓴다 — 2026-10-12 에 `analysis_server_plugin` 0.3.24, `analyzer` 14.5.0 (전용 상태 폴더의 `.plugin_manager/*/pubspec.lock`). **둘이 다른 버전이라는 점이 6번 결과의 원인이다.**
- 제외 패턴의 기준 폴더는 `analyzer` 14.4.0 에서 바뀌었다 (pub cache 의 `context_locator.dart` `_getExcludedGlobs`).

  | `analyzer` | 패턴을 푸는 기준 |
  |---|---|
  | 12.1.0, 13.3.0 | `optionsFile.parent` — context root 의 옵션 파일이 있는 폴더 |
  | 14.4.0, 14.5.0 | `excluded.declaringFile.parent` — **그 패턴을 적은 파일**이 있는 폴더 |

- **Dart 3.14 에서 같은 변경이 SDK 에 들어오면 규칙 진단에도 `codegen.yaml` 의 제외가 통하지 않게 될 것이다.** 소스를 읽은 추정이고 실행하지 않았다 (이 컴퓨터의 SDK 는 Dart 3.11.x 와 3.13.4 뿐이다). 그날 `example/` 의 정답지에 생성 파일 샘플의 4줄이 나타나 CI 가 먼저 깨진다.
- 주석 판정: `analysis_server_plugin` 의 `plugin_server.dart` 가 진단마다 `ignoreInfo.ignored(e, pluginName: …)` 을 부르고, `analyzer` 의 `IgnoredDiagnosticName._matches` 는 plugin 이름이 다르면 맞지 않는다고 본다. `// ignore:` 와 `// ignore_for_file:` 이 같은 함수를 쓴다.
- `diagnostics:` 가 받는 값: `error` / `warning` / `info` / `ignore` / `disable` / `enable` (소스에서 읽음). 실행으로 본 것은 `false` 와 `info` 다.
- 판정에 넣은 확인 15건이 모두 성립했다. 소스를 읽어 세운 추정과 실제가 다른 칸은 29칸 중 3칸이었다 (`type=lint`, `type=warning`, 묶음이 주는 생성 파일 제외 — 셋 다 plugin 쪽).
- 처음 실행은 15 ~ 20초다 (실행마다 빈 상태 폴더).
- 확인하지 않은 것: git 의존성으로 받았을 때 (패키지가 pub cache 에 놓여도 "패턴을 적은 파일의 폴더" 는 사용 프로젝트 밖이므로 같은 결과일 것이다 — 추정), `**/*.freezed.dart` (같은 코드가 처리한다), freezed · json_serializable 의 실제 산출물이 어떤 머리를 다는지, `riverpod_lint` 의 다른 14개 진단 (주석과 제외를 처리하는 코드는 진단 이름과 무관하다), 규칙과 plugin 진단을 한 옵션 파일에서 함께 끄는 것, Dart 3.14 의 분석 서버.

## Origin

Synthesized from spikes: 012 (한 파일 구조에서 plugin 선언을 다시 적어 끄는 것은 003 이 먼저 봤다)
Source files available in: sources/012-plugin-suppression-matrix/
원본 로그와 JSON: `.planning/spikes/012-plugin-suppression-matrix/results/`
