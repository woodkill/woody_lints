---
phase: 05
review: 05-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "README 검사 (e) 가 모양이 틀린 프리셋 주소를 조용히 건너뛴다 — 오타 주소로 통과"
  - id: WR-02
    severity: warning
    disposition: open
    title: "README 검사 (f) · (g) 가 따옴표 · 줄 끝 주석 · 두 자리 버전 값을 조용히 건너뛴다 — 낡은 값으로 통과"
  - id: WR-03
    severity: warning
    disposition: open
    title: "`fencedLines` 가 ``` 펜스만 안다 — `~~~` 코드 블록의 값은 (f) · (g) 가 보지 않는다"
  - id: WR-04
    severity: warning
    disposition: open
    title: "(b′) 가 flow 표기 `linter: {rules: [...]}` 로 다른 조각에 적은 규칙을 보지 못한다 — 사용 프로젝트는 받는데 검증은 10개 중 10개"
  - id: WR-05
    severity: warning
    disposition: open
    title: "`readShippedPluginConstraint` 가 YAML 토큰을 그대로 돌려주고 올바른 꼴 셋을 거부한다 — 70 이나 통과할 수 없는 `[3/N]` · `[4/N]`"
  - id: WR-06
    severity: warning
    disposition: open
    title: "`.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다"
  - id: IN-01
    severity: info
    disposition: open
    title: "`pubspecReleaseVersion` 이 따옴표로 감싼 `version:` 에서 종료 코드 70"
  - id: IN-02
    severity: info
    disposition: open
    title: "CHANGELOG 2.0.0 의 \"내용은 1.3.0 과 같다\" 가 같은 절의 다른 항목과 어긋난다"
  - id: IN-03
    severity: info
    disposition: open
    title: "README 「프리셋 고르기」 의 \"그 연습용 프로젝트의 정답지로 확인\" 이 묶음에는 맞지 않는다"
  - id: IN-04
    severity: info
    disposition: open
    title: "plugin 하한을 올릴 때 함께 고칠 자리가 두 문서에 반씩 적혀 있다"
  - id: IN-05
    severity: info
    disposition: open
    title: "`tool/verify.dart` 문서 주석의 단계 번호가 `[2/4]` · `[1/4]` 로 남아 있다"
  - id: IN-06
    severity: info
    disposition: open
    title: "`readBulletBlock` 이 `readRulesMdBlock` 의 마커 처리를 복제하고, 결과 타입 이름이 README 에 맞지 않는다"
  - id: IN-07
    severity: info
    disposition: open
    title: "README 「받는 규칙」 의 분류는 검사되지 않는다"
open: 13
total: 13
recorded: 2026-10-13T20:37:11.692Z
---

# Phase 05: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| WR-04 | warning | open | - |
| WR-05 | warning | open | - |
| WR-06 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |
| IN-05 | info | open | - |
| IN-06 | info | open | - |
| IN-07 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
