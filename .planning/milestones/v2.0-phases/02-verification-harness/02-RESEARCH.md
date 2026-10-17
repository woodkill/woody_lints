# Phase 2: Verification Harness - Research

**Researched:** 2026-10-11
**Domain:** `dart analyze` 기대 진단(golden) 비교 하네스, analyzer plugin(`riverpod_lint`) 준비 판정, deprecated / removed 규칙 검사, GitHub Actions CI
**Confidence:** HIGH — 로드맵의 "Spike first" 6가지는 spike 001~008 이 이미 실행으로 확정했고(모두 VALIDATED, D-15 의 멈춤 조건 해당 없음), 계획에 남아 있던 세부(규칙 12개 ↔ 위반 1건 대응, D-03 샘플 재료, "지워 보기" 결과, 규칙 검사의 fresh checkout 조건, 루트 분석에서 스크립트가 받는 규칙)는 이 세션에서 스크래치 복사본으로 직접 재어 확인했다. 저장소 안의 파일은 이 문서 하나만 만들었다.

**근거 표기**

| 표기 | 뜻 |
|------|-----|
| `[VERIFIED: spike NNN]` | `.planning/spikes/NNN-…/` 의 실측 기록. 요약은 `.claude/skills/spike-findings-woody-lints/` 의 references 에 있다 |
| `[VERIFIED: local <경로/명령>]` | 2026-10-11 이 머신에서 직접 실행하거나 파일을 열어 확인. 출력은 본문에 그대로 붙였다 |
| `[CITED: url]` | 공식 문서 / 원본 소스에서 읽음 |
| `[ASSUMED]` | 확인하지 않은 추정. "Assumptions Log" 에 모았다 |

이 세션의 실험은 모두 `/private/tmp/claude-501/-Users-woody-dv-woody-woody-lints/e22a9fc9-438a-4569-baaa-2d4c9246b9d9/scratchpad/research-p2/` 아래에서 했다 (`replica/` 저장소 설정 파일 사본 + `replica/example/` 연습용 프로젝트, `state/` 전용 상태 폴더, `mutate.sh` "지워 보기" 스크립트, `norm.py` 정답지 정규화). 실측 조건: Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, `flutter_riverpod` 3.4.3, `flutter_lints` 6.0.0 / `lints` 6.1.0, macOS arm64.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### 이전에 확정되어 그대로 따르는 것

다시 논의하지 않았다. 출처는 ROADMAP.md / REQUIREMENTS.md / PROJECT.md / 01-CONTEXT.md 다.

- 판정은 종료 코드가 아니라 정답지 비교(golden comparison)가 주 수단이다 (PROJECT.md Key Decisions)
- plugin 진단 확인은 `dart analyze` 로 한다. `flutter analyze` 는 Flutter 3.47.5 에서 plugin 진단을 내지 않는다
- 검증과 실측은 저장소 고정 SDK(Flutter 3.47.5 / Dart 3.13.4) 위에서 돈다. 로컬은 `fvm dart …`, 버전의 단일 원천은 `.fvmrc` 다
- CI workflow 는 읽기 권한만 갖고(`permissions: contents: read`) job 에 시간 제한을 둔다
- ROADMAP 의 "Spike first" 6가지는 이 phase 의 나머지를 계획하기 전에 실행으로 확인한다
- lint 는 info 라 `dart analyze` 의 기본 종료 코드가 0 이다. deprecated / removed 규칙은 include 경유로는 보고되지 않으므로, 규칙이 적힌 파일을 `analysis_options.yaml` 이름으로 분석 대상 안에 두는 단계가 따로 필요하다 (ROADMAP Notes, 실측)
- `example/` 은 pub workspace 멤버로 만들지 않는다 (`research/ARCHITECTURE.md` Anti-Pattern 3)
- 문서와 주석은 한국어로 쓰고 규칙명·키·명령은 영어 원문을 쓴다

#### 정답지에 담을 범위와 형식

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

#### `example/pubspec.lock` 과 주기 점검 (ROADMAP 의 D11 확정)

- **D-05:** **`example/pubspec.lock` 을 커밋한다.** 루트 `.gitignore` 의 `pubspec.lock` 패턴이 `example/` 에도 걸리므로 예외 한 줄을 더한다. 루트 `pubspec.lock` 은 지금처럼 커밋하지 않는다.
  - 이유: 소유자의 컴퓨터와 CI 가 같은 패키지 버전으로 판정한다. 정답지가 깨졌을 때 원인 후보가 "저장소 변경" 또는 "plugin 새 버전"으로 좁혀진다
  - 기반 세트(`flutter_lints`, `lints`)의 새 버전은 소유자가 일부러 올릴 때 들어오고, 그 영향이 정답지 diff 로 보인다
  - lock 이 묶지 못하는 것: `riverpod_lint` plugin 버전 (Analysis Server 가 따로 해석한다). 이 사실은 소유자에게 설명했다
- **D-06:** CI 트리거에 **수동 실행(`workflow_dispatch`)** 을 더한다. **예약 실행(`schedule`)은 두지 않는다.**
  - 이유: 공개 저장소는 60일 동안 활동이 없으면 예약 workflow 가 자동으로 꺼진다. 몇 달씩 손대지 않는 저장소라 믿기 어렵다
  - 수동 실행 버튼은 workflow 파일이 기본 브랜치(`main`)에 들어간 뒤, 곧 릴리스 뒤에야 GitHub 화면에 나타난다
- **D-07:** 검증 명령의 출력에 **실제로 쓰인 버전**을 찍는다 — SDK(Flutter / Dart), 기반 세트(`flutter_lints` / `lints`), 해석된 `riverpod_lint` 버전. 정답지가 깨졌을 때 원인을 화면에서 바로 알 수 있게 한다.

#### GitHub 에 올리기와 CI 실행 범위

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
  - 작업 브랜치를 올려도 사용 프로젝트 5개에는 영향이 없다. 그 프로젝트들은 `main` 을 따르고 `main` 은 이 phase 에서 건드리지 않는다

#### 점검 명령의 모양

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

### Deferred Ideas (OUT OF SCOPE)

논의 중에 나왔지만 이 phase 의 일이 아닌 것.

- **`riverpod_lint` plugin 을 정확한 버전에 묶을지** — lock 을 커밋해도 plugin 버전은 묶이지 않는다. Phase 3 의 D6 에서 정한다
- **상시 대조군 fixture** — "나오면 안 되는 경고"의 상시 증명. Phase 3 의 VERIFY-05 (로드맵에 이미 있다)
- **예약 점검(`schedule`)** — 이번에는 두지 않기로 했다 (D-06). 저장소 활동이 잦아지면 다시 검토한다
- **`example/` 의 lock 을 새로 받는 시점** — 릴리스 절차에 `example/` 의 `pub upgrade` 단계를 넣을지. Phase 6 의 릴리스 절차 문서에서 검토한다
- **릴리스 때 `main` 에 합치는 방법** — PR 을 거칠지, 어느 커밋에 tag 를 달지. Phase 6 의 결정이다 (D-10 은 이를 묶어 두지 않는다)
- **README 가 `example/` 을 "사용 예"로 가리킬지** — 이 phase 의 `example/` 은 검증용이다. Phase 5 에서 정한다
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| VERIFY-01 | 저장소 안의 `example/` 프로젝트가 배포 설정을 include 하고, 기대한 진단(이 패키지가 추가한 규칙, 기반 세트 규칙, `riverpod_lint` 진단)이 실제로 보고되는지를 커밋된 기대 진단 파일과 비교해 판정한다 | § "권고 1 — `example/` 의 구성", § "권고 2 — 정답지", § "Code Examples" 의 샘플 전문과 실측 정답지 16줄 (추가 규칙 6 + 기반 세트 겹침 6 + 기반 세트만 1 + plugin 3). 실행 형태와 판정 순서는 spike 001/002/008 |
| VERIFY-02 | 규칙이 적힌 배포 파일에 deprecated / removed / 존재하지 않는 규칙이 있으면 검증이 실패한다 | § "권고 5 — 규칙 검사" (spike 005/007 + 이 세션의 fresh checkout 실측: 루트 `dart pub get` 이 선행 조건) |
| VERIFY-03 | 소유자는 로컬에서 명령 하나로 전체 검증을 실행할 수 있다 | § "권고 10 — `tool/verify.dart` 의 모양" (단계 4개, 종료 코드 규약, D-12 SDK 확인의 구현) |
| VERIFY-04 | GitHub Actions 가 push 와 PR 마다 로컬과 같은 검증을 실행하며, 시간 제한이 걸려 있다 | § "권고 9 — CI workflow" (spike 006 의 실제 실행 + action 버전 재확인 + 공식 문서 인용). 원격 브랜치는 이미 올라가 있다 (§ "원격 상태") |
| VERIFY-07 | `lib/` 에 `.dart` 파일이 있으면 검증이 실패한다 | § "권고 10" 의 단계 1 (`Directory('lib').listSync(recursive: true)` 로 `.dart` 검색) |
| VERIFY-08 | 검증이 실제로 문제를 잡아냄이 확인되어 있다 — 규칙 하나를 지운 변경과 include 줄을 지운 변경이 각각 검증에서 실패한다 | § "권고 3 — 지워 보기의 실측 결과와 기록 자리" (이 세션에서 6가지 변경을 복사본에서 실제로 만들어 diff 를 받았다) |
</phase_requirements>

## Summary

로드맵이 "계획 전에 확인하라"고 한 6가지는 spike 001~006 이 이미 답했고, 그 답이 남긴 두 공백(`example/` 이 생긴 뒤의 루트 분석, 상태 폴더의 자리)은 007·008 이 메웠다. 8개 모두 VALIDATED 이고 D-15 의 "멈추고 돌아온다"에 해당한 것은 없다 `[VERIFIED: .planning/spikes/MANIFEST.md, WRAP-UP-SUMMARY.md]`. 계획이 기대는 핵심 사실은 넷이다. (1) `example/` 을 작업 디렉터리로 두고 **경로 인자 없이** `dart --suppress-analytics analyze --format=json` 을 돌리면 plugin 진단이 cold / warm, 로컬 / GitHub runner 모두에서 빠짐없이 나온다. (2) plugin 준비 실패는 종료 코드로는 알 수 없고 stderr 의 머리말 `An error occurred while executing an analyzer plugin:` 을 `contains` 로 찾아야 한다. (3) deprecated / removed 규칙은 include 경유로는 보고되지 않으므로 배포 파일을 `plugins:` 없이 저장소 **안** `build/woody_rule_check/analysis_options.yaml` 로 복사해 그 폴더를 인자로 분석한다. (4) 실제 `riverpod_lint` 버전은 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 준 전용 상태 폴더의 `.plugin_manager/*/pubspec.lock` 에서만 읽을 수 있다.

이 세션은 그 위에서 계획이 정해야 할 세부를 스크래치 복사본으로 재어 확정했다. 규칙 12개 + 기반 세트만 켜는 규칙 1개 + plugin 규칙 3개가 **규칙마다 정확히 한 줄씩** 나오는 샘플 4파일(총 16줄, `exit 2`)을 만들었고, D-03 의 "나오면 안 되는 경고" 샘플 3개(`@immutable` 을 함수에 붙인 `invalid_annotation_target`, 위반을 담은 `*.g.dart` / `*.freezed.dart`)가 정답지에 나오지 않음을 확인했다. VERIFY-08 과 D-03 의 "지워 보기" 6가지(규칙 삭제, `errors:` 삭제, exclude 2종 삭제, include 줄 삭제, deprecated 규칙 추가)를 실제로 만들어 돌렸고 모두 정답지와 달라졌다 — 특히 include 줄을 지우면 lint 16줄이 사라지는 대신 `invalid_annotation_target` **warning** 이 나타나 종료 코드는 그대로 2 다. 종료 코드만 봤다면 통과했을 변경이다. 두 가지 새 사실도 나왔다: 규칙 검사는 **루트의 `dart pub get` 이 먼저** 되어 있어야 한다 (fresh checkout 에서는 `include_file_not_found` 가 나와 검사가 반만 된다), 그리고 루트 옵션 파일에 `include: package:flutter_lints/flutter.yaml` 을 넣으면 `tool/verify.dart` 의 `print` 가 `avoid_print` 에 걸린다 (스크립트는 `stdout.writeln` 을 쓴다).

원격 상태: 작업 브랜치 `gsd/v2.0-package-rework` 는 **이미 origin 에 있다** (`1ed61cd`, 로컬 HEAD 의 5커밋 전 조상). spike 006 의 workflow 가 run `38136362920` 으로 성공했고 그 파일은 `1ed61cd` 에서 지워졌으므로 원격 브랜치에는 지금 workflow 파일이 없다. D-09 의 "첫 push 확인"은 끝났고, 이 phase 안에서 같은 브랜치에 더 올리는 push 는 묻지 않고 실행한 뒤 보고하는 단계다.

**Primary recommendation:** fixture 는 `example/` 하나(옛 URI 한 줄 = "전체" 구성 겸함), 정답지는 § "Code Examples" 의 샘플 4파일을 그대로 써서 실측한 16줄 + `exit 2`, `tool/verify.dart` 는 [SDK 확인 → `pub get` 2회] 뒤 단계 4개([1] `lib/` 에 `.dart` 없음 → [2] 배포 파일의 규칙 이름 → [3] `example/analysis_options.yaml` 이 include 한 줄 → [4] 정답지 비교)를 **모두 돌린 뒤** 요약하며, CI 는 spike 006 의 workflow 뼈대에 `on: [push, pull_request, workflow_dispatch]`, `timeout-minutes: 10`, 캐시 없음으로 `dart run tool/verify.dart` 한 줄을 돌린다.

## Spike first 6가지 — 어느 spike 가 답했고 결과는 무엇인가

ROADMAP Phase 2 의 "Spike first" 순서대로다. D-15 의 분류는 "기록하고 계속" (값·세부만 다름) 과 "멈추고 돌아옴" (정답지 비교 자체가 불가능) 둘이다.

| # | 로드맵의 질문 | 답한 spike | 결과 | D-15 분류 | 남은 것 |
|---|---|---|---|---|---|
| 1 | plugin 준비가 실패했는데 다른 진단이 있을 때 `dart analyze` 의 종료 코드 | 002 (+008) | 종료 코드는 **남은 진단의 강도만** 따른다 (info 뿐이면 0, warning 이 있으면 2). 4 는 진단이 하나도 없을 때만. stdout 은 멀쩡한 JSON 에서 plugin 줄만 빠지고, stderr 에 머리말 `An error occurred while executing an analyzer plugin:` 이 들어 있다 (받기·컴파일 실패는 첫 줄, 잘린 `plugin.aot` 을 읽지 못한 실패는 **셋째 줄** → `contains` 로 찾는다). 9가지 실패 원인 모두 재실행해도 같은 모양 `[VERIFIED: spike 002, 008]` | 기록하고 계속 — 판정 로직을 "stderr 머리말 → 도구가 죽음 → 정답지 비교" 순으로 정하면 된다 | plugin 이 뜬 뒤 분석 도중에 죽는 경우, pub 서버가 느리게 응답만 하는 경우는 재지 않았다 (CI 의 `timeout-minutes` 가 막는다) |
| 2 | `riverpod_lint` 15개 규칙 각각의 심각도와 JSON `code` 표기, 종료 코드 | 003 | **info 3 / warning 11 / error 1.** `code` 는 규칙 이름 그대로 (접두사 없음), `type` 은 전부 `STATIC_WARNING` (강도와 무관하므로 `severity` 로 읽는다). 종료 코드는 강도만 따른다 (info 0 / warning 2 / error 3). 코드 생성 없이 뜨는 규칙은 6개가 아니라 **5개** (`protected_notifier_properties` 는 `@riverpod` class 에서만). GitHub runner 10대에서도 같은 표 `[VERIFIED: spike 003, 006]` | 기록하고 계속 — "전부 warning" 이라는 조사 문서의 추정이 틀렸을 뿐, 정답지에 강도를 넣기로 한 D-04 가 이를 그대로 흡수한다 | generator 계열 6개가 생성 코드 없이도 뜨는지는 재지 않았다 (`example/` 에 넣지 않는다) |
| 3 | GitHub Linux runner 의 cold 실행에서 plugin 진단이 빠짐없이 나오는지, 첫 실행 시간 | 006 | 새 가상 머신 10대, 분석 60번이 **모두** 로컬 정답지와 한 줄도 다르지 않았다. stderr 60번 모두 비어 있음. 첫 분석 약 43초 (27~53초), 재분석 약 8초, job 전체 약 2분 (Flutter 설치 66초). 종료 코드 255 는 0번. 풀린 plugin 은 10대 모두 3.1.9 `[VERIFIED: spike 006, gh run 38136362920]` | 기록하고 계속 — 멈춤 조건의 예시 그 자체였으나 빠지지 않았다 | SDK 캐시(`cache: true`)를 켰을 때의 시간, macOS / Windows runner (쓰지 않는다) |
| 4 | `dart analyze <dir>` 이 plugin 진단을 잃는 문제(flutter#193203, sdk#62710)를 작업 디렉터리 + 인자 없이로 피할 수 있는지 | 001 (+007) | **피할 수 있다.** 패키지 루트를 작업 디렉터리로 두고 인자 없이 돌리면 cold·warm 모두 빠짐없이 나온다. 하위 폴더를 인자로 주면(`dart analyze lib`) plugin 을 준비조차 않고 전부 잃으며 종료 코드도 0 이다. 부수 발견: 사용 통계 전송을 끄지 않으면 가끔 **255** 로 죽는다 (65번 중 8번) → `--suppress-analytics` 를 항상 붙인다 `[VERIFIED: spike 001]` | 기록하고 계속 — 다만 `--suppress-analytics` 는 "조건" 으로 붙었다 | sdk#62710 은 "Dart 3.14 에 실린다"로 닫혔다. SDK 를 올리면 실행 형태 표를 다시 잰다 |
| 5 | `flutter pub get` 이 `example/analysis_options.yaml` 에 `build/**` exclude 를 덧붙이는 문제, Flutter 프로젝트인 `example/` 에서 `dart pub get` 이 되는지 | 004 | **`dart pub get` 이 된다** (`FLUTTER_ROOT` 없이도, SDK 안의 `dart` 를 직접 불러도). 결과는 `flutter pub get` 과 같고(`package_config.json` 35개 동일, lock 글자 하나 다르지 않음) 옵션 파일을 건드리지 않는다. `flutter pub get` 은 옵션 파일 맨 위에 `analyzer: exclude: - build/**` 세 줄을 써넣는다 (끄는 옵션 없음). `--enforce-lockfile` 은 어긋나면 종료 코드 65 `[VERIFIED: spike 004]`, 이 세션에서도 `dart pub get --enforce-lockfile` 이 exit 0 `[VERIFIED: local replica/example]` | 기록하고 계속 — 우회 방법이 정해졌다 | 프리셋에 `build/**` 제외를 넣을지는 Phase 4 로 넘겼다 |
| 6 | `unnecessary_await_in_return` 이 Dart 3.13.4 에서 deprecated 인지 (`rules.json` 과 실측의 불일치) | 005 (+007) | **deprecated 다** (`state: .deprecated(since: 3.13.0)`, `rules.json` 의 `stable` 은 틀렸다). 더 중요한 발견: `deprecated_lint` / `removed_lint` 는 **옵션 파일이 속한 패키지의 pubspec SDK 하한이 그 버전 이상일 때만** 보고된다. 저장소 밖 임시 폴더(pubspec 없음)에서는 `undefined_lint` 만 잡힌다 → 복사본은 저장소 **안**에 둔다. 007 이 실행 형태를 "루트에서 복사본 폴더를 인자로" 로 바꿨다 (0.5초, plugin 준비 없음) `[VERIFIED: spike 005, 007]` | 기록하고 계속 — 규칙 후보에서 제외한 판정이 맞았고, 검사 방식이 확정됐다 | 이 세션이 fresh checkout 상태를 재어 "루트 `dart pub get` 선행" 을 더했다 (§ 권고 5) |

007 과 008 이 더한 것: 루트에 `example/` 이 생기면 루트 분석에 섞인다 (`pub get` 전 exit 3 / 후 exit 2 + plugin 준비 15초) → 루트 옵션 파일에 `example/**` 제외 한 줄 `[VERIFIED: spike 007]`; 전용 상태 폴더를 주면 plugin 폴더가 하나만 생겨 md5 없이 버전을 읽을 수 있고, 잘린 `plugin.aot` 은 지울 때까지 계속 실패하며, 빈 상태 폴더에 처음 실행 둘을 동시에 띄우면 드물게 깨진다 (20쌍 중 1쌍) `[VERIFIED: spike 008]`.

**결론: 여섯 질문 모두 답이 있고, 전부 "기록하고 계속" 이다.** 이 세션은 spike 를 다시 돌리지 않고, 계획에 남은 세부만 복사본에서 쟀다.

## 원격 상태 (D-08 / D-09 의 전제)

```text
$ git ls-remote --heads origin
1ed61cd904eebad1a7b6fdb6e5e80edf9029f179	refs/heads/gsd/v2.0-package-rework
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
$ git merge-base --is-ancestor 1ed61cd HEAD && echo ok   → ok (HEAD 는 5커밋 앞)
$ git log --oneline -1 1ed61cd   → 1ed61cd ci: spike 006 임시 workflow 제거
$ gh run list --limit 5
completed  success  docs(spikes): spike 관례 문서 추가  spike-006-cold-plugin  gsd/v2.0-package-rework  push  38136362920  5m41s  2026-10-11T11:45:31Z
$ git ls-tree -r --name-only 1ed61cd | grep -E "^\.github|^example|^tool"   → (없음)
```
`[VERIFIED: local git ls-remote / gh run list, 2026-10-11]`

- **첫 push 는 이미 일어났다** (spike 006 단계, D-09 의 "첫 번째 확인"). 이 phase 의 나머지 push 는 D-09 대로 묻지 않고 실행한 뒤 결과를 보고한다. `--force`, `main`, tag, 다른 브랜치는 여전히 매번 확인받는다.
- 원격 브랜치에는 workflow 파일이 없다. 실제 CI workflow 를 올리는 커밋이 VERIFY-04 의 "GitHub 에서 실제로 성공한 실행" 을 만든다.
- `.planning/` 은 이미 공개되어 있다. 이 phase 가 만드는 기록 파일에는 로컬 절대 경로를 적지 않는다 (spike CONVENTIONS 와 같다).

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 배포 설정이 적용되는지 판정 (정답지 비교) | 저장소 안 검증 스크립트 `tool/verify.dart` (Dart VM, `dart:io`) | Dart Analysis Server (`dart analyze` 가 띄움) | 판정 주체는 스크립트, 진단 생산 주체는 analyzer. 스크립트는 analyzer 의 JSON 만 읽고 해석하지 않는다 |
| 위반 샘플과 정답지 | `example/` fixture 패키지 (Flutter 패키지, `path: ..` 의존) | — | 사용 프로젝트와 같은 모양이어야 "사용 프로젝트가 받는 그대로" 를 잰다 (Pitfall 13/14) |
| analyzer plugin(`riverpod_lint`) 준비·실행 | Dart Analysis Server 의 plugin manager (전용 상태 폴더 `.plugin_manager/<hash>/`) | pub.dev (매 실행 `dart pub upgrade`) | 스크립트가 제어할 수 없는 외부 단계. 네트워크 필요. 실패는 stderr 로만 드러난다 |
| 규칙 이름 유효성 (deprecated / removed / undefined) | analyzer 의 옵션 파일 검사 (`analysis_options.yaml` 이름으로 분석될 때만 온전함) | 스크립트의 복사·정리 단계 | include 경유로는 보고되지 않으므로 복사본이 필요하다 |
| `lib/` 에 Dart 코드 없음 | 스크립트 (`Directory.listSync`) | — | 파일 시스템 검사면 충분하다 |
| SDK 고정 | `.fvmrc` (단일 원천) → 로컬 `fvm`, CI `subosito/flutter-action` `flutter-version-file` | 스크립트의 D-12 확인 (`bin/cache/flutter.version.json`) | 버전을 적는 자리가 하나뿐이어야 어긋나지 않는다 (Pitfall 15) |
| CI 실행 | GitHub Actions `ubuntu-latest` (`.github/workflows/`) | — | 로컬과 같은 명령 한 줄을 돌리는 껍데기. 판정 로직은 넣지 않는다 |

## Project Constraints (from CLAUDE.md)

`.claude/CLAUDE.md` 에서 이 phase 에 적용되는 지시. "Technology Stack / Conventions / Architecture" 절은 commit `90a2736` 시점의 코드베이스 맵에서 생성되어 **낡았다** (`.fvmrc` 3.41.2, `sdk: ^3.10.4`, `version: 1.3.0` 으로 적혀 있다). 디스크의 현재 값이 우선한다: `.fvmrc` = `3.47.5`, `pubspec.yaml` = `version: 2.0.0-dev` / `sdk: ^3.13.0`, `VERSIONING.md` 존재, `CHANGELOG.md` 맨 위 `## 2.0.0 - 미출시`, `example/` / `tool/` / `.github/` 없음 `[VERIFIED: local .fvmrc, pubspec.yaml, CHANGELOG.md, ls -la]`. `.planning/codebase/*.md` 도 같은 시점이라 같은 주의가 필요하다.

| 지시 | 출처 | 이 phase 에서의 적용 |
|---|---|---|
| SDK 는 Flutter 3.47.x / Dart 3.13 이상만 지원 | Constraints | `example/pubspec.yaml` 의 `sdk: ^3.13.0`, D-12 의 SDK 확인 |
| `package:woody_lints/analysis_options.yaml` URI 는 공개 API, 뜻 유지 | Constraints | `example/analysis_options.yaml` 은 이 URI 한 줄 (옛 URI 가 곧 "전체") |
| 릴리스 전까지 `main` 의 `lib/` 와 `pubspec.yaml` 은 1.3.0 유지 | Constraints | 이 phase 는 `lib/` 를 건드리지 않고 `main` 에 아무것도 합치지 않는다 |
| Git 의존성 + tag 로만 배포, pub.dev 안 올림 | Constraints | `example/` 은 `path: ..` 로 받는다 (git 의존성과의 차이는 Pitfall 참조) |
| 실측은 `flutter_starter_kit` 복사본에서, 원본은 수정하지 않음 | Constraints | 이 phase 는 `flutter_starter_kit` 을 쓰지 않는다 (Phase 4 의 일) |
| plugin 진단 확인은 `dart analyze` 로 (`flutter analyze` 는 누락) | Constraints, Platform Requirements | 스크립트와 CI 모두 `dart analyze` |
| `include:` 대상 패키지는 `dependencies` 에 | Constraints, 의존성 선언 규칙 | 건드리지 않는다. `example/` 쪽은 `dev_dependencies: woody_lints` 로 충분 (spike 001~008 모두 그 형태) |
| YAML 주석·README·CHANGELOG 는 한국어, 규칙명·키는 영어 | Constraints, Comments | `example/` 의 Dart 주석, `tool/verify.dart` 의 주석·화면 문구, workflow 주석 모두 한국어. 영어 식별자 뒤 조사는 한 칸 띄운다 |
| 실측으로 확인한 동작은 버전과 날짜를 함께 적음 | Comments | 정답지 머리 주석과 기록 문서에 SDK / plugin 버전과 날짜 |
| `pubspec.lock` 은 커밋하지 않음 (라이브러리 관례) | Runtime, 의존성 선언 규칙 | **루트**는 유지, `example/pubspec.lock` 만 D-05 로 예외 (`.gitignore` 에 `!example/pubspec.lock`) |
| `plugins:` 섹션을 바꾼 뒤 Analysis Server 재시작 | Platform Requirements | 이 phase 는 바꾸지 않는다. 검증 명령은 전용 상태 폴더를 쓰므로 IDE 서버와 무관 |
| 루트 `analysis_options.yaml` 의 `lib/analysis_options.yaml` exclude 는 유지, `plugins:` 를 루트에 더하거나 `lib/` 에서 빼서 해결하지 않음 | Error Handling, Architectural Constraints | 유지. `example/**` 한 줄만 **더한다** |
| Conventional Commits: prefix 영어, 제목·본문 한국어. 커밋 전 린터 실행 | Git 커밋 규칙, 글로벌 CLAUDE.md | 커밋 전 린터 = 루트에서 `fvm dart analyze` (0.6초). `example/**` 제외가 있어야 이것이 깨끗하다 |
| 공개 함수·클래스에 Docstring, 함수명은 동사로 시작, 에러 핸들링 포함 | 글로벌 CLAUDE.md 코딩 스타일 | `tool/verify.dart` 에 적용 (spike 스크립트들이 이미 이 형식) |
| GSD workflow 밖에서 직접 편집하지 않음 | GSD Workflow Enforcement | 계획·실행 단계가 따른다 |

## Standard Stack

이 phase 는 pub 패키지를 **저장소에** 추가하지 않는다 (D-11). 도구와 `example/` 의 의존성만 있다.

### Core

| 도구 / 패키지 | 버전 | 용도 | 근거 |
|---|---|---|---|
| Flutter SDK (FVM) | 3.47.5 / Dart 3.13.4 | 검증·실측의 고정 SDK | `.fvmrc`, `fvm dart --version` → `3.13.4 (stable) … "macos_arm64"` `[VERIFIED: local]` |
| `dart analyze --format=json` | SDK 동봉 | 진단 생산 | 전역 플래그 `--suppress-analytics` 를 `analyze` 앞에 `[VERIFIED: spike 001]` |
| `dart pub get` | SDK 동봉 | `example/` 와 루트의 패키지 받기 | `--enforce-lockfile` 가능 `[VERIFIED: spike 004, local]` |
| Dart Analysis Server + `riverpod_lint` plugin | `^3.1.3` → 실행 시점 최신 3.x (지금 3.1.9) | plugin 진단 | 전용 상태 폴더 `.plugin_manager/<hash>/pubspec.lock` 에서 `version: "3.1.9"` `[VERIFIED: local state/.plugin_manager]` |
| `flutter_riverpod` (`example/` 의존성) | `^3.0.0` → 3.4.3 | plugin 규칙을 띄울 재료 | `example/pubspec.lock` `[VERIFIED: local replica/example/pubspec.lock]` |
| `flutter_lints` / `lints` | 6.0.0 / 6.1.0 | 기반 세트 | 루트 `pubspec.lock` 과 `example/pubspec.lock` 모두 같은 값 `[VERIFIED: local]` |
| `actions/checkout` | `v7` (최신 v7.0.1, 2026-07-20, `v7` tag → `3d3c42e5…`) | CI checkout | `gh api repos/actions/checkout/releases/latest` `[VERIFIED: local gh api, 2026-10-11]` |
| `subosito/flutter-action` | `v2` (최신 v2.23.0, 2026-03-25, `v2` tag → `1a449444…`) | CI 의 Flutter 설치, `.fvmrc` 읽기 | `gh api repos/subosito/flutter-action/releases/latest`, `action.yaml` `[VERIFIED: local gh api]` |
| `gh` CLI | 2.102.0, `woodkill` 로 로그인 | 실행 결과 확인 (`gh run list / view`) | `[VERIFIED: local gh auth status]` |

spike 가 쓴 action 버전(v7.0.1 / v2.23.0)과 **오늘 조회한 최신이 같다.** 구현 시점에 다시 조회하는 것은 CONTEXT 의 요구이지만 지금 값으로 계획해도 어긋날 가능성은 낮다.

### Alternatives Considered

| 대신 | 쓸 수 있는 것 | 왜 쓰지 않나 |
|---|---|---|
| `dart analyze` (인자 없이, `example/` 에서) | `flutter analyze` / `dart analyze example` | 앞은 plugin 진단을 내지 않고 (Flutter 3.47.5), 뒤는 sdk#62710 과 맞닿은 형태라 채택하지 않았다 `[VERIFIED: spike 001, PROJECT.md]` |
| `dart pub get` | `flutter pub get` | 옵션 파일에 `build/**` 제외 세 줄을 써넣어 작업 트리가 더러워진다 `[VERIFIED: spike 004]` |
| 전용 상태 폴더 | 기본 `~/.dartServer` | 자기 plugin 폴더를 고를 방법이 없다 (md5 없음, 내용에 경로 없음, 재실행이 시각을 안 바꿈) `[VERIFIED: spike 008]` |
| Dart 스크립트 (`dart:io`) | bash + `jq` + `python3` | D-11 로 확정. spike 스크립트가 같은 조건이라 조각을 그대로 옮긴다 |
| 캐시 없는 `flutter-action` | `cache: true` | 재지 않았다. 측정된 구성(60/60 통과, job 2분)을 그대로 쓴다 (§ 권고 9) |

## Package Legitimacy Audit

`gsd-tools query package-legitimacy check` 는 `npm|pypi|crates` 만 받는다 (`--ecosystem pub` → Usage 오류) `[VERIFIED: local]`. pub 생태계는 실제 해석 결과로 대신 확인했다 — 이 phase 는 저장소의 `pubspec.yaml` 에 아무것도 더하지 않고, `example/` 이 받는 패키지는 모두 이미 spike 001~008 과 이 세션의 `dart pub get` 으로 pub.dev 에서 풀렸다.

| Package | Registry | 풀린 버전 | 출처 | Verdict | Disposition |
|---|---|---|---|---|---|
| `flutter_riverpod` | pub.dev | 3.4.3 | `example/pubspec.lock` (`dart pub get`, 2026-10-11) | OK | Approved — Riverpod 공식 패키지 `[VERIFIED: local pub get]` |
| `riverpod_lint` (plugin) | pub.dev (Analysis Server 가 받음) | 3.1.9 | 전용 상태 폴더의 `pubspec.lock` | OK | Approved — 배포 파일이 이미 선언한 plugin `[VERIFIED: local, spike 003/006]` |
| `flutter_lints` / `lints` | pub.dev | 6.0.0 / 6.1.0 | 루트와 `example/` 의 lock | OK | Approved — 기존 의존성 |
| `actions/checkout@v7` | GitHub Marketplace | v7.0.1 | GitHub releases API | OK | Approved — GitHub 공식 `[VERIFIED: local gh api]` |
| `subosito/flutter-action@v2` | GitHub Marketplace | v2.23.0 | GitHub releases API, `action.yaml` | OK | Approved — Flutter 커뮤니티 표준 action, spike 006 이 실제로 썼다 `[VERIFIED: local gh api, spike 006]` |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```text
                    fvm dart run tool/verify.dart [--update]        dart run tool/verify.dart (CI)
                                     │                                        │
                                     └──────────────┬─────────────────────────┘
                                                    ▼
                              ┌──────────────────────────────────────────┐
                              │ 0. 준비                                   │
                              │  · SDK 확인: Platform.resolvedExecutable   │
                              │    → <root>/bin/cache/flutter.version.json │
                              │    ≠ .fvmrc → 올바른 명령 안내, exit 78     │
                              │  · --update 인데 CI=true → 거부, exit 64   │
                              │  · 루트 `dart pub get` (규칙 검사의 include) │
                              │  · example/ `dart pub get --enforce-lockfile`│
                              └──────────────────┬───────────────────────┘
                                                 ▼
   ┌────────────────────┐   ┌──────────────────────────┐   ┌───────────────────────┐   ┌─────────────────────────────────┐
   │ [1/4] lib/ 에 .dart │   │ [2/4] 배포 파일의 규칙 이름 │   │ [3/4] example/ 옵션 파일 │   │ [4/4] example/ 정답지 비교          │
   │  listSync(recursive)│   │  lib/analysis_options.yaml│   │  include 한 줄인가       │   │  cwd=example/, 인자 없음,          │
   │  *.dart 가 있으면 실패│   │  → plugins: 제거          │   │  (flutter pub get 흔적 / │   │  ANALYZER_STATE_LOCATION_OVERRIDE │
   └────────────────────┘   │  → build/woody_rule_check/│   │   include 삭제을 잡는다) │   │  = .dart_tool/woody_verify/example │
                            │    analysis_options.yaml  │   └───────────────────────┘   │  dart --suppress-analytics analyze │
                            │  → 루트에서 그 폴더를 인자로│                               │       --format=json                │
                            │  → deprecated_lint /      │                               │   ├ stderr contains 머리말 → plugin │
                            │    removed_lint /         │                               │   │  준비 실패 (상태 폴더 삭제 안내)   │
                            │    undefined_lint 가 있으면│                               │   ├ exit ∉ {0,2,3} / JSON 없음 →    │
                            │    실패. finally 로 삭제    │                               │   │  도구가 죽음                      │
                            └──────────────────────────┘                               │   └ 정규화 → 정렬 → 정답지와 비교    │
                                                                                       │      (빠진 줄 / 남는 줄 / exit)     │
                                                                                       │   --update: diff 를 보여 주고 덮어씀  │
                                                                                       └─────────────────────────────────┘
                                                 │ (단계 4개를 모두 돌린 뒤)
                                                 ▼
                              ┌──────────────────────────────────────────┐
                              │ 요약: 버전 3줄 (SDK / 기반 세트 / plugin)   │
                              │  단계별 통과·실패, 다음 할 일 안내          │
                              │  exit 0 (전부 통과) / 1 (하나라도 실패)     │
                              └──────────────────────────────────────────┘

외부 경계: pub.dev (example/ 의 pub get 과 Analysis Server 의 매 실행 `dart pub upgrade` — 네트워크 필수),
          GitHub Actions ubuntu-latest (checkout@v7 → flutter-action@v2(.fvmrc) → 위 명령 한 줄)
```

### Recommended Project Structure

```text
woody_lints/
├── lib/analysis_options.yaml        # 바꾸지 않는다
├── analysis_options.yaml            # exclude 에 'example/**' 한 줄 추가 (+ 권고 10 의 include)
├── .gitignore                       # '!example/pubspec.lock', 'build/' 추가
├── example/                         # 새로 만든다 — 사용 프로젝트와 같은 모양
│   ├── pubspec.yaml                 #   flutter, flutter_riverpod ^3.0.0, dev: woody_lints path: ..
│   ├── pubspec.lock                 #   커밋한다 (D-05)
│   ├── analysis_options.yaml        #   include: package:woody_lints/analysis_options.yaml 한 줄
│   ├── expected_diagnostics.txt     #   정답지 (exit 2 + 16줄)
│   ├── README.md                    #   fixture 의 뜻, 종료 코드 설명, "지워 보기" 기록 (권고 3)
│   └── lib/
│       ├── added_rules.dart         #   이 패키지가 추가하는 규칙 6개 (한 건씩)
│       ├── base_rules.dart          #   기반 세트와 겹치는 6개 + 기반 세트만의 1개
│       ├── main.dart                #   missing_provider_scope (warning)
│       ├── riverpod_rules.dart      #   avoid_public_notifier_properties (info), provider_parameters (warning)
│       ├── should_not_appear.dart   #   invalid_annotation_target (억제되어야 함)
│       └── generated/
│           ├── sample.g.dart        #   exclude 되어야 함
│           └── sample.freezed.dart  #   exclude 되어야 함
├── tool/verify.dart                 # 새로 만든다 (dart:io, dart:convert 만)
├── .github/workflows/verify.yml     # 새로 만든다
└── .dart_tool/woody_verify/         # 런타임에 생김 (gitignore 의 .dart_tool/ 에 걸림). fixture 별 상태 폴더
    └── example/.plugin_manager/<hash>/pubspec.lock   ← riverpod_lint 실제 버전
```

`build/woody_rule_check/` 는 단계 2 가 만들고 `finally` 로 지운다. `.gitignore` 에 `build/` 를 더해 남더라도 커밋되지 않게 한다 (`git check-ignore -v build/x` 는 지금 아무 패턴에도 걸리지 않는다 `[VERIFIED: local]`).

### Pattern 1: 정답지 비교 (characterization test) — D-04 형식

**What:** `dart analyze --format=json` 의 stdout 에서 `{` 로 시작하는 마지막 줄을 JSON 으로 읽고, 진단마다 `상대경로:줄  강도  규칙이름` 을 만들어 **문자열 정렬**한 뒤, 맨 위에 `exit N` 을 붙여 커밋된 파일과 비교한다. 문자열 정렬이라 `:13` 이 `:7` 보다 앞에 온다 — 정답지 파일도 같은 규칙으로 정렬해 두고, 비교 전에 양쪽을 다시 정렬하면 손으로 고친 순서에 흔들리지 않는다.
**When to use:** 실행 코드 없이 "다른 도구가 해석하는 설정"이 산출물일 때.
**Example:** § Code Examples 1 (`normalizeDiagnostics`, spike 006/008 의 함수 그대로).

### Pattern 2: plugin 실패는 stderr 머리말로, 도구 사망은 종료 코드·JSON 유무로, 나머지는 정답지로

판정 순서를 바꾸지 않는다 `[VERIFIED: spike 001, 002, 008]`:
1. `stderr.contains('An error occurred while executing an analyzer plugin:')` → "plugin 준비 실패". stderr 원문을 보여 주고 "네트워크를 확인 / 전용 상태 폴더 `<경로>` 를 지우고 다시 실행 (약 15초)" 을 안내한다.
2. 종료 코드 ∉ {0, 2, 3} 이거나 stdout 에 JSON 이 없음 → "도구가 죽음" (255 는 사용 통계 타이밍 문제, 4 는 진단 0건 + 서버 오류).
3. 정답지 비교 → `exit` 줄, 빠진 줄, 남는 줄.

`example/` 의 정답지에 warning 이 들어 있으므로(`exit 2`) plugin 이 죽으면 세 가지(plugin 줄 빠짐, `exit 0` 으로 어긋남, stderr 머리말)가 한꺼번에 어긋난다.

### Pattern 3: 규칙 검사는 복사본을 저장소 안에, `plugins:` 없이, 폴더 인자로

§ 권고 5. `stripPlugins` 는 § Code Examples 3.

### Pattern 4: fixture 마다 전용 상태 폴더

`ANALYZER_STATE_LOCATION_OVERRIDE` 를 fixture **별로** 다르게 준다 (`.dart_tool/woody_verify/<fixture>/`). plugin 폴더 이름이 분석 대상 경로의 md5 이므로, 상태 폴더 하나에 fixture 둘을 돌리면 폴더가 2개가 되어 `readPluginVersion` 의 "폴더가 하나뿐" 전제가 깨진다 `[VERIFIED: spike 008 의 폴더 이름 규칙]` → 지금은 `example/` 하나지만 Phase 3 의 대조군·재정의 fixture 가 같은 스크립트에 들어오므로 처음부터 이 구조로 짠다. 빈 상태 폴더에 처음 실행 둘을 동시에 띄우지 않는다 (fixture 는 **순서대로** 분석한다) `[VERIFIED: spike 008]`.

### Anti-Patterns to Avoid

- **종료 코드만 보고 판정:** include 줄을 지워도 `invalid_annotation_target` warning 때문에 exit 는 2 그대로다 `[VERIFIED: local M4]`. plugin 이 죽어도 0 / 2 다 `[VERIFIED: spike 002]`.
- **하위 폴더를 인자로 주는 `dart analyze`:** plugin 진단을 전부 잃고 exit 0 `[VERIFIED: spike 001]`. 유일한 예외는 plugin 이 필요 없는 규칙 검사의 복사본 폴더.
- **`startsWith` 로 머리말 찾기:** 잘린 `plugin.aot` 실패에서는 셋째 줄 `[VERIFIED: spike 008]`.
- **사용 통계를 끄지 않은 실행:** 로컬에서 65번 중 8번 exit 255 `[VERIFIED: spike 001]`.
- **`example/` 에서 `flutter pub get`:** 옵션 파일이 바뀐다 `[VERIFIED: spike 004]`.
- **복사본을 저장소 밖 임시 폴더에:** `undefined_lint` 만 잡힌다 `[VERIFIED: spike 005]`.
- **루트 `dart pub get` 없이 규칙 검사:** `include_file_not_found` warning 1건으로 끝난다 — 검사가 "실패"로 보이지만 deprecated 를 본 것이 아니다 `[VERIFIED: local M5b]`.
- **`~/.dartServer` 를 CI 에 캐시:** plugin 실패가 가려진다 (Pitfall 12). 캐시 없이도 43초.
- **`example/` 을 workspace 멤버로:** plugin 이 workspace 루트에서만 설정된다 (ARCHITECTURE Anti-Pattern 3, 확정 결정).
- **정답지에 `riverpod_syntax_error`(error) 넣기:** exit 3 이 되어 "warning 이 사라졌다" 를 종료 코드로 구별 못 한다 `[VERIFIED: spike 003]`.
- **`build/**` 제외를 `example/analysis_options.yaml` 에 미리 적기:** "include 한 줄" 이 아니게 되어 사용 프로젝트의 모습과 달라진다.

## 계획이 정해야 할 것 — 근거와 권고

### 권고 1 — fixture 는 `example/` 하나, 옛 URI 한 줄이 "전체" 구성을 겸한다

- `package:woody_lints/analysis_options.yaml` 은 지금 기본 + Riverpod + codegen 전부를 담은 유일한 파일이고, Phase 3 뒤에도 같은 뜻을 유지하는 공개 API 다 (CLAUDE.md Constraints). 따라서 이 URI 한 줄을 쓰는 `example/` 이 곧 "전체" 이자 "옛 URI" 다. SUMMARY.md 어긋나는 지점 13번이 말한 그 구성이다.
- Phase 3 가 더하는 fixture(대조군 `base.yaml` 만, 재정의, `recommended.yaml`)는 **형제 폴더**로 두고 루트 exclude 에 줄을 더한다 (spike 007 은 "폴더마다 제외 줄이 필요할 것" 으로 적었다). `example/` 안에 중첩 패키지를 두면 context root 가 또 갈린다.
- 스크립트는 fixture **목록**을 돌리는 꼴로 짠다 (지금은 원소 하나). 상태 폴더는 fixture 별 (Pattern 4).

### 권고 2 — 정답지: 샘플 4파일 + "나오면 안 되는" 3파일, 16줄, `exit 2`

§ Code Examples 의 파일을 **글자 그대로** 쓰면 아래가 그대로 나온다 `[VERIFIED: local replica/example, baseline 과 final_check 두 번 동일]`:

```text
exit 2
lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
lib/added_rules.dart:18  info  always_declare_return_types
lib/added_rules.dart:24  info  prefer_final_locals
lib/added_rules.dart:29  info  prefer_single_quotes
lib/added_rules.dart:33  info  unawaited_futures
lib/added_rules.dart:7  info  prefer_const_constructors
lib/base_rules.dart:12  info  sort_child_properties_last
lib/base_rules.dart:17  info  use_build_context_synchronously
lib/base_rules.dart:22  info  avoid_print
lib/base_rules.dart:30  info  control_flow_in_finally
lib/base_rules.dart:34  info  slash_for_doc_comments
lib/base_rules.dart:38  info  prefer_is_empty
lib/base_rules.dart:8  info  sized_box_for_whitespace
lib/main.dart:5  warning  missing_provider_scope
lib/riverpod_rules.dart:17  warning  provider_parameters
lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties
```

규칙 12개 ↔ 위반 1건의 대응과, 설계할 때 걸린 함정:

| 규칙 | 기반 세트에 있나 | 샘플 (파일:줄) | 주의 |
|---|---|---|---|
| `prefer_const_constructors` | 아니오 (lints 6 에서 빠짐) | `added_rules.dart:7` `Text('a')` | 다른 줄의 const 가능한 생성자 호출을 모두 피했다 — 리스트 샘플의 원소는 **상수 식별자** `constChild` |
| `prefer_const_literals_to_create_immutables` | 아니오 | `:13` `Column(key: key, children: [constChild])` | `key` 인자로 `Column` 자체는 const 불가, 리스트만 const 가능 |
| `always_declare_return_types` | 아니오 | `:18` 지역 함수 `noReturnType() => 0;` | **최상위에 두면 기반 세트의 `strict_top_level_inference` 가 같은 줄에 함께 걸린다** `[VERIFIED: local run1]`. `as int` 를 붙이면 `unnecessary_cast` warning `[VERIFIED: local run2]` |
| `prefer_final_locals` | 아니오 | `:24` `var value = 1;` | — |
| `prefer_single_quotes` | 아니오 | `:29` `"b"` | — |
| `unawaited_futures` | 아니오 | `:33` async 안의 `Future<void>.delayed(…)` | async 함수 안에서만 걸린다 |
| `sized_box_for_whitespace` | 예 (flutter.yaml) | `base_rules.dart:8` `Container(width: 8, height: 8)` | **`width` 하나만 주면 걸리지 않는다.** width+height / width+child / height+child 는 걸렸다 `[VERIFIED: local run2]` |
| `sort_child_properties_last` | 예 (flutter.yaml) | `:12` `Padding(key: key, child: …, padding: …)` | `key` 로 const 를 막았다 |
| `use_build_context_synchronously` | 예 (flutter.yaml) | `:17` await 뒤 `Navigator.of(context)` | — |
| `avoid_print` | 예 (flutter.yaml) | `:22` `print('d')` | 홑따옴표라 `prefer_single_quotes` 와 겹치지 않는다 |
| `control_flow_in_finally` | 예 (recommended.yaml) | `:30` `finally { return 2; }` | 다른 진단은 없었다 |
| `slash_for_doc_comments` | 예 (recommended.yaml) | `:34` `/** … */` | — |
| (기반 세트만) `prefer_is_empty` | 예 (core.yaml) | `:38` `items.length == 0` | D-01 의 "기반 세트만 켜는 규칙 1건" |

기반 세트 소속은 pub cache 의 `flutter_lints-6.0.0/lib/flutter.yaml`, `lints-6.1.0/lib/recommended.yaml`, `core.yaml` 을 열어 확인했다 `[VERIFIED: local ~/.pub-cache]`. flutter.yaml 의 규칙은 `avoid_print, avoid_unnecessary_containers, avoid_web_libraries_in_flutter, no_logic_in_create_state, prefer_const_constructors_in_immutables, sized_box_for_whitespace, sort_child_properties_last, use_build_context_synchronously, use_full_hex_values_for_flutter_colors, use_key_in_widget_constructors` 이고, D-01 이 "실제로 추가하는 6개" 로 든 목록과 정확히 맞는다.

`riverpod_lint` 는 **3건** 을 권한다 (D-02 의 상한): `missing_provider_scope` (warning, `main.dart:5`), `avoid_public_notifier_properties` (info — 코드 생성 없이 뜨는 유일한 info), `provider_parameters` (warning). 셋 다 `flutter_riverpod` 만으로 뜬다 `[VERIFIED: spike 003, local]`. 2건(처음 둘)만 넣어도 D-02 와 `exit 2` 는 만족한다 — 셋째를 넣는 이유는 Phase 3 PRESET-07 이 plugin 진단 하나를 끈 뒤에도 warning 과 info 가 **둘 다** 남아 강도별 동작을 계속 볼 수 있어서다. 줄이려면 `riverpod_rules.dart` 의 아래 블록을 지우면 되고 다른 파일의 줄 번호는 바뀌지 않는다.

정답지 파일의 머리 주석: 비교 함수가 `#` 줄과 빈 줄을 건너뛰도록 하고 (spike 006 `Expected.read` 가 그 형태), 첫 줄에 `# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, YYYY-MM-DD` 를 적는다. `--update` 는 이 주석을 보존하고 날짜를 갱신한다.

### 권고 3 — "지워 보기" 의 실측 결과와 기록 자리

이 세션에서 복사본의 배포 파일 / `example/` 옵션 파일에 아래 변경을 실제로 만들고 되돌렸다 (`mutate.sh`, 각 실행 3.5~3.8초, stderr 0줄). 모두 정답지와 달라졌다 `[VERIFIED: local M1~M5, M2', M3']`.

| 변경 | 정답지와의 diff | VERIFY-08 / D-03 의 어느 항목 |
|---|---|---|
| `lib/analysis_options.yaml` 에서 `- prefer_final_locals` 삭제 | `< lib/added_rules.dart:24  info  prefer_final_locals` (빠짐), exit 2 유지 | VERIFY-08 "규칙 하나를 지운 변경" |
| `example/analysis_options.yaml` 을 비움 (include 줄 삭제) | lint 16줄 전부 빠짐 + `> lib/should_not_appear.dart:5  warning  invalid_annotation_target` 나타남. **exit 2 그대로**, 0.8초 (plugin 준비 없음) | VERIFY-08 "include 줄을 지운 변경". 종료 코드만으로는 못 잡는다 |
| `analyzer.errors` 블록(`errors:` + `invalid_annotation_target: ignore`) 삭제 | `> lib/should_not_appear.dart:5  warning  invalid_annotation_target` | D-03 annotation 샘플 |
| `invalid_annotation_target: ignore` **한 줄만** 삭제 (`errors:` 를 빈 채로 남김) | 위 줄 + `> analysis_options.yaml:1  warning  included_file_warning` (빈 `errors:` 맵이 included 파일 경고를 낸다) | 기록할 때는 **블록째** 지운다. 한 줄만 지우면 diff 에 경고가 하나 더 섞인다 |
| `- '**/*.g.dart'` 삭제 | `> lib/generated/sample.g.dart:4  info  avoid_print`, `> … prefer_single_quotes` | D-03 생성 파일 샘플 |
| `- '**/*.freezed.dart'` 삭제 | `> lib/generated/sample.freezed.dart:4  info  avoid_print`, `> … prefer_single_quotes` | D-03 생성 파일 샘플 |
| `- unnecessary_await_in_return` 추가 (deprecated) | **정답지와 같음** (include 경유라 보고되지 않음). 같은 상태의 규칙 검사(권고 5)는 `build/woody_rule_check/analysis_options.yaml:41  warning  deprecated_lint`, exit 2 | VERIFY-02 — 정답지 비교가 못 잡고 규칙 검사가 잡는다는 분담의 증거 |

**기록 자리 권고: `example/README.md` 의 한 절** ("검증이 실제로 잡아내는지 확인한 기록"). 이유: VERIFY-08 은 패키지의 요구사항이라 `.planning/` 이 아닌 저장소 본문에 남는 편이 맞고, fixture 옆에 두면 정답지·샘플과 함께 읽힌다. 형식은 위 표 + 실측 조건(SDK / plugin 버전 / 날짜) + "실행한 명령은 `fvm dart run tool/verify.dart`, 변경은 커밋하지 않고 되돌렸다". 같은 내용을 해당 plan 의 SUMMARY 에도 요약한다. 실행 단계에서는 실제 저장소에서 다시 만들어 기록한다 (이 세션의 표는 복사본 실측이라 "기대 diff" 로 쓴다) — 변경 하나당 4초다.

### 권고 4 — D-03 샘플의 재료

- **`invalid_annotation_target`:** `package:flutter/foundation.dart` 가 재수출하는 `meta` 의 `@immutable` 을 **함수**에 붙인다. `Immutable` 클래스는 `@Target({TargetKind.classType, TargetKind.extensionType, TargetKind.mixinType})` 이라 함수에 붙이면 이 진단이 난다 `[VERIFIED: local ~/.pub-cache/hosted/pub.dev/meta-1.19.0/lib/meta.dart:645-649, flutter/lib/foundation.dart:12]`. 추가 패키지(freezed, json_annotation)가 필요 없고 `depend_on_referenced_packages` 도 걸리지 않는다 (flutter 를 통해 온다). 억제되지 않으면 **warning** 이라 exit 에도 영향을 준다 (M4 에서 확인).
- **생성 파일:** `lib/generated/sample.g.dart`, `sample.freezed.dart` 에 `print("g")` 한 줄 (avoid_print + prefer_single_quotes 두 규칙). `part of` 없는 보통 라이브러리 파일이어도 exclude 가 걸린다 `[VERIFIED: local]`.

### 권고 5 — 규칙 검사 (VERIFY-02) 의 구현

1. `lib/analysis_options.yaml` 을 읽어 `stripPlugins` (§ Code Examples 3) 로 최상위 `plugins:` 섹션을 뺀다. 못 찾으면 실패 (plugins 를 담은 채 폴더 인자로 주면 plugin 을 준비한다 — 11초 + 네트워크).
2. `build/woody_rule_check/analysis_options.yaml` 로 쓴다 (점으로 시작하지 않는 폴더, 저장소 **안**).
3. 저장소 루트를 `workingDirectory` 로 `dart --suppress-analytics analyze --format=json build/woody_rule_check`. 0.5초, plugin 준비 없음, `example/` 상태와 무관 `[VERIFIED: spike 007]`.
4. `code` 가 `deprecated_lint` / `removed_lint` / `undefined_lint` 인 진단이 하나라도 있으면 실패. 줄 번호는 그 규칙을 적은 줄이다 (`plugins:` 가 규칙 목록 **뒤**에 있는 동안 원본과 같다).
5. `finally` 로 `build/woody_rule_check` 를 지운다. `.gitignore` 에 `build/` 를 더한다.

**선행 조건 (이 세션의 새 발견):** 루트에 `.dart_tool/package_config.json` 이 없으면 — CI 가 저장소를 막 받은 상태 — 복사본의 `include: package:flutter_lints/flutter.yaml` 이 풀리지 않아 `build/woody_rule_check/analysis_options.yaml:13  warning  include_file_not_found` 만 나오고 deprecated 는 보이지 않는다. 루트에서 `dart pub get` 을 한 뒤에는 `…:41  warning  deprecated_lint` 가 정확히 나왔다 `[VERIFIED: local M5b → M5c]`. 따라서 스크립트의 준비 단계에서 **루트 `dart pub get`** 을 먼저 돌린다 (워크플로 step 으로 빼지 말고 스크립트 안에 두어 로컬과 같게). 이 실행에서 전용 상태 폴더의 plugin 폴더 수는 1 그대로였다 (규칙 검사는 plugin 을 준비하지 않는다) `[VERIFIED: local M5c]`.

깨끗한 지금의 배포 파일은 0건, exit 0 `[VERIFIED: local M5d, spike 005/007]`. 민감도는 루트 `pubspec.yaml` 의 SDK 하한(`^3.13.0`)을 따른다 — 3.14 에서 deprecated 될 규칙은 하한을 올리는 릴리스 전까지 잡히지 않는다 `[VERIFIED: spike 005]`.

### 권고 6 — plugin 준비 실패의 감지

Pattern 2 그대로. 덧붙여 D-07 의 plugin 버전 줄: 분석이 **끝난 뒤** 전용 상태 폴더의 `.plugin_manager` 아래 폴더를 센다. 1개면 그 `pubspec.lock` 에서 읽고, 0개 / 2개 이상 / lock 없음이면 `?` 로 찍고 이유를 한 줄 적는다 (0개 = `ANALYZER_STATE_LOCATION_OVERRIDE` 가 듣지 않음, 2개 이상 = 저장소 경로가 바뀐 적 있음 → 상태 폴더 삭제 안내) `[VERIFIED: spike 008]`. plugin 실패를 알린 실행에서 읽힌 버전은 앞선 실행의 값일 수 있으므로, 머리말이 있으면 버전 줄에 `(이번 실행에서는 plugin 이 뜨지 않았다)` 를 덧붙인다.

### 권고 7 — 루트 `analysis_options.yaml` 에 `example/**` 를 더한다

`example/` 을 만드는 **같은 변경**에서 더한다. 없으면 루트 분석이 `pub get` 전 exit 3 (error 6건) / 후 exit 2 + plugin 준비 15초 `[VERIFIED: spike 007]`. 이 세션의 복사본에서도 제외 없이 example 의 16줄이 루트 분석에 섞이고 15.4초가 걸렸으며, 제외를 더하면 0건 0.6초였다 `[VERIFIED: local M6c, M6b]`. 이 제외는 `example/` 안에서의 분석에 영향이 없다 (상위 옵션 파일은 읽히지 않는다). 기존 `lib/analysis_options.yaml` 줄은 그대로 둔다 (Phase 3 PRESET-06 의 일).

### 권고 8 — `example/` 의 `pub get` 은 `dart pub get --enforce-lockfile`

- `dart pub get` 은 Flutter 프로젝트에서 그대로 되고 옵션 파일을 건드리지 않는다 `[VERIFIED: spike 004]`. 스크립트는 `Platform.resolvedExecutable` 로 같은 SDK 의 `dart` 를 부른다.
- `--enforce-lockfile`: lock 을 커밋하므로(D-05) 로컬과 CI 가 같은 버전으로 판정한다. 어긋나면 exit 65 + "Unable to satisfy `pubspec.yaml` using `pubspec.lock`." `[VERIFIED: spike 004]`; 맞으면 exit 0 `[VERIFIED: local]`. 스크립트는 65 를 "`example/pubspec.yaml` 을 바꿨으면 `cd example && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요" 로 안내한다.
- `.gitignore` 는 `pubspec.lock` 아래에 `!example/pubspec.lock` 을 더한다. 지금은 `.gitignore:7:pubspec.lock` 이 `example/pubspec.lock` 을 잡고, 부정 패턴을 더한 뒤에는 `example/pubspec.lock` 만 풀리고 루트 `pubspec.lock` 은 그대로 무시된다 `[VERIFIED: local git check-ignore, 스크래치 git 저장소]`.
- 단계 3 (`example/analysis_options.yaml` 이 include 한 줄인가) 이 `flutter pub get` 을 잘못 돌린 흔적(`analyzer: exclude: - build/**` 세 줄)을 잡는다. 검사는 "주석·빈 줄을 뺀 나머지가 `include: package:woody_lints/analysis_options.yaml` 한 줄" 로 한다.

### 권고 9 — CI workflow (`.github/workflows/verify.yml`)

```yaml
# 검증 명령(tool/verify.dart)을 GitHub 의 Linux runner 에서 돌린다. 판정 로직은 스크립트에 있다.
name: verify

on:
  push:            # 필터 없음 = 모든 브랜치 (D-10). tag 트리거는 Phase 6 (REL-03)
  pull_request:
  workflow_dispatch:   # 수동 실행 버튼 — workflow 파일이 main 에 들어간 뒤에 보인다 (D-06)

# 저장소를 읽기만 한다.
permissions:
  contents: read

# 같은 브랜치에 새로 올리면 앞선 실행은 취소한다.
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  verify:
    runs-on: ubuntu-latest
    timeout-minutes: 10        # 정상 약 2분 (spike 006). 멈춰 있는 경우만 막는다
    steps:
      - uses: actions/checkout@v7
      # .fvmrc 를 읽어 로컬과 같은 Flutter 를 설치한다. Flutter 버전 숫자를 여기 적지 않는다.
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc
      - name: 검증
        run: dart run tool/verify.dart
```

근거:
- `on.push` 에 `branches` / `tags` 필터가 없으면 브랜치와 tag 의 push 모두에서 돈다 `[CITED: https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax — "If you define neither tags/tags-ignore or branches/branches-ignore, the workflow will run for events affecting either branches or tags."]`. D-10 의 "모든 브랜치" 와 맞는다. tag push 에서도 돌게 되지만 Phase 6 전에는 tag 를 올리지 않는다.
- `workflow_dispatch` 는 "This trigger only receives events when the workflow file is on the default branch." `[CITED: 같은 문서]`, "To trigger the workflow_dispatch event, your workflow must be in the default branch." `[CITED: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow]` — D-06 의 전제 그대로.
- `concurrency` 예시는 문서의 `${{ github.workflow }}-${{ github.ref }}` + `cancel-in-progress: true` 형태 `[CITED: workflow-syntax]`.
- `timeout-minutes` 의 기본값은 **360** `[CITED: workflow-syntax — "The maximum number of minutes to let a job run before GitHub automatically cancels it. Default: 360"]`. 10 은 spike 006 이 잰 2분의 5배이고, pub 서버에 닿지 못할 때도 plugin 준비는 약 30초 뒤 실패로 끝나므로 `[VERIFIED: spike 002]` 걸리는 것은 "멈춤" 뿐이다.
- `permissions: contents: read` — 지정하지 않은 권한은 전부 `none` 이 된다 `[CITED: workflow-syntax]`.
- `subosito/flutter-action` `action.yaml` (tag v2): `channel` 기본 `stable`, `flutter-version-file` = "The pubspec.yaml or FVM config file with exact Flutter version defined", `cache` = "Cache the Flutter SDK", **기본 `"false"`**, `pub-cache` 기본 `""` `[VERIFIED: local gh api repos/subosito/flutter-action/contents/action.yaml?ref=v2]`. README 는 `.fvmrc` 를 지원 파일로 적는다 `[CITED: https://github.com/subosito/flutter-action/blob/v2/README.md]`. spike 006 이 이 입력으로 Flutter 3.47.5 / Dart 3.13.4 를 받았다.
- **캐시는 켜지 않는다.** `cache: true` 는 Flutter SDK 설치(약 66초)를 줄일 수 있지만 재지 않았고, pub cache 는 `cache` 값으로 fallback 한다 `[CITED: README]`. 측정된 구성(캐시 없음, 60/60 통과, job 약 2분, 첫 분석 43초)을 그대로 쓰고, 시간이 문제가 될 때 SDK 캐시만 검토한다. `~/.dartServer` 와 전용 상태 폴더는 어떤 경우에도 캐시하지 않는다.
- 스크립트 안에서 `dart pub get` 2회(루트, `example/`)를 돌리므로 workflow 에 step 을 더 두지 않는다. runner 에서 `dart` 는 `CI=true` / `GITHUB_ACTIONS=true` 를 보고 사용 통계를 스스로 끄지만 `[VERIFIED: spike 006]` 스크립트는 늘 `--suppress-analytics` 를 붙인다.
- action 을 SHA 로 고정할지: 선택이다. 오늘의 `v7` → `3d3c42e5aac5ba805825da76410c181273ba90b1`, `v2` → `1a449444c387b1966244ae4d4f8c696479add0b2` `[VERIFIED: local gh api git/ref/tags]`. major tag 가 spike 와 조사 문서의 선택이므로 그대로 두되, 고정하려면 이 값을 쓴다.
- 결과 확인: `gh run list --workflow verify.yml --limit 5`, `gh run view <id> --log`. `GITHUB_STEP_SUMMARY` 에 Markdown 표를 덧붙이는 조각은 spike 006 에 있다 (선택).

### 권고 10 — `tool/verify.dart` 의 모양

**단계 4개, 모두 돌린 뒤 요약** (D-13 미리보기의 `점검 실패 (3개 중 1개)` 가 "전부 돌린다" 를 함의한다. 미리보기의 3단계에 단계 3 을 더한 것이고 구성은 같다):

| 단계 | 하는 일 | 실패 조건 | 시간 |
|---|---|---|---|
| 준비 (번호 없음) | D-12 SDK 확인 → `--update` 의 CI 거부 → 루트 `dart pub get` → `example/` `dart pub get --enforce-lockfile` | SDK 불일치 / CI 에서 `--update` / `pub get` 실패 → **검증을 시작하지 않고** 안내 후 종료 | 1~3초 |
| [1/4] `lib/` 에 `.dart` 파일 없음 | `Directory('lib').listSync(recursive: true)` 에서 `.dart` 로 끝나는 파일 | 하나라도 있음 (경로를 보여 준다) | 즉시 |
| [2/4] 배포 파일의 규칙 이름 | 권고 5 | `deprecated_lint` / `removed_lint` / `undefined_lint` 1건 이상 | 0.5초 |
| [3/4] `example/` 옵션 파일 | include 한 줄인가 | 다른 줄이 있음 (`flutter pub get` 흔적 / include 삭제) | 즉시 |
| [4/4] `example/` 정답지 비교 | Pattern 1·2·4. `--update` 면 diff 를 보여 주고 덮어쓴다 | plugin 머리말 / 도구 사망 / 빠진 줄·남는 줄·exit 불일치 | 처음 15초, 재실행 3.6초 (로컬) / 43초, 8초 (runner) |

**종료 코드 규약** (spike CONVENTIONS 의 sysexits 관례를 잇는다):

| exit | 뜻 |
|---|---|
| 0 | 단계 4개 모두 통과 |
| 1 | 단계 중 하나라도 실패 (plugin 준비 실패, 도구 사망 포함 — CI 입장에서는 모두 "실패") |
| 64 | 사용법 오류 (모르는 플래그, CI 에서 `--update`) |
| 69 | 하위 명령 실패 (`pub get` 이 65 등으로 실패) |
| 78 | 설정 불일치 (실행 중인 SDK 가 `.fvmrc` 와 다름 — EX_CONFIG) |

**D-12 의 구현:** `Platform.resolvedExecutable` 은 `fvm dart run …` 에서 `/Users/woody/fvm/versions/3.47.5/bin/cache/dart-sdk/bin/dart` 로 풀린다 (심볼릭 링크 해제됨). 거기서 `parent` 를 5번 올라가면 Flutter 루트이고 `bin/cache/flutter.version.json` 의 `frameworkVersion` = `3.47.5`, `dartSdkVersion` = `3.13.4` 다 `[VERIFIED: local sdkprobe/probe.dart]`. 이 값을 `.fvmrc` 의 `flutter` 와 비교한다. 파일이 없으면 "Flutter SDK 의 dart 가 아니다" 로 알리고 `fvm dart run tool/verify.dart` 를 안내한다. runner 의 `flutter-action` 설치본도 같은 배치다 `[ASSUMED — A1]`. `.fvmrc` 는 JSON 한 줄 `{"flutter": "3.47.5"}` 라 `jsonDecode` 로 읽는다.

**D-07 의 세 줄:** SDK 는 위 JSON (Dart 는 `Platform.version` 의 첫 토큰으로도 된다), 기반 세트는 `example/pubspec.lock` 의 `  flutter_lints:` / `  lints:` 블록의 `version: "…"` (`readPluginVersion` 과 같은 파서, 형식 확인 `[VERIFIED: local replica/example/pubspec.lock]`), plugin 은 권고 6.

**`--update` (D-14):** CI 거부는 `Platform.environment['CI'] == 'true' || Platform.environment['GITHUB_ACTIONS'] == 'true'` (runner 의 실제 값 `[VERIFIED: spike 006]`, 로컬은 둘 다 null `[VERIFIED: local]`). 갱신 전에 빠진 줄 / 남는 줄 / exit 변화를 그대로 보여 주고, 정답지 머리 주석은 보존하며 날짜만 바꾼다. 갱신 뒤 종료 코드는 0 (갱신이 곧 의도).

**루트 분석에서 스크립트가 받는 규칙:** 지금의 루트 옵션 파일에는 `include:` 가 없어 lint 규칙이 **하나도** 적용되지 않는다 (analyzer 의 error / warning 만). 권고: 루트에 `include: package:flutter_lints/flutter.yaml` 을 더한다. 복사본에서 돌려 보면 `example/**` 제외와 함께 0.6초에 끝나고, 스텁 스크립트의 `print` 가 `tool/verify.dart:6  info  avoid_print` 로 잡혔다 `[VERIFIED: local M6]` → 스크립트는 `stdout.writeln` / `stderr.writeln` 을 쓴다. `prefer_single_quotes`, `prefer_final_locals` 같은 이 패키지의 추가 규칙은 flutter.yaml 에 없어 스크립트에 강제되지 않는다 — Phase 3 에서 `base.yaml` 이 생기면 루트가 `package:woody_lints/base.yaml` 을 include 하는 것이 진짜 dogfooding 이고 그때 바꾼다. `lib/analysis_options.yaml` 을 include 하면 `plugins:` 가 루트로 들어와 커밋 전 린터가 매번 plugin 을 준비하므로 하지 않는다. include 를 더하지 않는 안(M6b, 0건)도 동작하지만 스크립트가 어떤 규칙도 받지 않는다.

**화면:** D-13 미리보기 그대로. 단계 번호는 `[n/4]`. 실패 시 "다음에 할 일" 은 단계별로 다르다 — 단계 1: 파일 경로와 "`lib/` 에는 YAML 만 둔다"; 단계 2: 규칙 이름과 줄, "`lib/analysis_options.yaml` 에서 지우거나 바꾼다"; 단계 3: "`example/analysis_options.yaml` 을 include 한 줄로 되돌린다 (`flutter pub get` 을 돌렸다면 `git checkout -- example/analysis_options.yaml`)"; 단계 4: plugin 실패면 네트워크·상태 폴더 삭제 안내, 아니면 `fvm dart run tool/verify.dart --update`.

### 권고 11 — `CHANGELOG.md` 2.0.0 항목에 한 줄 적는다

`### 그 밖의 변경` 칸(해당할 때만 두는 칸 `[VERIFIED: local VERSIONING.md:87]`)을 만들고 "저장소 안에 검증용 `example/` 프로젝트, 검증 명령 `tool/verify.dart`, GitHub Actions workflow 를 추가. 사용하는 프로젝트에는 영향 없음" 한 줄. 이유: 1.3.0 항목이 루트 옵션 파일 추가를 같은 문구로 적은 선례가 있고 `[VERIFIED: local CHANGELOG.md:19]`, 기준표의 "저장소 안쪽만 바뀜 = 올리지 않음" 과 어긋나지 않는다 (등급이 아니라 기록). 적지 않아도 틀리지 않으므로 계획이 가볍게 정한다.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| plugin 폴더 이름(md5) 계산 | `dart:io` 만으로 md5 구현 (약 50줄) | 전용 상태 폴더 → 폴더가 하나 | 링크를 푼 경로의 UTF-16 code unit 하위 8비트를 해시해야 하고, 영문·숫자 경로에서는 틀려도 드러나지 않는다 `[VERIFIED: spike 008]` |
| Flutter 버전 판별 | `flutter --version` 파싱 (느리고 출력 형식이 바뀐다) | `bin/cache/flutter.version.json` | 구조화된 JSON, 즉시 읽힌다 `[VERIFIED: local]` |
| YAML 파서 | `plugins:` 를 빼려고 YAML 파싱 | 정규식 `^plugins:\n(?:[ \t]+.*\n)+` (spike 007) | 지금 파일 모양에 맞고 못 찾으면 실패한다. 패키지 의존성 금지(D-11) |
| 진단 메시지 비교 | 메시지 문구까지 정답지에 | `상대경로:줄  강도  규칙이름` (D-04) | SDK 를 올릴 때 문구만 바뀌어 깨지는 것을 막는다 |
| 기대 진단 표식 | `// expect_lint` / `// ignore` + `unnecessary_ignore` | 정답지 비교 | 앞은 `custom_lint` 전용, 뒤는 plugin 진단에 동작하지 않는다 (ARCHITECTURE E, STACK 검증 기법) |
| CI 에서 Flutter 설치 | 직접 `git clone flutter` / 버전 숫자 하드코딩 | `subosito/flutter-action` + `flutter-version-file: .fvmrc` | 단일 원천 유지 (Pitfall 15) |

**Key insight:** 이 하네스의 어려움은 코드가 아니라 analyzer 와 plugin manager 의 **문서화되지 않은 동작**이다. 그 동작은 spike 가 전부 쟀으므로, 구현은 spike 스크립트의 조각(`normalizeDiagnostics`, `Expected.read`, `runAnalyze`, `runPubGet`, `pluginFolders`, `readPluginVersion`, `Outcome.hasPluginHeader`, `stripPlugins`)을 옮기는 일이다.

## Runtime State Inventory

해당 없음 — rename / refactor / migration phase 가 아니다 (새 파일을 더하는 greenfield 작업이고 기존 파일 변경은 루트 옵션 파일·`.gitignore`·CHANGELOG 의 줄 추가뿐). 런타임 상태로 볼 것은 `~/.dartServer/.plugin_manager` 인데 전용 상태 폴더를 쓰므로 건드리지 않는다. 이 세션의 첫 실행 1회(run1)가 환경변수를 빼먹어 기본 자리에 폴더 하나를 더 만들었다 — 복사본 경로의 해시라 저장소와 무관하고 해롭지 않다 `[VERIFIED: local]`.

## Common Pitfalls

### Pitfall 1: 종료 코드로 판정하면 include 삭제를 놓친다
**What goes wrong:** `example/` 의 include 줄을 지우면 lint 16줄이 사라지지만 `invalid_annotation_target` warning 이 되살아나 exit 는 2 그대로다 `[VERIFIED: local M4]`.
**How to avoid:** 정답지 줄 비교가 주 수단 (확정 결정). `exit` 줄은 보조.

### Pitfall 2: 규칙 검사가 "반만" 돈다
**What goes wrong:** (a) 복사본을 저장소 밖에 두면 `undefined_lint` 만 `[VERIFIED: spike 005]`; (b) 루트 `pub get` 전에는 `include_file_not_found` 만 `[VERIFIED: local M5b]`. 둘 다 "경고가 나왔으니 검사가 된다" 처럼 보인다.
**How to avoid:** 저장소 안 `build/`, 루트 `dart pub get` 선행. 스크립트가 `include_file_not_found` 를 보면 "deprecated 검사를 못 했다" 로 따로 알린다.

### Pitfall 3: 샘플 한 줄에 규칙 둘이 걸린다
**What goes wrong:** 최상위 `noReturnType() => 0;` 은 `always_declare_return_types` + `strict_top_level_inference`; `print("x")` 는 `avoid_print` + `prefer_single_quotes`; const 가능한 생성자를 리스트 원소로 두면 `prefer_const_constructors` 가 두 번 `[VERIFIED: local run1/run2]`. D-01 의 "규칙마다 한 건" 이 흐려진다.
**How to avoid:** § 권고 2 의 샘플을 그대로 쓴다. 바꿀 때는 정답지에 같은 규칙이 두 줄 생기는지 본다.

### Pitfall 4: `sized_box_for_whitespace` 가 `width` 하나로는 안 걸린다
`Container(width: 8)` 은 0건, `Container(width: 8, height: 8)` 은 1건 `[VERIFIED: local run1/run2]`.

### Pitfall 5: "지워 보기" 에서 한 줄만 지우면 diff 에 경고가 더 섞인다
`invalid_annotation_target: ignore` 만 지우고 `errors:` 를 남기면 `analysis_options.yaml:1  warning  included_file_warning` 이 추가로 나온다 `[VERIFIED: local M2 vs M2']`. 기록할 때는 블록째 지운다.

### Pitfall 6: 루트 분석에 `example/` 이 섞인다
제외 없이 `example/` 을 만들면 커밋 전 린터가 exit 3 / 2 가 되고 15초 + 네트워크가 든다 `[VERIFIED: spike 007, local M6c]`. `example/**` 한 줄을 같은 커밋에 넣는다.

### Pitfall 7: plugin 이 죽어도 조용하다
exit 0 / 2, stdout 은 멀쩡한 JSON. 머리말은 첫 줄이 아닐 수 있다 `[VERIFIED: spike 002, 008]`. `contains` + 정답지 warning 줄 + `exit 2` 세 겹으로 잡는다.

### Pitfall 8: 상태 폴더 하나에 fixture 둘
plugin 폴더가 2개가 되어 버전 읽기가 `?` 가 된다; 빈 폴더에 동시 실행 둘이면 드물게 깨진다 `[VERIFIED: spike 008]`. fixture 별 상태 폴더, 순차 실행.

### Pitfall 9: `flutter pub get` 을 습관적으로 돌린다
`example/analysis_options.yaml` 이 세 줄 늘어나 작업 트리가 더러워진다 `[VERIFIED: spike 004]`. 단계 3 이 잡고 `git checkout -- example/analysis_options.yaml` 을 안내한다.

### Pitfall 10: `path: ..` 는 작업 트리를 검증한다
커밋하지 않은 `lib/` 변경도 통과한다. CI 는 checkout 된 커밋으로 돌아 이를 보완한다 (PITFALLS.md 13). "tag 가 가리키는 커밋" 의 검증은 Phase 6 REL-04.

### Pitfall 11: 네트워크 없이 통과하지 못한다
plugin 이 컴파일돼 있어도 Analysis Server 가 매번 `dart pub upgrade` 를 돌린다. pub 서버에 닿지 못하면 26~31초 뒤 plugin 진단 없이 끝나고 머리말이 찍힌다 `[VERIFIED: spike 002]`. 오프라인에서는 단계 4 가 "plugin 준비 실패" 로 나오는 것이 정상이며 스크립트가 그렇게 안내한다.

## Code Examples

### 1. 정규화 (spike 006/008 의 함수, 그대로 옮긴다)

```dart
// Source: .planning/spikes/006-github-runner-cold-plugin/ci_probe.dart, 008 의 state_probe.dart
/// stdout 의 JSON 을 정답지 형식 줄 목록으로 바꾼다. 읽지 못하면 null.
List<String>? normalizeDiagnostics(String stdoutText, String fixtureDir) {
  final jsonLine = stdoutText
      .split('\n')
      .lastWhere((l) => l.trimLeft().startsWith('{'), orElse: () => '');
  if (jsonLine.isEmpty) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(jsonLine);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic> || decoded['diagnostics'] is! List) return null;
  final prefix = '$fixtureDir/';   // 절대 경로. 링크를 거치면 resolveSymbolicLinksSync() 접두사도 받는다
  final lines = <String>[];
  for (final d in decoded['diagnostics'] as List) {
    final location = (d as Map<String, dynamic>)['location'] as Map<String, dynamic>;
    final file = location['file'] as String;
    final line = ((location['range'] as Map)['start'] as Map)['line'];
    final relative = file.startsWith(prefix) ? file.substring(prefix.length) : file;
    lines.add('$relative:$line  ${(d['severity'] as String).toLowerCase()}  ${d['code']}');
  }
  return lines..sort();
}
```

### 2. `example/` 분석 실행 (spike 008)

```dart
// Source: .planning/spikes/008-state-folder-placement/state_probe.dart
final result = await Process.run(
  Platform.resolvedExecutable,
  ['--suppress-analytics', 'analyze', '--format=json'],
  workingDirectory: fixtureDir,                       // example/ 의 절대 경로, 경로 인자 없음
  environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir},   // fixture 별 전용 폴더 (미리 만들어 둔다)
);
final pluginFailed = (result.stderr as String)
    .contains('An error occurred while executing an analyzer plugin:');
```

### 3. `plugins:` 제거와 규칙 검사 (spike 007)

```dart
// Source: .planning/spikes/007-root-analysis-with-example/probe.dart
/// 옵션 파일 내용에서 최상위 `plugins:` 섹션을 뺀다.
String stripPlugins(String options) {
  final stripped =
      options.replaceAll(RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true), '');
  if (stripped == options) throw const FormatException('plugins: 섹션을 찾지 못했다');
  return stripped;
}
// 저장소 루트에서:  dart --suppress-analytics analyze --format=json build/woody_rule_check
// 실패 코드: deprecated_lint / removed_lint / undefined_lint. include_file_not_found 가 보이면 루트 pub get 누락.
```

### 4. plugin 버전 읽기 (spike 008)

```dart
// Source: .planning/spikes/008-state-folder-placement/state_probe.dart
List<Directory> pluginFolders(String stateDir) {
  final manager = Directory('$stateDir/.plugin_manager');
  if (!manager.existsSync()) return const [];
  return manager.listSync().whereType<Directory>().toList();
}

String? readPluginVersion(Directory pluginFolder) {   // 같은 파서로 example/pubspec.lock 의 flutter_lints / lints 도 읽는다
  final lock = File('${pluginFolder.path}/pubspec.lock');
  if (!lock.existsSync()) return null;
  final lines = lock.readAsLinesSync();
  final start = lines.indexOf('  riverpod_lint:');
  if (start < 0) return null;
  for (final line in lines.skip(start + 1)) {
    if (!line.startsWith('    ')) break;
    final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}
```

### 5. D-12 SDK 확인 (이 세션의 probe, `fvm dart run` 으로 실행해 확인)

```dart
// Source: scratchpad research-p2/sdkprobe/probe.dart — 출력: frameworkVersion = 3.47.5, dartSdkVersion = 3.13.4
/// 실행 중인 dart 가 속한 Flutter SDK 의 버전을 읽는다. Flutter SDK 의 dart 가 아니면 null.
Map<String, dynamic>? readFlutterVersion() {
  var dir = File(Platform.resolvedExecutable).parent;   // <root>/bin/cache/dart-sdk/bin
  for (var i = 0; i < 4; i++) {
    dir = dir.parent;                                   // → <root>
  }
  final file = File('${dir.path}/bin/cache/flutter.version.json');
  if (!file.existsSync()) return null;
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;   // frameworkVersion, dartSdkVersion
}
// .fvmrc: {"flutter": "3.47.5"} → jsonDecode(File('.fvmrc').readAsStringSync())['flutter']
```

### 6. `example/` 샘플 파일 전문 (이 세션에서 실측, 정답지 16줄의 근거)

`example/pubspec.yaml`:
```yaml
name: woody_lints_example
description: woody_lints 검증용 연습 프로젝트 — 일부러 규칙을 어긴 코드로 기대 진단을 고정한다.
publish_to: 'none'
version: 0.0.0

environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.0

dev_dependencies:
  # 저장소 루트의 woody_lints 를 그대로 받는다 (사용 프로젝트의 git 의존성 자리).
  woody_lints:
    path: ..
```

`example/analysis_options.yaml` (이 한 줄이 전부):
```yaml
include: package:woody_lints/analysis_options.yaml
```

`example/lib/added_rules.dart` (줄 번호가 정답지와 맞아야 하므로 빈 줄까지 그대로):
```dart
import 'package:flutter/material.dart';

// woody_lints 가 기반 세트(flutter_lints / lints) 위에 추가하는 규칙 6개를
// 규칙마다 한 건씩 어긴다. 한 줄에서 규칙 하나만 걸리게 둔다.

/// `prefer_const_constructors` — const 로 만들 수 있는 생성자 호출.
Widget constCandidate() => Text('a');

/// 리스트 원소로 쓸 const 위젯 (아래 줄의 생성자 호출을 피하려는 것).
const Widget constChild = SizedBox.shrink();

/// `prefer_const_literals_to_create_immutables` — @immutable 생성자에 넘기는 const 가능한 리스트.
Widget listCandidate(Key key) => Column(key: key, children: [constChild]);

/// `always_declare_return_types` — 반환 타입을 적지 않은 지역 함수.
/// (최상위 함수에 두면 기반 세트의 `strict_top_level_inference` 도 함께 걸린다.)
int callsLocal() {
  noReturnType() => 0;
  return noReturnType();
}

/// `prefer_final_locals` — 다시 대입하지 않는 지역 변수를 `var` 로 선언.
int finalCandidate() {
  var value = 1;
  return value;
}

/// `prefer_single_quotes` — 겹따옴표 문자열.
const String doubleQuoted = "b";

/// `unawaited_futures` — async 함수 안에서 기다리지 않은 Future.
Future<void> notAwaited() async {
  Future<void>.delayed(Duration.zero);
}
```

`example/lib/base_rules.dart`:
```dart
import 'package:flutter/material.dart';

// 배포 파일에 적혀 있지만 기반 세트(flutter_lints / lints)도 켜는 규칙 6개와,
// 기반 세트만 켜는 규칙 1개를 규칙마다 한 건씩 어긴다.

/// `sized_box_for_whitespace` — 여백용 Container (width 와 height 둘 다 준다.
/// width 하나만 주면 이 규칙이 걸리지 않는다).
Widget whitespace() => Container(width: 8, height: 8);

/// `sort_child_properties_last` — child 를 마지막 인자로 두지 않음.
Widget childFirst(Key key) =>
    Padding(key: key, child: const Text('c'), padding: EdgeInsets.zero);

/// `use_build_context_synchronously` — await 뒤의 BuildContext 사용.
Future<void> afterAwait(BuildContext context) async {
  await Future<void>.delayed(Duration.zero);
  Navigator.of(context).pop();
}

/// `avoid_print` — print 호출.
void printing() {
  print('d');
}

/// `control_flow_in_finally` — finally 블록 안의 return.
int inFinally() {
  try {
    return 1;
  } finally {
    return 2;
  }
}

/** `slash_for_doc_comments` — 별표 문서 주석. */
void starDoc() {}

/// `prefer_is_empty` — 기반 세트(lints core)만 켜는 규칙. 배포 파일에는 없다.
bool emptyCheck(List<int> items) => items.length == 0;
```

`example/lib/main.dart`:
```dart
import 'package:flutter/material.dart';

/// `missing_provider_scope` (riverpod_lint, warning) — ProviderScope 없이 runApp 을 부른다.
void main() {
  runApp(const MaterialApp(home: SizedBox()));
}
```

`example/lib/riverpod_rules.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `avoid_public_notifier_properties` (riverpod_lint, info) — Notifier 에 public 필드를 둔다.
class PublicFieldNotifier extends Notifier<int> {
  /// 바깥에서 보이는 필드.
  int publicField = 0;

  @override
  int build() => 0;
}

/// 인자를 받는 provider.
final familyProvider = Provider.family<int, Object?>((ref, value) => 0);

/// `provider_parameters` (riverpod_lint, warning) — `==` 를 재정의하지 않는 non-const 리터럴을 family 인자로 넘긴다.
final consumerProvider = Provider<int>(
  (ref) => ref.watch(familyProvider([42])),
);
```

`example/lib/should_not_appear.dart`:
```dart
import 'package:flutter/foundation.dart';

/// `invalid_annotation_target` — class 전용 annotation(`@immutable`)을 함수에 붙인다.
/// 배포 파일의 `invalid_annotation_target: ignore` 가 억제하므로 정답지에 없어야 한다.
@immutable
void wrongTarget() {}
```

`example/lib/generated/sample.g.dart` (`sample.freezed.dart` 도 같은 꼴, `"f"`):
```dart
// 생성 코드를 흉내 낸 파일. 배포 파일의 `**/*.g.dart` exclude 로 분석에서 빠지므로
// 아래 위반(avoid_print, prefer_single_quotes)이 정답지에 없어야 한다.
void generatedPrint() {
  print("g");
}
```

### 7. 루트 `analysis_options.yaml` (권고 7 + 10)

```yaml
# 이 저장소 자체를 분석할 때만 쓰는 설정 (사용하는 프로젝트에는 전달되지 않는다 —
# 프로젝트는 lib/analysis_options.yaml 을 include 한다).
#
# tool/ 의 스크립트에 기반 세트 규칙을 적용한다. lib/analysis_options.yaml 을 include 하면
# plugins: 가 루트로 들어와 분석마다 plugin 을 준비하므로 쓰지 않는다.
include: package:flutter_lints/flutter.yaml

# lib/analysis_options.yaml 은 배포용 공유 설정이라 최상위 `plugins:` 를 담는다.
# 이 저장소 안에서는 그 파일이 하위(inner) 옵션 파일로 취급되어
# `plugins_in_inner_options` 경고가 나므로 자체 분석에서만 제외한다.
# example/ 은 일부러 규칙을 어긴 검증용 프로젝트라 루트 분석에서 뺀다 (안에서 따로 분석한다).
analyzer:
  exclude:
    - lib/analysis_options.yaml
    - 'example/**'
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|---|---|---|---|
| `analyzer: plugins:` (legacy plugin) | 최상위 `plugins:` (analysis_server_plugin) | Dart 3.10+, 이 패키지는 1.3.0 | plugin 상태가 `.plugin_manager/<hash>/` 에 가상 패키지로 생기고 매 실행 `dart pub upgrade` |
| `flutter analyze` 로 검증 | `dart analyze` | Flutter 3.47.5 에서 plugin 진단 누락 (2026-09-20 실측) | 스크립트·CI 모두 `dart analyze` |
| `dart analyze --fatal-infos` 종료 코드 판정 (STACK.md 초안) | 정답지 비교 (SUMMARY D5) | 로드맵 확정 | 종료 코드는 정답지의 한 줄 |
| `~/.dartServer` 에서 plugin 버전 읽기 (spike 006) | 전용 상태 폴더 (spike 008) | 2026-10-11 | md5 불필요 |
| 루트에서 인자 없이 규칙 검사 (spike 005) | 복사본 폴더를 인자로 (spike 007) | 2026-10-11 | `example/` 상태와 무관, plugin 준비 없음 |
| `dart analyze <dir>` 의 plugin 누락 (sdk#62710) | Dart 3.14 에 수정 예정 | 2026-10-01 닫힘 | SDK 를 올리면 실행 형태를 다시 잰다 |

**Deprecated/outdated:** `unnecessary_await_in_return` (Dart 3.13.0 부터 deprecated — `rules.json` 은 틀렸다) `[VERIFIED: spike 005]`; `.planning/research/ARCHITECTURE.md` Tier 0 의 "`included_file_warning` 으로 올라온다", "riverpod_lint 는 모두 warning", STACK.md 의 `cache: true` / `flutter pub get` / `--fatal-infos` 초안 workflow — 모두 spike 와 결정으로 대체됐다.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| A1 | GitHub runner 의 `flutter-action` 설치본도 `<root>/bin/cache/flutter.version.json` 과 `bin/cache/dart-sdk/bin/dart` 배치를 갖는다 (같은 Flutter 저장소 clone 이므로) | 권고 10 (D-12) | D-12 확인이 runner 에서 "Flutter SDK 가 아니다" 로 실패한다. 첫 CI 실행에서 바로 드러나며, 그 경우 `FLUTTER_ROOT` 환경변수 fallback 을 더한다 |
| A2 | 전용 상태 폴더를 실제 저장소의 `.dart_tool/woody_verify/example/` 에 두어도 spike 008 의 세 자리와 같은 결과다 | Pattern 4 | 008 이 "프로젝트 밖 / 안의 점 폴더 / 안의 평범한 폴더" 를 재어 모두 같았고 이 세션도 "밖" 에서 같았다. 다르면 폴더 자리만 옮긴다 |
| A3 | `timeout-minutes: 10` 이 규칙 검사·`pub get` 2회를 더한 전체 스크립트에도 넉넉하다 | 권고 9 | spike 006 의 job 2분 + 로컬 0.5초·수 초 단계들. 넘치면 값만 올린다 |
| A4 | 정답지를 실제 저장소 `example/` 에서 만들었을 때 복사본과 같은 16줄이 나온다 (경로만 다르다) | 권고 2 | 샘플을 글자 그대로 쓰면 줄 번호가 같다. 실행 단계의 첫 `--update` 가 기준이 되므로 다르면 그 출력으로 확정한다 |
| A5 | `on.pull_request` 에 필터가 없으면 모든 base 브랜치의 PR 에서 돈다 | 권고 9 | 문서가 직접 말하지 않았다 (필터 예시로만). PR 은 Phase 6 전에는 열지 않는다 (D-10) |

## Open Questions (RESOLVED)

세 항목 모두 계획 단계(2026-10-11, `02-01-PLAN.md` ~ `02-04-PLAN.md`)에서 권고대로 결정되었다. 각 항목의 `RESOLVED:` 줄이 결정과 그 자리다.

1. **`riverpod_lint` 3건 vs 2건**
   - What we know: 셋 다 한 줄씩 뜨고 2건으로도 D-02·`exit 2` 를 만족한다.
   - What's unclear: plugin 새 버전이 `provider_parameters` 의 동작을 바꿀 가능성 (줄이 많을수록 저장소 변경 없이 깨진다는 D-02 의 우려).
   - Recommendation: 3건으로 시작. 깨지면 그 줄을 지우는 것이 곧 "plugin 변경의 기록" 이다.
   - **RESOLVED:** 3건 (`missing_provider_scope` warning, `provider_parameters` warning, `avoid_public_notifier_properties` info) — plan **02-01** Task 2 (`example/lib/main.dart` · `example/lib/riverpod_rules.dart`, 정답지 16줄 중 3줄). 이유: Phase 3 PRESET-07 이 plugin 진단 하나를 끈 뒤에도 warning 과 info 가 둘 다 남는다.
2. **루트 옵션 파일에 `include: package:flutter_lints/flutter.yaml` 을 넣을지**
   - What we know: 넣으면 스크립트의 `print` 가 잡히고 0.6초 (M6). 안 넣으면 규칙 0개 (M6b).
   - What's unclear: 없음 — 취향의 문제. Phase 3 PRESET-06 이 루트 파일을 다시 손본다.
   - Recommendation: 넣는다. 스크립트는 `stdout.writeln` 을 쓴다.
   - **RESOLVED:** 넣는다 — plan **02-01** Task 1 action 2 (루트 `analysis_options.yaml` 을 § Code Examples 7 의 전문으로; 스크립트는 `stdout.writeln` / `stderr.writeln` 만 쓴다). 이유: 넣지 않으면 `tool/verify.dart` 에 lint 규칙이 하나도 적용되지 않는다.
3. **action 을 SHA 로 고정할지**
   - What we know: 오늘의 SHA 두 개를 확보했다. spike 와 조사 문서는 major tag 를 썼다.
   - Recommendation: major tag 유지 (개인 저장소, 읽기 권한만). 계획이 달리 정해도 비용은 없다.
   - **RESOLVED:** major tag 유지 (`actions/checkout@v7`, `subosito/flutter-action@v2`; 구현 시점에 릴리스 페이지에서 major 를 다시 확인한다) — plan **02-04** Task 1 action 1. 오늘의 SHA 는 § Standard Stack 에 남아 있어 나중에 고정으로 바꿀 수 있다.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| FVM | 로컬 `fvm dart …` | ✓ | 4.3.1 | `.fvm/flutter_sdk/bin/dart` 직접 호출 |
| Flutter / Dart (`.fvmrc`) | 모든 검증 | ✓ | 3.47.5 / 3.13.4 (`fvm dart --version`) | — |
| 시스템 `dart` on PATH | — | ✗ | — | 필요 없음 (D-12 가 `fvm dart run` 을 안내) |
| pub.dev 접근 (네트워크) | `pub get`, plugin 준비 | ✓ (이 세션의 `pub get` 과 plugin 준비 성공) | — | 없음 — 오프라인이면 단계 4 가 plugin 실패로 보고된다 |
| `gh` CLI (로그인) | CI 결과 확인 | ✓ | 2.102.0, `woodkill` | GitHub 웹 화면 |
| GitHub Actions (저장소에 켜짐) | VERIFY-04 | ✓ | run 38136362920 성공 | — |
| 원격 브랜치 `gsd/v2.0-package-rework` | CI 실행 (D-08/09) | ✓ 이미 존재 (`1ed61cd`) | — | — |
| `python3`, `jq` | — | 불필요 (D-11) | — | — |

**Missing dependencies with no fallback:** none
**Missing dependencies with fallback:** none

## Validation Architecture

> `workflow.nyquist_validation` 은 `.planning/config.json` 에서 `true` `[VERIFIED: local]`.

### Test Framework

| Property | Value |
|---|---|
| Framework | 없음 (Dart 테스트 패키지를 두지 않는다, D-11). 검증 명령 `tool/verify.dart` 자체가 이 phase 의 테스트 하네스다 |
| Config file | `example/expected_diagnostics.txt` (정답지), `.github/workflows/verify.yml` — 둘 다 Wave 0 |
| Quick run command | `fvm dart run tool/verify.dart` (재실행 약 5초: 단계 1·2·3 즉시, 단계 4 약 3.6초) |
| Full suite command | 같은 명령 (단계 4개 전부). CI: `dart run tool/verify.dart` (약 2분) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| VERIFY-01 | `example/` 의 진단이 정답지와 같다 (추가 규칙 6, 기반 세트 7, plugin 3) | integration (analyzer 실행) | `fvm dart run tool/verify.dart` → `[4/4] … 통과`, exit 0 | ❌ Wave 0 (`example/`, `tool/verify.dart`) |
| VERIFY-02 | deprecated / removed / 없는 규칙이 있으면 실패 | integration | 배포 파일에 `- unnecessary_await_in_return` 을 임시로 넣고 같은 명령 → `[2/4] … 실패`, exit 1 (되돌린다) | ❌ Wave 0 |
| VERIFY-03 | 명령 하나로 전체 검증 | smoke | `fvm dart run tool/verify.dart; echo $?` → 0 | ❌ Wave 0 |
| VERIFY-04 | push / PR 마다 CI, 시간 제한 | e2e (GitHub) | push 후 `gh run list --workflow verify.yml --limit 1` → `completed success`; workflow 파일에 `timeout-minutes: 10` | ❌ Wave 0 (`.github/workflows/verify.yml`) |
| VERIFY-07 | `lib/` 에 `.dart` 가 있으면 실패 | integration | `touch lib/x.dart && fvm dart run tool/verify.dart; rm lib/x.dart` → `[1/4] … 실패`, exit 1 | ❌ Wave 0 |
| VERIFY-08 | 규칙 삭제 / include 삭제가 각각 실패함이 기록됨 | manual-with-record (변경을 만들고 되돌리며 diff 를 기록) | 권고 3 의 표를 실제 저장소에서 재현, `example/README.md` 에 기록 | ❌ Wave 0 (기록 절) |

D-12 (SDK 불일치) / D-14 (CI 에서 `--update` 거부) 는 요구사항 ID 는 없지만 같은 방식으로 확인한다: `CI=true fvm dart run tool/verify.dart --update` → exit 64 와 안내문.

### Sampling Rate
- **Per task commit:** `fvm dart run tool/verify.dart` (약 5초) + 커밋 전 린터 `fvm dart analyze` (0.6초, 루트)
- **Per wave merge:** 같은 명령 + 원격 push 뒤 `gh run list` 로 CI 초록 확인
- **Phase gate:** 로컬 exit 0, GitHub 에서 성공한 run 1회 이상, `example/README.md` 의 VERIFY-08 기록, `/gsd-verify-work` 전에 "지워 보기" 6건이 모두 실패로 재현됨

### Wave 0 Gaps
- [ ] `example/` 전체 (pubspec, lock, 옵션 파일, 샘플 7파일, 정답지) — VERIFY-01/08
- [ ] `tool/verify.dart` — VERIFY-01/02/03/07, D-07/12/13/14
- [ ] `.github/workflows/verify.yml` — VERIFY-04
- [ ] 루트 `analysis_options.yaml` 의 `example/**` 제외 (+ include) — 커밋 전 린터가 깨끗하려면 `example/` 과 같은 커밋
- [ ] `.gitignore` 의 `!example/pubspec.lock`, `build/`
- [ ] `example/README.md` 의 기록 절 — VERIFY-08, D-03
- [ ] Framework install: 없음

## Security Domain

`security_enforcement: true`, ASVS level 1 `[VERIFIED: local .planning/config.json]`. 실행 코드는 로컬 스크립트와 CI workflow 뿐이고 사용자 입력·인증·저장 데이터가 없다.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | no | — (CI 는 `GITHUB_TOKEN` 기본 토큰만, 외부 서비스 인증 없음) |
| V3 Session Management | no | — |
| V4 Access Control | yes (CI 권한) | `permissions: contents: read` — 지정하지 않은 권한은 `none` `[CITED: workflow-syntax]` |
| V5 Input Validation | yes (스크립트 입력) | 입력은 저장소 파일과 `--update` 플래그뿐. 모르는 플래그는 exit 64. `stripPlugins` 가 섹션을 못 찾으면 실패. 외부 문자열을 셸에 넘기지 않는다 (`Process.run` 에 인자 배열) |
| V6 Cryptography | no | md5 를 손으로 구현하지 않는다 (전용 상태 폴더로 회피) |
| V14 Configuration | yes | `.fvmrc` 단일 원천, action 은 알려진 publisher 의 major tag (SHA 고정 선택지 제공), `~/.dartServer` 미캐시, `example/pubspec.lock` 커밋으로 재현성 |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---|---|---|
| 서드파티 action 의 공급망 변조 | Tampering | 공식 / 널리 쓰이는 action 2개만, 읽기 권한, 필요 시 SHA 고정 (`3d3c42e5…`, `1a449444…`) |
| plugin(`riverpod_lint`)이 분석 시점에 pub.dev 에서 받아져 실행됨 | Tampering / Elevation | 이미 1.3.0 이 선언한 plugin. 버전은 D-07 로 화면에 찍고, 정답지 강도 변화로 드러난다. 고정 여부는 Phase 3 D6 |
| `.planning/` 공개로 인한 정보 노출 | Information Disclosure | D-08 로 소유자가 수용. 새 기록 파일에 로컬 절대 경로·토큰을 적지 않는다 |
| `build/woody_rule_check` 가 남아 커밋됨 | Tampering (저장소 오염) | `finally` 삭제 + `.gitignore` `build/` |
| CI 가 멈춰 runner 시간을 소모 | Denial of Service | `timeout-minutes: 10`, `concurrency.cancel-in-progress` |

## Sources

### Primary (HIGH confidence)
- `.planning/spikes/001~008` README·스크립트·results, `.planning/spikes/MANIFEST.md`, `WRAP-UP-SUMMARY.md`, `CONVENTIONS.md`, `.claude/skills/spike-findings-woody-lints/` (SKILL.md + references 4개) — 6가지 질문의 답, 실행 형태, 판정 순서, 규칙 검사, CI
- 이 세션의 스크래치 실측 (`research-p2/replica`, `mutate.sh`, `sdkprobe/probe.dart`) — 정답지 16줄, 지워 보기 7건, 규칙 검사의 fresh checkout 조건, 루트 include, SDK 판별, lock 형식, gitignore 부정 패턴
- `~/.pub-cache/hosted/pub.dev/flutter_lints-6.0.0/lib/flutter.yaml`, `lints-6.1.0/lib/{recommended,core}.yaml` — 기반 세트 소속
- `~/.pub-cache/hosted/pub.dev/meta-1.19.0/lib/meta.dart:645-649`, `flutter/lib/foundation.dart:12` — `@immutable` 의 `@Target`
- `gh api repos/{actions/checkout,subosito/flutter-action}/releases/latest`, `git/ref/tags/{v7,v2}`, `contents/action.yaml?ref=v2` (2026-10-11)
- `git ls-remote --heads origin`, `gh run list` (2026-10-11)
- `.planning/phases/02-verification-harness/02-CONTEXT.md`, `REQUIREMENTS.md`, `ROADMAP.md`, `STATE.md`, `VERSIONING.md`, `CHANGELOG.md`, `lib/analysis_options.yaml`, `analysis_options.yaml`, `.gitignore`, `pubspec.yaml`, `.fvmrc`, `.planning/config.json`

### Secondary (MEDIUM confidence)
- https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax — `timeout-minutes` 기본 360, `concurrency`, `on.push` 무필터, `workflow_dispatch` 기본 브랜치 조건, `permissions`
- https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow — 수동 실행 전제
- https://github.com/subosito/flutter-action/blob/v2/README.md — `flutter-version-file` 의 `.fvmrc`, `pub-cache` 의 fallback
- `.planning/research/{ARCHITECTURE,PITFALLS,STACK,FEATURES,SUMMARY}.md` — 설계 배경 (spike 로 대체된 부분은 § State of the Art 에 적었다)

### Tertiary (LOW confidence)
- 없음

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 버전은 전부 이 머신·registry·GitHub API 에서 오늘 확인
- Architecture: HIGH — 실행 형태·판정 순서·규칙 검사·상태 폴더는 spike 8개, 샘플·정답지·지워 보기는 이 세션의 실측. 전체를 한 스크립트로 묶어 돌린 것은 아직 없다 (각 단계는 따로 실측됨)
- Pitfalls: HIGH — 모두 실측에서 나온 것
- CI: HIGH (spike 006 의 실제 runner 실행) / 캐시·SHA 고정은 미측정이라 쓰지 않음

**Research date:** 2026-10-11
**Valid until:** SDK(Flutter 3.47.5 / Dart 3.13.4) 또는 `riverpod_lint` 3.1.9 가 바뀌기 전까지. action 버전은 구현 시점에 다시 조회 (오늘 기준 v7.0.1 / v2.23.0)
