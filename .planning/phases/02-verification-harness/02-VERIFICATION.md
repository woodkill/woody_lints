---
phase: 02-verification-harness
verified: 2026-10-11T17:55:13Z
status: gaps_found
score: 23/26 must-haves verified
covered_files:
  - ".fvmrc"
  - ".github/workflows/verify.yml"
  - ".gitignore"
  - ".planning/phases/02-verification-harness/02-01-PLAN.md"
  - ".planning/phases/02-verification-harness/02-01-SUMMARY.md"
  - ".planning/phases/02-verification-harness/02-02-PLAN.md"
  - ".planning/phases/02-verification-harness/02-02-SUMMARY.md"
  - ".planning/phases/02-verification-harness/02-03-PLAN.md"
  - ".planning/phases/02-verification-harness/02-03-SUMMARY.md"
  - ".planning/phases/02-verification-harness/02-04-PLAN.md"
  - ".planning/phases/02-verification-harness/02-04-SUMMARY.md"
  - "CHANGELOG.md"
  - "analysis_options.yaml"
  - "example/README.md"
  - "example/analysis_options.yaml"
  - "example/expected_diagnostics.txt"
  - "example/lib/added_rules.dart"
  - "example/lib/base_rules.dart"
  - "example/lib/generated/sample.freezed.dart"
  - "example/lib/generated/sample.g.dart"
  - "example/lib/main.dart"
  - "example/lib/riverpod_rules.dart"
  - "example/lib/should_not_appear.dart"
  - "example/pubspec.lock"
  - "example/pubspec.yaml"
  - "lib/analysis_options.yaml"
  - "pubspec.yaml"
  - "tool/verify.dart"
covered_digest: "v3:sha256:50a0a23c9219c0b81673fbe333236d2b8f083bc92cf7e1b880c1a14e48138c57"
behavior_unverified: 1
overrides_applied: 0
gaps:
  - truth: "소유자가 저장소 루트에서 명령 하나를 실행하면 example/ 의 분석 결과가 커밋된 기대 진단 파일과 비교되어, 같으면 성공하고 다르면 실패한다. 기대 진단에는 이 패키지가 추가한 규칙, 기반 세트 규칙, riverpod_lint 진단이 각각 한 건 이상 들어 있다 (ROADMAP 성공 기준 1)"
    status: partial
    reason: "정답지 비교가 줄의 있고 없음만 견주고 건수를 세지 않는다. 같은 줄(상대경로:줄 강도 규칙이름)이 두 번 이상 걸리는 입력에서는 경고가 한 건 생기거나 사라져도 종료 코드 0 으로 통과한다 (복사본에서 세 방향 모두 재현). 지금 커밋된 정답지 16줄은 모두 서로 다른 줄이라 현재 저장소에서는 틀린 판정이 나오지 않고, 줄이 생김 / 사라짐 / 강도 변경 / 종료 코드 변경은 모두 실행으로 실패를 확인했다. 성공 기준의 둘째 문장(세 종류가 각각 한 건 이상)은 실행으로 확인됐다"
    artifacts:
      - path: "tool/verify.dart"
        issue: "findDifference (462-481행) 의 477-478행이 expectedLines.where((l) => !actual.contains(l)) 와 그 반대 방향만 본다 — 집합 비교라 같은 줄의 건수 차이가 보이지 않는다"
      - path: "example/README.md"
        issue: "5행 '한 줄이라도 다르면 실패다' 와 65행 '경고가 생기거나, 사라지거나 … 검증이 실패한다' 가 같은 줄이 여러 건인 경우에는 사실과 다르다"
    missing:
      - "건수를 세는 비교 — 정답지에서 실제 줄을 건수만큼 빼고, 실제에서 정답지 줄을 건수만큼 뺀 나머지를 빠진 줄 / 남는 줄로 삼는다"
      - "같은 줄이 두 번 나오는 입력(한 줄에 같은 규칙 2건, 정답지에 같은 줄 2개)에서 검증이 실패함을 확인한 실행 기록"
behavior_unverified_items:
  - truth: "workflow 의 권한은 contents: read 뿐이고, 겹치는 실행은 concurrency 로 취소된다 (plan 02-04)"
    test: "같은 브랜치에 커밋을 연달아 두 번 올려, 앞선 verify 실행이 진행 중일 때 뒤 실행이 시작되게 한다"
    expected: "앞선 실행이 cancelled 로 끝나고 뒤 실행만 끝까지 돈다"
    why_human: "concurrency 블록은 파일에 있고 YAML 로 읽히지만(group, cancel-in-progress: true), 이 workflow 의 실행은 지금까지 한 번뿐이라 취소가 일어난 적이 없다. 권한 쪽은 그 한 번의 로그(GITHUB_TOKEN Permissions: Contents: read, Metadata: read)로 확인됐다"
coincidental_reliance_items:
  - truth: "명령 한 번으로 단계 4개가 모두 통과하고 종료 코드 0 이다 (VERIFY-03)"
    reason: undeclared-precondition
    harden: "정답지의 riverpod_lint 3줄은 배포 파일의 ^3.1.3 이 실행 시점에 3.1.9 로 풀린다는 전제에 기댄다. example/pubspec.lock 은 plugin 버전을 묶지 못한다. Phase 3 의 D6 (caret 유지 / 정확한 버전 고정) 에서 전제를 선언하거나 묶는다"
  - truth: "화면 맨 위에 실제로 쓰인 버전 세 줄이 찍힌다 (D-07)"
    reason: undeclared-precondition
    harden: "plugin 줄은 전용 상태 폴더에 남은 값을 읽는다. include 를 지운 실행에서도 riverpod_lint 3.1.9 가 찍혔다 (그 실행에는 plugin 진단이 없었다). example/README.md 131행이 이 한계를 적어 두었지만 코드가 지키는 것은 아니다 — plugin 진단이 실제로 나온 실행에서만 '쓰인 버전' 으로 찍거나, 줄의 뜻을 '상태 폴더 기준' 으로 표시한다"
---

# Phase 2: Verification Harness 검증 보고서

**Phase Goal:** `lib/` 를 바꾸기 전에 1.3.0 의 동작이 기대 진단(golden)으로 고정되어 있고, 소유자와 CI 가 같은 명령 하나로 "배포 설정이 기대한 대로 적용되는가"를 판정할 수 있다
**Verified:** 2026-10-11T17:55:13Z (한국 시각 2026-10-12 02:55), HEAD `f7c6f7c`, 브랜치 `gsd/v2.0-package-rework`
**Status:** gaps_found
**Re-verification:** No — initial verification

## 한눈에

- **목표의 대부분은 실행으로 확인됐다.** 1.3.0 (`lib/` == `90a2736`) 의 동작이 정답지 16줄로 고정되어 있고, 검증 명령 하나가 로컬과 GitHub 에서 같은 화면을 낸다. 내가 직접 만든 변경 19가지(저장소 11, 복사본 8)에서 검증이 예상한 단계로 실패했다.
- **gap 1건.** 정답지 비교가 건수를 세지 않는다. 같은 줄이 두 번 이상 걸리는 입력에서 "다른데 통과" 가 재현된다 (종료 코드 0). 로드맵 성공 기준 1 의 "다르면 실패한다" 와 소유자 결정 D-04 의 "경고가 생기거나 사라질 때 실패한다" 가 그 입력에서는 성립하지 않는다. 지금의 fixture 와 정답지에서는 틀린 판정이 나오지 않는다.
- **이 환경에서 확인할 수 없는 것**: pull request 트리거, 수동 실행 버튼, concurrency 취소, 화면과 기록이 소유자에게 읽히는지. 아래 "사람 확인이 필요한 것" 에 모았다.
- 코드 리뷰(02-REVIEW.md)의 14건 중 실행으로 재현해 볼 수 있는 것은 모두 재현했다. 판정을 틀리게 만드는 것은 CR-01 하나였고, 나머지는 "전체 판정은 실패로 맞지만 안내가 틀리거나 약한" 종류다.

이 보고서는 진술을 세 가지로 나눠 적는다.

| 표시 | 뜻 |
|------|----|
| **실행** | 내가 이 검증에서 명령을 돌려 출력과 종료 코드를 본 것 |
| **읽기** | 파일을 읽거나 grep / 파서로만 확인한 것 (동작을 일으켜 보지 않음) |
| **확인 불가** | 이 환경에서는 일으킬 수 없어 사람이 봐야 하는 것 |

## Goal Achievement

### Observable Truths

로드맵 성공 기준 5개(1~5)가 계약이고, 계획 4개의 must_haves.truths 를 중복을 빼고 더했다(6~26).

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | (SC 1) 명령 하나로 `example/` 분석 결과가 정답지와 비교되어 같으면 성공, 다르면 실패. 정답지에 추가 규칙 · 기반 세트 규칙 · `riverpod_lint` 진단이 각각 한 건 이상 | ✗ FAILED (부분) | **실행**: 같으면 성공 — exit 0, `점검 통과 (4개 중 4개)`. 다르면 실패 — 줄이 사라짐(추가 규칙 6개 각각, include 삭제), 줄이 생김(errors 블록 · exclude 2종 삭제), 강도 변경, 종료 코드 변경 모두 exit 1. 세 종류 각 한 건 이상 — 추가 규칙 6줄 · 기반 세트만의 `prefer_is_empty` 1줄 · `riverpod_lint` 3줄. **그러나** 같은 줄의 건수 차이는 exit 0 으로 통과한다 (복사본 실행 3건, 아래 Gap 1) |
| 2 | (SC 2) 배포 파일에 deprecated / removed / 없는 규칙을 하나 넣으면 같은 명령이 실패 | ✓ VERIFIED | **실행**: `unnecessary_await_in_return` → `[2/4]` 실패 `deprecated_lint`, exit 1. `avoid_returning_null` → `removed_lint`, exit 1. `no_such_rule_verifier_probe` → `undefined_lint` (+ `[4/4]` 도 `included_file_warning` 으로 실패), exit 1. 세 번 모두 되돌린 뒤 `lib` == `90a2736` |
| 3 | (SC 3) `lib/` 에 `.dart` 파일을 하나 두면 같은 명령이 실패 | ✓ VERIFIED | **실행**: `lib/_verifier_probe.dart` → `[1/4]` 실패 · 경로 표시 · exit 1. `lib/sub/deep/_verifier_probe.dart` (깊은 경로) 도 같은 결과. 지운 뒤 `lib` 의 `.dart` 0개 |
| 4 | (SC 4) 규칙 하나를 지운 변경과 include 줄을 지운 변경을 실제로 만들어 실패를 확인한 기록이 있다 | ✓ VERIFIED | **읽기**: `example/README.md` 82-137행 (M1 · M2 를 포함한 9행 표, 실측 조건, 되돌렸다는 문장). **실행**: M1 · M2 를 직접 다시 만들어 기록과 같은 화면을 봤다 (M1: 빠진 줄 1, exit 1 / M2: `[3/4]` · `[4/4]` 실패, 빠진 줄 16 · 남는 줄 1, exit 1, `dart analyze` 의 종료 코드는 2 그대로) |
| 5 | (SC 5) push 와 PR 마다 GitHub Actions 가 같은 명령을 실행하고 job 에 시간 제한이 있으며 실제로 성공한 실행이 한 번 이상 | ? UNCERTAIN (부분) | **실행(조회)**: `gh run view 38158088016` — workflow `verify`, event `push`, `1f06c558…`, `completed` / `success`, job 17:04:14Z ~ 17:06:08Z. 로그에 `Run dart run tool/verify.dart` 와 로컬과 같은 화면. `timeout-minutes` 는 YAML 파서로 숫자 10. **읽기**: `pull_request:` 가 필터 없이 선언됨. **확인 불가**: PR 에서의 실행 — PR 이 하나도 없다 (`gh pr list --state all` = 0) |
| 6 | 정답지는 `exit 2` + 16줄 — 배포 파일의 규칙 12개가 각 한 줄, `prefer_is_empty` 한 줄, `riverpod_lint` 세 줄(warning 2 · info 1) | ✓ VERIFIED | **실행**: `example/` 에서 `dart analyze --format=json` 을 스크립트와 따로 돌려 정규화한 16건이 정답지 16줄과 diff 없음 (건수 포함, 중복 줄 0). 규칙 이름 16개가 각 1회 |
| 7 | `invalid_annotation_target` 샘플과 생성 파일 샘플이 `example/` 에 있지만 정답지에 그 진단이 없다 (헛통과 아님) | ✓ VERIFIED | **읽기**: 샘플 3파일. **실행**: errors 블록 삭제 → `+ lib/should_not_appear.dart:5  warning  invalid_annotation_target`; `'**/*.g.dart'` 삭제 → `sample.g.dart:4` 2줄; `'**/*.freezed.dart'` 삭제 → `sample.freezed.dart:4` 2줄. 모두 exit 1 |
| 8 | `example/pubspec.lock` 이 커밋 대상이고 루트 `pubspec.lock` 은 무시된다 (D-05) | ✓ VERIFIED | **실행**: `git check-ignore example/pubspec.lock` rc=1, `git check-ignore -q pubspec.lock` rc=0, `git ls-files` 에 `example/pubspec.lock` 만 |
| 9 | `example/analysis_options.yaml` 은 include 한 줄이다 | ✓ VERIFIED | **읽기**: 파일 1줄. **실행**: `[3/4]` 통과 |
| 10 | 루트 `fvm dart analyze` 가 `No issues found` | ✓ VERIFIED | **실행**: `Analyzing woody_lints... No issues found!`. `fvm dart format --set-exit-if-changed tool example/lib` 도 바뀔 파일 0 |
| 11 | `lib/` 는 `90a2736` 과, `pubspec.yaml` · `README.md` 는 `968a5bb` 와 같고, 지워 보기의 임시 변경이 남지 않았다 | ✓ VERIFIED | **실행**: 두 `git diff --quiet` rc=0, `.fvmrc` = 3.47.5, `lib` 의 `.dart` 0개, `build/woody_rule_check` 없음. Phase 2 동안 `lib` · `.fvmrc` · `pubspec.yaml` · `README.md` 를 건드린 커밋 없음 (`git log 968a5bb..HEAD -- …` 에 `example/analysis_options.yaml` 을 만든 `ac5cced` 뿐) |
| 12 | 명령 한 번으로 단계 4개가 모두 돌고 `점검 통과 (4개 중 4개)`, 종료 코드 0 (VERIFY-03) | ✓ VERIFIED (coincidental-reliance) | **실행**: 저장소에서 exit 0 (5초). HEAD 를 새 폴더에 풀어 놓은 복사본에서도 exit 0 (plugin 처음 준비 포함 16초). `example/` 을 작업 폴더로 두고 실행해도 exit 0. plugin 버전이 3.1.9 로 풀린다는 전제는 `coincidental_reliance_items` 참조 |
| 13 | 규칙 검사는 배포 파일을 `plugins:` 없이 `build/woody_rule_check/` 에 복사해 분석하고 끝나면 지운다 | ✓ VERIFIED | **실행**: 실패 줄의 경로가 `build/woody_rule_check/analysis_options.yaml:41`. 통과한 실행과 실패한 실행 뒤 모두 `build/woody_rule_check` 없음. **읽기**: `tool/verify.dart` 589-670행 (`stripPlugins`, `try … finally`) |
| 14 | `example/` 옵션 파일이 include 한 줄이 아니면 `[3/4]` 가 실패 | ✓ VERIFIED | **실행**: 빈 파일 → 실패. `analyzer: exclude: build/**` 세 줄 추가(복사본) → 실패. 주석과 빈 줄만 추가(복사본) → 통과 |
| 15 | 실행 중인 SDK 가 `.fvmrc` 와 다르면 시작하지 않고 종료 코드 78 (D-12) | ✓ VERIFIED | **실행**: `.fvmrc` 를 `0.0.0` 으로 바꾸고 `.fvm/flutter_sdk/bin/dart run tool/verify.dart` → stdout 0바이트, 안내 두 줄, exit 78. **읽기만**: Flutter 밖의 dart 로 실행한 경우와 `FLUTTER_ROOT` fallback 경로 (284-297행) — 내가 일으켜 보지 않았다 |
| 16 | 화면 맨 위에 실제로 쓰인 버전 세 줄 (D-07) | ✓ VERIFIED (coincidental-reliance) | **실행**: stdout 첫 세 줄이 `SDK        Flutter 3.47.5 / Dart 3.13.4` · `기반 세트  flutter_lints 6.0.0 / lints 6.1.0` · `plugin     riverpod_lint 3.1.9`. CI 로그도 같다. plugin 줄이 그 실행의 값이 아닐 수 있는 점은 `coincidental_reliance_items` 참조 |
| 17 | 화면은 안내형이다 — 단계별 통과·실패, 두 목록, 단계마다 다른 다음 할 일, 요약 (D-13) | ✓ VERIFIED | **실행**: 구성 요소를 모두 화면에서 봤다 — 단계 1 · 2 · 3 · 4 각각의 실패 안내 문구가 다르다. plugin 준비 실패와 도구 사망의 안내는 **읽기만** (740-779행). "안내로 읽히는가" 는 **확인 불가** → 사람 확인 1 |
| 18 | `--update` 는 갱신 전에 줄 단위 변화를 보여 주고 머리 주석을 실제 버전·날짜로 다시 쓰며 CI 에서는 64 로 거부된다 (D-14) | ✓ VERIFIED | **실행(복사본)**: 바뀐 것 없음 → `정답지와 같다 — 바뀐 줄 없음`, 파일 sha 불변. 규칙 하나를 지운 뒤 → `- lib/added_rules.dart:24  info  prefer_final_locals` 를 보여 주고 그 줄만 빠진 정답지를 씀. `CI=true` 와 `GITHUB_ACTIONS=true` 각각 exit 64, stdout 0바이트, 정답지 sha 불변. 알려진 약점은 아래 리뷰 표의 WR-01 |
| 19 | `errors:` 블록과 exclude 2종을 지웠을 때 정답지와 달라졌다는 기록 (D-03) | ✓ VERIFIED | **읽기**: README 표의 M3 · M4 · M5. **실행**: 세 건을 다시 만들어 기록의 줄과 글자 그대로 같은 결과 |
| 20 | deprecated 규칙은 정답지 비교가 아니라 규칙 이름 단계가 잡는다는 기록 | ✓ VERIFIED | **읽기**: README 의 M6 과 128행. **실행**: `[2/4]` 실패 · `[4/4]` 통과 · exit 1 |
| 21 | 기록에 실측 조건과 실행한 명령이 있고 로컬 절대 경로나 토큰이 없다 (D-08) | ✓ VERIFIED | **읽기**: 86 · 88행. `grep -E '/Users/\|gho_\|ghp_\|github_pat_'` 가 `example/README.md`, `CHANGELOG.md`, `tool/verify.dart`, workflow, 정답지에서 0건 |
| 22 | CHANGELOG 2.0.0 항목에 `### 그 밖의 변경` 이 두 칸 사이에 있고 "사용하는 프로젝트에는 영향 없음" 과 함께 적혔다 | ✓ VERIFIED | **실행**: `git diff 968a5bb -- CHANGELOG.md` 가 더한 4줄뿐. 계획 02-03 Task 2 의 자동 검증 명령 원문 rc=0 |
| 23 | workflow 의 권한은 `contents: read` 뿐이고 겹치는 실행은 `concurrency` 로 취소된다 | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | 권한 — **실행(조회)**: CI 로그의 `GITHUB_TOKEN Permissions: Contents: read / Metadata: read`. concurrency — **읽기**: `group: ${{ github.workflow }}-${{ github.ref }}`, `cancel-in-progress: true`. 취소는 한 번도 일어나지 않았다 (이 workflow 의 실행은 1건) |
| 24 | 예약 실행 트리거, Flutter 버전 숫자, 캐시가 workflow 에 없다 | ✓ VERIFIED | **읽기**: 주석을 뺀 본문에서 `schedule:\|cron\|cache\|flutter-version:\|3\.47\.5\|matrix\|tags:\|secrets` 0건. step 은 3개 (`actions/checkout@v7`, `subosito/flutter-action@v2` + `flutter-version-file: .fvmrc`, `run: dart run tool/verify.dart`) |
| 25 | 작업 브랜치가 origin 에 올라갔고 `origin/main` 은 `90a2736`, tag 는 `v1.3.0` 하나 | ✓ VERIFIED | **실행(조회)**: `git ls-remote --heads origin` 2줄 (`1f06c558…` 작업 브랜치, `90a2736b…` main). `git ls-remote --tags origin` 은 `v1.3.0` 과 그 peeled 줄뿐. 원격 tip 은 HEAD 의 조상이고 그 뒤 로컬 전용 5커밋은 `.planning/` 밖을 바꾸지 않았다 |
| 26 | 그 커밋의 `verify` 실행이 `completed` / `success` 이고 로그에 버전 3줄, `[4/4] … 통과`, `점검 통과 (4개 중 4개)` | ✓ VERIFIED | **실행(조회)**: `gh run view 38158088016 --log` 의 192-201행. runner 이미지 `ubuntu-24.04` |

**Score:** 23/26 truths verified (1 present, behavior-unverified)

검증되지 않은 3건은 1번(부분 실패 — Gap 1), 5번(PR 쪽이 선언뿐 — 사람 확인 3), 23번(취소가 일어난 적 없음 — 사람 확인 5)이다.

### Gap 1 — 정답지 비교가 건수를 세지 않는다 (성공 기준 1, 부분)

**무엇이 틀리는가.** `tool/verify.dart` 의 `findDifference` 가 정답지 줄과 실제 줄을 "들어 있는가" 로만 견준다. 정답지 한 줄에는 열(column)이 없으므로, 한 줄에 같은 규칙이 두 번 걸리면 똑같은 줄 둘이 된다. 그 줄에서는 건수가 달라도 차이가 0 으로 계산된다.

**재현 (모두 scratch 의 복사본에서, 저장소는 건드리지 않았다).**

| 입력 | 실제 | 검증 결과 |
|------|------|-----------|
| 정답지 끝에 이미 있는 줄 `lib/base_rules.dart:22  info  avoid_print` 를 한 번 더 적음 | 정답지 17줄, 분석 16건 | `[4/4]` 통과, exit 0 |
| `example/lib/dup.dart` 에 `void twoPrints() { print('x'); print('y'); }`, 정답지에는 `lib/dup.dart:1  info  avoid_print` 한 줄만 | `dart analyze` 는 그 줄에서 `avoid_print` 2건 (column 20, 32) | `[4/4]` 통과, exit 0 — **경고가 한 건 생겼는데 통과** |
| 위 상태에서 `--update` 로 정답지에 두 줄을 적은 뒤, 샘플에서 `print` 하나를 지움 | 정답지 2줄, 분석 1건 | `[4/4]` 통과, exit 0 — **경고가 한 건 사라졌는데 통과** |
| 대조: 두 `print` 를 서로 다른 줄에 두고 정답지에 한 줄만 | 2건, 줄이 다름 | `[4/4]` 실패, exit 1 (정상) |

**어디까지 닿는가 (내 판단의 근거).**

- 지금의 저장소에서는 틀린 판정이 나오지 않는다. 정답지 16줄과 실제 16건이 모두 서로 다른 줄이다 (**실행**: 직접 분석한 결과의 중복 줄 0).
- 배포 파일(`lib/`)만 바꿔서는 이 구멍에 닿는 경로를 찾지 못했다. lint 규칙은 켜짐/꺼짐이라 같은 진단이 두 번 나오지 않고, plugin 을 두 파일에 겹쳐 선언한 복사본에서도 진단은 16건 그대로였다 (**실행**). 배포 파일의 문제는 `analysis_options.yaml:1  warning  included_file_warning` 이라는 같은 모양의 줄로 올라오지만, 정답지에 그 줄이 없는 한 "남는 줄" 로 잡힌다.
- 구멍이 열리는 것은 **fixture 나 정답지가 바뀔 때**다 — 한 줄에 같은 규칙이 두 번 걸리는 샘플, `--update` 가 적은 똑같은 줄 두 개, 손으로 고치거나 병합하다 겹친 정답지 줄. Phase 3 은 fixture 를 더하고 Phase 4 는 샘플과 정답지를 규칙마다 고친다.
- 그러므로 Phase 3 의 완료 기준("정답지가 한 줄도 바뀌지 않는다")은 지금의 16줄에 대해서는 이 비교로 판정할 수 있다. Phase 4 가 "한 줄에 규칙 하나" 관례를 벗어난 샘플을 만들면 그 줄에서만 건수 변화가 보이지 않는다.

**왜 warning 이 아니라 gap 으로 적었는가.** 성공 기준 1 은 조건 없는 문장("다르면 실패한다")이고, D-04 는 "경고가 생기거나 사라질 때 검증이 실패한다" 를 정답지 형식의 뜻으로 정했다. 그 두 문장이 성립하지 않는 입력이 종료 코드 0 으로 재현된다. 이 phase 의 중심 기능이고 `example/README.md` 가 반대로 적고 있어, 범위가 좁다는 이유로 통과로 올리지 않았다. 범위가 좁다는 사실은 위에 그대로 적었다.

**닫는 방법.** 고치는 쪽은 `findDifference` 의 두 줄을 건수를 세는 차집합으로 바꾸는 것이다 (02-REVIEW.md CR-01 에 예시 코드가 있다). 고치지 않고 받아들이려면 소유자가 이 파일의 frontmatter 에 override 를 적는다 — 그 경우 `example/README.md` 5행 · 65행의 문장과 "한 줄에 규칙 하나" 관례를 전제로 명시해야 문서와 동작이 맞는다. 어느 쪽인지는 소유자가 정한다.

### Deferred Items

없다. Gap 1 은 뒤 phase 의 목표나 성공 기준에 들어 있지 않다 (Phase 3 · 4 는 이 비교에 기대는 쪽이지 고치는 쪽이 아니다).

참고로 이 phase 의 일이 아니라고 로드맵이 정해 둔 것: 상시 대조군 fixture (Phase 3, VERIFY-05), `riverpod_lint` 버전을 묶을지 (Phase 3, D6), README ↔ YAML 비교 (Phase 5, VERIFY-06), tag 트리거와 버전 일치 검사 (Phase 6, REL-03).

### Required Artifacts

`gsd-tools query verify.artifacts` 를 계획 4개에 돌렸다 (네 번 모두 exit 0, `all_passed: true`). 아래 Details 는 내가 따로 확인한 것이다.

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `tool/verify.dart` | 검증 명령 전체 (준비 + 단계 4개 + 버전 3줄 + 안내형 화면 + `--update`), 350줄 이상 | ✓ VERIFIED | 1010줄. 계획이 든 export 13개가 모두 있다 (**읽기**). import 는 `dart:convert` · `dart:io` 뿐, `print(` 0건. 로컬과 CI 에서 실행됨 (**실행**) |
| `example/expected_diagnostics.txt` | 정답지 — `# 실측:` 머리 주석, `exit 2`, 16줄 | ✓ VERIFIED | 직접 분석 결과와 같다 (**실행**). 첫 줄 `# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12` |
| `example/pubspec.yaml` | 사용 프로젝트와 같은 모양 (`flutter_riverpod ^3.0.0`, dev `woody_lints: path: ..`) | ✓ VERIFIED | **읽기**. `build_runner` · `riverpod_generator` · workspace 설정 없음 |
| `example/pubspec.lock` | 커밋된 lock | ✓ VERIFIED | 추적 파일. `--enforce-lockfile` 로 받는다 (355-360행) |
| `example/lib/*.dart` 7개 | 위반 샘플 4 + 나오면 안 되는 샘플 3 | ✓ VERIFIED | 정답지의 16줄이 각각 주석에 적힌 의도한 위반 자리와 맞는다 (**읽기**). 한 줄만 주석 줄을 가리킨다 — `lib/riverpod_rules.dart:5` 는 필드의 문서 주석 줄이고 필드 자체는 6행이다 (진단 범위가 문서 주석에서 시작한다) |
| `example/README.md` | 설명, 종료 코드 표, 지워 보기 기록, 60줄 이상 | ✓ VERIFIED | 137줄, 여섯 절, `\| M1 \|` ~ `\| M9 \|` 9행. 단 5행 · 65행의 문장은 Gap 1 의 입력에서 사실과 다르다 |
| `analysis_options.yaml` (루트) | `flutter_lints` include, `example/**` 제외, 기존 제외 유지 | ✓ VERIFIED | **읽기** + 루트 분석 깨끗 (**실행**) |
| `.gitignore` | `!example/pubspec.lock`, `build/` | ✓ VERIFIED | **실행**: `git check-ignore` 세 가지 |
| `CHANGELOG.md` | 2.0.0 항목의 `### 그 밖의 변경` | ✓ VERIFIED | **실행**: `968a5bb` 대비 더한 4줄뿐 |
| `.github/workflows/verify.yml` | 트리거 셋, 읽기 권한, concurrency, timeout 10, `.fvmrc` 로 SDK 설치, 검증 명령 한 줄 | ✓ VERIFIED (구성) | YAML 파서로 구조 확인 (**읽기**). push 에서의 실행은 **조회**로 확인. PR · 수동 실행 · 취소는 **확인 불가** |

### Key Link Verification

`gsd-tools query verify.key-links` 결과: 02-01 3/3, 02-02 4/4, 02-03 2/2, 02-04 2/3. 02-04 의 셋째 링크는 파일이 아니라 git ref 사이의 연결이라 도구가 판정하지 못했다 (`Source file not found (from: must be a relative file path …)`) — 직접 조회로 확인했다.

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| `example/analysis_options.yaml` | `lib/analysis_options.yaml` | `include: package:woody_lints/analysis_options.yaml` (`path: ..`) | ✓ WIRED | **실행**: include 를 지우면 16줄이 모두 사라진다. 배포 파일의 줄 하나를 지우면 정답지의 그 줄이 사라진다 |
| `tool/verify.dart` | `example/expected_diagnostics.txt` | `Expected.read` → `findDifference` | ✓ WIRED (약점 있음) | **실행**. 건수를 세지 않는다 (Gap 1) |
| `tool/verify.dart` | `.dart_tool/woody_verify/example/` | `ANALYZER_STATE_LOCATION_OVERRIDE` | ✓ WIRED | **실행**: `.plugin_manager` 아래 폴더 1개, 그 lock 에서 3.1.9 가 읽힌다 |
| `tool/verify.dart` | `lib/analysis_options.yaml` | 단계 2 가 읽어 `plugins:` 를 뺀 복사본을 쓴다 (읽기만) | ✓ WIRED | **실행**: 문제 규칙 3종이 복사본 경로로 보고됨. 모든 실행 뒤 `lib/analysis_options.yaml` 의 sha1 불변 |
| `tool/verify.dart` | `.fvmrc` | `flutter.version.json` 의 `frameworkVersion` 과 비교 | ✓ WIRED | **실행**: 값을 바꾸면 exit 78 |
| `tool/verify.dart` | `example/pubspec.lock` | `readLockVersion` | ✓ WIRED | **실행**: 화면의 `기반 세트` 줄 |
| `tool/verify.dart` | `.plugin_manager/<hash>/pubspec.lock` | 폴더 수가 1 이면 plugin 버전을 읽는다 | ✓ WIRED | **실행**: 폴더를 하나 더 만들면(복사본) `riverpod_lint ?` 와 이유가 찍힌다 |
| `example/README.md` | `tool/verify.dart` | 실행 명령과 종료 코드 표 | ✓ WIRED | **실행**: 표의 0 / 1 / 64 / 69 / 70 / 78 을 각각 한 번 이상 일으켰다 (69 · 70 은 복사본) |
| `example/README.md` | `example/expected_diagnostics.txt` | 기록의 `- ` / `+ ` 줄 | ✓ WIRED | **실행**: M1 ~ M5 의 줄이 다시 만든 결과와 같다 |
| `.github/workflows/verify.yml` | `tool/verify.dart` | `run: dart run tool/verify.dart` | ✓ WIRED | **조회**: CI 로그 184행 |
| `.github/workflows/verify.yml` | `.fvmrc` | `flutter-version-file: .fvmrc` | ✓ WIRED | **조회**: CI 로그 125행, 설치 자리 `stable-3.47.5-x64` |
| 로컬 `gsd/v2.0-package-rework` | `origin/gsd/v2.0-package-rework` | `git push` (fast-forward) | ✓ WIRED | **조회**: 원격 tip `1f06c55` 가 HEAD 의 조상. reflog 에 이 브랜치의 `update by push` 3건 (2026-10-11 20:39, 20:52, 2026-10-12 02:04), `forced-update` 없음 |

### Data-Flow Trace (Level 4)

화면에 찍히는 값이 실제 원천에서 오는지 본 것이다.

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| `tool/verify.dart` 의 `SDK` 줄 | `sdk.flutter` / `sdk.dart` | 실행 중인 dart 근처의 `bin/cache/flutter.version.json` | 예 — `.fvmrc` 를 바꾸면 78 로 거부된다 | ✓ FLOWING |
| `기반 세트` 줄 | `readLockVersion(…)` | `example/pubspec.lock` | 예 | ✓ FLOWING |
| `plugin` 줄 | `readPluginVersion(stateDir)` | 전용 상태 폴더의 `.plugin_manager/<hash>/pubspec.lock` | 예, 다만 **그 실행의 값이 아닐 수 있다** — include 를 지운 실행에서도 3.1.9 | ⚠️ 남은 값을 읽는다 (README 131행에 적힘) |
| 단계 4 의 두 목록 | `difference.missing` / `unexpected` | `dart analyze --format=json` 의 진단 | 예. 건수는 세지 않는다 | ⚠️ Gap 1 |
| 단계 2 의 문제 줄 | `problems` | 복사본을 분석한 JSON | 예 — 세 코드만 고른다. 그 밖의 진단은 버린다 (WR-03) | ✓ FLOWING (범위가 좁음) |

### Behavioral Spot-Checks

내가 직접 돌린 것 전부다. "저장소" 는 이 작업 폴더에서 변경 하나를 만들고 그 경로만 되돌린 것, "복사본" 은 scratch 폴더에 `git archive HEAD` 로 풀어 놓은 사본에서 돌린 것이다. 저장소에서는 `--update` 를 돌리지 않았다.

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| 기준 실행 (저장소) | `fvm dart run tool/verify.dart` | 버전 3줄, 단계 4개 통과, `점검 통과 (4개 중 4개)`, exit 0, 5초. stderr 는 `example/ 분석 중…` 한 줄 | ✓ PASS |
| 정답지 독립 대조 | `example/` 에서 `dart --suppress-analytics analyze --format=json` 을 직접 | exit 2, 진단 16건, 정답지와 diff 없음 | ✓ PASS |
| deprecated 규칙 (저장소) | 배포 파일에 `- unnecessary_await_in_return` 추가 | `[2/4]` 실패 `deprecated_lint`, `[4/4]` 통과, exit 1 | ✓ PASS |
| removed 규칙 (저장소) | `- avoid_returning_null` 추가 | `[2/4]` 실패 `removed_lint`, exit 1 | ✓ PASS |
| 없는 규칙 (저장소) | `- no_such_rule_verifier_probe` 추가 | `[2/4]` 실패 `undefined_lint`, `[4/4]` 실패 `included_file_warning`, exit 1 | ✓ PASS |
| 규칙 삭제 M1 (저장소) | `- prefer_final_locals` 줄 삭제 | `[4/4]` 실패, 빠진 줄 1, exit 1 | ✓ PASS |
| errors 블록 삭제 M3 (저장소) | 두 줄 삭제 | 남는 줄 `lib/should_not_appear.dart:5  warning  invalid_annotation_target`, exit 1 | ✓ PASS |
| g.dart 제외 삭제 M4 (저장소) | 한 줄 삭제 | 남는 줄 2 (`sample.g.dart:4`), exit 1 | ✓ PASS |
| freezed.dart 제외 삭제 M5 (저장소) | 한 줄 삭제 | 남는 줄 2 (`sample.freezed.dart:4`), exit 1 | ✓ PASS |
| `lib/` 의 `.dart` (저장소) | 빈 `lib/_verifier_probe.dart` | `[1/4]` 실패, exit 1 | ✓ PASS |
| 깊은 경로의 `.dart` (저장소) | `lib/sub/deep/_verifier_probe.dart` | `[1/4]` 실패, exit 1 | ✓ PASS |
| include 삭제 M2 (저장소) | `example/analysis_options.yaml` 을 빈 파일로 | `[3/4]` · `[4/4]` 실패, 빠진 줄 16 · 남는 줄 1, exit 1. 같은 상태의 `dart analyze` 는 exit 2 (정답지와 같음) | ✓ PASS |
| SDK 불일치 M9 (저장소) | `.fvmrc` 를 `0.0.0` 으로, `.fvm/flutter_sdk/bin/dart run tool/verify.dart` | stdout 0바이트, 안내, exit 78 | ✓ PASS |
| 모르는 인자 (저장소) | `fvm dart run tool/verify.dart --bogus` | 사용법, exit 64 | ✓ PASS |
| 다른 작업 폴더 (저장소) | `example/` 에서 `fvm dart run ../tool/verify.dart` | exit 0 | ✓ PASS |
| 새 checkout (복사본) | 첫 실행 | exit 0, 16초 | ✓ PASS |
| 추가 규칙 나머지 5개 삭제 (복사본) | 규칙을 하나씩 지움 | 다섯 번 모두 그 규칙의 줄 하나가 빠지고 실패 | ✓ PASS |
| 강도 변경 (복사본) | `analyzer.errors` 에 `prefer_final_locals: warning` | `- …:24  info  …` / `+ …:24  warning  …`, exit 1 | ✓ PASS |
| 기반 세트가 켜는 규칙 삭제 (복사본) | 배포 파일에서 `- avoid_print` 삭제 | 통과, exit 0 — D-01 의 추론대로다 (기반 세트가 켠다). README 가 "재지 않았다" 고 적은 것을 쟀다 | ✓ PASS (설계대로) |
| `--update` 바뀐 것 없음 (복사본) | `dart run tool/verify.dart --update` | `정답지와 같다 — 바뀐 줄 없음`, sha 불변, exit 0 | ✓ PASS |
| `--update` 변화 표시 (복사본) | 규칙 하나를 지운 뒤 `--update` | `- ` 한 줄을 보여 주고 그 줄만 뺀 정답지를 씀 | ✓ PASS |
| CI 의 `--update` (복사본) | `CI=true …`, `GITHUB_ACTIONS=true …` | 각각 exit 64, 정답지 sha 불변 | ✓ PASS |
| 정답지 없음 (복사본) | 정답지를 치우고 실행 | `[4/4]` 실패 `정답지가 없다. 처음이면 … --update 로 만든다.`, exit 1 | ✓ PASS |
| 같은 줄의 건수 차이 (복사본) | 위 Gap 1 의 세 입력 | 세 번 모두 exit 0 | ✗ FAIL |
| GitHub 실행 | `gh run view 38158088016` | `completed` / `success`, 단계 4개 통과 | ✓ PASS |
| 계획의 자동 검증 명령 원문 | 02-02 T2, 02-03 T1, 02-03 T2, 02-04 T1, 02-04 T2 를 bash 로 | 다섯 개 모두 rc=0 | ✓ PASS |

계획의 자동 검증 명령 중 돌리지 않은 것: 02-01 T1 · 02-02 T1 (저장소에서 `CI=true … --update` 를 실행한다 — 이번 검증의 규칙상 저장소에서는 돌리지 않았고 같은 내용을 복사본에서 봤다), 02-01 T2 (단계가 1개이던 시점의 화면 문자열을 재므로 지금은 글자 그대로 통과할 수 없다 — 02-VALIDATION.md 가 같은 점을 적어 두었다).

### Probe Execution

해당 없음. `scripts/*/tests/probe-*.sh` 가 없고 계획과 SUMMARY 가 probe 스크립트를 선언하지 않았다.

### Requirements Coverage

계획 frontmatter 가 선언한 ID: 02-01 `VERIFY-01` / 02-02 `VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-07` / 02-03 `VERIFY-08` / 02-04 `VERIFY-04`. REQUIREMENTS.md 가 Phase 2 에 대응시킨 6개와 같다. **ORPHANED 없음.** (`VERIFY-05` 는 Phase 3, `VERIFY-06` 은 Phase 5 다.)

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| VERIFY-01 | 02-01, 02-02 | `example/` 이 배포 설정을 include 하고, 기대한 진단이 실제로 보고되는지를 커밋된 정답지와 비교해 판정한다 | ✓ SATISFIED (약점 있음) | 기대한 16줄 각각이 빠지면 실패한다 (**실행**: 추가 규칙 6개, include 삭제). 요구사항 문장은 채워졌다. 건수를 세지 않는 결함은 성공 기준 1 쪽에 gap 으로 적었다 |
| VERIFY-02 | 02-02 | 배포 파일에 deprecated / removed / 없는 규칙이 있으면 실패 | ✓ SATISFIED | **실행**: 세 종류 각각. 범위는 `lib/analysis_options.yaml` 에 **직접 적힌** 규칙이다 (아래 WR-03 과 "Phase 3 가 알아야 할 것") |
| VERIFY-03 | 02-02 | 소유자가 로컬에서 명령 하나로 전체 검증을 실행 | ✓ SATISFIED | **실행**: `fvm dart run tool/verify.dart` 한 줄 |
| VERIFY-04 | 02-04 | GitHub Actions 가 push 와 PR 마다 로컬과 같은 검증을 실행하며 시간 제한이 있다 | ? NEEDS HUMAN (부분) | push · 시간 제한 · 같은 명령은 **조회**로 확인. PR 쪽은 선언만 있다 (**확인 불가**) |
| VERIFY-07 | 02-02 | `lib/` 에 `.dart` 파일이 있으면 실패 | ✓ SATISFIED | **실행**: 얕은 경로와 깊은 경로 |
| VERIFY-08 | 02-03 | 검증이 실제로 문제를 잡아냄이 확인되어 있다 — 규칙 삭제와 include 삭제가 각각 실패 | ✓ SATISFIED | **읽기**: README 의 기록. **실행**: 두 변경을 다시 만들어 기록과 같은 결과 |

### Decision Coverage

`gsd-tools query check.decision-coverage-verify` 의 결과: `total 15, honored 15, not_honored []` — "All trackable CONTEXT.md decisions are honored by shipped artifacts." (문자열 일치에 기댄 판정이라 경고용이다. 상태에는 영향을 주지 않는다.)

내가 따로 본 것:

| 결정 | 확인 | 방법 |
|------|------|------|
| D-01 규칙 12개 + 기반 세트만의 규칙 1건 이상 | 지켜짐. "추가하는 6개 중 하나를 지워야 실패한다" 도 6개 각각 확인. 나머지 6개 중 `avoid_print` 는 지워도 통과 | 실행 |
| D-02 `riverpod_lint` 2~3건, 강도가 섞임, 코드 생성 도구 없음 | 3건 (warning 2, info 1), `build_runner` 등 없음 | 실행 + 읽기 |
| D-03 나오면 안 되는 샘플 + 지워 보기 기록 | 지켜짐 | 실행 + 읽기 |
| D-04 `상대경로:줄  강도  규칙이름` + `exit N`, 생기거나 사라지거나 강도가 바뀌면 실패 | 형식은 지켜짐. "생기거나 사라지면 실패" 는 같은 줄이 여러 건일 때 성립하지 않음 (Gap 1) | 실행 |
| D-05 `example/pubspec.lock` 커밋 | 지켜짐 | 실행 |
| D-06 수동 실행 추가, 예약 실행 없음 | 선언됨 / 없음 | 읽기 |
| D-07 쓰인 버전을 화면에 | 지켜짐 (plugin 줄의 한계는 위에 적음) | 실행 |
| D-08 / D-09 브랜치를 그대로 올림, 브랜치 이름 하나만, force · tag · main 없음 | 원격 상태와 reflog 가 일치 (작업 브랜치의 push 3건 모두 fast-forward, `origin/main` 의 마지막 push 는 2026-09-20). 실제로 입력된 명령은 SUMMARY 의 기록뿐이다 | 조회 |
| D-10 모든 브랜치 push · PR · 수동, concurrency, PR 을 미리 열지 않음, tag 트리거 없음 | PR 0건. `tags:` 키는 없다. 다만 필터 없는 `push:` 는 tag push 에서도 돈다 (GitHub 문서의 동작, 일으켜 보지 않음) — 사람 확인 6 | 조회 + 읽기 |
| D-11 Dart 스크립트, `dart:io` · `dart:convert` 만 | 지켜짐 | 읽기 |
| D-12 SDK 불일치면 시작하지 않음 | `.fvmrc` 불일치 경로는 실행으로 확인, 나머지 두 경로는 읽기만 | 실행 + 읽기 |
| D-13 안내형 화면 | 구성은 지켜짐. 단계 수가 미리보기의 3이 아니라 4 (`[3/4] example/ 옵션 파일` 이 더해짐 — 계획 02-02 가 정한 것) | 실행 |
| D-14 `--update`, 줄 단위 표시, CI 거부 | 지켜짐 (약점 WR-01) | 실행(복사본) |
| D-15 spike 결과의 처리 | `.planning/spikes/001` ~ `008` 과 `WRAP-UP-SUMMARY.md` 가 있다. 멈춤 조건에 해당한 결과가 있었는지는 기록에 기댄다 | 읽기 |

### Prohibitions (must_haves.prohibitions)

계획 4개의 금지 사항 12건은 모두 `verification: judgment`, `status: unresolved` 다. 아래 판정은 내가 증거를 보고 내린 **참고용 판정**이고 확정이 아니다 — 설정이 interactive 이므로 건마다 소유자가 확정한다 (`unverified-prohibition — human review recommended`).

| # | Plan | 금지 사항 | 참고 판정 | 증거 |
|---|------|-----------|-----------|------|
| P1 | 02-01 | `lib/` 와 `pubspec.yaml` 을 바꾸지 않는다. 루트 옵션 파일의 `lib/analysis_options.yaml` 제외는 그대로 | 지켜짐 | **실행**: `git diff --quiet 90a2736 -- lib` rc=0, `git diff --quiet 968a5bb -- pubspec.yaml README.md` rc=0. **읽기**: 루트 `analysis_options.yaml` 14행 |
| P2 | 02-01 | `example/` 에 `build_runner` / `riverpod_generator` 를 붙이지 않고 workspace 멤버로 만들지 않는다 | 지켜짐 | **읽기**: 두 `pubspec.yaml` 에 해당 문자열 0건 |
| P3 | 02-01 | `example/` 에서 `flutter pub get` 을 돌리지 않는다 | 흔적 없음 (돌리지 않았다는 증명은 불가) | **읽기**: 옵션 파일이 한 줄이고 그 파일을 건드린 커밋은 만든 커밋 하나뿐 |
| P4 | 02-02 | `lib/analysis_options.yaml` 은 읽기만 — 복사본은 `build/woody_rule_check/` 에만 쓰고 지운다 | 지켜짐 | **읽기**: 쓰기 호출은 523행(정답지) · 597행(복사본)뿐, 삭제는 666 · 668행(복사본과 빈 `build/`)뿐. **실행**: 모든 실행 뒤 배포 파일 sha1 불변, 복사본 폴더 없음 |
| P5 | 02-02 | `--update` 는 CI 에서 동작하지 않는다 | 지켜짐 | **실행(복사본)**: `CI=true` · `GITHUB_ACTIONS=true` 각각 exit 64, 정답지 불변. 판별은 두 환경변수가 정확히 `true` 일 때다 |
| P6 | 02-02 | 전용 상태 폴더를 스크립트가 지우지 않는다 | 지켜짐 | **읽기**: 상태 폴더 경로에 대한 삭제 호출 없음. **실행**: 실행을 거듭해도 `.plugin_manager` 폴더 1개 유지 |
| P7 | 02-03 | 지워 보기 변경을 커밋하지 않는다 | 지켜짐 | **실행**: Phase 2 동안 `lib` · `.fvmrc` 를 건드린 커밋 0, `example/analysis_options.yaml` 은 만든 커밋 하나 |
| P8 | 02-03 | 기록에 로컬 절대 경로와 토큰을 적지 않는다 | 지켜짐 | **읽기**: grep 0건 |
| P9 | 02-03 | CHANGELOG 의 옛 항목과 2.0.0 의 기존 칸을 바꾸지 않는다 | 지켜짐 | **실행**: `968a5bb` 대비 diff 가 더한 4줄뿐 |
| P10 | 02-04 | push 는 브랜치 이름 하나만 준 한 줄뿐 — force · `--tags` · `--all` · `main` · tag · 다른 브랜치 없음 | 원격 상태와 일치 (입력된 명령 자체는 확인 불가) | **조회**: heads 2줄, `main` = `90a2736`, tag 는 `v1.3.0` 뿐, reflog 에 forced-update 없음 |
| P11 | 02-04 | non-fast-forward 로 거부되면 force 하지 않고 멈춘다 | 해당 상황 없음 | **조회**: 이 phase 의 push 는 `1ed61cd..1f06c55` fast-forward 한 번 |
| P12 | 02-04 | CI 를 보려고 PR 을 열지 않는다. tag 트리거도 넣지 않는다 | PR 쪽은 지켜짐. tag 쪽은 **소유자 판단 필요** | **조회**: PR 0건. **읽기**: `tags:` 키는 없지만 필터 없는 `push:` 는 tag push 에서도 실행된다 — workflow 5행의 주석 "tag 트리거는 Phase 6" 이 "지금은 tag 에서 돌지 않는다" 로 읽힌다 (사람 확인 6) |

### Anti-Patterns Found

Phase 2 가 `.planning/` 밖에서 바꾼 17개 파일 중 생성물 `example/pubspec.lock` 을 뺀 16개를 훑었다.

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| (전체) | - | `TBD` / `FIXME` / `XXX` | - | 0건 — debt marker 없음 |
| (전체) | - | `TODO` / `HACK` / placeholder 문구 | - | 0건 |
| `tool/verify.dart` | 226-389 | `return null` 10곳 | Info | 모두 "읽지 못했다" 를 알리는 반환값이고 호출 쪽이 처리한다. stub 아님 |
| `tool/verify.dart` | 477-478 | 집합 비교 | Blocker (Gap 1) | 같은 줄의 건수 차이를 놓친다 |
| `tool/verify.dart` | 393 | 함수 이름 `pluginFolders` 가 동사로 시작하지 않음 | Info | 소유자의 전역 규칙("함수명: 동사로 시작")과 다르다. 계획의 `<interfaces>` 가 정한 이름이다 |
| `.github/workflows/verify.yml` | 5 | 주석이 동작보다 좁게 말한다 ("필터 없음 = 모든 브랜치") | Warning | Phase 6 이 이 주석을 믿고 `tags:` 만 더하면 브랜치 push 에서 돌지 않게 된다 (WR-07) |

### 코드 리뷰(02-REVIEW.md) 발견에 대한 내 판단

리뷰의 등급을 물려받지 않고 건마다 다시 봤다. "재현" 은 내가 복사본에서 돌린 결과다.

| ID | 실제인가 | 내가 본 것 | 목표에 주는 영향 |
|----|----------|------------|------------------|
| CR-01 | 예 (**실행**, 세 방향) | 위 Gap 1 | **성공 기준 1 이 부분적으로만 성립** — gap. 지금의 fixture 에서는 드러나지 않는다 |
| WR-01 | 예 (**실행**, 두 경우) | (a) `example/` 옵션 파일을 비우고 `--update` → `[3/4]` 실패인데 `[4/4] 통과` 를 찍고 정답지를 `exit 2` + `invalid_annotation_target` 한 줄로 덮어씀, exit 1. 머리 주석은 그 실행에서 돌지 않은 plugin 을 `riverpod_lint 3.1.9` 로 적는다. (b) `.plugin_manager` 에 폴더가 둘이면 머리 주석에 `riverpod_lint ?` 를 적고 exit 0 | 달성하되 약점. 검사 쪽의 판정이 틀리는 것은 아니고, 바뀌는 줄 16 + 1 은 쓰기 전에 화면에 나온다 (D-14 의 문장은 지켜진다). 다만 Phase 4 는 `--update` 를 규칙마다 쓰므로 망가진 실행이 정답지로 굳을 길이 열려 있다. Gap 1 을 고칠 때 함께 막는 것이 싸다 |
| WR-02 | 예 (**실행**) | 배포 파일의 YAML 을 깨뜨리면 `[2/4] 통과`, `[4/4] 실패`, `종료 코드: 정답지 2, 실제 3`, 빠진 줄 16, exit 1 | 영향 없음(전체 판정은 실패로 맞다). 원인을 가리킬 단계가 "통과" 로 찍히고 안내가 `--update` 를 권하는 것은 약점 |
| WR-03 | 예 (**실행**) | `linter:` 를 `lintr:` 로 바꾸면 `[2/4] 통과`, `[4/4] 실패`. 그리고 내가 더 잰 것: 규칙을 include 뒤의 파일로 옮기고 별칭 파일에 `plugins:` 만 남기면, **deprecated 규칙이 있어도 단계 4개가 모두 통과하고 exit 0** | 오늘의 성공 기준 2 에는 영향 없음. **Phase 3 에는 영향 있음** — 아래 "Phase 3 가 알아야 할 것" |
| WR-04 | 읽기로만 | `stderrText` 를 읽는 곳이 749행과 763행 두 군데뿐임을 확인. 머리말 없는 stderr 를 내는 실패는 만들지 못했다 | 알 수 없음. 진단을 어렵게 할 뿐 판정을 바꾸는 경로는 찾지 못했다 |
| WR-05 | 예 (**실행**) | 정답지 맨 위에 `<<<<<<< HEAD` 를 넣으면 보통 실행과 `--update` 둘 다 exit 70, stdout 0바이트, stderr 에 정답지의 **절대 경로**가 찍힌다 | 영향 없음(0 이 아닌 종료 코드라 CI 는 빨갛다). 깨진 정답지를 `--update` 로 되살릴 수 없고 화면이 통째로 사라지는 것은 약점 |
| WR-06 | 예 (**실행**) | 루트 `pubspec.yaml` 의 `version` 을 `2.0.0` 으로 바꾸면 exit 69, 안내는 "`example/pubspec.yaml` 을 바꿨으면 …". 안내가 시키는 명령(`cd example && fvm dart pub get` 후 커밋) 자체는 맞는 복구다 | 영향 없음. Phase 6 이 버전을 올리는 순간 반드시 만난다 — 그때 원인을 잘못 짚지 않도록 릴리스 절차에 적어 둘 일이다 |
| WR-07 | 읽기로만 | workflow 의 `on.push` 에 필터가 없다 (YAML 파서: `push: nil`). tag push 에서의 실행은 GitHub 문서의 동작이고 일으켜 보지 않았다 | 오늘은 영향 없음. 주석과 D-10 의 문장이 실제 동작과 다르다 — 사람 확인 6 |
| IN-01 | 다시 재지 않음 | 리뷰어의 실행 기록에 기댄다 | 영향 없음 (검증이 시작되지 않는 것은 같다) |
| IN-02 | 읽기 | 635-640행의 문구가 방금 성공한 `pub get` 을 원인으로 든다 | 영향 없음 |
| IN-03 | 예 (**실행**, 일부) | 빈 폴더 하나만 더해도 "저장소 경로가 바뀐 적 있다" 가 찍힌다 | 영향 없음 |
| IN-04 | 읽기 | action 이 major tag. 토큰 권한은 로그상 읽기뿐 | 영향 없음 |
| IN-05 | 읽기로만 | PR 이 없어 볼 수 없다 | 영향 없음 |
| IN-06 | 읽기 | `pluginFolders` | 영향 없음 |

### Phase 3 가 알아야 할 것 (gap 아님, 실행으로 확인한 사실)

로드맵 Phase 3 의 Notes 는 "Phase 2 의 deprecated / removed 검사가 새 위치를 대상으로 계속 실패를 잡는지 확인한다" 고 적어 두었다. 지금의 스크립트가 그 구조에서 어떻게 되는지 복사본에서 쟀다.

| 구조 | 결과 |
|------|------|
| 규칙과 `plugins:` 를 `lib/recommended.yaml` 로 옮기고 `lib/analysis_options.yaml` 은 include 한 줄 별칭 (로드맵이 그리는 모양에 가깝다) | **exit 70**, stdout 0바이트, `lib/analysis_options.yaml 에서 plugins: 섹션을 찾지 못했다`. 조용히 통과하지 않고 크게 실패한다 — 스크립트를 고쳐야만 넘어갈 수 있다 |
| 같은 구조인데 별칭 파일에 `plugins:` 를 남기고, include 된 파일에 `unnecessary_await_in_return` 을 넣음 | **단계 4개 모두 통과, exit 0.** 단계 2 는 복사본에 직접 적힌 규칙만 보는데 복사본에는 include 한 줄뿐이라 본 규칙이 0개다. deprecated 규칙이 include 뒤에 있으면 어느 단계도 잡지 못한다 |

둘째 줄이 WR-03 의 실제 모양이다. Phase 3 에서 단계 2 의 대상 파일을 옮길 때 "읽은 규칙이 0개면 실패" 를 함께 넣지 않으면, 대상 경로를 잘못 잡은 것이 통과로 보인다.

### Test Quality Audit

이 phase 에는 테스트 프레임워크가 없다. 검증 명령과 정답지가 곧 테스트다.

| Test File | Linked Req | Active | Skipped | Circular | Assertion Level | Verdict |
|-----------|-----------|--------|---------|----------|-----------------|---------|
| `tool/verify.dart` 단계 4 + `example/expected_diagnostics.txt` | VERIFY-01, VERIFY-08 | 1 | 0 | 형식상 그렇다 — 정답지는 같은 도구의 `--update` 가 쓴다. 목적이 1.3.0 동작의 고정(characterization)이고 `lib/` 가 `v1.3.0` 의 커밋과 같으므로 값의 출처는 "기존 시스템의 출력" 이다. 독립 근거: 16줄 각각이 주석에 적힌 의도한 위반과 맞고(읽기), 스크립트 밖에서 직접 분석한 결과와 같으며(실행), 변경 12가지에 반응한다(실행) | Value (줄 단위). 건수는 보지 않는다 | 유효, Gap 1 의 약점 |
| `tool/verify.dart` 단계 2 | VERIFY-02 | 1 | 0 | 아님 — analyzer 의 진단 코드 3종을 본다 | Value | 유효. 읽은 규칙 수는 보지 않는다 (WR-03) |
| `tool/verify.dart` 단계 1 · 3 | VERIFY-07 등 | 2 | 0 | 아님 | Value | 유효 |
| `.github/workflows/verify.yml` | VERIFY-04 | 1 | 0 | 아님 | Status (명령의 종료 코드) | 유효 |

**Disabled tests on requirements:** 0
**Circular patterns detected:** 0 (정답지 생성은 형식상 순환이지만 위의 독립 근거가 있어 blocker 로 보지 않았다)
**Insufficient assertions:** 1 — 정답지 비교가 건수를 보지 않는다 (Gap 1)

### Human Verification Required

상태가 `gaps_found` 라 frontmatter 의 `human_verification` 은 두지 않았다 (템플릿 규칙). 아래 항목은 gap 을 닫은 뒤에도 그대로 남는다. 1 · 2 는 계획이 phase 끝으로 미뤄 둔 `<human-check>` 를 가져온 것이다.

### 1. 안내형 화면이 읽히는가 (02-02 Task 2 의 human-check, D-13)

**Test:** `fvm dart run tool/verify.dart` 를 한 번 돌리고, `lib/analysis_options.yaml` 의 `- prefer_final_locals` 줄을 잠시 주석 처리한 뒤 한 번 더 돌려 두 화면을 `02-CONTEXT.md` 의 미리보기와 나란히 본다. 바꾼 줄은 `git checkout -- lib/analysis_options.yaml` 로 되돌린다.
**Expected:** 통과 화면은 버전 3줄 → 단계 4줄 → `점검 통과 (4개 중 4개)`. 실패 화면은 `[4/4] … 실패` 아래에 `정답지에는 있는데 나오지 않은 경고 (1)` 과 `lib/added_rules.dart:24  info  prefer_final_locals`, `정답지에 없는데 나온 경고 (0)`, `--update` 안내, `점검 실패 (4개 중 1개)`. 화면만 보고 무엇이 달라졌고 다음에 무엇을 하면 되는지 안다.
**Why human:** 문자열과 순서는 실행으로 확인했다 (위 Spot-Checks 의 M1 화면이 이것이다). "안내로 읽히는가" 는 소유자의 판단이다.

### 2. 지워 보기 기록이 읽히는가 (02-03 Task 2 의 human-check, VERIFY-08)

**Test:** `example/README.md` 의 `## 검증이 실제로 잡아내는지 확인한 기록` 절을 읽는다.
**Expected:** 표만 보고 (1) 규칙 하나를 지우면 어느 줄이 빠지는지, (2) include 를 지우면 16줄이 사라지는 대신 다른 warning 이 나타나 종료 코드가 그대로라는 점, (3) deprecated 규칙은 정답지가 아니라 규칙 이름 검사가 잡는다는 점이 읽힌다.
**Why human:** 기록의 내용이 사실과 맞는지는 다시 만들어 확인했다. 몇 달 뒤 이 절만 보고 아는가는 독자의 판단이다.

### 3. pull request 에서 workflow 가 도는가 (성공 기준 5, VERIFY-04)

**Test:** 이 저장소에 PR 이 처음 열릴 때 (Phase 6 의 `main` 병합이 PR 을 거친다면 그때) Actions 탭에 `verify` 실행이 `pull_request` event 로 생기는지 본다.
**Expected:** PR 의 커밋에서 `verify` 가 실행되고 단계 4개가 통과한다.
**Why human:** `pull_request:` 는 필터 없이 선언되어 있지만 PR 이 한 번도 열리지 않았고, D-10 이 점검용 PR 을 미리 열지 않기로 했다. 이 환경에서는 일으킬 수 없다.

### 4. 수동 실행 버튼 (D-06)

**Test:** workflow 파일이 `main` 에 들어간 뒤 GitHub 의 Actions → verify 화면에서 "Run workflow" 버튼을 눌러 본다.
**Expected:** 버튼이 보이고, 누르면 `workflow_dispatch` event 의 실행이 생겨 통과한다.
**Why human:** 버튼은 기본 브랜치에 workflow 파일이 있어야 나타난다. 릴리스 전에는 볼 수 없다.

### 5. 겹치는 실행의 취소 (truth 23, behavior-unverified)

**Test:** 같은 브랜치에 커밋을 연달아 두 번 올린다 (앞선 실행이 약 2분 도는 동안).
**Expected:** 앞선 실행이 `cancelled` 로 끝난다.
**Why human:** 실행이 지금까지 1건이라 취소가 일어난 적이 없다. 설정은 파일에 있다.

### 6. tag push 에서도 workflow 가 돈다는 점을 어떻게 둘 것인가 (D-10, P12, WR-07)

**Test:** `.github/workflows/verify.yml` 5-6행을 읽고 정한다 — (a) D-10 대로 브랜치에서만 돌게 `push:` 아래 `branches: ['**']` 를 적는다, 또는 (b) tag 에서도 도는 것을 그대로 두고 주석을 "필터 없음 = 모든 브랜치와 tag" 로 고친다.
**Expected:** 주석과 D-10 의 문장이 실제 동작과 맞는다. Phase 6 이 tag 트리거를 더할 때 `tags:` 만 적어 브랜치 push 의 실행을 잃는 일이 없다.
**Why human:** 지금 당장의 해는 없고(tag 를 올리면 검증이 한 번 더 돌 뿐이다) 어느 쪽이 의도인지는 소유자의 결정이다. tag 를 올려야 볼 수 있어 실행으로는 확인하지 않았다.

### 7. 금지 사항 12건의 확정

**Test:** 위 "Prohibitions" 표의 P1 ~ P12 를 증거와 함께 읽고 건마다 확정한다.
**Expected:** P1 · P2 · P4 ~ P9 는 증거가 분명하다. P3 (돌리지 않았다는 증명 불가) · P10 (입력된 명령은 기록뿐) · P11 (해당 상황 없음) · P12 (tag 쪽, 항목 6 과 같은 결정) 는 소유자의 판단이 들어간다.
**Why human:** 12건 모두 계획이 `verification: judgment` 로 둔 것이라 검증기의 판정은 참고용이다.

### Gaps Summary

**gap 은 하나다.** 정답지 비교(`tool/verify.dart` 의 `findDifference`)가 줄의 있고 없음만 보고 건수를 세지 않는다. 같은 줄이 두 번 이상 걸리는 입력에서 경고가 한 건 생기거나 사라져도 종료 코드 0 으로 통과하는 것을 복사본에서 재현했다. 로드맵 성공 기준 1 의 "다르면 실패한다" 가 그 입력에서는 거짓이고, `example/README.md` 는 그 반대를 적고 있다.

**범위는 좁다.** 지금 커밋된 fixture 와 정답지에서는 틀린 판정이 나오지 않고, 배포 파일만 바꿔서 이 구멍에 닿는 경로는 찾지 못했다. 구멍은 fixture 나 정답지가 바뀔 때 열린다 — Phase 3 · 4 가 하는 일이다.

**나머지는 확인됐다.** 성공 기준 2 · 3 · 4 는 변경을 직접 만들어 실패를 봤고, 성공 기준 5 는 push 쪽을 GitHub 조회로 확인했다 (PR 쪽은 선언뿐이라 사람 확인으로 남겼다). 요구사항 6개는 모두 계획이 맡았고 빠진 ID 가 없다. 금지 사항 12건은 어긴 흔적이 없다 (tag 트리거 한 건은 소유자 판단).

**같이 다루면 좋은 것 (gap 아님).** gap 을 닫는 계획을 세운다면 같은 함수 주변의 WR-01 (`--update` 가 다른 단계가 실패한 실행의 결과도 쓴다) 과 WR-03 (규칙 이름 단계가 읽은 규칙이 0개여도 통과한다) 이 같은 파일의 몇 줄짜리 변경이고, 둘 다 Phase 3 · 4 가 이 하네스에 기대는 지점이다. 넣을지는 소유자가 정한다.

**검증이 끝난 뒤의 저장소.** `lib` == `90a2736`, `pubspec.yaml` · `README.md` == `968a5bb`, `.fvmrc` = 3.47.5, `lib/` 에 `.dart` 0개, `build/woody_rule_check` 없음, `fvm dart run tool/verify.dart` exit 0. `git status --short` 는 시작할 때의 네 항목에 이 파일 하나가 더해진 것뿐이다.

---

_Verified: 2026-10-11T17:55:13Z_
_Verifier: Claude (gsd-verifier)_
