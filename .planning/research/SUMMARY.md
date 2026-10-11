# Project Research Summary

**Project:** woody_lints
**Domain:** Dart/Flutter 공유 lint 설정 패키지 (configuration-only package, Git 의존성 + git tag 배포)
**Researched:** 2026-10-11
**Confidence:** MEDIUM

**이 문서의 근거 표기.** 네 연구 문서는 근거 수준이 서로 다르다. 겹치는 주장은 아래 순서로 우선한다.

| 표기 | 뜻 | 주로 나온 문서 |
|------|----|----------------|
| `[실측]` | Flutter 3.47.5 / Dart 3.13.4 에서 scratch 패키지로 직접 실행해 확인 | STACK.md, FEATURES.md |
| `[소스]` | Dart SDK tag `3.13.4`, pub, dart_style 소스를 읽어 확인. **실행하지 않음** | ARCHITECTURE.md, PITFALLS.md |
| `[문서]` | dart.dev, SDK 저장소 문서, 패키지 CHANGELOG / README | 전 문서 |
| `[이슈]` | GitHub issue 원문 (타인의 재현 보고) | PITFALLS.md |
| `[관찰]` | 이 머신의 pub cache, `.plugin_manager`, `flutter_starter_kit` 을 읽기 전용으로 확인 | ARCHITECTURE.md, PITFALLS.md |
| `[추정]` | 위 근거에서 나온 판단 | FEATURES.md 의 "소음" 등급 전부 |
| `[미검증]` | 어느 문서도 실행으로 확인하지 못함. 신뢰도를 올리지 않고 그대로 넘긴다 | — |

ARCHITECTURE.md 와 PITFALLS.md 는 연구 단계에서 `dart analyze` 를 한 번도 실행하지 않았다. 두 문서가 "검증 필요"로 남긴 항목 중 일부는 STACK.md / FEATURES.md 의 실측으로 이미 답이 나왔다. 어느 항목이 해소됐고 어느 항목이 남았는지는 "Gaps to Address" 에 정리했다.

## Executive Summary

`woody_lints` 는 `lib/` 아래 YAML 이 유일한 산출물인 설정 전용 패키지다. 이런 패키지는 기반 세트(`flutter_lints`) 위에 규칙을 얹고, 저장소 안의 소비자 fixture 프로젝트로 "문서에 적힌 그대로 적용되는가"를 검증하며, 버전을 고정할 수단을 제공하는 방식으로 만든다. 네 문서의 결론은 한 방향이다. `flutter_lints ^6.0.0` 기반을 유지하고 규칙은 `flutter_starter_kit` 복사본 실측을 보고 하나씩 켠다. 설정은 `lib/` 아래 조각 파일(기본 / Riverpod / codegen)로 나누고, 기존 URI `package:woody_lints/analysis_options.yaml` 은 세 조각을 include 하는 묶음 파일로 남긴다. 검증은 `dart analyze --format=json` 출력을 커밋된 기대 진단과 비교하는 방식으로 하고, `ref: vX.Y.Z` 로 고정하는 git tag 로 릴리스한다. SDK 하한이 `^3.13.0` 으로 올라가므로 다음 버전은 2.0.0 이다.

프리셋 분리 구조의 핵심 전제는 실측으로 확인됐다. 이름이 `analysis_options.yaml` 이 아닌 파일(`lib/riverpod.yaml`)에 `plugins:` 를 두면 사용 프로젝트는 include 경유로 `riverpod_lint` 를 받고, 2단 include 에서도 로드되며, 저장소 자체 분석에서 `plugins_in_inner_options` 가 나지 않는다 `[실측: STACK.md, Dart 3.13.4]`. 다만 이것은 **문서화되지 않은 동작**이고 `[문서]`, scratch 패키지와 `path:` 의존성으로만 확인했다. git 의존성, 이 저장소의 실제 구조, GitHub Linux runner 의 cold 실행은 `[미검증]` 이다. 이 영역은 SDK 쪽에서 바뀌는 중이라(`plugins_in_inner_options` 진단 제거, inner 옵션의 plugin 지원 설계) 검증 fixture 가 계속 감시해야 한다.

위험은 세 가지로 모인다. (1) **검증이 아무것도 증명하지 못하는 경우**: lint 는 info 라 `dart analyze` 기본 종료 코드가 0 이고, deprecated / removed 규칙은 include 경유로 보고되지 않으며 `[실측]`, plugin 이 로드되지 않아도 진단이 줄어들 뿐이다. 기대 진단 비교와 "프리셋을 initial file 로 분석하는" 단계가 둘 다 필요하다. (2) **실측이 엉뚱한 것을 재는 경우**: 복사본 lockfile 이 1.3.0 커밋을 가리키거나, 디렉터리 인자를 붙인 `dart analyze` 가 plugin 진단을 잃거나 `[이슈]`, 0 건이 "깨끗하다"가 아니라 "규칙이 동작하지 않는다"인 경우(`require_trailing_commas`) `[실측]`. (3) **개발 중인 `main` 이 곧 배포**: 사용 프로젝트 5개가 전부 `ref: main` 이고 tag 가 하나도 없다. 어떤 작업보다 먼저 `v1.3.0` tag 를 달아야 한다. 계획 전에 프로젝트 소유자가 정해야 할 결정이 여러 개 있으며 "Implications for Roadmap" 맨 앞에 모았다.

## Key Findings

### Recommended Stack

상세: `.planning/research/STACK.md`. 올릴 의존성 버전은 사실상 없고, 고칠 것은 SDK 고정값과 plugin 하한이다. 배포 패키지의 `dependencies` 는 `flutter_lints` 하나로 유지한다.

**Core technologies:**
- Flutter `3.47.5` / Dart `3.13.4` (`.fvmrc`): 저장소 고정 SDK 이자 CI SDK — 실측 대상 `flutter_starter_kit` 과 같은 버전이어야 규칙별 숫자가 의미 있다. 최신 stable 은 3.47.7 `[문서: release manifest]`
- `environment.sdk: ^3.13.0`: 지원 정책을 `pub get` 단계에서 강제 — deprecated 판정 기준선도 이 값이다 `[소스: PITFALLS.md]`
- `flutter_lints ^6.0.0` (누적 102개 규칙): 기반 세트로 유지 — `very_good_analysis` 11.0.0 은 include 하지 않고 후보 목록의 1차 필터로만 쓴다. include 하면 "근거를 보고 켠다"가 "받고 끈다"로 뒤집힌다
- `riverpod_lint ^3.1.9` (최상위 `plugins:`): 하한을 3.1.3 에서 올린다 — 3.1.7 / 3.1.8 은 Dart 3.12 이하에서 `dart analyze` 를 무한 대기시켰고 3.1.9 부터 version solving 이 실패한다 `[문서: riverpod_lint CHANGELOG]` `[이슈: riverpod#4839]`
- `dart analyze --fatal-infos` / `dart analyze --format=json` + `jq`: 검증과 실측 명령 — 종료 코드 표 9칸 전부 `[실측]`. `flutter analyze` 는 3.47.5 에서 plugin 진단을 내지 않는다 `[실측]` `[이슈: flutter#187999 open]`
- `subosito/flutter-action@v2` (`flutter-version-file: .fvmrc`), `actions/checkout@v7`: CI — `.fvmrc` 가 로컬과 CI 의 단일 버전 출처가 된다. workflow 전체를 GitHub 에서 실행해 본 적은 없다 `[미검증]`

**실측으로 확인된, 설계를 좌우하는 사실 (Dart 3.13.4):**
- deprecated / removed 규칙은 include 경유로 보고되지 않는다. `analysis_options.yaml` 이라는 이름으로 분석 대상 안에 있어야 `deprecated_lint` / `removed_lint` 가 나온다 `[실측: STACK.md, FEATURES.md 독립 확인]`
- plugin 진단은 `analyzer.errors` 로 끌 수 없다. 사용 프로젝트 루트에서 `version:` 과 `diagnostics:` 를 함께 다시 선언해야 꺼지고, `version` 을 빼면 꺼지지 않는다 `[실측]`
- `// ignore: riverpod_lint/<code>` 는 접두사가 있어야 동작한다 `[실측]`
- `unnecessary_ignore` 는 plugin 진단을 판정하지 못한다 `[실측]` `[소스]`. plugin 로드 확인에는 쓸 수 없다
- include 된 파일의 `formatter:` 와 `analyzer.exclude` 는 사용 프로젝트에 적용된다 `[실측]`
- Dart 3.13.4 가 인식하는 규칙: 활성 243, deprecated 6, removed 14, 3.14 전용이라 `undefined_lint` 가 되는 것 2 `[실측]`

### Expected Features

상세: `.planning/research/FEATURES.md`. 규칙별 "소음" 등급은 전부 `[추정]` 이며 실측으로 대체해야 한다.

**Must have (table stakes):**
- 배포 파일이 유효하다 (없는 규칙, removed, deprecated, 양립 불가 쌍이 없다) — 검사 2종이 필요하다
- 문서의 규칙 목록 = 실제 설정 — Core Value 그 자체. 현재 README 가 꺼진 규칙 2건을 켜진 것으로 안내한다
- 선언한 SDK 하한이 규칙의 최소 SDK 와 일치 (`.fvmrc`, `pubspec.yaml`)
- 릴리스마다 규칙 추가 / 삭제를 적는 CHANGELOG, 버전 고정 수단 (git tag)
- 규칙 재정의 안내 (line / file / project 3단계 + plugin 진단 억제)
- 중복 선언 6개 삭제 — 실측 없이 결정 가능. 기반 세트와의 중복은 analyzer 가 경고하지 않는다 `[실측]`
- 주석 처리된 설정 3개 삭제 — `require_trailing_commas` 는 language 3.7 이상에서 no-op `[실측]` `[소스]`, `formatter: trailing_commas: preserve` 는 사용 프로젝트의 포맷 결과를 바꾼다 `[실측]`, `public_member_api_docs` 는 기본에서 빼고 실측 대상으로

**Should have (competitive):**
- 규칙별 근거 기록 (켠 이유 + 실측 건수) — 조사한 8개 패키지 중 실측 건수까지 남기는 곳은 없었다
- 끄기로 한 규칙과 사유 목록 — FEATURES.md B-6 표가 초안
- 스택 축의 선택형 프리셋 (기본 / Riverpod / codegen)
- `example/` fixture + CI, "`lib/` 에 Dart 소스가 없다" 검사
- 릴리스별 "새로 생기는 진단" 안내 (규칙, 심각도, 실측 건수, `dart fix` 가능 여부)
- strict 계열 채택 — 넣는다면 lint 형태(`no_dynamic_casts`, `no_raw_types`)로. `strict-casts` 옵션은 **error** 를 내 사용 프로젝트의 `dart analyze` 를 즉시 실패시킨다 `[실측]`

**Defer (v2+):**
- Dart 3.13 primary constructor 전환 규칙 (FEATURES.md B-4) — `unnecessary_type_name_in_constructor` 는 모든 생성자 선언에 진단을 낸다 `[실측]`. freezed 3.x / riverpod_generator 코드와의 호환은 `[미검증]`
- `migrate_design_widgets` — 대체 패키지와 이전 가능 여부 `[미검증]`. 켜기 전 별도 조사 필요
- experimental 규칙 9개, `use_primary_constructors`
- `public_member_api_docs` opt-in 프리셋, `discarded_futures` (건수가 크면 다음 릴리스로)
- `lints` 7.0.0 대응 — `switch_on_type`, `unnecessary_unawaited`, `simple_directive_paths`, `simplify_variable_pattern` 이 기반 세트에 들어올 예정 `[문서: 미릴리스 CHANGELOG]`

**하지 않는 것:** "전부 켜고 일부 끄기", 버전별 / SDK 별 옵션 파일, 자체 custom 규칙, 기본 프리셋의 `formatter:`, lint 일괄 심각도 승격, formatter 가 이미 처리하는 규칙.

### Architecture Approach

상세: `.planning/research/ARCHITECTURE.md`. 각 조각은 한 가지 관심사만 담고 서로를 include 하지 않는다(기본 조각만 `flutter_lints` 를 include). 조합은 include 하는 쪽이 목록으로 한다. include 로 받은 plugin 을 끄는 공식 수단이 없고 `[소스]`, `analyzer.exclude` 는 합집합이라 뺄 수 없으므로 `[소스]` `[실측: 합쳐짐 확인]`, opt-in 은 파일 분리로만 깨끗하게 제공된다. 병합 규칙의 세부(키별 병합 방식)는 대부분 `[소스]` 수준이다.

**Major components:**
1. `lib/base.yaml` (STACK.md 는 `core.yaml` 로 부른다) — `flutter_lints` include + 이 패키지가 추가하는 규칙. plugin, exclude, `errors: ignore` 없음
2. `lib/riverpod.yaml` — 최상위 `plugins: riverpod_lint` 만. 이름이 `analysis_options.yaml` 이 아니어야 한다
3. `lib/codegen.yaml` — `invalid_annotation_target: ignore` 와 생성 파일 exclude. 되돌릴 수 없는 설정을 opt-in 으로 격리
4. `lib/analysis_options.yaml` — 기존 공개 URI. 세 조각을 include 만 하는 묶음 파일. 자기 `plugins:` 를 갖지 않으므로 루트 exclude 우회를 걷어낼 수 있다
5. `example/` + `fixtures/base_only/` — 전체 구성 fixture 와 대조군. 같은 소스를 두 옵션 아래에서 분석해 "없어야 하는 진단"을 쌍으로 고정한다
6. `tool/verify.dart` — `dart:io` 만 쓰는 골든 비교 스크립트. CI 와 로컬이 같은 명령을 쓴다
7. `.github/workflows/verify.yaml` — push / PR / tag. tag 에서는 `tag == pubspec version == CHANGELOG 최상단` 검사
8. 루트 `analysis_options.yaml` — fixture 디렉터리를 exclude. `example/` 은 pub workspace 멤버로 만들지 않는다

**핵심 패턴:** 구조 변경과 내용 변경을 섞지 않는다. 프리셋 분리는 `example/` 골든이 한 줄도 바뀌지 않는 리팩터링으로 끝내고, 규칙 재선정에서 골든이 바뀌는 것만 리뷰한다.

### Critical Pitfalls

상세: `.planning/research/PITFALLS.md` (19개). PITFALLS.md 는 HIGH 로 표기한 주장이 하나도 없다. 아래는 실측이나 다른 문서로 뒷받침되는 것을 우선해 골랐다.

1. **통과하지만 아무것도 증명하지 못하는 example** — 종료 코드가 아니라 기대 진단의 존재로 판정한다. 골든에 종료 코드, 이 패키지가 추가한 규칙 각 1건, 기반 세트 규칙 1건, `riverpod_lint` 1건 이상, "보고되면 안 되는" 케이스를 넣는다. 완료 기준은 "규칙 하나를 지운 커밋이 CI 에서 실패한다"를 직접 해 보는 것
2. **deprecated / removed 규칙이 조용히 죽는다** — 규칙이 실제로 적힌 프리셋 파일을 `analysis_options.yaml` 이름으로 복사해 분석하는 단계를 CI 에 둔다 `[실측: 복사 방식 동작]`. `sdk: ^3.13.0` 이 선행 조건이다 `[소스]`
3. **실측 왜곡** — 복사본에서 `woody_lints` 를 `path:` 로 덮어쓰고, 패키지 루트에서 인자 없이 `dart analyze --format=json` 을 돌리고, 기준선(1.3.0) 대비 **차이**만 규칙의 값으로 쓴다. 매 실행마다 SDK / 기반 세트 / plugin 폴더의 버전을 기록하고, 일부러 넣은 위반 2건(core lint 1 + `riverpod_lint` 1)이 보고되지 않으면 그 회차를 폐기한다. `lib/` 과 `test/` 를 나눠 집계한다 (`test/` 227개 파일이 절반 이상) `[관찰]`
4. **`main` 이 곧 배포** — 첫 작업으로 commit `90a2736` (1.3.0 내용)에 `v1.3.0` tag 를 단다. 이후 작업을 `main` 에서 할지 브랜치에서 할지는 소유자 결정이다
5. **기존 URI 의 의미 변경으로 진단이 소리 없이 사라진다** — A(묶음 유지) / B(기본만으로 변경)를 프리셋 분리 전에 명시적으로 고르고, "옛 include 한 줄" fixture 의 기대값으로 고정한다
6. **plugin 버전은 tag 로 고정되지 않는다** — 분석 서버가 뜰 때마다 `dart pub upgrade` 로 해석한다 `[문서]` `[소스]`. 같은 `^3.1.3` 선언이 같은 날 3.1.4 와 3.1.9 로 해석된 폴더가 이 머신에 공존한다 `[관찰]`. README 에 "tag 를 고정해도 바뀌는 것"을 적고, CI job 에 `timeout-minutes` 를 둔다
7. **tag 실수** — push 한 tag 는 옮기지 않는다. annotated tag 를 쓰고, tag 검사 job 과 git 의존성 기반 smoke test 를 릴리스 절차에 넣는다

## Implications for Roadmap

### 계획 전에 프로젝트 소유자가 결정할 것

연구자들이 "결정 필요"로 넘긴 항목이다. 권고는 붙였지만 어느 것도 대신 정하지 않았다.

**계획을 막는 결정 (phase 구조가 달라진다)**

| # | 결정 | 선택지 | 권고와 근거 |
|---|------|--------|-------------|
| D1 | 기존 URI `package:woody_lints/analysis_options.yaml` 의 의미 | **A.** 묶음 유지(기본 + Riverpod + codegen), 새 URI 추가 / **B.** "기본만"으로 변경 | **A.** 기존 5개 프로젝트의 이전 작업이 0 이고 묶음 파일이 루트 검증의 진입점이 된다. 대가: 규칙이 다른 이름의 파일로 옮겨 가 deprecated / removed 검사에 복사 단계가 필요하다 `[실측]`. "쓰지 않는 프로젝트가 받지 않는다"는 요구는 새 URI 로 옮긴 프로젝트만 충족한다. B 는 복사 단계가 필요 없지만 `ref: main` 프로젝트가 다음 `pub upgrade` 때 `riverpod_lint` 를 말없이 잃는다 |
| D2 | 조각 파일 이름 | `base.yaml` (ARCHITECTURE.md) / `core.yaml` (STACK.md) | 연구자 사이에 합의가 없다. 파일 이름이 곧 공개 URI 라 릴리스 후에는 바꾸기 어렵다. `lints` 의 `core.yaml` 과 뜻이 겹치지 않는 `base.yaml` 을 권한다 |
| D3 | 이번 작업을 어디에 쌓을 것인가 | (a) `main` 에서 진행하고 사용 프로젝트를 `ref: v1.3.0` 으로 먼저 고정 / (b) 브랜치에서 진행하고 릴리스 때만 합침 / (c) `main` 에서 진행하고 위험 수용 | 소유자 결정. 어느 쪽이든 `v1.3.0` tag 는 선행한다. `sdk: ^3.13.0` 으로 올린 commit 은 Dart 3.13 미만에서 해석되지 않으므로 `ref: main` 인 학습용 프로젝트(Flutter 버전 미고정)가 영향받을 수 있다. (a) 는 범위 밖인 사용 프로젝트 수정을, (b) 는 GSD 설정 `branching_strategy: none` 변경을 뜻한다 |
| D4 | `v1.3.0` tag 를 원격에 push | 한다 / 하지 않는다 | **한다.** 내용 변경이 없어 위험이 없고, "이전 SDK 프로젝트는 이전 tag 에 머문다"는 결정이 성립하려면 머물 tag 가 있어야 한다. 원격에 남는 작업이므로 소유자 확인 후 진행 |
| D5 | 검증 판정 방식 | 골든 비교 (ARCHITECTURE.md, PITFALLS.md) / `--fatal-infos` + `// ignore` + `unnecessary_ignore` + `jq` (STACK.md) | **골든 비교를 주 수단으로.** `unnecessary_ignore` 는 plugin 진단을 모르고 `[실측]`, "없어야 하는 진단"을 대조군 없이 증명하지 못한다. 저장소 루트 분석에는 `--fatal-infos` 를 그대로 쓴다 |

**해당 phase 계획 때 정하면 되는 결정**

| # | 결정 | 권고 | 필요한 시점 |
|---|------|------|-------------|
| D6 | `riverpod_lint` 를 caret(`^3.1.9`) 으로 둘지 정확한 버전으로 고정할지 | caret. 정확 고정은 `riverpod_lint` 릴리스마다 이 패키지 릴리스가 필요하고, 고정해도 plugin 의 전이 의존성은 떠다닌다 `[관찰]`. 대신 README 는 Riverpod 규칙을 하나씩 나열하지 않는다 | 프리셋 분리 |
| D7 | `invalid_annotation_target: ignore` 를 codegen 프리셋으로 옮길지 삭제할지 | D1 을 A 로 정하면 옮긴다(묶음 URI 의 의미 유지). 지금 이 설정이 필요한 경우는 "factory 생성자에 붙인 `@JsonSerializable`" 하나뿐이고 `[실측]`, `flutter_starter_kit` 의 손으로 쓴 소스에는 해당 사용이 없다 `[관찰]` | 프리셋 분리 |
| D8 | 버전 정책(semver 의 뜻)과 다음 버전 번호 | 2.0.0 (SDK 하한 상향). 정책은 두 문서가 거의 같다: URI / SDK 하한 변경은 major, 진단이 늘 수 있는 변경은 minor, 늘지 않는 변경은 patch. 차이는 "어긋나는 지점" 9번 참조. **CHANGELOG 형식은 규칙 재선정 전에 정해 둔다** — 실측 결과가 그 형식으로 바로 들어간다 | 규칙 재선정 전 |
| D9 | GSD `git.create_tag: true` 와 릴리스 tag 의 이름 공간 충돌 (`v[X.Y]` 대 `vX.Y.Z`) | 끄거나 마일스톤 버전을 패키지 버전과 맞춘다. 설정 변경은 소유자 결정 | 마일스톤 완료 전 |
| D10 | README 의 규칙 목록을 어떻게 유지할 것인가 | 네 문서의 안이 다르다: 생성 스크립트(STACK.md, LOW) / YAML 로 링크만 / 사람이 맞춤(ARCHITECTURE.md) / 마커 구역 + 비교 스크립트(PITFALLS.md). 생성까지 가지 않는 **비교 검사 하나**를 `tool/verify.dart` 에 두는 안을 권한다 | 문서 |
| D11 | `example/pubspec.lock` 을 커밋할지 | 루트 `.gitignore` 의 `pubspec.lock` 패턴이 `example/` 에도 적용된다 `[관찰]`. 커밋하면 재현성, 하지 않으면 기반 세트 변화의 조기 경보 | 검증 하네스 |
| D12 | `.fvmrc` 를 3.47.5 로 할지 3.47.7 로 할지 | 3.47.5. 실측 대상과 같은 버전이어야 한다. 3.47.7 에서 `flutter analyze` 의 plugin 누락이 고쳐졌는지는 `[미검증]` | 첫 phase |
| D13 | 규칙별 채택 여부, strict 계열, `public_member_api_docs`, `unnecessary_ignore`, import 스타일(`always_use_package_imports` 대 `prefer_relative_imports`), fire-and-forget 표기법 | 실측 결과를 보고 규칙마다 소유자가 정한다 (PROJECT.md Key Decision). 계획에는 "소유자 검토 지점"으로 넣는다 | 규칙 재선정 |
| D14 | 기본 프리셋에 `formatter:` 를 넣을지 | 넣지 않는다. 기본값이 `automate` 이고, 넣으면 버전을 올리는 순간 대량 포맷 diff 가 생긴다 `[실측]` | 규칙 재선정 |

### 문서 사이에 어긋나는 지점

아래는 어느 한쪽을 조용히 고르지 않고 그대로 적는다. "판정" 열은 근거 수준 우선순위(실측 > 소스 > 문서)를 적용한 결과이며, 판정이 없는 것은 확인이 필요하다.

| # | 주제 | 한쪽 | 다른 쪽 | 판정 |
|---|------|------|---------|------|
| 1 | `unnecessary_await_in_return` 의 상태 | deprecated. Dart 3.13.4 가 `deprecated_lint` 를 낸다. deprecated 규칙은 6개 `[실측: STACK.md, FEATURES.md]` | 3.13.4 `rules.json` 에서 `stable`. deprecated 규칙은 5개 `[소스: PITFALLS.md]` | 실측 우선: 후보에서 제외. 다만 두 값이 왜 다른지는 설명되지 않았다. 하네스의 initial-file 검사에서 한 번 더 확인한다. PITFALLS.md 의 V8(`async_return_with_no_await` 와 동시 활성)은 이 규칙을 채택하지 않으면 해당 없음 |
| 2 | 루트 분석(Tier 0)이 조각 파일의 deprecated / removed 규칙을 잡는가 | 잡는다. `included_file_warning` 으로 올라온다 `[소스 기반 설계: ARCHITECTURE.md]` | include 경유로는 보고되지 않는다 `[실측: STACK.md, FEATURES.md]` `[소스: PITFALLS.md]` | 실측 우선: ARCHITECTURE.md 의 Tier 0 설명은 이 부분이 틀렸다. 조각 파일을 `analysis_options.yaml` 이름으로 복사해 분석하는 단계가 필요하다 |
| 3 | `riverpod_lint` 진단의 심각도와 종료 코드 | `avoid_public_notifier_properties` 는 **info** 로 보고됨. JSON `type` 은 `STATIC_WARNING` `[실측: STACK.md, 규칙 1개]` | 15개 전부 `registerWarningRule` 이므로 WARNING, 위반이 있으면 종료 코드 2 `[관찰 + 추론: ARCHITECTURE.md, PITFALLS.md]`. FEATURES.md 표는 3개 규칙을 "코드에 심각도 명시 없음"으로 적었고 실측된 규칙이 그중 하나다 | 미해결. 15개 각각의 심각도는 `[미검증]` 이다. 골든에 종료 코드를 넣을 때 실제 출력으로 확정한다. "프리셋을 include 하면 exit 2" 를 README 에 단정형으로 쓰지 않는다 |
| 4 | example 검증 방식 | `dart analyze --fatal-infos` + `// ignore` + `unnecessary_ignore`, plugin 은 `jq -e` 로 확인 `[STACK.md]` | 골든 비교가 주 수단, 종료 코드도 골든에 포함 `[ARCHITECTURE.md, PITFALLS.md]` | D5 |
| 5 | 조각 파일 이름 | `lib/core.yaml` `[STACK.md]` | `lib/base.yaml` `[ARCHITECTURE.md]` | D2 |
| 6 | 작업 순서: 검증 하네스와 프리셋 분리 | `example/` + CI 는 프리셋 구조 확정이 **선행**되어야 한다 `[FEATURES.md 의존성 그래프]` | 하네스를 먼저 만들어 1.3.0 동작을 골든으로 고정한 뒤 분리한다 `[ARCHITECTURE.md, PITFALLS.md]` | 하네스 우선을 권한다. 분리가 "골든 불변"이라는 검증 가능한 완료 기준을 갖게 된다. 이 단계에서는 루트 exclude 를 유지한다 |
| 7 | 작업 순서: 프리셋 분리와 규칙 재선정 | 분리 먼저. 각 결정이 들어갈 파일이 정해져 있어야 한다 `[ARCHITECTURE.md]` | 실측은 "분리 전 단일 파일" 기준이 변수가 적다. 중복 / 주석 정리는 독립이라 가장 먼저 할 수 있다 `[PITFALLS.md, FEATURES.md]` | 분리 먼저를 권한다. 실측은 복사본에 후보 옵션 파일을 직접 두는 방식이라 저장소 구조와 무관하게 돌릴 수 있다. 두 작업을 한 변경에 섞지 않는다는 점은 모든 문서가 같다 |
| 8 | `sort_pub_dependencies` 의 fix 여부 | `hasFix` `[문서: FEATURES.md, dart.dev linter_rules.json]` | `needsFix` `[소스: PITFALLS.md, SDK tag rules.json]` | 미해결. dart.dev JSON 은 SDK main 을 따라가므로 tag 고정 소스가 더 맞을 가능성이 높다. `dart fix --dry-run` 으로 확인한다 |
| 9 | 버전 정책 세부 | 규칙 제거는 PATCH, plugin major 상향은 MAJOR `[ARCHITECTURE.md]` | `unnecessary_ignore` 를 채택했다면 규칙 제거도 minor. `flutter_lints` major 상향과 기본 심각도 승격은 major `[PITFALLS.md]` | D8. 충돌이라기보다 서로 다른 항목을 다뤘다. 합쳐서 한 표로 정하면 된다 |
| 10 | 규칙 메타데이터의 기준 출처 | SDK tag 고정 `rules.json`(262개)을 쓰고 dart.dev `linter_rules.json` 은 쓰지 말 것 `[STACK.md]` | dart.dev `linter_rules.json`(264개)을 기준으로 삼고 3.13.4 analyzer 로 교차 확인 `[FEATURES.md]` | 방법 차이. FEATURES.md 의 상태 / 도입 버전은 실측으로 교차 확인됐지만 `fixStatus` 는 그렇지 않다(8번). 규칙 재선정 때는 tag 고정 `rules.json` 을 기준으로 삼는다 |
| 11 | 커뮤니티 세트 규칙 수 | `very_good_analysis` 213, `lint` strict 183, `leancode_lint` 196, `solid_lints` 167, `pedantic_mono` 는 `flutter_lints` + 108 `[STACK.md]` | 214, 184, 197, 168, 합계 207 `[FEATURES.md]` | 미해결. 세는 방법 차이로 보이나 확인하지 않았다. 참고 수치일 뿐 결정에 영향이 없다 |
| 12 | `riverpod_lint` 3.1.9 게시일 | 2026-09-03 `[STACK.md]` | 2026-09-04 `[FEATURES.md]` | 영향 없음 (시간대 차이로 추정) |
| 13 | fixture 구성 | 2개: 전체 / base 만 `[ARCHITECTURE.md]` | 3개 이내: 기본만 / 전체 / 옛 URI 한 줄 + 재정의 3종(규칙 끄기, plugin 진단 끄기, 목록 include) `[PITFALLS.md]` | 계획 단계에서 정한다. D1 을 A 로 정하면 `example/` 이 옛 URI 한 줄을 쓰는 것으로 "전체"와 "옛 URI"를 겸할 수 있다 |

### Phase 구조 제안

### Phase 1: 기준점과 툴체인 정렬
**Rationale:** 이후 모든 검증과 실측이 지원 대상 SDK 에서 돌아야 하고, 중간 상태의 `main` 으로부터 사용 프로젝트를 보호할 기준점이 먼저 있어야 한다.
**Delivers:** commit `90a2736` 의 `v1.3.0` annotated tag (D4), `.fvmrc` 3.47.5, `.vscode/settings.json` 의 SDK 경로, `pubspec.yaml` `sdk: ^3.13.0`. 버전 정책과 CHANGELOG 형식의 틀 (D8).
**Addresses:** 지원 SDK 정렬 (FEATURES.md P1).
**Avoids:** Pitfall 17 (`main` 이 곧 배포), Pitfall 15 (툴체인 drift), Pitfall 1 의 선행 조건(deprecated 판정 기준선).
**주의:** `sdk` 하한을 올리는 commit 이 `main` 에 들어가는 시점은 D3 에 달려 있다. `fvm use` 가 Flutter 프로젝트가 아닌 루트에서 `--force` 를 요구하는지는 `[미검증]`.

### Phase 2: 검증 하네스와 CI
**Rationale:** 규칙 재선정과 프리셋 분리 모두 "fixture 기대값을 바꾸는 일"로 진행되어야 한다. `lib/` 를 바꾸기 전에 1.3.0 의 동작을 골든으로 고정한다.
**Delivers:** `example/` (독립 패키지, `path: ..`), `tool/verify.dart`, 골든 파일, 프리셋을 initial file 로 분석하는 단계, `.github/workflows/verify.yaml` (push / PR, `timeout-minutes`, `permissions: contents: read`), "`lib/` 에 Dart 소스 없음" 검사. `lib/` 는 바꾸지 않고 루트 exclude 도 유지한다.
**Uses:** `dart analyze --format=json`, `subosito/flutter-action@v2` + `.fvmrc`, `flutter pub get` (Flutter 프로젝트에서의 `dart pub get` 은 `[미검증]`).
**Implements:** ARCHITECTURE.md Pattern 3 (골든 비교), Tier 0 / Tier 1.
**Avoids:** Pitfall 1, 12, 13, 14, 15.
**이 phase 의 첫 작업으로 확인할 것:** plugin 준비 실패 시 종료 코드, JSON 의 plugin `code` 표기(15개 전부), cold runner 에서 plugin 진단이 빠짐없이 나오는지, `flutter pub get` 이 `example/analysis_options.yaml` 에 `build/**` exclude 를 추가하는 문제 `[실측: FEATURES.md]` 의 처리.
**완료 기준 (직접 해 볼 것):** 규칙 하나를 지운 커밋, include 줄을 지운 example, deprecated 규칙을 넣은 프리셋, 존재하지 않는 plugin 버전이 각각 CI 에서 실패한다.

### Phase 3: 프리셋 분리
**Rationale:** 구조 변경을 내용 변경과 분리한다. 하네스가 있으므로 "`example/` 골든이 한 줄도 바뀌지 않는다"가 완료 기준이 된다.
**Delivers:** 기본 / Riverpod / codegen 조각, 묶음 파일로 바뀐 `lib/analysis_options.yaml` (D1 이 A 일 때), `riverpod_lint` 하한 `^3.1.9` (D6), 루트 exclude 를 fixture 디렉터리로 교체, 대조군 fixture, 재정의 fixture.
**Implements:** ARCHITECTURE.md Pattern 1, 2, 4.
**Avoids:** Pitfall 8, 9, 10, 11, 6 (exclude / ignore 의 위치).
**이 phase 의 첫 작업으로 확인할 것:** STACK.md 가 scratch 에서 확인한 include 경유 plugin 로드와 `plugins_in_inner_options` 소멸을 **이 저장소의 실제 구조에서** 재현. 통과하지 못하면 ARCHITECTURE.md 의 3 안(plugin 을 패키지에서 빼고 README 로 안내)으로 가며, 이 경우 URI 의 의미가 바뀐다.

### Phase 4: 규칙 재선정
**Rationale:** 각 결정이 들어갈 파일이 정해진 뒤에 한다. 골든 diff 가 규칙별 변화의 기록이 되고, 실측 결과가 CHANGELOG 의 "새로 생기는 진단" 절로 바로 들어간다.
**Delivers:** 조건 기록과 sanity check 를 갖춘 실측 스크립트, `flutter_starter_kit` 복사본 실측 결과(규칙별, `lib/` / `test/` / 생성물별, `dart fix --dry-run` 건수), 규칙별 결정 기록, 중복 선언 6개와 주석 3개 삭제, 사실에 맞게 고친 사유 주석(const 규칙, `always_declare_return_types`), 끈 규칙과 사유 목록.
**Addresses:** FEATURES.md B-1, B-2, B-3, B-5 후보 + strict 3종(lint 형태 2개 + `strict-inference`). B-4 와 B-6, B-7 은 실측 대상이 아니다.
**Avoids:** Pitfall 2, 3, 4, 5, 6, 7.
**주의:** 평가표의 열을 고정한다 — `state` / 심각도 / `fixStatus` / 실측 건수 / `dart fix` 가능 건수 / 상류 세트 포함 여부와 제거 이력. 하나라도 비면 결정하지 않는다. 양립 불가 쌍은 한쪽씩 나눠 돌린다. 규칙별 결정은 소유자 검토 지점이다 (D13).

### Phase 5: 문서
**Rationale:** 최종 YAML 과 최종 버전 번호가 있어야 쓸 수 있다. 도구 동작 서술은 fixture 로 뒷받침되는 것만 단정형으로 쓴다.
**Delivers:** README (설치, 프로젝트 유형별 복사용 블록, 재정의, 버전 올리기, "tag 를 고정해도 바뀌는 것", 문제 해결), CHANGELOG 2.0.0, YAML 머리 주석, README ↔ YAML 일치 검사 (D10).
**Avoids:** Pitfall 19, 18.
**빠지기 쉬운 것:** exclude 는 사용 프로젝트에서 되돌릴 수 없다는 사실, plugin 진단 재정의 시 `version` 필수, `dev_dependencies` 의 `riverpod_lint` 제거, plugin 변경 후 Analysis Server 재시작, 버전 올리기는 `pub upgrade` 가 아니라 `ref:` 수정 + `pub get` (현재 README 는 `pub upgrade` 를 안내한다), `ref: main` 프로젝트가 받는 영향.

### Phase 6: 릴리스
**Rationale:** README 의 `ref: v2.0.0` 예시가 실제로 존재하는 tag 를 가리키게 되는 마지막 단계다.
**Delivers:** workflow 의 tag 트리거와 버전 일치 검사, `v2.0.0` annotated tag, `git ls-remote --tags origin` 확인, 빈 프로젝트에서 git 의존성으로 받는 smoke test.
**Avoids:** Pitfall 16, 18.
**주의:** smoke test 가 "git 의존성으로 가져온 프리셋의 `plugins:` 동작"(`path:` 로만 확인됨)을 처음 확인하는 자리다. D9 를 이 phase 전에 정한다.

### Phase Ordering Rationale

- `v1.3.0` tag 가 맨 앞이다. 5분 작업이고 내용 변경이 없으며, 없으면 이후 모든 중간 커밋이 보호 없이 배포된다.
- 하네스가 분리와 재선정보다 앞선다. 세 연구 문서 중 둘이 이 순서를 권했고, FEATURES.md 의 반대 의존성(구조 확정 후 example)은 "1.3.0 을 먼저 고정한다"는 접근으로 해소된다 (어긋나는 지점 6번).
- 분리와 재선정은 섞지 않는다. 골든이 바뀐 이유가 "파일을 옮겨서"인지 "규칙을 바꿔서"인지 구분되어야 한다.
- 문서는 YAML 이 확정된 뒤, 릴리스는 문서가 가리키는 tag 를 만드는 마지막 단계다.
- 버전 정책과 CHANGELOG 형식만은 Phase 1 로 당긴다. Phase 4 의 실측 결과가 그 형식으로 들어간다.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (검증 하네스):** 문헌 조사가 아니라 **실행 확인**이 필요하다. plugin 실패 시 종료 코드, cold runner 동작, `riverpod_lint` 진단의 실제 심각도는 어느 문서도 확인하지 못했다. 계획에 스파이크 작업을 첫 항목으로 넣는다.
- **Phase 3 (프리셋 분리):** 핵심 동작이 문서화되지 않았고 SDK 에서 바뀌는 중이다. 이 저장소 구조에서의 재현이 통과하지 못하면 설계가 3 안으로 바뀐다. pub workspace 멤버 패키지에서의 동작과 plugin 내부 `riverpod` 버전 불일치는 README 호환 범위를 쓰기 전에 조사할지 결정한다.
- **Phase 4 (규칙 재선정):** 후보 목록과 메타데이터는 충분하다. 추가 조사가 아니라 실측이 필요하다. `migrate_design_widgets` 를 실측 대상에 넣으려면 별도 조사가 선행되어야 하나, v2+ 로 미루는 것을 권한다.

Phases with standard patterns (skip research-phase):
- **Phase 1:** `.fvmrc`, SDK 제약, annotated tag. 확립된 작업이다.
- **Phase 5 (문서):** 넣을 내용이 연구 문서에 이미 표로 정리되어 있다.
- **Phase 6 (릴리스):** 절차가 ARCHITECTURE.md F 항목과 PITFALLS.md Pitfall 16 에 단계별로 적혀 있다.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | 핵심 주장 대부분을 Dart 3.13.4 에서 직접 실행했다. 미검증 항목은 문서 안에 따로 표시되어 있다. plugin 버전 해석과 strict 옵션 판단은 MEDIUM, README 동기화 도구는 LOW |
| Features | MEDIUM | 규칙 상태 / 충돌 / 사각지대는 실측. 출처 등급상 HIGH 는 없다. **규칙별 소음 등급은 전부 추정**이고 `fixStatus` 는 실측으로 교차 확인되지 않았다 |
| Architecture | MEDIUM | 연구 단계에서 실행 실험을 하지 않았다. 병합 규칙과 plugin 로드 경로는 소스 읽기 수준. 핵심 전제(V1, V2, V3)는 STACK.md / FEATURES.md 실측으로 뒷받침되지만 Tier 0 의 범위는 실측과 어긋난다 |
| Pitfalls | MEDIUM | HIGH 로 표기한 주장이 없다. 소스 / 문서 / issue 기반이고 12개 항목을 "실측 필요"로 남겼다. `flutter analyze` 의 plugin 누락은 STACK.md 실측과 일치한다 |

**Overall confidence:** MEDIUM

방향(기반 세트 유지, 조각 프리셋, 골든 검증, tag 릴리스)에 대한 확신은 높다. 낮은 것은 (1) 규칙별 실제 진단 수, (2) 실측되지 않은 plugin 관련 세부 동작, (3) 다음 SDK 에서의 변화다.

### Gaps to Address

**다른 문서의 실측으로 해소된 "검증 필요" 항목** — scratch 패키지 기준이며 이 저장소에서의 재현은 남아 있다.

| 원래 항목 | 해소 근거 |
|-----------|-----------|
| 다른 이름의 프리셋 파일에 둔 `plugins:` 가 include 경유로 로드되는가, 2단 include 에서도 되는가 (ARCHITECTURE V1, PITFALLS V1) | 로드됨 `[실측: STACK.md. FEATURES.md 는 목록 include 로 독립 확인]` |
| 그 구조에서 저장소 루트의 `plugins_in_inner_options` 가 사라지는가 (ARCHITECTURE V2, PITFALLS V2) | 사라짐 `[실측: STACK.md]` |
| 패키지 프리셋의 `**/*.g.dart` exclude 가 사용 프로젝트에 적용되는가 (ARCHITECTURE V3) | 적용되고 로컬 exclude 와 합쳐짐 `[실측: STACK.md, FEATURES.md]` |
| plugin 진단 하나를 끄는 방법, warning 규칙이 `false` 로 꺼지는가 (ARCHITECTURE V5, PITFALLS V5) | `version` + `diagnostics: {rule: false}` 로 꺼짐. `version` 을 빼면 꺼지지 않음 `[실측: STACK.md, FEATURES.md]` |
| `dart format` 이 `package:` include 의 `formatter:` 를 따르는가 (ARCHITECTURE V6) | 따름 `[실측: STACK.md, FEATURES.md]` |
| `// ignore: riverpod_lint/<code>` 가 동작하는가 (FEATURES.md 는 실행하지 않음) | 접두사가 있으면 억제됨, 없으면 안 됨 `[실측: STACK.md]` |
| JSON 의 plugin `code` 에 접두사가 붙는가 (ARCHITECTURE V4, PITFALLS V4) | 붙지 않음 `[실측: STACK.md, 규칙 1개]`. 나머지 14개는 미확인 |

**계획을 막는 미해결 항목** — 해당 phase 의 첫 작업으로 확인한다.

- 이 저장소의 실제 구조에서 include 경유 plugin 로드와 루트 경고 소멸이 재현되는가 — Phase 3 첫 작업. 실패 시 설계 변경
- plugin 준비 실패 + 다른 진단 존재 시 `dart analyze` 종료 코드 (4 가 아닐 것으로 읽힘 `[소스]`) — Phase 2. 골든 판정 로직이 여기에 달려 있다
- `riverpod_lint` 15개 규칙 각각의 심각도와 그에 따른 종료 코드 — Phase 2. 어긋나는 지점 3번
- GitHub Linux runner 의 cold 실행에서 plugin 진단이 빠짐없이 나오는지, 첫 실행 시간, workflow 전체의 실제 동작 — Phase 2. 로컬은 11초 / 2초 `[실측]`
- `dart analyze <dir>` 가 plugin 진단을 잃는 문제 `[이슈: flutter#193203, sdk#62710. 로컬 미재현]` — Phase 2. fixture 를 작업 디렉터리로 두고 인자 없이 실행하면 피할 수 있다
- 3.13 신규 규칙이 language version 3.11 프로젝트(`flutter_starter_kit` 의 SDK 제약은 `^3.11.1`)에서 보고되는가 — Phase 4. 0 건의 뜻이 달라진다
- `flutter_starter_kit` 에 이미 있는 `// ignore` 주석(`cast_nullable_to_non_nullable` 56, `discarded_futures` 2 등 `[관찰]`)의 경위 — Phase 4 실측 전. 프로젝트 자체 옵션이 기준선에 섞이는지 확인

**릴리스 전까지 확인하면 되는 항목**

- git 의존성으로 가져온 프리셋의 `plugins:` 동작 (`path:` 로만 확인) — Phase 6 smoke test
- plugin 이 `analyzer.exclude` 와 `// ignore_for_file` 을 존중하는가 — Phase 3
- `sort_pub_dependencies` 등 `hasFix` 규칙이 `dart fix --apply` 로 일괄 적용되는가 — Phase 4
- `unnecessary_await_in_return` 의 상태 불일치 원인 — Phase 2 의 initial-file 검사에서 드러난다
- `analyzer.errors` 로 `invalid_annotation_target` 을 되살릴 때의 기본 심각도 — Phase 5 전
- pub workspace 멤버 패키지에서 Riverpod 프리셋 include 시 plugin 로드 여부 — README 에 적을지 판단용
- plugin 내부 `riverpod` 버전과 사용 프로젝트 `riverpod` major 가 다를 때의 진단 — README 호환 범위용
- `fvm use` 의 `--force` 필요 여부, Flutter 프로젝트인 `example/` 에서의 `dart pub get` 동작

**이번 마일스톤에서 확인하지 않아도 되는 항목** — 신뢰도를 올리지 않고 기록만 남긴다.

- include 된 파일의 `plugins:` 가 다음 SDK 에서도 허용되는가. 문서화되지 않은 동작이고 관련 설계가 진행 중이다 `[이슈: sdk#62451, #63627, #61481]`. 대응: fixture 가 감시하고, SDK minor 마다 다시 확인한다
- Dart 3.14 의 `analyzer.exclude` 기준 디렉터리 변경 `[소스: SDK main commit 7c44c48, 3.13.4 미포함]`. 릴리스되면 패키지 프리셋의 `**/*.g.dart` 가 사용 프로젝트 파일을 제외하지 못할 가능성이 있다. 대응: 고의 위반을 담은 `*.g.dart` fixture 로 고정하고, README 에 "exclude 는 프로젝트 루트 파일에도 직접 두는 것이 안전하다"를 적는다
- `flutter analyze` 의 plugin 누락이 3.47.7 에서 고쳐졌는가
- `strict-casts` / `strict-raw-types` 옵션의 제거 시점, legacy plugin 시스템이 완전히 비활성화되는 SDK 버전
- `include:` 목록 문법과 strict 옵션들의 도입 버전 (지원 SDK 가 3.13 이상이라 영향 없음)
- primary constructor 규칙의 `dart fix` 결과가 freezed / riverpod_generator 코드와 호환되는가, `migrate_design_widgets` 의 대체 패키지
- Riverpod 미사용 프로젝트에서 plugin 로드가 분석 시간에 주는 영향
- tag 를 옮긴 뒤 옛 lockfile 로 새 머신에서 `pub get` 이 되는가 (원칙상 하지 않을 일)
- README 동기화용 기성 도구의 존재 (웹 검색 1회로 찾지 못함), 다른 생태계 linter 의 semver 정책 비교 (원문 미확인), dart-lang/lints#205 의 const 규칙 제거 사유 원문 (API 조회 실패. `flutter_lints` CHANGELOG 의 참조만 확인)

## Sources

### Primary (HIGH confidence)
- 로컬 실측, Flutter 3.47.5 / Dart 3.13.4, 2026-10-11, scratch 패키지 (STACK.md, FEATURES.md) — `dart analyze` 종료 코드와 출력 형식, include 경유 `plugins:` / `exclude` / `formatter:` 전파, deprecated / removed 검출 사각지대, plugin 진단 억제 방법, `require_trailing_commas` 의 language 3.7 gate, strict 옵션과 대체 lint 비교, `invalid_annotation_target` × `json_annotation` 4.12.0, Dart 3.13 신규 규칙의 최소 샘플 적용
- 패키지 원본 (로컬 pub cache, pub.dev archive) — `lints` 6.1.0, `flutter_lints` 6.0.0, `riverpod_lint` 3.1.9 (`lib/main.dart`, CHANGELOG, pubspec), `very_good_analysis` 11.0.0 외 커뮤니티 세트 6종의 YAML
- pub.dev API, GitHub releases API, Flutter release manifest — 버전, 게시일, SDK 제약, action 버전
- https://raw.githubusercontent.com/dart-lang/sdk/3.13.4/pkg/linter/tool/machine/rules.json — 규칙 `state` / `incompatible` / `fixStatus`

### Secondary (MEDIUM confidence)
- Dart SDK tag `3.13.4` 소스 직접 열람, **실행 검증 아님** (ARCHITECTURE.md, PITFALLS.md) — `analysis_options_parser.dart` (키별 병합), `analysis_options_parse_model.dart` (`plugins_in_inner_options` 조건, deprecated / removed 보고 조건), `context_locator.dart` (exclude 기준, nested context root), `dartdev/commands/analyze.dart` (종료 코드, JSON 형식), `plugin_manager.dart` (plugin 폴더, `pub upgrade`), `ignore_validator.dart`
- 공식 문서, Context7 `/dart-lang/site-www` 교차 확인 — https://dart.dev/tools/analysis , https://dart.dev/tools/analyzer-plugins , https://dart.dev/tools/dart-analyze , https://dart.dev/tools/pub/dependencies , `analysis_server_plugin/doc/using_plugins.md`
- SDK / `lints` / `flutter_lints` / `riverpod_lint` / dart_style CHANGELOG — 3.13 의 strict 대체 lint, `lints` 7.0.0-wip, `flutter_lints` 5.0.0 의 const 규칙 제거
- GitHub issue 원문 — flutter#193203, flutter#187999, sdk#62710, sdk#63787, sdk#61481, sdk#63627, sdk#62164, sdk#63864, riverpod#4839
- 로컬 읽기 전용 관찰 — `~/.dartServer/.plugin_manager/` 의 합성 패키지와 lockfile, `flutter_starter_kit` 의 `pubspec.lock` / `analysis_options.yaml` / 파일 수 / `ignore` 주석 집계, gsd-core 의 `complete-milestone` 동작

### Tertiary (LOW confidence)
- https://raw.githubusercontent.com/dart-lang/site-www/main/src/data/linter_rules.json — SDK main 을 따라가 3.14 규칙과 미릴리스 세트 정보가 섞여 있다. `fixStatus` 는 tag 고정 소스로 다시 확인할 것
- FEATURES.md 의 규칙별 "소음" 등급 — 전부 추정. 실측으로 대체
- 웹 검색 — README 규칙 표 생성 도구 (찾지 못함), 다른 생태계 linter 의 semver 정책 (원문 미확인)
- `very_good_analysis` README 의 제외 표 — 실제 YAML 과 두 군데 어긋난다. 참고용으로만

---
*Research completed: 2026-10-11*
*Ready for roadmap: yes — 단, D1 ~ D5 는 roadmap 확정 전에 소유자 결정이 필요하다*
