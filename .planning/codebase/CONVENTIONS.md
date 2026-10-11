---
last_mapped_commit: 90a2736b8d998c84467faf562a0fec720b797eaf
last_mapped_at: 2026-10-11
---
# Coding Conventions

**Analysis Date:** 2026-10-11

## 저장소 성격(Repository Nature)

이 저장소는 Dart 소스 코드가 없는 **설정 전용 패키지(config-only package)** 다. 추적되는 파일은 8개뿐이다.

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

`lib/` 아래에 `.dart` 파일은 없다. 따라서 아래 규칙은 두 종류로 나뉜다.

1. **이 저장소를 수정할 때 따르는 규칙** — YAML/Markdown 작성 방식.
2. **이 패키지가 사용하는 프로젝트에 강제하는 Dart 규칙** — `lib/analysis_options.yaml` 의 내용.

## Naming Patterns

**Files:**
- 배포용 설정 파일 이름은 `lib/analysis_options.yaml` 로 고정한다. 사용하는 프로젝트의 `include:` 경로(`package:woody_lints/analysis_options.yaml`)가 이 이름에 의존하므로 이름을 바꾸거나 옮기지 않는다.
- 문서 파일은 대문자 이름을 쓴다: `README.md`, `CHANGELOG.md`.

**Functions / Variables / Types:**
- Not applicable — 이 저장소에는 Dart 코드가 없다.

**패키지 이름:**
- `pubspec.yaml` 의 `name: woody_lints` 는 snake_case 다. `include:` 경로와 사용하는 프로젝트의 `dev_dependencies` 키가 이 이름을 쓴다.

**린트 규칙 이름:**
- `linter: rules:` 항목은 Dart 공식 규칙 이름(snake_case)을 그대로 쓴다. 예: `prefer_const_constructors`.

## Code Style

**Formatting:**
- YAML 은 2칸 들여쓰기를 쓴다 (`lib/analysis_options.yaml`, `pubspec.yaml`).
- 자동 포맷터(formatter) 설정은 활성화되어 있지 않다. `lib/analysis_options.yaml` 15-16행의 `formatter: trailing_commas: preserve` 는 주석 처리된 상태다.
- YAML/Markdown 용 포맷터나 린터(예: prettier, yamllint, markdownlint) 설정 파일은 Not detected.

**Linting:**
- 기반 규칙 세트: `include: package:flutter_lints/flutter.yaml` (`flutter_lints ^6.0.0`, lock 기준 `6.0.0`, 전이 의존 `lints 6.1.0`).
- 추가로 켜는 규칙은 `lib/analysis_options.yaml` 의 `linter: rules:` 에 **목록 형식(list form)** 으로 적는다.

현재 활성 규칙 (`lib/analysis_options.yaml` 20-40행):

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

주석 처리되어 **비활성** 인 항목:
- `require_trailing_commas` (`lib/analysis_options.yaml` 31행)
- `public_member_api_docs` (`lib/analysis_options.yaml` 34행)
- `formatter: trailing_commas: preserve` (`lib/analysis_options.yaml` 15-16행)

**Analyzer 설정** (`lib/analysis_options.yaml` 42-47행):
- `errors: invalid_annotation_target: ignore` — freezed/json_serializable 어노테이션 사용을 전제로 한다.
- `exclude:` 에 생성 코드 `'**/*.freezed.dart'`, `'**/*.g.dart'` 를 둔다.

**Analyzer plugin** (`lib/analysis_options.yaml` 57-58행):
- `riverpod_lint: ^3.1.3` 을 **최상위 `plugins:` 키** 로 선언한다 (Dart 3.10+ analysis_server_plugin 방식).
- `analyzer: plugins:` 아래에 선언하지 않는다. riverpod_lint 3.x 에서는 그 방식이 아무것도 로드하지 않는다 (`lib/analysis_options.yaml` 49-56행 주석, `CHANGELOG.md` 1.3.0 항목).

## 규칙 추가/변경 방법 (Prescriptive)

`lib/analysis_options.yaml` 에 규칙을 추가할 때는 아래 형식을 그대로 따른다.

```yaml
linter:
  rules:
    # 성능
    - prefer_const_constructors # 위젯 재사용을 극대화하여 성능 향상

    # 가독성 및 스타일
    - prefer_single_quotes # 홑따옴표('') 사용 통일

    # 버그 방지
    - avoid_print # 실 서비스 앱에서 불필요한 로그 노출 방지

```

- 규칙은 세 그룹(`# 성능`, `# 가독성 및 스타일`, `# 버그 방지`) 중 하나 아래에 넣는다.
- 각 규칙 줄 끝에 한국어 인라인 주석으로 의도를 한 줄로 적는다.
- 규칙을 끌 때는 줄을 삭제하지 않고 `# - rule_name # 설명` 형태로 주석 처리한다 (31행, 34행의 방식).
- 목록 형식(`- rule`)을 유지한다. 맵 형식(`rule: true`)과 섞지 않는다.

규칙을 바꾸면 아래 파일을 함께 수정한다.

1. `lib/analysis_options.yaml` — 규칙 본체.
2. `README.md` 의 `## 포함된 규칙 목록` — 같은 분류 아래에 `규칙명: 설명` 형식으로 반영.
3. `pubspec.yaml` 의 `version:` — 버전 올림.
4. `CHANGELOG.md` — 맨 위에 `## x.y.z` 항목 추가.

## 문서 동기화 상태 (주의)

`README.md` 와 `lib/analysis_options.yaml` 이 일치하지 않는 지점이 있다. 규칙 목록의 기준(source of truth)은 `lib/analysis_options.yaml` 이다.

- `README.md` 81행은 `require_trailing_commas` 를 포함된 규칙으로 적지만, `lib/analysis_options.yaml` 31행에서는 주석 처리되어 있다.
- `README.md` 91-92행은 `formatter: trailing_commas` 를 포함된 설정으로 적지만, `lib/analysis_options.yaml` 15-16행에서는 주석 처리되어 있다.
- `README.md` 는 `analyzer:` 의 `errors`/`exclude` 설정(`invalid_annotation_target`, `*.freezed.dart`, `*.g.dart`)을 언급하지 않는다.
- `CHANGELOG.md` 에는 `1.3.0` 과 `1.0.0` 항목만 있다. git 이력에 있는 중간 버전(예: 커밋 `dbcd20b` 의 1.2.5)은 기록되어 있지 않다.

## Import Organization

**Order:**
- Not applicable — Dart 소스가 없다.

**설정 include 체인:**
1. 사용하는 프로젝트의 `analysis_options.yaml` → `include: package:woody_lints/analysis_options.yaml`
2. `lib/analysis_options.yaml` → `include: package:flutter_lints/flutter.yaml`
3. `flutter_lints` → `package:lints` 의 recommended 세트

**Path Aliases:**
- Not applicable.

## 의존성 선언 규칙

- `flutter_lints` 는 `pubspec.yaml` 의 `dependencies:` 에 둔다. `dev_dependencies:` 로 옮기지 않는다. `dev_dependencies` 는 사용하는 프로젝트의 의존성 그래프에 포함되지 않아 `include: package:flutter_lints/flutter.yaml` 해석이 깨진다 (`pubspec.yaml` 13-15행 주석).
- `riverpod_lint` 는 `pubspec.yaml` 에 넣지 않는다. `lib/analysis_options.yaml` 의 최상위 `plugins:` 에서만 버전을 지정하며, Dart Analysis Server 의 plugin 캐시(`~/.dartServer/.plugin_manager`)에서 해석된다.
- `publish_to: 'none'` 을 유지한다. 이 패키지는 pub.dev 에 올리지 않고 git 의존성으로만 배포한다 (`ref: main`).
- SDK 제약은 `environment: sdk: ^3.10.4` 다. 최상위 `plugins:` 방식이 Dart 3.10+ 를 요구하므로 이보다 낮추지 않는다.
- `pubspec.lock` 은 `.gitignore` 대상이다. 커밋하지 않는다.

## Error Handling

**Patterns:**
- Not applicable — 실행 코드가 없다.
- 설정 수준에서는 `analyzer: errors:` 로 진단 심각도를 조정한다. 현재 조정 항목은 `invalid_annotation_target: ignore` 하나다.
- 저장소 자체 분석에서 나는 `plugins_in_inner_options` 경고는 루트 `analysis_options.yaml` 에서 `lib/analysis_options.yaml` 을 `exclude` 하는 방식으로 처리한다. 루트 파일에 `plugins:` 를 추가하거나 `lib/analysis_options.yaml` 의 `plugins:` 를 제거하는 방식으로 해결하지 않는다.

## Logging

**Framework:** Not applicable.

**사용하는 프로젝트에 강제되는 규칙:**
- `avoid_print` 가 켜져 있으므로 이 패키지를 쓰는 프로젝트에서는 `print` 대신 로거(logger) 또는 `debugPrint` 를 쓴다.

## Comments

**When to Comment:**
- YAML 주석은 한국어로 쓴다. 템플릿에서 온 영어 주석(`lib/analysis_options.yaml` 1-12행, 60-64행)은 그대로 둔다.
- 설정의 **이유(why)** 를 적는다. "무엇을 하는가"가 아니라 "왜 이 위치/방식인가"를 설명한다. 예: `pubspec.yaml` 13-15행(왜 `dependencies` 인가), `analysis_options.yaml` 1-6행(왜 exclude 하는가), `lib/analysis_options.yaml` 49-56행(왜 최상위 `plugins:` 인가).
- 실측으로 확인한 동작은 버전과 날짜를 함께 적는다. 예: `lib/analysis_options.yaml` 55-56행 "Flutter 3.47.5 의 `flutter analyze` 는 plugin 진단을 표시하지 않았다 (3.41.9 는 표시, 2026-09-20 실측)".
- 한국어 문장에서 영어 식별자 뒤 조사는 한 칸 띄어 쓴다. 예: "riverpod_lint 를", "`plugins:` 가".

**JSDoc/TSDoc (Dart doc comments):**
- 사용하는 프로젝트에는 `slash_for_doc_comments` 로 `///` 형식을 강제한다.
- `public_member_api_docs` 는 비활성이므로 공개 API 문서화는 린트로 강제되지 않는다.

## Function Design

Not applicable — 이 저장소에는 함수가 없다.

## Module Design

**Exports:**
- 유일한 공개 산출물은 `lib/analysis_options.yaml` 이다. `lib/` 에 Dart 라이브러리 파일(예: `lib/woody_lints.dart`)은 없다.

**Barrel Files:**
- Not applicable.

## 버전 및 변경 이력 규칙

- `pubspec.yaml` 의 `version:` 은 `major.minor.patch` 형식이다 (현재 `1.3.0`).
- `CHANGELOG.md` 는 최신 버전이 위로 오며, `## x.y.z` 제목 아래 한국어 불릿으로 쓴다. 하위 불릿으로 원인과 영향을 적는다 (`CHANGELOG.md` 3-5행 형식).
- 사용하는 프로젝트에 영향이 없는 변경은 "사용하는 프로젝트에는 영향 없음" 이라고 명시한다 (`CHANGELOG.md` 7행).

## Git 커밋 규칙

- 최신 커밋은 Conventional Commits 형식이다: prefix 는 영어, 제목은 한국어, 버전은 괄호로 덧붙인다.
  - `90a2736 feat: riverpod_lint 를 최상위 plugins: 방식으로 전환 (1.3.0)`
  - `dbcd20b chore: bump version to 1.2.5 and update analysis options.`
- 이전 커밋은 prefix 없는 자유 형식이다 (예: `a97fd20 fvm 적용`, `9451f6b slash_for_doc_comments 추가`).
- 새 커밋은 Conventional Commits 형식(`feat:`, `fix:`, `chore:`, `docs:`)으로 쓰고 제목과 본문은 한국어로 쓴다.

## 도구 버전 고정

- Flutter 버전은 FVM 으로 고정한다: `.fvmrc` 의 `"flutter": "3.41.2"`.
- `.vscode/settings.json` 의 `dart.flutterSdkPath` 는 `.fvmrc` 와 같은 버전(`.fvm/versions/3.41.2`)을 가리킨다. `.fvmrc` 를 바꾸면 이 파일도 함께 바꾼다.
- `.fvm/` 디렉터리는 `.gitignore` 대상이다.

## 프로젝트 스킬(Project Skills)

- `.claude/skills/`, `.agents/skills/` 디렉터리는 Not detected.

---

*Convention analysis: 2026-10-11*
