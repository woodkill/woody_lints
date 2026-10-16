import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 하위 폴더에 둔 Notifier.
///
/// 일부러 어긴 규칙: `avoid_public_notifier_properties`
/// (riverpod_lint, 소스에 강도 지정이 없음).
class Counter extends Notifier<int> {
  int publicField = 0;

  @override
  int build() => 0;
}
