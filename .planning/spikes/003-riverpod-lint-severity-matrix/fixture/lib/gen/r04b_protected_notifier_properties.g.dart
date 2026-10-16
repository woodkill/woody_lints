// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'r04b_protected_notifier_properties.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// state 를 건드릴 대상.

@ProviderFor(GeneratedTarget)
final generatedTargetProvider = GeneratedTargetProvider._();

/// state 를 건드릴 대상.
final class GeneratedTargetProvider
    extends $NotifierProvider<GeneratedTarget, int> {
  /// state 를 건드릴 대상.
  GeneratedTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedTargetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generatedTargetHash();

  @$internal
  @override
  GeneratedTarget create() => GeneratedTarget();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$generatedTargetHash() => r'b0ddd6e27f6e388b3a0f288d0c2b215e319ef83e';

/// state 를 건드릴 대상.

abstract class _$GeneratedTarget extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// `protected_notifier_properties` — 다른 Notifier 의 `state` 를 바깥에서 쓴다.

@ProviderFor(GeneratedCaller)
final generatedCallerProvider = GeneratedCallerProvider._();

/// `protected_notifier_properties` — 다른 Notifier 의 `state` 를 바깥에서 쓴다.
final class GeneratedCallerProvider
    extends $NotifierProvider<GeneratedCaller, int> {
  /// `protected_notifier_properties` — 다른 Notifier 의 `state` 를 바깥에서 쓴다.
  GeneratedCallerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedCallerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generatedCallerHash();

  @$internal
  @override
  GeneratedCaller create() => GeneratedCaller();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$generatedCallerHash() => r'ec076e70d46d7232946d07e7fecac8b46f901db2';

/// `protected_notifier_properties` — 다른 Notifier 의 `state` 를 바깥에서 쓴다.

abstract class _$GeneratedCaller extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
