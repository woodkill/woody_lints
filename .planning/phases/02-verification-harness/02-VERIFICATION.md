---
phase: 02-verification-harness
verified: 2026-10-12T01:39:49Z
status: passed
score: 28/30 must-haves verified
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
  - ".planning/phases/02-verification-harness/02-05-PLAN.md"
  - ".planning/phases/02-verification-harness/02-05-SUMMARY.md"
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
covered_digest: "v3:sha256:028f836dd4864161c2cc718943eb6fd303cff9cad421a5b8736742f7e4dbf190"
behavior_unverified: 1
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 23/26
  gaps_closed:
    - "소유자가 저장소 루트에서 명령 하나를 실행하면 example/ 의 분석 결과가 커밋된 기대 진단 파일과 비교되어, 같으면 성공하고 다르면 실패한다 (ROADMAP 성공 기준 1) — 같은 줄의 건수 차이가 두 방향 모두 종료 코드 1 로 실패한다"
  gaps_remaining: []
  regressions: []
behavior_unverified_items:
  - truth: "workflow 의 권한은 contents: read 뿐이고, 겹치는 실행은 concurrency 로 취소된다 (plan 02-04)"
    test: "같은 브랜치에 커밋을 연달아 두 번 올려, 앞선 verify 실행이 진행 중일 때 뒤 실행이 시작되게 한다"
    expected: "앞선 실행이 cancelled 로 끝나고 뒤 실행만 끝까지 돈다"
    why_human: "concurrency 블록은 파일에 있고 YAML 로 읽히지만 이 workflow 의 실행은 지금까지 1건이라 취소가 일어난 적이 없다. 권한은 그 실행의 로그(Contents: read / Metadata: read)로 확인됐다"
coincidental_reliance_items:
  - truth: "명령 한 번으로 단계 4개가 모두 통과하고 종료 코드 0 이다 (VERIFY-03)"
    reason: undeclared-precondition
    harden: "정답지의 riverpod_lint 3줄은 배포 파일의 ^3.1.3 이 실행 시점에 3.1.9 로 풀린다는 전제에 기댄다. example/pubspec.lock 은 plugin 버전을 묶지 못한다. Phase 3 의 D6 (caret 유지 / 정확한 버전 고정) 에서 전제를 선언하거나 묶는다"
  - truth: "화면 맨 위에 실제로 쓰인 버전 세 줄이 찍힌다 (D-07)"
    reason: undeclared-precondition
    harden: "plugin 줄은 전용 상태 폴더에 남은 값을 읽는다. include 를 지운 실행에서도 riverpod_lint 3.1.9 가 찍혔다 (이번에도 재현). plugin 준비가 실패한 실행에는 '(이번 실행에서는 plugin 이 뜨지 않았다)' 가 붙지만, plugin 이 선언되지 않은 실행에는 붙지 않는다. Phase 3 의 plugin 없는 fixture 에서 이 줄의 뜻을 정한다"
human_verification:
  - test: "fvm dart run tool/verify.dart 를 한 번 돌리고, lib/analysis_options.yaml 의 '- prefer_final_locals' 줄을 잠시 주석 처리한 뒤 한 번 더 돌려 두 화면을 02-CONTEXT.md 의 미리보기와 나란히 본다. 끝나면 git checkout -- lib/analysis_options.yaml"
    expected: "통과 화면은 버전 3줄, 단계 4줄, '점검 통과 (4개 중 4개)'. 실패 화면은 '[4/4] … 실패' 아래 '정답지에는 있는데 나오지 않은 경고 (1)' 과 그 줄, --update 안내, '점검 실패 (4개 중 1개)'. 화면만 보고 무엇이 달라졌고 다음에 무엇을 하면 되는지 안다"
    why_human: "문자열과 순서는 실행으로 확인했다. 안내로 읽히는가는 소유자의 판단이다 (02-02 Task 2 의 human-check, D-13)"
  - test: "example/README.md 의 '## 검증이 실제로 잡아내는지 확인한 기록' 절(M1 ~ M9 표와 읽는 법)을 읽는다"
    expected: "표만 보고 규칙 하나를 지우면 어느 줄이 빠지는지, include 를 지우면 16줄이 사라지고 다른 warning 이 나타나 종료 코드가 그대로라는 점, deprecated 규칙은 규칙 이름 검사가 잡는다는 점이 읽힌다"
    why_human: "기록의 내용이 사실과 맞는지는 M1 · M2 · M6 을 다시 만들어 확인했다. 몇 달 뒤 이 절만 보고 아는가는 독자의 판단이다 (02-03 Task 2 의 human-check, VERIFY-08)"
  - test: "example/README.md 의 '### 추가 실측 — 건수 비교 · --update 안전장치 · 규칙 0개 (gap 닫기 02-05)' 소절(M10 ~ M14 표와 불릿 다섯)을 읽는다"
    expected: "같은 줄이 두 번 나오는 입력에서 어느 쪽 목록에 한 줄이 잡히는지, 다른 단계가 실패한 실행에서 --update 가 쓰지 않고 무엇을 찍는지, 규칙을 하나도 읽지 못하면 [2/4] 가 실패하고 Phase 3 이 규칙 파일을 옮길 때 무엇을 함께 옮겨야 하는지가 읽힌다"
    why_human: "표의 다섯 행과 불릿의 사실은 모두 다시 실행해 맞음을 확인했다. 소절만 보고 '무엇이 막혔고 무엇이 막히지 않는가' 를 아는가는 독자의 판단이다 (02-05 Task 3 의 human-check)"
  - test: "이 저장소에 PR 이 처음 열릴 때 Actions 탭에 verify 실행이 pull_request event 로 생기는지 본다"
    expected: "PR 의 커밋에서 verify 가 실행되고 단계 4개가 통과한다"
    why_human: "pull_request: 는 필터 없이 선언되어 있지만 PR 이 한 번도 열리지 않았고(gh pr list --state all = 0건) D-10 이 점검용 PR 을 미리 열지 않기로 했다 (성공 기준 5, VERIFY-04)"
  - test: "다음에 작업 브랜치를 올린 뒤(D-09 대로 소유자 확인 후) 그 커밋의 verify 실행을 본다"
    expected: "completed / success, 로그에 '점검 통과 (4개 중 4개)'"
    why_human: "GitHub 에서 성공한 실행은 1f06c55 의 것 하나다. 02-05 가 바꾼 tool/verify.dart (107줄) 는 올라가지 않아 Linux runner 에서 돈 적이 없다. 바뀐 것은 플랫폼에 기대지 않는 Dart 로직이고 로컬에서는 같은 SDK 로 통과하지만, runner 에서의 결과는 push 뒤에만 볼 수 있다"
  - test: "workflow 파일이 main 에 들어간 뒤 GitHub 의 Actions → verify 화면에서 'Run workflow' 버튼을 눌러 본다"
    expected: "버튼이 보이고, 누르면 workflow_dispatch event 의 실행이 생겨 통과한다"
    why_human: "버튼은 기본 브랜치에 workflow 파일이 있어야 나타난다. 릴리스 전에는 볼 수 없다 (D-06)"
  - test: "같은 브랜치에 커밋을 연달아 두 번 올린다 (앞선 실행이 약 2분 도는 동안)"
    expected: "앞선 실행이 cancelled 로 끝난다"
    why_human: "실행이 지금까지 1건이라 취소가 일어난 적이 없다 (truth 23, behavior-unverified)"
  - test: "아래 'Prohibitions' 표의 P1 ~ P16 을 증거와 함께 읽고 건마다 확정한다"
    expected: "P1 · P2 · P4 ~ P9 · P13 ~ P16 은 증거가 분명하다. P3 (돌리지 않았다는 증명 불가) · P10 (입력된 명령은 기록뿐) · P11 (해당 상황 없음) 은 소유자의 판단이 들어간다. P12 의 tag 쪽은 2026-10-12 소유자 결정(D-10 덧붙임)으로 정리됐다"
    why_human: "16건 모두 계획이 verification: judgment 로 둔 것이라 검증기의 판정은 참고용이다 (unverified-prohibition — human review recommended)"
  - test: "아래 '다음 phase 가 알아야 할 것' 의 1 · 2 를 읽고, Phase 4 (규칙마다 --update) 전에 닫을지 그대로 둘지 정한다 — (a) [2/4] 가 통과로 잘못 찍히는 세 입력에서 --update 가 망가진 정답지를 쓰고 종료 코드 0 으로 끝난다, (b) example/README.md 80행과 [2/4] 의 실패 문구가 'rules: 목록이 비어 있거나 없으면' 이라고 말하지만 코드는 rules: 키를 보지 않는다"
    expected: "닫는다면 gap 닫기 plan 을 하나 더 세운다. 두면 README 80행 · 30행의 문장을 코드가 실제로 보는 것에 맞출지 정한다"
    why_human: "이 phase 의 성공 기준은 깨지지 않는다 (보통 실행은 세 입력 모두 종료 코드 1 이다). 남은 위험을 받아들일지는 소유자의 결정이다"
---

# Phase 2: Verification Harness 검증 보고서

**Phase Goal:** `lib/` 를 바꾸기 전에 1.3.0 의 동작이 기대 진단(golden)으로 고정되어 있고, 소유자와 CI 가 같은 명령 하나로 "배포 설정이 기대한 대로 적용되는가"를 판정할 수 있다
**Verified:** 2026-10-12T01:39:49Z (한국 시각 2026-10-12 10:39), HEAD `c2f5e94`, 브랜치 `gsd/v2.0-package-rework` (`origin` 의 같은 브랜치는 `1f06c55` 그대로)
**Status:** human_needed
**Re-verification:** Yes — gap 닫기 plan 02-05 뒤 (이전 보고서: `c885f71`, `gaps_found`, 23/26)

## 한눈에

- **Gap 1 은 닫혔다.** 정답지 비교가 건수를 센다. 같은 줄이 정답지에 두 번 / 실제에 두 번인 두 입력을 이 저장소에서 직접 만들어 둘 다 종료 코드 1 을 봤다. 고치기 전 스크립트(`19ae5ec`)를 복사본에 넣어 같은 입력이 종료 코드 0 이던 것도 다시 봤다.
- **로드맵 성공 기준 1 ~ 4 는 내가 만든 변경으로 확인됐다.** 성공 기준 5 는 push 쪽과 시간 제한을 GitHub 조회로 확인했고, PR 쪽은 선언뿐이라 사람 확인으로 남는다.
- **1.3.0 의 동작은 고정되어 있다.** `lib` 는 `90a2736` · `v1.3.0` 과 같고, 정답지는 `19ae5ec` 와 같으며, 스크립트 밖에서 직접 분석한 16건이 정답지 16줄과 건수까지 같다. 배포 파일에서 규칙 하나를 지우면 `[4/4]` 가 실패한다.
- **gap 은 없다. 사람 확인이 9건 남는다** (이전 보고서의 7건 중 6번은 소유자 결정으로 정리되어 뺐고, 02-05 가 만든 것 1건 · push 뒤에만 볼 수 있는 것 1건 · 소유자 결정 1건을 더했다).
- 재리뷰(02-REVIEW.md `d19aa08`)의 주장은 모두 재현됐다. 어느 것도 이 phase 의 성공 기준을 거짓으로 만들지 않는다. 다만 Phase 3 · 4 가 반드시 알아야 할 사실이 넷 있다 (아래 "다음 phase 가 알아야 할 것").
- REQUIREMENTS.md 의 체크 표시에 어긋난 것이 하나 있다: **`VERIFY-07` 이 미완료(`[ ]`, 표에는 `Gaps Found`)로 남아 있는데 증거는 충족이다.** 반대로 `VERIFY-04` 의 `[x]` 는 PR 쪽 증거보다 앞서 있다.

진술의 표시.

| 표시 | 뜻 |
|------|----|
| **실행** | 이번 검증에서 내가 명령을 돌려 출력과 종료 코드를 본 것 |
| **조회** | GitHub / git 원격을 읽기만 한 것 |
| **읽기** | 파일을 읽거나 grep / 파서로만 확인한 것 |
| **확인 불가** | 이 환경에서는 일으킬 수 없는 것 |

실행 자리: "저장소" 는 이 작업 트리에서 변경 하나를 만들고 돌린 뒤 그 경로만 되돌린 것(`fvm dart run tool/verify.dart`), "복사본" 은 scratchpad 에 `git archive HEAD` 로 풀어 놓은 사본에서 CI 와 같은 꼴(`dart run tool/verify.dart`, 저장소의 `.fvm/flutter_sdk/bin/dart`)로 돌린 것이다. `--update` 는 복사본에서만 돌렸다. 출력 원문은 scratchpad 의 `verifier-e1Vp3h/out/` 에 `r01` ~ `r10` (저장소), `c00` ~ `c25` (복사본) 로 남겼다.

## Goal Achievement

### Observable Truths

로드맵 성공 기준 5개(1 ~ 5)가 계약이다. 6 ~ 26 은 계획 02-01 ~ 02-04 의 truths, 27 ~ 30 은 02-05 의 truths 다 (02-05 의 첫째 truth 는 1번, 여섯째 · 일곱째는 11번과 겹쳐 합쳤다).

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | (SC 1) 명령 하나로 `example/` 분석 결과가 정답지와 비교되어 같으면 성공, 다르면 실패. 정답지에 추가 규칙 · 기반 세트 규칙 · `riverpod_lint` 진단이 각각 한 건 이상 | ✓ VERIFIED | **실행(저장소)**: 변경 없음 → exit 0, `점검 통과 (4개 중 4개)` (`r00`). 정답지에 같은 줄 2개 → exit 1, `정답지에는 있는데 나오지 않은 경고 (1)` (`r01`). 실제에 같은 줄 2건 → exit 1, `정답지에 없는데 나온 경고 (1)` (`r02`). 양쪽 2건 → exit 0 (`r03`). 규칙 삭제 → exit 1 (`r04`). include 삭제 → exit 1 (`r07`). **실행(복사본)**: 강도 변경 → exit 1 (`c23`), 정답지 없음 → exit 1 (`c22`). 세 종류: 직접 분석한 16건 중 추가 규칙만의 것 6 · `prefer_is_empty` 1 · `riverpod_lint` 3 |
| 2 | (SC 2) 배포 파일에 deprecated / removed / 없는 규칙을 하나 넣으면 같은 명령이 실패 | ✓ VERIFIED | **실행(저장소)**: `unnecessary_await_in_return` → `[2/4]` 실패 `deprecated_lint`, exit 1. `avoid_returning_null` → `removed_lint`, exit 1. `no_such_rule_verifier_probe` → `undefined_lint` + `[4/4]` 도 `included_file_warning` 으로 실패, exit 1 (`r05-*`). 세 번 모두 되돌린 뒤 `git diff --quiet 90a2736 -- lib` rc=0. 범위는 `lib/analysis_options.yaml` 에 **직접 적힌** 규칙이다 (아래 "다음 phase" 3) |
| 3 | (SC 3) `lib/` 에 `.dart` 파일을 하나 두면 같은 명령이 실패 | ✓ VERIFIED | **실행(저장소)**: 빈 `lib/_verifier_probe.dart` → `[1/4]` 실패, 경로 표시, exit 1 (`r06`). 지운 뒤 `lib` 의 `.dart` 0개 |
| 4 | (SC 4) 규칙 하나를 지운 변경과 include 줄을 지운 변경을 실제로 만들어 실패를 확인한 기록이 있다 | ✓ VERIFIED | **읽기**: `example/README.md` 의 M1 · M2 행 (표 9행 + 추가 실측 5행). **실행**: 두 변경을 다시 만들어 기록과 같은 화면 — M1: 빠진 줄 `lib/added_rules.dart:24  info  prefer_final_locals`, exit 1 (`r04`) / M2: `[3/4]` · `[4/4]` 실패, 빠진 줄 16 · 남는 줄 `lib/should_not_appear.dart:5  warning  invalid_annotation_target`, exit 1 (`r07`) |
| 5 | (SC 5) push 와 PR 마다 GitHub Actions 가 같은 명령을 실행하고 job 에 시간 제한이 있으며 실제로 성공한 실행이 한 번 이상 | ? UNCERTAIN (부분) | **조회**: `gh run list --workflow verify` = 1건 — run `38158088016`, event `push`, `1f06c55`, `completed` / `success`, job 17:04:14Z ~ 17:06:08Z. 로그에 `Run dart run tool/verify.dart` 와 단계 4개 통과 · `점검 통과 (4개 중 4개)`. **읽기**: PyYAML 로 읽은 `timeout-minutes` = 10, `on` = `push` / `pull_request` / `workflow_dispatch` (필터 없음). **확인 불가**: PR 에서의 실행 (`gh pr list --state all` = 0건), 그리고 HEAD 의 스크립트가 runner 에서 도는 것 (올라가지 않았다) → 사람 확인 4 · 5 |
| 6 | 정답지는 `exit 2` + 16줄 — 규칙 12개가 각 한 줄, `prefer_is_empty` 한 줄, `riverpod_lint` 세 줄 | ✓ VERIFIED | **실행(복사본)**: `example/` 에서 `dart --suppress-analytics analyze --format=json` 을 스크립트와 따로 돌림 — rc=2, 진단 16건, 정답지 16줄과 건수까지 같음, 중복 줄 0 |
| 7 | `invalid_annotation_target` 샘플과 생성 파일 샘플이 있지만 정답지에 그 진단이 없다 (헛통과 아님) | ✓ VERIFIED | **실행**: include 를 지우면 `+ lib/should_not_appear.dart:5  warning  invalid_annotation_target` 이 나타난다 (`r07`) — 평소에는 배포 파일이 억제하고 있다는 뜻. exclude 2종의 삭제는 이번에 다시 만들지 않았다 (이전 검증의 실행 + `example/lib` · `lib` 가 그때와 같음: `git diff --quiet 1f06c55 -- example/lib` rc=0) |
| 8 | `example/pubspec.lock` 이 커밋 대상이고 루트 `pubspec.lock` 은 무시된다 (D-05) | ✓ VERIFIED | **실행**: `git check-ignore -q example/pubspec.lock` rc=1, `git check-ignore -q pubspec.lock` rc=0, 추적 중인 `pubspec.lock` 1개 |
| 9 | `example/analysis_options.yaml` 은 include 한 줄이다 | ✓ VERIFIED | **읽기**: 파일 1줄. **실행**: `[3/4]` 통과 |
| 10 | 루트 `fvm dart analyze` 가 `No issues found` | ✓ VERIFIED | **실행**: `No issues found!`. `fvm dart format --output=none --set-exit-if-changed tool example/lib` rc=0 |
| 11 | `lib/` 는 `90a2736`, `pubspec.yaml` · `README.md` 는 `968a5bb`, `CHANGELOG.md` 는 `2a9725e`, `.fvmrc` 는 `3a15da8`, 정답지는 `19ae5ec` 와 같고 임시 변경이 남지 않았다 | ✓ VERIFIED | **실행**: 여섯 `git diff --quiet` 모두 rc=0, `git diff --quiet v1.3.0 -- lib` rc=0, `lib` 의 `.dart` 0개, `build/` 없음, `example/lib/dup_probe.dart` · `lib/_probe_rules.yaml` 없음 |
| 12 | 명령 한 번으로 단계 4개가 모두 돌고 `점검 통과 (4개 중 4개)`, 종료 코드 0 (VERIFY-03) | ✓ VERIFIED (coincidental-reliance) | **실행**: 저장소 exit 0 (5초), 새 복사본 exit 0 (plugin 처음 준비 포함 17초). plugin 이 3.1.9 로 풀린다는 전제는 `coincidental_reliance_items` |
| 13 | 규칙 검사는 배포 파일을 `plugins:` 없이 `build/woody_rule_check/` 에 복사해 분석하고 끝나면 지운다 | ✓ VERIFIED | **실행**: 실패 줄의 경로가 `build/woody_rule_check/analysis_options.yaml:41`. 통과 · 실패 실행 뒤 모두 `build` 없음 |
| 14 | `example/` 옵션 파일이 include 한 줄이 아니면 `[3/4]` 가 실패 | ✓ VERIFIED | **실행**: 빈 파일 → `[3/4]` 실패 (`r07`, `c01`) |
| 15 | 실행 중인 SDK 가 `.fvmrc` 와 다르면 시작하지 않고 종료 코드 78 (D-12) | ✓ VERIFIED | **실행(복사본)**: `.fvmrc` 를 `0.0.0` 으로 → stdout 0줄, 안내 두 줄, exit 78 (`c20`). Flutter 밖의 dart 와 `FLUTTER_ROOT` 경로는 일으켜 보지 않았다 |
| 16 | 화면 맨 위에 실제로 쓰인 버전 세 줄 (D-07) | ✓ VERIFIED (coincidental-reliance) | **실행**: `SDK        Flutter 3.47.5 / Dart 3.13.4` · `기반 세트  flutter_lints 6.0.0 / lints 6.1.0` · `plugin     riverpod_lint 3.1.9`. CI 로그도 같다. plugin 줄의 한계는 `coincidental_reliance_items` |
| 17 | 화면은 안내형이다 — 단계별 통과·실패, 두 목록, 단계마다 다른 다음 할 일, 요약 (D-13) | ✓ VERIFIED | **실행**: 단계 1 · 2 · 3 · 4 와 plugin 준비 실패(`c08`)의 안내 문구가 서로 다르다. 도구 사망의 안내는 **읽기만**. "읽히는가" → 사람 확인 1 |
| 18 | `--update` 는 갱신 전에 줄 단위 변화를 보여 주고 머리 주석을 실제 버전·날짜로 다시 쓰며 CI 에서는 64 로 거부된다 (D-14) | ✓ VERIFIED | **실행(복사본)**: `- lib/base_rules.dart:22  info  avoid_print` 를 보여 준 뒤 씀, exit 0 (`c02`). `CI=true` · `GITHUB_ACTIONS=true` 각각 exit 64, 정답지 sha 불변 (`c03`, `c03b`) |
| 19 | `errors:` 블록과 exclude 2종을 지웠을 때 정답지와 달라졌다는 기록 (D-03) | ✓ VERIFIED | **읽기**: README 표의 M3 · M4 · M5 (계획 02-05 T3 의 자동 검증이 M1 ~ M9 9행을 단언 — 내가 글자 그대로 돌려 rc=0). 세 변경 자체는 이번에 다시 만들지 않았다 |
| 20 | deprecated 규칙은 정답지 비교가 아니라 규칙 이름 단계가 잡는다는 기록 | ✓ VERIFIED | **읽기**: M6 과 읽는 법. **실행**: `[2/4]` 실패 · `[4/4]` 통과 · exit 1 (`r05-unnecessary_await_in_return`) |
| 21 | 기록에 실측 조건과 실행한 명령이 있고 로컬 절대 경로나 토큰이 없다 (D-08) | ✓ VERIFIED | **읽기**: `grep -E '/Users/\|gho_\|ghp_\|github_pat_'` 가 `example/README.md`, `tool/verify.dart`, workflow, 정답지, `CHANGELOG.md` 에서 0건. 화면의 stderr 는 `<repo>` 로 가려진다 (`c08` 에서 **실행**) |
| 22 | CHANGELOG 2.0.0 항목에 `### 그 밖의 변경` 이 있다 | ✓ VERIFIED | **실행**: `git diff --quiet 2a9725e -- CHANGELOG.md` rc=0 (02-03 이 쓴 그대로) |
| 23 | workflow 의 권한은 `contents: read` 뿐이고 겹치는 실행은 `concurrency` 로 취소된다 | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | 권한 — **조회**: 로그의 `Contents: read` / `Metadata: read`. concurrency — **읽기**: `group: ${{ github.workflow }}-${{ github.ref }}`, `cancel-in-progress: true`. 취소는 일어난 적이 없다 (실행 1건) → 사람 확인 7 |
| 24 | 예약 실행 트리거, Flutter 버전 숫자, 캐시가 workflow 에 없다 | ✓ VERIFIED | **읽기**: step 3개 (`actions/checkout@v7`, `subosito/flutter-action@v2`, `dart run tool/verify.dart`). 02-05 T3 의 자동 검증(금지 문자열 0건 단언 포함)을 글자 그대로 돌려 rc=0 |
| 25 | 작업 브랜치가 origin 에 올라갔고 `origin/main` 은 `90a2736`, tag 는 `v1.3.0` 하나 | ✓ VERIFIED | **조회**: `git ls-remote --heads origin` 2줄 (`1f06c55…` 작업 브랜치, `90a2736…` main), tag 는 `v1.3.0` 과 peeled 줄뿐. 원격 tip 은 HEAD 의 조상 |
| 26 | 그 커밋의 `verify` 실행이 `completed` / `success` 이고 로그에 버전 줄, `[4/4] … 통과`, `점검 통과 (4개 중 4개)` | ✓ VERIFIED | **조회**: `gh run view 38158088016 --log` |
| 27 | 같은 줄이 두 번 나오는 입력 둘에서 검증이 실패한 실행 기록이 README 의 M10 · M11 행으로 있고 되돌려졌다 | ✓ VERIFIED | **읽기**: `### 추가 실측` 의 M10 · M11 행. **실행(저장소)**: 두 입력을 다시 만들어 기록과 글자 그대로 같은 줄 (`r01`, `r02`). 되돌림은 11번 |
| 28 | `--update` 는 같은 실행에서 다른 단계가 실패했으면 정답지를 쓰지 않고 `다른 단계가 실패해 정답지를 쓰지 않았다` 를 찍으며 종료 코드 1. 단계 4개가 통과하고 정답지만 다르면 쓰고 `정답지를 썼다: …` 를 찍는다 (소유자 승인 A) | ✓ VERIFIED | **실행(복사본)**: 옵션 파일을 비우고 `--update` → `[3/4]` 실패, 그 문구, `정답지를 썼다` 없음, sha `164b31c253df` 전후 같음, exit 1 (`c01`). 정답지에 중복 줄 + `--update` → `정답지를 썼다: example/expected_diagnostics.txt`, exit 0, 쓴 파일이 원본과 같음 (`c02`). plugin 준비 실패 + `--update` → `[4/4]` 실패 내용만 찍히고 쓰지 않음, sha 불변, exit 1 (`c08`) |
| 29 | `[2/4]` 는 최상위 `linter:` 블록에서 `- 규칙이름` 꼴 줄을 하나도 읽지 못하면 실패하고 안내에 파일 이름을 찍는다. 지금의 파일(규칙 12개)은 통과한다 (소유자 승인 B) | ✓ VERIFIED | **실행**: `linter:` → `lintr:` → `[2/4]` 실패 + `` `lib/analysis_options.yaml` 에서 규칙을 하나도 읽지 못했다 … ``, exit 1 (저장소 `r08`). 규칙 블록을 `lib/_probe_rules.yaml` 로 옮김 → `[2/4]` 만 실패, `[4/4]` 통과, exit 1 (복사본 `c11`). 변경 없음 → `[2/4]` 통과. 이 확인이 놓치는 모양과 잘못 실패하는 모양은 "다음 phase" 2 · 4 |
| 30 | workflow 의 `push:` 윗줄 주석이 "모든 브랜치와 tag 의 push" 와 Phase 6 경고를 말하고 주석을 뺀 YAML 은 `1f06c55` 와 같다. D-10 아래에 2026-10-12 덧붙임 한 줄이 있고 원문은 그대로다 (소유자 결정 C) | ✓ VERIFIED | **실행**: PyYAML 로 읽은 두 파일이 같다 (`equal True`). `git diff b2c0131 HEAD -- …/02-CONTEXT.md` 는 추가 1줄 · 삭제 0줄. **읽기**: workflow 5 ~ 7행. tag push 에서 실제로 도는지는 일으켜 보지 않았다 (GitHub 문서의 동작) |

**Score:** 28/30 truths verified (1 present, behavior-unverified)

검증되지 않은 2건은 5번(PR 쪽이 선언뿐 — 사람 확인 4 · 5)과 23번(취소가 일어난 적 없음 — 사람 확인 7)이다. 둘 다 이 환경에서 일으킬 수 없는 것이고 실패가 아니다.

### Gap 1 은 닫혔는가 — 닫혔다

이전 보고서의 gap: `findDifference` 가 줄의 있고 없음만 견줘, 같은 줄이 여러 건인 입력에서 건수 차이가 종료 코드 0 으로 통과했다.

**고친 것 (읽기).** `tool/verify.dart` 475 ~ 490행의 `subtractLines` 가 `remove` 의 줄마다 남은 횟수를 세어 `from` 에서 그 횟수만큼만 뺀다. 510 ~ 514행의 `findDifference` 는 `missing: subtractLines(expectedLines, actual)`, `unexpected: subtractLines(actual, expectedLines)` 다. `.contains(…)` 비교는 없다.

**재현 (실행, 모두 이 저장소에서 — 변경 하나 → 실행 → 그 경로만 되돌림).**

| # | 입력 | 명령 | 종료 코드 | 결정적인 출력 |
|---|------|------|-----------|---------------|
| `r01` | 정답지 끝에 이미 있는 `lib/base_rules.dart:22  info  avoid_print` 를 한 번 더 적음 (정답지 2개, 실제 1건) | `fvm dart run tool/verify.dart` | **1** | `[4/4] example/ 정답지 비교 ............. 실패` / `정답지에는 있는데 나오지 않은 경고 (1)` / `  lib/base_rules.dart:22  info  avoid_print` / `정답지에 없는데 나온 경고 (0)` / `점검 실패 (4개 중 1개)` |
| `r02` | `example/lib/dup_probe.dart` 2행에 `void twoPrints() { print('x'); print('y'); }`, 정답지에는 `lib/dup_probe.dart:2  info  avoid_print` 를 1줄만 (정답지 1개, 실제 2건) | 같음 | **1** | `[4/4] … 실패` / `정답지에는 있는데 나오지 않은 경고 (0)` / `정답지에 없는데 나온 경고 (1)` / `  lib/dup_probe.dart:2  info  avoid_print` / `점검 실패 (4개 중 1개)` |
| `r03` | 같은 probe 파일, 정답지에 그 줄을 2줄 (대조 — 건수가 맞으면 통과해야 한다) | 같음 | **0** | `[4/4] … 통과` / `점검 통과 (4개 중 4개)` |
| `c15` | 복사본에 고치기 전 스크립트(`git show 19ae5ec:tool/verify.dart`)를 넣고 `r01` 의 입력 | `dart run tool/verify.dart` | **0** | `[4/4] … 통과` / `점검 통과 (4개 중 4개)` — 고치기 전에는 헛통과였다는 확인 |

각 실행 뒤 `git status --short --untracked-files=all -- lib example tool .github` 가 비어 있음을 봤다. 계획 02-05 Task 1 의 `<automated>` 를 글자 그대로 돌린 것도 rc=0 이다.

이전 보고서가 gap 의 근거로 든 `example/README.md` 5행 · 65행의 문장("한 줄이라도 다르면 실패다", "경고가 생기거나 사라지거나 … 실패한다")은 이제 이 입력에서도 참이고, 두 곳 모두 "건수까지 견준다" 가 덧붙어 있다.

**남는 한계 (gap 아님, D-04 의 형식에서 오는 것).** 정답지 한 줄에는 열과 메시지가 없다. 같은 줄 · 같은 강도 · 같은 규칙의 두 진단이 서로 자리를 바꾸는 변화(건수는 같다)는 보이지 않는다. D-04 가 정한 형식이고 이 phase 가 약속한 범위 밖이다.

### Deferred Items

없다.

### Advisory (New Scope, Unevidenced)

없다. 이번에 새로 본 것은 모두 실행으로 재현했고, blocker 로 분류한 것이 없다.

### Required Artifacts

`gsd-tools query verify.artifacts` — 02-01 6/6, 02-02 2/2, 02-03 2/2, 02-04 2/2, 02-05 4/4 (다섯 번 모두 `all_passed: true`). 아래 Details 는 내가 따로 본 것이다.

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `tool/verify.dart` | 검증 명령 전체 + 02-05 의 `subtractLines` · `countDeclaredRules` · `updateTarget` | ✓ VERIFIED | 1099줄. import 는 `dart:convert` · `dart:io` 뿐, `print(` 0건, debt marker 0건. 세 변경 모두 실행으로 동작 확인 |
| `example/expected_diagnostics.txt` | 정답지 — `exit 2` + 16줄 | ✓ VERIFIED | `19ae5ec` 와 같다. 직접 분석 결과와 건수까지 같다 (**실행**) |
| `example/README.md` | 설명 + M1 ~ M9 + `### 추가 실측` 의 M10 ~ M14 | ✓ VERIFIED (문구 1곳 주의) | M10 ~ M14 다섯 행과 불릿의 사실을 모두 다시 실행해 맞음을 확인. 30행의 "plugin 준비 실패 … 에서는 전과 같이 쓰지 않는다 — 그때는 이 문구 대신 `[4/4]` 의 실패 내용이 찍힌다" 는 SUMMARY 가 읽기로만 썼다고 밝힌 문장인데, plugin 준비 실패 쪽은 이번에 **실행**으로 맞음을 봤다 (`c08`). 도구 사망 쪽은 여전히 읽기뿐이다. 80행의 "`rules:` 목록이 비어 있거나 없으면" 은 코드보다 넓게 말한다 (아래 Anti-Patterns) |
| `.github/workflows/verify.yml` | 트리거 셋, 읽기 권한, concurrency, timeout 10, `.fvmrc`, 명령 한 줄 + 바로잡은 주석 | ✓ VERIFIED (구성) | 주석을 뺀 YAML 이 `1f06c55` 와 같다 (**실행**). PR · 수동 실행 · 취소는 **확인 불가** |
| `.planning/phases/02-verification-harness/02-CONTEXT.md` | D-10 아래 덧붙임 한 줄 | ✓ VERIFIED | `b2c0131` 대비 추가 1줄뿐 |
| `example/pubspec.yaml` · `pubspec.lock` · `example/lib/*.dart` 7개 · `example/analysis_options.yaml` · 루트 `analysis_options.yaml` · `.gitignore` · `CHANGELOG.md` | 02-01 ~ 02-04 의 산출물 | ✓ VERIFIED (회귀 없음) | 모두 고정 커밋(`1f06c55` 또는 위 11번의 커밋)과 `git diff --quiet` rc=0 — 이전 검증 뒤로 바뀌지 않았다 |

### Key Link Verification

`gsd-tools query verify.key-links` — 02-01 3/3, 02-02 4/4, 02-03 2/2, 02-04 2/3, 02-05 4/4. 02-04 의 셋째는 파일이 아니라 git ref 사이의 연결이라 도구가 판정하지 못한다 (`Source file not found …`) — 조회로 확인했다.

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| `example/analysis_options.yaml` | `lib/analysis_options.yaml` | `include: package:woody_lints/analysis_options.yaml` | ✓ WIRED | **실행**: include 를 지우면 16줄이 사라지고, 배포 파일의 규칙 한 줄을 지우면 정답지의 그 줄이 사라진다 |
| `tool/verify.dart` | `example/expected_diagnostics.txt` | `Expected.read` → `findDifference` → `subtractLines` | ✓ WIRED | **실행**: 건수 차이가 두 방향 모두 실패 (Gap 1 의 약점이 사라졌다) |
| `tool/verify.dart` | `lib/analysis_options.yaml` | `checkRuleNames` 가 `plugins:` 를 뺀 복사본에서 `countDeclaredRules` 와 세 코드를 본다 (읽기만) | ✓ WIRED | **실행**: 규칙 0개 · 문제 규칙 3종 모두 실패. 모든 실행 뒤 `lib` == `90a2736` |
| `tool/verify.dart` | `.dart_tool/woody_verify/example/` | `ANALYZER_STATE_LOCATION_OVERRIDE` | ✓ WIRED | **실행**: `.plugin_manager` 아래 폴더 1개에서 3.1.9 가 읽힌다. 폴더를 하나 더 만들면 `riverpod_lint ?` (`c09`) |
| `tool/verify.dart` | `.fvmrc` | `flutter.version.json` 과 비교 | ✓ WIRED | **실행**: 값을 바꾸면 exit 78 |
| `tool/verify.dart` | `example/pubspec.lock` | `readLockVersion` | ✓ WIRED | **실행**: 화면의 `기반 세트` 줄 |
| `example/README.md` | `tool/verify.dart` | 종료 코드 표, M12 행과 `--update` 불릿의 문구 | ✓ WIRED | **실행**: 0 / 1 / 64 / 70 / 78 을 일으켰다 (69 는 이번에 일으키지 않음). `다른 단계가 실패해 정답지를 쓰지 않았다` 가 화면과 README 에서 글자 그대로 같다 |
| `.github/workflows/verify.yml` | `tool/verify.dart` | `run: dart run tool/verify.dart` | ✓ WIRED | **조회**: CI 로그 |
| `.github/workflows/verify.yml` | `.fvmrc` | `flutter-version-file: .fvmrc` | ✓ WIRED | **읽기** + CI 로그의 `Flutter 3.47.5` |
| `.github/workflows/verify.yml` | `02-CONTEXT.md` | 주석의 "소유자 결정 2026-10-12" → D-10 덧붙임 | ✓ WIRED | **읽기** |
| 로컬 `gsd/v2.0-package-rework` | `origin/gsd/v2.0-package-rework` | `git push` | ✓ WIRED (뒤처짐) | **조회**: 원격 tip `1f06c55` 가 HEAD 의 조상. 02-05 의 커밋 4개와 그 뒤 문서 커밋은 올라가지 않았다 (계획이 그렇게 정했다) |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| `SDK` 줄 | `sdk.flutter` / `sdk.dart` | 실행 중인 dart 근처의 `flutter.version.json` | 예 — `.fvmrc` 를 바꾸면 78 | ✓ FLOWING |
| `기반 세트` 줄 | `readLockVersion(…)` | `example/pubspec.lock` | 예 | ✓ FLOWING |
| `plugin` 줄 | `readPluginVersion(stateDir)` | 전용 상태 폴더의 `.plugin_manager/<hash>/pubspec.lock` | 예, 다만 그 실행의 값이 아닐 수 있다 (include 를 지운 `c01` 에서도 `3.1.9`) | ⚠️ 남은 값을 읽는다 (README 에 적힘) |
| 단계 4 의 두 목록 | `difference.missing` / `unexpected` | `dart analyze --format=json` 의 진단 | 예, 건수 포함 | ✓ FLOWING |
| 단계 2 의 문제 줄 | `problems` | 복사본을 분석한 JSON | 예 — 세 코드만 고른다. 그 밖의 진단은 버린다 | ✓ FLOWING (범위가 좁음) |
| 단계 2 의 규칙 수 | `countDeclaredRules(copy)` | **본문의 글자** (analyzer 가 읽은 규칙 수가 아니다) | 대체로. `rules:` 키를 보지 않고, 열 0 의 주석이 블록을 닫는다 | ⚠️ 근사값 ("다음 phase" 2 · 4) |

### Behavioral Spot-Checks

| Behavior | Command / 입력 | Result | Status |
|----------|----------------|--------|--------|
| 기준 실행 (저장소) | `fvm dart run tool/verify.dart` | 버전 3줄, 단계 4개 통과, exit 0, 5초 | ✓ PASS |
| 기준 실행 (새 복사본) | `dart run tool/verify.dart` | exit 0, 17초 (plugin 처음 준비) | ✓ PASS |
| 정답지 독립 대조 (복사본) | `example/` 에서 `dart --suppress-analytics analyze --format=json` | rc=2, 16건, 정답지와 건수까지 같음 | ✓ PASS |
| Gap 1 — 정답지 쪽 중복 (저장소) | `r01` | exit 1, `나오지 않은 경고 (1)` | ✓ PASS |
| Gap 1 — 실제 쪽 중복 (저장소) | `r02` | exit 1, `나온 경고 (1)` | ✓ PASS |
| Gap 1 — 양쪽 2건 (저장소) | `r03` | exit 0 | ✓ PASS |
| Gap 1 — 고치기 전 스크립트 (복사본) | `c15` | exit 0 (헛통과였음) | ✓ PASS (대조) |
| 1.3.0 고정 — 규칙 삭제 (저장소) | `- prefer_final_locals` 줄 삭제 | `[4/4]` 실패, 빠진 줄 1, exit 1 | ✓ PASS |
| deprecated / removed / 없는 규칙 (저장소) | 세 규칙을 하나씩 추가 | 세 번 모두 `[2/4]` 실패, exit 1 | ✓ PASS |
| `lib/` 의 `.dart` (저장소) | 빈 `lib/_verifier_probe.dart` | `[1/4]` 실패, exit 1 | ✓ PASS |
| include 삭제 (저장소) | `example/analysis_options.yaml` 을 빈 파일로 | `[3/4]` · `[4/4]` 실패, exit 1 | ✓ PASS |
| B — `linter:` → `lintr:` (저장소) | `r08` | `[2/4]` 실패(규칙 0개 문구) + `[4/4]` 실패(6줄), `점검 실패 (4개 중 2개)`, exit 1 | ✓ PASS |
| B — 규칙을 include 뒤로 (복사본) | `c11` | `[2/4]` 만 실패, exit 1 | ✓ PASS |
| A — 망가진 실행의 `--update` (복사본) | `c01` | 쓰지 않음, sha 불변, exit 1 | ✓ PASS |
| A — 정상 경로의 `--update` (복사본) | `c02` | `정답지를 썼다: …`, 원본과 같은 파일, exit 0 | ✓ PASS |
| plugin 준비 실패 + `--update` (복사본) | `bin/plugin.aot` 을 깨뜨림 (`c08`) | `plugin 준비 실패 — riverpod_lint 진단 없이 끝났다 (dart analyze exit 0)`, 쓰지 않음, sha 불변, exit 1. 같은 상태의 보통 실행도 exit 1 | ✓ PASS |
| CI 의 `--update` (복사본) | `CI=true`, `GITHUB_ACTIONS=true` | 각각 exit 64, sha 불변 | ✓ PASS |
| SDK 불일치 (복사본) | `.fvmrc` 를 `0.0.0` 으로 | exit 78 | ✓ PASS |
| 모르는 인자 (복사본) | `--bogus` | 사용법, exit 64 | ✓ PASS |
| 정답지 없음 (복사본) | 정답지를 치움 | `[4/4]` 실패 `정답지가 없다. …`, exit 1 | ✓ PASS |
| 강도 변경 (복사본) | `analyzer.errors` 에 `prefer_final_locals: warning` | `info` 줄이 빠지고 `warning` 줄이 남음, exit 1 | ✓ PASS |
| 기반 세트가 켜는 규칙 삭제 (복사본) | `- avoid_print` 삭제 | exit 0 — 설계대로다 (D-01, 기반 세트가 켠다) | ✓ PASS (설계대로) |
| 루트 분석 · 포맷 | `fvm dart analyze`, `fvm dart format --output=none --set-exit-if-changed tool example/lib` | `No issues found!`, rc=0 | ✓ PASS |
| 계획 02-05 의 자동 검증 원문 | T1 · T3 의 `<automated>` 를 bash 로 글자 그대로 | 둘 다 rc=0 | ✓ PASS |
| GitHub 실행 | `gh run view 38158088016` | `completed` / `success` | ✓ PASS |

02-05 T2 의 `<automated>` 는 글자 그대로 돌리지 않았다 — 이 작업 트리에서 `--update` 를 실행하기 때문이다. 같은 내용(M12, M12 대조, `CI=true`, M13)을 위 표의 실행으로 따로 봤다. 02-VALIDATION.md 가 적은 "11개를 다시 돌렸다" 는 이 둘(T1 · T3)과 02-05 T2 에 해당하는 내 실행에서만 확인했고, 02-01 ~ 02-04 의 여덟 개는 다시 돌리지 않았다.

### Probe Execution

해당 없음. `scripts/*/tests/probe-*.sh` 가 없고 계획과 SUMMARY 가 probe 스크립트를 선언하지 않았다.

### Requirements Coverage

계획이 선언한 ID: 02-01 `VERIFY-01` / 02-02 `VERIFY-01, 02, 03, 07` / 02-03 `VERIFY-08` / 02-04 `VERIFY-04` / 02-05 `VERIFY-01, 02, 03, 04, 08`. REQUIREMENTS.md 가 Phase 2 에 대응시킨 6개와 같다. **ORPHANED 없음.**

REQUIREMENTS.md 의 체크 표시는 실행자가 이 검증 **전에** `requirements.mark-complete` 로 쓴 것이라 주장으로 다뤘다. 마지막 열이 그 표시가 정당한지에 대한 내 판단이다.

| Requirement | Source Plan | Description | Status | Evidence | REQUIREMENTS.md 의 표시 |
|-------------|-------------|-------------|--------|----------|--------------------------|
| VERIFY-01 | 02-01, 02-02, 02-05 | `example/` 이 배포 설정을 include 하고, 기대한 진단이 보고되는지를 정답지와 비교해 판정 | ✓ SATISFIED | **실행**: 16줄 각각 · 건수 · 강도 · 종료 코드의 변화가 실패로 잡힌다 | `[x]` — 정당하다 |
| VERIFY-02 | 02-02, 02-05 | 배포 파일에 deprecated / removed / 없는 규칙이 있으면 실패 | ✓ SATISFIED | **실행**: 세 종류 각각 + 규칙 0개. 범위는 `lib/analysis_options.yaml` 에 직접 적힌 규칙 | `[x]` — 정당하다 (오늘의 파일 구조에서) |
| VERIFY-03 | 02-02, 02-05 | 소유자가 로컬에서 명령 하나로 전체 검증을 실행 | ✓ SATISFIED | **실행**: `fvm dart run tool/verify.dart` 한 줄 | `[x]` — 정당하다 |
| VERIFY-04 | 02-04, 02-05 | GitHub Actions 가 push 와 PR 마다 로컬과 같은 검증을 실행하며 시간 제한이 있다 | ? NEEDS HUMAN (부분) | push · 시간 제한 · 같은 명령은 **조회**로 확인. PR 쪽은 선언뿐 (**확인 불가**) | `[x]` — **증거보다 앞서 있다.** push 절반만 관측됐고 PR 절반은 사람 확인 4 가 끝나야 닫힌다 |
| VERIFY-07 | 02-02 | `lib/` 에 `.dart` 파일이 있으면 실패 | ✓ SATISFIED | **실행**: `[1/4]` 실패, exit 1 (`r06`) | `[ ]`, 표에는 `Gaps Found` — **틀렸다.** 증거는 충족이고, 이전 보고서의 gap 은 VERIFY-07 과 무관했다. 02-05 가 이 ID 를 선언하지 않아 `mark-complete` 가 건드리지 않은 것으로 보인다. orchestrator 가 바로잡을 일이다 (이 검증은 REQUIREMENTS.md 를 고치지 않는다) |
| VERIFY-08 | 02-03, 02-05 | 검증이 실제로 문제를 잡아냄이 확인되어 있다 — 규칙 삭제와 include 삭제가 각각 실패 | ✓ SATISFIED | **읽기**: README 의 기록. **실행**: 두 변경을 다시 만들어 기록과 같은 결과 | `[x]` — 정당하다 |

### Prohibitions (must_haves.prohibitions)

계획 5개의 금지 사항 16건은 모두 `verification: judgment`, `status: unresolved` 다. 아래는 증거를 본 **참고용 판정**이고 확정이 아니다 — 건마다 소유자가 확정한다 (`unverified-prohibition — human review recommended`, 사람 확인 8).

| # | Plan | 금지 사항 | 참고 판정 | 증거 |
|---|------|-----------|-----------|------|
| P1 | 02-01 | `lib/` 와 `pubspec.yaml` 을 바꾸지 않는다. 루트 옵션 파일의 `lib/analysis_options.yaml` 제외는 그대로 | 지켜짐 | **실행**: `git diff --quiet 90a2736 -- lib` rc=0, `968a5bb -- pubspec.yaml` rc=0. **읽기**: 루트 `analysis_options.yaml` 14행 |
| P2 | 02-01 | `example/` 에 `build_runner` / `riverpod_generator` 를 붙이지 않고 workspace 멤버로 만들지 않는다 | 지켜짐 | **실행**: `example/pubspec.yaml` · `pubspec.lock` 이 `1f06c55` 와 같다 (이전 검증이 본 그대로) |
| P3 | 02-01 | `example/` 에서 `flutter pub get` 을 돌리지 않는다 | 흔적 없음 (돌리지 않았다는 증명은 불가) | 옵션 파일이 한 줄이고 `1f06c55` 와 같다 |
| P4 | 02-02 | `lib/analysis_options.yaml` 은 읽기만 — 복사본은 `build/woody_rule_check/` 에만 쓰고 지운다 | 지켜짐 | **실행**: 저장소에서 돌린 모든 실행 뒤 `lib` == `90a2736`, `build` 없음 |
| P5 | 02-02 | `--update` 는 CI 에서 동작하지 않는다 | 지켜짐 | **실행(복사본)**: 두 환경변수 각각 exit 64, sha 불변 |
| P6 | 02-02 | 전용 상태 폴더를 스크립트가 지우지 않는다 | 지켜짐 | **실행**: 실행을 거듭해도 `.plugin_manager` 폴더 1개 (`6ca435cd…`) 유지 |
| P7 | 02-03 | 지워 보기 변경을 커밋하지 않는다 | 지켜짐 | **실행**: `lib` · 정답지 · `example/lib` · `example/analysis_options.yaml` 이 고정 커밋과 같다 |
| P8 | 02-03 | 기록에 로컬 절대 경로와 토큰을 적지 않는다 | 지켜짐 | **읽기**: grep 0건 |
| P9 | 02-03 | CHANGELOG 의 옛 항목과 2.0.0 의 기존 칸을 바꾸지 않는다 | 지켜짐 | **실행**: `2a9725e` 와 같다 |
| P10 | 02-04 | push 는 브랜치 이름 하나만 준 한 줄뿐 — force · `--tags` · `--all` · `main` 없음 | 원격 상태와 일치 (입력된 명령은 확인 불가) | **조회**: heads 2줄, `main` = `90a2736`, tag 는 `v1.3.0` 뿐 |
| P11 | 02-04 | non-fast-forward 로 거부되면 force 하지 않고 멈춘다 | 해당 상황 없음 | 원격 tip 이 HEAD 의 조상 |
| P12 | 02-04 | CI 를 보려고 PR 을 열지 않는다. tag 트리거도 넣지 않는다 | 지켜짐 (tag 쪽은 소유자 결정으로 정리) | **조회**: PR 0건. `tags:` 키 없음. 필터 없는 `push:` 가 tag 에서도 도는 것은 2026-10-12 소유자 결정으로 그대로 둔다 (D-10 덧붙임) |
| P13 | 02-05 | workflow 의 키와 값은 바꾸지 않는다 — 주석만. `branches:` · `tags:` 를 넣지 않는다 | 지켜짐 | **실행**: 주석을 뺀 YAML 이 `1f06c55` 와 같다. `on.push` = null |
| P14 | 02-05 | WR-01 case 2 (plugin 버전 `?` 일 때 `--update` 거부)는 넣지 않는다 | 지켜짐 | **읽기**: `plugin.version == null` 분기 없음. **실행**: `?` 인 실행의 `--update` 가 쓴다 (`c09`) |
| P15 | 02-05 | WR-03 의 다른 절반 (세 코드 밖의 진단으로 `[2/4]` 를 실패시키거나 찍는 것)은 넣지 않는다 | 지켜짐 | **읽기**: `ruleProblemCodes` 는 세 코드 그대로. **실행**: 겹친 규칙 + 없는 진단 코드에서 `[2/4]` 통과 (`c06`) |
| P16 | 02-05 | D-10 원문은 고치지 않고 덧붙임 한 줄만. 02-01 ~ 02-04 PLAN.md 와 02-REVIEW-DISPOSITION.md 는 건드리지 않는다 | 지켜짐 (DISPOSITION 은 plan 밖에서 갱신됨) | **실행**: CONTEXT 의 diff 는 추가 1줄. `git log c885f71..HEAD -- 02-0[1-4]-PLAN.md` 0건. DISPOSITION 은 `c2f5e94` (검증 꼬리의 재리뷰 반영)가 바꿨고 02-05 의 커밋 4개는 건드리지 않았다 |

### Anti-Patterns Found

02-05 가 바꾼 세 파일(`tool/verify.dart`, `example/README.md`, `.github/workflows/verify.yml`)과 Phase 2 의 나머지 산출물을 훑었다.

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| (전체) | - | `TBD` / `FIXME` / `XXX` / `TODO` / `HACK` / placeholder | - | 0건 |
| `example/README.md` · `tool/verify.dart` | 80 · 710-711 | 문구가 코드보다 넓다 — "최상위 `linter:` 아래 `rules:` 목록이 비어 있거나 없으면 실패" 인데 코드는 `rules:` 키를 보지 않는다 | ⚠️ Warning | `rules:` 를 `rulez:` 로 바꾸면 규칙이 하나도 적용되지 않는데 `[2/4]` 는 통과한다 (`r09`). 전체 판정은 `[4/4]` 가 실패시킨다 (exit 1). 사람 확인 9 |
| `example/README.md` | 30 | "같은 실행에서 다른 단계가 실패했으면 정답지를 쓰지 않는다" — 글자 그대로는 참이지만 "망가진 실행은 막힌다" 로 읽기 쉽다 | ⚠️ Warning | `[2/4]` 가 통과로 **잘못** 찍히는 세 입력에서는 `--update` 가 쓰고 exit 0 이다 ("다음 phase" 1) |
| `tool/verify.dart` | 622-637 | `countDeclaredRules` 가 `linter:` 블록 안의 열 0 주석에서 블록을 닫는다 | ⚠️ Warning | 멀쩡한 파일을 규칙 0개로 세어 `[2/4]` 가 잘못 실패한다 (`c14`). 크게 실패하는 쪽이라 판정이 조용히 틀리지는 않는다 ("다음 phase" 4) |
| `tool/verify.dart` | 402 | 함수 이름 `pluginFolders` 가 동사로 시작하지 않음 | ℹ️ Info | 소유자의 전역 규칙과 다르다. 계획의 `<interfaces>` 가 정한 이름 |
| `.github/workflows/verify.yml` | 28, 31 | action 이 움직이는 major tag (`@v7`, `@v2`) | ℹ️ Info | 토큰 권한은 읽기뿐 |

blocker 는 없다.

### 재리뷰(02-REVIEW.md, `d19aa08`)의 주장에 대한 내 판단

리뷰의 등급을 물려받지 않고 건마다 다시 돌렸다. 분류는 셋이다 — **목표를 깬다** / **약속 밖의 edge** / **다음 phase 가 알아야 할 사실**.

| 주장 | 재현 (내 실행) | 내 판단 |
|------|----------------|---------|
| **WR-08** — 규칙 수 세기가 `rules:` 키를 보지 않아, `rules:` 를 잘못 적은 배포 파일에서 `[2/4]` 가 통과한다 | 재현됨. 저장소에서 `  rules:` → `  rulez:` (`r09`): `[2/4] 통과`, `[4/4] 실패` — 빠진 줄 6 (`lib/added_rules.dart`), 남는 줄 `analysis_options.yaml:1  warning  included_file_warning`, `점검 실패 (4개 중 1개)`, **exit 1** | **약속 밖의 edge + 다음 phase 의 사실.** 명령은 실패한다 — 성공 기준 1 · 2 와 02-05 의 truth("`- 규칙이름` 꼴 줄을 하나도 읽지 못하면 실패")는 그대로 참이다. 틀린 것은 원인을 가리킬 단계가 통과로 찍히는 것과, README 80행 · 실패 문구가 코드보다 넓게 말하는 것이다 |
| **가로지르는 관찰** — 새 `--update` 안전장치는 "실패로 찍힌 단계" 만 봐서, `[2/4]` 가 통과로 잘못 찍히는 입력에서는 망가진 정답지를 쓰고 exit 0 | 재현됨, 복사본에서 세 입력 모두. (a) 닫지 않은 따옴표 (`c04`): 단계 넷 `통과`, `종료 코드: 정답지 2, 실제 3`, `정답지를 썼다`, `점검 통과 (4개 중 4개)`, **exit 0** — 쓰인 정답지는 `exit 3` + `lib/should_not_appear.dart:5  warning  invalid_annotation_target` 한 줄. (b) `rulez:` (`c05`, 리뷰어가 돌리지 않은 것): exit 0 — 정답지가 `exit 2` + 11줄 (`included_file_warning` 1줄 포함, 추가 규칙 6줄 사라짐). (c) 겹친 규칙 + 없는 진단 코드 (`c06`): exit 0 — `included_file_warning` 2줄이 정답지에 들어감 | **이 phase 의 목표는 깨지 않는다. Phase 4 가 반드시 알아야 할 사실이다.** 세 입력 모두 보통 실행은 exit 1 로 실패한다 (`r10`, `r09`, `c06-plain`) — "같은 명령 하나로 판정" 은 성립한다. `--update` 는 "지금의 결과를 정답으로 받아들인다" 는 명시적 행동이고, 바뀌는 줄(16줄이 사라짐 등)은 쓰기 전에 화면에 나온다 (D-14 의 문장은 지켜진다). 그러나 Phase 4 는 규칙마다 `--update` 를 돌린다 — 배포 파일을 고치다 YAML 을 깨뜨린 채 보통 실행 없이 `--update` 부터 돌리면 `점검 통과` 와 exit 0 을 받는다. 닫을지는 소유자가 정한다 (사람 확인 9) |
| **WR-01 case 2** — plugin 버전이 `?` 인 실행의 `--update` 가 머리 주석에 `riverpod_lint ?` 를 쓴다 (소유자 결정으로 열어 둠) | 재현됨 (`c09`): `.plugin_manager` 에 빈 폴더를 하나 더 → `plugin     riverpod_lint ? (저장소 경로가 바뀐 적 있다 — …)`, `정답지를 썼다`, exit 0, 정답지 첫 줄 `# 실측: … riverpod_lint ?, 2026-10-12` | **약속 밖의 edge (소유자가 열어 둔 것) + Phase 3 의 사실.** 진단 줄은 바뀌지 않고 머리 주석만 바뀐다. README 가 이 한계를 적어 두었다 |
| **WR-03 의 남은 절반** — 세 코드 밖의 진단을 `[2/4]` 가 버린다 (소유자 결정으로 열어 둠) | 재현됨 (`c06-plain`): 겹친 `- avoid_print` + `no_such_diagnostic_code: ignore` → `[2/4] 통과`, `[4/4] 실패` — `analysis_options.yaml:1  warning  included_file_warning` 2줄, exit 1 | **약속 밖의 edge.** 명령은 실패한다. 무엇이 문제인지는 화면에서 알 수 없다 (줄 번호 · 코드 없는 같은 줄 둘). Gap 1 이 닫혀 그 줄의 건수 변화는 이제 잡힌다 |
| **WR-02** — YAML 이 깨진 배포 파일에서 `[2/4]` 가 통과로 찍힌다 | 재현됨 (`r10`, 저장소): `[2/4] 통과`, `[4/4] 실패`, `종료 코드: 정답지 2, 실제 3`, 빠진 줄 16, exit 1. `parse_error` 는 화면에 없다 | **약속 밖의 edge.** 명령은 실패한다. `--update` 쪽은 위 "가로지르는 관찰" (a) |
| **IN-07** — `countDeclaredRules` 가 멀쩡한 YAML 몇 가지를 0개로 센다 | 한 모양을 재현 (`c14`): `linter:` 바로 아래 열 0 에 `# 규칙 목록` 한 줄 → `[2/4]` 실패(규칙 0개 문구), `[4/4]` 통과, exit 1 | **다음 phase 의 사실.** 잘못된 실패이지만 크게 실패한다. 지금의 배포 파일에는 그런 줄이 없다 |
| **CR-01 닫힘** | 위 Gap 1 절 | 동의한다 |
| **WR-07 닫힘** | truth 30 | 동의한다 (동작은 그대로, 주석과 기록이 맞춰졌다) |
| WR-04 · WR-05 · WR-06 · IN-01 ~ IN-06 · IN-08 | 이번에 다시 돌리지 않았다. 이전 검증에서 WR-05 · WR-06 · IN-03 을 실행으로 재현했고 02-05 는 그 코드를 건드리지 않았다 | 이전 판단 그대로 — 성공 기준에 영향 없음. WR-06 은 Phase 6 이 버전을 올릴 때 만난다 |

### 다음 phase 가 알아야 할 것 (gap 아님, 실행으로 확인한 사실)

1. **(Phase 4) `--update` 는 "실패로 찍힌 단계가 있는가" 만 본다.** 배포 파일의 YAML 이 깨졌거나(`c04`), `rules:` 키가 틀렸거나(`c05`), 세 코드 밖의 경고가 있을 때(`c06`) `[2/4]` 는 통과로 찍히고, 그 상태의 `--update` 는 망가진 결과를 정답지로 쓰고 `점검 통과 (4개 중 4개)` · exit 0 으로 끝난다. 규칙을 고친 뒤에는 `--update` 보다 **보통 실행을 먼저** 돌리고, `--update` 가 보여 주는 `- ` 줄이 의도한 것뿐인지 읽는다. 정답지의 `exit` 줄이 3 이 되거나 `analysis_options.yaml:1  warning  included_file_warning` 줄이 들어가면 배포 파일이 깨진 것이다.
2. **(Phase 3 · 4) `[2/4]` 의 "규칙 0개" 확인은 글자를 센다.** analyzer 가 실제로 읽은 규칙 수가 아니다. `rules:` 키의 오타는 통과하고(`r09`), `linter:` 블록 안의 열 0 주석은 잘못 실패시킨다(`c14`). 맵 형식(`rule: true`)도 0 으로 센다 (계획이 적어 둔 가정, 일으켜 보지 않음).
3. **(Phase 3) `[2/4]` 는 대상 파일에 직접 적힌 규칙만 본다.** 규칙을 include 뒤로 **전부** 옮기면 `[2/4]` 가 실패한다(`c11`) — 02-05 가 넣은 확인이 이것을 잡는다. 그러나 대상 파일에 규칙이 하나라도 남아 있으면 include 뒤의 파일에 넣은 deprecated 규칙은 **어느 단계도 잡지 못한다**: `lib/_probe_rules.yaml` 에 `unnecessary_await_in_return` 을 두고 배포 파일(규칙 12개 그대로)이 그 파일을 include 하게 하면 단계 4개가 모두 통과하고 exit 0 이다 (`c12`). 프리셋을 나눈 뒤에는 규칙이 적힌 **모든** 파일이 `[2/4]` 의 대상이어야 한다 (로드맵 Phase 3 의 Notes 가 요구하는 확인).
4. **(Phase 3) 규칙과 `plugins:` 를 함께 다른 파일로 옮기고 `lib/analysis_options.yaml` 을 include 한 줄 별칭으로 두면 exit 70** — `lib/analysis_options.yaml 에서 plugins: 섹션을 찾지 못했다`, stdout 0줄 (`c13`). 조용히 통과하지 않는다. 스크립트의 `stripPlugins` 와 대상 경로를 함께 고쳐야 넘어간다.
5. **(Phase 3) plugin 버전 줄과 `--update` 의 머리 주석.** plugin 을 선언하지 않는 fixture(대조군)에서는 `plugin` 줄이 상태 폴더에 남은 값을 그대로 찍거나 `?` 가 되고, `?` 인 실행의 `--update` 는 머리 주석에 `riverpod_lint ?` 를 쓴다 (`c09`). fixture 가 둘 이상일 때의 `--update` 쓰기 순서와 화면도 정해져 있지 않다 (IN-08, 돌려 보지 못함 — `fixtures` 가 하나다).
6. **(Phase 3 의 첫 push) 02-05 의 스크립트는 GitHub runner 에서 돈 적이 없다.** 성공한 실행은 `1f06c55` 의 것이다. 올린 뒤 첫 `verify` 실행을 본다 (사람 확인 5).
7. **(Phase 6) 루트 `pubspec.yaml` 의 `version` 을 올리면 exit 69** 가 나고 안내가 `example/pubspec.yaml` 을 가리킨다 (WR-06, 이전 검증에서 재현 — `example/pubspec.lock` 을 다시 받아 커밋하면 풀린다). tag push 에서도 `verify` 가 돈다 (workflow 주석 5 ~ 7행).

### Test Quality Audit

이 phase 에는 테스트 프레임워크가 없다. 검증 명령과 정답지가 곧 테스트다.

| Test File | Linked Req | Active | Skipped | Circular | Assertion Level | Verdict |
|-----------|-----------|--------|---------|----------|-----------------|---------|
| `tool/verify.dart` 단계 4 + `example/expected_diagnostics.txt` | VERIFY-01, VERIFY-08 | 1 | 0 | 형식상 그렇다 — 정답지는 같은 도구의 `--update` 가 쓴다. 독립 근거: `lib` 가 `v1.3.0` 과 같고, 스크립트 밖의 직접 분석과 건수까지 같으며(실행), 내가 만든 변경에 반응한다(실행) | Value (줄 단위 + 건수) | 유효 |
| `tool/verify.dart` 단계 2 | VERIFY-02 | 1 | 0 | 아님 — analyzer 의 진단 코드 3종 + 본문의 규칙 수 | Value | 유효. 규칙 수는 근사값이다 |
| `tool/verify.dart` 단계 1 · 3 | VERIFY-07 등 | 2 | 0 | 아님 | Value | 유효 |
| `.github/workflows/verify.yml` | VERIFY-04 | 1 | 0 | 아님 | Status (명령의 종료 코드) | 유효 |

**Disabled tests on requirements:** 0
**Circular patterns detected:** 0
**Insufficient assertions:** 0 (이전의 1건 — 건수를 보지 않음 — 은 닫혔다)

### Human Verification Required

이전 보고서의 사람 확인 7건은 답을 받은 적이 없다 (`02-UAT.md` 없음). 1 ~ 5 · 7 은 그대로 가져왔고, **6번(tag push 를 어떻게 둘 것인가)은 뺐다** — 소유자가 2026-10-12 에 "동작은 그대로, 주석만 바로잡는다" 로 정했고 그 결정이 workflow 주석과 D-10 덧붙임에 들어가 있다 (truth 30). 새로 더한 것은 3 · 5 · 9 다.

### 1. 안내형 화면이 읽히는가 (02-02 Task 2 의 human-check, D-13)

**Test:** `fvm dart run tool/verify.dart` 를 한 번 돌리고, `lib/analysis_options.yaml` 의 `- prefer_final_locals` 줄을 잠시 주석 처리한 뒤 한 번 더 돌려 두 화면을 `02-CONTEXT.md` 의 미리보기와 나란히 본다. 바꾼 줄은 `git checkout -- lib/analysis_options.yaml` 로 되돌린다.
**Expected:** 통과 화면은 버전 3줄 → 단계 4줄 → `점검 통과 (4개 중 4개)`. 실패 화면은 `[4/4] … 실패` 아래 `정답지에는 있는데 나오지 않은 경고 (1)` 과 `lib/added_rules.dart:24  info  prefer_final_locals`, `--update` 안내, `점검 실패 (4개 중 1개)`. 화면만 보고 무엇이 달라졌고 다음에 무엇을 하면 되는지 안다.
**Why human:** 문자열과 순서는 실행으로 확인했다 (`r04`). "안내로 읽히는가" 는 소유자의 판단이다.

### 2. 지워 보기 기록이 읽히는가 (02-03 Task 2 의 human-check, VERIFY-08)

**Test:** `example/README.md` 의 `## 검증이 실제로 잡아내는지 확인한 기록` 절(M1 ~ M9)을 읽는다.
**Expected:** 표만 보고 (1) 규칙 하나를 지우면 어느 줄이 빠지는지, (2) include 를 지우면 16줄이 사라지는 대신 다른 warning 이 나타나 종료 코드가 그대로라는 점, (3) deprecated 규칙은 규칙 이름 검사가 잡는다는 점이 읽힌다.
**Why human:** 내용이 사실과 맞는지는 다시 만들어 확인했다. 몇 달 뒤 이 절만 보고 아는가는 독자의 판단이다.

### 3. 추가 실측 소절이 읽히는가 (02-05 Task 3 의 human-check — 새 항목)

**Test:** `example/README.md` 의 `### 추가 실측 — 건수 비교 · --update 안전장치 · 규칙 0개 (gap 닫기 02-05)` 소절(M10 ~ M14 표와 불릿 다섯)을 읽는다.
**Expected:** (1) 같은 줄이 두 번 나오는 입력에서 어느 쪽 목록에 한 줄이 잡히는지, (2) 다른 단계가 실패한 실행에서 `--update` 가 쓰지 않고 무엇을 찍는지, (3) 규칙을 하나도 읽지 못하면 `[2/4]` 가 실패하고 Phase 3 이 규칙 파일을 옮길 때 무엇을 함께 옮겨야 하는지, (4) "막지 않는 것도 있다" 불릿에서 무엇이 남았는지가 읽힌다.
**Why human:** 다섯 행과 불릿의 사실은 모두 다시 실행해 맞음을 확인했다. 소절만 보고 아는가는 독자의 판단이다.

### 4. pull request 에서 workflow 가 도는가 (성공 기준 5, VERIFY-04)

**Test:** 이 저장소에 PR 이 처음 열릴 때 (Phase 6 의 `main` 병합이 PR 을 거친다면 그때) Actions 탭에 `verify` 실행이 `pull_request` event 로 생기는지 본다.
**Expected:** PR 의 커밋에서 `verify` 가 실행되고 단계 4개가 통과한다.
**Why human:** `pull_request:` 는 필터 없이 선언되어 있지만 PR 이 한 번도 열리지 않았고, D-10 이 점검용 PR 을 미리 열지 않기로 했다.

### 5. 다음 push 뒤 HEAD 의 verify 실행 (성공 기준 5 — 새 항목)

**Test:** 작업 브랜치를 다음에 올린 뒤(D-09 대로 소유자 확인 후) 그 커밋의 `verify` 실행을 본다 — `gh run list --workflow verify --limit 1`.
**Expected:** `completed` / `success`, 로그에 `점검 통과 (4개 중 4개)`.
**Why human:** GitHub 에서 성공한 실행은 `1f06c55` 의 것 하나다. 02-05 가 바꾼 스크립트는 올라가지 않아 Linux runner 에서 돈 적이 없다. 바뀐 것은 플랫폼에 기대지 않는 Dart 로직이고 로컬에서 같은 SDK 로 통과하지만, runner 의 결과는 push 뒤에만 볼 수 있고 push 는 소유자의 확인이 필요하다.

### 6. 수동 실행 버튼 (D-06)

**Test:** workflow 파일이 `main` 에 들어간 뒤 GitHub 의 Actions → verify 화면에서 "Run workflow" 버튼을 눌러 본다.
**Expected:** 버튼이 보이고, 누르면 `workflow_dispatch` event 의 실행이 생겨 통과한다.
**Why human:** 버튼은 기본 브랜치에 workflow 파일이 있어야 나타난다. 릴리스 전에는 볼 수 없다.

### 7. 겹치는 실행의 취소 (truth 23, behavior-unverified)

**Test:** 같은 브랜치에 커밋을 연달아 두 번 올린다 (앞선 실행이 약 2분 도는 동안).
**Expected:** 앞선 실행이 `cancelled` 로 끝난다.
**Why human:** 실행이 지금까지 1건이라 취소가 일어난 적이 없다. 설정은 파일에 있다.

### 8. 금지 사항 16건의 확정

**Test:** 위 "Prohibitions" 표의 P1 ~ P16 을 증거와 함께 읽고 건마다 확정한다.
**Expected:** P1 · P2 · P4 ~ P9 · P13 ~ P16 은 증거가 분명하다. P3 (돌리지 않았다는 증명 불가) · P10 (입력된 명령은 기록뿐) · P11 (해당 상황 없음) 은 소유자의 판단이 들어간다.
**Why human:** 16건 모두 계획이 `verification: judgment` 로 둔 것이라 검증기의 판정은 참고용이다.

### 9. 남은 `--update` 경로와 README 문구를 어떻게 둘 것인가 (새 항목 — 소유자 결정)

**Test:** 위 "다음 phase 가 알아야 할 것" 의 1 · 2 와 "Anti-Patterns" 의 warning 셋을 읽고 정한다 — (a) Phase 4 전에 닫는다 (리뷰가 든 길: `[2/4]` 가 세 코드 밖의 진단도 실패로 치면 `unsupported_option` · 겹친 규칙이 그 단계에서 잡히고 새 안전장치가 `--update` 를 알아서 막는다. 깨진 YAML 은 종료 코드와 JSON 의 어긋남을 따로 봐야 한다), 또는 (b) 그대로 두고 `example/README.md` 80행 · 30행과 `[2/4]` 실패 문구를 코드가 실제로 보는 것에 맞춘다, 또는 (c) 지금 그대로 둔다.
**Expected:** 어느 쪽이든 Phase 4 를 시작하기 전에 정해져 있다.
**Why human:** 이 phase 의 성공 기준은 깨지지 않는다 — 세 입력 모두 보통 실행은 종료 코드 1 이다. 02-05 를 세울 때 소유자가 WR-03 의 이 절반을 일부러 넣지 않기로 했으므로, 재리뷰가 새로 보인 결과(`--update` 가 exit 0 으로 쓴다)를 보고 그 결정을 유지할지는 소유자가 정한다.

### Gaps Summary

**gap 은 없다.** 이전 보고서의 Gap 1 (정답지 비교가 건수를 세지 않음)은 닫혔다 — 두 방향을 이 저장소에서 다시 만들어 둘 다 종료 코드 1 을 봤고, 고치기 전 스크립트로는 같은 입력이 종료 코드 0 이던 것도 다시 봤다.

**로드맵 성공 기준.** 1 · 2 · 3 · 4 는 내가 만든 변경으로 성립함을 확인했다. 5 는 push · 시간 제한 · 성공한 실행 1건을 조회로 확인했고, PR 쪽과 HEAD 스크립트의 runner 실행은 이 환경에서 일으킬 수 없어 사람 확인으로 남는다.

**소유자 승인 A · B · C.** A (`--update` 가 다른 단계가 실패한 실행에서 쓰지 않음)와 B (`[2/4]` 가 규칙 0개면 실패)는 계획이 적은 범위 그대로 동작한다. C 는 주석과 기록뿐이고 workflow 의 YAML 은 바뀌지 않았다. A 와 B 가 **막지 않는** 것은 재리뷰가 짚은 대로이고 모두 재현했다 — 이 phase 의 약속 밖이지만 Phase 3 · 4 가 알아야 한다.

**상태가 `human_needed` 인 이유.** 자동으로 볼 수 있는 것은 모두 통과했고, 사람만 볼 수 있는 것 9건이 남는다 (읽히는가 3, GitHub 에서만 볼 수 있는 것 4, 금지 사항 확정 1, 소유자 결정 1).

**바로잡을 기록 (이 검증이 고치지 않은 것).** REQUIREMENTS.md 의 `VERIFY-07` 이 `[ ]` · `Gaps Found` 로 남아 있다 — 증거는 충족이다. `VERIFY-04` 의 `[x]` 는 PR 쪽 확인(사람 확인 4)보다 앞서 있다.

**검증이 끝난 뒤의 저장소.** `lib` == `90a2736`, 정답지 == `19ae5ec`, `example/lib/dup_probe.dart` · `lib/_probe_rules.yaml` · `build/woody_rule_check` 없음, `fvm dart run tool/verify.dart` exit 0. `git status --short` 는 시작할 때의 네 항목에 이 파일 하나가 더해진 것뿐이다. 상태 폴더 `.dart_tool/woody_verify/` 는 지우지 않았다.

---

_Verified: 2026-10-12T01:39:49Z_
_Verifier: Claude (gsd-verifier)_
