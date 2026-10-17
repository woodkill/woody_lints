---
last_mapped_commit: 8ac96b71e9d394c5d1dfb132814ee87379519c69
last_mapped_at: 2026-10-17
---
# Coding Conventions

**Analysis Date:** 2026-10-17

이 저장소는 설정 전용 패키지(configuration-only package)다. 배포 산출물은 `lib/` 의 YAML 다섯(`lib/base.yaml` · `lib/codegen.yaml` · `lib/riverpod.yaml` · `lib/recommended.yaml` · `lib/analysis_options.yaml`)이고, Dart 코드는 검증 · 측정 도구 `tool/verify.dart` · `tool/smoke.dart` · `tool/measure_rules.dart` 와 연습용 프로젝트(`example/lib/`, `fixtures/*/lib/`)에만 있다. `lib/` 에 `.dart` 파일을 두지 않는다 — 검증 `[1/10]` 이 실패한다 (`tool/verify.dart` 4행).

## Naming Patterns

**Files:**
- 배포 YAML 은 `lib/<이름>.yaml` 이고 이름이 곧 공개 주소다 (`package:woody_lints/<이름>.yaml`). 조각(fragment) 셋 `base` · `riverpod` · `codegen`, 묶음(bundle) `recommended`, 옛 주소 별칭 `analysis_options` (`lib/analysis_options.yaml` 1-4행, `lib/recommended.yaml` 1-7행).
- `lib/analysis_options.yaml` 의 이름 · 위치는 바꾸지 않는다 — 사용 프로젝트가 이 주소로 include 한다. 내용은 `include: package:woody_lints/recommended.yaml` 한 줄뿐이어야 한다 (`[3/10]` 이 "include 만 담는지" 견줌, `tool/verify.dart` 6행).
- 문서는 대문자 이름: `README.md`, `RULES.md`, `VERSIONING.md`, `CHANGELOG.md`, `example/README.md`.
- Dart 도구 파일은 snake_case: `tool/verify.dart`, `tool/smoke.dart`, `tool/measure_rules.dart`.
- 연습용 샘플 파일은 `<분류>_rules.dart` 꼴: `example/lib/style_rules.dart`, `example/lib/bug_prevention_rules.dart`, `example/lib/performance_rules.dart`, `example/lib/strict_rules.dart`, `example/lib/riverpod_rules.dart`. 생성 파일 샘플은 `example/lib/generated/sample.g.dart` · `sample.freezed.dart`.
- 연습용 프로젝트 폴더는 받는 조합 이름: `fixtures/base_only/`, `fixtures/base_riverpod/`, `fixtures/base_codegen/`, `fixtures/recommended/`, `fixtures/overrides/`.
- 측정 결과는 `tool/measurements/<YYYY-MM-DD>-<run id>.json` (예: `tool/measurements/2026-10-13-R1.json`, 규칙은 `tool/measure_rules.dart` 머리 주석 `--out`).

**Functions (Dart, `tool/*.dart`):**
- lowerCamelCase. 대부분 동사로 시작한다: `checkLibHasNoDart`, `checkRuleNames`, `checkShippedComposition`, `compareFixture`, `ensurePinnedSdk`, `runPubGet`, `readPluginVersion`, `scrubPaths`, `normalizeDiagnostics`, `writeExpected`, `formatStepLine`, `quit` (`tool/verify.dart` 485-3066행).
- 단계 하나는 `check…` 이름으로 `StepResult` 를 돌려준다 (`checkLibHasNoDart` 819행, `checkFixtureOptions` 1382행, `checkShippedComposition` 2401행).
- 값을 돌려주는 순수 함수 일부는 명사형이다: `fencedLines`, `significantLines`, `pluginFolders`, `declaredRuleNames`, `yamlRuleNames`, `sameLines`. 새 함수는 사용자 전역 지침대로 동사로 시작한다 (`read…`, `check…`, `format…`).

**Variables / constants:**
- top-level 상수도 lowerCamelCase (`pluginFailureHeader`, `fixtures`, `createTimeout`, `pubGetTimeout`, `analyzeTimeout` — `tool/verify.dart` 52-55행, `tool/smoke.dart` 117-123행). SCREAMING_CASE 는 쓰지 않는다.

**Types:**
- UpperCamelCase 클래스: `Fixture`, `Expected`, `StepResult`, `SdkInfo`, `PluginVersion`, `AnalyzeOutcome`, `MarkerBlock` (`tool/verify.dart`).

**YAML 키 · 규칙 이름:**
- 규칙 이름은 Dart 공식 이름(snake_case) 그대로 (`lib/base.yaml`).

## Code Style

**Formatting:**
- YAML 은 2칸 들여쓰기 (`lib/base.yaml`, `pubspec.yaml`, `.github/workflows/verify.yml`).
- Dart 는 `dart format` 기본 스타일로 보인다 (추론 — 포맷 설정 파일은 없고 `formatter:` 키도 없다).
- YAML / Markdown 용 포맷터 · 린터 설정은 없다.

**Linting (이 저장소 자체):**
- 루트 `analysis_options.yaml` 은 `include: package:flutter_lints/flutter.yaml` 만 받는다. 이 패키지의 조각을 include 하지 않는다 — 규칙 변경이 도구 스크립트의 진단과 섞이지 않게 하려는 것 (`analysis_options.yaml` 1-6행).
- `analyzer.exclude` 로 `example/**` · `fixtures/**` 를 뺀다 — 일부러 규칙을 어긴 연습용 프로젝트라서 (`analysis_options.yaml` 8-12행). 루트에서 `lib/` 를 exclude 하지 않는다.

**Linting (배포 규칙 — 사용 프로젝트가 받는 것):**
- 기반 세트: `lib/base.yaml` 5행 `include: package:flutter_lints/flutter.yaml` (`pubspec.yaml` 의 `flutter_lints: ^6.0.0`).
- 추가 규칙 87개 남짓을 네 분류 주석 아래 둔다: `# 성능`, `# 가독성 및 스타일`, `# 버그 방지`, `# strict — …` (`lib/base.yaml`). 정확한 목록과 켠 이유는 `RULES.md` 「켠 규칙」(`woody:enabled-rules` 구역).
- `analyzer.errors` / `analyzer.exclude` 는 `lib/codegen.yaml` 에만 (`invalid_annotation_target: ignore`, `'**/*.freezed.dart'`, `'**/*.g.dart'`).
- analyzer plugin 은 `lib/riverpod.yaml` 의 최상위 `plugins:` 에만 (`riverpod_lint: ^3.1.9`). `analyzer: plugins:` 는 쓰지 않는다 — riverpod_lint 3.x 에서는 아무것도 로드하지 않는다 (`lib/riverpod.yaml` 2행).

## 규칙 추가 · 변경 절차 (Prescriptive)

근거: `README.md` 「이 저장소를 고치는 사람에게」(382-388행), `lib/base.yaml` 3행 주석, `tool/verify.dart` 6행 (`[3/N]` 설명), `VERSIONING.md` 「판정 순서」 · 「CHANGELOG 항목 형식」.

1. 규칙은 `lib/base.yaml` 에만 적는다. 알맞은 분류 주석(`# 성능` · `# 가독성 및 스타일` · `# 버그 방지` · `# strict …`) 아래에 넣는다. `lib/codegen.yaml` · `lib/riverpod.yaml` 에 `linter:` 를 두면 `[3/10]` 이 실패한다 (`example/README.md` M35).
2. 같은 커밋에서 다음을 함께 고친다 — 어긋나면 `[3/10]` 이 실패한다 (`README.md` 385행):
   - `RULES.md` 「켠 규칙」 표 (`<!-- woody:enabled-rules:start -->` ~ `end`, 9-93행). 행의 첫 칸은 backtick 이름 하나.
   - `README.md` 「받는 규칙」의 표시 구역 `woody:readme-rules` (빈 줄 · `**분류**` 소제목 · `` - `이름` `` 불릿만 허용; 구역이 든 절의 구역 밖에 목록 줄을 두지 않는다 — `example/README.md` M43 · M44 · M74 ~ M77).
   - `CHANGELOG.md` 최상단 버전 항목 (규칙 추가는 minor, 「새로 생기는 경고」 칸 필수 — `VERSIONING.md` 45 · 54행).
   - 연습용 프로젝트 샘플과 정답지 (`fvm dart run tool/verify.dart --update` 로 갱신, `example/README.md` 「실행」). `example/lib/` 를 고치면 `fixtures/*/lib/` 복사본 다섯도 같이 고친다 (`example/README.md` 「연습용 프로젝트 여섯」).
3. 형식:
   - 목록 형식 `    - rule_name # 이유` 만 쓴다. 맵 항목(`- avoid_print: true`), 이름을 다음 줄로 넘긴 `-` 는 검증이 종료 코드 70 으로 멈춘다 (`example/README.md` M29 · M30). 따옴표로 감싼 이름은 읽지만 쓰지 않는다 (M27 · M28).
   - 줄 끝에 한국어 주석으로 켠 이유를 한 줄 적는다. "무엇" 보다 "왜" — 예: `prefer_const_constructors # … 성능 이득은 근거가 부족하다는 것이 Flutter 팀의 판단 (lints#205)` (`lib/base.yaml`).
   - 기반 세트(`flutter_lints` / `lints`)가 이미 켜는 규칙은 넣지 않는다 — `[3/10]` 이 겹침으로 실패한다 (M20).
4. 끄는 규칙: `lib/base.yaml` 에 주석 처리로 남기지 않는다(현재 주석 처리된 규칙 줄은 0). 대신 `RULES.md` 「켜지 않은 규칙」 표(`woody:disabled-rules` 구역)에 접두사 7종(`기반 세트` · `비호환` · `experimental`/`testing` · `v2 로 미룸 (RULES-NN)` · `deprecated`/`removed`/`없음` · `규칙이 돌지 않음` · `소유자 결정`) 또는 `보류` 로 시작하는 이유를 적는다 (`RULES.md` 105-119행).
5. 조각마다 받는 최상위 키는 닫힌 목록이다: `lib/base.yaml` 은 `include` · `linter` · `analyzer`, `lib/codegen.yaml` 은 `analyzer`(아래 `errors` · `exclude`), `lib/riverpod.yaml` 은 `plugins`(아래 `riverpod_lint`). `lib/recommended.yaml` · `lib/analysis_options.yaml` 은 `include` 만 (`README.md` 384행).
6. `riverpod_lint` 하한을 올릴 때 같은 커밋에서 고칠 자리 (`lib/riverpod.yaml` 5행 주석, `README.md` 388행):
   - `lib/riverpod.yaml` 의 `riverpod_lint:` 선언
   - `fixtures/overrides/analysis_options.yaml` 의 `version:` (`[4/10]` 이 견줌)
   - `README.md` 의 plugin 버전 예시 둘 (「조각마다의 설정」 · 「규칙 · plugin 진단 끄기」, 펜스 안 블록 꼴 · 키 글자 그대로 — `[3/10]` 이 견줌)
7. 릴리스 버전을 올릴 때는 `pubspec.yaml` `version:`, `CHANGELOG.md` 첫 줄 제목, `README.md` 의 `ref:` 예시 둘, 커밋된 lock 여섯(`example/pubspec.lock`, `fixtures/*/pubspec.lock` — `fvm dart pub get` 으로만)을 같은 커밋에서 고친다 (`VERSIONING.md` 「릴리스 절차」 140-141행, `README.md` 388행).
8. 새 규칙이 SDK 에서 실제로 도는지 판단할 때 `rules.json` 대신 `messages.yaml` 과 실제 분석을 쓴다 (프로젝트 skill `.claude/skills/spike-findings-woody-lints/references/rule-status-check.md`).

## Import Organization (Dart 도구)

**Order:**
1. `dart:` (`dart:convert`, `dart:io`)
2. 빈 줄
3. `package:` (`package:markdown/markdown.dart' as md`, `package:yaml/yaml.dart`) — `tool/verify.dart` 46-50행

**Path Aliases:**
- 충돌하는 이름은 prefix 로 받는다 (`as md`).

**의존성:**
- 도구가 쓰는 패키지는 `pubspec.yaml` 의 `dev_dependencies` (`markdown`, `yaml`) — 받는 쪽 의존성 그래프에 들어가지 않는다 (`pubspec.yaml` 18-25행). 그 밖에는 `dart:io` · `dart:convert` 만 쓴다.
- `include:` 대상 패키지(`flutter_lints`)는 `dependencies` 에 둔다 — `dev_dependencies` 는 사용 프로젝트에 전달되지 않는다 (`pubspec.yaml` 13-17행).
- `riverpod_lint` 는 `pubspec.yaml` 에 넣지 않는다. plugin 캐시(`~/.dartServer/.plugin_manager`)에서 해석된다.

## Error Handling (Dart 도구)

**종료 코드 규약 (sysexits 계열):**
- `tool/verify.dart` (머리 주석 26-31행, `example/README.md` 「검증 명령의 종료 코드」): `0` 모두 통과 / `1` 단계 실패 / `64` 사용법 오류(CI 에서 `--update` 포함) / `69` `pub get` 실패 / `70` 예외(`FormatException` · `FileSystemException` · `ProcessException`) / `78` 실행 중 SDK 가 `.fvmrc` 와 다름 / `255` `package:yaml` 의 `Error` (받지 않음).
- `tool/smoke.dart` (45행): `0` 통과 / `1` 판정 실패 / `64` 사용법 오류 외.
- 새 실패 종류를 더하면 같은 표에 행을 더한다.

**Patterns:**
- `main` 이 예외 종류별로 `on … catch` 해 `exitCode` 를 정하고 stderr 에 한국어 한 줄을 찍는다 (`tool/verify.dart` 3209-3221행).
- 읽지 못하는 입력은 건너뛰지 않고 멈춘다 (`FormatException` → 70). 문구에 파일 이름 · 행 번호 · 받는 꼴을 적는다 (`example/README.md` M29).
- 종료는 `quit(int code)` (`Future<Never>`, `tool/verify.dart` 523행)로 출력 flush 뒤 `exit`.
- 하위 명령 실패는 `exitCode` 와 stderr 를 같이 보여 준다 (`runPubGet` 613-633행).
- plugin 준비 실패는 stderr 의 `pluginFailureHeader` 문자열을 `contains` 로 판정한다 (첫 줄이 아닐 수 있음, spike 008 — `tool/verify.dart` 52-55행).
- 하위 명령에 시간 제한을 둔다 (`tool/smoke.dart` 117-123행: create 2분, pub get 5분, analyze 5분).

**경로 가리기 (비공개):**
- 다른 도구 출력의 저장소 절대 경로는 `<repo>` 로 가린다 — `scrubPaths` (`tool/verify.dart` 689-697행). smoke 는 임시 폴더를 `<임시 폴더>` 로 가리고, `--keep` 때만 경로를 찍는다 (`tool/smoke.dart` 37-39행).
- 화면 · 정답지에는 상대 경로만 쓴다 (`relativize` 600행, 정답지 `상대경로:줄`).

## Logging

**Framework:** `stdout` / `stderr` 직접 (`dart:io`). 로깅 패키지 없음.

**Patterns:**
- 결과(단계 줄, 차이)는 stdout, 진단 · 모드 안내(`버전 일치 검사:` 줄)와 오류는 stderr (`tool/verify.dart` 16-18행).
- 단계 줄은 `[i/N] 이름 … 결과` 꼴로 폭을 맞춰 찍는다 (`formatStepLine` 3001행, `measureWidth` 2984행).
- 차이는 `- `(사라진 줄) · `+ `(새로 생긴 줄)로 (`example/README.md` 「실행」).
- 사용 프로젝트에는 `avoid_print` (기반 세트)가 켜져 있다.

## Comments

**YAML 주석 (배포 파일):**
- 한국어로 쓴다. `lib/*.yaml` 다섯에 영어 주석은 없다 (확인: `lib/base.yaml`, `lib/codegen.yaml`, `lib/riverpod.yaml`, `lib/recommended.yaml`, `lib/analysis_options.yaml` 전문). 템플릿에서 온 주석은 커밋 "docs(lib): 배포 YAML 다섯의 머리 주석을 실제 구성에 맞게 — 템플릿 주석 삭제 …" 에서 지웠다 (`git log -- lib/base.yaml`).
- 파일마다 머리 주석 2-4줄: 이 파일이 무엇인지, 이것만 받는 주소(`package:woody_lints/<이름>.yaml`), 자세한 곳(README · RULES.md)의 안내 (`lib/base.yaml` 1-4행, `lib/codegen.yaml` 1-3행).
- 주석은 "왜" 를 적는다 — 예: `lib/riverpod.yaml` 2행(왜 최상위 `plugins:` 인가), `pubspec.yaml` 13-15행(왜 `dependencies` 인가), `analysis_options.yaml` 4-5행(왜 조각을 include 하지 않나).
- 함께 고칠 자리를 주석에 적는다 (`lib/riverpod.yaml` 5행, `lib/base.yaml` 3행).
- 실측 값에는 SDK 버전과 날짜를 붙인다 — 예: `pubspec.yaml` 25행 "(2026-10-16 복제본 실측)", `.github/workflows/verify.yml` 27행 "약 4분 7초 (… 2026-10-12 실측 run …)", `tool/verify.dart` 41행 "(2026-10-15 실측, Dart 3.13.4)".
- 결정의 출처를 괄호로 적는다 — spike 번호(`spike 014`), 리뷰 ID(`06-REVIEW.md IN-09`), 소유자 결정 ID(`G4-Q1`), 결정 ID(`D-10`).
- 한국어 문장에서 영어 식별자 뒤 조사는 한 칸 띄운다 ("`plugins:` 는", "riverpod_lint 3.x 는").

**Dart 도구 주석:**
- 파일 머리에 `//` 블록으로 목적 · 실행 명령 · 단계 · 종료 코드 · 만드는/지우는 폴더를 적는다 (`tool/verify.dart` 1-45행, `tool/smoke.dart` 1-50행, `tool/measure_rules.dart` 1-30행).
- 공개 top-level 선언에는 `///` 문서 주석 (`tool/verify.dart` 에 `///` 줄 619개). 첫 줄 요약, 빈 `///`, 근거 문단 순.
- 관련 선언은 `[이름]` 으로 가리킨다 (`tool/smoke.dart` 119-131행).

**연습용 샘플 주석:**
- 파일 머리 `//` 에 어떤 규칙을 어기는지와 예외 사유를 적고, 샘플마다 `/// \`규칙이름\` — 설명.` (`example/lib/style_rules.dart` 1-20행). "한 줄에서 규칙 하나만 걸리게 둔다".

## Function Design

**Size:** 단계 함수는 길다 (`checkShippedComposition` 2401-2779행). 판정 조각은 작은 helper(`readMarkerBlock`, `fencedLines`, `unquotedScalar`)로 나눈다.

**Parameters:** 문맥은 `String repoRoot` 첫 인자, 선택값은 named(`{String? tag}`, `{required String shownAs}`) (`tool/verify.dart` 865 · 2297행).

**Return Values:** 단계는 `StepResult` / `Future<StepResult>`, 읽기 실패 가능 값은 nullable(`List<String>?`, `MarkerBlock?`).

## Module Design

**Exports:** 각 `tool/*.dart` 는 단일 파일 스크립트이고 서로 import 하지 않는다. 공용 조각이 필요해도 파일 안에 둔다 (추론 — `tool/` 에 공용 라이브러리 파일 없음).

**Barrel Files:** 없음.

**배포 YAML 의 합성:** 묶음 `lib/recommended.yaml` 은 조각 셋을 `include:` 목록으로만 합치고, 별칭 `lib/analysis_options.yaml` 은 묶음 하나만 include 한다.

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

---

*Convention analysis: 2026-10-17*
