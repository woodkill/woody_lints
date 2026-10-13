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
- [ ] **Phase 4: Rule Reselection** - `flutter_starter_kit` 실측을 근거로 규칙을 하나씩 결정하고 근거를 기록
- [ ] **Phase 5: Documentation** - README / CHANGELOG / YAML 주석을 확정된 설정에 맞춰 다시 쓰고 일치를 검증으로 고정
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

**Plans**: 7/10 plans executed

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
- [ ] 04-08-PLAN.md — `unnecessary_ignore` 재측정 (회차 UI · UI-base) → 질문 → 반영, `--audit` 보류 0 (RULES-06, RULES-08; D-17)

**Wave 8** *(blocked on Wave 7)*
- [ ] 04-09-PLAN.md — `RULES.md` 실측 기록 (`--report --write`) · CHANGELOG `### 새로 생기는 경고` 표 · README M25 · 03 리뷰 WR-01 ~ 03 · 로드맵 D-23 (RULES-03, RULES-05, RULES-07, RULES-08, DOCS-11; D-12, D-23)

**Wave 9** *(blocked on Wave 8 — 소유자 확인(D-22 첫 push))*
- [ ] 04-10-PLAN.md — push 전 점검 → 첫 push 확인 → push 와 GitHub `verify` 10단계 통과 확인 (RULES-01, RULES-06; D-22)

**Spike first** (실측을 돌리기 전에 실행으로 확인한다):
- Dart 3.13 신규 규칙이 language version 3.11 프로젝트에서 보고되는지 (`flutter_starter_kit` 의 SDK 제약은 `^3.11.1`). 0건이 "깨끗하다"인지 "규칙이 동작하지 않는다"인지가 여기서 갈린다.
- `flutter_starter_kit` 에 이미 있는 `// ignore` 주석(`cast_nullable_to_non_nullable` 56건, `discarded_futures` 2건 등)의 경위와, 프로젝트 자체 옵션이 기준선에 섞이는지.
- 복사본의 `woody_lints` 의존성이 작업 중인 파일을 가리키는지. lockfile 이 1.3.0 커밋을 가리키면 엉뚱한 것을 잰다 (`path:` 로 덮어쓴다).
- fix 가능으로 표기된 규칙이 실제로 `dart fix` 로 고쳐지는지 (`dart fix --dry-run`). `sort_pub_dependencies` 는 출처마다 `hasFix` 와 `needsFix` 로 어긋난다.

**Decision points** (이 phase 안에서 소유자가 정한다):
- **D13** — 규칙별 채택 여부. 실측 표를 본 뒤 규칙마다 소유자가 정한다 (strict 계열, `unnecessary_ignore`, import 스타일 `always_use_package_imports` 대 `prefer_relative_imports`, fire-and-forget 표기법 포함). 이 phase 는 소유자 검토 없이는 끝나지 않는다.
- **D14** — 기본 프리셋에 `formatter:` 를 넣을지. REQUIREMENTS.md 의 Out of Scope 표와 RULES-02 는 "넣지 않는다"로 적혀 있다. 다르게 정하려면 요구사항을 먼저 고쳐야 한다.

**Notes**:
- 실측은 `flutter_starter_kit` 복사본에서만 한다. 원본 프로젝트는 수정하지 않는다.
- 평가표의 열을 고정한다: `state` / 심각도 / `fixStatus` / 실측 건수 / `dart fix` 가능 건수 / 상류 세트 포함 여부. 하나라도 비면 그 규칙은 결정하지 않는다. 규칙 메타데이터는 SDK tag 고정 `rules.json` 을 기준으로 삼는다.
- 패키지 루트에서 인자 없이 `dart analyze --format=json` 을 돌리고, 기준선(1.3.0) 대비 차이만 규칙의 값으로 쓴다. `lib/` 과 `test/` 를 나눠 집계하고, 양립 불가 쌍은 한쪽씩 나눠 돌린다.
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

**Plans**: TBD

**Decision points** (이 phase 안에서 소유자가 정한다):
- **D10** — README 의 규칙 목록을 어떻게 유지할지: 생성 스크립트 / YAML 로 링크만 / 사람이 맞춤 / 마커 구역과 비교 스크립트. VERIFY-06 이 "다르면 실패"를 요구하므로 비교 검사 하나는 있어야 한다. 조사 권고는 생성까지 가지 않는 비교 검사다.

**Notes**:
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

**Plans**: TBD

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

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Baseline and Toolchain | 4/4 | Complete    | 2026-10-11 |
| 2. Verification Harness | 5/5 | Complete    | 2026-10-12 |
| 3. Preset Split | 4/4 | Complete    | 2026-10-12 |
| 4. Rule Reselection | 7/10 | In Progress | - |
| 5. Documentation | 0/TBD | Not started | - |
| 6. Release | 0/TBD | Not started | - |

## Backlog

### Phase 999.1: Follow-up — Phase 01 deferred UAT follow-up: Test 8 (BACKLOG)

**Goal:** Phase 01 검증 때 미룬 UAT 항목의 후속 작업을 마친다
**Source phase:** 01
**Deferred at:** 2026-10-11, `/gsd-verify-work 1` 세션 완료 시점
**Follow-ups:**
- [ ] Test 8: pass, 문장은 나중에 — (기록자 풀이) 8번은 통과이고, VERSIONING.md 30행에 전제 한 문장을 더하는 일만 나중으로 미룬다. 더할 내용: plugin 이나 기반 세트의 하한을 올릴 때는 새 하한 버전이 요구하는 Dart 버전을 보고, 그것이 이 패키지의 SDK 하한보다 높으면 판정 순서 1번의 첫째 조건(SDK 를 고쳐야 하나)이 예 다. 근거: riverpod_lint 3.1.9 는 Dart 3.13 이상, 3.1.3 은 3.10 이상을 요구한다 (01-VERIFICATION.md 의 coincidental_reliance_items) (deferred 2026-10-11)
