// ignore_for_file: riverpod_lint/provider_parameters
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final prefixedFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 파일 주석(접두사 있음)으로 plugin 진단 끄기.
final prefixedConsumer = Provider<int>((ref) => ref.watch(prefixedFamily([5])));
