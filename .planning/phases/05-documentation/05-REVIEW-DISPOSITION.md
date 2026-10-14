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
    disposition: skipped
    title: "README 검사 (e) 가 `package:` 로 정확히 시작하지 않는 include 주소를 보지 않는다 — scheme 오타로 10개 중 10개"
  - id: WR-08
    severity: warning
    disposition: skipped
    title: "README 검사 (f) · (g) 가 flow 표기에 적힌 plugin 버전 · `ref:` 를 보지 않는다 — 낡은 값으로 10개 중 10개"
  - id: WR-09
    severity: warning
    disposition: skipped
    title: "`fencedLines` 가 펜스가 아닌 코드 블록을 보지 않는다 — 들여쓴 코드 블록의 낡은 `ref:` 로 10개 중 10개"
  - id: WR-11
    severity: warning
    disposition: open
    title: "(a′) · `declaredRuleNames` 가 `\\n` 으로만 줄을 나눈다 — 주석 줄 끝의 CR(`\\r`) 뒤에 둔 키 · 규칙이 사용 프로젝트에 닿는데 10개 중 10개"
  - id: WR-12
    severity: warning
    disposition: open
    title: "(d′) 의 절 경계가 HTML 주석 안의 `#` 줄 · 4칸 들여 쓴 ```` ``` ```` 를 제목 · 펜스로 본다 — 렌더링된 「받는 규칙」 목록 바로 아래의 불릿으로 10개 중 10개"
  - id: WR-13
    severity: warning
    disposition: open
    title: "README 검사 (f) · (g) 가 따옴표로 감싼 키 · 콜론 앞 공백(`\"ref\":` · `'riverpod_lint':` · `ref :`)을 후보로 보지 않는다 — 낡은 값으로 10개 중 10개, 좁힌 문장은 \"모두 후보로\""
  - id: WR-14
    severity: warning
    disposition: open
    title: "(e) 의 다른 패키지 주소 검사는 `.yaml` · `.yml` 로 끝나는 주소만 보는데, 좁힌 문장과 문서 주석은 \"`package:` 로 정확히 시작하는 주소가 꼴이 아니면 실패\" 라고 적는다 — `package:woody-lints/riverpod` 로 10개 중 10개"
  - id: IN-08
    severity: info
    disposition: skipped
    title: "(e) 의 주소 끝 판정이 문장 부호를 모른다 — 맞는 주소의 거짓 실패와 다른 패키지 주소의 누락이 한 줄에서 함께 난다"
  - id: IN-09
    severity: info
    disposition: open
    title: "(a′) 가 들어온 뒤 M35 · M37 의 `[3/10]` 출력이 바뀌었는데, 05-10 소절은 M46 만 짚는다"
  - id: WR-10
    severity: warning
    disposition: fixed
    title: "`[3/10]` 이 조각의 `linter:` 밖 키를 보지 않는다 — `lib/codegen.yaml` 의 `language:` 옵션 · `formatter:` 가 사용 프로젝트에 닿는데 10개 중 10개"
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
total: 23
recorded: 2026-10-14T07:26:55.665Z
---

# Phase 05: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-06 | warning | deferred | D-09 — 마일스톤 끝 /gsd-map-codebase 에서 고친다 (70 · 173 · 313행의 "유지해야 한다" 지시 포함, 소유자 결정 2026-10-14) |
| WR-07 | warning | skipped | 소유자 결정 G2-Q2 — 문장을 검사 범위에 맞춤, 검사는 넓히지 않음; 05-10-PLAN.md Task 3 (d2d74c4) — example/README.md 116 · 358 · 436행과 tool/verify.dart 의 (e) 주석이 (e) 의 후보를 package: 로 정확히 시작하는 주소로 적음 (scheme 오타 · package: 뒤 공백은 범위 밖, 주석은 G2-Q5) |
| WR-08 | warning | skipped | 소유자 결정 G2-Q2 — 문장을 검사 범위에 맞춤, 검사는 넓히지 않음; 05-10-PLAN.md Task 3 (d2d74c4) — README.md 382행 · example/README.md 116 · 395행 · tool/verify.dart 의 (f) · (g) 주석이 펜스 안에서 키가 줄 머리에 오는 줄로 적음 (flow 표기 안의 키는 범위 밖) |
| WR-09 | warning | skipped | 소유자 결정 G2-Q2 — 문장을 검사 범위에 맞춤, 검사는 넓히지 않음; 05-10-PLAN.md Task 3 (d2d74c4) — README.md 382행 · example/README.md 116 · 395행 · tool/verify.dart 의 fencedLines · (f) · (g) 주석이 펜스 코드 블록만 본다고 적음 (들여 쓴 코드 블록 · 인용 안의 펜스는 범위 밖) |
| WR-11 | warning | open | - |
| WR-12 | warning | open | - |
| WR-13 | warning | open | - |
| WR-14 | warning | open | - |
| IN-08 | info | skipped | 소유자 결정 G2-Q2 — 문장을 검사 범위에 맞춤, 검사는 넓히지 않음; 05-10-PLAN.md Task 3 (d2d74c4) — example/README.md 116 · 436행과 tool/verify.dart 의 (e) 주석이 주소의 끝 글자와 뒤에 붙은 문장 부호의 결과를 적음 |
| IN-09 | info | open | - |
| WR-10 | warning | fixed | 05-10-PLAN.md Task 1 (02966c4) — 조각마다 받는 최상위 키와 lib/codegen.yaml 의 analyzer: · lib/riverpod.yaml 의 plugins: 아래 키를 닫힌 목록으로, M68 ~ M73 · M78 (소유자 결정 G2-Q1 · G2-Q4 — 05-VERIFICATION 2회차 gap 과 함께) (not in the current review) |
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
