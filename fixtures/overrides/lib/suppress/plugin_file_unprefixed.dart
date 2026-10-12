// ignore_for_file: provider_parameters
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final unprefixedFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 파일 주석(접두사 없음)으로 plugin 진단 끄기 — 꺼지지 않는 모양을 정답지에 고정한다.
final unprefixedConsumer = Provider<int>((ref) => ref.watch(unprefixedFamily([6])));
