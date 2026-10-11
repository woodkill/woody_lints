---
phase: 01-baseline-and-toolchain
verified: 2026-10-11T05:22:32Z
status: human_needed
score: 15/17 must-haves verified
covered_files:
  - .fvmrc
  - .planning/phases/01-baseline-and-toolchain/01-01-PLAN.md
  - .planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md
  - .planning/phases/01-baseline-and-toolchain/01-02-PLAN.md
  - .planning/phases/01-baseline-and-toolchain/01-02-SUMMARY.md
  - .planning/phases/01-baseline-and-toolchain/01-03-PLAN.md
  - .planning/phases/01-baseline-and-toolchain/01-03-SUMMARY.md
  - .vscode/settings.json
  - CHANGELOG.md
  - VERSIONING.md
  - pubspec.yaml
covered_digest: "v3:sha256:a5f058f0d0fa880156f824e8bf4f0f67e5d94b254cb8da44b112edf5f9989b8b"
behavior_unverified: 0
overrides_applied: 0
decision_coverage:
  honored: 20
  total: 20
  not_honored: []
human_verification:
  - test: "VERSIONING.md 의 판정 순서(25-28행)를 1.3.0 사례와 2.0.0 사례에 직접 대입한다. 1.3.0 은 1번의 두 조건(설정 파일·SDK 를 고쳐야 하나 / 자동 검사가 막힐 수 있나)을 둘 다 따진다"
    expected: "2.0.0 은 1번에서 예 → major 로 나온다(검증자 확인: 문서 어느 곳을 읽어도 같은 답). 1.3.0 은 문서가 minor (2번에서 멈춤) 라고 적었지만, 검증자가 문자 그대로 대입하면 1번의 둘째 조건이 예 로 읽힌다 — riverpod_lint 3.1.3 의 규칙 11개가 WARNING, 1개가 ERROR 이고 dart analyze 는 warning 을 기본으로 실패 처리한다. 소유자가 (가) 지금 문서대로 판정할 수 있다고 받아들이거나 (나) 문서를 고치기로 정한다"
    why_human: "ROADMAP success criterion 4 는 소유자가 읽고 판정할 수 있는가를 묻는다. 문서의 존재·구조·결정 원문과의 일치는 명령으로 확인했지만, 판정 순서와 기준표가 어긋나는 경우를 소유자가 어떻게 읽을지는 소유자만 정할 수 있다. 어긋남의 뿌리가 소유자가 확정한 결정(D-02, D-05, D-09) 원문에 있어 구현 결함으로 단정할 수 없다"
  - test: "v1.3.0 tag 를 GitHub 에 올리기 전에 확인 패널(올릴 것 · 실행할 명령 · 되돌릴 수 없는 점 · 점검 결과)을 보았고, push 라고 답한 뒤에 push 가 실행되었는지 소유자가 확인한다"
    expected: "소유자가 패널을 보고 push 를 택한 기억과 01-01-SUMMARY.md 의 기록(응답 04:25:38Z, push 04:27:13Z)이 일치한다"
    why_human: "과거의 사람 상호작용이다. 검증자가 확인할 수 있는 것은 tag 객체의 생성 시각(04:21:51Z)과 원격 tag 객체 SHA 가 로컬과 같다는 점뿐이고, 확인 요청이 실제로 있었는지는 SUMMARY 의 서술로만 남아 있다"
  - test: "prohibition (01-01) — 이 phase 에서 origin 에 올린 것이 tag v1.3.0 하나뿐인지 확인한다"
    expected: "unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. git ls-remote origin 은 HEAD, refs/heads/main (90a2736), refs/tags/v1.3.0 두 줄만 보이고, milestone 브랜치에는 upstream 이 없다"
    why_human: "judgment-tier prohibition 은 interactive 모드에서 항목마다 소유자의 명시적 판정이 필요하다. 결과 상태는 확인했지만 실행된 명령의 인자(--tags 등)는 기록으로만 남아 있다"
  - test: "prohibition (01-01) — push 한 tag v1.3.0 을 옮기거나 지우지 않았는지 확인한다"
    expected: "unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 원격 tag 객체 SHA 80e2112… 가 로컬과 같고 tagger 시각이 최초 생성 시각 2026-10-11T04:21:51Z 그대로다"
    why_human: "judgment-tier prohibition. 앞으로도 지켜야 하는 약속이라 소유자가 인지하고 확정해야 한다"
  - test: "prohibition (01-02) — 이 phase 에서 README.md, lib/, 루트 analysis_options.yaml 을 바꾸지 않았는지 확인한다"
    expected: "unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. git diff --quiet v1.3.0 HEAD -- lib README.md analysis_options.yaml .gitignore 가 rc=0 이다"
    why_human: "judgment-tier prohibition 은 interactive 모드에서 소유자 판정이 필요하다"
  - test: "prohibition (01-03) — main / origin/main 의 lib/ 와 pubspec.yaml 이 1.3.0 그대로이고, sdk ^3.13.0 / version 2.0.0-dev 가 milestone 브랜치에만 있으며 어디로도 push 되지 않았는지 확인한다"
    expected: "unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 원격 main 은 90a2736 (= v1.3.0 의 커밋), 로컬 main 대 v1.3.0 의 lib/ · pubspec.yaml diff 는 rc=0, 커밋 968a5bb 는 main 과 origin/main 의 조상이 아니다"
    why_human: "judgment-tier prohibition. 릴리스 전까지 계속 지켜야 하는 제약이다"
  - test: "prohibition (01-03) — CHANGELOG 의 기존 1.3.0 / 1.0.0 항목을 한 글자도 고치지 않았는지 확인한다"
    expected: "unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. git diff --numstat 90a2736 -- CHANGELOG.md 가 12 추가 / 0 삭제이고 마지막 11행이 git show 90a2736:CHANGELOG.md 와 같다"
    why_human: "judgment-tier prohibition 은 interactive 모드에서 소유자 판정이 필요하다"
---

# Phase 1: Baseline and Toolchain Verification Report

**Phase Goal:** 사용 프로젝트가 머물 수 있는 1.3.0 기준점이 원격에 있고, 이후의 모든 검증과 실측이 지원 대상 SDK(Flutter 3.47.5 / Dart 3.13.4) 위에서 돌며, 실측 결과를 받아 적을 버전 정책과 CHANGELOG 형식이 정해져 있다
**Verified:** 2026-10-11T05:22:32Z
**Status:** human_needed
**Re-verification:** No — initial verification
**Mode:** 일반 phase (MVP mode 아님). `config.json` 의 `mode` 는 `interactive`

검증 방법: SUMMARY 의 서술은 증거로 쓰지 않았다. 아래 증거는 전부 이 검증에서 직접 실행한 명령의 출력이거나 직접 읽은 파일 내용이다. 임시 프로젝트는 저장소 밖(세션 scratchpad)에 만들었고, 검증 전후 `git status --short` 가 같다. 원격에는 읽기(`git ls-remote`, pub 의 HTTPS clone)만 했다.

## Goal Achievement

목표의 세 부분 중 둘은 명령으로 확인되었다. 셋째(버전 정책)는 문서가 있고 결정 원문과 일치하지만, 소유자가 읽고 판정할 수 있는지는 소유자 확인이 남아 있다.

| 목표의 부분 | 판정 | 요약 |
|-------------|------|------|
| 1.3.0 기준점이 원격에 있다 | 달성 | 원격 annotated tag `v1.3.0` → `90a2736`. Dart 3.11.5 프로젝트가 GitHub 의 `ref: v1.3.0` 으로 1.3.0 을 받는다 |
| 검증과 실측이 지원 대상 SDK 위에서 돈다 | 달성 | 저장소 루트에서 Flutter 3.47.5 / Dart 3.13.4. `.fvmrc` 만 있는 사본에서도 같은 SDK 가 선택된다 |
| 버전 정책과 CHANGELOG 형식이 정해져 있다 | 형식은 달성, 정책은 소유자 확인 필요 | 다음 번호 2.0.0 은 확정. 판정 순서와 기준표가 어긋나는 경우가 있어 소유자 판정이 필요하다 |

### Observable Truths

출처: ROADMAP success criteria 5개(SC1 ~ SC5, 계약)와 세 plan 의 `must_haves.truths`. plan truth 가 SC 를 다시 말한 것은 SC 문구로 합쳤다.

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 — `git ls-remote --tags origin` 에 `v1.3.0` 이 보이고 `git show v1.3.0:pubspec.yaml` 의 version 이 1.3.0 이다 | ✓ VERIFIED | `git ls-remote --tags origin` → `80e2112…	refs/tags/v1.3.0`, `90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}`. `git show v1.3.0:pubspec.yaml` 3행 `version: 1.3.0` |
| 2 | SC2 — 저장소 루트에서 `fvm flutter --version` 이 Flutter 3.47.5 / Dart 3.13.4 를 보고하고 `.vscode/settings.json` 의 SDK 경로도 같은 버전을 가리킨다 | ✓ VERIFIED | `fvm flutter --version` → `Flutter 3.47.5 … Tools • Dart 3.13.4`. `fvm dart --version` → `3.13.4`. `.fvmrc` 2행 `"flutter": "3.47.5"`, `.vscode/settings.json` 2행 `".fvm/versions/3.47.5"`, 그 경로가 `/Users/woody/fvm/versions/3.47.5` 로 풀린다. `.fvm/` 없이 `.fvmrc` 와 `pubspec.yaml` 만 둔 사본에서도 `fvm dart --version` 이 3.13.4 다 (untracked 링크에 기대지 않는다) |
| 3 | SC3 — milestone 브랜치의 `pubspec.yaml` 이 `sdk: ^3.13.0` 을 선언하고, Dart 3.13 미만 SDK 에서 이 패키지를 의존한 프로젝트의 `pub get` 이 SDK 버전 불일치 오류로 끝난다. 같은 시점에 `origin/main` 의 `lib/` 와 `pubspec.yaml` 은 `v1.3.0` 과 차이가 없다 | ✓ VERIFIED | `pubspec.yaml` 11행 `  sdk: ^3.13.0`. 저장소 밖 임시 프로젝트(`path:` 의존)에서 Dart 3.11.5 / 3.11.1 / 3.11.0 의 `dart pub get` 이 모두 rc=1, `Because consumer_probe depends on woody_lints from path which requires SDK version ^3.13.0, version solving failed.` Flutter 3.41.9 의 `flutter pub get` 도 rc=1 같은 문구. 원격 `refs/heads/main` = `90a2736…` = `v1.3.0^{}` (같은 커밋이므로 차이가 있을 수 없다). `git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` rc=0 |
| 4 | SC4 — 소유자가 버전 정책 문서를 읽고 어떤 변경이 major / minor / patch 인지 판정할 수 있으며, 그 정책에 따라 다음 릴리스의 버전 번호가 정해져 있다 | ? UNCERTAIN | 뒷부분은 확인: `VERSIONING.md` 63-65행에 다음 릴리스 2.0.0 이 적혀 있고, SDK 하한 상향은 판정 순서 1번과 기준표 39행이 모두 major 로 답한다. 앞부분은 소유자 판정이 필요하고, 검증자가 찾은 반대 증거가 있다 — 아래 "SC4 상세" |
| 5 | SC5 — CHANGELOG 항목의 형식(추가·삭제 규칙, 지원 SDK, 새로 생기는 진단)이 문서로 정해져 있어 Phase 4 의 실측 결과를 그 형식에 그대로 옮겨 적을 수 있다 | ✓ VERIFIED | `VERSIONING.md` 73-123행: 제목 `## X.Y.Z - YYYY-MM-DD`, `지원 SDK:` 줄, `### 추가한 규칙` / `### 뺀 규칙` / `### 올리기 전에` / `### 그 밖의 변경` / `### 새로 생기는 경고`, 4열 표 `규칙` / `강도` / `실측` / `dart fix`, 실측 한 줄 형식. Phase 4 SC1 의 두 수치(진단 건수, `dart fix` 로 고쳐지는 건수)가 `실측` · `dart fix` 열에 대응한다. 예시 16줄이 CONTEXT 211-226행과 `diff` 차이 없음 |
| 6 | (01-01) `git cat-file -t v1.3.0` 이 `tag` 다 — annotated tag | ✓ VERIFIED | `git cat-file -t v1.3.0` → `tag`. `git cat-file -p v1.3.0` 에 tagger, 제목 `woody_lints 1.3.0`, 본문 단락이 있다 |
| 7 | (01-01) `git push origin v1.3.0` 은 소유자가 checkpoint 에서 `push` 를 택한 뒤에만 실행되었고, 확인 요청에 올릴 것·명령·되돌릴 수 없음이 쉬운 말로 적혀 있었다 | ? UNCERTAIN | 과거의 사람 상호작용이라 명령으로 재현할 수 없다. 확인되는 것: tag 객체 생성 시각 2026-10-11T04:21:51Z, 원격 tag 객체 SHA 가 로컬과 같음. 응답 시각과 패널 문안은 SUMMARY 의 기록뿐이다 → 소유자 확인 |
| 8 | (01-01) push 뒤 `git ls-remote --heads origin` 은 `refs/heads/main` 한 줄이다 | ✓ VERIFIED | `git ls-remote --heads origin` → `90a2736…	refs/heads/main` 한 줄. milestone 브랜치에 upstream 없음 |
| 9 | (01-02) 저장소 루트에 `VERSIONING.md` 가 있고 네 절 제목이 그대로 있다 | ✓ VERIFIED | `grep -cx` 가 `# 버전 정책 (Versioning)`, `## 판정 순서`, `## 기준표`, `## 실제 사례`, `## CHANGELOG 항목 형식` 각각 1 |
| 10 | (01-02) 기준표 절에 D-05 의 표 11행이 문구 그대로 있다 | ✓ VERIFIED | CONTEXT 43-55행(들여쓰기 제거)과 기준표 절의 표 13줄을 `diff` → 차이 없음. 등급 행 수 11 |
| 11 | (01-02) 판정 순서는 major → minor → patch → 올리지 않음 순서이고 세 자리 풀이가 붙어 있다 | ✓ VERIFIED | 25-28행. `맨 앞자리(major)`, `가운데 자리(minor)`, `맨 뒷자리(patch)` 가 각 줄과 9-11행에 있다 |
| 12 | (01-02) 실제 사례에 1.3.0 → minor 와 2.0.0 → major 가 있고 다음 릴리스가 2.0.0 임이 적혀 있다 | ✓ VERIFIED | 60행, 63행, 65행. 이 truth 는 문구의 존재를 말한다. 1.3.0 판정이 판정 순서에서 따라 나오는지는 #4 에서 다룬다 |
| 13 | (01-02) `README.md` 는 바뀌지 않았다 | ✓ VERIFIED | `git diff --quiet v1.3.0 HEAD -- lib README.md analysis_options.yaml .gitignore` rc=0 |
| 14 | (01-03) `pubspec.yaml` 이 `sdk: ^3.13.0` 과 `version: 2.0.0-dev` 를 선언하고 그 외 줄은 1.3.0 과 같다 | ✓ VERIFIED | `git diff --numstat 90a2736 -- pubspec.yaml` → `2	2`. diff 는 3행과 11행뿐이다 |
| 15 | (01-03) 같은 임시 프로젝트의 `dart pub get` 이 Dart 3.13.4 에서는 성공한다 | ✓ VERIFIED | Dart 3.13.4 `dart pub get` rc=0, `+ woody_lints 2.0.0-dev from path …`, lock `version: "2.0.0-dev"`, `sdks: dart: ">=3.13.0 <4.0.0"` |
| 16 | (01-03) `CHANGELOG.md` 첫 줄이 `## 2.0.0 - 미출시` 이고 D-14 문구가 그대로 있으며 기존 1.3.0 / 1.0.0 항목은 한 글자도 바뀌지 않았다 | ✓ VERIFIED | 1, 3, 5, 7, 9, 11행이 CONTEXT 231-241행과 같다. `git diff --numstat 90a2736 -- CHANGELOG.md` → `12	0`. 마지막 11행 = `git show 90a2736:CHANGELOG.md`. 제목의 ` - ` 는 1번 |
| 17 | (01-03) `ref: v1.3.0` 으로 GitHub 의 이 패키지를 의존하는 임시 프로젝트는 Dart 3.11.x 에서도 `pub get` 이 성공한다 | ✓ VERIFIED | Dart 3.11.5 `dart pub get` rc=0, `+ woody_lints 1.3.0 from git https://github.com/woodkill/woody_lints.git at 90a273`, lock `ref: "v1.3.0"`, `resolved-ref: "90a2736b8d998c84467faf562a0fec720b797eaf"`, `version: "1.3.0"` |

**Score:** 15/17 truths verified (0 present, behavior-unverified)

FAILED 는 없다. UNCERTAIN 둘(#4, #7)은 소유자 확인으로 넘긴다.

### SC4 상세 — 소유자 판정이 필요한 이유와 검증자가 찾은 반대 증거

`VERSIONING.md` 는 결정 원문(D-05 표, D-09 판정 순서, 소유자가 고른 예시)을 글자 단위로 옮겼다. 구현이 명세에서 벗어난 곳은 없다. 그런데 문서를 그대로 적용하면 같은 변경에 답이 둘 나오는 경우가 있다. 아래 셋은 검증자가 직접 확인한 것이다.

1. **필수 사례 1.3.0 이 판정 순서 1번의 둘째 조건을 따지지 않는다.** 25행의 1번은 조건이 둘이다 ("설정 파일이나 SDK 를 고쳐야 하나, 자동 검사가 막힐 수 있나"). 61행은 첫째만 답한다 ("고칠 것이 없었다"). 둘째 조건의 사실은 이렇다.
   - `~/.pub-cache/hosted/pub.dev/riverpod_lint-3.1.3/lib` 에서 `DiagnosticSeverity.WARNING` 11개, `DiagnosticSeverity.ERROR` 1개 (3.1.9 도 같다).
   - `dart analyze --help` (Dart 3.13.4): `--[no-]fatal-warnings … (defaults to on)`.
   - 54행은 major 의 이유로 "받는 프로젝트의 `dart analyze` 가 통과에서 실패로 바뀔 수 있다" 를 든다. 1.3.0 은 warning 등급 규칙을 처음 켰으므로 같은 상황이다.
   - 문자 그대로 대입하면 1.3.0 은 1번에서 멈춰 major 가 되고, 문서가 적은 "minor (2번에서 멈춤)" 와 어긋난다. plan 01-02 의 human-check 가 기대한 답("1번에서 아니오")이 문서만으로는 따라 나오지 않는다.
2. **README 나 CHANGELOG 만 고친 변경.** 판정 순서로는 3번(`lib/` 나 `pubspec.yaml` 이 바뀌었나)이 "아니오" 라서 4번 "올리지 않음" 이다. 기준표 47행은 patch 다.
3. **52행과 54행.** 52행은 "major 는 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하는 변경에만 쓴다" 고 한정하는데, 54행과 기준표 42행은 고칠 것이 없는 심각도 상향을 major 로 둔다.

영향 범위: 다음 릴리스 번호 2.0.0 은 이 어긋남과 무관하다 (SDK 하한 상향은 어디를 읽어도 major). 영향을 받는 것은 2.0.0 뒤의 판정과, Phase 3 / 4 가 이 문서를 기준으로 쓸 때다 (plugin 하한 상향, 규칙 추가).

이것을 FAILED 로 두지 않은 이유: 어긋남의 뿌리가 소유자가 확정한 결정 원문에 있어, 어느 쪽으로 고칠지는 소유자만 정할 수 있다. 실행 기록(01-02-SUMMARY "정책의 빈칸 하나")과 코드 리뷰(WR-01 ~ WR-04, 전부 `open`)도 같은 지점을 소유자 결정으로 남겼다.

### Required Artifacts

`gsd-tools query verify.artifacts` 는 세 plan 모두 exit 0 (`all_passed: true`, 7/7).

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `.planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md` | tag 점검·확인·push 출력 원문 | ✓ VERIFIED | 있음, `refs/tags/v1.3.0^{}` 포함. 기록된 SHA 가 실제 원격·로컬 값과 같다 |
| `VERSIONING.md` | 버전 정책 + CHANGELOG 항목 형식 | ✓ VERIFIED | 123줄 (min 80), `## 기준표` 포함, 결정 원문과 `diff` 일치. README 링크는 없다 — D-11 이 Phase 5 로 미뤘다 (의도된 상태) |
| `.fvmrc` | 저장소 고정 Flutter 버전 | ✓ VERIFIED | `"flutter": "3.47.5"`. FVM 이 실제로 이 값을 읽는다 (사본 실행으로 확인) |
| `.vscode/settings.json` | VS Code Dart 확장의 SDK 경로 | ✓ VERIFIED | `".fvm/versions/3.47.5"`, 경로가 존재한다 |
| `pubspec.yaml` | 지원 SDK 하한과 milestone 중 버전 | ✓ VERIFIED | `sdk: ^3.13.0`, `version: 2.0.0-dev`. pub solver 가 이 값으로 옛 SDK 를 거부한다 |
| `CHANGELOG.md` | 2.0.0 항목 — 새 형식의 첫 적용 | ✓ VERIFIED | `## 2.0.0 - 미출시` 와 D-14 내용. 11행은 의도된 자리 표시 (Anti-Patterns 참조) |
| `.planning/phases/01-baseline-and-toolchain/01-03-SUMMARY.md` | BASE-02 실측 증거 원문 | ✓ VERIFIED | 있음, `version solving failed` 포함. 적힌 출력이 이 검증의 재실행 결과와 같다 |

**Artifacts:** 7/7 verified

### Key Link Verification

`gsd-tools query verify.key-links` 는 8개 중 1개만 자동 판정했다. 나머지 7개는 `from` 이 파일 경로가 아니라 설명 문구여서 도구가 평가하지 못했다 (`Source file not found (from: must be a relative file path…)`). 이것은 NOT_WIRED 판정이 아니라 미평가다. 그래서 7개는 plan 이 적은 `via` 와 `pattern` 으로 직접 확인했다.

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| 로컬 `refs/tags/v1.3.0` | `90a2736…` = `origin/main` | `git rev-parse` 일치 | ✓ WIRED | `git rev-parse 'v1.3.0^{commit}'` = `git rev-parse origin/main` = `90a2736b8d998c84467faf562a0fec720b797eaf` |
| 로컬 `refs/tags/v1.3.0` | origin `refs/tags/v1.3.0` | `git push origin v1.3.0` | ✓ WIRED | 원격과 로컬의 tag 객체 SHA 가 `80e2112578b7a9870e43476a2893bc4972d4a3a9` 로 같다 |
| `VERSIONING.md` § 기준표 | CONTEXT D-05 표 | 11행 문구 그대로 복사 | ✓ WIRED | `diff` 차이 없음 |
| `VERSIONING.md` § CHANGELOG 항목 형식 | `CHANGELOG.md` 최상단 항목 | 제목 형식, ` - ` 한 번 | ✓ WIRED | 77행 `## X.Y.Z - YYYY-MM-DD`, CHANGELOG 1행 `## 2.0.0 - 미출시` |
| `.fvmrc` | `.vscode/settings.json` | `fvm use 3.47.5` | ✓ WIRED | 도구 자동 판정 (`Pattern found in source`) |
| `pubspec.yaml` (`environment.sdk`) | 사용 프로젝트의 `dart pub get` | pub version solver | ✓ WIRED | 임시 프로젝트 출력에 `requires SDK version ^3.13.0, version solving failed` |
| `CHANGELOG.md` 첫 줄 | Phase 6 REL-03 일치 검사 | ` - ` 앞 토큰이 버전 | ✓ WIRED (출발 쪽) | `^## 2\.0\.0 - ` 일치. 받는 쪽 검사는 Phase 6 에서 만든다 — 아직 없는 것이 정상이다 |
| `VERSIONING.md` § CHANGELOG 항목 형식 | `CHANGELOG.md` 2.0.0 항목 | 형식의 첫 적용 | ✓ WIRED | `### 올리기 전에`, `### 새로 생기는 경고`, `지원 SDK: … (이전: …)` 이 양쪽에 같은 이름으로 있다 |

**Wiring:** 8/8 connections verified (1 자동, 7 수동)

### Data-Flow Trace (Level 4)

해당 없음 — 이 phase 의 산출물은 정적 설정 파일과 문서다. 동적 데이터를 렌더링하는 artifact 가 없다. 설정 값이 실제 소비 주체(FVM, pub solver)에 도달하는지는 Key Link 와 Spot-Check 에서 실행으로 확인했다.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| 원격 tag 가 1.3.0 커밋을 가리킨다 | `git ls-remote --tags origin` | `90a2736…	refs/tags/v1.3.0^{}` | ✓ PASS |
| 원격 브랜치는 `main` 하나다 | `git ls-remote --heads origin` | 한 줄, `refs/heads/main` | ✓ PASS |
| 저장소 루트의 고정 SDK | `fvm flutter --version`, `fvm dart --version` | Flutter 3.47.5, Dart 3.13.4 | ✓ PASS |
| `.fvmrc` 만으로 SDK 가 선택된다 | 사본(`.fvmrc`, `pubspec.yaml`)에서 `fvm dart --version` | Dart 3.13.4, 사본에 새 파일 없음 | ✓ PASS |
| 옛 SDK 는 `pub get` 에서 거부된다 | Dart 3.11.5 / 3.11.1 / 3.11.0 `dart pub get` (`path:` 의존) | 셋 다 rc=1, `version solving failed` | ✓ PASS |
| Flutter 명령으로도 거부된다 | Flutter 3.41.9 `flutter pub get` | rc=1, 같은 문구, `Failed to update packages.` | ✓ PASS |
| 지원 SDK 에서는 받는다 | Dart 3.13.4 `dart pub get` | rc=0, `woody_lints 2.0.0-dev from path` | ✓ PASS |
| 옛 SDK 가 `ref: v1.3.0` 에 머물 수 있다 | Dart 3.11.5 `dart pub get` (`git:` + `ref: v1.3.0`) | rc=0, `resolved-ref: "90a2736…"`, `version: "1.3.0"` | ✓ PASS |
| 저장소 자체 분석 | `fvm dart analyze` | `No issues found!` rc=0 | ✓ PASS |
| 하한 상향이 `main` 에 없다 | `git merge-base --is-ancestor 968a5bb main` / `origin/main` | 둘 다 rc=1 (포함되지 않음) | ✓ PASS |

plan 의 실측은 `dart pub get` 만 돌렸다. 사용 프로젝트가 실제로 쓰는 `flutter pub get` 경로는 이 검증에서 처음 확인했다.

### Probe Execution

해당 없음 — `scripts/` 디렉터리가 없고, PLAN / SUMMARY 가 `probe-*.sh` 스크립트를 선언하지 않는다. plan 이 "probe" 라고 부른 것은 임시 사용 프로젝트이며 위 Spot-Check 에서 직접 실행했다.

### Requirements Coverage

plan frontmatter 의 요구사항 ID 는 REL-01 (01-01), BASE-03 · BASE-04 (01-02), BASE-01 · BASE-02 (01-03) 다. `REQUIREMENTS.md` 가 Phase 1 에 대응시킨 ID 다섯 개와 정확히 같다. ORPHANED 없음.

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| BASE-01 | 01-03 | 저장소가 고정하는 SDK 가 Flutter 3.47.5 / Dart 3.13.4 다 | ✓ SATISFIED | Truth 2 |
| BASE-02 | 01-03 | SDK 하한이 `^3.13.0` 이어서 지원하지 않는 SDK 는 `pub get` 단계에서 명확히 실패한다 | ✓ SATISFIED | Truth 3, 14, 15 |
| BASE-03 | 01-02 | 어떤 변경이 major / minor / patch 인지 정한 버전 정책이 문서로 남아 있다 | ? NEEDS HUMAN | 문서는 있고 결정 원문과 일치한다 (Truth 9 ~ 12). 일부 변경에서 판정 순서와 기준표의 답이 갈린다 (Truth 4) |
| BASE-04 | 01-02 | CHANGELOG 항목의 형식이 정해져 있다 | ✓ SATISFIED | Truth 5, 16 |
| REL-01 | 01-01 | 1.3.0 내용의 커밋에 `v1.3.0` tag 가 있고 원격에 올라가 있다 | ✓ SATISFIED | Truth 1, 6, 17 |

참고: `REQUIREMENTS.md` 는 다섯 개를 이미 `[x]` / Complete 로 표시한다. BASE-03 은 소유자 확인이 끝나기 전이다.

### Decision Coverage

All trackable CONTEXT.md decisions are honored by shipped artifacts. (`check.decision-coverage-verify`: honored 20 / total 20, not_honored 없음, blocking false)

### Prohibitions (must-NOT)

다섯 항목 모두 `verification: judgment`, `status: unresolved` 다. interactive 모드이므로 항목마다 소유자의 명시적 판정이 필요하다. 아래 판단은 검증자의 비권위 판단이며 통과 판정이 아니다.

| # | Prohibition | 검증자 판단 (비권위) | 근거 | Flag |
|---|-------------|----------------------|------|------|
| P1 | (01-01) origin 에 올리는 것은 tag `v1.3.0` 하나뿐이다 | 위반 없음 | `git ls-remote origin` → `HEAD`, `refs/heads/main`, tag 두 줄뿐. 로컬 tag 도 `v1.3.0` 하나. milestone 브랜치에 upstream 없음 | unverified-prohibition — human review recommended |
| P2 | (01-01) push 한 tag `v1.3.0` 은 옮기거나 지우지 않는다 | 위반 없음 | 원격 tag 객체 SHA = 로컬 = `80e2112…`, tagger 시각 2026-10-11T04:21:51Z (최초 생성 시각) | unverified-prohibition — human review recommended |
| P3 | (01-02) `README.md`, `lib/`, 루트 `analysis_options.yaml` 은 바꾸지 않는다 | 위반 없음 | `git diff --quiet v1.3.0 HEAD -- lib README.md analysis_options.yaml .gitignore` rc=0. phase 커밋 4개가 담은 저장소 파일은 `.fvmrc`, `.vscode/settings.json`, `CHANGELOG.md`, `VERSIONING.md`, `pubspec.yaml` 뿐 | unverified-prohibition — human review recommended |
| P4 | (01-03) `main` / `origin/main` 의 `lib/` 와 `pubspec.yaml` 은 1.3.0 그대로이고 하한 상향은 milestone 브랜치에만 있으며 push 하지 않는다 | 위반 없음 | 원격 `main` = `90a2736`. `git diff --quiet v1.3.0 main -- lib pubspec.yaml` rc=0. `968a5bb` 는 `main` 과 `origin/main` 의 조상이 아니다 | unverified-prohibition — human review recommended |
| P5 | (01-03) 기존 CHANGELOG 1.3.0 / 1.0.0 항목은 한 글자도 고치지 않는다 | 위반 없음 | numstat `12	0`, 마지막 11행 = `git show 90a2736:CHANGELOG.md` | unverified-prohibition — human review recommended |

### Anti-Patterns Found

debt marker(`TBD` / `FIXME` / `XXX`, `TODO` / `HACK` / `PLACEHOLDER`)는 변경된 파일 다섯 개 어디에도 없다. Blocker 없음.

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `VERSIONING.md` | 25, 60-62 | 1.3.0 사례가 판정 순서 1번의 둘째 조건을 건너뛴다 (리뷰 WR-01, 사실관계는 이 검증에서 재확인) | Warning | 2.0.0 뒤의 등급 판정이 선례를 따라 어긋날 수 있다. Truth 4 의 소유자 확인으로 넘김 |
| `VERSIONING.md` | 25 | "자동 검사" 가 어느 명령인지 정의되지 않았다 (WR-02). `flutter analyze` 는 `--fatal-infos` 도 기본으로 켜져 있다 (Flutter 3.47.5 `--help` 로 확인) | Warning | minor 와 major 의 경계가 명령에 따라 달라진다 |
| `VERSIONING.md` | 25-28, 47 | 판정 순서와 기준표가 README / CHANGELOG 만 고친 변경에 다른 등급을 낸다 (WR-03) | Warning | Phase 5 뒤 문서만 고친 커밋의 등급이 정해지지 않는다 |
| `VERSIONING.md` | 52, 54 | "에만" 한정이 54행·기준표 42행과 모순된다 (WR-04) | Warning | 같은 문서 안에서 major 의 범위가 둘이다 |
| `VERSIONING.md`, `CHANGELOG.md` | 5 / 7 | "tag 하나에 고정해서 받는다" 는 지금 사실이 아니다 — `README.md` 31, 42행은 `ref: main` 이다 (WR-05) | Warning | `ref: main` 프로젝트는 `v1.3.0` 으로 옮겨야 머물 수 있다. 옮기는 방법은 Phase 5 (DOCS-04, SC2) 가 다룬다. `main` 병합 전에 필요하다 |
| `VERSIONING.md` | 99-117 | 예시가 "규칙 하나를 추가" 인데 경고 표에는 규칙이 둘이다 (WR-06). 소유자가 고른 원문 그대로다 | Warning | Phase 4 가 표의 행 규칙을 추측해야 할 수 있다. SC5 를 막지는 않는다 |
| `CHANGELOG.md` | 11 | `(Phase 4 실측 후 채움)` 자리 표시 | Info | 의도된 자리다 (D-14). `.planning/WINDOWS.md` id 1 로 `open` 추적 중, Phase 4 실측과 Phase 5 SC4 가 채운다 |
| `.claude/CLAUDE.md` | 14줄 | `3.41.2` / `3.10.4` 옛 버전 서술 (`grep -c` = 14) | Info | phase 범위 밖(01-03-SUMMARY 후속 작업). 이 파일은 모든 에이전트에 주입되므로 뒤 phase 에서 옛 버전을 사실로 읽을 수 있다 |
| git (로컬 `main`) | — | 로컬 `main` 이 `origin/main` 보다 커밋 7개 앞서 있고 전부 `.planning/` 문서다 | Info | `lib/` · `pubspec.yaml` 은 1.3.0 그대로라 제약 위반이 아니다. `main` 을 그대로 push 하면 `.planning/` 이 공개 저장소에 올라간다 |

코드 리뷰(`01-REVIEW.md`: critical 0, warning 6, info 4)의 발견은 전부 `open` 이다. 리뷰 내용을 그대로 받아들이지 않고 WR-01 · WR-02 · WR-03 · WR-05 의 사실관계를 직접 확인했다. 넷 다 맞다.

### Test Quality Audit

해당 없음 — 테스트 프레임워크와 테스트 파일이 없다 (설정 전용 패키지). 검증은 셸 명령이며 순환 구조가 아니다: 비교 기준이 phase 이전 커밋(`90a2736`), 외부 판정자(pub version solver, GitHub 의 원격 ref), 결정 원문(`01-CONTEXT.md`)이다.

**Disabled tests on requirements:** 0
**Circular patterns detected:** 0
**Insufficient assertions:** 1 → Warning. plan 01-02 Task 1 의 자동 검사는 실제 사례 절에 `→ minor`, `→ major` 문자열이 있는지만 본다. 그 판정이 판정 순서에서 따라 나오는지는 보지 않는다 (Truth 4 로 넘김)

### Human Verification Required

이 phase 는 인프라 성격이지만, ROADMAP success criterion 4 가 소유자의 읽기·판정을 직접 요구하고 plan 01-02 가 `<human-check>` 를 phase 끝으로 미뤘으므로 사람 확인을 생략하지 않는다. plan 에서 수집한 `<human-check>` 는 1번 항목과 같은 검사라 합쳤다.

### 1. VERSIONING.md 판정 순서 대입 (SC4, BASE-03)

**Test:** `VERSIONING.md` 의 판정 순서(25-28행)를 두 사례에 직접 대입한다. (1) "1.3.0: 그때까지 로드되지 않던 `riverpod_lint` 를 처음 켰다", (2) "2.0.0: 지원 SDK 하한을 `^3.10.4` → `^3.13.0` 으로 올렸다". 1.3.0 은 1번의 두 조건을 모두 따진다.
**Expected:** (2) 는 1번에서 "예" → major. (1) 은 문서가 minor 라고 적었지만, 위 "SC4 상세" 의 사실(warning 등급 규칙 11개, `dart analyze` 의 기본 실패 조건)을 놓고 보면 1번의 둘째 조건이 "예" 로 읽힌다. 소유자가 둘 중 하나를 정한다.
- (가) 지금 문서로 판정할 수 있다고 받아들인다 — 이 항목 통과.
- (나) 문서를 고친다 — 1.3.0 을 "지금 정책이면 major" 로 옮기거나, 1번의 둘째 조건을 "이미 켜져 있던 규칙의 심각도 상향" 으로 좁힌다. README / CHANGELOG 만 고친 변경의 등급과 52행의 "에만" 도 함께 정한다.
**Why human:** "읽고 판정할 수 있다" 는 사람의 이해 여부이고, 어긋남의 뿌리가 소유자가 확정한 결정 원문(D-02, D-05, D-09)에 있다.

### 2. tag push 전 소유자 확인 (01-01 truth)

**Test:** `v1.3.0` 을 GitHub 에 올리기 전에 확인 패널을 보았고 `push` 라고 답한 뒤에 올라갔는지 확인한다.
**Expected:** 기억과 `01-01-SUMMARY.md` 의 기록(응답 04:25:38Z, push 04:27:13Z)이 같다.
**Why human:** 과거의 사람 상호작용이라 명령으로 재현할 수 없다.

### 3 ~ 7. Prohibition 다섯 항목 (P1 ~ P5)

**Test:** 위 "Prohibitions" 표의 다섯 항목을 하나씩 확인한다.
**Expected:** 다섯 항목 모두 위반이 없다. 검증자의 비권위 판단은 전부 "위반 없음" 이고 근거 명령이 표에 있다.
**Why human:** judgment-tier prohibition 은 interactive 모드에서 항목마다 소유자의 명시적 판정이 필요하다. P2 와 P4 는 릴리스 전까지 계속 지켜야 하는 약속이다.

### Gaps Summary

명령으로 판정할 수 있는 must-have 는 전부 통과했다. FAILED truth, MISSING / STUB artifact, 끊어진 key link, blocker 는 없다. deferred 로 옮길 gap 도 없다.

남은 것은 사람 확인 일곱 항목이다. 여섯은 근거가 갖춰진 확인이고, 무게가 있는 것은 1번 하나다. `VERSIONING.md` 는 결정 원문을 충실히 옮겼지만, 그 원문끼리(판정 순서 D-09, 기준표 D-05, 한정 문장 D-02) 답이 갈리는 변경이 있고 필수 사례인 1.3.0 이 그중 하나에 걸려 있다. 다음 릴리스 번호 2.0.0 은 영향받지 않는다. Phase 3 과 4 가 이 문서를 기준으로 등급을 매기기 전에 소유자가 (가) / (나) 를 정해야 한다.

---

_Verified: 2026-10-11T05:22:32Z_
_Verifier: Claude (gsd-verifier)_
