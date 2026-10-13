---
phase: 04
review: 04-REVIEW.md
titles: json
findings:
  - id: CR-01
    severity: critical
    disposition: open
    title: "`pubspec.yaml` 의 진단을 버려 `sort_pub_dependencies` 의 실측 2줄이 0줄로 기록됐다 — 소유자 결정의 근거가 사실과 다르다"
  - id: CR-02
    severity: critical
    disposition: open
    title: "`[3/10]` 이 `linter:` 블록 안의 열 0 주석 뒤에 적힌 규칙을 보지 못한다 — 겹침 · `RULES.md` 일치 검사의 거짓 통과"
  - id: CR-03
    severity: critical
    disposition: open
    title: "측정 도구가 \"지금 켜 둔 규칙\" 을 1.3.0 의 6개로 박아 두어, 지금 저장소에서 다시 재면 채택한 74개가 모두 0줄이 된다"
  - id: WR-01
    severity: warning
    disposition: open
    title: "같은 id 의 회차를 덮어써도 행이 옛 회차를 계속 가리킨다 — 수치의 출처 추적(RULES-05)이 조용히 끊긴다"
  - id: WR-02
    severity: warning
    disposition: open
    title: "음수인 \"가린 줄\" 이 `0` 으로 찍힌다"
  - id: WR-03
    severity: warning
    disposition: open
    title: "`--out` 을 검사하지 않는다 — 원본(사용 프로젝트)이나 저장소의 아무 파일에나 쓸 수 있다"
  - id: WR-04
    severity: warning
    disposition: open
    title: "`--work` 가 남의 폴더여도 그 아래 `consumer/` · `pristine/` · `pkg13/` · `state/<id>/` 를 지운다"
  - id: WR-05
    severity: warning
    disposition: open
    title: "`example/README.md` 의 줄 수 · 파일 표가 이 phase 의 샘플을 반영하지 않았다"
  - id: WR-06
    severity: warning
    disposition: open
    title: "기반 세트 YAML 에서 규칙을 하나도 읽지 못해도 겹침 검사가 통과한다"
  - id: WR-07
    severity: warning
    disposition: open
    title: "상태 출처의 캐시가 tag 를 가리지 않고, `sdkTag` 와 실행 SDK 를 견주지 않는다"
  - id: WR-08
    severity: warning
    disposition: open
    title: "단계가 예외로 끝나면 저장소 지문을 견주지 않고 결과도 저장하지 않는다"
  - id: IN-01
    severity: info
    disposition: open
    title: "샘플 머리 주석의 \"한 줄에서 규칙 하나만\" 이 사실과 다르다"
  - id: IN-02
    severity: info
    disposition: open
    title: "`MessagesRule.consistent` 가 쓰이지 않는다"
  - id: IN-03
    severity: info
    disposition: open
    title: "\"Dart 파일 474개\" 에 분석하지 않는 생성 파일 62개가 들어 있다"
  - id: IN-04
    severity: info
    disposition: open
    title: "`RULES.md` 의 완결성 · 사유 문장 일치를 CI 가 보지 않는다"
  - id: IN-05
    severity: info
    disposition: open
    title: "`lib/base.yaml:15` 의 템플릿 문장이 남았다"
  - id: IN-06
    severity: info
    disposition: open
    title: "`require_trailing_commas` 의 \"규칙이 돌지 않음 (표식 불가)\" 는 표식을 넣어 보지 않은 결론이다"
  - id: IN-07
    severity: info
    disposition: open
    title: "결과 파일 이름 · 출력 모드 · 종료 코드의 세부"
open: 18
total: 18
recorded: 2026-10-13T06:05:41.344Z
---

# Phase 04: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| CR-01 | critical | open | - |
| CR-02 | critical | open | - |
| CR-03 | critical | open | - |
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
| IN-07 | info | open | - |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
