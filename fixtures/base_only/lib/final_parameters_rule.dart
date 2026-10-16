// @dart=3.11
// `avoid_final_parameters` — 이 파일만 언어 버전 3.11 로 둔다. 언어 버전 3.13 에서는 primary constructor
// 기능이 켜져 이 규칙이 돌지 않고 보통 매개변수의 final 이 error 다 (style_rules.dart 머리 주석).

/// `avoid_final_parameters` — 매개변수 선언의 final.
int finalParameter(final int x) => x;
