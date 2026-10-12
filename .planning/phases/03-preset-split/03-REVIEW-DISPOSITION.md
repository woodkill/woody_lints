---
phase: 03
review: 03-REVIEW.md
titles: json
findings:
  - id: WR-01
    severity: warning
    disposition: open
    title: "`[2/N]` 이 묶음과 별칭을 검사하지 않아, 거기 넣은 deprecated 규칙이 아홉 단계를 모두 통과한다 (재현함)"
  - id: WR-02
    severity: warning
    disposition: open
    title: "`lib/riverpod.yaml` 을 YAML 로 문제없게 고쳐도 검증이 종료 코드 70 으로 멈춘다 (재현함)"
  - id: WR-03
    severity: warning
    disposition: open
    title: "규칙 세기와 규칙 이름 읽기가 목록 형식만 알아, 같은 뜻의 맵 형식이 `[2/N]` 거짓 실패가 된다 (재현함)"
  - id: WR-04
    severity: warning
    disposition: open
    title: "중첩 fixture 의 lock 불일치 안내가 틀린 경로를 알려 준다 (재현함)"
  - id: WR-05
    severity: warning
    disposition: open
    title: "정답지 파일이 깨지면 절대 경로를 찍고 종료 코드 70 으로 끝나며, `--update` 로도 복구할 수 없다 (재현함)"
  - id: WR-06
    severity: warning
    disposition: open
    title: "\"fixture 의 `lib/` 는 `example/lib/` 의 글자 그대로 복사본\" 이라는 전제를 아무 단계도 지키지 않는다 (추론)"
  - id: WR-07
    severity: warning
    disposition: open
    title: "plugin 을 쓰는 fixture 에서 plugin 이 준비되지 않은 실행도 `--update` 가 정답지로 쓴다 (추론)"
  - id: WR-08
    severity: warning
    disposition: open
    title: "서드파티 action 을 바뀔 수 있는 tag 로 받는다 (추론)"
  - id: IN-01
    severity: info
    disposition: open
    title: "단계 번호 `[1/4]` · `[2/4]` 와 \"다섯\" 이 코드에 박혀 있다"
  - id: IN-02
    severity: info
    disposition: open
    title: "다른 도구의 stderr 를 찍는 곳 가운데 일부만 경로를 가린다"
  - id: IN-03
    severity: info
    disposition: open
    title: "`lib/codegen.yaml` 에 \"왜\" 주석이 없다"
  - id: IN-04
    severity: info
    disposition: open
    title: "`example/README.md` 의 M1 ~ M17 이 지금은 없는 파일 모양을 가리킨다"
  - id: IN-05
    severity: info
    disposition: open
    title: "규칙 검사 복사본 폴더를 쓰기 전에 비우지 않는다"
  - id: IN-06
    severity: info
    disposition: open
    title: "`lib/` 의 YAML 집합 확인이 최상위 `.yaml` 만 본다"
open: 14
total: 14
recorded: 2026-10-12T13:04:38.618Z
---

# Phase 03: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| WR-01 | warning | open | - |
| WR-02 | warning | open | - |
| WR-03 | warning | open | - |
| WR-04 | warning | open | - |
| WR-05 | warning | open | - |
| WR-06 | warning | open | - |
| WR-07 | warning | open | - |
| WR-08 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |
| IN-05 | info | open | - |
| IN-06 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
