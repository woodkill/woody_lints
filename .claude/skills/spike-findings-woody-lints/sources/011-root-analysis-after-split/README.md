---
spike: 011
idea: preset-split-include-behavior
name: root-analysis-after-split
type: standard
validates: "Given 배포 파일을 조각 · 묶음 · 별칭으로 나눈 복사본에서 루트 옵션 파일의 lib/analysis_options.yaml 제외를 걷어냈을 때, when 저장소 루트에서 인자 없이 dart analyze 를 돌리면, then plugins_in_inner_options 를 포함해 0건이고 plugin 을 준비하지 않으며 연습용 프로젝트 폴더가 여럿이어도 섞이지 않는다"
verdict: VALIDATED
related: [007, 009, 010, 005]
tags: [dart-analyze, context-root, exclude, plugins-in-inner-options]
---

# Spike 011: 나눈 뒤의 저장소 루트 분석

## What This Validates

ROADMAP.md Phase 3 "Spike first" 의 첫 항목 (b) 이고, 성공 기준 4 (PRESET-06) 의 근거다. spike 007 이 재지 않고 남긴 "연습용 프로젝트가 더 생겼을 때" 도 함께 쟀다.

- **Given** 배포 파일을 조각 셋 · 묶음 · 한 줄짜리 별칭으로 나눈 복사본에서 루트 옵션 파일의 `lib/analysis_options.yaml` 제외를 걷어냈을 때
- **When** 저장소 루트에서 인자 없이 `dart analyze` 를 돌리면 (커밋 전 린터와 같은 실행)
- **Then** `plugins_in_inner_options` 를 포함해 진단이 0건이고, plugin 을 준비하지 않으며, 연습용 프로젝트 폴더가 여럿이어도 루트 분석에 섞이지 않는다

통과하지 못하면 phase 를 멈춘다. **통과했다.**

## Research

- 소스 (SDK tag 3.13.4, `research/ARCHITECTURE.md` § B · `PITFALLS.md` Pitfall 8 이 옮겨 둠): `plugins_in_inner_options` 는 `file.parent != contextRoot && isInitialFile` 일 때, 그리고 그 파일 **자신**이 `plugins:` 를 가질 때만 보고된다. include 로 닿은 파일은 대상이 아니다. 지금 경고가 나는 이유는 `plugins:` 를 담은 파일의 **이름**이 `analysis_options.yaml` 이라 `lib/` 의 옵션 파일로 직접 분석되기 때문이다.
- 이 저장소에서 이미 본 것: 하위 옵션 파일이 include 로 `plugins:` 를 받았을 때는 `plugins_in_inner_options` 가 나오지 않았다 (spike 007 의 A1). 다만 그때의 하위 파일은 `example/analysis_options.yaml` 이었다.
- pub.dev 의 `analyzer` 14.4.0 / 14.5.0 에서는 `PLUGINS_IN_INNER_OPTIONS` 가 "제거된 진단 코드" 목록에 들어 있다 (`analysis_options_parse_model.dart` 의 `removedCodeNames`). Dart 3.13.4 에 든 analyzer 에는 아직 살아 있다 — 아래 R1 에서 실제로 났다.
- context root: 하위 폴더가 자기 `.dart_tool/package_config.json` 을 가지면 별도 context root 가 되고, 상위 root 의 제외 glob 에 맞는 폴더는 들어가지 않는다 (spike 007 이 읽고 실행한 `context_locator.dart`).

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 나눈 뒤 제외를 걷어낸다 | 루트 `analyzer.exclude` 에서 한 줄 삭제 | 유일한 배포 산출물이 자체 분석에 다시 들어온다. 별칭 사슬이 깨지면 루트 분석이 알려 준다 | — | **채택 (됨)** |
| 제외를 남겨 둔다 | 그대로 | 변경 없음 | PRESET-06 을 채우지 못한다. 별칭이 깨져도 루트 분석이 모른다 | 쓰지 않음 |
| 새 연습용 프로젝트를 `fixtures/<이름>/` 에 모은다 | 루트에 `fixtures/**` 한 줄 | 폴더가 늘어도 제외 줄이 늘지 않는다 | 폴더 이름은 계획이 정한다 (03-CONTEXT.md Claude's Discretion) | **잼 — 한 줄로 충분** |

**Chosen approach:** spike 007 과 같은 방식(저장소의 모양을 복사한 replica 의 루트에서 인자 없이 분석, 실행마다 빈 상태 폴더)으로 한 파일 구조와 나눈 구조를 나란히 잰다.

## How to Run

```bash
# 저장소의 파일은 읽기만 한다 (약 1분 30초, 네트워크 필요).
fvm dart run .planning/spikes/011-root-analysis-after-split/probe.dart /tmp/spike011-work
```

## What to Expect

경우마다 `exit`, 시간, 진단 수, plugin 준비 폴더 수를 찍고 진단이 있으면 메시지와 함께 늘어놓는다. 끝의 `# 판정` 이 20건 모두 `✓` 이면 통과다.

## Investigation Trail

모두 Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64, 2026-10-12. 두 번 돌려 두 번 모두 같았다. replica 에는 저장소의 `tool/verify.dart` 도 복사해 뒀다 (루트 분석이 실제로 보는 Dart 파일).

### 1. 제외를 걷어낸다

| id | `lib/` 의 구조 | 루트의 `lib/analysis_options.yaml` 제외 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|---|
| R0 | 한 파일 (지금) | 있음 | 0 | 0건 | 없음 | 0.7초 |
| R1 | 한 파일 (지금) | **없음** | **2** | **1건** | 없음 | 0.6초 |
| R2 | 나눔, `package:` 주소 | **없음** | **0** | **0건** | **없음** | 0.6초 |
| R3 | 나눔 | 있음 (남겨 둠) | 0 | 0건 | 없음 | 0.6초 |
| R2-rel | 나눔, 상대 경로 | 없음 | 0 | 0건 | 없음 | 0.6초 |

R1 의 한 건 — 지금 제외가 있는 이유가 재현됐다.

```text
lib/analysis_options.yaml:58  warning  plugins_in_inner_options
  Plugins can only be specified in the root of a pub workspace or the root of a package that isn't in a workspace.
```

- **나눈 구조에서는 제외를 걷어내도 0건이다.** `lib/analysis_options.yaml` 이 include 한 줄뿐이고 `plugins:` 는 `riverpod.yaml` 에 있어서다. `riverpod.yaml` 은 이름이 달라 옵션 파일로 직접 분석되지 않는다.
- 루트 분석은 plugin 을 준비하지 않는다. `lib/` 의 별칭이 include 로 `plugins:` 를 받아도 그것은 하위 옵션 파일의 설정이라 서버가 쓰지 않는다 (빈 상태 폴더에 `.plugin_manager` 가 생기지 않았다).

### 2. 걷어낸 뒤에는 루트 분석이 별칭 사슬을 본다

| id | 바꾼 것 | exit | 진단 |
|---|---|---|---|
| R5 | 묶음이 없는 조각(`no_such_fragment.yaml`)을 부름 | 2 | `lib/analysis_options.yaml:1  warning  include_file_not_found` |

메시지에 깨진 자리가 적힌다: `The URI 'package:woody_lints/no_such_fragment.yaml' included in '<replica>/lib/recommended.yaml' can't be found …`. 진단이 붙는 파일은 묶음이 아니라 **별칭**이다 (직접 분석되는 것은 `analysis_options.yaml` 이름의 파일뿐이다).

제외를 걷어내면 커밋 전 린터(`fvm dart analyze`, 0.6초)가 "옛 주소에서 조각까지의 사슬이 풀리는가" 를 덤으로 확인한다.

### 3. 패키지를 받기 전 (저장소를 새로 받은 직후)

| id | 구조 | exit | 진단 |
|---|---|---|---|
| C0 | 한 파일, 지금의 루트 옵션 | 2 | 1건 — 루트 옵션 파일의 `include_file_not_found` (`flutter_lints`) |
| C1 | 나눔, `package:` 주소, 제외 없음 | 2 | 2건 — 위의 것 + `lib/analysis_options.yaml:1` (`package:woody_lints/recommended.yaml` 을 못 찾음) |
| C2 | 나눔, 상대 경로, 제외 없음 | 2 | 2건 — 위의 것 + `lib/analysis_options.yaml:1` (`base.yaml` 안의 `flutter_lints` 를 못 찾음) |

- `pub get` 전의 루트 분석은 지금도 exit 2 다. 나눈 뒤에는 warning 이 하나 더 붙는다.
- **상대 경로로 불러도 이 상태는 나아지지 않는다.** 별칭 → 묶음 → `base.yaml` 까지는 풀리지만 `base.yaml` 이 부르는 `flutter_lints` 가 풀리지 않는다. 주소 방식을 고를 근거가 되지 못한다.
- 검증 명령과 CI 는 루트 `pub get` 을 먼저 돌리므로 이 상태를 지나지 않는다.

### 4. 연습용 프로젝트 폴더가 여럿

`example/` 옆에 `fixtures/base_riverpod/`, `fixtures/base_only/` 를 뒀다 (샘플은 `example/` 의 복사본).

| id | `fixtures/` 의 상태 | 루트 제외 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|---|
| F0 | `pub get` 전 | `example/**` + `fixtures/**` | 0 | 0건 | 없음 | 0.6초 |
| F1 | `pub get` 후 | `example/**` 만 | **2** | **39건** (전부 `fixtures/` 아래, plugin 3 포함) | **있음** | 18 ~ 22초 |
| F2 | `pub get` 후 | `example/**` + `fixtures/**` | 0 | 0건 | 없음 | 0.6초 |
| F5 · F6 | 옵션 파일에 `plugins:` 를 직접 적은 폴더 (끄는 설정용), `pub get` 전 · 후 | `example/**` + `fixtures/**` | 0 | 0건 | 없음 | 0.5초 |

| id | 실행 | 결과 |
|---|---|---|
| F3 | `fixtures/base_riverpod` 안에서 인자 없이 (루트에 `fixtures/**` 제외가 있는 채) | 예상한 21줄, exit 2, plugin 폴더 1 |
| F4 | `fixtures/base_only` 안에서 인자 없이 | 예상한 18줄, exit 2, plugin 폴더 0 |

- **`fixtures/**` 한 줄이면 폴더가 몇 개든 섞이지 않는다.** spike 007 이 "폴더마다 제외 줄이 필요할 것이다" 라고 남긴 것은 연습용 프로젝트를 한 폴더 아래에 모으면 한 줄로 끝난다.
- 그 제외는 폴더 안에서의 분석을 건드리지 않는다 (spike 007 의 E3 가 `example/` 에서 본 것과 같다).
- 끄는 설정용 연습 프로젝트는 옵션 파일에 `plugins:` 를 직접 적는다 (D-04). 제외되어 있으면 `pub get` 전에도 `plugins_in_inner_options` 가 나지 않는다.

### 5. 루트 옵션 파일이 이 패키지의 조각을 include 한다면

| id | 루트의 include | 표식 파일 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|---|
| G0 | `flutter_lints` (지금) | 없음 | 0 | 0건 | 없음 | 0.5초 |
| G1 | `package:woody_lints/base.yaml` | 없음 | 0 | **0건** | 없음 | 0.5초 |
| G3 | `flutter_lints` | 겹따옴표 한 줄 | 0 | 0건 | 없음 | 0.5초 |
| G4 | `package:woody_lints/base.yaml` | 겹따옴표 한 줄 | 0 | 1건 — `tool/quote_marker.dart:2  info  prefer_single_quotes` | 없음 | 0.5초 |
| G2 | `package:woody_lints/recommended.yaml` | 없음 | 0 | 0건 | **있음** | 10 ~ 11초 |

- `base.yaml` 을 루트에서 include 하면 이 패키지의 규칙이 `tool/` 에 실제로 적용되고 (G4 — 0건이 "적용되지 않음" 이 아니다), **지금의 `tool/verify.dart` 는 그 규칙으로도 0건이다** (G1). plugin 은 준비하지 않는다.
- 묶음을 루트에서 include 하면 분석마다 plugin 을 준비한다 (10 ~ 11초, 네트워크). 지금 루트 옵션 파일의 주석이 적어 둔 이유가 나눈 뒤에도 그대로다.

## Results

**Verdict: VALIDATED** — 20건 모두 성립했다. 멈춤 조건에 해당하지 않는다.

1. 나눈 구조에서는 루트 옵션 파일의 `lib/analysis_options.yaml` 제외를 걷어내도 루트 분석이 0건, exit 0, 0.6초다. `plugins_in_inner_options` 가 나지 않고 plugin 도 준비하지 않는다.
2. 걷어낸 뒤의 루트 분석은 별칭 → 묶음 → 조각의 include 가 풀리는지를 함께 본다.
3. 연습용 프로젝트를 `fixtures/` 같은 한 폴더 아래에 모으면 루트 제외는 한 줄로 충분하다.

Phase 3 의 계획이 가져갈 것:

1. **루트 `analysis_options.yaml` 의 exclude 에서 `lib/analysis_options.yaml` 줄을 지운다** (PRESET-06). 파일을 나누는 커밋과 **같은 커밋이거나 그 뒤**여야 한다 — 한 파일 구조에서 먼저 지우면 `lib/analysis_options.yaml:58  warning  plugins_in_inner_options` 로 루트 분석이 exit 2 가 된다 (R1).
2. **새 연습용 프로젝트는 한 폴더 아래에 모으고 그 폴더를 `'<폴더>/**'` 한 줄로 제외한다.** `example/**` 줄은 그대로 둔다. 제외하지 않으면 루트 분석에 39건이 섞이고 plugin 준비로 18 ~ 22초가 든다 (F1).
3. 묶음과 별칭의 주소 방식은 `package:` 로 한다 (조사의 권고, `lints` 의 선례). 상대 경로는 사용 프로젝트 쪽(spike 010)에서도 루트 분석 쪽(R2-rel, C2)에서도 차이를 만들지 않았다.
4. 루트 옵션 파일이 `package:woody_lints/base.yaml` 을 include 하게 바꿔도 된다 — 지금의 `tool/verify.dart` 에서 새 진단이 0건이고 plugin 을 준비하지 않는다. 하고 말고는 계획의 재량이다 (03-CONTEXT.md). 묶음(`recommended.yaml`)은 루트에서 include 하지 않는다.
5. `pub get` 전의 루트 분석에는 warning 이 하나 더 붙는다 (C1). 검증 명령과 CI 는 영향이 없다.

spike 007 의 결론에서 달라지는 것: 없다. 007 이 남긴 "폴더마다 제외 줄이 필요할 것이다" 가 "한 폴더 아래에 모으면 한 줄" 로 좁혀졌다.

확인하지 않은 것:

- 루트를 IDE 로 열었을 때의 모습 (명령줄로는 잴 수 없다 — spike 007 과 같다).
- GitHub Linux runner 에서의 같은 실행. context root 와 옵션 파일을 다루는 코드는 운영체제와 무관하다.
- Dart 3.14 이후. `plugins_in_inner_options` 가 pub.dev 의 analyzer 에서 이미 제거된 코드이므로 R1 의 경고는 다음 SDK 에서 사라질 수 있다. R2 (나눈 구조는 0건) 에는 영향이 없다.
- 연습용 프로젝트를 `example/` **안**에 두는 배치. `example/` 의 분석에 섞일 것이라 재지 않았다.

원본: `results/probe.log`, `results/probe.json`.
