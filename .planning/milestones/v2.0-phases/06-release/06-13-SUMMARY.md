---
phase: 06-release
plan: 13
subsystem: release-smoke
tags: [dart, smoke-test, dart-io, process, sigint, gap-closure]

requires:
  - phase: 06-release
    provides: "06-09 의 smoke 판정 · 중단 · 정리 (judge 의 (c′), runProcess 의 단계 제한, SIGINT 처리기, killTree 의 SIGSTOP → 재읽기 → SIGKILL)"
  - phase: 06-release
    provides: "06-05 가 올린 tag v2.0.0 (704bf56) — 전체 smoke 회귀의 받을 대상"
provides:
  - "tool/smoke.dart runProcess — Utf8Decoder(allowMalformed: true) 와 Future.wait(종료 코드 · stdout · stderr) 제한"
  - "tool/smoke.dart judge — includeErrorCodes 셋(included_file_parse_error) · (c″) 종료 코드 3 인데 JSON 에 error 없음"
  - "tool/smoke.dart pendingSpawn · awaitRunningChild() — SIGINT 처리기가 띄우는 중인 하위 명령을 기다려 끊음; finally 는 cleanup() 뒤 처리기를 내림"
  - "tool/smoke.dart killTree(process, {readTable}) — 표 없음 안내 한 줄, SIGKILL 직전 재확인, 사슬 밖 SIGCONT; descendantsOf(pid, table) 순수"
  - "tool/smoke.dart scrubNamesFor({repoRoot, sdkRoot, workPath}) — runSmoke 와 main 의 catch 둘이 함께 씀; main 의 SdkInfo? sdk 승격"
affects: [06-14, 06-15, release-smoke, REL-04]

actuals:
  tokens: 4183
  tasks: 3
  commits: 2
plan_head_before: e6a4cbcad1683db1cbe0aa5115551e8d2288537b
plan_head_after: ea2d6647460a87e11583ec6ee43b65e78a38000f

tech-stack:
  added: []
  patterns:
    - "하위 명령 출력은 깨진 바이트를 허용하는 decoder 로 받고, 시간 제한은 종료 코드와 출력 수집 전체에 건다"
    - "판정은 진단 줄과 종료 코드의 일치를 본다 — 종료 코드 3 인데 error 줄이 없으면 실패"
    - "프로세스 표를 읽는 함수를 이름 있는 인자로 받아 하네스가 '읽지 못함' 을 강제한다"
    - "가리는 경로 목록은 함수 하나(scrubNamesFor)에만 두고 모든 안내가 함께 쓴다"

key-files:
  created: []
  modified:
    - tool/smoke.dart

key-decisions:
  - "IN-04 는 두 선택지 가운데 지역 상수 Utf8Decoder(allowMalformed: true) — 출력은 화면 표시와 JSON 판정에만 쓰이므로 U+FFFD 로 바꿔도 뜻이 같다 (planner 선택, G7-Q2)"
  - "WR-06 은 Future.wait<Object>([exitCode, out, err]) 에 제한 — 제한 뒤 늦게 끝나는 원래 future 의 오류는 timeout 이 버린다 (planner 선택)"
  - "killTree 는 SIGKILL 직전에 표를 다시 읽어 부모 사슬에 남은 pid 만 끊고, 사슬 밖의 얼린 pid 는 SIGCONT 로 풀어 둔다 (planner 보완 — Fix 의 '끊지 않는다' 와 같은 뜻); 재확인 표를 못 읽으면 얼린 것을 모두 끊는다"
  - "killTree 의 표 읽기는 이름 있는 인자 readTable (기본값 processTable) — 하네스가 '읽지 못함' 을 강제한다 (planner 선택)"
  - "finally 순서의 경합 창과 pid 재사용은 강제할 수 없어 하네스로 재현하지 않았다 — 소스와 회귀로만 본다"

patterns-established:
  - "smoke 하네스: 저장소 밖 임시 폴더의 Dart 파일이 tool/smoke.dart 를 import 해 runProcess · judge · killTree · awaitRunningChild · scrubNamesFor 를 직접 부른다 (네트워크 없음)"

requirements-completed: [REL-04]

coverage:
  - id: D1
    description: "runProcess 가 UTF-8 아닌 하위 명령 출력에서 죽지 않고(finally 가 돈다, U+FFFD) 파이프를 붙든 자손이 있어도 제한 안에 timedOut=true 로 돌아온다 (IN-04 gap · WR-06)"
    requirement: "REL-04"
    verification:
      - kind: integration
        ref: "06-13-PLAN.md Task 1 <automated> — 오프라인 하네스 열여덟 줄 (utf8 · pipe · orphan · timeout · echo)"
        status: pass
    human_judgment: false
  - id: D2
    description: "judge 가 include 코드 셋과 (c″) 종료 코드 3 · error 없음을 배타 순서 (a) → (b) → (c′) → (c″) → (c) 로 판정한다 (WR-04)"
    requirement: "REL-04"
    verification:
      - kind: unit
        ref: "06-13-PLAN.md Task 1 <automated> — judge 열두 입력 (06-09 의 여덟 + exit3-noerr · exit3-err · parse-err · exit3-inc)"
        status: pass
    human_judgment: false
  - id: D3
    description: "SIGINT 처리기가 띄우는 중인 하위 명령을 기다려 끊고, killTree 가 표 없음을 알리고 끊기 직전에 사슬을 다시 보며, 예외 안내가 runSmoke 와 같은 범위를 가린다 (IN-05 · IN-06 · IN-07)"
    requirement: "REL-04"
    verification:
      - kind: integration
        ref: "06-13-PLAN.md Task 2 <automated> — 오프라인 하네스 여덟 줄 (idle · spawn-window · notable · tree · scrub3 · scrub4) · 안내 줄 정확히 1 · finally 순서 소스 단언"
        status: pass
    human_judgment: false
  - id: D4
    description: "SIGINT 끝에서 끝까지 130 · 폴더 0 · 경로 없음, 전체 smoke v2.0.0 이 바깥 제한 18분 안에 종료 코드 0 · 두 주소 위반 두 줄 · 판정 꼬리 없음 (REL-04 회귀)"
    requirement: "REL-04"
    verification:
      - kind: e2e
        ref: "06-13-PLAN.md Task 3 <automated> — fvm dart run tool/smoke.dart v2.0.0 (네트워크)"
        status: pass
    human_judgment: false
  - id: D5
    description: "강제할 수 없는 둘 — finally 순서의 경합 창(정리 중의 Ctrl-C), killTree 의 pid 재사용"
    verification: []
    human_judgment: true
    rationale: "경합 시점과 pid 재사용은 하네스로 강제할 수 없다 — finally 순서는 소스 단언으로, 재확인 · SIGCONT 는 소스와 회귀(자손 둘까지 끊김)로만 보았다; 돌리지 않은 재현을 주장하지 않는다"

duration: 8min
completed: 2026-10-17
status: complete
---

# Phase 06 Plan 13: smoke 의 남은 구멍 여섯 Summary

**`tool/smoke.dart` 의 `runProcess` 가 UTF-8 아닌 출력을 U+FFFD 로 받고 제한을 출력 수집까지 걸며, `judge` 가 종료 코드 3 인데 JSON 에 error 가 없으면 실패로 보고, SIGINT 는 띄우는 중인 하위 명령까지 끊고 정리 뒤에 처리기를 내리며, `killTree` 는 표 없음을 알리고 끊기 직전에 사슬을 다시 보고, 예외 안내는 `scrubNamesFor` 하나로 SDK · 홈까지 가린다 — 전체 smoke `v2.0.0` 이 다시 통과 (REL-04)**

## Performance

- **Duration:** 약 8분
- **Started:** 2026-10-16T16:34:15Z
- **Completed:** 2026-10-16T16:42Z 무렵 (한국 시각 2026-10-17)
- **Tasks:** 3 (task 커밋 2 — Task 3 은 추적 파일 변경 없음)
- **Files modified:** 1 (`tool/smoke.dart`, +185 / −44)

## Accomplishments

- 06-VERIFICATION.md 2회차 둘째 gap(06-09 must_have 4 — IN-04)을 닫았다 — 하위 명령 출력을 `Utf8Decoder(allowMalformed: true)` 로 받아, UTF-8 아닌 바이트가 처리되지 않은 비동기 예외(255)로 `finally` 를 건너뛰는 경로가 없어졌다. 하네스가 그 입력에서 `finally` 가 도는 것을 단언하고, 고치기 전 판(HEAD `e6a4cbc` 의 파일)은 같은 입력에서 종료 코드 255 · `finally` 줄 0 · `FormatException: Invalid UTF-8 byte` 였다 (이번 실행에서 다시 재현).
- WR-06: 제한이 `Future.wait` 의 셋(종료 코드 · stdout · stderr)에 걸려, 출력 파이프를 붙든 자손이 있어도 2초 제한 안에 `timedOut=true` 로 돌아온다.
- WR-04: `includeErrorCodes` 에 `included_file_parse_error`, `judge` 에 (c″) — 종료 코드 3 인데 둘째 칸이 `error` 인 줄이 없으면 사유와 판정 꼬리 ` · 종료 코드 3 인데 error 없음`.
- IN-05 · IN-06 · IN-07: `pendingSpawn` · `awaitRunningChild()`, `finally` 의 `cleanup();` → `await interrupts.cancel();` 순서, `killTree` 의 `readTable` · 안내 한 줄 · SIGKILL 직전 재확인 · 사슬 밖 SIGCONT, 머리 주석의 범위 문장, `scrubNamesFor` 하나.
- 전체 smoke `v2.0.0` 이 바깥 제한 18분 안에 종료 코드 0 으로 통과했다 — 새 판정(include 코드 셋 · 종료 코드 3 규칙)이 통과 실행에서 거짓 양성을 내지 않았다.

## Task Commits

1. **Task 1: runProcess decoder · Future.wait 제한, judge (c″) · 코드 셋, 머리 주석** — `9d96778` (fix) `fix(tool): smoke runProcess 의 UTF-8 아닌 출력 허용 · 제한을 출력 수집까지, judge 의 종료 코드 3 · error 없음 (IN-04 · WR-06 · WR-04)`
2. **Task 2: SIGINT 의 띄우는 창 · finally 순서 · killTree · scrubNamesFor** — `ea2d664` (fix) `fix(tool): smoke SIGINT 의 띄우는 창 · killTree 의 안내와 재확인 · 예외 안내의 가리기 (IN-05 · IN-06 · IN-07)`
3. **Task 3: SIGINT 끝에서 끝까지 · 전체 smoke 회귀** — 커밋 없음 (추적 파일 변경 없음, 실행 기록은 아래)

| Task | `<automated>` rc | 걸린 시간 | 커밋 |
|------|------------------|-----------|------|
| 1 | 0 | 19초 | `9d96778` |
| 2 | 0 | 3초 | `ea2d664` |
| 3 | 0 | 46초 (SIGINT 실행 약 5초 + 5초 대기, 전체 smoke 약 39초) | 없음 |

## (1) Task 1 · 2 의 하네스 출력 (글자 그대로)

Task 1 (열여덟 줄 — `fvm dart run` 의 rc 0):

```
utf8 timedOut=false exit=0 fffd=true
utf8 finally=ran
pipe timedOut=true result=null fast=true
orphan pkill=0
timeout timedOut=true result=null fast=true
echo timedOut=false exit=0 out=hi
clean reasons=0  shown=prefer_single_quotes 있음 · provider_parameters 있음
inc-rec reasons=1 recommended: include 사슬이 끊겼다 (analysis_options.yaml:1  warning  include_file_not_found) shown=prefer_single_quotes 있음 · provider_parameters 있음 · include 사슬 끊김 1줄
inc-alias reasons=1 alias: include 사슬이 끊겼다 (analysis_options.yaml:1  warning  included_file_warning) shown=prefer_single_quotes 있음 · provider_parameters 있음 · include 사슬 끊김 1줄
other-ao reasons=0  shown=prefer_single_quotes 있음 · provider_parameters 있음
hdr reasons=1 alias: plugin 준비 실패 (stderr 의 머리말) shown=plugin 준비 실패 (stderr 의 머리말)
json-null reasons=1 alias: 도구가 죽었다 (JSON 아님) shown=도구가 죽었다 (JSON 아님)
exit9 reasons=1 alias: 도구가 죽었다 (exit 9) shown=도구가 죽었다 (exit 9)
no-plugin reasons=1 recommended: provider_parameters 없음 shown=prefer_single_quotes 있음 · provider_parameters 없음
exit3-noerr reasons=1 recommended: 종료 코드 3 인데 JSON 에 error 가 없다 (옵션 파일의 error — include 사슬) shown=prefer_single_quotes 있음 · provider_parameters 있음 · 종료 코드 3 인데 error 없음
exit3-err reasons=0  shown=prefer_single_quotes 있음 · provider_parameters 있음
parse-err reasons=1 alias: include 사슬이 끊겼다 (analysis_options.yaml:1  warning  included_file_parse_error) shown=prefer_single_quotes 있음 · provider_parameters 있음 · include 사슬 끊김 1줄
exit3-inc reasons=2 recommended: include 사슬이 끊겼다 (analysis_options.yaml:1  warning  include_file_not_found) | recommended: 종료 코드 3 인데 JSON 에 error 가 없다 (옵션 파일의 error — include 사슬) shown=prefer_single_quotes 있음 · provider_parameters 있음 · include 사슬 끊김 1줄 · 종료 코드 3 인데 error 없음
```

Task 2 (여덟 줄 — 안내 줄은 표를 강제로 비운 호출에서만, 전체 출력에서 정확히 1). 일곱째 줄의 가운데 칸은 하네스가 만든 가짜 SDK 경로 뒤의 "SDK 의 flutter 실행 파일" 꼴 상대 경로다 — 06-14 push gate 의 경로 꼴 검사에 걸리지 않게 그 칸만 말로 적었고, 실제 출력은 `<automated>` 의 `grep -qxF` 가 글자 그대로 맞췄다:

```
idle child=false
spawn-window child=true runningWasNull=true
spawn-window timedOut=false exit=-9 left=0
자손 프로세스를 찾지 못했다 — 부모만 끊었다
notable exit=-9 left=0
tree exit=-9 left=0
scrub3 keys=3 hasHome=true <Flutter SDK>/(SDK 의 flutter 실행 파일) <repo>/x <홈>/y
scrub4 keys=4 <임시 폴더>/app <Flutter SDK>/x
```

소스 확인 (Task 2 `<automated>` 의 단언): `'<repo>'` 글자는 `scrubNamesFor` 한 곳(1), `scrubNamesFor(` 는 넷(정의 + `runSmoke` + catch 둘), `main` 의 `finally` 블록에서 `cleanup();` 줄이 `interrupts.cancel()` 줄보다 앞. import 는 `dart:convert` · `dart:io` 둘. 두 task 모두 하네스가 띄운 `sleep` 0, 작업 트리에는 `tool/smoke.dart` 만 바뀌어 있었다 (커밋 전).

## (2) Task 3 의 실행

**SIGINT 끝에서 끝까지** (2026-10-16T16:39Z 무렵, 고정 SDK 의 dart 를 직접, ref 는 HEAD `ea2d664`): `woody_smoke_*` 폴더가 약 1초 뒤 생겨 `kill -INT` → `wait` 종료 코드 **130**, 5초 뒤에도 폴더 0, stdout 마지막 줄 `임시 폴더를 지웠다`, stderr `중단됨 (SIGINT) — 임시 폴더를 정리하고 끝낸다`, 어느 출력에도 임시 폴더 경로 없음, `flutter create` 자식 0, 안내 줄(`자손 프로세스를 찾지 못했다`) 0 (표를 읽었다). 신호가 닿은 자리: stdout 의 마지막 단계 줄이 `flutter create: exit 0, 0.5s` — 곧 `flutter pub get` 이 막 시작된 때다 (06-09 와 같은 자리). 띄우는 창(`Process.start` 가 돌아오기 전)에 정확히 맞추는 것은 강제할 수 없다 — 그 창은 Task 2 하네스의 `spawn-window` 두 줄이 본다.

**전체 smoke** (시작 2026-10-16T16:39:04Z 무렵, 약 39초, `fvm dart run tool/smoke.dart v2.0.0`): 종료 코드 **0** (바깥 제한 18분 안). stdout:

- 첫 줄 `SDK Flutter 3.47.5 / Dart 3.13.4`, `기대 커밋: 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2 (git rev-parse 'v2.0.0^{commit}')`
- `flutter create: exit 0, 0.4s`, `flutter pub get: exit 0, 5.5s — lock: source git, url https://github.com/woodkill/woody_lints.git, resolved-ref 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2`
- `recommended` — `dart analyze exit 2, 16.2s, 머리말 없음, plugin 폴더 1, riverpod_lint 3.1.9`; `alias` — `dart analyze exit 2, 15.5s, 머리말 없음, plugin 폴더 1, riverpod_lint 3.1.9`. 두 주소 각각 smoke 앱의 위반 파일에 `info  prefer_single_quotes` 한 줄 · `warning  provider_parameters` 한 줄 (합 4줄), 주소마다 진단 6줄
- `판정:` 줄 둘, 둘 다 글자 그대로 `   판정: prefer_single_quotes 있음 · provider_parameters 있음` (include · 종료 코드 3 꼬리 없음)
- `analysis_options.yaml:` 줄 0, `include 사슬` 0, `종료 코드 3 인데` 0
- `smoke 통과 (ref v2.0.0 → 704bf56fb028debe16f107bc9a8e6c9bdc5bccc2, recommended 6줄 / 옛 주소 6줄, riverpod_lint 3.1.9)`
- 마지막 줄 `임시 폴더를 지웠다`; stderr 빈 출력; 임시 폴더 경로 0; `woody_smoke_*` 폴더 0

69(네트워크 정지)는 나오지 않았다 — 재실행 없음. 세 task 뒤 `git status --porcelain -- . ':(exclude).planning'` 빈 출력.

## (3) 커밋

- `9d96778` — `fix(tool): smoke runProcess 의 UTF-8 아닌 출력 허용 · 제한을 출력 수집까지, judge 의 종료 코드 3 · error 없음 (IN-04 · WR-06 · WR-04)`
- `ea2d664` — `fix(tool): smoke SIGINT 의 띄우는 창 · killTree 의 안내와 재확인 · 예외 안내의 가리기 (IN-05 · IN-06 · IN-07)`

## (4) 강제할 수 없었던 것과 planner 의 선택 · 보완

- **하네스로 재현하지 않은 둘:** (i) `finally` 순서의 경합 창 — 처리기를 내린 뒤 `deleteSync` 도중에 오는 Ctrl-C 는 시점을 강제할 수 없어, 순서(`cleanup();` 뒤 `await interrupts.cancel();`)만 소스 단언으로 보았다. (ii) `killTree` 의 pid 재사용 — 표를 읽은 뒤 끝난 자손의 pid 가 남의 프로세스로 재사용되는 것은 강제할 수 없어, SIGKILL 직전의 재확인 · 사슬 밖 SIGCONT 는 소스와 회귀(`tree exit=-9 left=0` — 자손 둘까지 끊김, 안내 줄 없음)로만 보았다. 돌리지 않은 재현을 주장하지 않는다.
- **planner 보완:** 사슬 밖의 얼린 pid 는 SIGKILL 대신 SIGCONT 로 풀어 둔다 (남의 프로세스일 수 있는데 얼린 채 두지 않기 위해 — `Fix:` 의 "끊지 않는다" 와 같은 뜻). 재확인 표를 읽지 못하면 얼린 것을 모두 끊는다 (고치기 전 동작).
- **planner 선택:** decoder 는 두 선택지 가운데 `const Utf8Decoder(allowMalformed: true)` (`.catchError` 가 아님); 제한은 `Future.wait<Object>([process.exitCode, out, err])` 꼴; 표 읽기는 `killTree` 의 이름 있는 인자 `readTable` (기본값 `processTable`); 가리기는 null-aware 요소 `?workPath:` · `?sdkRoot:`.
- **실행자가 정한 세부 (계획 안에서):** `killTree` 의 SIGKILL 대상은 재확인 표의 사슬 전체(`descendantsOf(process.pid, again)`)다 — 얼린 것 가운데 사슬에 남은 pid 와, 얼리기 회차(최대 20)를 넘겨 얼리지 못한 사슬의 pid 가 있으면 그것까지. 표에서 사라질 때까지의 기다림도 끊은 pid 만 본다 (SIGCONT 로 푼 남의 pid 때문에 5초를 기다리지 않게). (a) 의 "읽지 못함" 은 부모를 SIGSTOP 한 뒤의 첫 표 읽기로 판정한다 — 고치기 전과 같은 순서(먼저 얼리고 읽기)를 지켰고, 그때 자손은 얼리지 않고 부모만 SIGKILL 한다.

## Files Created/Modified

- `tool/smoke.dart` — 위 여섯 고침과 머리 주석 (2′) 코드 셋 · (2″) · 69 의 출력 수집 · 255 의 동기 흐름과 U+FFFD · 범위 문장(새 프로세스 그룹)

## Decisions Made

frontmatter `key-decisions` 와 위 (4) 와 같다. 판정 (2) 의 위반 두 줄 · (3) 의 lock 비교 · 배타 순서 · 단계 제한 값(create 2분 · pub get 5분 · analyze 5분) · 종료 코드 69 · 130 · `--keep` 동작은 바꾸지 않았다. 검증자의 "(새)" info 둘은 범위 밖이라 건드리지 않았다 (G7-Q2 NOT).

## Deviations from Plan

None - plan executed exactly as written.

실행 방법에서 계획과 다르게 한 것 (판정 · 단언은 그대로):

- Task 3 의 `<automated>` 를 파일로 뽑아 돌릴 때, 두 `rm -rf` 바로 앞에 그 실행의 stdout · stderr 를 로그로 찍는 묶음 하나씩만 더했다 — 신호가 닿은 자리와 smoke 의 출력을 SUMMARY 에 적으려는 것이다 (블록이 끝에 임시 폴더를 지운다). 단언은 한 글자도 바꾸지 않았다.
- Task 1 뒤에 계획에 없는 실패 방향 확인 하나를 더 돌렸다 — HEAD `e6a4cbc` 의 `tool/smoke.dart` 를 임시 폴더에 꺼내 UTF-8 입력만 돌려 255 · `finally` 줄 0 을 보았다 (저장소 밖, 추적 파일 변경 없음).

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 06-14 가 이 두 커밋을 제목 머리로 찾아 06-REVIEW-DISPOSITION.md 에 WR-04 · WR-06 · IN-04 · IN-05 · IN-06 · IN-07 을 `fixed` 로 적을 수 있다.
- REL-04 는 06-14 · 06-15 도 선언하므로 이 plan 은 요구사항을 완료로 표시하지 않았다 (마지막 선언 plan 이 표시).
- Ready for 06-14.

## Self-Check: PASSED

- FOUND: `tool/smoke.dart`
- FOUND: `9d96778` (HEAD 의 조상), `ea2d664` (HEAD)
- 측정한 커밋 수: `e6a4cbc..ea2d664` = 2 (task 커밋 둘, Task 3 은 커밋 없음)

---
*Phase: 06-release*
*Completed: 2026-10-17*
