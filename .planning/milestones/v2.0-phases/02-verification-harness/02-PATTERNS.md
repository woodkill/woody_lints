# Phase 2: Verification Harness - Pattern Map

**Mapped:** 2026-10-11
**Files analyzed:** 14 (새로 만드는 파일 11, 고치는 파일 3)
**Analogs found:** 12 / 14

이 저장소는 설정 전용 패키지라 추적 중인 Dart 소스가 없고 `example/`, `tool/`, `.github/` 도 아직 없다. 그래서 이 phase 가 만드는 파일의 analog 는 대부분 **spike 산출물**(`.planning/spikes/NNN-…/`, 모두 git 추적 대상임을 `git ls-files` 로 확인)이다. spike 스크립트는 실제로 실행돼 결과를 낸 코드이고, `tool/verify.dart` 와 같은 조건(`dart:io` / `dart:convert` 만, `Platform.resolvedExecutable` 로 하위 `dart` 호출)으로 짜여 있어 조각을 그대로 옮길 수 있다. `.claude/skills/spike-findings-woody-lints/sources/` 는 같은 파일의 읽기용 사본이므로 이 문서는 원본 경로(`.planning/spikes/…`)만 가리킨다.

기존 추적 파일(`analysis_options.yaml`, `pubspec.yaml`, `lib/analysis_options.yaml`, `.gitignore`, `CHANGELOG.md`)은 **주석 문체와 배치 관례**의 analog 로 쓴다.

spike 스크립트와 `02-RESEARCH.md` § "Code Examples" 가 다른 곳은 각 항목의 **"차이와 권고"** 에 적었다. 조용히 한쪽을 고르지 않았다.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `example/pubspec.yaml` (new) | config (fixture manifest) | — | `.planning/spikes/001-analyze-invocation-form/fixture/pubspec.yaml` | exact (경로 한 줄만 다름) |
| `example/analysis_options.yaml` (new) | config (fixture options) | — | `.planning/spikes/001-analyze-invocation-form/fixture/analysis_options.yaml` | exact |
| `example/lib/added_rules.dart`, `base_rules.dart`, `main.dart`, `riverpod_rules.dart`, `should_not_appear.dart`, `generated/sample.g.dart`, `generated/sample.freezed.dart` (new, 7개) | fixture (위반 샘플) | — | `.planning/spikes/001-analyze-invocation-form/fixture/lib/main.dart` (주석 관례), 전문은 `02-RESEARCH.md` § Code Examples 6 | role-match (본문은 RESEARCH 가 실측한 전문을 글자 그대로) |
| `example/expected_diagnostics.txt` (new) | test (golden / 정답지) | file-I/O | `.planning/spikes/006-github-runner-cold-plugin/expected_001.txt` | exact (형식 동일, 머리 주석만 추가) |
| `example/pubspec.lock` (new) | config (생성물, 커밋) | — | 없음 (spike 의 lock 은 gitignore 대상) | no analog — `dart pub get` 이 만든다 |
| `example/README.md` (new) | doc (fixture 설명 + VERIFY-08 / D-03 기록) | — | `.planning/spikes/006-github-runner-cold-plugin/README.md` (Investigation Trail / Results 절), `CHANGELOG.md` 1.3.0 항목 (한국어 기록 문체) | role-match |
| `tool/verify.dart` (new) | script (검증 명령) | batch (프로세스 실행 → JSON 변환 → 파일 비교) | `.planning/spikes/006-github-runner-cold-plugin/ci_probe.dart` (비교·pub get), `.planning/spikes/008-state-folder-placement/state_probe.dart` (상태 폴더·plugin 버전·머리말), `.planning/spikes/007-root-analysis-with-example/probe.dart` (규칙 검사) | exact (세 파일의 조각을 합친다) |
| `.github/workflows/verify.yml` (new) | config (CI) | event-driven | `.planning/spikes/006-github-runner-cold-plugin/spike-006-cold-plugin.yml` | exact (트리거·시간 제한·matrix 만 바꾼다) |
| `analysis_options.yaml` (root, modify) | config (자체 분석) | — | 자기 자신 + `.planning/spikes/007-root-analysis-with-example/probe.dart` `setRootExcludes` | exact |
| `.gitignore` (modify) | config | — | 자기 자신 (5–7행의 "이유 주석 + 패턴" 꼴) | exact |
| `CHANGELOG.md` (modify) | doc | — | 자기 자신 19행 (1.3.0 의 "저장소 안쪽만 바뀜" 선례) + `VERSIONING.md` § "CHANGELOG 항목 형식" | exact |

## Pattern Assignments

### `example/pubspec.yaml` (config, fixture manifest)

**Analog:** `.planning/spikes/001-analyze-invocation-form/fixture/pubspec.yaml` (전문 16줄)

**전문 (1–16행):**
```yaml
name: spike_invocation_fixture
description: spike 001 — dart analyze 실행 형태별 plugin 진단 확인용 연습 프로젝트
publish_to: 'none'
version: 0.0.0

environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.0

dev_dependencies:
  # 저장소 루트의 woody_lints 를 그대로 받는다 (사용 프로젝트의 git 의존성 자리).
  woody_lints:
    path: ../../../..
```

**바꿀 것:** `name: woody_lints_example`, `description` 을 "woody_lints 검증용 연습 프로젝트 — …" 로, `path: ..`. 그 외는 그대로 (RESEARCH § Code Examples 6 의 `example/pubspec.yaml` 과 일치한다). `woody_lints` 는 `dev_dependencies` 로 충분하다 — spike 001~008 전부 이 형태로 plugin 진단이 나왔다. `build_runner` / `riverpod_generator` 를 붙이지 않는다 (D-02).

**주석 관례:** 루트 `pubspec.yaml` 13–15행처럼 "왜 이 자리인가" 를 설정 **위에** 한국어로 적는다.

---

### `example/analysis_options.yaml` (config, fixture options)

**Analog:** `.planning/spikes/001-analyze-invocation-form/fixture/analysis_options.yaml` (1줄)

```yaml
include: package:woody_lints/analysis_options.yaml
```

이 한 줄이 전부다. 주석도 두지 않는다 — `tool/verify.dart` 단계 3 이 "주석·빈 줄을 뺀 나머지가 이 한 줄인가" 를 검사하므로 주석은 허용되지만, `flutter pub get` 이 써넣는 `analyzer: exclude: - build/**` 세 줄과 구별이 또렷하도록 비워 둔다. `build/**` 제외를 미리 적으면 사용 프로젝트의 모양과 달라진다 (RESEARCH Anti-Patterns).

---

### `example/lib/*.dart` 7개 (fixture, 위반 샘플)

**Analog (주석 관례):** `.planning/spikes/001-analyze-invocation-form/fixture/lib/main.dart` (1–11행)

```dart
import 'package:flutter/material.dart';

/// 앱 진입점.
///
/// 일부러 어긴 규칙:
/// - `avoid_print` (기반 세트), `prefer_single_quotes` (woody_lints 가 추가)
/// - `missing_provider_scope` (riverpod_lint, warning 으로 선언됨)
void main() {
  print("spike 001");
  runApp(const MaterialApp(home: SizedBox()));
}
```

**관례:** 위반마다 바로 위 `///` 문서 주석에 `` `규칙이름` — 무엇을 어겼는지 `` 를 한국어로 적고, plugin 규칙은 `(riverpod_lint, 강도)` 를 덧붙인다. 파일 머리의 `//` 주석에 그 파일이 맡는 규칙 묶음을 적는다.

**본문:** `02-RESEARCH.md` § Code Examples 6 의 전문을 **빈 줄까지 글자 그대로** 옮긴다. 정답지 16줄의 줄 번호가 그 파일 모양에 묶여 있다 (예: `added_rules.dart:7` = `Text('a')`, `base_rules.dart:38` = `items.length == 0`). spike 001 의 `print("spike 001")` 처럼 한 줄에 규칙 둘이 걸리는 꼴은 쓰지 않는다 (RESEARCH Pitfall 3 — D-01 의 "규칙마다 한 건" 을 흐린다).

**파일 역할 분담 (RESEARCH 권고 2 · 4):**

| 파일 | 담는 것 | 정답지 줄 수 |
|---|---|---|
| `added_rules.dart` | 이 패키지가 실제로 추가하는 6개 | 6 |
| `base_rules.dart` | 기반 세트와 겹치는 6개 + 기반 세트만의 `prefer_is_empty` | 7 |
| `main.dart` | `missing_provider_scope` (warning) | 1 |
| `riverpod_rules.dart` | `avoid_public_notifier_properties` (info), `provider_parameters` (warning) | 2 |
| `should_not_appear.dart` | `@immutable` 을 함수에 → `invalid_annotation_target` (억제돼야 함) | 0 |
| `generated/sample.g.dart`, `sample.freezed.dart` | `print("g")` / `print("f")` (exclude 돼야 함) | 0 |

**차이와 권고:** spike 003 의 fixture(`r01_missing_provider_scope.dart` 등)는 규칙 15개를 파일 하나씩 나눴다. RESEARCH 는 규칙 묶음별 4파일 + "나오면 안 되는" 3파일을 권하고 그 구성으로 16줄을 실측했다 → RESEARCH 를 따른다.

---

### `example/expected_diagnostics.txt` (test, golden)

**Analog:** `.planning/spikes/006-github-runner-cold-plugin/expected_001.txt` (전문 5줄)

```text
exit 2
lib/main.dart:10  warning  missing_provider_scope
lib/main.dart:9  info  avoid_print
lib/main.dart:9  info  prefer_single_quotes
lib/src/counter.dart:8  info  avoid_public_notifier_properties
```

**형식 규칙 (D-04 + spike 관례):** 첫 줄 `exit N`, 이후 `상대경로:줄  강도  규칙이름` (칸 사이 공백 2개, 강도는 JSON `severity` 소문자). **문자열 정렬**이라 `:10` 이 `:9` 보다 앞에 온다 — 정답지도 같은 정렬로 저장한다. 읽는 쪽(`Expected.read`)이 `#` 줄과 빈 줄을 건너뛰므로 머리 주석을 둘 수 있다.

**이 phase 의 내용:** RESEARCH 권고 2 의 16줄 + `exit 2` 를 그대로 쓰되, 첫 줄에 `# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, YYYY-MM-DD` 머리 주석을 둔다 (`lib/analysis_options.yaml` 55–56행의 "버전 + 날짜" 관례). 실제 저장소에서 첫 `--update` 가 낸 결과가 최종 기준이다 (RESEARCH A4).

---

### `example/README.md` (doc, fixture 설명 + 기록)

**Analog:** `.planning/spikes/006-github-runner-cold-plugin/README.md` 의 절 구성 (`## How to Run` 36행, `## Investigation Trail` 63행 아래 `### 1. 로컬 연습 (Dart 3.13.4, macOS arm64, 2026-10-11)` 처럼 **제목에 실측 조건**을 붙이는 꼴, `## Results` 130행)

**기록 문체 analog:** `CHANGELOG.md` 19행
```markdown
- 저장소 자체 분석용 루트 `analysis_options.yaml` 추가 — `lib/analysis_options.yaml` 의 `plugins:` 가 이 저장소 안에서는 inner 옵션으로 취급되어 나는 `plugins_in_inner_options` 경고를 제외한다. 사용하는 프로젝트에는 영향 없음.
```

**담을 것 (RESEARCH 권고 3):**
1. 이 폴더가 "일부러 규칙을 어긴 연습용 프로젝트" 라는 설명과 종료 코드의 뜻 (`exit 2` = warning 이 있음)
2. 실행 명령: `fvm dart run tool/verify.dart`, 갱신: `--update`
3. `## 검증이 실제로 잡아내는지 확인한 기록` — RESEARCH 권고 3 의 표(변경 / 정답지와의 diff / 어느 요구사항) + 실측 조건 한 줄 + "변경은 커밋하지 않고 되돌렸다". 로컬 절대 경로를 적지 않는다 (spike CONVENTIONS 43행, D-08).

---

### `tool/verify.dart` (script, batch)

세 spike 스크립트의 조각을 합친다. 아래 순서는 RESEARCH 권고 10 의 실행 순서다.

#### Imports / 머리 주석

**Analog:** `.planning/spikes/008-state-folder-placement/state_probe.dart` 1–19행
```dart
// spike 008 — Analysis Server 의 상태 폴더(plugin 을 받아 두는 곳)를 어디에 둘지 정하는 데 필요한 것을 잰다.
//
// 실행: fvm dart run .planning/spikes/008-state-folder-placement/state_probe.dart <작업 폴더> [부 ...]
// …
// 저장소의 파일은 읽기만 한다. …
import 'dart:async';
import 'dart:convert';
import 'dart:io';
```
**관례:** 파일 머리 `//` 주석에 (1) 무엇을 하는지 한 줄, (2) `실행:` 명령, (3) 건드리는 것과 건드리지 않는 것. import 는 `dart:` 셋 이내 (D-11). `verify.dart` 는 `실행: fvm dart run tool/verify.dart [--update]` 와 "`lib/` 는 읽기만 한다, `build/woody_rule_check/` 와 `.dart_tool/woody_verify/` 를 만든다" 를 적는다.

#### 정답지 읽기

**Analog:** `.planning/spikes/006-github-runner-cold-plugin/ci_probe.dart` 74–96행 (`Expected`) — 008 의 22–44행과 동일
```dart
/// 기대 진단 파일 (`exit N` 한 줄 + 진단 줄들).
class Expected {
  /// 파일을 읽어 종료 코드와 줄 목록으로 나눈다.
  factory Expected.read(File file) {
    final lines = file
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();
    if (lines.isEmpty || !lines.first.startsWith('exit ')) {
      throw FormatException('첫 줄이 `exit N` 이 아니다: ${file.path}');
    }
    final code = int.parse(lines.first.substring('exit '.length));
    return Expected._(code, lines.skip(1).toList()..sort());
  }

  Expected._(this.exitCode, this.lines);

  /// 기대한 종료 코드.
  final int exitCode;

  /// 기대한 진단 줄 (정렬됨).
  final List<String> lines;
}
```
**덧붙일 것:** `--update` 가 머리 주석(`#` 줄)을 보존하고 날짜만 바꿔야 하므로(D-14, RESEARCH 권고 2), 주석 줄을 따로 보관하는 필드(예: `headerLines`)를 추가한다. spike 에는 없는 부분이다.

#### 진단 정규화

**Analog:** `.planning/spikes/008-state-folder-placement/state_probe.dart` 105–134행
```dart
/// stdout 의 JSON 을 정답지 형식 줄 목록으로 바꾼다. 읽지 못하면 null.
///
/// [bases] 중 하나로 시작하는 경로는 그 뒤만 남긴다 (심볼릭 링크로 들어간 경우 두 가지 경로가 다 올 수 있다).
List<String>? normalizeDiagnostics(String stdoutText, List<String> bases) {
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
  final lines = <String>[];
  for (final d in decoded['diagnostics'] as List) {
    final location = (d as Map<String, dynamic>)['location'] as Map<String, dynamic>;
    var file = location['file'] as String;
    for (final base in bases) {
      if (file.startsWith('$base/')) {
        file = file.substring(base.length + 1);
        break;
      }
    }
    final line = ((location['range'] as Map)['start'] as Map)['line'];
    lines.add('$file:$line  ${(d['severity'] as String).toLowerCase()}  ${d['code']}');
  }
  return lines..sort();
}
```
**차이와 권고:** 006 (`ci_probe.dart` 99–121행) 과 007 은 접두사를 **하나**(`String fixtureDir`) 받는다. 008 은 접두사 **목록**을 받아 `{cwd, resolveSymbolicLinksSync()}` 둘을 넘긴다 (213–223행). RESEARCH § Code Examples 1 은 006 꼴을 싣고 주석으로 "링크를 거치면 resolveSymbolicLinksSync() 접두사도 받는다" 고만 적었다 → **008 꼴(목록)을 쓴다.** macOS 의 `/tmp` 나 FVM 경로처럼 링크를 거치는 자리에서 상대 경로 변환이 깨지지 않는다. 호출부는 `normalizeDiagnostics(stdout, {cwd, Directory(cwd).resolveSymbolicLinksSync()}.toList())`.

"JSON 없음" 은 `null` 로 돌려주고 "진단 0건"(`[]`) 과 구별한다 (spike CONVENTIONS 38행). 판정은 `lines == null` → "도구가 죽음".

#### `example/` 분석 실행 + 머리말 판정

**Analog:** `.planning/spikes/008-state-folder-placement/state_probe.dart` 212–236행 (`Probe.analyze`) 과 77–79행 (`hasPluginHeader`)
```dart
  /// [cwd] 에서 `dart --suppress-analytics analyze --format=json` 을 한 번 돌린다.
  Future<Outcome> analyze({required String cwd, required String stateDir}) async {
    final watch = Stopwatch()..start();
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['--suppress-analytics', 'analyze', '--format=json'],
      workingDirectory: cwd,
      environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir},
    );
    watch.stop();
    final resolved = Directory(cwd).resolveSymbolicLinksSync();
    final lines = normalizeDiagnostics(result.stdout as String, {cwd, resolved}.toList());
    final actual = lines ?? const <String>[];
    …
    return Outcome(
      exitCode: result.exitCode,
      elapsed: watch.elapsed,
      lines: actual,
      jsonOk: lines != null,
      stderrHead: scrub((result.stderr as String).trim().split('\n').take(2).join(' / ')),
      stderrText: scrub((result.stderr as String).trim()),
      ok: lines != null && same && result.exitCode == expected.exitCode,
    );
  }
```
```dart
  /// spike 002 가 찾은 plugin 준비 실패의 머리말이 stderr 에 있는지.
  bool get hasPluginHeader =>
      stderrText.contains('An error occurred while executing an analyzer plugin:');
```
**지킬 것:** `--suppress-analytics` 는 `analyze` **앞** (전역 플래그). 경로 인자 없음. `workingDirectory` 는 `example/` 의 절대 경로. 상태 폴더는 fixture 별 `.dart_tool/woody_verify/<fixture>/` 로 **미리 만들어** 넘긴다 (008 `freshState` 205–210행은 실행마다 비우지만, verify.dart 는 warm 재실행을 위해 **비우지 않는다** — 비우는 것은 "plugin 준비 실패" 안내에서 사용자가 하는 일). `startsWith` 가 아니라 `contains` (RESEARCH Anti-Patterns, spike 008).

**판정 순서 (RESEARCH Pattern 2, 바꾸지 않는다):** ① `hasPluginHeader` → plugin 준비 실패 안내 → ② `lines == null` 또는 exit ∉ {0, 2, 3} → 도구가 죽음 → ③ 정답지 비교.

#### 빠진 줄 / 남는 줄 비교와 화면 출력

**Analog:** `.planning/spikes/006-github-runner-cold-plugin/ci_probe.dart` 150–152행, 155–165행
```dart
    missing: expected.lines.where((l) => !actual.contains(l)).toList(),
    unexpected: actual.where((l) => !expected.lines.contains(l)).toList(),
    expectedExit: expected.exitCode,
```
```dart
  stdout.writeln('${run.matches ? '통과' : '실패'}  $label: exit ${run.exitCode} (기대 ${run.expectedExit}), '
      '${seconds}s, 진단 ${actual.length}건, 빠진 줄 ${run.missing.length}, 남는 줄 ${run.unexpected.length}');
  for (final l in run.missing) {
    stdout.writeln('    - $l');
  }
  for (final l in run.unexpected) {
    stdout.writeln('    + $l');
  }
```
**차이와 권고:** 008 의 `analyze` 는 두 목록을 인덱스로 통째 비교해 `ok` 만 낸다 (225–226행). D-13 의 화면("정답지에는 있는데 나오지 않은 경고" / "정답지에 없는데 나온 경고")에는 006 의 `missing` / `unexpected` 가 그대로 맞는다 → **006 꼴을 쓴다.** 제목은 D-13 미리보기의 한국어 문구로 바꾸고, `--update` 때 같은 두 목록을 "줄 단위 변화" 로 보여 준 뒤 덮어쓴다 (D-14).

출력은 전부 `stdout.writeln` / `stderr.writeln` — 루트 옵션 파일에 `include: package:flutter_lints/flutter.yaml` 을 넣으면 `print` 가 `avoid_print` 에 걸린다 (RESEARCH 권고 10). spike 세 파일 모두 이미 그 형태다.

#### `pub get` 실행

**Analog:** `.planning/spikes/006-github-runner-cold-plugin/ci_probe.dart` 169–183행
```dart
/// [fixtureDir] 에서 `dart pub get` 을 돌리고 걸린 시간을 돌려준다. 실패하면 프로그램을 끝낸다.
Future<Duration> runPubGet(String fixtureDir) async {
  final watch = Stopwatch()..start();
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['pub', 'get'],
    workingDirectory: fixtureDir,
  );
  watch.stop();
  if (result.exitCode != 0) {
    stderr.writeln('pub get 실패 ($fixtureDir): exit ${result.exitCode}\n${result.stderr}');
    exit(69);
  }
  return watch.elapsed;
}
```
**차이와 권고:** verify.dart 는 두 번 부른다 — 루트(인자 `['pub', 'get']`, 규칙 검사의 include 해석용) 와 `example/`(인자 `['pub', 'get', '--enforce-lockfile']`). `example/` 쪽이 **65** 로 끝나면 spike 처럼 바로 `exit(69)` 하지 말고 "`example/pubspec.yaml` 을 바꿨으면 `cd example && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요" 를 먼저 적는다 (RESEARCH 권고 8). 그 뒤 종료 코드는 69 (RESEARCH 종료 코드 규약). 준비 단계라 "검증을 시작하지 않고" 끝내는 것은 spike 와 같다.

#### 규칙 검사 (단계 2)

**Analog:** `.planning/spikes/007-root-analysis-with-example/probe.dart` 25행, 133–139행, 217–229행, 244–262행
```dart
/// 규칙 검사용 복사본을 두는 자리 (replica 루트 기준, spike 005 와 같다).
const ruleCheckDir = 'build/woody_rule_check';
```
```dart
/// 옵션 파일 내용에서 최상위 `plugins:` 섹션을 뺀다 (spike 005 의 python3 패턴을 Dart 로 옮긴 것).
String stripPlugins(String options) {
  final stripped =
      options.replaceAll(RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true), '');
  if (stripped == options) throw const FormatException('plugins: 섹션을 찾지 못했다');
  return stripped;
}
```
```dart
  /// 규칙 검사용 복사본(`plugins:` 를 뺀 배포 파일)을 쓴다.
  void writeRuleCopy({required bool withProblems}) {
    final shipped = File('$repoRoot/lib/analysis_options.yaml').readAsStringSync();
    final body = stripPlugins(withProblems ? injectProblemRules(shipped) : shipped);
    Directory('$replica/$ruleCheckDir').createSync(recursive: true);
    File('$replica/$ruleCheckDir/analysis_options.yaml').writeAsStringSync(body);
  }

  /// 규칙 검사용 복사본을 지운다.
  void removeRuleCopy() {
    final build = Directory('$replica/build');
    if (build.existsSync()) build.deleteSync(recursive: true);
  }
```
```dart
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['--suppress-analytics', 'analyze', '--format=json', ...arguments],
      workingDirectory: cwd,
      environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path},
    );
```
**지킬 것:** `injectProblemRules` 는 spike 전용(문제 규칙을 끼워 넣는 실험)이라 옮기지 않는다. `writeRuleCopy(withProblems: false)` 꼴만 쓴다. 실행은 **저장소 루트**를 `workingDirectory` 로, `arguments: [ruleCheckDir]`. 실패 코드는 `deprecated_lint` / `removed_lint` / `undefined_lint`; `include_file_not_found` 가 보이면 "루트 `pub get` 누락이라 검사를 못 했다" 로 **따로** 알린다 (RESEARCH Pitfall 2). 삭제는 `try { … } finally { removeRuleCopy(); }` (spike CONVENTIONS 35행). 복사본은 `plugins:` 를 뺐으므로 상태 폴더를 줄 필요는 없지만, 주면 해롭지 않다 (007 이 그렇게 돌렸다).

**`stripPlugins` 의 전제:** `lib/analysis_options.yaml` 57–58행의 `plugins:` 블록이 규칙 목록 **뒤**에 있고 들여쓴 줄만 이어진다. 못 찾으면 `FormatException` → 단계 2 실패 (plugins 를 담은 채 돌리면 plugin 준비 11초 + 네트워크).

#### plugin 버전 읽기 (D-07)

**Analog:** `.planning/spikes/008-state-folder-placement/state_probe.dart` 238–258행
```dart
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
**차이와 권고:** 006 의 `readResolvedPluginVersions` (186–203행) 는 `~/.dartServer` 의 모든 폴더를 훑어 **집합**을 돌려준다. 008 은 전용 상태 폴더에서 폴더 하나의 버전을 읽는다. RESEARCH 권고 6 은 008 을 따르되 "폴더 수 1 이면 읽고, 0 / 2 이상 / lock 없음이면 `?` + 이유 한 줄" 을 요구한다 → **008 꼴 + 폴더 수 분기.** 같은 파서에 패키지 이름을 인자로 받게 일반화하면 `example/pubspec.lock` 의 `flutter_lints` / `lints` 도 읽는다 (RESEARCH 권고 10 "D-07 의 세 줄"). 버전 읽기는 분석이 **끝난 뒤**에 한다.

#### SDK 확인 (D-12)

**Analog:** 없음 (spike 에 없다). `02-RESEARCH.md` § Code Examples 5 의 `readFlutterVersion()` 을 쓴다 — `Platform.resolvedExecutable` 의 `parent` 5번 → `bin/cache/flutter.version.json` 의 `frameworkVersion` 을 `.fvmrc` 의 `flutter` 와 비교. 파일이 없으면 exit 78 + `fvm dart run tool/verify.dart` 안내. runner 의 설치본 배치는 RESEARCH A1 의 가정이므로 첫 CI 실행에서 확인한다.

#### `--update` 의 CI 거부 (D-14)

**Analog:** `.planning/spikes/006-github-runner-cold-plugin/ci_probe.dart` 206–213행
```dart
  final env = Platform.environment;
  final onGitHub = env['GITHUB_ACTIONS'] == 'true';
  final stateBase = args.isNotEmpty ? Directory(args[0]) : null;
  if (stateBase == null && !onGitHub) {
    stderr.writeln('로컬에서는 상태 폴더를 꼭 준다 (기본 자리 ~/.dartServer 를 쓰지 않으려고).');
    stderr.writeln('사용법: fvm dart run ci_probe.dart <상태 폴더>');
    exit(64);
  }
```
**바꿀 것:** 조건을 뒤집는다 — `--update` 이고 `env['CI'] == 'true' || env['GITHUB_ACTIONS'] == 'true'` 면 exit 64. 모르는 플래그도 64 (008 의 716–720행 "모르는 부" 처리와 같은 꼴).

#### main() 의 뼈대, 예외 처리, 종료 코드

**Analog:** `.planning/spikes/008-state-folder-placement/state_probe.dart` 709–784행, 특히 775–784행
```dart
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    exitCode = 65;
  } on FileSystemException catch (e) {
    stderr.writeln('파일 작업 실패: ${e.message} (${probe.scrub(e.path ?? '')})');
    exitCode = 74;
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: ${probe.scrub('$e')}');
    exitCode = 70;
  }
```
**차이와 권고:** spike 는 sysexits 전부(64/65/66/69/70/73/74)를 쓴다. RESEARCH 종료 코드 규약은 **0 / 1 / 64 / 69 / 78** 만 정했다 (1 = 단계 실패, CI 가 보는 값). 예외 처리 구조(세 `on` 절, `exitCode =` 대입)는 그대로 가져오되, 예외로 끝나는 경우도 CI 입장에서는 "실패" 이므로 계획은 65/70/74 를 유지할지 1 로 합칠지 정한다 — 어느 쪽이든 0 은 "단계 4개 모두 통과" 에만 쓴다. 또 spike 는 helper 안에서 `exit()` 를 바로 부르지만(006 `runPubGet`, 008 `makeFixture`), verify.dart 는 단계 1~4 를 **모두 돌린 뒤 요약**해야 하므로(D-13 의 "점검 실패 (N개 중 M개)") 단계 함수는 결과를 **돌려주고** `main` 이 모아 종료 코드를 정한다. `exit()` 즉시 종료는 준비 단계(SDK 불일치 / CI 의 `--update` / `pub get` 실패)에만 쓴다.

**Docstring:** 공개 클래스·함수마다 `///` 한 줄 (글로벌 CLAUDE.md), 함수명은 동사로 시작 (`readPluginVersion`, `stripPlugins`, `normalizeDiagnostics`). spike 세 파일이 전부 이 형식이다.

---

### `.github/workflows/verify.yml` (config, CI)

**Analog:** `.planning/spikes/006-github-runner-cold-plugin/spike-006-cold-plugin.yml` (전문 51줄)

**주석·권한·concurrency 꼴 (1–19행):**
```yaml
# spike 006 전용 — GitHub Linux runner 의 cold 실행에서 analyzer plugin 진단이
# 빠짐없이 나오는지와 걸리는 시간을 잰다 (.planning/spikes/006-github-runner-cold-plugin/).
#
# Phase 2 의 실제 CI 가 아니다. spike 결과를 기록한 뒤 이 파일은 지운다.
name: spike-006-cold-plugin

on:
  push:
    branches:
      - 'gsd/v2.0-package-rework'

# 저장소를 읽기만 한다.
permissions:
  contents: read

# 같은 브랜치에 새로 올리면 앞선 실행은 취소한다.
concurrency:
  group: spike-006-${{ github.ref }}
  cancel-in-progress: true
```

**job / SDK 설치 꼴 (21–41행, 49–50행):**
```yaml
jobs:
  cold:
    name: cold sample ${{ matrix.sample }}
    runs-on: ubuntu-latest
    timeout-minutes: 15
    …
    steps:
      - uses: actions/checkout@v7

      # .fvmrc 를 읽어 로컬과 같은 Flutter 를 설치한다. cold 를 재려고 캐시는 켜지 않는다.
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc
      …
      - name: cold 실행 점검
        run: dart run .planning/spikes/006-github-runner-cold-plugin/ci_probe.dart
```

**차이와 권고 (RESEARCH 권고 9 의 초안이 최종 형태):**

| 항목 | spike 006 | RESEARCH 권고 9 | 따를 것 |
|---|---|---|---|
| `on` | `push` + `branches` 필터 | `push:` / `pull_request:` / `workflow_dispatch:` 필터 없음 | RESEARCH (D-06, D-10) |
| `concurrency.group` | `spike-006-${{ github.ref }}` | `${{ github.workflow }}-${{ github.ref }}` | RESEARCH (문서 예시 그대로) |
| `timeout-minutes` | 15 | 10 | RESEARCH (job 약 2분의 5배) |
| `strategy.matrix`, `env.SPIKE_SAMPLE`, "설치된 SDK 버전" step | 있음 | 없음 | RESEARCH — 스크립트가 버전을 찍는다 (D-07) |
| `run` | spike 스크립트 경로 | `dart run tool/verify.dart` | RESEARCH |
| 캐시 | 없음 | 없음 (`cache` 기본 `false`) | 같음. `~/.dartServer` 는 어떤 경우에도 캐시하지 않는다 |

유지하는 것: 파일 머리 한국어 주석(무엇을 돌리는지, 판정 로직은 스크립트에 있음), `permissions: contents: read`, 각 설정 **위**의 "왜" 주석, action 은 major tag (`v7`, `v2`; SHA 고정은 선택 — RESEARCH 에 오늘 값이 있다). 별도 `pub get` step 을 두지 않는다 (스크립트 안에서 2회).

---

### `analysis_options.yaml` (root, modify)

**Analog:** 자기 자신 (전문 9줄) + `.planning/spikes/007-root-analysis-with-example/probe.dart` 207–215행

**현재 전문:**
```yaml
# 이 저장소 자체를 분석할 때만 쓰는 설정 (사용하는 프로젝트에는 전달되지 않는다 —
# 프로젝트는 lib/analysis_options.yaml 을 include 한다).
#
# lib/analysis_options.yaml 은 배포용 공유 설정이라 최상위 `plugins:` 를 담는다.
# 이 저장소 안에서는 그 파일이 하위(inner) 옵션 파일로 취급되어
# `plugins_in_inner_options` 경고가 나므로 자체 분석에서만 제외한다.
analyzer:
  exclude:
    - lib/analysis_options.yaml
```

**007 이 실측에 쓴 추가 방식 (210–214행):** 원본 끝이 `    - lib/analysis_options.yaml\n` 임을 확인한 뒤 `    - 'example/**'\n` 을 덧붙였다.
```dart
    if (!original.endsWith('    - lib/analysis_options.yaml\n')) {
      throw const FormatException('루트 옵션 파일의 끝이 예상한 exclude 항목이 아니다');
    }
    File('$replica/analysis_options.yaml')
        .writeAsStringSync(original + globs.map((g) => "    - '$g'\n").join());
```

**바꿀 것 (RESEARCH § Code Examples 7 의 전문을 쓴다):** (1) `include: package:flutter_lints/flutter.yaml` 을 더하고 그 위에 "tool/ 의 스크립트에 기반 세트 규칙을 적용한다. lib/analysis_options.yaml 을 include 하면 plugins: 가 루트로 들어와 … 쓰지 않는다" 주석, (2) `exclude` 에 `- 'example/**'` 한 줄과 "example/ 은 일부러 규칙을 어긴 검증용 프로젝트라 루트 분석에서 뺀다" 주석. 기존 `lib/analysis_options.yaml` 줄과 그 주석은 그대로 (Phase 3 PRESET-06 의 일). glob 은 따옴표로 감싼다 (`lib/analysis_options.yaml` 46–47행과 같은 꼴). `example/` 과 **같은 커밋**에 넣는다 (RESEARCH Pitfall 6).

---

### `.gitignore` (modify)

**Analog:** 자기 자신 5–7행
```gitignore
# Avoid committing pubspec.lock for library packages; see
# https://dart.dev/guides/libraries/private-files#pubspeclock.
pubspec.lock
```
**바꿀 것:** `pubspec.lock` 바로 아래에 `!example/pubspec.lock` 과 그 이유 주석(한국어 — "example/ 은 앱이라 lock 을 커밋한다. 로컬과 CI 가 같은 버전으로 판정한다 (D-05)"), 그리고 `build/` 와 이유 주석("tool/verify.dart 의 규칙 검사 복사본 자리. finally 로 지우지만 남아도 커밋되지 않게"). 기존 영어 템플릿 주석은 그대로 둔다 (CLAUDE.md Comments 관례). 부정 패턴이 루트 `pubspec.lock` 을 풀지 않는 것은 RESEARCH 권고 8 에서 확인됐다.

---

### `CHANGELOG.md` (modify)

**Analog:** 자기 자신 1–11행 (2.0.0 항목의 현재 꼴) + 19행 (선례 문구) + `VERSIONING.md` § "CHANGELOG 항목 형식"

**현재 2.0.0 항목 (1–11행):**
```markdown
## 2.0.0 - 미출시

지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)

### 올리기 전에

- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.

### 새로 생기는 경고

(Phase 4 실측 후 채움)
```

**VERSIONING.md 의 칸 순서:** `지원 SDK:` → `### 올리기 전에` → `### 추가한 규칙` → `### 뺀 규칙` → `### 그 밖의 변경` → `### 새로 생기는 경고`. 해당하는 칸만 둔다. 제목의 ` - ` 는 한 번만.

**바꿀 것 (RESEARCH 권고 11, 선택):** `### 올리기 전에` 와 `### 새로 생기는 경고` **사이**에 `### 그 밖의 변경` 을 만들고 한 줄 — "저장소 안에 검증용 `example/` 프로젝트, 검증 명령 `tool/verify.dart`, GitHub Actions workflow 를 추가. 사용하는 프로젝트에는 영향 없음." 19행의 1.3.0 문구("… 추가 — 이유. 사용하는 프로젝트에는 영향 없음.")와 같은 꼴이다. 버전은 올리지 않는다.

## Shared Patterns

### 하위 `dart` 호출
**Source:** `.planning/spikes/006-github-runner-cold-plugin/ci_probe.dart` 132–139행, 172–176행 (spike 001~008 공통)
**Apply to:** `tool/verify.dart` 의 모든 `Process.run`
```dart
  final result = await Process.run(
    Platform.resolvedExecutable,
    [...globalArguments, 'analyze', '--format=json'],
    workingDirectory: fixtureDir,
    environment: {
      if (stateDir != null) 'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir,
    },
  );
```
`Platform.resolvedExecutable` 이면 `fvm dart run` 으로 띄운 그 SDK 가 쓰인다. 인자는 배열로 넘긴다 (셸 문자열 금지 — RESEARCH V5). `--suppress-analytics` 는 항상 붙인다.

### 종료 코드 · stdout · stderr 를 따로 보고 판정
**Source:** `.planning/spikes/008-state-folder-placement/state_probe.dart` 47–103행 (`Outcome`: `exitCode`, `jsonOk`, `lines`, `stderrText`, `hasPluginHeader`)
**Apply to:** 단계 2 (규칙 검사) 와 단계 4 (정답지 비교). 하나만 보고 판정하지 않는다 (spike CONVENTIONS 36행). 결과 객체에 `toJson()` 을 두는 것은 spike 의 결과 파일용이라 verify.dart 에는 필요 없다.

### 한국어 "왜" 주석을 설정 위에
**Source:** `pubspec.yaml` 13–15행, `analysis_options.yaml` 1–6행, `lib/analysis_options.yaml` 49–56행
**Apply to:** `example/pubspec.yaml`, 루트 `analysis_options.yaml`, `.gitignore`, `.github/workflows/verify.yml`
```yaml
# lib/analysis_options.yaml 이 `include: package:flutter_lints/flutter.yaml` 을
# 쓰므로 사용하는 프로젝트에 전달되는 dependencies 에 둔다
# (dev_dependencies 는 사용하는 쪽 의존성 그래프에 포함되지 않는다).
dependencies:
  flutter_lints: ^6.0.0
```
영어 식별자 뒤 조사는 한 칸 띄운다 (`riverpod_lint 를`). 실측 사실에는 버전과 날짜를 함께 (`lib/analysis_options.yaml` 55–56행: "Flutter 3.47.5 의 `flutter analyze` 는 plugin 진단을 표시하지 않았다 (3.41.9 는 표시, 2026-09-20 실측)").

### 화면 문구와 안내
**Source:** `.planning/spikes/006-github-runner-cold-plugin/ci_probe.dart` 155–165행, 303–306행; D-13 미리보기 (02-CONTEXT.md `<specifics>`)
**Apply to:** `tool/verify.dart` 의 모든 출력. `통과` / `실패`, 빠진 줄 `- `, 남는 줄 `+ `, 규칙 이름·명령은 영어 그대로, "다음에 할 일" 은 단계별로 다르게 (RESEARCH 권고 10 "화면").

### 임시 산출물은 같은 자리에서 되돌린다
**Source:** `.planning/spikes/007-root-analysis-with-example/probe.dart` 226–229행 (`removeRuleCopy`), spike CONVENTIONS 35행
**Apply to:** `build/woody_rule_check/` (단계 2, `finally`). 전용 상태 폴더 `.dart_tool/woody_verify/` 는 **지우지 않는다** (warm 재실행 3.6초 vs cold 15초).

### 기록 파일에 로컬 절대 경로를 남기지 않는다
**Source:** `.planning/spikes/008-state-folder-placement/state_probe.dart` 171–177행 (`scrub`), spike CONVENTIONS 43행
**Apply to:** `example/README.md` 의 기록 절, `example/expected_diagnostics.txt` (정규화가 상대 경로로 바꾼다). verify.dart 의 **화면 출력**은 로컬용이라 절대 경로를 보여 줘도 되지만, 파일에 쓰는 것은 상대 경로만.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `example/pubspec.lock` | config (생성물) | — | 손으로 쓰지 않는다. `cd example && fvm dart pub get` 이 만들고 D-05 로 커밋한다. spike fixture 의 lock 은 gitignore 대상이라 추적 analog 가 없다 |
| `tool/verify.dart` 의 D-12 SDK 확인 부분 | script 조각 | file-I/O | spike 에 없다. RESEARCH § Code Examples 5 (`readFlutterVersion`, 스크래치 probe 로 실측) 를 쓴다 |
| `tool/verify.dart` 의 `--update` 갱신 부분 | script 조각 | file-I/O | spike 는 정답지를 읽기만 했다. `Expected.read` 에 머리 주석 보존을 더하고, 006 의 `missing` / `unexpected` 를 "줄 단위 변화" 로 보여 준 뒤 덮어쓴다 (D-14) |

## Metadata

**Analog search scope:** 추적 파일 전부 (`git ls-files`, `.planning/` 제외 10개), `.planning/spikes/001~008` 의 스크립트·fixture·workflow·expected 파일, `.planning/spikes/CONVENTIONS.md`, `.claude/skills/spike-findings-woody-lints/SKILL.md` (references 는 색인만 확인)
**Files scanned:** 읽은 파일 16 (RESEARCH / CONTEXT 포함), 목록으로 확인한 파일 약 180
**Tracked-source gate:** 이름을 댄 spike analog 7개는 `git ls-files` 로 추적 확인 (`.claude/skills/.../sources/` 사본은 가리키지 않았다)
**Pattern extraction date:** 2026-10-11
