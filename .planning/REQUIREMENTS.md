# Requirements: woody_lints

**Defined:** 2026-10-11
**Core Value:** 사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.

## v1 Requirements

이번 릴리스(새 버전 tag)에 들어가는 요구사항. 각 항목은 roadmap 의 phase 하나에 대응한다.

용어: "사용 프로젝트"는 이 패키지를 `include` 하는 Flutter 프로젝트, "소유자"는 이 패키지의 작성자 본인이다. 새 버전 번호는 BASE-03 의 버전 정책으로 확정한다 (조사 권고는 2.0.0).

### 기준점·툴체인 (BASE)

- [x] **BASE-01**: 저장소가 고정하는 SDK 가 Flutter 3.47.5 / Dart 3.13.4 다 (`.fvmrc`, `.vscode/settings.json`)
- [x] **BASE-02**: `pubspec.yaml` 의 SDK 하한이 `^3.13.0` 이어서, 지원하지 않는 SDK 를 쓰는 프로젝트는 `pub get` 단계에서 버전 불일치로 명확히 실패한다
- [x] **BASE-03**: 어떤 변경이 major / minor / patch 인지 정한 버전 정책이 문서로 남아 있다
- [x] **BASE-04**: CHANGELOG 항목의 형식이 정해져 있다 (추가·삭제 규칙, 지원 SDK, 새로 생기는 진단)

### 검증 (VERIFY)

- [x] **VERIFY-01**: 저장소 안의 `example/` 프로젝트가 배포 설정을 include 하고, 기대한 진단(이 패키지가 추가한 규칙, 기반 세트 규칙, `riverpod_lint` 진단)이 실제로 보고되는지를 커밋된 기대 진단 파일과 비교해 판정한다
- [x] **VERIFY-02**: 규칙이 적힌 배포 파일에 deprecated / removed / 존재하지 않는 규칙이 있으면 검증이 실패한다
- [x] **VERIFY-03**: 소유자는 로컬에서 명령 하나로 전체 검증을 실행할 수 있다
- [x] **VERIFY-04**: GitHub Actions 가 push 와 PR 마다 로컬과 같은 검증을 실행하며, 시간 제한이 걸려 있다
- [x] **VERIFY-05**: `base.yaml` 만 include 한 대조군 fixture 에서 Riverpod / codegen 설정이 적용되지 않음을 확인한다
- [x] **VERIFY-06**: README 의 규칙 목록이 실제 YAML 과 다르면 검증이 실패한다
- [x] **VERIFY-07**: `lib/` 에 `.dart` 파일이 있으면 검증이 실패한다
- [x] **VERIFY-08**: 검증이 실제로 문제를 잡아냄이 확인되어 있다 — 규칙 하나를 지운 변경과 include 줄을 지운 변경이 각각 검증에서 실패한다

### 프리셋 (PRESET)

- [x] **PRESET-01**: 사용 프로젝트는 `package:woody_lints/base.yaml` 만 include 해서, Riverpod plugin 과 codegen 설정 없이 기본 규칙만 받을 수 있다
- [x] **PRESET-02**: 사용 프로젝트는 `package:woody_lints/riverpod.yaml` 을 include 해서 `riverpod_lint` plugin 을 받을 수 있다
- [x] **PRESET-03**: 사용 프로젝트는 `package:woody_lints/codegen.yaml` 을 include 해서 코드 생성 관련 설정(생성 파일 제외 등)을 받을 수 있다
- [x] **PRESET-04**: 기존 `package:woody_lints/analysis_options.yaml` 한 줄만 쓰는 프로젝트는 프리셋 분리 전과 같은 구성(기본 + Riverpod + codegen)을 받는다
- [x] **PRESET-05**: `riverpod_lint` plugin 의 버전 하한이 `^3.1.9` 다
- [x] **PRESET-06**: 저장소 루트 분석이 배포 파일을 분석 대상에서 제외하지 않고도 경고 없이 통과한다
- [x] **PRESET-07**: 사용 프로젝트에서 규칙 하나를 끄는 방법과 plugin 진단 하나를 끄는 방법이 README 에 적힌 대로 동작함이 fixture 로 확인되어 있다
- [x] **PRESET-08**: 사용 프로젝트는 묶음의 정식 이름 `package:woody_lints/recommended.yaml` 한 줄로 기본 + Riverpod + codegen 구성을 받을 수 있고, 옛 URI 로 받는 구성과 같다

### 규칙 (RULES)

- [x] **RULES-01**: 기반 세트와 중복되는 선언 6개가 삭제되어, 배포 파일에는 이 패키지가 실제로 추가하는 규칙만 적혀 있다
- [x] **RULES-02**: 주석 처리된 설정 3개(`require_trailing_commas`, `public_member_api_docs`, `formatter: trailing_commas`)가 배포 파일에서 삭제되어 있다
- [x] **RULES-03**: 소유자는 후보 규칙(버그 방지, 성능, 가독성·스타일)마다 `flutter_starter_kit` 복사본에서 잰 진단 건수와 `dart fix` 로 고칠 수 있는 건수를 표로 볼 수 있다
- [x] **RULES-04**: strict 계열(`no_dynamic_casts`, `no_raw_types`, `strict-inference`)이 같은 실측 표에 포함되어 있다
- [x] **RULES-05**: 실측 결과를 믿을 수 있다 — 회차마다 SDK / 기반 세트 / plugin 버전이 기록되고, 일부러 넣은 위반이 보고된 회차의 수치만 쓴다
- [x] **RULES-06**: 후보 규칙마다 소유자가 채택 여부를 결정했고, 그 결정이 배포 파일에 반영되어 있다
- [x] **RULES-07**: 남기는 규칙의 사유 주석이 사실과 일치한다
- [x] **RULES-08**: 채택하지 않은 규칙과 그 사유가 목록으로 남아 있다

### 문서 (DOCS)

- [x] **DOCS-01**: 소유자는 README 만 보고 새 프로젝트에 이 패키지를 `ref: vX.Y.Z` 로 추가할 수 있다
- [x] **DOCS-02**: README 에 프로젝트 유형별로 복사해 쓸 include 블록이 있다 (전체 / 기본만 / 기본 + Riverpod 등)
- [x] **DOCS-03**: README 에 규칙을 한 줄 / 파일 / 프로젝트 단위로 끄는 방법과 plugin 진단을 끄는 방법이 있다
- [x] **DOCS-04**: README 에 버전을 올리는 방법(`ref:` 수정과 `pub get`)과 `ref: main` 에서 tag 로 옮기는 방법이 있다
- [x] **DOCS-05**: README 에 문제 해결 섹션이 있다 (plugin 경고가 안 보일 때, Analysis Server 재시작, `dart analyze` 와 `flutter analyze` 의 차이, tag 를 고정해도 바뀌는 것)
- [x] **DOCS-06**: README 의 규칙·설정 설명이 실제 YAML 과 일치한다 (현재의 불일치 2건과 기재되지 않은 설정 해소)
- [x] **DOCS-07**: CHANGELOG 에 새 릴리스 항목이 있다 (추가·삭제 규칙, 지원 SDK 변경)
- [x] **DOCS-08**: CHANGELOG 의 1.0.0 과 1.3.0 사이 누락이 git 이력에서 확인되는 범위로 보완되어 있다
- [x] **DOCS-09**: CHANGELOG 새 릴리스 항목에 새로 생기는 진단 안내가 있다 (규칙별 실측 건수, `dart fix` 가능 여부)
- [x] **DOCS-10**: 배포 YAML 의 머리 주석이 실제 구성을 설명하고, README 와 YAML 에 남은 템플릿 보일러플레이트가 제거되어 있다
- [x] **DOCS-11**: 켠 규칙마다 이유와 실측 건수를 적은 근거 문서가 있다

### 릴리스 (REL)

- [x] **REL-01**: 1.3.0 내용의 커밋에 `v1.3.0` tag 가 있고 원격에 올라가 있다
- [ ] **REL-02**: 새 버전의 annotated tag 가 원격에 있어, 사용 프로젝트가 `ref: vX.Y.Z` 로 버전을 고정할 수 있다
- [ ] **REL-03**: tag, `pubspec.yaml` 의 version, CHANGELOG 최상단 버전이 서로 다르면 CI 가 실패한다
- [ ] **REL-04**: 릴리스 직후 빈 프로젝트에서 새 tag 를 git 의존성으로 받아, 기본 규칙 진단과 `riverpod_lint` plugin 진단이 보고됨을 확인한다

## v2 Requirements

다음 릴리스 이후로 미룬 항목. 기록만 하고 이번 roadmap 에는 넣지 않는다.

### 프리셋

- **PRESET-09**: `public_member_api_docs` 를 켜는 선택형 문서화 프리셋(`docs.yaml`)

### 규칙

- **RULES-09**: API 문서 규칙(`public_member_api_docs` 등) 실측
- **RULES-10**: Dart 3.13 primary constructor 전환 규칙 검토 — freezed / riverpod_generator 코드와의 호환 확인 후
- **RULES-11**: `migrate_design_widgets` 검토 — 대체 패키지와 이전 가능 여부 조사 후
- **RULES-12**: experimental 규칙 재검토 — stable 로 전환되면
- **RULES-13**: `lints` 7.0.0 / `flutter_lints` 7 대응 — 기반 세트로 들어오는 규칙의 중복 선언 제거
  - 재측정 전에 먼저 고칠 것: 측정 도구 `tool/measure_rules.dart` 가 "지금 켜 둔 규칙" 을 1.3.0 의 6개(`currentRules`)로 박아 두어, 지금 저장소(`lib/base.yaml` 81개)에서 다시 재면 2.0.0 에서 켠 규칙이 기준선 B0 에 섞여 0줄로 나온다 — 기준선을 어떻게 잡을지 설계부터 정한다 (04-REVIEW.md CR-03; 소유자 결정 2026-10-13 — v2 메모로 남김; 지금 커밋된 R1 값에는 영향 없음 — R1 때 `lib/base.yaml` 은 6개였다)
  - 재측정 전에 먼저 고칠 것: `--recount` 가 `fixSkipped` 를 원인을 확인하지 않고 R1 전용 문장으로 적고, `measureFix` 가 잴 때 그것을 지우지 않으며, `fixCell` 이 `fixRemoved` 보다 `fixSkipped` 를 먼저 본다 — fix 단계가 죽은 결과(WR-08 꼴)에 `--recount --write` 를 돌리면 사실이 아닌 사유가 붙고 `--report` 단언 (2) 를 우회해 `--summary` 의 권고가 뒤집힌다; 원인이 확인될 때만 적고, 잴 때 지우고, 잰 값을 먼저 보게 CR-03 과 함께 고친다 (04-REVIEW.md WR-09; 소유자 결정 2026-10-13 — v2 메모로 남김; 지금 커밋된 R1 값에는 영향 없음 — `fixSkipped` 가 붙은 행은 `sort_pub_dependencies` 하나이고 그 문장은 사실이다)

## Out of Scope

명시적으로 제외한 것. 다시 끼워 넣지 않도록 사유를 적는다.

| Feature | Reason |
|---------|--------|
| 사용 프로젝트에 새 버전을 적용하고 경고를 정리하는 일 | 소유자가 원하는 시점에 따로 한다. 완료 기준은 패키지 릴리스까지다 |
| pub.dev 게시 | 개인 사용 목적이며 `publish_to: 'none'` 을 유지한다 |
| 영어 README | 독자가 소유자 본인이다 |
| Dart 3.13 미만 지원 | 최신 stable 만 지원한다. 이전 SDK 프로젝트는 `v1.3.0` tag 에 머문다 |
| "전부 켜고 일부만 끄기" 방식 | SDK 가 올라갈 때마다 새 규칙이 예고 없이 들어온다. 규칙마다 근거를 남긴다는 원칙과 충돌한다 |
| 버전별 / SDK 별 옵션 파일 | git tag 로 고정하면 파일을 복제하지 않고 같은 효과를 얻는다 |
| 자체 custom lint 규칙 | Dart 코드와 테스트가 필요해져 설정 전용 패키지라는 성격이 바뀐다 |
| 기본 프리셋의 `formatter:` 설정 | include 된 `formatter:` 가 사용 프로젝트의 `dart format` 결과를 바꿔, 버전을 올리면 대량의 포맷 변경이 생긴다 |
| lint 를 일괄 warning / error 로 승격 | 새 규칙 하나가 모든 사용 프로젝트의 CI 를 막는다. 엄격도는 사용 프로젝트가 정한다 |
| experimental 규칙 활성화 | 동작과 이름이 바뀔 수 있다 |

## Traceability

어느 phase 가 어느 요구사항을 다루는지. roadmap 을 만들 때 채운다.

| Requirement | Phase | Status |
|-------------|-------|--------|
| BASE-01 | Phase 1 | Complete |
| BASE-02 | Phase 1 | Complete |
| BASE-03 | Phase 1 | Complete |
| BASE-04 | Phase 1 | Complete |
| VERIFY-01 | Phase 2 | Complete |
| VERIFY-02 | Phase 2 | Complete |
| VERIFY-03 | Phase 2 | Complete |
| VERIFY-04 | Phase 2 | Complete |
| VERIFY-05 | Phase 3 | Complete |
| VERIFY-06 | Phase 5 | Complete |
| VERIFY-07 | Phase 2 | Complete |
| VERIFY-08 | Phase 2 | Complete |
| PRESET-01 | Phase 3 | Complete |
| PRESET-02 | Phase 3 | Complete |
| PRESET-03 | Phase 3 | Complete |
| PRESET-04 | Phase 3 | Complete |
| PRESET-05 | Phase 3 | Complete |
| PRESET-06 | Phase 3 | Complete |
| PRESET-07 | Phase 3 | Complete |
| PRESET-08 | Phase 3 | Complete |
| RULES-01 | Phase 4 | Complete |
| RULES-02 | Phase 4 | Complete |
| RULES-03 | Phase 4 | Complete |
| RULES-04 | Phase 4 | Complete |
| RULES-05 | Phase 4 | Complete |
| RULES-06 | Phase 4 | Complete |
| RULES-07 | Phase 4 | Complete |
| RULES-08 | Phase 4 | Complete |
| DOCS-01 | Phase 5 | Complete |
| DOCS-02 | Phase 5 | Complete |
| DOCS-03 | Phase 5 | Complete |
| DOCS-04 | Phase 5 | Complete |
| DOCS-05 | Phase 5 | Complete |
| DOCS-06 | Phase 5 | Complete |
| DOCS-07 | Phase 5 | Complete |
| DOCS-08 | Phase 5 | Complete |
| DOCS-09 | Phase 5 | Complete |
| DOCS-10 | Phase 5 | Complete |
| DOCS-11 | Phase 4 | Complete |
| REL-01 | Phase 1 | Complete |
| REL-02 | Phase 6 | Pending |
| REL-03 | Phase 6 | Pending |
| REL-04 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 43 total
- Mapped to phases: 43
- Unmapped: 0 ✓

---
*Requirements defined: 2026-10-11*
*Last updated: 2026-10-11 after bundle naming decision (PRESET-08 추가)*
