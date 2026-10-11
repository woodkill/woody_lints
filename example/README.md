# woody_lints 검증용 연습 프로젝트

이 폴더는 **일부러 규칙을 어긴 연습용 프로젝트**다. `woody_lints` 를 쓰는 프로젝트와 같은 모양으로 만들었다 — Flutter 패키지이고, `woody_lints` 를 `path: ..` 로 받으며, `analysis_options.yaml` 은 `include: package:woody_lints/analysis_options.yaml` 한 줄이다.

저장소의 검증 명령 `tool/verify.dart` 가 이 폴더를 `dart analyze` 로 분석하고, 나온 경고를 커밋해 둔 정답지 `expected_diagnostics.txt` 와 한 줄씩 비교한다. 같으면 통과이고 한 줄이라도 다르면 실패다. 배포 파일 `lib/analysis_options.yaml` 을 고쳤을 때 "받는 프로젝트에서 무엇이 달라지는가" 가 이 비교에서 드러난다.

이 폴더는 검증용이지 사용 예가 아니다. 설치와 사용법은 저장소 루트의 `README.md` 를 본다.

## 실행

저장소 루트에서 돌린다.

```sh
fvm dart run tool/verify.dart
```

- plugin 이 이미 준비된 상태에서 약 5초 걸린다 (2026-10-12 실측). 처음 실행은 `riverpod_lint` plugin 을 받아 컴파일하느라 더 걸린다 (사전 실측 약 15초).
- 네트워크가 필요하다. pub 서버에 닿지 못하면 plugin 이 준비되지 않아 `riverpod_lint` 경고 없이 끝난다 (사전 실측).
- CI 에서는 FVM 없이 `dart run tool/verify.dart` 로 돌린다. SDK 는 `.fvmrc` 의 버전으로 맞춘다.

배포 파일이나 이 폴더의 샘플을 일부러 바꿔 경고가 달라졌으면 정답지를 갱신한다.

```sh
fvm dart run tool/verify.dart --update
```

- 정답지를 쓰기 전에 바뀌는 줄을 화면에 보여 준다 (`- ` 는 사라지는 줄, `+ ` 는 새로 생기는 줄).
- 갱신된 정답지의 `git diff` 가 "이 변경으로 생기거나 사라진 경고" 의 기록이다. 커밋 전에 읽어 본다.
- CI 에서는 `--update` 가 거부된다 (종료 코드 64). 정답지는 로컬에서 갱신해 커밋한다.

이 폴더의 패키지를 손으로 받을 일이 있으면 `dart pub get` 을 쓴다. `flutter pub get` 은 쓰지 않는다 — `analysis_options.yaml` 에 `build/**` 제외를 써넣어 "include 한 줄" 이 아니게 만든다. 돌렸다면 `git checkout -- example/analysis_options.yaml` 로 되돌린다.

## 파일

| 파일 | 역할 | 정답지 줄 수 |
|------|------|--------------|
| `lib/added_rules.dart` | 이 패키지가 기반 세트 위에 추가하는 규칙 6개를 한 건씩 어긴다 | 6 |
| `lib/base_rules.dart` | 기반 세트(`flutter_lints` / `lints`)와 겹치는 규칙 6개와, 기반 세트만 켜는 `prefer_is_empty` 를 어긴다 | 7 |
| `lib/main.dart` | `riverpod_lint` 의 `missing_provider_scope` (warning) | 1 |
| `lib/riverpod_rules.dart` | `riverpod_lint` 의 `avoid_public_notifier_properties` (info), `provider_parameters` (warning) | 2 |
| `lib/should_not_appear.dart` | `invalid_annotation_target` 을 일으킨다. 배포 파일이 억제하므로 **나오면 안 된다** | 0 |
| `lib/generated/sample.g.dart`, `lib/generated/sample.freezed.dart` | 위반을 담은 생성 파일 흉내. 배포 파일이 분석에서 빼므로 **나오면 안 된다** | 0 |
| `analysis_options.yaml` | `include:` 한 줄. 검증 명령이 한 줄인지도 확인한다 | - |
| `expected_diagnostics.txt` | 정답지 (`exit 2` + 16줄) | - |
| `pubspec.yaml` | 저장소 루트의 `woody_lints` 를 `path: ..` 로 받는다 | - |
| `pubspec.lock` | 커밋한다. 로컬과 CI 가 같은 패키지 버전으로 판정하게 하려는 것이다. `riverpod_lint` plugin 의 버전은 이 파일이 묶지 못한다 (Analysis Server 가 따로 받는다) | - |

## 정답지 형식

`expected_diagnostics.txt` 는 손으로 쓰지 않고 `--update` 로 만든다.

```text
# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12
# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: fvm dart run tool/verify.dart --update
exit 2
lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
lib/added_rules.dart:18  info  always_declare_return_types
…
```

- `#` 줄은 머리 주석이다. `# 실측:` 줄은 `--update` 가 그때의 SDK · plugin 버전과 날짜로 다시 쓴다.
- 주석이 아닌 첫 줄 `exit N` 은 **`dart analyze` 의 종료 코드**다. warning 이 하나라도 있으면 2, error 가 있으면 3, info 뿐이면 0 이다. 지금은 `riverpod_lint` 의 warning 이 있어 `exit 2` 다.
- 그 뒤는 경고 한 건에 한 줄, `상대경로:줄  강도  규칙이름` 이다 (칸 사이는 공백 두 칸). 메시지 문구는 적지 않는다.
- 줄은 문자열로 정렬한다. 그래서 `:13` 이 `:7` 보다 앞에 온다.
- 경고가 생기거나, 사라지거나, 강도가 바뀌거나, `exit` 줄이 달라지면 검증이 실패한다.

## 검증 명령의 종료 코드

정답지의 `exit N` 과는 다른 숫자다 — 아래는 `tool/verify.dart` 자신의 종료 코드다.

| 종료 코드 | 뜻 |
|-----------|----|
| 0 | 단계 4개 모두 통과 (`--update` 로 갱신한 실행 포함) |
| 1 | 단계 중 하나라도 실패 (plugin 준비 실패, 도구 사망 포함) |
| 64 | 사용법 오류 (모르는 인자, CI 에서 `--update`) |
| 69 | 하위 명령 실패 (`pub get`) — 검증을 시작하지 않음 |
| 70 | 스크립트가 예외로 끝남 (파일 형식 · 파일 작업 · 프로세스 실행 실패) |
| 78 | 실행 중인 SDK 가 `.fvmrc` 와 다름 — 검증을 시작하지 않음 |

단계는 네 개다: `[1/4]` `lib/` 에 `.dart` 파일 없음, `[2/4]` 배포 파일의 규칙 이름, `[3/4]` `example/` 옵션 파일, `[4/4]` `example/` 정답지 비교. 하나가 실패해도 나머지를 모두 돌린다.

## 검증이 실제로 잡아내는지 확인한 기록

"통과" 만 내는 점검은 점검을 안 하는 것과 구별되지 않는다. 그래서 틀린 상태를 일부러 하나씩 만들어 검증이 정말 실패하는지 보고 적어 둔다.

실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12

실행한 명령: `fvm dart run tool/verify.dart` (M8 은 `CI=true` 로, M9 는 `.fvm/flutter_sdk/bin/dart` 로). macOS arm64 에서 돌렸고, 변경은 한 번에 하나만 만들었다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M1 | `lib/analysis_options.yaml` 에서 `- prefer_final_locals` 줄을 지움 | `[4/4]` | `- lib/added_rules.dart:24  info  prefer_final_locals` | 1 | VERIFY-08 — 규칙 하나를 지운 변경 |
| M2 | `example/analysis_options.yaml` 의 include 줄을 지움 (빈 파일) | `[3/4]` 과 `[4/4]` | `- ` 정답지의 16줄 전부<br>`+ lib/should_not_appear.dart:5  warning  invalid_annotation_target` | 1 | VERIFY-08 — include 줄을 지운 변경 |
| M3 | `lib/analysis_options.yaml` 의 `errors:` 블록 두 줄(`errors:` 와 `invalid_annotation_target: ignore`)을 지움 | `[4/4]` | `+ lib/should_not_appear.dart:5  warning  invalid_annotation_target` | 1 | D-03 — annotation 샘플 |
| M4 | `lib/analysis_options.yaml` 의 exclude 에서 `- '**/*.g.dart'` 줄을 지움 | `[4/4]` | `+ lib/generated/sample.g.dart:4  info  avoid_print`<br>`+ lib/generated/sample.g.dart:4  info  prefer_single_quotes` | 1 | D-03 — 생성 파일 샘플 |
| M5 | `lib/analysis_options.yaml` 의 exclude 에서 `- '**/*.freezed.dart'` 줄을 지움 | `[4/4]` | `+ lib/generated/sample.freezed.dart:4  info  avoid_print`<br>`+ lib/generated/sample.freezed.dart:4  info  prefer_single_quotes` | 1 | D-03 — 생성 파일 샘플 |
| M6 | `lib/analysis_options.yaml` 의 규칙 목록 끝에 `- unnecessary_await_in_return` 한 줄을 더함 (이 SDK 에서 deprecated) | `[2/4]` 만. `[4/4]` 는 통과 | 차이 없음. `[2/4]` 가 낸 줄:<br>`build/woody_rule_check/analysis_options.yaml:41  warning  deprecated_lint  (unnecessary_await_in_return)` | 1 | VERIFY-02 — deprecated 규칙 |
| M7 | 빈 파일 `lib/_probe.dart` 를 만듦 | `[1/4]` | 차이 없음. `[1/4]` 가 낸 줄:<br>`lib/_probe.dart` | 1 | VERIFY-07 — `lib/` 의 `.dart` 파일 |
| M8 | 변경 없이 `CI=true` 를 주고 `--update` 로 실행 | 단계를 시작하지 않음 (준비에서 거부) | 해당 없음. 정답지를 쓰지 않았다 | 64 | D-14 — CI 에서 `--update` 거부 |
| M9 | `.fvmrc` 의 `flutter` 값을 `0.0.0` 으로 바꿈 | 단계를 시작하지 않음 (준비에서 거부) | 해당 없음 | 78 | D-12 — SDK 불일치 |

`- ` 는 정답지에는 있는데 나오지 않은 줄, `+ ` 는 정답지에 없는데 나온 줄이다. 종료 코드는 검증 명령의 것이다. 걸린 시간은 M1 · M3 ~ M7 이 5초, M2 가 2초, M8 · M9 가 1초 미만이었다.

읽는 법은 다음과 같다.

- **M2 는 종료 코드만으로는 잡지 못한다.** include 줄을 지우면 경고 16줄이 전부 사라지지만, 억제되던 `invalid_annotation_target` warning 이 되살아나 `dart analyze` 의 종료 코드는 정답지의 `exit 2` 와 같은 2 다 (화면에 `종료 코드:` 줄이 나오지 않았고, 같은 상태에서 `dart analyze` 를 따로 돌려 2 를 확인했다). 잡아낸 것은 줄 단위 비교다. M2 의 차이 전체는 아래와 같다.

  ```text
  - lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
  - lib/added_rules.dart:18  info  always_declare_return_types
  - lib/added_rules.dart:24  info  prefer_final_locals
  - lib/added_rules.dart:29  info  prefer_single_quotes
  - lib/added_rules.dart:33  info  unawaited_futures
  - lib/added_rules.dart:7  info  prefer_const_constructors
  - lib/base_rules.dart:12  info  sort_child_properties_last
  - lib/base_rules.dart:17  info  use_build_context_synchronously
  - lib/base_rules.dart:22  info  avoid_print
  - lib/base_rules.dart:30  info  control_flow_in_finally
  - lib/base_rules.dart:34  info  slash_for_doc_comments
  - lib/base_rules.dart:38  info  prefer_is_empty
  - lib/base_rules.dart:8  info  sized_box_for_whitespace
  - lib/main.dart:5  warning  missing_provider_scope
  - lib/riverpod_rules.dart:17  warning  provider_parameters
  - lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties
  + lib/should_not_appear.dart:5  warning  invalid_annotation_target
  ```

- **M6 은 정답지 비교가 아니라 규칙 이름 단계가 잡는다.** deprecated 규칙은 include 를 거치면 보고되지 않아 정답지는 그대로다. 그래서 `[2/4]` 가 배포 파일을 `build/woody_rule_check/` 에 복사해 따로 본다 (복사본의 줄 번호는 원본과 같다). 두 단계는 서로를 대신하지 못한다.
- **M3 ~ M5 는 "나오면 안 되는 경고" 샘플이 헛통과가 아니라는 확인이다.** 배포 파일의 해당 설정을 지우면 그 샘플의 경고가 실제로 나타난다.
- M3 에서 `errors:` 를 블록째 지운 것은, `invalid_annotation_target: ignore` 한 줄만 지우면 빈 `errors:` 때문에 `included_file_warning` 이 하나 더 섞인다는 사전 실측이 있어서다. 한 줄만 지운 경우는 이 기록에서 다시 재지 않았다.
- M2 의 화면에서 `plugin` 줄은 `riverpod_lint 3.1.9` 였다. 그 실행에는 `riverpod_lint` 경고가 하나도 없었다 — 이 줄은 전용 상태 폴더에 남아 있는 값을 읽는 것이라, plugin 이 그 실행에서 돌았다는 표시가 아니다.

변경은 모두 커밋하지 않고 되돌렸다 (`git status` 로 확인). 변경 하나를 돌린 직후 그 파일을 되돌렸고, 끝에 검증 명령이 다시 종료 코드 0 인 것을 봤다.

이 기록이 재지 않은 것도 있다. 기반 세트가 이미 켜는 규칙(예: `avoid_print`)을 배포 파일에서 지웠을 때 정답지가 그대로인지는 보지 않았다 (Phase 4 의 중복 선언 정리 때 확인한다). 이 기록은 한 번의 확인이고, 늘 도는 대조군 fixture 는 Phase 3 (VERIFY-05) 에서 만든다.

항목의 `VERIFY-NN` 은 `.planning/REQUIREMENTS.md` 의 요구사항 번호, `D-NN` 은 `.planning/phases/02-verification-harness/02-CONTEXT.md` 의 결정 번호다.
