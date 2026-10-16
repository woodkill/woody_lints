---
phase: 06
review: 06-REVIEW.md
titles: json
findings:
  - id: CR-01
    severity: critical
    disposition: open
    title: "tag 모드가 정확히 견주는 version 원문을 YAML 과 견주는 확인이 없어, `-dev` 가 남은 pubspec 이 `--tag` 검사를 통과한다"
  - id: WR-01
    severity: warning
    disposition: open
    title: "smoke 가 include 사슬의 끊김(`include_file_not_found`)을 보고도 통과한다 — 두 주소의 codegen 부분은 판정에 없다"
  - id: WR-02
    severity: warning
    disposition: open
    title: "`changelogTop` 이 들여 쓴 ATX 제목 · setext 제목 · U+FEFF 머리를 제목으로 보지 않아, 평소 모드가 아래의 옛 항목과 견주어 통과한다"
  - id: WR-03
    severity: warning
    disposition: open
    title: "smoke 의 하위 명령에 시간 제한이 없어, 받기 · plugin 준비가 멈추면 끝없이 기다린다"
  - id: IN-01
    severity: info
    disposition: open
    title: "smoke 의 임시 폴더 정리가 `finally` 밖이라, 세 예외 밖의 throw · 중단 신호에서 폴더가 남는다"
  - id: IN-02
    severity: info
    disposition: open
    title: "`runSmoke` 가 `judge` 의 앞 두 조건을 다시 적는다"
  - id: IN-03
    severity: info
    disposition: open
    title: "`pubspecVersionText` 가 `pubspecReleaseVersion` 의 줄 찾기를 따로 다시 짠다"
open: 7
total: 7
recorded: 2026-10-16T05:18:38.325Z
---

# Phase 06: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| CR-01 | critical | open | - |
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
