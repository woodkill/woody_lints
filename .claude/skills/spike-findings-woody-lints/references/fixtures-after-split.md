# 나눈 뒤의 연습용 프로젝트 여섯

프리셋을 나눈 뒤 검증 명령이 분석할 연습용 프로젝트 여섯(03-CONTEXT.md D-03)의 옵션 파일, 정답지의 모양, 폴더 배치와 루트 제외, 상태 폴더, 걸리는 시간이다. 지금의 `example/` (옛 주소 한 줄) 이 여섯 중 첫째다.

모든 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64 (프로세서 10개), 2026-10-12 실측이다. 실험은 저장소의 모양을 작업 폴더에 복사한 replica 에서 했고, 연습용 프로젝트의 샘플은 저장소 `example/lib` 의 복사본이다.

분석 한 번의 실행 형태(작업 디렉터리, `--suppress-analytics`, 상태 폴더, plugin 준비 실패 판정)는 analyze-run-and-verdict.md 를 그대로 따른다. 끄는 설정용 프로젝트(아래 표의 `overrides`)의 내용은 suppression-and-exclude.md 에 있다.

이 문서에서 "N번" 은 아래의 절 번호다. 프로젝트는 번호가 아니라 이름(`example`, `recommended`, `base_only`, `overrides`, `base_riverpod`, `base_codegen`)으로 부른다. 1번 절의 표 첫 칸에 있는 숫자는 03-CONTEXT.md D-03 의 표와 맞춘 순번이다. D-NN 은 모두 03-CONTEXT.md 의 것이다.

## Requirements

MANIFEST.md 의 `preset-split-include-behavior` 에서 이 영역에 걸리는 것.

소유자가 이전에 확정한 것 (출처는 03-CONTEXT.md, ROADMAP.md).

- 파일 이름은 `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml` 이고, `lib/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 한 줄짜리 별칭이다
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 하고, 스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다
- pub workspace 와 Riverpod major 차이는 재지 않는다 (D-08)

spike 에서 나와 실제 구현이 지켜야 하는 것.

- 연습용 프로젝트별 정답지의 모양: 기본만 `exit 2` · 18줄, 기본 + Riverpod `exit 2` · 21줄, 기본 + codegen `exit 0` · 13줄. "기본만" 이 `exit 0` 이 아닌 것은 `invalid_annotation_target` 이 warning 이라서다 (009)
- 새 연습용 프로젝트는 한 폴더 아래에 모으고 루트에서 `'<폴더>/**'` 한 줄로 제외한다. 기존 `example/**` 줄은 그대로 둔다. 제외하지 않으면 루트 분석에 그 폴더들의 진단이 섞이고 plugin 까지 준비한다 (011)
- 끄는 설정용 연습 프로젝트는 끈 자리 옆에 끄지 않은 같은 위반을 둔다. plugin 진단은 주석에 `riverpod_lint/` 접두사를 붙이고, 프로젝트 전체에서 끌 때는 `version` 을 함께 적는다. `version` 을 뺀 설정은 경고 없이 무시되고, `analyzer.errors` 로는 plugin 진단을 끌 수 없다 (012)
- 연습용 프로젝트는 폴더마다 따로 두고 상태 폴더도 프로젝트마다 따로 준다 (지금 검증 명령의 방식 그대로). 여섯이 로컬에서 처음 66초, 재실행 20 ~ 21초다. 상태 폴더를 하나로 합치면 plugin 폴더가 넷이 되어 버전을 읽지 못한다. plugin 준비는 경로가 다르면 나눠 쓰지 못한다 (014)
- 시간이 문제가 되면 상태 폴더를 따로 둔 채 동시에 띄우는 것을 먼저 본다 — 로컬에서 여섯이 23초이고 결과가 같았다. GitHub runner 에서의 여섯은 재지 않았다 (추정 약 4분 20 ~ 30초) (014)

## How to Build It

### 1. 여섯 조합과 옵션 파일

| # | 폴더 (spike 가 쓴 이름) | 옵션 파일 | plugin | 견주는 정답지 |
|---|---|---|---|---|
| 1 | `example/` | `include: package:woody_lints/analysis_options.yaml` (옛 주소) | 씀 | 지금의 `example/expected_diagnostics.txt` — `exit 2` · 16줄. 바꾸지 않는다 |
| 2 | `fixtures/recommended/` | `include: package:woody_lints/recommended.yaml` | 씀 | **`example/` 의 정답지** (자기 것을 두지 않는다 — D-03) |
| 3 | `fixtures/base_only/` | `include: package:woody_lints/base.yaml` | 안 씀 | `exit 2` · 18줄 |
| 4 | `fixtures/overrides/` | 묶음 + 끄는 설정 | 씀 | 끈 것만 빠진 줄 (→ suppression-and-exclude.md) |
| 5 | `fixtures/base_riverpod/` | `base.yaml` + `riverpod.yaml` 의 목록 | 씀 | `exit 2` · 21줄 |
| 6 | `fixtures/base_codegen/` | `base.yaml` + `codegen.yaml` 의 목록 | 안 씀 | `exit 0` · 13줄 |

폴더 자리와 이름은 예시다. 계획이 정한다 (03-CONTEXT.md). `example/` 의 경로만 그대로다.

```yaml
# base_riverpod 의 옵션 파일 — 조각 둘을 목록으로 부른다 (Replica.includeList 가 쓴 모양)
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml
```

위의 `#` 줄은 여기서 붙인 설명이다. spike 의 옵션 파일에는 include 만 있었다.

- 정답지는 다섯 개가 된다 (`recommended` 가 `example/` 의 것을 쓴다). 옛 주소와 묶음 주소의 결과가 줄 단위로 같다는 것은 010 이 확인했다.
- 목록의 순서는 결과를 바꾸지 않는다 (009).
- **`overrides` 의 옵션 파일과 정답지는 여기서 정해지지 않는다.** 어느 규칙과 어느 plugin 진단을 끌지, 프로젝트를 하나로 둘지 둘로 나눌지는 계획이 정한다 (D-04). 정할 때 걸리는 점이 suppression-and-exclude.md 8번에 있다.

### 2. 정답지의 모양

지금의 정답지(16줄)에서 빼고 더해 셈한 예상이 실제 분석과 같았다 (009, 011, 014).

| 연습용 프로젝트 | 맨 위 줄 | 줄 수 | 지금의 정답지에서 달라지는 것 |
|---|---|---|---|
| 옛 주소 / 묶음 | `exit 2` | 16 | 없음 |
| 기본만 | `exit 2` | 18 | `riverpod_lint` 3줄이 빠지고, 아래 5줄이 더해진다 |
| 기본 + Riverpod | `exit 2` | 21 | 아래 5줄이 더해진다 |
| 기본 + codegen | **`exit 0`** | 13 | `riverpod_lint` 3줄이 빠진다 |

codegen 조각을 받지 않으면 더해지는 5줄.

```text
lib/generated/sample.freezed.dart:4  info  avoid_print
lib/generated/sample.freezed.dart:4  info  prefer_single_quotes
lib/generated/sample.g.dart:4  info  avoid_print
lib/generated/sample.g.dart:4  info  prefer_single_quotes
lib/should_not_appear.dart:5  warning  invalid_annotation_target
```

Riverpod 조각을 받지 않으면 빠지는 3줄.

```text
lib/main.dart:5  warning  missing_provider_scope
lib/riverpod_rules.dart:17  warning  provider_parameters
lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties
```

- **줄 수는 진단 줄만 센 것이다.** 실제 정답지 파일은 `#` 로 시작하는 머리 주석(실측한 버전 · 날짜, 형식 안내) 다음에 `exit N` 한 줄, 그 아래에 진단 줄이 온다. "맨 위 줄" 은 그 `exit N` 줄이고, 머리 주석과 `exit N` 줄은 줄 수에 넣지 않았다. 지금의 정답지는 `example/expected_diagnostics.txt` 다. 새 프로젝트의 정답지를 어디에 어떤 이름으로 둘지는 계획이 정한다.
- **"기본만" 의 맨 위 줄은 `exit 0` 이 아니라 `exit 2` 다.** 규칙 진단은 전부 info 지만 `invalid_annotation_target` 이 warning 이다. 종료 코드가 0 인 것은 "기본 + codegen" 하나뿐이다.
- 이 셈은 샘플이 `example/lib` 의 복사본일 때 성립한다. 그 프로젝트에만 필요한 샘플을 더하면 그만큼 줄이 는다.
- 실제 정답지는 `--update` 가 쓴다 (03-CONTEXT.md D-05). 위 표는 처음 쓰인 정답지를 읽을 때 견줄 기준이다.

```dart
// sources/009-preset-plugin-via-include/replica.dart 의 Expected 에서
/// 그 조합이 내야 하는 줄 — 정답지에서 빼고 더해 만든다 (03-CONTEXT.md D-02 · D-03).
List<String> predicted({required bool riverpod, required bool codegen}) {
  final out = [
    for (final l in lines)
      if (riverpod || !pluginCodes.any((c) => l.endsWith('  $c'))) l,
    if (!codegen) ...generatedLines,
    if (!codegen) annotationLine,
  ];
  return out..sort();
}
```

### 3. 폴더 배치와 샘플 소스

프로젝트마다 폴더를 따로 두고 그 안에 `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `lib/` 를 둔다. spike 는 `example/` 의 것을 복사하고 의존성 경로만 폴더 깊이에 맞췄다 (`fixtures/<이름>/` 이면 `path: ../..`).

```dart
// sources/009-preset-plugin-via-include/replica.dart 의 Replica.addFixture 에서
final up = List.filled(rel.split('/').length, '..').join('/');
final pubspec = File('$repoRoot/example/pubspec.yaml').readAsStringSync();
final lock = File('$repoRoot/example/pubspec.lock').readAsStringSync();
if (!pubspec.contains('    path: ..\n') || !lock.contains('      path: ".."\n')) {
  throw const FormatException('example 의 pubspec.yaml / pubspec.lock 에서 path 줄을 찾지 못했다');
}
File('$dir/pubspec.yaml')
    .writeAsStringSync(pubspec.replaceAll('    path: ..\n', '    path: $up\n'));
File('$dir/pubspec.lock')
    .writeAsStringSync(lock.replaceAll('      path: ".."\n', '      path: "$up"\n'));
```

- `pubspec.lock` 에도 `path:` 줄이 있다. `pubspec.yaml` 만 고치면 lock 과 어긋난다.
- **샘플 소스는 프로젝트마다 복사본을 커밋하는 것을 기본으로 한다** (014 의 권고). `recommended` 는 `example/` 의 정답지와 견주므로 같은 상대 경로의 진단을 내야 하고, 그 복사본이 `example/lib` 와 어긋나면 정답지 비교가 잡는다 — 샘플이 다르면 진단이 달라진다. 나머지 넷은 자기 정답지와 견주므로 이 구성으로는 복사본의 어긋남이 잡히지 않는다. 어긋난 복사본으로 돌려 본 것은 아니다.
- 샘플을 심볼릭 링크로 나눠 쓰는 것(`fixtures/linked/lib` → `../../example/lib`)도 macOS 에서는 동작했다 — 정답지와 한 줄도 다르지 않았고, 진단의 경로는 링크를 푼 경로가 아니라 그 프로젝트 기준(`lib/added_rules.dart`)으로 나왔다. Windows 와 Linux 에서는 재지 않았다.
- `pub get` 은 여섯을 합쳐 1.3초다 (lock 이 있고 pub cache 가 채워져 있을 때).
- 새 프로젝트의 `pubspec.lock` 을 커밋하려면 `.gitignore` 에 `example/` 처럼 예외가 필요하다 (03-CONTEXT.md 의 기본값이고 spike 가 잰 것은 아니다).

### 4. 루트 제외 한 줄

새 프로젝트를 한 폴더(`fixtures/`) 아래에 모으면 루트 옵션 파일의 제외는 **한 줄**이다. `example/` 옆에 `fixtures/base_riverpod/`, `fixtures/base_only/` 를 두고 저장소 루트에서 인자 없이 분석했을 때 (011):

| `fixtures/` 의 상태 | 루트 제외 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|
| `pub get` 전 | `example/**` + `fixtures/**` | 0 | 0건 | 없음 | 0.6초 |
| `pub get` 후 | `example/**` 만 | **2** | **39건** (전부 `fixtures/` 아래, plugin 3 포함) | **있음** | 18 ~ 22초 |
| `pub get` 후 | `example/**` + `fixtures/**` | 0 | 0건 | 없음 | 0.6초 |
| 옵션 파일에 `plugins:` 를 직접 적은 폴더(끄는 설정용)를 더함, `pub get` 전 · 후 | `example/**` + `fixtures/**` | 0 | 0건 | 없음 | 0.5초 |

- 이 제외는 폴더 안에서의 분석을 건드리지 않는다. 루트에 `fixtures/**` 제외가 있는 채로 `fixtures/base_riverpod` 안에서 인자 없이 돌리면 예상한 21줄 · exit 2 · plugin 폴더 1, `fixtures/base_only` 안에서는 18줄 · exit 2 · plugin 폴더 0 이었다.
- 끄는 설정용 프로젝트는 옵션 파일에 `plugins:` 를 직접 적는다. 제외되어 있으면 `pub get` 전에도 `plugins_in_inner_options` 가 나지 않는다.
- 루트 옵션 파일의 나머지 모양(`lib/analysis_options.yaml` 제외를 지우는 시점 등)은 preset-split-structure.md 6번에 있다.

### 5. 상태 폴더는 프로젝트마다 따로

Phase 2 의 `tool/verify.dart` 는 `fixtures` 목록(지금은 `example` 하나)을 차례로 돌며 `<저장소 루트>/.dart_tool/woody_verify/<이름>/` 을 상태 폴더로 준다. 이 방식을 여섯으로 그대로 늘린다. 프로젝트가 `fixtures/<이름>/` 처럼 한 단계 아래에 있을 때 상태 폴더의 `<이름>` 을 어떻게 지을지는 계획이 정한다 (014 는 작업 폴더의 `state/<마지막 폴더 이름>` 을 썼다).

| 방식 | 처음 실행 | 재실행 | plugin 폴더 | 진단 |
|---|---|---|---|---|
| **A. 폴더 · 상태 폴더 따로 (채택)** | 66.1 / 65.9초 | 20.1 / 20.9초 | 상태 폴더마다 1 | 여섯 다 예상과 같음 |
| A'. 상태 폴더 하나를 함께 | 54.7 / 56.7초 | 15.0 / 15.1초 | **한 폴더에 4** | 같음 |
| P. A 를 동시에 — 여섯 | 벽시계 22.8 / 23.1초 | — | 상태 폴더마다 1 | 같음 |
| B. 작업 폴더 하나에서 옵션 파일만 바꿔 가며 | 27.2 / 28.4초 | 15.2 / 15.7초 | 1 | 여섯 옵션 다 같음 |

두 번 돌린 값을 `첫 번째 / 두 번째` 로 적었다.

- **상태 폴더를 합치지 않는다 (A').** plugin 폴더가 넷이 되어 버전을 읽을 수 없다 (전용 상태 폴더에 plugin 폴더가 하나일 때만 읽는다 → analyze-run-and-verdict.md 8번). 얻는 것은 처음 9 ~ 11초, 재실행 5초다.
- **plugin 을 쓰지 않는 프로젝트(기본만, 기본 + codegen)의 상태 폴더에는 plugin 폴더가 생기지 않는다.** 이 둘의 `plugin` 줄을 무엇으로 찍을지는 계획이 정한다 — 014 는 "해당 없음" 을 제안했다. Phase 2 의 코드는 폴더가 0개면 `?` 를 찍고, 그 실행의 `--update` 는 머리 주석에 `riverpod_lint ?` 를 쓴다 (`02-VERIFICATION.md` 의 "다음 phase 가 알아야 할 것" 5번).
- B 는 가장 빠른 차례 실행이지만 "커밋된 폴더를 그대로 분석한다" 를 포기해야 한다 — 실행할 때 커밋된 폴더를 작업 폴더로 복사하고 의존성 경로와 `pub get` 을 스크립트가 맡는다. spike 는 옵션 파일만 바꿨고 그 복사 단계는 돌리지 않았다.

### 6. 프로젝트 하나의 시간

두 번째 실행의 값이다 (초).

| 프로젝트 | A 처음 | A 재실행 | A' 처음 | B 처음 |
|---|---|---|---|---|
| example (옛 주소) | 15.1 | 3.5 | 15.9 | 16.5 |
| recommended | 15.2 | 3.5 | 13.2 | 3.4 |
| base_only — plugin 없음 | 3.2 | 3.2 | 0.7 | 0.7 |
| overrides | 15.3 | 3.6 | 13.1 | 3.5 |
| base_riverpod | 13.9 | 3.5 | 13.1 | 3.5 |
| base_codegen — plugin 없음 | 3.3 | 3.6 | 0.7 | 0.7 |

- plugin 을 쓰는 프로젝트는 폴더가 다르면 매번 컴파일한다. 상태 폴더를 함께 써도(A') 둘째부터 13초다 — 줄어든 2초는 컴파일이 아니라 분석 캐시다.
- plugin 을 쓰지 않는 프로젝트는 자기만 쓰는 상태 폴더에서 약 3초, 다른 프로젝트가 채워 둔 상태 폴더에서 0.7초다. A 의 재실행(20초)에서 plugin 없는 둘이 3초씩 든다.

### 7. 시간이 문제가 되면 — 동시에 띄우기

상태 폴더가 이미 프로젝트마다 따로라 구조를 바꾸지 않고 동시에 띄울 수 있다.

```dart
// sources/014-multi-fixture-plugin-cost/probe.dart 의 parallel 에서
final runs = await Future.wait([
  for (final fx in fxs)
    replica.analyze(
      id: '$tag-${fx.rel.split('/').last}',
      title: fx.name,
      cwd: '$root/${fx.rel}',
      stateDir: state('$tag-${fx.rel.split('/').last}'),
      quiet: true,
    ),
]);
```

| 무엇 | 벽시계 | 하나씩의 시간을 더하면 | 결과 |
|---|---|---|---|
| plugin 을 쓰는 넷, 처음 실행 | 20.9 / 21.6초 | 83.1 / 83.5초 | 넷 다 예상과 같음 |
| 여섯 모두, 처음 실행 | 22.8 / 23.1초 | 101.4 / 103.1초 | 여섯 다 예상과 같음 |

- 차례로 돌린 66초가 23초가 된다. 하나하나는 느려진다 (15초 → 21 ~ 23초).
- 두 번의 실행에서 20건(4 + 6, 두 번)이 모두 통과했다.
- 화면에 찍는 순서를 따로 맞춰야 한다. 프로세서가 적은 기계(GitHub runner)에서의 이득은 재지 않았다.

### 8. GitHub 자동 점검 시간 (추정)

**올려야 잴 수 있다.** 아래는 지금의 job 에서 셈한 값이다.

| 방식 | 셈 | 분석 | job 전체 |
|---|---|---|---|
| A | plugin 넷 × 약 44초 + plugin 없는 둘 × 약 9초 | 약 3분 15초 | **약 4분 20 ~ 30초** |
| B | 44초 + 재실행 셋 × 약 8초 + plugin 없는 둘 × 약 2초 | 약 1분 15초 | 약 2분 25초 |

- 근거: 지금의 job 이 1분 54초이고 그중 `example/` 분석이 약 44초, 그 밖이 약 70초다 (run 38158088016). runner 의 재실행은 약 8초다 (006). plugin 없는 프로젝트의 9초는 로컬 3.2초에 runner / 로컬 비(약 2.9 — 014 가 쓴 값이고, runner 약 44초와 이번 로컬 약 15초의 비와 맞는다)를 곱한 값이다. ci-workflow.md 가 006 에서 적은 "2.5배쯤" 은 로컬의 처음 실행을 약 17초로 본 값이다. 어느 쪽을 곱해도 이 항은 8 ~ 9초다.
- 추정대로라면 `timeout-minutes: 10` 안에 든다. phase 를 끝내기 전에 올려서 본다 (03-CONTEXT.md D-09).

## What to Avoid

- **상태 폴더를 하나로 합치는 것.** plugin 폴더가 넷이 되어 `plugin` 줄이 `?` 가 된다.
- **새 폴더를 루트에서 제외하지 않는 것.** 커밋 전 린터에 39건이 섞이고 plugin 준비로 18 ~ 22초와 네트워크가 든다.
- **연습용 프로젝트마다 루트 제외 줄을 하나씩 더하는 것.** 한 폴더 아래에 모으면 한 줄이다.
- **"기본만" 의 정답지를 `exit 0` 으로 예상하는 것.** `invalid_annotation_target` 한 줄 때문에 `exit 2` 다.
- **`recommended` (묶음을 받는 프로젝트)에 자기 정답지를 따로 두는 것.** `example/` 의 정답지와 견줘야 "옛 주소와 묶음이 같은 진단을 낸다" 가 구조로 묶인다 (D-03).
- **plugin 폴더가 0개인 것을 실패로 치는 것.** plugin 을 선언하지 않는 조합에서는 정상이다. 반대로 plugin 을 쓰는 조합에서 0개면 서버가 plugin 준비를 시작하지 않은 것이다.
- **plugin 을 쓰는 프로젝트 넷이 plugin 준비를 나눠 쓸 것이라는 기대.** 경로가 다르면 폴더가 따로 생기고 따로 컴파일한다. 나눠 쓰는 길은 같은 경로에서 분석하는 것(B)뿐이다.
- **연습용 프로젝트를 `example/` 안에 두는 것.** `example/` 의 분석에 섞일 것이라 재지 않았다.
- **연습용 프로젝트를 pub workspace 멤버로 만드는 것.** 하지 않기로 한 것이다 (03-CONTEXT.md, 02-CONTEXT.md).
- **연습용 프로젝트에서 `flutter pub get` 을 돌리는 것.** 옵션 파일을 고친다 (004 → example-project-and-expected-file.md).

## Constraints

- plugin 폴더의 이름은 분석 대상 패키지 루트 경로에서 나온다 (008). 그래서 폴더가 다르면 plugin 을 따로 컴파일하고(약 13초), 같은 경로에서 옵션 파일만 바꾸면(B) 다시 컴파일하지 않는다. 끄는 설정처럼 `plugins:` 를 다시 적은 옵션도 `version` 이 같으면 그대로 쓴다.
- B 에서 옵션 파일만 바꿔 같은 상태 폴더로 돌려도 여섯 결과가 모두 예상과 같았다 (처음 · 재실행 각 6번). 분석 캐시가 앞 옵션의 결과를 끌고 오지 않는다.
- 014 의 "overrides" 는 묶음에 `provider_parameters` 하나를 끈 옵션으로 쟀다 (정답지에서 그 한 줄을 뺀 15줄, `exit 2`). 실제 끄는 설정용 프로젝트는 샘플과 끄는 설정이 더 많다 — 시간에는 영향이 작겠지만 재지 않았다.
- 상태 폴더를 따로 주고 동시에 띄우는 것은 008 이 2쌍으로 봤고, 014 가 넷 · 여섯으로 두 번씩 돌려 모두 통과했다. 빈 상태 폴더 **하나를 함께** 쓰는 동시 실행은 드물게 깨진다 (008 — 20쌍 중 1쌍).
- 014 는 두 번 돌려 48건씩 모두 성립했고 방식별 시간이 1 ~ 2초 안에서 재현됐다. pub cache 는 채워진 상태였다.
- 첫 실행의 로그(`results/probe-run1.log`) 끝의 `pub get 여섯  259.0` 은 스톱워치를 멈추지 않은 스크립트의 잘못이다. 실제 값은 같은 로그 위쪽의 `합계 1.3초` 다.
- 확인하지 않은 것: GitHub Linux runner 에서의 여섯, 프로세서가 적은 기계에서의 동시 실행, pub cache 가 빈 상태의 `pub get` (runner 의 첫 프로젝트 — 여섯이 같은 패키지를 쓰므로 둘째부터는 채워진 상태다), Windows 와 Linux 에서의 심볼릭 링크, B 를 실제 검증 명령으로 옮긴 것, 상태 폴더가 여섯일 때의 디스크 사용량 (plugin 을 쓰는 넷마다 약 15MB 의 `plugin.aot` 이 생긴다), 프로젝트가 여럿일 때 `--update` 의 쓰기 순서와 화면.

## Origin

Synthesized from spikes: 009, 011, 014 (끄는 설정용 프로젝트의 요구 사항 한 줄은 012 에서 왔다)
Source files available in: sources/009-preset-plugin-via-include/, sources/011-root-analysis-after-split/, sources/014-multi-fixture-plugin-cost/
원본 로그와 JSON: `.planning/spikes/009-preset-plugin-via-include/results/`, `.planning/spikes/011-root-analysis-after-split/results/`, `.planning/spikes/014-multi-fixture-plugin-cost/results/` (014 는 `probe-run1.*` 이 첫 번째, `probe.*` 이 두 번째 실행이다)
