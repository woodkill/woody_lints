// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r08_scoped_providers_should_specify_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `dependencies` 를 적지 않은 provider.

@ProviderFor(rootValue)
final rootValueProvider = RootValueProvider._();

/// `dependencies` 를 적지 않은 provider.

final class RootValueProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// `dependencies` 를 적지 않은 provider.
  RootValueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rootValueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rootValueHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return rootValue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$rootValueHash() => r'264d5dbb154ec569ea94b95d76b5e75d0cee68a6';
