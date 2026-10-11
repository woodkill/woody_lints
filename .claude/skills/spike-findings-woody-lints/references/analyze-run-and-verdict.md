# `dart analyze` 실행과 결과 판정

검증 명령(`tool/verify.dart`)이 `example/` 을 분석하고, 그 결과를 "통과 / 정답지와 다름 / plugin 준비 실패 / 도구가 죽음" 으로 가르는 부분이다.

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

## How to Build It

### 1. 실행

패키지 루트를 `workingDirectory` 로 두고, 경로 인자 없이, 전역 플래그 `--suppress-analytics` 를 `analyze` **앞에** 붙인다.

```dart
// sources/006-github-runner-cold-plugin/ci_probe.dart 의 runAnalyze 에서.
// globalArguments 에 const ['--suppress-analytics'] 를 넘긴 형태가 채택된 방식이다.
final result = await Process.run(
  Platform.resolvedExecutable,
  [...globalArguments, 'analyze', '--format=json'],
  workingDirectory: fixtureDir,
  environment: {
    if (stateDir != null) 'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir,
  },
);
```

- `Platform.resolvedExecutable` 을 쓰면 `fvm dart run tool/verify.dart` 로 띄운 그 SDK 의 `dart` 가 그대로 쓰인다.
- 사용 통계를 끄는 방법은 둘이고 결과가 같았다: 전역 플래그 `--suppress-analytics`, 환경변수 `DASH__SUPPRESS_ANALYTICS=true`.
- `ANALYZER_STATE_LOCATION_OVERRIDE` 는 Analysis Server 의 상태 폴더(기본 `~/.dartServer`)를 다른 곳으로 돌린다. 실제 검증 명령은 주지 않아도 된다(기본 자리를 쓰면 두 번째부터 빠르다). 빈 폴더를 주면 plugin 을 처음부터 다시 준비한다.

### 2. stdout 을 정답지 형식으로 바꾸기

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
- 정렬은 문자열 정렬이다. `lib/main.dart:10` 이 `lib/main.dart:9` 보다 앞에 온다 (`sources/006-…/expected_001.txt` 가 그 순서다). 정답지 파일도 같은 방식으로 정렬해 견준다.

### 3. 판정 순서

두 spike 의 "가져갈 것"을 합친 순서다. 각 조건은 실측했고, 이 순서로 묶은 전체 흐름은 아직 한 스크립트로 돌려 보지 않았다.

1. **stderr 에 `An error occurred while executing an analyzer plugin:` 이 있는가** → "plugin 준비 실패"로 알린다. stderr 의 `stderr = …` 줄을 그대로 보여 주고(원인이 거기에 적혀 있다) "네트워크를 확인하세요"를 함께 안내한다. 정답지 비교 결과보다 먼저 보여야 한다.
2. **종료 코드가 0 / 2 / 3 이 아니거나 stdout 이 JSON 이 아닌가** → "정답지와 다르다"가 아니라 "도구가 죽었다"로 따로 알린다.
3. **정답지 비교** → `exit N` 줄, 정답지에는 있는데 나오지 않은 줄, 정답지에 없는데 나온 줄.

종료 코드 4 는 1번에 먼저 걸린다 (4 가 나온 두 경우 모두 stderr 에 머리말이 있었다).

### 4. 종료 코드가 뜻하는 것

| exit | 뜻 | 근거 |
|---|---|---|
| 0 | 진단이 없거나 info 뿐 | 002, 003 |
| 2 | warning 이 하나라도 있다 | 002, 003 |
| 3 | error 가 하나라도 있다 | 003 |
| 4 | 진단이 **하나도 없고** 서버 오류가 있었다. `example/` 에서는 진단이 항상 있으므로 나올 일이 없다. 나오면 무조건 실패 | 002 (s2, s6) |
| 255 | Analysis Server 가 죽었다. stdout 에 JSON 이 없다. 사용 통계를 끄지 않았을 때만 봤다 | 001 |

종료 코드는 진단의 강도만 따른다. plugin 이 죽었는지는 알려 주지 않는다.

### 5. plugin 준비가 실패했을 때의 모양

| 무엇 | 정상 | plugin 준비 실패 |
|---|---|---|
| stdout | JSON, plugin 진단 포함 | **멀쩡한 JSON**, plugin 진단만 빠짐 |
| stderr | 비어 있음 | 머리말로 시작하는 36~55줄 |
| 종료 코드 | 정답지의 `exit` 와 같음 | 남은 진단의 강도대로 (info 뿐이면 0) |

stderr 의 머리말은 실패 단계와 상관없이 같다.

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

`example/` 의 정답지에는 warning 인 plugin 진단이 들어가므로(`exit 2`), plugin 준비가 실패하면 plugin 줄이 빠지고, `exit` 줄이 0 으로 어긋나고, stderr 에 머리말이 찍힌다. 세 가지가 한꺼번에 어긋나 헛통과할 길이 없다.

### 6. 실제로 쓰인 plugin 버전 읽기 (D-07)

`<상태 폴더>/.plugin_manager/<hash>/pubspec.lock` 에 있다. `<hash>` 는 **분석 대상 패키지 루트의 절대 경로를 md5 한 값**이다 (`printf '%s' "$PWD" | md5` 와 일치). 설정 내용이 아니라 경로로 정해진다.

```dart
// sources/006-github-runner-cold-plugin/ci_probe.dart
/// plugin 상태 폴더에서 실제로 풀린 `riverpod_lint` 버전들을 읽는다.
Set<String> readResolvedPluginVersions(Directory stateRoot) {
  final manager = Directory('${stateRoot.path}/.plugin_manager');
  final versions = <String>{};
  if (!manager.existsSync()) return versions;
  for (final entity in manager.listSync()) {
    final lock = File('${entity.path}/pubspec.lock');
    if (!lock.existsSync()) continue;
    final lines = lock.readAsLinesSync();
    final start = lines.indexOf('  riverpod_lint:');
    if (start < 0) continue;
    for (final line in lines.skip(start + 1)) {
      if (!line.startsWith('    ')) break;
      final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
      if (match != null) versions.add(match.group(1)!);
    }
  }
  return versions;
}
```

이 함수는 `.plugin_manager` 아래의 모든 폴더를 훑는다. 기본 자리(`~/.dartServer`)에는 다른 프로젝트의 폴더도 섞여 있으므로(이 컴퓨터에는 49개), 그 자리를 읽을 때는 md5 로 `example/` 의 폴더 하나만 골라야 한다. 상태 폴더를 따로 정해 주면 고를 필요가 없다.

### 7. 걸리는 시간

| 상황 | 로컬 (macOS arm64) | GitHub Linux runner |
|---|---|---|
| 처음 실행 (plugin 받기 + 컴파일) | 약 17~18초 | 약 43초 (27~53초) |
| 재실행 | 약 4~6초 | 약 8초 (5.5~10.6초) |
| pub 서버에 닿지 못할 때 | 26~31초 뒤 plugin 진단 없이 끝남 | 재지 않음 |

처음 실행 때 Analysis Server 는 `<상태 폴더>/.plugin_manager/<hash>/` 에 가상 패키지를 만들고 `dart pub upgrade` 를 돌린 뒤 `dart compile aot-snapshot` 으로 plugin 을 컴파일한다 (`bin/plugin.aot`, 약 15MB). 시간의 대부분은 컴파일이다.

## What to Avoid

- **하위 폴더를 인자로 주는 것** (`dart analyze lib`, `dart analyze lib/src`, 저장소 루트에서 `dart analyze example/lib`). plugin 진단을 전부 잃고 종료 코드도 0 이 된다. plugin 을 준비조차 하지 않는다. 조용히 통과하는 모양이라 가장 위험하다.
- **종료 코드만 보고 판정하는 것.** plugin 이 죽어도 0 이나 2 가 나온다.
- **사용 통계를 끄지 않고 실행하는 것.** 같은 명령이 가끔 종료 코드 255 로 죽는다. 이 컴퓨터에서 기본 방식 65번 중 8번이었다 (cold 24번 중 7번, warm 41번 중 1번). 끈 66번은 모두 정상이었다.
- **"plugin 이 이미 컴파일되어 있으니 네트워크 없이도 된다"는 가정.** `plugin.aot` 이 상태 폴더에 그대로 있어도 pub 서버에 닿지 못하면 plugin 진단이 0건이다. Analysis Server 는 뜰 때마다 `dart pub upgrade` 를 돌린다.
- **`plugins:` 에 다른 plugin 을 더 선언하는 것을 가볍게 보는 것.** 선언한 plugin 들은 가상 패키지 하나에 묶여 함께 받아지고 함께 컴파일된다. 하나가 실패하면 멀쩡한 `riverpod_lint` 의 진단도 사라진다.
- **검증 때마다 상태 폴더를 지우는 것.** 매번 처음 실행이 되어 로컬 18초, CI 43초가 든다.
- **`flutter analyze`.** Flutter 3.47.5 에서 plugin 진단을 내지 않는다 (PROJECT.md).
- **저장소 루트에서 `dart analyze example` 로 바꾸는 것.** 3.13.4 에서는 plugin 진단이 나왔지만, 폴더 인자 문제(sdk#62710)와 맞닿은 형태라 채택하지 않았다.

## Constraints

- 인자 없이 실행하면 `dart analyze` 는 현재 디렉터리를 대상으로 삼는다 (`pkg/dartdev/lib/src/commands/analyze.dart`, tag 3.13.4). 이 명령이 스스로 내는 종료 코드는 0 / 1 / 2 / 3 / 4 뿐이고 255 는 그 밖의 값이다.
- 폴더 인자에서 plugin 진단을 잃는 문제는 dart-lang/sdk#62710 이 "Dart 3.14 에 실릴 것"이라는 답으로 닫혔다 (2026-10-01). SDK 를 올리면 실행 형태 표를 다시 재야 한다 (`sources/001-…/matrix.dart`).
- 종료 코드 255 의 원인: Analysis Server 가 메모리 사용량이 512MB 늘 때마다 사용 통계를 보내는데, 그 전송이 끝나기 전에 분석이 끝나면 연결 시도가 취소되고 그 예외를 아무도 받지 않는다. 막힌 네트워크가 아니라 타이밍 문제다. upstream 이슈는 찾지 못했다.
- 255 의 비율은 이 세션의 실행 환경에서 잰 값이다. 다른 터미널에서는 다를 수 있다.
- CI 에서는 `dart` 가 `CI` / `GITHUB_ACTIONS` 환경변수를 보고 사용 통계를 스스로 끈다. GitHub runner 에서 끄는 인자 없이 돌린 cold 40번 중 255 는 0번이었다. 그래도 로컬과 같은 방식으로 돌도록 플래그는 항상 붙인다.
- plugin 준비 실패는 캐시되지 않는다. 9가지 경우 모두 1회차와 2회차가 같았다.
- SDK 와 맞지 않는 옛 plugin 버전(`riverpod_lint 3.1.0` 고정)은 멈추지 않고 4초 만에 실패한다. `analyzer_plugin ^0.13.10` 을 요구해 Dart 3.13.4 의 `analysis_server_plugin ^0.3.8` 과 함께 풀리지 않는다.
- 점(`.`)으로 시작하는 폴더 아래의 프로젝트도 그 프로젝트가 분석 대상의 루트이면 정상으로 분석된다. 반대로 저장소 루트의 분석에는 점으로 시작하는 폴더 아래가 들어가지 않는다.
- 확인하지 않은 것: plugin 이 뜬 뒤 분석 도중에 죽는 경우, pub 서버가 느리게 응답만 하고 끝나지 않는 경우의 시간 (CI 의 `timeout-minutes` 가 막는다).

## Origin

Synthesized from spikes: 001, 002 (정규화 함수와 버전 읽기는 006 의 스크립트에서 가져왔다)
Source files available in: sources/001-analyze-invocation-form/, sources/002-plugin-setup-failure-exit/, sources/006-github-runner-cold-plugin/
원본 로그와 JSON: `.planning/spikes/001-analyze-invocation-form/results/`, `.planning/spikes/002-plugin-setup-failure-exit/results/`
