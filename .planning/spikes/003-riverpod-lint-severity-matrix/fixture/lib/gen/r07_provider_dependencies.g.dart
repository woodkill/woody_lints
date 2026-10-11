// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r07_provider_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// scope 될 수 있는 provider.

@ProviderFor(scopedDep)
final scopedDepProvider = ScopedDepProvider._();

/// scope 될 수 있는 provider.

final class ScopedDepProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// scope 될 수 있는 provider.
  ScopedDepProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scopedDepProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
      );

  @override
  String debugGetCreateSourceHash() => _$scopedDepHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return scopedDep(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$scopedDepHash() => r'7733026f39b838e47d2ae3cd29384c4ea5c86a51';

/// `provider_dependencies` — 쓰지 않는 provider 를 `dependencies` 에 적는다.

@ProviderFor(unusedDependency)
final unusedDependencyProvider = UnusedDependencyProvider._();

/// `provider_dependencies` — 쓰지 않는 provider 를 `dependencies` 에 적는다.

final class UnusedDependencyProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// `provider_dependencies` — 쓰지 않는 provider 를 `dependencies` 에 적는다.
  UnusedDependencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unusedDependencyProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[scopedDepProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          UnusedDependencyProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = scopedDepProvider;

  @override
  String debugGetCreateSourceHash() => _$unusedDependencyHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return unusedDependency(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unusedDependencyHash() => r'22c77669daa881009fafe8ddc517d86ddec338f6';
