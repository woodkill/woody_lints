# Stack Research

**Domain:** Dart/Flutter 공유 lint 설정 패키지 (configuration-only package, Git 의존성 배포)
**Researched:** 2026-10-11
**Confidence:** HIGH — 핵심 주장 대부분을 Flutter 3.47.5 / Dart 3.13.4 에서 직접 실행해 확인했다. 확인하지 못한 항목은 본문에 "미검증"으로 표시했다.

**Confidence 표기 기준**

| 표기 | 근거 |
|------|------|
| HIGH (실측) | 2026-10-11 로컬 Dart 3.13.4 에서 임시 패키지로 직접 실행했거나, 게시된 패키지 원본 / pub.dev API / GitHub release API / pub 소스를 직접 읽어 확인 |
| MEDIUM | 공식 문서(dart.dev, Context7 `/dart-lang/site-www`) 단일 출처. `classify-confidence --provider context7` 결과가 MEDIUM |
| LOW | 웹 검색 단일 출처 또는 미검증. 권위 있는 사실로 쓰지 말 것 |

실측에 쓴 임시 패키지는 스크래치 디렉터리에만 만들었고 저장소와 `flutter_starter_kit` 은 건드리지 않았다.

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended | Confidence |
|------------|---------|---------|-----------------|------------|
| Flutter SDK (FVM 고정) | `3.47.5` (Dart 3.13.4) | 저장소 고정 SDK, CI SDK | 실측 대상 `flutter_starter_kit` 과 같은 버전이고 로컬 FVM 에 이미 설치되어 있다. 규칙별 경고 수를 같은 analyzer 로 재야 숫자가 의미 있다. 최신 stable 은 3.47.7 (Dart 3.13.5, 2026-10-08) 이며 `.fvmrc` 한 줄로 올릴 수 있다 | HIGH (Flutter release manifest 조회) |
| Dart SDK constraint | `sdk: ^3.13.0` | `pubspec.yaml` 의 `environment.sdk` | 지원 정책(Dart 3.13 이상)을 `pub get` 단계에서 강제한다. 이전 SDK 프로젝트는 해석 실패로 이전 tag 에 머문다. `riverpod_lint` 3.1.9 도 `>=3.13.0-0` 을 요구한다 | HIGH |
| `flutter_lints` | `^6.0.0` (해석 6.0.0, 2025-05-27) | 기반 규칙 세트 (`include: package:flutter_lints/flutter.yaml`) | Flutter 공식 세트이고 `flutter create` 기본값이다. 보수적(누적 102개)이라 "하나씩 근거를 보고 켠다"는 결정과 맞는다. 선언 범위가 이미 최신 | HIGH (pub.dev API + 로컬 pub cache 원본) |
| `lints` | `6.1.0` (전이 의존성, 2026-01-30) | `core`(35) + `recommended`(추가 58, 중복 1) | `flutter_lints` 6.0.0 이 `lints: ^6.0.0` 으로 끌어온다. 직접 선언하지 않는다 | HIGH |
| `riverpod_lint` (analyzer plugin) | `^3.1.9` (2026-09-03) | Riverpod 프리셋 파일의 최상위 `plugins:` | 3.1.9 가 Dart 3.13 을 요구하도록 바뀐 버전이다 (CHANGELOG: 이전 SDK 에서는 plugin 이 `dart analyze` 를 멈추게 했다). 하한을 `^3.1.9` 로 올려 지원 SDK 와 맞춘다 | HIGH (패키지 원본 CHANGELOG / pubspec) |
| analyzer plugin 시스템 (`analysis_server_plugin`) | Dart SDK 내장, Dart 3.10+ | `plugins:` 최상위 키 해석 | 유일하게 유지되는 plugin 시스템. legacy `analyzer: plugins:` 는 Dart 3.13.2 에서 deprecated | HIGH (SDK CHANGELOG) |

### Analysis options surface (Dart 3.13)

`lib/*.yaml` 에 쓸 수 있는 키 전체다. "3.13.4 실측" 열은 직접 실행해 본 결과다.

| 키 | 도입 | 상태 | 3.13.4 실측 / 주의 |
|----|------|------|--------------------|
| `include:` (단일 URI) | Dart 2 시절 (정확한 버전 미확인) | stable | `package:` URI 와 상대 경로 모두 동작 |
| `include:` (리스트) | **도입 버전 미검증.** dart.dev 는 2026-09 에야 문서화했다 (site-www #7477) | stable (문서화됨) | `package:` URI 3개 리스트 동작 확인. 병합 순서: 첫 파일 → 뒤 파일이 덮어씀 → 현재 파일이 최종 우선. 섹션 통째 교체가 아니라 키 단위 병합 |
| `linter.rules` (리스트 / 맵) | Dart 2 | stable | 한 파일 안에서 두 문법을 섞을 수 없다. include 된 파일과 include 하는 파일은 서로 다른 문법을 써도 된다. 규칙을 끄려면 맵 문법 `rule: false` |
| `analyzer.language.strict-casts` | Dart 2.16 | stable. Dart 3.13 에서 대체 lint `no_dynamic_casts` 도입 | 옵션은 경고 없이 그대로 받는다. 위반은 **error** (`invalid_assignment` 등). lint 판은 **info** (`no_dynamic_casts`) |
| `analyzer.language.strict-inference` | Dart 2.x (버전 미확인) | stable. 대체 lint 없음 | 위반은 **warning** (`inference_failure_on_*`) |
| `analyzer.language.strict-raw-types` | Dart 2.x (버전 미확인) | stable. Dart 3.13 에서 대체 lint `no_raw_types` 도입 | 위반은 **warning** (`strict_raw_type`). lint 판은 **info** (`no_raw_types`) |
| `analyzer.errors` | Dart 2 | stable | 값: `ignore` / `info` / `warning` / `error`. 모르는 코드는 `unrecognized_error_code`. **plugin 진단은 이 키로 끌 수 없다** (접두사 유무 모두 실패) |
| `analyzer.exclude` | Dart 2 | stable | `package:` 로 include 된 파일의 `'**/*.g.dart'` 가 사용 프로젝트에 적용됨을 확인. 공식 문서는 include 된 파일의 glob 기준 디렉터리를 말하지 않으므로 `**/` 로 시작하는 패턴만 쓴다 |
| `formatter.page_width` | Dart 3.7 | stable | include 로 전달된다 (`dart format` 이 include 된 파일의 값을 따름) |
| `formatter.trailing_commas` (`automate` \| `preserve`) | Dart 3.8 | stable | include 로 전달된다. 지원하지 않는 키는 `unsupported_option` |
| 최상위 `plugins:` | Dart 3.10 (Flutter 3.38) | 문서에 안정성 표기 없음. legacy 는 3.13.2 에서 deprecated | 아래 "plugins: 실측 결과" 참고 |

**strict 옵션 판단 (MEDIUM):** SDK 3.13.0 CHANGELOG 는 `no_raw_types` 가 `strict-raw-types` 를, `no_dynamic_casts` 가 `strict-casts` 를 "replaces" 한다고 적었다. 옵션 제거 시점은 어디에도 없다(미검증). 이 패키지가 엄격 검사를 켠다면 **lint 판을 쓴다**. 이유: (1) 규칙별 경고 수가 `no_raw_types` / `no_dynamic_casts` 코드로 따로 집계되어 실측 근거가 된다, (2) 사용 프로젝트가 `rule: false` 한 줄로 끌 수 있다, (3) error 가 아니라 info 라서 `flutter run` 을 막지 않는다. 두 lint 모두 `fixStatus: needsFix` — 자동 수정이 없다.

**`plugins:` 실측 결과 (HIGH, Dart 3.13.4)**

| 상황 | 결과 |
|------|------|
| `package:` 로 include 된 파일에 `plugins:` 선언 | plugin 로드됨. 사용 프로젝트에 `riverpod_lint` 진단이 나온다 |
| 프리셋을 모으는 파일이 `plugins:` 프리셋을 include (2단 include) | plugin 로드됨 |
| 저장소 안의 `lib/analysis_options.yaml` 에 `plugins:` 를 직접 작성 | 저장소 자체 분석에서 `plugins_in_inner_options` warning (현재 1.3.0 의 상태) |
| `lib/riverpod.yaml` 처럼 **이름이 다른** 파일에 `plugins:` 작성 | 저장소 자체 분석에서 경고 없음. analyzer 는 `analysis_options.yaml` 이라는 이름만 옵션 파일로 검사한다 |
| `lib/analysis_options.yaml` 이 `plugins:` 를 직접 쓰지 않고 `riverpod.yaml` 을 include | 저장소 자체 분석에서 경고 없음 |
| 사용 프로젝트 루트에서 `plugins: riverpod_lint: diagnostics: {rule: false}` (version 없음) | **꺼지지 않는다** |
| 사용 프로젝트 루트에서 `version: ^3.1.9` + `diagnostics: {rule: false}` | 해당 규칙만 꺼진다. 다른 규칙은 유지 |
| `// ignore: riverpod_lint/avoid_public_notifier_properties` | 억제됨 |
| `// ignore: avoid_public_notifier_properties` (접두사 없음) | 억제되지 않는다 |
| `flutter analyze` (3.47.5) | plugin 진단이 나오지 않는다 (같은 프로젝트에서 `dart analyze` 10건, `flutter analyze` 8건) |

공식 문서는 "plugin 은 패키지 또는 workspace 루트의 옵션 파일에서만 지정한다"고만 말하고 include 된 파일은 언급하지 않는다. 위 include 동작은 **문서화되지 않은 실측 동작**이다. 관련 SDK 이슈 #62451 이 열려 있어 바뀔 수 있다. `example/` 검증이 이 동작을 계속 감시해야 한다.

### 기반 lint 세트 비교

Dart 3.13.4 가 인식하는 규칙은 활성(stable + experimental) 243개, deprecated 6개, removed 14개다 (전 규칙을 켠 옵션 파일로 실측).

| 세트 | 버전 (게시일) | SDK | 규칙 수 | 구조 | 판단 |
|------|---------------|-----|---------|------|------|
| `lints` `core` | 6.1.0 (2026-01-30) | `^3.8.0` | 35 | 단독 | pub.dev 점수 기준. 너무 작다 |
| `lints` `recommended` | 6.1.0 | `^3.8.0` | 누적 92 | `core` include | Flutter 규칙 없음 |
| **`flutter_lints`** | 6.0.0 (2025-05-27) | `^3.8.0` | 누적 102 | `recommended` include + 10 | **기반으로 유지** |
| `very_good_analysis` | 11.0.0 (2026-09-03) | `^3.13.0` | 213 (flutter_lints 밖 111) | include 없는 단일 파일. strict 3종 켬, `formatter: trailing_commas: automate` | **후보 목록의 참고 자료로만 사용** |
| `pedantic_mono` | 1.38.1 (2026-08-13) | `^3.13.0` | flutter_lints + 108 | `flutter_lints` include. strict 3종, `trailing_commas: preserve` | 참고용 |
| `lint` (`strict.yaml`) | 2.14.0 (2026-09-05) | `>=3.13.0` | 183 (flutter_lints 규칙 5개 빠짐) | 단일 파일 | 참고용 |
| `total_lints` (`app_3.13.yaml`) | 3.13.0 (2026-08-27) | `>=3.13.0` | 223 | SDK 버전별 파일 | 거의 전부 켜는 세트. 근거 없이 엄격 |
| `leancode_lint` | 27.0.0 (2026-08-18) | `>=3.13.0` | 196 켬 / 37 끔 + 자체 plugin 규칙 | `analysis_server_plugin` 기반 | 자체 규칙까지 딸려 온다. 범위 밖 |
| `solid_lints` | 2.0.0 (2026-10-08) | `>=3.12.0` | 167 + 자체 plugin 규칙 | `analysis_server_plugin` 기반 | 범위 밖 |
| `all_lint_rules_community` | 0.0.43 (2024-11-19) | `>=2.14.0` | — | — | 2년 가까이 갱신 없음. 쓰지 않는다 |

**권고: `flutter_lints ^6.0.0` 를 기반으로 유지하고, 규칙은 하나씩 추가한다. `very_good_analysis` 11.0.0 은 include 하지 않고 후보 목록으로만 본다.** (HIGH)

- `very_good_analysis` 를 include 하면 모델이 "근거를 보고 켠다"에서 "213개를 받고 싫은 것을 끈다"로 뒤집힌다. 이 프로젝트의 핵심 가치(각 규칙이 왜 켜져 있는지 근거가 남는다)와 반대다.
- 메이저 업데이트마다 규칙이 자동으로 늘어난다. 11.0.0 은 Dart 3.13 신규 규칙 7개를 한 번에 추가했다. 사용 프로젝트가 고르지 않은 경고가 생긴다.
- 후보 조사에는 가장 좋은 출처다. `flutter_lints` 밖 활성 규칙 141개 중 111개를 VGA 가 켜고 있으므로 "VGA 가 켰는가"가 후보 1차 필터가 된다.

**upstream 예고 (MEDIUM, 미릴리스):** `lints` 7.0.0-wip 가 `core` 에 `switch_on_type`, `recommended` 에 `simple_directive_paths` / `simplify_variable_pattern` / `unnecessary_unawaited` 를 추가한다. `flutter_lints` 차기 버전은 최소 SDK 를 Flutter 3.41 / Dart 3.11 로 올린다. 이 4개는 공식 세트가 곧 켤 규칙이므로 후보 조사에서 우선순위가 높다.

**Dart 3.13 신규 규칙 (HIGH, SDK CHANGELOG + 3.13.4 인식 확인):** `async_return_with_no_await`, `empty_container_bodies`, `initialize_in_field_declaration`, `unnecessary_const_in_enum_constructor`, `unnecessary_primary_constructor_body`, `unnecessary_type_name_in_constructor`, `use_declaring_parameters`, `no_raw_types`, `no_dynamic_casts`, `use_primary_constructors`(experimental).

### `riverpod_lint` 3.x

| 항목 | 내용 | Confidence |
|------|------|------------|
| 현재 버전 | 3.1.9 (2026-09-03), `sdk: ">=3.13.0-0 <4.0.0"`, `analyzer: ">=13.0.0 <15.0.0"` | HIGH |
| 설치 방식 | `analysis_options.yaml` 최상위 `plugins: riverpod_lint: <version>` 뿐. `pubspec.yaml` 의 `dev_dependencies` 에 넣을 필요가 없다 (README) | HIGH |
| 규칙 등록 방식 | 15개 전부 `registerWarningRule` — **기본 활성**. 켜는 설정이 필요 없다 | HIGH (`lib/main.dart` 원본) |
| 버전 해석 | Analysis Server 가 plugin 용 가상 패키지를 만들어 `dart pub upgrade` 로 해석한다. 사용 프로젝트의 `pubspec.lock` 과 무관하다. `riverpod_lint` 가 `riverpod: 3.4.3` 을 정확히 고정하지만 앱의 riverpod 버전을 제약하지 않는다 | MEDIUM (`using_plugins.md`) |
| 개별 진단 끄기 (프로젝트 전체) | 사용 프로젝트 루트에서 `version:` 과 `diagnostics:` 를 함께 다시 선언. `analyzer.errors` 로는 안 된다 | HIGH (실측) |
| 개별 진단 끄기 (한 줄 / 파일) | `// ignore: riverpod_lint/<code>`, `// ignore_for_file: riverpod_lint/<code>`. 접두사 필수 | HIGH (실측) |
| 심각도 | `avoid_public_notifier_properties` 는 info 로 보고됨. JSON `type` 은 `STATIC_WARNING`, `code` 에 plugin 접두사 없음 | HIGH (실측, 1개 규칙) |
| 첫 실행 비용 | plugin 상태가 비어 있을 때 11초, 이후 2초 (macOS arm64, pub cache 는 채워진 상태). Linux runner 는 미측정 | HIGH (로컬) / 미검증 (CI) |
| `custom_lint` | **대체됨.** 저장소가 archived 이고 README 가 "no longer under active development" 라며 `analysis_server_plugin` 을 가리킨다. 마지막 릴리스 0.8.1 (2025-09-09). legacy plugin 시스템 자체가 Dart 3.13.2 에서 deprecated | HIGH (GitHub API) |

사용 프로젝트에서 규칙 하나를 끄는 정확한 형태 (README 에 그대로 실어야 한다):

```yaml
include:
  - package:woody_lints/analysis_options.yaml
  - package:woody_lints/riverpod.yaml

plugins:
  riverpod_lint:
    version: ^3.1.9   # 생략하면 diagnostics 가 무시된다 (Dart 3.13.4 실측)
    diagnostics:
      avoid_public_notifier_properties: false
```

**version 범위 판단 (MEDIUM):** plugin 은 lockfile 로 고정되지 않으므로 caret 범위면 `ref: vX.Y.Z` 로 고정한 프로젝트도 새 `riverpod_lint` 를 자동으로 받는다. 그래도 `^3.1.9` 를 권한다. 정확한 버전 고정은 `riverpod_lint` 가 나올 때마다 이 패키지를 릴리스해야 한다. 대신 README 는 Riverpod 규칙을 하나씩 나열하지 않고 "`riverpod_lint` 3.x 의 기본 활성 경고 전체"로 적는다. 그래야 문서가 틀리지 않는다.

### GitHub Actions

| Action | Version | Purpose | Why | Confidence |
|--------|---------|---------|-----|------------|
| `actions/checkout` | `v7` (v7.0.1, 2026-07-20) | 저장소 checkout | 최신 메이저 | HIGH (GitHub API) |
| `subosito/flutter-action` | `v2` (v2.23.0, 2026-03-25) | Flutter SDK 설치 (`flutter`, `dart` 를 PATH 에 추가) | v2.23.0 부터 `flutter-version-file` 이 `.fvmrc` 를 직접 읽는다. `.fvmrc` 가 로컬과 CI 의 단일 버전 출처가 된다. `cache: true` 로 SDK 와 pub cache 를 캐시한다 (내부적으로 `actions/cache@v5`) | HIGH (v2.23.0 `action.yaml` / README) |
| `gh` CLI (runner 기본 설치) | — | tag push 시 GitHub Release 생성 | 서드파티 action 이 필요 없다 | MEDIUM |

`dart analyze` 종료 코드 (HIGH, 3.13.4 실측):

| 최고 심각도 | 기본 | `--fatal-infos` | `--no-fatal-warnings` |
|-------------|------|-----------------|------------------------|
| info 만 | 0 | **1** | 0 |
| warning | 2 | 2 | 0 |
| error | 3 | 3 | 3 |

표의 9칸 모두 실행해 확인했다. `--fatal-warnings` 는 기본으로 켜져 있다. CI 는 `dart analyze --fatal-infos` 를 쓴다. lint 는 전부 info 이므로 이 플래그가 없으면 규칙 위반이 CI 를 통과한다.

권장 workflow (각 명령은 로컬에서 실측했지만 workflow 전체를 GitHub 에서 실행해 보지는 않았다):

```yaml
name: verify
on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:

permissions:
  contents: read

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc
          cache: true

      # 1) 배포 파일 자체 검증: 규칙 이름 오타 / deprecated / removed / 지원하지 않는 옵션
      - run: dart pub get
      - run: dart analyze --fatal-infos

      # 2) example/ 에서 실제 적용 검증
      - run: flutter pub get
        working-directory: example
      - run: dart analyze --fatal-infos
        working-directory: example
```

캐시 주의점: `flutter-action` 의 pub cache 키는 `hashFiles('**/pubspec.lock')` 을 쓴다. 이 저장소는 `.gitignore` 의 `pubspec.lock` 패턴이 `example/pubspec.lock` 까지 무시하므로 해시가 비어 캐시 키가 고정된다. 의존성이 몇 개뿐이라 문제되지 않는다. plugin 상태 디렉터리(`~/.dartServer/.plugin_manager`)는 캐시하지 않는다 — 첫 실행 비용이 작다.

### 검증 기법 (analyzer 출력만으로 판정)

실측으로 확인한 사실에서 나온 구성이다. 네 가지가 서로 다른 구멍을 막는다.

| 무엇을 잡나 | 기법 | 실측 근거 |
|-------------|------|-----------|
| 규칙 이름 오타, 모르는 진단 코드 | `example/` 가 배포 파일을 include 하고 `dart analyze --fatal-infos` | include 된 파일의 오류는 `included_file_warning` 으로 사용 프로젝트 옵션 파일에 보고된다 |
| **deprecated / removed 규칙** | 옵션 파일이 `analysis_options.yaml` 이라는 이름으로 분석 대상 안에 있어야 한다 | **include 경로로는 전달되지 않는다.** `prefer_final_parameters`(deprecated), `avoid_returning_null`(removed) 을 include 된 파일에 넣었을 때 사용 프로젝트는 "No issues found" 였다. 같은 내용을 `analysis_options.yaml` 로 두면 `deprecated_lint` / `removed_lint` 가 나온다 |
| 규칙이 실제로 켜져 있는가 | `example/` 에 위반 코드 + `// ignore: <rule>` 을 두고 `example/analysis_options.yaml` 에서 `unnecessary_ignore` (Dart 3.8+) 를 켠다 | 규칙이 꺼져 있으면 ignore 가 불필요해져 `unnecessary_ignore` 가 뜨고 `--fatal-infos` 로 실패한다 |
| plugin 이 실제로 로드됐는가 | `dart analyze --format=json` 결과에 기대하는 plugin 코드가 있는지 `jq -e` 로 확인 | `unnecessary_ignore` 는 plugin 진단을 모른다. plugin 을 뺀 상태에서도 `// ignore: riverpod_lint/...` 에 대해 아무것도 보고하지 않았다 |

프리셋 파일(`lib/core.yaml` 처럼 이름이 다른 파일)의 deprecated / removed 검사는 복사로 해결한다 (HIGH, 실측):

```bash
# 프리셋을 analysis_options.yaml 이름으로 복사해 analyzer 가 옵션 파일로 검사하게 한다.
# plugins: 를 담은 프리셋은 plugins_in_inner_options 가 뜨므로 제외한다.
# 점(.)으로 시작하는 디렉터리는 분석되지 않으므로 build/ 를 쓴다 (.gitignore 에 추가).
for f in lib/core.yaml lib/codegen.yaml; do
  name=$(basename "$f" .yaml)
  mkdir -p "build/preset_check/$name"
  cp "$f" "build/preset_check/$name/analysis_options.yaml"
done
dart analyze --fatal-infos
```

### 규칙별 경고 수 측정 도구

| Tool | Purpose | 실측 결과 (Dart 3.13.4) |
|------|---------|--------------------------|
| `dart analyze --format=json` | 규칙별 진단 수 집계 | 한 줄 JSON `{"version":1,"diagnostics":[...]}`. 각 항목: `code`(소문자 규칙명), `severity`(`ERROR`/`WARNING`/`INFO`), `type`(`LINT`/`STATIC_WARNING`/`COMPILE_TIME_ERROR`), `location.file`, `location.range.start.{offset,line,column}`, `problemMessage`, `correctionMessage`, `documentation`. stderr 는 비어 있다. `--format` 은 `dart analyze --help --verbose` 에만 나온다 |
| `dart analyze --format=machine` | 파이프로 다루기 쉬운 형식 | `SEVERITY\|TYPE\|ERROR_CODE\|FILE_PATH\|LINE\|COLUMN\|LENGTH\|MESSAGE`. 코드가 대문자. JSON 쪽이 낫다 |
| `jq` 1.7 | JSON 집계 | macOS 기본 설치, `ubuntu-latest` 에도 있다 |
| `dart fix --dry-run` | 자동 수정 가능 건수 | `<rule> - N fixes` 형식으로 규칙별 건수를 낸다. 종료 코드 0 |
| `dart fix --apply --code=<rule>` | 규칙 하나만 수정 | 여러 코드는 쉼표로 구분 |
| SDK `rules.json` (tag 고정) | 후보 규칙 메타데이터 | `https://raw.githubusercontent.com/dart-lang/sdk/3.13.4/pkg/linter/tool/machine/rules.json` — 262개. 필드: `name`, `description`, `categories`, `state`, `incompatible`, `fixStatus`(`hasFix` 165 / `noFix` 67 / `needsFix` 26 / `needsEvaluation` 4), `sinceDartSdk`, `details` |

측정 절차 (전 후보를 한 번에 켜고 한 번만 돌린다):

```bash
# 1) flutter_starter_kit 복사본에서, 3.13.4 의 활성 규칙 전체를 켠 옵션 파일을 만든다
curl -s https://raw.githubusercontent.com/dart-lang/sdk/3.13.4/pkg/linter/tool/machine/rules.json \
  | jq -r '.[] | select(.state=="stable" or .state=="experimental") | "    - \(.name)"'

# 2) 분석 (문제가 있으면 종료 코드가 0 이 아니므로 || true)
dart analyze --format=json > analyze.json || true

# 3) 규칙별 건수
jq -r '.diagnostics[] | "\(.code)\t\(.severity)"' analyze.json | sort | uniq -c | sort -rn

# 4) 자동 수정 가능 건수
dart fix --dry-run
```

주의:

- 전 규칙을 켜면 서로 충돌하는 쌍 때문에 `incompatible_lint` warning 이 10건 나온다. 측정에는 지장이 없다 (양쪽 다 실행된다).
- 복사본의 옵션 파일에도 `analyzer.exclude` (`**/*.g.dart`, `**/*.freezed.dart`) 를 유지한다. 빠뜨리면 생성 코드가 숫자를 부풀린다.
- `dart.dev` 사이트의 `linter_rules.json` (`site-www` main) 은 쓰지 않는다. SDK main 을 따라가서 3.14 규칙(`future_sync_value`, `unnecessary_this_alias` — 3.13.4 에서 `undefined_lint`)이 들어 있고, `sets` 필드는 미릴리스 `lints` 7.0.0 기준이다. 세트 소속은 pub cache 의 실제 YAML 로 계산한다.
- "현재 적용 중인 규칙 전체"를 출력하는 `dart analyze` 플래그는 없다 (SDK 이슈 #61496 open).

### Supporting Libraries

`example/` 프로젝트에만 필요하다. 배포 패키지의 `dependencies` 는 `flutter_lints` 하나로 유지한다.

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `flutter` (SDK) | 3.47.5 | Flutter 전용 규칙(`use_build_context_synchronously`, `sized_box_for_whitespace` 등)을 실제 위젯 코드로 검증 | `example/` 필수 |
| `woody_lints` | `path: ..` | 배포 파일을 사용 프로젝트와 같은 경로(`package:woody_lints/...`)로 include | `example/` 의 `dev_dependencies` |
| `flutter_riverpod` | `^3.4.3` (2026-09-03) | Riverpod 프리셋이 진단을 내는지 확인할 위반 코드 | Riverpod 프리셋 검증 시 |
| `riverpod_annotation` | `^4.0.7` (2026-09-03) | `@riverpod` 전용 규칙 확인 | generator 전용 규칙까지 검증할 때만 |
| `freezed_annotation` / `json_annotation` | `^3.1.0` / `^4.12.0` | codegen 프리셋의 `invalid_annotation_target: ignore` 확인 | codegen 프리셋 검증 시. `build_runner` 는 돌리지 않고 손으로 쓴 `*.g.dart` 고정 파일로 exclude 를 확인한다 |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| FVM 4.3.1 | 로컬 Flutter 버전 고정 | `fvm use 3.47.5` 로 `.fvmrc` 를 바꾼다. 루트 패키지가 Flutter 프로젝트가 아니라서 `--force` 가 필요할 수 있다 (미검증). `.vscode/settings.json` 의 `dart.flutterSdkPath` 가 `.fvm/versions/3.41.2` 를 가리키고 있으니 실행 후 함께 바뀌었는지 확인한다. CI 에서는 FVM 을 설치하지 않는다 — `flutter-action` 이 `.fvmrc` 를 읽는다 |
| `dart analyze` | 검증 명령 | `flutter analyze` 는 쓰지 않는다 (plugin 진단 누락, 3.47.5 재확인) |
| `dart format` | `formatter:` 옵션 확인 | include 된 파일의 `page_width` / `trailing_commas` 를 따른다 |
| `git tag` + `gh release create` | 릴리스 | `git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`. tag 는 옮기지 않는다 — 사용 프로젝트의 `pubspec.lock` 이 `resolved-ref` 로 commit SHA 를 기록한다 |
| README 동기화 스크립트 (`tool/sync_readme.dart`) | README 규칙 목록을 YAML 에서 생성 | 아래 참고 |

**README 규칙 목록 동기화 (LOW — 기성 도구를 찾지 못했다):** 직접 만든다. 의존성 없는 Dart 스크립트(`dart:io` 만 사용)가 `lib/*.yaml` 의 `- rule_name # 설명` 줄을 읽어 README 의 `<!-- rules:start -->` ~ `<!-- rules:end -->` 사이를 다시 쓴다. CI 는 스크립트를 실행한 뒤 `git diff --exit-code README.md` 로 어긋남을 잡는다.

- `package:yaml` 파서를 쓰지 않는 이유: 규칙 설명이 YAML 주석에 있는데 파서는 주석을 버린다. 줄 단위 정규식이 맞는 도구다.
- 의존성을 추가하지 않는 이유: 이 패키지의 `dependencies` 는 사용 프로젝트로 전이된다. `dev_dependencies` 라도 0개로 두는 편이 `pubspec.yaml` 이 단순하다.
- 규칙 문서 링크는 `https://dart.dev/lints/<rule_name>` 형식을 쓴다 (`lints` CHANGELOG 가 쓰는 형식).

## Installation

```bash
# 저장소 SDK 고정 (.fvmrc 갱신. .vscode/settings.json 의 경로도 3.47.5 인지 확인)
fvm use 3.47.5

# 배포 패키지: 의존성은 flutter_lints 하나
fvm dart pub get
fvm dart analyze --fatal-infos

# example/ 검증
cd example
fvm flutter pub get
fvm dart analyze --fatal-infos

# 릴리스 (pubspec.yaml 의 version 과 tag 가 일치해야 한다)
git tag -a v2.0.0 -m "release: 2.0.0"
git push origin v2.0.0
gh release create v2.0.0 --verify-tag --notes-from-tag
```

`pubspec.yaml` 변경:

```yaml
environment:
  sdk: ^3.13.0        # ^3.10.4 에서 올림

dependencies:
  flutter_lints: ^6.0.0   # 유지. dev_dependencies 로 옮기지 말 것
```

사용 프로젝트 쪽 (README 에 실을 형태):

```yaml
dev_dependencies:
  woody_lints:
    git:
      url: https://github.com/woodkill/woody_lints.git
      ref: v2.0.0
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| `flutter_lints` 기반 + 규칙 개별 추가 | `very_good_analysis` 11.0.0 include + 싫은 규칙 끄기 | 엄격함 자체가 목표이고 규칙별 근거를 남길 생각이 없을 때. 이 프로젝트는 반대다 |
| `ref: vX.Y.Z` 로 고정 | `tag_pattern: v{{version}}` + `version: ^2.0.0` (Dart 3.9+, 사용 프로젝트 SDK constraint 가 `^3.9.0` 이상) | `pub upgrade` 로 lint 패키지도 범위 안에서 자동으로 올리고 싶을 때. 다른 패키지를 올리다가 새 lint 경고가 딸려 오므로 "프로젝트마다 올리는 시점을 고른다"는 결정과 맞지 않는다. 다만 tag 를 `vX.Y.Z` 로 하고 `pubspec.yaml` version 과 일치시켜 두면 나중에 바꿀 수 있다 — pub 은 tag 에서 읽은 버전과 그 commit 의 pubspec version 이 다르면 실패한다 (pub 소스 확인) |
| `subosito/flutter-action@v2` | `dart-lang/setup-dart` v1.8.1 (2026-08-28) | `example/` 가 Flutter SDK 에 의존하지 않는 순수 Dart 패키지일 때. `dart analyze` problem matcher(PR 인라인 주석)가 내장되어 있다. 이 프로젝트는 Flutter 규칙을 검증해야 하므로 해당 없음 |
| `subosito/flutter-action@v2` 의 `flutter-version-file: .fvmrc` | `kuhnroyal/flutter-fvm-config-action` v3.3 | `flutter-action` 2.23.0 이전 버전에 묶여 있을 때. 지금은 불필요한 한 단계 |
| `subosito/flutter-action@v2` | `flutter-actions/setup-flutter` v4.3 | 특별한 이유 없음. star 40 대 2600, 사용처가 적다 |
| lint 판 `no_raw_types` / `no_dynamic_casts` | `analyzer.language.strict-raw-types` / `strict-casts` | 위반을 warning / error 로 강제하고 싶을 때. 사용 프로젝트가 끄기 어렵고 규칙별 실측 집계가 lint 코드로 잡히지 않는다 |
| `riverpod_lint: ^3.1.9` (caret) | `riverpod_lint: 3.1.9` (정확한 버전) | tag 고정 시점의 진단 집합을 완전히 재현해야 할 때. `riverpod_lint` 릴리스마다 이 패키지도 릴리스해야 한다 |
| 직접 만든 README 동기화 스크립트 | README 에 규칙 목록을 두지 않고 YAML 파일로 링크만 건다 | 규칙 수가 적고 README 에는 선정 근거만 쓰기로 할 때. 동기화 문제가 사라지는 가장 단순한 방법이다 |
| `gh release create` | `softprops/action-gh-release` v3.0.3 | release asset 업로드 등 `gh` 로 번거로운 작업이 있을 때. 여기는 없다 |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `custom_lint` / `custom_lint_builder` | 저장소 archived, "no longer under active development". 기반인 legacy plugin 시스템이 Dart 3.13.2 에서 deprecated. `riverpod_lint` 3.x 는 이미 쓰지 않는다 | 최상위 `plugins:` |
| `analyzer: plugins:` (legacy 선언) | Dart 3.13.2 부터 deprecated 경고. 이후 릴리스에서 비활성화 예정 (시점 미검증) | 최상위 `plugins:` |
| `flutter analyze` 를 CI 검증 명령으로 | Flutter 3.47.5 에서 plugin 진단을 내지 않는다 (같은 프로젝트: `dart analyze` 10건 / `flutter analyze` 8건) | `dart analyze --fatal-infos` |
| `--fatal-infos` 없는 `dart analyze` | lint 는 전부 info 라 종료 코드 0. 규칙 위반이 CI 를 통과한다 | `dart analyze --fatal-infos` |
| `analyzer.errors` 로 plugin 진단 끄기 | `unrecognized_error_code` 가 나고 진단은 그대로 남는다 | `plugins: <name>: {version, diagnostics}` 또는 `// ignore: riverpod_lint/<code>` |
| `plugins:` 를 `lib/analysis_options.yaml` 에 직접 작성 | 저장소 자체 분석에서 `plugins_in_inner_options` 가 나서 그 파일을 exclude 해야 하고, 그러면 배포 파일이 검증에서 빠진다 (현재 1.3.0 의 문제) | 이름이 다른 프리셋 파일(`lib/riverpod.yaml`)에 둔다 |
| pub workspace (`resolution: workspace`) 로 `example/` 묶기 | plugin 은 workspace 루트 옵션 파일에서만 지정할 수 있어 `example/` 가 사용 프로젝트와 다른 조건이 된다 | `example/` 를 독립 패키지로 두고 `path: ..` 의존 |
| 사이트의 `linter_rules.json` 을 규칙 목록 기준으로 | SDK main 을 따라가 3.14 규칙과 미릴리스 `lints` 7.0.0 세트 정보가 섞여 있다 | SDK tag 고정 `rules.json` + 로컬 analyzer 로 실제 인식 여부 확인 |
| deprecated 규칙: `prefer_final_parameters`, `avoid_null_checks_in_equality_operators`, `use_if_null_to_convert_nulls_to_bools`, `avoid_private_typedef_functions`, `one_member_abstracts`, `unnecessary_await_in_return` | Dart 3.13.4 가 `deprecated_lint` 를 낸다. Dart 3.13 은 선언 매개변수가 아닌 곳의 `final` / `var` 자체를 금지했다 | 후보에서 제외. 매개변수 재할당 방지는 `parameter_assignments` |
| `all_lint_rules_community` | 마지막 릴리스 2024-11-19 | SDK `rules.json` |
| `dart_code_linter` 4.4.2 / DCM | 별도 plugin 과 자체 규칙·메트릭 체계. "설정 전용 패키지"의 범위를 넘는다 | 필요해지면 별도 프리셋으로 검토 |
| `invertase/github-action-dart-analyzer` | 저장소 archived | `dart analyze` 직접 실행 |

## Stack Patterns by Variant

**기존 URI 의 의미를 유지하려면 (권장 검토안):**

- `lib/core.yaml` (기반 규칙), `lib/codegen.yaml`, `lib/riverpod.yaml` 로 나누고, `lib/analysis_options.yaml` 은 세 파일을 include 만 하는 묶음 파일로 둔다
- `package:woody_lints/analysis_options.yaml` 이 지금과 같은 뜻(전부 포함)으로 남아 기존 사용 프로젝트가 깨지지 않는다
- 실측: 묶음 파일이 `plugins:` 프리셋을 include 해도 저장소 자체 분석에서 `plugins_in_inner_options` 가 나지 않고, 사용 프로젝트는 2단 include 로 plugin 을 받는다. 루트 `analysis_options.yaml` 의 exclude 를 지울 수 있다
- 대가: 규칙이 `analysis_options.yaml` 이 아닌 이름의 파일로 옮겨 가므로 deprecated / removed 검사를 위해 "프리셋 복사" 단계가 필요하다

**기존 URI 를 기반 규칙만으로 바꾸려면:**

- `lib/analysis_options.yaml` 에 기반 규칙을 그대로 두고 `plugins:` 와 codegen 설정만 떼어 낸다
- 저장소 루트 `dart analyze` 가 배포 파일을 그대로 검사한다 (이름이 `analysis_options.yaml` 이므로 deprecated / removed 까지 잡힌다). 복사 단계가 필요 없다
- 대가: URI 의 의미가 바뀌는 breaking change 다. 메이저 버전을 올리고 README 에 옮기는 방법을 적어야 한다 (PROJECT.md 의 Compatibility 제약)

**Riverpod 를 쓰지 않는 사용 프로젝트:**

- `include:` 리스트에서 `riverpod.yaml` 을 뺀다. plugin 자체가 로드되지 않으므로 해석·컴파일 비용도 없다

**codegen 을 쓰지 않는 사용 프로젝트:**

- `codegen.yaml` 을 뺀다. `invalid_annotation_target` 이 다시 보고되고 `*.g.dart` exclude 가 사라진다

**엄격 타입 검사를 넣기로 한다면:**

- `no_raw_types`, `no_dynamic_casts` 를 `linter.rules` 에 넣는다
- `strict-inference` 는 대체 lint 가 없으므로 넣으려면 `analyzer.language` 로만 가능하다. 위반이 warning 이라 `dart analyze` 기본 종료 코드가 2 가 된다는 점을 실측 숫자와 함께 판단한다

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| `riverpod_lint` 3.1.9 | Dart `>=3.13.0-0` | `analysis_server_plugin` 0.3.18 이 요구하는 analysis server 프로토콜이 Dart 3.13 에 들어 있다. 이전 SDK 에서는 `dart analyze` 가 멈췄다 (CHANGELOG) |
| `riverpod_lint` 3.1.9 | 앱의 `flutter_riverpod` 3.x | plugin 은 별도 가상 패키지로 해석되므로 `riverpod: 3.4.3` 고정이 앱에 전달되지 않는다 (MEDIUM) |
| `flutter_lints` 6.0.0 | `lints` `^6.0.0` (6.1.0), Dart `^3.8.0` | `lints` 7.0.0 이 나와도 `flutter_lints` 6.x 는 받지 않는다 |
| `very_good_analysis` 11.0.0 | Dart `^3.13.0` | 참고 자료로만 |
| 최상위 `plugins:` | Dart 3.10+ (Flutter 3.38+) | `sdk: ^3.13.0` 이면 충족 |
| `formatter.trailing_commas` | Dart 3.8+ | `page_width` 는 3.7+ |
| `unnecessary_ignore` | Dart 3.8+ | plugin 진단은 판정하지 못한다 |
| `no_raw_types`, `no_dynamic_casts` | Dart 3.13+ | 자동 수정 없음 |
| `tag_pattern` | 사용 프로젝트 `sdk: ^3.9.0` 이상 | Dart 3.11.2 에서 lightweight tag 버그 수정. tag 버전과 pubspec version 이 일치해야 한다 |
| `subosito/flutter-action` v2.23.0 | `.fvmrc`, `.fvm/fvm_config.json`, `pubspec.yaml` | `.fvmrc` 지원은 2.23.0 부터. 내부 `actions/cache@v5` |
| `flutter analyze` (Flutter 3.47.5) | plugin 진단 미표시 | 3.47.7 은 미검증 |
| `future_sync_value`, `unnecessary_this_alias` | Dart 3.14+ | 3.13.4 에서 `undefined_lint` |
| Flutter 3.47.5 | Dart 3.13.4 | 최신 stable 3.47.7 = Dart 3.13.5 |

## 미검증 항목

roadmap 에서 사실로 쓰기 전에 확인이 필요하다.

- `include:` 리스트 문법을 도입한 Dart 버전. 지원 SDK 가 3.13 이상이라 실무 영향은 없다
- `strict-inference` / `strict-raw-types` 의 도입 버전, `strict-casts` / `strict-raw-types` 옵션의 제거 시점
- legacy plugin 시스템이 완전히 비활성화되는 SDK 버전
- include 된 파일의 `plugins:` 가 계속 허용될지. 문서화되지 않은 동작이다 (SDK 이슈 #62451)
- GitHub Linux runner 에서 plugin 첫 실행 시간, workflow 전체의 실제 실행
- Flutter 프로젝트인 `example/` 에서의 `dart pub get` 동작 (순수 Dart 패키지로만 실측했다). 그래서 `flutter pub get` 을 권했다
- `flutter analyze` 의 plugin 진단 누락이 3.47.7 에서 고쳐졌는지
- `riverpod_lint` 15개 규칙 각각의 심각도 (1개만 확인)
- README 동기화용 기성 도구의 존재 여부 (웹 검색 1회로 찾지 못함)

## Sources

**로컬 실측 (HIGH)** — Flutter 3.47.5 / Dart 3.13.4, 2026-10-11, 스크래치 임시 패키지

- `dart analyze` (기본 / `--format=json` / `--format=machine` / `--fatal-infos`), `dart fix --dry-run`, `dart format --output=show`, `flutter analyze`
- 전 규칙(265개 이름: SDK main 기준 264개 + `use_primary_constructors`)을 켠 옵션 파일로 인식 / deprecated / removed 여부 확인 — 243개 통과, deprecated 6, removed 14, undefined 2

**패키지 원본과 API (HIGH)**

- pub.dev API `https://pub.dev/api/packages/<name>` — `lints`, `flutter_lints`, `riverpod_lint`, `very_good_analysis`, `custom_lint`, `analysis_server_plugin`, `pedantic_mono`, `leancode_lint`, `lint`, `solid_lints`, `total_lints`, `all_lint_rules_community`, `dart_code_linter`, `flutter_riverpod`, `riverpod_annotation`, `freezed_annotation`, `json_annotation`
- 로컬 pub cache: `lints-6.1.0/lib/*.yaml`, `flutter_lints-6.0.0/lib/flutter.yaml`, `riverpod_lint-3.1.9/{README.md,CHANGELOG.md,pubspec.yaml,lib/main.dart}`, `analysis_server_plugin-0.3.24/doc/using_plugins.md`
- pub.dev archive: `very_good_analysis` 11.0.0, `lint` 2.14.0, `pedantic_mono` 1.38.1, `total_lints` 3.13.0, `leancode_lint` 27.0.0, `solid_lints` 2.0.0 의 YAML
- https://raw.githubusercontent.com/dart-lang/sdk/main/CHANGELOG.md — 3.7 ~ 3.14 의 Analyzer / Linter / Formatter / Pub 항목
- https://raw.githubusercontent.com/dart-lang/sdk/3.13.4/pkg/linter/tool/machine/rules.json — 규칙 메타데이터
- https://raw.githubusercontent.com/dart-lang/core/main/pkgs/lints/CHANGELOG.md — `lints` 7.0.0-wip
- https://raw.githubusercontent.com/flutter/packages/main/packages/flutter_lints/CHANGELOG.md — `flutter_lints` NEXT
- https://raw.githubusercontent.com/dart-lang/pub/master/lib/src/source/git.dart — `tag_pattern` 버전 일치 검사
- GitHub API releases: `subosito/flutter-action`, `dart-lang/setup-dart`, `actions/checkout`, `actions/cache`, `kuhnroyal/flutter-fvm-config-action`, `flutter-actions/setup-flutter`, `softprops/action-gh-release`, `invertase/dart_custom_lint`(archived), `invertase/github-action-dart-analyzer`(archived)
- `subosito/flutter-action` v2.23.0 의 `action.yaml`, `README.md`
- https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json — stable 3.47.7 / Dart 3.13.5
- https://github.com/dart-lang/sdk/issues/62164 — legacy plugin deprecation 계획
- https://github.com/dart-lang/site-www/issues/7477 — include 리스트 문서화

**공식 문서 (MEDIUM)**

- Context7 `/dart-lang/site-www` — include 병합 순서, plugin `diagnostics`
- https://dart.dev/tools/analysis — `include`, strict 모드, `linter.rules`, `analyzer.errors`, `analyzer.exclude`, `formatter`
- https://dart.dev/tools/analyzer-plugins — plugin 활성화, `diagnostics`, ignore 주석
- https://dart.dev/tools/diagnostics/plugins_in_inner_options
- https://dart.dev/tools/pub/dependencies — Git 의존성 `ref` / `tag_pattern`
- https://dart.dev/tools/dart-analyze — `--fatal-infos`, `--no-fatal-warnings`
- https://dart.dev/tools/linter-rules/no_raw_types

**웹 검색 (LOW)**

- README 규칙 표 생성 도구 검색 — 기성 도구 없음. `dart-lang/lints` 는 규칙 목록을 `rules.md` 로 분리했다

---
*Stack research for: Dart/Flutter 공유 lint 설정 패키지*
*Researched: 2026-10-11*
