# Phase 4 의 평가표 — 열마다 값을 얻는 법

Phase 4 (Rule Reselection) 의 평가표를 채우는 부분이다. ROADMAP.md Phase 4 Notes 는 열을 `state` / 심각도 / `fixStatus` / 실측 건수 / `dart fix` 가능 건수 / 상류 세트 포함 여부로 고정하고 "규칙 메타데이터는 SDK tag 고정 `rules.json` 을 기준으로 삼는다", "기준선(1.3.0) 대비 차이만 규칙의 값으로 쓴다", "양립 불가 쌍은 한쪽씩 나눠 돌린다" 고 적었다. 네 spike 가 그 문장들을 실행으로 확인했다 — `rules.json` 문장은 그대로 쓸 수 없고, 기준선 문장에는 조건이 붙었다 (로드맵 문구와 부딪치거나 좁혀진 곳 전부는 1번 끝).

실측의 틀 — 사용 프로젝트의 복사본, `pubspec_overrides.yaml`, 받은 자리 확인, 일부러 넣은 위반(표식), 비공개 프로젝트의 기록 — 은 real-consumer-measurement.md 에 있다. 규칙 이름이 deprecated / removed / 없는 것인지를 거르는 검증 명령의 단계(VERIFY-02)는 rule-status-check.md 에 있다. 이 문서는 그 위에서 **열마다 어느 출처의 어느 숫자를 적는가** 를 다룬다.

모든 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64, 2026-10-12 실측이다. 상류 파일은 SDK tag 3.13.4 의 것을 읽었다 (020 ~ 022). 사용 프로젝트는 `flutter_starter_kit` **하나**이고, 그날의 복사본(Dart 파일 469개, SDK 제약 `^3.11.1`)이다. 019 는 같은 날 468개로 셌다 — 세는 범위(`lib` · `test` · `bin` 의 `.dart`)는 같고, 그 사이에 프로젝트가 바뀌었는지는 확인하지 않았다. 021 ~ 023 의 복사본은 프리셋을 나눈 **뒤**의 작업 중인 저장소를 `path:` 로 받았다.

이 문서에서 쓰는 말.

- **평가표** — ROADMAP.md Phase 4 성공 기준 1 의 "표 하나". 후보 규칙 하나가 한 줄이다.
- **표식** · **프로젝트의 줄** · **복사본** — real-consumer-measurement.md 와 같다. 표식은 `lib/woody_probe_marker/` 아래에 일부러 넣은 위반이고, 프로젝트의 줄은 표식이 아닌 진단이다.
- **지금 하한** — 사용 프로젝트의 SDK 하한 `^3.11.1` (언어 버전 3.11). **저장소 하한** — 이 저장소의 `^3.13.0`.
- **단독 dry** — `dart fix --dry-run --code=<규칙>`. **그룹 dry** — 그룹 하나(022 의 `G1` ~ `G4`, 1부는 새 규칙 10개)의 규칙을 모두 켠 채 `dart fix --dry-run` 한 번. 022 의 README 는 그룹을 "묶음", 이것을 "묶음 dry" 라고 적었다 — 이 skill 에서 "묶음" 은 `recommended.yaml` 이라 바꿔 부른다. **apply** — 소스를 원본으로 되돌리고 `dart fix --apply --code=<규칙>` 한 뒤 다시 분석한 것.
- 실행은 spike 마다 id 로 부른다. 020 의 `pkg13` · `pkg11` (하한만 다른 두 패키지), 021 의 1부 `p311old` · `p313old` · `p313new` · `p311new` 와 2부 `B0` · `B1` · `B2`, 022 의 그룹 `G1` ~ `G4`, 023 의 `I0` ~ `I4`. 019 의 `V0` · `N1u` 와는 다른 실험이다.
- **판정 id** — `K1` ~ `K7` 은 spike 마다 따로 매겼다 (`K5` 가 021 에서는 plugin 준비, 022 에서는 저장소 불변, 023 에서는 가린 표식이다). 이 문서는 확인의 내용으로 부른다.
- **작업 브랜치의 프리셋** — 2026-10-12 의, 프리셋을 나눈 뒤의 `lib/` (`base.yaml` 등). SKILL.md 의 날짜 없는 "지금" (나누기 전의 저장소)과 다르다. "지금 하한" 은 위의 뜻이다.
- **testing** — `analyzer` 14.5.0 의 `RuleState.testing`. 설명은 "experimental, temporary, and have no stability guarantees … not recommended for general use" 다.

"N번" 은 아래의 절 번호다.

## Requirements

MANIFEST.md 의 `rule-reselection-measurement` 에서.

소유자가 확정한 것 (2026-10-12, `/gsd-spike` 의 후보 선택).

- 네 개(020 ~ 023)를 Phase 4 의 논의보다 먼저 돌린다

spike 가 스스로 건 조건 (019 의 조건을 그대로 잇는다).

- `flutter_starter_kit` 원본은 읽기만 한다. 실측은 저장소 밖 작업 폴더의 복사본에서 한다 (PROJECT.md 의 Safety)
- 비공개 프로젝트를 잰 결과에는 건수와 규칙 이름만 남긴다 — 경로 · 진단 메시지 · 코드 조각을 남기지 않는다. 원본의 경로는 스크립트에 적지 않고 인자로 준다
- 저장소의 `lib/`, `example/`, `fixtures/`, `pubspec.yaml`, 루트 `analysis_options.yaml` 은 바꾸지 않는다. GitHub 에 올리지 않는다
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 하고, 스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다
- 결과는 어느 쪽이든 기록하고 계속한다. 복사본의 `pub get` 이나 분석이 작업 중인 저장소를 바꾸면 그 자리에서 멈춘다

spike 에서 나와 Phase 4 의 실측과 평가표가 지켜야 하는 것.

- 평가표의 `state` 열을 SDK tag 의 `rules.json` 에서 옮기지 않는다 — 상류가 같은 폴더의 README 에 "unsupported and deprecated, should not be relied on" 이라고 적었고, tag 3.13.4 의 그 파일은 `unnecessary_await_in_return` 을 stable 로 적었으며 `migrate_design_widgets` 를 빠뜨렸다. deprecated / removed / 없는 이름은 후보를 적은 옵션 파일을 저장소와 같은 하한(`^3.13.0`)을 적은 pubspec 옆에서 분석해 정하고 (020 은 저장소 밖에 그런 패키지를 따로 만들었다), stable / experimental / testing 은 tag 의 `pkg/linter/messages.yaml` 에서 읽는다. 출처끼리 갈리는 넷(`unnecessary_ignore`, `unnecessary_underscores`, `use_primary_constructors`, `migrate_design_widgets`)은 출처마다 적는다 (020)
- 상류 세트 열은 저장소 루트가 받은 `lints` · `flutter_lints` 의 YAML 에서 읽는다. tag 3.13.4 의 `rules.json` 의 `sets` 는 262개 모두 비어 있다. 이름은 소문자로 맞춰 견준다 (`prefer_iterable_whereType`) (020)
- 비호환 쌍은 쌍마다 둘만 켜서 확인한다. 한 옵션 파일에 모두 켠 실행에서는 규칙 한 줄에 `incompatible_lint` 가 하나만 붙었고 일부 쌍(`unnecessary_final` × `prefer_final_locals` 등)이 보이지 않았다 (Dart 3.13.4, 실행 하나 — analyzer 가 한 줄에 하나만 알린다는 것은 그 결과로 세운 해석이다). `rules.json` 이 선언한 12쌍은 따로 켜면 모두 보고된다 (020)
- `migrate_design_widgets` 와 `use_primary_constructors` 는 tag 3.13.4 의 원본에서 `testing` (안정성 보장 없음, 일반 사용을 권하지 않음)이다. 후보 표에 올릴 때 이 상태를 함께 적는다 (020. `use_primary_constructors` 는 규칙 소스도 `.testing` 이다 — 021)
- Dart 3.13 의 새 규칙 가운데 6개(`empty_container_bodies`, `unnecessary_type_name_in_constructor`, `unnecessary_const_in_enum_constructor`, `use_primary_constructors`, `initialize_in_field_declaration`, `use_declaring_parameters`)는 언어 버전 3.11 의 라이브러리에서 돌지 않는다 — 연습용 패키지에서 6개 모두, `flutter_starter_kit` (`^3.11.1`) 의 복사본에서는 표식을 둔 넷(`empty_container_bodies`, `unnecessary_type_name_in_constructor`, `unnecessary_const_in_enum_constructor`, `use_primary_constructors`)이 그 규칙을 어기는 표식까지 0줄이다 (나머지 둘의 표식은 3.13 문법이라 지금 하한의 복사본에 넣지 않았다. 막는 조건이 primary constructor 기능이라 3.13 미만이면 꺼질 것이다 — 규칙 소스를 읽은 것이고 3.12 는 재지 않았다). 평가표에는 이 규칙들의 값을 둘 적는다: 지금 하한에서(0, 규칙이 돌지 않음)와 복사본의 하한만 `^3.13.0` 으로 올린 실행에서. `async_return_with_no_await`, `no_raw_types`, `no_dynamic_casts`, `strict-inference` 는 하한 3.11 에서도 돈다 (021)
- 하한을 올린 복사본으로 잴 때는 기준선도 하한을 올린 채 다시 잰다. 복사본의 하한을 `^3.13.0` 으로 올리는 것만으로 기반 세트의 `prefer_initializing_formals` 가 private named parameters 를 보기 시작해 `flutter_starter_kit` 에서 27줄이 생긴다 (Dart 3.12 에서 넓어진 동작이라 하한 3.12 에서도 생길 것이다 — CHANGELOG 와 규칙 소스를 읽은 추정이고, 3.12 하한은 재지 않았다) (021)
- 복사본의 `pubspec_overrides.yaml` 은 `path:` 로 작업 중인 저장소 자체를 가리킨다 — replica 를 만들지 않는다. 받은 자리(`package_config.json` 의 `rootUri`)가 저장소가 아니면 그 회차를 버리고, 실행 전후로 저장소의 지문(`git status`, `.dart_tool/` 의 맨 위 이름, 루트 `package_config.json` · `pubspec.lock`)을 견준다. 두 번의 `pub get` 과 세 번의 분석 뒤에도 저장소는 그대로였다. 이 방법은 `021-new-rules-language-gate/consumer.dart` 에 있다 (021). `dart fix --dry-run` 한 번과 `--apply --code=use_primary_constructors` 한 번도 저장소를 바꾸지 않았다 (022 의 `repo_guard.dart` — 022 의 본 실행은 지문 확인이 깨져 이것으로 다시 확인했다)
- 복사본의 SDK 하한을 바꿀 때는 `pubspec.yaml` 을 고친 뒤 `pub get` 을 한다 (`Consumer.useSdk`). `pubspec.yaml` 만 고치면 `package_config.json` 의 `languageVersion` 이 앞의 값으로 남는다 (022)
- 평가표의 "`dart fix` 로 고칠 수 있는 건수" 는 소스를 원본으로 둔 복사본에서 그 규칙만 `dart fix --apply --code=<규칙>` 한 뒤 다시 분석해 **사라진 그 규칙의 줄 수**로 적고, apply 뒤 새로 생긴 다른 진단(특히 error)의 수를 함께 적는다. `--dry-run --code=` 의 수는 수정 수라서 사라지는 줄과 두 방향으로 다르다 (`flutter_starter_kit` 복사본에서 단독 dry → 사라진 줄: `always_put_required_named_parameters_first` 16 → 32줄, `comment_references` 10 → 100줄, `avoid_redundant_argument_values` 155 → 123줄). 규칙을 모두 켠 한 번의 dry-run 은 규칙끼리 섞여 쓰지 않는다. `rules.json` 의 `hasFix` 도 쓰지 않는다 — `hasFix` 인데 단독 dry 가 0 인 규칙이 있다 (`always_put_control_body_on_new_line` 진단 398 · 단독 dry 0, `async_return_with_no_await`, `discarded_futures`, `prefer_foreach`, `unreachable_from_main` — apply 는 하지 않았다) (022)
- apply 가 코드를 깨뜨리는 규칙이 있다 — `flutter_starter_kit` 복사본에서 `diagnostic_describe_all_properties` (error 148), `always_specify_types` · `specify_nonobvious_local_variable_types` (`ambiguous_import` 등). `base.yaml` 의 규칙과 반대인 `prefer_double_quotes` · `unnecessary_final` 은 고친 만큼 반대 진단이 생긴다. dart fix 는 plugin 을 준비하지 않아 `riverpod_lint` 진단을 고치지 않는다 (022)
- `sort_pub_dependencies` 는 Dart 3.13.4 의 `dart fix` 로 고쳐지지 않는다 (돌린 것은 단독 dry 하나 — 진단 2 · 수정 0, apply 는 하지 않았다. 읽은 것: tag 의 `rules.json` 은 `needsFix`, analysis_server 의 등록 없음, 사이트(`main`)는 `hasFix`) (022)
- 평가표의 값은 사용 프로젝트의 무시 주석을 둔 채로 잰다 (채택하면 실제로 받는 줄). 주석이 가린 줄은 따로 한 칸으로 적는다 — `flutter_starter_kit` 에서는 `lines_longer_than_80_chars` 260줄, `discarded_futures` 2줄이다. 로드맵의 "`cast_nullable_to_non_nullable` 56건" 은 생성 파일 안의 freezed 주석이라 아무것도 가리지 않는다 (그 규칙의 값은 5줄) (023)
- 기준선 0줄은 "무시 주석이 있는 채로 0" 이다. `flutter_starter_kit` 의 손으로 쓴 파일 다섯 개가 `ignore_for_file: type=lint` 를 달아 lint 26줄(이 패키지의 `prefer_final_locals` 4줄 포함)을 가리고, 그 파일들은 어떤 lint 후보에도 보이지 않는다. 지금 아무것도 가리지 않는 낡은 주석(`avoid_print`, `use_build_context_synchronously`)이 있다 (023)
- `unnecessary_ignore` 는 켜져 있지 않은 규칙을 가리키는 주석도 보고한다 — 값이 다른 후보의 채택에 묶인다 (`flutter_starter_kit` 에서 작업 브랜치의 프리셋(2026-10-12, 나눈 뒤) 기준 38줄, 세 후보를 함께 켜면 12줄). 다른 후보의 채택이 정해진 뒤에 다시 잰다 (023)

MANIFEST.md 의 `preset-split-include-behavior` 에서 이 영역에 걸리는 것 (019 — 실측의 틀).

- 사용 프로젝트를 재는 실측은 복사본에 `pubspec_overrides.yaml` 로 `woody_lints` 를 작업 중인 파일의 경로로 돌리고, 같은 실행에 일부러 넣은 위반(표식 파일)을 둔다. 0줄을 표식 없이 해석하지 않는다 (019)
- 비공개인 사용 프로젝트를 잰 기록에는 그 프로젝트의 경로 · 진단 메시지 · 코드 조각을 남기지 않고 건수와 규칙 이름만 남긴다. 소유자가 정한 것이 아니라 spike 가 스스로 건 조건이다 — Phase 4 의 근거 문서가 공개 저장소에 들어가므로 그 논의에서 확인한다 (019)

## How to Build It

### 1. 열마다 출처 — 한눈에

| 열 | 값을 얻는 곳 | 쓰지 않는 것 | 근거 |
|---|---|---|---|
| `state` — deprecated / removed / 없는 이름 | 후보를 적은 옵션 파일을 **저장소와 같은 하한(`^3.13.0`)을 적은 pubspec 옆**에서 분석한 결과 (저장소 밖이어도 된다) | `rules.json` 의 `state` | 020 → 2번 |
| `state` — stable / experimental / testing / internal | tag 3.13.4 의 `pkg/linter/messages.yaml`. 출처끼리 갈리는 넷은 출처마다 적는다 | 분석 (둘 다 아무 진단이 없어 가르지 못한다) | 020 → 3번 |
| 심각도 | 네 spike 가 따로 다루지 않았다 | — | — |
| `fixStatus` | `rules.json` 의 값은 "고치는 방법이 등록되어 있다" 까지다. 열을 둔다면 그 뜻으로 적는다 | "dart fix 가 고친다" 로 읽는 것 | 022 → 8번 |
| 실측 건수 | 복사본에서 **무시 주석을 둔 채로** 잰 그 규칙의 줄. 언어 버전 3.13 에서만 도는 6개는 값을 둘 적는다 | 지금 하한에서 잰 그 6개의 0 | 021 → 6번, 023 → 7번 |
| (새 칸) 주석이 가린 줄 | 주석을 걷어낸 복사본과의 차이 | — | 023 → 7번 |
| `dart fix` 가능 건수 | 그 규칙만 apply 한 뒤 **사라진 그 규칙의 줄**, 그리고 새로 생긴 다른 진단(특히 error) | 단독 dry 의 수, 그룹 dry 의 수, `hasFix` | 022 → 8번 |
| 상류 세트 포함 여부 | 저장소 루트의 `package_config.json` 이 가리키는 `lints` · `flutter_lints` 의 YAML | `rules.json` 의 `sets` (전부 비어 있다) | 020 → 4번 |
| 비호환 쌍 | `rules.json` 의 `incompatible` 선언. 확인은 쌍마다 둘만 켜서 | 전부 켠 실행의 `incompatible_lint` 수 | 020 → 5번 |

- **로드맵 문구 가운데 그대로 쓸 수 없는 것은 둘이다.** "규칙 메타데이터는 SDK tag 고정 `rules.json` 을 기준으로 삼는다" 는 `state` · 상류 세트 열에서 성립하지 않는다 (020). 고정한 열 가운데 `fixStatus` 를 `rules.json` 에서 채우면 "dart fix 로 고쳐진다" 가 아니라 "등록이 있다" 는 뜻이 된다 (022). 열을 그대로 둘지, 뜻을 적어 둘지는 Phase 4 의 논의가 정한다.
- **범위나 방법이 좁혀진 것은 다섯이다.** "기준선(1.3.0) 대비 차이" — 기준선은 무시 주석이 있는 채의 0줄이고, 하한을 올린 복사본은 기준선을 다시 잰다 (7번, 6번). "양립 불가 쌍은 한쪽씩 나눠 돌린다" — 확인은 쌍마다 둘만 켜서 한다 (5번). "Spike first" 넷째의 "`dart fix --dry-run` 으로" — 건수는 apply 로 센다 (8번). 같은 항목의 "`sort_pub_dependencies` 는 출처마다 어긋난다" — tag 와 사이트 `main` 의 차이다 (8번). "Spike first" 둘째의 "`cast_nullable_to_non_nullable` 56건" — 생성 파일 안의 주석이다 (7번). SKILL.md 의 "뒤의 spike 가 바꾼 결론" 아래 문단에도 같은 목록이 있다.
- 심각도 열의 출처는 이 spike 들이 정하지 않았다. 결과 파일에는 표식 줄마다 JSON 의 `severity` 를 소문자로 적었고(`Diag.text`), 프로젝트의 줄은 규칙별 건수만 남겼다.

### 2. `state` — deprecated · removed · 없는 이름은 분석으로 가른다

규칙만 적은 순수 Dart 패키지를 만들고 Dart 3.13.4 로 분석한다. 하한을 적은 pubspec 이 있으면 저장소 밖에 둬도 된다 (deprecated / removed 는 pubspec 의 하한을 따른다 — rule-status-check.md 의 Constraints). 옵션 파일의 3행부터 규칙 하나씩이라 진단의 줄 번호로 규칙을 찾는다.

```dart
// sources/020-rule-state-vs-rules-json/probe.dart 의 analyzeAll 에서
File('${dir.path}/pubspec.yaml')
    .writeAsStringSync('name: spike_rule_state\npublish_to: none\nenvironment:\n  sdk: $constraint\n');
File('${dir.path}/lib/a.dart').writeAsStringSync('/// 분석 대상이 비지 않게 두는 파일.\nint answer() => 42;\n');
final options = StringBuffer('linter:\n  rules:\n');
for (final r in rules) {
  options.writeln('    - $r');
}
// … dart pub get, 빈 상태 폴더로 dart --suppress-analytics analyze --format=json
final index = line - 3;            // 진단의 줄 → 규칙
(a.byRule[rules[index]] ??= []).add(code);
```

두 메타데이터에 있는 이름 275개 전부와 대조용 없는 이름 하나를 적었다.

| 실행 | 하한 | exit | 진단 (모두 옵션 파일, 모두 warning) | 시간 |
|---|---|---|---|---|
| `pkg13` | `^3.13.0` (저장소 하한) | 2 | `removed_lint` 14 · `undefined_lint` 12 · `deprecated_lint` 6 · `incompatible_lint` 10 | 0.47초 |
| `pkg11` | `^3.11.1` (`flutter_starter_kit` 의 하한) | 2 | `removed_lint` 14 · `undefined_lint` 12 · `deprecated_lint` **3** · `incompatible_lint` 10 | 0.47초 |

- **deprecated 6 · removed 14 는 `messages.yaml` 과 하나도 다르지 않다.** `rules.json` 은 deprecated 를 5개로 적었다 — `unnecessary_await_in_return` 을 stable 로 적은 것이 005 가 찾은 그 하나다.
- deprecated 6: `avoid_null_checks_in_equality_operators`, `prefer_final_parameters`, `use_if_null_to_convert_nulls_to_bools` (3.11) 과 `avoid_private_typedef_functions`, `one_member_abstracts`, `unnecessary_await_in_return` (3.13).
- **하한 `^3.11.1` 에서는 3.13 에 deprecated 된 셋이 아무 진단도 내지 않는다 (`pkg11`).** 하한이 같은 `^3.11.1` 인 사용 프로젝트의 복사본에서도 그 셋이 deprecated 라는 것이 보이지 않을 것이다 (`pkg11` 의 결과를 옮긴 것이고 복사본으로 잰 것은 아니다). 그래서 이 열은 복사본이 아니라 저장소 하한의 패키지로 정한다.
- `undefined_lint` 12 = `messages.yaml` 의 `internal` 11개(`analyzer_*` 8개, `no_solo_tests`, `no_trailing_spaces`, `visit_registered_nodes`) + 대조용 이름 하나.
- **`rules.json` 에 없는데 켜지는 이름이 둘이다** — `migrate_design_widgets` (`messages.yaml` 은 testing 3.13), `erase_dart_type_extension_types` (internal 3.3). 둘 다 진단 없이 켜진다. 앞의 것은 FEATURES.md 의 후보 표에 올라 있다.
- 판정에 넣은 확인 7건이 모두 성립했다 — 두 분석 모두 JSON 을 냈다, 없는 이름 → `undefined_lint` (두 하한), `unnecessary_await_in_return` → `^3.13.0` 에서만 `deprecated_lint`, `avoid_returning_null` → `removed_lint` (두 하한), 옵션 파일 밖의 진단 0, 저장소 불변(처음과 끝의 지문), 쌍마다 둘만 켠 실행에서 `prefer_single_quotes` × `prefer_double_quotes` 가 보고된다.

### 3. `state` — stable / experimental / testing 은 `messages.yaml` 에서 읽는다

experimental 규칙을 켜도 아무 진단이 없다 (`rules.json` 의 experimental 11개 모두). 이 구분은 메타데이터에만 있다.

**`rules.json` 을 쓰지 않는 까닭.** 같은 tag 의 `pkg/linter/tool/machine/README.md` 첫머리 (2026-10-12 읽음):

> The `rules.json` file is unsupported and deprecated, and should **not** be relied on.
> … In the future, it will stop receiving updates and will be removed without notice.
> … Some of the information in the `rules.json` file is instead available in the `pkg/linter/messages.yaml` file.

| 출처 | 이름 수 | `state` 의 분포 |
|---|---|---|
| `rules.json` (tag 3.13.4) | 262 | stable 232 · removed 14 · experimental 11 · deprecated 5 |
| `messages.yaml` (tag 3.13.4) | 275 | stable 229 · removed 14 · internal 12 · experimental 12 · deprecated 6 · testing 2 |

`messages.yaml` 은 `LinterLintCode:` 아래에 진단 코드마다 항목이 있고, 상태는 항목의 `state:` 블록이다 (예: `unnecessaryAwaitInReturn` 의 `stable: "2.1"` · `deprecated: "3.13"`). 같은 규칙의 코드는 `sharedName` 으로 묶이고 그중 하나만 `state:` 를 적는다. 020 은 yaml 패키지 없이 들여쓰기(2칸 = 코드, 4칸 = 속성, 6칸 = 상태)에 기대어 줄 단위로 읽었다.

```dart
// sources/020-rule-state-vs-rules-json/probe.dart 에서
/// `linesLongerThan80Chars` → `lines_longer_than_80_chars`.
/// 첫 실행은 숫자 앞에 `_` 를 넣지 않아 `lines_longer_than80_chars` 를 만들었다.
String snake(String camel) => camel
    .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
    .replaceAllMapped(RegExp(r'([a-z])(\d+)'), (m) => '${m.group(1)}_${m.group(2)}');
```

- 한 규칙에 상태가 여럿 적혀 있으면 가장 늦은 버전의 것을 쓴다 (`MessagesRule.latest` — 같은 버전이면 removed > deprecated > stable > experimental).
- **규칙 소스에 상태를 적은 규칙도 있고 적지 않은 규칙도 있다.** `unnecessary_await_in_return` (005) 과 `use_primary_constructors` (021 — `state: .testing(since: .new(3, 13, 0))`) 는 소스에 적혀 있고, `unnecessary_ignore.dart` 에는 없었다 (020). 상태를 한 곳에서 읽으려면 `messages.yaml` 이다.

세 출처가 갈린 규칙 (dart.dev 의 사이트 데이터는 site-www `main` 의 `linter_rules.json`, 2026-10-12 받음 — 스크립트 밖에서 본 것이고 결과 파일에는 없다). 넷은 `rules.json` 과 `messages.yaml` 을 이름 전부로 견줘 나온 것이고, 사이트 데이터는 이 넷과 `use_super_parameters` 만 봤다:

| 규칙 | `rules.json` | `messages.yaml` | 사이트 (`main`) | 상류 세트 |
|---|---|---|---|---|
| `unnecessary_ignore` | stable | experimental (3.8) | stable | — |
| `unnecessary_underscores` | stable | experimental (3.7) | stable | `lints` recommended |
| `use_primary_constructors` | experimental | testing (3.13) | (없음) | — |
| `migrate_design_widgets` | (없음) | testing (3.13) | stable | — |

- **`use_super_parameters` 는 세 출처 모두 experimental 인데 `lints` 6.1.0 의 recommended 에 들어 있다.** `flutter_lints` 가 recommended 를 include 하므로 이 패키지를 include 하는 프로젝트에서는 이미 켜져 있다 (include 사슬로 읽은 것). "experimental 이면 채택하지 않는다" 는 기준을 세우면 기반 세트와 부딪친다. `unnecessary_underscores` 도 `messages.yaml` 로는 experimental 인데 recommended 에 있다.
- `unnecessary_ignore` 는 로드맵 D13 이 이름을 적은 후보다. 어느 출처를 쓰느냐에 따라 `state` 가 달라진다.
- stable / experimental 이 갈린 규칙의 "진짜" 상태는 분석으로 가를 수 없다. 출처를 함께 적는 것이 요구 사항이다.

### 4. 상류 세트 포함 여부 — 저장소 루트가 받은 YAML 에서 읽는다

`rules.json` 262개 모두 `sets: []` 다. 상류 세트는 저장소 루트의 `.dart_tool/package_config.json` 이 가리키는 패키지의 YAML 을 읽는다.

```dart
// sources/020-rule-state-vs-rules-json/probe.dart 의 readUpstreamSets 에서
Set<String> rulesOf(String file) => File(file)
    .readAsLinesSync()
    .map((l) => RegExp(r'^    - (\w+)').firstMatch(l)?.group(1))
    .whereType<String>()
    .toSet();
// lints 의 lib/core.yaml · lib/recommended.yaml, flutter_lints 의 lib/flutter.yaml
```

- 2026-10-12 의 저장소 루트가 받은 버전은 `lints` 6.1.0, `flutter_lints` 6.0.0 이다. 파일마다 **직접 적힌** 규칙은 core 35 · recommended 58 · flutter 10 이고, `no_wildcard_variable_uses` 가 core 와 recommended 에 모두 적혀 있어 합집합은 102개다 (020 의 README 는 "합 102개" 라고만 적었다 — wrap-up 에서 pub cache 의 YAML 로 겹치는 이름을 확인했다). 102개 모두 두 메타데이터에 있다.
- recommended 는 core 를, flutter 는 recommended 를 include 한다. 표에 "어느 세트" 를 적을 때는 가장 아래 세트(core → recommended → flutter 순)로 적는다 (`UpstreamSets.of`).
- **이름은 소문자로 맞춰 견준다.** 상류 YAML 은 `prefer_iterable_whereType` · `prefer_for_elements_to_map_fromIterable` 처럼 대문자를 섞고, 두 메타데이터는 소문자로 적는다. analyzer 는 두 표기를 모두 받는다 (소문자 이름을 적은 020 의 실행에 `undefined_lint` 가 없었고, 기반 세트는 대문자 이름으로 늘 켜져 있다).
- 상류 세트에 든 규칙 가운데 `messages.yaml` 이 stable 이 아닌 것은 `unnecessary_underscores`, `use_super_parameters` 둘이다 (3번).

### 5. 비호환 쌍 — 쌍마다 둘만 켜서 본다

`rules.json` 이 선언한 쌍은 12개다.

| 쌍 | 전부 켠 실행 (`pkg13`) | 둘만 켠 실행 |
|---|---|---|
| `always_specify_types` × `avoid_types_on_closure_parameters` · `omit_local_variable_types` · `omit_obvious_local_variable_types` · `omit_obvious_property_types` (4쌍) | 보고 | 보고 |
| `always_use_package_imports` × `prefer_relative_imports` | 보고 | 보고 |
| `avoid_final_parameters` × `prefer_final_parameters` | 보고 | 보고 (+ `deprecated_lint`) |
| `omit_local_variable_types` × `specify_nonobvious_local_variable_types` | 보고 | 보고 |
| `omit_obvious_property_types` × `type_annotate_public_apis` | 보고 | 보고 |
| `prefer_double_quotes` × `prefer_single_quotes` | 보고 | 보고 |
| `prefer_final_in_for_each` × `unnecessary_final` | 보고 | 보고 |
| `prefer_final_locals` × `unnecessary_final` | **가려짐** | 보고 |
| `prefer_final_parameters` × `unnecessary_final` | **가려짐** | 보고 (+ `deprecated_lint`) |

- **전부 켠 실행에서 한 줄에 붙은 `incompatible_lint` 는 최대 1개였다.** `unnecessary_final` 줄에는 `prefer_final_in_for_each` 와의 충돌 하나만 붙어 나머지 둘이 가려졌다. analyzer 가 규칙 한 줄에 충돌을 하나만 알린다는 것은 두 실행의 결과로 세운 해석이고 소스로 확인하지는 않았다.
- 둘만 켠 실행에서 `incompatible_lint` 는 뒤에 적은 규칙의 줄에 붙었다 (12쌍 모두 4행 — 3행 · 4행에 하나씩 적었다). 강도는 warning 이다.
- "선언되지 않았는데 보고된 쌍 0" 은 전부 켠 실행 하나로 본 것이다. 그 실행은 한 줄에 하나만 보이므로 선언 밖의 쌍이 없다는 완전한 확인은 아니다 (추론).
- **작업 브랜치(2026-10-12, 나눈 뒤)의 `base.yaml` 에 켜진 규칙과 비호환인 후보가 있다** — `prefer_final_locals` × `unnecessary_final`, `prefer_single_quotes` × `prefer_double_quotes`. 사용 프로젝트가 프리셋의 규칙을 끄지 않고는 쓸 수 없다 (8번의 G3).
- 후보를 한꺼번에 재야 할 때는 비호환 쌍이 한 그룹에 들지 않게 나눈다. 022 의 나눔: G1 (106개), G2 (G1 과 비호환인 쪽 — `always_specify_types`, `prefer_relative_imports`, `specify_nonobvious_local_variable_types`, `type_annotate_public_apis`), G3 (`base.yaml` 과 비호환인 쪽 — `prefer_double_quotes`, `unnecessary_final`), G4 (primary constructor 와 함께 온 7개 — 6번의 막는 조건이 있는 6개와 3.13 문법이 있어야 걸리는 `unnecessary_primary_constructor_body`. 하한을 올린 복사본에서).

### 6. 실측 건수 — 언어 버전 3.13 에서만 도는 규칙

Dart 3.13 의 새 규칙과 strict 계열을 어기는 표식을, 하한만 다른 두 연습용 패키지(1부)와 사용 프로젝트의 복사본(2부)에서 분석했다.

| 규칙 | 언어 버전 3.11 | 3.13 | 왜 (tag 3.13.4 의 규칙 소스) |
|---|---|---|---|
| `async_return_with_no_await` | 보고 | 보고 | 막는 조건 없음 |
| `no_raw_types` | 보고 | 보고 | 막는 조건 없음 |
| `no_dynamic_casts` | 보고 | 보고 | 막는 조건 없음 |
| `strict-inference` (`inference_failure_on_*`) | 보고 | 보고 | 분석 옵션. 막는 조건 없음 |
| `empty_container_bodies` | **없음** | 보고 | `registerNodeProcessors` 첫머리에서 `Feature.primary_constructors` 가 꺼져 있으면 돌아간다 |
| `unnecessary_type_name_in_constructor` | **없음** | 보고 | 〃 |
| `unnecessary_const_in_enum_constructor` | **없음** | 보고 | 〃 |
| `use_primary_constructors` (testing) | **없음** | 보고 | 〃 |
| `initialize_in_field_declaration` | **없음** | 보고 (3.13 문법에서만) | 〃 + primary constructor 몸통만 본다 |
| `use_declaring_parameters` | **없음** | 보고 (3.13 문법에서만) | 〃 |
| `unnecessary_primary_constructor_body` | 문법 오류인 파일에서만 | 보고 (3.13 문법에서만) | 막는 조건은 없고 3.13 문법이 있어야 걸린다 |

- **막는 단위는 패키지가 아니라 라이브러리의 언어 버전이다.** 3.13 패키지 안에서도 `// @dart=3.11` 을 단 파일의 `empty_container_bodies` 표식은 아무 진단도 내지 않았다.
- `unnecessary_primary_constructor_body` 는 3.11 패키지에서 3.13 문법의 표식(`experiment_not_enabled` error 가 나는 파일)을 파서가 읽어 내 걸렸다. 오류 없이 컴파일되는 3.11 프로젝트에는 이 규칙이 걸릴 코드가 없다.
- 3.13 에서 이 규칙들은 넓게 걸린다. 생성자가 없는 클래스(`class BoxMarker<T> {}`)에 `empty_container_bodies` 와 `use_primary_constructors` 가, 클래스 이름으로 선언한 생성자마다 `unnecessary_type_name_in_constructor` 가 걸렸다 (enum 생성자 포함).
- 소스를 읽고 세운 추정은 스크립트의 `guess` 표에 적고 판정에 넣지 않았다. 추정과 다른 칸은 `unnecessary_primary_constructor_body` 하나였다.

표식은 3.11 문법으로 쓸 수 있는 것과 primary constructor 문법이어야 하는 것을 나눴다.

```dart
// sources/021-new-rules-language-gate/probe.dart 의 oldSamples 에서 둘
  'empty_container_bodies.dart': '''
/// 표식 — 몸통이 빈 클래스.
class EmptyBodyMarker {}
''',
  'no_dynamic_casts.dart': '''
/// 표식 — dynamic 에서의 암묵적 cast.
int dynamicCastMarker(dynamic x) {
  final int y = x;
  return y;
}
''',
```

- `strict-inference` 는 규칙이 아니라 분석 옵션이다. 021 은 사용 프로젝트의 옵션 파일 `analyzer:` 아래에 `language: strict-inference: true` 를 끼웠다 (`Consumer.optionsWith(language: …)`). `no_raw_types` · `no_dynamic_casts` 는 `linter: rules:` 에 규칙으로 켰다 (로드맵의 "strict 계열은 lint 형태로 잰다").

**사용 프로젝트의 복사본** (`B0` 원본 옵션 + 기본 표식, `B1` 새 규칙 + strict-inference + 새 규칙 표식 · 지금 하한, `B2` 같은 옵션 · 복사본의 하한만 `^3.13.0` + 3.13 문법 표식):

| 규칙 | B1 표식 | B1 프로젝트 | B2 표식 | B2 프로젝트 | 읽는 법 |
|---|---|---|---|---|---|
| `async_return_with_no_await` | 1 | **30** (`lib` 16 · `test` 14) | 1 | 30 | 지금 하한에서 그대로 잰 값 |
| `strict-inference` | 1 | **106** (`test` 106, 전부 `inference_failure_on_function_invocation`) | 1 | 106 | 〃 |
| `no_raw_types` | 1 | 0 | 1 | 0 | 표식이 걸렸으니 **진짜 0** |
| `no_dynamic_casts` | 1 | 0 | 1 | 0 | 〃 |
| `use_primary_constructors` | **0** | 0 | 5 | **968** (`lib` 258 · `test` 707 · `bin` 3) | 지금 하한의 0 은 **규칙이 돌지 않은 0** |
| `empty_container_bodies` | **0** | 0 | 2 | **615** (`test` 615) | 〃 |
| `unnecessary_type_name_in_constructor` | **0** | 0 | 4 | **281** (`lib` 220 · `test` 59 · `bin` 2) | 〃 |
| `unnecessary_const_in_enum_constructor` | **0** | 0 | 2 | 2 (`lib` 2) | 〃 |
| `initialize_in_field_declaration` | 0 | 0 | 2 | 0 | 하한을 올린 뒤의 0 은 진짜 0 — 프로젝트에 primary constructor 가 없다 |
| `use_declaring_parameters` | 0 | 0 | 1 | 0 | 〃 |
| `unnecessary_primary_constructor_body` | 0 | 0 | 1 | 0 | 〃 |

- 회차: `B0` 16줄 (표식 16 · 프로젝트 0, `exit 2`), `B1` 156줄 (표식 20 · 프로젝트 136), `B2` 2,067줄 (표식 38 · 프로젝트 2,029). 세 회차 모두 plugin 폴더 1, `riverpod_lint` 3.1.9, 약 20.5초 (빈 상태 폴더).
- **`B2` 의 기본 표식 16줄은 `B0` 과 한 줄도 다르지 않았다.** 하한을 올린 것이 이 패키지의 규칙과 plugin 진단을 바꾸지 않았다 (표식으로 본 범위). 결과 파일의 `markerLines` 로 본 것이고 판정은 `B0` 의 16줄만 본다 — wrap-up 에서 `B0` 의 16줄이 `B2` 에 모두 들어 있는 것을 다시 확인했다.
- **하한을 올리면 기준선이 바뀐다.** 대상(새 규칙 10개 + strict-inference) 밖의 프로젝트 줄이 `B0` · `B1` 에서 0, `B2` 에서 `prefer_initializing_formals` 27줄 (`lib` 24 · `test` 3) 이다. 이 규칙은 `lints` 6.1.0 의 recommended 에 들어 있어 지금도 켜져 있다. CHANGELOG 3.12.0 과 규칙 소스(`_privateNamedParametersEnabled`)에 따르면 private named parameters 기능이 켜지면(언어 버전 3.12 이상) "private named parameter 로 바꿀 수 있는 이름 붙은 매개변수" 도 본다. 잰 하한은 `^3.13.0` 하나이고 3.12 는 재지 않았다. 27줄의 자리를 하나씩 확인하지도 않았다.
- `B2` 의 표식 38줄 = 기본 표식 16 + 새 규칙과 strict-inference 21 + 3.13 문법 표식에 걸린 `prefer_initializing_formals` 1.

평가표에 옮기는 법.

| 규칙의 종류 | 적을 값 |
|---|---|
| 막는 조건이 없는 규칙 (`async_return_with_no_await` 등) | 지금 하한의 복사본에서 잰 줄 |
| 언어 버전 3.13 에서만 도는 6개 | "지금 하한: 0 (규칙이 돌지 않음)" 과 "하한을 `^3.13.0` 으로 올린 복사본: N줄" 둘. 채택하면 사용 프로젝트는 하한을 올리는 날 그 줄을 한꺼번에 받는다 |
| 하한을 올린 복사본의 값 | 하한을 올린 채 다시 잰 기준선과의 차이. 하한 3.11 의 기준선(0줄)을 그대로 쓰면 `prefer_initializing_formals` 27줄이 후보의 값에 섞인다 |

### 7. 실측 건수 — 사용 프로젝트의 무시 주석

무시 주석을 둔 채와 걷어낸 채로 같은 옵션을 분석해 견준다. 걷어낼 때는 주석 부분만 지우고 줄은 남겨 줄 번호를 지킨다.

```dart
// sources/023-existing-ignore-comments/probe.dart 에서
final ignorePattern = RegExp(r'//\s*(ignore_for_file|ignore)\s*:\s*(.*)$');

/// 분석되는 파일(생성 파일과 표식 제외)에서 무시 주석 부분만 지운다. 줄 번호는 그대로다.
int stripIgnores() {
  // … analyzedDartFiles() 와 표식 폴더의 ignore_probe/ 를 돌며
      lines[i] = lines[i].substring(0, m.start).trimRight();
  // …
}
```

- 회차마다 `refreshSources` → 표식 넣기 → (걷어내기) → 옵션 쓰기 → 분석 순서로 처음부터 만든다. 앞 회차의 걷어낸 소스가 남지 않는다.
- 생성 파일(`*.g.dart`, `*.freezed.dart`)은 걷어내지 않는다. 사용 프로젝트의 옵션 파일이 분석에서 빼므로 그 안의 주석은 어떤 실행에도 나오지 않는다 — 세기만 했다.

| id | 주석 | 더 켠 규칙 | 줄 (표식 · 프로젝트) |
|---|---|---|---|
| `I0` | 그대로 | 없음 (사용 프로젝트가 받는 것 — 019 의 `V0` (1.3.0) 과 같은 16 · 0) | 16 · 0 |
| `I1` | 걷어냄 | 없음 | 17 · 54 |
| `I2` | 그대로 | `lines_longer_than_80_chars`, `discarded_futures`, `cast_nullable_to_non_nullable`, `unnecessary_ignore` | 24 · 135 |
| `I3` | 걷어냄 | `I2` 와 같음 | 26 · 439 |
| `I4` | 그대로 | `unnecessary_ignore` | 19 · 38 |

다섯 회차 모두 받은 자리가 저장소였고, `example/` 정답지 16줄이 표식의 줄에 들어 있었고, plugin 이 준비됐다. 약 21 ~ 26초씩이다.

**주석의 출처** (복사본에서 센 것 — `countIgnores`. 손으로 쓴 파일 67줄 · 49개, 생성 파일 121줄 · 57개. 023 은 그 전에 원본을 Python 으로 읽어 건수만 먼저 봤다):

| 자리 | 종류 | 코드 | 건수 |
|---|---|---|---|
| 생성 파일 | `ignore` | `cast_nullable_to_non_nullable` | **56** |
| 생성 파일 | `ignore` | `implicit_dynamic_type` | 1 |
| 생성 파일 | `ignore_for_file` | `type=lint` 57, `type=warning` 50, 그 밖 11종 각 7 (`*.freezed.dart` 7개의 머리) | — |
| 손으로 쓴 파일 | `ignore_for_file` | `lines_longer_than_80_chars` | **30** |
| 손으로 쓴 파일 | `ignore` / `ignore_for_file` | `subtype_of_sealed_class` | 18 / 3 |
| 손으로 쓴 파일 | `ignore_for_file` | `type=lint` | **5** (파일 5개. 머리 5줄에 "GENERATED" 가 있는 것은 0) |
| 손으로 쓴 파일 | `ignore` | `unused_import` 4, `discarded_futures` **2**, `use_build_context_synchronously` 1, `argument_type_not_assignable` 1, `unnecessary_type_check` 1, `unused_element_parameter` 1 | — |
| 손으로 쓴 파일 | `ignore_for_file` | `avoid_print` | 1 |

**기준선 0줄 가운데 주석 덕분인 부분 (`I0` → `I1`):**

| 새로 나온 줄 | 어디서 | 건수 |
|---|---|---|
| lint — `unnecessary_string_escapes` 8, `unnecessary_string_interpolations` 7, `prefer_final_locals` **4**, `no_leading_underscores_for_local_identifiers` 4, `use_super_parameters` 3 | `ignore_for_file: type=lint` 를 단 손으로 쓴 파일 5개 | 26 |
| lint 가 아닌 analyzer 경고 — `subtype_of_sealed_class` 27, `unnecessary_type_check` 1 | 그 밖의 손으로 쓴 파일 (`test`) | 28 |

- **019 의 "기준선 0줄" 은 "주석이 있는 채로 0줄" 이다.** 이 패키지의 규칙(`prefer_final_locals`)과 기반 세트의 규칙이 `type=lint` 파일 다섯 개 안에서 26줄 가려져 있다.
- 그 다섯 파일은 **어떤 lint 후보에도 보이지 않는다.** `type=lint` 는 plugin 진단도 끈다 (012 → suppression-and-exclude.md 5번) — 그 파일들의 `riverpod_lint` 진단도 가려져 있을 것이다 (012 의 결과를 옮긴 추론이고 023 은 plugin 진단을 따로 세지 않았다).
- `avoid_print` (파일 단위 1) 와 `use_build_context_synchronously` (1) 의 주석은 지금 아무것도 가리지 않는다 — 걷어내도 그 규칙의 줄이 생기지 않았고, `I4` 에서 둘 다 `unnecessary_ignore` 로 잡혔다.

**후보 규칙의 값이 주석 때문에 적게 세어지는가 (`I2` → `I3`, 프로젝트의 줄):**

| 규칙 | 주석 그대로 (`I2`) | 걷어냄 (`I3`) | 주석이 가린 줄 | 가린 주석 |
|---|---|---|---|---|
| `lines_longer_than_80_chars` | 107 | 367 | **260** | 파일 단위 `lines_longer_than_80_chars` 131 + `type=lint` 파일 129 |
| `discarded_futures` | 11 | 13 | 2 | `ignore: discarded_futures` 2 |
| `cast_nullable_to_non_nullable` | 5 | 5 | 0 | (주석은 모두 생성 파일 안) |

- 표식의 대조: 가리지 않은 표식은 두 실행 모두 걸렸고, 가린 표식은 `I3` 에서만 보였다 (`lines_longer_than_80_chars` 표식 줄 5 → 6, `discarded_futures` 1 → 2). 표식 파일에 긴 줄이 더 있어 표식 줄의 수가 1 보다 크다.
- **로드맵의 "`cast_nullable_to_non_nullable` 56건" 은 생성기(freezed)가 단 주석이고 모두 생성 파일 안에 있다.** 이 규칙의 실제 줄은 5줄(`test`)이고 주석을 걷어내도 5줄이다.

**`unnecessary_ignore` 의 값은 다른 규칙의 채택에 따라 바뀐다:**

| 실행 | 프로젝트의 `unnecessary_ignore` | 필요 없다고 보고된 주석의 코드 |
|---|---|---|
| `I4` (작업 브랜치의 프리셋 + `unnecessary_ignore`) | **38** (`lib` 3 · `test` 34 · `bin` 1) | `lines_longer_than_80_chars` 30 (파일 단위), `discarded_futures` 2, `avoid_print` 1, `use_build_context_synchronously` 1, `subtype_of_sealed_class` 1, `unused_import` 1, `argument_type_not_assignable` 1, `unused_element_parameter` 1 |
| `I2` (후보 셋도 켬) | **12** (`lib` 1 · `test` 10 · `bin` 1) | `lines_longer_than_80_chars` 6 (긴 줄이 없는 파일의 파일 단위 주석), `avoid_print` 1, `use_build_context_synchronously` 1, 그 밖 4종 각 1 |

- **`unnecessary_ignore` 는 켜져 있지 않은 규칙을 가리키는 주석도 필요 없다고 보고한다.** 그래서 그 줄 수는 다른 후보를 함께 채택하느냐에 따라 38 과 12 사이에서 달라진다. 022 의 G1 (세 후보를 포함한 106개를 켬)에서 잰 12 도 `I2` 와 같은 수다.
- 진단의 `code` 는 줄 단위 · 파일 단위 주석 모두 `unnecessary_ignore` 하나였다.
- 어느 주석이 보고됐는지는 메시지를 남기지 않고, 진단이 가리킨 줄의 주석을 복사본에서 다시 읽어 **코드 이름만** 셌다 (`unnecessaryIgnoreNames` — 주석 뒤의 설명 글은 버린다).

### 8. `dart fix` 가능 건수 — 규칙 하나씩 apply 해 사라진 줄로 센다

| 방법 | 무엇을 세나 | 쓸 수 있나 |
|---|---|---|
| 그룹 dry | 일괄 적용을 되풀이한 결과의 규칙별 수 | 쓰지 않는다 — 한 규칙의 수정이 다른 규칙의 진단을 지우거나 만든다 |
| 단독 dry | 그 규칙만 고칠 때의 **수정 수** | 0 인지 아닌지만 — 수정 수는 사라지는 진단 수가 아니다 |
| apply 뒤 다시 분석 | 실제로 사라진 줄, 새로 생긴 다른 진단 | **이것을 적는다** |

`dart fix` 의 출력은 파일 경로 줄 아래에 `  <코드> - N fix(es)` 줄이 붙는 모양이고, 끝에 `N proposed fixes in M files.` (apply 는 `N fixes made in M files.`) 가 찍힌다. 고칠 것이 있어도 종료 코드는 0 이었다.

```dart
// sources/022-dart-fix-dry-run-count/probe.dart 의 dryRun 에서
final r = await Process.run(
    Platform.resolvedExecutable,
    ['--suppress-analytics', 'fix', apply ? '--apply' : '--dry-run', if (code != null) '--code=$code'],
    workingDirectory: where,
    environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path});
// …
for (final line in out.split('\n')) {
  final m = RegExp(r'^  (\S+) - (\d+) fix(?:es)?$').firstMatch(line);
  if (m != null && area != null) { /* 자리 → 코드 → 건수 */ continue; }
  if (RegExp(r'^\S+\.(dart|yaml)$').hasMatch(line.trim()) && !line.startsWith(' ')) {
    area = Diag(line.trim(), 0, '', '').area;
  }
}
```

- `dart fix` 의 화면 그대로는 사용 프로젝트의 파일 경로가 들어 있어 `<작업 폴더>/private/` 에만 쓴다.

**apply 한 회의 순서** (022 의 apply 고리):

```dart
// sources/022-dart-fix-dry-run-count/probe.dart 에서
consumer.refreshSources();                       // apply 로 고친 소스를 원본으로
consumer.addExampleMarkers();
await consumer.useSdk(g == 'G4' ? '^3.13.0' : null);
consumer.setOptions(consumer.optionsWith(rules: groups[g]!));   // 그 규칙이 든 그룹 그대로
final before = shots.firstWhere((s) => s.id == '$g-analyze');  // 같은 그룹을 켠 분석
final apply = await dryRun('apply-$rule', code: rule, apply: true);
final after = await consumer.analyze('apply-$rule-analyze');
consumer.ensureRepoSource(after);
final remaining = after.diags.where((d) => d.code == rule).length;
// 다른 코드의 증감 = after − before (그 규칙 자신은 뺀다)
```

**1부 — 연습용 표식** (언어 버전 3.13 패키지, 새 규칙 10개):

| 코드 | 진단 | 그룹 dry | 단독 dry | 그룹 apply 뒤 진단 |
|---|---|---|---|---|
| `use_primary_constructors` | 4 | 4 | 4 | 0 |
| `empty_container_bodies` | 2 | 2 | 2 | 0 |
| `unnecessary_type_name_in_constructor` | 4 | **3** | 4 | 0 |
| `use_declaring_parameters` | **0** | **3** | 0 | 0 |
| `unnecessary_const_in_enum_constructor` | 1 | 1 | 1 | 0 |
| `async_return_with_no_await`, `no_raw_types`, `no_dynamic_casts` | 1 · 1 · 1 | 0 · 0 · 0 | 0 · 0 · 0 | 1 · 1 · 1 |

- 그룹 dry 는 "13 proposed fixes" 이고 그룹 apply 도 "13 fixes made" 다. `use_primary_constructors` 의 수정이 클래스를 primary constructor 로 바꾸면 그 매개변수에 `use_declaring_parameters` 진단이 새로 생기고, dart fix 가 그것까지 이어서 고친다.

**2부 — 복사본** (후보 119개 = FEATURES.md 의 후보 표에 있고 Dart 3.13.4 에서 켜지며 기반 세트와 `base.yaml` 에 없는 118개 + `use_primary_constructors`):

- 그룹 dry 와 단독 dry 가 갈린 것: `omit_obvious_local_variable_types` 진단 236 · 단독 236 · 그룹 **12** (`omit_local_variable_types` 의 수정이 먼저 덮는다), `directives_ordering` 163 · 160 · **261**, `prefer_double_quotes` 20,353 · 20,353 · **40,707** (`prefer_single_quotes` 와 서로를 되고친다), `unnecessary_type_name_in_constructor` 281 · 281 · **40**. G2 의 그룹 dry 에는 후보도 아닌 `undefined_identifier` 59 · `no_leading_underscores_for_local_identifiers` 228 의 수정이 섞였다.
- **이 절의 "진단" 칸은 표식 줄을 포함한다** (스크립트의 `diag` = 프로젝트 + 표식). 예: `prefer_double_quotes` 20,353 = 프로젝트 20,345 + 표식 8, `always_specify_types` 9,382 = 9,374 + 8, `use_primary_constructors` 969 = 968 + 1, `lines_longer_than_80_chars` 111 = 107 + 4. 프로젝트의 줄만 보면 019 · 021 · 023 의 값과 같다.

`rules.json` 이 `hasFix` 로 적었는데 진단이 있고 단독 dry 가 0 인 규칙:

| 규칙 | 진단 | 단독 dry |
|---|---|---|
| `always_put_control_body_on_new_line` | 398 | 0 (`fix_internal.dart` 의 등록이 `UseCurlyBraces.nonBulk`) |
| `async_return_with_no_await` | 30 | 0 |
| `discarded_futures` | 11 | 0 |
| `prefer_foreach` | 3 | 0 |
| `unreachable_from_main` | 2 | 0 |

- 진단이 0 이 아닌 규칙은 58개다 (진단도 그룹 dry 도 0 인 규칙도 58개다 — 수가 같을 뿐 다른 집합이다. 진단이 0 인 규칙은 61개이고 그중 G4 의 셋은 그룹 dry 에만 나왔다) — `hasFix` 40 · `noFix` 11 · `needsFix` 6 · `rules.json` 에 없음 1 (`migrate_design_widgets`). 단독 dry 가 0 이 아닌 것은 36개이고 모두 `hasFix` 이거나 `migrate_design_widgets` (단독 dry 159 = 진단 159) 다. `needsFix` · `noFix` 인 규칙은 모두 단독 dry 0 이었다.
- `dart fix` 는 일괄 적용할 수 있는 수정만 쓴다 (`fix_internal.dart` 의 등록에 `bulkFixable` / `nonBulk` 가 붙는다 — IDE 의 빠른 수정은 하나씩 쓸 수 있다). 규칙마다 등록의 일괄 여부를 소스로 확인하지는 않았고 실행 결과가 그것을 대신한다.

**apply — 소스를 원본으로 되돌리고 규칙 하나씩 (아홉 규칙):**

| 규칙 | 진단 | 단독 dry | apply 뒤 남은 그 규칙 | 사라진 줄 | apply 뒤 다른 코드의 증감 |
|---|---|---|---|---|---|
| `always_put_required_named_parameters_first` | 32 | **16** | 0 | 32 | `lines_longer_than_80_chars` +3 |
| `avoid_redundant_argument_values` | 123 | **155** | 0 | 123 | `unnecessary_lambdas` +1 |
| `comment_references` | 196 | **10** | 96 | 100 | `migrate_design_widgets` +1, `unused_import` +1, `unnecessary_import` +2 |
| `diagnostic_describe_all_properties` | 123 | 46 | 0 | 123 | **error 148** (`undefined_method` 77, `undefined_class` 40, `creation_with_non_type` 31), `lines_longer_than_80_chars` +32 |
| `always_specify_types` (G2) | 9,382 | 8,913 | 469 | 8,913 | **error** `ambiguous_import` 5 · `argument_type_not_assignable` 1, `unnecessary_import` +36, `implementation_imports` +3, `specify_nonobvious_local_variable_types` −4,070 |
| `specify_nonobvious_local_variable_types` (G2) | 4,103 | 4,070 | 33 | 4,070 | **error** `ambiguous_import` 3 · `argument_type_not_assignable` 1, `unnecessary_import` +4, `implementation_imports` +1, `always_specify_types` −4,070 |
| `use_primary_constructors` (G4, 하한 3.13) | 969 | 969 | 0 | 969 | `use_declaring_parameters` +332, `initialize_in_field_declaration` +30, `prefer_const_constructors_in_immutables` +3, `unnecessary_type_name_in_constructor` −249, `unnecessary_const_in_enum_constructor` −2 |
| `prefer_double_quotes` (G3) | 20,353 | 20,353 | 0 | 20,353 | `prefer_single_quotes` **+20,352** |
| `unnecessary_final` (G3) | 6,709 | 6,709 | 0 | 6,709 | `prefer_final_locals` **+6,263** |

- **수정 하나가 진단 여럿을 지우거나(16 → 32, 10 → 100), 진단 하나에 수정이 여럿 붙는다(155 → 123).** 단독 dry 의 수를 "고칠 수 있는 진단 수" 로 적으면 틀린다.
- **apply 가 코드를 깨뜨리는 규칙이 셋이다.** `diagnostic_describe_all_properties` 는 import 되지 않은 이름을 써서 error 148줄을 만들었다. `always_specify_types` · `specify_nonobvious_local_variable_types` 는 타입 이름을 쓰려고 import 를 더하다 `ambiguous_import` error 를 남겼다. 이 셋은 "자동으로 고쳐진다" 가 아니라 "고친 뒤 손볼 곳이 생긴다" 다.
- `base.yaml` 의 규칙과 반대인 규칙(G3)은 고친 만큼 반대 진단이 생긴다.
- 아홉 규칙은 스크립트가 고른 것이다 — 단독 dry 가 진단과 다른 규칙 앞의 넷 + 단독 dry 가 큰 규칙. 이 아홉에서 단독 dry 가 0 이 아니면 apply 도 그 규칙의 줄을 줄였다. 단독 dry 가 0 인 규칙(위의 다섯 등)은 apply 하지 않았다 — "apply 할 것이 없다" 는 dry-run 의 결과를 옮긴 추론이다.

**dart fix 와 plugin.** 실행마다 빈 상태 폴더를 줬다. dart fix 는 그 폴더에 `.analysis-driver` 등을 쓰지만(복사본에서 항목 9,000 ~ 16,000개) `.plugin_manager` 는 만들지 않았다. 같은 옵션의 `dart analyze` 는 만들었다 (plugin 폴더 1). `riverpod_lint` 진단은 dart fix 의 출력에 없었다 (Dart 3.13.4).

**`sort_pub_dependencies`.** 로드맵의 "출처마다 `hasFix` 와 `needsFix` 로 어긋난다" 는 tag 와 사이트의 차이다.

| 출처 | fix |
|---|---|
| `rules.json` (tag 3.13.4) | `needsFix` |
| `fix_internal.dart` (tag 3.13.4) | 등록 없음 |
| dart.dev 의 `linter_rules.json` (site-www `main`, 2026-10-12 받음) | `hasFix` |
| Dart 3.13.4 의 `dart fix` | 단독 dry 0 (진단 2 — 자리는 `pubspec.yaml`) |

스크립트는 이 규칙을 apply 목록에 넣으려 했지만(`if (rows['sort_pub_dependencies']?['diag'] != 0) 'sort_pub_dependencies'`) 목록을 아홉 개로 자르는 `take(maxApply + 1)` 에 밀려 apply 하지 않았다. "고쳐지지 않는다" 의 근거는 단독 dry 0 과 등록 없음이다.

**시간** (복사본, Dart 파일 469개):

| 실행 | 시간 |
|---|---|
| `dart analyze` (빈 상태 폴더, plugin 준비 포함) | 약 20초 |
| 그룹 dry (G1 106개 · G2 4개 · G3 2개 · G4 7개) | 28.5 · 24.6 · 28.2 · 15.1초 |
| 단독 dry (61번 — 진단이 있는 58개 + 진단은 0 인데 그룹 dry 에만 나온 G4 의 셋) | 5.9 ~ 17.2초, 중앙값 6.9초 |
| apply 한 번 (`--code`) | 7.5 ~ 17.7초 |

- 후보마다 apply 하면 규칙 하나에 약 30초다 (복사 · `pub get` · apply · 분석 20초). 단독 dry 가 0 이 아닌 36개를 apply 하면 약 18분이다 (규칙 하나 30초로 셈한 추정 — 022 의 README 는 "20분 남짓" 으로 적었다).

### 9. 회차 기록 — 성공 기준 2 를 채우는 모양

ROADMAP.md Phase 4 성공 기준 2 는 "회차 기록에 SDK / 기반 세트 / plugin 버전이 적혀 있고, 일부러 넣은 위반이 보고되지 않은 회차의 수치는 쓰이지 않았다" 다. 021 ~ 023 이 판정(`checks`)에 넣은 것과 기록만 한 것을 가른다.

| 확인 | 021 | 022 | 023 |
|---|---|---|---|
| 받은 자리가 작업 중인 저장소 (`ensureRepoSource` — 아니면 던진다) | 세 회차 | 그룹 분석 넷 + apply 뒤 분석 아홉 | 다섯 회차 |
| `example/` 정답지 16줄이 표식의 줄에 있다 | `B0` 하나 (정확히 같다) | 그룹 분석 넷 (들어 있다) | 다섯 회차 (들어 있다) |
| plugin 이 준비됐다 (폴더 1, 실패 머리말 없음) | 세 회차 | 그룹 분석 넷 | 다섯 회차 |
| 후보 규칙을 어기는 표식이 걸린다 | 대조 셋만 — `avoid_print` (두 연습용 패키지), 3.13 패키지의 `empty_container_bodies`, `B1` 의 `async_return_with_no_await`. 규칙별 표식 수는 `perRule` 에 기록만 | 없음 (규칙마다의 표식이 없다. 1부의 확인은 단독 dry 와 진단 수가 같은지다) | 후보 셋마다 가리지 않은 표식, 가린 표식 둘(`discarded_futures`, `lines_longer_than_80_chars`), 아무것도 가리지 않는 주석 하나 |
| 저장소 지문 | 처음과 끝이 같다 | 처음과 끝 — 첫 실행에서 깨짐 → `repo_guard.dart` 의 여섯 단계 모두 같음 | 처음과 끝이 같다 |

- **"그 회차를 버린다" 는 스크립트 전체가 멈추는 것으로 구현되어 있다.** `ensureRepoSource` 는 `StateError` 를 던지고, 021 ~ 023 의 스크립트는 그것을 잡지 않아 결과 파일도 쓰지 않고 끝난다. 그 회차만 빼고 계속하려면 Phase 4 의 코드가 따로 적는다.
- **저장소 지문은 처음과 끝에서만 견줬다.** 요구 사항의 "저장소를 바꾸면 그 자리에서 멈춘다" 는 끝의 판정이 깨지는 것으로 구현됐다 — 022 는 실행 도중에 저장소가 바뀌었는데도 약 15분을 끝까지 돌고 결과 파일을 쓴 뒤 그 판정이 깨졌다. 단계마다 보려면 `repo_guard.dart` 의 `step` 을 쓴다.
- **022 의 정답지 · plugin 확인은 그룹 분석 넷만 본다.** apply 뒤의 분석 아홉은 받은 자리만 확인했고(README 의 "2부의 모든 분석에서" 는 그 넷을 말한다) 결과 파일에도 `Shot` 이 들어가지 않았다. 다만 apply 뒤 "다른 코드의 증감" 에 plugin 의 코드가 하나도 없으므로 표식의 plugin 3줄은 그대로였다 (간접 확인).
- 022 는 후보 규칙마다의 표식이 없다. 진단도 그룹 dry 도 0 인 58개 규칙의 0 은 뜻을 가르지 않았다.
- **기록만 한 것:** SDK 는 결과 파일의 `dart` 필드에 적었고 3.13.4 인지 견주지는 않았다. plugin 버전은 `Shot.pluginVersion` (`riverpod_lint` 만), 복사본의 언어 버전은 022 의 `languageVersion` 에 적었다. 기반 세트의 버전은 020 의 `upstreamSets` 만 적었고(`lints-6.1.0`, `flutter_lints-6.0.0` — 저장소 루트의 것) 021 ~ 023 의 결과 파일에는 없다.
- Phase 4 의 회차 기록은 셋을 함께 적는다. 복사본을 분석할 때 쓰이는 기반 세트는 **복사본의** `.dart_tool/package_config.json` 이 푼 `lints` · `flutter_lints` 이므로 거기서 읽는다 — 그것을 읽는 코드는 spike 에 없다.
- 복사 · 받은 자리 · 저장소 지문 · 표식 · 비공개 기록의 코드는 real-consumer-measurement.md 1번 (복사) · 2번 (받은 자리, 저장소 지문, `useSdk`) · 3번 (표식) · 6번 (비공개 기록)에 있다.

## What to Avoid

- **`rules.json` 의 `state` · `sets` · `fixStatus` 를 평가표에 그대로 옮기는 것.** 상류가 "믿지 말라" 고 적었고, deprecated 하나가 틀렸고, 켜지는 규칙 둘이 빠졌고, `sets` 는 전부 비었고, `hasFix` 는 "dart fix 가 고친다" 가 아니다.
- **사용 프로젝트의 복사본(하한 `^3.11.1`)에서 deprecated 를 가르는 것.** 3.13 에 deprecated 된 셋이 보이지 않는다. 저장소 하한의 패키지에서 가른다.
- **stable / experimental 을 분석으로 가르려는 것.** 둘 다 아무 진단이 없다.
- **"experimental 이면 채택하지 않는다" 를 기준으로 세우는 것.** `use_super_parameters` 가 기반 세트에 이미 켜져 있다.
- **비호환 쌍을 한 옵션 파일에 모두 켜고 `incompatible_lint` 의 수로 판단하는 것.** 한 줄에 하나만 붙어 둘이 가려졌다.
- **언어 버전 3.13 에서만 도는 규칙의 0 을 "깨끗하다" 로 적는 것.** 지금 하한에서는 규칙이 돌지 않는다. 그 규칙을 어기는 표식까지 0줄이었다.
- **하한을 올린 복사본의 줄을 하한 3.11 의 기준선과 견주는 것.** `prefer_initializing_formals` 27줄이 섞인다.
- **`pubspec.yaml` 의 하한만 고치고 `pub get` 을 하지 않는 것.** `languageVersion` 이 앞의 값으로 남는다.
- **무시 주석을 걷어낸 값을 평가표의 실측 건수로 쓰는 것.** 채택했을 때 사용 프로젝트가 받는 줄은 주석을 둔 채의 값이다. 걷어낸 값과의 차이는 따로 한 칸이다.
- **기준선 0줄을 "프로젝트가 이 패키지의 규칙을 모두 지킨다" 로 읽는 것.** `type=lint` 파일 다섯이 `prefer_final_locals` 4줄을 가리고 있다.
- **`unnecessary_ignore` 의 값을 다른 후보의 채택과 떼어 정하는 것.** 38 과 12 사이에서 움직인다.
- **로드맵의 "`cast_nullable_to_non_nullable` 56건" 을 그 규칙이 가려진 줄 수로 읽는 것.** 생성 파일 안의 생성기 주석이다.
- **단독 dry · 그룹 dry 의 수, `hasFix` 를 "dart fix 로 고칠 수 있는 건수" 로 적는 것.**
- **apply 뒤 새로 생긴 error 를 적지 않는 것.** 세 규칙이 코드를 깨뜨렸다.
- **apply 를 이어서 하는 것.** 규칙마다 소스를 원본으로 되돌린다 (`refreshSources`). 앞 규칙의 수정이 다음 규칙의 진단을 바꾼다.
- **dart fix 로 `riverpod_lint` 진단을 고칠 수 있다고 보는 것.** dart fix 는 plugin 을 준비하지 않는다.
- **비공개 프로젝트의 dart fix 화면이나 진단 줄을 `results/` 에 쓰는 것.** 파일 경로가 들어 있다. `<작업 폴더>/private/` 에만 쓴다.
- **저장소의 지문을 견주는 실측이 도는 동안 저장소 안에 파일을 만드는 것.** 022 의 첫 실행에서 "저장소가 그대로다" 가 깨졌다 (`.planning/spikes/CONVENTIONS.md`).

## Constraints

- Dart 3.13.4 · SDK tag 3.13.4 의 상류 파일 · `lints` 6.1.0 · `flutter_lints` 6.0.0 · `riverpod_lint` 3.1.9 에서 잰 값이다. SDK 를 올리면 `messages.yaml` 의 상태, 언어 버전으로 막히는 규칙, dart fix 의 등록이 모두 달라질 수 있다.
- 사용 프로젝트 하나, 하루의 값이다. 줄 수는 2026-10-12 의 `flutter_starter_kit` 복사본의 것이다. Dart 파일 469개는 021 이 센 값이다 (022 · 023 의 README 는 그 값을 옮겼다 — 023 의 스크립트에는 Dart 파일을 세는 코드가 없고 022 는 복사한 파일 수를 센다).
- 021 ~ 023 의 기준선(`B0` · `I0` — 16줄, 프로젝트 0)은 나눈 뒤의 작업 브랜치를 받은 값이다. 1.3.0 과 같다는 것은 019 의 `V0` (1.3.0) 이 같은 16줄 · 0줄이었다는 데 기댄다.
- 스크립트는 저마다 한 번씩 돌았다 (020 은 이름 변환의 버그 둘을 고친 뒤 한 번 더 — `results/probe-3.13.4-run1.*` 이 첫 실행이고, 두 이름을 빼면 분석 결과가 같았다). 022 의 `repo_guard.dart` 는 저장소 불변 확인을 다시 하려고 따로 돌린 대조다.
- 020 의 상류 파일은 `raw.githubusercontent.com/dart-lang/sdk/3.13.4/…` 에서 받았다 (네트워크가 필요하다). 사이트 데이터(`linter_rules.json`)는 스크립트 밖에서 받아 본 것이다.
- 021 의 2부 · 022 · 023 은 복사본의 `pubspec_overrides.yaml` 이 저장소 루트의 절대 경로를 가리켰다 (`Consumer.pointToRepo`). 그 실행들이 받은 것은 프리셋을 나눈 뒤의 작업 브랜치다.
- 022 의 후보 119개는 FEATURES.md 의 후보 표에서 셈했다 (2026-10-12). Phase 4 의 실제 후보 목록이 다르면 G1 ~ G4 의 나눔도 다시 한다.
- 021 의 소스 읽기(`Feature.primary_constructors` 의 막는 조건, `_privateNamedParametersEnabled`)와 022 의 `fix_internal.dart` 읽기는 tag 3.13.4 의 것이다.
- 재지 않은 것: 심각도 열의 출처, stable / experimental 이 갈린 넷의 "진짜" 상태, `sinceDartSdk` 의 정확성, 3.12 하한(private named parameters 만 켜지고 primary constructor 는 꺼진 자리), `prefer_initializing_formals` 27줄의 자리 하나하나, 하한을 올린 복사본에서 이 패키지의 지금 규칙 12개가 달라지는지(표식 16줄로 본 범위만 같다), 아홉 규칙 밖의 apply, 진단도 그룹 dry 도 0 인 58개 규칙의 0 의 뜻, dart fix 를 두 번 돌렸을 때 결과가 흔들리는지, IDE 의 빠른 수정, `type=lint` 를 단 손으로 쓴 파일 다섯이 무엇이고 왜 그렇게 했는지(경로를 남기지 않는 조건 — 소유자에게 물을 일), plugin 진단의 무시 주석과 `unnecessary_ignore` (이 프로젝트에는 없다), 생성 파일을 분석에 넣었을 때, 학습용 프로젝트 넷, 다음 SDK.

## Origin

Synthesized from spikes: 020, 021, 022, 023 (실측의 틀은 019 를 잇는다 — real-consumer-measurement.md)
Source files available in: sources/020-rule-state-vs-rules-json/ (`probe.dart`), sources/021-new-rules-language-gate/ (`probe.dart`, `consumer.dart`), sources/022-dart-fix-dry-run-count/ (`probe.dart`, `repo_guard.dart`), sources/023-existing-ignore-comments/ (`probe.dart`)
원본 로그와 JSON: `.planning/spikes/020-rule-state-vs-rules-json/results/` (`probe-3.13.4.*` 이 둘째 실행, `-run1` 이 첫 실행), `.planning/spikes/021-new-rules-language-gate/results/`, `.planning/spikes/022-dart-fix-dry-run-count/results/` (`repo_guard-3.13.4.json` 포함), `.planning/spikes/023-existing-ignore-comments/results/`. 사용 프로젝트의 경로와 메시지는 들어 있지 않다
