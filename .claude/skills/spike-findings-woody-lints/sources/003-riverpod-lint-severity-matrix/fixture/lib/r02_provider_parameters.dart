import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final familyProvider = Provider.family<int, Object?>((ref, value) => 0);

/// `provider_parameters` — `==` 를 재정의하지 않는 non-const 리터럴을 family 인자로 넘긴다.
final consumerProvider = Provider<int>(
  (ref) => ref.watch(familyProvider([42])),
);
