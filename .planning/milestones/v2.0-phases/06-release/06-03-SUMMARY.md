---
phase: 06-release
plan: 03
subsystem: tooling
tags: [smoke-test, release, git-dependency, dart-analyze, riverpod_lint, flutter-create]

requires:
  - phase: 05-documentation
    provides: README 「설치」 블록(url · ref), origin 의 작업 브랜치 커밋 2336ba0 (나눈 구조 + Phase 5 README)
  - phase: 06-release
    provides: 06-02 의 VERSIONING.md 「릴리스 절차」 4 · 7번이 적은 명령 `fvm dart run tool/smoke.dart <릴리스 커밋>` · `… vX.Y.Z`
provides:
  - "tool/smoke.dart — 빈 프로젝트가 GitHub 에서 <ref> 를 받아 두 주소로 분석하고 D-09 (2) · (3) 을 판정하는 릴리스 smoke test (종료 코드 0 / 1 / 64 / 69 / 70 / 78)"
  - "실제 실행 넷의 결과 — 통과(2336ba0, rc 0), 없는 ref (69), annotated tag v1.3.0 (1, recommended 쪽만 실패), 앞선 브랜치 이름 (1, resolved-ref 불일치)"
affects: [06-04 예행 smoke 와 D-14 측정, 06-05 tag smoke (v2.0.0), 06-04 push gate 의 점검 범위]

actuals:
  tokens: 7853
  tasks: 2
  commits: 2
plan_head_before: 3ff4411719b01fc9b9cfcf4329a7b880e54908ee
plan_head_after: 0a53fd59b19ae29e19d7cdc9d9f223055e0e6815

tech-stack:
  added: []
  patterns:
    - "저장소 밖 임시 폴더 + 새 PUB_CACHE + 주소마다 새 ANALYZER_STATE_LOCATION_OVERRIDE — 평소 cache · 상태 폴더를 쓰지 않는다"
    - "하위 명령은 띄운 SDK 의 bin/flutter 와 실행 중인 dart 만 — fvm · PATH 의 이름은 git 만"
    - "화면에 나가는 하위 명령 출력의 경로는 긴 것부터 가린다 (링크를 푼 임시 폴더 경로가 준 경로를 품는다)"

key-files:
  created:
    - tool/smoke.dart
  modified: []

key-decisions:
  - "위반 파일의 출처 주석과 import 줄은 본문 raw 문자열 밖의 상수(violationsHeader · violationsImport)로 둔다 — 줄 머리의 import 를 세는 검사가 스크립트 자신의 import 로 읽는다; 임시 프로젝트에 쓰는 내용은 바이트까지 같다"
  - "주소마다의 판정은 tool/verify.dart 와 같은 배타 순서 — plugin 머리말 → 도구가 죽음(exit 0 · 2 · 3 밖 / JSON 아님) → 위반 두 줄의 존재; plugin 폴더 수 · 버전은 정보로만 찍는다"
  - "임시 폴더는 SDK 확인 · 기대 커밋 확인 뒤에 만든다 — 64 · 78 · 69(rev-parse) 는 아무것도 만들지 않고 끝나고, 그 뒤의 69 · 70 · 1 은 끝에 임시 폴더를 지운다 (--keep 이 아니면)"

patterns-established:
  - "릴리스 smoke: fvm dart run tool/smoke.dart <ref> [--keep] — 06-04 예행 · 06-05 tag 실행 · 앞으로의 릴리스가 같은 명령을 쓴다"

requirements-completed: [REL-04]

coverage:
  - id: D1
    description: "tool/smoke.dart 가 origin 의 커밋 2336ba0 을 빈 프로젝트가 GitHub 에서 받아 두 주소 각각에서 prefer_single_quotes (info) 와 provider_parameters (warning) 를 보고하고 lock 의 resolved-ref 가 기대 커밋과 같음을 판정해 종료 코드 0"
    requirement: "REL-04"
    verification:
      - kind: integration
        ref: "06-03-PLAN.md Task 1 <automated> (fvm dart run tool/smoke.dart 2336ba0e3e193e70b2c328c77594b3173b53defc 와 사용법 넷 포함)"
        status: pass
    human_judgment: false
  - id: D2
    description: "smoke 의 실패 방향 셋 — 없는 ref 69, annotated tag v1.3.0 은 tag 를 커밋으로 벗겨 (3) 통과 · recommended 쪽 두 사유로 1, 로컬이 앞선 브랜치 이름은 resolved-ref 불일치 한 사유로 1"
    requirement: "REL-04"
    verification:
      - kind: integration
        ref: "06-03-PLAN.md Task 2 <automated> (no-such-ref-06-03 · v1.3.0 · gsd/v2.0-package-rework)"
        status: pass
    human_judgment: false

duration: 13min
completed: 2026-10-15
status: complete
---

# Phase 6 Plan 03: 릴리스 smoke test Summary

**`tool/smoke.dart <ref>` — 저장소 밖 빈 Flutter 프로젝트가 README 「설치」 대로 GitHub 에서 `<ref>` 를 새 pub cache 로 받아 `recommended.yaml` · 옛 주소 둘로 분석하고, 위반 두 줄의 존재와 lock 의 `resolved-ref` == `git rev-parse '<ref>^{commit}'` 을 판정한다. 통과 하나와 실패 방향 셋을 실제 GitHub 주소로 돌려 확인했다.**

## Performance

- **Duration:** 약 13분
- **Started:** 2026-10-15T05:29:44Z
- **Completed:** 2026-10-15T05:43Z 무렵
- **Tasks:** 2 (Task 2 는 스크립트를 고칠 것이 없어 커밋 없음)
- **Files modified:** 1 (새 파일 `tool/smoke.dart`, 762줄)

## Accomplishments

- `tool/smoke.dart` — import 는 `dart:convert` · `dart:io` 둘, `tool/verify.dart` 를 import 하지 않음(도우미 복사), `fvm dart analyze` No issues · `fvm dart format --output=none --set-exit-if-changed tool` 통과. CI job · `tool/verify.dart` 에는 넣지 않았다 (D-10).
- 통과 실행 (origin 의 작업 브랜치 커밋 `2336ba0`) — GitHub 주소에서 받는 길을 스크립트가 처음 돌았다.
- 실패 방향 셋 — 각기 다른 종료 코드 · 사유로 갈린다. `v1.3.0` 실행이 "include 가 깨져도 통과" 의 거짓 통과(Pitfall 5)와 tag 경로(`^{commit}` 벗기기, checker W2)를 tag push 전에 가렸다.

## 실제 실행 넷 (Flutter 3.47.5 / Dart 3.13.4, 2026-10-15)

모든 실행의 stdout 첫 줄은 `SDK Flutter 3.47.5 / Dart 3.13.4`, 끝 줄은 (임시 폴더를 만든 실행이면) `임시 폴더를 지웠다`. 화면에 임시 폴더 · 홈 경로는 0줄이었고 저장소 안에는 아무것도 생기지 않았다.

| 명령 (`fvm dart run tool/smoke.dart …`) | 종료 코드 | 시간 | 요약 |
|---|---|---|---|
| `2336ba0e3e193e70b2c328c77594b3173b53defc` | 0 | 49초 (create 0.6초, pub get 6.8초, 분석 23.4초 · 16.6초) | lock `source git`, url README 와 같음, `resolved-ref 2336ba0e…`; 두 주소 각 6줄, exit 2, 머리말 없음, plugin 폴더 1, `riverpod_lint 3.1.9`; `smoke 통과 (ref 2336ba0e… → 2336ba0e…, recommended 6줄 / 옛 주소 6줄, riverpod_lint 3.1.9)` |
| `no-such-ref-06-03` | 69 | 1초 | stderr `git rev-parse 'no-such-ref-06-03^{commit}' 실패: exit 1 — 로컬에 없는 ref 다. …`; stdout 은 SDK 줄 하나 (빈 프로젝트를 만들기 전에 멈춤, 임시 폴더 없음) |
| `v1.3.0` (annotated tag, 객체 `80e2112…`) | 1 | 29초 | `기대 커밋: 90a2736b…` (tag 객체 번호가 아니라 커밋), `resolved-ref 90a2736b…` — (3) 통과. `recommended`: exit 2, 3.2초, plugin 폴더 0, 1줄 `analysis_options.yaml:10  warning  include_file_not_found`. `alias`: exit 2, 17.2초, plugin 폴더 1, 3.1.9, 3줄 (`missing_provider_scope` · `provider_parameters` · `prefer_single_quotes`). 사유 정확히 둘: `  - recommended: prefer_single_quotes 없음` · `  - recommended: provider_parameters 없음` |
| `gsd/v2.0-package-rework` | 1 | 44초 | `기대 커밋: 0a53fd59…` (로컬 브랜치 머리 — origin 보다 31커밋 앞), lock `resolved-ref 2336ba0e…` (pub 은 GitHub 의 그 브랜치를 받음). 두 주소 모두 6줄 · 위반 둘 있음. 사유 정확히 하나: `  - resolved-ref 2336ba0e… 가 기대 커밋 0a53fd59… 과 다르다` |

통과 실행 6줄 (두 주소 같음): `lib/main.dart:4  warning  missing_provider_scope`, `lib/smoke_violations.dart:12  warning  provider_parameters`, `lib/smoke_violations.dart:5  info  prefer_single_quotes`, `lib/smoke_violations.dart:8  info  specify_nonobvious_property_types`, `pubspec.yaml:36  info  sort_pub_dependencies`, `pubspec.yaml:48  info  sort_pub_dependencies`.

덧붙여 `2336ba0 --keep` 을 한 번 돌렸다 — rc 0, 41초, 마지막 줄이 `임시 폴더를 남겼다: <경로>` (그 한 줄뿐). 남긴 폴더에는 `app` · `pub-cache` · `state-alias` · `state-recommended` 넷이 있었고, 확인 뒤 지웠다.

## `<automated>` 결과

계획 파일의 `<verify>` 바로 안 `<automated>` 글자를 그대로 뽑아(python `-I`, 블록 둘 — 3253 · 2457바이트) 저장소 루트에서 `bash` 로 돌렸다. 고친 판은 만들지 않았다 (단언 결함 없음).

| Task | 적힌 그대로 rc | 고친 판 rc |
|---|---|---|
| Task 1 (커밋 `1a15926` 시점) | 1 — `import` 줄 대조에서 실패 (`bash -x` 의 마지막 줄: 스크립트의 import 셋째 줄로 위반 파일 본문의 `import 'package:flutter_riverpod/…'` 가 잡힘) | — (스크립트를 고침, 아래 Deviation 1) |
| Task 1 (커밋 `0a53fd5` 시점) | 0 (47초) | — |
| Task 2 (커밋 `0a53fd5` 시점, 세 실행 뒤) | 0 (69초) | — |

## Task Commits

1. **Task 1: tool/smoke.dart** — `1a15926` (feat) `feat(tool): tool/smoke.dart — 빈 프로젝트가 GitHub 에서 <ref> 를 받아 두 주소로 분석하는 릴리스 smoke test (REL-04, D-08 · D-09 · D-10)`
2. **Task 1 의 자동 검증에서 나온 수정** — `0a53fd5` (fix) `fix(tool): smoke 의 위반 파일 import 줄을 본문 상수 밖으로 (06-03 Task 1)`
3. **Task 2: 실패 방향 셋** — 커밋 없음 (기대한 종료 코드 · 사유가 그대로 나와 스크립트를 고치지 않았다)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 의 커밋 (docs)

## Files Created/Modified

- `tool/smoke.dart` — 릴리스 smoke test. 상수 `repoUrl` · `smokeAppName` · `violationsFile` · `includeTargets` · `expectedBaseRule` · `expectedPluginRule` · `pluginPackage` · `runCommand`, 함수 `flutterRootOf` · `ensurePinnedSdk` · `runProcess` · `editPubspec` · `setInclude` · `writeViolations` · `lockEntry` · `normalizeDiagnostics` · `pluginFolders` · `readPluginVersion` · `analyzeOnce` · `judge` · `quit` (계획의 목록) 과 보조 `scrub` · `findInBlock` · `expectedCommit` · `parseArgs` · `runSmoke` · `reportFailure` · `formatSeconds`.

## Decisions Made

- 위반 파일의 출처 주석 · import 줄을 본문 raw 문자열 밖 상수로 (Deviation 1).
- 주소마다의 판정은 `tool/verify.dart` 와 같은 배타 순서 — 머리말 → 도구가 죽음 → 두 줄의 존재. plugin 폴더 수 · 버전은 정보로만.
- 임시 폴더는 SDK · 기대 커밋 확인 뒤에 만들고, 그 뒤의 모든 끝(0 · 1 · 69 · 70)에서 `--keep` 이 아니면 지운다. 하위 명령 출력의 경로 가리기는 임시 폴더 · Flutter SDK · 저장소 · 홈을 이름으로 바꾸되 긴 경로부터 (링크를 푼 임시 폴더 경로가 준 경로를 품어, 짧은 쪽부터 바꾸면 앞부분이 남는다).
- `editPubspec` 의 앵커는 블록 안에서만 찾는다 (`dependencies:` 의 `cupertino_icons`, `dev_dependencies:` 의 `flutter_lints` — 들여쓰기 없는 다음 키가 나오면 블록 끝). 없으면 `FormatException` → 70.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] 위반 파일 본문 안의 `import` 줄이 스크립트의 import 로 세어짐**
- **Found during:** Task 1 (`<automated>` 첫 실행)
- **Issue:** 위반 파일 내용을 raw 문자열 상수 하나에 두었더니 그 안의 `import 'package:flutter_riverpod/flutter_riverpod.dart';` 가 줄 머리에 와서, import 가 `dart:convert` · `dart:io` 둘뿐인지 보는 단언(`grep -E '^import '`)이 셋을 셌다 (rc 1).
- **Fix:** 출처 주석을 `violationsHeader`, import 줄을 `violationsImport` (들여 쓴 문자열) 상수로 빼고 `writeViolations` 가 `머리 주석 \n import \n 본문` 으로 이어 쓴다. 임시 프로젝트에 쓰는 내용은 이전과 바이트까지 같다 (668바이트, python 으로 대조). 위반 줄 번호도 같다 (`:5` · `:12`).
- **Files modified:** `tool/smoke.dart`
- **Verification:** Task 1 `<automated>` 적힌 그대로 rc 0, 이어서 Task 2 `<automated>` rc 0.
- **Committed in:** `0a53fd5` (Task 1 커밋 뒤 별도 fix 커밋 — 계획은 fix 커밋을 Task 2 용으로만 적었으므로 제목 끝을 `(06-03 Task 1)` 로 했다)

---

**Total deviations:** 1 auto-fixed (Rule 1 1건)
**Impact on plan:** 생성 파일 내용 · 판정 · 출력은 그대로. 범위 밖 변경 없음.

## Issues Encountered

- 06-RESEARCH.md 의 가정 A2 ("`flutter_riverpod` 를 `cupertino_icons` 뒤, `woody_lints` 를 `flutter_lints` 뒤에 넣으면 `sort_pub_dependencies` 가 나지 않는다") 는 맞지 않았다 — 그 배치로도 두 줄이 났다. `--keep` 실행에서 본 줄 번호는 36 = 템플릿의 `cupertino_icons: ^1.0.8`, 48 = 템플릿의 `flutter_lints: ^6.0.0` 이다 — 더한 줄이 아니라 sdk 의존성(`flutter` · `flutter_test`) 뒤에 오는 템플릿 자신의 줄에 붙는다. `v1.3.0` 의 `alias` 실행(1.3.0 의 규칙)에서는 나지 않았으므로 2.0 의 `lib/base.yaml` 이 켜는 규칙이 템플릿에 대해 내는 진단이다. 판정은 두 줄의 존재라 영향 없다.
- 첫 확인 때 셸 하나에서 사용법 점검을 zsh 로 돌려 `a b` 를 인자 하나로 넘겨 69 가 나왔다 — bash 로 다시 돌려 64 를 확인했다 (스크립트 문제 아님). 이때 저장소 밖에 생긴 빈 출력 파일 하나는 곧바로 지웠다.

## User Setup Required

None - 네트워크(GitHub · pub.dev)만 필요하다.

## Next Phase Readiness

- **06-04 (예행 · D-14 측정):** 명령은 `fvm dart run tool/smoke.dart <릴리스 커밋>` 그대로. 릴리스 커밋이 origin 에 push 된 뒤여야 한다 — 브랜치 이름을 주면 로컬이 앞선 동안 resolved-ref 불일치로 1 이 된다 (위 넷째 실행); origin 에 없는 커밋 번호를 주면 pub get 이 받지 못해 69 로 끝날 것으로 보지만 재지 않았다. D-14 측정용으로 `--keep` 을 쓰면 마지막 줄 하나에만 임시 폴더 경로가 찍힌다 — 기록에 옮기지 말고, 끝에 그 폴더(`app` · `pub-cache` · `state-*` 넷)를 지운다. 남긴 폴더에서 다시 분석할 때도 `PUB_CACHE` · 상태 폴더를 그 폴더 안의 것으로 주고, 저장소 밖에서 `fvm` 으로 부르지 않는다 (전역 SDK 로 풀린다). 예행 통과 줄의 줄 수는 지금 6줄 — 릴리스 커밋이 규칙을 바꾸지 않으므로 같을 것으로 보지만 재지 않았다.
- **06-04 push gate:** 범위에 들어가는 `tool/smoke.dart` 의 더한 줄에서 점검 (2) 꼴에 걸리는 경로는 `bin/cache/flutter.version.json`, `lib/smoke_violations.dart` (예외 목록에 있음) 와 `example/` 에 있는 `lib/added_rules.dart` · `lib/riverpod_rules.dart` 넷뿐이다. 점검 (1) · (3) 꼴은 커밋 둘의 더한 줄에서 0줄 (커밋 전에 grep).
- **06-05 (tag smoke):** `fvm dart run tool/smoke.dart v2.0.0` — annotated tag 경로는 `v1.3.0` 으로 이미 돌았다 (`기대 커밋` 이 tag 객체가 아닌 커밋, lock `resolved-ref` 와 같음). tag 를 origin 에 push 한 뒤에 돌린다 (pub 은 GitHub 에서 받는다).

---
*Phase: 06-release*
*Completed: 2026-10-15*

## Self-Check: PASSED
