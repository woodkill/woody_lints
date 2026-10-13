import 'dart:io';

import 'package:flutter/material.dart';

// woody_lints 2.0.0 에서 새로 켠 성능 규칙을 규칙마다 한 건씩 어긴다. 한 줄에서 규칙 하나만 걸리게 둔다.

/// `avoid_slow_async_io` — 느린 dart:io async 메서드.
Future<bool> slowIo() => File('woody_missing.txt').exists();

/// 자기 runtimeType 을 문자열로 바꾸는 클래스 (이 규칙은 다른 값의 runtimeType 은 보지 않는다).
class RuntimeTypeName {
  /// `no_runtimetype_tostring` — runtimeType 의 toString().
  String name() => runtimeType.toString();
}

/// `noop_primitive_operations` — int 에 부른 toInt().
int noopInt(int x) => x.toInt();

/// `prefer_const_declarations` — const 로 선언할 수 있는 final.
final int finalLiteral = 1;

/// `sized_box_shrink_expand` — SizedBox.shrink 로 쓸 수 있는 SizedBox.
Widget shrinkBox() => const SizedBox(width: 0, height: 0);

/// `use_colored_box` — 색만 지정한 Container.
Widget coloredContainer() => Container(color: Colors.red, child: const Text('a'));

/// `use_string_buffers` — 루프 안에서 문자열을 누적해 잇는다.
String joinAll(List<String> parts) {
  var joined = '';
  for (final part in parts) {
    joined += part;
  }
  return joined;
}

/// `use_truncating_division` — (a / b).toInt().
int truncatingDivision(int a, int b) => (a / b).toInt();
