import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `avoid_public_notifier_properties` — Notifier 에 public 필드를 둔다.
class PublicFieldNotifier extends Notifier<int> {
  /// 바깥에서 보이는 필드.
  int publicField = 0;

  @override
  int build() => 0;
}
