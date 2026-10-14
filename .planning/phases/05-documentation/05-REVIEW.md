---
phase: 05-documentation
reviewed: 2026-10-14T03:21:07Z
depth: standard
files_reviewed: 7
files_reviewed_list:
  - CHANGELOG.md
  - README.md
  - example/README.md
  - lib/riverpod.yaml
  - tool/measure_rules.dart
  - tool/verify.dart
  - .claude/CLAUDE.md
findings:
  critical: 0
  warning: 5
  info: 1
  total: 6
status: issues_found
---

# Phase 5: Code Review Report

**Reviewed:** 2026-10-14T03:21:07Z
**Depth:** standard
**Files Reviewed:** 7
**Status:** issues_found

## Summary

gap 수정 05-07 · 05-08 · 05-09 (커밋 `5f43726`..`8789cfe`, diff base `4e33d2f`) 뒤의 재리뷰다. 범위 파일 여섯을 읽었다. `.claude/CLAUDE.md` 는 지난 WR-06 이 아직 해당하는지 보려고 해당 줄만 대조했다.

지난 리뷰의 발견 13건 가운데 12건은 고쳐졌다. 함수 단위로 다시 돌려 확인했다(아래 표). WR-06 은 소유자 결정 D-09 로 미뤄 둔 그대로 남아 있다. 고친 reader 들은 기준 실행에서 거짓 실패를 내지 않는다. 지금 README · `RULES.md` · `lib/` 로 돌린 복제본의 기준 실행은 종료 코드 0, `점검 통과 (10개 중 10개)` 였다.

그러나 "같은 결함 모양, 다른 입력" 이 다시 네 군데에서 나왔다. 넷 다 이번 gap 수정이 닫은 "꼴이 틀린 값" 의 바깥에 있다. reader 가 아예 후보로 보지 않는 줄이라서, 틀린 값이 실패 블록에 들어가지 않는다.

- **WR-07** — (e) 는 `package:` 로 정확히 시작하는 글자만 주소 후보로 본다. scheme 오타(`packages:`), `package:` 뒤의 공백은 아무 블록에도 걸리지 않는다.
- **WR-08** — (f) · (g) 는 키가 줄 머리에 오는 블록 꼴만 본다. flow 표기(`plugins: {riverpod_lint: …}`, `woody_lints: {git: {…, ref: …}}`)에 적힌 낡은 값은 건너뛴다. WR-04 · M45 · M59 · M60 이 lib 쪽에서 닫은 모양이 README 코드 블록 쪽에 남아 있다.
- **WR-09** — `fencedLines` 는 펜스 블록만 코드로 본다. CommonMark 의 들여쓴 코드 블록 · 인용 안의 펜스에 적힌 값은 건너뛴다. WR-03 (`~~~`) 과 같은 모양이다.
- **WR-10** — `[3/10]` 은 조각의 `linter:` 블록과 `lib/base.yaml` 의 `analyzer: language:` 만 읽는다. `lib/codegen.yaml` 에 적은 `language:` 옵션이나 `formatter:` 는 사용 프로젝트에 닿는데도 10개 중 10개로 통과한다. WR-04 의 모양이 규칙 밖의 키에 남아 있다.

재현은 모두 리뷰어의 저장소 복제본(`git clone --local`)에서만 했다. 작업 트리는 건드리지 않았고, 복제본은 끝에 지웠다. 재현 방법은 두 가지다.

- **전체 실행:** `fvm dart run tool/verify.dart` 를 끝까지 돌렸다. 첫 실행은 약 70초, 그 뒤는 약 23초였다.
- **함수 단위:** `tool/verify.dart` 를 import 한 작은 하네스로 `checkShippedComposition` · `checkFixtureOptions` 를 직접 불렀다.

소유자 결정은 코드와 어긋나지 않는다. 확인한 것은 다음 넷이다.

- `readRulesTable` · `readSet` 의 옛 동작(R2-Q4). `readRulesTable` 의 새 문서 주석은 지금 코드(`tool/measure_rules.dart:4782-4810`)를 그대로 말한다.
- plugin 선언은 `^X.Y.Z` · `X.Y.Z` 만 받고 범위 제약에서 70 으로 멈춘다(R2-Q1). 함수 단위로 돌려 문구까지 확인했다.
- (f) 의 `version:` 을 좁히지 않은 것은 열린 항목 그대로다.
- (e) 가 README 의 다른 패키지 주소를 실패시키는 것은 R2-Q3 그대로다.

## 지난 리뷰의 발견 13건 — 지금 상태

| ID | 제목 | 지금 상태 | 근거 |
|----|------|-----------|------|
| WR-01 | README 검사 (e) 가 모양이 틀린 프리셋 주소를 조용히 건너뛴다 — 오타 주소로 통과 | 해결됨 | `63fe3d9`, `tool/verify.dart:1796-1848`. 함수 단위로 `presets/codegen.yaml` · `package:woody_lints/codegen` (확장자 없음) 을 넣자 둘 다 `[3/N] passed=false` 였고 `` `<이름>.yaml` 꼴이 아닌 것이 있다 (1) `` 블록이 났다. `package:` 로 시작하지 않는 오타는 WR-07 (다른 입력) |
| WR-02 | README 검사 (f) · (g) 가 따옴표 · 줄 끝 주석 · 두 자리 버전 값을 조용히 건너뛴다 — 낡은 값으로 통과 | 해결됨 | `73f1c66`, `tool/verify.dart:1853-1927`. 함수 단위로 `ref: 'v1.9.0'` 은 `ref: vX.Y.Z 예시가 … 다르다` 로, `riverpod_lint: ^3.1` 은 `읽지 못하는 … 줄이 있다 (1)` 로 실패했다. flow 표기의 키는 WR-08 (다른 입력) |
| WR-03 | `fencedLines` 가 ``` 펜스만 안다 — `~~~` 코드 블록의 값은 (f) · (g) 가 보지 않는다 | 해결됨 | `63fe3d9`, `tool/verify.dart:1377-1403`. 함수 단위로 「`ref: main` 에서 tag 로 옮기기」 블록을 `~~~` 로 바꾸고 `ref: v1.9.0` 을 넣자 `[3/N] passed=false` 였다. 펜스가 아닌 코드 블록은 WR-09 (다른 입력) |
| WR-04 | (b′) 가 flow 표기 `linter: {rules: [...]}` 로 다른 조각에 적은 규칙을 보지 못한다 — 사용 프로젝트는 받는데 검증은 10개 중 10개 | 해결됨 | `057bef2`, `tool/verify.dart:926-936`. 함수 단위로 `lib/codegen.yaml` 끝에 `linter: {rules: [prefer_mixin]}` 를 덧붙이자 `FormatException(70): lib/codegen.yaml 의 10행: …` 이 났다. `linter:` 밖의 키는 WR-10 (다른 입력) |
| WR-05 | `readShippedPluginConstraint` 가 YAML 토큰을 그대로 돌려주고 올바른 꼴 셋을 거부한다 — 70 이나 통과할 수 없는 `[3/N]` · `[4/N]` | 해결됨 | `644897f`, `tool/verify.dart:1289-1341`. 함수 단위로 `"^3.1.9"` 는 `[3/N]` · `[4/N]` 모두 `passed=true` 였다. `">=3.1.9 <4.0.0"` 은 둘 다 `` … `^X.Y.Z` 나 `X.Y.Z` 꼴만 받는다 (범위 제약은 받지 않는다, …) `` 로 70 이었다 (소유자 결정 R2-Q1 그대로) |
| WR-06 | `.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다 | 아직 해당 | 처리 기록에 deferred (D-09) 로 남아 있다. `.claude/CLAUDE.md` 를 마지막으로 바꾼 커밋은 `403c584` 이고 71 · 181행만 고쳤다. 69 · 70 · 73 · 173 · 182 · 183 · 313행은 지난 리뷰 때 글자 그대로다. 대조한 저장소는 다음과 같다: 루트 `analysis_options.yaml` 은 `example/**` · `fixtures/**` 만 뺀다, `pubspec.yaml` 은 `2.0.0-dev`, `lib/analysis_options.yaml` 은 4줄 |
| IN-01 | `pubspecReleaseVersion` 이 따옴표로 감싼 `version:` 에서 종료 코드 70 | 해결됨 | `644897f`, `tool/verify.dart:1424-1440`. 함수 단위로 `version: "2.0.0-dev"` 에서 `[3/N] passed=true` 였다 |
| IN-02 | CHANGELOG 2.0.0 의 "내용은 1.3.0 과 같다" 가 같은 절의 다른 항목과 어긋난다 | 해결됨 | `e46cff4`, `CHANGELOG.md:92`. 새 문장이 가리키는 「추가한 규칙」 의 불릿을 세니 75개였다. 겹친 선언 삭제 · 사유 주석 · 머리 주석은 95 · 97 · 98행에 있다 |
| IN-03 | README 「프리셋 고르기」 의 "그 연습용 프로젝트의 정답지로 확인" 이 묶음에는 맞지 않는다 | 해결됨 | `e46cff4`, `README.md:45`. `tool/verify.dart` 의 `fixtures` 표에서 `recommended` 행(50 ~ 53행)에 `expectedPath` 가 없는 것을 대조했다 |
| IN-04 | plugin 하한을 올릴 때 함께 고칠 자리가 두 문서에 반씩 적혀 있다 | 해결됨 | `e46cff4`, `README.md:382` · `lib/riverpod.yaml:5`. 두 자리 모두 `fixtures/overrides` 의 `version:` 과 README 예시 둘(198 · 234행)을 함께 적는다 |
| IN-05 | `tool/verify.dart` 문서 주석의 단계 번호가 `[2/4]` · `[1/4]` 로 남아 있다 | 해결됨 | `644897f`. `tool/verify.dart` 에서 `[2/4]` · `[1/4]` 를 grep 하니 0줄이었다 |
| IN-06 | `readBulletBlock` 이 `readRulesMdBlock` 의 마커 처리를 복제하고, 결과 타입 이름이 README 에 맞지 않는다 | 해결됨 | `5f43726`, `tool/verify.dart:1500-1524`. `MarkerBlock` · `readMarkerBlock` 하나로 합쳐졌다 |
| IN-07 | README 「받는 규칙」 의 분류는 검사되지 않는다 | 해결됨 | `e46cff4`, `README.md:91`. "검증 명령은 이름만 견주고 분류는 보지 않는다" 로 낮췄다 |

## Narrative Findings (AI reviewer)

## Warnings

### WR-06: `.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다

**File:** `.claude/CLAUDE.md:69-73`, `.claude/CLAUDE.md:173`, `.claude/CLAUDE.md:182-183`, `.claude/CLAUDE.md:313`
**Issue:** 지난 리뷰와 같다. Phase 5 는 71행과 181행만 고쳤다. 이웃 줄은 여전히 1.3.0 의 한 파일 구조를 지시한다.

| 줄 | 남아 있는 지시 | 지금 저장소 |
|---|---|---|
| 69 | `riverpod_lint: ^3.1.3` | `lib/riverpod.yaml` 은 `^3.1.9` |
| 70 | 루트 `analyzer.exclude` 에 `lib/analysis_options.yaml` 을 넣는다 | 루트 `analysis_options.yaml` 은 `example/**` · `fixtures/**` 만 뺀다 |
| 73 | 버전 `1.3.0` | `pubspec.yaml` 은 `2.0.0-dev` |
| 173 · 313 | 루트 exclude 가 "반드시 유지되어야 한다" | 위와 같다 |
| 182 · 183 | 예시로 `lib/analysis_options.yaml` 49-56행 · 55-56행을 든다 | 그 파일은 지금 4줄이다 |

이 파일은 에이전트 지시문이다. 이번 재리뷰도 그 지시를 컨텍스트로 받았다. 다음 작업이 70 · 173 · 313행을 따르면, 이미 걷어낸 루트 exclude 를 되살리거나 "고칠 것" 으로 잘못 보고한다. 소유자 결정 D-09 로 마일스톤 끝 `/gsd-map-codebase` 에서 고치기로 미뤄 둔 항목이다. 미룬 그대로이므로 남긴다.

**재현:** 해당 없음(읽어서 대조한 것). `git log -- .claude/CLAUDE.md` 의 마지막 커밋 `403c584` 뒤로 바뀐 줄이 없다.

**Fix:** D-09 대로 마일스톤 끝에 69 · 70 · 73 · 173 · 182 · 183 · 313행을 지금 구조로 고친다. 그 전에 이 문서를 지시로 읽는 작업이 있으면, 적어도 70 · 173 · 313행의 "유지해야 한다" 지시를 지운다.

### WR-07: README 검사 (e) 가 `package:` 로 정확히 시작하지 않는 include 주소를 보지 않는다 — scheme 오타로 10개 중 10개

**File:** `tool/verify.dart:1796-1848`
**Issue:** (e) 의 두 정규식은 모두 `package:` 글자로 시작하는 문자열만 후보로 모은다.

- 주소 후보: `package:woody_lints/(\S+?)…` (1797 ~ 1800행)
- 다른 패키지 주소: `package:([^/\s]+)/…` (1818 ~ 1827행)

include 줄의 값이 `package:` 로 시작하지 않으면 두 검사 어디에도 들어가지 않는다. 그 줄은 "본 적 없음" 이 된다.

- `packages:woody_lints/riverpod.yaml` (scheme 오타)
- `include: package: woody_lints/base.yaml` (콜론 뒤 공백 — YAML 로도 깨진다)

README 의 다른 주소가 맞으면 `candidates.isEmpty` 경로도 타지 않는다. 사용 프로젝트가 그 블록을 복사하면 include 가 풀리지 않는다. 05-08 이 `woody-lints` · `woody_lint` (패키지 이름 오타)를 닫은 것과 같은 모양이고, 오타의 자리만 scheme 쪽으로 옮겼다.

- **재현(함수 단위):** README 68행을 `  - packages:woody_lints/riverpod.yaml` 로 바꿨다. 결과는 `[3/N] passed=true` 였다. 58행을 `include: package: woody_lints/base.yaml` 로 바꿔도 `[3/N] passed=true` 였다.
- **재현(전체 실행):** 68행의 `packages:` 오타를 WR-08 · WR-09 의 변경과 함께 넣고 돌렸다. 종료 코드 0, `[3/10] 배포 파일의 구성 ... 통과`, `점검 통과 (10개 중 10개)` 였다.

**Fix:** 문자열에서 주소를 찾지 말고, 코드 블록의 `include:` 값을 모두 후보로 잡는다. 정확한 꼴이 아니면 실패한다. (f) · (g) 와 같은 "키 줄을 모두 후보로" 원칙이다.
```dart
// (e′) 코드 블록의 include 값(스칼라 · 목록 항목)은 모두 정확한 주소 꼴이어야 한다.
final includeKey = RegExp(r'^\s*include:[ \t]*(.*?)(?:[ \t]+#.*)?[ \t]*$');
final listItem = RegExp(r'^\s*-[ \t]+(.*?)(?:[ \t]+#.*)?[ \t]*$');
final exactAddress = RegExp(r'^package:woody_lints/[A-Za-z0-9_]+\.yaml$');
final badIncludes = <String>[];
var inIncludeList = false;
for (final line in fenced) {
  final key = includeKey.firstMatch(line);
  if (key != null) {
    final raw = key.group(1)!;
    final value = unquotedScalar(raw.startsWith('#') ? '' : raw);
    inIncludeList = value.isEmpty;
    if (value.isNotEmpty && !exactAddress.hasMatch(value)) badIncludes.add(line.trim());
    continue;
  }
  final item = inIncludeList ? listItem.firstMatch(line) : null;
  if (item != null) {
    if (!exactAddress.hasMatch(unquotedScalar(item.group(1)!))) badIncludes.add(line.trim());
    continue;
  }
  if (line.trim().isNotEmpty) inIncludeList = false;
}
// badIncludes 가 있으면 addBlock(...) 으로 실패.
```

### WR-08: README 검사 (f) · (g) 가 flow 표기에 적힌 plugin 버전 · `ref:` 를 보지 않는다 — 낡은 값으로 10개 중 10개

**File:** `tool/verify.dart:1859-1861`, `tool/verify.dart:1904`
**Issue:** `versionKeyPattern` (`^\s*(?:version|riverpod_lint):…`) 과 `refKeyPattern` (`^\s*ref:…`) 은 키가 줄 머리에 오는 블록 꼴만 잡는다. 키가 flow 매핑 안에 있으면 그 줄은 후보가 아니어서 조용히 건너뛴다.

- `plugins: {riverpod_lint: ^3.1.3}`
- `woody_lints: {git: {url: …, ref: v1.9.0}}`

둘 다 YAML 로 올바르고, 사용 프로젝트가 복사하면 그 값이 그대로 들어간다. 다른 블록에 맞는 값이 하나라도 있으면 "0개" 경로도 타지 않는다. lib 쪽에서는 같은 꼴을 세 번 닫았다.

- `linter:` 줄의 flow — WR-04 · M45
- `analyzer:` 줄의 flow — M60
- `language:` 줄의 flow — M59

README 코드 블록의 reader 는 그 원칙 밖에 있다.

- **재현(함수 단위):** 두 변형을 따로 돌렸다.
  - README 196 ~ 199행 블록을 `plugins: {riverpod_lint: ^3.1.3}` 한 줄로 바꿨다(234행은 `^3.1.9` 그대로). 결과는 `[3/N] passed=true` 였다.
  - 「설치」 블록을 `dev_dependencies:` / `  woody_lints: {git: {url: https://github.com/woodkill/woody_lints.git, ref: v1.9.0}}` 로 바꿨다(333행은 `v2.0.0` 그대로). 결과는 `[3/N] passed=true` 였다.
- **재현(전체 실행):** `plugins:` flow 변형을 WR-07 · WR-09 의 변경과 함께 넣고 돌렸다. 종료 코드 0, `점검 통과 (10개 중 10개)` 였다.
- 참고로 README 의 `ref:` 줄을 모두 숨긴 실행(「설치」 를 flow 로, 「tag 로 옮기기」 를 들여쓴 블록으로)은 `` 코드 블록에 `ref: vX.Y.Z` 줄이 하나도 없다 `` 로 실패했다. "0개" 확인은 모두 숨길 때만 막는다.

**Fix:** 코드 블록 줄 가운데 키 글자가 줄 어디에든 키로 나오는데(`{` · `,` · 공백 뒤의 `ref:` 등) 블록 꼴 정규식에 맞지 않는 줄은 읽지 못하는 줄로 친다.
```dart
final anyRefKey = RegExp(r'(?:^|[\s{,])ref\s*:');
final anyVersionKey = RegExp(r'(?:^|[\s{,])(?:version|riverpod_lint)\s*:');
for (final line in fenced) {
  if (refKeyPattern.firstMatch(line) == null && anyRefKey.hasMatch(line)) {
    unreadableRefs.add(line.trim()); // "flow 표기는 읽지 않는다 — 블록 꼴로 적는다"
  }
  if (versionKeyPattern.firstMatch(line) == null && anyVersionKey.hasMatch(line)) {
    unreadableVersions.add(line.trim());
  }
}
```

### WR-09: `fencedLines` 가 펜스가 아닌 코드 블록을 보지 않는다 — 들여쓴 코드 블록의 낡은 `ref:` 로 10개 중 10개

**File:** `tool/verify.dart:1377-1403`
**Issue:** `fencedLines` 는 `trimLeft()` 한 줄이 백틱 · `~` 셋 이상으로 시작할 때만 블록을 연다. 다음 두 경우는 "산문" 이 되어 (f) · (g) 대상에서 빠진다.

- CommonMark 의 들여쓴 코드 블록(빈 줄 뒤의 네 칸 이상 들여쓴 줄). GitHub 도 코드로 그린다.
- 인용 안의 펜스(`> ```yaml`). `trimLeft()` 한 줄이 `>` 로 시작한다.

두 경우 모두 독자가 복사하는 코드 블록이다. WR-03 (`~~~`) 이 닫은 것과 같은 모양이고, 다른 종류의 코드 블록이 남아 있다.

- **재현(함수 단위):** 「`ref: main` 에서 tag 로 옮기기」 블록(328 ~ 334행)의 펜스를 빼고 네 칸 들여쓴 블록으로 바꿨다. 그 안의 값은 `ref: v1.9.0` 으로 바꿨다. 결과는 `[3/N] passed=true` 였다(18행의 `v2.0.0` 만 읽었다).
- **재현(전체 실행):** 이 변형을 WR-07 · WR-08 의 변경과 함께 넣고 돌렸다. 종료 코드 0, `점검 통과 (10개 중 10개)` 였다.
- 인용 안의 펜스는 코드에서 읽은 것이다. 돌리지 않았다.

**Fix:** 들여쓴 코드 블록을 정확히 가르는 것은 목록 문맥 때문에 복잡하다. 그러니 펜스 밖에서 값을 담을 수 있는 꼴을 실패로 돌린다. 산문의 인라인 코드(README 7행의 `` `ref: v1.3.0` ``)는 줄 머리에 키가 오지 않으므로 걸리지 않는다.
```dart
final fencedSet = fencedLines(readmeLines).toSet(); // 또는 fencedLines 가 줄 번호를 돌려주게
final outsideKey = RegExp(r'^(?:\s{4,}|\s*>\s*)(?:ref|version|riverpod_lint)\s*:|^\s*>\s*(`{3,}|~{3,})');
final unfenced = [
  for (final line in readmeLines)
    if (!fencedSet.contains(line) && outsideKey.hasMatch(line)) line.trim(),
];
// unfenced 가 있으면 "코드 블록은 펜스(``` 또는 ~~~)로 적는다" 로 실패.
```

### WR-10: `[3/10]` 이 조각의 `linter:` 밖 키를 보지 않는다 — `lib/codegen.yaml` 의 `language:` 옵션 · `formatter:` 가 사용 프로젝트에 닿는데 10개 중 10개

**File:** `tool/verify.dart:1671-1688`, `tool/verify.dart:1746`, `RULES.md:97`, `README.md:214`
**Issue:** (b′) 는 `lib/base.yaml` 밖 조각의 `linter:` 블록만 읽는다(`declaredRuleNames`). (c) 의 켠 옵션 비교는 `enabledLanguageOptions(baseText, …)` 로 `lib/base.yaml` 만 읽는다(1746행). 다른 조각의 `analyzer: language:` 와 최상위 `formatter:` 는 어느 검사도 읽지 않는다. 그러나 둘 다 include 로 사용 프로젝트에 닿고, 문서는 둘 다 없다고 적는다.

- `RULES.md` 켠 옵션 표: `없음 — analyzer 옵션을 켜지 않았다.`
- README 214행: "`formatter:` 설정은 어느 프리셋에도 넣지 않는다"

WR-04 와 같은 모양이다. 지난 리뷰가 규칙(`linter:`)에서 짚은 "사용 프로젝트는 받는데 검증은 10개 중 10개" 가 규칙 밖의 키에 남아 있다. 남는 방어선은 정답지뿐이다. 그 옵션이 샘플 코드에 걸리지 않으면 아무 단계도 실패하지 않는다.

- **재현(전체 실행, 세 번):**
  - `lib/codegen.yaml` 의 `analyzer:` 아래에 `  language:` / `    strict-inference: true` 를 넣었다. 종료 코드 0, `점검 통과 (10개 중 10개)` 였다.
  - 같은 자리에 `strict-casts: true` 를 넣었다(대조 실험). `[3/10]` 은 통과하고 `[5/10]` · `[9/10]` · `[10/10]` 이 정답지에 없는 `lib/strict_rules.dart:6  error  invalid_assignment` 로 실패했다(`점검 실패 (10개 중 3개)`). 이것으로 다른 조각의 `language:` 옵션이 사용 프로젝트까지 실제로 닿는 것이 확인된다. 실패 문구는 정답지 차이뿐이고 `RULES.md` 와의 불일치는 말하지 않는다.
  - `lib/codegen.yaml` 끝에 `formatter:` / `  trailing_commas: preserve` 를 덧붙였다. 종료 코드 0, `점검 통과 (10개 중 10개)` 였다. README 214행이 경고하는 "버전을 올릴 때 포맷 변경이 대량으로" 가 검증 없이 배포된다.

**Fix:** 조각마다 받는 최상위 키(와 `analyzer:` 아래 키)를 닫힌 목록으로 두고, 그 밖의 키는 `[3/10]` 실패로 알린다. `language:` 를 켜는 날에는 `lib/base.yaml` 의 목록에만 `analyzer` 를 더한다. 그러면 (c) 가 읽는 파일과 옵션이 놓일 수 있는 파일이 같아진다.
```dart
/// 조각마다 허용하는 최상위 키 — 그 밖의 키는 (c) 가 보지 않으므로 실패로 알린다.
const allowedTopLevelKeys = {
  'lib/base.yaml': {'linter'},          // analyzer: language: 를 켜면 'analyzer' 를 더한다 — (c) 가 읽는 파일
  'lib/codegen.yaml': {'analyzer'},     // analyzer: 아래는 errors · exclude 만
  'lib/riverpod.yaml': {'plugins'},
};
const allowedCodegenAnalyzerKeys = {'errors', 'exclude'};
// 열 0 의 `^([A-Za-z_][\w-]*):` 키를 모아 allowedTopLevelKeys[target] 밖이면 addBlock(...),
// lib/codegen.yaml 의 analyzer: 바로 아래 키가 allowedCodegenAnalyzerKeys 밖이면 addBlock(...).
```

## Info

### IN-08: (e) 의 주소 끝 판정이 문장 부호를 모른다 — 맞는 주소의 거짓 실패와 다른 패키지 주소의 누락이 한 줄에서 함께 난다

**File:** `tool/verify.dart:1797-1800`, `tool/verify.dart:1819-1822`, `example/README.md:116`, `example/README.md:436`
**Issue:** 두 정규식의 끝 lookahead 는 `` [`\s)"'] `` 와 줄 끝뿐이다. 산문에서 주소 뒤에 `,` · `.` · `;` · `>` · `]` 가 바로 붙으면 두 검사가 서로 반대로 틀린다.

- woody_lints 쪽은 `recommended.yaml,` 를 후보로 잡는다. 그래서 맞는 주소가 "`<이름>.yaml` 꼴이 아닌 것" 으로 거짓 실패한다(큰 소리라 헛통과는 아니다).
- 다른 패키지 쪽은 `\S+?\.ya?ml` 뒤에 허용 문자가 오지 않아 일치 자체가 실패한다. 그래서 `package:woody-lints/base.yaml.` 같은 오타를 조용히 놓친다.

`example/README.md` 116 · 436행은 "README 의 `package:` 주소가 … 꼴이 아니면 실패" 라고 넓게 적는다. 실제 범위는 이 lookahead 와 `package:` 로 시작하는 글자(WR-07)로 좁다.

지금 README 의 주소 여덟은 모두 backtick · 공백 앞에서 끝나므로 기준 실행에는 영향이 없다.

**재현(함수 단위):** README 85행 끝에 `예: package:woody_lints/recommended.yaml, package:woody-lints/base.yaml.` 를 덧붙였다. 결과는 `[3/N] passed=false` 였다. 블록은 `` `<이름>.yaml` 꼴이 아닌 것이 있다 (1): package:woody_lints/recommended.yaml, `` 하나뿐이었다. 다른 패키지 주소의 블록은 나지 않았다.

**Fix:** 두 검사가 같은 후보 목록을 쓰게 한다. 먼저 `package:<이름>/\S+` 를 모두 모은다. 끝의 문장 부호 `[.,;:>\]]+$` 를 뗀 뒤 패키지 이름과 꼴을 각각 본다. 그리고 `example/README.md` 116 · 436행의 범위 문장을 실제 동작에 맞춘다.

---

_Reviewed: 2026-10-14T03:21:07Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
