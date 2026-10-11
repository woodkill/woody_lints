# Spike Manifest

## Ideas

### verify-harness-tool-behavior

Phase 2 (Verification Harness) 의 나머지를 계획하기 전에, 검증 명령(`tool/verify.dart`)과 CI 가 기대는 도구 동작 6가지를 실행으로 확인한다. 대상은 `dart analyze`, analyzer plugin(`riverpod_lint`), `pub get`, GitHub Actions runner 이고, 목록은 ROADMAP.md Phase 2 의 "Spike first" 다. 결과의 처리 기준은 02-CONTEXT.md D-15 를 따른다 — "정답지 비교로 판정한다"를 지킬 수 없다는 결과면 멈추고 소유자에게 돌아가고, 값이나 세부만 다른 결과는 기록하고 계속한다.

**Requirements:**

소유자가 이전에 확정해 이 spike 들이 그대로 따른 것 (출처는 02-CONTEXT.md).

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

## Spikes

| # | Idea | Name | Type | Validates | Verdict | Tags |
|---|------|------|------|-----------|---------|------|
| 001 | verify-harness-tool-behavior | analyze-invocation-form | standard | 패키지 루트에서 인자 없이 `dart analyze` 를 돌리면 plugin 진단이 cold·warm 모두 빠짐없이 나온다 | ✓ VALIDATED (조건: 사용 통계 전송을 끈다) | dart-analyze, analyzer-plugin, exit-code, analytics, flaky |
| 002 | verify-harness-tool-behavior | plugin-setup-failure-exit | standard | plugin 준비가 실패하고 다른 진단이 있을 때 `dart analyze` 의 종료 코드·stdout·stderr 가 확정된다 | ✓ VALIDATED | dart-analyze, analyzer-plugin, exit-code, stderr, offline |
| 003 | verify-harness-tool-behavior | riverpod-lint-severity-matrix | standard | `riverpod_lint` 규칙 15개의 강도·`code` 표기·종료 코드가 표로 확정된다 | ✓ VALIDATED | riverpod_lint, severity, exit-code, json |
| 004 | verify-harness-tool-behavior | fixture-pub-get | standard | `flutter pub get` / `dart pub get` 이 `analysis_options.yaml` 을 바꾸는지와 `dart pub get` 이 Flutter 프로젝트에서 되는지가 확정된다 | ✓ VALIDATED | pub-get, flutter-tool, analysis-options, lockfile |
| 005 | verify-harness-tool-behavior | initial-file-rule-status | standard | `unnecessary_await_in_return` 이 Dart 3.13.4 에서 deprecated 로 보고되는지가 확정된다 | ✓ VALIDATED | linter-rules, deprecated-lint, removed-lint, sdk-constraint |
| 006 | verify-harness-tool-behavior | github-runner-cold-plugin | standard | 캐시 없는 GitHub Linux runner 에서 plugin 진단이 로컬과 똑같이 나오고 첫 실행 시간이 측정된다 | PENDING (첫 push 확인 대기) | github-actions, ci, cold-start, analyzer-plugin, timing |
