# Phase 4: Rule Reselection - Pattern Map

**Mapped:** 2026-10-13
**Files analyzed:** 14 (새 파일 4 · 고치는 파일 10)
**Analogs found:** 12 / 14 (exact 5 · role-match 7 · 없음 2)

이 저장소에는 실행 코드가 `tool/verify.dart` 하나뿐이다. 그래서 analog 는 두 갈래다 — (1) 저장소의 추적 소스(`tool/verify.dart`, `lib/base.yaml`, `example/lib/*.dart`, `example/README.md`, `CHANGELOG.md`), (2) 프로젝트 skill 에 **읽기용 사본**으로 추적되어 있는 spike 020 ~ 023 의 소스(`.claude/skills/spike-findings-woody-lints/sources/…`). (2) 는 제품 코드가 아니라 "들어 올리는(lift from)" analog 다 — 그대로 import 하지 않고 `tool/measure_rules.dart` 한 파일로 옮기며, 옮길 때 바꿔야 하는 자리를 각 항목에 적었다. 모든 analog 경로는 `git ls-files` 로 추적을 확인했다 (2026-10-13).

경로는 모두 저장소 루트 기준이다. 사용 프로젝트(`flutter_starter_kit`)의 경로 · 메시지 · 코드 조각은 이 문서에 넣지 않았다 (04-CONTEXT.md D-07).

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `tool/measure_rules.dart` (새) | utility (CLI 측정 도구) | batch (프로세스 실행 → JSON 집계 → 파일 I/O) | `.claude/skills/spike-findings-woody-lints/sources/021-new-rules-language-gate/consumer.dart` (핵심 클래스) + `sources/022-dart-fix-dry-run-count/repo_guard.dart` (단계 지문) + `sources/022-…/probe.dart` (apply 고리) + `sources/023-existing-ignore-comments/probe.dart` (`stripIgnores`) + `sources/020-rule-state-vs-rules-json/probe.dart` (상태 · 상류 세트) ; CLI 껍데기 · 종료 코드 · 한국어 메시지는 `tool/verify.dart` | exact (lift from) |
| `tool/measurements/<YYYY-MM-DD>-<id>.json` (새, 데이터) | config/data (회차 기록) | file-I/O (도구가 쓰고 `--report` · `--summary` 가 읽음) | `consumer.dart:98-111` (`Shot.toJson` — 경로 · 메시지 없는 모양) | exact |
| `tool/verify.dart` — 새 단계 `[3/N]` `checkShippedComposition`, `declaredRuleNames`, `significantLines`, 상류 YAML 읽기, `RULES.md` 읽기 | utility (검증 단계) | transform (파일 읽기 → 비교 → `StepResult`) | 같은 파일의 `checkFixtureOptions` (1058-1100), `checkLibYamlSet` (800-830), `countDeclaredRules` (848-863), `sameLines` (1121-1127), `subtractLines` (646-660); 상류 세트 읽기는 020 `readUpstreamSets` (448-474) | exact |
| `RULES.md` (새) | 문서 (근거 · 미채택 · 실측 기록; `verify.dart` 가 마커 구역을 읽음) | file-I/O (사람이 쓰는 표 2 + 도구가 생성하는 절 1) | 표 형식: `example/README.md` 의 M 표(120-131); 마커 규약: 저장소에 선례 없음 (04-RESEARCH.md § 3 의 설계를 따른다) | role-match |
| `lib/base.yaml` (삭제 9줄 → 묶음별 추가) | config (배포 조각) | — (선언) | 자기 자신 — `lib/base.yaml:20-40` 의 목록 형식 + 분류 주석 + 한 줄 사유 주석 | exact |
| `example/lib/<묶음>_rules.dart` (새, 묶음마다) | fixture 샘플 (위반 코드) | — (정적 샘플) | `example/lib/added_rules.dart` (1-34) | exact |
| `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/lib/<묶음>_rules.dart` (새 복사본) | fixture 샘플 | — | `example/lib/added_rules.dart` 와 글자 그대로 같은 다섯 복사본 (지금 `diff -rq example/lib fixtures/*/lib` 차이 없음) | exact |
| `example/lib/base_rules.dart` (머리 주석 3-4행만) | fixture 샘플 | — | 자기 자신 `example/lib/base_rules.dart:3-4` (코드 · 줄 번호 불변) | exact |
| `example/expected_diagnostics.txt`, `fixtures/*/expected_diagnostics.txt` (갱신) | config/data (정답지) | file-I/O (`--update` 가 씀) | `tool/verify.dart` `writeExpected` (703) 가 쓰는 형식 — 손으로 고치지 않는다 | exact |
| `example/README.md` (단계 수 9 → 10, `[n/9]` 표기, M20 ~ M25 기록) | 문서 | — | 같은 파일의 "추가 실측 — …" 소절 셋 (167 · 191 · 213행) 과 M 표 (120-131) | exact |
| `CHANGELOG.md` `## 2.0.0 - 미출시` (칸 셋 채움) | 문서 | — | `VERSIONING.md` § "CHANGELOG 항목 형식" (77-127) 의 예시 블록, 지금 2.0.0 항목의 불릿 문체 (`CHANGELOG.md:10-16`) | exact |
| `.planning/ROADMAP.md` (D-23 세 군데) | planning 문서 | — | Phase 3 의 "Spike first … 완료" 문구 선례 (ROADMAP Phase 3, 04-RESEARCH.md § 7 이 인용) | role-match |
| `.planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md` (WR-01 ~ 03 행) | planning 데이터 (YAML frontmatter) | — | 같은 파일의 `findings[]` 항목 (`id` / `severity` / `disposition` / `title`) | exact |
| 규칙별 표식 `lib/woody_probe_marker/rule_probe/<규칙>.dart` (복사본 안에만, 커밋 안 함) | fixture 샘플 (측정용) | — | 023 `probe.dart:28-` 의 `markers` 맵 (`addMarkers` 에 넘기는 `{상대경로: 소스}`), 021 `probe.dart` 의 `oldSamples` · `newSyntaxSamples` | role-match |

## Pattern Assignments

### `tool/measure_rules.dart` (utility, batch)

#### 1) CLI 껍데기 · 저장소 루트 · 종료 코드 · 예외 — analog `tool/verify.dart`

**머리 주석 관례** (`tool/verify.dart:1-25`): 첫 줄에 "무엇을 하는 명령인가", 단계 목록, `실행:` 줄, 종료 코드 표를 **한국어 주석**으로. 새 도구도 같은 머리를 둔다 (단계 `state | baseline | groups | markers | ignore | fix | unnecessary-ignore`, `--source` · `--work` 필수, 종료 코드 `0 / 1 판정 실패 / 64 사용법 / 69 하위 명령 / 70 예외`).

**import** (`tool/verify.dart:26-27`) — 둘뿐이다. 새 도구도 패키지 의존성 없이 이 둘만 쓴다.
```dart
import 'dart:convert';
import 'dart:io';
```

**인자 거부와 사용법** (`tool/verify.dart:1426-1433`):
```dart
Future<void> main(List<String> args) async {
  final unknown = args.where((a) => a != '--update').toList();
  if (unknown.isNotEmpty) {
    stderr.writeln('모르는 인자: ${unknown.join(' ')}');
    stderr.writeln('사용법: $runCommand [--update]');
    await quit(64);
  }
  final update = args.contains('--update');
```
새 도구는 `--source` · `--work` 가 없을 때, `--work` 가 저장소 루트 아래일 때 같은 꼴로 `stderr.writeln` + `quit(64)`.

**저장소 루트 셈법** (`tool/verify.dart:1435-1436`) — spike 의 `Repo.fromSpikeDir` (세 단계 위) 를 **이것으로 바꾼다**:
```dart
  // tool/ 의 부모가 저장소 루트다. 어느 폴더에서 실행해도 같은 파일을 본다.
  final repoRoot = File.fromUri(Platform.script).parent.parent.path;
```

**flush 뒤 종료** (`tool/verify.dart:439-444`):
```dart
/// stdout 과 stderr 를 비운 뒤 [code] 로 끝낸다 (준비 단계에서만 쓴다).
Future<Never> quit(int code) async {
  await stdout.flush();
  await stderr.flush();
  exit(code);
}
```

**예외 → 종료 코드 70** (`tool/verify.dart:1533-1544`) — `main` 의 본문을 `try` 로 감싸고 세 예외를 한국어 한 줄로 바꾼다. `FileSystemException` 의 경로는 `relativize` 로 가린다 (새 도구에서는 `Consumer.scrubText` 로 — 사용 프로젝트 경로가 섞일 수 있다):
```dart
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    exitCode = 70;
  } on FileSystemException catch (e) {
    stderr.writeln(
      '파일 작업 실패: ${e.message} (${relativize(e.path ?? '', repoRoot)})',
    );
    exitCode = 70;
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: $e');
    exitCode = 70;
  }
```

**SDK · Flutter 버전 읽기** (`tool/verify.dart:464-485` `readFlutterVersion` · `readVersionFile`) — 회차 기록의 `flutter` 필드에 그대로 옮긴다 (실행 파일에서 네 단계 위 → `bin/cache/flutter.version.json`, 없으면 `FLUTTER_ROOT`). 새 도구는 "저장소 밖에서 `<repo>/.fvm/flutter_sdk/bin/dart` 로 실행" 도 허용되므로 1순위 경로가 맞는다.

**진단 JSON 읽기의 심볼릭 링크 처리** (`tool/verify.dart:400-437` `normalizeDiagnostics`) — `bases` 를 **목록**으로 받아 준 경로와 푼 경로 둘 다를 떼어낸다. `Consumer.analyze` (consumer.dart:313-314) 는 `dir` 하나만 떼므로 작업 폴더가 링크를 거치면 `area` 가 전부 "그 밖" 이 된다 (04-RESEARCH.md Pitfall 7). 옮길 때 아래 고리를 쓴다:
```dart
      for (final base in bases) {
        if (file.startsWith('$base/')) {
          file = file.substring(base.length + 1);
          break;
        }
      }
```
`bases` = `[consumer.dir, Directory(consumer.dir).resolveSymbolicLinksSync()]`.

#### 2) 복사본 · 받은 자리 · 지문 · 분석 — analog `sources/021-new-rules-language-gate/consumer.dart` (전체 357행, lift)

옮길 클래스: `Repo` (17-47), `Diag` (50-68), `Shot` (71-112), `Consumer` (115-334), 함수 `replaceOnce` (337-341), `digest` (344-351), `expectedLines` (354-357). **한 파일에 넣는다** — `tool/` 에 import 할 다른 파일을 두지 않는다 (04-RESEARCH.md Code Examples 첫 주석).

**저장소 지문** (`consumer.dart:27-46`) — `git status --porcelain` + `.dart_tool/` 맨 위 이름 + 두 파일의 해시:
```dart
  Future<String> fingerprint() async {
    final status = await Process.run('git', ['status', '--porcelain'], workingDirectory: root);
    String fileDigest(String rel) {
      final f = File('$root/$rel');
      return f.existsSync() ? digest(f.readAsBytesSync()) : '-';
    }
    final tool = Directory('$root/.dart_tool');
    final top = tool.existsSync()
        ? (tool.listSync().map((e) => e.path.split('/').last).toList()..sort()).join(',')
        : '-';
    return ['${status.stdout}', top, fileDigest('.dart_tool/package_config.json'), fileDigest('pubspec.lock')].join('|');
  }
```
바꿀 것: `fromSpikeDir` (23-25) 를 지우고 `Repo(Directory(repoRoot).resolveSymbolicLinksSync())` 로 만든다.

**자리(area) 판정** (`consumer.dart:57-65`) — `marker` / `generated` / `lib` / `test` / `bin` / 파일 이름. 표식 폴더 상수 `Diag.markerDir = 'lib/woody_probe_marker/'` 는 그대로 (비공개 점검 (2) 의 허용 목록이 이 이름을 안다).

**결과에 경로 · 메시지를 남기지 않는 모양** (`consumer.dart:96-111`) — `tool/measurements/*.json` 의 `runs[]` 원소가 이 모양을 **확장**한다 (04-RESEARCH.md § 1 "회차 기록" 의 필드 `date` · `dart` · `flutter` · `baseSet` · `languageVersion` · `sdkConstraint` · `dartFiles` · `ignoresStripped` · `expectedCovered` · `markersReported` · `valid` 를 더한다):
```dart
  Map<String, Object> toJson() => {
        'id': id, 'exitCode': exitCode, 'elapsedMs': elapsedMs, 'jsonOk': jsonOk,
        'pluginHeader': pluginHeader, 'pluginFolders': pluginFolders, 'pluginVersion': pluginVersion,
        'woodySource': woodySource,
        'lines': {'all': diags.length, 'marker': marker.length, 'project': project.length},
        'countByAreaCode': countByAreaCode(),
        'projectDigest': digest(utf8.encode((project.map((d) => d.text).toList()..sort()).join('\n'))),
        'markerLines': (marker.map((d) => d.text).toList()..sort()),
      };
```
`markerLines` 만 전문이다 — 표식은 이 저장소의 샘플이라 경로가 공개돼도 된다. 프로젝트 줄은 해시 하나.

**복사 · 받은 자리 · 멈춤 조건** (`consumer.dart:135-154`, `196-236`): `copy()` 는 `pubspec.yaml` · `pubspec.lock` · `analysis_options.yaml` · `l10n.yaml` + `lib` · `test` · `bin` · `assets` 만 옮긴다. 151-153행의 "옛 주소 include 가 없으면 `FormatException`" 과 `pubspecWithSdk` (256-257) 의 `replaceOnce(originalPubspec, '\n  sdk: ^3.11.1\n', …)` 는 **그대로 둔다** — 사용 프로젝트가 바뀌면 조용히 엉뚱한 것을 재지 않고 멈추는 것이 맞다. `pointToRepo` (197-201) 가 `pubspec_overrides.yaml` 에 `path: ${repo.root}` 를 쓰고, `woodySource` (212-229) 가 `rootUri` 를 `file:` / 상대 둘 다 풀어 `repo` / `git` / `?` 를 돌려준다. `ensureRepoSource` (232-236) 는 `analyze` 가 스스로 부르지 않는다 — **부르는 쪽이 매번 부른다**.

**옵션 파일 만들기** (`consumer.dart:242-253`) — 규칙은 맵 문법(`rule: true`)으로 원본 옵션의 `\n  rules:\n` 뒤에, `strict-inference` 는 `language:` 로 `\n\nanalyzer:\n` 뒤에 끼운다. G1 실행이 `optionsWith(rules: g1, language: {'strict-inference': true})` 다.

**분석 한 번** (`consumer.dart:286-323`): 실행마다 빈 상태 폴더 `ANALYZER_STATE_LOCATION_OVERRIDE`, stderr 의 plugin 머리말 검출, `.plugin_manager` 폴더 수 == 1 일 때만 `pubspec.lock` 에서 `riverpod_lint` 버전, 줄 전문은 `<work>/private/<id>.txt` 에만.

#### 3) 단계마다 지문 견주기 — analog `sources/022-dart-fix-dry-run-count/repo_guard.dart:19-27`

```dart
  var last = await repo.fingerprint();
  Future<void> step(String name, Future<void> Function() body) async {
    await body();
    final now = await repo.fingerprint();
    steps[name] = now == last;
    stdout.writeln('- $name: 저장소 ${now == last ? '그대로' : '**바뀜**'}');
    last = now;
  }
```
바꿀 것: 기록만 하던 것을 **그 자리에서 종료 코드 1** 로 (04-RESEARCH.md Code Examples `step` — 다르면 `stderr.writeln('$name: 저장소가 바뀌었다 — 이 실행을 쓰지 않는다'); exit(1);`), 단계 끝마다 `results.save()` 로 `<work>/results/<id>.json` 에 합쳐 쓴다. 저장소 안 `tool/measurements/` 에는 **마지막 지문 비교가 끝난 뒤** 한 번만 복사한다.

#### 4) 그룹 상수 · apply 고리 — analog `sources/022-dart-fix-dry-run-count/probe.dart`

**그룹 상수 모양** (`probe.dart:21-73`): `const groups = <String, List<String>>{'G1': […], 'G2': […], 'G3': […], 'G4': […]}` 에 그룹마다 한국어 주석으로 "왜 따로인가". 새 도구는 G1 에 7개를 더해 113개로 (04-RESEARCH.md § 2), 후보 상수의 총수(125 + 1 + 6 + 1 = 133)를 시작 때 단언한다. `maxApply` (76행) 는 **버린다**.

**`dart fix` 호출과 출력 읽기** (`probe.dart:297-319`):
```dart
  final r = await Process.run(
      Platform.resolvedExecutable,
      ['--suppress-analytics', 'fix', apply ? '--apply' : '--dry-run', if (code != null) '--code=$code'],
      workingDirectory: where,
      environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path});
  …
  File('${private.path}/$id.txt').writeAsStringSync('$out\n--- stderr\n${r.stderr}');
  …
    final m = RegExp(r'^  (\S+) - (\d+) fix(?:es)?$').firstMatch(line);
```
화면 원문은 `<work>/private/` 에만 (D-07).

**apply 한 회의 순서와 증감 셈** (`probe.dart:194-223`):
```dart
  for (final rule in applyRules) {
    final g = rows[rule]!['group'] as String;
    consumer.refreshSources();
    consumer.addExampleMarkers();
    await consumer.useSdk(g == 'G4' ? '^3.13.0' : null);
    consumer.setOptions(consumer.optionsWith(rules: groups[g]!));
    final before = shots.firstWhere((s) => s.id == '$g-analyze');
    final apply = await dryRun('apply-$rule', code: rule, apply: true);
    final after = await consumer.analyze('apply-$rule-analyze');
    consumer.ensureRepoSource(after);
    final remaining = after.diags.where((d) => d.code == rule).length;
    final delta = <String, int>{};
    for (final d in before.diags) { delta.update(d.code, (v) => v - 1, ifAbsent: () => -1); }
    for (final d in after.diags)  { delta.update(d.code, (v) => v + 1, ifAbsent: () => 1); }
    delta.removeWhere((k, v) => v == 0 || k == rule);
```
바꿀 것: `applyRules` 의 `take(maxApply + 1)` (185-189) 을 "단독 dry > 0 인 규칙 전부" 로; `delta` 에서 **error 등급만** 따로 세어 "고친 뒤 새로 생긴 error" 칸에 (info 증감은 `otherDelta`); 규칙별 표식(`rule_probe/`)도 `addExampleMarkers()` 뒤에 다시 넣는다; 끝에 `refreshSources()` → `useSdk(null)` → `setOptions(originalOptions)` (224-226) 로 되돌린다.

**회차 유효성 판정의 재료** (`probe.dart:229-241` K2 ~ K5) — 새 도구의 `validate(shot)` 는 이 넷을 한 `Run.valid` 로 합친다 (04-RESEARCH.md Code Examples `validate`): `woodySource == 'repo'`, 정답지 줄 ⊆ 표식 줄 (`expectedLines(...).map((l) => l.replaceFirst('lib/', Diag.markerDir))`), `pluginFolders == 1 && !pluginHeader`, 지문 불변. **멈추지 않고 그 회차만 무효로 표시**한다 (spike 는 전체가 멈췄다).

#### 5) 무시 주석 — analog `sources/023-existing-ignore-comments/probe.dart`

**정규식** (`probe.dart:26`): `final ignorePattern = RegExp(r'//\s*(ignore_for_file|ignore)\s*:\s*(.*)$');`

**분석 대상 파일 열거** (`probe.dart:264-276`) — `lib` · `test` · `bin` 의 `.dart`, 표식 폴더 제외, 생성 파일은 옵션. 회차 기록의 `dartFiles` (생성 파일 수 따로) 도 이 함수로 센다.

**`stripIgnores`** (`probe.dart:308-329`) — 주석 부분만 지우고 **줄은 남겨 줄 번호를 지킨다**, 생성 파일은 건드리지 않는다. 그대로 옮긴다:
```dart
      lines[i] = lines[i].substring(0, m.start).trimRight();
```
걷어낸 소스는 다음 단계 전에 `refreshSources()` 로 되돌린다. `unnecessaryIgnoreNames` (334-) 는 `--stage unnecessary-ignore` 에서 쓴다 — 메시지를 남기지 않으므로 진단 자리의 주석을 복사본에서 다시 읽어 코드 이름만 센다.

**표식 맵 모양** (`probe.dart:28-`): `const markers = {'ignore_probe/discarded_futures.dart': '''…''', …}` → `consumer.addMarkers(markers)`. 규칙별 표식은 키를 `rule_probe/<규칙>.dart` 로.

#### 6) 상태 · 상류 세트 · 비호환 쌍 — analog `sources/020-rule-state-vs-rules-json/probe.dart`

**`messages.yaml` 읽기** (`probe.dart:329-412`): `MessagesRule.latest` (336-345, 같은 버전이면 removed > deprecated > stable > experimental), `readMessagesYaml` (353-406, 들여쓰기 2/4/6 칸에 기대는 줄 단위 파서, `sharedName` 짝 검사), `snake` (410-412 — 숫자 앞 `_` 처리 포함), `compareVersion` (414-423). 그대로 옮긴다. 받지 못하면 020 의 결과 JSON 을 읽는 fallback 을 두고 회차 기록에 출처를 적는다 (04-RESEARCH.md Alternatives).

**상류 세트** (`probe.dart:427-474`):
```dart
  Set<String> rulesOf(String file) => File(file)
      .readAsLinesSync()
      .map((l) => RegExp(r'^    - (\w+)').firstMatch(l)?.group(1))
      .whereType<String>()
      .toSet();
  …
  sets.sources['lints'] = Uri.directory(lints).pathSegments.where((s) => s.isNotEmpty).last;
  sets.core.addAll(rulesOf('${lints}lib/core.yaml'));
  sets.recommended.addAll(rulesOf('${lints}lib/recommended.yaml'));
  sets.flutter.addAll(rulesOf('${flutterLints}lib/flutter.yaml'));
```
`UpstreamSets.of` (436-445) 는 **소문자로** 견준다 (`prefer_iterable_whereType`). 바꿀 것: `readUpstreamSets()` 가 전역 `repoRoot` 를 읽는 것을 `readUpstreamSets(String packageDir)` 로 — 저장소 루트와 복사본 **둘 다**에 쓴다; `rootUri` 가 `file:` 이 아니면 `.dart_tool/` 기준 상대 경로로 (consumer.dart:223-225 의 처리). 이 함수는 `tool/verify.dart` 의 (b) 검사에도 **같은 코드**로 들어간다 — 두 파일이 서로 import 하지 않으므로 복사해 두되 주석에 "measure_rules.dart 와 같다" 를 적는다.

**규칙만 적은 패키지를 만들어 분석** (`probe.dart:515-560` `analyzeAll`): `<work>/<label>/` 에 `pubspec.yaml` (`sdk: $constraint`) + `lib/a.dart` + 규칙 목록 옵션 파일 → `pub get` (실패 시 exit 69) → 빈 상태 폴더로 `analyze --format=json` → 옵션 파일 줄의 진단만 모아 `line - 3` 을 규칙 index 로. 쌍마다 둘만 켠 비호환 확인은 같은 함수에 규칙 둘을 넣는다 (`probe.dart:199`). `message` 는 옵션 파일 진단이라 비공개가 아니지만 결과 JSON 에는 코드만 남긴다.

---

### `tool/verify.dart` — 새 단계 `[3/N]` "배포 파일의 구성" (utility, transform)

**Analog:** 같은 파일 — `checkFixtureOptions` (1058-1100) 의 "파일별 `details` 모으기 → 한 `StepResult`", `checkLibYamlSet` (800-830) 의 실패 문구 모양.

**단계 결과 타입** (`tool/verify.dart:329-350`): `StepResult({required label, required passed, detailLines = const [], …})`. 새 단계는 `label` · `passed` · `detailLines` 만 쓴다 (plugin · update 필드는 정답지 단계용).

**세 확인을 한 단계로 모으는 틀** (`tool/verify.dart:1061-1099`):
```dart
  final details = <String>[];
  for (final fixture in fixtures) {
    …
    if (rest != null && sameLines(rest.map((l) => l.trim()).toList(), expected)) {
      continue;
    }
    if (details.isNotEmpty) details.add('');
    details.addAll([
      if (rest == null)
        '`$optionsPath` 이 없다.'
      else ...[
        '`$optionsPath` 이 정해진 내용이 아니다 — 주석·빈 줄을 뺀 내용 (${rest.length}줄):',
        if (rest.isEmpty) '  (없음)' else ...rest.map((l) => '  $l'),
      ],
      '  정해진 내용:',
      ...expected.map((l) => '    $l'),
      '',
      '`flutter pub get` 을 돌렸다면: git checkout -- $optionsPath',
    ]);
  }
  return StepResult(label: fixtureOptionsLabel, passed: details.isEmpty, detailLines: details);
```
(a) include-만 확인은 1070-1078행의 "주석 · 빈 줄 뺀 `trimRight` 줄 → `trim` 비교" 를 `List<String>? significantLines(File)` 로 떼어 `includeOnlyFiles` 상수(04-RESEARCH.md § 4) 와 견준다. 실패 문구는 위와 같은 "실제 줄 / 정해진 내용" 꼴 (M19 의 모양).

**실패 문구의 "더 있는 것 / 없는 것" 모양** (`tool/verify.dart:812-829`) — (c) `RULES.md` ↔ `base.yaml` 의 한쪽에만 있는 이름을 적을 때 이 모양을 따르되 기호는 정답지 diff 와 같은 `+ ` / `- `:
```dart
    detailLines: [
      '`lib/` 의 YAML 이 정해진 다섯과 다르다.',
      if (extra.isNotEmpty) ...[
        '더 있는 것 (${extra.length})',
        ...extra.map((n) => '  lib/$n'),
      ],
      …
      '',
      '새 조각을 더했으면 tool/verify.dart 의 ruleCheckTargets 와 expectedLibYamls 에 함께 적는다. '
          '지웠으면 두 상수에서 뺀다.',
    ],
```
마지막 줄처럼 **"다음에 할 일"** 을 한 줄 더한다 — (b) 는 "기반 세트가 이미 켜므로 지운다", (c) 는 "`RULES.md` 의 켠 규칙 표와 `lib/base.yaml` 을 같은 커밋에서 고친다".

**규칙 이름 읽기 → 목록으로 바꾸기** (`tool/verify.dart:848-863`):
```dart
int countDeclaredRules(String options) {
  final rulePattern = RegExp(r'^\s*-\s*[A-Za-z0-9_]+');
  var inLinter = false;
  var count = 0;
  for (final line in options.split('\n')) {
    if (RegExp(r'^linter:').hasMatch(line)) {
      inLinter = true;
    } else if (RegExp(r'^\S').hasMatch(line)) {
      inLinter = false;
    } else if (inLinter && rulePattern.hasMatch(line)) {
      count++;
    }
  }
  return count;
}
```
`List<String> declaredRuleNames(String options)` 로 바꾸고 정규식을 `readRuleNameAt` (838행) 의 그룹 있는 꼴 `^\s*-\s*([A-Za-z0-9_]+)` 로. `countDeclaredRules` 는 `declaredRuleNames(options).length` 로 남긴다 (기존 호출 자리 불변).

**목록 비교 · 차집합** (`tool/verify.dart:1121-1127` `sameLines`, `646-660` `subtractLines`) — (c) 는 두 목록을 **정렬한 뒤** `sameLines`, 차이는 `subtractLines(a, b)` / `subtractLines(b, a)` 로 (중복 이름도 잡힌다).

**`main` 의 단계 목록에 끼우는 자리** (`tool/verify.dart:1465-1469`):
```dart
    final results = <StepResult>[
      checkLibHasNoDart(repoRoot),
      await checkRuleNames(repoRoot),
      checkFixtureOptions(repoRoot, fixtures),
    ];
```
`checkRuleNames` 와 `checkFixtureOptions` 사이에 `checkShippedComposition(repoRoot)` 한 줄. 번호 `[n/N]` 은 `formatStepLine` (1361-1366) 이 `results.length` 로 자동으로 매긴다 — 머리 주석 1-8행과 `example/README.md` 의 `[n/9]` 표기 · "단계 9개" 만 손으로 고친다. 상류 YAML 은 준비 3 (`runPubGet(repoRoot …)`, 1451행) 뒤라 루트 `package_config.json` 이 있다.

**상류 YAML 읽기** — 020 `readUpstreamSets` (위 6) 을 옮긴다. `RULES.md` 읽기는 새로 쓴다: `<!-- woody:enabled-rules:start -->` … `end` 사이의 `|` 로 시작하는 줄에서 첫 칸의 backtick 하나로 감싼 `[a-z0-9_]+` (04-RESEARCH.md § 3). 파일이 없으면 (c) 실패 문구 "`RULES.md` 가 없다 — D-08".

---

### `RULES.md` (문서, 마커 구역)

**Analog (표 형식):** `example/README.md:120-131` 의 M 표 — 헤더 `| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |`, 셀 안의 규칙 · 경로는 backtick, 요구사항 ID (`VERIFY-08`, `D-03`) 를 마지막 칸에. 켠 규칙 표 `| 규칙 | 분류 | 켠 이유 | 실측 (lib · test · bin) | dart fix | 회차 |`, 켜지 않은 규칙 표 `| 규칙 | 이유 |` (이유 첫 단어는 접두사 7종 가운데 하나) 는 04-RESEARCH.md § 3 의 뼈대를 그대로 쓴다.

**Analog (문체):** `CHANGELOG.md:12-16` — 한 불릿에 "무엇을 / 왜 / 사용하는 프로젝트에는 영향 없음 / (날짜 · 버전)". 켠 이유 한 줄은 `lib/base.yaml` 의 사유 주석과 **같은 문장**으로 둔다.

**마커 규약:** 저장소에 선례가 없다. `<!-- woody:enabled-rules:start -->` / `:end`, `woody:enabled-options`, `woody:disabled-rules` 의 세 쌍 (04-RESEARCH.md § 3). 실측 기록 절은 `measure_rules.dart --report` 가 생성하고 손으로 고치지 않는다는 문장을 절 머리에 둔다.

---

### `lib/base.yaml` (config, 삭제 → 묶음별 추가)

**Analog:** 자기 자신 `lib/base.yaml:20-40`.

**목록 형식 + 분류 주석 + 한 줄 사유 주석** (`lib/base.yaml:20-24`):
```yaml
linter:
  rules:
    # 성능
    - prefer_const_constructors # 위젯 재사용을 극대화하여 성능 향상
    - prefer_const_literals_to_create_immutables # 불변 컬렉션의 효율적 관리
```
지킬 것: 들여쓰기 2칸, `- rule # 사유` 한 줄, 분류 주석 셋 (`# 성능` 22행, `# 가독성 및 스타일` 27행, `# 버그 방지` 36행) 은 규칙이 줄어도 남긴다. 맵 형식(`rule: true`)을 섞지 않는다 (WR-03 회피). 지울 줄: 25 · 29 · 33 · 37 · 39 · 40 (겹침 6) 과 15-16 · 31 · 34 (주석 3). `# Uncomment the following section …` (18행) 과 템플릿 영어 주석 (1-12, 43-47) 은 Phase 5 몫 — 건드리지 않는다. `strict-inference` 를 채택하면 `analyzer:\n  language:\n    strict-inference: true` 블록을 새로 두고 (`enabled-options` 마커와 짝), 지금 `base.yaml` 에는 `analyzer:` 블록이 없다.

**고칠 사유 문구** (D-18): 23행 "성능 향상" → 근거 있는 문장으로 (`flutter_lints` 5.0.0 이 제거, dart-lang/lints#205), 28행 `always_declare_return_types` 는 "기반 세트의 `strict_top_level_inference` 가 보지 않는 지역 함수 · 옛 typedef" 로.

---

### `example/lib/<묶음>_rules.dart` + 다섯 복사본 (fixture 샘플)

**Analog:** `example/lib/added_rules.dart:1-34` (exact).

**머리 주석과 샘플 하나의 모양** (`example/lib/added_rules.dart:1-20`):
```dart
import 'package:flutter/material.dart';

// woody_lints 가 기반 세트(flutter_lints / lints) 위에 추가하는 규칙 6개를
// 규칙마다 한 건씩 어긴다. 한 줄에서 규칙 하나만 걸리게 둔다.

/// `prefer_const_constructors` — const 로 만들 수 있는 생성자 호출.
Widget constCandidate() => Text('a');

/// `always_declare_return_types` — 반환 타입을 적지 않은 지역 함수.
/// (최상위 함수에 두면 기반 세트의 `strict_top_level_inference` 도 함께 걸린다.)
int callsLocal() {
  noReturnType() => 0;
  return noReturnType();
}
```
지킬 것: 규칙마다 함수 하나, 위에 `/// \`규칙\` — 무엇을 어기는가` 한 줄, **한 줄에 규칙 하나**, 다른 규칙(기반 세트 포함)이 같은 줄에 걸리면 괄호 주석으로 피한 방법을 적는다 (15-16행의 방식). 새 파일은 묶음마다 하나 (`bug_prevention_rules.dart` 등). `added_rules.dart` 자체는 **건드리지 않는다** (줄 7 · 13 · 18 · 24 · 29 · 33 이 정답지 다섯에 박혀 있다). 복사본은 `cp example/lib/<파일> fixtures/*/lib/` 로 만들고 커밋 전 `diff -rq example/lib fixtures/*/lib` (overrides 의 `suppress/` 만 더 있어야 한다).

**`example/lib/base_rules.dart:3-4`** 는 주석 문구만: "배포 파일에 적혀 있지만 기반 세트(flutter_lints / lints)도 켜는 규칙 6개와, 기반 세트만 켜는 규칙 1개를" → "기반 세트(`flutter_lints` / `lints`)가 켜는 규칙 7개를". 줄 수를 바꾸지 않는다.

---

### `example/README.md` (M20 ~ M25, 단계 수)

**Analog:** 같은 파일의 소절 제목 셋 (`167` "### 추가 실측 — 건수 비교 · `--update` 안전장치 · 규칙 0개 (gap 닫기 02-05)", `191` "### 추가 실측 — 망가진 배포 파일의 `--update` (03-01)", `213` "### 추가 실측 — 새 연습용 프로젝트가 헛통과가 아닌지 (03-03)") 과 M 표 (`120-131`).

**소절 머리 두 줄** (`example/README.md:167-169` 의 꼴):
```markdown
### 추가 실측 — 배포 파일의 구성 (04-NN)

실측 (04-NN): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-DD
```

**M 표의 행 모양** (`example/README.md:122`):
```markdown
| M1 | `lib/analysis_options.yaml` 에서 `- prefer_final_locals` 줄을 지움 | `[4/4]` | `- lib/added_rules.dart:24  info  prefer_final_locals` | 1 | VERIFY-08 — 규칙 하나를 지운 변경 |
```
표 아래에 "`- ` 는 정답지에는 있는데 나오지 않은 줄, `+ ` 는 …" 설명, "변경은 모두 커밋하지 않고 되돌렸다 … 끝에 검증 명령이 다시 종료 코드 0" 문장, 읽는 법 불릿 (`- **M18 에서 …**` 꼴) 을 같은 순서로 둔다. **확인 기록** (실패가 아닌 것 — 겹침 삭제 뒤 `--update` 가 "바뀐 정답지가 없다", 묶음마다 `+` 줄 = 샘플 수) 은 `165`행 "이 기록이 재지 않은 것도 있다 … (Phase 4 의 중복 선언 정리 때 확인한다)" 를 가리키는 문장으로.

**함께 고칠 자리:** `63`행 "화면과 검증 명령의 순서는 … (`[4/9]` ~ `[9/9]`)", `103`행 "단계 9개 모두 통과", 단계 설명의 `[3/9]` (지금의 옵션 파일 단계가 `[4/10]` 으로 밀린다), `40`행 파일 표의 `base_rules.dart` 문구.

---

### `CHANGELOG.md` `## 2.0.0 - 미출시`

**Analog:** `VERSIONING.md:77-127` (형식의 원본) + `CHANGELOG.md:10-16` (지금 항목의 불릿 문체).

**칸 순서와 표** (`VERSIONING.md:109-121`):
```markdown
### 추가한 규칙

- `rule_a` — 켠 이유 한 줄

### 새로 생기는 경고

| 규칙     | 강도 | 실측 | dart fix |
|----------|------|------|----------|
| `rule_a` | info | 12건 | 12건     |

실측: flutter_starter_kit (Dart 파일 169개), Flutter 3.47.5, 2026-11-20
```
지킬 것: 칸 순서 올리기 전에 → 추가한 규칙 → 뺀 규칙 → 그 밖의 변경 → 새로 생기는 경고; `dart fix` 는 **고쳐지는 건수**; 실측 줄 한 줄; 겹치는 6개 삭제는 `### 그 밖의 변경` 에 "사용하는 프로젝트에는 영향 없음 (정답지 다섯 그대로, 날짜)" 로 (`CHANGELOG.md:16` 의 "2026-10-12 에 두 선언 모두 3.1.9 로 풀려 경고가 달라지지 않았다 — 정답지 다섯 그대로" 가 같은 문장 꼴).

---

### `.planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md`

**Analog:** 같은 파일 `findings[]` (`1-25`행):
```yaml
  - id: WR-01
    severity: warning
    disposition: open
    title: "`[2/N]` 이 묶음과 별칭을 검사하지 않아, …"
```
`disposition` 값만 바꾼다 — WR-01 `fixed` (M23 · M24 를 근거로), WR-02 `deferred` (Phase 5 첫 일), WR-03 `open` (목록 형식 관례로 회피). 메모가 필요하면 기존 키를 깨지 않는 추가 키로.

---

### `tool/measurements/<YYYY-MM-DD>-<id>.json` (데이터)

**Analog:** `consumer.dart:98-111` `Shot.toJson` (위 2 의 발췌) — 경로 · 메시지 **필드 자체가 없는** 구조. 상위 키는 `{ "runId", "conditions": {sdk · baseSet(저장소 · 복사본) · plugin · languageVersion · sdkConstraint · dartFiles · date · stateSource}, "runs": [Shot 확장], "rows": {규칙: {group, state, severity, counts{lib,test,bin}, counts313?, fixRemoved, newErrors, ignored, upstream, incompatible, runs[]}} }` (04-RESEARCH.md § 1 "회차 기록"). 쓰기는 `JsonEncoder.withIndent('  ')` (repo_guard.dart:52 의 방식). `grep -c '"message"'` 가 0 이어야 한다 (§ 8 (3)).

## Shared Patterns

### 한국어 메시지 · 식별자 뒤 띄어쓰기
**Source:** `tool/verify.dart:816-827`, `1512-1514`, `1534`
**Apply to:** `tool/measure_rules.dart` 의 모든 stdout/stderr, `verify.dart` 새 단계의 `detailLines`, `RULES.md` · README · CHANGELOG
- 문장은 평서형 "~다", 영어 식별자 뒤 조사 앞에 한 칸 (`base.yaml 에만`, `RULES.md 와`).
- 실패 문구는 "무엇이 다른가 → 실제 값 → 정해진 값 → 다음에 할 일" 순.

### 종료 코드 (sysexits)
**Source:** `tool/verify.dart:24-25` 머리 주석, `1431`(64), `550`(69), `1533-1544`(70)
**Apply to:** `tool/measure_rules.dart`
`0 / 1 판정 실패 / 64 사용법 / 69 하위 명령 / 70 예외`. 준비 단계의 거부는 `quit()` (flush 뒤 exit), 단계 안의 실패는 `exitCode = N` 으로 끝까지 돌린다.

### 저장소 밖에만 쓰는 비공개 원문
**Source:** `consumer.dart:319-321` (`<work>/private/<id>.txt`), `022 probe.dart:313-314` (`fix-<규칙>` 원문), `consumer.dart:325-333` `scrubText`
**Apply to:** `tool/measure_rules.dart` 의 모든 쓰기, PLAN · SUMMARY 에 옮겨 적는 숫자
```dart
  String scrubText(String text) {
    final home = Platform.environment['HOME'] ?? '/nonexistent-home';
    return text
        .replaceAll(source, '<consumer-source>')
        .replaceAll(work, '<work>')
        .replaceAll(repo.root, '<repo>')
        .replaceAll(home, '~');
  }
```
예외 메시지(`ProcessException` 의 stderr 등)도 `scrubText` 를 거쳐 던진다 (consumer.dart:207). 커밋 전 04-RESEARCH.md § 8 의 grep 넷을 돌린다.

### 빈 상태 폴더로 분석 · plugin 준비 확인
**Source:** `consumer.dart:288-306`, `tool/verify.dart:29-33` (`pluginFailureHeader` 상수), `573` `pluginFolders`
**Apply to:** `measure_rules.dart` 의 모든 `analyze` · `dart fix` 호출
`ANALYZER_STATE_LOCATION_OVERRIDE` 에 실행마다 새 폴더, stderr 에 머리말 `An error occurred while executing an analyzer plugin:` 이 있으면 그 회차 무효, `.plugin_manager` 폴더 1개일 때만 버전을 읽는다.

### "사용 프로젝트가 바뀌면 멈춘다" — `replaceOnce`
**Source:** `consumer.dart:336-341`
**Apply to:** 복사본의 옵션 · pubspec 을 고치는 모든 자리
```dart
String replaceOnce(String text, String from, String to) {
  final count = from.allMatches(text).length;
  if (count != 1) throw FormatException('바꿀 자리가 $count번 나온다: ${jsonEncode(from)}');
  return text.replaceFirst(from, to);
}
```

### 문서의 실측 표기
**Source:** `example/README.md:117`, `CHANGELOG.md:16`, `lib/base.yaml` 관례 (CLAUDE.md "실측으로 확인한 동작은 버전과 날짜를 함께")
**Apply to:** `RULES.md`, README M 기록, CHANGELOG, `base.yaml` 사유 주석
`실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, YYYY-MM-DD` 한 줄; 추정은 "추정" 이라고 적는다.

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `RULES.md` 의 마커 구역 (`<!-- woody:…:start/end -->`) 과 그것을 읽는 `verify.dart` 함수 | 문서 규약 + 파서 | transform | 저장소에 HTML 주석 마커로 표를 읽는 선례가 없다. 04-RESEARCH.md § 3 의 규약(backtick 하나로 감싼 `[a-z0-9_]+`, 정렬 목록 비교)을 그대로 쓴다 |
| `measure_rules.dart --summary <묶음>` 의 터미널 요약 표 | 출력 포맷 | transform | `tool/verify.dart` 의 `formatStepLine` (1361-1366, `measureWidth` 로 열 맞춤) 이 가장 가깝지만 한 줄 포맷이다. 표의 모양은 04-CONTEXT.md `<specifics>` · 04-RESEARCH.md § 5 "터미널 요약의 모양" 을 따르고, 열 너비 계산만 `measureWidth` (1344) 를 재사용한다 |

## Metadata

**Analog search scope:** `tool/`, `lib/`, `example/`, `fixtures/*/lib`, `.claude/skills/spike-findings-woody-lints/sources/{020,021,022,023}-*`, `VERSIONING.md`, `CHANGELOG.md`, `.planning/phases/03-preset-split/03-REVIEW-DISPOSITION.md`
**Files scanned:** 14 (verify.dart 는 1,545행이라 Grep 으로 자리를 잡고 8개 구간만 읽음; consumer.dart 전문; 020 · 022 · 023 은 RESEARCH 가 가리킨 구간만)
**Tracked-source gate:** 모든 analog 경로를 `git ls-files` 로 확인 — spike 사본은 `.claude/skills/spike-findings-woody-lints/sources/` 아래의 추적 파일이다 (`.planning/spikes/` 원본이 아니라 skill 사본을 가리켰다)
**Pattern extraction date:** 2026-10-13
