// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r10_unsupported_provider_value.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `unsupported_provider_value` — generator 가 지원하지 않는 값(StateNotifier)을 돌려준다.

@ProviderFor(legacyCounter)
final legacyCounterProvider = LegacyCounterProvider._();

/// `unsupported_provider_value` — generator 가 지원하지 않는 값(StateNotifier)을 돌려준다.

final class LegacyCounterProvider
    extends $FunctionalProvider<LegacyCounter, LegacyCounter, LegacyCounter>
    with $Provider<LegacyCounter> {
  /// `unsupported_provider_value` — generator 가 지원하지 않는 값(StateNotifier)을 돌려준다.
  LegacyCounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'legacyCounterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$legacyCounterHash();

  @$internal
  @override
  $ProviderElement<LegacyCounter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LegacyCounter create(Ref ref) {
    return legacyCounter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LegacyCounter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LegacyCounter>(value),
    );
  }
}

String _$legacyCounterHash() => r'115bb1fe36cddbec774ebaa2c88e757e33a002fb';
