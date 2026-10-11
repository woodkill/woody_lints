import 'package:riverpod_annotation/riverpod_annotation.dart';

// 생성 코드 대신 쓰는 가짜 기반 클래스 (upstream 테스트와 같은 방식).
typedef _$AbstractNotifier = Object;

/// `riverpod_syntax_error` — `@riverpod` class 를 abstract 로 선언한다.
@riverpod
abstract class AbstractNotifier extends _$AbstractNotifier {
  /// 초기 상태.
  int build() => 0;
}
