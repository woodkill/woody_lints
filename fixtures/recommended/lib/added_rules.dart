import 'package:flutter/material.dart';

// woody_lints 가 기반 세트(flutter_lints / lints) 위에 추가하는 규칙 6개를
// 규칙마다 한 건씩 어긴다. 한 줄에서 규칙 하나만 걸리게 둔다.

/// `prefer_const_constructors` — const 로 만들 수 있는 생성자 호출.
Widget constCandidate() => Text('a');

/// 리스트 원소로 쓸 const 위젯 (아래 줄의 생성자 호출을 피하려는 것).
const Widget constChild = SizedBox.shrink();

/// `prefer_const_literals_to_create_immutables` — @immutable 생성자에 넘기는 const 가능한 리스트.
Widget listCandidate(Key key) => Column(key: key, children: [constChild]);

/// `always_declare_return_types` — 반환 타입을 적지 않은 지역 함수.
/// (최상위 함수에 두면 기반 세트의 `strict_top_level_inference` 도 함께 걸린다.)
int callsLocal() {
  noReturnType() => 0;
  return noReturnType();
}

/// `prefer_final_locals` — 다시 대입하지 않는 지역 변수를 `var` 로 선언.
int finalCandidate() {
  var value = 1;
  return value;
}

/// `prefer_single_quotes` — 겹따옴표 문자열.
const String doubleQuoted = "b";

/// `unawaited_futures` — async 함수 안에서 기다리지 않은 Future.
Future<void> notAwaited() async {
  Future<void>.delayed(Duration.zero);
}
