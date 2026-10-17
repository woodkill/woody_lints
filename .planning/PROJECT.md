# woody_lints

## What This Is

`woody_lints` 는 Flutter 프로젝트의 `analysis_options.yaml` 에서 `include:` 한 줄로 끌어다 쓰는 설정 전용 패키지(configuration-only package)다. Dart 코드는 없고 `lib/` 의 YAML 이 배포 산출물이며, 작성자 본인의 Flutter 프로젝트들이 Git 의존성으로 가져다 쓴다. 2.0.0 (tag `v2.0.0`, 2026-10-16 `main` 병합)부터는 조각 셋(`base.yaml` · `riverpod.yaml` · `codegen.yaml`), 묶음 `recommended.yaml`, 옛 주소 별칭 `analysis_options.yaml` 의 다섯 파일이다 (Phase 3 · Phase 6).

v2.0 마일스톤(2026-10-11 ~ 10-17)에서 "잘 모르던 시절에 만든" 이 패키지를 지금 기준으로 다시 다듬어 2.0.0 으로 릴리스했다.

## Core Value

사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.

v2.0 뒤 다시 봐도 그대로다 — 검증 명령이 문서와 설정의 일치를 지키게 되었고, 다음 일도 이 가치를 지키는 쪽(버전 판정 문구, 측정 도구 정비)이다.

## Current State

**배포된 버전: 2.0.0** — annotated tag `v2.0.0` (`704bf56`), `main` 병합 PR #1 (2026-10-16), 저장소 안쪽 gap 수정 PR #2 · #3 (`main` = `3418989`). v2.0 마일스톤은 2026-10-17 에 `tech_debt` 판정(막는 문제 0, 받는 쪽 영향 0)을 받아들이고 마감했다 — `.planning/MILESTONES.md`, `.planning/milestones/v2.0-*`.

- **배포 파일 (`lib/`, YAML 5개):** 조각 `base.yaml` (규칙 81개, 모두 info) · `riverpod.yaml` (`riverpod_lint: ^3.1.9`) · `codegen.yaml` (생성 파일 제외 · `invalid_annotation_target`), 묶음 `recommended.yaml`, 옛 주소 별칭 `analysis_options.yaml`
- **지원 SDK:** `sdk: ^3.13.0`, 저장소 고정 Flutter 3.47.5 (`.fvmrc`). 3.13 미만은 `ref: v1.3.0`
- **검증:** `tool/verify.dart` 10단계 (연습용 프로젝트 여섯 — `example/` + `fixtures/` 다섯), GitHub Actions `verify.yml` 이 push · PR · 수동 실행에서 같은 명령을 돈다. 릴리스 확인 `tool/smoke.dart` 는 손으로 돌린다
- **근거 문서:** `RULES.md` (켠 규칙 · 켜지 않은 규칙과 사유, 실측 회차 R1), `VERSIONING.md` (등급 판정 · 릴리스 절차), `CHANGELOG.md` (1.0.0 ~ 2.0.0), `README.md` (설치 · 프리셋 · 끄기 · 버전 올리기)
- **사용 프로젝트:** 5개 모두 아직 `ref: main` — 다음 `pub upgrade` 때 2.0.0 을 받는다. 적용과 경고 정리는 소유자가 따로 한다 (Out of Scope)

## Next Milestone Goals

아직 정하지 않았다 — `/gsd-new-milestone` 에서 고른다. 후보 (v2.0 감사 · Backlog · v2 요구사항에서):

- **버전 판정 문구 다시 쓰기:** `VERSIONING.md` 판정 순서 · 기준표 (01:WR-03 · 06 ~ 10, Backlog 999.1 · 999.3) — 다음 minor · patch 를 매기기 전에
- **에이전트 지시 문서 갱신:** `.claude/CLAUDE.md` 가 1.3.0 시절 서술을 지시로 담고 있다 (05:WR-06) — `/gsd-map-codebase` 로 다시 만든다
- **도구 손질:** `tool/verify.dart` 안내 · 가드 (02:WR-01 · 04 · 05 · 06, 03:WR-04), fixture `lib/` 복사본 검사 (03:WR-06), workflow action SHA 고정 (03:WR-08), Backlog 999.2 (`smoke.dart` `killTree` · `example/README.md` 문장)
- **v2 요구사항:** RULES-13 (`lints` 7 / `flutter_lints` 7 대응, 측정 도구 CR-03 · WR-09 선행), PRESET-09 · RULES-09 (문서화 프리셋), RULES-10 ~ 12

## Requirements

### Validated

<!-- 기존 코드에서 추론한, 이미 동작하고 의존되고 있는 기능. -->

- ✓ `include: package:woody_lints/analysis_options.yaml` 한 줄로 공유 분석 설정 적용 — existing
- ✓ `flutter_lints ^6.0.0` 기반 규칙 상속, 전이 의존성(transitive dependency)으로 사용 프로젝트에 전달 — existing
- ✓ 추가 lint 규칙 12개 활성화 (성능 3, 가독성·스타일 5, 버그 방지 4) — existing
- ✓ 코드 생성 산출물(`**/*.freezed.dart`, `**/*.g.dart`) 분석 제외와 `invalid_annotation_target` 무시 — existing
- ✓ 최상위 `plugins:` 로 `riverpod_lint ^3.1.3` analyzer plugin 로드 — existing
- ✓ pub.dev 미게시, Git 의존성으로 배포 — existing
- ✓ 저장소 고정 SDK(`.fvmrc`, `.vscode/settings.json`)가 지원 대상 SDK(Flutter 3.47.5 / Dart 3.13.4)와 일치한다 — v2.0 (Phase 1)
- ✓ 1.3.0 기준점 `v1.3.0` annotated tag 가 원격에 있어, 사용 프로젝트가 `ref: v1.3.0` 에 머물 수 있다 — v2.0 (Phase 1)
- ✓ 버전 정책과 CHANGELOG 항목 형식이 `VERSIONING.md` 에 정해져 있다 — v2.0 (Phase 1)
- ✓ `example/` 프로젝트와 검증 명령 하나(`fvm dart run tool/verify.dart`)로 배포 파일을 이 저장소 안에서 검증할 수 있다 — 정답지 비교(줄과 건수), 규칙 이름 검사, `lib/` 의 `.dart` 검사 — v2.0 (Phase 2)
- ✓ Riverpod / codegen 설정을 선택형 프리셋으로 분리해, 쓰지 않는 프로젝트가 받지 않을 수 있다 — 조각 셋 · 묶음 · 옛 주소 별칭, 옛 주소와 묶음의 진단이 분리 전과 줄 단위로 같다. 연습용 프로젝트 여섯 · 단계 9개로 검증 — v2.0 (Phase 3)
- ✓ `riverpod_lint` plugin 하한 `^3.1.9`, 루트 분석이 배포 파일을 제외하지 않고 경고 없이 통과 — v2.0 (Phase 3)
- ✓ 규칙 하나 · plugin 진단 하나를 끄는 방법(프로젝트 전체 · 파일 · 한 줄)이 fixture 로 확인되어 있다 — README 「규칙 · plugin 진단 끄기」 는 Phase 5 — v2.0 (Phase 3)
- ✓ 규칙 세트 재선정: 후보 규칙을 `flutter_starter_kit` 복사본 실측(회차 R1, 52회 모두 유효)으로 재고 소유자가 하나씩 결정했다 — 켠 규칙 81개(1.3.0 의 6개 유지 + 새로 75개, 모두 info), 켜지 않은 규칙 90개와 사유가 `RULES.md` 에 있고 검증 명령 `[3/10]` 이 `lib/base.yaml` 과의 일치를 지킨다 — v2.0 (Phase 4)
- ✓ 기반 세트와 겹치는 선언 6개와 주석 처리된 설정 3개를 배포 파일에서 지웠다 — 정답지 다섯 그대로, 사유는 CHANGELOG 2.0.0 항목 — v2.0 (Phase 4)
- ✓ `README.md`, `CHANGELOG.md`, 배포 YAML 다섯의 머리 주석이 실제 설정과 일치한다 — 검증 명령 `[3/10]` 이 README 의 규칙 목록 · `package:` 주소 · plugin 버전 · `ref:` 와 `RULES.md` 를 배포 파일과 견주고, 마지막 확인 (h) 가 줄 단위 reader 의 값을 `package:yaml` 로 읽은 값과 견준다 (지워 보기 M32 ~ M91). CHANGELOG 1.1.0 ~ 1.2.5 를 git 이력으로 복원했다 — v2.0 (Phase 5)
- ✓ README 를 "몇 달 뒤의 내가 그대로 따라 하면 되는" 사용 안내로 다시 썼다 (설치, 프리셋 고르기, 규칙 · plugin 진단 끄기 세 층, 생성 파일 제외, 버전 올리기 세 갈래, 문제 해결) — 소유자 UAT 통과 (2026-10-15). 실제 tag 로 받는 확인과 UAT 에서 미룬 문서 손질 넷은 Phase 6 — v2.0 (Phase 5)
- ✓ GitHub Actions 가 push · PR · 수동 실행마다 그 검증을 자동 실행한다 — PR #1 ~ #3 의 `pull_request` 실행 모두 success, `main` 에서 `workflow_dispatch` 실행 38850984674 success, `Run workflow` 버튼을 소유자가 화면에서 확인 (UAT, 2026-10-17) — v2.0 (Phase 6)
- ✓ git tag 로 릴리스하고, 사용 프로젝트가 `ref: vX.Y.Z` 로 버전을 고정할 수 있다 — annotated tag `v2.0.0` 이 원격에서 `704bf56` 을 가리키고, 빈 프로젝트가 `ref: v2.0.0` 으로 받아 두 주소 모두에서 기본 규칙 · `riverpod_lint` 진단이 나온다 (`tool/smoke.dart`). tag · `pubspec.yaml` version · CHANGELOG 최상단이 다르면 CI 가 `[3/10]` 에서 실패한다 — v2.0 (Phase 6)

### Active

<!-- 이번 작업 범위. 릴리스되어 확인되기 전까지는 가설이다. -->

(없음 — v2.0 범위 43개는 모두 확인했다. 다음 범위는 `/gsd-new-milestone` 에서 정한다. 후보는 위 「Next Milestone Goals」, 미룬 손질은 ROADMAP `## Backlog` 999.1 ~ 999.3)

### Out of Scope

<!-- 명시적 경계. 다시 끼워 넣지 않도록 사유를 함께 적는다. -->

- 사용 프로젝트(`flutter_starter_kit`, 학습용 프로젝트)에 새 버전을 적용하고 경고를 정리하는 일 — 사용자가 따로 진행한다. 완료 기준은 패키지 릴리스까지다
- pub.dev 게시 — 개인 사용 목적이며 `publish_to: 'none'` 을 유지한다
- 영어 README — 독자가 작성자 본인이다
- Dart 3.13 미만 지원 — 최신 stable 만 지원하기로 했다. 이전 SDK 를 쓰는 프로젝트는 이전 tag 에 머문다
- "전부 켜고 일부만 끄기" 방식 — SDK 가 올라갈 때마다 새 규칙이 예고 없이 들어온다. 규칙마다 근거를 남긴다는 원칙과 충돌한다 (v2.0 REQUIREMENTS 에서 옮김)
- 버전별 / SDK 별 옵션 파일 — git tag 로 고정하면 파일을 복제하지 않고 같은 효과를 얻는다
- 자체 custom lint 규칙 — Dart 코드와 테스트가 필요해져 설정 전용 패키지라는 성격이 바뀐다
- 기본 프리셋의 `formatter:` 설정 — include 된 `formatter:` 가 사용 프로젝트의 `dart format` 결과를 바꿔, 버전을 올리면 대량의 포맷 변경이 생긴다
- lint 를 일괄 warning / error 로 승격 — 새 규칙 하나가 모든 사용 프로젝트의 CI 를 막는다. 엄격도는 사용 프로젝트가 정한다
- experimental 규칙 활성화 — 동작과 이름이 바뀔 수 있다 (stable 전환 뒤 재검토는 v2 RULES-12)

## Context

**v2.0 뒤 코드베이스 (2026-10-17, `main` 기준, `.planning/` 제외):**

- `v1.3.0` → `main`: 파일 227개, +60,121줄 / −138줄. 배포 파일 `lib/` 은 YAML 5개 120줄이고, 나머지는 저장소 안쪽 도구와 근거다
- 저장소 도구 (Dart, 받는 쪽에 가지 않음): `tool/verify.dart` 3,223줄 · `tool/smoke.dart` 1,143줄 · `tool/measure_rules.dart` 5,188줄, 측정 결과 `tool/measurements/2026-10-13-R1.json` (건수만). `lib/` 에는 `.dart` 가 없다 (검증 `[1/10]`)
- 연습용 프로젝트: `example/` (정답지 `exit 2` + 규칙별 줄) 와 `fixtures/` 다섯 (`recommended` · `base_only` · `base_riverpod` · `base_codegen` · `overrides`)
- 개발용 의존성 `yaml` · `markdown` 은 `dev_dependencies` — 받는 쪽 의존성 그래프에 들어가지 않는다

**알려진 문제 · 기술 부채 (v2.0 감사, 받는 쪽 영향 0):**

- `VERSIONING.md` 판정 순서와 기준표가 몇몇 경우(README · CHANGELOG 만 고친 변경, 새 프리셋 추가, `dev_dependencies` 만 바뀐 경우)에 다른 등급을 낸다 — 다음 릴리스 등급을 매기기 전에 다시 쓴다
- `.claude/CLAUDE.md` 의 Technology Stack · Conventions · Architecture 절이 1.3.0 시절 서술이다 (루트 exclude, 3.41.2, `^3.10.4` 등) — 에이전트가 읽으므로 다음 작업 전에 `/gsd-map-codebase` 로 다시 만든다
- 검증은 `04-DECISIONS.md` 결정 표와 CHANGELOG 표를 `lib/base.yaml` 과 견주지 않는다 (지금은 손 대조로 일치)
- `tool/measure_rules.dart` 는 1.3.0 기준선을 박아 두어 지금 다시 재면 틀린 값이 나온다 (04:CR-03 · WR-09) — RULES-13 재측정 전에 고친다
- CI 의 `ubuntu-latest` 가 2026-10-19 부터 Ubuntu 26 이미지다. 실패하면 spike-findings skill 의 runner 이미지 절부터 본다
- 전체 목록: `.planning/milestones/v2.0-MILESTONE-AUDIT.md` 의 `tech_debt`

<details>
<summary>v2.0 시작 때의 Context (1.3.0, 2026-10-11)</summary>

**현재 상태 (1.3.0):**

- 추적 파일 8개, Dart 소스 0개. 배포 산출물은 `lib/analysis_options.yaml` 하나
- 명시한 12개 규칙 중 6개는 `flutter_lints` / `lints` 가 이미 켜는 규칙이다. 이 패키지가 실제로 추가하는 것은 `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `always_declare_return_types`, `prefer_final_locals`, `prefer_single_quotes`, `unawaited_futures` 6개
- 주석 처리된 채 남은 설정: `formatter: trailing_commas: preserve`, `require_trailing_commas`, `public_member_api_docs`. 왜 꺼져 있는지 기록이 없다
- 테스트, `example/`, CI, git tag 가 모두 없다. 루트 `analysis_options.yaml` 이 배포 파일을 자체 분석에서 제외하므로, 규칙 이름 오타나 폐기된 규칙이 사용 프로젝트에서 처음 드러난다
- 상세 분석: `.planning/codebase/` (특히 `CONCERNS.md`, `ARCHITECTURE.md`)

**의존성 버전 (2026-10-11 pub.dev 조회):**

- `flutter_lints` 6.0.0 — 선언 `^6.0.0` 이 이미 최신
- `lints` 6.1.0 — 이미 최신
- `riverpod_lint` 최신 3.1.9 (Dart 3.13 이상 요구) — 선언 `^3.1.3` 범위에 포함
- 결론: 올릴 의존성 버전은 사실상 없다. 뒤처진 것은 `.fvmrc` (Flutter 3.41.2 / Dart 3.11.0) 뿐이다. 로컬 FVM 에는 3.47.5 (Dart 3.13.4) 가 설치되어 있다

**사용 프로젝트 (`~/dv` 아래 검색, 전부 `ref: main`):**

- `woody/flutter_starter_kit` — Flutter 3.47.5, Dart 파일 169개. 실측 대상
- `study/nomadcorders/{webtoon, toonflix, pomodoro, state}` — Flutter 버전 미고정, Dart 파일 1~9개의 학습용 프로젝트

**동기:**

- 구체적인 불편(거슬리는 규칙, 놓친 버그)은 없다. 제대로 구성된 것인지 확신이 없다는 점이 출발점이다
- 그래서 규칙 선정은 "설명만"이 아니라 실제 프로젝트 실측을 근거로 삼는다

**확인이 필요한 기술 사항:**

- 최상위 `plugins:` 를 include 되는 프리셋 파일 안에 두었을 때의 동작. 이 저장소 안에서는 `plugins_in_inner_options` 경고가 난 전례가 있어, 프리셋 분리 구조를 정하기 전에 대상 Dart 버전에서 검증해야 한다 — 확인됨 (spike 009 · 011, Dart 3.13.4): include 로 받은 `plugins:` 가 로드되고, 나눈 뒤에는 루트 분석에서 그 경고가 나지 않는다
- `flutter analyze` 가 Flutter 3.47.5 에서 plugin 진단을 표시하지 않는다는 기록(2026-09-20 실측). CI 검증 명령 선택에 영향을 준다
- 3단 include (`analysis_options.yaml` → `recommended.yaml` → 조각 파일)에서 `riverpod_lint` plugin 이 로드되는지. 조사에서 실측한 것은 2단까지다. 로드되지 않으면 옛 이름의 별칭이 plugin 을 소리 없이 잃으므로, 옛 URI 를 쓰는 fixture 로 고정해야 한다 — 확인됨 (spike 010, Phase 3): 3단 include 로 plugin 이 로드되고 `example/` 의 정답지가 지킨다 (M18)
- `codegen.yaml` 이 주는 생성 파일 제외는 Dart 3.13.x 의 규칙 진단에만 통하고 `riverpod_lint` 진단에는 통하지 않는다 (spike 012). 베타 SDK 에서는 규칙 진단에도 통하지 않았다 (spike 016). README 「생성 파일 제외」 가 SDK 별로 적고 사용 프로젝트에 직접 적는 방법을 안내한다 (Phase 5)

</details>

## Constraints

- **SDK**: Flutter 3.47.x / Dart 3.13 이상만 지원 — 사용 프로젝트가 3.47.5 이고, 최신 lint 규칙과 `riverpod_lint` 3.1.9 를 쓰기 위해
- **Compatibility**: `package:woody_lints/analysis_options.yaml` URI 는 공개 API 다 — 모든 사용 프로젝트가 이 경로로 참조하므로, 프리셋을 나눈 뒤에도 이 URI 는 지금과 같은 뜻(기본 + Riverpod + codegen)을 유지한다. 새 문서는 정식 이름 `package:woody_lints/recommended.yaml` 을 안내한다
- **Release channel**: `main` 은 릴리스 채널이다 — 사용 프로젝트 5개가 `ref: main` 을 따르므로, `lib/` 와 `pubspec.yaml` 을 고치는 작업은 milestone 브랜치에 쌓고 릴리스(tag) 때만 PR(merge commit)로 `main` 에 합친다. `.planning/` 기록만 바뀌는 PR 은 받는 쪽에 닿지 않는다 (v2.0 마감 때 고침 — 이전 문구는 "릴리스 전까지 1.3.0 상태 유지")
- **Distribution**: Git 의존성 + git tag 로만 배포 — pub.dev 에 올리지 않는다
- **Safety**: 실측은 `flutter_starter_kit` 복사본에서 한다 — 원본 프로젝트는 수정하지 않는다
- **Verification**: plugin 진단 확인은 `dart analyze` 로 한다 — `flutter analyze` 는 Flutter 버전에 따라 plugin 진단을 누락한다
- **Dependencies**: `include:` 대상 패키지는 `dependencies` 에 둔다 — `dev_dependencies` 는 사용 프로젝트의 의존성 그래프에 전달되지 않는다
- **Documentation**: YAML 주석, README, CHANGELOG 는 한국어로 쓰고 규칙명·키는 영어 원문을 쓴다 — 기존 관례이며 독자가 작성자 본인이다

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| git tag 로 릴리스하고 README 를 `ref: vX.Y.Z` 기준으로 안내한다 | 규칙 재검토로 새 경고가 많이 생길 수 있어, 프로젝트마다 올리는 시점을 고를 수 있어야 한다 | ✓ Phase 6 — annotated tag `v2.0.0` (`704bf56`), 빈 프로젝트가 `ref: v2.0.0` 으로 받아 두 주소 모두 진단 확인 |
| 최신 stable 만 지원한다 (Dart 3.13 이상) | 사용 프로젝트가 Flutter 3.47.5 이고 이전 SDK 를 쓰는 프로젝트는 이전 tag 에 머물 수 있다 | ✓ Phase 6 — 2.0.0 을 `sdk: ^3.13.0` 으로 냄, 3.13 미만은 `ref: v1.3.0` (README) |
| 규칙은 후보별 근거를 보고 하나씩 결정한다 | 구체적 불편이 없어 엄격도를 미리 정할 근거가 없다 | ✓ Phase 4 — 묶음 다섯 · 질문 아홉을 소유자가 정함 (`04-DECISIONS.md` 결정 표: 켬 81 · 안 켬 38 · 결정 안 함 14), `sort_pub_dependencies` 는 측정 도구 결함을 고친 뒤 다시 정함 |
| 근거에는 `flutter_starter_kit` 복사본 실측을 포함한다 | 규칙이 내 코드에 실제로 몇 건의 경고를 내는지가 판단 기준이다 | ✓ Phase 4 — `tool/measure_rules.dart` 의 회차 기록 `tool/measurements/2026-10-13-R1.json` (경로 · 메시지 없이 건수만), 원본은 바꾸지 않음. 재측정 전에 고칠 것 둘(CR-03 · WR-09)은 RULES-13 메모 |
| Riverpod / codegen 설정을 선택형 프리셋으로 분리한다 | 지금은 모든 주요 프로젝트가 Riverpod + codegen 이지만, 앞으로 다른 구성의 프로젝트가 생길 것을 대비한다 | ✓ Phase 3 — 조각은 서로를 include 하지 않고, 묶음이 셋을 `package:` 주소 목록으로 include 한다 |
| 검증은 `example/` 프로젝트 + GitHub Actions 로 자동화한다 | 유일한 산출물이 자체 분석에서 제외되어 있어 검증 수단이 없다 | ✓ Phase 2 — `tool/verify.dart` 와 `.github/workflows/verify.yml` (PR · 수동 실행 확인은 Phase 6) |
| README 독자는 미래의 작성자 본인, 한국어로 쓴다 | 개인 사용 패키지다 | ✓ Phase 5 — README 만 보고 따라 하기 UAT 통과 (2026-10-15) |
| 완료 범위는 패키지 릴리스까지다 | 각 프로젝트 적용은 사용자가 원하는 시점에 따로 한다 | ✓ Phase 6 — tag · `main` 병합까지 하고 사용 프로젝트는 건드리지 않음 (`ref: main` 프로젝트는 `pub upgrade` 때 받는다) |
| 묶음(기본 + Riverpod + codegen)의 정식 이름은 `package:woody_lints/recommended.yaml` 이다. 기존 URI `package:woody_lints/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 한 줄짜리 별칭으로 남긴다 | 조각 파일(`base.yaml` 등)처럼 묶음도 내용이 드러나는 이름을 쓴다. 옛 이름을 남겨 기존 프로젝트는 고칠 것이 없다. 옛 이름은 README 에 "예전 이름"으로만 적고 다음 major 에서 제거를 검토한다 | ✓ Phase 3 — 옛 주소 · 묶음 · 분리 전 커밋으로 받은 결과가 줄 단위로 같다 (README 안내는 Phase 5) |
| 기본 규칙 조각 파일의 이름은 `base.yaml` 이다 | 파일 이름이 곧 공개 URI 다. 공식 `lints` 패키지의 `core.yaml` 과 이름이 겹치지 않는다 | ✓ Phase 3 |
| `lib/` 와 `pubspec.yaml` 을 고치는 작업은 milestone 브랜치에 쌓고 릴리스 때만 `main` 에 합친다 (`git.branching_strategy: milestone`) | 사용 프로젝트가 전부 `ref: main` 이라, `main` 에 push 된 중간 상태가 `pub upgrade` 때 그대로 배포된다 | ✓ Phase 6 — PR #1 merge commit `5ee5a12` (2026-10-16) 로 처음 합침; 그 뒤 저장소 안쪽만 고친 gap 수정은 PR #2 · #3 merge commit 으로 |
| 검증 판정은 기대 진단 비교(golden comparison)를 주 수단으로 한다 | lint 는 info 라 종료 코드만으로는 규칙이 켜져 있음을 증명하지 못한다 (조사 결과) | ✓ Phase 2 — 정답지 `example/expected_diagnostics.txt` (`exit 2` + 16줄), 줄과 건수를 견준다 |
| 1.3.0 기준점은 commit `90a2736` 의 annotated tag `v1.3.0` 이다. 한 번 올린 tag 는 옮기거나 지우지 않는다 | 사용 프로젝트의 `pubspec.lock` 이 받은 커밋 번호를 적어 두므로, tag 를 옮기면 기록과 어긋난다. 잘못이 발견되면 새 이름(v1.3.1 등)을 쓴다 | ✓ Phase 1 — origin 에 올림 (2026-10-11) |
| 다음 릴리스는 2.0.0 이다. 준비하는 동안 milestone 브랜치의 `pubspec.yaml` 은 `2.0.0-dev` 로 둔다 | 이번 릴리스의 가장 큰 등급이 지원 SDK 하한 상향(`^3.10.4` → `^3.13.0`, major)이다 | ✓ Phase 6 — 릴리스 커밋 `704bf56` 에서 `-dev` 를 뗌 |
| 버전 등급의 기준은 "받는 쪽이 겪는 일" 이고 기준 문서는 루트 `VERSIONING.md` 다. 규칙을 새로 켜는 것은 그 규칙이 warning 등급이어도 minor 다 | 받는 쪽은 정확한 tag 하나에 고정하므로 버전 번호는 사람에게 보내는 신호다. 새로 켜는 규칙은 CHANGELOG 의 "새로 생기는 경고" 표에서 미리 볼 수 있다 | ✓ Phase 6 — 2.0.0 을 major 로 냄. 릴리스 뒤 `pubspec.yaml` 의 `dev_dependencies` · 주석만 바뀐 경우의 등급 문구는 Backlog 999.3 (Phase 6 UAT 3번) |
| GSD 의 자동 tag(`git.create_tag`)를 끄고, 마일스톤 번호를 패키지 버전에 맞춰 `v2.0` 으로 둔다 | 이 저장소의 `v` tag 는 사용 프로젝트가 `ref:` 로 가리키는 패키지 릴리스다. 뜻이 다른 `v1.0` tag 가 최신 내용에 붙으면 옛 버전으로 오해한다 | ✓ Phase 6 — 원격 tag 는 `v1.3.0` · `v2.0.0` 둘뿐 (2026-10-17) |
| `example/pubspec.lock` 을 커밋한다 (루트 `pubspec.lock` 은 지금처럼 커밋하지 않는다) | 소유자의 컴퓨터와 CI 가 같은 패키지 버전으로 판정한다. 정답지가 깨졌을 때 원인이 "저장소 변경" 또는 "plugin 새 버전" 으로 좁혀진다. `riverpod_lint` plugin 버전은 lock 이 묶지 못한다 | ✓ Phase 2 |
| CI 를 돌리려고 작업 브랜치를 `.planning/` 과 함께 그대로 origin 에 올린다. CI 는 모든 push(브랜치와 tag) · PR · 수동 실행에서 돌고 예약 실행은 두지 않는다 | 올리기만 하면 결과가 보이고 `main` 에 합치는 방법을 미리 묶지 않는다. `.planning/` 을 뺀 사본 브랜치는 로컬과 원격의 이력을 갈라놓는다. 예약 실행은 60일 동안 활동이 없으면 꺼진다 | ✓ Phase 2 — Phase 3 부터의 push 는 다시 소유자에게 묻는다 |
| `--update` 가 망가진 결과를 정답지로 쓰는 남은 경로는 Phase 3 에서 정답지를 새로 쓰기 전에 가장 먼저 닫는다 (지금 Phase 2 에서 한 바퀴 더 돌지 않는다) | `[2/4]` 가 통과로 잘못 찍히는 세 입력에서 `--update` 가 종료 코드 0 으로 끝난다. 보통 실행은 세 입력 모두 실패로 잡는다. 고칠 곳이 Phase 3 이 손대는 곳과 같다 | ✓ Phase 3 (03-01) — 세 입력 모두 `--update` 가 종료 코드 1 · 정답지 불변 (M15 ~ M17) |
| 검증 명령의 줄 단위 reader 가 본 값을 루트 `dev_dependencies` 의 `yaml` 로 읽은 같은 파일의 값과 견준다 (`[3/10]` 의 (h)). 줄 단위 reader 의 본문 · 메시지는 그대로 두고, 꼴을 하나씩 막는 코드는 더하지 않는다 | Phase 5 의 gap 일곱 회차가 모두 "줄 단위 reader 가 보는 것 ≠ analyzer · pub 이 보는 것" 이었다. 대조는 꼴 하나가 아니라 그 모양의 종류를 닫는다. `yaml` 은 개발용 의존성이라 받는 쪽 의존성 그래프에 들어가지 않는다 (D-11 을 이 목적에 한해 다시 정함, 소유자 결정 G4-Q1) | ✓ Phase 5 — 여러 줄 문자열 · 중복 키 입력 여섯(M86 ~ M91)이 실패, 고치기 전 판으로는 통과. SDK 가 품은 package:yaml 판과 같은지는 재지 않았다 |
| 검사가 보지 않는 꼴은 검사를 넓히지 않고 README · `example/README.md` 의 문장을 실제 범위로 좁힌다 | 남은 꼴(따옴표 키, flow 표기 안의 키, 네 칸 들여 쓴 펜스, HTML 주석 안의 `#` 줄 등)은 이 저장소 문서에 쓰지 않는 꼴이고, 막을수록 reader 가 늘어난다 | ✓ Phase 5 — 소유자 결정 G2-Q2 · G3-Q2 · G3-Q3 · G4-Q2, 처리 기록 `05-REVIEW-DISPOSITION.md` 의 `skipped` 8건 |
| 리뷰 경고 IN-12 · IN-13 · IN-14 와 Phase 5 UAT 에서 미룬 문서 손질 넷은 Phase 6 에서 릴리스 tag 전에 닫는다 | 셋 다 통과로 끝나지 않는 쪽(막는 쪽)이고 문서 손질은 사용자 동작과 무관하다. 릴리스 전 README · `pubspec.yaml` 커밋과 smoke test 가 같은 곳을 본다 | ✓ Phase 6 — IN-12 · IN-14 는 06-01, 문서 손질은 06-02, IN-13 은 릴리스 커밋 `704bf56` |
| ROADMAP Phase 3 성공 기준 3 의 "생성 파일의 진단이 보고되지 않는다" 는 Dart 3.13.x 의 규칙 진단에 대한 말로 읽는다 | 생성 파일 안의 `riverpod_lint` 진단은 패키지가 주는 제외로 막을 수 없다 (plugin 이 제외 패턴을 그것을 적은 폴더 기준으로 푼다, 1.3.0 도 같다). 사용 프로젝트가 자기 옵션 파일에 직접 적으면 막힌다 | ✓ 소유자 확인 2026-10-12 (Phase 3 UAT 1번) — README 의 범위 안내는 Phase 5 Notes |
| tag push 와 `main` 병합은 실행 바로 앞에서 소유자에게 한 번 더 묻고, tag 는 예행(smoke)을 통과한 그 커밋에만 단다. 병합은 merge commit 만 쓴다 | 원격에 남아 되돌리기 어려운 두 작업이다. squash · rebase 는 커밋 번호를 바꿔 tag 를 단 커밋이 `main` 이력에서 빠진다 | ✓ Phase 6 — `VERSIONING.md` 「릴리스 절차」 1 ~ 10, 소유자 응답 뒤 tag push 1회 · 병합 3회 |
| CHANGELOG 최상단 제목은 파일 첫 줄로 고정하고, 검사는 그 줄을 Markdown(GitHub Flavored) 해석의 첫 h2 와 견준다 (`markdown` 은 `dev_dependencies`) | 줄 단위 reader 와 GitHub 화면이 갈리는 꼴을 하나씩 막는 대신, 첫 줄 앞에 아무 블록도 없게 해 꼴의 종류를 닫는다 | ✓ Phase 6 — 소유자 결정 G7-Q1, 같은 꼴 입력 63개에서 거짓 통과 0 (06-VERIFICATION) |
| 릴리스 확인 도구 `tool/smoke.dart` 는 단계별 시간 제한(create 2분 · pub get 5분 · analyze 주소마다 5분)과 Ctrl-C 정리를 두고, verify · CI 에는 넣지 않는다 | 네트워크가 멈추면 받기가 끝없이 기다렸다 (06-04 예행 1회차). 릴리스 때 손으로 한 번 돌리는 도구다 | ✓ Phase 6 — 소유자 결정 G6-Q2 · G7-Q2. 하네스로 일으킬 수 없는 경합 둘은 알려진 한계 (UAT 4번), `killTree` 의 재현된 구멍 IN-11 은 Backlog 999.2 |
| v2.0 은 감사 판정 `tech_debt` 를 받아들이고 마감한다. Phase 1 ~ 5 의 검증 지문 `stale` 은 다시 돌리지 않고 기록만 한다 (`override_closeout`) | 막는 문제 0, 요구사항 43/43, 남은 지적은 모두 저장소 안쪽이다. 지문은 각 phase 검증 때 `passed` 였고, 뒤 phase 가 그 phase 의 covered 파일(CHANGELOG · VERSIONING · pubspec 등)을 고쳐 낡았다 | — Pending: 부채 처리는 다음 마일스톤 범위에서 정한다 (위 「Next Milestone Goals」) |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-10-17 after v2.0 milestone*
