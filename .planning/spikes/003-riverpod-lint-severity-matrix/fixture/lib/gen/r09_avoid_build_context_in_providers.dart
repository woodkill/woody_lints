import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'r09_avoid_build_context_in_providers.g.dart';

/// `avoid_build_context_in_providers` — provider 가 `BuildContext` 를 인자로 받는다.
@riverpod
int withContext(Ref ref, BuildContext context) => 0;
