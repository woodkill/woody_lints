---
spike: 007
idea: verify-harness-tool-behavior
name: root-analysis-with-example
type: standard
validates: "Given 저장소 루트에 점으로 시작하지 않는 `example/` 이 있을 때, when 루트에서 인자 없이 `dart analyze` 를 돌리면, then example 의 진단과 plugin 준비가 섞이는지와 루트의 `example/**` 제외가 이를 막는지가 확정된다"
verdict: VALIDATED
related: [001, 005]
tags: [dart-analyze, context-root, exclude, example, rule-check, analyzer-plugin]
---

# Spike 007: `example/` 이 생긴 뒤의 루트 분석

## What This Validates

Given 저장소 루트에 `example/` (자기 `pubspec.yaml`, include 한 줄, 위반 코드)이 있을 때,
when 저장소 루트에서 인자 없이 `dart analyze --format=json` 을 돌리면 (규칙 검사와 커밋 전 린터가 이렇게 돈다),
then (1) example 의 진단이 섞이는지, (2) plugin 준비까지 일어나는지, (3) 루트 옵션 파일에 `example/**` 제외를 더하면 사라지는지, (4) 그 제외가 `example/` 안에서의 분석을 건드리지 않는지가 확정된다.

spike 001~006 의 연습용 프로젝트는 모두 `.planning/` 아래(점으로 시작하는 폴더)에 있어 루트 분석에 섞인 적이 없다. 실제 `example/` 은 점으로 시작하지 않는다. spike 005 가 고른 규칙 검사("루트에서 인자 없이 분석하고 복사본의 진단만 고른다")가 `example/` 과 함께 있을 때 어떻게 되는지는 본 적이 없다. 02-CONTEXT.md 는 "루트 옵션 파일에 `example/**` exclude 를 더할지"를 계획에 맡겼다.

## Research

- `research/ARCHITECTURE.md` § "fixture 가 저장소 루트 분석에 섞이지 않게 하기", `research/PITFALLS.md` Pitfall 14: 소스를 읽고 "하위 폴더는 자기 `.dart_tool/package_config.json` 이 있을 때 별도 context root 가 된다", "그래서 `pub get` 전과 후에 루트 분석의 결과가 달라진다", "루트에서 `example/**` 를 exclude 하면 nested root 탐색에서도 빠진다"고 적었다. 실행한 적은 없다.
- `analyzer` 14.5.0 의 `lib/src/dart/analysis/context_locator.dart` (pub cache 의 소스)를 다시 읽었다.
  - `_createContextRoots`: 하위 폴더의 package config 가 상위 root 의 것과 다르면(`packageConfigFileToUse != containingRoot.packagesFile`) 새 context root 를 만든다.
  - `_createContextRootsIn` 의 `isExcluded`: 폴더 이름이 점으로 시작하거나, 상위 root 의 `excludedGlobs` 중 하나가 **그 폴더의 경로**에 맞으면 들어가지 않는다.
  - 읽고 남은 의문: `example/**` 는 `example` 아래의 경로에 맞는 모양이라 폴더 `example` 자체에는 맞지 않을 수 있다. 그렇다면 제외해도 nested root 가 생긴다. → 실행해 보니 제외됐다 (아래 A3). `example` 만 적어도 같았다 (A5).

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 루트 옵션 파일에 `example/**` 제외를 더한다 | `analyzer.exclude` | 루트 분석이 `example/` 의 상태와 무관해진다 | 루트를 IDE 로 열면 example 의 진단이 보이지 않는다 (조사 문서, 미확인) | **채택** |
| 제외하지 않고 검증 스크립트가 경로로 걸러 낸다 | — | 루트 옵션 파일을 그대로 둔다 | 루트 분석이 exit 2 / 3 이 되고 plugin 준비(15초, 네트워크)가 끼어든다 | 쓰지 않음 |
| 규칙 검사를 "루트에서 그 폴더를 인자로" 돌린다 | `dart analyze build/woody_rule_check` | example 의 상태, 루트 제외와 무관하다 | spike 005 에서는 `plugins:` 를 뺀 형태로 재지 않았다 | **채택** (이번에 잼) |

**Chosen approach:** 저장소를 건드리지 않도록 작업 폴더에 저장소의 모양을 복사한 replica 를 만들고, 그 안에서 `example/` 의 유무 / `pub get` 전후 / 루트 제외의 유무를 바꿔 가며 잰다.

## How to Run

```bash
# 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 에 복사해 실험한다 (약 3분).
fvm dart run .planning/spikes/007-root-analysis-with-example/probe.dart /tmp/spike007-work
```

`example/` 은 spike 001 의 연습용 프로젝트를 복사하고 의존성 경로만 `path: ..` 로 바꿔 만든다. 실행마다 빈 상태 폴더를 주므로 "plugin 준비 폴더 N개"가 그 실행에서 plugin 을 준비했는지를 뜻한다.

## What to Expect

실행마다 `exit`, 걸린 시간, 진단 수(`example/` 아래 / 그중 plugin / 규칙 검사 복사본 / 그 밖), plugin 준비 폴더 수를 한 줄로 찍고 그 아래에 진단을 정답지 형식으로 늘어놓는다.

## Investigation Trail

모두 Dart 3.13.4, macOS arm64, 2026-10-11. 두 번 돌려 두 번 모두 같았다.

### 1. 루트에서 인자 없이

| id | `example/` | 루트 제외 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|---|
| A0 | 없음 | — | 0 | 0건 | 없음 | 0.5초 |
| A1 | 있음, `pub get` 전 | 없음 | **3** | **9건 (error 6)** | 없음 | 0.5초 |
| A2 | 있음, `pub get` 후 | 없음 | **2** | **4건 (plugin 2 포함)** | **있음** | 15초 |
| A4 | 있음, `pub get` 전 | `example/**` | 0 | 0건 | 없음 | 0.5초 |
| A3 | 있음, `pub get` 후 | `example/**` | 0 | 0건 | 없음 | 0.5초 |
| A5 | 있음, `pub get` 후 | `example` | 0 | 0건 | 없음 | 0.5초 |
| A6 | 있음, `pub get` 후 | 둘 다 | 0 | 0건 | 없음 | 0.5초 |

- **제외하지 않으면 섞인다.** 그리고 `pub get` 전후로 모양이 완전히 다르다.
  - 전(A1): example 의 파일이 루트 패키지의 일부로 분석된다. 루트 패키지에는 `flutter` 가 없으므로 import 가 풀리지 않아 `uri_does_not_exist`, `extends_non_class` 같은 **error 6건**이 나고 종료 코드가 3 이다. 저장소를 새로 받은 직후의 상태다.
  - 후(A2): `example/` 이 별도 context root 가 된다. 그 옵션 파일이 루트 옵션 파일로 읽혀 **plugin 까지 준비되고**(15초, 네트워크 필요) plugin 진단 2건을 포함한 4건이 나온다. 종료 코드는 2 다.
- **`example/**` 를 제외하면 두 상태 모두 0건, exit 0, 0.5초다.** plugin 도 준비하지 않는다. 소스를 읽고 가진 의문과 달리 `example/**` 한 줄로 충분했다. `example` 만 적어도 같다.
- A1 에서 `avoid_print`, `prefer_single_quotes` 도 나왔다. `example/analysis_options.yaml` 이 루트 context 의 하위 옵션 파일로 읽히고, 그 안의 `include: package:woody_lints/…` 가 루트 패키지 자신으로 풀린다는 뜻이다. 이때 `plugins_in_inner_options` 는 나오지 않았다 (`plugins:` 가 하위 옵션 파일에 직접 적힌 것이 아니라 include 로 들어왔다).

### 2. `example/` 안에서 인자 없이 (검증 명령이 하는 실행)

| id | 루트 제외 | exit | 진단 |
|---|---|---|---|
| E2 | 없음 | 2 | 4건 (기대와 같음) |
| E3 | `example/**` | 2 | 4건 (기대와 같음) |
| E6 | `example` + `example/**` | 2 | 4건 (기대와 같음) |

**루트의 제외는 `example/` 안에서의 분석을 건드리지 않는다.** 분석 대상의 루트가 `example/` 이면 상위 폴더의 옵션 파일은 읽히지 않는다.

참고로 루트에서 `dart analyze example` 처럼 폴더를 인자로 준 형태(H2, H3)도 루트 제외와 상관없이 4건이 나왔다. 이 형태는 spike 001 에서 채택하지 않았고 여기서도 채택하지 않는다.

### 3. 규칙 검사 (문제 규칙 4개를 끼우고 `plugins:` 를 뺀 복사본을 `build/woody_rule_check/` 에 둔다)

| id | 루트 제외 | 실행 | exit | 복사본의 진단 | 섞인 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|---|---|
| R2a | 없음 | 루트에서 인자 없이 | 2 | 4건 | **example 4건** | **있음** | 15초 |
| R2b | 없음 | 루트에서 그 폴더를 인자로 | 2 | 4건 | 없음 | 없음 | 0.5초 |
| R3a | `example/**` | 루트에서 인자 없이 | 2 | 4건 | 없음 | 없음 | 0.5초 |
| R3b | `example/**` | 루트에서 그 폴더를 인자로 | 2 | 4건 | 없음 | 없음 | 0.5초 |

복사본의 진단 4건은 네 경우 모두 같다.

```text
build/woody_rule_check/analysis_options.yaml:41  warning  deprecated_lint
build/woody_rule_check/analysis_options.yaml:42  warning  deprecated_lint
build/woody_rule_check/analysis_options.yaml:43  warning  removed_lint
build/woody_rule_check/analysis_options.yaml:44  warning  undefined_lint
```

- **"그 폴더를 인자로"가 가장 덜 얽힌다** (R2b). 루트 제외가 없어도 example 을 훑지 않고 plugin 을 준비하지 않는다. deprecated 와 removed 가 보고되므로 루트 `pubspec.yaml` 의 SDK 하한도 그대로 적용된다.
- spike 005 가 고른 "루트에서 인자 없이"(R2a)는 루트 제외가 없으면 example 의 진단이 섞이고 15초가 든다. 루트 제외가 있으면(R3a) 폴더를 인자로 준 것과 같다.
- 문제 없는 복사본은 두 형태 모두 0건, exit 0 이었다 (P2b, P3a). 검증이 통과할 때의 모양이다.
- `plugins:` 섹션을 빼는 패턴을 이번에 Dart 로 옮겨 돌렸다 (`probe.dart` 의 `stripPlugins`). spike 005 는 python3 으로만 돌렸었다.

```dart
final stripped =
    options.replaceAll(RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true), '');
```

- 복사본의 줄 번호(41~44)는 원본에서 그 규칙을 적은 줄과 같다. `plugins:` 가 규칙 목록 **뒤에** 있어서 빼도 앞쪽 줄이 밀리지 않기 때문이다. 순서가 바뀌면 복사본의 줄 번호는 원본과 달라진다.

## Results

**Verdict: VALIDATED** — 네 가지가 모두 확정됐고, 조사 문서가 소스를 읽고 적은 내용이 실행으로 재현됐다.

1. 루트 제외가 없으면 루트 분석에 example 의 진단이 섞인다. `pub get` 전에는 error 6건(exit 3), 후에는 plugin 진단을 포함한 4건(exit 2)이다.
2. `pub get` 후에는 루트 분석이 plugin 까지 준비한다 (15초, 네트워크 필요).
3. 루트 옵션 파일에 `example/**` 를 제외하면 두 상태 모두 0건이다.
4. 그 제외는 `example/` 안에서의 분석을 건드리지 않는다.

Phase 2 의 계획이 가져갈 것:

1. **루트 `analysis_options.yaml` 의 exclude 에 `example/**` 한 줄을 더한다.** 기존 `lib/analysis_options.yaml` 제외는 그대로 둔다. 더하지 않으면 커밋 전 린터가 저장소를 새로 받은 직후에는 exit 3, 패키지를 받은 뒤에는 exit 2 가 된다.
2. **규칙 검사는 저장소 루트에서 복사본 폴더를 인자로 준다** — `dart --suppress-analytics analyze --format=json build/woody_rule_check`. 그 폴더의 진단만 나오므로 경로로 걸러 낼 필요가 없고, `example/` 의 상태와 루트 제외에 기대지 않는다. 복사할 때 `plugins:` 를 빼는 것은 그대로다 (빼지 않고 폴더를 인자로 주면 plugin 을 준비한다 — spike 005 의 4-6).
3. 검증 명령이 루트 분석(`tool/verify.dart` 자신의 lint 점검 등)을 따로 돌린다면 0.5초면 끝난다. plugin 준비는 `example/` 안에서의 분석 한 번에만 든다.

spike 005 의 결론에서 달라지는 것: 규칙 검사의 실행 형태가 "루트에서 인자 없이 + 복사본의 진단만 고름"에서 "루트에서 그 폴더를 인자로"가 된다. 복사본을 저장소 안에 두는 것, `plugins:` 를 빼는 것, 판정 기준(`deprecated_lint` / `removed_lint` / `undefined_lint`)은 그대로다.

확인하지 않은 것:

- 루트를 IDE 로 열었을 때 example 의 진단이 보이지 않는지 (조사 문서의 예상). 명령줄로는 잴 수 없다.
- GitHub Linux runner 에서의 같은 실행. context root 를 정하는 코드는 운영체제와 무관하다.
- `example/` 말고 연습용 프로젝트가 더 생겼을 때 (Phase 3 의 대조군 fixture). 폴더마다 제외 줄이 필요할 것이다.

원본: `results/probe.log`, `results/probe.json`.
