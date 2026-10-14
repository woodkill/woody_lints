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
| `lib/added_rules.dart` | 1.3.0 부터 켜 둔 규칙 6개를 한 건씩 어긴다 (이 패키지가 더하는 규칙 81개 가운데 1.3.0 의 것 — 나머지 75개의 샘플은 아래 파일들과 `pubspec.yaml` 에 있다) | 6 |
| `lib/base_rules.dart` | 기반 세트(`flutter_lints` / `lints`)가 켜는 규칙 7개를 한 건씩 어긴다 — 그중 6개는 2.0.0 전까지 배포 파일에도 겹쳐 적혀 있었다 | 7 |
| `lib/main.dart` | `riverpod_lint` 의 `missing_provider_scope` (warning) | 1 |
| `lib/riverpod_rules.dart` | `riverpod_lint` 의 `avoid_public_notifier_properties` (info), `provider_parameters` (warning), 04-07 부터 `specify_nonobvious_property_types` (13행) | 3 |
| `lib/bug_prevention_rules.dart` | 04-06 에 켠 버그 방지 규칙 24개(`discarded_futures` 포함)를 한 건씩 어긴다 — 135행은 `parameter_assignments` 와 04-07 의 `join_return_with_assignment` 에 함께 걸려 정답지에 두 줄이다 | 25 |
| `lib/performance_rules.dart` | 04-07 에 켠 성능 규칙 8개를 한 건씩 어긴다 | 8 |
| `lib/style_rules.dart` | 04-07 에 켠 가독성·스타일 규칙 38개를 한 건씩 어긴다 (`avoid_final_parameters` 는 아래 파일에 있다) | 38 |
| `lib/strict_rules.dart` | 04-06 에 켠 strict 계열 `no_dynamic_casts` · `no_raw_types` 를 한 건씩 어긴다 | 2 |
| `lib/final_parameters_rule.dart` | `avoid_final_parameters` — 이 규칙은 언어 버전 3.13 의 라이브러리에서 돌지 않아 파일 머리를 `// @dart=3.11` 로 둔다 | 1 |
| `lib/relative_imports_rule.dart` | `prefer_relative_imports` — 3행 import 의 패키지 이름이 연습용 프로젝트마다 다르다 (아래 복사본 규칙) | 1 |
| `lib/should_not_appear.dart` | `invalid_annotation_target` 을 일으킨다. 배포 파일이 억제하므로 **나오면 안 된다** | 0 |
| `lib/generated/sample.g.dart`, `lib/generated/sample.freezed.dart` | 위반을 담은 생성 파일 흉내. 배포 파일이 분석에서 빼므로 **나오면 안 된다** | 0 |
| `analysis_options.yaml` | `include:` 한 줄. 검증 명령이 한 줄인지도 확인한다 | - |
| `expected_diagnostics.txt` | 정답지 (`exit 2` + 93줄) | - |
| `pubspec.yaml` | 저장소 루트의 `woody_lints` 를 `path: ..` 로 받는다. `dependencies` 에서 `flutter_riverpod` 를 `flutter` 앞에 두어 `sort_pub_dependencies` 를 한 건 어긴다 (2.0.0) | 1 |
| `pubspec.lock` | 커밋한다. 로컬과 CI 가 같은 패키지 버전으로 판정하게 하려는 것이다. `riverpod_lint` plugin 의 버전은 이 파일이 묶지 못한다 (Analysis Server 가 따로 받는다) | - |

## 연습용 프로젝트 여섯

검증 명령은 이 폴더와 `fixtures/` 아래 다섯 폴더를 차례로 분석한다. 같은 샘플을 서로 다른 옵션 파일로 받아, 조합마다 어떤 경고가 나오고 나오지 않는지를 정답지로 고정한다. "나오지 않는다" 는 줄 수만 세지 않고, 받지 않은 설정이 적용되지 않았을 때 **남는 줄**로 증명한다.

| # | 폴더 | include | plugin | 정답지 | 줄 수 | 증명하는 것 |
|---|------|---------|--------|--------|-------|-------------|
| 1 | `example/` | 옛 주소 한 줄 (`analysis_options.yaml`) | 씀 | `expected_diagnostics.txt` (`exit 2`) | 93 | 분리 전후로 정답지가 같다. 별칭이 plugin 을 잃지 않는다 |
| 2 | `fixtures/recommended/` | `recommended.yaml` | 씀 | 없음 (같은 실행의 `example` 결과와 견줌) | 93 | 옛 주소와 같은 진단 |
| 3 | `fixtures/base_only/` | `base.yaml` 만 | 안 씀 | `expected_diagnostics.txt` (`exit 2`) | 95 | 기본 규칙은 나오고 `riverpod_lint` 진단은 안 나온다. 생성 파일의 규칙 진단과 `invalid_annotation_target` 은 나온다 |
| 4 | `fixtures/overrides/` | 묶음 + 끄는 설정 | 씀 | `expected_diagnostics.txt` (`exit 2`) | 104 | 끈 진단만 사라진다 — 프로젝트 전체 · 파일 · 한 줄 × 규칙 · plugin. 접두사 없는 주석은 끄지 못한다 |
| 5 | `fixtures/base_riverpod/` | `base.yaml` + `riverpod.yaml` | 씀 | `expected_diagnostics.txt` (`exit 2`) | 98 | Riverpod 조각만 받아도 plugin 이 돈다. codegen 설정은 딸려 오지 않는다 |
| 6 | `fixtures/base_codegen/` | `base.yaml` + `codegen.yaml` | 안 씀 | `expected_diagnostics.txt` (`exit 0`) | 90 | codegen 조각만 받아도 생성 파일이 빠진다 (Dart 3.13.4 의 규칙 진단 기준). plugin 은 딸려 오지 않는다 |

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
| 70 | 스크립트가 예외로 끝남 (파일 형식 · 파일 작업 · 프로세스 실행 실패 — 기반 세트 YAML 에서 규칙을 하나도 읽지 못한 경우, 조각(`lib/base.yaml` · `lib/codegen.yaml` · `lib/riverpod.yaml`)의 `linter:` 블록에 읽지 못하는 줄이 있는 경우 · 조각의 `linter:` 줄에 값이 붙은 flow 표기(`linter: {rules: [...]}`)인 경우 · `lib/base.yaml` 의 `analyzer:` · `language:` 줄에 값이 붙었거나 `language:` 블록에 `<이름>: true\|false` 가 아닌 줄이 있는 경우 — 문구에 파일 이름이 들어간다 —, `pubspec.yaml` 에서 `version:` 을 읽지 못한 경우 포함) |
| 78 | 실행 중인 SDK 가 `.fvmrc` 와 다름 — 검증을 시작하지 않음 |

단계는 열 개다: `[1/10]` `lib/` 에 `.dart` 파일 없음, `[2/10]` 배포 파일(조각 셋)의 규칙 이름, `[3/10]` 배포 파일의 구성 (묶음 `recommended.yaml` 과 별칭 `analysis_options.yaml` 이 `include:` 만 담는지, `lib/base.yaml` 의 규칙이 기반 세트 — 저장소 루트가 받은 `lints` · `flutter_lints` 의 YAML — 와 겹치지 않는지, `RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록이 같은지. analyzer 를 돌리지 않고 파일끼리 견준다. 규칙 목록은 열 0 주석 뒤의 줄도 읽고 (2026-10-13 에 고침, 아래 M26), 따옴표로 감싼 이름도 읽으며, 블록 안에서 읽지 못하는 꼴의 줄을 만나면 종료 코드 70 으로 멈춘다 (2026-10-13 에 고침, 아래 M27 ~ M31), `lib/codegen.yaml` · `lib/riverpod.yaml` 의 `linter:` 블록에 규칙이 없는지 (규칙은 `lib/base.yaml` 에만 — 2026-10-14 에 더함, 아래 M35), README 의 표시 구역 `woody:readme-rules` 의 규칙 이름이 `lib/base.yaml` 과 같은지 · README 의 `package:woody_lints/<이름>.yaml` 주소가 모두 `lib/` 에 있는지 · README 코드 블록의 `version:` (과 `riverpod_lint:`) 값이 `lib/riverpod.yaml` 의 선언과, `ref: vX.Y.Z` 가 `pubspec.yaml` 의 version 과 같은지 (읽은 값이 0개면 실패 — 2026-10-14 에 더함, 아래 M38 ~ M42), 표시 구역 안의 줄이 빈 줄 · `**분류**` 소제목 · `- `이름`` 불릿 밖의 꼴이면 실패 (2026-10-14 에 더함, 아래 M43 · M44), README 코드 블록의 `version:` · `riverpod_lint:` · `ref:` 값은 따옴표와 줄 끝 주석을 벗겨 읽고 꼴이 틀린 값은 실패 (2026-10-14 에 더함, 아래 M47 ~ M50), `RULES.md` 의 두 표 구역 안의 줄이 머리 줄 · 구분 줄 · 첫 칸이 backtick 이름 하나인 행 밖의 꼴이면 실패 (2026-10-14 에 더함, 아래 M51 ~ M53), README 의 `package:` 주소가 `woody_lints` 의 `<이름>.yaml` 꼴이 아니면 실패하고 코드 블록은 `` ``` `` 와 `~~~` 펜스를 문자 · 길이로 가린다 (2026-10-14 에 더함, 아래 M54 ~ M58), `lib/base.yaml` 의 `analyzer:` · `language:` 줄에 값이 붙었거나 옵션 줄이 `<이름>: true|false` 가 아니면 종료 코드 70 으로 멈춘다 (2026-10-14 에 더함, 아래 M59 ~ M62)), `[4/10]` 연습용 프로젝트 여섯의 옵션 파일 (주석 · 빈 줄을 뺀 내용을 통째로 견준다 — `overrides` 의 `version:` 은 `lib/riverpod.yaml` 의 선언과 같아야 한다), `[5/10]` ~ `[10/10]` 연습용 프로젝트마다 정답지 비교 (위 표의 순서. `recommended` 는 같은 실행의 `example` 결과와). 하나가 실패해도 나머지를 모두 돌린다. `[2/10]` 는 배포 파일을 `plugins:` 없이 복사한 폴더를 `dart analyze` 로 분석해, 종료 코드가 0 이 아니거나 진단이 하나라도 있으면 실패한다 — deprecated / removed / 없는 규칙뿐 아니라 겹친 규칙 · 모르는 키 · 없는 진단 코드 같은 옵션 경고도 실패다. 깨진 YAML 은 종료 코드 3 에 진단 0건으로 나오므로 같은 폴더를 형식 인자 없이 한 번 더 돌려 `parse_error` 줄을 보여 준다. 배포 파일의 최상위 `linter:` 블록에서 `- 규칙이름` 줄을 하나도 세지 못해도 실패한다 — 규칙을 다른 파일로 옮길 때 경로를 잘못 잡은 것이 통과로 보이지 않게 (2026-10-12, 아래 M13 ~ M17).

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

### 추가 실측 — 따옴표로 감싼 규칙 이름 · 읽지 못하는 줄 (04-13)

실측 (04-13): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 10개). 변경은 한 번에 하나만 만들고, 다섯 모두 `lib/base.yaml` 의 마지막 규칙 `- no_raw_types` 줄 바로 뒤에 더했다 — 더한 줄은 106행부터다. 돌린 직후 복사해 둔 `lib/base.yaml` 로 되돌렸다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M27 | 한 줄 `    - 'avoid_print' # 기반 세트와 겹침 (따옴표)` — 홑따옴표로 감싼 이름 (04-VERIFICATION.md 가 WR-10 을 재현한 입력) | `[3/10]` 만. `[2/10]` 과 `[5/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `lib/base.yaml` 의 규칙이 기반 세트와 겹친다 (1) — 기반 세트가 이미 켜므로 지운다. ``<br>`avoid_print  (flutter_lints-6.0.0 flutter.yaml)`<br>`` `RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록이 다르다. ``<br>`+ avoid_print  (base.yaml 에만)` | 1 | RULES-01 · RULES-06 · D-11 — 04-REVIEW.md WR-10 (04-VERIFICATION.md 진실 6) |
| M28 | 한 줄 `    - "prefer_mixin" # RULES.md 켠 규칙 표에 없음 (큰따옴표)` — 큰따옴표로 감싼 이름 | `[3/10]` 만. `[2/10]` 과 `[5/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄 (겹침 블록 없음):<br>`` `RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록이 다르다. ``<br>`+ prefer_mixin  (base.yaml 에만)` | 1 | RULES-06 · D-11 (2) — WR-10 의 큰따옴표 쪽 |
| M29 | 한 줄 `    - avoid_print: true # 읽지 못하는 꼴 (맵 항목)` | 단계를 돌리지 못했다 — 예외는 `[2/10]` 이 복사본을 분석한 뒤 규칙 수를 셀 때 났다 | 화면 없음 (stdout 비어 있음). stderr 한 줄:<br>`` 파일 모양이 예상과 다르다: `linter:` 블록의 106행을 읽지 못했다 — 목록 항목(`- 이름` · `- '이름'` · `- "이름"`, 뒤에 `# 주석` 가능)과 `rules:` 만 받는다 (04-REVIEW.md WR-10): - avoid_print: true # 읽지 못하는 꼴 (맵 항목) `` | 70 | D-11 — WR-10 (읽지 못하는 줄은 건너뛰지 않고 멈춘다) |
| M30 | 두 줄 `    -` 와 `      avoid_print # 읽지 못하는 꼴 (이름이 다음 줄)` — YAML 로는 올바른 목록 항목 | 단계를 돌리지 못했다 — 예외는 `[2/10]` 이 규칙 수를 셀 때 났다 | 화면 없음 (stdout 비어 있음). stderr 한 줄: M29 와 같은 문구 (`106행을 읽지 못했다`)이고 끝이 `(04-REVIEW.md WR-10): -` | 70 | D-11 — WR-10 (이름 없는 `-`) |
| M31 | 한 줄 `    avoid_print: true # 읽지 못하는 꼴 (맵 형식 — 대시 없음)` — `-` 로 시작하지 않는 맵 형식 줄 (03-REVIEW.md WR-03 의 입력 꼴) | 단계를 돌리지 못했다 — `[2/10]` 은 복사본 분석이 깨진 YAML 로 끝나 규칙 수를 세지 않고 돌아가고, 예외는 `[3/10]` 이 `lib/base.yaml` 을 읽을 때 났다 | 화면 없음 (stdout 비어 있음). stderr 한 줄: M29 와 같은 문구 (`106행을 읽지 못했다`)이고 끝이 `(04-REVIEW.md WR-10): avoid_print: true # 읽지 못하는 꼴 (맵 형식 — 대시 없음)` | 70 | D-11 — WR-10 (`-` 로 시작하지 않는 줄도 건너뛰지 않는다) |

`+ ` 의 뜻은 04-01 소절과 같다 — `lib/base.yaml` 에만 있는 이름이다. M27 · M28 의 화면 요약은 둘 다 `점검 실패 (10개 중 1개)` 였다. 걸린 시간은 M27 19초, M28 20초, M29 2초, M30 3초, M31 3초 (M29 ~ M31 은 준비 단계와 `[2/10]` 의 복사본 분석까지만 돈다), 되돌린 뒤의 보통 실행은 20초였다.

읽는 법은 다음과 같다.

- **M27 은 고치기 전에는 열 단계를 모두 통과했다.** 04-VERIFICATION.md 가 같은 한 줄을 더한 입력으로 `점검 통과 (10개 중 10개)`, 종료 코드 0 을 기록했다 (이번에 고치기 전의 스크립트로 다시 재지는 않았다). YAML 에서 `'avoid_print'` 는 `avoid_print` 와 같은 문자열이라 analyzer 는 그 규칙을 켜는데, `declaredRuleNames` 의 옛 정규식은 따옴표에서 맞지 않아 그 줄을 조용히 건너뛰었다 — M26 과 같은 결함 꼴이 다른 입력으로 남아 있던 것이다. 고친 뒤에는 따옴표 이름을 읽고(M27 · M28), 읽지 못하는 줄에서 멈춘다(M29 ~ M31). `[2/10]` 과 정답지 단계가 통과한 까닭은 M20 · M26 과 같다 — 조각의 복사본은 기반 세트와 겹친 규칙을 경고하지 않고, 두 규칙은 샘플에 걸리지 않는다.
- **M29 ~ M31 은 단계를 돌리지 못하고 멈춘다.** M29 · M30 은 `[2/10]` 이 `countDeclaredRules` → `declaredRuleNames` 를 부르는 자리에서, M31 은 `[2/10]` 이 깨진 YAML(목록에 섞인 맵)로 실패한 뒤 `[3/10]` 에서 멈춘다 — `-` 로 시작하지 않는 줄도 건너뛰지 않는다는 확인이다 (예외가 난 단계는 코드에서 읽은 것이고, 실행에서 본 것은 종료 코드 · stdout · stderr 다). 단계 줄은 단계를 모두 돌린 뒤 한 번에 찍으므로 찍히지 않고, `main` 이 stderr 한 줄과 종료 코드 70 으로 끝낸다. 받는 줄은 들여쓴 `rules:` 와 목록 항목 세 꼴(`- 이름` · `- '이름'` · `- "이름"`, 뒤에 공백과 `# 주석` 가능)뿐이고, 이름 뒤에 다른 것이 붙은 줄 · `-` 뒤 공백 없는 줄도 같은 길로 멈춘다 — 이 둘은 정규식으로 확인했고 돌려 보지는 않았다. `linter:` 줄 자체에 붙은 flow 표기(`linter: {rules: [...]}`)는 블록 안의 줄이 아니라 읽지 않으며, 그러면 규칙 0개라 `[2/10]` 이 "하나도 세지 못했다" 로 잡는다. 들여쓰기 없는 줄의 블록 닫기와 주석 · 빈 줄 건너뛰기(M26)는 그대로다.

변경은 모두 커밋하지 않고 되돌렸다 (`git status` 와 `lib/base.yaml` 을 HEAD 와 견준 `git diff` 로 확인). 끝에 검증 명령이 다시 종료 코드 0, `점검 통과 (10개 중 10개)` 인 것을 봤다.

### 추가 실측 — plugin 선언의 꼴과 다른 조각의 규칙 (05-01)

실측 (05-01): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-14

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 10개). 변경은 한 번에 하나만 만들고, 줄 번호가 아니라 내용을 기준으로 바꿨다 — M32 는 `lib/riverpod.yaml` 의 `  riverpod_lint: ^3.1.9` 줄 끝에 ` # 하한` 을 붙였고, M33 은 같은 파일의 마지막 줄바꿈을 지웠고, M34 는 들여쓴 `riverpod_lint:` 줄을 지웠다 (`plugins:` 만 남는다). M35 · M36 은 `lib/codegen.yaml` 끝에, M37 은 `lib/riverpod.yaml` 끝에 줄을 덧붙였다 (`printf … >>`). M32 ~ M34 는 커밋 1 (`stripPlugins` · `readShippedPluginConstraint` 를 고친 판), M35 ~ M37 은 그 위에 (b′) 와 파일 이름 문구를 더한 판으로 돌렸다. 돌린 직후 `git checkout -- <파일>` 로 되돌렸다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M32 | `lib/riverpod.yaml` 의 plugin 줄을 `  riverpod_lint: ^3.1.9 # 하한` 으로 — 줄 끝 주석 | 실패 없음 | 차이 없음. 화면 요약 `점검 통과 (10개 중 10개)`, plugin 표시줄 `riverpod_lint 3.1.9` | 0 | 03-REVIEW.md WR-02 · 05-CONTEXT.md D-08 (순서) |
| M33 | `lib/riverpod.yaml` 의 마지막 줄바꿈 삭제 (마지막 바이트가 `9`) | 실패 없음 | 차이 없음. 화면 요약 `점검 통과 (10개 중 10개)` | 0 | 03-REVIEW.md WR-02 · 05-CONTEXT.md D-08 (순서) |
| M34 | `lib/riverpod.yaml` 의 `  riverpod_lint: ^3.1.9` 줄 삭제 — `plugins:` 만 남는다 | 단계를 돌리지 못했다 — 예외는 `[2/10]` 이 조각을 복사할 때가 아니라 `[4/10]` 이 선언을 읽을 때 났다 | 화면 없음 (stdout 비어 있음). stderr 한 줄:<br>`파일 모양이 예상과 다르다: lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다` | 70 | 03-REVIEW.md WR-02 (reader 가 없는 선언을 만들어 내지 않는다) |
| M35 | `lib/codegen.yaml` 끝에 네 줄 `linter:` / `  rules:` / `    - avoid_print # 기반 세트와 겹침` / `    - prefer_mixin # RULES.md 에 없음` (04-REVIEW.md WR-11 의 재현 입력) | `[3/10]` 만. `[2/10]` 과 `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `lib/codegen.yaml` 에 규칙이 있다 (2) — 규칙은 `lib/base.yaml` 에만 적는다. ``<br>`avoid_print`<br>`prefer_mixin`<br>`` 그 규칙을 `lib/base.yaml` 로 옮기고 `RULES.md` 의 켠 규칙 표에 적는다 (03-REVIEW.md WR-01 의 관례, 04-REVIEW.md WR-11). `` | 1 | 04-REVIEW.md WR-11 |
| M36 | `lib/codegen.yaml` 끝에 세 줄 `linter:` / `  rules:` / `    avoid_print: true` — 읽지 못하는 꼴 (맵 항목) | 단계를 돌리지 못했다 — 예외는 `[3/10]` (b′) 가 `lib/codegen.yaml` 을 읽을 때 났다 | 화면 없음 (stdout 비어 있음). stderr 한 줄:<br>`` 파일 모양이 예상과 다르다: lib/codegen.yaml 의 `linter:` 블록의 10행을 읽지 못했다 — 목록 항목(`- 이름` · `- '이름'` · `- "이름"`, 뒤에 `# 주석` 가능)과 `rules:` 만 받는다 (04-REVIEW-DISPOSITION.md WR-10): avoid_print: true `` | 70 | 04-REVIEW.md IN-14 |
| M37 | `lib/riverpod.yaml` 끝에 세 줄 `linter:` / `  rules:` / `    - unnecessary_await_in_return # 지워 보기 M37` — deprecated 규칙 (Phase 3 이 `[2/N]` 을 재현한 입력). 더한 규칙 줄은 원본의 13행 | `[2/10]` 과 `[3/10]`. `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[2/10]` 이 낸 진단 줄:<br>`build/woody_rule_check/riverpod/analysis_options.yaml:13  warning  deprecated_lint  (unnecessary_await_in_return)`<br>`[3/10]` 이 낸 줄:<br>`` `lib/riverpod.yaml` 에 규칙이 있다 (1) — 규칙은 `lib/base.yaml` 에만 적는다. ``<br>`unnecessary_await_in_return` | 1 | 03-REVIEW.md WR-02 (줄 번호 보존) · 04-REVIEW.md WR-11 (riverpod 조각) |

읽는 법은 다음과 같다.

- **M32 · M33 은 고치기 전에는 종료 코드 70 이었던 입력이다.** 03-REVIEW.md WR-02 가 지적했고 05-RESEARCH.md § 1 이 2026-10-13 에 저장소 복제본에서 재현했다 — 줄 끝 주석은 `lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다`, 마지막 줄바꿈 없음은 `` lib/riverpod.yaml 의 `plugins:` 섹션을 빼지 못했다 `` 로, 둘 다 stdout 0 바이트였다. 두 변경 모두 YAML 로 올바르고 analyzer 의 동작도 같으므로 거짓 실패였다 (이번에 고치기 전의 스크립트로 다시 재지는 않았다).
- 고친 `stripPlugins` 는 줄 단위로 걸으며 `plugins:` 섹션을 지우지 않고 **빈 줄로 바꾼다** — `[2/10]` 복사본의 줄 수와 줄 번호가 원본과 같다 (아래 M37 이 실행으로 보인다). 받는 꼴은 줄 끝 주석, `plugins:` 뒤의 주석 · 공백, 섹션 안의 빈 줄 · 열 0 주석, CRLF, 마지막 줄바꿈 없음이다. 고친 `readShippedPluginConstraint` 는 들여쓴 스칼라 줄(줄 끝 주석 가능)과 맵 형식(`riverpod_lint:` 다음의 첫 비주석 줄 `version: <값>` — `fixtures/overrides` 의 꼴)을 받는다. 이 목록 가운데 실행으로 본 것은 M32 · M33 둘이고, 나머지는 05-RESEARCH.md § 1 의 함수 단위 확인이다.
- **M34 는 reader 가 헛통과가 아니라는 확인이다.** 선언이 없으면 지금도 `선언을 찾지 못했다` 로 멈춘다 — 고친 reader 가 없는 선언을 만들어 내거나 다른 줄의 값을 읽지 않는다. 고치기 전에는 같은 입력이 `` `plugins:` 섹션을 빼지 못했다 `` 로 70 이었다 (05-RESEARCH.md § 1, 2026-10-13 복제본). 고친 뒤에는 `[2/10]` 의 복사가 지나가고 `[4/10]` 의 선언 읽기에서 멈춘다 (예외가 난 자리는 코드에서 읽은 것이고, 실행에서 본 것은 종료 코드 · stdout · stderr 다 — stderr 에 연습용 프로젝트의 `분석 중…` 줄이 하나도 없었다).
- **M35 는 고치기 전에는 열 단계를 모두 통과했다.** 04-REVIEW.md WR-11 이 같은 네 줄로 종료 코드 0 을 재현했다 (2026-10-13. 이번에 고치기 전의 스크립트로 다시 재지는 않았다) — `[3/10]` 의 겹침 (b) 와 `RULES.md` 일치 (c) 가 `lib/base.yaml` 하나만 읽어, 다른 조각에 적은 규칙을 사용 프로젝트는 받는데 검사는 보지 못했다. 고친 뒤에는 (b′) 가 "규칙은 `lib/base.yaml` 에만" 을 검사로 굳혀 그 조각을 이름으로 가리킨다. `[2/10]` 과 정답지 단계가 통과한 까닭은 M20 · M27 과 같다 — 조각의 복사본은 기반 세트와 겹친 규칙을 경고하지 않고, 두 규칙은 샘플에 걸리지 않는다. 화면 요약은 `점검 실패 (10개 중 1개)`, 19초였다.
- **M36 의 예외는 `[3/10]` (b′) 에서 났다** (코드에서 읽은 것이다 — `[2/10]` 은 `lib/base.yaml` 의 규칙만 세므로 `lib/codegen.yaml` 의 맵 항목을 읽지 않는다). 3초 만에 stdout 0 바이트 · 종료 코드 70 으로 끝났고, stderr 문구의 머리에 파일 이름 `lib/codegen.yaml` 이 있다 — M29 ~ M31 의 문구에는 어느 파일인지가 없었다 (04-REVIEW.md IN-14). 행 번호(10행)는 `lib/codegen.yaml` 원본의 줄 번호다.
- **M37 은 두 가지를 한 실행으로 가른다.** 첫째, `[2/10]` 의 진단 줄 번호 `:13` 이 원본 `lib/riverpod.yaml` 에서 그 규칙 줄의 번호와 같다 — Phase 3 이 같은 입력으로 본 번호는 `:11` 이었다 (`plugins:` 두 줄을 지워 복사해 2 앞당겨졌다, `.planning/STATE.md` 의 Phase 03 결정). 빈 줄 치환이 줄 번호를 보존한다는 실행 증거는 이 행 하나다. 둘째, `[3/10]` 이 `lib/riverpod.yaml` 을 이름으로 가리킨다 — (b′) 가 `lib/codegen.yaml` 하나를 박아 둔 것이 아니라 `ruleCheckTargets` 에서 `rulesFile` 을 뺀 조각 전부를 본다. `[5/10]` ~ `[10/10]` 이 통과한 것은 include 를 거친 deprecated 규칙은 보고되지 않기 때문이다 (Phase 3 의 기록과 같다). 화면 요약은 `점검 실패 (10개 중 2개)`, 19초였다.

변경은 모두 커밋하지 않고 되돌렸다 (`git status` 와 `lib/riverpod.yaml` · `lib/codegen.yaml` 을 HEAD 와 견준 `git diff` 로 확인). 끝에 검증 명령이 다시 종료 코드 0, `점검 통과 (10개 중 10개)` 인 것을 봤다.

### 추가 실측 — README 의 규칙 목록 · 주소 · plugin 버전 · ref (05-06)

실측 (05-06): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-14

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 10개). 다섯 변경 모두 저장소 루트의 `README.md` 하나만, 한 번에 하나씩, 줄 번호가 아니라 내용을 기준으로 바꿨다 (`perl -ni` / `perl -pi`, 줄 끝 앵커는 `[ \t]*$`) — M38 은 표시 구역의 `` - `prefer_single_quotes` `` 줄을 지웠고, M39 는 「프리셋 고르기」 기본 + codegen 블록의 `  - package:woody_lints/codegen.yaml` 을 `  - package:woody_lints/codegn.yaml` 로, M40 은 「규칙 · plugin 진단 끄기」 블록의 `    version: ^3.1.9` 를 `^3.1.3` 으로, M41 은 코드 블록의 `ref: v2.0.0` 줄 전부(「설치」 와 「버전 올리기」 의 두 줄)를 `ref: v1.3.0` 으로 바꿨고, M42 는 `<!-- woody:readme-rules:start -->` 줄을 지웠다 (end 마커는 남김). 변경마다 의도한 줄만 바뀌었는지(지운 둘은 `git diff --numstat` 이 `0/1`, 바꾼 셋은 새 줄이 README 에 있는지)를 먼저 잡아 두고, 검증 명령을 돌린 직후 `git checkout -- README.md` 로 되돌린 뒤에 판정했다. 행 번호는 바꾸기 전 `README.md` 의 줄 번호다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M38 | `README.md` 의 표시 구역 `woody:readme-rules` 에서 `` - `prefer_single_quotes` `` 줄(112행)을 지움 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 규칙 목록과 `lib/base.yaml` 의 규칙 목록이 다르다. ``<br>`+ prefer_single_quotes  (base.yaml 에만)`<br>`` `README.md` 의 목록 · `RULES.md` 의 표 · `lib/base.yaml` 을 같은 커밋에서 고친다. `` | 1 | VERIFY-06 · D-01 · D-02 (1) |
| M39 | 「프리셋 고르기」 기본 + codegen 블록(78행)의 `  - package:woody_lints/codegen.yaml` 을 `  - package:woody_lints/codegn.yaml` 로 — README 의 `package:woody_lints/` 주소 가운데 첫 등장(50행, 묶음 블록)이 아닌 뒤쪽 등장 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 가 가리키는 프리셋 주소가 `lib/` 에 없다 (1): ``<br>`package:woody_lints/codegn.yaml`<br>`` `lib/` 의 파일 이름과 `README.md` 의 주소를 같은 커밋에서 고친다. `` | 1 | D-02 (2) — 뒤쪽 주소 |
| M40 | 「규칙 · plugin 진단 끄기」 의 프로젝트 전체 블록(234행) `    version: ^3.1.9` 를 `    version: ^3.1.3` 으로 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 코드 블록에 적힌 riverpod_lint 버전이 `lib/riverpod.yaml` 의 선언(^3.1.9)과 다르다: ``<br>`^3.1.3`<br>`` `README.md` 의 끄기 예시 · `lib/riverpod.yaml` · `fixtures/overrides/analysis_options.yaml` 을 같은 커밋에서 고친다. `` | 1 | D-02 (3) |
| M41 | 코드 블록의 `      ref: v2.0.0` 두 줄(18행 「설치」, 333행 「`ref: main` 에서 tag 로 옮기기」)을 모두 `      ref: v1.3.0` 으로 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 `ref: vX.Y.Z` 예시가 `pubspec.yaml` 의 version (2.0.0) 과 다르다: ``<br>`ref: v1.3.0`<br>`` 릴리스 버전을 올릴 때 `README.md` 의 `ref:` 예시도 같은 커밋에서 고친다. `` | 1 | D-02 (4) |
| M42 | start 마커 줄 `<!-- woody:readme-rules:start -->` (93행) 삭제 — end 마커와 불릿 81줄은 그대로 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 `woody:readme-rules` 구역이 없다 — 05-CONTEXT.md D-01 ``<br>``` `<!-- woody:readme-rules:start -->` 와 `<!-- woody:readme-rules:end -->` 사이에 `- `규칙이름`` 불릿을 둔다. ``` | 1 | D-01 (헛통과 아님) |

다섯 모두 화면의 요약은 `점검 실패 (10개 중 1개)` 였고, 걸린 시간은 다섯 모두 19초, 되돌린 뒤의 보통 실행도 19초였다. 표의 `[3/10]` 줄은 화면 줄에서 앞의 공백 두 칸(기호 줄 · 주소 줄 · 값 줄)을 뗀 것이다. plugin 표시줄은 다섯 모두 `riverpod_lint 3.1.9` 였다.

읽는 법은 다음과 같다.

- `+ ` 의 뜻은 04-01 소절과 같다 — `lib/base.yaml` 에만 있는 이름이다. (d) 는 README 의 표시 구역을 정답지 쪽에 놓으므로 반대쪽 기호 `- ` 는 표시 구역에만 있는 이름이고 `(README.md 에만)` 이 붙는다 (코드에서 읽은 것이다 — 이번에 `- ` 쪽은 돌리지 않았다).
- **M38 은 M21 의 README 판이다.** M21 이 `RULES.md` 의 켠 규칙 표에서 `prefer_single_quotes` 행을 지워 `+ prefer_single_quotes  (base.yaml 에만)` 을 봤듯이, README 의 표시 구역에서 같은 이름을 지우면 같은 기호 · 같은 꼬리로 (d) 가 실패한다. `RULES.md` 와의 일치 (c) 는 그대로라 `[3/10]` 의 블록은 (d) 하나뿐이었다. 다섯 변경 모두 `[2/10]` 과 정답지 단계가 통과한 것은 README 가 배포 파일이 아니어서 받는 프로젝트의 진단에 닿지 않기 때문이다.
- **M39 가 뒤쪽 주소를 바꾼 까닭.** README 에서 `package:woody_lints/` 주소가 처음 나오는 곳은 「프리셋 고르기」 묶음 블록의 50행(`recommended.yaml`)이다. 첫 일치 하나만 보는 (e) 라면 50행만 읽고 M39 를 지나쳤을 것이다. 78행을 바꾼 M39 가 실패했으므로 (e) 는 README 전체의 주소를 모은다 — 이 실행이 그 두 구현을 가른다.
- **M40 은 다른 값 하나만 찍는다.** 「받는 규칙」 의 조각마다의 설정 블록(198행) `riverpod_lint: ^3.1.9` 는 그대로라 선언과 같고, 다른 값 `^3.1.3` 하나만 찍혔다. 그 줄도 (f) 가 읽는 꼴(`riverpod_lint:` 줄)이다.
- **M41 은 두 줄을 바꿨는데 화면의 값 줄은 하나다.** (g) 가 틀린 값을 모아 같은 값은 한 번만 찍기 때문이다 (코드에서 읽은 것이다). 두 줄 가운데 하나만 바꾼 경우는 돌리지 않았다.
- **(f) · (g) 가 산문의 옛 값에 걸리지 않는 것은 앵커 정규식과 코드 블록 한정이 함께 막기 때문이다.** README 의 산문에는 `ref: v1.3.0` (7행, Dart 3.13 미만 프로젝트의 안내) 과 `^3.1.3` (372행) 이 있다. (f) 는 줄 전체가 `version:` / `riverpod_lint:` 와 값(뒤에 `# 주석` 가능)인 줄만, (g) 는 줄 전체가 `ref: vX.Y.Z` 인 줄만 받고, 둘 다 ``` 코드 블록 안의 줄만 본다. 블록 한정은 `tool/verify.dart` 의 `fencedLines` 코드를 읽은 것이고, 실행으로 가른 것은 아니다 — 산문의 그 두 줄은 앵커 정규식에도 맞지 않아, 코드 블록을 가리지 않고 파일 전체를 읽는 구현도 지금 README 에서 통과한다.
- **읽은 값이 0개면 실패다 — M42 가 "일치" 가 아니라 실패인 까닭.** start 마커가 없으면 (d) 는 표시 구역을 찾지 못해 이름을 하나도 읽지 못한다. 그때 비교를 건너뛰어 통과로 두지 않고 `구역이 없다` 로 실패하며, 이름 비교의 블록(`… 규칙 목록이 다르다.`)은 찍히지 않았다. 05-03 Task 2 의 검증이 같은 변형을 한 번 봤고, 여기서 기록한다. (e) · (f) · (g) 도 읽은 값이 0개면 `… 하나도 없다` 로 실패한다 — 이 세 경로는 코드에서 읽은 것이고 돌려 보지 않았다.

변경은 모두 커밋하지 않고 되돌렸다 (`git status` 와 `README.md` 를 HEAD 와 견준 `git diff` 로 확인). 끝에 검증 명령이 다시 종료 코드 0, `점검 통과 (10개 중 10개)` 인 것을 봤다.

### 추가 실측 — README 목록 · flow 표기 · 코드 블록 값의 읽지 못하는 줄 (05-07)

실측 (05-07): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-14

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 10개). 이 소절의 변경은 작업 트리가 아니라 **복제본(`git clone --local`)에서** 했다 — 저장소를 임시 폴더에 복제하고, 아직 커밋하지 않은 이 plan 의 `tool/verify.dart` · 문서 변경을 `git diff HEAD` 로 떠서 복제본에 적용해 복제본 안에서만 커밋한 뒤, 복제본에서 `fvm dart pub get --no-example` 을 돌리고 변형 · 실행 · 되돌림을 했다. 변경은 한 번에 하나씩, 줄 번호가 아니라 내용을 기준으로 했다 — M43 · M44 는 `README.md` 의 표시 구역에서 `` - `prefer_single_quotes` `` 줄 앞에 줄을 끼웠다 (`perl -pi -e 'print "…\n" if /^- `prefer_single_quotes`$/'`), M45 · M46 은 `lib/codegen.yaml` (9행) 끝에 `printf '…' >> lib/codegen.yaml` 로 줄을 덧붙였다 (10행부터). M47 ~ M50 은 `README.md` 코드 블록의 키 줄을 `perl -pi` 치환으로 바꿨다 — 「설치」 블록(18행)과 「`ref: main` 에서 tag 로 옮기기」 블록(333행)의 `      ref: v2.0.0` 은 글자가 같아, `ref:` 를 바꾼 M48 · M50 은 `perl -0777 -pi` 에 `/m` 을 주고 `/g` 없이 첫 일치(18행)만 바꿨다. 변경마다 의도한 줄이 들어갔는지(새 줄이 그 파일에 있는지, `git diff --numstat` 이 M43 `1/0` · M44 `2/0` · M47 ~ M49 `1/1` · M50 `3/3`)를 먼저 보고, 검증 명령을 돌린 직후 복제본에서 `git checkout -- <그 파일>` 로 되돌린 뒤에 판정했다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M43 | `README.md` 의 표시 구역에 옛 README(1.0.0 ~ 1.3.0) 꼴의 줄 `- require_trailing_commas: 자동 코드 정렬 최적화` 를 더함 (`` - `prefer_single_quotes` `` 앞) | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 `woody:readme-rules` 구역에 읽지 못하는 줄이 있다 (1): ``<br>`- require_trailing_commas: 자동 코드 정렬 최적화`<br>``` 구역 안에는 빈 줄 · `**분류**` 소제목 · `- `규칙이름`` 불릿만 둔다 (05-VERIFICATION.md gaps 1). ``` | 1 | VERIFY-06 · D-01 — 05-VERIFICATION.md gaps 1 |
| M44 | 같은 자리에 두 줄 `` * `extra` `` (불릿 기호가 다름) 와 `` - `Extra_Rule` `` (backtick 은 있지만 이름 꼴이 아님 — 대문자) 를 함께 더함 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 `woody:readme-rules` 구역에 읽지 못하는 줄이 있다 (2): ``<br>`` * `extra` ``<br>`` - `Extra_Rule` ``<br>``` 구역 안에는 빈 줄 · `**분류**` 소제목 · `- `규칙이름`` 불릿만 둔다 (05-VERIFICATION.md gaps 1). ``` | 1 | VERIFY-06 · D-01 — gaps 1 (느슨한 구현 가르기) |
| M45 | `lib/codegen.yaml` 끝에 flow 표기 한 줄 `linter: {rules: [prefer_mixin]}` (10행) | 단계를 돌리지 못했다 — 예외는 `[3/10]` (b′) 가 `lib/codegen.yaml` 을 읽을 때 났다 | 화면 없음 (stdout 비어 있음). stderr 한 줄:<br>`` 파일 모양이 예상과 다르다: lib/codegen.yaml 의 10행: `linter:` 줄에 값이 붙어 있다 — flow 표기(`linter: {rules: [...]}`)는 읽지 않는다. 블록 목록(`linter:` / `  rules:` / `    - 이름`)으로 적는다 (05-REVIEW.md WR-04): linter: {rules: [prefer_mixin]} `` | 70 | VERIFY-06 — 05-VERIFICATION.md gaps 2 · 05-REVIEW.md WR-04 |
| M46 | `lib/codegen.yaml` 끝에 세 줄 `linter: # 블록 꼴 — 줄 끝 주석은 받는다` / `  rules:` / `    - prefer_mixin` (10 ~ 12행) — 줄 끝 주석을 단 블록 꼴 | `[3/10]` 만. `[2/10]` 과 `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `lib/codegen.yaml` 에 규칙이 있다 (1) — 규칙은 `lib/base.yaml` 에만 적는다. ``<br>`prefer_mixin`<br>`` 그 규칙을 `lib/base.yaml` 로 옮기고 `RULES.md` 의 켠 규칙 표에 적는다 (03-REVIEW.md WR-01 의 관례, 04-REVIEW.md WR-11). `` | 1 | VERIFY-06 — gaps 2 (과잉 수정 가르기) |
| M47 | 「규칙 · plugin 진단 끄기」 의 프로젝트 전체 블록(234행) `    version: ^3.1.9` 를 `    version: "^3.1.3"` 으로 — 큰따옴표로 감싼 다른 값 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 코드 블록에 적힌 riverpod_lint 버전이 `lib/riverpod.yaml` 의 선언(^3.1.9)과 다르다: ``<br>`^3.1.3`<br>`` `README.md` 의 끄기 예시 · `lib/riverpod.yaml` · `fixtures/overrides/analysis_options.yaml` 을 같은 커밋에서 고친다. ``<br>읽지 못하는 줄의 블록은 없다 | 1 | VERIFY-06 · D-02 (3) — 05-REVIEW.md WR-02 |
| M48 | 「설치」 블록(18행)의 `      ref: v2.0.0` 을 `      ref: v1.9.0 # 예시` 로 — 줄 끝 주석을 단 다른 값 (333행은 그대로) | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 `ref: vX.Y.Z` 예시가 `pubspec.yaml` 의 version (2.0.0) 과 다르다: ``<br>`ref: v1.9.0`<br>`` 릴리스 버전을 올릴 때 `README.md` 의 `ref:` 예시도 같은 커밋에서 고친다. ``<br>읽지 못하는 줄의 블록은 없다 | 1 | VERIFY-06 · D-02 (4) — 05-REVIEW.md WR-02 |
| M49 | 「받는 규칙」 의 조각마다의 설정 블록(198행) `  riverpod_lint: ^3.1.9` 를 `  riverpod_lint: ^3.1` 로 — 꼴이 틀린 값 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 코드 블록에 읽지 못하는 `version:` · `riverpod_lint:` 줄이 있다 (1): ``<br>`riverpod_lint: ^3.1`<br>`` 값은 `^X.Y.Z` 로 적는다 — 따옴표와 줄 끝 `# 주석` 은 받는다 (05-REVIEW.md WR-02). `` | 1 | VERIFY-06 · D-02 (3) — 05-REVIEW.md WR-02 |
| M50 | 맞는 값에 따옴표 · 키 줄에 주석 — 「설치」 블록(18행)의 `ref: v2.0.0` 을 `ref: 'v2.0.0'` 으로, 234행을 `    version: "^3.1.9"` 로, 233행의 맵 키 줄 `  riverpod_lint:` 를 `  riverpod_lint: # 끄기 설정의 plugin 선언` 으로 (한 실행에 셋 함께) | 없음 — 10개 모두 통과 | 차이 없음. 화면의 요약은 `점검 통과 (10개 중 10개)` | 0 | VERIFY-06 — WR-02 (과잉 수정 가르기) |

종료 코드 1 인 여섯(M43 · M44 · M46 ~ M49)은 화면의 요약이 `점검 실패 (10개 중 1개)` 였고, M43 · M44 에서는 이름 비교의 블록(`… 규칙 목록이 다르다.`)이 찍히지 않았다 — 읽지 못한 줄의 이름은 목록에 들어가지 않는다. 표의 `[3/10]` 줄은 화면 줄에서 앞의 공백 두 칸(원문 줄 · 규칙 줄 · 값 줄)을 뗀 것이다. plugin 표시줄은 화면이 있는 실행 모두 `riverpod_lint 3.1.9` 였다.

읽는 법은 다음과 같다.

- **M43 은 05-VERIFICATION.md gaps 1 의 재현 입력이다.** 고치기 전에는 같은 줄을 더해도 전체 실행이 종료 코드 0 · `점검 통과 (10개 중 10개)` 였다 (05-VERIFICATION.md 의 실행, 2026-10-14 — 이번에 고치기 전 스크립트로 다시 재지는 않았다). 그때의 reader 는 `- ` 로 시작하지 않는 줄과 backtick 이름이 0개인 줄을 건너뛰었다.
- **두 변경이 함께 느슨한 구현을 가른다.** M43 은 `- ` 로 시작하지만 backtick 이 없는 줄, M44 의 `` * `extra` `` 는 `- ` 로 시작하지 않는 줄이다 — `- ` 줄만 거르고 나머지를 건너뛰는 구현은 둘 중 하나를 지나친다. M44 의 `` - `Extra_Rule` `` 은 backtick 은 있지만 이름 꼴(`[a-z0-9_-]+`)이 아니다 — backtick 이 있으면 이름 꼴이 아니어도 건너뛰는 구현은 `(2)` 대신 `(1)` 을 낸다.
- **구역 안에서 받는 줄은 셋뿐이다** — 빈 줄, `**분류**` 소제목 (backtick 없는 굵은 글씨 한 줄), `` - `이름` `` 불릿 (정확히 `- ` + backtick 이름 하나). 그 밖의 줄은 모두 실패다. Phase 4 WR-10 이 `linter:` 블록의 reader 에서 닫은 "블록 안에서 읽지 못하는 줄은 건너뛰지 않는다" 를 README reader 에도 적용한 것이다. 지금 README 의 구역(빈 줄 · 소제목 넷 · 불릿 81개)은 모두 받는 줄이라 보통 실행은 그대로 통과한다.
- **마커 처리는 `readMarkerBlock` 하나로 합쳤다** (05-REVIEW.md IN-06). `RULES.md` 의 표 reader 와 README 의 불릿 reader 가 같은 함수로 마커 사이의 줄을 받고, 각자의 줄 규칙만 적용한다.
- **M45 는 05-VERIFICATION.md gaps 2 의 재현 입력이다.** 고치기 전에는 같은 줄을 더해도 열 단계를 모두 통과했다 (종료 코드 0 · `점검 통과 (10개 중 10개)` — 05-VERIFICATION.md 의 전체 실행 · 05-REVIEW.md WR-04, 2026-10-13 ~ 14; 이번에 고치기 전 스크립트로 다시 재지는 않았다). (b′) 의 `declaredRuleNames` 가 `linter:` 줄에 붙은 값을 버리고 블록 줄만 읽어 규칙 0개로 봤기 때문이다. 같은 꼴로 `always_specify_types` 를 적으면 `fixtures/base_codegen` 의 분석에 그 진단 25건이 났다 (05-VERIFICATION.md 의 실행) — 규칙이 사용 프로젝트에 닿는데 검사는 못 봤다.
- **M45 가 멈추는 자리는 `[3/10]` (b′) 다.** `[2/10]` 은 `lib/base.yaml` 의 규칙만 세고 `lib/codegen.yaml` 의 `linter:` 는 읽지 않는다 (코드에서 읽은 것 — M36 과 같다). stderr 문구에는 파일 이름(`lib/codegen.yaml`) · 행 번호(10행) · 그 줄의 원문이 들어간다. 단계 줄은 찍히지 않고 종료 코드 70 으로 끝난다.
- **M46 은 과잉 수정을 가른다.** 받는 `linter:` 줄은 `linter:` 뒤에 공백과 줄 끝 `# 주석` 만 오는 꼴이다 (`^linter:[ \t]*(?:#.*)?$`). `linter:` 뒤에 무엇이든 붙으면 멈추게 만든 구현, 또는 `^linter:\s*$` 만 받는 구현은 M46 에서 종료 코드 70 으로 멈춘다. M46 은 M35 와 같은 길로 `[3/10]` 만 실패했다 — `[2/10]` 과 정답지 단계가 통과하는 까닭도 M35 와 같다.
- **04-13 소절 읽는 법의 "flow 표기는 … `[2/10]` 이 잡는다" 는 그때의 동작이다.** 이제는 `lib/base.yaml` 의 flow 표기도 `[2/10]` 의 `countDeclaredRules` 자리에서 종료 코드 70 으로 멈춘다 (코드에서 읽은 것 — 돌리지 않았다).
- **(f) · (g) 는 코드 블록의 키 줄을 모두 후보로 잡고, 따옴표와 줄 끝 `# 주석` 을 벗긴 값을 본다.** (f) 는 `version:` · `riverpod_lint:` 줄의 값이 `^X.Y.Z` 꼴인지, (g) 는 `ref:` 줄의 값이 `vX.Y.Z` 나 `main` 인지 보고, 꼴이 틀린 줄은 건너뛰지 않고 `읽지 못하는 … 줄이 있다 (N)` 으로 실패한다 (05-REVIEW.md WR-02). 고치기 전에는 M47 ~ M49 셋 모두 그 줄을 건너뛰어 통과했다 — M47 의 꼴은 05-REVIEW.md WR-02 가 전체 실행으로 재현했고 (2026-10-13), M48 · M49 는 옛 코드를 읽은 것이다 (이번에 고치기 전 스크립트로 다시 재지는 않았다). M48 은 (g) 의 정규식이 줄 끝 주석을 받지 않아 18행을 건너뛰고 333행의 `v2.0.0` 만 읽었고, M49 는 (f) 가 198행을 건너뛰고 234행만 읽었다. 이제 (f) 와 (g) 는 줄 끝 주석에서 대칭이다.
- **따옴표를 벗기는 함수는 `unquotedScalar` 하나다** — 같은 문자의 바깥 따옴표 한 쌍만 벗긴다. YAML 에서 `"^3.1.9"` 와 `^3.1.9` 는 같은 값이라 analyzer 에게 같은 선언이다. 05-09 가 plugin 선언 · pubspec reader 에 같은 함수를 다시 쓴다.
- **M47 과 M50 이 양쪽을 가른다.** M47 은 벗긴 값 `^3.1.3` 을 값 줄로 찍고 읽지 못하는 줄의 블록은 내지 않았다 — 한쪽 따옴표만 벗기는 구현은 이 줄 대신 읽지 못하는 줄의 블록을 낸다. M50 은 맞는 값에 따옴표를 단 두 줄과 주석만 붙은 맵 키 줄로 10개 모두 통과했다 — 따옴표를 모두 거부하는 구현, 또는 키 줄의 `# 주석` 을 값으로 잡는 구현은 M50 에서 실패한다.
- **값 없는 맵 키 줄은 후보가 아니다.** M49 의 `(1)` 은 233행의 `  riverpod_lint:` (값 없음 — 그 아래 `version:` 을 담는 맵) 를 읽지 못하는 줄로 세지 않았다는 확인이다 — 셌다면 `(2)` 였다.
- **`version:` 을 `riverpod_lint:` 맵 아래로 좁히지는 않았다** (05-REVIEW.md WR-02 의 부수 문제 — 소유자 승인 밖이라 열린 채 둔다). README 에 pubspec 예시 블록을 넣으면 그 `version:` 도 견준다. 지금 README 에는 그런 블록이 없다.
- **펜스 판정(`~~~`, 펜스 길이)은 05-08 이 고친다.** 지금의 `fencedLines` 는 ``` 로 시작하는 줄에서 블록을 열고 닫는다.

걸린 시간: 복제본의 첫 실행(plugin 준비 포함) 68 ~ 69초, M43 24초, M44 23초, M45 3초 (`[3/10]` 에서 멈춰 연습용 프로젝트를 분석하지 않았다), M46 23초, M47 ~ M50 각 23초, 되돌린 뒤의 보통 실행 22 ~ 24초.

변경은 모두(M43 ~ M50) 커밋하지 않고 복제본에서 되돌렸다 (복제본의 `git status` 와 `README.md` · `lib/codegen.yaml` 을 HEAD 와 견준 `git diff` 로 확인). 끝에 복제본에서 검증 명령이 다시 종료 코드 0, `점검 통과 (10개 중 10개)` 인 것을 봤다. 작업 트리는 건드리지 않았고, 복제본은 끝에 지웠다.

### 추가 실측 — RULES.md 표 · analyzer 옵션 · README 주소 · 펜스의 꼴 (05-08)

실측 (05-08): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-14

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 10개). 이 소절의 변경도 05-07 소절처럼 작업 트리가 아니라 **복제본(`git clone --local`)에서** 했다 — 저장소를 임시 폴더에 복제하고, 아직 커밋하지 않은 이 plan 의 변경을 `git diff HEAD` 로 떠서 복제본에 적용해 복제본 안에서만 커밋한 뒤, 복제본에서 `fvm dart pub get --no-example` 을 돌리고 변형 · 실행 · 되돌림을 했다. 변경은 한 번에 하나씩, 줄 번호가 아니라 내용을 기준으로 했다 — M51 ~ M53 은 `RULES.md` 의 `<!-- woody:enabled-rules:end -->` 줄 앞에 줄을 끼웠다 (`perl -pi -e 'print "…\n" if /^<!-- woody:enabled-rules:end -->$/'`). M54 ~ M58 은 `README.md` 를 `perl -pi` 치환으로 바꿨다 — 「설치」 블록(13 ~ 19행)과 「`ref: main` 에서 tag 로 옮기기」 블록은 글자가 같아, 펜스를 바꾼 M56 ~ M58 과 67행(`  - package:woody_lints/base.yaml` 의 첫 일치)을 바꾼 M55 는 `perl -0777 -pi` 에 `/m` 을 주고 `/g` 없이 첫 일치만 바꿨다. M59 ~ M62 는 `lib/base.yaml` (95행, `analyzer:` 없음) 끝에 `printf '…' >> lib/base.yaml` 로 줄을 덧붙였다 (96행부터). 변경마다 의도한 줄이 들어갔는지(그 줄이 파일에 있는지, `git diff --numstat` 이 M51 · M52 `1/0` · M53 `2/0` · M54 `1/1` · M55 `2/2` · M56 `3/3` · M57 · M58 `4/2` · M59 `2/0` · M60 `1/0` · M61 · M62 `3/0`, 펜스 변형은 둘째 블록의 `ref: v2.0.0` 이 하나 남았는지)를 먼저 보고, 검증 명령을 돌린 직후 복제본에서 `git checkout -- <그 파일>` 로 되돌린 뒤에 판정했다. 표 칸 안의 `\|` 는 원문의 `|` 다.

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M51 | `RULES.md` 의 켠 규칙 구역 끝(`<!-- woody:enabled-rules:end -->` 앞)에 첫 칸에 backtick 이 없는 행 `\| prefer_mixin \| 성능 \| 이유 \| 0 · 0 · 0 \| 해당 없음 \| R1 \|` 를 더함 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `RULES.md` 의 `woody:enabled-rules` 구역에 읽지 못하는 줄이 있다 (1): ``<br>`\| prefer_mixin \| 성능 \| 이유 \| 0 · 0 · 0 \| 해당 없음 \| R1 \|`<br>`` 구역 안에는 표 머리 줄 · 구분 줄 · 첫 칸이 backtick 이름 하나인 행만 둔다 (행이 없는 표는 `없음 — …` 한 줄). `` | 1 | VERIFY-06 · D-01 — 05-REVIEW 같은 모양 (소유자 승인 Q1) |
| M52 | 같은 자리에 대문자 이름의 행 `` \| `Prefer_Mixin` \| 성능 \| 이유 \| 0 · 0 · 0 \| 해당 없음 \| R1 \| `` 를 더함 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `RULES.md` 의 `woody:enabled-rules` 구역에 읽지 못하는 줄이 있다 (1): ``<br>`` \| `Prefer_Mixin` \| 성능 \| 이유 \| 0 · 0 · 0 \| 해당 없음 \| R1 \| ``<br>`` 구역 안에는 표 머리 줄 · 구분 줄 · 첫 칸이 backtick 이름 하나인 행만 둔다 (행이 없는 표는 `없음 — …` 한 줄). `` | 1 | VERIFY-06 · D-01 — 05-REVIEW 같은 모양 (소유자 승인 Q1, 느슨한 구현 가르기) |
| M53 | 같은 자리에 두 줄 `` - `prefer_mixin` `` (표 행이 아닌 불릿) 와 `없음 — 켠 규칙이 없다.` (데이터 행이 있는 구역의 빈 표 줄) 를 함께 더함 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `RULES.md` 의 `woody:enabled-rules` 구역에 읽지 못하는 줄이 있다 (2): ``<br>`` - `prefer_mixin` ``<br>`없음 — 켠 규칙이 없다.`<br>`` 구역 안에는 표 머리 줄 · 구분 줄 · 첫 칸이 backtick 이름 하나인 행만 둔다 (행이 없는 표는 `없음 — …` 한 줄). `` | 1 | VERIFY-06 · D-01 — 05-REVIEW 같은 모양 (소유자 승인 Q1, 느슨한 구현 가르기) |
| M54 | 「프리셋 고르기」 기본 + codegen 블록(78행)의 `  - package:woody_lints/codegen.yaml` 을 `  - package:woody_lints/codegen.yml` 로 — 확장자가 `.yml` | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 `package:woody_lints/` 주소 가운데 `<이름>.yaml` 꼴이 아닌 것이 있다 (1): ``<br>`package:woody_lints/codegen.yml`<br>`` 주소는 `package:woody_lints/<이름>.yaml` 로 적는다 — 이름은 영문 · 숫자 · `_`, 하위 폴더 없이, 확장자는 `.yaml` (05-REVIEW.md WR-01). ``<br>`lib/` 에 없다는 블록은 없다 | 1 | VERIFY-06 · D-02 (2) — 05-REVIEW.md WR-01 |
| M55 | 「기본 + Riverpod」 블록의 두 줄 — 67행 `  - package:woody_lints/base.yaml` 을 `  - package:woody-lints/base.yaml` (hyphen 오타) 로, 68행 `  - package:woody_lints/riverpod.yaml` 을 `  - package:woody_lint/riverpod.yaml` (밑줄 오타) 로 (한 실행에 둘 함께) | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 에 `woody_lints` 가 아닌 패키지의 `.yaml` 주소가 있다 (2): ``<br>`package:woody-lints/base.yaml`<br>`package:woody_lint/riverpod.yaml`<br>`` 이 README 의 include 주소는 모두 `package:woody_lints/<이름>.yaml` 이다 — 패키지 이름을 고친다 (05-VERIFICATION.md W1). `` | 1 | VERIFY-06 · D-02 (2) — 05-VERIFICATION.md W1 (소유자 결정 R2-Q3) |
| M56 | 「설치」 블록(13 ~ 19행)의 펜스를 `~~~yaml` / `~~~` 로, 그 안의 `      ref: v2.0.0` 을 `      ref: v1.9.0` 으로 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `README.md` 의 `ref: vX.Y.Z` 예시가 `pubspec.yaml` 의 version (2.0.0) 과 다르다: ``<br>`ref: v1.9.0`<br>`` 릴리스 버전을 올릴 때 `README.md` 의 `ref:` 예시도 같은 커밋에서 고친다. `` | 1 | VERIFY-06 · D-02 (4) — 05-REVIEW.md WR-03 |
| M57 | 같은 블록을 백틱 넷 `` ````yaml `` / `` ```` `` 로 열고 닫고, `dev_dependencies:` 다음 줄과 닫는 펜스 앞에 `` ``` `` 한 줄씩을 끼우며, `ref: v1.9.0` 으로 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄: M56 과 같다 (`ref: v1.9.0`) | 1 | VERIFY-06 · D-02 (4) — 05-REVIEW.md WR-03 (느슨한 구현 가르기) |
| M58 | 같은 블록을 `~~~yaml` / `~~~` 로 열고 닫고, M57 처럼 안쪽에 `` ``` `` 두 줄, `ref: v1.9.0` 으로 | `[3/10]` 만. `[1/10]` · `[2/10]` · `[4/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄: M56 과 같다 (`ref: v1.9.0`) | 1 | VERIFY-06 · D-02 (4) — 05-REVIEW.md WR-03 (느슨한 구현 가르기) |
| M59 | `lib/base.yaml` 끝에 두 줄 `analyzer:` / `  language: {strict-casts: true}` (96 · 97행) — `language:` 줄의 flow 표기 | 단계를 돌리지 못했다 — 예외는 `[3/10]` (c) 가 `lib/base.yaml` 의 켠 옵션을 읽을 때 났다 | 화면 없음 (stdout 비어 있음). stderr 한 줄:<br>`` 파일 모양이 예상과 다르다: lib/base.yaml 의 97행: `language:` 줄에 값이 붙어 있다 — flow 표기는 읽지 않는다. 블록(`analyzer:` / `  language:` / `    <이름>: true\|false`)으로 적는다: language: {strict-casts: true} `` | 70 | VERIFY-06 — 소유자 결정 R2-Q2 (gaps 2 와 같은 원칙) |
| M60 | `lib/base.yaml` 끝에 한 줄 `analyzer: {language: {strict-casts: true}}` (96행) — `analyzer:` 줄의 flow 표기 | 단계를 돌리지 못했다 — M59 와 같은 자리 | 화면 없음 (stdout 비어 있음). stderr 한 줄:<br>`` 파일 모양이 예상과 다르다: lib/base.yaml 의 96행: `analyzer:` 줄에 값이 붙어 있다 — flow 표기는 읽지 않는다. 블록(`analyzer:` / `  language:` / `    <이름>: true\|false`)으로 적는다: analyzer: {language: {strict-casts: true}} `` | 70 | VERIFY-06 — 소유자 결정 R2-Q2 (느슨한 구현 가르기) |
| M61 | `lib/base.yaml` 끝에 세 줄 `analyzer:` / `  language:` / `    strict-casts: yes` (96 ~ 98행) — 값이 `true` · `false` 가 아닌 옵션 줄 | 단계를 돌리지 못했다 — M59 와 같은 자리 | 화면 없음 (stdout 비어 있음). stderr 한 줄:<br>`` 파일 모양이 예상과 다르다: lib/base.yaml 의 `language:` 블록의 98행을 읽지 못했다 — `<이름>: true\|false` (뒤에 `# 주석` 가능) 만 받는다: strict-casts: yes `` | 70 | VERIFY-06 — 소유자 결정 R2-Q2 (gaps 2 와 같은 원칙) |
| M62 | `lib/base.yaml` 끝에 세 줄 `analyzer: # 블록 꼴` / `  language: # 줄 끝 주석은 받는다` / `    strict-casts: true # 켬` (96 ~ 98행) — 줄 끝 주석을 단 블록 꼴 | `[3/10]` 과 `[5/10]` · `[7/10]` ~ `[10/10]`. `[1/10]` · `[2/10]` · `[4/10]` · `[6/10]` 은 통과 | `[3/10]` 이 낸 줄:<br>`` `RULES.md` 의 켠 analyzer 옵션 표와 `lib/base.yaml` 의 `analyzer: language:` 가 다르다. ``<br>`+ strict-casts  (base.yaml 에만)`<br>`` `RULES.md` 의 표와 `lib/base.yaml` 을 같은 커밋에서 고친다. ``<br>정답지 단계 다섯은 모두 종료 코드 정답지 2 (`base_codegen` 은 0) · 실제 3 과, 정답지에 없는 줄 `lib/strict_rules.dart:6  error  invalid_assignment` 하나 | 1 | VERIFY-06 — 소유자 결정 R2-Q2 (과잉 수정 가르기) |

종료 코드 1 인 여덟(M51 ~ M58)은 화면의 요약이 `점검 실패 (10개 중 1개)` 였고, M62 는 `점검 실패 (10개 중 6개)` 였다. M51 ~ M53 은 셋 모두 표 비교의 블록(`` `RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록이 다르다. ``)이 찍히지 않았다 — 읽지 못한 줄의 이름은 목록에 들어가지 않는다. 표의 `[3/10]` 줄은 화면 줄에서 앞의 공백 두 칸(원문 줄 · 주소 줄 · 값 줄)을 뗀 것이다. plugin 표시줄은 화면이 있는 실행 모두 `riverpod_lint 3.1.9` 였다.

읽는 법은 다음과 같다.

- **`RULES.md` 의 표 구역 안에서 받는 줄은 넷뿐이다** — 표 머리 줄 (구역의 0번째 줄이고 첫 칸에 backtick 이 없을 때만), 구분 줄 (머리 줄 바로 뒤 1번째 줄이고 `|---|---|` 꼴일 때만), 첫 칸이 backtick 이름(`[a-z0-9_-]+`) 하나인 데이터 행, 데이터 행이 하나도 없는 구역의 `없음 — …` 한 줄. 그 밖의 줄은 모두 실패다. 05-07 이 README 표시 구역 reader 에서 닫은 "구역 안에서 읽지 못하는 줄은 건너뛰지 않는다" 를 `RULES.md` 표에도 적용한 것이다. `[3/10]` (c) 는 `woody:enabled-rules` · `woody:enabled-options` 두 구역을 같은 reader(`readRulesMdBlock`)로 읽는다.
- **세 변경이 각각 느슨한 구현을 가른다.** M51 은 자리를 보지 않고 backtick 없는 아무 `|` 행을 머리 줄로 받는 구현 (고치기 전처럼 건너뛰는 구현) 을, M52 는 대소문자를 무시해 이름으로 읽는 구현을 가른다 — 그런 구현은 `prefer_mixin` 을 이름으로 읽어 표 비교 블록(`- prefer_mixin  (RULES.md 에만)`)을 찍는다 (따져 본 것이고, 그런 구현을 돌리지는 않았다). M53 의 불릿은 `|` 행이 아닌 줄을 건너뛰는 구현을, `없음 — 켠 규칙이 없다.` 는 데이터 행이 있는 구역에서도 `없음 — …` 을 받는 구현을 가른다 — 그 구현은 `(2)` 대신 `(1)` 을 낸다.
- **`없음 — …` 줄을 받는 까닭.** 지금 `woody:enabled-options` 구역은 머리 줄 · 구분 줄 뒤에 `없음 — analyzer 옵션을 켜지 않았다.` 한 줄이 있다 (GFM 은 이 줄을 첫 칸 하나짜리 행으로 그린다). 받는 줄을 머리 줄 · 구분 줄 · 데이터 행 셋으로 닫으면 지금 `RULES.md` 가 실패하므로, `RULES.md` 는 고치지 않고 데이터 행이 없는 구역의 그 한 줄만 받았다. 복제본의 기준 실행(지금 `RULES.md`)이 `점검 통과 (10개 중 10개)` 인 것이 그 확인이다.
- **고치기 전 수치는 소유자의 함수 단위 확인이다** (2026-10-14) — 세 입력 모두 고치기 전의 reader 가 이름 81개를 그대로 읽고 읽지 못한 줄은 0개였다 (backtick 없는 첫 칸 · 대문자 이름 · `|` 로 시작하지 않는 줄을 건너뛰었다). 이번에 고치기 전 스크립트로 전체 실행을 다시 재지는 않았다.
- **`tool/measure_rules.dart` 의 `--audit` 이 쓰는 표 reader(`readRulesTable`)는 옛 규약 그대로다.** 소유자 결정(2026-10-14)으로 그 문서 주석만 고쳐 "`tool/verify.dart` 의 reader 와 같은 규약" 이라고 말하지 않게 했고, 동작을 엄격하게 만드는 일은 열린 채 남는다.
- **(e) 는 후보를 넓게 모으고, 꼴이 틀린 주소와 다른 패키지의 주소를 따로 알린다.** `package:woody_lints/` 뒤의 글자를 공백 · backtick · 괄호 · 따옴표 앞까지 모두 후보로 잡아, `<이름>.yaml` 꼴(`^[A-Za-z0-9_]+\.yaml$`)이 아닌 것은 `꼴이 아닌 것이 있다` 로 실패시키고, 꼴이 맞는 것만 `lib/` 의 파일과 견준다. 따로 `package:<이름>/….yaml` · `….yml` 를 모두 모아 `<이름>` 이 `woody_lints` 가 아닌 것을 실패시킨다 — 이름 자리는 `/` · 공백이 아닌 글자 전부라 hyphen 이 든 `woody-lints` 도 후보다. 지금 README 의 `package:` 주소 여덟은 모두 `woody_lints` 의 맞는 꼴이라 기준 실행은 통과한다.
- **M54 는 확장자만 넓힌 구현을 가른다.** `.ya?ml` 을 받아 `lib/` 와 견주는 구현은 `codegen.yml` 을 `lib/` 에 없는 주소로 찍는다 — 이 실행에서 그 블록(`` … 프리셋 주소가 `lib/` 에 없다 ``)은 없었다. 고치기 전에는 옛 정규식(`[A-Za-z0-9_]+\.yaml`)이 `codegen.yml` 을 주소로 잡지 못해 10개 중 10개였다 (05-REVIEW.md WR-01 의 전체 실행 재현 — 이번에 고치기 전 스크립트로 다시 재지는 않았다).
- **M55 는 패키지 이름을 보지 않는 구현과, 이름 자리를 `[A-Za-z0-9_]+` 로 좁힌 구현을 가른다.** 앞의 구현은 블록을 내지 않고, 뒤의 구현은 hyphen 이름을 놓쳐 `(2)` 대신 `(1)` 을 낸다. 고치기 전에는 두 오타 모두 10개 중 10개였다 (05-VERIFICATION.md W1 · plan-checker 의 실행 — 이번에 다시 재지는 않았다). `lib/` 와의 비교 블록은 찍히지 않았다 — 그 비교는 README 의 `woody_lints` 주소가 `lib/` 에 있는지만 보고, 주소가 빠지는 것은 보지 않는다 (코드에서 읽은 것).
- **세 펜스 변형이 각각 한 구현을 가른다.** M56 (`~~~` 블록 안의 `ref: v1.9.0`) 은 백틱만 아는 구현을 — 그 구현은 `~~~` 블록을 산문으로 보아 그 값을 읽지 않고 둘째 블록의 `ref: v2.0.0` 만 읽어 통과한다 (고치기 전의 `fencedLines` 가 이 꼴이었다 — 05-REVIEW.md WR-03 의 함수 단위 재현). M57 (백틱 넷 블록 안의 백틱 셋 짝) 은 길이를 보지 않는 구현을, M58 (`~~~` 블록 안의 백틱 셋 짝) 은 문자를 보지 않는 구현을 가른다 — 그런 구현은 안쪽 백틱 셋에서 블록을 닫아 `ref:` 줄을 블록 밖으로 보고 통과한다. 안쪽 펜스를 짝(두 줄)으로 두어 뒤쪽 블록의 펜스 짝이 뒤집히지 않게 했다. 세 변형 모두 실패한 것은 펜스를 여는 문자 · 길이를 기억하고, 같은 문자만으로 된 · 같거나 긴 줄에서만 닫기 때문이다 (그런 느슨한 구현을 돌려 보지는 않았다).
- **05-06 소절 읽는 법의 "블록 한정은 `fencedLines` 코드를 읽은 것이고, 실행으로 가른 것은 아니다" 는 그때의 기록이다.** 이제 M56 ~ M58 이 펜스 판정을 실행으로 가른다.
- **`[3/10]` (c) 가 켠 analyzer 옵션을 읽는 꼴은 블록 꼴 하나다** — `analyzer:` / `  language:` / `    <이름>: true|false`, 세 줄 모두 줄 끝 `# 주석` 을 받는다. 멈추는 꼴은 셋이다: `analyzer:` 줄에 `#` 주석 밖의 값이 붙은 경우 (M60), `language:` 줄에 값이 붙은 경우 (M59), `language:` 블록에 `<이름>: true|false` 가 아닌 줄이 있는 경우 (M61). 셋 모두 종료 코드 70 으로, 문구에 파일 이름 · 행 · 그 줄의 원문이 들어간다 — 05-07 이 `linter:` 줄의 flow 표기에서 닫은 원칙(M45)과 같다. `analyzer:` 아래의 `language:` 가 아닌 키(`errors:` · `exclude:` 와 그 아래)는 지금처럼 읽지 않는다.
- **M60 은 느슨한 구현을, M62 는 과잉 수정을 가른다.** `language:` 줄의 flow 만 잡는 구현은 M60 을 지나쳐 켠 옵션 없음으로 읽는다. `analyzer:` 를 통째로 거부하거나 `#` 주석이 붙은 줄을 거부하는 구현은 M62 에서 70 으로 멈춘다 — M62 는 70 이 아니라 종료 코드 1 이고 stderr 에 `파일 모양이 예상과 다르다` 가 없었으며, `[3/10]` 이 읽은 `strict-casts` 를 `RULES.md` 의 켠 옵션 표와 견줘 `+ strict-casts  (base.yaml 에만)` 을 찍었다. `analyzer:` 가 없는 기준 실행만으로는 과잉 수정을 가를 수 없어 M62 를 뒀다.
- **M62 에서 정답지 단계 다섯도 실패한 것은 `strict-casts` 가 연습용 프로젝트의 분석에 닿기 때문이다.** `lib/base.yaml` 은 배포 파일이라 `example` 과 `fixtures/` 의 넷이 받고, 각자의 `lib/strict_rules.dart` 6행에 `invalid_assignment` error 가 생겨 종료 코드가 3 이 되었다. `recommended` 는 같은 실행의 `example` 결과와 견주므로 함께 바뀌어 통과했다 (03-03 소절의 M18 과 같은 까닭).
- **고치기 전 수치는 소유자의 함수 단위 확인이다** (2026-10-14) — 고치기 전의 reader 는 M59 · M60 을 켠 옵션 없음(`{}`)으로 읽었고, M61 의 줄은 건너뛰었다 (M61 은 코드에서 읽은 것). 이번에 고치기 전 스크립트로 전체 실행을 다시 재지는 않았다.
- **M59 ~ M61 이 멈추는 자리는 `[3/10]` (c) 다.** `[2/10]` 의 `countDeclaredRules` 는 `linter:` 블록만 읽고 `analyzer:` 줄에서 블록을 닫는다 (코드에서 읽은 것). 단계 줄은 찍히지 않고 종료 코드 70 으로 끝난다.
- **지금 `lib/base.yaml` 에는 `analyzer:` 가 없다.** 그래서 기준 실행이 읽는 켠 옵션은 없음이고, `RULES.md` 의 `woody:enabled-options` 구역의 `없음 — …` 줄과 같아 통과한다.

걸린 시간: 복제본의 첫 실행(plugin 준비 포함) 69초 (M51 ~ M53 의 복제본) · 81초 (M54 ~ M58 의 복제본) · 69초 (M59 ~ M62 의 복제본), M51 23초, M52 22초, M53 23초, M54 23초, M55 24초, M56 23초, M57 24초, M58 23초, M59 ~ M61 각 3초 (`[3/10]` 에서 멈춰 연습용 프로젝트를 분석하지 않았다), M62 23초, 되돌린 뒤의 보통 실행 22 ~ 23초.

변경은 모두(M51 ~ M62) 커밋하지 않고 복제본에서 되돌렸다 (복제본의 `git status` 와 `RULES.md` · `README.md` · `lib/base.yaml` 을 HEAD 와 견준 `git diff` 로 확인). 끝에 복제본에서 검증 명령이 다시 종료 코드 0, `점검 통과 (10개 중 10개)` 인 것을 봤다. 작업 트리는 건드리지 않았고, 복제본은 끝에 지웠다.

항목의 `VERIFY-NN` · `PRESET-NN` · `RULES-NN` 은 `.planning/REQUIREMENTS.md` 의 요구사항 번호, `D-NN` 은 `.planning/phases/02-verification-harness/02-CONTEXT.md` 의 결정 번호다. 03-NN 소절의 `D-NN` 은 `.planning/phases/03-preset-split/03-CONTEXT.md` 의 결정 번호다. 04-NN 소절의 `D-NN` 은 `.planning/phases/04-rule-reselection/04-CONTEXT.md` 의 결정 번호다. 05-NN 소절의 `D-NN` 은 `.planning/phases/05-documentation/05-CONTEXT.md` 의 결정 번호다.
