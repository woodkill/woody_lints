---
last_mapped_commit: 8ac96b71e9d394c5d1dfb132814ee87379519c69
last_mapped_at: 2026-10-17
---
<!-- refreshed: 2026-10-17 -->

# Architecture

**Analysis Date:** 2026-10-17

## System Overview

```text
┌──────────────────────────────────────────────────────────────────────┐
│ 받는 쪽 Flutter 프로젝트의 analysis_options.yaml                         │
│   include: package:woody_lints/<이름>.yaml   (git 의존성, ref: main/vX.Y.Z) │
└───────────────┬──────────────────────────────────────────────────────┘
                ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 공개 URI (공개 API) — lib/ 의 YAML 다섯                                  │
│  별칭 `lib/analysis_options.yaml` ──include──▶ 묶음 `lib/recommended.yaml` │
│  묶음 ──include──▶ 조각 셋 (서로 include 하지 않음)                        │
│   ├ `lib/base.yaml`     linter.rules + include flutter_lints          │
│   ├ `lib/riverpod.yaml` 최상위 plugins: riverpod_lint ^3.1.9          │
│   └ `lib/codegen.yaml`  analyzer.errors / analyzer.exclude            │
└───────┬───────────────────────────────────────────┬──────────────────┘
        │ include: (pub 의존성 그래프)                │ plugins: (Analysis Server)
        ▼                                           ▼
┌───────────────────────────────┐   ┌───────────────────────────────────┐
│ package:flutter_lints/flutter.yaml │   │ ~/.dartServer/ plugin 캐시          │
│  → package:lints (core/recommended)│   │  riverpod_lint 를 pub.dev 에서 받아   │
│  `pubspec.yaml` dependencies      │   │  컴파일 (선언 범위 안 최신)            │
└───────────────────────────────┘   └───────────────────────────────────┘

저장소 안쪽 검증 (받는 쪽에 전달되지 않음)
┌──────────────────────────────────────────────────────────────────────┐
│ `tool/verify.dart` [1/10]~[10/10]  ◀── `.github/workflows/verify.yml`    │
│   ├ lib/ · RULES.md · README.md · CHANGELOG.md · pubspec.yaml 대조      │
│   └ `example/` + `fixtures/*` 를 dart analyze → expected_diagnostics.txt │
│ `tool/smoke.dart <ref>`   GitHub 에서 받아 보는 릴리스 확인               │
│ `tool/measure_rules.dart` 일회성 실측 → `tool/measurements/*.json` → RULES.md │
└──────────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| 옛 주소 별칭 | 1.x 사용 프로젝트용 공개 URI. `include: package:woody_lints/recommended.yaml` 한 줄만 담는다 | `lib/analysis_options.yaml:4` |
| 묶음 (recommended) | 조각 셋을 list 형식 `include:` 로 묶는다 | `lib/recommended.yaml:4-7` |
| 기본 조각 (base) | `flutter_lints` 상속 + 추가 규칙 전부 (성능 / 가독성 및 스타일 / 버그 방지 / strict 분류) | `lib/base.yaml` |
| Riverpod 조각 | 최상위 `plugins:` 에 `riverpod_lint: ^3.1.9` | `lib/riverpod.yaml:4-5` |
| codegen 조각 | `invalid_annotation_target: ignore`, `**/*.freezed.dart` · `**/*.g.dart` exclude | `lib/codegen.yaml:4-9` |
| 패키지 매니페스트 | `version: 2.0.0`, `sdk: ^3.13.0`, `flutter_lints` 를 `dependencies` 로 전달, 검증 도구용 dev 의존성(`yaml`, `markdown`) | `pubspec.yaml` |
| 자체 분석 설정 | 저장소 루트 분석. `flutter_lints` 만 include, `example/**` · `fixtures/**` exclude | `analysis_options.yaml` |
| 검증 명령 | 배포 파일 구성 · 문서 일치 · 연습용 프로젝트 진단 대조 (10단계) | `tool/verify.dart` |
| 릴리스 smoke test | 빈 Flutter 프로젝트가 GitHub 에서 `<ref>` 를 받아 두 주소로 분석 | `tool/smoke.dart` |
| 규칙 실측 도구 | 후보 133개의 상태 · 건수 · `dart fix` 건수를 재고 RULES.md 실측 구역을 쓴다 | `tool/measure_rules.dart` |
| 연습용 프로젝트 | 일부러 규칙을 어긴 샘플 + 정답지 | `example/`, `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/` |
| CI | 모든 push · PR · 수동 실행에서 `dart run tool/verify.dart` | `.github/workflows/verify.yml` |
| 규칙 근거 문서 | 켠 규칙 표, 켜지 않은 규칙, 실측 기록(`woody:measurements` 구역) | `RULES.md` |
| 버전 정책 | 등급 판정 순서 · 기준표 · CHANGELOG 형식 · 릴리스 절차 | `VERSIONING.md` |
| SDK 고정 | Flutter `3.47.5` (FVM) | `.fvmrc`, `.vscode/settings.json` |

## Pattern Overview

**Overall:** 설정 전용 패키지(configuration-only package) — include 합성(composition by include) 과 조각(preset fragment) 분리, 그리고 정답지 기반 검증(golden-file verification).

**Key Characteristics:**
- `lib/` 에 `.dart` 파일이 없다. 배포 산출물은 `lib/*.yaml` 다섯이며 `[1/10]` 이 `.dart` 부재를 검사한다 (`tool/verify.dart:4`).
- 파일 이름이 곧 공개 API 다: `package:woody_lints/<이름>.yaml` 은 `lib/` 바로 아래 같은 이름의 파일로 해석된다. 옛 주소 `package:woody_lints/analysis_options.yaml` 은 "기본 + Riverpod + codegen" 뜻을 유지한다 (`lib/analysis_options.yaml:1-3`). URI 를 없애거나 뜻을 바꾸면 major (`VERSIONING.md:38`).
- 조각끼리는 서로 include 하지 않는다. 묶음만 조각 셋을 include 하고, 별칭은 묶음만 include 한다. 규칙은 `lib/base.yaml` 에만 둔다 (`lib/base.yaml:3`, `[3/10]` 이 다른 조각의 규칙을 실패로 본다 — `tool/verify.dart:6`).
- 두 해석 경로가 공존한다: `include:` 는 pub 의존성 그래프, `plugins:` 는 Dart Analysis Server 의 plugin 캐시.
- 배포는 git 의존성 + tag 뿐이다 (`pubspec.yaml:6` `publish_to: 'none'`, `pubspec.yaml:8` repository `https://github.com/woodkill/woody_lints.git`).

## Layers

**상류 기반 세트 (external):**
- Purpose: Flutter 공식 권장 lint
- Location: `package:flutter_lints/flutter.yaml` → `package:lints`
- Contains: core / recommended / flutter 규칙
- Depends on: `flutter_lints: ^6.0.0` (`pubspec.yaml:16-17`)
- Used by: `lib/base.yaml:5`, 루트 `analysis_options.yaml:6`

**조각 (fragments):**
- Purpose: 받는 쪽이 골라 받는 최소 단위
- Location: `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`
- Contains: 조각마다 정해진 최상위 키만 — base 는 `include` · `linter` · `analyzer`, codegen 은 `analyzer`(아래 `errors` · `exclude`), riverpod 은 `plugins`(아래 `riverpod_lint`) (`README.md` 「이 저장소를 고치는 사람에게」 첫 항목)
- Depends on: 상류 기반 세트(base 만), plugin 캐시(riverpod 만)
- Used by: 묶음, 또는 받는 쪽이 직접

**묶음 · 별칭 (aggregates):**
- Purpose: 한 줄로 전부 받기, 옛 주소 호환
- Location: `lib/recommended.yaml`, `lib/analysis_options.yaml`
- Contains: `include:` 만 (`[3/10]` 이 "묶음 · 별칭은 include 만 담는지" 검사 — `tool/verify.dart:6`)
- Used by: 받는 쪽 프로젝트

**저장소 안쪽 도구 (repo-internal):**
- Purpose: 배포 파일이 문서 그대로 적용되는지 증명
- Location: `tool/`, `example/`, `fixtures/`, `.github/workflows/verify.yml`, 루트 `analysis_options.yaml`
- Depends on: `.fvmrc` 의 SDK, dev 의존성 `yaml` · `markdown` (`pubspec.yaml:23-25`)
- Used by: 저장소 기여자, CI. 받는 쪽에는 전달되지 않는다 (`analysis_options.yaml:1-2`)

## Data Flow

### Primary Request Path (받는 쪽의 정적 분석)

1. 받는 쪽 `pub get` 이 git 의존성(`ref: main` 또는 `ref: vX.Y.Z`)으로 `woody_lints` 와 그 `dependencies`(`flutter_lints`)를 받는다 (`pubspec.yaml:13-17`).
2. analyzer 가 받는 쪽 `include:` 를 따라 `lib/analysis_options.yaml` → `lib/recommended.yaml` (`lib/analysis_options.yaml:4`) → 조각 셋 (`lib/recommended.yaml:5-7`) → `package:flutter_lints/flutter.yaml` (`lib/base.yaml:5`) → `lints` 로 내려간다. 아래 계층(받는 쪽)이 위를 덮어쓴다.
3. `linter.rules` 는 list 형식으로 합쳐지고, `analyzer.errors` · `analyzer.exclude` 는 `lib/codegen.yaml` 에서 온다.
4. include 로 받은 최상위 `plugins:` 도 받는 쪽 루트 옵션 파일에 적용된다 (spike 009 — `.claude/skills/spike-findings-woody-lints/references/preset-split-structure.md`).

### Analyzer Plugin 로드 경로

1. Analysis Server 가 `plugins: riverpod_lint: ^3.1.9` (`lib/riverpod.yaml:5`) 를 읽는다.
2. pub.dev 에서 범위 안 최신을 받아 plugin 캐시에 컴파일한다 — 받는 쪽 `pubspec.lock` 이 묶지 못한다 (`example/README.md` 「파일」 표의 `pubspec.lock` 행, `VERSIONING.md:151-153`).
3. 받는 쪽이 진단을 끄려면 `plugins: riverpod_lint: version:` 을 다시 적고 `diagnostics:` 를 단다 — 그 값이 선언을 통째로 대신한다 (`fixtures/overrides/analysis_options.yaml:8-12`, `tool/verify.dart` 의 `pluginConstraintToken` 주석, spike 012).

### 검증 흐름 (`tool/verify.dart`)

1. 준비: 실행 SDK 가 `.fvmrc` 와 같은지(다르면 종료 코드 78), 루트 · 연습용 프로젝트 전부 `pub get` (실패 69) (`tool/verify.dart:23-24`, `:31-35`).
2. `[1/10]` `lib/` 에 `.dart` 없음.
3. `[2/10]` 조각 셋 복사본(`build/woody_rule_check/`)을 분석해 deprecated / removed / 없는 규칙 · 옵션 경고 · 깨진 YAML 이 0건.
4. `[3/10]` 배포 파일 구성과 문서 일치 — 묶음 · 별칭은 include 만, `lib/base.yaml` 규칙이 기반 세트와 겹치지 않음, `RULES.md` 켠 규칙 표 · README 표시 구역(`README.md:95-190` `woody:readme-rules`) 과 같음, 조각별 최상위 키 목록, README 의 프리셋 주소 · plugin 버전 · `ref:`, 줄 단위 읽기와 `package:yaml` 해석 일치, tag · `pubspec.yaml` version · `CHANGELOG.md` 최상단 버전 일치 (`tool/verify.dart:6`).
5. `[4/10]` 연습용 프로젝트 여섯의 `analysis_options.yaml` 이 `fixtures` 표의 `optionsLines` 와 같음 (`tool/verify.dart` `const fixtures`).
6. `[5/10]`~`[10/10]` 연습용 프로젝트마다 별도 상태 폴더(`.dart_tool/woody_verify/<폴더>/`)로 `dart analyze` → `expected_diagnostics.txt` 와 줄 · 건수 대조. 순서 example → recommended → base_only → base_riverpod → base_codegen → overrides; `recommended` 는 정답지 없이 같은 실행의 `example` 결과와 견준다 (`example/README.md` 「연습용 프로젝트 여섯」).
7. `--update` 는 모든 단계가 통과할 때만 정답지 다섯을 다시 쓴다. CI 에서는 거부(64) (`tool/verify.dart:10-15`).

### 규칙 실측 → 문서 흐름

1. `tool/measure_rules.dart --work <저장소 밖 폴더>` 가 사용 프로젝트 복사본에서 단계(state · baseline · groups · markers · ignore · fix · unnecessary-ignore)를 잰다 (`tool/measure_rules.dart:1-35`).
2. 결과 JSON 을 `tool/measurements/2026-10-13-R1.json` 꼴로 남긴다 (건수와 조건만, 비공개 경로 · 진단 문장 없음 — `tool/measure_rules.dart:37-38`).
3. `--report --write` 가 단언 통과 시에만 `RULES.md:218-425` 의 `woody:measurements` 구역을 쓴다. 결정된 규칙은 사람이 `lib/base.yaml` · `RULES.md` 켠 규칙 표 · README 표시 구역에 같은 커밋으로 반영하고, `[3/10]` 이 셋의 일치를 지킨다.

### 릴리스 흐름

1. milestone 브랜치(현재 `gsd/v2.0-package-rework`)에서 준비 중에는 `version: X.Y.Z-dev` 와 `## X.Y.Z - 미출시` 를 함께 둔다 (`VERSIONING.md:130-162` 의 1, 10단계).
2. 릴리스 커밋: `-dev` 제거, CHANGELOG 날짜, lock 여섯 `pub get` 으로 다시 받기, README `ref:` 예시 갱신, `verify.dart --tag vX.Y.Z` 통과 (2단계).
3. 브랜치 push → CI → `tool/smoke.dart <릴리스 커밋>` 예행 (3-4단계).
4. annotated tag `vX.Y.Z` 를 달고 tag 하나만 push → CI 의 tag 실행 확인(`GITHUB_REF_NAME`) → `tool/smoke.dart vX.Y.Z` (5-8단계). 존재하는 tag: `v1.3.0`, `v2.0.0` (`git tag`).
5. `gh pr create --base main` → `gh pr merge --merge` (merge commit 만, squash · rebase 금지) → `main` 이 릴리스 채널이 된다 (9단계). `ref: main` 프로젝트는 각자 `pub upgrade woody_lints` 때 받는다.

**State Management:**
- 실행 시점 상태 없음. 버전 상태는 `pubspec.yaml:3` 의 `version`, `CHANGELOG.md` 첫 줄, git tag 셋이 맞물려 있다 (`[3/10]` 이 견준다).
- 검증 도구의 상태: `.dart_tool/woody_verify/` (plugin 컴파일 캐시, 지우지 않음), `build/woody_rule_check/` (실행 중 임시, `.gitignore:18-20`).

## Key Abstractions

**공개 프리셋 URI:**
- Purpose: 받는 쪽이 고르는 단위
- Examples: `lib/recommended.yaml`, `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/analysis_options.yaml`
- Pattern: `lib/` 바로 아래 파일 = `package:woody_lints/<파일>`. 네 조합(Riverpod × codegen)이 모두 연습용 프로젝트로 덮인다 (`example/README.md` 「연습용 프로젝트 여섯」 2×2 표).

**정답지 (expected diagnostics):**
- Purpose: "받는 프로젝트에서 무엇이 달라지는가" 의 기록
- Examples: `example/expected_diagnostics.txt`, `fixtures/base_only/expected_diagnostics.txt`, `fixtures/overrides/expected_diagnostics.txt`
- Pattern: `상대경로:줄  강도  규칙이름` 정렬, 머리 주석에 SDK · plugin 버전 · 날짜. "안 나와야 하는 것" 은 `example/lib/should_not_appear.dart`, `example/lib/generated/` 로 증명.

**Fixture 표:**
- Purpose: 연습용 프로젝트의 경로 · 옵션 줄 · plugin 사용 · 정답지를 한곳에서 정의
- Examples: `tool/verify.dart` 의 `const fixtures = <Fixture>[...]`
- Pattern: 표 순서가 곧 단계 순서. 새 연습용 프로젝트는 이 표에 행을 더한다 (단계 수 N = 4 + 표 길이).

**표시 구역 (marked regions):**
- Purpose: 도구가 읽고 쓰는 문서 구역
- Examples: `README.md:95-190` (`woody:readme-rules`), `RULES.md:218-425` (`woody:measurements`)
- Pattern: `<!-- woody:<이름>:start -->` / `:end -->` 주석 쌍.

## Entry Points

**`lib/analysis_options.yaml` / `lib/recommended.yaml`:**
- Location: `lib/`
- Triggers: 받는 쪽 `include: package:woody_lints/...`
- Responsibilities: 조각 합성

**`tool/verify.dart`:**
- Location: `tool/verify.dart`
- Triggers: `fvm dart run tool/verify.dart [--update] [--tag vX.Y.Z]`, CI
- Responsibilities: 10단계 검증. 종료 코드 0 / 1 / 64 / 69 / 70 / 78 / 255 (`tool/verify.dart:30-35`)

**`tool/smoke.dart`:**
- Location: `tool/smoke.dart`
- Triggers: `fvm dart run tool/smoke.dart <ref> [--keep]` (릴리스 4 · 7단계)
- Responsibilities: 저장소 밖 임시 프로젝트에서 새 pub cache · 새 상태 폴더로 두 주소 분석, 위반 둘(`prefer_single_quotes`, `provider_parameters`) 존재 · include 사슬 진단 부재 · lock 의 `resolved-ref` 확인. 종료 코드 0 / 1 / 64 (`tool/smoke.dart:1-45`)

**`tool/measure_rules.dart`:**
- Location: `tool/measure_rules.dart`
- Triggers: 규칙 후보 평가 때 수동 실행
- Responsibilities: 실측 JSON, `RULES.md` 실측 구역, `--audit`

**`.github/workflows/verify.yml`:**
- Triggers: 모든 브랜치 · tag push, `pull_request`, `workflow_dispatch` (`.github/workflows/verify.yml:8-11`)
- Responsibilities: `subosito/flutter-action@v2` 가 `.fvmrc` 로 SDK 설치 → `dart run tool/verify.dart`. timeout 10분, `permissions: contents: read`

## Architectural Constraints

- **Threading:** 해당 없음 (배포물에 실행 코드 없음). 검증 도구는 연습용 프로젝트를 차례로 분석한다 — 상태 폴더를 합치면 plugin 폴더가 여럿이 되어 버전을 읽지 못한다 (`tool/verify.dart` fixtures 주석, spike 014).
- **Global state:** 없음. 도구 쪽 공유 위치는 `.dart_tool/woody_verify/`, `build/woody_rule_check/`.
- **Circular imports:** 없음. include 는 별칭 → 묶음 → 조각 → `flutter_lints` → `lints` 단방향.
- **공개 URI 고정:** `lib/` 다섯 파일의 이름과 옛 주소의 뜻은 바꾸지 않는다 (`lib/analysis_options.yaml:1-3`, `VERSIONING.md:38`).
- **`plugins:` 는 최상위 키:** `analyzer: plugins:` 는 riverpod_lint 3.x 에서 아무것도 로드하지 않는다 (`lib/riverpod.yaml:2`).
- **include 대상은 `dependencies`:** `dev_dependencies` 는 받는 쪽 그래프에 전달되지 않는다 (`pubspec.yaml:13-17`). 반대로 `yaml` · `markdown` 은 받는 쪽에 가지 않게 일부러 `dev_dependencies` (`pubspec.yaml:19-25`).
- **SDK 하한:** `sdk: ^3.13.0` (`pubspec.yaml:11`), 고정 SDK Flutter 3.47.5 (`.fvmrc`). `avoid_final_parameters` 는 언어 버전 3.13 라이브러리에서 돌지 않는다 (`lib/base.yaml:28`).
- **동기 수정 묶음:** 규칙 변경 = `lib/base.yaml` + `RULES.md` 표 + README 표시 구역; plugin 하한 변경 = `lib/riverpod.yaml` + `fixtures/overrides/analysis_options.yaml` `version:` + README 예시 둘; 버전 변경 = `pubspec.yaml` + `CHANGELOG.md` + README `ref:` 예시 둘 + lock 여섯 (`lib/riverpod.yaml:5`, `README.md` 「이 저장소를 고치는 사람에게」, `VERSIONING.md` 2단계). 어긋나면 `[3/10]` / `[4/10]` 실패.
- **연습용 프로젝트 복사 규칙:** `fixtures/*/lib/` 는 `example/lib/` 의 글자 그대로 복사본 — 예외 `example/lib/relative_imports_rule.dart` 3행의 패키지 이름 (`example/README.md` 「연습용 프로젝트 여섯」).
- **`codegen.yaml` exclude 의 한계:** Dart 3.13.4 에서 규칙 진단에만 통하고 plugin 진단에는 통하지 않는다 (`lib/codegen.yaml:3`, spike 012 · 016).
- **plugin 버전은 tag 로 고정되지 않는다:** 정답지가 저장소 변경 없이 깨질 수 있다 (`VERSIONING.md:151-162`).
- **검증 명령은 `dart analyze`:** plugin 진단 확인용 (`README.md` 「`dart analyze` 와 `flutter analyze`」).

## Anti-Patterns

### `analyzer: plugins:` 로 plugin 선언

**What happens:** plugin 을 `analyzer:` 아래 리스트로 적는다.
**Why it's wrong:** riverpod_lint 3.x 는 analysis_server_plugin 방식만 지원해 아무것도 로드되지 않는다.
**Do this instead:** 최상위 `plugins:` 맵 (`lib/riverpod.yaml:4-5`).

### 규칙을 `lib/base.yaml` 밖에 적기

**What happens:** 묶음 · 별칭 · 다른 조각에 `linter:` 를 넣는다.
**Why it's wrong:** 조각 조합의 뜻이 흐려지고 `[3/10]` 이 실패한다.
**Do this instead:** `lib/base.yaml` 의 분류 주석 아래에 한 줄 + 한국어 이유 주석, 같은 커밋에서 `RULES.md` 와 README 표시 구역.

### 기반 세트와 겹치는 규칙

**What happens:** `flutter_lints` 가 이미 켜는 규칙을 `lib/base.yaml` 에 다시 적는다.
**Why it's wrong:** `[3/10]` 이 겹침을 실패로 본다 (2.0.0 에서 6개 제거 — `example/README.md` 「파일」 `example/lib/base_rules.dart` 행).
**Do this instead:** 기반 세트에 없는 규칙만 적는다.

### 루트 `analysis_options.yaml` 에 이 패키지 조각 include

**What happens:** 저장소 자체 분석에 `lib/` 조각을 끌어온다.
**Why it's wrong:** 규칙 변경이 검증 스크립트 진단과 섞인다 (`analysis_options.yaml:4-5`).
**Do this instead:** 루트는 `flutter_lints` 만 include 하고 `example/**` · `fixtures/**` 만 exclude 한다.

### 연습용 프로젝트에서 `flutter pub get`

**What happens:** `flutter pub get` 이 옵션 파일에 `build/**` exclude 를 써넣는다.
**Why it's wrong:** "include 한 줄" 이 깨져 `[4/10]` 실패 (`example/README.md` 「실행」 끝 문단).
**Do this instead:** `dart pub get`; 돌렸으면 `git checkout -- example/analysis_options.yaml`.

### squash / rebase 병합, tag 옮기기

**What happens:** `main` 병합을 squash 로 하거나 올린 tag 를 다른 커밋으로 옮긴다.
**Why it's wrong:** tag 커밋이 `main` 이력에서 빠지거나 받는 쪽 lock 의 `resolved-ref` 와 어긋난다.
**Do this instead:** `gh pr merge --merge`, 잘못 올린 tag 는 새 번호 (`VERSIONING.md` 릴리스 절차 5 · 9 · 10).

## Error Handling

**Strategy:** 배포물은 analyzer 진단 심각도 조정으로, 도구는 종료 코드로 실패를 구분한다.

**Patterns:**
- `invalid_annotation_target: ignore`, 생성 파일 exclude (`lib/codegen.yaml:5-9`).
- `tool/verify.dart`: plugin 준비 실패를 stderr 머리말 `An error occurred while executing an analyzer plugin:` 의 `contains` 로 판정 (`tool/verify.dart` `pluginFailureHeader`, spike 002 · 008). 실패 시 정답지를 쓰지 않는다.
- `tool/smoke.dart`: 어떻게 끝나도 임시 폴더 삭제, 출력의 임시 경로는 `<임시 폴더>` 로 가림 (`tool/smoke.dart:35-37`).

## Cross-Cutting Concerns

**Logging:** 도구는 단계 줄 `[n/10]` 과 stderr 안내(`버전 일치 검사:` 줄 등). 받는 쪽에는 `avoid_print` 가 기반 세트로 들어간다 (추론: `flutter_lints` 포함 규칙).
**Validation:** `tool/verify.dart` 가 단일 판정자, CI 는 실행만 한다 (`.github/workflows/verify.yml:1`).
**Authentication:** 해당 없음. CI 는 읽기 권한만 (`.github/workflows/verify.yml:14-15`).
**비공개 보호:** 실측 · smoke 도구는 비공개 사용 프로젝트 경로 · 진단 문장을 저장소에 쓰지 않는다 (`tool/measure_rules.dart:37-38`, `tool/smoke.dart:34-36`).

---

*Architecture analysis: 2026-10-17*
