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
- workflow 의 `runs-on: ubuntu-latest` 는 그대로 둔다. `ubuntu-latest` 는 2026-10-19 ~ 11-19 에 Ubuntu 26.04 로 옮겨 가고(actions/runner-images#14748), 그 이미지(`ubuntu-26.04` — 26.04.1 LTS · glibc 2.43 · 버전 20260927.149.1)에서 지금의 검증 명령 세 번과 연습용 프로젝트 여섯의 점검 여섯 번이 `ubuntu-24.04` 와 같은 결과였다. 옮겨 간 뒤 CI 가 실패하면 로그의 `Image` · `Version` 줄을 이 값과 견준다 (018)

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
- 시간이 문제가 되면 상태 폴더를 따로 둔 채 동시에 띄우는 것을 먼저 본다 — 로컬에서 여섯이 23초이고 결과가 같았다. GitHub runner 에서의 여섯은 014 가 재지 않았다 (추정 약 4분 20 ~ 30초 — 그 뒤 017 이 쟀다) (014)
- `path:` 의존성으로 잰 009 ~ 012 의 결과는 git 의존성(패키지가 pub cache 의 `git/<저장소 이름>-<커밋 해시>/` 에 놓인다)에서도 줄 단위로 같다 — 3단 include 의 plugin 로드, 옛 주소 · 묶음 주소의 정답지 일치, 조합별 진단, 생성 파일 제외의 모양. 연습용 프로젝트를 git 의존성으로 따로 두지 않는다. 받아 오는 길(GitHub 주소, 실제 tag)은 Phase 6 의 smoke test 가 본다 (015)
- 버전 올리기 안내는 받는 방식에 따라 다르게 적는다. tag 로 고정한 프로젝트는 `ref:` 를 고치고 `pub get`, `ref: main` 을 따르는 프로젝트는 `pub upgrade woody_lints` 다 — `ref: main` 의 `pub get` 은 lock 의 커밋에 머문다. `ref:` 만 고치고 `--enforce-lockfile` 을 돌리면 종료 코드 65 다 (015)
- 연습용 프로젝트 여섯을 지금의 방식(차례로, 상태 폴더는 프로젝트마다 따로)으로 돌려도 GitHub runner 의 `timeout-minutes: 10` 안에 넉넉히 든다. 처음 실행의 분석이 146 ~ 191초이고, 재실행을 뺀 job 이 약 3분 20초 ~ 4분 20초다 (spike 의 스크립트를 돌린 값이고 여섯으로 늘린 `tool/verify.dart` 가 아니다. 코어 4개, 표본 여섯, 2026-10-12). 014 의 추정(약 4분 20 ~ 30초)을 대신한다 (017)
- 한꺼번에 띄우면 runner 에서 분석이 69 ~ 95초로 약 절반이 된다 (로컬처럼 3분의 1 이 되지는 않는다). plugin 을 쓰는 넷이 plugin 쪽 패키지(`riverpod_lint`, `analyzer` 등)를 새 가상 머신의 pub cache 에 동시에 처음 받는 경우를 포함해 여섯 번 모두 결과가 같았다. 표본이 적어 "드물게 깨지는지" 는 알 수 없다. 차례로 돌려도 시간 제한에 여유가 있으므로 넣을지는 계획이 정한다 (017)
- 실제 사용 프로젝트(`flutter_starter_kit` 의 복사본, Dart 파일 468개)에서도 나누기 전후가 줄 단위로 같다 — 지금 받는 그대로(git, 1.3.0) = 한 파일 구조 = 나눈 구조(옛 주소) = 나눈 구조(묶음 주소). 프로젝트 자신의 코드는 지금 0줄이라 표식 파일(정답지 16줄)과, `always_specify_types` 를 더 켠 짝(9,398줄이 줄 단위로 같다)으로 확인했다 (019)
- 사용 프로젝트를 재는 실측은 복사본에 `pubspec_overrides.yaml` 로 `woody_lints` 를 작업 중인 파일의 경로로 돌리고, 같은 실행에 일부러 넣은 위반(표식 파일)을 둔다. 0줄을 표식 없이 해석하지 않는다 — `public_member_api_docs` 의 0줄은 규칙이 꺼져서가 아니었다. 그 규칙을 어기는 표식 둘이 같은 실행에서 2줄로 잡혔다 (019)
- `flutter_starter_kit` 의 진짜 생성 파일 62개는 제외가 하나도 없어도 진단이 0줄이다 (2026-10-12, Dart 3.13.4. 57개가 머리에 `ignore_for_file: type=lint` 를 달고 있고, 머리 없는 5개도 지금의 규칙에 걸리지 않는다. 머리를 단 57개의 0줄이 그 머리 때문인지는 가르지 않았다). 012 · 016 의 "프리셋의 제외가 통하지 않는 경우" 는 이 프로젝트에 지금 새 줄을 만들지 않는다. 규칙이 늘면 머리 없는 5개에서 줄이 날 수 있다 (019)
- 사용 프로젝트의 `dev_dependencies` 에 따로 적힌 `riverpod_lint` 줄은 `dart analyze` 의 진단에 영향이 없었다 — 있을 때와 뺐을 때가 같고, plugin 은 어느 쪽에서도 3.1.9 로 풀렸다 (2026-10-12, `flutter_starter_kit` 하나. 그 줄은 프리셋의 선언과 같은 `^3.1.3` 이고 lock 은 3.1.3 이다) (019)
- 비공개인 사용 프로젝트를 잰 기록에는 그 프로젝트의 경로 · 진단 메시지 · 코드 조각을 남기지 않고 건수와 규칙 이름만 남긴다. 소유자가 정한 것이 아니라 spike 가 스스로 건 조건이다 — Phase 4 의 근거 문서가 공개 저장소에 들어가므로 그 논의에서 확인한다 (019)

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
- 고정 SDK 를 Dart 3.14 계열로 올리기 전에 016 의 두 스크립트를 그 SDK 로 돌린다. `probe.dart` 의 `≠` 10칸 중 생성 파일 제외에서 온 8칸이 `=` 로 돌아오면 되돌리는 변경이 들어간 것이고 (루트 분석의 2칸 R1 · R2 는 다른 변경(sdk#63627)에서 온 것이라 `≠` 로 남을 것이다), 10칸 그대로면 정답지 셋을 갱신하며 "SDK 가 바뀌어 생긴 줄" 로 기록한다 (016)

### rule-reselection-measurement

Phase 4 (Rule Reselection) 가 `flutter_starter_kit` 복사본에서 후보 규칙을 재기 전에, 그 실측 방법이 기대는 도구 동작을 실행으로 확인한다. 021 ~ 023 은 ROADMAP.md Phase 4 의 "Spike first" 가운데 019 가 재지 않은 셋(Dart 3.13 의 새 규칙과 언어 버전, 이미 있는 `// ignore` 주석, `dart fix --dry-run`)이고, 셋째 항목(복사본이 작업 중인 파일을 가리키는지)의 나머지 — `path:` 가 작업 중인 저장소 자체를 가리킬 때 — 를 021 이 함께 본다. 020 은 앞선 spike 와 로드맵 문구가 부딪치는 자리다 — Phase 4 Notes 는 평가표의 `state` 열을 SDK tag 의 `rules.json` 에서 가져온다고 적었고, 005 는 그 파일이 실제 동작과 어긋난 규칙을 하나 찾았다. Phase 4 의 논의(`04-CONTEXT.md`)보다 먼저 돌린다.

**Requirements:**

소유자가 확정한 것 (2026-10-12, `/gsd-spike` 의 후보 선택).

- 네 개(020 ~ 023)를 Phase 4 의 논의보다 먼저 돌린다

spike 가 스스로 건 조건 (019 의 조건을 그대로 잇는다).

- `flutter_starter_kit` 원본은 읽기만 한다. 실측은 저장소 밖 작업 폴더의 복사본에서 한다 (PROJECT.md 의 Safety)
- 비공개 프로젝트를 잰 결과에는 건수와 규칙 이름만 남긴다 — 경로 · 진단 메시지 · 코드 조각을 남기지 않는다. 원본의 경로는 스크립트에 적지 않고 인자로 준다
- 저장소의 `lib/`, `example/`, `fixtures/`, `pubspec.yaml`, 루트 `analysis_options.yaml` 은 바꾸지 않는다. GitHub 에 올리지 않는다
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 하고, 스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다
- 결과는 어느 쪽이든 기록하고 계속한다. 복사본의 `pub get` 이나 분석이 작업 중인 저장소를 바꾸면 그 자리에서 멈춘다

spike 에서 나와 Phase 4 의 실측과 평가표가 지켜야 하는 것 (근거는 각 spike 의 README).

- 평가표의 `state` 열을 SDK tag 의 `rules.json` 에서 옮기지 않는다 — 상류가 같은 폴더의 README 에 "unsupported and deprecated, should not be relied on" 이라고 적었고, tag 3.13.4 의 그 파일은 `unnecessary_await_in_return` 을 stable 로 적었으며 `migrate_design_widgets` 를 빠뜨렸다. deprecated / removed / 없는 이름은 후보를 적은 옵션 파일을 저장소 하한(`^3.13.0`)의 pubspec 옆에서 분석해 정하고, stable / experimental / testing 은 tag 의 `pkg/linter/messages.yaml` 에서 읽는다. 출처끼리 갈리는 넷(`unnecessary_ignore`, `unnecessary_underscores`, `use_primary_constructors`, `migrate_design_widgets`)은 출처마다 적는다 (020)
- 상류 세트 열은 저장소 루트가 받은 `lints` · `flutter_lints` 의 YAML 에서 읽는다. `rules.json` 의 `sets` 는 262개 모두 비어 있다. 이름은 소문자로 맞춰 견준다 (`prefer_iterable_whereType`) (020)
- 비호환 쌍은 쌍마다 둘만 켜서 확인한다. 한 옵션 파일에 모두 켜면 규칙 한 줄에 `incompatible_lint` 가 하나만 붙어 일부 쌍(`unnecessary_final` × `prefer_final_locals` 등)이 가려진다. `rules.json` 이 선언한 12쌍은 따로 켜면 모두 보고된다 (020)
- `migrate_design_widgets` 와 `use_primary_constructors` 는 tag 3.13.4 의 원본에서 `testing` (안정성 보장 없음, 일반 사용을 권하지 않음)이다. 후보 표에 올릴 때 이 상태를 함께 적는다 (020. `use_primary_constructors` 는 규칙 소스도 `.testing` 이다 — 021)
- Dart 3.13 의 새 규칙 가운데 6개(`empty_container_bodies`, `unnecessary_type_name_in_constructor`, `unnecessary_const_in_enum_constructor`, `use_primary_constructors`, `initialize_in_field_declaration`, `use_declaring_parameters`)는 언어 버전 3.13 미만의 라이브러리에서 돌지 않는다 — `flutter_starter_kit` (`^3.11.1`)에서 그 규칙을 어기는 표식까지 0줄이다. 평가표에는 이 규칙들의 값을 둘 적는다: 지금 하한에서(0, 규칙이 돌지 않음)와 복사본의 하한만 `^3.13.0` 으로 올린 실행에서. `async_return_with_no_await`, `no_raw_types`, `no_dynamic_casts`, `strict-inference` 는 하한 3.11 에서도 돈다 (021)
- 하한을 올린 복사본으로 잴 때는 기준선도 하한을 올린 채 다시 잰다. 하한을 3.12 이상으로 올리는 것만으로 기반 세트의 `prefer_initializing_formals` 가 private named parameters 를 보기 시작해 `flutter_starter_kit` 에서 27줄이 생긴다 (021)
- 복사본의 `pubspec_overrides.yaml` 은 `path:` 로 작업 중인 저장소 자체를 가리킨다 — replica 를 만들지 않는다. 받은 자리(`package_config.json` 의 `rootUri`)가 저장소가 아니면 그 회차를 버리고, 실행 전후로 저장소의 지문(`git status`, `.dart_tool/` 의 맨 위 이름, 루트 `package_config.json` · `pubspec.lock`)을 견준다. 세 번의 `pub get` 과 분석 뒤에도 저장소는 그대로였다. 이 방법은 `021-new-rules-language-gate/consumer.dart` 에 있다 (021). `dart fix --dry-run` · `--apply` 도 저장소를 바꾸지 않는다 (022 의 `repo_guard.dart`)
- 복사본의 SDK 하한을 바꿀 때는 `pubspec.yaml` 을 고친 뒤 `pub get` 을 한다 (`Consumer.useSdk`). `pubspec.yaml` 만 고치면 `package_config.json` 의 `languageVersion` 이 앞의 값으로 남는다 (022)
- 평가표의 "`dart fix` 로 고칠 수 있는 건수" 는 소스를 원본으로 둔 복사본에서 그 규칙만 `dart fix --apply --code=<규칙>` 한 뒤 다시 분석해 **사라진 그 규칙의 줄 수**로 적고, apply 뒤 새로 생긴 다른 진단(특히 error)의 수를 함께 적는다. `--dry-run --code=` 의 수는 수정 수라서 사라지는 줄과 두 방향으로 다르다 (`always_put_required_named_parameters_first` 16 → 32줄, `comment_references` 10 → 100줄, `avoid_redundant_argument_values` 155 → 123줄). 규칙을 모두 켠 한 번의 dry-run 은 규칙끼리 섞여 쓰지 않는다. `rules.json` 의 `hasFix` 도 쓰지 않는다 — `hasFix` 인데 dart fix 가 고치지 않는 규칙이 있다 (`always_put_control_body_on_new_line` 398줄 → 0, `async_return_with_no_await`, `discarded_futures`, `prefer_foreach`, `unreachable_from_main`) (022)
- apply 가 코드를 깨뜨리는 규칙이 있다 — `diagnostic_describe_all_properties` (error 148), `always_specify_types` · `specify_nonobvious_local_variable_types` (`ambiguous_import` 등). `base.yaml` 의 규칙과 반대인 `prefer_double_quotes` · `unnecessary_final` 은 고친 만큼 반대 진단이 생긴다. dart fix 는 plugin 을 준비하지 않아 `riverpod_lint` 진단을 고치지 않는다 (022)
- `sort_pub_dependencies` 는 Dart 3.13.4 의 `dart fix` 로 고쳐지지 않는다 (tag 의 `rules.json` 은 `needsFix`, analysis_server 의 등록 없음, 사이트(`main`)는 `hasFix`) (022)
- 평가표의 값은 사용 프로젝트의 무시 주석을 둔 채로 잰다 (채택하면 실제로 받는 줄). 주석이 가린 줄은 따로 한 칸으로 적는다 — `flutter_starter_kit` 에서는 `lines_longer_than_80_chars` 260줄, `discarded_futures` 2줄이다. 로드맵의 "`cast_nullable_to_non_nullable` 56건" 은 생성 파일 안의 freezed 주석이라 아무것도 가리지 않는다 (그 규칙의 값은 5줄) (023)
- 기준선 0줄은 "무시 주석이 있는 채로 0" 이다. 손으로 쓴 파일 다섯 개가 `ignore_for_file: type=lint` 를 달아 lint 26줄(이 패키지의 `prefer_final_locals` 4줄 포함)을 가리고, 그 파일들은 어떤 lint 후보에도 보이지 않는다. 지금 아무것도 가리지 않는 낡은 주석(`avoid_print`, `use_build_context_synchronously`)이 있다 (023)
- `unnecessary_ignore` 는 켜져 있지 않은 규칙을 가리키는 주석도 보고한다 — 값이 다른 후보의 채택에 묶인다 (지금의 프리셋 기준 38줄, 세 후보를 함께 켜면 12줄). 다른 후보의 채택이 정해진 뒤에 다시 잰다 (023)

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
| 017 | preset-split-include-behavior | runner-six-fixtures | standard | 캐시 없는 GitHub Linux runner 에서 나눈 구조의 연습용 프로젝트 여섯을 차례로 · 한꺼번에 돌릴 때의 시간이 재어지고, 진단이 로컬과 같다 | ✓ VALIDATED | github-actions, ci, timing, fixture-layout, concurrency |
| 018 | verify-harness-tool-behavior | runner-next-image | standard | 다음 runner 이미지(`ubuntu-26.04`)에서 지금의 검증 명령과 연습용 프로젝트 여섯이 `ubuntu-24.04` 와 같은 진단을 내고 plugin 준비가 실패하지 않는다 | ✓ VALIDATED | github-actions, ci, runner-image, ubuntu-26, forward-compat |
| 019 | preset-split-include-behavior | real-consumer-split-invariance | standard | 실제 사용 프로젝트(`flutter_starter_kit`)의 복사본이 지금 받는 그대로 · 한 파일 구조 · 나눈 구조(옛 주소 · 묶음 주소)를 받을 때 진단이 줄 단위로 같다 | ✓ VALIDATED | real-consumer, include, analyzer-plugin, exclude, generated-files |
| 020 | rule-reselection-measurement | rule-state-vs-rules-json | standard | SDK tag 3.13.4 의 `rules.json` 에 있는 규칙 전부를 SDK 하한을 적은 패키지(`^3.13.0` · `^3.11.1`)의 옵션 파일에 적고 분석하면, `rules.json` 의 `state` 와 실제로 보고되는 상태가 어긋나는 규칙과 `incompatible_lint` 쌍이 확정된다 | ✓ VALIDATED (`rules.json` 을 그대로 옮기면 안 된다 — deprecated 하나가 틀렸고 `sets` 는 전부 비었다. 열마다 출처를 바꾼다) | rules-json, messages-yaml, deprecated-lint, rule-check, incompatible-lint |
| 021 | rule-reselection-measurement | new-rules-language-gate | standard | Dart 3.13 의 새 규칙과 strict 계열을 어기는 표식을 언어 버전 3.11 · 3.13 패키지와 `flutter_starter_kit` 복사본에서 분석하면, 규칙마다 언어 버전 3.11 에서 보고되는지가 확정된다 | ✓ VALIDATED (새 규칙 6개는 3.11 에서 돌지 않아 표식까지 0줄. 하한을 3.13 으로 올린 복사본에서는 수백 줄. 하한을 올리는 것만으로 `prefer_initializing_formals` 27줄) | language-version, linter-rules, strict-mode, real-consumer, marker, primary-constructors |
| 022 | rule-reselection-measurement | dart-fix-dry-run-count | standard | 후보 규칙을 켠 복사본에서 진단 건수, 묶음 · 단독 `dart fix --dry-run` 의 건수, 규칙 하나씩 `--apply` 한 뒤 남은 건수를 견주면, 평가표의 "`dart fix` 로 고칠 수 있는 건수" 를 세는 방법이 확정된다 | ✓ VALIDATED (규칙 하나씩 apply 해 사라진 줄로 센다 — dry-run 의 수는 수정 수이고 `hasFix` 는 등록 여부다. apply 가 error 를 남기는 규칙 셋) | dart-fix, fix-status, real-consumer, bulk-fix |
| 023 | rule-reselection-measurement | existing-ignore-comments | standard | `flutter_starter_kit` 복사본에서 `// ignore` 주석을 둔 채와 걷어낸 채로 지금의 프리셋과 후보 규칙을 분석하면, 주석이 숨기는 줄의 수와 주석의 출처(손으로 쓴 것 / 생성기)가 규칙별로 확정된다 | ✓ VALIDATED (`cast_nullable_to_non_nullable` 56건은 생성 파일의 freezed 주석. 기준선 0줄 안에 `type=lint` 파일 다섯이 lint 26줄을 가린다. 후보 가운데 가려지는 것은 `lines_longer_than_80_chars` 260줄 · `discarded_futures` 2줄) | ignore-comments, baseline, real-consumer, unnecessary-ignore, generated-files |
