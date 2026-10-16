---
phase: 06
review: 06-REVIEW.md
titles: json
findings:
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "`changelogTop` 이 들여 쓴 ATX 제목 · setext 제목 · U+FEFF 머리를 제목으로 보지 않아, 평소 모드가 아래의 옛 항목과 견주어 통과한다"
  - id: WR-04
    severity: warning
    disposition: fixed
    title: "smoke 가 include 받는 파일의 깨진 YAML(`included_file_parse_error`)을 보지 못한다 — JSON 에 진단이 없고 종료 코드 3 만 남는다"
  - id: WR-05
    severity: warning
    disposition: fixed
    title: "인용 · 목록 · 단락 안에서 연 `<!--` 뒤의 `## ` 를 `changelogTop` 이 최상단으로 읽는다 — GitHub 화면에는 제목이 없는데 tag 모드가 통과한다"
  - id: WR-06
    severity: warning
    disposition: fixed
    title: "smoke 의 시간 제한이 하위 명령의 종료에만 걸려, 출력 파이프를 붙든 자손이 있으면 제한을 넘겨 기다린다"
  - id: IN-04
    severity: info
    disposition: fixed
    title: "하위 명령의 출력이 UTF-8 이 아니면 처리되지 않은 비동기 예외(255)로 끝나 `finally` 의 정리를 건너뛴다"
  - id: IN-05
    severity: info
    disposition: fixed
    title: "SIGINT 처리기의 경합 창 둘 — 띄우는 중의 하위 명령을 기다리지 않고 끝내고, `finally` 는 처리기를 정리 전에 내린다"
  - id: IN-06
    severity: info
    disposition: fixed
    title: "`killTree` 가 자손을 놓쳐도 알리지 않는다 — `/bin/ps` 실패 · 먼저 끝난 부모의 자손 · pid 재사용"
  - id: IN-07
    severity: info
    disposition: fixed
    title: "`main` 의 예외 안내가 SDK 경로 · 홈 폴더를 가리지 않는다"
  - id: IN-08
    severity: info
    disposition: deferred
    title: "`markdown` · `yaml` 의 범위 제약(`^`)과 커밋하지 않는 루트 lock 때문에, CI 가 받는 해석기 판이 고정되지 않는다"
  - id: IN-09
    severity: info
    disposition: fixed
    title: "의존성 문장이 \"`package:yaml` 은 YAML 대조에만\" 이라고 하나, (i) 는 YAML 값을 직접 쓴다"
  - id: CR-01
    severity: critical
    disposition: fixed
    title: "tag 모드가 정확히 견주는 version 원문을 YAML 과 견주는 확인이 없어, `-dev` 가 남은 pubspec 이 `--tag` 검사를 통과한다"
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "smoke 가 include 사슬의 끊김(`include_file_not_found`)을 보고도 통과한다 — 두 주소의 codegen 부분은 판정에 없다"
  - id: WR-03
    severity: warning
    disposition: fixed
    title: "smoke 의 하위 명령에 시간 제한이 없어, 받기 · plugin 준비가 멈추면 끝없이 기다린다"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "smoke 의 임시 폴더 정리가 `finally` 밖이라, 세 예외 밖의 throw · 중단 신호에서 폴더가 남는다"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "`runSmoke` 가 `judge` 의 앞 두 조건을 다시 적는다"
  - id: IN-03
    severity: info
    disposition: fixed
    title: "`pubspecVersionText` 가 `pubspecReleaseVersion` 의 줄 찾기를 따로 다시 짠다"
open: 0
total: 16
recorded: 2026-10-16T11:25:46.334Z
---

# Phase 06: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-02 | warning | fixed | 06-12-PLAN.md Task 1 (85e1b0d) — changelogTop 이 CHANGELOG.md 의 첫 줄(U+FEFF 뗀 뒤)을 엄격한 최상단 제목 ## X.Y.Z - 날짜 자리 로 요구하고 package:markdown 의 첫 h2 와 같아야 통과 — 한 글자 밑줄의 setext 는 첫 줄이 제목이 아니라 [3/10] 블록으로 실패; M107 ~ M109 (소유자 결정 G7-Q1 (나)) |
| WR-04 | warning | fixed | 06-13-PLAN.md Task 1 (9d96778) — judge 가 종료 코드 3 인데 JSON 에 error 줄이 없으면 실패 사유를 더하고 includeErrorCodes 에 included_file_parse_error 를 더함 (소유자 결정 G7-Q2) |
| WR-05 | warning | fixed | 06-12-PLAN.md Task 1 (85e1b0d) — 같은 첫 줄 규칙 — 인용 · 목록 · 단락 안에서 연 HTML 주석 여는 글자는 첫 줄이 제목이 아니라 [3/10] 블록으로 실패; M110 ~ M112 (소유자 결정 G7-Q1 (나)) |
| WR-06 | warning | fixed | 06-13-PLAN.md Task 1 (9d96778) — runProcess 의 제한이 종료 코드와 출력 수집 전체(Future.wait)에 걸려 파이프를 붙든 자손이 있어도 제한 안에 timedOut (소유자 결정 G7-Q2) |
| IN-04 | info | fixed | 06-13-PLAN.md Task 1 (9d96778) — runProcess 가 Utf8Decoder(allowMalformed: true) 로 UTF-8 아닌 출력을 U+FFFD 로 받아 처리되지 않은 비동기 예외(255)가 finally 를 건너뛰지 않음; 하네스 (06-VERIFICATION.md 2회차 gap, 소유자 결정 G7-Q2) |
| IN-05 | info | fixed | 06-13-PLAN.md Task 2 (ea2d664) — pendingSpawn · awaitRunningChild 로 처리기가 띄우는 중인 하위 명령을 기다려 끊고, finally 가 cleanup 뒤에 처리기를 내림 (소유자 결정 G7-Q2) |
| IN-06 | info | fixed | 06-13-PLAN.md Task 2 (ea2d664) — killTree 가 표를 읽지 못하면 stderr 한 줄, SIGKILL 직전 표를 다시 읽어 사슬에 남은 pid 만 끊고 사슬 밖은 SIGCONT, 머리 주석에 부모가 먼저 끝난 자손은 끊지 못한다는 범위 (소유자 결정 G7-Q2) |
| IN-07 | info | fixed | 06-13-PLAN.md Task 2 (ea2d664) — scrubNamesFor 하나를 runSmoke 와 main 의 예외 안내 둘이 함께 씀 (SDK root · 홈 · 저장소 · 임시 폴더) (소유자 결정 G7-Q2) |
| IN-08 | info | deferred | 소유자 결정 G7-Q1 — 판 고정은 하지 않는다: 첫 줄 규칙 아래에서는 거짓 통과 방향이 해석기 판에 기대지 않는다 (첫 줄이 엄격한 제목이어야 하고 package:markdown 은 첫 줄과의 일치만 보는 둘째 reader 다); 2026-10-16 |
| IN-09 | info | fixed | 06-12-PLAN.md Task 1 (85e1b0d) — 다섯 자리(skill 세 줄 · pubspec.yaml 19행 · tool/verify.dart 머리 주석)의 문장이 package:yaml 을 YAML 대조와 pubspec.yaml 의 version 읽기에 쓴다고 말함 (소유자 결정 G7-Q2) |
| CR-01 | critical | fixed | 06-08-PLAN.md Task 1 (6aa78fe) — tool/verify.dart 의 [3/10] (i) 가 pubspec.yaml 의 version 을 package:yaml 이 읽은 값(pubspecYamlVersion — 원문 · 꼬리 뗀 값)에서 쓰고, (h) 가 pubspecVersionText 의 원문 전체를 YAML 의 version 과 견줌 (두 겹); M98 · M99 (06-VERIFICATION.md gap — 검증자 권고 그대로, 소유자 결정 2026-10-16) (not in the current review) |
| WR-01 | warning | fixed | 06-09-PLAN.md Task 1 (2c5b73b) — tool/smoke.dart 의 judge 가 두 주소 각각에서 analysis_options.yaml 의 include_file_not_found · included_file_warning 줄을 실패 사유로 더함 (소유자 결정 G6-Q2) (not in the current review) |
| WR-03 | warning | fixed | 06-09-PLAN.md Task 2 (4286d48) — runProcess 가 단계마다 제한(create 2분 · pub get 5분 · analyze 5분)을 두고 넘으면 SIGKILL 로 끊고 69, 머리 주석의 종료 코드 목록 (소유자 결정 G6-Q2) (not in the current review) |
| IN-01 | info | fixed | 06-09-PLAN.md Task 2 (4286d48) — 임시 폴더 정리를 finally 로 옮기고 SIGINT 에서 하위 명령을 끊고 정리한 뒤 130 (소유자 결정 G6-Q2) (not in the current review) |
| IN-02 | info | fixed | 06-09-PLAN.md Task 1 (2c5b73b) — judge 가 (reasons, shown) 을 돌려주고 runSmoke 는 그 값만 씀 — 판정 조건은 judge 한 곳 (소유자 결정 G6-Q2) (not in the current review) |
| IN-03 | info | fixed | 06-08-PLAN.md Task 1 (6aa78fe) — pubspecReleaseVersion 을 pubspecVersionText 위에서 releaseHead 로 머리만 떼게 해 줄 단위 reader 를 하나로 (검증자 권고) (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
