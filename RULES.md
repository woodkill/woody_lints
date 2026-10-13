# woody_lints 규칙 근거

이 문서는 `woody_lints` 가 기반 세트(`flutter_lints` / `lints`) 위에 무엇을 더 켜고 무엇을 켜지 않았는지, 그리고 그 이유를 규칙마다 적는다. 표의 수치는 실제 사용 프로젝트 `flutter_starter_kit` 의 복사본에서 잰 것이며, 회차마다의 조건(SDK · 기반 세트 · plugin 버전)은 아래 "실측 기록" 절에 있다. 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록은 검증 명령(`fvm dart run tool/verify.dart`)의 "배포 파일의 구성" 단계가 서로 같은지 견준다 — 둘은 같은 커밋에서 고친다.

## 켠 규칙

`lib/base.yaml` 의 `linter: rules:` 에 적힌 규칙이다. "켠 이유" 는 `lib/base.yaml` 의 사유 주석과 같은 문장이다.

<!-- woody:enabled-rules:start -->
| 규칙 | 분류 | 켠 이유 | 실측 (lib · test · bin) | dart fix | 회차 |
|---|---|---|---|---|---|
| `prefer_const_constructors` | 성능 | 불변 위젯 트리를 const 로 적는 관례 — 성능 이득은 근거가 부족하다는 것이 Flutter 팀의 판단 (lints#205) | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `prefer_const_literals_to_create_immutables` | 성능 | 위와 같은 관례 — 불변 위젯에 넘기는 리터럴도 const 로 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `always_declare_return_types` | 가독성·스타일 | 기반 세트의 strict_top_level_inference 가 보지 않는 지역 함수 · 옛 typedef 의 반환 타입까지 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `prefer_final_locals` | 가독성·스타일 | 데이터의 불변성 보장 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `prefer_single_quotes` | 가독성·스타일 | 홑따옴표('') 사용 통일 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `prefer_relative_imports` | 가독성·스타일 | lib 안의 같은 패키지 파일은 상대 경로로 import 한다 — 사용 프로젝트의 다수 쪽 스타일 | 9 · 0 · 0 | 9 | R1-G2 · R1-G2-strip · R1-apply-prefer_relative_imports |
| `unawaited_futures` | 버그 방지 | 처리되지 않은 Future 감지 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `async_return_with_no_await` | 버그 방지 | await 없이 넘긴 Future 는 이 함수의 try/catch 를 지나 예외가 밖에서 난다 | 16 · 14 · 0 | 0 (dry 0) | R1-G1 · R1-G1-strip |
| `avoid_catching_errors` | 버그 방지 | Error 를 잡으면 프로그램 버그가 숨는다 | 2 · 1 · 0 | 0 (dry 0) | R1-G1 · R1-G1-strip |
| `avoid_double_and_int_checks` | 버그 방지 | web 에서 뜻이 달라지는 is double / is int 검사 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `avoid_dynamic_calls` | 버그 방지 | dynamic 위의 호출은 타입 오류를 실행 때까지 숨긴다 | 0 · 28 · 0 | 0 (dry 0) | R1-G1 · R1-G1-strip |
| `avoid_js_rounded_ints` | 버그 방지 | web 에서 정밀도가 깨지는 정수 리터럴 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `avoid_type_to_string` | 버그 방지 | release 빌드에서 타입 이름이 바뀔 수 있다 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `avoid_unused_constructor_parameters` | 버그 방지 | 쓰지 않는 생성자 매개변수는 빠뜨린 대입 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `avoid_void_async` | 버그 방지 | void 를 돌려주는 async 는 호출한 쪽이 기다리거나 오류를 받을 수 없다 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `cancel_subscriptions` | 버그 방지 | 닫지 않은 StreamSubscription 은 메모리 누수 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `cast_nullable_to_non_nullable` | 버그 방지 | null 일 수 있는 값을 as 로 단정하면 실행 중 오류 | 0 · 5 · 0 | 5 | R1-G1 · R1-G1-strip · R1-apply-cast_nullable_to_non_nullable |
| `conditional_uri_does_not_exist` | 버그 방지 | 조건부 import 가 없는 파일을 가리키면 다른 플랫폼에서 빌드가 깨진다 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `deprecated_member_use_from_same_package` | 버그 방지 | 같은 패키지 안의 deprecated 사용을 잡는다 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `discarded_futures` | 버그 방지 | 동기 함수(콜백 · initState 등)에서 버린 Future 의 오류가 사라진다 | 9 · 2 · 0 | 0 (dry 0) | R1-G1 · R1-G1-strip |
| `literal_only_boolean_expressions` | 버그 방지 | 늘 참이나 거짓인 조건은 남은 디버그 코드 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `matching_super_parameters` | 버그 방지 | super 매개변수의 순서 착오 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `missing_whitespace_between_adjacent_strings` | 버그 방지 | 이어 붙인 문자열 사이의 공백 누락으로 문장이 붙는다 | 0 · 13 · 0 | 0 (dry 0) | R1-G1 · R1-G1-strip |
| `no_adjacent_strings_in_list` | 버그 방지 | 리스트 안의 붙은 문자열은 쉼표 누락일 때가 많다 | 0 · 9 · 0 | 0 (dry 0) | R1-G1 · R1-G1-strip |
| `no_self_assignments` | 버그 방지 | x = x 는 거의 늘 오타 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `only_throw_errors` | 버그 방지 | Exception 이나 Error 가 아닌 값을 던지면 잡는 쪽이 스택을 잃는다 | 0 · 4 · 0 | 0 (dry 0) | R1-G1 · R1-G1-strip |
| `parameter_assignments` | 버그 방지 | 매개변수를 다시 쓰면 원래 값을 잃는다 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `switch_on_type` | 버그 방지 | runtimeType 으로 가르면 하위 타입을 놓친다 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `test_types_in_equals` | 버그 방지 | == 에서 인자 타입을 보지 않으면 cast 오류 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `throw_in_finally` | 버그 방지 | finally 의 throw 는 원래 예외를 덮는다 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `unnecessary_statements` | 버그 방지 | 효과 없는 문장은 빠진 호출 · 대입의 흔적 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `no_dynamic_casts` | 버그 방지 (strict) | dynamic 값을 구체 타입 자리에 넣는 암묵적 cast 를 잡는다 — strict-casts 옵션의 공식 대체이고 info 라 받는 쪽 CI 를 막지 않는다 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
| `no_raw_types` | 버그 방지 (strict) | 타입 인자를 생략한 제네릭 타입을 잡는다 — strict-raw-types 옵션의 공식 대체이고 info 다 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-G1 · R1-G1-marker · R1-G1-strip |
<!-- woody:enabled-rules:end -->

### 켠 analyzer 옵션

`lib/base.yaml` 의 `analyzer: language:` 아래 `true` 로 켠 옵션이다.

<!-- woody:enabled-options:start -->
| 옵션 | 켠 이유 | 실측 | 회차 |
|---|---|---|---|
없음 — analyzer 옵션을 켜지 않았다.
<!-- woody:enabled-options:end -->

## 켜지 않은 규칙

검토했지만 `lib/base.yaml` 에 적지 않은 규칙이다. "이유" 칸은 아래 접두사 7종 가운데 하나로 시작한다.

- `기반 세트` — 기반 세트(`flutter_lints` / `lints`)가 이미 켠다. 어느 세트 파일이 켜는지 함께 적는다
- `비호환` — 이미 켠 규칙과 함께 쓸 수 없다
- `experimental` 또는 `testing` — 상류가 안정 상태로 두지 않은 규칙이다
- `v2 로 미룸 (RULES-NN)` — 다음 마일스톤의 요구사항으로 미뤘다
- `deprecated` · `removed` · `없음` — 지금 SDK 에서 쓸 수 없는 이름이다
- `규칙이 돌지 않음` — 켜도 보고하지 않는다 (일부러 넣은 위반까지 0줄)
- `소유자 결정` — 실측을 보고 소유자가 켜지 않기로 했다

<!-- woody:disabled-rules:start -->
| 규칙 | 이유 |
|---|---|
| `sized_box_for_whitespace` | 기반 세트 — `flutter_lints` 6.0.0 `flutter.yaml` 이 켠다 |
| `sort_child_properties_last` | 기반 세트 — `flutter_lints` 6.0.0 `flutter.yaml` 이 켠다 |
| `slash_for_doc_comments` | 기반 세트 — `lints` 6.1.0 `recommended.yaml` 이 켠다 |
| `use_build_context_synchronously` | 기반 세트 — `flutter_lints` 6.0.0 `flutter.yaml` 이 켠다 |
| `avoid_print` | 기반 세트 — `flutter_lints` 6.0.0 `flutter.yaml` 이 켠다 |
| `control_flow_in_finally` | 기반 세트 — `lints` 6.1.0 `recommended.yaml` 이 켠다 |
| `always_use_package_imports` | 비호환 — 켠 `prefer_relative_imports` 와 함께 쓸 수 없다 (소유자 결정 2026-10-13, 사용 프로젝트의 소수 쪽 스타일이라 켜면 615줄) |
| `avoid_equals_and_hash_code_on_mutable_classes` | 소유자 결정 — `@immutable` 표시가 없을 뿐인 클래스도 걸린다 (8줄 모두 lib, dart fix 0) |
| `avoid_implementing_value_types` | 소유자 결정 — test 의 mock · fake 가 걸리는 규칙 (25줄 모두 test) |
| `unnecessary_unawaited` | 소유자 결정 — `dart fix` 가 3줄을 지우고 error 9건을 남긴다 |
| `strict-inference` | 소유자 결정 — analyzer 옵션(`analyzer: language:`)이고 진단이 warning 이라 받는 쪽 `dart analyze` 가 바로 실패한다 (106줄 모두 test, dart fix 0) |
<!-- woody:disabled-rules:end -->

formatter: 설정은 기본 프리셋에 넣지 않는다 (04-CONTEXT.md D-13, REQUIREMENTS.md Out of Scope)

## 실측 기록

<!-- woody:measurements:start -->
(tool/measure_rules.dart --report --write 가 생성한다. 손으로 고치지 않는다.)
<!-- woody:measurements:end -->
