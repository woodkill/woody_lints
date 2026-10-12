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

spike 에서 나와 실제 구현이 지켜야 하는 것 (근거는 각 spike 의 README).

- 묶음(`recommended.yaml`)은 조각 셋을 `package:woody_lints/…` 주소의 목록으로 부르고, 옛 주소 파일은 `include: package:woody_lints/recommended.yaml` 한 줄이다. 이 3단 구조에서 plugin 이 로드되고 옛 주소 · 묶음 주소 둘 다 지금의 정답지(`exit 2` + 16줄)와 한 줄도 다르지 않다. 상대 경로로 불러도 결과가 같으므로 선례대로 `package:` 를 쓴다 (009, 010, 011)
- 연습용 프로젝트별 정답지의 모양: 기본만 `exit 2` · 18줄, 기본 + Riverpod `exit 2` · 21줄, 기본 + codegen `exit 0` · 13줄. "기본만" 이 `exit 0` 이 아닌 것은 `invalid_annotation_target` 이 warning 이라서다 (009)
- `riverpod_lint` 선언을 `^3.1.9` 로 올리는 커밋에서 정답지는 바뀌지 않는다 — 2026-10-12 에 `^3.1.3` 과 `^3.1.9` 가 둘 다 3.1.9 로 풀리는 동안의 사실이다 (010)
- 루트 `analysis_options.yaml` 의 `lib/analysis_options.yaml` 제외는 파일을 나누는 커밋과 **같은 커밋이거나 그 뒤**에 지운다. 한 파일 구조에서 먼저 지우면 `lib/analysis_options.yaml:58  warning  plugins_in_inner_options` 로 루트 분석이 exit 2 가 된다 (011)
- 새 연습용 프로젝트는 한 폴더 아래에 모으고 루트에서 `'<폴더>/**'` 한 줄로 제외한다. 기존 `example/**` 줄은 그대로 둔다. 제외하지 않으면 루트 분석에 그 폴더들의 진단이 섞이고 plugin 까지 준비한다 (011)
- 루트 옵션 파일은 묶음을 include 하지 않는다 — 분석마다 plugin 을 준비한다. `base.yaml` 은 include 해도 plugin 을 준비하지 않고 지금의 `tool/verify.dart` 에 새 진단이 0건이다 (011)
- 끄는 설정용 연습 프로젝트는 끈 자리 옆에 끄지 않은 같은 위반을 둔다. plugin 진단은 주석에 `riverpod_lint/` 접두사를 붙이고, 프로젝트 전체에서 끌 때는 `version` 을 함께 적는다. `version` 을 뺀 설정은 경고 없이 무시되고, `analyzer.errors` 로는 plugin 진단을 끌 수 없다 (012)
- **`codegen.yaml` 이 주는 생성 파일 제외는 규칙 진단에만 통하고 plugin 진단에는 통하지 않는다.** plugin 이 쓰는 `analyzer` 14.4.0 이상이 제외 패턴을 그것을 적은 파일의 폴더 기준으로 풀기 때문이고, 나누기 전(1.3.0)에도 같다. 사용 프로젝트가 자기 옵션 파일에 직접 적은 제외는 plugin 도 따른다. 성공 기준 3 의 "생성 파일의 진단이 보고되지 않는다" 는 규칙 진단에 대한 말로 읽는다 (012)
- 규칙 검사는 `base.yaml` · `codegen.yaml` · (`plugins:` 를 뺀) `riverpod.yaml` 을 `build/woody_rule_check/<조각 이름>/analysis_options.yaml` 로 복사해 한 번에 돌린다. 통과 조건은 "exit 0 이고 복사본의 진단이 0건" 이다. "규칙 0개" 확인은 `base.yaml` 에만 건다. 묶음과 별칭은 대상에 넣지 않는다 — 폴더를 인자로 준 분석에서는 include 를 거쳐 plugin 까지 준비한다 (013)
- 깨진 YAML 은 exit 3 인데 JSON 의 진단이 0건이고 stderr 도 비어 있다. 원인(`parse_error`)은 형식 인자 없이 돌린 출력에만 찍힌다. `linter:` 키의 오타는 아무 신호도 남기지 않는다 (013)
- 연습용 프로젝트는 폴더마다 따로 두고 상태 폴더도 프로젝트마다 따로 준다 (지금 검증 명령의 방식 그대로). 여섯이 로컬에서 처음 66초, 재실행 20 ~ 21초다. 상태 폴더를 하나로 합치면 plugin 폴더가 넷이 되어 버전을 읽지 못한다. plugin 준비는 경로가 다르면 나눠 쓰지 못한다 (014)
- 시간이 문제가 되면 상태 폴더를 따로 둔 채 동시에 띄우는 것을 먼저 본다 — 로컬에서 여섯이 23초이고 결과가 같았다. GitHub runner 에서의 여섯은 재지 않았다 (추정 약 4분 20 ~ 30초) (014)
- `path:` 의존성으로 잰 009 ~ 012 의 결과는 git 의존성(패키지가 pub cache 의 `git/<저장소 이름>-<커밋 해시>/` 에 놓인다)에서도 줄 단위로 같다 — 3단 include 의 plugin 로드, 옛 주소 · 묶음 주소의 정답지 일치, 조합별 진단, 생성 파일 제외의 모양. 연습용 프로젝트를 git 의존성으로 따로 두지 않는다. 받아 오는 길(GitHub 주소, 실제 tag)은 Phase 6 의 smoke test 가 본다 (015)
- 버전 올리기 안내는 받는 방식에 따라 다르게 적는다. tag 로 고정한 프로젝트는 `ref:` 를 고치고 `pub get`, `ref: main` 을 따르는 프로젝트는 `pub upgrade woody_lints` 다 — `ref: main` 의 `pub get` 은 lock 의 커밋에 머문다. `ref:` 만 고치고 `--enforce-lockfile` 을 돌리면 종료 코드 65 다 (015)

### next-sdk-forward-compat

Phase 3 이 지을 구조(조각 셋 · 묶음 · 옛 주소의 별칭)와 지금의 한 파일 구조(1.3.0)가 **다음 SDK** 에서도 같은 동작을 하는지, 정식 버전이 나오기 전에 베타로 미리 잰다. 조사 문서(`research/SUMMARY.md` § Gaps to Address)는 "include 된 파일의 `plugins:` 가 다음 SDK 에서도 허용되는가" 와 "Dart 3.14 의 `analyzer.exclude` 기준 디렉터리 변경" 을 이번 마일스톤에서 확인하지 않아도 되는 항목으로 두었다. 2026-10-01 에 Flutter 베타 `3.49.0-0.2.pre` 가 공개되어 실행으로 잴 수 있게 되었고, 소유자가 2026-10-12 에 재기로 골랐다. 결과는 기록이다 — 베타의 동작은 정식 버전에서 달라질 수 있고 이 패키지가 고칠 수 있는 것이 아니다. 구조를 바꿔야 한다는 결과가 나오면 멈추고 소유자에게 돌아간다.

**Requirements:**

소유자가 확정한 것 (2026-10-12, `/gsd-spike` 의 후보 선택).

- 베타 SDK 는 fvm 캐시(`~/fvm/versions`)에만 설치한다. `.fvmrc`, `.vscode/settings.json`, 저장소의 파일은 바꾸지 않는다
- GitHub 에는 아무것도 올리지 않는다

spike 가 스스로 건 조건.

- 같은 스크립트를 저장소 고정 SDK (Dart 3.13.4) 와 베타에서 각각 돌려 견준다. 고정 SDK 의 실행이 기준이다
- 베타의 `dart` 는 저장소 밖을 작업 디렉터리로 두고 스크립트의 절대 경로를 주어 띄운다 — 저장소 루트에서 `dart run` 을 하면 베타가 루트의 패키지를 다시 풀 수 있다
- 스크립트는 Dart 이고 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다

spike 에서 나와 실제 구현과 문서가 지켜야 하는 것 (근거는 spike 의 README. 베타 `3.14.0-211.1.beta` 한 빌드의 결과이고 정식 버전에서 달라질 수 있다).

- 구조(조각 셋 · 묶음 · 별칭)는 바꾸지 않는다. include 로 받는 `plugins:` 는 베타에서도 한 파일 구조 · 3단 별칭 · 묶음 · 조각 조합에서 모두 로드되고 진단의 내용이 같다 (016)
- "`codegen.yaml` 을 받으면 생성 파일의 진단이 보고되지 않는다" 는 Dart 3.13.x 의 사실로 적는다. 베타에서는 이 패키지가 주는 제외가 규칙 진단에도 통하지 않아 정답지 셋(옛 주소 · 묶음 16줄 → 20줄, 기본 + codegen 13줄 → 17줄)에 생성 파일 샘플의 4줄이 생긴다. 한 파일 구조(1.3.0)도 같다 (016)
- README 는 생성 파일 제외를 **사용 프로젝트의 옵션 파일에 직접** 적으라고 안내한다 — 두 SDK 에서 규칙과 plugin 을 모두 막는 방법은 이것 하나다. "프리셋의 제외가 통하지 않는다" 를 굳은 사실로 적지 않고 SDK 버전에 따라 다르다고 적는다. 상류가 `P1` 버그(sdk#64549)로 다루며 되돌리는 변경을 리뷰하고 있다 (2026-10-11) (016)
- 루트 옵션 파일의 주석과 문서에 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다. 베타에서는 `lib/analysis_options.yaml` 이 `plugins:` 에 닿는 한 루트 분석이 plugin 을 준비하고(0.5초 → 10초, 진단은 0줄) 루트의 제외로 막지 못한다. `plugins_in_inner_options` 는 베타에서 나오지 않는다 (016)
- 연습용 프로젝트 폴더를 루트에서 제외하는 방식은 베타에서도 통한다 — 제외한 폴더는 plugin 을 준비시키지 않는다 (016)
- 지금 규칙 12개는 베타에서 deprecated / removed 가 아니다 (pubspec 의 SDK 하한을 `^3.14.0` · `^3.99.0` 으로 올려도 0건) (016)
- plugin 진단 확인은 베타에서도 `dart analyze` 로 한다. 베타의 `flutter analyze` 는 plugin 진단을 내지만 규칙 진단을 겹쳐 세고 그 수가 실행마다 달랐다 (016)
- 고정 SDK 를 Dart 3.14 계열로 올리기 전에 016 의 두 스크립트를 그 SDK 로 돌린다. `≠` 가 0칸이면 되돌리는 변경이 들어간 것이고, 10칸이면 정답지 셋을 갱신하며 "SDK 가 바뀌어 생긴 줄" 로 기록한다 (016)

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
| 013 | preset-split-include-behavior | rule-check-after-split | standard | 규칙이 `base.yaml` 로 옮겨 간 뒤의 규칙 검사에서 문제 규칙 셋과 깨진 입력 셋이 어떤 종료 코드와 진단으로 드러나는지가 확정된다 | ✓ VALIDATED | linter-rules, deprecated-lint, rule-check, broken-yaml |
| 014 | preset-split-include-behavior | multi-fixture-plugin-cost | standard | plugin 을 쓰는 연습용 프로젝트 넷을 차례로 돌릴 때의 시간과, 폴더마다 따로 두는 방식 대 작업 폴더 하나를 돌려 쓰는 방식의 차이가 재어진다 | ✓ VALIDATED | analyzer-plugin, timing, state-folder, fixture-layout |
| 015 | preset-split-include-behavior | git-dependency-preset-load | standard | 나눈 구조를 `path:` 가 아니라 git 의존성으로 받아도(패키지가 pub cache 에 놓여도) plugin 이 로드되고 옛 주소 · 묶음 주소가 지금 정답지와 같으며, 생성 파일 제외의 모양이 `path:` 때와 같다 | ✓ VALIDATED | git-dependency, pub-cache, include, analyzer-plugin, lockfile |
| 016 | next-sdk-forward-compat | next-sdk-forward-compat | standard | Flutter 베타 3.49.0-0.2.pre 에서 include 로 받는 `plugins:` 가 로드되는지, `codegen.yaml` 의 제외가 규칙 진단에 여전히 통하는지, 지금 규칙 12개 중 새로 deprecated 된 것이 있는지가 확정된다 | ⚠ PARTIAL (plugin 로드와 규칙 12개는 그대로. 이 패키지가 주는 생성 파일 제외는 베타에서 규칙 진단에도 통하지 않는다 — 상류에서 되돌리는 중) | beta-sdk, forward-compat, include, analyzer-plugin, exclude, deprecated-lint, plugins-in-inner-options |
