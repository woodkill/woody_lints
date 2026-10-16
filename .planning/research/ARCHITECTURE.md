# Architecture Research

**Domain:** Dart/Flutter 공유 lint 설정 패키지 (configuration-only package, 프리셋 분리 구조)
**Researched:** 2026-10-11
**Confidence:** MEDIUM

> 범위: 기존 구조(`.planning/codebase/ARCHITECTURE.md`)는 다시 조사하지 않았다. 이 문서는 이번 마일스톤의 다섯 기능(규칙 재선정, 프리셋 분리, `example/` + CI 검증, git tag 릴리스, README 재작성)이 기존 구조에 어떻게 얹히는지만 다룬다.

## 근거 표기 규칙

이 문서의 모든 동작 주장에는 아래 표기 중 하나가 붙는다. 표기가 없는 문장은 설계 권고(의견)다.

| 표기 | 뜻 | 신뢰도 |
|------|----|--------|
| `[문서]` | dart.dev 또는 SDK 저장소의 공식 문서에 문장으로 적혀 있다 (Context7 `/dart-lang/site-www` 로 교차 확인) | MEDIUM (`classify-confidence --provider context7`) |
| `[소스]` | Dart SDK tag `3.13.4` (analyzer `14.1.0-dev`) 소스를 직접 읽어 확인했다. **실행해서 확인한 것은 아니다** | 문서보다 구체적이지만 구현 세부라 SDK 버전이 바뀌면 달라질 수 있다 |
| `[관찰]` | 이 저장소나 사용 프로젝트에 남아 있는 기록/파일에서 확인했다 | 해당 시점·버전 한정 |
| `[검증 필요]` | 문서에도 없고 실행으로도 확인하지 않았다. 구현 전에 실측해야 한다 | — |

연구 단계에서는 저장소에 파일을 만들거나 `dart analyze` 를 돌리는 실험을 하지 않았다. 따라서 `[소스]` 로 표시된 항목도 Phase 0 스파이크에서 한 번씩 실행으로 확인해야 한다 (아래 "실측 검증 목록" 참조).

## Standard Architecture

### System Overview

```
┌──────────────────────────────────────────────────────────────────────────┐
│                사용 프로젝트 (Consumer, analysis context root)            │
│  pubspec.yaml                       analysis_options.yaml  ← 유일한 루트  │
│  woody_lints:                       include:                             │
│    git: {url, ref: vX.Y.Z}            - package:woody_lints/base.yaml    │
│                                       - package:woody_lints/riverpod.yaml│
│                                     (+ 자기 linter/analyzer 재정의)       │
└───────────────┬───────────────────────────────┬──────────────────────────┘
                │ pub get (git tag → commit SHA) │ include 해석 (목록 순서대로 병합)
                ▼                               ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                     woody_lints  lib/  (배포 산출물)                      │
│                                                                          │
│  analysis_options.yaml  ── 기존 공개 URI. "전체 구성" 합성 파일            │
│        │ include: [base, riverpod, codegen]                               │
│        ├────────────┬──────────────────┐                                 │
│        ▼            ▼                  ▼                                 │
│  ┌──────────┐ ┌──────────────┐ ┌──────────────────┐                      │
│  │ base.yaml│ │ riverpod.yaml│ │ codegen.yaml     │   ← 조각(fragment)   │
│  │ include: │ │ plugins:     │ │ analyzer.errors  │     프리셋           │
│  │ flutter_ │ │  riverpod_   │ │ analyzer.exclude │                      │
│  │ lints    │ │  lint        │ │                  │                      │
│  │ + 규칙   │ │ (규칙 없음)   │ │ (규칙 없음)       │                      │
│  └────┬─────┘ └──────┬───────┘ └──────────────────┘                      │
└───────┼──────────────┼───────────────────────────────────────────────────┘
        │ include      │ plugins: (context root 의 병합 결과에서 읽힘)
        ▼              ▼
┌────────────────────┐ ┌───────────────────────────────────────────────┐
│ flutter_lints      │ │ Analysis Server plugin 합성 패키지              │
│  → lints           │ │ ~/.dartServer/.plugin_manager/<hash>/          │
│ (pub 의존성 그래프) │ │ dart pub upgrade 로 riverpod_lint 를 별도 해석  │
└────────────────────┘ └───────────────────────────────────────────────┘

저장소 안 검증 경로 (사용 프로젝트에 전달되지 않음)
┌──────────────────────────────────────────────────────────────────────────┐
│ analysis_options.yaml (루트)      tool/verify.dart        .github/workflows│
│  exclude: example/**, fixtures/** │                          verify.yaml  │
│  → Tier 0: lib/analysis_options   ├─ example/        (전체 구성, path:..) │
│    .yaml 체인 유효성 검사          └─ fixtures/base_only/ (base 만)        │
│                                    dart analyze --format=json → 골든 비교 │
└──────────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `lib/base.yaml` | 모든 Flutter 프로젝트에 공통인 규칙. `flutter_lints` include + 이 패키지가 추가하는 규칙. plugin·codegen 설정 없음 | `include: package:flutter_lints/flutter.yaml` + `linter.rules` |
| `lib/riverpod.yaml` | Riverpod 사용 프로젝트 전용. 최상위 `plugins: riverpod_lint` 만 담는 조각. 다른 파일을 include 하지 않는다 | 최상위 `plugins:` 맵 |
| `lib/codegen.yaml` | freezed / json_serializable / riverpod_generator 사용 프로젝트 전용. `invalid_annotation_target: ignore` 와 생성 파일 `exclude` | `analyzer.errors`, `analyzer.exclude` |
| `lib/analysis_options.yaml` | 기존 공개 URI 유지용 합성 파일. 세 조각을 목록 include 로 묶어 1.3.0 과 같은 의미("전부 다")를 유지한다. 자기 자신의 `plugins:` 키는 갖지 않는다 | `include:` 목록만 |
| `example/` | "전체 구성"을 쓰는 최소 Flutter 패키지. README 가 가리키는 사용 예이자 검증 대상 | `pubspec.yaml`(`woody_lints: path: ..`) + 고의 위반 fixture |
| `fixtures/base_only/` | `base.yaml` 만 include 하는 최소 패키지. Riverpod·codegen 설정이 **적용되지 않음**을 증명 | `example/` 와 같은 fixture 소스, 다른 옵션 파일 |
| `tool/verify.dart` | fixture 패키지마다 `dart analyze --format=json` 을 실행해 정규화하고 커밋된 골든과 비교 | `dart:io` + `dart:convert` 만 쓰는 스크립트 (의존성 추가 없음) |
| 루트 `analysis_options.yaml` | 저장소 자체 분석용. fixture 디렉터리를 제외하고, `lib/analysis_options.yaml` 체인을 옵션 파일로 검사받게 한다 | `analyzer.exclude: [example/**, fixtures/**]` |
| `.github/workflows/verify.yaml` | push / PR / tag 마다 Tier 0 + Tier 1 검증. tag 일 때는 버전 일치 검사 추가 | `subosito/flutter-action@v2` + `.fvmrc` |
| git tag `vX.Y.Z` | 릴리스 단위. 사용 프로젝트가 `ref:` 로 고정하는 대상 | annotated tag, `pubspec.yaml` 의 `version` 과 일치 |
| `README.md` / `CHANGELOG.md` | 프리셋 선택표, 설치, 재정의 방법, 버전 올리는 절차, 버전별 "새로 생기는 진단" | 최종 YAML 이 확정된 뒤 작성 |

## Recommended Project Structure

```
woody_lints/
├── lib/
│   ├── analysis_options.yaml   # [공개 URI, 유지] 합성: base + riverpod + codegen
│   ├── base.yaml               # [공개 URI, 신규] flutter_lints + 추가 규칙
│   ├── riverpod.yaml           # [공개 URI, 신규] plugins: riverpod_lint
│   └── codegen.yaml            # [공개 URI, 신규] invalid_annotation_target, 생성 파일 exclude
├── example/                    # 전체 구성 사용 예 + 검증 fixture
│   ├── pubspec.yaml            #   woody_lints: { path: .. }
│   ├── analysis_options.yaml   #   README 의 권장 사용법 그대로
│   ├── lib/                    #   규칙별 고의 위반, riverpod 위반, *.g.dart 샘플
│   └── expected_diagnostics.txt#   골든 (커밋)
├── fixtures/
│   └── base_only/              # include: package:woody_lints/base.yaml 만
│       ├── pubspec.yaml
│       ├── analysis_options.yaml
│       ├── lib/
│       └── expected_diagnostics.txt
├── tool/
│   └── verify.dart             # 골든 비교 스크립트 (--update 로 골든 갱신)
├── .github/workflows/
│   └── verify.yaml             # push / PR / tag
├── analysis_options.yaml       # 저장소 자체 분석용 (fixture 제외)
├── pubspec.yaml                # version, sdk: ^3.13.0, dependencies: flutter_lints
├── .fvmrc                      # 3.47.5 (CI 와 로컬이 같은 파일을 읽는다)
├── CHANGELOG.md
└── README.md
```

### Structure Rationale

- **`lib/` 바로 아래 평평하게:** `package:woody_lints/<file>.yaml` URI 가 곧 공개 API 다. `lints`(`core.yaml`, `recommended.yaml`), `flutter_lints`(`flutter.yaml`), `very_good_analysis`(`analysis_options.yaml` + 버전별 파일) 모두 `lib/` 바로 아래에 둔다 `[관찰: 로컬 pub cache 의 lints-6.1.0, flutter_lints-6.0.0 / GitHub VeryGoodOpenSource/very_good_analysis]`.
- **조각 파일명을 `analysis_options.yaml` 이 아닌 이름으로:** analysis server 는 파일 이름(basename)이 정확히 `analysis_options.yaml` 인 파일만 옵션 파일로 직접 분석한다 `[소스: pkg/analyzer/lib/src/util/file_paths.dart 의 isAnalysisOptionsYaml, pkg/analysis_server/lib/src/context_manager.dart 의 _analyzeAnalysisOptionsYaml 호출 조건]`. `plugins:` 를 `riverpod.yaml` 로 옮기면 그 파일은 include 를 통해서만 읽히므로, 지금 루트 exclude 로 막고 있는 `plugins_in_inner_options` 경고의 발생 조건에서 벗어난다 `[소스]` `[검증 필요]`.
- **`lib/analysis_options.yaml` 을 합성 파일로 남김:** 기존 사용 프로젝트는 아무것도 바꾸지 않아도 같은 의미를 받는다. `very_good_analysis` 도 `lib/analysis_options.yaml` 을 `include: package:very_good_analysis/analysis_options.11.0.0.yaml` 한 줄짜리 포인터로 쓴다 `[관찰: GitHub raw]`.
- **`example/` 와 `fixtures/` 분리:** `example/` 는 pub 관례상 "사용 예" 위치라 README 가 가리키기 좋다. 프리셋 조합마다 루트 옵션 파일이 따로 있어야 하므로(plugin 은 context root 에서만 읽힌다) 조합 수만큼 패키지가 필요하다. 최소 두 개(전체 / base 만)면 opt-in 이 증명된다.
- **`tool/verify.dart`:** `lints` 패키지도 `tool/validate_lib.dart` 로 자체 검사를 한다 `[관찰]`. `lib/` 밖이므로 "lib 에는 Dart 소스 없음" 원칙은 유지된다.
- **`.fvmrc` 를 CI 의 단일 진실 원천으로:** `subosito/flutter-action` 의 `flutter-version-file` 입력이 `.fvmrc` 를 받는다 `[관찰: flutter-action README, "path to pubspec.yaml or .fvmrc or .fvm/fvm_config.json"]`. 로컬과 CI 의 SDK 가 어긋날 수 없게 된다.

## 조사 결과 (질문 A–F)

### A. 프리셋 파일 배치와 include 병합 규칙

**목록 include 는 Dart 3.13 에서 지원된다** `[문서]`.

DATA_q7Lm3ZxA_START
"Specify a single URI or a list of URIs to include multiple files."
"When including multiple files, the analyzer merges options in list order: The first included file is evaluated, including any files it recursively includes. Each subsequent included file is applied in order, adding new options or overriding conflicting ones. Finally, options defined directly in the current `analysis_options.yaml` file override any included options."
"When merging options, the analyzer combines compatible settings rather than replacing entire sections."
"An included options file can be specified with a `package:` URI or a relative path."
DATA_q7Lm3ZxA_END
— dart.dev/tools/analysis (문서 기준 Dart 3.13.3, 2026-09-14 갱신)

- 도입 버전: 공식 changelog 에서 "목록 include 가 추가된 버전" 문장을 찾지 못했다. 로컬 pub cache 의 가장 오래된 `analyzer-7.6.0` 소스에 이미 `YamlList` 처리가 있으므로 Dart 3.13 에서 쓸 수 있다는 점은 확실하고, 정확한 도입 버전은 이 프로젝트(3.13 이상만 지원)에 영향이 없다.

**키별 병합 규칙 (Dart 3.13.4)**

| 키 | 병합 방식 | 근거 |
|----|-----------|------|
| `linter.rules` | 규칙 이름 단위로 합쳐진다. 뒤 파일이 같은 규칙을 다시 적으면 그 값이 이긴다. 목록 문법과 맵 문법은 한 파일 안에서 섞을 수 없지만 파일끼리는 달라도 된다 | `[문서]` "enabling an individual linter rule in a later file adds to or overrides rules from earlier files without discarding the rest of the included ruleset" / `[소스]` `_applyLinterSection`: `_linterRuleConfigs.addAll(...)` |
| `analyzer.errors` | 진단 코드 단위로 합쳐진다. 뒤 파일의 같은 코드가 이긴다 | `[소스]` `_applyErrorProcessors`: 코드별 맵에 덮어쓰기. dart.dev 는 이 키의 병합을 따로 설명하지 않는다 |
| `analyzer.exclude` | **확장(합집합)** 이다. 뒤 파일의 패턴이 추가되고, 이미 있는 패턴은 건너뛴다. include 로 받은 패턴을 **빼는 방법은 없다** | `[소스]` `_applyExcludes`: `if (!contains) add`. dart.dev 는 이 키의 병합을 따로 설명하지 않는다 |
| `analyzer.exclude` 의 기준 디렉터리 | 3.13.4: include 된 파일의 패턴도 **context root 옵션 파일의 디렉터리** 기준으로 해석된다. 그래서 패키지 프리셋의 `**/*.g.dart` 가 사용 프로젝트 파일에 적용된다 | `[소스]` `context_locator.dart` `_getExcludedGlobs`: `LocatedGlob(optionsFile.parent, ...)` |
| `formatter` | `page_width`, `trailing_commas` 키 단위로 뒤 파일이 이긴다 (analyzer 가 읽는 값 기준) | `[소스]` `_applyFormatter`. `dart format` 자체가 `package:` include 를 따라가는지는 `[검증 필요]` |
| `analyzer.language` (`strict-*`) | 키 단위로 뒤 파일이 이긴다 | `[소스]` `_applyLanguage` |
| 최상위 `plugins` | **plugin 이름 단위**로 합쳐진다. 뒤 파일이 같은 plugin 을 다시 적으면 그 항목 **전체(source + diagnostics)가 교체**된다. 깊은 병합이 아니다 | `[소스]` `_applyPlugins`: `configurations[configuration.name] = configuration` |

**SDK main 에서 바뀐 것 (Dart 3.14 예정, 이번 마일스톤 범위 밖이지만 구조에 영향)**

`analyzer.exclude` 패턴의 기준이 "context root 옵션 파일의 디렉터리"에서 **"그 패턴을 선언한 파일의 디렉터리"** 로 바뀌었다 `[소스: dart-lang/sdk commit 7c44c48, 2026-07-27, issue #63864]`. tag `3.13.4` 에는 들어 있지 않다 `[소스: tag 3.13.4 의 context_locator.dart 는 optionsFile.parent 사용]`. SDK main 의 테스트 이름이 `..._includedAnalysisOptions_exclude_relativeToDeclaringFile` 이고 기대값이 `test/lib/nested/b.dart in /home` (선언 파일 위치)이다.

이 변경이 릴리스되면, pub cache(`~/.pub-cache/git/woody_lints-<sha>/lib/`)에 놓인 패키지 프리셋이 선언한 `**/*.g.dart` 는 그 디렉터리 아래에서만 매칭되어 **사용 프로젝트의 생성 파일을 더 이상 제외하지 못할 가능성이 높다** `[검증 필요: 3.14 에서 package: include 에 대해 실측]`. 영향:

- `codegen.yaml` 의 `analyzer.errors` 부분은 영향 없다. `exclude` 부분만 해당된다.
- 실측 대상인 `flutter_starter_kit` 는 이미 자기 루트 파일에 `**/*.g.dart`, `**/*.freezed.dart` exclude 를 직접 갖고 있다 `[관찰]`. 즉 지금도 패키지 쪽 exclude 에 의존하지 않는다.
- 대응: (1) fixture 에 고의 위반을 담은 `*.g.dart` 를 두어 "제외됨"을 골든으로 고정한다 → SDK 를 올리는 날 CI 가 먼저 깨진다. (2) README 에 "생성 파일 exclude 는 프로젝트 루트 파일에도 직접 두는 것이 SDK 변화에 안전하다"는 안내와 복사용 블록을 넣는다.

### B. include 된 파일 안의 최상위 `plugins:`

**문서에 적힌 것**

DATA_Vb92KdTe_START
"You can start using an analyzer plugin in your Dart project by enabling it in the `analysis_options.yaml` file at the root of your package or workspace."
"To enable an analyzer plugin, add it to the top-level plugins section of your `analysis_options.yaml` file."
"`rule_3` is explicitly disabled, which is useful for overriding a rule that might be enabled from an `include:` file."
"After you have made changes to the plugins section, restart the Dart Analysis Server to see the effects."
DATA_Vb92KdTe_END
— dart.dev/tools/analyzer-plugins (Dart 3.13.3 기준, 2026-06-24 갱신) `[문서]`

DATA_hR5wPn8C_START
"A set of analyzer plugins can be enabled for a given package or [workspace][] via the `analysis_options.yaml` file, at the root of the package or workspace source tree. Analyzer plugins cannot be enabled, disabled, or otherwise specified or configured in a nested analysis options file"
"Additionally, `rule_3` is disabled, which can be useful if an included analysis options file explicitly enables the rule."
"When the analysis server sees that a set of plugins is enabled, it creates a synthetic package which depends on each plugin package, which is loaded into a separate isolate of the analysis server process. It uses [`dart pub upgrade`][] to resolve a compatible set of versions of the plugin packages and their dependencies."
DATA_hR5wPn8C_END
— dart-lang/sdk tag 3.13.4, `pkg/analysis_server_plugin/doc/using_plugins.md` `[문서]`

DATA_Yt4sGj1M_START
"The analyzer produces this diagnostic when analyzer plugins are defined in an analysis options file other than the `analysis_options.yaml` at the root of the package."
예시 uri: `inner/analysis_options.yaml` — "Given an `analysis_options.yaml` file located in a subdirectory of the package root"
DATA_Yt4sGj1M_END
— dart.dev/tools/diagnostics/plugins_in_inner_options `[문서]`

정리하면 문서는 두 가지를 말한다.

1. plugin 은 패키지(또는 workspace) 루트의 옵션 파일에서 켠다. 하위 디렉터리의 옵션 파일("nested", "inner")에서는 설정할 수 없다.
2. include 된 파일이 plugin 규칙을 켜 둘 수 있고, 루트 파일이 그것을 재정의할 수 있다 ("enabled from an `include:` file"). 즉 include 를 통한 plugin 설정 전달을 전제로 한 문장이 두 문서 모두에 있다.

문서에 **없는** 것: "include 로 도달한 파일의 `plugins:` 가 로드된다"를 직접 선언한 문장, 그리고 `package:` URI include 에 대한 언급.

**소스로 확인한 것 (tag 3.13.4)**

- plugin 설정은 context root 의 옵션 파일을 **include 까지 병합한 결과**에서 읽는다 `[소스: pkg/analyzer/lib/src/dart/analysis/driver.dart]`.

  ```dart
  /// The plugins options specified in the root analysis options, if any.
  PluginsOptions? get pluginsOptions {
    // We currently only support plugins which are specified at the root of a
    // context.
    var rootOptionsFile = analysisContext?.contextRoot.optionsFile;
    ...
    return getAnalysisOptionsForFile(rootOptionsFile).pluginsOptions;
  }
  ```

  병합 단계(`_ApplyState.apply`)는 include 체인의 모든 파일에 대해 `_applyPlugins` 를 호출한다. 따라서 루트 파일이 include 한 패키지 파일의 `plugins:` 는 로드 대상에 들어간다.

- `plugins_in_inner_options` 는 **직접 분석되는 옵션 파일 자신**이 `plugins:` 맵을 갖고 있고, 그 파일이 context root 디렉터리에 있지 않을 때만 보고된다 `[소스: analysis_options_parse_model.dart]`.

  ```dart
  if (file.parent != contextRoot && isInitialFile) {
    reporter.report(diag.pluginsInInnerOptions ...
  ```

  include 로 도달한 파일(`isInitialFile == false`)에는 보고되지 않는다.

**이 저장소의 관찰과 맞춰 보면**

| 관찰 `[관찰]` | 소스 설명 `[소스]` |
|---------------|--------------------|
| 저장소 안에서 `lib/analysis_options.yaml` 에 `plugins_in_inner_options` 경고가 났다 | 그 파일은 이름이 `analysis_options.yaml` 이라 직접 분석되고(`isInitialFile`), 위치가 `lib/` 라 context root 가 아니다 |
| 사용 프로젝트에서는 경고 없이 riverpod_lint 진단이 나왔다 (v1.3.0) | 사용 프로젝트의 루트 파일이 initial file 이고, 패키지 파일은 include 로 도달하므로 경고 조건에 해당하지 않으며, 병합된 `pluginsOptions` 에 들어간다 |

**사용 프로젝트가 include 로 받은 plugin 을 끄거나 조정할 수 있는가**

| 하고 싶은 일 | 방법 | 근거 |
|--------------|------|------|
| plugin 버전을 프로젝트에서 바꾸기 | 루트 파일에 `plugins: riverpod_lint: ^x.y.z` 를 다시 적는다. 같은 이름이라 include 쪽 항목이 통째로 교체된다 | `[소스]` `[검증 필요]` |
| plugin 의 특정 규칙 끄기 | 루트 파일에 **source(version)를 다시 적고** `diagnostics: {rule: false}` 를 준다. `diagnostics:` 만 적으면 source 가 없어 항목으로 인정되지 않는다 (`_parsePluginSource` 가 `null`) | `[문서]` diagnostics 맵 문법 / `[소스]` 교체 방식. riverpod_lint 규칙은 전부 warning 으로 등록되어 있어(`registerWarningRule`) `false` 로 꺼지는지는 `[검증 필요]` |
| 한 줄 / 한 파일에서만 억제 | `// ignore: riverpod_lint/<code>`, `// ignore_for_file: riverpod_lint/<code>` | `[문서]` using_plugins.md "Suppressing diagnostics" |
| include 로 받은 plugin 을 아예 끄기 | **문서화된 방법이 없다.** 소스에 `// TODO(srawlins): Implement 'enabled: false'.` 가 남아 있다. 루트 파일에 값 없는 `plugins:` 를 적으면 include 쪽 plugin 이 전부 지워지는 구현이지만(`clearsExisting`), 같은 자리에 "이 동작을 유지할지 결정해야 한다"는 TODO 가 있어 의존하면 안 된다 | `[소스]` |

마지막 줄이 프리셋 분리의 근거다. **켜는 것은 파일 선택으로 할 수 있지만 끄는 공식 수단은 없으므로, opt-in 은 구조(별도 파일)로 제공해야 한다.**

### C. Riverpod opt-in 설계안

| 안 | 구조 | 장점 | 단점 | 기존 사용 프로젝트 |
|----|------|------|------|--------------------|
| **1. 조각 프리셋 + 합성 파일 (권장)** | `base.yaml`, `riverpod.yaml`(plugins 만), `codegen.yaml` 을 조각으로 두고, `analysis_options.yaml` 은 셋을 목록 include 하는 합성 파일 | plugin 버전이 한 곳에서 관리된다. 조합이 자유롭다. 기존 URI 의 의미가 유지된다. 저장소 안의 `plugins_in_inner_options` 우회(exclude)를 걷어낼 수 있다 `[검증 필요]` | include 를 통한 plugin 전달에 의존한다 (문서는 간접 언급, 소스·관찰로 확인). 사용 프로젝트가 plugin 규칙을 조정하려면 version 을 다시 적어야 한다 | 변경 불필요. 받는 내용은 재선정된 규칙만 달라진다 |
| 2. 자기완결 체인 | `riverpod.yaml` 이 `base.yaml` 을 include 하고 plugins 를 더한다. `codegen.yaml` 도 같은 식 | 사용 프로젝트가 include 한 줄만 쓴다 | riverpod + codegen 을 같이 쓰려면 결국 목록 include 나 조합 파일(`riverpod_codegen.yaml`)이 필요해 파일 수가 조합 수만큼 늘어난다. 같은 base 가 두 경로로 include 된다 | 1 과 같음 |
| 3. plugin 을 패키지에서 빼고 README 로 안내 | `base.yaml` 에 plugin 없음. 사용 프로젝트가 자기 루트 파일에 `plugins: riverpod_lint: ^x` 를 직접 적는다 | 문서가 말하는 "루트 파일에서 켠다"에 가장 정확히 맞는다. plugin 버전을 프로젝트의 Riverpod 버전에 맞춰 고를 수 있다 | plugin 버전이 프로젝트마다 흩어진다. "include 한 줄로 받는다"는 핵심 가치에서 벗어난다. `analysis_options.yaml` URI 가 plugin 을 더 이상 주지 않으므로 기존 URI 의 의미가 바뀐다 | `ref: main` 인 프로젝트는 다음 `pub upgrade` 때 riverpod_lint 진단이 **말없이 사라진다**. major 변경 + 이전 안내 필요 |
| 4. 기본 파일에 plugin 유지 + opt-out 파일 | `analysis_options.yaml` 은 그대로 두고 `no_riverpod.yaml` 을 추가 | 변경이 가장 작다 | 프리셋이 늘 때마다 "빼는" 파일의 조합이 필요하다. 결국 base 를 분리해야 opt-out 파일을 만들 수 있으므로 1 과 같은 작업에 이름만 거꾸로 붙는다 | 변경 불필요 |

**권고: 1 안.** 근거는 세 가지다. (a) 끄는 공식 수단이 없으므로 조각을 고르는 방식이 유일하게 깨끗한 opt-in 이다. (b) 합성 파일 덕분에 `package:woody_lints/analysis_options.yaml` 의 의미("전부 다")가 유지되어 이전 안내가 필요 없다. (c) 3 안으로 물러나는 길이 열려 있다 — 사용 프로젝트가 루트에 `plugins:` 를 직접 적으면 include 쪽 항목이 교체될 뿐이라, 1 안에서 3 안으로의 이동은 README 수정만으로 된다.

1 안이 성립하려면 실측 V1·V2 가 통과해야 한다. 통과하지 못하면 3 안으로 간다 (이 경우 `analysis_options.yaml` 의 의미가 바뀌므로 major 변경 + README 이전 안내).

### D. 사용 프로젝트의 재정의 방법

| 하고 싶은 일 | 사용 프로젝트 루트 파일에 쓰는 것 | 함정 |
|--------------|----------------------------------|------|
| 규칙 끄기 | `linter: rules: { prefer_single_quotes: false }` | 끄려면 **맵 문법**이어야 한다 `[문서]` "requires the use of a map rather than a list". 한 `rules:` 안에 목록과 맵을 섞을 수 없다 `[문서]`. 프리셋이 목록 문법이어도 사용 프로젝트는 맵 문법을 쓸 수 있다 `[문서]` |
| 규칙 추가 | `linter: rules: [some_rule]` 또는 `{some_rule: true}` | 프리셋의 규칙은 유지된다 `[문서]` |
| 무시한 진단 되살리기 | `analyzer: errors: { invalid_annotation_target: warning }` | 코드 단위로 뒤 파일이 이긴다 `[소스]`. 되살릴 심각도를 직접 적어야 한다 (`warning` 이 이 진단의 기본값인지는 `[검증 필요]`) |
| 심각도 올리기 | `analyzer: errors: { unawaited_futures: error }` | 위와 같음 |
| exclude 추가 | `analyzer: exclude: [build/**, functions/**]` | **대체가 아니라 확장**이다 `[소스]`. 프리셋의 exclude 는 그대로 남는다 |
| 프리셋의 exclude 빼기 | 방법 없음 | 빼야 한다면 `codegen.yaml` 을 include 하지 않고 필요한 부분만 직접 적는다. 이것이 codegen 을 별도 조각으로 두는 이유다 |
| exclude 패턴의 기준 | 사용 프로젝트 루트 | 3.13.4 에서는 include 된 패턴도 루트 기준 `[소스]`. SDK main 에서는 선언 파일 기준으로 바뀌었다 (A 항목 참조) |
| plugin 규칙 조정 | B 항목의 표 참조 | version 을 다시 적어야 항목으로 인정된다 `[소스]` |

README 의 "규칙 재정의" 절은 이 표를 그대로 옮기면 된다. 단 `[소스]` / `[검증 필요]` 항목은 fixture 로 한 번 확인한 뒤에 옮긴다.

### E. 저장소 안 검증 구조

**세 층으로 나눈다.**

| 층 | 무엇을 잡는가 | 어떻게 | 비용 |
|----|--------------|--------|------|
| Tier 0 — 옵션 파일 유효성 | 규칙 이름 오타(`undefined_lint`), 제거·폐기된 규칙, 서로 충돌하는 규칙, include 대상 없음, YAML 오류 | 저장소 루트에서 `dart pub get && dart analyze --fatal-infos`. `lib/analysis_options.yaml` 이 직접 분석되고, 세 조각의 문제는 `included_file_warning` 으로 올라온다 | fixture 없이 가능 |
| Tier 1 — 적용 결과 | 규칙이 실제로 진단을 내는가, plugin 이 로드되는가, exclude / errors 가 적용되는가, base 만 썼을 때 Riverpod·codegen 설정이 **빠지는가** | fixture 패키지에서 `dart analyze --format=json` → 정규화 → 골든 비교 | fixture 2 개 + 스크립트 |
| Tier 2 — 실제 코드베이스 실측 | 규칙별 경고 수 (규칙 재선정의 근거) | `flutter_starter_kit` 복사본. CI 에 넣지 않는다 | 수동, 규칙 재선정 단계에서만 |

Tier 0 은 1 안의 부수 효과다. `lib/analysis_options.yaml` 이 자기 `plugins:` 키를 갖지 않게 되므로 루트 exclude 를 풀 수 있고, 그러면 analyzer 가 그 파일과 include 체인을 검사한다 `[소스]` `[검증 필요: V2]`.

**표식 방식 비교**

| 방식 | 판정 | 이유 |
|------|------|------|
| `// expect_lint: <code>` | 쓸 수 없다 | `custom_lint` 패키지의 테스트 기능이다 `[관찰: custom_lint-0.8.1 README "Built-in testing mechanism using // expect_lint"]`. `dart analyze` 는 이 주석을 해석하지 않는다. riverpod_lint 3.x 는 `custom_lint` 가 아니라 `analysis_server_plugin` 기반이다 `[관찰: riverpod_lint-3.1.9 pubspec]` |
| `// ignore: <code>` + `unnecessary_ignore` lint | 보조 수단으로만 | `unnecessary_ignore` (Dart 3.8 도입, stable `[문서]`)를 fixture 에서 켜면 "기대한 진단이 안 나오면 ignore 가 불필요하다고 보고"되어 expect_lint 와 같은 효과가 난다. 그러나 **plugin 진단 코드에는 동작하지 않는다** — 소스가 lint 도 analyzer 진단도 아닌 이름을 "plugin 에서 온 것일 수 있다"며 건너뛴다 `[소스: pkg/analyzer/lib/src/error/ignore_validator.dart, "It could come from a plugin"]`. plugin 로드 확인이 핵심 요구이므로 주 수단이 될 수 없다 |
| `dart analyze --format=json` 골든 비교 | **권장 (주 수단)** | lint, analyzer 진단, plugin 진단, 옵션 파일 경고를 한 가지 방식으로 다룬다. "없어야 하는 진단"도 골든에 없다는 것으로 증명된다 |
| `--format=machine` 골든 비교 | 대안 | `SEVERITY|TYPE|ERROR_CODE|FILE_PATH|LINE|COLUMN|LENGTH|ERROR_MESSAGE` `[관찰: dart analyze --help, Dart 3.13.4]`. 셸만으로 처리할 수 있지만 경로·메시지 정규화가 번거롭다 |

**`dart analyze` 출력에 대해 알아 둘 것** `[소스: pkg/dartdev/lib/src/commands/analyze.dart, tag 3.13.4]`

- JSON 형태: `{"version": 1, "diagnostics": [{"code", "severity", "type", "location": {"file", "range": {"start": {"offset","line","column"}, "end": {...}}}, "problemMessage", "correctionMessage"?, "documentation"?}]}`.
- 종료 코드: `0` 문제 없음, `1` info (`--fatal-infos` 일 때), `2` warning (`--fatal-warnings` 기본 켜짐), `3` error, `4` analysis server 비정상 종료.
- `analysis_options.yaml` / `pubspec.yaml` 에 대한 **ERROR 심각도** 진단은 json / machine 형식에서 **출력되지 않는다** (소스에 `TODO(srawlins): Why don't we emit the priority errors here?`). 종료 코드에는 반영된다. 따라서 스크립트는 JSON 만 보지 말고 **종료 코드도 기대값과 비교**해야 한다. 같은 파일의 warning / info 는 JSON 에 나온다.
- include 된 파일 안의 문제는 include 한 쪽 파일의 include 줄 위치에 `included_file_warning` 으로 보고된다 `[소스: _IncludedDiagnosticListener]`.
- riverpod_lint 규칙은 모두 warning 으로 등록되어 있어 `[관찰: riverpod_lint-3.1.9 lib/main.dart, registerWarningRule]` plugin 이 로드되고 위반이 있으면 종료 코드가 `2` 가 된다.

**골든 비교 스크립트가 단언할 것**

1. 종료 코드가 기대값과 같다 (`4` 는 무조건 실패).
2. `location.file` 이 `analysis_options.yaml` 로 끝나는 진단이 0 건이다 (프리셋 체인이 깨끗하다).
3. 정규화한 `(상대 경로, 줄, code)` 목록이 `expected_diagnostics.txt` 와 정확히 같다.
4. `example/` 골든에는 riverpod_lint 진단이 1 건 이상 있다 → **plugin 로드의 증거**.
5. `fixtures/base_only/` 골든에는 같은 소스에 대해 riverpod_lint 진단이 없고, `*.g.dart` 의 고의 위반과 `invalid_annotation_target` 은 **있다** → opt-in 의 증거이자, `example/` 쪽 "없음"이 헛통과가 아니라는 대조군.

plugin 진단의 `code` 가 JSON 에 `riverpod_lint/<name>` 로 나오는지 `<name>` 만 나오는지는 `[검증 필요: V4]`. 골든을 처음 만들 때 실제 출력을 보고 정하면 된다.

**fixture 가 저장소 루트 분석에 섞이지 않게 하기**

- 하위 폴더가 별도 analysis context root 가 되는 조건은 **자기 `.dart_tool/package_config.json` 이 있을 때**다. 옵션 파일만 있는 하위 폴더는 새 root 가 되지 않고 상위 context 의 "inner 옵션"으로 붙는다 `[소스: context_locator.dart _createContextRoots — packageConfigFileToUse != containingRoot.packagesFile]`.
- 즉 `example/` 에서 `flutter pub get` 을 하기 전과 후에 저장소 루트 분석의 결과가 달라진다. 이 불안정을 없애려면 루트 `analysis_options.yaml` 이 `example/**`, `fixtures/**` 를 exclude 한다. exclude 된 폴더는 nested root 탐색 대상에서도 빠진다 `[소스: 같은 함수의 doc comment]`.
- fixture 검증은 **fixture 디렉터리를 작업 디렉터리로 두고** 실행한다 (스크립트가 `workingDirectory` 를 지정). `flutter pub get` 이 끝난 `example/` 은 자기 package config 를 가지므로 context root 가 되고, 그 옵션 파일이 루트 옵션 파일이 되어 plugin 이 읽힌다 `[소스]`. 저장소 루트에서 `dart analyze example` 로 실행해도 같은 결과가 나오는지는 확인하지 않았다 `[검증 필요]`.
- **`example/` 을 pub workspace 멤버로 만들지 않는다.** workspace 에서는 plugin 을 workspace 루트 옵션 파일에서만 설정할 수 있다 `[문서: using_plugins.md "at the root of the package or workspace"]`. 그러면 `example/` 의 옵션 파일이 nested 가 되어 검증하려는 상황 자체가 바뀐다.
- 부작용: 루트를 IDE 로 열면 fixture 파일의 진단이 보이지 않는다. fixture 를 볼 때는 `example/` 폴더를 따로 연다.

**GitHub Actions 구성**

```yaml
name: verify
on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7            # 2026-07 기준 최신 v7.0.1 (GitHub API 조회)
      - uses: subosito/flutter-action@v2     # 최신 v2.23.0, README 가 @v2 로 안내
        with:
          flutter-version-file: .fvmrc       # 로컬과 같은 SDK
          cache: true
      # Tier 0: 프리셋 체인 유효성 + tool/ 스크립트 분석
      - run: dart pub get
      - run: dart analyze --fatal-infos
      # Tier 1: fixture 골든 비교 (스크립트가 fixture 마다 flutter pub get 을 먼저 실행)
      - run: dart run tool/verify.dart
      # 디버깅용: 실제로 해석된 plugin 버전 기록
      - run: grep -h -A7 '^  riverpod_lint:' ~/.dartServer/.plugin_manager/*/pubspec.lock || true

  release-check:
    if: startsWith(github.ref, 'refs/tags/v')
    needs: verify
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      # tag(v 제거) == pubspec.yaml version == CHANGELOG.md 최상단 제목
      - run: dart run tool/verify.dart --check-version "${GITHUB_REF_NAME#v}"
```

- **`flutter analyze` 가 아니라 `dart analyze`:** Flutter 3.47.5 의 `flutter analyze` 가 plugin 진단을 내지 않았다는 기록이 있다 `[관찰: PROJECT.md, 2026-09-20 실측]`. 공식 문서는 둘 다 지원한다고 적지만 `[문서]`, 이 저장소의 실측이 우선이다.
- **plugin 은 첫 분석 때 네트워크로 받는다.** analysis server 가 합성 패키지에서 `dart pub upgrade` 를 실행한다 `[문서]`. 합성 패키지는 `~/.dartServer/.plugin_manager/<hash>/` 에 생긴다 `[관찰: 로컬 디렉터리에 pubspec.yaml(name: plugin_entrypoint, dependencies: analysis_server_plugin, riverpod_lint) 와 pubspec.lock]`. CI 는 매번 cold 상태다. cold 실행에서 plugin 진단이 빠짐없이 나오는지는 `[검증 필요: V4]` — 빠진다면 골든 비교가 실패로 드러내므로 조용히 통과하지는 않는다.
- 캐시(`~/.dartServer/.plugin_manager`)는 처음에는 넣지 않는다. 실행 시간이 문제가 될 때 추가한다.

### F. 릴리스 구조

**tag 와 pub 의 관계**

- `ref` 는 git 이 commit 으로 해석할 수 있는 것이면 무엇이든 된다 `[문서]`.

  DATA_c6XeUo0B_START
  "If you want to depend on a specific commit, branch, or tag, add a `ref` key to the description" / "The ref can be anything that Git allows to identify a commit."
  DATA_c6XeUo0B_END
  — dart.dev/tools/pub/dependencies (Git packages)

- `pubspec.lock` 은 `ref` 와 함께 해석된 commit 을 `resolved-ref` 로 기록한다 `[관찰: flutter_starter_kit/pubspec.lock — ref: main, resolved-ref: 90a2736…, version: "1.3.0"]`. pub cache 의 디렉터리 이름도 `woody_lints-<sha>` 다 `[관찰: ~/.pub-cache/git]`.
- 따라서 tag 를 옮기면(force-push) 이미 lock 된 프로젝트와 새로 받는 프로젝트가 서로 다른 commit 을 쓰게 된다. **한 번 push 한 tag 는 옮기지 않는다.** 고칠 것이 있으면 patch 버전을 새로 낸다.
- 사용 프로젝트에서 버전을 올리는 절차는 "`ref:` 를 새 tag 로 고치고 `flutter pub get`"이다. tag 는 움직이지 않으므로 `flutter pub upgrade woody_lints` 만으로는 아무 일도 일어나지 않는다. README 의 "버전 올리기" 절은 이 차이를 적어야 한다 (지금 README 는 `pub upgrade` 를 안내한다).
- 대안: `tag_pattern` `[문서]`.

  DATA_Nz8aFq2W_START
  "If the package you depend on has tagged the revision of each version of the package, you can use `tag_pattern` instead of `ref`, together with a version constraint." / "Support for `tag_pattern` was introduced in Dart 3.9." / "To use `tag_pattern`, the including pubspec (but not the dependency) must have an SDK version constraint of `^3.9.0` or higher."
  DATA_Nz8aFq2W_END

  `tag_pattern: v{{version}}` + `version: ^2.0.0` 을 쓰면 `pub upgrade` 가 새 tag 를 따라간다. 이번 마일스톤의 결정("프로젝트마다 올리는 시점을 고른다")과 반대 방향이므로 **권장하지 않는다.** 다만 tag 이름을 `v` + pubspec `version` 과 정확히 맞춰 두면 나중에 이 방식으로 옮길 수 있으므로, tag 규칙은 이 패턴에 맞춘다. (3.11 패치에서 lightweight tag 를 못 읽는 버그가 고쳐진 이력이 있다 `[문서: SDK CHANGELOG, dart-lang/pub#4756]` → annotated tag 를 쓴다.)

**lint 패키지에서 semver 가 뜻하는 것**

선례는 엇갈린다. `lints` 는 규칙 추가를 대체로 major 로 냈지만(4.0.0, 5.0.0, 6.0.0) 6.1.0 에서는 minor 로 두 규칙을 추가했다 `[관찰: lints-6.1.0 CHANGELOG]`. `very_good_analysis` 는 규칙 세트가 바뀔 때마다 파일명에 버전을 박아 새 파일을 낸다 `[관찰: lib/analysis_options.11.0.0.yaml]`. 즉 생태계 공통 규칙은 없고 패키지마다 정한다.

이 패키지는 사용 프로젝트가 **정확한 tag 하나**에 고정하므로 semver 범위가 기계적으로 평가되지 않는다. 버전 번호는 "올리면 무슨 일이 생기는가"를 사람에게 알리는 신호다. 권장 정책:

| 변경 | 버전 | 사용 프로젝트가 겪는 일 |
|------|------|------------------------|
| 공개 URI 삭제·이름 변경, URI 의 의미 변경(프리셋 내용이 다른 파일로 이동), SDK 하한 상향, plugin major 상향 | **MAJOR** | 옵션 파일이나 SDK 를 고쳐야 한다 |
| 규칙 추가, 심각도 상향, plugin minor 상향, 새 프리셋 파일 추가 | **MINOR** | 새 진단이 생길 수 있다. 코드만 고치면 된다 |
| 규칙 제거, 주석·README 수정, 진단이 줄기만 하는 변경 | **PATCH** | 고칠 것이 없다 |

- "규칙 추가는 breaking 인가": 엄밀히는 `--fatal-infos` CI 를 깨뜨릴 수 있으므로 breaking 이다. 그러나 tag 고정 방식에서는 올리는 시점을 사용자가 고르므로 MINOR 로 두고, CHANGELOG 의 해당 버전에 **"새로 생기는 진단"** 절을 반드시 넣는 것으로 충분하다. 나중에 `tag_pattern` + `^` 범위로 옮긴다면 그때 규칙 추가를 MAJOR 로 올린다.
- 이번 릴리스는 SDK 하한이 `^3.10.4` → `^3.13.0` 으로 올라가므로 **2.0.0** 이다.

**`pubspec.yaml` version / CHANGELOG / tag 맞추기**

- 단일 진실 원천은 `pubspec.yaml` 의 `version` 이다. pub 이 lockfile 에 기록하는 값이 이것이다 `[관찰]`.
- tag workflow 가 세 값의 일치를 검사한다 (`very_good_analysis` 도 `verify_version` workflow 와 `tool/verify_version/main.dart` 를 둔다 `[관찰: GitHub]`). release-please 같은 자동화는 개인 패키지에는 과하다.
- 릴리스 절차: (1) `pubspec.yaml` version 올림 → (2) `CHANGELOG.md` 최상단에 같은 버전 항목 → (3) README 의 `ref:` 예시를 같은 버전으로 → (4) commit, push, CI 통과 확인 → (5) `git tag -a vX.Y.Z -m "..."` → `git push origin vX.Y.Z` → tag workflow 통과 확인.
- **먼저 할 일:** 현재 commit `90a2736` 에 `v1.3.0` tag 를 단다. PROJECT.md 는 "이전 SDK 를 쓰는 프로젝트는 이전 tag 에 머문다"고 정했지만 지금은 tag 가 하나도 없어 머물 곳이 없다.
- **GSD 와의 충돌 가능성:** `.planning/config.json` 의 `git.create_tag: true` 는 마일스톤 완료 때 `v[X.Y]` 형식 tag 를 만든다 `[관찰: gsd-core complete-milestone.md]`. 패키지 릴리스 tag(`vX.Y.Z`)와 같은 접두사를 쓰므로 혼동된다. 마일스톤 버전을 패키지 버전과 맞추거나 `create_tag` 를 끄는 결정이 필요하다.

## Architectural Patterns

### Pattern 1: 조각 프리셋 + 목록 include 조합

**What:** 각 프리셋 파일은 한 가지 관심사만 담고 서로를 include 하지 않는다. 조합은 include 하는 쪽(사용 프로젝트 또는 합성 파일)이 목록으로 한다.
**When to use:** 프리셋이 서로 독립적으로 켜고 끌 수 있는 축일 때 (Riverpod 사용 여부, codegen 사용 여부).
**Trade-offs:** 사용 프로젝트의 include 가 한 줄에서 2~3 줄로 늘어난다. 대신 파일 수가 조합 수가 아니라 축 수만큼만 는다. 한 줄을 원하는 프로젝트에는 합성 파일(Pattern 2)이 있다.

**Example:**
```yaml
# lib/base.yaml — plugin·codegen 설정을 두지 않는다
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors # 근거: (규칙 재선정 단계에서 실측값 기록)
```

```yaml
# lib/riverpod.yaml — 최상위 plugins 만. 다른 파일을 include 하지 않는다
plugins:
  riverpod_lint: ^3.1.9
```

```yaml
# lib/codegen.yaml — analyzer 설정만
analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - '**/*.freezed.dart'
    - '**/*.g.dart'
```

```yaml
# 사용 프로젝트의 analysis_options.yaml — Riverpod 은 쓰고 codegen 은 안 쓰는 경우
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml

analyzer:
  exclude:
    - build/**
```

### Pattern 2: 기존 공개 URI 를 합성 별칭으로 유지

**What:** `lib/analysis_options.yaml` 은 내용을 직접 갖지 않고 조각들을 include 만 한다. URI 와 의미는 1.3.0 과 같다.
**When to use:** 이미 참조되고 있는 URI 의 내용을 재구성할 때.
**Trade-offs:** "기본" 이름을 가진 파일이 가장 무거운 구성이 된다 (opt-in 이라기보다 "기본은 전부, 줄이려면 조각을 고름"). 대신 기존 프로젝트의 이전 작업이 0 이고, 이 파일이 Tier 0 검증의 진입점이 된다.

**Example:**
```yaml
# lib/analysis_options.yaml
# 기존 URI 유지용. base + riverpod + codegen 전부를 받는다.
# 일부만 받으려면 README 의 프리셋 표를 보고 조각 파일을 직접 include 한다.
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml
  - package:woody_lints/codegen.yaml
```

자기 패키지를 `package:` URI 로 include 하는 것은 `lints`(`recommended.yaml` → `package:lints/core.yaml`)와 `very_good_analysis` 가 쓰는 방식이다 `[관찰]`. 상대 경로(`base.yaml`)도 문서상 허용된다 `[문서]`. 선례를 따라 `package:` URI 를 쓴다.

### Pattern 3: 진단 골든 비교 (characterization test)

**What:** fixture 패키지의 `dart analyze --format=json` 출력을 `(파일, 줄, code)` 목록으로 정규화해 커밋된 텍스트 파일과 비교한다. 의도한 변경이면 `--update` 로 골든을 갱신하고 그 diff 를 리뷰한다.
**When to use:** 실행 코드가 없고 산출물이 "다른 도구가 해석하는 설정"일 때.
**Trade-offs:** 줄 번호가 골든에 들어가므로 fixture 를 고치면 골든도 바뀐다 (fixture 를 작게, 규칙당 한 줄로 유지하면 문제되지 않는다). SDK 를 올리면 analyzer 가 내는 진단이 달라져 골든이 깨질 수 있다 — 이것은 결함이 아니라 **SDK 변화가 사용 프로젝트에 닿기 전에 저장소에서 먼저 드러나는** 원하는 동작이다.

**Example:**
```dart
/// fixture 디렉터리 하나를 분석해 골든과 비교한다.
///
/// 종료 코드와 정규화한 진단 목록이 모두 기대값과 같으면 `true` 를 돌려준다.
Future<bool> verifyFixture(Directory fixture, {required bool update}) async {
  final result = await Process.run(
    'dart',
    ['analyze', '--format=json'],
    workingDirectory: fixture.path, // fixture 가 context root 가 되어야 plugin 이 읽힌다
  );
  // 4 는 analysis server 비정상 종료 — 결과를 믿을 수 없다
  if (result.exitCode == 4) return false;

  // JSON 으로 파싱되지 않는 줄은 건너뛴다 (출력에 다른 줄이 섞이는지는 V4 에서 확인)
  final diagnostics = parseDiagnostics(result.stdout as String, relativeTo: fixture);
  final actual = ['exit ${result.exitCode}', ...diagnostics].join('\n');
  final golden = File('${fixture.path}/expected_diagnostics.txt');
  if (update) {
    await golden.writeAsString('$actual\n');
    return true;
  }
  return actual == (await golden.readAsString()).trimRight();
}
```

### Pattern 4: 대조군 fixture

**What:** 같은 소스를 두 옵션 파일(전체 / base 만) 아래에서 분석해, 한쪽에서는 나오고 다른 쪽에서는 안 나오는 진단을 쌍으로 고정한다.
**When to use:** "진단이 없다"를 검증해야 할 때 (exclude, `errors: ignore`, plugin 미로드). 대조군이 없으면 소스가 애초에 위반이 아니어서 통과하는 헛통과를 구분할 수 없다.
**Trade-offs:** fixture 패키지가 하나 더 필요하다.

| fixture 소스 | `example/` (전체) 기대 | `fixtures/base_only/` 기대 |
|--------------|------------------------|-----------------------------|
| 추가 규칙별 고의 위반 | 진단 있음 | 진단 있음 |
| riverpod_lint 위반 | **있음** (plugin 로드) | **없음** (opt-in) |
| 고의 위반을 담은 `sample.g.dart` | **없음** (exclude) | **있음** |
| 잘못된 위치의 annotation | **없음** (`invalid_annotation_target: ignore`) | **있음** |

### Pattern 5: tag 가 곧 릴리스, 이동 금지

**What:** annotated tag `vX.Y.Z` 를 `pubspec.yaml` 의 `version` 과 같은 commit 에 단다. tag 는 옮기지 않는다.
**When to use:** pub.dev 없이 Git 의존성으로 배포할 때.
**Trade-offs:** 잘못 낸 릴리스를 지울 수 없고 patch 를 새로 내야 한다. 대신 `resolved-ref` 가 프로젝트마다 달라지는 일이 없다.

## Data Flow

### Request Flow

**설정 해석 (사용 프로젝트 → 프리셋 → 기반 세트)**

```
사용 프로젝트 analysis_options.yaml   ← context root 의 옵션 파일 (initial file)
    │ include 목록을 위에서 아래로
    ├─► package:woody_lints/base.yaml
    │       └─► package:flutter_lints/flutter.yaml
    │               └─► package:lints/recommended.yaml
    │                       └─► package:lints/core.yaml
    ├─► package:woody_lints/riverpod.yaml     (plugins)
    └─► package:woody_lints/codegen.yaml      (analyzer.errors / exclude)
    │
    ▼ 병합: 가장 깊은 include 부터 적용, 목록의 뒤 파일이 앞 파일을 덮고,
            마지막에 사용 프로젝트 자신의 설정이 전부를 덮는다  [문서]
    │
    ├─► linter.rules        이름 단위 합치기        → 진단 생성
    ├─► analyzer.errors     코드 단위 덮어쓰기      → 심각도 / 무시
    ├─► analyzer.exclude    합집합                  → 분석 대상 파일 결정
    └─► plugins             이름 단위 교체          → Analysis Server
                                                        │ 합성 패키지 생성
                                                        │ dart pub upgrade (pub.dev)
                                                        ▼
                                                 plugin isolate → 진단
```

방향은 한쪽이다. 프리셋은 사용 프로젝트에 대해 아무것도 모르고, 사용 프로젝트의 설정이 항상 마지막에 이긴다. 예외는 두 가지다: `analyzer.exclude` 는 뺄 수 없고(합집합), include 로 받은 plugin 은 끌 수 없다(B 항목).

### State Management

런타임 상태는 없다. 버전 상태는 세 곳에 있고 한 방향으로 흐른다.

```
pubspec.yaml version  (단일 진실 원천)
    │ 같은 commit 에서
    ├─► CHANGELOG.md 최상단 항목
    ├─► README.md 의 ref: 예시
    └─► git tag vX.Y.Z   ──push──►  tag workflow 가 세 값의 일치를 검사
                                         │
                                         ▼
                        사용 프로젝트 pubspec.yaml  ref: vX.Y.Z
                                         │ flutter pub get
                                         ▼
                        pubspec.lock  resolved-ref: <commit SHA>
```

plugin 버전은 이 흐름 밖에 있다. `riverpod.yaml` 의 제약(`^3.1.9`)은 사용 프로젝트의 `pubspec.lock` 이 아니라 analysis server 의 합성 패키지에서, 분석할 때마다 그 시점의 pub.dev 를 상대로 해석된다 `[문서]` `[관찰]`. 같은 tag 라도 시점에 따라 plugin 버전이 달라질 수 있다 (정확한 버전으로 고정할지는 STACK 쪽 결정).

### Key Data Flows

1. **검증 흐름:** push / PR → Actions 가 `.fvmrc` 의 Flutter 설치 → 루트 `dart analyze` (Tier 0) → `tool/verify.dart` 가 fixture 마다 `flutter pub get` → `dart analyze --format=json` → 정규화 → 골든과 비교 → 불일치면 실패.
2. **규칙 변경 흐름:** `lib/base.yaml` 수정 → 로컬에서 `dart run tool/verify.dart` 실패 → `--update` 로 골든 갱신 → 골든 diff 가 "이 변경으로 생기거나 사라지는 진단"의 기록이 된다 → 같은 commit 에서 CHANGELOG 갱신.
3. **릴리스 흐름:** version / CHANGELOG / README 를 같은 commit 에서 올림 → main CI 통과 → tag push → tag workflow 가 버전 일치 검사.
4. **사용 프로젝트 반영 흐름:** `ref:` 수정 → `flutter pub get` → IDE 의 Dart Analysis Server 재시작 (plugin 구성이 바뀌었을 때 필요 `[문서]`) → `dart analyze`.

## Scaling Considerations

사용자 수가 아니라 프리셋 축, 사용 프로젝트, 지원 SDK 수가 이 구조의 규모다.

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 프리셋 축 2 개, 사용 프로젝트 ~5 개, SDK 1 개 (지금) | 위 구조 그대로. fixture 2 개, workflow 1 개, 수동 릴리스 |
| 프리셋 축 4~5 개 (예: 순수 Dart 용 base, 엄격 모드) | 조각이 독립적인 한 파일만 는다. fixture 는 축마다 "켠 것 / 끈 것" 대조가 필요하므로 조합 전체가 아니라 축 수 + 1 개로 유지한다. 이 시점에 fixture 소스 중복이 부담이 되면 스크립트가 옵션 파일만 바꿔 끼우는 방식으로 옮긴다 |
| SDK 2 개 이상 동시 지원 | CI matrix 로 SDK 별 실행, 골든을 SDK 별로 분리. 이번 마일스톤은 "최신 stable 만"이므로 하지 않는다. 이전 SDK 는 이전 tag 로 해결한다 |
| 타인이 쓰는 패키지 | 그때 pub.dev 게시, `very_good_analysis` 식 버전별 파일, LICENSE 를 검토한다. 지금은 범위 밖이다 |

### Scaling Priorities

1. **가장 먼저 깨지는 것 — SDK 를 올리는 날:** `analyzer.exclude` 기준 변경(A 항목), plugin API 변화, 새로 폐기되는 규칙. 대응은 이미 구조에 들어 있다 — `.fvmrc` 를 올리는 PR 에서 골든이 깨지고, 그 diff 가 무엇이 바뀌었는지 알려 준다.
2. **그다음 — plugin 버전 표류:** caret 범위라 같은 tag 에서도 진단이 달라질 수 있다. CI 가 해석된 버전을 로그로 남기게 해 두면 원인 추적이 된다.

## Anti-Patterns

### Anti-Pattern 1: 조각 프리셋이 서로를 include

**What people do:** `riverpod.yaml` 이 `base.yaml` 을 include 하고 `codegen.yaml` 도 `base.yaml` 을 include 한다.
**Why it's wrong:** 둘을 같이 쓰면 base 가 두 번 적용되고, 순서에 따라 한 조각의 재정의가 다른 조각이 다시 들여온 base 에 덮일 수 있다. 조합 파일이 조합 수만큼 필요해진다.
**Do this instead:** 조각은 include 를 하지 않는다 (base 만 `flutter_lints` 를 include). 조합은 목록 include 로 한다.

### Anti-Pattern 2: `plugins:` 를 `analysis_options.yaml` 이라는 이름의 패키지 파일에 두기

**What people do:** 지금처럼 `lib/analysis_options.yaml` 에 최상위 `plugins:` 를 둔다.
**Why it's wrong:** 그 파일은 이름 때문에 저장소 안에서 직접 분석되어 `plugins_in_inner_options` 가 나고 `[관찰]`, 이를 피하려고 파일을 자체 분석에서 제외하면 유일한 산출물이 검증 밖에 놓인다 (CONCERNS.md 의 "Fragile Areas").
**Do this instead:** `plugins:` 는 `riverpod.yaml` 처럼 다른 이름의 파일에 둔다. `analysis_options.yaml` 은 include 목록만 갖는다.

### Anti-Pattern 3: `example/` 을 pub workspace 멤버로 묶기

**What people do:** 루트 `pubspec.yaml` 에 `workspace: [example]` 을 두고 `example/pubspec.yaml` 에 `resolution: workspace` 를 쓴다.
**Why it's wrong:** workspace 에서는 plugin 설정이 workspace 루트 옵션 파일에서만 읽힌다 `[문서]`. `example/` 의 옵션 파일이 nested 가 되어, 검증하려는 "사용 프로젝트가 루트에서 include 하는 상황"이 재현되지 않는다. 또 루트 패키지에 Flutter SDK 의존이 끌려 들어온다.
**Do this instead:** `example/` 은 `woody_lints: {path: ..}` 로 의존하는 독립 패키지로 두고, 그 디렉터리에서 따로 `flutter pub get` 한다.

### Anti-Pattern 4: JSON 출력만 보고 통과 판정

**What people do:** `dart analyze --format=json | jq '.diagnostics | length'` 가 기대값이면 통과로 본다.
**Why it's wrong:** 옵션 파일과 pubspec 의 ERROR 진단은 JSON 에 나오지 않는다 `[소스]`. analysis server 가 죽어도(종료 코드 4) 빈 목록이 나올 수 있다. plugin 이 로드되지 않으면 진단이 "줄어드는" 방향이라 개수 비교가 느슨하면 통과한다.
**Do this instead:** 종료 코드를 골든에 포함하고, 개수가 아니라 `(파일, 줄, code)` 목록 전체를 비교한다.

### Anti-Pattern 5: 릴리스 tag 를 옮기기

**What people do:** 방금 낸 `v2.0.0` 에 오타가 있어 고친 뒤 `git tag -f v2.0.0 && git push -f origin v2.0.0`.
**Why it's wrong:** 이미 받은 프로젝트의 `pubspec.lock` 은 옛 commit 을 가리키고 `[관찰]`, 새로 받는 프로젝트는 새 commit 을 받는다. 같은 버전 번호가 두 내용을 뜻하게 된다.
**Do this instead:** `v2.0.1` 을 낸다.

### Anti-Pattern 6: 구조 변경과 내용 변경을 한 단계에서 하기

**What people do:** 프리셋 분리와 규칙 재선정을 같은 변경에 넣는다.
**Why it's wrong:** 골든이 바뀐 이유가 "파일을 옮겨서"인지 "규칙을 바꿔서"인지 구분할 수 없다.
**Do this instead:** 프리셋 분리는 `example/` 골든이 **한 줄도 바뀌지 않는** 리팩터링으로 먼저 끝낸다. 그 뒤 규칙 재선정에서 골든이 바뀌는 것만 리뷰한다.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| pub (Git 의존성) | 사용 프로젝트 `pubspec.yaml` 의 `git: {url, ref}` | `ref` 는 tag. lockfile 이 `resolved-ref` 로 commit 고정 `[관찰]`. `include:` 대상인 `flutter_lints` 는 이 패키지의 `dependencies` 에 있어야 전달된다 (기존 제약 유지) |
| pub.dev (plugin 다운로드) | analysis server 가 합성 패키지에서 `dart pub upgrade` `[문서]` | 프로젝트 lockfile 과 무관. 네트워크 필요. CI 는 매번 cold. riverpod_lint 3.1.9 는 `sdk: ">=3.13.0-0 <4.0.0"`, `analyzer: ">=13.0.0 <15.0.0"` 을 요구 `[관찰: pubspec]` |
| Dart Analysis Server | `dart analyze` 가 내부에서 서버를 띄운다 | plugin 구성 변경 뒤 IDE 는 서버 재시작 필요 `[문서]`. CLI 는 매번 새로 띄우므로 해당 없음 |
| GitHub Actions | `subosito/flutter-action@v2` + `flutter-version-file: .fvmrc` | `.fvmrc` 지원은 README 에 명시 `[관찰]`. `actions/checkout` 최신은 v7.0.1 (2026-07) `[관찰: GitHub API]` |
| GitHub (tag) | `git push origin vX.Y.Z` → `on: push: tags: ['v*']` | GitHub Release 생성은 선택 사항. tag 만으로 배포는 끝난다 |
| FVM | `.fvmrc` 가 로컬과 CI 의 SDK 를 결정 | 3.41.2 → 3.47.5 로 올려야 문서에 적힌 동작을 재현할 수 있다 (CONCERNS.md) |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| 합성 파일 ↔ 조각 | `include:` 목록 (`package:woody_lints/…`) | 한 방향. 조각은 합성 파일을 모른다 |
| `base.yaml` ↔ `flutter_lints` | `include:` + `pubspec.yaml` 의 `dependencies` | 유일한 외부 include. 버전은 `pubspec.yaml` 에서만 관리 |
| `riverpod.yaml` ↔ `pubspec.yaml` | 없음 | plugin 버전은 `riverpod.yaml` 에만 있다. 의도된 분리 — `pubspec.yaml` 에 넣으면 Riverpod 을 쓰지 않는 프로젝트의 의존성 그래프에 들어간다 |
| fixture ↔ `lib/` | `path: ..` 의존 + `include: package:woody_lints/…` | fixture 는 `lib/` 를 읽기만 한다. `lib/` 의 어떤 파일도 fixture 를 참조하지 않는다 |
| `tool/verify.dart` ↔ fixture | `Process.run('dart', ['analyze', …], workingDirectory: fixture)` + 골든 파일 읽기/쓰기 | 스크립트는 `lib/` 를 직접 파싱하지 않는다. analyzer 가 해석한 결과만 본다 (README ↔ YAML 일치 검사를 넣는다면 그때 YAML 을 읽는다) |
| 루트 옵션 ↔ fixture | `analyzer.exclude` | 루트 분석이 fixture 상태(pub get 여부)에 좌우되지 않게 한다 |
| CI ↔ 로컬 | 같은 명령 (`dart analyze --fatal-infos`, `dart run tool/verify.dart`), 같은 `.fvmrc` | workflow 에만 있는 검증 로직을 두지 않는다. 버전 일치 검사도 스크립트 옵션으로 둔다 |
| README ↔ `lib/*.yaml` | 사람이 맞춘다 (최종 단계에서 한 번) | 자동 일치 검사는 선택 사항. 넣는다면 `tool/verify.dart` 에 "YAML 의 규칙 이름이 README 에 모두 나오는가" 한 가지만 |

## Suggested Build Order

의존 관계가 순서를 정한다. 화살표는 "앞이 끝나야 뒤를 시작할 수 있다"는 뜻이다.

```
0. 스파이크(실측 V1–V4)
      │  └─ 결과에 따라 C 의 1 안 / 3 안 확정
      ▼
1. 기반 정리: .fvmrc 3.47.5, sdk ^3.13.0, v1.3.0 tag
      ▼
2. 검증 하네스 (현재 1.3.0 내용 그대로를 골든으로 고정)
      ▼
3. CI (push / PR)
      ▼
4. 프리셋 분리 (example 골든 불변) + base_only fixture
      ▼
5. 규칙 재선정 (골든이 의도대로 바뀜)
      ▼
6. README / CHANGELOG / 머리 주석
      ▼
7. 릴리스: tag workflow + v2.0.0
```

| 순서 | 내용 | 왜 이 자리인가 |
|------|------|----------------|
| 0 | 임시 디렉터리에서 V1–V4 실측. 저장소 구조는 건드리지 않는다 | 프리셋 배치(1 안 / 3 안)와 하네스의 골든 형식이 이 결과에 달려 있다. 틀린 가정 위에 4 단계를 지으면 전부 다시 한다 |
| 1 | `.fvmrc` → 3.47.5, `pubspec.yaml` `sdk: ^3.13.0`, 현재 commit 에 `v1.3.0` tag | 이후 모든 검증이 대상 SDK 에서 돌아야 한다. tag 는 이전 SDK 프로젝트가 머물 곳이고, 이후 `main` 의 중간 상태로부터 보호하는 기준점이다 |
| 2 | `example/` + `tool/verify.dart` + 골든. **`lib/` 는 아직 바꾸지 않는다** | 지금 동작을 먼저 고정해야 4·5 단계의 변화가 diff 로 보인다. 이 단계에서는 루트 exclude 를 유지한다 (plugins 가 아직 `lib/analysis_options.yaml` 에 있다) |
| 3 | `.github/workflows/verify.yaml` | 4·5 단계의 모든 push 가 보호받는다. 2 와 한 단계로 묶어도 된다 |
| 4 | `base.yaml` / `riverpod.yaml` / `codegen.yaml` 분리, `analysis_options.yaml` 을 합성 파일로, 루트 exclude 를 `lib/analysis_options.yaml` 에서 fixture 디렉터리로 교체, `fixtures/base_only/` 추가 | 완료 기준이 명확하다: `example/` 골든이 바뀌지 않는다 + Tier 0 이 `lib/analysis_options.yaml` 을 검사한다 + `base_only` 골든이 대조표와 일치한다 |
| 5 | 후보 규칙 조사, `flutter_starter_kit` 복사본 실측, 규칙별 결정, 중복 선언 6 개와 주석 처리된 설정 3 개 정리 | 분리 뒤에 해야 각 결정이 들어갈 파일이 정해져 있다. 골든 diff 가 규칙별 변화의 기록이 된다. 4 와 순서를 바꿀 수는 있지만(둘 다 2 에만 의존) Anti-Pattern 6 때문에 섞지는 않는다 |
| 6 | README 재작성(설치, 프리셋 표, 재정의, 버전 올리기), CHANGELOG 2.0.0, YAML 머리 주석 | 최종 YAML 과 최종 버전 번호가 있어야 쓸 수 있다. D 항목의 표 중 `[검증 필요]` 는 이 단계 전에 fixture 로 확인되어 있어야 한다 |
| 7 | workflow 에 tag 트리거와 버전 일치 검사 추가, `v2.0.0` tag push | README 의 `ref: v2.0.0` 예시가 실제로 존재하는 tag 를 가리키게 되는 마지막 단계 |

**단계 사이의 주의점**

- 2~6 단계 동안 `main` 에 push 되는 중간 상태는 `ref: main` 인 프로젝트가 `pub upgrade` 를 하면 그대로 받는다. 사용 프로젝트 적용은 범위 밖이지만, 1 단계의 `v1.3.0` tag 가 있으면 필요할 때 그쪽으로 고정할 수 있다.
- 1 단계에서 `sdk: ^3.13.0` 으로 올리는 순간 그 commit 은 Dart 3.13 미만에서 해석되지 않는다. `ref: main` 인 학습용 프로젝트(Flutter 버전 미고정)가 영향받을 수 있다.

### 실측 검증 목록 (Phase 0)

| ID | 확인할 것 | 지금 근거 | 틀리면 |
|----|-----------|-----------|--------|
| V1 | 사용 프로젝트 루트 파일이 목록 include 한 `package:…/riverpod.yaml` (이름이 `analysis_options.yaml` 이 아닌 파일)의 `plugins:` 로 riverpod_lint 진단이 `dart analyze` 에 나온다 | `[소스]` + v1.3.0 관찰(단일 include, `analysis_options.yaml` 이름) | 3 안으로 전환 |
| V2 | `lib/analysis_options.yaml` 이 자기 `plugins:` 없이 `riverpod.yaml` 을 include 할 때, 저장소 루트 분석에서 `plugins_in_inner_options` 가 나지 않고 include 체인의 오타가 `included_file_warning` 으로 잡힌다 | `[소스]` | 루트 exclude 유지, Tier 0 을 fixture 쪽 단언(옵션 파일 진단 0 건)으로 대체 |
| V3 | 패키지 프리셋의 `analyzer.exclude: '**/*.g.dart'` 가 3.13.4 에서 사용 프로젝트 파일을 제외한다 | `[소스]` | exclude 를 프리셋에서 빼고 README 안내로 대체 |
| V4 | JSON 출력에서 plugin 진단의 `code` 형태, cold cache 첫 실행에 plugin 진단이 빠짐없이 나오는지, 종료 코드 | 형식은 `[소스]`, plugin 부분은 근거 없음 | 골든 정규화 규칙 조정, 필요하면 워밍업 실행 추가 |
| V5 (6 단계 전) | 사용 프로젝트가 `plugins: riverpod_lint: {version, diagnostics: {x: false}}` 로 warning 규칙을 끌 수 있는가 | 교체 방식은 `[소스]`, warning 에 대한 `false` 는 근거 없음 | README 에 `// ignore:` 방식만 안내 |
| V6 (formatter 설정을 프리셋에 넣기로 할 때만) | `dart format` 이 `package:` include 를 따라가 `formatter:` 값을 읽는가 | 근거 없음 | formatter 설정은 프리셋에 넣지 않고 README 안내로 |

## Sources

공식 문서 (Context7 `/dart-lang/site-www` 로 교차 확인 — MEDIUM)

- [Customizing static analysis — dart.dev/tools/analysis](https://dart.dev/tools/analysis) — include 목록, 병합 순서, 규칙 끄기, exclude (Dart 3.13.3 기준, 2026-09-14)
- [Analyzer plugins — dart.dev/tools/analyzer-plugins](https://dart.dev/tools/analyzer-plugins) — 최상위 `plugins:`, diagnostics 맵, 서버 재시작 (2026-06-24)
- [plugins_in_inner_options — dart.dev/tools/diagnostics](https://dart.dev/tools/diagnostics/plugins_in_inner_options)
- [Package dependencies, Git packages — dart.dev/tools/pub/dependencies](https://dart.dev/tools/pub/dependencies) — `ref`, `tag_pattern` (2026-08-12)
- [unnecessary_ignore — dart.dev/tools/linter-rules](https://dart.dev/tools/linter-rules/unnecessary_ignore)
- [dart analyze — dart.dev/tools/dart-analyze](https://dart.dev/tools/dart-analyze)

Dart SDK 저장소, tag `3.13.4` (직접 열람, 실행 검증 아님)

- [pkg/analysis_server_plugin/doc/using_plugins.md](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analysis_server_plugin/doc/using_plugins.md)
- [pkg/analyzer/lib/src/analysis_options/analysis_options_parser.dart](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/analysis_options/analysis_options_parser.dart) — `_ApplyState` 의 키별 병합
- [pkg/analyzer/lib/src/analysis_options/analysis_options_parse_model.dart](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/analysis_options/analysis_options_parse_model.dart) — `plugins_in_inner_options` 조건, plugin 항목 파싱
- [pkg/analyzer/lib/src/dart/analysis/driver.dart](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/dart/analysis/driver.dart) — `pluginsOptions`
- [pkg/analyzer/lib/src/dart/analysis/context_locator.dart](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/dart/analysis/context_locator.dart) — nested context root 조건, exclude glob 기준
- [pkg/analyzer/lib/src/error/ignore_validator.dart](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/error/ignore_validator.dart) — `unnecessary_ignore` 와 plugin 코드
- [pkg/analysis_server/lib/src/plugin/plugin_watcher.dart](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analysis_server/lib/src/plugin/plugin_watcher.dart) — 합성 plugin 패키지 생성
- [pkg/analysis_server/lib/src/context_manager.dart](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analysis_server/lib/src/context_manager.dart) 와 [pkg/analyzer/lib/src/util/file_paths.dart](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/util/file_paths.dart) — 옵션 파일을 이름으로 판별
- [pkg/dartdev/lib/src/commands/analyze.dart](https://github.com/dart-lang/sdk/blob/3.13.4/pkg/dartdev/lib/src/commands/analyze.dart) — JSON 형식, 종료 코드, priority error 누락
- [SDK issue #63864](https://github.com/dart-lang/sdk/issues/63864) 와 [commit 7c44c48](https://github.com/dart-lang/sdk/commit/7c44c487f41e3a19bafa1fb7c309d6035d5e036b) — exclude 패턴 기준 변경 (3.13.4 에 미포함)
- [SDK CHANGELOG.md](https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md) — plugin 시스템(3.10), `tag_pattern`(3.9) 과 후속 수정

선례 패키지

- `lints` 6.1.0, `flutter_lints` 6.0.0, `riverpod_lint` 3.1.9, `custom_lint` 0.8.1 — 로컬 pub cache (`~/.pub-cache/hosted/pub.dev/`) 의 파일 배치, CHANGELOG, `tool/`, `pubspec.yaml`
- [VeryGoodOpenSource/very_good_analysis](https://github.com/VeryGoodOpenSource/very_good_analysis) — `lib/analysis_options.yaml` 포인터 파일, `verify_version` workflow
- [subosito/flutter-action](https://github.com/subosito/flutter-action) — `flutter-version-file` 의 `.fvmrc` 지원, 최신 v2.23.0

이 저장소와 사용 프로젝트의 기록

- `.planning/PROJECT.md`, `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/CONCERNS.md`, `CHANGELOG.md` (1.3.0)
- `~/dv/woody/flutter_starter_kit/pubspec.lock`, `analysis_options.yaml` — `resolved-ref`, 자체 exclude
- `~/.dartServer/.plugin_manager/<hash>/pubspec.yaml` — 합성 plugin 패키지의 실제 모양

---
*Architecture research for: Dart/Flutter 공유 lint 설정 패키지 (프리셋 분리)*
*Researched: 2026-10-11*
