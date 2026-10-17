---
phase: 06-release
plan: 09
subsystem: testing
tags: [dart, smoke, release, timeout, sigint, process, rel-04]

# Dependency graph
requires:
  - phase: 06-release
    provides: "06-03 의 tool/smoke.dart (두 주소 분석 · D-09 (2) · (3) 판정 · 임시 폴더), 06-05 의 tag v2.0.0 (원격)"
provides:
  - "judge 가 주소마다 analysis_options.yaml 의 include 오류 코드 둘(include_file_not_found · included_file_warning)을 실패 사유로 더하고 ({List<String> reasons, String shown}) 을 돌려준다 — runSmoke 는 그 값만 쓴다"
  - "runProcess 의 단계별 시간 제한 (create 2분 · pub get 5분 · analyze 주소마다 5분) — 넘으면 프로세스와 자손을 얼린 뒤 SIGKILL, stderr 안내, 종료 코드 69"
  - "cleanupWork 와 main 의 finally · SIGINT(130) 정리 — --keep 때만 경로를 찍는다"
  - "머리 주석의 종료 코드 목록 (69 의 시간 초과 · 130 · 255) 과 판정 설명 (2′)"
affects: [06-10, 06-11, release-gate, tool/smoke.dart]

# Actuals (#2632)
actuals:
  tokens: 5857
  tasks: 3
  commits: 2
plan_head_before: ca2cb7862a6a18fe81cf48a54f10a42ac6e9c72d
plan_head_after: 4286d48b980e581c10ab8164debcbe072234e27a

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "하위 명령은 Process.start + exitCode 의 제한(.then<int?> · timeout(onTimeout: null)) — dart:async 없이"
    - "하위 명령을 끊을 때는 자손까지: SIGSTOP 으로 얼리고 /bin/ps 표를 다시 읽어 새 자손이 없을 때 한꺼번에 SIGKILL, 표에서 사라질 때까지 기다림"
    - "SIGINT 처리기와 본 흐름: quit 는 먼저 부른 쪽 우선, 처리기 중이면 본 흐름은 await 뒤에서 멈춤"

key-files:
  created: []
  modified:
    - tool/smoke.dart

key-decisions:
  - "smoke 의 시간 초과 · SIGINT 는 하위 명령의 자손까지 끊는다 — SIGSTOP 으로 얼리고 /bin/ps 표를 새 자손이 없을 때까지 다시 읽은 뒤 SIGKILL (dart analyze 가 analysis server 를 자식으로 두고, 표를 한 번만 읽고 끊었을 때 지운 임시 폴더가 다시 생긴 실측)"
  - "SIGINT 처리기와 본 흐름의 겹침은 quit 의 먼저 부른 쪽 우선과 처리기 중의 본 흐름 멈춤(haltIfInterrupted)으로 막는다"
  - "단계 제한 값(create 2분 · pub get 5분 · analyze 5분)과 SIGINT 종료 코드 130 은 planner 가 고른 값이고 Round 2 에서 소유자에게 보였으며 반대가 없었다"

patterns-established:
  - "판정 조건과 화면 문구는 judge 한 곳 — 부르는 쪽은 reasons · shown 만 쓴다"

requirements-completed: [REL-04]  # 이 plan 은 requirements.mark-complete 를 부르지 않는다 — REL-04 는 06-10 · 06-11 도 선언하므로 마지막 plan 이 표시한다

coverage:
  - id: D1
    description: "judge 가 두 주소 각각에서 include 사슬 진단(코드 둘)을 실패 사유로 더하고, 다른 analysis_options.yaml 진단은 사유로 보지 않으며, (reasons, shown) 을 돌려준다 — 하네스 여덟 입력"
    requirement: "REL-04"
    verification:
      - kind: unit
        ref: "06-09-PLAN.md Task 1 <automated> (고친 판 — `)\\\" =` 한 군데) rc 0"
        status: pass
    human_judgment: false
  - id: D2
    description: "runProcess 의 시간 제한과 자손까지 끊기, cleanupWork, main 의 finally · SIGINT 130 — 하네스 넷과 SIGINT 끝에서 끝까지"
    requirement: "REL-04"
    verification:
      - kind: integration
        ref: "06-09-PLAN.md Task 2 <automated> (고친 판 — `)\\\" =` 한 군데 · cleanupWork 서명 grep 을 format 이 나눈 꼴로) rc 0"
        status: pass
    human_judgment: false
  - id: D3
    description: "고친 smoke 가 GitHub 에서 v2.0.0 을 받아 두 주소 모두 통과 (REL-04 회귀)"
    requirement: "REL-04"
    verification:
      - kind: e2e
        ref: "06-09-PLAN.md Task 3 <automated> (고친 판 — `)\\\" =` 여섯 군데) rc 0, 42초"
        status: pass
    human_judgment: false

# Metrics
duration: 15min
completed: 2026-10-16
status: complete
---

# Phase 6 Plan 09: smoke 판정 · 시간 제한 · 임시 폴더 정리 Summary

**`tool/smoke.dart` 의 `judge` 가 두 주소 각각에서 include 사슬이 끊긴 진단(`include_file_not_found` · `included_file_warning`)을 실패로 보고 사유와 `판정:` 문구를 함께 돌려주며, 하위 명령 셋은 단계별 제한(2 · 5 · 5분)을 넘기면 자손까지 끊겨 69 로, Ctrl-C 는 정리 뒤 130 으로 끝나고 어떤 끝에서도 임시 폴더가 지워진다 — 고친 smoke 가 `v2.0.0` 을 39초 · 42초에 통과**

## Performance

- **Duration:** 약 15 min
- **Started:** 2026-10-16T10:02:57Z
- **Completed:** 2026-10-16T10:18Z
- **Tasks:** 3 (커밋 2 — Task 3 은 실행 기록만)
- **Files modified:** 1 (`tool/smoke.dart`, 762 → 1002줄)

## Accomplishments

- **Task 1 (WR-01 · IN-02):** `const includeErrorCodes = {'include_file_not_found', 'included_file_warning'};` 를 두고, `judge` 를 `({List<String> reasons, String shown}) judge(AnalyzeOutcome outcome)` 로 바꿨다. 순서는 (a) plugin 머리말 → (b) 도구 사망 → (c′) `analysis_options.yaml` 의 include 오류 줄마다 사유 → (c) 위반 두 줄. `shown` 은 (a) · (b) 면 사유에서 주소 이름을 뗀 글자이고, 아니면 `… 있음 · … 없음` 에 include 사유가 있을 때 ` · include 사슬 끊김 N줄` 을 잇는다. `runSmoke` 의 중복 조건 · `found.first.substring` · 지역 `mark` 를 지우고 `final verdict = judge(outcome);` · `reasons.addAll(verdict.reasons);` · `stdout.writeln('   판정: ${verdict.shown}');` 세 줄로 바꿨다. `analyzeExitCodes.contains(` 는 `judge` 한 곳뿐이다. 머리 주석에 (2′) 를 더했다.
- **Task 2 (WR-03 · IN-01):** `createTimeout` 2분 · `pubGetTimeout` 5분 · `analyzeTimeout` 5분. `runProcess` 는 `Process.start` 로 띄우고 stdout · stderr 를 먼저 모으기 시작한 뒤 `exitCode` 에 제한을 둔다. 넘으면 `killTree` 가 프로세스와 자손을 끊고 `(result: null, elapsed, timedOut: true)` 를 돌려준다. 세 호출이 시간 초과면 stderr 에 단계 · 분을 적고 69 로 끝난다 (`analyzeOnce` 는 `Future<AnalyzeOutcome?>` → null → `runSmoke` 69). 정리는 `cleanupWork` 로 묶고 `main` 의 `finally` 와 `ProcessSignal.sigint.watch()` 처리기가 같이 부른다 (SIGINT → 130). 옛 `try` 밖 정리 블록은 지웠다. 머리 주석의 종료 코드 목록에 69 의 시간 초과 · 130 · 255 를 적고, "어떻게 끝나도 임시 폴더는 지운다" 한 줄을 더했다. `Process.run(` 은 `expectedCommit` 의 git 한 곳뿐이고, import 는 `dart:convert` · `dart:io` 둘 그대로다.
- **Task 3 (REL-04 회귀):** 고친 smoke 가 실제 GitHub 주소에서 `v2.0.0` 을 받아 통과했다 (기록 실행 1회 + `<automated>` 1회, 둘 다 rc 0).

### (1) Task 1 하네스 여덟 줄 (고친 판 `<automated>` 안의 출력, 글자 그대로)

```
clean reasons=0  shown=prefer_single_quotes 있음 · provider_parameters 있음
inc-rec reasons=1 recommended: include 사슬이 끊겼다 (analysis_options.yaml:1  warning  include_file_not_found) shown=prefer_single_quotes 있음 · provider_parameters 있음 · include 사슬 끊김 1줄
inc-alias reasons=1 alias: include 사슬이 끊겼다 (analysis_options.yaml:1  warning  included_file_warning) shown=prefer_single_quotes 있음 · provider_parameters 있음 · include 사슬 끊김 1줄
other-ao reasons=0  shown=prefer_single_quotes 있음 · provider_parameters 있음
hdr reasons=1 alias: plugin 준비 실패 (stderr 의 머리말) shown=plugin 준비 실패 (stderr 의 머리말)
json-null reasons=1 alias: 도구가 죽었다 (JSON 아님) shown=도구가 죽었다 (JSON 아님)
exit9 reasons=1 alias: 도구가 죽었다 (exit 9) shown=도구가 죽었다 (exit 9)
no-plugin reasons=1 recommended: provider_parameters 없음 shown=prefer_single_quotes 있음 · provider_parameters 없음
```

### (1) Task 2 하네스 네 줄과 SIGINT 실행

```
timeout timedOut=true result=null fast=true
echo timedOut=false exit=0 out=hi
nokeep deleted=true exists=false hasPath=false msg=임시 폴더를 지웠다
keep deleted=false exists=true hasPath=true
```

- 하네스 뒤 `sleep 7331` 0건. 덧붙여 자식을 둔 셸(`sh -c 'sleep 7332 & sleep 7333; wait'`, 제한 2초)도 `timedOut=true` · 10초 안이고 두 `sleep` 모두 남지 않았다 (`killTree` 확인).
- SIGINT 끝에서 끝까지 (고정 SDK 의 dart 를 직접, 인자는 HEAD SHA — Task 1 커밋): `<automated>` 안의 1회 + 같은 절차를 따로 3회 + 신호 8초 뒤 폴더 재확인 1회. 모두 종료 코드 **130**, 걸린 시간 약 1초, `woody_smoke_*` 폴더 0 (8초 뒤에도 0), stdout 끝 줄 `임시 폴더를 지웠다`, stderr `중단됨 (SIGINT) — 임시 폴더를 정리하고 끝낸다`, stdout · stderr 의 임시 폴더 경로 0줄, `project-name smoke_app` 0건.
- 신호가 닿은 자리는 `flutter create` 가 아니라 `flutter pub get` 의 시작이었다 — `flutter create` 가 0.4초에 끝나 1초 간격의 폴더 확인보다 빨랐다 (stdout 에 `flutter create: exit 0, 0.4s` 가 있다). 그래서 이 실행은 받기(네트워크) 단계를 끊는 경우를 확인한 것이다.

### (2) Task 3 — 전체 smoke `v2.0.0`

| 회차 | 시작 (UTC) | 걸린 시간 | 종료 코드 |
|------|-----------|-----------|-----------|
| 기록 실행 (action 1) | 2026-10-16T10:13:52Z | 39초 | 0 |
| `<automated>` 고친 판 | 2026-10-16T10:14:39Z | 42초 | 0 |

기록 실행의 화면 (경로 · 계정이 든 글자는 말로 바꿨다):

- 첫 줄 `SDK Flutter 3.47.5 / Dart 3.13.4`, `기대 커밋: 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2 (git rev-parse 'v2.0.0^{commit}')`
- `flutter create: exit 0, 0.4s`, `flutter pub get: exit 0, 6.3s` — lock 의 `source git`, url 이 README 와 같음, `resolved-ref 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2`
- `## recommended` — `dart analyze exit 2, 16.0s, 머리말 없음, plugin 폴더 1, riverpod_lint 3.1.9`, 6줄 (위반 파일의 `info  prefer_single_quotes` · `warning  provider_parameters` 포함)
- `## alias` — `dart analyze exit 2, 15.6s, 머리말 없음, plugin 폴더 1, riverpod_lint 3.1.9`, 6줄 (같은 둘 포함)
- `판정:` 둘 — 두 주소 모두 `   판정: prefer_single_quotes 있음 · provider_parameters 있음` (include 사슬 글자 없음, `analysis_options.yaml:` 줄 0)
- `smoke 통과 (ref v2.0.0 → 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2, recommended 6줄 / 옛 주소 6줄, riverpod_lint 3.1.9)`
- 마지막 줄 `임시 폴더를 지웠다`, stderr 빈 출력, 임시 폴더 경로 0줄, 남은 `woody_smoke_*` 0, 끝난 뒤 `tool/smoke.dart` · `project-name smoke_app` 프로세스 0건
- 69 는 나지 않았다 (네트워크 정지 없음).

### (3) planner 재량 둘

단계 제한 값(create 2분 · pub get 5분 · analyze 주소마다 5분)과 SIGINT 의 종료 코드 130 은 planner 가 고른 값이다. Round 2 (2026-10-16) 에서 소유자에게 보였고 반대가 없었다. 시간 초과의 종료 코드 69 는 소유자에게 보인 값이다 (G6-Q2).

### `<automated>` 종료 코드

| Task | 적힌 그대로 | 고친 판 | 바꾼 자리 |
|------|-------------|---------|-----------|
| 1 | 2 (구문 오류 `near unexpected token \`|'`) | 0 | `)\" =` → `)" =` 1곳 |
| 2 | 2 (같은 구문 오류) | 0 | `)\" =` → `)" =` 1곳 + cleanupWork 서명 grep 1곳 (아래 Deviations 2) |
| 3 | 2 (`test: too many arguments`) | 0 (42초) | `)\" =` → `)" =` 6곳 |

치환은 python `-I` 의 글자 치환으로 했고 치환 횟수(1 · 1 · 6)를 찍어 확인했다. 고친 판 Task 1 은 Task 2 커밋 뒤에도 다시 rc 0 이었다.

## Task Commits

1. **Task 1: judge 의 include 사슬 조건과 (reasons, shown)** — `2c5b73b` `fix(tool): smoke 판정 — include 사슬 진단을 실패로, judge 가 사유와 표시 문구를 함께 돌려줌 (WR-01 · IN-02)`
2. **Task 2: 시간 제한 · 자손까지 끊기 · finally · SIGINT** — `4286d48` `fix(tool): smoke 단계마다 시간 제한(69)과 임시 폴더 정리(finally · SIGINT, 130) (WR-03 · IN-01)`
3. **Task 3: 전체 smoke 회귀** — 커밋 없음 (실행 기록은 위)

**Plan metadata:** 이 SUMMARY 와 STATE · ROADMAP 의 커밋 (docs)

## Files Created/Modified

- `tool/smoke.dart` — 머리 주석(판정 (2′), 종료 코드 69 · 130 · 255, 정리 문장, `/bin/ps`), 상수 `includeErrorCodes` · `createTimeout` · `pubGetTimeout` · `analyzeTimeout`, 전역 `runningChild` · `interrupted` · `quitting`, 함수 `haltIfInterrupted` · `processTable` · `descendantsOf` · `killTree` · `cleanupWork`, 바뀐 `quit` · `runProcess` · `analyzeOnce` · `judge` · `expectedCommit` · `runSmoke` · `main`

## Decisions Made

- 위 key-decisions 셋. 그 밖은 계획대로.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] 세 `<automated>` 의 `)\" =` — 고친 판으로 실행**
- **Found during:** Task 1 · 2 · 3 검증 (orchestrator 가 미리 센 1 · 1 · 6곳과 같음)
- **Issue:** 닫는 따옴표 앞의 `\"` 가 글자가 되어 따옴표가 어긋난다 — 적힌 그대로는 셋 모두 rc 2.
- **Fix:** `)\" =` → `)" =` 만. 단언의 뜻은 그대로.
- **Committed in:** 해당 없음 (검증 명령만)

**2. [Rule 3 - Blocking] Task 2 `<automated>` 의 cleanupWork 서명 grep — format 이 나누는 줄**
- **Found during:** Task 2 검증
- **Issue:** 계획의 `grep -qF '({bool deleted, String message}) cleanupWork(Directory work, {required bool keep})'` 는 한 줄 85자라, 같은 명령의 `dart format --set-exit-if-changed` 가 요구하는 모양(네 줄로 나뉨)과 함께 성립할 수 없다. `\"` 만 고친 판은 이 grep 에서 rc 1.
- **Fix:** 고친 판에서 그 grep 하나를 `tr '\n' ' ' < tool/smoke.dart | tr -s ' ' | grep -qF '({bool deleted, String message}) cleanupWork( Directory work, { required bool keep, }) {'` 로 바꿨다 — 같은 서명을 format 이 낸 꼴로 본다. 코드에 `// dart format off` 를 넣는 길은 고르지 않았다.
- **Committed in:** 해당 없음 (검증 명령만)

**3. [Rule 1 - Bug] 하위 명령을 끊을 때 자손까지 — 얼린 뒤 끊기**
- **Found during:** Task 2
- **Issue:** 계획은 "자식이 하나다 (`flutter` 는 dart 를 exec)" 로 보고 그 프로세스 하나만 SIGKILL 하게 했다. 재 보니 `dart analyze` 는 자식 `dartaotruntime` (analysis server) 을 둔다. 부모만 끊으면 멈춘 받기가 남는다. 첫 구현(표를 한 번 읽고 부모 · 자손을 SIGKILL)의 SIGINT 실행 두 번은 둘 다 `woody_smoke_*` 폴더를 남겼다. 한 번은 `임시 폴더를 지우지 못했다: Deletion failed` 였다. 다른 한 번은 `임시 폴더를 지웠다` 를 찍은 뒤 폴더가 `pub-cache/_temp` 와 함께 다시 생겼다. 표를 읽은 뒤에 뜬 자식이 남아 쓴 것이다.
- **Fix:** `killTree` 가 먼저 SIGSTOP 으로 얼리고, 새 자손이 없을 때까지 `/bin/ps -A -o pid= -o ppid=` 표를 다시 읽어 얼린 뒤, 한꺼번에 SIGKILL 하고, 표에서 사라질 때까지 최대 약 5초 기다린다. 시간 초과 · SIGINT · "띄우는 사이의 SIGINT" 세 자리에서 쓴다. `ps` 는 절대 경로로 부르고 `Process.runSync` 다. 머리 주석의 "PATH 의 이름으로 부르는 것은 git 하나뿐" 옆에 이 점을 적었다.
- **Verification:** 고친 뒤 SIGINT 실행 5회 모두 폴더 0 (8초 뒤 0), 자식을 둔 셸 하네스의 손자 0.
- **Committed in:** `4286d48`

**4. [Rule 1 - Bug] SIGINT 처리기와 본 흐름의 겹침**
- **Found during:** Task 2
- **Issue:** 처리기가 하위 명령을 끊으면 그 명령을 기다리던 본 흐름이 깨어난다. 본 흐름은 69 쪽으로 가서 다시 `quit` 를 부르거나, 처리기가 비우는 중의 stdout 에 쓴다. IOSink 는 그때 `StateError` 를 내므로 255 나 69 가 130 을 덮을 수 있다.
- **Fix:** `quit` 는 먼저 부른 쪽이 이긴다 (두 번째는 끝나지 않는 `Future.any([])` 에서 멈춘다). 처리기는 `interrupted` 를 세운다. 본 흐름은 `runProcess` · `expectedCommit` 의 await 뒤 `haltIfInterrupted` 에서 멈춘다. 처리기는 `quitting` 이면 아무것도 하지 않는다.
- **Committed in:** `4286d48`

**5. [Rule 3 - Blocking] 시간 제한을 `TimeoutException` 없이**
- **Issue:** 계획의 `on TimeoutException` 은 `dart:async` import 가 필요하다. 그런데 계획의 `<automated>` 는 import 가 `dart:convert` · `dart:io` 둘뿐이기를 단언한다.
- **Fix:** `process.exitCode.then<int?>((code) => code).timeout(timeout, onTimeout: () => null)` — null 이면 시간 초과. 동작은 같다.
- **Committed in:** `4286d48`

**6. [동작 유지] `--keep` 의 "남겼다" 문구는 stdout 그대로**
- 계획의 `cleanup()` 은 "`deleted` 면 stdout, 아니면 stderr" 였다. 그대로 하면 `--keep` 의 `임시 폴더를 남겼다: …` 가 stderr 로 옮겨 간다. 06-03 의 "stdout 마지막 줄" 동작이 바뀌므로, 지우지 못한 경우만 stderr 로 보냈다 (`deleted || keep` 이면 stdout). `4286d48`.

---

**Total deviations:** 6 (검증 명령 고친 판 2, 버그 2, 막힘 1, 동작 유지 1)
**Impact on plan:** 범위는 `tool/smoke.dart` 한 파일 그대로이고, 판정 (2) · (3) 과 배타 순서는 바뀌지 않았다. 3 · 4 는 WR-03 · IN-01 의 "끊고 지운다" 가 실제로 성립하게 한 것이다.

## Issues Encountered

- 첫 구현의 SIGINT 실행 두 번(Deviations 3)이 기본 임시 폴더에 자기 바깥 폴더 둘을 남겼다. 각각 `out` · `err` 와 `pub-cache/_temp` 만 든 `woody_smoke_*` 를 품었다. 내용을 확인한 뒤 지웠다.
- 적힌 그대로의 Task 3 `<automated>` 가 어긋난 따옴표 안의 명령 치환으로 `mktemp -d` 를 한 번 돌렸다. 빈 폴더 하나가 남아, 시각(그 실행과 같은 초)과 빈 내용을 확인한 뒤 지웠다. smoke 는 띄우지 않았다.
- 내 쪽 도구 실수: 처음 `<automated>` 를 꺼낼 때 정규식이 수용 기준 문장 안의 `` `<automated>` `` 글자에서 시작해, Task 2 파일 앞에 문장이 붙었다. 그 파일은 구문 오류로 아무것도 실행하지 않고 끝났다. 줄 머리에 붙은 태그만 잡도록 고쳐 다시 꺼냈고, Task 1 파일은 처음과 같았다.
- `mktemp -d` 는 06-08 이 적은 대로 기본 임시 폴더를 썼다. 저장소 안에는 아무것도 남지 않았다. 다른 날짜의 `woody_measure_smoke_*` 폴더(10-13)는 이 plan 의 것이 아니라 건드리지 않았다.
- 네트워크 정지 없음. 끝난 뒤 `pgrep -f 'tool/smoke.dart'` · `pgrep -f 'project-name smoke_app'` 0건.

## User Setup Required

None - 네트워크(GitHub · pub.dev)만 필요하다.

## Next Phase Readiness

- 06-10 이 처리 기록에서 WR-01 · IN-02 를 `2c5b73b` 로, WR-03 · IN-01 을 `4286d48` 로 닫을 수 있다. 두 커밋 제목의 머리는 계획 글자 그대로다.
- REL-04 표시는 마지막으로 선언한 plan 이 한다.
- 세 task 뒤 `.planning` 밖 `git status --porcelain` 빈 출력, `fvm dart analyze` 깨끗, `fvm dart run tool/verify.dart` 10/10 (rc 0).

---
*Phase: 06-release*
*Completed: 2026-10-16*

## Self-Check: PASSED

- 파일: `tool/smoke.dart` 있음, 이 SUMMARY 있음
- 커밋: `2c5b73b` · `4286d48` 이 HEAD 의 조상, `git rev-list --count ca2cb78..HEAD` = 2
- 고친 판 Task 1 · 2 · 3 `<automated>` rc 0, `tool/smoke.dart` 밖 추적 파일 불변
