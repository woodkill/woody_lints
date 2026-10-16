# Phase 4: Rule Reselection - Context

**Gathered:** 2026-10-13
**Status:** Ready for planning

<domain>
## Phase Boundary

`flutter_starter_kit` 복사본에서 후보 규칙마다 경고 건수와 `dart fix` 로 고쳐지는 건수를 재서 평가표 하나로 만들고, 소유자가 그 표를 보고 규칙마다 켤지 정한다. 결정은 `lib/base.yaml` 에 반영하고, 켠 이유와 켜지 않은 이유를 근거 문서로 남긴다. 이 phase 가 끝나면 다음이 참이다 (ROADMAP 성공 기준 1 ~ 5).

1. 소유자가 후보 규칙(버그 방지, 성능, 가독성·스타일, strict 계열)마다 실측 건수와 `dart fix` 로 고쳐지는 건수를 표 하나에서 본다 (RULES-03, RULES-04)
2. 표의 수치마다 어느 실측 회차에서 나왔는지 따라갈 수 있고, 회차 기록에 SDK / 기반 세트 / plugin 버전이 있으며, 일부러 넣은 위반이 보고되지 않은 회차의 수치는 쓰지 않았다 (RULES-05)
3. 후보마다 소유자의 채택 / 미채택 결정이 있고, 배포 파일에서 켜진 규칙이 채택 목록과 같다 (RULES-06)
4. 배포 파일에 기반 세트와 겹치는 선언과 주석 처리된 설정이 없고, 남은 규칙의 사유 주석이 사실과 맞다 (RULES-01, RULES-02, RULES-07)
5. 켠 규칙마다 이유와 실측 건수를 적은 근거 문서와 미채택 목록이 저장소에 있다 (DOCS-11, RULES-08)

이 phase 가 하지 않는 것: README 재작성과 배포 YAML 머리 주석 정리(Phase 5 — DOCS-01 ~ 10, VERIFY-06), tag 와 `main` 병합(Phase 6), 사용 프로젝트에 새 버전을 적용하고 경고를 정리하는 일(Out of Scope). `main` 은 건드리지 않는다. 규칙별 채택(로드맵 D13)은 이 논의에서 정하지 않았다 — 실측 표가 나온 뒤 소유자가 정한다. 이 논의는 그 표의 모양과 결정 방식을 정했다.

</domain>

<decisions>
## Implementation Decisions

### 이전에 확정되어 그대로 따르는 것

다시 논의하지 않았다. 출처는 ROADMAP.md / REQUIREMENTS.md / PROJECT.md / 01 ~ 03-CONTEXT.md / `spike-findings-woody-lints` skill 이다.

- 기반 세트와 겹치는 선언 6개(`sized_box_for_whitespace`, `sort_child_properties_last`, `slash_for_doc_comments`, `use_build_context_synchronously`, `avoid_print`, `control_flow_in_finally`)와 주석 처리된 설정 3개(`require_trailing_commas`, `public_member_api_docs`, `formatter: trailing_commas`)는 지운다 (RULES-01, RULES-02 의 문구가 "삭제" 다)
- 실측은 `flutter_starter_kit` 의 **복사본**에서만 한다. 원본은 읽기만 한다 (PROJECT.md Safety). 복사본의 `pubspec_overrides.yaml` 이 `path:` 로 작업 중인 저장소 자체를 가리키고, 받은 자리(`package_config.json` 의 `rootUri`)가 저장소가 아니면 그 회차를 버리며, 실행 전후로 저장소의 지문을 견준다 (spike 021 의 `consumer.dart`, 022 의 `repo_guard.dart`)
- 실측과 검증은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 `fvm dart …` 로, plugin 진단은 `dart analyze` 로 본다 (`flutter analyze` 를 쓰지 않는다)
- strict 계열은 lint 형태(`no_dynamic_casts`, `no_raw_types`)와 `strict-inference` 로 잰다. `strict-casts` 옵션은 error 를 내 사용 프로젝트의 `dart analyze` 를 즉시 실패시키므로 쓰지 않는다 (ROADMAP Notes, FEATURES.md D절)
- 평가표의 값은 사용 프로젝트의 무시 주석을 **둔 채로** 잰 값이다 (채택하면 실제로 받는 줄). `dart fix` 건수는 소스를 원본으로 둔 복사본에서 규칙 하나씩 `dart fix --apply --code=<규칙>` 한 뒤 다시 분석해 사라진 그 규칙의 줄 수로 센다. 단독 dry 의 수, 그룹 dry 의 수, `rules.json` 의 `hasFix` 를 그 값으로 쓰지 않는다 (spike 022 · 023)
- `rules.json` 의 `state` · `sets` · `fixStatus` 를 평가표에 옮기지 않는다. deprecated / removed / 없는 이름은 저장소 하한(`^3.13.0`)을 적은 pubspec 옆에서 분석해 가르고, stable / experimental / testing 은 SDK tag 3.13.4 의 `pkg/linter/messages.yaml` 에서 읽으며, 상류 세트는 저장소 루트가 받은 `lints` · `flutter_lints` 의 YAML 에서 읽는다 (spike 020)
- 함께 쓸 수 없는 규칙의 쌍은 쌍마다 둘만 켜서 확인한다. 후보를 한꺼번에 잴 때는 그런 쌍이 한 그룹에 들지 않게 나눈다 (spike 020 · 022)
- 언어 버전 3.13 에서만 도는 규칙(`empty_container_bodies`, `unnecessary_type_name_in_constructor`, `unnecessary_const_in_enum_constructor`, `use_primary_constructors`, `initialize_in_field_declaration`, `use_declaring_parameters`)은 값을 둘 적는다 — 지금 하한(`^3.11.1`)에서의 0 (규칙이 돌지 않음)과, 복사본의 하한만 `^3.13.0` 으로 올린 실행의 값. 하한을 올린 실행은 기준선도 올린 채로 다시 잰다 (`prefer_initializing_formals` 27줄이 섞인다 — spike 021)
- 새 규칙을 켜는 것은 minor 다 (`VERSIONING.md` 기준표). 이 phase 의 변경은 `CHANGELOG.md` 의 `## 2.0.0 - 미출시` 항목에 적고, `### 새로 생기는 경고` 의 자리 표시 `(Phase 4 실측 후 채움)` 을 `| 규칙 | 강도 | 실측 | dart fix |` 표와 `실측: flutter_starter_kit (Dart 파일 N개), Flutter X.Y.Z, YYYY-MM-DD` 한 줄로 바꾼다 (`VERSIONING.md` § "CHANGELOG 항목 형식")
- 규칙은 `lib/base.yaml` 의 `linter: rules:` 에 목록 형식으로, 분류 주석 아래에 한 줄 한국어 사유 주석을 달아 적는다 (CLAUDE.md 의 규칙 추가 관례)
- 판정은 정답지 비교가 주 수단이다. 정답지 한 줄은 `상대경로:줄  강도  규칙이름`, 맨 위에 `exit N` 이다 (02-CONTEXT.md D-04). `--update` 는 모든 정답지를 한 번에 쓰고, 같은 실행에서 하나라도 이상하면 어느 정답지도 쓰지 않는다 (03-CONTEXT.md D-05)

### 평가표의 모양

- **D-01:** 평가표에는 **후보를 전부** 올려 잰다 (약 120개).
  - 올리는 것: FEATURES.md 의 버그 방지(B-1) · 성능(B-2) · 가독성·스타일(B-3) 후보, strict 계열 3개(`no_dynamic_casts`, `no_raw_types`, `strict-inference`), Dart 3.13 의 새 규칙(B-4), 제외 권장 목록(B-6), 지금 `base.yaml` 이 켜는 이 패키지만의 규칙 6개(`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `always_declare_return_types`, `prefer_final_locals`, `prefer_single_quotes`, `unawaited_futures`)
  - v2 로 미룬 규칙은 숫자만 참고로 싣고 이번에 결정하지 않는다 — API 문서 규칙(B-5, RULES-09), primary constructor 전환 규칙(RULES-10 — 위의 언어 버전 3.13 전용 6개와 `unnecessary_primary_constructor_body`), `migrate_design_widgets` (RULES-11). 미채택 목록에 "v2 로 미룸" 과 요구사항 ID 를 사유로 적는다
  - deprecated / removed / Dart 3.13 에 없는 규칙(B-7)은 재지 않고 미채택 목록에 상태만 적는다
  - 근거: 기반 세트 밖의 Dart 3.13.4 stable 규칙 129개가 모두 FEATURES.md 에 이름이 있다 (2026-10-13, spike 020 의 결과 JSON 과 대조). 분석 한 번이 약 25초라 B-6 까지 재도 비용이 거의 같고, 미채택 사유에 숫자가 붙는다
  - 고르지 않은 안: 제외 권장은 재지 않기 / 좁힌 후보만
- **D-02:** 평가표의 칸을 **고쳐서 쓴다.** ROADMAP Phase 4 Notes 의 "평가표의 열을 고정한다: `state` / 심각도 / `fixStatus` / 실측 건수 / `dart fix` 가능 건수 / 상류 세트 포함 여부. … 규칙 메타데이터는 SDK tag 고정 `rules.json` 을 기준으로 삼는다" (ROADMAP.md 195행, 2026-10-13 확인) 를 아래로 바꾼다.

  | 칸 | 값을 얻는 곳 |
  |---|---|
  | 상태 | 위의 "이전에 확정" 의 출처 (분석 + `messages.yaml`). 출처끼리 갈리는 넷(`unnecessary_ignore`, `unnecessary_underscores`, `use_primary_constructors`, `migrate_design_widgets`)은 출처마다 적는다 |
  | 강도 | 실측 JSON 의 `severity`. tag 3.13.4 의 `messages.yaml` 에는 심각도 표기가 0건이다 (2026-10-13 확인) — lint 는 info 로, `strict-inference` 의 `inference_failure_on_*` 는 warning 으로 나온다 |
  | 실측 건수 | 무시 주석을 둔 채의 줄, `lib` / `test` (와 `bin`) 로 나눠 적는다. 언어 버전 3.13 전용 규칙은 값 둘 |
  | `dart fix` 로 사라진 줄 | 규칙 하나씩 apply 해 사라진 그 규칙의 줄 |
  | 고친 뒤 새로 생긴 error | 같은 apply 뒤 새로 생긴 다른 진단 가운데 error 의 수 (`diagnostic_describe_all_properties` error 148 같은 경우) |
  | 무시 주석이 가린 줄 | 주석을 걷어낸 복사본과의 차이 (spike 023 의 `stripIgnores`) |
  | 상류 세트 | 저장소 루트가 받은 `lints` · `flutter_lints` YAML. 가장 아래 세트로 적는다 |
  | 함께 쓸 수 없는 규칙 | 쌍마다 둘만 켜서 확인한 결과 |

  - `fixStatus` 칸은 없앤다 — `rules.json` 의 값은 "고치는 방법이 등록되어 있다" 이고, `hasFix` 인데 apply 할 것이 0 인 규칙이 다섯 있다 (spike 022). CHANGELOG 의 `dart fix` 칸도 "고쳐지는 건수" 로 정해져 있다
  - ROADMAP Notes 의 "칸이 하나라도 비면 그 규칙은 결정하지 않는다" 는 그대로 둔다. 실측 0줄인 규칙의 `dart fix` 칸은 "해당 없음" 으로 채운다
  - 고르지 않은 안: 로드맵 여섯 칸 그대로 두고 `fixStatus` 는 "등록 여부" 라고 적기
- **D-03:** 0줄을 해석하는 표식은 **0줄인 후보에만 규칙별로** 둔다. 회차마다 공통 표식(`example/` 의 샘플 — 정답지 16줄)은 늘 둔다.
  - 프로젝트에서 1줄 이상 나온 규칙은 그 결과가 "규칙이 돌았다" 의 증거다. 0줄인 후보에는 그 규칙을 어기는 표식을 넣고, 표식에서도 나오지 않으면 "규칙이 돌지 않음" 으로 적어 결정하지 않는다 (RULES-05)
  - 근거: spike 019 의 `public_member_api_docs` 0줄은 표식으로 갈렸고, spike 021 의 새 규칙 넷은 지금 하한에서 표식까지 0줄이었으며, spike 022 는 규칙별 표식이 없어 0줄인 58개의 뜻을 가르지 못했다
  - 채택된 규칙의 표식은 D-10 의 연습용 프로젝트 샘플로 옮겨 쓸 수 있다
  - 고르지 않은 안: 모든 후보에 표식 / 공통 표식만

### 채택 기준과 검토 순서 (로드맵 D13 의 진행 방식)

- **D-04:** 규칙별 채택은 **권고 + 묶음 승인**으로 정한다.
  - Claude 가 평가표의 규칙마다 켬 / 안 켬 권고와 이유 한 줄을 붙인다. 소유자는 분류 묶음마다(버그 방지 / 성능 / 가독성·스타일 / strict / 지금 켜 둔 6개 / 제외 권장) "권고대로" 로 승인하거나 바꿀 규칙만 짚는다
  - 묶음에 넣지 않고 **하나씩 묻는 것:** 로드맵 D13 이 이름을 적은 것 — strict 계열(`no_dynamic_casts`, `no_raw_types`, `strict-inference`), `unnecessary_ignore`, import 스타일(`always_use_package_imports` 대 `prefer_relative_imports`), fire-and-forget 표기법(`unawaited_futures` · `discarded_futures` · `unnecessary_unawaited` 와 `unawaited()` / `// ignore` / `@awaitNotRequired`) — 과 함께 쓸 수 없는 쌍, 상태 출처가 갈리는 규칙 (D-05)
  - 이 결정 지점은 소유자 검토 없이 끝나지 않는다 (ROADMAP D13). 계획에서는 사람이 답해야 하는 checkpoint 다
  - 고르지 않은 안: 하나씩 묻기(약 120번) / 기준만 정하고 Claude 가 적용
- **D-05:** 권고를 만드는 잣대는 **분류마다 다르다.** 잣대는 권고의 근거이고, 최종 결정은 D-04 의 승인에서 소유자가 한다.
  - **공통으로 "안 켬" 권고:** `messages.yaml` 기준 experimental / testing 인 규칙 (Out of Scope "experimental 규칙 활성화"), `base.yaml` 에 켜진 규칙과 함께 쓸 수 없는 규칙 (`prefer_double_quotes`, `unnecessary_final` 등), `dart fix` 가 코드를 깨뜨리는 규칙 (고친 뒤 새 error 가 생김), v2 로 미룬 규칙
  - **버그 방지 · strict:** 경고가 실제 문제를 가리키면 건수와 상관없이 "켬", 오탐이 많으면 "안 켬"
  - **성능 · 가독성·스타일:** `dart fix` 가 거의 다 고치거나 손으로 고칠 줄(경고 − `dart fix` 로 사라진 줄)이 **50줄 이하**일 때 "켬". 50은 추정으로 잡은 값이다
  - **상태 출처가 갈리는 규칙**(`unnecessary_ignore` — `messages.yaml` experimental, `rules.json` · dart.dev stable)은 묶음에 넣지 않고 하나씩 묻는다. 기반 세트의 `use_super_parameters` 가 세 출처 모두 experimental 인데 이미 켜져 있다는 사실(spike 020)을 함께 보인다
  - 고르지 않은 안: 숫자 하나(손으로 고칠 줄 N 이하) / 최소한만(버그 방지만 더함)
- **D-06:** 검토 때 평가표는 **묶음마다 터미널 요약**으로 보이고, 전체 표는 저장소 파일(D-08 의 `RULES.md`)로 둔다.
  - 터미널 요약의 칸: 규칙 / 경고 / `dart fix` 로 사라진 줄 / 고친 뒤 새 error / 권고 / 이유
  - 고르지 않은 안: 같은 표를 claude.ai 비공개 웹 페이지로도 띄우기 (Deferred 참조)

### 근거 문서와 공개 범위

- **D-07:** 공개 저장소에 적는 `flutter_starter_kit` 의 정보는 **이름 + 규칙별 건수 + 회차 조건**이다. — **Reversibility:** one-way — `woodkill/woody_lints` 는 GitHub 에서 공개이고 `.planning/` 도 함께 올라가므로, 한 번 올린 경로 · 메시지는 브랜치를 지워도 복제본 · 캐시에 남는다
  - 적는 것: 프로젝트 이름, 규칙별 건수(`lib` / `test` 로 나눔), 회차 조건(SDK · 기반 세트 · plugin 버전 · Dart 파일 수 · 날짜 · 복사본의 SDK 하한)
  - 적지 않는 것: 파일 경로, 진단 메시지, 코드 조각, `dart fix` 화면 원문. 이것들은 저장소 밖 작업 폴더에만 둔다 (spike 022 의 `<작업 폴더>/private/` 방식)
  - 이 규칙은 `RULES.md` 만이 아니라 원격에 올라가는 `.planning/` 의 PLAN · SUMMARY · VERIFICATION 등에도 똑같이 적용한다. 측정 도구(D-09)의 저장소 쪽 출력에도 적용한다
  - 근거: `woodkill/flutter_starter_kit` 는 GitHub 에서 PRIVATE 이다 (2026-10-13 `gh repo view` 로 확인). 프로젝트 이름은 이미 공개되어 있다 (`VERSIONING.md` 2회, 원격의 `.planning/PROJECT.md` 5회, CHANGELOG 형식이 이름을 요구한다). spike 019 ~ 023 이 스스로 건 조건을 소유자 결정으로 확정한 것이다
  - 고르지 않은 안: 파일 경로별 건수까지 / 이름도 가림
- **D-08:** 근거 문서(DOCS-11), 미채택 목록(RULES-08), 평가표(RULES-03)는 **저장소 루트의 `RULES.md` 한 파일**에 둔다.
  - 절 셋: 켠 규칙 표 (규칙 / 분류 / 켠 이유 / 실측 건수 / `dart fix`), 켜지 않은 규칙 표 (규칙 / 이유 — very_good_analysis README 의 "Excluded rules" `| Rule | Reason |` 형식을 참고), 실측 기록 (전체 평가표 + 회차 조건)
  - `lib/base.yaml` 의 사유 주석은 규칙마다 한 줄로 두고 사실에 맞게 고친다 (RULES-07). 자세한 근거는 `RULES.md` 에 둔다
  - README 가 `RULES.md` 를 어떻게 안내할지는 Phase 5 의 일이다 (로드맵 D10)
  - 고르지 않은 안: `RULES.md` 는 결정만 두고 평가표 · 회차는 `.planning/` 에 / `.planning/` 에만
- **D-09:** 규칙을 재는 도구를 **`tool/measure_rules.dart` 로 커밋**한다.
  - 사용 프로젝트의 경로는 스크립트에 적지 않고 실행할 때 인자로 받는다. 저장소에 쓰는 출력은 D-07 의 범위(건수와 회차 조건)뿐이고, 원문은 저장소 밖 작업 폴더에 쓴다
  - 다시 잴 일이 예정되어 있다 — v2 의 RULES-13 (`lints` 7 / `flutter_lints` 7), 고정 SDK 를 Dart 3.14 계열로 올릴 때
  - 비공개 프로젝트가 있어야 돌므로 CI 에서는 돌지 않는다. `tool/` 의 Dart 파일이라 저장소 루트 분석(커밋 전 린터)의 대상이다
  - spike 021 ~ 023 의 코드(`consumer.dart` 의 복사 · 받은 자리 확인 · `useSdk`, `repo_guard.dart` 의 지문, 022 의 apply 고리, 023 의 `stripIgnores`)를 이어 받는다. 복사본의 기반 세트 버전은 **복사본의** `.dart_tool/package_config.json` 에서 읽는다 — spike 에는 그 코드가 없다 (rule-evaluation-table.md 9번)
  - 고르지 않은 안: 저장소 밖에서만 돌리고 표만 커밋 / `.planning/` 에 기록용으로만 커밋

### 정답지와 검증 장치

- **D-10:** 새로 켠 규칙마다 연습용 프로젝트에 **위반 샘플을 하나 이상** 넣어, 정답지에 그 규칙의 줄이 생기게 한다.
  - 지금 `example/lib/added_rules.dart` 에 이 패키지만의 규칙 6개의 샘플이 하나씩 있고, 그 덕에 "규칙 하나를 지우면 검증이 실패한다" (VERIFY-08, Phase 2 지워 보기 M1)가 성립한다. 새 규칙에도 같은 보장을 준다
  - 샘플 소스는 연습용 프로젝트마다 복사본이 있다 — `example/lib/` 와 `fixtures/{base_only,base_riverpod,base_codegen,overrides}/lib/`. 샘플 하나가 기본 규칙을 받는 정답지 다섯을 함께 바꾼다 (`fixtures/recommended` 는 `example/` 의 정답지와 견준다)
  - 정답지의 바뀐 줄은 규칙 결정과 하나씩 대응해야 한다 (ROADMAP Notes)
  - 고르지 않은 안: 분류마다 대표 몇 개 / 샘플을 더하지 않음
- **D-11:** 정답지가 잡지 못하는 두 가지를 **검증 명령의 검사로** 지킨다.
  - (1) `lib/base.yaml` 의 규칙이 기반 세트(저장소 루트가 받은 `lints` · `flutter_lints` 의 YAML)와 겹치면 실패
  - (2) `RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록이 다르면 실패 (성공 기준 3 의 "배포 파일에서 켜진 규칙이 채택 목록과 일치")
  - 근거: 겹치는 6개를 지워도 정답지는 한 줄도 바뀌지 않는다 — 기반 세트가 여전히 켜고, 그 샘플은 `example/lib/base_rules.dart` 에 있다 (2026-10-13 확인). analyzer 도 겹침을 경고하지 않는다 (FEATURES.md C절). `lints` 7 은 기반 세트에 규칙을 더해 새 겹침을 만든다 (RULES-13)
  - Phase 5 의 VERIFY-06 (README 규칙 목록 ↔ YAML) 이 (2)의 방식을 이어 쓸 수 있다
  - 고르지 않은 안: 겹침만 검사 / 둘 다 실행 기록으로 한 번만 확인
- **D-12:** Phase 3 이 남긴 검증 빈틈 셋 가운데 **WR-01 만 이 phase 에서 닫는다.**
  - WR-01 (거짓 통과 — 묶음 `recommended.yaml` 이나 옛 주소 별칭에 적은 규칙을 규칙 검사가 보지 않는다): D-11 의 검사를 만들 때 "묶음과 별칭은 `include:` 만 담는다" 를 함께 확인해 닫는다
  - WR-02 (거짓 실패 — `riverpod.yaml` 의 plugin 줄 끝 주석 · 마지막 줄바꿈 없음에서 종료 코드 70): Phase 5 의 첫 일로 넘긴다. Phase 5 가 YAML 머리 주석을 고칠 때(DOCS-10) 밟는 자리다
  - WR-03 (거짓 실패 — `base.yaml` 의 맵 형식 규칙): 목록 형식 관례로 피하고 열어 둔다
  - 처리 결과는 `03-REVIEW-DISPOSITION.md` 의 해당 행에 적는다
  - 고르지 않은 안: 셋 다 닫기 / 그대로 두기

### 묻지 않고 잡은 것

논의 끝에 목록으로 보였고 소유자가 반대하지 않았다 ("CONTEXT 작성" 을 골랐다). 명시적으로 고른 선택지는 아니다 (02-CONTEXT.md D-12, 03-CONTEXT.md D-07 의 표기와 같다).

- **D-13:** 기본 프리셋에 `formatter:` 를 넣지 않는다 (로드맵 D14 — REQUIREMENTS.md Out of Scope 그대로)
- **D-14:** 최종 숫자는 이 phase 에서 다시 잰다. spike 020 ~ 023 의 수치(2026-10-12)는 방법의 근거로만 쓰고 평가표에 옮기지 않는다 — `flutter_starter_kit` 에 2026-10-13 커밋이 있다
- **D-15:** 평가표의 기본값은 사용 프로젝트의 지금 하한(`^3.11.1`)에서 잰 값이다. 하한을 올린 값은 언어 버전 3.13 전용 규칙의 둘째 값으로만 쓴다
- **D-16:** `flutter_starter_kit` 에서 `ignore_for_file: type=lint` 를 단 이름이 `*.g.dart` · `*.freezed.dart` 꼴이 아닌 파일 다섯은 다른 도구가 만든 파일이다 (2026-10-13 읽기 전용 확인 — spike 023 이 "소유자에게 물을 일" 로 남긴 항목). "무시 주석을 둔 채로 잰다" 를 그대로 적용한다. 그 파일들이 어떤 후보에도 보이지 않는 것은 정상이다
- **D-17:** `unnecessary_ignore` 는 다른 후보의 채택이 정해진 **뒤** 그 결과를 켠 채로 다시 재서 하나씩 묻는다 (spike 023 — 다른 후보에 따라 38 ↔ 12)
- **D-18:** 지금 켜 둔 6개도 묶음 하나로 검토한다. 남기더라도 사유 주석은 사실에 맞게 고친다 — `prefer_const_constructors` · `prefer_const_literals_to_create_immutables` 의 "성능 향상" 문구는 Flutter 팀이 근거 부족으로 본 주장이고 (`flutter_lints` 5.0.0 이 제거, dart-lang/lints#205), `always_declare_return_types` 가 기반 세트의 `strict_top_level_inference` 에 더하는 범위는 지역 함수와 옛 typedef 다 (FEATURES.md C절)
- **D-19:** `strict-inference` 는 lint 가 아니라 analyzer 옵션(`analyzer: language: strict-inference: true`)이고 진단이 warning 이다. 받는 쪽의 `dart analyze` 는 warning 에서 실패한다 (`--fatal-warnings` 기본 켜짐, `VERSIONING.md`). D-04 에서 하나씩 물을 때 이 점을 함께 보인다
- **D-20:** 커밋 순서 — 겹치는 6개와 주석 처리된 3개를 지우는 커밋을 먼저 하고 정답지 다섯이 바뀌지 않음을 확인한다. 규칙 추가는 결정 묶음별 커밋으로 해서 정답지의 바뀐 줄이 결정과 대응하게 한다
- **D-21:** `lib/codegen.yaml` 의 `invalid_annotation_target: ignore` 는 다시 재지 않고 그대로 둔다 (03-CONTEXT.md D-02)
- **D-22:** GitHub 에 올리기는 Phase 3 과 같은 방식이다 — 이 phase 의 **첫 push 만** 확인받고, 같은 브랜치(`gsd/v2.0-package-rework`)에 더 올리는 것은 실행한 뒤 보고한다. `main` · tag · 덮어쓰는 push(`--force` 계열)는 매번 확인받는다. push 는 브랜치 이름 하나만 지정한다 (03-CONTEXT.md D-09). — **Reversibility:** one-way — 공개 저장소에 올린 내용은 사실상 되돌릴 수 없다
- **D-23:** 로드맵을 정리한다 — ROADMAP Phase 4 의 "Spike first" 에 "spike 020 ~ 023 으로 완료 (2026-10-12)" 를 표시하고 (Phase 3 의 선례), Notes 의 평가표 칸 문구(195행)를 D-02 대로 고치며, Phase 5 Notes 에 WR-02 를 첫 일로 적는다 (D-12)

### Claude's Discretion

소유자에게 묻지 않고 조사 · 계획 단계에 맡긴 것.

- 후보의 그룹 나누기 (함께 쓸 수 없는 쌍과 언어 버전 3.13 전용 규칙을 다른 그룹에 — spike 022 의 G1 ~ G4 를 출발점으로)
- 규칙별 표식의 문법과 자리 (복사본의 `lib/woody_probe_marker/` 아래 — spike 019 ~ 023 의 방식), 표식과 D-10 샘플의 공유 방법
- `tool/measure_rules.dart` 의 인자 · 출력 형식, 회차 기록을 `RULES.md` 와 함께 둘 데이터 파일(건수만)로 커밋할지
- apply 를 돌릴 규칙의 범위 (단독 dry 가 0 이 아닌 규칙만 — spike 022 는 약 36개로 셈. 규칙당 약 30초)
- D-11 · D-12 의 검사를 `tool/verify.dart` 의 어느 단계에 넣을지, 단계 수와 번호, `example/README.md` 에 지워 보기 기록(M 번호)을 더하는 범위
- 묶음 승인 때 터미널 요약의 분량 (한 묶음이 너무 크면 나눈다)
- `CHANGELOG.md` 2.0.0 항목의 문구 — 겹치는 6개 삭제는 받는 쪽에 변화가 없으므로 `### 그 밖의 변경` 에 "사용하는 프로젝트에는 영향 없음" 으로, 새로 켠 규칙은 `### 추가한 규칙` 과 `### 새로 생기는 경고` 에
- 측정 원문을 둘 저장소 밖 작업 폴더의 자리 (Claude 의 scratchpad 등). 실측이 저장소 지문을 견주는 동안 저장소 안에 파일을 만들지 않는다 (spike 022 의 교훈)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 범위와 요구사항

- `.planning/ROADMAP.md` § "Phase 4: Rule Reselection" — goal, success criteria 5개, Spike first 4개, decision points D13 · D14, Notes (195행의 평가표 칸 문구는 D-02 로 바뀐다)
- `.planning/ROADMAP.md` § "모든 phase 에 걸친 제약" — `main` 은 1.3.0 유지, 구조 변경과 내용 변경을 섞지 않음, 원격 작업은 소유자 확인
- `.planning/REQUIREMENTS.md` — RULES-01 ~ 08, DOCS-11. v2 로 미룬 것: RULES-09 ~ 13, PRESET-09. Out of Scope 표 (`formatter:`, experimental, 일괄 warning 승격, "전부 켜고 일부만 끄기")
- `.planning/PROJECT.md` § Constraints (Safety — 원본 수정 금지), § Key Decisions

### 후보와 평가표

- `.planning/research/FEATURES.md` § "Candidate Lint Rules (Section B)" (B-1 ~ B-7 후보 표), § "Existing Rules Under Review (Section C)" (지금 규칙 12개와 주석 처리된 3개, const 규칙의 근거, `always_declare_return_types` 와 `strict_top_level_inference`), § "Analyzer Strict Modes (Section D)"
- `.claude/skills/spike-findings-woody-lints/SKILL.md` — 넷째 idea `rule-reselection-measurement` 의 요구 사항, "읽을 때 헷갈리기 쉬운 것"
- `.claude/skills/spike-findings-woody-lints/references/rule-evaluation-table.md` — 칸마다의 출처(1번), `state`(2 · 3번), 상류 세트(4번), 함께 쓸 수 없는 쌍(5번), 언어 버전 3.13 전용 규칙(6번), 무시 주석(7번), `dart fix` 건수(8번), 회차 기록(9번), What to Avoid
- `.claude/skills/spike-findings-woody-lints/references/real-consumer-measurement.md` — 복사본 만들기, `pubspec_overrides.yaml`, 받은 자리 확인, 저장소 지문, 표식, 비공개 기록 (1 · 2 · 3 · 6번)
- `.claude/skills/spike-findings-woody-lints/references/rule-status-check.md` 7번 — deprecated / removed 를 거르는 분석
- `.claude/skills/spike-findings-woody-lints/sources/021-new-rules-language-gate/consumer.dart`, `sources/022-dart-fix-dry-run-count/probe.dart` · `repo_guard.dart`, `sources/023-existing-ignore-comments/probe.dart`, `sources/020-rule-state-vs-rules-json/probe.dart` — D-09 의 도구가 이어 받을 코드
- `.planning/spikes/CONVENTIONS.md` — 저장소 지문을 견주는 실측 동안 저장소 안에 파일을 만들지 않는다

### 검증 명령과 정답지

- `tool/verify.dart` — 아래 code_context 의 자리
- `example/README.md` — 지워 보기 기록 M1 ~ M19 (D-10 · D-11 의 새 검사가 헛통과가 아님을 보이는 기록을 같은 형식으로 더한다)
- `.planning/phases/03-preset-split/03-REVIEW.md` § WR-01 · WR-02 · WR-03, `03-REVIEW-DISPOSITION.md` (D-12), `03-VERIFICATION.md` § Gaps Summary
- `.planning/phases/02-verification-harness/02-CONTEXT.md` § D-04 (정답지 형식), `.planning/phases/03-preset-split/03-CONTEXT.md` § D-03 ~ D-05 (연습용 프로젝트 여섯, `--update`), D-09 (push 확인 — D-22 가 따른다)

### 버전 · 기록 정책

- `VERSIONING.md` § "기준표" (새 규칙 = minor), § "CHANGELOG 항목 형식" (`### 추가한 규칙` / `### 뺀 규칙` / `### 새로 생기는 경고` 표와 실측 한 줄)
- `CHANGELOG.md` § `## 2.0.0 - 미출시` — `### 새로 생기는 경고` 의 자리 표시를 이 phase 가 채운다

### 논의에서 참고한 외부 문서

- https://raw.githubusercontent.com/dart-lang/sdk/3.13.4/pkg/linter/messages.yaml — 상태의 출처. 심각도 표기 0건 (2026-10-13 받아 셈)
- https://github.com/dart-lang/core/blob/main/pkgs/lints/README.md — core / recommended 의 목적과 Dart 팀의 정기 검토 방식 (D-04 · D-05 의 참고)
- https://github.com/VeryGoodOpenSource/very_good_analysis/blob/main/README.md § "Excluded rules" — `| Rule | Reason |` 표 (D-08 의 참고)
- https://github.com/dart-lang/lints/issues/205 — const 규칙을 기반 세트에서 뺀 논의 (D-18)

</canonical_refs>

<code_context>
## Existing Code Insights

### 논의 시점의 저장소 상태 (2026-10-13 확인)

- `lib/base.yaml` (47행): 1 ~ 12행 템플릿 영어 주석, 13행 `include: package:flutter_lints/flutter.yaml`, 15 ~ 16행 주석 처리된 `formatter:`, 20 ~ 40행 `linter: rules:` (규칙 12개 + 주석 처리된 `require_trailing_commas` 31행 · `public_member_api_docs` 34행), 43 ~ 47행 템플릿 영어 주석. 분류 주석은 `# 성능` 22행, `# 가독성 및 스타일` 27행, `# 버그 방지` 36행
- `lib/codegen.yaml` (`invalid_annotation_target: ignore`, 생성 파일 제외 두 줄), `lib/riverpod.yaml` (`riverpod_lint: ^3.1.9`), `lib/recommended.yaml` (조각 셋을 include), `lib/analysis_options.yaml` (묶음을 include 하는 별칭)
- `example/expected_diagnostics.txt` 는 `exit 2` + 16줄이다 — `lib/added_rules.dart` 6줄(이 패키지만의 규칙), `lib/base_rules.dart` 7줄(겹치는 6개 + `prefer_is_empty`), `riverpod_lint` 3줄
- 루트 `analysis_options.yaml` 은 `flutter_lints` 만 include 하고 `example/**` · `fixtures/**` 를 제외한다 — `tool/` 의 스크립트(D-09 포함)에는 기반 세트만 적용된다
- `woodkill/woody_lints` 는 PUBLIC, `woodkill/flutter_starter_kit` 은 PRIVATE 이다. `flutter_starter_kit` 의 SDK 제약은 `^3.11.1` 이고 마지막 커밋이 2026-10-13 이다

### Reusable Assets

- `tool/verify.dart` (1,545행): `fixtures` 표 40행, `ruleCheckTargets` 118행, `expectedLibYamls` 133행, `subtractLines` 646행, `stripPlugins` 769행, `readRuleNameAt` 833행, `countDeclaredRules` 848행, `checkRuleNames` 908행, `readShippedPluginConstraint` 1106행. D-11 · D-12 의 검사는 규칙 이름을 읽는 이 자리들과 맞물린다
- spike 021 ~ 023 의 실측 코드 (canonical_refs 의 `sources/`) — 복사, 받은 자리 확인, `useSdk`, 저장소 지문, 그룹별 분석, apply 고리, 무시 주석 걷어내기, 표식
- spike 020 의 `messages.yaml` 읽기(`snake`, `MessagesRule.latest`)와 상류 세트 읽기(`readUpstreamSets`)
- `example/lib/added_rules.dart` 와 각 fixture 의 같은 파일 — D-10 의 샘플을 더할 자리

### Established Patterns

- 정답지 갱신은 `fvm dart run tool/verify.dart --update` 하나로 다섯을 한꺼번에 쓰고, 바뀐 줄을 fixture 별로 보여 준다 (03-CONTEXT.md D-05)
- 실측으로 확인한 동작은 버전과 날짜를 함께 적고, 추정은 추정이라고 적는다
- 비공개 프로젝트의 기록은 건수와 규칙 이름만 (D-07)
- 커밋 메시지는 Conventional Commits, prefix 는 영어, 제목 · 본문은 한국어. 커밋 전에 `fvm dart analyze` 를 돌린다

### Integration Points

- **Phase 5:** README 는 `RULES.md` 를 안내하고 (D10 의 결정), VERIFY-06 이 D-11 (2)의 비교 방식을 이어 쓸 수 있다. WR-02 를 첫 일로 닫는다 (D-12). CHANGELOG 의 1.0.0 ~ 1.3.0 보완(DOCS-08)은 Phase 5 다
- **Phase 6:** 정답지에 샘플이 늘면 릴리스 smoke test 의 기대 진단도 그만큼 늘 수 있다. 루트 `pubspec.yaml` 의 `version` 을 올리면 fixture 의 lock 이 모두 어긋난다 (02-VERIFICATION.md 7번)
- **v2 (RULES-13):** `lints` 7 이 나오면 `tool/measure_rules.dart` 를 다시 돌리고 D-11 (1)의 겹침 검사가 새 겹침을 잡는다

</code_context>

<specifics>
## Specific Ideas

### 묶음 승인 때의 터미널 요약 (모양의 예 — 숫자는 spike 022 의 2026-10-12 값이며 최종값이 아니다)

```text
[버그 방지] 29개 — 권고: 켬 N · 안 켬 M

| 규칙                         | 경고 | dart fix | 고친 뒤 error | 권고  | 이유                        |
|------------------------------|------|----------|---------------|-------|-----------------------------|
| async_return_with_no_await   |   30 |        0 |             0 | (예)  | (이유 한 줄)                |
| ...                          |      |          |               |       |                             |
```

### 소유자와 소통하는 방식

- 결정을 요청할 때는 용어 풀이 → 찾아본 것(출처와 함께) → 비교표 → 굵은 `권고:` 한 줄 → 선택지 순서로 보인다. 소유자는 이번 논의의 선택 12건 모두에서 권고안을 골랐다
- 묶음 승인에서도 `권고:` 를 묶음마다 한 줄 적어 "권고대로" 가 무엇을 가리키는지 모호하지 않게 한다
- 추정한 숫자(손으로 고칠 줄 50, 규칙당 apply 약 30초)는 추정이라고 적어 보였다

</specifics>

<deferred>
## Deferred Ideas

- **평가표를 claude.ai 비공개 웹 페이지로도 띄우기** — D-06 에서 고르지 않았다. 묶음 승인 때 터미널 요약이 읽기 어렵다고 느끼면 그때 더한다
- **WR-02 (`riverpod.yaml` 의 거짓 실패)** — Phase 5 의 첫 일 (D-12, D-23 이 ROADMAP Phase 5 Notes 에 적는다)
- **WR-03 (맵 형식 규칙의 거짓 실패)** — 열어 둔다. 맵 형식을 쓰게 되면 그때 닫는다
- **`invalid_annotation_target: ignore` 를 지울지** — 이번에도 다시 재지 않는다 (D-21). 03-CONTEXT.md 의 Deferred 와 같다
- **학습용 프로젝트 넷에서의 실측** — 하지 않는다. Dart 파일이 1 ~ 9개이고 Riverpod · 코드 생성을 쓰지 않는다. 사용 프로젝트에 새 버전을 적용하는 일은 범위 밖이다
- **Dart 3.13 의 primary constructor 전환 규칙, `migrate_design_widgets`, API 문서 규칙** — v2 (RULES-09 ~ 11). 이번 평가표에는 숫자만 참고로 싣는다 (D-01)

</deferred>

---

*Phase: 4-Rule Reselection*
*Context gathered: 2026-10-13*
