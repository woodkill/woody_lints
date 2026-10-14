---
phase: 05-documentation
reviewed: 2026-10-14T13:41:37Z
depth: standard
files_reviewed: 4
files_reviewed_list:
  - README.md
  - example/README.md
  - tool/verify.dart
  - .claude/CLAUDE.md
findings:
  critical: 0
  warning: 9
  info: 3
  total: 12
status: issues_found
---

# Phase 5: Code Review Report

**Reviewed:** 2026-10-14T13:41:37Z
**Depth:** standard
**Files Reviewed:** 4
**Status:** issues_found

## Summary

3회차 gap 수정 05-12 (커밋 `d771c0c` · `d8b61b0`, diff base `de2b191`) 뒤의 재리뷰다. 범위 파일 셋(`README.md` · `example/README.md` · `tool/verify.dart`)을 읽었다. `.claude/CLAUDE.md` 는 지난 WR-06 이 아직 해당하는지 보려고 해당 줄만 대조했다.

**기준 실행 (복제본):**

- `fvm dart run tool/verify.dart` — 종료 코드 0, `점검 통과 (10개 중 10개)`, 71초 (plugin 준비 포함). Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9.
- `fvm dart analyze tool` — `No issues found!`.
- `fvm dart format --output=none --set-exit-if-changed tool` — 종료 코드 0 (`Formatted 2 files (0 changed)`).

**바뀐 줄 나누기가 맞는 파일에서 거짓 실패를 내는지 — 내지 않는다.** 다음을 확인했다.

- 대상 파일: `lib/` 의 YAML 다섯 · `pubspec.yaml` · `README.md` · `RULES.md`.
- 변형: 모두 CRLF, 모두 CR 하나, 모두 마지막 줄바꿈 없음.
- 확인 방법: 함수 단위(`checkShippedComposition` · `stripPlugins`)는 셋 다 `passed=true` 였다. 전체 실행은 CR 하나 · CRLF 두 변형을 돌렸고 둘 다 종료 코드 0 · `점검 통과 (10개 중 10개)` 였다.

**WR-11 은 닫혔다.** M79 · M82 ~ M85 의 입력을 함수 단위로 다시 넣었고, 다섯 모두 `passed=false` 이며 블록 줄은 05-12 기록과 같다.

**YAML 과 다르게 읽히는 다른 입력도 찾아봤다.** 결과는 두 갈래다.

- **파일 머리의 BOM — 발견 아님.** `File.readAsStringSync()` 가 BOM 을 벗긴다(첫 글자 `0x23`). 조각 셋 머리에 BOM 을 붙여도 `passed=true` 였다.
- **줄 머리의 BOM (파일 중간) — 발견 아님.** 함수가 보는 줄과 analyzer 가 보는 줄은 다르다. 그런데 analyzer 가 `parse_error` 로 거부한다. `$T/p` 의 작은 프로젝트에서 두 꼴을 돌렸다:
  - `linter:` 블록 뒤의 `U+FEFF + analyzer:` → `Expected a key while parsing a block mapping`
  - 주석 줄 뒤의 `U+FEFF + analyzer:` → `Only expected one document`
  - 그래서 `[2/10]` 이 잡는다. 헛통과가 아니다.
- **여러 줄 스칼라 (따옴표 · 블록) — 발견.** 줄 단위 reader 는 스칼라를 모른다. 여러 줄 따옴표 스칼라나 블록 스칼라 안의 줄을 키 · 규칙 · 옵션 · `version:` 으로 읽는다. YAML · pub · analyzer 는 그 줄을 글자 값으로 읽는다. 둘 다 전체 실행에서 10개 중 10개였다.
  - `pubspecReleaseVersion` → **WR-15**
  - `declaredRuleNames` · `enabledLanguageOptions` → **WR-16**
  - 줄 나누기를 맞춘 뒤에도 "reader 가 보는 줄 ≠ YAML 이 보는 값" 이라는 같은 모양이 남아 있다.
- **(f) · (g) 의 펜스 판정 (Markdown) — 발견.** 진짜 펜스 안에 네 칸 들여 쓴 ```` ``` ```` 줄이 있으면 `fencedLines` 가 그 펜스를 닫는다. GitHub 는 그 줄을 내용으로 그린다. 그 뒤의 낡은 `ref:` 는 함수 단위에서 통과한다. 고친 문장(`README.md:382`)은 이 꼴을 적지 않는다 → **IN-10**.

**지난 발견 23건 가운데 지금도 해당하는 것은 여덟 건이다** (아래 표).

- WR-06 — `deferred` 그대로다.
- WR-07 · WR-08 · WR-09 · WR-12 · WR-13 · WR-14 · IN-08 — 같은 입력이 지금도 같은 결과를 낸다. 소유자 결정(G2-Q2 · G3-Q2 · G3-Q3)대로 코드는 그대로다. WR-12 · WR-13 · WR-14 · IN-08 의 문장 쪽 어긋남은 `d8b61b0` 으로 닫혔다. 남은 것은 동작뿐이고, 고친 문장은 그 동작을 맞게 적는다.

WR-11 · IN-09 를 포함한 나머지 15건은 지금 해당하지 않는다.

**재현 방법.** 모두 `T=$(mktemp -d)` 아래에서만 했다. 복제본은 `git clone --local --quiet . "$T/repo"` 로 만들고 `fvm dart pub get --no-example` 을 돌렸다.

- **함수 단위:** 복제본 밖 `$T/h` 의 Dart 파일 하나가 `import '../repo/tool/verify.dart' as v;` 로 함수를 불렀다.
- **YAML · pub · analyzer 대조:** `$T/p` · `$T/q` 의 작은 프로젝트에서 했다.
- **렌더링 확인:** 합성한 짧은 조각 하나만 GitHub Markdown API(`gh api -X POST /markdown`, `mode=gfm`)로 그렸다. README 본문은 보내지 않았다.
- 변형마다 `git diff --numstat` 으로 의도한 줄 수를 확인했고, 실행 뒤 `git checkout -- .` 으로 되돌렸다.
- 끝에 `$T` 를 지웠다. 작업 트리의 `git status --porcelain` 은 시작과 같다 (GSD 도구 상태 넷).

## 지난 리뷰의 발견 23건 — 지금 상태

| ID | 제목 | 처리 기록 | 지금 해당하는가 | 근거 |
|----|------|-----------|-----------------|------|
| WR-01 | README 검사 (e) 가 모양이 틀린 프리셋 주소를 조용히 건너뛴다 — 오타 주소로 통과 | fixed | 아니오 | 함수 단위로 README 68행을 `  - package:woody_lints/presets/riverpod.yaml` 로 → `passed=false`, `` `<이름>.yaml` 꼴이 아닌 것이 있다 (1) `` |
| WR-02 | README 검사 (f) · (g) 가 따옴표 · 줄 끝 주석 · 두 자리 버전 값을 조용히 건너뛴다 — 낡은 값으로 통과 | fixed | 아니오 | 18행을 `      ref: 'v1.9.0'` 으로 → `passed=false` (`ref: v1.9.0` 이 다르다) |
| WR-03 | `fencedLines` 가 ``` 펜스만 안다 — `~~~` 코드 블록의 값은 (f) · (g) 가 보지 않는다 | fixed | 아니오 | 328 · 334행 펜스를 `~~~` 로, 333행을 `v1.9.0` 으로 → `passed=false` |
| WR-04 | (b′) 가 flow 표기 `linter: {rules: [...]}` 로 다른 조각에 적은 규칙을 보지 못한다 — 사용 프로젝트는 받는데 검증은 10개 중 10개 | fixed | 아니오 | `lib/codegen.yaml` 끝에 `linter: {rules: [prefer_mixin]}` → `FormatException: lib/codegen.yaml 의 10행: `linter:` 줄에 값이 붙어 있다 …` |
| WR-05 | `readShippedPluginConstraint` 가 YAML 토큰을 그대로 돌려주고 올바른 꼴 셋을 거부한다 — 70 이나 통과할 수 없는 `[3/N]` · `[4/N]` | fixed | 아니오 | `"^3.1.9"` → `passed=true`. `">=3.1.9 <4.0.0"` → `… 꼴만 받는다 (범위 제약은 받지 않는다, …)` 의 `FormatException` |
| WR-06 | `.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다 | deferred | 예 | 마지막 커밋은 여전히 `403c584`. 69 · 70 · 73 · 173 · 182 · 183 · 313행이 그대로다 (아래 WR-06) |
| WR-07 | README 검사 (e) 가 `package:` 로 정확히 시작하지 않는 include 주소를 보지 않는다 — scheme 오타로 10개 중 10개 | skipped | 예 | 68행 `  - packages:woody_lints/riverpod.yaml` → `passed=true`. 문장(`example/README.md:116`, `tool/verify.dart:1877`)은 맞게 적는다 |
| WR-08 | README 검사 (f) · (g) 가 flow 표기에 적힌 plugin 버전 · `ref:` 를 보지 않는다 — 낡은 값으로 10개 중 10개 | skipped | 예 | 196 ~ 199행 블록을 `plugins: {riverpod_lint: ^3.1.3}` 로 → `passed=true`. 문장은 맞게 적는다 |
| WR-09 | `fencedLines` 가 펜스가 아닌 코드 블록을 보지 않는다 — 들여쓴 코드 블록의 낡은 `ref:` 로 10개 중 10개 | skipped | 예 | 328 ~ 334행을 펜스 없이 네 칸 들여 쓴 블록으로, `ref: v1.9.0` → `passed=true`. 문장은 맞게 적는다 |
| WR-10 | `[3/10]` 이 조각의 `linter:` 밖 키를 보지 않는다 — `lib/codegen.yaml` 의 `language:` 옵션 · `formatter:` 가 사용 프로젝트에 닿는데 10개 중 10개 | fixed | 아니오 | M71 → `passed=false` · `5행:   language:`. M72 → `passed=false` · `10행: formatter:` |
| WR-11 | (a′) · `declaredRuleNames` 가 `\n` 으로만 줄을 나눈다 — 주석 줄 끝의 CR(`\r`) 뒤에 둔 키 · 규칙이 사용 프로젝트에 닿는데 10개 중 10개 | fixed | 아니오 — `d771c0c` | M79 · M82 · M83 · M84 · M85 의 입력을 함수 단위로 → 모두 `passed=false`, 블록은 `example/README.md` 05-12 소절 그대로다. CRLF · CR 하나 · 마지막 줄바꿈 없음은 거짓 실패 없음 (Summary) |
| WR-12 | (d′) 의 절 경계가 HTML 주석 안의 `#` 줄 · 4칸 들여 쓴 ```` ``` ```` 를 제목 · 펜스로 본다 — 렌더링된 「받는 규칙」 목록 바로 아래의 불릿으로 10개 중 10개 | skipped | 예 (동작) | 지난 세 입력(188행 뒤 HTML 주석, 91행 뒤 start 마커 앞, 188행 뒤 4칸 펜스) → 셋 다 `passed=true`. 대조(마커 바로 뒤 불릿)는 `passed=false` · `189행`. 정의 문장은 `d8b61b0` 으로 `example/README.md:116` · `:549` 에 들어갔다 |
| WR-13 | README 검사 (f) · (g) 가 따옴표로 감싼 키 · 콜론 앞 공백(`"ref":` · `'riverpod_lint':` · `ref :`)을 후보로 보지 않는다 — 낡은 값으로 10개 중 10개, 좁힌 문장은 "모두 후보로" | skipped | 예 (동작) | 18행 `"ref": v1.9.0` · `ref : v1.9.0`, 198행 `'riverpod_lint': ^3.1.3`, 234행 `"version": ^3.1.3` → 넷 다 `passed=true`. "모두 후보로" 의 어긋남은 `d8b61b0` 으로 닫혔다 (`README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:1873` · `:1875` · `:1877` · `:2147` · `:2193`) |
| WR-14 | (e) 의 다른 패키지 주소 검사는 `.yaml` · `.yml` 로 끝나는 주소만 보는데, 좁힌 문장과 문서 주석은 "`package:` 로 정확히 시작하는 주소가 꼴이 아니면 실패" 라고 적는다 — `package:woody-lints/riverpod` 로 10개 중 10개 | skipped | 예 (동작) | 68행 `package:woody-lints/riverpod` · `package:woody_lint/riverpod.yam` → 둘 다 `passed=true`. 대조 `package:woody-lints/riverpod.yaml` → `passed=false`. 문장 쪽 어긋남은 `d8b61b0` 으로 닫혔다 (`example/README.md:116`, `tool/verify.dart:1871` · `:1877`) |
| IN-01 | `pubspecReleaseVersion` 이 따옴표로 감싼 `version:` 에서 종료 코드 70 | fixed | 아니오 | `version: "2.0.0-dev"` → `passed=true` |
| IN-02 | CHANGELOG 2.0.0 의 "내용은 1.3.0 과 같다" 가 같은 절의 다른 항목과 어긋난다 | fixed | 아니오 | `git diff --stat ddfb852 HEAD -- CHANGELOG.md lib RULES.md` 가 빈 출력 |
| IN-03 | README 「프리셋 고르기」 의 "그 연습용 프로젝트의 정답지로 확인" 이 묶음에는 맞지 않는다 | fixed | 아니오 | `README.md:45` 의 "묶음(`recommended`)에는 자기 정답지가 없다 — …" 그대로 |
| IN-04 | plugin 하한을 올릴 때 함께 고칠 자리가 두 문서에 반씩 적혀 있다 | fixed | 아니오 | `README.md:382` 가 네 자리를 한 곳에 적는다 |
| IN-05 | `tool/verify.dart` 문서 주석의 단계 번호가 `[2/4]` · `[1/4]` 로 남아 있다 | fixed | 아니오 | `grep -c '\[2/4\]\|\[1/4\]' tool/verify.dart` → 0 |
| IN-06 | `readBulletBlock` 이 `readRulesMdBlock` 의 마커 처리를 복제하고, 결과 타입 이름이 README 에 맞지 않는다 | fixed | 아니오 | `tool/verify.dart:1683` `readMarkerBlock` 이 `:1698` `findMarkerRange` 를 부른다 |
| IN-07 | README 「받는 규칙」 의 분류는 검사되지 않는다 | fixed | 아니오 | `README.md:91` 의 "검증 명령은 이름만 견주고 분류는 보지 않는다" 그대로 |
| IN-08 | (e) 의 주소 끝 판정이 문장 부호를 모른다 — 맞는 주소의 거짓 실패와 다른 패키지 주소의 누락이 한 줄에서 함께 난다 | skipped | 예 (동작) | 85행 끝에 ` 예: package:woody_lints/recommended.yaml, package:woody-lints/base.yaml.` → `passed=false`. 블록은 `package:woody_lints/recommended.yaml,` 하나, 다른 패키지 블록 0개. `tool/verify.dart:1864` 주석의 어긋남은 `d8b61b0` 으로 닫혔다 (지금 `:1877`) |
| IN-09 | (a′) 가 들어온 뒤 M35 · M37 의 `[3/10]` 출력이 바뀌었는데, 05-10 소절은 M46 만 짚는다 | fixed | 아니오 — `d8b61b0` | `example/README.md:518` 이 "M35 · M37 · M46 은 이제 `[3/10]` 에 블록 둘(최상위 · 규칙)을 찍는다. 05-01 · 05-07 소절의 그 행은 그때의 기록이다" |

## 소유자가 이번 범위 밖으로 둔 것

ID 를 주지 않는다. 이번에 확인한 그대로 적는다.

- **`tool/measure_rules.dart` 의 줄 나누기** (G3-R2-Q2 "두기"). `split('\n')` 이 6곳 그대로다 (`grep -c`). 측정 도구라 배포 · 검증 명령에 들지 않는다.
- **`stripPlugins` 끝의 `^plugins:` 여러 줄 확인** (U+2028 에서 거짓 실패 쪽 — G3-R2 NOT approved). 그대로다.
  - 재현(함수 단위): `lib/riverpod.yaml` 1행 끝에 ` ` + U+2028 + `plugins: memo` 를 붙였다.
  - 결과: `FormatException: lib/riverpod.yaml 의 `plugins:` 섹션을 빼지 못했다`, 곧 종료 코드 70 경로다.
- **(e) 의 여러 줄 정규식** (G2-Q2 · G3-Q2). `tool/verify.dart:2088` · `:2110` 의 `multiLine: true` 가 그대로다 (코드에서 읽은 것, 따로 돌리지 않았다).
- **(d′) · (e) · (f) · (g) 의 검사 코드를 넓히는 수정** (G3-Q2 · G3-Q3). WR-07 · WR-08 · WR-09 · WR-12 · WR-13 · WR-14 · IN-08 의 동작이 그대로 남은 까닭이다 (위 표).
  - 이번에 고친 문장은 그 동작을 맞게 적는다.
  - 예외가 하나 있다. `README.md:382` 는 펜스 안의 4칸 ```` ``` ```` 줄을 적지 않는다 → IN-10.

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

이번 재리뷰도 이 지시를 컨텍스트로 받았다.

**재현:** 해당 없음(읽어서 대조한 것).

**Fix:** D-09 대로 마일스톤 끝 `/gsd-map-codebase` 에서 69 · 70 · 73 · 173 · 182 · 183 · 313행을 지금 구조로 고친다.

### WR-07: README 검사 (e) 가 `package:` 로 정확히 시작하지 않는 include 주소를 보지 않는다 — scheme 오타로 10개 중 10개

**File:** `tool/verify.dart:2086-2089`, `tool/verify.dart:2107-2116`
**Issue:** 지난 리뷰와 같은 입력이 지금도 통과한다. 소유자 결정 G2-Q2 로 `skipped` 이고 코드는 그대로다. 문장은 이 입력을 범위 밖으로 맞게 적는다 — `example/README.md:116` 의 "`packages:` 같은 scheme 오타 · `package:` 뒤의 공백은 보지 않고", `tool/verify.dart:1877` 의 "(e) 는 `package:` 로 시작하지 않는 scheme 오타 · … 를 보지 않고".

**재현(함수 단위):** README 68행을 `  - packages:woody_lints/riverpod.yaml` 로 바꿨다. 결과는 `passed=true` 였다.

**Fix:** 소유자 결정대로 둔다. 다시 넓히려면 지난 리뷰의 Fix 그대로다.

### WR-08: README 검사 (f) · (g) 가 flow 표기에 적힌 plugin 버전 · `ref:` 를 보지 않는다 — 낡은 값으로 10개 중 10개

**File:** `tool/verify.dart:2149-2151`, `tool/verify.dart:2195`
**Issue:** 지난 리뷰와 같은 입력이 지금도 통과한다. G2-Q2 로 `skipped` 이고 코드는 그대로다. 문장(`README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:1877` · `:2146` · `:2192`)은 flow 표기를 범위 밖으로 맞게 적는다.

**재현(함수 단위):** 196 ~ 199행 블록을 `plugins: {riverpod_lint: ^3.1.3}` 한 줄로 바꿨다(234행은 `^3.1.9` 그대로). 결과는 `passed=true` 였다.

**Fix:** 소유자 결정대로 둔다.

### WR-09: `fencedLines` 가 펜스가 아닌 코드 블록을 보지 않는다 — 들여쓴 코드 블록의 낡은 `ref:` 로 10개 중 10개

**File:** `tool/verify.dart:1503-1529`
**Issue:** 지난 리뷰와 같은 입력이 지금도 통과한다. G2-Q2 로 `skipped` 이고 코드는 그대로다. 문장(`README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:1502` · `:2139`)은 맞게 적는다.

같은 함수의 반대쪽 꼴은 다른 입력이다. 펜스 안의 네 칸 들여 쓴 ```` ``` ```` 가 펜스를 일찍 닫는 꼴이고, IN-10 에 적었다.

**재현(함수 단위):** 328 ~ 334행 블록의 펜스 두 줄을 빼고 나머지를 네 칸 들여 썼다. 값은 `ref: v1.9.0` 으로 바꿨다. 결과는 `passed=true` 였다.

**Fix:** 소유자 결정대로 둔다.

### WR-12: (d′) 의 절 경계가 HTML 주석 안의 `#` 줄 · 4칸 들여 쓴 ```` ``` ```` 를 제목 · 펜스로 본다 — 렌더링된 「받는 규칙」 목록 바로 아래의 불릿으로 10개 중 10개

**File:** `tool/verify.dart:1539-1564`, `tool/verify.dart:1816-1847`
**Issue:** 동작은 지난 리뷰와 같다. 소유자 결정 G3-Q3 은 "정의를 문장에 적고 검사는 고치지 않는다" 였다. `d8b61b0` 이 그 정의를 넣었다.

- `example/README.md:116` — "제목 · 펜스 판정은 HTML 주석(`<!--` ~ `-->`) 안의 `#` 줄과 네 칸 이상 들여 쓴 `` ``` `` 줄을 가리지 않아 … 검사 밖이 될 수 있다"
- `example/README.md:549` — 같은 정의

이제 문장은 동작과 맞는다. 렌더링된 절 안의 목록 줄이 검사 밖이 되는 동작은 남아 있다.

**재현(함수 단위):** 셋 모두 `passed=true` 였다.
- 188행 뒤에 `<!--` / `# 메모` / `-->` / `` - `bogus_after_comment` `` 을 끼웠다.
- 91행 뒤에 `` - `bogus_before` `` / `<!--` / `# 메모` / `-->` 를 끼웠다.
- 188행 뒤에 빈 줄 / `    ```` / `` - `bogus_after_indented` `` / `    ```` 를 끼웠다.

**대조:** 188행 뒤에 `` - `bogus_after_marker` `` 한 줄만 끼웠다. `passed=false`, `189행: - `bogus_after_marker`` 였다.

**Fix:** 소유자 결정대로 둔다. 다시 고치려면 지난 리뷰의 Fix 그대로다.

### WR-13: README 검사 (f) · (g) 가 따옴표로 감싼 키 · 콜론 앞 공백(`"ref":` · `'riverpod_lint':` · `ref :`)을 후보로 보지 않는다 — 낡은 값으로 10개 중 10개, 좁힌 문장은 "모두 후보로"

**File:** `tool/verify.dart:2149-2151`, `tool/verify.dart:2195`
**Issue:** 동작은 지난 리뷰와 같다. 제목 끝의 "좁힌 문장은 '모두 후보로'" 쪽은 `d8b61b0` 으로 닫혔다 (G3-Q2). 키 글자 구절이 들어간 자리는 다음과 같다.

- `README.md:382`
- `example/README.md:116` · `:395`
- `tool/verify.dart:1873` · `:1875` · `:1877` (문서 주석)
- `tool/verify.dart:2147` · `:2193` (함수 안 주석)

새 구절은 "키는 따옴표 · 콜론 앞 공백 없이 … 글자 그대로인 줄만 후보" 다. 지금 문장은 동작과 맞는다. 남은 것은 YAML 로는 같은 키인 줄의 값을 견주지 않는 동작이다.

**재현(함수 단위):** 각각 따로 돌렸고 넷 모두 `passed=true` 였다.
- 18행 `      "ref": v1.9.0`
- 18행 `      ref : v1.9.0`
- 198행 `  'riverpod_lint': ^3.1.3`
- 234행 `    "version": ^3.1.3`

**Fix:** 소유자 결정대로 둔다.

### WR-14: (e) 의 다른 패키지 주소 검사는 `.yaml` · `.yml` 로 끝나는 주소만 보는데, 좁힌 문장과 문서 주석은 "`package:` 로 정확히 시작하는 주소가 꼴이 아니면 실패" 라고 적는다 — `package:woody-lints/riverpod` 로 10개 중 10개

**File:** `tool/verify.dart:2107-2116`
**Issue:** 동작은 지난 리뷰와 같다. 제목의 문장 쪽 어긋남은 `d8b61b0` 으로 닫혔다 (G3-Q2).

- `example/README.md:116` 은 이제 "`package:<이름>/` 뒤가 `.yaml` · `.yml` 로 끝나는 다른 패키지의 주소면 실패하고 (확장자가 `.yaml` · `.yml` 이 아닌 다른 패키지의 주소(`package:woody-lints/riverpod`) … 는 보지 않고" 라고 적는다.
- `tool/verify.dart:1871` · `:1877` 도 같은 범위를 적는다.

남은 것은 그 주소를 보지 않는 동작이다.

**재현(함수 단위):** 68행을 `  - package:woody-lints/riverpod` 로, 또 `  - package:woody_lint/riverpod.yam` 로 바꿨다. 둘 다 `passed=true` 였다.

**대조:** 68행 `  - package:woody-lints/riverpod.yaml` → `passed=false`, `` `README.md` 에 `woody_lints` 가 아닌 패키지의 `.yaml` 주소가 있다 (1) ``.

**Fix:** 소유자 결정대로 둔다.

### WR-15: `pubspecReleaseVersion` 이 여러 줄 따옴표 스칼라 안의 `version:` 줄을 읽는다 — pub 은 진짜 `version:` 을 읽는데 README 의 낡은 `ref:` 로 10개 중 10개

**File:** `tool/verify.dart:1587-1604` (줄 찾기 `:1592-1596`), `tool/verify.dart:1584-1585`, `example/README.md:588`
**Issue:** 05-12 는 `pubspecReleaseVersion` 을 줄 단위로 바꿨다 (G3-R2-Q1, "숨긴 값이 아니라 진짜 값을 읽는다"). 여러 줄 정규식이 U+2028 뒤에 숨긴 `version:` 을 읽던 꼴은 닫혔다. 그런데 줄 단위 reader 는 YAML 스칼라를 모른다.

- 앞의 키 값이 여러 줄 따옴표 스칼라면, 그 다음 줄의 열 0 `version: …` 은 YAML 로는 그 문자열의 일부다.
- reader 는 열 0 의 첫 `^version:` 줄을 그대로 돌려준다.

pub (package:yaml) 은 따옴표 스칼라의 이어지는 줄이 열 0 이어도 받는다 (아래 대조). 그래서 `description:` 을 여러 줄 따옴표 값으로 적고 그 안에 `version: 1.9.0` 줄이 끼면 두 쪽이 갈린다.

- pub 은 `2.0.0-dev` 로 읽는다. 사용 프로젝트가 받는 버전 · tag 의 기준이다.
- `[3/10]` (g) 는 `1.9.0` 과 README 의 `ref:` 를 견준다.

같은 모양이 U+2028 꼴과 다른 입력으로 다시 나온 것이다. `tool/verify.dart:1584-1585` 의 문서 주석과 `example/README.md:588` 은 "이제 진짜 값을 읽는다" 고 읽힌다. 이 입력에서는 그렇지 않다.

- **재현(전체 실행, 복제본):**
  - `pubspec.yaml` 2행을 세 줄로 바꿨다: `description: "Woody's custom lint rules for Flutter projects.` / `version: 1.9.0` / `"`.
  - README 18 · 333행을 `      ref: v1.9.0` 으로 바꿨다.
  - `git diff --numstat` 은 `pubspec.yaml 3/1`, `README.md 2/2` 였다.
  - 결과는 종료 코드 0, `[3/10] 배포 파일의 구성 ... 통과`, `점검 통과 (10개 중 10개)` 였다.
  - 같은 복제본에서 `fvm dart pub deps` 의 머리 셋째 줄은 `woody_lints 2.0.0-dev` 였다.
- **함수 단위:** 같은 변형에서 `pubspecReleaseVersion` → `1.9.0`.
- **대조:**
  - `pubspec.yaml` 만 되돌리고 README 의 `v1.9.0` 은 둔 채 돌렸다. `passed=false`, `` `ref: vX.Y.Z` 예시가 `pubspec.yaml` 의 version (2.0.0) 과 다르다 `` · `ref: v1.9.0` 이었다.
  - `$T/q` 에 따로 만든 패키지(`name: q` / `description: "foo bar.` / `version: 1.9.0` / `"` / `version: 2.0.0-dev` / `environment: …`)에서도 확인했다. `fvm dart pub get --offline` 은 성공했고, `pub deps` 는 `q 2.0.0-dev`, `pubspecReleaseVersion` 은 `1.9.0` 이었다.

**Fix:** 숨은 값을 고르지 말고 읽지 못하는 꼴로 멈춘다 (종료 코드 70 — 지금 "version: 을 읽지 못했다" 와 같은 길).

1. YAML 은 같은 키를 두 번 받지 않는다. 그러므로 열 0 의 `version:` 줄이 둘 이상이면 하나는 스칼라 안의 줄이다.
2. 여러 줄 스칼라를 여는 줄(값이 따옴표로 열리고 그 줄에서 닫히지 않거나, 값이 `|` · `>`)이 있으면 멈춘다.

```dart
// 열 0 의 `version:` 줄은 정확히 하나여야 한다 — 둘 이상이면 하나는 여러 줄 스칼라 안의 줄이다 (WR-15).
final found = [
  for (final line in lines)
    if (versionLine.firstMatch(line) case final m?) m.group(1)!,
];
if (found.length != 1 || lines.any(opensMultilineScalar)) {
  throw FormatException(
    'pubspec.yaml 에서 version: 을 하나로 읽지 못했다 — 열 0 의 `version:` 줄 ${found.length}개, '
    '여러 줄 스칼라(따옴표 값이 다음 줄로 이어지거나 `|` · `>`)는 받지 않는다',
  );
}
final raw = found.single;
```
`opensMultilineScalar` 는 WR-16 의 Fix 와 같은 도우미다. 고친 뒤 위 입력을 지워 보기 행으로 남긴다.

### WR-16: `declaredRuleNames` · `enabledLanguageOptions` 가 여러 줄 스칼라(따옴표 · 블록) 안의 줄을 규칙 · 옵션으로 읽는다 — 사용 프로젝트에 닿지 않는 규칙 · 옵션을 `RULES.md` · README 가 켰다고 적는데 10개 중 10개

**File:** `tool/verify.dart:951-997` (`:966` 주석 줄 건너뛰기, `:967` `linter:` 줄), `tool/verify.dart:1101-1159` (`:1145` 깊이를 보지 않는 `language:` 판정), `tool/verify.dart:1029-1081`, `README.md:379`, `example/README.md:116`
**Issue:** WR-15 와 같은 뿌리다. `lib/base.yaml` 의 줄 단위 reader 둘이, YAML 로는 글자 값의 일부인 줄을 키 · 규칙 · 옵션으로 읽는다. 자유 글자 값을 받는 자리는 `lib/base.yaml` 의 `analyzer:` 아래 `exclude:` glob 이다. 그 아래 키는 닫힌 목록이 없다 (G2-Q1 범위 밖). 거기에 여러 줄 값을 두면 둘이 갈린다.

- **따옴표 꼴:** `    - "build/**` 로 연 값이 다음 줄들로 이어지고, `    # "` 로 닫힌다.
  - reader 는 그 사이의 열 0 `linter:` · `  rules:` · `    - 규칙` 줄을 둘째 `linter:` 블록으로 읽는다.
  - 닫는 줄은 reader 에게는 주석이고, YAML 에게는 문자열 안의 `# ` 뒤 닫는 따옴표다.
  - `findUnexpectedKeys` 는 같은 최상위 키가 두 번 나와도 막지 않는다 (`:1050-1064`). YAML 은 두 번째 `linter:` 를 받지 않는 파일인데도 그렇다.
  - `enabledLanguageOptions` 도 같은 따옴표 값 안의 `  language:` / `    strict-casts: true` 를 켠 옵션으로 읽는다.
- **블록 스칼라 꼴:** `    - |` 아래 `      language:` / `        strict-casts: true`.
  - `enabledLanguageOptions` 는 `analyzer:` 블록 안 어느 깊이의 `language:` 든 받는다 (`:1145`).
  - YAML 로는 glob 문자열 한 개다.

결과는 이렇다.

- `RULES.md` 의 켠 규칙 표 · 켠 analyzer 옵션 표와 README 의 「받는 규칙」 목록이, 사용 프로젝트가 받지 않는 규칙 · 옵션을 적는다.
- 그런데 (c) · (d) 는 같다고 본다.
- `README.md:379` 의 "어긋나면 검증이 실패한다" 와 프로젝트의 Core Value(받는 규칙이 문서에 적힌 그대로)가 이 입력에서 거짓이 된다.

`[2/10]` 도, 정답지도 잡지 못한다. analyzer 에게는 그 규칙 · 옵션이 없기 때문이다.

- **재현(전체 실행, 셋 — 모두 종료 코드 0, `[3/10] 통과`, `점검 통과 (10개 중 10개)`):**
  - (규칙) `lib/base.yaml` 끝에 일곱 줄 `analyzer:` / `  exclude:` / `    - "build/**` / `linter:` / `  rules:` / `    - always_specify_types` / `    # "` 를 붙였다. `RULES.md` 92행 뒤에 `` | `always_specify_types` | 버그 방지 | x | 0 · 0 · 0 | 해당 없음 | x | `` 를 더했다. README 186행 뒤에 `` - `always_specify_types` `` 를 더했다. 같은 규칙을 진짜 규칙 줄로 넣은 M80 (`example/README.md` 05-12 소절)은 `[2/10]` 과 정답지 단계 다섯이 실패했다. 이번에는 analyzer 가 그 규칙을 켜지 않았다.
  - (규칙, 같은 꼴) 위에서 규칙만 `prefer_mixin` 으로 바꿨다. 결과는 같다.
  - (옵션, 따옴표) `lib/base.yaml` 끝에 `analyzer:` / `  exclude:` / `    - "build/**` / `  language:` / `    strict-casts: true` / `    # "` 를 붙였다. `RULES.md` 102행 `없음 — …` 을 `` | `strict-casts` | x | 0 | x | `` 로 바꿨다.
- **재현(전체 실행, 블록 스칼라):** `lib/base.yaml` 끝에 `analyzer:` / `  exclude:` / `    - |` / `      language:` / `        strict-casts: true` 를 붙였다. `RULES.md` 는 위와 같이 바꿨다. 결과는 종료 코드 0, `점검 통과 (10개 중 10개)` 였다.
- **대조(전체 실행):** 같은 `RULES.md` 에서 `lib/base.yaml` 끝을 진짜 옵션(`analyzer:` / `  exclude:` / `    - "build/**"` / `  language:` / `    strict-casts: true`)으로 바꿨다.
  - 결과는 종료 코드 1, `점검 실패 (10개 중 5개)` 였다.
  - `[5/10]` · `[7/10]` ~ `[10/10]` 이 `invalid_assignment` error 로 실패했다. 옵션이 진짜로 켜지면 사용 프로젝트에 닿는다는 뜻이다.
- **대조(analyzer):** `$T/p` 의 작은 프로젝트(`print(1);` 한 줄)에서 돌렸다.
  - 옵션 파일 `linter:` / `  rules:` / `    - prefer_single_quotes` / `analyzer:` / `  exclude:` / `    - "build/**` / `linter:` / `  rules:` / `    - avoid_print` / `    # "` → `No issues found!`.
  - 같은 `avoid_print` 를 진짜 규칙 줄로 둔 대조 → `avoid_print` info 한 줄.

**Fix:** 둘 중 하나 (또는 둘 다). 어느 쪽이든 새 승인이 필요하다 — G2-Q1 은 `lib/base.yaml` 의 `analyzer:` 아래를 범위 밖으로 뒀다.

1. **줄 단위 reader 가 읽지 못하는 꼴로 멈춘다** (WR-15 와 같은 도우미). 대상은 `lib/` 조각 셋과 `pubspec.yaml` 이다. 다음이 있으면 `[3/10]` 실패(또는 70)로 멈춘다.
   - 여러 줄 스칼라를 여는 줄
   - 같은 최상위 키가 두 번 나온 줄 (`findUnexpectedKeys`)
```dart
/// [line] 이 여러 줄 스칼라를 여는지 — 값이 따옴표로 열리고 그 줄에서 닫히지 않거나, `|` · `>` 블록 스칼라다.
/// 줄 단위 reader 는 그 아래 줄을 키 · 규칙으로 읽으므로 받지 않는다 (WR-15 · WR-16).
bool opensMultilineScalar(String line) {
  final value = RegExp(r'^\s*(?:-\s+|[^\s#][^:#]*:\s+)(.+?)\s*$')
      .firstMatch(line)
      ?.group(1);
  if (value == null) return false;
  if (RegExp(r'^[|>][-+0-9]*(?:\s+#.*)?$').hasMatch(value)) return true;
  final quote = value[0];
  if (quote != '"' && quote != "'") return false;
  // 같은 줄 안에서 닫는 따옴표 뒤에는 `# 주석` 만 온다 — 아니면 다음 줄로 이어진다.
  return !RegExp('^$quote.*$quote(?:\\s+#.*)?\$').hasMatch(value);
}

// findUnexpectedKeys: 같은 최상위 키가 두 번이면 받지 않는 줄 — YAML 은 중복 키를 받지 않는다.
final seenKeys = <String>{};
// … indent == 0 이고 key 를 읽은 곳에서
if (!seenKeys.add(key)) topLevel.add(shown);
```
   이 꼴은 따옴표 안에 따옴표를 겹쳐 쓴 값(`"a \" b"`)을 여는 줄로 볼 수 있다. 그러면 거짓 실패 쪽이다 — 지금 조각에는 그런 값이 없다.
2. **자유 글자 값을 받는 자리를 닫는다.** `allowedChildKeys` 에 `'lib/base.yaml': {'analyzer': {'language'}}` 를 둔다. 그러면 `lib/base.yaml` 에는 여러 줄 값을 둘 자리가 `include:` 값 하나만 남는다. 그 값을 여러 줄로 쓰면 include 가 풀리지 않아 `[2/10]` 이 잡는다. 다만 `pubspec.yaml` (WR-15) 은 이 길로 닫히지 않는다.

`enabledLanguageOptions` 의 `language:` 판정은 따로 좁힌다. `analyzer:` 바로 아래(첫 자식 줄의 들여쓰기)만 받게 한다. 블록 스칼라 꼴은 1 이 없어도 이것으로 닫힌다. 고친 뒤 위 네 입력을 지워 보기 행으로 남긴다.

## Info

### IN-08: (e) 의 주소 끝 판정이 문장 부호를 모른다 — 맞는 주소의 거짓 실패와 다른 패키지 주소의 누락이 한 줄에서 함께 난다

**File:** `tool/verify.dart:2086-2089`, `tool/verify.dart:2107-2110`
**Issue:** 동작은 지난 리뷰와 같다 (G2-Q2 `skipped`). 지난 리뷰가 짚은 `tool/verify.dart:1864` 주석은 `d8b61b0` 으로 고쳐졌다. 지금 `:1877` 은 "주소 바로 뒤에 `,` · `.` 같은 문장 부호가 붙으면 `woody_lints` 주소는 꼴이 아닌 것으로 실패하고 다른 패키지의 주소는 후보가 되지 않는다" 라고 적는다. 문장은 이제 동작과 맞는다.

**재현(함수 단위):** README 85행 끝에 ` 예: package:woody_lints/recommended.yaml, package:woody-lints/base.yaml.` 를 덧붙였다. 결과는 `passed=false` 였다.
- 블록은 `` `<이름>.yaml` 꼴이 아닌 것이 있다 (1): `` · `package:woody_lints/recommended.yaml,` 하나였다.
- "아닌 패키지" 블록은 0개였다.

**Fix:** 소유자 결정대로 둔다.

### IN-10: (f) · (g) 의 범위 문장이 펜스 안의 네 칸 들여 쓴 ```` ``` ```` 줄을 적지 않는다 — 그 줄이 `fencedLines` 의 펜스를 닫아 진짜 펜스 안의 낡은 `ref:` 로 통과

**File:** `tool/verify.dart:1518-1525`, `tool/verify.dart:1489-1502`, `README.md:382`, `example/README.md:116`, `example/README.md:395`
**Issue:** `fencedLines` 는 블록 안에서 `trim()` 한 줄이 펜스 문자만이면 블록을 닫는다 (`:1518-1525`). 들여쓰기는 보지 않는다. CommonMark 의 닫는 펜스는 들여쓰기 3칸까지다. 네 칸 이상 들여 쓴 ```` ``` ```` 줄은 펜스 안의 내용이다. 그래서 그런 줄 뒤의 같은 블록 줄은 (f) · (g) 의 후보가 아니다.

`d8b61b0` 이 고친 `README.md:382` 는 견주지 않는 꼴을 나열한다. 따옴표 키 · 콜론 앞 공백, flow 표기, 네 칸 들여 쓴 코드 블록, 인용 안의 펜스다. 이 꼴은 그 목록에 없다. 이 꼴의 값은 렌더링된 README 에서 펜스 코드 블록 안에 보인다. 그러니 문장대로라면 "견준다" 쪽이다. `example/README.md:116` · `:395` 도 같다.

(d′) 쪽은 같은 규칙(`markFencedLines`)을 `example/README.md:549` 가 "네 칸 이상 들여 쓴 ```` ``` ```` 줄도 펜스 여는 줄로 본다" 라고 적는다. (f) · (g) 의 문장에만 빠져 있다. WR-09 (펜스가 아닌 코드 블록)와는 입력이 다르다. 낡은 값이 진짜 펜스 안에 있다.

입력 가능성은 낮다 — YAML 예시 안에 그런 줄을 둘 까닭이 드물다. 그래서 Info 로 둔다.

- **재현(함수 단위):** README 330행(`  woody_lints:`) 뒤에 `    ```` 한 줄을 끼우고, 333행(이제 334행)을 `      ref: v1.9.0` 으로 바꿨다. `git diff --numstat` 은 `2/1` 이었다. 결과는 `passed=true` 였다.
- **대조:** `    ```` 줄 없이 333행만 `v1.9.0` 으로 바꿨다. `passed=false`, `ref: v1.9.0` 블록이 나왔다.
- **렌더링 확인:** 합성 조각 ```` ```yaml ```` / `a:` / `  b:` / `    ```` / `    ref: v1.9.0` / ```` ``` ```` 을 GitHub Markdown API(`gfm`)로 그렸다. `<pre>` 하나 안에 ```` ``` ```` 글자와 `ref: v1.9.0` 이 함께 나왔다.

**Fix:** G2-Q2 · G3-Q2 와 같은 길이면 문장만 고친다. `README.md:382` · `example/README.md:116` · `:395` 와 `fencedLines` 문서 주석(`:1502`)의 범위 밖 목록에 다음을 더한다: "펜스 안에서 네 칸 이상 들여 쓴 `` ``` `` · `~~~` 줄은 그 펜스를 닫는 것으로 보아, 그 뒤의 같은 블록 값은 견주지 않는다". 코드로 닫으려면 닫는 줄의 들여쓰기를 3칸까지로 제한한다. `markFencedLines` 와 함께 고쳐야 한다(`:1536-1537`). 이쪽은 새 승인이 필요하다.

### IN-11: `stripPlugins` 문서 주석의 "복사본의 줄 수 … 가 원본과 같다" 가 `plugins:` 섹션이 파일 끝일 때 맞지 않는다

**File:** `tool/verify.dart:832`, `tool/verify.dart:857`
**Issue:** 05-12 뒤 `stripPlugins` 의 흐름은 이렇다.

- `splitYamlLines` (`LineSplitter`) 는 끝 줄바꿈 뒤의 빈 조각을 만들지 않는다.
- 비운 줄을 `join('\n')` 하면 마지막 빈 줄의 줄바꿈이 사라진다.

`lib/riverpod.yaml` 은 5줄이고 `plugins:` 섹션(4 · 5행)이 끝에 있다. 그 복사본은 `splitYamlLines` 로 4줄이다. 고치기 전 코드(`split('\n')`)는 5줄이었다. 줄 번호는 내용이 있는 줄에서 원본과 같으므로 진단과 `readRuleNameAt` 에는 영향이 없다.

다만 `:832` 의 "복사본의 줄 수와 줄 번호가 원본과 같다" 는 이제 줄 수에서 틀리다. 05-12 계획의 설계 절은 "마지막 줄바꿈은 복사본에서 빠질 수 있다" 고 적었지만, 문서 주석에는 옮겨지지 않았다.

**재현(함수 단위):** 지금 `lib/riverpod.yaml` 에 `stripPlugins` 를 불렀다. `splitYamlLines(결과).length` → 4 였다 (원본 5).

**Fix:** 둘 중 하나.
- 문서 주석을 "줄 번호가 원본과 같다 (끝의 빈 줄은 빠질 수 있다)" 로 고친다.
- 줄 수까지 맞춘다:
```dart
final stripped = lines.isEmpty ? '' : '${lines.join('\n')}\n';
```

---

_Reviewed: 2026-10-14T13:41:37Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
