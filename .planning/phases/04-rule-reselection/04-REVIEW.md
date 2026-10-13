---
phase: 04-rule-reselection
reviewed: 2026-10-13T09:10:18Z
depth: standard
files_reviewed: 18
files_reviewed_list:
  - CHANGELOG.md
  - RULES.md
  - example/README.md
  - example/expected_diagnostics.txt
  - example/pubspec.yaml
  - fixtures/base_codegen/expected_diagnostics.txt
  - fixtures/base_codegen/pubspec.yaml
  - fixtures/base_only/expected_diagnostics.txt
  - fixtures/base_only/pubspec.yaml
  - fixtures/base_riverpod/expected_diagnostics.txt
  - fixtures/base_riverpod/pubspec.yaml
  - fixtures/overrides/expected_diagnostics.txt
  - fixtures/overrides/pubspec.yaml
  - fixtures/recommended/pubspec.yaml
  - lib/base.yaml
  - tool/measure_rules.dart
  - tool/measurements/2026-10-13-R1.json
  - tool/verify.dart
findings:
  critical: 1
  warning: 7
  info: 11
  total: 19
status: issues_found
---

# Phase 4: Code Review Report (재리뷰 — gap 수정 04-11 · 04-12 뒤)

**Reviewed:** 2026-10-13T09:10:18Z
**Depth:** standard
**Files Reviewed:** 18
**Status:** issues_found

## Summary

gap 수정 plan 04-11 · 04-12 가 `03d457a..HEAD` 에서 바꾼 파일 18개를 다시 봤다. 지난 리뷰의 발견 18건은 하나씩 지금 코드와 대조했고, 새 코드(`--recount`, 단언 (7), `fixSkipped`, `valueAreas`, `declaredRuleNames` 의 주석 처리, 상류 YAML 0규칙 guard)는 처음 보는 코드로 다시 읽었다.

실행으로 확인한 것 (발견 아님):

- 저장소에서 (읽기만 하는 출력 모드): `--recount --in tool/measurements/2026-10-13-R1.json` → `다시 센 행 133개 — 바뀐 행이 없다` (rc 0). `--audit` → `감사 통과 — 켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0` (rc 0). `--report --in …` (rc 0) 의 출력이 `RULES.md` 의 `woody:measurements` 구역(218 ~ 425행 사이)과 글자 그대로 같다.
- 리뷰어 임시 폴더(scratchpad 아래 `reviewer-` 로 시작하는 폴더)에 `git archive HEAD` 로 만든 복사본에서: `fvm dart run tool/verify.dart` → `점검 통과 (10개 중 10개)` (rc 0, 72초).
- 같은 복사본에서 M26 입력(열 0 주석 + `- avoid_print` + `- prefer_mixin`)을 다시 만들어 돌렸다 → `[3/10]` 만 실패, `+ avoid_print` · `+ prefer_mixin` · 겹침 `avoid_print (flutter_lints-6.0.0 flutter.yaml)`, `점검 실패 (10개 중 1개)` (rc 1). CR-02 는 고쳐졌다.
- 단언 (7): 복사본에서 G1 · G1-strip 의 `pubspec.yaml` 자리를 `integration_test` 로 옮긴 JSON → `--report` 가 `값에 넣지 않은 자리에 진단이 있는 행 1개: sort_pub_dependencies (integration_test)` 로 멈춘다.
- 문서 대조 (스크립트): `lib/base.yaml` 규칙 81개 == `RULES.md` 켠 규칙 표 81행, 사유 81개 글자 그대로 같음. CHANGELOG "추가한 규칙" 75 · "새로 생기는 경고" 75행 == 81 − 1.3.0 의 6개, 건수(네 자리 합) · 강도가 R1 JSON 과 모두 같다. R1 JSON 에 `/` 가 든 문자열은 `lib/woody_probe_marker/` 표식 경로뿐이다 (D-07).
- `example/README.md` 파일 표의 줄 수 합(6+7+1+3+25+8+38+2+1+1+1 = 93)과 연습용 프로젝트 여섯 표(93 · 93 · 95 · 104 · 98 · 90)가 정답지에서 다시 센 값과 같다.

지금 남은 가장 무거운 것은 그대로인 CR-03 (소유자가 `deferred` 로 둠) 이다. 새 발견 가운데 무거운 것은 둘이다. (1) `--recount` 가 `fixSkipped` 를 원인을 확인하지 않고 R1 전용 문장으로 적고, 어느 단계도 그것을 지우지 않는다. 그래서 `--report` 의 단언 (2) 를 우회하고 권고를 뒤집을 수 있다 (WR-09, 복사본에서 재현). (2) `[3/10]` 이 따옴표로 감싼 규칙 이름을 읽지 못한다. CR-02 와 같은 거짓 통과가 다른 입력으로 남았다 (WR-10, 복사본에서 rc 0 재현).

작업 트리는 바꾸지 않았다. 리뷰 전후 저장소의 `git status --porcelain` 은 시작할 때의 넷(`.planning/config.json` 수정, 추적하지 않는 `.planning/state.json` · `.planning/milestone.lock` · `.planning/research/.cache/`)과 이 파일뿐이다.

## 지난 리뷰의 발견 18건 — 지금 상태

| ID | 제목 | 지금 상태 | 근거 |
|---|---|---|---|
| CR-01 | `pubspec.yaml` 의 진단을 버려 `sort_pub_dependencies` 의 실측 2줄이 0줄로 기록됐다 — 소유자 결정의 근거가 사실과 다르다 | 고쳐짐 | `tool/measure_rules.dart:1726-1734` (`valueAreas` 에 `pubspec.yaml`), `:3315-3323` (`ruleCounts`), 단언 (7) `:4550-4582`. R1 행 `counts = {lib 0, test 0, bin 0, pubspec.yaml 2}`. `RULES.md:49` (켠 규칙) · `:376` (`2 (0·0·0·2)`). 틀린 0 을 근거로 한 켜지 않은 규칙 행은 지워졌다. `--recount` 재실행 "바뀐 행이 없다", 단언 (7) 변형 JSON 으로 실패 확인 |
| CR-02 | `[3/10]` 이 `linter:` 블록 안의 열 0 주석 뒤에 적힌 규칙을 보지 못한다 — 겹침 · `RULES.md` 일치 검사의 거짓 통과 | 고쳐짐 | `tool/verify.dart:884-886`. 복사본에서 M26 입력 → `[3/10]` 실패, rc 1. (같은 꼴의 다른 입력은 새 발견 WR-10) |
| CR-03 | 측정 도구가 "지금 켜 둔 규칙" 을 1.3.0 의 6개로 박아 두어, 지금 저장소에서 다시 재면 채택한 74개가 모두 0줄이 된다 | 그대로 해당 — 소유자 결정으로 `deferred` (REQUIREMENTS.md RULES-13 아래 메모, 04-12) | `tool/measure_rules.dart:273-280` (`currentRules` 6개 그대로), `:415`, `:3533-3539`, `:4207-4210`. 지금 `lib/base.yaml` 은 81개다 |
| WR-01 | 같은 id 의 회차를 덮어써도 행이 옛 회차를 계속 가리킨다 — 수치의 출처 추적(RULES-05)이 조용히 끊긴다 | 그대로 해당 | `tool/measure_rules.dart:1950-1958` (`addRun` 이 통째로 바꿈), 단언 (5) `:4515-4529` 는 회차가 있고 유효한지만 본다. 새 `--recount` (`:4955-4967`) 도 같은 가정 위에서 값을 다시 쓴다 |
| WR-02 | 음수인 "가린 줄" 이 `0` 으로 찍힌다 | 고쳐짐 | `tool/measure_rules.dart:4104` (`n != 0`). `RULES.md:324` `-48 (-1·-46·-1·0)`, `:390` `-12 (-1·-10·-1·0)` |
| WR-03 | `--out` 을 검사하지 않는다 — 원본(사용 프로젝트)이나 저장소의 아무 파일에나 쓸 수 있다 | 그대로 해당 | `tool/measure_rules.dart:1536-1545` (`absoluteNormalized` 만), `:5140-5148` (지문 비교 뒤에 쓴다) |
| WR-04 | `--work` 가 남의 폴더여도 그 아래 `consumer/` · `pristine/` · `pkg13/` · `state/<id>/` 를 지운다 | 그대로 해당 | `tool/measure_rules.dart:1476-1478` (저장소 밖인지만), `:2131-2135`, `:2154-2158`, `:2338-2340`, `:2940-2941`, `:2986-2987` |
| WR-05 | `example/README.md` 의 줄 수 · 파일 표가 이 phase 의 샘플을 반영하지 않았다 | 고쳐짐 | `example/README.md:39-54` · `:62-67`. 정답지에서 다시 센 값(93 · 95 · 98 · 104 · 90, 파일별 6 · 7 · 1 · 3 · 25 · 8 · 38 · 2 · 1 · 1 · 1)과 같다. (`added_rules.dart` 행의 문장은 새 발견 IN-10) |
| WR-06 | 기반 세트 YAML 에서 규칙을 하나도 읽지 못해도 겹침 검사가 통과한다 | 고쳐짐 | `tool/verify.dart:1239-1250`, `tool/measure_rules.dart:2722-2734` — 파일마다 0개면 `FormatException` |
| WR-07 | 상태 출처의 캐시가 tag 를 가리지 않고, `sdkTag` 와 실행 SDK 를 견주지 않는다 | 그대로 해당 | `tool/measure_rules.dart:50`, `:2897` (`upstream/messages.yaml` 고정 이름), `:2911` |
| WR-08 | 단계가 예외로 끝나면 저장소 지문을 견주지 않고 결과도 저장하지 않는다 | 그대로 해당 | `tool/measure_rules.dart:3091-3104` (`await body()` 에 `try/finally` 없음) |
| IN-01 | 샘플 머리 주석의 "한 줄에서 규칙 하나만" 이 사실과 다르다 | 그대로 해당 | `example/lib/bug_prevention_rules.dart:3` 그대로, `:135` 가 두 규칙에 걸림. `example/README.md:43` 이 두 줄인 것을 적었지만 머리 주석은 고치지 않았다 |
| IN-02 | `MessagesRule.consistent` 가 쓰이지 않는다 | 그대로 해당 | `tool/measure_rules.dart:2755` — 부르는 곳 0 (`grep -n "\.consistent"` 0줄) |
| IN-03 | "Dart 파일 474개" 에 분석하지 않는 생성 파일 62개가 들어 있다 | 그대로 해당 | `CHANGELOG.md:181`, `RULES.md:422`, `tool/measure_rules.dart:2317-2319`, `:4273-4277` |
| IN-04 | `RULES.md` 의 완결성 · 사유 문장 일치를 CI 가 보지 않는다 | 그대로 해당 | `tool/verify.dart` 에 사유 비교 없음, `.github/workflows/verify.yml:37` 은 `verify.dart` 만 돌린다. `--audit` (`tool/measure_rules.dart:4812`) 은 손으로만, `보류` 를 통과로 친다 (`:3994-4006`, `:4902`) |
| IN-05 | `lib/base.yaml:15` 의 템플릿 문장이 남았다 | 그대로 해당 | `lib/base.yaml:15` "Uncomment the following section to specify additional rules." |
| IN-06 | `require_trailing_commas` 의 "규칙이 돌지 않음 (표식 불가)" 는 표식을 넣어 보지 않은 결론이다 | 그대로 해당 | `tool/measure_rules.dart:1298-1300`, `RULES.md:161` |
| IN-07 | 결과 파일 이름 · 출력 모드 · 종료 코드의 세부 | 그대로 해당 | `tool/measure_rules.dart:5141-5144` (기본 `--out` 의 날짜), `:4029-4032` (`--work` 의 파일이 없으면 알리지 않고 넘어감), `:5157-5185` (나열하지 않은 예외는 255) |

## Critical Issues

### CR-03: 측정 도구가 "지금 켜 둔 규칙" 을 1.3.0 의 6개로 박아 두어, 지금 저장소에서 다시 재면 채택한 74개가 모두 0줄이 된다

**File:** `tool/measure_rules.dart:273-280`, `tool/measure_rules.dart:415`, `tool/measure_rules.dart:3533-3539`, `tool/measure_rules.dart:4207-4210`
**처리 상태:** 소유자가 `deferred` 로 두었다 (v2 RULES-13 의 선행 작업, `.planning/REQUIREMENTS.md` RULES-13 아래 메모, 04-12). 코드는 바뀌지 않았으므로 결함은 그대로 해당한다.
**Issue:** 복사본은 `path:` 로 작업 중인 저장소를 받으므로 기준선 `B0` 에 그때의 `lib/base.yaml` 이 이미 적용된다. 그룹의 값은 "그룹 실행 − 기준선" 이다 (3535-3538). `currentRules` 는 여전히 1.3.0 의 6개다. 지금 `lib/base.yaml` 은 81개를 켜므로, 다시 재면 G1 ~ G3 에 든 채택 규칙 75개(04-12 의 `sort_pub_dependencies` 포함)가 기준선에도 같은 줄로 있어 값이 0 이 된다. 이어 markers 단계가 표식을 넣으면 평가표는 `0 (표식 1)` 로 바뀌고, 단언 (1) ~ (7) 가운데 어느 것도 이것을 잡지 못한다. `recommend` 의 비호환 판정(4207-4210)도 같은 6개만 본다. 커밋된 R1 값에는 영향이 없다 (R1 을 잴 때 `lib/base.yaml` 은 6개였다).
**Fix:** 시작할 때 `lib/base.yaml` 에서 켠 규칙을 읽어 `current` 로 다루거나, 겹치면 멈춘다.

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

**File:** `tool/measure_rules.dart:1950-1958`, `tool/measure_rules.dart:3519-3555`, `tool/measure_rules.dart:4515-4529`, `tool/measure_rules.dart:4955-4967`
**Issue:** `addRun` 은 같은 id 의 회차를 통째로 바꾼다. 범위를 좁힌 재실행(`--rules`)은 범위 밖 행의 `counts` · `runs` 를 그대로 두므로, 그 행들은 자기 규칙을 켜지 않은 회차를 출처로 가리킨다. 단언 (5) 는 회차가 "있고 유효한지" 만 본다. 이번에 더한 `--recount` 도 같은 가정 위에 있다. `recountRows` 는 행의 `runs` 나 회차의 `options.rules` 를 보지 않고 고정 id(`B0` · `G1` · `primaryRunId(c)` · `<g>-strip`)로 값을 다시 쓴다. 그래서 위 상태에서 `--recount --write` 를 돌리면, 출처만 끊겼던 행이 그 규칙을 켜지 않은 회차의 차이(0)로 **값까지** 바뀐다. G4 행의 `counts = G1 − B0` (4961-4963) 도 G1 이 G4 규칙을 켰다는 전제를 확인하지 않는다. 커밋된 R1 에는 이 어긋남이 없다.
**Fix:** `buildReport` 에 단언을 하나 더한다 — 행이 참조한 그룹 회차의 `options.rules` (또는 `options.language`)에 그 규칙이 있어야 한다. `recountRows` 는 쓰려는 회차가 행의 `runs` 에 있고 그 회차가 규칙을 켰을 때만 칸을 다시 쓰고, 아니면 그 행을 화면에 찍고 건너뛴다.

### WR-03: `--out` 을 검사하지 않는다 — 원본(사용 프로젝트)이나 저장소의 아무 파일에나 쓸 수 있다

**File:** `tool/measure_rules.dart:1536-1545`, `tool/measure_rules.dart:5140-5148`
**Issue:** `--work` 는 저장소 · 원본과의 포함 관계를 검사하지만 `--out` 은 절대 경로로 바꾸기만 한다. 쓰기는 마지막 지문 비교 **뒤에** 하므로 지문으로도 잡히지 않는다. `--out lib/base.yaml` 같은 오타는 배포 파일을 JSON 으로 덮어쓰고, 원본 안의 경로는 PROJECT.md Safety("원본은 읽기만")를 깬다. 04-11 · 04-12 는 이 부분을 바꾸지 않았다.
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
**Issue:** `--work` 는 "저장소 밖" 과 "원본과 서로의 안이 아님" 만 확인한다. 저장소를 품은 상위 폴더도 받는다. 그 뒤 `_reset` · `refreshSources` · `analyze` · `measureState` 가 `<work>` 아래 같은 이름의 폴더를 확인 없이 `deleteSync(recursive: true)` 한다. 바뀌지 않았다.
**Fix:** 작업 폴더가 비어 있거나 이 도구가 만든 표시 파일(`<work>/.woody_measure_rules`)이 있을 때만 쓴다. 저장소나 원본을 품은 폴더(`isWithin(repo.root, resolvedWork)`)는 거부한다.

### WR-07: 상태 출처의 캐시가 tag 를 가리지 않고, `sdkTag` 와 실행 SDK 를 견주지 않는다

**File:** `tool/measure_rules.dart:50`, `tool/measure_rules.dart:2897-2912`
**Issue:** `messages.yaml` 은 `<work>/upstream/messages.yaml` 에 한 번 받으면 다시 받지 않는데, `stateSource` 에는 그때의 상수 `messages.yaml@$sdkTag` 를 적는다. Dart 3.14 재측정(D-09) 때 `sdkTag` 를 올리고 같은 작업 폴더를 쓰면 3.13.4 의 상태를 3.14 의 것으로 적는다. `sdkTag` 와 `dartVersion()` (2641) 을 견주는 곳도 없다.
**Fix:** 캐시 이름에 tag 를 넣는다 (`upstream/messages-$sdkTag.yaml`). 시작할 때 `dartVersion() != sdkTag` 면 멈추거나 경고한다.

### WR-08: 단계가 예외로 끝나면 저장소 지문을 견주지 않고 결과도 저장하지 않는다

**File:** `tool/measure_rules.dart:3091-3104`
**Issue:** `RepoGuard.step` 은 `await body()` 가 던지면 곧바로 빠져나간다. 그 단계가 저장소를 바꿨는지 확인하지 않고(D-09 "단계마다 지문을 비교"), 단계 안에서 끝낸 회차도 저장하지 않는다 (`fix` 만 규칙마다 저장). 바뀌지 않았다.
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
**Issue:** `recountRows` 는 "값 > 0 · `fixRemoved` 없음 · `aloneDry` 없음 · `apply-<규칙>` 회차 없음" 인 행이면 모두 `fixSkipped` 를 적는다. 사유 문장은 고정이다: "`<run id>` 의 fix 단계는 이 규칙의 값이 0 으로 집계된 채 돌아 …". 그런데 이 조건은 fix 단계가 아예 돌지 않았거나 중간에 죽은 경우(WR-08)에도 똑같이 성립한다. 그런 행에도 사실이 아닌 사유가 붙는다. `fixSkipped` 가 붙으면 다음 셋이 함께 따라온다.

1. 단언 (2) 가 그 행의 빈 `fixRemoved` · `newErrors` 를 빠진 칸으로 세지 않는다 (4465-4467). "fix 를 재지 않은 행" 이 단언 실패에서 각주로 바뀐다.
2. `manualLines` 가 경고 전부를 손으로 고칠 줄로 보므로 `recommend` 가 `안 켬` 으로 뒤집힐 수 있다.
3. `measureFix` 는 `fixSkipped` 를 지우지 않는다. 그런데 `fixCell` 은 `fixRemoved` 보다 `fixSkipped` 를 먼저 본다 (4165). 그래서 나중에 실제로 잰 값이 표에 나오지 않는다.

복사본에서 재현했다.

```text
A) R1 JSON 에서 directives_ordering 의 aloneDry · fixRemoved · newErrors 와 apply-directives_ordering 회차를 지움 (fix 단계가 중간에 죽은 꼴)
   --report                → rc 1, "값이 없는 행 1개: directives_ordering (빠진 칸: fixRemoved 1 · newErrors 1)"
   --recount --write       → "directives_ordering: counts 3·163·0·0 → 3·163·0·0 · fixSkipped 적음"
   --report                → rc 0, 평가표 "166 (3·163·0·0) | … | 재지 않음",
                             각주 "directives_ordering — R1 의 fix 단계는 이 규칙의 값이 0 으로 집계된 채 돌아 …" (사실이 아님)
B) R1 JSON 의 sort_pub_dependencies 에 aloneDry 2 · fixRemoved 2 · newErrors 0 을 넣음 (나중에 fix 단계가 잰 꼴, fixSkipped 는 남음)
   --report                → rc 0, dart fix 칸 "재지 않음", 각주도 그대로
```

A 의 `directives_ordering` 은 R1 에서 `dart fix` 가 166줄을 모두 고친 규칙이다. `fixSkipped` 가 붙으면 `--summary style` 의 권고 잣대(손으로 고칠 줄 ≤ 50)로는 `안 켬` 이 된다. 커밋된 R1 에는 `sort_pub_dependencies` 한 행뿐이고, 그 사유는 사실이다.
**Fix:** `fixSkipped` 는 원인이 확인될 때만 적는다. 예: fix 단계가 그 run id 로 돌았다는 기록(`conditions` 에 fix 단계가 다룬 규칙 목록)이 있고 그 목록에서 이 행의 당시 값이 0 이었을 때만 적는다. 그 밖에는 `--recount` 가 행을 찍고 `--report` 가 단언 (2) 로 실패하게 둔다. `measureFix` 는 행을 잴 때 `row.remove('fixSkipped')` 한다. `fixCell` 은 `fixRemoved is int` 를 `fixSkipped` 보다 먼저 본다.

```dart
// measureFix — 값을 쓰기 전에
row.remove('fixSkipped');

// fixCell
final removed = row['fixRemoved'];
if (removed is int) return row['aloneDry'] == 0 ? '0 (dry 0)' : '$removed';
if (row['fixSkipped'] is String) return '재지 않음';
```

### WR-10: `[3/10]` 이 따옴표로 감싼 규칙 이름을 읽지 못한다 — CR-02 와 같은 거짓 통과가 다른 입력으로 남았다

**File:** `tool/verify.dart:879-899` (880행 `rulePattern`)
**Issue:** CR-02 의 수정은 주석 · 빈 줄만 건너뛴다. 규칙 줄은 여전히 `^\s*-\s*([A-Za-z0-9_]+)` 로 읽는다. YAML 에서 `- 'avoid_print'` · `- "avoid_print"` 는 같은 문자열이고 analyzer 는 그 규칙을 켠다. 그런데 이 정규식은 따옴표에서 맞지 않아 그 줄을 건너뛴다. 그래서 겹침 검사(b)와 `RULES.md` 일치 검사(c)가 그 규칙을 보지 못한다. `[2/10]` 의 "하나도 세지 못하면 실패" 는 나머지 81개가 세어지므로 걸리지 않는다. 복사본에서 재현했다.

```text
lib/base.yaml 의 no_raw_types 뒤에  "    - 'avoid_print' # 기반 세트와 겹침 (따옴표)"
  → [1/10] ~ [10/10] 모두 통과, 점검 통과 (10개 중 10개), rc 0
같은 자리에 "    - 'cascade_invocations' # RULES.md 에 없음 (따옴표)"
  → [3/10] 통과, [5/10] · [7/10] ~ [10/10] 실패 (lib/bug_prevention_rules.dart:61  info  cascade_invocations)
    — analyzer 는 따옴표 이름을 켜는데 [3/10] 은 보지 못한다
```

CR-02 와 결과(D-11 의 거짓 통과)는 같다. 하지만 이 저장소의 관례(따옴표 없는 목록 형식)를 벗어난 입력이어야 생기므로 Warning 으로 둔다. `lib/base.yaml` 지금 판정(81개, 겹침 0, 표 일치)은 맞다.
**Fix:** 따옴표를 받아들이고, `linter:` 블록 안의 `- ` 줄인데 이름을 읽지 못하면 실패로 돌린다 (조용히 건너뛰지 않는다).

```dart
final rulePattern = RegExp(r'''^\s*-\s*(['"]?)([A-Za-z0-9_]+)\1\s*(#.*)?$''');
…
} else if (inLinter && trimmed.startsWith('-')) {
  final match = rulePattern.firstMatch(line);
  if (match == null) throw FormatException('linter: 블록의 목록 줄을 읽지 못했다: ${trimmed.split('#').first.trim()}');
  names.add(match.group(2)!);
}
```

`example/README.md` 의 M 기록에 따옴표 입력에서 `[3/10]` 이 실패하는 것을 더한다.

## Info

### IN-01: 샘플 머리 주석의 "한 줄에서 규칙 하나만" 이 사실과 다르다

**File:** `example/lib/bug_prevention_rules.dart:3`, `example/lib/bug_prevention_rules.dart:133-136` (fixture 다섯의 복사본도 같다)
**Issue:** 135행 `x = x + 1;` 은 `parameter_assignments` 와 `join_return_with_assignment` 에 함께 걸린다. 04-12 가 `example/README.md:43` 에 이 사실을 적었지만, 파일의 머리 주석은 여전히 "한 줄에서 규칙 하나만 걸리게 둔다" 이다.
**Fix:** 135행을 return 직전 대입이 아닌 꼴로 바꾼다 (예: `x = x + 1;` 뒤에 `return x * 2;`). 바꾸지 않으려면 머리 주석을 고친다.

### IN-02: `MessagesRule.consistent` 가 쓰이지 않는다

**File:** `tool/measure_rules.dart:2755`
**Issue:** 같은 규칙의 코드끼리 state 가 다를 때를 가르는 getter 인데 부르는 곳이 없다. `latest` 는 그 경우를 따로 다루지 않는다.
**Fix:** `readRuleStates` 에서 `!consistent` 인 규칙을 경고하거나 getter 를 지운다.

### IN-03: "Dart 파일 474개" 에 분석하지 않는 생성 파일 62개가 들어 있다

**File:** `CHANGELOG.md:181`, `RULES.md:422`, `tool/measure_rules.dart:2317-2319`, `tool/measure_rules.dart:4273-4277`
**Issue:** `dartFileTotal` 은 생성 파일까지 더한다 (자기 문서 주석은 "생성 파일 포함" 이라고 적는다). 그런데 한 줄 요약 "Dart 파일 474개" 에는 그 말이 없다. 복사본은 `codegen.yaml` 의 `analyzer.exclude` 로 생성 파일 62개를 분석하지 않으므로, 분석한 파일은 412개다.
**Fix:** 요약에 분석한 파일 수(412)를 쓰거나 "생성 파일 62 포함" 을 덧붙인다.

### IN-04: `RULES.md` 의 완결성 · 사유 문장 일치를 CI 가 보지 않는다

**File:** `tool/measure_rules.dart:3994-4006`, `tool/measure_rules.dart:4812-4910`, `RULES.md:7`, `.github/workflows/verify.yml:37`
**Issue:** `--audit` 은 손으로만 돌고 `보류` 접두사를 통과로 친다. `RULES.md:7` 의 "켠 이유는 `lib/base.yaml` 의 사유 주석과 같은 문장" 은 어느 검사도 보지 않는다. 지금은 81개 모두 같다 (스크립트로 확인).
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
- 출력 모드에서 `--work` 를 줬는데 `<work>/results/<id>.json` 이 없으면 알리지 않고 `tool/measurements/` 의 파일로 넘어간다. 이제 `--recount --write` 도 이 경로를 쓰므로, 작업 폴더의 JSON 을 다시 세려던 실행이 커밋된 R1 JSON 을 고쳐 쓸 수 있다.
- `TypeError` 같은 나열하지 않은 예외는 종료 코드 255 로 끝난다 (머리 주석은 70).

**Fix:** 기존 `tool/measurements/` 파일과 run id 가 같고 회차 집합이 줄면 쓰기를 멈춘다. `--work` 를 준 출력 모드는 그 자리만 본다. 끝에 `catch (e)` 를 하나 두어 70 으로 맞춘다.

### IN-08: `RULES.md` 켠 규칙 표의 머리가 `실측 (lib · test · bin)` 그대로다 — `sort_pub_dependencies` 행이 0줄처럼 읽힌다

**File:** `RULES.md:10`, `RULES.md:49`
**Issue:** 평가표 · `--summary` · CHANGELOG 는 자리를 넷(`lib·test·bin·pubspec`)으로 바꿨다. 켠 규칙 표만 머리가 셋이다. 그래서 `sort_pub_dependencies` 의 칸이 `0 · 0 · 0 (pubspec.yaml 2줄)` 이 되었다. 칸의 수는 0 이고 실제 2줄은 괄호 안 주석에만 있다. 다른 행의 괄호(`(표식 검출)`)는 0줄의 뜻을 적는 자리라서, 같은 괄호가 여기서는 다른 뜻으로 쓰인다.
**Fix:** 머리를 `실측 (lib · test · bin · pubspec)` 으로 바꾸고 행마다 넷째 칸을 둔다. 또는 이 행만 `2 (pubspec.yaml 2 — lib · test · bin 0)` 처럼 합계를 앞에 쓴다.

### IN-09: `--in` 의 사용법 오류 문구가 `--recount` 를 빠뜨렸다

**File:** `tool/measure_rules.dart:1470-1472`
**Issue:** 측정 모드에 `--in` 을 주면 "`--in 은 출력 모드(--summary · --report)에만 쓴다`" 를 찍는다. 04-11 이 더한 `--recount` 도 `--in` 을 받는다 (`usage` 1344행).
**Fix:** 문구를 `(--summary · --report · --recount)` 로 고치거나 `outputModes` 에서 만든다.

### IN-10: `example/README.md` 의 `lib/added_rules.dart` 행이 "이 패키지가 기반 세트 위에 추가하는 규칙 6개" 라고 적는다

**File:** `example/README.md:39`
**Issue:** 04-12 가 같은 표를 다시 셌지만 이 행의 문장은 1.3.0 때 그대로다. 지금 이 패키지가 더하는 규칙은 81개이고, 이 파일이 어기는 것은 그 가운데 1.3.0 부터 켠 6개다. 같은 표의 새 행들은 "04-06 에 켠 …" 처럼 범위를 적는다.
**Fix:** "1.3.0 부터 켜 둔 규칙 6개를 한 건씩 어긴다" 로 고친다. 파일 머리 주석(`example/lib/added_rules.dart:3`, 리뷰 범위 밖)도 같게 고친다.

### IN-11: "가린 줄이 음수인 행은 무시 주석 자체를 보는 규칙이다" 는 확인하지 않은 원인을 생성기가 단정한다

**File:** `tool/measure_rules.dart:4721-4734`, `RULES.md:420`
**Issue:** 각주는 `ignored` 합이 음수인 행을 모두 모아 "무시 주석 자체를 보는 규칙이다 — 주석을 걷어내면 그 규칙의 줄도 함께 사라진다" 고 적는다. 지금의 두 행(`document_ignores` · `unnecessary_ignore`)에는 맞다. 하지만 생성기는 원인을 보지 않는다. 다음 재측정에서 다른 까닭(예: strip 때문에 다른 진단이 줄어든 규칙)으로 음수가 된 행에도 같은 문장이 붙는다. `--report --write` 가 만든 절은 "손으로 고치지 않는다".
**Fix:** 문장을 사실만 적게 바꾼다 ("가린 줄이 음수인 행 — 주석을 걷어낸 실행에서 줄이 줄었다: …"). 또는 원인을 단정할 이름 목록(`document_ignores` · `unnecessary_ignore`)을 상수로 두고, 그 밖의 음수 행은 단언으로 멈추게 한다.

---

_Reviewed: 2026-10-13T09:10:18Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
