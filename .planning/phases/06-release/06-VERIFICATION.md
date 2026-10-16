---
phase: 06-release
verified: 2026-10-16T05:39:35Z
status: gaps_found
score: 40/41 must-haves verified
covered_files:
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
covered_digest: "v3:sha256:1c192ecb5fd52807fd7aef82069d72ce09f29dc4d1b8cd423bb4baff1fd229b9"
behavior_unverified: 0
overrides_applied: 0
gaps:
  - truth: "ROADMAP 성공 기준 1 · REL-03 — tag 이름, `pubspec.yaml` 의 version, CHANGELOG 최상단 버전이 서로 다르면 실패하는 검사가 CI 의 tag 트리거에 걸려 있다"
    status: partial
    reason: "검사는 CI 의 tag 트리거에 걸려 있고 보통의 어긋남(tag 이름 · `-dev` · CHANGELOG 버전 · 환경변수 경로)에서는 실제로 실패한다. 그러나 version 을 읽는 줄 단위 reader 둘이 실제 해석기(YAML · Markdown)와 다르게 읽는 입력에서 셋이 서로 다른데도 tag 모드 전체 실행이 종료 코드 0 · 10/10 으로 통과한다 — (1) pubspec: 겹따옴표 여러 줄 스칼라 안의 열 0 `version: 2.0.0` 줄 (YAML · pub 은 `2.0.0-dev`) 에서 `--tag v2.0.0` 과 `GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v2.0.0` 둘 다 rc 0 (CR-01 재현); (2) CHANGELOG: HTML 주석 안의 열 0 `## 2.0.1 - 2026-10-20` 줄을 최상단으로 읽어, 렌더된 최상단이 `2.0.0` 인 새 릴리스 상태(pubspec 2.0.1 · lock 여섯 · README `ref: v2.0.1`)에서 `--tag v2.0.1` rc 0 (새로 찾음 — 다음 릴리스의 gate 가 뚫린다); (3) CHANGELOG: 공백 1칸 들여 쓴 ATX 제목 · setext 제목을 건너뛰어 평소 모드가 rc 0 (WR-02 재현). 이미 올린 v2.0.0 은 이 결함의 영향을 받지 않았다 — tag 커밋의 pubspec 은 한 줄 `version: 2.0.0`, CHANGELOG 1행 `## 2.0.0 - 2026-10-15` 이다."
    artifacts:
      - path: "tool/verify.dart"
        issue: "`pubspecVersionText` (1633행) 의 원문을 YAML 의 `version` 과 견주는 확인이 없다 — (h) (2169 ~ 2183행) 는 `pubspecReleaseVersion` 의 꼬리 뗀 값만 견준다; tag 모드 (2236 ~ 2243행) 가 그 원문을 그대로 믿는다"
      - path: "tool/verify.dart"
        issue: "`changelogTop` (1657행) 이 `## ` 로 시작하는 첫 줄을 최상단으로 잡는다 — HTML 주석 · 펜스 코드 블록 안의 열 0 `## ` 줄을 제목으로 읽고, 들여 쓴 ATX · setext 제목은 건너뛴다"
    missing:
      - "version 을 읽는 reader 를 하나로 합친다: `pubspec.yaml` 의 version 은 `package:yaml` 이 읽은 `version` 값에서 얻고(원문 · 꼬리 뗀 값 모두), 줄 단위 reader 를 남긴다면 원문 전체를 YAML 값과 견주어 다르면 실패 — 05 의 길 B (`compareLineReadersWithYaml`) 와 같은 방식, IN-03 의 두 reader 합치기를 함께"
      - "CHANGELOG 최상단 reader 가 Markdown 렌더 결과와 다르게 읽을 수 있는 꼴을 닫는다: (가) Markdown 해석기(새 dev 의존성 — G4-Q1 때처럼 소유자 결정)로 첫 h2 를 찾거나, (나) fail-closed 허용 목록 — 첫 엄격한 `## X.Y.Z - …` 줄 앞에 HTML 주석 여는 줄(`<!--`), 펜스 여는 줄(``` · ~~~), 공백 0 ~ 3칸 + `#` 제목 꼴, setext 밑줄(`---` · `===`) 이 있으면 FormatException 으로 실패"
      - "실패 방향을 입력 하나가 아니라 꼴로 기록 · 단언한다: 겹따옴표 · 홑따옴표 여러 줄 스칼라, HTML 주석, 두 종류 펜스, 들여 쓴 ATX 1 ~ 3칸, setext 두 종류, U+FEFF 머리 — 평소 · `--tag` · `GITHUB_REF_NAME` 세 경로에서 (`example/README.md` 의 M 기록)"
      - "고침은 저장소 안쪽만 바꾼다 — 받는 쪽 규칙이 같으므로 새 버전 번호는 필요 없다 (VERSIONING.md 기준표 \"저장소 안쪽만 바뀜 → 올리지 않음\"), 다음 릴리스 전에 닫는다"
human_verification:
  - test: "GitHub 의 Actions → `verify` 화면을 열어 `Run workflow` 버튼이 보이는지 본다 (02-UAT 6번 · D-03 (6) — 06-06 Task 3 의 `<human-check>`)"
    expected: "기본 브랜치 `main` 에 `.github/workflows/verify.yml` 이 있으므로 버튼이 보인다 (실행 자체는 `workflow_dispatch` run 38850984674 가 `success` 로 확인됨)"
    why_human: "GitHub 웹 화면의 버튼 표시는 CLI 로 볼 수 없다"
  - test: "판정 등급 prohibition 25건(PLAN frontmatter 의 `MUST NOT`)의 LLM 판정(아래 「Prohibitions」 표 — 비권위)을 사람이 훑어본다"
    expected: "표의 판정에 동의하거나, 다르게 보는 항목을 적는다"
    why_human: "judgment 등급 prohibition 은 시행 증거(test)가 없어 자동 판정이 권위를 갖지 않는다 (ADR-550 D4)"
---

# Phase 6: Release Verification Report

**Phase Goal:** 새 버전이 annotated tag 로 원격에 있어 사용 프로젝트가 `ref: vX.Y.Z` 로 버전을 고정할 수 있고, 그 tag 를 git 의존성으로 받은 프로젝트에서 규칙과 plugin 이 실제로 적용됨이 확인되어 있다
**Verified:** 2026-10-16T05:39:35Z
**Status:** gaps_found
**Re-verification:** No — initial verification

이미 올린 `v2.0.0` 에 관한 사실(원격 annotated tag, 그 커밋의 version · CHANGELOG, CI 의 tag 실행, tag smoke)은 모두 직접 돌려서 확인했다. gap 은 하나이고 v2.0.0 이 아니라 **다음 릴리스의 gate** 에 관한 것이다. tag 모드 검사가 version 을 줄 단위로 읽는데, 그 값이 YAML · Markdown 이 읽는 값과 다를 수 있는 입력에서 셋이 서로 달라도 통과한다.

## 확인 방법

- 원격 · CI 는 본 체크아웃에서 읽기 전용 명령만 썼다 — `git ls-remote --tags/--heads origin`, `git show v2.0.0:…`, `git cat-file`, `git merge-base --is-ancestor`, `gh run view <id> --log`, `gh pr list`.
- 검사 · smoke 는 임시 폴더 안의 `git clone --local` 복사본에서 돌렸다. 루트에서 `fvm dart pub get --no-example` 을 먼저 했다. 어긋나게 만드는 변경은 갈래마다 새 복사본에서 했다. smoke 의 임시 폴더도 `TMPDIR` 로 같은 임시 폴더 안에 두었다. 끝에 모두 지웠다. 작업 트리는 시작 때와 같다 (orchestrator 상태 파일 넷만 있다).
- SDK 는 Flutter 3.47.5 / Dart 3.13.4 (`.fvmrc` 와 같다) 이다.
- 함수 단위 탐침 하나는 복사본의 `tool/verify.dart` 를 import 해 `changelogTop` · `pubspecVersionText` · `checkVersionAgreement` 를 직접 불렀다. 탐침은 복사본 밖에 두었다.
- 실험 중 lock 을 처음에 `flutter pub get` 으로 다시 받은 갈래 둘(c2 · c5)이 있었다. 이 갈래에서는 연습용 프로젝트 옵션 파일에 `analyzer: exclude: build/**` 가 덧붙어 `[4/10]` 이 함께 실패했다 (README 36행이 적는 Flutter 3.47.5 의 동작이다). 그래서 CR-01 갈래는 VERSIONING 「릴리스 절차」 2번대로 `fvm dart pub get` 만 쓰는 판(c5b)으로 다시 돌렸다. 아래 표의 CR-01 결과는 그 판이다.

## Goal Achievement

### Observable Truths — ROADMAP 성공 기준

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| SC1 | tag 이름 · `pubspec.yaml` version · CHANGELOG 최상단 버전이 서로 다르면 실패하는 검사가 CI 의 tag 트리거에 걸려 있고, 일부러 어긋나게 만든 입력에서 실제로 실패함이 확인되어 있다 | ✗ FAILED (partial) | 걸려 있음: tag 커밋의 `verify.yml` 은 필터 없는 `push:` 이고, tag 실행 38844667011 (`headBranch` `v2.0.0`, `success`) 의 로그에 `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` · `[3/10] … 통과` · `점검 통과 (10개 중 10개)` 가 있다. 실제로 실패함: c1 · c2 · c3 · c4 (아래 spot-check) 가 모두 rc 1 이고 `[3/10]` (i) 블록이 나왔다. **거짓 통과:** c5b (CR-01) — `--tag v2.0.0` · CI 환경변수 둘 다 rc 0 · 10/10, YAML 과 lock 은 `2.0.0-dev`. cA2 (HTML 주석) — 새 릴리스 `--tag v2.0.1` rc 0 · 10/10, 렌더된 최상단은 `2.0.0`. c6 · c7 (들여 쓴 ATX · setext) — 평소 모드 rc 0 |
| SC2 | `git ls-remote --tags origin` 에 새 버전의 annotated tag 가 보이고, 그 tag 의 `pubspec.yaml` version 과 CHANGELOG 최상단 버전이 tag 이름과 같다 | ✓ VERIFIED | `753f520…  refs/tags/v2.0.0` · `704bf56…  refs/tags/v2.0.0^{}` 두 줄이 있다. `git cat-file -t v2.0.0` = `tag` 이고 `rev-parse 'v2.0.0^{commit}'` = `704bf56fb028…` 이다. `git show v2.0.0:pubspec.yaml` 은 전문이 한 줄 `version: 2.0.0` 이다 (여러 줄 스칼라 없음 — CR-01 의 꼴 아님). CHANGELOG 1행은 `## 2.0.0 - 2026-10-15` 이고 앞에 주석 · 들여 쓴 제목이 없다 |
| SC3 | 빈 프로젝트가 새 tag 를 git 의존성(`ref: vX.Y.Z`)으로 받아 `dart analyze` 를 돌리면 기본 규칙 진단과 `riverpod_lint` plugin 진단이 둘 다 보고된다 | ✓ VERIFIED | 직접 돌린 `fvm dart run tool/smoke.dart v2.0.0` 이 rc 0 이다 (50초). lock: `source git` · README 의 url · `resolved-ref 704bf56…`. 두 주소(`recommended.yaml` · 옛 주소 `analysis_options.yaml`) 각각에서 위반 파일의 `info prefer_single_quotes` 와 `warning provider_parameters` 가 나왔고 `riverpod_lint 3.1.9` 였다. 출력에 `analysis_options.yaml:` 줄(include 오류)은 없다. smoke 임시 폴더는 0개 남았다 |

### Observable Truths — PLAN must_haves

06-05 의 셋째 · 다섯째 truth 는 SC2 · SC3 와 같은 내용이라 따로 세지 않았다.

| Plan | # | Truth (요약) | Status | Evidence |
|------|---|--------------|--------|----------|
| 06-01 | 1 | 평소 모드는 꼬리 뗀 version 과 CHANGELOG 버전만 견주고 통과 · stderr 모드 줄 | ✓ VERIFIED | 코드 2216 ~ 2224행. HEAD 의 평소 실행은 rc 0 · 10/10 이고 stderr 는 `버전 일치 검사: 평소 (…)` 이다. c3 평소는 rc 1 이다 (양쪽 방향) |
| 06-01 | 2 | `-dev` · `미출시` 상태의 `--tag v2.0.0` → `[3/10]` 만 실패, 블록 둘 | ✓ VERIFIED | c2: `-dev` 꼬리 블록이 나왔다. 날짜 블록은 코드 2250 ~ 2256행에서 확인했다 (`YYYY-MM-DD` 정규식 — 꼴만 보고 글자 `미출시` 만 보지 않는다) |
| 06-01 | 3 | 꼴이 아닌 tag 는 꼴 블록 하나, 값 없음 · 모르는 인자 · 남는 인자는 64 와 사용법 | ✓ VERIFIED | `--tag` · `--bogus` · `--tag v2.0.0 extra` 가 모두 rc 64 이고 `사용법: fvm dart run tool/verify.dart [--update] [--tag vX.Y.Z]` 가 나온다. 꼴 블록은 코드 2228 ~ 2235행에서 확인했다 |
| 06-01 | 4 | `GITHUB_REF_TYPE=tag` + `GITHUB_REF_NAME` 이면 tag 모드, branch 면 평소, 인자가 우선 | ✓ VERIFIED | c4: rc 1, stderr `버전 일치 검사: tag v2.0.1 (GITHUB_REF_NAME)`. 코드 2998 ~ 3001행 (`env['GITHUB_REF_TYPE'] == 'tag'`, `tagArg ?? ciTag`). PR · `main` push · dispatch 실행 로그가 모두 평소 모드 줄이다 |
| 06-01 | 5 | `verify.yml` 은 7행 주석만 현재형, 나머지는 `79f27e5` 와 같다 | ✓ VERIFIED | `diff` 결과 7행 한 줄만 다르다. `push:` · `pull_request:` · `workflow_dispatch:` 가 있고 `branches:` · `tags:` 는 없다 |
| 06-01 | 6 | D-06 다섯 입력이 실패했고 M92 ~ M96 으로 기록 | ✓ VERIFIED | `example/README.md` 632행 소절에 M92 ~ M97 6행이 있다. 셋(tag 이름 · `-dev` · CHANGELOG 버전)은 이번에 전체 실행으로 다시 실패시켰다 (c1 · c2 · c3) |
| 06-01 | 7 | IN-12 (`keyLikePattern`) — `include:` 값을 다음 줄에 쓴 입력의 통과 (M97) | ✓ VERIFIED | `keyLikePattern` 이 3곳에 있고 M97 기록이 있다. 06-01 T2 `<automated>` 를 VALIDATION 감사가 task 커밋 복제본에서 rc 0 으로 다시 돌렸다. 이번에 따로 재실행하지는 않았다 |
| 06-01 | 8 | 종료 코드 255 를 머리 주석 · 문서 주석 · `example/README.md` 표에 적음 | ✓ VERIFIED | `tool/verify.dart` 30 · 2059행, `example/README.md` 115행 |
| 06-02 | 1 | 「설치」 · 「프로젝트 전체」 · 「생성 파일 제외」 의 합치기 문장, `plugins:` 측정 문장 | ✓ VERIFIED | `두 번 적으면 YAML 이 받지 않는다` 3건이 있고, 226행에 측정 문장이 있다. 측정은 이번에 다시 했다 — 받은 v2.0.0 빈 프로젝트에서 `base.yaml` + 템플릿 exclude + README 의 `linter:` · `plugins:` 블록으로 새 상태 폴더에서 분석했더니 `provider_parameters` 가 있었고 `missing_provider_scope` 는 없었다 |
| 06-02 | 2 | 34행 (flutter#191151 · #191530), 355행 출처 표시, 381행 VERSIONING 링크 | ✓ VERIFIED | 지금 36행에 병합일 · 3.47.2 가 있다. 387행은 `버전 등급 · CHANGELOG 항목 형식 · 릴리스 절차는 [\`VERSIONING.md\`]` 이다 (줄 번호는 뒤 편집으로 밀렸다) |
| 06-02 | 3 | `VERSIONING.md` 「릴리스 절차」 1 ~ 10 과 plugin 새 버전 대응 단락 | ✓ VERIFIED | 129행 절. 2번은 lock 여섯을 `fvm dart pub get` 으로만 받고 69 를 안내한다. 6 · 7 · 8 · 9 단계가 있다. 「plugin 새 버전 때문에 정답지가 저절로 깨졌을 때」 의 (a) ~ (d) 가 있다 |
| 06-02 | 4 | 82행 현재형 | ✓ VERIFIED | `검증 명령 \`[3/10]\` 의 일치 검사(REL-03 …` |
| 06-02 | 5 | README 를 고친 뒤 verify 10/10 | ✓ VERIFIED | HEAD (배포 내용이 v2.0.0 과 같다) 의 평소 실행이 rc 0 · 10/10 이다 |
| 06-03 | 1 | smoke 가 저장소 밖 임시 폴더 · README 블록 · 새 `PUB_CACHE` · 두 주소 · 새 상태 폴더로 분석 | ✓ VERIFIED | 실행 출력. 코드 334 ~ 335행(url · ref), 472 ~ 473 · 607 · 626행(`PUB_CACHE` · `ANALYZER_STATE_LOCATION_OVERRIDE`), 729행(`Directory.systemTemp`) |
| 06-03 | 2 | 판정 D-09 (2) · (3) | ✓ VERIFIED | `judge` 497 ~ 518행. v2.0.0 은 통과(rc 0), v1.3.0 은 실패(rc 1) — 양쪽 방향 |
| 06-03 | 3 | origin 커밋으로 받아 오는 길의 통과 실행 | ✓ VERIFIED | 같은 길을 `ref: v2.0.0` 으로 이번에 돌렸다 (rc 0). `2336ba0` 자체는 다시 돌리지 않았다 |
| 06-03 | 4 | 실패 방향 — 없는 ref 69, `v1.3.0` 1 (tag 를 커밋으로 벗김), 앞선 브랜치 1 | ✓ VERIFIED | 없는 ref: rc 69 와 `git rev-parse '…^{commit}' 실패` 안내. `v1.3.0`: rc 1 · `기대 커밋: 90a2736…` · `resolved-ref 90a2736…` · `recommended` 쪽 두 규칙 없음 · 옛 주소 쪽 있음. 앞선 브랜치 갈래는 다시 돌리지 않았다 (VALIDATION 감사가 rc 0 을 기록) |
| 06-03 | 5 | 사용법 64, `--keep` 이 아니면 임시 폴더를 지우고 경로를 찍지 않음 | ✓ VERIFIED | 인자 없음 rc 64. 통과 실행의 마지막 줄은 `임시 폴더를 지웠다` 이고 경로가 없으며, 남은 폴더는 0개다. `--keep` 때만 마지막 줄에 경로가 나온다 |
| 06-03 | 6 | 자기 SDK 만 사용, stdout 첫 줄 `SDK Flutter … / Dart …` | ✓ VERIFIED | 첫 줄 `SDK Flutter 3.47.5 / Dart 3.13.4`. 코드 133행(`$root/bin/flutter`), 468행(`Platform.resolvedExecutable`) |
| 06-03 | 7 | `dart:io` · `dart:convert` 만 import, analyze 깨끗, format 통과, CI · verify 에 넣지 않음 | ✓ VERIFIED | import 두 줄. 복사본에서 `fvm dart analyze tool` 결과 `No issues found!`, format rc 0. `verify.yml` 에는 7행 주석만 바뀌었다 |
| 06-04 | 1 | 릴리스 커밋 하나에 version · 주석 · CHANGELOG 날짜 · lock 여섯 · VERSIONING 67 · 69행 | ✓ VERIFIED | `704bf56` 은 9파일 11+/11- 이다. lock 여섯은 각각 1줄이고 `version: "2.0.0"` 이다. VERSIONING 67 · 69행이 현재형이다 |
| 06-04 | 2 | 릴리스 커밋에서 평소 · `--tag v2.0.0` 둘 다 10/10 | ✓ VERIFIED | `v2.0.0` 과 HEAD 는 `.planning` 밖 diff 가 없다. 그 HEAD 복사본에서 평소 · `--tag v2.0.0` 이 각각 rc 0 · 10/10 이고 stderr 모드 줄이 있다 |
| 06-04 | 3 | push gate 뒤 한 줄 push, HEAD 의 CI `success` · 평소 모드 줄 | ✓ VERIFIED | run 38690710677 (`704bf56`, push, `success`). tag 트리를 절대 경로 꼴로 grep 하면 GitHub runner 의 상태 폴더 경로 두 줄(spike 기록)만 나온다 — 비공개 경로 아님 |
| 06-04 | 4 | 예행 smoke — 릴리스 커밋 = tag 를 달 커밋 | ✓ VERIFIED | tag 가 가리키는 커밋 = `704bf56` = 06-04 의 릴리스 커밋. 그 커밋을 GitHub 에서 받은 smoke 가 rc 0 이다 (이번 `v2.0.0` 실행 — 같은 커밋) |
| 06-04 | 5 | D-14 측정 | ✓ VERIFIED | 06-02 #1 의 재측정과 같은 결과다 |
| 06-05 | 1 | 로컬 annotated tag 가 예행 통과 커밋을 가리키고 4중 점검 통과 | ✓ VERIFIED | `cat-file -t` = `tag`, `^{commit}` = `704bf56…`, `version: 2.0.0`, `## 2.0.0 - 2026-10-15`. tag 객체의 tagger 시각은 tag 를 단 시각(2026-10-15T08:17:28Z)과 같다 |
| 06-05 | 2 | 소유자 `tag` 응답 뒤에만 push | ✓ VERIFIED | 소유자 응답 03:15:24Z (orchestrator 기록) 보다 tag 실행 생성 03:16:11Z 가 늦다. 요청 문안과 손 따라 하기 대조표가 06-05-SUMMARY 에 있다 |
| 06-05 | 4 | tag push 의 CI 실행이 tag 모드로 10/10 | ✓ VERIFIED | SC1 의 "걸려 있음" 증거와 같다 |
| 06-05 | 6 | 올린 tag 를 옮기거나 지우지 않음 | ✓ VERIFIED | 원격 tag 객체 `753f520…` 는 SUMMARY 기록과 같고 `704bf56` 을 가리킨다 |
| 06-06 | 1 | PR 의 `pull_request` 실행 `success` · 로그 두 줄 | ✓ VERIFIED | PR #1 (MERGED). run 38845784725 `pull_request` `success`, 로그에 평소 모드 줄과 10/10 |
| 06-06 | 2 | 소유자 `merge` 응답 뒤에만 `gh pr merge --merge` | ✓ VERIFIED | 소유자 응답 04:25:06Z (orchestrator 기록) 보다 `mergedAt` 04:26:05Z 가 늦다 |
| 06-06 | 3 | `origin/main` 머리가 부모 둘인 merge commit, `v2.0.0` 이 조상, 작업 브랜치 남음 | ✓ VERIFIED | `5ee5a12` 의 부모는 `90a2736` · `ad09d6e` 이다. `merge-base --is-ancestor` 가 참이다. `--heads` 에 작업 브랜치가 있다. `v2.0.0..origin/main` 의 `.planning` 밖 diff 는 없다 |
| 06-06 | 4 | `gh workflow run` 의 `workflow_dispatch` 실행 `success` (버튼은 사람) | ✓ VERIFIED | run 38850984674 `workflow_dispatch` `main` `success`, 로그에 평소 모드 줄과 10/10. 버튼은 Human Verification 1번 |
| 06-06 | 5 | `main` push 실행 `success` | ✓ VERIFIED | run 38850611790 `push` `main` `success`, 10/10 |
| 06-07 | 1 | `02-UAT.md` 4 · 6번 pass, `passed: 9` · `skipped: 0`, `closed_in` | ✓ VERIFIED | 56 · 59 · 69 · 74행 |
| 06-07 | 2 | `05-UAT.md` 1 · 2 · 4 · 5 의 `closed_in` | ✓ VERIFIED | `closed_in:` 4건 |
| 06-07 | 3 | `05-REVIEW-DISPOSITION.md` IN-12 ~ IN-14 fixed, `open: 0`, deferred 는 WR-06 하나 | ✓ VERIFIED | 144 ~ 146 · 126 · 135행. sha `971a6f2` · `704bf56` 은 실재한다 |
| 06-07 | 4 | 세 파일에서 처리 기록 밖의 줄은 그대로 | ✓ VERIFIED | `5ceead2` 는 disposition 3줄과 표 3행만 바꿨다. `41785ad` 는 02-UAT 8+/6-, 05-UAT 4+ 이다 |

**Score:** 40/41 truths verified (0 present, behavior-unverified)

### Deferred Items

없다. Phase 6 이 마지막 phase 이고, Backlog 999.1 (Phase 01 UAT Test 8) 은 이 gap 과 관계가 없다.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `tool/verify.dart` | `[3/10]` (i) `checkVersionAgreement`, `--tag`, `GITHUB_REF_*`, 모드 줄 | ⚠️ VERIFIED (결함 있음) | 있고 연결되어 있으며 CI 의 tag 실행에서 실제로 불렸다. reader 두 개(`pubspecVersionText` · `changelogTop`)가 실제 해석기와 갈린다 — gap |
| `tool/smoke.dart` | 릴리스 smoke | ✓ VERIFIED | 762줄. 통과 · 실패 방향을 둘 다 직접 돌렸다 |
| `.github/workflows/verify.yml` | 필터 없는 `push:` 와 7행 주석 | ✓ VERIFIED | tag 커밋에서 확인했다 |
| `example/README.md` | M92 ~ M97, 종료 코드 표 | ✓ VERIFIED | 632행 소절, 115행 |
| `README.md` · `VERSIONING.md` | D-14 문장, 「릴리스 절차」 | ✓ VERIFIED | 위 표 |
| `pubspec.yaml` · `CHANGELOG.md` · lock 여섯 (tag 커밋) | `2.0.0` · 날짜 제목 · `version: "2.0.0"` | ✓ VERIFIED | `git show v2.0.0:…` |
| `refs/tags/v2.0.0` (origin) | annotated tag → 릴리스 커밋 | ✓ VERIFIED | `ls-remote` 두 줄 |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `verify.dart` main | `checkShippedComposition(repoRoot, tag: effectiveTag)` | `--tag` → `GITHUB_REF_TYPE == tag` 의 `GITHUB_REF_NAME` | ✓ WIRED | 3037행. c1 (`--tag`) · c4 (환경변수) 가 (i) 블록을 냈다 |
| `checkVersionAgreement` | `pubspec.yaml` · `CHANGELOG.md` | `pubspecVersionText` · `pubspecReleaseVersion` · `changelogTop` | ⚠️ WIRED (읽는 값이 해석기와 다를 수 있음) | gap 의 자리 |
| `refs/tags/v2.0.0` (origin) | GitHub `verify` (tag) | 필터 없는 `push:` | ✓ WIRED | run 38844667011 |
| `refs/tags/v2.0.0` (origin) | smoke 빈 프로젝트의 lock | `ref: v2.0.0` → `resolved-ref` | ✓ WIRED | `resolved-ref 704bf56…` = `rev-parse 'v2.0.0^{commit}'` |
| `refs/tags/v2.0.0` | `origin/main` 이력 | `gh pr merge --merge` | ✓ WIRED | 조상 확인 |
| `.github/workflows/verify.yml` (`main`) | `workflow_dispatch` 실행 | 기본 브랜치의 workflow 파일 | ✓ WIRED | run 38850984674 |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| `checkVersionAgreement` (tag 모드) | `text` (pubspec 원문) | `pubspecVersionText` — 열 0 `version:` 첫 줄 | 대부분의 입력에서는 YAML 과 같다. 여러 줄 스칼라 안의 열 0 줄에서는 YAML 과 다르다 | ⚠️ 해석기와 갈림 (gap) |
| `checkVersionAgreement` | `top` (CHANGELOG 최상단) | `changelogTop` — `## ` 로 시작하는 첫 줄 | HTML 주석 · 펜스 안의 줄을 제목으로 읽고, 들여 쓴 ATX · setext 는 건너뛴다 | ⚠️ 렌더와 갈림 (gap) |
| smoke `judge` | 진단 줄 | 받은 프로젝트의 `dart analyze --format=json` | 예 — 실제 분석 결과 | ✓ FLOWING |

### Behavioral Spot-Checks

모두 임시 복사본에서 돌린 전체 실행이다 (`fvm dart run tool/verify.dart …`). 함수 단위 탐침은 따로 적었다.

| # | 입력 | 명령 | Result | Status |
|---|------|------|--------|--------|
| — | HEAD 그대로 | 평소 / `--tag v2.0.0` | 둘 다 rc 0 · 10/10, 모드 줄 각각 | ✓ PASS |
| c1 | tag 이름만 다름 | `--tag v2.0.1` | rc 1, `[3/10]` 만, 블록 둘 (pubspec · CHANGELOG) | ✓ PASS (실패 방향) |
| c4 | CI 환경변수, tag 이름 다름 | `GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v2.0.1` | rc 1, `(GITHUB_REF_NAME)` 모드 줄, 같은 블록 둘 | ✓ PASS (실패 방향) |
| c2 | `version: 2.0.0-dev` + lock 다시 받기 | `--tag v2.0.0` | rc 1, `-dev` 꼬리 블록 (`[4/10]` 동반 실패는 실험 부산물 — 위 「확인 방법」) | ✓ PASS (실패 방향) |
| c3 | CHANGELOG 1행 `## 2.0.1 - …` | `--tag v2.0.0` / 평소 | 둘 다 rc 1, `[3/10]` 만 | ✓ PASS (실패 방향) |
| c5b | **CR-01** — 겹따옴표 여러 줄 스칼라 안의 열 0 `version: 2.0.0`, 실제 키는 `version: 2.0.0-dev`, lock 은 `fvm dart pub get` (lock `version: "2.0.0-dev"`, `loadYaml` = `2.0.0-dev`) | `--tag v2.0.0` / CI 환경변수 | **둘 다 rc 0 · `점검 통과 (10개 중 10개)`** | ✗ FAIL (거짓 통과) |
| cA2 | **HTML 주석 안의 열 0 `## 2.0.1 - 2026-10-20`**, 렌더된 최상단은 `## 2.0.0 - 2026-10-15`; pubspec `2.0.1` · lock 여섯 · README `ref: v2.0.1` (새 릴리스 상태) | `--tag v2.0.1` | **rc 0 · 10/10** (README `ref:` 를 고치기 전에는 (g) 블록 하나로 rc 1 — (i) 블록은 없었다) | ✗ FAIL (거짓 통과) |
| c6 | **WR-02** — 맨 앞에 공백 1칸 ` ## 2.1.0 - 미출시`, pubspec `2.0.0` | 평소 / `--tag v2.0.0` | **둘 다 rc 0 · 10/10** | ✗ FAIL (평소 모드 거짓 통과; tag 모드는 옛 버전 tag 로만 통과) |
| c7 | **WR-02** — 맨 앞에 setext `2.1.0 - 미출시` / `---` | 평소 | **rc 0 · 10/10** | ✗ FAIL (거짓 통과) |
| 탐침 | 펜스 블록 안의 `## 2.0.1 - …` (함수 단위) | `checkVersionAgreement(tag: 'v2.0.1')` | 블록 0, `top=2.0.1` | ✗ FAIL (HTML 주석과 같은 꼴) |
| 탐침 | U+FEFF 머리 + `## 2.0.1 - …` (함수 단위) | `checkVersionAgreement(tag: 'v2.0.1')` | 블록 0, `top=2.0.1` — 최상단을 바르게 읽었다 | ✓ PASS (WR-02 의 U+FEFF 부분은 재현되지 않음) |
| — | 사용법 | `verify.dart --tag` · `--bogus` · `--tag v2.0.0 extra` | 셋 다 rc 64 · 사용법 줄 | ✓ PASS |
| — | smoke 통과 | `smoke.dart v2.0.0` | rc 0, 50초 | ✓ PASS |
| — | smoke 실패 방향 | `smoke.dart v1.3.0` · `no-such-ref-xyz` · 인자 없음 | rc 1 · 69 · 64 | ✓ PASS |
| — | D-14 측정 | 받은 v2.0.0 에 `base.yaml` + README 블록, 새 상태 폴더로 `dart analyze` | `provider_parameters` 있음, `missing_provider_scope` 없음 | ✓ PASS |
| — | tool 품질 | `fvm dart analyze tool` · `dart format --set-exit-if-changed tool` | `No issues found!` · rc 0 | ✓ PASS |

### Probe Execution

해당 없음. `scripts/*/tests/probe-*.sh` 가 없고, 이 phase 의 계획도 probe 를 선언하지 않는다. 계획의 검증 수단인 `tool/verify.dart` 와 `tool/smoke.dart` 는 위에서 직접 돌렸다.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| REL-02 | 06-02 · 06-04 · 06-05 · 06-06 | 새 버전의 annotated tag 가 원격에 있어 `ref: vX.Y.Z` 로 고정할 수 있다 | ✓ SATISFIED | SC2. smoke 가 `ref: v2.0.0` 으로 받았다 (lock `resolved-ref` = tag 커밋) |
| REL-03 | 06-01 · 06-05 · 06-07 | tag · version · CHANGELOG 최상단 버전이 다르면 CI 가 실패한다 | ✗ BLOCKED (partial) | CI tag 트리거와 보통의 어긋남에서의 실패는 확인했다. 그러나 reader 가 해석기와 갈리는 입력(c5b · cA2 · c6 · c7)에서는 다른데도 통과한다 — gap |
| REL-04 | 06-02 · 06-03 · 06-04 · 06-05 · 06-07 | 릴리스 직후 빈 프로젝트에서 새 tag 를 받아 기본 규칙 · plugin 진단 확인 | ✓ SATISFIED | SC3 (직접 실행) |

REQUIREMENTS.md 가 Phase 6 에 매핑한 ID 는 REL-02 · REL-03 · REL-04 셋이다. 모두 하나 이상의 plan frontmatter 에 있어 ORPHANED 는 없다. 체크 표시(`[ ]` → `[x]`)는 orchestrator 가 한다 — REL-03 은 gap 이 닫힌 뒤에 한다.

### Prohibitions (판정 등급 25건 — LLM 판정, 비권위)

모든 `MUST NOT` 은 `verification` 이 없는 judgment 등급이다. 아래는 증거로 본 판정이고, 사람 검토를 권한다 (Human Verification 2번).

| Plan | 항목 | 판정 | 근거 |
|------|------|------|------|
| 06-01 | 새 단계 `[11/11]` 를 두지 않음 · `verify.yml` 은 7행만 | 지켜짐 | 출력은 `[1/10]` ~ `[10/10]` 이고, `diff` 는 7행만 다르다 |
| 06-01 | tag 모드에서 꼬리 뗀 값으로 견주지 않음 · `pubspecReleaseVersion` 동작 그대로 | 지켜짐 | 2236행이 `text` (원문) 와 견주고, c2 가 `-dev` 를 잡았다. 이 금지 자체는 지켜졌지만, 원문 reader 가 YAML 과 갈리는 것이 gap 이다 |
| 06-01 | IN-14 에 catch 를 더하지 않음 · IN-12 는 한 곳만 | 지켜진 것으로 보임 | 2059행 주석만 있다. `keyLikePattern` 3곳 |
| 06-01 | 지워 보기는 복제본에서 · 기록에 경로 없음 | 판정 불가 (과정) | 기록 문서에서는 경로를 찾지 못했다 |
| 06-01 · 06-02 | 다른 plan 의 파일을 바꾸지 않음 | 지켜진 것으로 보임 | 릴리스 커밋 `704bf56` 이 version · lock · CHANGELOG · VERSIONING 을 한 번에 바꿨다 |
| 06-02 | README 에 새 펜스 · 다른 `package:` 주소를 더하지 않음 | 지켜진 것으로 보임 | verify (e) · (f) · (g) 가 10/10 이다 |
| 06-02 | VERSIONING 의 82행 밖 기존 줄을 고치지 않음 · `RELEASING.md` 없음 · `pub upgrade` 단계 없음 | 지켜진 것으로 보임 | `RELEASING.md` 가 없다. 2번 단계가 `pub upgrade` 를 하지 않는다고 적는다 |
| 06-03 | verify 에 넣지 않음 · CI job 없음 · verify import 없음 · 새 의존성 없음 | 지켜짐 | import 두 줄. `verify.yml` 은 job 하나 그대로 |
| 06-03 | 평소 pub cache · 기본 analyzer 상태 폴더 · 저장소 안을 쓰지 않음 | 지켜짐 | 코드 472 ~ 473 · 607 · 626행. 실행 뒤 작업 트리에 변화가 없었다 |
| 06-03 | 기반 세트 규칙을 기본 규칙 위반으로 쓰지 않음 | 지켜짐 | 판정은 `prefer_single_quotes` (base.yaml) 와 `provider_parameters` 다 |
| 06-03 | 화면 · SUMMARY 에 임시 경로 없음 · GitHub 에 올리지 않음 | 지켜짐 (화면) | `--keep` 이 아니면 경로가 안 나온다 |
| 06-04 | lock 은 `pub get` 으로만 · pubspec 다른 줄 그대로 · VERSIONING 은 67 · 69행만 | 지켜진 것으로 보임 | lock 마다 1줄, pubspec 2줄, VERSIONING 2줄 |
| 06-04 | tag 를 만들지 않음 · `main` 그대로 · push 한 줄 | 판정 불가 (과정) | 원격 상태는 기록과 맞는다 |
| 06-04 | 비공개 점검 0 이 아니면 올리지 않음 · 날짜를 다시 고치지 않음 · 예행 커밋에만 tag | 지켜진 것으로 보임 | CHANGELOG 날짜는 `2026-10-15` (tag 를 단 날과 같다) 이고, tag 커밋 = 예행 커밋이다 |
| 06-05 | 소유자 `tag` 전에 push 안 함 · tag 이름 하나만 · 옮기지 않음 | 지켜짐 | 시각 순서, `--heads` 에 tag 와 함께 올라간 브랜치가 없다, tag 객체가 그대로다 |
| 06-05 | 예행 커밋 밖에 tag 를 달지 않음 · `main` 그대로 · 파일 변경 없음 | 지켜짐 | `704bf56` |
| 06-05 · 06-06 | SUMMARY 에 경로 없음 · checkpoint 자동 승인 없음 | 판정 불가 (과정) | 소유자 응답 시각이 orchestrator 기록에 있다 |
| 06-06 | `merge` 전에 병합 안 함 · `--squash` · `--rebase` · `--delete-branch` 없음 | 지켜짐 | 부모 둘, 작업 브랜치가 남아 있다, 시각 순서 |
| 06-06 | push gate 뒤 한 줄 push · PR 본문에 경로 없음 | 판정 불가 (과정) | — |
| 06-06 | 저장소 파일 · `verify.yml` 을 바꾸지 않음 | 지켜짐 | `v2.0.0..origin/main` 의 `.planning` 밖 diff 가 없다 |
| 06-07 | 처리 기록 밖의 줄 · WR-06 · REQUIREMENTS 를 바꾸지 않음 | 지켜짐 | 위 06-07 #4. REQUIREMENTS 의 REL 셋은 아직 `[ ]` 이다 |
| 06-07 | 기록에 경로 없음 · push 하지 않음 | 지켜진 것으로 보임 | — |

### Code Review 발견의 판정 (06-REVIEW.md — 등급을 물려받지 않고 다시 갈랐다)

| ID | 주장 | 이번 확인 | 판정 |
|----|------|-----------|------|
| CR-01 | 여러 줄 스칼라 안의 열 0 `version:` 줄로 `--tag` 전체 실행이 거짓 통과한다 | 재현: c5b 의 `--tag` 와 CI 환경변수 경로 모두 rc 0 · 10/10 (lock 은 `fvm dart pub get` 으로만) | **gap** — REL-03 문장이 거짓이 되는 입력이다. v2.0.0 은 해당 없음 |
| WR-01 | smoke 가 include 사슬의 끊김을 판정에 넣지 않는다 | 코드 확인: `judge` 는 위반 두 줄만 본다. v2.0.0 smoke 출력에는 `analysis_options.yaml:` 줄이 없다 | **경고** — REL-04 · SC3 는 기본 규칙 · plugin 진단만 요구하고, smoke 는 그것을 판정한다. 옛 주소의 codegen 부분은 같은 커밋의 CI `[5/10]` 정답지 비교가 본다. 그래도 smoke 가 이미 화면에 찍은 실패 신호를 버리는 것은 고칠 만하다 |
| WR-02 | `changelogTop` 이 들여 쓴 ATX · setext · U+FEFF 를 놓친다 (평소 모드만 뚫림) | 들여 쓴 ATX · setext 는 재현됐다 (c6 · c7 평소 rc 0). U+FEFF 는 재현되지 않았다 (최상단을 바르게 읽음). **같은 reader 에서 더 큰 꼴을 찾았다** — HTML 주석 · 펜스 블록 안의 열 0 `## ` 줄 때문에 새 tag 의 tag 모드가 통과한다 (cA2) | **gap** (CR-01 과 같은 gap 으로 묶었다) — "tag 모드는 뚫리지 않는다" 는 reviewer 판단은 이 꼴에서 틀렸다 |
| WR-03 | smoke 하위 명령에 시간 제한이 없다 | 코드 확인 (`Process.run`) | 경고 — 진실을 거짓으로 만들지 않는다 (운영 문제) |
| IN-01 · IN-02 | smoke 정리 · 판정 조건 중복 | 확인하지 않음 | info |
| IN-03 | version reader 가 둘로 갈렸다 | 코드 확인 (1606 · 1633행) | info — gap 을 고칠 때 함께 합치기를 권한다 |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `tool/verify.dart` | 1633 ~ 1647 | 줄 단위 reader 의 원문을 해석기 값과 대조하지 않고 tag 모드 판정에 씀 | 🛑 Blocker | REL-03 거짓 통과 (gap) |
| `tool/verify.dart` | 1657 ~ 1677 | Markdown 구조(주석 · 펜스 · 들여 쓴 제목 · setext)를 모르는 첫 `## ` 줄 찾기 | 🛑 Blocker | REL-03 거짓 통과 (gap) |
| `tool/smoke.dart` | 497 ~ 518 | include 오류 진단을 판정에서 버림 | ⚠️ Warning | WR-01 |
| `tool/smoke.dart` | 274 ~ 289 | 시간 제한 없는 `Process.run` | ⚠️ Warning | WR-03 |
| `example/README.md` | (06-01 소절) | `TBD` 2건 | ℹ️ Info | 실험 입력 값(날짜 자리 `TBD`)을 적은 문장이다 — debt marker 가 아니다 |

### Human Verification Required

### 1. Actions 의 `Run workflow` 버튼

**Test:** GitHub 의 Actions → `verify` 화면을 연다.
**Expected:** `Run workflow` 버튼이 보인다 (실행 자체는 run 38850984674 가 `success` 로 확인했다).
**Why human:** 웹 화면의 버튼 표시는 CLI 로 볼 수 없다.

### 2. 판정 등급 prohibition 25건

**Test:** 위 「Prohibitions」 표를 훑는다.
**Expected:** 판정에 동의하거나, 다르게 보는 항목을 적는다.
**Why human:** 시행 증거(test)가 없는 judgment 등급이라 자동 판정은 권위가 없다.

### Gaps Summary

**v2.0.0 에 관해 사실인 것.** 원격에 annotated tag `v2.0.0` 이 있다 (→ `704bf56`). 그 커밋의 version · CHANGELOG 는 tag 이름과 같고, reader 를 속이는 꼴도 아니다. tag push 의 CI 는 tag 모드로 10/10 을 냈다. 빈 프로젝트가 `ref: v2.0.0` 으로 받아 두 주소 모두에서 규칙 · plugin 진단을 냈다. `main` 병합(merge commit, tag 가 조상)과 PR · dispatch · `main` push 실행도 확인했다. 목표 문장의 앞부분("annotated tag 로 원격에 있어 고정할 수 있고 … 적용됨이 확인되어 있다")은 이루어졌다.

**gap — 다음 릴리스의 gate 가 거짓 통과할 수 있다 (REL-03 · SC1).** 원인은 하나다. `[3/10]` (i) 가 version 을 해석기와 따로 줄 단위로 읽고, 그 값을 실제 해석기(YAML · Markdown)가 읽는 값과 대조하지 않는다.
- pubspec 쪽 (CR-01): `pubspecVersionText` 는 열 0 의 첫 `version:` 줄을 읽는다. (h) 는 꼬리 뗀 값만 YAML 과 견주므로, 여러 줄 스칼라 안에 숨은 `version: 2.0.0` 이 실제 `2.0.0-dev` 를 가린다.
- CHANGELOG 쪽: `changelogTop` 은 첫 `## ` 줄을 읽는다. 그래서 HTML 주석 · 펜스 안의 줄을 제목으로 잡는다 — 새 tag 의 tag 모드가 뚫린다. 들여 쓴 ATX · setext 제목은 건너뛴다 — 평소 모드가 뚫린다.

앞 phase 들의 gap (05 의 여러 줄 스칼라 · 중복 키)과 같은 꼴이다. reader 가 한 입력은 막고, 같은 꼴의 다른 입력은 놓친다.

**gap 계획에 권하는 것 (입력 하나가 아니라 꼴을 닫기).**
1. pubspec version 은 `package:yaml` 이 읽은 `version` 값 하나에서 얻는다. 줄 단위 reader 를 남긴다면 원문 전체를 YAML 값과 견주고, 다르면 실패하게 한다 (05 의 길 B 와 같은 방식). IN-03 대로 두 reader 를 합친다.
2. CHANGELOG 최상단은 렌더 결과와 같게 읽는다. 방법은 둘이고, 고르는 것은 소유자 결정이다.
   - (가) Markdown 해석기를 dev 의존성으로 더한다 — G4-Q1 처럼.
   - (나) fail-closed — 첫 엄격한 `## X.Y.Z - …` 줄 앞에 주석 여는 줄 · 펜스 여는 줄 · 0 ~ 3칸 들여 쓴 `#` 제목 · setext 밑줄이 있으면 실패하게 한다.
3. 실패 방향을 꼴 단위로 기록 · 단언한다. 따옴표 두 종류의 여러 줄 스칼라, HTML 주석, 펜스 두 종류, 들여 쓴 ATX 1 ~ 3칸, setext 두 종류, U+FEFF 를 평소 · `--tag` · `GITHUB_REF_NAME` 세 경로에서 본다. 함께 "그럴듯한 틀린 구현"(예: YAML 값을 읽되 꼬리를 떼고 견주는 판)이 단언에 걸리는지도 본다.
4. 고침은 저장소 안쪽만 바꾼다. 새 버전 번호는 필요 없다. 다음 릴리스(`v2.0.1` 이든 `v2.1.0` 이든) 전에 닫는다.

경고(WR-01 · WR-03)는 gap 이 아니다. 같은 gap 계획에서 함께 고칠지는 소유자가 정한다.

---

_Verified: 2026-10-16T05:39:35Z_
_Verifier: Claude (gsd-verifier)_
