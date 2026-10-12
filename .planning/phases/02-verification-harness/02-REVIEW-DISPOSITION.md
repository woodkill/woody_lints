---
phase: 02
review: 02-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "`--update` 가 같은 실행에서 실패가 난 뒤에도, plugin 버전을 읽지 못한 때에도 정답지를 쓴다"
  - id: WR-02
    severity: warning
    disposition: open
    title: "`dart analyze` 의 종료 코드와 JSON 이 어긋나는 것을 보지 않아, 규칙 이름 단계가 YAML 이 깨진 배포 파일을 \"통과\" 로 찍는다"
  - id: WR-03
    severity: warning
    disposition: open
    title: "규칙 이름 단계가 세 코드 밖의 진단을 모두 버리고, 규칙을 하나도 읽지 못해도 통과한다"
  - id: WR-04
    severity: warning
    disposition: open
    title: "머리말이 없는 stderr 는 어디에도 찍히지 않는다"
  - id: WR-05
    severity: warning
    disposition: open
    title: "한 단계가 던진 예외가 실행 전체를 끝내서, 깨진 정답지는 `--update` 로도 고칠 수 없고 화면이 통째로 사라진다"
  - id: WR-06
    severity: warning
    disposition: open
    title: "루트 `pubspec.yaml` 의 `version` 을 바꾸면 exit 69 가 나는데, 안내는 `example/pubspec.yaml` 을 가리키고 어긋난 패키지 이름은 버려진다"
  - id: WR-08
    severity: warning
    disposition: open
    title: "규칙 수 세기가 `rules:` 키를 보지 않아, `rules:` 를 잘못 적어 규칙이 하나도 적용되지 않는 배포 파일에서 `[2/4]` 가 통과한다"
  - id: IN-01
    severity: info
    disposition: open
    title: "`.fvmrc` 보다 낮은 SDK 로 실행하면 D-12 의 안내에 닿기 전에 exit 254 로 끝난다"
  - id: IN-02
    severity: info
    disposition: open
    title: "`include_file_not_found` 의 안내가 방금 성공한 `pub get` 을 원인으로 단정한다"
  - id: IN-03
    severity: info
    disposition: open
    title: "코드가 아는 것보다 많이 말하는 문구와 주석"
  - id: IN-04
    severity: info
    disposition: open
    title: "workflow 의 action 이 움직이는 tag 로 지정되어 있다"
  - id: IN-05
    severity: info
    disposition: open
    title: "PR 을 열면 같은 커밋에 실행이 둘 돌고 `concurrency` 가 서로를 취소하지 않는다"
  - id: IN-06
    severity: info
    disposition: open
    title: "`pluginFolders` 는 동사로 시작하지 않는다"
  - id: IN-07
    severity: info
    disposition: open
    title: "규칙 수 세기가 멀쩡한 YAML 몇 가지 모양을 0개로 세어 `[2/4]` 를 잘못 실패시키고, 문구는 \"비어 있거나 없다\" 고 말한다"
  - id: IN-08
    severity: info
    disposition: open
    title: "`--update` 쓰기 반복문은 fixture 가 둘 이상일 때의 모양이 정해져 있지 않다"
  - id: CR-01
    severity: critical
    disposition: fixed
    title: "정답지 비교가 집합으로 견줘서, 같은 줄이 여러 건일 때 건수 변화를 놓친다"
  - id: WR-07
    severity: warning
    disposition: fixed
    title: "workflow 의 `push:` 는 필터가 없어 tag push 에서도 돈다 — 주석과 D-10 은 반대로 적혀 있다"
open: 15
total: 17
recorded: 2026-10-12T01:29:53.295Z
---

# Phase 02: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| WR-04 | warning | open | - |
| WR-05 | warning | open | - |
| WR-06 | warning | open | - |
| WR-08 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |
| IN-05 | info | open | - |
| IN-06 | info | open | - |
| IN-07 | info | open | - |
| IN-08 | info | open | - |
| CR-01 | critical | fixed | 02-05-PLAN.md Task 1 (37316e3) (not in the current review) |
| WR-07 | warning | fixed | 02-05-PLAN.md Task 3 (008ea3f) (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
