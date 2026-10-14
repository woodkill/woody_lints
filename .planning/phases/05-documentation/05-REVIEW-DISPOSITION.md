---
phase: 05
review: 05-REVIEW.md
titles: json
findings:
  - id: WR-06
    severity: warning
    disposition: deferred
    title: "`.claude/CLAUDE.md` 의 고친 두 줄 옆에 저장소와 어긋나는 지시가 남아 있다"
  - id: WR-07
    severity: warning
    disposition: open
    title: "README 검사 (e) 가 `package:` 로 정확히 시작하지 않는 include 주소를 보지 않는다 — scheme 오타로 10개 중 10개"
  - id: WR-08
    severity: warning
    disposition: open
    title: "README 검사 (f) · (g) 가 flow 표기에 적힌 plugin 버전 · `ref:` 를 보지 않는다 — 낡은 값으로 10개 중 10개"
  - id: WR-09
    severity: warning
    disposition: open
    title: "`fencedLines` 가 펜스가 아닌 코드 블록을 보지 않는다 — 들여쓴 코드 블록의 낡은 `ref:` 로 10개 중 10개"
  - id: WR-10
    severity: warning
    disposition: open
    title: "`[3/10]` 이 조각의 `linter:` 밖 키를 보지 않는다 — `lib/codegen.yaml` 의 `language:` 옵션 · `formatter:` 가 사용 프로젝트에 닿는데 10개 중 10개"
  - id: IN-08
    severity: info
    disposition: open
    title: "(e) 의 주소 끝 판정이 문장 부호를 모른다 — 맞는 주소의 거짓 실패와 다른 패키지 주소의 누락이 한 줄에서 함께 난다"
  - id: WR-01
    severity: warning
    disposition: fixed
    title: "README 검사 (e) 가 모양이 틀린 프리셋 주소를 조용히 건너뛴다 — 오타 주소로 통과"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "README 검사 (f) · (g) 가 따옴표 · 줄 끝 주석 · 두 자리 버전 값을 조용히 건너뛴다 — 낡은 값으로 통과"
  - id: WR-03
    severity: warning
    disposition: fixed
    title: "`fencedLines` 가 ``` 펜스만 안다 — `~~~` 코드 블록의 값은 (f) · (g) 가 보지 않는다"
  - id: WR-04
    severity: warning
    disposition: fixed
    title: "(b′) 가 flow 표기 `linter: {rules: [...]}` 로 다른 조각에 적은 규칙을 보지 못한다 — 사용 프로젝트는 받는데 검증은 10개 중 10개"
  - id: WR-05
    severity: warning
    disposition: fixed
    title: "`readShippedPluginConstraint` 가 YAML 토큰을 그대로 돌려주고 올바른 꼴 셋을 거부한다 — 70 이나 통과할 수 없는 `[3/N]` · `[4/N]`"
  - id: IN-01
    severity: info
    disposition: fixed
    title: "`pubspecReleaseVersion` 이 따옴표로 감싼 `version:` 에서 종료 코드 70"
  - id: IN-02
    severity: info
    disposition: fixed
    title: "CHANGELOG 2.0.0 의 \"내용은 1.3.0 과 같다\" 가 같은 절의 다른 항목과 어긋난다"
  - id: IN-03
    severity: info
    disposition: fixed
    title: "README 「프리셋 고르기」 의 \"그 연습용 프로젝트의 정답지로 확인\" 이 묶음에는 맞지 않는다"
  - id: IN-04
    severity: info
    disposition: fixed
    title: "plugin 하한을 올릴 때 함께 고칠 자리가 두 문서에 반씩 적혀 있다"
  - id: IN-05
    severity: info
    disposition: fixed
    title: "`tool/verify.dart` 문서 주석의 단계 번호가 `[2/4]` · `[1/4]` 로 남아 있다"
  - id: IN-06
    severity: info
    disposition: fixed
    title: "`readBulletBlock` 이 `readRulesMdBlock` 의 마커 처리를 복제하고, 결과 타입 이름이 README 에 맞지 않는다"
  - id: IN-07
    severity: info
    disposition: fixed
    title: "README 「받는 규칙」 의 분류는 검사되지 않는다"
open: 5
total: 18
recorded: 2026-10-14T03:23:47.764Z
---

# Phase 05: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-06 | warning | deferred | D-09 — 마일스톤 끝 /gsd-map-codebase 에서 고친다 (70 · 173 · 313행의 "유지해야 한다" 지시 포함, 소유자 결정 2026-10-14) |
| WR-07 | warning | open | - |
| WR-08 | warning | open | - |
| WR-09 | warning | open | - |
| WR-10 | warning | open | - |
| IN-08 | info | open | - |
| WR-01 | warning | fixed | 05-08-PLAN.md Task 2 (63fe3d9) — (e) 가 후보를 모두 모아 꼴이 아닌 주소 · 다른 패키지의 주소를 실패, M54 · M55 (not in the current review) |
| WR-02 | warning | fixed | 05-07-PLAN.md Task 3 (73f1c66) — (f) · (g) 가 따옴표 · 줄 끝 주석을 벗겨 읽고 꼴이 틀린 값을 실패, M47 ~ M50 (not in the current review) |
| WR-03 | warning | fixed | 05-08-PLAN.md Task 2 (63fe3d9) — fencedLines 가 펜스 문자 · 길이를 기억, M56 ~ M58 (not in the current review) |
| WR-04 | warning | fixed | 05-07-PLAN.md Task 2 (057bef2) — linter: 줄에 붙은 flow 표기를 FormatException (70), M45 · M46 (not in the current review) |
| WR-05 | warning | fixed | 05-09-PLAN.md Task 1 (644897f) — 따옴표 · 고정 버전 · 맵 안의 키 순서, 범위 제약은 원인을 말하는 70, M63 ~ M66 (not in the current review) |
| IN-01 | info | fixed | 05-09-PLAN.md Task 1 (644897f) — 따옴표 version, M67 (not in the current review) |
| IN-02 | info | fixed | 05-09-PLAN.md Task 2 (e46cff4) — CHANGELOG 2.0.0 그 밖의 변경 첫 불릿의 '옮기기만 했다' 를 나누는 변경 자체로 한정 (not in the current review) |
| IN-03 | info | fixed | 05-09-PLAN.md Task 2 (e46cff4) — README 45행: 묶음(recommended)은 자기 정답지 없이 같은 실행의 example/ 결과와 견준다 (not in the current review) |
| IN-04 | info | fixed | 05-09-PLAN.md Task 2 (e46cff4) — 함께 고칠 자리 셋을 README 382행 한 곳에, lib/riverpod.yaml 5행 주석이 같은 셋과 README 를 가리킴 (not in the current review) |
| IN-05 | info | fixed | 05-09-PLAN.md Task 1 (644897f) — [1/N] · [2/N] (not in the current review) |
| IN-06 | info | fixed | 05-07-PLAN.md Task 1 (5f43726) — readMarkerBlock · MarkerBlock (not in the current review) |
| IN-07 | info | fixed | 05-09-PLAN.md Task 2 (e46cff4) — README 91행: 검증 명령은 이름만 견주고 분류는 보지 않는다 (D-16 유지, 분류 검사는 더하지 않음) (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
