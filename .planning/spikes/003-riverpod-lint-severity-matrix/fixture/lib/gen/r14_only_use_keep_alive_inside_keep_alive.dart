import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'r14_only_use_keep_alive_inside_keep_alive.g.dart';

/// 쓰는 곳이 없으면 정리되는(auto-dispose) provider.
@riverpod
int autoDisposed(Ref ref) => 0;

/// `only_use_keep_alive_inside_keep_alive` — keepAlive provider 가 auto-dispose provider 에 기댄다.
@Riverpod(keepAlive: true)
int keptAlive(Ref ref) => ref.watch(autoDisposedProvider);
