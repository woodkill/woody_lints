import 'package:flutter/material.dart';

/// 앱 진입점.
///
/// 일부러 어긴 규칙:
/// - `avoid_print` (기반 세트), `prefer_single_quotes` (woody_lints 가 추가)
/// - `missing_provider_scope` (riverpod_lint, warning 으로 선언됨)
void main() {
  print("spike 001");
  runApp(const MaterialApp(home: SizedBox()));
}
