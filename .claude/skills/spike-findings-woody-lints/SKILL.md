---
name: spike-findings-woody-lints
description: woody_lints 의 spike 실측에서 나온 구현 설계도(implementation blueprint). 검증 명령(`tool/verify.dart`), `example/` 과 연습용 프로젝트 · 정답지, deprecated 규칙 검사, GitHub Actions CI 를 만들거나 고칠 때, 프리셋을 `base.yaml` / `riverpod.yaml` / `codegen.yaml` / `recommended.yaml` 로 나누거나 루트 `analysis_options.yaml` 의 exclude 를 고칠 때, 실제 사용 프로젝트(`flutter_starter_kit`)의 복사본에서 규칙 후보를 잴 때, Phase 4 의 평가표(`state` · 상류 세트 · 비호환 쌍 · 실측 건수 · `dart fix` 건수)를 채울 때, 진단 끄기 · 생성 파일 제외 · 설치와 버전 올리기(`ref:`, `pub get` / `pub upgrade`)를 문서로 안내할 때, 릴리스 smoke test 를 계획할 때, 고정 SDK(`.fvmrc`)를 Dart 3.14 계열로 올릴 때, runner 이미지가 바뀐 뒤 CI 가 실패했을 때 읽는다. `dart analyze` 실행 형태, analyzer plugin(`riverpod_lint`) 준비 실패 판정과 복구, 종료 코드, 상태 폴더(`ANALYZER_STATE_LOCATION_OVERRIDE`), include 로 받는 `plugins:`, `analyzer.exclude` 가 통하는 조건, git 의존성 · 다음 SDK(베타) · Ubuntu 26.04 runner 에서의 동작, `pubspec_overrides.yaml` 과 일부러 넣은 위반으로 사용 프로젝트를 재는 방식, `rules.json` 대신 `messages.yaml` 과 실제 분석으로 규칙 상태를 정하는 법, 언어 버전 3.13 에서만 도는 새 규칙, 무시 주석이 가리는 줄, `dart fix --apply` 로 고칠 수 있는 건수를 세는 법을 담았다.
---

<context>
## Project: woody_lints

idea key 는 넷이다.

**`verify-harness-tool-behavior`** — Phase 2 (Verification Harness) 의 나머지를 계획하기 전에, 검증 명령(`tool/verify.dart`)과 CI 가 기대는 도구 동작 6가지를 실행으로 확인한다. 대상은 `dart analyze`, analyzer plugin(`riverpod_lint`), `pub get`, GitHub Actions runner 이고, 목록은 ROADMAP.md Phase 2 의 "Spike first" 다. 결과의 처리 기준은 02-CONTEXT.md D-15 를 따른다 — "정답지 비교로 판정한다"를 지킬 수 없다는 결과면 멈추고 소유자에게 돌아가고, 값이나 세부만 다른 결과는 기록하고 계속한다.

9개(001 ~ 008, 018) 모두 VALIDATED 다. D-15 의 멈춤 조건에 해당한 것은 없다. 001 ~ 006 이 위의 6가지이고, 007 과 008 은 그 6개가 재지 않고 남긴 두 가지를 같은 idea 아래에서 잰 것이다 — `example/` 이 생긴 뒤의 저장소 루트 분석과 Analysis Server 상태 폴더의 자리. 018 은 Phase 2 가 끝난 뒤에 생긴 바깥의 변화를 같은 idea 아래에서 잰 것이다 — GitHub 이 `ubuntu-latest` 를 2026-10-19 부터 Ubuntu 26.04 로 옮긴다는 예고가 `verify` 의 실행에 붙어, 그 이미지를 직접 지정해 미리 돌렸다 (소유자 선택 2026-10-12).

**`preset-split-include-behavior`** — Phase 3 (Preset Split) 의 나머지를 계획하기 전에, 한 파일(`lib/analysis_options.yaml`)을 조각 셋(`base.yaml` / `riverpod.yaml` / `codegen.yaml`)과 묶음(`recommended.yaml`), 옛 주소의 한 줄짜리 별칭으로 나눈 구조가 기대는 도구 동작을 실행으로 확인한다. 009 ~ 012 는 ROADMAP.md Phase 3 의 "Spike first" 네 항목이고, 013 과 014 는 앞선 spike 끼리 맞물리는 자리(규칙 검사 005 × 007, 여러 연습용 프로젝트의 plugin 준비 006 × 008)다. 결과의 처리 기준은 03-CONTEXT.md 를 따른다 — 009 ~ 011 중 하나라도 통과하지 못하면 멈추고 소유자에게 돌아가고, 012 는 결과가 어느 쪽이든 기록하고 계속한다 (D-07).

9개(009 ~ 015, 017, 019) 중 여덟이 VALIDATED, 012 가 PARTIAL 이다. 멈춤 조건에 해당한 것은 없다 — 009 ~ 011 이 모두 통과했다. 012 는 끄는 방법 여섯 칸이 성립했고, 묶음이 주는 생성 파일 제외가 plugin 진단에 통하지 않는다는 것이 나왔다 (나누기 전의 1.3.0 도 같다). 015 는 "Spike first" 밖에서 구조를 짓기 전에 당겨 잰 것이다 (010 × 012 가 맞물리는 자리, 소유자 선택 2026-10-12) — 나눈 구조를 `path:` 가 아니라 git 의존성으로 받아도 결과가 줄 단위로 같았고, 통과하지 못했다면 009 ~ 011 과 같은 급의 멈춤 조건이었다.

017 과 019 도 "Spike first" 밖이다 (소유자 선택 2026-10-12). 017 은 006 × 014 가 맞물리는 자리 — 연습용 프로젝트 여섯을 GitHub runner 에서 차례로 · 한꺼번에 돌린 시간 — 이고 결과가 어느 쪽이든 기록하고 계속하는 항목이었다. 019 는 앞선 spike 가 한 번도 닿지 않은 대상 — 실제 사용 프로젝트 `flutter_starter_kit` 의 복사본 — 에서 나누기 전후를 견준 것이고, 한 파일 구조와 나눈 구조가 다르면 009 ~ 011 과 같은 급의 멈춤 조건이었다. 같았다.

**`next-sdk-forward-compat`** — Phase 3 이 지을 구조(조각 셋 · 묶음 · 옛 주소의 별칭)와 지금의 한 파일 구조(1.3.0)가 **다음 SDK** 에서도 같은 동작을 하는지, 정식 버전이 나오기 전에 베타로 미리 잰다. 조사 문서(`research/SUMMARY.md` § Gaps to Address)는 "include 된 파일의 `plugins:` 가 다음 SDK 에서도 허용되는가" 와 "Dart 3.14 의 `analyzer.exclude` 기준 디렉터리 변경" 을 이번 마일스톤에서 확인하지 않아도 되는 항목으로 두었다. 2026-10-01 에 Flutter 베타 `3.49.0-0.2.pre` 가 공개되어 실행으로 잴 수 있게 되었고, 소유자가 2026-10-12 에 재기로 골랐다. 결과는 기록이다 — 베타의 동작은 정식 버전에서 달라질 수 있고 이 패키지가 고칠 수 있는 것이 아니다. 구조를 바꿔야 한다는 결과가 나오면 멈추고 소유자에게 돌아간다.

1개(016)이고 PARTIAL 이다. 구조를 바꿔야 한다는 결과는 나오지 않았다 (멈춤 조건에 해당하지 않는다). include 로 받는 `plugins:` 의 로드와 지금 규칙 12개의 상태는 베타에서도 그대로이고, 이 패키지가 주는 생성 파일 제외가 베타에서는 규칙 진단에도 통하지 않았다. 재려던 것 밖에서, 베타의 저장소 루트 분석이 plugin 을 준비한다는 것이 나왔다.

**`rule-reselection-measurement`** — Phase 4 (Rule Reselection) 가 `flutter_starter_kit` 복사본에서 후보 규칙을 재기 전에, 그 실측 방법이 기대는 도구 동작을 실행으로 확인한다. 021 ~ 023 은 ROADMAP.md Phase 4 의 "Spike first" 가운데 019 가 재지 않은 셋(Dart 3.13 의 새 규칙과 언어 버전, 이미 있는 `// ignore` 주석, `dart fix --dry-run`)이고, 셋째 항목(복사본이 작업 중인 파일을 가리키는지)의 나머지 — `path:` 가 작업 중인 저장소 자체를 가리킬 때 — 를 021 이 함께 본다. 020 은 앞선 spike 와 로드맵 문구가 부딪치는 자리다 — Phase 4 Notes 는 평가표의 `state` 열을 SDK tag 의 `rules.json` 에서 가져온다고 적었고, 005 는 그 파일이 실제 동작과 어긋난 규칙을 하나 찾았다. Phase 4 의 논의(`04-CONTEXT.md`)보다 먼저 돌린다 (소유자 선택 2026-10-12). 결과는 어느 쪽이든 기록하고 계속하고, 복사본의 `pub get` 이나 분석이 작업 중인 저장소를 바꾸면 멈춘다 (spike 가 스스로 건 조건 — CONTEXT 가 아직 없다).

4개(020 ~ 023) 모두 VALIDATED 다. 멈춤 조건에 해당한 것은 없다 — 022 의 첫 실행에서 "저장소가 그대로다" 가 깨졌지만 원인은 실행 중에 다음 spike 의 폴더를 저장소 안에 만든 것이었고 (022 README 의 경위 — 저장소의 `.dart_tool/` · 루트 `package_config.json` · `pubspec.lock` 의 시각이 그대로였고, 대조로 복사본 쪽을 소거했다), 단계마다 지문을 견준 대조(`repo_guard.dart`)에서 복사본의 `pub get` · 분석 · `dart fix` 는 저장소를 바꾸지 않았다. 로드맵의 "규칙 메타데이터는 SDK tag 고정 `rules.json` 을 기준으로 삼는다" 는 그대로 쓸 수 없다는 것이 나왔다 (020). "기준선(1.3.0) 대비 차이" 의 기준선에는 조건이 붙었다 — 019 가 잰 0줄은 무시 주석이 있는 채의 0줄이고 (023), 복사본의 하한을 올려 잴 때는 기준선을 다시 잰다 (021).

Spike sessions wrapped: 2026-10-11 (001 ~ 006), 2026-10-11 (007 ~ 008), 2026-10-12 (009 ~ 014), 2026-10-12 (015 ~ 016), 2026-10-12 (017 ~ 019), 2026-10-12 (020 ~ 023)

실측 조건: Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64 (로컬) 와 GitHub Linux runner (006, 017, 018). 009 ~ 014 는 모두 로컬에서, 저장소의 모양을 작업 폴더에 복사한 replica 와 `path:` 의존성으로 쟀다. 015 는 그 replica 를 로컬 git 저장소로 만들어 git 의존성으로 받았다 (GitHub 에는 올리지 않았다). 016 은 같은 스크립트를 고정 SDK 와 베타(Flutter 3.49.0-0.2.pre / Dart 3.14.0-211.1.beta)로 각각 돌려 견줬다. 017 과 018 은 작업 브랜치를 한 번 올려(소유자 확인 뒤) 임시 workflow 로 쟀다 — 이미지 `ubuntu-24.04` (20261004.327.1) 와 `ubuntu-26.04` (20260927.149.1), 둘 다 코어 4개. 019 는 `flutter_starter_kit` 의 복사본을 로컬에서 쟀다 (원본은 읽기만 했다). 020 ~ 023 도 로컬이다 — 020 은 저장소 밖에 규칙만 적은 패키지를 만들고 SDK tag 3.13.4 의 상류 파일(`rules.json`, `messages.yaml`)과 견줬고, 021 ~ 023 은 `flutter_starter_kit` 의 복사본(Dart 파일 469개)에 프리셋을 나눈 **뒤**의 작업 중인 저장소를 `path:` 로 물려 쟀다. plugin 쪽에서 풀린 `analyzer` 는 14.5.0, `analysis_server_plugin` 은 0.3.24 다 (2026-10-12, 베타와 runner 에서도 같은 값). SDK 나 plugin 의 버전이 바뀌면 아래 내용은 다시 재야 한다.

**SDK 를 따로 적지 않은 사실은 고정 SDK (Dart 3.13.4) 의 것이다.** 베타에서 달랐던 것은 셋이다 (→ references/next-sdk-forward-compat.md).

- 저장소 루트의 분석이 plugin 을 준비하고, `plugins_in_inner_options` 가 나오지 않는다 (같은 상류 변경에서 온 것이다).
- 프리셋이 주는 생성 파일 제외가 규칙 진단에 통하지 않는다.
- `flutter analyze` 가 plugin 진단을 내지만 규칙 진단을 겹쳐 센다.
</context>

<requirements>
## Requirements

### `verify-harness-tool-behavior`

소유자가 이전에 확정해 spike 들이 그대로 따른 것 (출처는 02-CONTEXT.md).

- 판정의 주 수단은 정답지 비교다. spike 는 이를 뒤집지 않고 값과 세부를 확정한다 (D-15)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 `fvm dart …` 로 한다
- `lib/`, `pubspec.yaml` 은 바꾸지 않는다. 루트 `analysis_options.yaml` 은 기존 exclude 항목(`lib/analysis_options.yaml`)을 그대로 둔다 (spike 는 저장소의 이 파일들을 아예 고치지 않고 복사본에서 실험했다)
- 6가지의 결과는 모두 기록 문서로 남긴다 (D-15)
- 정답지 한 줄은 `상대경로:줄  강도  규칙이름`, 맨 위에 `exit N` (D-04) — spike 스크립트의 정규화가 이 형식을 따른다
- 검증 스크립트는 Dart 이고 `dart:io` · `dart:convert` 에 더해, YAML 대조에만 `package:yaml` 을 개발용 의존성(`dev_dependencies`)으로 쓴다 (D-11, 2026-10-15 G4-Q1)

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

### `preset-split-include-behavior`

소유자가 이전에 확정해 spike 들이 그대로 따른 것 (출처는 03-CONTEXT.md, ROADMAP.md).

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
- 실제 사용 프로젝트(`flutter_starter_kit` 의 복사본, Dart 파일 468개)에서도 나누기 전후가 줄 단위로 같다 — 지금 받는 그대로(git, 1.3.0) = 한 파일 구조 = 나눈 구조(옛 주소) = 나눈 구조(묶음 주소). 프로젝트 자신의 코드는 지금 0줄(무시 주석이 있는 채의 값 — 그 뒤 023)이라 표식 파일(정답지 16줄)과, `always_specify_types` 를 더 켠 짝(9,398줄이 줄 단위로 같다)으로 확인했다 (019)
- 사용 프로젝트를 재는 실측은 복사본에 `pubspec_overrides.yaml` 로 `woody_lints` 를 작업 중인 파일의 경로로 돌리고, 같은 실행에 일부러 넣은 위반(표식 파일)을 둔다. 0줄을 표식 없이 해석하지 않는다 — `public_member_api_docs` 의 0줄은 규칙이 꺼져서가 아니었다. 그 규칙을 어기는 표식 둘이 같은 실행에서 2줄로 잡혔다 (019)
- `flutter_starter_kit` 의 진짜 생성 파일 62개는 제외가 하나도 없어도 진단이 0줄이다 (2026-10-12, Dart 3.13.4. 57개가 머리에 `ignore_for_file: type=lint` 를 달고 있고, 머리 없는 5개도 지금의 규칙에 걸리지 않는다. 머리를 단 57개의 0줄이 그 머리 때문인지는 가르지 않았다). 012 · 016 의 "프리셋의 제외가 통하지 않는 경우" 는 이 프로젝트에 지금 새 줄을 만들지 않는다. 규칙이 늘면 머리 없는 5개에서 줄이 날 수 있다 (019)
- 사용 프로젝트의 `dev_dependencies` 에 따로 적힌 `riverpod_lint` 줄은 `dart analyze` 의 진단에 영향이 없었다 — 있을 때와 뺐을 때가 같고, plugin 은 어느 쪽에서도 3.1.9 로 풀렸다 (2026-10-12, `flutter_starter_kit` 하나. 그 줄은 프리셋의 선언과 같은 `^3.1.3` 이고 lock 은 3.1.3 이다) (019)
- 비공개인 사용 프로젝트를 잰 기록에는 그 프로젝트의 경로 · 진단 메시지 · 코드 조각을 남기지 않고 건수와 규칙 이름만 남긴다. 소유자가 정한 것이 아니라 spike 가 스스로 건 조건이다 — Phase 4 의 근거 문서가 공개 저장소에 들어가므로 그 논의에서 확인한다 (019)

### `next-sdk-forward-compat`

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

### `rule-reselection-measurement`

소유자가 확정한 것 (2026-10-12, `/gsd-spike` 의 후보 선택).

- 네 개(020 ~ 023)를 Phase 4 의 논의보다 먼저 돌린다

spike 가 스스로 건 조건 (019 의 조건을 그대로 잇는다).

- `flutter_starter_kit` 원본은 읽기만 한다. 실측은 저장소 밖 작업 폴더의 복사본에서 한다 (PROJECT.md 의 Safety)
- 비공개 프로젝트를 잰 결과에는 건수와 규칙 이름만 남긴다 — 경로 · 진단 메시지 · 코드 조각을 남기지 않는다. 원본의 경로는 스크립트에 적지 않고 인자로 준다
- 저장소의 `lib/`, `example/`, `fixtures/`, `pubspec.yaml`, 루트 `analysis_options.yaml` 은 바꾸지 않는다. GitHub 에 올리지 않는다
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 하고, 스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다
- 결과는 어느 쪽이든 기록하고 계속한다. 복사본의 `pub get` 이나 분석이 작업 중인 저장소를 바꾸면 그 자리에서 멈춘다

spike 에서 나와 Phase 4 의 실측과 평가표가 지켜야 하는 것 (근거는 각 spike 의 README).

- 평가표의 `state` 열을 SDK tag 의 `rules.json` 에서 옮기지 않는다 — 상류가 같은 폴더의 README 에 "unsupported and deprecated, should not be relied on" 이라고 적었고, tag 3.13.4 의 그 파일은 `unnecessary_await_in_return` 을 stable 로 적었으며 `migrate_design_widgets` 를 빠뜨렸다. deprecated / removed / 없는 이름은 후보를 적은 옵션 파일을 저장소와 같은 하한(`^3.13.0`)을 적은 pubspec 옆에서 분석해 정하고 (020 은 저장소 밖에 그런 패키지를 따로 만들었다), stable / experimental / testing 은 tag 의 `pkg/linter/messages.yaml` 에서 읽는다. 출처끼리 갈리는 넷(`unnecessary_ignore`, `unnecessary_underscores`, `use_primary_constructors`, `migrate_design_widgets`)은 출처마다 적는다 (020)
- 상류 세트 열은 저장소 루트가 받은 `lints` · `flutter_lints` 의 YAML 에서 읽는다. tag 3.13.4 의 `rules.json` 의 `sets` 는 262개 모두 비어 있다. 이름은 소문자로 맞춰 견준다 (`prefer_iterable_whereType`) (020)
- 비호환 쌍은 쌍마다 둘만 켜서 확인한다. 한 옵션 파일에 모두 켠 실행에서는 규칙 한 줄에 `incompatible_lint` 가 하나만 붙었고 일부 쌍(`unnecessary_final` × `prefer_final_locals` 등)이 보이지 않았다 (Dart 3.13.4, 실행 하나 — analyzer 가 한 줄에 하나만 알린다는 것은 그 결과로 세운 해석이다). `rules.json` 이 선언한 12쌍은 따로 켜면 모두 보고된다 (020)
- `migrate_design_widgets` 와 `use_primary_constructors` 는 tag 3.13.4 의 원본에서 `testing` (안정성 보장 없음, 일반 사용을 권하지 않음)이다. 후보 표에 올릴 때 이 상태를 함께 적는다 (020. `use_primary_constructors` 는 규칙 소스도 `.testing` 이다 — 021)
- Dart 3.13 의 새 규칙 가운데 6개(`empty_container_bodies`, `unnecessary_type_name_in_constructor`, `unnecessary_const_in_enum_constructor`, `use_primary_constructors`, `initialize_in_field_declaration`, `use_declaring_parameters`)는 언어 버전 3.11 의 라이브러리에서 돌지 않는다 — 연습용 패키지에서 6개 모두, `flutter_starter_kit` (`^3.11.1`) 의 복사본에서는 표식을 둔 넷(`empty_container_bodies`, `unnecessary_type_name_in_constructor`, `unnecessary_const_in_enum_constructor`, `use_primary_constructors`)이 그 규칙을 어기는 표식까지 0줄이다 (나머지 둘의 표식은 3.13 문법이라 지금 하한의 복사본에 넣지 않았다. 막는 조건이 primary constructor 기능이라 3.13 미만이면 꺼질 것이다 — 규칙 소스를 읽은 것이고 3.12 는 재지 않았다). 평가표에는 이 규칙들의 값을 둘 적는다: 지금 하한에서(0, 규칙이 돌지 않음)와 복사본의 하한만 `^3.13.0` 으로 올린 실행에서. `async_return_with_no_await`, `no_raw_types`, `no_dynamic_casts`, `strict-inference` 는 하한 3.11 에서도 돈다 (021)
- 하한을 올린 복사본으로 잴 때는 기준선도 하한을 올린 채 다시 잰다. 복사본의 하한을 `^3.13.0` 으로 올리는 것만으로 기반 세트의 `prefer_initializing_formals` 가 private named parameters 를 보기 시작해 `flutter_starter_kit` 에서 27줄이 생긴다 (Dart 3.12 에서 넓어진 동작이라 하한 3.12 에서도 생길 것이다 — CHANGELOG 와 규칙 소스를 읽은 추정이고, 3.12 하한은 재지 않았다) (021)
- 복사본의 `pubspec_overrides.yaml` 은 `path:` 로 작업 중인 저장소 자체를 가리킨다 — replica 를 만들지 않는다. 받은 자리(`package_config.json` 의 `rootUri`)가 저장소가 아니면 그 회차를 버리고, 실행 전후로 저장소의 지문(`git status`, `.dart_tool/` 의 맨 위 이름, 루트 `package_config.json` · `pubspec.lock`)을 견준다. 두 번의 `pub get` 과 세 번의 분석 뒤에도 저장소는 그대로였다. 이 방법은 `021-new-rules-language-gate/consumer.dart` 에 있다 (021). `dart fix --dry-run` 한 번과 `--apply --code=use_primary_constructors` 한 번도 저장소를 바꾸지 않았다 (022 의 `repo_guard.dart` — 022 의 본 실행은 지문 확인이 깨져 이것으로 다시 확인했다)
- 복사본의 SDK 하한을 바꿀 때는 `pubspec.yaml` 을 고친 뒤 `pub get` 을 한다 (`Consumer.useSdk`). `pubspec.yaml` 만 고치면 `package_config.json` 의 `languageVersion` 이 앞의 값으로 남는다 (022)
- 평가표의 "`dart fix` 로 고칠 수 있는 건수" 는 소스를 원본으로 둔 복사본에서 그 규칙만 `dart fix --apply --code=<규칙>` 한 뒤 다시 분석해 **사라진 그 규칙의 줄 수**로 적고, apply 뒤 새로 생긴 다른 진단(특히 error)의 수를 함께 적는다. `--dry-run --code=` 의 수는 수정 수라서 사라지는 줄과 두 방향으로 다르다 (`flutter_starter_kit` 복사본에서 단독 dry → 사라진 줄: `always_put_required_named_parameters_first` 16 → 32줄, `comment_references` 10 → 100줄, `avoid_redundant_argument_values` 155 → 123줄). 규칙을 모두 켠 한 번의 dry-run 은 규칙끼리 섞여 쓰지 않는다. `rules.json` 의 `hasFix` 도 쓰지 않는다 — `hasFix` 인데 단독 dry 가 0 인 규칙이 있다 (`always_put_control_body_on_new_line` 진단 398 · 단독 dry 0, `async_return_with_no_await`, `discarded_futures`, `prefer_foreach`, `unreachable_from_main` — apply 는 하지 않았다) (022)
- apply 가 코드를 깨뜨리는 규칙이 있다 — `flutter_starter_kit` 복사본에서 `diagnostic_describe_all_properties` (error 148), `always_specify_types` · `specify_nonobvious_local_variable_types` (`ambiguous_import` 등). `base.yaml` 의 규칙과 반대인 `prefer_double_quotes` · `unnecessary_final` 은 고친 만큼 반대 진단이 생긴다. dart fix 는 plugin 을 준비하지 않아 `riverpod_lint` 진단을 고치지 않는다 (022)
- `sort_pub_dependencies` 는 Dart 3.13.4 의 `dart fix` 로 고쳐지지 않는다 (돌린 것은 단독 dry 하나 — 진단 2 · 수정 0, apply 는 하지 않았다. 읽은 것: tag 의 `rules.json` 은 `needsFix`, analysis_server 의 등록 없음, 사이트(`main`)는 `hasFix`) (022)
- 평가표의 값은 사용 프로젝트의 무시 주석을 둔 채로 잰다 (채택하면 실제로 받는 줄). 주석이 가린 줄은 따로 한 칸으로 적는다 — `flutter_starter_kit` 에서는 `lines_longer_than_80_chars` 260줄, `discarded_futures` 2줄이다. 로드맵의 "`cast_nullable_to_non_nullable` 56건" 은 생성 파일 안의 freezed 주석이라 아무것도 가리지 않는다 (그 규칙의 값은 5줄) (023)
- 기준선 0줄은 "무시 주석이 있는 채로 0" 이다. `flutter_starter_kit` 의 손으로 쓴 파일 다섯 개가 `ignore_for_file: type=lint` 를 달아 lint 26줄(이 패키지의 `prefer_final_locals` 4줄 포함)을 가리고, 그 파일들은 어떤 lint 후보에도 보이지 않는다. 지금 아무것도 가리지 않는 낡은 주석(`avoid_print`, `use_build_context_synchronously`)이 있다 (023)
- `unnecessary_ignore` 는 켜져 있지 않은 규칙을 가리키는 주석도 보고한다 — 값이 다른 후보의 채택에 묶인다 (`flutter_starter_kit` 에서 작업 브랜치의 프리셋(2026-10-12, 나눈 뒤) 기준 38줄, 세 후보를 함께 켜면 12줄). 다른 후보의 채택이 정해진 뒤에 다시 잰다 (023)

### 읽을 때 헷갈리기 쉬운 것

- "인자 없이"는 **경로 인자**가 없다는 뜻이다. 연습용 프로젝트 분석의 실제 명령은 `dart --suppress-analytics analyze --format=json` 이고, 규칙 검사는 그 끝에 복사본 폴더 경로가 붙는다 (`… analyze --format=json build/woody_rule_check`).
- **"바꾸지 않는다" 는 spike 의 조건이다.** 세 idea 모두 spike 가 저장소의 파일을 고치지 않고 복사본에서 실험했다는 말이다 (셋째 idea 는 `.fvmrc` 와 `.vscode/settings.json` 도 건드리지 않았다). Phase 3 의 구현은 `lib/` 와 루트 `analysis_options.yaml` 을 바꾼다. 구현이 바꾸지 않는 것은 `example/` 의 샘플 소스와 정답지, `pubspec.yaml` 의 `version` 과 `dependencies`, `main` 이다 (03-CONTEXT.md).
- **루트 `analysis_options.yaml` 의 exclude 는 phase 에 따라 다르다.** Phase 2 는 기존 `lib/analysis_options.yaml` 줄을 그대로 두고 `example/**` 를 **더했다** (첫째 idea — 지금의 저장소가 이 모양이다). 나눌 때부터는 둘이 달라진다 (둘째 idea): `lib/analysis_options.yaml` 줄은 파일을 나누는 커밋이나 그 뒤의 커밋에서 **지우고** (먼저 지우면 안 된다), 새 연습용 프로젝트 폴더의 제외 한 줄은 그 폴더를 만드는 변경에서 함께 **더한다**. `include` 줄은 그대로다. 두 요구 사항은 때가 다를 뿐 부딪치지 않는다.
- **"지금의 정답지 (`exit 2` + 16줄)" 는 실제 `example/expected_diagnostics.txt` 다** (2026-10-12). example-project-and-expected-file.md 에 나오는 진단 4건은 spike 001 의 연습용 프로젝트 것이다.
- **정답지의 "N줄" 은 진단 줄만 센 것이다.** 파일은 `#` 로 시작하는 머리 주석, `exit N` 한 줄, 진단 줄의 순서이고, 머리 주석과 `exit N` 줄은 줄 수에 넣지 않았다. "맨 위 줄" 은 `exit N` 줄을 말한다.
- 연습용 프로젝트는 여섯이고 정답지는 다섯이다. 묶음을 받는 프로젝트가 `example/` 의 정답지와 견준다 (03-CONTEXT.md D-03).
- **"끈 자리 옆에 끄지 않은 같은 위반" 은 주석으로 끄는 칸의 이야기다.** 프로젝트 전체에서 끈 진단은 그 프로젝트의 모든 자리에서 사라지므로 옆자리 대조가 성립하지 않는다. spike 012 는 여섯 칸을 같은 규칙 · 같은 진단으로 실행을 바꿔 가며 쟀고, 한 프로젝트에 함께 담아 돌리지 않았다 (→ suppression-and-exclude.md 8번).
- 조각(fragment)은 `base.yaml` / `riverpod.yaml` / `codegen.yaml`, 묶음(bundle)은 `recommended.yaml`, 별칭(alias)과 옛 주소는 `lib/analysis_options.yaml` (`package:woody_lints/analysis_options.yaml`), 연습용 프로젝트는 fixture, 정답지는 expected / golden 파일이다. 프리셋(preset)은 이 패키지가 배포하는 옵션 파일을 통틀어 이르는 말이다. "묶음이 주는 생성 파일 제외", "`codegen.yaml` 이 주는 제외", "프리셋이 주는 제외" 는 같은 것 — `codegen.yaml` 에 적히는 `analyzer.exclude` 두 줄(나누기 전에는 `lib/analysis_options.yaml` 에 있다) — 을 가리킨다.
- references 안의 "→ N번" 은 그 문서의 `### N.` 절 번호다.
- **"고정 SDK" 는 `.fvmrc` 의 Flutter 3.47.5 / Dart 3.13.4, "베타" 는 빌드 하나(Flutter 3.49.0-0.2.pre / Dart 3.14.0-211.1.beta)다.** "다음 SDK" 는 Dart 3.14 계열을 말하고, 잰 것은 그 베타 하나다. 정식 3.14 는 재지 않았다.
- **둘째 idea 의 요구 사항에 남아 있는 "plugin 을 준비하지 않고" · "plugin 까지 준비한다" (011) 와 "규칙 진단에만 통하고" (012) 는 고정 SDK 에서 잰 말이다.** 고정 SDK 에서 일하는 동안에는 그대로 맞다. 셋째 idea 가 막는 것은 그것을 SDK 와 무관한 사실로 주석 · README 에 옮겨 적는 일이다.
- **셋째 idea 의 "정답지 셋" 은 016 이 잰 칸 셋(옛 주소, 묶음, 기본 + codegen)이다.** 연습용 프로젝트 여섯의 정답지 파일로 세면 달라진다 — 묶음은 `example/` 의 정답지를 함께 쓰고, 끄는 설정용 프로젝트는 재지 않았다 (→ next-sdk-forward-compat.md 3번).
- **"받는 쪽" 은 사용 프로젝트, "받아 오는 길" 은 실제 GitHub 주소 · tag · 인증이다.** 015 가 잰 것은 받은 **뒤**의 모양이고(로컬 git 저장소를 `git:` 로 받았다), 받아 오는 길은 Phase 6 의 smoke test 가 본다.
- **"009 ~ 012 의 결과는 git 의존성에서도 줄 단위로 같다" (015) 에서 git 으로 다시 잰 칸은 정해져 있다** — 옛 주소, 묶음 주소, `base.yaml` + `riverpod.yaml`, `base.yaml` 만, 묶음에서 Riverpod 조각을 뺀 것, 생성 파일 제외의 세 자리다. 끄는 방법 여섯 칸(012), 사슬을 끊은 모양과 가장자리(010), 저장소 루트의 분석(011)은 git 으로 다시 재지 않았다 (→ git-dependency-and-upgrade.md 2번 · Constraints).
- **"두 SDK 에서 규칙과 plugin 을 모두 막는 방법은 이것 하나다" (016) 는 README 가 안내할 방법을 하나로 한다는 뜻이다.** 실측에서 두 SDK 모두 막은 자리는 둘이다 — 사용 프로젝트의 옵션 파일에 직접 적은 것과, 사용 프로젝트 루트에 둔 파일을 include 로 부른 것. README 에 "유일한 방법" 으로 옮기지 않는다.
- **생성 파일 제외에는 축이 둘이다.** 규칙 진단 쪽은 SDK 에 든 analyzer 를, plugin 진단 쪽은 분석할 때마다 pub.dev 에서 풀리는 `analyzer` 를 따른다. "SDK 버전에 따라 다르다" 는 규칙 쪽의 말이고, plugin 쪽은 SDK 를 올리지 않아도 pub.dev 의 릴리스로 바뀔 수 있다 (→ next-sdk-forward-compat.md 3번 · 9번).
- **셋째 idea 의 "루트 분석이 plugin 을 준비하고(… 진단은 0줄)" 의 0줄은 Dart 파일이 없는 replica 의 값이다.** 016 의 replica 에는 `tool/verify.dart` 가 없었다. 실제 저장소의 루트를 베타로 분석한 것은 아니다. "루트의 제외로 막지 못한다" 도 잰 제외는 파일 하나(`lib/analysis_options.yaml`)이고 `lib/**` 로는 재지 않았다 (→ next-sdk-forward-compat.md 4번).
- **`R1` · `R2` 는 016 의 `probe.dart` 가 루트 분석을 본 두 칸이다** — `R1` 은 한 파일 구조에서 `plugins_in_inner_options` 가 나오는지, `R2` 는 나눈 구조에서 plugin 을 준비하는지. 007 의 `R2a` · `R3b` 와는 다른 실험이다.
- **"학습용 프로젝트" 는 사용 프로젝트 5개 가운데 `flutter_starter_kit` 을 뺀 넷이다** (`webtoon`, `toonflix`, `pomodoro`, `state` — Flutter 버전을 고정하지 않았고 Riverpod 과 코드 생성을 쓰지 않는다. 03-CONTEXT.md D-08, PROJECT.md). 이 skill 의 "연습용 프로젝트" (fixture — 저장소 안의 `example/` 과 그 형제들)와 다른 것이다.
- **날짜 없이 적은 "지금" 은 2026-10-12 의, 프리셋을 나누기 전의 저장소다** — `lib/analysis_options.yaml` 이 64행짜리 한 파일이고, 루트의 exclude 가 `lib/analysis_options.yaml` 과 `example/**` 이고, README 가 `flutter pub get` / `flutter pub upgrade woody_lints` 를 안내하던 때다. 넷째 idea 의 설계도(rule-evaluation-table.md)는 나눈 뒤에 쓰였다 — 거기서 나눈 뒤의 프리셋은 "작업 브랜치의 프리셋" 이라 부르고, "지금 하한" 은 사용 프로젝트의 `^3.11.1` 이다.
- **"조각" 은 프리셋 파일(`base.yaml` 등)을 말한다.** 스크립트에서 옮겨 쓸 코드는 "코드" 나 함수 이름으로 부른다.
- **둘째 idea 의 014 줄에 남아 있는 "추정 약 4분 20 ~ 30초" 는 그 아래의 017 두 줄이 대신한다.** 017 이 잰 값은 약 3분 20초 ~ 4분 20초다.
- **017 의 시간은 spike 의 스크립트를 runner 에서 돌린 값이다.** 여섯으로 늘린 `tool/verify.dart` 는 아직 없다. 요구 사항의 "재실행을 뺀 job 이 약 3분 20초 ~ 4분 20초" 는 잰 job 시간(4분 5초 ~ 5분 8초 — 처음 실행과 재실행을 함께 돈 값)에서 재실행 시간을 뺀 셈이고, 규칙 검사와 화면 출력은 들어 있지 않다 (→ ci-workflow.md 3번). 실제 값은 Phase 3 을 끝내기 전에 본다 (03-CONTEXT.md D-09).
- **018 의 "같은 결과" 는 이미지 버전 하나(`ubuntu-26.04` 20260927.149.1)에서 고정 SDK 로 본 것이다.** 이미지는 매주 새로 나온다. 옮겨 간 뒤의 실패를 "이미지 탓일 리 없다" 로 읽지 않고 로그의 버전을 견준다. Ubuntu 26.04 (runner 의 운영체제) 와 Dart 3.14 (SDK) 는 다른 축이다. 요구 사항의 "점검 여섯 번" 은 job 여섯 개다 — job 하나가 여섯 프로젝트를 처음 실행과 재실행으로 두 번 돈다. 그 이미지에서 통과한 검증 명령은 프로젝트 하나짜리 지금의 것이다.
- **"사용 프로젝트" 는 다섯이고 019 가 잰 것은 `flutter_starter_kit` 하나다.** 그날(2026-10-12)의 그 프로젝트에서 잰 수 — 파일 468개, 프로젝트의 줄 0, `always_specify_types` 9,374줄, plugin 이 3.1.9 로 풀린 것 — 는 프로젝트나 pub.dev 가 바뀌면 달라진다. "같다" 를 프로젝트의 줄로 본 것은 `always_specify_types` 한 규칙이고, 나머지는 표식 파일의 줄로 본 것이다.
- **019 에서 "복사본" 은 사용 프로젝트의 복사본(`consumer/`), "replica" 는 이 저장소 모양의 복사본, "표식 파일" 은 복사본에 일부러 넣은 `example/lib` 의 샘플, "프로젝트의 줄" 은 표식 파일의 것이 아닌 진단이다.** 요구 사항의 "프로젝트 자신의 코드는 지금 0줄" 은 프로젝트의 줄이 0 이라는 말이고, 그때의 16줄은 전부 표식 파일의 줄이다.
- **019 의 "지금 받는 그대로(git, 1.3.0)" 는 받아 오는 길을 잰 것이 아니다.** 평소의 pub cache 를 쓴 실행이라 그때 GitHub 에서 받았는지가 기록에 없다. 받아 오는 길(주소 · tag · 인증)은 여전히 Phase 6 의 smoke test 가 처음 본다. git 으로 받은 것은 한 파일 구조(1.3.0)이고, 나눈 구조는 `path:` 로 물렸다.
- **019 의 "진짜 생성 파일 62개는 제외가 하나도 없어도 0줄" 은 까닭을 가르지 않은 결과다.** `type=lint` 머리가 막은 것인지 걸릴 코드가 없었던 것인지는 모른다 (→ suppression-and-exclude.md 6번 끝). "프리셋의 제외가 통하지 않아도 괜찮다" 의 일반 근거로 쓰지 않는다.
- **019 의 "0줄을 표식 없이 해석하지 않는다" 에서 표식은 그 규칙을 어기는 것이어야 한다.** 기본 표식(정답지 16줄을 내는 샘플)은 `public_member_api_docs` 를 어기지 않아 그 규칙을 가르지 못했고, 문서 주석 없는 선언 둘을 따로 넣어서야 갈렸다 (→ real-consumer-measurement.md 3번).
- **"평가표" 는 ROADMAP.md Phase 4 성공 기준 1 의 "표 하나" 이고, 열은 Phase 4 Notes 가 고정한 여섯이다** (`state` / 심각도 / `fixStatus` / 실측 건수 / `dart fix` 가능 건수 / 상류 세트 포함 여부). 넷째 idea 가 출처를 정한 것은 심각도를 뺀 다섯과 비호환 쌍이다. 심각도 열은 재지 않았다. `fixStatus` 열을 `rules.json` 에서 채우면 "고치는 방법이 등록되어 있다" 는 뜻이 된다 (→ rule-evaluation-table.md 1번).
- **"지금 하한" 은 사용 프로젝트의 `^3.11.1` (언어 버전 3.11), "저장소 하한" 은 이 저장소의 `^3.13.0` 이다.** 넷째 idea 의 "언어 버전 3.13 에서만 도는 6개" 가 지금 하한에서 낸 0 은 "깨끗하다" 가 아니라 "규칙이 돌지 않았다" 다. deprecated 를 가르는 것도 저장소 하한의 패키지에서다 — 지금 하한에서는 3.13 에 deprecated 된 셋이 보이지 않는다.
- **"단독 dry" 는 `dart fix --dry-run --code=<규칙>`, "그룹 dry" 는 그룹 하나(022 의 `G1` ~ `G4`)의 규칙을 모두 켠 `dart fix --dry-run` 한 번 (022 의 README 는 "묶음 dry" 라고 적었다 — 이 skill 에서 "묶음" 은 `recommended.yaml` 이다), "apply" 는 소스를 원본으로 되돌리고 `--apply --code=<규칙>` 한 뒤 다시 분석한 것이다.** 022 의 표에서 "진단" 칸은 프로젝트의 줄과 표식 줄을 합친 수다 (`prefer_double_quotes` 20,353 = 20,345 + 8). 022 의 apply 는 스크립트가 고른 아홉 규칙뿐이고 `sort_pub_dependencies` 는 그 목록에서 밀려 apply 하지 않았다 — "고쳐지지 않는다" 의 근거는 단독 dry 0 과 `fix_internal.dart` 의 등록 없음이다 (→ rule-evaluation-table.md 8번).
- **"testing" 은 `analyzer` 14.5.0 의 `RuleState.testing` — 안정성 보장이 없고 일반 사용을 권하지 않는 상태다.** `rules.json` 에는 이 값이 없다 (`use_primary_constructors` 를 experimental 로 적었다).
- **규칙의 상태가 규칙 소스에 적혀 있는 것은 아니다.** `unnecessary_await_in_return` (005) 과 `use_primary_constructors` (021) 의 소스에는 있고 `unnecessary_ignore.dart` (020) 에는 없었다. 한 곳에서 읽는 출처는 `messages.yaml` 이다.
- **019 의 "기준선 0줄" 은 무시 주석이 있는 채의 값이다 (023).** 021 ~ 023 의 `B0` · `I0` 는 나눈 뒤의 작업 브랜치를 받은 값이고 019 의 `V0` (1.3.0) 와 같은 16줄 · 0줄이다. 손으로 쓴 파일 다섯 개의 `ignore_for_file: type=lint` 가 lint 26줄을 가리고, 그 파일들은 어떤 lint 후보에도 보이지 않는다. 지금 하한의 복사본으로 잰 후보의 값은 그 규칙의 줄 수 그대로지만, 하한을 올린 복사본에서는 기준선을 다시 잰다 (021 의 `prefer_initializing_formals` 27줄).
- **`flutter_starter_kit` 의 Dart 파일은 019 가 468개, 021 이 469개로 셌다** (같은 날, 세는 범위 같음. 022 · 023 의 README 의 469 는 021 의 값을 옮긴 것이다). 그 사이 프로젝트가 바뀌었는지는 확인하지 않았다. 줄 수를 견줄 때는 spike 마다의 값을 쓴다.
- **021 ~ 023 의 실행 id — 021 의 `B0` · `B1` · `B2`, 022 의 `G1` ~ `G4`, 023 의 `I0` ~ `I4` — 는 019 의 `V0` · `G2u` · `G3`, 016 의 `R1` · `R2` 와 다른 실험이다.** 특히 022 의 `G3` (`base.yaml` 과 비호환인 후보 둘의 그룹)와 019 의 `G3` (제외 두 줄을 빼고 `base` + `riverpod` 만 받은 실행)은 이름만 같다. 판정 id `K1` ~ `K7` 도 spike 마다 따로 매겼다 (`K5` 가 021 에서는 plugin 준비, 022 에서는 저장소 불변, 023 에서는 가린 표식).
- **넷째 idea 의 "받은 자리가 저장소가 아니면 그 회차를 버린다" 는 스크립트 전체가 멈추는 것으로 구현되어 있다** (`ensureRepoSource` 가 던지고 결과 파일을 쓰지 않는다). "저장소를 바꾸면 그 자리에서 멈춘다" 도 지문을 처음과 끝에서만 견주는 것으로 구현되어 있다 (→ rule-evaluation-table.md 9번).
- **넷째 idea 의 비공개 조건(건수와 규칙 이름만)도 spike 가 스스로 건 조건이다.** 둘째 idea 의 019 와 같다 — 소유자가 정한 것이 아니고, Phase 4 의 논의에서 확인한다. 021 ~ 023 의 결과 파일에도 사용 프로젝트에 관한 수와 설정값(Dart 파일 수, SDK 제약, 주석의 코드별 건수)이 들어 있다.

skill 밖 문서의 자리: MANIFEST.md 는 `.planning/spikes/MANIFEST.md`, 02-CONTEXT.md 와 02-VERIFICATION.md 는 `.planning/phases/02-verification-harness/`, 03-CONTEXT.md (Phase 3 의 D-NN 결정) 는 `.planning/phases/03-preset-split/`, ROADMAP.md · PROJECT.md · STATE.md 는 `.planning/`, PITFALLS.md · ARCHITECTURE.md · FEATURES.md (Phase 4 의 후보 표) · STACK.md · `research/SUMMARY.md` 는 `.planning/research/` 에 있다. D-NN 번호는 phase 마다 따로 매겨져 있다 — 첫째 idea 의 D-NN 은 02-CONTEXT.md, 둘째 idea 의 D-NN 은 03-CONTEXT.md 의 것이다. 셋째 idea 와 넷째 idea 에는 D-NN 이 없다 (소유자가 `/gsd-spike` 의 후보에서 고른 것이다. 넷째 idea 를 돌린 2026-10-12 에는 04-CONTEXT.md 가 아직 없다). 넷째 idea 에 나오는 "D13" 은 ROADMAP.md Phase 4 의 결정 지점(규칙별 채택 여부)이다. ROADMAP.md 의 Phase 5 · Phase 6 Notes 가운데 015 보다 앞서 적힌 문구는 git-dependency-and-upgrade.md 4번 · 5번에 짚어 두었다.
</requirements>

<findings_index>
## Feature Areas

| Area | Reference | Key Finding |
|------|-----------|-------------|
| `dart analyze` 실행과 결과 판정 | references/analyze-run-and-verdict.md | 프로젝트 폴더에서 인자 없이 `--suppress-analytics` 로, 저장소 안의 전용 상태 폴더를 **프로젝트마다 따로** 주고 돌린다. plugin 이 죽어도 종료 코드는 0 / 2 라서 stderr 에 머리말이 **들어 있는지**(`contains`)로 알아챈다. plugin 버전은 전용 상태 폴더의 `pubspec.lock` 에서 읽는다. plugin 을 선언하지 않는 조합에서는 plugin 폴더 0개가 정상이다. 깨진 `plugin.aot` 은 지울 때까지 계속 실패한다. 이 실행 형태는 베타에서도 통했다. `flutter analyze` 는 어느 SDK 에서도 쓰지 않는다 |
| `example/` 프로젝트와 정답지 | references/example-project-and-expected-file.md | `riverpod_lint` 15개는 info 3 / warning 11 / error 1 이다. 정답지에는 `missing_provider_scope` + `avoid_public_notifier_properties` 를 넣어 `exit 2` 로 만든다. 패키지는 `dart pub get` 으로 받는다. `example/` 을 만들 때 루트 옵션 파일에 `example/**` 제외를 함께 넣는다. 나눈 뒤에도 `example/` 은 옛 주소 한 줄을 그대로 둔다. 정답지 16줄은 Dart 3.13.4 의 것이다 — 베타에서는 생성 파일 샘플의 4줄이 더 나온다 |
| deprecated / removed / 없는 규칙 검사 | references/rule-status-check.md | 대상을 저장소 **안**에 `analysis_options.yaml` 이름으로 복사하고 루트에서 **그 폴더를 인자로** 분석한다 (0.5초, plugin 준비 없음). 나눈 뒤에는 조각 셋을 하위 폴더에 복사해 한 번에 돌리고 "exit 0 · 진단 0건" 으로 판정한다. 깨진 YAML 은 exit 3 인데 JSON 의 진단이 0건이고, `linter:` 의 오타는 "규칙 0개" 확인만 잡는다. 지금 규칙 12개는 베타에서 SDK 하한을 올려도 깨끗하다. 같은 방식으로 규칙 이름 275개를 거르면 deprecated 6 · removed 14 가 `messages.yaml` 과 같고 `rules.json` 과는 하나가 다르다 (020) |
| GitHub Actions CI | references/ci-workflow.md | `checkout@v7` + `flutter-action@v2` (`.fvmrc`) 만으로 캐시 없는 runner 에서 60번 중 60번 로컬과 같은 진단이 나왔다. 첫 분석 약 43초, job 약 2분, `timeout-minutes: 10`. 상태 폴더는 캐시하지 않는다. 연습용 프로젝트 여섯을 spike 의 스크립트로 차례로 돌리면 재실행을 뺀 job 이 약 3분 20초 ~ 4분 20초이고, 한꺼번에 띄우면 분석이 약 절반이다 (017). `runs-on: ubuntu-latest` 는 그대로 둔다 — `ubuntu-26.04` 이미지 하나(20260927.149.1)에서 지금의 검증이 같은 결과였다 (018). `.fvmrc` 를 올리는 커밋이 CI 의 SDK 를 올린다 |
| 프리셋 나누기 (조각 · 묶음 · 별칭) | references/preset-split-structure.md | 이름이 `analysis_options.yaml` 이 아닌 조각의 `plugins:` 가 include 로 로드되고, 옛 주소 → 묶음 → 조각의 3단에서 정답지가 한 줄도 달라지지 않는다. 조각은 배포 파일을 잘라 만들고 이어 붙여 원본과 견준다. 루트의 `lib/analysis_options.yaml` 제외는 나누는 커밋이거나 그 뒤에 지운다. 루트는 묶음을 include 하지 않는다. git 의존성으로 받아도 같고, 베타에서도 plugin 로드는 같다 — 다만 베타의 루트 분석은 plugin 을 준비한다 (진단은 0줄) |
| 나눈 뒤의 연습용 프로젝트 여섯 | references/fixtures-after-split.md | 정답지의 모양은 기본만 `exit 2` · 18줄, 기본 + Riverpod `exit 2` · 21줄, 기본 + codegen `exit 0` · 13줄이다. 새 프로젝트는 한 폴더 아래에 모아 루트에서 한 줄로 제외하고, 상태 폴더는 프로젝트마다 따로 준다. 여섯이 로컬에서 처음 66초, 재실행 20 ~ 21초, 동시에 띄우면 23초다. GitHub runner 에서는 차례로 146 ~ 191초, 동시에 69 ~ 95초이고 여섯의 진단이 로컬의 예상과 줄 단위로 같았다 (017). 줄 수는 Dart 3.13.4 의 것이고, git 의존성용 프로젝트는 따로 두지 않는다 |
| 진단 끄기와 생성 파일 제외 | references/suppression-and-exclude.md | 끄는 방법 여섯 칸(프로젝트 전체 / 파일 / 한 줄 × 규칙 / plugin)이 모두 끈 것만 사라지게 한다. plugin 진단은 주석에 `riverpod_lint/` 접두사, 옵션 파일에는 `version` 이 있어야 꺼진다 — `version` 을 빼면 경고 없이 무시된다. **프리셋이 주는 생성 파일 제외는 Dart 3.13.x 에서 규칙 진단에만 통하고, 베타에서는 규칙 진단에도 통하지 않는다** (1.3.0 도 같다). 두 SDK 에서 모두 막는 것은 사용 프로젝트의 옵션 파일에 직접 적은 제외다. 실제 사용 프로젝트의 생성 파일 62개에서는 제외가 어디에도 없어도 0줄이었다 (019 — 까닭은 가르지 않았다) |
| git 의존성으로 받기와 버전 올리기 | references/git-dependency-and-upgrade.md | 나눈 구조를 git 의존성으로 받아도(패키지가 pub cache 에 놓여도) plugin 이 로드되고 진단이 `path:` 때와 줄 단위로 같다. `ref: main` 프로젝트의 `pub get` 은 lock 의 커밋에 머물고 `pub upgrade woody_lints` 가 새 커밋을 받는다. `ref:` 를 고친 프로젝트는 `pub get` 으로 옮긴다. `ref:` 만 고친 채의 `--enforce-lockfile` 은 종료 코드 65 다. 사용 프로젝트의 `dev_dependencies` 에 적힌 `riverpod_lint` 줄은 진단에 영향이 없다 (019) |
| 다음 SDK (Dart 3.14 베타) 와 SDK 올리기 | references/next-sdk-forward-compat.md | 베타에서 include 로 받는 `plugins:` 와 규칙 12개는 그대로다. 달라진 것은 프리셋의 생성 파일 제외가 규칙 진단에도 통하지 않는 것(정답지에 4줄 — 상류가 되돌리는 중)과, 저장소 루트의 분석이 plugin 을 준비하고 `plugins_in_inner_options` 를 내지 않는 것(Dart 파일이 없는 replica 에서 0줄, 10초)이다. `.fvmrc` 를 올리기 전에 016 의 두 스크립트를 그 SDK 로 돌리고 `≠` 의 수가 아니라 칸의 내용을 읽는다 |
| 실제 사용 프로젝트의 복사본에서 재기 | references/real-consumer-measurement.md | `flutter_starter_kit` 의 복사본에서 지금 받는 그대로 · 한 파일 구조 · 나눈 구조(옛 주소 · 묶음 주소)의 진단이 줄 단위로 같다. 복사본의 `pubspec.yaml` 은 그대로 두고 `pubspec_overrides.yaml` 로 `woody_lints` 를 작업 중인 파일로 돌린 뒤 받은 자리를 `package_config.json` 으로 확인한다. 프로젝트의 줄은 무시 주석이 있는 채로 0 이다. 0줄은 그 규칙을 어기는 표식 파일 없이 해석하지 않는다. 비공개 프로젝트의 결과에는 건수와 규칙 이름만 남긴다. 나눈 뒤에는 `path:` 가 작업 중인 저장소 자체를 가리키고(replica 없음), 받은 자리가 저장소가 아니면 회차를 버리고(`ensureRepoSource`), 실행 전후로 저장소 지문을 견준다 (021 의 `consumer.dart`) |
| Phase 4 의 평가표 — 열마다 값을 얻는 법 | references/rule-evaluation-table.md | `state` 의 deprecated / removed 는 저장소 하한(`^3.13.0`)의 패키지를 분석해서, stable / experimental / testing 은 tag 의 `messages.yaml` 에서, 상류 세트는 저장소 루트가 받은 `lints` YAML 에서 — `rules.json` 은 쓰지 않는다. 비호환 쌍은 쌍마다 둘만 켠다. 새 규칙 6개는 지금 하한(언어 버전 3.11)에서 돌지 않아 값을 둘 적는다. 실측 건수는 무시 주석을 둔 채로 재고 가린 줄은 따로 적는다. `dart fix` 건수는 규칙 하나씩 apply 해 사라진 줄로 세고 새로 생긴 error 를 함께 적는다 — 단독 dry 의 수는 수정 수이고 `hasFix` 는 등록 여부다 |

## 어느 것을 읽을지

- `tool/verify.dart` 의 분석 실행, 상태 폴더, 종료 코드 해석, 실제 plugin 버전 표시(D-07), plugin 실패 안내 문구 → analyze-run-and-verdict.md
- `lib/` 의 파일을 나누는 일, 묶음과 별칭의 내용, plugin 하한을 올리는 커밋, 루트 `analysis_options.yaml` 의 include 와 exclude → preset-split-structure.md
- 새 연습용 프로젝트의 폴더 · 옵션 파일 · 정답지의 모양, 프로젝트가 여럿일 때의 상태 폴더와 시간, `fixtures/**` 제외 → fixtures-after-split.md
- 끄는 설정용 연습 프로젝트(PRESET-07)의 샘플과 옵션, README 의 "끄는 방법" · "생성 파일" 안내 (Phase 5) → suppression-and-exclude.md
- `example/` 의 파일 구성, 위반 코드, `pubspec.lock`, README 의 종료 코드 설명, `riverpod_lint` 규칙의 강도 → example-project-and-expected-file.md
- 저장소 루트에서 돌린 `dart analyze`(커밋 전 린터)에 뜻밖의 진단이 나올 때 → `example/` 의 것이면 example-project-and-expected-file.md 의 8번, `lib/analysis_options.yaml` 의 것이면 preset-split-structure.md 의 5번 · 6번 (루트의 `pub get` 을 했는지도 본다 — 같은 문서의 Constraints), 다른 연습용 프로젝트 폴더의 것이면 fixtures-after-split.md 의 4번
- 규칙 검사 단계(VERIFY-02)의 대상과 통과 조건, 깨진 옵션 파일의 신호, 규칙 후보 선정(Phase 4) → rule-status-check.md
- `.github/workflows/`, 자동 점검 시간(프로젝트 하나 · 여섯, 차례로 · 한꺼번에), `runs-on` 과 runner 이미지 → ci-workflow.md
- `ubuntu-latest` 가 Ubuntu 26.04 로 옮겨 간 뒤(2026-10-19 ~ 11-19) CI 가 실패했을 때 → ci-workflow.md 4번 (로그의 `Image:` · `Version:` 줄을 견준다)
- Phase 4 의 규칙 후보 실측 — `flutter_starter_kit` 의 복사본 만들기, `woody_lints` 를 작업 중인 파일로 돌리기, 일부러 넣은 위반, 회차 기록에 남길 것과 남기지 않을 것 → real-consumer-measurement.md (규칙의 deprecated / removed 상태를 거르는 일은 rule-status-check.md 7번)
- Phase 4 의 평가표 — 열마다의 출처, `rules.json` 을 쓰지 않는 까닭, 비호환 쌍과 후보의 그룹 나누기, 언어 버전 3.13 에서만 도는 규칙의 두 값, 하한을 올린 복사본의 기준선, 무시 주석이 가린 줄, `unnecessary_ignore` 의 값, `dart fix` 건수와 apply 가 깨뜨리는 규칙, 회차 기록의 확인 → rule-evaluation-table.md
- 후보 규칙의 `state` 를 `rules.json` · `messages.yaml` · dart.dev 사이트 가운데 어디서 읽을지, `testing` 상태, `use_super_parameters` 가 experimental 인데 기반 세트에 있는 것 → rule-evaluation-table.md 3번
- "나눠도 실제 사용 프로젝트에 보이지 않는다" 의 근거, 사용 프로젝트의 `dev_dependencies` 의 `riverpod_lint` 줄, 실제 생성 파일에서 제외를 넣고 뺀 결과 → real-consumer-measurement.md 5번 (README 에 옮길 말은 git-dependency-and-upgrade.md 4번, suppression-and-exclude.md 7번)
- README 의 설치 · 버전 올리기 · `ref: main` 에서 tag 로 옮기기 안내 (Phase 5), 릴리스의 `main` 병합이 사용 프로젝트에 닿는 때와 smoke test 가 볼 것 (Phase 6), git 의존성을 올리지 않고 재는 방법 → git-dependency-and-upgrade.md
- `.fvmrc` 를 Dart 3.14 계열로 올릴 때, 루트 옵션 파일의 주석이나 README 에 SDK 에 따라 달라지는 동작(루트 분석의 plugin 준비, 프리셋의 생성 파일 제외, `flutter analyze`)을 적을 때, 다른 SDK 를 저장소를 건드리지 않고 돌릴 때 → next-sdk-forward-compat.md
- 저장소 루트의 `dart analyze` 가 진단 없이 끝나는데 10초가 걸리고 네트워크를 쓸 때 (다음 SDK), SDK 를 올린 뒤 정답지에 `lib/generated/sample.*.dart` 의 4줄이 생겼을 때 → next-sdk-forward-compat.md 4번 · 3번
- 새 spike 를 쓸 때의 관례 → `.planning/spikes/CONVENTIONS.md`

## 뒤의 spike 가 바꾼 결론

references 는 바뀐 뒤의 결론으로 적혀 있다. `sources/` 의 README 는 원문 그대로라 앞선 결론이 남아 있으므로, 어긋나면 references 와 번호가 큰 spike 를 따른다.

| 무엇 | 앞선 결론 | 지금의 결론 |
|---|---|---|
| 규칙 검사의 실행 형태 | 루트에서 인자 없이 돌리고 복사본의 진단만 고른다 (005) | 루트에서 복사본 폴더를 인자로 준다 (007) |
| 상태 폴더 | 정해 주면 md5 없이 버전을 찾을 수 있다는 선택지 (001). 앞선 wrap-up 은 "검증 명령은 주지 않아도 된다"고 적었다 | 항상 저장소 안의 전용 폴더를 준다 (008). 프로젝트가 여럿이면 프로젝트마다 따로 준다 (014) |
| plugin 버전을 읽는 자리 | runner 에서 `~/.dartServer/.plugin_manager/*/pubspec.lock` 을 읽었다 (006. 새 가상 머신이라 다른 프로젝트의 폴더가 없었다) | 전용 상태 폴더의 `.plugin_manager/*/pubspec.lock` 에서 읽는다. 기본 자리에서는 읽지 않는다 (008) |
| stderr 의 머리말 | 모든 실패에서 stderr 가 머리말로 시작한다 (002) | 받기·컴파일 실패에서는 첫 줄, 컴파일된 파일을 읽지 못한 실패에서는 셋째 줄. `contains` 로 찾는다 (008) |
| plugin 폴더 이름 | 패키지 루트 절대 경로의 md5 (001) | **링크를 푼** 경로의 **code unit** 을 md5 한 값. 영문·숫자뿐인 경로에서만 001 의 말과 같다 (008) |
| 루트의 `lib/analysis_options.yaml` 제외 | 그대로 둔다 (Phase 2 의 요구 사항) | 파일을 나누는 커밋과 같은 커밋이거나 그 뒤에 지운다. 한 파일 구조에서 먼저 지우면 Dart 3.13.x 의 루트 분석이 exit 2 다 (011. 베타에서는 → 아래 `plugins_in_inner_options` 줄) |
| 연습용 프로젝트가 늘 때의 루트 제외 | 폴더마다 제외 줄이 필요할 것이다 (007. 재지 않고 남긴 예상) | 한 폴더 아래에 모으면 한 줄이다 (011) |
| 규칙 검사의 대상 | 배포 파일 하나 (005, 007) | 조각 셋을 하위 폴더에 복사해 한 번에. 묶음과 별칭은 넣지 않는다 (013) |
| 규칙 검사의 통과 조건 | 세 코드(`deprecated_lint` / `removed_lint` / `undefined_lint`)가 없으면 통과 (005, 007) | exit 0 이고 복사본의 진단이 0건. "규칙 0개" 확인은 `base.yaml` 에만 (013) |
| `plugins:` 를 빼는 단계 | 섹션을 찾지 못하면 실패한다 (007 의 `stripPlugins`) | 있으면 뺀다. `base.yaml` 은 그대로 복사해 줄 번호가 원본과 같다 (013) |
| 종료 코드 3 | error 가 하나라도 있다 (003) | 옵션 파일의 YAML 이 깨졌을 때도 3 이고, 그때는 JSON 의 진단이 0건이다 (013) |
| plugin 진단을 프로젝트 전체에서 끄기 | 같은 이름으로 다시 선언해 덮어쓴다 (003. 예시에 `version` 이 있었지만 필수라고 적지 않았다) | `version` 을 함께 적어야 한다. 빼면 경고 없이 무시된다 (012) |
| JSON 의 `type` | 전부 `STATIC_WARNING` (003) | 그대로 맞다. 다만 주석의 `type=warning` 은 plugin 진단을 끄지 못하고 `type=lint` 가 끈다 (012) |
| 생성 파일 제외 | 프리셋의 제외가 생성 파일의 진단을 막는다 (spike 가 잰 적 없는 전제) | Dart 3.13.x 에서 규칙 진단에만 통한다. plugin 진단에는 통하지 않고 1.3.0 도 같다 (012. 베타에서는 → 아래 "프리셋의 생성 파일 제외 — 규칙 진단" 줄) |
| plugin 폴더가 0개 | 버전을 `?` 로 찍고 이유를 알린다 (008) | plugin 을 선언하지 않는 조합에서는 정상이다 — "해당 없음" 으로 찍을 수 있다 (009, 014) |
| 상태 폴더를 따로 준 동시 실행 | 2쌍에서 문제가 없었다 (008) | 넷 · 여섯을 두 번씩, 20건이 모두 통과했다 (014) |
| git 의존성으로 받았을 때 | 재지 않았다 — "같은 결과일 것" 이라는 추정(012), Phase 6 의 smoke test 가 처음 확인하는 자리 (009 ~ 011) | `path:` 때와 줄 단위로 같다. smoke test 가 처음 보는 것은 받아 오는 길 하나다 (015) |
| 루트 분석의 plugin 준비 | 준비하지 않는다 (011) | Dart 3.13.x 의 사실이다. 베타에서는 `lib/analysis_options.yaml` 이 `plugins:` 에 닿는 한 준비하고, 그 파일을 루트에서 제외해도 막지 못했다. Dart 파일이 없는 replica 에서 진단은 두 SDK 모두 0줄이다 (016) |
| `plugins_in_inner_options` | 한 파일 구조에서 루트의 제외를 먼저 지우면 난다 (011). 다음 SDK 에서 사라질 수 있다는 것은 소스를 읽은 추정이었다 | Dart 3.13.x 에서만 난다. 베타에서는 나오지 않았다 (016) |
| 프리셋의 생성 파일 제외 — 규칙 진단 | 통한다 (012). Dart 3.14 에서 통하지 않게 될 것이라는 것은 소스를 읽은 추정이었다 | Dart 3.13.x 의 사실이다. 베타에서는 통하지 않아 codegen 조각을 받는 조합의 정답지에 4줄이 생긴다. 상류가 되돌리는 중이다 (016) |
| README 의 생성 파일 안내 | 사용 프로젝트의 옵션 파일에**도** 직접 적으라고 안내한다 (012) | 사용 프로젝트의 옵션 파일에 직접 적으라고 안내한다 — 두 SDK 에서 모두 막는 안내는 이것 하나다. "프리셋의 제외가 통하지 않는다" 를 굳은 사실로 적지 않는다 (016) |
| `flutter analyze` | plugin 진단을 내지 않는다 (PROJECT.md, SDK 를 따로 적지 않았다) | Flutter 3.47.5 의 사실이다. 베타는 plugin 진단을 내지만 규칙 진단을 겹쳐 세고 건수가 실행마다 달랐다. 어느 쪽에서도 쓰지 않는다 (016) |
| 연습용 프로젝트 여섯의 CI 시간 | 재지 않았다. 추정 약 4분 20 ~ 30초 (014) | spike 의 스크립트로 쟀다 — 차례로 돌린 job 이 약 3분 20초 ~ 4분 20초 (재실행을 뺀 값, 표본 여섯). 014 의 추정(260 ~ 270초)은 가장 느린 표본(258초)보다 조금 길었다. 실제 `tool/verify.dart` 로는 아직 재지 않았다 (017) |
| 동시에 띄웠을 때 runner 에서의 이득 | 재지 않았다. 로컬에서는 3분의 1 (014) | runner (코어 4개) 에서는 약 절반이다 — 분석 146 ~ 191초가 69 ~ 95초. plugin 쪽 패키지를 넷이 동시에 처음 받는 경우를 포함해 여섯 번 모두 통과했다 (017) |
| pub cache 가 빈 상태의 `pub get` | 재지 않았다 (014) | 새 가상 머신의 job 에서 루트 0.06 ~ 0.15초, 첫째 프로젝트 1.2 ~ 3.5초, 둘째부터 0.1초 이하 (017 — pub cache 의 내용을 들여다본 것은 아니다) |
| runner 에서 plugin 을 쓰지 않는 프로젝트 | 약 9초 — 로컬 값에 비를 곱한 셈 (014) | 6 ~ 8초 (017) |
| runner 이미지가 바뀐 뒤의 CI | "그 뒤 CI 가 처음 실패하면 저장소 변경보다 runner 이미지 변경을 먼저 의심한다" (STATE.md 의 메모. 24.04 에서만 쟀다) | `ubuntu-26.04` (20260927.149.1) 에서 지금의 검증과 spike 의 여섯 프로젝트 점검이 24.04 와 같았다. 실패하면 로그의 이미지 버전을 그 값과 견주는 것이 먼저다 — 그 뒤의 이미지 버전과 여섯으로 늘린 검증은 재지 않았다 (018) |
| 실제 사용 프로젝트 | 닿은 적이 없다 — 001 ~ 018 은 모두 저장소 안의 연습용 프로젝트로 쟀다 | `flutter_starter_kit` 의 복사본에서 나누기 전후가 줄 단위로 같다. 프로젝트의 줄은 지금 0 이다 (019 — 무시 주석이 있는 채의 0 이다, 023) |
| 생성기가 다는 머리 주석 | `riverpod_generator` 4.0.9 만 봤다. "다른 생성기는 확인하지 않았다" (012) | `flutter_starter_kit` 의 `*.freezed.dart` 7개는 `type=lint` 를 달고, `json_serializable` 의 산출물로 본 5개에는 머리가 없었다. 생성기의 버전은 기록하지 않았다 (019) |
| 사용 프로젝트의 `dev_dependencies` 에 적힌 `riverpod_lint` | 재지 않았다 (015) | `dart analyze` 의 진단에 영향이 없었다. plugin 은 그 프로젝트의 lock(3.1.3)과 무관하게 3.1.9 로 풀렸다 (019 — 프로젝트 하나, 그 줄의 제약이 프리셋과 같은 `^3.1.3` 인 경우) |
| git 으로 받은 패키지의 폴더 이름 | 실제 사용 프로젝트에서는 `git/woody_lints-<해시>/` 가 될 것이다 — 실제 주소로 받아 본 것은 아니다 (015) | 실제 사용 프로젝트의 복사본에서 `rootUri` 가 `git/woody_lints-…` 를 가리켰다. 다만 평소의 pub cache 를 쓴 실행이라 받아 오는 길을 잰 것은 아니다 (019) |
| `public_member_api_docs` 와 앱 프로젝트 | (019 가 도중에 세운 추정) `publish_to: 'none'` 인 프로젝트에는 적용되지 않는다 | 적용된다. 그 규칙을 어기는 표식 둘이 `publish_to` 줄이 있든 없든 2줄로 잡혔다 (019) |
| 규칙 메타데이터의 출처 | "SDK tag 고정 `rules.json` 을 기준으로 삼는다" (ROADMAP.md Phase 4 Notes). `rules.json` 은 상태 하나가 틀렸으니 상태의 근거로 삼지 않는다 (005 — 규칙 하나를 봤다) | 열마다 출처를 바꾼다 — deprecated / removed / 없는 이름은 저장소 하한의 분석, stable / experimental / testing 은 tag 의 `messages.yaml`, 상류 세트는 `lints` · `flutter_lints` 의 YAML, 비호환 쌍은 `rules.json` 의 선언을 쌍마다 확인. 상류가 `rules.json` 을 "믿지 말라" 고 적었다 (020) |
| 비호환 쌍의 확인 | "양립 불가 쌍은 한쪽씩 나눠 돌린다" (ROADMAP.md Phase 4 Notes, 잰 적 없음) | 쌍마다 둘만 켜야 12쌍이 모두 보인다. 전부 켜면 한 줄에 `incompatible_lint` 가 하나만 붙어 둘이 가려진다 (020) |
| `path:` 가 가리킬 자리 | 계획이 정한다. 저장소 자체를 가리킨 실행은 재지 않았다 (019 — replica 를 가리켰다) | 작업 중인 저장소 자체를 가리킨다. `pub get` · 분석 · `dart fix` 뒤에도 저장소의 지문이 그대로였다 (021, 022 의 `repo_guard.dart`) |
| 받은 자리 · 표식의 문턱 | 019 의 스크립트는 기록만 한다. Phase 4 가 판정으로 새로 적는다 | 021 의 `consumer.dart` 가 받은 자리가 저장소가 아니면 던진다 (`ensureRepoSource` — 스크립트 전체가 멈춘다). 023 은 후보마다 그 규칙을 어기는 표식이 걸리는지를 판정에 넣었다. 021 은 대조 셋만 판정이고 규칙별 표식 수는 기록했다 (`perRule`). 022 는 규칙마다의 표식이 없다 |
| 기준선 | 0줄. 후보 규칙의 값은 그 규칙의 줄 수 그대로다 (019) | 무시 주석이 있는 채의 0줄이다 — `type=lint` 를 단 손으로 쓴 파일 다섯이 lint 26줄을 가린다 (023). 복사본의 하한을 올려 잴 때는 기준선을 다시 잰다 — `^3.13.0` 에서 `prefer_initializing_formals` 27줄 (021) |
| Dart 3.13 의 새 규칙과 언어 버전 3.11 | 재지 않았다 (019, ROADMAP.md Phase 4 "Spike first" 첫째 항목) | 6개는 언어 버전 3.11 의 라이브러리에서 돌지 않는다 (3.12 는 재지 않았다) — 지금 하한의 0 은 "돌지 않은 0" 이라 값을 둘 적는다. `async_return_with_no_await` · `no_raw_types` · `no_dynamic_casts` · `strict-inference` 는 돈다 (021) |
| `dart fix` 로 고칠 수 있는 건수 | 재지 않았다. 로드맵은 `dart fix --dry-run` 으로 확인한다고 적었다 (ROADMAP.md Phase 4 "Spike first" 넷째 항목) | 규칙 하나씩 apply 해 사라진 줄로 센다. 단독 dry 의 수는 수정 수(16 → 32줄, 155 → 123줄)이고, 그룹 dry 는 규칙끼리 섞이고, `hasFix` 는 등록 여부다. apply 가 error 를 남기는 규칙이 셋이다 (022) |
| 사용 프로젝트의 `// ignore` 주석 | 경위를 보지 않았다 (019). 로드맵은 `cast_nullable_to_non_nullable` 56건을 적었다 | 그 56건은 생성 파일 안의 freezed 주석이라 아무것도 가리지 않는다. 후보 가운데 주석이 가리는 것은 `lines_longer_than_80_chars` 260줄 · `discarded_futures` 2줄이다. 값은 주석을 둔 채로 재고 가린 줄은 따로 적는다 (023) |

015 는 spike 가 아니라 **로드맵의 문구**도 좁혔다. ROADMAP.md Phase 5 Notes 의 "버전 올리기는 `pub upgrade` 가 아니라 `ref:` 수정과 `pub get`" 은 tag 로 고정한 쪽의 말이고, Phase 6 Notes 의 "`main` 병합은 … 새 버전이 배포되는 순간" 은 곧바로 닿는다는 뜻이 아니다 (→ git-dependency-and-upgrade.md 4번).

019 는 ROADMAP.md Phase 4 의 "Spike first" 넷 가운데 **셋째 하나**에 방법을 줬다 ("복사본의 `woody_lints` 의존성이 작업 중인 파일을 가리키는지" — `pubspec_overrides.yaml` 과 `rootUri` 확인). 둘째 항목은 절반만 닿았다 (프로젝트 자신의 옵션 파일은 규칙을 더 켜지 않는다. `// ignore` 주석의 경위는 보지 않았다). 첫째(Dart 3.13 의 새 규칙이 language version 3.11 프로젝트에서 보고되는지)와 넷째(`dart fix --dry-run`)는 재지 않았다. Phase 4 Notes 의 "기준선(1.3.0) 대비 차이만 규칙의 값으로 쓴다" 에서 그 기준선이 2026-10-12 에 0줄이었다는 것도 019 의 값이다 (→ real-consumer-measurement.md 7번).

그 뒤 **021 ~ 023 이 Phase 4 의 "Spike first" 넷을 모두 실행으로 확인했다** — 첫째는 021, 둘째의 나머지(`// ignore` 주석)는 023, 셋째의 나머지(`path:` 가 저장소 자체를 가리킬 때)는 021, 넷째는 022 다. 020 · 022 · 023 은 **로드맵의 문구**도 좁혔다 (이 wrap-up 은 로드맵을 고치지 않았다).

- Phase 4 Notes 의 "규칙 메타데이터는 SDK tag 고정 `rules.json` 을 기준으로 삼는다" — `state` · 상류 세트 열에서는 쓰지 않는다 (020). 고정한 열 `fixStatus` 를 `rules.json` 에서 채우면 "등록이 있다" 는 뜻이 된다 (022).
- "Spike first" 넷째 항목의 "`sort_pub_dependencies` 는 출처마다 `hasFix` 와 `needsFix` 로 어긋난다" — tag 3.13.4 의 `rules.json` (`needsFix`) 과 dart.dev 사이트 `main` (`hasFix`) 의 차이이고, Dart 3.13.4 의 `dart fix` 는 고치지 않는다 (022).
- "Spike first" 둘째 항목의 "`cast_nullable_to_non_nullable` 56건" — 생성 파일 안의 freezed 주석이고, 생성 파일은 분석에서 빠지므로 아무것도 가리지 않는다 (023).
- Phase 4 Notes 의 "기준선(1.3.0) 대비 차이" — 기준선은 무시 주석이 있는 채의 0줄이고, 복사본의 하한을 올리면 다시 잰다 (023, 021).

## Source Files

Original spike source files are preserved in `sources/` for complete reference.

- `sources/` 는 **읽기용 사본**이다. README, 실측 스크립트, 연습용 프로젝트의 소스만 담았다. 실행은 원본(`.planning/spikes/NNN-name/`)에서 한다 — 사본의 `pubspec.yaml` 에 적힌 `path: ../../../..` 는 사본 자리에서는 맞지 않고, 007 ~ 023 의 스크립트는 자기 위치에서 저장소 루트를 찾는다 (`.planning/spikes/<spike>/` 의 세 단계 위 — 사본 자리에서 돌리면 엉뚱한 폴더를 저장소로 본다).
- 원본 로그와 JSON(`results/`), 생성 코드(`*.g.dart`), `pubspec.lock`, `.dart_tool/` 은 사본에 넣지 않았다. 원본 폴더에 있다.
- 007 과 008 은 연습용 프로젝트를 새로 만들지 않았다. spike 001 의 것을 작업 폴더에 복사해 썼으므로 사본에는 README 와 스크립트만 있다.
- 009 ~ 016 도 연습용 프로젝트를 따로 두지 않았다. 저장소 `example/` 의 샘플과 `pubspec.lock` 을 작업 폴더의 복사본(replica)에 복사해 썼다. 여덟이 함께 쓰는 공용 파일이 `sources/009-preset-plugin-via-include/replica.dart` 이고, 나머지 스크립트는 `import '../009-preset-plugin-via-include/replica.dart';` 로 받는다. 그 spike 에만 필요한 샘플(012 의 끄는 샘플, 012 · 015 · 016 의 생성 파일 샘플)은 스크립트 안에 문자열로 들어 있다. 015 는 받는 쪽 프로젝트를 replica **밖**에 만들었다.
- 017 과 019 도 같은 `replica.dart` 를 import 한다. 017 의 `runner_probe.dart` 는 014 의 스크립트에서 프로젝트 하나의 틀(`Fx`)과 옵션 문자열(`bundle`, `overrides`), 시간 표기(`secs`)도 받는다 (`import '../014-multi-fixture-plugin-cost/probe.dart' show Fx, bundle, overrides, secs;`) — 여섯의 목록 자체는 `runner_probe.dart` 에 다시 적혀 있다. 018 에는 스크립트가 없다 — 017 의 스크립트와 임시 workflow 를 함께 썼고 사본에는 README 만 있다. 임시 workflow 의 사본(`sources/017-runner-six-fixtures/spike-017-018-runner.yml`)은 참고용이다 — 저장소의 `.github/workflows/` 에서는 결과를 기록한 뒤 지웠다. 019 는 사용 프로젝트의 복사본을 replica **옆**(`<작업 폴더>/consumer`)에 만들었고, 원본의 경로는 스크립트에 없다 (인자로 받는다).
- **009 ~ 017 과 019 의 스크립트는 저장소의 `lib/analysis_options.yaml` 이 한 파일 구조일 때 돈다.** `replica.dart` 의 `Shipped.read` 가 그 파일에서 `analyzer:` 와 `plugins:` 의 자리를 찾아 조각으로 자른다. Phase 3 이 저장소를 나눈 뒤에는 그대로 돌지 않을 것이다 — 스크립트를 읽은 것이고 돌려 보지는 않았다 (→ next-sdk-forward-compat.md 9번). Phase 4 가 019 의 방법을 쓸 때는 나눈 뒤이므로, 옮겨 쓸 것은 `main` 이 아니라 019 의 `Consumer` 쪽이다 (→ real-consumer-measurement.md 2번). 그 일은 021 이 했다 — `sources/021-new-rules-language-gate/consumer.dart` 는 replica 없이 작업 중인 저장소를 받고, 나눈 뒤의 저장소에서 021 ~ 023 이 돌았다.
- 020 ~ 023 은 `replica.dart` 를 쓰지 않는다. 020 은 혼자 서는 스크립트이고(상류 파일을 받아 `<작업 폴더>/upstream/` 에 둔다), 021 ~ 023 은 `consumer.dart` 를 import 한다. 022 는 021 의 표식(`oldSamples`)과 규칙 목록(`newRules`)도 받고(`import '../021-new-rules-language-gate/probe.dart' show oldSamples, newRules;`), 020 의 결과 파일에서 `fixStatus` 를 읽는다. 022 의 `repo_guard.dart` 는 K5 (저장소 불변)가 깨진 원인을 가르려고 따로 돌린 대조다. 사용 프로젝트의 원본 경로는 스크립트에 없다 (인자로 받는다).
- 실측 스크립트에서 그대로 옮겨 쓸 수 있는 코드. 모두 `dart:io`, `dart:convert` 만 쓴다.
  - `sources/006-github-runner-cold-plugin/ci_probe.dart`: `normalizeDiagnostics`, `Expected.read`, `runAnalyze`, `runPubGet`
  - `sources/008-state-folder-placement/state_probe.dart`: `pluginFolders`, `readPluginVersion` (전용 상태 폴더에서 버전 읽기), `Outcome.hasPluginHeader` (`contains`), 접두사를 둘 받는 `normalizeDiagnostics`
  - `sources/007-root-analysis-with-example/probe.dart`: `stripPlugins` (`plugins:` 섹션 빼기 — 못 찾으면 던지는 형태다. 나눈 뒤에는 "있으면 뺀다" 로 쓴다)
  - `sources/009-preset-plugin-via-include/replica.dart`: `Shipped` (배포 파일을 세 조각으로 자르고 이어 붙여 원본과 견주기), `Expected.predicted` (조합별 정답지 셈하기), `diffLines` (건수까지 세는 비교), `Replica.addFixture` (연습용 프로젝트 복사와 의존성 경로 맞추기), `Replica.declaredConstraint` (서버가 받은 plugin 선언 읽기), `Replica.scrub` (결과에서 로컬 경로 가리기)
  - `sources/012-plugin-suppression-matrix/probe.dart`: `samples` (끈 자리 옆에 끄지 않은 같은 위반을 둔 샘플 9개), `cells` (칸마다 볼 자리). **`cells` 의 다섯째 인자는 결과가 아니라 소스를 읽어 세운 추정(`guess`)이다** — 세 칸(`type=lint`, `type=warning`, 생성 파일 제외의 plugin 쪽)은 실제와 반대였다. 결과는 suppression-and-exclude.md 의 표를 따른다
  - `sources/013-rule-check-after-split/probe.dart`: `ruleCheck` (복사본을 두고 폴더를 인자로 분석한 뒤 `finally` 로 지우기 — 경로에 하위 폴더를 주면 여럿을 한 번에 본다), 깨진 입력 여섯(`broken`), `countDeclaredRules` (`tool/verify.dart` 의 것과 같은 셈)
  - `sources/014-multi-fixture-plugin-cost/probe.dart`: `parallel` (상태 폴더를 따로 주고 `Future.wait` 로 동시에 띄우기 — `main` 안의 지역 함수라 import 로 받지 못하고 옮겨 적는다)
  - `sources/015-git-dependency-preset-load/probe.dart`: `Consumer` (replica 밖에 둔 받는 쪽 프로젝트 — `create`, `setDependency`, `PUB_CACHE` 를 작업 폴더로 돌린 `pub`, lock 의 항목을 읽는 `lockEntry`, 패키지의 자리를 읽는 `packageRoot`), `git` (전역 설정을 끄고 커밋의 이름 · 시각을 고정한 실행), `commit`
  - `sources/016-next-sdk-forward-compat/probe.dart`: `Observations` (칸마다 기준 SDK 의 값을 적어 두고 `=` / `≠` 로 견주기), `insertAfterLastRule` (규칙 목록 끝에 문제 규칙 끼우기), SDK 하한만 바꿔 규칙 검사를 돌리고 `finally` 로 되돌리는 3부
  - `sources/016-next-sdk-forward-compat/root_probe.dart`: `cases` 와 `rootOptions` (`lib/` 의 모양 · `example/` 의 유무 · 루트의 제외를 하나씩 넣고 빼며 루트 분석을 돌리는 표)
  - `sources/017-runner-six-fixtures/runner_probe.dart`: `pass` (여섯을 차례로 또는 `Future.wait` 로 한꺼번에 돌리고 프로젝트마다 진단과 plugin 준비를 확인하기 — `main` 안의 지역 함수다), `readKeyValue` · `totalMemoryMb` (runner 의 운영체제와 메모리 읽기), 로그에 `SPIKE017_RESULT {…}` 한 줄을 찍고 `GITHUB_STEP_SUMMARY` 에 표를 덧붙이는 끝부분
  - `sources/017-runner-six-fixtures/collect.py`: GitHub 실행 하나의 job 별 시간 · 이미지 버전 · 결과 줄을 모아 JSON 으로 쓰기 (`gh` 만 쓴다. python 3.9). Dart 가 아니라 결과를 모으는 도구다
  - `sources/019-real-consumer-split-invariance/probe.dart`: `Consumer` (사용 프로젝트의 복사본 — `copy`, `addMarkers`, `optionsWith` · `replaceOnce`, `ensurePub`, `woodySource`, `facts`. 015 의 `Consumer` 와 이름만 같은 다른 클래스다. `ensurePub` 은 `path: ../replica` 를, `woodySource` 는 replica 의 자리와 같은지를 박아 두었다 — 나눈 뒤에는 아래 021 의 `consumer.dart` 를 쓴다), `Diag` (정답지 형식 한 줄을 풀어 표식 / 생성 파일 / plugin / 자리로 가르기), `digest` (64비트 FNV-1a — 경로를 드러내지 않고 줄 목록을 견주기), `Shot.toJson` (사용 프로젝트의 경로와 메시지를 뺀 결과)
  - `sources/021-new-rules-language-gate/consumer.dart`: **나눈 뒤의 실측에 옮겨 쓸 공용 조각.** `Repo` (`fromSpikeDir`, `fingerprint` — 저장소 지문), `Diag` (정답지 형식 한 줄, `area` 가 `marker` / `generated` / `lib` / `test` / `bin` 으로 가른다), `Shot` (분석 한 번 — `marker` · `project`, `countByAreaCode`, 경로와 메시지를 뺀 `toJson`), `Consumer` (`copy`, `pointToRepo`, `woodySource`, `ensureRepoSource`, `useSdk`, `languageVersion`, `refreshSources`, `optionsWith(rules:, language:)`, `pubspecWithSdk`, `addExampleMarkers` · `addMarkers` · `removeMarkers`, `analyze`, `scrubText`), `replaceOnce`, `digest` (바이트를 받는다 — 019 의 것은 줄 목록을 받는다), `expectedLines`. 019 의 `Consumer` 와 이름만 같은 다른 클래스다. 함정: `pubspecWithSdk` 는 원본의 `sdk: ^3.11.1` 줄을, `copy` 는 옵션 파일이 옛 주소를 include 하는 것을, `optionsWith` 는 `\n  rules:\n` · `\nanalyzer:\n` 이 정확히 한 번 나오는 것을 요구한다 (아니면 던진다). `Repo.fromSpikeDir` 는 `.planning/spikes/<spike>/` 의 세 단계 위를 저장소로 본다. `analyze` 는 `ensureRepoSource` 를 스스로 부르지 않고(부르는 쪽이 부른다), 022 의 `dryRun` 은 받은 자리를 보지 않는다
  - `sources/020-rule-state-vs-rules-json/probe.dart`: `analyzeAll` (규칙만 적은 패키지를 하한별로 만들어 분석하고 진단의 줄 번호로 규칙을 찾기), `readRulesJson`, `readMessagesYaml` · `MessagesRule.latest` · `snake` (yaml 패키지 없이 `messages.yaml` 의 상태 읽기), `readUpstreamSets` · `UpstreamSets.of` (저장소 루트의 `package_config.json` 으로 상류 세트 읽기, 소문자로 견주기), `download` (`HttpClient` 로 상류 파일 받기)
  - `sources/021-new-rules-language-gate/probe.dart`: `newRules`, `guess` (소스를 읽은 추정 — 판정에 넣지 않는다), `oldSamples` · `newSyntaxSamples` (새 규칙과 strict-inference 를 어기는 표식), `consumerFacts`
  - `sources/022-dart-fix-dry-run-count/probe.dart`: `groups` (비호환 쌍이 갈리도록 그룹 넷으로 나눈 후보 119개 — 2026-10-12 의 FEATURES.md 기준), `DryRun` · `dryRun` (`dart fix` 의 출력 읽기 — 화면 그대로는 `private/` 에), apply 고리 (`refreshSources` → 표식 → `useSdk` → 묶음의 옵션 → `--apply --code=` → 다시 분석 → 남은 줄과 증감), `readFixStatus`. `applyRules` 는 `take(maxApply + 1)` 로 잘려 `sort_pub_dependencies` 를 apply 하지 않았다 — 옮겨 쓸 때 목록을 따로 정한다
  - `sources/022-dart-fix-dry-run-count/repo_guard.dart`: 단계마다 저장소 지문을 견주는 `step`
  - `sources/023-existing-ignore-comments/probe.dart`: `ignorePattern` · `stripIgnores` (무시 주석 부분만 지우고 줄은 남기기), `markers` (가리지 않은 위반 · 가린 위반 · 아무것도 가리지 않는 주석), 주석의 출처 세기(손으로 쓴 것 / 생성 파일, `type=lint` 를 단 손으로 쓴 파일), `unnecessaryIgnoreNames` (진단이 가리킨 줄의 주석에서 코드 이름만 뽑기)
</findings_index>

<metadata>
## Processed Spikes

- 001-analyze-invocation-form
- 002-plugin-setup-failure-exit
- 003-riverpod-lint-severity-matrix
- 004-fixture-pub-get
- 005-initial-file-rule-status
- 006-github-runner-cold-plugin
- 007-root-analysis-with-example
- 008-state-folder-placement
- 009-preset-plugin-via-include
- 010-alias-three-level-include
- 011-root-analysis-after-split
- 012-plugin-suppression-matrix
- 013-rule-check-after-split
- 014-multi-fixture-plugin-cost
- 015-git-dependency-preset-load
- 016-next-sdk-forward-compat
- 017-runner-six-fixtures
- 018-runner-next-image
- 019-real-consumer-split-invariance
- 020-rule-state-vs-rules-json
- 021-new-rules-language-gate
- 022-dart-fix-dry-run-count
- 023-existing-ignore-comments

skill 이름은 `spike-findings-woody-lints` 다. 프로젝트 폴더 이름은 `woody_lints` 이지만 skill 이름에는 소문자·숫자·하이픈만 쓰는 규격에 맞춰 밑줄을 하이픈으로 바꿨다. 다음 wrap-up 은 이 폴더를 그대로 갱신한다.
</metadata>
