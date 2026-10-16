// `prefer_relative_imports` — lib 안의 같은 패키지 파일을 package: 주소로 import 한다 (자기 자신).
// 이 파일만 연습용 프로젝트마다 다르다 — 아래 import 의 패키지 이름이 그 프로젝트의 이름이다.
import 'package:woody_lints_fixture_base_only/relative_imports_rule.dart' as same_package;

/// 위 import 로 다시 읽는 값.
const int relativeImportValue = 1;

/// 위 import 한 이름을 쓰는 자리 (쓰지 않으면 unused_import 가 함께 걸린다).
int readRelativeImport() => same_package.relativeImportValue;
