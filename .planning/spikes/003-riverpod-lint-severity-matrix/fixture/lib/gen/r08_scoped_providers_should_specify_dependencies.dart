import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'r08_scoped_providers_should_specify_dependencies.g.dart';

/// `dependencies` 를 적지 않은 provider.
@riverpod
int rootValue(Ref ref) => 0;

/// `scoped_providers_should_specify_dependencies` — `dependencies` 가 없는 provider 를
/// 하위 container 에서 override 한다.
ProviderContainer createScopedContainer(ProviderContainer parent) {
  return ProviderContainer(
    parent: parent,
    overrides: [rootValueProvider.overrideWith((ref) => 0)],
  );
}
