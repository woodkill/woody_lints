import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'r07_provider_dependencies.g.dart';

/// scope 될 수 있는 provider.
@Riverpod(dependencies: [])
int scopedDep(Ref ref) => 0;

/// `provider_dependencies` — 쓰지 않는 provider 를 `dependencies` 에 적는다.
@Riverpod(dependencies: [scopedDep])
int unusedDependency(Ref ref) => 0;
