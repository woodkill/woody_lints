# `example/` 연습용 프로젝트와 정답지

검증 명령이 분석할 `example/` 프로젝트의 모양, 거기에 넣을 위반 코드, 정답지에 적힐 줄, 패키지를 받는 방법, 그리고 `example/` 이 저장소 루트의 분석에 섞이지 않게 하는 방법이다.

모든 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, 2026-10-11 실측이다.

## Requirements

MANIFEST.md 의 `verify-harness-tool-behavior` 에서 이 영역에 걸리는 것.

- 정답지 한 줄은 `상대경로:줄  강도  규칙이름`, 맨 위에 `exit N` (D-04)
- `lib/`, `pubspec.yaml` 은 바꾸지 않는다. 루트 `analysis_options.yaml` 은 기존 exclude 항목(`lib/analysis_options.yaml`)을 그대로 둔다
- 루트 `analysis_options.yaml` 의 exclude 에 `example/**` 한 줄을 더한다 (기존 `lib/analysis_options.yaml` 제외는 그대로 둔다 — 02-CONTEXT.md 가 계획에 맡긴 항목). 더하지 않으면 루트 분석에 example 의 진단이 섞인다: 패키지를 받기 전에는 error 6건으로 exit 3, 받은 뒤에는 plugin 준비까지 일어나 exit 2. 이 제외는 `example/` 안에서의 분석을 건드리지 않는다 (007)
- `riverpod_lint` 진단의 강도는 JSON 의 `severity` 로 읽는다. `type` 은 강도와 상관없이 전부 `STATIC_WARNING` 이고 `code` 에는 접두사가 없다 (003)
- 정답지에 넣을 plugin 진단은 코드 생성 없이 뜨는 5개 중에서 고른다. warning 하나(`missing_provider_scope`)와 info 하나(`avoid_public_notifier_properties`)를 넣으면 맨 위 줄이 `exit 2` 가 된다 (003)
- `example/` 의 패키지는 `dart pub get` 으로 받는다 (`--enforce-lockfile` 가능). `flutter pub get` 은 옵션 파일 맨 위에 `build/**` 제외를 써넣는다 (004)

## How to Build It

### 1. 프로젝트의 모양

사용 프로젝트와 같은 모양으로 둔다: Flutter 패키지, `woody_lints` 를 의존성으로 받음, 옵션 파일은 include 한 줄.

```yaml
# sources/001-analyze-invocation-form/fixture/pubspec.yaml
name: spike_invocation_fixture
description: spike 001 — dart analyze 실행 형태별 plugin 진단 확인용 연습 프로젝트
publish_to: 'none'
version: 0.0.0

environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.0

dev_dependencies:
  # 저장소 루트의 woody_lints 를 그대로 받는다 (사용 프로젝트의 git 의존성 자리).
  woody_lints:
    path: ../../../..
```

`example/` 에서는 `path:` 가 저장소 루트를 가리키도록 `path: ..` 로 바꾼다 (spike 의 `../../../..` 은 `.planning/spikes/NNN/fixture/` 기준이다). spike 007 이 이 연습용 프로젝트를 `example/` 자리에 복사하고 그 한 줄만 바꿔 돌렸고, 아래 2번의 진단 4건이 그대로 나왔다.

```yaml
# example/analysis_options.yaml — 이 한 줄이 전부다
include: package:woody_lints/analysis_options.yaml
```

### 2. 위반 코드와 그 결과

spike 001 의 연습용 프로젝트가 lint 2건과 plugin 2건을 낸다. 파일 두 개를 서로 다른 폴더에 둔 것은 하위 폴더의 plugin 진단도 나오는지 보려는 것이었다.

`sources/001-analyze-invocation-form/fixture/lib/main.dart` 전문 (9행이 `print`, 10행이 `runApp`):

```dart
import 'package:flutter/material.dart';

/// 앱 진입점.
///
/// 일부러 어긴 규칙:
/// - `avoid_print` (기반 세트), `prefer_single_quotes` (woody_lints 가 추가)
/// - `missing_provider_scope` (riverpod_lint, warning 으로 선언됨)
void main() {
  print("spike 001");
  runApp(const MaterialApp(home: SizedBox()));
}
```

`sources/001-analyze-invocation-form/fixture/lib/src/counter.dart` 전문 (8행이 `publicField`):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 하위 폴더에 둔 Notifier.
///
/// 일부러 어긴 규칙: `avoid_public_notifier_properties`
/// (riverpod_lint, 소스에 강도 지정이 없음).
class Counter extends Notifier<int> {
  int publicField = 0;

  @override
  int build() => 0;
}
```

정답지 형식으로 적으면 아래와 같다 (`sources/006-github-runner-cold-plugin/expected_001.txt`). GitHub runner 의 새 가상 머신 10대에서 50번 돌려 50번 모두 이와 같았다.

```text
exit 2
lib/main.dart:10  warning  missing_provider_scope
lib/main.dart:9  info  avoid_print
lib/main.dart:9  info  prefer_single_quotes
lib/src/counter.dart:8  info  avoid_public_notifier_properties
```

줄의 순서는 문자열 정렬이다 (`:10` 이 `:9` 보다 앞에 온다).

### 3. 정답지에 넣을 plugin 규칙 고르기

조건: 코드 생성 없이 낼 수 있고, 강도가 서로 다른 규칙을 섞는다 (2~3건).

| 역할 | 규칙 | 이유 |
|---|---|---|
| warning 하나 | `missing_provider_scope` | `runApp` 한 줄이면 되고 가장 흔한 실수다 |
| info 하나 | `avoid_public_notifier_properties` | 코드 생성 없이 낼 수 있는 유일한 info 다 |
| 세 번째가 필요하면 | `provider_parameters` (warning) | `flutter_riverpod` 만으로 뜬다 |

이 조합이면 정답지의 맨 위 줄은 **`exit 2`** 다. warning 이 하나 들어 있어야 "plugin 이 죽어 warning 이 사라졌다"가 종료 코드로도 드러난다.

### 4. `riverpod_lint` 규칙 15개의 강도

| 규칙 | 강도 (`severity`) | 이 규칙만 켰을 때 exit | 띄우는 데 필요한 것 |
|---|---|---|---|
| `missing_provider_scope` | warning | 2 | `flutter_riverpod` 만 |
| `provider_parameters` | warning | 2 | `flutter_riverpod` 만 |
| `avoid_public_notifier_properties` | **info** | 0 | `flutter_riverpod` 만 |
| `avoid_ref_inside_state_dispose` | warning | 2 | `flutter_riverpod` 만 |
| `async_value_nullable_pattern` | warning | 2 | `flutter_riverpod` 만 |
| `functional_ref` | warning | 2 | `riverpod_annotation` (생성 코드 없이 뜬다) |
| `notifier_extends` | warning | 2 | `riverpod_annotation` (생성 코드 없이 뜬다) |
| `notifier_build` | warning | 2 | `riverpod_annotation` + 가짜 기반 클래스 `typedef` |
| `riverpod_syntax_error` | **error** | 3 | `riverpod_annotation` + 가짜 기반 클래스 `typedef` |
| `protected_notifier_properties` | **info** | 0 | 생성 코드를 둔 상태로 확인 |
| `avoid_build_context_in_providers` | **info** | 0 | 생성 코드를 둔 상태로 확인 |
| `provider_dependencies` | warning | 2 | 생성 코드를 둔 상태로 확인 |
| `scoped_providers_should_specify_dependencies` | warning | 2 | 생성 코드를 둔 상태로 확인 |
| `unsupported_provider_value` | warning | 2 | 생성 코드를 둔 상태로 확인 |
| `only_use_keep_alive_inside_keep_alive` | warning | 2 | 생성 코드를 둔 상태로 확인 |

합계: **info 3개, warning 11개, error 1개.** 15개 모두에 공통인 것:

- JSON `code` 는 규칙 이름 그대로다. `riverpod_lint/` 접두사가 붙지 않는다.
- JSON `type` 은 info 든 error 든 전부 `STATIC_WARNING` 이다.
- 종료 코드는 강도만 따른다: info → 0, warning → 2, error → 3. 15개를 한 번에 돌리면 3 이다.

위반 예제 15개는 `sources/003-riverpod-lint-severity-matrix/fixture/lib/` 에 규칙마다 파일 하나로 있다. 가짜 기반 클래스는 `typedef _$Name = Object;` 로 흉내 낸다 (upstream 테스트와 같은 방식).

### 5. 패키지 받기

```bash
# example/ 에서
dart pub get --enforce-lockfile
```

- `dart pub get` 은 Flutter 프로젝트에서 그대로 된다. `flutter` SDK 의존성을 스스로 찾는다. `FLUTTER_ROOT` 환경변수가 없어도, Flutter SDK 안의 `bin/cache/dart-sdk/bin/dart` 를 직접 불러도 됐다.
- 그래서 검증 스크립트가 `Platform.resolvedExecutable` 로 `pub get` 을 불러도 된다.

```dart
// sources/006-github-runner-cold-plugin/ci_probe.dart 의 runPubGet 에서
final result = await Process.run(
  Platform.resolvedExecutable,
  ['pub', 'get'],
  workingDirectory: fixtureDir,
);
if (result.exitCode != 0) {
  stderr.writeln('pub get 실패 ($fixtureDir): exit ${result.exitCode}\n${result.stderr}');
  exit(69);
}
```

- 위의 Dart 조각은 spike 가 돌린 그대로라 `--enforce-lockfile` 이 없다. 이 플래그의 동작은 004 가 명령줄로 쟀다. 검증 명령이 붙일지는 계획에서 정한다.
- `example/pubspec.lock` 을 커밋하려면 루트 `.gitignore` 의 `pubspec.lock` 패턴에 `example/` 예외 한 줄이 필요하다 (D-05 의 결정이고 spike 가 잰 것은 아니다).
- `--enforce-lockfile` 은 "`pubspec.lock` 에 적힌 버전 그대로"를 강제한다. `example/pubspec.lock` 을 커밋하기로 했으므로(D-05) 검증 명령과 CI 가 쓸 수 있다. lock 과 `pubspec.yaml` 이 어긋나면 **종료 코드 65** 로 실패하고 lock 은 바뀌지 않는다 ("Unable to satisfy `pubspec.yaml` using `pubspec.lock`.").
- 결과는 `flutter pub get` 과 같다: `.dart_tool/package_config.json` 의 패키지 35개가 같고 `pubspec.lock` 은 글자 하나 다르지 않았다. `flutter pub get` 만 `.dart_tool/version` 을 하나 더 만든다.

### 6. 옵션 파일이 include 한 줄인지 함께 본다

검증 명령이 "`example/analysis_options.yaml` 이 include 한 줄인가"를 검사하면 두 가지를 같은 자리에서 잡는다.

- 누군가 `example/` 에서 `flutter pub get` 을 돌린 실수 (맨 위에 세 줄이 생긴다)
- include 줄을 지운 변경 (VERIFY-08)

`flutter pub get` 이 만든 파일 전문:

```yaml
analyzer:
  exclude:
    - build/**
include: package:woody_lints/analysis_options.yaml
```

### 7. 규칙 하나만 끄는 설정 (Phase 3 의 PRESET-07 이 기대는 사실)

include 로 받은 `plugins:` 선언을 사용 프로젝트가 같은 이름으로 다시 선언해 덮어쓸 수 있다. 이 저장소의 실제 파일로 재현했다 (15번 모두 남긴 규칙의 진단만 나왔고, 15개를 다 끄면 plugin 진단이 0건).

```yaml
include: package:woody_lints/analysis_options.yaml

plugins:
  riverpod_lint:
    version: ^3.1.3
    diagnostics:
      missing_provider_scope: false
      # … 끌 규칙을 이어 적는다
```

### 8. `example/` 이 저장소 루트의 분석에 섞이지 않게 한다

spike 의 연습용 프로젝트는 모두 `.planning/` 아래(점으로 시작하는 폴더)에 있어 루트 분석에 들어간 적이 없다. 실제 `example/` 은 점으로 시작하지 않으므로, **`example/` 을 만드는 같은 변경에서** 루트 `analysis_options.yaml` 의 exclude 에 한 줄을 더한다.

```yaml
# 루트 analysis_options.yaml — 기존 항목은 그대로 두고 한 줄을 더한다
analyzer:
  exclude:
    - lib/analysis_options.yaml
    - 'example/**'
```

저장소 루트에서 인자 없이 `dart analyze` 를 돌렸을 때 (커밋 전 린터가 이렇게 돈다):

| `example/` | 루트 제외 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|
| 없음 (지금의 저장소) | — | 0 | 0건 | 없음 | 0.5초 |
| 있음, `pub get` 전 | 없음 | **3** | **9건 (error 6)** | 없음 | 0.5초 |
| 있음, `pub get` 후 | 없음 | **2** | **4건 (plugin 2 포함)** | **있음** | 15초 |
| 있음, `pub get` 전 | `example/**` | 0 | 0건 | 없음 | 0.5초 |
| 있음, `pub get` 후 | `example/**` | 0 | 0건 | 없음 | 0.5초 |
| 있음, `pub get` 후 | `example` | 0 | 0건 | 없음 | 0.5초 |

제외하지 않으면 `pub get` 전후로 모양이 완전히 다르다.

- **전:** example 의 파일이 루트 패키지의 일부로 분석된다. 루트 패키지에는 `flutter` 가 없어 import 가 풀리지 않으므로 `uri_does_not_exist`, `extends_non_class` 같은 error 6건이 난다. 저장소를 새로 받은 직후의 상태다.
- **후:** `example/` 이 별도 context root 가 된다. 그 옵션 파일이 루트 옵션 파일로 읽혀 plugin 까지 준비되고(15초, 네트워크 필요) 2번의 진단 4건이 나온다.

**이 제외는 `example/` 안에서의 분석을 건드리지 않는다.** `example/` 을 작업 디렉터리로 두고 인자 없이 돌리면(검증 명령이 하는 실행) 루트 제외가 없든, `example/**` 이든, `example` 과 `example/**` 둘 다이든 exit 2 에 기대한 4건이 나왔다. 분석 대상의 루트가 `example/` 이면 상위 폴더의 옵션 파일은 읽히지 않는다.

제외가 있으면 루트 분석은 0.5초면 끝난다. plugin 준비는 `example/` 안에서의 분석 한 번에만 든다.

## What to Avoid

- **루트 제외 없이 `example/` 을 추가하는 것.** 커밋 전 린터(루트에서 `dart analyze`)가 저장소를 새로 받은 직후에는 exit 3, `example/` 의 패키지를 받은 뒤에는 exit 2 가 되고 15초와 네트워크가 든다.
- **"spike 의 연습용 프로젝트는 루트 분석에 섞이지 않았으니 `example/` 도 그럴 것"이라는 가정.** 섞이지 않은 것은 `.planning/` 이 점으로 시작하기 때문이다.
- **`example/` 에서 `flutter pub get` 을 돌리는 것.** 옵션 파일을 고친다. 분석 결과는 같지만 CI 에서 작업 트리가 바뀌고 로컬에는 커밋하지 않은 변경이 생긴다. 끄는 옵션은 Flutter 도구 소스에 없다.
- **`riverpod_syntax_error` 를 정답지에 넣는 것.** `riverpod_annotation` 의존성과 가짜 `typedef` 가 필요하고, 정답지의 종료 코드가 3 이 되어 "warning 이 사라졌다"를 종료 코드로 구별하지 못한다.
- **"코드 생성 없이 뜨는 후보는 6개"로 세는 것.** 5개다. `protected_notifier_properties` 는 `@riverpod` 가 붙은 class 안에서만 보고한다 (`if (enclosingClass.riverpod == null) return;`). 손으로 쓴 `Notifier` 에서 같은 위반을 한 대조 파일(`r04a_…_plain.dart`)에서는 진단이 나오지 않았다.
- **"`riverpod_lint` 규칙은 전부 warning"으로 적는 것.** `registerWarningRule` 은 강도가 아니라 "기본으로 켠다"는 뜻이다. 강도는 규칙마다 `LintCode(..., severity: …)` 로 따로 적고, 적지 않은 3개가 info 로 보고된다.
- **JSON 의 `type` 으로 강도를 읽는 것, `code` 에 `riverpod_lint/` 접두사가 있다고 가정하는 것.**
- **README 에 "프리셋을 include 하면 종료 코드 2" 라고 단정하는 것.** 위반이 없거나 info 뿐이면 0 이다. 쓸 수 있는 문장: "`riverpod_lint` 진단은 규칙에 따라 info / warning / error 로 보고된다. 프리셋을 include 한 프로젝트에 warning 규칙의 위반이 있으면 `dart analyze` 의 종료 코드는 2 다."
- **`example/` 에 `build_runner` / `riverpod_generator` 를 붙이는 것.** spike 003 의 연습용 프로젝트에만 붙였다 (02-CONTEXT.md D-02).
- **`build/**` 제외를 `example/analysis_options.yaml` 에 미리 적는 것.** `flutter pub get` 을 써도 안 바뀌게 되지만 옵션 파일이 "include 한 줄"이 아니게 되어 사용 프로젝트의 모습과 달라진다.

## Constraints

- plugin 은 `^3.1.3` 이 실행 시점의 최신 3.x 로 풀린다 (이번에는 3.1.9). 다음 버전에서 강도가 바뀔 수 있다. 정답지에 강도가 들어가므로 바뀌면 diff 로 드러난다.
- `riverpod_lint` 3.1.3 (배포 파일의 하한) 소스의 강도 선언 15개는 3.1.9 와 같다.
- 규칙 15개의 강도 표는 GitHub Linux runner 에서도 같았다 (새 가상 머신 10대).
- `flutter pub get` 의 동작 (`AnalysisOptionsMigration`, Flutter 3.47.5): `flutter` 에 의존하는 프로젝트이고 `analysis_options.yaml` 이 있으면 `build/**` 와 **존재하는 플랫폼 폴더**(`android/**`, `ios/**`, `web/**`, `windows/**`, `macos/**`, `linux/**`)가 `analyzer.exclude` 에 있는지 보고, 없으면 덧붙인다. 볼 때 `include:` 를 따라간다 (상대 경로와 `package:` URI 모두). 한 번만 고치고 그 뒤로는 그대로다.
- 사용 프로젝트에도 같은 일이 생긴다. 플랫폼 폴더가 있는 실제 앱에서 `flutter pub get` 을 돌리면 그 프로젝트의 옵션 파일에 제외 줄이 덧붙는다. 이 패키지의 문제는 아니다. include 한 파일이 이미 제외하고 있으면 덧붙지 않는다.
- **Phase 4 로 넘긴 것:** 프리셋에 `build/**` (그리고 플랫폼 폴더) 제외를 넣을지. 넣으면 사용 프로젝트의 `flutter pub get` 이 옵션 파일을 고치지 않는다.
- 하위 폴더가 별도 context root 가 되는 조건 (`analyzer` 14.5.0 의 `lib/src/dart/analysis/context_locator.dart`): 그 폴더의 package config(`.dart_tool/package_config.json`)가 상위 root 의 것과 다를 때다. 그래서 `example/` 에서 `pub get` 을 하기 전과 후에 루트 분석의 결과가 달라진다. 폴더 이름이 점으로 시작하거나 상위 root 의 exclude 에 걸리면 그 폴더로 들어가지 않는다.
- 루트 제외는 `example/**` 한 줄로 충분했다. 소스를 읽고는 "`example/**` 는 폴더 `example` 자체에는 맞지 않아 nested root 가 생길 수 있다"는 의문이 남았지만 실행에서는 제외됐다. `example` 만 적어도, 둘 다 적어도 결과가 같았다.
- 루트 제외가 없고 `pub get` 전일 때 example 의 파일에서 `avoid_print`, `prefer_single_quotes` 도 나왔다. `example/analysis_options.yaml` 이 루트 context 의 하위 옵션 파일로 읽히고 그 안의 `include: package:woody_lints/…` 가 루트 패키지 자신으로 풀린다는 뜻이다. 이때 `plugins_in_inner_options` 는 나오지 않았다 (`plugins:` 가 하위 옵션 파일에 직접 적힌 것이 아니라 include 로 들어왔다).
- 저장소 루트에서 `dart analyze example` 처럼 폴더를 인자로 준 형태는 루트 제외와 상관없이 4건이 나왔다. 채택한 형태가 아니다 (→ analyze-run-and-verdict.md).
- 8번의 표는 저장소의 모양을 작업 폴더에 복사한 replica 에서 쟀다 (`sources/007-root-analysis-with-example/probe.dart`). 두 번 돌려 두 번 모두 같았다.
- 확인하지 않은 것: 표의 아래 6개가 생성 코드 없이도 뜨는지 (`example/` 에 넣지 않을 규칙이다). `protected_notifier_properties` 는 손으로 쓴 `Notifier` 에서 뜨지 않는 것까지만 확인했다. 루트를 IDE 로 열었을 때 example 의 진단이 보이지 않게 되는지 (조사 문서의 예상이고 명령줄로는 잴 수 없다). 루트 제외를 GitHub Linux runner 에서 돌린 것 (context root 를 정하는 코드는 운영체제와 무관하다). `example/` 말고 연습용 프로젝트가 더 생겼을 때 (Phase 3 의 대조군 fixture — 폴더마다 제외 줄이 필요할 것이다).

## Origin

Synthesized from spikes: 003, 004, 007 (위반 코드와 기대 진단 파일은 001, 006 에서 가져왔다)
Source files available in: sources/003-riverpod-lint-severity-matrix/, sources/004-fixture-pub-get/, sources/007-root-analysis-with-example/, sources/001-analyze-invocation-form/fixture/, sources/006-github-runner-cold-plugin/expected_001.txt, sources/006-github-runner-cold-plugin/expected_003.txt
원본 로그와 JSON: `.planning/spikes/003-riverpod-lint-severity-matrix/results/`, `.planning/spikes/004-fixture-pub-get/results/`, `.planning/spikes/007-root-analysis-with-example/results/`
생성 코드(`*.g.dart`)는 사본에 넣지 않았다. 원본은 `.planning/spikes/003-riverpod-lint-severity-matrix/fixture/lib/gen/` 에 있다.
