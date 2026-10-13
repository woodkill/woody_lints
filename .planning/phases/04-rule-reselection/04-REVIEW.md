---
phase: 04-rule-reselection
reviewed: 2026-10-13T12:54:29Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - RULES.md
  - example/README.md
  - tool/verify.dart
findings:
  critical: 1
  warning: 7
  info: 13
  total: 21
status: issues_found
---

# Phase 4: Code Review Report (재리뷰 — gap 수정 2회차 04-13 뒤)

**Reviewed:** 2026-10-13T12:54:29Z
**Depth:** standard
**Files Reviewed:** 3
**Status:** issues_found

## Summary

gap 수정 plan 04-13 (커밋 `67d1bc7` · `76dee2f` · `8f4e257`, 마무리 `accee5a`) 이 `4397888..HEAD` 에서 바꾼 소스 셋(`tool/verify.dart` · `example/README.md` · `RULES.md`)을 다시 봤다. 지난 리뷰의 발견 19건은 하나씩 지금 코드와 대조했다. 새 `declaredRuleNames` (`rulePattern` · `rulesKeyPattern` · `FormatException`)는 처음 보는 코드로 읽었고, 그 함수를 부르는 두 자리 — `[2/10]` 의 `countDeclaredRules(rulesCopy)` (`tool/verify.dart:1089`) 와 `[3/10]` (b) · (c) 의 `declaredRuleNames(baseText)` (`:1371`) — 에서 예외가 어떻게 흐르는지 실행으로 확인했다. 이번 범위 밖 파일(`tool/measure_rules.dart` · `tool/measurements/2026-10-13-R1.json` · `lib/base.yaml` · `CHANGELOG.md` · `example/lib/*.dart` · `.github/workflows/verify.yml` · 정답지)은 `git diff --quiet 4397888 HEAD -- <파일>` 이 모두 참이다 (바뀌지 않음). 그래서 그 파일에 걸린 지난 발견은 원래 ID · 제목 · 본문 요지 그대로 옮겼다.

실행으로 확인한 것 (발견 아님). 모두 리뷰어 임시 폴더에 `git archive HEAD` 로 만든 복사본에서 돌렸고, 복사본 루트에서 `fvm dart pub get` 을 먼저 했다. 변경은 한 번에 하나만 만들고, 돌린 직후 백업으로 되돌린 뒤 `git diff --no-index` 로 원본과 같은지 봤다.

- 보통 실행: `fvm dart run tool/verify.dart` → `점검 통과 (10개 중 10개)` (rc 0, plugin 준비 포함 69초). `fvm dart analyze` → `No issues found!`, `fvm dart format --output=none --set-exit-if-changed tool` → rc 0. `readRuleNameAt` 은 `c06d8d5` 와 같고, `tool/measure_rules.dart` 는 `c06d8d5` 뒤로 바뀌지 않았다.
- `lib/base.yaml` 의 `- no_raw_types` 줄(105행) 뒤에 한 줄을 더한 입력:
  - M27 (`    - 'avoid_print' # …`) → rc 1, `[3/10]` 만 실패. 겹침 `avoid_print  (flutter_lints-6.0.0 flutter.yaml)` · `+ avoid_print  (base.yaml 에만)` · `점검 실패 (10개 중 1개)` (24초).
  - M28 (`    - "prefer_mixin" # …`) → rc 1, `[3/10]` 만 실패. `+ prefer_mixin  (base.yaml 에만)` 하나, 겹침 블록 없음 (22초).
  - M29 (`    - avoid_print: true …`) · M30 (`    -` 와 다음 줄 이름) · M31 (`    avoid_print: true …`) → 셋 다 rc 70, stdout 0바이트, stderr `파일 모양이 예상과 다르다: \`linter:\` 블록의 106행을 읽지 못했다 — … (04-REVIEW.md WR-10): <그 줄>` (3초 · 2초 · 3초).
  - `    -avoid_print` (`-` 뒤 공백 없음) · `    - avoid_print extra` (이름 뒤에 다른 것) → 둘 다 rc 70, 같은 문구 (README 가 "정규식으로 확인했고 돌려 보지는 않았다" 고 적은 두 꼴. 이번에 돌려서 맞는 것을 봤다).
- 예외가 난 자리: 두 번째 복사본의 `main` 의 `on FormatException` 에 stack trace 한 줄을 찍게 고쳐 돌렸다. M29 · M30 은 `declaredRuleNames ← countDeclaredRules ← checkRuleNames (:1089)` 이다. M31 과 `-avoid_print` 는 `declaredRuleNames ← checkShippedComposition (:1371) ← main` 이다 — `example/README.md` 의 "예외가 난 단계" 설명과 같다. 두 경우 모두 `build/woody_rule_check` 가 남지 않았다 (`checkRuleNames` 의 `finally`).
- 올바른 YAML 인데 거짓으로 멈추는지 확인했다. 아래 둘은 모두 `점검 통과 (10개 중 10개)` rc 0 이다. (1) `lib/base.yaml` 전체를 CRLF 줄 끝으로 바꾼 입력 — `#.*` 이 `\r` 앞에서 멈추고 `\s*$` 가 `\r` 을 먹는다. (2) 규칙 줄을 `rules:` 와 같은 들여쓰기(`  - 이름`)로 둔 indentless 목록.
- 아직 건너뛰는 꼴이 있는지 확인했다. 블록 안의 비주석 · 비공백 줄은 `rulesKeyPattern` 에 맞거나, `rulePattern` 에 맞거나, 던진다. 건너뛰는 분기는 없다. `rulePattern` 이 읽은 이름은 YAML 이 읽는 스칼라와 같다. 여는 · 닫는 따옴표는 backreference 로 맞추고, 이름 문자는 `[A-Za-z0-9_]`, 이름 뒤에는 공백 + `#` 만 온다. 여러 줄 plain scalar(`- avoid` 다음 줄 `_print`)는 둘째 줄에서 던진다. `linter:` 줄에 붙은 flow 표기(`linter: {rules: [<81개>]}`)는 doc 주석대로 `[2/10]` 이 "`- 규칙이름` 줄을 하나도 세지 못했다" 로, `[3/10]` 이 `- <81개>  (RULES.md 에만)` 으로 실패한다 (rc 1). WR-10 은 `lib/base.yaml` 안에서는 결함 꼴째 닫혔다.
- `example/README.md` 파일 표 `lib/added_rules.dart` 행의 새 문장("나머지 75개의 샘플은 아래 파일들과 `pubspec.yaml` 에 있다")을 확인했다. `lib/base.yaml` 의 규칙 81개가 모두 `example/expected_diagnostics.txt` 에 한 줄 이상 있다 (`comm -23` 0줄, `sort_pub_dependencies` 는 `pubspec.yaml:11`).

새 발견 가운데 무거운 것은 WR-11 이다. `[3/10]` 의 겹침 (b) 와 `RULES.md` 일치 (c) 는 `lib/base.yaml` 하나만 읽는다. 그래서 같은 조각 묶음(`recommended.yaml`)으로 사용 프로젝트에 전달되는 `lib/codegen.yaml` · `lib/riverpod.yaml` 에 적은 규칙은 두 검사를 모두 지나친다 (복사본에서 rc 0 재현). WR-10 을 결함 꼴째 닫았다는 주장은 `lib/base.yaml` 안에서만 맞다. 지금 남은 가장 무거운 것은 그대로인 CR-03 (소유자가 `deferred` 로 둠) 이다.

작업 트리는 바꾸지 않았다. 리뷰 전후 저장소의 `git status --porcelain` 은 시작할 때의 넷(`.planning/config.json` 수정, 추적하지 않는 `.planning/state.json` · `.planning/milestone.lock` · `.planning/research/.cache/`)과 이 파일뿐이다.

## 지난 리뷰의 발견 19건 — 지금 상태

| ID | 제목 | 지금 상태 | 근거 |
|---|---|---|---|
| CR-03 | 측정 도구가 "지금 켜 둔 규칙" 을 1.3.0 의 6개로 박아 두어, 지금 저장소에서 다시 재면 채택한 74개가 모두 0줄이 된다 | 그대로 해당 — 소유자 결정으로 `deferred` (REQUIREMENTS.md RULES-13 아래 메모, 04-12) | `tool/measure_rules.dart` 는 `4397888` 뒤로 바뀌지 않았다. `:273-280` (`currentRules` 6개), `:415`, `:3533-3539`, `:4207-4210` 그대로 |
| WR-01 | 같은 id 의 회차를 덮어써도 행이 옛 회차를 계속 가리킨다 — 수치의 출처 추적(RULES-05)이 조용히 끊긴다 | 그대로 해당 | `tool/measure_rules.dart:1950-1958`, `:4515-4529`, `:4955-4967` 그대로 (파일 바뀌지 않음) |
| WR-03 | `--out` 을 검사하지 않는다 — 원본(사용 프로젝트)이나 저장소의 아무 파일에나 쓸 수 있다 | 그대로 해당 | `tool/measure_rules.dart:1536-1545`, `:5140-5148` 그대로 |
| WR-04 | `--work` 가 남의 폴더여도 그 아래 `consumer/` · `pristine/` · `pkg13/` · `state/<id>/` 를 지운다 | 그대로 해당 | `tool/measure_rules.dart:1476-1478` 외 그대로 |
| WR-07 | 상태 출처의 캐시가 tag 를 가리지 않고, `sdkTag` 와 실행 SDK 를 견주지 않는다 | 그대로 해당 | `tool/measure_rules.dart:50`, `:2897-2912` 그대로 |
| WR-08 | 단계가 예외로 끝나면 저장소 지문을 견주지 않고 결과도 저장하지 않는다 | 그대로 해당 | `tool/measure_rules.dart:3091-3104` 그대로 |
| WR-09 | `--recount` 가 `fixSkipped` 를 원인을 확인하지 않고 R1 전용 문장으로 적고, 어느 단계도 지우지 않는다 — 단언 (2) 를 우회하고 권고를 뒤집는다 | 그대로 해당 — 소유자 결정으로 `deferred` (REQUIREMENTS.md RULES-13 아래 둘째 메모, 04-13 Task 3 `8f4e257`) | `tool/measure_rules.dart:4985-4997`, `:4161-4168`, `:4462-4467` 그대로. 04-13 은 메모만 더했다 |
| WR-10 | `[3/10]` 이 따옴표로 감싼 규칙 이름을 읽지 못한다 — CR-02 와 같은 거짓 통과가 다른 입력으로 남았다 | 고쳐짐 | `tool/verify.dart:885-922`. 복사본에서 M27 · M28 → `[3/10]` 만 실패 rc 1, M29 ~ M31 · `-avoid_print` · `- avoid_print extra` → rc 70. CRLF · indentless 목록은 rc 0 (거짓 실패 없음). `lib/base.yaml` 밖 조각의 같은 결과는 새 발견 WR-11 |
| IN-01 | 샘플 머리 주석의 "한 줄에서 규칙 하나만" 이 사실과 다르다 | 그대로 해당 | `example/lib/bug_prevention_rules.dart:3` 그대로 (파일 바뀌지 않음), `example/README.md:43` 은 두 줄인 것을 적는다 |
| IN-02 | `MessagesRule.consistent` 가 쓰이지 않는다 | 그대로 해당 | `tool/measure_rules.dart:2755` 그대로 |
| IN-03 | "Dart 파일 474개" 에 분석하지 않는 생성 파일 62개가 들어 있다 | 그대로 해당 | `RULES.md:422`, `CHANGELOG.md:181` 그대로 |
| IN-04 | `RULES.md` 의 완결성 · 사유 문장 일치를 CI 가 보지 않는다 | 그대로 해당 | `tool/verify.dart` 에 사유 비교 없음 (`grep -n 사유` 0줄), `.github/workflows/verify.yml` 바뀌지 않음 |
| IN-05 | `lib/base.yaml:15` 의 템플릿 문장이 남았다 | 그대로 해당 | `lib/base.yaml:15` "Uncomment the following section to specify additional rules." |
| IN-06 | `require_trailing_commas` 의 "규칙이 돌지 않음 (표식 불가)" 는 표식을 넣어 보지 않은 결론이다 | 그대로 해당 | `RULES.md:114`, `:161`, `tool/measure_rules.dart:1298-1300` 그대로 |
| IN-07 | 결과 파일 이름 · 출력 모드 · 종료 코드의 세부 | 그대로 해당 | `tool/measure_rules.dart:5141-5144`, `:4022-4045`, `:5157-5185` 그대로 |
| IN-08 | `RULES.md` 켠 규칙 표의 머리가 `실측 (lib · test · bin)` 그대로다 — `sort_pub_dependencies` 행이 0줄처럼 읽힌다 | 고쳐짐 | `RULES.md:49` 의 칸이 `2 (pubspec.yaml 2 — lib · test · bin 은 0)` — 지난 Fix 의 둘째 안(합계를 앞에). 머리를 넷으로 바꾸는 첫째 안은 소유자가 고르지 않았다 (`RULES.md:10` 머리는 그대로). 값은 `RULES.md:376` `2 (0·0·0·2)` · `CHANGELOG.md:163` `2건` 과 같다 |
| IN-09 | `--in` 의 사용법 오류 문구가 `--recount` 를 빠뜨렸다 | 그대로 해당 | `tool/measure_rules.dart:1470-1472` 그대로 |
| IN-10 | `example/README.md` 의 `lib/added_rules.dart` 행이 "이 패키지가 기반 세트 위에 추가하는 규칙 6개" 라고 적는다 | 그대로 해당(일부) — README 문장은 고쳐졌고, 소유자 결정(§2)으로 그대로 둔 샘플 머리 주석이 아직 사실과 다르다 | `example/README.md:39` 는 "1.3.0 부터 켜 둔 규칙 6개 … (이 패키지가 더하는 규칙 81개 가운데 1.3.0 의 것 …)" 로 고쳐졌다. `example/lib/added_rules.dart:3` 은 여전히 "woody_lints 가 기반 세트(flutter_lints / lints) 위에 추가하는 규칙 6개를" 이다 (fixture 다섯의 복사본도 같다) |
| IN-11 | "가린 줄이 음수인 행은 무시 주석 자체를 보는 규칙이다" 는 확인하지 않은 원인을 생성기가 단정한다 | 그대로 해당 | `tool/measure_rules.dart:4721-4734`, `RULES.md:420` 그대로 |

## Critical Issues

### CR-03: 측정 도구가 "지금 켜 둔 규칙" 을 1.3.0 의 6개로 박아 두어, 지금 저장소에서 다시 재면 채택한 74개가 모두 0줄이 된다

**File:** `tool/measure_rules.dart:273-280`, `tool/measure_rules.dart:415`, `tool/measure_rules.dart:3533-3539`, `tool/measure_rules.dart:4207-4210`
**처리 상태:** 소유자가 `deferred` 로 두었다 (v2 RULES-13 의 선행 작업, `.planning/REQUIREMENTS.md` RULES-13 아래 메모, 04-12). 코드는 바뀌지 않았으므로 결함은 그대로 해당한다.
**Issue:** 복사본은 `path:` 로 작업 중인 저장소를 받으므로, 기준선 `B0` 에 그때의 `lib/base.yaml` 이 이미 적용된다. 그룹의 값은 "그룹 실행 − 기준선" 이다 (3535-3538). 그런데 `currentRules` 는 여전히 1.3.0 의 6개다. 지금 `lib/base.yaml` 은 81개를 켜므로, 다시 재면 G1 ~ G3 에 든 채택 규칙 75개가 기준선에도 같은 줄로 있어 값이 0 이 된다. 이어 markers 단계가 표식을 넣으면 평가표는 `0 (표식 1)` 로 바뀌고, 단언 (1) ~ (7) 가운데 어느 것도 이것을 잡지 못한다. `recommend` 의 비호환 판정(4207-4210)도 같은 6개만 본다. 커밋된 R1 값에는 영향이 없다.
**Fix:** 시작할 때 `lib/base.yaml` 에서 켠 규칙을 읽어 `current` 로 다루거나, 겹치면 멈춘다.

```dart
final shipped = declaredRuleNames(File('${repo.root}/lib/base.yaml').readAsStringSync()).toSet();
final stale = [for (final c in candidates) if (c.group != 'current' && shipped.contains(c.name)) c.name];
if (stale.isNotEmpty) {
  throw StateError('lib/base.yaml 이 이미 켠 후보 ${stale.length}개 — 기준선에 섞여 값이 0 이 된다: ${stale.join(', ')}');
}
```

`recommend` 의 `currentRules.contains(other)` 도 `shipped.contains(other)` 로 바꾼다. (두 도구는 서로 import 하지 않으므로, 04-13 이 고친 `declaredRuleNames` 를 옮겨 쓸 때는 따옴표 · 읽지 못하는 줄 처리까지 같게 옮긴다.)

## Warnings

### WR-01: 같은 id 의 회차를 덮어써도 행이 옛 회차를 계속 가리킨다 — 수치의 출처 추적(RULES-05)이 조용히 끊긴다

**File:** `tool/measure_rules.dart:1950-1958`, `tool/measure_rules.dart:3519-3555`, `tool/measure_rules.dart:4515-4529`, `tool/measure_rules.dart:4955-4967`
**Issue:** `addRun` 은 같은 id 의 회차를 통째로 바꾼다. 범위를 좁힌 재실행(`--rules`)은 범위 밖 행의 `counts` · `runs` 를 그대로 두므로, 그 행들은 자기 규칙을 켜지 않은 회차를 출처로 가리킨다. 단언 (5) 는 회차가 "있고 유효한지" 만 본다. `recountRows` 도 행의 `runs` 나 회차의 `options.rules` 를 보지 않고 고정 id(`B0` · `G1` · `primaryRunId(c)` · `<g>-strip`)로 값을 다시 쓴다. 그래서 위 상태에서 `--recount --write` 를 돌리면, 출처만 끊겼던 행의 **값까지** 그 규칙을 켜지 않은 회차의 차이(0)로 바뀐다. 커밋된 R1 에는 이 어긋남이 없다.
**Fix:** `buildReport` 에 단언을 하나 더한다 — 행이 참조한 그룹 회차의 `options.rules` (또는 `options.language`)에 그 규칙이 있어야 한다. `recountRows` 는 쓰려는 회차가 행의 `runs` 에 있고 그 회차가 규칙을 켰을 때만 칸을 다시 쓰고, 아니면 그 행을 화면에 찍고 건너뛴다.

### WR-03: `--out` 을 검사하지 않는다 — 원본(사용 프로젝트)이나 저장소의 아무 파일에나 쓸 수 있다

**File:** `tool/measure_rules.dart:1536-1545`, `tool/measure_rules.dart:5140-5148`
**Issue:** `--work` 는 저장소 · 원본과의 포함 관계를 검사하지만 `--out` 은 절대 경로로 바꾸기만 한다. 쓰기는 마지막 지문 비교 **뒤에** 하므로 지문으로도 잡히지 않는다. `--out lib/base.yaml` 같은 오타는 배포 파일을 JSON 으로 덮어쓰고, 원본 안의 경로는 PROJECT.md Safety("원본은 읽기만")를 깬다.
**Fix:**

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

**File:** `tool/measure_rules.dart:1476-1478`, `tool/measure_rules.dart:2131-2135`, `tool/measure_rules.dart:2154-2158`, `tool/measure_rules.dart:2338-2340`, `tool/measure_rules.dart:2940-2941`, `tool/measure_rules.dart:2986-2987`
**Issue:** `--work` 는 "저장소 밖" 과 "원본과 서로의 안이 아님" 만 확인한다. 저장소를 품은 상위 폴더도 받는다. 그 뒤 `_reset` · `refreshSources` · `analyze` · `measureState` 가 `<work>` 아래 같은 이름의 폴더를 확인 없이 `deleteSync(recursive: true)` 한다.
**Fix:** 작업 폴더가 비어 있거나 이 도구가 만든 표시 파일(`<work>/.woody_measure_rules`)이 있을 때만 쓴다. 저장소나 원본을 품은 폴더(`isWithin(repo.root, resolvedWork)`)는 거부한다.

### WR-07: 상태 출처의 캐시가 tag 를 가리지 않고, `sdkTag` 와 실행 SDK 를 견주지 않는다

**File:** `tool/measure_rules.dart:50`, `tool/measure_rules.dart:2897-2912`
**Issue:** `messages.yaml` 은 `<work>/upstream/messages.yaml` 에 한 번 받으면 다시 받지 않는데, `stateSource` 에는 그때의 상수 `messages.yaml@$sdkTag` 를 적는다. Dart 3.14 재측정(D-09) 때 `sdkTag` 를 올리고 같은 작업 폴더를 쓰면 3.13.4 의 상태를 3.14 의 것으로 적는다. `sdkTag` 와 `dartVersion()` 을 견주는 곳도 없다.
**Fix:** 캐시 이름에 tag 를 넣는다 (`upstream/messages-$sdkTag.yaml`). 시작할 때 `dartVersion() != sdkTag` 면 멈추거나 경고한다.

### WR-08: 단계가 예외로 끝나면 저장소 지문을 견주지 않고 결과도 저장하지 않는다

**File:** `tool/measure_rules.dart:3091-3104`
**Issue:** `RepoGuard.step` 은 `await body()` 가 던지면 곧바로 빠져나간다. 그 단계가 저장소를 바꿨는지 확인하지 않고(D-09 "단계마다 지문을 비교"), 단계 안에서 끝낸 회차도 저장하지 않는다 (`fix` 만 규칙마다 저장).
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

### WR-09: `--recount` 가 `fixSkipped` 를 원인을 확인하지 않고 R1 전용 문장으로 적고, 어느 단계도 지우지 않는다 — 단언 (2) 를 우회하고 권고를 뒤집는다

**File:** `tool/measure_rules.dart:4985-4997`, `tool/measure_rules.dart:4161-4168`, `tool/measure_rules.dart:4462-4467`, `tool/measure_rules.dart:4220-4225`, `tool/measure_rules.dart:3868-3912`
**처리 상태:** 소유자가 `deferred` 로 두었다 (`.planning/REQUIREMENTS.md` RULES-13 아래 둘째 메모, 04-13 Task 3). 코드는 바뀌지 않았으므로 결함은 그대로 해당한다.
**Issue:** `recountRows` 는 "값 > 0 · `fixRemoved` 없음 · `aloneDry` 없음 · `apply-<규칙>` 회차 없음" 인 행이면 모두 `fixSkipped` 를 적는다. 사유 문장은 "`<run id>` 의 fix 단계는 이 규칙의 값이 0 으로 집계된 채 돌아 …" 로 고정이다. 그런데 이 조건은 fix 단계가 돌지 않았거나 중간에 죽은 경우(WR-08)에도 똑같이 성립한다. `fixSkipped` 가 붙으면 다음 셋이 따라온다. (1) 단언 (2) 가 빈 `fixRemoved` · `newErrors` 를 빠진 칸으로 세지 않는다. (2) `manualLines` 가 경고 전부를 손으로 고칠 줄로 보므로 `recommend` 가 `안 켬` 으로 뒤집힐 수 있다. (3) `measureFix` 가 `fixSkipped` 를 지우지 않는데 `fixCell` 이 그것을 먼저 보므로, 나중에 잰 값이 표에 나오지 않는다. 지난 리뷰가 복사본에서 재현했다 (R1 JSON 의 `directives_ordering` fix 칸을 지운 꼴 → `--report` rc 1 이 `--recount --write` 뒤 rc 0 · 사실이 아닌 각주). 커밋된 R1 에는 `sort_pub_dependencies` 한 행뿐이고 그 사유는 사실이다.
**Fix:** `fixSkipped` 는 원인이 확인될 때만 적는다 (fix 단계가 그 run id 로 돌았다는 기록이 있고 그때 이 행의 값이 0 이었을 때). 그 밖에는 `--recount` 가 행을 찍고 `--report` 가 단언 (2) 로 실패하게 둔다. `measureFix` 는 `row.remove('fixSkipped')` 한다. `fixCell` 은 `fixRemoved is int` 를 먼저 본다.

```dart
// measureFix — 값을 쓰기 전에
row.remove('fixSkipped');

// fixCell
final removed = row['fixRemoved'];
if (removed is int) return row['aloneDry'] == 0 ? '0 (dry 0)' : '$removed';
if (row['fixSkipped'] is String) return '재지 않음';
```

### WR-11: `[3/10]` 의 겹침 · `RULES.md` 일치 검사가 `lib/base.yaml` 만 읽는다 — `lib/codegen.yaml` · `lib/riverpod.yaml` 에 적은 규칙은 두 검사를 모두 지나친다

**File:** `tool/verify.dart:1369-1382` ((b)), `tool/verify.dart:1420-1424` ((c)), `tool/verify.dart:148-151` (`rulesFile` — "codegen.yaml 과 plugins: 를 뺀 riverpod.yaml 에는 규칙이 없다" 를 단정만 한다)
**Issue:** (b) 와 (c) 는 `declaredRuleNames(File(rulesFile))` 하나만 본다. 그런데 사용 프로젝트에 전달되는 조각은 셋이다. `lib/recommended.yaml` 과 별칭 `lib/analysis_options.yaml` 이 `base.yaml` · `riverpod.yaml` · `codegen.yaml` 을 모두 include 하고, analyzer 는 include 한 파일들의 `linter: rules:` 를 합친다. `codegen.yaml` · `riverpod.yaml` 에 `linter:` 블록이 생겨도 막는 단계가 없다. `[2/10]` 은 복사본을 분석해 deprecated / 없는 규칙만 잡는다. (a) 의 "include 만" 확인은 묶음 · 별칭에만 건다. `[4/10]` 은 연습용 프로젝트의 옵션 파일만 견준다. 정답지 단계는 샘플에 걸리는 규칙만 잡는데, 걸린 것도 `--update` 한 번이면 정답지에 굳는다. 04-13 이 닫으려던 D-11 의 거짓 통과(기반 세트와 겹친 규칙, `RULES.md` 에 없는 규칙)가 다른 파일로 그대로 남는다. 복사본에서 재현했다.

```text
lib/codegen.yaml 끝에 "linter:\n  rules:\n    - avoid_print # 기반 세트와 겹침\n    - prefer_mixin # RULES.md 켠 규칙 표에 없음"
  → [1/10] ~ [10/10] 모두 통과, 점검 통과 (10개 중 10개), rc 0
    (같은 두 줄을 lib/base.yaml 에 두면 M26 · M27 · M28 처럼 [3/10] 이 실패한다)
lib/codegen.yaml 끝에 "linter:\n  rules:\n    - avoid_positional_boolean_parameters"
  → [3/10] 통과, [5/10] · [9/10] · [10/10] 만 실패 (정답지에 없는 lib/style_rules.dart:76 · :113 avoid_positional_boolean_parameters)
    — 사용 프로젝트가 이 규칙을 받는다는 증거. 같은 상태에서 example/ 의 한 파일 `void probeFlag(bool flag) {}` 를
      dart analyze 하면 avoid_positional_boolean_parameters (info) 가 나온다. 정답지 차이는 --update 로 사라지고,
      그 뒤에는 RULES.md 에 없는 규칙이 rc 0 으로 남는다
```

이 저장소의 관례(규칙은 `lib/base.yaml` 에만 — 03-REVIEW.md WR-01)를 벗어나야 생긴다. 그래서 WR-10 과 같은 까닭으로 Warning 으로 둔다. 지금의 세 조각에는 `linter:` 블록이 없다 (확인함).
**Fix:** (b) · (c) 앞에서 `rulesFile` 밖의 조각은 규칙을 담지 않는다는 것을 확인한다. 같은 파서를 쓰므로 따옴표 · 읽지 못하는 줄의 처리도 같다.

```dart
// (b) 앞 — rulesFile 밖의 조각은 규칙을 담지 않는다 (03-REVIEW.md WR-01 의 관례를 검사로)
for (final target in ruleCheckTargets.where((t) => t != rulesFile)) {
  final extra = declaredRuleNames(File('$repoRoot/$target').readAsStringSync());
  if (extra.isNotEmpty) {
    addBlock([
      '`$target` 에 규칙이 있다 (${extra.length}) — 규칙은 `$rulesFile` 에만 적는다.',
      ...extra.map((r) => '  $r'),
    ]);
  }
}
```

## Info

### IN-01: 샘플 머리 주석의 "한 줄에서 규칙 하나만" 이 사실과 다르다

**File:** `example/lib/bug_prevention_rules.dart:3`, `example/lib/bug_prevention_rules.dart:133-136` (fixture 다섯의 복사본도 같다)
**Issue:** 135행 `x = x + 1;` 은 `parameter_assignments` 와 `join_return_with_assignment` 에 함께 걸린다. `example/README.md:43` 은 이 사실을 적지만, 파일의 머리 주석은 여전히 "한 줄에서 규칙 하나만 걸리게 둔다" 이다.
**Fix:** 135행을 return 직전 대입이 아닌 꼴로 바꾼다. 바꾸지 않으려면 머리 주석을 고친다.

### IN-02: `MessagesRule.consistent` 가 쓰이지 않는다

**File:** `tool/measure_rules.dart:2755`
**Issue:** 같은 규칙의 코드끼리 state 가 다를 때를 가르는 getter 인데 부르는 곳이 없다. `latest` 는 그 경우를 따로 다루지 않는다.
**Fix:** `readRuleStates` 에서 `!consistent` 인 규칙을 경고하거나 getter 를 지운다.

### IN-03: "Dart 파일 474개" 에 분석하지 않는 생성 파일 62개가 들어 있다

**File:** `CHANGELOG.md:181`, `RULES.md:422`, `tool/measure_rules.dart:2317-2319`, `tool/measure_rules.dart:4273-4277`
**Issue:** `dartFileTotal` 은 생성 파일까지 더하는데, 한 줄 요약 "Dart 파일 474개" 에는 그 말이 없다. 복사본은 `codegen.yaml` 의 `analyzer.exclude` 로 생성 파일 62개를 분석하지 않으므로, 분석한 파일은 412개다.
**Fix:** 요약에 분석한 파일 수(412)를 쓰거나 "생성 파일 62 포함" 을 덧붙인다.

### IN-04: `RULES.md` 의 완결성 · 사유 문장 일치를 CI 가 보지 않는다

**File:** `tool/measure_rules.dart:3994-4006`, `tool/measure_rules.dart:4812-4910`, `RULES.md:7`, `.github/workflows/verify.yml:37`
**Issue:** `--audit` 은 손으로만 돌고 `보류` 접두사를 통과로 친다. `RULES.md:7` 의 "켠 이유는 `lib/base.yaml` 의 사유 주석과 같은 문장" 은 어느 검사도 보지 않는다 (`tool/verify.dart` 에 사유 비교 없음).
**Fix:** `[3/10]` 에 켠 규칙 표의 셋째 칸 == `lib/base.yaml` 줄 끝 주석 비교를 더한다. 릴리스 전에는 `보류` 0 을 요구한다.

### IN-05: `lib/base.yaml:15` 의 템플릿 문장이 남았다

**File:** `lib/base.yaml:15`
**Issue:** "Uncomment the following section to specify additional rules." — 가리키던 주석 처리된 절은 이 phase 에서 지웠다.
**Fix:** 줄을 지운다 (머리 주석 정리가 Phase 5 의 일이면 그때).

### IN-06: `require_trailing_commas` 의 "규칙이 돌지 않음 (표식 불가)" 는 표식을 넣어 보지 않은 결론이다

**File:** `tool/measure_rules.dart:1298-1300`, `RULES.md:114`, `RULES.md:161`
**Issue:** `RULES.md:114` 는 `규칙이 돌지 않음` 을 "일부러 넣은 위반까지 0줄" 로 정의하는데, 이 규칙에는 표식을 넣지 않았다. 언어 버전 조건은 `// @dart=3.6` 파일 머리로 맞출 수 있다 (`example/lib/final_parameters_rule.dart` 와 같은 방식).
**Fix:** `// @dart=3.6` 표식을 더해 실측으로 가르거나, 이유를 "사용 프로젝트의 언어 버전에서는 돌지 않음 (규칙 소스의 language37 조건)" 으로 고친다.

### IN-07: 결과 파일 이름 · 출력 모드 · 종료 코드의 세부

**File:** `tool/measure_rules.dart:5141-5144`, `tool/measure_rules.dart:4022-4045`, `tool/measure_rules.dart:5157-5185`
**Issue:**
- 기본 `--out` 의 날짜는 결과 파일을 처음 만든 날(`conditions.date`)이다. 다른 작업 폴더에서 같은 run id 로 일부 단계만 돌리면 커밋된 `tool/measurements/<날짜>-R1.json` 을 부분 결과로 덮어쓴다.
- 출력 모드에서 `--work` 를 줬는데 `<work>/results/<id>.json` 이 없으면 알리지 않고 `tool/measurements/` 의 파일로 넘어간다 (`--recount --write` 도 이 경로를 쓴다).
- `TypeError` 같은 나열하지 않은 예외는 종료 코드 255 로 끝난다 (머리 주석은 70).

**Fix:** 기존 `tool/measurements/` 파일과 run id 가 같고 회차 집합이 줄면 쓰기를 멈춘다. `--work` 를 준 출력 모드는 그 자리만 본다. 끝에 `catch (e)` 를 하나 두어 70 으로 맞춘다.

### IN-09: `--in` 의 사용법 오류 문구가 `--recount` 를 빠뜨렸다

**File:** `tool/measure_rules.dart:1470-1472`
**Issue:** 측정 모드에 `--in` 을 주면 "`--in 은 출력 모드(--summary · --report)에만 쓴다`" 를 찍는다. `--recount` 도 `--in` 을 받는다 (`usage` 1344행).
**Fix:** 문구를 `(--summary · --report · --recount)` 로 고치거나 `outputModes` 에서 만든다.

### IN-10: `example/README.md` 의 `lib/added_rules.dart` 행이 "이 패키지가 기반 세트 위에 추가하는 규칙 6개" 라고 적는다

**File:** `example/lib/added_rules.dart:3` (fixture 다섯의 `lib/added_rules.dart:3` 복사본도 같다)
**처리 상태:** README 쪽 절반(`example/README.md:39`)은 04-13 Task 2 (`76dee2f`) 가 고쳤다. 새 문장 "1.3.0 부터 켜 둔 규칙 6개 … 나머지 75개의 샘플은 아래 파일들과 `pubspec.yaml` 에 있다" 는 사실과 같다 (81개 모두 정답지에 있음을 확인). 샘플 머리 주석은 소유자 결정(§2 — 코드와 샘플은 건드리지 않는다)으로 그대로 두었다.
**Issue:** 남은 절반이 지금도 사실과 다르다. `example/lib/added_rules.dart:3` 은 "woody_lints 가 기반 세트(flutter_lints / lints) 위에 추가하는 규칙 6개를" 이다. 지금 이 패키지가 더하는 규칙은 81개이고, 이 파일이 어기는 것은 그 가운데 1.3.0 부터 켠 6개다. 같은 폴더의 README 와 샘플이 이제 서로 다른 범위를 적는다.
**Fix:** 머리 주석을 "woody_lints 1.3.0 부터 켜 둔 규칙 6개를" 로 고치고 fixture 다섯의 복사본에도 같게 옮긴다 (정답지 줄 번호는 바뀌지 않는다 — 주석 한 줄 안의 문구만 바꾼다).

### IN-11: "가린 줄이 음수인 행은 무시 주석 자체를 보는 규칙이다" 는 확인하지 않은 원인을 생성기가 단정한다

**File:** `tool/measure_rules.dart:4721-4734`, `RULES.md:420`
**Issue:** 각주는 `ignored` 합이 음수인 행을 모두 모아 "무시 주석 자체를 보는 규칙이다" 고 적는다. 지금의 두 행(`document_ignores` · `unnecessary_ignore`)에는 맞지만, 생성기는 원인을 보지 않는다. 다음 재측정에서 다른 까닭으로 음수가 된 행에도 같은 문장이 붙고, `--report --write` 가 만든 절은 손으로 고치지 않는다.
**Fix:** 문장을 사실만 적게 바꾸거나("가린 줄이 음수인 행 — 주석을 걷어낸 실행에서 줄이 줄었다: …"), 원인을 단정할 이름 목록을 상수로 두고 그 밖의 음수 행은 단언으로 멈추게 한다.

### IN-12: 04-13 소절의 "두 규칙은 샘플에 걸리지 않는다" 가 `avoid_print` 에는 사실과 다르다

**File:** `example/README.md:307`
**Issue:** M27 의 읽는 법은 "`[2/10]` 과 정답지 단계가 통과한 까닭은 M20 · M26 과 같다 — 조각의 복사본은 기반 세트와 겹친 규칙을 경고하지 않고, 두 규칙은 샘플에 걸리지 않는다" 이다. 그런데 `avoid_print` 는 샘플에 걸린다 — `lib/base_rules.dart:22  info  avoid_print` 가 `example/expected_diagnostics.txt:12` 와 fixture 넷의 정답지에 있다. M27 에서 정답지 단계가 통과한 까닭은 같은 파일의 M20 읽는 법(258행)이 적은 대로다. 기반 세트 `flutter.yaml` 이 이미 켜므로 다시 적어도 진단이 한 줄도 달라지지 않는다. "샘플에 걸리지 않는다" 는 M28 의 `prefer_mixin` 에만 맞는다. M26 의 읽는 법(284행)에서 온 문장인데, 거기서는 `[2/10]` 에 대한 말이었고 이번에는 정답지 단계까지 넓혀 적었다.
**Fix:** "… 조각의 복사본은 기반 세트와 겹친 규칙을 경고하지 않는다. 정답지 단계는 `avoid_print` 를 기반 세트가 이미 켜므로(M20) 진단이 달라지지 않고, `prefer_mixin` 은 샘플에 걸리지 않는다." 로 고친다.

### IN-13: `readRuleNameAt` 은 옛 패턴을 그대로 써서, 따옴표 이름 줄의 `[2/10]` 실패 출력에서 규칙 이름이 빠진다

**File:** `tool/verify.dart:857-865` (862행 `RegExp(r'^\s*-\s*([A-Za-z0-9_]+)')`), `tool/verify.dart:888-890`
**처리 상태:** 소유자가 04-13 에서 `readRuleNameAt` 을 바꾸지 않기로 했다 (owner-decisions 2026-10-13 §1 의 NOT approved — "실패 출력을 꾸밀 뿐"). 결과는 출력에만 미친다.
**Issue:** 04-13 뒤로 같은 파일의 두 파서가 같은 줄을 다르게 읽는다. `declaredRuleNames` 는 `- 'x'` · `- "x"` 를 규칙으로 받는다. `[2/10]` 의 진단 줄에 규칙 이름을 붙이는 `readRuleNameAt` 은 따옴표에서 맞지 않아 null 을 돌려준다. 복사본에서 재현했다.

```text
- invariant_booleans     → [2/10] "build/woody_rule_check/base/analysis_options.yaml:106  warning  removed_lint  (invariant_booleans)"
- 'invariant_booleans'   → [2/10] "build/woody_rule_check/base/analysis_options.yaml:106  warning  removed_lint"   (이름 없음)
```

판정(rc 1, `[2/10]` · `[3/10]` 실패)은 같다. 하지만 이제 받는 꼴인 따옴표 이름에서 "어느 규칙을 지울지" 를 화면이 알려 주지 않는다.
**Fix:** 이름을 읽는 정규식을 상수 하나로 두고 두 함수가 함께 쓴다 (예: `final ruleItemPattern = RegExp(r'''^\s*-\s+(['"]?)([A-Za-z0-9_]+)\1(?:\s+#.*)?\s*$''');`, `readRuleNameAt` 은 `group(2)`).

### IN-14: 읽지 못하는 줄의 `FormatException` 문구가 파일을 적지 않고, 부르는 쪽의 문서 주석은 예외를 말하지 않는다

**File:** `tool/verify.dart:912-916`, `tool/verify.dart:867-870` (`countDeclaredRules` 문서), `tool/verify.dart:982-983` (`checkRuleNames` 문서), `tool/verify.dart:1089`
**Issue:**
- stderr 한 줄은 `` 파일 모양이 예상과 다르다: `linter:` 블록의 106행을 읽지 못했다 — … `` 이다. 어느 파일의 106행인지 적지 않는다. 이 실행은 단계 줄을 하나도 찍지 않고 끝나므로(stdout 0바이트) 그 한 줄이 받는 사람이 보는 전부다. 같은 파일의 다른 `FormatException` 은 파일을 적는다 (`stripPlugins` 의 `$shownAs`, `readUpstreamRules` 의 `$folder $fileName`).
- `[2/10]` 경로(M29 · M30)의 행 번호는 `lib/base.yaml` 이 아니라 `plugins:` 를 뺀 복사본 `rulesCopy` 의 행 번호다. 지금은 `lib/base.yaml` 에 `plugins:` 가 없어 같다. 하지만 `rulesFile` 을 다른 조각으로 옮기면(그 단계의 안내 문구가 권하는 일) `fragmentLineHint` 가 경고하는 그 어긋남이 이 문구에도 생긴다.
- `countDeclaredRules` 의 문서는 "블록이 없으면 0 이다", `checkRuleNames` 의 문서는 "규칙을 하나도 읽지 못하면 … 실패다" 만 적는다. 이제 둘 다 `FormatException` 으로 실행 전체를 끝낼 수 있다는 말이 없다.
- 실행 중에 찍히는 문구와 코드 주석이 `04-REVIEW.md WR-10` 을 가리키지만, 그 절은 이번 리뷰로 사라진다 (고쳐진 발견은 목록에서 빠진다). 기록이 남는 곳은 `04-REVIEW-DISPOSITION.md` 다. (`WR-06` · `CR-02` 를 가리키는 기존 문구도 같다.)

**Fix:** `declaredRuleNames(String options, {required String shownAs})` 로 파일 이름을 받아 문구 앞에 붙이고(`'$shownAs 의 \`linter:\` 블록의 ${i + 1}행 …'`), `[2/10]` 은 `countDeclaredRules` 를 복사본이 아닌 원본 본문으로 부르거나 `shownAs: '$rulesFile (plugins: 를 뺀 복사본)'` 으로 적는다. 두 문서 주석에 "읽지 못하는 줄이 있으면 [FormatException] (main 이 70)" 을 더한다. 실행 문구의 참조는 `04-REVIEW-DISPOSITION.md` 나 결정 번호(D-11)처럼 남는 기록을 가리키게 한다.

---

_Reviewed: 2026-10-13T12:54:29Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
