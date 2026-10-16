---
phase: 06-release
verified: 2026-10-16T11:47:02Z
status: gaps_found
score: 60/63 must-haves verified
covered_files:
  - .claude/skills/spike-findings-woody-lints/SKILL.md
  - .claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md
  - .claude/skills/spike-findings-woody-lints/references/rule-status-check.md
  - .github/workflows/verify.yml
  - .planning/phases/06-release/06-01-PLAN.md
  - .planning/phases/06-release/06-01-SUMMARY.md
  - .planning/phases/06-release/06-02-PLAN.md
  - .planning/phases/06-release/06-02-SUMMARY.md
  - .planning/phases/06-release/06-03-PLAN.md
  - .planning/phases/06-release/06-03-SUMMARY.md
  - .planning/phases/06-release/06-04-PLAN.md
  - .planning/phases/06-release/06-04-SUMMARY.md
  - .planning/phases/06-release/06-05-PLAN.md
  - .planning/phases/06-release/06-05-SUMMARY.md
  - .planning/phases/06-release/06-06-PLAN.md
  - .planning/phases/06-release/06-06-SUMMARY.md
  - .planning/phases/06-release/06-07-PLAN.md
  - .planning/phases/06-release/06-07-SUMMARY.md
  - .planning/phases/06-release/06-08-PLAN.md
  - .planning/phases/06-release/06-08-SUMMARY.md
  - .planning/phases/06-release/06-09-PLAN.md
  - .planning/phases/06-release/06-09-SUMMARY.md
  - .planning/phases/06-release/06-10-PLAN.md
  - .planning/phases/06-release/06-10-SUMMARY.md
  - .planning/phases/06-release/06-11-PLAN.md
  - .planning/phases/06-release/06-11-SUMMARY.md
  - CHANGELOG.md
  - README.md
  - VERSIONING.md
  - example/README.md
  - example/pubspec.lock
  - fixtures/base_codegen/pubspec.lock
  - fixtures/base_only/pubspec.lock
  - fixtures/base_riverpod/pubspec.lock
  - fixtures/overrides/pubspec.lock
  - fixtures/recommended/pubspec.lock
  - pubspec.yaml
  - tool/smoke.dart
  - tool/verify.dart
covered_digest: "v3:sha256:df2c3f330a9867a5919c675588b202f9df1ceaca3753d83dc7febc015fcf4d0f"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 40/41
  gaps_closed:
    - "pubspec 쪽 — 겹따옴표 · 홑따옴표 여러 줄 스칼라 안의 열 0 `version:` 줄 (CR-01): (i) 가 YAML 값을 쓰고 (h) 가 원문 전체를 견주어 평소 · `--tag` 둘 다 실패한다 (직접 재현)"
    - "CHANGELOG 쪽 — 열 0 HTML 주석 블록 · 두 종류 펜스 · 1 ~ 3칸 들여 쓴 ATX · `--` 이상 setext · 인용 · 목록 안의 h2 · U+FEFF: `package:markdown` 과 GitHub 화면의 첫 h2 가 같다 (직접 견줌)"
  gaps_remaining:
    - "ROADMAP 성공 기준 1 · REL-03 — CHANGELOG 최상단 reader 가 GitHub 화면과 갈리는 꼴이 둘 남았다 (좁아짐)"
  regressions: []
gaps:
  - truth: "ROADMAP 성공 기준 1 · REL-03 (함께: 06-08 must_have 2 「HTML 주석 안의 열 0 `## ` 줄은 제목이 아니다」) — tag 이름, `pubspec.yaml` 의 version, CHANGELOG 최상단 버전이 서로 다르면 CI 의 검사가 실패한다"
    status: partial
    reason: "`changelogTop` 은 `package:markdown` 7.3.1 의 첫 h2 를 읽는데, 이 해석기가 GitHub 화면과 갈리는 꼴이 둘 남았다. 복제본의 전체 실행에서 셋이 서로 다른데도 종료 코드 0 · 10/10 이었다. (1) 한 글자 `-` 밑줄의 setext 제목 (인용 · 목록 안 포함): GitHub 화면의 첫 h2 는 그 새 항목인데 검사는 그 아래의 옛 `## 2.0.0` 을 읽는다 — `2.1.0 - 미출시` / `-` 머리에서 평소 · `--tag v2.0.0` · `GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v2.0.0` 셋 모두 rc 0, 날짜를 단 `2.0.1 - 2026-10-20` / `-` 머리에서 `--tag v2.0.0` rc 0 (대조 `--` 밑줄은 rc 1). (2) 인용 · 목록 항목(중첩 포함) · 단락 안에서 연 `<!--`: GitHub 화면에는 h2 가 하나도 없는데(옛 항목까지 주석으로 사라짐) 검사는 그 안의 `## 2.0.1` 을 최상단으로 읽는다 — 새 릴리스 상태(pubspec `2.0.1` · README `ref: v2.0.1` 둘 · lock 여섯)에서 `> <!--` 머리로 `--tag v2.0.1` · 환경변수 · 평소 셋 모두 rc 0, 단락 + 빈 줄 변형(reviewer 표 밖)도 `--tag v2.0.1` rc 0 (대조: 머리 조각 없는 같은 상태는 rc 1). 문서 주석 · `pubspec.yaml` 주석 · `example/README.md` 의 「GitHub 화면과 같다」 「raw `<h2>` 가 다를 수 있는 유일한 꼴」 문장도 이 두 꼴에서 사실이 아니다. 이미 올린 v2.0.0 과 지금 `main` 의 CHANGELOG(1행이 `## 2.0.0 - 2026-10-15`)는 해당하지 않는다 — 다음 릴리스의 gate 문제다."
    artifacts:
      - path: "tool/verify.dart"
        issue: "`changelogTop` (1709 ~ 1732행) 이 `package:markdown` 의 첫 h2 를 그대로 믿는다 — 해석기가 GitHub 과 다르게 읽는 꼴을 알아채는 장치가 없다"
      - path: "tool/verify.dart"
        issue: "문서 주석 (1686 ~ 1702행) 의 「GitHub 화면이 그리는 제목과 같다」 · 「렌더된 화면과 다를 수 있는 유일한 꼴」 이 두 꼴에서 틀린다"
      - path: "pubspec.yaml"
        issue: "`dev_dependencies` 위 주석의 「GitHub 화면과 같게」 가 두 꼴에서 틀린다"
      - path: "example/README.md"
        issue: "705행 (3) 의 「유일한 꼴」 문장, M 기록에 두 꼴이 없다"
    missing:
      - "소유자가 길을 고른다 — (가) 꼴을 하나씩 막는 수정 (06-REVIEW.md WR-02 · WR-05 의 Fix: 한 글자 밑줄을 `--` 로 넓힌 사본을 다시 해석해 첫 h2 가 다르면 실패, 첫 h2 앞에 닫히지 않은 `<!--` 가 남으면 실패) 또는 (나) 구조를 바꾸는 길 (CHANGELOG 첫 줄이 최상단 제목이어야 한다는 형식 규칙을 검사로 굳히고 해석기와 둘이 같아야 통과 — 아래 「Gaps Summary」)"
      - "어느 길이든 실패 방향을 꼴로 기록 · 단언한다: 한 글자 밑줄 (맨 앞 · 인용 · 목록, 뒤 공백 · 탭), 인용 · 목록 · 중첩 목록 · 단락 안에서 연 `<!--` (닫힘 · 닫히지 않음, 빈 줄 있음 · 없음) — 평소 · `--tag` · `GITHUB_REF_NAME` 세 경로"
      - "문서 주석 · `pubspec.yaml` 주석 · `example/README.md` (3) 의 「GitHub 화면과 같다 / 유일한 꼴」 문장을 고른 길에 맞게 고친다"
      - "고침은 저장소 안쪽만 바꾼다 — 새 버전 번호는 필요 없다 (VERSIONING.md 기준표). 다음 릴리스 전에 닫는다"
  - truth: "06-09 must_have 4 — 임시 폴더 정리는 `finally` 에 있어 어떤 예외로 끝나도 돈다"
    status: partial
    reason: "하위 명령의 출력이 UTF-8 이 아니면 `runProcess` 의 디코더(`utf8.decoder.bind(…).join()`, 419 ~ 420행)가 아무도 듣지 않는 future 에서 FormatException 을 내고, 처리되지 않은 비동기 예외로 isolate 가 바로 끝난다 (종료 코드 255). 하네스에서 `runProcess` 를 `try { … } finally { … }` 안에서 불렀더니 rc 255 · `Unhandled exception: FormatException: Invalid UTF-8 byte` 였고 finally 의 출력이 없었다 — smoke 라면 새 pub cache 가 든 임시 폴더가 남는다. 머리 주석 46행 「255 … 임시 폴더는 finally 가 지운다」 도 이 경로에서 틀린다. 세 명령이 UTF-8 이 아닌 바이트를 낼 일은 드물고, phase 목표(v2.0.0 의 적용 확인)에는 영향이 없다."
    artifacts:
      - path: "tool/smoke.dart"
        issue: "419 ~ 420행의 엄격한 UTF-8 디코딩 — 오류가 처리되지 않은 비동기 예외가 되어 997 ~ 1000행의 finally 를 건너뛴다"
    missing:
      - "`const Utf8Decoder(allowMalformed: true)` 로 디코딩하거나, 두 future 에 띄우는 즉시 오류 처리를 붙인다 (06-REVIEW.md IN-04 의 Fix)"
      - "오프라인 하네스에 UTF-8 이 아닌 출력 꼴을 더해 정리가 도는지 단언한다"
      - "이 길을 고치지 않기로 하면, must_have 문장을 「동기 흐름의 예외」 로 좁히는 override 를 소유자가 단다 (아래 「Gaps Summary」 의 문안)"
human_verification:
  - test: "GitHub 의 Actions → `verify` 화면을 열어 `Run workflow` 버튼이 보이는지 본다 (02-UAT 6번 · D-03 (6) — 06-06 Task 3 의 `<human-check>`, 지난 회차부터 열려 있음)"
    expected: "기본 브랜치 `main` 에 `.github/workflows/verify.yml` 이 있으므로 버튼이 보인다 (실행 자체는 `workflow_dispatch` run 38850984674 가 `success`)"
    why_human: "GitHub 웹 화면의 버튼 표시는 CLI 로 볼 수 없다"
  - test: "판정 등급 prohibition 37건(06-01 ~ 06-07 의 25건 + gap 수정 06-08 ~ 06-11 의 12건, PLAN frontmatter 의 `MUST NOT`)의 LLM 판정(아래 「Prohibitions」 표 — 비권위)을 사람이 훑어본다"
    expected: "표의 판정에 동의하거나, 다르게 보는 항목을 적는다"
    why_human: "judgment 등급 prohibition 은 시행 증거(test)가 없어 자동 판정이 권위를 갖지 않는다 (ADR-550 D4)"
---

# Phase 6: Release Verification Report

**Phase Goal:** 새 버전이 annotated tag 로 원격에 있어 사용 프로젝트가 `ref: vX.Y.Z` 로 버전을 고정할 수 있고, 그 tag 를 git 의존성으로 받은 프로젝트에서 규칙과 plugin 이 실제로 적용됨이 확인되어 있다
**Verified:** 2026-10-16T11:47:02Z
**Status:** gaps_found
**Re-verification:** Yes — gap 수정 06-08 ~ 06-11 뒤 (지난 회차 gaps_found 40/41)

목표 문장의 앞부분은 지금도 참이다. 원격에 annotated tag `v2.0.0` 이 있고, 그것을 `ref: v2.0.0` 으로 받은 빈 프로젝트에서 규칙과 plugin 진단이 나온다 (이번에 다시 돌림). 지난 gap 가운데 pubspec 쪽은 닫혔다. CHANGELOG 쪽은 좁아졌지만 닫히지 않았다. `package:markdown` 이 GitHub 화면과 다르게 읽는 꼴이 둘 남아, 다음 릴리스의 gate 가 셋이 서로 다른데도 통과한다. 따로 06-09 의 정리 must_have 하나가 UTF-8 이 아닌 출력에서 성립하지 않는다.

## 확인 방법

- 원격 · CI 는 본 작업 폴더에서 읽기 전용 명령만 썼다 — `git fetch` · `git ls-remote` · `git show origin/main:…` · `git merge-base --is-ancestor` · `gh run list/view --log` · `gh pr view` · `gh api` (커밋 부모 수).
- 본 작업 폴더에서는 읽기 실행만 했다: `fvm dart run tool/verify.dart` 네 번(평소 · `--tag v2.0.0` · `--tag v2.0.1` · 환경변수 `v2.0.0`), 사용법 셋, `tool/smoke.dart` 다섯 번(`v2.0.0` 통과 · SIGINT · 인자 없음 · 없는 ref · `v1.3.0`). smoke 의 임시 폴더는 `TMPDIR` 로 이 검증의 임시 폴더 안에 두었다. 실행 전후 `git status --porcelain` 은 orchestrator 상태 파일 넷만으로 같았다.
- 깨뜨리는 변경은 모두 `mktemp -d` 로 만든 임시 폴더 하나 안의 `git clone --local` 복제본에서만 했다. 복제본마다 `rev-parse --show-toplevel` 이 복제본인지 먼저 보고, 루트 `fvm dart pub get --no-example` 을 돌렸다. 새 릴리스 상태(상태 C)는 VERSIONING 「릴리스 절차」 2번대로 lock 여섯을 `fvm dart pub get` 으로만 다시 받았다 (numstat: pubspec 1 · README 2 · lock 여섯 각 1).
- 함수 단위 하네스는 복제본 밖(같은 임시 폴더)의 Dart 파일이 복제본의 `tool/verify.dart` · `tool/smoke.dart` 를 import 해 `changelogTop` · `checkShippedComposition` · `checkVersionAgreement` · `judge` · `runProcess` 를 직접 불렀다.
- Markdown 의 기준값은 GitHub 렌더 API (`POST /markdown`, `mode: markdown`) 에 합성한 머리 조각(공개 CHANGELOG 앞에 붙인 것)을 보내 얻었다. 머리 조각 59개를 두 쪽에 넣고 첫 h2 를 견주었다.
- SDK 는 Flutter 3.47.5 / Dart 3.13.4, 루트 lock 의 `markdown` 은 7.3.1 이다.
- 끝에 임시 폴더를 통째로 지웠다.

## Goal Achievement

### Observable Truths — ROADMAP 성공 기준

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| SC1 | tag 이름 · `pubspec.yaml` version · CHANGELOG 최상단 버전이 서로 다르면 실패하는 검사가 CI 의 tag 트리거에 걸려 있고, 일부러 어긋나게 만든 입력에서 실제로 실패함이 확인되어 있다 | ✗ FAILED (partial) | 걸려 있음: `main` 의 `verify.yml` 은 필터 없는 `push:` 이고 `main` push 실행 38888830252 (`0038572`) 가 고친 검사로 10/10 이다. 보통의 어긋남에서는 실패한다: 본 작업 폴더 `--tag v2.0.1` rc 1 (블록 둘), CR-01 입력 평소 · `v2.0.0` 둘 다 `passed=false`, 대조 a2 · b0 rc 1. **거짓 통과:** a · a3 (한 글자 `-` setext) 와 b · b2 (인용 · 단락 안에서 연 `<!--`) — 전체 실행 rc 0 · 10/10 (아래 spot-check) |
| SC2 | `git ls-remote --tags origin` 에 새 버전의 annotated tag 가 보이고, 그 tag 의 `pubspec.yaml` version 과 CHANGELOG 최상단 버전이 tag 이름과 같다 | ✓ VERIFIED (회귀 확인) | `753f520…  refs/tags/v2.0.0` · `704bf56…  refs/tags/v2.0.0^{}` 그대로, `cat-file -t` = `tag`, `^{commit}` = `704bf56fb028…`. tag 4줄(`v1.3.0` · `v2.0.0`) 밖의 새 tag 는 없다. tag 커밋의 version · CHANGELOG 1행은 지난 회차 그대로이고 두 갈림 꼴에 해당하지 않는다 |
| SC3 | 빈 프로젝트가 새 tag 를 git 의존성(`ref: vX.Y.Z`)으로 받아 `dart analyze` 를 돌리면 기본 규칙 진단과 `riverpod_lint` plugin 진단이 둘 다 보고된다 | ✓ VERIFIED | 고친 smoke 로 직접 돌림 — `fvm dart run tool/smoke.dart v2.0.0` rc 0 (39초). lock `source git` · README 의 url · `resolved-ref 704bf56…`. 두 주소 각각 `info prefer_single_quotes` · `warning provider_parameters` · `riverpod_lint 3.1.9`, 판정 줄에 include 사슬 끊김 없음, stderr 빈 출력, 남은 임시 폴더 0 |

### Observable Truths — PLAN must_haves

06-01 ~ 06-07 (38건)은 지난 회차에 VERIFIED 였고, 이번에는 회귀만 봤다. README · VERSIONING · CHANGELOG · `lib/` · `.github/` 는 `v2.0.0` 뒤로 바뀌지 않았다 (`git log v2.0.0..HEAD -- …` 0건). 02-UAT · 05-UAT · 05-REVIEW-DISPOSITION 도 06-07 뒤로 바뀌지 않았다. 06-08 이 고친 `checkVersionAgreement` · 06-09 가 고친 smoke 의 회귀는 직접 돌렸다:

| Plan | # | Truth (요약) | Status | 이번 확인 |
|------|---|--------------|--------|-----------|
| 06-01 | 1 · 2 · 4 | 평소 모드 · `-dev` 꼬리 블록 · `GITHUB_REF_*` 모드 | ✓ VERIFIED | 본 작업 폴더의 평소 · `--tag v2.0.0` · 환경변수 `v2.0.0` rc 0 과 각 모드 줄, `--tag v2.0.1` rc 1. `-dev` 꼬리 블록은 하네스(CR-01 입력 · 한 줄 `2.0.0-dev`)에서 나왔다 |
| 06-01 | 3 | 값 없음 · 모르는 인자 · 남는 인자는 64 와 사용법 | ✓ VERIFIED | `--tag` · `--bogus` · `--tag v2.0.0 extra` 셋 다 rc 64 · 사용법 줄 |
| 06-01 | 5 ~ 8 | `verify.yml` 7행 · M92 ~ M97 · IN-12 · 255 기록 | ✓ VERIFIED | 파일이 지난 회차 뒤로 바뀌지 않았다 (`verify.yml` 은 `v2.0.0` 뒤 0건, `example/README.md` 는 06-08 이 소절을 더했을 뿐 M1 ~ M97 행은 그대로) |
| 06-02 | 1 ~ 5 | README · VERSIONING 문장 | ✓ VERIFIED | 두 파일 `v2.0.0` 뒤 0건 |
| 06-03 | 1 ~ 7 | smoke 의 흐름 · 판정 · 실패 방향 · 사용법 · SDK · import | ✓ VERIFIED | 고친 smoke 로 다시 돌림: `v2.0.0` rc 0, 인자 없음 64, `no-such-ref-xyz` 69, `v1.3.0` rc 1 (`기대 커밋: 90a2736…`, `recommended` 쪽 두 규칙 없음 · include 사슬 끊김 1줄, 옛 주소 쪽 있음). import 는 `dart:convert` · `dart:io` 둘, 복제본에서 `dart analyze tool` `No issues found!` · format rc 0 |
| 06-04 | 1 ~ 5 | 릴리스 커밋 · push · 예행 | ✓ VERIFIED | 원격 사실 그대로 (tag → `704bf56`) |
| 06-05 | 1 · 2 · 4 · 6 | 로컬 tag · 소유자 응답 뒤 push · tag CI · 옮기지 않음 | ✓ VERIFIED | tag 객체 `753f520` 그대로, run 38844667011 로그의 `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` · 10/10 |
| 06-06 | 1 ~ 5 | PR #1 · merge commit · dispatch · `main` push | ✓ VERIFIED | `5ee5a12` 가 `origin/main` 의 조상, 실행 넷 `success` 그대로 |
| 06-07 | 1 ~ 4 | 처리 기록 셋 | ✓ VERIFIED | 세 파일이 06-07 뒤로 바뀌지 않았다 |

gap 수정 plan 의 must_haves (22건):

| Plan | # | Truth (요약) | Status | Evidence |
|------|---|--------------|--------|----------|
| 06-08 | 1 | (i) 는 YAML 의 version, (h) 는 원문 전체 ↔ YAML, `pubspecReleaseVersion` 은 `pubspecVersionText` 위 | ✓ VERIFIED | 복제본에 CR-01 입력(겹따옴표 여러 줄 스칼라 안 `version: 2.0.0`, 실제 `2.0.0-dev`)을 넣고 `checkShippedComposition` 을 불렀다 — 평소 `passed=false` · (h) `줄 단위 reader: 2.0.0` / `YAML: 2.0.0-dev`, `v2.0.0` 에서 (h) + (i) `-dev 꼬리가 남아 있다`. 코드 1621 ~ 1623 · 1658 ~ 1669 · 2225 ~ 2239 · 2302행 |
| 06-08 | 2 | `changelogTop` 이 `package:markdown` 의 첫 h2 (깊이 무관) 를 읽고 HTML 주석 · 펜스 안의 열 0 `## ` 줄은 제목이 아니다 | ✗ FAILED (partial) | 첫 절은 참이다. 그러나 「HTML 주석 안의 열 0 `## ` 줄은 제목이 아니다」 가 인용 · 목록 · 단락 안에서 연 `<!--` 에서 거짓이다 — 소스에서 `<!--` 와 `-->` 사이의 열 0 `## 2.0.1` 을 제목으로 읽는다 (GitHub 화면에는 h2 가 없다). 열 0 에서 연 주석(M100) · 1 ~ 3칸 들여 연 주석은 바르게 읽는다. 첫 gap 과 같은 원인 |
| 06-08 | 3 | HEAD 에서 평소 · `--tag v2.0.0` 10/10, `--tag v2.0.1` 은 `[3/10]` 만 · 블록 둘 | ✓ VERIFIED | 본 작업 폴더: rc 0 (21초) · rc 0 (19초) · rc 1 (20초, `[3/10] … 실패` · `점검 실패 (10개 중 1개)`, 블록 `… version (2.0.0) 이 다르다.` · `… CHANGELOG.md 최상단 버전 (2.0.0) 이 다르다.`) |
| 06-08 | 4 | M98 ~ M106 기록 | ✓ VERIFIED | `example/README.md` 670행 소절, M98 ~ M106 아홉 행. M98 (CR-01) 과 M104 꼴(`--` setext 대조)은 이번에 다시 실패시켰다 |
| 06-08 | 5 | 그럴듯하게 틀린 구현이 단언에 걸림 · raw `<h2>` 는 범위 밖 문장 | ✓ VERIFIED | 꼬리 뗀 판(`pub.text` → `pub.release` 한 줄)을 하네스로 불렀더니 `2.0.0-dev` + `v2.0.0` 에서 블록 0 (고친 판은 `-dev` 블록) — 단언이 구별한다. 최상위만 보는 판은 VALIDATION 감사의 실패 방향 (가). raw `<h2>` 문장은 문서 주석 1700행 · `example/README.md` 705행에 있다 (단, 「유일한 꼴」 은 첫 gap 에서 틀린다) |
| 06-08 | 6 | `markdown: ^7.3.1` dev 의존성 · 이유 주석 · publisher · lock 여섯 불변 | ✓ VERIFIED | `main` 의 `pubspec.yaml` 24행, pub.dev API `{"publisherId":"tools.dart.dev"}` (이번에 읽음), `git diff v2.0.0 origin/main -- lib example/pubspec.lock fixtures` 0줄 |
| 06-08 | 7 | `example/README.md` 의 (h) 다섯째 비교 · 70 행 · 117행 (i) 구절 | ✓ VERIFIED | 621행 `pubspecVersionText` ↔ `version` — **원문 전체**, 113행 70 행의 Markdown 해석 문구, 117행 `version 은 YAML 값 · CHANGELOG 최상단은 Markdown 해석의 첫 h2 (깊이 무관)` |
| 06-08 | 8 | skill 세 줄 · 11행 · 626행 불변 · `.claude/CLAUDE.md` 불변 | ✓ VERIFIED | 세 파일 각각 새 문장 1 · 옛 구절 0, 11행이 둘을 말함, 626행 해시가 `97848cd` 와 같음, `.claude/CLAUDE.md` 는 `97848cd..HEAD` 에서 바뀌지 않음 |
| 06-09 | 1 | `judge` 가 두 주소 각각에서 `include_file_not_found` · `included_file_warning` 줄을 사유로 더함 | ✓ VERIFIED | 하네스: 없는 include 줄 → `reasons=1`. 실제 `v1.3.0` smoke 에서 `recommended` 의 `include 사슬 끊김 1줄`. 깨진 YAML 은 이 문장 밖이다 (WR-04 — 경고) |
| 06-09 | 2 | `judge` 가 `(reasons, shown)` 을 돌려주고 `runSmoke` 는 그 값만 씀 | ✓ VERIFIED | `analyzeExitCodes.contains(` 1곳, 888 ~ 889행 `final verdict = judge(outcome);` · `reasons.addAll(verdict.reasons);` |
| 06-09 | 3 | 단계마다 시간 제한, 넘으면 끊고 69 | ✓ VERIFIED | 하네스: 자식을 둔 셸, 제한 2초 → `timedOut=true` · 2초, 두 `sleep` 남지 않음. 상수 104 · 107 · 110행, 69 경로 812 · 818 · 841행. 출력 파이프를 붙든 자손은 이 문장의 「그 프로세스」 밖이다 (WR-06 — 경고) |
| 06-09 | 4 | 정리는 `finally` 에 있어 어떤 예외로 끝나도 돌고, SIGINT 는 끊고 정리 뒤 130, `--keep` 이 아니면 경로를 찍지 않음 | ✗ FAILED (partial) | SIGINT 는 직접 확인: 실행 중 신호 → rc 130, `임시 폴더를 지웠다` · `중단됨 (SIGINT) …`, 남은 폴더 0 (5초 뒤에도 0), 화면에 경로 없음. **그러나** UTF-8 이 아닌 출력에서 rc 255 · finally 건너뜀 (하네스 재현) — 두 번째 gap |
| 06-09 | 5 | 하네스 · SIGINT · 전체 smoke `v2.0.0` 통과 | ✓ VERIFIED | SC3 의 실행 (39초 — 18분 안) |
| 06-10 | 1 | 처리 기록의 일곱 발견 fixed · `open: 0` · `total: 7` | ✓ VERIFIED (그 시점) | `75f102f` 의 파일: `disposition: fixed` 7 · `open: 0` · `total: 7` · Source 꼴 7행. 지금 파일은 재리뷰 기록(`2a01835`)으로 `open: 10` · `total: 16` 이고, 같은 ID 로 다시 보고된 WR-02 가 `open` 이다 — 기록이 재리뷰를 따른 것이고 결함이 아니다 |
| 06-10 | 2 | push gate 0 뒤 한 줄 push | ✓ VERIFIED | 원격 작업 브랜치 = `75f102f`. 범위 `ad09d6e..75f102f` 의 더해진 줄에서 경로 꼴 글자는 계획 파일 안의 gate 정규식 · 참조 줄뿐이다 (누출 아님) |
| 06-10 | 3 | 브랜치 push 실행 `success` · 로그 세 줄 | ✓ VERIFIED | run 38887002394 `success`, 로그의 `점검 통과 (10개 중 10개)` |
| 06-10 | 4 | PR 의 `pull_request` 실행 `success` | ✓ VERIFIED | run 38887576984 `success`, 로그의 평소 모드 줄 · 10/10. PR #2 는 지금 `MERGED` (06-11) |
| 06-10 | 5 | 버전 번호 · CHANGELOG · VERSIONING 불변 | ✓ VERIFIED | `main` 의 `version: 2.0.0`, CHANGELOG 1행 `## 2.0.0 - 2026-10-15`, 두 파일 `v2.0.0` 뒤 0건 |
| 06-11 | 1 | 소유자 `merge` 뒤에만 `gh pr merge --merge` | ✓ VERIFIED | 소유자 응답 10:38:32Z (orchestrator 기록) < `mergedAt` 10:40:54Z (`gh pr view`) |
| 06-11 | 2 | `origin/main` = 부모 둘인 merge commit, 첫 부모 `5ee5a12`, 고침 커밋 · 브랜치 · `v2.0.0` 이 조상 | ✓ VERIFIED | `0038572` 의 부모 `5ee5a12` · `75f102f` (`gh api` 부모 수 2), `merge-base --is-ancestor` 가 `6aa78fe` · `2c5b73b` · `4286d48` · `75f102f` · `v2.0.0` 모두 참 |
| 06-11 | 3 | `main` 의 version · markdown · CHANGELOG · tag · 브랜치 | ✓ VERIFIED | 위 06-10 #5, tag 4줄, `ls-remote --heads` 에 작업 브랜치 |
| 06-11 | 4 | `main` push 실행 `success` · 로그 두 줄 | ✓ VERIFIED | run 38888830252 `success`, `버전 일치 검사: 평소 …` · `점검 통과 (10개 중 10개)` |

**Score:** 60/63 truths verified (0 present, behavior-unverified)

### Deferred Items

없다. Phase 6 이 마지막 phase 이고, Backlog 999.1 (Phase 01 UAT Test 8) 은 두 gap 과 관계가 없다.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `tool/verify.dart` | (h) · (i) 의 해석기 reader, `changelogTop` 의 Markdown 해석 | ⚠️ VERIFIED (결함 있음) | 있고 연결되어 있으며 `main` 의 CI 에서 돌았다. pubspec 쪽은 닫혔다. `changelogTop` 이 해석기와 GitHub 화면의 갈림을 모른다 — 첫 gap |
| `tool/smoke.dart` | include 사슬 판정 · 시간 제한 · 정리 | ⚠️ VERIFIED (결함 있음) | 통과 · 실패 방향 · SIGINT 를 직접 돌렸다. UTF-8 이 아닌 출력에서 정리를 건너뛴다 — 둘째 gap |
| `pubspec.yaml` | `dev_dependencies` 의 `markdown: ^7.3.1` | ✓ VERIFIED | 주석 문장 하나가 첫 gap 에서 틀린다 |
| `example/README.md` | M98 ~ M106 소절 | ✓ VERIFIED | 두 갈림 꼴이 기록에 없다 |
| skill 세 파일 | 의존성 문장 한 줄씩 | ✓ VERIFIED | — |
| `06-REVIEW-DISPOSITION.md` | 처리 기록 | ✓ VERIFIED | 06-10 #1 참조 |
| `refs/tags/v2.0.0` · `refs/heads/main` (origin) | annotated tag · merge commit `0038572` | ✓ VERIFIED | `ls-remote` |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `checkVersionAgreement` | `pubspec.yaml` | `pubspecYamlVersion(repoRoot)` | ✓ WIRED | 2271행, CR-01 입력에서 `-dev` 블록 |
| `compareLineReadersWithYaml` (h) | `pubspec.yaml` | `pubspecVersionText ↔ version` (원문 전체) | ✓ WIRED | 2227 ~ 2238행, CR-01 입력에서 블록 |
| `checkVersionAgreement` | `CHANGELOG.md` | `changelogTop` → `package:markdown` 첫 h2 | ⚠️ WIRED (읽는 값이 GitHub 화면과 다를 수 있음) | 첫 gap 의 자리 |
| `pubspec.yaml` dev_dependencies | `tool/verify.dart` | `import 'package:markdown/markdown.dart' as md` | ✓ WIRED | 46행, Linux runner 가 workflow 변경 없이 받아 10/10 (run 38887002394 · 38888830252) |
| `runSmoke` | `judge` | `final verdict = judge(outcome)` | ✓ WIRED | 888행 |
| `runProcess` | 하위 명령 | `exitCode.timeout` → `killTree` (SIGSTOP → SIGKILL) | ✓ WIRED | 하네스 2초 · 자손 0 |
| `main` | 임시 폴더 | `finally` 의 `cleanup` · `ProcessSignal.sigint.watch()` | ⚠️ WIRED (처리되지 않은 비동기 예외는 건너뜀) | 둘째 gap |
| `gsd/v2.0-package-rework` (origin) | `main` (origin) | `gh pr merge 2 --merge` | ✓ WIRED | 부모 둘, 조상 다섯 |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| `checkVersionAgreement` | `pub` (version) | `package:yaml` 의 `version` 값 | 예 — pub 이 읽는 값과 같다 | ✓ FLOWING |
| `checkVersionAgreement` | `top` (CHANGELOG 최상단) | `package:markdown` 7.3.1 의 첫 h2 | 59 꼴 가운데 갈림 둘(한 글자 setext · 컨테이너 · 단락 안의 `<!--`)에서 GitHub 화면과 다르다 | ⚠️ 렌더와 갈림 (gap) |
| smoke `judge` | 진단 줄 | 받은 프로젝트의 `dart analyze --format=json` | 예 — 실제 분석 결과. 단 옵션 파일의 깨진 YAML 은 JSON 에 오지 않는다 (WR-04) | ✓ FLOWING (경고 하나) |

### Behavioral Spot-Checks

전체 실행은 `fvm dart run tool/verify.dart …` 이다. 복제본 실행은 모두 stderr 첫 줄에 해당 모드 줄이 있었다.

| # | 입력 | 명령 | Result | Status |
|---|------|------|--------|--------|
| — | 본 작업 폴더 HEAD | 평소 / `--tag v2.0.0` / 환경변수 `v2.0.0` / `--tag v2.0.1` | rc 0 · 0 · 0 · 1 (블록 둘) | ✓ PASS |
| a | **WR-02** — CHANGELOG 맨 앞 `2.1.0 - 미출시` / `-` / 빈 줄, pubspec `2.0.0` 그대로. GitHub 화면 첫 h2 `2.1.0 - 미출시` | 평소 / `--tag v2.0.0` / 환경변수 `v2.0.0` | **셋 다 rc 0 · 10/10** | ✗ FAIL (거짓 통과) |
| a2 | 대조 — 같은 머리, 밑줄 `--` | 평소 / `--tag v2.0.0` | rc 1 (`(2.0.0 → 2.0.0) … (2.1.0) 이 다르다`) · rc 1 (블록 둘 · 날짜 자리 `미출시`) | ✓ PASS (실패 방향) |
| a3 | **WR-02 (tag 모드)** — 맨 앞 `2.0.1 - 2026-10-20` / `-`. GitHub 화면 첫 h2 `2.0.1 - 2026-10-20` | `--tag v2.0.0` | **rc 0 · 10/10** | ✗ FAIL (거짓 통과) |
| b0 | 대조 — 상태 C (pubspec `2.0.1` · README `ref: v2.0.1` 둘 · lock 여섯), CHANGELOG 그대로 | `--tag v2.0.1` | rc 1 (`… CHANGELOG.md 최상단 버전 (2.0.0) 이 다르다.`) | ✓ PASS (실패 방향) |
| b | **WR-05** — 상태 C + 맨 앞 `> <!--` / `## 2.0.1 - 2026-10-16` / `-->` / 빈 줄. GitHub 화면 h2 0개 | `--tag v2.0.1` / 환경변수 `v2.0.1` / 평소 | **셋 다 rc 0 · 10/10** | ✗ FAIL (거짓 통과) |
| b2 | **WR-05 변형 (reviewer 표 밖)** — 상태 C + 맨 앞 `<!-- a --> x <!--` / 빈 줄 / `## 2.0.1 - 2026-10-16` / 빈 줄 / `-->`. GitHub 화면 h2 0개 | `--tag v2.0.1` | **rc 0 · 10/10** | ✗ FAIL (거짓 통과) |
| 하네스 | CR-01 입력 | `checkShippedComposition` 평소 · `v2.0.0` | 둘 다 `passed=false` ((h) · (h)+(i)) | ✓ PASS |
| 하네스 | 꼬리 뗀 틀린 판 | `checkVersionAgreement(tag: 'v2.0.0')` on `2.0.0-dev` | 고친 판 블록 1 · 틀린 판 블록 0 | ✓ PASS (구별됨) |
| — | 사용법 | `--tag` · `--bogus` · `--tag v2.0.0 extra` | 셋 다 rc 64 | ✓ PASS |
| — | smoke 통과 | `smoke.dart v2.0.0` | rc 0, 39초, 남은 폴더 0 | ✓ PASS |
| — | smoke 실패 방향 | 인자 없음 · `no-such-ref-xyz` · `v1.3.0` | rc 64 · 69 · 1 | ✓ PASS |
| — | smoke SIGINT | 실행 중 `kill -INT` | rc 130, 정리 뒤 남은 폴더 0 (5초 뒤 0), 남은 프로세스 0 | ✓ PASS |
| 하네스 | smoke 시간 제한 | `runProcess` 자식 둔 셸, 제한 2초 | `timedOut=true` · 2초 · 자손 0 | ✓ PASS |
| 하네스 | **IN-04** — UTF-8 이 아닌 출력 | `runProcess` 를 `try/finally` 안에서 | **rc 255 · finally 출력 없음** | ✗ FAIL |
| 하네스 · 측정 | **WR-04** — include 받는 파일이 깨진 YAML | 작은 프로젝트에 `dart analyze --format=json`, 그 꼴을 `judge` 에 | rc 3 · JSON 진단은 `prefer_single_quotes` 하나 (사람용 출력에만 `included_file_parse_error`) → `reasons=0` (통과) | ⚠️ 경고 (must_have 문장 밖) |
| 하네스 | **WR-06** — 출력 파이프를 붙든 자손 | `runProcess` 로 셸의 `sleep 12 & echo hi`, 제한 2초 | `timedOut=false` · 12초 기다림 | ⚠️ 경고 (must_have 문장 밖) |
| — | tool 품질 | 복제본 `dart analyze tool` · `dart format --set-exit-if-changed tool` | `No issues found!` · rc 0 | ✓ PASS |

#### 머리 조각 59개 — `package:markdown` 7.3.1 ↔ GitHub 렌더 API 의 첫 h2

모두 지금 CHANGELOG 의 `## 2.0.0 - 2026-10-15` 앞에 붙였다. 갈린 것만 적는다 — 나머지 47개 가운데 46개는 첫 h2 가 같았고 (FormatException 으로 실패 쪽에 서는 것 포함), 하나는 해석기가 죽었다 (아래).

| 꼴 | `changelogTop` | GitHub 첫 h2 | 결과 방향 |
|----|----------------|--------------|-----------|
| 한 글자 `-` setext — 맨 앞 · 인용 안 `> -` · 목록 안 `  -` (3) | `2.0.0` | 새 항목 (`2.0.1 - …`) | 거짓 통과 (평소 · 옛 버전 tag) |
| `<!--` 를 인용 안에서 열고 닫음 · 인용 안 + 빈 줄 · 인용 안 닫지 않음 (3) | `2.0.1` | 없음 | 거짓 통과 (새 tag) |
| `<!--` 를 목록 항목 · 목록 + 빈 줄 · 중첩 목록 안에서 엶 (3) | `2.0.1` | 없음 | 거짓 통과 (새 tag) |
| 단락 중간 `<!-- a --> x <!--` — 빈 줄 없음 · 있음 (2) | `2.0.1` | 없음 | 거짓 통과 (새 tag) |
| 제목 안의 인라인 주석 `## 2.0.1<!-- --> - …` (1) | `2.0.1<!-- -->` | `2.0.1 - …` | 거짓 실패 (실패 쪽 — 경고) |

같았던 꼴 (그대로 막혀 있음): 열 0 · 1칸 · 3칸 들여 연 주석 블록과 빈 줄을 품은 주석 블록, HTML 블록 종류 1 (`<pre>` · `<script>` · `<style>` · `<textarea>` — 닫음 · 닫지 않음), 종류 3 · 4 · 5 (`<?` · `<!X` · `<![CDATA[`), 종류 6 · 7 (`<div>` · 사용자 태그), 빈 주석 `<!-->` · `<!--->`, 여러 줄 link reference 제목(겹 · 홑따옴표), 참조되지 않은 각주, `<details>`, 표 뒤의 제목, 단락 안에서 연 요소 열(`<textarea>` · `<xmp>` · `<plaintext>` · `<style>` · `<script>` · `<iframe>` · `<noembed>` · `<title>` · `<noscript>` · `<select>`), 제목 · 표 칸 · 링크 글자 · 강조 안에서 연 `<!--` 뒤의 빈 줄, `===` setext, 탭 들여쓰기, 닫는 `##`, 인용 뒤 lazy `-`. 꺾쇠 URL 의 link reference(`[x]:` / `<` / …)는 `package:markdown` 이 `RangeError` 로 죽는다 (main 이 잡지 않아 255 — 실패 쪽, info).

### Probe Execution

해당 없음. `scripts/*/tests/probe-*.sh` 가 없고, 이 phase 의 계획도 probe 를 선언하지 않는다. 계획의 검증 수단인 `tool/verify.dart` · `tool/smoke.dart` 는 위에서 직접 돌렸다.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| REL-02 | 06-02 · 06-04 · 06-05 · 06-06 | 새 버전의 annotated tag 가 원격에 있어 `ref: vX.Y.Z` 로 고정할 수 있다 | ✓ SATISFIED | SC2 · SC3 (smoke 가 `ref: v2.0.0` 으로 받아 `resolved-ref` = tag 커밋) |
| REL-03 | 06-01 · 06-05 · 06-07 · 06-08 · 06-10 · 06-11 | tag · version · CHANGELOG 최상단 버전이 다르면 CI 가 실패한다 | ✗ BLOCKED (partial) | pubspec 쪽은 닫혔다. CHANGELOG 의 두 꼴(a · a3 · b · b2)에서 서로 다른데도 통과한다 — 첫 gap |
| REL-04 | 06-02 · 06-03 · 06-04 · 06-05 · 06-07 · 06-09 · 06-10 · 06-11 | 릴리스 직후 빈 프로젝트에서 새 tag 를 받아 기본 규칙 · plugin 진단 확인 | ✓ SATISFIED | SC3 (직접 실행). 둘째 gap 은 smoke 의 정리 문제라 이 요구사항의 문장을 거짓으로 만들지 않는다 |

REQUIREMENTS.md 가 Phase 6 에 매핑한 ID 는 REL-02 · REL-03 · REL-04 셋이고, 모두 하나 이상의 plan frontmatter 에 있어 ORPHANED 는 없다. **지금 REQUIREMENTS.md 는 REL-03 을 `[x]` · `Complete` 로 표시하고 있다** (06-11 의 기록 커밋 `3a51efa`). 이번 판정으로는 REL-03 이 아직 닫히지 않았으므로 orchestrator 가 `[ ]` · `Pending` 으로 되돌려야 한다. REL-02 는 `[ ]` · `Pending` 이지만 SATISFIED 다.

### Prohibitions (판정 등급 37건 — LLM 판정, 비권위)

06-01 ~ 06-07 의 25건은 지난 회차 표와 같은 판정이다 (그 뒤로 해당 파일 · 원격이 바뀌지 않았다). gap 수정 plan 의 12건:

| Plan | 항목 | 판정 | 근거 |
|------|------|------|------|
| 06-08 | fail-closed 허용 목록으로 만들지 않음 · 제목 글자 규칙 그대로 | 지켜짐 | `changelogTop` 에 허용 목록이 없고 ` - ` 한 번 · 앞 토큰 · `YYYY-MM-DD` 가 그대로다 (1723 ~ 1731 · 2317행) |
| 06-08 | `markdown` 을 `dependencies` 에 두지 않음 · 다른 줄 · 다른 파일 그대로 | 지켜짐 | `6aa78fe` 는 pubspec · verify · skill 셋, `c6187cd` 는 `example/README.md` 만. `v2.0.0..origin/main` 의 pubspec diff 는 3줄 더함뿐 |
| 06-08 | skill 의 그 한 줄 밖 · 626행 · `.claude/CLAUDE.md` 그대로 | 지켜짐 | skill diff 3+/3-, 626행 해시 같음, CLAUDE.md 불변 |
| 06-08 | 복제본에서만 · 기록에 경로 없음 · M1 ~ M97 그대로 | 지켜진 것으로 보임 (과정은 판정 불가) | 두 커밋의 더해진 줄에 경로 꼴 0 |
| 06-09 | `tool/smoke.dart` 밖 불변 · verify · CI 에 넣지 않음 · 새 의존성 없음 | 지켜짐 | 두 커밋이 `tool/smoke.dart` 만, import 둘 |
| 06-09 | 판정 (2) · (3) · 배타 순서 그대로 · include 코드 둘로 좁힘 | 지켜짐 | 673 ~ 706행의 순서 (a) → (b) → (c′) → (c), 97행의 코드 둘 |
| 06-09 | 전체 smoke 는 한 번 · 저장소 안에 파일 없음 · 기록에 경로 없음 | 지켜진 것으로 보임 (과정은 판정 불가) | 두 커밋의 더해진 줄에 경로 꼴 0 |
| 06-10 | `main` · tag · force push 없음 · 한 줄 push · PR 은 열기만 | 지켜짐 | 원격 작업 브랜치 = `75f102f` (fast-forward 기록), 병합은 06-11 에서 소유자 응답 뒤 |
| 06-10 | 처리 기록의 제목 · `recorded:` · 형식 설명 그대로 · 저장소 파일 불변 | 지켜짐 | `75f102f` 는 처리 기록 한 파일 |
| 06-10 | PR 본문 · 커밋 · SUMMARY 에 경로 없음 | 지켜짐 | PR #2 본문 · 병합 메시지에 경로 꼴 0 |
| 06-11 | `merge` 전에 병합 안 함 · merge commit 만 · 되감지 않음 · tag · 버전 · CHANGELOG 불변 | 지켜짐 | 시각 순서, 부모 둘, 작업 브랜치 남음, tag 4줄, version · CHANGELOG 불변 |
| 06-11 | 저장소 파일 불변 · `hold` 처리 · 메시지에 비공개 정보 없음 | 지켜짐 | `3a51efa` 는 `.planning/` 만, 병합 메시지에 경로 꼴 0 |

### Code Review 발견의 판정 (06-REVIEW.md — 등급을 물려받지 않고 다시 갈랐다)

잣대는 "명시된 진실(성공 기준 · must_haves)이 거짓이 되는 입력인가" 이다.

| ID | 주장 | 이번 확인 | 판정 |
|----|------|-----------|------|
| WR-02 | 한 글자 `-` setext 를 해석기가 h2 로 보지 않아 평소 모드가 옛 항목과 견주어 통과 | **재현 (전체 실행)**: a 의 평소 · `--tag v2.0.0` · 환경변수 rc 0, a3 의 `--tag v2.0.0` rc 0 (GitHub 첫 h2 `2.0.1`). 인용 · 목록 안 변형도 함수 단위로 같다 | **gap** — 성공 기준 1 · REL-03 의 「서로 다르면 실패」 가 거짓이다. reviewer 의 「새 tag 의 gate 는 뚫리지 않는다」 는 맞지만, 옛 버전 tag (a3) 와 평소 push (a — D-04 (1)) 가 뚫린다 |
| WR-05 | 인용 · 목록 · 단락 안에서 연 `<!--` 뒤의 `## ` 를 최상단으로 읽어 tag 모드 통과 | **재현 (전체 실행)**: b 의 `--tag v2.0.1` · 환경변수 · 평소 rc 0, 대조 b0 rc 1. reviewer 표 밖의 변형 다섯(인용 + 빈 줄, 인용 닫지 않음, 목록 + 빈 줄, 중첩 목록, 단락 + 빈 줄)도 함수 단위로 같고, 단락 + 빈 줄(b2)은 전체 실행 rc 0 | **gap** — 지난 회차 cA2 (열 0 주석) 와 같은 꼴이다. 받는 쪽 규칙에 영향이 없다는 점은 cA2 도 같았다. 06-08 must_have 2 도 거짓이 된다 |
| WR-04 | 깨진 include YAML 이 JSON 진단 없이 exit 3 → smoke 통과 | **재현**: 측정 rc 3 · JSON 에 error 없음, `judge` `reasons=0` | 경고 — 06-09 must_have 1 은 코드 둘로 좁혀 적혀 있고, SC3 · REL-04 는 두 진단이 나오는지만 요구한다. 같은 커밋의 `verify.dart` `[2/10]` 가 저장소 안의 깨진 조각을 잡는다 |
| WR-06 | 출력 파이프를 붙든 자손이 있으면 제한을 넘겨 기다림 | **재현**: 제한 2초, 12초 기다림 | 경고 — must_have 3 의 「넘으면 그 프로세스를 끊고」 의 그 프로세스는 제한 안에 끝났다. 다만 WR-03 과 같은 결과(끝없는 기다림)가 이 경로에 남는다. 지금 세 명령에서 그런 자손을 본 실측은 없다 |
| IN-04 | UTF-8 이 아닌 출력 → 255, finally 건너뜀 | **재현**: rc 255, finally 출력 없음 | **gap** — 06-09 must_have 4 의 「어떤 예외로 끝나도 돈다」 가 거짓이다. phase 목표에는 영향이 없고 한 줄로 고칠 수 있다 |
| IN-05 | SIGINT 처리기의 경합 창 둘 | 읽기로만 판정 (`runningChild` 는 `Process.start` 뒤에 정해짐, finally 가 처리기를 먼저 내림 — 코드 그대로). SIGINT 실행 한 번은 정상이었다 | info |
| IN-06 | `killTree` 가 자손을 놓쳐도 알리지 않음 | 읽기로만 판정 | info |
| IN-07 | `main` 의 예외 안내가 SDK 경로 · 홈을 가리지 않음 | 읽기로만 판정 (990 · 994행의 가림 표가 임시 폴더 · 저장소 둘뿐) | info — 임시 폴더 경로는 가린다 (06-03 must_have 5 는 지켜짐) |
| IN-08 | `markdown` · `yaml` 판이 고정되지 않음 | 읽기로만 판정 (`^7.3.1` · `^3.1.4`, 루트 lock 은 커밋하지 않음). CI 가 받은 판은 로그에 없다 | info — 첫 gap 의 판정이 해석기 판에 기대므로, 길 (가) 를 고르면 판 고정도 같이 정할 일이다 |
| IN-09 | 의존성 문장이 「`package:yaml` 은 YAML 대조에만」 | 읽기로 확인 (`pubspec.yaml` 19행 주석 · skill 세 줄) — (i) 는 YAML 값을 직접 쓴다 | info |
| (새) | 꺾쇠 URL link reference 에서 `package:markdown` 이 `RangeError` | 함수 단위 재현 | info — 실패 쪽(255)이지만 70 이 아니고 stack trace 가 남는다 |
| (새) | 제목 안의 인라인 주석에서 거짓 실패 | 함수 단위 재현 | info — 실패 쪽 |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `tool/verify.dart` | 1709 ~ 1732 | 해석기 하나의 첫 h2 를 「GitHub 화면과 같다」 고 믿음 — 갈림을 알아채는 장치 없음 | 🛑 Blocker | REL-03 거짓 통과 (첫 gap — 지난 gap 이 이어진 것) |
| `tool/verify.dart` · `pubspec.yaml` · `example/README.md` | 1686 ~ 1702 · 21 · 705 | 사실과 다른 문서 문장 (「같다」 · 「유일한 꼴」) | ⚠️ Warning | 첫 gap 과 함께 고친다 |
| `tool/smoke.dart` | 419 ~ 420 | 엄격한 디코딩의 오류가 처리되지 않은 비동기 예외가 됨 | 🛑 Blocker | 06-09 must_have 4 거짓 (둘째 gap — 바뀐 파일이고 하네스 재현이 있다) |
| `tool/smoke.dart` | 97 · 677 | 종료 코드 3 인데 JSON 에 error 가 없는 경우를 보지 않음 | ⚠️ Warning | WR-04 |
| `tool/smoke.dart` | 421 ~ 430 | 제한이 종료에만 걸리고 출력 수집에는 없음 | ⚠️ Warning | WR-06 |
| `example/README.md` | (06-01 소절) | `TBD` 2건 | ℹ️ Info | 실험 입력 값을 적은 문장이다 — debt marker 아님 (지난 회차와 같음) |

이번 회차의 blocker 둘은 둘 다 증거 gate 를 넘는다. 첫째는 지난 gap 이 이어진 것이고, 둘째는 지난 `verified:` 뒤로 바뀐 파일(`tool/smoke.dart`)이며 하네스 재현이 있다. advisory 로 내린 항목은 없다.

### Human Verification Required

이번 gap 수정 plan(06-08 ~ 06-11)에는 `<human-check>` 가 없고, 새 사람 확인 항목은 생기지 않았다. 지난 회차의 둘이 아직 열려 있다.

### 1. Actions 의 `Run workflow` 버튼

**Test:** GitHub 의 Actions → `verify` 화면을 연다.
**Expected:** `Run workflow` 버튼이 보인다 (실행 자체는 run 38850984674 가 `success`).
**Why human:** 웹 화면의 버튼 표시는 CLI 로 볼 수 없다.

### 2. 판정 등급 prohibition 37건

**Test:** 위 「Prohibitions」 표와 지난 회차 표를 훑는다.
**Expected:** 판정에 동의하거나, 다르게 보는 항목을 적는다.
**Why human:** 시행 증거(test)가 없는 judgment 등급이라 자동 판정은 권위가 없다.

덧붙여 알아 둘 것: 두 갈림 꼴의 기준값은 GitHub 렌더 API 다 (소유자 결정 G6-Q1 과 06-REVIEW 와 같은 기준). 저장소 파일 화면 자체는 원격에 올려야 볼 수 있어 확인하지 않았다.

### Gaps Summary

**v2.0.0 과 `main` 에 관해 사실인 것.** 원격 annotated tag `v2.0.0` (→ `704bf56`) 과 그 커밋의 version · CHANGELOG 는 그대로이고, 고친 smoke 가 `ref: v2.0.0` 으로 받아 두 주소 모두에서 규칙 · plugin 진단을 냈다. gap 수정은 merge commit `0038572` 로 `main` 에 들어갔고, `main` 의 CI 가 고친 검사로 10/10 을 냈다. 받는 쪽 규칙 · 버전은 바뀌지 않았다. 목표 문장 자체("annotated tag 로 원격에 있어 고정할 수 있고 … 적용됨이 확인되어 있다")는 이루어졌다. 남은 것은 성공 기준 1 이 말하는 **다음 릴리스의 gate** 와 smoke 의 정리 한 경로다.

**첫 gap — CHANGELOG 최상단 reader (REL-03 · SC1, 06-08 must_have 2).** 06-08 은 줄 찾기를 Markdown 해석기로 바꿔, 지난 회차의 꼴 아홉을 닫았다. 그러나 "해석기 = GitHub 화면" 이라는 전제가 두 꼴에서 틀린다.
- 한 글자 `-` 밑줄 setext — 해석기는 제목이 아니라고 보고 GitHub 은 h2 로 그린다. 평소 push 와 옛 버전 tag 가 뚫린다.
- 인용 · 목록 · 단락 안에서 연 `<!--` — 해석기는 그 뒤의 `## X.Y.Z` 를 h2 로 보고, GitHub 은 그 자리부터 끝까지를 주석으로 삼킨다. 새 tag 가 뚫린다.

이 저장소가 여러 번 겪은 일과 같은 모양이다. 고친 입력은 막혔고, 같은 꼴의 다른 입력이 뚫린다. 그래서 다음 gap 계획 전에 소유자가 고를 길을 둘로 나눠 적는다.

- **(가) 꼴을 하나씩 막는 수정 — G6-Q1 (가) 를 그대로 잇는 길.** 06-REVIEW.md 의 Fix 둘이다. 첫째, 한 글자 밑줄 줄을 `--` 로 넓힌 사본을 다시 해석해, 첫 h2 가 다르면 실패시킨다. 둘째, 첫 h2 앞의 글자(raw HTML 포함)에 닫히지 않은 `<!--` 가 남으면 실패시킨다.
  - 장점: 지금 구조와 문장을 유지한다.
  - 단점: 59개 꼴 밖의 다음 갈림은 다시 찾아야 막힌다. 해석기 판이 바뀌면 갈림도 바뀐다 (IN-08 — 판 고정을 함께 정해야 한다). reviewer 의 두 Fix 가 이번에 찾은 변형 다섯(빈 줄 · 닫지 않음 · 중첩)까지 덮는지는 고칠 때 단언으로 확인해야 한다.
- **(나) 구조를 바꾸는 길 — 최상단 제목을 파일 첫 줄로 고정.** `CHANGELOG.md` 의 첫 줄(U+FEFF 뗀 뒤)이 엄격한 `## X.Y.Z - …` 꼴이 아니면 실패시킨다. 해석기의 첫 h2 와 그 줄이 같아야 통과한다 (05 의 길 B 처럼 두 reader 의 일치).
  - 왜 꼴 전체를 닫는가: 첫 줄 앞에는 아무 블록도 없다. ATX 제목은 한 줄 블록이라 뒤의 줄이 그것을 바꿀 수 없다. 그래서 어떤 CommonMark 렌더러(GitHub 포함)도 그 줄을 h2 로 그린다. 위의 갈림 꼴은 모두 첫 줄이 `## ` 가 아니므로 실패한다. 해석기 판이 바뀌어도 판정이 그대로다.
  - 지금 CHANGELOG 와 v2.0.0 은 1행이 이미 그 꼴이라 통과한다.
  - 정해야 할 것: `# Changelog` 같은 머리말을 허용할지다. 허용하면 앞 블록이 다시 생긴다. VERSIONING.md 「CHANGELOG 항목 형식」 에 "최상단 항목이 파일 첫 줄" 을 적을지도 정해야 한다.
  - 지난 소유자 결정의 NOT 인 "(나) fail-closed 허용 목록" 과 닮았지만 다르다. 금지 글자 목록이 아니라 양성 규칙 하나다. 그래도 소유자 결정이 필요하다.
- (참고) GitHub 렌더 API 를 기준으로 쓰는 길도 있다. 화면과 같음이 보장되지만, 오프라인 검증 명령이 네트워크와 토큰 · 속도 제한에 기대게 된다.

어느 길이든 실패 방향은 꼴 단위로 기록 · 단언한다 (frontmatter `missing`). 고침은 저장소 안쪽만 바꾸므로 새 버전 번호는 필요 없다. 다음 릴리스 전에 닫는다.

**둘째 gap — smoke 의 정리 한 경로 (06-09 must_have 4).** UTF-8 이 아닌 출력이 처리되지 않은 비동기 예외(255)가 되어 finally 의 정리를 건너뛴다. 고침은 한 줄이다 (`allowMalformed: true` 또는 오류 처리). phase 목표 · REL-04 에는 영향이 없다. 고치지 않기로 하면 아래 override 를 달면 된다.

```yaml
overrides:
  - must_have: "06-09 must_have 4 — 임시 폴더 정리는 finally 에 있어 어떤 예외로 끝나도 돈다"
    reason: "동기 흐름의 예외와 SIGINT 에서는 정리가 돈다. 하위 명령이 UTF-8 이 아닌 바이트를 내는 경로(처리되지 않은 비동기 예외)는 세 명령에서 일어나지 않는 것으로 보고 받아들인다"
    accepted_by: "{소유자}"
    accepted_at: "{ISO 시각}"
```

**경고(WR-04 · WR-06)는 gap 이 아니다.** 둘 다 must_have 문장 밖이다. 같은 gap 계획에서 함께 고칠지는 소유자가 정한다. WR-06 은 WR-03 과 같은 결과(끝없는 기다림)가 남는 자리이므로, 둘째 gap 을 고칠 때 `runProcess` 의 제한을 출력 수집까지 넓히는 것을 함께 권한다.

---

_Verified: 2026-10-16T11:47:02Z_
_Verifier: Claude (gsd-verifier)_
