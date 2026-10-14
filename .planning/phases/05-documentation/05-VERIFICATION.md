---
phase: 05-documentation
verified: 2026-10-14T03:38:00Z
status: gaps_found
score: 50/53 must-haves verified
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
covered_digest: "v3:sha256:99374fb51b6b2d77b3cbc9a20f979de3c152aedb14899f7cb85033b72f27748a"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 23/25
  gaps_closed:
    - "gaps 1 — README 표시 구역 안의 옛 README 꼴 `- require_trailing_commas: 자동 코드 정렬 최적화` · `* `x`` · `+ `x`` · `1. `x`` · `- x` · `- `Extra_Rule`` 이 `[3/10]` 실패 (전체 실행 M43 rc 1 · 10개 중 1개 실패, 함수 단위 다섯 줄 `(5)`)"
    - "gaps 2 — `lib/codegen.yaml` · `lib/riverpod.yaml` 끝의 flow 표기 `linter: {rules: […]}` 가 종료 코드 70 · 빈 stdout (전체 실행 M45 rc 70)"
  gaps_remaining: []
  regressions: []
  new_gaps:
    - "같은 모양의 다른 입력 — 다른 조각의 `linter` 키를 다른 철자(`linter :` · `\"linter\":`)로 적으면 (b′) 가 그 블록을 통째로 지나쳐 10개 중 10개 (아래 gaps)"
gaps:
  - truth: "규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 — `lib/codegen.yaml` · `lib/riverpod.yaml` 에 규칙을 적으면 검증 명령이 잡고, README 비교가 `lib/base.yaml` 하나만 봐도 빈자리가 없다 (성공 기준 3 · VERIFY-06 · 05-01 truth 3 · 05-07 truth 7 · README 378행)"
    status: failed
    reason: "`declaredRuleNames` 는 열 0 의 글자 `^linter:` 로만 linter 블록을 찾고, 그 밖의 최상위 키 아래 들여쓴 줄은 모두 조용히 건너뛴다. YAML 에서 같은 키인 `linter :` (콜론 앞 공백) 이나 `\"linter\":` (따옴표 키) 로 블록 목록을 적으면 (b′) 가 규칙 0개로 읽는다. 검증자 복제본 전체 실행: `lib/codegen.yaml` 끝에 `linter :` / `  rules:` / `    - prefer_mixin` → 종료 코드 0 · `점검 통과 (10개 중 10개)`; 같은 꼴의 `\"linter\":` → 0 · 10/10; `lib/riverpod.yaml` 끝에 `linter :` 꼴 → 0 · 10/10. 사용 프로젝트에 닿는다 — 같은 자리에 `always_specify_types` 를 두면 `fixtures/base_codegen` 의 `fvm dart analyze` 에 그 진단 25건 (`linter :` · `\"linter\":` 모두). 정답지는 샘플이 그 규칙에 걸릴 때만 잡는다 (`always_specify_types` 는 `[5/10]` · `[9/10]` · `[10/10]` 실패, `prefer_mixin` 은 통과). 05-VERIFICATION gaps 2 와 같은 모양(블록을 찾지 못한 입력을 0개로 통과)이고 고친 자리(`linter:` 줄의 값) 바로 옆의 다른 입력이다. 개연성은 낮다 — 두 철자 모두 이 저장소의 YAML 관례 밖이다. 그러나 README 378행은 '다른 조각에 규칙을 적으면 검증 명령이 잡는다 — 블록 목록이면 `[3/10]` 단계가 실패' 라고 단정하고, 이 입력은 블록 목록이다."
    artifacts:
      - path: "tool/verify.dart"
        issue: "declaredRuleNames (910 ~ 956행): `RegExp(r'^linter:')` 에 맞지 않는 열 0 줄은 `inLinter = false` 로 처리되어 그 아래 줄을 읽지 않는다 — 다른 조각에서는 '모르는 최상위 키' 와 '다른 철자의 linter 키' 를 가르지 못한다; (b′) (1674 ~ 1688행) 가 그 0개를 통과로 본다"
      - path: "README.md"
        issue: "378행 '블록 목록이면 `[3/10]` 단계가 실패하고' 가 `linter :` · `\"linter\":` 블록 목록에서 거짓"
    missing:
      - "`lib/base.yaml` 밖 조각의 최상위 키를 닫힌 목록으로 본다 — `lib/codegen.yaml` 은 `analyzer`, `lib/riverpod.yaml` 은 `plugins` 만 받고, 열 0 의 그 밖의 줄(키 이름을 읽지 못하는 줄 포함)은 `[3/10]` 실패나 70 으로 알린다 (05-REVIEW.md WR-10 의 Fix 와 같은 장치 — 이 gap 과 WR-10 을 함께 닫는다). 철자를 하나씩 더 받는 정규식 수정은 같은 모양을 다시 남긴다"
      - "지워 보기 기록(example/README.md): `lib/codegen.yaml` 끝의 `linter :` 블록 목록 · `\"linter\":` 블록 목록이 각각 `[3/10]` 실패(또는 70)임을 실제로 돌려 적는다; 기준 실행 10개 중 10개 유지"
      - "README 378행 문장이 고친 동작과 같은지 다시 본다"
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
    why_human: "문장 단위의 단정 / 출처 구분은 사람이 판단한다 (05-VALIDATION Manual-Only)"
  - test: "CHANGELOG 1.1.0 ~ 1.2.5 복원 일곱 항목마다 적힌 커밋을 `git show` 로 열어 적힌 변경과 대조한다"
    expected: "항목의 문장이 diff 의 변경만 말하고 커밋 메시지를 옮기지 않았다 (이 검증의 첫 회차가 일곱 항목과 부수 커밋을 대조해 일치를 기록했다 — 이번 gap 수정은 CHANGELOG 의 92행 한 줄만 바꿨다)"
    why_human: "문장의 사실 여부는 grep 으로 가를 수 없다 (05-VALIDATION Manual-Only)"
  - test: "README 의 외부 링크 넷을 브라우저로 연다 — flutter#191151 (googlesource 커밋), dart-lang/sdk#64549, dart.dev/tools/pub/workspaces (인용문), pub.dev 의 riverpod_lint 설치 안내"
    expected: "링크가 열리고, 인용문과 요약이 페이지 내용과 같다"
    why_human: "외부 페이지는 검증 명령이 보지 않는다"
---

# Phase 5: Documentation 검증 보고서 (재검증)

**Phase 목표:** 소유자가 몇 달 뒤 README 만 보고 설치, 프리셋 선택, 규칙 재정의, 버전 올리기를 그대로 따라 할 수 있고, README / CHANGELOG / YAML 주석이 실제 설정과 일치하며 그 일치가 검증으로 지켜진다
**검증 시각:** 2026-10-14
**상태:** gaps_found
**재검증:** 예 — gap 수정 05-07 · 05-08 · 05-09 뒤 (이전 gaps_found 23/25)

방법: 저장소를 `git clone --local` 로 두 번 복제했다 (scratchpad 아래 검증자 폴더, 작업 트리는 건드리지 않음). 복제본마다 루트 `fvm dart pub get --no-example` 뒤 기준 실행 `fvm dart run tool/verify.dart` 가 종료 코드 0 · `점검 통과 (10개 중 10개)` 였다 (첫 실행 69초). 입력을 바꾼 실험은 두 가지다 — 전체 실행 19회, 그리고 `tool/verify.dart` 를 import 해 `checkShippedComposition` 을 직접 부르는 하네스(복제본 밖) 30여 회. 변형마다 `git checkout -- .` 로 되돌리고 `git status --porcelain` 0줄을 확인했다. 작업 트리는 끝까지 GSD 도구 상태 넷(`.planning/config.json` 수정 등) 밖의 변경이 없었다.

## 목표 달성

### 관찰 가능한 참 (Observable Truths)

ROADMAP 성공 기준 5개, 첫 회차의 plan truth 20개(회귀 확인), gap plan 05-07 · 05-08 · 05-09 의 truth 28개.

**성공 기준 (ROADMAP)**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| SC1 | README 의 설치 안내와 유형별 include 블록을 그대로 복사해 `ref: vX.Y.Z` 로 추가할 수 있다 | ✓ VERIFIED | 회귀: 「설치」 블록(13 ~ 19행) `ref: v2.0.0`, include 블록 넷이 `fixtures/{recommended,base_only,base_riverpod,base_codegen}/analysis_options.yaml` 의 비주석 줄과 같다(직접 대조). gap 수정은 README 의 이 절을 바꾸지 않았다. 실제 tag 설치는 Phase 6 (Deferred) |
| SC2 | 끄기 · 버전 올리기 · `ref: main` → tag · 문제 해결 절, 재정의가 Phase 3 fixture 와 같다 | ✓ VERIFIED | 회귀: 절 제목 그대로(216 · 304 · 324 · 345행), 끄기 블록(224 ~ 237행)의 `version: ^3.1.9` 가 `fixtures/overrides` 와 같고 `[4/10]` 통과 |
| SC3 | README 의 규칙 · 설정 설명이 실제 YAML 과 일치하고, 규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 | ✗ FAILED | **앞 절반은 참:** 표시 구역 81개 == `lib/base.yaml` (기준 실행 `[3/10]` 통과), `require_trailing_commas` · `trailing_commas` 0줄. **지난 gap 둘은 닫혔다:** 옛 README 꼴 M43 전체 실행 rc 1 · `[3/10]` 실패 · `구역에 읽지 못하는 줄이 있다 (1)`; flow 표기 M45 rc 70 · 빈 stdout. **뒤 절반은 새 입력에서 거짓:** `lib/codegen.yaml` 에 `linter :` 블록 목록 → rc 0 · 10/10, `"linter":` → 0 · 10/10, `lib/riverpod.yaml` 에 `linter :` → 0 · 10/10; 같은 꼴의 규칙이 사용 프로젝트에 닿는다(`always_specify_types` 25건). gaps 1번 |
| SC4 | CHANGELOG 최상단 새 항목(Phase 1 형식), 1.0.0 ~ 1.3.0 사이 보완 | ✓ VERIFIED | 회귀: 1행 `## 2.0.0 - 미출시`, 3행 `지원 SDK:`, 제목 순서 2.0.0 · 1.3.0 · 1.2.5 … 1.1.0 · 1.0.0. gap 수정의 변경은 92행 한 줄(IN-02 — 아래 09-9) |
| SC5 | 배포 YAML 머리 주석이 실제 구성을 설명, 보일러플레이트 없음 | ✓ VERIFIED | 회귀: `git diff 209e3af HEAD -- lib` 는 `lib/riverpod.yaml` 5행의 줄 끝 주석 한 줄뿐(선언 `^3.1.9` 불변) |

**첫 회차 plan truth — 회귀 확인**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 01-1 | plugin 줄 끝 주석 · 마지막 줄바꿈 없음에서 통과 | ✓ VERIFIED | HEAD 의 `lib/riverpod.yaml` 5행이 긴 줄 끝 주석을 단 채 기준 실행 10/10 |
| 01-2 | `riverpod_lint:` 선언을 지우면 70 · `선언을 찾지 못했다` | ✓ VERIFIED | 소스 1332행 문구 그대로; M66 은 다른 문구(아래 09-4) |
| 01-3 | `lib/codegen.yaml` · `lib/riverpod.yaml` 에 규칙을 적으면 실패 — README 비교가 `lib/base.yaml` 하나만 봐도 빈자리가 없다 | ✗ FAILED | 블록 꼴 `linter:` (M35) · flow 꼴 (M45) 은 잡는다. `linter :` · `"linter":` 블록 목록은 `[3/10]` 통과 · 10/10 (gaps 1번) |
| 01-4 | 다른 조각의 읽지 못하는 줄 → 70 문구에 파일 이름 | ✓ VERIFIED | 함수 단위: `lib/codegen.yaml` 의 `prefer_single_quotes: false` → `lib/codegen.yaml 의 `linter:` 블록의 12행을 읽지 못했다` |
| 01-5 | `stripPlugins` 가 섹션을 빈 줄로 | ✓ VERIFIED | 815행 그대로 (gap 수정이 건드리지 않음) |
| 01-6 | M32 ~ M37 기록 · 처리 기록 fixed | ✓ VERIFIED | `example/README.md` 의 `| M3[2-7] |` 행 6개 그대로 |
| 02-1 ~ 02-4 | 머리 주석 다섯, 템플릿 없음, 규칙 81줄 불변, riverpod 주석, codegen 머리 주석 | ✓ VERIFIED | `lib/` 의 비주석 내용은 `209e3af` 와 같다(riverpod 5행은 줄 끝 주석만) |
| 02-5 | `.claude/CLAUDE.md` 는 71 · 181행만 | ✓ VERIFIED | 마지막 변경 커밋 `403c584` 그대로 |
| 04-4 ~ 04-6 | CHANGELOG `### 올리기 전에` · `### 그 밖의 변경` · 01 WR-05 fixed | ✓ VERIFIED | gap 수정이 바꾼 CHANGELOG 줄은 92행 하나 |
| 05-1 ~ 05-3 | 첫 push, 비공개 점검, GitHub verify | ✓ VERIFIED | `git ls-remote origin`: `main` `90a2736`, tag `v1.3.0` 만, 작업 브랜치 `8789cfe`; `gh pr list --state all` → `[]` |
| 06-1 ~ 06-3 | M38 ~ M42, 기록 소절, 지워 보기 미커밋 | ✓ VERIFIED | `| M(3[89]|4[0-2]) |` 행 5개 그대로; `1d28346..HEAD` 에서 지운 줄은 70 행 · 단계 설명의 덧붙임 자리 둘뿐 |

(02-1 ~ 02-4, 04-4 ~ 04-6, 05-1 ~ 05-3, 06-1 ~ 06-3 은 묶어 적었다 — 개수는 20개 그대로 센다.)

**gap plan 05-07**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 07-1 | 옛 README 꼴 한 줄 → rc 1 · `[3/10]` 실패 · `구역에 읽지 못하는 줄이 있다 (1)` (M43) | ✓ VERIFIED | 전체 실행: rc 1, `[3/10] … 실패`, `[4/10] … 통과`, `점검 실패 (10개 중 1개)`, 그 줄 원문 |
| 07-2 | `* `extra`` · `- `Extra_Rule`` → `(2)`, 이름 비교 블록 없음 (M44) | ✓ VERIFIED | 함수 단위: 다섯 줄(`*` · `+` · `1.` · `- d_x` · `` `Extra_Rule` ``)을 함께 넣어 `(5)`, `규칙 목록이 다르다` 블록 없음 |
| 07-3 | `lib/codegen.yaml` 끝 flow `linter: {rules: [prefer_mixin]}` → 70 · 빈 stdout · `10행: `linter:` 줄에 값이 붙어 있다` (M45) | ✓ VERIFIED | 전체 실행: rc 70, stdout 0 바이트, stderr `파일 모양이 예상과 다르다: lib/codegen.yaml 의 10행: …`. `lib/riverpod.yaml` 의 맵 flow 도 70 (함수 단위) |
| 07-4 | 줄 끝 주석 단 블록 꼴은 `[3/10]` 실패 (M46) | ✓ VERIFIED | 05-VALIDATION 감사 rc 0 (task 커밋 `057bef2`); 같은 코드 경로를 블록 꼴 M35 로 확인 |
| 07-5 | 지금 README · RULES.md · lib 로 기준 실행 10/10 | ✓ VERIFIED | 복제본 둘 모두 rc 0 · 10/10 |
| 07-6 | 마커 처리는 `readMarkerBlock` 하나, 타입 `MarkerBlock` | ✓ VERIFIED | 1500 · 1517행, 두 reader 첫 줄이 `readMarkerBlock`; `indexOf` 마커 두 줄은 1520 · 1521행에만 |
| 07-7 | README 378행 불릿이 블록 목록(`[3/10]` 실패)과 flow(70)를 구분해 말하고 단정이 참이 된다 | ✗ FAILED | 문장은 그대로 고쳐졌으나 `linter :` · `"linter":` 블록 목록에서 '`[3/10]` 단계가 실패' 가 거짓 (gaps 1번) |
| 07-8 | 코드 블록 값 M47 ~ M50 | ✓ VERIFIED | 함수 단위: M47 `^3.1.3` 다른 버전 블록, M48 `ref: v1.9.0` 블록, M49 `읽지 못하는 … (1)`, M50 (따옴표 맞는 값 · 주석만 붙은 맵 키) `passed=true` |
| 07-9 | M43 ~ M50 기록, M1 ~ M42 불변 | ✓ VERIFIED | `| M(4[3-9]|50) |` 8행, 앞 행 수 그대로 |

**gap plan 05-08**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 08-1 | RULES.md 표 구역 M51 ~ M53 | ✓ VERIFIED | 함수 단위: M51 · M52 `(1)`, M53 `(2)`, 표 비교 블록 없음 |
| 08-2 | 지금 RULES.md 두 구역(`없음 — …` 포함)으로 10/10 | ✓ VERIFIED | 기준 실행 |
| 08-3 | `readRulesTable` 문서 주석만, 코드 불변 | ✓ VERIFIED | `git diff c06d8d5 HEAD -- tool/measure_rules.dart` 의 바뀐 줄은 모두 `///` (코드 줄 0); 4778행 `보다 느슨한 옛 규약` |
| 08-4 | 주소 M54 · M55 | ✓ VERIFIED | 함수 단위: M54 `꼴이 아닌 것이 있다 (1)`, M55 `woody_lints 가 아닌 패키지 … (2)` |
| 08-5 | 펜스 M56 ~ M58 | ✓ VERIFIED | 함수 단위: 셋 모두 `ref: v1.9.0` 블록 |
| 08-6 | 옵션 flow · 읽지 못하는 옵션 줄 → 70 (M59 ~ M61) | ✓ VERIFIED | 함수 단위: `97행: `language:` 줄에 값이 붙어 있다`, `96행: `analyzer:` 줄에 값이 붙어 있다`, `98행을 읽지 못했다` |
| 08-7 | 주석 단 블록 꼴 옵션은 `+ strict-casts` 실패 (M62) | ✓ VERIFIED | 함수 단위 `passed=false` · `+ strict-casts  (base.yaml 에만)` |
| 08-8 | M51 ~ M62 기록, 앞 행 불변 | ✓ VERIFIED | `| M(5[1-9]|6[0-2]) |` 12행 |

**gap plan 05-09**

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| 09-1 | 따옴표 선언 `"^3.1.9"` → 10/10 (M63) | ✓ VERIFIED | 함수 단위 `[3/N]` `passed=true`; 05-VALIDATION 감사(전체 실행) rc 0 |
| 09-2 | 고정 버전 `3.1.9` 넷 → `[3/10]` · `[4/10]` 통과, 70 아님 (M64) | ✓ VERIFIED | 전체 실행: `lib/riverpod.yaml` · README 198 · 234행 · `fixtures/overrides` 10행을 `3.1.9` 로 → rc 0, `[3/10]` · `[4/10]` 통과, `점검 통과 (10개 중 10개)`, stderr 에 `파일 모양이 예상과 다르다` 없음 |
| 09-3 | 키 줄 주석 · `diagnostics:` 먼저인 맵 → 통과, 70 아님 (M65) | ✓ VERIFIED | 전체 실행: 5행을 `  riverpod_lint: # 맵 꼴` / `    diagnostics:` / `      missing_provider_scope: true` / `    version: ^3.1.9` 로 → rc 0, 10/10, 70 머리말 없음 |
| 09-4 | 범위 제약 → 70 · 원인 문구, `찾지 못했다` 없음 (M66) | ✓ VERIFIED | 함수 단위: `` riverpod_lint 선언 `>=3.1.9 <4.0.0` 을 읽지 못했다 — `^X.Y.Z` 나 `X.Y.Z` 꼴만 받는다 `` |
| 09-5 | pubspec `version: "2.0.0-dev"` → 10/10 (M67) | ✓ VERIFIED | 함수 단위 `passed=true`; 감사 rc 0 |
| 09-6 | `[1/4]` · `[2/4]` 없음 | ✓ VERIFIED | grep 0줄 |
| 09-7 | README 산문에 지금 plugin 버전 숫자 없음 | ✓ VERIFIED | `^3.1.9` 는 198 · 234행 코드 블록뿐; 342 · 372행의 `3.1.9` 는 날짜 붙은 실측 기록(spike 010) |
| 09-8 | 함께 고칠 자리 셋이 README 382행 한 곳, `lib/riverpod.yaml` 5행 주석이 같은 셋 | ✓ VERIFIED | 382행 · riverpod 5행 원문 대조 |
| 09-9 | README 45 · 91행, CHANGELOG 92행 문장 | ✓ VERIFIED | 45행 묶음은 `example/` 결과와 견준다, 91행 '이름만 견주고 분류는 보지 않는다', CHANGELOG 92행 '나누는 변경 자체는 …' |
| 09-10 | 처리 기록 fixed 12 · deferred 1 · open 0 | ✓ VERIFIED | `git show 8789cfe:…/05-REVIEW-DISPOSITION.md` → `open: 0` · `total: 13`. 지금 파일의 `open: 5` 는 그 뒤 재리뷰(`ddfb852`)가 더한 새 발견이다 — 판정은 아래 「05-REVIEW 재리뷰 발견의 판정」 |
| 09-11 | push · GitHub verify 성공, `main` · tag · PR 불변 | ✓ VERIFIED | `gh run view 38502214557`: `completed` · `success` · push · headSha `8789cfe…`, 로그에 `[3/10] 배포 파일의 구성 … 통과` · `점검 통과 (10개 중 10개)`; `8789cfe..HEAD` 는 README · lib · tool · CHANGELOG · example · fixtures · RULES · pubspec · `.claude` 를 바꾸지 않았다(diff 0) |

**점수:** 50/53 참 확인 (present · behavior-unverified 0). 실패 셋(SC3 · 01-3 · 07-7)은 뿌리가 하나다 — gaps 1번.

### Deferred Items

| # | 항목 | 다룰 phase | 근거 |
|---|------|-----------|------|
| 1 | README 의 `ref: v2.0.0` 블록으로 실제로 받는 것 (tag 가 아직 없다) | Phase 6 | 성공 기준 3 |

새 gap 은 Phase 6 (tag · 릴리스 smoke test) 의 범위에 들지 않는다 — 미루지 않았다.

### 05-REVIEW 재리뷰 발견의 판정 (orchestrator 요청)

판정 기준: 이 phase 가 말한 참(ROADMAP 성공 기준, plan must_haves, README · CLAUDE.md 의 "검사가 지킨다" 문장)이 그 입력에서 거짓이 되고, 그 참이 **VERIFY-06 의 약속 — README 의 규칙 목록과 사용 프로젝트가 받는 규칙이 다르면 검증이 실패한다** 에 속하면 gap. (e) ~ (g) 같은 D-02 보조 검사의 꼴 문제는 첫 회차의 W1 ~ W3 와 같은 등급(경고)으로 둔다 — 그 plan truth 들은 입력을 하나하나 적었고 모두 참이다. 모두 복제본에서 재현했다.

| 발견 | 재현 (검증자) | 판정 | 이유 |
|------|---------------|------|------|
| WR-07 (e) 가 `package:` 로 시작하지 않는 주소를 안 봄 | 전체 실행: README 68행 `- packages:woody_lints/riverpod.yaml` → rc 0 · 10/10. 함수 단위: 58행 `include: package: woody_lints/base.yaml` → `passed=true` | ⚠️ 경고 | 성공 기준 · VERIFY-06 은 주소 검사를 약속하지 않는다 (SC1 은 지금 README 가 복사 가능한가 — 참). `example/README.md` 116행은 "`package:` 주소가 … 꼴이 아니면 실패" 라고 적는데 `packages:` 는 그 낱말에 들지 않는다. `package: woody…` (콜론 뒤 공백) 은 그 문장이 덮는다고 읽을 수 있어 문장이 구현보다 넓다 |
| WR-08 (f) · (g) 가 flow 표기 키를 안 봄 | 전체 실행: 196 ~ 199행을 `plugins: {riverpod_lint: ^3.1.3}` → rc 0 · 10/10; 「설치」 를 `woody_lints: {git: {url: …, ref: v1.9.0}}` → rc 0 · 10/10 | ⚠️ 경고 (문장 과장) | VERIFY-06 밖. 다만 README 382행 "`ref:` 예시 둘 … plugin 버전 예시 둘 … 검증 명령이 모두 견준다" 는 그 예시를 flow 로 고쳐 쓰면 거짓이 된다. 문장이 가리키는 "버전을 올리며 예시를 빠뜨리는" 경우는 지금 꼴의 블록에서 잡힌다(M40 · M41 · M47 · M48). 예시의 꼴을 바꾸면서 낡은 값을 남기는 입력이다 |
| WR-09 펜스가 아닌 코드 블록 | 전체 실행: 「tag 로 옮기기」 블록을 네 칸 들여쓴 블록 + `ref: v1.9.0` → rc 0 · 10/10; **인용 안의 펜스**(`> ```yaml` … `>       ref: v1.9.0`, 리뷰어는 돌리지 않음) → rc 0 · 10/10 | ⚠️ 경고 (문장 과장) | VERIFY-06 밖. `example/README.md` 116행은 "코드 블록은 ``` 와 `~~~` 펜스를 문자 · 길이로 가린다" 로 범위를 펜스로 적었다 — 그 문장과는 맞다. README 382행의 "모두 견준다" 와는 WR-08 과 같은 방식으로 어긋난다 |
| WR-10 `[3/10]` 이 조각의 `linter:` 밖 키를 안 봄 | 전체 실행: `lib/codegen.yaml` 의 `analyzer:` 아래 `language: strict-inference: true` → rc 0 · 10/10; 끝에 `formatter: trailing_commas: preserve` → rc 0 · 10/10 | ⚠️ 경고 — **단, 같은 뿌리가 gap 을 낸다** | 규칙이 아닌 키라 VERIFY-06 밖이다. `RULES.md` 의 켠 옵션 표는 "`lib/base.yaml` 의 `analyzer: language:`" 로 범위를 적었고, README 214행 "`formatter:` 설정은 어느 프리셋에도 넣지 않는다" 는 정책 문장이지 검사가 지킨다는 문장이 아니다. 그러나 같은 뿌리 — 조각이 받을 최상위 키를 검사가 모른다 — 가 **다른 철자의 `linter` 키로 규칙을 들이는 입력**을 통과시킨다 (gaps 1번). 리뷰의 Fix(조각마다 최상위 키를 닫힌 목록으로)가 둘을 함께 닫는다 |
| IN-08 주소 끝 문장 부호 | 함수 단위: 산문 끝 `package:woody-lints/base.yaml.` → `passed=true` (다른 패키지 주소 누락); `package:woody_lints/recommended.yaml,` → `꼴이 아닌 것이 있다 (1)` (거짓 실패, 큰 소리) | ℹ️ 정보 | 산문 주소이고 지금 README 의 주소는 모두 backtick 안이다. `example/README.md` 436행 "`package:<이름>/….yaml` · `….yml` 를 모두 모아" 는 이 입력에서 넓다 |

검증자가 더 돌린 같은 모양의 입력:

| 입력 | 결과 | 판정 |
|------|------|------|
| `lib/codegen.yaml` 끝 `linter :` / `  rules:` / `    - prefer_mixin` | 전체 실행 rc 0 · 10/10 | 🛑 gap (gaps 1번) |
| 같은 꼴 `"linter":` | 전체 실행 rc 0 · 10/10 | 🛑 gap |
| `lib/riverpod.yaml` 끝 `linter :` 꼴 | 전체 실행 rc 0 · 10/10 | 🛑 gap |
| `linter :` 꼴로 `always_specify_types` | `fixtures/base_codegen` 분석 25건 (사용 프로젝트에 닿음); 전체 실행 rc 1 — `[3/10]` 은 통과, `[5/10]` · `[9/10]` · `[10/10]` 정답지 차이로만 실패 | 정답지는 샘플이 걸리는 규칙만 잡는다 |
| `lib/codegen.yaml` 의 `analyzer: errors:` 에 `prefer_single_quotes: ignore` | `[3/10]` 통과, 정답지 셋 실패 (rc 1) | ℹ️ 정보 — 규칙 목록이 아니라 심각도 재정의이고 정답지가 잡았다 |
| README 표시 구역 end 마커 바로 뒤에 `- `bogus_after_marker`` | 전체 실행 rc 0 · 10/10. 렌더링된 README 에서는 「받는 규칙」 마지막 목록에 붙어 보인다 | ⚠️ 경고 — 검사 대상을 마커 구역으로 정한 것은 D-01 (README 379행도 "표시 구역" 이라 적는다). 같은 절 안 마커 밖의 불릿을 실패로 돌리는 것은 다음 gap plan 에서 값싸게 더할 수 있다 |

**"같은 모양, 다른 입력" 에 대한 답:** 이번에도 나왔다. 05-07 이 `linter:` 줄에 붙은 값(flow)을 닫았지만, reader 가 **블록을 찾는 방법** 자체(열 0 의 글자 `linter:`)는 그대로라 다른 철자의 키 아래 블록이 통째로 빠진다. 정규식에 철자를 하나 더 받는 수정은 같은 모양을 다시 남긴다 — 조각마다 받는 최상위 키를 닫힌 목록으로 두는 수정(WR-10 의 Fix)이 이 모양을 구조적으로 닫는다. (e) ~ (g) 쪽 WR-07 ~ WR-09 · IN-08 은 문서화된 보장(성공 기준 · VERIFY-06)에는 들지 않지만, README 382행과 `example/README.md` 116 · 436행의 문장이 구현보다 넓다 — 다음 gap plan 에서 문장을 구현에 맞게 좁히거나 검사를 넓히기를 권한다.

### Required Artifacts

| Artifact | 기대 | 상태 | 세부 |
|----------|------|------|------|
| `tool/verify.dart` | `readMarkerBlock` · 엄격한 `readBulletBlock` · `readRulesMdBlock`, flow 거부 `declaredRuleNames` · `enabledLanguageOptions`, `unquotedScalar`, (e) ~ (g) 강화, plugin · pubspec reader | ⚠️ 있음 · 연결됨 · 일부 fail-open | (b′) 가 다른 철자의 `linter` 키를 건너뛴다 (gaps 1번); (e) ~ (g) 의 꼴 경고 |
| `README.md` | 378 · 45 · 91 · 239 · 372 · 382행 | ⚠️ | 378행 단정이 gap 입력에서 거짓, 382행 "모두 견준다" 가 넓음(경고) |
| `CHANGELOG.md` | 92행 | ✓ VERIFIED | |
| `lib/riverpod.yaml` | 5행 줄 끝 주석만 | ✓ VERIFIED | |
| `tool/measure_rules.dart` | `///` 만 | ✓ VERIFIED | |
| `example/README.md` | M43 ~ M67 소절 셋, 앞 행 불변 | ✓ VERIFIED | |
| `05-REVIEW-DISPOSITION.md` | 05-09 시점 fixed 12 · deferred 1 · open 0 | ✓ VERIFIED | 지금 open 5 는 재리뷰 발견 — 판정은 위 표 |

### Key Link Verification

| From | To | Via | 상태 | 세부 |
|------|----|-----|------|------|
| `tool/verify.dart` | `README.md` | `readBulletBlock` → (d) | ✓ WIRED | 구역 안의 모르는 줄이 실패 (M43 전체 실행) |
| `tool/verify.dart` | `lib/codegen.yaml` · `lib/riverpod.yaml` | (b′) `declaredRuleNames` | ⚠️ PARTIAL | `linter:` 블록 · flow 는 잡고, 다른 철자의 키는 건너뜀 |
| `tool/verify.dart` | `RULES.md` | `readRulesMdBlock` → (c) | ✓ WIRED | M51 ~ M53 |
| `tool/verify.dart` | `lib/base.yaml` | `enabledLanguageOptions` | ✓ WIRED | M59 ~ M62 |
| `tool/verify.dart` | `README.md` | (e) · (f) · (g) | ✓ WIRED (경고 있음) | 블록 꼴 · 펜스 안의 값만 |
| `tool/verify.dart` | `lib/riverpod.yaml` · `pubspec.yaml` | `readShippedPluginConstraint` · `pubspecReleaseVersion` | ✓ WIRED | M63 ~ M67 |
| 로컬 브랜치 | origin | `git push origin gsd/v2.0-package-rework` | ✓ WIRED | origin `8789cfe`; 로컬은 그 뒤 메타데이터 커밋 7개 |

### Behavioral Spot-Checks (전체 실행)

| 동작 | 결과 | 상태 |
|------|------|------|
| 기준 실행 (복제본 둘) | rc 0 · `점검 통과 (10개 중 10개)` | ✓ PASS |
| M43 옛 README 꼴 | rc 1 · `[3/10]` 만 실패 · `(1)` | ✓ PASS (지난 gaps 1 닫힘) |
| M45 codegen flow | rc 70 · stdout 0 바이트 · `10행: `linter:` 줄에 값이 붙어 있다` | ✓ PASS (지난 gaps 2 닫힘) |
| M64 고정 버전 넷 | rc 0 · `[3/10]` · `[4/10]` 통과 · 10/10 · 70 없음 | ✓ PASS |
| M65 맵 꼴 · 키 순서 | rc 0 · 10/10 · 70 없음 | ✓ PASS |
| codegen `linter :` 블록 목록 | rc 0 · 10/10 | ✗ FAIL (gaps 1) |
| codegen `"linter":` 블록 목록 | rc 0 · 10/10 | ✗ FAIL (gaps 1) |
| riverpod `linter :` 블록 목록 | rc 0 · 10/10 | ✗ FAIL (gaps 1) |
| WR-07 · WR-08 (둘) · WR-09 (둘) · WR-10 (둘) · 마커 뒤 불릿 | 모두 rc 0 · 10/10 | ⚠️ 경고 |

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
| DOCS-06 | 05-03 · 05-07 · 05-09 | ✓ SATISFIED (지금 상태) | 표시 구역 · 코드 블록 값이 YAML 과 같다. 378행의 검사 설명 문장은 gaps 1번과 함께 고친다 |
| DOCS-07 | 05-04 · 05-09 | ✓ SATISFIED | SC4, 92행 |
| DOCS-08 | 05-04 | ✓ SATISFIED | 첫 회차 diff 대조, 이번 회차 변경 없음 (사람 확인 3번) |
| DOCS-09 | 05-04 | ✓ SATISFIED | 변경 없음 |
| DOCS-10 | 05-01 · 05-02 | ✓ SATISFIED | SC5 |
| VERIFY-06 | 05-01 · 05-03 · 05-05 ~ 05-09 | ✗ BLOCKED | gaps 1번 — 다른 철자의 `linter` 키로 다른 조각에 적은 규칙이 사용 프로젝트에 닿는데 10/10 |

ORPHANED 없음 — REQUIREMENTS.md 가 Phase 5 에 매긴 11개가 모두 plan 의 `requirements` 에 있다. REQUIREMENTS.md 의 체크 표시(VERIFY-06 · DOCS-06 · DOCS-07 `[x]`, 나머지 여덟 `Gaps Found`)는 증거와 다르다 — VERIFY-06 은 BLOCKED, 여덟은 SATISFIED 다.

### Anti-Patterns

| 파일 | 줄 | 패턴 | 심각도 | 영향 |
|------|----|------|--------|------|
| `tool/verify.dart` | 926 · 937 | 열 0 의 `^linter:` 글자가 아니면 블록 밖으로 보고 그 아래 줄을 읽지 않음 | 🛑 Blocker | gaps 1번 |
| `tool/verify.dart` | 1797 · 1820 · 1859 · 1904 · 1377 | `package:` 글자 · 줄 머리 키 · 펜스에만 맞추는 후보 수집 | ⚠️ Warning | WR-07 ~ WR-09 · IN-08 |
| `tool/verify.dart` | 1674 · 1746 | 조각의 `linter:` 밖 키와 `lib/base.yaml` 밖의 `language:` 를 보지 않음 | ⚠️ Warning | WR-10 (gaps 1 과 같은 뿌리) |

`TBD` · `FIXME` · `XXX` 표식: 바뀐 파일에 0개. 공개 파일의 절대 경로 꼴 0줄.

### 금지 사항(prohibitions) 확인

판단 등급 항목 가운데 기계로 가를 수 있는 것은 직접 확인했다 — 배포 설정 내용 불변(`lib` 의 변경은 riverpod 5행 줄 끝 주석뿐, `RULES.md` · `pubspec.yaml` · `fixtures` 는 고정 커밋과 같음), M1 ~ M42 행 수 · 문구 불변(`example/README.md` 에서 지운 줄은 덧붙임 자리 둘), `.claude/CLAUDE.md` 불변(WR-06 deferred), `tool/measure_rules.dart` 는 `///` 줄만, `readUpstreamRules` (`readSet` 포함) 는 `e69470e` 와 글자가 같음, (d) 에 분류 검사 없음, 원격 `main` `90a2736` · tag `v1.3.0` 하나 · PR 0, 공개 파일의 절대 경로 꼴 0줄. "지워 보기는 복제본에서 했다" 는 작업 트리와 이력에 변형 흔적이 없다는 것까지만 확인할 수 있다.

### Human Verification Required

gap 을 닫은 뒤에도 남는 사람 확인 넷이다 (frontmatter `human_verification`).

1. **README 를 처음부터 따라 하기** — 설치 → 프리셋 고르기 → 끄기 세 층 → 버전 올리기 세 갈래.
2. **단정 / 출처 문장 단위 확인** — 끄기 · 생성 파일 제외 · 버전 올리기 · 문제 해결.
3. **CHANGELOG 복원 일곱 항목과 `git show` diff 대조** — 첫 회차 검증이 대조해 일치를 기록했고 이번 회차는 CHANGELOG 92행만 바뀌었다.
4. **외부 링크 넷 열기.**

### Gaps 요약

지난 gap 둘은 닫혔다 — 옛 README 꼴은 `[3/10]` 실패, flow 표기는 종료 코드 70 (둘 다 전체 실행으로 확인). 05-08 · 05-09 의 truth 도 모두 돌린 대로다.

**새 gap 하나 (뿌리 하나, 실패 truth 셋 — SC3 뒤 절반 · 05-01 truth 3 · 05-07 truth 7):** (b′) 가 다른 조각에서 linter 블록을 열 0 의 글자 `linter:` 로만 찾는다. YAML 에서 같은 키인 `linter :` · `"linter":` 로 블록 목록을 적으면 블록이 통째로 빠져 규칙 0개 · 10개 중 10개이고, 그 규칙은 사용 프로젝트에 닿는다. 개연성은 낮다(두 철자 모두 이 저장소의 관례 밖). 그러나 README 378행은 "블록 목록이면 `[3/10]` 단계가 실패" 라고 단정하고, 지난 gaps 2 도 개연성 낮음으로 적은 채 gap 으로 닫았다 — 같은 기준을 적용했다.

권하는 수정은 철자를 더 받는 정규식이 아니라 **조각마다 받는 최상위 키를 닫힌 목록으로 두는 것**이다 (05-REVIEW WR-10 의 Fix). 그러면 이 gap 과 WR-10 (`language:` · `formatter:`) 이 함께 닫히고, "블록을 찾지 못하면 0개로 통과" 라는 모양이 키 단위에서 사라진다. 같은 gap plan 에서 README 382행 · `example/README.md` 116 · 436행의 검사 설명을 구현에 맞게 좁히거나 (e) ~ (g) 를 넓히는 일(WR-07 ~ WR-09 · IN-08), 마커 뒤 불릿 검사를 함께 다루기를 권한다 — 이것들은 경고이고 소유자가 범위를 정한다.

현재 상태의 README · CHANGELOG · YAML 주석은 실제 설정과 일치한다 — 실패한 것은 "그 일치가 검증으로 지켜진다" 의 한 입력이다.

---

_Verified: 2026-10-14_
_Verifier: Claude (gsd-verifier)_
