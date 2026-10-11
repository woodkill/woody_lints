---
phase: 01
review: 01-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "1.3.0 사례가 판정 순서 1번의 둘째 조건을 건너뛴다 — 끝까지 적용하면 major 다"
  - id: WR-02
    severity: warning
    disposition: open
    title: "\"자동 검사가 막힐 수 있나\" 의 뜻이 정해져 있지 않아 minor 와 major 의 경계가 무너진다"
  - id: WR-03
    severity: warning
    disposition: open
    title: "판정 순서와 기준표가 같은 변경에 다른 등급을 낸다 (세 가지 경우)"
  - id: WR-04
    severity: warning
    disposition: open
    title: "52행 \"major 는 … 고쳐야 하는 변경에만 쓴다\" 가 25행, 40-42행, 54행과 모순된다"
  - id: WR-05
    severity: warning
    disposition: open
    title: "\"받는 쪽은 tag 하나에 고정해서 받는다\" 는 전제가 지금 사실이 아니고, CHANGELOG 의 \"올리기 전에\" 가 그 전제 위에 쓰여 있다"
  - id: WR-06
    severity: warning
    disposition: open
    title: "형식의 기준 예시가 자기 설명과 어긋난다 — \"규칙 하나를 추가\" 인데 경고 표에는 규칙이 둘이다"
  - id: IN-01
    severity: info
    disposition: open
    title: "\"옛 판정과 지금 정책이 다른 것\" 목록에 규칙을 뺀 유일한 사례 1.2.5 가 없다"
  - id: IN-02
    severity: info
    disposition: open
    title: "`` ` - ` `` 는 렌더링하면 앞뒤 공백이 사라진다"
  - id: IN-03
    severity: info
    disposition: open
    title: "오래 남을 문서가 작업 계획의 내부 이름에 기대고, 아직 없는 검사를 현재형으로 적는다"
  - id: IN-04
    severity: info
    disposition: open
    title: "준비 중 버전에 `-dev` 를 붙이는 규칙이 2.0.0 사례의 하위 불릿에만 있다"
open: 10
total: 10
recorded: 2026-10-11T05:17:19.936Z
---

# Phase 01: Code Review Disposition

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

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
