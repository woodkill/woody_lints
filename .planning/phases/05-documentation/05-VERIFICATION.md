---
phase: 05-documentation
verified: 2026-10-14T07:42:21Z
status: gaps_found
score: 62/66 must-haves verified
covered_files:
  - ".claude/CLAUDE.md"
  - ".planning/phases/05-documentation/05-01-PLAN.md"
  - ".planning/phases/05-documentation/05-01-SUMMARY.md"
  - ".planning/phases/05-documentation/05-02-PLAN.md"
  - ".planning/phases/05-documentation/05-02-SUMMARY.md"
  - ".planning/phases/05-documentation/05-03-PLAN.md"
  - ".planning/phases/05-documentation/05-03-SUMMARY.md"
  - ".planning/phases/05-documentation/05-04-PLAN.md"
  - ".planning/phases/05-documentation/05-04-SUMMARY.md"
  - ".planning/phases/05-documentation/05-05-PLAN.md"
  - ".planning/phases/05-documentation/05-05-SUMMARY.md"
  - ".planning/phases/05-documentation/05-06-PLAN.md"
  - ".planning/phases/05-documentation/05-06-SUMMARY.md"
  - ".planning/phases/05-documentation/05-07-PLAN.md"
  - ".planning/phases/05-documentation/05-07-SUMMARY.md"
  - ".planning/phases/05-documentation/05-08-PLAN.md"
  - ".planning/phases/05-documentation/05-08-SUMMARY.md"
  - ".planning/phases/05-documentation/05-09-PLAN.md"
  - ".planning/phases/05-documentation/05-09-SUMMARY.md"
  - ".planning/phases/05-documentation/05-10-PLAN.md"
  - ".planning/phases/05-documentation/05-10-SUMMARY.md"
  - ".planning/phases/05-documentation/05-11-PLAN.md"
  - ".planning/phases/05-documentation/05-11-SUMMARY.md"
  - "CHANGELOG.md"
  - "README.md"
  - "RULES.md"
  - "example/README.md"
  - "fixtures/overrides/analysis_options.yaml"
  - "lib/analysis_options.yaml"
  - "lib/base.yaml"
  - "lib/codegen.yaml"
  - "lib/recommended.yaml"
  - "lib/riverpod.yaml"
  - "pubspec.yaml"
  - "tool/measure_rules.dart"
  - "tool/verify.dart"
covered_digest: "v3:sha256:746718cece72d61e4245e977efbc6de74d1014037230e3aefcf24e24add8fcc1"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 50/53
  gaps_closed:
    - "지난 gaps 1 의 입력 — `lib/codegen.yaml` 끝의 `linter :` 블록 목록 (M68 전체 실행 rc 1 · `[3/10]` 만 실패 · `점검 실패 (10개 중 1개)` · `10행: linter :`, 다른 조각의 규칙 블록 없음), `\"linter\":` (M69) · `lib/riverpod.yaml` 의 `linter :` (M70) 은 함수 단위 `passed=false`. 검증자가 더 넣은 철자 넷(`'linter':` · `? linter` · `&a linter:` · `!!str linter:`)도 모두 최상위 블록으로 실패"
  gaps_remaining: []
  regressions: []
  new_gaps:
    - "같은 모양의 다른 입력 — 줄을 `\\n` 으로만 나누는 reader 셋이 CR 하나(`\\r`) 뒤의 키 · 규칙을 주석 줄로 본다. YAML (package:yaml) 과 analyzer 는 CR 을 줄바꿈으로 읽는다 (05-REVIEW WR-11 재현)"
    - "05-10 이 좁힌 (e) · (f) · (g) 문장 가운데 둘이 아직 코드보다 넓다 (05-REVIEW WR-14 · WR-13 재현)"
gaps:
  - truth: "규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 — 조각마다 받는 키는 닫힌 목록이고 그 밖의 최상위 줄 · 그 바로 아래의 다른 키는 `[3/10]` 실패 (성공 기준 3 · VERIFY-06 · 05-01 truth 3 · 05-07 truth 7 · 05-10 truth 8 의 README 378 · 379행 부분)"
    status: failed
    reason: "`findUnexpectedKeys` (1027행) 는 CRLF 만 LF 로 바꾼 뒤 `\\n` 으로, `declaredRuleNames` (951행) · `enabledLanguageOptions` (1101행) 는 `\\n` 으로만 줄을 나눈다. package:yaml 3.1.4 의 `_isBreakAt` 은 CR 하나도 줄바꿈으로 본다(소스와 `loadYaml` 로 확인: `# c\\rformatter:\\r  x: 1` → `{formatter: {x: 1}, …}`, `    # s\\r    - hidden` → `rules: [a, hidden]`). 그래서 주석 줄 끝의 `\\r` 뒤에 둔 키 · 규칙은 reader 셋에게는 주석이고 analyzer 에게는 새 줄이다. 검증자 복제본 전체 실행: `lib/base.yaml` 93행(주석) 끝에 `\\r    - prefer_mixin` → 종료 코드 0 · `점검 통과 (10개 중 10개)` (RULES.md · README 어디에도 없는 규칙이 배포된다); 같은 자리 `\\r    - always_specify_types` → `[3/10]` 통과, 정답지 단계 다섯이 그 규칙의 새 진단으로 실패하고 `[2/10]` 이 `analysis_options.yaml:94  incompatible_lint` 를 낸다(analyzer 가 그 줄을 94행으로 센다 — 사용 프로젝트에 닿는다); `lib/codegen.yaml` 9행 끝에 `\\r  language:\\r    strict-casts: true` → `[3/10]` 통과, `[5/10]` · `[9/10]` · `[10/10]` 이 `invalid_assignment` 로 실패(옵션이 사용 프로젝트에 닿는다); 같은 자리 `\\r  language:\\r    strict-inference: true\\rformatter:\\r  trailing_commas: preserve` → 0 · 10/10. 함수 단위: `lib/codegen.yaml` 3행 끝 `\\rlinter:\\r  rules:\\r    - prefer_mixin`, `lib/base.yaml` 4행 끝 `\\rformatter:… \\rplugins:\\r  custom_lint: ^0.7.0`, `lib/riverpod.yaml` 의 `plugins:` 아래 `  # memo\\r  custom_lint: ^0.7.0` 모두 `passed=true`. 같은 파일의 `significantLines` 는 `readAsLinesSync()` (CR 도 나눔) 라 `lib/recommended.yaml` 의 같은 꼴은 `(a)` 가 잡는다(`passed=false`) — 한 파일 안에서 줄을 나누는 방식이 둘이다. 지난 두 gap 과 같은 모양(reader 가 analyzer 와 다르게 읽는 줄을 조용히 건너뜀)이고 개연성은 낮다(편집기 · 붙여넣기로 CR 하나가 들어오는 경우). 그러나 README 378행 '그 밖의 최상위 줄 … 은 `[3/10]` 단계가 실패' · 379행 '어긋나면 검증이 실패한다' 와 성공 기준 3 이 이 입력에서 거짓이다 — 지난 회차와 같은 기준을 적용했다."
    artifacts:
      - path: "tool/verify.dart"
        issue: "1027행 `options.replaceAll('\\r\\n', '\\n').split('\\n')`, 951행 · 1101행 `options.split('\\n')` — CR 하나를 줄바꿈으로 보지 않는다 (stripPlugins 832행 · readShippedPluginConstraint 1408행도 같은 꼴)"
      - path: "README.md"
        issue: "378 · 379행의 단정이 CR 입력에서 거짓"
      - path: "example/README.md"
        issue: "116행 '조각 셋의 최상위 키가 정해진 목록 안인지 (… 철자가 다른 키 · 열 0 에서 시작하지 않는 키도 실패' 가 CR 입력에서 거짓"
    missing:
      - "옵션 YAML 을 읽는 reader 가 YAML 과 같은 줄바꿈으로 나눈다 — `const LineSplitter().convert(text)` (`dart:convert`, 이미 import 됨; 같은 파일의 `significantLines` 가 쓰는 `readAsLinesSync` 와 같은 규칙). 최소 `findUnexpectedKeys` · `declaredRuleNames` · `enabledLanguageOptions`, 같은 꼴의 `stripPlugins` · `readShippedPluginConstraint` 도 함께 보기를 권한다. 줄 번호가 analyzer 의 `[2/10]` 진단과 같아진다"
      - "지워 보기 기록: 위 전체 실행 넷(base 숨은 규칙 · codegen 의 `language:` + `formatter:`)과 함수 단위 셋(codegen 숨은 `linter:`, base 숨은 `formatter:` · `plugins:`, riverpod 숨은 plugin)이 `[3/10]` 실패가 되는지 복제본에서 돌려 적는다; 기준 실행 10개 중 10개 유지"
      - "철자나 문자 하나를 더 받는 정규식 수정이 아니라 줄 나누기 자체를 YAML 과 맞춘다 (같은 모양이 세 번째다)"
  - truth: "README 382행 · `example/README.md` 116 · 358 · 395 · 436행 · `tool/verify.dart` 의 (e) · (f) · (g) 주석이 실제 검사 범위를 말한다 (05-10 truth 8, 소유자 결정 G2-Q2 '정확히 말하게' · G2-Q5)"
    status: partial
    reason: "WR-07 · WR-08 · WR-09 의 꼴(scheme 오타 · flow · 들여 쓴 블록 · 인용 안 펜스)은 좁힌 문장이 맞게 범위 밖으로 적는다. 그러나 둘이 아직 넓다. (1) WR-14 — `example/README.md` 116행 'README 에서 `package:` 로 정확히 시작하는 주소가 `woody_lints` 의 `<이름>.yaml` 꼴이 아니면 실패' 와 `tool/verify.dart` 1857 ~ 1858행 '꼴이 아닌 주소 · `woody_lints` 가 아닌 패키지의 주소도 실패': 다른 패키지 쪽은 `.yaml` · `.yml` 로 끝나는 주소만 본다(436행만 정확). 전체 실행: README 68행 `  - package:woody-lints/riverpod` → 0 · 10/10 (대조 `package:woody-lints/riverpod.yaml` → 함수 단위 `passed=false`). (2) WR-13 — README 382행 · `example/README.md` 116 · 395행은 범위 밖을 'flow 표기 · 네 칸 들여 쓴 블록 · 인용 안 펜스' 로만 적는데, 따옴표 키 · 콜론 앞 공백 줄도 후보가 아니다. 전체 실행: 18행 `      \"ref\": v1.9.0` + 198행 `  'riverpod_lint': ^3.1.3` → 0 · 10/10; 18행 `      ref : v1.9.0` → 0 · 10/10 (대조 `      ref: v1.9.0` → `passed=false`). 문장의 '`ref:` 줄' 을 글자 그대로 읽으면 맞다고 볼 여지가 있어 (2) 는 (1) 보다 약하다. 그 밖에 1864행 주석의 '문장 부호를 보지 않고' 는 다른 패키지 쪽에만 맞다(IN-08 의 남은 한 곳, 정보)."
    artifacts:
      - path: "example/README.md"
        issue: "116행 (e) 구절이 `.yaml` · `.yml` 로 끝나지 않는 다른 패키지 주소까지 실패한다고 적음; 116 · 395행 (f) · (g) 구절이 따옴표 키 · 콜론 앞 공백을 범위 밖으로 적지 않음"
      - path: "README.md"
        issue: "382행 (f) · (g) 구절 — 위와 같음"
      - path: "tool/verify.dart"
        issue: "1857 ~ 1858행 (e) 문서 주석, 1864행 문장 부호 구절"
    missing:
      - "소유자가 고른다 (G2-Q2 와 같은 길이면 문장만): 116행 · 1858행을 436행처럼 '`.yaml` · `.yml` 로 끝나는 다른 패키지의 주소' 로, 382 · 116 · 395행에 '키는 따옴표 · 콜론 앞 공백 없이 `ref:` · `version:` · `riverpod_lint:` 글자 그대로인 줄만' 을 더한다. 검사를 닫는 쪽(리뷰의 Fix)은 G2-Q2 밖이라 새 승인이 필요하다"
deferred:
  - truth: "README 의 설치 블록(`ref: v2.0.0`)을 새 프로젝트에 그대로 복사해 실제로 받을 수 있다 (tag v2.0.0 이 아직 없다)"
    addressed_in: "Phase 6"
    evidence: "Phase 6 성공 기준 3: '빈 프로젝트가 새 tag 를 git 의존성(`ref: vX.Y.Z`)으로 받아 `dart analyze` 를 돌리면 기본 규칙 진단과 `riverpod_lint` plugin 진단이 둘 다 보고된다'"
human_verification:
  - test: "README 만 열고 처음부터 끝까지 따라 해 본다 — 설치(dev_dependencies 블록 + flutter pub get), 「프리셋 고르기」 에서 하나 고르기, 「규칙 · plugin 진단 끄기」 의 세 층, 「버전 올리기」 의 세 갈래(tag · ref: main · main → tag)"
    expected: "다른 문서를 열지 않고 순서대로 따라 할 수 있고, 막히는 단계나 앞뒤가 맞지 않는 안내가 없다"
    why_human: "'몇 달 뒤 README 만 보고 따라 할 수 있다' 는 grep 으로 가를 수 없다 (성공 기준 1 · 2, 05-VALIDATION Manual-Only)"
  - test: "README 의 「규칙 · plugin 진단 끄기」 · 「생성 파일 제외」 · 「버전 올리기」 · 「문제 해결」 의 단정형 문장마다 spike · fixture 출처, SDK 따라 다른 동작의 SDK 버전 · 날짜, 읽은 것 · 추론 · 추정 표시를 본다"
    expected: "출처 없는 단정이 없다"
    why_human: "문장 단위의 단정 / 출처 구분은 사람이 판단한다 (05-VALIDATION Manual-Only, 05-03 의 human-check)"
  - test: "CHANGELOG 1.1.0 ~ 1.2.5 복원 일곱 항목마다 적힌 커밋을 `git show` 로 열어 적힌 변경과 대조한다"
    expected: "항목의 문장이 diff 의 변경만 말하고 커밋 메시지를 옮기지 않았다 (CHANGELOG 는 `e46cff4` 뒤로 바뀌지 않았다)"
    why_human: "문장의 사실 여부는 grep 으로 가를 수 없다 (05-VALIDATION Manual-Only, 05-04 의 human-check)"
  - test: "README 의 외부 링크 넷을 브라우저로 연다 — flutter#191151 (googlesource 커밋), dart-lang/sdk#64549, dart.dev/tools/pub/workspaces (인용문), pub.dev 의 riverpod_lint 설치 안내"
    expected: "링크가 열리고, 인용문과 요약이 페이지 내용과 같다"
    why_human: "외부 페이지는 검증 명령이 보지 않는다"
  - test: "05-10 이 고친 문장(README 378 · 382행, `example/README.md` 116 · 358 · 395 · 436행)을 읽고, 검사가 실제로 보는 범위를 오해 없이 전하는지 본다 (위 gaps 2 를 고친 뒤)"
    expected: "문장이 말하는 범위와 지워 보기 기록이 같고, 읽는 사람이 받지 않는 보호를 기대하지 않는다"
    why_human: "05-10-SUMMARY coverage D6 (human_judgment: true) — 자동 검증은 글자의 있고 없음만 본다"
---

# Phase 5: Documentation 검증 보고서 (2회차 gap 수정 뒤 재검증)

**Phase 목표:** 소유자가 몇 달 뒤 README 만 보고 설치, 프리셋 선택, 규칙 재정의, 버전 올리기를 그대로 따라 할 수 있고, README / CHANGELOG / YAML 주석이 실제 설정과 일치하며 그 일치가 검증으로 지켜진다
**검증 시각:** 2026-10-14T07:42:21Z
**상태:** gaps_found
**재검증:** 예 — 2회차 gap 수정 05-10 · 05-11 뒤 (이전 gaps_found 50/53)

방법: 저장소를 `git clone --local` 로 검증자 임시 폴더에 복제하고 루트에서 `fvm dart pub get` 을 돌렸다 (Flutter 3.47.5, `riverpod_lint` 3.1.9). 기준 실행 `fvm dart run tool/verify.dart` 는 종료 코드 0 · `점검 통과 (10개 중 10개)` (68초). 입력을 바꾼 실험은 두 가지다 — 전체 실행 11회, 그리고 `tool/verify.dart` 를 import 해 `checkShippedComposition` 을 직접 부르는 하네스(복제본 밖) 40여 회. 변형마다 `git checkout -- .` 로 되돌리고 `git status --porcelain` 0줄을 확인했다. YAML 해석은 analyzer 가 쓰는 package:yaml 3.1.4 의 소스와 `loadYaml` 로 따로 확인했다. 원격 확인은 작업 트리에서 읽기 전용 명령만 썼다. 작업 트리는 끝까지 GSD 도구 상태 넷 밖의 변경이 없었다 (이 보고서 제외).

## 목표 달성

### 관찰 가능한 참 (Observable Truths)

ROADMAP 성공 기준 5개, 첫 회차 plan truth 20개, gap plan 05-07 (9) · 05-08 (8) · 05-09 (11) · 05-10 (9) · 05-11 (4) — 모두 66개.

**성공 기준 (ROADMAP)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| SC1 | README 의 설치 안내와 유형별 include 블록을 그대로 복사해 `ref: vX.Y.Z` 로 추가할 수 있다 | ✓ VERIFIED | 회귀: README 는 05-10 에서 378 · 382행만 바뀌었다; 설치 블록(13 ~ 19행) `ref: v2.0.0`, include 블록 넷 그대로. 실제 tag 설치는 Phase 6 (Deferred) |
| SC2 | 끄기 · 버전 올리기 · `ref: main` → tag · 문제 해결 절, 재정의가 Phase 3 fixture 와 같다 | ✓ VERIFIED | 회귀: 절 제목 그대로(216 · 304 · 324 · 345행), `fixtures` 는 `6d64bee` 와 같고 기준 실행 `[4/10]` · `[10/10]` 통과 |
| SC3 | README 의 규칙 · 설정 설명이 실제 YAML 과 일치하고, 규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 | ✗ FAILED | **앞 절반은 참:** 기준 실행 `[3/10]` 통과(표시 구역 == `lib/base.yaml`). **지난 gap 은 닫혔다:** M68 전체 실행 rc 1 · 1/10, M69 · M70 과 검증자의 철자 넷 모두 실패. **뒤 절반은 새 입력에서 거짓:** `lib/base.yaml` 의 주석 줄 끝 `\r` 뒤에 `    - prefer_mixin` → 전체 실행 rc 0 · 10/10 (README · RULES.md 에 없는 규칙이 배포됨). 같은 자리의 `always_specify_types` 는 사용 프로젝트에 닿는다(정답지 다섯 실패, `[3/10]` 은 통과). gaps 1번 |
| SC4 | CHANGELOG 최상단 새 항목(Phase 1 형식), 1.0.0 ~ 1.3.0 사이 보완 | ✓ VERIFIED | 회귀: `git diff --quiet e46cff4 HEAD -- CHANGELOG.md` |
| SC5 | 배포 YAML 머리 주석이 실제 구성을 설명, 보일러플레이트 없음 | ✓ VERIFIED | 회귀: `git diff --quiet e46cff4 HEAD -- lib` |

**첫 회차 plan truth (20) — 회귀 확인**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 01-1 · 01-2 · 01-4 ~ 01-6 | plugin 줄 끝 주석 통과, 선언 삭제 70, 다른 조각의 읽지 못하는 줄 70, `stripPlugins`, M32 ~ M37 기록 | ✓ VERIFIED | 기준 실행 10/10; M34 함수 단위 `riverpod_lint 선언을 찾지 못했다`; M36 `lib/codegen.yaml 의 `linter:` 블록의 12행을 읽지 못했다` |
| 01-3 | `lib/codegen.yaml` · `lib/riverpod.yaml` 에 규칙을 적으면 실패 — README 비교가 `lib/base.yaml` 하나만 봐도 빈자리가 없다 | ✗ FAILED | 블록 꼴(M35 · M46) · flow(M45) · 다른 철자(M68 ~ M70)는 잡는다. `lib/codegen.yaml` 3행 주석 끝 `\rlinter:\r  rules:\r    - prefer_mixin` → 함수 단위 `passed=true` (analyzer 가 CR 뒤를 읽는 것은 아래 F3 로 확인). gaps 1번 |
| 02-1 ~ 02-5 | 머리 주석 다섯, 템플릿 없음, 규칙 81줄, riverpod 주석, `.claude/CLAUDE.md` 71 · 181행 | ✓ VERIFIED | `lib` · `.claude/CLAUDE.md` 가 고정 커밋(`e46cff4` · `403c584`)과 같다 |
| 03-x · 04-4 ~ 04-6 | README 절 · 표시 구역, CHANGELOG `### 올리기 전에` · `### 그 밖의 변경`, 01 WR-05 fixed | ✓ VERIFIED | CHANGELOG 불변, README 는 378 · 382행만 바뀜 |
| 05-1 ~ 05-3 · 06-1 ~ 06-3 | 첫 push, 비공개 점검, GitHub verify, M38 ~ M42 기록 | ✓ VERIFIED | M42 꼴(start 마커 삭제) 함수 단위 `구역이 없다` 만; `example/README.md` 의 M1 ~ M67 행은 05-10 소절 밖에서 바뀌지 않음(05-10 truth 9) |

(묶은 행도 20개로 센다 — 실패는 01-3 하나.)

**gap plan 05-07 · 05-08 · 05-09 (28) — 회귀 확인**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 07-1 ~ 07-6 · 07-8 · 07-9 | 옛 README 꼴 `(1)`, 구역 안 다섯 꼴, flow 70, 주석 단 블록 꼴 실패, 기준 10/10, `readMarkerBlock`, M47 ~ M50 | ✓ VERIFIED | 함수 단위: M43 꼴 `구역에 읽지 못하는 줄이 있다 (1)`, M45 `10행: `linter:` 줄에 값이 붙어 있다` (FormatException → 70), M46 은 이제 블록 둘(최상위 · 규칙)로 실패 |
| 07-7 | README 378행 불릿이 블록 목록(`[3/10]` 실패)과 flow(70)를 구분해 말하고 단정이 참이 된다 | ✗ FAILED | 378행은 05-10 이 닫힌 목록 문장으로 바꿨고 적은 철자 · 키는 모두 잡힌다. 그러나 CR 뒤의 `formatter:` · `language:` (전체 실행 F4 rc 0 · 10/10) 에서 '그 밖의 최상위 줄 … 은 `[3/10]` 단계가 실패' 가 거짓. gaps 1번 |
| 08-1 ~ 08-8 | RULES.md 표 · 주소 · 펜스 · 옵션 reader, M51 ~ M62 | ✓ VERIFIED | 함수 단위: M60 `6행: `analyzer:` 줄에 값이 붙어 있다`, M59 `7행: `language:` 줄에 …`, M61 `8행을 읽지 못했다`, M62 `+ strict-casts  (base.yaml 에만)` 이고 닫힌 목록 블록 없음; `RULES.md` 는 `76dee2f` 와 같다 |
| 09-1 ~ 09-11 | plugin 선언 · pubspec reader, 문장, 처리 기록, push | ✓ VERIFIED | 함수 단위: M63 (따옴표 선언) · M65 (맵 꼴) `passed=true`, M66 `… 꼴만 받는다 (범위 제약은 받지 않는다 …)`; `pubspec.yaml` 은 `968a5bb` 와 같다 |

**gap plan 05-10 (9)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 10-1 | M68 · M69 · M70 → rc 1 · `[3/10]` 만 · 최상위 블록과 그 줄, 규칙 블록 없음 | ✓ VERIFIED | 전체 실행 M68: rc 1, `[3/10] … 실패`, `` `lib/codegen.yaml` 의 최상위에 받지 않는 줄이 있다 (1) — 받는 키: analyzer `` · `  10행: linter :`, `점검 실패 (10개 중 1개)`, `에 규칙이 있다` 없음. M69 (`10행: "linter":`) · M70 (`6행: linter :`, 받는 키: plugins) 함수 단위 같은 꼴 |
| 10-2 | M78 (`custom_lint` · 따옴표 plugin 키) → `plugins:` 바로 아래 블록 `(2)`, M63 · M65 는 10/10 | ✓ VERIFIED | 함수 단위: `6행:   custom_lint: ^0.7.0` · `7행:   "zz_quoted_plugin": ^0.1.0`, 최상위 블록 없음 |
| 10-3 | M71 (`analyzer:` 아래 `language:`) · M72 (`formatter:`) → 각 블록과 줄 | ✓ VERIFIED | 함수 단위: `5행:   language:` (받는 키: errors · exclude), `10행: formatter:`. 적힌 입력에서 참 — CR 뒤에 둔 같은 키는 gaps 1번 |
| 10-4 | M73 (조각 전체를 두 칸 들여 씀) → `4행:   analyzer:` | ✓ VERIFIED | 함수 단위 그대로 |
| 10-5 | 회귀 입력 11개의 70 · 실패 · 통과가 그대로 | ✓ VERIFIED | 함수 단위로 M45 · M36 · M34 · M60 · M59 · M61 · M66 (FormatException 문구 그대로), M46 (블록 둘), M62 (닫힌 목록 블록 없음), M65 · M63 (`passed=true`) |
| 10-6 | 표시 구역이 든 절의 구역 밖 목록 줄 (M74 ~ M77) | ✓ VERIFIED | 전체 실행 M74: rc 1 · `189행: - `bogus_after_marker`` · 1/10. 함수 단위 M75 `(5)` (93 · 190 ~ 193행), M76 `passed=true`, M77 `(1)` 이고 펜스 안 `- in_fence` 는 세지 않음. truth 가 정한 '제목' (펜스 밖의 `#` 줄) 그대로다 — 렌더링과 다른 꼴은 WR-12 (경고, 아래) |
| 10-7 | 새 절 검사는 구역 안을 다시 세지 않고 마커가 없으면 빠진다 | ✓ VERIFIED | M42 꼴 `구역이 없다` 만, M43 꼴 `읽지 못하는 줄이 있다 (1)` 만 |
| 10-8 | README 378 · 382행, `example/README.md` 116 · 358 · 395 · 436행, `tool/verify.dart` 의 (e) ~ (g) 주석이 실제 동작 · 범위를 말하고, 코드 줄은 `644897f` 와 같다 | ✗ FAILED | **코드 줄 단언은 참:** `declaredRuleNames` (38줄), (e) ~ (g) 구간 (134줄), `fencedLines` · `unquotedScalar` (31줄) 의 주석이 아닌 줄이 `644897f` 와 같다. **문장은 일부 거짓:** 378 · 379행은 CR 입력에서 (gaps 1번), `example/README.md` 116행 · `tool/verify.dart` 1857 ~ 1858행의 (e) 구절은 `package:woody-lints/riverpod` 에서 (전체 실행 F8 rc 0 · 10/10), 382 · 116 · 395행의 (f) · (g) 구절은 따옴표 키 · 콜론 앞 공백에서 (F7 · F7b rc 0 · 10/10) 넓다 (gaps 2번) |
| 10-9 | 기준 실행 10/10, 고정 커밋 불변, M1 ~ M67 행 불변 | ✓ VERIFIED | 기준 실행 rc 0 · 10/10; `lib` · `CHANGELOG.md` (`e46cff4`) · `RULES.md` (`76dee2f`) · `fixtures` (`6d64bee`) · `pubspec.yaml` (`968a5bb`) · `.claude/CLAUDE.md` (`403c584`) 모두 diff 0 |

**gap plan 05-11 (4)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 11-1 | 처리 기록 fixed 13 · skipped 4 · deferred 1 · open 0 · total 18 | ✓ VERIFIED | `git show b8519d4:…/05-REVIEW-DISPOSITION.md` frontmatter 그대로. 지금 파일의 `open: 5` · `total: 23` 은 그 뒤 재리뷰(`d60b709`)가 더한 새 발견이다 — 판정은 아래 표 |
| 11-2 | CHANGELOG 불변 | ✓ VERIFIED | `git diff --quiet e46cff4 b8519d4 -- CHANGELOG.md` |
| 11-3 | push 전 범위 비공개 점검 0 | ✓ VERIFIED | `git diff 8789cfe b8519d4` 의 더한 줄에 절대 경로 꼴 0 (계획의 정규식 원문 줄만 걸림); 공개 파일(README · example · tool · lib · RULES · CHANGELOG · fixtures)의 절대 경로 꼴 0 |
| 11-4 | fast-forward push, `main` · tag · PR 불변, GitHub verify 성공 | ✓ VERIFIED | `git ls-remote origin`: 작업 브랜치 `b8519d4`, `main` `90a2736`, tag `v1.3.0` 하나; `8789cfe` 는 `b8519d4` 의 조상; `gh pr list --state all` → `[]`; `gh run view 38522962086`: `completed` · `success` · push · headSha `b8519d4…`, 로그에 `[3/10] 배포 파일의 구성 … 통과` · `점검 통과 (10개 중 10개)`. 로컬의 그 뒤 커밋 5개는 `.planning` 만 바꾼다(README · lib · tool 등 diff 0) |

**점수:** 62/66 참 확인 (present · behavior-unverified 0). 실패 넷 가운데 SC3 · 01-3 · 07-7 과 10-8 의 378 · 379행 부분은 뿌리가 하나다 (gaps 1번 — 줄 나누기). 10-8 의 나머지는 문장 둘 (gaps 2번).

### Deferred Items

| # | 항목 | 다룰 phase | 근거 |
|---|------|-----------|------|
| 1 | README 의 `ref: v2.0.0` 블록으로 실제로 받는 것 (tag 가 아직 없다) | Phase 6 | 성공 기준 3 |

gaps 1 · 2 는 Phase 6 (tag · 릴리스 smoke test) 의 범위에 들지 않는다 — 미루지 않았다.

### 닫힌 목록 (a′) 가 지난 gap 을 YAML 기준으로 닫는가 (orchestrator 요청)

| 입력 (다른 조각 끝 또는 지정 자리) | YAML 에서 | 결과 | 판정 |
|------|-----------|------|------|
| `linter :` · `"linter":` · `'linter':` | `linter` 키 | 최상위 블록 `(1)` | ✓ 닫힘 |
| `? linter` / `:` (명시 키) | `linter` 키 | 최상위 블록 `(2)` | ✓ |
| `&a linter:` · `!!str linter:` (앵커 · 태그) | `linter` 키 | 최상위 블록 `(1)` | ✓ |
| 조각 전체를 두 칸 들여 씀 (M73) | 같은 최상위 맵 | 최상위 블록 | ✓ |
| `analyzer:` · `plugins:` 줄에 값 · 앵커 · 태그 | 아래 키를 읽을 수 없음 | 최상위 블록 | ✓ |
| BOM (`\uFEFF`) 으로 시작하는 키 줄 | package:yaml 은 열 0 의 BOM 을 건너뛰지만 이 자리는 `Expected a key while parsing a block mapping` (파싱 오류) | codegen 끝: `analyzer:` 아래 블록으로 실패. base 의 `include:` 뒤: `passed=true` 이나 YAML 이 깨져 사용 프로젝트에 닿지 않는다 | ✓ (헛통과 아님) |
| NBSP (`\u00A0`) 로 시작하는 키 줄 | 키 이름이 `\u00A0plugins` — `plugins` 가 아닌 다른 키 (`loadYaml` 확인) | base 의 `include:` 뒤: `passed=true` 이나 analyzer 가 받는 `plugins:` 가 아니다 | ✓ (헛통과 아님) |
| 주석 줄 끝 CR 뒤의 키 · 규칙 | 새 줄 (CR 은 YAML 줄바꿈) | `passed=true`, 전체 실행 10/10 | ✗ gaps 1번 |

결론: 닫힌 목록은 **한 줄 안의 철자**에 대해서는 YAML 기준으로 닫혔다 — 키 줄을 정규식 하나로 받고 나머지를 모두 막는 설계라, 철자를 하나씩 더하는 수정과 달리 따옴표 · 명시 키 · 앵커 · 태그를 따로 다루지 않아도 막힌다. 남은 구멍은 **줄의 경계**다: reader 셋이 줄을 `\n` 으로만 나눠, YAML 이 줄로 보는 CR 뒤를 주석의 일부로 본다. 같은 파일의 `significantLines` (`readAsLinesSync`) 는 CR 을 나누므로 묶음 · 별칭의 같은 꼴은 `(a)` 가 잡는다(`lib/recommended.yaml` 함수 단위 `passed=false`) — 고칠 방법이 이미 파일 안에 있다.

### 05-REVIEW 2회차 재리뷰 발견의 판정 (orchestrator 요청)

판정 기준: 이 phase 가 말한 참(성공 기준, plan must_haves, README · `example/README.md` 의 "검사가 지킨다" 문장)이 그 입력에서 거짓이 되는가. 규칙 · 옵션 · plugin 이 사용 프로젝트에 닿는데 10/10 이면 VERIFY-06 의 약속이 깨진 것이라 gap. 소유자가 G2-Q2 로 "문장을 실제 범위대로" 고르고 코드를 두기로 한 보조 검사 (e) ~ (g) 는, 문장이 코드보다 넓으면 그 문장의 truth (10-8) 가 거짓이다. 모두 복제본에서 재현했다 (리뷰의 기록은 증거로 쓰지 않았다).

| 발견 | 재현 (검증자) | 판정 | 이유 |
|------|---------------|------|------|
| WR-11 CR 뒤의 키 · 규칙 | 전체 실행 넷 — F1 base 숨은 `prefer_mixin` rc 0 · 10/10; F2 base 숨은 `always_specify_types` rc 1 이나 `[3/10]` 통과 · `[2/10]` 의 `analysis_options.yaml:94  incompatible_lint` · 정답지 다섯 실패; F3 codegen 숨은 `strict-casts` `[3/10]` 통과 · `invalid_assignment` 로 정답지 셋 실패; F4 codegen 숨은 `language:` + `formatter:` rc 0 · 10/10. 함수 단위 셋(codegen 숨은 `linter:`, base 숨은 `formatter:` · `plugins:`, riverpod 숨은 plugin) `passed=true`. package:yaml 3.1.4 소스 `_isBreakAt` → `char == CR \|\| char == LF` | 🛑 gap (gaps 1번) | 숨은 규칙 · 옵션이 사용 프로젝트에 닿고 10/10 이다 (F1 · F2 · F3). SC3 · README 378 · 379행 · `example/README.md` 116행이 거짓. 개연성은 낮지만 지난 두 회차와 같은 모양 · 같은 기준이다 |
| WR-12 HTML 주석 안 `#` 줄 · 4칸 들여 쓴 ``` | 전체 실행 F5 (end 마커 뒤 `<!--` / `# memo` / `-->` / 불릿) rc 0 · 10/10; F6 (빈 줄, 4칸 ```, 불릿, 4칸 ```) rc 0 · 10/10. 대조: 불릿만이면 rc 1 (M74), 3칸 들여 쓴 펜스는 CommonMark 에서도 펜스라 `passed=true` 가 맞다 | ⚠️ 경고 | truth 10-6 은 '제목' 을 펜스 밖의 `#` 줄로 정했고 코드는 그대로 한다. 검사하는 규칙 목록은 D-01 대로 표시 구역이고 그 구역 == YAML 은 지켜진다 — SC3 의 '규칙 목록' 은 깨지지 않는다. 다만 렌더링된 절에 규칙처럼 보이는 줄이 남고, `example/README.md` 116행 '구역 앞의 제목부터 … 다음 제목 앞까지' 는 렌더링 기준으로 읽힌다. gaps 1번을 고치는 plan 에서 리뷰의 Fix(HTML 주석 · 4칸 펜스를 가림)를 함께 넣거나 문장에 정의를 적기를 권한다 |
| WR-13 따옴표 키 · 콜론 앞 공백 | 전체 실행 F7 (18행 `"ref": v1.9.0` + 198행 `'riverpod_lint': ^3.1.3`) rc 0 · 10/10; F7b (18행 `ref : v1.9.0`) rc 0 · 10/10; 대조 `ref: v1.9.0` → `passed=false` | ⚠️ 경고 — gaps 2번의 일부 | 코드를 넓히지 않는 것은 G2-Q2 의 결정이고 받아들인 단점과 같은 종류다. 그러나 좁힌 문장은 범위 밖을 'flow · 들여 쓴 블록 · 인용 안 펜스' 로만 적는다. '`ref:` 줄' 을 글자 그대로 읽으면 맞다는 해석이 가능해 WR-14 보다 약하다 |
| WR-14 확장자 없는 다른 패키지 주소 | 전체 실행 F8 (68행 `- package:woody-lints/riverpod`) rc 0 · 10/10; 대조 `.yaml` 을 붙이면 `woody_lints 가 아닌 패키지의 .yaml 주소가 있다 (1)` | ⚠️ — gaps 2번 (10-8 거짓) | `example/README.md` 116행과 `tool/verify.dart` 1857 ~ 1858행이 이 주소를 실패로 적는다 — G2-Q2 가 요구한 '정확히' 가 아니다. 436행은 정확하다. 문장 하나 · 주석 하나를 436행에 맞추면 닫힌다 |
| IN-09 M35 · M37 기록이 지금 두 블록 | 함수 단위: M35 의 네 줄 → 최상위 블록 `(1)` 과 `에 규칙이 있다 (2)` 둘 | ℹ️ 정보 | 기록 행은 그때의 결과이고 고치지 않는 것이 금지(P-03 · P-04)다. 518행의 읽는 법이 M46 만 짚는다 — 같은 plan 에서 한 줄 넓히면 된다 |
| WR-07 · WR-08 · WR-09 · IN-08 (skipped, G2-Q2) | 코드 줄이 `644897f` 와 같음을 확인 (위 10-8) | 범위 한계로 받아들임 | 좁힌 문장(README 382, `example/README.md` 116 · 395 · 436, `tool/verify.dart` 2126 · 2133 · 2178)이 scheme 오타 · `package:` 뒤 공백 · 문장 부호 · flow · 들여 쓴 블록 · 인용 안 펜스를 범위 밖으로 맞게 적는다. 예외는 1864행 주석의 '문장 부호를 보지 않고' — `woody_lints` 쪽은 그 문장 부호로 거짓 실패한다(코드 읽음, 정보) |
| WR-06 (deferred, D-09) | `.claude/CLAUDE.md` 가 `403c584` 그대로 | 미룸 그대로 | 마일스톤 끝 `/gsd-map-codebase` |

**소유자가 Round 2 에서 범위 밖으로 둔 것** — 「받는 규칙」 절의 표 · 산문 · HTML 규칙 이름, `lib/base.yaml` 의 `include:` 값, 둘째 마커 쌍, `lib/base.yaml` 의 `analyzer:` 아래 키, codegen `errors:` 의 심각도 재정의, CHANGELOG 98행, README 214행은 승인된 범위 한계로 적고 gap 으로 세지 않았다. 이 가운데 승인한 must_have 와 부딪치는 것은 찾지 못했다 — `allowedChildKeys` 에 `lib/base.yaml` 이 없는 것은 05-10 의 금지(base 의 analyzer 아래를 목록으로 묶지 않음) 그대로다. gaps 1번의 CR 입력은 이 목록 밖이다: base 의 `analyzer:` 아래가 아니라 **최상위**(`formatter:` · `plugins:`)와 **`linter:` 규칙 목록**에 숨는다.

### Required Artifacts

| Artifact | 기대 | 상태 | 세부 |
|----------|------|------|------|
| `tool/verify.dart` | `allowedTopLevelKeys` · `allowedChildKeys` · `findUnexpectedKeys` (a′), `findMarkerRange` · `markFencedLines` · `findListLinesOutsideMarkers` (d′), (e) ~ (g) 주석 | ⚠️ 있음 · 연결됨 · 일부 fail-open | (a′) 는 `[3/10]` 에 연결되고 적힌 입력을 모두 잡는다; 줄 나누기가 YAML 과 달라 CR 뒤를 놓친다 (gaps 1번); 1857 ~ 1858 · 1864행 주석이 넓다 (gaps 2번) |
| `README.md` | 378 · 382행 | ⚠️ | 378 · 379행의 단정이 CR 입력에서 거짓, 382행 (f) · (g) 구절이 따옴표 키 · 콜론 앞 공백을 말하지 않음 |
| `example/README.md` | M68 ~ M78 소절 둘, 116 · 358 · 395 · 436행 | ⚠️ | 소절 둘 있음(`### 추가 실측 — 조각의 최상위 키와 `analyzer:` 아래 키의 닫힌 목록 (05-10)`); 116행의 (e) 구절이 넓음 |
| `05-REVIEW-DISPOSITION.md` | 05-11 시점 open 0 | ✓ VERIFIED | `b8519d4` 시점 그대로; 지금 open 5 는 재리뷰 발견 |

### Key Link Verification

| From | To | Via | 상태 | 세부 |
|------|----|-----|------|------|
| `tool/verify.dart` | 조각 셋 | (a′) `findUnexpectedKeys` | ⚠️ PARTIAL | 한 줄 안의 철자 · 들여쓰기는 모두 잡고, CR 로 나뉜 줄은 놓친다 |
| `tool/verify.dart` | `lib/base.yaml` | (b) · (c) · (d) `declaredRuleNames` | ⚠️ PARTIAL | CR 뒤의 규칙을 세지 않는다 (F1) |
| `tool/verify.dart` | `README.md` | (d′) `findListLinesOutsideMarkers` | ✓ WIRED (경고 있음) | M74 · M75 · M77 실패, WR-12 꼴은 통과 |
| `tool/verify.dart` | `example/README.md` | M68 ~ M78 기록 | ✓ WIRED | 검증자 실행 결과가 기록과 같다 (M68 · M74 전체 실행, 나머지 함수 단위) |
| 로컬 브랜치 | origin | `git push origin gsd/v2.0-package-rework` | ✓ WIRED | origin `b8519d4`, verify run 38522962086 success |

### Behavioral Spot-Checks (전체 실행)

| 동작 | 결과 | 상태 |
|------|------|------|
| 기준 실행 | rc 0 · `점검 통과 (10개 중 10개)` | ✓ PASS |
| M68 codegen `linter :` | rc 1 · `[3/10]` 만 · 1/10 · 규칙 블록 없음 | ✓ PASS (지난 gap 닫힘) |
| M74 end 마커 뒤 불릿 | rc 1 · `189행` · 1/10 | ✓ PASS |
| F1 base 주석 끝 CR + `- prefer_mixin` | rc 0 · 10/10 | ✗ FAIL (gaps 1) |
| F2 base 주석 끝 CR + `- always_specify_types` | rc 1, `[3/10]` 통과, 사용 프로젝트에 진단 | ✗ FAIL (gaps 1 — `[3/10]` 이 잡지 못함) |
| F3 codegen CR + `language: strict-casts` | rc 1, `[3/10]` 통과, `invalid_assignment` | ✗ FAIL (gaps 1) |
| F4 codegen CR + `language:` · `formatter:` | rc 0 · 10/10 | ✗ FAIL (gaps 1) |
| F5 · F6 WR-12 | rc 0 · 10/10 | ⚠️ 경고 |
| F7 · F7b WR-13 | rc 0 · 10/10 | ⚠️ (gaps 2) |
| F8 WR-14 | rc 0 · 10/10 | ⚠️ (gaps 2) |

### Probe Execution

해당 없음 — 이 phase 는 `scripts/*/tests/probe-*.sh` 를 선언하지 않는다. 검증 명령 자체를 위 표로 돌렸다.

### Requirements Coverage

| 요구사항 | Plan | 상태 | 근거 |
|----------|------|------|------|
| DOCS-01 | 05-03 | ✓ SATISFIED (실제 tag 설치는 Phase 6) | SC1 |
| DOCS-02 | 05-03 | ✓ SATISFIED | SC1 |
| DOCS-03 | 05-03 | ✓ SATISFIED | SC2 |
| DOCS-04 | 05-03 | ✓ SATISFIED | SC2 |
| DOCS-05 | 05-03 | ✓ SATISFIED | 「문제 해결」 네 소절 |
| DOCS-06 | 05-03 · 05-07 · 05-09 · 05-10 | ✓ SATISFIED (지금 상태) | 지금 README 의 규칙 · 설정 설명은 YAML 과 같다(기준 실행 `[3/10]`). 검사를 설명하는 문장의 넓음은 gaps 1 · 2 와 함께 고친다 |
| DOCS-07 | 05-04 · 05-09 | ✓ SATISFIED | SC4 |
| DOCS-08 | 05-04 | ✓ SATISFIED | 변경 없음 (사람 확인 3번) |
| DOCS-09 | 05-04 | ✓ SATISFIED | 변경 없음 |
| DOCS-10 | 05-01 · 05-02 | ✓ SATISFIED | SC5 |
| VERIFY-06 | 05-01 · 05-03 · 05-05 ~ 05-11 | ✗ BLOCKED | gaps 1번 — CR 뒤에 둔 규칙이 `lib/base.yaml` 의 목록 · RULES.md · README 와 다르게 배포되는데 10/10 |

ORPHANED 없음 — REQUIREMENTS.md 가 Phase 5 에 매긴 11개가 모두 plan 의 `requirements` 에 있다. REQUIREMENTS.md 의 표시(VERIFY-06 · DOCS-06 `Complete`, 나머지 아홉 `Gaps Found`)는 이 증거와 다르다 — VERIFY-06 은 BLOCKED, 나머지 열은 SATISFIED 다.

### Anti-Patterns

| 파일 | 줄 | 패턴 | 심각도 | 영향 |
|------|----|------|--------|------|
| `tool/verify.dart` | 951 · 1027 · 1101 | YAML 옵션을 `\n` 으로만 나눔 (CR 하나를 줄바꿈으로 보지 않음) — 같은 파일의 `significantLines` 는 `readAsLinesSync` | 🛑 Blocker | gaps 1번 (전체 실행 F1 · F4 가 증거) |
| `tool/verify.dart` | 832 · 1408 | 같은 꼴 (`stripPlugins` · `readShippedPluginConstraint`) | ⚠️ Warning | 직접 헛통과는 재현하지 않음 — 같은 수정에 함께 넣기를 권함 |
| `tool/verify.dart` | 1530 ~ 1556 · 1812 | HTML 주석 · 4칸 들여 쓴 ``` 를 제목 · 펜스로 봄 | ⚠️ Warning | WR-12 |
| `tool/verify.dart` · `example/README.md` | 1857 ~ 1858 · 116 | (e) 문장이 코드보다 넓음 | ⚠️ Warning | gaps 2번 |

`TBD` · `FIXME` · `XXX` 표식: `tool/verify.dart` · `README.md` · `example/README.md` 에 0개. 공개 파일의 절대 경로 꼴 0줄. 재검증 증거 gate: gaps 1번은 이번에 바뀐 `tool/verify.dart` 의 새 검사에 걸리고 전체 실행 결과(F1 · F4)라는 재현 가능한 증거가 있어 blocker 로 둔다. 증거 없는 새 범위 발견은 없다 (Advisory 없음).

### 금지 사항(prohibitions) 확인 (판단 등급 — 검증자의 비권위 판정)

기계로 가를 수 있는 것은 직접 확인했고 어긴 것은 없다.

- 05-10: `declaredRuleNames` 본문은 `644897f` 와 주석이 아닌 줄이 같다(철자 정규식을 더하지 않음); (e) ~ (g) · `fencedLines` · `unquotedScalar` 의 코드 줄도 같다; `allowedChildKeys` 에 `lib/base.yaml` 이 없다; `lib` · `RULES.md` · CHANGELOG · `pubspec.yaml` · `fixtures` · `.claude/CLAUDE.md` 가 고정 커밋과 같다; 공개 파일 · 범위 이력에 절대 경로 꼴 0. "지워 보기는 복제본에서" 는 작업 트리와 이력에 변형 흔적이 없다는 것까지만 확인할 수 있다.
- 05-11: push 는 fast-forward (`8789cfe` → `b8519d4`), 원격 `main` `90a2736` · tag `v1.3.0` 하나 · PR 0; 처리 기록의 앞 회차 행 그대로(`b8519d4` 시점); WR-06 `deferred`; 05-11 이 CHANGELOG · 배포 YAML · README · `tool/verify.dart` 를 바꾸지 않았다.

### Human Verification Required

gap 을 닫은 뒤에도 남는 사람 확인 다섯이다 (frontmatter `human_verification`).

1. **README 를 처음부터 따라 하기** — 설치 → 프리셋 고르기 → 끄기 세 층 → 버전 올리기 세 갈래.
2. **단정 / 출처 문장 단위 확인** — 끄기 · 생성 파일 제외 · 버전 올리기 · 문제 해결.
3. **CHANGELOG 복원 일곱 항목과 `git show` diff 대조** — 첫 회차 검증이 대조해 일치를 기록했고 그 뒤 CHANGELOG 는 92행 한 줄만 바뀌었다(`e46cff4` 뒤로 불변).
4. **외부 링크 넷 열기.**
5. **05-10 이 고친 검사 설명 문장의 읽힘** — gaps 2번을 고친 뒤, 문장이 말하는 범위가 지워 보기 기록과 같은지 (05-10-SUMMARY D6).

### Gaps 요약

**지난 gap 은 닫혔다.** 다른 철자의 `linter` 키(M68 · M69 · M70)는 `[3/10]` 실패이고, 검증자가 더 넣은 철자 넷(작은따옴표 · 명시 키 · 앵커 · 태그)도 막힌다. 05-10 · 05-11 의 truth 는 적힌 입력에서 모두 돌린 대로이고, 회귀 입력 11개와 앞 기록의 결과도 그대로다. GitHub verify 도 새 검사 둘로 10/10 이다.

**새 gap 하나 (blocker, 뿌리 하나):** 닫힌 목록이 한 줄 안의 철자는 YAML 기준으로 닫았지만 **줄의 경계**는 YAML 과 다르다. `findUnexpectedKeys` · `declaredRuleNames` · `enabledLanguageOptions` 가 줄을 `\n` 으로만 나누는데, YAML 과 analyzer 는 CR 하나도 줄바꿈으로 읽는다. 주석 줄 끝의 `\r` 뒤에 둔 규칙 · 옵션 · plugin 은 reader 에게 주석이고 analyzer 에게는 새 줄이다 — `lib/base.yaml` 에 숨긴 규칙은 10개 중 10개로 배포되고(F1), 같은 꼴의 규칙 · 옵션은 사용 프로젝트에 진단을 낸다(F2 · F3). 같은 모양(reader 가 analyzer 와 다르게 읽는 줄을 조용히 건너뜀)이 세 번째로 나왔다. 수정은 작다 — `const LineSplitter().convert(…)` 로 나누면 된다 (같은 파일의 `significantLines` 가 이미 그렇게 나눠 묶음의 같은 꼴을 잡는다). 개연성은 낮다(CR 하나만 든 파일). 소유자가 이 입력을 받아들이기로 하면 아래 override 로 적을 수 있다 — 다만 고치는 비용이 override 를 적는 비용과 비슷하다.

```yaml
overrides:
  - must_have: "규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 — 조각마다 받는 키는 닫힌 목록이고 그 밖의 최상위 줄 · 그 바로 아래의 다른 키는 `[3/10]` 실패"
    reason: "{CR 하나(\\r)로만 나뉜 줄은 이 저장소의 편집 경로에서 생기지 않는다고 보고 받아들인다 — 그 경우 README 378 · 379행과 example/README.md 116행에 'CR 하나로 나뉜 줄은 보지 않는다' 를 적는다}"
    accepted_by: "{name}"
    accepted_at: "{ISO timestamp}"
```

**문장 둘 (gaps 2번, partial):** G2-Q2 로 좁힌 문장 가운데 `example/README.md` 116행 · `tool/verify.dart` 1857 ~ 1858행의 (e) 구절은 확장자 없는 다른 패키지 주소(`package:woody-lints/riverpod`)까지 실패한다고 적고(10/10 으로 통과), README 382 · `example/README.md` 116 · 395행의 (f) · (g) 구절은 따옴표 키 · 콜론 앞 공백을 범위 밖으로 적지 않는다. 코드는 그대로 두고 문장만 436행처럼 정확히 맞추면 G2-Q2 안에서 닫힌다.

**경고 · 정보:** WR-12 (HTML 주석 · 4칸 펜스가 (d′) 의 절 경계를 옮김 — 표시 구역 == YAML 은 지켜짐), IN-09 (M35 · M37 의 지금 출력이 두 블록), 1864행 주석. gaps 1번을 고치는 plan 에 함께 넣기를 권하지만 소유자가 범위를 정한다.

지금 상태의 README · CHANGELOG · YAML 주석은 실제 설정과 일치한다 — 실패한 것은 "그 일치가 검증으로 지켜진다" 의 한 입력(CR 로 나뉜 줄)과, 검사 범위를 말하는 문장 둘이다.

---

_Verified: 2026-10-14T07:42:21Z_
_Verifier: Claude (gsd-verifier)_
