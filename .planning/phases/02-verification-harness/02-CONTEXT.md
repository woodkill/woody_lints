# Phase 2: Verification Harness - Context

**Gathered:** 2026-10-11
**Status:** Ready for planning

<domain>
## Phase Boundary

`lib/` 를 바꾸기 전에 1.3.0 의 동작을 기대 진단(golden, 이하 "정답지")으로 고정하고, 소유자와 CI 가 같은 명령 하나로 "배포 설정이 기대한 대로 적용되는가"를 판정하게 한다. 이 phase 가 끝나면 다음이 참이다.

1. 저장소 루트에서 명령 하나를 실행하면 `example/` 의 분석 결과가 커밋된 정답지와 비교되어, 같으면 성공하고 다르면 실패한다 (VERIFY-01, VERIFY-03)
2. 규칙이 적힌 배포 파일에 deprecated / removed / 존재하지 않는 규칙이 있으면 같은 명령이 실패한다 (VERIFY-02)
3. `lib/` 에 `.dart` 파일이 있으면 같은 명령이 실패한다 (VERIFY-07)
4. 규칙 하나를 지운 변경과 `example/` 의 include 줄을 지운 변경이 각각 검증에서 실패함을 확인한 기록이 있다 (VERIFY-08)
5. push 와 PR 마다 GitHub Actions 가 같은 명령을 실행하고, 시간 제한이 걸려 있으며, GitHub 에서 실제로 성공한 실행이 한 번 이상 있다 (VERIFY-04)

이 phase 는 `lib/` 를 바꾸지 않는다. 루트 `analysis_options.yaml` 의 `lib/analysis_options.yaml` exclude 도 그대로 둔다 (제거는 Phase 3 의 PRESET-06). 대조군 fixture(VERIFY-05)는 Phase 3, README ↔ YAML 비교 검사(VERIFY-06)는 Phase 5, tag 트리거와 버전 일치 검사(REL-03)는 Phase 6 의 일이다.

</domain>

<decisions>
## Implementation Decisions

### 이전에 확정되어 그대로 따르는 것

다시 논의하지 않았다. 출처는 ROADMAP.md / REQUIREMENTS.md / PROJECT.md / 01-CONTEXT.md 다.

- 판정은 종료 코드가 아니라 정답지 비교(golden comparison)가 주 수단이다 (PROJECT.md Key Decisions)
- plugin 진단 확인은 `dart analyze` 로 한다. `flutter analyze` 는 Flutter 3.47.5 에서 plugin 진단을 내지 않는다
- 검증과 실측은 저장소 고정 SDK(Flutter 3.47.5 / Dart 3.13.4) 위에서 돈다. 로컬은 `fvm dart …`, 버전의 단일 원천은 `.fvmrc` 다
- CI workflow 는 읽기 권한만 갖고(`permissions: contents: read`) job 에 시간 제한을 둔다
- ROADMAP 의 "Spike first" 6가지는 이 phase 의 나머지를 계획하기 전에 실행으로 확인한다
- lint 는 info 라 `dart analyze` 의 기본 종료 코드가 0 이다. deprecated / removed 규칙은 include 경유로는 보고되지 않으므로, 규칙이 적힌 파일을 `analysis_options.yaml` 이름으로 분석 대상 안에 두는 단계가 따로 필요하다 (ROADMAP Notes, 실측)
- `example/` 은 pub workspace 멤버로 만들지 않는다 (`research/ARCHITECTURE.md` Anti-Pattern 3)
- 문서와 주석은 한국어로 쓰고 규칙명·키·명령은 영어 원문을 쓴다

### 정답지에 담을 범위와 형식

- **D-01:** `example/` 은 `lib/analysis_options.yaml` 에 선언된 **규칙 12개 전부**를 규칙마다 위반 한 건씩으로 고정하고, 여기에 **기반 세트만 켜는 규칙**(이 패키지가 선언하지 않은 `flutter_lints` / `lints` 규칙) 1건 이상을 더한다.
  - 12개: `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `sized_box_for_whitespace`, `always_declare_return_types`, `sort_child_properties_last`, `prefer_final_locals`, `prefer_single_quotes`, `slash_for_doc_comments`, `use_build_context_synchronously`, `unawaited_futures`, `avoid_print`, `control_flow_in_finally`
  - 고르지 않은 안: 실제로 추가하는 6개만 / 최소 3건
  - 이유: Phase 3 에서 파일을 나눈 뒤 "달라진 것이 없다", Phase 4 에서 중복 선언 6개를 지운 뒤 "여전히 켜져 있다"가 규칙마다 확인된다
  - 따라 나오는 점 (소유자 결정이 아니라 사실): VERIFY-08 의 "규칙 하나를 지운 변경"은 이 패키지가 실제로 추가하는 6개(`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `always_declare_return_types`, `prefer_final_locals`, `prefer_single_quotes`, `unawaited_futures`) 중 하나로 해야 실패한다. 나머지 6개는 지워도 기반 세트가 켠다
- **D-02:** `riverpod_lint` 진단은 **2~3건**만 정답지에 넣는다. 코드 생성 없이 낼 수 있는 규칙(`research/FEATURES.md` 표의 대상 "전체" 6개) 중에서 고르고, 강도가 서로 다른 규칙을 섞는다 (어느 규칙인지는 spike 의 강도 실측 뒤에 정한다).
  - `example/` 에 코드 생성 도구(`build_runner`, `riverpod_generator`)를 붙이지 않는다
  - 15개 규칙 각각의 강도·JSON `code` 표기 조사 결과는 정답지가 아니라 **spike 기록 문서**에 남긴다
  - 2건 이상인 이유: Phase 3 의 PRESET-07 ("plugin 진단 하나를 끄면 그 진단만 사라진다")이 남는 진단을 필요로 한다
  - 고르지 않은 안: 일반 코드용 6개 전부 / 15개 전부. plugin 버전은 고정되지 않으므로(`^3.1.3` 이 실행 시점의 최신 3.x 로 풀린다) 줄이 많을수록 저장소 변경 없이 정답지가 깨진다
- **D-03:** "나오면 안 되는 경고" 샘플을 **이 phase 에서** `example/` 에 넣는다 — 위반을 담은 생성 파일 샘플(`*.g.dart`, `*.freezed.dart` 패턴에 걸리는 파일)과 `invalid_annotation_target` 을 일으키는 annotation 샘플. 정답지에는 이들의 진단이 없다.
  - 헛통과가 아님을 보이기 위해, 배포 파일의 해당 설정 줄(`analyzer.exclude` 항목, `invalid_annotation_target: ignore`)을 **임시로 지웠을 때 정답지와 달라지는지를 한 번 확인하고 기록**한다. 지운 것은 커밋하지 않고 되돌린다 (VERIFY-08 과 같은 방식이며 같은 기록에 함께 남긴다)
  - 상시 대조군 fixture 는 로드맵대로 Phase 3 (VERIFY-05) 에서 만든다
  - 고르지 않은 안: Phase 3 로 미루기 / 지금 대조군 fixture 까지 만들기
- **D-04:** 정답지 한 줄은 **`상대경로:줄  강도  규칙이름`** 이고, 맨 위에 종료 코드 줄(`exit N`)을 둔다. 메시지 문구는 적지 않는다.
  - 경고가 생기거나 사라질 때와 강도가 바뀔 때 검증이 실패한다
  - 이유: `VERSIONING.md` 가 "이미 켜져 있던 규칙의 강도가 warning 이상으로 올라가면 major"로 정했으므로 강도 변화가 정답지 diff 에서 보여야 한다. 조사 문서끼리 어긋난 `riverpod_lint` 강도의 확정 기록도 된다
  - 고르지 않은 안: 파일·줄·규칙 이름만 / 메시지 문구까지 (SDK 를 올릴 때마다 이유 없이 깨질 수 있다)

### `example/pubspec.lock` 과 주기 점검 (ROADMAP 의 D11 확정)

- **D-05:** **`example/pubspec.lock` 을 커밋한다.** 루트 `.gitignore` 의 `pubspec.lock` 패턴이 `example/` 에도 걸리므로 예외 한 줄을 더한다. 루트 `pubspec.lock` 은 지금처럼 커밋하지 않는다.
  - 이유: 소유자의 컴퓨터와 CI 가 같은 패키지 버전으로 판정한다. 정답지가 깨졌을 때 원인 후보가 "저장소 변경" 또는 "plugin 새 버전"으로 좁혀진다
  - 기반 세트(`flutter_lints`, `lints`)의 새 버전은 소유자가 일부러 올릴 때 들어오고, 그 영향이 정답지 diff 로 보인다
  - lock 이 묶지 못하는 것: `riverpod_lint` plugin 버전 (Analysis Server 가 따로 해석한다). 이 사실은 소유자에게 설명했다
- **D-06:** CI 트리거에 **수동 실행(`workflow_dispatch`)** 을 더한다. **예약 실행(`schedule`)은 두지 않는다.**
  - 이유: 공개 저장소는 60일 동안 활동이 없으면 예약 workflow 가 자동으로 꺼진다. 몇 달씩 손대지 않는 저장소라 믿기 어렵다
  - 수동 실행 버튼은 workflow 파일이 기본 브랜치(`main`)에 들어간 뒤, 곧 릴리스 뒤에야 GitHub 화면에 나타난다
- **D-07:** 검증 명령의 출력에 **실제로 쓰인 버전**을 찍는다 — SDK(Flutter / Dart), 기반 세트(`flutter_lints` / `lints`), 해석된 `riverpod_lint` 버전. 정답지가 깨졌을 때 원인을 화면에서 바로 알 수 있게 한다.

### GitHub 에 올리기와 CI 실행 범위

- **D-08:** CI 를 돌리기 위해 작업 브랜치 `gsd/v2.0-package-rework` 를 **`.planning/` 과 함께 그대로** 올린다. `.planning/` 을 걸러 낸 사본 브랜치는 만들지 않는다. — **Reversibility:** one-way — 공개 저장소에 올린 내용은 브랜치를 지워도 복제본·캐시에 남을 수 있어 사실상 되돌릴 수 없다
  - 논의 시점에 확인한 공개 범위: `.planning/` 38개 파일, `.claude/CLAUDE.md`, `VERSIONING.md`. 비밀번호·토큰은 없다. 이메일 주소는 1곳에 나오지만 이미 공개된 커밋 18개의 작성자 정보와 같은 주소다. 다른 프로젝트 이름이 18개 파일에, 로컬 절대 경로(`/Users/woody/…`)가 9개 파일에 있다. 커밋 메시지 51개에 Claude 세션 주소가 있다 (본인 계정으로만 열리는지는 확인하지 못했다고 소유자에게 밝혔다)
  - 고르지 않은 안: `/gsd-pr-branch` 로 `.planning/` 을 뺀 사본을 올리기. 로컬과 원격의 이력이 릴리스 이후까지 달라져 git 작업이 복잡해진다
- **D-09:** push 확인은 **첫 번째만** 받는다.
  - 첫 push 는 phase 초반 spike 단계에서 일어난다 (GitHub runner 에서만 확인되는 spike 가 있다). 확인 요청에는 올릴 것의 목록, 실행할 명령, 되돌릴 수 없다는 점을 쉬운 말로 적는다 (01-CONTEXT.md D-19 와 같은 형식)
  - 그 뒤 **Phase 2 안에서, 같은 브랜치에 커밋을 더 올리는 것**은 묻지 않고 실행한 뒤 결과를 보고한다
  - 포함하지 않는 것: 이미 올린 것을 덮어쓰는 push(`--force` 계열), `main`, tag, 다른 브랜치. 이들은 지금처럼 매번 확인받는다. Phase 3 부터는 다시 묻는다
  - push 는 브랜치 이름 하나만 지정한다. `--force`, `--tags`, `--all` 을 쓰지 않는다 (01-CONTEXT.md D-20 과 같은 원칙)
- **D-10:** CI 는 **모든 브랜치의 push, pull request, 수동 실행**에서 돈다. 겹치는 실행은 `concurrency` 로 자동 취소한다. 작업 브랜치를 점검하려고 PR 을 미리 열어 두지 않는다.
  - 이유: 올리기만 하면 결과가 보이고, `main` 에 합치는 방법(Phase 6 의 결정)을 지금 묶어 두지 않는다
  - tag 트리거는 이 phase 에서 넣지 않는다 (Phase 6 의 REL-03)
    - 덧붙임 (2026-10-12, gap 닫기 02-05): 필터 없는 `push:` 는 GitHub Actions 동작상 tag push 에서도 돈다 (02-REVIEW.md WR-07, 02-VERIFICATION.md 사람 확인 6 · P12). 소유자 결정 — 동작은 그대로 두고 `.github/workflows/verify.yml` 의 주석만 "모든 브랜치와 tag" 로 바로잡는다. `branches: ['**']` 를 넣어 브랜치에서만 돌게 하는 안은 고르지 않았다. 릴리스 tag 에서 검증이 한 번 더 도는 것은 해가 없다. Phase 6 (REL-03) 이 `tags:` 를 더할 때 브랜치 push 가 빠지지 않도록 workflow 주석이 경고한다. 위 문장 "tag 트리거는 이 phase 에서 넣지 않는다" 는 "tag 전용 트리거 · 검사를 더하지 않는다" 는 뜻으로 읽는다.
  - 작업 브랜치를 올려도 사용 프로젝트 5개에는 영향이 없다. 그 프로젝트들은 `main` 을 따르고 `main` 은 이 phase 에서 건드리지 않는다

### 점검 명령의 모양

- **D-11:** 검증 명령은 **Dart 스크립트**다. 위치는 `tool/verify.dart`, 로컬 실행은 `fvm dart run tool/verify.dart`, CI 는 `dart run tool/verify.dart` 다. 패키지 의존성을 추가하지 않는다 (`dart:io`, `dart:convert` 만 쓴다).
  - 저장소에 처음으로 `.dart` 파일이 생긴다. `lib/` 밖이므로 VERIFY-07 과 "배포 산출물에 Dart 코드 없음"은 그대로다
  - 고르지 않은 안: 셸 스크립트 + `jq`
- **D-12:** 스크립트는 시작할 때 실행 중인 SDK 가 `.fvmrc` 와 다르면 **검증을 시작하지 않고 올바른 명령을 알려 준다.** (논의 중 Claude 가 제안했고 소유자가 반대하지 않았다. 명시적으로 고른 선택지는 아니다.)
- **D-13:** 화면 출력은 **안내형**이다. `<specifics>` 의 미리보기를 따른다.
  - 맨 위에 쓰인 버전 (D-07)
  - 검사 단계별 통과·실패
  - 달라진 경고를 "정답지에는 있는데 나오지 않은 경고" / "정답지에 없는데 나온 경고" 로 나눠 표시
  - 다음에 할 일을 한국어로 안내 (규칙 이름과 명령은 영어 그대로)
  - 고르지 않은 안: 실패한 항목과 diff 만 보여 주는 짧은 형
- **D-14:** 정답지는 **`--update` 플래그**로 갱신한다.
  - 갱신할 때 무엇이 바뀌었는지 화면에 줄 단위로 보여 준다 (조용히 덮어쓰지 않는다)
  - CI 에서는 `--update` 가 동작하지 않는다
  - 갱신된 정답지의 git diff 가 "이 변경으로 생기거나 사라진 경고"의 기록이다. 커밋 전에 검토한다
  - 고르지 않은 안: 갱신 기능 없이 손으로만 편집
- **D-15:** spike 결과의 처리 기준.
  - **멈추고 소유자에게 돌아온다:** "정답지 비교로 판정한다"는 확정 결정이나 로드맵의 성공 기준을 그대로는 지킬 수 없다는 결과가 나왔을 때. 논의에서 든 예: GitHub runner 의 cold 실행에서 plugin 진단이 빠진다 / `example/` 을 작업 디렉터리로 두고 인자 없이 실행해도 plugin 진단을 잃는다
  - **기록하고 계속 진행한다:** 값이나 세부만 달라지는 결과 (종료 코드 숫자, 강도와 `code` 표기, `pub get` 우회 방법, `unnecessary_await_in_return` 의 상태)
  - 어느 경우든 6가지의 결과는 모두 기록 문서로 남긴다
  - 고르지 않은 안: 하나라도 예상과 다르면 멈춤 / 멈추지 않고 우회

### Claude's Discretion

소유자에게 묻지 않고 조사·계획 단계에 맡긴 것. 조사 문서의 권고안이 기본값이다.

- spike 6가지의 실행 형식과 기록 자리. 로드맵은 "나머지를 계획하기 전에"를 요구한다. `/gsd-spike` 로 따로 실행해 `--wrap-up` 결과를 계획 단계가 읽게 할 수도 있고, 계획의 첫 wave 로 두고 결과에 따라 나머지를 다시 계획할 수도 있다
- 샘플 Dart 파일을 몇 개로 나눌지, 정답지 줄의 정렬 순서와 열 정렬
- fixture 를 `example/` 하나로 둘지, `example/` 이 옛 URI 한 줄(`package:woody_lints/analysis_options.yaml`)을 쓰는 "전체" 구성을 겸할지 (ROADMAP Notes: 계획 때 정함)
- `invalid_annotation_target` 샘플의 재료 (어느 패키지의 annotation 을 쓸지)
- deprecated / removed / 존재하지 않는 규칙 검사의 구현 — 배포 파일을 `analysis_options.yaml` 이름으로 복사해 분석하는 방식과 복사 위치
- plugin 준비 실패를 알아채는 방법 (stderr 문구 감시 등). spike 결과에 따른다
- 루트 `analysis_options.yaml` 에 `example/**` exclude 를 더할지. 기존 `lib/analysis_options.yaml` exclude 는 유지한다
- `flutter pub get` 이 `example/analysis_options.yaml` 에 `build/**` exclude 를 덧붙이는 문제의 처리, `example/` 에서 `dart pub get` 을 쓸지
- CI job 의 `timeout-minutes` 값, action 버전 (구현 시점에 릴리스 페이지에서 확인), pub cache 사용 여부. `~/.dartServer` 는 캐시하지 않는다
- 스크립트의 종료 코드 규약, 검사 단계의 개수와 순서, `tool/verify.dart` 가 루트 분석에서 받는 규칙
- VERIFY-08 과 D-03 의 "지워 보기" 확인 기록을 남길 자리
- `CHANGELOG.md` 의 2.0.0 항목에 이 phase 의 변경을 적을지. 적는다면 "사용하는 프로젝트에는 영향 없음"을 명시한다 (`VERSIONING.md` 기준표: 저장소 안쪽만 바뀜 = 버전을 올리지 않음)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 범위와 요구사항

- `.planning/ROADMAP.md` § "Phase 2: Verification Harness" — goal, success criteria 5개, Spike first 6개, decision point D11, Notes
- `.planning/ROADMAP.md` § "모든 phase 에 걸친 제약" — `main` 은 1.3.0 유지, 확인되지 않은 도구 동작은 먼저 실행, 원격 작업은 소유자 확인
- `.planning/REQUIREMENTS.md` — VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-04, VERIFY-07, VERIFY-08. 이 phase 가 아닌 것: VERIFY-05 (Phase 3), VERIFY-06 (Phase 5)
- `.planning/PROJECT.md` § Constraints, § Key Decisions — 정답지 비교가 주 수단, milestone 브랜치 전략, `dart analyze` 사용

### 검증 구조의 근거

- `.planning/research/SUMMARY.md` § "Phase 2: 검증 하네스와 CI", § "문서 사이에 어긋나는 지점" 1·2·3·4·13번, § "Gaps to Address" 의 Phase 2 항목, 결정 표의 D5 · D11
- `.planning/research/ARCHITECTURE.md` § "E. 저장소 안 검증 구조" — `dart analyze` JSON 형태와 종료 코드, 스크립트가 단언할 것, fixture 가 루트 분석에 섞이지 않게 하기, workflow 초안. **주의:** Tier 0 설명의 "조각의 문제는 `included_file_warning` 으로 올라온다"는 deprecated / removed 규칙에 대해 실측과 어긋난다 (SUMMARY.md 어긋나는 지점 2번). "`riverpod_lint` 규칙은 모두 warning"도 확정되지 않았다 (3번)
- `.planning/research/ARCHITECTURE.md` § "Pattern 3: 진단 골든 비교" — 스크립트 골격 예시. **주의:** 예시의 정답지 형식 `(파일, 줄, code)` 는 D-04 로 대체되었다 (강도 포함)
- `.planning/research/ARCHITECTURE.md` § "Anti-Pattern 3", § "Anti-Pattern 4" — `example/` 을 workspace 멤버로 묶지 않기, JSON 출력만 보고 판정하지 않기
- `.planning/research/PITFALLS.md` § "Pitfall 1" (deprecated / removed 규칙이 조용히 죽는다), § "Pitfall 12" (plugin 이 로드되지 않았는데 통과), § "Pitfall 13" (아무것도 증명하지 못하는 example), § "Pitfall 14" (분석 컨텍스트가 새거나 가린다, `pubspec.lock` 패턴), § "Pitfall 15" (CI 툴체인과 action 버전)
- `.planning/research/STACK.md` § "GitHub Actions" — action 버전, 종료 코드 표(실측), 캐시 주의점. § "검증 기법" — 복사 방식의 deprecated 검사(실측). **주의:** `--fatal-infos` + `// ignore` + `unnecessary_ignore` 방식은 주 수단이 아니다 (SUMMARY.md D5)
- `.planning/research/FEATURES.md` § "riverpod_lint 3.x" — 진단 15개의 표 (대상 "전체" 6개 / "generator" 9개, 문서상 강도). D-02 의 후보 목록이다

### 버전·기록 정책

- `VERSIONING.md` § "기준표" — 규칙 강도를 warning 이상으로 올림 = major (D-04 의 근거), 저장소 안쪽만 바뀜 = 버전을 올리지 않음
- `.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md` § D-17 · D-19 · D-20 (원격 작업의 확인 형식과 push 원칙), § Deferred Ideas 의 "milestone 브랜치를 올리면 `.planning/` 이 공개된다" (D-08 로 닫음)

### 저장소 현황과 관례

- `.planning/codebase/TESTING.md` § "검증 공백", § "테스트를 추가할 때의 배치 지침" — fixture 는 `example/`, 스크립트는 `tool/`
- `.claude/CLAUDE.md` § Conventions — 문서는 한국어, 영어 식별자 뒤 조사는 한 칸 띄움, Conventional Commits, `pubspec.lock` 관례 (D-05 가 `example/` 에 한해 예외를 둔다)

### 논의에서 참고한 외부 문서

- https://dart.dev/tools/pub/private-files — 앱은 `pubspec.lock` 을 커밋, 라이브러리는 커밋하지 않음 (D-05)
- https://docs.github.com/en/actions/how-tos/manage-workflow-runs/disable-and-enable-workflows — 공개 저장소의 예약 workflow 는 60일 무활동 시 자동으로 꺼짐 (D-06)
- https://dart.dev/tools/pub/create-packages — 공개하지 않는 개발용 도구는 `tool/` 에 둔다 (D-11)

### 고치거나 새로 만드는 파일

- `example/` — 새로 만든다 (`pubspec.yaml`, `analysis_options.yaml`, 위반 샘플 Dart 파일, 정답지, `pubspec.lock`)
- `tool/verify.dart` — 새로 만든다
- `.github/workflows/` — 새로 만든다
- `.gitignore` — `example/pubspec.lock` 예외를 더한다
- `lib/`, `pubspec.yaml`, 루트 `analysis_options.yaml` 의 기존 exclude — **바꾸지 않는다**

</canonical_refs>

<code_context>
## Existing Code Insights

### 논의 시점의 저장소 상태 (2026-10-11 확인)

- `example/`, `tool/`, `.github/`, `test/` 가 모두 없다. Dart 파일은 0개다
- 추적 파일(`.planning/` 제외): `.claude/CLAUDE.md`, `.fvmrc`, `.gitignore`, `.vscode/settings.json`, `CHANGELOG.md`, `README.md`, `VERSIONING.md`, `analysis_options.yaml`, `lib/analysis_options.yaml`, `pubspec.yaml`
- 현재 브랜치 `gsd/v2.0-package-rework` 는 원격에 없다. `origin/main` 은 `90a2736` (1.3.0) 이고 브랜치는 그보다 커밋 52개 앞선다
- `origin` 은 공개 저장소 `woodkill/woody_lints` 다. GitHub Actions 가 켜져 있고(`allowed_actions: all`) `gh` CLI 가 로그인되어 있다
- `.gitignore` 의 `pubspec.lock` 패턴은 경로 접두사가 없어 `example/pubspec.lock` 에도 걸린다
- `pubspec.yaml` 은 `version: 2.0.0-dev`, `sdk: ^3.13.0`, `dependencies: flutter_lints: ^6.0.0` 이다

### Reusable Assets

- `lib/analysis_options.yaml` 23–40행 — 정답지가 고정할 규칙 12개의 목록. 31행·34행의 주석 처리된 규칙은 대상이 아니다
- `lib/analysis_options.yaml` 43–47행 — D-03 의 "지워 보기" 대상 (`invalid_annotation_target: ignore`, `**/*.freezed.dart`, `**/*.g.dart`)
- `lib/analysis_options.yaml` 57–58행 — `plugins: riverpod_lint: ^3.1.3`
- `.planning/research/ARCHITECTURE.md` 의 스크립트 골격과 workflow 초안, `.planning/research/STACK.md` 의 복사 방식 검사 스니펫 — 출발점으로 쓸 수 있다

### Established Patterns

- 검증 명령은 로컬에서 `fvm dart …` 로 실행한다 (Phase 1). CI 는 `.fvmrc` 를 읽어 같은 버전을 설치한다
- 루트 `analysis_options.yaml` 이 `lib/analysis_options.yaml` 을 exclude 한다. 이 phase 에서 유지한다
- 실측으로 확인한 동작은 버전과 날짜를 함께 적는다 (`lib/analysis_options.yaml` 55–56행의 방식)
- 소유자에게 하는 확인 요청과 화면 문구는 쉬운 말로 쓴다 (01-CONTEXT.md, D-13)

### Integration Points

- **Phase 3:** 프리셋 분리의 완료 기준이 "`example/` 정답지가 한 줄도 바뀌지 않는다"이다. 규칙이 `base.yaml` 로 옮겨 가므로 deprecated / removed 검사의 대상 파일이 바뀐다. 대조군 fixture(VERIFY-05)와 재정의 fixture(PRESET-07)가 같은 스크립트에 더해진다
- **Phase 4:** 규칙 결정마다 정답지 diff 가 하나씩 대응해야 한다. D-14 의 `--update` 흐름이 그 기록을 만든다
- **Phase 5:** README ↔ YAML 비교 검사(VERIFY-06)가 같은 명령에 더해진다. README 는 `riverpod_lint` 의 강도를 이 phase 의 실측으로 확정된 범위에서만 단정형으로 쓴다
- **Phase 6:** tag 트리거와 버전 일치 검사(REL-03)가 같은 workflow 와 스크립트에 더해진다. workflow 가 `main` 에 들어간 뒤 D-06 의 수동 실행 버튼이 보인다

</code_context>

<specifics>
## Specific Ideas

### 소유자가 고른 정답지 미리보기 (형식을 그대로 따른다)

파일 이름, 줄 번호, 강도, 종료 코드 숫자는 예시다. 실제 값은 spike 와 구현에서 나온다.

```text
# example/expected_diagnostics.txt

exit 2
lib/added_rules.dart:8    info     prefer_const_constructors
lib/added_rules.dart:14   info     prefer_final_locals
lib/added_rules.dart:21   info     unawaited_futures
lib/base_rules.dart:5     info     avoid_print
lib/riverpod_rules.dart:6 warning  missing_provider_scope
lib/riverpod_rules.dart:15 info    avoid_public_notifier_properties
```

강도가 바뀌면 diff 가 이렇게 보여야 한다.

```text
- lib/added_rules.dart:8  info     prefer_const_constructors
+ lib/added_rules.dart:8  warning  prefer_const_constructors
```

### 소유자가 고른 화면 미리보기 (구성을 그대로 따른다)

```text
$ fvm dart run tool/verify.dart

SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/3] lib/ 에 .dart 파일 없음 ........ 통과
[2/3] 배포 파일의 규칙 이름 ......... 통과
[3/3] example/ 정답지 비교 .......... 실패

정답지에는 있는데 나오지 않은 경고 (1)
  lib/added_rules.dart:14  info  prefer_final_locals

정답지에 없는데 나온 경고 (0)

일부러 바꾼 것이면 정답지를 갱신하세요:
  fvm dart run tool/verify.dart --update

점검 실패 (3개 중 1개)
```

### 소유자와 소통하는 방식

- 논의에서 통한 쉬운 말: 기대 진단(golden)은 "정답지", fixture 는 "일부러 규칙을 어긴 연습용 프로젝트", `pubspec.lock` 은 "받은 패키지 버전을 적어 둔 영수증", CI 는 "GitHub 이 대신 돌려 주는 자동 점검", push 는 "GitHub 에 올린다", `workflow_dispatch` 는 "수동 실행 버튼"
- 결정을 요청할 때는 용어 풀이와 비교표를 먼저 보이고 `권고:` 한 줄을 적는다. 소유자는 이번 논의의 선택 13건 모두에서 권고안을 골랐다
- D-09 의 첫 push 확인 요청에 D-08 의 공개 범위 표를 다시 보여 준다

</specifics>

<deferred>
## Deferred Ideas

논의 중에 나왔지만 이 phase 의 일이 아닌 것.

- **`riverpod_lint` plugin 을 정확한 버전에 묶을지** — lock 을 커밋해도 plugin 버전은 묶이지 않는다. Phase 3 의 D6 에서 정한다
- **상시 대조군 fixture** — "나오면 안 되는 경고"의 상시 증명. Phase 3 의 VERIFY-05 (로드맵에 이미 있다)
- **예약 점검(`schedule`)** — 이번에는 두지 않기로 했다 (D-06). 저장소 활동이 잦아지면 다시 검토한다
- **`example/` 의 lock 을 새로 받는 시점** — 릴리스 절차에 `example/` 의 `pub upgrade` 단계를 넣을지. Phase 6 의 릴리스 절차 문서에서 검토한다
- **릴리스 때 `main` 에 합치는 방법** — PR 을 거칠지, 어느 커밋에 tag 를 달지. Phase 6 의 결정이다 (D-10 은 이를 묶어 두지 않는다)
- **README 가 `example/` 을 "사용 예"로 가리킬지** — 이 phase 의 `example/` 은 검증용이다. Phase 5 에서 정한다

</deferred>

---

*Phase: 2-Verification Harness*
*Context gathered: 2026-10-11*
