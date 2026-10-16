---
spike: 002
idea: verify-harness-tool-behavior
name: plugin-setup-failure-exit
type: standard
validates: "Given plugin 준비가 실패하고 다른 진단이 있는 프로젝트, when `dart analyze --format=json` 을 돌리면, then 종료 코드·stdout·stderr 가 무엇인지 확정된다"
verdict: VALIDATED
related: [001, 003, 006]
tags: [dart-analyze, analyzer-plugin, exit-code, stderr, offline, pub]
---

# Spike 002: plugin 준비가 실패했을 때의 종료 코드

## What This Validates

Given plugin 준비(패키지 받기 → 컴파일)가 실패하는 설정과, 그와 별개로 lint 진단이 나오는 코드,
when 연습용 프로젝트에서 `dart analyze --format=json` 을 돌리면,
then 종료 코드와 stdout / stderr 의 모양이 경우별로 확정된다.

정답지 판정 로직이 여기에 달려 있다 (ROADMAP Phase 2 "Spike first" 1번). 조사 문서는 소스를 읽고 "종료 코드 4 가 아닐 것"이라고 추정했을 뿐 실행한 적이 없었다 (PITFALLS.md V3).

## Research

`pkg/dartdev/lib/src/commands/analyze.dart` 와 `analysis_server.dart` (tag 3.13.4) 를 읽었다.

- plugin 오류는 `server.pluginError` 알림으로 오고, `dart analyze` 는 메시지를 stderr 에 찍은 뒤 `serverErrorReceived = true` 로만 기록한다.
- 종료 코드 4 는 **진단이 하나도 없을 때만** `serverErrorReceived` 를 보고 돌려준다. 진단이 하나라도 있으면 종료 코드는 진단의 강도만으로 정해진다 (error → 3, warning → 2, 그 밖은 0).

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 없는 버전을 선언 | `plugins: riverpod_lint: ^99.0.0` | 빠르고 확실하게 실패 | 실제 사고와는 모양이 다름 | 채택 |
| pub 서버에 닿지 못하게 함 | `PUB_HOSTED_URL=http://127.0.0.1:9` | "네트워크가 막힌 환경"과 같다. 설정 파일을 바꾸지 않아도 됨 | 실행마다 약 30초 | 채택 |
| 옛 plugin 버전 고정 | `riverpod_lint: 3.1.0` | SDK 와 맞지 않는 버전이 들어왔을 때 | — | 채택 |
| 컴파일이 실패하는 plugin | `path:` 로 준 가짜 plugin | 받기 다음 단계(컴파일)의 실패 | 가짜 패키지가 필요 | 채택 |

**Chosen approach:** 네 가지를 모두 돌린다. 실패하는 단계(패키지 해석 / 네트워크 / 컴파일)와 "다른 진단"의 강도(없음 / info / warning)를 섞어 9가지 경우를 만든다.

배포 파일(`lib/analysis_options.yaml`)은 건드릴 수 없으므로, 연습용 프로젝트의 옵션 파일에서 같은 이름의 plugin 을 다시 선언해 덮어쓴다.

## How to Run

```bash
(cd .planning/spikes/002-plugin-setup-failure-exit/fixture && fvm dart pub get)

# 9가지 경우를 각각 2번씩 (약 6분. pub 서버에 닿지 못하는 경우가 한 번에 30초쯤 걸린다)
fvm dart run .planning/spikes/002-plugin-setup-failure-exit/failure_modes.dart /tmp/spike002-state

# 일부만: 뒤에 id 를 붙인다
fvm dart run .planning/spikes/002-plugin-setup-failure-exit/failure_modes.dart /tmp/spike002-state s1-bad-version-info
```

스크립트는 경우마다 `fixture/analysis_options.yaml` 을 바꿔 쓰고, 끝나면(`finally`) 원래 내용으로 되돌린다. 사용 통계 전송은 끄고 돌린다 (spike 001 의 종료 코드 255 를 피하려고).

## What to Expect

경우별로 `exit`, 걸린 시간, 진단 수, plugin 진단이 있는지, 컴파일된 plugin(`plugin.aot`)이 생겼는지, stderr 줄 수를 표로 찍는다. stderr 원문은 `results/<id>.stderr.txt` 에 남는다.

## Investigation Trail

### 결과 표 (Dart 3.13.4, `results/failure_modes.log`)

| id | 경우 | exit | 진단 수 | plugin 진단 | stderr | 시간 |
|---|---|---|---|---|---|---|
| s0 | 대조군: 정상 설정 | 2 | 3 | 있음 | 없음 | 17초 / 4초 |
| s1 | 없는 버전 + 다른 진단은 info 뿐 | **0** | 2 | 없음 | 40줄 | 4초 |
| s2 | 없는 버전 + 다른 진단 없음 | **4** | 0 | 없음 | 40줄 | 4초 |
| s3 | 없는 버전 + 다른 진단에 warning | **2** | 2 | 없음 | 40줄 | 4초 |
| s4 | 없는 plugin 패키지를 하나 더 선언 + info | 0 | 2 | 없음 | 36줄 | 4초 |
| s5 | pub 서버에 닿지 못함, 처음 실행 + info | 0 | 2 | 없음 | 36줄 | 28초 |
| s6 | pub 서버에 닿지 못함, 처음 실행 + 다른 진단 없음 | 4 | 0 | 없음 | 36줄 | 31초 |
| s7 | pub 서버에 닿지 못함, **plugin 은 이미 준비됨** + info | 0 | 2 | **없음** | 36줄 | 26초 |
| s8 | 옛 plugin 버전(3.1.0 고정) + info | 0 | 2 | 없음 | 50줄 | 4초 |
| s9 | 컴파일이 실패하는 plugin 을 하나 더 선언 + info | 0 | 2 | 없음 | 55줄 | 5초 |

모든 경우에서 1회차와 2회차가 같았다 (실패가 캐시되어 다음 실행에서 달라지는 일은 없다).

### 읽는 법

1. **종료 코드는 plugin 실패를 알려 주지 않는다.** 다른 진단이 info 뿐이면 0, warning 이 있으면 2 다. 4 는 진단이 하나도 없을 때만 나온다. 소스에서 읽은 대로다.
2. **stdout 은 멀쩡한 JSON 이다.** 실패한 plugin 의 진단만 빠진 채로 나온다. s2 / s6 은 `{"version":1,"diagnostics":[]}` 이다.
3. **stderr 는 모든 실패에서 같은 말로 시작한다.**

   ```text
   An error occurred while executing an analyzer plugin: An error occurred while setting up the analyzer plugin package at '<상태 폴더>/.plugin_manager/<hash>'. The `dart pub upgrade` command failed:
     exitCode = 1
     stdout = Resolving dependencies...

     stderr = Because plugin_entrypoint depends on riverpod_lint ^99.0.0 which doesn't match any versions, version solving failed.
   ```

   컴파일 단계의 실패(s9)는 앞부분만 같고 뒤가 다르다.

   ```text
   An error occurred while executing an analyzer plugin: Failed to compile "<상태 폴더>/.plugin_manager/<hash>/bin/plugin.dart" to an AOT snapshot.
   ```

   공통 머리말은 `An error occurred while executing an analyzer plugin:` 이다. 정상 실행(s0)의 stderr 는 비어 있다.
4. **plugin 하나가 실패하면 전부 잃는다** (s4, s9). 선언한 plugin 들은 가상 패키지 하나에 묶여 함께 받아지고 함께 컴파일되므로, 멀쩡한 `riverpod_lint` 의 진단도 사라진다.
5. **이미 준비된 plugin 도 네트워크가 없으면 쓰지 못한다** (s7). `plugin.aot` 이 상태 폴더에 그대로 있는데도 plugin 진단이 0건이었다. Analysis Server 는 뜰 때마다 `dart pub upgrade` 를 돌리고, 그것이 실패하면 plugin 준비 전체를 실패로 처리한다. pub 은 재시도하다가 약 26~31초 뒤에 포기한다.
6. **SDK 와 맞지 않는 옛 plugin 버전은 멈추지 않고 바로 실패한다** (s8, 4초). `riverpod_lint 3.1.0` 은 `analyzer_plugin ^0.13.10` 을 요구해 Dart 3.13.4 의 `analysis_server_plugin ^0.3.8` 과 함께 풀리지 않는다. PITFALLS.md Pitfall 11 의 "실패가 아니라 멈춤"은 이 방향(새 SDK + 옛 plugin)에서는 일어나지 않았다.

### 정답지 판정에 주는 뜻

`example/` 의 정답지에는 `riverpod_lint` 진단이 2~3건 들어가고(D-02) 그중 하나는 warning 이라 맨 위 줄이 `exit 2` 가 된다(D-04, spike 003). plugin 준비가 실패하면:

- plugin 진단 줄이 모두 빠진다 → "정답지에는 있는데 나오지 않은 경고"로 잡힌다.
- 남는 진단이 info 뿐이라 종료 코드가 0 이 된다 → `exit` 줄도 어긋난다.
- stderr 에 위의 머리말이 찍힌다.

세 가지가 한꺼번에 어긋나므로 헛통과할 길이 없다. 다만 화면에는 "정답지가 다르다"보다 "plugin 준비가 실패했다"가 먼저 보여야 소유자가 원인을 바로 안다.

## Results

**Verdict: VALIDATED** — 종료 코드, stdout, stderr 의 모양이 9가지 경우 모두에서 확정됐고, 소스에서 읽은 것과 같다.

`tool/verify.dart` 가 가져갈 것:

1. 종료 코드만으로 판정하지 않는다. plugin 이 죽어도 0 이나 2 가 나온다.
2. stderr 에 `An error occurred while executing an analyzer plugin:` 이 있으면 정답지 비교 결과보다 먼저 "plugin 준비 실패"로 알리고, stderr 의 `stderr = …` 줄을 그대로 보여 준다 (원인이 거기에 적혀 있다).
3. 종료 코드 4 는 "진단이 없는데 서버 오류가 있었다"는 뜻이다. `example/` 에서는 진단이 항상 있으므로 4 가 나올 일이 없지만, 나오면 무조건 실패로 본다.
4. 검증은 네트워크가 필요하다. plugin 이 이미 준비되어 있어도 pub 서버에 닿지 못하면 약 30초 뒤 plugin 진단 없이 끝난다. 화면 안내에 "네트워크를 확인하세요"가 들어가야 한다.

확인하지 않은 것:

- plugin 이 뜬 뒤 실행 중에 죽는 경우 (준비는 성공, 분석 도중 예외).
- pub 서버가 느리게 응답만 하고 끝나지 않는 경우의 시간. CI 의 `timeout-minutes` 가 막는다.

원본: `results/failure_modes.log`, `results/failure_modes.json`, `results/<id>.stderr.txt`.
