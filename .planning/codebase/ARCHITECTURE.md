---
last_mapped_commit: 90a2736b8d998c84467faf562a0fec720b797eaf
last_mapped_at: 2026-10-11
---
<!-- refreshed: 2026-10-11 -->

# Architecture

**Analysis Date:** 2026-10-11

## System Overview

`woody_lints` 는 Dart 소스 코드가 한 줄도 없는 **설정 전용 패키지(configuration-only package)** 다. 배포 산출물은 `lib/analysis_options.yaml` 단 하나이며, 사용하는 Flutter 프로젝트가 이 파일을 `include:` 로 끌어다 쓴다.

```text
┌─────────────────────────────────────────────────────────────┐
│          사용하는 Flutter 프로젝트 (Consumer project)         │
├──────────────────────────────┬──────────────────────────────┤
│  pubspec.yaml                │  analysis_options.yaml       │
│  dev_dependencies:           │  include: package:           │
│    woody_lints: (git, main)  │   woody_lints/               │
│                              │   analysis_options.yaml      │
└──────────────┬───────────────┴──────────────┬───────────────┘
               │ pub get (git 의존성)           │ include 해석
               ▼                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  woody_lints (이 저장소)                      │
├──────────────────────────────┬──────────────────────────────┤
│  패키지 매니페스트             │  공유 분석 설정 (배포 산출물)   │
│  `pubspec.yaml`              │  `lib/analysis_options.yaml` │
└──────────────┬───────────────┴───────┬──────────────┬───────┘
               │ dependencies          │ include:     │ plugins:
               ▼                       ▼              ▼
┌──────────────────────────────────────────┐ ┌────────────────┐
│  flutter_lints ^6.0.0 (→ lints 6.1.0)    │ │ riverpod_lint  │
│  `package:flutter_lints/flutter.yaml`    │ │ ^3.1.3         │
│  pub 의존성 그래프로 전달                  │ │ Analysis Server│
│                                          │ │ plugin 캐시     │
└──────────────────────────────────────────┘ └────────────────┘

별도 경로 (이 저장소 자체 분석 전용, 사용하는 프로젝트에 전달되지 않음):
┌─────────────────────────────────────────────────────────────┐
│  `analysis_options.yaml` (루트)                              │
│  analyzer.exclude: lib/analysis_options.yaml                 │
└─────────────────────────────────────────────────────────────┘
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

**Overall:** 공유 lint 설정 패키지(Shared lint configuration package) — `flutter_lints` / `lints` 와 동일한 `include:` 체인 방식의 계층형 설정(layered configuration).

**Key Characteristics:**
- 실행 코드 없음. `lib/` 에는 `.dart` 파일이 없고 YAML 하나만 존재한다.
- 계층 합성(composition by include): `lints` (core/recommended) → `flutter_lints/flutter.yaml` → `lib/analysis_options.yaml` → 사용하는 프로젝트의 `analysis_options.yaml`. 아래 계층이 위 계층을 덮어쓴다.
- pub.dev 미배포. `pubspec.yaml` 의 `publish_to: 'none'` 로 막혀 있고, Git 의존성(`ref: main`)으로만 배포된다. `main` 브랜치에 push 하는 순간이 곧 릴리스다.
- 두 개의 서로 다른 해석 경로(resolution path)가 공존한다: `include:` 는 pub 의존성 그래프로, `plugins:` 는 Dart Analysis Server 의 plugin 캐시(`~/.dartServer/.plugin_manager`)로 해석된다.

## Layers

**기반 규칙 계층 (Base rule layer):**
- Purpose: Flutter 공식 권장 lint 세트 제공
- Location: 외부 패키지 `package:flutter_lints/flutter.yaml` (`pubspec.lock` 기준 flutter_lints 6.0.0, lints 6.1.0)
- Contains: core / recommended / flutter lint 규칙
- Depends on: `lints`
- Used by: `lib/analysis_options.yaml:13`

**공유 설정 계층 (Shared configuration layer):**
- Purpose: 기반 규칙 위에 추가 규칙·analyzer 설정·plugin 을 얹는다
- Location: `lib/analysis_options.yaml`
- Contains: `include:`, `linter.rules`, `analyzer.errors`, `analyzer.exclude`, 최상위 `plugins:`
- Depends on: `flutter_lints` (`pubspec.yaml:16-17`), `riverpod_lint ^3.1.3` (`lib/analysis_options.yaml:57-58`)
- Used by: 사용하는 Flutter 프로젝트의 `analysis_options.yaml`

**패키지 메타데이터 계층 (Package metadata layer):**
- Purpose: pub 이 패키지를 해석하고 의존성을 전달하도록 한다
- Location: `pubspec.yaml`
- Contains: `name`, `version`, `environment.sdk`, `dependencies`
- Depends on: Dart SDK `^3.10.4`
- Used by: `flutter pub get` / `dart pub get`

**저장소 로컬 계층 (Repository-local layer):**
- Purpose: 이 저장소를 개발할 때만 쓰이는 설정. 사용하는 프로젝트에는 전달되지 않는다
- Location: `analysis_options.yaml`, `.fvmrc`, `.vscode/settings.json`, `.gitignore`
- Contains: 자체 분석 제외 규칙, Flutter SDK 버전 고정, 편집기 SDK 경로
- Depends on: FVM
- Used by: 저장소 기여자와 IDE

## Data Flow

### Primary Request Path (사용하는 프로젝트의 정적 분석)

1. 사용하는 프로젝트가 `dev_dependencies` 에 Git 의존성으로 `woody_lints` 를 선언한다 (`README.md:36-43`)
2. `flutter pub get` 이 `pubspec.yaml` 을 읽고 `flutter_lints ^6.0.0` 을 전이 의존성으로 함께 해석한다 (`pubspec.yaml:16-17`)
3. 사용하는 프로젝트의 `analysis_options.yaml` 이 `include: package:woody_lints/analysis_options.yaml` 로 공유 설정을 가리킨다 (`README.md:59-60`)
4. analyzer 가 `package:woody_lints/` 를 이 저장소의 `lib/` 로 매핑해 `lib/analysis_options.yaml` 을 읽는다
5. 그 파일의 `include: package:flutter_lints/flutter.yaml` 을 따라 기반 규칙을 병합한다 (`lib/analysis_options.yaml:13`)
6. `linter.rules` 의 추가 규칙 11개를 적용한다 (`lib/analysis_options.yaml:20-40`)
7. `analyzer.errors` / `analyzer.exclude` 를 적용한다 — `invalid_annotation_target` 무시, `**/*.freezed.dart` 와 `**/*.g.dart` 제외 (`lib/analysis_options.yaml:42-47`)
8. 진단 결과가 IDE 와 `dart analyze` 로 출력된다

### Analyzer Plugin 로드 경로

1. Dart Analysis Server 가 최상위 `plugins:` 키를 읽는다 (`lib/analysis_options.yaml:57-58`)
2. `riverpod_lint ^3.1.3` 을 프로젝트의 `pubspec.lock` 과 무관하게 pub.dev 에서 받아 plugin 캐시(`~/.dartServer/.plugin_manager`)에 해석한다
3. plugin 진단이 일반 lint 진단과 함께 보고된다
4. `plugins:` 섹션을 바꾼 뒤에는 Dart Analysis Server 를 재시작해야 반영된다 (`lib/analysis_options.yaml:54`)

### 저장소 자체 분석 경로

1. 이 저장소 루트에서 analyzer 가 `analysis_options.yaml` 을 읽는다
2. `analyzer.exclude` 가 `lib/analysis_options.yaml` 을 분석 대상에서 뺀다 (`analysis_options.yaml:7-9`)
3. 그 결과 `lib/analysis_options.yaml` 의 최상위 `plugins:` 가 inner 옵션 파일로 취급되어 나는 `plugins_in_inner_options` 경고가 사라진다

**State Management:**
- 런타임 상태 없음. 모든 동작은 YAML 선언으로 결정되고, 버전 상태는 `pubspec.yaml:3` 의 `version` 필드와 Git `main` 브랜치의 HEAD 가 전부다.

## Key Abstractions

**공유 analysis options 파일:**
- Purpose: 여러 Flutter 프로젝트가 재사용하는 lint 정책 단일 진실 원천(single source of truth)
- Examples: `lib/analysis_options.yaml`
- Pattern: `include:` 체인. 패키지 URI `package:woody_lints/analysis_options.yaml` 는 반드시 `lib/` 바로 아래 파일로 해석되므로 파일 위치와 이름이 곧 공개 API 다.

**규칙 그룹 (Rule group):**
- Purpose: `linter.rules` 안에서 규칙을 목적별로 묶는다
- Examples: `lib/analysis_options.yaml:22` (`# 성능`), `:27` (`# 가독성 및 스타일`), `:36` (`# 버그 방지`)
- Pattern: 한국어 그룹 주석 + 규칙마다 한 줄 한국어 설명 주석. 비활성 규칙은 삭제하지 않고 주석 처리로 남긴다 (`:31`, `:34`).

**전이 의존성으로서의 기반 lint (Transitive base lint dependency):**
- Purpose: 사용하는 프로젝트가 `flutter_lints` 를 직접 선언하지 않아도 `include:` 가 해석되게 한다
- Examples: `pubspec.yaml:13-17`
- Pattern: `include:` 대상 패키지는 `dependencies` 에 둔다. `dev_dependencies` 는 사용하는 쪽 의존성 그래프에 포함되지 않는다.

**Analyzer plugin 선언:**
- Purpose: lint 규칙 목록으로 표현할 수 없는 패키지 고유 규칙(Riverpod) 추가
- Examples: `lib/analysis_options.yaml:57-58`
- Pattern: 최상위 `plugins:` 맵에 `패키지명: 버전 제약`. `analyzer: plugins:` 리스트 방식은 쓰지 않는다.

## Entry Points

**공유 설정 include 지점:**
- Location: `lib/analysis_options.yaml`
- Triggers: 사용하는 프로젝트의 `include: package:woody_lints/analysis_options.yaml`
- Responsibilities: 기반 규칙 include, 추가 규칙 활성화, analyzer 오류·제외 설정, plugin 선언

**패키지 해석 지점:**
- Location: `pubspec.yaml`
- Triggers: 사용하는 프로젝트의 `flutter pub get` / `flutter pub upgrade woody_lints`
- Responsibilities: 패키지 식별, SDK 제약 검사, `flutter_lints` 전달

**자체 분석 지점:**
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

**What happens:** `analyzer:` 아래 `plugins: - riverpod_lint` 형태로 plugin 을 선언한다.
**Why it's wrong:** riverpod_lint 3.x 는 이 방식에서 아무것도 로드하지 않아 규칙이 실행되지 않고, Dart 3.13 부터 `included_file_warning` (legacy plugin deprecated) 경고가 난다 (`CHANGELOG.md:3-5`).
**Do this instead:** 최상위 `plugins:` 맵에 버전 제약과 함께 선언한다 — `lib/analysis_options.yaml:57-58`.

### `include:` 대상 패키지를 `dev_dependencies` 에 선언

**What happens:** `lib/analysis_options.yaml` 이 include 하는 패키지를 `pubspec.yaml` 의 `dev_dependencies` 에 둔다.
**Why it's wrong:** `dev_dependencies` 는 사용하는 프로젝트의 의존성 그래프에 포함되지 않아, 그 프로젝트가 해당 패키지를 직접 선언하지 않으면 `include:` 해석이 실패한다 (`CHANGELOG.md:6`).
**Do this instead:** `dependencies` 에 둔다 — `pubspec.yaml:13-17`.

### 루트 `analysis_options.yaml` 에 공유 규칙 추가

**What happens:** 사용하는 프로젝트에 전달하려는 규칙을 루트 `analysis_options.yaml` 에 적는다.
**Why it's wrong:** 루트 파일은 이 저장소 자체 분석에만 쓰이고 패키지 URI 로 노출되지 않는다 (`analysis_options.yaml:1-2`). 규칙이 어느 프로젝트에도 적용되지 않는다.
**Do this instead:** `lib/analysis_options.yaml` 의 `linter.rules` 에 해당 그룹 주석 아래 추가한다.

### 문서와 설정의 불일치

**What happens:** `README.md` 의 "포함된 규칙 목록" 이 `require_trailing_commas` (`README.md:81`) 와 `formatter: trailing_commas` (`README.md:92`) 를 포함된 것으로 적지만, `lib/analysis_options.yaml:31` 과 `:15-16` 에서는 둘 다 주석 처리되어 비활성이다.
**Why it's wrong:** 사용자가 적용되지 않는 규칙을 적용된다고 믿게 된다.
**Do this instead:** `lib/analysis_options.yaml` 의 규칙을 켜거나 끌 때 같은 변경에서 `README.md` 의 규칙 목록과 `CHANGELOG.md` 를 함께 고친다.

## Error Handling

**Strategy:** 실행 코드가 없으므로 런타임 오류 처리 없음. 오류는 analyzer 진단과 pub 해석 실패로만 나타난다.

**Patterns:**
- 진단 심각도 재정의: `analyzer.errors` 에서 `invalid_annotation_target: ignore` (`lib/analysis_options.yaml:43-44`) — freezed / json_serializable 사용 시의 오탐 억제
- 생성 코드 제외: `analyzer.exclude` 에 `**/*.freezed.dart`, `**/*.g.dart` (`lib/analysis_options.yaml:45-47`)
- 자체 분석 경고 억제: 루트 `analysis_options.yaml:7-9` 의 exclude

## Cross-Cutting Concerns

**Logging:** 해당 없음.
**Validation:** 자동 검증 없음. 테스트 디렉터리와 CI 설정이 없다. 변경 검증은 사용하는 프로젝트에서 `dart analyze` 를 직접 실행해 수행한다.
**Authentication:** 해당 없음. 공개 Git 저장소 URL 로 가져온다 (`pubspec.yaml:8`).
**Versioning:** `pubspec.yaml:3` 의 `version` 과 `CHANGELOG.md` 최상단 항목을 같은 값으로 맞춘다 (둘 다 1.3.0).
**Documentation language:** YAML 주석, `README.md`, `CHANGELOG.md` 는 한국어로 쓰고 규칙명·키는 영어 원문을 그대로 쓴다.

---

*Architecture analysis: 2026-10-11*
