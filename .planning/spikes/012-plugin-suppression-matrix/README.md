---
spike: 012
idea: preset-split-include-behavior
name: plugin-suppression-matrix
type: standard
validates: "Given 묶음을 받는 연습용 프로젝트에 끄는 방법 여섯 칸(D-04)과 생성 파일 안의 Riverpod 위반을 둘 때, when 분석하면, then 칸마다 끈 것만 사라지고 옆의 같은 위반은 남는지와, plugin 이 // ignore_for_file 과 analyzer.exclude 를 따르는지가 확정된다"
verdict: PARTIAL
related: [003, 009, 010]
tags: [analyzer-plugin, ignore, exclude, override]
---

# Spike 012: 끄는 방법 여섯 칸과 plugin 의 제외

## What This Validates

ROADMAP.md Phase 3 "Spike first" 의 넷째 항목(plugin 이 `analyzer.exclude` 와 `// ignore_for_file` 을 존중하는지)과 03-CONTEXT.md D-04 의 표다. 결과가 어느 쪽이든 기록하고 계속 진행하는 항목이다 (D-07).

- **Given** 묶음(`recommended.yaml`)을 받는 연습용 프로젝트에, 규칙과 plugin 진단을 프로젝트 전체 / 파일 하나 / 한 줄에서 끄는 여섯 칸과 생성 파일 안의 Riverpod 위반을 둘 때
- **When** `dart analyze` 를 돌리면
- **Then** 칸마다 끈 것만 사라지고 옆의 같은 위반은 남는지, plugin 이 `// ignore_for_file` 과 `analyzer.exclude` 를 따르는지가 확정된다

**여섯 칸은 모두 성립했다. `analyzer.exclude` 는 "어디에 적었느냐" 에 따라 갈렸다** — 묶음에서 받은 생성 파일 제외는 규칙에는 통하고 plugin 에는 통하지 않는다.

## Research

읽은 소스는 plugin 이 실제로 쓰는 버전이다 — 전용 상태 폴더의 `pubspec.lock` 에 `analysis_server_plugin` 0.3.24, `analyzer` 14.5.0 으로 풀려 있다 (2026-10-12). 분석 서버 쪽은 Dart 3.13.4 에 든 analyzer(14.1.0-dev)다. **둘이 다른 버전이라는 점이 아래 결과의 원인이다.**

- 주석: `analysis_server_plugin` 의 `plugin_server.dart` 가 진단마다 `ignoreInfo.ignored(e, pluginName: …)` 을 부른다. `analyzer` 의 `IgnoredDiagnosticName._matches` 는 plugin 이름이 다르면 맞지 않는다고 본다. `// ignore:` 와 `// ignore_for_file:` 이 같은 함수를 쓴다 → 둘 다 `riverpod_lint/` 접두사가 필요하다는 추정.
- `type=…`: `IgnoredDiagnosticType._matches` 는 plugin 이름을 보지 않고 진단 코드의 종류(`LINT` / `STATIC_WARNING` / `HINT`)만 본다. spike 003 이 JSON 의 `type` 을 전부 `STATIC_WARNING` 으로 봤으므로 `type=warning` 이 끌 것이라고 추정했다 → **틀렸다** (아래 2번).
- 제외: `plugin_server.dart` 가 파일마다 `contextRoot.isAnalyzed` 를 본다 → plugin 이 제외를 따를 것이라는 추정. 그런데 pub cache 의 `context_locator.dart` 를 버전별로 견주니 **제외 패턴의 기준 폴더가 14.4.0 에서 바뀌었다.**

  | `analyzer` | `_getExcludedGlobs` 가 패턴을 푸는 기준 |
  |---|---|
  | 12.1.0, 13.3.0 | `optionsFile.parent` — context root 의 옵션 파일이 있는 폴더 |
  | 14.4.0, 14.5.0 | `excluded.declaringFile.parent` — **그 패턴을 적은 파일**이 있는 폴더 |

  `research/ARCHITECTURE.md` § A 가 "Dart 3.14 예정" 으로 적어 둔 변경(sdk commit 7c44c48)이다. SDK 에는 아직 들어오지 않았지만 pub.dev 의 analyzer 에는 이미 들어 있고, plugin 은 pub.dev 의 것을 쓴다.
- `diagnostics:` 의 값: `plugin_server.dart` 가 `error` / `warning` / `info` / `ignore` / `disable` / `enable` 을 받는다.

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 칸마다 끈 자리 옆에 끄지 않은 같은 위반을 둔다 | `lib/suppress/*.dart` | "꺼졌다" 가 헛통과가 아니다 (D-04) | 샘플이 는다 | **채택** |
| 끈 설정마다 실행을 따로 하고 줄 수만 센다 | — | 샘플이 적다 | 다른 줄이 함께 사라져도 모른다 | 쓰지 않음 |

**Chosen approach:** 주석으로 끄는 칸은 한 번의 실행에서 한꺼번에 보고, 프로젝트 전체에서 끄는 칸은 옵션 파일을 바꿔 가며 "끄지 않은 실행에서 그 진단의 줄만 뺀 것" 과 전체를 견준다. 규칙은 `prefer_single_quotes`(info), plugin 진단은 `provider_parameters`(warning)로 쟀다.

## How to Run

```bash
# 저장소의 파일은 읽기만 한다 (약 4분 30초, 네트워크 필요).
fvm dart run .planning/spikes/012-plugin-suppression-matrix/probe.dart /tmp/spike012-work
```

## What to Expect

칸마다 `나옴` / `안 나옴` 을 찍고, 소스를 읽어 세운 추정과 다르면 `≠` 를 붙인다. 끝의 `# 추정과 실제` 가 다른 칸을 모아 보여 주고, `# 판정` 15건이 모두 `✓` 이면 대조 자리와 전체 비교가 성립한 것이다.

## Investigation Trail

모두 Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64, 2026-10-12. 세 번 돌려 1부의 결과가 세 번 모두 같았다. 실행마다 빈 상태 폴더를 줬다.

### 1. 여섯 칸 (D-04)

| 층 | 규칙 (`prefer_single_quotes`) | plugin 진단 (`provider_parameters`) |
|---|---|---|
| 프로젝트 전체 | `linter: rules:` 에 `이름: false` (맵 문법) → **그 규칙의 4줄만 사라짐** | `plugins: riverpod_lint:` 에 `version` 과 `diagnostics: {이름: false}` → **그 진단의 7줄만 사라짐**, 다른 plugin 진단 2줄은 남음 |
| 파일 하나 | `// ignore_for_file: 이름` → 꺼짐 | `// ignore_for_file: riverpod_lint/이름` → **꺼짐** |
| 한 줄 | `// ignore: 이름` → 꺼짐, 옆의 같은 위반은 남음 | `// ignore: riverpod_lint/이름` → 꺼짐 (윗줄에 적든 같은 줄 끝에 적든), 옆의 같은 위반은 남음 |

함정 — 꺼지지 않는 모양:

| 적은 것 | 결과 |
|---|---|
| `// ignore: provider_parameters` (접두사 없음) | 꺼지지 않는다 |
| `// ignore_for_file: provider_parameters` (접두사 없음) | 꺼지지 않는다 |
| `plugins: riverpod_lint: diagnostics: {…: false}` (`version` 없음) | **꺼지지 않고, 경고도 없다.** 끄지 않은 실행과 25줄이 한 줄도 다르지 않았다 |
| `analyzer: errors: {provider_parameters: ignore}` | 꺼지지 않고 `analysis_options.yaml:5  warning  unrecognized_error_code` 가 붙는다 |
| `analyzer: errors: {riverpod_lint/provider_parameters: ignore}` | 위와 같다 |

그 밖에 본 것:

- 한 주석에 규칙과 plugin 진단을 함께 적을 수 있다 — `// ignore: prefer_single_quotes, riverpod_lint/provider_parameters` 가 둘 다 껐다.
- `version` 은 묶음과 **다른 값**(`^3.1.9`)을 적어도 꺼진다. 서버가 받은 선언은 사용 프로젝트가 적은 것이었다 — 같은 이름의 선언이 통째로 바뀐다 (spike 003 이 한 파일 구조에서 본 것과 같다).
- `diagnostics:` 에 강도를 적으면 그 강도로 바뀐다 — `provider_parameters: info` 로 7줄이 모두 info 가 됐다.

### 2. `// ignore_for_file: type=…` — 추정과 반대였다

| 파일 머리 | 규칙 진단 | plugin 진단 |
|---|---|---|
| `// ignore_for_file: type=lint` | 꺼짐 | **꺼짐** |
| `// ignore_for_file: type=warning` | 남음 | **남음** |

plugin 안에서 `riverpod_lint` 의 진단은 종류가 `LINT` 다. JSON 에 `type: STATIC_WARNING` 으로 나오는 것(spike 003)은 서버가 plugin 진단을 옮겨 적을 때 붙는 값이고 주석 판정에는 쓰이지 않는다.

실제 생성 파일은 이 머리를 달고 나온다 — spike 003 의 `riverpod_generator` 4.0.9 산출물 6개가 모두 10행에 `// ignore_for_file: type=lint, type=warning` 을 갖고 있다. 그런 파일에서는 제외가 통하지 않아도 plugin 진단이 나오지 않는다.

### 3. `analyzer.exclude` — 어디에 적었느냐에 따라 갈린다

생성 파일 샘플 `lib/generated/riverpod_violation.g.dart` 에 규칙 위반과 plugin 위반을 한 줄에 뒀다.

| id | `**/*.g.dart` 제외를 적은 곳 | 규칙 진단 | plugin 진단 |
|---|---|---|---|
| X2 | 없음 (`base.yaml` + `riverpod.yaml`) | 나옴 | 나옴 |
| J0 | 패키지의 `codegen.yaml` (묶음으로 받음) | 안 나옴 | **나옴** |
| G-old | 패키지의 `analysis_options.yaml` (나누기 전, 1.3.0 의 모양) | 안 나옴 | **나옴** |
| G-own | 사용 프로젝트의 `analysis_options.yaml` 에 직접 | 안 나옴 | 안 나옴 |
| G-local-root | 사용 프로젝트 루트의 `local_excludes.yaml` (include 로 부름) | 안 나옴 | 안 나옴 |
| G-local-sub | 사용 프로젝트의 `config/local_excludes.yaml` (include 로 부름) | 안 나옴 | **나옴** |
| X3 | 사용 프로젝트의 옵션 파일에 `lib/suppress/**` | `lib/suppress/` 아래 0줄 (끄지 않은 실행은 8줄) | 같이 0줄 |

- **plugin 은 제외 패턴을 "그 패턴을 적은 파일의 폴더" 기준으로 푼다.** G-local-root 와 G-local-sub 는 같은 내용의 파일을 폴더만 달리 둔 것이고 결과가 갈렸다. 소스에서 읽은 그대로다.
- 그래서 패키지 안에 적힌 `**/*.g.dart` 는 패키지 폴더 아래에서만 맞고, 사용 프로젝트의 생성 파일에는 맞지 않는다. 분석 서버(규칙 쪽)는 사용 프로젝트 루트 기준으로 풀어 제외한다.
- **나눠서 생긴 일이 아니다.** 나누기 전의 한 파일 구조(G-old)에서도 같다 — 1.3.0 이 이미 이렇게 동작한다.
- 사용 프로젝트가 자기 옵션 파일에 직접 적은 제외는 규칙과 plugin 이 둘 다 따르고, 묶음에서 받은 제외와 합쳐진다 (X3).

## Results

**Verdict: PARTIAL** — 끄는 방법 여섯 칸은 모두 성립했다. `// ignore_for_file` 은 접두사를 붙이면 plugin 이 따른다. `analyzer.exclude` 는 사용 프로젝트가 직접 적은 것만 plugin 이 따르고, **이 패키지가 `codegen.yaml` 로 주는 생성 파일 제외는 plugin 진단에는 통하지 않는다.** D-07 에 따라 기록하고 계속 진행한다.

Phase 3 의 계획이 가져갈 것:

1. **D-04 의 표는 그대로 연습용 프로젝트로 옮길 수 있다.** 여섯 칸이 모두 "끈 것만" 사라지게 한다. 대조 자리(끈 자리 옆의 같은 위반)는 이 spike 의 `lib/suppress/` 샘플 모양을 쓰면 된다.
2. 함정 둘(`version` 을 빼면 꺼지지 않는다 / 접두사가 없으면 꺼지지 않는다)이 이 저장소의 구조에서 재현됐다. **`version` 을 뺀 설정은 경고 없이 조용히 무시된다** — 연습용 프로젝트에 "꺼지지 않는 모양" 을 정답지에 남는 줄로 고정해 둘 가치가 있다.
3. **성공 기준 3 의 "생성 파일의 진단이 보고되지 않는다" 는 규칙 진단에 대해서만 참이다.** 지금의 `example/` 샘플(생성 파일에 규칙 위반만 있다)로는 성립한다. 생성 파일에 plugin 위반을 두면 `codegen.yaml` 을 받아도 그 줄이 나온다. 이 동작을 연습용 프로젝트에 있는 그대로 고정할지는 계획이 정한다 (D-07 의 "따르지 않는다로 나오면 그 동작을 있는 그대로 고정한다").
4. plugin 진단을 끄는 길은 `plugins:` 의 `diagnostics:` 와 주석뿐이다. `analyzer.errors` 로는 끌 수 없다.

Phase 5 (README) 로 넘길 것:

- 생성 파일 제외는 **사용 프로젝트의 `analysis_options.yaml` 에도 직접 적으라고 안내한다.** 조사가 "Dart 3.14 에서 필요해질 수 있다" 고 적은 안내에 지금의 이유가 생겼다 — plugin 진단에는 이미 통하지 않는다.
- `// ignore_for_file: type=lint` 를 단 생성 파일에서는 제외와 상관없이 plugin 진단이 나오지 않는다. `riverpod_generator` 4.0.9 의 산출물이 이 머리를 단다 (다른 생성기는 확인하지 않았다).
- plugin 진단을 프로젝트 전체에서 끌 때 `version` 은 묶음과 같지 않아도 되지만, 적은 값이 그 프로젝트의 plugin 버전 선언이 된다.
- `diagnostics:` 에 `info` / `warning` / `error` 를 적어 강도를 바꿀 수 있다.

spike 003 의 결론에서 달라지는 것: "JSON 의 `type` 은 전부 `STATIC_WARNING`" 은 그대로 맞다. 다만 그것으로 `// ignore_for_file: type=warning` 이 plugin 진단을 끈다고 미루어 볼 수는 없다 — 끄는 것은 `type=lint` 다.

확인하지 않은 것:

- Dart 3.14 의 분석 서버. 같은 변경이 SDK 에 들어오면 **규칙 진단에도** `codegen.yaml` 의 제외가 통하지 않게 될 것이다 — 소스를 읽은 추정이고 실행하지 않았다 (이 컴퓨터에 설치된 SDK 는 Dart 3.11.x 와 3.13.4 뿐이다). 그날 `example/` 의 정답지에 생성 파일 샘플의 4줄이 나타나 CI 가 먼저 깨진다.
- git 의존성으로 받았을 때. 패키지가 pub cache 에 놓여도 "패턴을 적은 파일의 폴더" 는 사용 프로젝트 밖이므로 같은 결과일 것이다 (추정).
- `**/*.freezed.dart`. 같은 코드가 처리한다.
- freezed · json_serializable 의 실제 산출물이 어떤 머리를 다는지. `riverpod_generator` 4.0.9 만 확인했다.
- `riverpod_lint` 의 다른 14개 진단. 주석과 제외를 처리하는 코드는 진단 이름과 무관하다.

원본: `results/probe.log`, `results/probe.json`.
