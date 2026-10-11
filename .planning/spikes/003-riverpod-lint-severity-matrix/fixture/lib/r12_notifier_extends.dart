import 'package:riverpod_annotation/riverpod_annotation.dart';

/// `notifier_extends` — 클래스형 provider 가 `_$WrongExtends` 를 상속하지 않는다.
@riverpod
class WrongExtends extends Object {
  /// 초기 상태.
  int build() => 0;
}
