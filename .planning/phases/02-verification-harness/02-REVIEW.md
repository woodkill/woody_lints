---
phase: 02-verification-harness
reviewed: 2026-10-12T01:25:47Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - .github/workflows/verify.yml
  - example/README.md
  - tool/verify.dart
findings:
  critical: 0
  warning: 7
  info: 8
  total: 15
status: issues_found
---

# Phase 2: Code Review Report

**Reviewed:** 2026-10-12T01:25:47Z
**Depth:** standard
**Files Reviewed:** 3
**Status:** issues_found

## Summary

재리뷰다. 지난 리뷰(`1483194`, 발견 14건) 뒤에 gap 닫기 plan 02-05 (`37316e3`, `40776b5`, `008ea3f`) 가 바꾼 세 파일을 HEAD `fd76e7a` 기준으로 다시 읽고, 지난 발견 14건을 하나씩 지금 코드에서 다시 판정했다. 새로 들어간 코드(`subtractLines` / `findDifference`, `countDeclaredRules`, `main` 의 `--update` 쓰기 확인)와 README 의 새 문장 · M10 ~ M14 기록, workflow 주석도 따로 봤다.

실측 조건: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, macOS arm64, 2026-10-12. 저장소에서는 `fvm dart run tool/verify.dart` (4단계 통과, exit 0, 5.9초) 와 `fvm dart analyze` (No issues found) 만 돌렸다. 입력을 바꾼 실행은 전부 저장소 밖의 복사본(`git archive HEAD` 로 만든 scratchpad 폴더)에서 했다. 저장소의 추적 파일은 고치지 않았다.

결론.

- **CR-01 은 닫혔다.** 건수를 세는 차집합이 두 방향 모두에서 실패를 낸다 (M10 · M11 을 복사본에서 다시 재현했다). 정답지에 같은 줄이 2개인데 실제가 2건이면 통과, 3개면 다시 실패한다. 새 critical 은 없다.
- **WR-07 은 닫혔다.** workflow 주석이 실제 동작을 말하고 D-10 아래에 덧붙임이 있다. 주석 밖의 YAML 은 바뀌지 않았다.
- **WR-01 · WR-03 은 일부만 닫혔다.** 계획이 범위를 그렇게 잡았고 README 의 "막지 않는 것" 불릿이 남은 부분을 적어 두었다.
- **새 `--update` 안전장치는 "다른 단계가 실패했는가" 만 본다.** 그래서 `[2/4]` 가 통과로 잘못 찍히는 입력(WR-02 의 깨진 YAML, WR-03 의 남은 절반)에서는 여전히 망가진 결과가 정답지로 들어가고 종료 코드 0 · `점검 통과 (4개 중 4개)` 로 끝난다. 복사본에서 둘 다 다시 봤다.
- **새 발견 3건.** `countDeclaredRules` 는 `rules:` 키를 보지 않아 README 와 실패 문구가 말한 것보다 좁게 잡고(WR-08), 반대로 멀쩡한 YAML 몇 가지 모양을 0개로 센다(IN-07). `--update` 쓰기 반복문은 fixture 가 둘 이상이 될 때의 모양이 정해져 있지 않다(IN-08).

실행으로 확인했고 **문제가 없었던 것** (발견이 아니다).

| 확인한 것 | 결과 |
|---|---|
| M10 — 정답지에 `lib/base_rules.dart:22  info  avoid_print` 를 한 번 더 적음 | `[4/4]` 실패, `나오지 않은 경고 (1)`, exit 1 |
| M10 상태에서 `--update` | `- ` 한 줄을 보여 준 뒤 `정답지를 썼다: example/expected_diagnostics.txt`, exit 0. 쓴 파일은 원래 정답지와 같았다 (`diff` 로 확인) |
| M11 — 한 줄에 `print` 둘, 정답지에는 1줄 / 2줄 / 3줄 | 1줄: `정답지에 없는데 나온 경고 (1)` exit 1. 2줄: 통과 exit 0. 3줄: `나오지 않은 경고 (1)` exit 1 |
| M12 — `example/analysis_options.yaml` 을 비우고 `--update` | `[3/4]` 실패, `다른 단계가 실패해 정답지를 쓰지 않았다 …`, exit 1, 정답지는 그대로 (`diff`) |
| M13 — `linter:` → `lintr:` | `[2/4]` 실패(규칙 0개 문구) + `[4/4]` 실패(`lib/added_rules.dart` 의 6줄), `점검 실패 (4개 중 2개)`, exit 1 |
| M14 — 규칙 블록을 `lib/_probe_rules.yaml` 로 옮기고 include | `[2/4]` 만 실패, `[4/4]` 통과, exit 1 |
| 변경 없이 `--update --update` | 한 번 쓰고 exit 0. 정답지 내용은 그대로 (날짜가 같은 날이라 머리 주석도 같다) |
| `git diff 1483194..HEAD -- .github/workflows/verify.yml` | 주석 1줄 → 3줄. 키 · 값은 그대로 |
| `.planning/phases/02-verification-harness/02-CONTEXT.md:82` | `덧붙임 (2026-10-12, gap 닫기 02-05)` 한 줄이 D-10 아래에 있다 |

돌리지 못한 것: tag push 와 PR 에서의 workflow 동작(WR-07 · IN-05 — GitHub 에 올려야 볼 수 있다), 머리말 없는 stderr 를 내는 분석 실패(WR-04), fixture 가 둘 이상인 실행(IN-08 — `fixtures` 가 지금 하나다).

## 지난 리뷰(1483194)의 발견 14건 — 지금 상태

| ID | 지금 상태 | 근거 |
|----|-----------|------|
| CR-01 | 해당 없음 (닫힘) | `37316e3` — `subtractLines` (`tool/verify.dart:475-490`), `findDifference` (`:510-514`). 복사본에서 M10 · M11 이 exit 1, 정답지 2줄 · 실제 2건은 exit 0 |
| WR-01 | 일부 남음 | case 1 닫힘 (`40776b5`, `tool/verify.dart:1066-1078`; M12 재현 — 쓰지 않음, exit 1). case 2 남음: `.plugin_manager` 에 빈 폴더를 더하고 `--update` → `riverpod_lint ?` 로 쓰고 exit 0 |
| WR-02 | 그대로 | `tool/verify.dart:669`, `:719-722`, `:838`. 닫지 않은 따옴표 → `[2/4] 통과`, `종료 코드: 정답지 2, 실제 3`. 이어서 `--update` → `exit 3` + 1줄짜리 정답지를 쓰고 exit 0 |
| WR-03 | 일부 남음 | "규칙 0개" 절반은 닫힘 (`40776b5`, `:703-717`; M13 · M14 재현). 세 코드 밖의 진단은 그대로 버린다 (`:719-722`) — 중복 규칙 등 3건을 넣으면 `[2/4] 통과` |
| WR-04 | 그대로 | `tool/verify.dart:816`, `:825-828`, `:839-842` — `stderrText` 를 읽는 곳이 여전히 이 셋뿐이다 (읽기만) |
| WR-05 | 그대로 | `tool/verify.dart:1035-1038`, `:1087-1098`. 정답지에 `<<<<<<< HEAD` → 일반 실행 · `--update` 모두 exit 70, 절대 경로가 찍힘. 배포 파일 없음 · `plugins: # 주석` 도 exit 70 |
| WR-06 | 그대로 | `tool/verify.dart:371-380`. 루트 `version: 2.0.0` → "`example/pubspec.yaml` 을 바꿨으면 …" + exit 69, 어긋난 패키지 이름은 나오지 않음 |
| WR-07 | 해당 없음 (닫힘) | `008ea3f` — `.github/workflows/verify.yml:5-7` 의 주석이 "모든 브랜치와 tag 의 push" 와 Phase 6 경고를 말한다. 02-CONTEXT.md:82 에 덧붙임. 동작은 소유자 결정으로 그대로 |
| IN-01 | 그대로 | `~/fvm/versions/3.41.9/bin/dart run tool/verify.dart` → `language version 3.13 … is too high`, exit 254. `example/README.md:72-79` 의 표에 이 경우가 없다 |
| IN-02 | 그대로 | `tool/verify.dart:691-699`. `flutter.yaml` → `fluter.yaml` → "루트 `pub get` 이 안 되어 …" 문구 그대로 |
| IN-03 | 그대로 | `tool/verify.dart:421-425`, `:647`, `:670-674` — 세 곳 모두 문구 · 코드가 바뀌지 않았다. 첫째는 빈 폴더 하나로 "저장소 경로가 바뀐 적 있다" 가 다시 나왔다 |
| IN-04 | 그대로 | `.github/workflows/verify.yml:28`, `:31` — `@v7`, `@v2` (읽기만) |
| IN-05 | 그대로 | `.github/workflows/verify.yml:8-9`, `:18-20` (읽기만) |
| IN-06 | 그대로 | `tool/verify.dart:402` — `pluginFolders`, 부르는 곳 `:414` (읽기만) |

## Narrative Findings (AI reviewer)

아래 `## Warnings`, `## Info` 가 직접 읽고 돌려서 판정한 것이다. 구조 분석(fallow) 입력과 외부 리뷰어 증거는 받지 않았다. 지난 리뷰에서 넘어온 항목은 ID 와 제목을 그대로 두고 본문만 지금 코드에 맞췄다. 새 항목은 WR-08, IN-07, IN-08 이다. 항목마다 "확인" 줄에 실행으로 본 것인지 읽기로만 본 것인지 적었다. 실행은 모두 복사본에서 했다.

## Warnings

### WR-01: `--update` 가 같은 실행에서 실패가 난 뒤에도, plugin 버전을 읽지 못한 때에도 정답지를 쓴다

**File:** `tool/verify.dart:865-893`, `tool/verify.dart:1066-1078`
**Issue:** 지난 리뷰가 든 두 경우 중 하나만 남았다.

- **닫힌 부분 (`40776b5`).** case 1 — 같은 실행의 다른 단계가 실패한 때. `main` 이 쓰기 직전에 `failed` 를 보고(1066-1071행) 쓰지 않는다. 화면의 줄도 `정답지 갱신 대상:` (쓰기 전) 과 `정답지를 썼다:` (쓴 뒤) 로 나뉘어, 지난 리뷰가 지적한 "쓰지 않았는데 `정답지 갱신:` 이 찍힌다" 도 없어졌다. 머리 주석에 그 실행에서 돌지 않은 plugin 의 버전이 "실측" 으로 들어가던 것도, 쓰지 않으므로 생기지 않는다.
- **남은 부분.** case 2 — plugin 버전이 `?` 인 때. 단계 4개가 모두 통과하면 `--update` 는 머리 주석에 `riverpod_lint ?` 를 적고 exit 0 으로 끝난다. 계획 02-05 가 일부러 범위 밖에 둔 것이고(`prohibitions` 둘째 항목 — Phase 3 의 plugin 없는 fixture 에 영향) `example/README.md:158` 이 이 한계를 적어 두었다. README 는 "이번에 다시 재지 않았다" 고 했는데 이 리뷰에서 다시 쟀고 그대로였다.

덧붙여, 새 확인은 "실패로 찍힌 단계가 있는가" 만 본다. 단계가 통과로 **잘못** 찍히는 입력에서는 안전장치가 듣지 않는다 — WR-02 와 WR-03 의 확인 줄에 그 실행을 적었다.

**확인 (실행):**
- `example/analysis_options.yaml` 을 빈 파일로 두고 `--update` → `[3/4] 실패`, `다른 단계가 실패해 정답지를 쓰지 않았다 — 실패를 먼저 고친 뒤 다시 실행하세요.`, exit 1, 정답지는 실행 전과 같았다 (`diff`).
- `.dart_tool/woody_verify/example/.plugin_manager/` 에 빈 폴더 하나를 더 만들고 `--update` → `plugin     riverpod_lint ? (저장소 경로가 바뀐 적 있다 — …)`, `정답지와 같다 — 바뀐 줄 없음`, `정답지를 썼다: example/expected_diagnostics.txt`, exit 0. 정답지 첫 줄이 `# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint ?, 2026-10-12` 로 바뀌었다.

**Fix:** `compareFixture` 의 `update` 가지 앞에 한 가지를 둔다. Phase 3 에서 plugin 이 없는 fixture 가 생기면 그 fixture 에서는 이 가지를 건너뛰게 한다 (fixture 별 설정).

```dart
if (update && plugin.version == null) {
  return StepResult(
    label: label,
    passed: false,
    plugin: plugin,
    detailLines: ['plugin 버전을 읽지 못해 정답지를 쓰지 않는다: ${plugin.reason}'],
  );
}
```

넣지 않기로 한 결정을 유지한다면, 적어도 쓰는 순간 화면에 `머리 주석에 plugin 버전이 ? 로 들어간다` 한 줄을 더해 커밋 전에 눈에 띄게 한다.

### WR-02: `dart analyze` 의 종료 코드와 JSON 이 어긋나는 것을 보지 않아, 규칙 이름 단계가 YAML 이 깨진 배포 파일을 "통과" 로 찍는다

**File:** `tool/verify.dart:669`, `tool/verify.dart:719-722`, `tool/verify.dart:838`
**Issue:** 02-05 는 이 항목을 건드리지 않았고 동작은 그대로다. `dart analyze --format=json` 은 옵션 파일의 error 강도 진단을 JSON 에 싣지 않는다. 배포 파일의 YAML 이 깨지면 규칙 검사의 분석은 진단 0건과 exit 3 을 내고, 스크립트는 3 을 정상 종료 코드로 받아(669행) 문제 줄이 0건이라 `passed: true` 를 돌려준다(722행).

새로 들어간 규칙 수 확인(`countDeclaredRules`, 705행)도 이 경우를 잡지 못한다. 그 함수는 analyzer 가 읽은 규칙이 아니라 **본문의 글자**를 센다. 깨진 줄 하나를 뺀 나머지 11줄이 `- 이름` 꼴이라 11 을 돌려주고 단계는 통과한다 — analyzer 는 그 파일에서 규칙을 하나도 읽지 못했는데도.

그리고 새 `--update` 안전장치(WR-01 의 닫힌 부분)가 이 경로를 막지 못한다. `[2/4]` 가 통과로 찍히므로 "다른 단계가 실패했는가" 가 거짓이고, `--update` 는 줄에 error 가 없는데 `exit 3` 인 정답지를 쓰고 `점검 통과 (4개 중 4개)` · exit 0 으로 끝난다. 바뀌는 줄 17개는 쓰기 전에 화면에 나오므로 조용한 덮어쓰기는 아니다. 다만 `example/README.md:30` 의 "같은 실행에서 다른 단계가 실패했으면 정답지를 쓰지 않는다" 를 읽은 사람은 배포 파일이 깨진 실행도 막힌다고 기대하기 쉽다. 02-05 가 닫으려던 "망가진 실행이 정답으로 굳는다" 가 이 입력에서는 남아 있어, 남은 warning 중에서는 이것을 먼저 고칠 만하다.

**확인 (실행):** 배포 파일의 `- prefer_final_locals` 를 `- 'prefer_final_locals` (닫지 않은 따옴표)로 바꿨다.
- 일반 실행 → `[2/4] 통과`, `[4/4] 실패`, `종료 코드: 정답지 2, 실제 3`, 나오지 않은 경고 16건 + `lib/should_not_appear.dart:5  warning  invalid_annotation_target`, exit 1. `parse_error` 는 화면 어디에도 없다.
- 같은 상태에서 `--update` → 단계 넷 모두 `통과`, `정답지를 썼다: example/expected_diagnostics.txt`, `점검 통과 (4개 중 4개)`, exit 0. 쓰인 정답지는 머리 주석 2줄 + `exit 3` + `lib/should_not_appear.dart:5  warning  invalid_annotation_target` 한 줄이었다.

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

어긋나면 실패로 돌려주고 이렇게 안내한다: "dart analyze 가 JSON 에 싣지 않은 진단이 있다 (옵션 파일의 error). `fvm dart analyze` 를 `<폴더>` 에서 직접 돌려 확인하세요." `checkRuleNames` 에서 이 실패가 나면 새 안전장치가 `--update` 를 알아서 막는다. `compareFixture` 에서는 `update` 가지 앞에 두어 `applyUpdate` 를 돌려주지 않게 한다.

### WR-03: 규칙 이름 단계가 세 코드 밖의 진단을 모두 버리고, 규칙을 하나도 읽지 못해도 통과한다

**File:** `tool/verify.dart:719-722` (남은 부분), `tool/verify.dart:703-717` (닫힌 부분)
**Issue:** 제목의 두 절 중 뒤 절은 대부분 닫혔고 앞 절은 그대로다.

- **닫힌 부분 (`40776b5`).** "규칙을 하나도 읽지 못해도 통과한다" — `countDeclaredRules` 가 0 이면 `[2/4]` 가 실패한다. `linter:` 키의 오타(M13)와 규칙을 다른 파일로 옮긴 모양(M14)에서 실패하는 것을 다시 봤다. 이 확인이 놓치는 모양은 새 항목 WR-08 에, 잘못 실패하는 모양은 IN-07 에 따로 적었다.
- **남은 부분.** "세 코드 밖의 진단을 모두 버린다" — 복사본에 대한 분석이 낸 warning 중 `deprecated_lint` / `removed_lint` / `undefined_lint` (와 `include_file_not_found`) 로 끝나지 않는 줄은 읽고 버린다. 그 문제들은 `[4/4]` 에서 줄 번호도 이름도 없는 `analysis_options.yaml:1  warning  included_file_warning` 으로만 다시 나타난다. 줄 번호와 코드를 아는 쪽은 `[2/4]` 인데 그쪽이 통과를 찍는다. 계획 02-05 가 일부러 넣지 않은 절반이고(`prohibitions` 셋째 항목) `example/README.md:158` 이 적어 두었다.

CR-01 이 닫히면서 달라진 점이 하나 있다. 똑같은 `included_file_warning` 줄이 여러 개여도 이제 건수 변화는 `[4/4]` 가 잡는다. 무엇이 문제인지 알 수 없다는 점은 그대로다.

이 경로에서도 새 `--update` 안전장치는 듣지 않는다 (`[2/4]` 가 통과이므로). `--update` 는 `included_file_warning` 3줄을 정답지에 넣고 exit 0 으로 끝난다.

**확인 (실행):** 배포 파일의 `errors:` 아래에 `no_such_diagnostic_code: ignore`, 규칙 목록 끝에 `- avoid_print` (중복)과 `- prefer_double_quotes` 를 더했다.
- 일반 실행 → `[2/4] 통과`, `[4/4] 실패` — `정답지에 없는데 나온 경고 (11)`: 똑같은 `analysis_options.yaml:1  warning  included_file_warning` 3줄 + `prefer_double_quotes` 8줄. exit 1.
- 같은 상태에서 `--update` → `+ ` 11줄을 보여 준 뒤 `정답지를 썼다: …`, `점검 통과 (4개 중 4개)`, exit 0. 정답지는 27줄이 되었고 `included_file_warning` 이 3줄 들어갔다.

**Fix:** 복사본에 대한 진단 가운데 세 코드에 들지 않는 것을 버리지 않는다.

```dart
final others = lines
    .where((l) => !ruleProblemCodes.any((code) => l.endsWith('  $code')))
    .toList();
// problems 와 others 중 하나라도 있으면 passed: false.
// others 는 '배포 파일의 다른 경고 (N)' 아래에 줄 번호 · 코드 그대로 찍는다.
```

실패로 치지 않기로 한 결정을 유지한다면, 통과로 두더라도 `others` 를 `detailLines` 에 찍어 `[4/4]` 의 `included_file_warning` 이 무엇인지 화면에서 이어지게 한다.

### WR-04: 머리말이 없는 stderr 는 어디에도 찍히지 않는다

**File:** `tool/verify.dart:816`, `tool/verify.dart:825-828`, `tool/verify.dart:839-842`
**Issue:** 02-05 는 이 항목을 건드리지 않았다. `outcome.stderrText` 는 plugin 머리말이 있을 때(816행의 `hasPluginHeader`, 825-828행)와 도구가 죽었을 때(839-842행, 앞 두 줄만)에만 쓰인다. 종료 코드가 0 / 2 / 3 이고 JSON 이 멀쩡한데 stderr 에 머리말 아닌 무언가가 찍힌 실행은 그 내용을 버리고 정답지 비교로 넘어간다.

정상 실행의 stderr 는 비어 있다 (skill `references/ci-workflow.md`). 머리말 문자열은 `analysis_server` 3.13.4 의 문구에 묶여 있고, spike 008 에서 한 번 "첫 줄이 아닐 수 있다" 로 가정이 바뀐 적이 있다. 문구가 바뀌거나 재지 않은 실패가 나면 화면은 "나오지 않은 경고" 와 "일부러 바꾼 것이면 정답지를 갱신하세요" 만 보여 주고 원인이 적힌 stderr 는 사라진다. 그 실행은 "단계 실패" 가 아니라 정답지와의 차이로만 보이므로, `--update` 에서는 새 안전장치를 지나 그대로 쓰인다.

**확인 (읽기만):** 머리말 없는 stderr 를 내는 실패를 만들지 못해 실행으로는 보지 못했다. `stderrText` 를 읽는 곳이 위 세 군데뿐임을 지금 코드에서 다시 확인했다.

**Fix:** stderr 가 비어 있지 않으면 정답지 비교의 실패 화면에 `scrubPaths` 를 거친 stderr 를 함께 찍고, `--update` 는 `applyUpdate` 를 돌려주지 않고 실패로 돌려준다. "도구가 죽었다" 의 `take(2)` 는 안내 문구("위의 stderr 를 확인하세요")와 맞도록 전체를 찍거나 줄 수를 넉넉히 잡는다.

### WR-05: 한 단계가 던진 예외가 실행 전체를 끝내서, 깨진 정답지는 `--update` 로도 고칠 수 없고 화면이 통째로 사라진다

**File:** `tool/verify.dart:105-107`, `tool/verify.dart:858-861`, `tool/verify.dart:650-652`, `tool/verify.dart:1035-1038`, `tool/verify.dart:1087-1098`
**Issue:** 02-05 는 이 항목을 건드리지 않았다. 단계들은 `main` 의 `try` 하나 안에서 차례로 돈다(1035-1038행). 단계가 `FormatException` / `FileSystemException` 을 던지면 그때까지 모은 `results` 는 버려지고 exit 70 으로 끝난다. "단계는 하나가 실패해도 나머지를 모두 돌린다"(1020행)와 "첫 줄은 늘 `SDK` 줄이다"(981-982행)가 이 경로에서는 지켜지지 않는다.

1. 정답지의 모양이 틀린 때 (merge conflict 표시가 남았거나 빈 파일). `Expected.read` 는 `update` 가지보다 앞(858-861행)에서 불리므로 `--update` 도 같은 예외로 끝난다. 메시지에 `file.path` 가 그대로 들어가 절대 경로가 찍힌다(106행).
2. `lib/analysis_options.yaml` 이 없는 때. `checkLibHasNoDart` 의 docstring(564행)은 "배포 파일이 없는 상태는 규칙 검사가 잡는다" 고 하지만 실제로는 단계 실패가 아니라 예외다.
3. `plugins:` 줄의 모양이 달라진 때. `stripPlugins` 가 `try` (654행) 밖인 650-652행에서 던진다. `plugins: # 주석` 말고도, 배포 파일의 줄 끝이 CRLF 이면 같은 예외가 난다 (정규식이 `plugins:\n` 을 찾는다) — 이번에 새로 본 모양이다.

새 규칙 수 확인(705행)은 이 예외들 **뒤**에 있어서, "배포 파일을 읽지 못했다" 를 단계 실패로 바꿔 주지 않는다.

**확인 (실행):**
- 정답지 맨 위에 `<<<<<<< HEAD` 를 넣고 일반 실행과 `--update` → 둘 다 `파일 모양이 예상과 다르다: 첫 줄이 \`exit N\` 이 아니다: /private/tmp/…/repo/example/expected_diagnostics.txt`, exit 70, stdout 은 비어 있음. 정답지를 빈 파일로 만든 뒤의 `--update` 도 같았다.
- `lib/analysis_options.yaml` 을 치우고 실행 → `파일 작업 실패: Cannot open file (lib/analysis_options.yaml)`, exit 70, 단계 줄 없음.
- `plugins:` 를 `plugins: # analyzer plugin` 으로 바꾸고 실행 → `… \`plugins:\` 섹션을 찾지 못했다`, exit 70, 단계 줄 없음.
- 배포 파일의 줄 끝을 모두 CRLF 로 바꾸고 실행 → 같은 `\`plugins:\` 섹션을 찾지 못했다`, exit 70.

**Fix:** 단계마다 예외를 실패한 `StepResult` 로 바꾼다. 종료 코드는 1 이 된다 (70 은 준비 단계와 화면 출력의 예외에만 남는다 — `example/README.md:78` 의 표도 함께 고친다). 이렇게 하면 새 `--update` 안전장치가 이 실패도 "다른 단계가 실패" 로 본다.

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

정답지는 따로 다룬다: `compareFixture` 에서 `Expected.read` 를 `try` 로 감싸, `update` 이면 `expected = null` 로 두고 "기존 정답지를 읽지 못해 새로 쓴다" 를 화면에 찍고, 아니면 상대 경로와 함께 "`git checkout -- example/expected_diagnostics.txt` 로 되돌리거나 `--update` 로 다시 만든다" 를 안내하는 실패로 돌려준다. `Expected.read` 의 메시지에는 `file.path` 대신 파일 이름만 넣는다. `stripPlugins` 의 정규식은 `\r?\n` 을 받게 한다.

### WR-06: 루트 `pubspec.yaml` 의 `version` 을 바꾸면 exit 69 가 나는데, 안내는 `example/pubspec.yaml` 을 가리키고 어긋난 패키지 이름은 버려진다

**File:** `tool/verify.dart:371-380`, `example/pubspec.lock:267-273`
**Issue:** 02-05 는 이 항목을 건드리지 않았다. `example/pubspec.lock` 은 path 의존성 `woody_lints` 의 버전(`2.0.0-dev`)을 적고 있다. 루트 `pubspec.yaml` 의 `version` 이 바뀌면 `dart pub get --enforce-lockfile` 이 exit 65 로 실패하고 검증은 exit 69 로 끝난다. `version` 은 릴리스(Phase 6)와 규칙 변경 때마다 바뀌는 값이다.

실패 자체는 lock 을 엄격히 지키는 설계의 결과다. 문제는 안내다. 374-377행의 문구는 "`example/pubspec.yaml` 을 바꿨으면 …" 인데 소유자는 그 파일을 건드리지 않았다. 어느 패키지가 어긋났는지는 pub 의 **stdout** 에 찍히는데 스크립트는 `result.stderr` 만 내보낸다(380행). `example/README.md:47` 의 `pubspec.lock` 행에도 이 연결은 적혀 있지 않다.

**확인 (실행):** 루트 `pubspec.yaml` 을 `version: 2.0.0` 으로 바꾸고 실행 → `` `example/pubspec.yaml` 을 바꿨으면 `cd example && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요. ``, `pub get 실패 (example/): exit 65`, `Unable to satisfy \`pubspec.yaml\` using \`pubspec.lock\`.`, exit 69. `woody_lints` 라는 이름은 화면에 나오지 않았다. (pub 의 stdout 에 패키지 이름이 찍힌다는 것은 지난 리뷰의 실측이고 이번에는 stdout 을 따로 받아 보지 않았다.)

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

### WR-08: 규칙 수 세기가 `rules:` 키를 보지 않아, `rules:` 를 잘못 적어 규칙이 하나도 적용되지 않는 배포 파일에서 `[2/4]` 가 통과한다

**File:** `tool/verify.dart:622-637`, `tool/verify.dart:705-717`, `example/README.md:81`
**Issue:** 02-05 가 넣은 `countDeclaredRules` 는 최상위 `linter:` 블록 안의 `- 이름` 꼴 줄을 센다. 그 줄들이 `rules:` 아래에 있는지는 보지 않고, analyzer 가 실제로 읽은 규칙 수와도 무관하다. 그래서 `linter:` 는 맞고 그 아래 키가 틀린 파일은 규칙 12개로 세어져 통과한다. analyzer 는 그 파일에서 규칙을 하나도 켜지 않는다.

이 단계의 docstring(641-642행)은 "검사가 본 것이 없는데 '문제 없음' 으로 넘기지 않는다" 를 목적으로 적었고, 실패 문구(710-711행)와 `example/README.md:81` 은 조건을 "최상위 `linter:` 아래 `rules:` 목록이 비어 있거나 없으면" 이라고 말한다. `rules:` 가 **없는** 이 입력에서 단계는 통과한다 — 문장이 코드보다 많이 말한다. M13 이 잡은 것은 `linter:` 의 오타이고 `rules:` 의 오타는 M13 · M14 어느 것도 재지 않았다.

전체 판정은 `[4/4]` 가 실패시켜 준다 (규칙 6줄이 사라지고 `included_file_warning` 한 줄이 생긴다). 그러나 원인을 아는 단계가 통과를 찍는 것은 WR-03 의 남은 절반과 같은 모양이고(analyzer 는 이 오타를 `unsupported_option` warning 으로 정확히 짚는데 그 줄이 버려진다), `[2/4]` 가 통과이므로 `--update` 안전장치도 듣지 않는다.

**확인 (실행):** 배포 파일의 `  rules:` 를 `  rulez:` 로 바꿨다.
- 검증 명령 → `[2/4] 통과`, `[4/4] 실패` — 나오지 않은 경고 6건(`lib/added_rules.dart` 의 6줄), `정답지에 없는데 나온 경고 (1)`: `analysis_options.yaml:1  warning  included_file_warning`. exit 1.
- 같은 내용(`plugins:` 를 뺀 것)을 저장소 안의 폴더에 `analysis_options.yaml` 로 두고 `dart analyze` 를 직접 돌림 → `warning - analysis_options.yaml:21:3 - The option 'rulez' isn't supported by 'linter'. … - unsupported_option`. 규칙 검사의 분석이 이 줄을 받고도 버린다는 뜻이다.
- 이 상태의 `--update` 는 돌리지 않았다 (읽기로는 WR-03 의 실행과 같은 경로로 쓰인다).

**Fix:** 둘 중 하나.

1. WR-03 의 남은 절반을 고친다 — 세 코드 밖의 진단이 하나라도 있으면 실패로 치면 `unsupported_option` 이 이 단계에서 줄 번호와 함께 잡힌다. 글자를 세는 쪽을 더 정교하게 만드는 것보다 analyzer 의 답을 쓰는 편이 정확하다.
2. 세는 쪽을 유지한다면 `rules:` 아래만 센다.

```dart
var inRules = false;
for (final line in options.split('\n')) {
  if (RegExp(r'^linter:').hasMatch(line)) {
    inLinter = true;
    inRules = false;
  } else if (RegExp(r'^\S').hasMatch(line) && !line.startsWith('#')) {
    inLinter = false; // 최상위 주석은 블록을 닫지 않는다 (IN-07)
  } else if (inLinter && RegExp(r'^\s+rules:').hasMatch(line)) {
    inRules = true;
  } else if (inLinter && inRules && rulePattern.hasMatch(line)) {
    count++;
  }
}
```

어느 쪽이든 `example/README.md:81` 과 710-711행의 문구를 코드가 실제로 보는 것에 맞춘다 (지금 코드 그대로 둔다면: "최상위 `linter:` 블록에 `- 규칙이름` 꼴 줄이 하나도 없으면").

## Info

### IN-01: `.fvmrc` 보다 낮은 SDK 로 실행하면 D-12 의 안내에 닿기 전에 exit 254 로 끝난다

**File:** `tool/verify.dart:320-343`, `example/README.md:72-79`
**Issue:** 그대로다. 이 컴퓨터에 깔린 다른 Flutter(3.41.2 / 3.41.4 / 3.41.9)는 모두 Dart 3.11 이다. 그 dart 로 실행하면 스크립트가 컴파일되지 않아 `ensurePinnedSdk` 가 불리지 않는다. "올바른 명령을 알려 준다"(D-12)와 exit 78 은 Dart 3.13 이상인 다른 SDK 에서만 나온다. 검증이 시작되지 않는다는 점은 지켜진다. README 의 종료 코드 표에는 이 경우가 없다.

**확인 (실행):** 복사본에서 `~/fvm/versions/3.41.9/bin/dart run tool/verify.dart` → `Error: The language version 3.13 specified for the package 'woody_lints' is too high. The highest supported language version is 3.11.`, exit 254. (`.dart_tool/package_config.json` 이 이미 있는 상태였다.)

**Fix:** `example/README.md` 의 종료 코드 표 아래에 한 줄을 더한다: "그 밖의 값(254 등)과 `language version … is too high` 는 `.fvmrc` 보다 낮은 SDK 로 실행한 것이다 — `fvm dart run tool/verify.dart` 로 실행한다."

### IN-02: `include_file_not_found` 의 안내가 방금 성공한 `pub get` 을 원인으로 단정한다

**File:** `tool/verify.dart:691-699`
**Issue:** 그대로다. 이 가지에 닿았다면 준비 3 의 루트 `pub get` 은 이미 성공했다 (실패했으면 exit 69 로 끝났다). 그런데 문구는 "루트 `pub get` 이 안 되어 규칙 검사를 하지 못했다" 이고 다음에 할 일로 `fvm dart pub get` 을 시킨다. 실제로 이 가지에 오는 원인은 배포 파일의 `include:` URI 가 틀렸거나 루트 `pubspec.yaml` 에서 `flutter_lints` 가 빠진 경우다.

**확인 (실행):** 배포 파일에서 `flutter.yaml` 을 `fluter.yaml` 로 바꾸고 실행 → `[2/4] 실패` 와 위 문구, `build/woody_rule_check/analysis_options.yaml:13  warning  include_file_not_found`, 이어서 `저장소 루트에서 \`fvm dart pub get\` 을 돌린 뒤 다시 실행하세요.`.

**Fix:** 문구를 사실만 적도록 바꾼다: "복사본의 include 가 풀리지 않아 규칙을 보지 못했다. `lib/analysis_options.yaml` 의 `include:` 경로와 루트 `pubspec.yaml` 의 `dependencies` 를 확인하세요."

### IN-03: 코드가 아는 것보다 많이 말하는 문구와 주석

**File:** `tool/verify.dart:421-425`, `tool/verify.dart:647`, `tool/verify.dart:670-674`
**Issue:** 세 곳 모두 그대로다 (줄 번호만 옮겨졌다).
- 421-425행: plugin 폴더가 둘 이상이면 "저장소 경로가 바뀐 적 있다" 고 단정한다. 코드가 아는 것은 "폴더가 둘 이상" 뿐이다. `.plugin_manager` 에 빈 폴더를 하나 만들기만 해도 이 문구가 나왔다 (실행 — WR-01 의 둘째 확인과 같은 실행).
- 647행: "복사본은 어떤 경우에도 지운다" — `finally` 는 예외와 `return` 에서만 돈다. 규칙 검사 도중의 Ctrl-C 에서는 `build/woody_rule_check/` 가 남는다 (읽기만). 다음 실행이 덮어쓰고 지우며 `.gitignore` 가 막고 있어 해는 없다.
- 670-674행: 규칙 검사의 `stderrHead` 는 `scrubPaths` 를 거치지 않는다. 같은 모양의 839-842행은 거친다 (읽기만).

**Fix:** "저장소 경로가 바뀐 적이 있을 수 있다 (plugin 폴더가 N개다)" 로 바꾸고, 647행은 "예외로 끝나도 지운다 (Ctrl-C 에서는 남을 수 있고 다음 실행이 지운다)" 로, 670행에는 `scrubPaths(…, repoRoot)` 를 넣는다.

### IN-04: workflow 의 action 이 움직이는 tag 로 지정되어 있다

**File:** `.github/workflows/verify.yml:28`, `.github/workflows/verify.yml:31`
**Issue:** 그대로다. `actions/checkout@v7` 과 제3자 action `subosito/flutter-action@v2` 가 major tag 로 지정되어 있다. tag 는 가리키는 커밋이 바뀔 수 있다. 권한이 `contents: read` 이고 secret 을 쓰지 않으므로 영향은 "CI 판정을 믿을 수 있는가" 에 그친다.

**확인 (읽기만).**

**Fix:** 고정하려면 전체 commit SHA 로 적고 버전을 주석으로 남긴다 (`uses: subosito/flutter-action@<sha> # v2.x.y`). `actions/checkout` 에 `with: persist-credentials: false` 를 더하면 token 이 `.git/config` 에 남지 않는다.

### IN-05: PR 을 열면 같은 커밋에 실행이 둘 돌고 `concurrency` 가 서로를 취소하지 않는다

**File:** `.github/workflows/verify.yml:8-9`, `.github/workflows/verify.yml:18-20`
**Issue:** 그대로다. 같은 저장소의 브랜치로 PR 을 열면 `push` 와 `pull_request` 가 각각 실행을 만든다. `group` 의 `github.ref` 가 앞의 것은 `refs/heads/<브랜치>`, 뒤의 것은 `refs/pull/<번호>/merge` 라 묶음이 다르다. 약 2분짜리 실행이 한 번 더 도는 것이 전부다. `008ea3f` 가 고친 주석은 tag 에서 한 번 더 도는 것만 다루고 이 겹침은 다루지 않는다.

**확인 (읽기만):** 이 저장소에는 아직 PR 이 없다.

**Fix:** 그대로 두어도 된다. 줄이려면 `group: ${{ github.workflow }}-${{ github.head_ref || github.ref_name }}` 로 브랜치 이름에 묶는다.

### IN-06: `pluginFolders` 는 동사로 시작하지 않는다

**File:** `tool/verify.dart:402`
**Issue:** 그대로다. 소유자의 전역 규칙은 "함수명: 동사로 시작" 이다. 이 파일의 다른 함수는 `read…` / `check…` / `format…` / `find…` 로 시작하고, 02-05 가 더한 `subtractLines` · `countDeclaredRules` 도 동사로 시작한다. spike 에서 옮겨 온 `pluginFolders` 만 명사다.

**확인 (읽기만).**

**Fix:** `listPluginFolders` 로 바꾼다 (부르는 곳은 414행 하나).

### IN-07: 규칙 수 세기가 멀쩡한 YAML 몇 가지 모양을 0개로 세어 `[2/4]` 를 잘못 실패시키고, 문구는 "비어 있거나 없다" 고 말한다

**File:** `tool/verify.dart:623`, `tool/verify.dart:629-631`, `tool/verify.dart:710-714`
**Issue:** WR-08 의 반대 방향이다. `countDeclaredRules` 는 줄의 모양으로 세기 때문에, analyzer 가 문제없이 읽는 다음 모양에서 0 을 돌려준다.

- **들여쓰기 없는 주석 줄이 `rules:` 와 첫 규칙 사이에 있을 때.** 629-631행은 들여쓰기 없는 줄을 전부 "블록의 끝" 으로 본다 (주석 포함 — 630행의 주석과 02-05-SUMMARY 가 이 동작을 일부러 정한 것으로 적었다). YAML 에서 주석은 들여쓰기와 무관하므로 블록은 끝나지 않는다. 그런 주석이 규칙 목록 중간에 있으면 그 뒤의 규칙만 세지 않아 결과가 0 보다 크고 판정은 맞다. 첫 규칙 **앞**에 있으면 0 이 된다.
- **맵 형식** (`prefer_const_constructors: true`). 프로젝트 관례가 목록 형식이므로 이 저장소에서 일부러 쓸 일은 없지만, 유효한 형식이고 analyzer 는 받아들인다.
- (읽기만) 따옴표로 감싼 이름(`- 'avoid_print'`)과 flow 형식(`rules: [a, b]`)도 623행의 패턴에 맞지 않는다.

모두 실패 쪽으로 틀리므로(통과로 틀리지 않는다) 판정을 믿을 수 없게 만들지는 않는다. 문제는 문구다. 규칙이 12개 적혀 있고 `[4/4]` 가 16줄 그대로 통과하는데 화면은 "`rules:` 목록이 비어 있거나 없다", "`linter:` / `rules:` 키와 들여쓰기를 확인하세요" 라고 한다. 키도 들여쓰기도 맞는 파일에서 이 안내를 받은 사람은 원인(주석의 자리, 목록 형식만 센다는 제약)을 찾을 단서가 없다.

**확인 (실행):**
- `    # 성능` (22행)을 들여쓰기 없는 `# 성능 (들여쓰기 없는 주석)` 으로 바꿈 → `[2/4] 실패` (규칙 0개 문구), `[4/4] 통과`, exit 1.
- 규칙 12줄을 `이름: true` 맵 형식으로 바꿈 → `[2/4] 실패` (같은 문구), `[4/4] 통과`, exit 1.

**Fix:** 들여쓰기 없는 주석 줄은 블록을 닫지 않게 한다 (WR-08 의 코드에 넣어 두었다: `&& !line.startsWith('#')`). 나머지 형식은 세지 않더라도 문구가 제약을 말하게 한다: "`lib/analysis_options.yaml` 의 최상위 `linter:` 블록에서 `- 규칙이름` 꼴 줄을 찾지 못했다 (이 검사는 목록 형식만 센다)." WR-03 의 남은 절반을 analyzer 의 진단으로 고치면 이 세기는 "규칙을 다른 파일로 옮긴 경우"(M14)만 맡으면 된다.

### IN-08: `--update` 쓰기 반복문은 fixture 가 둘 이상일 때의 모양이 정해져 있지 않다

**File:** `tool/verify.dart:1066-1078`, `example/README.md:30`
**Issue:** `fixtures` 는 지금 `['example']` 하나라 아래는 오늘 일어나지 않는다. Phase 3 (VERIFY-05 의 대조군 fixture)이 목록을 늘릴 때 드러날 것이라 적어 둔다.

- 1073-1076행은 `applyUpdate` 를 차례로 부른다. 둘째 fixture 의 쓰기가 `FileSystemException` 을 던지면 첫 정답지는 이미 쓰였고 `정답지를 썼다:` 한 줄만 찍힌 채 exit 70 으로 끝난다. 요약 줄은 나오지 않는다.
- 1070-1071행의 `failed` 에는 다른 fixture 의 정답지 비교 단계(plugin 준비 실패, 도구 사망)도 들어간다. 그러면 멀쩡한 fixture 의 쓰기까지 막히고 문구는 "다른 단계가 실패해" 다. 막는 쪽이 안전하므로 동작은 괜찮다. 다만 `example/README.md:30` 은 "다른 단계(`[1/4]` ~ `[3/4]`)" 와 "plugin 준비 실패와 도구 사망에서는 … 이 문구 대신 `[4/4]` 의 실패 내용이 찍힌다" 로 적어, fixture 가 하나일 때만 맞는 설명이 된다.
- 막힌 실행에서도 `detailLines` 의 `정답지 갱신 대상:` · `- ` / `+ ` 줄 · `머리 주석:` 줄은 전부 먼저 찍힌다 (M12 의 화면에서 확인). 쓰지 않을 내용 17줄 뒤에 "쓰지 않았다" 한 줄이 온다. 순서상 어쩔 수 없지만, 줄이 많으면 마지막 줄을 놓치기 쉽다.

**확인:** 셋째는 실행 (M12 재현의 화면). 첫째 · 둘째는 읽기만 — fixture 가 하나라 만들 수 없다.

**Fix:** Phase 3 에서 fixture 를 더할 때 함께 정한다. 쓰기 전에 대상 경로를 모두 확인하거나, 쓰기 반복문을 `try` 로 감싸 "N개 중 M개를 썼다" 를 찍고 exit 1 로 끝낸다. README 의 설명은 "다른 단계가 하나라도 실패했으면" 으로 일반화한다. 막힌 실행의 문구에는 실패한 단계 번호를 넣으면 긴 화면에서도 찾기 쉽다 (`[3/4] 이 실패해 정답지를 쓰지 않았다`).

---

_Reviewed: 2026-10-12T01:25:47Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
