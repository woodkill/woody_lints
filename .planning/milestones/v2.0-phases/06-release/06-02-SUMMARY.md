---
phase: 06-release
plan: 02
subsystem: docs
tags: [readme, versioning, release-procedure, flutter-create-template]

requires:
  - phase: 06-release
    provides: "06-01 의 `fvm dart run tool/verify.dart --tag vX.Y.Z` 와 stderr 모드 줄 `버전 일치 검사: …` (절차 2 · 6 이 그대로 인용)"
provides:
  - "README 「설치」 · 「프로젝트 전체」 · 「생성 파일 제외」 의 `flutter create` 템플릿 기존 키 합치기 문단 셋과 `plugins:` 블록 측정 문장 (D-14, 05-UAT 1번)"
  - "README 34행 flutter#191151 병합 사실 (05-UAT 4번), 355행 출처 표시 (05-UAT 2번), 381행 릴리스 절차 안내 (D-11)"
  - "VERSIONING.md 새 절 `## 릴리스 절차` — 단계 1 ~ 10 과 소절 「plugin 새 버전 때문에 정답지가 저절로 깨졌을 때」 (D-11 · D-12), 82행 현재형"
affects: [06-03, 06-04, 06-05, 06-06, 06-07]

actuals:
  tokens: 2654
  tasks: 2
  commits: 2
plan_head_before: 0d9e684223ee4d7f2e706f201102541b7ad6fda3
plan_head_after: f95d48237341023541bc75b539b6465a4458340f

tech-stack:
  added: []
  patterns:
    - "README 손질은 펜스 밖 산문만 — 새 펜스 · 다른 패키지의 `.yaml` 주소를 더하지 않아 `[3/10]` (d′) ~ (g) 를 지나간다"
    - "VERSIONING.md 의 번호 붙은 절차 절 — 명령은 백틱 안에 그대로, 원격에 남는 두 작업 앞에 **(직전 확인)**"

key-files:
  created: []
  modified:
    - README.md
    - VERSIONING.md

key-decisions:
  - "절차 5단계의 tag 점검은 06-RESEARCH § 8 대로 넷(cat-file · rev-parse · tag 의 pubspec version · tag 의 CHANGELOG 첫 줄)으로 적었다 — 계획 본문은 셋을 나열하고 넷이라 했다"
  - "절차 6 의 tag 실행 필터(`headBranch` 가 tag 이름)는 A3 가정 그대로 적었다 — 06-05 가 진짜 tag 실행으로 확인한다"

patterns-established:
  - "릴리스 절차의 자리는 VERSIONING.md 「릴리스 절차」 하나 — README 381행과 06-01 의 (i) 안내 줄이 이 절 이름을 가리킨다"

requirements-completed: [REL-02, REL-04]

coverage:
  - id: D1
    description: "README 의 기존 키 합치기 문단 셋 · plugins: 블록 측정 문장 · 34 · 355 · 381행 손질, [3/10] 그대로 통과"
    requirement: "REL-04"
    verification:
      - kind: other
        ref: "06-02-PLAN.md Task 1 의 <automated> (커밋 c9a3225 뒤 base 고정으로 재실행) rc 0"
        status: pass
      - kind: other
        ref: "fvm dart run tool/verify.dart — rc 0, 점검 통과 (10개 중 10개), [3/10] 통과"
        status: pass
    human_judgment: true
    rationale: "글자 · 검사 통과는 자동으로 확인했지만, README 를 사람이 따라 해 막히지 않는지와 측정 문장이 릴리스 커밋에서도 맞는지는 06-04 의 예행 (D-10 · D-14) 이 판정한다"
  - id: D2
    description: "VERSIONING.md 「릴리스 절차」 단계 1 ~ 10 과 plugin 새 버전 대응 소절, 82행 현재형"
    requirement: "REL-02"
    verification:
      - kind: other
        ref: "06-02-PLAN.md Task 2 의 <automated> (커밋 f95d482 뒤 base 고정으로 재실행) rc 0"
        status: pass
    human_judgment: true
    rationale: "절차의 명령이 실제로 맞는지(특히 6단계의 tag 실행 필터, A3)는 06-04 ~ 06-06 이 이 순서를 실제로 밟아야 확인된다"

duration: 9min
completed: 2026-10-15
status: complete
---

# Phase 6 Plan 02: README 손질과 VERSIONING.md 「릴리스 절차」 Summary

**README 에 `flutter create` 템플릿의 기존 `include:` · `analyzer:` · `linter:` 와 합치는 법(세 절)과 `base.yaml` 만 받는 프로젝트에서 `plugins:` 블록이 `riverpod_lint` 를 켠다는 측정 문장을 넣고 34 · 355 · 381행을 사실 · 출처 · 절차 안내로 고쳤으며, `VERSIONING.md` 끝에 2.0.0 에서 밟는 릴리스 순서 1 ~ 10 · lock 은 `fvm dart pub get` 으로만 · plugin 새 버전에 정답지가 깨졌을 때의 대응을 담은 절 「릴리스 절차」 를 더했다**

## Performance

- **Duration:** 9 min
- **Started:** 2026-10-15T05:18:53Z
- **Completed:** 2026-10-15T05:27:30Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- README 세 절(「설치」 · 「프로젝트 전체」 · 「생성 파일 제외」)에 `flutter create` 가 만든 옵션 파일과 합치는 문단 — 셋 모두 `두 번 적으면 YAML 이 받지 않는다` 를 담는다 (D-14, 05-UAT 1번).
- 「프로젝트 전체」 에 측정 문장 — `base.yaml` 만 받는 프로젝트에 `plugins:` 블록을 붙이면 `riverpod_lint` 가 켜진다 (Flutter 3.47.5, 2026-10-15 실측).
- README 34행 (05-UAT 4번) · 355행 (05-UAT 2번) · 381행 (D-11).
- `VERSIONING.md` 「릴리스 절차」 (D-11 · D-12) 와 82행 현재형. 기존 1 ~ 81 · 83 ~ 127행은 글자 그대로 (md5 단언).
- 두 커밋 뒤 `fvm dart run tool/verify.dart` 종료 코드 0, `점검 통과 (10개 중 10개)`, `[3/10] 배포 파일의 구성 ... 통과`, stderr 모드 줄 `버전 일치 검사: 평소 (pubspec.yaml 의 꼬리 뗀 version ↔ CHANGELOG.md 최상단 버전)`.

## Task Commits

1. **Task 1: README 손질** — `c9a3225` `docs(readme): flutter create 템플릿의 기존 키와 합치는 문장 셋과 plugins: 블록 측정 문장 (D-14), 34 · 355행의 사실 · 출처 (05-UAT 4 · 2), 릴리스 절차 안내 (D-11)` (numstat 9 더함 / 3 지움)
2. **Task 2: VERSIONING.md 「릴리스 절차」** — `f95d482` `docs(versioning): 「릴리스 절차」 절 — 2.0.0 에서 밟는 순서 1 ~ 10, lock 은 pub get 으로만, plugin 새 버전에 정답지가 깨졌을 때 (D-11 · D-12); 82행 현재형` (numstat 35 더함 / 1 지움)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 의 metadata 커밋 (`docs(06-02): …`)

## `<automated>` 결과

계획 파일에서 `<verify>` 바로 안의 `<automated>` 글자를 python `-I` 로 뽑아(Task 1 2171 바이트, Task 2 2317 바이트) 각자의 임시 폴더에서 `bash <파일>` 로 저장소 루트에서 돌렸다. 고친 판은 없다.

| Task | 시점 | 적힌 그대로 rc | 고친 판 rc |
|------|------|----------------|------------|
| 1 | 커밋 전 (B=HEAD) | 0 | — |
| 1 | 커밋 `c9a3225` 직후 (B=`c9a3225~1`) | 0 | — |
| 1 | Task 2 커밋 뒤 재실행 | 0 | — |
| 2 | 커밋 전 (B=HEAD) | 0 | — |
| 2 | 커밋 `f95d482` 직후 (B=`f95d482~1`) | 0 | — |

plan `<verification>` 의 "두 task 뒤 `git status --porcelain` 빈 출력" 은, 처음부터 있던 상태 파일(orchestrator 가 고친 `.planning/STATE.md` · `.planning/config.json`, 추적 안 되는 `.planning/milestone.lock` · `.planning/research/.cache/` · `.planning/state.json`)만 남은 모양이다 — 이 plan 이 만든 변경은 없다.

## 고친 자리 여섯 — 전후 글자

**README 34행 (05-UAT 4번)**

- 전: `- `flutter pub get` 은 Flutter 프로젝트의 옵션 파일에 `build/**` 와, 프로젝트에 있는 플랫폼 폴더(`android/**` 등)의 제외 줄을 덧붙인다. Flutter 3.47.5 의 `AnalysisOptionsMigration` 이 하는 일이고, 끄는 옵션은 없으며, 이미 제외되어 있으면 덧붙이지 않는다. 이 패키지의 문제가 아니다. 상류에 이 동작을 고치는 변경이 있다 — [flutter#191151](https://flutter.googlesource.com/mirrors/flutter/+/c7a822e59b5b37c4fa74f0cc71e9d1f4e25ac7ff) (병합 여부는 확인하지 않았다).`
- 후 (지금 36행): `- `flutter pub get` 은 Flutter 프로젝트의 옵션 파일에 `build/**` 와, 프로젝트에 있는 플랫폼 폴더(`android/**` 등)의 제외 줄을 덧붙인다. Flutter 3.47.5 의 `AnalysisOptionsMigration` 이 하는 일이고, 끄는 옵션은 없으며, 이미 제외되어 있으면 덧붙이지 않는다 (`flutter create` 로 만든 빈 프로젝트에서 그랬다 — 2026-10-15 실측). 이 패키지의 문제가 아니다. 상류 변경 [flutter#191151](https://flutter.googlesource.com/mirrors/flutter/+/c7a822e59b5b37c4fa74f0cc71e9d1f4e25ac7ff) 은 2026-08-19 에 병합됐고 stable 판 #191530 이 Flutter 3.47.2 부터 들어 있다 (3.47.5 의 동작이 이미 이것이다) — 바뀐 것은 "있는 플랫폼 폴더만 제외 · Flutter 가 아닌 패키지는 건너뜀" 이고 `build/**` 는 그대로 덧붙인다.`

**README 355행 (05-UAT 2번)**

- 전: `` `plugins:` 를 바꾼 뒤(프리셋을 바꾸거나 위의 끄는 설정을 적은 뒤)에는 IDE 의 Dart Analysis Server 를 재시작해야 반영된다. ``
- 후 (지금 361행): `` `plugins:` 를 바꾼 뒤(프리셋을 바꾸거나 위의 끄는 설정을 적은 뒤)에는 IDE 의 Dart Analysis Server 를 재시작해야 반영된다. (1.3.0 의 배포 파일 주석에서 옮긴 문장이다 — spike 에서 재시작 자체를 재 보지는 않았다) ``

**README 381행 (D-11)**

- 전: `- 버전 등급과 CHANGELOG 항목 형식은 [`VERSIONING.md`](VERSIONING.md) 를 따른다.`
- 후 (지금 387행): `- 버전 등급 · CHANGELOG 항목 형식 · 릴리스 절차는 [`VERSIONING.md`](VERSIONING.md) 를 따른다.`

**「설치」 29행 뒤의 새 문단 (지금 31행, 전문)**

> `flutter create` 가 만든 `analysis_options.yaml` 에는 이미 `include:` 줄(기반 세트 `flutter_lints` 의 주소) · `analyzer: exclude:` (`build/**` 와 만든 플랫폼 폴더) · 빈 `linter: rules:` 가 있다 (Flutter 3.47.5 의 앱 템플릿, 2026-10-15 읽음). 기존 `include:` 줄은 이 패키지의 주소로 **바꾸고**, 이미 있는 `analyzer:` · `linter:` 키에는 아래 절들의 내용을 **합친다** — 같은 최상위 키를 두 번 적으면 YAML 이 받지 않는다.

**「프로젝트 전체」 222행 뒤의 새 문단 (지금 226행, 전문)**

> `flutter create` 가 만든 옵션 파일에는 빈 `linter: rules:` 가 이미 있다 — 그 아래에 `이름: false` 를 넣는 꼴이 된다 (같은 `linter:` 키를 두 번 적으면 YAML 이 받지 않는다). `plugins:` 블록은 그 프로젝트의 plugin 선언 자체다 — `riverpod.yaml` 을 받지 않는 프로젝트(`base.yaml` 만)에 이 블록을 붙이면 `riverpod_lint` 가 켜진다 (Flutter 3.47.5, 2026-10-15 실측 — 작업 브랜치의 커밋을 GitHub 에서 받은 `flutter create` 빈 프로젝트에서 `provider_parameters` 가 나왔고 `missing_provider_scope` 는 꺼졌다).

**「생성 파일 제외」 284행 뒤의 새 문단 (지금 290행, 전문)**

> `flutter create` 가 만든 옵션 파일에는 이미 `analyzer: exclude:` 가 있다 (`build/**` 와 만든 플랫폼 폴더). 그 목록에 아래 두 줄을 더한다 — 같은 `analyzer:` 키를 두 번 적으면 YAML 이 받지 않는다.

**VERSIONING.md 82행**

- 전: `  - 제목의 ` - ` (앞뒤에 공백이 하나씩 있는 붙임표)는 **한 번만** 쓴다. Phase 6 에서 만드는 일치 검사(REL-03 — …)가 ` - ` 앞 토큰을 버전으로 읽는다.`
- 후: `  - 제목의 ` - ` (앞뒤에 공백이 하나씩 있는 붙임표)는 **한 번만** 쓴다. 검증 명령 `[3/10]` 의 일치 검사(REL-03 — …)가 ` - ` 앞 토큰을 버전으로 읽는다.`

## 새 절의 단계 제목 열 개

1. 등급을 정한다 (`X.Y.Z-dev` · `## X.Y.Z - 미출시` 의 준비 상태)
2. 릴리스 커밋을 만든다 (`-dev` 떼기 · 날짜 · 루트 `fvm dart pub get` · lock 여섯은 `fvm dart pub get` 으로만, `pub upgrade` 는 하지 않음 · 종료 코드 69 의 경우 · `fvm dart run tool/verify.dart --tag vX.Y.Z` · 같은 커밋)
3. 작업 브랜치 push 와 GitHub `verify` (push 전 비공개 점검)
4. 예행 — `fvm dart run tool/smoke.dart <릴리스 커밋>`
5. **(직전 확인)** annotated tag 와 `git push origin vX.Y.Z`
6. CI 의 tag 실행 (`headBranch` 필터 · `버전 일치 검사: tag vX.Y.Z (GITHUB_REF_NAME)`)
7. `fvm dart run tool/smoke.dart vX.Y.Z` (`resolved-ref` 대조)
8. `git ls-remote --tags origin` 의 `^{}` 줄과 `--heads`
9. **(직전 확인)** `main` 병합 — `gh pr merge <번호> --merge`, squash · rebase 금지
10. 다음 `-dev` 와 `미출시` 를 같은 커밋에서

그 뒤 소절 `### plugin 새 버전 때문에 정답지가 저절로 깨졌을 때` — 화면의 `plugin` 줄로 가르기, (a) ~ (d) 대응(다른 단계가 모두 통과할 때만 `--update`, 별도 커밋, 버전은 올리지 않음), `--update` 를 쓰지 않는 경우.

## Files Created/Modified

- `README.md` — 문단 셋, 34 · 355 · 381행 (펜스 줄 수 · 다른 패키지의 `.yaml` 주소 수 · 표시 구역 마커 2 는 그대로)
- `VERSIONING.md` — 82행, 끝에 새 절 (`^## ` 줄 5 → 6)

## Decisions Made

- 절차 5단계의 tag 점검은 06-RESEARCH § 8 대로 넷(`git cat-file -t` · `git rev-parse '…^{commit}'` · tag 의 `pubspec.yaml` version · tag 의 CHANGELOG 첫 줄)으로 적었다 — 계획 본문은 셋을 나열하고 "넷을 본 뒤" 라고 했다.
- 절차 6 의 tag 실행 필터는 A3 가정 그대로 적었다 — 06-05 가 실제 `headBranch` 값으로 확인한다.

## Deviations from Plan

계획의 글자에서 벗어난 것은 아래 셋뿐이고, 모두 문서 문장의 범위다. Rule 1 ~ 4 에 해당하는 자동 수정은 없다.

1. **절차 5단계에 넷째 점검 `git show vX.Y.Z:CHANGELOG.md` 의 첫 줄을 더했다** — 계획 문안이 "넷을 본 뒤" 라 하면서 셋만 나열했다. 06-RESEARCH § 8 의 4중 점검에 맞췄다.
2. **새 절 앞머리에 용어 풀이 세 줄(annotated tag · 예행 · merge commit)을 더했다** — 계획의 "1 ~ 4행의 톤대로 쉬운 말로" 를 따른 것이고 계획이 정한 글자를 지우지 않았다. 앞 문단은 계획의 "실제로 밟은" 대신 "실제로 밟는" 으로 썼다 — 이 커밋은 릴리스 전에 들어간다.
3. **절차 2 · 4 에 설명을 조금 더했다** — 2 에는 종료 코드 69 일 때 stderr 안내가 `example/` 쪽 변경처럼 읽힌다는 것과 `--tag` 실행의 모드 줄 `버전 일치 검사: tag vX.Y.Z (--tag)` 를, 4 에는 두 주소 이름(`recommended.yaml` · `analysis_options.yaml`)을 더했다. 10 의 "검사 (1) 이" 는 "검사가" 로 썼다 (절차 문서 안에 (1) 이 가리킬 목록이 없다).

**Total deviations:** 0 auto-fixed (문서 문장 조정 셋). **Impact on plan:** 단언 모두 통과, 금지 항목(새 펜스 · 다른 패키지 주소 · 「받는 규칙」 절 · VERSIONING 82행 밖의 기존 줄 · `lib/` 등 다른 파일)은 건드리지 않았다.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 06-03 (`tool/smoke.dart`): 절차 4 · 7 이 `fvm dart run tool/smoke.dart <릴리스 커밋>` · `fvm dart run tool/smoke.dart vX.Y.Z` 를 글자 그대로 적었다 — 스크립트 이름 · 인자 꼴이 바뀌면 이 절도 고친다. 4 의 설명은 "빈 Flutter 프로젝트가 GitHub 주소에서 그 커밋을 받아 두 주소 `recommended.yaml` · `analysis_options.yaml` 로 분석한다", 7 은 "받은 lock 의 `resolved-ref` 가 `git rev-parse 'vX.Y.Z^{commit}'` 과 같다" 이다.
- 06-04 (릴리스 커밋): README 「프로젝트 전체」 의 측정 문장은 2026-10-15 의 작업 브랜치 커밋을 잰 것이다 — 예행이 릴리스 커밋으로 다시 재고, 다르면 문장을 고친 커밋으로 예행을 다시 한다 (D-07). `VERSIONING.md` 「실제 사례」 67 · 69행은 이 plan 이 손대지 않았다 (R2-Q1). 새 절은 파일 끝(128 ~ 162행)이라 67 · 69행의 줄 번호는 그대로다.
- 06-05: 절차 6 의 `headBranch` 필터(A3)를 진짜 tag 실행으로 확인하고, 다르면 6단계를 고친다.
- 06-04 의 push 범위 점검용: 이 plan 의 두 커밋 · SUMMARY 에 더한 줄에서 절대 경로 · 홈 · 임시 폴더 꼴 0줄, 저장소에 없는 소스 · 자산 파일 경로 0개, 리뷰 도구가 고친 곳을 가리키는 영어 문구 꼴 0줄 (커밋 전 `git diff --cached` 로 확인 — 이 SUMMARY 도 그 문구 글자를 적지 않았다).

## Self-Check: PASSED

- FOUND: `README.md`, `VERSIONING.md`
- FOUND: `c9a3225`, `f95d482` (`git merge-base --is-ancestor … HEAD`)
- 두 task 의 `<automated>` 를 커밋 뒤 base 고정으로 다시 돌려 rc 0

---
*Phase: 06-release*
*Completed: 2026-10-15*
