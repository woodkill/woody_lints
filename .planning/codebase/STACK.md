---
last_mapped_commit: 90a2736b8d998c84467faf562a0fec720b797eaf
last_mapped_at: 2026-10-11
---
# Technology Stack

**Analysis Date:** 2026-10-11

## Languages

**Primary:**
- YAML - 저장소의 실질적 산출물 전부. 공유 분석 옵션(analysis options) `lib/analysis_options.yaml`, 패키지 매니페스트 `pubspec.yaml`, 저장소 자체 분석용 `analysis_options.yaml`

**Secondary:**
- Markdown - `README.md`, `CHANGELOG.md`
- JSON - 도구 설정 `.fvmrc`, `.vscode/settings.json`
- Dart - 소스 파일 없음(`*.dart` 0개). 이 패키지는 Dart 코드를 담지 않고 Dart analyzer 설정만 배포한다. SDK 제약(constraint)만 `pubspec.yaml` 에 선언되어 있다.

## Runtime

**Environment:**
- Dart SDK `^3.10.4` (`pubspec.yaml` 의 `environment.sdk`). 최상위 `plugins:` 키(analysis_server_plugin 방식)가 Dart 3.10+ 를 요구한다.
- Flutter `3.41.2` - FVM(Flutter Version Management)으로 고정 (`.fvmrc`). 이 Flutter 에 번들된 Dart SDK 의 정확한 버전은 저장소에서 확인되지 않음.
- 실행 시점 런타임 없음. 소비 주체는 Dart Analysis Server / `dart analyze` / `flutter analyze` 이다.

**Package Manager:**
- pub (`dart pub` / `flutter pub`)
- Lockfile: `pubspec.lock` 은 로컬에 존재하나 `.gitignore` 로 제외(라이브러리 패키지 관례). 커밋하지 말 것.

## Frameworks

**Core:**
- `flutter_lints` `^6.0.0` (로컬 해석 버전 6.0.0) - 기반 규칙 세트. `lib/analysis_options.yaml` 이 `include: package:flutter_lints/flutter.yaml` 로 상속한다.
- `lints` 6.1.0 - `flutter_lints` 의 전이 의존성(transitive dependency).

**Testing:**
- Not detected - 테스트 프레임워크, `test/` 디렉터리 없음.

**Build/Dev:**
- FVM - Flutter SDK 버전 고정. 설정 `.fvmrc`, 캐시 `.fvm/` (gitignore).
- Dart Analysis Server - 규칙과 plugin 을 실제로 실행하는 주체.
- 빌드 단계 없음. 코드 생성(code generation), 번들러, 컴파일 산출물 없음.

## Key Dependencies

**Critical:**
- `flutter_lints` `^6.0.0` - `pubspec.yaml` 의 `dependencies` 에 둔다. `dev_dependencies` 는 사용하는 프로젝트의 의존성 그래프에 전달되지 않으므로 `include:` 해석이 깨진다. `dev_dependencies` 로 옮기지 말 것.
- `riverpod_lint` `^3.1.3` - `pubspec.yaml` 이 아니라 `lib/analysis_options.yaml` 의 최상위 `plugins:` 에 선언된 analyzer plugin. pub 의존성이 아니며 Dart Analysis Server 의 plugin 캐시(`~/.dartServer/.plugin_manager`)에서 별도로 해석된다.

**Infrastructure:**
- Not applicable

## Configuration

**Environment:**
- 환경 변수 사용 없음. `.env` 파일 없음.
- 설정은 전부 YAML 파일로 선언된다.

**배포용 공유 설정 `lib/analysis_options.yaml`:**
- `include: package:flutter_lints/flutter.yaml`
- `linter.rules` 로 추가 활성화한 규칙:
  - 성능: `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `sized_box_for_whitespace`
  - 가독성/스타일: `always_declare_return_types`, `sort_child_properties_last`, `prefer_final_locals`, `prefer_single_quotes`, `slash_for_doc_comments`
  - 버그 방지: `use_build_context_synchronously`, `unawaited_futures`, `avoid_print`, `control_flow_in_finally`
- 주석 처리되어 비활성인 항목: `require_trailing_commas`, `public_member_api_docs`, `formatter: trailing_commas: preserve`
- `analyzer.errors`: `invalid_annotation_target: ignore`
- `analyzer.exclude`: `**/*.freezed.dart`, `**/*.g.dart`
- 최상위 `plugins:`: `riverpod_lint: ^3.1.3`

**저장소 자체 분석용 `analysis_options.yaml` (루트):**
- `analyzer.exclude` 에 `lib/analysis_options.yaml` 을 넣어 `plugins_in_inner_options` 경고를 피한다. 사용하는 프로젝트에는 전달되지 않는다.

**규칙 추가 시 패턴:**

```yaml
linter:
  rules:
    # 버그 방지
    - rule_name # 한국어로 목적 한 줄 설명

```

- 규칙은 `lib/analysis_options.yaml` 의 분류 주석(성능 / 가독성 및 스타일 / 버그 방지) 아래에 추가하고, `README.md` 의 "포함된 규칙 목록" 과 `CHANGELOG.md`, `pubspec.yaml` 의 `version` 을 함께 갱신한다.
- analyzer plugin 은 `analyzer: plugins:` 가 아니라 최상위 `plugins:` 에 선언한다.

**Build:**
- `pubspec.yaml` - 패키지 이름 `woody_lints`, 버전 `1.3.0`, `publish_to: 'none'`
- `.fvmrc` - Flutter `3.41.2`
- `.vscode/settings.json` - `dart.flutterSdkPath` 를 `.fvm/versions/3.41.2` 로 지정

## Platform Requirements

**Development:**
- FVM 과 Flutter 3.41.2 설치
- 검증 명령은 `dart analyze` 를 사용한다. `lib/analysis_options.yaml` 주석 기록상 Flutter 3.47.5 의 `flutter analyze` 는 plugin 진단을 표시하지 않는다.
- `plugins:` 섹션을 바꾼 뒤에는 Dart Analysis Server 를 재시작한다.

**Production:**
- 배포 대상 없음. pub.dev 에 게시하지 않으며(`publish_to: 'none'`), 사용하는 프로젝트가 git 의존성으로 가져간다.
- 사용하는 프로젝트 요구 사항: Dart SDK 3.10.4 이상, `analysis_options.yaml` 에 `include: package:woody_lints/analysis_options.yaml`

---

*Stack analysis: 2026-10-11*
