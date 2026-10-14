---
phase: 05-documentation
reviewed: 2026-10-14T22:04:35Z
depth: standard
files_reviewed: 7
files_reviewed_list:
  - .claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md
  - .claude/skills/spike-findings-woody-lints/references/rule-status-check.md
  - .claude/skills/spike-findings-woody-lints/SKILL.md
  - example/README.md
  - pubspec.yaml
  - README.md
  - tool/verify.dart
findings:
  critical: 0
  warning: 7
  info: 5
  total: 12
status: issues_found
---

# Phase 5: Code Review Report

**Reviewed:** 2026-10-14T22:04:35Z
**Depth:** standard
**Files Reviewed:** 7
**Status:** issues_found

## Summary

4회차 gap 수정 05-14 · 05-15 (커밋 `77e0b88` · `0f62057` · `2336ba0`, diff base `299718f`) 뒤의 재리뷰다. 범위 파일 일곱을 읽었다. `.claude/CLAUDE.md` 는 WR-06 이 아직 해당하는지 보려고 해당 줄만 대조했다.

**기준 실행 (복제본):**

- `fvm dart run tool/verify.dart` — 종료 코드 0, `점검 통과 (10개 중 10개)`, 82초 (plugin 준비 포함). Flutter 3.47.5 / Dart 3.13.4, flutter_lints 6.0.0 / lints 6.1.0, riverpod_lint 3.1.9. 실행 뒤 복제본의 `git status --porcelain` 은 빈 출력이다.
- `fvm dart analyze tool` — `No issues found!`.
- `fvm dart format --output=none --set-exit-if-changed tool` — 종료 코드 0 (`Formatted 2 files (0 changed)`).

**(h) 는 소유자 문장("지금 검사가 읽은 값과 YAML 해석 결과가 다르면 실패")을 다섯 비교에서 지킨다.** 비교마다 두 방향을 함수 단위(`checkShippedComposition`)로 넣었다.

| 비교 | reader 에만 보이는 값 | YAML 에만 보이는 값 | YAML 이 읽지 못하는 파일 |
|------|----------------------|---------------------|--------------------------|
| 규칙 (`declaredRuleNames` ↔ `linter.rules`) | WR-16 의 따옴표 꼴 둘(`always_specify_types` · `prefer_mixin`, `RULES.md` · README 도 맞춤) → `passed=false`, 블록 셋 (규칙 · 최상위 키 · `linter:` 아래 키) | 열 0 아래로 YAML 만 보는 규칙은 만들 수 없었다 — reader 는 `#` 줄만 건너뛰고, YAML 은 `#` 로 시작하는 줄에서 키 · 항목을 읽지 않는다 | — |
| 키 (`findUnexpectedKeys` ↔ 맵 키) | M88 · M89 · M90 → 각각 블록 둘 · 셋 · 둘, `example/README.md` (05-14) 표 그대로 | M89 의 `YAML 에만: language` | `lib/riverpod.yaml` 끝에 `  riverpod_lint: ^3.1.9` 한 줄 더 → `` `lib/riverpod.yaml` 을 YAML 로 읽지 못했다 — 6행: Duplicate mapping key. `` |
| 옵션 (`enabledLanguageOptions` ↔ `analyzer.language`) | WR-16 의 따옴표 꼴 · 블록 스칼라 꼴(= M91) → 블록 둘 · 하나 | M89 의 `YAML 에만: strict-inference: true` | — |
| plugin (`readShippedPluginConstraint` ↔ `plugins.riverpod_lint`) | M90 (아래 키 블록으로 잡힌다) | — | 위 Duplicate mapping key |
| version (`pubspecReleaseVersion` ↔ `version`) | M87 → `줄 단위 reader: 1.9.0` · `YAML: 2.0.0-dev` | — | `pubspec.yaml` 끝에 `version: 2.0.0-dev` 한 줄 더 → `23행: Duplicate mapping key.` |

맞는 파일에서 거짓 실패를 내는지도 봤다.

- 조각 셋과 `pubspec.yaml` 을 모두 CRLF · 모두 CR 하나 · 마지막 줄바꿈 없음 · 파일 머리 BOM · 끝에 빈 줄과 열 0 주석으로 바꾼 다섯 변형 → 모두 `passed=true`.
- 다른 올바른 꼴 셋 → 모두 `passed=true`. `lib/riverpod.yaml` 의 맵 꼴(`version:` + `diagnostics:`), `lib/base.yaml` 의 `include:` 목록 꼴, `include: >-` 접힌 블록 스칼라다.
- **발견 하나:** `include:` 의 값을 다음 줄에 둔 꼴(`include:` / `  package:flutter_lints/flutter.yaml`)이다. analyzer 와 정답지 단계는 모두 통과하는데 `[3/10]` 만 실패한다 → **IN-12**.
- package:yaml 3.1.4 는 한 글자 `!!float` 값에서 `YamlException` 이 아닌 `RangeError` 를 던진다. `load` 는 그것을 잡지 않고 main 도 받지 않는다 → **IN-14** (문서 주석과 동작의 어긋남).

**같은 모양의 다른 입력 — (h) 의 다섯 비교 안에서는 찾지 못했다.** 까닭은 이렇다.

- reader 가 최상위로 보는 줄(열 0 의 비주석 줄 전부, 또는 들여 쓴 첫 줄)은 YAML 의 최상위 키를 모두 덮는다. 그래서 YAML 에만 있는 최상위 키 · 아래 키는 목록 비교에서 드러난다.
- 값(규칙 이름 · 옵션 · plugin 선언 · version)은 reader 가 따옴표를 벗기고 꼴을 좁게 받는다. 그 밖의 꼴(escape · 태그 · 앵커 · flow)은 (h) 앞에서 종료 코드 70 으로 멈춘다 — `linter: &l` 로 확인했다.
- 글자로만 견주어 YAML 과 갈릴 수 있는 자리는 남아 있다. 묶음 · 별칭의 (a), 연습용 프로젝트 옵션의 `[4/10]`, README 의 (d) ~ (g) 다. 모두 소유자가 이번 범위 밖으로 둔 reader(`significantLines` 등)다. 아래 「소유자가 이번 범위 밖으로 둔 것」에 확인한 결과를 적었다.

**새 문장의 확인.**

- `README.md:380` · `example/README.md:11` 의 종료 코드 254 — 다시 재현했다.
  - 복제본을 `299718f` 로 두고 `fvm dart pub get --no-example` 을 돌렸다. 그 뒤 `9dc5398` 으로 checkout 하고 `fvm dart run tool/verify.dart --bogus` 를 돌렸다.
  - 결과는 종료 코드 254 였다. 첫 줄은 `Error: Couldn't resolve the package 'yaml' in 'package:yaml/yaml.dart'.` 이다.
  - `.dart_tool/` 이 없는 새 복제본에서는 같은 명령이 64 (`모르는 인자: --bogus`) 였다. 실행 뒤 `git status --porcelain` 은 빈 출력이다. 문장 그대로다.
- `example/README.md` (05-14) 소절 — 표의 블록 수와 블록 줄이 내가 넣은 입력과 맞는다.
  - M86 은 WR-16 의 `prefer_mixin` 입력과 같은 글자다. M91 은 WR-16 의 블록 스칼라 입력과 같은 글자다.
  - M87 · M88 · M89 · M90 은 표의 글자대로 넣었다. M90 에는 (a′) 블록이 없다.
  - "줄 단위 reader 와 그 메시지는 한 글자도 바꾸지 않았다" 는 diff 와 맞는다. `git diff 299718f` 에서 지운 줄은 문서 주석 셋뿐이다.
- skill 세 줄 — 맞다. `package:yaml` 은 `tool/verify.dart` 의 (h) 도우미(`keysSeenByYaml` · `yamlRuleNames` · `yamlLanguageOptions` · `yamlPluginConstraint` · `compareLineReadersWithYaml`)에서만 쓰인다. 그 바로 위 줄이 어긋나는 것은 범위 밖 절에 적었다.
- `pubspec.yaml` 17 · 18행의 새 주석 — 맞다. 그 위 13 · 15행의 옛 주석은 가리키는 파일이 틀리다 → **IN-13**.
- `README.md:378` · `:379` · `example/README.md:116` — 거짓 문장은 없다. 116행의 단계 설명은 (h) 를 적지 않는다. 소유자 결정 G4-Q1 (4) 의 "고친 뒤 참이면 그대로" 범위다.

**지난 발견 27건 가운데 지금도 해당하는 것은 아홉 건이다** (아래 표).

- WR-06 — `deferred` 그대로다.
- WR-07 · WR-08 · WR-09 · WR-12 · WR-13 · WR-14 · IN-08 · IN-10 — 같은 입력이 지금도 같은 결과를 낸다. 소유자 결정대로 코드는 그대로이고, 문장은 그 동작을 맞게 적는다.
  - IN-10 의 문장 쪽은 `0f62057` 으로 닫혔다. 남은 것은 동작뿐이다.
- WR-15 · WR-16 · IN-11 은 이번에 닫혔다. 나머지 15건도 해당하지 않는다.

**새 발견은 셋이다.** IN-12 · IN-13 · IN-14 모두 Info 다.

**재현 방법.** 모두 `mktemp -d` 로 만든 임시 폴더 하나 안에서만 했다.

- 복제본: `git clone --local --quiet` 로 만들고 `fvm dart pub get --no-example` 을 돌렸다.
  - 전체 실행용 하나, 함수 단위용 하나, 254 재현용 하나, 새 복제본 실행용 하나다.
- 함수 단위: 임시 폴더의 Dart 파일 하나가 `tool/verify.dart` 를 import 해 `checkShippedComposition` 을 불렀다. 부르는 법은 `fvm dart run --packages=<복제본의 .dart_tool/package_config.json> <하네스> <복제본>` 이다.
- 변형: 매번 `git diff --numstat` 으로 의도한 줄 수를 확인했고, 실행 뒤 `git checkout -- .` 으로 되돌렸다.
- 정리: 끝에 임시 폴더를 지웠다. 작업 트리의 `git status --porcelain` 은 시작과 같다 (GSD 도구 상태 넷).

## 지난 리뷰의 발견 27건 — 지금 상태

| ID | 제목 | 처리 기록 | 지금 해당하는가 | 근거 |
|----|------|-----------|-----------------|------|
| WR-01 | README 검사 (e) 가 모양이 틀린 프리셋 주소를 조용히 건너뛴다 — 오타 주소로 통과 | fixed | 아니오 | 함수 단위로 README 68행을 `  - package:woody_lints/presets/riverpod.yaml` 로 → `passed=false`, `` `<이름>.yaml` 꼴이 아닌 것이 있다 (1) `` |
| WR-02 | README 검사 (f) · (g) 가 따옴표 · 줄 끝 주석 · 두 자리 버전 값을 조용히 건너뛴다 — 낡은 값으로 통과 | fixed | 아니오 | 18행을 `      ref: 'v1.9.0'` 으로 → `passed=false` (`ref: v1.9.0` 이 다르다) |
| WR-03 | `fencedLines` 가 ``` 펜스만 안다 — `~~~` 코드 블록의 값은 (f) · (g) 가 보지 않는다 | fixed | 아니오 | 328 · 334행 펜스를 `~~~` 로, 333행을 `v1.9.0` 으로 → `passed=false` |
| WR-04 | (b′) 가 flow 표기 `linter: {rules: [...]}` 로 다른 조각에 적은 규칙을 보지 못한다 — 사용 프로젝트는 받는데 검증은 10개 중 10개 | fixed | 아니오 | `lib/codegen.yaml` 끝에 `linter: {rules: [prefer_mixin]}` → `FormatException: lib/codegen.yaml 의 10행: `linter:` 줄에 값이 붙어 있다 …` |
| WR-05 | `readShippedPluginConstraint` 가 YAML 토큰을 그대로 돌려주고 올바른 꼴 셋을 거부한다 — 70 이나 통과할 수 없는 `[3/N]` · `[4/N]` | fixed | 아니오 | `"^3.1.9"` → `passed=true` ((h) 블록도 없다). `">=3.1.9 <4.0.0"` → `… 꼴만 받는다 (범위 제약은 받지 않는다, …)` 의 `FormatException` |
| WR-06 | `.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다 | deferred | 예 | 마지막 커밋은 여전히 `403c584`. 69 · 70 · 73 · 173 · 182 · 183 · 313행이 그대로이고, 261행도 이제 어긋난다 (아래 WR-06) |
| WR-07 | README 검사 (e) 가 `package:` 로 정확히 시작하지 않는 include 주소를 보지 않는다 — scheme 오타로 10개 중 10개 | skipped | 예 | 68행 `  - packages:woody_lints/riverpod.yaml` → `passed=true`. 문장(`example/README.md:116`, `tool/verify.dart:2144`)은 맞게 적는다 |
| WR-08 | README 검사 (f) · (g) 가 flow 표기에 적힌 plugin 버전 · `ref:` 를 보지 않는다 — 낡은 값으로 10개 중 10개 | skipped | 예 | 196 ~ 199행 블록을 `plugins: {riverpod_lint: ^3.1.3}` 로 → `passed=true`. 문장은 맞게 적는다 |
| WR-09 | `fencedLines` 가 펜스가 아닌 코드 블록을 보지 않는다 — 들여쓴 코드 블록의 낡은 `ref:` 로 10개 중 10개 | skipped | 예 | 328 ~ 334행을 펜스 없이 네 칸 들여 쓴 블록으로, `ref: v1.9.0` → `passed=true`. 문장은 맞게 적는다 |
| WR-10 | `[3/10]` 이 조각의 `linter:` 밖 키를 보지 않는다 — `lib/codegen.yaml` 의 `language:` 옵션 · `formatter:` 가 사용 프로젝트에 닿는데 10개 중 10개 | fixed | 아니오 | `lib/codegen.yaml` 끝에 `  language:` / `    strict-casts: true` → `passed=false` · `10행:   language:`. `formatter:` / `  page_width: 100` → `passed=false` · `10행: formatter:` |
| WR-11 | (a′) · `declaredRuleNames` 가 `\n` 으로만 줄을 나눈다 — 주석 줄 끝의 CR(`\r`) 뒤에 둔 키 · 규칙이 사용 프로젝트에 닿는데 10개 중 10개 | fixed | 아니오 | M79 (93행 끝에 CR + `    - prefer_mixin`) → `passed=false`, `+ prefer_mixin  (base.yaml 에만)`. CRLF · CR 하나 · 마지막 줄바꿈 없음은 거짓 실패 없음 (Summary) |
| WR-12 | (d′) 의 절 경계가 HTML 주석 안의 `#` 줄 · 4칸 들여 쓴 ```` ``` ```` 를 제목 · 펜스로 본다 — 렌더링된 「받는 규칙」 목록 바로 아래의 불릿으로 10개 중 10개 | skipped | 예 (동작) | 지난 세 입력 → 셋 다 `passed=true`. 대조(마커 바로 뒤 불릿)는 `passed=false` · `189행`. 정의 문장은 `example/README.md:116` · `:549` 그대로 |
| WR-13 | README 검사 (f) · (g) 가 따옴표로 감싼 키 · 콜론 앞 공백(`"ref":` · `'riverpod_lint':` · `ref :`)을 후보로 보지 않는다 — 낡은 값으로 10개 중 10개, 좁힌 문장은 "모두 후보로" | skipped | 예 (동작) | 18행 `"ref": v1.9.0` · `ref : v1.9.0`, 198행 `'riverpod_lint': ^3.1.3`, 234행 `"version": ^3.1.3` → 넷 다 `passed=true`. 문장 쪽은 닫혀 있다 |
| WR-14 | (e) 의 다른 패키지 주소 검사는 `.yaml` · `.yml` 로 끝나는 주소만 보는데, 좁힌 문장과 문서 주석은 "`package:` 로 정확히 시작하는 주소가 꼴이 아니면 실패" 라고 적는다 — `package:woody-lints/riverpod` 로 10개 중 10개 | skipped | 예 (동작) | 68행 `package:woody-lints/riverpod` · `package:woody_lint/riverpod.yam` → 둘 다 `passed=true`. 대조 `package:woody-lints/riverpod.yaml` → `passed=false`. 문장 쪽은 닫혀 있다 |
| WR-15 | `pubspecReleaseVersion` 이 여러 줄 따옴표 스칼라 안의 `version:` 줄을 읽는다 — pub 은 진짜 `version:` 을 읽는데 README 의 낡은 `ref:` 로 10개 중 10개 | fixed | 아니오 — `77e0b88` | 같은 입력(M87) → `passed=false`, (h) 블록 `줄 단위 reader: 1.9.0` · `YAML: 2.0.0-dev`. reader 는 여전히 `1.9.0` 을 읽지만 (h) 가 실패시킨다 |
| WR-16 | `declaredRuleNames` · `enabledLanguageOptions` 가 여러 줄 스칼라(따옴표 · 블록) 안의 줄을 규칙 · 옵션으로 읽는다 — 사용 프로젝트에 닿지 않는 규칙 · 옵션을 `RULES.md` · README 가 켰다고 적는데 10개 중 10개 | fixed | 아니오 — `77e0b88` | 지난 리뷰의 네 입력(규칙 둘 · 옵션 따옴표 · 블록 스칼라, `RULES.md` · README 도 맞춤) → 넷 다 `passed=false`, (h) 블록만 |
| IN-01 | `pubspecReleaseVersion` 이 따옴표로 감싼 `version:` 에서 종료 코드 70 | fixed | 아니오 | `version: "2.0.0-dev"` → `passed=true` ((h) 블록도 없다) |
| IN-02 | CHANGELOG 2.0.0 의 "내용은 1.3.0 과 같다" 가 같은 절의 다른 항목과 어긋난다 | fixed | 아니오 | `git diff --stat ddfb852 HEAD -- CHANGELOG.md lib RULES.md` 가 빈 출력 |
| IN-03 | README 「프리셋 고르기」 의 "그 연습용 프로젝트의 정답지로 확인" 이 묶음에는 맞지 않는다 | fixed | 아니오 | `README.md:45` 의 "묶음(`recommended`)에는 자기 정답지가 없다" 그대로 |
| IN-04 | plugin 하한을 올릴 때 함께 고칠 자리가 두 문서에 반씩 적혀 있다 | fixed | 아니오 | `README.md:382` 가 네 자리를 한 곳에 적는다 |
| IN-05 | `tool/verify.dart` 문서 주석의 단계 번호가 `[2/4]` · `[1/4]` 로 남아 있다 | fixed | 아니오 | `grep -c '\[2/4\]\|\[1/4\]' tool/verify.dart` → 0 |
| IN-06 | `readBulletBlock` 이 `readRulesMdBlock` 의 마커 처리를 복제하고, 결과 타입 이름이 README 에 맞지 않는다 | fixed | 아니오 | `tool/verify.dart:1693` `readMarkerBlock` 이 `:1708` `findMarkerRange` 를 부른다 |
| IN-07 | README 「받는 규칙」 의 분류는 검사되지 않는다 | fixed | 아니오 | `README.md:91` 의 "검증 명령은 이름만 견주고 분류는 보지 않는다" 그대로 |
| IN-08 | (e) 의 주소 끝 판정이 문장 부호를 모른다 — 맞는 주소의 거짓 실패와 다른 패키지 주소의 누락이 한 줄에서 함께 난다 | skipped | 예 (동작) | 85행 끝에 ` 예: package:woody_lints/recommended.yaml, package:woody-lints/base.yaml.` → `passed=false`. 블록은 `package:woody_lints/recommended.yaml,` 하나, 다른 패키지 블록 0개 |
| IN-09 | (a′) 가 들어온 뒤 M35 · M37 의 `[3/10]` 출력이 바뀌었는데, 05-10 소절은 M46 만 짚는다 | fixed | 아니오 | `example/README.md:518` 그대로 |
| IN-10 | (f) · (g) 의 범위 문장이 펜스 안의 네 칸 들여 쓴 ```` ``` ```` 줄을 적지 않는다 — 그 줄이 `fencedLines` 의 펜스를 닫아 진짜 펜스 안의 낡은 `ref:` 로 통과 | skipped | 예 (동작) | 330행 뒤 `    ```` + 333행 `v1.9.0` → `passed=true`. 대조(333행만) → `passed=false`. 문장 쪽은 `0f62057` 으로 닫혔다 (`README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:1512` · `:2144`) |
| IN-11 | `stripPlugins` 문서 주석의 "복사본의 줄 수 … 가 원본과 같다" 가 `plugins:` 섹션이 파일 끝일 때 맞지 않는다 | fixed | 아니오 — `0f62057` | `tool/verify.dart:841` 이 "복사본의 줄 번호가 원본과 같다 (끝의 빈 줄은 빠질 수 있다 …)" |

## 소유자가 이번 범위 밖으로 둔 것

ID 를 주지 않는다. 이번에 확인한 그대로 적는다 (05-14-PLAN `<owner_decisions>` 의 NOT approved).

- **길 A 의 꼴 막기 · reader 를 `loadYaml` 로 바꾸기.** 하지 않았다.
  - `git diff 299718f HEAD -- tool/verify.dart` 에서 지운 줄은 문서 주석 셋뿐이다 (머리 주석의 `[3/N]` 줄, `stripPlugins` 주석, `checkShippedComposition` 의 범위 밖 문단).
  - reader 다섯의 본문은 그대로다.
- **`yaml` 을 `dependencies` 에 두기.** 아니다. `pubspec.yaml:20-22` 의 `dev_dependencies` 다.
  - 기준 실행 뒤와 새 복제본 실행 뒤의 `git status --porcelain` 이 빈 출력이다. `example/` · `fixtures/` 의 커밋된 lock 그대로다.
- **gap 1 의 override (길 C).** 없다.
- **(d′) · (e) · (f) · (g) · `fencedLines` · `markFencedLines` · `unquotedScalar` · `findMarkerRange` · `findListLinesOutsideMarkers` 의 코드, `stripPlugins` 의 코드.** 바뀌지 않았다.
  - WR-07 · WR-08 · WR-09 · WR-12 · WR-13 · WR-14 · IN-08 · IN-10 의 동작이 그대로 남은 까닭이다 (위 표).
  - IN-10 과 IN-11 은 문장 · 주석만 고쳤다.
- **`tool/measure_rules.dart` · CHANGELOG · `lib/` · `RULES.md` · `fixtures/` · `.claude/CLAUDE.md`.** `git diff --stat 299718f HEAD` 가 빈 출력이다. `.claude/CLAUDE.md` 261행은 WR-06 에 적었다.
- **`stripPlugins` · `readRuleNameAt` · `significantLines` · `readUpstreamRules` 를 대조에 넣기.** 넣지 않았다. 그래서 글자로만 견주는 자리가 남는다. `significantLines` 쪽을 확인했다.
  - **입력:** `lib/recommended.yaml` 6행(`  - package:woody_lints/riverpod.yaml`)을 네 칸 들여 썼다. 주석 · 빈 줄을 뺀 `trim()` 줄은 그대로다.
  - **YAML 이 읽는 값:** `{include: [package:woody_lints/base.yaml - package:woody_lints/riverpod.yaml, package:woody_lints/codegen.yaml]}`. 들여 쓴 줄이 앞 항목의 plain scalar 에 접힌다.
  - **함수 단위:** (a) 를 통과했다 (`passed=true`).
  - **전체 실행:** 종료 코드 1 이었다. `[5/10]` example 이 정답지와 달랐고(나오지 않은 줄 93), `[10/10]` overrides 도 실패했다. `[1/10]` ~ `[4/10]` 은 통과했다.
  - **결론:** 묶음이 깨져도 정답지 단계가 잡는다. `[4/10]` 의 연습용 프로젝트 옵션 비교도 같은 `trim()` 비교다.
- **`05-VALIDATION.md` 의 Test Infrastructure 문장.** 그대로다 — "`[3/10]` 에 (b′) · (d) ~ (g) 가 더해진다" 로 (h) 를 적지 않는다.
- **skill 의 다른 줄.** "스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다" 꼴의 spike 실측 스크립트 문장은 skill 전체에 15곳 그대로다 (`grep -rn -F`).
  - 고친 줄 바로 위의 줄 둘도 이제 저장소와 어긋난다 — `SKILL.md:49` · `references/rule-status-check.md:13`.
  - 그 줄은 "`lib/`, `pubspec.yaml` 은 바꾸지 않는다. 루트 `analysis_options.yaml` 은 기존 exclude 항목(`lib/analysis_options.yaml`)을 그대로 둔다" 이다.
  - 지금 `pubspec.yaml` 에는 `dev_dependencies` 가 있다. 루트 `analysis_options.yaml` 은 `example/**` · `fixtures/**` 만 뺀다.
  - `SKILL.md:49` 는 괄호로 spike 의 일이라고 밝힌다. `rule-status-check.md:13` 은 밝히지 않는다.
  - Round 2 · Round 3 의 "skill 의 다른 줄" 이라 ID 를 주지 않는다.

## Narrative Findings (AI reviewer)

## Warnings

### WR-06: `.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다

**File:** `.claude/CLAUDE.md:69-73`, `.claude/CLAUDE.md:173`, `.claude/CLAUDE.md:182-183`, `.claude/CLAUDE.md:261`, `.claude/CLAUDE.md:313`
**Issue:** 지난 리뷰와 같다. 처리 기록은 deferred (D-09) 다. `git log -- .claude/CLAUDE.md` 의 마지막 커밋은 여전히 `403c584` 다.

| 줄 | 남아 있는 지시 | 지금 저장소 |
|---|---|---|
| 69 | `riverpod_lint: ^3.1.3` | `lib/riverpod.yaml` 은 `^3.1.9` |
| 70 | 루트 `analyzer.exclude` 에 `lib/analysis_options.yaml` 을 넣는다 | 루트 `analysis_options.yaml` 은 `example/**` · `fixtures/**` 만 뺀다 |
| 73 | 버전 `1.3.0` | `pubspec.yaml` 은 `2.0.0-dev` |
| 173 · 313 | 루트 exclude 가 "반드시 유지되어야 한다" | 위와 같다 |
| 182 · 183 | 예시로 `lib/analysis_options.yaml` 49-56행 · 55-56행을 든다 | 그 파일은 지금 4줄이다 |
| 261 | 매니페스트가 담는 것: `name`, `version`, `environment.sdk`, `dependencies` | 이번 회차부터 `dev_dependencies` (`yaml`) 도 담는다 |

261행은 05-14-PLAN 의 Round 2 가 WR-06 · D-09 로 미룬 줄이다. 이번 재리뷰도 이 지시를 컨텍스트로 받았다.

**재현:** 해당 없음(읽어서 대조한 것).

**Fix:** D-09 대로 마일스톤 끝 `/gsd-map-codebase` 에서 69 · 70 · 73 · 173 · 182 · 183 · 261 · 313행을 지금 구조로 고친다.

### WR-07: README 검사 (e) 가 `package:` 로 정확히 시작하지 않는 include 주소를 보지 않는다 — scheme 오타로 10개 중 10개

**File:** `tool/verify.dart:2353-2356`, `tool/verify.dart:2374-2383`
**Issue:** 지난 리뷰와 같은 입력이 지금도 통과한다. 소유자 결정 G2-Q2 로 `skipped` 이고 코드는 그대로다. 문장은 이 입력을 범위 밖으로 맞게 적는다 — `example/README.md:116` 의 "`packages:` 같은 scheme 오타 · `package:` 뒤의 공백은 보지 않고", `tool/verify.dart:2144` 의 "(e) 는 `package:` 로 시작하지 않는 scheme 오타 · … 를 보지 않고".

**재현(함수 단위):** README 68행을 `  - packages:woody_lints/riverpod.yaml` 로 바꿨다. 결과는 `passed=true` 였다.

**Fix:** 소유자 결정대로 둔다.

### WR-08: README 검사 (f) · (g) 가 flow 표기에 적힌 plugin 버전 · `ref:` 를 보지 않는다 — 낡은 값으로 10개 중 10개

**File:** `tool/verify.dart:2416-2418`, `tool/verify.dart:2462`
**Issue:** 지난 리뷰와 같은 입력이 지금도 통과한다. G2-Q2 로 `skipped` 이고 코드는 그대로다. 문장(`README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:2144` · `:2413` · `:2459`)은 flow 표기를 범위 밖으로 맞게 적는다.

**재현(함수 단위):** 196 ~ 199행 블록을 `plugins: {riverpod_lint: ^3.1.3}` 한 줄로 바꿨다(234행은 `^3.1.9` 그대로). 결과는 `passed=true` 였다.

**Fix:** 소유자 결정대로 둔다.

### WR-09: `fencedLines` 가 펜스가 아닌 코드 블록을 보지 않는다 — 들여쓴 코드 블록의 낡은 `ref:` 로 10개 중 10개

**File:** `tool/verify.dart:1513-1539`
**Issue:** 지난 리뷰와 같은 입력이 지금도 통과한다. G2-Q2 로 `skipped` 이고 코드는 그대로다. 문장(`README.md:382`, `example/README.md:116` · `:395`, `tool/verify.dart:1511` · `:2406`)은 맞게 적는다.

**재현(함수 단위):** 328 ~ 334행 블록의 펜스 두 줄을 빼고 나머지를 네 칸 들여 썼다. 값은 `ref: v1.9.0` 으로 바꿨다(`git diff --numstat` `5/7`). 결과는 `passed=true` 였다.

**Fix:** 소유자 결정대로 둔다.

### WR-12: (d′) 의 절 경계가 HTML 주석 안의 `#` 줄 · 4칸 들여 쓴 ```` ``` ```` 를 제목 · 펜스로 본다 — 렌더링된 「받는 규칙」 목록 바로 아래의 불릿으로 10개 중 10개

**File:** `tool/verify.dart:1549-1574`, `tool/verify.dart:1826-1857`
**Issue:** 동작은 지난 리뷰와 같다. 소유자 결정 G3-Q3 은 "정의를 문장에 적고 검사는 고치지 않는다" 였고, 정의는 `example/README.md:116` · `:549` 에 그대로 있다. 렌더링된 절 안의 목록 줄이 검사 밖이 되는 동작이 남아 있다.

**재현(함수 단위):** 셋 모두 `passed=true` 였다.
- 188행 뒤에 `<!--` / `# 메모` / `-->` / `` - `bogus_after_comment` `` 을 끼웠다.
- 91행 뒤에 `` - `bogus_before` `` / `<!--` / `# 메모` / `-->` 를 끼웠다.
- 188행 뒤에 빈 줄 / `    ```` / `` - `bogus_after_indented` `` / `    ```` 를 끼웠다.

**대조:** 188행 뒤에 `` - `bogus_after_marker` `` 한 줄만 끼웠다. `passed=false`, `189행: - `bogus_after_marker`` 였다.

**Fix:** 소유자 결정대로 둔다.

### WR-13: README 검사 (f) · (g) 가 따옴표로 감싼 키 · 콜론 앞 공백(`"ref":` · `'riverpod_lint':` · `ref :`)을 후보로 보지 않는다 — 낡은 값으로 10개 중 10개, 좁힌 문장은 "모두 후보로"

**File:** `tool/verify.dart:2416-2418`, `tool/verify.dart:2462`
**Issue:** 동작은 지난 리뷰와 같다. 제목 끝의 문장 쪽은 닫혀 있다 (G3-Q2). 키 글자 구절이 든 자리는 다음과 같고, 동작과 맞는다.

- `README.md:382`
- `example/README.md:116` · `:395`
- `tool/verify.dart:2139` · `:2141` · `:2144` (문서 주석), `:2414` · `:2460` (함수 안 주석)

남은 것은 YAML 로는 같은 키인 줄의 값을 견주지 않는 동작이다. (h) 는 README 를 보지 않으므로 이 동작에 닿지 않는다.

**재현(함수 단위):** 각각 따로 돌렸고 넷 모두 `passed=true` 였다.
- 18행 `      "ref": v1.9.0`
- 18행 `      ref : v1.9.0`
- 198행 `  'riverpod_lint': ^3.1.3`
- 234행 `    "version": ^3.1.3`

**Fix:** 소유자 결정대로 둔다.

### WR-14: (e) 의 다른 패키지 주소 검사는 `.yaml` · `.yml` 로 끝나는 주소만 보는데, 좁힌 문장과 문서 주석은 "`package:` 로 정확히 시작하는 주소가 꼴이 아니면 실패" 라고 적는다 — `package:woody-lints/riverpod` 로 10개 중 10개

**File:** `tool/verify.dart:2374-2383`
**Issue:** 동작은 지난 리뷰와 같다. 제목의 문장 쪽 어긋남은 닫혀 있다 (G3-Q2). `example/README.md:116` 과 `tool/verify.dart:2137` · `:2144` 가 같은 범위를 적는다. 남은 것은 그 주소를 보지 않는 동작이다.

**재현(함수 단위):** 68행을 `  - package:woody-lints/riverpod` 로, 또 `  - package:woody_lint/riverpod.yam` 로 바꿨다. 둘 다 `passed=true` 였다.

**대조:** 68행 `  - package:woody-lints/riverpod.yaml` → `passed=false`, `` `README.md` 에 `woody_lints` 가 아닌 패키지의 `.yaml` 주소가 있다 (1) ``.

**Fix:** 소유자 결정대로 둔다.

## Info

### IN-08: (e) 의 주소 끝 판정이 문장 부호를 모른다 — 맞는 주소의 거짓 실패와 다른 패키지 주소의 누락이 한 줄에서 함께 난다

**File:** `tool/verify.dart:2353-2356`, `tool/verify.dart:2374-2383`
**Issue:** 동작은 지난 리뷰와 같다 (G2-Q2 `skipped`). `tool/verify.dart:2144` · `:2373` 의 주석이 이 동작을 맞게 적는다.

**재현(함수 단위):** README 85행 끝에 ` 예: package:woody_lints/recommended.yaml, package:woody-lints/base.yaml.` 를 덧붙였다. 결과는 `passed=false` 였다.
- 블록은 `` `<이름>.yaml` 꼴이 아닌 것이 있다 (1): `` · `package:woody_lints/recommended.yaml,` 하나였다.
- "아닌 패키지" 블록은 0개였다.

**Fix:** 소유자 결정대로 둔다.

### IN-10: (f) · (g) 의 범위 문장이 펜스 안의 네 칸 들여 쓴 ```` ``` ```` 줄을 적지 않는다 — 그 줄이 `fencedLines` 의 펜스를 닫아 진짜 펜스 안의 낡은 `ref:` 로 통과

**File:** `tool/verify.dart:1528-1535`
**Issue:** 문장 쪽은 `0f62057` 으로 닫혔다 (소유자 결정 G4-Q2). 다음 다섯 자리가 이 꼴을 범위 밖으로 적는다.

- `README.md:382`
- `example/README.md:116` · `:395`
- `tool/verify.dart:1512` (`fencedLines` 문서 주석) · `:2144` (`checkShippedComposition` 문서 주석)

남은 것은 동작이다. 닫는 펜스의 들여쓰기를 보지 않으므로 네 칸 들여 쓴 펜스 문자 줄이 진짜 펜스를 닫는다. 그 뒤의 같은 블록 값은 견주지 않는다.

**재현(함수 단위):** README 330행(`  woody_lints:`) 뒤에 `    ```` 한 줄을 끼우고, 333행(이제 334행)을 `      ref: v1.9.0` 으로 바꿨다(`git diff --numstat` `2/1`). 결과는 `passed=true` 였다.

**대조:** 333행만 `v1.9.0` 으로 바꿨다. `passed=false`, `ref: v1.9.0` 블록이 나왔다.

**Fix:** 소유자 결정대로 둔다.

### IN-12: (h) 가 값 없는 최상위 키 바로 아래의 스칼라 값 줄을 "아래 키" 로 센다 — `include:` 값을 다음 줄에 적은 `lib/base.yaml` 로 analyzer · 정답지는 모두 통과인데 `[3/10]` 만 실패

**File:** `tool/verify.dart:1878-1912` (`keysSeenByLineReader`, 아래 줄을 모으는 자리 `:1896-1910`), `tool/verify.dart:2058-2067` (아래 키 비교)
**Issue:** `lib/base.yaml` 에는 `allowedChildKeys` 가 없다. 그래서 지금 검사 (a′) 는 `lib/base.yaml` 의 최상위 키 아래 줄을 읽지 않는다.

`keysSeenByLineReader` 는 다르게 읽는다.

- 값 없는 최상위 키마다 받는 아래 키를 빈 집합으로 두고 `findUnexpectedKeys` 를 다시 부른다.
- 그 바로 아래 들여쓰기의 줄을 모두 "아래 키" 로 담는다. 목록 항목(`- …`)만 뺀다.
- 키 꼴이 아닌 줄은 원문 그대로 담는다 (`:1906-1908`).

YAML 은 같은 줄을 다르게 읽는다. 값 없는 키 다음 줄의 스칼라는 그 키의 값이다. 그래서 YAML 쪽은 아래 키가 없다.

- `include:` / `  package:flutter_lints/flutter.yaml` 은 YAML · analyzer 에게 `include: package:flutter_lints/flutter.yaml` 과 같다.
- (h) 는 `` `lib/base.yaml` 의 `include:` 바로 아래 키 … (findUnexpectedKeys ↔ include 맵) `` 블록으로 `[3/10]` 을 실패시킨다.

이 블록은 세 가지로 맞지 않는다.

- "지금 검사가 읽은 값" 을 넘는다. 이 줄을 키로 읽는 검사는 지금 없다.
- 블록 머리의 "include 맵" 은 YAML 에 없는 맵이다.
- 안내 줄(`yamlAgreementHint` — 여러 줄 문자열 · 같은 키 두 번 · 철자가 다른 키)이 이 입력에는 하나도 맞지 않는다.

`lib/codegen.yaml` · `lib/riverpod.yaml` 에서는 같은 꼴을 (a′) 가 이미 실패시킨다. (h) 만의 거짓 실패는 `lib/base.yaml` 쪽이다.

입력 가능성은 낮다 — 한 줄 값을 다음 줄로 내려 쓸 까닭이 드물다. 실패 쪽(막힌다)이라 Info 로 둔다.

- **재현(전체 실행, 복제본):**
  - `lib/base.yaml` 5행을 `include:` / `  package:flutter_lints/flutter.yaml` 두 줄로 바꿨다(`git diff --numstat` `2/1`).
  - 결과는 종료 코드 1 이었다. `[3/10]` 만 실패했고 `[2/10]` · `[5/10]` ~ `[10/10]` 은 통과했다. 요약은 `점검 실패 (10개 중 1개)` 였다.
  - 블록은 `줄 단위 reader 에만: package:flutter_lints/flutter.yaml` · `YAML 에만: (없음)` 이었다.
- **함수 단위:** 값을 따옴표로 감싼 `  "package:flutter_lints/flutter.yaml"` 도 같은 블록을 냈다.
- **대조(함수 단위):** 둘 다 `passed=true` 였다.
  - 목록 꼴 `include:` / `  - package:flutter_lints/flutter.yaml`
  - 접힌 블록 스칼라 `include: >-` / `  package:flutter_lints/flutter.yaml`

**Fix:** 아래 줄 가운데 키처럼 보이는 줄만 담는다. 키처럼 보이는 줄은 `이름:`, 따옴표 키, 콜론 앞 공백 키다. 키 꼴이 아닌 스칼라 값 줄은 담지 않는다.

```dart
// 아래 줄 가운데 키처럼 보이는 줄 — `이름:` · `"이름":` · `'이름':` · `이름 :`.
// `package:…` 처럼 콜론 뒤에 공백 · 줄 끝이 없는 스칼라 값 줄은 키가 아니다 (05-REVIEW.md IN-12).
final keyLikePattern = RegExp(
  r'''^(?:"[^"]*"|'[^']*'|[^\s#'"][^#]*?)[ \t]*:(?:[ \t]|$)''',
);
// …
if (listItemPattern.hasMatch(text) || !keyLikePattern.hasMatch(text)) continue;
```

M86 ~ M91 이 숨긴 줄은 모두 키 꼴이다 (`rules:` · `language:` · `exclude:` · `riverpod_lint:` · `custom_lint:`). M78 의 `"zz_quoted_plugin": ^0.1.0` 도 따옴표 키 꼴이다. 그러므로 고친 뒤에도 그 블록은 그대로다.

### IN-13: `pubspec.yaml` 의 `dependencies` 주석이 `include: package:flutter_lints/flutter.yaml` 을 쓰는 파일을 `lib/analysis_options.yaml` 로 적는다 — 지금은 `lib/base.yaml`

**File:** `pubspec.yaml:13-15`
**Issue:** 13행은 "`lib/analysis_options.yaml` 이 `include: package:flutter_lints/flutter.yaml` 을 쓰므로 … dependencies 에 둔다" 이다. 지금 두 파일은 이렇다.

- `lib/analysis_options.yaml` 은 `include: package:woody_lints/recommended.yaml` 한 줄인 별칭이다.
- 기반 세트를 include 하는 것은 `lib/base.yaml:5` 다.

이유("include 대상이므로 dependencies")는 그대로 참이고, 가리키는 파일만 틀리다. 이번 회차가 바로 아래(17 · 18행)에 같은 꼴의 "왜" 주석을 더했다. 두 주석이 나란히 있어, 옛 주석의 파일 이름이 새 주석과 같은 무게로 읽힌다.

프로젝트 규칙은 이렇다 — "설정의 이유(why)를 적는다". 이 주석은 `.claude/CLAUDE.md` 182행(WR-06)이 예시로 드는 줄이기도 하다.

**재현:** 해당 없음(읽어서 대조한 것 — `sed -n 1,5p lib/base.yaml`, `cat lib/analysis_options.yaml`).

**Fix:**

```yaml
# lib/base.yaml 이 `include: package:flutter_lints/flutter.yaml` 을
# 쓰므로 사용하는 프로젝트에 전달되는 dependencies 에 둔다
# (dev_dependencies 는 사용하는 쪽 의존성 그래프에 포함되지 않는다).
```

### IN-14: `compareLineReadersWithYaml` 문서 주석의 "그 밖의 예외는 지금처럼 main 이 받는다" 가 맞지 않는다 — `loadYaml` 의 `RangeError` 는 main 을 지나 종료 코드 255

**File:** `tool/verify.dart:1985-1986`, `tool/verify.dart:2025-2040`, `tool/verify.dart:2915-2926`
**Issue:** `load` 는 `YamlException` 만 잡는다 (`:2030`). 문서 주석은 "그 밖의 예외는 지금처럼 main 이 받는다" 고 적는다. 그런데 main 이 받는 것은 셋뿐이다 (`:2915-2926`) — `FormatException` · `FileSystemException` · `ProcessException`.

package:yaml 3.1.4 는 일부 입력에서 `YamlException` 이 아닌 `Error` 를 던진다.

- 한 글자 값에 `!!float` 태그를 단 경우 (`x: !!float i`) → `RangeError (length): Invalid value: Only valid value is 0: 1`. 같은 태그라도 값이 여러 글자면 `Invalid float scalar.` 의 `YamlException` 이다.
- 아주 깊은 flow 중첩 → `StackOverflowError` (임시 폴더의 작은 Dart 파일로 `loadYaml` 을 직접 불러 확인했다).

이 오류는 main 을 지나 처리되지 않은 예외(종료 코드 255)가 된다. 문서가 말하는 70 도, (h) 블록도 아니다.

전체 실행에서는 이 길에 닿지 않았다. 그래서 문서 주석과 동작이 어긋난 것으로 Info 에 둔다.

- `lib/codegen.yaml` 6행을 `    invalid_annotation_target: !!float i` 로 바꿔 전체 실행을 돌렸다.
- `[2/10]` 의 `dart analyze build/woody_rule_check` 가 400초가 넘도록 끝나지 않았다. CPU 시간은 5초 안팎이었다.
- 멈춘 것으로 보고 프로세스를 끝냈다. analyzer 쪽 동작이라 이번 범위 밖이다.
- `pubspec.yaml` 쪽이면 준비 3 의 `pub get` 이 먼저 해석한다.

- **재현(함수 단위):** 위 변경에서 `checkShippedComposition` 이 `RangeError` 를 던졌다. 하네스의 `catch` 가 `RangeError (length): Invalid value: Only valid value is 0: 1` 을 받았다. 여러 글자 값(`!!float ignore`)은 `` `lib/codegen.yaml` 을 YAML 로 읽지 못했다 — 6행: Invalid float scalar. `` 블록이었다.
- **대조:** main 과 같은 `on FormatException` · `on FileSystemException` 만 둔 작은 Dart 파일에서 같은 `loadYaml` 을 불렀다. 종료 코드는 255, stderr 첫 줄은 `Unhandled exception:` 이었다.

**Fix:** 둘 중 하나.

- 읽지 못한 것으로 같은 블록을 낸다:

```dart
    } on YamlException catch (e) {
      // … 지금 그대로
    } catch (e) {
      // package:yaml 이 YamlException 밖의 오류를 던지는 입력이 있다 — 한 글자 `!!float` 값의 RangeError (05-REVIEW.md IN-14).
      blocks.add([
        '`$path` 을 YAML 로 읽지 못했다 — 해석기 오류 (${e.runtimeType})',
        '',
        yamlAgreementHint,
      ]);
      return null;
    }
```

- 또는 문서 주석을 "그 밖의 예외(`RangeError` 같은 `Error` 포함)는 main 이 받지 않아 처리되지 않은 예외로 끝난다" 로 고친다.

---

_Reviewed: 2026-10-14T22:04:35Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
