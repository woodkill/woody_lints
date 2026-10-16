import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'r04b_protected_notifier_properties.g.dart';

/// state 를 건드릴 대상.
@riverpod
class GeneratedTarget extends _$GeneratedTarget {
  @override
  int build() => 0;
}

/// `protected_notifier_properties` — 다른 Notifier 의 `state` 를 바깥에서 쓴다.
@riverpod
class GeneratedCaller extends _$GeneratedCaller {
  @override
  int build() => 0;

  /// 다른 Notifier 의 state 를 바꾼다.
  void poke() {
    ref.read(generatedTargetProvider.notifier).state = 42;
  }
}
