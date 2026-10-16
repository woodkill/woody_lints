---
phase: 06-release
reviewed: 2026-10-16T17:45:00Z
depth: standard
files_reviewed: 8
files_reviewed_list:
  - .claude/skills/spike-findings-woody-lints/SKILL.md
  - .claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md
  - .claude/skills/spike-findings-woody-lints/references/rule-status-check.md
  - VERSIONING.md
  - example/README.md
  - pubspec.yaml
  - tool/smoke.dart
  - tool/verify.dart
findings:
  critical: 0
  warning: 0
  info: 2
  total: 2
status: issues_found
---

# Phase 6: Code Review Report

**Reviewed:** 2026-10-16T17:45:00Z
**Depth:** standard
**Files Reviewed:** 8
**Status:** issues_found

## Summary

범위는 `git diff 724d17a..HEAD` 의 여덟 파일이다. gap 수정 2회차의 두 갈래를 봤다.
- 06-12 (`85e1b0d` · `317d3ff`, 그리고 `e6a4cbc` 의 이스케이프 되돌림): `tool/verify.dart` 의 `topHeadingLine` · `changelogTopOf` · `checkVersionAgreement` 블록, `VERSIONING.md` 한 줄, `pubspec.yaml` 19 · 21행, skill 세 줄, `example/README.md` 의 M107 ~ M115
- 06-13 (`9d96778` · `ea2d664`): `tool/smoke.dart` 의 decoder, `Future.wait` 제한, `judge` (c″), `pendingSpawn` · `awaitRunningChild`, `finally` 순서, `killTree` 의 안내 · 재확인 · SIGCONT, `scrubNamesFor`

실험은 모두 scratchpad 아래 `mktemp -d` 폴더 하나에서 했다. `git archive HEAD` 를 풀고 그 안에서 `fvm dart pub get --no-example` 을 먼저 돌렸다. 복사본 밖의 하네스 Dart 파일 셋이 복사본의 `tool/verify.dart` · `tool/smoke.dart` 를 import 해 함수를 직접 불렀고, 고정 SDK(Dart 3.13.4)로 돌렸다. 옵션 파일 진단이 JSON 에 오는지는 같은 폴더의 작은 프로젝트 넷에 `dart analyze` 를 돌려 쟀다. 네트워크 요청(GitHub 렌더 API 포함)은 하지 않았다. 전체 `tool/verify.dart` · `tool/smoke.dart` 실행은 하지 않았다. 작업 트리는 건드리지 않았고 끝에 폴더를 지웠다.

CHANGELOG 쪽은 닫혔다. 지난 WR-02 · WR-05 의 입력은 이제 모두 `[3/10]` 블록으로 실패한다. 첫 줄 규칙의 "같은 꼴의 다른 입력" 도 따로 넣어 봤다. 결과는 둘로 갈렸다.
- 첫 줄 정규식에서 실패: U+2028 이 든 첫 줄, ` - ` 뒤가 U+00A0 인 첫 줄
- 둘째 reader 에서 실패: 닫는 `#` 하나
- 통과: CR 하나 줄바꿈, 뒤 탭, 둘째 줄 `=`, 첫 줄 끝의 닫지 않은 `<!--` (`## 2.0.0 - 2026-10-15 <!--`)

마지막 꼴은 평소 모드에서 통과한다. 하지만 버전은 정규식이 숫자 셋으로만 잡고, tag 모드에서는 날짜 자리 `2026-10-15 <!--` 가 `YYYY-MM-DD` 검사에서 실패한다. 그래서 어느 꼴도 거짓 통과가 아니다. 디스크의 U+FEFF 는 `readAsStringSync` 가 뗀다는 주석의 주장도 확인했다 (BOM 을 붙인 파일을 읽은 글자가 U+FEFF 로 시작하지 않고 길이가 원문과 같았다).

CHANGELOG 최상단과 `pubspec.yaml` 의 version 을 읽는 다른 자리도 훑었다. `tool/smoke.dart` 는 둘 다 읽지 않는다. `VERSIONING.md` 「릴리스 절차」 5 단계는 `git show vX.Y.Z:CHANGELOG.md` 의 첫 줄을 보라고 한다. 1 · 10 단계도 첫 줄 규칙과 맞는다. 문서 쪽에서는 하나가 남았다. `example/README.md` 의 06-08 소절 읽는 법 (5) 가 아직 "지금은" 이라고 말하는데, 06-12 뒤로는 사실이 아니다 (IN-10).

smoke 쪽의 여섯 고침은 하네스로 다시 확인했다.
- UTF-8 아닌 출력: `finally` 가 돌고 U+FFFD 로 바뀐다
- `sleep 7 & echo hi` 를 2초 제한으로: 4초 안에 `timedOut=true`
- 종료 코드 3 인데 error 줄 없음: 사유 하나
- `scrubNamesFor` 의 키: 넷

새 발견은 하나다. `killTree` 의 재확인(IN-06 (c) 의 고침)이 pid 재사용을 막으려다, 얼린 뒤 중간 프로세스가 끝나 사슬에서 빠진 **자기 자손**을 SIGCONT 로 풀어 살려 둔다. 고치기 전 판은 그 자손을 끊었다 (IN-11).

발견으로 적지 않은 관찰이 둘 있다.
- `judge` 의 (c″) 는 JSON 에 다른 error 줄이 하나라도 있으면 가려진다. 하네스에서 종료 코드 3, 위반 두 줄, 다른 파일의 error 한 줄을 주었더니 `reasons=[]` 였다. 지금 smoke 앱은 error 를 내지 않는다 (06-13 의 전체 실행이 종료 코드 2). 그래서 옵션 파일 error 와 코드 error 가 같이 나야 가려진다.
- 옵션 파일 진단 측정에서, include 받는 파일의 `analyzer: exclude:` 를 목록이 아니라 맵으로 쓰면 진단도 없고 종료 코드도 0 이었다. 이번 diff 밖의 동작이라 아래 「범위 밖」 에 적었다.

## 지난 리뷰의 발견 16건 — 지금 상태

| ID | 지금 상태 | 근거 |
|----|-----------|------|
| CR-01 | 닫힘 | `tool/verify.dart:1660-1671` (`pubspecYamlVersion`) · `:2345-2352` 그대로. 복사본에서 겹따옴표 여러 줄 스칼라 안의 열 0 `version: 2.0.0` + 실제 `version: 2.0.0-dev` 를 넣었다. `checkShippedComposition` 이 평소 `passed=false` ((h) 블록), `v2.0.0` 에서 `passed=false` ((h) 블록 + `` … (2.0.0-dev) 이 다르다 — `-dev` 꼬리가 남아 있다. ``) 를 냈다 (직접 재현) |
| WR-01 | 닫힘 | `tool/smoke.dart:795-804` 의 (c′) 그대로. 고정 SDK 측정에서 중첩 include 의 없는 파일은 `include_file_not_found`, 틀린 `errors` 값은 `included_file_warning` 으로 JSON 의 `analysis_options.yaml` 줄에 왔다 |
| WR-02 | 닫힘 | `tool/verify.dart:1693` (`topHeadingLine`) · `:1743-1748`. 복사본의 `CHANGELOG.md` 맨 앞에 `2.1.0 - 미출시` / `-` / 빈 줄을 넣었다. 평소 · `v2.0.0` 모두 `passed=false`, 블록 `` … 꼴이 아니다: `2.1.0 - 미출시` `` (직접 재현). 지난 Issue 의 문서 문장들(`pubspec.yaml` 21행, 문서 주석의 "GitHub 화면과 같다" · "유일한 꼴")도 고쳐졌다 |
| WR-03 | 닫힘 | `tool/smoke.dart:497-544` 의 단계별 제한 그대로 (`:732` · `:932` · `:961`) |
| WR-04 | 닫힘 | `tool/smoke.dart:106-110` · `:806-818`. 하네스에서 종료 코드 3 · 위반 두 줄 · error 줄 없음 → 사유 하나 `종료 코드 3 인데 JSON 에 error 가 없다 …`. 고정 SDK 측정에서 include 받는 파일의 깨진 YAML 은 여전히 JSON 에 없고 종료 코드 3 이었다 — (c″) 가 잡는 꼴. 다른 error 줄과 함께면 가려지는 점은 Summary 의 관찰 |
| WR-05 | 닫힘 | 같은 첫 줄 규칙. 복사본에서 `pubspec.yaml` 을 `2.0.1` 로, `CHANGELOG.md` 맨 앞에 `> <!--` / `## 2.0.1 - 2026-10-16` / `-->` / 빈 줄을 넣었다. `v2.0.1` · 평소 모두 `passed=false`, 블록 `` … 꼴이 아니다: `> <!--` `` (직접 재현) |
| WR-06 | 닫힘 | `tool/smoke.dart:528-530`. 하네스에서 시스템 셸로 `sh -c 'sleep 7 & echo hi'` 를 `runProcess` (제한 2초) 로 돌림 → `timedOut=true`, 4초 안. 남은 고아 프로세스는 머리 주석 `:42-43` 이 범위로 밝힌다 |
| IN-01 | 닫힘 | `tool/smoke.dart:1136-1141` 의 `finally` · `:1088-1099` 의 처리기 그대로 |
| IN-02 | 닫힘 | `analyzeExitCodes.contains(` 는 `judge` (`tool/smoke.dart:789`) 한 곳뿐이다 |
| IN-03 | 닫힘 | `pubspecReleaseVersion` 이 `releaseHead(pubspecVersionText(repoRoot))` 한 줄이다 (`tool/verify.dart:1623-1625`) |
| IN-04 | 닫힘 | `tool/smoke.dart:525-527`. 하네스 `printf "\377\n"; sleep 1` 을 `try/finally` 안에서 → `exit=0` · U+FFFD 있음 · `finally=ran` |
| IN-05 | 닫힘 | `tool/smoke.dart:505-523` (`pendingSpawn`) · `:363-373` (`awaitRunningChild`) · `:1139-1140` (`cleanup();` 이 `await interrupts.cancel();` 앞). 읽기로 판정했다. 띄우는 창의 SIGINT 에서는 본 흐름이 먼저 깨어 `runningChild` 를 정하고 멈추며, 처리기가 그 프로세스를 끊는다. `deleteSync` 는 동기라, 그 도중의 신호는 정리가 끝난 뒤에야 처리된다 |
| IN-06 | 닫힘 | (a) `tool/smoke.dart:439-445` 의 안내 한 줄, (b) 머리 주석 `:42-43` 의 범위 문장, (c) `:459-470` 의 재확인. 다만 (c) 의 고침이 새 문제를 냈다 — IN-11 로 따로 적었다 |
| IN-07 | 닫힘 | `scrubNamesFor` (`tool/smoke.dart:339-348`) 를 `runSmoke` (`:913`) 와 `main` 의 catch 둘 (`:1121` · `:1129`) 이 쓴다. 하네스에서 키 넷 |
| IN-08 | 닫힘 (쓰인 그대로는 해당 없음) | 판은 여전히 고정되지 않았다 (`pubspec.yaml:24-25`). 그러나 지난 Issue 의 해악은 "GitHub 화면과 같게 읽는다" 는 판정이 7.3.1 실측에 기댄다는 것이었다. 첫 줄 규칙 아래에서 버전은 정규식이 숫자 셋으로 잡는다 (`tool/verify.dart:1693`). tag 모드의 날짜 자리는 `^\d{4}-\d{2}-\d{2}$` 다 (`:2360`). 해석기는 두 reader 를 갈라 실패시킬 수만 있다. 남은 거짓 실패 쪽은 「범위 밖」 에 적었다 |
| IN-09 | 닫힘 | 다섯 자리가 모두 "YAML 대조와 `pubspec.yaml` 의 version 읽기" 로 고쳐졌다 — skill 세 줄 (`SKILL.md:52`, `analyze-run-and-verdict.md:13`, `rule-status-check.md:14`), `pubspec.yaml:19`, `tool/verify.dart:34-36` |

## Narrative Findings (AI reviewer)

## Info

### IN-10: `example/README.md` 06-08 소절의 읽는 법 (5) 가 "지금은" `# Changelog` 머리말이 통과한다고 말한다 — 06-12 뒤로는 실패한다 (M113)

**File:** `example/README.md:707`, `example/README.md:766`, `example/README.md:706`, `example/README.md:11`
**Issue:** 06-12 는 06-08 소절의 읽는 법 (2) · (3) (`:704` · `:705`) 끝에 "2026-10-16 에 다시 고침" 을 덧붙였다. 새 소절의 (6) (`:766`) 도 "(2) · (3) 은 그때의 기록이다" 라고 둘만 짚는다. 그런데 바로 아래 (5) (`:707`) 는 손대지 않았다. 문장은 "**지금은** 첫 h2 를 읽고, `# Changelog` 머리 줄의 결과(`passed=true`)는 같다" 이다. 같은 파일의 M113 (`:728`) 은 그 입력이 06-12 뒤로 세 경로 모두 `[3/10]` 블록으로 실패한다고 적는다. 그래서 한 문서 안에서 현재형 두 문장이 서로 반대다. 몇 달 뒤 이 문서를 읽고 CHANGELOG 에 머리말을 넣으면, 통과를 예상했다가 `[3/10]` 실패를 만난다.

같은 소절의 다른 문장도 지금 코드와 다르다.
- (4) (`:706`): "떼지 않은 문자열은 첫 `## ` 줄이 단락이 되어 다음 h2 를 읽는다". 06-08 판의 동작이다. 지금 판에서는 U+FEFF 가 남은 첫 줄이 `topHeadingLine` 에 맞지 않아 실패한다.
- `:11`: 두 개발용 의존성의 쓰임을 "YAML 대조 · CHANGELOG 최상단 제목 읽기" 라고 적는다. 지금 `package:markdown` 은 최상단 제목을 읽는 쪽이 아니라 첫 줄과 견주는 둘째 reader 이고, `package:yaml` 은 version 읽기에도 쓴다. "만" 이 없어 IN-09 처럼 규칙으로 읽힐 위험은 작다.

**Fix:** (5) 끝에 (2) · (3) 과 같은 꼴로 덧붙인다. 예: `— **2026-10-16 에 다시 고침 (06-12):** 지금은 첫 줄 규칙이라 `# Changelog` 머리말은 실패한다 (아래 M113).` (6) 의 "(2) · (3)" 은 "(2) · (3) · (4) · (5)" 로 넓힌다. `:11` 의 괄호는 "YAML 대조 · `pubspec.yaml` 의 version 읽기 · CHANGELOG 첫 줄과 Markdown 첫 h2 의 대조" 로 고친다.

### IN-11: `killTree` 의 SIGKILL 직전 재확인이, 얼린 뒤 중간 프로세스가 끝나 사슬에서 빠진 자기 자손을 SIGCONT 로 풀어 살려 둔다

**File:** `tool/smoke.dart:453-456` (얼리기), `tool/smoke.dart:459-470` (재확인 · SIGKILL · SIGCONT), `tool/smoke.dart:427-430` (문서 주석)
**Issue:** 재확인은 SIGKILL 대상을 "다시 읽은 표에서 아직 `process.pid` 사슬에 있는 pid" 로 줄인다. 얼린 pid 가운데 사슬 밖의 것은 "재사용되어 남의 프로세스일 수 있다" 며 SIGCONT 로 푼다. 그런데 얼린 pid 가 사슬에서 빠지는 흔한 경우는 pid 재사용이 아니다. 표를 읽은 뒤 SIGSTOP 이 닿기 전에 **중간 프로세스**가 끝나는 경우다. 그러면 그 아래의 자손은 pid 1 로 옮겨 간다. 얼리기는 그 자손에게 그대로 닿지만(살아 있으므로), 재확인 표에서는 사슬 밖이 된다. 그래서 끊지 않고 풀어 준다.

Ctrl-C 는 전경 프로세스 그룹 전체에 SIGINT 를 보낸다. 그래서 처리기가 `killTree` 를 도는 바로 그때 `flutter` · `dart` 중간 프로세스도 SIGINT 로 끝나는 중일 수 있다. 이 경로는 pid 재사용(수 ms 사이에 같은 번호가 다시 배정됨)보다 훨씬 그럴듯하다.

하네스로 재현했다.
- 프로세스: 시스템 셸 안의 셸 안의 `sleep 30` — `sh -c 'sh -c "sleep 30; :"; :'` 꼴 (P → A → B)
- `readTable` 주입: 첫 호출에서 실제 표를 읽은 직후 A 를 SIGKILL 하고, B 의 부모가 A 가 아니게 될 때까지 기다린 뒤 읽어 둔 표를 돌려준다
- `killTree(proc, readTable: …)` 결과: B 가 살아 있다 — `alive=true`, 상태 `S` (얼려 있지 않음), 부모 pid 1, 표 읽기 4번

고치기 전 판(`ea2d664` 의 부모)은 얼린 것을 모두 SIGKILL 했다 (`for (final pid in frozen) Process.killPid(pid, ProcessSignal.sigkill);`). 그래서 이 입력에서 B 를 끊었다. 06-09 Deviations 가 본 "지운 임시 폴더를 다시 만드는 자식" 이 이 경로로 돌아올 수 있다. 끊긴 받기 · analysis server 가 임시 폴더를 지운 뒤에도 돈다. 머리 주석 `:42-43` 의 "부모가 먼저 끝난 자손은 끊지 못한다" 는 처음 표를 읽기 **전**에 옮겨 간 자손의 범위다. 이미 찾아 얼린 자손을 일부러 푸는 것은 그 범위 밖이고, 화면에도 아무 말이 없다. 경합 창이 좁아 드물고, IN-06 과 같은 성격이라 INFO 로 둔다.

**Fix:** 재사용의 근거를 SIGSTOP 의 성공 여부로 바꾼다. `Process.killPid` 는 끝난 pid 에 `false` 를 돌려준다. 얼리기에 성공한 프로세스는 스스로 끝날 수 없으므로 번호가 재사용되지 않는다. 그러니 성공한 것만 기록하고, 그중 아직 표에 있는 것은 사슬과 상관없이 끊는다. SIGCONT 는 필요 없어진다.

```dart
    for (final pid in fresh) {
      // 얼리지 못한 pid(이미 끝남)는 기록하지 않는다 — 번호가 재사용될 수 있는 것은 끝난 pid 뿐이다.
      if (Process.killPid(pid, ProcessSignal.sigstop)) frozen.add(pid);
    }
  ...
  final again = readTable();
  final doomed = again == null
      ? frozen
      : {
          // 얼린 것은 사슬에서 빠졌어도(중간 프로세스가 먼저 끝남) 자기 자손이다.
          ...frozen.where(again.containsKey),
          ...descendantsOf(process.pid, again),
        };
  process.kill(ProcessSignal.sigkill);
  for (final pid in doomed) {
    Process.killPid(pid, ProcessSignal.sigkill);
  }
```

문서 주석 (c) (`:427-430`) 와 머리 주석의 범위 문장도 이에 맞춰 고친다. 하네스에는 위의 "표를 읽은 직후 중간 프로세스를 끝내는 `readTable`" 입력을 더한다.

## 범위 밖으로 둔 것 (ID 없음)

- **IN-08 의 남은 쪽 (소유자 결정 G7-Q1 로 미룸).** `markdown` · `yaml` 은 여전히 `^` 범위이고 루트 lock 은 커밋하지 않는다. 첫 줄 규칙 아래에서 남은 효과는 거짓 실패뿐이다. 새 판의 해석기가 첫 줄의 제목 글자를 달리 읽으면, 같은 커밋이 CI 에서 문구 B 블록으로 실패할 수 있다. 거짓 통과 방향은 없다 (위 표의 IN-08 근거).
- **`.claude/CLAUDE.md` 의 낡은 줄 (D-09 로 milestone 끝에 미룸).** 예: "루트 `analysis_options.yaml` 의 exclude 가 반드시 유지되어야 한다", Flutter 3.41.2 · `riverpod_lint ^3.1.3` · `1.3.0` 상태를 적은 줄들. 같은 뜻의 `SKILL.md:49` "루트 `analysis_options.yaml` 은 기존 exclude 항목(`lib/analysis_options.yaml`)을 그대로 둔다" 도 같다.
- **include 받는 옵션 파일의 `analyzer: exclude:` 를 맵으로 쓴 꼴.** 고정 SDK(Dart 3.13.4)의 작은 프로젝트에서 이 꼴은 진단이 하나도 없었고 종료 코드도 0 이었다. 그러면 `tool/smoke.dart` 의 (2′) · (2″) 는 받는 쪽에서 `lib/codegen.yaml` 의 exclude 가 이 꼴로 깨진 것을 볼 수 없다. 이번 diff 가 바꾼 동작이 아니다. `tool/verify.dart` 의 정답지 단계가 생성 파일 샘플로 저장소 쪽에서 잡는지는 재지 않았으므로 발견으로 적지 않았다.
- 지난 리뷰 「범위 밖」 의 front matter 꼴(`---` 로 시작하는 CHANGELOG)은 이제 첫 줄 규칙에서 실패한다. 더 볼 것이 없다.

---

_Reviewed: 2026-10-16T17:45:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
