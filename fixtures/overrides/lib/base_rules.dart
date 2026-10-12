import 'package:flutter/material.dart';

// 배포 파일에 적혀 있지만 기반 세트(flutter_lints / lints)도 켜는 규칙 6개와,
// 기반 세트만 켜는 규칙 1개를 규칙마다 한 건씩 어긴다.

/// `sized_box_for_whitespace` — 여백용 Container (width 와 height 둘 다 준다.
/// width 하나만 주면 이 규칙이 걸리지 않는다).
Widget whitespace() => Container(width: 8, height: 8);

/// `sort_child_properties_last` — child 를 마지막 인자로 두지 않음.
Widget childFirst(Key key) =>
    Padding(key: key, child: const Text('c'), padding: EdgeInsets.zero);

/// `use_build_context_synchronously` — await 뒤의 BuildContext 사용.
Future<void> afterAwait(BuildContext context) async {
  await Future<void>.delayed(Duration.zero);
  Navigator.of(context).pop();
}

/// `avoid_print` — print 호출.
void printing() {
  print('d');
}

/// `control_flow_in_finally` — finally 블록 안의 return.
int inFinally() {
  try {
    return 1;
  } finally {
    return 2;
  }
}

/** `slash_for_doc_comments` — 별표 문서 주석. */
void starDoc() {}

/// `prefer_is_empty` — 기반 세트(lints core)만 켜는 규칙. 배포 파일에는 없다.
bool emptyCheck(List<int> items) => items.length == 0;
