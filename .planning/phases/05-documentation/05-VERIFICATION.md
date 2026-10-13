---
phase: 05-documentation
verified: 2026-10-14T06:30:00Z
status: gaps_found
score: 23/25 must-haves verified
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
  - "tool/verify.dart"
covered_digest: "v3:sha256:ed0f07cd034f7af8f4772380da59c20f35f69343338571156c1da26b47a99d40"
behavior_unverified: 0
overrides_applied: 0
gaps:
  - truth: "README 의 규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 (성공 기준 3 · VERIFY-06 · 05-03 truth 7)"
    status: failed
    reason: "README 쪽 reader `readBulletBlock` 이 표시 구역 안에서 `- `이름`` 꼴이 아닌 줄을 실패로 돌리지 않고 건너뛴다. 옛 README(1.0.0 ~ 1.3.0)의 목록 꼴 `- require_trailing_commas: 자동 코드 정렬 최적화` 한 줄을 표시 구역에 더하면 — DOCS-06 이 고친 옛 불일치 1번과 같은 입력 — README 는 YAML 에 없는 규칙을 켜졌다고 말하는데 검증 명령은 종료 코드 0 · `점검 통과 (10개 중 10개)` 다 (검증자 복제본, 전체 실행). `* `x`` · `+ `x`` · `1. `x`` · 대문자 이름도 같다 (함수 단위). Phase 4 WR-10 이 YAML 쪽 reader 에서 닫은 '블록 안에서 읽지 못하는 줄은 건너뛰지 않고 멈춘다' 원칙이 README 쪽 reader 에 없다 — 같은 결함 모양, 다른 입력. 05-REVIEW.md 는 이 입력을 다루지 않는다."
    artifacts:
      - path: "tool/verify.dart"
        issue: "readBulletBlock (1412 ~ 1436행): `trim()` 한 줄이 `- ` 로 시작하지 않으면 continue, `- ` 로 시작해도 backtick 이름이 0개면 continue — 표시 구역 안의 읽지 못하는 줄이 조용히 빠진다"
    missing:
      - "표시 구역 안에서 빈 줄 · 분류 소제목(`**…**`) · 정확히 `- `이름`` 인 줄 밖의 줄을 만나면 `[3/10]` 실패(또는 70)로 돌린다 — WR-10 과 같은 원칙"
      - "지워 보기 기록(example/README.md): `- require_trailing_commas: 자동 코드 정렬 최적화` 추가, `* `extra`` 추가가 각각 `[3/10]` 실패임을 실제로 돌려 적는다"
  - truth: "`lib/codegen.yaml` 이나 `lib/riverpod.yaml` 에 규칙을 적으면 `[3/10]` 이 실패해 README 비교가 `lib/base.yaml` 하나만 봐도 빈자리가 없다 (05-01 truth 3 · ROADMAP Phase 5 Notes 'README 비교도 같은 빈자리를 갖지 않게' · README 378행)"
    status: failed
    reason: "flow 표기 `linter: {rules: [prefer_mixin]}` 를 `lib/codegen.yaml` 끝에 더하면 (b′) 가 규칙 0개로 읽고 검증 명령은 종료 코드 0 · `점검 통과 (10개 중 10개)` 다 (검증자 복제본, 전체 실행 — 05-REVIEW WR-04 재현). 같은 꼴로 `always_specify_types` 를 더하면 `fixtures/base_codegen` 의 `dart analyze` 에 그 진단 25건이 나온다 — 사용 프로젝트에 닿는 규칙이 README 목록에 없는데 `[3/10]` 은 통과한다. `declaredRuleNames` 문서 주석의 'flow 표기는 규칙 0개라 [2/N] 이 잡는다' 는 `lib/base.yaml` 에만 맞고 다른 조각에는 0개 확인이 없다. 개연성은 낮다 — CLAUDE.md 의 '목록 형식을 유지한다' 와 README 의 '규칙은 lib/base.yaml 에만' 두 관례를 함께 어겨야 한다. 그러나 (b′) 는 그 관례 위반을 잡으려고 있는 검사이고, README 378행은 '`[3/10]` 단계가 다른 조각에 적힌 규칙을 잡는다' 고 단정한다."
    artifacts:
      - path: "tool/verify.dart"
        issue: "declaredRuleNames (925행): `^linter:` 줄에 같은 줄로 붙은 값(flow 표기)을 건너뛰고 블록 줄만 읽는다; (b′) (1488 ~ 1502행) 가 그 0개를 통과로 본다"
      - path: "README.md"
        issue: "378행 '검증 명령의 `[3/10]` 단계가 다른 조각에 적힌 규칙을 잡는다' 가 flow 표기에서 거짓"
    missing:
      - "`linter:` 줄에 `#` 주석 밖의 값이 붙어 있으면 FormatException (종료 코드 70) 으로 멈춘다 — 05-REVIEW WR-04 의 Fix"
      - "지워 보기 기록: `lib/codegen.yaml` 끝의 `linter: {rules: [prefer_mixin]}` 가 70 (또는 `[3/10]` 실패) 임을 실제로 돌려 적는다"
deferred:
  - truth: "README 의 설치 블록(`ref: v2.0.0`)을 새 프로젝트에 그대로 복사해 실제로 받을 수 있다 (tag v2.0.0 이 아직 없다)"
    addressed_in: "Phase 6"
    evidence: "Phase 6 성공 기준 3: '빈 프로젝트가 새 tag 를 git 의존성(`ref: vX.Y.Z`)으로 받아 `dart analyze` 를 돌리면 기본 규칙 진단과 `riverpod_lint` plugin 진단이 둘 다 보고된다'"
human_verification:
  - test: "README 만 열고 처음부터 끝까지 따라 해 본다 — 설치(dev_dependencies 블록 + flutter pub get), 「프리셋 고르기」 2 × 2 표에서 하나 고르기, 「규칙 · plugin 진단 끄기」 의 세 층, 「버전 올리기」 의 세 갈래(tag · ref: main · main → tag)"
    expected: "다른 문서를 열지 않고 순서대로 따라 할 수 있고, 막히는 단계나 앞뒤가 맞지 않는 안내가 없다"
    why_human: "'몇 달 뒤 README 만 보고 따라 할 수 있다' 는 grep 으로 가를 수 없다 (성공 기준 1 · 2, 05-VALIDATION Manual-Only 2번)"
  - test: "README 의 「규칙 · plugin 진단 끄기」 · 「생성 파일 제외」 · 「버전 올리기」 · 「문제 해결」 의 문장을 하나씩 읽고, 단정형 문장마다 spike · fixture 출처가 있는지, SDK 에 따라 다른 동작에 SDK 버전과 날짜가 붙었는지, 읽은 것 · 추론 · 추정이 그렇다고 적혔는지 본다"
    expected: "출처 없는 단정이 없다; 05-CONTEXT 가 금지한 '쏟아진다' · '유일한 방법' 류 문구가 없다 (grep 으로는 0건 확인)"
    why_human: "문장마다의 단정 / 출처 구분은 사람이 판단한다 (05-VALIDATION Manual-Only 4번)"
  - test: "README 의 외부 링크 넷을 브라우저로 연다 — flutter#191151 (googlesource 커밋), dart-lang/sdk#64549, dart.dev/tools/pub/workspaces (87행 인용문이 그 페이지에 그대로 있는지), README 342행이 말하는 pub.dev 의 riverpod_lint 설치 안내"
    expected: "링크가 열리고, 인용문과 요약이 페이지 내용과 같다"
    why_human: "외부 페이지는 검증 명령이 보지 않고, 이 검증은 네트워크로 페이지 본문을 대조하지 않았다"
---

# Phase 5: Documentation 검증 보고서

**Phase 목표:** 소유자가 몇 달 뒤 README 만 보고 설치, 프리셋 선택, 규칙 재정의, 버전 올리기를 그대로 따라 할 수 있고, README / CHANGELOG / YAML 주석이 실제 설정과 일치하며 그 일치가 검증으로 지켜진다
**검증 시각:** 2026-10-14
**상태:** gaps_found
**재검증:** 아니오 — 첫 검증

방법: 저장소를 `git clone --local` 로 복제(검증자 복제본 둘, 작업 트리는 건드리지 않음)하고 루트 `fvm dart pub get` 뒤 `fvm dart run tool/verify.dart` 를 기준 실행(종료 코드 0, `점검 통과 (10개 중 10개)`, 67초)으로 돌렸다. 입력을 바꾼 실험은 두 가지로 했다 — 전체 실행, 그리고 `tool/verify.dart` 를 import 해 `checkShippedComposition` · `readShippedPluginConstraint` 를 직접 부르는 작은 하네스(복제본 밖). 실험마다 `git checkout -- .` 로 되돌리고 `git status --porcelain` 0줄을 확인했다.

## 목표 달성

### 관찰 가능한 참 (Observable Truths)

ROADMAP 성공 기준 5개를 먼저 두고, plan must_haves 가운데 성공 기준과 겹치지 않는 것을 더했다 (05-03 의 8개와 05-04 의 앞 셋은 성공 기준 1 ~ 5 에 합쳤다).

| # | 참 | 상태 | 근거 |
|---|----|------|------|
| SC1 | README 의 설치 안내와 프로젝트 유형별 include 블록을 그대로 복사해 `ref: vX.Y.Z` 로 추가할 수 있다 | ✓ VERIFIED | README 13 ~ 19행 `dev_dependencies:` · `url: https://github.com/woodkill/woody_lints.git` · `ref: v2.0.0`, 23 ~ 25행 `flutter pub get`, 「설치」 절에 `ref: main` 없음. include 블록 넷(49 ~ 79행)이 `fixtures/{recommended,base_only,base_riverpod,base_codegen}/analysis_options.yaml` 과 글자가 같다(직접 대조). 블록 아래 "받는 것" 은 정답지와 맞다 — `base_only` · `base_riverpod` 에 `invalid_annotation_target` 1건 · 생성 파일 줄 4건, `base_codegen` 은 0 · 0, `base_only` · `base_codegen` 에 plugin 진단 없음. 실제 tag 로 받는 것은 Phase 6 (Deferred) |
| SC2 | 끄는 방법(한 줄 / 파일 / 프로젝트, plugin 진단), 버전 올리기, `ref: main` → tag, 문제 해결 절이 있고 재정의 방법이 Phase 3 fixture 와 같다 | ✓ VERIFIED | README 224 ~ 237행 블록이 `fixtures/overrides/analysis_options.yaml` 전체와 글자가 같다. 246 · 247 · 255 · 256 · 262 ~ 264행이 `fixtures/overrides/lib/suppress/*.dart` 의 줄과 같다. 272행의 `plugin_line.dart:11` · `plugin_file_unprefixed.dart:8` 이 정답지 100 · 102행에 있고 꺼진 줄(9 · 12행 warning)은 없다. 「버전 올리기」 세 갈래 + `--enforce-lockfile` 65 + 권하는 일 넷(304 ~ 343행), 「문제 해결」 네 소절(345 ~ 374행) |
| SC3 | README 의 규칙 · 설정 설명이 실제 YAML 과 일치하고(불일치 2건 해소), 규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 | ✗ FAILED | **앞 절반은 참:** 표시 구역 81개가 `lib/base.yaml` 과 같고 분류 넷과 순서까지 같다(직접 diff). `codegen.yaml` 블록(203 ~ 210행)이 `lib/codegen.yaml` 4 ~ 9행과 같고 `^3.1.9` 가 맞다. `require_trailing_commas` · `trailing_commas` 0줄. 삭제 · 오타 · 추가(`- `x``) · `lib/base.yaml` 쪽 주석 처리는 모두 `[3/10]` 실패(함수 단위). **뒤 절반은 거짓:** 표시 구역에 옛 README 꼴 `- require_trailing_commas: 자동 코드 정렬 최적화` 를 더한 전체 실행이 종료 코드 0 · `점검 통과 (10개 중 10개)`. `* `x`` · `+ `x`` · `1. `x`` · `- x` · `- `Extra_Rule`` 추가도 `passed=true` (함수 단위). gaps 1번 |
| SC4 | CHANGELOG 최상단에 새 릴리스 항목이 Phase 1 형식으로 있고, 1.0.0 과 1.3.0 사이가 git 이력 범위로 채워져 있다 | ✓ VERIFIED | 1행 `## 2.0.0 - 미출시`, 3행 `지원 SDK:`, 칸 순서 올리기 전에 → 추가한 규칙 → 그 밖의 변경 → 새로 생기는 경고. 추가한 규칙 불릿 75 = 경고 표 규칙 행 75, 181행 `실측: flutter_starter_kit (Dart 파일 474개), …`. 제목 순서 2.0.0 · 1.3.0 · 1.2.5 … 1.1.0 · 1.0.0. 복원 일곱의 날짜 · 커밋 · 변경을 `git show` diff 와 대조 — `dbcd20b` · `9451f6b` · `31c8cb1` · `21c5689` · `ec66e3f` · `2249a0b`/`126aa43` 와 부수 커밋 `7b7455e` · `9950fd1` · `1693a97` · `9bf0d86` · `a97fd20`, `212365d` 의 `.fvmrc` 변경까지 모두 일치 (1.2.4 본문은 orchestrator 가 대조). 커밋 메시지(`Update pubspec.yaml` 등)를 옮긴 문장 없음 |
| SC5 | 배포 YAML 의 머리 주석이 실제 구성을 설명하고, README 와 YAML 에 템플릿 보일러플레이트가 없다 | ✓ VERIFIED | 다섯 파일의 머리 주석 3 ~ 4줄이 무엇을 주는지 · include 주소 · 왜 이 모양인지 · README / RULES.md 를 말한다(별칭은 옛 주소 별칭임을 말함). `Uncomment` · `For more information` · `This file configures` · 템플릿 HTML 주석 grep 0줄 (README 의 `<!--` 는 표시 구역 마커 둘뿐) |
| 01-1 | `lib/riverpod.yaml` plugin 줄 끝 주석 · 마지막 줄바꿈 없음에서도 검증 통과 | ✓ VERIFIED | HEAD 의 `lib/riverpod.yaml` 5행이 줄 끝 주석을 단 채 기준 실행 10/10. 마지막 줄바꿈을 지운 입력도 `passed=true` · `^3.1.9` (함수 단위) |
| 01-2 | `riverpod_lint:` 선언을 지우면 종료 코드 70 · `riverpod_lint 선언을 찾지 못했다` | ✓ VERIFIED | 함수 단위로 `FormatException: lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다` (main 이 70 으로 바꾸는 것은 05-VALIDATION 감사의 M34 rc 70) |
| 01-3 | `lib/codegen.yaml` · `lib/riverpod.yaml` 에 규칙을 적으면 `[3/10]` 실패 — README 비교가 `lib/base.yaml` 하나만 봐도 빈자리가 없다 | ✗ FAILED | 블록 꼴(M35)은 `` `lib/codegen.yaml` 에 규칙이 있다 (1) `` 로 실패(함수 단위). flow 꼴 `linter: {rules: [prefer_mixin]}` 는 전체 실행 종료 코드 0 · 10/10, `linter: {rules: {prefer_mixin: true}}` (riverpod.yaml) 도 `passed=true`. 같은 꼴의 `always_specify_types` 는 `base_codegen` 분석에 25건 — 사용 프로젝트에 닿는다. gaps 2번 |
| 01-4 | 다른 조각의 읽지 못하는 줄 → 70 문구에 파일 이름 (IN-14) | ✓ VERIFIED | `declaredRuleNames(…, shownAs: target)` 이 문구 머리에 `$shownAs` 를 넣는다(909 ~ 940행); 05-VALIDATION 감사 M36 rc 70 |
| 01-5 | `stripPlugins` 가 섹션을 빈 줄로 바꿔 `[2/10]` 줄 번호가 원본과 같다 | ✓ VERIFIED | 815행 `if (inPlugins) lines[i] = '';`; 05-VALIDATION 감사 M37 rc 1 · 원본 줄 번호 |
| 01-6 | M32 ~ M37 기록 · 03 WR-02 / 04 WR-11 · IN-14 처리 기록 fixed | ✓ VERIFIED | `example/README.md` 312행 소절, M32 ~ M42 행 11개. `03-REVIEW-DISPOSITION.md` 75행 WR-02 fixed (`1831c04`), `04-REVIEW-DISPOSITION.md` 136 · 149행 WR-11 · IN-14 fixed (`dc42790`) |
| 02-1 | 배포 YAML 다섯의 첫 줄이 `#` 한국어 머리 주석, 2 ~ 4줄 | ✓ VERIFIED | base 4줄, riverpod · codegen · recommended · analysis_options 각 3줄 |
| 02-2 | 템플릿 영어 주석 없음, 분류 주석 넷 · 규칙 81줄 불변, 정답지 불변 | ✓ VERIFIED | `2c026dd` 와 `^    (- |# )` 줄이 같다(diff 0), 비주석 줄 diff 다섯 파일 모두 0, `^    - ` 81줄, `git diff 6d64bee HEAD -- '*expected_diagnostics.txt'` 0 |
| 02-3 | `lib/riverpod.yaml` 머리 주석은 왜 최상위 `plugins:` 인지만, 캐시 · 재시작 · 실측 문장은 README 로 | ✓ VERIFIED | 2행이 최상위 `plugins:` 이유, 3행이 README 「문제 해결」 안내. `.dartServer` · `2026-09-20` 은 README 357 · 363행에 있고 YAML 에 없다 |
| 02-4 | `lib/codegen.yaml` 머리 주석 신설, 내용 불변; 묶음 · 별칭 include 줄 불변 | ✓ VERIFIED | 위 비주석 diff 0, 기준 실행 `[3/10]` (a) 통과 |
| 02-5 | `.claude/CLAUDE.md` 는 71 · 181행만 바뀌었다 | ✓ VERIFIED | `git diff cd76cc8 HEAD -- .claude/CLAUDE.md` 의 hunk 가 `@@ -71 +71 @@` · `@@ -181 +181 @@` 둘뿐 |
| 04-4 | `### 올리기 전에` 에 꼭 할 것 둘 + 받는 때 + README 「버전 올리기」 링크, 권하는 일 없음 | ✓ VERIFIED | CHANGELOG 7 ~ 10행 불릿 넷, `dart fix --apply` 없음 |
| 04-5 | `### 그 밖의 변경` 의 저장소 안쪽 한 줄 · 받는 쪽 줄 유지 · README · YAML 정리 한 줄 | ✓ VERIFIED | 92 ~ 99행 불릿 8개, 99행 `저장소 안쪽: … — 사용하는 프로젝트에는 영향 없음`, 98행 README · 머리 주석 · 복원 |
| 04-6 | `01-REVIEW-DISPOSITION.md` WR-05 fixed | ✓ VERIFIED | 81행 `| WR-05 | warning | fixed | 05-04-PLAN.md Task 2 (06f62a5)` |
| 05-1 | 소유자 확인 뒤 브랜치 하나로 push, `main` `90a2736`, tag `v1.3.0` 하나, PR 없음 | ✓ VERIFIED | `git ls-remote origin`: `refs/heads/main` `90a2736…`, 작업 브랜치 `92d478a…`, tag `v1.3.0` 만; `gh pr list --state all` → `[]` |
| 05-2 | push 전 범위 전체 비공개 점검 0줄 | ✓ VERIFIED | 05-VALIDATION 의 독립 확인(범위 `0db0fdd..92d478a`). 재확인: 공개 문서 · `lib/` · `example/README.md` · 이 phase 문서의 절대 경로 꼴은 PLAN 속 정규식 원문 줄만 걸린다 |
| 05-3 | GitHub `verify` 성공 · `[3/10] … 통과` · `점검 통과 (10개 중 10개)` | ✓ VERIFIED | `gh run view 38460138720`: `completed` · `success` · push · headSha `92d478a…`. `92d478a..HEAD` 는 README · lib · tool · CHANGELOG · example · fixtures · RULES · pubspec · `.claude` 를 바꾸지 않았다(diff 0) — CI 가 본 내용이 지금 HEAD 와 같다 |
| 06-1 | M38 ~ M42 가 각각 `[3/10]` 실패 · 기대 문구 | ✓ VERIFIED | 같은 성질을 직접 재현: 규칙 이름 삭제 · `code_gen.yaml` (올바른 꼴의 없는 주소) · `version: ^3.1.3` 모두 `passed=false` 와 해당 문구(함수 단위); start 마커 삭제는 05-VALIDATION 감사 rc 1. 단, 이 다섯 입력은 "올바른 꼴의 틀린 값" 만 가른다 — 꼴이 틀린 값은 아래 경고 W1 ~ W3 |
| 06-2 | 기록 소절과 단계 설명 · 70 설명 갱신 | ✓ VERIFIED | `example/README.md` 338행 소절; `2c026dd..HEAD` 에서 지운 줄은 70 설명 · 단계 설명 · 범례 문단 셋뿐(M1 ~ M37 행 불변) |
| 06-3 | 지워 보기 README 가 커밋되지 않았다 | ✓ VERIFIED | HEAD 의 README 로 기준 실행 10/10, 표시 구역 81개 그대로 |

**점수:** 23/25 참 확인 (present · behavior-unverified 0)

### Deferred Items

| # | 항목 | 다룰 phase | 근거 |
|---|------|-----------|------|
| 1 | README 의 `ref: v2.0.0` 블록을 새 프로젝트에 복사해 실제로 받는 것 (tag 가 아직 없다 — README 의 예시가 Phase 6 tag 를 가리키는 것은 ROADMAP Phase 5 Notes 의 결정) | Phase 6 | 성공 기준 3 "빈 프로젝트가 새 tag 를 git 의존성(`ref: vX.Y.Z`)으로 받아 `dart analyze` …" |

### Required Artifacts

| Artifact | 기대 | 상태 | 세부 |
|----------|------|------|------|
| `tool/verify.dart` | `[3/N]` (b′) · (d) ~ (g), 고친 `stripPlugins` · `readShippedPluginConstraint` | ⚠️ 있음 · 연결됨 · 일부 fail-open | (d) · (b′) 의 reader 가 읽지 못하는 입력을 건너뛴다(gaps). (e) ~ (g) 도 같은 모양(경고) |
| `README.md` | 절 아홉, 표시 구역 81개, 코드 블록 값 | ✓ VERIFIED | 378행 단정 하나가 flow 꼴에서 거짓(gaps 2번) |
| `CHANGELOG.md` | 복원 7항목, 2.0.0 정리 | ✓ VERIFIED | |
| `lib/*.yaml` 다섯 | 머리 주석, 내용 불변 | ✓ VERIFIED | |
| `example/README.md` | M32 ~ M42 | ✓ VERIFIED | |
| `.claude/CLAUDE.md` | 71 · 181행 | ✓ VERIFIED | 이웃 줄의 낡은 서술은 D-09 가 마일스톤 끝으로 미룸(정보) |
| 처리 기록 01 · 03 · 04 | fixed 행 | ✓ VERIFIED | |

### Key Link Verification

| From | To | Via | 상태 | 세부 |
|------|----|-----|------|------|
| `tool/verify.dart` | `README.md` | `readBulletBlock` → `woody:readme-rules` | ⚠️ PARTIAL | `- `이름`` 줄만 읽고 나머지를 건너뜀 |
| `tool/verify.dart` | `lib/codegen.yaml` · `lib/riverpod.yaml` | (b′) `declaredRuleNames(shownAs: target)` | ⚠️ PARTIAL | 블록 꼴만; flow 꼴 0개 |
| `tool/verify.dart` | `lib/riverpod.yaml` | `readShippedPluginConstraint` → `[4/N]` · (f) | ✓ WIRED | 따옴표 · 범위 · 키 순서는 fail-closed (경고 W5) |
| `tool/verify.dart` | `pubspec.yaml` | `pubspecReleaseVersion` → (g) | ✓ WIRED | 따옴표 값은 70 (fail-closed, IN-01) |
| `README.md` | `fixtures/overrides/analysis_options.yaml` | 끄기 블록 | ✓ WIRED | 글자 동일 |
| `CHANGELOG.md` | `README.md` | `### 올리기 전에` 의 「버전 올리기」 링크 | ✓ WIRED | 10행 |
| 로컬 작업 브랜치 | origin | `git push origin gsd/v2.0-package-rework` | ✓ WIRED | origin `92d478a`, 로컬은 메타데이터 커밋 6개 앞(올리기는 뒤의 소유자 결정) |

### Behavioral Spot-Checks

| 동작 | 명령 | 결과 | 상태 |
|------|------|------|------|
| 기준 실행 | `fvm dart run tool/verify.dart` | rc 0, `점검 통과 (10개 중 10개)` | ✓ PASS |
| README 규칙 하나 삭제 | 하네스 | `passed=false`, `+ prefer_final_locals  (base.yaml 에만)` | ✓ PASS |
| README 에 없는 규칙 `- `not_a_real_rule`` 추가 | 하네스 | `passed=false`, `- not_a_real_rule  (README.md 에만)` | ✓ PASS |
| `lib/base.yaml` 에서 규칙 주석 처리 | 하네스 | `passed=false` (RULES.md · README 둘 다) | ✓ PASS |
| 옛 README 꼴 `- require_trailing_commas: 자동 코드 정렬 최적화` 추가 | 전체 실행 | rc 0, `점검 통과 (10개 중 10개)` | ✗ FAIL (gaps 1) |
| `* `extra_rule_star`` · `+ `…`` · `1. `…`` · `- extra_rule_plain` · `- `Extra_Rule`` 추가 | 하네스 | 모두 `passed=true` | ✗ FAIL (gaps 1) |
| `lib/codegen.yaml` 끝에 `linter: {rules: [prefer_mixin]}` | 전체 실행 | rc 0, `점검 통과 (10개 중 10개)` | ✗ FAIL (gaps 2) |
| 같은 자리에 `linter: {rules: [always_specify_types]}` 뒤 `fixtures/base_codegen` 분석 | `fvm dart analyze` | `always_specify_types` 25건 | 사용 프로젝트에 닿음 확인 |
| 블록 꼴 규칙을 `lib/codegen.yaml` 에 (M35) | 하네스 | `passed=false`, `` `lib/codegen.yaml` 에 규칙이 있다 (1) `` | ✓ PASS |

### Probe Execution

해당 없음 — 이 phase 는 `scripts/*/tests/probe-*.sh` 를 선언하지 않는다. 검증 명령 자체를 위 표로 돌렸다.

### Requirements Coverage

| 요구사항 | Plan | 설명 | 상태 | 근거 |
|----------|------|------|------|------|
| DOCS-01 | 05-03 | README 만 보고 `ref: vX.Y.Z` 로 추가 | ✓ SATISFIED (실제 tag 설치는 Phase 6) | SC1 |
| DOCS-02 | 05-03 | 유형별 include 블록 | ✓ SATISFIED | SC1 — 블록 넷이 fixture 와 글자 동일 |
| DOCS-03 | 05-03 | 한 줄 / 파일 / 프로젝트 · plugin 진단 끄기 | ✓ SATISFIED | SC2 |
| DOCS-04 | 05-03 | `ref:` 수정 + `pub get`, main → tag | ✓ SATISFIED | README 304 ~ 334행 |
| DOCS-05 | 05-03 | 문제 해결 넷 | ✓ SATISFIED | README 345 ~ 374행 |
| DOCS-06 | 05-03 | README 규칙 · 설정 설명 == YAML | ✓ SATISFIED (현재 상태) | SC3 앞 절반 |
| DOCS-07 | 05-04 | 새 릴리스 항목 | ✓ SATISFIED | SC4 |
| DOCS-08 | 05-04 | 1.0.0 ~ 1.3.0 보완 | ✓ SATISFIED | SC4 — diff 대조 |
| DOCS-09 | 05-04 | 규칙별 건수 · `dart fix` | ✓ SATISFIED | 표 75행 · 4열 |
| DOCS-10 | 05-01 · 05-02 | 머리 주석 · 보일러플레이트 제거 | ✓ SATISFIED | SC5 |
| VERIFY-06 | 05-01 · 05-03 · 05-05 · 05-06 | README 규칙 목록이 YAML 과 다르면 검증 실패 | ✗ BLOCKED | gaps 1 · 2 — 옛 README 꼴 · flow 꼴 입력에서 다른데 통과 |

ORPHANED 없음 — REQUIREMENTS.md 가 Phase 5 에 매긴 11개가 모두 plan 의 `requirements` 에 있다.

### 경고 (gap 아님 — 지금 상태의 참을 깨지 않거나 fail-closed)

| # | 내용 | 재현 입력 | 판정 |
|---|------|-----------|------|
| W1 | (e) 가 꼴이 틀린 주소를 모으지 않는다 (05-REVIEW WR-01) | README 78행 `package:woody_lints/codegen.yml`, 68행 `package:woody_lint/riverpod.yaml` → 둘 다 `passed=true` | 경고. 지금 README 의 주소 넷은 모두 맞다. 약속(D-02 (2))은 `<이름>.yaml` 꼴의 주소를 견주는 것이고 그대로 동작한다. 다만 `.yml` · 패키지 이름 오타는 그럴듯한 실수이고 gaps 1 과 같은 "건너뛰기" 모양이라 같은 gap plan 에서 닫기를 권한다 |
| W2 | (f) · (g) 가 따옴표 · 줄 끝 주석 · 두 자리 값을 건너뛴다 (WR-02) | 234행 `version: "^3.1.3"`, 333행 `ref: v1.9.0 # 예시` → 둘 다 `passed=true` | 경고. 맞는 값 옆의 낡은 값이 통과한다. 이 README 의 코드 블록은 따옴표 · 주석을 쓰지 않는다. W1 과 같은 권고 |
| W3 | `fencedLines` 가 `~~~` 펜스를 모른다 (WR-03) | 328 ~ 334행 펜스를 `~~~` 로, 333행을 `ref: v1.9.0` → `passed=true` | 경고. 개연성 낮음(README 는 전부 백틱 펜스) |
| W4 | 산문 속 plugin 버전은 견주지 않는다 | `lib/riverpod.yaml` · README 코드 블록 둘을 `^3.2.0` 으로 올리면 `[3/10]` 통과, 239행 "프리셋과 같은 값(`^3.1.9`)을 적는다" · 372행 "프리셋의 범위(`^3.1.9`)" 는 낡은 채 남는다 | 경고. (f) 를 코드 블록으로 좁힌 것은 05-RESEARCH Pattern 2 의 의도된 설계(산문의 옛 값 인용 때문)이고 README 382행도 "예시" 만 견준다고 적는다. 다만 다음 plugin 하한 상향(D-02 가 이유로 든 바로 그 변경) 때 두 문장이 조용히 어긋난다 — 두 문장에서 숫자를 빼거나 검사 범위를 넓히기를 권한다 |
| W5 | `readShippedPluginConstraint` 가 따옴표째 돌려주고 범위 · 키 순서를 거부한다 (WR-05) | `riverpod_lint: "^3.1.9"` → `[3/N]` 실패(선언 `"^3.1.9"`); `">=3.1.9 <4.0.0"` → FormatException | 경고. 모두 fail-closed — 헛통과가 아니라 거짓 실패라 참을 깨지 않는다 |
| W6 | `.claude/CLAUDE.md` 의 이웃 낡은 줄 (WR-06) | 70 · 173 · 313행이 걷어낸 루트 exclude 를 "유지해야 한다" 고 지시 | 정보. D-09 가 범위를 두 줄로 정하고 나머지를 마일스톤 끝 `/gsd-map-codebase` 로 미뤘다(소유자 결정). 다만 에이전트가 따를 수 있는 지시라 미룬 일에 꼭 넣을 것 |
| W7 | `pubspec.yaml` 13 ~ 15행 주석이 "`lib/analysis_options.yaml` 이 `include: package:flutter_lints/flutter.yaml` 을 쓰므로" 라고 적는다 | — | 정보. 지금 그 include 는 `lib/base.yaml` 에 있다(별칭은 묶음 → base 를 거쳐 닿는다). 성공 기준 5 의 "배포 YAML 다섯" 밖이라 gap 아님 |
| — | IN-01 (`pubspec.yaml` 따옴표 version → 70) | `version: "2.0.0-dev"` → FormatException | 정보, fail-closed |

### Anti-Patterns

| 파일 | 줄 | 패턴 | 심각도 | 영향 |
|------|----|------|--------|------|
| `tool/verify.dart` | 1421 ~ 1433 | 표시 구역 안의 읽지 못하는 줄을 `continue` | 🛑 Blocker | VERIFY-06 헛통과 (gaps 1) |
| `tool/verify.dart` | 925 | `^linter:` 의 같은 줄 값(flow)을 버림, 문서 주석 905 ~ 906행의 "[2/N] 이 잡는다" 는 다른 조각에 거짓 | 🛑 Blocker | (b′) 헛통과 (gaps 2) |
| `tool/verify.dart` | 1607 · 1630 · 1654 · 1274 | 정규식에 맞지 않는 값 건너뛰기 | ⚠️ Warning | W1 ~ W3 |

`TBD` · `FIXME` · `XXX` 표식: 바뀐 파일(README · CHANGELOG · `lib/*.yaml` · `tool/verify.dart` · `example/README.md`)에 0개.

### 금지 사항(prohibitions) 확인

판단 등급(judgment) 항목 가운데 기계로 가를 수 있는 것은 직접 확인했다 — 배포 설정 내용 불변(비주석 diff 0, 정답지 diff 0), `.claude/CLAUDE.md` 두 줄만, 1.3.0 · 1.0.0 항목 불변(05-04 `<automated>` 의 `fb6386a` 대조 · 감사 rc 0), M1 ~ M37 행 불변, 지워 보기 파일 미커밋, 공개 파일의 절대 경로 꼴 0줄, `~/.dartServer` 전체 삭제 안내 없음(README 359행이 `<hash>` 폴더로 좁힌다), `main` · tag · force push 없음(원격 상태). 문장 단위의 "fixture · spike 가 받치지 않는 단정 금지" 는 아래 사람 확인 2번으로 남긴다.

### Human Verification Required

gap 을 닫은 뒤에도 남는 사람 확인 셋이다 (05-VALIDATION Manual-Only 의 "CHANGELOG 복원 항목이 diff 와 맞다" 는 이 검증이 일곱 항목과 부수 커밋까지 `git show` 로 대조해 닫았다).

1. **README 를 처음부터 따라 하기** — 설치 → 프리셋 고르기 → 끄기 세 층 → 버전 올리기 세 갈래. 기대: 다른 문서 없이 순서대로 따라 할 수 있다. 이유: "따라 할 수 있다" 는 grep 으로 가를 수 없다.
2. **단정 / 출처 문장 단위 확인** — 끄기 · 생성 파일 제외 · 버전 올리기 · 문제 해결의 단정형 문장마다 spike · fixture 출처, SDK 따라 다른 동작의 버전 · 날짜, 읽은 것 · 추론 표시. 이유: 사람이 판단한다.
3. **외부 링크 넷 열기** — flutter#191151, sdk#64549, dart.dev workspaces 인용문(87행), pub.dev riverpod_lint 설치 안내. 이유: 검증 명령이 보지 않는다.

### Gaps 요약

두 gap 은 뿌리가 하나다 — **VERIFY-06 의 일치 검사가 읽지 못하는 입력을 실패로 돌리지 않고 건너뛴다 (fail-open).** Phase 4 의 WR-10 이 `lib/base.yaml` 의 `linter:` 블록 reader 에서 "블록 안에서 읽지 못하는 줄은 건너뛰지 않고 멈춘다" 로 닫은 결함 모양이, 이 phase 가 새로 쓴 README reader(`readBulletBlock`)와 다른 조각을 보는 (b′) 의 flow 꼴에 다시 나왔다.

- **gaps 1 (README 쪽, 개연성 중간):** 재현 입력은 이 저장소의 1.0.0 ~ 1.3.0 README 가 실제로 쓰던 목록 꼴 `- 규칙이름: 설명` 이다. 그 꼴로 DOCS-06 이 고친 옛 불일치(`require_trailing_commas`)를 그대로 다시 적으면 전체 검증이 10개 중 10개로 통과한다. 05-REVIEW 는 이 입력을 다루지 않았다.
- **gaps 2 (YAML 쪽, 개연성 낮음):** 05-REVIEW WR-04 재현. 관례 둘을 함께 어겨야 생기지만 README 378행과 05-01 truth 가 "빈자리가 없다" 고 단정하고, 규칙이 실제로 사용 프로젝트에 닿는 것을 확인했다.

둘 다 고치는 범위가 작다 — reader 두 곳에 "모르는 줄이면 멈춘다" 를 넣고 지워 보기 기록을 더하면 된다. 같은 plan 에서 경고 W1 ~ W3 의 (e) · (f) · (g) 도 같은 원칙(후보를 넓게 모으고 꼴이 틀리면 실패)으로 닫기를 권한다. W4 는 문장 두 개를 고치는 일이다.

현재 상태의 README · CHANGELOG · YAML 주석은 실제 설정과 일치한다 — 실패한 것은 "그 일치가 검증으로 지켜진다" 의 일부다.

---

_Verified: 2026-10-14_
_Verifier: Claude (gsd-verifier)_
