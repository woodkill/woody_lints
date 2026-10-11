---
phase: 02-verification-harness
reviewed: 2026-10-11T17:33:34Z
depth: standard
files_reviewed: 17
files_reviewed_list:
  - .github/workflows/verify.yml
  - .gitignore
  - analysis_options.yaml
  - CHANGELOG.md
  - example/analysis_options.yaml
  - example/expected_diagnostics.txt
  - example/lib/added_rules.dart
  - example/lib/base_rules.dart
  - example/lib/generated/sample.freezed.dart
  - example/lib/generated/sample.g.dart
  - example/lib/main.dart
  - example/lib/riverpod_rules.dart
  - example/lib/should_not_appear.dart
  - example/pubspec.lock
  - example/pubspec.yaml
  - example/README.md
  - tool/verify.dart
findings:
  critical: 1
  warning: 7
  info: 6
  total: 14
status: issues_found
---

# Phase 2: Code Review Report

**Reviewed:** 2026-10-11T17:33:34Z
**Depth:** standard
**Files Reviewed:** 17
**Status:** issues_found

## Summary

검증 명령 `tool/verify.dart`, 연습용 프로젝트 `example/`, CI workflow, 관련 문서를 읽고, 의심 가는 경로는 저장소 밖의 복사본에서 실제로 돌려 확인했다 (Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, macOS arm64, 2026-10-12 로컬 날짜). 저장소의 추적 파일은 고치지 않았고 `--update` 는 복사본에서만 돌렸다.

결론부터 적는다.

- **정답지 비교가 건수를 세지 않는다 (CR-01).** 같은 줄에 같은 규칙이 두 건 나오면 한 건이 생기거나 사라져도 통과한다. 지금의 `example/` 에는 그런 줄이 없어 드러나지 않지만, 검증 명령의 중심 기능이 틀린 판정을 내는 입력이 실제로 있다.
- **`--update` 가 망가진 실행에서도 정답지를 쓴다 (WR-01).** 같은 실행에서 다른 단계가 실패했거나 plugin 버전을 읽지 못했어도 쓴다.
- **규칙 이름 단계가 본 것이 없어도 통과한다 (WR-02, WR-03).** 전체 판정은 정답지 비교가 대신 실패시켜 주지만, 화면은 원인을 가리킨 단계를 "통과" 로 찍고 진짜 원인(YAML 오류, 중복 규칙 등)은 보이지 않는다.
- 나머지는 실패 안내가 원인을 잘못 짚거나(WR-06, IN-02), 한 단계의 예외가 화면 전체를 날리는(WR-05) 종류다.

실행으로 확인했고 **문제가 없었던 것** (발견 사항이 아니다. 이전에 실행해 보지 못했다고 기록된 경로가 들어 있어 적어 둔다).

| 확인한 것 | 결과 |
|---|---|
| 저장소에서 `fvm dart run tool/verify.dart` | 4단계 통과, exit 0, 4.8초. 작업 트리 변화 없음, `build/` 남지 않음 |
| 저장소 루트 `fvm dart analyze`, `fvm dart format --set-exit-if-changed tool example/lib` | 진단 0건, 바뀔 파일 0개 |
| Flutter 밖의 dart (dart-sdk 사본) + `FLUTTER_ROOT` 없음 | exit 78, "Flutter SDK 의 dart 가 아니다" |
| 같은 dart + `FLUTTER_ROOT` 가 3.41.9 (Dart 3.11.5) | exit 78 — fallback 이 Dart 버전이 다른 SDK 를 받아들이지 않는다 |
| 같은 dart + `FLUTTER_ROOT` 가 3.47.5 | fallback 으로 통과, 4단계 통과, exit 0 |
| lock 이 어긋난 채 루트 `.dart_tool` 을 지우고 실행 (CI 의 새 checkout 모양), `example/` 을 작업 폴더로 두고 실행, `/` 에서 절대 경로로 실행 | 세 경우 모두 exit 69, `example/pubspec.lock` 은 다시 쓰이지 않았다 — `dart run` 의 암묵적 `pub get` 은 `example/` 을 건드리지 않는다 |
| 배포 파일의 plugin 제약을 `^99.0.0` 으로 바꾸고 `--update` | "plugin 준비 실패" 로 exit 1, 정답지는 그대로 |
| `--help`, `--update=1` | exit 64 |
| 샘플 ↔ 정답지 ↔ `example/README.md` 의 건수 | 6 + 7 + 1 + 2 = 16 줄로 서로 맞는다. 정답지의 16줄은 모두 서로 다른 줄이다 |
| `CHANGELOG.md` 의 칸 순서 | `VERSIONING.md` 의 순서(올리기 전에 → 그 밖의 변경 → 새로 생기는 경고)와 같다 |

## Narrative Findings (AI reviewer)

아래 `## Critical Issues`, `## Warnings`, `## Info` 가 직접 읽고 돌려서 찾은 것이다. 구조 분석(fallow) 입력과 외부 리뷰어 증거는 받지 않았다. 항목마다 "확인" 줄에 실행으로 본 것인지 읽기로만 본 것인지 적었다.

## Critical Issues

### CR-01: 정답지 비교가 집합으로 견줘서, 같은 줄이 여러 건일 때 건수 변화를 놓친다

**File:** `tool/verify.dart:477-478`
**Issue:** `findDifference` 가 `expectedLines.where((l) => !actual.contains(l))` 와 그 반대 방향으로만 견준다. 줄이 "있는가" 만 보고 "몇 번 있는가" 는 보지 않는다. 정답지 한 줄(`상대경로:줄  강도  규칙이름`)에는 열(column)이 없어서, 한 줄에 같은 규칙이 두 번 걸리면 똑같은 줄 둘이 된다. 그 둘 중 하나가 생기거나 사라져도 통과한다.

`example/README.md:5` ("한 줄이라도 다르면 실패다") 와 `:65` ("경고가 생기거나, 사라지거나 … 검증이 실패한다") 가 이 경우에는 맞지 않는다. Phase 3 의 완료 기준("정답지가 한 줄도 바뀌지 않는다")이 이 비교에 기댄다.

지금의 `example/` 은 "한 줄에서 규칙 하나만" 으로 짜여 있어 16줄이 모두 다르다. 그래서 현재 fixture 로는 틀린 판정이 나오지 않는다. 다만 똑같은 줄이 생기는 경로는 샘플 코드 말고도 있다 — 배포 파일 자체의 문제는 전부 `analysis_options.yaml:1  warning  included_file_warning` 한 모양으로 올라온다 (WR-03 의 실행에서 서로 다른 문제 3건이 똑같은 줄 3개로 나왔다). 그 줄이 한 번이라도 정답지에 들어가면 그 뒤에 생기는 배포 파일의 문제는 몇 건이든 보이지 않는다.

**확인 (실행):**
- 복사본의 정답지 끝에 이미 있는 줄 `lib/base_rules.dart:22  info  avoid_print` 를 한 번 더 적고 실행 → `[4/4]` 통과, exit 0 (정답지 17줄, 실제 16건).
- `example/lib/dup.dart` 에 `void twoPrints() { print('x'); print('y'); }` 한 줄을 두고 정답지에는 `lib/dup.dart:1  info  avoid_print` 를 **한 줄만** 더함. `dart analyze --format=json` 은 그 줄에서 `avoid_print` 2건(column 20, 32)을 냈는데 검증은 `[4/4]` 통과, exit 0.

**Fix:** 건수를 세는 차집합으로 바꾼다.

```dart
/// [from] 에서 [remove] 의 줄을 건수만큼 뺀 나머지 (같은 줄이 여러 번 있을 수 있다).
List<String> subtractLines(List<String> from, List<String> remove) {
  final remaining = <String, int>{};
  for (final line in remove) {
    remaining[line] = (remaining[line] ?? 0) + 1;
  }
  final rest = <String>[];
  for (final line in from) {
    final left = remaining[line] ?? 0;
    if (left > 0) {
      remaining[line] = left - 1;
    } else {
      rest.add(line);
    }
  }
  return rest;
}

// findDifference 안에서
missing: subtractLines(expectedLines, actual),
unexpected: subtractLines(actual, expectedLines),
```

## Warnings

### WR-01: `--update` 가 같은 실행에서 실패가 난 뒤에도, plugin 버전을 읽지 못한 때에도 정답지를 쓴다

**File:** `tool/verify.dart:789-815`, `tool/verify.dart:986-988`
**Issue:** `compareFixture` 는 "plugin 준비 실패" 와 "도구가 죽음" 에서만 쓰기를 막는다. 그 둘을 지나면 `--update` 는 무조건 `passed: true` 와 `applyUpdate` 를 돌려주고, `main` 은 다른 단계의 결과를 보지 않고 모든 `applyUpdate` 를 부른다. 그래서 다음 두 경우에 망가진 실행의 결과가 정답지로 들어간다.

1. 같은 실행의 다른 단계가 실패한 때. `[3/4]` 이 "include 한 줄이 아니다" 로 실패했는데도 `[4/4]` 는 그 깨진 옵션 파일로 분석한 결과를 정답지에 쓴다. 화면은 `[4/4] … 통과` 와 `점검 실패 (4개 중 1개)` 를 함께 찍는다.
2. plugin 버전이 `?` 인 때. 머리 주석에 `riverpod_lint ?` 를 적고 exit 0 으로 끝난다.

1번에서는 머리 주석도 틀린다. plugin 이 그 실행에서 돌지 않았는데 상태 폴더에 남은 값으로 `riverpod_lint 3.1.9` 를 "실측" 으로 적는다 (`example/README.md:131` 은 화면의 `plugin` 줄에 대해서만 이 한계를 적었다).

바뀌는 줄을 화면에 보여 주므로 조용히 덮어쓰는 것은 아니다. 다만 docstring(`tool/verify.dart:714-717`)이 "앞의 두 실패에서는 `update` 여도 정답지를 건드리지 않는다" 로 정한 취지가 이 두 경우에는 지켜지지 않는다.

**확인 (실행):**
- 복사본의 `example/analysis_options.yaml` 을 빈 파일로 만들고 `--update` → exit 1, 정답지는 `exit 2` + `lib/should_not_appear.dart:5  warning  invalid_annotation_target` 한 줄로 바뀌었고 머리 주석은 `riverpod_lint 3.1.9` 였다.
- 상태 폴더의 `.plugin_manager` 에 빈 폴더 하나를 더 만들고 `--update` → exit 0, "정답지와 같다 — 바뀐 줄 없음", 정답지 첫 줄이 `# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint ?, 2026-10-12` 로 바뀌었다.

**Fix:** 쓰기 전에 실행 전체를 본다.

```dart
// main — `--update` 의 쓰기 직전
final blocked = results.any((r) => !r.passed);
if (blocked && results.any((r) => r.applyUpdate != null)) {
  stdout.writeln('');
  stdout.writeln('다른 단계가 실패해 정답지를 쓰지 않았다 — 실패를 먼저 고친 뒤 다시 실행하세요.');
} else {
  for (final result in results) {
    result.applyUpdate?.call();
  }
}
```

`compareFixture` 의 `update` 가지 앞에는 `plugin.version == null` 이면 쓰지 않고 실패로 돌려주는 가지를 둔다 (`'plugin 버전을 읽지 못해 정답지를 쓰지 않는다: ${plugin.reason}'`). 화면의 `정답지 갱신:` 줄은 쓰기가 실제로 일어났을 때만 그 뜻이 되도록 `main` 이 쓴 뒤에 찍거나 문구를 "갱신할 내용" 으로 바꾼다. Phase 3 에서 plugin 이 없는 fixture 가 생기면 "버전을 읽지 못함 = 막음" 은 fixture 별로 풀어야 한다.

### WR-02: `dart analyze` 의 종료 코드와 JSON 이 어긋나는 것을 보지 않아, 규칙 이름 단계가 YAML 이 깨진 배포 파일을 "통과" 로 찍는다

**File:** `tool/verify.dart:610`, `tool/verify.dart:644-647`, `tool/verify.dart:762`
**Issue:** `dart analyze --format=json` 은 옵션 파일의 error 강도 진단을 JSON 에 싣지 않는다 (skill `references/rule-status-check.md` 의 "What to Avoid" 마지막 항목에 실측으로 적혀 있다). 배포 파일의 YAML 이 깨지면 규칙 검사의 분석은 `{"version":1,"diagnostics":[]}` 와 exit 3 을 낸다. 스크립트는 3 을 "정상 종료 코드" 로 받고(610행) 문제 줄이 0건이라 `passed: true` 를 돌려준다(647행). 규칙을 하나도 보지 못했는데 통과다.

전체 판정은 `[4/4]` 가 실패시켜 준다. 그러나 화면에는 원인이 없다 — `[2/4] 통과`, `종료 코드: 정답지 2, 실제 3`, "나오지 않은 경고 16건" 이 전부이고, error 를 낸 진단(`parse_error`)은 어디에도 찍히지 않는다. 안내는 "일부러 바꾼 것이면 정답지를 갱신하세요" 다. 그대로 `--update` 하면 줄에는 error 가 없는데 `exit 3` 인 정답지가 만들어진다.

**확인 (실행):** 복사본의 `lib/analysis_options.yaml` 에서 `- prefer_final_locals` 줄을 `- 'prefer_final_locals` (닫지 않은 따옴표)로 바꿨다.
- 규칙 검사와 같은 형태(`dart --suppress-analytics analyze --format=json build/woody_rule_check`)를 직접 돌림 → `{"version":1,"diagnostics":[]}`, exit 3. 사람이 읽는 형식으로는 `error - analysis_options.yaml:46:8 - While parsing a block collection, expected '-'. - parse_error` 가 나왔다.
- 검증 명령 → `[2/4] 통과`, `[4/4] 실패`, exit 1. `example/` 의 JSON 에는 warning 1건뿐이고 error 는 없었다.

**Fix:** 종료 코드가 말하는 강도의 줄이 JSON 에 실제로 있는지 두 단계 모두에서 확인한다.

```dart
/// 종료 코드가 말하는 강도의 진단이 [lines] 에 실제로 있는지 본다.
///
/// `dart analyze` 는 옵션 파일의 error 진단을 JSON 에 싣지 않는다 — 그때 exit 3 인데
/// error 줄이 없다.
bool hasSeverityForExit(int exitCode, List<String> lines) => switch (exitCode) {
  3 => lines.any((l) => l.contains('  error  ')),
  2 => lines.any((l) => l.contains('  warning  ')),
  _ => true,
};
```

어긋나면 실패로 돌려주고 이렇게 안내한다: "dart analyze 가 JSON 에 싣지 않은 진단이 있다 (옵션 파일의 error). `fvm dart analyze` 를 `<폴더>` 에서 직접 돌려 확인하세요." `compareFixture` 에서는 이 경우 `--update` 도 막는다.

### WR-03: 규칙 이름 단계가 세 코드 밖의 진단을 모두 버리고, 규칙을 하나도 읽지 못해도 통과한다

**File:** `tool/verify.dart:644-647`
**Issue:** 이 단계는 배포 파일의 복사본을 분석해 놓고 `deprecated_lint` / `removed_lint` / `undefined_lint` (와 `include_file_not_found`) 로 끝나는 줄만 본다. 같은 분석이 배포 파일에 대해 낸 나머지 warning 은 읽고 버린다. 지금의 배포 파일은 이 분석에서 0건이므로(skill 의 실측), 0건이 아닌 것은 전부 배포 파일의 문제인데도 그렇다.

버려지는 것들은 `[4/4]` 에서 include 줄의 `included_file_warning` 으로 다시 나타나 전체 판정은 실패한다. 하지만 그 모양으로는 무엇이 문제인지 알 수 없다 — 서로 다른 문제 3건이 줄 번호도 이름도 없는 똑같은 줄 3개가 된다 (CR-01 과 겹치면 건수 변화도 보이지 않는다). 줄 번호와 코드를 아는 쪽은 `[2/4]` 인데 그쪽이 "통과" 를 찍는다.

반대 방향도 있다. `linter:` 키를 잘못 적어 규칙이 하나도 읽히지 않으면 분석은 0건, exit 0 이고 이 단계는 통과한다.

**확인 (실행):**
- 복사본의 배포 파일에 `errors:` 아래 `no_such_diagnostic_code: ignore`, 규칙 목록 끝에 `- avoid_print` (중복)과 `- prefer_double_quotes` 를 더함 → 규칙 검사 형태의 분석은 `41 WARNING duplicate_rule`, `42 WARNING incompatible_lint`, `47 WARNING unrecognized_error_code` 를 냈고, 검증 명령은 `[2/4] 통과`, `[4/4] 실패` (`analysis_options.yaml:1  warning  included_file_warning` 이 똑같이 3줄).
- `linter:` 를 `lintr:` 로 바꿈 → 규칙 검사 형태의 분석은 0건, 검증 명령은 `[2/4] 통과`, `[4/4] 실패`.

**Fix:** 복사본에 대한 진단이 하나라도 있으면 실패로 하고, 세 코드는 지금처럼 "쓸 수 없는 규칙" 으로, 나머지는 "배포 파일의 다른 경고" 로 줄 번호와 코드를 그대로 찍는다. 읽은 규칙 수도 확인한다.

```dart
// include 확인 뒤, problems 를 고르기 전에
final ruleCount = copy
    .split('\n')
    .where((l) => RegExp(r'^\s*-\s*[a-z0-9_]+').hasMatch(l))
    .length;
if (ruleCount == 0) {
  return StepResult(
    label: label,
    passed: false,
    detailLines: ['`$shippedOptionsPath` 에서 규칙을 하나도 읽지 못했다 — `linter: rules:` 를 확인하세요.'],
  );
}
final others = lines
    .where((l) => !ruleProblemCodes.any((code) => l.endsWith('  $code')))
    .toList();
// problems 와 others 중 하나라도 있으면 passed: false
```

단계 이름을 "배포 파일의 규칙 이름" 으로 좁게 두고 싶으면, 적어도 `others` 를 화면에 찍어 `[4/4]` 의 `included_file_warning` 이 무엇인지 알 수 있게 한다.

### WR-04: 머리말이 없는 stderr 는 어디에도 찍히지 않는다

**File:** `tool/verify.dart:739-779`, `tool/verify.dart:825-844`
**Issue:** `outcome.stderrText` 는 plugin 머리말이 있을 때(749행)와 도구가 죽었을 때(763행, 그나마 앞 두 줄만)에만 쓰인다. 종료 코드가 0 / 2 / 3 이고 JSON 이 멀쩡한데 stderr 에 머리말 아닌 무언가가 찍힌 실행은 그 내용을 통째로 버리고 정답지 비교로 넘어간다.

정상 실행의 stderr 는 비어 있다 (skill `references/ci-workflow.md`: 60번 모두 비어 있었다). 머리말 문자열은 `analysis_server` 3.13.4 의 문구에 묶여 있고, spike 008 에서 이미 한 번 "첫 줄이 아닐 수 있다" 로 가정이 바뀐 적이 있다. 문구가 바뀌거나 재지 않은 실패(skill 의 "확인하지 않은 것": plugin 이 뜬 뒤 분석 도중에 죽는 경우)가 나면, 화면은 "정답지에는 있는데 나오지 않은 경고" 와 "일부러 바꾼 것이면 정답지를 갱신하세요" 만 보여 주고 원인이 적힌 stderr 는 사라진다. 그 상태의 `--update` 는 막히지 않는다 (WR-01).

**확인 (읽기만):** 머리말 없는 stderr 를 내는 실패를 만들지 못해 실행으로는 보지 못했다. 코드에서 `stderrText` 를 읽는 곳이 위 두 군데뿐임을 확인했다.

**Fix:** stderr 가 비어 있지 않으면 정답지 비교의 실패 화면에 `scrubPaths` 를 거친 stderr 를 함께 찍고, `--update` 는 쓰지 않고 실패로 돌려준다. "도구가 죽었다" 의 `take(2)` 는 안내 문구("위의 stderr 를 확인하세요")와 맞도록 전체를 찍거나 줄 수를 넉넉히 잡는다.

### WR-05: 한 단계가 던진 예외가 실행 전체를 끝내서, 깨진 정답지는 `--update` 로도 고칠 수 없고 화면이 통째로 사라진다

**File:** `tool/verify.dart:104-106`, `tool/verify.dart:783-785`, `tool/verify.dart:591-593`, `tool/verify.dart:956-959`, `tool/verify.dart:998-1009`
**Issue:** 단계들은 `main` 의 `try` 하나 안에서 차례로 돈다. 단계가 `FormatException` / `FileSystemException` 을 던지면 그때까지 모은 `results` 는 버려지고 exit 70 으로 끝난다. "단계는 하나가 실패해도 나머지를 모두 돌린다"(941행)와 "첫 줄은 늘 `SDK` 줄이다"(902-903행)가 이 경로에서는 지켜지지 않는다. 드러나는 모양은 셋이다.

1. 정답지의 모양이 틀린 때 (merge conflict 표시가 남았거나 빈 파일). `Expected.read` 는 `update` 가지보다 **앞에서** 불리므로 `--update` 도 같은 예외로 끝난다. 정답지를 다시 만드는 명령이 정답지 때문에 돌지 않고, 화면은 무엇을 하라는 말이 없다. 메시지에는 `file.path` 가 그대로 들어가 절대 경로가 찍힌다 (`relativize` 의 "화면에 절대 경로를 남기지 않는다" 와 어긋난다).
2. `lib/analysis_options.yaml` 이 없는 때. `checkLibHasNoDart` 의 docstring(530행)은 "배포 파일이 없는 상태는 규칙 검사가 잡는다" 고 하지만 실제로는 단계 실패가 아니라 예외다.
3. `plugins:` 줄의 모양이 달라진 때 (`plugins: # 주석`). `stripPlugins` 가 `try` 밖(591행)에서 던진다.

**확인 (실행):** 모두 복사본에서.
- 정답지 맨 위에 `<<<<<<< HEAD` 를 넣고 일반 실행과 `--update` → 둘 다 `파일 모양이 예상과 다르다: 첫 줄이 \`exit N\` 이 아니다: /private/tmp/…/repo/example/expected_diagnostics.txt`, exit 70, stdout 은 비어 있음. 정답지를 빈 파일로 만든 뒤의 `--update` 도 같았다.
- `lib/analysis_options.yaml` 을 치우고 실행 → `파일 작업 실패: Cannot open file (lib/analysis_options.yaml)`, exit 70, 단계 줄 없음.
- `plugins:` 를 `plugins: # analyzer plugin` 으로 바꾸고 실행 → `… \`plugins:\` 섹션을 찾지 못했다`, exit 70, 단계 줄 없음.

**Fix:** 단계마다 예외를 실패한 `StepResult` 로 바꾼다. 종료 코드는 1 이 된다 (70 은 준비 단계와 화면 출력의 예외에만 남는다 — `example/README.md` 의 표도 함께 고친다).

```dart
for (final (index, step) in steps.indexed) {
  try {
    results.add(await step());
  } on FormatException catch (e) {
    results.add(StepResult(
      label: '단계 ${index + 1}',
      passed: false,
      detailLines: ['파일 모양이 예상과 다르다: ${scrubPaths(e.message, repoRoot)}'],
    ));
  } on FileSystemException catch (e) {
    results.add(StepResult(
      label: '단계 ${index + 1}',
      passed: false,
      detailLines: ['파일 작업 실패: ${e.message} (${relativize(e.path ?? '', repoRoot)})'],
    ));
  }
}
```

정답지는 따로 다룬다: `compareFixture` 에서 `Expected.read` 를 `try` 로 감싸, `update` 이면 `expected = null` 로 두고 "기존 정답지를 읽지 못해 새로 쓴다" 를 화면에 찍고, 아니면 상대 경로와 함께 "`git checkout -- example/expected_diagnostics.txt` 로 되돌리거나 `--update` 로 다시 만든다" 를 안내하는 실패로 돌려준다. `Expected.read` 의 메시지에는 `file.path` 대신 파일 이름만 넣는다.

### WR-06: 루트 `pubspec.yaml` 의 `version` 을 바꾸면 exit 69 가 나는데, 안내는 `example/pubspec.yaml` 을 가리키고 어긋난 패키지 이름은 버려진다

**File:** `tool/verify.dart:362-371`, `example/pubspec.lock:267-273`
**Issue:** `example/pubspec.lock` 은 path 의존성 `woody_lints` 의 버전(`2.0.0-dev`)을 적고 있다. 루트 `pubspec.yaml` 의 `version` 이 바뀌면 `dart pub get --enforce-lockfile` 이 exit 65 로 실패하고 검증은 exit 69 로 끝난다. `version` 은 릴리스(Phase 6)와 규칙 변경 때마다 바뀌는 값이다 (`.claude/CLAUDE.md`: 규칙을 더할 때 `pubspec.yaml` 의 `version` 을 함께 갱신한다).

이 실패 자체는 lock 을 엄격히 지키는 설계의 결과다. 문제는 안내다. 363-368행의 문구는 "`example/pubspec.yaml` 을 바꿨으면 …" 인데 소유자는 그 파일을 건드리지 않았다. 그리고 어느 패키지가 어긋났는지는 pub 의 **stdout** 에 찍히는데(`> woody_lints 2.0.0 from path .. (was 2.0.0-dev from path ..)`), 스크립트는 `result.stderr` 만 내보낸다(371행). 화면에 남는 것은 "Unable to satisfy `pubspec.yaml` using `pubspec.lock`" 뿐이다. `example/README.md` 에도 이 연결은 적혀 있지 않다.

**확인 (실행):** 복사본의 루트 `pubspec.yaml` 을 `version: 2.0.0` 으로 바꾸고 실행 → 위 안내와 `pub get 실패 (example/): exit 65`, exit 69. `example/` 에서 `dart pub get --no-example --enforce-lockfile` 을 직접 돌려 stdout 에 `> woody_lints 2.0.0 from path .. (was 2.0.0-dev from path ..)` 와 `Would change 1 dependency.` 가, stderr 에 "Unable to satisfy…" 가 나뉘어 찍히는 것을 봤다.

**Fix:**

```dart
if (enforceLockfile && result.exitCode == 65) {
  final name = dir.split('/').last;
  stderr.writeln(
    '`$name/pubspec.lock` 이 지금의 패키지와 맞지 않는다. '
    '`$name/pubspec.yaml` 이나 저장소 루트 `pubspec.yaml` 의 `version` 을 바꿨으면 '
    '`cd $name && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요.',
  );
  // 어느 패키지가 어긋났는지는 pub 의 stdout 에 있다 (`> 이름 새버전 (was 옛버전)`).
  stderr.writeln('${result.stdout}'.trimRight());
}
```

`example/README.md` 의 `pubspec.lock` 행과 Phase 6 의 릴리스 절차에 "루트 `version` 을 바꾸면 `example/pubspec.lock` 도 다시 받아 함께 커밋한다" 를 적는다.

### WR-07: workflow 의 `push:` 는 필터가 없어 tag push 에서도 돈다 — 주석과 D-10 은 반대로 적혀 있다

**File:** `.github/workflows/verify.yml:5-6`
**Issue:** 주석은 "필터 없음 = 모든 브랜치 (D-10). tag 트리거는 Phase 6 (REL-03)" 이다. GitHub Actions 에서 `on.push` 에 `branches` / `tags` 계열 필터를 하나도 두지 않으면 브랜치와 tag 의 push **둘 다** 에서 돈다. 하나만 두면 두지 않은 쪽에서는 돌지 않는다. 그러므로 지금 workflow 는 이미 tag push 에서 돈다 — 02-CONTEXT.md D-10 의 "tag 트리거는 이 phase 에서 넣지 않는다" 와 다르다.

지금 당장의 해는 없다 (tag 를 올리면 검증이 한 번 더 돌 뿐이다). 위험은 Phase 6 다. 주석을 믿고 "tag 트리거를 더한다" 며 `push:` 아래에 `tags: ['v*']` 만 적으면, 그 순간부터 브랜치 push 에서는 workflow 가 돌지 않는다.

**확인 (읽기만):** GitHub 의 workflow 문법 문서의 동작이다. tag 를 올려야 볼 수 있어 실행으로는 확인하지 않았다.

**Fix:** D-10 대로 브랜치만 두려면 필터를 적는다.

```yaml
on:
  # 브랜치 push 만 (D-10). tag 트리거는 Phase 6 (REL-03) 에서 `tags:` 를 **함께** 적는다 —
  # `tags:` 만 적으면 브랜치 push 에서 돌지 않는다.
  push:
    branches: ['**']
  pull_request:
  workflow_dispatch:
```

tag 에서 도는 것을 그대로 두려면 주석을 "필터 없음 = 모든 브랜치와 tag" 로 고치고 02-CONTEXT.md D-10 과의 차이를 기록한다.

## Info

### IN-01: `.fvmrc` 보다 낮은 SDK 로 실행하면 D-12 의 안내에 닿기 전에 exit 254 로 끝난다

**File:** `tool/verify.dart:311-334`, `example/README.md:71-78`
**Issue:** 이 컴퓨터에 깔린 다른 Flutter(3.41.2 / 3.41.4 / 3.41.9)는 모두 Dart 3.11 이다. 그 dart 로 실행하면 스크립트가 컴파일되지 않아 `ensurePinnedSdk` 가 불리지 않는다. "올바른 명령을 알려 준다"(D-12)와 exit 78 은 Dart 3.13 이상인 다른 SDK 에서만 나온다. 검증이 시작되지 않는다는 점은 지켜진다. README 의 종료 코드 표에는 이 경우가 없다.

**확인 (실행):** 복사본에서 `~/fvm/versions/3.41.9/bin/dart run tool/verify.dart` → `Error: The language version 3.13 specified for the package 'woody_lints' is too high. The highest supported language version is 3.11.`, exit 254. (`.dart_tool/package_config.json` 이 이미 있는 상태였다. 새로 받은 저장소에서는 `pub get` 이 먼저 실패할 것으로 보이나 재지 않았다.)

**Fix:** `example/README.md` 의 종료 코드 표 아래에 한 줄을 더한다: "그 밖의 값(254 등)과 `language version … is too high` 는 `.fvmrc` 보다 낮은 SDK 로 실행한 것이다 — `fvm dart run tool/verify.dart` 로 실행한다."

### IN-02: `include_file_not_found` 의 안내가 방금 성공한 `pub get` 을 원인으로 단정한다

**File:** `tool/verify.dart:635-640`
**Issue:** 이 가지에 닿았다면 준비 3 의 루트 `pub get` 은 이미 성공했다 (실패했으면 exit 69 로 끝났다). 그런데 문구는 "루트 `pub get` 이 안 되어 규칙 검사를 하지 못했다" 이고 다음에 할 일로 `fvm dart pub get` 을 시킨다. 실제로 이 가지에 오는 원인은 배포 파일의 `include:` URI 가 틀렸거나 루트 `pubspec.yaml` 에서 `flutter_lints` 가 빠진 경우다.

**확인 (실행):** 복사본의 배포 파일에서 `flutter.yaml` 을 `fluter.yaml` 로 바꾸고 실행 → `[2/4] 실패` 와 위 문구, `build/woody_rule_check/analysis_options.yaml:13  warning  include_file_not_found`.

**Fix:** 문구를 사실만 적도록 바꾼다: "복사본의 include 가 풀리지 않아 규칙을 보지 못했다. `lib/analysis_options.yaml` 의 `include:` 경로와 루트 `pubspec.yaml` 의 `dependencies` 를 확인하세요."

### IN-03: 코드가 아는 것보다 많이 말하는 문구와 주석

**File:** `tool/verify.dart:412-416`, `tool/verify.dart:588`, `tool/verify.dart:611-615`
**Issue:**
- 412-416행: plugin 폴더가 둘 이상이면 "저장소 경로가 바뀐 적 있다" 고 단정한다. 코드가 아는 것은 "폴더가 둘 이상" 뿐이다. 복사본에서 `.plugin_manager` 에 빈 폴더를 하나 만들기만 해도 이 문구가 나왔다 (실행). skill 도 이 경우를 "직접 재지는 않았다" 로 적었다.
- 588행: "복사본은 어떤 경우에도 지운다" — `finally` 는 예외와 `return` 에서만 돈다. 규칙 검사 도중의 Ctrl-C 에서는 `build/woody_rule_check/` 가 남는다 (읽기만). 다음 실행이 덮어쓰고 지우며 `.gitignore` 가 막고 있어 해는 없다.
- 611-615행: 규칙 검사의 `stderrHead` 는 `scrubPaths` 를 거치지 않는다. 같은 모양의 763-766행은 거친다 (읽기만).

**Fix:** "저장소 경로가 바뀐 적이 있을 수 있다 (plugin 폴더가 N개다)" 로 바꾸고, 588행은 "예외로 끝나도 지운다 (Ctrl-C 에서는 남을 수 있고 다음 실행이 지운다)" 로, 611행에는 `scrubPaths(…, repoRoot)` 를 넣는다.

### IN-04: workflow 의 action 이 움직이는 tag 로 지정되어 있다

**File:** `.github/workflows/verify.yml:26`, `.github/workflows/verify.yml:29`
**Issue:** `actions/checkout@v7` 과 제3자 action `subosito/flutter-action@v2` 가 major tag 로 지정되어 있다. tag 는 가리키는 커밋이 바뀔 수 있다. 권한이 `contents: read` 이고 secret 을 쓰지 않으므로 영향은 "CI 판정을 믿을 수 있는가" 에 그친다.

**확인 (읽기만).**

**Fix:** 고정하려면 전체 commit SHA 로 적고 버전을 주석으로 남긴다 (`uses: subosito/flutter-action@<sha> # v2.23.0`). `actions/checkout` 에 `with: persist-credentials: false` 를 더하면 token 이 `.git/config` 에 남지 않는다.

### IN-05: PR 을 열면 같은 커밋에 실행이 둘 돌고 `concurrency` 가 서로를 취소하지 않는다

**File:** `.github/workflows/verify.yml:6-7`, `.github/workflows/verify.yml:16-18`
**Issue:** 같은 저장소의 브랜치로 PR 을 열면 `push` 와 `pull_request` 가 각각 실행을 만든다. `group` 의 `github.ref` 가 앞의 것은 `refs/heads/<브랜치>`, 뒤의 것은 `refs/pull/<번호>/merge` 라 묶음이 다르다. D-10 의 "겹치는 실행은 `concurrency` 로 자동 취소한다" 는 같은 종류의 실행끼리만 해당한다. 약 2분짜리 실행이 한 번 더 도는 것이 전부다.

**확인 (읽기만):** 이 저장소에는 아직 PR 이 없다.

**Fix:** 그대로 두어도 된다. 줄이려면 `group: ${{ github.workflow }}-${{ github.head_ref || github.ref_name }}` 로 브랜치 이름에 묶는다.

### IN-06: `pluginFolders` 는 동사로 시작하지 않는다

**File:** `tool/verify.dart:393`
**Issue:** 소유자의 전역 규칙은 "함수명: 동사로 시작" 이다. 이 파일의 다른 함수는 `read…` / `check…` / `format…` / `find…` 로 시작하는데 spike 에서 옮겨 온 `pluginFolders` 만 명사다.

**확인 (읽기만).**

**Fix:** `listPluginFolders` 로 바꾼다 (부르는 곳은 405행 하나).

---

_Reviewed: 2026-10-11T17:33:34Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
