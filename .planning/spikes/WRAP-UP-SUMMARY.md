# Spike Wrap-Up Summary

**Date:** 2026-10-11 (wrap-up 두 번 — 001~006, 이어서 007~008)
**Spikes processed:** 8 (이번 2개, 앞선 wrap-up 6개)
**Feature areas:** `dart analyze` 실행과 결과 판정, `example/` 프로젝트와 정답지, deprecated / removed / 없는 규칙 검사, GitHub Actions CI
**Skill output:** `./.claude/skills/spike-findings-woody-lints/`

idea key 는 `verify-harness-tool-behavior` 하나다. 001~006 은 ROADMAP.md Phase 2 의 "Spike first" 6가지이고, 007 과 008 은 그 6개가 재지 않고 남긴 두 가지(`example/` 이 생긴 뒤의 루트 분석, 상태 폴더의 자리)다. 8개 모두 VALIDATED 이고, 02-CONTEXT.md D-15 의 멈춤 조건에 해당한 것은 없다.

실측 조건: Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64 와 GitHub `ubuntu-latest` (006 만).

## Processed Spikes

| # | Name | Type | Verdict | Feature Area |
|---|------|------|---------|--------------|
| 001 | analyze-invocation-form | standard | ✓ VALIDATED (조건: 사용 통계 전송을 끈다) | `dart analyze` 실행과 결과 판정 |
| 002 | plugin-setup-failure-exit | standard | ✓ VALIDATED | `dart analyze` 실행과 결과 판정 |
| 003 | riverpod-lint-severity-matrix | standard | ✓ VALIDATED | `example/` 프로젝트와 정답지 |
| 004 | fixture-pub-get | standard | ✓ VALIDATED | `example/` 프로젝트와 정답지 |
| 005 | initial-file-rule-status | standard | ✓ VALIDATED | deprecated / removed / 없는 규칙 검사 |
| 006 | github-runner-cold-plugin | standard | ✓ VALIDATED | GitHub Actions CI |
| 007 | root-analysis-with-example | standard | ✓ VALIDATED | `example/` 프로젝트와 정답지 (루트 제외), deprecated / removed / 없는 규칙 검사 (실행 형태) |
| 008 | state-folder-placement | standard | ✓ VALIDATED | `dart analyze` 실행과 결과 판정 |

이번 wrap-up 은 feature area 를 새로 만들지 않았다. 007 과 008 의 결과는 기존 설계도 셋에 들어갔고, CI 설계도에는 두 줄을 덧붙였다.

## 이번 wrap-up 에서 달라진 것 (007, 008)

앞선 wrap-up 의 결론 중 다섯이 바뀌었다. skill 의 references 는 바뀐 뒤의 결론으로 고쳐 썼다.

| 무엇 | 앞선 결론 | 지금의 결론 |
|---|---|---|
| 규칙 검사의 실행 형태 | 루트에서 인자 없이 돌리고 복사본의 진단만 고른다 (005) | 루트에서 복사본 폴더를 인자로 준다 — `dart analyze build/woody_rule_check` (007) |
| 상태 폴더 | 검증 명령은 주지 않아도 된다 (앞선 wrap-up) | `example/` 을 분석할 때 항상 저장소 안의 전용 폴더를 준다 (008) |
| stderr 의 머리말 | 모든 실패에서 stderr 가 머리말로 시작한다 (002) | 컴파일된 파일을 읽지 못한 실패에서는 셋째 줄에 온다. `contains` 로 찾는다 (008) |
| plugin 폴더 이름 | 패키지 루트 절대 경로의 md5 (001) | 링크를 푼 경로의 code unit 을 md5 한 값 (008) |
| plugin 버전을 읽는 자리 | runner 의 기본 자리(`~/.dartServer`)에서 읽었다 (006) | 전용 상태 폴더에서 읽는다. 기본 자리에서는 자기 폴더를 고를 수 없다 (008) |

새로 정해진 것:

1. **루트 `analysis_options.yaml` 의 exclude 에 `example/**` 한 줄을 더한다 (007).** 02-CONTEXT.md 가 계획에 맡긴 항목이다. 기존 `lib/analysis_options.yaml` 제외는 그대로 둔다.
2. **plugin 실패를 알릴 때 "전용 상태 폴더를 지우고 다시 실행"을 함께 안내한다 (008).**
3. **`plugins:` 섹션을 빼는 패턴을 Dart 로 옮겨 돌렸다 (007).** 앞선 wrap-up 에 "Dart 로 옮긴 형태는 아직 실행해 보지 않았다"로 남아 있던 항목이다.

## Key Findings

### 계획을 바꾸는 것

조사 문서의 추정과 달랐거나, 조사 문서에 없던 것이다.

1. **같은 `dart analyze` 가 가끔 종료 코드 255 로 죽는다 (001).** Analysis Server 가 사용 통계를 보내는 도중에 분석이 끝나면 죽는다. 이 컴퓨터에서 기본 방식 65번 중 8번이었다. `--suppress-analytics` 를 붙인 66번은 모두 정상이었다. 검증 명령은 이 플래그를 항상 붙인다.
2. **`riverpod_lint` 규칙은 "전부 warning"이 아니다 (003).** info 3 / warning 11 / error 1 이다. `registerWarningRule` 은 강도가 아니라 "기본으로 켠다"는 뜻이다.
3. **코드 생성 없이 뜨는 규칙 후보는 6개가 아니라 5개다 (003).** `protected_notifier_properties` 는 `@riverpod` 가 붙은 class 에서만 보고한다.
4. **deprecated / removed 보고는 pubspec 의 SDK 하한에 달려 있다 (005).** 배포 파일 복사본을 저장소 밖 임시 폴더에 두면 "없는 규칙"만 잡히고 나머지를 놓친다. 복사본은 저장소 안에 둔다.
5. **SDK tag 의 `rules.json` 은 실제 동작과 어긋날 수 있다 (005).** `unnecessary_await_in_return` 은 `rules.json` 에 stable 로 적혀 있지만 Dart 3.13.0 부터 deprecated 다.
6. **이미 준비된 plugin 도 네트워크가 없으면 쓰지 못한다 (002).** Analysis Server 는 뜰 때마다 `dart pub upgrade` 를 돌린다. 검증에는 네트워크가 필요하다.
7. **`dart:io` / `dart:convert` 만으로는 기본 자리(`~/.dartServer`)에서 자기 plugin 폴더를 고를 수 없다 (008).** 폴더 이름은 md5 인데 md5 가 없고, 폴더 안에 프로젝트 경로가 없고, 재실행은 어느 파일의 시각도 바꾸지 않는다. 전용 상태 폴더를 주면 plugin 폴더가 하나만 생긴다.
8. **컴파일된 plugin 파일이 잘린 채 남으면 서버는 스스로 회복하지 않는다 (008).** `plugin.aot` 이나 상태 폴더를 지울 때까지 계속 실패한다 (exit 0, plugin 진단 없음). 이때 머리말은 stderr 의 셋째 줄에 온다.
9. **같은 빈 상태 폴더를 처음 실행 둘이 동시에 쓰면 드물게 깨진다 (008).** 20쌍 중 1쌍(실행으로는 40번 중 1번)이었다. plugin 폴더에는 잠금이 없다.

### 예상대로 확인된 것

1. `example/` 을 작업 디렉터리로 두고 인자 없이 실행하면 plugin 진단이 처음 실행과 재실행 모두에서 빠짐없이 나온다 (001). 하위 폴더를 인자로 주면 전부 잃는다.
2. plugin 준비가 실패해도 종료 코드는 남은 진단의 강도만 따른다 (002). 4 는 진단이 하나도 없을 때만 나온다. stdout 은 멀쩡한 JSON 이고, stderr 에 `An error occurred while executing an analyzer plugin:` 이 찍힌다.
3. `dart pub get` 은 Flutter 프로젝트에서 되고 옵션 파일을 건드리지 않는다 (004). `flutter pub get` 은 옵션 파일 맨 위에 `build/**` 제외를 써넣는다.
4. 캐시 없는 GitHub Linux runner 에서 plugin 진단이 빠지지 않는다 (006). 새 가상 머신 10대, 분석 60번이 모두 로컬의 기대 진단과 같았다.
5. 루트에 점으로 시작하지 않는 `example/` 이 생기면 루트 분석에 섞인다 (007). 조사 문서가 소스를 읽고 적은 내용이 실행으로 재현됐다: `pub get` 전에는 error 6건(exit 3), 후에는 별도 context root 가 되어 plugin 까지 준비한다(exit 2, 15초). 루트에 `example/**` 를 제외하면 두 상태 모두 0건이고, 그 제외는 `example/` 안에서의 분석을 건드리지 않는다.
6. 상태 폴더의 자리(프로젝트 밖 / 안의 점 폴더 / 안의 평범한 폴더)는 진단도 시간도 바꾸지 않는다 (008).
7. 준비된 상태 폴더를 함께 쓰는 것, 오래 떠 있는 서버(`dart language-server`) 옆에서 쓰는 것, 분석 도중의 Ctrl-C 는 문제가 없었다 (008).

### 확정된 값

| 무엇 | 값 | 출처 |
|---|---|---|
| 정답지 맨 위 줄 | `exit 2` (`missing_provider_scope` + `avoid_public_notifier_properties`) | 003 |
| plugin 준비 실패를 알아채는 문구 | `An error occurred while executing an analyzer plugin:` (`contains` 로 찾는다) | 002, 008 |
| 처음 실행 / 재실행 (로컬) | 약 15~18초 / 약 3.6~6초 | 001, 002, 006, 008 |
| 처음 실행 / 재실행 (GitHub runner) | 약 43초 (27~53초) / 약 8초 | 006 |
| plugin 을 다시 컴파일만 할 때 (로컬) | 약 13초 | 008 |
| CI job 하나 | 약 2분. `timeout-minutes: 10` | 006 |
| pub 서버에 닿지 못할 때 | 26~31초 뒤 plugin 진단 없이 끝남 | 002 |
| `--enforce-lockfile` 이 어긋날 때 | 종료 코드 65 | 004 |
| 지금 선언된 규칙 12개 | deprecated / removed / 없는 규칙 없음 | 005, 007 |
| 루트 분석 (`example/**` 제외가 있을 때) / 규칙 검사 | 0.5초 / 0.5초 | 007 |
| 루트 옵션 파일에 더할 줄 | `example/**` (`example` 만 적어도 같았다) | 007 |
| 전용 상태 폴더의 plugin 폴더 수 | 1 | 008 |

### 다음 phase 로 넘긴 것

- **Phase 3:** include 로 받은 `plugins:` 선언을 사용 프로젝트가 같은 이름으로 다시 선언해 규칙을 하나씩 끌 수 있다 (003). PRESET-07 이 기댈 수 있다. 규칙이 `plugins:` 없는 `base.yaml` 로 옮겨 가면 규칙 검사에서 `plugins:` 를 빼는 단계가 필요 없어진다 (005). 대조군 fixture 처럼 연습용 프로젝트가 더 생기면 폴더마다 루트 제외 줄이 필요할 것이다 (007, 재지 않음).
- **Phase 4:** 프리셋에 `build/**` 와 플랫폼 폴더 제외를 넣을지 (004). 규칙 후보는 `rules.json` 이 아니라 "옵션 파일에 적고 고정 SDK 로 분석"하는 방식으로 걸러야 한다 (005).
- **Phase 5:** README 에 "include 하면 종료 코드 2" 라고 단정하지 않는다 (003).

### 확인하지 않은 것

- plugin 이 뜬 뒤 분석 도중에 죽는 경우 (002)
- pub 서버가 느리게 응답만 하고 끝나지 않는 경우의 시간 (002)
- generator 계열 규칙 6개가 생성 코드 없이도 뜨는지 (003)
- macOS / Windows runner, SDK 캐시를 켰을 때의 CI 시간 (006)
- 하위 폴더 인자 문제가 Dart 3.14 에서 고쳐졌는지 (001, sdk#62710)
- 루트를 IDE 로 열었을 때 example 의 진단이 보이지 않게 되는지 (007)
- 007 과 008 의 실험을 GitHub Linux runner 에서 한 것. 다만 빈 폴더를 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 준 cold 실행은 006 이 runner 에서 30번 돌려 모두 통과했다
- 동시 실행의 실패가 폴더에 잘린 `plugin.aot` 을 남기는지 (008)
- 실제 IDE(VS Code)와 상태 폴더를 함께 쓸 때 (008). `dart language-server` 로 흉내 냈다
- `ANALYZER_STATE_LOCATION_OVERRIDE` 가 사용자 문서에 있는 공식 설정인지 (008). 소스의 문서 주석에는 적혀 있다
- 판정 순서(머리말 → 도구가 죽음 → 정답지 비교)를 한 스크립트로 묶어 돌린 것. 각 조건은 따로 쟀다
- 규칙 검사(폴더를 인자로 준 형태)를 `example/` 의 패키지를 받기 전 상태와, 루트의 패키지를 받지 않은 상태(CI 가 저장소를 새로 받은 직후)에서 돌린 것 (007). 잰 것은 두 패키지가 모두 받아진 상태다
- 전용 상태 폴더를 실제 저장소 안의 자리에 둔 것 (008). 작업 폴더에 복사한 연습용 프로젝트의 밖 / 안의 점 폴더 / 안의 평범한 폴더 세 자리를 쟀고 결과가 같았다
- plugin 준비가 실패한 뒤 전용 상태 폴더에 남는 폴더 수와 `pubspec.lock` 의 유무 (002, 008)
