---
last_mapped_commit: 90a2736b8d998c84467faf562a0fec720b797eaf
last_mapped_at: 2026-10-11
---
# Testing Patterns

**Analysis Date:** 2026-10-11

## 요약

이 저장소에는 **자동화된 테스트가 없다.** 테스트 프레임워크, 테스트 파일, 테스트 디렉터리, CI 파이프라인 모두 Not detected. 저장소는 Dart 소스 코드 없이 `lib/analysis_options.yaml` 하나를 배포하는 설정 전용 패키지이며, 검증은 정적 분석(static analysis) 명령을 수동으로 실행하는 방식으로 이루어진다.

## Test Framework

**Runner:**
- Not detected. `pubspec.yaml` 에 `test`, `flutter_test` 의존성이 없고 `dev_dependencies:` 섹션 자체가 없다.
- Config: Not detected (`dart_test.yaml` 없음).

**Assertion Library:**
- Not applicable.

**Run Commands:**

테스트 명령은 없다. 저장소 문서가 언급하는 검증 명령은 다음과 같다.

```bash
flutter pub get                       # 의존성 해석 (README.md 48행)
flutter pub upgrade woody_lints       # 사용하는 프로젝트에서 이 패키지 갱신 (README.md 53행)
dart analyze                          # plugin 진단 포함 분석 결과 확인 (README.md 95행, lib/analysis_options.yaml 55행)
```

- Flutter SDK 는 FVM 으로 고정되어 있다 (`.fvmrc`: `3.41.2`). FVM 을 통해 실행할 때는 `fvm flutter pub get`, `fvm dart analyze` 형태가 된다. 저장소 안에 이 형태를 명시한 스크립트나 문서는 없다.
- plugin 진단 확인에는 `flutter analyze` 가 아니라 `dart analyze` 를 쓴다. `lib/analysis_options.yaml` 55-56행 주석에 따르면 Flutter 3.47.5 의 `flutter analyze` 는 plugin 진단을 표시하지 않았고 3.41.9 는 표시했다 (2026-09-20 실측 기록).

## Test File Organization

**Location:**
- Not detected. `test/`, `example/`, `tool/` 디렉터리가 없다.

**Naming:**
- Not applicable.

**Structure:**

```
woody_lints/
├── lib/
│   └── analysis_options.yaml   # 유일한 배포 산출물 (테스트 대상)
├── analysis_options.yaml       # 저장소 자체 분석용
└── pubspec.yaml
```

## Test Structure

**Suite Organization:**
- Not applicable — 테스트 스위트가 없다.

**Patterns:**
- Setup / Teardown / Assertion 패턴: Not applicable.

## 수동 검증 절차(Manual Verification)

저장소 문서와 주석에서 확인되는 검증 방식은 아래와 같다.

**1. 저장소 자체 분석**
- 루트에서 `dart analyze` 를 실행한다.
- 루트 `analysis_options.yaml` 이 `lib/analysis_options.yaml` 을 `exclude` 하므로 `plugins_in_inner_options` 경고가 나지 않는 것이 정상 상태다.
- 이 exclude 때문에 **저장소 자체 분석은 `lib/analysis_options.yaml` 의 내용을 검증하지 않는다.** 잘못된 규칙 이름이나 YAML 문법 오류는 이 단계에서 드러나지 않는다.

**2. 사용하는 프로젝트에서의 검증**
- 실제 Flutter 프로젝트의 `analysis_options.yaml` 에 `include: package:woody_lints/analysis_options.yaml` 을 넣고 `dart analyze` 를 실행한다 (`README.md` 56-61행).
- 설치 확인은 사용하는 프로젝트의 `pubspec.lock` 에서 `woody_lints` 를 검색하는 방식이다 (`README.md` 63-68행).
- `plugins:` 섹션을 바꾼 뒤에는 IDE 의 Dart Analysis Server 를 재시작해야 반영된다 (`lib/analysis_options.yaml` 54행, `README.md` 95행).

**3. plugin 로드 확인**
- riverpod_lint 는 첫 분석 때 pub.dev 에서 받아지며 `~/.dartServer/.plugin_manager` 캐시에서 해석된다 (`lib/analysis_options.yaml` 52-53행).
- `CHANGELOG.md` 1.3.0 항목은 이전 선언 방식(`analyzer: plugins:`)에서 riverpod_lint 규칙이 한 번도 실행되지 않았다고 기록한다. 설정이 문법상 유효해도 규칙이 실제로 동작하지 않을 수 있으므로, plugin 변경 시에는 riverpod_lint 진단이 실제로 출력되는지 확인한다.

## Mocking

**Framework:** Not applicable.

**Patterns:**
- Not applicable.

**What to Mock / What NOT to Mock:**
- Not applicable.

## Fixtures and Factories

**Test Data:**
- Not detected. 규칙 위반 예시를 담은 fixture Dart 파일이나 example 프로젝트가 없다.

**Location:**
- Not applicable.

## Coverage

**Requirements:** None enforced.

**View Coverage:**
- Not applicable — 측정 대상 코드가 없다.

## Test Types

**Unit Tests:**
- Not used.

**Integration Tests:**
- Not used. 사용하는 프로젝트에서의 수동 `dart analyze` 실행이 이 역할을 대신한다.

**E2E Tests:**
- Not used.

## CI/CD

- CI 설정 Not detected (`.github/workflows/` 없음).
- pre-commit hook, Makefile, 검증 스크립트 Not detected.

## 검증 공백(Verification Gaps)

| 대상 | 현재 상태 | 위험 |
|------|-----------|------|
| `lib/analysis_options.yaml` 의 규칙 이름 유효성 | 자동 검증 없음. 루트 `analysis_options.yaml` 이 이 파일을 exclude 한다 | 오타나 제거된(deprecated/removed) 규칙이 사용하는 프로젝트에서만 드러난다 |
| `plugins:` 의 riverpod_lint 로드 여부 | 자동 검증 없음 | 규칙이 조용히 실행되지 않는 상태가 생길 수 있다 (`CHANGELOG.md` 1.3.0 에 기록된 사례) |
| `README.md` 규칙 목록과 실제 설정의 일치 | 자동 검증 없음 | `README.md` 81행(`require_trailing_commas`), 91-92행(`formatter: trailing_commas`)이 `lib/analysis_options.yaml` 의 주석 처리 상태와 어긋나 있다 |
| `pubspec.yaml` 버전과 `CHANGELOG.md` 항목의 일치 | 자동 검증 없음 | `CHANGELOG.md` 에 `1.3.0`, `1.0.0` 만 있다 |
| `.fvmrc` 와 `.vscode/settings.json` 의 Flutter 버전 일치 | 자동 검증 없음 | 두 파일이 각각 `3.41.2` 를 하드코딩한다 |
| Flutter/Dart 버전별 동작 차이 | 주석에 실측 기록만 있음 (`lib/analysis_options.yaml` 55-56행) | SDK 업그레이드 시 `flutter analyze`/`dart analyze` 의 plugin 진단 표시 여부가 달라질 수 있다 |

## 테스트를 추가할 때의 배치 지침

현재 패턴이 없으므로 아래는 이 저장소 구조에 맞는 배치 기준이다.

- 규칙 위반 예시 fixture: `example/` 아래에 최소 Flutter 프로젝트를 두고 그 `analysis_options.yaml` 에서 `include: package:woody_lints/analysis_options.yaml` 을 쓴다. `example/` 의 옵션 파일이 루트가 아닌 하위 옵션으로 취급되는 점(`plugins_in_inner_options`)을 고려한다.
- 검증 스크립트: `tool/` 아래에 둔다.
- 테스트 의존성은 `pubspec.yaml` 의 `dev_dependencies:` 에 추가한다. `flutter_lints` 는 `dependencies:` 에 그대로 둔다 (`pubspec.yaml` 13-15행 주석).
- 생성 파일(`*.freezed.dart`, `*.g.dart`)은 `lib/analysis_options.yaml` 의 `exclude` 대상이므로 fixture 로 쓰지 않는다.

## Common Patterns

**Async Testing:**
- Not applicable.

**Error Testing:**
- Not applicable.

---

*Testing analysis: 2026-10-11*
