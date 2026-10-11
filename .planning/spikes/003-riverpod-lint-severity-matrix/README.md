---
spike: 003
idea: verify-harness-tool-behavior
name: riverpod-lint-severity-matrix
type: standard
validates: "Given `riverpod_lint` 규칙 15개를 각각 어긴 코드, when `dart analyze --format=json` 으로 분석하면, then 규칙마다 강도·`code` 표기·종료 코드가 표로 확정된다"
verdict: VALIDATED
related: [001, 002, 006]
tags: [riverpod_lint, analyzer-plugin, severity, exit-code, json]
---

# Spike 003: `riverpod_lint` 규칙 15개의 강도와 JSON 표기

## What This Validates

Given `riverpod_lint` 3.x 가 등록하는 규칙 15개를 하나씩 어긴 연습용 프로젝트(`fixture/`),
when 배포 파일을 include 한 그대로 `dart analyze --format=json` 을 돌리면,
then 규칙마다 JSON 의 `severity` / `type` / `code` 와, 그 규칙 하나가 만드는 종료 코드가 확정된다.

조사 문서끼리 어긋나 있던 항목이다 (SUMMARY.md "문서 사이에 어긋나는 지점" 3번). STACK.md 는 규칙 1개를 실측해 info 라고 했고, ARCHITECTURE.md / PITFALLS.md 는 `registerWarningRule` 이라는 이유로 15개 모두 warning 이라고 추정했다.

## Research

`riverpod_lint` 3.1.9 의 소스(`~/.pub-cache/hosted/pub.dev/riverpod_lint-3.1.9/lib/`)를 읽었다.

- `lib/main.dart` 는 15개를 모두 `registry.registerWarningRule(...)` 로 등록한다. 이 호출은 "기본으로 켠다"는 뜻이고 강도를 정하지 않는다.
- 강도는 규칙마다 `LintCode(..., severity: DiagnosticSeverity.X)` 로 따로 적는다. 12개가 `WARNING`, 1개(`riverpod_syntax_error`)가 `ERROR` 이고, **3개에는 `severity` 가 없다** (`avoid_build_context_in_providers`, `avoid_public_notifier_properties`, `protected_notifier_properties`).
- 3.1.3 (배포 파일의 `^3.1.3` 하한)의 소스도 15개의 강도 선언이 3.1.9 와 같다.
- 위반 예제는 upstream 테스트(`rrousselGit/riverpod`, tag `riverpod_lint-v3.1.9`, `packages/riverpod_lint_flutter_test/test/lints/`)를 참고해 규칙마다 한 건만 나오도록 새로 썼다.

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 소스의 `severity` 선언만 읽는다 | — | 빠름 | "선언이 없으면 무엇으로 보고되는가"가 남는다 | 보조 |
| 15개를 실제로 어기고 JSON 을 읽는다 | `dart analyze --format=json` | 로드맵이 요구한 실측 | generator 계열은 생성 코드가 필요 | **채택** |

**Chosen approach:** 실측. generator 계열 규칙을 띄우려고 이 spike 의 연습용 프로젝트에만 `build_runner` + `riverpod_generator` 를 붙였다. 실제 `example/` 에는 붙이지 않는다 (02-CONTEXT.md D-02).

## How to Run

```bash
cd .planning/spikes/003-riverpod-lint-severity-matrix/fixture
fvm dart pub get
fvm dart run build_runner build      # lib/gen/*.g.dart 를 만든다 (저장소에 이미 들어 있다)
cd -

# 전체 1번 + 규칙 하나만 남긴 실행 15번 + 모두 끈 실행 1번 (약 2분)
fvm dart run .planning/spikes/003-riverpod-lint-severity-matrix/severity_matrix.dart /tmp/spike003-state
```

스크립트는 경우마다 `fixture/analysis_options.yaml` 을 바꿔 쓰고 끝나면 되돌린다.

## What to Expect

"전체 실행: exit 3, 진단 15건 (plugin 15건)" 한 줄, 규칙 15개의 표, "15개 모두 끔: exit 0, 진단 0건" 한 줄이 나온다.

## Investigation Trail

### 결과 (Dart 3.13.4, 실제로 풀린 버전 `riverpod_lint` 3.1.9)

| 규칙 | 강도 (`severity`) | 이 규칙만 켰을 때 exit | 필요한 것 |
|---|---|---|---|
| `missing_provider_scope` | **warning** | 2 | `flutter_riverpod` 만 |
| `provider_parameters` | **warning** | 2 | `flutter_riverpod` 만 |
| `avoid_public_notifier_properties` | **info** | 0 | `flutter_riverpod` 만 |
| `avoid_ref_inside_state_dispose` | **warning** | 2 | `flutter_riverpod` 만 |
| `async_value_nullable_pattern` | **warning** | 2 | `flutter_riverpod` 만 |
| `functional_ref` | **warning** | 2 | `riverpod_annotation` (생성 코드 없이 뜬다) |
| `notifier_extends` | **warning** | 2 | `riverpod_annotation` (생성 코드 없이 뜬다) |
| `notifier_build` | **warning** | 2 | `riverpod_annotation` + 가짜 기반 클래스 `typedef` |
| `riverpod_syntax_error` | **error** | 3 | `riverpod_annotation` + 가짜 기반 클래스 `typedef` |
| `protected_notifier_properties` | **info** | 0 | 생성 코드를 둔 상태로 확인 |
| `avoid_build_context_in_providers` | **info** | 0 | 생성 코드를 둔 상태로 확인 |
| `provider_dependencies` | **warning** | 2 | 생성 코드를 둔 상태로 확인 |
| `scoped_providers_should_specify_dependencies` | **warning** | 2 | 생성 코드를 둔 상태로 확인 |
| `unsupported_provider_value` | **warning** | 2 | 생성 코드를 둔 상태로 확인 |
| `only_use_keep_alive_inside_keep_alive` | **warning** | 2 | 생성 코드를 둔 상태로 확인 |

합계: **info 3개, warning 11개, error 1개.** 소스에 `severity` 가 없는 3개가 info 로 보고된다.

15개 모두에 공통인 것:

- JSON `code` 는 규칙 이름 그대로다. `riverpod_lint/` 접두사가 붙지 않는다.
- JSON `type` 은 강도와 상관없이 전부 `STATIC_WARNING` 이다 (info 인 것도, error 인 것도). 강도는 `severity` 로 읽어야 한다.
- 전체를 한 번에 돌리면 종료 코드는 3 이다 (`riverpod_syntax_error` 때문). 규칙 하나만 남긴 실행에서는 error 규칙이 3, warning 규칙이 2, info 규칙이 0 이었다.
- stderr 는 비어 있었다.

### 조사 문서와 달라진 점

1. **"15개 전부 warning" 은 틀렸다.** `registerWarningRule` 은 강도가 아니라 "기본 활성"을 뜻한다. STACK.md 의 실측(info)이 맞았고, 그 규칙은 `severity` 선언이 없는 3개 중 하나였다.
2. **`protected_notifier_properties` 는 코드 생성 없이는 뜨지 않는다.** FEATURES.md 표는 대상을 "전체"로 적었지만, 소스는 `@riverpod` 가 붙은 class 안에서만 보고한다 (`if (enclosingClass.riverpod == null) return;`). 손으로 쓴 `Notifier` 에서 같은 위반을 한 대조 파일(`lib/r04a_…_plain.dart`)에서는 진단이 나오지 않았다. D-02 의 후보 "전체 6개"는 **5개**다.
3. `riverpod_annotation` 만 의존성에 넣으면 생성 코드 없이 뜨는 규칙이 4개 더 있다 (`functional_ref`, `notifier_extends`, `notifier_build`, `riverpod_syntax_error`). 뒤의 둘은 생성 코드가 만들 기반 클래스를 `typedef _$Name = Object;` 로 흉내 내야 컴파일 오류 없이 뜬다 (upstream 테스트와 같은 방식).

### 규칙 하나만 끄는 설정이 실제 패키지 include 와 함께 동작하는가

`severity_matrix.dart` 는 연습용 프로젝트의 옵션 파일에 아래처럼 다시 선언해 14개를 끄고 1개만 남겼다.

```yaml
include: package:woody_lints/analysis_options.yaml

plugins:
  riverpod_lint:
    version: ^3.1.3
    diagnostics:
      missing_provider_scope: false
      # … 나머지 13개
```

15번 모두 남긴 규칙의 진단만 나왔고, 15개를 다 끄면 plugin 진단이 0건이었다. include 로 받은 `plugins:` 선언을 사용 프로젝트가 같은 이름으로 다시 선언해 덮어쓸 수 있다는 조사 결과(STACK.md, scratch 패키지 실측)가 이 저장소의 실제 파일로 재현됐다. Phase 3 의 PRESET-07 이 기댈 수 있는 사실이다.

### 정답지(D-02)에 넣을 규칙 고르기

조건: 코드 생성 없이 낼 수 있고, 강도가 서로 다른 규칙을 섞는다 (2~3건).

- warning 하나: `missing_provider_scope` — `runApp` 한 줄이면 되고 가장 흔한 실수다.
- info 하나: `avoid_public_notifier_properties` — 코드 생성 없이 낼 수 있는 유일한 info 다.
- 세 번째가 필요하면: `provider_parameters` (warning).

`riverpod_syntax_error` (error)는 넣지 않는 편이 낫다. `riverpod_annotation` 의존성과 가짜 `typedef` 가 필요하고, 정답지의 종료 코드가 3 이 되어 "warning 이 사라졌다"를 종료 코드로 구별하지 못하게 된다.

이 조합이면 `example/` 정답지의 맨 위 줄은 **`exit 2`** 가 된다.

## Results

**Verdict: VALIDATED** — 15개 모두 한 번에 떴고(나오지 않은 규칙 없음), 강도·표기·종료 코드가 확정됐다.

- 강도: info 3 / warning 11 / error 1 (위 표). `riverpod_lint` 3.1.9, Dart 3.13.4, 2026-10-11 실측.
- `code` 에 접두사 없음, `type` 은 전부 `STATIC_WARNING`.
- 종료 코드는 진단의 강도만 따른다: info → 0, warning → 2, error → 3.

Phase 5 가 README 에 쓸 수 있는 문장: "`riverpod_lint` 진단은 규칙에 따라 info / warning / error 로 보고된다. 프리셋을 include 한 프로젝트에 warning 규칙의 위반이 있으면 `dart analyze` 의 종료 코드는 2 다." — "include 하면 종료 코드 2" 라고 단정하면 틀린다 (위반이 없거나 info 뿐이면 0).

확인하지 않은 것:

- 표의 아래 6개가 생성 코드 없이도 뜨는지. `example/` 에는 넣지 않을 규칙이라 확인하지 않았다.
- 버전에 따른 차이. plugin 은 `^3.1.3` 이 실행 시점의 최신 3.x 로 풀리므로 다음 버전에서 강도가 바뀔 수 있다. 정답지에 강도가 들어가므로(D-04) 바뀌면 diff 로 드러난다.

원본: `results/severity_matrix.log`, `results/severity_matrix.json`.
