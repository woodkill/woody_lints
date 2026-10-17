---
last_mapped_commit: 8ac96b71e9d394c5d1dfb132814ee87379519c69
last_mapped_at: 2026-10-17
---
# Technology Stack

**Analysis Date:** 2026-10-17

이 저장소는 설정 전용 패키지(configuration-only package)다. 받는 쪽(사용 프로젝트)에 가는 것은 `lib/` 의 YAML 다섯 개와 `pubspec.yaml` 의 `dependencies` 뿐이고, `tool/` 의 Dart 스크립트 · `example/` · `fixtures/` · CI 는 저장소 안쪽 도구다.

## Languages

**Primary:**
- YAML - 배포 산출물 전부. `lib/base.yaml` (95행, 규칙 81개), `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml`, `lib/analysis_options.yaml` (옛 주소 별칭). 그 밖에 `pubspec.yaml`, 루트 `analysis_options.yaml`, `.github/workflows/verify.yml`, 연습용 프로젝트의 `analysis_options.yaml`
- Dart (언어 버전 3.13, `pubspec.yaml:11` `sdk: ^3.13.0`) - 저장소 안쪽 도구만. `tool/verify.dart` (3223행), `tool/smoke.dart` (1143행), `tool/measure_rules.dart` (5188행). `lib/` 에는 `.dart` 파일이 없다 (`tool/verify.dart` 의 `[1/N]` 단계가 이것을 검사한다, `tool/verify.dart:4`)

**Secondary:**
- Dart (연습용 코드) - `example/lib/*.dart`, `fixtures/*/lib/*.dart` — 일부러 규칙을 어긴 코드. `example/lib/final_parameters_rule.dart` 는 `// @dart=3.11` 로 언어 버전을 낮춘다 (`example/README.md:47`)
- Markdown - `README.md`, `RULES.md`, `VERSIONING.md`, `CHANGELOG.md`, `example/README.md` (한국어)
- JSON - `.fvmrc`, `.vscode/settings.json`, 실측 결과 `tool/measurements/2026-10-13-R1.json`

## Runtime

**Environment:**
- 받는 쪽: 실행 시점 런타임 없음. 소비 주체는 Dart Analysis Server / `dart analyze`. 받는 쪽 요구 사항은 Dart 3.13 이상(Flutter 3.47 이상) — `pubspec.yaml:11`, `README.md:7`. 미만은 `ref: v1.3.0` 에 머문다 (`CHANGELOG.md` 2.0.0 항목)
- 저장소 안쪽: Flutter `3.47.5` 를 FVM 으로 고정 (`.fvmrc`). 번들 Dart 는 3.13.4 (`example/README.md:89`, `tool/measurements/2026-10-13-R1.json` 의 `conditions.dart`). `tool/verify.dart` · `tool/smoke.dart` 는 실행 중인 SDK 가 `.fvmrc` 와 다르면 종료 코드 78 로 멈춘다 (`tool/verify.dart` 머리 주석, `tool/smoke.dart:51`)

**Package Manager:**
- pub (`dart pub` / `flutter pub`)
- Lockfile: 루트 `pubspec.lock` 은 커밋하지 않는다 (`.gitignore`, 라이브러리 관례). `example/pubspec.lock` 과 `fixtures/*/pubspec.lock` 다섯은 커밋한다 (`.gitignore` 의 `!` 예외) — 로컬과 CI 가 같은 패키지 버전으로 판정하게 하려는 것

## Frameworks

**Core (받는 쪽에 가는 것):**
- `flutter_lints` `^6.0.0` (`pubspec.yaml:17`, 연습용 lock 기준 6.0.0) - 기반 규칙 세트. `lib/base.yaml:5` 가 `include: package:flutter_lints/flutter.yaml` 로 상속
- `lints` 6.1.0 - `flutter_lints` 의 전이 의존성 (`example/pubspec.lock`)
- `riverpod_lint` `^3.1.9` - analyzer plugin. `lib/riverpod.yaml:4-5` 의 최상위 `plugins:` 에 선언. pub 의존성이 아니다 (아래 "Key Dependencies")

**Testing (저장소 안쪽):**
- 테스트 프레임워크(`package:test`) 없음, `test/` 없음
- 검증은 `tool/verify.dart` 가 한다: 연습용 프로젝트(`example/` + `fixtures/` 다섯)를 `dart analyze` 로 분석해 정답지(`expected_diagnostics.txt`)와 견준다 (`tool/verify.dart:1-28`)
- 릴리스 smoke test: `tool/smoke.dart` (GitHub 에서 `<ref>` 를 받아 빈 Flutter 프로젝트로 확인)

**Build/Dev:**
- FVM - Flutter 버전 고정 (`.fvmrc`, 캐시 `.fvm/` 는 `.gitignore`)
- 빌드 단계 · 코드 생성 · 번들러 없음

## Key Dependencies

**Critical (받는 쪽 의존성 그래프에 들어감):**
- `flutter_lints` `^6.0.0` - `pubspec.yaml` 의 `dependencies` 에 둔다. `lib/base.yaml` 의 `include:` 는 받는 쪽 프로젝트의 패키지 해석으로 풀리는데, `dev_dependencies` 는 받는 쪽 의존성 그래프에 들어가지 않으므로 거기 두면 include 해석이 깨진다 (`pubspec.yaml:13-15` 주석)
- `woody_lints` 자기 자신 - `lib/recommended.yaml` · `lib/analysis_options.yaml` 이 `package:woody_lints/...` 로 조각을 include 한다 (자기 참조 include 사슬: `analysis_options.yaml` → `recommended.yaml` → `base.yaml` · `riverpod.yaml` · `codegen.yaml`)

**Plugin (pub 의존성 아님):**
- `riverpod_lint` `^3.1.9` - `pubspec.yaml` 에 없다. include 로 받은 최상위 `plugins:` 를 Dart Analysis Server 가 읽어, 자기 상태 폴더의 `.plugin_manager/<hash>/` 에 따로 받아 컴파일한다 (기본 자리 `~/.dartServer`, `README.md:363`). 옛 `analyzer: plugins:` 선언은 3.x 에서 아무것도 로드하지 않는다 (`lib/riverpod.yaml:2`). 하한을 바꾸면 `fixtures/overrides/analysis_options.yaml` 의 `version:` 과 README 예시도 같은 커밋에서 바꾼다 (`lib/riverpod.yaml:5` 주석, `tool/verify.dart` `[3/N]` · `[4/N]` 이 견준다)

**Infrastructure (저장소 안쪽, `dev_dependencies`):**
- `yaml` `^3.1.4` - `tool/verify.dart` `[3/N]` 이 줄 단위로 읽은 값을 YAML 해석 결과와 견주고 `version` 을 읽는다 (`pubspec.yaml:19-24`, `tool/verify.dart:49`)
- `markdown` `^7.3.1` - `tool/verify.dart` 가 `CHANGELOG.md` 첫 줄 제목을 Markdown 해석의 첫 h2 와 견준다 (`tool/verify.dart:48`)
- `tool/smoke.dart` · `tool/measure_rules.dart` 는 `dart:io` · `dart:convert` 만 쓴다 (`tool/smoke.dart:56`, `tool/measure_rules.dart:46-47`)

**연습용 프로젝트 의존성:**
- `flutter_riverpod` `^3.0.0` (lock 3.4.3), `flutter` SDK, `woody_lints` 는 `path: ..` / `path: ../..` (`example/pubspec.yaml`, `fixtures/*/pubspec.yaml`)

## Configuration

**Environment:**
- 환경 변수로 하는 설정 없음. `.env` 파일 없음
- 도구가 읽는 환경 변수: `FLUTTER_ROOT` (SDK 찾기, `tool/verify.dart:555`, `tool/smoke.dart:268`), `GITHUB_REF_TYPE` · `GITHUB_REF_NAME` · `CI` · `GITHUB_ACTIONS` (`tool/verify.dart:3105-3121`), `HOME` (출력 가리기, `tool/smoke.dart:347`)
- 도구가 하위 명령에 주는 환경 변수: `ANALYZER_STATE_LOCATION_OVERRIDE` (전용 analyzer 상태 폴더, `tool/verify.dart:712`, `tool/smoke.dart:729`), `PUB_CACHE` (smoke 의 새 pub cache, `tool/smoke.dart:13`)

**배포 설정 (`lib/`):**
- `lib/base.yaml` - `include: package:flutter_lints/flutter.yaml` + `linter.rules` 목록 (분류 주석: 성능 · 가독성 및 스타일 · 버그 방지 · strict)
- `lib/riverpod.yaml` - 최상위 `plugins: riverpod_lint: ^3.1.9`
- `lib/codegen.yaml` - `analyzer.errors.invalid_annotation_target: ignore`, `analyzer.exclude` 에 `**/*.freezed.dart` · `**/*.g.dart`
- `lib/recommended.yaml` - 위 셋을 include 하는 묶음
- `lib/analysis_options.yaml` - `include: package:woody_lints/recommended.yaml` 만 담은 옛 주소 별칭 (공개 API 라 유지)

**저장소 자체 분석:**
- 루트 `analysis_options.yaml` - `flutter_lints` 기반 세트만 include (이 패키지의 조각은 include 하지 않음), `analyzer.exclude` 에 `example/**` · `fixtures/**`

**Build:**
- 없음. `build/` 는 `tool/verify.dart` 의 규칙 검사 복사본 자리(`build/woody_rule_check/`)로 `.gitignore` 대상. `.dart_tool/woody_verify/` 는 검증 전용 analyzer 상태 폴더

## Platform Requirements

**Development:**
- FVM + Flutter 3.47.5 (`.fvmrc`), `.vscode/settings.json` 의 `dart.flutterSdkPath` 가 `.fvm/versions/3.47.5` 를 가리킨다 — `.fvmrc` 를 바꾸면 함께 바꾼다
- 검증: `fvm dart run tool/verify.dart [--update] [--tag vX.Y.Z]` (`tool/verify.dart:13`). plugin 진단은 `dart analyze` 로 본다
- `pubspec.yaml` 이 바뀐 작업 트리는 `fvm dart pub get` 을 먼저 한 번 돌린다 (안 하면 종료 코드 254, `example/README.md:11`)

**Production:**
- 배포 대상 서버 없음. `publish_to: 'none'` (`pubspec.yaml:6`). GitHub 저장소 `woodkill/woody_lints` 의 git tag(`v1.3.0`, `v2.0.0`)로 배포. 현재 `pubspec.yaml` 의 `version: 2.0.0`
- 받는 쪽: Dart 3.13 이상, `analysis_options.yaml` 에 `include: package:woody_lints/recommended.yaml` (또는 옛 주소)

---

*Stack analysis: 2026-10-17*
