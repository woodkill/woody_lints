import 'dart:async';

// woody_lints 2.0.0 에서 새로 켠 버그 방지 규칙을 규칙마다 한 건씩 어긴다. 한 줄에서 규칙 하나만 걸리게 둔다.
// `prefer_relative_imports` 의 샘플은 relative_imports_rule.dart 에 있다 — 자기 패키지 이름을
// 적어야 하는데 그 이름이 프로젝트마다 달라서, 그 파일만 프로젝트마다 패키지 이름이 다르다.

// `conditional_uri_does_not_exist` — 조건부 export 가 없는 파일을 가리킨다 (import 로 두면
// 쓰지 않는 import 라 unused_import warning 이 같은 줄에 함께 걸린다).
export 'dart:math' if (dart.library.io) 'woody_missing_conditional_target.dart';

/// `async_return_with_no_await` — async 함수가 Future 를 await 없이 돌려준다.
Future<String> asyncReturn(Future<String> value) async {
  return value;
}

/// `avoid_catching_errors` — Error 의 하위 타입을 잡는다.
int catchesError() {
  try {
    return int.parse('1');
  } on StateError {
    return 0;
  }
}

/// `avoid_double_and_int_checks` — is double 검사 뒤의 is int 검사.
String numberKind(num x) {
  if (x is double) {
    return 'double';
  } else if (x is int) {
    return 'int';
  }
  return 'other';
}

/// `avoid_dynamic_calls` — dynamic 값의 메서드 호출.
Object? dynamicCall(dynamic value) => value.toList();

/// `avoid_js_rounded_ints` — JavaScript 에서 정밀도가 깨지는 정수 리터럴.
const int jsRounded = 9007199254740993;

/// Type 을 implements 하는 클래스 (아래 줄의 toString() 이 기대는 것).
class TypeLike implements Type {}

/// `avoid_type_to_string` — Type 의 toString() 결과에 기댄다.
String typeLikeName() => TypeLike().toString();

/// 아래 생성자의 매개변수를 쓰지 않는 클래스.
class UnusedParameter {
  /// `avoid_unused_constructor_parameters` — 쓰이지 않는 생성자 매개변수.
  UnusedParameter(int unused);
}

/// `avoid_void_async` — 반환 타입이 void 인 async 함수.
void voidAsync() async {
  await Future<void>.value();
}

/// `cancel_subscriptions` — cancel 하지 않는 StreamSubscription.
void keepSubscription(Stream<int> stream) {
  final StreamSubscription<int> subscription = stream.listen((_) {});
  subscription.pause();
}

/// 아래 cast 의 원래 타입.
class CastBase {}

/// 아래 cast 의 대상 타입.
class CastChild extends CastBase {}

/// `cast_nullable_to_non_nullable` — nullable 값을 non-nullable 하위 타입으로 as.
CastChild castNullable(CastBase? value) => value as CastChild;

/// deprecated 로 표시한 함수 (아래 줄이 부른다).
@Deprecated('샘플')
int deprecatedValue() => 1;

/// `deprecated_member_use_from_same_package` — 같은 패키지 안에서 deprecated 멤버를 쓴다.
int useDeprecated() => deprecatedValue();

/// `discarded_futures` — 동기 함수에서 Future 를 버린다.
void discardFuture() {
  Future<void>.delayed(Duration.zero);
}

/// `literal_only_boolean_expressions` — 리터럴만으로 이루어진 조건식.
int literalCondition() {
  if (1 > 2) {
    return 0;
  }
  return 1;
}

/// super 매개변수가 가리키는 부모 클래스.
class SuperBase {
  /// 생성자.
  SuperBase(this.first, this.second);

  /// 첫째.
  final int first;

  /// 둘째.
  final int second;
}

/// 아래 생성자의 super 매개변수 이름이 부모와 다른 클래스.
class SuperChild extends SuperBase {
  /// `matching_super_parameters` — 둘째 super 매개변수의 이름이 부모 생성자와 다르다.
  SuperChild(super.first, super.other);
}

/// `missing_whitespace_between_adjacent_strings` — 이어 붙인 문자열 사이에 공백이 없다.
const String joinedSentence = 'no space' 'here';

/// `no_adjacent_strings_in_list` — 리스트 안에서 쉼표 없이 붙은 문자열.
const List<String> adjacentInList = ['first ' 'second'];

/// 자기 자신을 대입하는 메서드를 가진 클래스.
class SelfAssign {
  /// 값.
  int value = 0;

  /// `no_self_assignments` — 같은 값을 다시 넣는다.
  void reset() {
    value = value;
  }
}

/// `only_throw_errors` — Exception / Error 가 아닌 값을 던진다.
void throwsString() {
  throw 'oops';
}

/// `parameter_assignments` — 매개변수에 다시 대입한다.
int parameterAssign(int x) {
  x = x + 1;
  return x;
}

/// `switch_on_type` — runtimeType 으로 switch.
String switchOnType(Object value) {
  switch (value.runtimeType) {
    case const (int):
      return 'int';
    default:
      return 'other';
  }
}

/// operator == 에서 인자의 타입을 검사하지 않는 클래스.
class EqualsWithoutTypeCheck {
  /// 생성자.
  const EqualsWithoutTypeCheck(this.value);

  /// 값.
  final int value;

  /// `test_types_in_equals` — 인자의 타입을 검사하지 않고 as 한다.
  @override
  bool operator ==(Object other) =>
      (other as EqualsWithoutTypeCheck).value == value;

  @override
  int get hashCode => value.hashCode;
}

/// `throw_in_finally` — finally 안의 throw.
int throwInFinally() {
  try {
    return int.parse('1');
  } finally {
    throw StateError('샘플');
  }
}

/// `unnecessary_statements` — 효과가 없는 문장.
void noEffect(int x) {
  x + 1;
}
