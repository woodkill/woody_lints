import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final lineFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 한 줄 주석으로 plugin 진단 끄기 — 접두사 있음 / 없음 / 같은 줄 끝 / 끄지 않음.
final lineConsumer = Provider<int>((ref) {
  // ignore: riverpod_lint/provider_parameters
  final a = ref.watch(lineFamily([1]));
  // ignore: provider_parameters
  final b = ref.watch(lineFamily([2]));
  final c = ref.watch(lineFamily([3])); // ignore: riverpod_lint/provider_parameters
  final d = ref.watch(lineFamily([4]));
  return a + b + c + d;
});
