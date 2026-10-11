<!-- GSD:project-start source:PROJECT.md -->

## Project

**woody_lints**

`woody_lints` 는 Flutter 프로젝트의 `analysis_options.yaml` 에서 `include:` 한 줄로 끌어다 쓰는 설정 전용 패키지(configuration-only package)다. Dart 코드는 없고 `lib/analysis_options.yaml` 이 유일한 배포 산출물이며, 작성자 본인의 Flutter 프로젝트들이 Git 의존성으로 가져다 쓴다.

이번 작업은 "잘 모르던 시절에 만든" 이 패키지를 지금 기준으로 다시 다듬어 새 버전으로 릴리스하는 것이다.

**Core Value:** 사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.

### Constraints

- **SDK**: Flutter 3.47.x / Dart 3.13 이상만 지원 — 사용 프로젝트가 3.47.5 이고, 최신 lint 규칙과 `riverpod_lint` 3.1.9 를 쓰기 위해
- **Compatibility**: `package:woody_lints/analysis_options.yaml` URI 는 공개 API 다 — 모든 사용 프로젝트가 이 경로로 참조하므로, 프리셋을 나눈 뒤에도 이 URI 는 지금과 같은 뜻(기본 + Riverpod + codegen)을 유지한다. 새 문서는 정식 이름 `package:woody_lints/recommended.yaml` 을 안내한다
- **Release channel**: 릴리스 전까지 `main` 의 `lib/` 와 `pubspec.yaml` 은 1.3.0 상태를 유지한다 — 사용 프로젝트 5개가 `ref: main` 을 따른다
- **Distribution**: Git 의존성 + git tag 로만 배포 — pub.dev 에 올리지 않는다
- **Safety**: 실측은 `flutter_starter_kit` 복사본에서 한다 — 원본 프로젝트는 수정하지 않는다
- **Verification**: plugin 진단 확인은 `dart analyze` 로 한다 — `flutter analyze` 는 Flutter 버전에 따라 plugin 진단을 누락한다
- **Dependencies**: `include:` 대상 패키지는 `dependencies` 에 둔다 — `dev_dependencies` 는 사용 프로젝트의 의존성 그래프에 전달되지 않는다
- **Documentation**: YAML 주석, README, CHANGELOG 는 한국어로 쓰고 규칙명·키는 영어 원문을 쓴다 — 기존 관례이며 독자가 작성자 본인이다

<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->

## Technology Stack

## Languages

- YAML - 저장소의 실질적 산출물 전부. 공유 분석 옵션(analysis options) `lib/analysis_options.yaml`, 패키지 매니페스트 `pubspec.yaml`, 저장소 자체 분석용 `analysis_options.yaml`
- Markdown - `README.md`, `CHANGELOG.md`
- JSON - 도구 설정 `.fvmrc`, `.vscode/settings.json`
- Dart - 소스 파일 없음(`*.dart` 0개). 이 패키지는 Dart 코드를 담지 않고 Dart analyzer 설정만 배포한다. SDK 제약(constraint)만 `pubspec.yaml` 에 선언되어 있다.

## Runtime

- Dart SDK `^3.10.4` (`pubspec.yaml` 의 `environment.sdk`). 최상위 `plugins:` 키(analysis_server_plugin 방식)가 Dart 3.10+ 를 요구한다.
- Flutter `3.41.2` - FVM(Flutter Version Management)으로 고정 (`.fvmrc`). 이 Flutter 에 번들된 Dart SDK 의 정확한 버전은 저장소에서 확인되지 않음.
- 실행 시점 런타임 없음. 소비 주체는 Dart Analysis Server / `dart analyze` / `flutter analyze` 이다.
- pub (`dart pub` / `flutter pub`)
- Lockfile: `pubspec.lock` 은 로컬에 존재하나 `.gitignore` 로 제외(라이브러리 패키지 관례). 커밋하지 말 것.

## Frameworks

- `flutter_lints` `^6.0.0` (로컬 해석 버전 6.0.0) - 기반 규칙 세트. `lib/analysis_options.yaml` 이 `include: package:flutter_lints/flutter.yaml` 로 상속한다.
- `lints` 6.1.0 - `flutter_lints` 의 전이 의존성(transitive dependency).
- Not detected - 테스트 프레임워크, `test/` 디렉터리 없음.
- FVM - Flutter SDK 버전 고정. 설정 `.fvmrc`, 캐시 `.fvm/` (gitignore).
- Dart Analysis Server - 규칙과 plugin 을 실제로 실행하는 주체.
- 빌드 단계 없음. 코드 생성(code generation), 번들러, 컴파일 산출물 없음.

## Key Dependencies

- `flutter_lints` `^6.0.0` - `pubspec.yaml` 의 `dependencies` 에 둔다. `dev_dependencies` 는 사용하는 프로젝트의 의존성 그래프에 전달되지 않으므로 `include:` 해석이 깨진다. `dev_dependencies` 로 옮기지 말 것.
- `riverpod_lint` `^3.1.3` - `pubspec.yaml` 이 아니라 `lib/analysis_options.yaml` 의 최상위 `plugins:` 에 선언된 analyzer plugin. pub 의존성이 아니며 Dart Analysis Server 의 plugin 캐시(`~/.dartServer/.plugin_manager`)에서 별도로 해석된다.
- Not applicable

## Configuration

- 환경 변수 사용 없음. `.env` 파일 없음.
- 설정은 전부 YAML 파일로 선언된다.
- `include: package:flutter_lints/flutter.yaml`
- `linter.rules` 로 추가 활성화한 규칙:
- 주석 처리되어 비활성인 항목: `require_trailing_commas`, `public_member_api_docs`, `formatter: trailing_commas: preserve`
- `analyzer.errors`: `invalid_annotation_target: ignore`
- `analyzer.exclude`: `**/*.freezed.dart`, `**/*.g.dart`
- 최상위 `plugins:`: `riverpod_lint: ^3.1.3`
- `analyzer.exclude` 에 `lib/analysis_options.yaml` 을 넣어 `plugins_in_inner_options` 경고를 피한다. 사용하는 프로젝트에는 전달되지 않는다.
- 규칙은 `lib/analysis_options.yaml` 의 분류 주석(성능 / 가독성 및 스타일 / 버그 방지) 아래에 추가하고, `README.md` 의 "포함된 규칙 목록" 과 `CHANGELOG.md`, `pubspec.yaml` 의 `version` 을 함께 갱신한다.
- analyzer plugin 은 `analyzer: plugins:` 가 아니라 최상위 `plugins:` 에 선언한다.
- `pubspec.yaml` - 패키지 이름 `woody_lints`, 버전 `1.3.0`, `publish_to: 'none'`
- `.fvmrc` - Flutter `3.41.2`
- `.vscode/settings.json` - `dart.flutterSdkPath` 를 `.fvm/versions/3.41.2` 로 지정

## Platform Requirements

- FVM 과 Flutter 3.41.2 설치
- 검증 명령은 `dart analyze` 를 사용한다. `lib/analysis_options.yaml` 주석 기록상 Flutter 3.47.5 의 `flutter analyze` 는 plugin 진단을 표시하지 않는다.
- `plugins:` 섹션을 바꾼 뒤에는 Dart Analysis Server 를 재시작한다.
- 배포 대상 없음. pub.dev 에 게시하지 않으며(`publish_to: 'none'`), 사용하는 프로젝트가 git 의존성으로 가져간다.
- 사용하는 프로젝트 요구 사항: Dart SDK 3.10.4 이상, `analysis_options.yaml` 에 `include: package:woody_lints/analysis_options.yaml`

<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->

## Conventions

## 저장소 성격(Repository Nature)

| 파일 | 역할 |
|------|------|
| `lib/analysis_options.yaml` | 배포 산출물. 사용하는 프로젝트가 `include: package:woody_lints/analysis_options.yaml` 로 가져가는 공유 린트(lint) 설정 |
| `analysis_options.yaml` | 이 저장소 자체 분석 전용 설정. 사용하는 프로젝트에 전달되지 않는다 |
| `pubspec.yaml` | 패키지 메타데이터, 버전, 의존성 |
| `README.md` | 사용법과 규칙 목록 (한국어) |
| `CHANGELOG.md` | 버전별 변경 내역 (한국어) |
| `.fvmrc` | FVM Flutter 버전 고정 (`3.41.2`) |
| `.vscode/settings.json` | `dart.flutterSdkPath` 를 `.fvm/versions/3.41.2` 로 지정 |
| `.gitignore` | `.dart_tool/`, `pubspec.lock`, `.DS_Store`, `.fvm/` 제외 |

## Naming Patterns

- 배포용 설정 파일 이름은 `lib/analysis_options.yaml` 로 고정한다. 사용하는 프로젝트의 `include:` 경로(`package:woody_lints/analysis_options.yaml`)가 이 이름에 의존하므로 이름을 바꾸거나 옮기지 않는다.
- 문서 파일은 대문자 이름을 쓴다: `README.md`, `CHANGELOG.md`.
- Not applicable — 이 저장소에는 Dart 코드가 없다.
- `pubspec.yaml` 의 `name: woody_lints` 는 snake_case 다. `include:` 경로와 사용하는 프로젝트의 `dev_dependencies` 키가 이 이름을 쓴다.
- `linter: rules:` 항목은 Dart 공식 규칙 이름(snake_case)을 그대로 쓴다. 예: `prefer_const_constructors`.

## Code Style

- YAML 은 2칸 들여쓰기를 쓴다 (`lib/analysis_options.yaml`, `pubspec.yaml`).
- 자동 포맷터(formatter) 설정은 활성화되어 있지 않다. `lib/analysis_options.yaml` 15-16행의 `formatter: trailing_commas: preserve` 는 주석 처리된 상태다.
- YAML/Markdown 용 포맷터나 린터(예: prettier, yamllint, markdownlint) 설정 파일은 Not detected.
- 기반 규칙 세트: `include: package:flutter_lints/flutter.yaml` (`flutter_lints ^6.0.0`, lock 기준 `6.0.0`, 전이 의존 `lints 6.1.0`).
- 추가로 켜는 규칙은 `lib/analysis_options.yaml` 의 `linter: rules:` 에 **목록 형식(list form)** 으로 적는다.

| 분류 | 규칙 | 의도 |
|------|------|------|
| 성능 | `prefer_const_constructors` | 위젯 재사용 극대화 |
| 성능 | `prefer_const_literals_to_create_immutables` | 불변 컬렉션의 효율적 관리 |
| 성능 | `sized_box_for_whitespace` | 가벼운 여백 위젯 사용 |
| 가독성 및 스타일 | `always_declare_return_types` | 반환 타입 명시 |
| 가독성 및 스타일 | `sort_child_properties_last` | `child`/`children` 을 마지막 인자로 |
| 가독성 및 스타일 | `prefer_final_locals` | 지역 변수 불변성 |
| 가독성 및 스타일 | `prefer_single_quotes` | 홑따옴표 통일 |
| 가독성 및 스타일 | `slash_for_doc_comments` | `///` 문서 주석 통일 |
| 버그 방지 | `use_build_context_synchronously` | 비동기 gap 이후 `BuildContext` 사용 방지 |
| 버그 방지 | `unawaited_futures` | 처리되지 않은 `Future` 감지 |
| 버그 방지 | `avoid_print` | `print` 사용 금지 |
| 버그 방지 | `control_flow_in_finally` | `finally` 블록 내 제어문 금지 |
- `require_trailing_commas` (`lib/analysis_options.yaml` 31행)
- `public_member_api_docs` (`lib/analysis_options.yaml` 34행)
- `formatter: trailing_commas: preserve` (`lib/analysis_options.yaml` 15-16행)
- `errors: invalid_annotation_target: ignore` — freezed/json_serializable 어노테이션 사용을 전제로 한다.
- `exclude:` 에 생성 코드 `'**/*.freezed.dart'`, `'**/*.g.dart'` 를 둔다.
- `riverpod_lint: ^3.1.3` 을 **최상위 `plugins:` 키** 로 선언한다 (Dart 3.10+ analysis_server_plugin 방식).
- `analyzer: plugins:` 아래에 선언하지 않는다. riverpod_lint 3.x 에서는 그 방식이 아무것도 로드하지 않는다 (`lib/analysis_options.yaml` 49-56행 주석, `CHANGELOG.md` 1.3.0 항목).

## 규칙 추가/변경 방법 (Prescriptive)

- 규칙은 세 그룹(`# 성능`, `# 가독성 및 스타일`, `# 버그 방지`) 중 하나 아래에 넣는다.
- 각 규칙 줄 끝에 한국어 인라인 주석으로 의도를 한 줄로 적는다.
- 규칙을 끌 때는 줄을 삭제하지 않고 `# - rule_name # 설명` 형태로 주석 처리한다 (31행, 34행의 방식).
- 목록 형식(`- rule`)을 유지한다. 맵 형식(`rule: true`)과 섞지 않는다.

## 문서 동기화 상태 (주의)

- `README.md` 81행은 `require_trailing_commas` 를 포함된 규칙으로 적지만, `lib/analysis_options.yaml` 31행에서는 주석 처리되어 있다.
- `README.md` 91-92행은 `formatter: trailing_commas` 를 포함된 설정으로 적지만, `lib/analysis_options.yaml` 15-16행에서는 주석 처리되어 있다.
- `README.md` 는 `analyzer:` 의 `errors`/`exclude` 설정(`invalid_annotation_target`, `*.freezed.dart`, `*.g.dart`)을 언급하지 않는다.
- `CHANGELOG.md` 에는 `1.3.0` 과 `1.0.0` 항목만 있다. git 이력에 있는 중간 버전(예: 커밋 `dbcd20b` 의 1.2.5)은 기록되어 있지 않다.

## Import Organization

- Not applicable — Dart 소스가 없다.
- Not applicable.

## 의존성 선언 규칙

- `flutter_lints` 는 `pubspec.yaml` 의 `dependencies:` 에 둔다. `dev_dependencies:` 로 옮기지 않는다. `dev_dependencies` 는 사용하는 프로젝트의 의존성 그래프에 포함되지 않아 `include: package:flutter_lints/flutter.yaml` 해석이 깨진다 (`pubspec.yaml` 13-15행 주석).
- `riverpod_lint` 는 `pubspec.yaml` 에 넣지 않는다. `lib/analysis_options.yaml` 의 최상위 `plugins:` 에서만 버전을 지정하며, Dart Analysis Server 의 plugin 캐시(`~/.dartServer/.plugin_manager`)에서 해석된다.
- `publish_to: 'none'` 을 유지한다. 이 패키지는 pub.dev 에 올리지 않고 git 의존성으로만 배포한다 (`ref: main`).
- SDK 제약은 `environment: sdk: ^3.10.4` 다. 최상위 `plugins:` 방식이 Dart 3.10+ 를 요구하므로 이보다 낮추지 않는다.
- `pubspec.lock` 은 `.gitignore` 대상이다. 커밋하지 않는다.

## Error Handling

- Not applicable — 실행 코드가 없다.
- 설정 수준에서는 `analyzer: errors:` 로 진단 심각도를 조정한다. 현재 조정 항목은 `invalid_annotation_target: ignore` 하나다.
- 저장소 자체 분석에서 나는 `plugins_in_inner_options` 경고는 루트 `analysis_options.yaml` 에서 `lib/analysis_options.yaml` 을 `exclude` 하는 방식으로 처리한다. 루트 파일에 `plugins:` 를 추가하거나 `lib/analysis_options.yaml` 의 `plugins:` 를 제거하는 방식으로 해결하지 않는다.

## Logging

- `avoid_print` 가 켜져 있으므로 이 패키지를 쓰는 프로젝트에서는 `print` 대신 로거(logger) 또는 `debugPrint` 를 쓴다.

## Comments

- YAML 주석은 한국어로 쓴다. 템플릿에서 온 영어 주석(`lib/analysis_options.yaml` 1-12행, 60-64행)은 그대로 둔다.
- 설정의 **이유(why)** 를 적는다. "무엇을 하는가"가 아니라 "왜 이 위치/방식인가"를 설명한다. 예: `pubspec.yaml` 13-15행(왜 `dependencies` 인가), `analysis_options.yaml` 1-6행(왜 exclude 하는가), `lib/analysis_options.yaml` 49-56행(왜 최상위 `plugins:` 인가).
- 실측으로 확인한 동작은 버전과 날짜를 함께 적는다. 예: `lib/analysis_options.yaml` 55-56행 "Flutter 3.47.5 의 `flutter analyze` 는 plugin 진단을 표시하지 않았다 (3.41.9 는 표시, 2026-09-20 실측)".
- 한국어 문장에서 영어 식별자 뒤 조사는 한 칸 띄어 쓴다. 예: "riverpod_lint 를", "`plugins:` 가".
- 사용하는 프로젝트에는 `slash_for_doc_comments` 로 `///` 형식을 강제한다.
- `public_member_api_docs` 는 비활성이므로 공개 API 문서화는 린트로 강제되지 않는다.

## Function Design

## Module Design

- 유일한 공개 산출물은 `lib/analysis_options.yaml` 이다. `lib/` 에 Dart 라이브러리 파일(예: `lib/woody_lints.dart`)은 없다.
- Not applicable.

## 버전 및 변경 이력 규칙

- `pubspec.yaml` 의 `version:` 은 `major.minor.patch` 형식이다 (현재 `1.3.0`).
- `CHANGELOG.md` 는 최신 버전이 위로 오며, `## x.y.z` 제목 아래 한국어 불릿으로 쓴다. 하위 불릿으로 원인과 영향을 적는다 (`CHANGELOG.md` 3-5행 형식).
- 사용하는 프로젝트에 영향이 없는 변경은 "사용하는 프로젝트에는 영향 없음" 이라고 명시한다 (`CHANGELOG.md` 7행).

## Git 커밋 규칙

- 최신 커밋은 Conventional Commits 형식이다: prefix 는 영어, 제목은 한국어, 버전은 괄호로 덧붙인다.
- 이전 커밋은 prefix 없는 자유 형식이다 (예: `a97fd20 fvm 적용`, `9451f6b slash_for_doc_comments 추가`).
- 새 커밋은 Conventional Commits 형식(`feat:`, `fix:`, `chore:`, `docs:`)으로 쓰고 제목과 본문은 한국어로 쓴다.

## 도구 버전 고정

- Flutter 버전은 FVM 으로 고정한다: `.fvmrc` 의 `"flutter": "3.41.2"`.
- `.vscode/settings.json` 의 `dart.flutterSdkPath` 는 `.fvmrc` 와 같은 버전(`.fvm/versions/3.41.2`)을 가리킨다. `.fvmrc` 를 바꾸면 이 파일도 함께 바꾼다.
- `.fvm/` 디렉터리는 `.gitignore` 대상이다.

## 프로젝트 스킬(Project Skills)

- `.claude/skills/`, `.agents/skills/` 디렉터리는 Not detected.

<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->

## Architecture

## System Overview

```text

```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| 공유 분석 설정 (Shared analysis options) | 사용하는 프로젝트에 적용되는 lint 규칙, analyzer 오류 설정, 제외 glob, analyzer plugin 선언. 유일한 배포 산출물 | `lib/analysis_options.yaml` |
| 패키지 매니페스트 (Package manifest) | 패키지 이름·버전, SDK 제약, 사용하는 프로젝트로 전달되는 의존성(`flutter_lints`) 선언 | `pubspec.yaml` |
| 자체 분석 설정 (Self-analysis options) | 이 저장소를 분석할 때만 적용. `lib/analysis_options.yaml` 을 분석 대상에서 제외해 `plugins_in_inner_options` 경고 차단 | `analysis_options.yaml` |
| 사용 문서 (Usage documentation) | 설치 절차와 포함 규칙 목록 | `README.md` |
| 변경 이력 (Release notes) | 버전별 변경 사항과 그 이유 | `CHANGELOG.md` |
| SDK 고정 (SDK pin) | FVM 으로 Flutter SDK 버전 고정 (3.41.2) | `.fvmrc`, `.vscode/settings.json` |

## Pattern Overview

- 실행 코드 없음. `lib/` 에는 `.dart` 파일이 없고 YAML 하나만 존재한다.
- 계층 합성(composition by include): `lints` (core/recommended) → `flutter_lints/flutter.yaml` → `lib/analysis_options.yaml` → 사용하는 프로젝트의 `analysis_options.yaml`. 아래 계층이 위 계층을 덮어쓴다.
- pub.dev 미배포. `pubspec.yaml` 의 `publish_to: 'none'` 로 막혀 있고, Git 의존성(`ref: main`)으로만 배포된다. `main` 브랜치에 push 하는 순간이 곧 릴리스다.
- 두 개의 서로 다른 해석 경로(resolution path)가 공존한다: `include:` 는 pub 의존성 그래프로, `plugins:` 는 Dart Analysis Server 의 plugin 캐시(`~/.dartServer/.plugin_manager`)로 해석된다.

## Layers

- Purpose: Flutter 공식 권장 lint 세트 제공
- Location: 외부 패키지 `package:flutter_lints/flutter.yaml` (`pubspec.lock` 기준 flutter_lints 6.0.0, lints 6.1.0)
- Contains: core / recommended / flutter lint 규칙
- Depends on: `lints`
- Used by: `lib/analysis_options.yaml:13`
- Purpose: 기반 규칙 위에 추가 규칙·analyzer 설정·plugin 을 얹는다
- Location: `lib/analysis_options.yaml`
- Contains: `include:`, `linter.rules`, `analyzer.errors`, `analyzer.exclude`, 최상위 `plugins:`
- Depends on: `flutter_lints` (`pubspec.yaml:16-17`), `riverpod_lint ^3.1.3` (`lib/analysis_options.yaml:57-58`)
- Used by: 사용하는 Flutter 프로젝트의 `analysis_options.yaml`
- Purpose: pub 이 패키지를 해석하고 의존성을 전달하도록 한다
- Location: `pubspec.yaml`
- Contains: `name`, `version`, `environment.sdk`, `dependencies`
- Depends on: Dart SDK `^3.10.4`
- Used by: `flutter pub get` / `dart pub get`
- Purpose: 이 저장소를 개발할 때만 쓰이는 설정. 사용하는 프로젝트에는 전달되지 않는다
- Location: `analysis_options.yaml`, `.fvmrc`, `.vscode/settings.json`, `.gitignore`
- Contains: 자체 분석 제외 규칙, Flutter SDK 버전 고정, 편집기 SDK 경로
- Depends on: FVM
- Used by: 저장소 기여자와 IDE

## Data Flow

### Primary Request Path (사용하는 프로젝트의 정적 분석)

### Analyzer Plugin 로드 경로

### 저장소 자체 분석 경로

- 런타임 상태 없음. 모든 동작은 YAML 선언으로 결정되고, 버전 상태는 `pubspec.yaml:3` 의 `version` 필드와 Git `main` 브랜치의 HEAD 가 전부다.

## Key Abstractions

- Purpose: 여러 Flutter 프로젝트가 재사용하는 lint 정책 단일 진실 원천(single source of truth)
- Examples: `lib/analysis_options.yaml`
- Pattern: `include:` 체인. 패키지 URI `package:woody_lints/analysis_options.yaml` 는 반드시 `lib/` 바로 아래 파일로 해석되므로 파일 위치와 이름이 곧 공개 API 다.
- Purpose: `linter.rules` 안에서 규칙을 목적별로 묶는다
- Examples: `lib/analysis_options.yaml:22` (`# 성능`), `:27` (`# 가독성 및 스타일`), `:36` (`# 버그 방지`)
- Pattern: 한국어 그룹 주석 + 규칙마다 한 줄 한국어 설명 주석. 비활성 규칙은 삭제하지 않고 주석 처리로 남긴다 (`:31`, `:34`).
- Purpose: 사용하는 프로젝트가 `flutter_lints` 를 직접 선언하지 않아도 `include:` 가 해석되게 한다
- Examples: `pubspec.yaml:13-17`
- Pattern: `include:` 대상 패키지는 `dependencies` 에 둔다. `dev_dependencies` 는 사용하는 쪽 의존성 그래프에 포함되지 않는다.
- Purpose: lint 규칙 목록으로 표현할 수 없는 패키지 고유 규칙(Riverpod) 추가
- Examples: `lib/analysis_options.yaml:57-58`
- Pattern: 최상위 `plugins:` 맵에 `패키지명: 버전 제약`. `analyzer: plugins:` 리스트 방식은 쓰지 않는다.

## Entry Points

- Location: `lib/analysis_options.yaml`
- Triggers: 사용하는 프로젝트의 `include: package:woody_lints/analysis_options.yaml`
- Responsibilities: 기반 규칙 include, 추가 규칙 활성화, analyzer 오류·제외 설정, plugin 선언
- Location: `pubspec.yaml`
- Triggers: 사용하는 프로젝트의 `flutter pub get` / `flutter pub upgrade woody_lints`
- Responsibilities: 패키지 식별, SDK 제약 검사, `flutter_lints` 전달
- Location: `analysis_options.yaml`
- Triggers: 이 저장소에서 실행하는 `dart analyze` 또는 IDE 의 Analysis Server
- Responsibilities: `lib/analysis_options.yaml` 을 분석에서 제외

## Architectural Constraints

- **Threading:** 해당 없음. 실행 코드가 없다.
- **Global state:** 해당 없음. 모듈 수준 상태가 없다.
- **Circular imports:** 해당 없음. `include:` 체인은 `lib/analysis_options.yaml` → `flutter_lints` → `lints` 단방향이다.
- **파일 위치 고정:** `lib/analysis_options.yaml` 의 경로와 파일명은 변경 불가. 사용하는 모든 프로젝트가 `package:woody_lints/analysis_options.yaml` URI 로 참조한다.
- **`plugins:` 위치:** 최상위 `plugins:` 는 analysis context 의 루트 옵션 파일로 취급될 때만 유효하다. 이 저장소 안에서는 `lib/analysis_options.yaml` 이 inner 옵션이 되므로 루트 `analysis_options.yaml` 의 exclude 가 반드시 유지되어야 한다.
- **SDK 하한:** `pubspec.yaml:11` 의 `sdk: ^3.10.4`. 최상위 `plugins:` (analysis_server_plugin) 는 Dart 3.10 이상에서만 동작한다.
- **Git ref 배포:** 사용하는 프로젝트가 `ref: main` 을 추적하므로 `main` 에 들어간 변경은 다음 `flutter pub upgrade woody_lints` 때 모든 프로젝트에 적용된다. 규칙 추가는 사용하는 프로젝트에 새 진단을 일으키는 변경이다.
- **plugin 해석 분리:** `riverpod_lint` 는 `pubspec.yaml` 에 없다. 버전은 `lib/analysis_options.yaml:58` 에서만 관리된다.
- **검증 명령:** plugin 진단 확인은 `dart analyze` 로 한다. `flutter analyze` 는 Flutter 버전에 따라 plugin 진단을 표시하지 않는다 (`lib/analysis_options.yaml:55-56`).

## Anti-Patterns

### `analyzer: plugins:` 리스트로 plugin 선언

### `include:` 대상 패키지를 `dev_dependencies` 에 선언

### 루트 `analysis_options.yaml` 에 공유 규칙 추가

### 문서와 설정의 불일치

## Error Handling

- 진단 심각도 재정의: `analyzer.errors` 에서 `invalid_annotation_target: ignore` (`lib/analysis_options.yaml:43-44`) — freezed / json_serializable 사용 시의 오탐 억제
- 생성 코드 제외: `analyzer.exclude` 에 `**/*.freezed.dart`, `**/*.g.dart` (`lib/analysis_options.yaml:45-47`)
- 자체 분석 경고 억제: 루트 `analysis_options.yaml:7-9` 의 exclude

## Cross-Cutting Concerns

<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->

## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->

## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-fast` for a trivial task inline, with no subagents and no PLAN.md
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->

## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->

## Spike Findings

- **woody_lints 의 spike 실측 결과** (구현 방식, 제약, 함정) → `Skill("spike-findings-woody-lints")` — 검증 명령(`tool/verify.dart`), `example/` 과 정답지, 규칙 상태 검사, CI workflow 를 만들거나 고치기 전에 읽는다
