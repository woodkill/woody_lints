# Phase 4: Rule Reselection - Research

**Researched:** 2026-10-13
**Domain:** Dart analyzer lint 규칙의 재선정 — 사용 프로젝트 복사본 실측 도구(`tool/measure_rules.dart`), 근거 문서(`RULES.md`), 검증 명령(`tool/verify.dart`)의 새 검사, 소유자 결정 checkpoint
**Confidence:** HIGH — 조사 대상의 거의 전부가 이 저장소 안의 파일과 spike 020 ~ 023 의 실측(2026-10-12)이고, 이 세션에서 그 파일들을 직접 읽었다. 바깥에서 가져온 것은 `dart fix --code` 의 문법(dart.dev 문서 + 고정 SDK 의 `--help`)과 very_good_analysis README 의 표 형식뿐이다

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### 이전에 확정되어 그대로 따르는 것

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

#### 평가표의 모양

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

#### 채택 기준과 검토 순서 (로드맵 D13 의 진행 방식)

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

#### 근거 문서와 공개 범위

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

#### 정답지와 검증 장치

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

#### 묻지 않고 잡은 것

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

### Deferred Ideas (OUT OF SCOPE)

- **평가표를 claude.ai 비공개 웹 페이지로도 띄우기** — D-06 에서 고르지 않았다. 묶음 승인 때 터미널 요약이 읽기 어렵다고 느끼면 그때 더한다
- **WR-02 (`riverpod.yaml` 의 거짓 실패)** — Phase 5 의 첫 일 (D-12, D-23 이 ROADMAP Phase 5 Notes 에 적는다)
- **WR-03 (맵 형식 규칙의 거짓 실패)** — 열어 둔다. 맵 형식을 쓰게 되면 그때 닫는다
- **`invalid_annotation_target: ignore` 를 지울지** — 이번에도 다시 재지 않는다 (D-21). 03-CONTEXT.md 의 Deferred 와 같다
- **학습용 프로젝트 넷에서의 실측** — 하지 않는다. Dart 파일이 1 ~ 9개이고 Riverpod · 코드 생성을 쓰지 않는다. 사용 프로젝트에 새 버전을 적용하는 일은 범위 밖이다
- **Dart 3.13 의 primary constructor 전환 규칙, `migrate_design_widgets`, API 문서 규칙** — v2 (RULES-09 ~ 11). 이번 평가표에는 숫자만 참고로 싣는다 (D-01)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| RULES-01 | 기반 세트와 중복되는 선언 6개가 삭제되어, 배포 파일에는 이 패키지가 실제로 추가하는 규칙만 적혀 있다 | 겹치는 6개의 자리는 `lib/base.yaml` 25 · 29 · 33 · 37 · 39 · 40행이고, 여섯이 모두 pub cache 의 `lints` 6.1.0 / `flutter_lints` 6.0.0 YAML 에 있는 것을 이 세션에서 확인했다 (§ "기반 세트와의 겹침"). 삭제 뒤 정답지가 불변인 까닭은 `example/lib/base_rules.dart` 의 샘플 7개다. D-11 (1) 의 겹침 검사가 재발을 막는다 (§ 4) |
| RULES-02 | 주석 처리된 설정 3개가 배포 파일에서 삭제되어 있다 | `lib/base.yaml` 15 ~ 16행(`formatter:`), 31행(`require_trailing_commas`), 34행(`public_member_api_docs`). `require_trailing_commas` 는 B-6 후보로 평가표에도 오르며 언어 버전 3.7 이상에서 보고하지 않아(FEATURES.md C절) 표식까지 0줄로 나올 것이다 — "규칙이 돌지 않음" 으로 미채택 목록에 적는다 |
| RULES-03 | 후보 규칙(버그 방지, 성능, 가독성·스타일)마다 복사본에서 잰 진단 건수와 `dart fix` 로 고칠 수 있는 건수를 표로 본다 | `tool/measure_rules.dart` 의 단계 설계(§ 1), 후보 133개의 유도(§ 2), `RULES.md` 의 실측 기록 절(§ 3) |
| RULES-04 | strict 계열(`no_dynamic_casts`, `no_raw_types`, `strict-inference`)이 같은 실측 표에 포함된다 | 둘은 G1 의 lint 로, `strict-inference` 는 G1 실행의 `analyzer: language:` 옵션으로 함께 켠다 (spike 021 의 `optionsWith(language:)`). 셋 다 하한 3.11 에서 돈다 (rule-evaluation-table.md 6번). 평가표 행 하나씩 — `strict-inference` 의 값은 `inference_failure_on_*` 코드 넷의 합이고 강도는 warning |
| RULES-05 | 회차마다 SDK / 기반 세트 / plugin 버전이 기록되고, 일부러 넣은 위반이 보고된 회차의 수치만 쓴다 | 회차 기록의 필드와 "회차 무효" 판정 조건(§ 1 의 "회차 기록"), 복사본의 `package_config.json` 에서 기반 세트 버전을 읽는 법, 규칙별 표식의 재실행(§ 1 의 "표식") |
| RULES-06 | 후보 규칙마다 소유자가 채택 여부를 결정했고, 그 결정이 배포 파일에 반영되어 있다 | checkpoint 흐름(§ 5), D-11 (2) 의 `RULES.md` ↔ `lib/base.yaml` 검사(§ 4), 묶음별 커밋(§ 6) |
| RULES-07 | 남기는 규칙의 사유 주석이 사실과 일치한다 | D-18 의 두 문구 수정, 사유 주석 한 줄 ↔ `RULES.md` 의 켠 이유 한 줄을 같은 문장으로 두는 관례(§ 3). 자동 검사는 못 하고 사람 확인 항목이다 — 다만 지워야 할 옛 문구("성능 향상")의 부재는 grep 으로 본다(§ Validation Architecture) |
| RULES-08 | 채택하지 않은 규칙과 그 사유가 목록으로 남아 있다 | `RULES.md` 의 "켜지 않은 규칙" 표(§ 3) — 사유 접두사 7종. 후보 전부 = 켠 규칙 ∪ 켜지 않은 규칙 ∪ v2 로 미룸 이 되는지를 `measure_rules.dart --report` 가 센다 |
| DOCS-11 | 켠 규칙마다 이유와 실측 건수를 적은 근거 문서가 있다 | `RULES.md` 의 "켠 규칙" 표 — 규칙 / 분류 / 켠 이유 / 실측 (`lib` · `test` · `bin`) / `dart fix` / 회차 id (§ 3) |
</phase_requirements>

## Summary

이 phase 의 기술적 위험은 거의 다 spike 020 ~ 023 이 2026-10-12 에 실행으로 걷어 냈다 — `rules.json` 을 쓰지 않는 상태 출처, 쌍마다 둘만 켜는 비호환 확인, 언어 버전 3.11 에서 돌지 않는 6개, 무시 주석을 둔 채의 값과 가린 줄, apply 로 세는 `dart fix` 건수. 남은 일은 그 네 스크립트의 조각을 **하나의 커밋되는 도구** `tool/measure_rules.dart` 로 잇고, 결과를 소유자가 묶음으로 승인할 수 있는 모양으로 내고, 결정을 `lib/base.yaml` · `RULES.md` · 정답지 다섯 · CHANGELOG 에 **서로 어긋나지 않게** 옮기는 것이다. 어긋남을 막는 장치는 둘이다 — 정답지(샘플 하나가 정답지 다섯을 바꾼다, D-10)와 `tool/verify.dart` 의 새 단계(기반 세트 겹침 · `RULES.md` 일치 · 묶음과 별칭은 `include:` 만, D-11 · D-12).

이 세션에서 저장소 파일을 다시 읽어 확인한 것 가운데 계획이 꼭 알아야 할 것은 넷이다. (1) FEATURES.md B-1 ~ B-6 표의 규칙은 125개이고, spike 022 의 그룹 119개는 B-6 의 한 칸에 이름이 여럿 적힌 행에서 7개를 빠뜨렸다 — 그 7개는 모두 Dart 3.13.4 에서 stable 이고 비호환 선언이 없어 G1 에 더한다. 후보 표의 행은 125 + `use_primary_constructors` + 지금 켜 둔 6개 + `strict-inference` = **133** 이고 그중 12개가 "v2 로 미룸" 이라 이 phase 가 결정하는 것은 121개다. (2) 겹치는 6개는 pub cache 의 `lints` 6.1.0 · `flutter_lints` 6.0.0 YAML 에 실제로 있고(`sized_box_for_whitespace` · `sort_child_properties_last` · `use_build_context_synchronously` · `avoid_print` 는 `flutter.yaml`, `slash_for_doc_comments` · `control_flow_in_finally` 는 `recommended.yaml`), 이 패키지만의 6개는 셋 어디에도 없다. (3) `fixtures/overrides` 가 `prefer_final_locals: false` 로 끄기를 시연하므로, 소유자가 그 규칙을 빼면 fixture 와 `verify.dart` 의 `optionsLines` 를 함께 바꿔야 한다. (4) warning 등급 진단(`strict-inference` 의 `inference_failure_on_*`)을 채택하면 `fixtures/base_codegen` 의 정답지 첫 줄이 `exit 0` 에서 `exit 2` 로 바뀐다 — 결정과 대응하는 정상 변화이지만 미리 알고 봐야 한다.

**Primary recommendation:** 계획을 다섯 묶음(wave)으로 나눈다 — ① 도구와 검사 만들기 + 겹침 · 주석 삭제 커밋(정답지 불변 확인), ② 실측 한 번(로컬, 약 35분), ③ 소유자 결정 checkpoint(묶음 6 + 개별 질문), ④ 결정 묶음별 커밋(규칙 + 사유 주석 + 샘플 6벌 + 정답지 5 + `RULES.md` + CHANGELOG 행) 과 `unnecessary_ignore` 재측정 checkpoint, ⑤ 마무리 문서(`RULES.md` 실측 기록, ROADMAP D-23, `03-REVIEW-DISPOSITION.md`, `example/README.md` M20 ~) 와 첫 push 확인. 비공개 정보 점검(§ 8)은 ②부터 모든 커밋 전에 돌린다.

## Architectural Responsibility Map

이 저장소에는 실행 코드가 없으므로 "tier" 는 phase 의 산출물이 사는 자리로 읽는다.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 사용 프로젝트 복사 · `path:` 물리기 · 받은 자리 확인 · 저장소 지문 | `tool/measure_rules.dart` (저장소 밖 작업 폴더에서 실행) | — | spike 021 `consumer.dart` 의 `Consumer` · `Repo` 를 잇는다. 원본은 읽기만, 복사본은 작업 폴더, 저장소는 지문으로 지킨다 |
| 규칙 상태(deprecated / removed / 없음 · stable / experimental / testing) · 상류 세트 · 비호환 쌍 | `tool/measure_rules.dart` (`state` 단계) | SDK tag 3.13.4 의 `messages.yaml` (네트워크) · pub cache 의 `lints` YAML | spike 020 의 `analyzeAll` · `readMessagesYaml` · `readUpstreamSets`. 분석은 저장소 밖에 만든 하한 `^3.13.0` 패키지에서 |
| 그룹 분석 · 표식 · 무시 주석 걷어내기 · apply 고리 | `tool/measure_rules.dart` (`groups` · `apply` · `ignore` 단계) | 복사본의 `lib/woody_probe_marker/` | spike 022 · 023 의 고리. 줄 단위 원문은 `<작업 폴더>/private/` 에만 |
| 건수만 담은 회차 기록 → 저장소 | `tool/measurements/<날짜>-<id>.json` (커밋) | `RULES.md` § 실측 기록 (`--report` 로 생성) | D-07 의 범위만 담는다. 지문 비교가 끝난 **뒤** 저장소로 복사한다 |
| 소유자 결정 | checkpoint (사람) | 터미널 요약 (`measure_rules.dart --summary <묶음>`) | D-04 ~ D-06. 도구는 권고를 계산하고 사람이 승인한다 |
| 결정의 반영 | `lib/base.yaml` | `RULES.md` 켠 · 켜지 않은 표, 샘플 6벌, 정답지 5, `CHANGELOG.md` | 묶음별 커밋 (D-20) |
| 어긋남 방지 | `tool/verify.dart` 새 단계 `[3/10]` | 정답지 비교 `[5/10]` ~ `[10/10]` | D-11 (1) · (2), D-12 WR-01. CI 에서 돈다 |
| 비공개 정보 차단 | 도구의 출력 구조 (`Shot.toJson` 에 경로 · 메시지 없음) | 커밋 전 grep (§ 8) | 구조가 먼저, grep 은 보조 (real-consumer-measurement.md 6번) |

## Standard Stack

이 phase 는 **외부 패키지를 하나도 새로 설치하지 않는다.** 도구는 `dart:io` · `dart:convert` 만 쓴다 (02-CONTEXT.md D-11, `.planning/spikes/CONVENTIONS.md` Stack — `[VERIFIED: .planning/spikes/CONVENTIONS.md:9]` "실측 스크립트는 Dart 로 쓴다. `dart:io`, `dart:convert` 만 쓰고 패키지 의존성을 두지 않는다").

### Core

| Library / Tool | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Dart SDK (Flutter 3.47.5 에 번들) | 3.13.4 | `dart analyze --format=json`, `dart fix --apply --code=`, `dart pub get` | 저장소 고정 SDK (`.fvmrc` `"flutter": "3.47.5"`). `[VERIFIED: .fvm/flutter_sdk/bin/dart --version → "Dart SDK version: 3.13.4 (stable)", 2026-10-13]` |
| `dart:io` · `dart:convert` | SDK | 프로세스 실행, 파일 복사, JSON 읽기 · 쓰기, 64비트 FNV-1a 해시(직접 구현) | 검증 명령과 같은 조건이라 조각을 그대로 옮긴다 |
| `lints` · `flutter_lints` (상류 세트) | 6.1.0 · 6.0.0 | 기반 세트 YAML 읽기 (겹침 검사, 상류 세트 칸) | 저장소 루트 `.dart_tool/package_config.json` 이 가리킨다 `[VERIFIED: 루트 package_config.json 의 rootUri → ~/.pub-cache/hosted/pub.dev/lints-6.1.0, flutter_lints-6.0.0, 2026-10-13]` |
| `riverpod_lint` (analyzer plugin) | 3.1.9 | 복사본 분석에서 plugin 진단 (표식 3줄의 대조) | `lib/riverpod.yaml:10` `riverpod_lint: ^3.1.9`. 복사본의 상태 폴더 `.plugin_manager/*/pubspec.lock` 에서 실제 버전을 읽는다 |
| SDK tag 3.13.4 의 `pkg/linter/messages.yaml` | tag 3.13.4 | stable / experimental / testing 상태 | `https://raw.githubusercontent.com/dart-lang/sdk/3.13.4/pkg/linter/messages.yaml` — spike 020 의 `download` 로 받아 `<작업 폴더>/upstream/` 에 둔다. 네트워크 필요 |

### Supporting

| Tool | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `fvm` | 4.3.1 | 고정 SDK 로 실행 (`fvm dart run tool/measure_rules.dart …`) | 저장소 안에서. 작업 폴더에서는 `<저장소>/.fvm/flutter_sdk/bin/dart` 를 직접 부른다 (CONVENTIONS.md:13) |
| `git` | 2.56.0 | 지문(`git status --porcelain`), 묶음별 커밋, 정답지 diff | — |
| `gh` | 2.102.0 | 첫 push 뒤 GitHub `verify` 실행 확인 | D-22 |
| `python3` | 3.9.6 | 커밋 전 비공개 정보 점검의 보조 (§ 8) — 선택 | 3.10 문법(`X \| None`)을 쓰지 않는다 (CONVENTIONS.md:85) |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `messages.yaml` 을 받아 상태 읽기 | spike 020 의 결과 JSON(`.planning/spikes/020-…/results/probe-3.13.4.json`)의 `messages` 필드를 그대로 쓰기 | 네트워크가 없어도 돌지만 D-14 ("최종 숫자는 다시 잰다") 의 정신과 어긋난다. **받기를 1순위로, 받지 못하면 020 의 JSON 을 읽고 회차 기록에 "상태 출처: spike 020 (2026-10-12)" 라고 적는 fallback** 을 둔다 |
| 규칙별 표식을 손으로 쓰기 | `dart fix` 의 반대 적용 등 자동 생성 | 자동 생성 수단이 없다. 표식은 손으로 쓰되 0줄 후보에만 (D-03) |
| `RULES.md` 의 실측 기록 절을 손으로 옮기기 | `measure_rules.dart --report` 가 JSON 에서 생성 | 생성이 옮겨 적기 오류를 없애고 "수치마다 회차 추적" (성공 기준 2) 을 구조로 만든다. **생성을 권한다** |

**Installation:** 없음. `fvm dart pub get` (저장소 루트, 이미 받아져 있다).

## Package Legitimacy Audit

> 이 phase 는 외부 패키지를 설치하지 않는다 — 새 pub 의존성 0개, `plugins:` 변경 0개. 감사 대상이 없어 표를 두지 않는다.

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```text
[소유자] ──인자: --source <원본 경로> --work <저장소 밖 폴더>──▶ tool/measure_rules.dart (fvm dart run, 저장소 루트)
                                                                   │
   ┌───────────────────────────────────────────────────────────────┼──────────────────────────────────────┐
   │ state 단계 (저장소 밖 pkg13 패키지)                            │ 복사본 단계 (<work>/consumer)          │
   │  messages.yaml ─▶ stable/experimental/testing                  │  copy ─▶ pointToRepo ─▶ woodySource==repo? ──X─▶ 회차 무효
   │  하한 ^3.13.0 분석 ─▶ deprecated/removed/undefined             │  addExampleMarkers (정답지 16줄 ⊆ 표식?) ──X─▶ 회차 무효
   │  쌍마다 둘만 켠 분석 ─▶ incompatible_lint                      │  B0 (지금 하한) · B0-313 (^3.13.0 + pub get)
   │  복사본 package_config ─▶ lints-6.1.0 / flutter_lints-6.0.0     │  G1 (+strict-inference) · G2 · G3 · G4(^3.13.0)
   └───────────────────────────────────────────────────────────────┤  0줄 후보에 규칙별 표식 ─▶ G*-marker 재분석 ──X─▶ "돌지 않음"
                                                                   │  stripIgnores ─▶ G*-strip (가린 줄 = strip − keep)
   저장소 지문 (git status · .dart_tool 맨 위 · package_config · lock) │  단독 dry (diag>0) ─▶ 0/비0 ─▶ apply --code=<규칙> ─▶ 재분석
   ── 단계마다 견줌, 다르면 중단 ──────────────────────────────────┤  (사라진 줄, 새 error) · refreshSources 로 되돌림
                                                                   ▼
                              <work>/private/*.txt (줄 전문 · dart fix 화면)     <work>/results/<id>.json (건수 · 조건)
                                                                   │ 지문 최종 비교 뒤에만
                                                                   ▼
                              tool/measurements/<날짜>-<id>.json (커밋)  ──--summary──▶ 터미널 묶음 요약 ──▶ [소유자 결정 checkpoint]
                                                                   │                                              │
                                                                   └──--report──▶ RULES.md § 실측 기록            ▼
                                                      lib/base.yaml ◀── 결정 묶음별 커밋 ──▶ RULES.md 켠/켜지 않은 표 · 샘플 6벌 · 정답지 5 · CHANGELOG
                                                                   │
                                                                   ▼
                              tool/verify.dart [3/10] (겹침 · RULES.md 일치 · include-only) + [5/10]~[10/10] 정답지 ──▶ CI
```

### Recommended Project Structure (이 phase 가 더하거나 고치는 파일)

```text
tool/
├── verify.dart                    # [3/N] 새 단계 (D-11, D-12), declaredRuleNames 로 리팩터
├── measure_rules.dart             # D-09 — 새 파일. dart:io · dart:convert 만
└── measurements/                  # 건수만 담은 회차 기록 (커밋). 예: 2026-10-14-R1.json
RULES.md                           # D-08 — 새 파일 (절 셋 + 마커 구역)
lib/base.yaml                      # 겹침 6 · 주석 3 삭제 → 결정 묶음별 추가
example/lib/
├── added_rules.dart               # 그대로 (줄 번호 보존)
├── base_rules.dart                # 머리 주석 문구만 고침 ("배포 파일에 적혀 있지만" → "기반 세트가 켜는")
└── <묶음>_rules.dart              # 결정 묶음마다 새 파일 (예: bug_prevention_rules.dart)
fixtures/{base_only,base_riverpod,base_codegen,overrides,recommended}/lib/   # example/lib 와 글자 그대로 같게
example/expected_diagnostics.txt, fixtures/*/expected_diagnostics.txt         # --update 로 다섯을 한 번에
example/README.md                  # 단계 10개 · M20 ~ 기록
CHANGELOG.md                       # 2.0.0 항목의 세 칸
.planning/ROADMAP.md               # D-23
.planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md                     # WR-01 fixed, WR-02 → Phase 5
```

### 1. `tool/measure_rules.dart` 의 설계 (planner 질문 1)

#### 인자

```text
fvm dart run tool/measure_rules.dart --source <원본 경로> --work <저장소 밖 작업 폴더>
    [--stage state|baseline|groups|markers|ignore|fix|unnecessary-ignore|all]   (기본 all — unnecessary-ignore 는 뺀다)
    [--rules a,b,c]        단계를 일부 규칙으로 좁힌다 (apply 재시도용)
    [--out <저장소 안 JSON 경로>]   기본 tool/measurements/<YYYY-MM-DD>-<run id>.json
    [--summary <묶음 이름>]  결과 JSON 에서 D-06 의 터미널 요약만 찍고 끝낸다 (분석하지 않는다)
    [--report]             결과 JSON 에서 RULES.md § 실측 기록 의 Markdown 을 stdout 으로 (분석하지 않는다)
```

- `--source` · `--work` 는 필수이고 스크립트에 기본값을 적지 않는다 (D-09, CONVENTIONS.md:35). `--work` 가 저장소 루트 아래면 종료 코드 64 로 거부한다 — 지문의 `git status` 가 작업 폴더 때문에 깨진다 (spike 022 의 교훈).
- 단계를 인자로 고르고 결과 JSON 은 덮어쓰지 않고 합친다 (`[CITED: .planning/spikes/CONVENTIONS.md:50]` "오래 걸리는 실험은 부(part)나 경우 id 로 나눠 인자로 골라 돌릴 수 있게 하고, 결과 JSON 은 덮어쓰지 않고 합쳐 쓴다"). 그래야 apply 단계가 중간에 죽어도 그룹 분석을 다시 돌리지 않는다.
- 종료 코드는 sysexits 관례 (CONVENTIONS.md:47): 64 사용법, 69 하위 명령(`pub get` · `dart analyze`) 실패, 70 프로세스, 1 판정(저장소 지문 · 회차 무효) 실패.
- 저장소 루트는 `File.fromUri(Platform.script).parent.parent.path` 로 잡는다 (`[VERIFIED: tool/verify.dart:1436]` "final repoRoot = File.fromUri(Platform.script).parent.parent.path;"). spike 의 `Repo.fromSpikeDir` (세 단계 위)는 `tool/` 에서 맞지 않는다.

#### 이어 받는 코드와 출처

| 조각 | 출처 (읽기용 사본) | 고칠 것 |
|---|---|---|
| `Repo` (`fingerprint`), `Diag` (`area` 가 `marker` / `generated` / `lib` / `test` / `bin`), `Shot` (`toJson` 에 경로 · 메시지 없음), `Consumer` (`copy` · `refreshSources` · `useSdk` · `languageVersion` · `pointToRepo` · `woodySource` · `ensureRepoSource` · `optionsWith(rules:, language:)` · `pubspecWithSdk` · `addExampleMarkers` · `addMarkers` · `removeMarkers` · `analyze` · `scrubText`), `replaceOnce`, `digest`, `expectedLines` | `.claude/skills/spike-findings-woody-lints/sources/021-new-rules-language-gate/consumer.dart` 1 ~ 358행 (이 세션에서 전문을 읽었다) | `Repo.fromSpikeDir` → 위의 저장소 루트 셈법. `Consumer.copy` 가 옛 주소 include 를 요구하는 것(151 ~ 153행)과 `pubspecWithSdk` 가 `\n  sdk: ^3.11.1\n` 을 요구하는 것(257행)은 그대로 둔다 — 사용 프로젝트가 바뀌면 멈추는 것이 맞다. `analyze` 는 `ensureRepoSource` 를 스스로 부르지 않는다 — 부르는 쪽이 매번 부른다 (SKILL.md 의 함정 메모) |
| `groups` (G1 ~ G4), `dryRun` 의 출력 읽기 정규식 `^  (\S+) - (\d+) fix(?:es)?$`, apply 고리 (`refreshSources` → 표식 → `useSdk` → 그룹 옵션 → `--apply --code=` → 재분석 → 남은 줄과 증감) | `sources/022-dart-fix-dry-run-count/probe.dart` 24 ~ 76행, 185 ~ 200행 | G1 에 빠진 7개를 더한다 (§ 2). `applyRules` 의 `take(maxApply + 1)` 을 버리고 범위를 "단독 dry > 0" 전부로 (아래) |
| 단계마다 지문을 견주는 `step` | `sources/022-dart-fix-dry-run-count/repo_guard.dart` 21 ~ 27행 | 단계 경계마다 부른다. 다르면 그 자리에서 종료 코드 1 — 021 ~ 023 처럼 끝에서만 보면 15분을 헛돈다 (rule-evaluation-table.md 9번) |
| `ignorePattern`, `analyzedDartFiles`, `countIgnores`, `stripIgnores`, `unnecessaryIgnoreNames` | `sources/023-existing-ignore-comments/probe.dart` 26행, 264 ~ 333행 | `stripIgnores` 는 생성 파일을 건드리지 않고 줄은 남겨 줄 번호를 지킨다 — 그대로 |
| `readMessagesYaml` · `MessagesRule.latest` · `snake` · `compareVersion`, `readUpstreamSets` · `UpstreamSets.of`, `download`, `analyzeAll` (규칙만 적은 패키지를 하한별로 만들어 분석, 진단 줄 번호 − 3 = 규칙 index), 쌍마다 둘만 켠 분석 | `sources/020-rule-state-vs-rules-json/probe.dart` 329 ~ 470행, `analyzeAll` | `readUpstreamSets` 가 읽는 `package_config.json` 을 **저장소 루트와 복사본 둘 다**로 넓힌다 (아래). `rootUri` 가 `file:` 이 아니면 `.dart_tool/` 기준 상대 경로로 푼다 (`consumer.dart:223-225` 의 `woodySource` 가 같은 처리를 한다) |
| `normalizeDiagnostics` 의 심볼릭 링크 처리(준 경로와 푼 경로 둘 다를 base 로) | `tool/verify.dart:402-438` | `Consumer.analyze` 는 `dir` 하나만 떼어낸다(314행). 작업 폴더가 `/private/tmp` 처럼 링크를 거치면 경로가 안 떼어져 `area` 가 전부 "그 밖" 이 된다 — base 둘로 넓힌다 |

#### 그룹 나누기 (Claude 재량 — 권고)

022 의 G1 ~ G4 를 그대로 쓰되 G1 에 7개를 더한다. 비호환 선언(`[VERIFIED: .planning/spikes/020-rule-state-vs-rules-json/results/probe-3.13.4.json 의 rules[].jsonIncompatible 을 이 세션에서 스크립트로 읽음]`)으로 다시 확인한 결과 G2 안의 넷(`always_specify_types`, `prefer_relative_imports`, `specify_nonobvious_local_variable_types`, `type_annotate_public_apis`)은 서로 비호환이 아니고, 더하는 7개는 비호환 선언이 없다.

| 그룹 | 규칙 | 하한 | 기준선 | 비고 |
|---|---|---|---|---|
| G1 | 022 의 106개 + `avoid_field_initializers_in_const_classes`, `cascade_invocations`, `package_prefixed_library_names`, `prefer_asserts_with_message`, `prefer_expression_function_bodies`, `prefer_mixin`, `use_to_and_as_if_applicable` = 113개. 같은 실행에 `analyzer: language: strict-inference: true` | `^3.11.1` (지금) | B0 | `strict-inference` 는 `optionsWith(language: {'strict-inference': true})` |
| G2 | `always_specify_types`, `prefer_relative_imports`, `specify_nonobvious_local_variable_types`, `type_annotate_public_apis` | 지금 | B0 | G1 의 짝(`omit_*`, `avoid_types_on_closure_parameters`, `always_use_package_imports`, `omit_obvious_property_types`)과 갈라 둔다 |
| G3 | `prefer_double_quotes`, `unnecessary_final` | 지금 | B0 | `base.yaml` 의 `prefer_single_quotes` · `prefer_final_locals` 와 비호환 — 사용 프로젝트 옵션 파일에서 켜면 `incompatible_lint` warning 이 옵션 파일 줄에 붙는다 (020). 그 줄은 `area` 가 파일 이름이라 프로젝트 줄에서 빼고 "함께 쓸 수 없는 규칙" 칸의 근거로 적는다 |
| G4 | `empty_container_bodies`, `unnecessary_type_name_in_constructor`, `unnecessary_const_in_enum_constructor`, `use_primary_constructors`, `initialize_in_field_declaration`, `use_declaring_parameters`, `unnecessary_primary_constructor_body` | `^3.13.0` (`useSdk` → `pub get` 포함) | **B0-313** (하한을 올린 기준선 — `prefer_initializing_formals` 27줄이 여기 들어간다) | 지금 하한의 값은 G1 실행에 같은 7개를 함께 켜 0 을 기록한다 (값 둘, D-15). 끝나면 `useSdk(null)` 로 되돌린다 |

규칙의 값 = 그룹 실행의 그 규칙 프로젝트 줄 − 기준선의 그 규칙 프로젝트 줄 (자리별). 지금 하한에서는 lint 후보의 기준선이 0 이라 그대로지만 셈은 늘 한다.

#### 표식 (D-03)

- 회차마다 `addExampleMarkers()` — `example/lib` 전체를 `lib/woody_probe_marker/` 로. 겹침 6개를 지운 뒤에도 `example/` 정답지는 16줄 그대로이므로 "정답지 16줄 ⊆ 표식 줄" 대조는 그대로 쓴다 (경로의 `lib/` 를 `lib/woody_probe_marker/` 로 바꿔 견준다 — real-consumer-measurement.md 3번). 결정 묶음을 반영한 뒤에는 정답지가 늘어나므로 **그 시점의 정답지 파일**을 읽어 견준다 (`expectedLines`).
- 그룹 분석 뒤 프로젝트 줄이 0 인 후보를 모아, 규칙별 표식을 `lib/woody_probe_marker/rule_probe/<규칙>.dart` 로 넣고 **그룹마다 한 번** 더 분석한다 (`G1-marker` 등). 규칙마다 재분석하지 않는다 — 표식 줄은 `area == 'marker'` 로 따로 세므로 한 실행에 여럿을 넣어도 가를 수 있다. 판정: 그 규칙의 코드가 `rule_probe/<규칙>.dart` 줄에 1건 이상 → "진짜 0". 아니면 → "규칙이 돌지 않음(표식 미검출)" 으로 적고 결정하지 않는다.
- 표식 문법: G1 ~ G3 는 언어 버전 3.11 로 컴파일되는 코드만 (`// @dart=3.11` 파일에서는 3.13 전용 규칙이 돌지 않는다 — rule-evaluation-table.md 6번). G4 의 셋(`initialize_in_field_declaration`, `use_declaring_parameters`, `unnecessary_primary_constructor_body`)만 3.13 문법 (021 의 `newSyntaxSamples`). 출발점: 021 의 `oldSamples` (`empty_container_bodies`, `no_dynamic_casts` 등), 023 의 `markers` (`discarded_futures`, `lines_longer_than_80_chars`, `cast_nullable_to_non_nullable`, `unnecessary_ignore`), `example/lib/added_rules.dart` (지금 켜 둔 6개).
- 표식의 수는 결과에 달렸다 — 022 에서는 119개 중 62개가 프로젝트 줄 0 이었다 (`[VERIFIED: 022 결과 JSON rows[].diagProject == 0 인 행 62개, 이 세션에서 셈]`). **약 60개의 표식을 써야 한다고 보고 시간을 잡는다** `[ASSUMED]` — 규칙마다 3 ~ 8줄이면 소스 500줄 안팎. 채택되는 규칙의 표식은 D-10 샘플로 옮겨 쓴다 (같은 코드를 `example/lib/<묶음>_rules.dart` 에).
- 표식이 다른 규칙도 건드릴 수 있다 (예: 긴 줄 표식이 `prefer_single_quotes` 도 어김). 표식 줄은 자리로 가르므로 프로젝트 값에는 섞이지 않는다. 다만 D-10 으로 옮길 때는 "한 줄에 규칙 하나" 를 지킨다 (`example/lib/added_rules.dart:4` 의 관례).

#### `dart fix` 건수 (D-02 의 두 칸)

- `dart fix --code` 는 쉼표로 나눈 코드 하나 이상을 받는다 `[VERIFIED: 고정 SDK 의 dart fix --help → "--code=<code1,code2,...>    Apply fixes for one (or more) diagnostic codes.", 2026-10-13]` `[CITED: dart.dev/tools/dart-fix via Context7 /dart-lang/site-www — "dart fix --apply --code=prefer_single_quotes,use_super_parameters"]`. 규칙 하나씩 준다.
- 범위(Claude 재량 — 권고): 프로젝트 줄 > 0 인 규칙 전부에 단독 dry 를 돌려(약 7초) 0 / 비0 만 가르고, **비0 인 규칙 전부**를 apply 한다. 022 에서는 비0 이 36개였다 `[VERIFIED: 022 결과 JSON rows[].alone > 0 인 행 36개]` — `always_put_required_named_parameters_first`, `always_specify_types`, `always_use_package_imports`, `avoid_annotating_with_dynamic`, `avoid_bool_literals_in_conditional_expressions`, `avoid_escaping_inner_quotes`, `avoid_redundant_argument_values`, `avoid_types_on_closure_parameters`, `cast_nullable_to_non_nullable`, `comment_references`, `diagnostic_describe_all_properties`, `directives_ordering`, `empty_container_bodies`, `migrate_design_widgets`, `omit_local_variable_types`, `omit_obvious_local_variable_types`, `omit_obvious_property_types`, `prefer_const_declarations`, `prefer_double_quotes`, `prefer_if_elements_to_conditional_expressions`, `prefer_int_literals`, `prefer_relative_imports`, `specify_nonobvious_local_variable_types`, `specify_nonobvious_property_types`, `unnecessary_const_in_enum_constructor`, `unnecessary_final`, `unnecessary_ignore`, `unnecessary_lambdas`, `unnecessary_null_checks`, `unnecessary_parenthesis`, `unnecessary_raw_strings`, `unnecessary_type_name_in_constructor`, `unnecessary_unawaited`, `use_decorated_box`, `use_primary_constructors`, `use_raw_strings`. 이름은 출발점이고 2026-10-13 의 복사본에서는 달라질 수 있다 (D-14).
- 단독 dry 가 0 인데 진단이 있는 규칙(022 에서 22개 — `always_put_control_body_on_new_line`, `async_return_with_no_await`, `discarded_futures`, `lines_longer_than_80_chars`, `sort_pub_dependencies` 등)은 apply 하지 않고 `dart fix` 칸을 `0 (단독 dry 0)` 으로 적는다. 프로젝트 줄 0 인 규칙은 `해당 없음` (D-02).
- apply 한 회: `refreshSources` → 표식 다시 → `useSdk(그룹 하한)` → `setOptions(그룹 전체)` → `dart fix --apply --code=<규칙>` (화면 원문은 `<work>/private/fix-<규칙>.txt`) → `analyze('apply-<규칙>')` → `ensureRepoSource` → 사라진 줄 = 그룹 실행의 그 규칙 줄 − 남은 줄, 새 error = after 의 error 코드별 수 − before (그 규칙 자신은 뺀다). G3 · G2 처럼 반대 규칙이 생기는 경우는 "고친 뒤 새로 생긴 error" 가 아니라 info 증감이라 따로 `otherDelta` 에 적는다 (rule-evaluation-table.md 8번의 표 모양).
- plugin: `dart fix` 는 plugin 을 준비하지 않아 `riverpod_lint` 진단을 고치지 않는다 (022). apply 뒤 재분석은 plugin 을 준비하므로 표식 3줄이 그대로인지로 간접 확인한다.

#### 무시 주석이 가린 줄 (`stripIgnores`)

그룹마다 `refreshSources` → 표식 → `stripIgnores()` → 같은 옵션으로 분석(`G*-strip`). 가린 줄 = strip 실행의 그 규칙 줄 − 주석을 둔 실행의 줄. 기준선 쪽도 한 번 걷어낸다(`B0-strip` — 023 의 I1, 기반 세트 26줄의 기록용). 걷어낸 소스는 다음 단계 전에 `refreshSources` 로 되돌린다 (023 의 회차 순서).

#### 복사본의 기반 세트 버전 (spike 에 없는 코드)

```dart
// 복사본의 .dart_tool/package_config.json 에서 lints · flutter_lints 의 rootUri 를 읽는다.
// rootUri 는 'file:///…/lints-6.1.0' 꼴 (절대) 이거나 '../…' 꼴 (상대) 일 수 있다 — 상대면 .dart_tool/ 기준으로 푼다.
Map<String, String> baseSetVersions(String packageDir) {
  final config = jsonDecode(File('$packageDir/.dart_tool/package_config.json').readAsStringSync())
      as Map<String, dynamic>;
  final out = <String, String>{};
  for (final p in (config['packages'] as List).cast<Map<String, dynamic>>()) {
    final name = p['name'] as String;
    if (name != 'lints' && name != 'flutter_lints') continue;
    final uri = Uri.parse(p['rootUri'] as String);
    final dir = uri.hasScheme ? Directory.fromUri(uri) : Directory('$packageDir/.dart_tool/${uri.path}');
    // 폴더 이름이 '<패키지>-<버전>' 이다 (pub cache 의 hosted 패키지) — 020 의 UpstreamSets.sources 와 같은 셈법.
    out[name] = dir.absolute.path.split('/').where((s) => s.isNotEmpty).last;
  }
  return out;
}
```

같은 함수를 저장소 루트에도 적용해 둘을 함께 기록한다 (상류 세트 칸은 "저장소 루트가 받은" YAML 로 — D-02; 복사본의 값은 회차 조건). 2026-10-13 의 저장소 루트는 `lints-6.1.0` · `flutter_lints-6.0.0` 이다 `[VERIFIED: 루트 .dart_tool/package_config.json]`.

#### 회차 기록 (RULES-05 · 성공 기준 2)

분석 한 번(`Shot`)마다 결과 JSON 의 `runs[]` 에 넣는 것:

| 필드 | 값 | 출처 |
|---|---|---|
| `id` | `B0`, `B0-313`, `G1`, `G1-marker`, `G1-strip`, `apply-<규칙>`, `UI` (unnecessary_ignore 재측정) | — |
| `date`, `dart`, `flutter` | ISO 날짜, `Platform.version` 의 첫 토큰, `.fvm/flutter_sdk/bin/cache/flutter.version.json` 의 `flutterVersion` | `tool/verify.dart:464-489` (`readFlutterVersion`) 을 옮긴다 |
| `baseSet` | 복사본 · 저장소 루트의 `lints-x` / `flutter_lints-y` | 위 함수 |
| `plugin` | `riverpod_lint` 버전 (상태 폴더의 `.plugin_manager/*/pubspec.lock`), `pluginFolders`, `pluginHeader` | `Shot` 그대로 |
| `languageVersion`, `sdkConstraint` | 복사본 `package_config.json` 의 자기 패키지 `languageVersion`, `pubspec.yaml` 의 `sdk:` | `Consumer.languageVersion` |
| `dartFiles` | `lib` · `test` · `bin` 의 `.dart` 수 (생성 파일 수 따로) | `Consumer.copy` 의 `copiedFiles` 를 확장 |
| `ignoresStripped` | `stripIgnores()` 가 지운 줄 수 (0 이면 둔 채) | — |
| `woodySource`, `expectedCovered`, `markersReported` | `repo` 인지 · 그 시점 정답지 줄이 표식 줄에 다 있는지 · (marker 실행) 규칙별 표식 검출 여부 | — |
| `valid` | 위 셋이 모두 성립하고 plugin 폴더 1 · 머리말 없음 | 판정 |

평가표의 행마다 `runs` 를 적는다 (예: `G1`, `G1-marker`, `apply-x`). `valid == false` 인 회차의 수치는 행에 넣지 않고 "회차 무효" 라고 남긴다 — 스크립트는 멈추지 않고 그 회차만 버린다 (021 ~ 023 은 전체가 멈췄다, rule-evaluation-table.md 9번).

#### 출력의 자리

| 어디 | 무엇 | 커밋 |
|---|---|---|
| `<work>/consumer/` | 복사본 (원본의 `pubspec.yaml` · lock · 옵션 파일 · `lib` · `test` · `bin` · `assets`), `pubspec_overrides.yaml`, 표식 | 아니오 |
| `<work>/state/<id>/` | 실행마다 빈 상태 폴더 | 아니오 |
| `<work>/private/<id>.txt`, `fix-<규칙>.txt` | 진단 줄 전문(경로 포함), `dart fix` 화면 원문 | **절대 아니오** |
| `<work>/upstream/messages.yaml` | 받은 상류 파일 | 아니오 |
| `<work>/results/<run id>.json` | 건수 · 조건만 (아래 `--out` 과 같은 내용) | 아니오 (작업 사본) |
| `tool/measurements/<YYYY-MM-DD>-<run id>.json` | 같은 JSON. **최종 지문 비교가 끝난 뒤** 저장소로 복사한다 | 예 (권고) |

`--work` 는 Claude 의 scratchpad 가 아니라 **소유자가 다시 찾을 수 있는 자리**(예: `~/dv/woody/_measure/woody_lints/`)를 권한다 `[ASSUMED]` — scratchpad 는 세션이 끝나면 지워지는데, apply 재시도나 `unnecessary_ignore` 재측정이 같은 복사본을 다시 쓴다. 어느 자리든 저장소 밖이고 `.gitignore` 대상이 아닌 곳이면 된다.

**건수만 담은 JSON 을 `RULES.md` 옆에 커밋할지 (Claude 재량) — 권고: 커밋한다, 다만 `RULES.md` 옆이 아니라 `tool/measurements/` 에.** 까닭 셋. (a) `RULES.md` § 실측 기록 을 `--report` 로 생성하면 옮겨 적기 오류가 없고, 표의 수치마다 회차 id 가 자동으로 붙어 성공 기준 2 를 구조로 만족한다. (b) RULES-13 · 다음 SDK 때 다시 재면 두 JSON 의 diff 가 곧 변화 기록이다. (c) 비공개 정보는 구조상 들어가지 않고(§ 8 의 grep 이 보조), 크기는 행 133 × 필드 10 정도로 작다. 루트에 두지 않는 것은 `RULES.md` 가 사람이 읽는 문서이고 JSON 은 도구가 읽는 파일이라서다. `tool/` 아래 JSON 은 루트 분석(`fvm dart analyze`)의 대상이 아니다.

#### 단계별 시간 (추정 — spike 의 실측에서 셈)

| 단계 | 분석 · 명령 수 | 시간 |
|---|---|---|
| `state` — `messages.yaml` 받기, 하한 `^3.13.0` 패키지 분석 1, 쌍마다 둘만 켠 분석 13 | 14 × 0.5초 + 받기 | 약 30초 |
| 복사 · `pub get` · 기준선 B0 · B0-313 (`useSdk` 의 `pub get` 포함) | 분석 2 | 약 1분 |
| 그룹 G1 ~ G4 + marker 재분석 4 + strip 5 | 분석 13 × 약 22초 | 약 5분 |
| 단독 dry (프로젝트 줄 > 0 인 규칙 — 022 는 61번) | 61 × 약 7초 | 약 7분 |
| apply (단독 dry > 0 — 022 는 36개) | 36 × 약 30초 | 약 18분 |
| `unnecessary-ignore` (결정 반영 뒤, 따로) | 분석 1 | 약 30초 |
| **합계 (한 번에)** | | **약 32분** `[ASSUMED — 022 의 "규칙 하나 약 30초", 분석 약 20 ~ 25초(real-consumer-measurement.md 5번 · rule-evaluation-table.md 8번)에서 셈]` |

실행 중에는 저장소 안에 파일을 만들지 않는다 (CONVENTIONS.md:69). 계획의 다른 task 를 그 시간에 저장소에서 진행하지 않는다 — 백그라운드로 돌리고 다음 작업은 scratchpad 에서만.

### 2. 후보 목록의 출처와 재현 (planner 질문 2)

FEATURES.md § B 의 표를 이 세션에서 스크립트로 세었다 — 표 행(`| \`` 로 시작하는 줄)의 **첫 칸에 적힌 backtick 이름 전부**를 모은다. B-6 에는 한 칸에 이름이 여럿인 행이 셋 있다 (FEATURES.md 245 · 246 · 253행).

| 절 | 행 수 (고유 이름) | 비고 |
|---|---|---|
| B-1 버그 방지 | 29 | `always_use_package_imports` × `prefer_relative_imports` 쌍 포함 |
| B-2 성능 | 8 | |
| B-3 가독성·스타일 | 42 | `unnecessary_ignore` (messages.yaml experimental) 포함 |
| B-4 Dart 3.13 신규 | 9 | `no_dynamic_casts` · `no_raw_types` (strict 둘), `migrate_design_widgets` (testing), 언어 버전 3.13 전용 5개 + `unnecessary_primary_constructor_body` |
| B-5 API 문서 | 4 | 전부 v2 (RULES-09) — 숫자만 |
| B-6 제외 권장 | 33 | `require_trailing_commas` (RULES-02) 포함. 022 가 7개를 빠뜨렸다 |
| **B-1 ~ B-6 합** | **125** | `[VERIFIED: .planning/research/FEATURES.md 94 ~ 254행을 읽고 스크립트로 셈, 2026-10-13]` |
| + `use_primary_constructors` | 1 | B-7 (273행 "켜지 않는다") 에만 있지만 D-01 의 "언어 버전 3.13 전용 6개" 에 들어 있다 → RULES-10 으로 숫자만 |
| + 지금 켜 둔 이 패키지만의 6개 | 6 | `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `always_declare_return_types`, `prefer_final_locals`, `prefer_single_quotes`, `unawaited_futures` — `lib/base.yaml` 23 · 24 · 28 · 30 · 32 · 38행 |
| + `strict-inference` | 1 | analyzer 옵션 (D-19) |
| **평가표 행** | **133** | |
| − v2 로 미룸 (숫자만, 결정 안 함) | 12 | B-5 의 4 (RULES-09) + primary constructor 7 (`empty_container_bodies`, `unnecessary_type_name_in_constructor`, `unnecessary_const_in_enum_constructor`, `use_primary_constructors`, `initialize_in_field_declaration`, `use_declaring_parameters`, `unnecessary_primary_constructor_body` — RULES-10) + `migrate_design_widgets` (RULES-11) |
| **이 phase 가 결정하는 것** | **121** | D-01 의 "약 120개" 와 맞는다 |

- 125개 모두 spike 020 의 이름 275개 안에 있고, 하한 `^3.13.0` 분석에서 deprecated / removed / undefined 가 하나도 없으며, `messages.yaml` 상태가 stable 이 아닌 것은 `unnecessary_ignore` (experimental) 와 `migrate_design_widgets` (testing) 둘뿐이다 `[VERIFIED: 020 결과 JSON 의 rules[].messages · actualState13 을 125개에 대해 읽음]`. 기반 세트(102개)와 겹치는 것도, 지금 켜 둔 6개와 겹치는 것도 없다.
- **022 의 그룹에 없는 7개:** `avoid_field_initializers_in_const_classes`, `cascade_invocations`, `package_prefixed_library_names`, `prefer_asserts_with_message`, `prefer_expression_function_bodies`, `prefer_mixin`, `use_to_and_as_if_applicable` — 모두 B-6 이고 stable 이며 비호환 선언이 없다 → **G1 에 더한다.** 022 의 "후보 119개" (rule-evaluation-table.md Constraints "FEATURES.md 의 후보 표에서 셈했다 … 다르면 G1 ~ G4 의 나눔도 다시 한다") 가 예고한 자리다.
- **B-7 (재지 않고 상태만 적는다):** deprecated 6 (`avoid_null_checks_in_equality_operators`, `avoid_private_typedef_functions`, `one_member_abstracts`, `prefer_final_parameters`, `unnecessary_await_in_return`, `use_if_null_to_convert_nulls_to_bools`), removed 14, Dart 3.13 에 없는 2 (`future_sync_value`, `unnecessary_this_alias`), experimental 9 (`annotate_redeclares`, `avoid_futureor_void`, `implicit_reopen`, `invalid_case_patterns`, `no_default_cases`, `unnecessary_async`, `unsafe_variance`, `use_late_for_private_fields_and_variables`, `var_with_no_type_annotation`). 020 의 상태와 B-7 의 분류가 하나도 어긋나지 않는다 `[VERIFIED: 020 결과 JSON 과 FEATURES.md 258 ~ 273행 대조]`. 이들은 `RULES.md` 의 켜지 않은 규칙 표에 상태만 적는다 (D-01). `use_super_parameters` 는 기반 세트라 후보가 아니다 — D-05 가 "experimental 인데 이미 켜져 있다" 의 예시로만 보인다.
- **"잰다 / 결정하지 않는다" 와 "재지 않는다" 의 구분:** v2 로 미룬 12개는 **잰다** (평가표에 숫자가 실린다, G1 또는 G4) 그러나 켠 / 켜지 않은 결정은 하지 않고 미채택 목록에 "v2 로 미룸 (RULES-NN)" 으로 적는다. B-7 의 31개는 **재지 않는다**.
- 재현: `measure_rules.dart` 는 FEATURES.md 를 런타임에 읽지 않고 **목록을 상수로 박고** 주석에 유도 방법(이 절)을 적는다. 상수의 수(125 + 1 + 6 + 1)를 스크립트 시작 때 단언한다. 아래 한 줄로 B-1 ~ B-6 의 이름 125개를 다시 뽑아 상수와 견줄 수 있다 (계획의 검증 명령으로 쓸 수 있다).

```sh
# FEATURES.md 의 B-1 ~ B-6 표 첫 칸의 규칙 이름 (고유, 정렬) — 125줄이어야 한다
sed -n '/^### B-1\./,/^### B-7\./p' .planning/research/FEATURES.md \
  | grep -E '^\| `' | cut -d'|' -f2 | grep -o -E '`[a-z0-9_]+`' | tr -d '`' | sort -u | wc -l
```

### 3. `RULES.md` 의 구조 (planner 질문 3)

세 절 (D-08) 에 **마커 구역**을 더해 `tool/verify.dart` 가 제목 문구가 아니라 마커로 표를 찾게 한다 (Phase 5 의 README 검사도 같은 방식을 이어 쓸 수 있다 — ROADMAP D10 의 "마커 구역과 비교 스크립트").

```markdown
# woody_lints 규칙 근거

(머리 — 이 문서가 무엇이고 어느 실측에서 나왔는지 한 문단. 프로젝트 이름 · 날짜 · Flutter 버전만)

## 켠 규칙

<!-- woody:enabled-rules:start -->
| 규칙 | 분류 | 켠 이유 | 실측 (lib · test · bin) | dart fix | 회차 |
|---|---|---|---|---|---|
| `prefer_final_locals` | 가독성·스타일 | 다시 대입하지 않는 지역 변수를 final 로 | 0 · 0 · 0 (표식 1) | 해당 없음 | R1-G1, R1-G1-marker |
<!-- woody:enabled-rules:end -->

### 켠 analyzer 옵션

<!-- woody:enabled-options:start -->
| 옵션 | 켠 이유 | 실측 | 회차 |
|---|---|---|---|
| `strict-inference` | … | … | … |
<!-- woody:enabled-options:end -->
(채택하지 않으면 이 소절은 "없음" 한 줄)

## 켜지 않은 규칙

<!-- woody:disabled-rules:start -->
| 규칙 | 이유 |
|---|---|
| `avoid_print` | 기반 세트 — `flutter_lints` 6.0.0 `flutter.yaml` 이 켠다 |
| `prefer_double_quotes` | 비호환 — `prefer_single_quotes` 와 함께 쓸 수 없다 |
| `unnecessary_ignore` | 소유자 결정 — … (상태: messages.yaml experimental / rules.json · dart.dev stable) |
| `public_member_api_docs` | v2 로 미룸 (RULES-09) — 실측 N줄 |
| `unnecessary_await_in_return` | deprecated (Dart 3.13) — 재지 않음 |
| `require_trailing_commas` | 규칙이 돌지 않음 — 언어 버전 3.7 이상에서 보고하지 않는다 (표식까지 0줄) |
<!-- woody:disabled-rules:end -->

## 실측 기록

(`tool/measure_rules.dart --report` 가 생성. 회차 표 + 전체 평가표. 손으로 고치지 않는다)
```

- **이유 접두사 7종** (켜지 않은 규칙 표의 첫 단어로 고정): `기반 세트` / `비호환` / `experimental` 또는 `testing` / `v2 로 미룸 (RULES-NN)` / `deprecated` · `removed` · `없음` / `규칙이 돌지 않음` / `소유자 결정`. very_good_analysis README 의 `| Rule | Reason |` 두 칸 형식을 따른 것이다 `[CITED: raw.githubusercontent.com/VeryGoodOpenSource/very_good_analysis/main/README.md — 표 헤더 "| Rule | Reason |", 행 38개, 2026-10-13 받음]`.
- **`verify.dart` 가 읽는 규약 (깨지기 어렵게):** `enabled-rules` 마커 사이의 줄 가운데 `|` 로 시작하는 줄에서 첫 칸의 **backtick 하나로 감싼 `[a-z0-9_]+`** 를 규칙 이름으로 읽는다. 헤더 줄과 `|---|` 줄은 backtick 이 없어 저절로 빠진다. 이름이 둘 이상이거나 없는 행은 형식 오류(종료 코드 70 이 아니라 `[3/N]` 실패 — 사람이 고칠 수 있는 문구로). 비교는 집합이 아니라 **정렬한 목록**으로 — 같은 규칙이 두 번 적히면 잡는다.
- `enabled-options` 는 `lib/base.yaml` 의 `analyzer: language:` 아래 `<이름>: true` 와 견준다. 지금은 그 블록이 없으므로 "없음" 끼리 같아야 통과다.
- 켠 규칙 표의 "켠 이유" 한 줄은 `lib/base.yaml` 의 사유 주석과 **같은 문장**으로 둔다 (RULES-07 을 사람이 확인할 때 한 번만 보면 된다). 자동으로 견주지는 않는다 — 주석에는 `#` 뒤 공백과 괄호가 섞여 글자 비교가 깨지기 쉽다 `[ASSUMED — 깨지기 쉽다는 판단]`.

### 4. `tool/verify.dart` 의 변경 (planner 질문 4)

#### 자리와 번호 (Claude 재량 — 권고)

새 단계 하나 `[3/N]` **"배포 파일의 구성"** 을 `[2/N]` (규칙 이름) 과 지금의 `[3/N]` (연습용 프로젝트 옵션 파일) 사이에 넣는다. N 은 3 + fixture 수 = 9 에서 **4 + 6 = 10** 이 된다. `main` 의 `results` 목록(`tool/verify.dart:1465-1469`)에 한 줄을 더하면 번호는 저절로 밀린다 — 머리 주석 1 ~ 8행, `example/README.md` 의 "단계는 아홉 개", `[4/9]` ~ `[9/9]`, 표의 순서 문장(63행), 종료 코드 표(103행 "단계 9개") 를 함께 고친다.

하나의 단계에 세 확인을 넣는 까닭: 셋 다 "저장소 안의 파일끼리 어긋나지 않는가" 를 보는 것이고 analyzer 를 돌리지 않는다 (`[2/N]` 은 analyzer 가 보는 옵션 경고다). 세 확인은 모두 돌리고 실패를 모아 한 `StepResult` 로 돌려준다 — `checkFixtureOptions` (`tool/verify.dart:1058-1100`) 가 파일별로 `details` 를 모으는 방식 그대로.

| 확인 | 무엇 | 실패 문구에 넣을 것 |
|---|---|---|
| (a) D-12 WR-01 — 묶음과 별칭은 `include:` 만 | `lib/recommended.yaml` 과 `lib/analysis_options.yaml` 의 주석 · 빈 줄을 뺀 `trim()` 줄이 아래 상수와 통째로 같다 | 실제 줄 / 정해진 줄 (M19 의 모양) |
| (b) D-11 (1) — 기반 세트와 겹침 | `lib/base.yaml` 의 선언 규칙 ∩ (core ∪ recommended ∪ flutter) = ∅. 이름은 소문자로 맞춰 견준다 (`prefer_iterable_whereType` 처럼 대문자가 섞인다 — rule-evaluation-table.md 4번) | 겹친 이름과 그 이름이 든 세트 파일 (`flutter_lints 6.0.0 flutter.yaml` 등) |
| (c) D-11 (2) — `RULES.md` 와 일치 | `RULES.md` 의 `enabled-rules` 목록(정렬) == `lib/base.yaml` 선언 규칙(정렬); `enabled-options` == `analyzer.language` 의 `true` 키 | 한쪽에만 있는 이름을 `- ` / `+ ` 로 (정답지 diff 와 같은 기호) |

```dart
/// (a) 규칙을 담으면 안 되는 배포 파일 — include 줄만 있어야 한다 (주석 · 빈 줄 제외, trim 비교).
/// 03-REVIEW.md WR-01 의 제안을 그대로 쓴다.
const includeOnlyFiles = <String, List<String>>{
  'lib/analysis_options.yaml': ['include: package:woody_lints/recommended.yaml'],
  'lib/recommended.yaml': [
    'include:',
    '- package:woody_lints/base.yaml',
    '- package:woody_lints/riverpod.yaml',
    '- package:woody_lints/codegen.yaml',
  ],
};
```

#### 다시 쓰는 함수

| 지금 | 어떻게 |
|---|---|
| `countDeclaredRules(String options)` (`tool/verify.dart:848-863`) — `linter:` 블록 안의 `- 이름` 줄을 **센다** | `List<String> declaredRuleNames(String options)` 로 바꿔 이름 목록을 돌려주고, `countDeclaredRules` 는 `declaredRuleNames(options).length` 로 남긴다. 정규식 `^\s*-\s*([A-Za-z0-9_]+)` 의 그룹을 쓰면 된다 (`readRuleNameAt` 833 ~ 841행이 같은 정규식을 쓴다). (b) 와 (c) 가 이 목록을 쓴다 |
| `checkFixtureOptions` 안의 "주석 · 빈 줄을 뺀 `trimRight` 줄 → `trim` 비교" (1070 ~ 1078행) | `List<String>? significantLines(File)` 로 떼어 (a) 와 함께 쓴다 (03-REVIEW.md WR-01 Fix 의 제안) |
| `sameLines` (1121 ~ 1127행) | (a) 그대로, (c) 는 정렬한 목록에 |
| `checkLibYamlSet` (800 ~ 830행) | 그대로 — `[2/N]` 첫 확인. 새 단계는 이 뒤에 돌므로 `lib/` 의 다섯이 있다고 가정해도 된다 |
| `readRuleNameAt` | 그대로 (새 단계는 쓰지 않는다) |
| `relativize`, `StepResult`, `formatStepLine` | 그대로 |
| 상류 YAML 읽기 | 새로 쓴다 — 020 의 `readUpstreamSets` 를 옮긴다. 루트 `.dart_tool/package_config.json` 은 준비 3 (`runPubGet(repoRoot …)`, 1451행) 뒤라 있다. `rootUri` 가 상대 경로일 때의 처리를 넣는다 (§ 1 의 `baseSetVersions`) `[ASSUMED — 지금 환경에서는 file: 절대 URI 였다]` |
| `RULES.md` 읽기 | 새로 쓴다 — 마커 사이의 `|` 줄에서 첫 칸 backtick 이름 (§ 3). 파일이 없으면 (c) 실패 ("`RULES.md` 가 없다 — D-08") |

#### 통과 / 실패의 뜻을 보이는 기록 (`example/README.md` M20 ~)

Phase 2 · 3 의 선례(M1 ~ M19, `example/README.md` 120 ~ 231행)와 같은 표 형식으로 "추가 실측 — 배포 파일의 구성 (04-NN)" 소절을 더한다. 변경은 한 번에 하나, 바로 되돌리고, 끝에 종료 코드 0 을 본다.

| # | 변경 | 기대 | 항목 |
|---|---|---|---|
| M20 | `lib/base.yaml` 규칙 목록에 `- avoid_print` 를 더함 (기반 세트 `flutter.yaml` 이 켜는 규칙) | `[3/10]` 만 실패 (겹침: `avoid_print` — `flutter_lints` `flutter.yaml`). **`[5/10]` ~ `[10/10]` 은 통과** — 정답지가 겹침을 잡지 못한다는 D-11 의 근거가 이 한 행이다 | RULES-01 · D-11 (1) |
| M21 | `RULES.md` 켠 규칙 표에서 행 하나를 지움 | `[3/10]` 실패 (`- <규칙>` 한 줄), 정답지 단계 통과 | RULES-06 · D-11 (2) |
| M22 | `lib/base.yaml` 에 규칙 하나를 더하고 `RULES.md` 에는 더하지 않음 (샘플 없음) | `[3/10]` 실패 (`+ <규칙>`), 정답지 단계는 그 규칙이 샘플에 걸리지 않으면 통과 | RULES-06 · D-11 (2) |
| M23 | `lib/recommended.yaml` 끝에 `linter:` / `rules:` / `- unnecessary_await_in_return` 세 줄 (03-REVIEW.md WR-01 의 재현 입력) | `[3/10]` 실패 (include 만 담아야 한다). 고치기 전에는 아홉 단계 모두 통과했다 (03-REVIEW.md 120행 — 그 기록을 인용한다) | D-12 WR-01 |
| M24 | `lib/analysis_options.yaml` (별칭) 에 같은 세 줄 | `[3/10]` 실패 | D-12 WR-01 |
| M25 | 새로 켠 규칙 하나의 줄을 `lib/base.yaml` 에서 지움 (D-10 의 M1 재현 — 묶음마다 하나는 돌린다) | `[3/10]` 실패 (`RULES.md` 와 어긋남) **그리고** `[5/10]` ~ `[10/10]` 실패 (`- <샘플 경로>:<줄>  info  <규칙>` 다섯 정답지 모두) | VERIFY-08 · D-10 |

실패 기록이 아닌 **확인 기록** 둘도 같은 소절에 문장으로 남긴다: (i) 겹치는 6개와 주석 3개를 지운 커밋에서 `--update` 가 `바뀐 정답지가 없다 — 쓰지 않았다` 였다 (D-20 — `example/README.md:165` 가 "Phase 4 의 중복 선언 정리 때 확인한다" 로 미뤄 둔 자리). (ii) 결정 묶음마다 `--update` 의 `+` 줄 수가 그 묶음의 샘플 수와 같았다.

#### 함께 고칠 자리

- `example/lib/base_rules.dart:3-4` 머리 주석 "배포 파일에 적혀 있지만 기반 세트(flutter_lints / lints)도 켜는 규칙 6개와" → "기반 세트(`flutter_lints` / `lints`)가 켜는 규칙 7개를" (코드는 바꾸지 않는다 — 줄 번호가 정답지에 묶여 있다). `example/README.md:40` 의 파일 표 문구도.
- `fixtures/overrides/analysis_options.yaml` 과 `tool/verify.dart:90` 의 `prefer_final_locals: false` — 소유자가 `prefer_final_locals` 를 빼면 이 fixture 는 끄는 대상이 사라져 `[3/10]` 이 아니라 **정답지가 바뀐다** (`lib/added_rules.dart:24` 줄이 다른 fixture 에서도 사라지므로 overrides 의 "끈 진단만 사라진다" 대조가 무너진다). 그 경우 끄는 규칙을 남는 규칙 하나로 바꾸고 `optionsLines` · README 55 ~ 61행 · M19 설명을 함께 고친다.
- `03-REVIEW-DISPOSITION.md` 의 WR-01 행을 `fixed` (M23 · M24), WR-02 를 `deferred — Phase 5 첫 일`, WR-03 을 `open — 목록 형식 관례로 회피` 로.

### 5. 소유자 결정 checkpoint 의 흐름 (planner 질문 5)

GSD 설정의 `human_verify_mode` 는 `end-of-phase` 이지만 D-04 의 결정은 **phase 중간의 막는(blocking) checkpoint** 다 — 계획은 실측 wave 와 반영 wave 사이에 사람이 답해야 하는 task 를 명시적으로 둔다 (ROADMAP D13 "이 phase 는 소유자 검토 없이는 끝나지 않는다").

#### 계획의 나눔 (권고)

| Wave | 내용 | 끝나는 조건 |
|---|---|---|
| 1 — 장치 | `tool/measure_rules.dart` (§ 1), `tool/verify.dart` `[3/10]` (a) · (b) (§ 4 — (c) 는 `RULES.md` 가 생기는 wave 4 에서 켠다), `lib/base.yaml` 의 겹침 6 · 주석 3 삭제 커밋 (D-20 첫 커밋), `example/lib/base_rules.dart` 주석, README 단계 수 | `fvm dart analyze` 깨끗, `verify` 10단계 통과, `--update` 가 "바뀐 정답지가 없다", M20 · M23 · M24 기록 |
| 2 — 실측 | `measure_rules.dart --stage all` 한 번 (약 32분, 로컬) → `tool/measurements/<날짜>-R1.json` 커밋 (§ 8 grep 뒤) | 모든 회차 `valid`, 지문 불변, 후보 133 행 모두 값 또는 "표식 미검출" |
| 3 — 결정 | checkpoint: `--summary <묶음>` 으로 묶음 6 + 개별 질문 (아래 순서) | 121개 모두 켬 / 안 켬 / (unnecessary_ignore 는 보류) 기록 |
| 4 — 반영 | 결정 묶음별 커밋 (§ 6) — `lib/base.yaml` + 사유 주석 + `example/lib/<묶음>_rules.dart` 6벌 + `--update` 정답지 5 + `RULES.md` 행 + CHANGELOG 행. 첫 커밋에서 `RULES.md` 와 `[3/10]` (c) 를 함께 켠다. 끝에 `--stage unnecessary-ignore` 재측정 → 둘째 checkpoint (한 질문) → 반영 | 묶음마다 `verify` 통과, `+` 줄 = 샘플 수 |
| 5 — 마무리 | `RULES.md` § 실측 기록 (`--report`), 켜지 않은 규칙 표 완성 (B-7 상태 포함), CHANGELOG `### 새로 생기는 경고` 표와 실측 한 줄, ROADMAP D-23, `03-REVIEW-DISPOSITION.md`, `example/README.md` M25 와 확인 기록, § 8 grep, 첫 push 확인 (D-22) → GitHub `verify` 통과 확인 | 성공 기준 1 ~ 5 |

#### 묶음의 순서와 개별 질문

D-04 가 개별로 묻는 것을 묶음에서 **먼저 빼고** 묶음을 보인다. 묶음은 분류 → 영향이 큰 것부터.

1. **버그 방지** (B-1 29개 − 개별 질문 4개 = 25개). 권고 잣대: 실제 문제를 가리키면 건수 무관 켬.
2. **성능** (B-2 8개).
3. **가독성·스타일** (B-3 42개 − `unnecessary_ignore` = 41개 — 크면 "dart fix 가 다 고치는 것 / 손으로 고칠 줄 50 이하 / 그 밖" 셋으로 나눠 보인다, D-06).
4. **지금 켜 둔 6개** (− `unawaited_futures` = 5개, D-18 의 사유 문구 수정 포함).
5. **제외 권장** (B-6 33개 — 둘로 나눈다: "비호환 · 돌지 않음 · dart fix 가 깨뜨림" 처럼 공통 안 켬 잣대에 걸리는 것 / 취향 규칙).
6. **strict 계열** — 하나씩: `no_dynamic_casts`, `no_raw_types`, `strict-inference` (D-19: warning, 받는 쪽 `dart analyze` 실패, `base_codegen` 정답지의 `exit 0` → `2`).
7. **import 스타일** — 쌍으로 한 번: `always_use_package_imports` 대 `prefer_relative_imports` (둘의 건수를 나란히 — FEATURES.md 128행 "다수 쪽을 택하면 진단이 최소").
8. **fire-and-forget** — `unawaited_futures` (지금 켜 둠) · `discarded_futures` · `unnecessary_unawaited` 를 한 화면에, `unawaited()` / `// ignore` / `@awaitNotRequired` 의 뜻 풀이와 함께.
9. **함께 쓸 수 없는 쌍** — `prefer_double_quotes`, `unnecessary_final` (공통 안 켬이지만 D-04 가 개별로 적었다 — 한 화면에 둘).
10. **v2 로 미룸 12개** — 결정을 묻지 않고 숫자만 보인다 (D-01).
11. **(wave 4 끝) `unnecessary_ignore`** — 재측정 값과 `unnecessaryIgnoreNames` 의 코드별 건수, 상태 출처의 갈림, `use_super_parameters` 의 선례 (D-05).

#### 터미널 요약의 모양 (D-06)

```text
[버그 방지] 25개 — 권고: 켬 N · 안 켬 M        실측 R1 (2026-10-14, Flutter 3.47.5, flutter_starter_kit Dart 파일 K개)

| 규칙                         | 경고 (lib·test·bin) | dart fix | 고친 뒤 error | 권고  | 이유                                  |
|------------------------------|---------------------|----------|---------------|-------|---------------------------------------|
| async_return_with_no_await   |  30 (16·14·0)       | 0 (dry 0)|            0  | 켬    | await 없는 Future 반환은 예외 전파를 바꾼다 |
| no_adjacent_strings_in_list  |   0 (표식 1)        | 해당 없음|            —  | 켬    | 쉼표 누락 — 걸리면 거의 버그           |
| require_trailing_commas      |   0 (표식 미검출)   | 해당 없음|            —  | 결정 안 함 | 언어 3.7+ 에서 돌지 않음 (RULES-02 삭제) |

**권고:** 표의 `권고` 열대로 — 켬 N개, 안 켬 M개.
선택지: (1) 권고대로  (2) 바꿀 규칙을 짚는다 (이름만 적으면 된다)  (3) 이 묶음은 보류
```

- 숫자는 `R1` 의 값만 (D-14). 0줄은 `(표식 1)` 또는 `(표식 미검출)` 을 반드시 붙여 뜻을 가른다 (D-03).
- 용어 풀이 → 찾아본 것 → 표 → 굵은 `권고:` → 선택지 순서 (CONTEXT `<specifics>`).
- 결정의 기록은 `RULES.md` 의 두 표가 원본이고, checkpoint 의 응답 요지는 그 wave 의 SUMMARY 에 적는다 (경로 · 메시지 없이 — D-07).

### 6. D-10 샘플과 D-20 커밋 순서 (planner 질문 6)

#### 어느 파일을 고치나

- `example/lib/added_rules.dart` 는 **건드리지 않는다** — 그 줄 번호(7 · 13 · 18 · 24 · 29 · 33)가 정답지 다섯에 박혀 있다. 소유자가 6개 중 하나를 빼면 그 파일의 함수 하나를 지우는 대신 **그대로 두고** 정답지에서 그 줄이 사라지게 둔다 (코드를 지우면 아래 줄이 당겨져 다른 규칙의 줄이 함께 바뀐다 — 1:1 대응이 깨진다). 사유 설명 주석만 "(2.0.0 에서 뺌 — 기반 세트의 X 가 대신한다)" 식으로 고치면 줄 수가 같은 범위에서만.
- 새 규칙의 샘플은 **결정 묶음마다 새 파일 하나** — `example/lib/bug_prevention_rules.dart`, `performance_rules.dart`, `style_rules.dart`, `strict_rules.dart` (이름은 재량). 그러면 묶음 커밋 하나가 새 파일 하나 + 정답지 다섯의 `+` 줄로 끝나고, 바뀐 줄이 결정과 1:1 로 대응한다 (ROADMAP Notes). 규칙마다 함수 하나, 위에 `/// \`규칙\` — 무엇을 어기는가` 한 줄 (`added_rules.dart` 의 관례), 한 줄에 규칙 하나.
- 다섯 복사본 `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/lib/` 에 **같은 파일을 글자 그대로** 둔다. 지금 다섯이 `example/lib` 와 글자 그대로 같다 `[VERIFIED: diff -rq example/lib fixtures/*/lib → 차이 없음 (overrides 의 suppress/ 만 더 있음), 2026-10-13]`. 복사는 `cp example/lib/<파일> fixtures/*/lib/` 로 하고, 커밋 전에 같은 `diff -rq` 를 돌린다 (03-REVIEW WR-06 — 어느 단계도 이 전제를 지키지 않는다).
- 표식(§ 1)으로 쓴 코드를 그대로 옮기면 두 벌을 따로 쓰지 않아도 된다 (D-03 "채택된 규칙의 표식은 D-10 의 샘플로 옮겨 쓸 수 있다"). 차이: 표식은 0줄 후보에만 있었으므로 **1줄 이상 나온 규칙의 샘플은 새로 쓴다.**

#### 정답지 다섯이 어떻게 바뀌나

| 정답지 | 바뀌는 것 |
|---|---|
| `example/expected_diagnostics.txt` | `+ lib/<묶음>_rules.dart:<줄>  info  <규칙>` 이 규칙마다 1줄 (같은 규칙 샘플이 둘이면 2줄). `exit 2` 그대로 |
| `fixtures/recommended` | 정답지 없음 — 같은 실행의 `example` 과 견주므로 저절로 같다 |
| `fixtures/base_only`, `base_riverpod`, `overrides` | `example` 과 같은 `+` 줄. `exit 2` 그대로 |
| `fixtures/base_codegen` | 같은 `+` 줄. **warning 등급 진단을 채택하면 `exit 0` → `exit 2`** — `strict-inference` 의 `inference_failure_on_*` 가 warning 이다 (`[VERIFIED: rule-evaluation-table.md 6번 표 "`strict-inference` (`inference_failure_on_*`) … 분석 옵션" + FEATURES.md 349행 "warning"]`, 정답지 첫 줄의 뜻은 `example/README.md:92` "warning 이 하나라도 있으면 2"). 결정과 대응하는 정상 변화다 |
| 모두 | 머리 `# 실측:` 줄의 날짜가 그 날로 바뀐다 (`--update` 가 쓴다) |

- 새 규칙이 **기존 샘플 파일**(`added_rules.dart`, `base_rules.dart`, `main.dart`, `riverpod_rules.dart`, `should_not_appear.dart`, `generated/`)에 걸릴 수 있다 — 예: `prefer_const_declarations` 나 `unnecessary_lambdas`. 그 줄은 **같은 규칙의 추가 샘플**이라 결정과의 대응은 유지된다 — 받아들이고 `RULES.md` 켠 규칙 표의 샘플 수에 포함한다. 다른 규칙의 줄이 생기거나 사라지면 샘플을 고친다 (줄 수를 유지하면서).
- 먼저 `--update` 없이 보통 실행으로 `+` / `-` 줄을 보고, 샘플 수와 같은지 센 뒤 `--update` 로 쓴다 (`example/README.md:28-29`).

#### D-20 커밋 순서

1. **커밋 A (wave 1):** `lib/base.yaml` 에서 25 · 29 · 33 · 37 · 39 · 40행(겹침 6)과 15 ~ 16 · 31 · 34행(주석 3), 18행의 템플릿 문장 "Uncomment the following section …" 은 Phase 5 (DOCS-10) 몫이라 그대로 둔다. `example/lib/base_rules.dart` 머리 주석. `verify` 10단계 통과 + `--update` "바뀐 정답지가 없다" 를 커밋 메시지 본문에 적는다. 분류 주석 `# 성능` 아래가 2개, `# 가독성 및 스타일` 3개, `# 버그 방지` 1개로 줄어든다 — 그룹 주석은 남긴다.
2. **커밋 B ~ (wave 4):** 결정 묶음마다 하나 — `lib/base.yaml` 규칙 + 사유 주석 (분류 주석 아래, 목록 형식), `example/lib/<묶음>_rules.dart` + 다섯 복사본, `--update` 정답지 다섯, `RULES.md` 켠 · 켜지 않은 표의 그 묶음 행, `CHANGELOG.md` `### 추가한 규칙` 의 그 묶음 불릿. 첫 번째 B 커밋에 `RULES.md` 파일 생성과 `[3/10]` (c) 켜기를 넣는다 (지금 켜 둔 6개의 묶음을 첫 B 로 두면 자연스럽다 — 뺀 규칙이 있어도 샘플 변화가 `-` 뿐이라 가장 단순하다).
3. **커밋 C:** `unnecessary_ignore` 결정 반영 (켜면 샘플 + 정답지, 아니면 `RULES.md` 행만).
4. **커밋 D (wave 5):** `RULES.md` § 실측 기록, CHANGELOG `### 새로 생기는 경고`, ROADMAP, DISPOSITION, README M 기록.

커밋 메시지: Conventional Commits, prefix 영어 · 제목 한국어 (예: `feat(base): 버그 방지 규칙 N개 켬 — 소유자 결정 2026-10-14`, `chore(base): 기반 세트와 겹치는 선언 6개와 주석 처리된 설정 3개 삭제 — 정답지 불변`). 커밋 전 `fvm dart analyze` (CLAUDE.md).

### 7. `CHANGELOG.md` 2.0.0 문구와 ROADMAP D-23 (planner 질문 7)

`VERSIONING.md` § "CHANGELOG 항목 형식" (77 ~ 127행) 그대로. 지금 2.0.0 항목(`CHANGELOG.md:1-20`)에 `### 올리기 전에`, `### 그 밖의 변경`, `### 새로 생기는 경고` 가 있고 `### 추가한 규칙` · `### 뺀 규칙` 은 없다. 칸 순서는 올리기 전에 → 추가한 규칙 → 뺀 규칙 → 그 밖의 변경 → 새로 생기는 경고 (90행 "칸은 위 순서대로 둔다").

| 칸 | 무엇을 적나 |
|---|---|
| `### 올리기 전에` | warning 등급을 채택했을 때만 한 불릿 더함 — "`strict-inference` 가 warning 진단을 낸다. `dart analyze` 는 warning 에서 실패하므로(`--fatal-warnings` 기본), 올리기 전에 아래 표의 건수를 본다" |
| `### 추가한 규칙` (새로 둔다) | 불릿 `` - `rule_name` — 켠 이유 한 줄 `` — `RULES.md` 켠 규칙 표의 "켠 이유" 와 같은 문장 |
| `### 뺀 규칙` | 지금 켜 둔 6개 중 소유자가 뺀 것이 있을 때만 — `` - `rule_name` — 뺀 이유 한 줄 ``. **겹치는 6개의 삭제는 여기 적지 않는다** — 받는 쪽에서 사라지는 경고가 없다 |
| `### 그 밖의 변경` | 불릿 둘 더함 — "기반 세트와 겹치는 선언 6개(`sized_box_for_whitespace`, `sort_child_properties_last`, `slash_for_doc_comments`, `use_build_context_synchronously`, `avoid_print`, `control_flow_in_finally`)와 주석 처리된 설정 3개를 배포 파일에서 지움. 기반 세트가 여전히 켜므로 사용하는 프로젝트에는 영향 없음 (정답지 다섯 그대로, 2026-10-XX)" / "규칙 근거 문서 `RULES.md` 와 실측 도구 `tool/measure_rules.dart` 를 추가. 검증 명령에 배포 파일의 구성 단계를 더함. 사용하는 프로젝트에는 영향 없음" |
| `### 새로 생기는 경고` | `(Phase 4 실측 후 채움)` 을 `| 규칙 | 강도 | 실측 | dart fix |` 표로. `실측` 은 `lib + test + bin` 의 합 (한 수 — 94 ~ 99행의 뜻 "그 규칙이 낸 경고 건수"; 자리별 수는 `RULES.md`), `dart fix` 는 사라진 줄 (99행 "고쳐지는 건수"), 0줄 규칙은 `0건` · `해당 없음`. 표 아래 `실측: flutter_starter_kit (Dart 파일 N개), Flutter 3.47.5, YYYY-MM-DD` 한 줄 (101행의 꼴). 새로 켠 규칙만 싣는다 — 지금 켜 둔 6개는 "새로 생기는" 경고가 아니다 |

ROADMAP D-23 의 세 군데:

- 183행 `**Spike first** (실측을 돌리기 전에 실행으로 확인한다):` → Phase 3 의 150행 선례대로 `(… — **2026-10-12 완료**: spike 020 ~ 023 이 네 항목에 답했다. 멈춤 조건에 해당한 것 없음. 로드맵 문구 가운데 그대로 쓸 수 없게 된 것은 Notes 에 반영했다. `04-RESEARCH.md` 와 skill \`spike-findings-woody-lints\` 참조)`.
- 195행 Notes "평가표의 열을 고정한다: … `rules.json` 을 기준으로 삼는다." → D-02 의 표 요지 한 문단으로 바꾼다 — "평가표의 칸은 상태(분석 + `messages.yaml`) / 강도(실측 JSON) / 실측 건수(무시 주석을 둔 채, `lib` · `test` · `bin`) / `dart fix` 로 사라진 줄 / 고친 뒤 새 error / 무시 주석이 가린 줄 / 상류 세트 / 함께 쓸 수 없는 규칙 이다. `rules.json` 은 쓰지 않는다 (spike 020 · 022). 칸이 하나라도 비면 그 규칙은 결정하지 않는다 (04-CONTEXT.md D-02)". 196행 "`dart analyze --format=json` … 양립 불가 쌍은 한쪽씩 나눠 돌린다" 와 187행 "`dart fix --dry-run`" 도 좁혀진 문구(쌍마다 둘만 켠다 / apply 로 센다)로 — 선택.
- Phase 5 Notes (218행 아래) 에 불릿 — "**가장 먼저 할 일 (04-CONTEXT.md D-12):** `tool/verify.dart` 의 WR-02 (거짓 실패 — `lib/riverpod.yaml` 의 plugin 줄 끝 주석 · 마지막 줄바꿈 없음에서 `stripPlugins` · `readShippedPluginConstraint` 가 종료 코드 70) 를 YAML 머리 주석(DOCS-10)을 고치기 전에 닫는다 (`03-REVIEW.md` WR-02)".
- 181행 `**Plans**: TBD` 는 planner 가 채운다.

### 8. D-07 의 비공개 정보 점검 (planner 질문 8)

구조가 먼저다 — `Shot.toJson` 은 경로 · 메시지를 담지 않고(consumer.dart 98 ~ 111행), 줄 전문은 `<work>/private/` 에만 쓴다. 아래는 커밋 전에 **반드시** 돌리는 보조 점검이고, 결과가 0 이어야 커밋한다. 대상은 이 phase 가 만들거나 고치는 저장소 파일과 `.planning/phases/04-rule-reselection/` 전부다.

```sh
# (1) 절대 경로 · 홈 · 임시 폴더 — 0줄이어야 한다 (CONVENTIONS.md:58 의 패턴을 넓힘)
git grep -n -E '/Users/[A-Za-z]|/private/tmp[/]|/var/folders[/]|/home/[a-z]+[/]' -- \
  RULES.md CHANGELOG.md tool/measure_rules.dart tool/measurements example/README.md \
  .planning/phases/04-rule-reselection .planning/ROADMAP.md .planning/STATE.md

# (2) 사용 프로젝트의 파일 경로 꼴 — 저장소에 실재하는 경로만 남아야 한다 (CONVENTIONS.md:66 의 패턴)
git grep -h -o -E '(lib|test|bin|assets)/[A-Za-z0-9_./-]+\.(dart|json|arb|yaml)' -- \
  RULES.md CHANGELOG.md tool/measure_rules.dart tool/measurements example/README.md \
  .planning/phases/04-rule-reselection \
  | sort -u | while read -r p; do
      case "$p" in lib/woody_probe_marker/*) continue;; esac       # 표식 폴더는 이 저장소의 샘플 (경로만)
      [ -e "$p" ] || [ -e "example/$p" ] || [ -e "fixtures/base_only/$p" ] || echo "LEAK? $p"
    done

# (3) 진단 메시지 · dart fix 화면 — 결과 JSON 에 메시지 필드가 없어야 한다
grep -c '"message"' tool/measurements/*.json            # 0 이어야 한다
git grep -n -E 'fixes? made in|proposed fixes in' -- RULES.md tool/measurements .planning/phases/04-rule-reselection   # 0줄

# (4) 사용 프로젝트 이름 밖의 식별자 — 원본 폴더의 **상위 폴더 이름**이 섞이지 않았는지 (프로젝트 이름 자체는 허용, D-07)
#     <원본 경로> 는 소유자가 --source 로 준 값. 그 상위 폴더 이름들을 하나씩 grep 한다.
for seg in $(dirname "<원본 경로>" | tr '/' '\n' | grep -v -E '^(Users|woody|dv|home|)$'); do
  git grep -n -F -e "$seg" -- RULES.md tool/measurements .planning/phases/04-rule-reselection && echo "LEAK? $seg"
done
```

- (2) 의 허용 목록: 저장소 루트의 실재 파일(`lib/base.yaml` 등), `example/` · `fixtures/` 의 샘플(`lib/added_rules.dart` 등), 표식 폴더 `lib/woody_probe_marker/` (이 저장소의 샘플을 복사한 것 — 경로만 적힌다), 새 샘플 파일 `lib/<묶음>_rules.dart`, 그리고 글자 그대로 허용할 셋 — `lib/a.dart` (`state` 단계가 저장소 밖에 만드는 연습용 패키지의 파일, 020), 상류 패키지의 `lib/core.yaml` · `lib/recommended.yaml` · `lib/flutter.yaml`, Flutter SDK 의 `bin/cache/flutter.version.json`. 그 밖의 것이 나오면 사용 프로젝트의 경로다. (이 문서 자체에 위 명령을 돌리면 그 셋만 나온다 — 2026-10-13 확인.) 2026-10-13 현재 CHANGELOG · VERSIONING · `tool/` · README 에서 이 패턴에 걸리는 토큰은 `lib/riverpod.yaml`, `lib/base.yaml`, `lib/analysis_options.yaml`, `lib/recommended.yaml`, `lib/codegen.yaml`, `bin/cache/flutter.version.json` 뿐이다 `[VERIFIED: git grep 으로 셈]` — `bin/cache/flutter.version.json` 은 Flutter SDK 의 파일이라 (2) 의 허용 조건(`[ -e "$p" ]`)에 걸리지 않는다 → 허용 목록에 글자 그대로 더한다.
- (1) 은 `.planning/phases/01-…` 등 **이전 phase** 의 파일에 이미 97건이 있다 (저장소 자신의 절대 경로와 fvm 캐시 경로) `[VERIFIED: git grep 셈, 2026-10-13]`. 이 phase 의 대상 파일로 범위를 좁힌 것은 그래서다. 그 97건은 이 저장소의 경로이지 사용 프로젝트의 것이 아니다.
- `grep` 에 `-` 로 시작하는 고정 문자열을 줄 때는 `-e` 를 쓴다 (이 셸의 `grep` 은 ugrep wrapper 다 — orchestrator 메모). (4) 가 그 경우다.
- 이 점검을 계획의 각 커밋 task 의 `<automated>` 검증에 넣고, wave 2 · 4 · 5 의 끝에 한 번 더 돌린다. SUMMARY · VERIFICATION 을 쓰는 agent 에도 같은 규칙을 지시문으로 넘긴다 (D-07 "`.planning/` 에도 똑같이 적용").

### Anti-Patterns to Avoid

- **결과 JSON 을 지문 비교 전에 저장소 안에 쓰는 것** — `git status` 가 바뀌어 "저장소가 바뀌었다" 로 멈춘다. 작업 폴더에 쓰고, 최종 비교 뒤 복사한다.
- **실측이 도는 동안 저장소에서 다른 task 를 진행하는 것** — 022 의 첫 실행이 그래서 깨졌다 (CONVENTIONS.md:69).
- **spike 022 의 그룹 상수를 그대로 복사하는 것** — B-6 의 7개가 빠져 있다 (§ 2).
- **단독 dry 의 수, 그룹 dry 의 수, `hasFix` 를 `dart fix` 칸에 적는 것** — 수정 수와 사라지는 줄은 두 방향으로 다르다 (16 → 32, 155 → 123; rule-evaluation-table.md 8번).
- **apply 를 이어서 하는 것** — 규칙마다 `refreshSources`.
- **0줄을 표식 없이 "깨끗하다" 로 적는 것, 언어 버전 3.13 전용 규칙의 지금 하한 0 을 값으로 쓰는 것, 하한을 올린 값을 하한 3.11 의 기준선과 견주는 것** (rule-evaluation-table.md What to Avoid).
- **`unnecessary_ignore` 를 다른 후보와 같은 회차에서 결정하는 것** — 38 ↔ 12 로 움직인다 (D-17).
- **`example/lib/added_rules.dart` 의 함수를 지우거나 줄을 끼워 넣는 것** — 다른 규칙의 정답지 줄이 함께 바뀐다.
- **새 규칙의 샘플을 분류와 무관하게 한 파일에 몰아 넣는 것** — 묶음 커밋과 정답지 `+` 줄의 1:1 대응이 흐려진다.
- **`[2/N]` 안에 새 확인을 섞어 넣고 단계 수를 그대로 두는 것** — 실패 문구가 "규칙 이름" 단계로 찍혀 M 기록의 귀속이 흐려진다. 새 단계로 둔다 (재량이지만 권고).
- **`RULES.md` 를 제목 문구로 찾는 것** — Phase 5 가 문서를 다시 쓰면 깨진다. 마커 구역으로.
- **`countDeclaredRules` 처럼 맵 형식을 모르는 정규식에 기대면서 맵 형식 규칙을 적는 것** (WR-03) — 목록 형식만 쓴다.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| 복사본 · `path:` 물리기 · 받은 자리 · 지문 · 분석 한 번 | 새 `Consumer` | `sources/021-new-rules-language-gate/consumer.dart` 전문 | 세 spike 가 그대로 돌렸다. `replaceOnce` 의 "정확히 한 번" 요구가 사용 프로젝트의 변화를 잡는다 |
| `dart fix` 출력 읽기, apply 고리 | 새 파서 | 022 `probe.dart` 의 `dryRun` 정규식과 고리 | 출력 모양(`  <코드> - N fix(es)`, `N fixes made in M files.`)을 실측으로 맞췄다 |
| 무시 주석 걷어내기 | 줄을 지우는 치환 | 023 `stripIgnores` (주석 부분만 지우고 줄은 남긴다) | 줄 번호가 유지되어야 두 실행을 줄 단위로 견준다 |
| `messages.yaml` 읽기 | yaml 패키지 (의존성 추가) | 020 `readMessagesYaml` (들여쓰기 2 / 4 / 6칸에 기댄 줄 단위) + `snake` (숫자 앞 `_`) | `dart:io` 만 쓰는 조건. `MessagesRule.latest` 의 우선순위도 검증됐다 |
| 상류 세트 읽기 | `rules.json` 의 `sets` | 020 `readUpstreamSets` (pub cache 의 YAML, 소문자 비교) | `sets` 는 262개 모두 빈 배열이다 |
| 진단 JSON → 정답지 형식 | 새 정규화 | `tool/verify.dart` `normalizeDiagnostics` (심볼릭 링크 base 둘) | 이미 CI 에서 돈다 |
| 해시 | md5 (dart:io 에 없음) | 019 · 021 의 64비트 FNV-1a `digest` | 경로를 드러내지 않고 줄 목록을 견준다 |

**Key insight:** 이 phase 의 코드는 "새로 짓는 것" 이 아니라 "네 spike 의 조각을 한 파일에 잇고 판정을 코드의 조건으로 올리는 것" 이다. 조각을 다시 쓰면 spike 가 실측으로 맞춘 세부(정규식, 요구 조건, 회차 순서)를 잃는다.

## Runtime State Inventory

> 이름 바꾸기 · 이전이 아니라 생략한다 — 다만 이 phase 가 "지우는" 것이 사용 프로젝트에 남긴 상태가 있는지는 확인했다. 겹치는 6개와 주석 3개는 분석 옵션일 뿐이고 사용 프로젝트의 lock · 캐시 · 환경변수 어디에도 들어 있지 않다. `riverpod_lint` plugin 캐시(`~/.dartServer/.plugin_manager`)는 `plugins:` 를 바꾸지 않으므로 그대로다. **None — `lib/base.yaml` 과 사용 프로젝트의 관계는 `include:` 한 줄뿐임을 019 · 021 ~ 023 의 복사본 실측이 보였다.**

## Common Pitfalls

### Pitfall 1: 022 의 "후보 119개" 를 그대로 믿는다
**What goes wrong:** B-6 의 7개(`cascade_invocations` 등)가 평가표에서 빠져 미채택 사유에 숫자가 붙지 않는다 (D-01 의 근거가 깨진다).
**Why it happens:** FEATURES.md 245 · 246 · 253행이 한 칸에 이름을 여럿 적었고 022 가 첫 이름만 받았다.
**How to avoid:** § 2 의 상수와 단언(125 + 1 + 6 + 1).
**Warning signs:** `--summary` 의 제외 권장 묶음이 26개로 나온다 (33개여야 한다).

### Pitfall 2: 결과 파일을 저장소에 쓰다가 지문이 깨진다
**What goes wrong:** 마지막 지문 비교가 "바뀜" 으로 끝나 회차 전체가 의심받는다.
**How to avoid:** `--out` 복사는 지문 비교 **뒤**. 실행 중에는 저장소에서 아무것도 만들지 않는다 (Claude 의 다음 task 포함).
**Warning signs:** 지문의 첫 토큰(`git status --porcelain`)만 달라졌다.

### Pitfall 3: `fixtures/overrides` 가 끄는 `prefer_final_locals` 를 소유자가 뺀다
**What goes wrong:** overrides 의 "끈 진단만 사라진다" 대조가 사라지고, `verify.dart:90` 의 `optionsLines` · README · M19 설명이 거짓이 된다.
**How to avoid:** 지금 켜 둔 6개 묶음의 checkpoint 화면에 이 의존을 한 줄 적어 보인다. 빼기로 하면 끄는 규칙을 남는 규칙 하나로 바꾼다 (같은 커밋에서 fixture 옵션 파일 · `optionsLines` · README).
**Warning signs:** `[4/10]` (연습용 프로젝트 옵션 파일) 는 통과하는데 overrides 의 정답지에 `- lib/added_rules.dart:24  info  prefer_final_locals` 가 없다.

### Pitfall 4: warning 등급 채택으로 `base_codegen` 의 `exit 0` 이 바뀐다
**What goes wrong:** 정답지 diff 에 `종료 코드: 정답지 0, 실제 2` 가 떠서 "깨졌다" 로 오해한다.
**Why it happens:** `strict-inference` 의 `inference_failure_on_*` 가 warning 이다.
**How to avoid:** D-19 화면과 CHANGELOG `### 올리기 전에` 에 미리 적는다. `--update` 가 `exit 2` 로 다시 쓴다 — 결정과 대응하는 변화다.

### Pitfall 5: 새 규칙이 기존 샘플에 걸려 `+` 줄 수가 샘플 수와 다르다
**How to avoid:** 보통 실행으로 diff 를 먼저 본다. 같은 규칙의 줄이면 받아들이고(샘플 수에 포함), 다른 규칙의 줄이면 샘플을 고친다 (줄 수 유지).

### Pitfall 6: 표식이 언어 버전 3.13 문법이라 지금 하한의 복사본에서 `experiment_not_enabled` error 를 낸다
**How to avoid:** G1 ~ G3 표식은 3.11 문법만. 3.13 문법 표식은 G4 (하한 `^3.13.0`) 에만 넣는다 (021 의 `oldSamples` / `newSyntaxSamples` 구분).

### Pitfall 7: 복사본 작업 폴더가 심볼릭 링크를 거쳐 진단 경로가 떼어지지 않는다
**What goes wrong:** 모든 진단의 `area` 가 파일 이름이 되어 `lib` / `test` 집계가 0 이 되고 표식도 "미검출" 이 된다.
**How to avoid:** `Consumer.analyze` 의 경로 떼기를 `verify.dart` 의 `normalizeDiagnostics` 처럼 base 둘(준 경로 · `resolveSymbolicLinksSync`)로. 작업 폴더는 링크 없는 자리(홈 아래)를 권한다.

### Pitfall 8: `messages.yaml` 을 받지 못한다 (네트워크)
**How to avoid:** 받기 실패 → 020 의 결과 JSON 을 읽는 fallback + 회차 기록에 출처를 적는다 (§ Standard Stack 의 대안). 상태 칸의 값은 같다 (같은 tag).

### Pitfall 9: `RULES.md` 와 `lib/base.yaml` 을 다른 커밋에서 고친다
**What goes wrong:** 중간 커밋에서 `[3/10]` 이 실패해 CI 가 빨갛다 (push 는 phase 끝이지만 bisect 가 깨진다).
**How to avoid:** 묶음 커밋 하나에 둘을 함께 (§ 6).

### Pitfall 10: `.planning/` 의 PLAN · SUMMARY 에 사용 프로젝트의 경로나 메시지가 들어간다
**How to avoid:** § 8 의 grep 을 커밋 task 의 `<automated>` 에. 하위 agent 지시문에 "경로 · 메시지 · 코드 조각 금지, 건수와 규칙 이름만" 을 적는다.

## Code Examples

### 측정 도구의 뼈대 (단계 · 지문 · 회차 유효성)

```dart
// tool/measure_rules.dart — dart:io, dart:convert 만. consumer.dart 의 클래스를 이 파일에 옮겨 넣는다
// (tool/ 에 import 할 다른 파일을 두지 않는다 — 루트 분석 대상이 늘고 spike 사본은 읽기용이다).
Future<void> main(List<String> args) async {
  final opts = parseArgs(args);                              // --source, --work 필수. 없으면 64
  final repoRoot = File.fromUri(Platform.script).parent.parent.path;   // verify.dart:1436 과 같은 셈법
  final repo = Repo(Directory(repoRoot).resolveSymbolicLinksSync());
  if (Directory(opts.work).absolute.path.startsWith(repo.root)) {
    stderr.writeln('--work 는 저장소 밖이어야 한다 (지문의 git status 가 깨진다)');
    exit(64);
  }
  final consumer = Consumer(work: opts.work, repo: repo, source: opts.source);
  final results = Results.load('${opts.work}/results/${opts.runId}.json');   // 합쳐 쓴다

  var last = await repo.fingerprint();
  Future<void> step(String name, Future<void> Function() body) async {   // repo_guard.dart:21-27
    await body();
    final now = await repo.fingerprint();
    if (now != last) {
      stderr.writeln('$name: 저장소가 바뀌었다 — 이 실행을 쓰지 않는다');
      exit(1);
    }
    results.save();                                           // 단계마다 작업 폴더에 저장 (저장소 밖)
  }

  if (opts.stages.contains('state')) await step('state', () => measureState(opts, results));
  if (opts.stages.contains('baseline')) await step('baseline', () async {
    consumer.copy();
    await consumer.pointToRepo();
    consumer.addExampleMarkers();
    results.addRun(validate(await consumer.analyze('B0'), consumer, repoRoot));
    await consumer.useSdk('^3.13.0');
    results.addRun(validate(await consumer.analyze('B0-313'), consumer, repoRoot));
    await consumer.useSdk(null);
  });
  // groups → markers → ignore → fix 순. 각 단계는 refreshSources 로 시작한다.

  // 저장소 안에는 지문 비교가 모두 끝난 뒤에만 쓴다.
  File(opts.out).parent.createSync(recursive: true);
  File(opts.out).writeAsStringSync(results.toPrettyJson());
}

/// 회차가 유효한지 — RULES-05 의 조건을 코드로. 무효여도 멈추지 않고 표시만 한다.
Run validate(Shot shot, Consumer consumer, String repoRoot) {
  final expected = expectedLines('$repoRoot/example/expected_diagnostics.txt')
      .map((l) => l.replaceFirst('lib/', Diag.markerDir)).toSet();
  final markerTexts = shot.marker.map((d) => d.text).toSet();
  return Run(shot,
      expectedCovered: expected.every(markerTexts.contains),
      valid: shot.woodySource == 'repo' &&
          expected.every(markerTexts.contains) &&
          shot.pluginFolders == 1 && !shot.pluginHeader && shot.jsonOk);
}
```

### `verify.dart` 의 새 단계 — 세 확인을 한 `StepResult` 로

```dart
/// [3/N] 배포 파일의 구성 — (a) 묶음 · 별칭은 include 만, (b) base.yaml 과 기반 세트의 겹침, (c) RULES.md 와 일치.
StepResult checkShippedComposition(String repoRoot) {
  final details = <String>[];
  // (a) includeOnlyFiles — significantLines 로 읽어 sameLines 로 견준다 (checkFixtureOptions 의 방식).
  // (b)
  final declared = declaredRuleNames(File('$repoRoot/lib/base.yaml').readAsStringSync());
  final upstream = readUpstreamRules(repoRoot);              // 이름 소문자 → 세트 파일 이름
  final overlapping = [for (final r in declared) if (upstream.containsKey(r.toLowerCase())) r]..sort();
  if (overlapping.isNotEmpty) {
    details.addAll([
      '`lib/base.yaml` 의 규칙이 기반 세트와 겹친다 (${overlapping.length}) — 기반 세트가 이미 켜므로 지운다.',
      ...overlapping.map((r) => '  $r  (${upstream[r.toLowerCase()]})'),
    ]);
  }
  // (c)
  final listed = readRulesMdBlock(File('$repoRoot/RULES.md'), 'enabled-rules');   // 마커 사이 첫 칸 backtick 이름
  final a = [...declared]..sort(), b = [...listed]..sort();
  if (!sameLines(a, b)) {
    details.addAll([
      if (details.isNotEmpty) '',
      '`RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 의 규칙 목록이 다르다.',
      ...subtractLines(a, b).map((r) => '  + $r  (base.yaml 에만)'),
      ...subtractLines(b, a).map((r) => '  - $r  (RULES.md 에만)'),
    ]);
  }
  return StepResult(label: '배포 파일의 구성', passed: details.isEmpty, detailLines: details);
}
```

### 쌍마다 둘만 켠 비호환 확인 (020 의 방식)

```dart
// 저장소 밖 <work>/pkg13/ 에 pubspec (sdk: ^3.13.0) 과 lib/a.dart 를 두고, 쌍마다 옵션 파일을
//   linter:\n  rules:\n    - a\n    - b\n
// 로 쓴 뒤 dart --suppress-analytics analyze --format=json 을 돌린다 (약 0.5초).
// incompatible_lint 는 뒤에 적은 규칙(4행)에 warning 으로 붙는다 (rule-evaluation-table.md 5번).
// 쌍 목록은 020 결과 JSON 의 rules[].jsonIncompatible 선언 13개 규칙 → 12쌍 (sort 해 중복 제거).
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `rules.json` 을 규칙 메타데이터의 기준으로 | `messages.yaml` + 실제 분석 + pub cache 의 YAML | 상류가 `rules.json` 을 "unsupported and deprecated" 로 표시 (tag 3.13.4 의 `pkg/linter/tool/machine/README.md`, spike 020) | D-02 의 칸 출처. ROADMAP 195행을 고친다 (D-23) |
| `strict-casts` / `strict-raw-types` 옵션 | lint `no_dynamic_casts` / `no_raw_types` | Dart 3.13 (FEATURES.md 353행) | info 등급이라 규칙처럼 세고 끌 수 있다. `strict-inference` 만 옵션 (warning) |
| `require_trailing_commas` | formatter 가 대신 (언어 3.7+ 에서 규칙이 보고하지 않음) | Dart 3.7 (dart-lang/sdk#60119) | RULES-02 삭제의 근거. 표식까지 0줄로 나올 것 |
| `dart fix --dry-run` 으로 "고칠 수 있는 건수" | 규칙 하나씩 `--apply --code=` 뒤 재분석해 사라진 줄 | spike 022 (2026-10-12) | D-02 의 두 칸, CHANGELOG `dart fix` 칸의 뜻 |
| `flutter_lints` 가 const 규칙 셋을 켬 | 5.0.0 에서 제거 (dart-lang/lints#205) | `flutter_lints` 5.0.0 | D-18 사유 문구 수정 |

**Deprecated/outdated:**
- `rules.json` 의 `state` · `sets` · `fixStatus` — 쓰지 않는다 (위).
- ROADMAP Phase 4 Notes 195 ~ 196행과 "Spike first" 넷째의 `--dry-run` 문구 — D-23 으로 고친다.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | 실측 전체가 약 32분 (분석 약 22초, apply 약 30초, 단독 dry 약 7초 — 2026-10-12 의 복사본 값에서 셈) | § 1 시간 | 길어져도 결과는 같다. 계획의 task 시간 배분만 어긋난다 |
| A2 | 0줄 후보가 약 60개라 표식을 약 60개 써야 한다 (022 의 62개에서) | § 1 표식 | 더 많으면 wave 1 의 작업량이 늘고, 적으면 준다 |
| A3 | 복사본 · 루트의 `package_config.json` 의 `rootUri` 가 상대 경로일 수 있어 처리를 넣는다 (지금 환경은 `file:` 절대 URI) | § 1, § 4 | 처리가 없어도 지금 환경에서는 돈다. 다른 pub 설정에서 상류 세트를 못 읽는다 |
| A4 | `--work` 를 scratchpad 가 아니라 소유자의 홈 아래 고정 폴더로 두는 것이 재측정에 유리하다 | § 1 출력의 자리 | 어디든 저장소 밖이면 D-07 · 지문에는 영향 없다 |
| A5 | `RULES.md` 의 "켠 이유" 와 `base.yaml` 사유 주석을 자동으로 글자 비교하면 깨지기 쉽다 | § 3 | 자동 비교를 넣어도 된다 — 그러면 RULES-07 의 한 부분이 자동화된다 |
| A6 | 새 단계를 `[3/N]` 로 두어 N = 10 이 되는 것이 `[2/N]` 안에 섞는 것보다 M 기록의 귀속이 또렷하다 | § 4 | 재량이다. 섞어도 D-11 · D-12 는 만족한다 |
| A7 | 새 규칙 샘플이 기존 샘플 파일에 걸릴 수 있다 (어느 규칙이 걸릴지는 실측 전엔 모른다) | § 6 | 걸리지 않으면 더 단순하다 |
| A8 | 소유자의 `flutter_starter_kit` 원본 경로와 모양(옛 주소 include, `sdk: ^3.11.1`)이 2026-10-12 와 같다 — 이 세션은 원본을 찾지도 읽지도 않았다 | § 1 | `Consumer.copy` · `pubspecWithSdk` 가 `FormatException` 으로 멈춘다 — 그때 요구 조건을 고친다 |

## Open Questions

1. **`unnecessary_ignore` 재측정에 쓸 옵션의 모양**
   - What we know: 다른 후보의 채택이 정해진 뒤 그 결과를 켠 채로 잰다 (D-17). 복사본은 `path:` 로 작업 중인 저장소를 받으므로 결정을 반영한 `lib/base.yaml` 이 그대로 적용된다.
   - What's unclear: 옵션 파일에 `unnecessary_ignore: true` 만 더하면 되는지 (그렇다 — 023 의 I4 가 그 모양), 그 회차의 "기준선" 을 무엇으로 적을지.
   - Recommendation: 회차 `UI` = 결정 반영 뒤의 저장소 + `unnecessary_ignore` 하나. 기준선은 같은 저장소의 B0 재측정(`UI-base`) 하나를 더 돌린다 (분석 1회).
2. **`strict-inference` 를 채택할 때 `lib/base.yaml` 의 `analyzer:` 블록**
   - What we know: 조각은 서로를 include 하지 않고 `codegen.yaml` 이 `analyzer:` 를 쓴다. 두 조각이 각각 `analyzer:` 를 가져도 include 병합은 키 단위라 충돌하지 않는다 (ARCHITECTURE.md § A — 이 세션에서 다시 읽지 않았다 `[ASSUMED]`).
   - Recommendation: 채택되면 `fixtures/base_codegen` 정답지가 `analyzer.language` 와 `analyzer.exclude` 의 공존을 실측으로 보인다 — 거기서 확인한다.
3. **CHANGELOG `실측` 칸의 수 — 합계 하나인가 `lib` / `test` 나눔인가**
   - What we know: `VERSIONING.md:98` 은 "그 규칙이 낸 경고 건수" 한 수, D-07 은 `RULES.md` 에 `lib` / `test` 나눔.
   - Recommendation: CHANGELOG 는 합계 하나, 나눔은 `RULES.md`. 표 아래 한 줄에 "자리별 건수와 회차는 `RULES.md`" 를 덧붙인다.
4. **`tool/measurements/` JSON 의 스키마 고정**
   - Recommendation: 머리에 `schema: 1` 을 두고, `--report` · `--summary` 가 그 값을 단언한다. RULES-13 때 바뀌면 올린다.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `fvm` | 저장소 안의 모든 `fvm dart …` | ✓ | 4.3.1 | — |
| Dart SDK (Flutter 3.47.5) | 분석 · fix · pub | ✓ | 3.13.4 (`.fvm/flutter_sdk/bin/dart`) | — |
| `lints` 6.1.0 · `flutter_lints` 6.0.0 (pub cache) | 겹침 검사 · 상류 세트 칸 | ✓ | 루트 `package_config.json` 이 가리킴 | — |
| `git` | 지문 · 커밋 | ✓ | 2.56.0 | — |
| `gh` | 첫 push 뒤 CI 확인 | ✓ | 2.102.0 | GitHub 웹 |
| `python3` (보조) | § 8 점검의 대안 | ✓ | 3.9.6 | 셸만으로 가능 |
| 네트워크 — `raw.githubusercontent.com` (messages.yaml), pub.dev (복사본 `pub get`, plugin) | `state` 단계, 복사본 분석 | 이 세션에서 확인 안 함 | — | messages.yaml 은 020 결과 JSON fallback. `pub get` · plugin 은 대안 없음 (plugin 이 없으면 회차 무효) |
| `flutter_starter_kit` 원본 | `--source` | **확인 안 함 — 일부러 찾지 않았다** (읽기 전용이지만 경로를 이 문서에 남기지 않기 위해) | — | 없음 — 소유자가 실행 때 경로를 준다 |
| 저장소 밖 작업 폴더 (수백 MB 여유 — 복사본 + 상태 폴더 약 60개) | `--work` | 소유자가 정한다 | — | — |

**Missing dependencies with no fallback:** 사용 프로젝트 원본의 경로 (실행 시점 인자) — 계획의 precondition 으로 적는다.
**Missing dependencies with fallback:** `messages.yaml` 받기 (020 결과 JSON).

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | 없음 (테스트 프레임워크 · `test/` 없음). 검증 장치는 `tool/verify.dart` (정답지 비교 + 단계 검사), 루트 `fvm dart analyze`, `tool/measure_rules.dart` 의 자기 판정(`valid` · 지문), § 8 의 grep |
| Config file | `tool/verify.dart` 의 `fixtures` 표 · `includeOnlyFiles` (새) · `RULES.md` 마커 — "none — see Wave 0" 아님 |
| Quick run command | `fvm dart analyze` (약 1초) + `fvm dart run tool/verify.dart` (plugin 준비된 상태 약 22초, 처음 약 69초) |
| Full suite command | 위 둘 + § 8 grep 넷 + (로컬만) `fvm dart run tool/measure_rules.dart --source … --work … --stage all` (약 32분) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| RULES-01 | 겹치는 6개가 `lib/base.yaml` 에 없고 겹침이 재발하지 않는다 | 단계 검사 (CI) | `fvm dart run tool/verify.dart` → `[3/10]` 통과; 보조: `grep -c -E '^\s*- (sized_box_for_whitespace\|sort_child_properties_last\|slash_for_doc_comments\|use_build_context_synchronously\|avoid_print\|control_flow_in_finally)' lib/base.yaml` = 0 | ❌ `[3/10]` 은 wave 1 |
| RULES-02 | 주석 처리된 설정 3개가 없다 | grep (CI 가능) | `grep -c -E 'require_trailing_commas\|public_member_api_docs\|trailing_commas' lib/base.yaml` = 0 | ✓ 명령만 |
| RULES-03 | 후보마다 실측 건수와 `dart fix` 건수가 표에 있다 | 데이터 검사 (로컬) | `measure_rules.dart --report` 가 행 133 · 빈 칸 0 을 단언 (`exit 1` 아니면 통과); `RULES.md` § 실측 기록 에 그 표 | ❌ wave 2 · 5 |
| RULES-04 | strict 3개가 같은 표에 | 데이터 검사 | 같은 `--report` 가 `no_dynamic_casts` · `no_raw_types` · `strict-inference` 행을 단언 | ❌ |
| RULES-05 | 회차마다 SDK / 기반 세트 / plugin 이 적히고 무효 회차의 수치가 쓰이지 않았다 | 데이터 검사 | `--report` 가 `runs[].valid` 가 아닌 회차를 참조한 행이 0 임을 단언; JSON 의 `runs[]` 필드 존재 | ❌ |
| RULES-06 | 결정이 배포 파일에 반영 | 단계 검사 (CI) | `[3/10]` (c) `RULES.md` ↔ `lib/base.yaml`; M21 · M22 · M25 로 헛통과 아님을 기록 | ❌ wave 4 |
| RULES-07 | 사유 주석이 사실과 맞다 | 사람 확인 + grep | `grep -c '성능 향상' lib/base.yaml` = 0 (D-18); 나머지는 checkpoint 에서 소유자가 `RULES.md` 켠 이유와 함께 본다 | ✓ 명령만 |
| RULES-08 | 미채택 목록이 후보를 다 덮는다 | 데이터 검사 | `--report` 가 (후보 133 − 켠 규칙 − 켜지 않은 규칙 표의 이름 − v2 로 미룸) = ∅ 과 B-7 31개의 상태 행을 단언 | ❌ |
| DOCS-11 | 켠 규칙마다 이유 · 실측 · 회차 | 데이터 검사 | `RULES.md` `enabled-rules` 구역의 모든 행에 빈 칸이 없다 — `--report` 또는 `awk -F'|'` 한 줄 | ❌ |
| (D-07) | 비공개 정보 없음 | grep (CI 가능하나 로컬 커밋 전) | § 8 의 네 명령 모두 0 | ✓ 명령만 |
| (D-20) | 삭제 커밋에서 정답지 불변 | 실행 기록 | `fvm dart run tool/verify.dart --update` → `바뀐 정답지가 없다 — 쓰지 않았다`; `git diff --stat -- '*expected_diagnostics.txt'` 비어 있음 | ✓ |
| (D-10) | 새 규칙마다 정답지 줄 | 정답지 비교 (CI) | `[5/10]` ~ `[10/10]`; 묶음 커밋의 `git diff` 에서 `+` 줄 수 = 샘플 수 | ✓ 장치, ❌ 샘플 |

### CI 에서 도는 것 / 로컬에서만 도는 것

- **CI (GitHub `verify`):** `tool/verify.dart` 10단계 전부 — `[3/10]` 의 세 확인 포함. 비공개 프로젝트가 필요 없다. 시간은 지금의 약 3분 30초 ~ 4분 7초 (STATE.md Phase 03 기록) 에 `[3/10]` 의 1초 미만이 더해진다.
- **로컬만:** `tool/measure_rules.dart` (사용 프로젝트 원본 필요), § 8 의 (4) (원본 경로 필요). `--report` · `--summary` 는 JSON 만 읽으므로 어디서나 돌지만 CI 에 넣지 않는다 (지금은 할 일이 없다).

### Sampling Rate

- **Per task commit:** `fvm dart analyze` + `fvm dart run tool/verify.dart` + § 8 (1) ~ (3). 결정 묶음 커밋은 `--update` 전에 보통 실행으로 diff 를 먼저 본다.
- **Per wave merge:** 위 + § 8 (4), `diff -rq example/lib fixtures/*/lib` (suppress/ 제외), wave 2 는 `measure_rules.dart` 의 지문 · `valid` 전부.
- **Phase gate:** `verify` 로컬 종료 코드 0 · GitHub `verify` 성공 1회 이상 (첫 push 뒤), `--report` 단언 전부, § 8 전부 0, M20 ~ M25 기록, ROADMAP 성공 기준 1 ~ 5 를 `04-VERIFICATION.md` 가 실행으로 확인.

### Wave 0 Gaps

- [ ] `tool/measure_rules.dart` — RULES-03 · 04 · 05 · 08 의 데이터 검사(`--report` 단언)를 포함해 만든다 (wave 1)
- [ ] `tool/verify.dart` `[3/10]` — RULES-01 · 06, D-12 (wave 1 에 (a) · (b), wave 4 첫 커밋에 (c))
- [ ] `RULES.md` 마커 구역 — (c) 의 대상 (wave 4 첫 커밋)
- 프레임워크 설치: 없음

## Security Domain

> `security_enforcement` 가 켜져 있다 (`.planning/config.json`). 이 phase 에는 네트워크 서비스 · 인증 · 저장소가 없고, 위험은 **비공개 프로젝트의 정보 유출**과 **도구가 저장소 · 원본을 바꾸는 것** 둘이다.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | no | — |
| V5 Input Validation | yes — CLI 인자 | `--source` 는 존재하는 폴더 · `pubspec.yaml` 있음, `--work` 는 저장소 밖, `--rules` 는 후보 상수 안의 이름만 (아니면 64). 원본은 `copySync` 로 읽기만 — 원본 아래에 쓰는 코드 경로가 없다 |
| V6 Cryptography | no (FNV-1a 는 식별용 해시이지 보안 해시가 아니다 — 그렇게 적는다) | — |
| V8 Data Protection | **yes** — 비공개 프로젝트의 경로 · 메시지 · 코드 | 구조(`Shot.toJson`, `private/` 분리) + § 8 grep. 공개 저장소에 올라가는 모든 파일에 적용 (D-07) |
| V10 Malicious Code / Supply chain | yes — `messages.yaml` 받기 | HTTPS, tag 고정 URL, 받은 파일은 **읽기만** 하고 실행하지 않는다. `LinterLintCode:` 가 없으면 `FormatException`. 새 pub 의존성 0 |

### Known Threat Patterns for 이 stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| 사용 프로젝트의 경로 · 메시지가 공개 저장소에 (한 번 올리면 되돌릴 수 없다 — D-07 one-way) | Information disclosure | 결과 구조에서 배제, 줄 전문은 저장소 밖 `private/`, 커밋 전 grep (§ 8), `.planning/` 포함 |
| 도구가 작업 중인 저장소를 바꾼다 (`pub get` · `dart fix` 가 엉뚱한 폴더에서) | Tampering | 지문 단계 비교(`repo_guard` 방식), `--work` 저장소 밖 강제, `dart fix` 의 `workingDirectory` 는 복사본 |
| 도구가 원본을 바꾼다 | Tampering | 원본 경로로는 `File.copySync` 의 **원본 인자**로만 접근. 실행 전후 원본의 `git status` 를 소유자가 본다 (019 의 관례) |
| 수치의 출처를 따라갈 수 없다 | Repudiation | 회차 id · 조건 · `valid` 를 JSON 과 `RULES.md` 에 (RULES-05) |
| 받은 `messages.yaml` 이 바뀌어 상태가 틀린다 | Tampering (상류) | tag 고정 URL, 020 결과 JSON 과 상태 분포(stable 229 · removed 14 · deprecated 6 …)를 견줘 다르면 경고 |

## Sources

### Primary (HIGH confidence)

- 이 저장소의 파일 (이 세션에서 `Read` 로 읽음): `.planning/phases/04-rule-reselection/04-CONTEXT.md` 전문, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `.planning/ROADMAP.md` 169 ~ 199행 · 7 ~ 13행, `.planning/research/FEATURES.md` 82 ~ 371행, `.planning/spikes/CONVENTIONS.md`, `.claude/skills/spike-findings-woody-lints/SKILL.md` 1 ~ 172행과 173 ~ 363행의 Phase 4 관련 줄, `references/rule-evaluation-table.md` 전문, `references/real-consumer-measurement.md` 전문, `references/rule-status-check.md` § 7 · What to Avoid · Constraints, `sources/021-new-rules-language-gate/consumer.dart` 전문, `sources/022-dart-fix-dry-run-count/probe.dart` 20 ~ 80행 · `repo_guard.dart` 전문, `sources/023-existing-ignore-comments/probe.dart` 24 ~ 70 · 260 ~ 335행, `sources/020-rule-state-vs-rules-json/probe.dart` 329 ~ 470행, `tool/verify.dart` 1 ~ 260 · 275 ~ 440 · 620 ~ 690 · 769 ~ 1143 · 1426 ~ 1545행, `lib/*.yaml` 다섯, 루트 `analysis_options.yaml`, `pubspec.yaml`, `.gitignore`, `VERSIONING.md` 38 ~ 127행, `CHANGELOG.md`, `example/README.md` 전문, `example/lib/added_rules.dart` · `base_rules.dart`, 정답지 다섯, `fixtures/overrides/analysis_options.yaml` · `lib/suppress/*`, `.planning/phases/03-preset-split/03-REVIEW.md` WR-01 · WR-02 절, `03-REVIEW-DISPOSITION.md` 1 ~ 30행, `03-VERIFICATION.md` Gaps Summary, `03-CONTEXT.md` D-03 ~ D-05 · D-09, `02-CONTEXT.md` D-04, `.planning/PROJECT.md` Constraints · Key Decisions
- spike 결과 JSON (스크립트로 읽음): `.planning/spikes/020-rule-state-vs-rules-json/results/probe-3.13.4.json` (`rules[]` 275개의 `messages` · `actualState13` · `jsonIncompatible` · `upstreamSet`), `.planning/spikes/022-dart-fix-dry-run-count/results/probe-3.13.4.json` (`rows` 119개의 `diagProject` · `alone`, `applied` 9개)
- pub cache: `~/.pub-cache/hosted/pub.dev/lints-6.1.0/lib/{core,recommended}.yaml`, `flutter_lints-6.0.0/lib/flutter.yaml` — 35 · 58 · 10 규칙, 합집합 102, 겹치는 6개의 자리
- 고정 SDK: `.fvm/flutter_sdk/bin/dart --version` (3.13.4), `dart fix --help` (`--code=<code1,code2,...>`)
- 도구 버전: `fvm --version` 4.3.1, `gh --version` 2.102.0, `git --version` 2.56.0, `python3 --version` 3.9.6

### Secondary (MEDIUM confidence)

- Context7 `/dart-lang/site-www` — `src/content/tools/dart-fix.md`: `--code` 는 쉼표로 나눈 코드 하나 이상, `--dry-run` / `--apply` (고정 SDK 의 `--help` 와 일치해 HIGH 로 올려 적어도 되지만 문서 자체는 `main` 의 것이다)

### Tertiary (LOW confidence)

- `raw.githubusercontent.com/VeryGoodOpenSource/very_good_analysis/main/README.md` (WebFetch, 2026-10-13) — "Excluded rules" 표 헤더 `| Rule | Reason |`, 행 38개. 형식의 참고일 뿐 이 phase 의 판정에 쓰이지 않는다

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 새 의존성 없음, SDK · pub cache · 도구 버전을 이 세션에서 실행으로 확인
- Architecture: HIGH — 이어 받을 코드를 전문으로 읽었고, 그룹 · 후보 · 겹침을 결과 JSON 과 YAML 로 다시 세었다. 시간과 표식 수만 추정 (A1 · A2)
- Pitfalls: HIGH — spike 의 What to Avoid 에 더해 이 세션에서 새로 찾은 넷(022 의 7개 누락, overrides 의 `prefer_final_locals` 의존, `base_codegen` 의 `exit` 변화, 기존 샘플에 걸리는 새 규칙)은 파일을 읽어 확인한 것이다

**Research date:** 2026-10-13
**Valid until:** 2026-11-12 (30일) — 다만 `flutter_starter_kit` 이 바뀌면 § 1 의 이름 목록(apply 범위의 출발점)은 바로 낡는다 (D-14 가 그래서 다시 잰다). `lints` 7 / `flutter_lints` 7 이 나오면 § 2 의 겹침 전제가 바뀐다 (RULES-13)
