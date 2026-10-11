# `dart analyze` 실행과 결과 판정

검증 명령(`tool/verify.dart`)이 `example/` 을 분석하고, 그 결과를 "통과 / 정답지와 다름 / plugin 준비 실패 / 도구가 죽음" 으로 가르는 부분이다. Analysis Server 가 plugin 을 받아 컴파일해 두는 상태 폴더를 어디에 두는지도 여기서 다룬다.

모든 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, 2026-10-11 실측이다.

## Requirements

MANIFEST.md 의 `verify-harness-tool-behavior` 에서 이 영역에 걸리는 것.

- 판정의 주 수단은 정답지 비교다 (D-15)
- 정답지 한 줄은 `상대경로:줄  강도  규칙이름`, 맨 위에 `exit N` (D-04)
- 검증 스크립트는 Dart 이고 `dart:io`, `dart:convert` 만 쓴다 (D-11)
- `dart analyze` 는 `example/` 을 작업 디렉터리로 두고 **인자 없이**, **사용 통계 전송을 끈 채**(`--suppress-analytics`) 실행한다 (001)
- plugin 준비 실패는 종료 코드가 아니라 **stderr 의 머리말**(`An error occurred while executing an analyzer plugin:`)과 정답지의 빠진 줄로 알아챈다. 종료 코드 0 / 2 는 plugin 이 죽어도 나온다 (002)
- 검증에는 네트워크가 필요하다. plugin 이 이미 준비되어 있어도 pub 서버에 닿지 못하면 plugin 진단 없이 끝난다 (002)
- 진단의 강도는 JSON 의 `severity` 로 읽는다 (003)
- 검증 명령은 `example/` 을 분석할 때 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 **저장소 안의 전용 상태 폴더**를 준다. 실제 `riverpod_lint` 버전(D-07)은 그 폴더의 `.plugin_manager/*/pubspec.lock` 에서 읽는다. `dart:io` / `dart:convert` 에는 md5 가 없고, 기본 자리(`~/.dartServer`)에서는 폴더 내용으로도 파일 시각으로도 자기 폴더를 고를 수 없다 (008)
- stderr 의 머리말은 첫 줄이 아닐 수 있으므로 `contains` 로 찾는다. plugin 실패를 알릴 때 "전용 상태 폴더를 지우고 다시 실행"을 안내한다 — 컴파일된 plugin 파일이 깨진 채 남으면 지울 때까지 계속 실패한다 (008)

## How to Build It

### 1. 실행

패키지 루트를 `workingDirectory` 로 두고, 경로 인자 없이, 전역 플래그 `--suppress-analytics` 를 `analyze` **앞에** 붙이고, 상태 폴더를 환경변수로 넘긴다.

```dart
// sources/008-state-folder-placement/state_probe.dart 의 Probe.analyze 에서.
final result = await Process.run(
  Platform.resolvedExecutable,
  ['--suppress-analytics', 'analyze', '--format=json'],
  workingDirectory: cwd,
  environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir},
);
```

- `cwd` 는 `example/` 의 절대 경로, `stateDir` 는 2번의 전용 상태 폴더다.
- `Platform.resolvedExecutable` 을 쓰면 `fvm dart run tool/verify.dart` 로 띄운 그 SDK 의 `dart` 가 그대로 쓰인다.
- 사용 통계를 끄는 방법은 둘이고 결과가 같았다: 전역 플래그 `--suppress-analytics`, 환경변수 `DASH__SUPPRESS_ANALYTICS=true`.

### 2. 상태 폴더는 저장소 안의 전용 폴더로 준다

Analysis Server 는 plugin 을 `<상태 폴더>/.plugin_manager/<hash>/` 에 받아 컴파일해 둔다. 상태 폴더의 기본 자리는 `~/.dartServer` 이고 IDE 와 다른 프로젝트가 함께 쓴다 (이 컴퓨터에는 plugin 폴더가 49개 있었다). 검증 명령은 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 자기만 쓰는 폴더를 준다.

전용 폴더를 주는 이유는 둘이다.

- plugin 폴더가 **하나만** 생겨서 md5 없이 버전을 읽을 수 있다 (→ 8번). D-11 아래에서는 다른 방법이 없다.
- 깨졌을 때 통째로 지워도 다른 프로젝트나 IDE 에 영향이 없다 (→ 7번).

자리는 결과를 바꾸지 않았다.

| 자리 (분석 대상 프로젝트 기준) | 처음 실행 | 재실행 | plugin 폴더 수 | 읽은 버전 |
|---|---|---|---|---|
| 프로젝트 밖 | 통과, 14.7초 | 통과, 3.6초 | 1 | 3.1.9 |
| 프로젝트 안의 점 폴더 (`.dart_tool/woody_verify_state`) | 통과, 15.0초 | 통과, 3.6초 | 1 | 3.1.9 |
| 프로젝트 안의 평범한 폴더 (`verify_state`) | 통과, 15.3초 | 통과, 3.9초 | 1 | 3.1.9 |

- **자리는 점으로 시작하는 폴더 아래로 잡는다.** `.dart_tool/` 아래면 `.gitignore` 의 `.dart_tool/` 에 이미 걸려 따로 손댈 것이 없다. 정확한 경로는 계획에서 정한다.
- 표의 세 자리는 작업 폴더에 복사한 연습용 프로젝트를 기준으로 쟀다. **실제 저장소 안의 자리에 두고 잰 것은 아니다.** `example/` 을 기준으로 옮겨 보면 저장소 루트의 `.dart_tool/…` 은 표의 "프로젝트 밖"에, `example/.dart_tool/…` 은 "프로젝트 안의 점 폴더"에 대응한다 (추론). 세 자리의 결과가 같았으므로 어느 쪽이든 같을 것으로 본다.
- 프로젝트 안에 두어도 진단이 달라지지 않는 것은 상태 폴더의 내용물이 모두 점으로 시작하는 폴더(`.plugin_manager`, `.analysis-driver` 등)라 분석에 들어가지 않기 때문이다.
- **폴더를 지우지 않고 둔다.** 재실행이 3.6초다. 지우는 것은 plugin 실패를 알렸을 때의 복구 수단이다 (→ 7번).
- spike 는 늘 폴더를 먼저 만들어 두고 넘겼다 (`createSync(recursive: true)`). 없는 경로를 넘겼을 때는 재지 않았다.

### 3. stdout 을 정답지 형식으로 바꾸기

stdout 에서 `{` 로 시작하는 **마지막 줄**을 JSON 으로 읽고, 진단마다 `상대경로:줄  강도  규칙이름` 한 줄을 만들어 정렬한다.

```dart
// sources/006-github-runner-cold-plugin/ci_probe.dart (002 의 failure_modes.dart 와 같은 함수)
/// stdout 의 JSON 을 정답지 형식 줄 목록으로 바꾼다. 읽지 못하면 null.
List<String>? normalizeDiagnostics(String stdoutText, String fixtureDir) {
  final jsonLine = stdoutText
      .split('\n')
      .lastWhere((l) => l.trimLeft().startsWith('{'), orElse: () => '');
  if (jsonLine.isEmpty) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(jsonLine);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic> || decoded['diagnostics'] is! List) return null;
  final prefix = '$fixtureDir/';
  final lines = <String>[];
  for (final d in decoded['diagnostics'] as List) {
    final location = (d as Map<String, dynamic>)['location'] as Map<String, dynamic>;
    final file = location['file'] as String;
    final line = ((location['range'] as Map)['start'] as Map)['line'];
    final relative = file.startsWith(prefix) ? file.substring(prefix.length) : file;
    lines.add('$relative:$line  ${(d['severity'] as String).toLowerCase()}  ${d['code']}');
  }
  return lines..sort();
}
```

- `fixtureDir` 는 절대 경로여야 한다 (JSON 의 `location.file` 이 절대 경로다).
- 작업 디렉터리를 심볼릭 링크로 줄 수 있으면 접두사를 둘 받는다 — 준 경로와 링크를 푼 경로(`Directory(cwd).resolveSymbolicLinksSync()`). `sources/008-state-folder-placement/state_probe.dart` 의 `normalizeDiagnostics` 가 그 형태이고, 링크를 거친 작업 디렉터리의 분석이 그 형태로 통과했다.
- 정렬은 문자열 정렬이다. `lib/main.dart:10` 이 `lib/main.dart:9` 보다 앞에 온다 (`sources/006-…/expected_001.txt` 가 그 순서다). 정답지 파일도 같은 방식으로 정렬해 견준다.

### 4. 판정 순서

세 spike(001, 002, 008)의 "가져갈 것"을 합친 순서다. 각 조건은 실측했고, 이 순서로 묶은 전체 흐름은 아직 한 스크립트로 돌려 보지 않았다.

1. **stderr 에 `An error occurred while executing an analyzer plugin:` 이 들어 있는가** → "plugin 준비 실패"로 알린다. 정답지 비교 결과보다 먼저 보여야 한다.
   - **`contains` 로 찾는다.** 첫 줄이 아닐 수 있다 (→ 6번). `startsWith` 로 찾으면 컴파일된 plugin 파일을 읽어 들이지 못한 실패를 놓친다.
   - stderr 를 그대로 보여 준다. 원인이 거기에 적혀 있다 (`stderr = …` 줄, 또는 `plugin.aot` 을 읽지 못했다는 줄).
   - 안내는 둘이다: "네트워크를 확인하세요", "전용 상태 폴더(`<경로>`)를 지우고 다시 실행하세요 (약 15초)".
2. **종료 코드가 0 / 2 / 3 이 아니거나 stdout 이 JSON 이 아닌가** → "정답지와 다르다"가 아니라 "도구가 죽었다"로 따로 알린다.
3. **정답지 비교** → `exit N` 줄, 정답지에는 있는데 나오지 않은 줄, 정답지에 없는데 나온 줄.

종료 코드 4 는 1번에 먼저 걸린다 (4 가 나온 두 경우 모두 stderr 에 머리말이 있었다).

```dart
// sources/008-state-folder-placement/state_probe.dart 의 Outcome 에서
/// spike 002 가 찾은 plugin 준비 실패의 머리말이 stderr 에 있는지.
bool get hasPluginHeader =>
    stderrText.contains('An error occurred while executing an analyzer plugin:');
```

### 5. 종료 코드가 뜻하는 것

| exit | 뜻 | 근거 |
|---|---|---|
| 0 | 진단이 없거나 info 뿐 | 002, 003 |
| 2 | warning 이 하나라도 있다 | 002, 003 |
| 3 | error 가 하나라도 있다 | 003 |
| 4 | 진단이 **하나도 없고** 서버 오류가 있었다. `example/` 에서는 진단이 항상 있으므로 나올 일이 없다. 나오면 무조건 실패 | 002 (s2, s6) |
| 255 | Analysis Server 가 죽었다. stdout 에 JSON 이 없다. 사용 통계를 끄지 않았을 때만 봤다 | 001 |

종료 코드는 진단의 강도만 따른다. plugin 이 죽었는지는 알려 주지 않는다.

### 6. plugin 준비가 실패했을 때의 모양

| 무엇 | 정상 | plugin 준비 실패 |
|---|---|---|
| stdout | JSON, plugin 진단 포함 | **멀쩡한 JSON**, plugin 진단만 빠짐 |
| stderr | 비어 있음 | 머리말이 들어 있다 (자리는 아래 표) |
| 종료 코드 | 정답지의 `exit` 와 같음 | 남은 진단의 강도대로 (info 뿐이면 0) |

머리말의 문구는 실패 단계와 상관없이 같다. **자리는 단계에 따라 다르다.**

| 실패한 단계 | 머리말의 자리 | stderr 길이 | 근거 |
|---|---|---|---|
| plugin 을 받는 단계 (`dart pub upgrade`) | 첫 줄 | 36~55줄 | 002 |
| plugin 을 컴파일하는 단계 | 첫 줄 | 36~55줄 | 002 |
| 컴파일된 `plugin.aot` 을 읽어 들이는 단계 | **셋째 줄** (앞 두 줄은 Dart VM 이 직접 찍는다) | 11줄 | 008 |

받는 단계의 실패:

```text
An error occurred while executing an analyzer plugin: An error occurred while setting up the analyzer plugin package at '<상태 폴더>/.plugin_manager/<hash>'. The `dart pub upgrade` command failed:
  exitCode = 1
  stdout = Resolving dependencies...

  stderr = Because plugin_entrypoint depends on riverpod_lint ^99.0.0 which doesn't match any versions, version solving failed.
```

컴파일 단계의 실패는 머리말 뒤가 다르다.

```text
An error occurred while executing an analyzer plugin: Failed to compile "<상태 폴더>/.plugin_manager/<hash>/bin/plugin.dart" to an AOT snapshot.
```

읽어 들이는 단계의 실패 (`plugin.aot` 이 0바이트로 잘려 있을 때. exit 0, 진단 2건, 0.8초):

```text
File truncated before or at offset 0x0.
Loading dynamic library failed: dlopen(<상태 폴더>/.plugin_manager/<hash>/bin/plugin.aot, 0x0001): tried: …
An error occurred while executing an analyzer plugin: IsolateSpawnException: Unable to spawn isolate: The uri(file://<상태 폴더>/.plugin_manager/<hash>/bin/plugin.aot) provided to `Isolate.spawnUri()` does not contain a valid AOT snapshot.

An error occurred while executing an analyzer plugin: Unrecorded error while starting the plugin.
#0      PluginSession.start (package:analysis_server/src/plugin/plugin_isolate.dart:499)
```

`example/` 의 정답지에는 warning 인 plugin 진단이 들어가므로(`exit 2`), plugin 준비가 실패하면 plugin 줄이 빠지고, `exit` 줄이 0 으로 어긋나고, stderr 에 머리말이 찍힌다. 세 가지가 한꺼번에 어긋나 헛통과할 길이 없다.

### 7. 실패한 뒤 다음 실행이 스스로 회복하는가

| 무슨 일이 있었나 | 다음 실행 | 근거 |
|---|---|---|
| 분석 도중 Ctrl-C (처음 실행 도중 4번, 다시 컴파일하는 도중 3번) | **7번 모두 통과.** 컴파일러는 끊겨도 잘린 `plugin.aot` 을 남기지 않았다 | 008 |
| `plugin.aot` 이 잘린 채 남음 | **계속 실패.** 서버는 `depfile.txt` 기준으로 "최신"이라고 보고 잘린 파일을 그대로 쓴다 | 008 |
| → `plugin.aot` 만 지움 | 통과, 12.8초 (다시 컴파일) | 008 |
| → 상태 폴더를 통째로 지움 | 빈 상태 폴더의 처음 실행과 같다 (약 15초) | 008 |
| 원인이 그대로인 채 다시 실행 (없는 버전, 닿지 않는 pub 서버 등 9가지) | 1회차와 같은 실패. 실패가 캐시되어 모양이 달라지는 일은 없다 | 002 |

그래서 plugin 실패를 알릴 때 "전용 상태 폴더를 지우고 다시 실행"을 함께 안내한다. 전용 폴더라 지워도 다른 것에 영향이 없고 비용은 15초다. 검증 명령은 사용자가 Ctrl-C 로 끊어도 된다.

### 8. 실제로 쓰인 plugin 버전 읽기 (D-07)

전용 상태 폴더의 `.plugin_manager` 아래에는 폴더가 하나뿐이다. 그 폴더의 `pubspec.lock` 에서 읽는다.

```dart
// sources/008-state-folder-placement/state_probe.dart 의 Probe 에서
/// 상태 폴더의 `.plugin_manager` 아래 폴더들.
List<Directory> pluginFolders(String stateDir) {
  final manager = Directory('$stateDir/.plugin_manager');
  if (!manager.existsSync()) return const [];
  return manager.listSync().whereType<Directory>().toList();
}

/// plugin 폴더의 `pubspec.lock` 에서 풀린 `riverpod_lint` 버전을 읽는다. 없으면 null.
String? readPluginVersion(Directory pluginFolder) {
  final lock = File('${pluginFolder.path}/pubspec.lock');
  if (!lock.existsSync()) return null;
  final lines = lock.readAsLinesSync();
  final start = lines.indexOf('  riverpod_lint:');
  if (start < 0) return null;
  for (final line in lines.skip(start + 1)) {
    if (!line.startsWith('    ')) break;
    final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}
```

- **폴더가 하나가 아니면 버전을 `?` 로 찍고 이유를 알린다.**
  - 0개: 서버가 이 상태 폴더에서 plugin 준비를 시작하지 않았다. `ANALYZER_STATE_LOCATION_OVERRIDE` 가 더는 듣지 않을 때가 이 모양이다 (→ Constraints).
  - 2개 이상: 그 상태 폴더로 다른 경로의 프로젝트를 분석한 적이 있다. 폴더 이름이 경로에서 나오므로 저장소 폴더를 옮기거나 이름을 바꾸면 하나 더 생긴다 (이 경우를 직접 재지는 않았다). 상태 폴더를 지우고 다시 실행하면 하나가 된다.
- **폴더는 하나인데 `readPluginVersion` 이 null 이면 그때도 `?` 다.** plugin 을 받지 못한 실패가 이 모양일 수 있다 — 002 의 실패 문구가 `.plugin_manager/<hash>` 경로를 찍으므로 폴더는 생긴 것으로 보인다. 실패한 뒤의 폴더 수와 `pubspec.lock` 의 유무를 직접 재지는 않았다.
- plugin 준비 실패를 알린 실행에서 읽힌 버전은 앞선 실행이 남긴 `pubspec.lock` 의 값일 수 있다 (재지 않았다). 그 실행에서는 버전 줄을 어떻게 찍을지 계획에서 정한다.
- 분석이 끝난 **뒤에** 읽는다. 처음 실행에서는 분석 전에 폴더가 없다.
- D-07 이 화면에 찍으라고 한 것은 셋이다: SDK(Flutter / Dart), 기반 세트(`flutter_lints` / `lints`), 해석된 `riverpod_lint` 버전 (`.planning/phases/02-verification-harness/02-CONTEXT.md`). 이 절은 셋째만 다룬다.
- 서버가 만든 가상 패키지의 `pubspec.yaml` 은 배포 파일의 제약을 그대로 옮겨 적는다 (`riverpod_lint: ^3.1.3`). 실제로 풀린 값은 `pubspec.lock` 에만 있다.

기본 자리(`~/.dartServer`)를 그대로 쓰면서 자기 폴더를 고르는 길은 셋 다 막혀 있다.

| 방법 | 결과 |
|---|---|
| 폴더 이름을 계산한다 | 이름은 **링크를 푼 경로의 code unit** 을 md5 한 값이다 (`hex.encode(md5.convert(path.codeUnits).bytes)`). `dart:io` / `dart:convert` 에 md5 가 없다 |
| 폴더 내용으로 고른다 | 폴더 안 어디에도 분석 대상 프로젝트의 경로가 없다 (0회) |
| 가장 최근에 바뀐 폴더를 고른다 | 재실행은 어느 파일의 수정 시각도 바꾸지 않는다 |

### 9. 걸리는 시간

| 상황 | 로컬 (macOS arm64) | GitHub Linux runner |
|---|---|---|
| 처음 실행 (plugin 받기 + 컴파일) | 약 15~18초 (008 은 14.7~15.3초, 001·002·006 은 17~18초) | 약 43초 (27~53초) |
| 재실행 | 약 3.6~6초 (008 은 3.6~3.9초) | 약 8초 (5.5~10.6초) |
| plugin 을 다시 컴파일만 할 때 | 약 13초 | 재지 않음 |
| pub 서버에 닿지 못할 때 | 26~31초 뒤 plugin 진단 없이 끝남 | 재지 않음 |

서버가 뜰 때마다 하는 일은 셋이다: (1) 가상 패키지의 `pubspec.yaml` 과 `bin/plugin.dart` 를 내용이 다를 때만 다시 쓰고, (2) `dart pub upgrade` 를 **항상** 돌리고, (3) 기존 `bin/plugin.aot` (약 15MB) 이 `bin/depfile.txt` 기준으로 최신이면 그대로 쓰고 아니면 기존 파일을 지운 뒤 `dart compile aot-snapshot` 을 돌린다. `analysis_server` (tag 3.13.4) 의 소스에서 읽은 순서이고 008 의 실험 결과가 이와 맞았다. 처음 실행의 시간은 대부분 컴파일이다.

## What to Avoid

- **하위 폴더를 인자로 주는 것** (`dart analyze lib`, `dart analyze lib/src`, 저장소 루트에서 `dart analyze example/lib`). plugin 진단을 전부 잃고 종료 코드도 0 이 된다. plugin 을 준비조차 하지 않는다. 조용히 통과하는 모양이라 가장 위험하다. (plugin 진단이 필요 없는 규칙 검사만 폴더를 인자로 준다 → rule-status-check.md)
- **종료 코드만 보고 판정하는 것.** plugin 이 죽어도 0 이나 2 가 나온다.
- **머리말을 `startsWith` 나 "stderr 의 첫 줄"로 찾는 것.** `plugin.aot` 을 읽어 들이지 못한 실패에서는 셋째 줄에 온다.
- **사용 통계를 끄지 않고 실행하는 것.** 같은 명령이 가끔 종료 코드 255 로 죽는다. 이 컴퓨터에서 기본 방식 65번 중 8번이었다 (cold 24번 중 7번, warm 41번 중 1번). 끈 66번은 모두 정상이었다.
- **"plugin 이 이미 컴파일되어 있으니 네트워크 없이도 된다"는 가정.** `plugin.aot` 이 상태 폴더에 그대로 있어도 pub 서버에 닿지 못하면 plugin 진단이 0건이다. Analysis Server 는 뜰 때마다 `dart pub upgrade` 를 돌린다.
- **`plugins:` 에 다른 plugin 을 더 선언하는 것을 가볍게 보는 것.** 선언한 plugin 들은 가상 패키지 하나에 묶여 함께 받아지고 함께 컴파일된다. 하나가 실패하면 멀쩡한 `riverpod_lint` 의 진단도 사라진다.
- **검증 때마다 상태 폴더를 지우는 것.** 매번 처음 실행이 되어 로컬 15초, CI 43초가 든다. 지우는 것은 plugin 실패 뒤의 복구 수단이다.
- **기본 자리(`~/.dartServer`)에서 버전을 읽는 것.** 다른 프로젝트의 폴더가 섞여 있고 자기 폴더를 고를 방법이 없다 (→ 8번). md5 를 손으로 구현하는 길(약 50줄)은 경로를 서버와 똑같이 만들어야 한다 — 링크를 풀고, UTF-8 바이트가 아니라 UTF-16 code unit 의 아래 8비트를 모은다. 경로에 영문·숫자만 있을 때는 UTF-8 과 결과가 같아 틀린 구현이 드러나지 않는다.
- **검증 명령 둘을 빈 상태 폴더 하나에 동시에 띄우는 것.** 처음 실행 둘이 정확히 겹친 20쌍 중 1쌍(실행으로는 40번 중 1번)에서 한쪽이 plugin 진단 없이 exit 0 으로 끝났다. 한쪽이 `plugin.aot` 을 쓰는 도중에 다른 쪽이 읽은 것이다.
- **`flutter analyze`.** Flutter 3.47.5 에서 plugin 진단을 내지 않는다 (PROJECT.md).
- **저장소 루트에서 `dart analyze example` 로 바꾸는 것.** 3.13.4 에서는 plugin 진단이 나왔지만(001, 007), 폴더 인자 문제(sdk#62710)와 맞닿은 형태라 채택하지 않았다.

## Constraints

- 인자 없이 실행하면 `dart analyze` 는 현재 디렉터리를 대상으로 삼는다 (`pkg/dartdev/lib/src/commands/analyze.dart`, tag 3.13.4). 이 명령이 스스로 내는 종료 코드는 0 / 1 / 2 / 3 / 4 뿐이고 255 는 그 밖의 값이다.
- 폴더 인자에서 plugin 진단을 잃는 문제는 dart-lang/sdk#62710 이 "Dart 3.14 에 실릴 것"이라는 답으로 닫혔다 (2026-10-01). SDK 를 올리면 실행 형태 표를 다시 재야 한다 (`sources/001-…/matrix.dart`).
- 종료 코드 255 의 원인: Analysis Server 가 메모리 사용량이 512MB 늘 때마다 사용 통계를 보내는데, 그 전송이 끝나기 전에 분석이 끝나면 연결 시도가 취소되고 그 예외를 아무도 받지 않는다. 막힌 네트워크가 아니라 타이밍 문제다. upstream 이슈는 찾지 못했다.
- 255 의 비율은 이 세션의 실행 환경에서 잰 값이다. 다른 터미널에서는 다를 수 있다.
- CI 에서는 `dart` 가 `CI` / `GITHUB_ACTIONS` 환경변수를 보고 사용 통계를 스스로 끈다. GitHub runner 에서 끄는 인자 없이 돌린 cold 40번 중 255 는 0번이었다. 그래도 로컬과 같은 방식으로 돌도록 플래그는 항상 붙인다.
- plugin 을 받거나 컴파일하지 못한 실패는 원인이 그대로이면 다음 실행에서도 같은 모양으로 되풀이된다. 9가지 경우 모두 1회차와 2회차가 같았다 (002). 컴파일된 파일이 잘린 채 남은 실패는 원인을 지울 때까지 이어진다 (→ 7번).
- SDK 와 맞지 않는 옛 plugin 버전(`riverpod_lint 3.1.0` 고정)은 멈추지 않고 4초 만에 실패한다. `analyzer_plugin ^0.13.10` 을 요구해 Dart 3.13.4 의 `analysis_server_plugin ^0.3.8` 과 함께 풀리지 않는다.
- 점(`.`)으로 시작하는 폴더 아래의 프로젝트도 그 프로젝트가 분석 대상의 루트이면 정상으로 분석된다. 반대로 저장소 루트의 분석에는 점으로 시작하는 폴더 아래가 들어가지 않는다.
- **`ANALYZER_STATE_LOCATION_OVERRIDE` 는 소스의 문서 주석에만 적혀 있다** (`analyzer` 14.5.0 의 `lib/file_system/physical_file_system.dart` `_getStandardStateLocation`). 사용자 문서(dart.dev)에 있는 공식 설정인지는 확인하지 않았다. 없어지면 전용 폴더에 `.plugin_manager` 가 생기지 않으므로 버전이 `?` 로 찍혀 드러난다. Dart 3.13.4 에서는 001, 006(GitHub runner 의 30번 포함), 007, 008 이 이 환경변수로 돌았다.
- **plugin 폴더에는 잠금이 없다.** 같은 폴더를 두 서버가 쓰는 경우를 막는 코드는 `analysis_server` (tag 3.13.4) 소스에서 찾지 못했다. 함께 쓸 때의 실측:

  | 경우 | 쌍 | 실패한 쌍 |
  |---|---|---|
  | 빈 폴더에서 처음 실행 둘을 **동시에** | 20 | **1** |
  | 빈 폴더에서 처음 실행, 둘째를 3~12초 늦게 | 17 | 0 |
  | 준비된 폴더에서 둘을 동시에 | 8 | 0 |
  | 대조군: 상태 폴더를 따로 주고 처음 실행 둘을 동시에 | 2 | 0 |

- 오래 떠 있는 서버(`dart language-server`, IDE 가 프로젝트를 열어 둔 상황을 흉내 냄)와 상태 폴더를 함께 써도 명령줄 분석 3번이 모두 통과했다. 서버가 쓰고 있는 `plugin.aot` 을 명령줄 쪽이 지우고 다시 만들어도 서버는 죽지 않았다. 전용 폴더를 쓰면 IDE 와는 애초에 폴더가 나뉜다.
- 전용 폴더의 비용: IDE 가 기본 자리에 이미 준비해 둔 plugin 을 쓰지 못하므로 첫 검증이 15초 든다. 시간 자체는 기본 자리와 같다.
- 확인하지 않은 것: plugin 이 뜬 뒤 분석 도중에 죽는 경우, pub 서버가 느리게 응답만 하고 끝나지 않는 경우의 시간 (CI 의 `timeout-minutes` 가 막는다), 동시 실행의 실패가 폴더에 잘린 `plugin.aot` 을 남기는지, 실제 IDE(VS Code)와 함께 쓸 때, 008 의 실험을 GitHub Linux runner 에서 한 것.

## Origin

Synthesized from spikes: 001, 002, 008 (정규화 함수는 006 의 스크립트에서 가져왔다)
Source files available in: sources/001-analyze-invocation-form/, sources/002-plugin-setup-failure-exit/, sources/006-github-runner-cold-plugin/, sources/008-state-folder-placement/
원본 로그와 JSON: `.planning/spikes/001-analyze-invocation-form/results/`, `.planning/spikes/002-plugin-setup-failure-exit/results/`, `.planning/spikes/008-state-folder-placement/results/`
