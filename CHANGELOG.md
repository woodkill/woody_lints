## 2.0.0 - 미출시

지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)

### 올리기 전에

- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.
- 옛 주소 한 줄을 쓰는 프로젝트는 고칠 것이 없다. 새 프로젝트는 `package:woody_lints/recommended.yaml` 을 include 한다.
- 받는 때: `ref: main` 을 따르는 프로젝트는 `main` 에 2.0.0 이 합쳐진 뒤 `flutter pub upgrade woody_lints` 를 하는 순간 받는다. `flutter pub get` 으로는 받지 않고 `pubspec.lock` 에 적힌 커밋에 머문다 (spike 015, 2026-10-12 실측). lock 에 `woody_lints` 항목이 없는 프로젝트의 첫 `pub get` 은 그때의 `main` 을 받는다.
- 올리면서 권하는 일은 README 의 「버전 올리기」 절에 있다 — [README.md](README.md#버전-올리기).

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
- `no_dynamic_casts` — dynamic 값을 구체 타입 자리에 넣는 암묵적 cast 를 잡는다 — strict-casts 옵션의 공식 대체이고 info 라 받는 쪽 CI 를 막지 않는다
- `no_raw_types` — 타입 인자를 생략한 제네릭 타입을 잡는다 — strict-raw-types 옵션의 공식 대체이고 info 다
- `avoid_slow_async_io` — 느린 dart:io async 메서드(exists · stat 등) 대신 sync 판을 쓴다
- `no_runtimetype_tostring` — runtimeType 의 toString() 은 비용이 크다 — 로깅 · toString 구현에서 흔하다
- `noop_primitive_operations` — 효과 없는 원시 타입 연산(int 의 toInt() · String 의 toString() 등)
- `prefer_const_declarations` — const 로 선언할 수 있는 final 은 const 로 적는 관례 — prefer_const_constructors 와 함께 기반 세트에서 빠진 셋 중 하나 (lints#205)
- `sized_box_shrink_expand` — SizedBox.shrink / SizedBox.expand 로 쓸 수 있는 SizedBox
- `use_colored_box` — 색만 지정한 Container 대신 가벼운 ColoredBox
- `use_string_buffers` — 루프 안의 문자열 누적 연결 대신 StringBuffer
- `use_truncating_division` — (a / b).toInt() 대신 정수 나눗셈 a ~/ b
- `avoid_bool_literals_in_conditional_expressions` — cond ? true : false 류는 조건식 하나로 줄인다
- `avoid_escaping_inner_quotes` — 바깥 따옴표를 바꾸면 없앨 수 있는 escape — prefer_single_quotes 의 보완
- `avoid_final_parameters` — 매개변수 선언의 final 은 읽기만 어렵게 한다 (언어 버전 3.13 의 라이브러리에서는 돌지 않는다)
- `avoid_multiple_declarations_per_line` — 한 줄에 변수 하나씩 선언한다
- `avoid_redundant_argument_values` — 기본값과 같은 값을 다시 적은 인자
- `avoid_setters_without_getters` — getter 없는 setter 는 읽을 수 없는 프로퍼티를 만든다
- `combinators_ordering` — show / hide 의 이름을 알파벳 순으로
- `directives_ordering` — import / export 를 정해진 구역과 알파벳 순으로
- `document_ignores` — 무시 주석(// ignore) 바로 윗줄에 끄는 까닭을 적는다
- `flutter_style_todos` — TODO 는 // TODO(이름): 형식으로 담당자를 적는다
- `join_return_with_assignment` — 대입 직후 같은 변수를 return 하지 않고 한 문장으로 쓴다
- `leading_newlines_in_multiline_strings` — 여러 줄 문자열은 개행으로 시작해 줄 맞춤을 읽기 쉽게 한다
- `no_literal_bool_comparisons` — x == true 같은 bool 리터럴 비교
- `omit_obvious_local_variable_types` — 타입이 자명한 지역 변수에는 타입을 적지 않는다
- `prefer_asserts_in_initializer_lists` — 생성자 본문의 assert 는 초기화 목록으로 옮긴다
- `prefer_constructors_over_static_methods` — 인스턴스를 만드는 static 메서드 대신 이름 있는 생성자
- `prefer_final_in_for_each` — 다시 대입하지 않는 for-in 변수는 final 로 — prefer_final_locals 와 같은 관례
- `prefer_if_elements_to_conditional_expressions` — 컬렉션 안의 삼항 연산자 대신 if 요소
- `prefer_int_literals` — double 자리의 1.0 은 1 로 적는다
- `prefer_null_aware_method_calls` — if (f != null) f!() 대신 f?.call()
- `simple_directive_paths` — directive 경로에 ./ 나 되돌아가는 ../ 를 넣지 않는다
- `simplify_variable_pattern` — 변수 pattern 에 같은 이름의 getter 를 다시 적지 않는다
- `sort_constructors_first` — 생성자를 다른 멤버보다 먼저 둔다
- `sort_pub_dependencies` — pubspec.yaml 의 dependencies · dev_dependencies 를 이름 순으로 적는다 — 목록에서 찾기 쉽고 끼워 넣을 자리가 정해진다
- `sort_unnamed_constructors_first` — 이름 없는 생성자를 이름 있는 생성자보다 먼저 둔다
- `specify_nonobvious_property_types` — 타입이 자명하지 않은 top-level · static 변수에는 타입을 적는다
- `tighten_type_of_initializing_formals` — assert(p != null) 대신 초기화 매개변수의 타입으로 null 아님을 적는다
- `type_annotate_public_apis` — 공개 API 에는 타입을 적는다
- `unnecessary_breaks` — switch case 끝의 불필요한 break
- `unnecessary_lambdas` — tear-off 로 쓸 수 있는 람다
- `unnecessary_library_directive` — 문서 주석도 annotation 도 없는 library; 지시문
- `unnecessary_null_aware_operator_on_extension_on_nullable` — nullable 대상 extension 에 쓴 불필요한 ?.
- `unnecessary_null_checks` — nullable 을 받는 자리에 쓴 불필요한 !
- `unnecessary_parenthesis` — 불필요한 괄호
- `unnecessary_raw_strings` — escape 가 없는 문자열의 불필요한 raw 표시
- `use_enums` — enum 처럼 쓰는 클래스는 enum 으로
- `use_is_even_rather_than_modulo` — % 2 == 0 대신 isEven
- `use_named_constants` — Duration(seconds: 0) 같은 값 대신 Duration.zero 같은 이름 있는 상수
- `use_raw_strings` — escape 를 늘어놓는 대신 raw 문자열
- `use_setters_to_change_properties` — 프로퍼티를 바꾸는 메서드 대신 setter

### 그 밖의 변경

- 프리셋을 조각 셋과 묶음으로 나눔 — `package:woody_lints/base.yaml` (기본 규칙), `riverpod.yaml` (`riverpod_lint` plugin), `codegen.yaml` (생성 파일 제외와 `invalid_annotation_target: ignore`), `recommended.yaml` (셋을 한 번에). 규칙 · 주석 · 설정은 옮기기만 했고 내용은 1.3.0 과 같다 (minor — 새 프리셋 파일 추가).
- 옛 주소 `package:woody_lints/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 별칭으로 남긴다 — 그 한 줄을 쓰는 프로젝트가 받는 구성(기본 + Riverpod + codegen)은 같다. 사용하는 프로젝트에는 영향 없음.
- `riverpod_lint` plugin 의 하한을 `^3.1.3` → `^3.1.9` 로 올림 (같은 major 안이라 minor). 2026-10-12 에 두 선언 모두 3.1.9 로 풀려 경고가 달라지지 않았다 — 정답지 다섯 그대로. 3.1.9 는 Dart 3.13 이상을 요구하고 이 패키지의 SDK 하한과 맞는다.
- 기반 세트와 겹치는 선언 6개(`sized_box_for_whitespace`, `sort_child_properties_last`, `slash_for_doc_comments`, `use_build_context_synchronously`, `avoid_print`, `control_flow_in_finally`)와 주석 처리된 설정 3개(`require_trailing_commas`, `public_member_api_docs`, `formatter: trailing_commas`)를 배포 파일에서 지움. 기반 세트가 여전히 켜므로 사용하는 프로젝트에는 영향 없음 (정답지 다섯 그대로, 2026-10-13).
- 규칙 근거 문서 `RULES.md` 를 추가 — 규칙마다 켠 이유와 실측 건수, 켜지 않은 규칙과 그 사유. 문서만 더해 사용하는 프로젝트에는 영향 없음.
- 1.3.0 부터 켜 둔 규칙 6개(`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `always_declare_return_types`, `prefer_final_locals`, `prefer_single_quotes`, `unawaited_futures`)를 모두 남기고, `lib/base.yaml` 의 사유 주석 셋을 사실에 맞게 고침 — const 규칙 둘의 "성능 향상" 문구(Flutter 팀이 근거 부족으로 본 주장, dart-lang/lints#205)와 `always_declare_return_types` 의 범위. 주석만 바뀌어 사용하는 프로젝트에는 영향 없음 (소유자 결정 2026-10-13).
- README 를 다시 씀 — tag 설치(`ref: v2.0.0`), 프리셋 고르기 표, 규칙 · plugin 진단 끄기, 생성 파일 제외, 버전 올리기, 문제 해결. README 의 규칙 목록 · 프리셋 주소 · plugin 버전 · `ref:` 는 검증 명령이 배포 파일 · `pubspec.yaml` 과 견준다. 배포 YAML 다섯의 머리 주석을 실제 구성에 맞게 정리하고 템플릿에서 온 영어 주석을 지움. 1.1.0 ~ 1.2.5 의 CHANGELOG 항목을 git 이력에서 복원. 문서와 주석만 바뀌어 사용하는 프로젝트의 진단에는 영향 없음.
- 저장소 안쪽: 검증용 연습 프로젝트 여섯(`example/` 과 `fixtures/` 다섯)과 검증 명령 `tool/verify.dart` (배포 파일 구성 · README 검사 단계 포함) · GitHub Actions workflow, 루트 분석 설정(`lib/analysis_options.yaml` 제외를 걷어냄), 규칙 실측 도구 `tool/measure_rules.dart` 와 회차 기록 `tool/measurements/`, 측정 도구 · 검증 명령의 결함 수정 — 사용하는 프로젝트에는 영향 없음.

### 새로 생기는 경고

| 규칙 | 강도 | 실측 | dart fix |
|---|---|---|---|
| `prefer_relative_imports` | info | 9건 | 9건 |
| `async_return_with_no_await` | info | 30건 | 0건 |
| `avoid_catching_errors` | info | 3건 | 0건 |
| `avoid_double_and_int_checks` | info | 0건 | 해당 없음 |
| `avoid_dynamic_calls` | info | 28건 | 0건 |
| `avoid_js_rounded_ints` | info | 0건 | 해당 없음 |
| `avoid_type_to_string` | info | 0건 | 해당 없음 |
| `avoid_unused_constructor_parameters` | info | 0건 | 해당 없음 |
| `avoid_void_async` | info | 0건 | 해당 없음 |
| `cancel_subscriptions` | info | 0건 | 해당 없음 |
| `cast_nullable_to_non_nullable` | info | 5건 | 5건 |
| `conditional_uri_does_not_exist` | info | 0건 | 해당 없음 |
| `deprecated_member_use_from_same_package` | info | 0건 | 해당 없음 |
| `discarded_futures` | info | 11건 | 0건 |
| `literal_only_boolean_expressions` | info | 0건 | 해당 없음 |
| `matching_super_parameters` | info | 0건 | 해당 없음 |
| `missing_whitespace_between_adjacent_strings` | info | 13건 | 0건 |
| `no_adjacent_strings_in_list` | info | 9건 | 0건 |
| `no_self_assignments` | info | 0건 | 해당 없음 |
| `only_throw_errors` | info | 4건 | 0건 |
| `parameter_assignments` | info | 0건 | 해당 없음 |
| `switch_on_type` | info | 0건 | 해당 없음 |
| `test_types_in_equals` | info | 0건 | 해당 없음 |
| `throw_in_finally` | info | 0건 | 해당 없음 |
| `unnecessary_statements` | info | 0건 | 해당 없음 |
| `no_dynamic_casts` | info | 0건 | 해당 없음 |
| `no_raw_types` | info | 0건 | 해당 없음 |
| `avoid_slow_async_io` | info | 0건 | 해당 없음 |
| `no_runtimetype_tostring` | info | 1건 | 0건 |
| `noop_primitive_operations` | info | 0건 | 해당 없음 |
| `prefer_const_declarations` | info | 5건 | 5건 |
| `sized_box_shrink_expand` | info | 0건 | 해당 없음 |
| `use_colored_box` | info | 0건 | 해당 없음 |
| `use_string_buffers` | info | 0건 | 해당 없음 |
| `use_truncating_division` | info | 0건 | 해당 없음 |
| `avoid_bool_literals_in_conditional_expressions` | info | 1건 | 1건 |
| `avoid_escaping_inner_quotes` | info | 1건 | 1건 |
| `avoid_final_parameters` | info | 0건 | 해당 없음 |
| `avoid_multiple_declarations_per_line` | info | 0건 | 해당 없음 |
| `avoid_redundant_argument_values` | info | 124건 | 124건 |
| `avoid_setters_without_getters` | info | 0건 | 해당 없음 |
| `combinators_ordering` | info | 0건 | 해당 없음 |
| `directives_ordering` | info | 166건 | 166건 |
| `document_ignores` | info | 48건 | 0건 |
| `flutter_style_todos` | info | 0건 | 해당 없음 |
| `join_return_with_assignment` | info | 1건 | 0건 |
| `leading_newlines_in_multiline_strings` | info | 0건 | 해당 없음 |
| `no_literal_bool_comparisons` | info | 0건 | 해당 없음 |
| `omit_obvious_local_variable_types` | info | 236건 | 236건 |
| `prefer_asserts_in_initializer_lists` | info | 0건 | 해당 없음 |
| `prefer_constructors_over_static_methods` | info | 1건 | 0건 |
| `prefer_final_in_for_each` | info | 0건 | 해당 없음 |
| `prefer_if_elements_to_conditional_expressions` | info | 3건 | 1건 |
| `prefer_int_literals` | info | 17건 | 17건 |
| `prefer_null_aware_method_calls` | info | 0건 | 해당 없음 |
| `simple_directive_paths` | info | 0건 | 해당 없음 |
| `simplify_variable_pattern` | info | 0건 | 해당 없음 |
| `sort_constructors_first` | info | 0건 | 해당 없음 |
| `sort_pub_dependencies` | info | 2건 | 재지 않음 |
| `sort_unnamed_constructors_first` | info | 0건 | 해당 없음 |
| `specify_nonobvious_property_types` | info | 0건 | 해당 없음 |
| `tighten_type_of_initializing_formals` | info | 0건 | 해당 없음 |
| `type_annotate_public_apis` | info | 0건 | 해당 없음 |
| `unnecessary_breaks` | info | 0건 | 해당 없음 |
| `unnecessary_lambdas` | info | 197건 | 197건 |
| `unnecessary_library_directive` | info | 0건 | 해당 없음 |
| `unnecessary_null_aware_operator_on_extension_on_nullable` | info | 0건 | 해당 없음 |
| `unnecessary_null_checks` | info | 1건 | 1건 |
| `unnecessary_parenthesis` | info | 1건 | 1건 |
| `unnecessary_raw_strings` | info | 33건 | 33건 |
| `use_enums` | info | 0건 | 해당 없음 |
| `use_is_even_rather_than_modulo` | info | 0건 | 해당 없음 |
| `use_named_constants` | info | 0건 | 해당 없음 |
| `use_raw_strings` | info | 9건 | 9건 |
| `use_setters_to_change_properties` | info | 3건 | 0건 |

실측: flutter_starter_kit (Dart 파일 474개), Flutter 3.47.5, 2026-10-13

자리별 건수(lib · test · bin · pubspec)와 회차는 RULES.md 의 실측 기록에 있다.

`sort_pub_dependencies` 의 2건은 Dart 파일이 아니라 `pubspec.yaml` 에 보고되는 줄이다 (의존성 두 곳의 순서) — `dart fix` 는 재지 않았다. 손으로 고치는 2곳이다.

## 1.3.0

- riverpod_lint 를 최상위 `plugins:` (analysis_server_plugin) 방식으로 전환.
  - 옛 `analyzer: plugins: - riverpod_lint` 선언은 riverpod_lint 3.x 에서 아무것도 로드하지 않아 규칙이 실행된 적이 없었다 → 이번 버전부터 riverpod_lint 규칙이 처음으로 켜진다.
  - Dart 3.13 (Flutter 3.47) 의 `included_file_warning` (legacy plugin deprecated) 해소.
- `flutter_lints` 를 `dev_dependencies` → `dependencies` 로 이동. `include: package:flutter_lints/flutter.yaml` 이 사용하는 프로젝트의 직접 의존 여부와 무관하게 해석된다.
- 저장소 자체 분석용 루트 `analysis_options.yaml` 추가 — `lib/analysis_options.yaml` 의 `plugins:` 가 이 저장소 안에서는 inner 옵션으로 취급되어 나는 `plugins_in_inner_options` 경고를 제외한다. 사용하는 프로젝트에는 영향 없음.

## 1.2.5

2026-03-23, 커밋 `dbcd20b` (tag 없음)

- `formatter:` / `trailing_commas: preserve` 두 줄, `require_trailing_commas`, `public_member_api_docs` 를 주석 처리. 줄은 지우지 않고 남겼다 (지운 것은 2.0.0).

## 1.2.4

2026-02-27, 커밋 `212365d` (tag 없음)

- `public_member_api_docs` 규칙 추가 (당시 patch 로 냄 — `VERSIONING.md` 의 실제 사례 참고).
- `analyzer:` 블록 신설.
  - 옛 방식 `analyzer: plugins:` 로 `riverpod_lint` 선언 추가 — 1.3.0 항목 참고, 이 방식은 riverpod_lint 3.x 를 로드하지 않았다.
  - `errors: invalid_annotation_target: ignore`.
  - `exclude:` 에 `'**/*.freezed.dart'` · `'**/*.g.dart'`.
- 템플릿에서 온 주석 처리된 `# analyzer:` 예시 세 줄을 지움.
- 저장소 안쪽: FVM 설정 `.fvmrc` (Flutter 3.38.9) · `.vscode/settings.json` 과 `.gitignore` 의 `.fvm/` 추가 (`a97fd20`, 2026-01-30), 이 버전 커밋에서 `.fvmrc` 를 3.38.9 → 3.41.2 로, `.vscode/settings.json` 의 SDK 경로를 `.fvm/versions/3.41.2` 로. 사용하는 프로젝트에는 영향 없음.

## 1.2.3

2026-01-28, 커밋 `9451f6b` (tag 없음)

- `slash_for_doc_comments` 규칙 추가 (가독성 및 스타일, 당시 patch 로 냄 — `VERSIONING.md` 의 실제 사례 참고). README 의 규칙 목록에도 한 줄.
- 저장소 안쪽: `.gitignore` 에 `.DS_Store` 추가 (`1693a97`, 같은 날). 사용하는 프로젝트에는 영향 없음.

## 1.2.2

2026-01-03, 커밋 `31c8cb1` (tag 없음)

- 설정 변경 없음 — 버전 숫자만 바뀌었다. 같은 날 README 수정 (`7b7455e` — 의존성 블록을 따로 보이고 설치 순서 문구를 고침).

## 1.2.1

2025-12-30, 커밋 `21c5689` (tag 없음)

- 설정 변경 없음 — 버전 숫자만 바뀌었다. 같은 날 README 수정 (`9950fd1` — 설치 확인 방법 추가, 포맷터 절을 규칙 목록의 한 항목으로).

## 1.2.0

2025-12-24, 커밋 `ec66e3f` (tag 없음)

- `formatter:` / `trailing_commas: preserve` 두 줄 추가 (`include:` 와 `linter:` 사이). README 에 포맷터 절 추가.

## 1.1.0

2025-12-22, 커밋 `2249a0b` (tag 없음) — 내용은 `126aa43`, 같은 날

- 기반 세트를 `package:lints/recommended.yaml` 에서 `package:flutter_lints/flutter.yaml` 로 바꿈.
- `dev_dependencies` 의 `lints: ^6.0.0` 을 `flutter_lints: ^6.0.0` 으로 바꿈 (1.3.0 이 `dependencies` 로 옮겼다).
- 같은 날 README 에 `flutter pub upgrade woody_lints` 안내 추가 (`9bf0d86`).

## 1.0.0

- Initial version.
