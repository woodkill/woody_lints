# Spike Wrap-Up Summary

**Date:** 2026-10-11
**Spikes processed:** 6
**Feature areas:** `dart analyze` 실행과 결과 판정, `example/` 프로젝트와 정답지, deprecated / removed / 없는 규칙 검사, GitHub Actions CI
**Skill output:** `./.claude/skills/spike-findings-woody-lints/`

idea key 는 `verify-harness-tool-behavior` 하나다 (ROADMAP.md Phase 2 의 "Spike first" 6가지). 6개 모두 VALIDATED 이고, 02-CONTEXT.md D-15 의 멈춤 조건에 해당한 것은 없다.

실측 조건: Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64 와 GitHub `ubuntu-latest`.

## Processed Spikes

| # | Name | Type | Verdict | Feature Area |
|---|------|------|---------|--------------|
| 001 | analyze-invocation-form | standard | ✓ VALIDATED (조건: 사용 통계 전송을 끈다) | `dart analyze` 실행과 결과 판정 |
| 002 | plugin-setup-failure-exit | standard | ✓ VALIDATED | `dart analyze` 실행과 결과 판정 |
| 003 | riverpod-lint-severity-matrix | standard | ✓ VALIDATED | `example/` 프로젝트와 정답지 |
| 004 | fixture-pub-get | standard | ✓ VALIDATED | `example/` 프로젝트와 정답지 |
| 005 | initial-file-rule-status | standard | ✓ VALIDATED | deprecated / removed / 없는 규칙 검사 |
| 006 | github-runner-cold-plugin | standard | ✓ VALIDATED | GitHub Actions CI |

## Key Findings

### 계획을 바꾸는 것

조사 문서의 추정과 달랐거나, 조사 문서에 없던 것이다.

1. **같은 `dart analyze` 가 가끔 종료 코드 255 로 죽는다 (001).** Analysis Server 가 사용 통계를 보내는 도중에 분석이 끝나면 죽는다. 이 컴퓨터에서 기본 방식 65번 중 8번이었다. `--suppress-analytics` 를 붙인 66번은 모두 정상이었다. 검증 명령은 이 플래그를 항상 붙인다.
2. **`riverpod_lint` 규칙은 "전부 warning"이 아니다 (003).** info 3 / warning 11 / error 1 이다. `registerWarningRule` 은 강도가 아니라 "기본으로 켠다"는 뜻이다.
3. **코드 생성 없이 뜨는 규칙 후보는 6개가 아니라 5개다 (003).** `protected_notifier_properties` 는 `@riverpod` 가 붙은 class 에서만 보고한다.
4. **deprecated / removed 보고는 pubspec 의 SDK 하한에 달려 있다 (005).** 배포 파일 복사본을 저장소 밖 임시 폴더에 두면 "없는 규칙"만 잡히고 나머지를 놓친다. 복사본은 저장소 안에 둔다.
5. **SDK tag 의 `rules.json` 은 실제 동작과 어긋날 수 있다 (005).** `unnecessary_await_in_return` 은 `rules.json` 에 stable 로 적혀 있지만 Dart 3.13.0 부터 deprecated 다.
6. **이미 준비된 plugin 도 네트워크가 없으면 쓰지 못한다 (002).** Analysis Server 는 뜰 때마다 `dart pub upgrade` 를 돌린다. 검증에는 네트워크가 필요하다.

### 예상대로 확인된 것

1. `example/` 을 작업 디렉터리로 두고 인자 없이 실행하면 plugin 진단이 처음 실행과 재실행 모두에서 빠짐없이 나온다 (001). 하위 폴더를 인자로 주면 전부 잃는다.
2. plugin 준비가 실패해도 종료 코드는 남은 진단의 강도만 따른다 (002). 4 는 진단이 하나도 없을 때만 나온다. stdout 은 멀쩡한 JSON 이고, stderr 가 `An error occurred while executing an analyzer plugin:` 으로 시작한다.
3. `dart pub get` 은 Flutter 프로젝트에서 되고 옵션 파일을 건드리지 않는다 (004). `flutter pub get` 은 옵션 파일 맨 위에 `build/**` 제외를 써넣는다.
4. 캐시 없는 GitHub Linux runner 에서 plugin 진단이 빠지지 않는다 (006). 새 가상 머신 10대, 분석 60번이 모두 로컬의 기대 진단과 같았다.

### 확정된 값

| 무엇 | 값 | 출처 |
|---|---|---|
| 정답지 맨 위 줄 | `exit 2` (`missing_provider_scope` + `avoid_public_notifier_properties`) | 003 |
| plugin 준비 실패를 알아채는 문구 | `An error occurred while executing an analyzer plugin:` | 002 |
| 처음 실행 / 재실행 (로컬) | 약 17~18초 / 약 4~6초 | 001, 002, 006 |
| 처음 실행 / 재실행 (GitHub runner) | 약 43초 (27~53초) / 약 8초 | 006 |
| CI job 하나 | 약 2분. `timeout-minutes: 10` | 006 |
| pub 서버에 닿지 못할 때 | 26~31초 뒤 plugin 진단 없이 끝남 | 002 |
| `--enforce-lockfile` 이 어긋날 때 | 종료 코드 65 | 004 |
| 지금 선언된 규칙 12개 | deprecated / removed / 없는 규칙 없음 | 005 |

### 다음 phase 로 넘긴 것

- **Phase 3:** include 로 받은 `plugins:` 선언을 사용 프로젝트가 같은 이름으로 다시 선언해 규칙을 하나씩 끌 수 있다 (003). PRESET-07 이 기댈 수 있다. 규칙이 `plugins:` 없는 `base.yaml` 로 옮겨 가면 규칙 검사에서 `plugins:` 를 빼는 단계가 필요 없어진다 (005).
- **Phase 4:** 프리셋에 `build/**` 와 플랫폼 폴더 제외를 넣을지 (004). 규칙 후보는 `rules.json` 이 아니라 "옵션 파일에 적고 고정 SDK 로 분석"하는 방식으로 걸러야 한다 (005).
- **Phase 5:** README 에 "include 하면 종료 코드 2" 라고 단정하지 않는다 (003).

### 확인하지 않은 것

- plugin 이 뜬 뒤 분석 도중에 죽는 경우 (002)
- pub 서버가 느리게 응답만 하고 끝나지 않는 경우의 시간 (002)
- generator 계열 규칙 6개가 생성 코드 없이도 뜨는지 (003)
- macOS / Windows runner, SDK 캐시를 켰을 때의 CI 시간 (006)
- 하위 폴더 인자 문제가 Dart 3.14 에서 고쳐졌는지 (001, sdk#62710)
