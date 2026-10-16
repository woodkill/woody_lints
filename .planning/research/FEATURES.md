# Feature Research

**Domain:** Dart/Flutter 공유 lint 설정 패키지 (configuration-only package, `lib/analysis_options.yaml` 배포)
**Researched:** 2026-10-11
**Confidence:** MEDIUM

신뢰도 표기는 두 축으로 나눈다.

- **출처 등급 (seam 기준):** dart.dev / pub.dev / GitHub 원문을 직접 내려받아 읽은 내용은 `classify-confidence` 가 LOW(webfetch) ~ MEDIUM(context7, 교차 확인된 websearch) 로 분류한다. HIGH 등급은 없다.
- **근거 표기 (이 문서 안):**
  - **[실측]** — 로컬 FVM 의 Flutter 3.47.5 / Dart 3.13.4 analyzer 를 scratch 프로젝트에서 직접 실행해 확인한 것. 지원 대상 SDK 그대로이므로 이 문서에서 가장 강한 근거다.
  - **[공식]** — dart.dev 의 `linter_rules.json`, dart.dev 문서, Dart SDK `CHANGELOG.md`, 패키지 배포본(pub.dev archive, 로컬 pub cache)의 소스.
  - **[추정]** — 위 근거를 바탕으로 한 판단. 특히 **규칙별 "소음" 등급은 전부 추정**이며, `flutter_starter_kit` 복사본 실측으로 대체해야 한다.

규칙 이름·상태(stable / experimental / deprecated / removed)·도입 버전·fix 여부·충돌 관계는 `linter_rules.json` 264개 항목을 기준으로 하고, 전체 이름을 Dart 3.13.4 analyzer 에 넣어 `undefined_lint` / `removed_lint` / `deprecated_lint` / `incompatible_lint` 출력으로 교차 확인했다 [실측].

---

## Feature Landscape

### Table Stakes (Users Expect These)

공유 lint 패키지가 "믿고 include 할 수 있다"고 여겨지려면 있어야 하는 것. 조사한 패키지(`lints`, `flutter_lints`, `very_good_analysis`, `lint`, `leancode_lint`, `pedantic_mono`, `solid_lints`, `total_lints`)가 공통으로 갖춘 항목이다.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| 배포 파일이 유효하다 (없는 규칙·removed·deprecated·서로 충돌하는 규칙이 없다) | 유일한 산출물이 깨져 있으면 패키지 존재 이유가 없다 | LOW | 검증 방법이 두 가지 필요하다. 아래 "검증 방식의 사각지대" 참조 [실측] |
| 문서의 규칙 목록 = 실제 설정 | Core Value 그 자체. 현재 README 가 꺼진 규칙 2건을 켜진 것으로 안내한다 | LOW | 목록을 README 에 손으로 복제하지 말고 YAML 을 단일 원천으로 삼는다 |
| 기반 세트(`flutter_lints`) 위에 얹는 구조 | `pedantic_mono` 도 `include: package:flutter_lints/flutter.yaml` 방식. 기반이 바뀌면 자동으로 따라간다 | LOW | 이미 충족. 중복 선언 6개 정리만 남았다 |
| 릴리스마다 규칙 추가/삭제를 적는 CHANGELOG | `lints` / `flutter_lints` CHANGELOG 는 버전마다 "added X / removed Y" 만 적는다. 사용 프로젝트에서 진단이 생긴 원인 버전을 추적하는 유일한 수단 | LOW | 형식은 `lints` CHANGELOG 를 그대로 따르면 된다 |
| 버전 고정 수단 | pub 버전(`lints`), 버전별 파일(`very_good_analysis`), SDK 대응표(`lint`) 중 하나는 반드시 있다 | LOW | 이 패키지는 git tag + `ref: vX.Y.Z` |
| 선언한 SDK 하한이 규칙의 최소 SDK 와 일치 | Dart 3.13 에서 추가된 규칙을 쓰면서 `sdk: ^3.10.4` 로 두면 이전 SDK 프로젝트에서 `undefined_lint` 가 난다 | LOW | `pubspec.yaml` 의 `sdk` 와 `.fvmrc` 를 함께 올린다 |
| 규칙 재정의(override) 안내 | `very_good_analysis` README 가 line / file / project 3단계 억제 방법을 싣는다. 현재 README 에 없다 | LOW | plugin 진단은 `// ignore: riverpod_lint/<code>` 와 `plugins.<name>.diagnostics` 로 따로 안내해야 한다 [공식][실측] |
| 서로 양립 불가한 규칙을 함께 켜지 않는다 | analyzer 가 `incompatible_lint` 경고를 낸다 | LOW | 충돌 쌍은 "Candidate Lint Rules" 의 충돌 열 참조 |

**검증 방식의 사각지대 [실측].** 배포 파일에 일부러 잘못된 규칙을 넣고 두 방식으로 분석했다.

| 배포 파일 안의 문제 | 사용 프로젝트 방식 (`include: package:...`) | 배포 파일을 root 옵션 파일로 분석 |
|---|---|---|
| 없는 규칙 이름 (오타, 상위 SDK 전용 규칙) | 보고됨 (`included_file_warning`) | 보고됨 (`undefined_lint`) |
| 양립 불가 규칙 쌍 | 보고됨 (`included_file_warning`) | 보고됨 (`incompatible_lint`) |
| removed 규칙 (`avoid_returning_null`) | **보고되지 않음** | 보고됨 (`removed_lint`) |
| deprecated 규칙 (`unnecessary_await_in_return`) | **보고되지 않음** | 보고됨 (`deprecated_lint`) |
| 기반 세트와 중복되는 선언 | 보고되지 않음 | 보고되지 않음 |

따라서 `example/` 프로젝트가 사용 프로젝트 방식만 흉내 내면 removed / deprecated 규칙을 놓친다. CI 는 (1) `example/` 에서 include 방식 분석과 (2) 배포 파일을 root 옵션 파일 자리에 놓고 분석하는 검사를 둘 다 가져야 한다. 표본은 문제 유형당 규칙 1개씩이다.

### Differentiators (Competitive Advantage)

필수는 아니지만 이 패키지의 Core Value("각 규칙이 왜 켜져 있는지 근거가 남아 있다")를 직접 강화하는 것.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| 규칙별 근거 기록 (켠 이유 + 실측 건수) | `lint` 패키지는 `strict.yaml` 에 규칙마다 켠/끈 사유를 주석으로 남긴다. `very_good_analysis` 는 끈 규칙만 README 표로 남긴다. 실측 건수까지 남기는 패키지는 조사 범위에서 찾지 못했다 | MEDIUM | 사유는 YAML 주석(배포 파일 = 단일 원천)에, 실측 표는 별도 문서에 두는 구성이 drift 가 적다 |
| 끄기로 한 규칙과 사유 목록 | "왜 이 규칙이 없지?" 를 몇 달 뒤 다시 조사하지 않게 한다. `very_good_analysis` README 의 "Excluded rules" 표가 선례 | LOW | 이 문서의 "제외 권장" 표가 초안이 된다 |
| 선택형 preset 파일 | `lint` (`casual` / `strict` / `package`), `total_lints` (`app` / `package`), `solid_lints` (test 용 별도 파일), `lints` (`core` / `recommended`) 가 선례. 축은 "엄격도" 또는 "용도" | MEDIUM | 이 패키지의 축은 "스택"(Riverpod, codegen). include 목록 방식과 plugin 을 담은 preset 이 Dart 3.13.4 에서 동작함을 확인했다 [실측] |
| `example/` 프로젝트 + CI | `very_good_analysis`, `pedantic_mono`, `lint`, `leancode_lint`, `solid_lints` 가 `example/` 를 둔다. `very_good_analysis` 의 example 은 `path: ../` 의존성 + include 한 줄 + Dart 파일 1개(12줄)로 최소 구성 | MEDIUM | 위 "사각지대" 때문에 검사 두 종류가 필요 |
| 릴리스별 migration 안내 | 새 규칙이 기존 코드에 몇 건을 내는지, `dart fix --apply` 로 몇 건이 사라지는지 적어 두면 사용 프로젝트를 올릴 시점을 고를 수 있다 | LOW | 실측 결과를 재사용하면 추가 비용이 거의 없다 |
| analyzer strict 모드 채택 | 조사한 6개 커뮤니티 패키지 중 5개가 `strict-casts` 를 켠다. "Analyzer Strict Modes" 참조 | MEDIUM | Dart 3.13 에 대체 lint 가 생겼다. 형태 선택이 필요 |
| "`lib/` 에 Dart 소스가 없다" 검사 | `lints` 와 `flutter_lints` 가 저장소에서 돌리는 유일한 자체 검사다. 설정 전용 패키지라는 불변식을 지킨다 | LOW | CI 에 한 줄로 추가 가능 |
| 생성 파일 exclude 를 preset 으로 제공 | `solid_lints`, `total_lints` 가 기본 파일에 `*.g.dart` 등을 넣는다. include 된 파일의 exclude glob 이 사용 프로젝트에 적용되고 로컬 exclude 와 합쳐짐을 확인했다 [실측] | LOW | 사용 프로젝트가 같은 exclude 를 다시 적을 필요가 없어진다 (`flutter_starter_kit` 은 현재 중복 선언 중) |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| "전부 켜고 일부만 끄기" (`total_lints` 방식) | 놓치는 규칙이 없다 | SDK 가 올라갈 때마다 새 규칙이 자동으로 들어와 예고 없이 진단이 늘어난다. "규칙마다 근거" 원칙과 정면으로 충돌 | 후보 표에서 골라 실측 후 명시적으로 켠다 |
| 버전별 옵션 파일 (`analysis_options.11.0.0.yaml`) | `very_good_analysis` 가 쓰는 방식이라 표준처럼 보인다 | pub.dev 패키지가 "최신 버전을 받되 규칙 세트는 고정"하려는 장치다. git tag 로 고정하면 같은 효과를 파일 복제 없이 얻는다 | `ref: vX.Y.Z` |
| SDK 버전별 파일 / 대응표 (`lint`, `total_lints`) | 여러 SDK 지원 | "최신 stable 만 지원" 결정(PROJECT.md Out of Scope)과 충돌. 이전 SDK 는 이전 tag 가 담당 | tag 와 지원 SDK 를 CHANGELOG 에 한 줄로 기록 |
| 자체 custom lint 규칙 (`leancode_lint`, `solid_lints`) | 팀 고유 관례 강제 | Dart 코드, analyzer API 추적, 테스트가 필요해진다. 설정 전용 패키지라는 정체성이 바뀐다 | 필요해지면 별도 패키지로 |
| experimental 규칙 활성화 | `lint` / `leancode_lint` 는 일부 켠다 | 동작과 이름이 바뀔 수 있다. `very_good_analysis` 는 "Experimental" 을 제외 사유로 명시 | stable 이 될 때까지 후보 목록에만 둔다 |
| Dart 3.13 primary constructor 문법 전환 규칙을 지금 켜기 | `very_good_analysis` 11.0.0 이 전부 켰다 | `unnecessary_type_name_in_constructor` 는 모든 생성자 선언에 진단을 낸다 [실측]. freezed / riverpod_generator 코드와의 호환은 확인하지 못했다 | 실측은 하되 기본 preset 에는 넣지 않는다. 문법 전환을 결정한 뒤 별도 릴리스로 |
| 기본 preset 에 `formatter:` 설정 넣기 | `very_good_analysis`(`automate`), `pedantic_mono`(`preserve`) 가 넣는다 | include 된 파일의 `formatter:` 가 사용 프로젝트의 `dart format` 결과를 바꾼다 [실측]. lint 패키지를 올렸더니 포맷 diff 가 대량 발생하는 부작용이 생긴다 | 넣지 않는다. 기본값이 `automate` 라 선언할 필요가 없다 |
| 기본 preset 에서 lint 를 일괄 warning / error 로 승격 | `leancode_lint` 는 거의 모든 규칙을 `warning` 으로 올린다 | 새 규칙 하나가 모든 사용 프로젝트의 CI 를 막는다. "프로젝트마다 올리는 시점을 고른다"는 결정과 충돌 | 엄격도는 사용 프로젝트 CI 의 `--fatal-infos` 로 정한다 |
| 전역 `invalid_annotation_target: ignore` 를 기본 preset 에 유지 | freezed README 가 권한다 | 최신 `json_annotation` 에서는 필요한 경우가 한 가지로 줄었다 [실측]. 모든 프로젝트에서 실제 annotation 실수를 가린다 | codegen preset 으로 옮기거나 삭제. "Riverpod and Codegen Settings" 참조 |
| 앱 대상 `public_member_api_docs` 를 기본으로 켜기 | 문서화 습관 | fix 가 없고, 앱의 모든 public 위젯·메서드에 진단이 난다. `lint` 는 "Maybe relevant for packages" 로 꺼 둔다 | 실측 후 건수가 감당 가능하면 opt-in preset 후보 |
| formatter 가 이미 처리하는 규칙 | 스타일 통일 | `require_trailing_commas` 는 language 3.7 이상에서 아무것도 보고하지 않는다 [실측]. `eol_at_end_of_file`, `lines_longer_than_80_chars` 는 `dart format` 과 역할이 겹친다 | 켜지 않는다 |
| README 에 badge, pub.dev 게시용 메타 | 다른 패키지가 다 한다 | pub.dev 미게시, 독자가 작성자 본인 | 생략 |

---

## Candidate Lint Rules (Section B)

`flutter_lints` 6.0.0 + `lints` 6.1.0 이 켜는 규칙은 102개다(`core` 35 + `recommended` 58 + `flutter` 10, 중복 1) [공식: 로컬 pub cache]. 아래는 **그 102개에 없는** 규칙만 다룬다.

**열 설명**

- **소음** — 기존 코드베이스에 처음 켰을 때의 예상 진단량 [추정]. 실측으로 대체할 값이다. 실측한 항목은 [실측] 으로 표시했다.
- **fix** — `linter_rules.json` 의 `fixStatus`. `O` = `hasFix`, `X` = `noFix`, `△` = `needsFix` / `needsEvaluation`(fix 미구현). `hasFix` 는 quick fix 가 있다는 뜻이며, 일괄 적용 가능 여부는 실측 때 `dart fix --dry-run` 으로 확인한다.
- **도입·상태** — 규칙이 추가된 Dart SDK 버전과 Dart 3.13 기준 상태. 표에 따로 적지 않은 규칙은 모두 stable 이다.
- **VGA** — `very_good_analysis` 11.0.0 (`analysis_options.11.0.0.yaml`) 이 켜는지.
- **채택** — 7개 세트(`very_good_analysis` 11.0.0, `lint` 2.14.0 `strict` / `casual`, `leancode_lint` 27.0.0, `pedantic_mono` 1.38.1, `solid_lints` 2.0.0, `total_lints` 3.13.0 `app`) 중 켜는 수. `total_lints` 는 "전부 켜기" 방식이라 가중치가 낮다.

### B-1. 버그 방지 — 실측 대상

| 규칙 | 잡는 것 | 소음 | fix | 도입·상태 | 충돌 | VGA | 채택 |
|---|---|---|---|---|---|---|---|
| `discarded_futures` | 동기 함수 안에서 Future 를 받지 않고 버리는 호출. `unawaited_futures` 는 async 본문만 본다 | 높음 — `onPressed`, `initState` 같은 동기 콜백의 `Navigator.push`, controller 호출이 대상 | O | 2.18 | 없음 (`unawaited_futures` 와 보완) | Y | 3/7 |
| `unnecessary_unawaited` | `@awaitNotRequired` 대상에 쓴 불필요한 `unawaited()` | 낮음 | O | 3.9 | 없음 | Y | 6/7 |
| `async_return_with_no_await` | async 함수가 Future 를 `await` 없이 그대로 return | 중간 — `return api.get(...)` 형태의 repository 메서드. 샘플에서 발생 확인 [실측] | O | 3.13 | deprecated 규칙 `unnecessary_await_in_return` 과 정반대 방향 | Y | 6/7 |
| `avoid_void_async` | `void f() async` (호출자가 await 할 수 없다) | 낮음~중간 | O | 2.1 | 없음 | Y | 7/7 |
| `cancel_subscriptions` | cancel 하지 않는 `StreamSubscription` | 낮음 | X | 2.0 | 없음 | Y | 6/7 |
| `avoid_dynamic_calls` | `dynamic` 대상의 메서드 호출·프로퍼티 접근 | 중간 — 손으로 쓴 JSON / Firebase payload 접근 | X | 2.12 | 없음 | Y | 7/7 |
| `cast_nullable_to_non_nullable` | nullable 값을 non-nullable 타입으로 `as` | 낮음 | O | 2.12 | 없음 | Y | 7/7 |
| `avoid_type_to_string` | `Type.toString()` 결과에 의존 (release 빌드에서 이름이 minify 될 수 있다) | 낮음 | X | 2.12 | 없음 | Y | 7/7 |
| `switch_on_type` | `switch (x.runtimeType)` | 낮음 | X | 3.9 | 없음 | Y | 6/7 |
| `test_types_in_equals` | `operator ==` 재정의에서 인자 타입 검사 누락 | 낮음 — freezed 가 `==` 를 생성 | X | 2.0 | 없음 | Y | 7/7 |
| `throw_in_finally` | `finally` 안의 `throw` | 낮음 | X | 2.0 | 없음 (`control_flow_in_finally` 와 보완) | Y | 7/7 |
| `no_self_assignments` | `x = x` | 낮음 | △ | 3.1 | 없음 | Y | 6/7 |
| `no_adjacent_strings_in_list` | 리스트 안의 인접 문자열 (쉼표 누락) | 낮음 | △ | 2.0 | 없음 | Y | 7/7 |
| `missing_whitespace_between_adjacent_strings` | 이어 붙인 문자열 사이 공백 누락 | 낮음 | △ | 2.8 | 없음 | Y | 4/7 |
| `unnecessary_statements` | 효과가 없는 문장 | 낮음 | X | 2.0 | 없음 | Y | 7/7 |
| `literal_only_boolean_expressions` | 리터럴만으로 이루어진 조건식 | 낮음. `lint` 는 `while (true)` 오탐을 이유로 꺼 둔다 | X | 2.0 | 없음 | Y | 5/7 |
| `avoid_unused_constructor_parameters` | 쓰이지 않는 생성자 매개변수 | 낮음 | O | 2.0 | 없음 | Y | 7/7 |
| `parameter_assignments` | 매개변수 재할당 | 낮음~중간 | X | 2.0 | 없음 | Y | 7/7 |
| `avoid_catching_errors` | `Error` 계열을 명시적으로 catch | 낮음 | X | 2.0 | 없음 | Y | 6/7 |
| `only_throw_errors` | `Exception` / `Error` 가 아닌 값을 throw | 낮음 | X | 2.0 | 없음 | Y | 4/7 |
| `always_use_package_imports` | `lib/` 안의 relative import | 현재 import 스타일에 따라 0 또는 높음. 전부 자동 수정 | O | 2.10 | `prefer_relative_imports` 와 양립 불가 [실측] | Y | 5/7 |
| `prefer_relative_imports` | `lib/` 안의 `package:` import | 위와 같음 (방향만 반대) | O | 2.6 | `always_use_package_imports` 와 양립 불가 [실측] | N | 1/7 |
| `conditional_uri_does_not_exist` | 조건부 import 가 가리키는 파일이 없음 | 낮음 | X | 2.16 | 없음 | Y | 6/7 |
| `deprecated_member_use_from_same_package` | 같은 패키지 안에서 deprecated 멤버 사용 | 낮음 | O | 3.0 | 없음 | Y | 3/7 |
| `matching_super_parameters` | super 매개변수 이름이 부모 생성자와 다름 (순서 착오) | 낮음 | △ | 3.0 | 없음 | Y | 3/7 |
| `avoid_equals_and_hash_code_on_mutable_classes` | `@immutable` 이 아닌 클래스의 `==` / `hashCode` 재정의 | 낮음 | X | 2.6 | 없음 | Y | 2/7 |
| `avoid_implementing_value_types` | `==` 를 재정의한 클래스를 `implements` | 낮음. `very_good_analysis` 는 테스트 mock/fake 때문에 제외 | X | 2.1 | 없음 | N | 6/7 |
| `avoid_double_and_int_checks` | web 에서 뜻이 달라지는 `is double` / `is int` 검사 | 낮음 (모바일 전용 앱에는 무관) | △ | 2.0 | 없음 | Y | 7/7 |
| `avoid_js_rounded_ints` | JavaScript 에서 정밀도가 깨지는 정수 리터럴 | 낮음 (위와 같음) | X | 2.0 | 없음 | Y | 4/7 |

`always_use_package_imports` 와 `prefer_relative_imports` 는 둘 중 하나만 고른다. `flutter_starter_kit` 이 현재 어느 스타일인지 세어 보고 다수 쪽을 택하면 진단이 최소가 된다.

`lints` 7.0.0-wip (미릴리스) CHANGELOG 는 `switch_on_type` 을 `core` 에, `unnecessary_unawaited` · `simple_directive_paths` · `simplify_variable_pattern` 을 `recommended` 에 추가한다고 적고 있다 [공식]. 이 네 규칙은 기반 세트에 곧 들어올 가능성이 높으므로, 지금 켜면 다음 `flutter_lints` 메이저 때 중복 선언이 된다.

### B-2. 성능 — 실측 대상

| 규칙 | 잡는 것 | 소음 | fix | 도입·상태 | 충돌 | VGA | 채택 |
|---|---|---|---|---|---|---|---|
| `prefer_const_declarations` | `const` 로 선언할 수 있는 `final` | 중간. 전부 자동 수정 | O | 2.0 | 없음 | Y | 6/7 |
| `use_colored_box` | 색만 지정한 `Container` | 낮음 | O | 2.17 | 없음 | Y | 5/7 |
| `sized_box_shrink_expand` | `SizedBox.shrink` / `.expand` 로 쓸 수 있는 `SizedBox` | 낮음 | △ | 2.16 | 없음 | Y | 7/7 |
| `use_string_buffers` | 루프 안의 문자열 누적 연결 | 낮음 | △ | 2.0 | 없음 | Y | 7/7 |
| `no_runtimetype_tostring` | `runtimeType` 의 `toString()` (문자열 보간 포함) | 낮음~중간 — 로깅, `toString()` 구현 | X | 2.8 | `very_good_analysis` 는 옛 표기 `no_runtimeType_toString` 을 쓴다. 같은 규칙이며 두 표기를 함께 적으면 `duplicate_rule` [실측] | Y | 6/7 |
| `avoid_slow_async_io` | 느린 `dart:io` async 메서드 | 낮음 | △ | 2.0 | 없음 | Y | 4/7 |
| `noop_primitive_operations` | 효과 없는 원시 타입 연산 (`string.toString()` 등) | 낮음 | O | 2.14 | 없음 | Y | 7/7 |
| `use_truncating_division` | `(a / b).toInt()` | 낮음 | O | 3.6 | 없음 | Y | 6/7 |

`prefer_const_declarations` 는 `flutter_lints` 5.0.0 이 `prefer_const_constructors`, `prefer_const_literals_to_create_immutables` 와 함께 제거한 세 규칙 중 하나다 [공식]. 배경은 "Existing Rules Under Review" 참조.

### B-3. 가독성·스타일 — 실측 대상

대부분 `dart fix --apply` 로 일괄 수정된다. 건수보다 "이 스타일을 원하는가"가 판단 기준이다.

| 규칙 | 잡는 것 | 소음 | fix | 도입·상태 | 충돌 | VGA | 채택 |
|---|---|---|---|---|---|---|---|
| `prefer_final_in_for_each` | 재할당하지 않는 for-in 변수에 `final` 누락 | 중간 | O | 2.1 | `unnecessary_final` 과 양립 불가 [실측] | Y | 7/7 |
| `avoid_final_parameters` | 매개변수 선언의 `final` | 낮음 | O | 2.16 | deprecated 규칙 `prefer_final_parameters` 와 양립 불가 [실측] | Y | 7/7 |
| `type_annotate_public_apis` | 타입 표기가 없는 공개 API | 낮음 | O | 2.0 | `omit_obvious_property_types` 와 양립 불가 [실측] | Y | 6/7 |
| `directives_ordering` | import / export 정렬 규칙 위반 | 높음(초기). 전부 자동 수정 | O | 2.0 | 없음 | Y | 6/7 |
| `combinators_ordering` | `show` / `hide` 이름 정렬 | 낮음 | O | 2.19 | 없음 | Y | 5/7 |
| `avoid_redundant_argument_values` | 기본값과 같은 값을 명시한 인자 | 중간~높음 — 위젯에 기본값을 명시해 둔 곳 | O | 2.8 | 없음 | Y | 7/7 |
| `unnecessary_lambdas` | tear-off 로 대체 가능한 람다 | 중간. `lint` 는 `setState` 와 제네릭 전달 문제로 꺼 둔다 | O | 2.0 | 없음 | Y | 5/7 |
| `unnecessary_parenthesis` | 불필요한 괄호 | 낮음 | O | 2.0 | 없음 | Y | 7/7 |
| `unnecessary_breaks` | 불필요한 `break` | 낮음 | O | 3.0 | 없음 | Y | 7/7 |
| `unnecessary_null_checks` | nullable 을 받는 자리에 쓴 `!` | 낮음 | O | 2.12 | 없음 | Y | 7/7 |
| `unnecessary_null_aware_operator_on_extension_on_nullable` | nullable 대상 extension 에 쓴 불필요한 `?.` | 낮음 | O | 2.18 | 없음 | Y | 6/7 |
| `unnecessary_raw_strings` | 불필요한 raw string | 낮음 | O | 2.8 | 없음 | Y | 6/7 |
| `use_raw_strings` | escape 대신 raw string 사용 가능 | 낮음 | O | 2.8 | 없음 | Y | 4/7 |
| `unnecessary_library_directive` | 문서·annotation 없는 `library;` | 낮음 | O | 2.19 | 없음 | Y | 6/7 |
| `unnecessary_ignore` | 더 이상 발생하지 않는 진단에 대한 `// ignore` | 낮음. 규칙 세트를 바꾸는 이번 작업 뒤 정리에 유용 | O | 3.8 | 없음 | Y | 6/7 |
| `document_ignores` | 사유 주석이 없는 `// ignore` | 기존 ignore 수만큼 | △ | 3.5 | 없음 | Y | 3/7 |
| `avoid_bool_literals_in_conditional_expressions` | `cond ? true : false` 류 | 낮음 | O | 2.0 | 없음 | Y | 7/7 |
| `no_literal_bool_comparisons` | `x == true` | 낮음 | O | 3.0 | 없음 | Y | 5/7 |
| `prefer_if_elements_to_conditional_expressions` | 컬렉션 안의 삼항 대신 `if` 요소 | 낮음 | O | 2.3 | 없음 | Y | 6/7 |
| `prefer_null_aware_method_calls` | `if (f != null) f!()` → `f?.call()` | 낮음 | △ | 2.14 | 없음 | Y | 6/7 |
| `prefer_int_literals` | double 문맥의 `1.0` → `1` | 중간 — Flutter 수치 리터럴 | O | 2.1 | 없음 | Y | 4/7 |
| `avoid_multiple_declarations_per_line` | 한 줄에 변수 여러 개 선언 | 낮음 | O | 2.13 | 없음 | Y | 6/7 |
| `avoid_escaping_inner_quotes` | 바깥 따옴표를 바꾸면 없앨 수 있는 escape | 낮음. `prefer_single_quotes` 와 함께 쓰는 보완 규칙 | O | 2.8 | 없음 | Y | 4/7 |
| `leading_newlines_in_multiline_strings` | 여러 줄 문자열을 개행으로 시작 | 낮음 | O | 2.8 | 없음 | Y | 6/7 |
| `use_enums` | enum 처럼 쓰는 클래스 | 낮음 | O | 2.17 | 없음 | Y | 7/7 |
| `use_named_constants` | `Duration(seconds: 0)` 대신 `Duration.zero` | 낮음 | O | 2.13 | 없음 | Y | 7/7 |
| `use_is_even_rather_than_modulo` | `% 2 == 0` | 낮음 | △ | 2.9 | 없음 | Y | 6/7 |
| `tighten_type_of_initializing_formals` | `assert(p != null)` 대신 매개변수 타입으로 표현 | 낮음 | △ | 2.12 | 없음 | Y | 7/7 |
| `join_return_with_assignment` | 대입 직후 return | 낮음 | △ | 2.0 | 없음 | Y | 5/7 |
| `prefer_asserts_in_initializer_lists` | 생성자 본문의 assert | 낮음 | △ | 2.0 | 없음 | Y | 6/7 |
| `prefer_constructors_over_static_methods` | 인스턴스를 만드는 static 메서드 | 낮음 | △ | 2.0 | 없음 | Y | 6/7 |
| `sort_unnamed_constructors_first` | 이름 없는 생성자를 먼저 | 낮음 | O | 2.0 | 없음 | Y | 6/7 |
| `sort_constructors_first` | 생성자를 다른 멤버보다 먼저 | 중간. `lint` 는 "too opinionated" 로 꺼 둔다 | O | 2.0 | 없음 | Y | 3/7 |
| `sort_pub_dependencies` | `pubspec.yaml` 의존성 알파벳 순 | 낮음 (프로젝트당 파일 1개) | O | 2.1 | 없음 | Y | 6/7 |
| `avoid_setters_without_getters` | getter 없는 setter | 낮음 | △ | 2.0 | 없음 | Y | 6/7 |
| `use_setters_to_change_properties` | 프로퍼티를 바꾸는 메서드 | 낮음 | X | 2.0 | 없음 | Y | 6/7 |
| `use_test_throws_matchers` | `fail()` 대신 `throwsA` | 낮음 (test 코드) | △ | 2.14 | 없음 | Y | 7/7 |
| `simple_directive_paths` | `./`, 되돌아가는 `../` 가 낀 directive 경로 | 낮음 | O | 3.12 | 없음 | Y | 5/7 |
| `simplify_variable_pattern` | 변수 pattern 의 중복 멤버 이름 | 낮음 | O | 3.11 | 없음 | Y | 5/7 |
| `specify_nonobvious_property_types` | 타입이 자명하지 않은 top-level / static 변수의 타입 누락 | 낮음 | O | 3.7 | 없음 | Y | 2/7 |
| `omit_obvious_local_variable_types` | 타입이 자명한 지역 변수의 타입 표기 | 낮음 | O | 3.6 | `always_specify_types` 와 양립 불가 [실측] | N | 3/7 |
| `flutter_style_todos` | `// TODO(user): ...` 형식 | 기존 TODO 수만큼 | O | 2.1 | 없음 | Y | 3/7 |

### B-4. Dart 3.13 신규 규칙 — 별도 판단

Dart 3.13 은 primary constructor 를 도입했고 [공식: SDK CHANGELOG], 아래 규칙 대부분은 그 문법으로의 전환을 유도한다. 최소 Flutter 샘플(enum 1, 일반 클래스 2, 위젯·State 클래스 3)로 확인한 결과를 함께 적는다 [실측].

| 규칙 | 잡는 것 | 소음 | fix | 도입·상태 | 충돌·주의 | VGA | 채택 |
|---|---|---|---|---|---|---|---|
| `unnecessary_type_name_in_constructor` | 생성자 선언의 타입 이름 (`C();` → `new();`) | **매우 높음** — 샘플의 생성자 선언 5개 전부. 위젯의 `const MyWidget({super.key})` 포함 [실측] | O | 3.13 | freezed factory 생성자, riverpod_generator 클래스와의 호환 미확인 | Y | 6/7 |
| `migrate_design_widgets` | `package:flutter/material.dart` / `cupertino.dart` import (deprecated 로 표시) | **매우 높음** — material 을 import 하는 모든 파일 [실측] | O | 3.13 | 3.13.1 에서 `dart fix` 가 export 문도 처리하도록 수정됨 [공식] | N | 1/7 |
| `empty_container_bodies` | 빈 본문 `{}` → `;` | 중간 — 빈 클래스마다 1건 [실측] | O | 3.13 | 없음 | Y | 5/7 |
| `unnecessary_const_in_enum_constructor` | enum 생성자의 `const` | enhanced enum 마다 1건 [실측] | O | 3.13 | `very_good_analysis` README 의 제외 표에는 있으나 11.0.0 YAML 은 켠다 (README 가 뒤처짐) | Y | 5/7 |
| `use_declaring_parameters` | declaring parameter 를 쓸 수 있는 곳 | 샘플에서 0건 [실측]. primary constructor 를 쓴 코드에만 해당하는 것으로 보인다 [추정] | O | 3.13 | 없음 | Y | 6/7 |
| `initialize_in_field_declaration` | 선언부에서 초기화할 수 있는 필드 | 샘플에서 0건 [실측] | O | 3.13 | `very_good_analysis` README 제외 표와 YAML 불일치 (위와 같음) | Y | 6/7 |
| `unnecessary_primary_constructor_body` | 빈 primary constructor body | primary constructor 미사용 코드에서는 0 [추정] | O | 3.13 | 없음 | Y | 6/7 |
| `no_dynamic_casts` | `dynamic` 에서의 암묵적 cast | "Analyzer Strict Modes" 참조 | △ | 3.13 | `strict-casts` 의 대체 [공식] | N | 2/7 |
| `no_raw_types` | 타입 인자를 생략한 제네릭 타입 | "Analyzer Strict Modes" 참조 | △ | 3.13 | `strict-raw-types` 의 대체 [공식] | N | 2/7 |

`migrate_design_widgets` 는 문서 본문이 한 줄뿐이라, 대체 패키지가 무엇이고 Flutter 3.47 에서 이전이 가능한 상태인지는 확인하지 못했다. **켜기 전에 Flutter 쪽 이전 안내를 따로 조사해야 한다.**

### B-5. API 문서 — 실측 대상

| 규칙 | 잡는 것 | 소음 | fix | 도입·상태 | 충돌 | VGA | 채택 |
|---|---|---|---|---|---|---|---|
| `public_member_api_docs` | 문서 주석이 없는 공개 멤버 | 높음 — 앱의 public 클래스·메서드·필드 대부분 | X | 2.0 | 없음 | Y | 2/7 |
| `comment_references` | doc comment 의 `[이름]` 이 scope 에 없음 | 중간. `lint` 는 오탐 이력을 이유로 꺼 둔다 | O | 2.0 | 없음 | Y | 5/7 |
| `missing_code_block_language_in_doc_comment` | 언어를 지정하지 않은 doc comment 코드 블록 | 낮음 | △ | 3.4 | 없음 | Y | 5/7 |
| `deprecated_consistency` | `@Deprecated` 를 클래스·생성자·필드에 일관되게 붙이지 않음 | 낮음 | △ | 2.13 | 없음 | Y | 6/7 |

`public_member_api_docs` 는 작성자의 전역 코딩 기준("공개 함수·클래스·모듈에는 반드시 Docstring 작성")과 일치하는 유일한 규칙이다. 소음이 크다는 이유만으로 빼지 말고 건수를 실측한 뒤, 기본 preset 이 아닌 opt-in 으로 둘지 판단한다.

### B-6. 제외 권장 — 실측하지 않아도 되는 규칙

| 규칙 | 상태 | 제외 사유 |
|---|---|---|
| `require_trailing_commas` | stable | language 3.7 이상에서 보고하지 않는다 [실측]. "Existing Rules Under Review" 참조 |
| `eol_at_end_of_file` | stable | `dart format` 이 이미 보장한다 [추정] |
| `lines_longer_than_80_chars` | stable | 줄바꿈은 formatter 담당. fix 없음. `lint` 는 "too hard to be a general rule" 로 제외 |
| `always_put_control_body_on_new_line` | stable | formatter 와 충돌할 수 있다 (`very_good_analysis` 제외 사유) |
| `always_specify_types` | stable | `avoid_types_on_closure_parameters`, `omit_local_variable_types`, `omit_obvious_local_variable_types`, `omit_obvious_property_types` 와 양립 불가 [실측]. 채택 0/7 |
| `prefer_double_quotes` | stable | `prefer_single_quotes` 와 양립 불가 [실측] |
| `unnecessary_final` | stable | `prefer_final_locals`, `prefer_final_in_for_each` 와 양립 불가 [공식]. 후자와의 충돌은 analyzer 출력으로도 확인 [실측] |
| `omit_local_variable_types` | stable | `specify_nonobvious_local_variable_types` 와 양립 불가 [실측]. 취향 규칙, 채택 2/7 |
| `specify_nonobvious_local_variable_types` | stable | 위 규칙과 양립 불가. 채택 0/7 |
| `omit_obvious_property_types` | stable | `type_annotate_public_apis` 와 양립 불가 [실측] |
| `avoid_types_on_closure_parameters` | stable | 취향 규칙, 채택 3/7. 필요하면 B-3 로 옮겨 실측 |
| `always_put_required_named_parameters_first` | stable | Flutter 의 `super.key` 관례와 어긋난다 (`lint` 제외 사유). 채택 1/7 |
| `avoid_catches_without_on_clauses` | stable | 앱 코드에서 `catch (e)` 는 흔하다. fix 없음. `lint` 는 "very strict" 로 제외 |
| `avoid_positional_boolean_parameters` | stable | `void Function(bool)` 콜백에서 오탐 (`lint` 제외 사유). fix 없음 |
| `avoid_classes_with_only_static_members` | stable | 상수 모음 클래스가 흔하다. fix 없음. 채택 2/7 |
| `avoid_annotating_with_dynamic` | stable | 채택 0/7 |
| `avoid_returning_this`, `use_to_and_as_if_applicable`, `prefer_mixin`, `prefer_asserts_with_message`, `avoid_field_initializers_in_const_classes` | stable | API 설계 취향 규칙. 대부분 fix 없음. 앱 코드에서 실익이 작다 [추정] |
| `prefer_foreach`, `cascade_invocations`, `prefer_expression_function_bodies` | stable | "더 빽빽한 코드"를 강제한다. `lint` 는 셋 다 제외, `very_good_analysis` 는 10.1.0 에서 `prefer_expression_function_bodies` 를 제거 |
| `close_sinks` | stable | 해결되지 않은 오탐 (`very_good_analysis`, `lint` 공통 제외 사유) |
| `prefer_void_to_null` | stable | 해결되지 않은 오탐 (`very_good_analysis` 제외 사유) |
| `use_decorated_box` | stable | 오동작 이슈 (`very_good_analysis`, `lint` 공통 제외 사유) |
| `unreachable_from_main` | stable | `very_good_analysis` 가 10.3.0 에서 기본 비활성으로 전환 |
| `diagnostic_describe_all_properties` | stable | Flutter framework 개발용. 채택 0/7 |
| `do_not_use_environment` | stable | `--dart-define` 을 쓰는 앱은 전부 걸린다. 채택 1/7 |
| `library_names`, `package_prefixed_library_names` | stable | `unnecessary_library_name`(기반 세트에 포함)으로 대체됨 (`very_good_analysis` 제외 사유) |
| `remove_deprecations_in_breaking_versions` | stable | 버전을 가진 배포 패키지용. 앱에는 의미가 없다 |

### B-7. 켜면 안 되는 규칙 — deprecated / removed / 3.13 미지원 / experimental

**deprecated (6개)** — 켜면 `deprecated_lint` 경고 [실측]:
`avoid_null_checks_in_equality_operators`, `avoid_private_typedef_functions`, `one_member_abstracts`, `prefer_final_parameters`, `unnecessary_await_in_return`, `use_if_null_to_convert_nulls_to_bools`.
`avoid_private_typedef_functions` 와 `one_member_abstracts` 는 Dart 3.13 에서, `prefer_final_parameters` 는 3.11 에서 deprecated 가 되었다 [공식: SDK CHANGELOG].

**removed (14개)** — 켜면 `removed_lint` 경고 [실측]:
`always_require_non_null_named_parameters`, `avoid_as`, `avoid_returning_null`, `avoid_returning_null_for_future`, `avoid_unstable_final_fields`, `enable_null_safety`, `invariant_booleans`, `iterable_contains_unrelated_type`, `list_remove_unrelated_type`, `package_api_docs`, `prefer_bool_in_asserts`, `prefer_equal_for_default_values`, `super_goes_last`, `unsafe_html`.

**Dart 3.13 에 없는 규칙 (2개)** — dart.dev 목록에는 있으나 3.14 도입이라 3.13.4 에서 `undefined_lint` [실측]:
`future_sync_value`, `unnecessary_this_alias`.
dart.dev 의 규칙 목록은 SDK main 을 따라간다. **목록에 있다고 지원 SDK 에 있는 것이 아니므로 `sinceDartSdk` 를 반드시 확인한다.**

**experimental (stable 이 될 때까지 보류)**:
`annotate_redeclares`, `avoid_futureor_void`, `implicit_reopen`, `invalid_case_patterns`, `no_default_cases`, `unnecessary_async`, `unsafe_variance`, `use_late_for_private_fields_and_variables`, `var_with_no_type_annotation`.
참고로 기반 세트의 `use_super_parameters` 도 목록상 experimental 이지만 `recommended` 에 이미 들어 있다.

**문서로 확인하지 못한 규칙**: `use_primary_constructors` — SDK 3.13 CHANGELOG 는 experimental 규칙으로 추가했다고 적고 있고 3.13.4 analyzer 도 이름을 인식하지만 [실측], dart.dev 규칙 목록 JSON 에는 항목이 없다. 켜지 않는다.

---

## Existing Rules Under Review (Section C)

### 현재 선언된 12개 규칙

| 규칙 | 기반 세트가 이미 켜는가 | 여전히 권장되는가 | 비고 |
|---|---|---|---|
| `prefer_const_constructors` | 아니오. `flutter_lints` 5.0.0 이 제거 [공식] | 의견이 갈린다. 채택 6/7 | 아래 "const 규칙의 근거" 참조 |
| `prefer_const_literals_to_create_immutables` | 아니오. 같은 버전에서 제거 | 위와 같음. 채택 6/7 | 위와 같음 |
| `sized_box_for_whitespace` | **예** (`flutter.yaml`) | 예 | 중복 선언 |
| `always_declare_return_types` | 아니오 | 예. 채택 7/7 | 기반 세트의 `strict_top_level_inference` 와 부분 중복. 아래 참조 [실측] |
| `sort_child_properties_last` | **예** (`flutter.yaml`) | 예 | 중복 선언 |
| `prefer_final_locals` | 아니오 | 예. 채택 7/7 | `unnecessary_final` 과 양립 불가. 짝 규칙 `prefer_final_in_for_each` 가 후보에 있다 |
| `prefer_single_quotes` | 아니오 | 취향. 채택 4/7 | `lint` 는 "doesn't define a style" 로 제외. `prefer_double_quotes` 와 양립 불가. 보완 규칙 `avoid_escaping_inner_quotes` 가 후보에 있다 |
| `slash_for_doc_comments` | **예** (`recommended.yaml`) | 예 | 중복 선언 |
| `use_build_context_synchronously` | **예** (`flutter.yaml`) | 예 | 중복 선언 |
| `unawaited_futures` | 아니오 | 예. 채택 5/7 | `lint` 는 꺼 둔다. 짝 규칙 `unnecessary_unawaited`, 범위 확장 규칙 `discarded_futures` 가 후보에 있다. Dart 3.9 에서 `@awaitNotRequired` 지원이 추가되었다 [공식] |
| `avoid_print` | **예** (`flutter.yaml`) | 예 | 중복 선언 |
| `control_flow_in_finally` | **예** (`recommended.yaml`) | 예 | 중복 선언. 보완 규칙 `throw_in_finally` 가 후보에 있다 |

**중복 선언 6개의 처리.** 삭제를 권한다. `flutter_lints` 가 `^6.0.0` 으로 묶여 있어 규칙이 빠지려면 메이저가 올라가야 하고, 메이저를 올릴 때는 어차피 릴리스 노트를 확인한다. 선언을 남기면 "이 패키지가 실제로 더하는 것"이 흐려진다. 기반 세트와의 중복은 analyzer 가 경고하지 않으므로 [실측] 사람이 관리해야 한다.

**const 규칙의 근거.** `flutter_lints` 5.0.0 은 `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables` 를 제거했다 [공식: flutter_lints CHANGELOG]. 근거 issue(dart-lang/lints#205)의 제안 요지는 "benchmark 에서 뚜렷한 실익이 확인되지 않는데 개발 중 계속 거슬린다"는 것이고, 반대 의견(성능 저하 사례 보고)도 같은 issue 에 있다. 커뮤니티 세트는 대부분 계속 켠다(6/7). 유지 자체는 무리가 없지만, 현재 주석의 사유("위젯 재사용을 극대화하여 성능 향상")는 Flutter 팀이 근거 부족으로 본 주장이므로 **사유 문구를 고쳐 써야 한다**. 기존 코드는 이미 이 규칙을 따르고 있어 유지해도 새 진단은 없다 [추정].

**`always_declare_return_types` 와 `strict_top_level_inference` 의 중복 [실측].** 반환 타입이 없는 선언 6종으로 비교했다.

| 선언 위치 | `strict_top_level_inference` (기반 세트) | `always_declare_return_types` |
|---|---|---|
| top-level 함수 | 보고 | 보고 |
| instance / static 메서드, getter | 보고 | 보고 |
| 지역 함수 (local function) | 보고 안 함 | 보고 |
| 옛 문법 typedef | 보고 안 함 | 보고 |

유지하면 흔한 경우에 같은 위치로 진단 두 개가 나오고, 고유하게 더하는 범위는 지역 함수와 옛 typedef 다. 유지한다면 사유를 "지역 함수의 반환 타입까지 강제" 로 적는다.

### 주석 처리된 설정 3개

**`require_trailing_commas`**

- 규칙은 stable 이고 fix 도 있다 [공식]. 그러나 **language version 3.7 이상인 라이브러리에서는 아무것도 보고하지 않는다** [실측].
  - Dart 3.13.4 에서 포맷하지 않은 코드(여러 줄로 쪼갠 인자 + trailing comma 없음)에 켰을 때 0건.
  - 같은 코드에 `// @dart=3.6` 을 붙이면 2건 보고.
  - `formatter: trailing_commas: preserve` 를 함께 써도 3.13 코드에서는 0건.
- 배경: tall style formatter(language 3.7 부터)가 여러 줄로 나뉘는 인자·매개변수 목록에 trailing comma 를 직접 넣고, 한 줄에 들어가면 뺀다. 규칙이 formatter 와 어긋나게 되어 linter 가 3.7 이상에서 보고를 중단했다 (dart-lang/sdk#60119).
- `very_good_analysis` 11.0.0, `solid_lints`, `total_lints` 는 여전히 켜 두지만 (3/7), Dart 3.13 이상만 지원하는 이 패키지에서는 죽은 설정이다. `lint` 는 "Removed for Dart 3.7" 로 제외했다.
- **권고: 삭제.** CHANGELOG 와 README 에 "formatter 가 대신한다"는 사유를 남긴다.

**`public_member_api_docs`**

- stable, fix 없음. 문서 주석이 없는 모든 공개 멤버를 보고한다 [공식].
- 채택 2/7 (`very_good_analysis`, `solid_lints`). `very_good_analysis` 는 자기 example 에서조차 이 규칙을 끈다.
- 앱 프로젝트에서는 진단이 가장 많이 나오는 규칙 중 하나가 된다 [추정].
- **권고: 기본 preset 에서는 삭제하고 실측 대상에 포함.** 작성자의 코딩 기준과 맞는 규칙이라, 건수를 보고 opt-in preset 으로 둘지 정한다.

**`formatter: trailing_commas: preserve`**

- `formatter:` 는 `analysis_options.yaml` 의 최상위 키로 `dart format` 을 설정한다. `trailing_commas` 의 유효 값은 `automate` 와 `preserve` 둘뿐이며 다른 값은 `invalid_option` 경고 [실측].
  - `automate` (기본값): 구조가 여러 줄로 나뉘면 trailing comma 를 넣고, 한 줄에 들어가면 뺀다.
  - `preserve`: 이미 있는 trailing comma 를 지우지 않고, 그 구조를 강제로 여러 줄로 나눈다. 넣기는 `automate` 와 같다.
- formatter 설정은 language 3.7 이상, `trailing_commas` 는 3.8 이상이 필요하다 [공식].
- **include 된 패키지 파일의 `formatter:` 가 사용 프로젝트의 `dart format` 결과에 적용된다** [실측]. 공유 파일에 `preserve` 를 두면 사용 프로젝트의 포맷 결과가 바뀐다.
- **권고: 삭제하고 기본 preset 에 `formatter:` 를 두지 않는다.** 기본값이 `automate` 다. 손으로 넣은 trailing comma 로 위젯 트리를 강제로 펼치고 싶은 프로젝트만 자기 파일에 `preserve` 를 적도록 README 에 안내한다.

---

## Analyzer Strict Modes (Section D)

`analyzer: language:` 아래에 두며 셋 다 기본값은 `false` 다 [공식]. 한 샘플 파일로 각 모드의 출력을 확인했다 [실측].

| 모드 | 잡는 것 | 출력 (Dart 3.13.4) | 소음 [추정] | 채택 (커뮤니티 6개 패키지) |
|---|---|---|---|---|
| `strict-casts` | `dynamic` 에서 구체 타입으로의 암묵적 cast. 예: `final int v = jsonDecode(s);`, `takesList(jsonDecode(s))`, `if (json['flag'])` | **error** — `invalid_assignment`, `argument_type_not_assignable`, `non_bool_condition` | 중간. 손으로 쓴 JSON / platform channel / Firebase payload 코드에 집중된다. json_serializable 로 생성한 부분은 exclude 대상 | 5/6 (`very_good_analysis`, `lint`, `leancode_lint`, `pedantic_mono`, `solid_lints`) |
| `strict-raw-types` | 타입 인자를 생략한 제네릭 타입. 예: `List raw`, `Map m`, `Future f` | warning — `strict_raw_type` | 낮음~중간 | 4/6 (`very_good_analysis`, `leancode_lint`, `pedantic_mono`, `solid_lints`) |
| `strict-inference` | 추론 실패로 `dynamic` 이 되는 곳. 예: `final empty = [];`, `{}`, `Future.delayed(...)`, 타입 없는 매개변수·반환 | warning — `inference_failure_on_collection_literal`, `inference_failure_on_instance_creation`, `inference_failure_on_function_return_type`, `inference_failure_on_untyped_parameter` | 중간. `Future.delayed`, `showDialog`, `Navigator.push` 처럼 타입 인자를 생략하는 Flutter 호출이 대상 | 3/6 (`very_good_analysis`, `leancode_lint`, `pedantic_mono`) |

`flutter_lints` / `lints` 는 셋 다 켜지 않는다.

**Dart 3.13 의 변화 [공식: SDK CHANGELOG 3.13.0].** "`no_raw_types` lint 가 `strict-raw-types` 옵션을 대체하고, `no_dynamic_casts` lint 가 `strict-casts` 옵션을 대체한다"고 적혀 있다. `strict-inference` 의 대체 lint 는 언급이 없다. 같은 샘플로 비교한 결과 [실측]:

| | 옵션 형태 | lint 형태 |
|---|---|---|
| 보고 위치 | `strict-casts` 5곳, `strict-raw-types` 3곳 | `no_dynamic_casts` 같은 5곳, `no_raw_types` 같은 3곳 |
| 심각도 | error / warning | 둘 다 info |
| 끄는 단위 | 모드 전체 | 규칙 단위 (`linter.rules`, `// ignore: no_dynamic_casts`) |
| Dart 3.13.4 에서 deprecated 경고 | 없음 | 해당 없음 |

옵션 형태는 3.13.4 에서 경고 없이 동작한다. 언제 deprecated 가 되는지는 확인하지 못했다.

**권고.**

1. 실측은 lint 형태(`no_dynamic_casts`, `no_raw_types`)와 `strict-inference` 로 한다. 공식 대체 경로이고, info 심각도라 다른 규칙과 같은 방식으로 건수를 세고 끌 수 있다.
2. `strict-casts` 옵션은 **error** 를 낸다. 공유 파일에 넣으면 버전을 올리는 순간 사용 프로젝트의 `dart analyze` 가 실패한다. 넣는다면 lint 형태로 넣는다.
3. `strict-inference` 를 켜면 `*.g.dart` exclude 가 사실상 필수다. json_serializable 은 자기 저장소의 생성 코드에서 `inference_failure_on_function_invocation`, `inference_failure_on_collection_literal` 을 ignore 하고 있고 [공식: json_serializable `build.yaml`], json_serializable 만으로 생성된 `.g.dart` 에는 `ignore_for_file` 헤더가 없다 [`flutter_starter_kit` 의 생성 파일 확인].

---

## Riverpod and Codegen Settings (Section E)

### riverpod_lint 3.x

- 최신 3.1.9 (2026-09-04) 는 Dart 3.13 이상을 요구한다. 이전 SDK 에서는 plugin 이 `dart analyze` 를 멈추게 했고, 3.1.9 부터는 버전 해석 단계에서 실패한다 [공식: riverpod_lint CHANGELOG].
- 진단은 15개이고 **전부 `registerWarningRule` 로 등록되어 기본으로 켜진다** [공식: `lib/main.dart`]. dart.dev 는 "plugin 의 warning 은 기본 활성, lint 는 기본 비활성"이라고 설명한다 [공식].

| 진단 코드 | 심각도 | 대상 | 잡는 것 |
|---|---|---|---|
| `missing_provider_scope` | warning | 전체 | `runApp` 에 `ProviderScope` 가 없음 |
| `provider_parameters` | warning | 전체 | family 인자로 `==` 를 재정의하지 않은 non-const 값 전달 |
| `avoid_public_notifier_properties` | (코드에 명시 없음) | 전체 | Notifier 의 public 프로퍼티·getter |
| `protected_notifier_properties` | (코드에 명시 없음) | 전체 | 다른 Notifier 의 `state` 를 바깥에서 사용 |
| `avoid_ref_inside_state_dispose` | warning | 전체 | `State.dispose` 안의 `ref` 사용 |
| `async_value_nullable_pattern` | warning | 전체 | nullable 데이터를 가진 `AsyncValue` 의 잘못된 pattern |
| `provider_dependencies` | warning | generator | `dependencies` 목록 누락·불일치 |
| `scoped_providers_should_specify_dependencies` | warning | generator | scoped provider 의 `dependencies` 미지정 |
| `avoid_build_context_in_providers` | (코드에 명시 없음) | generator | provider 에 `BuildContext` 전달 |
| `unsupported_provider_value` | warning | generator | 지원하지 않는 값 타입을 반환 |
| `functional_ref` | warning | generator | 함수형 provider 의 `Ref` 매개변수 형식 |
| `notifier_extends` | warning | generator | 클래스형 provider 의 `extends _$Name` 형식 |
| `notifier_build` | warning | generator | 클래스형 provider 의 `build` 메서드 누락 |
| `only_use_keep_alive_inside_keep_alive` | warning | generator | keepAlive provider 가 auto-dispose provider 에 의존 |
| `riverpod_syntax_error` | **error** | generator | `@riverpod` 문법 오류 |

README 에는 `only_use_keep_alive_inside_keep_alive` 항목이 없고 `avoid_keep_alive_dependency_inside_auto_dispose` 항목이 있다. 소스에 등록된 진단 코드는 전자뿐이다 [공식: 소스]. 같은 규칙의 옛 이름이 README 에 남은 것으로 보인다 [추정]. 설정에는 위 표의 이름을 쓴다.

**설정 방법 [공식 + 실측].**

```yaml
# 켜기 (version 축약형)
plugins:
  riverpod_lint: ^3.1.9

# 특정 진단 끄기 (version 키로 풀어 쓴다)
plugins:
  riverpod_lint:
    version: ^3.1.9
    diagnostics:
      provider_parameters: false
```

```dart
// 한 줄 / 파일 단위 억제는 plugin 이름을 접두사로 붙인다
// ignore: riverpod_lint/provider_parameters
```

- `plugins: riverpod_lint: ^3.1.9` 로 plugin 이 로드되어 `dart analyze` 에 `provider_parameters` 가 보고됨 [실측].
- `diagnostics: provider_parameters: false` 로 해당 진단이 사라짐 [실측].
- **include 된 패키지 파일 안의 `plugins:` 도 사용 프로젝트에서 로드된다** [실측]. `include: [package:x/base.yaml, package:x/riverpod.yaml]` 구성에서 plugin 진단과 lint 가 함께 나왔고, 사용 프로젝트 쪽에는 `plugins_in_inner_options` 경고가 없었다.
- 사용 프로젝트가 자기 파일에 같은 plugin 을 `diagnostics:` 와 함께 다시 선언하면 include 된 선언을 덮어쓸 수 있다 [실측].
- 위 세 항목은 `path:` 의존성으로 확인했다. git 의존성도 같은 방식으로 해석될 것으로 보지만 [추정] `example/` 에서 한 번 더 확인한다.
- `// ignore: riverpod_lint/<code>` 문법은 dart.dev 문서 내용이며 직접 실행해 보지는 않았다.

### freezed / json_serializable

**`invalid_annotation_target: ignore`**

- freezed README(4.0.2 포함)는 json_serializable 과 함께 쓸 때 이 설정을 권한다 [공식].
- 그러나 `json_annotation` 4.10.0 이 `JsonKey` 의 대상에 constructor parameter 를 추가했다 [공식: json_annotation CHANGELOG, `@Target({field, getter, parameter})`].
- `json_annotation` 4.12.0 으로 확인한 결과 [실측]:

| 위치 | `invalid_annotation_target` |
|---|---|
| factory 생성자 매개변수의 `@JsonKey(...)` | 발생하지 않음 |
| factory 생성자 매개변수의 custom `JsonConverter` | 발생하지 않음 |
| factory 생성자 매개변수의 `@Default(...)` | 발생하지 않음 |
| enum 값의 `@JsonValue(...)` | 발생하지 않음 |
| **factory 생성자에 붙인 `@JsonSerializable(...)`** | **발생** |

- 즉 지금 이 설정이 필요한 경우는 "freezed 클래스의 factory 생성자에 `@JsonSerializable(...)` 을 붙이는 패턴" 하나다.
- `flutter_starter_kit` 의 손으로 쓴 소스에는 `@JsonSerializable` 도 `@JsonKey` 도 없다 (grep 0건). 현재 이 프로젝트에서 전역 ignore 가 가리는 것은 없다.
- **권고: 기본 preset 에서 빼고 codegen preset 으로 옮기거나 삭제한다.** 삭제 시에는 해당 패턴을 쓰는 자리에 `// ignore: invalid_annotation_target` 을 쓰도록 README 에 안내한다.

**생성 파일 exclude (`**/*.freezed.dart`, `**/*.g.dart`)**

- 생성기별 헤더 [공식 + `flutter_starter_kit` 생성 파일 확인]:

| 생성기 | 출력 | 자체 억제 헤더 |
|---|---|---|
| freezed | `*.freezed.dart` | `// ignore_for_file: type=lint` 외 다수 (4.0.2 는 `type=warning` 도 포함) |
| riverpod_generator | `*.g.dart` | `// ignore_for_file: type=lint, type=warning` |
| json_serializable | `*.g.dart` | **없음** |

- freezed 와 riverpod_generator 출력은 exclude 없이도 lint 가 나오지 않는다. json_serializable 만으로 생성된 `.g.dart` 는 헤더가 없으므로, 규칙을 늘리거나 strict 모드를 켜면 생성 코드에서 진단이 나올 수 있다. **exclude 는 여전히 필요하다.**
- include 된 패키지 파일의 `analyzer.exclude` glob 은 사용 프로젝트에 적용되고, 사용 프로젝트 자신의 `exclude` 와 **합쳐진다(대체하지 않는다)** [실측]. `flutter_starter_kit` 이 같은 두 줄을 다시 적어 둔 것은 불필요한 중복이다.
- 커뮤니티 패키지의 관례: `solid_lints` 는 `**/*.g.dart`, `**/*.gr.dart`, `**/*.freezed.dart`, `**/*.mocks.dart`, `**/*.pb.dart` 를, `total_lints` 는 `lib/**.g.dart` 를 기본 파일에 넣는다. `very_good_analysis` 와 `lint` 는 생성 파일을 넣지 않고 `lib/generated_plugin_registrant.dart` 만 넣는다.

**freezed 4.x 주의 [공식: freezed CHANGELOG].** freezed 최신은 4.0.2 (Dart 3.13 이상 요구) 이고, 4.0.0 은 primary constructor 를 지원하면서 "생성자 매개변수의 `final` 키워드를 더 이상 지원하지 않는다"는 breaking change 를 넣었다. `flutter_starter_kit` 은 freezed `^3.2.5` 다. primary constructor 관련 규칙(B-4)을 판단할 때 freezed 메이저와 함께 봐야 한다.

---

## Feature Dependencies

```
[규칙 세트 재선정]
    └──requires──> [후보 목록 (이 문서)]
    └──requires──> [지원 SDK 고정: .fvmrc, pubspec sdk 를 3.47.x / 3.13 으로]
    └──requires──> [실측: flutter_starter_kit 복사본에서 규칙별 진단 수]
                       └──requires──> [소비 프로젝트 방식의 include 가 동작]

[중복 6개 / 주석 3개 정리] ──독립── (실측 불필요, 이 문서의 근거로 결정 가능)

[Riverpod / codegen preset 분리]
    └──requires──> [include 목록 + 포함 파일의 plugins / exclude 동작]  (Dart 3.13.4 에서 확인됨)
    └──requires──> [기존 URI package:woody_lints/analysis_options.yaml 의 의미 결정]

[example/ + GitHub Actions]
    └──requires──> [preset 구조 확정]
    └──requires──> [검사 2종: include 방식 분석 + 배포 파일 root 분석]

[git tag 릴리스]
    └──requires──> [CHANGELOG: 추가/삭제 규칙 목록]
    └──requires──> [규칙 세트·preset 확정]

[README 재작성]
    └──requires──> [위 전부 확정]
    └──enhances──> [git tag 릴리스]  (ref: vX.Y.Z 안내)

[기본 preset 의 formatter: 설정] ──conflicts──> [버전을 올려도 포맷 diff 가 없다는 기대]
[strict-casts 옵션 형태] ──conflicts──> [프로젝트마다 올리는 시점을 고른다는 결정]
[primary constructor 규칙] ──conflicts──> [freezed 3.x / riverpod_generator 코드 (호환 미확인)]
```

### Dependency Notes

- **규칙 재선정 requires 지원 SDK 고정:** 규칙의 존재 여부가 SDK 에 달려 있다. `async_return_with_no_await`, `no_dynamic_casts` 등 10개 후보는 Dart 3.13 도입이고, dart.dev 목록의 2개는 3.14 전용이다. `.fvmrc` 가 Dart 3.11 인 채로는 실측 자체가 틀린 결과를 낸다.
- **실측은 한 번의 `dart analyze` 로 묶을 수 있다:** 후보를 전부 켠 옵션 파일로 분석하고 진단 코드별로 집계하면 된다. 단 양립 불가 쌍(`always_use_package_imports` / `prefer_relative_imports` 등)은 한쪽씩 나눠 돌려야 한다.
- **preset 분리 requires 기존 URI 의 의미 결정:** `package:woody_lints/analysis_options.yaml` 은 공개 API 다. 이 파일이 "기본만"을 뜻하게 바꾸면 기존 사용 프로젝트는 버전을 올리는 순간 riverpod_lint 를 조용히 잃는다. "전부 포함(기존 동작 유지)"으로 남기고 새 파일(`base` / `riverpod` / `codegen`)을 추가하는 방안과 비교해 정해야 한다.
- **example/ + CI requires 검사 2종:** include 방식만으로는 removed / deprecated 규칙이 보고되지 않는다 [실측].
- **`flutter pub get` 이 `analysis_options.yaml` 을 고친다:** Flutter 3.47.5 에서 `flutter pub get` 이 "Upgrading analysis_options.yaml to exclude build and platform directories" 를 출력하며 프로젝트 파일에 `analyzer: exclude: - build/**` 를 추가했다 [실측]. `example/` 에 미리 넣어 두지 않으면 CI 에서 작업 트리가 바뀐다.
- **중복·주석 정리는 독립:** 실측 없이 이 문서의 근거만으로 결정할 수 있어 가장 먼저 처리할 수 있다.

---

## MVP Definition

### Launch With (v1)

이번 milestone 의 새 릴리스에 들어가야 하는 것.

- [ ] 지원 SDK 정렬 (`.fvmrc`, `pubspec.yaml` 의 `sdk`) — 이후 모든 판단의 전제
- [ ] 중복 선언 6개 삭제, 주석 3개 삭제 — 근거가 이미 확보되었다
- [ ] 후보 규칙 실측 (B-1, B-2, B-3, B-5 + strict 3종의 lint 형태) 과 규칙별 결정 기록
- [ ] 남기는 규칙의 사유 주석을 사실에 맞게 수정 (특히 const 규칙, `always_declare_return_types`)
- [ ] preset 분리: 기본 / Riverpod / codegen. 기존 URI 의 의미 결정 포함
- [ ] `invalid_annotation_target: ignore` 를 기본 preset 에서 제거
- [ ] `example/` + CI: include 방식 분석과 배포 파일 root 분석 두 검사
- [ ] CHANGELOG (추가/삭제 규칙, 지원 SDK), README (설치, preset 선택, override, 버전 올리기)
- [ ] git tag 릴리스

### Add After Validation (v1.x)

- [ ] `public_member_api_docs` opt-in preset — 실측 건수가 감당 가능하고 실제로 쓰고 싶을 때
- [ ] `discarded_futures` — 건수가 크면 기본 preset 대신 다음 릴리스로 분리해 사용 프로젝트 정리 시점을 따로 잡는다
- [ ] `lints` 7.0.0 / `flutter_lints` 7 릴리스 대응 — `switch_on_type`, `unnecessary_unawaited`, `simple_directive_paths`, `simplify_variable_pattern` 이 기반 세트로 들어오면 중복 선언 제거

### Future Consideration (v2+)

- [ ] primary constructor 문법 전환 규칙 (B-4) — 사용 프로젝트가 freezed 4.x 로 올리고 문법 전환을 결정한 뒤
- [ ] `migrate_design_widgets` — Flutter 의 Material / Cupertino 패키지 분리 이전 안내를 조사한 뒤
- [ ] experimental 규칙 — stable 로 전환되면 재검토
- [ ] `strict-casts` / `strict-raw-types` 옵션 형태 제거 대응 — 이 패키지는 처음부터 lint 형태를 쓰면 해당 없음

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| 지원 SDK 정렬 | HIGH | LOW | P1 |
| 중복 6개 / 주석 3개 정리 | MEDIUM | LOW | P1 |
| 후보 규칙 실측 + 결정 기록 | HIGH | MEDIUM | P1 |
| 규칙 사유 주석 정정 | HIGH | LOW | P1 |
| preset 분리 (기본 / Riverpod / codegen) | MEDIUM | MEDIUM | P1 |
| `invalid_annotation_target` 전역 ignore 제거 | MEDIUM | LOW | P1 |
| `example/` + CI (검사 2종) | HIGH | MEDIUM | P1 |
| CHANGELOG / README / git tag | HIGH | LOW | P1 |
| 끈 규칙과 사유 목록 문서화 | MEDIUM | LOW | P2 |
| 릴리스별 migration 안내 (건수, `dart fix` 절차) | MEDIUM | LOW | P2 |
| strict 계열 (`no_dynamic_casts`, `no_raw_types`, `strict-inference`) 채택 | MEDIUM | MEDIUM | P2 |
| `public_member_api_docs` opt-in preset | LOW | LOW | P3 |
| primary constructor 규칙 | LOW | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

---

## Competitor Feature Analysis

조사 대상의 최신 버전과 게시일 (pub.dev API, 2026-10-11 조회).

| 패키지 | 버전 | 게시일 | SDK 하한 | 규칙 수 | 구성 방식 |
|---|---|---|---|---|---|
| `lints` | 6.1.0 | 2026-01-30 | 3.8 | `core` 35 + `recommended` 58 | 누적 tier |
| `flutter_lints` | 6.0.0 | 2025-05-27 | 3.8 | `recommended` + 10 | `lints` 를 include |
| `very_good_analysis` | 11.0.0 | 2026-09-03 | 3.13 | 214 | 전체 나열, 버전별 파일 |
| `lint` | 2.14.0 | 2026-09-05 | 3.13 | `strict` 184 / `casual` 136 | 전체 나열, 3 tier |
| `leancode_lint` | 27.0.0 | 2026-08-18 | 3.13 | 197 | 전체 나열 + custom plugin |
| `pedantic_mono` | 1.38.1 | 2026-08-13 | 3.13 | `flutter_lints` 포함 합계 207 | `flutter_lints` 를 include |
| `solid_lints` | 2.0.0 | 2026-10-08 | 3.12 | 168 | 전체 나열 + custom plugin |
| `total_lints` | 3.13.0 | 2026-08-27 | 3.13 | 223 | 전부 켜고 일부 끄기, SDK 별 파일 |

| Feature | `lints` / `flutter_lints` | `very_good_analysis` | `lint` 외 | Our Approach |
|---------|---------------------------|----------------------|-----------|--------------|
| preset tier | `core` → `recommended` → `flutter` (엄격도 누적) | 없음 (단일) | `lint`: `casual` / `strict` / `package`. `total_lints`: `app` / `package`. `solid_lints`: test 용 파일 | 스택 축: 기본 / Riverpod / codegen |
| 버전 고정 | pub 버전 | 버전별 YAML 파일 26개 유지, 기본 파일은 최신 파일을 include 하는 한 줄 | `lint`: Dart 버전 ↔ 패키지 버전 대응표. `total_lints`: SDK 별 파일 | git tag + `ref: vX.Y.Z` |
| 규칙별 사유 | 규칙 추가 시 GitHub issue 링크 | 끈 규칙만 README 표 (일부는 "Not specified") | `lint`: YAML 에 규칙마다 켠/끈 사유 주석 | YAML 주석에 켠 사유 + 실측 건수, 끈 규칙 표 |
| override 안내 | `lints`: dart.dev 문서로 링크만 | line / file / project 3단계 | `lint`: README 에 exclude · 재정의 예시 | 3단계 + plugin 진단 억제 방법 |
| CHANGELOG | 버전별 added / removed 규칙 목록 | Conventional Commits 자동 생성, rc 사전 릴리스 | 패키지마다 다름 | `lints` 형식 (added / removed + 지원 SDK) |
| example 프로젝트 | 둘 다 있음 | 있음 (`path: ../` + include 한 줄 + Dart 12줄) | `lint`, `pedantic_mono`, `leancode_lint`, `solid_lints` 있음 | 있음. preset 조합별 검증 |
| 저장소 내 검증 | `lints`: `tool/validate_lib.dart`, `flutter_lints`: `run_tests.sh` — 둘 다 "`lib/` 에 Dart 소스가 없다"만 검사 | README 에 CI badge (workflow 내용은 배포본에 없어 미확인) | 미확인 | include 방식 + root 분석 두 검사 |
| 규칙 목록 문서 | `lints`: `tool/gen_docs.dart` 가 YAML 에서 `rules.md` 표를 생성 | README 의 제외 표를 주석 marker 사이에 생성 | `lint`: YAML 주석이 곧 문서 | YAML 을 원천으로 하고 README 에는 손으로 복제하지 않음 |
| strict 모드 | 없음 | 3종 전부 | `lint`: `strict-casts` 만. `leancode_lint`, `pedantic_mono`: 3종. `solid_lints`: casts + raw-types | lint 형태로 실측 후 결정 |
| formatter 설정 | 없음 | `trailing_commas: automate` | `pedantic_mono`: `preserve` | 넣지 않음 |
| 생성 파일 exclude | 없음 | 없음 | `solid_lints`, `total_lints`: 있음 | codegen preset 에 포함 |
| 심각도 승격 | 없음 | 5개 진단 승격(`missing_return: error` 등) + `close_sinks: ignore` | `leancode_lint`: 거의 전부 `warning` | 하지 않음 |
| custom 규칙 | 없음 | 없음 | `leancode_lint`, `solid_lints` | 하지 않음 |

`very_good_analysis` 11.0.0 의 README 제외 표는 실제 YAML 과 두 군데 어긋난다(`initialize_in_field_declaration`, `unnecessary_const_in_enum_constructor` 를 제외했다고 적었으나 YAML 은 켠다). 규칙 목록을 문서에 손으로 복제하면 잘 관리되는 패키지에서도 drift 가 생긴다는 실례다.

---

## Sources

**실측 (Dart 3.13.4 / Flutter 3.47.5, 로컬 FVM, scratch 프로젝트)**

- 규칙 이름 264개 + 별칭을 한 옵션 파일에 넣어 `dart analyze` — undefined / removed / deprecated / incompatible / duplicate 출력
- `require_trailing_commas` × `dart format` (`automate`, `preserve`) × language version (3.13, 3.6)
- `formatter:` 설정의 include 전파
- `analyzer.exclude` 의 include 전파와 로컬 exclude 병합
- 포함 파일 안의 잘못된 규칙이 사용 프로젝트에 보고되는지 (include 방식 vs root 분석)
- `plugins:` 를 담은 포함 파일의 로드, `diagnostics:` 로 끄기, 사용 프로젝트의 재선언
- `invalid_annotation_target` × `json_annotation` 4.12.0 의 annotation 위치 5종
- strict 3종과 `no_dynamic_casts` / `no_raw_types` 의 출력 비교
- `always_declare_return_types` vs `strict_top_level_inference` 범위 비교
- Dart 3.13 신규 규칙 10개와 `var_with_no_type_annotation` 을 최소 Flutter 샘플에 적용

**공식 원문 (seam 등급: LOW ~ MEDIUM)**

- https://raw.githubusercontent.com/dart-lang/site-www/main/src/data/linter_rules.json — dart.dev/tools/linter-rules 의 원본 데이터 (264개 규칙)
- https://dart.dev/tools/linter-rules/require_trailing_commas
- https://dart.dev/tools/analysis — strict 모드, include 병합 순서, 규칙 끄기, exclude, formatter
- https://dart.dev/tools/dart-format — `formatter:` 설정과 language version 요건
- https://dart.dev/tools/analyzer-plugins — `plugins:` / `diagnostics:` / `// ignore: plugin/code`
- https://raw.githubusercontent.com/dart-lang/sdk/main/CHANGELOG.md — 3.9 ~ 3.14 의 Analyzer / Linter / Formatter 항목
- https://raw.githubusercontent.com/dart-lang/core/main/pkgs/lints/CHANGELOG.md — `lints` 7.0.0-wip
- https://raw.githubusercontent.com/flutter/packages/main/packages/flutter_lints/CHANGELOG.md — 5.0.0 의 const 규칙 제거
- https://github.com/dart-lang/lints/issues/205 — const 규칙 제거 논의
- https://dart.googlesource.com/sdk/+/stable/pkg/linter/lib/src/rules/require_trailing_commas.dart — language 3.7 gate (websearch 로 확인, 실측과 일치)
- pub.dev API (`https://pub.dev/api/packages/<name>`) — 버전·게시일·SDK 제약

**패키지 배포본**

- 로컬 pub cache: `flutter_lints` 6.0.0 (`run_tests.sh` 포함), `lints` 6.1.0 (`tool/`, `rules.md` 포함), `riverpod_lint` 3.1.9, `freezed` 3.2.5
- pub.dev archive: `very_good_analysis` 11.0.0, `lint` 2.14.0, `leancode_lint` 27.0.0, `pedantic_mono` 1.38.1, `solid_lints` 2.0.0, `total_lints` 3.13.0, `freezed` 4.0.2, `json_serializable` 6.14.1, `json_annotation` 4.12.0
- Context7 `/rrousselgit/riverpod` — riverpod_lint 설치 안내 (소스와 일치)

**읽기 전용으로 확인한 사용 프로젝트**

- `/Users/woody/dv/woody/flutter_starter_kit` — `pubspec.yaml` 의 codegen 버전, `analysis_options.yaml` 의 중복 exclude, 생성 파일 헤더, `@JsonSerializable` / `@JsonKey` 사용 여부 (수정 없음)

**확인하지 못한 것**

- 규칙별 실제 진단 수 — 소음 등급은 전부 추정이다
- `unnecessary_type_name_in_constructor` 등 primary constructor 규칙의 `dart fix` 결과가 freezed / riverpod_generator 코드와 호환되는지
- `migrate_design_widgets` 가 가리키는 대체 패키지와 Flutter 3.47 에서의 이전 가능 여부
- `strict-casts` / `strict-raw-types` 옵션이 언제 deprecated 되는지
- `use_primary_constructors` 의 공식 문서
- git 의존성으로 가져온 preset 파일에서의 `plugins:` 동작 (`path:` 의존성으로만 확인)
- `hasFix` 규칙 각각이 `dart fix --apply` 로 일괄 적용되는지

---
*Feature research for: Dart/Flutter 공유 lint 설정 패키지 (woody_lints)*
*Researched: 2026-10-11*
