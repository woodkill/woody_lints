---
phase: 01-baseline-and-toolchain
verified: 2026-10-11T08:53:57Z
status: passed
score: 24/26 must-haves verified
covered_files:
  - .fvmrc
  - .planning/phases/01-baseline-and-toolchain/01-01-PLAN.md
  - .planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md
  - .planning/phases/01-baseline-and-toolchain/01-02-PLAN.md
  - .planning/phases/01-baseline-and-toolchain/01-02-SUMMARY.md
  - .planning/phases/01-baseline-and-toolchain/01-03-PLAN.md
  - .planning/phases/01-baseline-and-toolchain/01-03-SUMMARY.md
  - .planning/phases/01-baseline-and-toolchain/01-04-PLAN.md
  - .planning/phases/01-baseline-and-toolchain/01-04-SUMMARY.md
  - .planning/phases/01-baseline-and-toolchain/01-CONTEXT.md
  - .vscode/settings.json
  - CHANGELOG.md
  - VERSIONING.md
  - pubspec.yaml
covered_digest: "v3:sha256:45721ff6b04942031b1ffe78522daffa5a3b1c4e8df47bd7e67f3de67b7f2398"
behavior_unverified: 0
overrides_applied: 0
overrides:
  - must_have: "`01-REVIEW-DISPOSITION.md` 에서 WR-01 · WR-02 · WR-04 는 fixed, WR-03 은 open 이다 — WR-03 행의 Source 칸에 부분 해소 메모가 있고, SUMMARY 에도 같은 메모를 남긴다"
    reason: "코드 리뷰 게이트가 처리 기록표를 다시 만들 때 open 행의 Source 칸을 비운다. 같은 메모가 01-04-SUMMARY.md 243-250행, 01-UAT.md Gaps 절 G-01-1 의 '범위 밖' 줄, 01-REVIEW.md 의 WR-03 본문에 남아 있다 (소유자가 UAT 9번에서 (가) 받아들인다 를 골랐다)"
    accepted_by: "Woody Moon"
    accepted_at: "2026-10-11T09:23:33Z"
re_verification:
  previous_status: human_needed
  previous_score: 15/17
  gaps_closed:
    - "UAT gap G-01-1 — VERSIONING.md 의 판정 순서를 1.3.0 사례와 2.0.0 사례에 문자 그대로 대입하면 실제 사례 절이 적은 등급과 같은 답이 나온다 (계산으로 확인: 1.3.0 minor, 2.0.0 major)"
    - "01-01 truth — tag push 전 소유자 확인 (01-UAT.md 2번 pass)"
  gaps_remaining: []
  regressions: []
decision_coverage:
  honored: 20
  total: 20
  not_honored: []
coincidental_reliance_items:
  - truth: "기준표의 minor 행 가운데 riverpod_lint 하한을 같은 major 안에서 올림 (^3.1.3 → ^3.1.9) 은 판정 순서 1번에서 아니오 로 지나가 2번에서 minor 가 된다"
    reason: undeclared-precondition
    harden: "VERSIONING.md 30행에 전제를 적는다 — plugin 이나 기반 세트의 하한을 올릴 때는 새 하한 버전이 요구하는 Dart 버전을 보고, 그것이 이 패키지의 SDK 하한보다 높으면 1번의 첫째 조건(SDK 를 고쳐야 하나)이 예 다. riverpod_lint 3.1.9 는 Dart 3.13 이상을 요구하고 3.1.3 은 3.10 이상을 요구한다. 지금은 pubspec.yaml 이 이미 sdk ^3.13.0 이라 답이 아니오 로 성립한다"
human_verification:
  - test: "VERSIONING.md 를 다시 읽고 판정 순서의 네 질문(25-28행)에 네 가지 변경을 직접 대 본다. (1) 1.3.0 — 그때까지 꺼져 있던 riverpod_lint 규칙을 처음 켰다. 1번 질문의 세 조건을 모두 따진다 (2) 2.0.0 — 지원하는 Dart 최저 버전을 올렸다 (3) 맨 앞자리가 바뀌는 큰 업그레이드 — 기준표의 flutter_lints 6 → 7 줄과 riverpod_lint 3 → 4 줄 (4) 맨 앞자리가 같은 작은 업그레이드 — 기준표의 riverpod_lint ^3.1.3 → ^3.1.9 줄"
    expected: "(1) 1번의 세 조건이 모두 아니오 → 2번 예 → minor. 새로 켜진 규칙 가운데 warning 등급이 있었다는 사실이 적혀 있고, 그것이 왜 1번이 아니라 2번인지 문서만 읽고 납득된다 (2) 1번의 첫째 조건이 예 → major (3) 1번의 둘째 조건이 예 → major (4) 1번 아니오 → 2번 예 → minor. 네 답이 실제 사례 절(63-70행)과 기준표(40-50행)에 적힌 등급과 같다. 검증자가 계산으로 확인한 것 — 두 사례와 기준표 여덟 줄은 문서에 적힌 등급과 같은 답이 나온다. 검증자가 찾은 참고 사항 — (4)의 예시 riverpod_lint 3.1.9 는 그 자체가 Dart 3.13 이상을 요구한다 (3.1.3 은 3.10 이상). 2.0.0 은 Dart 최저 버전을 3.13 으로 함께 올리므로 (4)의 답은 아니오 가 맞다. 다만 문서에는 올리려는 버전이 더 높은 Dart 를 요구하는지 보라는 말이 없다. 이대로 받아들일지 한 문장을 더할지 소유자가 정한다"
    why_human: "ROADMAP success criterion 4 는 소유자가 읽고 판정할 수 있는가를 묻는다. 01-04 가 판정 순서 1번과 그 주변 문장을 다시 썼으므로 지난 UAT 1번의 답은 지금 문서에 해당하지 않는다. 계산은 명령으로 확인했지만 설명이 납득되는지는 소유자만 안다 (plan 01-04 Task 2 의 human-check)"
  - test: "리뷰 지적 처리 기록표(01-REVIEW-DISPOSITION.md)의 WR-03 줄에 실행자가 적었던 메모가 지금은 그 표에 없다는 점을 받아들일지 정한다. 메모 내용은 major 행 누락만 닫았고 README/CHANGELOG 만 고침과 새 프리셋 추가는 남았다 는 것이다. 실행이 끝난 뒤 코드 리뷰 도구가 표를 다시 만들면서 그 칸을 비웠다"
    expected: "둘 중 하나를 고른다. (가) 받아들인다 — 같은 내용이 01-04-SUMMARY.md 243-250행, 새 리뷰 보고서 01-REVIEW.md 의 WR-03 본문, 01-UAT.md 86행에 남아 있으므로 표에는 없어도 된다. 이 경우 이 보고서 본문의 overrides 문안을 frontmatter 에 적는다 (나) 표에 다시 적는다 — 다만 열림(open) 상태인 줄의 메모는 리뷰 도구를 다시 돌리면 또 지워진다"
    why_human: "plan 01-04 의 must_have 한 구절이 지금 파일에서는 성립하지 않는다. 실행자의 커밋 6b9eec8 시점에는 성립했고, 그 뒤 workflow 의 도구가 파일을 다시 만들었다 (9c9ca54). 계획대로 되돌려도 도구가 다시 지우므로 수정 계획으로는 닫히지 않는다. 받아들일지는 소유자만 정할 수 있다"
  - test: "prohibition (01-04) — 이번 수정에서 받는 쪽에 전달되는 파일을 건드리지 않았는지 확인한다. 대상은 lib/, README.md, 루트 analysis_options.yaml, pubspec.yaml, .fvmrc, .vscode/, CHANGELOG.md, .gitignore 이고, 버전을 올리지 않았는지와 GitHub 에 아무것도 올리지 않았는지도 본다"
    expected: "unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 23d2674 뒤로 .planning/ 밖에서 바뀐 파일은 VERSIONING.md 하나다. pubspec.yaml 의 version 은 2.0.0-dev 그대로다. GitHub 에는 main (90a2736) 과 이름표 v1.3.0 만 있고, 내 컴퓨터의 main 은 01-04 실행 전(10:28)에 마지막으로 바뀌었다. 작업 브랜치에는 올릴 곳(upstream)이 설정되어 있지 않다"
    why_human: "judgment-tier prohibition 은 interactive 모드에서 항목마다 소유자의 명시적 판정이 필요하다. 결과 상태는 확인했지만 실행된 명령 자체는 기록으로만 남아 있다"
  - test: "prohibition (01-04) — 확정된 결정 셋(D-04 심각도 상향은 major, D-05 기준표 11줄, D-09 3. 의 1.3.0 = minor · 2.0.0 = major)을 바꾸지 않았는지, 리뷰 지적 WR-03 을 닫지 않고 열어 두었는지 확인한다"
    expected: "unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. VERSIONING.md 의 기준표 13줄은 23d2674 와 같고 01-CONTEXT.md 의 D-05 표와도 같다. 실제 사례의 머리 줄은 minor (2번에서 멈춤) 과 major (1번에서 멈춤) 그대로다. 판정 순서 2 ~ 4번 문장은 바뀌지 않았다. 처리 기록표의 WR-03 은 open 이다"
    why_human: "judgment-tier prohibition 은 interactive 모드에서 소유자 판정이 필요하다"
  - test: "prohibition (01-04) — 결정 기록(01-CONTEXT.md)의 기존 줄을 지우거나 고치지 않고 주석 줄만 덧붙였는지 확인한다"
    expected: "unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 23d2674 와 비교하면 추가 2줄, 삭제 0줄이다. 덧붙은 두 줄은 38행(D-02 아래)과 70행(D-09 ① 아래)이고 D-02 와 D-09 ① 의 원문은 글자 그대로 남아 있다"
    why_human: "judgment-tier prohibition 은 interactive 모드에서 소유자 판정이 필요하다"
---

# Phase 1: Baseline and Toolchain Verification Report

**Phase Goal:** 사용 프로젝트가 머물 수 있는 1.3.0 기준점이 원격에 있고, 이후의 모든 검증과 실측이 지원 대상 SDK(Flutter 3.47.5 / Dart 3.13.4) 위에서 돌며, 실측 결과를 받아 적을 버전 정책과 CHANGELOG 형식이 정해져 있다
**Verified:** 2026-10-11T08:53:57Z
**Status:** human_needed
**Re-verification:** Yes — UAT gap G-01-1 을 닫은 plan 01-04 실행 뒤. 이전 보고서(05:22:32Z, human_needed)에는 `gaps:` 가 없었으므로 지난 결과를 이어받지 않고 26개 항목 전부를 처음부터 다시 확인했다
**Mode:** 일반 phase (MVP mode 아님). `config.json` 의 `mode` 는 `interactive`

검증 방법: SUMMARY 의 서술은 증거로 쓰지 않았다. 아래 증거는 전부 이 검증에서 직접 실행한 명령의 출력이거나 직접 읽은 파일 내용이다. 임시 프로젝트는 저장소 밖(세션 scratchpad)에 만들었고, 검증 전후 `git status --short` 가 같다. 원격에는 읽기(`git fetch`, `git ls-remote`, pub 의 HTTPS clone)만 했다.

## Goal Achievement

목표의 세 부분 가운데 둘은 명령으로 확인되었다. 셋째(버전 정책)는 지난 UAT 에서 나온 문제가 닫혔음을 계산으로 확인했고, 다시 쓴 문서를 소유자가 읽는 일이 남아 있다.

| 목표의 부분 | 판정 | 요약 |
|-------------|------|------|
| 1.3.0 기준점이 원격에 있다 | 달성 | 원격 annotated tag `v1.3.0` → `90a2736`. Dart 3.11.5 프로젝트가 GitHub 의 `ref: v1.3.0` 으로 1.3.0 을 받는다 |
| 검증과 실측이 지원 대상 SDK 위에서 돈다 | 달성 | 저장소 루트에서 Flutter 3.47.5 / Dart 3.13.4. Dart 3.11.x 의 `pub get` 은 `version solving failed` 로 거부된다 |
| 버전 정책과 CHANGELOG 형식이 정해져 있다 | 형식은 달성, 정책은 소유자 재확인 필요 | 다음 번호 2.0.0 확정. 판정 순서에 두 사례와 기준표 여덟 줄을 대입한 계산값이 문서의 등급과 같다. 다시 쓴 설명을 소유자가 읽고 납득하는지가 남았다 |

### Observable Truths

출처: ROADMAP success criteria 5개(SC1 ~ SC5, 계약)와 네 plan 의 `must_haves.truths`. plan truth 가 SC 를 다시 말한 것은 SC 문구로 합쳤다 (01-02 와 01-04 의 "소유자가 대입해 납득한다" 는 SC4 로 합침).

줄 번호 안내: plan 01-04 가 적은 "38-42행 / 43 · 44 · 46행" 은 수정 전 `VERSIONING.md` 의 줄 번호다. 지금 파일에서는 기준표가 두 줄 내려가 major 다섯 줄이 40-44행, minor 네 줄이 45-48행, patch 가 49행, "올리지 않음" 이 50행이다. 아래에서는 지금 줄 번호를 쓴다.

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SC1 — `git ls-remote --tags origin` 에 `v1.3.0` 이 보이고 `git show v1.3.0:pubspec.yaml` 의 version 이 1.3.0 이다 | ✓ VERIFIED | `git ls-remote origin` → `80e2112…	refs/tags/v1.3.0`, `90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}`. `git show v1.3.0:pubspec.yaml` 3행 `version: 1.3.0` |
| 2 | SC2 — 저장소 루트에서 `fvm flutter --version` 이 Flutter 3.47.5 / Dart 3.13.4 를 보고하고 `.vscode/settings.json` 의 SDK 경로도 같은 버전을 가리킨다 | ✓ VERIFIED | `fvm flutter --version` → `Flutter 3.47.5 … Tools • Dart 3.13.4`. `fvm dart --version` → `3.13.4`. `.fvmrc` `"flutter": "3.47.5"`, `.vscode/settings.json` `".fvm/versions/3.47.5"`, 그 경로가 `/Users/woody/fvm/versions/3.47.5` 로 풀린다 |
| 3 | SC3 — milestone 브랜치의 `pubspec.yaml` 이 `sdk: ^3.13.0` 을 선언하고, Dart 3.13 미만 SDK 에서 이 패키지를 의존한 프로젝트의 `pub get` 이 SDK 버전 불일치 오류로 끝난다. 같은 시점에 `origin/main` 의 `lib/` 와 `pubspec.yaml` 은 `v1.3.0` 과 차이가 없다 | ✓ VERIFIED | `pubspec.yaml` 11행 `  sdk: ^3.13.0`. 저장소 밖 임시 프로젝트(`path:` 의존)에서 Dart 3.11.5 / 3.11.1 / 3.11.0 의 `dart pub get` 이 모두 rc=1, `Because consumer_probe depends on woody_lints from path which requires SDK version ^3.13.0, version solving failed.` Flutter 3.41.9 의 `flutter pub get` 도 rc=1 `Failed to update packages.` 원격 `refs/heads/main` = `90a2736…` = `v1.3.0^{}`. `git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` rc=0 |
| 4 | SC4 — 소유자가 버전 정책 문서를 읽고 어떤 변경이 major / minor / patch 인지 판정할 수 있으며, 그 정책에 따라 다음 릴리스의 버전 번호가 정해져 있다 | ? UNCERTAIN | 뒷부분은 확인: `VERSIONING.md` 67-69행에 다음 릴리스 2.0.0. 앞부분은 소유자 판정이다. 지난 UAT 1번의 답(issue, G-01-1)은 01-04 가 다시 쓰기 전 문서에 대한 것이라 다시 물어야 한다. 검증자가 확인한 것과 찾은 것은 아래 "SC4 상세" |
| 5 | SC5 — CHANGELOG 항목의 형식(추가·삭제 규칙, 지원 SDK, 새로 생기는 진단)이 문서로 정해져 있어 Phase 4 의 실측 결과를 그 형식에 그대로 옮겨 적을 수 있다 | ✓ VERIFIED | `VERSIONING.md` 77-127행: 제목 `## X.Y.Z - YYYY-MM-DD`, `지원 SDK:` 줄, 다섯 칸, 4열 표 `규칙` / `강도` / `실측` / `dart fix`, 실측 한 줄 형식. 이 절은 `git show 23d2674:VERSIONING.md` 의 같은 절과 `diff` 차이 없음 (01-04 가 건드리지 않았다) |
| 6 | (01-01) `git cat-file -t v1.3.0` 이 `tag` 다 — annotated tag | ✓ VERIFIED | `git cat-file -t v1.3.0` → `tag`. `git cat-file -p v1.3.0` 에 tagger, 제목 `woody_lints 1.3.0`, 본문 단락 |
| 7 | (01-01) `git push origin v1.3.0` 은 소유자가 checkpoint 에서 `push` 를 택한 뒤에만 실행되었고, 확인 요청에 올릴 것·명령·되돌릴 수 없음이 쉬운 말로 적혀 있었다 | ✓ VERIFIED | 소유자 확인: `01-UAT.md` 2번 `result: pass` (커밋 `26b0602`). 그 뒤 달라진 것 없음 — tag 객체 SHA `80e2112…` 가 로컬·원격 같고 tagger 시각 2026-10-11T04:21:51Z 그대로 |
| 8 | (01-01) push 뒤 `git ls-remote --heads origin` 은 `refs/heads/main` 한 줄이다 | ✓ VERIFIED | `git ls-remote --heads origin` → `90a2736…	refs/heads/main` 한 줄. milestone 브랜치에 upstream 없음 |
| 9 | (01-02) 저장소 루트에 `VERSIONING.md` 가 있고 네 절 제목이 그대로 있다 | ✓ VERIFIED | `grep -c -x -F` 가 `# 버전 정책 (Versioning)`, `## 판정 순서`, `## 기준표`, `## 실제 사례`, `## CHANGELOG 항목 형식` 각각 1 |
| 10 | (01-02) 기준표 절에 D-05 의 표 11행이 문구 그대로 있다 | ✓ VERIFIED | `01-CONTEXT.md` 의 D-05 표(들여쓰기 제거)와 기준표 절의 표 줄을 `diff` → 차이 없음. 등급 행 수 11 |
| 11 | (01-02) 판정 순서는 major → minor → patch → 올리지 않음 순서이고 세 자리 풀이가 붙어 있다 | ✓ VERIFIED | 25-28행. `맨 앞자리(major)`, `가운데 자리(minor)`, `맨 뒷자리(patch)` 가 각 줄과 9-11행에 있다 |
| 12 | (01-02) 실제 사례에 1.3.0 → minor 와 2.0.0 → major 가 있고 다음 릴리스가 2.0.0 임이 적혀 있다 | ✓ VERIFIED | 63행 `→ minor (2번에서 멈춤)`, 67행 `→ major (1번에서 멈춤)`, 69행 "다음 릴리스는 **2.0.0**" |
| 13 | (01-02) `README.md` 는 바뀌지 않았다 | ✓ VERIFIED | `git diff --quiet v1.3.0 HEAD -- lib README.md analysis_options.yaml .gitignore` rc=0 |
| 14 | (01-03) `pubspec.yaml` 이 `sdk: ^3.13.0` 과 `version: 2.0.0-dev` 를 선언하고 그 외 줄은 1.3.0 과 같다 | ✓ VERIFIED | `git diff --numstat 90a2736 -- pubspec.yaml` → `2	2`. diff 는 3행과 11행뿐 |
| 15 | (01-03) 같은 임시 프로젝트의 `dart pub get` 이 Dart 3.13.4 에서는 성공한다 | ✓ VERIFIED | Dart 3.13.4 `dart pub get` rc=0, `+ woody_lints 2.0.0-dev from path …`, lock `version: "2.0.0-dev"`, `sdks: dart: ">=3.13.0 <4.0.0"` |
| 16 | (01-03) `CHANGELOG.md` 첫 줄이 `## 2.0.0 - 미출시` 이고 D-14 문구가 그대로 있으며 기존 1.3.0 / 1.0.0 항목은 한 글자도 바뀌지 않았다 | ✓ VERIFIED | 1, 3, 5, 7, 9, 11행. `git diff --numstat 90a2736 -- CHANGELOG.md` → `12	0`. 마지막 11행 = `git show 90a2736:CHANGELOG.md`. 제목의 ` - ` 는 1번 |
| 17 | (01-03) `ref: v1.3.0` 으로 GitHub 의 이 패키지를 의존하는 임시 프로젝트는 Dart 3.11.x 에서도 `pub get` 이 성공한다 | ✓ VERIFIED | Dart 3.11.5 `dart pub get` rc=0, lock `ref: "v1.3.0"`, `resolved-ref: "90a2736b8d998c84467faf562a0fec720b797eaf"`, `version: "1.3.0"` |
| 18 | (01-04) 판정 순서 1번이 세 조건(설정·SDK 를 고쳐야 하나 / `flutter_lints` 나 `riverpod_lint` 를 다음 major 로 올리나 / 이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나)으로 기준표의 major 다섯 행을 모두 묻고, 1.3.0 과 2.0.0 을 문자 그대로 대입하면 1.3.0 → minor (2번), 2.0.0 → major (1번) 가 나오며 실제 사례의 등급과 같다 | ✓ VERIFIED | 25행이 세 조건 문장이다. plan 의 대입 검사 출력 `substitution: 1.3.0 computed=minor documented=minor / 2.0.0 computed=major documented=major`. 검증자가 따로 대입: 1.3.0 은 `90a2736` 의 diff 로 세 조건의 사실을 확인했다 — `sdk: ^3.10.4` 그대로, `flutter_lints: ^6.0.0` 은 위치만 이동, 옛 `analyzer: plugins: - riverpod_lint` 는 버전이 없었고 새 `plugins: riverpod_lint: ^3.1.3` 이 처음 로드, `errors:` 그대로 → 세 조건 아니오, 2번 예. 2.0.0 은 `sdk` 하한 상향 → 첫째 조건 예 |
| 19 | (01-04) 기준표의 major 다섯 행을 대입하면 모두 1번에서 "예" 가 나오고, minor 행 가운데 규칙 추가·삭제(45행), `analyzer.exclude` / `errors`(46행), `riverpod_lint` 하한을 같은 major 안에서 올림(48행)은 1번을 지나 2번에서 minor 가 된다. 48행은 1번의 둘째 조건에 걸리지 않는다. 자동 검사가 이것을 문서에서 계산한다 | ✓ VERIFIED (coincidental-reliance) | 출력 `table: 38=major/major 39=major/major 40=major/major 41=major/major 42=major/major 43=minor/minor 44=minor/minor 46=minor/minor` (라벨은 수정 전 줄 번호). 둘째 조건의 "다음 major 로" 한정이 48행을 가른다는 것도 문장으로 확인. 다만 48행이 1번의 **첫째** 조건도 지나간다는 것은 전제 하나에 기댄다 — `coincidental_reliance_items` 와 "SC4 상세" 1번 참조 |
| 20 | (01-04) 1.3.0 사례가 1번의 세 조건을 모두 답하고, 새로 켜진 `riverpod_lint` 3.1.3 규칙에 warning 11 / error 1 이 있다는 사실과 그것이 2번에서 다뤄지는 이유가 적혀 있다 | ✓ VERIFIED | 64-66행에 하위 불릿 3개. 사실 확인: `~/.pub-cache/hosted/pub.dev/riverpod_lint-3.1.3/lib` 에 `registerWarningRule` 15개, `DiagnosticSeverity.WARNING` 11개, `DiagnosticSeverity.ERROR` 1개. 이유는 56행("그 표의 `강도` 열에서 미리 볼 수 있다") |
| 21 | (01-04) 기준표 아래 사유의 major 범위가 판정 순서 1번과 같은 범위로 적혀 있고 `에만` 한정이 없다 | ✓ VERIFIED | 54행 "… (판정 순서 1번과 같은 범위 — 기준표의 major 다섯 행)". `grep -F 'SDK 를 고쳐야 하는 변경에만 쓴다' VERSIONING.md` 출력 없음 |
| 22 | (01-04) 판정 순서 아래 설명 단락이 다음 major 상향은 1번이고 같은 major 안의 하한 상향은 2번임을 갈라 적는다 | ✓ VERIFIED | 30행 "둘째 조건은 맨 앞자리가 바뀌는 상향(…)만 가리킨다 — 같은 major 안에서 하한만 올리는 것(`^3.1.3` → `^3.1.9`)은 2번의 'plugin 버전이 바뀌었나' 다" |
| 23 | (01-04) `자동 검사` 가 어느 명령인지와 그것이 등급 기준이 아니라 받는 쪽이 겪는 일의 설명임이 적혀 있다 | ✓ VERIFIED | 57행. 적힌 사실을 직접 확인: `fvm dart analyze --help` (3.13.4) 에서 `--[no-]fatal-warnings … (defaults to on)`, `--fatal-infos` 는 기본값 표시 없음(꺼짐). `fvm flutter analyze --help` (3.47.5) 에서 `--[no-]fatal-infos` 와 `--[no-]fatal-warnings` 둘 다 `(defaults to on)` |
| 24 | (01-04) 기준표 11행(D-05)과 `## CHANGELOG 항목 형식` 절은 한 글자도 바뀌지 않았고 D-04 · D-09 3. 도 그대로다 | ✓ VERIFIED | 표 줄과 CHANGELOG 절 각각 `git show 23d2674:VERSIONING.md` 의 같은 부분과 `diff` → 차이 없음. `git diff -U0 23d2674 -- VERSIONING.md` 의 변경 자리는 25, 30, 54, 56-57, 64-65, 68행 여섯 덩어리(문구 수정 7곳)뿐. 판정 순서 2 ~ 4번 문장 불변 |
| 25 | (01-04) `01-CONTEXT.md` 의 D-02 와 D-09 ① 원문은 글자 그대로 남아 있고 각각 바로 아래에 `수정 (2026-10-11, UAT G-01-1)` 주석이 붙어 있다 — 삭제 줄 0, 추가만 | ✓ VERIFIED | `git diff --numstat 23d2674 -- 01-CONTEXT.md` → `2	0`. 주석은 38행과 70행. 70행에 `(1) UAT 뒤`, `(2) 계획 검토 뒤`, 최종 문구가 있고, 최종 문구에 `. 맨 앞자리(major) 를 올린다.` 를 붙이면 `VERSIONING.md` 25행과 글자 그대로 같다. plan 의 Task 1 검사 21개 rc=0 (bash · zsh) |
| 26 | (01-04) `01-REVIEW-DISPOSITION.md` 에서 WR-01 · WR-02 · WR-04 는 fixed, WR-03 은 open 이다 — WR-03 행의 Source 칸에 부분 해소 메모가 있고, SUMMARY 에도 같은 메모를 남긴다 | ? UNCERTAIN (WARNING — 소유자 결정 요청) | 네 구절 가운데 셋은 지금도 성립하고 **하나는 지금 성립하지 않는다**. 아래 "처리 기록표 상세" |

**Score:** 24/26 truths verified (0 present, behavior-unverified)

FAILED 로 판정한 항목은 없다. UNCERTAIN 둘(#4, #26)은 소유자에게 넘긴다. #26 은 "확인할 수 없어서" 가 아니라 "한 구절이 지금 성립하지 않는데 계획으로는 닫을 수 없어서" 넘기는 것이다 — 통과로 세지 않았다.

### SC4 상세 — 계산으로 확인한 것과 소유자가 읽을 때 알아야 할 것

**닫힌 것.** 지난 검증과 UAT 가 지적한 어긋남(1.3.0 을 문자 그대로 대입하면 major, 문서는 minor)은 없어졌다. 1번의 둘째 조건이 "자동 검사가 막힐 수 있나" 에서 "이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나" 로 바뀌었고, 1.3.0 사례가 세 조건을 모두 답한다. `grep -F '자동 검사가 막힐 수 있나' VERSIONING.md` 는 출력이 없다.

**검증자가 기준표 11줄을 전부 직접 대입한 결과.** plan 의 검사는 8줄만 계산한다. 나머지 3줄까지 문장 그대로 따라가 보았다.

| 기준표 줄 | 표의 등급 | 판정 순서를 따라가면 | 같은가 |
|-----------|-----------|----------------------|--------|
| 40 기존 URI 를 없애거나 이름·뜻을 바꿈 | major | 1번 첫째 조건 예 | 같다 |
| 41 지원 SDK 하한을 올림 | major | 1번 첫째 조건 예 | 같다 |
| 42 `flutter_lints` 를 다음 major 로 | major | 1번 둘째 조건 예 | 같다 |
| 43 `riverpod_lint` 를 다음 major 로 | major | 1번 둘째 조건 예 | 같다 |
| 44 규칙 심각도를 warning 이상으로 올림 | major | 1번 셋째 조건 예 | 같다 |
| 45 규칙을 넣거나 뺌 | minor | 1번 아니오 → 2번 예 | 같다 |
| 46 `analyzer.exclude` / `errors` 를 바꿈 | minor | 1번 아니오 → 2번 예 | 같다 |
| 47 새 프리셋 파일을 추가함 | minor | 2번이 묻는 것은 안 바뀜 → 3번 `lib/` 가 바뀜 → patch | **다르다** |
| 48 `riverpod_lint` 하한을 같은 major 안에서 올림 | minor | 1번 아니오 → 2번 예 | 같다 (전제 있음 — 아래 1번) |
| 49 주석·README·CHANGELOG·사유 문구만 고침 | patch | `lib/` 주석이면 3번 → patch. README / CHANGELOG 만이면 3번 아니오 → 4번 올리지 않음 | **일부 다르다** |
| 50 저장소 안쪽만 바뀜 | 올리지 않음 | 4번 | 같다 |

47행과 49행의 어긋남은 새로 생긴 것이 아니다. 리뷰 WR-03 의 남은 두 경우이고, 소유자가 2026-10-11 에 "이 gap 에서 고치지 않는다" 고 정했다 (`01-UAT.md` 86행). 그래서 이 둘은 실패로 세지 않았다. 01-04 는 이 두 줄을 건드리지 않았다 (더 나빠지지도 않았다).

**소유자가 읽기 전에 알아야 할 것 셋.** 재리뷰(`01-REVIEW.md`, warning 7 / info 6)의 지적을 그대로 받아들이지 않고, 이 phase 의 must-have 에 닿는 것만 사실관계를 직접 확인했다.

1. **작은 업그레이드의 예시가 그 자체로 Dart 버전을 올리게 하는 변경이다 (리뷰 WR-07, 사실 확인됨).** pub 캐시의 `pubspec.yaml`: `riverpod_lint` 3.1.3 과 3.1.4 는 `sdk: ^3.10.0`, 3.1.9 는 `sdk: ">=3.13.0-0 <4.0.0"`. 그래서 `^3.1.3` → `^3.1.9` 를 "SDK 하한이 `^3.10.4` 인 패키지" 에 대입하면 1번의 첫째 조건(SDK 를 고쳐야 하나)이 "예" 다. 지금 브랜치는 `pubspec.yaml` 이 이미 `sdk: ^3.13.0` 이라 "아니오" 가 맞고, 2.0.0 의 등급(major)도 달라지지 않는다. 남는 문제는 문서가 이 전제를 적지 않았다는 점이다 — 2.0.0 뒤에 plugin 하한을 올릴 때 새 버전이 더 높은 Dart 를 요구하는지 보라는 문장이 없다. 그래서 #19 를 `coincidental-reliance` 로 표시했다.
2. **2번 질문의 목록이 닫혀 있다 (리뷰 WR-09, 문장 확인).** 2번은 "규칙 목록, exclude / errors 설정, plugin 버전" 만 묻는다. 47행(새 프리셋)이 3번으로 떨어지는 것이 그 결과다. ROADMAP 의 Phase 4 후보 `strict-inference` 도 이 목록에 없다 (`.planning/ROADMAP.md` 145행). 이 지적의 나머지 사례는 검증자가 따로 확인하지 않았다.
3. **"이미 켜져 있던" 의 범위 (리뷰 WR-10, 일부만 확인).** 배포 파일의 `analyzer.errors` 항목은 `invalid_annotation_target: ignore` 하나다 (`lib/analysis_options.yaml` 43-44행). ROADMAP 의 Phase 3 결정 사항 D7 은 이 줄을 "옮길지 삭제할지" 로 둔다 (129행). 지우는 변경이 44행(major)인지 46행(minor)인지는 문서 문장만으로 정해지지 않는다. 그 진단의 기본 심각도는 검증자가 확인하지 않았다.

영향 범위: 다음 릴리스 번호 2.0.0 은 위 어느 것과도 무관하다 (SDK 하한 상향은 문서 어디를 읽어도 major). 영향을 받는 것은 2.0.0 뒤의 판정과, Phase 3 / 4 가 이 문서로 등급을 매길 때다.

### 처리 기록표 상세 — Truth 26 의 두 시점

실행 순서: (1) 실행자가 Task 2 를 `6b9eec8` 로 커밋 (2026-10-11 17:20 KST). 그 커밋에 처리 기록표 수정이 들어 있다. (2) 그 뒤 workflow 의 코드 리뷰 게이트가 `VERSIONING.md` 를 재리뷰하고(`507f93e`) 처리 기록표를 **다시 만들었다** (`9c9ca54`, 17:44 KST).

| 구절 | `6b9eec8` 시점 (`git show 6b9eec8:…`) | 지금 파일 |
|------|----------------------------------------|-----------|
| WR-01 · WR-02 · WR-04 가 fixed | 성립 — frontmatter 와 표 모두 | 성립 — frontmatter `disposition: fixed` 셋. 표의 Source 칸에는 도구가 ` (not in the current review)` 를 덧붙였다 |
| WR-03 이 open | 성립 | 성립 — frontmatter 와 표 모두 `open` |
| WR-03 행의 Source 칸에 부분 해소 메모 | 성립 — `01-04-PLAN.md (UAT G-01-1) 가 major 행 누락(기준표 40·41행)만 닫음. README/CHANGELOG 만 고침(47행)과 새 프리셋 추가(45행)는 남음` | **성립하지 않음** — 79행 `\| WR-03 \| warning \| open \| - \|` |
| SUMMARY 에 같은 메모 | 성립 | 성립 — `01-04-SUMMARY.md` 47행, 238행, 243-250행 |

plan 의 Task 2 자동 검사를 두 가지로 돌렸다.

- 처리 기록표를 `6b9eec8` 사본으로 바꿔 실행: 출력 두 줄(`substitution:` / `table:`), rc=0 (bash · zsh).
- 지금 파일로 실행: 같은 두 줄을 찍은 뒤 `FAIL: T2-32 DISPOSITION frontmatter open: 7 없음`, rc=1. 지금 값은 `open: 13` / `total: 16` 이다. 뒤따르는 T2-33 ~ T2-36(표 네 줄의 정확한 문구)도 지금 파일에는 없다.

판단: 실행자는 계획대로 했다. 메모를 지운 것은 실행 뒤에 돈 도구다. 그 표는 스스로 "보존되는 것은 `deferred` 와 그 사유" 라고 적고 있고(97행), plan 01-04 도 이 점을 알고 "오래 남는 기록은 SUMMARY" 라고 적었다. 메모의 내용은 세 곳에 남아 있다 — `01-04-SUMMARY.md`, `01-UAT.md` 86행, 새 `01-REVIEW.md` 의 WR-03 본문(57-72행: 셋째 경우는 해소, 나머지 둘은 그대로). phase 목표에는 닿지 않는다.

그렇다고 통과로 세지 않았다. must-have 의 한 구절이 지금 파일에서 성립하지 않는 것은 사실이고, 표에 다시 적어도 도구가 다시 지우므로 수정 계획으로 닫을 수 없다. 받아들일지는 소유자가 정한다.

**받아들인다면** 이 파일의 frontmatter 에 아래를 적는다 (`accepted_by` 와 `accepted_at` 은 소유자가 채운다).

```yaml
overrides:
  - must_have: "`01-REVIEW-DISPOSITION.md` 에서 WR-01 · WR-02 · WR-04 는 fixed, WR-03 은 open 이다 — WR-03 행의 Source 칸에 부분 해소 메모가 있고, SUMMARY 에도 같은 메모를 남긴다"
    reason: "코드 리뷰 게이트가 처리 기록표를 다시 만들 때 open 행의 Source 칸을 비운다. 같은 메모가 01-04-SUMMARY.md, 01-UAT.md 86행, 01-REVIEW.md 의 WR-03 본문에 남아 있다"
    accepted_by: "{소유자 이름}"
    accepted_at: "{ISO 시각}"
```

### Deferred Items

없음 — 뒤 phase 로 넘긴 gap 이 없다. 참고로 "`ref: main` 에서 tag 로 옮기는 방법" (아래 Anti-Patterns 의 WR-05)은 Phase 5 의 DOCS-04 가 다룬다.

### Advisory (New Scope, Unevidenced)

None — Blocker 로 올렸다가 내린 항목이 없다. 재리뷰의 지적은 Blocker 가 아니라 Warning 으로 분류했고 아래 Anti-Patterns 에 있다.

### Required Artifacts

`gsd-tools query verify.artifacts` 는 네 plan 모두 exit 0 (`all_passed: true`, 합계 10/10).

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `.planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md` | tag 점검·확인·push 출력 원문 | ✓ VERIFIED | 있음. 기록된 SHA 가 실제 원격·로컬 값과 같다 |
| `VERSIONING.md` | 버전 정책 + CHANGELOG 항목 형식; 세 조건의 판정 순서 1번 | ✓ VERIFIED | 127줄 (min 120), `## 기준표` 와 `이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나` 포함. README 링크는 없다 — D-11 이 Phase 5 로 미뤘다 |
| `.fvmrc` | 저장소 고정 Flutter 버전 | ✓ VERIFIED | `"flutter": "3.47.5"`. `fvm` 이 실제로 이 값으로 실행된다 |
| `.vscode/settings.json` | VS Code Dart 확장의 SDK 경로 | ✓ VERIFIED | `".fvm/versions/3.47.5"`, 경로가 존재한다 |
| `pubspec.yaml` | 지원 SDK 하한과 milestone 중 버전 | ✓ VERIFIED | `sdk: ^3.13.0`, `version: 2.0.0-dev`. pub solver 가 이 값으로 옛 SDK 를 거부한다 |
| `CHANGELOG.md` | 2.0.0 항목 — 새 형식의 첫 적용 | ✓ VERIFIED | `## 2.0.0 - 미출시` 와 D-14 내용. 11행은 의도된 자리 표시 |
| `.planning/phases/01-baseline-and-toolchain/01-03-SUMMARY.md` | BASE-02 실측 증거 원문 | ✓ VERIFIED | 있음. 적힌 출력이 이 검증의 재실행 결과와 같다 |
| `.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md` | D-02 · D-09 ① 수정 주석 (원문 보존) | ✓ VERIFIED | `수정 (2026-10-11, UAT G-01-1)` 이 38행과 70행 |
| `.planning/phases/01-baseline-and-toolchain/01-REVIEW-DISPOSITION.md` | WR-01 / WR-02 / WR-04 의 fixed 기록, WR-03 open 유지 + 부분 해소 메모 | ⚠️ 있음 — 메모 한 칸 없음 | `contains: "\| WR-04 \| warning \| fixed \|"` 는 충족. WR-03 의 메모는 재생성으로 사라졌다 (Truth 26) |

**Artifacts:** 10개 가운데 9개 verified, 1개는 Truth 26 과 같은 소유자 결정 대상

### Key Link Verification

`gsd-tools query verify.key-links` 는 12개 중 1개만 자동 판정했다. 나머지 11개는 `from` 이 파일 경로가 아니라 설명 문구여서 도구가 평가하지 못했다 (`Source file not found (from: must be a relative file path…)`). NOT_WIRED 판정이 아니라 미평가다. 11개는 plan 이 적은 `via` 와 `pattern` 으로 직접 확인했다.

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| 로컬 `refs/tags/v1.3.0` | `90a2736…` = `origin/main` | `git rev-parse` 일치 | ✓ WIRED | `git rev-parse 'v1.3.0^{commit}'` = `git rev-parse origin/main` = `90a2736b8d998c84467faf562a0fec720b797eaf` |
| 로컬 `refs/tags/v1.3.0` | origin `refs/tags/v1.3.0` | `git push origin v1.3.0` | ✓ WIRED | 원격과 로컬의 tag 객체 SHA 가 `80e2112578b7a9870e43476a2893bc4972d4a3a9` 로 같다 |
| `VERSIONING.md` § 기준표 | CONTEXT D-05 표 | 11행 문구 그대로 복사 | ✓ WIRED | `diff` 차이 없음 |
| `VERSIONING.md` § CHANGELOG 항목 형식 | `CHANGELOG.md` 최상단 항목 | 제목 형식, ` - ` 한 번 | ✓ WIRED | `## X.Y.Z - YYYY-MM-DD`, CHANGELOG 1행 `## 2.0.0 - 미출시` (구분자 1개) |
| `.fvmrc` | `.vscode/settings.json` | `fvm use 3.47.5` | ✓ WIRED | 도구 자동 판정 (`Pattern found in source`) |
| `pubspec.yaml` (`environment.sdk`) | 사용 프로젝트의 `dart pub get` | pub version solver | ✓ WIRED | 임시 프로젝트 출력에 `requires SDK version ^3.13.0, version solving failed` |
| `CHANGELOG.md` 첫 줄 | Phase 6 REL-03 일치 검사 | ` - ` 앞 토큰이 버전 | ✓ WIRED (출발 쪽) | `^## 2\.0\.0 - ` 일치. 받는 쪽 검사는 Phase 6 에서 만든다 — 아직 없는 것이 정상이다 |
| `VERSIONING.md` § CHANGELOG 항목 형식 | `CHANGELOG.md` 2.0.0 항목 | 형식의 첫 적용 | ✓ WIRED | `### 올리기 전에`, `### 새로 생기는 경고`, `지원 SDK:` 가 양쪽에 있다 |
| § 판정 순서 1번 셋째 조건 | § 기준표 `규칙 심각도를 warning 이상으로 올림` 행 (변경 종류 칸) | 변경 종류를 질문으로 옮김 | ✓ WIRED | 25행에 `이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나`, 44행이 그 행. 옛 결과 문구는 문서에 없다 |
| § 판정 순서 1번 둘째 조건 | § 기준표 `flutter_lints` / `riverpod_lint` 다음 major 행 | "다음 major 로" 한정 | ✓ WIRED | 25행 `다음 major 로 올리나`, 42-43행이 그 두 행. 48행(같은 major 안)은 2번에 남는다 |
| `01-CONTEXT.md` D-09 ① 수정 주석 | § 판정 순서 1번 | 같은 문구 | ✓ WIRED | 70행의 최종 문구와 25행의 조건 문구가 글자 그대로 같다 |
| § 실제 사례 1.3.0 불릿 | § 판정 순서 1번 (세 조건) | 세 조건을 각각 답한다 | ✓ WIRED | 64행 `세 조건 모두 "아니오"`. 대입 결과가 63행의 등급과 같다 |

**Wiring:** 12/12 connections verified (1 자동, 11 수동)

### Data-Flow Trace (Level 4)

해당 없음 — 이 phase 의 산출물은 정적 설정 파일과 문서다. 동적 데이터를 렌더링하는 artifact 가 없다. 설정 값이 실제 소비 주체(FVM, pub solver)에 도달하는지는 Key Link 와 Spot-Check 에서 실행으로 확인했다.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| 원격 tag 가 1.3.0 커밋을 가리킨다 | `git ls-remote origin` | `90a2736…	refs/tags/v1.3.0^{}` | ✓ PASS |
| 원격 브랜치는 `main` 하나다 | `git ls-remote --heads origin` | 한 줄, `refs/heads/main` | ✓ PASS |
| 저장소 루트의 고정 SDK | `fvm flutter --version`, `fvm dart --version` | Flutter 3.47.5, Dart 3.13.4 | ✓ PASS |
| 옛 SDK 는 `pub get` 에서 거부된다 | Dart 3.11.5 / 3.11.1 / 3.11.0 `dart pub get` (`path:` 의존) | 셋 다 rc=1, `version solving failed` | ✓ PASS |
| Flutter 명령으로도 거부된다 | Flutter 3.41.9 `flutter pub get` | rc=1, `Failed to update packages.` | ✓ PASS |
| 지원 SDK 에서는 받는다 | Dart 3.13.4 `dart pub get` | rc=0, `woody_lints 2.0.0-dev from path` | ✓ PASS |
| 옛 SDK 가 `ref: v1.3.0` 에 머물 수 있다 | Dart 3.11.5 `dart pub get` (`git:` + `ref: v1.3.0`) | rc=0, `resolved-ref: "90a2736…"`, `version: "1.3.0"` | ✓ PASS |
| 저장소 자체 분석 | `fvm dart analyze` | `No issues found!` rc=0 | ✓ PASS |
| 하한 상향이 `main` 에 없다 | `git merge-base --is-ancestor 968a5bb main` / `origin/main` | 둘 다 rc=1 (포함되지 않음). `git branch -a --contains 968a5bb` 는 작업 브랜치뿐 | ✓ PASS |
| 결정 기록은 주석만 덧붙었다 | plan 01-04 Task 1 `<automated>` (21개 검사) | 출력 없음, rc=0 (bash · zsh) | ✓ PASS |
| 판정 순서 대입 계산 | plan 01-04 Task 2 `<automated>` 의 `substitution:` / `table:` 줄 | 두 사례와 기준표 여덟 줄 모두 계산값 = 문서값 | ✓ PASS |
| 같은 검사의 처리 기록표 부분 (T2-28 ~ T2-36) | 같은 명령, 지금 파일 | `FAIL: T2-32 DISPOSITION frontmatter open: 7 없음`, rc=1. `6b9eec8` 사본으로는 rc=0 | ⚠️ 지금은 실패 — Truth 26 과 같은 원인 |

이번에 다시 돌리지 않은 것: 지난 검증의 "`.fvmrc` 만 둔 사본에서도 같은 SDK 가 선택된다" 확인. `fvm` 이 저장소 밖 레지스트리(`~/fvm/projects.json`)를 건드릴 수 있어 생략했다. `.fvmrc` 는 그 뒤로 바뀌지 않았다.

### Probe Execution

해당 없음 — `scripts/` 디렉터리가 없고, PLAN / SUMMARY 가 `probe-*.sh` 스크립트를 선언하지 않는다. plan 이 "probe" 라고 부른 것은 임시 사용 프로젝트이며 위 Spot-Check 에서 직접 실행했다.

### Requirements Coverage

plan frontmatter 의 요구사항 ID 는 REL-01 (01-01), BASE-03 · BASE-04 (01-02), BASE-01 · BASE-02 (01-03), BASE-03 (01-04) 다. `REQUIREMENTS.md` 가 Phase 1 에 대응시킨 ID 다섯 개와 정확히 같다. ORPHANED 없음.

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| BASE-01 | 01-03 | 저장소가 고정하는 SDK 가 Flutter 3.47.5 / Dart 3.13.4 다 | ✓ SATISFIED | Truth 2 |
| BASE-02 | 01-03 | SDK 하한이 `^3.13.0` 이어서 지원하지 않는 SDK 는 `pub get` 단계에서 명확히 실패한다 | ✓ SATISFIED | Truth 3, 14, 15 |
| BASE-03 | 01-02, 01-04 | 어떤 변경이 major / minor / patch 인지 정한 버전 정책이 문서로 남아 있다 | ? NEEDS HUMAN | 문서가 있고 결정 원문과 일치하며 G-01-1 이 닫혔다 (Truth 9 ~ 12, 18 ~ 25). 다시 쓴 문서의 소유자 재확인이 남았다 (Truth 4). 기준표 47행과 49행 일부는 판정 순서와 여전히 답이 다르다 (소유자가 범위 밖으로 둠) |
| BASE-04 | 01-02 | CHANGELOG 항목의 형식이 정해져 있다 | ✓ SATISFIED | Truth 5, 16 |
| REL-01 | 01-01 | 1.3.0 내용의 커밋에 `v1.3.0` tag 가 있고 원격에 올라가 있다 | ✓ SATISFIED | Truth 1, 6, 17 |

참고: `REQUIREMENTS.md` 는 다섯 개를 이미 `[x]` / Complete 로 표시한다. BASE-03 은 소유자 재확인이 끝나기 전이다.

### Decision Coverage

All trackable CONTEXT.md decisions are honored by shipped artifacts. (`check.decision-coverage-verify`: honored 20 / total 20, not_honored 없음, blocking false)

### Prohibitions (must-NOT)

여덟 항목 모두 `verification: judgment` 다. 앞의 다섯(01-01 ~ 01-03)은 소유자가 UAT 에서 판정을 마쳤고, 01-04 의 셋은 아직 판정 전이다. 아래 "검증자 판단" 은 비권위 판단이며 통과 판정이 아니다.

| # | Prohibition | 소유자 판정 | 검증자 판단 (비권위) | 근거 |
|---|-------------|-------------|----------------------|------|
| P1 | (01-01) origin 에 올리는 것은 tag `v1.3.0` 하나뿐이다 | pass (`01-UAT.md` 3번) | 그 뒤 달라진 것 없음 | `git ls-remote origin` → `HEAD`, `refs/heads/main`, tag 두 줄뿐 |
| P2 | (01-01) push 한 tag `v1.3.0` 은 옮기거나 지우지 않는다 | pass (4번) | 그 뒤 달라진 것 없음 | 원격 tag 객체 SHA = 로컬 = `80e2112…`, tagger 시각 2026-10-11T04:21:51Z |
| P3 | (01-02) `README.md`, `lib/`, 루트 `analysis_options.yaml` 은 바꾸지 않는다 | pass (5번) | 그 뒤 달라진 것 없음 | `git diff --quiet v1.3.0 HEAD -- lib README.md analysis_options.yaml .gitignore` rc=0 |
| P4 | (01-03) `main` / `origin/main` 의 `lib/` 와 `pubspec.yaml` 은 1.3.0 그대로이고 하한 상향은 milestone 브랜치에만 있으며 push 하지 않는다 | pass (6번) | 그 뒤 달라진 것 없음 | 원격 `main` = `90a2736`. `git diff --quiet v1.3.0 main -- lib pubspec.yaml` rc=0. `968a5bb` 는 `main` 과 `origin/main` 의 조상이 아니다 |
| P5 | (01-03) 기존 CHANGELOG 1.3.0 / 1.0.0 항목은 한 글자도 고치지 않는다 | pass (7번) | 그 뒤 달라진 것 없음 | numstat `12	0`, 마지막 11행 = `git show 90a2736:CHANGELOG.md` |
| P6 | (01-04) `lib/`, `README.md`, 루트 `analysis_options.yaml`, `pubspec.yaml`, `.fvmrc`, `.vscode/`, `CHANGELOG.md`, `.gitignore` 는 바꾸지 않는다. 버전은 올리지 않는다. `main` 과 origin 은 건드리지 않고 아무것도 push 하지 않는다 | 판정 전 — **unverified-prohibition — human review recommended** | 위반 없음 | `git diff --quiet 23d2674 -- lib README.md analysis_options.yaml pubspec.yaml .fvmrc .vscode CHANGELOG.md .gitignore` rc=0. `git diff --name-only 23d2674 HEAD -- . ':(exclude).planning'` → `VERSIONING.md` 한 줄. 로컬 `main` 의 마지막 reflog 는 2026-10-11T10:28:57+09:00 (01-04 커밋은 17:19, 17:20). 원격은 그대로, upstream 없음 |
| P7 | (01-04) D-04, D-05, D-09 3. 은 바꾸지 않는다. WR-03 은 major 행 누락만 닫고 open 으로 남긴다 | 판정 전 — **unverified-prohibition — human review recommended** | 위반 없음 | 기준표 13줄이 `23d2674` · CONTEXT D-05 표와 같다. 실제 사례 머리 줄 불변. 판정 순서 2 ~ 4번 불변. 처리 기록표의 WR-03 은 `open` |
| P8 | (01-04) `01-CONTEXT.md` 의 기존 줄은 한 줄도 지우거나 고치지 않는다 | 판정 전 — **unverified-prohibition — human review recommended** | 위반 없음 | `23d2674` 대비 `diff` 의 `<` 줄 0, 추가 2줄 (38행, 70행) |

### Anti-Patterns Found

debt marker(`TBD` / `FIXME` / `XXX`, `TODO` / `HACK` / `PLACEHOLDER`)는 phase 가 바꾼 파일(`VERSIONING.md`, `CHANGELOG.md`, `pubspec.yaml`, `.fvmrc`, `.vscode/settings.json`) 어디에도 없다. Blocker 없음.

재리뷰(`01-REVIEW.md`: critical 0, warning 7, info 6)의 지적은 사실로 전제하지 않고 단서로 썼다. "확인" 칸은 검증자가 직접 확인한 범위다.

| File | Line | Pattern | Severity | 확인 | Impact |
|------|------|---------|----------|------|--------|
| `VERSIONING.md` | 30, 48 | 같은 major 안 상향의 예시 `^3.1.3` → `^3.1.9` 가 그 자체로 Dart 3.13 을 요구한다 (WR-07) | Warning | 사실 확인 (pub 캐시 `environment.sdk`) | 2.0.0 뒤 plugin 하한을 올릴 때 SDK 요구가 함께 올라가도 minor 로 매길 수 있다. Truth 19 의 전제 |
| `VERSIONING.md` | 26-28, 47, 49 | 판정 순서와 기준표가 새 프리셋 추가, README / CHANGELOG 만 고침에 다른 등급을 낸다 (WR-03 의 남은 두 경우) | Warning | 직접 대입으로 확인 | 소유자가 이 gap 범위 밖으로 둠. Phase 3 이 프리셋 파일을 추가하지만 2.0.0 은 어차피 major |
| `VERSIONING.md` | 26 | 2번의 목록이 닫혀 있어 목록에 없는 설정 변경이 3번(patch)으로 떨어진다 (WR-09) | Warning | 문장만 확인 | Phase 4 가 `strict-inference` 등을 채택하면 등급이 문장으로 정해지지 않는다 |
| `VERSIONING.md` | 25, 30, 56 | "이미 켜져 있던 규칙의 심각도가 올라가나" 의 범위가 정해져 있지 않다 (WR-10) | Warning | 일부 확인 (`lib/analysis_options.yaml` 43-44행, ROADMAP 129행) | Phase 3 의 D7 (`invalid_annotation_target: ignore` 처리) 등급 판정에 걸린다 |
| `VERSIONING.md` | 5, 57 | 5행은 "기준은 하나 — 받는 쪽이 겪는 일", 57행은 "등급은 왼쪽 칸의 변경 종류로 매긴다" (WR-08) | Warning | 두 문장 확인 | 읽는 사람이 어느 쪽을 기준으로 삼을지 문장이 엇갈린다 |
| `VERSIONING.md`, `CHANGELOG.md` | 5 / 7 | "tag 하나에 고정해서 받는다" 는 지금 사실이 아니다 — `README.md` 31, 42행은 `ref: main` 이다 (WR-05) | Warning | README 두 줄 확인 | `ref: main` 프로젝트는 `v1.3.0` 으로 옮겨야 머물 수 있다. 옮기는 방법은 Phase 5 (DOCS-04) 가 다룬다. `main` 병합 전에 필요하다 |
| `VERSIONING.md` | 103-119 | 예시가 "규칙 하나를 추가" 인데 경고 표에는 규칙이 둘이다 (WR-06). 소유자가 고른 원문 그대로다 | Warning | 확인 | Phase 4 가 표의 행 규칙을 추측해야 할 수 있다. SC5 를 막지는 않는다 |
| `01-REVIEW-DISPOSITION.md` | 70-71, 79 | 재생성으로 WR-03 메모가 사라지고 `open: 13` / `total: 16` 이 되어 plan 01-04 Task 2 검사가 지금 파일로는 rc=1 | Warning | 두 시점 모두 실행 | Truth 26. `01-VALIDATION.md` 61행과 `01-SECURITY.md` 52행이 이 사정을 이미 적어 두었다 |
| `CHANGELOG.md` | 11 | `(Phase 4 실측 후 채움)` 자리 표시 | Info | 확인 | 의도된 자리다 (D-14). `.planning/WINDOWS.md` id 1 로 `open` 추적 중 |
| `.claude/CLAUDE.md` | 여러 줄 | `3.41.2` / `3.10.4` 옛 버전 서술 | Info | 이 검증의 주입 문맥에서 확인 | phase 범위 밖. 모든 에이전트에 주입되므로 뒤 phase 가 옛 버전을 사실로 읽을 수 있다 |
| git (로컬 `main`) | — | 로컬 `main` 이 `origin/main` 보다 커밋 7개 앞서 있고 전부 `.planning/` 문서다 | Info | `git rev-list --count origin/main..main` = 7 | `lib/` · `pubspec.yaml` 은 1.3.0 그대로라 제약 위반이 아니다. `main` 을 그대로 push 하면 `.planning/` 이 공개 저장소에 올라간다 |

재리뷰의 나머지 Info(IN-01 ~ IN-06)는 이 phase 의 must-have 에 닿지 않아 따로 확인하지 않았다.

### Test Quality Audit

테스트 프레임워크와 테스트 파일은 없다 (설정 전용 패키지). 검증은 셸 명령이다.

| 검사 | Linked Req | 비교 기준 | Assertion Level | Verdict |
|------|-----------|-----------|-----------------|---------|
| 01-01 ~ 01-03 의 `<automated>` | REL-01, BASE-01, BASE-02, BASE-04 | phase 이전 커밋(`90a2736`), 외부 판정자(pub version solver, GitHub 의 원격 ref), 결정 원문 | Value | 순환 아님 |
| 01-04 Task 1 `<automated>` | BASE-03 | 고정 커밋 `23d2674` | Value | 순환 아님 |
| 01-04 Task 2 `<automated>` 의 대입 계산 | BASE-03 | 문서의 한 부분(판정 순서)을 다른 부분(사례, 기준표)과 비교 | Value (일관성) | 목적에 맞다 — 다만 아래 두 가지 |

**Disabled tests on requirements:** 0
**Circular patterns detected:** 0
**Insufficient assertions:** 2 → Warning

1. 대입 계산은 줄마다 "사실" 을 검사 안에 직접 적어 넣는다. 48행의 사실은 "SDK 를 고칠 일 없음" 으로 고정되어 있어, 예시 버전이 실제로 더 높은 Dart 를 요구한다는 점(위 WR-07)은 이 검사로 드러나지 않는다.
2. 기준표 11줄 가운데 8줄만 계산한다. 47, 49, 50행은 일부러 뺐다 (WR-03 의 남은 범위). 뺀 줄 가운데 둘은 실제로 답이 다르다.

지난 검증이 적은 "01-02 Task 1 의 검사는 `→ minor` / `→ major` 문자열만 본다" 는 01-04 Task 2 의 계산이 덮었다.

### Human Verification Required

이 phase 는 인프라 성격이지만 ROADMAP success criterion 4 가 소유자의 읽기·판정을 직접 요구하고 plan 01-04 가 `<human-check>` 를 phase 끝으로 미뤘으므로 사람 확인을 생략하지 않는다. 지난 UAT 에서 답한 2 ~ 7번은 그 뒤로 달라진 것이 없어 다시 묻지 않는다.

### 1. 버전 정책 문서 다시 읽기 (SC4, BASE-03)

쉬운 말로: 버전 번호를 얼마나 올릴지 정하는 네 질문에 실제 변경 넷을 대 보고, 문서가 적어 둔 답과 같은지 본다. 지난번에 문제가 나온 그 항목이고, 문서를 고쳤으므로 다시 한다.

**Test:** `VERSIONING.md` 의 "판정 순서" (25-28행)에 다음을 대 본다.
1. 1.3.0 — 그때까지 꺼져 있던 `riverpod_lint` 규칙을 처음 켰다. 1번 질문의 세 조건을 모두 따진다.
2. 2.0.0 — 지원하는 Dart 최저 버전을 올렸다.
3. 맨 앞자리가 바뀌는 큰 업그레이드 — 기준표의 `flutter_lints` 6 → 7 줄(42행)과 `riverpod_lint` 3 → 4 줄(43행).
4. 맨 앞자리가 같은 작은 업그레이드 — 기준표의 `riverpod_lint` `^3.1.3` → `^3.1.9` 줄(48행).

**Expected:**
1. 1번의 세 조건이 모두 "아니오" → 2번 "예" → minor. 새로 켜진 규칙 가운데 warning 등급이 있었다는 사실이 적혀 있고(65행), 그것이 왜 1번이 아니라 2번인지(56행) 문서만 읽고 납득된다.
2. 1번의 첫째 조건이 "예" → major.
3. 1번의 둘째 조건이 "예" → major. 기준표의 그 두 줄과 같다.
4. 1번 "아니오" → 2번 "예" → minor. 기준표의 그 줄과 같다.

네 답이 "실제 사례" 절(63-70행)과 "기준표" (40-50행)에 적힌 등급과 같다.

**검증자가 미리 알려 두는 것:**
- 계산으로는 확인했다. 두 사례와 기준표 여덟 줄은 문서에 적힌 등급과 같은 답이 나온다.
- 4번의 예시에는 문서에 적히지 않은 전제가 있다. `riverpod_lint` 3.1.9 는 그 자체가 Dart 3.13 이상을 요구한다 (3.1.3 은 3.10 이상). 2.0.0 은 Dart 최저 버전을 3.13 으로 함께 올리므로 4번의 답은 "아니오" 가 맞다. 다만 문서에는 "올리려는 버전이 더 높은 Dart 를 요구하는지 본다" 는 말이 없다. 이대로 받아들일지, 30행에 한 문장을 더할지 정한다.
- 기준표의 "새 프리셋 파일을 추가함" (47행)과 "README·CHANGELOG 만 고침" (49행)은 네 질문을 따라가면 표와 다른 답이 나온다. 지난번에 "이번에는 고치지 않는다" 고 정한 것이라 이 항목의 통과 여부에는 넣지 않는다.

**Why human:** "읽고 판정할 수 있다" 는 사람의 이해 여부다. 계산 결과는 명령으로 확인했지만 설명이 납득되는지는 소유자만 안다.

### 2. 리뷰 지적 처리 기록표의 사라진 메모 (01-04 must-have)

쉬운 말로: 리뷰 지적을 어떻게 처리했는지 적어 두는 표가 있다. 실행자가 그 표의 한 줄에 "여기까지 닫았고 이것이 남았다" 는 메모를 적었는데, 그 뒤에 리뷰 도구가 표를 새로 만들면서 메모 칸을 비웠다. 메모 내용은 다른 문서 세 곳에 그대로 남아 있다.

**Test:** `01-REVIEW-DISPOSITION.md` 79행(`| WR-03 | warning | open | - |`)과 `01-04-SUMMARY.md` 243-250행("WR-03 부분 해소 기록")을 나란히 본다.

**Expected:** 둘 중 하나를 고른다.
- (가) 받아들인다 — 메모는 SUMMARY, `01-UAT.md` 86행, 새 `01-REVIEW.md` 의 WR-03 본문에 남아 있으므로 표에는 없어도 된다. 이 경우 위 "처리 기록표 상세" 의 `overrides` 문안을 이 파일의 frontmatter 에 적는다.
- (나) 표에 다시 적는다 — 다만 열림(open) 상태인 줄의 메모는 리뷰 도구를 다시 돌리면 또 지워진다.

**Why human:** must-have 의 한 구절이 지금 파일에서 성립하지 않는다. 실행자의 잘못이 아니고 계획으로 닫히지도 않으므로, 받아들일지는 소유자만 정할 수 있다.

### 3 ~ 5. 01-04 의 금지 사항 세 가지 (P6 ~ P8)

쉬운 말로: 이번 수정이 "하지 않기로 한 것" 을 지켰는지 확인한다. 검증자가 본 바로는 셋 다 지켰다.

**Test:** 위 "Prohibitions" 표의 P6, P7, P8 을 하나씩 확인한다.
- P6 — 받는 쪽에 전달되는 파일과 버전 번호를 건드리지 않았고, GitHub 에 아무것도 올리지 않았다.
- P7 — 확정된 결정 셋(기준표 11줄, 심각도 상향은 major, 1.3.0 = minor · 2.0.0 = major)을 바꾸지 않았고, 리뷰 지적 WR-03 을 닫지 않고 열어 두었다.
- P8 — 결정 기록(`01-CONTEXT.md`)의 기존 줄을 지우거나 고치지 않고 주석 두 줄만 덧붙였다.

**Expected:** 세 항목 모두 위반이 없다. 검증자의 비권위 판단은 전부 "위반 없음" 이고 근거 명령이 표에 있다.

**Why human:** judgment-tier prohibition 은 interactive 모드에서 항목마다 소유자의 명시적 판정이 필요하다.

### Gaps Summary

명령으로 판정할 수 있는 must-have 가운데 FAILED 는 없다. MISSING / STUB artifact, 끊어진 key link, blocker 도 없다. deferred 로 옮길 gap 도 없다.

지난 UAT 의 gap G-01-1 은 닫혔다. 판정 순서 1번이 세 조건이 되었고, 1.3.0 을 문자 그대로 대입해도 minor 가 나온다. 이것은 문자열 존재가 아니라 대입 계산으로, 그리고 `90a2736` 의 diff 로 세 조건의 사실을 따로 확인했다.

남은 것은 사람 확인 다섯 항목이다.

- **무게가 있는 것은 1번이다.** 다시 쓴 `VERSIONING.md` 를 소유자가 읽는 일이고, 읽을 때 알아야 할 전제 하나(작은 업그레이드의 예시가 Dart 3.13 을 요구한다)를 함께 적었다. 이 전제는 2.0.0 의 등급을 바꾸지 않지만, Phase 3 이 `riverpod_lint` 하한을 `^3.1.9` 로 올리고 그 뒤 릴리스가 이 문서를 선례로 삼기 전에 소유자가 알고 있어야 한다.
- **2번은 기록의 문제다.** plan 01-04 의 must-have 한 구절이 지금 파일에서 성립하지 않는다. 실행자는 계획대로 했고, 실행 뒤에 돈 리뷰 도구가 표를 다시 만들었다. phase 목표에는 닿지 않지만 통과로 세지 않고 소유자 결정으로 넘겼다.
- **3 ~ 5번은 근거가 갖춰진 확인이다.**

fingerprint 에 관한 메모: `covered_files` 에 `01-CONTEXT.md` 는 넣고 `01-REVIEW-DISPOSITION.md` 는 넣지 않았다. 뒤의 파일은 리뷰 도구가 돌 때마다 다시 만들어지므로, 넣으면 이 보고서가 도구 실행만으로 stale 이 된다. 그 파일에 걸린 판정(Truth 26)은 이미 소유자 결정으로 넘겼다.

---

_Verified: 2026-10-11T08:53:57Z_
_Verifier: Claude (gsd-verifier)_
