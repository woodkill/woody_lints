---
spike: 001
idea: verify-harness-tool-behavior
name: analyze-invocation-form
type: standard
validates: "Given plugin 이 켜진 연습용 프로젝트, when 그 폴더 안에서 인자 없이 `dart analyze` 를 돌리면, then plugin 진단이 처음 실행(cold)과 재실행(warm) 모두에서 빠짐없이 나온다"
verdict: VALIDATED
related: [002, 003, 006]
tags: [dart-analyze, analyzer-plugin, riverpod_lint, exit-code, analytics, flaky]
---

# Spike 001: `dart analyze` 실행 형태와 plugin 진단

## What This Validates

Given plugin 이 켜진 연습용 프로젝트(`fixture/`, 배포 파일을 include 한 줄로 받는다),
when 그 폴더를 작업 디렉터리로 두고 인자 없이 `dart analyze --format=json` 을 돌리면,
then plugin 진단 2건이 cold 와 warm 모두에서 빠짐없이 나온다.

함께 본 것: `dart analyze <dir>` 처럼 경로를 인자로 줄 때 plugin 진단을 잃는지 (flutter#193203, sdk#62710).

02-CONTEXT.md D-15 의 멈춤 조건("`example/` 을 작업 디렉터리로 두고 인자 없이 실행해도 plugin 진단을 잃는다")에 해당하는지를 판정하는 spike 다.

## Research

- **flutter/flutter#193203** (2026-09-23, 중복으로 닫힘): Flutter 3.47.5 / Dart 3.13.4 에서 `dart analyze` 는 plugin 진단 10건, `dart analyze lib` 는 0건, `dart analyze lib/<file>.dart` 는 7건이라는 표.
- **dart-lang/sdk#62710** (2026-10-01 닫힘): 폴더를 인자로 주면 plugin 규칙이 나오지 않는다. "Dart 3.14 에 실릴 것"이라는 답으로 닫혔다. 보고자의 재현 프로젝트에서 `dart analyze .` 는 되고 `dart analyze ./lib/` 는 안 됐다.
- **`dart analyze` 소스** (`pkg/dartdev/lib/src/commands/analyze.dart`, tag 3.13.4): 인자가 없으면 현재 디렉터리를 대상으로 삼는다. 종료 코드 255 는 이 명령의 `_Result` 에 없는 값이다 (0 / 1 / 2 / 3 / 4 뿐).

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 작업 디렉터리 = 패키지 루트, 인자 없음 | `dart analyze` | 문서와 이슈가 모두 "된다"고 한 형태 | — | **채택** |
| 저장소 루트에서 패키지 루트를 인자로 | `dart analyze example` | 스크립트가 `cd` 하지 않아도 됨 | 3.13.4 에서는 됐지만 이슈가 다루는 영역과 맞닿아 있다 | 실측만 |
| 하위 폴더를 인자로 | `dart analyze lib` | — | plugin 진단을 전부 잃는다 | 쓰지 않음 |

**Chosen approach:** 패키지 루트를 작업 디렉터리로 두고 인자 없이 실행한다. 나머지 형태는 "무엇을 하면 안 되는가"를 기록하려고 함께 돌렸다.

## How to Run

```bash
# 저장소 루트에서. 상태 폴더는 아무 빈 폴더나 된다 (~/.dartServer 를 건드리지 않으려고 따로 준다).
(cd .planning/spikes/001-analyze-invocation-form/fixture && fvm dart pub get)

# 실행 형태 11가지 × cold/warm (형태 A 는 cold 를 5번 반복)
fvm dart run .planning/spikes/001-analyze-invocation-form/matrix.dart /tmp/spike001-state 5

# 종료 코드 255 빈도: 기본 / 환경변수 / 플래그 를 번갈아 25번씩 (warm)
fvm dart run .planning/spikes/001-analyze-invocation-form/flaky.dart /tmp/spike001-flaky 25

# 같은 비교를 실행마다 빈 상태 폴더에서 (cold) 8번씩
fvm dart run .planning/spikes/001-analyze-invocation-form/flaky.dart /tmp/spike001-flaky-cold 8 cold
```

## What to Expect

- `matrix.dart`: 형태별로 `exit`, 걸린 시간, 진단 수, `plugin 진단 n/2` 를 표로 찍고 `results/matrix.json` 에 원본을 남긴다.
- `flaky.dart`: 방식별로 "진단 4건 모두 나온 횟수"와 종료 코드별 횟수를 표로 찍는다.
- 연습용 프로젝트의 기대 진단 (정답지 형식):

```text
lib/main.dart:9  info  avoid_print
lib/main.dart:9  info  prefer_single_quotes
lib/main.dart:10  warning  missing_provider_scope
lib/src/counter.dart:8  info  avoid_public_notifier_properties
```

## Investigation Trail

### 1. 연습용 프로젝트와 격리 방법

- `fixture/` 는 Flutter 패키지이고 `woody_lints` 를 `path: ../../../..` 로 받는다. 옵션 파일은 `include: package:woody_lints/analysis_options.yaml` 한 줄이다.
- `fvm dart pub get` 이 Flutter 프로젝트에서 그대로 됐고 `analysis_options.yaml` 을 바꾸지 않았다 (자세한 비교는 spike 004).
- 점(`.`)으로 시작하는 폴더(`.planning/`) 아래에 둔 프로젝트도 **그 프로젝트가 분석 대상의 루트이면** 정상으로 분석된다. 반대로 저장소 루트에서 인자 없이 돌린 분석에는 `.planning/` 아래가 들어가지 않는다 (루트 분석은 "No issues found!").
- **`ANALYZER_STATE_LOCATION_OVERRIDE`** 환경변수로 Analysis Server 의 상태 폴더(`~/.dartServer`)를 다른 곳으로 돌릴 수 있다 (Dart 3.13.4 에서 동작 확인). 빈 폴더를 주면 plugin 을 처음부터 다시 준비하는 cold 실행이 되고, `~/.dartServer/.plugin_manager` 의 기존 49개 폴더는 건드려지지 않았다.
- cold 실행에서 Analysis Server 는 `<상태 폴더>/.plugin_manager/<hash>/` 에 가상 패키지를 만들고 `dart pub upgrade` 를 돌린 뒤 `dart compile aot-snapshot` 으로 plugin 을 컴파일한다 (`bin/plugin.aot`, 약 15MB).
- `<hash>` 는 **분석 대상 패키지 루트의 절대 경로를 md5 한 값**이다 (`printf '%s' "$PWD" | md5` 와 일치). 설정 내용이 아니라 경로로 정해진다.

### 2. 실행 형태 표 (`matrix.dart`, Dart 3.13.4, macOS arm64, pub cache 는 채워진 상태)

| 실행 형태 | plugin 진단 | exit | cold / warm | 비고 |
|---|---|---|---|---|
| A. fixture 에서 인자 없음 | 2/2 | 2 | 18초 / 6초 | 10번 중 3번은 종료 코드 255 로 죽음 (아래 3번) |
| B. fixture 에서 `.` | 2/2 | 2 | 18초 / 6초 | |
| C. fixture 에서 `lib` | **0/2** | **0** | 4.5초 / 2.3초 | lint 2건만 나옴. plugin 을 준비조차 하지 않는다 |
| D. fixture 에서 `lib/src` | **0/2** | **0** | 4.4초 / 3.5초 | 진단 0건 (그 폴더에는 plugin 진단만 있다) |
| E. fixture 에서 `lib/main.dart` | 1/2 | 2 | 17초 / 5초 | 그 파일의 plugin 진단은 나옴 |
| F. fixture 에서 파일 2개 | 2/2 | 2 | 18초 / 6초 | |
| G. fixture 에서 자기 절대 경로 | 2/2 | 2 | 18초 / 6초 | |
| H. 저장소 루트에서 상대 경로 | 2/2 | 2 | — / 6초 | cold 1번이 종료 코드 255 로 죽음 |
| I. 저장소 루트에서 절대 경로 | 2/2 | 2 | 18초 / 6초 | |
| J. 저장소 루트에서 `<fixture>/lib` | **0/2** | **0** | 4.4초 / 2.3초 | |
| K. fixture 의 부모에서 `fixture` | 2/2 | 2 | 18초 / 6초 | |

읽는 법:

- **패키지 루트 자체**를 가리키는 형태(인자 없음, `.`, 절대 경로, 다른 곳에서 준 상대 경로)는 모두 plugin 진단이 나왔다.
- **패키지 루트의 하위 폴더**를 인자로 주면 plugin 진단을 전부 잃고, 종료 코드도 0 이 된다 (warning 인 `missing_provider_scope` 가 사라지므로). 이슈 보고가 재현됐다.
- 파일을 인자로 주면 그 파일의 plugin 진단은 나온다.

### 3. 예상 밖: 같은 명령이 가끔 종료 코드 255 로 죽는다

형태 A 를 반복하던 중 10번 중 3번이 **종료 코드 255, stdout 에 JSON 없음** 으로 끝났다. stderr 는 네 번 모두 같았다.

```text
Unhandled exception:
SocketException: Connection attempt cancelled, host: www.google-analytics.com, port: 443
...
#13     GAClient.sendData (package:unified_analytics/src/ga_client.dart:65)
#14     AnalyticsImpl.send (package:unified_analytics/src/analytics.dart:645)
#15     AnalyticsManager.sendMemoryUsage (package:analysis_server/src/analytics/analytics_manager.dart:286)
#16     Driver.start.<anonymous closure> (package:analysis_server/src/server/driver.dart:424)
#17     UsageEventCreator._triggerEvent (package:memory_usage/src/_usage_event.dart:42)
...
Unhandled exception:
Bad state: The analysis server crashed unexpectedly
```

원인 (소스로 확인, tag 3.13.4):

- Analysis Server 는 메모리 사용량이 512MB 늘 때마다 사용 통계(analytics)를 Google 로 보낸다 (`usage_tracking.dart` 의 `deltaMb: 512`, `analytics_manager.dart` 의 `sendMemoryUsage`).
- 그 전송이 끝나기 전에 분석이 끝나 서버가 종료되면 연결 시도가 취소되고, 그 예외를 아무도 받지 않아 서버가 죽는다. `dart analyze` 는 결과를 찍지 못하고 255 로 끝난다.
- 이 컴퓨터의 Dart 사용 통계 설정은 켜져 있다 (`~/.dart-tool/dart-flutter-telemetry.config` 의 `reporting=1`). Google Analytics 주소는 이 셸에서 정상으로 열린다 (0.3초). 막혀서 생기는 문제가 아니라 타이밍 문제다.
- upstream 이슈는 `gh search` 3회로 찾지 못했다.

끄는 방법 두 가지 (소스: `dartdev.dart`, `driver.dart`, `unified_analytics/src/utils.dart`):

- 전역 플래그: `dart --suppress-analytics analyze --format=json`
- 환경변수: `DASH__SUPPRESS_ANALYTICS=true`
- CI 에서는 `dart` 가 CI 환경임을 알아채면(`isBot()`) 스스로 이 환경변수를 켜서 하위 도구에 넘긴다 — GitHub runner 에서 실제로 그런지는 spike 006 에서 본다.

빈도 측정 (`flaky.dart`, 세 방식을 번갈아 실행):

| 방식 | warm 25번 | cold 8번 |
|---|---|---|
| 기본 (`dart analyze --format=json`) | 24번 정상, **1번 255** | 5번 정상, **3번 255** |
| 환경변수 `DASH__SUPPRESS_ANALYTICS=true` | 25번 정상 | 8번 정상 |
| 플래그 `--suppress-analytics` | 25번 정상 | 8번 정상 |

`matrix.dart` 까지 합치면 기본 방식 65번 중 8번이 255 였다 (cold 24번 중 7번, warm 41번 중 1번). 사용 통계를 끈 66번은 모두 정상이었다 (cold 16번, warm 50번).

- 이 비율은 이 세션의 실행 환경에서 잰 값이다. 소유자의 터미널에서는 다를 수 있다.
- 죽을 때는 조용히 통과하지 않는다. 종료 코드가 255 이고 JSON 이 없다.

## Results

**Verdict: VALIDATED** — 조건이 하나 붙는다.

- 패키지 루트를 작업 디렉터리로 두고 인자 없이 실행하면 plugin 진단이 cold 와 warm 모두에서 빠짐없이 나온다. D-15 의 멈춤 조건에 해당하지 않는다.
- **조건:** 사용 통계 전송을 끄고 실행해야 한다 (`dart --suppress-analytics analyze …` 또는 `DASH__SUPPRESS_ANALYTICS=true`). 끄지 않으면 같은 명령이 가끔(여기서는 cold 의 약 3할) 종료 코드 255 로 죽는다.

`tool/verify.dart` 가 가져갈 것:

1. `example/` 을 `workingDirectory` 로 두고 `dart --suppress-analytics analyze --format=json` 을 인자 없이 실행한다. 하위 폴더를 인자로 주지 않는다.
2. 종료 코드가 0 / 2 / 3 이 아니거나 stdout 이 JSON 이 아니면 "정답지와 다르다"가 아니라 "도구가 죽었다"로 따로 알린다 (255 = 서버 충돌, 4 = spike 002 참고).
3. 처음 실행은 약 18초, 그 뒤는 약 6초다 (로컬). plugin 을 매번 새로 준비하게 만들지 않으려면 상태 폴더를 지우지 않는다.
4. 실제로 쓰인 `riverpod_lint` 버전(D-07)은 `<상태 폴더>/.plugin_manager/<패키지 루트 절대 경로의 md5>/pubspec.lock` 에 있다. `ANALYZER_STATE_LOCATION_OVERRIDE` 로 상태 폴더를 정해 주면 md5 를 계산하지 않고도 찾을 수 있다.

원본: `results/matrix.log`, `results/matrix.json`, `results/flaky-warm.log`, `results/flaky-cold.log`.
