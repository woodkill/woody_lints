# Roadmap: woody_lints

## Overview

`woody_lints` 1.3.0 을 지금 기준으로 다시 다듬어 새 버전 tag 로 릴리스하기까지의 여정이다. 먼저 사용 프로젝트가 머물 수 있는 `v1.3.0` 기준점을 만들고 저장소 SDK 를 지원 대상에 맞춘다. 그다음 `lib/` 를 건드리기 전에 1.3.0 의 동작을 기대 진단(golden)으로 고정하는 검증 하네스를 세운다. 그 위에서 설정을 조각 프리셋으로 나누고(구조 변경), `flutter_starter_kit` 실측을 근거로 규칙을 하나씩 다시 고른다(내용 변경). 확정된 YAML 을 기준으로 문서를 다시 쓰고, 마지막에 문서가 가리키는 tag 를 만들어 git 의존성으로 받아 확인한다.

**모든 phase 에 걸친 제약:**

- **`main` 은 릴리스 전까지 1.3.0 이다.** 사용 프로젝트 5개가 전부 `ref: main` 을 따른다. `lib/` 와 `pubspec.yaml` 을 고치는 작업은 milestone 브랜치에만 쌓고 릴리스 때 `main` 에 합친다 (`git.branching_strategy: milestone`).
- **구조 변경과 내용 변경을 섞지 않는다.** 프리셋 분리(Phase 3)는 기대 진단이 바뀌지 않는 리팩터링으로 끝내고, 규칙 재선정(Phase 4)에서 바뀌는 기대 진단만 리뷰한다.
- **확인되지 않은 도구 동작은 먼저 실행해 본다.** Phase 2, 3, 4 는 문서화되지 않은 analyzer / plugin 동작에 기대므로, 각 phase 의 "Spike first" 항목을 `dart analyze` 로 확인한 뒤에 나머지를 계획한다.
- **plugin 진단 확인은 `dart analyze` 로 한다.** `flutter analyze` 는 Flutter 3.47.5 에서 plugin 진단을 내지 않는다.
- **원격에 남는 작업은 실행 시점에 소유자 확인을 받는다.** tag push, 브랜치 push, `main` 병합이 여기에 해당한다.

## v2.0 — Package Rework

**Milestone Goal:** 1.3.0 을 다시 다듬은 새 버전을 git tag 로 릴리스한다. 규칙마다 근거가 남고, 문서가 실제 설정과 일치하며, 그 일치가 자동으로 검증된다.

`v2.0` 은 GSD 마일스톤 번호다. 이 작업이 만들 패키지 릴리스(조사 권고 2.0.0, Phase 1 의 D8 에서 확정)에 맞춰 붙였고, 이 번호와 이름으로 milestone 브랜치(`gsd/v2.0-package-rework`)가 만들어진다. `git.create_tag` 는 꺼져 있어 GSD 는 tag 를 만들지 않는다. 이 저장소의 `v` tag 는 패키지 릴리스(`vX.Y.Z`)에만 쓴다.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Baseline and Toolchain** - 1.3.0 기준점(`v1.3.0` tag)과 지원 SDK 정렬, 버전 정책과 CHANGELOG 형식 확정 (completed 2026-10-11)
- [x] **Phase 2: Verification Harness** - `lib/` 를 바꾸기 전에 1.3.0 동작을 기대 진단으로 고정하는 `example/` 검증과 CI (completed 2026-10-12)
- [x] **Phase 3: Preset Split** - 기본 / Riverpod / codegen 조각과 `recommended.yaml` 묶음, 옛 URI 별칭 (기대 진단 불변) (completed 2026-10-12)
- [x] **Phase 4: Rule Reselection** - `flutter_starter_kit` 실측을 근거로 규칙을 하나씩 결정하고 근거를 기록 (completed 2026-10-13)
- [x] **Phase 5: Documentation** - README / CHANGELOG / YAML 주석을 확정된 설정에 맞춰 다시 쓰고 일치를 검증으로 고정 (completed 2026-10-15)
- [ ] **Phase 6: Release** - 새 버전 annotated tag 와 git 의존성 smoke test

## Phase Details

### Phase 1: Baseline and Toolchain

**Goal**: 사용 프로젝트가 머물 수 있는 1.3.0 기준점이 원격에 있고, 이후의 모든 검증과 실측이 지원 대상 SDK(Flutter 3.47.5 / Dart 3.13.4) 위에서 돌며, 실측 결과를 받아 적을 버전 정책과 CHANGELOG 형식이 정해져 있다
**Depends on**: Nothing (first phase)
**Requirements**: BASE-01, BASE-02, BASE-03, BASE-04, REL-01
**Success Criteria** (what must be TRUE):
  1. `git ls-remote --tags origin` 에 `v1.3.0` 이 보이고, `git show v1.3.0:pubspec.yaml` 의 version 이 1.3.0 이다
  2. 저장소 루트에서 `fvm flutter --version` 이 Flutter 3.47.5 / Dart 3.13.4 를 보고하고, `.vscode/settings.json` 의 SDK 경로도 같은 버전을 가리킨다
  3. milestone 브랜치의 `pubspec.yaml` 이 `sdk: ^3.13.0` 을 선언하고, Dart 3.13 미만 SDK 에서 이 패키지를 의존성으로 둔 프로젝트의 `pub get` 이 SDK 버전 불일치 오류로 끝난다. 같은 시점에 `origin/main` 의 `lib/` 와 `pubspec.yaml` 은 `v1.3.0` 과 차이가 없다
  4. 소유자가 버전 정책 문서를 읽고 어떤 변경이 major / minor / patch 인지 판정할 수 있으며, 그 정책에 따라 다음 릴리스의 버전 번호가 정해져 있다
  5. CHANGELOG 항목의 형식(추가·삭제 규칙, 지원 SDK, 새로 생기는 진단)이 문서로 정해져 있어, Phase 4 의 실측 결과를 그 형식에 그대로 옮겨 적을 수 있다

**Plans**: 4/4 plans complete

Plans:
**Wave 1**
- [x] 01-01-PLAN.md — `v1.3.0` annotated tag 를 만들고, 소유자 확인을 받은 뒤 원격에 올린다 (REL-01)

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 01-02-PLAN.md — `VERSIONING.md` 에 버전 정책과 CHANGELOG 항목 형식을 적는다 (BASE-03, BASE-04)

**Wave 3** *(blocked on Wave 2 completion)*
- [x] 01-03-PLAN.md — 저장소 SDK 를 3.47.5 로, 지원 하한을 `sdk: ^3.13.0` / `2.0.0-dev` 로 올리고 CHANGELOG 2.0.0 항목을 만든다 (BASE-01, BASE-02)

**Wave 4** *(gap closure — UAT G-01-1, blocked on Wave 3 completion)*
- [x] 01-04-PLAN.md — `VERSIONING.md` 판정 순서 1번을 기준표의 major 다섯 행을 모두 묻는 변경 종류 문구로 고치고(둘째 조건을 "이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나" 로 좁힘 + `flutter_lints` / `riverpod_lint` 다음 major 상향 추가) 1.3.0 사례가 세 조건을 모두 답하게 한다; D-02 · D-09 ① 문구 수정(소유자 결정 2건)을 CONTEXT 에 주석으로 기록한다 (G-01-1; BASE-03)

**Decision points** (이 phase 안에서 소유자가 정한다):
- **D4** — `v1.3.0` tag 를 원격에 push 하는 것은 원격에 남는 작업이다. tag 는 로컬에서 만들어 두고, push 는 실행 시점에 소유자의 명시적 확인을 받은 뒤에 한다. 조사 권고는 commit `90a2736` 에 annotated tag 이며, push 한 tag 는 옮기지 않는다.
- **D8** — 버전 정책의 세부와 다음 버전 번호. 조사 문서 두 편의 표(규칙 제거가 patch 인지 minor 인지, plugin 과 기반 세트 major 상향의 등급 등)를 하나로 합친다. 조사 권고는 2.0.0 (SDK 하한 상향).

**Notes**:
- `.fvmrc` 버전(D12)은 BASE-01 이 3.47.5 로 정했다. 실측 대상 `flutter_starter_kit` 과 같은 버전이어야 규칙별 수치가 의미 있다.
- `sdk` 하한을 올린 커밋은 Dart 3.13 미만에서 해석되지 않는다. `main` 에 들어가면 Flutter 버전을 고정하지 않은 학습용 프로젝트 4개가 영향받을 수 있으므로 milestone 브랜치에만 둔다.
- Flutter 프로젝트가 아닌 저장소 루트에서 `fvm use` 가 `--force` 를 요구하는지는 확인된 적이 없다.

### Phase 2: Verification Harness

**Goal**: `lib/` 를 바꾸기 전에 1.3.0 의 동작이 기대 진단(golden)으로 고정되어 있고, 소유자와 CI 가 같은 명령 하나로 "배포 설정이 기대한 대로 적용되는가"를 판정할 수 있다
**Depends on**: Phase 1
**Requirements**: VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-04, VERIFY-07, VERIFY-08
**Success Criteria** (what must be TRUE):
  1. 소유자가 저장소 루트에서 명령 하나를 실행하면 `example/` 의 분석 결과가 커밋된 기대 진단 파일과 비교되어, 같으면 성공하고 다르면 실패한다. 기대 진단에는 이 패키지가 추가한 규칙, 기반 세트 규칙, `riverpod_lint` 진단이 각각 한 건 이상 들어 있다
  2. 규칙이 적힌 배포 파일에 deprecated / removed / 존재하지 않는 규칙을 하나 넣으면 같은 명령이 실패한다
  3. `lib/` 에 `.dart` 파일을 하나 두면 같은 명령이 실패한다
  4. 배포 파일에서 규칙 하나를 지운 변경과 `example/` 의 include 줄을 지운 변경을 각각 실제로 만들어, 검증이 실패함을 확인한 기록이 있다
  5. push 와 PR 마다 GitHub Actions 가 같은 명령을 실행하고 job 에 시간 제한이 걸려 있으며, GitHub 에서 실제로 성공한 실행이 한 번 이상 있다

**Plans**: 5/5 plans complete

Plans:
**Wave 1**
- [x] 02-01-PLAN.md — `example/` 연습용 프로젝트와 `tool/verify.dart` 의 정답지 비교 경로(tracer)를 만들고, 규칙 12개 + 기반 세트 1개 + `riverpod_lint` 3건의 정답지 16줄을 생성해 커밋한다; 루트 옵션 파일 `example/**` 제외와 `.gitignore` 의 `!example/pubspec.lock` · `build/` (VERIFY-01; D-01 ~ D-05, D-11, D-14)

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 02-02-PLAN.md — `tool/verify.dart` 를 단계 4개(`lib/` 에 `.dart` 없음 / 배포 파일의 규칙 이름 / `example/` 옵션 파일 / 정답지 비교)로 넓히고, SDK 확인(D-12) · 버전 3줄(D-07) · 안내형 화면(D-13) · `--update` 의 CI 거부(D-14)를 완성한다 (VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-07)

**Wave 3** *(blocked on Wave 2 completion)*
- [x] 02-03-PLAN.md — 지워 보기 9건(규칙 삭제, include 삭제, `errors:` 블록 · exclude 2종 삭제, deprecated 규칙 추가, `lib/` 의 `.dart`, CI 의 `--update`, SDK 불일치)을 실제로 만들어 실패를 확인하고 되돌린 뒤 `example/README.md` 에 기록하고, CHANGELOG 2.0.0 항목에 `### 그 밖의 변경` 을 더한다 (VERIFY-08; D-03)

**Wave 4** *(blocked on Wave 3 completion)*
- [x] 02-04-PLAN.md — `.github/workflows/verify.yml`(push · PR · 수동 실행, 읽기 권한, timeout 10)을 만들고 작업 브랜치를 origin 에 올려 GitHub Actions 의 성공한 실행을 확인한다 (VERIFY-04; D-06, D-08 ~ D-10)

**Wave 5** *(gap closure — 02-VERIFICATION.md Gap 1 + 소유자 승인 A · B · C (2026-10-12), blocked on Wave 4 completion)*
- [x] 02-05-PLAN.md — `tool/verify.dart` 의 정답지 비교를 건수를 세는 차집합으로 고치고(CR-01), `--update` 가 다른 단계가 실패한 실행의 결과를 쓰지 않게 하고(WR-01 case 1), 규칙 이름 단계가 규칙 0개면 실패하게 하며(WR-03 의 절반), 중복 줄 · 망가진 실행 · 규칙 0개의 지워 보기 M10 ~ M14 를 실제로 돌려 `example/README.md` 에 기록한다; workflow 5행 주석을 "모든 브랜치와 tag" 로 바로잡고 D-10 과의 차이를 02-CONTEXT.md 에 날짜 붙여 덧붙인다 (Gap 1; VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-04, VERIFY-08; D-04, D-10, D-13, D-14)

**Spike first** (이 phase 의 나머지를 계획하기 전에 실행으로 확인한다):
- plugin 준비가 실패했는데 다른 진단이 있을 때 `dart analyze` 의 종료 코드. 기대 진단 판정 로직이 여기에 달려 있다.
- `riverpod_lint` 15개 규칙 각각의 실제 심각도와 JSON `code` 표기, 그에 따른 종료 코드. 조사 문서끼리 info 와 warning 으로 어긋나 있고 실측된 것은 규칙 1개뿐이다.
- GitHub Linux runner 의 cold 실행에서 plugin 진단이 빠짐없이 나오는지와 첫 실행 시간. workflow 전체를 GitHub 에서 돌려 본 적이 없다.
- `dart analyze <dir>` 이 plugin 진단을 잃는다는 보고(flutter#193203, sdk#62710, 로컬 미재현). fixture 를 작업 디렉터리로 두고 인자 없이 실행하면 피할 수 있는지.
- `flutter pub get` 이 `example/analysis_options.yaml` 에 `build/**` exclude 를 덧붙이는 문제의 처리, Flutter 프로젝트인 `example/` 에서 `dart pub get` 이 되는지.
- `unnecessary_await_in_return` 이 Dart 3.13.4 에서 deprecated 인지. 실측과 `rules.json` 이 어긋나며, 배포 파일을 initial file 로 분석하는 검사에서 드러난다.

**Decision points** (이 phase 안에서 소유자가 정한다):
- **D11** — `example/pubspec.lock` 을 커밋할지. 루트 `.gitignore` 의 `pubspec.lock` 패턴이 `example/` 에도 걸린다. 커밋하면 재현성을, 하지 않으면 기반 세트 변화의 조기 경보를 얻는다.

**Notes**:
- 이 phase 는 `lib/` 를 바꾸지 않고, 루트 `analysis_options.yaml` 의 exclude 도 그대로 둔다. exclude 제거는 Phase 3 의 PRESET-06 이다.
- lint 는 info 라 `dart analyze` 의 기본 종료 코드가 0 이다. 종료 코드가 아니라 기대 진단의 존재로 판정한다.
- deprecated / removed 규칙은 include 경유로는 보고되지 않는다 (실측). 규칙이 적힌 파일을 `analysis_options.yaml` 이름으로 분석 대상 안에 두는 단계가 따로 필요하다.
- fixture 를 몇 개 둘지, 옛 URI 한 줄을 쓰는 `example/` 이 "전체" 구성을 겸할지는 계획 때 정한다.
- CI workflow 는 읽기 권한만 갖는다 (`permissions: contents: read`).
- GitHub 에서 CI 실행을 보려면 milestone 브랜치를 원격에 push 해야 한다. 실행 시점에 소유자 확인을 받는다.

### Phase 3: Preset Split

**Goal**: 사용 프로젝트가 기본 / Riverpod / codegen 조각을 골라 include 하거나 `recommended.yaml` 묶음 한 줄로 전부 받을 수 있고, 옛 URI 한 줄을 쓰는 프로젝트는 분리 전과 똑같은 구성을 받는다
**Depends on**: Phase 2
**Requirements**: PRESET-01, PRESET-02, PRESET-03, PRESET-04, PRESET-05, PRESET-06, PRESET-07, PRESET-08, VERIFY-05
**Success Criteria** (what must be TRUE):
  1. 옛 URI(`package:woody_lints/analysis_options.yaml`) 한 줄만 쓰는 `example/` 의 기대 진단이 프리셋 분리(파일을 나누는 변경) 전후로 한 줄도 바뀌지 않고, `package:woody_lints/recommended.yaml` 을 include 해도 같은 진단이 나온다
  2. `base.yaml` 만 include 한 대조군 fixture 에서 기본 규칙 진단은 보고되고, `riverpod_lint` 진단은 보고되지 않으며, codegen 설정(생성 파일 제외 등)이 적용되지 않는다
  3. `riverpod.yaml` 을 include 한 구성에서 `riverpod_lint` 진단이 보고되고 plugin 버전 하한이 `^3.1.9` 이며, `codegen.yaml` 을 include 한 구성에서 생성 파일(`*.g.dart`, `*.freezed.dart`)의 진단이 보고되지 않는다
  4. 저장소 루트의 `analysis_options.yaml` 에서 배포 파일 exclude 를 걷어낸 상태로 루트 분석이 경고 없이 통과한다 (`plugins_in_inner_options` 포함)
  5. 재정의 fixture 에서 규칙 하나를 끄는 설정과 plugin 진단 하나를 끄는 설정이 각각 그 진단만 사라지게 한다

**Plans**: 4/4 plans complete

Plans:
**Wave 1**
- [x] 03-01-PLAN.md — "가장 먼저 할 일": `tool/verify.dart` 의 `[2/4]` 통과 조건을 "exit 0 이고 진단 0건" 으로 좁혀 세 입력(깨진 YAML · `rules:` 오타 · 겹친 규칙 + 없는 진단 코드)에서 `--update` 가 정답지를 쓰지 못하게 하고, `example/README.md` 의 30행 · 81행 · 158행과 M15 ~ M17 을 기록한다 (PRESET-04 의 전제; D-05; 권고 6)

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 03-02-PLAN.md — `lib/analysis_options.yaml` 을 줄 범위로 잘라 `base.yaml` / `codegen.yaml` / `riverpod.yaml` 과 `recommended.yaml` 묶음 · 옛 주소 별칭으로 나누고(같은 커밋에서 규칙 검사 대상을 조각 셋으로), 루트 `analysis_options.yaml` 의 `lib/analysis_options.yaml` 제외를 걷어내며 CHANGELOG 에 적는다 — `example/` 정답지 불변 (PRESET-04, PRESET-06, PRESET-08; D-02; 권고 5 · 7 · 8)

**Wave 3** *(blocked on Wave 2 completion)*
- [x] 03-03-PLAN.md — `tool/verify.dart` 를 fixture 표 · 단계 9개 · `--update` 일괄로 넓히고 `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/` 와 정답지 넷을 만들며, README 에 여섯 · 아홉과 M18 · M19 를 기록한다 (PRESET-01, PRESET-02, PRESET-03, PRESET-07, PRESET-08, VERIFY-05; D-03 ~ D-06; 권고 1 ~ 5 · 11)

**Wave 4** *(blocked on Wave 3 completion — 소유자 확인(D-09 첫 push) 포함)*
- [x] 03-04-PLAN.md — `riverpod_lint` 하한을 `^3.1.9` 로 올려 정답지 다섯 불변을 단언하고, 소유자 확인 뒤 첫 push → GitHub `verify` 가 여섯으로 시간 제한 안에 통과하는 것을 보고 workflow 주석을 실측으로 고쳐 다시 올린다 (PRESET-05; D-01, D-09; 권고 9 의 C4 · 권고 10)

**Spike first** (이 phase 의 나머지를 계획하기 전에 실행으로 확인한다 — **2026-10-12 완료**: spike 009 ~ 012 가 네 항목에 답했고 013 ~ 019 가 맞물리는 자리를 쟀다. 멈춤 조건에 해당한 것 없음. `03-RESEARCH.md` 머리의 표 참조):
- 조사가 scratch 패키지와 `path:` 의존성으로만 확인한 두 가지를 이 저장소의 실제 구조에서 재현한다. (a) 이름이 `analysis_options.yaml` 이 아닌 파일(`riverpod.yaml`)의 `plugins:` 가 include 경유로 로드된다. (b) 그 구조에서 루트 분석의 `plugins_in_inner_options` 가 사라진다.
- 3단 include (`analysis_options.yaml` → `recommended.yaml` → 조각 파일)에서 `riverpod_lint` plugin 이 로드되는지. 조사의 실측은 2단까지다. 로드되지 않으면 옛 이름의 별칭이 plugin 을 소리 없이 잃는다.
- 위 항목이 하나라도 통과하지 못하면 phase 를 멈추고 소유자에게 돌아간다. 대안(plugin 을 패키지에서 빼고 README 로 안내하기 등)은 확정된 URI 결정을 바꾸는 일이다.
- plugin 이 `analyzer.exclude` 와 `// ignore_for_file` 을 존중하는지.

**Decision points** (이 phase 안에서 소유자가 정한다):
- **D6** — `riverpod_lint` 를 caret(`^3.1.9`)으로 둘지 정확한 버전으로 고정할지. PRESET-05 의 문구는 caret 을 전제하므로, 정확 고정을 고르면 요구사항 문구도 고쳐야 한다. 조사 권고는 caret 이다.
- **D7** — `invalid_annotation_target: ignore` 를 `codegen.yaml` 로 옮길지 삭제할지. PRESET-04 의 "분리 전과 같은 구성"과 기대 진단 불변 조건이 걸려 있다. 조사 권고는 옮기기다.

**Notes**:
- 묶음의 정식 이름은 `recommended.yaml` 이고(PRESET-08), 옛 URI `analysis_options.yaml` 은 이를 include 하는 한 줄짜리 별칭이다(PRESET-04). PROJECT.md Key Decisions 참조.
- 파일 분리와 `riverpod_lint` 하한 상향(PRESET-05)은 서로 다른 커밋으로 한다. 기대 진단이 바뀐다면 하한 상향 커밋에서만 바뀌어야 한다.
- 조각은 서로를 include 하지 않는다 (`base.yaml` 만 `flutter_lints` 를 include 한다). 조합은 include 하는 쪽이 한다.
- 규칙이 `base.yaml` 로 옮겨 가므로, Phase 2 의 deprecated / removed 검사가 새 위치를 대상으로 계속 실패를 잡는지 확인한다.
- **가장 먼저 할 일 (소유자 결정 2026-10-12, `02-UAT.md` 9번):** 정답지를 새로 쓰거나 fixture 를 더하기 전에, `tool/verify.dart` 의 `--update` 가 망가진 결과를 정답지로 쓰는 경로를 닫는다. `[2/4]` 가 통과로 잘못 찍히는 세 입력(닫지 않은 따옴표로 깨진 YAML, `rules:` 키의 오타, 겹친 규칙 + 없는 진단 코드)에서 `--update` 는 지금 `정답지를 썼다` · `점검 통과 (4개 중 4개)` · 종료 코드 0 으로 끝나고, 그 뒤의 보통 실행도 통과한다 (보통 실행을 먼저 돌리면 세 입력 모두 종료 코드 1 이다). 이 결정은 02-05 가 일부러 넣지 않은 WR-03 의 다른 절반(세 코드 밖의 진단도 `[2/4]` 의 실패로 치기)을 뒤집는다. `example/README.md` 80행 · 30행과 `[2/4]` 의 실패 문구도 코드가 실제로 보는 것에 함께 맞춘다. 재현과 근거는 `02-VERIFICATION.md` 의 "다음 phase 가 알아야 할 것" 1 ~ 5.
- 옛 URI 를 쓰는 fixture 를 남겨, 별칭이 plugin 을 잃는 일이 생기면 검증이 잡게 한다.
- pub workspace 멤버 패키지에서의 plugin 로드, plugin 내부 `riverpod` 버전과 사용 프로젝트 `riverpod` major 가 다를 때의 동작을 조사할지는 이 phase 에서 정한다 (README 호환 범위에 쓰인다).

### Phase 4: Rule Reselection

**Goal**: 배포 파일의 규칙 하나하나가 `flutter_starter_kit` 실측을 본 소유자의 결정으로 켜져 있고, 켠 이유와 켜지 않은 이유가 기록으로 남아 있다
**Depends on**: Phase 3
**Requirements**: RULES-01, RULES-02, RULES-03, RULES-04, RULES-05, RULES-06, RULES-07, RULES-08, DOCS-11
**Success Criteria** (what must be TRUE):
  1. 소유자가 후보 규칙(버그 방지, 성능, 가독성·스타일, strict 계열 `no_dynamic_casts` / `no_raw_types` / `strict-inference`)마다 `flutter_starter_kit` 복사본에서 잰 진단 건수와 `dart fix` 로 고칠 수 있는 건수를 표 하나에서 볼 수 있다
  2. 표의 수치마다 어느 실측 회차에서 나왔는지 따라갈 수 있다. 회차 기록에 SDK / 기반 세트 / plugin 버전이 적혀 있고, 일부러 넣은 위반이 보고되지 않은 회차의 수치는 쓰이지 않았다
  3. 후보 규칙마다 소유자의 채택 / 미채택 결정이 기록되어 있고, 배포 파일에서 켜진 규칙이 채택 목록과 일치한다
  4. 배포 파일에 기반 세트와 중복되는 선언과 주석 처리된 설정(`require_trailing_commas`, `public_member_api_docs`, `formatter: trailing_commas`)이 없고, 남은 규칙의 사유 주석이 사실과 일치한다
  5. 켠 규칙마다 이유와 실측 건수를 적은 근거 문서와, 채택하지 않은 규칙과 그 사유의 목록이 저장소에 있다

**Plans**: 13/13 plans complete (gap 수정 plan 04-11 · 04-12 실행 완료 2026-10-13 — 재검증 gaps_found 10/11, WR-10 하나 남음; 2회차 gap 수정 plan 04-13 실행 완료 2026-10-13 — 재검증 passed 11/11, WR-11 은 Phase 5 의 VERIFY-06 과 함께)

Plans:
**Wave 1** *(04-02 의 smoke 는 저장소 지문을 견주므로 04-01 과 같은 worktree 에서 동시에 돌리지 않는다 — worktree 가 다르면 병렬, 같으면 04-01 뒤)*
- [x] 04-01-PLAN.md — (tracer) `lib/base.yaml` 겹침 6 · 주석 3 삭제(정답지 불변) + `RULES.md` 뼈대 + `tool/verify.dart` `[3/10] 배포 파일의 구성` (묶음 · 별칭은 include 만 / 기반 세트 겹침 / `RULES.md` 일치) + README M20 ~ M24 · CHANGELOG (RULES-01, RULES-02, RULES-06; D-11, D-12, D-20)
- [x] 04-02-PLAN.md — `tool/measure_rules.dart` 핵심: CLI · 후보 133 · `state` 단계 · 복사본 단계 여섯 · 회차 유효성 · 저장소 지문 — `example/` 을 사용 프로젝트 삼은 smoke 로 끝에서 끝까지 (RULES-03, RULES-04, RULES-05; D-09)

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 04-03-PLAN.md — 규칙별 표식 (spike 022 의 0줄 후보 62개 + B-6 의 7개) 과 `--summary` · `--report [--write]` · `--audit` (RULES-03 ~ 05, RULES-08, DOCS-11; D-03, D-06, D-08)

**Wave 3** *(blocked on Wave 2 — 소유자가 checkpoint 로 원본 · 작업 폴더 경로를 준다)*
- [x] 04-04-PLAN.md — 실측 회차 R1 (백그라운드 두 번), 비공개 점검 (1) ~ (4), `tool/measurements/<날짜>-R1.json` 커밋 (RULES-03 ~ 05; D-07, D-14, D-15)

**Wave 4** *(blocked on Wave 3 — 소유자 결정 checkpoint 둘)*
- [x] 04-05-PLAN.md — `04-DECISIONS.md` 패널 · 권고 → 묶음 5 승인 → 개별 질문 7 (strict 3 · import · fire-and-forget · 쌍 · `unnecessary_underscores`) (로드맵 D13; D-04 ~ D-06, D-19)

**Wave 5** *(blocked on Wave 4)*
- [x] 04-06-PLAN.md — 반영 A: 지금 켜 둔 6개 (D-18 사유 문구) · 버그 방지 + import + fire-and-forget · strict — 묶음별 커밋, 샘플 6벌, 정답지 다섯, `RULES.md`, CHANGELOG (RULES-06, RULES-07, DOCS-11; D-10, D-20)

**Wave 6** *(blocked on Wave 5)*
- [x] 04-07-PLAN.md — 반영 B: 성능 · 가독성·스타일 · 켜지 않은 규칙 표 완성 (제외 권장 · 쌍 · v2 12 · B-7 31) — `--audit` 보류 1 (RULES-06, RULES-08, DOCS-11)

**Wave 7** *(blocked on Wave 6 — 소유자 checkpoint 둘)*
- [x] 04-08-PLAN.md — `unnecessary_ignore` 재측정 (회차 UI · UI-base) → 질문 → 반영, `--audit` 보류 0 (RULES-06, RULES-08; D-17)

**Wave 8** *(blocked on Wave 7)*
- [x] 04-09-PLAN.md — `RULES.md` 실측 기록 (`--report --write`) · CHANGELOG `### 새로 생기는 경고` 표 · README M25 · 03 리뷰 WR-01 ~ 03 · 로드맵 D-23 (RULES-03, RULES-05, RULES-07, RULES-08, DOCS-11; D-12, D-23)

**Wave 9** *(blocked on Wave 8 — 소유자 확인(D-22 첫 push))*
- [x] 04-10-PLAN.md — push 전 점검 → 첫 push 확인 → push 와 GitHub `verify` 10단계 통과 확인 (RULES-01, RULES-06; D-22)

**Wave 10** *(gap 수정 — 04-VERIFICATION.md 의 gap 둘과 소유자가 묶은 리뷰 지적 WR-02 · WR-05 · WR-06, CR-03 은 v2 메모; blocked on Wave 9)*
- [x] 04-11-PLAN.md — (tracer) 측정 도구가 `pubspec.yaml` 자리의 진단을 값에 넣고(CR-01, `valueAreas`) 단언 (7) · `--recount` 로 R1 행 재계산(`sort_pub_dependencies` 0 → 2, 회차는 그대로) · `fixSkipped` · 가린 줄 부호째(WR-02) · `--report --write`; `[3/10]` 이 열 0 주석 뒤의 규칙도 읽음(CR-02) · 기반 세트 YAML 0규칙 guard 두 도구(WR-06) · README M26 (RULES-01, RULES-03, RULES-05, RULES-06, RULES-08; D-02, D-07, D-11)

**Wave 11** *(blocked on Wave 10)*
- [x] 04-12-PLAN.md — `sort_pub_dependencies` 켬 (소유자 재결정 2026-10-13 — 실측 2줄 모두 `pubspec.yaml`, 같은 잣대) — `lib/base.yaml` 81 · `RULES.md` 표 · pubspec 샘플 6 · 정답지 5 를 한 커밋으로; CHANGELOG 75 · `04-DECISIONS.md` 재결정 행; README 수치(WR-05) · CR-03 v2 메모(REQUIREMENTS RULES-13) · DISPOSITION `deferred` (RULES-03, RULES-06, RULES-07, RULES-08, DOCS-11; D-08, D-10, D-20)

**Wave 12** *(gap 수정 2회차 — 재검증 04-VERIFICATION.md 에 남은 gap 하나(진실 6, 04-REVIEW.md WR-10)와 소유자가 묶은 IN-08 · IN-10 · WR-09 메모; blocked on Wave 11)*
- [x] 04-13-PLAN.md — (tracer) `[3/10]` 의 `declaredRuleNames` 가 따옴표 이름을 읽고 `linter:` 블록 안의 읽지 못하는 줄에서 `FormatException` (70) 으로 멈춤(WR-10 — 입력 하나가 아니라 결함 꼴을 닫음) · README M27 ~ M31; `RULES.md` `sort_pub_dependencies` 실측 칸을 합계 앞으로(IN-08) · README `added_rules.dart` 문장(IN-10); WR-09 를 RULES-13 v2 메모 · DISPOSITION `deferred` (RULES-01, RULES-06, DOCS-11; D-07, D-08, D-09, D-10, D-11)

**Spike first** (실측을 돌리기 전에 실행으로 확인한다 — **2026-10-12 완료**: spike 020 ~ 023 이 네 항목에 답했다. 멈춤 조건에 해당한 것 없음. 로드맵 문구 가운데 그대로 쓸 수 없게 된 것은 Notes 에 반영했다. `04-RESEARCH.md` 와 skill `spike-findings-woody-lints` 참조):
- Dart 3.13 신규 규칙이 language version 3.11 프로젝트에서 보고되는지 (`flutter_starter_kit` 의 SDK 제약은 `^3.11.1`). 0건이 "깨끗하다"인지 "규칙이 동작하지 않는다"인지가 여기서 갈린다.
- `flutter_starter_kit` 에 이미 있는 `// ignore` 주석(`cast_nullable_to_non_nullable` 56건, `discarded_futures` 2건 등)의 경위와, 프로젝트 자체 옵션이 기준선에 섞이는지.
- 복사본의 `woody_lints` 의존성이 작업 중인 파일을 가리키는지. lockfile 이 1.3.0 커밋을 가리키면 엉뚱한 것을 잰다 (`path:` 로 덮어쓴다).
- fix 가능으로 표기된 규칙이 실제로 `dart fix` 로 고쳐지는지 (`dart fix --dry-run`). `sort_pub_dependencies` 는 출처마다 `hasFix` 와 `needsFix` 로 어긋난다.

**Decision points** (이 phase 안에서 소유자가 정한다):
- **D13** — 규칙별 채택 여부. 실측 표를 본 뒤 규칙마다 소유자가 정한다 (strict 계열, `unnecessary_ignore`, import 스타일 `always_use_package_imports` 대 `prefer_relative_imports`, fire-and-forget 표기법 포함). 이 phase 는 소유자 검토 없이는 끝나지 않는다.
- **D14** — 기본 프리셋에 `formatter:` 를 넣을지. REQUIREMENTS.md 의 Out of Scope 표와 RULES-02 는 "넣지 않는다"로 적혀 있다. 다르게 정하려면 요구사항을 먼저 고쳐야 한다.

**Notes**:
- 실측은 `flutter_starter_kit` 복사본에서만 한다. 원본 프로젝트는 수정하지 않는다.
- 평가표의 칸은 상태(저장소 하한 분석 + `messages.yaml`) / 강도(실측 JSON) / 실측 건수(무시 주석을 둔 채, `lib` · `test` · `bin`) / `dart fix` 로 사라진 줄 / 고친 뒤 새 error / 무시 주석이 가린 줄 / 상류 세트 / 함께 쓸 수 없는 규칙이다. `rules.json` 은 쓰지 않는다 (spike 020 · 022). 칸이 하나라도 비면 그 규칙은 결정하지 않는다 (04-CONTEXT.md D-02).
- 패키지 루트에서 인자 없이 `dart analyze --format=json` 을 돌리고, 기준선(1.3.0) 대비 차이만 규칙의 값으로 쓴다. `lib/` 과 `test/` 를 나눠 집계하고, 함께 쓸 수 없는 쌍은 쌍마다 둘만 켜서 확인한다 (spike 020).
- strict 계열은 lint 형태(`no_dynamic_casts`, `no_raw_types`)로 잰다. `strict-casts` 옵션은 error 를 내 사용 프로젝트의 `dart analyze` 를 즉시 실패시킨다.
- 규칙이 바뀌면 `example/` 기대 진단도 바뀐다. 이 phase 에서 바뀌는 기대 진단은 규칙 결정과 하나씩 대응해야 한다.
- DOCS-11(근거 문서)은 결정과 수치가 나오는 이 phase 에 둔다. 미채택 목록(RULES-08)과 한 쌍이다.

### Phase 5: Documentation

**Goal**: 소유자가 몇 달 뒤 README 만 보고 설치, 프리셋 선택, 규칙 재정의, 버전 올리기를 그대로 따라 할 수 있고, README / CHANGELOG / YAML 주석이 실제 설정과 일치하며 그 일치가 검증으로 지켜진다
**Depends on**: Phase 4
**Requirements**: DOCS-01, DOCS-02, DOCS-03, DOCS-04, DOCS-05, DOCS-06, DOCS-07, DOCS-08, DOCS-09, DOCS-10, VERIFY-06
**Success Criteria** (what must be TRUE):
  1. 소유자가 README 의 설치 안내와 프로젝트 유형별 include 블록(전체는 `recommended.yaml`, 기본만, 기본 + Riverpod 등)을 그대로 복사해 새 프로젝트에 `ref: vX.Y.Z` 로 이 패키지를 추가할 수 있다
  2. README 에 규칙을 한 줄 / 파일 / 프로젝트 단위로 끄는 방법, plugin 진단을 끄는 방법, 버전 올리기(`ref:` 수정과 `pub get`), `ref: main` 에서 tag 로 옮기는 방법, 문제 해결 절이 있고, 재정의 방법은 Phase 3 의 fixture 가 확인한 것과 같다
  3. README 의 규칙·설정 설명이 실제 YAML 과 일치하고(현재의 불일치 2건 해소), 규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다
  4. CHANGELOG 최상단에 새 릴리스 항목이 Phase 1 에서 정한 형식으로 있고(추가·삭제 규칙, 지원 SDK 변경, 규칙별 실측 건수와 `dart fix` 가능 여부), 1.0.0 과 1.3.0 사이 항목이 git 이력으로 확인되는 범위에서 채워져 있다
  5. 배포 YAML 의 머리 주석이 실제 구성(조각 파일, 묶음, 옛 이름 별칭)을 설명하고, README 와 YAML 에 템플릿 보일러플레이트가 남아 있지 않다

**Plans**: 15/15 plans complete (검증 gaps_found 23/25, 2026-10-14 — README 규칙 목록 reader 와 (b′) 가 읽지 못하는 줄을 건너뛰는 gap 2건, `05-VERIFICATION.md`; gap 수정 plan 05-07 ~ 05-09 실행 완료 2026-10-14, push `92d478a..8789cfe` · verify run 38502214557 success — 재검증 gaps_found 50/53: 지난 gap 둘은 닫힘, `declaredRuleNames` 가 `linter :` · `"linter":` 철자의 조각 규칙을 건너뛰는 새 gap 1건 (재리뷰 WR-07 ~ WR-10 · IN-08 은 경고 · 정보) — 2회차 gap 수정 계획됨 (05-10 · 05-11, 2026-10-14) — 소유자 결정 2026-10-14: gap 둘 + 같은 모양의 reader 넷(Q1) · 문장 넷(Q2) · 맞는 값에서 실패하는 곳과 코드 정리(Q3) · WR-06 은 D-09 대로 미룸(Q4); 2차 결정 2026-10-14: 고정 버전은 받기(R2-Q1) · 옵션 reader(R2-Q2) · 다른 패키지 주소(R2-Q3) · measure 주석만(R2-Q4); 2회차 소유자 결정 2026-10-14: 조각마다의 닫힌 목록으로 gap 과 WR-10 을 함께(G2-Q1) · WR-07 ~ WR-09 · IN-08 은 문장 좁히기(G2-Q2) · 표시 구역 밖 목록 줄 검사 더함(G2-Q3); Round 2: riverpod 의 plugins: 아래 명단(G2-Q4) · tool/verify.dart 의 (e) ~ (g) 주석 좁히기(G2-Q5); 05-10 실행 완료 2026-10-14 — 닫힌 목록 · 표시 구역 밖 목록 줄 · 문장 좁히기, 커밋 02966c4 · 204e401 · d2d74c4; 05-11 실행 완료 2026-10-14 — 처리 기록 open 0 (b8519d4), push `8789cfe..b8519d4` · verify run 38522962086 success — 재검증 gaps_found 62/66 (2026-10-14): 지난 gap 은 닫힘, 주석 줄 끝의 CR 뒤에 숨긴 규칙 · 옵션을 (a′) · `declaredRuleNames` 가 건너뛰는 새 gap 1건(WR-11)과 좁힌 문장 둘이 아직 넓은 gap 1건(WR-13 · WR-14) — 3회차 gap 수정 계획됨 (05-12 · 05-13, 2026-10-14) — 3회차 소유자 결정 2026-10-14: YAML 을 줄로 나누는 자리를 모두 LineSplitter 하나로(G3-Q1) · WR-13 · WR-14 는 문장만 코드에 맞춤(G3-Q2) · WR-12 · IN-09 는 문장으로(G3-Q3); Round 2: `pubspecReleaseVersion` 도 같은 도우미로 줄마다(G3-R2-Q1) · 측정 도구는 두기(G3-R2-Q2); 05-12 실행 완료 2026-10-14 — splitYamlLines 줄 나누기 · 문장 맞춤, 커밋 d771c0c · d8b61b0; 05-13 실행 완료 2026-10-14 — 처리 기록 open 0 (c2f275a), push `b8519d4..c2f275a` · verify run 38568654401 success — 재검증 gaps_found 74/78 (2026-10-14): 지난 gap 둘은 닫힘, 줄 단위 reader 가 여러 줄 스칼라 · 중복 키를 YAML 과 다르게 읽는 새 gap 1건(WR-15 · WR-16 과 역방향 입력 — 소유자 결정 A · B · C 필요)과 펜스 안 네 칸 ``` 줄을 문장이 적지 않는 gap 1건(IN-10) — 4회차 gap 수정 계획됨 (05-14 · 05-15, 2026-10-15) — 4회차 소유자 결정 2026-10-14: 루트 `dev_dependencies` 의 `yaml` 로 줄 단위 reader 의 값을 YAML 해석 결과와 견주고 D-11 을 이 목적에 한해 다시 정함(G4-Q1, 길 B) · IN-10 · IN-11 은 문장 · 주석만(G4-Q2); Round 2 · 3 (2026-10-15): skill 세 줄의 "`dart:io` · `dart:convert` 만" 을 제자리에서 고침(G4-R2-Q1 · G4-R3-Q1) · README 380행 · `example/README.md` 11행에 `pubspec.yaml` 이 바뀐 뒤 `fvm dart pub get` 구절(G4-R2-Q2); 05-14 · 05-15 실행 완료 2026-10-15 — 처리 기록 open 0 (2336ba0), push `c2f275a..2336ba0` · verify run 38639587080 success — 재검증 human_needed 92/92 (2026-10-15): 지난 gap 둘 닫힘, 새 헛통과 없음, 경고 셋(IN-12 · IN-13 · IN-14 — 처리 시점은 소유자 결정), 사람 확인 6건 → `05-UAT.md`)

Plans:

**Wave 1**
- [x] 05-01-PLAN.md — (tracer) `tool/verify.dart` 결함 둘 닫기: WR-02 (`stripPlugins` 빈 줄 치환 · `readShippedPluginConstraint` 줄 끝 주석 · 맵 형식, M32 ~ M34) · WR-11 / IN-14 (`[3/10]` (b′) 다른 조각에 규칙 없음, `declaredRuleNames(shownAs)`, M35 ~ M37 — M37 이 줄 번호 보존과 (b′) 의 범위를 가른다) + 처리 기록 셋 (VERIFY-06 의 전제, DOCS-10 의 전제; D-19)

**Wave 2** *(blocked on Wave 1 — `lib/riverpod.yaml` 주석은 WR-02 뒤에)*
- [x] 05-02-PLAN.md — 배포 YAML 다섯의 머리 주석 (템플릿 삭제 · `codegen.yaml` 신설 · `riverpod.yaml` 줄이기, 정답지 불변) + `.claude/CLAUDE.md` 71 · 181행 (DOCS-10; D-08, D-09)

**Wave 3** *(blocked on Wave 2 — 05-03 · 05-04 는 파일이 겹치지 않아 나란히; 05-04 가 가리키는 README 절 제목은 05-03 이 글자로 고정)*
- [x] 05-03-PLAN.md — README 전면 재작성 (tag 설치 · 프리셋 표 · 표시 구역 81개 · 끄기 · 생성 파일 · 버전 올리기 · 문제 해결 · workspace 문장) 을 먼저 커밋하고, 그 다음 커밋에 `[3/10]` (d) ~ (g) README 검사 (DOCS-01 ~ 06, VERIFY-06; D-01 ~ D-04, D-10 ~ D-16, D-18, D-20)
- [x] 05-04-PLAN.md — CHANGELOG 1.1.0 ~ 1.2.5 복원 7항목 + 2.0.0 `### 올리기 전에` · `### 그 밖의 변경` 정리 + DOCS-07 · 09 확인 + 01 WR-05 fixed (DOCS-07 ~ 09; D-05 ~ D-07, D-17, D-19)

**Wave 4** *(blocked on 05-03)*
- [x] 05-06-PLAN.md — README 검사 넷의 지워 보기 M38 ~ M42 (규칙 이름 삭제 · 뒤쪽 블록의 주소 오타 · plugin 버전 · `ref:` · 마커 삭제) 를 실제로 돌려 `example/README.md` 에 기록 (VERIFY-06; D-01, D-02)

**Wave 5** *(blocked on Wave 3 · 4 — 첫 push 는 소유자 확인)*
- [x] 05-05-PLAN.md — push 전 비공개 점검 (범위 전체) → 첫 push 확인 checkpoint (blocking-human) → `git push origin gsd/v2.0-package-rework` 와 GitHub `verify` 확인 (D-21)

**Wave 6** *(gap 수정 — 05-VERIFICATION.md 의 gap 둘과 05-REVIEW.md IN-06; blocked on Wave 5)*
- [x] 05-07-PLAN.md — (tracer) README 표시 구역 reader 가 빈 줄 · `**분류**` · `- `이름`` 밖의 줄을 `[3/10]` 실패로 (gaps 1, M43 · M44) · 마커 처리를 `readMarkerBlock` · `MarkerBlock` 하나로 (IN-06) · `linter:` 줄의 flow 표기를 종료 코드 70 으로 (gaps 2 · WR-04, M45 · M46) · README 378행 문장 · 코드 블록 값 (f) · (g) 의 따옴표 · 줄 끝 주석 · 꼴, `unquotedScalar` (WR-02, M47 ~ M50) — 지워 보기는 `git clone --local` 복제본에서 (VERIFY-06, DOCS-06; D-01, D-02, D-20)

**Wave 7** *(blocked on Wave 6 — 같은 모양의 reader, 소유자 승인 2026-10-14 Q1 · 2차 R2-Q2 ~ Q4)*
- [x] 05-08-PLAN.md — `RULES.md` 표 reader 가 머리 줄 · 구분 줄 · backtick 이름 행 밖의 줄을 실패로 (M51 ~ M53, `없음 — …` 빈 표 줄은 행이 없을 때만) · `tool/measure_rules.dart` 의 `readRulesTable` 문서 주석만 (R2-Q4) · README 주소의 꼴 (WR-01) · `woody_lints` 가 아닌 패키지 주소 (R2-Q3) · `~~~` 와 펜스 길이 (WR-03) (M54 ~ M58) · `analyzer:` · `language:` 의 flow 표기와 읽지 못하는 옵션 줄을 70 으로 (R2-Q2, M59 ~ M62) (VERIFY-06; D-01, D-02, D-20)

**Wave 8** *(blocked on Wave 7 — 소유자 승인 Q2 · Q3 · Q4; 같은 브랜치 push 는 D-21 대로 실행 뒤 보고)*
- [x] 05-09-PLAN.md — plugin 선언 reader 의 따옴표 · 고정 버전(R2-Q1) · 맵 안의 키 순서 · 범위 제약은 원인을 말하는 70 (WR-05) · pubspec 따옴표 (IN-01) · 주석 단계 번호 (IN-05) (M63 ~ M67); README 45 · 91 · 239 · 372 · 382행 · `lib/riverpod.yaml` 줄 끝 주석 · CHANGELOG 92행 (W4 · IN-02 · IN-03 · IN-04 · IN-07); 처리 기록 fixed 12 · deferred 1 (WR-06 — D-09); push 전 범위 비공개 점검 → push → GitHub `verify` (VERIFY-06, DOCS-06, DOCS-07; D-09, D-16, D-20, D-21)

**Wave 9** *(2회차 gap 수정 — 05-VERIFICATION.md 의 gap 하나와 05-REVIEW.md 재리뷰 WR-07 ~ WR-10 · IN-08, 소유자 결정 2026-10-14 G2-Q1 ~ G2-Q3; blocked on Wave 8)*
- [x] 05-10-PLAN.md — (tracer) 조각마다 받는 최상위 키와 `lib/codegen.yaml` 의 `analyzer:` 아래 키를 닫힌 목록으로 — 다른 철자의 `linter` 키 · `formatter:` · `language:` · 열 0 밖의 최상위 키를 `[3/10]` 실패로 (2회차 gap · WR-10, M68 ~ M73, 회귀 입력 M45 · M46 · M36 · M34 · M59 · M60 · M61 · M62 · M63 · M65 · M66) · `lib/riverpod.yaml` 의 `plugins:` 아래는 `riverpod_lint` 만 (M78, G2-Q4) · README 378행 (G2-Q1); 표시 구역이 든 절의 구역 밖 목록 줄을 `[3/10]` 실패로 (M74 ~ M77, G2-Q3); README 382행 · `example/README.md` 116 · 358 · 395 · 436행 · `tool/verify.dart` 의 주석 줄을 (e) · (f) · (g) 의 실제 범위로, 코드 줄은 그대로 (WR-07 ~ WR-09 · IN-08, G2-Q2 · G2-Q5) — 지워 보기는 복제본에서 (VERIFY-06, DOCS-06; D-01, D-02, D-20)

**Wave 10** *(blocked on Wave 9 — 같은 브랜치 push 는 D-21 대로 실행 뒤 보고)*
- [x] 05-11-PLAN.md — 처리 기록 WR-10 fixed · WR-07 ~ WR-09 · IN-08 skipped (open 0), CHANGELOG 는 그대로 (VERSIONING.md — 저장소 안쪽); push 전 범위 `8789cfe..HEAD` 비공개 점검 → `git push origin gsd/v2.0-package-rework` → GitHub `verify` (VERIFY-06; D-07, D-09, D-20, D-21)

**Wave 11** *(gap 수정 3회차 — 05-VERIFICATION.md 의 gap 둘(CR 하나로 나뉜 줄 · 아직 넓은 문장 둘)과 05-REVIEW.md 재리뷰 WR-11 ~ WR-14 · IN-08 · IN-09, 소유자 결정 2026-10-14 G3-Q1 ~ G3-Q3; blocked on Wave 10)*
- [x] 05-12-PLAN.md — (tracer) `tool/verify.dart` 에서 YAML 을 줄로 나누는 자리 여섯(`stripPlugins` · `declaredRuleNames` · `findUnexpectedKeys` · `enabledLanguageOptions` · `readShippedPluginConstraint` · `copyLines`)을 도우미 `splitYamlLines` (`LineSplitter` — CR · LF · CRLF) 하나로, CR 뒤에 숨긴 규칙 · 옵션 · 키 · plugin 을 `[3/10]` 실패로 (gap 1 · WR-11, 전체 실행 M79 ~ M82 · 함수 단위 M83 ~ M85, 회귀 M33 · M37 · M45 · M61, G3-Q1) · `pubspecReleaseVersion` 도 같은 도우미로 나눈 줄을 한 줄씩 — U+2028 로 숨긴 `version:` 이 아니라 진짜 값 (함수 단위, G3-R2-Q1); README 382행 · `example/README.md` 116 · 395 · 518 · 549행 · `tool/verify.dart` 의 (e) · (f) · (g) 주석을 실제 범위로, 코드 줄은 그대로 (gap 2 · WR-12 · WR-13 · WR-14 · IN-08 · IN-09, G3-Q2 · G3-Q3) — 지워 보기는 복제본에서 (VERIFY-06, DOCS-06; D-01, D-02, D-20)

**Wave 12** *(blocked on Wave 11 — 같은 브랜치 push 는 D-21 대로 실행 뒤 보고)*
- [x] 05-13-PLAN.md — 처리 기록 WR-11 · IN-09 fixed · WR-12 · WR-13 · WR-14 skipped (open 0), CHANGELOG 는 그대로 (VERSIONING.md — 저장소 안쪽); push 전 범위 `b8519d4..HEAD` 비공개 점검 → `git push origin gsd/v2.0-package-rework` → GitHub `verify` (VERIFY-06, DOCS-06; D-07, D-09, D-20, D-21)

**Wave 13** *(gap 수정 4회차 — 05-VERIFICATION.md 의 gap 둘(여러 줄 스칼라 · 중복 키를 줄 단위 reader 가 YAML 과 다르게 읽음 · 펜스 안 네 칸 펜스 줄을 문장이 적지 않음)과 05-REVIEW.md 재리뷰 WR-15 · WR-16 · IN-10 · IN-11, 소유자 결정 2026-10-14 G4-Q1 · G4-Q2 · Round 2 · 3 2026-10-15 G4-R2-Q1 · G4-R2-Q2 · G4-R3-Q1; blocked on Wave 12)*
- [x] 05-14-PLAN.md — (tracer) 루트 `pubspec.yaml` 의 `dev_dependencies` 에 `yaml` (D-11 을 이 목적에 한해 다시 정함 — 받는 쪽에는 전달되지 않음) · `tool/verify.dart` 의 `[3/10]` 끝에 (h) `compareLineReadersWithYaml` — 줄 단위 reader 다섯(규칙 · 최상위 키와 그 바로 아래 키 · analyzer 옵션 · `riverpod_lint` 선언 · pubspec version)의 값을 `package:yaml` 이 읽은 값과 견주고 YAML 로 읽지 못하는 파일도 실패, 지금 reader 와 메시지는 그대로 (gap 1 · WR-15 · WR-16, 전체 실행 M86 ~ M89 · 함수 단위 M90 · M91, 회귀 M79 · M37 · M45 · M61 · M66, G4-Q1) · 같은 커밋에서 skill 세 줄(`SKILL.md` 52행 · `references/analyze-run-and-verdict.md` 13행 · `references/rule-status-check.md` 14행)을 새 의존성 규칙으로, README 380행 · `example/README.md` 11행에 `pubspec.yaml` 이 바뀐 뒤 `fvm dart pub get` (G4-R2-Q1 · G4-R2-Q2 · G4-R3-Q1); README 382행 · `example/README.md` 116 · 395행 · `fencedLines` · `checkShippedComposition` 주석에 펜스 안의 네 칸 이상 들여 쓴 펜스 줄(IN-10), `stripPlugins` 주석의 줄 수(IN-11), 코드 줄은 그대로 (gap 2, G4-Q2) — 지워 보기는 복제본에서 (VERIFY-06, DOCS-06; D-01, D-02, D-20)

**Wave 14** *(blocked on Wave 13 — 같은 브랜치 push 는 D-21 대로 실행 뒤 보고)*
- [x] 05-15-PLAN.md — 처리 기록 WR-15 · WR-16 · IN-11 fixed · IN-10 skipped (open 0), CHANGELOG 는 그대로 (VERSIONING.md — 저장소 안쪽); push 전 범위 `c2f275a..HEAD` 비공개 점검(`.claude/skills/` 는 세 줄만) → `git push origin gsd/v2.0-package-rework` → GitHub `verify` — 새 checkout 이 `yaml` 을 받는지 (VERIFY-06, DOCS-06; D-07, D-09, D-20, D-21)

**Decision points** (이 phase 안에서 소유자가 정한다):
- **D10** — README 의 규칙 목록을 어떻게 유지할지: 생성 스크립트 / YAML 로 링크만 / 사람이 맞춤 / 마커 구역과 비교 스크립트. VERIFY-06 이 "다르면 실패"를 요구하므로 비교 검사 하나는 있어야 한다. 조사 권고는 생성까지 가지 않는 비교 검사다.

**Notes**:
- **가장 먼저 할 일 (04-CONTEXT.md D-12):** `tool/verify.dart` 의 WR-02 (거짓 실패 — `lib/riverpod.yaml` 의 plugin 줄 끝 주석 · 마지막 줄바꿈 없음에서 `stripPlugins` · `readShippedPluginConstraint` 가 종료 코드 70) 를 YAML 머리 주석(DOCS-10)을 고치기 전에 닫는다 (`03-REVIEW.md` WR-02).
- **VERIFY-06 과 함께 닫을 것 (`04-REVIEW.md` WR-11, 소유자 결정 2026-10-13):** `[3/10]` 의 겹침 (b) · `RULES.md` 일치 (c) 는 `lib/base.yaml` 만 읽어, `lib/codegen.yaml` · `lib/riverpod.yaml` 에 적은 규칙은 사용 프로젝트에 적용되는데도 두 검사를 지나친다 (복사본에서 rc 0 재현, 지금 조각 넷의 규칙은 0개). VERIFY-06 이 같은 비교를 README 로 넓힐 때 비교 대상을 `lib/base.yaml` 하나로 잡으면 같은 빈자리가 README 쪽에도 생긴다 — 배포 YAML 다섯 전체에서 규칙을 모으거나, `lib/base.yaml` 밖 조각에 규칙이 없음을 먼저 확인한다. `declaredRuleNames` 를 다른 파일에 쓰면 그 `FormatException` 문구에 파일 이름을 넣는다 (IN-14).
- README 는 묶음의 정식 이름 `package:woody_lints/recommended.yaml` 을 안내하고, 옛 이름은 "예전 이름"으로만 적는다.
- 도구 동작은 fixture 로 뒷받침되는 것만 단정형으로 쓴다. `riverpod_lint` 심각도가 Phase 2 에서 확정되기 전에는 "프리셋을 include 하면 종료 코드 2" 같은 문장을 쓰지 않는다.
- 빠지기 쉬운 내용: exclude 는 사용 프로젝트에서 되돌릴 수 없다, plugin 진단 재정의에는 `version` 이 필수다, `dev_dependencies` 의 `riverpod_lint` 제거, plugin 변경 뒤 Analysis Server 재시작, 버전 올리기는 `pub upgrade` 가 아니라 `ref:` 수정과 `pub get` 이다 (현재 README 는 `pub upgrade` 를 안내한다), tag 를 고정해도 plugin 버전은 바뀔 수 있다, `ref: main` 프로젝트가 받는 영향.
- README 를 쓰기 전에 확인할 것: `analyzer.errors` 로 `invalid_annotation_target` 을 되살릴 때의 기본 심각도.
- README 는 생성 파일 제외의 범위를 밝힌다 — `codegen.yaml` 이 주는 제외는 Dart 3.13.x 의 규칙 진단에만 통하고 `riverpod_lint` (plugin) 진단에는 통하지 않는다. plugin 진단까지 막으려면 사용 프로젝트의 옵션 파일에 직접 적으라고 안내한다 (spike 012 · 016, Phase 3 UAT 1번 — 2026-10-12 소유자 확인).
- README 의 `ref: vX.Y.Z` 예시는 Phase 6 에서 만들 tag 를 가리킨다. 버전 번호는 Phase 1 에서 정한 값을 쓴다.

### Phase 6: Release

**Goal**: 새 버전이 annotated tag 로 원격에 있어 사용 프로젝트가 `ref: vX.Y.Z` 로 버전을 고정할 수 있고, 그 tag 를 git 의존성으로 받은 프로젝트에서 규칙과 plugin 이 실제로 적용됨이 확인되어 있다
**Depends on**: Phase 5
**Requirements**: REL-02, REL-03, REL-04
**Success Criteria** (what must be TRUE):
  1. tag 이름, `pubspec.yaml` 의 version, CHANGELOG 최상단 버전이 서로 다르면 실패하는 검사가 CI 의 tag 트리거에 걸려 있고, 일부러 어긋나게 만든 입력에서 실제로 실패함이 확인되어 있다
  2. `git ls-remote --tags origin` 에 새 버전의 annotated tag 가 보이고, 그 tag 의 `pubspec.yaml` version 과 CHANGELOG 최상단 버전이 tag 이름과 같다
  3. 빈 프로젝트가 새 tag 를 git 의존성(`ref: vX.Y.Z`)으로 받아 `dart analyze` 를 돌리면 기본 규칙 진단과 `riverpod_lint` plugin 진단이 둘 다 보고된다

**Plans**: 15/15 plans executed — 06-01 ~ 06-07 첫 실행 (검증 gaps_found 40/41), gap 수정 06-08 ~ 06-11 실행 완료 2026-10-16 (PR #2 → `main` `0038572`) — 재검증 gaps_found 60/63: CHANGELOG 최상단 reader 가 GitHub 과 갈리는 꼴 둘(한 글자 밑줄 setext · 블록 안의 `<!--`)과 smoke 의 UTF-8 아닌 출력, `06-VERIFICATION.md`; **gap 수정 2회차 06-12 ~ 06-15 는 2026-10-16 계획 · 2026-10-17 실행 완료 (PR #3 → `main` `3418989`) — 재검증 human_needed 82/82, UAT 대기 (`06-UAT.md` 둘)** — 소유자 결정 G7-Q1 (나) 첫 줄 고정 · G7-Q2 smoke 여섯 · G7-Q3 main 병합까지, 06-REVIEW.md 열 발견(아홉 fixed · IN-08 deferred), 11 waves (gap 수정 1회차 4 는 2026-10-16 계획 — 06-VERIFICATION.md 40/41: REL-03 의 version · CHANGELOG 최상단 reader, 06-REVIEW.md 일곱 발견; 소유자 결정 G6-Q1 ~ G6-Q3; 06-01 ~ 06-07 은 2026-10-15 계획 — 06-CONTEXT.md D-01 ~ D-14, 06-RESEARCH.md)

Plans:

**Wave 1** *(파일이 겹치지 않아 나란히 — 06-01 `tool/verify.dart` · `example/README.md` · `.github/workflows/verify.yml` 7행, 06-02 `README.md` · `VERSIONING.md`, 06-03 `tool/smoke.dart`; worktree 격리로 — 같은 트리에서는 서로의 'HEAD 와 같다' 단언이 겹치므로 격리가 꺼져 있으면 차례로)*
- [x] 06-01-PLAN.md — (tracer) `tool/verify.dart` `[3/10]` 에 버전 일치 확인 (i) 와 `--tag vX.Y.Z` 인자 · `GITHUB_REF_TYPE` / `GITHUB_REF_NAME` · stderr 모드 줄 (REL-03; D-04 · D-05), IN-12 코드 (`keysSeenByLineReader` 의 `keyLikePattern`) · IN-14 주석 · 05-UAT 5번 문장 (D-13), 지워 보기 M92 ~ M97 을 복제본에서 돌려 `example/README.md` 에 기록하고 D-06 의 다섯 입력 · D-05 의 날짜 꼴을 함수 단위 하네스로 다시 단언 (D-05 · D-06); `.github/workflows/verify.yml` 7행 주석만 현재형으로 (소유자 결정 2026-10-15 R2-Q2)
- [x] 06-02-PLAN.md — README 「설치」 · 「프로젝트 전체」 · 「생성 파일 제외」 의 기존 키 합치기 문장과 `plugins:` 블록 측정 문장 (D-14), 34 · 355 · 381행 (05-UAT 4 · 2, D-11); `VERSIONING.md` 「릴리스 절차」 1 ~ 10 과 plugin 새 버전 대응 단락, 82행 현재형 (D-11 · D-12)
- [x] 06-03-PLAN.md — `tool/smoke.dart <ref> [--keep]` — 저장소 밖 임시 폴더에서 `flutter create` → README 대로 → 새 `PUB_CACHE` 로 받기 → 두 주소로 `dart analyze` → D-09 (2) · (3) 판정; 하위 명령은 고정 SDK 의 `bin/flutter` · dart 로만(저장소 밖 임시 폴더); origin 의 커밋 `2336ba0` 으로 통과 실행, 실패 방향 셋 — 없는 ref · annotated tag `v1.3.0` (tag 경로를 tag push 전에) · 앞선 브랜치 이름 (REL-04; D-08 · D-09 · D-10)

**Wave 2** *(blocked on Wave 1 — 릴리스 커밋은 손질 · 검사 · 스크립트 뒤에; 본 체크아웃에서, 같은 브랜치 push 는 D-21 대로 실행 뒤 보고)*
- [x] 06-04-PLAN.md — 릴리스 커밋 (`version: 2.0.0` · IN-13 주석 · CHANGELOG 날짜 · `VERSIONING.md` 「실제 사례」 67 · 69행 현재형 (소유자 결정 2026-10-15 R2-Q1) · lock 여섯을 `fvm dart pub get` 으로만) 과 평소 · `--tag v2.0.0` 10/10 (D-01 1 · 3, D-12 (2)) → push gate (범위 `2336ba0…HEAD` 의 더해진 줄 전부에 비공개 점검, fail-closed — push 전에 따로) → `git push origin gsd/v2.0-package-rework` → GitHub `verify` (평소 모드 줄) (D-01 2, D-21) → 예행 `tool/smoke.dart <릴리스 커밋>` 과 D-14 측정 — 저장소 밖 측정은 고정 SDK 의 dart 로 (D-01 4, D-07, D-14)

**Wave 3** *(blocked on Wave 2 — tag push 는 소유자 직전 확인, one-way)*
- [x] 06-05-PLAN.md — 예행 통과 커밋에 로컬 annotated tag `v2.0.0` 과 4중 점검 → checkpoint (blocking-human — 고정 SDK 로 README 를 손으로 따라 한 결과와 smoke 단계와의 대조를 함께, 05-UAT 1번; `tag` / `readme` / `script` / `hold`) → `git push origin v2.0.0` → `ls-remote` · CI 의 tag 실행 로그 (`버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)`) · `tool/smoke.dart v2.0.0` (REL-02 · REL-03 · REL-04; D-01 5 ~ 8, D-06, D-09)

**Wave 4** *(blocked on Wave 3 — `main` 병합은 소유자 직전 확인, one-way)*
- [x] 06-06-PLAN.md — push gate (범위 `v2.0.0^{commit}..HEAD`) 뒤 남은 기록 커밋 push → PR (`main` ← 작업 브랜치) 과 `pull_request` 실행 (02-UAT 4번) → checkpoint (blocking-human) → `gh pr merge --merge` (merge commit 만) → `v2.0.0` 이 `main` 의 조상 · `main` push 실행 → `gh workflow run verify.yml --ref main` 과 `workflow_dispatch` 실행 (02-UAT 6번; 버튼은 human-check → 06-UAT) (REL-02; D-01 9, D-02, D-03)

**Wave 5** *(blocked on Wave 4)*
- [x] 06-07-PLAN.md — 처리 기록: `02-UAT.md` 4 · 6번 pass, `05-UAT.md` 1 · 2 · 4 · 5번 `closed_in`, `05-REVIEW-DISPOSITION.md` IN-12 · IN-13 · IN-14 fixed (open 0, deferred 는 WR-06 — D-09)

**Wave 6** *(gap 수정 — 06-VERIFICATION.md 40/41 · 06-REVIEW.md 일곱 발견, 소유자 결정 2026-10-16 G6-Q1 ~ G6-Q3; 파일이 겹치지 않아 나란히 — worktree 격리, 꺼져 있으면 06-08 → 06-09 차례로)*
- [x] 06-08-PLAN.md — `[3/10]` (i) 의 version 을 `package:yaml` 값으로 · (h) 의 pubspec 비교를 원문 전체로 · `pubspecReleaseVersion` 을 `pubspecVersionText` 위에 (CR-01 · IN-03), `changelogTop` 을 `package:markdown` (새 dev 의존성) 으로 해석한 첫 h2 (깊이 무관, U+FEFF 떼기) 로 (WR-02 · 검증자의 HTML 주석 꼴 — G6-Q1 (가)); 복제본에서 꼴 아홉을 세 경로(평소 · `--tag` · `GITHUB_REF_NAME`)로 실패시키고 고치기 전 판과 대조해 M98 ~ M106 기록; skill 세 줄 · `example/README.md` 11행의 의존성 문장을 `yaml` · `markdown` 둘로 (G6-R2-Q1) (REL-03; D-04 · D-05)
- [x] 06-09-PLAN.md — `tool/smoke.dart`: `judge` 가 include 사슬 진단을 두 주소 각각의 실패 사유로 더하고 `(reasons, shown)` 을 돌려줌 (WR-01 · IN-02), 단계별 시간 제한(create 2분 · pub get 5분 · analyze 5분 — 넘으면 끊고 69) · `finally` · SIGINT(130) 정리 (WR-03 · IN-01), 오프라인 하네스 · SIGINT 끝에서 끝까지 · 전체 smoke `v2.0.0` 회귀 (REL-04; G6-Q2; D-09 · D-10)

**Wave 7** *(blocked on Wave 6)*
- [x] 06-10-PLAN.md — `06-REVIEW-DISPOSITION.md` 일곱 발견 fixed (open 0) → push gate(범위의 더해진 줄 전부에 비공개 점검, fail-closed) → `git push origin gsd/v2.0-package-rework` → GitHub `verify` (push) → PR (`main` ← 작업 브랜치) → `pull_request` 실행 (REL-03 · REL-04; G6-Q3 의 앞 절반, D-21)

**Wave 8** *(blocked on Wave 7 — `main` 병합은 소유자 직전 확인, one-way)*
- [x] 06-11-PLAN.md — checkpoint (blocking-human) → `gh pr merge --merge` (merge commit 만) → 부모 둘(첫 부모 `5ee5a12`) · 고침 커밋 셋 · `v2.0.0` 이 `main` 의 조상 · `main` push 실행 success; tag · 버전 · CHANGELOG 는 그대로 (REL-03 · REL-04; G6-Q3, D-02)

**Wave 9** *(gap 수정 2회차 — 06-VERIFICATION.md 60/63 의 gap 둘 · 06-REVIEW.md 열 발견, 소유자 결정 2026-10-16 G7-Q1 ~ G7-Q3; 파일이 겹치지 않아 나란히 — worktree 격리, 꺼져 있으면 06-12 → 06-13 차례로)*
- [x] 06-12-PLAN.md — (tracer) `tool/verify.dart` 의 `changelogTop` 을 **파일 첫 줄 고정**으로: U+FEFF 뗀 첫 줄이 엄격한 `## X.Y.Z - …` 이고 `package:markdown` 첫 h2(깊이 무관)와 같아야 통과, 아니면 `[3/10]` 블록 (G7-Q1 (나) — WR-02 · WR-05); 머리 주석 · 문서 주석 · `pubspec.yaml` 19 · 21행 · skill 세 줄(IN-09 포함) · `VERSIONING.md` 「CHANGELOG 항목 형식」 한 줄; 복제본에서 M107 ~ M115(한 글자 `-` setext · 블록 안의 `<!--` · 머리말 · 장식 · 닫는 `##` — 대표 여섯은 세 경로 전체 실행)와 M100 ~ M106 재측정을 `example/README.md` 에 (REL-03; D-04 · D-05 · D-06)
- [x] 06-13-PLAN.md — `tool/smoke.dart`: `runProcess` 의 UTF-8 아닌 출력 허용(IN-04 — gap) · 제한을 출력 수집까지(WR-06) · `judge` 의 종료 코드 3 · error 없음 규칙과 `included_file_parse_error`(WR-04) · SIGINT 의 띄우는 창과 finally 순서(IN-05) · `killTree` 의 안내 · 재확인 · 범위 문장(IN-06) · `scrubNamesFor` 하나(IN-07); 오프라인 하네스 · SIGINT 끝에서 끝까지 · 전체 smoke `v2.0.0` 회귀 (REL-04; G7-Q2; D-09 · D-10)

**Wave 10** *(blocked on Wave 9)*
- [x] 06-14-PLAN.md — `06-REVIEW-DISPOSITION.md` 아홉 발견 fixed · IN-08 deferred (open 0) → push gate(범위의 더해진 줄 전부에 비공개 점검, fail-closed) → `git push origin gsd/v2.0-package-rework` → GitHub `verify` (push) → PR (`main` ← 작업 브랜치) → `pull_request` 실행 (REL-03 · REL-04; G7-Q3 의 앞 절반, D-21)

**Wave 11** *(blocked on Wave 10 — `main` 병합은 소유자 직전 확인, one-way)*
- [x] 06-15-PLAN.md — checkpoint (blocking-human) → `gh pr merge --merge` (merge commit 만) → 부모 둘(첫 부모 `0038572`) · 고침 커밋 셋 · `v2.0.0` 이 `main` 의 조상 · `main` 의 고침 글자 · `main` push 실행 success; tag · 버전 · CHANGELOG 는 그대로 (REL-02 · REL-03 · REL-04; G7-Q3, D-02)

**Decision points** (이 phase 안에서 소유자가 정한다):
- **D9 (결정됨, 2026-10-11)** — `git.create_tag` 를 껐고 마일스톤 번호를 `v2.0` 으로 맞췄다. GSD 는 tag 를 만들지 않으며, 이 저장소의 `v` tag 는 패키지 릴리스(`vX.Y.Z`)에만 쓴다. 릴리스 tag 는 이 phase 에서 직접 만든다.
- 릴리스 tag 를 다는 커밋과 `main` 병합의 순서. GSD 흐름에서 milestone 브랜치의 `main` 병합은 이 phase 가 끝난 뒤 `/gsd-complete-milestone` 이 제안한다. tag 를 병합 전 milestone 브랜치에 달지 `main` 의 병합 커밋에 달지, squash 로 합칠지를 계획 때 정한다.
- 릴리스 tag push 와 `main` 병합은 원격에 남는 작업이다. `main` 병합은 `ref: main` 을 따르는 사용 프로젝트 5개에 새 버전이 배포되는 순간이므로, 둘 다 실행 시점에 소유자 확인을 받는다. push 한 tag 는 옮기지 않는다.

**Notes**:
- git 의존성으로 받은 프리셋의 `plugins:` 로드는 지금까지 `path:` 의존성으로만 확인되어 있고, smoke test 가 이를 처음 확인하는 자리다. tag 를 push 한 뒤에 실패를 발견하면 patch 릴리스로만 고칠 수 있으므로, tag 를 달기 전에 milestone 브랜치를 `ref:` 로 받는 빈 프로젝트에서 먼저 확인할지 계획 때 검토한다.
- smoke test 를 어느 URI 로 할지(정식 이름 `recommended.yaml`, 옛 별칭, 둘 다)는 계획 때 정한다.
- **Phase 2 에서 미룬 확인 둘 (`02-UAT.md` 4번 · 6번, 소유자 결정 2026-10-12)** — 릴리스 때에만 볼 수 있어 이 phase 로 넘겼다.
  - PR 에서 `verify` 가 도는가: `main` 병합을 PR 로 한다면, PR 을 연 직후 Actions 탭에 `pull_request` event 의 `verify` 실행이 생기고 단계 4개가 통과하는지 본다. `.github/workflows/verify.yml` 에 `pull_request:` 가 조건 없이 선언되어 있지만 PR 이 열린 적이 없다 (2026-10-12 기준 0건). PR 없이 합치기로 정하면 이 확인은 "해당 없음" 으로 닫는다.
  - 수동 실행 버튼: workflow 파일이 `main` 에 들어간 뒤 Actions → verify 화면에 `Run workflow` 버튼이 보이는지, 누르면 `workflow_dispatch` event 의 실행이 생겨 통과하는지 본다 (02-CONTEXT.md D-06).
- 사용 프로젝트에 새 버전을 적용하고 경고를 정리하는 일은 이 마일스톤의 범위 밖이다.
- **Phase 5 에서 미룬 리뷰 경고 셋 (`05-REVIEW.md` IN-12 · IN-13 · IN-14, 소유자 결정 2026-10-15)** — 05-VERIFICATION 4회차 재검증이 gap 아닌 경고로 판정했다. 셋 다 막는 쪽(통과로 끝나지 않음)이다.
  - IN-12: `lib/base.yaml` 의 `include:` 값을 다음 줄에 쓰면 `[3/10]` (h) 만 거짓 실패 — `tool/verify.dart` 의 `keysSeenByLineReader` 가 값 없는 최상위 키 아래의 스칼라 값 줄을 "아래 키" 로 담는다.
  - IN-13: `pubspec.yaml` 13 ~ 15행의 `dependencies` 주석이 기반 세트를 include 하는 파일을 `lib/analysis_options.yaml` 로 적는다 (지금은 `lib/base.yaml`) — 이 phase 가 version 을 바꿀 때 함께 고친다.
  - IN-14: `loadYaml` 이 `!!float` 한 글자 값에서 `RangeError` 를 던져 main 을 지나 종료 코드 255 — `compareLineReadersWithYaml` 문서 주석과 머리 주석의 종료 코드 목록이 이를 적지 않는다.
  - `tool/verify.dart` · `pubspec.yaml` 을 고치면 그 뒤의 검증(`fvm dart run tool/verify.dart` 10/10, 실패 방향)을 다시 본다.
- **Phase 5 UAT 에서 미룬 문서 손질 넷 (`05-UAT.md` 1 · 2 · 4 · 5번, 소유자 결정 2026-10-15)** — 넷 다 통과로 적고 넘겼다. 릴리스 tag 전의 README 커밋에서 함께 고친다.
  - 1번: smoke test 에서 `flutter create` 로 만든 빈 프로젝트에 README 를 그대로 따라 한다. Flutter 3.47.5 앱 템플릿의 옵션 파일에는 이미 `include: package:flutter_lints/flutter.yaml` · `analyzer: exclude:` · `linter: rules:` 가 있다 (템플릿 파일에서 읽음) — README 「설치」 · 「생성 파일 제외」 · 「프로젝트 전체」 에 "기존 `include` 줄은 바꾸고, 같은 키는 합친다" 한 문장을 넣을지 본다. `base.yaml` 만 받는 사람이 「프로젝트 전체」 의 `plugins:` 블록을 붙이면 plugin 이 켜지는지도 본다 (추론).
  - 2번: README 355행 "`plugins:` 를 바꾼 뒤 … Analysis Server 를 재시작해야 반영된다" 에 출처 표시를 단다 — 1.3.0 의 주석에서 옮긴 문장이고 spike 에 재시작 실측이 없다.
  - 4번: README 34행을 사실대로 고친다 — flutter#191151 은 2026-08-19 에 병합됐고 stable 판 #191530 이 Flutter 3.47.2 부터 들어 있다 (3.47.5 의 동작이 이미 이것). 바뀐 것은 "있는 플랫폼 폴더만 제외 · Flutter 가 아닌 패키지는 건너뜀" 이고 `build/**` 는 그대로 덧붙이며 끄는 옵션은 없다 — "고치는 변경이 있다 (병합 여부는 확인하지 않았다)" 구절을 뺀다.
  - 5번: `example/README.md` (05-14) 소절 읽는 법의 "YAML (package:yaml — analyzer · pub 과 같은 해석기)" 에 "(판이 같은지는 재지 않았다)" 를 덧붙인다. 같은 읽는 법의 "깨진 YAML 도 블록 하나로 실패한다" 는 IN-14 와 함께 고친다.
  - README · `example/README.md` 를 고치면 `fvm dart run tool/verify.dart` 10/10 을 다시 본다 (`[3/10]` 이 README 를 견준다).

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Baseline and Toolchain | 4/4 | Complete    | 2026-10-11 |
| 2. Verification Harness | 5/5 | Complete    | 2026-10-12 |
| 3. Preset Split | 4/4 | Complete    | 2026-10-12 |
| 4. Rule Reselection | 13/13 | Complete    | 2026-10-13 |
| 5. Documentation | 15/15 | Complete    | 2026-10-15 |
| 6. Release | 15/15 | 재검증 human_needed 82/82 — UAT 대기 (`06-UAT.md`) | - |

## Backlog

### Phase 999.1: Follow-up — Phase 01 deferred UAT follow-up: Test 8 (BACKLOG)

**Goal:** Phase 01 검증 때 미룬 UAT 항목의 후속 작업을 마친다
**Source phase:** 01
**Deferred at:** 2026-10-11, `/gsd-verify-work 1` 세션 완료 시점
**Follow-ups:**
- [ ] Test 8: pass, 문장은 나중에 — (기록자 풀이) 8번은 통과이고, VERSIONING.md 30행에 전제 한 문장을 더하는 일만 나중으로 미룬다. 더할 내용: plugin 이나 기반 세트의 하한을 올릴 때는 새 하한 버전이 요구하는 Dart 버전을 보고, 그것이 이 패키지의 SDK 하한보다 높으면 판정 순서 1번의 첫째 조건(SDK 를 고쳐야 하나)이 예 다. 근거: riverpod_lint 3.1.9 는 Dart 3.13 이상, 3.1.3 은 3.10 이상을 요구한다 (01-VERIFICATION.md 의 coincidental_reliance_items) (deferred 2026-10-11)

### Phase 999.2: Follow-up — Phase 06 재리뷰 경고 IN-10 · IN-11 (BACKLOG)

**Goal:** gap 수정 2회차 뒤 재리뷰(`06-REVIEW.md`)가 찾은 info 둘을 다음에 그 파일을 손댈 때 고친다
**Source phase:** 06
**Deferred at:** 2026-10-17, `/gsd-execute-phase 06 --gaps-only` 검증 꼬리 (소유자 결정 — 미룸; verifier 판정 경고, 명시된 진실 밖)
**Follow-ups:**
- [ ] IN-10: `example/README.md` (06-08) 소절의 읽는 법 (4) · (5) 와 11행의 의존성 괄호를 06-12 뒤 동작에 맞춘다 — 지금 (5) 는 `# Changelog` 머리말이 통과한다고 현재형으로 말하지만 첫 줄 규칙 뒤로는 실패한다 (M113)
- [ ] IN-11: `tool/smoke.dart` 의 `killTree` 재확인 — SIGSTOP 이 성공한 pid 를 기록하고 SIGKILL 직전 표에 아직 남은 것은 사슬과 상관없이 끊어, 얼린 뒤 중간 프로세스가 먼저 끝난 자기 자손이 SIGCONT 로 풀려 살아남지 않게 한다 (reviewer · verifier 재현: P → A → B 에서 A 가 첫 표 직후 끝나면 B 가 남음); 06-13 must_have 4 의 "사슬 밖은 SIGCONT" 문장과 머리 주석의 범위 문장도 함께 고친다
