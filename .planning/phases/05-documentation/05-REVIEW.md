---
phase: 05-documentation
reviewed: 2026-10-13T20:35:05Z
depth: standard
files_reviewed: 10
files_reviewed_list:
  - tool/verify.dart
  - README.md
  - CHANGELOG.md
  - example/README.md
  - lib/base.yaml
  - lib/riverpod.yaml
  - lib/codegen.yaml
  - lib/recommended.yaml
  - lib/analysis_options.yaml
  - .claude/CLAUDE.md
findings:
  critical: 0
  warning: 6
  info: 7
  total: 13
status: issues_found
---

# Phase 5: Code Review Report

**Reviewed:** 2026-10-13T20:35:05Z
**Depth:** standard
**Files Reviewed:** 10
**Status:** issues_found

## Summary

Phase 5 에서 바뀐 파일 10개(diff base `2c026dd`)를 리뷰했다. 배포 YAML 다섯은 주석과 빈 줄만 바뀌었다. 비주석 줄은 `2c026dd` 와 같다(빈 줄만 빠졌다). 문서를 연습용 프로젝트 정답지 · spike references · git 이력과 대조한 결과는 대부분 맞다. CHANGELOG 1.1.0 ~ 1.2.5 의 커밋 해시 · 날짜 · `version:` 값은 모두 git 이력과 일치한다. README 의 끄기 예시는 `fixtures/overrides/` 의 줄과 글자가 같고, `plugin_line.dart:11` · `plugin_file_unprefixed.dart:8` 인용도 정답지와 맞는다.

결함은 주로 `tool/verify.dart` 의 새 reader 쪽에 있다. 오케스트레이터가 짚은 꼴, 곧 "같은 결함 모양, 다른 입력" 이 네 군데에서 다시 나왔다.

- README 검사 (e) · (f) · (g) 는 "읽은 값이 0개면 실패" 만 막는다. 값 하나가 정규식에 맞지 않으면 그 값을 조용히 건너뛴다. 그래서 낡은 값이 맞는 값 옆에 있으면 통과한다.
- (b′) 는 블록 형식의 `linter:` 만 본다. `linter: {rules: [...]}` 꼴로 다른 조각에 적은 규칙은 보지 않는다.

재현은 리뷰어의 저장소 복제본(`git clone --local`)에서만 했다. 작업 트리는 건드리지 않았다. 재현 방법은 두 가지다.

- **전체 실행:** `fvm dart run tool/verify.dart` 를 끝까지 돌린 것.
- **함수 단위:** `tool/verify.dart` 를 import 한 작은 하네스로 `checkShippedComposition` · `checkFixtureOptions` 를 직접 부른 것.

## Narrative Findings (AI reviewer)

## Warnings

### WR-01: README 검사 (e) 가 모양이 틀린 프리셋 주소를 조용히 건너뛴다 — 오타 주소로 통과

**File:** `tool/verify.dart:1607`
**Issue:** 주소 정규식 `package:woody_lints/([A-Za-z0-9_]+\.yaml)` 에 맞지 않는 주소는 아예 모이지 않는다. 그래서 `lib/` 에 있는지 견주는 대상에서도 빠진다. 다음 주소는 모두 "주소 없음" 이 아니라 "본 적 없음" 이 된다.

- 확장자 오타 `codegen.yml`
- 하위 경로 `presets/codegen.yaml`
- 하이픈이 든 이름 `base-rules.yaml`
- 확장자가 빠진 `package:woody_lints/codegen`

README 의 다른 주소가 맞으면 `addresses.isEmpty` 경로도 타지 않으므로 통과한다. 사용 프로젝트가 이 블록을 복사하면 `include_file_not_found` 를 받는다. 틀린 주소를 잡는 것이 (e) 의 목적인데, 잡혀야 할 입력이 정확히 그 틀린 주소다.

- **재현(전체 실행):** README 78행의 `  - package:woody_lints/codegen.yaml` 을 `codegen.yml` 로 바꿨다. 아래 WR-02 의 두 변경과 함께 돌린 실행이 종료 코드 0, `점검 통과 (10개 중 10개)` 였다.
- **재현(함수 단위):** `presets/codegen.yaml` 도 `[3/N] passed=true` 였다.

**Fix:** 넓은 패턴으로 후보를 모두 모으고, 그 가운데 정확한 꼴이 아닌 것을 실패로 돌린다.
```dart
final candidates = RegExp(r'package:woody_lints/(\S+?)(?=[`\s)"\x27]|$)', multiLine: true)
    .allMatches(readmeLines.join('\n'))
    .map((m) => m.group(1)!)
    .toSet();
final malformed = candidates
    .where((c) => !RegExp(r'^[A-Za-z0-9_]+\.yaml$').hasMatch(c))
    .toList()..sort();
// malformed 가 있으면 addBlock(...) 으로 실패. 나머지는 지금처럼 expectedLibYamls 와 견준다.
```

### WR-02: README 검사 (f) · (g) 가 따옴표 · 줄 끝 주석 · 두 자리 버전 값을 조용히 건너뛴다 — 낡은 값으로 통과

**File:** `tool/verify.dart:1630-1635`, `tool/verify.dart:1654-1657`
**Issue:** (f) 의 `versionPattern` 은 `\^?\d+\.\d+\.\d+` 만 받는다. (g) 의 `refPattern` 은 줄 끝 주석 없이 `ref: vX.Y.Z` 인 줄만 받는다. 다음 줄은 YAML 로 올바르지만 목록에 들어가지 않는다.

- 따옴표: `version: "^3.1.3"`, `ref: 'v1.9.0'`
- 두 자리 버전: `riverpod_lint: ^3.1`
- 줄 끝 주석: `ref: v1.9.0 # 예시`. (f) 는 줄 끝 주석을 받는데 (g) 는 받지 않아, 두 검사가 비대칭이다.

README 에는 `version:` / `riverpod_lint:` 줄이 둘(198 · 234행), `ref:` 줄이 둘(18 · 333행) 있다. 하나만 맞으면 "0개" 경로를 타지 않으므로 낡은 쪽이 통과한다. `example/README.md` 의 05-06 소절은 "(e) · (f) · (g) 도 읽은 값이 0개면 … 실패한다" 를 헛통과를 막는 근거로 적는다. 그러나 이 0개 확인은 하나도 읽지 못한 경우만 막는다. 일부만 읽은 경우는 막지 못한다.

부수 문제가 하나 있다. (f) 는 어느 코드 블록이든 `version:` 줄을 plugin 버전으로 본다. 뒤에 pubspec 예시 블록(`version: ^2.0.0` 등)을 넣으면 거짓 실패한다(코드에서 읽은 것이다. 돌리지 않았다).

- **재현(전체 실행):** 다음 세 변경을 함께 넣고 돌렸다. 종료 코드 0, `[3/10] 배포 파일의 구성 ... 통과`, `점검 통과 (10개 중 10개)` 였다.
  - README 333행: `      ref: v1.9.0 # 예시`
  - README 234행: `    version: "^3.1.3"`
  - README 78행: WR-01 의 `codegen.yml`
- **재현(함수 단위):** `ref: 'v1.9.0'` 과 `riverpod_lint: ^3.1` 도 각각 `[3/N] passed=true` 였다.

**Fix:** 코드 블록 안에서 키(`ref:` · `version:` · `riverpod_lint:`)가 보이는 줄을 모두 후보로 잡는다. 따옴표와 줄 끝 주석을 벗긴 뒤 값이 기대한 꼴이 아니면 실패로 친다.
```dart
final refKey = RegExp(r'''^\s*ref:\s*(['"]?)([^'"#\s]+)\1\s*(?:#.*)?$''');
for (final line in fenced) {
  final m = refKey.firstMatch(line);
  if (m == null) continue;
  final value = m.group(2)!;
  if (value == 'main') continue;
  final v = RegExp(r'^v(\d+\.\d+\.\d+)$').firstMatch(value)?.group(1);
  if (v == null) unreadable.add(line.trim()); else refs.add(v);
}
// unreadable 이 있으면 실패. (f) 도 같은 꼴로 — 그리고 `version:` 은 `riverpod_lint:` 맵 아래의 줄만 세도록 좁힌다.
```

### WR-03: `fencedLines` 가 ``` 펜스만 안다 — `~~~` 코드 블록의 값은 (f) · (g) 가 보지 않는다

**File:** `tool/verify.dart:1274-1285`
**Issue:** 펜스는 `trimLeft().startsWith('```')` 로만 연다. CommonMark 의 `~~~` 펜스로 쓴 블록은 통째로 "산문" 으로 취급된다. 블록 안의 `ref:` · `version:` 줄은 (f) · (g) 대상에서 빠진다. 다른 블록에 맞는 값이 하나라도 있으면 통과한다.

닫는 펜스의 길이도 보지 않는다. 4개 백틱 블록 안에 ``` 줄이 있으면 열고 닫는 판단이 뒤집힌다(코드에서 읽은 것이다).

**재현(함수 단위):** README 328 · 334행의 펜스를 `~~~yaml` / `~~~` 로 바꾸고, 333행을 `ref: v1.9.0` 으로 바꿨다. 결과는 `[3/N] passed=true` 였다.

**Fix:** 여는 펜스의 문자(``` 또는 `~`)와 길이를 기억한다. 같은 문자이고 길이가 같거나 긴 줄에서만 닫는다.
```dart
final open = RegExp(r'^\s{0,3}(`{3,}|~{3,})');
String? fence;
for (final line in lines) {
  final m = open.firstMatch(line);
  if (fence == null && m != null) { fence = m.group(1); continue; }
  if (fence != null && m != null && m.group(1)![0] == fence[0] && m.group(1)!.length >= fence.length && line.trim() == m.group(1)) { fence = null; continue; }
  if (fence != null) out.add(line);
}
```

### WR-04: (b′) 가 flow 표기 `linter: {rules: [...]}` 로 다른 조각에 적은 규칙을 보지 못한다 — 사용 프로젝트는 받는데 검증은 10개 중 10개

**File:** `tool/verify.dart:1488-1502` (`declaredRuleNames` 925행)
**Issue:** `declaredRuleNames` 는 `linter:` 줄 뒤에 오는 블록 줄만 읽는다. 문서 주석(905 ~ 906행)은 flow 표기를 "규칙 0개라 `[2/N]` 이 잡는다" 고 적는다. 그러나 그 0개 확인은 `rulesFile`(`lib/base.yaml`)에만 걸린다(1115행). `lib/codegen.yaml` · `lib/riverpod.yaml` 에 flow 표기로 적은 규칙은 (b′) 에서 0개로 읽히고 그대로 통과한다. WR-11 이 블록 형식에서 닫은 빈자리가 flow 형식에서는 열려 있다.

`[2/N]` 도 막지 못한다. 조각 복사본에는 include 가 없어서 기반 세트와 겹친 규칙(`avoid_print`)도 경고가 나지 않는다. 남는 방어선은 연습용 프로젝트 정답지뿐이다. 그 규칙이 샘플 코드에 걸리지 않으면 아무 단계도 실패하지 않는다. 걸리더라도 실패 문구가 "일부러 바꾼 것이면 `--update`" 를 안내하므로, RULES.md · README 에 없는 규칙이 정답지로 굳을 수 있다.

**재현(전체 실행, 두 번):**
- `lib/codegen.yaml` 끝에 `linter: {rules: [prefer_mixin, avoid_print]}` 를 덧붙였다. 종료 코드 0, `점검 통과 (10개 중 10개)` 였다.
- 같은 자리에 `linter: {rules: [always_specify_types]}` 를 덧붙였다. 이번에는 `[3/10]` 이 통과하고, `[5/10]` · `[9/10]` · `[10/10]` 이 정답지 차이(`always_specify_types` 94줄)로 실패했다. 이것으로 flow 표기 규칙이 사용 프로젝트까지 실제로 닿는다는 것이 확인된다.

**Fix:** `linter:` 줄에 값이 같은 줄로 붙어 있으면(`^linter:\s*\S` 이면서 `#` 이 아니면) 건너뛰지 말고 `FormatException` 을 던진다. 블록 안 `rules:` 줄에 값이 붙은 경우(`rules: [..]`)는 이미 멈춘다.
```dart
if (RegExp(r'^linter:').hasMatch(line)) {
  if (!RegExp(r'^linter:\s*(?:#.*)?$').hasMatch(line)) {
    throw FormatException('$shownAs 의 ${i + 1}행: `linter:` 의 flow 표기는 읽지 않는다 — 블록 목록으로 적는다: $trimmed');
  }
  inLinter = true;
}
```

### WR-05: `readShippedPluginConstraint` 가 YAML 토큰을 그대로 돌려주고 올바른 꼴 셋을 거부한다 — 70 이나 통과할 수 없는 `[3/N]` · `[4/N]`

**File:** `tool/verify.dart:1227-1244`
**Issue:** 스칼라 정규식의 `([^\s#]+)` 는 따옴표째로 값을 잡는다. 그 밖의 올바른 꼴 둘은 아예 읽지 못한다. 세 경우의 결과는 다음과 같다.

| `lib/riverpod.yaml` 의 꼴 | 결과 |
|---|---|
| `riverpod_lint: "^3.1.9"` (따옴표) | `"^3.1.9"` 를 돌려준다. `[4/N]` 이 `fixtures/overrides` 의 `version: ^3.1.9` 와 어긋나 실패한다. `[3/N]` (f) 는 README 의 `^3.1.9` 와 어긋나 실패한다. README 쪽을 따옴표로 맞추면 (f) 가 그 줄을 읽지 않는다(WR-02). 그래서 `[3/N]` 은 어떻게 고쳐도 통과할 수 없다. |
| `riverpod_lint: ">=3.1.9 <4.0.0"` (범위 제약) | 공백 때문에 스칼라 꼴도 맵 꼴도 맞지 않는다. `FormatException` 으로 종료 코드 70 이다. |
| `riverpod_lint:` 아래에 `diagnostics:` 를 먼저 쓰고 `version:` 을 뒤에 둔 맵 형식 | 첫 비주석 줄이 `version:` 이 아니라 `break` 하고, 끝내 `FormatException` 으로 70 이다. 맵 키의 순서는 YAML 에서 뜻이 없다. |

셋 다 analyzer 에게는 같은 선언이다. 03-REVIEW WR-02 와 같은 "거짓 실패" 모양이다.

**재현(함수 단위):** 세 꼴 모두 하네스로 돌렸다.
- 따옴표 꼴: `[3/N] passed=false`(선언 `"^3.1.9"`), `[4/N] passed=false`
- 범위 · 순서 꼴: `[3/N]` · `[4/N]` 모두 `FormatException: lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다`

**Fix:**
- 값을 읽은 뒤 바깥 따옴표를 벗긴다(`^(['"])(.*)\1$` → 그룹 2).
- 맵 형식은 `riverpod_lint:` 의 들여쓰기보다 깊은 줄 가운데 `version:` 을 찾는다. 첫 줄만 보지 않는다.
- 범위 제약을 받지 않을 것이라면, 문구를 "`^X.Y.Z` 꼴만 받는다" 로 바꿔 원인을 알린다.

```dart
String unquote(String v) => RegExp(r'''^(['"])(.*)\1$''').firstMatch(v)?.group(2) ?? v;
```

### WR-06: `.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다

**File:** `.claude/CLAUDE.md:69-73`, `.claude/CLAUDE.md:173`, `.claude/CLAUDE.md:182-183`, `.claude/CLAUDE.md:313`
**Issue:** Phase 5 는 71행과 181행만 지금 구조에 맞게 고쳤다. 같은 목록과 같은 절의 이웃 줄은 1.3.0 의 한 파일 구조를 그대로 지시한다.

| 줄 | 남아 있는 지시 | 지금 저장소 |
|---|---|---|
| 69 | `riverpod_lint: ^3.1.3` | `lib/riverpod.yaml` 은 `^3.1.9` |
| 70 | 루트 `analyzer.exclude` 에 `lib/analysis_options.yaml` 을 넣는다 | 루트 `analysis_options.yaml` 은 `example/**` · `fixtures/**` 만 뺀다. CHANGELOG 99행은 그 제외를 "걷어냄" 이라고 적는다 |
| 73 | 버전 `1.3.0` | `pubspec.yaml` 은 `2.0.0-dev` |
| 173 · 313 | 루트 exclude 가 "반드시 유지되어야 한다" | 위와 같다 |
| 182 · 183 | 예시로 `lib/analysis_options.yaml` 49-56행 · 55-56행을 든다 | 그 파일은 지금 4줄이다. 181행을 고친 바로 다음 줄이다 |

이 파일은 에이전트 지시문이다. 다음 작업이 70 · 173행을 따르면, 이미 걷어낸 루트 exclude 를 되살리거나 "고칠 것" 으로 잘못 보고하게 된다.

**재현:** 해당 없음(읽어서 대조한 것). 루트 `analysis_options.yaml`, `lib/riverpod.yaml`, `pubspec.yaml` 과 견줬다.

**Fix:** 69 · 70 · 73 · 173 · 182 · 183 · 313행을 지금 구조로 고친다(`lib/riverpod.yaml` `^3.1.9`, 루트는 `example/**` · `fixtures/**` 제외, `2.0.0-dev`, 예시 줄 번호는 `lib/riverpod.yaml` 2행 등). 범위가 Phase 5 밖이면, 적어도 70 · 173 · 313행의 "유지해야 한다" 지시는 지운다. 그리고 이 문서가 1.3.0 시점의 코드베이스 지도라는 한 줄을 머리에 둔다.

## Info

### IN-01: `pubspecReleaseVersion` 이 따옴표로 감싼 `version:` 에서 종료 코드 70

**File:** `tool/verify.dart:1293-1296`
**Issue:** `^version:\s*(\d+\.\d+\.\d+)` 는 `version: "2.0.0-dev"` / `'2.0.0'` 에 맞지 않는다. 그래서 `FormatException` 이 나고 검증 전체가 70 으로 끝난다. 큰 소리로 실패하므로 헛통과는 아니다.
**재현(함수 단위):** pubspec 의 version 을 `"2.0.0-dev"` 로 바꾸자 `[3/N] FormatException(exit 70): pubspec.yaml 에서 version: 을 읽지 못했다` 가 났다.
**Fix:** `^version:\s*['"]?(\d+\.\d+\.\d+)` 로 따옴표를 받는다.

### IN-02: CHANGELOG 2.0.0 의 "내용은 1.3.0 과 같다" 가 같은 절의 다른 항목과 어긋난다

**File:** `CHANGELOG.md:92`
**Issue:** 92행은 "규칙 · 주석 · 설정은 옮기기만 했고 내용은 1.3.0 과 같다" 라고 적는다. 그런데 같은 2.0.0 절의 다른 항목은 그와 다른 변경을 기록한다.

- 95행: 겹친 선언 6개와 주석 처리된 설정 3개를 지웠다.
- 97행: 사유 주석 셋을 고쳤다.
- 98행: 머리 주석을 다시 썼다.
- 12 ~ 88행: 규칙 75개를 추가했다.

릴리스 노트는 1.3.0 대비 순변경으로 읽힌다. 그렇게 읽으면 92행은 틀린 문장이다.
**Fix:** "나누는 변경 자체는 옮기기만 했다 — 같은 2.0.0 의 다른 변경은 아래 항목" 처럼, 범위를 나누는 변경 하나로 한정한다.

### IN-03: README 「프리셋 고르기」 의 "그 연습용 프로젝트의 정답지로 확인" 이 묶음에는 맞지 않는다

**File:** `README.md:45`, `README.md:53`
**Issue:** `fixtures/recommended/` 에는 `expected_diagnostics.txt` 가 없다. 묶음은 같은 실행의 `example` 결과와 견준다(`tool/verify.dart` 의 `recommended` 행, `expectedPath` 없음). 따라서 53행의 "받는 것" 을 뒷받침하는 것은 `example/expected_diagnostics.txt` 다.
**Fix:** 45행에 "묶음은 자기 정답지 없이 `example/` 의 정답지와 같은 결과인지로 확인한다" 를 덧붙인다.

### IN-04: plugin 하한을 올릴 때 함께 고칠 자리가 두 문서에 반씩 적혀 있다

**File:** `lib/riverpod.yaml:5`, `README.md:382`
**Issue:** 함께 고칠 자리 안내가 두 곳에 나뉘어 있고, 어느 쪽도 전부를 적지 않는다.

| 자리 | 적힌 것 | 빠진 것 |
|---|---|---|
| `lib/riverpod.yaml` 5행의 줄 끝 주석 | `fixtures/overrides/analysis_options.yaml` 만 (`[4/N]`) | README 의 버전 예시 — `[3/N]` (f) 도 이 값을 견준다 |
| README 382행 | README 의 예시만 | `fixtures/overrides` |

둘 다 검증이 잡으므로 결과가 틀어지지는 않는다. 다만 한쪽만 읽은 사람은 한 번 실패를 보고서야 나머지를 알게 된다.
**Fix:** 두 자리 모두 "README 의 버전 예시 · `fixtures/overrides/analysis_options.yaml` 의 `version:`" 둘을 함께 적는다.

### IN-05: `tool/verify.dart` 문서 주석의 단계 번호가 `[2/4]` · `[1/4]` 로 남아 있다

**File:** `tool/verify.dart:171`, `tool/verify.dart:174`, `tool/verify.dart:762`, `tool/verify.dart:839`, `tool/verify.dart:1001`
**Issue:** 단계는 지금 10개(`[N/10]`)이고 파일의 다른 곳은 `[2/N]` 꼴을 쓴다. Phase 5 는 174 ~ 177행의 `fragmentLineHint` 를 고쳤지만, 바로 위의 `[2/4]` 는 그대로 두었다.
**Fix:** 다섯 자리를 `[1/N]` · `[2/N]` 으로 바꾼다.

### IN-06: `readBulletBlock` 이 `readRulesMdBlock` 의 마커 처리를 복제하고, 결과 타입 이름이 README 에 맞지 않는다

**File:** `tool/verify.dart:1412-1436`
**Issue:** 마커를 찾는 4줄, `names` / `malformed` 를 모으는 구조, 이름 정규식이 1378 ~ 1403행과 같다. 다른 것은 줄을 고르는 조건(`|` 표 행이냐 `- ` 불릿이냐)과 이름을 찾는 범위(첫 칸이냐 줄 전체냐)뿐이다. 결과 타입은 README 에도 `RulesMdBlock` 이다. 마커 규칙을 바꿀 때(앞뒤 공백 허용 등) 두 곳을 함께 고쳐야 한다.
**Fix:** `readMarkerBlock(File, String name, Iterable<String> Function(String line) namesOf)` 하나로 합치고, 타입 이름을 `MarkerBlock` 으로 바꾼다.

### IN-07: README 「받는 규칙」 의 분류는 검사되지 않는다

**File:** `README.md:91`, `tool/verify.dart:1593-1595`
**Issue:** 91행은 "분류는 `lib/base.yaml` 의 분류 주석을 따른다" 고 적는다. 그러나 (d) 는 이름을 정렬해 집합으로만 견준다. `lib/base.yaml` 에서 규칙을 다른 분류 주석 아래로 옮겨도 README 의 소제목은 낡은 채 통과한다. 지금은 분류별 10 · 44 · 25 · 2 개로 일치한다(직접 대조했다).
**Fix:** README 의 문장을 "이름의 집합만 검증한다" 로 낮추거나, (d) 에서 소제목 → 이름 목록을 `lib/base.yaml` 의 분류 주석 → 이름 목록과 견준다.

---

_Reviewed: 2026-10-13T20:35:05Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
