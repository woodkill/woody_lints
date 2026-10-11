import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `@riverpod` 없이 손으로 쓴 Notifier.
class PlainTarget extends Notifier<int> {
  @override
  int build() => 0;
}

/// [PlainTarget] 의 provider.
final plainTargetProvider = NotifierProvider<PlainTarget, int>(PlainTarget.new);

/// `protected_notifier_properties` 의 대조군 — 손으로 쓴 Notifier 에서 다른 Notifier 의
/// `state` 를 건드린다. 소스상 `@riverpod` class 안에서만 보고하므로 진단이 없을 것으로 본다.
class PlainCaller extends Notifier<int> {
  @override
  int build() => 0;

  /// 다른 Notifier 의 state 를 바꾼다.
  void poke() {
    ref.read(plainTargetProvider.notifier).state = 42;
  }
}
