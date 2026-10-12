import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `avoid_public_notifier_properties` (riverpod_lint, info) — Notifier 에 public 필드를 둔다.
class PublicFieldNotifier extends Notifier<int> {
  /// 바깥에서 보이는 필드.
  int publicField = 0;

  @override
  int build() => 0;
}

/// 인자를 받는 provider.
final familyProvider = Provider.family<int, Object?>((ref, value) => 0);

/// `provider_parameters` (riverpod_lint, warning) — `==` 를 재정의하지 않는 non-const 리터럴을 family 인자로 넘긴다.
final consumerProvider = Provider<int>(
  (ref) => ref.watch(familyProvider([42])),
);
