---
schema_version: 1
open_count: 2
waived_count: 0
fixed_count: 0
total_count: 2
last_updated: 2026-10-12T23:21:26.735Z
---

# Broken Windows Ledger

> Cross-phase defect register. With `workflow.windows_enforce` enabled, `/gsd-ship` blocks while `open_count > 0`.
> Waive with `gsd-tools windows waive <id> "<reason>"` (reason required).
> Mark fixed with `gsd-tools windows fixed <id>`.

| id | phase | kind | file | line | description | status | reason | recorded_at | resolved_at |
|----|-------|------|------|------|-------------|--------|--------|-------------|-------------|
| 1 | 01 | stub | CHANGELOG.md | 11 | CHANGELOG 2.0.0 항목의 "새로 생기는 경고" 칸이 자리 표시 "(Phase 4 실측 후 채움)" 이다 — 의도된 자리(D-14), Phase 4 실측 표로 채운다 | open |  | 2026-10-11T04:55:25.101Z |  |
| 2 | 04 | stub | RULES.md |  | RULES.md 켠 규칙 표의 실측 · dart fix · 회차 칸이 '(실측 전 — 04-06 이 채운다)' 자리 표시 — 04-06 이 채운다 | open |  | 2026-10-12T23:21:26.735Z |  |

````json
[
  {
    "id": 1,
    "kind": "stub",
    "phase": "01",
    "file": "CHANGELOG.md",
    "line": 11,
    "description": "CHANGELOG 2.0.0 항목의 \"새로 생기는 경고\" 칸이 자리 표시 \"(Phase 4 실측 후 채움)\" 이다 — 의도된 자리(D-14), Phase 4 실측 표로 채운다",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-10-11T04:55:25.101Z",
    "resolved_at": null,
    "milestone": "v2.0"
  },
  {
    "id": 2,
    "kind": "stub",
    "phase": "04",
    "file": "RULES.md",
    "line": null,
    "description": "RULES.md 켠 규칙 표의 실측 · dart fix · 회차 칸이 '(실측 전 — 04-06 이 채운다)' 자리 표시 — 04-06 이 채운다",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-10-12T23:21:26.735Z",
    "resolved_at": null,
    "milestone": "v2.0"
  }
]
````
