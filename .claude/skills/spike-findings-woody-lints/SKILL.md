---
name: spike-findings-woody-lints
description: woody_lints 의 spike 실측에서 나온 구현 설계도(implementation blueprint). 검증 명령(`tool/verify.dart`), `example/` 연습용 프로젝트와 정답지, deprecated 규칙 검사, GitHub Actions CI 를 만들거나 고칠 때 읽는다. `dart analyze` 실행 형태, analyzer plugin(`riverpod_lint`) 준비 실패 판정, 종료 코드 해석, `pub get` 방식의 요구 사항과 검증된 방식을 담았다.
---

<context>
## Project: woody_lints

Phase 2 (Verification Harness) 의 나머지를 계획하기 전에, 검증 명령(`tool/verify.dart`)과 CI 가 기대는 도구 동작 6가지를 실행으로 확인한다. 대상은 `dart analyze`, analyzer plugin(`riverpod_lint`), `pub get`, GitHub Actions runner 이고, 목록은 ROADMAP.md Phase 2 의 "Spike first" 다. 결과의 처리 기준은 02-CONTEXT.md D-15 를 따른다 — "정답지 비교로 판정한다"를 지킬 수 없다는 결과면 멈추고 소유자에게 돌아가고, 값이나 세부만 다른 결과는 기록하고 계속한다.

6개 모두 VALIDATED 다. D-15 의 멈춤 조건에 해당한 것은 없다.

Spike sessions wrapped: 2026-10-11

실측 조건: Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64 (로컬) 와 `ubuntu-latest` (GitHub runner). SDK 나 plugin 의 버전이 바뀌면 아래 내용은 다시 재야 한다.
</context>

<requirements>
## Requirements

idea key 는 `verify-harness-tool-behavior` 하나다.

소유자가 이전에 확정해 spike 들이 그대로 따른 것 (출처는 02-CONTEXT.md).

- 판정의 주 수단은 정답지 비교다. spike 는 이를 뒤집지 않고 값과 세부를 확정한다 (D-15)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 `fvm dart …` 로 한다
- `lib/`, `pubspec.yaml`, 루트 `analysis_options.yaml` 은 바꾸지 않는다
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
</requirements>

<findings_index>
## Feature Areas

| Area | Reference | Key Finding |
|------|-----------|-------------|
| `dart analyze` 실행과 결과 판정 | references/analyze-run-and-verdict.md | 패키지 루트에서 인자 없이 `--suppress-analytics` 로 돌린다. 하위 폴더를 인자로 주면 plugin 진단을 잃고 exit 0 이 된다. plugin 이 죽어도 종료 코드는 0 / 2 라서 stderr 의 머리말로 알아챈다 |
| `example/` 프로젝트와 정답지 | references/example-project-and-expected-file.md | `riverpod_lint` 15개는 info 3 / warning 11 / error 1 이다. 정답지에는 `missing_provider_scope` + `avoid_public_notifier_properties` 를 넣어 `exit 2` 로 만든다. 패키지는 `dart pub get` 으로 받는다 (`flutter pub get` 은 옵션 파일을 고친다) |
| deprecated / removed / 없는 규칙 검사 | references/rule-status-check.md | 배포 파일을 `plugins:` 를 뺀 채 저장소 **안**에 `analysis_options.yaml` 이름으로 복사해 분석한다. 저장소 밖에 두면 deprecated 와 removed 를 놓친다 (보고 여부가 pubspec 의 SDK 하한에 달려 있다) |
| GitHub Actions CI | references/ci-workflow.md | `checkout@v7` + `flutter-action@v2` (`.fvmrc`) 만으로 캐시 없는 runner 에서 60번 중 60번 로컬과 같은 진단이 나왔다. 첫 분석 약 43초, job 약 2분, `timeout-minutes: 10` |

## 어느 것을 읽을지

- `tool/verify.dart` 의 분석 실행, 종료 코드 해석, 실패 안내 문구 → analyze-run-and-verdict.md
- `example/` 의 파일 구성, 위반 코드, 정답지 내용, `pubspec.lock`, README 의 종료 코드 설명 → example-project-and-expected-file.md
- VERIFY-02, 규칙 후보 선정(Phase 4) → rule-status-check.md
- `.github/workflows/` → ci-workflow.md
- 새 spike 를 쓸 때의 관례 → `.planning/spikes/CONVENTIONS.md`

## Source Files

Original spike source files are preserved in `sources/` for complete reference.

- `sources/` 는 **읽기용 사본**이다. README, 실측 스크립트, 연습용 프로젝트의 소스만 담았다. 실행은 원본(`.planning/spikes/NNN-name/`)에서 한다 — 사본의 `pubspec.yaml` 에 적힌 `path: ../../../..` 는 사본 자리에서는 맞지 않는다.
- 원본 로그와 JSON(`results/`), 생성 코드(`*.g.dart`), `pubspec.lock`, `.dart_tool/` 은 사본에 넣지 않았다. 원본 폴더에 있다.
- 실측 스크립트에서 그대로 옮겨 쓸 수 있는 조각: `sources/006-github-runner-cold-plugin/ci_probe.dart` 의 `normalizeDiagnostics`, `Expected.read`, `runAnalyze`, `runPubGet`, `readResolvedPluginVersions`. 모두 `dart:io`, `dart:convert` 만 쓴다.
</findings_index>

<metadata>
## Processed Spikes

- 001-analyze-invocation-form
- 002-plugin-setup-failure-exit
- 003-riverpod-lint-severity-matrix
- 004-fixture-pub-get
- 005-initial-file-rule-status
- 006-github-runner-cold-plugin

skill 이름은 `spike-findings-woody-lints` 다. 프로젝트 폴더 이름은 `woody_lints` 이지만 skill 이름에는 소문자·숫자·하이픈만 쓰는 규격에 맞춰 밑줄을 하이픈으로 바꿨다. 다음 wrap-up 은 이 폴더를 그대로 갱신한다.
</metadata>
