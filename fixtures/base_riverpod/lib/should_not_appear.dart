import 'package:flutter/foundation.dart';

/// `invalid_annotation_target` — class 전용 annotation(`@immutable`)을 함수에 붙인다.
/// 배포 파일의 `invalid_annotation_target: ignore` 가 억제하므로 정답지에 없어야 한다.
@immutable
void wrongTarget() {}
