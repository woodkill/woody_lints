---
phase: 04-rule-reselection
reviewed: 2026-10-13T06:02:52Z
depth: standard
files_reviewed: 54
files_reviewed_list:
  - CHANGELOG.md
  - RULES.md
  - example/README.md
  - example/expected_diagnostics.txt
  - example/lib/base_rules.dart
  - example/lib/bug_prevention_rules.dart
  - example/lib/final_parameters_rule.dart
  - example/lib/performance_rules.dart
  - example/lib/relative_imports_rule.dart
  - example/lib/strict_rules.dart
  - example/lib/style_rules.dart
  - fixtures/base_codegen/expected_diagnostics.txt
  - fixtures/base_codegen/lib/base_rules.dart
  - fixtures/base_codegen/lib/bug_prevention_rules.dart
  - fixtures/base_codegen/lib/final_parameters_rule.dart
  - fixtures/base_codegen/lib/performance_rules.dart
  - fixtures/base_codegen/lib/relative_imports_rule.dart
  - fixtures/base_codegen/lib/strict_rules.dart
  - fixtures/base_codegen/lib/style_rules.dart
  - fixtures/base_only/expected_diagnostics.txt
  - fixtures/base_only/lib/base_rules.dart
  - fixtures/base_only/lib/bug_prevention_rules.dart
  - fixtures/base_only/lib/final_parameters_rule.dart
  - fixtures/base_only/lib/performance_rules.dart
  - fixtures/base_only/lib/relative_imports_rule.dart
  - fixtures/base_only/lib/strict_rules.dart
  - fixtures/base_only/lib/style_rules.dart
  - fixtures/base_riverpod/expected_diagnostics.txt
  - fixtures/base_riverpod/lib/base_rules.dart
  - fixtures/base_riverpod/lib/bug_prevention_rules.dart
  - fixtures/base_riverpod/lib/final_parameters_rule.dart
  - fixtures/base_riverpod/lib/performance_rules.dart
  - fixtures/base_riverpod/lib/relative_imports_rule.dart
  - fixtures/base_riverpod/lib/strict_rules.dart
  - fixtures/base_riverpod/lib/style_rules.dart
  - fixtures/overrides/expected_diagnostics.txt
  - fixtures/overrides/lib/base_rules.dart
  - fixtures/overrides/lib/bug_prevention_rules.dart
  - fixtures/overrides/lib/final_parameters_rule.dart
  - fixtures/overrides/lib/performance_rules.dart
  - fixtures/overrides/lib/relative_imports_rule.dart
  - fixtures/overrides/lib/strict_rules.dart
  - fixtures/overrides/lib/style_rules.dart
  - fixtures/recommended/lib/base_rules.dart
  - fixtures/recommended/lib/bug_prevention_rules.dart
  - fixtures/recommended/lib/final_parameters_rule.dart
  - fixtures/recommended/lib/performance_rules.dart
  - fixtures/recommended/lib/relative_imports_rule.dart
  - fixtures/recommended/lib/strict_rules.dart
  - fixtures/recommended/lib/style_rules.dart
  - lib/base.yaml
  - tool/measure_rules.dart
  - tool/measurements/2026-10-13-R1.json
  - tool/verify.dart
findings:
  critical: 3
  warning: 8
  info: 7
  total: 18
status: issues_found
---

# Phase 4: Code Review Report

**Reviewed:** 2026-10-13T06:02:52Z
**Depth:** standard
**Files Reviewed:** 54
**Status:** issues_found

## Summary

리뷰 시간 대부분을 `tool/measure_rules.dart` 와 `tool/verify.dart` 에 썼다. 문서 · 설정(`lib/base.yaml` · `RULES.md` · `CHANGELOG.md` · `example/README.md`)은 서로, 그리고 결과 JSON 과 어긋나는지를 스크립트로 견줬다. `fixtures/*/lib/*.dart` 30개는 `diff -rq` 로 `example/lib/` 와 대조만 했다 — `relative_imports_rule.dart` 의 3행 import 패키지 이름 말고는 차이가 0 이다 (소유자가 받아들인 예외).

맞는 것으로 확인한 것 (발견 아님):

- `lib/base.yaml` 의 규칙 80개 == `RULES.md` 켠 규칙 표 80행, 사유 문장도 80개 모두 글자 그대로 같다. `CHANGELOG.md` 의 "추가한 규칙" 74개와 "새로 생기는 경고" 74행은 `lib/base.yaml` 에서 1.3.0 의 6개를 뺀 집합과 같고, 건수 · `dart fix` 칸은 결과 JSON 의 `counts` · `fixRemoved` 와 74행 모두 같다.
- `--report` 를 복사본에서 돌린 Markdown 이 `RULES.md` 의 `woody:measurements` 구역과 글자 그대로 같다 (`diff` 0). `--audit` 은 종료 코드 0 (`켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0`).
- 결과 JSON 의 모든 키 · 값 문자열에 `/` 가 든 것은 `lib/woody_probe_marker/` 표식 경로뿐이다 — 사용 프로젝트의 경로 · 메시지가 없다 (D-07). 소스 · 작업 폴더 경로는 화면 출력에서도 `<work>` 로 가려졌다.
- `lib/base.yaml` 의 규칙마다 `example/expected_diagnostics.txt` 에 그 규칙의 줄이 하나 이상 있고, 정답지 넷도 같다 (`overrides` 는 끄는 설정대로 `prefer_final_locals` 만 없다).
- `--work` 를 저장소 안(대소문자만 다른 경로 포함)에 주면 거부된다.

가장 무거운 발견은 셋이다. (1) 측정 도구가 `pubspec.yaml` 에서 나온 진단을 버려 `sort_pub_dependencies` 의 실측 2줄이 0줄로 기록되었고, 소유자 결정의 이유 문장이 그 틀린 0 을 근거로 쓴다. (2) `[3/10]` 이 `linter:` 블록 안의 열 0 주석 뒤에 적힌 규칙을 보지 못해, 기반 세트와 겹치는 규칙이나 `RULES.md` 에 없는 규칙을 더해도 통과한다 (D-11 의 거짓 통과). (3) 측정 도구가 "지금 켜 둔 규칙" 을 1.3.0 의 6개로 박아 두어, 지금 저장소에서 다시 재면(D-09 가 예정한 RULES-13 · Dart 3.14 재측정) 채택한 규칙 74개가 모두 0줄로 나온다.

재현은 모두 리뷰어 임시 폴더(scratchpad 아래 `reviewer-` 로 시작하는 폴더)에 `git archive HEAD` 로 만든 복사본에서 했다. 측정 smoke 는 `--source <복사본>/example` 로 돌렸다. 작업 트리는 바꾸지 않았다 (리뷰 전후 `git status --porcelain` 이 같다).

## Critical Issues

### CR-01: `pubspec.yaml` 의 진단을 버려 `sort_pub_dependencies` 의 실측 2줄이 0줄로 기록됐다 — 소유자 결정의 근거가 사실과 다르다

**File:** `tool/measure_rules.dart:1704-1721`, `tool/measure_rules.dart:3290-3298`, `tool/measure_rules.dart:1289`, `RULES.md:133`, `RULES.md:376`
**Issue:** `Diag.area` 는 경로에 `/` 가 없으면 파일 이름 자체를 자리로 돌려주고(1709-1710), 규칙의 값은 `projectAreas = ['lib', 'test', 'bin']` 자리만 더한다(`ruleCounts`, 3290-3298). 그래서 `pubspec.yaml` 에 보고되는 `sort_pub_dependencies` 는 구조적으로 늘 0 이다. 커밋된 결과 JSON 이 이를 보여 준다.

```text
runs[G1].countByAreaCode["pubspec.yaml"] = {"sort_pub_dependencies": 2}   # G1 · G1-marker · G1-strip · apply-* 30여 회차 모두 같음
rows.sort_pub_dependencies.counts   = {"lib": 0, "test": 0, "bin": 0}
rows.sort_pub_dependencies.severity = "info"   # firstSeverity 는 shot.project(pubspec 자리 포함)에서 읽어 값을 찾았다
```

같은 행의 강도는 pubspec 의 진단에서 읽고 건수는 그 진단을 버린 것이다. 결과로 평가표(`RULES.md:376`)는 `0 (표식 불가)`, 켜지 않은 규칙 표(`RULES.md:133`)는 "소유자 결정 — **실제 프로젝트 0줄**이고 …" 이다. 사용 프로젝트에는 2줄이 있다. `noFileProbe` 의 이유(1289 "pubspec.yaml 을 본다 — Dart 파일로는 어길 수 없다")도 실측이 0 이라는 전제에서만 맞는 말이다. Core Value("각 규칙이 왜 켜져 있는지 근거가 남아 있다", RULES-07 "사유가 사실과 맞다")를 직접 깨고, 같은 방식으로 `analysis_options.yaml` 자리의 진단(지금은 `incompatible_lint` 뿐)도 값에서 빠진다.
**Fix:** 프로젝트 파일 자리를 값에 넣는다. 그 뒤 `--report --write` 로 표를 다시 만들고, `RULES.md:133` 의 이유를 실측(2줄, `pubspec.yaml`)으로 고쳐 소유자에게 다시 묻는다.

```dart
/// 규칙의 값을 나누는 자리 (D-02). pubspec.yaml 처럼 맨 위 파일에 보고하는 규칙도 센다.
const projectAreas = ['lib', 'test', 'bin', 'pubspec.yaml'];
```

`areaTriple` · 표 머리의 `lib·test·bin` 도 넷째 칸을 보이도록 고친다. 자리를 늘리지 않으려면 최소한 `ruleCounts` 가 0 인데 `countByAreaCode` 의 다른 자리에 그 규칙 코드가 있으면 `--report` 단언이 실패해야 한다.

### CR-02: `[3/10]` 이 `linter:` 블록 안의 열 0 주석 뒤에 적힌 규칙을 보지 못한다 — 겹침 · `RULES.md` 일치 검사의 거짓 통과

**File:** `tool/verify.dart:878-894` (885-887행)
**Issue:** `declaredRuleNames` 는 들여쓰기 없는 줄을 만나면 `linter:` 블록을 닫는다. 주석도 그렇다 ("들여쓰기 없는 줄(다른 최상위 키나 주석)이 블록을 닫는다"). YAML 에서 열 0 주석은 블록을 닫지 않으므로 analyzer 는 그 뒤의 `- 규칙` 을 그대로 켠다. 그래서 열 0 주석 뒤에 규칙을 더하면 (b) 겹침 검사와 (c) `RULES.md` 일치 검사가 그 규칙을 보지 못한다. `[2/10]` 은 겹침을 경고하지 않고(M20), 정답지는 기반 세트가 이미 켜는 규칙이나 샘플이 없는 규칙에서 바뀌지 않는다. 검증 전체가 통과한다. D-11 이 막으려던 두 가지가 모두 새어 나간다.

복사본에서 재현했다. `lib/base.yaml` 의 마지막 규칙(`no_raw_types`) 뒤에 세 줄을 더했다.

```yaml
# 실험 중 (열 0 주석)
    - avoid_print # 기반 세트와 겹침
    - cascade_invocations # RULES.md 에 없음
```

`checkShippedComposition(<복사본>)` 의 결과는 `passed=true`, `declaredRuleNames(...).length` 는 80 그대로였다. 같은 꼴의 옵션 파일(`rules:` 아래 `- prefer_single_quotes`, 열 0 주석, `- prefer_final_locals`)을 따로 만든 패키지에서 `fvm dart analyze` 를 돌리면 `prefer_final_locals` 가 보고된다. analyzer 는 주석 뒤의 규칙을 켠다.
**Fix:** 주석 줄과 빈 줄은 블록을 닫지 않게 한다 (`enabledLanguageOptions` 는 이미 그렇게 한다).

```dart
for (final line in options.split('\n')) {
  final trimmed = line.trimLeft();
  if (trimmed.isEmpty || trimmed.startsWith('#')) continue; // 주석 · 빈 줄은 블록을 닫지 않는다
  if (RegExp(r'^linter:').hasMatch(line)) {
    inLinter = true;
  } else if (RegExp(r'^\S').hasMatch(line)) {
    inLinter = false;
  } else if (inLinter) { … }
}
```

`example/README.md` 의 M 기록에 이 입력(열 0 주석 + 겹치는 규칙)을 하나 더해 `[3/10]` 이 실패하는 것을 남긴다.

### CR-03: 측정 도구가 "지금 켜 둔 규칙" 을 1.3.0 의 6개로 박아 두어, 지금 저장소에서 다시 재면 채택한 74개가 모두 0줄이 된다

**File:** `tool/measure_rules.dart:269-276`, `tool/measure_rules.dart:410-417`, `tool/measure_rules.dart:3494-3517`, `tool/measure_rules.dart:4177-4183`
**Issue:** 복사본은 `path:` 로 작업 중인 저장소를 받으므로 기준선 `B0` 에 그때의 `lib/base.yaml` 이 이미 적용된다. 그룹의 값은 "그룹 실행 − 기준선" 이다(3510-3513). R1 을 잴 때는 `lib/base.yaml` 이 6개만 켰으므로 맞았다. 지금은 80개를 켜므로 G1 ~ G3 에 든 채택 규칙 74개는 기준선에도 같은 줄이 있어 값이 0 이 된다. 이어 markers 단계가 0줄 후보에 표식을 넣으면 검출되므로 평가표는 `0 (표식 1)` 이 되고, `--report` 의 단언 (1) ~ (6) 가운데 어느 것도 이것을 잡지 못한다. D-09 는 이 도구를 다시 돌릴 일(RULES-13 의 `lints` 7, Dart 3.14 계열)을 예정하고 있다. `recommend` 의 비호환 판정(4177-4183)도 같은 6개만 보므로, 이미 켠 `prefer_relative_imports` 와 함께 쓸 수 없는 `always_use_package_imports` 를 "안 켬" 으로 가르지 못한다.

복사본에서 `--source <복사본>/example --stage baseline,groups --rules directives_ordering,unnecessary_lambdas --out <임시 폴더>/out1.json` 으로 smoke 를 돌렸다 (45초, 회차 3개 모두 유효).

```text
B0  lib.unnecessary_lambdas=1  lib.directives_ordering=1   options.rules=[]
G1  lib.unnecessary_lambdas=1  lib.directives_ordering=1   options.rules=[directives_ordering, unnecessary_lambdas]
rows.unnecessary_lambdas.counts   = {lib: 0, test: 0, bin: 0}
rows.directives_ordering.counts   = {lib: 0, test: 0, bin: 0}
```

`example/lib/style_rules.dart` 에는 두 규칙의 위반이 하나씩 있는데 값은 0 이다. R1 의 커밋된 값에는 영향이 없다 (그때의 `lib/base.yaml` 이 6개였다).
**Fix:** 시작할 때 `lib/base.yaml` 에서 켠 규칙을 읽어(`verify.dart` 의 `declaredRuleNames` 와 같은 셈법, CR-02 를 고친 판) 그 규칙들을 `current` 로 다룬다 (값은 B0 에서 읽는다). 또는 겹치면 멈춘다.

```dart
final shipped = declaredRuleNames(File('${repo.root}/lib/base.yaml').readAsStringSync()).toSet();
final stale = [for (final c in candidates) if (c.group != 'current' && shipped.contains(c.name)) c.name];
if (stale.isNotEmpty) {
  throw StateError('lib/base.yaml 이 이미 켠 후보 ${stale.length}개 — 기준선에 섞여 값이 0 이 된다: ${stale.join(', ')}');
}
```

`recommend` 의 `currentRules.contains(other)` 도 `shipped.contains(other)` 로 바꾼다.

## Warnings

### WR-01: 같은 id 의 회차를 덮어써도 행이 옛 회차를 계속 가리킨다 — 수치의 출처 추적(RULES-05)이 조용히 끊긴다

**File:** `tool/measure_rules.dart:1938-1946`, `tool/measure_rules.dart:3497-3517`, `tool/measure_rules.dart:4481-4495`
**Issue:** `addRun` 은 같은 id 의 회차를 통째로 바꾼다. 범위를 좁힌 재실행(`--rules`)은 범위 밖 행의 `counts` · `runs` 를 그대로 둔다. 그 행들은 이제 자기 규칙을 켜지 않은 회차를 출처로 가리킨다. `--report` 의 단언 (5) 는 회차가 "있고 유효한지" 만 보고 그 회차가 그 규칙을 켰는지는 보지 않는다. 위 smoke 의 작업 폴더에서 `--stage groups --rules directives_ordering` 을 한 번 더 돌린 결과다.

```text
out2.json  G1.options.rules = ['directives_ordering']
           rows.unnecessary_lambdas.runs = ['G1']   # 값은 첫 실행의 G1 에서 나왔는데 그 회차는 이제 없다
```

커밋된 R1 에는 이 어긋남이 없다 (행마다 참조한 그룹 회차의 `options.rules` 에 그 규칙이 있는 것을 스크립트로 확인했다).
**Fix:** `buildReport` 에 단언을 하나 더한다 — 행이 참조한 `G1` ~ `G4` (와 `-marker` · `-strip`) 회차의 `options.rules` 에 그 규칙이 있어야 한다 (`strict-inference` 는 `options.language`). 또는 그룹 회차를 덮어쓸 때 범위 밖 행의 그 회차 참조와 값을 지운다.

### WR-02: 음수인 "가린 줄" 이 `0` 으로 찍힌다

**File:** `tool/measure_rules.dart:4073-4078`, `RULES.md:324`, `RULES.md:390`
**Issue:** `countCell` 은 합계가 0 보다 클 때만 수를 쓰고 나머지는 모두 `0` 으로 쓴다. 결과 JSON 의 `ignored` 는 `document_ignores` 가 `{lib: -1, test: -46, bin: -1}`, `unnecessary_ignore` 가 `{-1, -10, -1}` 이다. 주석을 걷어내면 주석에 붙는 진단이 사라지기 때문이다. 평가표의 "가린 줄" 칸에는 둘 다 `0` 으로 실려, "주석이 가린 줄이 없다" 로 읽힌다.
**Fix:** 0 이 아닌 값은 부호째 쓴다 (`-48 (-1·-46·-1)`). 무시 주석 자체를 보는 규칙은 칸에 "주석을 걷으면 줄어듦" 을 덧붙인다.

```dart
if (n != 0) return '$n (${areaTriple(counts)})';
```

### WR-03: `--out` 을 검사하지 않는다 — 원본(사용 프로젝트)이나 저장소의 아무 파일에나 쓸 수 있다

**File:** `tool/measure_rules.dart:1530-1539`, `tool/measure_rules.dart:4907-4914`
**Issue:** `--work` 는 저장소 · 원본과의 포함 관계를 검사하지만 `--out` 은 절대 경로로 바꾸기만 한다. 마지막 지문 비교가 끝난 **뒤에** `writeAsBytesSync` 로 쓰므로 지문으로도 잡히지 않는다. 복사본에서 `--source <가짜 원본> --out <가짜 원본>/leak.json --stage fix` 를 주면 인자 검증은 통과하고, 다음 확인(앞 회차 없음)에서야 멈췄다. 단계가 있었다면 원본 안에 파일을 만들었을 것이다 (PROJECT.md Safety "원본은 읽기만"). `--out lib/base.yaml` 같은 오타는 배포 파일을 JSON 으로 덮어쓴다.
**Fix:** `parseArgs` 에서 `--out` 이 `.json` 으로 끝나는지, 원본 안이 아닌지 확인한다. 저장소 안이면 `tool/measurements/` 아래만 허용한다.

```dart
if (out != null) {
  if (!out.endsWith('.json')) throw UsageError('--out 은 .json 파일이어야 한다');
  if (source != null && isWithin(resolveLoosely(out), source)) throw UsageError('--out 은 원본 안에 둘 수 없다');
  if (isWithin(resolveLoosely(out), repo.root) && !isWithin(resolveLoosely(out), '${repo.root}/tool/measurements')) {
    throw UsageError('저장소 안의 --out 은 tool/measurements/ 아래만');
  }
}
```

### WR-04: `--work` 가 남의 폴더여도 그 아래 `consumer/` · `pristine/` · `pkg13/` · `state/<id>/` 를 지운다

**File:** `tool/measure_rules.dart:2118-2122`, `tool/measure_rules.dart:2962-2963`, `tool/measure_rules.dart:2325-2327`, `tool/measure_rules.dart:1468-1473`
**Issue:** `--work` 는 "저장소 밖" 과 "원본과 서로의 안이 아님" 만 확인한다. 저장소를 품은 상위 폴더도 받는다. 복사본에서 `--work <저장소 복사본의 부모>` 가 인자 검증을 통과했다. 그 뒤 `_reset` · `measureState` · `analyze` 는 `<work>/pristine`, `<work>/consumer`, `<work>/pkg13`, `<work>/state/<id>` 를 확인 없이 `deleteSync(recursive: true)` 한다. 작업 폴더를 잘못 주면 같은 이름의 폴더가 날아간다.
**Fix:** 작업 폴더가 비어 있거나 이 도구가 만든 표시 파일(`<work>/.woody_measure_rules`)이 있을 때만 쓴다. 저장소나 원본을 품은 폴더는 거부한다 (`isWithin(repo.root, resolvedWork)`).

### WR-05: `example/README.md` 의 줄 수 · 파일 표가 이 phase 의 샘플을 반영하지 않았다

**File:** `example/README.md:37-48`, `example/README.md:56-61`
**Issue:** 이 phase 는 같은 파일의 단계 번호(`[5/10]` 등)는 고쳤지만, 정답지 크기와 파일 목록은 Phase 3 의 값 그대로다.

| 자리 | 문서 | 실제 (HEAD) |
|---|---|---|
| 46행 `expected_diagnostics.txt` | `exit 2` + 16줄 | `exit 2` + 92줄 |
| 56 · 57행 example · recommended | 16 | 92 · 92 |
| 58행 base_only | 18 | 94 |
| 59행 overrides | 18 | 103 |
| 60행 base_riverpod | 21 | 97 |
| 61행 base_codegen | 13 | 89 |
| 42행 `lib/riverpod_rules.dart` | 2 | 3 (`specify_nonobvious_property_types` 13행이 더해짐) |

파일 표에는 `bug_prevention_rules.dart` · `performance_rules.dart` · `style_rules.dart` · `strict_rules.dart` · `final_parameters_rule.dart` · `relative_imports_rule.dart` 여섯이 없다.
**Fix:** 표를 지금 정답지로 다시 센다 (`grep -v -E '^(#|exit )' <정답지> | grep -c .`). 새 파일 여섯의 행을 더하고, `riverpod_rules.dart` 행에 새 규칙이 걸린 줄을 적는다.

### WR-06: 기반 세트 YAML 에서 규칙을 하나도 읽지 못해도 겹침 검사가 통과한다

**File:** `tool/verify.dart:1211-1244`, `tool/measure_rules.dart:2685-2721`
**Issue:** 두 함수는 `^    - (\w+)` (들여쓰기 4칸의 목록 형식)만 읽는다. 상류 YAML 의 들여쓰기나 형식이 바뀌면(RULES-13 의 `lints` 7 이 예정되어 있다) 빈 집합을 돌려준다. 그러면 `[3/10]` (b) 는 겹침 0 으로 통과하고, 측정 도구의 `upstream` 칸은 모두 `—` 가 된다. 둘 다 아무 경고도 내지 않는다.
**Fix:** 파일마다 읽은 이름 수가 0 이면 `FormatException` 을 던진다.

```dart
final found = …;
if (found.isEmpty) throw FormatException('$folder $fileName 에서 규칙을 하나도 읽지 못했다 — 형식이 바뀌었다');
```

### WR-07: 상태 출처의 캐시가 tag 를 가리지 않고, `sdkTag` 와 실행 SDK 를 견주지 않는다

**File:** `tool/measure_rules.dart:46`, `tool/measure_rules.dart:2873-2888`
**Issue:** `messages.yaml` 은 `<work>/upstream/messages.yaml` 에 한 번 받으면 다시 받지 않는다. 그런데 `stateSource` 에는 그때의 상수 `messages.yaml@$sdkTag` 를 적는다. Dart 3.14 재측정(D-09) 때 `sdkTag` 를 올리고 같은 작업 폴더를 쓰면, 3.13.4 의 상태를 3.14 의 것으로 적는다. 반대로 `sdkTag` 를 그대로 두고 3.14 SDK 로 돌리면, 분석 SDK 와 상태 출처가 어긋난 표가 나와도 아무 경고가 없다.
**Fix:** 캐시 이름에 tag 를 넣는다 (`upstream/messages-$sdkTag.yaml`). 시작할 때 `dartVersion() != sdkTag` 면 멈추거나 경고한다.

### WR-08: 단계가 예외로 끝나면 저장소 지문을 견주지 않고 결과도 저장하지 않는다

**File:** `tool/measure_rules.dart:3067-3080`
**Issue:** `RepoGuard.step` 은 `await body()` 가 던지면 곧바로 빠져나간다. 그 단계가 저장소를 바꿨는지는 확인하지 않고(D-09 "단계마다 지문을 비교"), 단계 안에서 끝낸 회차도 `results.save()` 되지 않는다 (규칙마다 저장하는 `fix` 만 예외). 종료 코드 69/70 이 나므로 결과를 쓰지는 않겠지만, "저장소가 바뀌었다" 는 가장 중요한 신호가 다른 오류에 가려진다.
**Fix:**

```dart
try {
  await body();
} finally {
  final now = await repo.fingerprint();
  results.save();
  if (now != last) { stderr.writeln('$name: 저장소가 바뀌었다 — 이 실행을 쓰지 않는다'); …; exit(1); }
  last = now;
}
```

## Info

### IN-01: 샘플 머리 주석의 "한 줄에서 규칙 하나만" 이 사실과 다르다

**File:** `example/lib/bug_prevention_rules.dart:3`, `example/lib/bug_prevention_rules.dart:133-136` (fixture 다섯의 복사본도 같다)
**Issue:** `parameterAssign` 의 135행 `x = x + 1;` 은 `parameter_assignments` 와 `join_return_with_assignment` 에 함께 걸린다. 정답지에 `lib/bug_prevention_rules.dart:135` 가 두 줄 있다. `join_return_with_assignment` 의 샘플은 `style_rules.dart:67` 에 따로 있다. 검증은 성립하지만, D-10 의 "정답지의 바뀐 줄 ↔ 규칙 결정" 대응이 한 줄에서 둘이 된다. `riverpod_rules.dart:13` 도 새 규칙(`specify_nonobvious_property_types`)을 함께 받는다.
**Fix:** 135행을 return 직전 대입이 아닌 꼴로 바꾼다 (예: `x = x + 1;` 뒤에 `return x * 2;`). 바꿀 수 없으면 머리 주석을 고친다.

### IN-02: `MessagesRule.consistent` 가 쓰이지 않는다

**File:** `tool/measure_rules.dart:2730-2731`, `tool/measure_rules.dart:2743`
**Issue:** 같은 규칙의 코드끼리 state 가 다를 때를 가르는 getter 를 두었지만 부르는 곳이 없다. `latest` 는 `states.first` 만 본다.
**Fix:** `readRuleStates` 에서 `!consistent` 인 규칙을 경고하거나, getter 를 지운다.

### IN-03: "Dart 파일 474개" 에 분석하지 않는 생성 파일 62개가 들어 있다

**File:** `tool/measure_rules.dart:2304-2319`, `tool/measure_rules.dart:4241-4245`, `CHANGELOG.md` "새로 생기는 경고" 끝 줄, `RULES.md` 실측 기록 끝 줄
**Issue:** `dartFiles` 의 문서 주석은 "분석되는 Dart 파일 수 — … 생성 파일" 이라고 적는다. 그런데 복사본은 옛 주소 → `codegen.yaml` 의 `analyzer.exclude` 로 `*.g.dart` · `*.freezed.dart` 를 분석하지 않는다. 그래서 474 (= 172 + 239 + 1 + 생성 62) 는 분석한 파일 수가 아니다.
**Fix:** 한 줄 요약에는 분석한 파일 수(412)를 쓰거나 "생성 파일 포함" 을 덧붙인다.

### IN-04: `RULES.md` 의 완결성 · 사유 문장 일치를 CI 가 보지 않는다

**File:** `tool/measure_rules.dart:3970-3982`, `tool/measure_rules.dart:4718-4816`, `RULES.md:7`
**Issue:** `--audit` (후보 133 + B-7 31 이 표에 모두 있는지, 두 표에 겹친 이름)은 손으로만 돈다. 또 `보류` 접두사를 통과로 친다. `RULES.md:7` 의 "켠 이유는 `lib/base.yaml` 의 사유 주석과 같은 문장" 은 어느 검사도 보지 않는다. 지금은 80개 모두 같다 (스크립트로 확인).
**Fix:** `[3/10]` 에 켠 규칙 표의 셋째 칸 == `lib/base.yaml` 줄 끝 주석 비교를 더한다. 릴리스 전에는 `보류` 0 을 요구한다.

### IN-05: `lib/base.yaml:15` 의 템플릿 문장이 남았다

**File:** `lib/base.yaml:15`
**Issue:** "Uncomment the following section to specify additional rules." — 주석 처리된 절은 이 phase 에서 지웠다 (RULES-02). 이제 가리키는 대상이 없다. 머리 주석 정리(DOCS-10)가 Phase 5 의 일이라면 그때 함께 지운다.
**Fix:** 줄을 지운다.

### IN-06: `require_trailing_commas` 의 "규칙이 돌지 않음 (표식 불가)" 는 표식을 넣어 보지 않은 결론이다

**File:** `tool/measure_rules.dart:1293-1295`, `RULES.md:113`, `RULES.md:161`
**Issue:** `RULES.md:113` 은 `규칙이 돌지 않음` 을 "일부러 넣은 위반까지 0줄" 로 정의한다. 그런데 이 규칙은 표식을 넣지 않았다. 언어 버전 조건은 `example/lib/final_parameters_rule.dart` 처럼 파일 맨 위 `// @dart=3.6` 으로 맞출 수 있으므로 "Dart 파일 하나로는 어길 수 없다" 도 정확하지 않다. 사용 프로젝트(언어 3.11)에서 돌지 않는다는 결론 자체는 맞다.
**Fix:** `// @dart=3.6` 표식을 더해 0줄의 뜻을 실측으로 가르거나, 이유 문장을 "사용 프로젝트의 언어 버전에서는 돌지 않음 (규칙 소스의 language37 조건)" 으로 고친다.

### IN-07: 결과 파일 이름 · 출력 모드 · 종료 코드의 세부

**File:** `tool/measure_rules.dart:4907-4910`, `tool/measure_rules.dart:4003-4017`, `tool/measure_rules.dart:38-41`
**Issue:**
- 기본 `--out` 의 날짜는 결과 파일을 처음 만든 날(`conditions.date`)이다. 다른 날 같은 작업 폴더로 이어 재면 옛 날짜 이름의 파일을 덮어쓴다. 다른 작업 폴더에서 같은 run id 로 일부 단계만 돌리면, 커밋된 `tool/measurements/<날짜>-R1.json` 을 그 부분 결과로 덮어쓴다.
- 출력 모드에서 `--work` 를 줬는데 `<work>/results/<id>.json` 이 없으면, 알리지 않고 `tool/measurements/` 의 파일로 넘어간다.
- `TypeError` 같은 나열하지 않은 예외는 종료 코드 255 로 끝난다 (머리 주석은 70).

**Fix:** 기존 `tool/measurements/` 파일과 run id 가 같고 회차 집합이 줄면 쓰기를 멈춘다. `--work` 를 준 출력 모드는 그 자리만 본다. 끝에 `catch (e)` 를 하나 두어 70 으로 맞춘다.

---

_Reviewed: 2026-10-13T06:02:52Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
