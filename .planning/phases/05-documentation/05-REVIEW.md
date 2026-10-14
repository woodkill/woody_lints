---
phase: 05-documentation
reviewed: 2026-10-14T07:30:00Z
depth: standard
files_reviewed: 4
files_reviewed_list:
  - README.md
  - example/README.md
  - tool/verify.dart
  - .claude/CLAUDE.md
findings:
  critical: 0
  warning: 8
  info: 2
  total: 10
status: issues_found
---

# Phase 5: Code Review Report

**Reviewed:** 2026-10-14T07:30:00Z
**Depth:** standard
**Files Reviewed:** 4
**Status:** issues_found

## Summary

2회차 gap 수정 05-10 (커밋 `02966c4` · `204e401` · `d2d74c4`, diff base `ddfb852`) 뒤의 재리뷰다. 범위 파일 셋(`README.md` · `example/README.md` · `tool/verify.dart`)을 읽었다. `.claude/CLAUDE.md` 는 지난 WR-06 이 아직 해당하는지 보려고 해당 줄만 대조했다.

새 코드 둘을 봤다.

- **(a′)** `allowedTopLevelKeys` · `allowedChildKeys` · `findUnexpectedKeys` — 지난 WR-10 의 입력(M71 · M72)과 gap 입력(M68 ~ M70 · M78)을 막는다. 앞 기록의 회귀 입력(M45 · M36 · M60 · M66 의 종료 코드 70, M35 · M46 의 `[3/10]` 실패)도 그대로다. 함수 단위로 다시 돌려 확인했다.
- **(d′)** `findMarkerRange` · `markFencedLines` · `findListLinesOutsideMarkers` — M74 꼴(end 마커 바로 뒤 불릿)을 막는다. 함수 단위로 확인했다.

지금 파일로 돌린 기준 실행은 종료 코드 0, `점검 통과 (10개 중 10개)` 였다. 새 검사 둘은 지금 파일에서 거짓 실패를 내지 않는다. `fvm dart analyze tool` 은 `No issues found!`, `fvm dart format --output=none --set-exit-if-changed tool` 은 종료 코드 0 이었다.

그러나 "같은 모양, 다른 입력" 이 다시 네 군데에서 나왔다. 넷 다 reader 가 보는 줄 · 키 · 제목이 YAML 이나 CommonMark 가 보는 것과 다르다.

- **WR-11** — (a′) 와 `declaredRuleNames` 는 `\n` 으로만 줄을 나눈다. YAML 은 CR 하나(`\r`)도 줄바꿈으로 읽는다. 주석 줄 끝에 `\r` 을 넣고 키를 붙이면, reader 에게는 주석 줄이고 analyzer 에게는 새 키 줄이다. `lib/codegen.yaml` 의 `formatter:` · `language:`, `lib/base.yaml` 의 숨은 규칙이 10개 중 10개로 통과한다.
- **WR-12** — (d′) 의 절 경계는 HTML 주석 안의 `#` 줄을 제목으로 본다. 4칸 들여 쓴 ```` ``` ```` 는 펜스로 본다. 둘 다 GitHub 는 그렇게 그리지 않는다. 그 뒤의 불릿은 「받는 규칙」 목록 바로 아래에 보이는데 검사는 통과한다.
- **WR-13** — (f) · (g) 는 따옴표로 감싼 키(`"ref":`, `'riverpod_lint':`)와 콜론 앞 공백(`ref :`)을 후보로 보지 않는다. pub 은 둘 다 `ref` 로 읽는다. 05-10 이 (a′) 에서 닫은 "철자가 다른 키" 의 모양이 README 쪽에 남아 있다. 좁힌 문장("키가 줄 머리에 오는 줄을 모두 후보로")도 이 꼴을 빼지 않는다.
- **WR-14** — (e) 의 다른 패키지 주소 검사는 `.yaml` · `.yml` 로 끝나는 주소만 본다. 그런데 좁힌 문장(`example/README.md:116`)과 문서 주석(`tool/verify.dart:1857-1858`)은 "`package:` 로 정확히 시작하는 주소가 꼴이 아니면 실패" 라고 넓게 적는다.

지난 리뷰의 발견 18건 가운데 남은 것은 다섯 건이다.

- WR-07 · WR-08 · WR-09 · IN-08 — 소유자 결정 G2-Q2 로 `skipped` 이고 코드는 그대로다. 같은 입력이 지금도 통과한다. 좁힌 문장은 그 입력을 맞게 적는다. 예외는 IN-08 의 `tool/verify.dart:1864` 주석 하나다(IN-08 본문).
- WR-06 — `deferred` (D-09) 그대로다.

이 다섯은 원래 ID 와 제목으로 남겼다. 나머지 13건은 지금 해당하지 않는다(아래 표). 그 밖에 05-10 이 만든 기록의 낡은 행 하나를 IN-09 로 적었다.

재현은 모두 리뷰어의 사본에서만 했다. `git archive HEAD` 를 임시 폴더에 풀고 `fvm dart pub get` 을 돌린 사본이다. 작업 트리는 건드리지 않았고(끝의 `git status --short` 가 시작과 같다), 사본은 끝에 지웠다. 재현 방법은 두 가지다.

- **전체 실행:** `fvm dart run tool/verify.dart` 를 끝까지 돌렸다. 첫 실행은 68초, 그 뒤는 약 25초였다.
- **함수 단위:** `tool/verify.dart` 를 import 한 작은 하네스로 `checkShippedComposition` 을 직접 불러 `passed` 와 블록을 봤다.

Markdown 렌더링은 GitHub 의 Markdown API(`gh api -X POST /markdown`, `mode=gfm`)로 합성한 짧은 조각만 그려 확인했다. README 본문은 보내지 않았다.

## 지난 리뷰의 발견 18건 — 지금 상태

| ID | 제목 | 처리 기록 | 지금 해당하는가 | 근거 |
|----|------|-----------|-----------------|------|
| WR-01 | README 검사 (e) 가 모양이 틀린 프리셋 주소를 조용히 건너뛴다 — 오타 주소로 통과 | fixed | 아니오 | 함수 단위로 README 68행을 `  - package:woody_lints/presets/riverpod.yaml` 로 → `passed=false`. (e) 의 코드 줄은 지난 리뷰 뒤 바뀌지 않았다 — `git diff ddfb852 HEAD -- tool/verify.dart` 에서 지운 코드 줄은 `readMarkerBlock` 의 `return lines.sublist(start + 1, end);` 하나뿐이다 |
| WR-02 | README 검사 (f) · (g) 가 따옴표 · 줄 끝 주석 · 두 자리 버전 값을 조용히 건너뛴다 — 낡은 값으로 통과 | fixed | 아니오 | 함수 단위로 18행을 `      ref: 'v1.9.0'` 으로 → `passed=false`. 따옴표 **키**는 WR-13 (다른 입력) |
| WR-03 | `fencedLines` 가 ``` 펜스만 안다 — `~~~` 코드 블록의 값은 (f) · (g) 가 보지 않는다 | fixed | 아니오 | 함수 단위로 「`ref: main` 에서 tag 로 옮기기」 블록(328 · 334행)을 `~~~` 로, 333행을 `v1.9.0` 으로 → `passed=false` |
| WR-04 | (b′) 가 flow 표기 `linter: {rules: [...]}` 로 다른 조각에 적은 규칙을 보지 못한다 — 사용 프로젝트는 받는데 검증은 10개 중 10개 | fixed | 아니오 | 함수 단위로 `lib/codegen.yaml` 끝에 `linter: {rules: [prefer_mixin]}` → `FormatException: lib/codegen.yaml 의 10행: `linter:` 줄에 값이 붙어 있다 …` (M45 그대로) |
| WR-05 | `readShippedPluginConstraint` 가 YAML 토큰을 그대로 돌려주고 올바른 꼴 셋을 거부한다 — 70 이나 통과할 수 없는 `[3/N]` · `[4/N]` | fixed | 아니오 | 함수 단위로 `lib/riverpod.yaml` 의 `^3.1.9` 를 `"^3.1.9"` 로 → `passed=true`. `">=3.1.9 <4.0.0"` 은 `… 꼴만 받는다 (범위 제약은 받지 않는다, …)` 의 `FormatException` (M66 그대로) |
| WR-06 | `.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다 | deferred | 예 | `.claude/CLAUDE.md` 를 마지막으로 바꾼 커밋은 여전히 `403c584` 다. 69 · 70 · 73 · 173 · 182 · 183 · 313행이 지난 리뷰 때 글자 그대로다 (아래 WR-06) |
| WR-07 | README 검사 (e) 가 `package:` 로 정확히 시작하지 않는 include 주소를 보지 않는다 — scheme 오타로 10개 중 10개 | skipped | 예 | 함수 단위로 68행을 `  - packages:woody_lints/riverpod.yaml` 로 → `passed=true`. 좁힌 문장(`example/README.md:116` · `:436`, `tool/verify.dart:1864`)은 이 입력을 범위 밖으로 맞게 적는다 |
| WR-08 | README 검사 (f) · (g) 가 flow 표기에 적힌 plugin 버전 · `ref:` 를 보지 않는다 — 낡은 값으로 10개 중 10개 | skipped | 예 | 함수 단위로 196 ~ 199행 블록을 `plugins: {riverpod_lint: ^3.1.3}` 한 줄로 → `passed=true`. 좁힌 문장(`README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:2133` · `:2178`)은 flow 표기를 범위 밖으로 맞게 적는다 |
| WR-09 | `fencedLines` 가 펜스가 아닌 코드 블록을 보지 않는다 — 들여쓴 코드 블록의 낡은 `ref:` 로 10개 중 10개 | skipped | 예 | 함수 단위로 328 ~ 334행 블록의 펜스를 빼고 네 칸 들여 쓴 블록으로, 값은 `ref: v1.9.0` → `passed=true`. 좁힌 문장(`README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:1493` · `:2126`)은 맞게 적는다 |
| WR-10 | `[3/10]` 이 조각의 `linter:` 밖 키를 보지 않는다 — `lib/codegen.yaml` 의 `language:` 옵션 · `formatter:` 가 사용 프로젝트에 닿는데 10개 중 10개 | fixed | 아니오 | 함수 단위로 M71 (`analyzer:` 바로 뒤 `  language:` / `    strict-inference: true`) → `passed=false`, `` `lib/codegen.yaml` 의 `analyzer:` 바로 아래에 받지 않는 줄이 있다 (1) `` · `5행:   language:`. M72 (끝에 `formatter:`) → `passed=false`, `10행: formatter:`. 같은 키를 CR 줄바꿈 뒤에 둔 꼴은 WR-11 (다른 입력) |
| IN-01 | `pubspecReleaseVersion` 이 따옴표로 감싼 `version:` 에서 종료 코드 70 | fixed | 아니오 | 함수 단위로 `pubspec.yaml` 을 `version: "2.0.0-dev"` 로 → `passed=true` |
| IN-02 | CHANGELOG 2.0.0 의 "내용은 1.3.0 과 같다" 가 같은 절의 다른 항목과 어긋난다 | fixed | 아니오 | `git diff --stat ddfb852 HEAD -- CHANGELOG.md` 가 빈 출력 — 지난 리뷰가 고쳐진 것으로 본 글자 그대로다 |
| IN-03 | README 「프리셋 고르기」 의 "그 연습용 프로젝트의 정답지로 확인" 이 묶음에는 맞지 않는다 | fixed | 아니오 | `README.md:45` 가 "묶음(`recommended`)에는 자기 정답지가 없다 — … 같은 실행의 `example/` …" 그대로다 |
| IN-04 | plugin 하한을 올릴 때 함께 고칠 자리가 두 문서에 반씩 적혀 있다 | fixed | 아니오 | `README.md:382` 가 여전히 네 자리(`lib/riverpod.yaml` · `fixtures/overrides` 의 `version:` · README 예시 둘)를 한 곳에 적는다. `lib/riverpod.yaml:5` 주석도 그대로다 |
| IN-05 | `tool/verify.dart` 문서 주석의 단계 번호가 `[2/4]` · `[1/4]` 로 남아 있다 | fixed | 아니오 | `grep -c '\[2/4\]\|\[1/4\]' tool/verify.dart` → 0 |
| IN-06 | `readBulletBlock` 이 `readRulesMdBlock` 의 마커 처리를 복제하고, 결과 타입 이름이 README 에 맞지 않는다 | fixed | 아니오 | `tool/verify.dart:1670` `readMarkerBlock` 이 `:1685` `findMarkerRange` 를 부른다. 마커 문자열은 그 함수 한 곳에만 있다 |
| IN-07 | README 「받는 규칙」 의 분류는 검사되지 않는다 | fixed | 아니오 | `README.md:91` 에 "검증 명령은 이름만 견주고 분류는 보지 않는다" 가 그대로다 |
| IN-08 | (e) 의 주소 끝 판정이 문장 부호를 모른다 — 맞는 주소의 거짓 실패와 다른 패키지 주소의 누락이 한 줄에서 함께 난다 | skipped | 예 | 함수 단위로 85행 끝에 ` 예: package:woody_lints/recommended.yaml, package:woody-lints/base.yaml.` → `passed=false`. 블록은 `package:woody_lints/recommended.yaml,` 하나뿐이고 다른 패키지 블록은 없다 (아래 IN-08) |

## 소유자가 이번 범위 밖으로 둔 것

ID 를 주지 않는다. 이번에 확인한 그대로 적는다(모두 함수 단위, `passed=true`).

- `lib/base.yaml` 의 `analyzer:` 아래 키 — 끝에 `analyzer:` / `  errors:` / `    unused_import: ignore` 를 덧붙여도 통과한다 (`allowedChildKeys` 에 `lib/base.yaml` 이 없다, `tool/verify.dart:192-199`).
- codegen `errors:` 의 심각도 재정의 — `    invalid_annotation_target: ignore` 뒤에 `    unused_import: ignore` 를 더해도 통과한다 (`errors:` 아래는 보지 않는다).
- `lib/base.yaml` 의 `include:` 값 — 5행을 `include:` / `  - package:flutter_lints/flutter.yaml` / `  - package:woody_lints/codegen.yaml` 로 바꿔도 통과한다.
- 「받는 규칙」 절에 표 · 산문 · HTML 로 적은 규칙 이름 — (d′) 의 `listPattern` (`tool/verify.dart:1809-1811`) 은 목록 줄만 본다 (코드에서 읽은 것, 돌리지 않았다).

## Narrative Findings (AI reviewer)

## Warnings

### WR-06: `.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다

**File:** `.claude/CLAUDE.md:69-73`, `.claude/CLAUDE.md:173`, `.claude/CLAUDE.md:182-183`, `.claude/CLAUDE.md:313`
**Issue:** 지난 리뷰와 같다. 처리 기록은 deferred (D-09) 다. `git log -- .claude/CLAUDE.md` 의 마지막 커밋은 여전히 `403c584` 다.

| 줄 | 남아 있는 지시 | 지금 저장소 |
|---|---|---|
| 69 | `riverpod_lint: ^3.1.3` | `lib/riverpod.yaml` 은 `^3.1.9` |
| 70 | 루트 `analyzer.exclude` 에 `lib/analysis_options.yaml` 을 넣는다 | 루트 `analysis_options.yaml` 은 `example/**` · `fixtures/**` 만 뺀다 |
| 73 | 버전 `1.3.0` | `pubspec.yaml` 은 `2.0.0-dev` |
| 173 · 313 | 루트 exclude 가 "반드시 유지되어야 한다" | 위와 같다 |
| 182 · 183 | 예시로 `lib/analysis_options.yaml` 49-56행 · 55-56행을 든다 | 그 파일은 지금 4줄이다 |

이 파일은 에이전트 지시문이다. 이번 재리뷰도 그 지시를 컨텍스트로 받았다. 미룬 그대로이므로 남긴다.

**재현:** 해당 없음(읽어서 대조한 것).

**Fix:** D-09 대로 마일스톤 끝 `/gsd-map-codebase` 에서 69 · 70 · 73 · 173 · 182 · 183 · 313행을 지금 구조로 고친다.

### WR-07: README 검사 (e) 가 `package:` 로 정확히 시작하지 않는 include 주소를 보지 않는다 — scheme 오타로 10개 중 10개

**File:** `tool/verify.dart:2073-2076`, `tool/verify.dart:2094-2103`
**Issue:** 지난 리뷰와 같은 입력이 지금도 통과한다. 소유자 결정 G2-Q2 로 `skipped` 이고, 코드는 일부러 그대로 뒀다(`d2d74c4` 는 주석 줄만 바꿨다).

좁힌 문장은 이 입력을 맞게 적는다.

- `example/README.md:116` — "`packages:` 같은 scheme 오타 · `package:` 뒤의 공백은 보지 않고"
- `example/README.md:436` — "`package:` 로 시작하지 않는 scheme 오타(`packages:`), `package:` 뒤의 공백 … 은 보지 않는다"
- `tool/verify.dart:1864` — "(e) 는 `package:` 로 시작하지 않는 scheme 오타 · `package:` 뒤의 공백 … 을 보지 않고"

**재현(함수 단위):** README 68행을 `  - packages:woody_lints/riverpod.yaml` 로 바꿨다. 결과는 `passed=true` 였다.

**Fix:** 소유자 결정대로 둔다. 다시 넓히려면 지난 리뷰의 Fix 그대로다 — 코드 블록의 `include:` 값을 모두 후보로 잡고, 정확한 꼴이 아니면 실패시킨다.

### WR-08: README 검사 (f) · (g) 가 flow 표기에 적힌 plugin 버전 · `ref:` 를 보지 않는다 — 낡은 값으로 10개 중 10개

**File:** `tool/verify.dart:2135-2137`, `tool/verify.dart:2180`
**Issue:** 지난 리뷰와 같은 입력이 지금도 통과한다. G2-Q2 로 `skipped` 이고 코드는 그대로다.

좁힌 문장은 flow 표기를 범위 밖으로 맞게 적는다: `README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:2133` · `:2178`. 같은 줄 머리 정규식이 따옴표 키 · 콜론 앞 공백도 놓친다. 그것은 다른 입력이라 WR-13 에 적었다.

**재현(함수 단위):** 196 ~ 199행 블록을 `plugins: {riverpod_lint: ^3.1.3}` 한 줄로 바꿨다(234행은 `^3.1.9` 그대로). 결과는 `passed=true` 였다.

**Fix:** 소유자 결정대로 둔다. 다시 넓히려면 지난 리뷰의 Fix 그대로다.

### WR-09: `fencedLines` 가 펜스가 아닌 코드 블록을 보지 않는다 — 들여쓴 코드 블록의 낡은 `ref:` 로 10개 중 10개

**File:** `tool/verify.dart:1494-1520`
**Issue:** 지난 리뷰와 같은 입력이 지금도 통과한다. G2-Q2 로 `skipped` 이고 코드는 그대로다.

좁힌 문장은 맞게 적는다: `README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:1493` · `:2126` — "네 칸 들여 쓴 코드 블록 · 인용 안의 펜스는 세지 않는다".

반대쪽은 적지 않았다. 4칸 이상 들여 쓴 ```` ``` ```` 줄은 CommonMark 에서 펜스가 아닌데, `fencedLines` 는 그 줄을 펜스로 연다. 이 꼴이 새 (d′) 에서 낳는 헛통과는 WR-12 에 적었다.

**재현(함수 단위):** 328 ~ 334행 블록의 펜스 두 줄을 빼고 나머지를 네 칸 들여 썼다. 값은 `ref: v1.9.0` 으로 바꿨다. 결과는 `passed=true` 였다.

**Fix:** 소유자 결정대로 둔다.

### WR-11: (a′) · `declaredRuleNames` 가 `\n` 으로만 줄을 나눈다 — 주석 줄 끝의 CR(`\r`) 뒤에 둔 키 · 규칙이 사용 프로젝트에 닿는데 10개 중 10개

**File:** `tool/verify.dart:1027`, `tool/verify.dart:1037`, `tool/verify.dart:951`, `tool/verify.dart:956`, `tool/verify.dart:1101`, `README.md:378`, `example/README.md:116`, `example/README.md:515`
**Issue:** 줄을 나누는 방식이 YAML 과 다르다.

- `findUnexpectedKeys` 는 `options.replaceAll('\r\n', '\n').split('\n')` 로 줄을 나눈다(1027행).
- `declaredRuleNames` (951행) · `enabledLanguageOptions` (1101행)는 `options.split('\n')` 으로 나눈다.
- YAML 1.2 는 CR 하나도 줄바꿈으로 읽고, analyzer 도 그렇게 읽는다(아래 대조 실험).

그래서 `# 주석\rformatter:` 같은 한 "줄" 이 두 쪽에서 다르게 읽힌다.

- reader 셋 — `trimmed.startsWith('#')` 인 주석 줄이라 건너뛴다(956 · 1037행).
- analyzer — 주석 줄 하나와 열 0 의 `formatter:` 키 줄 하나다.

들여 쓴 줄 끝에 붙여도 같다. `findUnexpectedKeys` 는 그 줄을 "더 깊은 줄" 로 보아 건너뛴다(1064행 `if (indent > childIndent) continue;`).

05-10 의 약속은 "명단에 없으면 모두 막는다"(G2-Q1) 다. `README.md:378` 은 "그 밖의 최상위 줄 … 과 그 바로 아래의 다른 키 … 는 `[3/10]` 단계가 실패" 라고 적는다. 그런데 이 꼴의 키는 어느 블록에도 들어가지 않는다. 지금까지 이 phase 에서 되풀이된 모양이다 — 읽지 못하는 줄을 reader 가 조용히 건너뛴다. 이번에는 그 줄이 주석으로 보인다.

같은 뿌리가 `lib/base.yaml` 의 규칙 목록에도 닿는다. 주석 줄 끝의 `\r` 뒤에 `    - 규칙` 을 두면 `declaredRuleNames` 가 그 규칙을 세지 않는다. 그러면 (b) 겹침 · (c) `RULES.md` 일치 · (d) README 목록 일치가 모두 그 규칙 없이 통과한다.

편집기나 복사 붙여넣기로 이런 줄바꿈이 들어올 가능성은 낮다. 그래도 YAML 로 올바른 입력이고, 문서가 말하는 검사 결과가 거짓이 된다.

- **재현(전체 실행, 넷):**
  - `lib/codegen.yaml` 9행 끝에 `\r  language:\r    strict-inference: true\rformatter:\r  trailing_commas: preserve` 를 붙였다. 종료 코드 0, `[3/10] 배포 파일의 구성 ... 통과`, `점검 통과 (10개 중 10개)` 였다. WR-10 의 입력 둘이 그대로 통과한 것이다.
  - 대조 실험으로 같은 자리에 `strict-casts: true` 를 넣었다. `[3/10]` 은 통과하고 `[5/10]` · `[9/10]` · `[10/10]` 이 정답지에 없는 `invalid_assignment` 로 실패했다(`점검 실패 (10개 중 3개)`). 이것으로 analyzer 가 CR 뒤의 키를 읽고, 그 옵션이 사용 프로젝트까지 닿는 것이 확인된다.
  - `lib/base.yaml` 93행(`    # strict — …` 주석) 끝에 `\r    - prefer_mixin` 을 붙였다. 종료 코드 0, `점검 통과 (10개 중 10개)` 였다. `RULES.md` · README 어디에도 없는 규칙이 배포된다.
  - 같은 자리에 `\r    - always_specify_types` 를 붙인 대조 실험도 돌렸다. `[3/10]` 은 통과했다. 정답지 단계 다섯(`[5/10]` · `[7/10]` ~ `[10/10]`)은 샘플 코드의 새 `always_specify_types` 진단으로 실패했다. `[2/10]` 은 이 규칙과 `no_dynamic_casts` 의 `incompatible_lint` 로 실패했는데, 이번 규칙이 우연히 비호환 쌍이었기 때문이다. `[3/10]` 은 규칙 표 · README 목록과 다르다는 말을 하지 않았다.
- **재현(함수 단위):**
  - `lib/codegen.yaml` 3행 주석 끝에 `\rlinter:\r  rules:\r    - prefer_mixin` → `passed=true`.
  - `lib/base.yaml` 4행 주석 끝에 `\rformatter:\r  trailing_commas: preserve\rplugins:\r  custom_lint: ^0.7.0` → `passed=true`.
  - `lib/riverpod.yaml` 의 `plugins:` 아래에 주석 줄 `  # memo\r  custom_lint: ^0.7.0` → `passed=true`.
  - 전체 실행에서 riverpod 꼴은 plugin 준비에 닿으므로 돌리지 않았다(M78 처럼 pub 서버에 따라 결과가 갈린다).
- 참고로 탭 들여쓰기(`  \tlanguage:`)도 `findUnexpectedKeys` 는 "더 깊은 줄" 로 건너뛴다. 하지만 analyzer 가 `Tab characters are not allowed as indentation. - parse_error` 로 거부해서 `[2/10]` 이 실패했다(`점검 실패 (10개 중 4개)`). 헛통과는 아니다.

**Fix:** 세 reader 가 YAML 과 같은 줄바꿈으로 나누게 한다. `dart:convert` 의 `LineSplitter` 는 `\r\n` · `\r` · `\n` 을 모두 줄바꿈으로 본다(import 는 이미 `dart:convert` · `dart:io` 둘이다).
```dart
// YAML 1.2 와 같은 줄바꿈 — CR 하나도 줄을 나눈다 (analyzer 가 그렇게 읽는다).
List<String> splitYamlLines(String text) => const LineSplitter().convert(text);

// findUnexpectedKeys (1027행), declaredRuleNames (951행), enabledLanguageOptions (1101행)
final lines = splitYamlLines(options);
```
그러면 숨었던 키는 열 0 의 줄이 되어 (a′) 블록에 들어간다. 숨었던 규칙은 `linter:` 블록의 줄이 되어 (b) · (c) · (d) 가 견준다. 줄 번호도 analyzer(`[2/10]` 의 진단)와 같아진다. 고친 뒤 위 네 입력을 지워 보기 행으로 남긴다.

### WR-12: (d′) 의 절 경계가 HTML 주석 안의 `#` 줄 · 4칸 들여 쓴 ```` ``` ```` 를 제목 · 펜스로 본다 — 렌더링된 「받는 규칙」 목록 바로 아래의 불릿으로 10개 중 10개

**File:** `tool/verify.dart:1530-1556`, `tool/verify.dart:1803-1834`, `example/README.md:116`, `example/README.md:549`
**Issue:** `findListLinesOutsideMarkers` 는 end 마커 뒤의 첫 "제목 줄" 에서 절을 끊는다. 제목 줄은 `isHeading` 이다 — `markFencedLines` 가 펜스로 표시하지 않았고 `^ {0,3}#{1,6}(?:[ \t]|$)` 에 맞는 줄이다(1812행). 이 판정은 CommonMark 와 두 군데에서 어긋난다.

- **HTML 블록을 모른다.** `<!--` 로 여는 줄부터 `-->` 가 든 줄까지는 HTML 블록(CommonMark 의 type 2)이다. GitHub 는 그 안을 그리지 않는다. 그런데 그 안의 `# 메모` 줄은 `isHeading` 이 참이다. 그래서 절이 그 줄에서 끝나고, 주석 뒤의 목록 줄은 검사 밖이 된다. start 마커 앞에서도 같다. 실제 제목과 start 마커 사이에 그런 주석이 있으면, 그 위의 목록 줄이 검사 밖이 된다.
- **펜스의 들여쓰기 한도를 모른다.** `markFencedLines` 는 `trimLeft()` 한 줄이 ```` ``` ```` 로 시작하면 펜스를 연다(1539행). CommonMark 의 펜스는 들여쓰기 3칸까지다. 4칸 들여 쓴 ```` ``` ```` 는 들여 쓴 코드 블록의 글자이거나 문단의 이어짐이다. 그런 줄 둘 사이의 목록 줄은 `fenced[i]` 가 참이라 세지 않는다. GitHub 는 그 줄을 목록 항목으로 그린다.

05-10 이 이 검사를 넣은 까닭이 M74 다 — "렌더링된 README 에서는 목록의 마지막 항목처럼 보이지만 (d) 는 보지 못했다". 같은 줄이 다른 꼴로 다시 통과한다. `example/README.md:549` 는 "펜스 안의 `# …` 줄은 제목이 아니다" 까지 적고 HTML 주석은 말하지 않는다. `example/README.md:116` 은 "구역 밖에 목록 줄 … 이 있으면 실패" 라고 넓게 적는다.

승인 밖으로 둔 "HTML 로 적은 규칙 이름"(`<li>`)과는 다르다. 여기서 숨는 것은 Markdown 목록 줄(`- `bogus``)이고, (d′) 가 맡은 꼴이다.

- **재현(전체 실행):** README 188행(end 마커) 뒤에 네 줄 `<!--` / `# 메모` / `-->` / `` - `bogus_after_comment` `` 을 끼웠다. 종료 코드 0, `[3/10] 배포 파일의 구성 ... 통과`, `점검 통과 (10개 중 10개)` 였다.
- **대조(함수 단위):** 같은 자리에 `` - `bogus_after_marker` `` 한 줄만 끼우면 `passed=false`, `189행: - `bogus_after_marker`` 였다(M74 그대로).
- **재현(함수 단위):**
  - 91행 뒤에 `` - `bogus_before` `` 와 `<!--` / `# 메모` / `-->` 를 끼웠다(start 마커 앞). 결과는 `passed=true` 였다.
  - 188행 뒤에 빈 줄, `    ```` (4칸), `` - `bogus_after_indented` ``, `    ```` 를 끼웠다. 결과는 `passed=true` 였다.
- **렌더링 확인:** 같은 꼴의 합성 조각(`## 받는 규칙` · 마커 · 불릿 하나 · 위 두 꼴)을 GitHub Markdown API(`gfm`)로 그렸다.
  - HTML 주석 꼴: `# 메모` 는 그려지지 않았다. `bogus_after_comment` 는 `<ul><li>` 로 같은 `<h2>` 아래에 나왔다.
  - 4칸 꼴: 첫 줄은 ```` ``` ```` 글자를 담은 `<pre>` 로, `bogus_after_indented` 는 `<li>` 로 나왔다.

**Fix:** 제목 · 펜스 판정이 렌더러가 숨기는 줄을 보지 않게 한다. 방향은 "모르면 절을 길게" (헛통과 쪽으로 가지 않게) 다.
```dart
// HTML 주석 블록 안의 줄 — 제목도 펜스 여는 줄도 아니다 (CommonMark HTML block type 2).
List<bool> markHtmlCommentLines(List<String> lines) {
  final marks = List<bool>.filled(lines.length, false);
  var open = false;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (!open && RegExp(r'^ {0,3}<!--').hasMatch(line)) open = true;
    if (open) {
      marks[i] = true;
      if (line.contains('-->')) open = false;
    }
  }
  return marks;
}

// markFencedLines: HTML 주석 안에서는 열지 않고, 4칸 이상 들여 쓴 줄로는 열지 않는다
// (그 줄 뒤를 산문으로 보면 절 안의 줄을 더 볼 뿐이다).
final open = hidden[i] || indentOf(line) > 3 ? null : openPattern.firstMatch(line.trimLeft());

// findListLinesOutsideMarkers:
bool isHeading(int i) => !fenced[i] && !hidden[i] && headingPattern.hasMatch(lines[i]);
```
마커 줄 둘은 한 줄짜리 주석이라 위 규칙으로도 그대로다. `markFencedLines` 를 고치면 "규칙은 [fencedLines] 와 같다"(1524 ~ 1529행)가 틀리게 된다. G2-Q2 로 `fencedLines` 는 바꾸지 않으므로, 그 주석을 "(d′) 는 HTML 주석과 4칸 들여쓰기를 더 가린다" 로 고친다. 고친 뒤 위 세 입력을 지워 보기 행으로 남긴다.

### WR-13: README 검사 (f) · (g) 가 따옴표로 감싼 키 · 콜론 앞 공백(`"ref":` · `'riverpod_lint':` · `ref :`)을 후보로 보지 않는다 — 낡은 값으로 10개 중 10개, 좁힌 문장은 "모두 후보로"

**File:** `tool/verify.dart:2135-2137`, `tool/verify.dart:2180`, `README.md:382`, `example/README.md:116`, `example/README.md:395`, `tool/verify.dart:1859-1861`
**Issue:** 두 정규식은 키를 글자 그대로만 받는다. `versionKeyPattern` 은 `^\s*(?:version|riverpod_lint):…`, `refKeyPattern` 은 `^\s*ref:…` 다. 키를 따옴표로 감싸거나 콜론 앞에 공백을 두면 그 줄은 후보가 아니다. 그래서 다른 블록에 맞는 값이 하나라도 있으면 "0개" 경로도 타지 않는다.

YAML 에서 `"ref":` · `ref :` 는 `ref` 키다. pub 도 그렇게 읽는다(아래 대조 실험). 사용 프로젝트가 그 블록을 복사하면 낡은 값이 그대로 들어간다.

05-10 은 같은 모양을 `lib/` 쪽에서 막았다.

- 05-VERIFICATION 의 `linter :` · `"linter":` (M68 · M69)
- M78 의 `"zz_quoted_plugin":` — analyzer 가 따옴표 키를 plugin 이름으로 받았다

README 코드 블록의 reader 에는 그 꼴이 남아 있다. WR-08 (flow 표기)과는 입력이 다르다. 이 줄들은 블록 꼴이고, 키도 줄 머리에 있다.

좁힌 문장이 이 꼴을 빼지 않는다. 다음 셋은 이 줄을 범위 안으로 적는다.

- `example/README.md:395` — "(f) · (g) 는 펜스 코드 블록 안에서 키가 줄 머리에 오는 줄을 모두 후보로 잡고"
- `README.md:382` — "키가 줄 머리에 오는 `ref:` · `version:` · `riverpod_lint:` 줄의 값을 견준다"
- `example/README.md:116` — 같은 말

범위 밖으로 드는 것은 flow 표기 · 들여 쓴 블록 · 인용 안 펜스뿐이다.

- **재현(전체 실행):** README 18행을 `      "ref": v1.9.0` 으로, 198행을 `  'riverpod_lint': ^3.1.3` 으로 함께 바꿨다(333행 `v2.0.0` · 234행 `^3.1.9` 는 그대로). 종료 코드 0, `[3/10] 배포 파일의 구성 ... 통과`, `점검 통과 (10개 중 10개)` 였다.
- **재현(함수 단위):** 각각 따로 돌렸고 넷 모두 `passed=true` 였다.
  - 18행 `      "ref": v1.9.0`
  - 18행 `      ref : v1.9.0`
  - 198행 `  'riverpod_lint': ^3.1.3`
  - 234행 `    "version": ^3.1.3`
- **대조(pub):** 사본 안에 로컬 git 패키지(tag `v1.0.0`)와 그것을 git 의존성으로 받는 앱을 만들었다. `"ref": v9.9.9` 와 `ref : v9.9.9` 로 각각 `fvm dart pub get --offline` 을 돌렸다. 둘 다 `Could not find git ref 'v9.9.9'` 로 실패했다. pub 이 두 꼴을 모두 `ref` 로 읽는다.

**Fix:** 둘 중 하나를 소유자가 고른다. G2-Q2 는 "(e) · (f) · (g) 의 코드 변경은 승인 밖" 이었으므로 코드 쪽은 새 승인이 필요하다.

1. 검사를 닫는다 — 펜스 안에서 키 이름이 `ref` · `version` · `riverpod_lint` 로 읽히는데 엄격한 정규식에 맞지 않는 줄은 읽지 못하는 줄로 실패시킨다.
```dart
// 따옴표 키 · 콜론 앞 공백 · `? ` 명시 키 — YAML 로는 같은 키다 (M68 · M69 · M78 과 같은 모양).
final looseRefKey = RegExp(r'''^\s*(?:\?\s+)?(['"]?)ref\1\s*:(?:\s|$)''');
final looseVersionKey =
    RegExp(r'''^\s*(?:\?\s+)?(['"]?)(?:version|riverpod_lint)\1\s*:(?:\s|$)''');
for (final line in fenced) {
  if (refKeyPattern.firstMatch(line) == null && looseRefKey.hasMatch(line)) {
    unreadableRefs.add(line.trim()); // "키는 따옴표 · 콜론 앞 공백 없이 적는다"
  }
  if (versionKeyPattern.firstMatch(line) == null && looseVersionKey.hasMatch(line)) {
    unreadableVersions.add(line.trim());
  }
}
```
2. 문장을 더 좁힌다(G2-Q2 와 같은 길) — `README.md:382` · `example/README.md:116` · `:395` 와 `tool/verify.dart:1859-1861` · `:2129` · `:2176` 에 "키는 따옴표 · 콜론 앞 공백 없이 `ref:` 글자 그대로인 줄만 후보" 를 적는다.

### WR-14: (e) 의 다른 패키지 주소 검사는 `.yaml` · `.yml` 로 끝나는 주소만 보는데, 좁힌 문장과 문서 주석은 "`package:` 로 정확히 시작하는 주소가 꼴이 아니면 실패" 라고 적는다 — `package:woody-lints/riverpod` 로 10개 중 10개

**File:** `tool/verify.dart:2094-2103`, `example/README.md:116`, `tool/verify.dart:1857-1858`
**Issue:** (e) 의 두 정규식이 함께 덮지 못하는 주소가 있다.

- `candidates` 는 `package:woody_lints/` 로 시작하는 글자만 모은다.
- `otherPackages` 는 `package:([^/\s]+)/(\S+?\.ya?ml)` 이다. 그래서 확장자가 `.yaml` · `.yml` 이 아닌 다른 패키지 주소는 어느 쪽에도 들지 않는다.

패키지 이름 오타와 확장자 누락이 함께 난 주소가 그 예다. `package:woody-lints/riverpod` 나 `package:woody_lint/riverpod.yam` 은 조용히 지나간다.

문서는 이 주소를 실패로 적는다.

- `example/README.md:116` 은 G2-Q2 로 좁힌 뒤에도 "README 에서 `package:` 로 정확히 시작하는 주소가 `woody_lints` 의 `<이름>.yaml` 꼴이 아니면 실패하고" 라고 적는다. 위 두 주소는 `package:` 로 정확히 시작하고, 문장 부호도 붙지 않았고, `woody_lints` 의 꼴도 아니다. 그런데 통과한다.
- `tool/verify.dart:1857-1858` 의 문서 주석도 "— 꼴이 아닌 주소 · `woody_lints` 가 아닌 패키지의 주소도 실패" 라고 넓게 적는다.

`example/README.md:436` 만 "`package:<이름>/` 뒤가 `.yaml` · `.yml` 로 끝나고 …" 라고 정확히 적는다. 같은 파일 안에서 두 문장이 다른 범위를 말하는 셈이다.

WR-07 (scheme 오타)과 IN-08 (뒤에 붙은 문장 부호)과는 입력이 다르다. 사용 프로젝트가 그 블록을 복사하면 include 가 풀리지 않는 것은 같다.

- **재현(전체 실행):** README 68행을 `  - package:woody-lints/riverpod` 로 바꿨다. 종료 코드 0, `[3/10] 배포 파일의 구성 ... 통과`, `점검 통과 (10개 중 10개)` 였다.
- **재현(함수 단위):** 68행 `  - package:woody_lint/riverpod.yam` → `passed=true`.
- **대조:** 68행 `  - package:woody-lints/riverpod.yaml` → `passed=false`, `` `README.md` 에 `woody_lints` 가 아닌 패키지의 `.yaml` 주소가 있다 (1) ``.

**Fix:** 둘 중 하나를 소유자가 고른다(코드 쪽은 G2-Q2 밖이라 새 승인이 필요하다).

1. 문장을 코드에 맞춘다. `example/README.md:116` 의 그 구절을 다음처럼 고친다: "`package:woody_lints/` 뒤의 주소가 `<이름>.yaml` 꼴이 아니면, `package:<이름>/` 뒤가 `.yaml` · `.yml` 로 끝나는 다른 패키지의 주소면 실패하고". `tool/verify.dart:1858` 도 "`.yaml` · `.yml` 로 끝나는 다른 패키지의 주소도 실패" 로 고친다.
2. 검사를 닫는다. 다른 패키지 쪽도 확장자를 가리지 않고 모은다. 이 README 의 `package:` 주소는 모두 `woody_lints` 이므로(`example/README.md:436`) 지금 파일에서 거짓 실패는 없다.
```dart
final otherPackages = RegExp(r'''package:([^/\s]+)/(\S+?)(?=[`\s)"']|$)''', multiLine: true)
    .allMatches(readmeText)
    .where((m) => m.group(1) != 'woody_lints')
    .map((m) => 'package:${m.group(1)}/${m.group(2)}')
    .toSet()
    .toList()
  ..sort();
```

## Info

### IN-08: (e) 의 주소 끝 판정이 문장 부호를 모른다 — 맞는 주소의 거짓 실패와 다른 패키지 주소의 누락이 한 줄에서 함께 난다

**File:** `tool/verify.dart:2073-2076`, `tool/verify.dart:2094-2097`, `tool/verify.dart:1864`
**Issue:** 지난 리뷰와 같은 입력이 지금도 같은 결과를 낸다. G2-Q2 로 `skipped` 이고 코드는 그대로다.

좁힌 문장 대부분은 결과를 맞게 적는다.

- `example/README.md:116` · `:436` — "그 문장 부호가 붙으면 `woody_lints` 주소는 꼴이 아닌 것으로 실패하고, 다른 패키지의 주소는 후보가 되지 않는다"
- `tool/verify.dart:2093` — 다른 패키지 쪽

한 곳은 맞지 않는다. `tool/verify.dart:1864` 의 문서 주석은 "(e) 는 … 주소 바로 뒤에 붙은 `,` · `.` 같은 문장 부호를 보지 않고" 라고 적는다. 하지만 `woody_lints` 쪽은 그 문장 부호를 후보에 넣어 거짓 실패한다. "보지 않는다" 는 다른 패키지 쪽에만 맞다.

**재현(함수 단위):** README 85행 끝에 ` 예: package:woody_lints/recommended.yaml, package:woody-lints/base.yaml.` 를 덧붙였다. 결과는 `passed=false` 였다. 블록은 `` `<이름>.yaml` 꼴이 아닌 것이 있다 (1): `` · `package:woody_lints/recommended.yaml,` 하나뿐이었고, 다른 패키지 블록은 나지 않았다.

**Fix:** 소유자 결정대로 코드는 둔다. `tool/verify.dart:1864` 의 그 구절만 `example/README.md:436` 과 같게 고친다: "주소 바로 뒤에 붙은 `,` · `.` 같은 문장 부호(붙으면 `woody_lints` 주소는 꼴이 아닌 것으로 실패하고, 다른 패키지의 주소는 후보가 되지 않는다)".

### IN-09: (a′) 가 들어온 뒤 M35 · M37 의 `[3/10]` 출력이 바뀌었는데, 05-10 소절은 M46 만 짚는다

**File:** `example/README.md:323`, `example/README.md:325`, `example/README.md:518`
**Issue:** 같은 입력에서 지금 `[3/10]` 이 내는 것과 기록이 다르다.

- `example/README.md:323` (M35 행)과 `:325` (M37 행)는 `[3/10]` 이 낸 줄을 `` `lib/<조각>.yaml` 에 규칙이 있다 `` 블록 하나로 적는다.
- 05-10 뒤에는 그 앞에 `` `lib/<조각>.yaml` 의 최상위에 받지 않는 줄이 있다 (1) — 받는 키: … `` 블록이 먼저 나온다. 다른 조각의 열 0 `linter:` 는 (a′) 의 목록 밖이기 때문이다.

05-10 소절 518행은 "M46 은 이제 `[3/10]` 에 블록 둘(최상위 · 규칙)을 찍는다. 05-07 소절의 M46 행은 그때의 기록이다" 라고 M46 만 짚는다. 116행은 M35 를 "`linter:` 블록에 규칙이 없는지" 의 근거 행으로 든다. 행을 다시 돌려 보는 사람은 기록과 다른 화면을 보게 된다.

M1 ~ M67 행은 고치지 않는 것이 이번 계획의 금지(P-03 · P-04)라, 행이 아니라 05-10 의 읽는 법이 짚어야 한다.

**재현(함수 단위):**
- M35 의 네 줄(`linter:` / `  rules:` / `    - avoid_print # 기반 세트와 겹침` / `    - prefer_mixin # RULES.md 에 없음`)을 `lib/codegen.yaml` 끝에 덧붙였다. 블록이 둘 나왔다: `` `lib/codegen.yaml` 의 최상위에 받지 않는 줄이 있다 (1) — 받는 키: analyzer `` 와 `` `lib/codegen.yaml` 에 규칙이 있다 (2) ``.
- M37 의 세 줄을 `lib/riverpod.yaml` 끝에 덧붙였다. 이것도 둘이었다: `… 받는 키: plugins` 와 `… 규칙이 있다 (1)`.

**Fix:** 518행을 "M35 · M37 · M46 은 이제 `[3/10]` 에 블록 둘(최상위 · 규칙)을 찍는다. 05-01 · 05-07 소절의 그 행은 그때의 기록이다" 로 넓힌다.

---

_Reviewed: 2026-10-14T07:30:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
