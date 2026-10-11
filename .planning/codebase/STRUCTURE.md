---
last_mapped_commit: 90a2736b8d998c84467faf562a0fec720b797eaf
last_mapped_at: 2026-10-11
---
# Codebase Structure

**Analysis Date:** 2026-10-11

## Directory Layout

```
woody_lints/
├── lib/
│   └── analysis_options.yaml   # 배포 산출물: 사용하는 프로젝트가 include 하는 공유 lint 설정
├── .vscode/
│   └── settings.json           # VS Code 의 Flutter SDK 경로 (.fvm/versions/3.41.2)
├── .planning/
│   └── codebase/               # GSD 코드베이스 분석 문서
├── analysis_options.yaml       # 이 저장소 자체 분석 전용 설정 (배포되지 않음)
├── pubspec.yaml                # 패키지 매니페스트 (name, version, sdk, dependencies)
├── pubspec.lock                # 로컬 생성, Git 미추적
├── CHANGELOG.md                # 버전별 변경 이력
├── README.md                   # 설치 절차와 포함 규칙 목록
├── .fvmrc                      # FVM Flutter 버전 고정 (3.41.2)
├── .gitignore                  # .dart_tool/, pubspec.lock, .DS_Store, .fvm/ 제외
├── .dart_tool/                 # pub 생성물, Git 미추적
└── .fvm/                       # FVM SDK 캐시, Git 미추적
```

Git 이 추적하는 파일은 8개, 합계 약 210줄이다: `.fvmrc`, `.gitignore`, `.vscode/settings.json`, `CHANGELOG.md`, `README.md`, `analysis_options.yaml`, `lib/analysis_options.yaml`, `pubspec.yaml`.

`.dart` 소스 파일, `test/`, `example/`, `bin/`, `tool/`, CI 설정(`.github/`)은 존재하지 않는다.

## Directory Purposes

**`lib/`:**
- Purpose: 패키지의 공개 표면(public surface). `package:woody_lints/` URI 가 이 디렉터리로 매핑된다
- Contains: YAML 설정 파일만. Dart 코드 없음
- Key files: `lib/analysis_options.yaml`

**`.vscode/`:**
- Purpose: 저장소 기여자용 편집기 설정
- Contains: `dart.flutterSdkPath` 한 항목
- Key files: `.vscode/settings.json`

**`.planning/codebase/`:**
- Purpose: GSD 명령이 읽는 코드베이스 분석 문서
- Contains: `ARCHITECTURE.md`, `STRUCTURE.md` 등 UPPERCASE.md 문서
- Key files: `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`

## Key File Locations

**Entry Points:**
- `lib/analysis_options.yaml`: 사용하는 프로젝트가 `include: package:woody_lints/analysis_options.yaml` 로 참조하는 유일한 진입점
- `pubspec.yaml`: pub 이 패키지를 해석하는 지점

**Configuration:**
- `lib/analysis_options.yaml`: 공유 lint 규칙(`linter.rules`), analyzer 설정(`analyzer.errors`, `analyzer.exclude`), analyzer plugin(`plugins:`)
- `analysis_options.yaml`: 저장소 자체 분석 설정 — `lib/analysis_options.yaml` 제외
- `pubspec.yaml`: 버전 `1.3.0`, `publish_to: 'none'`, `sdk: ^3.10.4`, `flutter_lints: ^6.0.0`
- `.fvmrc`: Flutter `3.41.2`
- `.vscode/settings.json`: `.fvm/versions/3.41.2`
- `.gitignore`: `.dart_tool/`, `pubspec.lock`, `.DS_Store`, `.fvm/`

**Core Logic:**
- `lib/analysis_options.yaml:13`: 기반 규칙 include (`package:flutter_lints/flutter.yaml`)
- `lib/analysis_options.yaml:20-40`: 추가 lint 규칙 — 성능 3개, 가독성 및 스타일 4개 활성(2개 주석 처리), 버그 방지 4개
- `lib/analysis_options.yaml:42-47`: analyzer 오류 재정의와 생성 코드 제외
- `lib/analysis_options.yaml:57-58`: `riverpod_lint: ^3.1.3` plugin 선언

**Documentation:**
- `README.md:23-68`: 사용법 (설치 4단계)
- `README.md:70-95`: 포함된 규칙 목록
- `CHANGELOG.md`: 릴리스 노트 (최상단 = 최신 버전)

**Testing:**
- Not detected. 테스트 파일과 테스트 설정이 없다.

## Naming Conventions

**Files:**
- 분석 설정 파일은 Dart 도구가 요구하는 고정 이름 `analysis_options.yaml` 을 쓴다: `lib/analysis_options.yaml`, `analysis_options.yaml`
- 패키지 표준 파일은 pub 관례 이름을 쓴다: `pubspec.yaml`, `README.md`, `CHANGELOG.md`
- YAML 확장자는 `.yaml` 을 쓴다 (`.yml` 아님)

**Directories:**
- pub 패키지 표준 레이아웃을 따른다: 공개 파일은 `lib/`
- 도구 디렉터리는 점(dot) 접두사: `.vscode/`, `.fvm/`, `.dart_tool/`, `.planning/`

**Package:**
- 패키지명은 `snake_case`: `woody_lints` (`pubspec.yaml:1`)

**YAML 내부:**
- lint 규칙명은 Dart linter 공식 이름 그대로 `snake_case`: `prefer_const_constructors`
- 규칙 한 줄 형식: `- 규칙명 # 한국어 설명` (`lib/analysis_options.yaml:23`)
- 규칙 그룹 머리 주석: `# 성능`, `# 가독성 및 스타일`, `# 버그 방지`
- 비활성 규칙은 줄을 지우지 않고 `# - 규칙명 # 설명` 으로 주석 처리 (`lib/analysis_options.yaml:31`, `:34`)
- 들여쓰기 2칸

**CHANGELOG:**
- 버전 머리말 `## X.Y.Z`, 항목은 `- ` 불릿, 본문은 한국어, 규칙명·키는 백틱으로 감싼 영어

## Where to Add New Code

**새 lint 규칙 (New lint rule):**
- Primary code: `lib/analysis_options.yaml` 의 `linter.rules` — 목적에 맞는 그룹 주석(`# 성능` / `# 가독성 및 스타일` / `# 버그 방지`) 아래에 `- 규칙명 # 한국어 설명` 형식으로 추가
- 문서: `README.md` 의 "포함된 규칙 목록" 해당 분류에 `- 규칙명: 설명` 추가
- 릴리스: `pubspec.yaml:3` 의 `version` 을 올리고 `CHANGELOG.md` 최상단에 `## X.Y.Z` 항목 추가
- Tests: 테스트 인프라 없음. 사용하는 Flutter 프로젝트에서 `dart analyze` 를 실행해 확인

**규칙 비활성화 (Disable a rule):**
- `lib/analysis_options.yaml` 에서 해당 줄을 주석 처리하고, `README.md` 규칙 목록에서도 제거

**analyzer 오류 심각도 변경 / 진단 무시:**
- `lib/analysis_options.yaml` 의 `analyzer.errors` (`:43-44`) 에 `진단코드: ignore|info|warning|error` 추가

**생성 코드 제외 패턴 추가:**
- `lib/analysis_options.yaml` 의 `analyzer.exclude` (`:45-47`) 에 작은따옴표로 감싼 glob 추가 — 예: `'**/*.gr.dart'`

**새 analyzer plugin:**
- `lib/analysis_options.yaml` 의 최상위 `plugins:` (`:57-58`) 에 `패키지명: ^버전` 추가. `pubspec.yaml` 에는 추가하지 않는다 (plugin 은 Analysis Server 캐시에서 따로 해석된다)
- `README.md` 의 "analyzer plugin" 항목에 설명 추가

**새 기반 lint 패키지 (include 대상 변경·추가):**
- `lib/analysis_options.yaml:13` 의 `include:` 수정
- 해당 패키지를 `pubspec.yaml` 의 `dependencies` 에 추가 (`dev_dependencies` 아님)

**추가 공유 설정 변형 (예: 순수 Dart 용, strict 용):**
- `lib/` 바로 아래에 새 YAML 파일로 추가 — 예: `lib/strict.yaml` → 사용하는 쪽에서 `include: package:woody_lints/strict.yaml`
- 기존 `lib/analysis_options.yaml` 의 경로와 이름은 바꾸지 않는다

**저장소 자체 분석 설정:**
- `analysis_options.yaml` (루트). 공유할 규칙은 여기에 넣지 않는다

**Flutter SDK 버전 변경:**
- `.fvmrc` 의 `flutter` 값과 `.vscode/settings.json` 의 `dart.flutterSdkPath` 를 같은 버전으로 함께 수정

**Utilities / Dart 코드:**
- 해당 없음. 이 패키지는 Dart 코드를 담지 않는다. custom lint 규칙 구현이 필요해지면 `lib/src/` 와 `lib/woody_lints.dart` 를 새로 만드는 구조 변경이므로 별도 설계가 필요하다

## Special Directories

**`.dart_tool/`:**
- Purpose: pub 이 만드는 패키지 해석 결과 (`package_config.json`, `package_graph.json`, `version`)
- Generated: Yes
- Committed: No (`.gitignore:3`)

**`.fvm/`:**
- Purpose: FVM 의 Flutter SDK 캐시와 심볼릭 링크 (`flutter_sdk`, `versions/`, `fvm_config.json`, `release`, `version`)
- Generated: Yes
- Committed: No (`.gitignore:12`)

**`pubspec.lock`:**
- Purpose: 로컬 의존성 잠금 (flutter_lints 6.0.0, lints 6.1.0)
- Generated: Yes
- Committed: No (`.gitignore:7`) — 라이브러리 패키지 관례

**`.planning/`:**
- Purpose: GSD 계획·분석 문서
- Generated: Yes (GSD 명령이 작성)
- Committed: Git 추적 대상에 아직 없음

**`.vscode/`:**
- Purpose: 편집기 설정
- Generated: No
- Committed: Yes

---

*Structure analysis: 2026-10-11*
