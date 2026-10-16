// woody_lints 2.0.0 에서 새로 켠 strict 계열 lint 를 규칙마다 한 건씩 어긴다. 한 줄에서 규칙 하나만 걸리게 둔다.
// analyzer 옵션 strict-inference 는 켜지 않았다 (소유자 결정 2026-10-13) — 그 샘플은 없다.

/// `no_dynamic_casts` — dynamic 값을 구체 타입 자리에 그대로 넣는다 (암묵적 cast).
int dynamicCast(dynamic value) {
  final int result = value;
  return result;
}

/// 타입 매개변수 하나를 가진 상자 (아래 줄이 타입 인자 없이 쓴다).
class Box<T> {}

/// `no_raw_types` — 타입 인자를 생략한 제네릭 타입.
Box rawBox = Box<int>();
