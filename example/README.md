# woody_lints 검증용 연습 프로젝트

이 폴더는 **일부러 규칙을 어긴 연습용 프로젝트**다. `woody_lints` 를 쓰는 프로젝트와 같은 모양으로 만들었다 — Flutter 패키지이고, `woody_lints` 를 `path: ..` 로 받으며, `analysis_options.yaml` 은 `include: package:woody_lints/analysis_options.yaml` 한 줄이다. 저장소 루트의 `fixtures/` 아래 다섯 폴더가 이 폴더의 샘플을 복사해 다른 조합을 받는다 (아래 "연습용 프로젝트 여섯").

저장소의 검증 명령 `tool/verify.dart` 가 이 폴더를 `dart analyze` 로 분석하고, 나온 경고를 커밋해 둔 정답지 `expected_diagnostics.txt` 와 한 줄씩 비교한다. 연습용 프로젝트 여섯 가운데 이 폴더(옛 주소)의 정답지만 분리 전의 1.3.0 과 같은 것이고, 나머지는 아래 표에 있다. 같으면 통과이고 한 줄이라도 다르면 실패다. 같은 줄이 여러 건 나오면 건수까지 견준다. 배포 파일(`lib/base.yaml` 등 `lib/` 의 조각 · 묶음 · 별칭)을 고쳤을 때 "받는 프로젝트에서 무엇이 달라지는가" 가 이 비교에서 드러난다.

이 폴더는 검증용이지 사용 예가 아니다. 설치와 사용법은 저장소 루트의 `README.md` 를 본다.

## 실행

저장소 루트에서 돌린다.

```sh
fvm dart run tool/verify.dart
```

- plugin 이 준비된 상태에서 연습용 프로젝트 여섯 모두 약 22초 걸린다 (2026-10-12 실측, 20 ~ 23초). 처음 실행은 plugin 을 쓰는 넷이 각각 `riverpod_lint` 를 받아 컴파일하느라 약 69초 걸린다 (전용 상태 폴더를 비운 실행, 2026-10-12 실측).
- 네트워크가 필요하다. pub 서버에 닿지 못하면 plugin 이 준비되지 않아 `riverpod_lint` 경고 없이 끝난다 (사전 실측).
- CI 에서는 FVM 없이 `dart run tool/verify.dart` 로 돌린다. SDK 는 `.fvmrc` 의 버전으로 맞춘다.

배포 파일이나 연습용 프로젝트의 샘플을 일부러 바꿔 경고가 달라졌으면 정답지를 갱신한다.

```sh
fvm dart run tool/verify.dart --update
```

- 정답지 **다섯을 한 번에** 다시 쓴다 — 연습용 프로젝트마다 바뀐 줄을 보여 주고, 바뀐 것만 쓰고, 끝에 `정답지를 썼다 (N개):` 와 쓴 파일 목록을 찍는다. 단계 줄의 결과는 `바뀐 줄 없음` / `갱신` 이다. 바뀐 것이 없으면 `바뀐 정답지가 없다 — 쓰지 않았다` 를 찍고 아무것도 쓰지 않는다 (머리 주석의 날짜도 그대로). 이름을 줘서 하나만 갱신하는 인자는 없다 (D-05). `recommended` 는 정답지가 없어 쓰지 않는다 — 같은 실행의 `example` 결과와 견주는 단계라 갱신 모드에서도 `통과` / `실패` 다.
- 정답지를 쓰기 전에 바뀌는 줄을 화면에 보여 준다 (`- ` 는 사라지는 줄, `+ ` 는 새로 생기는 줄).
- 갱신된 정답지의 `git diff` 가 "이 변경으로 생기거나 사라진 경고" 의 기록이다. 커밋 전에 읽어 본다.
- CI 에서는 `--update` 가 거부된다 (종료 코드 64). 정답지는 로컬에서 갱신해 커밋한다.
- 같은 실행에서 다른 단계가 실패했으면 정답지를 쓰지 않고 `다른 단계가 실패해 정답지를 쓰지 않았다` 를 찍는다 (종료 코드 1). 실패를 고친 뒤 다시 돌린다. plugin 준비 실패와 도구 사망에서는 전과 같이 쓰지 않는다 — 그때는 그 연습용 프로젝트 단계의 실패 내용이 찍힌다. 썼을 때는 `정답지를 썼다 (N개):` 와 목록이 찍힌다. 2026-10-12 에 더한 안전장치다 (아래 M12, M15 ~ M17).

이 폴더의 패키지를 손으로 받을 일이 있으면 `dart pub get` 을 쓴다. `flutter pub get` 은 쓰지 않는다 — `analysis_options.yaml` 에 `build/**` 제외를 써넣어 "include 한 줄" 이 아니게 만든다. 돌렸다면 `git checkout -- example/analysis_options.yaml` 로 되돌린다.

## 파일

| 파일 | 역할 | 정답지 줄 수 |
|------|------|--------------|
| `lib/added_rules.dart` | 이 패키지가 기반 세트 위에 추가하는 규칙 6개를 한 건씩 어긴다 | 6 |
| `lib/base_rules.dart` | 기반 세트(`flutter_lints` / `lints`)가 켜는 규칙 7개를 한 건씩 어긴다 — 그중 6개는 2.0.0 전까지 배포 파일에도 겹쳐 적혀 있었다 | 7 |
| `lib/main.dart` | `riverpod_lint` 의 `missing_provider_scope` (warning) | 1 |
| `lib/riverpod_rules.dart` | `riverpod_lint` 의 `avoid_public_notifier_properties` (info), `provider_parameters` (warning) | 2 |
| `lib/should_not_appear.dart` | `invalid_annotation_target` 을 일으킨다. 배포 파일이 억제하므로 **나오면 안 된다** | 0 |
| `lib/generated/sample.g.dart`, `lib/generated/sample.freezed.dart` | 위반을 담은 생성 파일 흉내. 배포 파일이 분석에서 빼므로 **나오면 안 된다** | 0 |
| `analysis_options.yaml` | `include:` 한 줄. 검증 명령이 한 줄인지도 확인한다 | - |
| `expected_diagnostics.txt` | 정답지 (`exit 2` + 16줄) | - |
| `pubspec.yaml` | 저장소 루트의 `woody_lints` 를 `path: ..` 로 받는다 | - |
| `pubspec.lock` | 커밋한다. 로컬과 CI 가 같은 패키지 버전으로 판정하게 하려는 것이다. `riverpod_lint` plugin 의 버전은 이 파일이 묶지 못한다 (Analysis Server 가 따로 받는다) | - |

## 연습용 프로젝트 여섯

검증 명령은 이 폴더와 `fixtures/` 아래 다섯 폴더를 차례로 분석한다. 같은 샘플을 서로 다른 옵션 파일로 받아, 조합마다 어떤 경고가 나오고 나오지 않는지를 정답지로 고정한다. "나오지 않는다" 는 줄 수만 세지 않고, 받지 않은 설정이 적용되지 않았을 때 **남는 줄**로 증명한다.

| # | 폴더 | include | plugin | 정답지 | 줄 수 | 증명하는 것 |
|---|------|---------|--------|--------|-------|-------------|
| 1 | `example/` | 옛 주소 한 줄 (`analysis_options.yaml`) | 씀 | `expected_diagnostics.txt` (`exit 2`) | 16 | 분리 전후로 정답지가 같다. 별칭이 plugin 을 잃지 않는다 |
| 2 | `fixtures/recommended/` | `recommended.yaml` | 씀 | 없음 (같은 실행의 `example` 결과와 견줌) | 16 | 옛 주소와 같은 진단 |
| 3 | `fixtures/base_only/` | `base.yaml` 만 | 안 씀 | `expected_diagnostics.txt` (`exit 2`) | 18 | 기본 규칙은 나오고 `riverpod_lint` 진단은 안 나온다. 생성 파일의 규칙 진단과 `invalid_annotation_target` 은 나온다 |
| 4 | `fixtures/overrides/` | 묶음 + 끄는 설정 | 씀 | `expected_diagnostics.txt` (`exit 2`) | 18 | 끈 진단만 사라진다 — 프로젝트 전체 · 파일 · 한 줄 × 규칙 · plugin. 접두사 없는 주석은 끄지 못한다 |
| 5 | `fixtures/base_riverpod/` | `base.yaml` + `riverpod.yaml` | 씀 | `expected_diagnostics.txt` (`exit 2`) | 21 | Riverpod 조각만 받아도 plugin 이 돈다. codegen 설정은 딸려 오지 않는다 |
| 6 | `fixtures/base_codegen/` | `base.yaml` + `codegen.yaml` | 안 씀 | `expected_diagnostics.txt` (`exit 0`) | 13 | codegen 조각만 받아도 생성 파일이 빠진다 (Dart 3.13.4 의 규칙 진단 기준). plugin 은 딸려 오지 않는다 |

화면과 검증 명령의 순서는 1 → 2 → 3 → 5 → 6 → 4 다 (`[5/10]` ~ `[10/10]`). 2 는 1 의 결과를 받아 견주므로 반드시 1 뒤에 돈다.

네 경우 — Riverpod 을 받나 × codegen 을 받나 — 가 모두 채워진다.

| | codegen 받음 | codegen 안 받음 |
|---|---|---|
| **Riverpod 받음** | 1 (옛 주소) · 2 (묶음) | 5 (기본 + Riverpod) |
| **Riverpod 안 받음** | 6 (기본 + codegen) | 3 (기본만) |

- 폴더마다 `pubspec.yaml` 은 저장소 루트를 `path: ../..` 로 받고, `lib/` 는 이 폴더 `lib/` 의 글자 그대로 복사본이다 (줄 번호가 같아야 정답지를 견줄 수 있다). 예외는 `lib/relative_imports_rule.dart` 하나다 — `prefer_relative_imports` 는 자기 패키지를 `package:` 주소로 import 할 때만 걸리므로, 3행 import 의 패키지 이름이 그 폴더 `pubspec.yaml` 의 `name:` 이다 (나머지 줄은 같다). 이 파일은 `cp` 로 덮어쓰지 말고 3행의 이름을 맞춘다. `overrides` 만 끄는 방법의 샘플 `lib/suppress/` 5파일을 더 둔다. `pubspec.lock` 은 이 폴더의 것에서 `path` 줄만 `"../.."` 로 바꾼 복사본이고 커밋한다. 이 폴더의 샘플을 고치면 다섯 복사본도 함께 고친다.
- 상태 폴더는 `.dart_tool/woody_verify/<폴더>/` 로 연습용 프로젝트마다 따로다 — 합치면 plugin 폴더가 여럿이 되어 화면의 `plugin` 줄이 버전을 읽지 못한다. plugin 을 쓰지 않는 둘(3 · 6)은 plugin 폴더가 0개인 것이 정상이고, 정답지 머리 주석에 `riverpod_lint 해당 없음` 이 적힌다.
- 생성 파일 제외(`codegen.yaml` 의 `analyzer.exclude`)는 이 SDK(Dart 3.13.4)에서 규칙 진단에만 통하고 plugin 진단에는 통하지 않는다 (2026-10-12, spike 012). 그래서 생성 파일 샘플(`lib/generated/`)에는 plugin 위반을 두지 않는다. 다음 SDK 에서는 규칙 진단에도 통하지 않을 수 있다 (spike 016).
- `overrides` 의 `plugins:` 에 적은 `version:` 은 `lib/riverpod.yaml` 의 선언과 같아야 한다 — 다르면 `[4/10]` 가 실패한다. `version` 없이 `diagnostics:` 만 적으면 끄기가 경고 없이 무시된다 (아래 M19).
- `fixtures/` 에서도 `flutter pub get` 을 돌리지 않는다 (옵션 파일에 `build/**` 제외를 써넣어 `[4/10]` 가 실패한다). 저장소 루트의 분석은 `example/**` 와 `fixtures/**` 를 뺀다.

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
- 경고가 생기거나, 사라지거나, 강도가 바뀌거나, `exit` 줄이 달라지면 검증이 실패한다. 같은 줄이 여러 건이면 건수까지 견준다 — 한 줄에 같은 규칙이 두 번 걸리면 정답지에도 그 줄이 두 번 있어야 한다 (2026-10-12 에 고침, 아래 M10 · M11).

## 검증 명령의 종료 코드

정답지의 `exit N` 과는 다른 숫자다 — 아래는 `tool/verify.dart` 자신의 종료 코드다.

| 종료 코드 | 뜻 |
|-----------|----|
| 0 | 단계 10개 모두 통과 (`--update` 로 갱신한 실행 포함) |
| 1 | 단계 중 하나라도 실패 (plugin 준비 실패, 도구 사망 포함) |
| 64 | 사용법 오류 (모르는 인자, CI 에서 `--update`) |
| 69 | 하위 명령 실패 (`pub get`) — 검증을 시작하지 않음 |
| 70 | 스크립트가 예외로 끝남 (파일 형식 · 파일 작업 · 프로세스 실행 실패 — 기반 세트 YAML 에서 규칙을 하나도 읽지 못한 경우 포함) |
| 78 | 실행 중인 SDK 가 `.fvmrc` 와 다름 — 검증을 시작하지 않음 |

단계는 열 개다: `[1/10]` `lib/` 에 `.dart` 파일 없음, `[2/10]` 배포 파일(조각 셋)의 규칙 이름, `[3/10]` 배포 파일의 구성 (묶음 `recommended.yaml` 과 별칭 `analysis_options.yaml` 이 `include:` 만 담는지, `lib/base.yaml` 의 규칙이 기반 세트 — 저장소 루트가 받은 `lints` · `flutter_lints` 의 YAML — 와 겹치지 않는지, `RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록이 같은지. analyzer 를 돌리지 않고 파일끼리 견준다. 규칙 목록은 열 0 주석 뒤의 줄도 읽는다 (2026-10-13 에 고침, 아래 M26)), `[4/10]` 연습용 프로젝트 여섯의 옵션 파일 (주석 · 빈 줄을 뺀 내용을 통째로 견준다 — `overrides` 의 `version:` 은 `lib/riverpod.yaml` 의 선언과 같아야 한다), `[5/10]` ~ `[10/10]` 연습용 프로젝트마다 정답지 비교 (위 표의 순서. `recommended` 는 같은 실행의 `example` 결과와). 하나가 실패해도 나머지를 모두 돌린다. `[2/10]` 는 배포 파일을 `plugins:` 없이 복사한 폴더를 `dart analyze` 로 분석해, 종료 코드가 0 이 아니거나 진단이 하나라도 있으면 실패한다 — deprecated / removed / 없는 규칙뿐 아니라 겹친 규칙 · 모르는 키 · 없는 진단 코드 같은 옵션 경고도 실패다. 깨진 YAML 은 종료 코드 3 에 진단 0건으로 나오므로 같은 폴더를 형식 인자 없이 한 번 더 돌려 `parse_error` 줄을 보여 준다. 배포 파일의 최상위 `linter:` 블록에서 `- 규칙이름` 줄을 하나도 세지 못해도 실패한다 — 규칙을 다른 파일로 옮길 때 경로를 잘못 잡은 것이 통과로 보이지 않게 (2026-10-12, 아래 M13 ~ M17).

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

이 기록이 재지 않은 것도 있다. 기반 세트가 이미 켜는 규칙(예: `avoid_print`)을 배포 파일에서 지웠을 때 정답지가 그대로인지는 2026-10-13 에 확인했다 — 아래 "추가 실측 — 배포 파일의 구성 (04-01)" 의 확인 기록 (i). 이 기록은 한 번의 확인이고, 늘 도는 대조군 fixture 는 Phase 3 (VERIFY-05) 에서 만든다.

### 추가 실측 — 건수 비교 · `--update` 안전장치 · 규칙 0개 (gap 닫기 02-05)

실측 (02-05): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12

실행한 명령: `fvm dart run tool/verify.dart` (M12 와 그 대조 실행은 `--update` 를 붙여). 변경은 한 번에 하나만 만들고 바로 되돌렸다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M10 | 정답지 끝에 이미 있는 줄 `lib/base_rules.dart:22  info  avoid_print` 를 한 번 더 적음 (정답지에 같은 줄 2개, 실제는 1건) | `[4/4]` | `- lib/base_rules.dart:22  info  avoid_print` (1줄) | 1 | 성공 기준 1 · D-04 — 같은 줄의 건수 (02-VERIFICATION.md Gap 1, CR-01) |
| M11 | `example/lib/dup_probe.dart` 의 한 줄에 `print` 둘을 두고 (`void twoPrints() { print('x'); print('y'); }`), 정답지에는 그 줄을 1개만 더함 | `[4/4]` | `+ lib/dup_probe.dart:2  info  avoid_print` (1줄) | 1 | 성공 기준 1 · D-04 — 같은 줄의 건수 (02-VERIFICATION.md Gap 1, CR-01) |
| M12 | `example/analysis_options.yaml` 을 빈 파일로 두고 `--update` 로 실행 | `[3/4]`. `[4/4]` 는 갱신 모드라 통과로 찍힌다 | 정답지를 쓰지 않았다 (파일의 git hash 가 실행 전과 같다). 화면: `다른 단계가 실패해 정답지를 쓰지 않았다 — 실패를 먼저 고친 뒤 다시 실행하세요.` | 1 | D-14 — 망가진 실행의 `--update` (WR-01 case 1) |
| M13 | `lib/analysis_options.yaml` 의 `linter:` 를 `lintr:` 로 바꿈 | `[2/4]` 과 `[4/4]` | `[2/4]` 가 낸 줄: `` `lib/analysis_options.yaml` 에서 규칙을 하나도 읽지 못했다 — 최상위 `linter:` 아래 `rules:` 목록이 비어 있거나 없다. ``<br>`[4/4]`: `- ` 이 패키지가 추가하는 규칙 6줄 (`lib/added_rules.dart` 의 6줄) | 1 | VERIFY-02 — 규칙 0개 (WR-03 의 절반) |
| M14 | 규칙 목록(`linter:` 블록)을 새 파일 `lib/_probe_rules.yaml` 로 옮기고, 배포 파일은 `include: package:woody_lints/_probe_rules.yaml` 로 그 파일을 받게 함 (`analyzer:` 와 `plugins:` 는 배포 파일에 남김) | `[2/4]` 만. `[4/4]` 는 통과 | 차이 없음 (16줄 그대로 — 규칙은 include 를 거쳐 그대로 적용된다). `[2/4]` 가 낸 줄은 M13 과 같다 | 1 | VERIFY-02 — Phase 3 의 규칙 파일 이동 모양 |

`- ` 와 `+ ` 의 뜻은 위 표와 같다. 걸린 시간은 M10 · M14 가 6초, M11 · M13 이 5초, M12 가 3초였다.

- **고치기 전에는 M10 · M11 이 종료 코드 0 으로 통과했다.** 정답지 비교가 "이 줄이 있는가" 만 보고 "몇 번 있는가" 를 보지 않았기 때문이다 (02-VERIFICATION.md Gap 1). 고치기 직전의 스크립트로 같은 두 변경을 이 저장소에서 다시 만들어 `[4/4] 통과` 를 본 뒤 고쳤다. M11 의 샘플은 정답지에 그 줄을 **두 번** 적어야 통과한다.
- **M12 도 고치기 전에는 정답지를 덮어썼다.** 같은 변경에서 고치기 전의 `--update` 는 정답지를 `exit 2` + `lib/should_not_appear.dart:5  warning  invalid_annotation_target` 한 줄로 바꿔 썼다 (종료 코드 1, 쓴 파일은 되돌렸다). M13 은 고치기 전에 `[2/4] 통과` · `[4/4] 실패` 였다 — 규칙을 하나도 보지 못한 단계가 통과로 찍혔다.
- **`--update` 의 정상 경로는 그대로다.** M10 의 상태(정답지에 같은 줄 2개, 단계 넷은 문제 없음)에서 `--update` 를 돌리면 `- lib/base_rules.dart:22  info  avoid_print` 를 보여 준 뒤 정답지를 16줄로 되돌려 쓰고 `정답지를 썼다: example/expected_diagnostics.txt` 를 찍는다 (종료 코드 0, 5초; 쓴 파일은 되돌렸다). `--update` 가 자기가 쓰려는 차이에 막히지는 않는다. `CI=true` 를 준 `--update` 는 여전히 종료 코드 64 다.
- **M14 는 Phase 3 을 위한 확인이다.** 규칙을 `base.yaml` 같은 다른 파일로 옮길 때 `[2/4]` 의 대상 파일을 함께 옮기지 않으면, 규칙이 멀쩡히 적용되어 `[4/4]` 가 통과하더라도 `[2/4]` 가 바로 실패한다. 고치기 전의 스크립트는 이 모양에서 단계 넷이 모두 통과했다 (02-VERIFICATION.md 의 복사본 실측 — 이번에 고치기 전 스크립트로 다시 재지는 않았다).
- **막지 않는 것도 있다.** plugin 버전을 읽지 못해 화면의 `plugin` 줄이 `?` 인 실행에서 단계 넷이 모두 통과하면 `--update` 는 지금도 정답지를 쓰고 머리 주석에 `riverpod_lint ?` 를 적는다 (02-REVIEW.md WR-01 의 둘째 경우 — 이번에 다시 재지 않았다). `[2/4]` 가 세 코드 밖의 옵션 경고와 깨진 YAML 을 실패로 치지 않던 것은 2026-10-12 에 고쳤다 (아래 M15 ~ M17).

변경은 모두 커밋하지 않고 되돌렸다 (`git status` 와, 정답지 · `lib/` 를 이 실측 전의 커밋과 견준 `git diff` 로 확인). `--update` 를 돌린 두 실행 뒤에는 정답지를 바로 되돌렸고, 끝에 검증 명령이 다시 종료 코드 0 인 것을 봤다.

### 추가 실측 — 망가진 배포 파일의 `--update` (03-01)

실측 (03-01): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12

실행한 명령: 입력마다 `fvm dart run tool/verify.dart --update` 와 `fvm dart run tool/verify.dart` 를 한 번씩. 세 입력은 `lib/analysis_options.yaml` 에만 넣었고, 변경은 한 번에 하나만 만들고 바로 되돌렸다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M15 | `lib/analysis_options.yaml` 46행 `- '**/*.freezed.dart'` 의 끝 따옴표를 뗌 (닫지 않은 따옴표로 깨진 YAML) | `--update` 에서 `[2/4]` (갱신 모드의 `[4/4]` 는 통과로 찍힌다). 보통 실행에서 `[2/4]` 과 `[4/4]` | `[2/4]` 가 낸 줄: `error - analysis_options.yaml:47:8 - While parsing a block collection, expected '-'. - parse_error`<br>정답지를 쓰지 않았다 (파일의 git hash 가 실행 전과 같다) | 1 | CONTEXT '가장 먼저 할 일' — 망가진 배포 파일의 --update (02-UAT.md 9번, WR-03 의 다른 절반) |
| M16 | `lib/analysis_options.yaml` 21행 `rules:` 를 `ruels:` 로 바꿈 | `--update` 에서 `[2/4]` (갱신 모드의 `[4/4]` 는 통과로 찍힌다). 보통 실행에서 `[2/4]` 과 `[4/4]` | `[2/4]` 가 낸 줄: `build/woody_rule_check/analysis_options.yaml:21  warning  unsupported_option`<br>정답지를 쓰지 않았다 (파일의 git hash 가 실행 전과 같다) | 1 | CONTEXT '가장 먼저 할 일' — 망가진 배포 파일의 --update (02-UAT.md 9번, WR-03 의 다른 절반) |
| M17 | `lib/analysis_options.yaml` 40행 뒤에 `- avoid_print # dup-probe` (겹친 규칙), 44행 뒤에 `no_such_code_zz9: ignore` (없는 진단 코드) 를 더함 | `--update` 에서 `[2/4]` (갱신 모드의 `[4/4]` 는 통과로 찍힌다). 보통 실행에서 `[2/4]` 과 `[4/4]` | `[2/4]` 가 낸 줄:<br>`build/woody_rule_check/analysis_options.yaml:41  warning  duplicate_rule  (avoid_print)`<br>`build/woody_rule_check/analysis_options.yaml:46  warning  unrecognized_error_code`<br>정답지를 쓰지 않았다 (파일의 git hash 가 실행 전과 같다) | 1 | CONTEXT '가장 먼저 할 일' — 망가진 배포 파일의 --update (02-UAT.md 9번, WR-03 의 다른 절반) |

세 입력 모두 `--update` 의 화면에 `다른 단계가 실패해 정답지를 쓰지 않았다 — 실패를 먼저 고친 뒤 다시 실행하세요.` 와 `점검 실패 (4개 중 1개)` 가 찍혔고, 보통 실행은 `점검 실패 (4개 중 2개)` 였다. 되돌린 뒤의 보통 실행은 종료 코드 0, `점검 통과 (4개 중 4개)` 다.

- **고치기 전에는 세 입력 모두 `--update` 가 정답지를 썼다.** 고치기 직전의 스크립트로 같은 세 변경을 이 저장소에서 만들어 돌렸더니 셋 다 종료 코드 0, `[2/4] 통과`, `[4/4] 통과`, `정답지를 썼다: example/expected_diagnostics.txt`, `점검 통과 (4개 중 4개)` 였다. 쓴 정답지는 이랬다 (쓴 파일은 되돌렸다) — M15 는 `exit 3` + `lib/should_not_appear.dart:5  warning  invalid_annotation_target` 1줄 (include 가 깨져 규칙 16줄이 전부 사라졌다), M16 은 이 패키지가 추가하는 규칙 6줄이 빠지고 `analysis_options.yaml:1  warning  included_file_warning` 1줄이 더해진 것, M17 은 16줄 그대로에 `analysis_options.yaml:1  warning  included_file_warning` 2줄이 더해진 것. 보통 실행은 고치기 전에도 셋 다 종료 코드 1 이었지만 `[4/4]` 만 실패했다 (`점검 실패 (4개 중 1개)`).
- **잡는 것은 `[2/4]` 의 새 통과 조건(exit 0 이고 진단 0건) 이다.** 갱신 모드의 `[4/4]` 는 자기가 쓰려는 차이에 막히지 않도록 늘 통과로 찍힌다. 그래서 망가진 배포 파일은 `[2/4]` 가 실패로 잡아야 "다른 단계가 실패하면 쓰지 않는다" 는 안전장치(M12)가 돈다. 고치기 전의 `[2/4]` 는 deprecated / removed / 없는 규칙의 세 코드만 골랐다 — 세 입력의 진단은 그 밖의 코드이거나(M16 · M17) 아예 JSON 에 나오지 않았다(M15).
- **깨진 YAML 은 JSON 에 진단이 없다.** M15 의 규칙 검사 복사본은 종료 코드 3 인데 `--format=json` 출력의 진단이 0건이다. 그래서 같은 폴더를 형식 인자 없이 한 번 더 돌린 출력에서 `parse_error` 줄을 골라 보여 준다 (spike 013). 그 줄은 따옴표를 뗀 46행이 아니라 파서가 막힌 47행을 가리킨다.
- **세 코드 밖의 진단에도 규칙 이름을 붙인다.** M17 의 `duplicate_rule` 줄 끝의 `(avoid_print)` 는 진단이 가리키는 복사본의 줄에서 읽은 것이다. `unrecognized_error_code` 줄은 규칙 줄이 아니라 그대로 보인다.
- M13 의 문구는 03-01 에서 `` `lib/analysis_options.yaml` 의 최상위 `linter:` 블록 안에서 `- 규칙이름` 줄을 하나도 세지 못했다. `` 로 바뀌었다 — 코드는 `rules:` 키를 보지 않는다. M13 행은 그날 실제로 찍힌 문구 그대로 둔다.

변경은 모두 커밋하지 않고 되돌렸다 (`git status` 와, 정답지 · `lib/` 를 `19ae5ec` · `90a2736` 과 견준 `git diff` 로 확인). `--update` 를 돌린 실행 뒤에는 정답지를 바로 되돌렸고, 끝에 검증 명령이 다시 종료 코드 0 인 것을 봤다.

### 추가 실측 — 새 연습용 프로젝트가 헛통과가 아닌지 (03-03)

실측 (03-03): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 9개). 변경은 한 번에 하나만 만들고 바로 `git checkout` 으로 되돌렸다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M18 | `lib/recommended.yaml` 에서 `- package:woody_lints/riverpod.yaml` 줄을 지움 (묶음이 Riverpod 조각을 잃음) | `[4/9] example` 만. `[5/9] recommended`, `[7/9] base_riverpod`, `[9/9] overrides` 는 통과 | `[4/9]`: `종료 코드: 정답지 2, 실제 0`<br>`- lib/main.dart:5  warning  missing_provider_scope`<br>`- lib/riverpod_rules.dart:17  warning  provider_parameters`<br>`- lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties` | 1 | PRESET-08 · D-03 — 묶음이 Riverpod 조각을 잃으면 옛 주소 fixture 가 잡는다 |
| M19 | `fixtures/overrides/analysis_options.yaml` 에서 `version: ^3.1.3` 줄을 지움 (`diagnostics:` 만 남김) | `[3/9]` 와 `[9/9] overrides` | `[3/9]`: `` `fixtures/overrides/analysis_options.yaml` 이 정해진 내용이 아니다 `` (주석·빈 줄을 뺀 내용 8줄, 정해진 내용 9줄)<br>`[9/9]`: `+ lib/main.dart:5  warning  missing_provider_scope` | 1 | PRESET-07 · D-04 — version 없는 plugin 끄기는 조용히 무시된다 (spike 012) |

`- ` 와 `+ ` 의 뜻은 위 표와 같다. 화면의 요약은 M18 이 `점검 실패 (9개 중 1개)`, M19 가 `점검 실패 (9개 중 2개)` 였다. 걸린 시간은 M18 이 17초, M19 가 23초, 되돌린 뒤의 보통 실행이 22초였다 (M19 는 `overrides` 의 plugin 선언이 바뀌었다 돌아오지만, 되돌린 뒤의 실행이 평소의 재실행 20 ~ 23초 안이었다).

- **M18 에서 `recommended` 는 통과한다.** 자기 정답지 없이 같은 실행의 `example` 결과와 견주므로, 둘이 똑같이 plugin 3줄을 잃으면 "같다" 가 성립한다. 깨짐을 잡는 것은 `example` 의 정답지다. `recommended` 의 역할은 "묶음 = 옛 주소" 이지 "plugin 이 돈다" 가 아니다.
- **M18 에서 `overrides` 도 통과했다 — 계획의 예상(함께 실패)과 다르다.** `overrides` 는 끄는 설정을 위해 자기 옵션 파일의 `plugins:` 에 `riverpod_lint` 를 `version` 과 함께 다시 적으므로, 묶음이 Riverpod 조각을 잃어도 그 프로젝트의 선언으로 plugin 이 돈다 (spike 012 의 "적은 값이 그 프로젝트의 plugin 버전 선언이 된다" 와 맞는 결과다. 까닭을 따로 갈라 재지는 않았다). 그래서 묶음의 Riverpod 조각은 `example` 하나가 지킨다.
- **M19 는 `[3/9]` 와 `[9/9]` 가 함께 잡는다.** 옵션 파일의 내용이 정해진 것과 다르고, `version` 없는 끄기가 경고 없이 무시되어 `missing_provider_scope` 가 되살아난다. `[3/9]` 는 `version:` 의 값도 본다 — 값을 `^3.1.9` 로만 바꾼 실행(커밋하지 않고 되돌림)에서는 진단이 같아 `[9/9]` 는 통과했고 `[3/9]` 만 실패했다 (`점검 실패 (9개 중 1개)`).
- **`[3/9]` 는 옵션 파일을 통째로 견준다.** `overrides` 의 `prefer_final_locals: false` 를 `true` 로 바꾼 실행에서 `[3/9]` (그 파일을 들어) 와 `[9/9]` (`+ lib/added_rules.dart:24  info  prefer_final_locals`) 가 실패했다 (종료 코드 1, `점검 실패 (9개 중 2개)`).

변경은 모두 커밋하지 않고 되돌렸다 (M18 · M19 는 `git checkout` 과 `git status` 로, `overrides` 의 옵션 파일을 커밋하기 전에 돌린 두 실행은 복사해 둔 파일로 되돌리고 `cmp` 로 확인). 끝에 검증 명령이 다시 종료 코드 0, `점검 통과 (9개 중 9개)` 인 것을 봤다.

### 추가 실측 — 배포 파일의 구성 (04-01)

실측 (04-01): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 10개). 변경은 한 번에 하나만 만들고, 돌린 직후 복사해 둔 파일(`lib/base.yaml` · `RULES.md`)이나 `git checkout` (`lib/recommended.yaml` · `lib/analysis_options.yaml`)으로 되돌렸다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M20 | `lib/base.yaml` 의 규칙 목록에 `- avoid_print # probe M20` 을 `- unawaited_futures` 줄 앞에 끼움 (기반 세트 `flutter.yaml` 이 켜는 규칙) | `[3/10]` 만. `[2/10]` 과 `[5/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `lib/base.yaml` 의 규칙이 기반 세트와 겹친다 (1) — 기반 세트가 이미 켜므로 지운다. ``<br>`avoid_print  (flutter_lints-6.0.0 flutter.yaml)`<br>`+ avoid_print  (base.yaml 에만)` | 1 | RULES-01 · D-11 (1) — 기반 세트와의 겹침 |
| M21 | `RULES.md` 의 켠 규칙 표에서 `prefer_single_quotes` 행을 지움 | `[3/10]` 만. `[5/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록이 다르다. ``<br>`+ prefer_single_quotes  (base.yaml 에만)` | 1 | RULES-06 · D-11 (2) — 표에서 행이 빠짐 |
| M22 | `lib/base.yaml` 에 `- avoid_slow_async_io # probe M22` 를 더하고 `RULES.md` 에는 더하지 않음 (그 규칙을 어기는 샘플 없음) | `[3/10]` 만. `[5/10]` ~ `[10/10]` 은 통과 (샘플에 걸리지 않았다) | 차이 없음. `[3/10]` 이 낸 줄:<br>`+ avoid_slow_async_io  (base.yaml 에만)` | 1 | RULES-06 · D-11 (2) — 배포 파일에만 더한 규칙 |
| M23 | `lib/recommended.yaml` 끝에 `linter:` / `  rules:` / `    - unnecessary_await_in_return` 세 줄 (03-REVIEW.md WR-01 의 재현 입력) | `[3/10]` 만. `[2/10]` 과 `[5/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `lib/recommended.yaml` 는 include 만 담아야 한다 — 주석 · 빈 줄을 뺀 내용 (7줄): `` 과 그 7줄, 정해진 4줄 | 1 | D-12 WR-01 — 묶음에 적힌 규칙 |
| M24 | `lib/analysis_options.yaml` (별칭) 끝에 같은 세 줄 | `[3/10]` 만. `[2/10]` 과 `[5/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `lib/analysis_options.yaml` 는 include 만 담아야 한다 — 주석 · 빈 줄을 뺀 내용 (4줄): `` 과 그 4줄, 정해진 1줄 | 1 | D-12 WR-01 — 별칭에 적힌 규칙 |
| M25 | `lib/base.yaml` 에서 04-06 에 켠 `no_self_assignments` 줄 하나를 지움 (`RULES.md` 와 정답지는 그대로) | `[3/10]` 과 `[5/10]` ~ `[10/10]` 가운데 정답지 단계 다섯 (`[5/10]` · `[7/10]` ~ `[10/10]`). `[6/10]` 은 통과 | `[3/10]` 이 낸 줄:<br>`- no_self_assignments  (RULES.md 에만)`<br>정답지 다섯 모두 같은 한 줄이 "정답지에는 있는데 나오지 않은 경고 (1)" 로 찍혔고 나온 쪽의 새 줄은 0:<br>`lib/bug_prevention_rules.dart:124  info  no_self_assignments` | 1 | VERIFY-08 · D-10 — 새로 켠 규칙 하나를 지운 변경 (M1 의 재현) |

`[3/10]` 의 `+ ` 는 `lib/base.yaml` 에만 있는 이름, `- ` 는 `RULES.md` 의 켠 규칙 표에만 있는 이름이다 — `RULES.md` 를 정답지, `lib/base.yaml` 을 실제 결과로 놓은 정답지 diff 와 같은 기호다. M20 ~ M24 다섯 모두 화면의 요약은 `점검 실패 (10개 중 1개)` 였고, 걸린 시간은 다섯 모두 19초, 되돌린 뒤의 보통 실행도 19초였다. M25 는 04-09 에서 같은 조건(Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13)으로 쟀다 — 요약은 `점검 실패 (10개 중 6개)`, 21초였고, `git checkout -- lib/base.yaml` 로 되돌린 뒤 `git diff` 가 비어 있는 것과 보통 실행의 종료 코드 0 · `점검 통과 (10개 중 10개)` 를 봤다. 지운 채로 `--update` 는 돌리지 않았다 (정답지를 다시 쓰므로).

읽는 법은 다음과 같다.

- **M20 에서 정답지 단계는 통과한다.** `avoid_print` 는 기반 세트 `flutter_lints` 6.0.0 의 `flutter.yaml` 이 이미 켜므로, 배포 파일에 겹쳐 적어도 받는 프로젝트의 진단은 한 줄도 달라지지 않는다. `[2/10]` 도 통과한다 — 조각의 복사본은 기반 세트와 겹친 규칙을 경고하지 않는다. 겹침을 잡는 것은 `[3/10]` 의 (b) 하나다 (D-11 의 근거). 같은 이름이 `RULES.md` 의 표에 없어 (c) 의 `+ avoid_print` 도 함께 찍혔다.
- **M21 의 기호는 `+` 다 — 계획의 예상(`- prefer_single_quotes`)과 다르다.** 표에서 행을 지우면 그 이름은 `lib/base.yaml` 에만 남으므로 M22 와 같은 쪽이다. `- ` 쪽은 따로 한 번 확인했다: `RULES.md` 의 켠 규칙 표에 `avoid_slow_async_io` 행을 더한 실행(커밋하지 않고 되돌림)에서 `- avoid_slow_async_io  (RULES.md 에만)` 이 찍혔다 (종료 코드 1, 19초). 같은 방식으로 첫 칸에 이름이 둘인 행은 `` `RULES.md` 의 `woody:enabled-rules` 표에 첫 칸의 이름이 둘 이상인 행이 있다 (1): `` 로, `woody:enabled-options` 의 시작 마커를 지운 파일은 `` `RULES.md` 의 `woody:enabled-options` 구역이 없다 — 04-CONTEXT.md D-08 `` 로 `[3/10]` 이 실패했다 (둘 다 종료 코드 1, 되돌림).
- **M23 · M24 는 고치기 전에는 아홉 단계를 모두 통과했다.** 03-REVIEW.md WR-01 이 같은 세 줄을 `lib/recommended.yaml` 끝에 더한 복사본에서 "`[1/9]` ~ `[9/9]` 모두 통과, `점검 통과 (9개 중 9개)`, 종료 코드 0" 을 기록했다 (이번에 고치기 전의 스크립트로 다시 재지는 않았다). `[2/10]` 의 규칙 검사는 묶음과 별칭을 대상에 넣지 않으므로 (spike 013) 지금도 통과하고, `[3/10]` 의 (a) 가 "include 만" 을 잡는다.
- **M25 는 새 규칙에도 M1 의 보장이 성립한다는 확인이다.** M1 은 1.3.0 부터 켜 둔 `prefer_final_locals` 를 지워 정답지 비교가 그 줄의 빠짐을 잡는 것을 봤다. 04-06 ~ 04-07 에서 켠 규칙은 D-10 대로 규칙마다 샘플 한 줄이 정답지 다섯에 들어 있으므로, 그 가운데 하나를 지우면 `[3/10]` (`RULES.md` 와의 일치) 과 정답지 단계 다섯이 함께 실패한다. 둘 중 하나만 있었다면 다른 하나가 잡는다. `[6/10]` recommended 가 통과한 것은 M18 과 같은 까닭이다 — 자기 정답지 없이 같은 실행의 `example` 결과와 견주므로, 둘이 똑같이 그 줄을 잃으면 "같다" 가 성립한다.

확인 기록 둘도 같은 자리에 둔다 (실패가 아니라 "바뀌지 않았다" 의 확인이다).

- (i) 기반 세트와 겹치는 선언 6개와 주석 처리된 설정 3개를 `lib/base.yaml` 에서 지운 커밋에서 `fvm dart run tool/verify.dart --update` 가 `바뀐 정답지가 없다 — 쓰지 않았다` 를 찍었고 정답지 다섯의 내용이 그대로였다 (D-20, RULES-01 · RULES-02). 정답지 다섯은 `19ae5ec` · `91bbeec` · `9ed0fe5` 와 `git diff` 로 견줘 같았다.
- (ii) 결정 묶음 커밋마다 정답지 다섯의 `+` 줄 수가 그 묶음의 샘플 수와 같았다 — B2 `354959c`: 규칙 25 · `+` 25줄 × 5, B3 `52402df`: 규칙 2 · `+` 2줄 × 5, B4 `6c0bc83`: 규칙 8 · `+` 8줄 × 5, B5 `944ca1c`: 규칙 39 · `+` 41줄 × 4 와 `overrides` 50줄. 다섯 커밋 모두 `-lib/` 줄은 0 이고 `exit` 줄은 그대로였다. B1 `9cff42e` (지금 켜 둔 6개의 사유 주석만 고침) 과 B6 `ba58060` (`RULES.md` 의 켜지 않은 규칙 표만 채움) 은 샘플도 정답지의 변화도 0 이다. B5 만 수가 다르다 — 같은 커밋에서 켠 규칙이 기존 샘플에도 걸린 줄(정답지 다섯 모두 `join_return_with_assignment` · `specify_nonobvious_property_types` 각 1줄, `overrides` 는 끄는 설정 시연 파일의 `document_ignores` 6줄 · `specify_nonobvious_property_types` 3줄 더)이고, 새 규칙 39개 밖의 이름은 없었다. 04-08 은 `unnecessary_ignore` 를 켜지 않아 묶음 커밋이 없다. 수는 커밋마다 `git diff <커밋>^ <커밋> -- <정답지>` 의 `+lib/` · `-lib/` 줄로 04-09 에서 다시 셌다 (04-06 · 04-07 · 04-08 의 SUMMARY 와 같다).

변경은 모두 커밋하지 않고 되돌렸다 (`git status` 와, `lib` · `RULES.md` 를 HEAD 와 견준 `git diff` 로 확인). 끝에 검증 명령이 다시 종료 코드 0, `점검 통과 (10개 중 10개)` 인 것을 봤다.

### 추가 실측 — 열 0 주석 뒤의 규칙 · 기반 세트 읽기 실패 (04-11)

실측 (04-11): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 10개). 변경은 한 번에 하나만 만들고, 돌린 직후 복사해 둔 `lib/base.yaml` 로 되돌렸다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M26 | `lib/base.yaml` 의 마지막 규칙 `- no_raw_types` 줄 바로 뒤에 세 줄 — 열 0 주석 `# 실험 중 (열 0 주석)`, `    - avoid_print # 기반 세트와 겹침`, `    - prefer_mixin # RULES.md 켠 규칙 표에 없음` | `[3/10]` 만. `[2/10]` 과 `[5/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `lib/base.yaml` 의 규칙이 기반 세트와 겹친다 (1) — 기반 세트가 이미 켜므로 지운다. ``<br>`avoid_print  (flutter_lints-6.0.0 flutter.yaml)`<br>`` `RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록이 다르다. ``<br>`+ avoid_print  (base.yaml 에만)`<br>`+ prefer_mixin  (base.yaml 에만)` | 1 | RULES-01 · RULES-06 · D-11 — 04-REVIEW.md CR-02 (04-VERIFICATION.md gap 2) |

`- ` 와 `+ ` 의 뜻은 04-01 소절과 같다 — `+ ` 는 `lib/base.yaml` 에만 있는 이름, `- ` 는 `RULES.md` 의 켠 규칙 표에만 있는 이름이다. 화면의 요약은 `점검 실패 (10개 중 1개)` 였고, 걸린 시간은 23초, 되돌린 뒤의 보통 실행은 21초였다.

읽는 법은 다음과 같다.

- **M26 은 고치기 전에는 열 단계를 모두 통과했다.** 04-VERIFICATION.md 가 같은 세 줄을 더한 입력으로 `점검 통과 (10개 중 10개)`, 종료 코드 0 을 기록했다 (이번에 고치기 전의 스크립트로 다시 재지는 않았다). YAML 파서는 `linter:` 블록에서 규칙 82개를 읽는데, `[3/10]` 이 쓰는 `declaredRuleNames` 는 들여쓰기 없는 줄을 블록의 끝으로 보아 열 0 주석에서 블록을 닫고 80개만 봤다 — 그 뒤의 두 규칙은 기반 세트와의 겹침 (b) 에도 `RULES.md` 와의 일치 (c) 에도 들지 않았다. 고친 뒤에는 주석 줄과 빈 줄이 블록을 닫지 않는다. `[2/10]` 은 고치기 전에도 뒤에도 통과한다 — 조각의 복사본은 기반 세트와 겹친 규칙을 경고하지 않고, 두 규칙은 샘플에 걸리지 않는다.
- **WR-06 은 함수 단위로 확인했다.** 검증 명령의 준비 단계가 저장소 루트의 `pub get` 으로 `.dart_tool/package_config.json` 을 다시 쓰므로, 상류 파일의 형식이 바뀐 상태를 검증 명령 전체로는 만들 수 없다. 대신 git 이 무시하는 `.dart_tool/woody_gap_probe/` 에 두 도구를 import 하는 탐침과 가짜 `lints` · `flutter_lints` 패키지 · `package_config.json` 을 두고 `tool/verify.dart` 의 `readUpstreamRules` 와 `tool/measure_rules.dart` 의 `readUpstreamSets` 를 두 번 불렀다. 규칙 줄의 들여쓰기가 4칸(지금 상류의 형식)이면 둘 다 규칙 2개를 읽었고(`control verify 2 measure 2`), 2칸(형식이 바뀐 상류)이면 둘 다 `FormatException` 이었다 — `lints core.yaml 에서 규칙을 하나도 읽지 못했다 — 상류 YAML 의 형식이 바뀌었다 (04-REVIEW.md WR-06)` 와 `core.yaml 에서 …` (같은 문구). 검증 명령에서는 `main` 이 이 예외를 받아 종료 코드 70 `파일 모양이 예상과 다르다: lints-6.1.0 core.yaml 에서 규칙을 하나도 읽지 못했다 …` 로 끝난다 (코드에서 읽은 경로다 — 위 까닭으로 검증 명령 전체로는 돌려 보지 못했다). 고치기 전에는 빈 집합이 되어 `[3/10]` 의 겹침 검사가 `겹침 0` 으로 통과했다. 탐침과 가짜 패키지는 실행 뒤 지웠고 커밋하지 않았다.

변경은 모두 커밋하지 않고 되돌렸다 (`git status` 와 `lib/base.yaml` 을 HEAD 와 견준 `git diff` 로 확인). 끝에 검증 명령이 다시 종료 코드 0, `점검 통과 (10개 중 10개)` 인 것을 봤다.

항목의 `VERIFY-NN` · `PRESET-NN` · `RULES-NN` 은 `.planning/REQUIREMENTS.md` 의 요구사항 번호, `D-NN` 은 `.planning/phases/02-verification-harness/02-CONTEXT.md` 의 결정 번호다. 03-NN 소절의 `D-NN` 은 `.planning/phases/03-preset-split/03-CONTEXT.md` 의 결정 번호다. 04-NN 소절의 `D-NN` 은 `.planning/phases/04-rule-reselection/04-CONTEXT.md` 의 결정 번호다.
