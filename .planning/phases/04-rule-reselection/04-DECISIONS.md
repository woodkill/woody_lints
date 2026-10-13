# Phase 4 — 규칙별 채택 결정 (로드맵 D13)

**실측 조건:** 회차 `R1` (2026-10-13), Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, 기반 세트 `lints` 6.1.0 · `flutter_lints` 6.0.0 (저장소 · 복사본 모두), `flutter_starter_kit` 복사본의 Dart 파일 474개 (lib 172 · test 239 · bin 1 · 생성 파일 62), 복사본의 SDK 제약 `^3.11.1` (언어 버전 3.11). 회차 50개 모두 유효 (04-04).

**수치의 출처:** `tool/measurements/2026-10-13-R1.json` 하나. 묶음마다의 표는 `fvm dart run tool/measure_rules.dart --summary <묶음 id> --in tool/measurements/2026-10-13-R1.json` 의 출력을 손대지 않고 옮긴 것이다. spike 020 ~ 023 의 수치는 쓰지 않았다 (D-14).

## 읽는 법

### 표의 칸

- **경고 (lib·test·bin):** 그 규칙을 켰을 때 사용 프로젝트가 받는 줄 수. 프로젝트에 이미 있는 무시 주석(`// ignore` 등)은 **둔 채로** 쟀다 — 채택하면 실제로 받는 줄이다. 괄호 안은 `lib` · `test` · `bin` 으로 나눈 수.
- **`0 (표식 1)`:** 프로젝트에서는 0줄이고, 일부러 넣은 위반(표식)에서는 1줄이 나왔다 — 규칙은 돌았고 프로젝트가 이미 그 규칙을 지킨다는 뜻이다.
- **`0 (표식 미검출)`:** 표식에서도 나오지 않았다 — 규칙이 돌지 않았다. **`0 (표식 불가)`:** Dart 파일 하나로는 어길 수 없는 규칙이라 표식을 넣지 못했다. 둘 다 0줄의 뜻을 가를 수 없어 `결정 안 함` 이다 (RULES-05).
- **dart fix:** 규칙 하나씩 `dart fix --apply --code=<규칙>` 한 뒤 다시 분석해 **사라진 그 규칙의 줄 수**. `0 (dry 0)` 은 고칠 것이 없다고 나와 apply 하지 않은 것. `해당 없음` 은 0줄이라 고칠 것이 없는 것.
- **고친 뒤 error:** 같은 apply 뒤 새로 생긴 다른 진단 가운데 error 의 수. 0 이 아니면 "dart fix 가 코드를 깨뜨린다" 로 본다.
- **손으로 고칠 줄:** 경고 − dart fix 로 사라진 줄. 성능 · 가독성·스타일의 잣대 **50 은 추정으로 잡은 값**이다 (D-05).
- 각 묶음의 `text` 블록 끝에 찍힌 `**권고:**` 줄은 도구가 낸 것이고 `검토` 행을 세지 않는다. 그 묶음의 권고는 블록 아래 Claude 가 채운 표와 그 밑의 굵은 `**권고:**` 줄이다.

### 묻는 방식 (D-04)

- **묶음 1 ~ 5** 는 묶음마다 한 번 답한다 — `(1) 권고대로` 면 표의 `권고` 열이 그대로 결정이 되고, `(2)` 는 바꿀 규칙의 이름과 켬 / 안 켬 만 적으면 나머지는 권고대로다. `(3)` 은 그 묶음을 보류한다 (보류한 묶음은 반영되지 않고 다시 묻는다).
- **질문 1 ~ 9** 는 하나씩 묻는다 — strict 계열 셋, import 스타일, fire-and-forget, 함께 쓸 수 없는 쌍, 상태 출처가 갈리는 규칙. 질문 8 (v2 로 미룬 12개) 은 숫자만 보이고, 질문 9 (`unnecessary_ignore`) 는 보류를 알리기만 한다.
- **도구가 이미 판정한 행** — `v2` · `결정 안 함 (표식 …)` · `안 켬 (dart fix 가 error …)` · `안 켬 (비호환 …)` · `켬 (손으로 고칠 줄 …)` — 은 도구의 판정이 권고다. Claude 는 그 행에 덧붙일 것만 적었다.
- 결정은 맨 아래 결정 표의 `결정` · `사유` 칸에 소유자의 응답으로만 적는다. 초안(`0362628`)에서 그 칸이 채워진 행은 결정이 아니라 도구 판정의 결과(`v2` · `결정 안 함`)와 이 plan 이 정한 보류(`unnecessary_ignore`)뿐이었다 — `켬` / `안 켬` 은 2026-10-13 의 응답으로 채웠다.

### 권고의 잣대 (D-05)

- **공통으로 안 켬:** `messages.yaml` 기준 experimental / testing, `base.yaml` 에 켜진 규칙과 함께 쓸 수 없음, `dart fix` 가 error 를 남김, v2 로 미룸.
- **버그 방지 · strict:** 경고가 실제 문제를 가리키면 건수와 상관없이 켬, 오탐이 많으면 안 켬.
- **성능 · 가독성·스타일:** `dart fix` 가 거의 다 고치거나 손으로 고칠 줄이 50 이하(추정 값)이면 켬.
- **지금 켜 둔 규칙:** 남길지와 사유 문구 (D-18).

### 권고의 합계 (후보 133개)

| 묶음 | 행 | 켬 권고 | 안 켬 권고 | 결정 안 함 | 그 밖 |
|---|---|---|---|---|---|
| 1 버그 방지 (`bug`) | 25 | 23 | 2 | 0 | |
| 2 성능 (`perf`) | 8 | 8 | 0 | 0 | |
| 3 가독성·스타일 (`style`) | 41 | 39 | 0 | 2 | |
| 4 지금 켜 둔 5개 (`current`) | 5 | 5 | 0 | 0 | |
| 5 제외 권장 (`excluded`) | 31 | 0 | 28 | 3 | |
| 질문 1 ~ 3 strict (`strict`) | 3 | 2 | 1 | 0 | |
| 질문 4 import (`import`) | 2 | 1 | 1 | 0 | |
| 질문 5 fire-and-forget (`fire`) | 3 | 2 | 1 | 0 | |
| 질문 6 함께 쓸 수 없는 쌍 (`pairs`) | 2 | 0 | 2 | 0 | |
| 질문 7 상태 출처 (`status`) | 0 | — | — | — | 후보 행 없음 (질문 7 참조) |
| 질문 8 v2 (`v2`) | 12 | — | — | — | 결정 안 함 (v2) 12 |
| 질문 9 (`ui`) | 1 | — | — | — | 보류 1 |
| **합계** | **133** | **80** | **35** | **5** | **13** |

결정 대상은 133 − v2 12 = 121개다. 그 가운데 `unnecessary_ignore` 는 보류(04-08)이고, 0줄의 뜻을 가를 수 없는 5개(표식 불가 4 · 표식 미검출 1)는 도구 판정으로 `결정 안 함` 이다 — 이번 두 checkpoint 에서 켬 / 안 켬 을 받을 행은 115개다.

## 묶음 1 — 버그 방지 (`bug`, 25개)

### 용어 풀이

- **버그 방지 규칙:** 스타일이 아니라 실행 중 오류 · 놓친 예외 · 오타를 가리키는 규칙. 이 묶음의 잣대는 건수가 아니라 "걸린 줄이 실제 문제를 가리키는가" 다.
- **Future 를 await 없이 돌려준다:** `async` 함수가 다른 Future 를 기다리지 않고 그대로 넘기면, 그 Future 가 실패해도 이 함수 안의 `try` / `catch` 가 잡지 못한다.
- **mock · fake:** 테스트에서 진짜 객체 대신 쓰는 가짜 객체. 값 객체를 `implements` 로 흉내 내는 일이 흔하다.

### 찾아본 것

- 규칙마다 "무엇을 잡는가" 와 7개 커뮤니티 세트의 채택 수 — `.planning/research/FEATURES.md` § B-1
- `avoid_implementing_value_types` 를 very_good_analysis 가 테스트 mock / fake 때문에 뺀다 — FEATURES.md § B-1 의 같은 행
- `switch_on_type` 은 미출시 `lints` 7 의 core 에 들어갈 예정이다 — FEATURES.md § B-1 아래 문단. 들어오면 검증 명령의 겹침 검사(`[3/10]`)가 이 패키지의 선언을 잡는다 (D-11)
- `import` 스타일 쌍 둘은 이 묶음에서 빼고 질문 4 에서 묻는다

### 실측 (`--summary bug`)

```text
[버그 방지] 25개 — 권고: 켬 0 · 안 켬 0 · 검토 25 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙                                          | 경고 (lib·test·bin) | dart fix  | 고친 뒤 error | 권고 | 이유                                 |
|-----------------------------------------------|---------------------|-----------|---------------|------|--------------------------------------|
| async_return_with_no_await                    | 30 (16·14·0)        | 0 (dry 0) | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_void_async                              | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| cancel_subscriptions                          | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_dynamic_calls                           | 28 (0·28·0)         | 0 (dry 0) | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| cast_nullable_to_non_nullable                 | 5 (0·5·0)           | 5         | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_type_to_string                          | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| switch_on_type                                | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| test_types_in_equals                          | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| throw_in_finally                              | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| no_self_assignments                           | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| no_adjacent_strings_in_list                   | 9 (0·9·0)           | 0 (dry 0) | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| missing_whitespace_between_adjacent_strings   | 13 (0·13·0)         | 0 (dry 0) | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| unnecessary_statements                        | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| literal_only_boolean_expressions              | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_unused_constructor_parameters           | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| parameter_assignments                         | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_catching_errors                         | 3 (2·1·0)           | 0 (dry 0) | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| only_throw_errors                             | 4 (0·4·0)           | 0 (dry 0) | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| conditional_uri_does_not_exist                | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| deprecated_member_use_from_same_package       | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| matching_super_parameters                     | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_equals_and_hash_code_on_mutable_classes | 8 (8·0·0)           | 0 (dry 0) | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_implementing_value_types                | 25 (0·25·0)         | 0 (dry 0) | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_double_and_int_checks                   | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_js_rounded_ints                         | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |

**권고:** 표의 권고 열대로 — 켬 0개, 안 켬 0개 (검토 25개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

### 권고와 이유

| 규칙 | 경고 (lib·test·bin) | dart fix | 권고 | 이유 |
|---|---|---|---|---|
| `async_return_with_no_await` | 30 (16·14·0) | 0 (dry 0) | 켬 | await 없이 넘긴 Future 는 이 함수의 try/catch 를 지나 예외가 밖에서 난다 — 30줄 손으로 (dart fix 0) |
| `avoid_void_async` | 0 (표식 1) | 해당 없음 | 켬 | `void` 를 돌려주는 async 는 호출한 쪽이 기다리거나 오류를 받을 수 없다 — 0줄 |
| `cancel_subscriptions` | 0 (표식 1) | 해당 없음 | 켬 | 닫지 않은 `StreamSubscription` 은 메모리 누수 — 0줄 |
| `avoid_dynamic_calls` | 28 (0·28·0) | 0 (dry 0) | 켬 | dynamic 위의 호출은 타입 오류를 실행 때까지 숨긴다 — 28줄 모두 test, lib 0 |
| `cast_nullable_to_non_nullable` | 5 (0·5·0) | 5 | 켬 | null 일 수 있는 값을 `as` 로 단정하면 실행 중 오류 — 5줄 모두 dart fix |
| `avoid_type_to_string` | 0 (표식 1) | 해당 없음 | 켬 | release 빌드에서 타입 이름이 바뀔 수 있다 — 0줄 |
| `switch_on_type` | 0 (표식 1) | 해당 없음 | 켬 | `runtimeType` 으로 가르면 하위 타입을 놓친다 — 0줄 (lints 7 의 core 에 들어갈 예정 — 그때 겹침 검사가 잡는다) |
| `test_types_in_equals` | 0 (표식 1) | 해당 없음 | 켬 | `==` 에서 인자 타입을 보지 않으면 cast 오류 — 0줄 |
| `throw_in_finally` | 0 (표식 1) | 해당 없음 | 켬 | `finally` 의 throw 는 원래 예외를 덮는다 — 0줄 |
| `no_self_assignments` | 0 (표식 1) | 해당 없음 | 켬 | `x = x` 는 거의 늘 오타 — 0줄 |
| `no_adjacent_strings_in_list` | 9 (0·9·0) | 0 (dry 0) | 켬 | 리스트 안의 붙은 문자열은 쉼표 누락일 때가 많다 — 9줄 모두 test, 손으로 |
| `missing_whitespace_between_adjacent_strings` | 13 (0·13·0) | 0 (dry 0) | 켬 | 이어 붙인 문자열 사이의 공백 누락으로 문장이 붙는다 — 13줄 모두 test, 손으로 |
| `unnecessary_statements` | 0 (표식 1) | 해당 없음 | 켬 | 효과 없는 문장은 빠진 호출 · 대입의 흔적 — 0줄 |
| `literal_only_boolean_expressions` | 0 (표식 1) | 해당 없음 | 켬 | 늘 참/거짓인 조건은 남은 디버그 코드 — 0줄 |
| `avoid_unused_constructor_parameters` | 0 (표식 1) | 해당 없음 | 켬 | 쓰지 않는 생성자 매개변수는 빠뜨린 대입 — 0줄 |
| `parameter_assignments` | 0 (표식 1) | 해당 없음 | 켬 | 매개변수를 다시 쓰면 원래 값을 잃는다 — 0줄 |
| `avoid_catching_errors` | 3 (2·1·0) | 0 (dry 0) | 켬 | `Error` 를 잡으면 프로그램 버그가 숨는다 — 3줄 손으로 |
| `only_throw_errors` | 4 (0·4·0) | 0 (dry 0) | 켬 | `Exception` / `Error` 가 아닌 값을 던지면 잡는 쪽이 스택을 잃는다 — 4줄 모두 test |
| `conditional_uri_does_not_exist` | 0 (표식 1) | 해당 없음 | 켬 | 조건부 import 가 없는 파일을 가리키면 다른 플랫폼에서 빌드가 깨진다 — 0줄 |
| `deprecated_member_use_from_same_package` | 0 (표식 1) | 해당 없음 | 켬 | 같은 패키지 안의 deprecated 사용을 잡는다 — 0줄 |
| `matching_super_parameters` | 0 (표식 1) | 해당 없음 | 켬 | super 매개변수의 순서 착오 — 0줄 |
| `avoid_equals_and_hash_code_on_mutable_classes` | 8 (8·0·0) | 0 (dry 0) | 안 켬 | `@immutable` 표시가 없을 뿐인 클래스도 걸린다 — 8줄 모두 lib, dart fix 0, 채택 2/7 |
| `avoid_implementing_value_types` | 25 (0·25·0) | 0 (dry 0) | 안 켬 | test 의 mock · fake 가 걸리는 규칙 — 25줄 모두 test (very_good_analysis 가 같은 이유로 뺀다) |
| `avoid_double_and_int_checks` | 0 (표식 1) | 해당 없음 | 켬 | web 에서 뜻이 달라지는 검사 — 0줄, web 빌드를 할 때를 대비 |
| `avoid_js_rounded_ints` | 0 (표식 1) | 해당 없음 | 켬 | web 에서 정밀도가 깨지는 정수 — 0줄 |

**권고:** 켬 23개 · 안 켬 2개 (`avoid_equals_and_hash_code_on_mutable_classes`, `avoid_implementing_value_types`) — 표의 권고 열대로.

선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름과 켬 / 안 켬)  (3) 이 묶음은 보류

## 묶음 2 — 성능 (`perf`, 8개)

### 용어 풀이

- **손으로 고칠 줄:** 경고 줄에서 `dart fix` 가 지운 줄을 뺀 수. 이 묶음과 묶음 3 의 잣대는 이 값이 50 이하(추정)인가다.

### 찾아본 것

- 규칙마다 잡는 것 — FEATURES.md § B-2
- `prefer_const_declarations` 는 `flutter_lints` 5.0.0 이 `prefer_const_constructors` · `prefer_const_literals_to_create_immutables` 와 함께 기반 세트에서 뺀 셋 중 하나다 (FEATURES.md § B-2 아래 문단 · § C, dart-lang/lints#205) — 켜는 이유는 "성능" 이 아니라 "바뀌지 않는 값을 `const` 로 적는 관례" 로 적는 것이 사실에 맞다

### 실측 (`--summary perf`)

```text
[성능] 8개 — 권고: 켬 8 · 안 켬 0 · 검토 0 · 결정 안 함 0 (50 은 추정)        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙                      | 경고 (lib·test·bin) | dart fix  | 고친 뒤 error | 권고 | 이유                    |
|---------------------------|---------------------|-----------|---------------|------|-------------------------|
| prefer_const_declarations | 5 (2·3·0)           | 5         | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| use_colored_box           | 0 (표식 1)          | 해당 없음 | —             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| sized_box_shrink_expand   | 0 (표식 1)          | 해당 없음 | —             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| use_string_buffers        | 0 (표식 1)          | 해당 없음 | —             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| no_runtimetype_tostring   | 1 (1·0·0)           | 0 (dry 0) | 0             | 켬   | 손으로 고칠 줄 1 (≤ 50) |
| avoid_slow_async_io       | 0 (표식 1)          | 해당 없음 | —             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| noop_primitive_operations | 0 (표식 1)          | 해당 없음 | —             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| use_truncating_division   | 0 (표식 1)          | 해당 없음 | —             | 켬   | 손으로 고칠 줄 0 (≤ 50) |

**권고:** 표의 권고 열대로 — 켬 8개, 안 켬 0개 (검토 0개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

### 권고와 이유

8개 모두 도구가 `켬 (손으로 고칠 줄 …)` 으로 판정했다. 덧붙일 것:

| 규칙 | 덧붙임 |
|---|---|
| `prefer_const_declarations` | 5줄 모두 dart fix. 사유 주석은 성능이 아니라 관례로 적는다 (위의 lints#205) |
| `no_runtimetype_tostring` | 손으로 고칠 1줄 (dart fix 0) |
| 나머지 6개 | 0줄 (표식 1) — 프로젝트가 이미 지킨다 |

**권고:** 켬 8개 · 안 켬 0개 — 표의 권고 열대로.

선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름과 켬 / 안 켬)  (3) 이 묶음은 보류

## 묶음 3 — 가독성·스타일 (`style`, 41개)

### 용어 풀이

- **표식 불가:** 이 규칙은 Dart 파일이 아닌 곳(`pubspec.yaml`)을 보거나 테스트 패키지를 import 한 파일에서만 걸려, 일부러 넣는 위반으로 "규칙이 돌았다" 를 보일 수 없다. 0줄의 뜻을 가를 수 없어 결정하지 않는다.
- 행이 25개를 넘어 도구가 `dart fix 가 다 고치는 것` / `손으로 고칠 줄 50 이하` / `그 밖` 셋으로 나눠 찍었다 (D-06).

### 찾아본 것

- 규칙마다 잡는 것과 채택 수 — FEATURES.md § B-3 ("건수보다 이 스타일을 원하는가가 판단 기준")
- `simple_directive_paths` · `simplify_variable_pattern` · `unnecessary_unawaited` 는 미출시 `lints` 7 의 recommended 에 들어갈 예정이다 — FEATURES.md § B-1 아래 문단
- `avoid_final_parameters` 는 언어 버전 3.13 에서 꺼진다 (04-03 SUMMARY — 그 언어 버전에서는 보통 매개변수의 `final` 이 error)
- 함께 쓸 수 없는 짝 — `tool/measurements/2026-10-13-R1.json` 의 `conditions.incompatiblePairs` (10쌍 모두 쌍마다 둘만 켜서 확인)

### 실측 (`--summary style`)

```text
[가독성·스타일] 41개 — 권고: 켬 39 · 안 켬 0 · 검토 0 · 결정 안 함 2 (50 은 추정)        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

#### dart fix 가 다 고치는 것 (11개)

| 규칙                                           | 경고 (lib·test·bin) | dart fix | 고친 뒤 error | 권고 | 이유                    |
|------------------------------------------------|---------------------|----------|---------------|------|-------------------------|
| directives_ordering                            | 166 (3·163·0)       | 166      | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| avoid_redundant_argument_values                | 124 (9·103·12)      | 124      | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| unnecessary_lambdas                            | 197 (0·197·0)       | 197      | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| unnecessary_parenthesis                        | 1 (0·1·0)           | 1        | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| unnecessary_null_checks                        | 1 (0·1·0)           | 1        | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| unnecessary_raw_strings                        | 33 (0·33·0)         | 33       | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| use_raw_strings                                | 9 (0·9·0)           | 9        | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| avoid_bool_literals_in_conditional_expressions | 1 (1·0·0)           | 1        | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| prefer_int_literals                            | 17 (5·12·0)         | 17       | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| avoid_escaping_inner_quotes                    | 1 (0·1·0)           | 1        | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |
| omit_obvious_local_variable_types              | 236 (1·235·0)       | 236      | 0             | 켬   | 손으로 고칠 줄 0 (≤ 50) |

#### 손으로 고칠 줄 50 이하 (30개)

| 규칙                                                     | 경고 (lib·test·bin) | dart fix  | 고친 뒤 error | 권고       | 이유                                                                                                              |
|----------------------------------------------------------|---------------------|-----------|---------------|------------|-------------------------------------------------------------------------------------------------------------------|
| prefer_final_in_for_each                                 | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| avoid_final_parameters                                   | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| type_annotate_public_apis                                | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| combinators_ordering                                     | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| unnecessary_breaks                                       | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| unnecessary_null_aware_operator_on_extension_on_nullable | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| unnecessary_library_directive                            | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| document_ignores                                         | 48 (1·46·1)         | 0 (dry 0) | 0             | 켬         | 손으로 고칠 줄 48 (≤ 50)                                                                                          |
| no_literal_bool_comparisons                              | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| prefer_if_elements_to_conditional_expressions            | 3 (3·0·0)           | 1         | 0             | 켬         | 손으로 고칠 줄 2 (≤ 50)                                                                                           |
| prefer_null_aware_method_calls                           | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| avoid_multiple_declarations_per_line                     | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| leading_newlines_in_multiline_strings                    | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| use_enums                                                | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| use_named_constants                                      | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| use_is_even_rather_than_modulo                           | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| tighten_type_of_initializing_formals                     | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| join_return_with_assignment                              | 1 (1·0·0)           | 0 (dry 0) | 0             | 켬         | 손으로 고칠 줄 1 (≤ 50)                                                                                           |
| prefer_asserts_in_initializer_lists                      | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| prefer_constructors_over_static_methods                  | 1 (1·0·0)           | 0 (dry 0) | 0             | 켬         | 손으로 고칠 줄 1 (≤ 50)                                                                                           |
| sort_unnamed_constructors_first                          | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| sort_constructors_first                                  | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| sort_pub_dependencies                                    | 0 (표식 불가)       | 해당 없음 | —             | 결정 안 함 | 표식 불가 — pubspec.yaml 을 본다 — Dart 파일로는 어길 수 없다                                                     |
| avoid_setters_without_getters                            | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| use_setters_to_change_properties                         | 3 (0·3·0)           | 0 (dry 0) | 0             | 켬         | 손으로 고칠 줄 3 (≤ 50)                                                                                           |
| use_test_throws_matchers                                 | 0 (표식 불가)       | 해당 없음 | —             | 결정 안 함 | 표식 불가 — package:test_api 의 fail() 을 찾는다 — flutter_test 를 import 하지 않는 lib/ 의 파일로는 어길 수 없다 |
| simple_directive_paths                                   | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| simplify_variable_pattern                                | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| specify_nonobvious_property_types                        | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |
| flutter_style_todos                                      | 0 (표식 1)          | 해당 없음 | —             | 켬         | 손으로 고칠 줄 0 (≤ 50)                                                                                           |

#### 그 밖 (0개)

(없음)

**권고:** 표의 권고 열대로 — 켬 39개, 안 켬 0개 (검토 0개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

### 권고와 이유

39개는 도구가 `켬 (손으로 고칠 줄 …)` 으로, 2개(`sort_pub_dependencies`, `use_test_throws_matchers`)는 `결정 안 함 (표식 불가)` 로 판정했다. 다르게 볼 근거는 찾지 못했고, 덧붙일 것:

| 규칙 | 덧붙임 |
|---|---|
| `document_ignores` | 손으로 고칠 줄 48 — 잣대(50, 추정)에 가깝다. `unnecessary_ignore` 의 apply 가 이 규칙의 줄을 7줄 줄였다 (R1 의 `otherDelta`) — 04-08 의 재측정 뒤 수가 바뀔 수 있다 |
| `type_annotate_public_apis` | 묶음 5 의 `omit_obvious_property_types` 와 함께 쓸 수 없다 — 그쪽은 안 켬 권고 |
| `omit_obvious_local_variable_types` | 묶음 5 의 `always_specify_types` 와 함께 쓸 수 없다 — 그쪽은 도구가 안 켬 |
| `prefer_final_in_for_each` | 질문 6 의 `unnecessary_final` 과 함께 쓸 수 없다 — 그쪽은 안 켬 권고 |
| `avoid_escaping_inner_quotes` | 지금 켜 둔 `prefer_single_quotes` 의 보완 규칙 (1줄, dart fix) |
| `avoid_final_parameters` | 사용 프로젝트가 언어 버전을 3.13 으로 올리면 이 규칙은 돌지 않는다 |
| `simple_directive_paths`, `simplify_variable_pattern` | `lints` 7 에서 기반 세트에 들어오면 겹침 검사(`[3/10]`)가 잡는다 — 그때 이 패키지의 선언을 지운다 |
| `unnecessary_lambdas` | 197줄 모두 dart fix, 고친 뒤 error 0 (lint 패키지는 `setState` 쪽 문제로 꺼 두지만 이 회차에서는 error 가 생기지 않았다) |
| `sort_constructors_first` | lint 패키지는 "too opinionated" 로 꺼 둔다 — 이 프로젝트는 0줄 (표식 1) |

**권고:** 켬 39개 · 안 켬 0개 · 결정 안 함 2개 (표식 불가) — 표의 권고 열대로.

선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름과 켬 / 안 켬)  (3) 이 묶음은 보류

## 묶음 4 — 지금 켜 둔 5개 (`current`)

### 용어 풀이

- **지금 켜 둔 규칙:** `lib/base.yaml` 이 기반 세트 위에 더 켜는 이 패키지만의 규칙. 원래 6개이고 `unawaited_futures` 는 질문 5 에서 함께 묻는다. 남기더라도 `lib/base.yaml` 의 사유 주석은 사실에 맞게 고친다 (D-18, RULES-07).

### 찾아본 것

- `prefer_const_constructors` · `prefer_const_literals_to_create_immutables` 의 지금 사유("위젯 재사용을 극대화하여 성능 향상")는 Flutter 팀이 근거가 부족하다고 본 주장이다 — `flutter_lints` 5.0.0 이 두 규칙을 기반 세트에서 뺐고, 근거 issue 는 dart-lang/lints#205 (https://github.com/dart-lang/lints/issues/205, FEATURES.md § C "const 규칙의 근거")
- `always_declare_return_types` 가 기반 세트의 `strict_top_level_inference` 에 더하는 범위는 지역 함수와 옛 문법 typedef 뿐이다 — 흔한 자리(top-level 함수 · 메서드)에서는 둘이 같은 자리에 진단을 하나씩 낸다 (FEATURES.md § C 의 비교표)
- `prefer_final_locals` 는 `fixtures/overrides` 가 "사용 프로젝트가 규칙 하나를 끈다" 를 시연하는 규칙이다 (04-RESEARCH.md Pitfall 3) — **빼면** 끄는 규칙을 남는 규칙 하나로 바꾸고, 같은 커밋에서 그 fixture 의 옵션 파일 · `tool/verify.dart` 의 `optionsLines` · README 를 함께 바꿔야 한다

### 실측 (`--summary current`)

```text
[지금 켜 둔 5개] 5개 — 권고: 켬 0 · 안 켬 0 · 검토 5 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙                                       | 경고 (lib·test·bin) | dart fix  | 고친 뒤 error | 권고 | 이유                                 |
|--------------------------------------------|---------------------|-----------|---------------|------|--------------------------------------|
| prefer_const_constructors                  | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| prefer_const_literals_to_create_immutables | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| always_declare_return_types                | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| prefer_final_locals                        | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| prefer_single_quotes                       | 0 (표식 1)          | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |

**권고:** 표의 권고 열대로 — 켬 0개, 안 켬 0개 (검토 5개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

### 권고와 이유

| 규칙 | 경고 (lib·test·bin) | dart fix | 권고 | 이유 |
|---|---|---|---|---|
| `prefer_const_constructors` | 0 (표식 1) | 해당 없음 | 켬 | 남긴다 — 0줄 (사유 문구는 "불변 위젯 트리를 const 로 적는 관례" 로 고친다, D-18) |
| `prefer_const_literals_to_create_immutables` | 0 (표식 1) | 해당 없음 | 켬 | 남긴다 — 0줄 (사유 문구는 위와 같이 고친다, D-18) |
| `always_declare_return_types` | 0 (표식 1) | 해당 없음 | 켬 | 남긴다 — 0줄 (사유 문구는 "기반 세트의 strict_top_level_inference 가 보지 않는 지역 함수 · 옛 typedef" 로, D-18) |
| `prefer_final_locals` | 0 (표식 1) | 해당 없음 | 켬 | 남긴다 — 0줄, `fixtures/overrides` 의 끄기 시연이 이 규칙을 쓴다 (Pitfall 3) |
| `prefer_single_quotes` | 0 (표식 1) | 해당 없음 | 켬 | 남긴다 — 0줄 (프로젝트가 이미 따른다) |

**사유 문구 수정 제안 (D-18 — 남길 때):**

| 규칙 | 지금 사유 | 고칠 사유 (제안) |
|---|---|---|
| `prefer_const_constructors` | 위젯 재사용 극대화 (성능 향상) | 불변 위젯 트리를 `const` 로 적는 관례 — 성능 이득은 근거가 부족하다는 것이 Flutter 팀의 판단 (lints#205) |
| `prefer_const_literals_to_create_immutables` | 불변 컬렉션의 효율적 관리 | 위와 같은 관례 — 불변 위젯에 넘기는 리터럴도 `const` 로 |
| `always_declare_return_types` | 반환 타입 명시 | 기반 세트의 `strict_top_level_inference` 가 보지 않는 지역 함수 · 옛 typedef 의 반환 타입까지 |
| `prefer_final_locals` | 지역 변수 불변성 | 그대로 |
| `prefer_single_quotes` | 홑따옴표 통일 | 그대로 |

**권고:** 켬 5개 (모두 남김) · 안 켬 0개, 사유 문구는 위 표대로 고친다 — 표의 권고 열대로.

선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름과 켬 / 안 켬, 사유 문구 의견)  (3) 이 묶음은 보류

## 묶음 5 — 제외 권장 (`excluded`, 31개)

### 용어 풀이

- **제외 권장:** 조사 단계(FEATURES.md § B-6)에서 "켜지 않아도 된다" 고 본 규칙. 미채택 사유에 숫자를 붙이려고 함께 쟀다 (D-01).
- **취향 규칙:** 버그와 상관없이 코드 모양을 한쪽으로 강제하는 규칙.

### 찾아본 것

- 규칙마다의 제외 사유 — FEATURES.md § B-6 (very_good_analysis · lint 패키지가 뺀 이유를 함께 적었다)
- `require_trailing_commas` 는 언어 버전 3.7 이상에서 보고하지 않는다 — FEATURES.md § C. 주석 처리된 줄은 RULES-02 로 이미 지운다
- 도구가 `안 켬` 으로 판정한 4개는 `dart fix` 가 error 를 남긴다 (`diagnostic_describe_all_properties` 148 · `always_specify_types` 6 · `omit_local_variable_types` 4 · `specify_nonobvious_local_variable_types` 4)
- `omit_obvious_property_types` ↔ `type_annotate_public_apis` 는 함께 쓸 수 없는 쌍으로 확인됐다 (R1 의 `conditions.incompatiblePairs`)

### 실측 (`--summary excluded`)

```text
[제외 권장] 31개 — 권고: 켬 0 · 안 켬 4 · 검토 24 · 결정 안 함 3        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

#### dart fix 가 다 고치는 것 (7개)

| 규칙                                       | 경고 (lib·test·bin) | dart fix | 고친 뒤 error | 권고  | 이유                                 |
|--------------------------------------------|---------------------|----------|---------------|-------|--------------------------------------|
| omit_local_variable_types                  | 891 (12·879·0)      | 891      | 4             | 안 켬 | dart fix 가 error 4건을 남긴다       |
| omit_obvious_property_types                | 716 (182·532·2)     | 716      | 0             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_types_on_closure_parameters          | 237 (2·235·0)       | 237      | 0             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |
| always_put_required_named_parameters_first | 32 (31·1·0)         | 32       | 0             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |
| avoid_annotating_with_dynamic              | 1 (0·1·0)           | 1        | 0             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |
| use_decorated_box                          | 1 (1·0·0)           | 1        | 0             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |
| diagnostic_describe_all_properties         | 123 (122·1·0)       | 123      | 148           | 안 켬 | dart fix 가 error 148건을 남긴다     |

#### 손으로 고칠 줄 50 이하 (20개)

| 규칙                                      | 경고 (lib·test·bin) | dart fix  | 고친 뒤 error | 권고       | 이유                                                                                                                                      |
|-------------------------------------------|---------------------|-----------|---------------|------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| require_trailing_commas                   | 0 (표식 불가)       | 해당 없음 | —             | 결정 안 함 | 표식 불가 — 언어 버전 3.7 이상의 라이브러리에서는 돌지 않는다 (규칙 소스의 language37 조건) — 사용 프로젝트의 하한에서 걸리는 파일이 없다 |
| eol_at_end_of_file                        | 0 (표식 1)          | 해당 없음 | —             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| specify_nonobvious_local_variable_types   | 4111 (878·3181·52)  | 4078      | 4             | 안 켬      | dart fix 가 error 4건을 남긴다                                                                                                            |
| avoid_catches_without_on_clauses          | 0 (표식 1)          | 해당 없음 | —             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| avoid_positional_boolean_parameters       | 5 (1·4·0)           | 0 (dry 0) | 0             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| avoid_classes_with_only_static_members    | 4 (4·0·0)           | 0 (dry 0) | 0             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| avoid_returning_this                      | 0 (표식 1)          | 해당 없음 | —             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| use_to_and_as_if_applicable               | 0 (표식 1)          | 해당 없음 | —             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| prefer_mixin                              | 0 (표식 1)          | 해당 없음 | —             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| prefer_asserts_with_message               | 5 (5·0·0)           | 0 (dry 0) | 0             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| avoid_field_initializers_in_const_classes | 0 (표식 1)          | 해당 없음 | —             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| prefer_foreach                            | 3 (0·3·0)           | 0 (dry 0) | 0             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| prefer_expression_function_bodies         | 128 (71·55·2)       | 121       | 0             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| close_sinks                               | 0 (표식 1)          | 해당 없음 | —             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| prefer_void_to_null                       | 0 (표식 1)          | 해당 없음 | —             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| unreachable_from_main                     | 2 (0·1·1)           | 0 (dry 0) | 0             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| do_not_use_environment                    | 17 (13·4·0)         | 0 (dry 0) | 0             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| library_names                             | 0 (표식 1)          | 해당 없음 | —             | 검토       | 실제 문제를 가리키는가 — 사람이 본다                                                                                                      |
| package_prefixed_library_names            | 0 (표식 불가)       | 해당 없음 | —             | 결정 안 함 | 표식 불가 — 규칙 소스(tag 3.13.4)의 visitLibraryDirective 가 곧바로 return 한다 — 아무것도 보고하지 않는다 (dart-lang/linter#3395)        |
| remove_deprecations_in_breaking_versions  | 0 (표식 미검출)     | 해당 없음 | —             | 결정 안 함 | 표식 미검출 — 규칙이 돌지 않음                                                                                                            |

#### 그 밖 (4개)

| 규칙                                | 경고 (lib·test·bin)  | dart fix  | 고친 뒤 error | 권고  | 이유                                 |
|-------------------------------------|----------------------|-----------|---------------|-------|--------------------------------------|
| lines_longer_than_80_chars          | 107 (35·72·0)        | 0 (dry 0) | 0             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |
| always_put_control_body_on_new_line | 398 (324·53·21)      | 0 (dry 0) | 0             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |
| always_specify_types                | 9388 (1524·7753·111) | 8917      | 6             | 안 켬 | dart fix 가 error 6건을 남긴다       |
| cascade_invocations                 | 60 (6·44·10)         | 0 (dry 0) | 0             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |

**권고:** 표의 권고 열대로 — 켬 0개, 안 켬 4개 (검토 24개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

### 권고와 이유

도구가 판정한 7개(안 켬 4 · 결정 안 함 3)는 그대로다. `검토` 24개:

| 규칙 | 경고 (lib·test·bin) | dart fix | 권고 | 이유 |
|---|---|---|---|---|
| `omit_obvious_property_types` | 716 (182·532·2) | 716 | 안 켬 | `type_annotate_public_apis` (묶음 3 켬 권고)와 함께 쓸 수 없다 — 716줄 |
| `avoid_types_on_closure_parameters` | 237 (2·235·0) | 237 | 안 켬 | 취향 규칙 — dart fix 가 237줄 모두 고치지만 closure 매개변수의 타입을 지우는 쪽으로 강제할 근거가 약하다 (채택 3/7) |
| `always_put_required_named_parameters_first` | 32 (31·1·0) | 32 | 안 켬 | Flutter 의 `super.key` 를 앞에 두는 관례와 어긋난다 — 32줄 |
| `avoid_annotating_with_dynamic` | 1 (0·1·0) | 1 | 안 켬 | `dynamic` 을 적는 것은 의도 표시이기도 하다 — 1줄, 채택 0/7 |
| `use_decorated_box` | 1 (1·0·0) | 1 | 안 켬 | 상류에 알려진 오동작이 있다 (very_good_analysis · lint 가 뺀다) — 1줄 |
| `eol_at_end_of_file` | 0 (표식 1) | 해당 없음 | 안 켬 | `dart format` 이 이미 보장한다 — 0줄 |
| `avoid_catches_without_on_clauses` | 0 (표식 1) | 해당 없음 | 안 켬 | 모든 catch 에 `on` 을 요구하는 매우 엄격한 규칙 — 지금 0줄이지만 앞으로의 코드에 부담 (lint 가 뺀다) |
| `avoid_positional_boolean_parameters` | 5 (1·4·0) | 0 (dry 0) | 안 켬 | `void Function(bool)` 콜백에서 오탐 — 5줄 손으로 |
| `avoid_classes_with_only_static_members` | 4 (4·0·0) | 0 (dry 0) | 안 켬 | 상수 모음 클래스가 흔하다 — 4줄 손으로 |
| `avoid_returning_this` | 0 (표식 1) | 해당 없음 | 안 켬 | API 설계 취향 규칙 — 0줄, 앱 코드에서 실익이 작다 |
| `use_to_and_as_if_applicable` | 0 (표식 1) | 해당 없음 | 안 켬 | API 설계 취향 규칙 — 0줄 |
| `prefer_mixin` | 0 (표식 1) | 해당 없음 | 안 켬 | API 설계 취향 규칙 — 0줄 |
| `prefer_asserts_with_message` | 5 (5·0·0) | 0 (dry 0) | 안 켬 | API 설계 취향 규칙 — 5줄 손으로 |
| `avoid_field_initializers_in_const_classes` | 0 (표식 1) | 해당 없음 | 안 켬 | API 설계 취향 규칙 — 0줄 |
| `prefer_foreach` | 3 (0·3·0) | 0 (dry 0) | 안 켬 | "더 빽빽한 코드" 를 강제한다 — 3줄 손으로 (lint 가 뺀다) |
| `prefer_expression_function_bodies` | 128 (71·55·2) | 121 | 안 켬 | "더 빽빽한 코드" 를 강제한다 — 128줄 중 121 dart fix (very_good_analysis 가 10.1.0 에서 뺐다) |
| `close_sinks` | 0 (표식 1) | 해당 없음 | 안 켬 | 풀리지 않은 오탐 (very_good_analysis · lint 가 뺀다) — 0줄 |
| `prefer_void_to_null` | 0 (표식 1) | 해당 없음 | 안 켬 | 풀리지 않은 오탐 (very_good_analysis 가 뺀다) — 0줄 |
| `unreachable_from_main` | 2 (0·1·1) | 0 (dry 0) | 안 켬 | very_good_analysis 가 10.3.0 에서 기본으로 껐다 — 2줄 |
| `do_not_use_environment` | 17 (13·4·0) | 0 (dry 0) | 안 켬 | `--dart-define` 을 쓰는 앱은 모두 걸린다 — 17줄 (lib 13) |
| `library_names` | 0 (표식 1) | 해당 없음 | 안 켬 | 기반 세트의 `unnecessary_library_name` 이 대신한다 — 0줄 |
| `lines_longer_than_80_chars` | 107 (35·72·0) | 0 (dry 0) | 안 켬 | 줄바꿈은 formatter 의 몫 — 107줄, dart fix 0 |
| `always_put_control_body_on_new_line` | 398 (324·53·21) | 0 (dry 0) | 안 켬 | formatter 와 어긋날 수 있다 — 398줄, dart fix 0 |
| `cascade_invocations` | 60 (6·44·10) | 0 (dry 0) | 안 켬 | "더 빽빽한 코드" 를 강제한다 — 60줄, dart fix 0 |

**권고:** 켬 0개 · 안 켬 28개 (도구 판정 4 + 검토 24) · 결정 안 함 3개 (표식 불가 2 · 표식 미검출 1) — 표의 권고 열대로.

선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름과 켬 / 안 켬)  (3) 이 묶음은 보류

## 질문 1 — `no_dynamic_casts`

### 용어 풀이

- **dynamic 에서의 cast:** 타입이 `dynamic` 인 값(예: JSON 을 풀어 얻은 값)을 구체 타입 자리에 그대로 넣는 것. 컴파일러가 검사하지 않고 실행 중에 타입이 맞지 않으면 오류가 난다.

### 찾아본 것

- Dart 3.13.0 CHANGELOG: "`no_dynamic_casts` lint 가 `strict-casts` 옵션을 대체한다" — FEATURES.md § D. 옵션 형태(`strict-casts`)는 **error** 를 내 받는 쪽 `dart analyze` 를 바로 실패시키므로 쓰지 않는다 (ROADMAP Notes); lint 형태는 **info** 이고 규칙 단위로 끌 수 있다
- 채택 2/7 (FEATURES.md § B-4)

### 실측 (`--summary strict` 의 그 행)

```text
[strict 계열] 3개 — 권고: 켬 0 · 안 켬 0 · 검토 3 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙             | 경고 (lib·test·bin)     | dart fix  | 고친 뒤 error | 권고 | 이유                                 |
|------------------|-------------------------|-----------|---------------|------|--------------------------------------|
| no_dynamic_casts | 0 (표식 1)              | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
```

**권고:** 켬 — 0줄 (표식 1), info 라 받는 쪽 CI 를 막지 않고 앞으로의 JSON 처리 코드에서 실행 중 타입 오류를 미리 잡는다.

선택지: `켬` / `안 켬`

## 질문 2 — `no_raw_types`

### 용어 풀이

- **raw 타입:** 타입 인자를 생략한 제네릭 타입 (`List`, `Map`, `Future` 처럼 `<…>` 를 쓰지 않은 것). 생략된 인자는 `dynamic` 이 되어 타입 검사가 빠진다.

### 찾아본 것

- Dart 3.13.0 CHANGELOG: "`no_raw_types` lint 가 `strict-raw-types` 옵션을 대체한다" — FEATURES.md § D. 옵션 형태는 warning, lint 형태는 info
- 채택 2/7 (FEATURES.md § B-4)

### 실측 (`--summary strict` 의 그 행)

```text
[strict 계열] 3개 — 권고: 켬 0 · 안 켬 0 · 검토 3 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙             | 경고 (lib·test·bin)     | dart fix  | 고친 뒤 error | 권고 | 이유                                 |
|------------------|-------------------------|-----------|---------------|------|--------------------------------------|
| no_raw_types     | 0 (표식 1)              | 해당 없음 | —             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
```

**권고:** 켬 — 0줄 (표식 1), info.

선택지: `켬` / `안 켬`

## 질문 3 — `strict-inference`

### 용어 풀이

- **lint 가 아니라 analyzer 옵션이다:** 켜면 `lib/base.yaml` 에 `analyzer: language: strict-inference: true` 가 들어간다 (`linter: rules:` 목록이 아니다).
- **추론 실패:** 타입을 적지 않아 analyzer 가 타입을 정하지 못하고 `dynamic` 으로 두는 곳 (예: 타입 인자 없이 부른 `Future.delayed(...)`, `showDialog(...)`, 빈 `[]`). 진단 이름이 `inference_failure_on_*` 다.
- **warning:** 이 진단은 info 가 아니라 **warning** 이다. 받는 쪽의 `dart analyze` 는 warning 에서 실패한다 (`--fatal-warnings` 가 기본으로 켜져 있다 — `VERSIONING.md`, Dart 3.13.4, 2026-10-11 확인).

### 찾아본 것

- FEATURES.md § D — 채택 3/6 (very_good_analysis · leancode_lint · pedantic_mono), 대체 lint 는 아직 없다 (Dart 3.13.0 CHANGELOG 에 언급 없음)
- 04-CONTEXT.md D-19, 04-RESEARCH.md Pitfall 4 — 채택하면 이 저장소의 연습용 프로젝트 `fixtures/base_codegen` 의 정답지 첫 줄이 `exit 0` → `exit 2` 로 바뀐다. 결정과 대응하는 정상 변화이고, `CHANGELOG.md` 2.0.0 의 `### 올리기 전에` 에 "warning 이 생겨 `dart analyze` 가 실패할 수 있다" 는 불릿이 생긴다
- `strict-inference` 를 켜면 생성 파일(`*.g.dart`) 제외가 사실상 필요하다 — `lib/codegen.yaml` 이 이미 제외한다 (FEATURES.md § D 권고 3)
- (참고) 켜되 `analyzer: errors:` 로 진단 코드마다 심각도를 info 로 낮추는 길도 있다. 이번 회차는 그 형태를 재지 않았다 — 고르려면 따로 잰 뒤 정한다

### 실측 (`--summary strict` 의 그 행)

```text
[strict 계열] 3개 — 권고: 켬 0 · 안 켬 0 · 검토 3 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙             | 경고 (lib·test·bin)     | dart fix  | 고친 뒤 error | 권고 | 이유                                 |
|------------------|-------------------------|-----------|---------------|------|--------------------------------------|
| strict-inference | 106 (0·106·0) · warning | 0 (dry 0) | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
```

**권고:** 안 켬 — 106줄이 모두 test 에 있고 `dart fix` 로 사라지는 줄이 0이다. 켜는 순간 `flutter_starter_kit` 의 `dart analyze` 가 warning 106줄로 실패하고(손으로 타입 인자를 적어야 풀린다), lib 에서는 0줄이라 얻는 것이 작다.

선택지: `켬` / `안 켬`

## 질문 4 — import 스타일 (`always_use_package_imports` 대 `prefer_relative_imports`)

### 용어 풀이

- **package import / 상대 경로 import:** 같은 패키지 안의 파일을 `import 'package:앱이름/…'` 로 부르느냐, `import '../…'` 로 부르느냐.
- `always_use_package_imports` 는 lib 안의 **상대 경로** import 를, `prefer_relative_imports` 는 lib 안의 **package** import 를 경고한다. 둘은 함께 쓸 수 없다 (R1 의 `conditions.incompatiblePairs` 에서 확인).

### 찾아본 것

- FEATURES.md 128행: "`flutter_starter_kit` 이 현재 어느 스타일인지 세어 보고 다수 쪽을 택하면 진단이 최소가 된다"
- 채택: `always_use_package_imports` 5/7, `prefer_relative_imports` 1/7 (FEATURES.md § B-1)
- 이 수치는 `flutter_starter_kit` 하나에서 잰 것이다 — 이 패키지를 쓰는 다른 프로젝트의 스타일은 재지 않았다

### 실측 (`--summary import`)

```text
[import 스타일] 2개 — 권고: 켬 0 · 안 켬 0 · 검토 2 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙                       | 경고 (lib·test·bin) | dart fix | 고친 뒤 error | 권고 | 이유                                 |
|----------------------------|---------------------|----------|---------------|------|--------------------------------------|
| always_use_package_imports | 615 (615·0·0)       | 615      | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |
| prefer_relative_imports    | 9 (9·0·0)           | 9        | 0             | 검토 | 실제 문제를 가리키는가 — 사람이 본다 |

**권고:** 표의 권고 열대로 — 켬 0개, 안 켬 0개 (검토 2개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

- 읽는 법: `always_use_package_imports` 의 615줄은 이 프로젝트의 lib 에 **상대 경로 import 가 615줄** 있다는 뜻이고, `prefer_relative_imports` 의 9줄은 lib 의 **package import 가 9줄** 이라는 뜻이다. 다수는 상대 경로다. 어느 쪽이든 `dart fix` 가 모두 고치고 고친 뒤 error 는 0이다.

**권고:** `prefer_relative_imports` 켬 · `always_use_package_imports` 안 켬 — 다수 쪽이라 9줄만 바뀐다 (모두 dart fix).

선택지: (a) `prefer_relative_imports` 켬  (b) `always_use_package_imports` 켬  (c) 둘 다 안 켬

## 질문 5 — fire-and-forget (`unawaited_futures` · `discarded_futures` · `unnecessary_unawaited`)

### 용어 풀이

- **fire-and-forget:** Future 를 돌려받고도 기다리지(`await`) 않고 버리는 호출. 버린 Future 가 실패하면 오류가 아무 데도 전달되지 않는다.
- **세 규칙의 범위:** `unawaited_futures` (지금 켜 둠) 는 `async` 함수 **안** 에서 버린 Future 를, `discarded_futures` 는 `onPressed` · `initState` 같은 **동기** 함수 안에서 버린 Future 를 잡는다. 둘을 함께 켜면 버리는 모든 Future 에 표시를 해야 한다. `unnecessary_unawaited` 는 표시가 필요 없는 곳에 붙은 `unawaited()` 를 잡는다.
- **표시하는 방법 셋:** `unawaited(f)` (`dart:async`) — "일부러 기다리지 않는다" 를 코드에 적는다. `// ignore: unawaited_futures` — 그 줄의 경고만 끄는 주석. `@awaitNotRequired` (`package:meta`, Dart 3.9 부터) — 함수 선언에 붙여 "이 함수의 Future 는 기다리지 않아도 된다" 고 알리면 부르는 쪽이 경고를 받지 않는다; 그런 함수를 `unawaited()` 로 감싸면 `unnecessary_unawaited` 가 잡는다.

### 찾아본 것

- FEATURES.md § B-1 (`discarded_futures` 채택 3/7, `unnecessary_unawaited` 6/7), § C (`unawaited_futures` 채택 5/7, `@awaitNotRequired` 지원은 Dart 3.9)
- `unnecessary_unawaited` 는 미출시 `lints` 7 의 recommended 에 들어갈 예정이다 — FEATURES.md § B-1 아래 문단

### 실측 (`--summary fire`)

```text
[fire-and-forget] 3개 — 권고: 켬 0 · 안 켬 1 · 검토 2 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙                  | 경고 (lib·test·bin) | dart fix  | 고친 뒤 error | 권고  | 이유                                 |
|-----------------------|---------------------|-----------|---------------|-------|--------------------------------------|
| discarded_futures     | 11 (9·2·0)          | 0 (dry 0) | 0             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |
| unnecessary_unawaited | 3 (0·3·0)           | 3         | 9             | 안 켬 | dart fix 가 error 9건을 남긴다       |
| unawaited_futures     | 0 (표식 1)          | 해당 없음 | —             | 검토  | 실제 문제를 가리키는가 — 사람이 본다 |

**권고:** 표의 권고 열대로 — 켬 0개, 안 켬 1개 (검토 2개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

| 규칙 | 권고 | 이유 |
|---|---|---|
| `unawaited_futures` | 켬 (남김) | async 본문에서 버린 Future — 0줄 (표식 1), 프로젝트가 이미 지킨다 |
| `discarded_futures` | 켬 | 동기 콜백에서 버린 Future 의 오류가 사라진다 — 11줄 (lib 9 · test 2), dart fix 0 이라 손으로 `unawaited()` 로 감싼다 |
| `unnecessary_unawaited` | 안 켬 (도구 판정) | `dart fix` 가 3줄을 지우고 error 9건을 남긴다 — `lints` 7 에서 기반 세트로 들어오면 그때 받는다 |

**권고:** `unawaited_futures` 켬 · `discarded_futures` 켬 · `unnecessary_unawaited` 안 켬 — 버리는 Future 는 모두 `unawaited()` 로 적는 쪽.

선택지: 규칙마다 `켬` / `안 켬`

## 질문 6 — 함께 쓸 수 없는 쌍 (`prefer_double_quotes` · `unnecessary_final`)

### 용어 풀이

- **함께 쓸 수 없는 쌍:** 정반대를 요구하는 두 규칙. 둘을 함께 켜면 analyzer 가 옵션 파일(`analysis_options.yaml`)에 `incompatible_lint` 진단을 붙이고, 고치는 대로 반대 규칙이 다시 걸린다.
- `prefer_double_quotes` 는 지금 켜 둔 `prefer_single_quotes` 와, `unnecessary_final` 은 지금 켜 둔 `prefer_final_locals` (와 묶음 3 의 `prefer_final_in_for_each`) 와 함께 쓸 수 없다.

### 찾아본 것

- FEATURES.md § B-6, R1 의 `conditions.incompatiblePairs` (두 쌍 모두 둘만 켜서 확인)
- 04-CONTEXT.md D-04 · D-05 — 공통 안 켬 잣대에 걸리지만 하나씩 묻기로 적었다

### 실측 (`--summary pairs`)

```text
[함께 쓸 수 없는 쌍] 2개 — 권고: 켬 0 · 안 켬 2 · 검토 0 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙                 | 경고 (lib·test·bin)    | dart fix | 고친 뒤 error | 권고  | 이유                                             |
|----------------------|------------------------|----------|---------------|-------|--------------------------------------------------|
| prefer_double_quotes | 20332 (2241·17901·190) | 20332    | 0             | 안 켬 | 비호환 — prefer_single_quotes 과 함께 쓸 수 없다 |
| unnecessary_final    | 6724 (1008·5632·84)    | 6724     | 0             | 안 켬 | 비호환 — prefer_final_locals 과 함께 쓸 수 없다  |

**권고:** 표의 권고 열대로 — 켬 0개, 안 켬 2개 (검토 0개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

- 읽는 법: 이 두 줄 수는 지금 켜 둔 규칙과 반대 방향이라서 크다 — 이 프로젝트가 홑따옴표와 `final` 지역 변수를 이미 쓴다는 뜻이다. 켜려면 짝인 지금 규칙을 빼야 한다.

**권고:** 둘 다 안 켬 — 지금 켜 둔 `prefer_single_quotes` · `prefer_final_locals` 와 정반대이고, 켜면 2만 줄 · 6천 줄이 바뀐다.

선택지: 규칙마다 `켬` / `안 켬` (켬 이면 짝인 지금 규칙을 빼는 결정이 함께 필요하다)

## 질문 7 — 상태 출처가 갈리는 규칙 (`unnecessary_underscores`)

### 용어 풀이

- **상태 출처:** 규칙이 stable 인지 experimental 인지를 적은 곳. SDK 의 `messages.yaml`, SDK 의 `rules.json`, dart.dev 의 규칙 목록 셋이 서로 다르게 적은 규칙이 있다. 이 phase 는 `messages.yaml` 을 기준으로 삼는다 (04-CONTEXT.md "이전에 확정").

### 찾아본 것

- `.claude/skills/spike-findings-woody-lints/references/rule-evaluation-table.md` 3번 (spike 020):

  | 규칙 | `rules.json` | `messages.yaml` | dart.dev | 상류 세트 |
  |---|---|---|---|---|
  | `unnecessary_underscores` | stable | experimental (3.7) | stable | `lints` recommended |
  | `use_super_parameters` | experimental | experimental | experimental | `lints` recommended |

- **선례 (D-05):** 기반 세트의 `use_super_parameters` 는 세 출처 모두 experimental 인데 `lints` 6.1.0 의 recommended 에 들어 있어, 이 패키지를 include 하는 프로젝트에서 이미 켜져 있다. "experimental 이면 켜지 않는다" 를 그대로 적용하면 기반 세트와 부딪친다.
- **이번 회차에서 확인한 것:** `unnecessary_underscores` 도 `lints` 6.1.0 의 `recommended.yaml` 에 있다 — 이미 켜져 있어 후보가 아니고, 실측 도구는 이 규칙의 행을 만들지 않았다 (`tool/measure_rules.dart` 의 `bundleRules` 주석). 그래서 아래 출력은 0행이고, 결정 표에도 이 규칙의 행은 없다.

### 실측 (`--summary status`)

```text
[상태 출처가 갈리는 규칙] 0개 — 권고: 켬 0 · 안 켬 0 · 검토 0 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙 | 경고 (lib·test·bin) | dart fix | 고친 뒤 error | 권고 | 이유 |
|------|---------------------|----------|---------------|------|------|
(이 묶음의 후보 행이 없다)

**권고:** 표의 권고 열대로 — 켬 0개, 안 켬 0개 (검토 0개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

- 이 질문이 실제로 정하는 것: 기반 세트가 켜는 이 규칙을 **그대로 받을지**, 이 패키지에서 **끌지**. 끄려면 `lib/base.yaml` 의 규칙을 맵 형식(`unnecessary_underscores: false`)으로 적어야 하는데, 이 저장소는 목록 형식을 관례로 쓰고 맵 형식은 검증 명령의 알려진 거짓 실패(03 리뷰 WR-03)를 밟는다.
- 같은 갈림이 질문 9 의 `unnecessary_ignore` 에도 있다 (`messages.yaml` experimental, `rules.json` · dart.dev stable). 이 질문의 답은 04-08 에서 그 규칙을 물을 때의 참고가 된다.

**권고:** 그대로 둔다 (기반 세트가 켠다) — 출처가 갈리는 experimental 표기는 "켜지 않는다" 의 이유로 쓰지 않고, 기반 세트의 선택을 따른다.

선택지: `그대로 둔다` / `끈다`

## 질문 8 — v2 로 미룬 12개 (숫자만)

이 12개는 **결정을 묻지 않는다** (D-01). 결정 표에 `결정 안 함 (v2, RULES-NN)` 으로 적고, 04-07 이 `RULES.md` 의 켜지 않은 규칙 표에 "v2 로 미룸 (RULES-NN)" 으로 옮긴다.

- RULES-09: API 문서 규칙 (`public_member_api_docs`, `comment_references`, `missing_code_block_language_in_doc_comment`, `deprecated_consistency`)
- RULES-10: primary constructor 전환 규칙 — 언어 버전 3.13 에서만 도는 6개와 `unnecessary_primary_constructor_body`. 지금 하한(`^3.11.1`)의 값과 복사본의 하한만 `^3.13.0` 으로 올린 값을 둘 다 적었다
- RULES-11: `migrate_design_widgets`

### 실측 (`--summary v2`)

```text
[v2 로 미룸] 12개 — 권고: 켬 0 · 안 켬 0 · 검토 0 · 결정 안 함 12        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙                                       | 경고 (lib·test·bin)                       | dart fix  | 고친 뒤 error | 권고          | 이유                   |
|--------------------------------------------|-------------------------------------------|-----------|---------------|---------------|------------------------|
| unnecessary_type_name_in_constructor       | 0 (돌지 않음) / 3.13 하한 281 (220·59·2)  | 281       | 0             | v2 (RULES-10) | 결정하지 않음 — 숫자만 |
| migrate_design_widgets                     | 157 (62·95·0)                             | 157       | 12            | v2 (RULES-11) | 결정하지 않음 — 숫자만 |
| empty_container_bodies                     | 0 (돌지 않음) / 3.13 하한 432 (0·432·0)   | 432       | 0             | v2 (RULES-10) | 결정하지 않음 — 숫자만 |
| unnecessary_const_in_enum_constructor      | 0 (돌지 않음) / 3.13 하한 2 (2·0·0)       | 2         | 0             | v2 (RULES-10) | 결정하지 않음 — 숫자만 |
| use_declaring_parameters                   | 0 (표식 없음) / 3.13 하한 0 (표식 1)      | 해당 없음 | —             | v2 (RULES-10) | 결정하지 않음 — 숫자만 |
| initialize_in_field_declaration            | 0 (표식 없음) / 3.13 하한 0 (표식 1)      | 해당 없음 | —             | v2 (RULES-10) | 결정하지 않음 — 숫자만 |
| unnecessary_primary_constructor_body       | 0 (표식 없음) / 3.13 하한 0 (표식 1)      | 해당 없음 | —             | v2 (RULES-10) | 결정하지 않음 — 숫자만 |
| public_member_api_docs                     | 0 (표식 1)                                | 해당 없음 | —             | v2 (RULES-09) | 결정하지 않음 — 숫자만 |
| comment_references                         | 196 (178·18·0)                            | 100       | 0             | v2 (RULES-09) | 결정하지 않음 — 숫자만 |
| missing_code_block_language_in_doc_comment | 0 (표식 1)                                | 해당 없음 | —             | v2 (RULES-09) | 결정하지 않음 — 숫자만 |
| deprecated_consistency                     | 0 (표식 1)                                | 해당 없음 | —             | v2 (RULES-09) | 결정하지 않음 — 숫자만 |
| use_primary_constructors                   | 0 (돌지 않음) / 3.13 하한 785 (258·524·3) | 785       | 0             | v2 (RULES-10) | 결정하지 않음 — 숫자만 |

**권고:** 표의 권고 열대로 — 켬 0개, 안 켬 0개 (검토 0개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

## 질문 9 — `unnecessary_ignore` (보류)

### 용어 풀이

- **`unnecessary_ignore`:** 더 이상 나지 않는 진단을 끄고 있는 `// ignore` 주석을 잡는다. 다른 규칙을 켜고 끄는 데 따라 값이 바뀐다 (spike 023 — 다른 후보에 따라 38 ↔ 12).

### 찾아본 것

- 04-CONTEXT.md D-17 — 다른 후보의 채택이 정해진 **뒤** 그 결과를 켠 채로 다시 재서 하나씩 묻는다. 그 일은 plan 04-08 이 한다 (`--stage unnecessary-ignore`)
- 상태 출처가 갈린다 — `messages.yaml` experimental (3.8), `rules.json` · dart.dev stable. 도구는 `messages.yaml` 기준으로 `안 켬 (experimental)` 을 냈다. 질문 7 의 선례(`use_super_parameters`)를 04-08 에서 함께 보인다

### 지금의 값 (회차 R1 의 G1 — 참고로만)

```text
[unnecessary_ignore] 1개 — 권고: 켬 0 · 안 켬 1 · 검토 0 · 결정 안 함 0        실측 R1 (2026-10-13, Flutter 3.47.5, flutter_starter_kit Dart 파일 474개)

| 규칙               | 경고 (lib·test·bin) | dart fix | 고친 뒤 error | 권고  | 이유                                                                                                    |
|--------------------|---------------------|----------|---------------|-------|---------------------------------------------------------------------------------------------------------|
| unnecessary_ignore | 12 (1·10·1)         | 11       | 0             | 안 켬 | experimental (messages.yaml) — 출처마다 다름: messages.yaml experimental / rules.json · dart.dev stable |

**권고:** 표의 권고 열대로 — 켬 0개, 안 켬 1개 (검토 0개는 사람이 정한다).
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

**권고:** 지금은 답하지 않는다 — 04-08 에서 이번 결정을 켠 채로 다시 잰 값으로 묻는다 (결정 표에는 `보류 (04-08)`).

선택지: 없음 (보류를 알리기만 한다)

## 결정

결정 표 — 후보 133개, 이름 순. `묶음` 칸은 `tool/measure_rules.dart` 의 `bundles` id 다. `권고` 는 위 패널의 것(도구 판정 포함)이고, `결정` · `사유` 는 소유자의 응답으로만 채운다. `결정` 칸의 `켬` / `안 켬` 115행은 2026-10-13 의 소유자 응답(묶음 5 · 개별 질문 7)으로 채웠고, 나머지 18행은 v2 12 · `unnecessary_ignore` 보류 1 · 도구가 0줄의 뜻을 가르지 못한 5 다 (초안 그대로).

| 규칙 | 묶음 | 권고 | 결정 | 사유 |
|---|---|---|---|---|
| `always_declare_return_types` | current | 켬 | 켬 | 권고 이유 승인 — 남긴다 — 0줄 (사유 문구는 "기반 세트의 strict_top_level_inference 가 보지 않는 지역 함수 · 옛 typedef" 로, D-18). 사유 문구 (D-18 승인): 기반 세트의 strict_top_level_inference 가 보지 않는 지역 함수 · 옛 typedef 의 반환 타입까지 |
| `always_put_control_body_on_new_line` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — formatter 와 어긋날 수 있다 — 398줄, dart fix 0 |
| `always_put_required_named_parameters_first` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — Flutter 의 `super.key` 를 앞에 두는 관례와 어긋난다 — 32줄 |
| `always_specify_types` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 도구 판정: dart fix 가 error 6건을 남긴다 |
| `always_use_package_imports` | import | 안 켬 | 안 켬 | 권고 이유 승인 — 질문 4 (a) — 소수 쪽, 켜면 615줄 |
| `async_return_with_no_await` | bug | 켬 | 켬 | 권고 이유 승인 — await 없이 넘긴 Future 는 이 함수의 try/catch 를 지나 예외가 밖에서 난다 — 30줄 손으로 (dart fix 0) |
| `avoid_annotating_with_dynamic` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — `dynamic` 을 적는 것은 의도 표시이기도 하다 — 1줄, 채택 0/7 |
| `avoid_bool_literals_in_conditional_expressions` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `avoid_catches_without_on_clauses` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 모든 catch 에 `on` 을 요구하는 매우 엄격한 규칙 — 지금 0줄이지만 앞으로의 코드에 부담 (lint 가 뺀다) |
| `avoid_catching_errors` | bug | 켬 | 켬 | 권고 이유 승인 — `Error` 를 잡으면 프로그램 버그가 숨는다 — 3줄 손으로 |
| `avoid_classes_with_only_static_members` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 상수 모음 클래스가 흔하다 — 4줄 손으로 |
| `avoid_double_and_int_checks` | bug | 켬 | 켬 | 권고 이유 승인 — web 에서 뜻이 달라지는 검사 — 0줄, web 빌드를 할 때를 대비 |
| `avoid_dynamic_calls` | bug | 켬 | 켬 | 권고 이유 승인 — dynamic 위의 호출은 타입 오류를 실행 때까지 숨긴다 — 28줄 모두 test, lib 0 |
| `avoid_equals_and_hash_code_on_mutable_classes` | bug | 안 켬 | 안 켬 | 권고 이유 승인 — `@immutable` 표시가 없을 뿐인 클래스도 걸린다 — 8줄 모두 lib, dart fix 0, 채택 2/7 |
| `avoid_escaping_inner_quotes` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `avoid_field_initializers_in_const_classes` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — API 설계 취향 규칙 — 0줄 |
| `avoid_final_parameters` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `avoid_implementing_value_types` | bug | 안 켬 | 안 켬 | 권고 이유 승인 — test 의 mock · fake 가 걸리는 규칙 — 25줄 모두 test (very_good_analysis 가 같은 이유로 뺀다) |
| `avoid_js_rounded_ints` | bug | 켬 | 켬 | 권고 이유 승인 — web 에서 정밀도가 깨지는 정수 — 0줄 |
| `avoid_multiple_declarations_per_line` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `avoid_positional_boolean_parameters` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — `void Function(bool)` 콜백에서 오탐 — 5줄 손으로 |
| `avoid_redundant_argument_values` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `avoid_returning_this` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — API 설계 취향 규칙 — 0줄, 앱 코드에서 실익이 작다 |
| `avoid_setters_without_getters` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `avoid_slow_async_io` | perf | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `avoid_type_to_string` | bug | 켬 | 켬 | 권고 이유 승인 — release 빌드에서 타입 이름이 바뀔 수 있다 — 0줄 |
| `avoid_types_on_closure_parameters` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 취향 규칙 — dart fix 가 237줄 모두 고치지만 closure 매개변수의 타입을 지우는 쪽으로 강제할 근거가 약하다 (채택 3/7) |
| `avoid_unused_constructor_parameters` | bug | 켬 | 켬 | 권고 이유 승인 — 쓰지 않는 생성자 매개변수는 빠뜨린 대입 — 0줄 |
| `avoid_void_async` | bug | 켬 | 켬 | 권고 이유 승인 — `void` 를 돌려주는 async 는 호출한 쪽이 기다리거나 오류를 받을 수 없다 — 0줄 |
| `cancel_subscriptions` | bug | 켬 | 켬 | 권고 이유 승인 — 닫지 않은 `StreamSubscription` 은 메모리 누수 — 0줄 |
| `cascade_invocations` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — "더 빽빽한 코드" 를 강제한다 — 60줄, dart fix 0 |
| `cast_nullable_to_non_nullable` | bug | 켬 | 켬 | 권고 이유 승인 — null 일 수 있는 값을 `as` 로 단정하면 실행 중 오류 — 5줄 모두 dart fix |
| `close_sinks` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 풀리지 않은 오탐 (very_good_analysis · lint 가 뺀다) — 0줄 |
| `combinators_ordering` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `comment_references` | v2 | v2 (RULES-09) | 결정 안 함 (v2, RULES-09) |  |
| `conditional_uri_does_not_exist` | bug | 켬 | 켬 | 권고 이유 승인 — 조건부 import 가 없는 파일을 가리키면 다른 플랫폼에서 빌드가 깨진다 — 0줄 |
| `deprecated_consistency` | v2 | v2 (RULES-09) | 결정 안 함 (v2, RULES-09) |  |
| `deprecated_member_use_from_same_package` | bug | 켬 | 켬 | 권고 이유 승인 — 같은 패키지 안의 deprecated 사용을 잡는다 — 0줄 |
| `diagnostic_describe_all_properties` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 도구 판정: dart fix 가 error 148건을 남긴다 |
| `directives_ordering` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `discarded_futures` | fire | 켬 | 켬 | 권고 이유 승인 — 질문 5 — 동기 콜백에서 버린 Future 의 오류가 사라진다, 11줄 손으로 unawaited() 로 감싼다 |
| `do_not_use_environment` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — `--dart-define` 을 쓰는 앱은 모두 걸린다 — 17줄 (lib 13) |
| `document_ignores` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 48 (≤ 50) |
| `empty_container_bodies` | v2 | v2 (RULES-10) | 결정 안 함 (v2, RULES-10) |  |
| `eol_at_end_of_file` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — `dart format` 이 이미 보장한다 — 0줄 |
| `flutter_style_todos` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `initialize_in_field_declaration` | v2 | v2 (RULES-10) | 결정 안 함 (v2, RULES-10) |  |
| `join_return_with_assignment` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 1 (≤ 50) |
| `leading_newlines_in_multiline_strings` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `library_names` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 기반 세트의 `unnecessary_library_name` 이 대신한다 — 0줄 |
| `lines_longer_than_80_chars` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 줄바꿈은 formatter 의 몫 — 107줄, dart fix 0 |
| `literal_only_boolean_expressions` | bug | 켬 | 켬 | 권고 이유 승인 — 늘 참/거짓인 조건은 남은 디버그 코드 — 0줄 |
| `matching_super_parameters` | bug | 켬 | 켬 | 권고 이유 승인 — super 매개변수의 순서 착오 — 0줄 |
| `migrate_design_widgets` | v2 | v2 (RULES-11) | 결정 안 함 (v2, RULES-11) |  |
| `missing_code_block_language_in_doc_comment` | v2 | v2 (RULES-09) | 결정 안 함 (v2, RULES-09) |  |
| `missing_whitespace_between_adjacent_strings` | bug | 켬 | 켬 | 권고 이유 승인 — 이어 붙인 문자열 사이의 공백 누락으로 문장이 붙는다 — 13줄 모두 test, 손으로 |
| `no_adjacent_strings_in_list` | bug | 켬 | 켬 | 권고 이유 승인 — 리스트 안의 붙은 문자열은 쉼표 누락일 때가 많다 — 9줄 모두 test, 손으로 |
| `no_dynamic_casts` | strict | 켬 | 켬 | 권고 이유 승인 — 질문 1 — strict-casts 옵션의 공식 대체, info 라 받는 쪽 CI 를 막지 않는다, 0줄 (표식 1) |
| `no_literal_bool_comparisons` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `no_raw_types` | strict | 켬 | 켬 | 권고 이유 승인 — 질문 2 — strict-raw-types 옵션의 공식 대체, info, 0줄 (표식 1) |
| `no_runtimetype_tostring` | perf | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 1 (≤ 50) |
| `no_self_assignments` | bug | 켬 | 켬 | 권고 이유 승인 — `x = x` 는 거의 늘 오타 — 0줄 |
| `noop_primitive_operations` | perf | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `omit_local_variable_types` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 도구 판정: dart fix 가 error 4건을 남긴다 |
| `omit_obvious_local_variable_types` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `omit_obvious_property_types` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — `type_annotate_public_apis` (묶음 3 켬 권고)와 함께 쓸 수 없다 — 716줄 |
| `only_throw_errors` | bug | 켬 | 켬 | 권고 이유 승인 — `Exception` / `Error` 가 아닌 값을 던지면 잡는 쪽이 스택을 잃는다 — 4줄 모두 test |
| `package_prefixed_library_names` | excluded | 결정 안 함 (표식 불가) | 결정 안 함 (표식 불가) |  |
| `parameter_assignments` | bug | 켬 | 켬 | 권고 이유 승인 — 매개변수를 다시 쓰면 원래 값을 잃는다 — 0줄 |
| `prefer_asserts_in_initializer_lists` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `prefer_asserts_with_message` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — API 설계 취향 규칙 — 5줄 손으로 |
| `prefer_const_constructors` | current | 켬 | 켬 | 권고 이유 승인 — 남긴다 — 0줄 (사유 문구는 "불변 위젯 트리를 const 로 적는 관례" 로 고친다, D-18). 사유 문구 (D-18 승인): 불변 위젯 트리를 const 로 적는 관례 — 성능 이득은 근거가 부족하다는 것이 Flutter 팀의 판단 (lints#205) |
| `prefer_const_declarations` | perf | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `prefer_const_literals_to_create_immutables` | current | 켬 | 켬 | 권고 이유 승인 — 남긴다 — 0줄 (사유 문구는 위와 같이 고친다, D-18). 사유 문구 (D-18 승인): 위와 같은 관례 — 불변 위젯에 넘기는 리터럴도 const 로 |
| `prefer_constructors_over_static_methods` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 1 (≤ 50) |
| `prefer_double_quotes` | pairs | 안 켬 | 안 켬 | 권고 이유 승인 — 질문 6 — 지금 켜 둔 prefer_single_quotes 와 함께 쓸 수 없다 (도구 판정) |
| `prefer_expression_function_bodies` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — "더 빽빽한 코드" 를 강제한다 — 128줄 중 121 dart fix (very_good_analysis 가 10.1.0 에서 뺐다) |
| `prefer_final_in_for_each` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `prefer_final_locals` | current | 켬 | 켬 | 권고 이유 승인 — 남긴다 — 0줄, `fixtures/overrides` 의 끄기 시연이 이 규칙을 쓴다 (Pitfall 3) |
| `prefer_foreach` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — "더 빽빽한 코드" 를 강제한다 — 3줄 손으로 (lint 가 뺀다) |
| `prefer_if_elements_to_conditional_expressions` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 2 (≤ 50) |
| `prefer_int_literals` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `prefer_mixin` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — API 설계 취향 규칙 — 0줄 |
| `prefer_null_aware_method_calls` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `prefer_relative_imports` | import | 켬 | 켬 | 권고 이유 승인 — 질문 4 (a) — 다수 쪽 (lib 의 상대 경로 import 615 대 package import 9), 9줄 모두 dart fix |
| `prefer_single_quotes` | current | 켬 | 켬 | 권고 이유 승인 — 남긴다 — 0줄 (프로젝트가 이미 따른다) |
| `prefer_void_to_null` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 풀리지 않은 오탐 (very_good_analysis 가 뺀다) — 0줄 |
| `public_member_api_docs` | v2 | v2 (RULES-09) | 결정 안 함 (v2, RULES-09) |  |
| `remove_deprecations_in_breaking_versions` | excluded | 결정 안 함 (표식 미검출) | 결정 안 함 (표식 미검출) |  |
| `require_trailing_commas` | excluded | 결정 안 함 (표식 불가) | 결정 안 함 (표식 불가) |  |
| `simple_directive_paths` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `simplify_variable_pattern` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `sized_box_shrink_expand` | perf | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `sort_constructors_first` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `sort_pub_dependencies` | style | 결정 안 함 (표식 불가) | 결정 안 함 (표식 불가) |  |
| `sort_unnamed_constructors_first` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `specify_nonobvious_local_variable_types` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 도구 판정: dart fix 가 error 4건을 남긴다 |
| `specify_nonobvious_property_types` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `strict-inference` | strict | 안 켬 | 안 켬 | 권고 이유 승인 — 질문 3 — warning 이라 받는 쪽 dart analyze 가 바로 실패한다, 106줄 모두 test · dart fix 0 |
| `switch_on_type` | bug | 켬 | 켬 | 권고 이유 승인 — `runtimeType` 으로 가르면 하위 타입을 놓친다 — 0줄 (lints 7 의 core 에 들어갈 예정 — 그때 겹침 검사가 잡는다) |
| `test_types_in_equals` | bug | 켬 | 켬 | 권고 이유 승인 — `==` 에서 인자 타입을 보지 않으면 cast 오류 — 0줄 |
| `throw_in_finally` | bug | 켬 | 켬 | 권고 이유 승인 — `finally` 의 throw 는 원래 예외를 덮는다 — 0줄 |
| `tighten_type_of_initializing_formals` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `type_annotate_public_apis` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `unawaited_futures` | fire | 켬 | 켬 | 권고 이유 승인 — 질문 5 — 남김, async 본문에서 버린 Future, 0줄 (표식 1) |
| `unnecessary_breaks` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `unnecessary_const_in_enum_constructor` | v2 | v2 (RULES-10) | 결정 안 함 (v2, RULES-10) |  |
| `unnecessary_final` | pairs | 안 켬 | 안 켬 | 권고 이유 승인 — 질문 6 — 지금 켜 둔 prefer_final_locals 와 함께 쓸 수 없다 (도구 판정) |
| `unnecessary_ignore` | ui | 보류 (도구: 안 켬 — experimental) | 보류 (04-08) |  |
| `unnecessary_lambdas` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `unnecessary_library_directive` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `unnecessary_null_aware_operator_on_extension_on_nullable` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `unnecessary_null_checks` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `unnecessary_parenthesis` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `unnecessary_primary_constructor_body` | v2 | v2 (RULES-10) | 결정 안 함 (v2, RULES-10) |  |
| `unnecessary_raw_strings` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `unnecessary_statements` | bug | 켬 | 켬 | 권고 이유 승인 — 효과 없는 문장은 빠진 호출 · 대입의 흔적 — 0줄 |
| `unnecessary_type_name_in_constructor` | v2 | v2 (RULES-10) | 결정 안 함 (v2, RULES-10) |  |
| `unnecessary_unawaited` | fire | 안 켬 | 안 켬 | 권고 이유 승인 — 질문 5 — dart fix 가 3줄을 지우고 error 9건을 남긴다 (도구 판정) |
| `unreachable_from_main` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — very_good_analysis 가 10.3.0 에서 기본으로 껐다 — 2줄 |
| `use_colored_box` | perf | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `use_declaring_parameters` | v2 | v2 (RULES-10) | 결정 안 함 (v2, RULES-10) |  |
| `use_decorated_box` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — 상류에 알려진 오동작이 있다 (very_good_analysis · lint 가 뺀다) — 1줄 |
| `use_enums` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `use_is_even_rather_than_modulo` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `use_named_constants` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `use_primary_constructors` | v2 | v2 (RULES-10) | 결정 안 함 (v2, RULES-10) |  |
| `use_raw_strings` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `use_setters_to_change_properties` | style | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 3 (≤ 50) |
| `use_string_buffers` | perf | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |
| `use_test_throws_matchers` | style | 결정 안 함 (표식 불가) | 결정 안 함 (표식 불가) |  |
| `use_to_and_as_if_applicable` | excluded | 안 켬 | 안 켬 | 권고 이유 승인 — API 설계 취향 규칙 — 0줄 |
| `use_truncating_division` | perf | 켬 | 켬 | 권고 이유 승인 — 도구 판정: 손으로 고칠 줄 0 (≤ 50) |

### 표 밖의 응답과 메모 (2026-10-13)

- 응답은 orchestrator 가 위의 묶음 1 ~ 5 · 질문 1 ~ 9 패널을 원문 그대로 보인 뒤 선택지 질문으로 받았다. 묶음 1 ~ 5 는 모두 `(1) 권고대로`, 질문 1 ~ 6 은 모두 권고와 같은 답이다. 소유자는 어느 항목에도 사유를 따로 덧붙이지 않았다 — `사유` 칸의 `권고 이유 승인 — …` 는 Claude 가 패널에 적은 이유(또는 도구 판정)를 소유자가 승인했다는 뜻이고 소유자가 쓴 말이 아니다.
- **D-18 사유 문구 (묶음 4, 승인):** 04-06 · 04-07 이 `lib/base.yaml` 의 사유 주석과 `RULES.md` 의 켠 이유로 쓴다.
  - prefer_const_constructors — 불변 위젯 트리를 const 로 적는 관례 — 성능 이득은 근거가 부족하다는 것이 Flutter 팀의 판단 (lints#205)
  - prefer_const_literals_to_create_immutables — 위와 같은 관례 — 불변 위젯에 넘기는 리터럴도 const 로
  - always_declare_return_types — 기반 세트의 strict_top_level_inference 가 보지 않는 지역 함수 · 옛 typedef 의 반환 타입까지
  - prefer_final_locals · prefer_single_quotes — 지금 사유 그대로
- **질문 7 (`unnecessary_underscores`): 그대로 둔다** — 기반 세트(`lints` 6.1.0 recommended)가 켜는 그대로 받고 `lib/base.yaml` 에서 끄지 않는다. 후보가 아니라 이 표에 행이 없다.
- 질문 8 (v2 12개)은 묻지 않았고, 질문 9 (`unnecessary_ignore`)는 보류 (04-08) 를 알렸다.
