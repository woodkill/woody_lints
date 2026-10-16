# Pitfalls Research

**Domain:** Dart/Flutter 공유 lint 설정 패키지(configuration-only package) — 규칙 재선정, 프리셋 분리, 저장소 내 검증, git tag 릴리스, README 재작성
**Researched:** 2026-10-11
**Confidence:** MEDIUM

**이 문서의 범위:** `.planning/codebase/CONCERNS.md` 에 이미 적힌 사실(README drift 2건, 주석 처리된 설정 3개, `.fvmrc` 불일치, caret plugin 버전, CI/tag 부재 등)은 반복하지 않는다. 여기서는 "그 위에 이번 작업을 얹을 때 새로 생기는 실수"만 다룬다.

**증거 표기:**

| 표기 | 의미 | seam 등급 |
|------|------|-----------|
| `[SRC]` | Dart SDK `3.13.4` tag(= Flutter 3.47.5 번들), pub, dart_style 소스를 직접 읽음. **실행해서 확인한 것은 아니다** | seam 에 해당 provider 없음 — 본 문서에서는 "소스 확인, 실측 필요"로 취급 |
| `[DOC]` | dart.dev / riverpod.dev 공식 문서 (Context7 또는 원문 markdown) | MEDIUM (context7) |
| `[ISSUE]` | 웹 검색으로 찾고 GitHub API 로 원문을 다시 확인한 issue | MEDIUM (websearch + verified) |
| `[LOCAL]` | 이 머신의 pub cache, `~/.dartServer/.plugin_manager`, `flutter_starter_kit` 을 읽기 전용으로 관찰 | — |
| `[실측 필요]` | 이번 조사에서 실행하지 않았다. 해당 phase 에서 먼저 확인할 것 | — |

HIGH 로 표기한 주장은 없다. 도구 동작에 관한 주장은 전부 `[SRC]`/`[DOC]`/`[ISSUE]` 중 하나를 달았고, 실행 확인이 필요한 것은 문서 끝 "Needs Empirical Verification" 에 모았다.

## Critical Pitfalls

### Pitfall 1: 폐기·제거된 규칙은 공유 파일 안에서 "조용히" 죽고, 오타만 모든 사용 프로젝트에서 터진다

**What goes wrong:**
공유 파일에 넣은 규칙이 deprecated/removed 상태여도 사용 프로젝트에는 아무 경고가 뜨지 않는다. 규칙은 그냥 동작하지 않거나(removed) 곧 사라질 상태로 남는다. 반대로 규칙 이름 오타는 모든 사용 프로젝트의 `include:` 줄에 WARNING 으로 나타나 `dart analyze` 종료 코드를 2 로 만든다.

**Why it happens:**
- `deprecated_lint` / `removed_lint` 는 **분석 중인 옵션 파일 자신(initial file)에 직접 적힌 규칙**에만 보고된다. 소스 주석이 "defined directly (and not in includes)" 라고 명시한다 `[SRC: analysis_options_parse_model.dart, isInitialFile 분기]`.
- 그마저도 `since <= (그 패키지 pubspec 의 SDK 하한)` 일 때만 보고된다 `[SRC: _beforeCurrentConstraint]`. 이 저장소 `pubspec.yaml` 은 `sdk: ^3.10.4` 라서, 3.11 에 폐기된 `prefer_final_parameters` 나 3.13 에 폐기된 규칙은 직접 분석해도 경고가 나지 않는다.
- 제거된 규칙도 registry 에는 남아 있어 `undefined_lint` 가 되지 않는다. 진짜 모르는 이름만 `undefined_lint` 가 되고, include 된 파일의 진단은 전부 `included_file_warning`(WARNING)으로 바뀌어 **include 한 쪽**에 보고된다 `[SRC: analysis_options_include_walker.dart, _IncludedDiagnosticListener]`.
- 결과: `example/` 프로젝트가 프리셋을 include 해도 deprecated/removed 는 잡지 못한다. "example 이 통과했으니 규칙 목록은 유효하다"는 추론이 성립하지 않는다.

Dart 3.13.4 기준 폐기 상태인 규칙 `[SRC: pkg/linter/tool/machine/rules.json]`: `avoid_null_checks_in_equality_operators`, `avoid_private_typedef_functions`, `one_member_abstracts`, `prefer_final_parameters`, `use_if_null_to_convert_nulls_to_bools`. (3.13 CHANGELOG 가 `avoid_private_typedef_functions`, `one_member_abstracts` 폐기를, 3.11 CHANGELOG 가 나머지 셋의 폐기를 명시한다.) removed 상태는 14개, experimental 은 11개다.

**How to avoid:**
1. `pubspec.yaml` 의 `environment.sdk` 를 `^3.13.0` 으로 올린다. 지원 범위 결정과도 일치하고, 폐기 판정 기준선이 3.13 이 된다.
2. CI 에 "프리셋을 initial file 로 분석하는" 단계를 둔다. 프리셋 파일 내용을 임시 패키지(`sdk: ^3.13.0`)의 `analysis_options.yaml` 로 복사해 `dart analyze` 를 돌리면 `deprecated_lint` / `removed_lint` / `duplicate_rule` / `incompatible_lint` 가 직접 보고된다. include 로 규칙을 쪼갠 구조라면 규칙이 실제로 적힌 파일마다 이 단계를 돌린다.
3. 규칙을 고를 때 `state` 가 `stable` 인 것만 후보로 삼고, `experimental` 을 켠다면 사유와 재검토 시점을 주석으로 남긴다.

**Warning signs:**
- 규칙을 켰는데 실측 진단 수가 0 이고, 위반 샘플을 넣어도 0 이다.
- 사용 프로젝트 `analysis_options.yaml` 의 `include:` 줄에 "Warning in the included options file ..." 이 뜬다.
- SDK 를 올린 뒤 dart.dev 규칙 페이지에 "deprecated" 배지가 붙었는데 CI 는 여전히 초록이다.

**Phase to address:**
검증 하네스(verification harness) — 규칙 선정보다 먼저. 규칙 선정 phase 는 이 검사가 있다는 전제에서 시작한다.

---

### Pitfall 2: 포매터와 싸우거나, 대상 언어 버전에서 아예 동작하지 않는 규칙을 켠다

**What goes wrong:**
- `require_trailing_commas` 는 **언어 버전 3.7 이상에서 아무것도 보고하지 않는다.** 규칙 소스가 tall-style 포매터 도입 버전(3.7.0) 이상이면 즉시 return 한다 `[SRC: pkg/linter/lib/src/rules/require_trailing_commas.dart]`. Dart 3.13+ 만 지원하기로 했고 `flutter_starter_kit` 의 SDK 제약은 `^3.11.1` 이므로, 주석을 풀어도 실측은 0 건이 나온다. "0 건 = 코드가 깨끗하다"로 읽으면 틀린다.
- `formatter:` 섹션을 공유 파일에 넣으면 사용 프로젝트의 `dart format` 결과가 바뀐다. `dart format` 은 `analysis_options.yaml` 의 `include:` 를 따라가고 `package:` URI 도 `.dart_tool/package_config.json` 으로 해석한다 `[SRC: dart_style lib/src/config_cache.dart]`. analyzer 쪽에서도 `page_width` / `trailing_commas` 는 include 에서 개별 상속된다 `[SRC: analysis_options_parser.dart, _applyFormatter]`.
- `trailing_commas: preserve` 는 dart_style 이 "reversibility 를 깨뜨린다"는 이유로 기본값에서 제외한 옵션이다 `[DOC: dart_style CHANGELOG]`.
- `pub get` 을 하지 않은 상태(CI 의 format 전용 job 등)에서는 `package:` include 를 해석하지 못해 포매터가 경고만 내고 기본값으로 포맷한다 `[SRC: config_cache.dart, PackageResolutionException 분기]`. 로컬과 CI 의 포맷 결과가 달라진다.

**Why it happens:**
"trailing comma 를 강제하면 자동 정렬이 좋아진다"는 short-style(3.7 이전) 시절 지식이 그대로 남아 있다. 현재 README 가 꺼져 있는 두 항목을 켜진 것으로 적고 있는 것도 같은 뿌리다.

**How to avoid:**
- `require_trailing_commas` 주석 줄은 "유지/삭제 결정" 대상이 아니라 **삭제**다. 사유는 "언어 버전 3.7 이상에서 no-op"로 남긴다.
- `formatter:` 는 lint 규칙이 아니라 포맷 정책이다. 넣는다면 별도 결정으로 다루고, 넣는 순간 모든 사용 프로젝트에 대량 diff 가 생긴다는 점을 CHANGELOG 에 적는다. 넣지 않는다면 주석 줄을 지우고 README 의 "포맷터" 항목도 지운다.
- `lines_longer_than_80_chars` 를 후보에 올린다면 `formatter.page_width` 와 값이 어긋나지 않는지 같이 본다.
- 실측 결과가 0 건인 규칙은 "위반 샘플 1개를 넣어 실제로 보고되는지"를 확인한 뒤에만 근거로 쓴다.

**Warning signs:**
- 켠 규칙의 실측 값이 정확히 0 이다.
- 사용 프로젝트에서 `dart format` 후 lint 와 무관한 파일에 대량 diff 가 생긴다.
- `dart format` 출력에 "Package resolution error when reading ..." 경고가 보인다.

**Phase to address:**
규칙 선정(rule selection). 포맷 정책 결정은 같은 phase 안의 별도 항목으로 분리한다.

---

### Pitfall 3: 서로 충돌하는 규칙을 켠다 — analyzer 가 알려 주는 충돌과 알려 주지 않는 충돌

**What goes wrong:**
analyzer 가 `incompatible` 로 선언한 쌍은 `incompatible_lint`(WARNING)로 보고되지만, 의도가 정반대인데 선언되지 않은 쌍은 아무 경고 없이 양쪽 진단을 동시에 낸다.

**Why it happens:**
선언된 비호환 쌍 (Dart 3.13.4) `[SRC: rules.json incompatible 필드]`:

| 규칙 | 비호환 |
|------|--------|
| `prefer_final_locals` (현재 켜짐) | `unnecessary_final` |
| `prefer_single_quotes` (현재 켜짐) | `prefer_double_quotes` |
| `always_specify_types` | `avoid_types_on_closure_parameters`, `omit_local_variable_types`, `omit_obvious_local_variable_types`, `omit_obvious_property_types` |
| `always_use_package_imports` | `prefer_relative_imports` |
| `prefer_final_parameters` (폐기됨) | `unnecessary_final`, `avoid_final_parameters` |
| `prefer_final_in_for_each` | `unnecessary_final` |
| `omit_local_variable_types` | `specify_nonobvious_local_variable_types` |
| `omit_obvious_property_types` | `type_annotate_public_apis` |

- 같은 파일 안의 충돌은 `incompatible_lint`, include 를 가로지르는 충돌은 Dart 3.10 부터 `incompatible_lint_included` 로 보고된다 `[SRC: analysis_options_include_walker.dart]` `[DOC: SDK CHANGELOG 3.10]`. 사용 프로젝트가 프리셋과 비호환인 규칙을 켜면 그쪽에서 경고가 난다. 프리셋 규칙을 `false` 로 먼저 꺼야 해소된다.
- **선언되지 않은 충돌:** Dart 3.13 에 새로 들어온 `async_return_with_no_await`(async 함수에서 Future 를 반환할 때 `await` 를 쓰라)와 기존 `unnecessary_await_in_return`(return 의 `await` 는 불필요)은 권고가 정반대인데 rules.json 의 `incompatible` 에 없다 `[SRC: rules.json details]`. 둘 다 켜면 같은 줄에서 서로 반대 진단이 날 수 있다 `[실측 필요]`.
- 같은 파일 안에서 같은 규칙을 두 번 켜면 `duplicate_rule`(WARNING)이다. include 로 이미 켜진 규칙을 다시 켜는 것(현재의 6개 중복 선언)은 대상이 아니다 `[SRC: _processEnabledRule 의 activeRules 는 파일 단위]`.

**How to avoid:**
- 후보 규칙마다 rules.json 의 `incompatible` 을 조회해 표로 남긴다.
- 후보를 한꺼번에 켠 상태에서 Pitfall 1 의 "initial file 분석" 단계를 돌려 `incompatible_lint` 가 없는지 확인한다.
- "같은 구문에 대해 반대 방향을 권하는 규칙 쌍"은 analyzer 에 의존하지 말고 규칙 설명을 읽어 직접 걸러낸다. 최소한 `async_return_with_no_await` ↔ `unnecessary_await_in_return` 은 동시 채택 금지 후보로 적어 둔다.

**Warning signs:**
- 한 규칙의 quick fix 를 적용하면 다른 규칙 진단이 새로 생긴다.
- `dart fix --apply` 를 두 번 돌리면 결과가 진동한다.

**Phase to address:**
규칙 선정(rule selection). 검출 자체는 검증 하네스가 맡는다.

---

### Pitfall 4: `unawaited_futures` 와 `discarded_futures` 를 "중복"으로 오해하거나, 둘 다 켜서 UI 코드에 진단을 쏟아붓는다

**What goes wrong:**
두 규칙은 겹치지 않고 서로 다른 문맥을 맡는다. `unawaited_futures` 는 **async 함수 본문** 안의 await 누락을, `discarded_futures` 는 **async 가 아닌 함수** 안의 비동기 호출을 본다 `[SRC: rules.json details — discarded_futures 설명이 "as enforced by unawaited_futures" 로 역할을 나눈다]`. 하나만 켜면 다른 쪽 문맥은 비어 있고, 둘 다 켜면 Flutter 의 동기 콜백(`onPressed: () { ... }`, `initState`) 안의 `Navigator.push`, `context.push`, `ref.read(...notifier).doX()` 가 전부 걸린다.

**Why it happens:**
이름이 비슷해 한쪽이 다른 쪽을 포함한다고 가정한다. `flutter_starter_kit` 에는 이미 `// ignore: discarded_futures` 가 2건 있다 `[LOCAL]` — 과거에 이 규칙을 켜 봤거나 켠 상태를 가정한 흔적이므로, 실측 전에 경위를 확인할 가치가 있다.

**How to avoid:**
- 두 규칙을 별개 후보로 실측한다. 판단 기준은 건수가 아니라 "걸린 것 중 실제 버그 후보의 비율"이다.
- 채택한다면 README 에 의도적 fire-and-forget 표기법을 한 가지로 정해 적는다: `unawaited(...)` (dart:async), 또는 Dart 3.9 부터 지원되는 `@awaitNotRequired` 주석 `[DOC: SDK CHANGELOG 3.9]`. `unawaited()` 를 표준으로 삼는다면 `unnecessary_unawaited`(3.9)도 같이 검토한다.
- Riverpod 코드에서 이 규칙들이 내는 진단의 실제 분포는 이번 조사에서 확인하지 못했다 `[실측 필요]`.

**Warning signs:**
- 실측 진단의 대부분이 위젯 콜백과 `initState` 에 몰려 있다.
- 수정 방법이 전부 `unawaited(` 로 감싸기다 (규칙이 버그를 찾는 것이 아니라 의식(ritual)을 강제하고 있다는 신호).

**Phase to address:**
규칙 선정(rule selection).

---

### Pitfall 5: 심각도와 수정 가능 여부를 보지 않고 "엄격한" 옵션을 켠다

**What goes wrong:**
같은 "엄격함"이라도 종류에 따라 사용 프로젝트의 CI 를 즉시 깨뜨리는 것과 그렇지 않은 것이 있다.

**Why it happens:**
- `dart analyze` 는 기본적으로 error 와 warning 에서 실패하고 info 에서는 실패하지 않는다. 종료 코드는 0(없음) / 1(info, `--fatal-infos` 일 때만) / 2(warning) / 3(error) / 4(서버 오류)다 `[SRC: pkg/dartdev/lib/src/commands/analyze.dart, _Result enum]` `[DOC: dart.dev/tools/dart-analyze]`.
- linter 규칙은 INFO 다. 반면 `analyzer.language` 의 strict 모드가 내는 `strict_raw_type`, `inference_failure_on_*` 는 WARNING 이다 `[SRC: pkg/analyzer/messages.yaml]`. 공유 파일에서 strict 모드를 켜면 사용 프로젝트의 `dart analyze` 가 곧바로 exit 2 가 된다.
- Dart 3.13 은 `strict-raw-types` → `no_raw_types`, `strict-casts` → `no_dynamic_casts` lint 로 대체하는 길을 열었다 `[DOC: SDK CHANGELOG 3.13.0]`. 3.13.4 파서는 strict 옵션을 여전히 경고 없이 받는다 `[SRC]`. 새 설정에서 구 옵션을 고르면 곧 옮겨야 할 부채가 된다.
- `riverpod_lint` 의 규칙 15개는 전부 `registerWarningRule` 로 등록된다 `[LOCAL: riverpod_lint-3.1.9/lib/main.dart]`. plugin 의 warning 은 기본 활성이고 lint 만 opt-in 이다 `[DOC: analyzer-plugins]`. 즉 Riverpod 프리셋을 include 하는 순간 15개가 WARNING 으로 켜지고, 위반이 하나라도 있으면 exit 2 다.
- auto-fix 가 없는 규칙은 `dart fix` 로 정리할 수 없다. rules.json 의 `fixStatus` 가 `noFix` 인 후보: `public_member_api_docs`, `use_build_context_synchronously`, `avoid_dynamic_calls`, `avoid_positional_boolean_parameters`, `control_flow_in_finally`, `cancel_subscriptions`, `close_sinks`, `avoid_catches_without_on_clauses`, `lines_longer_than_80_chars`. `sort_pub_dependencies` 는 `needsFix` 다 `[SRC]`.
- `flutter_lints` 5.0.0 은 `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables` 를 **의도적으로 제거**했다 `[LOCAL: flutter_lints-6.0.0/CHANGELOG.md, dart-lang/lints#205 참조]`. 이 패키지는 그중 둘을 다시 켜고 있다. 상류가 뺀 규칙을 다시 켜는 것은 가능하지만, 사유 없이 켜 두면 이번 작업의 Core Value("왜 켜져 있는지 근거가 남아 있다")에 정면으로 어긋난다.

**How to avoid:**
후보 평가표의 열을 고정한다: `state` / 심각도(INFO·WARNING) / `fixStatus` / 실측 건수 / `dart fix --dry-run` 으로 고쳐지는 건수 / 상류 세트 포함 여부(및 제거 이력). 이 중 하나라도 비어 있으면 결정하지 않는다.

**Warning signs:**
- 후보 규칙의 실측 건수가 파일 수보다 많다 (`public_member_api_docs` 류).
- 규칙을 켠 뒤 exit code 가 0 → 2 로 바뀐다 (INFO 가 아니라는 뜻).
- `very_good_analysis` 가 "unresolved false positives" 사유로 제외한 규칙(`close_sinks`, `prefer_void_to_null`, `use_decorated_box`)을 후보에 올렸다 `[DOC: very_good_analysis README 의 excluded rules 표]`.

**Phase to address:**
규칙 선정(rule selection).

---

### Pitfall 6: 생성 코드와 `ignore` 주석이 실측과 규칙 효과를 가린다

**What goes wrong:**
- `analyzer.exclude` 는 `*.g.dart`, `*.freezed.dart` 만 뺀다. `flutter_starter_kit` 의 `lib/l10n/generated/` 9개 파일(gen-l10n 산출물)은 이 패턴에 걸리지 않고 분석 대상이다 `[LOCAL]`. `firebase_options.dart`, `*.gr.dart`, `*.mocks.dart`, `*.config.dart` 같은 다른 생성물도 마찬가지다(이 프로젝트에는 없었다).
- 생성 파일의 `// ignore_for_file: type=lint` 는 **lint 만** 가린다. `riverpod_lint` 규칙은 warning 이라 이 주석으로 가려지지 않는다. plugin 이 `analyzer.exclude` 와 `ignore_for_file` 을 어떻게 존중하는지는 확인하지 못했다 `[실측 필요]`.
- `unnecessary_ignore` 를 공유 프리셋에 넣으면, 프리셋 조합이 다른 프로젝트 사이에서 "한쪽에는 필요한 ignore 가 다른 쪽에서는 불필요"해진다. 이후 프리셋에서 규칙을 하나 **빼는** 것도 사용 프로젝트에 새 진단을 만든다. `flutter_starter_kit` 에는 이미 `ignore` 주석이 다수 있다(`cast_nullable_to_non_nullable` 56, `subtype_of_sealed_class` 18+3, `discarded_futures` 2 등) `[LOCAL]`.
- `invalid_annotation_target: ignore` 는 freezed README 가 `json_serializable` 병용 시 권장하는 설정이다 `[LOCAL: freezed-3.2.5/README.md]`. 근거는 있지만 codegen 을 쓰지 않는 프로젝트에는 필요 없다.

**Why it happens:**
"생성 코드는 제외했다"는 믿음이 파일 이름 패턴 두 개에만 근거한다.

**How to avoid:**
- 실측 결과를 파일 경로별로 집계해 생성 코드 비중을 먼저 본다. 규칙별 건수에서 생성 파일을 뺀 값과 포함한 값을 둘 다 기록한다.
- 제외 패턴과 `invalid_annotation_target: ignore` 는 codegen 프리셋으로 옮긴다 (Pitfall 9 의 "exclude 는 되돌릴 수 없다" 참조).
- `unnecessary_ignore` 는 채택하더라도 프리셋 간 조합을 고려해 기본 프리셋에만 두지 않는다. 채택 여부 자체를 semver 정책(Pitfall 18)과 같이 결정한다.

**Warning signs:**
- 한 규칙 진단의 절반 이상이 `generated/` 나 생성 파일에서 나온다.
- 규칙을 뺐는데 진단이 늘었다.

**Phase to address:**
규칙 선정(rule selection) — 집계 방식. 프리셋 분리(preset split) — exclude/ignore 의 위치.

---

### Pitfall 7: 복사본 실측이 "지금 배포된 1.3.0" 을 재고 있거나, 아무것도 재지 않고 있다

**What goes wrong:**
규칙별 진단 수가 그럴듯하게 나오지만 실제로는 후보 프리셋이 적용되지 않은 상태의 숫자다.

**Why it happens:**
1. **의존성이 옛 커밋을 가리킨다.** `flutter_starter_kit/pubspec.lock` 의 `woody_lints` 는 `resolved-ref: 90a2736...`(1.3.0)이다 `[LOCAL]`. 복사본에서 `pub get` 만 다시 하면 lockfile 의 커밋이 그대로 쓰인다 `[DOC: dart pub get — lockfile 이 있으면 잠긴 버전 사용]`. 작업 트리의 프리셋을 재려면 복사본에서 `woody_lints` 를 `path:` 로 덮어써야 한다.
2. **`pub get` 을 안 했다 / `.dart_tool` 이 낡았다.** `package:woody_lints/...` 가 해석되지 않으면 `include_file_not_found`(WARNING) 한 줄만 나오고 include 로 오던 규칙이 전부 꺼진다 `[SRC: _MissingInclude 분기는 apply 를 건너뛴다]`. 진단 수는 0 에 가깝게 나온다.
3. **인자를 붙인 `dart analyze` 는 plugin 진단을 잃는다.** Flutter 3.47.5 / Dart 3.13.4 에서 재현 보고된 표 `[ISSUE: flutter/flutter#193203]`:

   | 명령 | plugin 진단 | exit |
   |------|-------------|------|
   | `dart analyze` | 10 | 3 |
   | `dart analyze lib` | 0 | 0 |
   | `dart analyze lib/<file>.dart` | 7 | 3 |
   | `flutter analyze`, `flutter analyze lib` | 0 | 0 |

   디렉터리 인자 문제는 dart-lang/sdk#62710 으로 추적되었고 "Dart 3.14 에 실릴 것"이라는 답으로 2026-10-01 에 닫혔다 `[ISSUE]`. **3.13 에서는 반드시 패키지 루트에서 인자 없이 `dart analyze` 를 실행해야 한다.**
4. **분모가 틀리다.** "Dart 파일 169개"는 `lib/` 의 비생성 파일 수다(`lib/` 230 − 생성 61). `dart analyze` 는 `test/` 227개와 `bin/` 1개도 분석한다 `[LOCAL]`. 테스트 코드가 전체의 절반 이상이므로 규칙별 건수는 `lib/` 과 `test/` 로 나눠 봐야 한다.
5. **plugin 버전이 원본과 다르다.** plugin 작업 폴더는 context root **경로**의 MD5 로 만들어지고 `[SRC: plugin_watcher.dart, plugin_manager.dart _uniqueDirectoryName]`, 분석 서버가 뜰 때마다 `dart pub upgrade` 를 돌린다 `[SRC: filesFor → pubCommand 'upgrade']`. 복사본은 새 경로이므로 그 시점의 최신 버전으로 새로 해석된다. 이 머신의 `.plugin_manager` 에는 같은 `^3.1.3` 선언이 같은 날 3.1.4(analyzer 12.1.0)와 3.1.9(analyzer 14.4.0)로 해석된 폴더가 공존하고, 선언 변경 없이 10월 6일→7일 사이에 analyzer 14.4.0 → 14.5.0 으로 바뀐 기록이 있다 `[LOCAL]`.
6. **프로젝트 pubspec.lock 의 `riverpod_lint` 는 진단과 무관하다.** `flutter_starter_kit` 은 `dev_dependencies` 에 `riverpod_lint: ^3.1.3` 을 두고 lockfile 은 3.1.3 이지만, 실제 진단을 내는 것은 plugin 폴더의 3.1.9 다 `[LOCAL]`. lockfile 을 보고 "3.1.3 으로 쟀다"고 기록하면 틀린다.
7. **기반 세트가 움직인다.** `lints` 6.1.0 은 minor 릴리스에서 `recommended` 에 `use_null_aware_elements`, `no_wildcard_variable_uses` 를 추가했다 `[LOCAL: lints-6.1.0/CHANGELOG.md]`. 복사본에서 `pub upgrade` 를 하면 기준선(baseline)이 원본과 달라질 수 있다.
8. **언어 버전 게이트.** Dart 3.13 의 새 규칙 다수(`use_primary_constructors`(experimental), `use_declaring_parameters`, `unnecessary_primary_constructor_body` 등)는 primary constructor 기능과 묶여 있다 `[DOC: SDK CHANGELOG 3.13.0]`. `sdk: ^3.11.1` 프로젝트에서 0 건이 나와도 SDK 제약을 올리면 달라질 수 있다 `[실측 필요 — 규칙별 게이트 여부]`.
9. **사용 프로젝트 자신의 옵션이 섞인다.** `flutter_starter_kit/analysis_options.yaml` 은 자체 `analyzer.exclude`(`functions/**`, 플랫폼 디렉터리 등)를 갖고 있다 `[LOCAL]`. 학습용 프로젝트에는 없다. 한 프로젝트의 수치를 다른 프로젝트에 일반화할 수 없다.
10. **건수 ≠ 작업량.** `dart analyze` 는 TODO 를 걸러내고, 진단 수는 quick fix 유무를 말해 주지 않는다.

**How to avoid:**
실측 절차를 스크립트로 고정하고, 매 실행마다 다음을 결과 파일 머리에 기록한다.
- Flutter/Dart 버전, 복사본의 원본 커밋, `pubspec.lock` 의 `flutter_lints`·`lints` 버전
- plugin 폴더(`~/.dartServer/.plugin_manager/<md5>/pubspec.lock`)의 `riverpod_lint`·`analyzer`·`analysis_server_plugin` 버전
- 기준선(현재 1.3.0 프리셋) 진단 수 → 후보 규칙을 켠 뒤의 **차이**만 그 규칙의 값으로 쓴다
- 실행 명령은 `dart analyze --format=json` (인자 없음, 패키지 루트), `code` 별·`severity` 별·경로 접두사(`lib/`, `test/`, 생성물)별 집계
- 실행 전 sanity check: 일부러 넣은 위반 1건(core lint 1개 + riverpod_lint 1개)이 보고되는지. 보고되지 않으면 그 회차 결과는 폐기한다
- 보조 지표: `dart fix --dry-run` 의 규칙별 수정 가능 건수

**Warning signs:**
- 기준선 진단 수가 0 이거나, 규칙을 바꿔도 숫자가 변하지 않는다.
- 출력에 `include_file_not_found` 또는 `included_file_warning` 이 있다.
- riverpod_lint 코드가 결과에 하나도 없다 (`missing_provider_scope` 등).
- stderr 에 "An error occurred while setting up the analyzer plugin package" 가 있다.

**Phase to address:**
규칙 선정(rule selection)의 첫 작업. sanity check 와 집계 스크립트는 검증 하네스에서 만든 것을 재사용한다.

---

### Pitfall 8: `plugins:` 를 프리셋 파일로 옮기면 된다고 가정한다 — 동작은 하지만 문서화된 경로가 아니고, 다음 SDK 에서 규칙이 바뀐다

**What goes wrong:**
프리셋 분리 구조를 `plugins_in_inner_options` 경고의 원인을 오해한 채 설계하거나, "include 된 파일의 `plugins:`" 가 계속 지원된다고 가정한다.

**Why it happens:**
- 경고 조건은 `file.parent != contextRoot && isInitialFile` 이다 `[SRC: _ParsedPluginsData.parse]`. 즉 **include 로 들어온 파일은 대상이 아니다.** 이 저장소에서 경고가 나는 이유는 `lib/analysis_options.yaml` 이라는 **파일 이름** 때문에 analyzer 가 그것을 `lib/` 디렉터리의 옵션 파일(initial file)로 직접 분석하기 때문이다. 메시지 원문:

  DATA_k7Qp2mXa_START
  Plugins can only be specified in the root of a pub workspace or the root of a package that isn't in a workspace.
  DATA_k7Qp2mXa_END

- include 된 파일의 `plugins:` 는 plugin 이름을 키로 병합된다 `[SRC: analysis_options_parser.dart, _applyPlugins]`. 1.3.0 에서 실제로 동작한 것과 일치한다. 그러나 공식 문서는 "패키지 또는 workspace 루트의 `analysis_options.yaml`" 만 말하고, nested 옵션 파일에서는 지정할 수 없다고 적는다 `[DOC: analysis_server_plugin/doc/using_plugins.md]`. riverpod 공식 문서도 "`pubspec.yaml` 옆의 `analysis_options.yaml`" 만 안내한다 `[DOC: riverpod.dev getting_started]`. **공유 패키지의 include 로 plugin 을 켜는 것은 소스상 동작하지만 문서가 보장하는 경로는 아니다.**
- 이 영역은 지금 바뀌는 중이다. `plugins_in_inner_options` 는 pub.dev 의 analyzer 14.4.0 / 14.5.0 에서 이미 "제거된 진단 코드" 목록에 들어 있고 `[LOCAL: analyzer-14.4.0, 14.5.0 의 removedCodeNames — 정확히 어느 버전에서 옮겨졌는지는 확인하지 않았다]`, "어느 옵션 파일에서든 plugin 을 지정할 수 있게 한다"는 설계(dart-lang/sdk#63627)가 2026-08-19 에 완료 처리되었다 `[ISSUE]`. Dart 3.13.4 번들 analyzer(14.1.0-dev)에는 진단이 아직 있다 `[LOCAL: SDK 스냅샷 문자열]`. 다음 stable 에서 `lib/analysis_options.yaml` 이 이 저장소 안에서 어떻게 취급될지는 알 수 없다.
- 사용 프로젝트가 pub workspace 의 멤버 패키지라면, 그 패키지의 `analysis_options.yaml` 은 context root 가 아니다. 거기서 Riverpod 프리셋을 include 하면 3.13 에서는 plugin 이 로드되지 않을 수 있다 `[ISSUE: dart-lang/sdk#61481 — 서버는 context root 의 옵션 파일에서만 plugin 을 찾는다]` `[실측 필요]`.

**How to avoid:**
- 구조를 확정하기 전에 Flutter 3.47.5 에서 스파이크로 확인한다: (a) `lib/riverpod.yaml` 처럼 이름이 `analysis_options.yaml` 이 아닌 프리셋에 `plugins:` 를 두고, 사용 프로젝트가 include 했을 때 plugin 이 로드되는가 (b) 이 저장소 루트에서 경고가 사라지는가 (c) 프리셋이 다른 프리셋을 include 하는 2단 구조에서도 로드되는가.
- `plugins:` 를 담는 파일은 `analysis_options.yaml` 이라는 이름을 쓰지 않는다. 그러면 루트 `analysis_options.yaml` 의 `exclude` 우회(유일한 산출물을 자체 분석에서 빼는 것)를 없앨 수 있다.
- README 의 Riverpod 프리셋 절에 "pub workspace 멤버 패키지에서는 workspace 루트 옵션 파일에서 include 한다"를 적을지, 실측 결과에 따라 결정한다.
- CI 에 "다음 stable 에서도 통과하는가"를 알려 줄 수단(주기 실행 또는 수동 실행)을 하나 둔다. 이 영역은 SDK minor 마다 다시 확인해야 한다.

**Warning signs:**
- include 구조를 바꾼 뒤 riverpod_lint 진단이 0 이 되었는데 오류는 없다.
- 이 저장소에서 `plugins_in_inner_options` 를 없애려고 `exclude` 나 `errors: ignore` 를 추가하고 있다.

**Phase to address:**
프리셋 분리(preset split) — 맨 앞의 스파이크. PROJECT.md "확인이 필요한 기술 사항" 1번이 이것이다.

---

### Pitfall 9: `include:` 병합 규칙을 "나중 것이 덮어쓴다" 한 줄로 이해한다

**What goes wrong:**
프리셋에 넣은 설정 일부는 사용 프로젝트가 되돌릴 수 없고, 일부는 되돌릴 때 전체를 다시 써야 한다.

**Why it happens:**
섹션마다 병합 방식이 다르다 `[SRC: analysis_options_parser.dart, _ApplyState]`:

| 섹션 | 병합 방식 | 사용 프로젝트가 되돌리는 법 |
|------|-----------|------------------------------|
| `linter.rules` | 규칙 이름별 병합, 나중 것이 이김 | map 문법으로 `rule: false`. 한 `rules:` 안에서 list 와 map 을 섞을 수 없다 `[DOC]` |
| `analyzer.exclude` | **합집합(추가만 됨)** | **되돌릴 수 없다** |
| `analyzer.errors` | 진단 코드별, 나중 것이 이김 | 같은 코드에 다른 심각도 지정 |
| `analyzer.language` (strict-*) | 옵션별, 나중 것이 이김 | `false` 지정 |
| `formatter` | `page_width`, `trailing_commas` 각각 상속 | 같은 키 지정 |
| `plugins` | **plugin 이름별로 설정 전체를 교체** | 버전과 `diagnostics` 를 통째로 다시 적어야 한다 `[실측 필요]` |

- `exclude` 의 glob 은 include 된 파일 위치가 아니라 **분석 중인 옵션 파일의 디렉터리** 기준으로 해석된다 `[SRC: context_locator.dart, LocatedGlob(optionsFile.parent, ...)]`. `**/*.g.dart` 는 의도대로 동작하지만, 경로가 박힌 패턴은 사용 프로젝트 구조에 의존한다.
- `plugins:` 값이 map 이 아니면(예: list 로 적음) 그때까지 include 로 쌓인 plugin 설정이 **전부 지워진다** `[SRC: clearsExisting]`.
- `linter:` 섹션 형식이 잘못되면 그때까지의 규칙 설정이 지워진다 `[SRC: _ParsedLinterDataKind.invalid]`.
- 같은 파일은 include 그래프에서 **한 번만** 적용된다 `[SRC: handled set]`. 프리셋 A 와 B 가 둘 다 기본 프리셋을 include 하는 구조에서, 적용 순서는 처음 만난 위치로 정해진다.
- 사용 프로젝트의 `analysis_options.yaml` 에 적은 값이 항상 마지막에 적용된다 `[DOC: dart.dev/tools/analysis "Including shared options"]`.

**How to avoid:**
- 되돌릴 수 없는 것(`analyzer.exclude`)과 숨기는 것(`errors: ignore`)은 기본 프리셋에 넣지 않고 opt-in 프리셋에만 둔다. 이것이 codegen 프리셋을 따로 두는 실질적 이유다.
- 프리셋 사이의 include 관계는 최대 1단으로 유지하고, 적용 순서를 README 에 적는다.
- 검증 fixture 에 "사용 프로젝트가 규칙 하나를 끈다 / plugin 진단 하나를 끈다 / 프리셋 두 개를 list 로 include 한다" 세 경우를 넣는다.

**Warning signs:**
- "이 프로젝트에서는 `*.g.dart` 를 분석하고 싶다"는 요구가 프리셋을 고치지 않고는 불가능하다.
- 사용 프로젝트에서 riverpod_lint 규칙 하나를 끄려 했더니 plugin 이 통째로 사라졌다.

**Phase to address:**
프리셋 분리(preset split). 재정의 방법은 문서(docs) phase 에서 README 로 옮긴다.

---

### Pitfall 10: 기존 URI 의 의미를 바꿔서 사용 프로젝트의 진단이 소리 없이 사라진다

**What goes wrong:**
`package:woody_lints/analysis_options.yaml` 에서 Riverpod/codegen 설정을 떼어 내면, 이 URI 를 쓰는 5개 프로젝트에서 `riverpod_lint` 진단과 `*.g.dart` 제외가 사라진다. 오류도 경고도 없다. 반대 방향으로는, README 가 안내하는 새 프리셋 URI 를 옛 ref 에 고정된 프로젝트가 쓰면 `include_file_not_found`(WARNING)가 나고 그 include 로 오던 설정이 전부 빠진다.

**Why it happens:**
URI 는 공개 API 인데 "파일 내용 변경"은 API 변경처럼 보이지 않는다. 설정이 줄어드는 방향의 변화는 `dart analyze` 가 더 조용해지는 것이라 눈에 띄지 않는다.

**How to avoid:**
둘 중 하나를 프리셋 분리 phase 시작 시점에 명시적으로 고른다.
- **A. 기존 URI 를 "전체 묶음"으로 유지:** `analysis_options.yaml` 은 기본 + Riverpod + codegen 을 include 하는 aggregate 로 남기고, 새 URI(예: 기본만)를 추가한다. 기존 사용 프로젝트는 변화가 없다. 단, 이 구조에서는 "쓰지 않는 프로젝트가 받지 않는다"는 요구를 **새 URI 로 옮긴 프로젝트만** 충족한다.
- **B. 기존 URI 의 의미를 "기본만"으로 변경:** major 버전을 올리고, README 와 CHANGELOG 에 "이전과 같은 동작을 원하면 이렇게 include 하라"는 정확한 YAML 을 싣는다.

어느 쪽이든 검증 fixture 에 "옛 include 한 줄만 쓴 프로젝트"를 하나 두어, 그 프로젝트에서 riverpod_lint 진단이 나오는지(A) 또는 나오지 않는지(B)를 기대값으로 고정한다.

**Warning signs:**
- 릴리스 후 사용 프로젝트의 진단 수가 **줄었다**.
- README 의 설치 절에 URI 가 두 종류 이상 등장하는데 "기존 사용자는 무엇을 하라"는 문장이 없다.

**Phase to address:**
프리셋 분리(preset split) — 결정. 릴리스(release) — 버전 번호. 문서(docs) — 옮기는 방법.

---

### Pitfall 11: plugin 버전 범위가 지원하지 않는 SDK 에서 "실패"가 아니라 "멈춤"을 만든다

**What goes wrong:**
`riverpod_lint: ^3.1.3` 범위는 Dart 3.12 이하에서 3.1.7 / 3.1.8 로 해석될 수 있고, 이 조합은 `dart analyze` 를 무한 대기시킨다. CI 에서 2시간 넘게 멈춰 있었다는 보고가 있다 `[ISSUE: rrousselGit/riverpod#4839]`. 3.1.9 가 Dart 3.13 을 요구하게 된 이유가 이것이다:

DATA_Zr41vBne_START
Require Dart 3.13: ... On earlier SDKs the plugin previously hung `dart analyze`; now version solving fails with a clear error instead (#4839).
DATA_Zr41vBne_END

`[LOCAL: riverpod_lint-3.1.9/CHANGELOG.md]`

**Why it happens:**
plugin 은 프로젝트의 `pubspec.lock` 과 무관하게 분석 서버가 만든 합성 패키지에서 `dart pub upgrade` 로 해석된다 `[DOC: using_plugins.md]` `[SRC: plugin2/generator.dart, plugin_manager.dart]`. SDK 제약으로 최신 버전이 배제되면 범위 안의 다음 버전이 선택되고, 그 버전이 해당 SDK 에서 깨져 있어도 pub 은 알 수 없다.

부수 사실:
- 정확한 버전으로 고정해도 plugin 의 전이 의존성(`analysis_server_plugin`, `analyzer`)은 매 실행마다 떠다닌다. `analysis_server_plugin` 각 버전은 `analyzer` 를 정확 버전으로 요구한다 `[LOCAL: analysis_server_plugin-0.3.24/pubspec.yaml]`. 완전한 재현성은 없다. `plugins:` 아래 `dependency_overrides` 키가 파서에 존재한다 `[SRC]` — 최후 수단으로만 기록해 둔다.
- `riverpod_lint` 는 `riverpod` 를 정확 버전으로 고정한다(3.1.3 → `riverpod: 3.2.1`, 3.1.9 → `riverpod: 3.4.3`) `[LOCAL]`. plugin 샌드박스 안에서는 사용 프로젝트와 충돌하지 않는다. 그러나 사용 프로젝트가 `riverpod_lint` 를 `dev_dependencies` 에 **같이** 두면 그 프로젝트의 `riverpod` 버전이 거기에 묶인다. `flutter_starter_kit` 이 이 상태다(lockfile: `riverpod_lint` 3.1.3, `riverpod` 3.2.1) `[LOCAL]`. 새 plugin 방식에서는 `dev_dependencies` 선언이 필요 없다 `[DOC: riverpod.dev, riverpod_lint README]`.
- plugin 이 분석하는 것은 사용 프로젝트의 소스다. plugin 내부 `riverpod` 버전과 사용 프로젝트의 `riverpod` major 가 다를 때의 동작은 이번에도 확인하지 못했다 `[실측 필요]` (CONCERNS.md 의 기존 미확인 항목 그대로).

**How to avoid:**
- 하한을 `3.1.9` 이상으로 올린다. 그러면 Dart 3.12 이하에서는 멈추지 않고 version solving 이 실패한다. 정확 버전 고정(`3.1.9`)과 caret(`^3.1.9`) 중 무엇을 고를지는 "릴리스 없이 새 진단이 들어와도 되는가"로 결정한다(Pitfall 18).
- `pubspec.yaml` 의 `environment.sdk` 를 `^3.13.0` 으로 올려, 지원하지 않는 SDK 에서는 `pub get` 단계에서 먼저 실패하게 한다.
- CI job 에 `timeout-minutes` 를 반드시 둔다. 이 실패 양식은 종료 코드가 아니라 시간으로만 드러난다.
- README 의 Riverpod 프리셋 절에 "`dev_dependencies` 의 `riverpod_lint` 는 지운다"와 그 이유를 적는다.

**Warning signs:**
- `dart analyze` 가 "Analyzing..." 에서 CPU 0% 로 멈춘다.
- 같은 커밋인데 머신/날짜에 따라 riverpod_lint 진단이 다르다.
- 사용 프로젝트에서 `riverpod` 를 올리려는데 version solving 이 `riverpod_lint` 때문에 막힌다.

**Phase to address:**
프리셋 분리(preset split) — 버전 선언. 검증 하네스 — timeout. 문서(docs) — `dev_dependencies` 안내.

---

### Pitfall 12: plugin 이 로드되지 않았는데 검증이 통과한다

**What goes wrong:**
plugin 설정(다운로드·해석·컴파일)이 실패해도 `dart analyze` 가 0 을 반환할 수 있다.

**Why it happens:**
- plugin 준비 실패는 `PluginException` → `server.pluginError` 알림 → stderr 출력으로 처리된다 `[SRC: plugin_manager.dart addPluginToContextRoot, dartdev analysis_server.dart _handlePluginError]`.
- 종료 코드 4(서버 오류)는 **진단이 하나도 없을 때만** 반환된다. 진단이 하나라도 있으면 종료 코드는 그 진단들의 심각도로만 정해지고 서버 오류 여부는 보지 않는다 `[SRC: analyze.dart — serverErrorReceived 는 "issues 없음" 분기에서만 참조]`. 일부러 넣은 INFO 위반이 있는 example 프로젝트는 plugin 이 죽어도 exit 0 이다 `[실측 필요]`.
- 분석 서버가 뜰 때마다 `dart pub upgrade` 가 실행되므로 네트워크가 막힌 환경에서는 매번 실패한다. CI 러너는 매번 cold start 이고, AOT 스냅샷 재사용(Dart 3.11, "약 10초 절약")의 혜택도 받지 못한다 `[DOC: SDK CHANGELOG 3.11.0]`.
- `flutter analyze` 는 plugin 진단을 받기 전에 세션을 끝낸다 `[ISSUE: flutter/flutter#187999(open), dart-lang/sdk#63787(open)]`. 이 저장소가 2026-09-20 에 실측한 내용과 일치한다. `flutter analyze` 는 `--fatal-infos` 가 기본값(on)이라 `dart analyze` 와 종료 기준도 다르다 `[LOCAL: flutter analyze --help]`.
- `plugins:` 섹션을 바꾼 뒤에는 Dart Analysis Server 를 재시작해야 반영된다 `[DOC]`. IDE 에서 "고쳤는데 그대로"인 경우 대부분 이것이다.

**How to avoid:**
- 검증은 종료 코드가 아니라 **기대 진단의 존재**로 한다: riverpod_lint 코드가 최소 1건(예: `missing_provider_scope`) 실제로 출력되어야 통과.
- stderr 에 plugin 오류 문구가 있으면 종료 코드와 무관하게 실패 처리한다.
- CI 에서 `~/.dartServer` 를 캐시하지 않는다. 캐시하면 plugin 해석 실패가 가려지거나 옛 스냅샷이 재사용된다.
- 기본 프리셋만 include 한 fixture 에서는 반대로 "plugin 진단이 0건이고 plugin 폴더가 생기지 않는다"를 확인한다 `[실측 필요 — 폴더 생성 여부를 판정 기준으로 쓸 수 있는지]`.

**Warning signs:**
- `dart analyze` 출력에 "No issues found!" 도 "N issues found." 도 없다.
- CI 로그에 "An error occurred while setting up the analyzer plugin package" 가 있는데 job 은 초록이다.
- CI 분석 시간이 갑자기 짧아졌다 (plugin 이 안 떴다).

**Phase to address:**
검증 하네스(verification harness).

---

### Pitfall 13: `example/` 프로젝트가 통과하지만 아무것도 증명하지 못한다

**What goes wrong:**
빈 `flutter create` 프로젝트에 include 한 줄을 넣고 `dart analyze` 가 0 을 반환하는 것을 "검증"으로 삼는다.

**Why it happens:**
- lint 규칙은 INFO 이고 `dart analyze` 는 기본적으로 INFO 에서 실패하지 않는다. 규칙이 **하나도 적용되지 않아도**, 전부 위반해도 exit 0 이다.
- 깨끗한 코드는 "규칙이 켜져 있다"와 "규칙이 꺼져 있다"를 구별하지 못한다.
- deprecated/removed 규칙은 include 경유로는 보고되지 않는다 (Pitfall 1).
- `path: ..` 의존성은 작업 트리를 검증한다. git 의존성으로 받는 내용(커밋된 파일만)과 다를 수 있다 — 새 프리셋 파일을 `git add` 하지 않은 경우 로컬은 통과하고 사용 프로젝트는 `include_file_not_found` 가 난다. CI 는 checkout 된 커밋으로 돌기 때문에 이 경우를 잡지만, "tag 가 가리키는 커밋"은 별개다(Pitfall 16).

**How to avoid:**
example 을 "통과해야 하는 프로젝트"가 아니라 **기대 진단 fixture** 로 만든다.
- 프리셋마다 위반 샘플을 두고, `dart analyze --format=json`(또는 `machine`) 출력을 `code|file|line` 으로 정규화해 저장소에 커밋한 기대 파일과 비교한다. 추가된 진단도, 사라진 진단도 실패다.
- 기대 파일에는 최소한: 이 패키지가 추가한 규칙 각각 1건, 기반 세트(`flutter_lints`)에서 온 규칙 1건, riverpod_lint 1건, 그리고 "보고되면 안 되는" 케이스(`*.g.dart` 안의 위반, `invalid_annotation_target`)를 넣는다.
- 옵션 파일 자체의 진단(`included_file_warning`, `include_file_not_found`, `incompatible_lint`)은 0 건이어야 한다는 조건을 별도로 둔다.
- Pitfall 1 의 initial-file 분석을 같은 workflow 에 둔다.

**Warning signs:**
- 규칙을 하나 지운 PR 이 CI 를 통과한다.
- example 의 Dart 파일이 `main.dart` 하나다.
- CI 스크립트가 `dart analyze` 의 종료 코드만 본다.

**Phase to address:**
검증 하네스(verification harness) — 이번 milestone 의 첫 phase 로 둘 것을 권한다. 규칙 선정·프리셋 분리 모두 이 fixture 를 갱신하는 방식으로 진행하면 "문서에 적힌 그대로 적용된다"가 매 커밋마다 확인된다.

---

### Pitfall 14: 루트 옵션 파일과 example 의 분석 컨텍스트가 서로 새거나 가린다

**What goes wrong:**
- 저장소 루트에서 `dart analyze` 를 돌리면 `example/` 도 함께 분석된다. fixture 의 의도적 위반 때문에 루트 분석이 실패한다.
- 이를 피하려고 `dart analyze example` 처럼 인자를 주면 plugin 진단이 사라진다 (Pitfall 7-3).
- `example/` 에 `analysis_options.yaml` 이 없으면 analyzer 는 상위 디렉터리의 것(루트의 "자체 분석용" 파일)을 쓴다. 프리셋이 전혀 적용되지 않은 채 통과한다.
- example 을 pub workspace 멤버로 만들면 context root 가 workspace 루트로 올라가고, plugin 은 workspace 루트의 옵션 파일에서만 인식된다 `[DOC: using_plugins.md]` `[ISSUE: dart-lang/sdk#61481]`.
- 루트 `.gitignore` 의 `pubspec.lock` 패턴은 경로 접두사가 없어 `example/pubspec.lock` 에도 적용된다 `[LOCAL]`. 의도하지 않으면 example 의 기반 세트 버전은 CI 실행마다 달라진다.

**Why it happens:**
"설정 패키지 + 그 안의 소비자 프로젝트"는 analyzer 입장에서 중첩된 두 패키지이고, 옵션 파일 탐색·context root·plugin 범위가 각각 다른 규칙을 따른다.

**How to avoid:**
- CI 는 `working-directory: example` 에서 **인자 없이** `dart analyze` 를 실행한다. 저장소 루트 분석은 별도 step 으로 두고 루트 옵션에서 `example/**` 를 제외한다.
- example 은 자체 `pubspec.yaml`(workspace 아님)과 자체 `analysis_options.yaml`(내용은 include 한 줄)을 갖는다.
- `example/pubspec.lock` 을 커밋할지 결정하고 `.gitignore` 를 그에 맞춘다. 커밋하면 재현성을, 커밋하지 않으면 기반 세트 변화의 조기 경보를 얻는다. 둘 다 원하면 PR 용 job(잠금)과 주기 실행 job(`pub upgrade`)으로 나눈다.
- 프리셋 조합이 여러 개면 fixture 프로젝트도 조합별로 둔다(예: 기본만 / 기본+Riverpod+codegen / 옛 URI 한 줄). 한 프로젝트 안에서 조합을 바꿔 가며 돌리지 않는다 — plugin 폴더가 context root 경로로 키잉되어 상태가 섞인다.

**Warning signs:**
- 루트에서 돌린 결과와 `example/` 에서 돌린 결과의 진단 수가 다르다.
- example 에서 include 줄을 지워도 결과가 같다.

**Phase to address:**
검증 하네스(verification harness).

---

### Pitfall 15: CI 의 툴체인과 action 버전이 저장소 고정값과 따로 논다

**What goes wrong:**
workflow 에 Flutter 버전을 직접 적거나 `channel: stable` 만 적으면 `.fvmrc` 와 어긋난다. 반대로 `.fvmrc` 를 고치지 않고 workflow 만 3.47.5 로 맞추면 로컬 재현이 안 된다(현재 `.fvmrc` 는 3.41.2 / Dart 3.11.0 으로, 지원 범위 밖이다).

**Why it happens:**
버전을 적는 곳이 `.fvmrc`, `.vscode/settings.json`, workflow, `pubspec.yaml` 의 SDK 제약, 문서 다섯 군데다.

**How to avoid:**
- `.fvmrc` 를 단일 원천으로 삼는다. `subosito/flutter-action` 은 `flutter-version-file` 에 `.fvmrc` 를 받는다 `[DOC: flutter-action README, v2.23.0]`.
- `.fvmrc` 를 3.47.x 로 올리는 것을 검증 하네스 phase 의 첫 작업으로 둔다. 그 전에는 로컬에서 어떤 검증도 문서와 같은 조건으로 돌 수 없다.
- action 버전은 구현 시점에 릴리스 페이지에서 확인한다. 2026-10-11 조회 값: `actions/checkout` v7.0.1, `actions/cache` v6.1.0, `subosito/flutter-action` v2.23.0 `[GitHub releases API]`. 오래된 예제의 major 를 그대로 복사하지 않는다.
- `on.push` 에 `branches` 만 적으면 tag push 에서는 workflow 가 돌지 않는다 `[DOC: GitHub Actions workflow syntax]`. 릴리스 tag 검증이 필요하면 `tags` 를 명시한다.
- `push` 와 `pull_request` 를 둘 다 걸면 같은 저장소의 PR 에서 두 번 돈다. 개인 저장소에서는 `push`(main, tags) + `pull_request` 조합으로 충분하고, 중복은 `concurrency` 로 줄인다.
- pub cache 캐시는 써도 되지만 `~/.dartServer` 는 캐시하지 않는다 (Pitfall 12).

**Warning signs:**
- workflow YAML 에 Flutter 버전 숫자가 직접 적혀 있다.
- CI 로그의 `Dart SDK version` 이 `.fvmrc` 와 다르다.
- Actions 탭에 "Node.js ... is deprecated" 주석이 달린다.

**Phase to address:**
검증 하네스(verification harness).

---

### Pitfall 16: tag 를 옮기거나, push 하지 않거나, 엉뚱한 커밋에 붙인다

**What goes wrong:**
- **tag 이동:** 사용 프로젝트의 `pubspec.lock` 은 `ref` 와 함께 `resolved-ref`(커밋 SHA)를 저장한다 `[SRC: pub lib/src/source/git.dart]` `[LOCAL: flutter_starter_kit/pubspec.lock]`. tag 를 다른 커밋으로 옮기면 lockfile 이 있는 머신은 옛 커밋에, lockfile 이 없거나 `pub upgrade` 를 한 머신은 새 커밋에 머문다. 같은 `ref: v2.0.0` 인데 내용이 다르다. 옛 커밋이 어떤 ref 에서도 도달할 수 없게 되면 새 머신에서 옛 lockfile 로 `pub get` 이 실패할 수 있다 `[실측 필요]`.
- **push 누락:** `git push` 는 tag 를 보내지 않는다. `--follow-tags` 는 push 되는 커밋에서 도달 가능한 **annotated tag 만** 보낸다 `[DOC: git-scm.com/docs/git-push]`. README 가 `ref: v2.0.0` 을 안내하는데 원격에 tag 가 없으면 사용 프로젝트의 `pub get` 이 실패한다.
- **엉뚱한 커밋:** 버전을 올리는 커밋 **전에** tag 를 붙이면 `v2.0.0` 이 `version: 1.3.0` 인 pubspec 을 가리킨다. `ref:` 방식에서는 pub 이 이를 검사하지 않고, 사용 프로젝트 lockfile 에는 `version: "1.3.0"` 이 찍힌다.
- **GSD 의 자동 tag:** 이 프로젝트의 `.planning/config.json` 은 `git.create_tag: true` 이고, GSD 는 milestone 완료 시 `v[X.Y]` 형식의 annotated tag 를 만든다 `[LOCAL: gsd-core workflows/complete-milestone]`. 패키지 릴리스 tag(`vX.Y.Z`)와 같은 이름 공간을 쓴다. `ref: v1.0` 같은 milestone tag 를 릴리스로 오인할 수 있다.

**Why it happens:**
git 의존성에서 tag 는 가변 포인터이고, pub 은 `ref:` 방식에서 tag·pubspec 버전의 일치를 요구하지 않는다.

**How to avoid:**
- 원칙: **push 한 tag 는 옮기지 않는다.** 잘못 나간 릴리스는 patch 버전으로 고친다.
- 릴리스 절차를 README(또는 별도 문서)에 번호 붙인 단계로 고정한다: 버전·CHANGELOG 커밋 → CI 통과 확인 → annotated tag → `git push origin main vX.Y.Z` → `git ls-remote --tags origin` 로 확인 → 빈 프로젝트에서 `ref: vX.Y.Z` 로 `pub get` + `dart analyze` smoke test.
- tag push 에서 도는 CI 검사를 둔다: `GITHUB_REF_NAME == "v" + pubspec.version == CHANGELOG 최상단 제목`. 셋 중 하나라도 다르면 실패.
- GSD 의 `git.create_tag` 를 끄거나, milestone 버전을 패키지 버전과 같게 맞출지 릴리스 phase 계획에서 결정한다. (설정 변경은 사용자 결정 사항이다.)
- 대안으로 Dart 3.9+ 의 `tag_pattern: v{{version}}` + `version: ^X.Y.Z` 가 있다 `[DOC: dart.dev/tools/pub/dependencies#git-packages]`. 이 방식은 tag 와 pubspec 버전이 다르면 pub 이 "Expected ... version" 오류로 거부한다 `[SRC: git.dart]`. 대신 범위 안의 새 tag 가 `pub upgrade` 로 자동 유입된다. PROJECT.md 의 결정("프로젝트마다 올리는 시점을 고른다")에는 `ref: vX.Y.Z` 가 더 맞고, `tag_pattern` 은 README 에 선택지로만 언급할지 결정한다.

**Warning signs:**
- `git tag -l` 과 `git ls-remote --tags origin` 의 결과가 다르다.
- 사용 프로젝트 lockfile 의 `woody_lints` `version` 이 `ref` 의 숫자와 다르다.
- `git tag -l` 에 `v1.0` 과 `v1.3.0` 이 같이 보인다.

**Phase to address:**
릴리스(release).

---

### Pitfall 17: 개발 중인 `main` 이 그대로 사용 프로젝트에 배포된다

**What goes wrong:**
사용 프로젝트 5개가 전부 `ref: main` 이고, 이 저장소의 GSD 설정은 `branching_strategy: none` 이다 `[LOCAL]`. 이번 milestone 의 모든 중간 커밋(규칙 절반만 바꾼 상태, 프리셋을 쪼개는 중인 상태)이 `main` 에 쌓이고, 사용 프로젝트가 `flutter pub upgrade` 를 하거나 lockfile 없이 `pub get` 을 하는 순간 그 중간 상태를 받는다. README 를 `ref: vX.Y.Z` 로 고쳐도 기존 프로젝트의 `pubspec.yaml` 은 바뀌지 않는다.

**Why it happens:**
"릴리스 방식 전환"을 마지막 phase 로 미루면, 전환 전까지의 모든 작업이 옛 방식(= main 이 곧 릴리스)으로 배포된다. 사용 프로젝트 적용은 범위 밖이므로 누구도 이 구간을 지키지 않는다.

**How to avoid:**
- milestone 의 **첫 작업**으로 1.3.0 내용의 커밋에 `v1.3.0` tag 를 붙여 push 한다. `flutter_starter_kit` lockfile 이 가리키는 커밋은 `90a2736` 이고, 그 뒤 `main` 에는 `.planning/` 문서 커밋만 있다 `[LOCAL]`. 이것만으로 사용 프로젝트는 원할 때 `ref: v1.3.0` 으로 물러설 수 있다. 내용 변경이 없으므로 위험이 없다.
- 그다음 둘 중 하나를 고른다: (a) 사용 프로젝트를 `ref: v1.3.0` 으로 먼저 고정한다(범위 밖이지만 한 줄 수정이고, 하지 않으면 아래 위험을 받아들이는 것) (b) 이번 작업을 `main` 이 아닌 브랜치에서 진행하고 릴리스 시점에만 `main` 에 합친다.
- 새 버전의 CHANGELOG 맨 위에 "`ref: main` 을 쓰는 프로젝트는 다음 `pub upgrade` 에서 이 변경을 전부 받는다"를 적는다.

**Warning signs:**
- milestone 진행 중에 `flutter_starter_kit` 에서 설명되지 않는 새 진단이 생긴다.
- 사용 프로젝트 lockfile 의 `resolved-ref` 가 이 저장소의 중간 커밋이다.

**Phase to address:**
릴리스(release) — 단, `v1.3.0` tag 는 milestone 맨 앞으로 당긴다. phase 순서를 정할 때 이 한 가지를 선행 작업으로 분리할 것.

---

### Pitfall 18: "tag 로 고정하면 규칙이 고정된다"고 믿고, 버전 번호의 의미를 정하지 않는다

**What goes wrong:**
사용 프로젝트가 `ref: v2.0.0` 에 고정해도 실제 적용되는 진단은 계속 바뀐다. 그리고 "이 릴리스가 새 진단을 만드는가"를 버전 번호로 알 수 없다.

**Why it happens:**
유효 규칙 집합은 네 가지의 곱이다.

| 층 | 무엇이 고정하나 | 언제 바뀌나 |
|----|-----------------|-------------|
| 이 패키지의 YAML | git tag (`resolved-ref`) | `ref` 를 바꿀 때 |
| 기반 세트 (`flutter_lints ^6.0.0` → `lints ^6.0.0`) | 사용 프로젝트의 `pubspec.lock` | 사용 프로젝트의 `pub upgrade`. `lints` 6.1.0 은 minor 에서 `recommended` 에 규칙 2개를 추가했다 `[LOCAL]` |
| 규칙 구현 | Dart SDK 버전 | Flutter 업그레이드. 규칙 폐기·동작 변경이 따라온다 |
| plugin 과 그 의존성 | **아무것도 고정하지 않는다** | 분석 서버가 뜰 때마다 (`pub upgrade`) |

lint 패키지에는 깨질 API 가 없어서 semver 가 자명하지 않다. 정하지 않으면 1.3.0 처럼 "그때까지 로드되지 않던 riverpod_lint 를 처음 켜는" 변경이 minor 로 나간다.

**How to avoid:**
버전 정책을 한 번 정해 README 에 적는다. 권장안:
- **major:** 기존 URI 삭제 또는 의미 변경, 지원 SDK 하한 상승, `flutter_lints` major 상승, 기본 심각도를 WARNING 이상으로 올리는 변경.
- **minor:** 진단이 **늘어날 수 있는** 모든 변경 — 규칙 추가, plugin 추가, plugin 하한 상승, 프리셋 추가.
- **patch:** 진단이 늘지 않는 변경 — 주석·문서, 규칙 제거(단, `unnecessary_ignore` 를 채택했다면 규칙 제거도 진단을 늘리므로 minor).

CHANGELOG 형식도 고정한다. 릴리스마다 "새로 생길 수 있는 진단" 절을 두고 규칙 이름, 심각도, `flutter_starter_kit` 실측 건수, `dart fix` 가능 여부를 적는다. 이번 실측 데이터가 그대로 첫 항목이 된다.

참고한 선례: `very_good_analysis` 는 `analysis_options.<버전>.yaml` 처럼 버전이 박힌 파일을 같이 배포해 URI 로도 고정할 수 있게 한다 `[DOC: very_good_analysis README]`. 다른 생태계의 linter 들은 규칙 추가를 minor 로, "기존 규칙이 더 많이 보고하게 되는 변경"을 major 로 두는 경우와 그렇지 않은 경우가 갈린다 `[웹 검색, 원문 미확인 — LOW]`. 정답은 없고, 적어 두는 것이 요점이다.

**Warning signs:**
- CHANGELOG 항목이 "규칙 정리" 한 줄이다.
- 버전을 올리지 않은 커밋이 `lib/` 아래 YAML 을 바꾼다.
- "tag 를 안 바꿨는데 진단이 늘었다"는 상황을 설명할 문서가 없다.

**Phase to address:**
릴리스(release) — 정책 결정. 문서(docs) — README·CHANGELOG 반영. 규칙 선정(rule selection) — CHANGELOG 에 들어갈 실측 데이터의 형식을 미리 맞춘다.

---

### Pitfall 19: README 를 손으로 다시 쓰고, 다음 변경에서 다시 어긋난다

**What goes wrong:**
README 규칙 목록이 YAML 과 어긋나는 일은 이미 일어났다(CONCERNS.md). 다시 쓰는 것만으로는 재발을 막지 못한다. 이번에는 프리셋이 여러 개가 되어 어긋날 표면이 늘어난다.

**Why it happens:**
규칙 이름이 YAML, README, CHANGELOG, YAML 주석 네 곳에 중복되고, 일치를 확인하는 수단이 없다.

**How to avoid:**
- README 의 규칙 표를 **검사 가능한 구역**으로 만든다. `very_good_analysis` 처럼 시작/끝 마커 주석 사이에 표를 두고 `[DOC]`, CI 에서 "각 프리셋 YAML 의 활성 규칙 집합 == README 마커 구역의 규칙 집합"을 비교한다. 생성 스크립트까지 가지 않아도 비교 스크립트 하나면 충분하다.
- "왜 켰는가"는 YAML 의 규칙 옆 주석을 단일 원천으로 삼고, README 는 그 주석을 옮긴 것으로 취급한다.
- README 에 반드시 들어가야 하는데 빠지기 쉬운 것:
  1. 전역으로 적용되는 숨김 설정 — `analyzer.exclude` 패턴, `errors: ignore` 항목, 어느 프리셋에 있는지, **exclude 는 사용 프로젝트에서 되돌릴 수 없다**는 사실
  2. 재정의 방법 — 규칙 끄기는 map 문법, list 와 혼용 불가, 프리셋과 비호환인 규칙을 켜려면 프리셋 쪽을 먼저 끌 것, plugin 진단 재정의는 plugin 설정 전체를 다시 적을 것
  3. 확인 명령 — "패키지 루트에서 인자 없이 `dart analyze`". `flutter analyze` 와 `dart analyze <dir>` 가 plugin 진단을 빠뜨린다는 사실은 **SDK 버전과 조회 날짜를 함께** 적는다 (3.14 에서 일부가 고쳐질 예정이므로 문장의 유효기간이 짧다)
  4. plugin 변경 후 Dart Analysis Server 재시작
  5. `dev_dependencies` 의 `riverpod_lint` 제거
  6. 버전 올리는 절차와 "tag 를 고정해도 바뀌는 것" (Pitfall 18 의 표)
  7. 옛 include 한 줄을 쓰던 프로젝트가 할 일 (Pitfall 10)
- 문서에 적는 도구 동작은 fixture 로 뒷받침되는 것만 단정형으로 쓴다.

**Warning signs:**
- README 를 고치는 커밋과 YAML 을 고치는 커밋이 따로다.
- README 에 "실측" 날짜가 없는 도구 동작 서술이 있다.
- README 의 규칙 수와 `grep -c` 결과가 다르다.

**Phase to address:**
문서(docs). 비교 스크립트는 검증 하네스 phase 에서 틀을 만들고 문서 phase 에서 켠다.

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| 루트 `analysis_options.yaml` 의 `exclude` 로 `plugins_in_inner_options` 를 계속 가린다 | 저장소가 조용해진다 | 유일한 산출물이 자체 분석에서 빠진 채로 남는다 | `plugins:` 를 다른 이름의 파일로 옮기기 전까지만 |
| example 검증을 `dart analyze` 종료 코드로만 판정 | workflow 가 5줄로 끝난다 | 규칙이 전부 꺼져도, plugin 이 죽어도 통과한다 | 받아들일 수 없다 |
| 규칙 중복 선언 6개를 "혹시 몰라" 유지 | 기반 세트가 규칙을 빼도 영향이 없다 | 이 패키지의 실제 기여분이 흐려지고 README 가 길어진다 | 규칙별로 "기반 세트와 무관하게 고정" 사유를 적을 수 있을 때만 |
| `riverpod_lint` 를 caret 범위로 둔다 | 릴리스 없이 수정이 들어온다 | 릴리스 없이 진단도 들어온다. 재현 불가 | 하한이 3.1.9 이상이고, CHANGELOG 정책에 "plugin 은 떠다닌다"를 적었을 때 |
| 실측을 한 번 손으로 돌리고 숫자만 문서에 적는다 | 빠르다 | 규칙 후보가 바뀔 때마다 재현할 수 없고 조건(버전)이 남지 않는다 | 받아들일 수 없다 — 스크립트와 조건 기록이 근거의 일부다 |
| `v1.3.0` tag 없이 바로 2.0 작업을 시작한다 | 한 단계 생략 | 사용 프로젝트가 물러설 지점이 commit hash 뿐이다 | 받아들일 수 없다 |
| experimental 규칙을 켠다 | 새 기능을 일찍 쓴다 | SDK minor 마다 동작·이름이 바뀔 수 있다 | 사유와 재검토 SDK 버전을 주석에 적었을 때 |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `dart analyze` | `dart analyze lib` 또는 `dart analyze example` 처럼 디렉터리 인자를 준다 | Dart 3.13 에서는 패키지 루트에서 인자 없이 실행 (sdk#62710, 3.14 에서 수정 예정) |
| `flutter analyze` | 사용 프로젝트 CI 가 이 명령만 쓴다 | plugin 진단이 빠진다(flutter#187999 open). README 에 `dart analyze` 를 병기 |
| `dart analyze` 종료 코드 | 0 이면 문제없다고 본다 | INFO 는 기본 비치명. 검증은 기대 진단 비교로, 필요하면 `--fatal-infos` |
| analyzer plugin 캐시 | `~/.dartServer` 를 CI 캐시에 넣는다 / 로컬에서 "캐시가 낡았다"고 지운다 | CI 는 캐시하지 않는다. 로컬은 지울 필요가 거의 없다 — 서버 시작마다 `pub upgrade` 가 돈다. 반영이 안 되면 서버 재시작이 먼저 |
| `dart format` | lint 패키지가 포맷에 영향이 없다고 가정 | `formatter:` 섹션은 `package:` include 를 따라 사용 프로젝트에 적용된다 |
| pub git 의존성 | tag 를 옮겨 "조용히 고친다" | lockfile 의 `resolved-ref` 때문에 머신마다 갈린다. patch 버전으로 고친다 |
| GitHub Actions | `on.push.branches: [main]` 만 적고 tag 검증을 기대 | `tags` 를 명시해야 tag push 에서 돈다 |
| `subosito/flutter-action` | workflow 에 버전을 직접 적는다 | `flutter-version-file: .fvmrc` |
| GSD milestone tag | `git.create_tag: true` 를 그대로 둔다 | 릴리스 tag 와 이름 공간이 겹친다. 끄거나 버전을 일치시킨다 |
| `flutter_lints` 전이 의존성 | tag 고정으로 기반 세트도 고정된다고 가정 | 기반 세트는 사용 프로젝트 lockfile 이 고정한다. README 에 명시 |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| plugin cold start | CI 의 `dart analyze` 가 로컬 두 번째 실행보다 수십 초 느리다 (pub upgrade + AOT 컴파일) | 받아들인다. `timeout-minutes` 로 상한만 둔다 | 매 CI 실행 |
| plugin hang | "Analyzing..." 에서 CPU 0% 로 무한 대기 | plugin 하한 3.1.9, SDK 하한 3.13, job timeout | 지원 범위 밖 SDK 조합 |
| `.plugin_manager` 폴더 누적 | 이 머신에 30개가 넘는 폴더가 쌓여 있다(조사 중에도 늘었다). context root 경로마다 하나씩 생긴다 `[LOCAL]` | 실측용 복사본은 같은 경로를 재사용한다 | 복사본을 매번 새 경로에 만들 때 |
| Riverpod 미사용 프로젝트의 plugin 로드 | 분석 시작이 느려지고 plugin isolate 메모리를 쓴다 | 프리셋 분리로 해결. 분석 시간 영향은 측정되지 않았다 `[실측 필요]` | 기본 프리셋에 `plugins:` 가 남아 있을 때 |
| fixture 가 프리셋 조합 수만큼 늘어난다 | CI 시간이 조합 수에 비례 | 조합을 3개 이내로 유지 (기본 / 전체 / 옛 URI) | 프리셋을 4개 이상으로 쪼갤 때 |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| "정확 버전으로 고정했으니 plugin 공급망이 통제된다"고 문서화 | plugin 의 전이 의존성은 매 실행 `pub upgrade` 로 떠다닌다. 고정은 직접 의존성 한 줄에만 적용된다 | README 에 한계를 그대로 적는다. 필요 시 `plugins: dependency_overrides` 가 있다는 것만 기록 |
| tag 를 불변이라고 가정하고 안내 | git tag 는 옮길 수 있다. 저장소 쓰기 권한이 곧 모든 사용 프로젝트의 analyzer 설정(= 실행되는 plugin 선택) 변경 권한이다 | tag 이동 금지 원칙. 더 강한 고정이 필요한 프로젝트를 위해 README 에 commit SHA 로 `ref` 를 적는 방법을 한 줄 싣는다 |
| workflow 의 third-party action 을 가변 tag(`@v2`)로 참조 | action 저장소가 바뀌면 CI 에서 실행되는 코드가 바뀐다 | 개인 저장소 수준에서는 major tag 로 충분하다는 판단도 가능. 결정을 workflow 주석에 남긴다 |
| workflow 에 불필요한 권한 | 이 CI 는 읽기만 필요하다 | `permissions: contents: read` |
| 프리셋이 진단을 숨긴다는 사실을 문서화하지 않음 | `invalid_annotation_target: ignore` 와 `exclude` 가 실제 실수를 가린다 (CONCERNS.md 기존 항목) | opt-in 프리셋으로 이동 + README 명시 (Pitfall 9, 19) |

## UX Pitfalls

이 패키지의 사용자는 "몇 달 뒤의 작성자 본인"이다.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| 새 버전으로 올리자 진단이 수백 건 생기는데 어디서 왔는지 알 수 없다 | 올리기를 포기하거나 규칙을 통째로 끈다 | CHANGELOG 의 "새로 생길 수 있는 진단" 절: 규칙별 실측 건수, `dart fix --apply --code=<rule>` 가능 여부, 권장 적용 순서 |
| 옵션 파일 문제가 `include:` 줄에 "Warning in the included options file /…/pub-cache/…(123..145)" 로 뜬다 | 자기 프로젝트 문제로 오인한다 | README 문제 해결 절에 이 메시지 형태와 뜻("프리셋 쪽 문제, 패키지 버전을 확인")을 적는다 |
| 프리셋이 여러 개인데 무엇을 include 해야 하는지 README 가 표로만 설명 | 매번 YAML 을 열어 본다 | 프로젝트 유형별 복사용 블록 3개 (Flutter+Riverpod+codegen / Flutter만 / 옛 설정 유지) |
| IDE 에서 고쳤는데 진단이 그대로 | 설정이 틀렸다고 생각해 되돌린다 | "plugin 설정을 바꾼 뒤에는 Analysis Server 재시작"을 설치 절 바로 아래에 둔다 |
| `ref: vX.Y.Z` 의 숫자를 README 에 하드코딩 | 다음 릴리스에서 README 가 옛 버전을 안내한다 | 릴리스 절차에 "README 의 버전 문자열 갱신" 단계를 넣고 tag 검사 스크립트가 README 도 확인 |
| 규칙을 끄는 방법이 없다 | 프리셋 전체를 포기한다 | Pitfall 19 의 재정의 절 |

## "Looks Done But Isn't" Checklist

- [ ] **규칙 재선정:** 실측 0 건인 규칙 — 위반 샘플을 넣었을 때 실제로 보고되는지 확인했는가 (`require_trailing_commas` 는 언어 3.7+ 에서 no-op)
- [ ] **규칙 재선정:** 실측 결과 파일에 Flutter/Dart 버전, 기반 세트 버전, plugin 폴더의 `riverpod_lint`·`analyzer` 버전, 기준선 대비 차이가 적혀 있는가
- [ ] **규칙 재선정:** 실측이 작업 트리의 프리셋을 썼는가 — 복사본 lockfile 의 `woody_lints` 가 `path` 소스인가 (`resolved-ref: 90a2736…` 이면 1.3.0 을 잰 것)
- [ ] **규칙 재선정:** 모든 채택 규칙이 `state: stable` 이거나 예외 사유가 적혀 있는가. `incompatible` 쌍이 없는가
- [ ] **프리셋 분리:** 옛 include 한 줄만 쓴 fixture 의 기대 진단이 결정(A/B)과 일치하는가
- [ ] **프리셋 분리:** 기본 프리셋만 include 한 fixture 에서 riverpod_lint 진단이 0 건이고 `*.g.dart` 가 분석되는가
- [ ] **프리셋 분리:** `plugins:` 를 담은 파일 이름이 `analysis_options.yaml` 이 아닌가. 루트 `exclude` 우회가 제거되었는가
- [ ] **프리셋 분리:** `riverpod_lint` 하한이 3.1.9 이상인가. `pubspec.yaml` 의 SDK 하한이 `^3.13.0` 인가
- [ ] **검증:** 규칙 하나를 지운 커밋이 CI 에서 **실패**하는가 (직접 해 볼 것)
- [ ] **검증:** include 줄을 지운 example 이 CI 에서 실패하는가
- [ ] **검증:** deprecated 규칙을 일부러 넣었을 때 CI 가 실패하는가 (initial-file 분석 단계)
- [ ] **검증:** plugin 로드 실패(예: 존재하지 않는 plugin 버전)를 일부러 만들었을 때 CI 가 실패하는가
- [ ] **검증:** job 에 `timeout-minutes` 가 있는가. `dart analyze` 에 디렉터리 인자가 없는가
- [ ] **검증:** CI 로그의 Flutter 버전이 `.fvmrc` 와 같은가
- [ ] **릴리스:** `git ls-remote --tags origin` 에 새 tag 가 있는가. tag 가 가리키는 커밋의 `pubspec.yaml` version 과 CHANGELOG 최상단이 tag 와 같은가
- [ ] **릴리스:** 빈 Flutter 프로젝트에서 `ref: vX.Y.Z` 로 `pub get` + `dart analyze` 가 기대대로 도는가 (path 가 아니라 git 으로)
- [ ] **릴리스:** `v1.3.0` tag 가 변경 이전 커밋에 붙어 있는가
- [ ] **문서:** README 의 규칙 집합과 YAML 의 규칙 집합을 기계적으로 비교했는가
- [ ] **문서:** `exclude` 와 `errors: ignore` 가 어느 프리셋에 있는지, 되돌릴 수 있는지 적혀 있는가
- [ ] **문서:** 도구 동작 서술마다 SDK 버전과 확인 날짜가 있는가

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| 릴리스에 오타·무효 규칙이 들어가 사용 프로젝트에 `included_file_warning` | LOW | patch 버전으로 수정 릴리스. 사용 프로젝트는 `ref` 를 올린다. tag 는 옮기지 않는다 |
| tag 를 이미 옮겼다 | MEDIUM | 원래 커밋에 되돌릴 수 있으면 되돌리고, 새 내용은 새 patch tag 로 낸다. 각 사용 프로젝트에서 `flutter pub upgrade woody_lints` 후 lockfile 의 `resolved-ref` 확인 |
| 사용 프로젝트가 `ref: main` 으로 중간 상태를 받았다 | LOW | 그 프로젝트의 `ref` 를 `v1.3.0` 으로 바꾸고 `pub get` |
| 기존 URI 의 의미를 바꿔 riverpod_lint 가 사라졌다 | LOW (발견하면) / HIGH (발견 못 하면) | 사용 프로젝트 include 를 전체 묶음 URI 로 교체. 발견 수단: 릴리스 전후 진단 수 비교 |
| 실측이 옛 프리셋을 잰 것으로 밝혀졌다 | MEDIUM | 스크립트의 sanity check 를 추가하고 전부 다시 잰다. 이미 내린 규칙 결정은 "재확인 필요"로 표시 |
| CI 가 plugin hang 으로 멈췄다 | LOW | job 취소, timeout 추가, plugin 하한·SDK 확인 |
| SDK 를 올린 뒤 규칙이 폐기되어 CI 가 붉다 | LOW | 규칙 제거 + minor/patch 릴리스. 이것은 하네스가 의도대로 동작한 것이다 |
| README 가 다시 어긋났다 | LOW | 비교 스크립트를 CI 필수 단계로 승격 |
| `formatter:` 를 넣은 릴리스 후 사용 프로젝트에 대량 포맷 diff | MEDIUM | 사용 프로젝트에서 `formatter:` 를 재정의하거나, 프리셋에서 제거한 patch 릴리스. 이미 커밋된 포맷 변경은 프로젝트별로 되돌려야 한다 |

## Pitfall-to-Phase Mapping

phase 이름은 요청에 쓰인 다섯 종류를 그대로 쓴다. 번호는 roadmap 에서 정한다.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| 1. 폐기·제거 규칙이 조용히 죽음 | 검증 하네스 | deprecated 규칙을 일부러 넣은 커밋이 CI 에서 실패 |
| 2. 포매터와 싸우는/no-op 규칙 | 규칙 선정 | 채택 규칙마다 "위반 샘플이 보고됨" 기록. `formatter:` 결정이 문서화됨 |
| 3. 충돌 규칙 | 규칙 선정 (+하네스) | initial-file 분석에서 `incompatible_lint` 0 건. 반대 방향 규칙 쌍 수동 검토 기록 |
| 4. Future 규칙 겹침 | 규칙 선정 | 두 규칙의 실측이 문맥별(async/sync)로 분리 기록됨 |
| 5. 심각도·수정 가능 여부 | 규칙 선정 | 평가표의 모든 열이 채워짐 |
| 6. 생성 코드·ignore | 규칙 선정 / 프리셋 분리 | 실측이 경로별로 집계됨. exclude/ignore 가 opt-in 프리셋에만 있음 |
| 7. 실측 왜곡 | 규칙 선정 (첫 작업) | 결과 파일에 조건 기록 + sanity check 통과 |
| 8. `plugins:` 위치 | 프리셋 분리 (스파이크) | 3.47.5 에서 스파이크 결과 기록. 루트 `exclude` 우회 제거 |
| 9. include 병합 | 프리셋 분리 | 재정의 3종 fixture 통과 |
| 10. 기존 URI 호환 | 프리셋 분리 / 릴리스 / 문서 | 옛-URI fixture 기대값이 결정과 일치. README 에 이전 방법 |
| 11. plugin 버전·hang | 프리셋 분리 / 하네스 | 하한 3.1.9+, SDK `^3.13.0`, timeout 존재 |
| 12. plugin 미로드 통과 | 검증 하네스 | 깨진 plugin 버전으로 CI 실패 확인 |
| 13. 증명 없는 example | 검증 하네스 | 규칙 삭제 커밋이 CI 에서 실패 |
| 14. 컨텍스트 간섭 | 검증 하네스 | example 의 include 줄 삭제가 CI 에서 실패 |
| 15. 툴체인·action drift | 검증 하네스 | CI 로그 버전 == `.fvmrc` |
| 16. tag 실수 | 릴리스 | tag 검사 job + git 기반 smoke test |
| 17. `main` 이 곧 배포 | 릴리스 (단, `v1.3.0` tag 는 맨 앞으로) | `git ls-remote --tags origin` 에 `v1.3.0` |
| 18. semver 의미 | 릴리스 / 문서 | README 에 정책, CHANGELOG 에 "새 진단" 절 |
| 19. README drift | 문서 (+하네스) | README↔YAML 비교가 CI 에서 돈다 |

**phase 순서에 대한 함의:**
1. `v1.3.0` tag 붙이기는 어떤 phase 보다 먼저 한다 (5분 작업, Pitfall 17).
2. 검증 하네스가 규칙 선정·프리셋 분리보다 앞선다. 두 작업 모두 "fixture 기대값을 바꾸는 일"로 진행되어야 한다. `.fvmrc` 갱신이 하네스의 첫 작업이다.
3. 프리셋 분리의 `plugins:` 스파이크는 하네스 직후, 규칙 선정과 병행 가능하다. 규칙 선정과 프리셋 분리 중 무엇을 먼저 할지는 스파이크 결과에 달려 있지 않다 — 다만 실측은 "분리 전 단일 파일" 기준으로 하는 편이 변수가 적다.
4. 릴리스 정책(semver, CHANGELOG 형식)은 규칙 선정 **전에** 형식만 정해 둔다. 실측 결과가 그 형식으로 바로 들어간다.

## Needs Empirical Verification

이번 조사에서 실행하지 않은 것. 해당 phase 의 첫 작업으로 확인한다. (저장소를 수정하지 않는 조건이라 실험하지 않았다.)

| # | 확인할 것 | 근거가 된 소스 | Phase |
|---|-----------|----------------|-------|
| V1 | 이름이 `analysis_options.yaml` 이 아닌 프리셋 파일의 `plugins:` 가 include 경유로 로드되는가. 2단 include 에서도 되는가 | `_applyPlugins`, `_ParsedPluginsData.parse` | 프리셋 분리 |
| V2 | 그 구조에서 이 저장소 루트의 `plugins_in_inner_options` 가 사라지는가 | 같은 곳 | 프리셋 분리 |
| V3 | plugin 준비 실패 + 다른 진단 존재 시 `dart analyze` 종료 코드 (4 가 아닐 것으로 읽힘) | `analyze.dart`, `analysis_server.dart` | 검증 하네스 |
| V4 | `dart analyze --format=json` 에서 plugin 진단의 `code` 표기(접두사 유무) | — | 검증 하네스 |
| V5 | 사용 프로젝트에서 plugin 진단 하나만 끄려면 무엇을 적어야 하는가 | `_applyPlugins` (이름별 전체 교체) | 프리셋 분리 |
| V6 | plugin 이 `analyzer.exclude` 와 `// ignore_for_file` 을 존중하는가 | — | 프리셋 분리 |
| V7 | 3.13 의 새 규칙들이 언어 버전 3.11 프로젝트에서 보고되는가 | SDK CHANGELOG 3.13.0 | 규칙 선정 |
| V8 | `async_return_with_no_await` 와 `unnecessary_await_in_return` 동시 활성 시 동작 | rules.json | 규칙 선정 |
| V9 | pub workspace 멤버 패키지에서 Riverpod 프리셋 include 시 plugin 로드 여부 | sdk#61481 | 프리셋 분리 (README 에 적을지 판단용) |
| V10 | tag 를 옮긴 뒤 옛 lockfile 로 새 머신에서 `pub get` 이 되는가 | `git.dart _ensureRevision` | 릴리스 (원칙상 하지 않을 일이므로 우선순위 낮음) |
| V11 | plugin 내부 `riverpod` 버전과 사용 프로젝트 `riverpod` major 가 다를 때의 진단 | CONCERNS.md 기존 미확인 | 프리셋 분리 (README 호환 범위용) |
| V12 | Riverpod 미사용 프로젝트에서 plugin 로드가 분석 시간에 주는 영향 | CONCERNS.md 기존 미확인 | 프리셋 분리 (동기 확인용, 선택) |

## Sources

**Dart SDK 소스 (`3.13.4` tag = Flutter 3.47.5 번들; analyzer `14.1.0-dev`) — `[SRC]`**
- https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/analysis_options/analysis_options_parse_model.dart — `plugins_in_inner_options` 조건, `deprecated_lint`/`removed_lint`/`undefined_lint` 보고 조건, plugin 파싱
- https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/analysis_options/analysis_options_parser.dart — 섹션별 병합(`_ApplyState`)
- https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/analysis_options/analysis_options_include_walker.dart — `included_file_warning` 변환
- https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/lib/src/dart/analysis/context_locator.dart — exclude glob 기준 디렉터리
- https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analyzer/messages.yaml — 진단 심각도
- https://github.com/dart-lang/sdk/blob/3.13.4/pkg/dartdev/lib/src/commands/analyze.dart , https://github.com/dart-lang/sdk/blob/3.13.4/pkg/dartdev/lib/src/analysis_server.dart — 종료 코드, plugin 오류 처리
- https://github.com/dart-lang/sdk/blob/3.13.4/pkg/analysis_server/lib/src/plugin/plugin_manager.dart , `plugin_watcher.dart` , `../plugin2/generator.dart` — plugin 폴더, `pub upgrade`, AOT
- https://github.com/dart-lang/sdk/blob/3.13.4/pkg/linter/tool/machine/rules.json — 규칙 state / incompatible / fixStatus
- https://github.com/dart-lang/sdk/blob/3.13.4/pkg/linter/lib/src/rules/require_trailing_commas.dart — 언어 3.7 게이트
- https://github.com/dart-lang/sdk/blob/3.13.4/CHANGELOG.md — 3.9 ~ 3.13 Analyzer/Linter/Formatter/Pub 절

**공식 문서 — `[DOC]`**
- https://dart.dev/tools/analysis (include 병합, 규칙 끄기, formatter) — Context7 `/dart-lang/site-www` + 원문
- https://dart.dev/tools/analyzer-plugins — Context7 + 원문
- https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server_plugin/doc/using_plugins.md (로컬 `analysis_server_plugin-0.3.24/doc/` 로도 확인)
- https://dart.dev/tools/dart-analyze , https://dart.dev/tools/dart-format
- https://dart.dev/tools/pub/dependencies#git-packages (`ref`, `tag_pattern`) , https://dart.dev/tools/pub/cmd/pub-get
- https://riverpod.dev/docs/introduction/getting_started — Context7 `/rrousselgit/riverpod`
- https://github.com/dart-lang/dart_style/blob/main/CHANGELOG.md , https://github.com/dart-lang/dart_style/blob/main/lib/src/config_cache.dart
- https://github.com/dart-lang/pub/blob/master/lib/src/source/git.dart
- https://github.com/VeryGoodOpenSource/very_good_analysis (README: 버전 박힌 옵션 파일, excluded rules 표)
- https://github.com/subosito/flutter-action (README, v2.23.0)
- https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax (branches/tags 필터) — WebFetch
- https://git-scm.com/docs/git-push (`--follow-tags`, `--tags`) — WebFetch

**Issue — `[ISSUE]` (웹 검색 후 GitHub API 로 원문 확인)**
- https://github.com/flutter/flutter/issues/193203 — Flutter 3.47.5 / Dart 3.13.4 명령별 plugin 진단 표 (#187999 의 중복으로 닫힘)
- https://github.com/flutter/flutter/issues/187999 — `flutter analyze` plugin 진단 누락 (open)
- https://github.com/dart-lang/sdk/issues/63787 — 분석 완료 신호가 plugin 진단보다 먼저 온다 (open)
- https://github.com/dart-lang/sdk/issues/62710 — 디렉터리 인자 시 plugin 규칙 미검출 (2026-10-01 닫힘, "Dart 3.14 에 실릴 것")
- https://github.com/dart-lang/sdk/issues/61481 , https://github.com/dart-lang/sdk/issues/63627 — inner 옵션의 plugin 지원 설계
- https://github.com/dart-lang/sdk/issues/62164 — legacy plugin 시스템 폐기 (3.13.2)
- https://github.com/rrousselGit/riverpod/issues/4839 — riverpod_lint 3.1.7/3.1.8 이 Dart 3.12.2 에서 `dart analyze` 를 멈춤

**로컬 관찰 — `[LOCAL]` (읽기 전용)**
- `~/.pub-cache/hosted/pub.dev/`: `riverpod_lint-3.1.3`, `-3.1.9` (pubspec, CHANGELOG, README, `lib/main.dart`), `analysis_server_plugin-0.3.24`, `analyzer-12.1.0` / `-14.4.0` / `-14.5.0`, `lints-6.1.0`, `flutter_lints-6.0.0`, `freezed-3.2.5`
- `~/.dartServer/.plugin_manager/` 아래 폴더들(30개 이상)의 `pubspec.yaml` / `pubspec.lock`
- `~/fvm/versions/3.47.5` 의 `dart analyze --help -v`, `flutter analyze --help`, SDK 스냅샷 문자열
- `~/dv/woody/flutter_starter_kit`: `analysis_options.yaml`, `pubspec.yaml`, `pubspec.lock`, 파일 수 집계, `ignore` 주석 집계
- `~/.claude/gsd-core/workflows/complete-milestone*` — `git.create_tag` 동작

**확인하지 못한 것 / LOW**
- 다른 생태계 linter 들의 semver 정책 비교 (웹 검색 요약만 봄, 원문 미확인)
- dart-lang/lints#205 의 `prefer_const_*` 제거 사유 원문 (저장소 이전으로 API 조회 실패. `flutter_lints` CHANGELOG 의 참조만 확인)
- `very_good_analysis` README 가 `unnecessary_await_in_return` 을 "Deprecated" 로 적고 있으나 3.13.4 rules.json 에서는 `stable` 이다 — 다음 SDK 에서의 상태 변화로 추정되나 확인하지 않았다

---
*Pitfalls research for: Dart/Flutter 공유 lint 설정 패키지 (woody_lints) — 규칙 재선정 · 프리셋 분리 · 검증 · tag 릴리스 · 문서*
*Researched: 2026-10-11*
