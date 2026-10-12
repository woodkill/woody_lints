# woody_lints

## What This Is

`woody_lints` 는 Flutter 프로젝트의 `analysis_options.yaml` 에서 `include:` 한 줄로 끌어다 쓰는 설정 전용 패키지(configuration-only package)다. Dart 코드는 없고 `lib/analysis_options.yaml` 이 유일한 배포 산출물이며, 작성자 본인의 Flutter 프로젝트들이 Git 의존성으로 가져다 쓴다.

이번 작업은 "잘 모르던 시절에 만든" 이 패키지를 지금 기준으로 다시 다듬어 새 버전으로 릴리스하는 것이다.

## Core Value

사용 프로젝트가 `include` 한 줄로 받는 규칙이 문서에 적힌 그대로 적용되고, 각 규칙이 왜 켜져 있는지 근거가 남아 있다.

## Requirements

### Validated

<!-- 기존 코드에서 추론한, 이미 동작하고 의존되고 있는 기능. -->

- ✓ `include: package:woody_lints/analysis_options.yaml` 한 줄로 공유 분석 설정 적용 — existing
- ✓ `flutter_lints ^6.0.0` 기반 규칙 상속, 전이 의존성(transitive dependency)으로 사용 프로젝트에 전달 — existing
- ✓ 추가 lint 규칙 12개 활성화 (성능 3, 가독성·스타일 5, 버그 방지 4) — existing
- ✓ 코드 생성 산출물(`**/*.freezed.dart`, `**/*.g.dart`) 분석 제외와 `invalid_annotation_target` 무시 — existing
- ✓ 최상위 `plugins:` 로 `riverpod_lint ^3.1.3` analyzer plugin 로드 — existing
- ✓ pub.dev 미게시, Git 의존성으로 배포 — existing
- ✓ 저장소 고정 SDK(`.fvmrc`, `.vscode/settings.json`)가 지원 대상 SDK(Flutter 3.47.5 / Dart 3.13.4)와 일치한다 — Phase 1
- ✓ 1.3.0 기준점 `v1.3.0` annotated tag 가 원격에 있어, 사용 프로젝트가 `ref: v1.3.0` 에 머물 수 있다 — Phase 1
- ✓ 버전 정책과 CHANGELOG 항목 형식이 `VERSIONING.md` 에 정해져 있다 — Phase 1
- ✓ `example/` 프로젝트와 검증 명령 하나(`fvm dart run tool/verify.dart`)로 배포 파일을 이 저장소 안에서 검증할 수 있다 — 정답지 비교(줄과 건수), 규칙 이름 검사, `lib/` 의 `.dart` 검사 — Phase 2

### Active

<!-- 이번 작업 범위. 릴리스되어 확인되기 전까지는 가설이다. -->

- [ ] 규칙 세트 재선정: 후보 규칙을 조사하고 `flutter_starter_kit` 실측 근거(규칙별 경고 수)로 하나씩 켤지 결정한다
- [ ] 기반 세트와 중복되는 선언 6개, 주석 처리된 설정 3개 각각에 대해 유지/삭제를 결정하고 사유를 남긴다
- [ ] `README.md`, `CHANGELOG.md`, `lib/analysis_options.yaml` 머리 주석이 실제 설정과 일치한다
- [ ] GitHub Actions 가 push 와 PR 마다 그 검증을 자동 실행한다 — push 쪽은 Phase 2 에서 확인했다 (성공한 실행 2건, 겹친 실행의 취소 1건, 2026-10-12). PR 에서 도는지와 수동 실행 버튼은 PR 이 처음 열리고 workflow 가 `main` 에 들어가는 Phase 6 에서 본다
- [ ] git tag 로 릴리스하고, 사용 프로젝트가 `ref: vX.Y.Z` 로 버전을 고정할 수 있다
- [ ] Riverpod / codegen 설정을 선택형 프리셋으로 분리해, 쓰지 않는 프로젝트가 받지 않을 수 있다
- [ ] README 를 "몇 달 뒤의 내가 그대로 따라 하면 되는" 사용 안내로 다시 쓴다 (설치, 프리셋 선택, 규칙 재정의, 버전 올리기)

### Out of Scope

<!-- 명시적 경계. 다시 끼워 넣지 않도록 사유를 함께 적는다. -->

- 사용 프로젝트(`flutter_starter_kit`, 학습용 프로젝트)에 새 버전을 적용하고 경고를 정리하는 일 — 사용자가 따로 진행한다. 완료 기준은 패키지 릴리스까지다
- pub.dev 게시 — 개인 사용 목적이며 `publish_to: 'none'` 을 유지한다
- 영어 README — 독자가 작성자 본인이다
- Dart 3.13 미만 지원 — 최신 stable 만 지원하기로 했다. 이전 SDK 를 쓰는 프로젝트는 이전 tag 에 머문다

## Context

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

- 최상위 `plugins:` 를 include 되는 프리셋 파일 안에 두었을 때의 동작. 이 저장소 안에서는 `plugins_in_inner_options` 경고가 난 전례가 있어, 프리셋 분리 구조를 정하기 전에 대상 Dart 버전에서 검증해야 한다
- `flutter analyze` 가 Flutter 3.47.5 에서 plugin 진단을 표시하지 않는다는 기록(2026-09-20 실측). CI 검증 명령 선택에 영향을 준다
- 3단 include (`analysis_options.yaml` → `recommended.yaml` → 조각 파일)에서 `riverpod_lint` plugin 이 로드되는지. 조사에서 실측한 것은 2단까지다. 로드되지 않으면 옛 이름의 별칭이 plugin 을 소리 없이 잃으므로, 옛 URI 를 쓰는 fixture 로 고정해야 한다

## Constraints

- **SDK**: Flutter 3.47.x / Dart 3.13 이상만 지원 — 사용 프로젝트가 3.47.5 이고, 최신 lint 규칙과 `riverpod_lint` 3.1.9 를 쓰기 위해
- **Compatibility**: `package:woody_lints/analysis_options.yaml` URI 는 공개 API 다 — 모든 사용 프로젝트가 이 경로로 참조하므로, 프리셋을 나눈 뒤에도 이 URI 는 지금과 같은 뜻(기본 + Riverpod + codegen)을 유지한다. 새 문서는 정식 이름 `package:woody_lints/recommended.yaml` 을 안내한다
- **Release channel**: 릴리스 전까지 `main` 의 `lib/` 와 `pubspec.yaml` 은 1.3.0 상태를 유지한다 — 사용 프로젝트 5개가 `ref: main` 을 따른다
- **Distribution**: Git 의존성 + git tag 로만 배포 — pub.dev 에 올리지 않는다
- **Safety**: 실측은 `flutter_starter_kit` 복사본에서 한다 — 원본 프로젝트는 수정하지 않는다
- **Verification**: plugin 진단 확인은 `dart analyze` 로 한다 — `flutter analyze` 는 Flutter 버전에 따라 plugin 진단을 누락한다
- **Dependencies**: `include:` 대상 패키지는 `dependencies` 에 둔다 — `dev_dependencies` 는 사용 프로젝트의 의존성 그래프에 전달되지 않는다
- **Documentation**: YAML 주석, README, CHANGELOG 는 한국어로 쓰고 규칙명·키는 영어 원문을 쓴다 — 기존 관례이며 독자가 작성자 본인이다

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| git tag 로 릴리스하고 README 를 `ref: vX.Y.Z` 기준으로 안내한다 | 규칙 재검토로 새 경고가 많이 생길 수 있어, 프로젝트마다 올리는 시점을 고를 수 있어야 한다 | — Pending |
| 최신 stable 만 지원한다 (Dart 3.13 이상) | 사용 프로젝트가 Flutter 3.47.5 이고 이전 SDK 를 쓰는 프로젝트는 이전 tag 에 머물 수 있다 | — Pending |
| 규칙은 후보별 근거를 보고 하나씩 결정한다 | 구체적 불편이 없어 엄격도를 미리 정할 근거가 없다 | — Pending |
| 근거에는 `flutter_starter_kit` 복사본 실측을 포함한다 | 규칙이 내 코드에 실제로 몇 건의 경고를 내는지가 판단 기준이다 | — Pending |
| Riverpod / codegen 설정을 선택형 프리셋으로 분리한다 | 지금은 모든 주요 프로젝트가 Riverpod + codegen 이지만, 앞으로 다른 구성의 프로젝트가 생길 것을 대비한다 | — Pending |
| 검증은 `example/` 프로젝트 + GitHub Actions 로 자동화한다 | 유일한 산출물이 자체 분석에서 제외되어 있어 검증 수단이 없다 | ✓ Phase 2 — `tool/verify.dart` 와 `.github/workflows/verify.yml` (PR · 수동 실행 확인은 Phase 6) |
| README 독자는 미래의 작성자 본인, 한국어로 쓴다 | 개인 사용 패키지다 | — Pending |
| 완료 범위는 패키지 릴리스까지다 | 각 프로젝트 적용은 사용자가 원하는 시점에 따로 한다 | — Pending |
| 묶음(기본 + Riverpod + codegen)의 정식 이름은 `package:woody_lints/recommended.yaml` 이다. 기존 URI `package:woody_lints/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 한 줄짜리 별칭으로 남긴다 | 조각 파일(`base.yaml` 등)처럼 묶음도 내용이 드러나는 이름을 쓴다. 옛 이름을 남겨 기존 프로젝트는 고칠 것이 없다. 옛 이름은 README 에 "예전 이름"으로만 적고 다음 major 에서 제거를 검토한다 | — Pending |
| 기본 규칙 조각 파일의 이름은 `base.yaml` 이다 | 파일 이름이 곧 공개 URI 다. 공식 `lints` 패키지의 `core.yaml` 과 이름이 겹치지 않는다 | — Pending |
| `lib/` 와 `pubspec.yaml` 을 고치는 작업은 milestone 브랜치에 쌓고 릴리스 때만 `main` 에 합친다 (`git.branching_strategy: milestone`) | 사용 프로젝트가 전부 `ref: main` 이라, `main` 에 push 된 중간 상태가 `pub upgrade` 때 그대로 배포된다 | — Pending |
| 검증 판정은 기대 진단 비교(golden comparison)를 주 수단으로 한다 | lint 는 info 라 종료 코드만으로는 규칙이 켜져 있음을 증명하지 못한다 (조사 결과) | ✓ Phase 2 — 정답지 `example/expected_diagnostics.txt` (`exit 2` + 16줄), 줄과 건수를 견준다 |
| 1.3.0 기준점은 commit `90a2736` 의 annotated tag `v1.3.0` 이다. 한 번 올린 tag 는 옮기거나 지우지 않는다 | 사용 프로젝트의 `pubspec.lock` 이 받은 커밋 번호를 적어 두므로, tag 를 옮기면 기록과 어긋난다. 잘못이 발견되면 새 이름(v1.3.1 등)을 쓴다 | ✓ Phase 1 — origin 에 올림 (2026-10-11) |
| 다음 릴리스는 2.0.0 이다. 준비하는 동안 milestone 브랜치의 `pubspec.yaml` 은 `2.0.0-dev` 로 둔다 | 이번 릴리스의 가장 큰 등급이 지원 SDK 하한 상향(`^3.10.4` → `^3.13.0`, major)이다 | — Pending |
| 버전 등급의 기준은 "받는 쪽이 겪는 일" 이고 기준 문서는 루트 `VERSIONING.md` 다. 규칙을 새로 켜는 것은 그 규칙이 warning 등급이어도 minor 다 | 받는 쪽은 정확한 tag 하나에 고정하므로 버전 번호는 사람에게 보내는 신호다. 새로 켜는 규칙은 CHANGELOG 의 "새로 생기는 경고" 표에서 미리 볼 수 있다 | — Pending |
| GSD 의 자동 tag(`git.create_tag`)를 끄고, 마일스톤 번호를 패키지 버전에 맞춰 `v2.0` 으로 둔다 | 이 저장소의 `v` tag 는 사용 프로젝트가 `ref:` 로 가리키는 패키지 릴리스다. 뜻이 다른 `v1.0` tag 가 최신 내용에 붙으면 옛 버전으로 오해한다 | — Pending |
| `example/pubspec.lock` 을 커밋한다 (루트 `pubspec.lock` 은 지금처럼 커밋하지 않는다) | 소유자의 컴퓨터와 CI 가 같은 패키지 버전으로 판정한다. 정답지가 깨졌을 때 원인이 "저장소 변경" 또는 "plugin 새 버전" 으로 좁혀진다. `riverpod_lint` plugin 버전은 lock 이 묶지 못한다 | ✓ Phase 2 |
| CI 를 돌리려고 작업 브랜치를 `.planning/` 과 함께 그대로 origin 에 올린다. CI 는 모든 push(브랜치와 tag) · PR · 수동 실행에서 돌고 예약 실행은 두지 않는다 | 올리기만 하면 결과가 보이고 `main` 에 합치는 방법을 미리 묶지 않는다. `.planning/` 을 뺀 사본 브랜치는 로컬과 원격의 이력을 갈라놓는다. 예약 실행은 60일 동안 활동이 없으면 꺼진다 | ✓ Phase 2 — Phase 3 부터의 push 는 다시 소유자에게 묻는다 |
| `--update` 가 망가진 결과를 정답지로 쓰는 남은 경로는 Phase 3 에서 정답지를 새로 쓰기 전에 가장 먼저 닫는다 (지금 Phase 2 에서 한 바퀴 더 돌지 않는다) | `[2/4]` 가 통과로 잘못 찍히는 세 입력에서 `--update` 가 종료 코드 0 으로 끝난다. 보통 실행은 세 입력 모두 실패로 잡는다. 고칠 곳이 Phase 3 이 손대는 곳과 같다 | — Pending (Phase 3, 소유자 결정 2026-10-12) |

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
*Last updated: 2026-10-12 after Phase 2*
