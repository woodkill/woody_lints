---
phase: 06-release
verified: 2026-10-16T18:05:06Z
status: human_needed
score: 82/82 must-haves verified
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
  - .planning/phases/06-release/06-12-PLAN.md
  - .planning/phases/06-release/06-12-SUMMARY.md
  - .planning/phases/06-release/06-13-PLAN.md
  - .planning/phases/06-release/06-13-SUMMARY.md
  - .planning/phases/06-release/06-14-PLAN.md
  - .planning/phases/06-release/06-14-SUMMARY.md
  - .planning/phases/06-release/06-15-PLAN.md
  - .planning/phases/06-release/06-15-SUMMARY.md
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
covered_digest: "v3:sha256:e8082d391305c5d4c7d0dd4bc6dece1b073d60d0062a8d4654becefa56166888"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 60/63
  gaps_closed:
    - "ROADMAP 성공 기준 1 · REL-03 (함께: 06-08 must_have 2) — CHANGELOG 최상단 reader 가 GitHub 화면과 갈리던 두 꼴(한 글자 `-` setext · 인용 · 목록 · 단락 안에서 연 `<!--`): 06-12 의 첫 줄 규칙 아래에서 지난 회차의 재현 a · a3 · b · b2 가 세 경로(평소 · `--tag` · `GITHUB_REF_NAME`) 모두 rc 1 · `[3/10]` 블록 (직접 재현, 고치기 전 판은 같은 입력에서 rc 0)"
    - "06-09 must_have 4 — UTF-8 이 아닌 하위 명령 출력: `runProcess` 를 `try/finally` 안에서 부르면 finally 가 돌고 U+FFFD 로 받는다 (하네스 직접 재현, 고치기 전 판은 rc 255 · finally 없음)"
  gaps_remaining: []
  regressions: []
human_verification:
  - test: "GitHub 의 Actions → `verify` 화면을 열어 `Run workflow` 버튼이 보이는지 본다 (02-UAT 6번 · D-03 (6) — 06-06 Task 3 의 `<human-check>`, 첫 회차부터 열려 있음)"
    expected: "기본 브랜치 `main` 에 `.github/workflows/verify.yml` 이 있으므로 버튼이 보인다 (실행 자체는 `workflow_dispatch` run 38850984674 가 `success`)"
    why_human: "GitHub 웹 화면의 버튼 표시는 CLI 로 볼 수 없다"
  - test: "판정 등급 prohibition 49건(06-01 ~ 06-07 의 25건 + 06-08 ~ 06-11 의 12건 + gap 수정 2회차 06-12 ~ 06-15 의 12건, PLAN frontmatter 의 `MUST NOT`)의 LLM 판정(아래 「Prohibitions」 표와 지난 회차 표 — 비권위)을 사람이 훑어본다"
    expected: "표의 판정에 동의하거나, 다르게 보는 항목을 적는다"
    why_human: "judgment 등급 prohibition 은 시행 증거(test)가 없어 자동 판정이 권위를 갖지 않는다 (ADR-550 D4)"
---

# Phase 6: Release Verification Report

**Phase Goal:** 새 버전이 annotated tag 로 원격에 있어 사용 프로젝트가 `ref: vX.Y.Z` 로 버전을 고정할 수 있고, 그 tag 를 git 의존성으로 받은 프로젝트에서 규칙과 plugin 이 실제로 적용됨이 확인되어 있다
**Verified:** 2026-10-16T18:05:06Z
**Status:** human_needed
**Re-verification:** Yes — gap 수정 2회차 06-12 ~ 06-15 뒤 (지난 회차 gaps_found 60/63)

지난 회차의 gap 둘이 모두 닫혔다. CHANGELOG 쪽은 06-12 의 첫 줄 규칙이 꼴을 하나씩 막는 대신 구조로 닫았고, 지난 재현 여섯과 같은 꼴의 입력 63개(HEAD 포함)를 다시 넣어 거짓 통과가 하나도 없음을 확인했다. smoke 쪽은 UTF-8 이 아닌 출력에서 finally 가 돈다. 원격의 `v2.0.0` · `main` (`3418989`) · CI 실행 셋은 그대로이고, 고친 smoke 로 `ref: v2.0.0` 을 다시 받아 두 주소 모두에서 규칙 · plugin 진단이 나왔다. 남은 것은 사람 확인 둘(지난 회차와 같은 항목, prohibition 건수만 늘어남)과 must_have 밖의 경고 넷이다.

## 확인 방법

- 원격 · CI 는 본 작업 폴더에서 읽기 전용 명령만 썼다 — `git fetch` · `git ls-remote` · `git show origin/main:…` · `git merge-base --is-ancestor` · `gh run view` (`--log` 포함) · `gh pr view` · `gh api` (커밋 부모).
- 깨뜨리는 변경과 하네스는 모두 scratchpad 아래 `mktemp -d` 로 만든 폴더 하나 안에서 했다. 그 안에 `git clone --local` 복제본 셋을 두고, 각각 `rev-parse --show-toplevel` 이 복제본인지 본 뒤 루트 `fvm dart pub get --no-example` 을 먼저 돌렸다. 상태 C(새 릴리스 상태)는 VERSIONING 「릴리스 절차」 2번대로 lock 여섯을 `fvm dart pub get` 으로만 다시 받았다 (numstat: pubspec 1 · README 2 · lock 여섯 각 1).
- 함수 단위 하네스는 복제본 밖(같은 폴더)의 Dart 파일이 복제본의 `tool/verify.dart` 또는 HEAD · 고치기 전 커밋에서 꺼낸 `tool/smoke.dart` 사본을 import 해 `changelogTopOf` · `runProcess` · `judge` · `killTree` · `scrubNamesFor` · `awaitRunningChild` 를 직접 불렀다.
- 네트워크를 쓴 실행은 `tool/smoke.dart v2.0.0` 한 번(41초)과 SIGINT 실행 한 번(받기 단계에서 끊음)뿐이다. smoke 의 임시 폴더는 `TMPDIR` 로 이 검증의 폴더 안에 두었다. GitHub 렌더 API 는 쓰지 않았다 — 첫 줄 규칙 아래에서는 기준값이 필요 없다 (아래 「첫 줄 규칙이 꼴 전체를 닫는가」).
- SDK 는 Flutter 3.47.5 / Dart 3.13.4, 루트 lock 의 `markdown` 은 7.3.1 이다.
- 본 작업 폴더의 `git status --porcelain` 은 시작과 끝 모두 orchestrator 상태 파일 넷뿐이다. 끝에 검증 폴더를 통째로 지웠다.

## Goal Achievement

### Observable Truths — ROADMAP 성공 기준

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| SC1 | tag 이름 · `pubspec.yaml` version · CHANGELOG 최상단 버전이 서로 다르면 실패하는 검사가 CI 의 tag 트리거에 걸려 있고, 일부러 어긋나게 만든 입력에서 실제로 실패함이 확인되어 있다 | ✓ VERIFIED | 걸려 있음: `main` 의 `verify.yml` 은 `v2.0.0` 뒤로 바뀌지 않은 필터 없는 `push:` 이고, `main` push 실행 38936761858 (`3418989`) 이 첫 줄 규칙의 검사로 10/10. 어긋난 입력: 복제본 전체 실행에서 `--tag v2.0.1` (블록 둘), b0, 지난 회차의 거짓 통과 a · a3 · b · b2 가 세 경로 모두 rc 1 · `[3/10]` 만 실패. 올바른 새 릴리스 상태(C-good)는 세 경로 rc 0 — 거짓 실패 없음 (아래 spot-check) |
| SC2 | `git ls-remote --tags origin` 에 새 버전의 annotated tag 가 보이고, 그 tag 의 `pubspec.yaml` version 과 CHANGELOG 최상단 버전이 tag 이름과 같다 | ✓ VERIFIED (회귀 확인) | `753f520…  refs/tags/v2.0.0` · `704bf56…  refs/tags/v2.0.0^{}`, `cat-file -t` = `tag`. tag 는 `v1.3.0` · `v2.0.0` 네 줄뿐이다. `git show v2.0.0:pubspec.yaml` 의 `version: 2.0.0`, CHANGELOG 1행 `## 2.0.0 - 2026-10-15` — 첫 줄 규칙도 그대로 통과한다 (HEAD 의 세 모드 rc 0) |
| SC3 | 빈 프로젝트가 새 tag 를 git 의존성(`ref: vX.Y.Z`)으로 받아 `dart analyze` 를 돌리면 기본 규칙 진단과 `riverpod_lint` plugin 진단이 둘 다 보고된다 | ✓ VERIFIED | 06-13 이 고친 smoke 로 직접 돌림 — `fvm dart run tool/smoke.dart v2.0.0` rc 0 (41초). lock `source git` · README 의 url · `resolved-ref 704bf56…`. 두 주소 각각 `info prefer_single_quotes` · `warning provider_parameters` · `riverpod_lint 3.1.9`, 종료 코드 2, 판정 줄에 include 사슬 · 종료 코드 3 꼬리 없음, stderr 빈 출력, `임시 폴더를 지웠다`, 남은 임시 폴더 0 |

### Observable Truths — PLAN must_haves

06-01 ~ 06-11 (60건) 가운데 지난 회차의 실패 둘(06-08 #2 · 06-09 #4)은 다시 전부 확인했고, 나머지는 회귀만 봤다. `lib/` · README · CHANGELOG · `.github/` 는 `v2.0.0` 뒤로 바뀌지 않았다 (`git log v2.0.0..origin/main -- …` 0건). 받는 쪽에 가는 파일과 lock 여섯도 `v2.0.0` 과 diff 0 이다.

| Plan | # | Truth (요약) | Status | 이번 확인 |
|------|---|--------------|--------|-----------|
| 06-01 | 1 ~ 8 | 버전 일치 확인 (i) · 모드 · 사용법 · 기록 | ✓ VERIFIED | HEAD 의 평소 · `--tag v2.0.0` · 환경변수 `v2.0.0` rc 0 과 모드 줄, `--tag v2.0.1` rc 1. M95 (`미출시`) · M96 (`release-2.0.0`) 꼴은 문자열 하네스 · 06-12 기록 그대로 |
| 06-02 ~ 06-07 | 전부 | README · VERSIONING 문장, smoke 흐름, 릴리스 커밋 · tag · PR #1 · 처리 기록 | ✓ VERIFIED (회귀) | 원격 사실 그대로, README 는 `v2.0.0` 뒤 0건, VERSIONING 은 06-12 의 한 줄만 더해졌다 |
| 06-08 | 1 | (i) 는 YAML 의 version, (h) 는 원문 전체 ↔ YAML | ✓ VERIFIED (회귀) | 06-12 는 `pubspecYamlVersion` · (h) 를 바꾸지 않았다. 상태 C 의 `--tag v2.0.1` 통과 · HEAD 의 `--tag v2.0.1` 의 pubspec 블록이 같은 길이다 |
| 06-08 | 2 | `changelogTop` 이 Markdown 첫 h2 를 읽고, HTML 주석 · 펜스 안의 열 0 `## ` 줄은 제목이 아니다 | ✓ VERIFIED | 첫 절은 06-12 #1 이 대신한다 (첫 줄 + 첫 h2 일치). 「주석 · 펜스 안의 `## ` 줄은 제목이 아니다」 는 이제 모든 꼴에서 참이다 — 인용 · 목록 · 중첩 목록 · 단락 안에서 연 `<!--` (닫음 · 닫지 않음 · 빈 줄) · 열 0 주석 · 펜스(백틱 셋) 모두 첫 줄 블록으로 실패한다 (문자열 하네스 · 전체 실행 b · b2) |
| 06-08 | 3 ~ 8 | HEAD 실행 · M98 ~ M106 · 틀린 판 · 의존성 · 문장 · skill | ✓ VERIFIED (회귀) | 의존성 `^7.3.1` · lock 여섯 불변, skill 세 줄은 06-12 가 한 줄씩 고쳤다 (06-12 #3) |
| 06-09 | 1 · 2 · 3 · 5 | include 사유 · `(reasons, shown)` · 단계 제한 · 하네스 | ✓ VERIFIED | 하네스: include 코드 셋째 `included_file_parse_error` 도 사유 1 (06-13 이 넓힘). 제한: `sleep` 혼자 · 파이프를 붙든 자손 모두 2초 `timedOut=true`. 전체 smoke 통과 (SC3) |
| 06-09 | 4 | 정리는 `finally` 에 있어 어떤 예외로 끝나도 돌고, SIGINT 는 끊고 정리 뒤 130, `--keep` 이 아니면 경로를 찍지 않음 | ✓ VERIFIED | **지난 gap 닫힘.** 하네스: `printf "\377\n"` (stdout) · `printf "\376x"` (stderr) 를 내는 셸을 `try/finally` 안에서 → `exit=0` · 두 스트림 U+FFFD · `finally=ran`. 고치기 전 판(`9d96778` 의 부모)은 같은 하네스에서 rc 255 · `Unhandled exception: FormatException` · finally 없음. 같은 꼴의 다른 reader 인 `Process.run` (기대 커밋의 git) 은 엄격한 디코딩이지만 오류가 await 한 future 로 와서 `main` 의 `on FormatException` (70) 으로 가고 finally 가 돈다 (하네스). SIGINT: 받기 단계에서 신호 → rc 130, `임시 폴더를 지웠다` · `중단됨 (SIGINT) …`, 5초 뒤 남은 폴더 0 · 남은 프로세스 0, 출력에 임시 폴더 경로 0 |
| 06-10 · 06-11 | 전부 | 처리 기록 1회차 · PR #2 · merge `0038572` | ✓ VERIFIED (회귀) | `0038572` 가 `3418989` 의 첫 부모, 실행 셋 그대로 |

gap 수정 2회차 plan 의 must_haves (19건):

| Plan | # | Truth (요약) | Status | Evidence |
|------|---|--------------|--------|----------|
| 06-12 | 1 | U+FEFF 를 뗀 **첫 줄**이 `^## (\d+\.\d+\.\d+) - (\S.*?)[ \t]*$` 이고 Markdown 첫 h2 가 같을 때만 통과, 아니면 70 이 아닌 `[3/10]` 블록, 제목 글자 규칙 그대로 | ✓ VERIFIED | 코드 `tool/verify.dart` 1693 · 1725 ~ 1760 · 2302 ~ 2311행. 문자열 하네스 63 입력 (HEAD 포함): 머리말 · 앞 빈 줄 · 한 글자 setext (맨 앞 · 뒤 공백 · 탭 · 인용 · 목록) · 블록 안의 `<!--` · 장식 · raw `<h2>` · `v` 접두 · 빈 문자열 · 빈 날짜 자리는 문구 A, 닫는 `##` · 닫는 `#` · 백슬래시 escape · 엔티티 · 강조 · 코드 날짜는 문구 B. 전체 실행은 모두 rc 1 · `점검 실패 (10개 중 1개)` (70 아님). `미출시` · 뒤 공백 · ` - ` 두 번은 통과 |
| 06-12 | 2 | HEAD 세 모드 10/10, `--tag v2.0.1` 은 `[3/10]` 만 · 블록 둘; 문자열 하네스의 통과 · 거부 | ✓ VERIFIED | 복제본 HEAD: 평소 · `--tag v2.0.0` · 환경변수 rc 0 · 10/10, `--tag v2.0.1` rc 1 · `점검 실패 (10개 중 1개)` · `… version (2.0.0) 이 다르다.` · `… CHANGELOG.md 최상단 버전 (2.0.0) 이 다르다.` 둘. 하네스: BOM · CRLF · CR 하나 · 뒤 공백 · 탭 · `미출시` · ` - ` 두 번 통과, BOM 두 개 · 앞 빈 줄 · `v` 접두 · 빈 문자열 · 빈 날짜 거부 |
| 06-12 | 3 | 거짓이 된 문장 고침 — 네 구절이 저장소에 남지 않음, 다섯 자리가 `package:yaml` 을 대조와 version 읽기에, VERSIONING 한 줄 | ✓ VERIFIED | `git grep` (`.planning/` 밖) 으로 「GitHub 화면과 같」 「유일한 꼴」 「YAML 대조에만」 「견줄 때만」 「GitHub 화면이 그리는」 0건. skill 세 줄에 새 문장 각 1, `pubspec.yaml` 19행 · `tool/verify.dart` 34 ~ 37행이 같은 뜻. `VERSIONING.md` 83행 「최상단 항목의 제목은 **파일의 첫 줄**이다」. 단, 이 문장 목록 밖의 `example/README.md` (06-08) 읽는 법 (4) · (5) 가 낡았다 — IN-10 (경고) |
| 06-12 | 4 | M107 ~ M115 기록 · M100 ~ M106 재측정 · 고치기 전 판 대조 | ✓ VERIFIED | `example/README.md` 722 ~ 730행 아홉 행. 이번에 M107 · M108 · M110 · M112 · M113 · M114 · M115 와 같은 입력을 전체 실행으로 다시 실패시켰고, 고치기 전 판(`85e1b0d` 의 부모)으로 a (M107 꼴) 평소 · b (M110 꼴) `--tag v2.0.1` 이 rc 0 · 10/10 인 것을 같은 복제본에서 다시 봤다 |
| 06-12 | 5 | 그럴듯하게 틀린 구현이 단언에 걸림 | ✓ VERIFIED | 06-08 판(고치기 전)은 위의 a · b 에서 통과 — M107 ~ M114 단언에 걸린다. 첫 줄만 보는 판은 M115 (`첫 h2 가 다르다` 블록 — 전체 실행으로 확인) 에 걸린다. BOM · CRLF · 앞 빈 줄 · `## v…` 의 하네스 결과가 각 틀린 판과 갈린다. VALIDATION 감사의 실패 방향 (가) (`h2 != body` → `h2 == null`) 도 같은 자리에서 걸렸다 |
| 06-13 | 1 | `allowMalformed` decoder — 255 가 finally 를 건너뛰는 경로 없음, 머리 주석 255 문장 | ✓ VERIFIED | 06-09 #4 의 하네스. 코드 525 ~ 527행, 머리 주석 52 ~ 53행 |
| 06-13 | 2 | 제한이 종료 코드와 출력 수집 전체(`Future.wait`)에 걸림 | ✓ VERIFIED | 하네스: `sleep N & echo hi`, 제한 2초 → `timedOut=true` · 2초 (고아는 하네스가 `pkill` 로 정리, 0건 확인) |
| 06-13 | 3 | `judge` 의 (a) → (b) → (c′) 코드 셋 → (c″) → (c), (c″) 의 `shown` 꼬리 | ✓ VERIFIED | 하네스: 종료 코드 3 · error 줄 없음 → 사유 1, `included_file_parse_error` → 사유 1 · `include 사슬 끊김 1줄`, include 줄 + 종료 코드 3 → 사유 둘이 (c′) · (c″) 순서, `shown` 꼬리 ` · 종료 코드 3 인데 error 없음`. 다른 error 줄이 있으면 (c″) 는 서지 않는다 — 문장이 「error 줄이 하나도 없으면」 이므로 설계 그대로 (경고로 따로 적음) |
| 06-13 | 4 | `pendingSpawn` · `awaitRunningChild` · finally 순서 · `killTree` 의 안내 · 재확인 · SIGCONT · 범위 문장 · `scrubNamesFor` | ✓ VERIFIED | 하네스: 표 읽기 null → stderr `자손 프로세스를 찾지 못했다 — 부모만 끊었다` · 부모 exit -9, `scrubNamesFor` 키 넷 (`<임시 폴더>` · `<Flutter SDK>` · `<repo>` · `<홈>`) · 최소 둘, 띄운 것이 없을 때 `awaitRunningChild` null. finally 는 `cleanup();` 이 `interrupts.cancel()` 앞 (1139 ~ 1140행). 재확인 · SIGCONT 는 문장 그대로 동작한다 — 그 동작이 자기 자손을 살려 두는 꼴은 IN-11 (경고) |
| 06-13 | 5 | 하네스 · SIGINT · 전체 smoke · 분석 · 포맷 · import 둘 | ✓ VERIFIED | 위 하네스 · SIGINT · SC3. 복제본에서 `fvm dart analyze` `No issues found!`, `dart format --set-exit-if-changed tool` rc 0, import `dart:convert` · `dart:io` 둘, `Process.run(` 한 곳 |
| 06-14 | 1 | 처리 기록: 아홉 fixed · IN-08 deferred · `open: 0` · `total: 16` | ✓ VERIFIED (그 시점) | `0461741` 의 파일: fixed 15 · deferred 1 · `open: 0` · `total: 16`. 지금 파일은 재리뷰 기록(`3f29741`)으로 `open: 2` · `total: 18` (IN-10 · IN-11) 이고 앞의 16행은 그대로다 — 기록이 재리뷰를 따른 것이다 |
| 06-14 | 2 | push gate 0 뒤 한 줄 push | ✓ VERIFIED | 원격 작업 브랜치 = `0461741`. `0038572..0461741` 의 더해진 줄에서 경로 꼴 글자는 계획 파일 안의 gate 정규식뿐이다 (누출 아님) |
| 06-14 | 3 | 브랜치 push 실행 `success` · 로그 세 줄 | ✓ VERIFIED | run 38934754393 `push` · `success` · head `0461741`, 로그에 `버전 일치 검사: 평소 …` · `[3/10] 배포 파일의 구성 … 통과` · `점검 통과 (10개 중 10개)` |
| 06-14 | 4 | PR 의 `pull_request` 실행 `success`, 그때 `origin/main` = `0038572` | ✓ VERIFIED | run 38935292307 `pull_request` · `success`, 같은 세 줄. PR #3 은 지금 `MERGED` (06-15) |
| 06-14 | 5 | 버전 · CHANGELOG · tag 불변, VERSIONING 은 한 줄만 | ✓ VERIFIED | `main` 의 `version: 2.0.0`, CHANGELOG 1행 그대로, tag 네 줄, VERSIONING 은 `724d17a..HEAD` 에서 1줄 더함뿐 |
| 06-15 | 1 | 소유자 `merge` 뒤에만 `gh pr merge --merge` | ✓ VERIFIED | 소유자 응답 17:01:23Z (06-15-SUMMARY) < `mergedAt` 17:03:39Z (`gh pr view 3`) |
| 06-15 | 2 | `origin/main` = 부모 둘 merge commit, 첫 부모 `0038572`, 고침 커밋 셋 · 브랜치 · `v2.0.0` 이 조상 | ✓ VERIFIED | `gh api` 부모 `0038572…` · `0461741…`. `merge-base --is-ancestor` 가 `85e1b0d` · `9d96778` · `ea2d664` · `0461741` · `v2.0.0` (그리고 `317d3ff` · `e6a4cbc`) 모두 참 |
| 06-15 | 3 | `main` 의 version · markdown · CHANGELOG · 세 표식 · tag · 브랜치 | ✓ VERIFIED | `git show origin/main:…` — `version: 2.0.0`, `markdown: ^7.3.1`, CHANGELOG 1행, `changelogTopOf(` 2곳, VERSIONING 83행, `allowMalformed: true` 2곳; tag 네 줄; `ls-remote --heads` 에 작업 브랜치 |
| 06-15 | 4 | `main` push 실행 `success` · 로그 두 줄 | ✓ VERIFIED | run 38936761858 `push` · `success` · head `3418989`, 로그의 `버전 일치 검사: 평소 …` · `점검 통과 (10개 중 10개)` |

**Score:** 82/82 truths verified (0 present, behavior-unverified)

### 첫 줄 규칙이 꼴 전체를 닫는가 (같은 결함의 다른 입력 찾기)

이 저장소의 앞선 gap 여덟은 "고친 입력은 막히고 같은 꼴의 다른 입력이 뚫린다" 였다. 그래서 고친 reader 의 전제를 따로 따졌다.

- 통과하려면 첫 줄이 `## ` + ASCII 숫자 셋 + ` - ` + 비어 있지 않은 글자여야 한다. 첫 줄 앞에는 블록이 없고 ATX 제목은 뒤 줄이 바꾸지 못하므로, CommonMark 렌더러(GitHub 포함)의 첫 h2 는 그 줄이다. 버전 토큰은 ASCII 숫자와 점뿐이라(`\d` 는 유니코드 숫자를 받지 않는다) 렌더가 그 글자를 바꿀 길이 없다. 그래서 검사가 읽는 버전과 화면의 최상단 버전이 갈릴 수 없다. 해석기는 실패를 더할 수만 있다.
- 문자열 하네스 63 입력 가운데 통과한 것은 모두 첫 줄이 위 꼴인 경우였다. 지난 회차 표의 갈림 꼴(한 글자 setext 셋 · 인용 · 목록 · 단락 안의 `<!--` 여덟 · 제목 안 인라인 주석)은 모두 문구 A 로 실패했다. 줄 나눔 차이도 봤다. CR 하나는 `LineSplitter` 와 CommonMark 가 둘 다 줄 끝으로 보고, U+2028 · U+0085 · VT · FF 는 둘 다 줄 끝으로 보지 않는다. 그래서 첫 줄의 범위가 갈리지 않는다.
- 통과하지만 날짜 자리가 이상한 꼴(`<!--` 꼬리 · 닫힌 주석 꼬리 · `<span>` · NUL · VT 뒤 글자 · 끝 백슬래시)은 평소 모드에서만 통과한다. 평소 모드는 버전만 견주고, 버전은 화면과 같다. tag 모드는 `YYYY-MM-DD` 검사에서 실패한다. 거짓 통과가 아니다.
- CHANGELOG 최상단을 읽는 다른 자리: `tool/smoke.dart` 는 읽지 않는다. `checkShippedComposition` 안에서는 (i) 한 곳뿐이다 (`changelogTop(` 호출 1곳).

### Deferred Items

없다. Phase 6 이 마지막 phase 이고 남은 gap 이 없다.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `tool/verify.dart` | `changelogTopOf` (첫 줄 규칙 + 둘째 reader), `checkVersionAgreement` 의 블록, 고친 문장 | ✓ VERIFIED | 있고, `main` 의 CI 세 실행에서 돌았다. 63 입력 하네스 · 전체 실행 30번 |
| `tool/smoke.dart` | decoder · `Future.wait` 제한 · (c″) · `pendingSpawn` · `killTree` 재확인 · `scrubNamesFor` | ✓ VERIFIED | 하네스 · SIGINT · 전체 smoke. `killTree` 의 재확인에 경고 하나 (IN-11) |
| `VERSIONING.md` | 「CHANGELOG 항목 형식」 의 첫 줄 규칙 한 줄 | ✓ VERIFIED | 83행 |
| `pubspec.yaml` | 19 · 21행의 새 주석, `markdown: ^7.3.1` | ✓ VERIFIED | — |
| skill 세 파일 | 의존성 문장 한 줄씩 | ✓ VERIFIED | 각 1+/1- |
| `example/README.md` | M107 ~ M115 소절, (06-08) (2) · (3) 덧붙임 | ✓ VERIFIED | (06-08) 소절의 (4) · (5) 와 11행이 낡음 — IN-10 (경고) |
| `06-REVIEW-DISPOSITION.md` | 처리 기록 | ✓ VERIFIED | 06-14 #1 참조 |
| `refs/tags/v2.0.0` · `refs/heads/main` (origin) | annotated tag · merge commit `3418989` | ✓ VERIFIED | `ls-remote` |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `checkVersionAgreement` | `CHANGELOG.md` | `changelogTop` → `changelogTopOf` (첫 줄 정규식 + `firstElement(nodes, 'h2')`), `FormatException` → `[message, '', changelogGuide]` | ✓ WIRED | 2308 ~ 2311행. 전체 실행에서 블록 머리 줄 · 안내 줄(`VERSIONING.md 「CHANGELOG 항목 형식」`)이 `[3/10]` 아래에 나왔다 |
| `VERSIONING.md` 「CHANGELOG 항목 형식」 | `changelogTopOf` | 형식 규칙과 검사가 같은 것을 말함 | ✓ WIRED | 83행 문장과 1693행 정규식 · 안내 줄 |
| `tool/verify.dart` | `example/README.md` | M107 ~ M115 의 실제 실행 결과 | ✓ WIRED | 이번 재실행 결과가 표와 같다 |
| `runProcess` | 하위 명령 | `Process.start` → `pendingSpawn` → `runningChild`; decoder 둘과 `exitCode` 를 `Future.wait` 로 묶어 `timeout` | ✓ WIRED | 하네스 |
| `main` 의 SIGINT 처리기 | 띄우는 중의 하위 명령 | `awaitRunningChild()` | ✓ WIRED | 1092행, SIGINT 실행 rc 130 |
| `runSmoke` · `main` 의 catch 둘 | `scrub` | `scrubNamesFor(…)` | ✓ WIRED | 정의 + 세 호출 |
| `gsd/v2.0-package-rework` (origin) | `main` (origin) | `gh pr merge 3 --merge` | ✓ WIRED | 부모 둘, 조상 일곱 |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| `checkVersionAgreement` | `top` (CHANGELOG 최상단) | 파일 첫 줄의 정규식 (주 reader) + `package:markdown` 첫 h2 (일치 확인) | 예 — 버전은 해석기 판에 기대지 않는다 | ✓ FLOWING |
| `checkVersionAgreement` | `pub` (version) | `package:yaml` 의 `version` 값 | 예 | ✓ FLOWING |
| smoke `judge` | 진단 줄 · 종료 코드 | 받은 프로젝트의 `dart analyze --format=json` | 예 — 실제 실행에서 두 주소 각각 6줄 · 종료 코드 2 | ✓ FLOWING |

### Behavioral Spot-Checks

전체 실행은 복제본에서 `fvm dart run tool/verify.dart …` 이다. 모두 stderr 에 해당 모드 줄(`평소` · `tag … (--tag)` · `tag … (GITHUB_REF_NAME)`)이 있었다.

| # | 입력 | 명령 | Result | Status |
|---|------|------|--------|--------|
| — | HEAD | 평소 / `--tag v2.0.0` / 환경변수 `v2.0.0` / `--tag v2.0.1` | rc 0 · 0 · 0 · 1 (블록 둘, `[3/10]` 만) | ✓ PASS |
| a | CHANGELOG 맨 앞 `2.1.0 - 미출시` / `-` / 빈 줄 (지난 거짓 통과) | 평소 / `--tag v2.0.0` / 환경변수 | 셋 다 rc 1 · 문구 A `` `2.1.0 - 미출시` `` | ✓ PASS (닫힘) |
| a2 | 같은 머리, 밑줄 `--` | 평소 / `--tag v2.0.0` | rc 1 · rc 1 (문구 A) | ✓ PASS |
| a3 | 맨 앞 `2.0.1 - 2026-10-20` / `-` (지난 거짓 통과) | `--tag v2.0.0` / 환경변수 / 평소 | 셋 다 rc 1 · 문구 A | ✓ PASS (닫힘) |
| b0 | 상태 C, CHANGELOG 그대로 | `--tag v2.0.1` | rc 1 · `… 최상단 버전 (2.0.0) 이 다르다.` | ✓ PASS |
| b | 상태 C + 맨 앞 `> <!--` / `## 2.0.1 - 2026-10-16` / `-->` (지난 거짓 통과) | `--tag v2.0.1` / 환경변수 / 평소 | 셋 다 rc 1 · 문구 A `` `> <!--` `` | ✓ PASS (닫힘) |
| b2 | 상태 C + 맨 앞 `<!-- a --> x <!--` / 빈 줄 / `## 2.0.1 …` / 빈 줄 / `-->` (지난 거짓 통과) | `--tag v2.0.1` / 환경변수 / 평소 | 셋 다 rc 1 · 문구 A | ✓ PASS (닫힘) |
| C-good | 상태 C + 1행 `## 2.0.1 - 2026-10-16` (올바른 새 릴리스) | `--tag v2.0.1` / 환경변수 / 평소 | 셋 다 rc 0 · 10/10 | ✓ PASS (거짓 실패 없음) |
| M113 | 맨 앞 `# Changelog` + 빈 줄 | 평소 / `--tag v2.0.0` | rc 1 · 문구 A `` `# Changelog` `` | ✓ PASS (소유자에게 보인 변화 그대로) |
| M114 | 1행 `## **2.0.0** - 2026-10-15` | 평소 / `--tag v2.0.0` | rc 1 · 문구 A | ✓ PASS (같음) |
| raw h2 | 맨 앞 `<h2>2.0.0 - 2026-10-15</h2>` | 평소 | rc 1 · 문구 A | ✓ PASS (같음) |
| M115 | 1행 `## 2.0.0 - 2026-10-15 ##` | 평소 | rc 1 · 문구 B `첫 줄: 2.0.0 - 2026-10-15 ## / 첫 h2: 2.0.0 - 2026-10-15` | ✓ PASS (같음) |
| 고치기 전 | `85e1b0d` 의 부모 판 + a / + b | 평소 / `--tag v2.0.1` | 둘 다 rc 0 · 10/10 | ✓ PASS (단언이 고친 판과 고치기 전 판을 가른다) |
| 하네스 | 머리 조각 · 변형 63개 (HEAD 포함) | `changelogTopOf` | 통과 16 (HEAD 포함 — 모두 첫 줄이 엄격한 제목), 문구 A 39, 문구 B 8, 해석기 사망 0 | ✓ PASS |
| 하네스 | **IN-04** — stdout · stderr 의 UTF-8 아닌 바이트 | `runProcess` 를 `try/finally` 안에서 | 지금 판: `exit=0` · U+FFFD 둘 · `finally=ran` · rc 0. 고치기 전 판: rc 255 · finally 없음 | ✓ PASS (닫힘) |
| 하네스 | `Process.run` 의 UTF-8 아닌 출력 (같은 꼴의 다른 reader) | `try/finally` 안에서 | `FormatException` 이 await 로 와서 잡힘 · finally 돎 | ✓ PASS |
| 하네스 | WR-06 — `sleep N & echo hi`, 제한 2초 | `runProcess` | `timedOut=true` · 2초 | ✓ PASS |
| 하네스 | (c″) · 코드 셋 · 순서 | `judge` | 위 06-13 #3 | ✓ PASS |
| 하네스 | (c″) 가림 — 종료 코드 3 · 위반 두 줄 · 다른 파일의 error 한 줄 | `judge` | `reasons=0` | ⚠️ 경고 (must_have 문장 그대로의 동작) |
| 하네스 | **IN-11** — P → A → B, 첫 표를 읽은 직후 A 를 끝내는 `readTable` | `killTree` | B 가 살아 있음 · 상태 `S` · 부모 pid 1, 표 읽기 4번. 대조(주입 없음)는 B 끊김 | ⚠️ 경고 (아래 판정) |
| — | smoke 통과 | `smoke.dart v2.0.0` | rc 0, 41초, 남은 폴더 0 | ✓ PASS |
| — | smoke SIGINT | 받기 단계에서 `kill -INT` | rc 130, 5초 뒤 남은 폴더 0 · 프로세스 0, 출력에 경로 0 | ✓ PASS |
| 측정 | 받는 쪽 옵션 파일 `lib/codegen.yaml` 의 `exclude:` 를 맵으로 (복제본) | 전체 `verify.dart` | rc 1 · 4개 실패 — `[2/10]` 에 `invalid_section_format`, `[5/10]` · `[9/10]` · `[10/10]` | ℹ️ 저장소 쪽에서 잡힘 |
| 측정 | `lib/codegen.yaml` 끝에 깨진 YAML (복제본) | 전체 `verify.dart` | rc 1 · 5개 실패 (`[2/10]` · `[3/10]` 포함) | ℹ️ 저장소 쪽에서 잡힘 |
| — | tool 품질 | 복제본 `dart analyze` · `dart format --set-exit-if-changed tool` | `No issues found!` · rc 0 | ✓ PASS |

### Probe Execution

해당 없음. `scripts/*/tests/probe-*.sh` 가 없고, 이 phase 의 계획도 probe 를 선언하지 않는다. 계획의 검증 수단인 `tool/verify.dart` · `tool/smoke.dart` 는 위에서 직접 돌렸다.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| REL-02 | 06-02 · 06-04 · 06-05 · 06-06 · 06-15 | 새 버전의 annotated tag 가 원격에 있어 `ref: vX.Y.Z` 로 고정할 수 있다 | ✓ SATISFIED | SC2 · SC3 (smoke 가 `ref: v2.0.0` 으로 받아 `resolved-ref` = tag 커밋) |
| REL-03 | 06-01 · 06-05 · 06-07 · 06-08 · 06-10 · 06-11 · 06-12 · 06-14 · 06-15 | tag · version · CHANGELOG 최상단 버전이 다르면 CI 가 실패한다 | ✓ SATISFIED | SC1 — 지난 회차의 거짓 통과 넷이 세 경로 모두 실패, 올바른 새 릴리스는 통과 |
| REL-04 | 06-02 · 06-03 · 06-04 · 06-05 · 06-07 · 06-09 · 06-10 · 06-11 · 06-13 · 06-14 · 06-15 | 릴리스 직후 빈 프로젝트에서 새 tag 를 받아 기본 규칙 · plugin 진단 확인 | ✓ SATISFIED | SC3 (직접 실행) |

REQUIREMENTS.md 가 Phase 6 에 매핑한 ID 는 REL-02 · REL-03 · REL-04 셋이고, 모두 plan frontmatter 에 있어 ORPHANED 는 없다. REQUIREMENTS.md 는 셋 다 `[x]` · `Complete` (06-15 기록) 이고, 이번 판정과 같다.

### Code Review 발견의 판정 (06-REVIEW.md — 등급을 물려받지 않고 다시 갈랐다)

잣대는 "명시된 진실(성공 기준 · must_haves · 요구사항)이 어떤 입력에서 거짓이 되는가" 이다.

| 항목 | 주장 | 이번 확인 | 판정 |
|------|------|-----------|------|
| IN-10 | `example/README.md` (06-08) 소절의 읽는 법 (5) 가 「지금은 … `# Changelog` 머리 줄의 결과(`passed=true`)는 같다」 라고 말해 M113 과 어긋난다 | **맞다.** 707행 (5) 는 현재형으로 통과를 말하고, 728행 M113 과 이번 전체 실행은 실패다. 같은 소절 (4) 의 「떼지 않은 문자열은 첫 `## ` 줄이 단락이 되어 다음 h2 를 읽는다」 도 지금 판에서는 문구 A 실패다 (하네스 BOM 두 개). 11행의 괄호도 지금 쓰임과 다르다 | **경고 — gap 아님.** 06-12 must_have 3 은 고칠 자리와 구절을 목록으로 정했고 (5) · (4) 는 그 밖이다. 06-12 prohibition 3 은 (06-08) 소절에서 (2) · (3) 밖을 고치지 말라고 했다 — 계획 범위가 남긴 낡은 문장이다. 성공 기준 · 요구사항의 동작은 바뀌지 않는다. 문장을 믿고 머리말을 넣으면 큰 소리로 실패하는 쪽이라 거짓 통과로 이어지지 않는다. 고침은 문서 세 자리 (reviewer 의 Fix) |
| IN-11 | `killTree` 의 SIGKILL 직전 재확인이, 얼린 뒤 중간 프로세스가 끝나 사슬에서 빠진 자기 자손을 SIGCONT 로 풀어 살려 둔다 | **재현했다.** P → A → B, 첫 표를 읽은 직후 A 를 끝낸 `readTable` 주입에서 B 가 살아 있고(부모 pid 1, 얼려 있지 않음), 주입 없는 대조에서는 B 가 끊겼다. 고치기 전 판(`ea2d664` 의 부모)은 얼린 것을 모두 SIGKILL 했다 (읽어서 확인) — 동작 회귀다 | **경고 — gap 아님.** 06-13 must_have 4 는 "사슬에 남은 pid 만 끊고 사슬 밖의 얼린 pid 는 SIGCONT 로 푼다" 를 그대로 요구하고 코드가 그대로 한다. 머리 주석의 범위 문장 「부모가 먼저 끝난 자손(pid 1 로 옮겨 간 것)은 끊지 못한다」 도 B 를 글자 그대로 덮는다 (시점을 한정하지 않는다). 06-09 #3 · #4 의 「그 프로세스를 끊고」 · 「돌고 있는 하위 명령을 끊고」 는 P 를 끊는다는 말이고 P 는 끊긴다. 남은 B 가 지운 임시 폴더를 다시 만들어 06-09 #4 를 거짓으로 만드는 실행은 보이지 못했다 — 표를 읽은 뒤 몇 ms 안에 중간 프로세스가 스스로 끝나야 한다. 다만 문서 주석 (c) 의 근거(「재사용되어 남의 프로세스일 수 있으므로」)는 이 경우를 말하지 않는다. reviewer 의 Fix(얼리기에 성공한 pid 만 기록하고 그중 표에 남은 것은 사슬과 상관없이 끊기)를 다음 손질에 권한다 |
| (c″) 가림 | JSON 에 다른 error 줄이 하나라도 있으면 (c″) 가 서지 않는다 | **재현했다** (`reasons=0`). 계획 자신의 하네스 입력 `exit3-err → reasons=0` 이 이 동작을 단언한다 | **경고 — gap 아님.** 06-13 must_have 3 은 조건을 「`error` 줄이 하나도 없으면」 으로 적었다. 가려지려면 같은 ref 에서 받은 옵션 파일이 깨지고 템플릿 · 위반 파일에 error 강도 진단이 함께 나야 한다. 지금 `v2.0.0` 의 실행은 종료 코드 2 (error 0) 이다. 깨진 옵션 파일은 같은 커밋의 `verify.dart` 가 `[2/10]` · `[3/10]` 에서 잡는다 (복제본 측정). 위반 규칙의 강도를 error 로 올린 ref 는 (c) 의 `info` 패턴에서 따로 실패한다 (하네스) |
| IN-08 | 「쓰인 그대로는 해당 없음」 (reviewer) · `deferred` (처리 기록, G7-Q1) | 첫 줄 규칙 아래에서 통과하려면 정규식이 첫 줄에서 버전을 잡아야 하고, 그 값은 해석기와 무관하다. 해석기는 갈림 블록을 더할 수만 있다 | **동의 — gap 아님.** 거짓 통과 방향은 해석기 판에 기대지 않는다. 남는 것은 새 `markdown` 판이 첫 줄 제목 글자를 달리 읽을 때의 거짓 실패(CI 가 문구 B 로 멈춤)뿐이고, 실패 쪽이다. `deferred` 가 맞다 |
| 범위 밖 — `analyzer: exclude:` 맵 꼴 | include 받는 파일의 맵 꼴 exclude 는 진단도 종료 코드도 없다 → smoke 의 (2′) · (2″) 가 못 본다 | 복제본의 `lib/codegen.yaml` 을 맵 꼴로 바꾸고 전체 `verify.dart` 를 돌렸다 — rc 1, `[2/10]` 이 그 파일을 분석의 루트로 볼 때 `invalid_section_format` 을 내고 `[5/10]` · `[9/10]` · `[10/10]` 도 실패 | **info — gap 아님.** SC3 · REL-04 는 규칙 · plugin 진단만 요구한다. 생성 파일 제외는 이 phase 의 문장 밖이고, 저장소 쪽 gate 가 같은 커밋에서 잡는다. smoke 가 못 보는 것은 사실이다 |
| (지난 회차의 새 info) | 꺾쇠 URL link reference 에서 `package:markdown` 이 `RangeError` | 첫 줄 뒤에 `[x]:` / `<` 를 두면 지금도 `RangeError` (하네스) | info — 실패 쪽(255), 06-13 이 범위 밖으로 정한 그대로 |

### Prohibitions (판정 등급 49건 — LLM 판정, 비권위)

06-01 ~ 06-11 의 37건은 지난 회차 표들과 같은 판정이다 (해당 파일 · 원격이 그 뒤로 그 방향으로 바뀌지 않았다). gap 수정 2회차의 12건:

| Plan | 항목 | 판정 | 근거 |
|------|------|------|------|
| 06-12 | (가) 꼴별 패치 장치 없음 · 네트워크 없음 · 판 고정 없음 | 지켜짐 | `changelogTopOf` 에 밑줄 넓힘 · `<!--` 찾기가 없다 (1725 ~ 1760행). import 는 `dart:convert` · `dart:io` · `markdown` · `yaml`. `^7.3.1` · `^3.1.4` 그대로 |
| 06-12 | 제목 글자 규칙 그대로 · 버전 · CHANGELOG · tag · `lib/` · README · lock · workflow · smoke 불변 | 지켜짐 | `85e1b0d` 는 verify · pubspec · VERSIONING · skill 셋, `317d3ff` 는 `example/README.md`, `e6a4cbc` 는 verify 1줄. M95 · `--tag` 날짜 검사 그대로 |
| 06-12 | skill 그 한 줄 밖 · `.claude/CLAUDE.md` · M1 ~ M106 · VERSIONING 한 줄 | 지켜짐 | skill 각 1/1, CLAUDE.md `724d17a..HEAD` 0, `example/README.md` 의 지운 줄은 (2) · (3) · 113행 (70 행) · 117행 (i) 구절뿐, VERSIONING 1+ |
| 06-12 | 복제본에서만 · 기록에 경로 없음 | 지켜진 것으로 보임 (과정은 판정 불가) | 더해진 줄에 경로 꼴 0 |
| 06-12 계획 밖 | `e6a4cbc` (소유자 승인) | 동작 같음 | 보이지 않는 글자를 이스케이프 표기(백슬래시 · `u` · `FEFF`) 로 되돌린 1줄, 추적 파일의 U+FEFF 바이트 0 |
| 06-13 | 여섯 밖 불변 · smoke 밖 불변 · verify · CI 에 넣지 않음 · 새 의존성 없음 | 지켜짐 | `9d96778` · `ea2d664` 는 `tool/smoke.dart` 만, import 둘, `verify.yml` 불변 |
| 06-13 | 판정 (2) · (3) · 배타 순서 · 제한 값 · 69 · 130 · `--keep` 그대로 | 지켜짐 | 2분 · 5분 · 5분 상수, 순서 (a) → (b) → (c′) → (c″) → (c), SIGINT rc 130 |
| 06-13 | 전체 smoke 한 번 · 저장소 안에 파일 없음 · 기록에 경로 없음 | 지켜진 것으로 보임 (과정은 판정 불가) | 더해진 줄에 경로 꼴 0 |
| 06-14 | `main` · tag · force push 없음 · 한 줄 push · PR 은 열기만 | 지켜짐 | `0461741` 이 원격 작업 브랜치, 병합은 06-15 의 소유자 응답 뒤 |
| 06-14 | 처리 기록의 제목 · `recorded:` · 형식 설명 · 앞 회차 여섯 행 · 저장소 파일 불변 | 지켜짐 | `0461741` · `4ee0c55` 는 `.planning/` 만 |
| 06-14 | PR 본문 · 커밋 · SUMMARY 에 경로 없음 | 지켜짐 | PR #3 본문 경로 꼴 0 |
| 06-15 | `merge` 전에 병합 안 함 · merge commit 만 · 되감지 않음 · tag · 버전 · CHANGELOG 불변 | 지켜짐 | 시각 순서, 부모 둘, 작업 브랜치 남음, tag 네 줄 |
| 06-15 | 저장소 파일 불변 · 메시지에 비공개 정보 없음 | 지켜짐 | `3ba5fca` · `5e44d4c` 는 `.planning/` 만, 병합 메시지에 경로 꼴 0 |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `example/README.md` | 11 · 706 · 707 | 지금 동작과 다른 현재형 문장 ((4) · (5), 의존성 괄호) | ⚠️ Warning | IN-10 — 문서만 |
| `tool/smoke.dart` | 459 ~ 470 · 427 ~ 430 | 재확인이 얼린 자기 자손을 SIGCONT 로 풂, 문서 주석 (c) 의 근거가 이 경우를 말하지 않음 | ⚠️ Warning | IN-11 — must_have 문장 밖, 고치기 전보다 덜 끊음 |
| `tool/smoke.dart` | (c″) | 다른 error 줄이 있으면 서지 않음 | ⚠️ Warning | 설계 그대로, 두 결함이 겹칠 때만 |
| `example/README.md` | (06-01 소절) | `TBD` 2건 | ℹ️ Info | 실험 입력 값을 적은 문장 — debt marker 아님 (지난 회차와 같음) |

이번에 바뀐 파일(`tool/verify.dart` · `tool/smoke.dart` · `pubspec.yaml` · `VERSIONING.md` · `example/README.md` · skill 셋)에 `TBD` · `FIXME` · `XXX` 새 표식은 없다. blocker 는 없다. 재검증 증거 gate 로 advisory 에 내린 항목도 없다 — 위 경고 셋은 증거(하네스 재현)가 있지만 명시된 진실을 거짓으로 만들지 않아 경고로 둔다.

### Human Verification Required

이번 gap 수정 plan(06-12 ~ 06-15)에는 `<human-check>` 가 없다. 06-15 의 checkpoint 는 소유자가 이미 답했다 (`merge`, 17:01:23Z). 지난 회차의 둘이 아직 열려 있다.

### 1. Actions 의 `Run workflow` 버튼

**Test:** GitHub 의 Actions → `verify` 화면을 연다.
**Expected:** `Run workflow` 버튼이 보인다 (실행 자체는 run 38850984674 가 `success`).
**Why human:** 웹 화면의 버튼 표시는 CLI 로 볼 수 없다.

### 2. 판정 등급 prohibition 49건

**Test:** 위 「Prohibitions」 표와 지난 회차 표를 훑는다.
**Expected:** 판정에 동의하거나, 다르게 보는 항목을 적는다.
**Why human:** 시행 증거(test)가 없는 judgment 등급이라 자동 판정은 권위가 없다.

### Gaps Summary

**gap 은 없다.** 목표 문장의 세 부분이 모두 참이다. 원격에 annotated tag `v2.0.0` 이 있다. 그것을 `ref: v2.0.0` 으로 받은 빈 프로젝트에서 규칙과 plugin 진단이 나온다 (이번에 다시 돌림). 다음 릴리스의 gate 도 tag · pubspec · CHANGELOG 최상단이 서로 다르면 실패한다.

**지난 첫 gap (CHANGELOG 최상단 reader)** 은 구조로 닫혔다. 해석기를 화면의 대리로 믿던 전제를 버리고, 형식 규칙 「최상단 항목 = 파일 첫 줄」 을 검사로 굳혔다. 해석기는 둘째 reader 로만 남았다. 같은 꼴의 다른 입력 63개, 지난 거짓 통과 넷의 세 경로 전체 실행, 고치기 전 판과의 대조 모두에서 거짓 통과가 없었다. 올바른 새 릴리스 상태는 거짓 실패 없이 통과했다. 소유자에게 보인 동작 변화(머리말 · 장식 · raw `<h2>` · 닫는 `##` 가 실패로)도 코드가 그대로 한다.

**지난 둘째 gap (smoke 의 UTF-8 아닌 출력)** 도 닫혔다. 같은 꼴의 다른 reader 인 `Process.run` 은 오류가 await 쪽으로 와서 finally 를 건너뛰지 않는다.

**경고 넷은 다음 손질에 권하는 것** 이다 (모두 must_have 문장 밖, 받는 쪽 영향 없음).
- IN-10 — `example/README.md` 의 낡은 문장 세 자리. 문서만 고치면 된다.
- IN-11 — `killTree` 의 재확인. reviewer 의 Fix 대로 얼리기에 성공한 pid 를 사슬과 상관없이 끊는다.
- (c″) 가림 — 설계 그대로다. 바꾸려면 「옵션 파일 줄의 error」 와 「코드 error」 를 갈라 셀 길이 필요하다.
- smoke 가 못 보는 exclude 맵 꼴 — 저장소 쪽 gate 가 잡는다.

덧붙여 알아 둘 것(이 phase 의 목표 밖): CI 는 `runs-on: ubuntu-latest` 이고 GitHub 은 이 이름이 2026-10-19 부터 Ubuntu 26 으로 옮겨 간다고 알렸다. 다음 실행이 새 이미지에서 돌므로, 실패하면 skill 의 runner 이미지 절부터 본다.

---

_Verified: 2026-10-16T18:05:06Z_
_Verifier: Claude (gsd-verifier)_
