## 2.0.0 - 미출시

지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)

### 올리기 전에

- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.
- 옛 주소 한 줄을 쓰는 프로젝트는 고칠 것이 없다. 새 프로젝트는 `package:woody_lints/recommended.yaml` 을 include 한다.

### 추가한 규칙

- `prefer_relative_imports` — lib 안의 같은 패키지 파일은 상대 경로로 import 한다 — 사용 프로젝트의 다수 쪽 스타일
- `async_return_with_no_await` — await 없이 넘긴 Future 는 이 함수의 try/catch 를 지나 예외가 밖에서 난다
- `avoid_catching_errors` — Error 를 잡으면 프로그램 버그가 숨는다
- `avoid_double_and_int_checks` — web 에서 뜻이 달라지는 is double / is int 검사
- `avoid_dynamic_calls` — dynamic 위의 호출은 타입 오류를 실행 때까지 숨긴다
- `avoid_js_rounded_ints` — web 에서 정밀도가 깨지는 정수 리터럴
- `avoid_type_to_string` — release 빌드에서 타입 이름이 바뀔 수 있다
- `avoid_unused_constructor_parameters` — 쓰지 않는 생성자 매개변수는 빠뜨린 대입
- `avoid_void_async` — void 를 돌려주는 async 는 호출한 쪽이 기다리거나 오류를 받을 수 없다
- `cancel_subscriptions` — 닫지 않은 StreamSubscription 은 메모리 누수
- `cast_nullable_to_non_nullable` — null 일 수 있는 값을 as 로 단정하면 실행 중 오류
- `conditional_uri_does_not_exist` — 조건부 import 가 없는 파일을 가리키면 다른 플랫폼에서 빌드가 깨진다
- `deprecated_member_use_from_same_package` — 같은 패키지 안의 deprecated 사용을 잡는다
- `discarded_futures` — 동기 함수(콜백 · initState 등)에서 버린 Future 의 오류가 사라진다
- `literal_only_boolean_expressions` — 늘 참이나 거짓인 조건은 남은 디버그 코드
- `matching_super_parameters` — super 매개변수의 순서 착오
- `missing_whitespace_between_adjacent_strings` — 이어 붙인 문자열 사이의 공백 누락으로 문장이 붙는다
- `no_adjacent_strings_in_list` — 리스트 안의 붙은 문자열은 쉼표 누락일 때가 많다
- `no_self_assignments` — x = x 는 거의 늘 오타
- `only_throw_errors` — Exception 이나 Error 가 아닌 값을 던지면 잡는 쪽이 스택을 잃는다
- `parameter_assignments` — 매개변수를 다시 쓰면 원래 값을 잃는다
- `switch_on_type` — runtimeType 으로 가르면 하위 타입을 놓친다
- `test_types_in_equals` — == 에서 인자 타입을 보지 않으면 cast 오류
- `throw_in_finally` — finally 의 throw 는 원래 예외를 덮는다
- `unnecessary_statements` — 효과 없는 문장은 빠진 호출 · 대입의 흔적

### 그 밖의 변경

- 저장소 안에 검증용 연습 프로젝트 여섯(`example/` 과 `fixtures/` 다섯), 검증 명령 `tool/verify.dart`, GitHub Actions workflow 를 추가. 사용하는 프로젝트에는 영향 없음.
- 프리셋을 조각 셋과 묶음으로 나눔 — `package:woody_lints/base.yaml` (기본 규칙), `riverpod.yaml` (`riverpod_lint` plugin), `codegen.yaml` (생성 파일 제외와 `invalid_annotation_target: ignore`), `recommended.yaml` (셋을 한 번에). 규칙 · 주석 · 설정은 옮기기만 했고 내용은 1.3.0 과 같다 (minor — 새 프리셋 파일 추가).
- 옛 주소 `package:woody_lints/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 별칭으로 남긴다 — 그 한 줄을 쓰는 프로젝트가 받는 구성(기본 + Riverpod + codegen)은 같다. 사용하는 프로젝트에는 영향 없음.
- 저장소 자체 분석용 루트 `analysis_options.yaml` 의 `lib/analysis_options.yaml` 제외를 걷어냄 — 나눈 뒤에는 그 파일에 `plugins:` 가 없어 `plugins_in_inner_options` 가 나지 않는다 (Dart 3.13.4). 사용하는 프로젝트에는 영향 없음.
- `riverpod_lint` plugin 의 하한을 `^3.1.3` → `^3.1.9` 로 올림 (같은 major 안이라 minor). 2026-10-12 에 두 선언 모두 3.1.9 로 풀려 경고가 달라지지 않았다 — 정답지 다섯 그대로. 3.1.9 는 Dart 3.13 이상을 요구하고 이 패키지의 SDK 하한과 맞는다.
- 기반 세트와 겹치는 선언 6개(`sized_box_for_whitespace`, `sort_child_properties_last`, `slash_for_doc_comments`, `use_build_context_synchronously`, `avoid_print`, `control_flow_in_finally`)와 주석 처리된 설정 3개(`require_trailing_commas`, `public_member_api_docs`, `formatter: trailing_commas`)를 배포 파일에서 지움. 기반 세트가 여전히 켜므로 사용하는 프로젝트에는 영향 없음 (정답지 다섯 그대로, 2026-10-13).
- 규칙 근거 문서 `RULES.md` 를 추가하고 검증 명령에 `[3/10]` 배포 파일의 구성 단계를 더함 — 기반 세트와의 겹침, `RULES.md` 와의 일치, 묶음 · 별칭이 include 만 담는지. 사용하는 프로젝트에는 영향 없음.
- 규칙 실측 도구 `tool/measure_rules.dart` 와 회차 기록 `tool/measurements/` 를 추가 — 비공개 사용 프로젝트의 복사본이 있어야 돌므로 CI 에서는 돌지 않는다. 사용하는 프로젝트에는 영향 없음.
- 1.3.0 부터 켜 둔 규칙 6개(`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `always_declare_return_types`, `prefer_final_locals`, `prefer_single_quotes`, `unawaited_futures`)를 모두 남기고, `lib/base.yaml` 의 사유 주석 셋을 사실에 맞게 고침 — const 규칙 둘의 "성능 향상" 문구(Flutter 팀이 근거 부족으로 본 주장, dart-lang/lints#205)와 `always_declare_return_types` 의 범위. 주석만 바뀌어 사용하는 프로젝트에는 영향 없음 (소유자 결정 2026-10-13).

### 새로 생기는 경고

(Phase 4 실측 후 채움)

## 1.3.0

- riverpod_lint 를 최상위 `plugins:` (analysis_server_plugin) 방식으로 전환.
  - 옛 `analyzer: plugins: - riverpod_lint` 선언은 riverpod_lint 3.x 에서 아무것도 로드하지 않아 규칙이 실행된 적이 없었다 → 이번 버전부터 riverpod_lint 규칙이 처음으로 켜진다.
  - Dart 3.13 (Flutter 3.47) 의 `included_file_warning` (legacy plugin deprecated) 해소.
- `flutter_lints` 를 `dev_dependencies` → `dependencies` 로 이동. `include: package:flutter_lints/flutter.yaml` 이 사용하는 프로젝트의 직접 의존 여부와 무관하게 해석된다.
- 저장소 자체 분석용 루트 `analysis_options.yaml` 추가 — `lib/analysis_options.yaml` 의 `plugins:` 가 이 저장소 안에서는 inner 옵션으로 취급되어 나는 `plugins_in_inner_options` 경고를 제외한다. 사용하는 프로젝트에는 영향 없음.

## 1.0.0

- Initial version.
