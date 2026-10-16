import 'package:flutter/material.dart';

/// 앱 진입점.
///
/// 일부러 어긴 규칙:
/// - `avoid_print` (기반 세트), `prefer_single_quotes` (woody_lints 가 추가) — 둘 다 info
/// - `missing_provider_scope` (riverpod_lint) — plugin 이 살아 있을 때만 나온다
void main() {
  print("spike 002");
  runApp(const MaterialApp(home: SizedBox()));
}
