---
spike: 008
idea: verify-harness-tool-behavior
name: state-folder-placement
type: standard
validates: "Given md5 를 쓸 수 없고 같은 프로젝트를 다른 Analysis Server 가 동시에 분석할 수 있을 때, when 상태 폴더를 기본 자리에 둔 경우와 전용 폴더로 돌린 경우에 반복·동시 실행하면, then 실제 `riverpod_lint` 버전을 읽는 방법과 동시 실행에서 plugin 준비가 깨지는지가 확정된다"
verdict: VALIDATED
related: [001, 002, 006]
tags: [analyzer-plugin, state-folder, concurrency, md5, plugin-version, aot-snapshot]
---

# Spike 008: 상태 폴더를 어디에 둘 것인가

## What This Validates

Given 검증 스크립트가 `dart:io`, `dart:convert` 만 쓸 수 있고(D-11, 거기에는 md5 가 없다) 같은 프로젝트를 IDE 의 Analysis Server 가 동시에 분석할 수 있을 때,
when Analysis Server 의 상태 폴더(plugin 을 받아 컴파일해 두는 곳)를 여러 자리에 두고 반복·동시 실행하면,
then (1) 실제로 쓰인 `riverpod_lint` 버전을 md5 없이 읽는 방법, (2) 같은 상태 폴더를 두 실행이 함께 쓸 때 plugin 준비가 깨지는지, (3) 깨진 뒤 스스로 회복하는지가 확정된다.

검증 화면에 실제 plugin 버전을 찍기로 했다(D-07). spike 001 은 그 버전이 `<상태 폴더>/.plugin_manager/<프로젝트 경로의 md5>/pubspec.lock` 에 있다고 확인했고, "상태 폴더를 정해 주면 md5 를 계산하지 않고도 찾을 수 있다"고 적었지만 그 방식을 실제 사용 조건(반복 실행, IDE 와 함께)에서 재지는 않았다.

## Research

`analysis_server` (SDK tag 3.13.4) 와 `analyzer` 14.5.0 의 소스를 읽었다.

- **폴더 이름:** `plugin_watcher.dart` 의 `_addPlugins` 가 `manager.pluginStateFolder(contextRoot.root.path)` 로 폴더를 정하고, `plugin_manager.dart` 의 `_uniqueDirectoryName` 이 이름을 만든다 — `hex.encode(md5.convert(path.codeUnits).bytes)`. 입력이 UTF-8 바이트가 아니라 **`codeUnits`** 다.
- **준비 순서:** 서버가 뜰 때마다 (1) `pubspec.yaml` 과 `bin/plugin.dart` 를 내용이 다를 때만 다시 쓰고, (2) `dart pub upgrade` 를 **항상** 돌리고, (3) 기존 `bin/plugin.aot` 이 `bin/depfile.txt` 기준으로 최신이면 그대로 쓰고 아니면 **기존 파일을 지운 뒤** `dart compile aot-snapshot` 을 돌린다.
- **잠금이 없다.** 같은 폴더를 두 서버가 쓰는 경우를 막는 코드는 찾지 못했다.
- **상태 폴더의 자리:** `analyzer` 의 `lib/file_system/physical_file_system.dart` `_getStandardStateLocation` 이 `ANALYZER_STATE_LOCATION_OVERRIDE` 환경변수를 먼저 보고, 없으면 `~/.dartServer` 를 쓴다. 이 환경변수는 그 함수의 문서 주석에 적혀 있다. 사용자 문서(dart.dev)에 있는지는 확인하지 않았다.

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 전용 상태 폴더를 준다 | `ANALYZER_STATE_LOCATION_OVERRIDE` | plugin 폴더가 하나뿐이라 md5 가 필요 없다. IDE 와 폴더를 나눠 쓴다 | IDE 가 이미 준비해 둔 것을 쓰지 못해 첫 검증이 15초 든다. 환경변수가 소스 주석에만 적혀 있다 | **채택** |
| 기본 자리 + md5 를 손으로 구현 | `dart:convert` 만으로 md5 약 50줄 | 기본 자리를 그대로 쓴다 | 경로를 서버와 똑같이 만들어야 한다 (링크를 풀고, UTF-8 이 아닌 code unit). IDE 와 폴더를 함께 쓴다 | 쓰지 않음 |
| 기본 자리 + 가장 최근에 바뀐 폴더 | 파일 시각 | 코드가 짧다 | 재실행은 어느 파일의 시각도 바꾸지 않는다 (실측) | **안 됨** |
| 기본 자리 + 폴더 내용으로 고르기 | — | — | 폴더 안 어디에도 프로젝트 경로가 없다 (실측) | **안 됨** |

**Chosen approach:** 네 가지를 모두 실측으로 가른다. 함께 쓰는 경우는 "두 `dart analyze` 를 겹쳐 띄우기"와 "오래 떠 있는 서버(`dart language-server`)를 띄워 두고 그 옆에서 실행하기" 두 방식으로 본다.

## How to Run

```bash
# 저장소의 파일은 읽기만 한다. 연습용 프로젝트는 spike 001 의 것을 <작업 폴더>/fx 에 복사해 쓴다.
# 부를 골라 돌릴 수 있다 (전부 약 23분).
fvm dart run .planning/spikes/008-state-folder-placement/state_probe.dart /tmp/spike008-work placement hash inside
fvm dart run .planning/spikes/008-state-folder-placement/state_probe.dart /tmp/spike008-work contention
fvm dart run .planning/spikes/008-state-folder-placement/state_probe.dart /tmp/spike008-work race
fvm dart run .planning/spikes/008-state-folder-placement/state_probe.dart /tmp/spike008-work window
fvm dart run .planning/spikes/008-state-folder-placement/state_probe.dart /tmp/spike008-work corrupt server

# 분석 도중 Ctrl-C (placement 부가 만든 <작업 폴더>/fx 가 있어야 한다)
python3 .planning/spikes/008-state-folder-placement/interrupt.py /tmp/spike008-work
```

## What to Expect

부마다 표나 줄 목록을 찍는다. "통과"는 진단 4건이 spike 006 의 `expected_001.txt` 와 같고 종료 코드가 2 라는 뜻이다. 결과 JSON 은 `results/state_probe.json` 에 부별로 합쳐진다.

## Investigation Trail

모두 Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64, 2026-10-11.

### 1. 상태 폴더의 자리는 결과를 바꾸지 않는다 (`placement`)

| 자리 | 처음 실행 | 재실행 | plugin 폴더 수 | 읽은 버전 |
|---|---|---|---|---|
| 프로젝트 밖 | 통과, 14.7초 | 통과, 3.6초 | 1 | 3.1.9 |
| 프로젝트 안의 점 폴더 (`.dart_tool/woody_verify_state`) | 통과, 15.0초 | 통과, 3.6초 | 1 | 3.1.9 |
| 프로젝트 안의 평범한 폴더 (`verify_state`) | 통과, 15.3초 | 통과, 3.9초 | 1 | 3.1.9 |

- 전용 폴더를 주면 `.plugin_manager` 아래에 폴더가 **하나만** 생기고, 그 `pubspec.lock` 에서 버전이 읽힌다. md5 가 필요 없다.
- 분석 대상 프로젝트 안에 두어도 진단이 달라지지 않는다. 상태 폴더의 내용물이 모두 점으로 시작하는 폴더(`.plugin_manager`, `.analysis-driver` 등)라 분석에 들어가지 않는다.

### 2. 폴더 이름은 "링크를 푼 경로의 code unit" 의 md5 다 (`hash`)

| 작업 디렉터리 | 폴더 이름과 일치한 것 |
|---|---|
| 평범한 경로 | 그 경로의 md5 |
| 심볼릭 링크를 거친 경로 | **링크를 푼** 경로의 md5 (준 경로의 md5 와는 다르다) |
| 한글이 든 경로 | UTF-8 의 md5 가 **아니다.** 글자마다 UTF-16 code unit 의 아래 8비트만 모은 것의 md5 |

소스에서 읽은 `md5.convert(path.codeUnits)` 그대로다. md5 를 손으로 구현해 기본 자리의 폴더를 고르려면 이 두 가지(링크 풀기, code unit 자르기)를 서버와 똑같이 해야 한다. 경로에 영문·숫자만 있을 때는 UTF-8 과 결과가 같아 차이가 드러나지 않는다.

### 3. 폴더 안에는 프로젝트를 가리키는 것이 없다 (`inside`)

- 파일: `pubspec.yaml`, `pubspec.lock`, `.dart_tool/package_config.json`, `.dart_tool/package_graph.json`, `bin/plugin.dart`, `bin/plugin.aot` (약 15MB), `bin/depfile.txt`.
- 이 중 어디에도 분석 대상 프로젝트의 경로가 적혀 있지 않다 (0회). 내용으로는 "어느 프로젝트의 폴더인지" 알 수 없다.
- **재실행은 어느 파일의 수정 시각도 바꾸지 않는다.** `dart pub upgrade` 가 매번 돌지만 바뀐 것이 없으면 파일을 다시 쓰지 않는다. "가장 최근에 바뀐 폴더가 내 것"이라는 추정은 쓸 수 없다.
- 서버가 만든 `pubspec.yaml` (주석 두 줄은 뺐다):

```yaml
name: plugin_entrypoint
version: 0.0.1
environment:
  sdk: ^3.6.0
dependencies:
  analysis_server_plugin: ^0.3.8
  riverpod_lint: ^3.1.3
```

### 4. 같은 상태 폴더를 두 실행이 함께 쓸 때 (`contention`, `race`, `window`)

| 경우 | 쌍 | 실패한 쌍 |
|---|---|---|
| 빈 폴더에서 처음 실행 둘을 **동시에** | 20 | **1** |
| 빈 폴더에서 처음 실행, 둘째를 3~12초 늦게 | 17 | 0 |
| 준비된 폴더에서 둘을 동시에 | 8 | 0 |
| 대조군: 상태 폴더를 따로 주고 처음 실행 둘을 동시에 | 2 | 0 |

- **실패는 한 번 봤다** (동시에 띄운 처음 실행 20쌍 중 1쌍, 실행으로는 40번 중 1번). 15쌍을 더 돌리고, 시작 시각을 0.5초씩 옮겨 가며 14쌍을 더 돌렸지만 다시 나오지 않았다.
- 실패한 쪽의 모양: **종료 코드 0, 진단 2건(plugin 진단이 빠짐)**, 13.5초. stderr 의 앞 두 줄:

```text
File truncated before or at offset 0x0.
Loading dynamic library failed: dlopen(<상태 폴더>/.plugin_manager/<hash>/bin/plugin.aot, 0x0001): tried: …
```

  한쪽이 `plugin.aot` 을 쓰는 도중에 다른 쪽이 그 파일을 읽은 것이다. 이때는 stderr 전문을 남기지 못했다. 같은 모양을 5번에서 일부러 만들어 전문을 확인했다.
- 준비된 폴더를 함께 쓰는 것은 문제가 없었다 (8쌍, 그리고 아래 6번).
- 둘째를 늦게 띄우면 둘째가 스스로 다시 컴파일하거나(3~9초 늦게: 약 13.7초) 첫째가 만든 것을 그대로 쓴다(9.5초 이후: 4.2~6.8초). 두 경우 모두 통과했다.

### 5. 컴파일된 plugin 파일이 잘린 채 남으면 계속 실패한다 (`corrupt`)

준비를 마친 뒤 `plugin.aot` 을 0바이트로 자르고(`depfile.txt` 는 그대로) 분석했다.

| 실행 | 결과 |
|---|---|
| 잘린 채로 분석 | 실패 — exit 0, 진단 2건, 0.8초 |
| 한 번 더 | **같은 실패.** 파일은 0바이트 그대로 |
| `plugin.aot` 만 지운 뒤 | 통과 — 12.8초 (다시 컴파일) |

stderr 전문(11줄)의 앞부분:

```text
File truncated before or at offset 0x0.
Loading dynamic library failed: dlopen(<상태 폴더>/.plugin_manager/<hash>/bin/plugin.aot, 0x0001): tried: …
An error occurred while executing an analyzer plugin: IsolateSpawnException: Unable to spawn isolate: The uri(file://<상태 폴더>/.plugin_manager/<hash>/bin/plugin.aot) provided to `Isolate.spawnUri()` does not contain a valid AOT snapshot.

An error occurred while executing an analyzer plugin: Unrecorded error while starting the plugin.
#0      PluginSession.start (package:analysis_server/src/plugin/plugin_isolate.dart:499)
```

- **spike 002 의 머리말(`An error occurred while executing an analyzer plugin:`)이 있다. 다만 stderr 의 첫 줄이 아니라 셋째 줄이다.** 앞의 두 줄은 Dart VM 이 직접 찍는다. spike 002 의 9가지 경우는 모두 머리말이 첫 줄이었다.
- **서버는 스스로 회복하지 않는다.** `depfile.txt` 기준으로 "최신"이라고 보고 잘린 파일을 계속 쓴다. `plugin.aot` 을 지우거나 상태 폴더를 통째로 지우면 회복한다.
- 4번의 실패가 이 상태를 남겼는지는 확인하지 못했다 (그 폴더에서는 다른 쪽이 파일을 끝까지 썼을 수 있다).

### 6. 오래 떠 있는 서버 옆에서 (`server`)

`dart language-server` 를 같은 상태 폴더로 띄워 두고(IDE 가 프로젝트를 열어 둔 상황) 그 옆에서 명령줄 분석을 돌렸다.

| 단계 | 결과 |
|---|---|
| 서버가 plugin 을 준비하고 plugin 진단을 보냄 | 예 (9초, `missing_provider_scope` 가 진단에 옴) |
| 서버가 떠 있는 동안 명령줄 분석 3번 | 3번 통과, 3.6초 |
| `depfile.txt` 를 지워 명령줄 쪽이 다시 컴파일하게 함 | 통과, 12.9초. `plugin.aot` 이 새로 만들어짐 |
| 그 뒤 명령줄 분석 | 통과, 3.6초 |
| 서버가 그동안 살아 있고 `shutdown` 요청에 답함 | 예 |

서버가 이미 plugin 을 띄워 둔 상태라면 함께 써도 문제가 없다. 서버가 쓰고 있는 `plugin.aot` 을 명령줄 쪽이 지우고 다시 만들어도 서버는 죽지 않았다.

### 7. 분석 도중에 Ctrl-C 를 눌러도 다음 실행이 회복한다 (`interrupt.py`)

프로세스 그룹 전체에 SIGINT 를 보냈다 (터미널의 Ctrl-C 와 같다).

| 경우 | 끊은 시점 | 남은 파일 | 다음 실행 |
|---|---|---|---|
| 처음 실행 도중 | 3초 | `plugin.aot` 없음, `depfile.txt` 없음 | 통과, 15.3초 |
| | 6초, 9초 | `plugin.aot` 없음, `depfile.txt` 있음 | 통과, 약 15.5초 |
| | 11초 | 둘 다 있음 (컴파일이 끝난 뒤) | 통과, 6.2초 |
| 준비된 뒤 다시 컴파일하는 도중 | 3초, 6초, 9초 | `plugin.aot` 없음, 옛 `depfile.txt` 있음 | 통과, 13.0초 |

7번 모두 다음 실행이 통과했다. 컴파일러는 도중에 끊겨도 잘린 `plugin.aot` 을 남기지 않았다. 5번의 "잘린 파일이 남은 상태"는 Ctrl-C 로는 만들어지지 않는다.

## Results

**Verdict: VALIDATED** — 세 가지가 모두 확정됐다.

1. **md5 없이 버전을 읽는 방법은 전용 상태 폴더뿐이다.** 기본 자리(`~/.dartServer`)에서는 폴더 내용으로도, 파일 시각으로도 "내 폴더"를 고를 수 없다. 전용 폴더에는 plugin 폴더가 하나만 생긴다. 시간은 기본 자리와 같다 (처음 15초, 재실행 3.6초).
2. **같은 상태 폴더를 함께 쓰면 드물게 깨진다.** 빈 폴더에서 처음 실행 둘이 정확히 겹칠 때 40번 중 1번이었다. 준비된 뒤에 함께 쓰는 것은 문제가 없었다.
3. **깨진 채 남으면 스스로 회복하지 않는다.** `plugin.aot` 이 잘린 채 남으면 지울 때까지 계속 실패한다. Ctrl-C 로는 그 상태가 되지 않는다.

`tool/verify.dart` 가 가져갈 것:

1. `example/` 을 분석할 때 **`ANALYZER_STATE_LOCATION_OVERRIDE` 로 저장소 안의 전용 폴더를 준다.** 자리는 점으로 시작하는 폴더 아래면 된다 (루트의 `.dart_tool/` 아래는 이미 `.gitignore` 에 걸린다). 폴더를 지우지 않으면 재실행은 3.6초다.
2. plugin 버전(D-07)은 그 폴더의 `.plugin_manager/*/pubspec.lock` 에서 읽는다. 폴더가 하나가 아니면 버전을 `?` 로 찍고 이유를 알린다.
3. stderr 의 머리말은 **`contains` 로 찾는다.** 첫 줄이 아닐 수 있다 (`startsWith` 로 찾으면 5번의 실패를 놓친다).
4. plugin 실패를 알릴 때 "전용 상태 폴더를 지우고 다시 실행하세요"를 함께 안내한다. 전용 폴더라 지워도 다른 프로젝트나 IDE 에 영향이 없다. 비용은 15초다.
5. 검증 명령은 사용자가 Ctrl-C 로 끊어도 된다. 다음 실행이 회복한다.

spike 001 / 002 의 결론에서 달라지는 것:

- 001 은 "상태 폴더를 정해 주면 md5 를 계산하지 않고도 찾을 수 있다"고 선택지로 적었다. 이제 그것이 채택된 방식이다 (D-11 아래에서는 다른 방법이 없다).
- 002 는 "stderr 는 모든 실패에서 같은 말로 시작한다"고 적었다. plugin 을 **받고 컴파일하는** 단계의 실패에서는 맞다. 컴파일된 파일을 **읽어 들이는** 단계의 실패에서는 머리말이 셋째 줄에 온다.

확인하지 않은 것:

- GitHub Linux runner 에서의 같은 실험. 다만 `ANALYZER_STATE_LOCATION_OVERRIDE` 자체는 spike 006 에서 runner 의 30번 실행에 썼고 모두 통과했다.
- 4번의 실패가 폴더에 잘린 파일을 남기는지.
- 실제 IDE(VS Code)와 함께 쓸 때. `dart language-server` 로 흉내 냈다.
- `ANALYZER_STATE_LOCATION_OVERRIDE` 가 사용자 문서에 있는 공식 설정인지. 소스의 문서 주석에는 적혀 있다. 없어지면 전용 폴더에 `.plugin_manager` 가 생기지 않으므로 2번의 `?` 로 드러난다.

원본: `results/placement-hash-inside.log`, `results/contention.log`, `results/race.log`, `results/window.log`, `results/corrupt-server.log`, `results/interrupt.log`, `results/state_probe.json`.
