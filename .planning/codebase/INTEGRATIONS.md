---
last_mapped_commit: 8ac96b71e9d394c5d1dfb132814ee87379519c69
last_mapped_at: 2026-10-17
---
# External Integrations

**Analysis Date:** 2026-10-17

외부 서비스가 거의 없는 설정 전용 패키지다. 아래가 저장소 · 도구가 닿는 바깥 전부다.

## APIs & External Services

**배포 (GitHub git 의존성):**
- GitHub 저장소 `https://github.com/woodkill/woody_lints.git` (`pubspec.yaml:8`) - 받는 쪽이 `git: url / ref:` 로 받는다 (`README.md:16-18`, 기본 안내 `ref: v2.0.0`)
  - SDK/Client: pub 의 git 소스
  - Auth: 없음 (공개 저장소 읽기)
  - tag: `v1.3.0`, `v2.0.0` (`git tag`). 한 번 올린 tag 는 옮기지 않는다 (`VERSIONING.md`). `ref: main` 을 따르는 프로젝트는 `flutter pub upgrade woody_lints` 때 새 커밋을 받고 `pub get` 은 lock 의 커밋에 머문다 (`CHANGELOG.md` 2.0.0, spike 015)

**패키지 해석 (pub.dev):**
- pub.dev - `flutter_lints` · `lints` · `yaml` · `markdown` · 연습용 `flutter_riverpod` 해석
  - Client: `dart pub` / `flutter pub`
  - Auth: 없음
- 이 패키지는 pub.dev 에 올리지 않는다 (`pubspec.yaml:6` `publish_to: 'none'`)

**Analyzer plugin 캐시:**
- Dart Analysis Server 가 `riverpod_lint` 를 pub.dev 에서 받아 상태 폴더의 `.plugin_manager/<hash>/` 에 컴파일 (기본 `~/.dartServer`, `README.md:363` — 읽은 것, 그 자리에서 잰 것은 아님)
- 도구는 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 전용 상태 폴더를 쓴다: `.dart_tool/woody_verify/` (`tool/verify.dart:712`), smoke 는 주소마다 새 폴더 (`tool/smoke.dart:729`)

**도구가 쓰는 네트워크:**
- `tool/smoke.dart` - GitHub 에서 `<ref>` 를 받고 pub.dev 에서 의존성 · plugin 을 받는다 (새 `PUB_CACHE`, 약 1분, `tool/smoke.dart:13-15,57`). `flutter create` 로 저장소 밖 임시 프로젝트를 만든다. 올리는 것은 없다
- `tool/measure_rules.dart` - `https://raw.githubusercontent.com/dart-lang/sdk/3.13.4/pkg/linter/messages.yaml` 에서 규칙 상태를 읽는다 (`tool/measure_rules.dart:51-54`). 못 받으면 `.planning/spikes/` 의 spike 020 결과를 대신 읽는다 (`tool/measure_rules.dart:56-58`)
- `tool/verify.dart` - 준비 단계의 `pub get` 과 plugin 준비 외에 직접 호출하는 외부 API 없음

## Data Storage

**Databases:**
- 없음

**File Storage:**
- 로컬 파일 시스템만. 실측 결과 JSON 은 `tool/measurements/` (예: `tool/measurements/2026-10-13-R1.json`). 비공개 사용 프로젝트의 원문은 저장소 밖 작업 폴더의 `private` 하위 폴더에만 쓴다 (`tool/measure_rules.dart` 머리 주석)

**Caching:**
- pub cache, Analysis Server plugin 캐시, `.dart_tool/woody_verify/` (지우면 다음 실행이 plugin 을 다시 준비, 약 15초 — `tool/verify.dart` 머리 주석)

## Authentication & Identity

**Auth Provider:**
- 없음

## Monitoring & Observability

**Error Tracking:**
- 없음

**Logs:**
- 도구의 stdout/stderr 와 종료 코드 (0 / 1 / 64 / 69 / 70 / 78 등, `tool/verify.dart` · `tool/smoke.dart` 머리 주석). CI 로그는 GitHub Actions

## CI/CD & Deployment

**Hosting:**
- GitHub (git tag 배포). 호스팅 서버 없음

**CI Pipeline:**
- GitHub Actions `.github/workflows/verify.yml`
  - 트리거: 모든 `push` (브랜치 · tag), `pull_request`, `workflow_dispatch`
  - `runs-on: ubuntu-latest`, `timeout-minutes: 10` (정상 약 4분 7초), `permissions: contents: read`, 브랜치별 `concurrency` 취소
  - 단계: `actions/checkout@v7` → `subosito/flutter-action@v2` (`channel: stable`, `flutter-version-file: .fvmrc`) → `dart run tool/verify.dart`
  - tag push 에서는 `GITHUB_REF_TYPE` · `GITHUB_REF_NAME` 으로 버전 일치 검사를 tag 모드로 돈다 (`tool/verify.dart:3102-3117`). CI 에서 `--update` 는 동작하지 않는다
  - runner 이미지: `ubuntu-latest` 가 Ubuntu 26.04 로 옮겨 가는 것에 대비해 `ubuntu-26.04` 이미지에서 같은 결과를 미리 확인했다 (`.claude/skills/spike-findings-woody-lints/references/ci-workflow.md:19`)

## Environment Configuration

**Required env vars:**
- 없음 (받는 쪽, 저장소 둘 다). CI 는 GitHub 이 주는 기본 변수만 읽는다

**Secrets location:**
- 없음. workflow 는 secret 을 쓰지 않는다

## Webhooks & Callbacks

**Incoming:**
- 없음

**Outgoing:**
- 없음

---

*Integration audit: 2026-10-17*
