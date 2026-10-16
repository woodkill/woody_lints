---
phase: 06
review: 06-REVIEW.md
titles: json
findings:
  - id: CR-01
    severity: critical
    disposition: fixed
    title: "tag 모드가 정확히 견주는 version 원문을 YAML 과 견주는 확인이 없어, `-dev` 가 남은 pubspec 이 `--tag` 검사를 통과한다"
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "smoke 가 include 사슬의 끊김(`include_file_not_found`)을 보고도 통과한다 — 두 주소의 codegen 부분은 판정에 없다"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "`changelogTop` 이 들여 쓴 ATX 제목 · setext 제목 · U+FEFF 머리를 제목으로 보지 않아, 평소 모드가 아래의 옛 항목과 견주어 통과한다"
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
total: 7
recorded: 2026-10-16T05:18:38.325Z
---

# Phase 06: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| CR-01 | critical | fixed | 06-08-PLAN.md Task 1 (6aa78fe) — tool/verify.dart 의 [3/10] (i) 가 pubspec.yaml 의 version 을 package:yaml 이 읽은 값(pubspecYamlVersion — 원문 · 꼬리 뗀 값)에서 쓰고, (h) 가 pubspecVersionText 의 원문 전체를 YAML 의 version 과 견줌 (두 겹); M98 · M99 (06-VERIFICATION.md gap — 검증자 권고 그대로, 소유자 결정 2026-10-16) |
| WR-01 | warning | fixed | 06-09-PLAN.md Task 1 (2c5b73b) — tool/smoke.dart 의 judge 가 두 주소 각각에서 analysis_options.yaml 의 include_file_not_found · included_file_warning 줄을 실패 사유로 더함 (소유자 결정 G6-Q2) |
| WR-02 | warning | fixed | 06-08-PLAN.md Task 1 (6aa78fe) — changelogTop 이 package:markdown (dev_dependencies, GitHub Flavored) 으로 해석한 문서의 첫 h2 (깊이 무관) 를 읽고 U+FEFF 를 뗌 — HTML 주석 · 펜스 · 들여 쓴 ATX · setext · 인용 · 목록의 M100 ~ M106 (소유자 결정 G6-Q1 (가)) |
| WR-03 | warning | fixed | 06-09-PLAN.md Task 2 (4286d48) — runProcess 가 단계마다 제한(create 2분 · pub get 5분 · analyze 5분)을 두고 넘으면 SIGKILL 로 끊고 69, 머리 주석의 종료 코드 목록 (소유자 결정 G6-Q2) |
| IN-01 | info | fixed | 06-09-PLAN.md Task 2 (4286d48) — 임시 폴더 정리를 finally 로 옮기고 SIGINT 에서 하위 명령을 끊고 정리한 뒤 130 (소유자 결정 G6-Q2) |
| IN-02 | info | fixed | 06-09-PLAN.md Task 1 (2c5b73b) — judge 가 (reasons, shown) 을 돌려주고 runSmoke 는 그 값만 씀 — 판정 조건은 judge 한 곳 (소유자 결정 G6-Q2) |
| IN-03 | info | fixed | 06-08-PLAN.md Task 1 (6aa78fe) — pubspecReleaseVersion 을 pubspecVersionText 위에서 releaseHead 로 머리만 떼게 해 줄 단위 reader 를 하나로 (검증자 권고) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
