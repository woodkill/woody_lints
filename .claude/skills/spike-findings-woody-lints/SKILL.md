---
name: spike-findings-woody-lints
description: woody_lints 의 spike 실측에서 나온 구현 설계도(implementation blueprint). 검증 명령(`tool/verify.dart`), `example/` 연습용 프로젝트와 정답지, deprecated 규칙 검사, GitHub Actions CI 를 만들거나 고칠 때, 그리고 루트 `analysis_options.yaml` 의 exclude 를 고칠 때 읽는다. `dart analyze` 실행 형태, analyzer plugin(`riverpod_lint`) 준비 실패 판정과 복구, 종료 코드 해석, Analysis Server 상태 폴더(`ANALYZER_STATE_LOCATION_OVERRIDE`), plugin 버전 읽기, `pub get` 방식의 요구 사항과 검증된 방식을 담았다.
---

<context>
## Project: woody_lints

Phase 2 (Verification Harness) 의 나머지를 계획하기 전에, 검증 명령(`tool/verify.dart`)과 CI 가 기대는 도구 동작 6가지를 실행으로 확인한다. 대상은 `dart analyze`, analyzer plugin(`riverpod_lint`), `pub get`, GitHub Actions runner 이고, 목록은 ROADMAP.md Phase 2 의 "Spike first" 다. 결과의 처리 기준은 02-CONTEXT.md D-15 를 따른다 — "정답지 비교로 판정한다"를 지킬 수 없다는 결과면 멈추고 소유자에게 돌아가고, 값이나 세부만 다른 결과는 기록하고 계속한다.

8개 모두 VALIDATED 다. D-15 의 멈춤 조건에 해당한 것은 없다. 001~006 이 위의 6가지이고, 007 과 008 은 그 6개가 재지 않고 남긴 두 가지를 같은 idea 아래에서 잰 것이다 — `example/` 이 생긴 뒤의 저장소 루트 분석(02-CONTEXT.md 가 계획에 맡긴 항목)과 Analysis Server 상태 폴더의 자리(001 이 선택지로만 적어 둔 것).

Spike sessions wrapped: 2026-10-11 (001~006), 2026-10-11 (007~008)

실측 조건: Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64 (로컬) 와 `ubuntu-latest` (GitHub runner, 006 만). SDK 나 plugin 의 버전이 바뀌면 아래 내용은 다시 재야 한다.
</context>

<requirements>
## Requirements

idea key 는 `verify-harness-tool-behavior` 하나다.

소유자가 이전에 확정해 spike 들이 그대로 따른 것 (출처는 02-CONTEXT.md).

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

읽을 때 헷갈리기 쉬운 두 가지.

- 위의 "인자 없이"는 **경로 인자**가 없다는 뜻이다. `example/` 분석의 실제 명령은 `dart --suppress-analytics analyze --format=json` 이고, 규칙 검사는 그 끝에 복사본 폴더 경로가 붙는다 (`… analyze --format=json build/woody_rule_check`).
- 루트 `analysis_options.yaml` 은 기존 항목을 그대로 두고 `example/**` 한 줄을 **더하는** 것이다. "그대로 둔다"와 "한 줄을 더한다"는 서로 부딪치지 않는다.

skill 밖 문서의 자리: MANIFEST.md 는 `.planning/spikes/MANIFEST.md`, 02-CONTEXT.md (D-NN 결정) 는 `.planning/phases/02-verification-harness/02-CONTEXT.md`, ROADMAP.md 와 PROJECT.md 는 `.planning/`, PITFALLS.md 와 ARCHITECTURE.md 는 `.planning/research/` 에 있다.
</requirements>

<findings_index>
## Feature Areas

| Area | Reference | Key Finding |
|------|-----------|-------------|
| `dart analyze` 실행과 결과 판정 | references/analyze-run-and-verdict.md | `example/` 에서 인자 없이 `--suppress-analytics` 로, 저장소 안의 전용 상태 폴더를 주고 돌린다. plugin 이 죽어도 종료 코드는 0 / 2 라서 stderr 에 머리말이 **들어 있는지**(`contains`)로 알아챈다. plugin 버전은 전용 상태 폴더의 `pubspec.lock` 에서 읽는다 (기본 자리에서는 자기 폴더를 고를 수 없다). 깨진 `plugin.aot` 은 지울 때까지 계속 실패한다 |
| `example/` 프로젝트와 정답지 | references/example-project-and-expected-file.md | `riverpod_lint` 15개는 info 3 / warning 11 / error 1 이다. 정답지에는 `missing_provider_scope` + `avoid_public_notifier_properties` 를 넣어 `exit 2` 로 만든다. 패키지는 `dart pub get` 으로 받는다. `example/` 을 만들 때 루트 옵션 파일에 `example/**` 제외를 함께 넣는다 — 넣지 않으면 루트 분석이 exit 3 (`pub get` 전) 또는 exit 2 + plugin 준비 15초 (`pub get` 후) 가 된다 |
| deprecated / removed / 없는 규칙 검사 | references/rule-status-check.md | 배포 파일을 `plugins:` 를 뺀 채 저장소 **안**에 `analysis_options.yaml` 이름으로 복사하고, 루트에서 **그 폴더를 인자로** 분석한다 (0.5초, plugin 준비 없음). 저장소 밖에 두면 deprecated 와 removed 를 놓친다 (보고 여부가 pubspec 의 SDK 하한에 달려 있다) |
| GitHub Actions CI | references/ci-workflow.md | `checkout@v7` + `flutter-action@v2` (`.fvmrc`) 만으로 캐시 없는 runner 에서 60번 중 60번 로컬과 같은 진단이 나왔다. 첫 분석 약 43초, job 약 2분, `timeout-minutes: 10`. 상태 폴더는 캐시하지 않는다 |

## 어느 것을 읽을지

- `tool/verify.dart` 의 분석 실행, 상태 폴더, 종료 코드 해석, 실제 plugin 버전 표시(D-07), plugin 실패 안내 문구 → analyze-run-and-verdict.md
- `example/` 의 파일 구성, 위반 코드, 정답지 내용, `pubspec.lock`, README 의 종료 코드 설명 → example-project-and-expected-file.md
- 루트 `analysis_options.yaml` 의 exclude, 저장소 루트에서 돌린 `dart analyze`(커밋 전 린터)에 뜻밖의 진단이 나올 때 → example-project-and-expected-file.md 의 8번
- VERIFY-02, 규칙 후보 선정(Phase 4) → rule-status-check.md
- `.github/workflows/` → ci-workflow.md
- 새 spike 를 쓸 때의 관례 → `.planning/spikes/CONVENTIONS.md`

## 뒤의 spike 가 바꾼 결론

references 는 바뀐 뒤의 결론으로 적혀 있다. `sources/` 의 README 는 원문 그대로라 앞선 결론이 남아 있으므로, 어긋나면 references 와 번호가 큰 spike 를 따른다.

| 무엇 | 앞선 결론 | 지금의 결론 |
|---|---|---|
| 규칙 검사의 실행 형태 | 루트에서 인자 없이 돌리고 복사본의 진단만 고른다 (005) | 루트에서 복사본 폴더를 인자로 준다 (007) |
| 상태 폴더 | 정해 주면 md5 없이 버전을 찾을 수 있다는 선택지 (001). 앞선 wrap-up 은 "검증 명령은 주지 않아도 된다"고 적었다 | 항상 저장소 안의 전용 폴더를 준다 (008) |
| plugin 버전을 읽는 자리 | runner 에서 `~/.dartServer/.plugin_manager/*/pubspec.lock` 을 읽었다 (006. 새 가상 머신이라 다른 프로젝트의 폴더가 없었다) | 전용 상태 폴더의 `.plugin_manager/*/pubspec.lock` 에서 읽는다. 기본 자리에서는 읽지 않는다 (008) |
| stderr 의 머리말 | 모든 실패에서 stderr 가 머리말로 시작한다 (002) | 받기·컴파일 실패에서는 첫 줄, 컴파일된 파일을 읽지 못한 실패에서는 셋째 줄. `contains` 로 찾는다 (008) |
| plugin 폴더 이름 | 패키지 루트 절대 경로의 md5 (001) | **링크를 푼** 경로의 **code unit** 을 md5 한 값. 영문·숫자뿐인 경로에서만 001 의 말과 같다 (008) |

## Source Files

Original spike source files are preserved in `sources/` for complete reference.

- `sources/` 는 **읽기용 사본**이다. README, 실측 스크립트, 연습용 프로젝트의 소스만 담았다. 실행은 원본(`.planning/spikes/NNN-name/`)에서 한다 — 사본의 `pubspec.yaml` 에 적힌 `path: ../../../..` 는 사본 자리에서는 맞지 않고, 007·008 의 스크립트는 자기 위치에서 저장소 루트와 spike 001 의 연습용 프로젝트를 찾는다.
- 원본 로그와 JSON(`results/`), 생성 코드(`*.g.dart`), `pubspec.lock`, `.dart_tool/` 은 사본에 넣지 않았다. 원본 폴더에 있다.
- 007 과 008 은 연습용 프로젝트를 새로 만들지 않았다. spike 001 의 것을 작업 폴더에 복사해 썼으므로 사본에는 README 와 스크립트만 있다.
- 실측 스크립트에서 그대로 옮겨 쓸 수 있는 조각. 모두 `dart:io`, `dart:convert` 만 쓴다.
  - `sources/006-github-runner-cold-plugin/ci_probe.dart`: `normalizeDiagnostics`, `Expected.read`, `runAnalyze`, `runPubGet`
  - `sources/008-state-folder-placement/state_probe.dart`: `pluginFolders`, `readPluginVersion` (전용 상태 폴더에서 버전 읽기), `Outcome.hasPluginHeader` (`contains`), 접두사를 둘 받는 `normalizeDiagnostics`
  - `sources/007-root-analysis-with-example/probe.dart`: `stripPlugins` (`plugins:` 섹션 빼기)
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

skill 이름은 `spike-findings-woody-lints` 다. 프로젝트 폴더 이름은 `woody_lints` 이지만 skill 이름에는 소문자·숫자·하이픈만 쓰는 규격에 맞춰 밑줄을 하이픈으로 바꿨다. 다음 wrap-up 은 이 폴더를 그대로 갱신한다.
</metadata>
