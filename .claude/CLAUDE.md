<!-- GSD:project-start source:PROJECT.md -->

## Project

**woody_lints**

`woody_lints` 는 Flutter 프로젝트의 `analysis_options.yaml` 에서 `include:` 한 줄로 끌어다 쓰는 설정 전용 패키지(configuration-only package)다. Dart 코드는 없고 `lib/` 의 YAML 이 배포 산출물이며, 작성자 본인의 Flutter 프로젝트들이 Git 의존성으로 가져다 쓴다. 2.0.0 (tag `v2.0.0`, 2026-10-16 `main` 병합)부터는 조각 셋(`base.yaml` · `riverpod.yaml` · `codegen.yaml`), 묶음 `recommended.yaml`, 옛 주소 별칭 `analysis_options.yaml` 의 다섯 파일이다 (Phase 3 · Phase 6).

v2.0 마일스톤(2026-10-11 ~ 10-17)에서 "잘 모르던 시절에 만든" 이 패키지를 지금 기준으로 다시 다듬어 2.0.0 으로 릴리스했다.

**Core Value:** 사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.

v2.0 뒤 다시 봐도 그대로다 — 검증 명령이 문서와 설정의 일치를 지키게 되었고, 다음 일도 이 가치를 지키는 쪽(버전 판정 문구, 측정 도구 정비)이다.

### Constraints

- **SDK**: Flutter 3.47.x / Dart 3.13 이상만 지원 — 사용 프로젝트가 3.47.5 이고, 최신 lint 규칙과 `riverpod_lint` 3.1.9 를 쓰기 위해
- **Compatibility**: `package:woody_lints/analysis_options.yaml` URI 는 공개 API 다 — 모든 사용 프로젝트가 이 경로로 참조하므로, 프리셋을 나눈 뒤에도 이 URI 는 지금과 같은 뜻(기본 + Riverpod + codegen)을 유지한다. 새 문서는 정식 이름 `package:woody_lints/recommended.yaml` 을 안내한다
- **Release channel**: `main` 은 릴리스 채널이다 — 사용 프로젝트 5개가 `ref: main` 을 따르므로, `lib/` 와 `pubspec.yaml` 을 고치는 작업은 milestone 브랜치에 쌓고 릴리스(tag) 때만 PR(merge commit)로 `main` 에 합친다. `.planning/` 기록만 바뀌는 PR 은 받는 쪽에 닿지 않는다 (v2.0 마감 때 고침 — 이전 문구는 "릴리스 전까지 1.3.0 상태 유지")
- **Distribution**: Git 의존성 + git tag 로만 배포 — pub.dev 에 올리지 않는다
- **Safety**: 실측은 `flutter_starter_kit` 복사본에서 한다 — 원본 프로젝트는 수정하지 않는다
- **Verification**: plugin 진단 확인은 `dart analyze` 로 한다 — `flutter analyze` 는 Flutter 버전에 따라 plugin 진단을 누락한다
- **Dependencies**: `include:` 대상 패키지는 `dependencies` 에 둔다 — `dev_dependencies` 는 사용 프로젝트의 의존성 그래프에 전달되지 않는다
- **Documentation**: YAML 주석, README, CHANGELOG 는 한국어로 쓰고 규칙명·키는 영어 원문을 쓴다 — 기존 관례이며 독자가 작성자 본인이다

<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->

## Technology Stack

## Languages

- YAML - 배포 산출물 전부. `lib/base.yaml` (95행, 규칙 81개), `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml`, `lib/analysis_options.yaml` (옛 주소 별칭). 그 밖에 `pubspec.yaml`, 루트 `analysis_options.yaml`, `.github/workflows/verify.yml`, 연습용 프로젝트의 `analysis_options.yaml`
- Dart (언어 버전 3.13, `pubspec.yaml:11` `sdk: ^3.13.0`) - 저장소 안쪽 도구만. `tool/verify.dart` (3223행), `tool/smoke.dart` (1143행), `tool/measure_rules.dart` (5188행). `lib/` 에는 `.dart` 파일이 없다 (`tool/verify.dart` 의 `[1/N]` 단계가 이것을 검사한다, `tool/verify.dart:4`)
- Dart (연습용 코드) - `example/lib/*.dart`, `fixtures/*/lib/*.dart` — 일부러 규칙을 어긴 코드. `example/lib/final_parameters_rule.dart` 는 `// @dart=3.11` 로 언어 버전을 낮춘다 (`example/README.md:47`)
- Markdown - `README.md`, `RULES.md`, `VERSIONING.md`, `CHANGELOG.md`, `example/README.md` (한국어)
- JSON - `.fvmrc`, `.vscode/settings.json`, 실측 결과 `tool/measurements/2026-10-13-R1.json`

## Runtime

- 받는 쪽: 실행 시점 런타임 없음. 소비 주체는 Dart Analysis Server / `dart analyze`. 받는 쪽 요구 사항은 Dart 3.13 이상(Flutter 3.47 이상) — `pubspec.yaml:11`, `README.md:7`. 미만은 `ref: v1.3.0` 에 머문다 (`CHANGELOG.md` 2.0.0 항목)
- 저장소 안쪽: Flutter `3.47.5` 를 FVM 으로 고정 (`.fvmrc`). 번들 Dart 는 3.13.4 (`example/README.md:89`, `tool/measurements/2026-10-13-R1.json` 의 `conditions.dart`). `tool/verify.dart` · `tool/smoke.dart` 는 실행 중인 SDK 가 `.fvmrc` 와 다르면 종료 코드 78 로 멈춘다 (`tool/verify.dart` 머리 주석, `tool/smoke.dart:51`)
- pub (`dart pub` / `flutter pub`)
- Lockfile: 루트 `pubspec.lock` 은 커밋하지 않는다 (`.gitignore`, 라이브러리 관례). `example/pubspec.lock` 과 `fixtures/*/pubspec.lock` 다섯은 커밋한다 (`.gitignore` 의 `!` 예외) — 로컬과 CI 가 같은 패키지 버전으로 판정하게 하려는 것

## Frameworks

- `flutter_lints` `^6.0.0` (`pubspec.yaml:17`, 연습용 lock 기준 6.0.0) - 기반 규칙 세트. `lib/base.yaml:5` 가 `include: package:flutter_lints/flutter.yaml` 로 상속
- `lints` 6.1.0 - `flutter_lints` 의 전이 의존성 (`example/pubspec.lock`)
- `riverpod_lint` `^3.1.9` - analyzer plugin. `lib/riverpod.yaml:4-5` 의 최상위 `plugins:` 에 선언. pub 의존성이 아니다 (아래 "Key Dependencies")
- 테스트 프레임워크(`package:test`) 없음, `test/` 없음
- 검증은 `tool/verify.dart` 가 한다: 연습용 프로젝트(`example/` + `fixtures/` 다섯)를 `dart analyze` 로 분석해 정답지(`expected_diagnostics.txt`)와 견준다 (`tool/verify.dart:1-28`)
- 릴리스 smoke test: `tool/smoke.dart` (GitHub 에서 `<ref>` 를 받아 빈 Flutter 프로젝트로 확인)
- FVM - Flutter 버전 고정 (`.fvmrc`, 캐시 `.fvm/` 는 `.gitignore`)
- 빌드 단계 · 코드 생성 · 번들러 없음

## Key Dependencies

- `flutter_lints` `^6.0.0` - `pubspec.yaml` 의 `dependencies` 에 둔다. `lib/base.yaml` 의 `include:` 는 받는 쪽 프로젝트의 패키지 해석으로 풀리는데, `dev_dependencies` 는 받는 쪽 의존성 그래프에 들어가지 않으므로 거기 두면 include 해석이 깨진다 (`pubspec.yaml:13-15` 주석)
- `woody_lints` 자기 자신 - `lib/recommended.yaml` · `lib/analysis_options.yaml` 이 `package:woody_lints/...` 로 조각을 include 한다 (자기 참조 include 사슬: `analysis_options.yaml` → `recommended.yaml` → `base.yaml` · `riverpod.yaml` · `codegen.yaml`)
- `riverpod_lint` `^3.1.9` - `pubspec.yaml` 에 없다. include 로 받은 최상위 `plugins:` 를 Dart Analysis Server 가 읽어, 자기 상태 폴더의 `.plugin_manager/<hash>/` 에 따로 받아 컴파일한다 (기본 자리 `~/.dartServer`, `README.md:363`). 옛 `analyzer: plugins:` 선언은 3.x 에서 아무것도 로드하지 않는다 (`lib/riverpod.yaml:2`). 하한을 바꾸면 `fixtures/overrides/analysis_options.yaml` 의 `version:` 과 README 예시도 같은 커밋에서 바꾼다 (`lib/riverpod.yaml:5` 주석, `tool/verify.dart` `[3/N]` · `[4/N]` 이 견준다)
- `yaml` `^3.1.4` - `tool/verify.dart` `[3/N]` 이 줄 단위로 읽은 값을 YAML 해석 결과와 견주고 `version` 을 읽는다 (`pubspec.yaml:19-24`, `tool/verify.dart:49`)
- `markdown` `^7.3.1` - `tool/verify.dart` 가 `CHANGELOG.md` 첫 줄 제목을 Markdown 해석의 첫 h2 와 견준다 (`tool/verify.dart:48`)
- `tool/smoke.dart` · `tool/measure_rules.dart` 는 `dart:io` · `dart:convert` 만 쓴다 (`tool/smoke.dart:56`, `tool/measure_rules.dart:46-47`)
- `flutter_riverpod` `^3.0.0` (lock 3.4.3), `flutter` SDK, `woody_lints` 는 `path: ..` / `path: ../..` (`example/pubspec.yaml`, `fixtures/*/pubspec.yaml`)

## Configuration

- 환경 변수로 하는 설정 없음. `.env` 파일 없음
- 도구가 읽는 환경 변수: `FLUTTER_ROOT` (SDK 찾기, `tool/verify.dart:555`, `tool/smoke.dart:268`), `GITHUB_REF_TYPE` · `GITHUB_REF_NAME` · `CI` · `GITHUB_ACTIONS` (`tool/verify.dart:3105-3121`), `HOME` (출력 가리기, `tool/smoke.dart:347`)
- 도구가 하위 명령에 주는 환경 변수: `ANALYZER_STATE_LOCATION_OVERRIDE` (전용 analyzer 상태 폴더, `tool/verify.dart:712`, `tool/smoke.dart:729`), `PUB_CACHE` (smoke 의 새 pub cache, `tool/smoke.dart:13`)
- `lib/base.yaml` - `include: package:flutter_lints/flutter.yaml` + `linter.rules` 목록 (분류 주석: 성능 · 가독성 및 스타일 · 버그 방지 · strict)
- `lib/riverpod.yaml` - 최상위 `plugins: riverpod_lint: ^3.1.9`
- `lib/codegen.yaml` - `analyzer.errors.invalid_annotation_target: ignore`, `analyzer.exclude` 에 `**/*.freezed.dart` · `**/*.g.dart`
- `lib/recommended.yaml` - 위 셋을 include 하는 묶음
- `lib/analysis_options.yaml` - `include: package:woody_lints/recommended.yaml` 만 담은 옛 주소 별칭 (공개 API 라 유지)
- 루트 `analysis_options.yaml` - `flutter_lints` 기반 세트만 include (이 패키지의 조각은 include 하지 않음), `analyzer.exclude` 에 `example/**` · `fixtures/**`
- 없음. `build/` 는 `tool/verify.dart` 의 규칙 검사 복사본 자리(`build/woody_rule_check/`)로 `.gitignore` 대상. `.dart_tool/woody_verify/` 는 검증 전용 analyzer 상태 폴더

## Platform Requirements

- FVM + Flutter 3.47.5 (`.fvmrc`), `.vscode/settings.json` 의 `dart.flutterSdkPath` 가 `.fvm/versions/3.47.5` 를 가리킨다 — `.fvmrc` 를 바꾸면 함께 바꾼다
- 검증: `fvm dart run tool/verify.dart [--update] [--tag vX.Y.Z]` (`tool/verify.dart:13`). plugin 진단은 `dart analyze` 로 본다
- `pubspec.yaml` 이 바뀐 작업 트리는 `fvm dart pub get` 을 먼저 한 번 돌린다 (안 하면 종료 코드 254, `example/README.md:11`)
- 배포 대상 서버 없음. `publish_to: 'none'` (`pubspec.yaml:6`). GitHub 저장소 `woodkill/woody_lints` 의 git tag(`v1.3.0`, `v2.0.0`)로 배포. 현재 `pubspec.yaml` 의 `version: 2.0.0`
- 받는 쪽: Dart 3.13 이상, `analysis_options.yaml` 에 `include: package:woody_lints/recommended.yaml` (또는 옛 주소)

<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->

## Conventions

## Naming Patterns

- 배포 YAML 은 `lib/<이름>.yaml` 이고 이름이 곧 공개 주소다 (`package:woody_lints/<이름>.yaml`). 조각(fragment) 셋 `base` · `riverpod` · `codegen`, 묶음(bundle) `recommended`, 옛 주소 별칭 `analysis_options` (`lib/analysis_options.yaml` 1-4행, `lib/recommended.yaml` 1-7행).
- `lib/analysis_options.yaml` 의 이름 · 위치는 바꾸지 않는다 — 사용 프로젝트가 이 주소로 include 한다. 내용은 `include: package:woody_lints/recommended.yaml` 한 줄뿐이어야 한다 (`[3/10]` 이 "include 만 담는지" 견줌, `tool/verify.dart` 6행).
- 문서는 대문자 이름: `README.md`, `RULES.md`, `VERSIONING.md`, `CHANGELOG.md`, `example/README.md`.
- Dart 도구 파일은 snake_case: `tool/verify.dart`, `tool/smoke.dart`, `tool/measure_rules.dart`.
- 연습용 샘플 파일은 `<분류>_rules.dart` 꼴: `example/lib/style_rules.dart`, `example/lib/bug_prevention_rules.dart`, `example/lib/performance_rules.dart`, `example/lib/strict_rules.dart`, `example/lib/riverpod_rules.dart`. 생성 파일 샘플은 `example/lib/generated/sample.g.dart` · `sample.freezed.dart`.
- 연습용 프로젝트 폴더는 받는 조합 이름: `fixtures/base_only/`, `fixtures/base_riverpod/`, `fixtures/base_codegen/`, `fixtures/recommended/`, `fixtures/overrides/`.
- 측정 결과는 `tool/measurements/<YYYY-MM-DD>-<run id>.json` (예: `tool/measurements/2026-10-13-R1.json`, 규칙은 `tool/measure_rules.dart` 머리 주석 `--out`).
- lowerCamelCase. 대부분 동사로 시작한다: `checkLibHasNoDart`, `checkRuleNames`, `checkShippedComposition`, `compareFixture`, `ensurePinnedSdk`, `runPubGet`, `readPluginVersion`, `scrubPaths`, `normalizeDiagnostics`, `writeExpected`, `formatStepLine`, `quit` (`tool/verify.dart` 485-3066행).
- 단계 하나는 `check…` 이름으로 `StepResult` 를 돌려준다 (`checkLibHasNoDart` 819행, `checkFixtureOptions` 1382행, `checkShippedComposition` 2401행).
- 값을 돌려주는 순수 함수 일부는 명사형이다: `fencedLines`, `significantLines`, `pluginFolders`, `declaredRuleNames`, `yamlRuleNames`, `sameLines`. 새 함수는 사용자 전역 지침대로 동사로 시작한다 (`read…`, `check…`, `format…`).
- top-level 상수도 lowerCamelCase (`pluginFailureHeader`, `fixtures`, `createTimeout`, `pubGetTimeout`, `analyzeTimeout` — `tool/verify.dart` 52-55행, `tool/smoke.dart` 117-123행). SCREAMING_CASE 는 쓰지 않는다.
- UpperCamelCase 클래스: `Fixture`, `Expected`, `StepResult`, `SdkInfo`, `PluginVersion`, `AnalyzeOutcome`, `MarkerBlock` (`tool/verify.dart`).
- 규칙 이름은 Dart 공식 이름(snake_case) 그대로 (`lib/base.yaml`).

## Code Style

- YAML 은 2칸 들여쓰기 (`lib/base.yaml`, `pubspec.yaml`, `.github/workflows/verify.yml`).
- Dart 는 `dart format` 기본 스타일로 보인다 (추론 — 포맷 설정 파일은 없고 `formatter:` 키도 없다).
- YAML / Markdown 용 포맷터 · 린터 설정은 없다.
- 루트 `analysis_options.yaml` 은 `include: package:flutter_lints/flutter.yaml` 만 받는다. 이 패키지의 조각을 include 하지 않는다 — 규칙 변경이 도구 스크립트의 진단과 섞이지 않게 하려는 것 (`analysis_options.yaml` 1-6행).
- `analyzer.exclude` 로 `example/**` · `fixtures/**` 를 뺀다 — 일부러 규칙을 어긴 연습용 프로젝트라서 (`analysis_options.yaml` 8-12행). 루트에서 `lib/` 를 exclude 하지 않는다.
- 기반 세트: `lib/base.yaml` 5행 `include: package:flutter_lints/flutter.yaml` (`pubspec.yaml` 의 `flutter_lints: ^6.0.0`).
- 추가 규칙 87개 남짓을 네 분류 주석 아래 둔다: `# 성능`, `# 가독성 및 스타일`, `# 버그 방지`, `# strict — …` (`lib/base.yaml`). 정확한 목록과 켠 이유는 `RULES.md` 「켠 규칙」(`woody:enabled-rules` 구역).
- `analyzer.errors` / `analyzer.exclude` 는 `lib/codegen.yaml` 에만 (`invalid_annotation_target: ignore`, `'**/*.freezed.dart'`, `'**/*.g.dart'`).
- analyzer plugin 은 `lib/riverpod.yaml` 의 최상위 `plugins:` 에만 (`riverpod_lint: ^3.1.9`). `analyzer: plugins:` 는 쓰지 않는다 — riverpod_lint 3.x 에서는 아무것도 로드하지 않는다 (`lib/riverpod.yaml` 2행).

## 규칙 추가 · 변경 절차 (Prescriptive)

- 근거: `README.md` 「이 저장소를 고치는 사람에게」(382-388행), `lib/base.yaml` 3행 주석, `tool/verify.dart` 6행 (`[3/N]` 설명), `VERSIONING.md` 「판정 순서」 · 「CHANGELOG 항목 형식」.
- **1.** 규칙은 `lib/base.yaml` 에만 적는다. 알맞은 분류 주석(`# 성능` · `# 가독성 및 스타일` · `# 버그 방지` · `# strict …`) 아래에 넣는다. `lib/codegen.yaml` · `lib/riverpod.yaml` 에 `linter:` 를 두면 `[3/10]` 이 실패한다 (`example/README.md` M35).
- **2.** 같은 커밋에서 다음을 함께 고친다 — 어긋나면 `[3/10]` 이 실패한다 (`README.md` 385행):
- ↳ `RULES.md` 「켠 규칙」 표 (`<!-- woody:enabled-rules:start -->` ~ `end`, 9-93행). 행의 첫 칸은 backtick 이름 하나.
- ↳ `README.md` 「받는 규칙」의 표시 구역 `woody:readme-rules` (빈 줄 · `**분류**` 소제목 · `` - `이름` `` 불릿만 허용; 구역이 든 절의 구역 밖에 목록 줄을 두지 않는다 — `example/README.md` M43 · M44 · M74 ~ M77).
- ↳ `CHANGELOG.md` 최상단 버전 항목 (규칙 추가는 minor, 「새로 생기는 경고」 칸 필수 — `VERSIONING.md` 45 · 54행).
- ↳ 연습용 프로젝트 샘플과 정답지 (`fvm dart run tool/verify.dart --update` 로 갱신, `example/README.md` 「실행」). `example/lib/` 를 고치면 `fixtures/*/lib/` 복사본 다섯도 같이 고친다 (`example/README.md` 「연습용 프로젝트 여섯」).
- **3.** 형식:
- ↳ 목록 형식 `    - rule_name # 이유` 만 쓴다. 맵 항목(`- avoid_print: true`), 이름을 다음 줄로 넘긴 `-` 는 검증이 종료 코드 70 으로 멈춘다 (`example/README.md` M29 · M30). 따옴표로 감싼 이름은 읽지만 쓰지 않는다 (M27 · M28).
- ↳ 줄 끝에 한국어 주석으로 켠 이유를 한 줄 적는다. "무엇" 보다 "왜" — 예: `prefer_const_constructors # … 성능 이득은 근거가 부족하다는 것이 Flutter 팀의 판단 (lints#205)` (`lib/base.yaml`).
- ↳ 기반 세트(`flutter_lints` / `lints`)가 이미 켜는 규칙은 넣지 않는다 — `[3/10]` 이 겹침으로 실패한다 (M20).
- **4.** 끄는 규칙: `lib/base.yaml` 에 주석 처리로 남기지 않는다(현재 주석 처리된 규칙 줄은 0). 대신 `RULES.md` 「켜지 않은 규칙」 표(`woody:disabled-rules` 구역)에 접두사 7종(`기반 세트` · `비호환` · `experimental`/`testing` · `v2 로 미룸 (RULES-NN)` · `deprecated`/`removed`/`없음` · `규칙이 돌지 않음` · `소유자 결정`) 또는 `보류` 로 시작하는 이유를 적는다 (`RULES.md` 105-119행).
- **5.** 조각마다 받는 최상위 키는 닫힌 목록이다: `lib/base.yaml` 은 `include` · `linter` · `analyzer`, `lib/codegen.yaml` 은 `analyzer`(아래 `errors` · `exclude`), `lib/riverpod.yaml` 은 `plugins`(아래 `riverpod_lint`). `lib/recommended.yaml` · `lib/analysis_options.yaml` 은 `include` 만 (`README.md` 384행).
- **6.** `riverpod_lint` 하한을 올릴 때 같은 커밋에서 고칠 자리 (`lib/riverpod.yaml` 5행 주석, `README.md` 388행):
- ↳ `lib/riverpod.yaml` 의 `riverpod_lint:` 선언
- ↳ `fixtures/overrides/analysis_options.yaml` 의 `version:` (`[4/10]` 이 견줌)
- ↳ `README.md` 의 plugin 버전 예시 둘 (「조각마다의 설정」 · 「규칙 · plugin 진단 끄기」, 펜스 안 블록 꼴 · 키 글자 그대로 — `[3/10]` 이 견줌)
- **7.** 릴리스 버전을 올릴 때는 `pubspec.yaml` `version:`, `CHANGELOG.md` 첫 줄 제목, `README.md` 의 `ref:` 예시 둘, 커밋된 lock 여섯(`example/pubspec.lock`, `fixtures/*/pubspec.lock` — `fvm dart pub get` 으로만)을 같은 커밋에서 고친다 (`VERSIONING.md` 「릴리스 절차」 140-141행, `README.md` 388행).
- **8.** 새 규칙이 SDK 에서 실제로 도는지 판단할 때 `rules.json` 대신 `messages.yaml` 과 실제 분석을 쓴다 (프로젝트 skill `.claude/skills/spike-findings-woody-lints/references/rule-status-check.md`).

## Import Organization (Dart 도구)

- **1.** `dart:` (`dart:convert`, `dart:io`)
- **2.** 빈 줄
- **3.** `package:` (`package:markdown/markdown.dart' as md`, `package:yaml/yaml.dart`) — `tool/verify.dart` 46-50행
- 충돌하는 이름은 prefix 로 받는다 (`as md`).
- 도구가 쓰는 패키지는 `pubspec.yaml` 의 `dev_dependencies` (`markdown`, `yaml`) — 받는 쪽 의존성 그래프에 들어가지 않는다 (`pubspec.yaml` 18-25행). 그 밖에는 `dart:io` · `dart:convert` 만 쓴다.
- `include:` 대상 패키지(`flutter_lints`)는 `dependencies` 에 둔다 — `dev_dependencies` 는 사용 프로젝트에 전달되지 않는다 (`pubspec.yaml` 13-17행).
- `riverpod_lint` 는 `pubspec.yaml` 에 넣지 않는다. plugin 캐시(`~/.dartServer/.plugin_manager`)에서 해석된다.

## Error Handling (Dart 도구)

- `tool/verify.dart` (머리 주석 26-31행, `example/README.md` 「검증 명령의 종료 코드」): `0` 모두 통과 / `1` 단계 실패 / `64` 사용법 오류(CI 에서 `--update` 포함) / `69` `pub get` 실패 / `70` 예외(`FormatException` · `FileSystemException` · `ProcessException`) / `78` 실행 중 SDK 가 `.fvmrc` 와 다름 / `255` `package:yaml` 의 `Error` (받지 않음).
- `tool/smoke.dart` (45행): `0` 통과 / `1` 판정 실패 / `64` 사용법 오류 외.
- 새 실패 종류를 더하면 같은 표에 행을 더한다.
- `main` 이 예외 종류별로 `on … catch` 해 `exitCode` 를 정하고 stderr 에 한국어 한 줄을 찍는다 (`tool/verify.dart` 3209-3221행).
- 읽지 못하는 입력은 건너뛰지 않고 멈춘다 (`FormatException` → 70). 문구에 파일 이름 · 행 번호 · 받는 꼴을 적는다 (`example/README.md` M29).
- 종료는 `quit(int code)` (`Future<Never>`, `tool/verify.dart` 523행)로 출력 flush 뒤 `exit`.
- 하위 명령 실패는 `exitCode` 와 stderr 를 같이 보여 준다 (`runPubGet` 613-633행).
- plugin 준비 실패는 stderr 의 `pluginFailureHeader` 문자열을 `contains` 로 판정한다 (첫 줄이 아닐 수 있음, spike 008 — `tool/verify.dart` 52-55행).
- 하위 명령에 시간 제한을 둔다 (`tool/smoke.dart` 117-123행: create 2분, pub get 5분, analyze 5분).
- 다른 도구 출력의 저장소 절대 경로는 `<repo>` 로 가린다 — `scrubPaths` (`tool/verify.dart` 689-697행). smoke 는 임시 폴더를 `<임시 폴더>` 로 가리고, `--keep` 때만 경로를 찍는다 (`tool/smoke.dart` 37-39행).
- 화면 · 정답지에는 상대 경로만 쓴다 (`relativize` 600행, 정답지 `상대경로:줄`).

## Logging

- 결과(단계 줄, 차이)는 stdout, 진단 · 모드 안내(`버전 일치 검사:` 줄)와 오류는 stderr (`tool/verify.dart` 16-18행).
- 단계 줄은 `[i/N] 이름 … 결과` 꼴로 폭을 맞춰 찍는다 (`formatStepLine` 3001행, `measureWidth` 2984행).
- 차이는 `- `(사라진 줄) · `+ `(새로 생긴 줄)로 (`example/README.md` 「실행」).
- 사용 프로젝트에는 `avoid_print` (기반 세트)가 켜져 있다.

## Comments

- 한국어로 쓴다. `lib/*.yaml` 다섯에 영어 주석은 없다 (확인: `lib/base.yaml`, `lib/codegen.yaml`, `lib/riverpod.yaml`, `lib/recommended.yaml`, `lib/analysis_options.yaml` 전문). 템플릿에서 온 주석은 커밋 "docs(lib): 배포 YAML 다섯의 머리 주석을 실제 구성에 맞게 — 템플릿 주석 삭제 …" 에서 지웠다 (`git log -- lib/base.yaml`).
- 파일마다 머리 주석 2-4줄: 이 파일이 무엇인지, 이것만 받는 주소(`package:woody_lints/<이름>.yaml`), 자세한 곳(README · RULES.md)의 안내 (`lib/base.yaml` 1-4행, `lib/codegen.yaml` 1-3행).
- 주석은 "왜" 를 적는다 — 예: `lib/riverpod.yaml` 2행(왜 최상위 `plugins:` 인가), `pubspec.yaml` 13-15행(왜 `dependencies` 인가), `analysis_options.yaml` 4-5행(왜 조각을 include 하지 않나).
- 함께 고칠 자리를 주석에 적는다 (`lib/riverpod.yaml` 5행, `lib/base.yaml` 3행).
- 실측 값에는 SDK 버전과 날짜를 붙인다 — 예: `pubspec.yaml` 25행 "(2026-10-16 복제본 실측)", `.github/workflows/verify.yml` 27행 "약 4분 7초 (… 2026-10-12 실측 run …)", `tool/verify.dart` 41행 "(2026-10-15 실측, Dart 3.13.4)".
- 결정의 출처를 괄호로 적는다 — spike 번호(`spike 014`), 리뷰 ID(`06-REVIEW.md IN-09`), 소유자 결정 ID(`G4-Q1`), 결정 ID(`D-10`).
- 한국어 문장에서 영어 식별자 뒤 조사는 한 칸 띄운다 ("`plugins:` 는", "riverpod_lint 3.x 는").
- 파일 머리에 `//` 블록으로 목적 · 실행 명령 · 단계 · 종료 코드 · 만드는/지우는 폴더를 적는다 (`tool/verify.dart` 1-45행, `tool/smoke.dart` 1-50행, `tool/measure_rules.dart` 1-30행).
- 공개 top-level 선언에는 `///` 문서 주석 (`tool/verify.dart` 에 `///` 줄 619개). 첫 줄 요약, 빈 `///`, 근거 문단 순.
- 관련 선언은 `[이름]` 으로 가리킨다 (`tool/smoke.dart` 119-131행).
- 파일 머리 `//` 에 어떤 규칙을 어기는지와 예외 사유를 적고, 샘플마다 `/// \`규칙이름\` — 설명.` (`example/lib/style_rules.dart` 1-20행). "한 줄에서 규칙 하나만 걸리게 둔다".

## Function Design

## Module Design

## 문서 관례

- 모든 문서는 한국어, 규칙명 · 키 · 경로는 영어 원문 (`README.md`, `RULES.md`, `VERSIONING.md`).
- 읽는 사람은 몇 달 뒤의 작성자 본인 — 용어를 쉬운 말로 풀어 적는다 (`VERSIONING.md` 3행, 15-19행).
- 검증이 읽는 구역은 HTML 주석 표식으로 감싼다: `woody:enabled-rules` · `woody:enabled-options` · `woody:disabled-rules` · `woody:measurements` (`RULES.md`), `woody:readme-rules` (`README.md`). `RULES.md` 의 `woody:measurements` 는 `tool/measure_rules.dart --report --write` 가 쓴다.
- README 의 YAML 예시는 펜스(```` ``` ```` · `~~~`) 안 블록 꼴, 키 글자 그대로(`ref:` · `version:` · `riverpod_lint:`) — `[3/10]` 이 그 값만 견준다 (`README.md` 388행).
- **CHANGELOG:** 최신이 위. 첫 줄은 반드시 `## X.Y.Z - YYYY-MM-DD` (준비 중 `## X.Y.Z - 미출시`), ` - ` 는 제목에 한 번만 (`VERSIONING.md` 82행, `CHANGELOG.md` 1행). 그 아래 `지원 SDK:` 줄과 「새로 생기는 경고」 칸은 필수, `### 올리기 전에` · `### 추가한 규칙` 등은 해당할 때만 (`VERSIONING.md` 77-102행). 실측 한 줄은 `실측: flutter_starter_kit (Dart 파일 N개), Flutter X.Y.Z, YYYY-MM-DD`. 1.3.0 / 1.0.0 항목은 옛 형식 그대로 둔다 (`VERSIONING.md` 128행).
- **버전:** `major.minor.patch`. 준비 중 `X.Y.Z-dev` (`VERSIONING.md` 140행). 등급은 `VERSIONING.md` 「판정 순서」 위에서부터 첫 "예" — SDK 하한 · URI · `flutter_lints`/`riverpod_lint` major · 기존 규칙 심각도 상향은 major, 규칙 · exclude/errors · plugin 하한 변경은 minor, 그 밖의 `lib/` · `pubspec.yaml` 변경은 patch.
- 연습용 프로젝트 · 검증 동작의 실측 기록은 `example/README.md` 「검증이 실제로 잡아내는지 확인한 기록」의 M 번호 표에 이어 쓴다.

## 커밋 관례

- Conventional Commits, prefix 영어 · 제목과 본문 한국어. scope 로 영역을 적는다: `feat(base):`, `fix(tool):`, `docs(lib):`, `style(tool):`, `test(06):`, `docs(06-15):` (`git log`).
- 제목에 ID 를 괄호로 덧붙인다 — 예: `fix(tool): smoke SIGINT 의 … (IN-05 · IN-06 · IN-07)` (커밋 `ea2d664`).
- 규칙 변경 커밋은 제목에 규칙 이름과 결정 근거를 적는다 — 예: `feat(base): sort_pub_dependencies 켬 — 소유자 재결정 (실측 2줄, …); … 정답지 다섯 +1줄`.
- 본문 끝 trailer: `Co-Authored-By: …`, `Claude-Session: …` (커밋 `ea2d664`).
- 지금 이력의 prefix 분포: `docs` 370, `fix` 30, `feat` 24, `test` 16, `chore` 8, `ci` 3, `style` 1. 초기 몇 커밋은 prefix 없는 자유 형식(`slash_for_doc_comments 추가`, `Update README.md`)이다 — 새 커밋에는 쓰지 않는다.
- 커밋 전 린터: `fvm dart run tool/verify.dart` (`README.md` 386행).

## 도구 버전 고정

- `.fvmrc` 의 `"flutter": "3.47.5"`. CI 는 `flutter-version-file: .fvmrc` 로 같은 버전을 설치하고 workflow 에 숫자를 적지 않는다 (`.github/workflows/verify.yml` 30-34행).
- `tool/verify.dart` 는 실행 중 SDK 가 `.fvmrc` 와 다르면 78 로 멈춘다 (`ensurePinnedSdk` 574행).
- `pubspec.yaml` 의 `environment.sdk: ^3.13.0`.
- `.vscode/settings.json` 은 FVM SDK 경로를 가리킨다 (내용은 이번에 확인하지 않음).

<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->

## Architecture

## System Overview

```text

```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| 옛 주소 별칭 | 1.x 사용 프로젝트용 공개 URI. `include: package:woody_lints/recommended.yaml` 한 줄만 담는다 | `lib/analysis_options.yaml:4` |
| 묶음 (recommended) | 조각 셋을 list 형식 `include:` 로 묶는다 | `lib/recommended.yaml:4-7` |
| 기본 조각 (base) | `flutter_lints` 상속 + 추가 규칙 전부 (성능 / 가독성 및 스타일 / 버그 방지 / strict 분류) | `lib/base.yaml` |
| Riverpod 조각 | 최상위 `plugins:` 에 `riverpod_lint: ^3.1.9` | `lib/riverpod.yaml:4-5` |
| codegen 조각 | `invalid_annotation_target: ignore`, `**/*.freezed.dart` · `**/*.g.dart` exclude | `lib/codegen.yaml:4-9` |
| 패키지 매니페스트 | `version: 2.0.0`, `sdk: ^3.13.0`, `flutter_lints` 를 `dependencies` 로 전달, 검증 도구용 dev 의존성(`yaml`, `markdown`) | `pubspec.yaml` |
| 자체 분석 설정 | 저장소 루트 분석. `flutter_lints` 만 include, `example/**` · `fixtures/**` exclude | `analysis_options.yaml` |
| 검증 명령 | 배포 파일 구성 · 문서 일치 · 연습용 프로젝트 진단 대조 (10단계) | `tool/verify.dart` |
| 릴리스 smoke test | 빈 Flutter 프로젝트가 GitHub 에서 `<ref>` 를 받아 두 주소로 분석 | `tool/smoke.dart` |
| 규칙 실측 도구 | 후보 133개의 상태 · 건수 · `dart fix` 건수를 재고 RULES.md 실측 구역을 쓴다 | `tool/measure_rules.dart` |
| 연습용 프로젝트 | 일부러 규칙을 어긴 샘플 + 정답지 | `example/`, `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/` |
| CI | 모든 push · PR · 수동 실행에서 `dart run tool/verify.dart` | `.github/workflows/verify.yml` |
| 규칙 근거 문서 | 켠 규칙 표, 켜지 않은 규칙, 실측 기록(`woody:measurements` 구역) | `RULES.md` |
| 버전 정책 | 등급 판정 순서 · 기준표 · CHANGELOG 형식 · 릴리스 절차 | `VERSIONING.md` |
| SDK 고정 | Flutter `3.47.5` (FVM) | `.fvmrc`, `.vscode/settings.json` |

## Pattern Overview

- `lib/` 에 `.dart` 파일이 없다. 배포 산출물은 `lib/*.yaml` 다섯이며 `[1/10]` 이 `.dart` 부재를 검사한다 (`tool/verify.dart:4`).
- 파일 이름이 곧 공개 API 다: `package:woody_lints/<이름>.yaml` 은 `lib/` 바로 아래 같은 이름의 파일로 해석된다. 옛 주소 `package:woody_lints/analysis_options.yaml` 은 "기본 + Riverpod + codegen" 뜻을 유지한다 (`lib/analysis_options.yaml:1-3`). URI 를 없애거나 뜻을 바꾸면 major (`VERSIONING.md:38`).
- 조각끼리는 서로 include 하지 않는다. 묶음만 조각 셋을 include 하고, 별칭은 묶음만 include 한다. 규칙은 `lib/base.yaml` 에만 둔다 (`lib/base.yaml:3`, `[3/10]` 이 다른 조각의 규칙을 실패로 본다 — `tool/verify.dart:6`).
- 두 해석 경로가 공존한다: `include:` 는 pub 의존성 그래프, `plugins:` 는 Dart Analysis Server 의 plugin 캐시.
- 배포는 git 의존성 + tag 뿐이다 (`pubspec.yaml:6` `publish_to: 'none'`, `pubspec.yaml:8` repository `https://github.com/woodkill/woody_lints.git`).

## Layers

- Purpose: Flutter 공식 권장 lint
- Location: `package:flutter_lints/flutter.yaml` → `package:lints`
- Contains: core / recommended / flutter 규칙
- Depends on: `flutter_lints: ^6.0.0` (`pubspec.yaml:16-17`)
- Used by: `lib/base.yaml:5`, 루트 `analysis_options.yaml:6`
- Purpose: 받는 쪽이 골라 받는 최소 단위
- Location: `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`
- Contains: 조각마다 정해진 최상위 키만 — base 는 `include` · `linter` · `analyzer`, codegen 은 `analyzer`(아래 `errors` · `exclude`), riverpod 은 `plugins`(아래 `riverpod_lint`) (`README.md` 「이 저장소를 고치는 사람에게」 첫 항목)
- Depends on: 상류 기반 세트(base 만), plugin 캐시(riverpod 만)
- Used by: 묶음, 또는 받는 쪽이 직접
- Purpose: 한 줄로 전부 받기, 옛 주소 호환
- Location: `lib/recommended.yaml`, `lib/analysis_options.yaml`
- Contains: `include:` 만 (`[3/10]` 이 "묶음 · 별칭은 include 만 담는지" 검사 — `tool/verify.dart:6`)
- Used by: 받는 쪽 프로젝트
- Purpose: 배포 파일이 문서 그대로 적용되는지 증명
- Location: `tool/`, `example/`, `fixtures/`, `.github/workflows/verify.yml`, 루트 `analysis_options.yaml`
- Depends on: `.fvmrc` 의 SDK, dev 의존성 `yaml` · `markdown` (`pubspec.yaml:23-25`)
- Used by: 저장소 기여자, CI. 받는 쪽에는 전달되지 않는다 (`analysis_options.yaml:1-2`)

## Data Flow

### Primary Request Path (받는 쪽의 정적 분석)

- **1.** 받는 쪽 `pub get` 이 git 의존성(`ref: main` 또는 `ref: vX.Y.Z`)으로 `woody_lints` 와 그 `dependencies`(`flutter_lints`)를 받는다 (`pubspec.yaml:13-17`).
- **2.** analyzer 가 받는 쪽 `include:` 를 따라 `lib/analysis_options.yaml` → `lib/recommended.yaml` (`lib/analysis_options.yaml:4`) → 조각 셋 (`lib/recommended.yaml:5-7`) → `package:flutter_lints/flutter.yaml` (`lib/base.yaml:5`) → `lints` 로 내려간다. 아래 계층(받는 쪽)이 위를 덮어쓴다.
- **3.** `linter.rules` 는 list 형식으로 합쳐지고, `analyzer.errors` · `analyzer.exclude` 는 `lib/codegen.yaml` 에서 온다.
- **4.** include 로 받은 최상위 `plugins:` 도 받는 쪽 루트 옵션 파일에 적용된다 (spike 009 — `.claude/skills/spike-findings-woody-lints/references/preset-split-structure.md`).

### Analyzer Plugin 로드 경로

- **1.** Analysis Server 가 `plugins: riverpod_lint: ^3.1.9` (`lib/riverpod.yaml:5`) 를 읽는다.
- **2.** pub.dev 에서 범위 안 최신을 받아 plugin 캐시에 컴파일한다 — 받는 쪽 `pubspec.lock` 이 묶지 못한다 (`example/README.md` 「파일」 표의 `pubspec.lock` 행, `VERSIONING.md:151-153`).
- **3.** 받는 쪽이 진단을 끄려면 `plugins: riverpod_lint: version:` 을 다시 적고 `diagnostics:` 를 단다 — 그 값이 선언을 통째로 대신한다 (`fixtures/overrides/analysis_options.yaml:8-12`, `tool/verify.dart` 의 `pluginConstraintToken` 주석, spike 012).

### 검증 흐름 (`tool/verify.dart`)

- **1.** 준비: 실행 SDK 가 `.fvmrc` 와 같은지(다르면 종료 코드 78), 루트 · 연습용 프로젝트 전부 `pub get` (실패 69) (`tool/verify.dart:23-24`, `:31-35`).
- **2.** `[1/10]` `lib/` 에 `.dart` 없음.
- **3.** `[2/10]` 조각 셋 복사본(`build/woody_rule_check/`)을 분석해 deprecated / removed / 없는 규칙 · 옵션 경고 · 깨진 YAML 이 0건.
- **4.** `[3/10]` 배포 파일 구성과 문서 일치 — 묶음 · 별칭은 include 만, `lib/base.yaml` 규칙이 기반 세트와 겹치지 않음, `RULES.md` 켠 규칙 표 · README 표시 구역(`README.md:95-190` `woody:readme-rules`) 과 같음, 조각별 최상위 키 목록, README 의 프리셋 주소 · plugin 버전 · `ref:`, 줄 단위 읽기와 `package:yaml` 해석 일치, tag · `pubspec.yaml` version · `CHANGELOG.md` 최상단 버전 일치 (`tool/verify.dart:6`).
- **5.** `[4/10]` 연습용 프로젝트 여섯의 `analysis_options.yaml` 이 `fixtures` 표의 `optionsLines` 와 같음 (`tool/verify.dart` `const fixtures`).
- **6.** `[5/10]`~`[10/10]` 연습용 프로젝트마다 별도 상태 폴더(`.dart_tool/woody_verify/<폴더>/`)로 `dart analyze` → `expected_diagnostics.txt` 와 줄 · 건수 대조. 순서 example → recommended → base_only → base_riverpod → base_codegen → overrides; `recommended` 는 정답지 없이 같은 실행의 `example` 결과와 견준다 (`example/README.md` 「연습용 프로젝트 여섯」).
- **7.** `--update` 는 모든 단계가 통과할 때만 정답지 다섯을 다시 쓴다. CI 에서는 거부(64) (`tool/verify.dart:10-15`).

### 규칙 실측 → 문서 흐름

- **1.** `tool/measure_rules.dart --work <저장소 밖 폴더>` 가 사용 프로젝트 복사본에서 단계(state · baseline · groups · markers · ignore · fix · unnecessary-ignore)를 잰다 (`tool/measure_rules.dart:1-35`).
- **2.** 결과 JSON 을 `tool/measurements/2026-10-13-R1.json` 꼴로 남긴다 (건수와 조건만, 비공개 경로 · 진단 문장 없음 — `tool/measure_rules.dart:37-38`).
- **3.** `--report --write` 가 단언 통과 시에만 `RULES.md:218-425` 의 `woody:measurements` 구역을 쓴다. 결정된 규칙은 사람이 `lib/base.yaml` · `RULES.md` 켠 규칙 표 · README 표시 구역에 같은 커밋으로 반영하고, `[3/10]` 이 셋의 일치를 지킨다.

### 릴리스 흐름

- **1.** milestone 브랜치(현재 `gsd/v2.0-package-rework`)에서 준비 중에는 `version: X.Y.Z-dev` 와 `## X.Y.Z - 미출시` 를 함께 둔다 (`VERSIONING.md:130-162` 의 1, 10단계).
- **2.** 릴리스 커밋: `-dev` 제거, CHANGELOG 날짜, lock 여섯 `pub get` 으로 다시 받기, README `ref:` 예시 갱신, `verify.dart --tag vX.Y.Z` 통과 (2단계).
- **3.** 브랜치 push → CI → `tool/smoke.dart <릴리스 커밋>` 예행 (3-4단계).
- **4.** annotated tag `vX.Y.Z` 를 달고 tag 하나만 push → CI 의 tag 실행 확인(`GITHUB_REF_NAME`) → `tool/smoke.dart vX.Y.Z` (5-8단계). 존재하는 tag: `v1.3.0`, `v2.0.0` (`git tag`).
- **5.** `gh pr create --base main` → `gh pr merge --merge` (merge commit 만, squash · rebase 금지) → `main` 이 릴리스 채널이 된다 (9단계). `ref: main` 프로젝트는 각자 `pub upgrade woody_lints` 때 받는다.
- 실행 시점 상태 없음. 버전 상태는 `pubspec.yaml:3` 의 `version`, `CHANGELOG.md` 첫 줄, git tag 셋이 맞물려 있다 (`[3/10]` 이 견준다).
- 검증 도구의 상태: `.dart_tool/woody_verify/` (plugin 컴파일 캐시, 지우지 않음), `build/woody_rule_check/` (실행 중 임시, `.gitignore:18-20`).

## Key Abstractions

- Purpose: 받는 쪽이 고르는 단위
- Examples: `lib/recommended.yaml`, `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/analysis_options.yaml`
- Pattern: `lib/` 바로 아래 파일 = `package:woody_lints/<파일>`. 네 조합(Riverpod × codegen)이 모두 연습용 프로젝트로 덮인다 (`example/README.md` 「연습용 프로젝트 여섯」 2×2 표).
- Purpose: "받는 프로젝트에서 무엇이 달라지는가" 의 기록
- Examples: `example/expected_diagnostics.txt`, `fixtures/base_only/expected_diagnostics.txt`, `fixtures/overrides/expected_diagnostics.txt`
- Pattern: `상대경로:줄  강도  규칙이름` 정렬, 머리 주석에 SDK · plugin 버전 · 날짜. "안 나와야 하는 것" 은 `example/lib/should_not_appear.dart`, `example/lib/generated/` 로 증명.
- Purpose: 연습용 프로젝트의 경로 · 옵션 줄 · plugin 사용 · 정답지를 한곳에서 정의
- Examples: `tool/verify.dart` 의 `const fixtures = <Fixture>[...]`
- Pattern: 표 순서가 곧 단계 순서. 새 연습용 프로젝트는 이 표에 행을 더한다 (단계 수 N = 4 + 표 길이).
- Purpose: 도구가 읽고 쓰는 문서 구역
- Examples: `README.md:95-190` (`woody:readme-rules`), `RULES.md:218-425` (`woody:measurements`)
- Pattern: `<!-- woody:<이름>:start -->` / `:end -->` 주석 쌍.

## Entry Points

- Location: `lib/`
- Triggers: 받는 쪽 `include: package:woody_lints/...`
- Responsibilities: 조각 합성
- Location: `tool/verify.dart`
- Triggers: `fvm dart run tool/verify.dart [--update] [--tag vX.Y.Z]`, CI
- Responsibilities: 10단계 검증. 종료 코드 0 / 1 / 64 / 69 / 70 / 78 / 255 (`tool/verify.dart:30-35`)
- Location: `tool/smoke.dart`
- Triggers: `fvm dart run tool/smoke.dart <ref> [--keep]` (릴리스 4 · 7단계)
- Responsibilities: 저장소 밖 임시 프로젝트에서 새 pub cache · 새 상태 폴더로 두 주소 분석, 위반 둘(`prefer_single_quotes`, `provider_parameters`) 존재 · include 사슬 진단 부재 · lock 의 `resolved-ref` 확인. 종료 코드 0 / 1 / 64 (`tool/smoke.dart:1-45`)
- Location: `tool/measure_rules.dart`
- Triggers: 규칙 후보 평가 때 수동 실행
- Responsibilities: 실측 JSON, `RULES.md` 실측 구역, `--audit`
- Triggers: 모든 브랜치 · tag push, `pull_request`, `workflow_dispatch` (`.github/workflows/verify.yml:8-11`)
- Responsibilities: `subosito/flutter-action@v2` 가 `.fvmrc` 로 SDK 설치 → `dart run tool/verify.dart`. timeout 10분, `permissions: contents: read`

## Architectural Constraints

- **Threading:** 해당 없음 (배포물에 실행 코드 없음). 검증 도구는 연습용 프로젝트를 차례로 분석한다 — 상태 폴더를 합치면 plugin 폴더가 여럿이 되어 버전을 읽지 못한다 (`tool/verify.dart` fixtures 주석, spike 014).
- **Global state:** 없음. 도구 쪽 공유 위치는 `.dart_tool/woody_verify/`, `build/woody_rule_check/`.
- **Circular imports:** 없음. include 는 별칭 → 묶음 → 조각 → `flutter_lints` → `lints` 단방향.
- **공개 URI 고정:** `lib/` 다섯 파일의 이름과 옛 주소의 뜻은 바꾸지 않는다 (`lib/analysis_options.yaml:1-3`, `VERSIONING.md:38`).
- **`plugins:` 는 최상위 키:** `analyzer: plugins:` 는 riverpod_lint 3.x 에서 아무것도 로드하지 않는다 (`lib/riverpod.yaml:2`).
- **include 대상은 `dependencies`:** `dev_dependencies` 는 받는 쪽 그래프에 전달되지 않는다 (`pubspec.yaml:13-17`). 반대로 `yaml` · `markdown` 은 받는 쪽에 가지 않게 일부러 `dev_dependencies` (`pubspec.yaml:19-25`).
- **SDK 하한:** `sdk: ^3.13.0` (`pubspec.yaml:11`), 고정 SDK Flutter 3.47.5 (`.fvmrc`). `avoid_final_parameters` 는 언어 버전 3.13 라이브러리에서 돌지 않는다 (`lib/base.yaml:28`).
- **동기 수정 묶음:** 규칙 변경 = `lib/base.yaml` + `RULES.md` 표 + README 표시 구역; plugin 하한 변경 = `lib/riverpod.yaml` + `fixtures/overrides/analysis_options.yaml` `version:` + README 예시 둘; 버전 변경 = `pubspec.yaml` + `CHANGELOG.md` + README `ref:` 예시 둘 + lock 여섯 (`lib/riverpod.yaml:5`, `README.md` 「이 저장소를 고치는 사람에게」, `VERSIONING.md` 2단계). 어긋나면 `[3/10]` / `[4/10]` 실패.
- **연습용 프로젝트 복사 규칙:** `fixtures/*/lib/` 는 `example/lib/` 의 글자 그대로 복사본 — 예외 `example/lib/relative_imports_rule.dart` 3행의 패키지 이름 (`example/README.md` 「연습용 프로젝트 여섯」).
- **`codegen.yaml` exclude 의 한계:** Dart 3.13.4 에서 규칙 진단에만 통하고 plugin 진단에는 통하지 않는다 (`lib/codegen.yaml:3`, spike 012 · 016).
- **plugin 버전은 tag 로 고정되지 않는다:** 정답지가 저장소 변경 없이 깨질 수 있다 (`VERSIONING.md:151-162`).
- **검증 명령은 `dart analyze`:** plugin 진단 확인용 (`README.md` 「`dart analyze` 와 `flutter analyze`」).

## Anti-Patterns

### `analyzer: plugins:` 로 plugin 선언

- **What happens:** plugin 을 `analyzer:` 아래 리스트로 적는다.
- **Why it's wrong:** riverpod_lint 3.x 는 analysis_server_plugin 방식만 지원해 아무것도 로드되지 않는다.
- **Do this instead:** 최상위 `plugins:` 맵 (`lib/riverpod.yaml:4-5`).

### 규칙을 `lib/base.yaml` 밖에 적기

- **What happens:** 묶음 · 별칭 · 다른 조각에 `linter:` 를 넣는다.
- **Why it's wrong:** 조각 조합의 뜻이 흐려지고 `[3/10]` 이 실패한다.
- **Do this instead:** `lib/base.yaml` 의 분류 주석 아래에 한 줄 + 한국어 이유 주석, 같은 커밋에서 `RULES.md` 와 README 표시 구역.

### 기반 세트와 겹치는 규칙

- **What happens:** `flutter_lints` 가 이미 켜는 규칙을 `lib/base.yaml` 에 다시 적는다.
- **Why it's wrong:** `[3/10]` 이 겹침을 실패로 본다 (2.0.0 에서 6개 제거 — `example/README.md` 「파일」 `example/lib/base_rules.dart` 행).
- **Do this instead:** 기반 세트에 없는 규칙만 적는다.

### 루트 `analysis_options.yaml` 에 이 패키지 조각 include

- **What happens:** 저장소 자체 분석에 `lib/` 조각을 끌어온다.
- **Why it's wrong:** 규칙 변경이 검증 스크립트 진단과 섞인다 (`analysis_options.yaml:4-5`).
- **Do this instead:** 루트는 `flutter_lints` 만 include 하고 `example/**` · `fixtures/**` 만 exclude 한다.

### 연습용 프로젝트에서 `flutter pub get`

- **What happens:** `flutter pub get` 이 옵션 파일에 `build/**` exclude 를 써넣는다.
- **Why it's wrong:** "include 한 줄" 이 깨져 `[4/10]` 실패 (`example/README.md` 「실행」 끝 문단).
- **Do this instead:** `dart pub get`; 돌렸으면 `git checkout -- example/analysis_options.yaml`.

### squash / rebase 병합, tag 옮기기

- **What happens:** `main` 병합을 squash 로 하거나 올린 tag 를 다른 커밋으로 옮긴다.
- **Why it's wrong:** tag 커밋이 `main` 이력에서 빠지거나 받는 쪽 lock 의 `resolved-ref` 와 어긋난다.
- **Do this instead:** `gh pr merge --merge`, 잘못 올린 tag 는 새 번호 (`VERSIONING.md` 릴리스 절차 5 · 9 · 10).

## Error Handling

- `invalid_annotation_target: ignore`, 생성 파일 exclude (`lib/codegen.yaml:5-9`).
- `tool/verify.dart`: plugin 준비 실패를 stderr 머리말 `An error occurred while executing an analyzer plugin:` 의 `contains` 로 판정 (`tool/verify.dart` `pluginFailureHeader`, spike 002 · 008). 실패 시 정답지를 쓰지 않는다.
- `tool/smoke.dart`: 어떻게 끝나도 임시 폴더 삭제, 출력의 임시 경로는 `<임시 폴더>` 로 가림 (`tool/smoke.dart:35-37`).

## Cross-Cutting Concerns

<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->

## Project Skills

| Skill | Description | Path |
|-------|-------------|------|
| spike-findings-woody-lints | woody_lints 의 spike 실측에서 나온 구현 설계도(implementation blueprint). 검증 명령(`tool/verify.dart`), `example/` 과 연습용 프로젝트 · 정답지, deprecated 규칙 검사, GitHub Actions CI 를 만들거나 고칠 때, 프리셋을 `base.yaml` / `riverpod.yaml` / `codegen.yaml` / `recommended.yaml` 로 나누거나 루트 `analysis_options.yaml` 의 exclude 를 고칠 때, 실제 사용 프로젝트(`flutter_starter_kit`)의 복사본에서 규칙 후보를 잴 때, Phase 4 의 평가표(`state` · 상류 세트 · 비호환 쌍 · 실측 건수 · `dart fix` 건수)를 채울 때, 진단 끄기 · 생성 파일 제외 · 설치와 버전 올리기(`ref:`, `pub get` / `pub upgrade`)를 문서로 안내할 때, 릴리스 smoke test 를 계획할 때, 고정 SDK(`.fvmrc`)를 Dart 3.14 계열로 올릴 때, runner 이미지가 바뀐 뒤 CI 가 실패했을 때 읽는다. `dart analyze` 실행 형태, analyzer plugin(`riverpod_lint`) 준비 실패 판정과 복구, 종료 코드, 상태 폴더(`ANALYZER_STATE_LOCATION_OVERRIDE`), include 로 받는 `plugins:`, `analyzer.exclude` 가 통하는 조건, git 의존성 · 다음 SDK(베타) · Ubuntu 26.04 runner 에서의 동작, `pubspec_overrides.yaml` 과 일부러 넣은 위반으로 사용 프로젝트를 재는 방식, `rules.json` 대신 `messages.yaml` 과 실제 분석으로 규칙 상태를 정하는 법, 언어 버전 3.13 에서만 도는 새 규칙, 무시 주석이 가리는 줄, `dart fix --apply` 로 고칠 수 있는 건수를 세는 법을 담았다. | `.claude/skills/spike-findings-woody-lints/SKILL.md` |
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
