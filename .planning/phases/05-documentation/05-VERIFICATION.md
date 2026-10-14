---
phase: 05-documentation
verified: 2026-10-14T22:28:34Z
status: human_needed
score: 92/92 must-haves verified
covered_files:
  - ".claude/CLAUDE.md"
  - ".claude/skills/spike-findings-woody-lints/SKILL.md"
  - ".claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md"
  - ".claude/skills/spike-findings-woody-lints/references/rule-status-check.md"
  - ".github/workflows/verify.yml"
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
  - ".planning/phases/05-documentation/05-14-PLAN.md"
  - ".planning/phases/05-documentation/05-14-SUMMARY.md"
  - ".planning/phases/05-documentation/05-15-PLAN.md"
  - ".planning/phases/05-documentation/05-15-SUMMARY.md"
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
covered_digest: "v3:sha256:5d14b9894f49e21e71114febff762e53f972729c72da1bc707288dbbaa437da8"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 74/78
  gaps_closed:
    - "지난 gaps 1 (여러 줄 스칼라 안의 줄을 구조로 읽음) — 검증자 복제본 전체 실행: M86 (WR-16 규칙 꼴) · M87 (WR-15) · M88 (R1) · M89 (R2) 모두 종료 코드 1 · `[3/10]` 만 실패 · `점검 실패 (10개 중 1개)` · (h) 블록이 기록 글자 그대로; 함수 단위 M90 (R3) · M91 (블록 스칼라) · 선언만 다른 입력 · 같은 키 두 번 모두 `passed=false`; 실패 방향 — `tool/verify.dart` 만 `d8b61b0` 으로 되돌리면 M90 · M91 이 `passed=true`"
    - "지난 gaps 2 (IN-10 문장) — README 382행 · `example/README.md` 116 · 395행 · `fencedLines` · `checkShippedComposition` 문서 주석에 '그 펜스를 닫는 것으로 보아' 구절; 같은 입력(330행 뒤 네 칸 들여 쓴 펜스 줄 + 333행 `v1.9.0`)이 함수 단위 `passed=true` — 문장이 말한 범위 밖 그대로"
  gaps_remaining: []
  regressions: []
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
  - test: "검사 범위를 말하는 문장(README 378 · 379 · 380 · 382행, `example/README.md` 11 · 116 · 395 · 436 · 549행, (05-14) 소절의 읽는 법)을 읽고, 검사가 실제로 보는 범위를 오해 없이 전하는지 본다"
    expected: "문장이 말하는 범위와 지워 보기 기록이 같고, 읽는 사람이 받지 않는 보호를 기대하지 않는다"
    why_human: "05-10-SUMMARY coverage D6 (human_judgment: true) — 자동 검증은 글자의 있고 없음만 본다"
  - test: "05-14 · 05-15 의 금지 사항(prohibitions, judgment 등급 — 모두 `flagged: true`)을 아래 「금지 사항 확인」 의 비권위 판정과 견주어 받아들일지 정한다"
    expected: "기계로 가를 수 있는 부분(고정 커밋 diff 0, 지운 코드 줄 0, push 범위 · 원격 상태)은 검증자가 확인했다 — 남는 것은 '복제본에서만 실험했다' 같은 과정 주장의 수용"
    why_human: "judgment 등급 금지 사항은 사람이 해소한다 (ADR-550 D4) — 검증자 판정은 권위가 없다"
---

# Phase 5: Documentation 검증 보고서 (4회차 gap 수정 뒤 재검증)

**Phase 목표:** 소유자가 몇 달 뒤 README 만 보고 설치, 프리셋 선택, 규칙 재정의, 버전 올리기를 그대로 따라 할 수 있고, README / CHANGELOG / YAML 주석이 실제 설정과 일치하며 그 일치가 검증으로 지켜진다
**검증 시각:** 2026-10-14T22:28:34Z
**상태:** human_needed
**재검증:** 예 — 4회차 gap 수정 05-14 · 05-15 뒤 (이전 gaps_found 74/78)

방법: 운영체제 임시 폴더 아래 `mktemp -d` 로 만든 폴더 하나 안에 `git clone --local` 복제본 셋을 두었다 — 전체 실행용(`repo`), 함수 단위용(`fn`), CI 꼴 첫 실행 · 종료 코드 254 재현용(`ci`). Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, `yaml` 3.1.4. `ci` 는 `pub get` 없이 바로 돌렸고, `repo` · `fn` 은 `fvm dart pub get --no-example` 을 먼저 돌렸다. 함수 단위는 같은 폴더의 하네스(`tool/verify.dart` 를 import 해 `checkShippedComposition` 을 부르고 `loadYaml` 결과도 찍음)를 `fvm dart run --packages=<복제본의 .dart_tool/package_config.json>` 으로 불렀다. 변형마다 `git diff --numstat` 으로 의도한 줄 수를 보고, 실행 뒤 `git checkout -- .` 로 되돌렸다. 전체 실행 14회(기준 셋 포함), 함수 단위 17회. 끝에 세 복제본의 `git status --porcelain` 0줄을 보고 폴더째 지웠다. 작업 트리에서는 `tool/verify.dart` 를 돌리지 않았고(읽기 전용 git · gh 명령만), 작업 트리는 GSD 도구 상태 넷 밖의 변경이 없다 (이 보고서 제외). `05-REVIEW.md` · SUMMARY 의 기록은 증거로 쓰지 않았다 — 판정한 주장은 모두 다시 돌렸다.

## 목표 달성

### 관찰 가능한 참 (Observable Truths)

ROADMAP 성공 기준 5개, 첫 회차 plan truth 20개, gap plan 05-07 (9) · 05-08 (8) · 05-09 (11) · 05-10 (9) · 05-11 (4) · 05-12 (8) · 05-13 (4) · 05-14 (10) · 05-15 (4) — 모두 92개.

**성공 기준 (ROADMAP)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| SC1 | README 의 설치 안내와 유형별 include 블록을 그대로 복사해 `ref: vX.Y.Z` 로 추가할 수 있다 | ✓ VERIFIED | 회귀: 05-14 는 README 380 · 382행만 바꿨다 (`git diff -U0 d8b61b0 HEAD -- README.md` 의 hunk 둘); 18 · 333행 `      ref: v2.0.0` 그대로. 실제 tag 설치는 Phase 6 (Deferred) |
| SC2 | 끄기 · 버전 올리기 · `ref: main` → tag · 문제 해결 절, 재정의가 Phase 3 fixture 와 같다 | ✓ VERIFIED | 회귀: 절 제목 그대로, `fixtures` 는 `6d64bee` 와 같고 기준 실행 `[4/10]` · `[10/10]` 통과 |
| SC3 | README 의 규칙 · 설정 설명이 실제 YAML 과 일치하고, 규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 | ✓ VERIFIED | **앞 절반:** 기준 실행 셋(CI 꼴 70초 · `pub get` 뒤 73초 · 되돌린 뒤 23초) 모두 종료 코드 0 · `점검 통과 (10개 중 10개)`. **뒤 절반 — 지난 gap 입력이 이제 실패:** M86 (문서가 받지 않는 규칙) · M87 (pubspec 의 숨긴 version) · M88 · M89 (사용 프로젝트에 닿는 숨은 옵션) 전체 실행 모두 rc 1 · `[3/10]` 만 · 10개 중 1개. **같은 모양의 새 입력 — 찾지 못함** (아래 「같은 모양 시험」) |
| SC4 | CHANGELOG 최상단 새 항목(Phase 1 형식), 1.0.0 ~ 1.3.0 사이 보완 | ✓ VERIFIED | `git diff --quiet e46cff4 HEAD -- CHANGELOG.md` |
| SC5 | 배포 YAML 머리 주석이 실제 구성을 설명, 보일러플레이트 없음 | ✓ VERIFIED | `git diff --quiet e46cff4 HEAD -- lib` (`pubspec.yaml` 의 옛 주석은 배포 YAML 이 아니다 — 아래 경고 IN-13) |

**첫 회차 plan truth (20) — 회귀 확인**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 01-1 · 01-2 · 01-4 ~ 01-6 | plugin 줄 끝 주석, 선언 삭제 70, 읽지 못하는 줄 70, `stripPlugins`, M32 ~ M37 기록 | ✓ VERIFIED | 회귀 M37 전체 실행 rc 1 · `[2/10]` `build/woody_rule_check/riverpod/analysis_options.yaml:8  warning  deprecated_lint  (unnecessary_await_in_return)` · `[3/10]` `6행: linter:` · 10개 중 2개 · (h) 블록 0 |
| 01-3 | `lib/codegen.yaml` · `lib/riverpod.yaml` 에 규칙을 적으면 실패 | ✓ VERIFIED | M68 (`linter :` 철자) 함수 단위 `passed=false` — (a′) 줄 `10행: linter :` 에 더해 (h) 규칙 블록 `YAML 에만: prefer_mixin`. (h) 가 YAML 쪽에만 보이는 규칙도 잡는다 |
| 02-1 ~ 02-5 | 머리 주석 다섯, 템플릿 없음, 규칙 81줄, riverpod 주석, `.claude/CLAUDE.md` 71 · 181행 | ✓ VERIFIED | `lib` (`e46cff4`) · `.claude/CLAUDE.md` (`403c584`) 와 diff 0 |
| 03-x · 04-4 ~ 04-6 | README 절 · 표시 구역, CHANGELOG 정리, 01 WR-05 fixed | ✓ VERIFIED | CHANGELOG 불변, README 는 380 · 382행만 바뀜 |
| 05-1 ~ 05-3 · 06-1 ~ 06-3 | 첫 push, 비공개 점검, GitHub verify, M38 ~ M42 기록 | ✓ VERIFIED | `example/README.md` 의 `| M` 행: `d8b61b0` 의 85행과 지금 앞 85행이 글자 그대로 같고 M86 ~ M91 여섯이 더해짐 (91행) |

(묶은 행도 20개로 센다 — 실패 없음.)

**gap plan 05-07 · 05-08 · 05-09 (28) — 회귀 확인**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 07-1 ~ 07-6 · 07-8 · 07-9 | 옛 README 꼴, 구역 안 다섯 꼴, flow 70, 블록 꼴 실패, 기준 10/10, `readMarkerBlock`, M47 ~ M50 | ✓ VERIFIED | 회귀 M45 전체 실행 rc 70 · stdout 0 바이트 · stderr `` lib/codegen.yaml 의 10행: `linter:` 줄에 값이 붙어 있다 … `` |
| 07-7 | README 378행 불릿의 단정이 참이 된다 | ✓ VERIFIED | 지난 회차 FAILED → 이제 참. 378행 괄호의 두 예가 지난 gap 입력에서 실패한다: codegen 의 숨은 `language:` (M88 전체 실행 `YAML 에만: language`), riverpod 의 숨은 다른 plugin (M90 함수 단위 `YAML 에만: custom_lint`). 일반 논증: (h) 는 YAML 의 맵 키와 reader 가 본 키를 건수까지 견주므로, YAML 이 보는 최상위 · 바로 아래 키는 reader 도 봐야 하고, reader 가 본 키는 (a′) 의 닫힌 목록 안이어야 한다 |
| 08-1 ~ 08-8 | RULES.md 표 · 주소 · 펜스 · 옵션 reader, M51 ~ M62 | ✓ VERIFIED | 회귀 M61 전체 실행 rc 70 · stderr `` lib/base.yaml 의 `language:` 블록의 98행을 읽지 못했다 … strict-casts: yes ``; `RULES.md` 는 `76dee2f` 와 같다 |
| 09-1 ~ 09-11 | plugin 선언 · pubspec reader, 문장, 처리 기록, push | ✓ VERIFIED | 회귀 M66 rc 70 · `` riverpod_lint 선언 `>=3.1.9 <4.0.0` 을 읽지 못했다 … ``. 낡은 단언 `git diff --quiet 968a5bb -- pubspec.yaml` 은 새 기준으로 판정: `968a5bb..77e0b88` 의 diff 는 17행 뒤에 다섯 줄을 더한 것뿐이고, `77e0b88..HEAD` 는 0 |

**gap plan 05-10 (9)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 10-1 ~ 10-7 · 10-9 | M68 ~ M78 의 적힌 결과, 회귀 입력, (d′) 경계, 고정 커밋 | ✓ VERIFIED | (d′) ~ (g) · `fencedLines` 등의 코드 줄 불변 (`d8b61b0..HEAD` 의 지운 코드 줄 0); M68 은 (a′) 줄 그대로에 (h) 블록이 더해짐 — 05-14 소절 읽는 법이 적은 대로 |
| 10-8 | README 378 · 382행, `example/README.md` 116 · 358 · 395 · 436행, (e) ~ (g) 주석이 실제 동작 · 범위를 말한다 | ✓ VERIFIED | 지난 회차 FAILED → 이제 참. 378 · 379 · 116행 닫힌 목록 · (g) 구절은 M86 ~ M90 으로 참; 382 · 116 · 395행과 두 문서 주석의 범위 밖 목록에 IN-10 구절이 있고 같은 입력이 함수 단위 `passed=true` (문장대로 범위 밖). WR-07 ~ WR-09 · WR-12 ~ WR-14 · IN-08 의 꼴은 코드 불변 · 문장 불변(구절 하나만 더함)이라 지난 판정 그대로 |

**gap plan 05-11 (4) · 05-13 (4)** — ✓ VERIFIED (지난 재검증 그대로; `b8519d4` · `c2f275a` 는 HEAD 의 조상, CHANGELOG 불변).

**gap plan 05-12 (8)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 12-1 ~ 12-5 · 12-7 · 12-8 | M79 ~ M85, `splitYamlLines` 일곱 자리, 코드 줄 변경 범위, 고정 커밋 | ✓ VERIFIED | 회귀 M79 전체 실행 rc 1 · `[3/10]` 만 · `  + prefer_mixin  (base.yaml 에만)` 두 줄 · (h) 블록 0 · 10개 중 1개. 낡은 단언(“import 둘”, `example/README.md` `4/4`, README 382행 하나)은 05-14 가 예고한 새 기준으로 판정 — import 셋, `example/README.md` 는 11행 · 116 · 395행과 새 소절, README 는 380 · 382행 |
| 12-6 | 회귀 없음, 378 · 379 · 116행 닫힌 목록 구절은 '고친 뒤 참이 되므로' 글자 그대로 | ✓ VERIFIED | 지난 회차 FAILED → 이제 참. 그 구절은 글자 그대로이고(`d8b61b0` 대비 116행 hunk 는 IN-10 구절만, 378 · 379행 hunk 없음) M86 ~ M90 으로 참 |

**gap plan 05-14 (10) — 새 truth**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 14-1 | M86 · M87 전체 실행이 rc 1 · `[3/10]` 만 · 10개 중 1개, 정해진 블록 | ✓ VERIFIED | M86 (`7/0` · `1/0` · `1/0`): 블록 셋 `declaredRuleNames ↔ linter.rules` `줄 단위 reader 에만: prefer_mixin` · 최상위 `linter` · `linter:` 아래 `rules` (24초). M87 (`3/1` · `2/2`): `pubspecReleaseVersion ↔ version` `줄 단위 reader: 1.9.0` · `YAML: 2.0.0-dev` (25초) |
| 14-2 | M88 · M89 전체 실행이 같은 꼴, 정해진 블록 | ✓ VERIFIED | M88 (`6/0`): 최상위 `analyzer` · `analyzer:` 아래 `줄 단위 reader 에만: exclude` · `YAML 에만: language` (25초). M89 (`7/0`): 최상위 `include` · `analyzer:` 아래 `YAML 에만: language` · 옵션 `YAML 에만: strict-inference: true` (22초) |
| 14-3 | M90 · M91 · 선언만 다른 입력 · 같은 키 두 번이 함수 단위 `passed=false` | ✓ VERIFIED | M90 (`8/1`) 블록 둘 그대로, loadYaml 의 `plugins` 에 `custom_lint`. M91 (`5/0` · `1/1`) 블록 하나 `줄 단위 reader 에만: strict-casts: true`. 선언만 다른 입력(`6/1`) `줄 단위 reader: ^3.1.9` · `YAML: ^3.2.0`. 둘째 `analyzer:` → `` `lib/codegen.yaml` 을 YAML 로 읽지 못했다 — 10행: Duplicate mapping key. ``. **실패 방향:** `tool/verify.dart` 만 `d8b61b0` 으로 두면 M90 · M91 둘 다 `passed=true` |
| 14-4 | `pubspec.yaml` 은 17줄 그대로 뒤에 다섯 줄만, import 셋, 지운 코드 줄 0, reader 열셋 코드 불변, `checkShippedComposition` 에 더한 코드 줄 하나 | ✓ VERIFIED | `git diff 968a5bb 77e0b88 -- pubspec.yaml` 은 `+` 다섯 줄뿐; import `dart:convert` · `dart:io` · `package:yaml/yaml.dart`; `git diff d8b61b0 HEAD -- tool/verify.dart` 의 지운 줄은 모두 주석 줄(6 · 832 · 1877행 자리); `checkShippedComposition` 의 hunk(2232행 뒤)에서 더한 코드 줄은 `  compareLineReadersWithYaml(repoRoot).forEach(addBlock);` 하나 |
| 14-5 | 새 복제본의 `pub get` 없는 첫 실행 10/10, `yaml` direct dev, `git status` 빈 출력, CRLF · CR 거짓 실패 없음 | ✓ VERIFIED | `ci` 복제본 첫 실행 rc 0 · 10개 중 10개 · 70초, 뒤의 `git status --porcelain` 0줄, 루트 lock 의 `yaml` `dependency: "direct dev"` · `https://pub.dev` · 3.1.4. 함수 단위 CRLF (`95/95` 등) · CR 하나 둘 다 `passed=true` |
| 14-6 | 회귀 M79 · M37 · M45 · M61 · M66 메시지 그대로, M68 ~ M78 은 (h) 블록이 더해짐, 378 · 379 · 116행 글자 그대로 | ✓ VERIFIED | 위 회귀 다섯 전체 실행 모두 앞 기록 그대로 (M79 · M37 은 (h) 블록 0, M45 · M61 · M66 은 rc 70 · stdout 0 바이트). M68 함수 단위는 (a′) 줄 + (h) 블록 셋 |
| 14-7 | `example/README.md` 의 (05-14) 소절 · 6열 표 · M86 ~ M91, M1 ~ M85 불변, 11행만 제자리 수정 | ✓ VERIFIED | 소절은 594행에서 시작(05-12 소절 뒤 · 끝 각주 앞), 표 여덟 줄의 칸 수가 모두 같다; `d8b61b0` 대비 hunk 는 11 · 116 · 395행과 593행 뒤 37줄 |
| 14-8 | README 380행 구절, `example/README.md` 11행, skill 세 줄, 254 → 64 | ✓ VERIFIED | 380행 `… pubspec.yaml 이 바뀐 뒤에는 fvm dart pub get 을 먼저 한 번 돌린다 …`; skill 세 줄이 정해진 글자이고 `git diff --stat de8900c HEAD -- .claude/skills` 는 세 파일 `1/1`. 검증자 재현: `yaml` 없는 `pubspec.yaml` 로 `pub get` 한 뒤 되돌린 복제본에서 `--bogus` → rc 254 · `Error: Couldn't resolve the package 'yaml' …`, `pub get --no-example` 뒤 → rc 64 · `모르는 인자: --bogus` |
| 14-9 | IN-10 · IN-11 문장, Task 2 의 코드 줄 불변 | ✓ VERIFIED | '그 펜스를 닫는 것으로 보아' README 1 · `example/README.md` 2 · `tool/verify.dart` 2; `stripPlugins` 주석 `복사본의 줄 번호가 원본과 같다 (끝의 빈 줄은 빠질 수 있다 …)`, 옛 글자 0; `0f62057` 은 세 파일의 문장 · 주석만 (`git show --stat`: README `1/1`, `example/README.md` `2/2`, `tool/verify.dart` 주석 hunk) |
| 14-10 | 고정 커밋 여덟 그대로, 검증 10/10 | ✓ VERIFIED | `lib` · CHANGELOG (`e46cff4`) · `RULES.md` (`76dee2f`) · `fixtures` (`6d64bee`) · `example/pubspec.lock` (`ac5cced`) · `.claude/CLAUDE.md` (`403c584`) · `tool/measure_rules.dart` (`812c477`) · `.github/workflows/verify.yml` (`79f27e5`) 모두 diff 0; HEAD 와 같은 내용의 복제본에서 `fvm dart analyze` `No issues found!`, format 종료 코드 0, 검증 10/10 |

**gap plan 05-15 (4) — 새 truth**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 15-1 | 처리 기록 fixed 18 · skipped 8 · deferred 1 · open 0 · total 27 | ✓ VERIFIED | `git show 2336ba0:…/05-REVIEW-DISPOSITION.md` 의 disposition 셈 18 · 8 · 1 · 0, `open: 0`, `total: 27`; WR-15 · WR-16 → `77e0b88`, IN-11 → `0f62057`, IN-10 `skipped` 의 Source 칸이 `소유자 결정 G4-Q2 — 문장을 실제 범위에 맞춤, 검사는 고치지 않음; ` 으로 시작. 지금 파일의 open 3 (IN-12 · IN-13 · IN-14)은 그 뒤 재리뷰(`811d894`)의 새 발견이다 |
| 15-2 | CHANGELOG 불변 | ✓ VERIFIED | `git diff --quiet e46cff4 HEAD -- CHANGELOG.md` |
| 15-3 | push 전 범위 비공개 점검 0 | ✓ VERIFIED | 범위 `c2f275a..2336ba0` 16커밋; `.claude/CLAUDE.md` · workflow 불변, `.claude/skills/` 는 세 파일 `1/1` 뿐. 05-VALIDATION 감사(05-15 T2 첫째 rc 0)와 같은 결론 — 검증자도 범위의 `.planning/` 밖 더한 줄(일곱 파일)에서 절대 경로 꼴 · 홈 · 임시 폴더 꼴 · 비공개 사용 프로젝트 이름을 grep 해 0줄을 봤다 |
| 15-4 | fast-forward push, `main` · tag · PR 불변, GitHub verify 성공 | ✓ VERIFIED | `git ls-remote origin`: 작업 브랜치 `2336ba0`, `main` `90a2736`, tag `v1.3.0` 하나; `c2f275a` → `2336ba0` → HEAD 조상 관계; `gh pr list --state all` → `[]`; `gh run view 38639587080`: `completed` · `success` · push · headSha `2336ba0…`, 로그 `[3/10] 배포 파일의 구성 ................ 통과` · `점검 통과 (10개 중 10개)` |

**점수:** 92/92 참 확인 (present · behavior-unverified 0). 지난 실패 넷(SC3 · 07-7 · 10-8 · 12-6)이 모두 닫혔다.

### 같은 모양 시험 (orchestrator 요청 — "(h) 가 다섯 비교에서 소유자 문장을 지킨다" 는 리뷰 주장)

이 phase 에서 일곱 번 되풀이된 모양은 "줄 단위 reader 가 보는 것 ≠ analyzer · pub 이 보는 것" 이다. (h) 뒤에 이 모양이 남으려면 둘 중 하나여야 한다: (가) analyzer · pub 이 받는 값 가운데 줄 단위 reader 가 읽어 문서와 견주는데 (h) 가 YAML 과 견주지 않는 값, (나) reader 와 `loadYaml` 이 같게 읽는데 analyzer 가 다르게 읽는 입력.

**(가) — 빈자리 없음.** 코드를 읽어 다섯 비교마다 reader 가 진짜 값을 놓칠 수 있는지 봤다.

- 최상위 키: reader 는 열 0 의 비주석 줄을 모두 본다(들여 쓴 첫 줄은 원문으로 담아 늘 불일치). YAML 의 최상위 키는 열 0 에 있으므로 reader 쪽이 YAML 키를 모두 포함하고, 건수까지 같아야 하므로 가짜 열 0 줄이 있으면 실패한다.
- 바로 아래 키: reader 의 "바로 아래" 는 키 다음 첫 비주석 줄의 들여쓰기다. 값 없는 키 줄 뒤의 첫 줄은 YAML 맵의 첫 키이므로, 블록 맵의 모든 키(같은 들여쓰기)를 reader 가 본다. 가짜 줄은 더해질 뿐이라 건수에서 걸린다. 키 줄에 값 · 앵커 · 태그가 붙으면 reader 쪽이 비어 YAML 쪽만 남아 실패한다.
- 규칙 · 옵션: `linter:` · `language:` 블록 안에서는 읽지 못하는 줄이 70 이므로 스칼라를 열 수 없다. `enabledLanguageOptions` 가 어느 깊이의 `language:` 든 받는 점은 reader 쪽에 값이 더해지는 쪽(실패)이다. Map 으로 겹쳐 쓰는 점도 값이 다르면 문자열이 달라 실패하고, 같으면 문서와 실제가 같다.
- plugin 선언 · version: 값 비교라 다르면 블록. 선언만 다른 입력 · M87 로 확인.
- 나머지 reader(`significantLines` 의 (a) · `[4/10]`, `readUpstreamRules`, `stripPlugins` · `readRuleNameAt`, README 쪽 (d) ~ (g))는 소유자가 이번 범위 밖으로 둔 것이다 (05-14 `<owner_decisions>` Round 2 NOT approved). 리뷰어의 `significantLines` 시험(묶음 줄을 네 칸 들여 써 YAML 이 접음)은 `[5/10]` · `[10/10]` 이 잡는다고 기록됐다 — 검증자는 다시 돌리지 않았다.

**(나) — 시험한 입력 모두 셋(reader · `loadYaml` · analyzer)이 같았다.**

| 시험 | 입력 | 결과 | 판정 |
|------|------|------|------|
| P1 따옴표 bool | `lib/base.yaml` 끝 `analyzer:` / `  language:` / `    strict-casts: "true"` (YAML 문자열 `"true"` 는 `'$value'` 로 bool 과 같은 글자가 된다) | 함수 단위 `FormatException` (reader 가 따옴표 값을 받지 않음 → 종료 코드 70) | 막힘 — 글자 겹침이 (h) 에 닿지 않는다 |
| P2 줄 머리 BOM | `language:` 아래 옵션 줄 앞에 U+FEFF (Dart 의 `trim` 은 BOM 을 공백으로, package:yaml 은 열 0 의 BOM 을 건너뜀) + `RULES.md` 옵션 행 | 함수 단위 `passed=true` (reader · YAML 모두 `strict-casts: true`). 전체 실행 rc 1 · `[3/10]` 통과 · `[5/10]` · `[7/10]` ~ `[10/10]` 이 `lib/strict_rules.dart:6  error  invalid_assignment` 로 실패 — analyzer 도 옵션을 켰다 | 셋이 같다 — 문서(RULES.md)와 실제가 일치, 헛통과 아님 |
| P3 병합 키 | `lib/codegen.yaml` 의 `analyzer:` 아래 `  <<: {language: {strict-casts: true}}` | `passed=false` — (a′) 줄과 (h) 블록 (`YAML 에만: <<` — package:yaml 은 병합 키를 일반 키로 읽는다) | 막힘 |
| NBSP · 탭 | (코드를 읽은 것) reader 는 U+00A0 등을 들여쓰기로 세고 YAML 은 글자로 읽는다 | 그 글자가 키 이름에 들어가 analyzer 가 모르는 키가 되거나 YAML 오류 | reader 와 YAML 이 갈려 실패 쪽 |

재지 않은 것: 루트의 `yaml` 3.1.4 와 SDK 의 analyzer · pub 이 품은 package:yaml 의 판이 같은지(SDK 배포본에는 그 정보가 없다). P2 와 IN-14 의 analyzer 쪽 동작(리뷰어 기록)이 같은 해석기임을 시사하지만 증명은 아니다 — 남는 위험으로만 적는다.

**결론:** 리뷰어의 주장("다섯 비교에서 새 헛통과 없음")은 검증자의 시험에서도 깨지지 않았다. 지난 일곱 회차와 달리 이번 수정은 꼴을 하나씩 막지 않고 "reader 가 본 값 ≠ YAML 이 본 값" 자체를 실패로 만들어, 다섯 값에 대해서는 모양의 종류를 닫았다.

### 05-REVIEW 4회차 재리뷰 발견의 판정

판정 기준: 이 phase 가 말한 참(성공 기준, plan must_haves, README · `example/README.md` 의 "검사가 지킨다" 문장)이 그 입력에서 거짓이 되면 gap, 참이지만 다듬을 점이면 경고. 모두 복제본에서 다시 돌렸다.

| 발견 | 재현 (검증자) | 판정 | 이유 |
|------|---------------|------|------|
| IN-12 값을 다음 줄에 둔 `include:` 를 (h) 가 "아래 키" 로 셈 | 전체 실행 (`lib/base.yaml` `2/1`) rc 1 · `[3/10]` 만 실패 · 10개 중 1개 · 블록 `` `lib/base.yaml` 의 `include:` 바로 아래 키 … `` `줄 단위 reader 에만: package:flutter_lints/flutter.yaml` · `YAML 에만: (없음)`; `[2/10]` · 정답지 다섯은 통과 (analyzer 는 받는다) | ⚠️ 경고 | 거짓 **실패** 쪽(막힘)이다 — "일치가 검증으로 지켜진다" 를 거짓으로 만들지 않는다. 05-14 의 "거짓 실패 없음" truth 는 CRLF · CR 로 한정돼 있고 그 입력은 통과했다. 다만 소유자 문장 "지금 검사가 **읽은** 값과 다르면" 보다 넓다(이 줄을 키로 읽는 지금 검사는 없다)이고 안내 줄이 이 입력에 맞지 않는다. 리뷰의 Fix(키 꼴 줄만 담기)는 (h) 의 도우미만 고치므로 길 B 안이다 — 소유자 결정 |
| IN-13 `pubspec.yaml` 13행 주석이 `lib/analysis_options.yaml` 을 include 하는 파일로 적음 | 읽어 대조: `lib/analysis_options.yaml` 은 `include: package:woody_lints/recommended.yaml` 한 줄, 기반 세트를 include 하는 것은 `lib/base.yaml:5`. 이 주석은 1.3.0 (`90a2736`)에 쓰였고 Phase 3 의 분리(`89d6073`)부터 낡았다 | ⚠️ 경고 | phase 목표 문구 "YAML 주석이 실제 설정과 일치" 에 걸리지만, 그 계약인 SC5 · DOCS-10 은 "배포 YAML 의 머리 주석" 이고 `pubspec.yaml` 은 배포 YAML 이 아니다. 주석의 이유(include 대상이라 `dependencies`)는 참이고 파일 이름만 틀리다. 05-14 는 `pubspec.yaml` 의 기존 줄을 바꾸지 말라는 금지 사항이 있어 이번에 손댈 수 없었다 — 다음 수정에 주석 한 줄(`lib/base.yaml` 로)을 넣을지 소유자 결정 |
| IN-14 한 글자 `!!float` 값에서 `loadYaml` 이 `RangeError` | 함수 단위 (`lib/codegen.yaml` 6행 `!!float i`) `checkShippedComposition` 이 `RangeError (length): Invalid value: Only valid value is 0: 1` 를 던짐; 대조 `!!float ignore` → 블록 `6행: Invalid float scalar.` | ⚠️ 경고 | main 은 `FormatException` · `FileSystemException` · `ProcessException` 만 받으므로 처리되지 않은 예외(종료 코드 255)다. 헛통과는 될 수 없다 — (h) 가 결정적으로 던지므로 `점검 통과` 에 닿지 않는다(리뷰어 기록으로는 그보다 앞의 `[2/10]` analyzer 가 멈춘다). 거짓인 것은 `compareLineReadersWithYaml` 문서 주석의 "그 밖의 예외는 지금처럼 main 이 받는다" 와 머리 주석의 종료 코드 목록(255 없음)이다. 문서 주석 · catch 하나라 길 B 안 — 소유자 결정 |
| WR-07 · WR-08 · WR-09 · WR-12 · WR-13 · WR-14 · IN-08 · IN-10 (skipped) | IN-10 입력 함수 단위 `passed=true`; 나머지는 코드 · 문장이 지난 재검증 뒤 바뀌지 않음(문장에 IN-10 구절만 더함) | 범위 한계로 받아들임 | 문장이 그 동작을 범위 밖으로 맞게 적는다 (소유자 결정 G2-Q2 · G3-Q2 · G3-Q3 · G4-Q2) |
| WR-06 (deferred, D-09) | `.claude/CLAUDE.md` 는 `403c584` 그대로 | 미룸 그대로 | 마일스톤 끝 `/gsd-map-codebase`. 261행(pubspec 의 Contains 에 `dev_dependencies` 없음)도 이 미룸에 든다 (05-14 Round 2 NOT approved) |

**범위 한계로 적는 것 (소유자가 범위 밖으로 둔 것 — 판정하지 않음):** 길 A 의 꼴 막기, reader 를 `loadYaml` 로 바꾸기, `yaml` 을 `dependencies` 에, override (길 C), (d′) · (e) ~ (g) · `fencedLines` · `markFencedLines` · `unquotedScalar` · `findMarkerRange` · `findListLinesOutsideMarkers` · `stripPlugins` 의 코드, `tool/measure_rules.dart`, `.claude/CLAUDE.md`, CHANGELOG, `stripPlugins` · `readRuleNameAt` · `significantLines` · `readUpstreamRules` 를 대조에 넣기, `05-VALIDATION.md` Test Infrastructure 문장, skill 의 다른 줄. 앞 회차의 G2-… · G3-… 결정과 Round 2 범위 밖 목록(`lib/base.yaml` 의 `include:` 값, `lib/base.yaml` 의 `analyzer:` 아래 `language:` 밖의 키, codegen `errors:` 의 심각도 등)도 그대로다.

### Deferred Items

| # | 항목 | 다룰 phase | 근거 |
|---|------|-----------|------|
| 1 | README 의 `ref: v2.0.0` 블록으로 실제로 받는 것 (tag 가 아직 없다) | Phase 6 | 성공 기준 3 |

### Advisory (New Scope, Unevidenced)

없음 — 새 발견 셋(IN-12 · IN-13 · IN-14)은 모두 재현 또는 파일 대조라는 결정적 증거가 있고, 경고로 둔다.

### Required Artifacts

| Artifact | 기대 | 상태 | 세부 |
|----------|------|------|------|
| `pubspec.yaml` | `dev_dependencies` 의 `yaml: ^3.1.4` 와 이유 주석 | ✓ VERIFIED | 20 ~ 22행; 기존 17줄 불변 (13행의 옛 주석은 경고 IN-13) |
| `tool/verify.dart` | `compareLineReadersWithYaml` 과 도우미 여섯, (h) 호출 한 줄, IN-10 · IN-11 주석 | ✓ VERIFIED | 있음 · 실질 · 연결됨(`checkShippedComposition` 의 마지막 확인) · 데이터 흐름(`loadYaml` 이 같은 파일을 읽음 — M86 ~ M91 의 블록이 그 값을 보임). 문서 주석 한 문장이 동작과 다름 (IN-14) |
| `example/README.md` | (05-14) 소절, 11 · 116 · 395행 | ✓ VERIFIED | 기록이 검증자 실행과 같다 |
| `README.md` | 380 · 382행 구절 | ✓ VERIFIED | 380행의 254 → 64 동작을 재현 |
| skill 세 파일 | 52 · 13 · 14행 | ✓ VERIFIED | 정해진 글자, 다른 줄 불변 |
| `05-REVIEW-DISPOSITION.md` | 05-15 시점 open 0 | ✓ VERIFIED | `2336ba0` 시점 그대로; 지금 open 3 은 재리뷰 발견 |

### Key Link Verification

| From | To | Via | 상태 | 세부 |
|------|----|-----|------|------|
| `tool/verify.dart` | 조각 셋 · `pubspec.yaml` | (h) `compareLineReadersWithYaml` — reader 다섯 ↔ `loadYaml` | ✓ WIRED | 정방향(M86 · M87 · M91) · 역방향(M88 · M89 · M90) · 선언만 다른 입력 · 중복 키 모두 실패; CRLF · CR 거짓 실패 없음 |
| `pubspec.yaml` | `tool/verify.dart` | `dev_dependencies` 의 `yaml` → `import 'package:yaml/yaml.dart'` | ✓ WIRED | 새 복제본 첫 실행이 받음, 낡은 package config 는 254 (README 380행 그대로) |
| `tool/verify.dart` | `example/README.md` | M86 ~ M91 기록 | ✓ WIRED | 검증자 실행이 기록 글자와 같다 |
| `05-REVIEW-DISPOSITION.md` | 05-14 의 task 커밋 | WR-15 · WR-16 → `77e0b88`, IN-10 · IN-11 → `0f62057` | ✓ WIRED | `77e0b88` 은 `pubspec.yaml` · `tool/verify.dart` 등, `0f62057` 은 README · `example/README.md` · `tool/verify.dart` 주석 |
| 로컬 브랜치 | origin | `git push origin gsd/v2.0-package-rework` | ✓ WIRED | origin `2336ba0`, run 38639587080 success |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| (h) 블록 | `yamlRuleNames` · `keysSeenByYaml` · `yamlLanguageOptions` · `yamlPluginConstraint` · `version` | `loadYaml(File('$repoRoot/$path').readAsStringSync())` | 예 — M90 의 하네스가 찍은 `loadYaml` 값(`custom_lint`)이 블록의 `YAML 에만:` 과 같다 | ✓ FLOWING |

### Behavioral Spot-Checks (검증자 복제본)

| 동작 | 결과 | 상태 |
|------|------|------|
| 새 복제본의 `pub get` 없는 첫 실행 (CI 꼴) | rc 0 · 10/10 · 70초 · `git status` 0줄 | ✓ PASS |
| 기준 실행 (`pub get` 뒤 / 되돌린 뒤) | rc 0 · 10/10 (73초 / 23초) | ✓ PASS |
| M86 · M87 · M88 · M89 | rc 1 · `[3/10]` 만 · 10개 중 1개 · 기록 블록 그대로 | ✓ PASS |
| M90 · M91 · 선언만 다른 입력 · 같은 키 두 번 (함수 단위) | 모두 `passed=false` | ✓ PASS |
| 실패 방향 — `d8b61b0` 의 `tool/verify.dart` 로 M90 · M91 | 둘 다 `passed=true` | ✓ PASS (시험이 가른다) |
| CRLF · CR (함수 단위) | 둘 다 `passed=true` | ✓ PASS |
| 회귀 M79 · M37 · M45 · M61 · M66 | rc 1 (1/10) · rc 1 (2/10) · rc 70 · rc 70 · rc 70, 문구 앞 기록 그대로 | ✓ PASS |
| 254 → 64 | rc 254 · rc 64 | ✓ PASS |
| `fvm dart analyze` · format | `No issues found!` · rc 0 | ✓ PASS |
| IN-12 입력 (맞는 YAML) | rc 1 · `[3/10]` 만 | ⚠️ 거짓 실패 (경고) |
| IN-14 입력 | `RangeError` (처리되지 않음) | ⚠️ 문서 주석과 다름 (경고) |

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
| DOCS-06 | 05-03 · 05-07 · 05-09 · 05-10 · 05-12 · 05-13 · 05-14 · 05-15 | ✓ SATISFIED | README 의 규칙 · 설정 설명이 YAML 과 같다(기준 실행 `[3/10]`), 검사 범위 문장이 동작과 같다 (14-8 · 14-9) |
| DOCS-07 | 05-04 · 05-09 | ✓ SATISFIED | SC4 |
| DOCS-08 | 05-04 | ✓ SATISFIED | 변경 없음 (사람 확인 3번) |
| DOCS-09 | 05-04 | ✓ SATISFIED | 변경 없음 |
| DOCS-10 | 05-01 · 05-02 | ✓ SATISFIED | SC5 (`pubspec.yaml` 주석은 범위 밖 — IN-13) |
| VERIFY-06 | 05-01 · 05-03 · 05-05 ~ 05-15 | ✓ SATISFIED | SC3 — 지난 gap 입력 여섯이 실패, 같은 모양의 새 입력 없음 |

ORPHANED 없음 — REQUIREMENTS.md 가 Phase 5 에 매긴 11개가 모두 plan 의 `requirements` 에 있다. REQUIREMENTS.md 의 표시(VERIFY-06 · DOCS-06 `Complete`, 나머지 아홉 `Gaps Found`)는 이 증거와 다르다 — 열하나 모두 SATISFIED 다 (사람 확인 뒤 갱신).

### Anti-Patterns

| 파일 | 줄 | 패턴 | 심각도 | 영향 |
|------|----|------|--------|------|
| `tool/verify.dart` | 1896 ~ 1910 | `keysSeenByLineReader` 가 값 없는 키 아래의 스칼라 값 줄을 "아래 키" 로 담음 | ⚠️ Warning | IN-12 — 맞는 `lib/base.yaml` 꼴 하나에서 거짓 실패 |
| `tool/verify.dart` | 1984 ~ 1986 · 2027 ~ 2039 | `YamlException` 만 잡는데 문서 주석은 "그 밖의 예외는 main 이 받는다" | ⚠️ Warning | IN-14 — 종료 코드 255, 머리 주석의 목록에 없음 |
| `pubspec.yaml` | 13 ~ 15 | 이유 주석이 include 하는 파일을 옛 이름으로 적음 | ⚠️ Warning | IN-13 — 주석의 파일 이름만 틀림 |

`TBD` · `FIXME` · `XXX` 표식: `tool/verify.dart` · `README.md` · `example/README.md` · `pubspec.yaml` 에 0개. 재검증 증거 gate: 새 발견 셋은 모두 이번 회차에 바뀐 파일(`tool/verify.dart` · `pubspec.yaml`)에 걸리고 재현 또는 파일 대조가 있으나, 목표 · truth 를 거짓으로 만들지 않아 blocker 가 아니다.

### 금지 사항(prohibitions) 확인 (판단 등급 — 검증자의 비권위 판정)

기계로 가를 수 있는 것은 직접 확인했고 어긴 것은 없다.

- 05-14: 줄 단위 reader 의 본문 · 메시지 불변(`d8b61b0..HEAD` 의 지운 코드 줄 0, 회귀 다섯의 메시지 그대로); 꼴 막기 코드 · reader 교체 · override 없음; `yaml` 은 `dev_dependencies` 만, `lib/` 에 Dart 없음(`[1/10]` 통과), `pubspec.yaml` 의 기존 17줄 불변; (d′) ~ (g) · 펜스 판정 · `stripPlugins` 의 코드 줄 불변(바뀐 것은 주석 줄); `tool/measure_rules.dart` · workflow · `lib` · `RULES.md` · CHANGELOG · `fixtures` · `example/pubspec.lock` · `.claude/CLAUDE.md` 고정 커밋 그대로; M1 ~ M85 행 불변; skill 은 세 줄만; WR-06 `deferred` 그대로. "복제본에서만 실험했다" 는 작업 트리와 이력에 변형 흔적이 없다는 것까지만 확인할 수 있다.
- 05-15: push 는 fast-forward (`c2f275a` → `2336ba0`), 원격 `main` `90a2736` · tag `v1.3.0` 하나 · PR 0; 처리 기록의 앞 회차 행 · `recorded:` 그대로, WR-06 `deferred`; 이 plan 의 커밋(`2336ba0`)은 처리 기록 하나만 바꿨다.

### Human Verification Required

자동 검증은 모두 통과했다. 남는 것은 사람 확인 여섯이다 (frontmatter `human_verification`).

1. **README 를 처음부터 따라 하기** — 설치 → 프리셋 고르기 → 끄기 세 층 → 버전 올리기 세 갈래.
2. **단정 / 출처 문장 단위 확인** — 끄기 · 생성 파일 제외 · 버전 올리기 · 문제 해결.
3. **CHANGELOG 복원 일곱 항목과 `git show` diff 대조** — CHANGELOG 는 `e46cff4` 뒤로 불변.
4. **외부 링크 넷 열기.**
5. **검사 범위를 말하는 문장의 읽힘** — README 378 ~ 382행, `example/README.md` 11 · 116 · 395 · 436 · 549행, (05-14) 소절.
6. **금지 사항(judgment 등급) 수용** — 위 비권위 판정과 견주기.

### 소유자 결정이 필요한 경고 (gap 아님)

| 경고 | 길 B 안에서 닫을 수 있나 | 제안 |
|------|-------------------------|------|
| IN-12 거짓 실패 | 예 — (h) 의 도우미 `keysSeenByLineReader` 만 고침 (reader 본문 불변) | 아래 줄 가운데 키 꼴 줄만 담기, 또는 받아들이고 그대로 |
| IN-13 `pubspec.yaml` 13행 | 해당 없음 (주석 한 줄) | `lib/analysis_options.yaml` → `lib/base.yaml`; 05-14 의 금지 사항 밖에서 새 승인 필요 |
| IN-14 문서 주석 · 255 | 예 — `load` 의 catch 하나 또는 주석 한 줄 | 리뷰의 Fix 둘 가운데 하나 |

### Gaps 요약

**지난 gap 둘은 닫혔다.** 여러 줄 문자열 안에 숨긴 규칙 · 버전(정방향)과 옵션 · plugin(역방향) 입력 여섯이 이제 모두 실패한다 — 검증자가 M86 ~ M89 를 전체 실행으로, M90 · M91 · 선언만 다른 입력 · 같은 키 두 번을 하네스로 다시 돌려 기록과 같았고, 고치기 전 `tool/verify.dart` 로는 M90 · M91 이 통과해 시험이 가른다는 것도 봤다. 새 복제본의 CI 꼴 실행 · GitHub verify 가 10/10 이고, 회귀 다섯은 앞 기록 그대로다. IN-10 문장도 이제 동작과 맞다.

**같은 모양의 새 입력은 찾지 못했다.** (h) 는 다섯 값에 대해 "reader 가 본 것 ≠ YAML 이 본 것" 을 건수까지 견주므로, 이번에는 꼴 하나를 막은 것이 아니라 모양의 종류를 닫았다. 코드 논증과 세 시험(따옴표 bool · 줄 머리 BOM · 병합 키)에서 reader · `loadYaml` · analyzer 가 갈려 헛통과하는 입력은 없었다. 남는 위험은 SDK 가 품은 package:yaml 판을 재지 못한 것뿐이다.

**경고 셋 (gap 아님):** IN-12 (맞는 YAML 의 거짓 실패), IN-13 (`pubspec.yaml` 의 낡은 주석 — SC5 범위 밖), IN-14 (문서 주석과 255) — 위 표의 소유자 결정.

자동으로 가를 수 있는 must-have 92개가 모두 참이고, 상태는 사람 확인 여섯 때문에 `human_needed` 다.

---

_Verified: 2026-10-14T22:28:34Z_
_Verifier: Claude (gsd-verifier)_
