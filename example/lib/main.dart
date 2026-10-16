import 'package:flutter/material.dart';

/// `missing_provider_scope` (riverpod_lint, warning) — ProviderScope 없이 runApp 을 부른다.
void main() {
  runApp(const MaterialApp(home: SizedBox()));
}
