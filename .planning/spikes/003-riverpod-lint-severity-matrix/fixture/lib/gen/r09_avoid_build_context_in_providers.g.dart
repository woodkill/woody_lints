// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r09_avoid_build_context_in_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `avoid_build_context_in_providers` — provider 가 `BuildContext` 를 인자로 받는다.

@ProviderFor(withContext)
final withContextProvider = WithContextFamily._();

/// `avoid_build_context_in_providers` — provider 가 `BuildContext` 를 인자로 받는다.

final class WithContextProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// `avoid_build_context_in_providers` — provider 가 `BuildContext` 를 인자로 받는다.
  WithContextProvider._({
    required WithContextFamily super.from,
    required BuildContext super.argument,
  }) : super(
         retry: null,
         name: r'withContextProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$withContextHash();

  @override
  String toString() {
    return r'withContextProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as BuildContext;
    return withContext(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WithContextProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$withContextHash() => r'183054aba3242eb3bf9f40a68142601cfa07fee5';

/// `avoid_build_context_in_providers` — provider 가 `BuildContext` 를 인자로 받는다.

final class WithContextFamily extends $Family
    with $FunctionalFamilyOverride<int, BuildContext> {
  WithContextFamily._()
    : super(
        retry: null,
        name: r'withContextProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// `avoid_build_context_in_providers` — provider 가 `BuildContext` 를 인자로 받는다.

  WithContextProvider call(BuildContext context) =>
      WithContextProvider._(argument: context, from: this);

  @override
  String toString() => r'withContextProvider';
}
