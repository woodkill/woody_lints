---
phase: 05-documentation
verified: 2026-10-14T14:02:53Z
status: gaps_found
score: 74/78 must-haves verified
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
  - ".planning/phases/05-documentation/05-12-PLAN.md"
  - ".planning/phases/05-documentation/05-12-SUMMARY.md"
  - ".planning/phases/05-documentation/05-13-PLAN.md"
  - ".planning/phases/05-documentation/05-13-SUMMARY.md"
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
covered_digest: "v3:sha256:f7baa07fe7f067b8204e53f864c40d07cb3568b4b23b7720d09a005ac0aef06c"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 62/66
  gaps_closed:
    - "지난 gaps 1 (CR 하나로 나뉜 줄) — 검증자 복제본 전체 실행: M79 rc 1 · `[3/10]` 만 · `+ prefer_mixin  (base.yaml 에만)` 두 줄 · 10개 중 1개, M80 rc 1 · `[2/10]` 의 `:94  warning  incompatible_lint  (always_specify_types)` · 10개 중 7개, M81 rc 1 · `10행:   language:` · 10개 중 4개, M82 rc 1 · `12행: formatter:` 와 `10행:   language:` · 10개 중 1개; 함수 단위 M83 ~ M85 모두 `passed=false` (블록 줄은 기록 그대로); 함수 직접 호출 일곱이 05-12 truth 4 의 기대값 그대로"
    - "지난 gaps 2 의 적힌 꼴 (WR-13 · WR-14 문장) — `example/README.md` 116행 · `tool/verify.dart` 의 (e) 문서 주석이 다른 패키지 쪽을 `.yaml` · `.yml` 로 끝나는 주소로 좁혔고, README 382 · `example/README.md` 116 · 395행 · (f) · (g) 주석이 '키는 따옴표 · 콜론 앞 공백 없이 글자 그대로인 줄만 후보' 를 말한다. 함수 단위로 `package:woody-lints/riverpod` · `ref : v1.9.0` · `packages:woody_lints/riverpod.yaml` 이 `passed=true` — 문장이 말한 범위 밖 그대로다"
  gaps_remaining: []
  regressions: []
  new_gaps:
    - "같은 모양의 다른 입력 (네 번째) — 줄 단위 reader 가 YAML 의 여러 줄 스칼라(따옴표 · 블록)와 같은 키의 중복을 모른다. 스칼라 안의 줄을 키 · 규칙 · 옵션 · version 으로 읽고(정방향 — 05-REVIEW WR-15 · WR-16 재현), 스칼라 안의 가짜 열 0 줄 · 가짜 첫 자식 줄로 블록 경계 · '바로 아래' 들여쓰기를 옮겨 진짜 옵션 · plugin 을 건너뛴다(역방향 — 검증자가 찾음, 지난 gap 과 같은 쪽)"
    - "README 382 · `example/README.md` 116 · 395행 · (f) · (g) 주석이 펜스 안의 네 칸 들여 쓴 ``` 줄을 범위 밖으로 적지 않는다 (05-REVIEW IN-10 재현)"
gaps:
  - truth: "규칙 · 설정 설명이 실제 YAML 과 일치하고 어긋나면 검증 명령이 실패한다 — README 378행 '그 바로 아래의 다른 키(`lib/codegen.yaml` 의 `language:`, `lib/riverpod.yaml` 의 다른 plugin 등)는 `[3/10]` 단계가 실패', 379행 '어긋나면 검증이 실패한다', `example/README.md` 116행의 닫힌 목록 구절과 '`ref: vX.Y.Z` 가 `pubspec.yaml` 의 version 과 같은지' (성공 기준 3 · VERIFY-06 · 05-07 truth 7 · 05-10 truth 8 · 05-12 truth 6)"
    status: failed
    reason: "결함의 꼴: `tool/verify.dart` 의 줄 단위 reader 는 05-12 뒤 줄 경계는 YAML 과 같지만, 줄이 YAML 의 어떤 노드에 속하는지는 모른다. (1) 여러 줄 따옴표 스칼라 · 블록 스칼라(`|` · `>`) 안의 줄을 구조(키 · 규칙 · 옵션 · `version:`)로 읽는다 — YAML · analyzer · pub 은 글자 값으로 읽는다. (2) 같은 키가 두 번 나온 줄을 막지 않는다 — YAML 은 두 번째 키를 받지 않으므로 그 줄은 늘 스칼라 안의 가짜 줄이다. (3) 그 가짜 줄이 블록 경계(열 0 줄)와 `findUnexpectedKeys` 의 '바로 아래' 들여쓰기(첫 자식 줄)를 정하게 둔다. 닿는 reader: `declaredRuleNames` → (b′) · (b) · (c) · (d); `enabledLanguageOptions` → (c) 의 켠 옵션 표; `findUnexpectedKeys` → (a′); `pubspecReleaseVersion` → (g); 같은 꼴이나 헛통과를 재현하지 않은 것: `readShippedPluginConstraint` (첫 `riverpod_lint:` 줄), `stripPlugins`. 검증자 복제본 전체 실행 — 정방향: WR-16 (`lib/base.yaml` 끝 `analyzer:` / `  exclude:` / `    - \"build/**` / `linter:` / `  rules:` / `    - prefer_mixin` / `    # \"`, RULES.md 표 · README 목록에 `prefer_mixin` 한 줄씩) rc 0 · 10개 중 10개 — loadYaml 의 `linter.rules` 에는 `prefer_mixin` 이 없다(문서가 받지 않는 규칙을 켰다고 적음); WR-15 (`pubspec.yaml` 2행을 `description: \"…` / `version: 1.9.0` / `\"` 로, README 18 · 333행 `ref: v1.9.0`) rc 0 · 10/10 — reader `1.9.0`, loadYaml `2.0.0-dev`. 역방향: R1 (`lib/codegen.yaml` 끝 `    - \"x/**` / `analyzer:` / ` exclude:` / ` # \"` / `  language:` / `    strict-inference: true`) rc 0 · 10/10, 같은 꼴 `strict-casts: true` 는 `[2/10]` · `[3/10]` 통과에 `[5/10]` · `[9/10]` · `[10/10]` 이 `invalid_assignment` 로 실패(옵션이 실제 include 사슬로 사용 프로젝트에 닿는다); R2 (`lib/base.yaml` 끝 `analyzer:` / `  exclude:` / `    - \"x/**` / `include: x` / `  # \"` / `  language:` / `    strict-inference: true`) rc 0 · 10/10 — reader 의 옵션 `{}`, RULES.md '없음' 과 같다고 보는데 loadYaml 은 `language: {strict-inference: true}`; 같은 꼴 `strict-casts` 는 `[3/10]` 통과 · 정답지 다섯 `invalid_assignment` 실패. 작은 프로젝트의 analyzer 대조: R1 · R2 꼴의 옵션 파일에서 `inference_failure_on_collection_literal` 2건, 대조(옵션 없음) 0건. 함수 단위: R3 (`lib/riverpod.yaml` 을 맵 꼴로 쓰고 `diagnostics:` 아래 `x: \"a` / `plugins:` / ` riverpod_lint:` / ` # \"` / `  custom_lint: ^0.7.0`) `passed=true` — loadYaml 의 `plugins` 에 `custom_lint` 가 있다; WR-16 블록 스칼라 꼴(`    - |` / `      language:` / `        strict-casts: true` + RULES.md 행) `passed=true`. 대조: 같은 옵션을 스칼라 없이 두면 R1 `10행:   language:` 로, R2 `+ strict-inference  (base.yaml 에만)` 으로 `passed=false`. 개연성은 낮다(일부러 꾸민 입력). 그러나 README 378 · 379행 · `example/README.md` 116행 · 성공 기준 3 의 단정이 이 입력에서 거짓이고, 지난 세 회차와 같은 기준(규칙 · 옵션 · plugin 이 사용 프로젝트에 닿거나 문서가 실제와 다른데 10/10)을 적용했다. 같은 모양(reader 가 보는 줄 · 키 · 값 ≠ YAML · analyzer · pub 이 보는 것)이 네 번째다."
    artifacts:
      - path: "tool/verify.dart"
        issue: "`declaredRuleNames` (951행) · `enabledLanguageOptions` (1101행, `language:` 를 `analyzer:` 아래 어느 깊이에서든 받음) · `findUnexpectedKeys` (1029행, 같은 최상위 키 중복을 막지 않고 첫 자식 줄로 '바로 아래' 를 정함) · `pubspecReleaseVersion` (1587행, 첫 `^version:` 줄) 이 여러 줄 스칼라 안의 줄을 구조로 읽는다"
      - path: "README.md"
        issue: "378 · 379행의 단정이 위 입력에서 거짓"
      - path: "example/README.md"
        issue: "116행의 닫힌 목록 구절 · (g) 구절이 위 입력에서 거짓"
    missing:
      - "소유자가 길을 고른다 — 철자 · 꼴을 하나씩 더 막는 수정은 네 번째라 권하지 않는다. (A) D-11(`dart:io` · `dart:convert` 만) 안에서 꼴을 닫는다: 조각 셋과 `pubspec.yaml` 에 여러 줄 스칼라를 여는 줄(따옴표가 그 줄에서 닫히지 않음 · `|` · `>`)과 닫히지 않은 flow 괄호가 있으면 70 또는 `[3/10]` 실패, `findUnexpectedKeys` 가 같은 수준의 중복 키를 받지 않는 줄로, `enabledLanguageOptions` 는 `analyzer:` 바로 아래의 `language:` 만, `pubspecReleaseVersion` 은 열 0 의 `version:` 줄이 정확히 하나일 때만 (05-REVIEW WR-15 · WR-16 의 Fix 와 같은 방향). (B) D-11 을 다시 정해 `yaml` 을 루트 `dev_dependencies` 에 두고(사용 프로젝트로 전달되지 않는다) 각 reader 의 결과를 `loadYaml` 결과와 견줘 다르면 실패 — 규칙 목록 · `analyzer.language` · 최상위 키와 그 아래 키 · `plugins` 의 키 · `version` 을 한 번에 YAML 기준으로 묶는다. (C) 받아들이고 override 와 함께 378 · 379 · 116행에 '조각 · `pubspec.yaml` 은 한 줄 스칼라로 적는다 — 여러 줄 스칼라 안의 줄은 검사가 YAML 과 다르게 읽는다' 를 적는다"
      - "지워 보기 기록: 위 전체 실행 넷(WR-16 규칙 · WR-15 · R1 · R2)과 함수 단위 둘(R3 · WR-16 블록 스칼라)이 고친 뒤 실패가 되는지 복제본에서 돌려 적는다; 기준 실행 10개 중 10개 유지"
  - truth: "README 382행 · `example/README.md` 116 · 395행 · `tool/verify.dart` 의 (f) · (g) 주석이 실제 검사 범위를 말한다 (05-10 truth 8, 소유자 결정 G2-Q2 · G3-Q2 '문장을 검사 범위에 맞춤')"
    status: partial
    reason: "WR-07 · WR-08 · WR-09 · WR-12 · WR-13 · WR-14 · IN-08 의 꼴은 지금 문장이 맞게 범위 밖으로 적는다(지난 gaps 2 닫힘). 새 꼴 하나가 문장보다 넓다 (05-REVIEW IN-10 재현): `fencedLines` 는 펜스 안에서 `trim()` 한 줄이 펜스 문자뿐이면 들여쓰기와 상관없이 펜스를 닫는다. CommonMark 의 닫는 펜스는 세 칸까지라 네 칸 들여 쓴 ``` 줄 뒤의 값은 렌더링된 펜스 코드 블록 안에 있는데, 382행은 '펜스 코드 블록 안에서 키가 줄 머리에 오는 … 줄의 값을 견준다' 고 하고 범위 밖 목록(따옴표 키 · 콜론 앞 공백 · flow · 네 칸 들여 쓴 코드 블록 · 인용 안 펜스)에 이 꼴이 없다. 함수 단위: README 330행 뒤에 `    ```` 한 줄, 333(→334)행 `      ref: v1.9.0` (`git diff --numstat` `2/1`) → `passed=true`; 대조(``` 줄 없이 333행만) → `passed=false` · `ref: v1.9.0`. 개연성은 낮다(YAML 예시 안의 ``` 줄)."
    artifacts:
      - path: "README.md"
        issue: "382행 범위 밖 목록에 펜스 안의 네 칸 들여 쓴 펜스 줄이 없다"
      - path: "example/README.md"
        issue: "116 · 395행 — 위와 같음 (549행은 (d′) 쪽 정의를 이미 적는다)"
      - path: "tool/verify.dart"
        issue: "`fencedLines` 문서 주석(1502행 부근) · `checkShippedComposition` 문서 주석의 (f) · (g) 범위 밖 문장"
    missing:
      - "G2-Q2 · G3-Q2 와 같은 길이면 문장만: 382 · 116 · 395행과 두 문서 주석의 범위 밖 목록에 '펜스 안에서 네 칸 이상 들여 쓴 ``` · ~~~ 줄은 그 펜스를 닫는 것으로 보아 그 뒤의 같은 블록 값은 견주지 않는다' 를 더한다. 코드로 닫는 쪽(닫는 줄 들여쓰기 세 칸까지, `markFencedLines` 와 함께)은 새 승인이 필요하다"
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
  - test: "검사 범위를 말하는 문장(README 378 · 379 · 382행, `example/README.md` 116 · 395 · 436 · 549행)을 읽고, 검사가 실제로 보는 범위를 오해 없이 전하는지 본다 (위 gaps 를 고친 뒤)"
    expected: "문장이 말하는 범위와 지워 보기 기록이 같고, 읽는 사람이 받지 않는 보호를 기대하지 않는다"
    why_human: "05-10-SUMMARY coverage D6 (human_judgment: true) — 자동 검증은 글자의 있고 없음만 본다"
---

# Phase 5: Documentation 검증 보고서 (3회차 gap 수정 뒤 재검증)

**Phase 목표:** 소유자가 몇 달 뒤 README 만 보고 설치, 프리셋 선택, 규칙 재정의, 버전 올리기를 그대로 따라 할 수 있고, README / CHANGELOG / YAML 주석이 실제 설정과 일치하며 그 일치가 검증으로 지켜진다
**검증 시각:** 2026-10-14T14:02:53Z
**상태:** gaps_found
**재검증:** 예 — 3회차 gap 수정 05-12 · 05-13 뒤 (이전 gaps_found 62/66)

방법: `T=$(mktemp -d)` 아래에 `git clone --local` 복제본 둘(`$T/repo` 는 전체 실행, `$T/repo2` 는 함수 단위)을 만들고 각각 루트에서 `fvm dart pub get --no-example` 을 돌렸다 (Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9). 함수 단위는 `$T/h` 의 하네스(`import '../../repo/tool/verify.dart' as v;`, package:yaml 3.1.4 의 `loadYaml` 로 YAML 이 읽는 값을 함께 찍음)로, analyzer 대조는 `$T/p` 의 작은 프로젝트로 했다. 기준 실행 `fvm dart run tool/verify.dart` 는 종료 코드 0 · `점검 통과 (10개 중 10개)` (69초). 입력을 바꾼 전체 실행 14회, 함수 단위 20여 회. 변형마다 `git diff --numstat` 으로 의도한 줄 수를 보고 실행 뒤 `git checkout -- .` 로 되돌렸으며, 마지막 전체 실행(되돌린 뒤)도 10개 중 10개였다. 끝에 두 복제본의 `git status --porcelain` 0줄을 보고 `$T` 를 지웠다. 원격 확인은 작업 트리에서 읽기 전용 명령만 썼고, 작업 트리는 GSD 도구 상태 넷 밖의 변경이 없다 (이 보고서 제외). `05-REVIEW.md` 의 기록은 증거로 쓰지 않았다 — 판정한 주장은 모두 다시 돌렸다.

## 목표 달성

### 관찰 가능한 참 (Observable Truths)

ROADMAP 성공 기준 5개, 첫 회차 plan truth 20개, gap plan 05-07 (9) · 05-08 (8) · 05-09 (11) · 05-10 (9) · 05-11 (4) · 05-12 (8) · 05-13 (4) — 모두 78개.

**성공 기준 (ROADMAP)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| SC1 | README 의 설치 안내와 유형별 include 블록을 그대로 복사해 `ref: vX.Y.Z` 로 추가할 수 있다 | ✓ VERIFIED | 회귀: 05-12 는 README 382행만 바꿨다 (`git diff --numstat d2d74c4 HEAD -- README.md` `1/1`); 설치 블록 `ref: v2.0.0` 그대로. 실제 tag 설치는 Phase 6 (Deferred) |
| SC2 | 끄기 · 버전 올리기 · `ref: main` → tag · 문제 해결 절, 재정의가 Phase 3 fixture 와 같다 | ✓ VERIFIED | 회귀: 절 제목 그대로, `fixtures` 는 `6d64bee` 와 같고 기준 실행 `[4/10]` · `[10/10]` 통과 |
| SC3 | README 의 규칙 · 설정 설명이 실제 YAML 과 일치하고, 규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 | ✗ FAILED | **앞 절반은 참:** 기준 실행 `[3/10]` 통과. **지난 gap 은 닫혔다:** M79 · M80 · M81 · M82 전체 실행 모두 `[3/10]` 실패, M83 ~ M85 `passed=false`. **뒤 절반은 새 입력에서 거짓:** 여러 줄 스칼라 안의 가짜 줄 — WR-16 (문서가 받지 않는 규칙을 켰다고 적어도 10/10), R1 · R2 (사용 프로젝트에 닿는 옵션을 문서가 '없음' 이라 해도 10/10). gaps 1번 |
| SC4 | CHANGELOG 최상단 새 항목(Phase 1 형식), 1.0.0 ~ 1.3.0 사이 보완 | ✓ VERIFIED | `git diff --quiet e46cff4 HEAD -- CHANGELOG.md` |
| SC5 | 배포 YAML 머리 주석이 실제 구성을 설명, 보일러플레이트 없음 | ✓ VERIFIED | `git diff --quiet e46cff4 HEAD -- lib` |

**첫 회차 plan truth (20) — 회귀 확인**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 01-1 · 01-2 · 01-4 ~ 01-6 | plugin 줄 끝 주석, 선언 삭제 70, 읽지 못하는 줄 70, `stripPlugins`, M32 ~ M37 기록 | ✓ VERIFIED | 기준 실행 10/10; 회귀 M37 전체 실행 rc 1 · `[2/10]` `:8  warning  deprecated_lint  (unnecessary_await_in_return)` · 10개 중 2개; M33 (마지막 줄바꿈 삭제) 10/10 |
| 01-3 | `lib/codegen.yaml` · `lib/riverpod.yaml` 에 규칙을 적으면 실패 — README 비교가 `lib/base.yaml` 하나만 봐도 빈자리가 없다 | ✓ VERIFIED | M83 (CR 뒤 `linter:`) `passed=false` · `4행: linter:` · `에 규칙이 있다 (1)`. 지난 gap 이 닫혔다. 여러 줄 스칼라로는 진짜 최상위 `linter:` 를 숨길 수 없다 — YAML 의 최상위 키 줄은 열 0 이라 reader 도 늘 본다(최상위 `(a′)` 가 잡음). 숨길 수 있는 것은 최상위 키 바로 아래 · `analyzer:` 의 `language:` 다 (gaps 1번) |
| 02-1 ~ 02-5 | 머리 주석 다섯, 템플릿 없음, 규칙 81줄, riverpod 주석, `.claude/CLAUDE.md` 71 · 181행 | ✓ VERIFIED | `lib` (`e46cff4`) · `.claude/CLAUDE.md` (`403c584`) 와 diff 0 |
| 03-x · 04-4 ~ 04-6 | README 절 · 표시 구역, CHANGELOG `### 올리기 전에` · `### 그 밖의 변경`, 01 WR-05 fixed | ✓ VERIFIED | CHANGELOG 불변, README 는 382행만 바뀜 |
| 05-1 ~ 05-3 · 06-1 ~ 06-3 | 첫 push, 비공개 점검, GitHub verify, M38 ~ M42 기록 | ✓ VERIFIED | `example/README.md` 의 `d2d74c4` 대비 변경은 116 · 395 · 518 · 549행과 새 소절뿐, 지운 `| M` 행 0 |

(묶은 행도 20개로 센다 — 실패 없음.)

**gap plan 05-07 · 05-08 · 05-09 (28) — 회귀 확인**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 07-1 ~ 07-6 · 07-8 · 07-9 | 옛 README 꼴, 구역 안 다섯 꼴, flow 70, 블록 꼴 실패, 기준 10/10, `readMarkerBlock`, M47 ~ M50 | ✓ VERIFIED | 회귀 M45 전체 실행 rc 70 · stdout 단계 줄 없음 · stderr `lib/codegen.yaml 의 10행: `linter:` 줄에 값이 붙어 있다 …` |
| 07-7 | README 378행 불릿의 단정이 참이 된다 | ✗ FAILED | 378행 '그 바로 아래의 다른 키(`lib/codegen.yaml` 의 `language:`, `lib/riverpod.yaml` 의 다른 plugin 등)는 `[3/10]` 단계가 실패' — R1 (codegen 의 숨은 `language:`) 전체 실행 10/10, R3 (riverpod 의 숨은 `custom_lint`) 함수 단위 `passed=true`. gaps 1번 |
| 08-1 ~ 08-8 | RULES.md 표 · 주소 · 펜스 · 옵션 reader, M51 ~ M62 | ✓ VERIFIED | 적힌 입력 그대로; 회귀 M61 전체 실행 rc 70 · stderr `lib/base.yaml 의 `language:` 블록의 98행을 읽지 못했다 … strict-casts: yes`; `RULES.md` 는 `76dee2f` 와 같다 |
| 09-1 ~ 09-11 | plugin 선언 · pubspec reader, 문장, 처리 기록, push | ✓ VERIFIED | 적힌 입력(따옴표 version · 따옴표 선언 · 맵 꼴) 그대로; `pubspec.yaml` 은 `968a5bb` 와 같다. pubspec reader 의 여러 줄 스칼라 입력은 05-09 의 truth 밖이다 — gaps 1번에서 다룬다 |

**gap plan 05-10 (9)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 10-1 ~ 10-7 · 10-9 | M68 ~ M78 의 적힌 결과, 회귀 입력, (d′) 경계, 고정 커밋 | ✓ VERIFIED | 적힌 입력 그대로 (지난 재검증 이후 해당 코드 줄 불변 — 05-12 의 코드 변경은 줄 나누기뿐, 아래 12-5); 기준 실행 10/10; 고정 커밋 diff 0 |
| 10-8 | README 378 · 382행, `example/README.md` 116 · 358 · 395 · 436행, `tool/verify.dart` 의 (e) ~ (g) 주석이 실제 동작 · 범위를 말한다 | ✗ FAILED | **지난 꼴은 닫혔다:** WR-07 · WR-13 · WR-14 입력을 함수 단위로 돌려 `passed=true` — 문장이 그 꼴을 범위 밖으로 적는다. **새 입력에서 거짓:** 378 · 379행과 116행의 닫힌 목록 구절 (gaps 1번 — R1 · R3 · WR-16), 116행 (g) 구절 '`ref: vX.Y.Z` 가 `pubspec.yaml` 의 version 과 같은지' (WR-15 전체 실행 10/10), 382 · 116 · 395행 (f) · (g) 구절이 펜스 안의 네 칸 들여 쓴 ``` 줄을 적지 않음 (gaps 2번 — IN-10) |

**gap plan 05-11 (4)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 11-1 ~ 11-4 | 그때의 처리 기록 · CHANGELOG · 비공개 점검 · push | ✓ VERIFIED | 지난 재검증 그대로; `b8519d4` 는 `c2f275a` 의 조상 |

**gap plan 05-12 (8)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 12-1 | M79 · M80 의 실패 꼴 | ✓ VERIFIED | M79 전체 실행 rc 1 · `[3/10]` 만 · `  + prefer_mixin  (base.yaml 에만)` 두 줄 · 10개 중 1개. M80 rc 1 · `[2/10]` `build/woody_rule_check/base/analysis_options.yaml:94  warning  incompatible_lint  (always_specify_types)` · `[3/10]` 실패 · 정답지 다섯 실패 · 10개 중 7개 |
| 12-2 | M81 · M82 의 실패 꼴 | ✓ VERIFIED | M81 rc 1 · `[3/10]` `10행:   language:` · `[5/10]` · `[9/10]` · `[10/10]` 실패 · 10개 중 4개. M82 rc 1 · `[3/10]` 만 · `12행: formatter:` · `10행:   language:` · 10개 중 1개 |
| 12-3 | M83 ~ M85 함수 단위 `passed=false` | ✓ VERIFIED | M83 `4행: linter:` · `에 규칙이 있다 (1)` · `prefer_mixin`; M84 `(2)` · `5행: formatter:` · `7행: plugins:`; M85 `7행:   custom_lint: ^0.7.0` |
| 12-4 | 줄 나누기 자리 여섯 + `pubspecReleaseVersion` 이 `splitYamlLines`, 함수 직접 호출 일곱 | ✓ VERIFIED | 주석 밖 `splitYamlLines(` 8개(정의 827행 · 쓰는 곳 842 · 961 · 1037 · 1111 · 1318 · 1418 · 1589행). 검증자가 같은 꼴의 입력을 직접 만들어 부름: `declared=[a]` · `options={strict-casts: true}` · `keys=[2행: formatter:]` · `crlf=[2행: formatter:]` · `strip=false` · `plugin=^3.1.9` (CR 로만 나눈 riverpod 조각) · `pubspec=2.0.0` (U+2028 뒤의 `version: 9.9.9`) |
| 12-5 | 코드 줄 변경은 줄 나누기뿐, (d′) ~ (g) 등 코드 줄 불변 | ✓ VERIFIED | `git diff d2d74c4 d771c0c -- tool/verify.dart` 의 주석 아닌 변경 줄은 `split('\n')` · `replaceAll('\r\n'` 줄, 연쇄 머리, `splitYamlLines` 줄, `pubspecReleaseVersion` 본문뿐; `d771c0c..HEAD` 의 `tool/verify.dart` 변경은 모두 주석 줄 |
| 12-6 | 회귀 없음, 378 · 379 · 116행 닫힌 목록 구절은 '고친 뒤 참이 되므로' 글자 그대로 | ✗ FAILED | **회귀 부분은 참:** 기준 실행 10/10, M37 · M33 · M45 · M61 앞 기록 그대로(위). **'고친 뒤 참' 은 거짓:** 그 구절은 R1 · R3 입력에서 거짓 (gaps 1번 — 같은 뿌리) |
| 12-7 | 382 · 116 · 395 · 518 · 549행과 (e) ~ (g) 주석이 새 구절을 말하고, 이 task 의 `tool/verify.dart` 변경은 주석 줄뿐 | ✓ VERIFIED | 구절 있음(382 · 116 · 395 · 549행 · 1871 ~ 1877행 문서 주석), 518행 `M35 · M37 · M46`; `d771c0c..d8b61b0` 의 코드 줄 변경 0. (그 문장이 새 입력 IN-10 에서 넓은 것은 10-8 · gaps 2번) |
| 12-8 | 고정 커밋 일곱 불변, M1 ~ M78 행 불변, 작업 트리 검증 10/10 | ✓ VERIFIED | `lib` · CHANGELOG (`e46cff4`) · RULES.md (`76dee2f`) · fixtures (`6d64bee`) · pubspec (`968a5bb`) · `.claude/CLAUDE.md` (`403c584`) · `tool/measure_rules.dart` (`812c477`) diff 0; `example/README.md` 지운 `| M` 행 0 |

**gap plan 05-13 (4)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 13-1 | 처리 기록 fixed 15 · skipped 7 · deferred 1 · open 0 · total 23 | ✓ VERIFIED | `git show c2f275a:…/05-REVIEW-DISPOSITION.md` 의 disposition 셈 15 · 7 · 1, `open: 0`, `total: 23`; WR-11 → `d771c0c`, WR-12 · WR-13 · WR-14 · IN-09 → `d8b61b0`; WR-06 deferred. 지금 파일의 open 4 (WR-15 · WR-16 · IN-10 · IN-11)는 그 뒤 재리뷰(`728ad29`)의 새 발견이다 |
| 13-2 | CHANGELOG 불변 | ✓ VERIFIED | `git diff --quiet e46cff4 HEAD -- CHANGELOG.md` |
| 13-3 | push 전 범위 비공개 점검 0 | ✓ VERIFIED | `git diff b8519d4 c2f275a` 의 더한 줄에서 절대 경로 꼴은 계획의 `<automated>` 정규식 원문 넷뿐; 공개 파일(README · example · tool · lib · RULES · CHANGELOG · fixtures)의 추적 파일에 절대 경로 꼴 0 (걸린 것은 무시 대상인 `.dart_tool/package_config.json` 뿐) |
| 13-4 | fast-forward push, `main` · tag · PR 불변, GitHub verify 성공 | ✓ VERIFIED | `git ls-remote origin`: 작업 브랜치 `c2f275a`, `main` `90a2736`, tag `v1.3.0` 하나; `b8519d4` → `c2f275a` 조상 관계, `c2f275a` 는 HEAD 의 조상; `gh pr list --state all` → `[]`; `gh run view 38568654401`: `completed` · `success` · push · headSha `c2f275a…`, 로그에 `[3/10] 배포 파일의 구성 … 통과` · `점검 통과 (10개 중 10개)` |

**점수:** 74/78 참 확인 (present · behavior-unverified 0). 실패 넷 가운데 SC3 · 07-7 · 12-6 과 10-8 의 378 · 379 · 116행 부분은 뿌리가 하나다 (gaps 1번 — reader 가 YAML 노드를 모름). 10-8 의 나머지는 문장 하나 (gaps 2번).

### Deferred Items

| # | 항목 | 다룰 phase | 근거 |
|---|------|-----------|------|
| 1 | README 의 `ref: v2.0.0` 블록으로 실제로 받는 것 (tag 가 아직 없다) | Phase 6 | 성공 기준 3 |

gaps 1 · 2 는 Phase 6 (tag · 릴리스 smoke test) 의 범위에 들지 않는다 — 미루지 않았다.

### 05-REVIEW 3회차 재리뷰 발견의 판정 (orchestrator 요청)

판정 기준은 지난 회차와 같다: 이 phase 가 말한 참(성공 기준, plan must_haves, README · `example/README.md` 의 "검사가 지킨다" 문장)이 그 입력에서 거짓이 되면 gap, 목표는 지키되 다듬을 점이면 경고. 소유자가 "문장을 검사 범위에 맞추고 검사는 그대로" 로 정한 (d′) · (e) ~ (g) 는 문장이 동작보다 넓은지만 본다. 모두 복제본에서 다시 돌렸다.

| 발견 | 재현 (검증자) | 판정 | 이유 |
|------|---------------|------|------|
| WR-15 `pubspecReleaseVersion` 이 여러 줄 따옴표 스칼라 안의 `version:` 줄을 읽음 | 전체 실행 (`pubspec.yaml` `3/1`, README `2/2`) rc 0 · `[3/10]` 통과 · 10/10. 함수 단위 reader `1.9.0`, loadYaml `2.0.0-dev`. 대조: README 만 `v1.9.0` 이면 `passed=false` · `pubspec.yaml 의 version (2.0.0) 과 다르다` | 🛑 gap (gaps 1번의 일부) | `example/README.md` 116행 '`ref: vX.Y.Z` 가 `pubspec.yaml` 의 version 과 같은지' 가 거짓 — README 의 설치 예시가 실제 버전과 다른데 10/10. 소유자는 G3-R2-Q1 로 이 reader 를 '숨긴 값이 아니라 진짜 값' 을 읽게 하기로 했다. (g) 는 G2-Q2 의 '문장을 범위에 맞춤' 대상이기도 하므로 문장으로 닫는 길(C)도 고를 수 있다 |
| WR-16 `declaredRuleNames` · `enabledLanguageOptions` 가 여러 줄 스칼라 안의 줄을 규칙 · 옵션으로 읽음 | 전체 실행: 따옴표 꼴 규칙 `prefer_mixin` + RULES.md · README 한 줄씩 → rc 0 · 10/10, loadYaml 의 `linter.rules` 에 없음. 함수 단위: 블록 스칼라 꼴 옵션 `strict-casts` + RULES.md 행 → `passed=true`, loadYaml 의 `analyzer` 는 `exclude` 하나 | 🛑 gap (gaps 1번) | README 379행 '어긋나면 검증이 실패한다' 와 SC3 가 거짓 — 문서가 받지 않는 규칙 · 옵션을 켰다고 적는데 10/10. 정방향이라 사용 프로젝트에 새 진단이 닿지는 않는다 |
| (반대 방향 — 오케스트레이터 요청) 여러 줄 스칼라 안의 가짜 줄로 진짜 옵션 · plugin 을 숨김 | R1 · R2 전체 실행 `strict-inference` rc 0 · 10/10; `strict-casts` 판은 `[3/10]` 통과 · 정답지 `invalid_assignment` 실패(R1 셋, R2 다섯) — 사용 프로젝트에 닿는다. analyzer 대조 `inference_failure_on_collection_literal` 2건 vs 0건. R3 함수 단위 `passed=true`, loadYaml 의 `plugins` 에 `custom_lint` | 🛑 gap (gaps 1번 — 가장 무거운 쪽) | 지난 세 gap 과 같은 쪽: 받지 않는 키 · 옵션 · plugin 이 사용 프로젝트에 닿는데 `[3/10]` 이 통과. README 378행 · `example/README.md` 116행의 닫힌 목록 단정이 거짓 |
| IN-10 펜스 안의 네 칸 들여 쓴 ``` 줄이 `fencedLines` 의 펜스를 닫음 | 함수 단위 `2/1` → `passed=true`; 대조 `passed=false` · `ref: v1.9.0` | ⚠️ gap (partial — gaps 2번) | 코드는 G2-Q2 · G3-Q2 로 그대로 두기로 한 보조 검사다. 그러나 382 · 116 · 395행이 이 꼴을 범위 밖으로 적지 않아 '펜스 코드 블록 안의 값을 견준다' 가 이 입력에서 거짓 — 지난 회차 WR-14 와 같은 판정 기준. 문장 한 구절로 닫힌다 |
| IN-11 `stripPlugins` 문서 주석의 '복사본의 줄 수 … 가 원본과 같다' | 함수 단위: 지금 `lib/riverpod.yaml` 원본 5줄, 복사본 `splitYamlLines` 4줄 | ℹ️ 정보 | 동작에는 영향 없음 — 내용이 있는 줄의 번호는 같아 `[2/10]` 진단 · `readRuleNameAt` 이 맞다 (M37 `:8 … (unnecessary_await_in_return)`, M80 `:94 … (always_specify_types)` 로 확인). 주석 한 줄을 '줄 번호가 같다 (끝의 빈 줄은 빠질 수 있다)' 로 고치면 된다 |
| WR-07 · WR-08 · WR-09 · WR-12 · WR-13 · WR-14 · IN-08 (skipped, G2-Q2 · G3-Q2 · G3-Q3) | WR-07 (`packages:` 오타) · WR-13 (`ref : v1.9.0`) · WR-14 (`package:woody-lints/riverpod`) 함수 단위 `passed=true`; 지금 문장을 읽어 견줌 | 범위 한계로 받아들임 (문장은 동작보다 넓지 않다) | README 382행, `example/README.md` 116 · 395 · 549행, `tool/verify.dart` 1871 ~ 1877행이 scheme 오타 · `package:` 뒤 공백 · 확장자가 다른 다른 패키지 주소 · 문장 부호 · 따옴표 키 · 콜론 앞 공백 · flow · 네 칸 들여 쓴 블록 · 인용 안 펜스 · HTML 주석 안 `#` 줄 · 네 칸 들여 쓴 펜스(d′ 쪽)를 범위 밖으로 맞게 적는다. 예외는 IN-10 하나(위) |
| WR-06 (deferred, D-09) | `.claude/CLAUDE.md` 가 `403c584` 그대로 | 미룸 그대로 | 마일스톤 끝 `/gsd-map-codebase` |

**결함의 꼴과 닿는 reader (gaps 1번).** 같은 모양이 네 번째다 — 1회차는 읽지 못하는 줄 건너뛰기, 2회차는 철자가 다른 키, 3회차는 CR 줄 경계, 이번은 **줄이 속한 YAML 노드**다. reader 는 줄 단위로 구조를 짐작하므로 YAML 이 글자 값으로 읽는 줄(여러 줄 따옴표 · 블록 스칼라 안)을 구조로 읽고, 그 가짜 줄이 reader 의 상태(블록 경계 · '바로 아래' 들여쓰기 · 첫 `version:`)를 바꾼다.

| reader | 쓰는 검사 | 정방향 (문서 > 실제) | 역방향 (실제 > 문서) |
|--------|-----------|----------------------|----------------------|
| `declaredRuleNames` | (b′) · (b) · (c) 규칙 표 · (d) README 목록 | WR-16 규칙 — 재현 | 찾지 못함 (`linter:` 블록 안에서는 스칼라를 열 줄이 70 으로 멈춘다) |
| `enabledLanguageOptions` | (c) 켠 옵션 표 | WR-16 옵션 (블록 스칼라 · 따옴표) — 재현 | R2 (가짜 열 0 `include:` 로 `analyzer:` 블록을 닫음) — 재현 |
| `findUnexpectedKeys` | (a′) | — | R1 (가짜 `analyzer:` · ` exclude:` 로 '바로 아래' 를 한 칸으로), R3 (가짜 `plugins:` · ` riverpod_lint:`) — 재현. 같은 최상위 키 중복을 막지 않는 것이 열쇠 |
| `pubspecReleaseVersion` | (g) | WR-15 — 재현 | (같은 함수 — 스칼라 안의 줄이 먼저 오면 그 값) |
| `readShippedPluginConstraint` · `stripPlugins` | (f) · `[4/10]` · `[2/10]` 복사본 | 같은 꼴(첫 줄을 읽음) — 헛통과는 재현하지 않음 | R3 에서는 진짜 `^3.1.9` 를 읽었다 |

**범위 한계로 적는 것 (소유자가 범위 밖으로 둔 것 — 판정하지 않음):** `tool/measure_rules.dart` 의 줄 나누기(G3-R2-Q2 — 측정 도구, 배포 · 검증 명령 밖; `812c477` 그대로), `stripPlugins` 끝의 `^plugins:` 여러 줄 확인(U+2028 에서 거짓 실패 쪽 — 헛통과 아님), (e) 의 여러 줄 정규식, WR-06 (deferred — D-09). 지난 회차의 Round 2 범위 밖 목록(「받는 규칙」 절의 표 · 산문 · HTML 규칙 이름, `lib/base.yaml` 의 `include:` 값, 둘째 마커 쌍, `lib/base.yaml` 의 `analyzer:` 아래 키, codegen `errors:` 의 심각도 재정의, CHANGELOG 98행, README 214행)도 그대로다. 단 gaps 1번의 R2 는 `lib/base.yaml` 의 `analyzer:` 아래 '다른 키' 가 아니라 `language:` 다 — `enabledLanguageOptions` 가 읽고 RULES.md 의 켠 옵션 표와 견주는, 범위 안의 키다.

### Required Artifacts

| Artifact | 기대 | 상태 | 세부 |
|----------|------|------|------|
| `tool/verify.dart` | `splitYamlLines` 와 일곱 자리, (e) ~ (g) 주석 | ⚠️ 있음 · 연결됨 · 일부 fail-open | 줄 경계는 YAML 과 같다(지난 gap 닫힘). 줄이 속한 노드를 몰라 여러 줄 스칼라 입력에서 정방향 · 역방향 헛통과 (gaps 1번); (f) · (g) 문장 하나가 넓다 (gaps 2번) |
| `example/README.md` | `### 추가 실측 — CR 하나로 나뉜 줄 (05-12)` (M79 ~ M85), 116 · 395 · 518 · 549행 | ✓ 있음 (문장 일부 ⚠️) | 소절과 기록 행이 검증자 실행과 같다; 116행의 닫힌 목록 · (g) 구절이 gaps 1번 입력에서 거짓, 116 · 395행 (f) · (g) 가 IN-10 에서 넓다 |
| `README.md` | 382행 '글자 그대로인 줄만 후보' | ✓ 있음 (⚠️) | 378 · 379행 (gaps 1번), 382행 (gaps 2번) |
| `05-REVIEW-DISPOSITION.md` | 05-13 시점 open 0 | ✓ VERIFIED | `c2f275a` 시점 그대로; 지금 open 4 는 재리뷰 발견 |

### Key Link Verification

| From | To | Via | 상태 | 세부 |
|------|----|-----|------|------|
| `tool/verify.dart` | 조각 셋 · `pubspec.yaml` | `splitYamlLines` 로 나눈 reader 일곱 | ⚠️ PARTIAL | 줄 경계는 analyzer · pub 과 같다 (M79 ~ M85, 함수 직접 호출 일곱). 줄의 소속(여러 줄 스칼라)은 다르다 |
| `tool/verify.dart` | `example/README.md` | M79 ~ M85 기록 | ✓ WIRED | 검증자 실행(M79 ~ M82 전체, M83 ~ M85 함수 단위, 회귀 넷 전체)이 기록과 같다 |
| `05-REVIEW-DISPOSITION.md` | 05-12 의 task 커밋 | WR-11 → `d771c0c`, WR-12 ~ WR-14 · IN-09 → `d8b61b0` | ✓ WIRED | `d771c0c` 는 `tool/verify.dart` · `example/README.md`, `d8b61b0` 은 README · `example/README.md` · `tool/verify.dart` 주석을 바꿨다 |
| 로컬 브랜치 | origin | `git push origin gsd/v2.0-package-rework` | ✓ WIRED | origin `c2f275a`, run 38568654401 success |

### Behavioral Spot-Checks (전체 실행 — 검증자 복제본)

| 동작 | 결과 | 상태 |
|------|------|------|
| 기준 실행 | rc 0 · 10/10 (69초) | ✓ PASS |
| M79 · M80 · M81 · M82 (지난 gap) | rc 1 · 각각 10개 중 1 · 7 · 4 · 1개, `[3/10]` 실패 | ✓ PASS (닫힘) |
| 회귀 M37 · M33 · M45 · M61 | rc 1 (2/10) · rc 0 (10/10) · rc 70 · rc 70, 문구 앞 기록 그대로 | ✓ PASS |
| WR-15 (pubspec 여러 줄 따옴표 + README `v1.9.0`) | rc 0 · 10/10 | ✗ FAIL (gaps 1) |
| WR-16 규칙 (base 끝 따옴표 스칼라 안 `prefer_mixin` + 문서 둘) | rc 0 · 10/10 | ✗ FAIL (gaps 1) |
| R1 codegen 숨은 `language:` (`strict-inference` / `strict-casts`) | rc 0 · 10/10 / rc 1 · `[3/10]` 통과 · 정답지 셋 `invalid_assignment` | ✗ FAIL (gaps 1) |
| R2 base 숨은 `language:` (`strict-inference` / `strict-casts`) | rc 0 · 10/10 / rc 1 · `[3/10]` 통과 · 정답지 다섯 `invalid_assignment` | ✗ FAIL (gaps 1) |
| 되돌린 뒤 | rc 0 · 10/10 | ✓ PASS |

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
| DOCS-06 | 05-03 · 05-07 · 05-09 · 05-10 · 05-12 · 05-13 | ✓ SATISFIED (지금 상태) | 지금 README 의 규칙 · 설정 설명은 YAML 과 같다(기준 실행 `[3/10]`). 검사를 설명하는 문장의 넓음은 gaps 1 · 2 와 함께 고친다 |
| DOCS-07 | 05-04 · 05-09 | ✓ SATISFIED | SC4 |
| DOCS-08 | 05-04 | ✓ SATISFIED | 변경 없음 (사람 확인 3번) |
| DOCS-09 | 05-04 | ✓ SATISFIED | 변경 없음 |
| DOCS-10 | 05-01 · 05-02 | ✓ SATISFIED | SC5 |
| VERIFY-06 | 05-01 · 05-03 · 05-05 ~ 05-13 | ✗ BLOCKED | gaps 1번 — 문서와 다른 규칙 · 옵션 · plugin 이 여러 줄 스칼라 입력으로 10/10 |

ORPHANED 없음 — REQUIREMENTS.md 가 Phase 5 에 매긴 11개가 모두 plan 의 `requirements` 에 있다. REQUIREMENTS.md 의 표시(VERIFY-06 · DOCS-06 `Complete`, 나머지 아홉 `Gaps Found`)는 이 증거와 다르다 — VERIFY-06 은 BLOCKED, 나머지 열은 SATISFIED 다.

### Anti-Patterns

| 파일 | 줄 | 패턴 | 심각도 | 영향 |
|------|----|------|--------|------|
| `tool/verify.dart` | 951 · 1029 · 1101 · 1587 | 줄 단위 reader 가 여러 줄 스칼라 안의 줄을 구조로 읽고, 같은 키 중복을 막지 않음 | 🛑 Blocker | gaps 1번 (전체 실행 WR-15 · WR-16 · R1 · R2 가 증거) |
| `tool/verify.dart` | 1503 ~ 1529 | 펜스를 들여쓰기와 상관없이 닫음 — 문장이 이 꼴을 적지 않음 | ⚠️ Warning | gaps 2번 (IN-10) |
| `tool/verify.dart` | 829 ~ 833 | `stripPlugins` 주석의 '줄 수 … 원본과 같다' | ℹ️ Info | IN-11 |

`TBD` · `FIXME` · `XXX` 표식: `tool/verify.dart` · `README.md` · `example/README.md` 에 0개. 재검증 증거 gate: gaps 1번은 이번 회차에 바뀐 `tool/verify.dart` 의 reader(05-12 가 고친 일곱 자리 가운데 넷)에 걸리고, 전체 실행이라는 재현 가능한 증거(WR-15 · WR-16 · R1 · R2 의 rc 와 출력)가 있어 blocker 로 둔다. gaps 2번은 05-12 가 고친 382 · 116 · 395행의 문장에 걸리고 함수 단위 재현이 있다. 증거 없는 새 범위 발견은 없다 (Advisory 없음).

### Advisory (New Scope, Unevidenced)

없음.

### 금지 사항(prohibitions) 확인 (판단 등급 — 검증자의 비권위 판정)

기계로 가를 수 있는 것은 직접 확인했고 어긴 것은 없다.

- 05-12: 일곱 자리가 모두 `splitYamlLines` 를 쓴다(한 reader 만 CR 을 바꾸지 않음, 정규식에 문자를 더하지 않음); (d′) · (e) ~ (g) · `fencedLines` · `unquotedScalar` · `findMarkerRange` · `markFencedLines` · `findListLinesOutsideMarkers` 의 코드 줄은 변경 diff 에 없다; `tool/measure_rules.dart` 는 `812c477` 그대로; 배포 YAML · RULES.md · CHANGELOG · pubspec · fixtures · `.claude/CLAUDE.md` 고정 커밋 그대로; `example/README.md` M1 ~ M78 행 그대로; gap 1 override 를 적지 않았다. "지워 보기는 복제본에서" 는 작업 트리와 이력에 변형 흔적이 없다는 것까지만 확인할 수 있다.
- 05-13: push 는 fast-forward (`b8519d4` → `c2f275a`), 원격 `main` `90a2736` · tag `v1.3.0` 하나 · PR 0; 처리 기록의 앞 회차 행 · WR-06 `deferred` 그대로; 05-13 의 커밋(`c2f275a`)은 처리 기록 하나만 바꿨다.

### Human Verification Required

gap 을 닫은 뒤에도 남는 사람 확인 다섯이다 (frontmatter `human_verification`).

1. **README 를 처음부터 따라 하기** — 설치 → 프리셋 고르기 → 끄기 세 층 → 버전 올리기 세 갈래.
2. **단정 / 출처 문장 단위 확인** — 끄기 · 생성 파일 제외 · 버전 올리기 · 문제 해결.
3. **CHANGELOG 복원 일곱 항목과 `git show` diff 대조** — CHANGELOG 는 `e46cff4` 뒤로 불변.
4. **외부 링크 넷 열기.**
5. **검사 범위를 말하는 문장의 읽힘** — gaps 1 · 2 를 고친 뒤.

### Gaps 요약

**지난 gap 둘은 닫혔다.** CR 하나로 나뉜 줄에 숨긴 규칙 · 옵션 · 키 · plugin 은 이제 `[3/10]` 에서 실패한다 — 검증자가 M79 ~ M82 를 전체 실행으로, M83 ~ M85 와 함수 직접 호출 일곱을 하네스로 다시 돌려 기록과 같았다. 회귀 넷(M37 · M33 · M45 · M61)도 앞 기록 그대로이고 GitHub verify 도 10/10 이다. 지난 gaps 2 의 문장(WR-13 · WR-14)도 이제 동작과 맞다.

**새 gap 하나 (blocker, 뿌리 하나 — 같은 모양의 네 번째):** 줄 경계는 YAML 과 같아졌지만, reader 는 **그 줄이 YAML 의 어느 노드에 속하는지** 모른다. 여러 줄 따옴표 · 블록 스칼라 안의 줄을 키 · 규칙 · 옵션 · `version:` 으로 읽고, 같은 키가 두 번 나온 줄(YAML 에서는 늘 스칼라 안의 가짜 줄)을 막지 않는다. 그래서 두 방향 모두 10/10 이다 — 문서가 받지 않는 규칙 · 옵션 · 버전을 적어도 통과하고(WR-15 · WR-16), 가짜 줄로 블록 경계나 '바로 아래' 들여쓰기를 옮기면 사용 프로젝트에 닿는 옵션 · plugin 을 문서가 적지 않아도 통과한다(R1 · R2 · R3 — 지난 세 gap 과 같은 쪽). 개연성은 낮다(일부러 꾸며야 나오는 입력). 철자 · 꼴을 하나씩 막는 수정이 네 번째로 같은 모양을 만났으므로, 다음 수정은 **꼴의 종류를 닫는 쪽**을 권한다 — 소유자가 (A) D-11 안에서 여러 줄 스칼라 · 중복 키를 받지 않게 하거나, (B) D-11 을 다시 정해 `dev_dependencies` 의 `yaml` 로 reader 결과를 YAML 과 견주거나, (C) 받아들이고 문장에 '조각은 한 줄 스칼라로 적는다' 를 적는다. (C) 를 고르면 아래 override 를 쓸 수 있다.

```yaml
overrides:
  - must_have: "규칙 · 설정 설명이 실제 YAML 과 일치하고 어긋나면 검증 명령이 실패한다 — README 378행 · 379행 · example/README.md 116행의 단정"
    reason: "{여러 줄 스칼라(따옴표 · 블록) 안에 YAML 구조처럼 보이는 줄을 두는 입력은 이 저장소의 편집 경로에서 생기지 않는다고 보고 받아들인다 — README 378 · 379행과 example/README.md 116행에 '조각 · pubspec.yaml 은 한 줄 스칼라로 적는다 — 여러 줄 스칼라 안의 줄은 검사가 YAML 과 다르게 읽는다' 를 적는다}"
    accepted_by: "{name}"
    accepted_at: "{ISO timestamp}"
```

**문장 하나 (gaps 2번, partial):** README 382 · `example/README.md` 116 · 395행과 (f) · (g) 주석이 펜스 안의 네 칸 들여 쓴 ``` 줄(그 줄이 `fencedLines` 의 펜스를 닫는다)을 범위 밖으로 적지 않는다 (IN-10). G2-Q2 · G3-Q2 의 길대로 문장 한 구절로 닫힌다.

**정보:** IN-11 (`stripPlugins` 주석의 줄 수 — 동작 영향 없음).

지금 상태의 README · CHANGELOG · YAML 주석은 실제 설정과 일치한다 — 실패한 것은 "그 일치가 검증으로 지켜진다" 의 한 꼴(여러 줄 스칼라로 꾸민 입력)과, 검사 범위를 말하는 문장 하나다.

---

_Verified: 2026-10-14T14:02:53Z_
_Verifier: Claude (gsd-verifier)_
