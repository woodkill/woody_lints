---
last_mapped_commit: 90a2736b8d998c84467faf562a0fec720b797eaf
last_mapped_at: 2026-10-11
---
# External Integrations

**Analysis Date:** 2026-10-11

이 저장소는 Dart analyzer 설정만 배포하는 패키지다. 실행 코드가 없으므로 런타임 외부 연동(API 호출, 데이터베이스, 인증)은 존재하지 않는다. 연동은 전부 패키지 해석(resolution)과 배포 경로에 한정된다.

## APIs & External Services

**패키지 레지스트리(Package Registry):**
- pub.dev - `flutter_lints` `^6.0.0` 과 전이 의존성 `lints` 를 받아 온다.
  - SDK/Client: `dart pub get` / `flutter pub get`
  - Auth: 불필요(공개 패키지)
  - 선언 위치: `pubspec.yaml` 의 `dependencies`
- pub.dev (analyzer plugin 경로) - `riverpod_lint` `^3.1.3` 을 받아 온다.
  - SDK/Client: Dart Analysis Server 의 plugin manager. 첫 분석 때 내려받아 `~/.dartServer/.plugin_manager` 에 캐시한다. 사용하는 프로젝트의 `pubspec.lock` 과 별도로 해석된다.
  - Auth: 불필요
  - 선언 위치: `lib/analysis_options.yaml` 의 최상위 `plugins:`

**소스 호스팅 / 배포 채널:**
- GitHub - `https://github.com/woodkill/woody_lints.git` (`pubspec.yaml` 의 `repository`). 사용하는 프로젝트가 git 의존성으로 가져가는 유일한 배포 채널이다.
  - 사용하는 쪽 선언 예 (`README.md`):
    ```yaml
    dev_dependencies:
      woody_lints:
        git:
          url: https://github.com/woodkill/woody_lints.git
          ref: main
    ```
  - `ref: main` 을 추적하므로 `main` 브랜치에 푸시한 내용이 `flutter pub upgrade woody_lints` 를 실행한 프로젝트에 곧바로 반영된다. 버전 태그 기반 고정은 사용하지 않는다.
  - Auth: 개발자 push 는 SSH remote(`git@github.com:woodkill/woody_lints.git`) 사용. 저장소에 자격 증명 파일 없음.

## Data Storage

**Databases:**
- Not applicable

**File Storage:**
- Local filesystem only (저장소 파일 자체)

**Caching:**
- None (도구 캐시만 존재: `.dart_tool/`, `.fvm/` - 둘 다 `.gitignore` 로 제외)

## Authentication & Identity

**Auth Provider:**
- Not applicable

## Monitoring & Observability

**Error Tracking:**
- None

**Logs:**
- Not applicable. 진단은 `dart analyze` 출력과 IDE 의 Dart Analysis Server 로 확인한다.

## CI/CD & Deployment

**Hosting:**
- GitHub 저장소 (git 의존성으로 소비). pub.dev 게시 없음 (`pubspec.yaml` 의 `publish_to: 'none'`).

**CI Pipeline:**
- None - `.github/` 디렉터리와 CI 설정 파일 없음. 릴리스는 `pubspec.yaml` 의 `version` 과 `CHANGELOG.md` 를 수동으로 갱신한 뒤 `main` 에 푸시하는 방식이다.

## Environment Configuration

**Required env vars:**
- None

**Secrets location:**
- Not applicable - 비밀 값(secret)을 사용하지 않는다. `.env` 및 자격 증명 파일 없음.

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## 도구 연동 (Tooling Integrations)

**FVM:**
- `.fvmrc` 가 Flutter `3.41.2` 를 고정한다. `.fvm/flutter_sdk` 는 로컬 FVM 캐시를 가리키는 심볼릭 링크이며 커밋되지 않는다.

**VS Code (Dart 확장):**
- `.vscode/settings.json` 의 `dart.flutterSdkPath` 가 `.fvm/versions/3.41.2` 를 가리킨다. `.fvmrc` 의 Flutter 버전을 바꾸면 이 경로도 함께 바꾼다.

**사용하는 프로젝트 쪽 코드 생성 도구와의 접점:**
- `lib/analysis_options.yaml` 이 `**/*.freezed.dart`, `**/*.g.dart` 를 분석에서 제외하고 `invalid_annotation_target` 을 무시한다. 사용하는 프로젝트가 freezed / json_serializable 계열 생성 코드를 쓰는 것을 전제로 한 설정이며, 이 저장소가 해당 패키지에 의존하지는 않는다.
- `riverpod_lint` plugin 은 사용하는 프로젝트가 Riverpod 를 쓰는 것을 전제로 한다.

---

*Integration audit: 2026-10-11*
