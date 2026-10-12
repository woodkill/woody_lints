# Spike Manifest

## Ideas

### verify-harness-tool-behavior

Phase 2 (Verification Harness) 의 나머지를 계획하기 전에, 검증 명령(`tool/verify.dart`)과 CI 가 기대는 도구 동작 6가지를 실행으로 확인한다. 대상은 `dart analyze`, analyzer plugin(`riverpod_lint`), `pub get`, GitHub Actions runner 이고, 목록은 ROADMAP.md Phase 2 의 "Spike first" 다. 결과의 처리 기준은 02-CONTEXT.md D-15 를 따른다 — "정답지 비교로 판정한다"를 지킬 수 없다는 결과면 멈추고 소유자에게 돌아가고, 값이나 세부만 다른 결과는 기록하고 계속한다.

**Requirements:**

소유자가 이전에 확정해 이 spike 들이 그대로 따른 것 (출처는 02-CONTEXT.md).

- 판정의 주 수단은 정답지 비교다. spike 는 이를 뒤집지 않고 값과 세부를 확정한다 (D-15)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 `fvm dart …` 로 한다
- `lib/`, `pubspec.yaml` 은 바꾸지 않는다. 루트 `analysis_options.yaml` 은 기존 exclude 항목(`lib/analysis_options.yaml`)을 그대로 둔다 (spike 는 저장소의 이 파일들을 아예 고치지 않고 복사본에서 실험했다)
- 6가지의 결과는 모두 기록 문서로 남긴다 (D-15)
- 정답지 한 줄은 `상대경로:줄  강도  규칙이름`, 맨 위에 `exit N` (D-04) — spike 스크립트의 정규화가 이 형식을 따른다
- 검증 스크립트는 Dart 이고 `dart:io`, `dart:convert` 만 쓴다 (D-11)

spike 에서 나와 실제 구현이 지켜야 하는 것 (근거는 각 spike 의 README).

- `dart analyze` 는 `example/` 을 작업 디렉터리로 두고 **인자 없이**, **사용 통계 전송을 끈 채**(`--suppress-analytics`) 실행한다 (001)
- plugin 준비 실패는 종료 코드가 아니라 **stderr 의 머리말**(`An error occurred while executing an analyzer plugin:`)과 정답지의 빠진 줄로 알아챈다. 종료 코드 0 / 2 는 plugin 이 죽어도 나온다 (002)
- 검증에는 네트워크가 필요하다. plugin 이 이미 준비되어 있어도 pub 서버에 닿지 못하면 plugin 진단 없이 끝난다 (002)
- `riverpod_lint` 진단의 강도는 JSON 의 `severity` 로 읽는다. `type` 은 강도와 상관없이 전부 `STATIC_WARNING` 이고 `code` 에는 접두사가 없다 (003)
- 정답지에 넣을 plugin 진단은 코드 생성 없이 뜨는 5개 중에서 고른다. warning 하나(`missing_provider_scope`)와 info 하나(`avoid_public_notifier_properties`)를 넣으면 맨 위 줄이 `exit 2` 가 된다 (003)
- `example/` 의 패키지는 `dart pub get` 으로 받는다 (`--enforce-lockfile` 가능). `flutter pub get` 은 옵션 파일 맨 위에 `build/**` 제외를 써넣는다 (004)
- deprecated / removed 규칙 검사에 쓰는 배포 파일 복사본은 **저장소 안**에 둔다. `deprecated_lint` / `removed_lint` 는 그 파일이 속한 패키지의 pubspec SDK 하한이 해당 버전 이상일 때만 보고되고, pubspec 이 없는 임시 폴더에서는 보고되지 않는다 (005)
- CI 는 `actions/checkout@v7` + `subosito/flutter-action@v2` (`flutter-version-file: .fvmrc`) 로 SDK 를 맞추고, `~/.dartServer` 는 캐시하지 않는다. 정상 job 은 약 2분, 첫 분석은 약 43초다 (006)
- 루트 `analysis_options.yaml` 의 exclude 에 `example/**` 한 줄을 더한다 (기존 `lib/analysis_options.yaml` 제외는 그대로 둔다 — 02-CONTEXT.md 가 계획에 맡긴 항목). 더하지 않으면 루트 분석에 example 의 진단이 섞인다: 패키지를 받기 전에는 error 6건으로 exit 3, 받은 뒤에는 plugin 준비까지 일어나 exit 2. 이 제외는 `example/` 안에서의 분석을 건드리지 않는다 (007)
- 규칙 검사는 저장소 루트에서 **복사본 폴더를 인자로** 준다 (`dart analyze build/woody_rule_check`). 그 폴더의 진단만 나오고 plugin 을 준비하지 않으며 `example/` 의 상태에 기대지 않는다. 005 의 "루트에서 인자 없이"를 대신한다 (007)
- 검증 명령은 `example/` 을 분석할 때 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 **저장소 안의 전용 상태 폴더**를 준다. 실제 `riverpod_lint` 버전(D-07)은 그 폴더의 `.plugin_manager/*/pubspec.lock` 에서 읽는다. `dart:io` / `dart:convert` 에는 md5 가 없고, 기본 자리(`~/.dartServer`)에서는 폴더 내용으로도 파일 시각으로도 자기 폴더를 고를 수 없다 (008)
- stderr 의 머리말은 첫 줄이 아닐 수 있으므로 `contains` 로 찾는다. plugin 실패를 알릴 때 "전용 상태 폴더를 지우고 다시 실행"을 안내한다 — 컴파일된 plugin 파일이 깨진 채 남으면 지울 때까지 계속 실패한다 (008)

### preset-split-include-behavior

Phase 3 (Preset Split) 의 나머지를 계획하기 전에, 한 파일(`lib/analysis_options.yaml`)을 조각 셋(`base.yaml` / `riverpod.yaml` / `codegen.yaml`)과 묶음(`recommended.yaml`), 옛 주소의 한 줄짜리 별칭으로 나눈 구조가 기대는 도구 동작을 실행으로 확인한다. 009 ~ 012 는 ROADMAP.md Phase 3 의 "Spike first" 네 항목이고, 013 과 014 는 앞선 spike 끼리 맞물리는 자리(규칙 검사 005 × 007, 여러 연습용 프로젝트의 plugin 준비 006 × 008)다. 결과의 처리 기준은 03-CONTEXT.md 를 따른다 — 009 ~ 011 중 하나라도 통과하지 못하면 멈추고 소유자에게 돌아가고, 012 는 결과가 어느 쪽이든 기록하고 계속한다 (D-07).

**Requirements:**

소유자가 이전에 확정해 이 spike 들이 그대로 따르는 것 (출처는 03-CONTEXT.md, ROADMAP.md).

- 파일 이름은 `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml` 이고, `lib/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 한 줄짜리 별칭이다
- 조각은 서로를 include 하지 않는다. `base.yaml` 만 `flutter_lints` 를 include 하고 조합은 include 하는 쪽이 한다
- 나누는 것은 구조 변경이다. 규칙 목록 · 주석 처리된 줄 · 사유 주석은 옮기기만 한다 — spike 의 조각 파일은 저장소의 배포 파일을 **잘라서** 만들고 손으로 다시 쓰지 않는다
- `invalid_annotation_target: ignore` 와 생성 파일 제외 두 줄은 `codegen.yaml` 에 둔다 (D-02). `riverpod_lint` 선언은 범위 지정이다 (D-01)
- 실측은 저장소 복사본에서 한다. 저장소의 `lib/`, `pubspec.yaml`, 루트 `analysis_options.yaml`, `example/` 은 바꾸지 않는다
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 하고, 스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다
- pub workspace 와 Riverpod major 차이는 재지 않는다 (D-08)

## Spikes

| # | Idea | Name | Type | Validates | Verdict | Tags |
|---|------|------|------|-----------|---------|------|
| 001 | verify-harness-tool-behavior | analyze-invocation-form | standard | 패키지 루트에서 인자 없이 `dart analyze` 를 돌리면 plugin 진단이 cold·warm 모두 빠짐없이 나온다 | ✓ VALIDATED (조건: 사용 통계 전송을 끈다) | dart-analyze, analyzer-plugin, exit-code, analytics, flaky |
| 002 | verify-harness-tool-behavior | plugin-setup-failure-exit | standard | plugin 준비가 실패하고 다른 진단이 있을 때 `dart analyze` 의 종료 코드·stdout·stderr 가 확정된다 | ✓ VALIDATED | dart-analyze, analyzer-plugin, exit-code, stderr, offline |
| 003 | verify-harness-tool-behavior | riverpod-lint-severity-matrix | standard | `riverpod_lint` 규칙 15개의 강도·`code` 표기·종료 코드가 표로 확정된다 | ✓ VALIDATED | riverpod_lint, severity, exit-code, json |
| 004 | verify-harness-tool-behavior | fixture-pub-get | standard | `flutter pub get` / `dart pub get` 이 `analysis_options.yaml` 을 바꾸는지와 `dart pub get` 이 Flutter 프로젝트에서 되는지가 확정된다 | ✓ VALIDATED | pub-get, flutter-tool, analysis-options, lockfile |
| 005 | verify-harness-tool-behavior | initial-file-rule-status | standard | `unnecessary_await_in_return` 이 Dart 3.13.4 에서 deprecated 로 보고되는지가 확정된다 | ✓ VALIDATED | linter-rules, deprecated-lint, removed-lint, sdk-constraint |
| 006 | verify-harness-tool-behavior | github-runner-cold-plugin | standard | 캐시 없는 GitHub Linux runner 에서 plugin 진단이 로컬과 똑같이 나오고 첫 실행 시간이 측정된다 | ✓ VALIDATED | github-actions, ci, cold-start, analyzer-plugin, timing |
| 007 | verify-harness-tool-behavior | root-analysis-with-example | standard | 저장소 루트에 `example/` 이 있을 때 루트에서 인자 없이 돌린 `dart analyze` 에 example 의 진단과 plugin 준비가 섞이는지, 루트의 `example/**` 제외가 이를 막는지가 확정된다 | ✓ VALIDATED | dart-analyze, context-root, exclude, example, rule-check |
| 008 | verify-harness-tool-behavior | state-folder-placement | standard | md5 없이 실제 `riverpod_lint` 버전을 읽는 방법과, 같은 프로젝트를 두 Analysis Server 가 동시에 분석할 때 plugin 준비가 깨지는지가 확정된다 | ✓ VALIDATED | analyzer-plugin, state-folder, concurrency, md5, plugin-version |
| 009 | preset-split-include-behavior | preset-plugin-via-include | standard | 이름이 `analysis_options.yaml` 이 아닌 조각(`riverpod.yaml`)의 `plugins:` 가 include 경유로 로드되고, 조각 조합 넷이 한 파일로 둔 같은 내용과 같은 진단을 낸다 | ✓ VALIDATED | include, analyzer-plugin, preset, list-include |
| 010 | preset-split-include-behavior | alias-three-level-include | standard | 옛 주소 → 묶음 → 조각의 3단 include 에서 plugin 이 로드되고, 옛 주소와 묶음 주소가 둘 다 지금 정답지와 같은 진단을 낸다 | ✓ VALIDATED | include, analyzer-plugin, alias, depth |
| 011 | preset-split-include-behavior | root-analysis-after-split | standard | 나눈 구조에서 루트의 `lib/analysis_options.yaml` 제외를 걷어내도 루트 분석이 `plugins_in_inner_options` 없이 0건이고 plugin 을 준비하지 않으며, 연습용 프로젝트 폴더가 여럿이어도 섞이지 않는다 | ✓ VALIDATED | dart-analyze, context-root, exclude, plugins-in-inner-options |
| 012 | preset-split-include-behavior | plugin-suppression-matrix | standard | 규칙과 plugin 진단을 프로젝트 전체 / 파일 하나 / 한 줄에서 끄는 여섯 칸과 `analyzer.exclude` 가 각각 끈 것만 사라지게 하는지가 확정된다 | ⚠ PARTIAL (여섯 칸은 성립. 묶음이 주는 생성 파일 제외는 plugin 진단에 통하지 않는다) | analyzer-plugin, ignore, exclude, override |
| 013 | preset-split-include-behavior | rule-check-after-split | standard | 규칙이 `base.yaml` 로 옮겨 간 뒤의 규칙 검사에서 문제 규칙 셋과 깨진 입력 셋이 어떤 종료 코드와 진단으로 드러나는지가 확정된다 | PENDING | linter-rules, deprecated-lint, rule-check, broken-yaml |
| 014 | preset-split-include-behavior | multi-fixture-plugin-cost | standard | plugin 을 쓰는 연습용 프로젝트 넷을 차례로 돌릴 때의 시간과, 폴더마다 따로 두는 방식 대 작업 폴더 하나를 돌려 쓰는 방식의 차이가 재어진다 | PENDING | analyzer-plugin, timing, state-folder, fixture-layout |
