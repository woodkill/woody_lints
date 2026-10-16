import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'r10_unsupported_provider_value.g.dart';

/// 옛 방식의 StateNotifier.
class LegacyCounter extends StateNotifier<int> {
  /// 0 에서 시작한다.
  LegacyCounter() : super(0);
}

/// `unsupported_provider_value` — generator 가 지원하지 않는 값(StateNotifier)을 돌려준다.
@riverpod
LegacyCounter legacyCounter(Ref ref) => LegacyCounter();
