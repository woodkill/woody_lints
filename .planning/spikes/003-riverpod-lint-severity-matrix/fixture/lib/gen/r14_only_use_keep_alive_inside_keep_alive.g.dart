// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r14_only_use_keep_alive_inside_keep_alive.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 쓰는 곳이 없으면 정리되는(auto-dispose) provider.

@ProviderFor(autoDisposed)
final autoDisposedProvider = AutoDisposedProvider._();

/// 쓰는 곳이 없으면 정리되는(auto-dispose) provider.

final class AutoDisposedProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// 쓰는 곳이 없으면 정리되는(auto-dispose) provider.
  AutoDisposedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoDisposedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoDisposedHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return autoDisposed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$autoDisposedHash() => r'f8556cc9e85183b2e22e296e7afe574e564adf4f';

/// `only_use_keep_alive_inside_keep_alive` — keepAlive provider 가 auto-dispose provider 에 기댄다.

@ProviderFor(keptAlive)
final keptAliveProvider = KeptAliveProvider._();

/// `only_use_keep_alive_inside_keep_alive` — keepAlive provider 가 auto-dispose provider 에 기댄다.

final class KeptAliveProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// `only_use_keep_alive_inside_keep_alive` — keepAlive provider 가 auto-dispose provider 에 기댄다.
  KeptAliveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keptAliveProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keptAliveHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return keptAlive(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$keptAliveHash() => r'c4cd814d700ea15dd544a4721bc9bf3785c6bbf9';
