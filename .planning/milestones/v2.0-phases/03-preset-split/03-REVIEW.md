---
phase: 03-preset-split
reviewed: 2026-10-12T13:02:25Z
depth: standard
files_reviewed: 65
files_reviewed_list:
  - .github/workflows/verify.yml
  - .gitignore
  - analysis_options.yaml
  - CHANGELOG.md
  - example/README.md
  - fixtures/base_codegen/analysis_options.yaml
  - fixtures/base_codegen/expected_diagnostics.txt
  - fixtures/base_codegen/lib/added_rules.dart
  - fixtures/base_codegen/lib/base_rules.dart
  - fixtures/base_codegen/lib/generated/sample.freezed.dart
  - fixtures/base_codegen/lib/generated/sample.g.dart
  - fixtures/base_codegen/lib/main.dart
  - fixtures/base_codegen/lib/riverpod_rules.dart
  - fixtures/base_codegen/lib/should_not_appear.dart
  - fixtures/base_codegen/pubspec.yaml
  - fixtures/base_only/analysis_options.yaml
  - fixtures/base_only/expected_diagnostics.txt
  - fixtures/base_only/lib/added_rules.dart
  - fixtures/base_only/lib/base_rules.dart
  - fixtures/base_only/lib/generated/sample.freezed.dart
  - fixtures/base_only/lib/generated/sample.g.dart
  - fixtures/base_only/lib/main.dart
  - fixtures/base_only/lib/riverpod_rules.dart
  - fixtures/base_only/lib/should_not_appear.dart
  - fixtures/base_only/pubspec.yaml
  - fixtures/base_riverpod/analysis_options.yaml
  - fixtures/base_riverpod/expected_diagnostics.txt
  - fixtures/base_riverpod/lib/added_rules.dart
  - fixtures/base_riverpod/lib/base_rules.dart
  - fixtures/base_riverpod/lib/generated/sample.freezed.dart
  - fixtures/base_riverpod/lib/generated/sample.g.dart
  - fixtures/base_riverpod/lib/main.dart
  - fixtures/base_riverpod/lib/riverpod_rules.dart
  - fixtures/base_riverpod/lib/should_not_appear.dart
  - fixtures/base_riverpod/pubspec.yaml
  - fixtures/overrides/analysis_options.yaml
  - fixtures/overrides/expected_diagnostics.txt
  - fixtures/overrides/lib/added_rules.dart
  - fixtures/overrides/lib/base_rules.dart
  - fixtures/overrides/lib/generated/sample.freezed.dart
  - fixtures/overrides/lib/generated/sample.g.dart
  - fixtures/overrides/lib/main.dart
  - fixtures/overrides/lib/riverpod_rules.dart
  - fixtures/overrides/lib/should_not_appear.dart
  - fixtures/overrides/lib/suppress/lint_file.dart
  - fixtures/overrides/lib/suppress/lint_line.dart
  - fixtures/overrides/lib/suppress/plugin_file_prefixed.dart
  - fixtures/overrides/lib/suppress/plugin_file_unprefixed.dart
  - fixtures/overrides/lib/suppress/plugin_line.dart
  - fixtures/overrides/pubspec.yaml
  - fixtures/recommended/analysis_options.yaml
  - fixtures/recommended/lib/added_rules.dart
  - fixtures/recommended/lib/base_rules.dart
  - fixtures/recommended/lib/generated/sample.freezed.dart
  - fixtures/recommended/lib/generated/sample.g.dart
  - fixtures/recommended/lib/main.dart
  - fixtures/recommended/lib/riverpod_rules.dart
  - fixtures/recommended/lib/should_not_appear.dart
  - fixtures/recommended/pubspec.yaml
  - lib/analysis_options.yaml
  - lib/base.yaml
  - lib/codegen.yaml
  - lib/recommended.yaml
  - lib/riverpod.yaml
  - tool/verify.dart
findings:
  critical: 0
  warning: 8
  info: 6
  total: 14
status: issues_found
---

# Phase 3: Code Review Report

**Reviewed:** 2026-10-12T13:02:25Z
**Depth:** standard
**Files Reviewed:** 65
**Status:** issues_found

## Summary

리뷰 범위는 Phase 3 에서 바뀐 배포 YAML 다섯(`lib/*.yaml`), 검증 명령 `tool/verify.dart`, 연습용 프로젝트 다섯(`fixtures/*`)과 정답지, 루트 설정 · workflow · 문서다.

실험은 HEAD 를 `git archive` 로 뽑은 복사본에서만 했다 (Flutter 3.47.5 / Dart 3.13.4, `dart analyze`). 원본 작업 트리는 건드리지 않았다. 복사본의 기준 실행은 `점검 통과 (9개 중 9개)`, 종료 코드 0 이었다 (plugin 상태 폴더가 빈 첫 실행, 68.7초).

다음은 맞는 것으로 확인했다.

- 조각 셋을 이어 붙이면 1.3.0 의 `lib/analysis_options.yaml` 과 같다. 다른 곳은 끝의 영어 템플릿 주석 위치와 `riverpod_lint` 하한(`^3.1.3` → `^3.1.9`)뿐이다.
- `fixtures/*/lib/` 는 지금 `example/lib/` 와 글자까지 같다 (`overrides` 의 `lib/suppress/` 만 더 있다). `fixtures/*/pubspec.lock` 은 `path` 줄만 다른 `example/pubspec.lock` 의 복사본이다.
- `lib/analysis_options.yaml` 의 제외를 걷어낸 뒤에도 루트의 `dart analyze` 는 `No issues found!` 다 (CHANGELOG 의 주장과 맞다).
- `[2/9]` 는 `base.yaml` 의 deprecated 규칙을 잡는다. 루트 옵션에 `build/**` 제외를 더해도 잡는다.
- `codegen.yaml` 의 깨진 YAML 은 `[2/9]` 가 `codegen/analysis_options.yaml:6:8 … parse_error` 로 잡는다.

정답지와 끄는 설정 샘플(`lib/suppress/`)은 README 의 "증명하는 것" 표를 뒷받침한다. 일부러 넣은 위반은 결함으로 세지 않았다.

문제는 주로 `tool/verify.dart` 의 판정 범위와 견고성에 있다.

- 묶음(`recommended.yaml`)과 별칭(`analysis_options.yaml`)에 들어간 deprecated 규칙은 아홉 단계를 모두 통과한다 (WR-01, 재현함).
- 프로젝트 관례대로 YAML 끝에 주석을 붙이거나 맵 형식을 쓰면 검증이 깨진다. 단계를 하나도 돌리지 못하고 종료 코드 70 으로 끝나거나 거짓 실패가 난다 (WR-02 · WR-03, 재현함).
- 실패 안내 문구가 틀린 경로를 알려 주거나 절대 경로를 찍는다 (WR-04 · WR-05, 재현함).

이미 기록된 두 관찰(`[3/9]` 실패 화면의 들여쓰기, M18)은 다시 적지 않았다.

각 항목에는 근거의 종류를 적었다. **재현함**은 복사본에서 실제로 돌려 본 것이고, **추론**은 코드를 읽고 판단한 것이다.

## Warnings

### WR-01: `[2/N]` 이 묶음과 별칭을 검사하지 않아, 거기 넣은 deprecated 규칙이 아홉 단계를 모두 통과한다 (재현함)

**File:** `tool/verify.dart:113-122` (`ruleCheckTargets`), `tool/verify.dart:908-1048` (`checkRuleNames`)
**Issue:** 규칙 검사 대상은 조각 셋뿐이다. `lib/recommended.yaml` 과 `lib/analysis_options.yaml` 은 폴더 분석이 plugin 을 준비한다는 이유로 대상에서 빠졌다 (spike 013). 그런데 이 두 파일이 `include:` 만 담는지는 어느 단계도 보지 않는다. deprecated 규칙은 include 를 거치면 보고되지 않으므로 (README M6) 정답지 비교도 잡지 못한다.

복사본의 `lib/recommended.yaml` 끝에 아래 세 줄을 더하고 `dart run tool/verify.dart` 를 돌렸다. 결과는 `[1/9]` ~ `[9/9]` 모두 통과, `점검 통과 (9개 중 9개)`, 종료 코드 0 이었다.

```yaml
linter:
  rules:
    - unnecessary_await_in_return
```

이 상태는 옛 주소를 쓰는 사용 프로젝트 다섯 모두에 초록 CI 와 함께 배포된다. 단계 이름 "배포 파일의 규칙 이름" 도 다섯 파일을 모두 본다고 읽힌다.
**Fix:** 묶음과 별칭의 내용을 `[3/N]` 처럼 통째로 고정한다. 주석과 빈 줄을 빼고 견준다. `checkFixtureOptions` 의 비교를 함수로 떼어 함께 쓰면 된다. 이렇게 하면 M18 의 "묶음이 Riverpod 조각을 잃음" 도 이 단계가 바로 짚는다.

```dart
/// 규칙을 담으면 안 되는 배포 파일 — include 줄만 있어야 한다 (주석 · 빈 줄 제외, trim 비교).
const includeOnlyFiles = <String, List<String>>{
  'lib/analysis_options.yaml': ['include: package:woody_lints/recommended.yaml'],
  'lib/recommended.yaml': [
    'include:',
    '- package:woody_lints/base.yaml',
    '- package:woody_lints/riverpod.yaml',
    '- package:woody_lints/codegen.yaml',
  ],
};
// checkRuleNames 의 checkLibYamlSet 바로 뒤에서 위 표와 견주고, 다르면 실패를 돌려준다.
```

### WR-02: `lib/riverpod.yaml` 을 YAML 로 문제없게 고쳐도 검증이 종료 코드 70 으로 멈춘다 (재현함)

**File:** `tool/verify.dart:769-778` (`stripPlugins`), `tool/verify.dart:1106-1118` (`readShippedPluginConstraint`)
**Issue:** 두 정규식은 `riverpod.yaml` 이 한 가지 글자 모양일 때만 맞는다. 복사본에서 두 경우를 돌려 봤다.

| 변경 | 결과 | 종료 코드 |
|------|------|-----------|
| `riverpod_lint: ^3.1.9 # 하한` (규칙 줄 끝에 한국어 주석을 다는 관례를 따름) | `lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다` | 70 |
| 마지막 줄의 줄바꿈을 지움 | `lib/riverpod.yaml 의 plugins: 섹션을 빼지 못했다` | 70 |

두 경우 모두 stdout 이 비고, 아홉 단계 가운데 하나도 화면에 찍히지 않는다.

같은 이유로 다음 모양도 멈춘다고 추론한다.

- `plugins: # 주석` 이나 `plugins:` 뒤의 공백
- `plugins:` 섹션 안의 빈 줄이나 0열 주석
- CRLF 줄바꿈
- `riverpod_lint:` 를 맵 형식(`version:` / `diagnostics:`)으로 바꾼 것. 사용 프로젝트에 안내하는 끄는 설정의 형식이기도 하다

또 `stripPlugins` 는 섹션을 지우므로 그 뒤의 줄 번호가 당겨진다. `fragmentLineHint` 의 단서 문장은 이것 때문에 필요하다.
**Fix:**

- 선언 읽기는 줄 끝 주석을 허용한다. `r'^[ \t]+riverpod_lint:[ \t]*([^\s#]+)[ \t]*(?:#.*)?$'`
- 맵 형식은 바로 아랫줄의 `version:` 을 읽는다. 또는 루트 `dev_dependencies` 에 `yaml` 을 두고 `loadYaml` 로 `plugins.riverpod_lint` 를 읽는다 (`dev_dependencies` 는 사용 프로젝트로 전달되지 않는다).
- 섹션 빼기는 지우지 말고 빈 줄로 바꾼다. 그러면 줄 번호가 원본과 같아져 힌트의 단서 문장도 필요 없다.

```dart
String stripPlugins(String options, {required String shownAs}) {
  final lines = options.replaceAll('\r\n', '\n').split('\n');
  var inPlugins = false;
  for (var i = 0; i < lines.length; i++) {
    final l = lines[i];
    if (RegExp(r'^plugins:\s*(#.*)?$').hasMatch(l)) {
      inPlugins = true;
    } else if (inPlugins && RegExp(r'^\S').hasMatch(l) && !l.startsWith('#')) {
      inPlugins = false;
    }
    if (inPlugins) lines[i] = '';
  }
  return lines.join('\n');
}
```

### WR-03: 규칙 세기와 규칙 이름 읽기가 목록 형식만 알아, 같은 뜻의 맵 형식이 `[2/N]` 거짓 실패가 된다 (재현함)

**File:** `tool/verify.dart:843-863` (`countDeclaredRules`), `tool/verify.dart:832-841` (`readRuleNameAt`)
**Issue:** 복사본의 `lib/base.yaml` 에서 규칙 12줄을 `- rule # …` 에서 `rule: true # …` 로만 바꿨다. 분석 결과는 같아서 `[4/9]` ~ `[9/9]` 는 모두 통과했다. 그런데 `[2/9]` 는 아래 문구를 내고 실패했다 (`점검 실패 (9개 중 1개)`, 종료 코드 1).

`` `lib/base.yaml` 의 최상위 `linter:` 블록 안에서 `- 규칙이름` 줄을 하나도 세지 못했다. ``

안내 문구는 키 이름과 들여쓰기를 보라고 하므로 원인을 잘못 짚는다.

기반 세트(`flutter_lints`)가 켜는 규칙을 이 패키지에서 끄려면 `avoid_print: false` 같은 맵 형식밖에 없다. YAML 의 `rules:` 는 목록과 맵을 섞을 수 없어서, 이때는 블록 전체가 맵이 되어야 한다. 규칙을 바꾸는 Phase 4 에서 이 경로를 밟을 수 있다. 맵 형식의 진단 줄에는 `readRuleNameAt` 이 규칙 이름도 붙이지 못한다.
**Fix:** 두 형식을 모두 센다. 끈 규칙(`: false`)을 "본 규칙" 으로 셀지는 정해서 주석으로 남긴다.

```dart
final rulePattern = RegExp(r'^\s+(?:-\s*)?([A-Za-z0-9_]+)\s*(?::\s*(?:true|false))?\s*(?:#.*)?$');
// `rules:` 줄 자체는 세지 않도록 이름이 'rules' 인 줄은 건너뛴다.
```

### WR-04: 중첩 fixture 의 lock 불일치 안내가 틀린 경로를 알려 준다 (재현함)

**File:** `tool/verify.dart:542-549`
**Issue:** `final name = dir.split('/').last;` 는 `fixtures/base_only` 를 `base_only` 로 줄인다. 복사본의 `fixtures/base_only/pubspec.yaml` 에 `http: any` 를 더하고 돌리면 stderr 에 아래 안내가 찍힌다 (종료 코드 69).

```text
`base_only/pubspec.yaml` 을 바꿨으면 `cd base_only && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요.
```

저장소 루트에는 `base_only/` 가 없어서 이 명령은 실패한다. Phase 3 에서 fixture 를 `fixtures/` 아래로 넣으면서 생긴 회귀다. `example` 하나뿐일 때는 맞았다.
**Fix:** 화면용 이름을 이미 받고 있으므로 그것을 쓴다.

```dart
final name = (shownAs ?? dir).replaceFirst(RegExp(r'/$'), '');
stderr.writeln('`$name/pubspec.yaml` 을 바꿨으면 `cd $name && fvm dart pub get` 으로 …');
```

### WR-05: 정답지 파일이 깨지면 절대 경로를 찍고 종료 코드 70 으로 끝나며, `--update` 로도 복구할 수 없다 (재현함)

**File:** `tool/verify.dart:1259-1262`, `tool/verify.dart:245`, `tool/verify.dart:1533-1535`
**Issue:** 복사본의 `fixtures/base_only/expected_diagnostics.txt` 맨 위에 merge 충돌 표시 `<<<<<<< HEAD` 를 넣고 `--update` 로 돌렸다. 결과는 종료 코드 70, stdout 0줄이었다. stderr 에는 아래 줄이 찍혔다.

```text
파일 모양이 예상과 다르다: 첫 줄이 `exit N` 이 아니다: <저장소 절대 경로>/fixtures/base_only/expected_diagnostics.txt
```

여기에는 세 가지 문제가 있다.

1. `FormatException` 처리기는 `FileSystemException` 처리기와 달리 `relativize` · `scrubPaths` 를 거치지 않는다. 그래서 runner 의 절대 경로가 공개 CI 로그에 남는다 (스크립트가 곳곳에서 막으려는 바로 그것이다).
2. 앞서 끝난 단계의 결과가 모두 버려진다.
3. 정답지를 다시 만드는 명령인 `--update` 가 바로 이 상황에서 쓸모가 없다. 파일을 손으로 지워야 한다.
**Fix:** `compareFixture` 안에서 `Expected.read` 의 `FormatException` 을 받아 그 단계만 실패시킨다. 문구에는 상대 경로를 쓴다. 갱신 모드에서는 정답지가 없는 경우(`expected = null`)처럼 차이를 보여 주고 쓴다. 덧붙여 `main` 의 `FormatException` 처리기도 `scrubPaths(e.message, repoRoot)` 를 거치게 한다.

```dart
Expected? expected;
String? brokenNote;
if (expectedFile.existsSync()) {
  try {
    expected = Expected.read(expectedFile);
  } on FormatException catch (e) {
    brokenNote = '${fixture.path}/$expectedPath 를 읽지 못했다: ${scrubPaths(e.message, repoRoot)}';
    if (!update) return StepResult(label: label, passed: false, plugin: plugin, outcome: outcome, detailLines: [brokenNote, '', '정답지를 다시 만들려면 `$updateCommand`']);
  }
}
```

### WR-06: "fixture 의 `lib/` 는 `example/lib/` 의 글자 그대로 복사본" 이라는 전제를 아무 단계도 지키지 않는다 (추론)

**File:** `tool/verify.dart:1050-1100` (확인이 있어야 할 자리), `example/README.md:72`
**Issue:** README 는 줄 번호가 같아야 정답지를 견줄 수 있다고 하고, 샘플을 고치면 다섯 복사본도 손으로 고치라고 한다. 지금은 다섯 모두 같다 (`diff -r` 로 확인했다).

`recommended` 는 `example` 의 같은 실행 결과와 견주므로 어긋나면 드러난다. 하지만 `base_only` · `base_riverpod` · `base_codegen` · `overrides` 는 자기 정답지만 보므로, `example/lib/` 와 어긋나도 그대로 통과한다. Phase 4 에서 새 규칙의 위반 샘플을 `example/lib/` 에만 더하고 `--update` 를 돌리는 경우를 생각해 보자. 나머지 넷은 그 규칙에 대해 아무것도 증명하지 못하는데도 초록이다. README 의 "증명하는 것" 표가 조용히 거짓이 된다.
**Fix:** `[3/N]` 에 (또는 새 단계로) 복사본 비교를 넣는다. `fixtures/*/lib/` 에서 `lib/suppress/` 를 뺀 파일 목록과 각 파일의 바이트가 `example/lib/` 와 같아야 통과로 한다.

### WR-07: plugin 을 쓰는 fixture 에서 plugin 이 준비되지 않은 실행도 `--update` 가 정답지로 쓴다 (추론)

**File:** `tool/verify.dart:1266-1302`
**Issue:** 이 구멍은 README 에 "막지 않는 것" 으로 적혀 있다 (Phase 2 의 WR-01 둘째 경우). Phase 3 에서 달라진 점이 둘 있다.

- plugin 을 쓰는 fixture 가 하나에서 넷으로 늘었다.
- `Fixture.usesPlugin` 이 생겨 막는 비용이 한 줄이 되었다.

`readPluginVersion` 이 plugin 폴더 0개(`이 상태 폴더에 plugin 이 준비되지 않았다`)를 돌려준다는 것은 plugin 이 그 실행에서 돌지 않았다는 강한 신호다. 그런데 stderr 에 머리말이 없으면 갱신 가지는 `riverpod_lint` 3줄이 빠진 결과를 `riverpod_lint ?` 머리 주석과 함께 쓴다.
**Fix:** 갱신 가지 앞에 다음을 둔다. 그러면 `main` 의 "다른 단계가 실패하면 쓰지 않는다" 가 그 실행 전체의 쓰기를 막는다.

```dart
if (update && fixture.usesPlugin && plugin.version == null) {
  return StepResult(label: label, passed: false, plugin: plugin, outcome: outcome,
      detailLines: ['${fixture.path}/ — plugin 버전을 읽지 못해 정답지를 쓰지 않는다: ${plugin.reason}']);
}
```

### WR-08: 서드파티 action 을 바뀔 수 있는 tag 로 받는다 (추론)

**File:** `.github/workflows/verify.yml:28`, `:31` (`actions/checkout@v7`, `subosito/flutter-action@v2`)
**Issue:** `@v2` 는 그 저장소 소유자가 언제든 다른 커밋으로 옮길 수 있다. `permissions: contents: read` 이고 비밀 값을 쓰지 않으므로 피해는 "검증 결과를 거짓으로 만들기" 와 저장소 읽기에 그친다. 하지만 이 workflow 는 릴리스 판정에 쓰는 유일한 자동 관문이다. Phase 3 이전부터 있던 상태이고, 이번 Phase 에서는 주석만 바뀌었다.
**Fix:** 커밋 SHA 로 고정하고 tag 는 주석으로 남긴다. 예: `uses: subosito/flutter-action@<40자 SHA> # v2.x.y`. Dependabot 의 `github-actions` 생태계로 갱신을 받는다.

## Info

### IN-01: 단계 번호 `[1/4]` · `[2/4]` 와 "다섯" 이 코드에 박혀 있다

**File:** `tool/verify.dart:141`, `:144`, `:733`, `:795`, `:816`, `:886`
**Issue:** 단계가 아홉으로 늘었는데 문서 주석은 여전히 `[1/4]` · `[2/4]` 라고 적는다. 실패 문구 `` `lib/` 의 YAML 이 정해진 다섯과 다르다. `` 는 `expectedLibYamls` 의 크기를 숫자로 박아 두었다.
**Fix:** 주석은 `[1/N]` · `[2/N]` 으로 바꾼다. 문구는 `${expectedLibYamls.length}` 로 만든다.

### IN-02: 다른 도구의 stderr 를 찍는 곳 가운데 일부만 경로를 가린다

**File:** `tool/verify.dart:942-953` (`checkRuleNames` 의 도구 사망 가지), `tool/verify.dart:551` (`runPubGet`)
**Issue:** `compareFixture` 의 같은 가지(1191-1194)는 `scrubPaths` 를 거친다. 그러나 규칙 검사의 도구 사망 문구와 `pub get` 실패의 stderr 원문은 그대로 찍는다. "CI 로그에 runner 경로를 남기지 않는다" 는 의도와 맞지 않는다.
**Fix:** 두 곳 모두 `scrubPaths(…, repoRoot)` 를 거친다. `runPubGet` 에는 `repoRoot` 를 인자로 넘긴다.

### IN-03: `lib/codegen.yaml` 에 "왜" 주석이 없다

**File:** `lib/codegen.yaml:1-6`
**Issue:** 프로젝트 관례는 설정마다 이유를 적는 것이다. 다른 조각과 묶음 · 별칭은 머리 주석이 있는데, 이 조각만 주석이 없다. `invalid_annotation_target: ignore` 가 freezed / json_serializable 의 오탐 때문이라는 것, 그리고 이 SDK 에서 `exclude` 가 plugin 진단에는 통하지 않는다는 것(README, spike 012)은 조각을 따로 고르는 사용자에게 필요한 정보다.
**Fix:** 두세 줄의 머리 주석을 더한다. 1.3.0 에도 이 블록에는 주석이 없었으니 회귀는 아니다.

### IN-04: `example/README.md` 의 M1 ~ M17 이 지금은 없는 파일 모양을 가리킨다

**File:** `example/README.md:120-130` (M1 ~ M9 표), `:173-201` (M10 ~ M17 표)
**Issue:** 각 행은 `lib/analysis_options.yaml` 의 규칙 줄 · `errors:` · exclude 를 고친다고 적는다. 진단 경로도 `build/woody_rule_check/analysis_options.yaml:41` 처럼 하위 폴더가 없는 모양이다. 지금 그 파일은 한 줄짜리 별칭이라, 그대로 다시 재 보려는 독자는 고칠 줄을 찾지 못한다. 소절 제목에 plan 번호는 있지만 "분리 전의 단일 파일에서 쟀다" 는 말은 없다.
**Fix:** 첫 표 위에 한 줄을 더한다. 예: "M1 ~ M17 은 Phase 3 분리 전(단일 `lib/analysis_options.yaml`, 단계 4개)에서 잰 기록이다. 지금의 같은 줄은 `lib/base.yaml` · `lib/codegen.yaml` 에 있다."

### IN-05: 규칙 검사 복사본 폴더를 쓰기 전에 비우지 않는다

**File:** `tool/verify.dart:922-928`
**Issue:** 앞선 실행이 중단되면(SIGINT 로 끝나면 `finally` 가 돌지 않는다) `build/woody_rule_check/<옛 이름>/` 이 남는다. 다음 실행은 그 폴더까지 분석하고, `lib/<옛 이름>.yaml` 을 고치라고 안내한다. 그 실행의 `finally` 가 폴더를 지우므로 저절로 낫기는 한다 (추론, 재현하지 않음).
**Fix:** `try` 에 들어가기 전에 `if (checkDir.existsSync()) checkDir.deleteSync(recursive: true);` 를 둔다.

### IN-06: `lib/` 의 YAML 집합 확인이 최상위 `.yaml` 만 본다

**File:** `tool/verify.dart:800-808`
**Issue:** `listSync()` 는 재귀하지 않고 확장자는 `.yaml` 만 본다. 사용 프로젝트는 `package:woody_lints/presets/x.yaml` 이나 `package:woody_lints/x.yml` 도 include 할 수 있다. 그런 파일은 집합 확인과 규칙 검사를 모두 비켜 간다 (추론).
**Fix:** `listSync(recursive: true)` 로 `.yaml` · `.yml` 을 모두 모은다. `relativize` 결과(하위 경로 포함)를 `expectedLibYamls` 와 견준다.

---

_Reviewed: 2026-10-12T13:02:25Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
