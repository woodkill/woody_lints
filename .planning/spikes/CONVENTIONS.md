# Spike Conventions

spike 세션에서 굳어진 도구 선택과 방식이다. 새 spike 는 질문이 다른 방식을 요구하지 않는 한 이를 따른다. 두 개 이상의 spike 에서 반복된 것만 적었다.

## Stack

- **실측 스크립트는 Dart 로 쓴다.** `dart:io`, `dart:convert` 만 쓰고 패키지 의존성을 두지 않는다 (001, 002, 003, 006). 실제 검증 명령(`tool/verify.dart`, 02-CONTEXT.md D-11)과 같은 조건이라 스크립트의 조각을 그대로 옮겨 갈 수 있다.
- 명령을 차례로 돌리고 파일을 견주는 일은 `bash` + `python3` 으로 쓴다 (004, 005).
- SDK 는 저장소 고정 버전이다 (Flutter 3.47.5 / Dart 3.13.4). 저장소 안에서는 `fvm dart …`, 저장소 밖 작업 폴더에서는 `<저장소>/.fvm/flutter_sdk/bin/dart` 를 직접 부른다 (`fvm` 이 `.fvmrc` 를 찾지 못하므로).

## Structure

```text
.planning/spikes/NNN-name/
  README.md        질문, 조사, 실행법, 조사 경과, 결과
  fixture/         연습용 프로젝트 (복사해 써야 하면 template/)
  <script>         저장소 루트에서 실행한다
  results/         원본 로그와 JSON
```

- 연습용 프로젝트는 Flutter 패키지이고, `woody_lints` 를 `path: ../../../..` 로 받으며, 옵션 파일은 `include: package:woody_lints/analysis_options.yaml` 한 줄이다. 사용 프로젝트와 같은 모양으로 둔다.
- 연습용 프로젝트의 `.dart_tool/` 과 `pubspec.lock` 은 루트 `.gitignore` 에 걸려 커밋되지 않는다. 실행 전에 `fvm dart pub get` 을 한다.
- `.planning/` 은 점(`.`)으로 시작하므로 저장소 루트의 분석에 연습용 프로젝트의 위반 코드가 섞이지 않는다.

## Patterns

- **`dart analyze` 는 패키지 루트를 작업 디렉터리로 두고 인자 없이 실행한다.** 하위 폴더를 인자로 주면 plugin 진단을 잃는다 (001).
- **사용 통계 전송을 끄고 실행한다** — `dart --suppress-analytics analyze …` 또는 `DASH__SUPPRESS_ANALYTICS=true`. 끄지 않으면 가끔 종료 코드 255 로 죽는다 (001).
- **`~/.dartServer` 를 건드리지 않는다.** 스크립트의 첫 인자로 상태 폴더를 받아 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 넘긴다. 빈 폴더를 주면 cold 실행이 된다.
- 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 정규화하고 정렬해 견준다 (D-04). 강도는 JSON 의 `severity` 를 소문자로 쓴다.
- 연습용 프로젝트의 파일을 바꿔 쓰는 스크립트는 끝날 때 반드시 되돌린다 (Dart 는 `finally`, bash 는 `trap`). 저장소 안에 임시 폴더를 만들면 같은 자리에서 지운다.
- 종료 코드, stdout(JSON), stderr 를 따로 기록한다. 하나만 보고 판정하지 않는다 (002).
- 결과 파일에서는 로컬 절대 경로를 `<repo>`, `<scratch>`, `~/` 로 가린다. 작업 브랜치가 공개 저장소에 올라가기 때문이다 (D-08).
- 실측한 사실에는 버전과 날짜를 함께 적는다.
- 연습용 프로젝트의 패키지는 `dart pub get` 으로 받는다. `flutter pub get` 은 옵션 파일을 고친다 (004).

## Tools & Libraries

이번 세션에서 실제로 풀린 버전 (2026-10-11).

| 패키지 | 버전 | 쓰인 곳 |
|---|---|---|
| `riverpod_lint` (plugin, `^3.1.3` 이 풀린 값) | 3.1.9 | 001, 002, 003, 006 |
| `flutter_riverpod` / `riverpod` | 3.4.3 | 001, 002, 003, 004 |
| `flutter_lints` / `lints` | 6.0.0 / 6.1.0 | 전부 |
| `riverpod_annotation` | 4.0.7 | 003 |
| `riverpod_generator` / `build_runner` | 4.0.9 / 2.16.2 | 003 만 (실제 `example/` 에는 붙이지 않는다) |
| `actions/checkout` / `subosito/flutter-action` | `v7` / `v2` | 006 |

쓰지 않는 것:

- `flutter analyze` — Flutter 3.47.5 에서 plugin 진단을 내지 않는다 (PROJECT.md).
- `dart analyze <하위 폴더>` — plugin 진단을 잃는다 (001).
- 연습용 프로젝트에서의 `flutter pub get` — 옵션 파일을 고친다 (004).
- SDK tag 의 `rules.json` 을 규칙 상태의 근거로 삼는 것 — 실제 동작과 어긋난 항목이 있었다 (005).
