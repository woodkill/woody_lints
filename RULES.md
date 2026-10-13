# woody_lints 규칙 근거

이 문서는 `woody_lints` 가 기반 세트(`flutter_lints` / `lints`) 위에 무엇을 더 켜고 무엇을 켜지 않았는지, 그리고 그 이유를 규칙마다 적는다. 표의 수치는 실제 사용 프로젝트 `flutter_starter_kit` 의 복사본에서 잰 것이며, 회차마다의 조건(SDK · 기반 세트 · plugin 버전)은 아래 "실측 기록" 절에 있다. 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록은 검증 명령(`fvm dart run tool/verify.dart`)의 "배포 파일의 구성" 단계가 서로 같은지 견준다 — 둘은 같은 커밋에서 고친다.

## 켠 규칙

`lib/base.yaml` 의 `linter: rules:` 에 적힌 규칙이다. "켠 이유" 는 `lib/base.yaml` 의 사유 주석과 같은 문장이다.

<!-- woody:enabled-rules:start -->
| 규칙 | 분류 | 켠 이유 | 실측 (lib · test · bin) | dart fix | 회차 |
|---|---|---|---|---|---|
| `prefer_const_constructors` | 성능 | 불변 위젯 트리를 const 로 적는 관례 — 성능 이득은 근거가 부족하다는 것이 Flutter 팀의 판단 (lints#205) | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `prefer_const_literals_to_create_immutables` | 성능 | 위와 같은 관례 — 불변 위젯에 넘기는 리터럴도 const 로 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `always_declare_return_types` | 가독성·스타일 | 기반 세트의 strict_top_level_inference 가 보지 않는 지역 함수 · 옛 typedef 의 반환 타입까지 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `prefer_final_locals` | 가독성·스타일 | 데이터의 불변성 보장 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `prefer_single_quotes` | 가독성·스타일 | 홑따옴표('') 사용 통일 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
| `unawaited_futures` | 버그 방지 | 처리되지 않은 Future 감지 | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
<!-- woody:enabled-rules:end -->

### 켠 analyzer 옵션

`lib/base.yaml` 의 `analyzer: language:` 아래 `true` 로 켠 옵션이다.

<!-- woody:enabled-options:start -->
| 옵션 | 켠 이유 | 실측 | 회차 |
|---|---|---|---|
없음 — analyzer 옵션을 켜지 않았다.
<!-- woody:enabled-options:end -->

## 켜지 않은 규칙

검토했지만 `lib/base.yaml` 에 적지 않은 규칙이다. "이유" 칸은 아래 접두사 7종 가운데 하나로 시작한다.

- `기반 세트` — 기반 세트(`flutter_lints` / `lints`)가 이미 켠다. 어느 세트 파일이 켜는지 함께 적는다
- `비호환` — 이미 켠 규칙과 함께 쓸 수 없다
- `experimental` 또는 `testing` — 상류가 안정 상태로 두지 않은 규칙이다
- `v2 로 미룸 (RULES-NN)` — 다음 마일스톤의 요구사항으로 미뤘다
- `deprecated` · `removed` · `없음` — 지금 SDK 에서 쓸 수 없는 이름이다
- `규칙이 돌지 않음` — 켜도 보고하지 않는다 (일부러 넣은 위반까지 0줄)
- `소유자 결정` — 실측을 보고 소유자가 켜지 않기로 했다

<!-- woody:disabled-rules:start -->
| 규칙 | 이유 |
|---|---|
| `sized_box_for_whitespace` | 기반 세트 — `flutter_lints` 6.0.0 `flutter.yaml` 이 켠다 |
| `sort_child_properties_last` | 기반 세트 — `flutter_lints` 6.0.0 `flutter.yaml` 이 켠다 |
| `slash_for_doc_comments` | 기반 세트 — `lints` 6.1.0 `recommended.yaml` 이 켠다 |
| `use_build_context_synchronously` | 기반 세트 — `flutter_lints` 6.0.0 `flutter.yaml` 이 켠다 |
| `avoid_print` | 기반 세트 — `flutter_lints` 6.0.0 `flutter.yaml` 이 켠다 |
| `control_flow_in_finally` | 기반 세트 — `lints` 6.1.0 `recommended.yaml` 이 켠다 |
<!-- woody:disabled-rules:end -->

formatter: 설정은 기본 프리셋에 넣지 않는다 (04-CONTEXT.md D-13, REQUIREMENTS.md Out of Scope)

## 실측 기록

<!-- woody:measurements:start -->
(tool/measure_rules.dart --report --write 가 생성한다. 손으로 고치지 않는다.)
<!-- woody:measurements:end -->
