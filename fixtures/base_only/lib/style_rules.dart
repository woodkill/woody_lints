// woody_lints 2.0.0 에서 새로 켠 가독성·스타일 규칙을 규칙마다 한 건씩 어긴다. 한 줄에서 규칙 하나만 걸리게 둔다.
// `avoid_final_parameters` 의 샘플은 final_parameters_rule.dart 에 있다 — 언어 버전 3.13 에서는 이 규칙이
// 돌지 않아(보통 매개변수의 final 이 error 다) 그 파일만 언어 버전 3.11 로 둔다.
// 맨 위 directive 넷이 샘플이다 — `unnecessary_library_directive` (문서 주석 없는 library;),
// `combinators_ordering` (show 의 이름 순서), `directives_ordering` (dart: import 의 알파벳 순서),
// `simple_directive_paths` (./ 가 낀 경로).
library;

import 'dart:math' show sin, cos;
import 'dart:collection';

export './performance_rules.dart';

/// show 로 받은 이름을 쓰는 자리 (쓰지 않으면 unused_shown_name 이 함께 걸린다).
double trigonometry() => sin(0) + cos(0);

/// dart:collection 의 이름을 쓰는 자리.
int queueLength(Queue<int> queue) => queue.length;

/// `avoid_bool_literals_in_conditional_expressions` — 조건식의 결과에 bool 리터럴.
bool isPositive(int x) => x > 0 ? true : false;

/// `avoid_escaping_inner_quotes` — 바깥 따옴표를 바꾸면 없앨 수 있는 escape.
const String escapedQuote = 'it\'s';

/// `avoid_multiple_declarations_per_line` — 한 줄에 변수 둘.
int sumOfTwo(int x) {
  final a = x, b = x + 1;
  return a + b;
}

/// 기본값이 있는 매개변수를 가진 함수.
int withDefault({int value = 1}) => value;

/// `avoid_redundant_argument_values` — 기본값과 같은 인자.
int redundantArgument() => withDefault(value: 1);

/// getter 없이 setter 만 둔 클래스.
class SetterOnly {
  int _value = 0;

  /// `avoid_setters_without_getters` — getter 없는 setter.
  set value(int v) {
    _value = v;
  }

  /// 값을 읽는다.
  int read() => _value;
}

/// `document_ignores` — 까닭을 적지 않은 무시 주석 (바로 윗줄이 주석이 아니다).
int undocumentedIgnore() {
  // ignore: prefer_final_locals
  var value = 1;
  return value;
}

/// `flutter_style_todos` — Flutter 형식이 아닌 TODO.
int todoValue() {
  // TODO: 샘플
  return 1;
}

/// `join_return_with_assignment` — 대입 직후 같은 변수를 return.
int joinReturn(List<int> values) {
  var total = 0;
  total = values.length;
  return total;
}

/// `leading_newlines_in_multiline_strings` — 개행으로 시작하지 않는 여러 줄 문자열.
const String multiline = '''첫 줄
둘째 줄''';

/// `no_literal_bool_comparisons` — bool 리터럴과의 비교.
bool isTrue(bool b) => b == true;

/// `omit_obvious_local_variable_types` — 타입이 자명한 지역 변수에 타입을 적는다.
int obviousLocal(int seconds) {
  final Duration duration = Duration(seconds: seconds);
  return duration.inMilliseconds;
}

/// 생성자 본문에서 값을 검사하는 클래스.
class AssertInBody {
  /// `prefer_asserts_in_initializer_lists` — 생성자 본문의 assert.
  AssertInBody(this.value) {
    assert(value > 0);
  }

  /// 값.
  final int value;
}

/// static 메서드로 인스턴스를 만드는 클래스.
class StaticFactory {
  StaticFactory._();

  /// `prefer_constructors_over_static_methods` — 인스턴스를 만드는 static 메서드.
  static StaticFactory create() => StaticFactory._();
}

/// `prefer_final_in_for_each` — 다시 대입하지 않는 for-in 변수에 final 이 없다.
int sumAll(List<int> values) {
  var sum = 0;
  for (var value in values) {
    sum += value;
  }
  return sum;
}

/// `prefer_if_elements_to_conditional_expressions` — 컬렉션 안의 삼항 연산자.
List<int> pick(bool flag) => [flag ? 1 : 2];

/// `prefer_int_literals` — double 자리의 1.0.
const double one = 1.0;

/// null 일 수 있는 콜백을 가진 클래스 (필드라 null 검사 뒤에도 승격되지 않는다).
class CallbackHolder {
  /// 생성자.
  CallbackHolder(this.callback);

  /// 콜백.
  final void Function()? callback;

  /// `prefer_null_aware_method_calls` — null 검사 뒤의 f!() 호출.
  void run() {
    if (callback != null) callback!();
  }
}

/// `simplify_variable_pattern` — 변수 pattern 에 같은 이름의 getter 를 다시 적는다.
int secondsOf(Object value) {
  if (value case Duration(inSeconds: final inSeconds)) {
    return inSeconds;
  }
  return 0;
}

/// 생성자보다 앞에 다른 멤버를 둔 클래스.
class ConstructorLast {
  /// 값.
  int get value => 1;

  /// `sort_constructors_first` — 생성자보다 앞에 둔 멤버.
  ConstructorLast();
}

/// 이름 있는 생성자를 먼저 둔 클래스.
class UnnamedLast {
  /// 이름 있는 생성자.
  UnnamedLast.named();

  /// `sort_unnamed_constructors_first` — 이름 있는 생성자 뒤에 둔 이름 없는 생성자.
  UnnamedLast();
}

/// `specify_nonobvious_property_types` — 타입이 자명하지 않은 top-level 변수에 타입이 없다.
final nonObvious = int.parse('1');

/// assert 로 null 아님을 검사하는 클래스.
class Tighten {
  /// `tighten_type_of_initializing_formals` — assert 로 null 아님을 검사하는 nullable 초기화 매개변수.
  Tighten(this.value) : assert(value != null);

  /// 값.
  final String? value;
}

/// `type_annotate_public_apis` — 타입 표기가 없는 공개 top-level 변수.
var publicCounter = 0;

/// `unnecessary_breaks` — case 끝의 불필요한 break.
int breakAfterCase(int x) {
  var y = x;
  switch (x) {
    case 1:
      y++;
      break;
    default:
      y--;
  }
  return y;
}

/// `unnecessary_lambdas` — tear-off 로 쓸 수 있는 람다.
List<double> parseAll(List<String> values) => values.map((v) => double.parse(v)).toList();

/// nullable int 의 extension.
extension NullableOrZero on int? {
  /// null 이면 0.
  int get orZero => this ?? 0;
}

/// `unnecessary_null_aware_operator_on_extension_on_nullable` — nullable 대상 extension 에 쓴 ?.
int? orZeroOf(int? x) => x?.orZero;

/// nullable 을 받는 함수.
int? nullableIdentity(int? x) => x;

/// `unnecessary_null_checks` — nullable 을 받는 자리에 쓴 !.
int? passNullable(int? x) => nullableIdentity(x!);

/// `unnecessary_parenthesis` — 불필요한 괄호.
int doubled(int x) => (x * 2);

/// `unnecessary_raw_strings` — escape 가 없는 raw 문자열.
const String rawPlain = r'plain';

/// `use_raw_strings` — raw 문자열로 쓸 수 있는 escape.
const String escapedBackslash = 'a\\b';

/// `use_enums` — enum 처럼 쓰는 클래스.
class EnumLike {
  const EnumLike._(this.value);

  /// 첫째.
  static const EnumLike first = EnumLike._(1);

  /// 둘째.
  static const EnumLike second = EnumLike._(2);

  /// 값.
  final int value;
}

/// `use_is_even_rather_than_modulo` — % 2 == 0.
bool isEven(int x) => x % 2 == 0;

/// `use_named_constants` — Duration.zero 대신 쓴 const Duration().
Duration zeroDuration() => const Duration();

/// 메서드로 필드를 바꾸는 클래스.
class SetterMethod {
  int _value = 0;

  /// 값.
  int get value => _value;

  /// `use_setters_to_change_properties` — 프로퍼티를 바꾸는 메서드.
  void changeValue(int v) {
    _value = v;
  }
}
