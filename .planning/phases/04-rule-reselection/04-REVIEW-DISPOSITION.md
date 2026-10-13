---
phase: 04
review: 04-REVIEW.md
titles: json
findings:
  - id: CR-03
    severity: critical
    disposition: deferred
    title: "측정 도구가 \"지금 켜 둔 규칙\" 을 1.3.0 의 6개로 박아 두어, 지금 저장소에서 다시 재면 채택한 74개가 모두 0줄이 된다"
  - id: WR-01
    severity: warning
    disposition: open
    title: "같은 id 의 회차를 덮어써도 행이 옛 회차를 계속 가리킨다 — 수치의 출처 추적(RULES-05)이 조용히 끊긴다"
  - id: WR-03
    severity: warning
    disposition: open
    title: "`--out` 을 검사하지 않는다 — 원본(사용 프로젝트)이나 저장소의 아무 파일에나 쓸 수 있다"
  - id: WR-04
    severity: warning
    disposition: open
    title: "`--work` 가 남의 폴더여도 그 아래 `consumer/` · `pristine/` · `pkg13/` · `state/<id>/` 를 지운다"
  - id: WR-07
    severity: warning
    disposition: open
    title: "상태 출처의 캐시가 tag 를 가리지 않고, `sdkTag` 와 실행 SDK 를 견주지 않는다"
  - id: WR-08
    severity: warning
    disposition: open
    title: "단계가 예외로 끝나면 저장소 지문을 견주지 않고 결과도 저장하지 않는다"
  - id: WR-09
    severity: warning
    disposition: open
    title: "`--recount` 가 `fixSkipped` 를 원인을 확인하지 않고 R1 전용 문장으로 적고, 어느 단계도 지우지 않는다 — 단언 (2) 를 우회하고 권고를 뒤집는다"
  - id: WR-10
    severity: warning
    disposition: open
    title: "`[3/10]` 이 따옴표로 감싼 규칙 이름을 읽지 못한다 — CR-02 와 같은 거짓 통과가 다른 입력으로 남았다"
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
  - id: IN-08
    severity: info
    disposition: open
    title: "`RULES.md` 켠 규칙 표의 머리가 `실측 (lib · test · bin)` 그대로다 — `sort_pub_dependencies` 행이 0줄처럼 읽힌다"
  - id: IN-09
    severity: info
    disposition: open
    title: "`--in` 의 사용법 오류 문구가 `--recount` 를 빠뜨렸다"
  - id: IN-10
    severity: info
    disposition: open
    title: "`example/README.md` 의 `lib/added_rules.dart` 행이 \"이 패키지가 기반 세트 위에 추가하는 규칙 6개\" 라고 적는다"
  - id: IN-11
    severity: info
    disposition: open
    title: "\"가린 줄이 음수인 행은 무시 주석 자체를 보는 규칙이다\" 는 확인하지 않은 원인을 생성기가 단정한다"
  - id: CR-01
    severity: critical
    disposition: fixed
    title: "`pubspec.yaml` 의 진단을 버려 `sort_pub_dependencies` 의 실측 2줄이 0줄로 기록됐다 — 소유자 결정의 근거가 사실과 다르다"
  - id: CR-02
    severity: critical
    disposition: fixed
    title: "`[3/10]` 이 `linter:` 블록 안의 열 0 주석 뒤에 적힌 규칙을 보지 못한다 — 겹침 · `RULES.md` 일치 검사의 거짓 통과"
  - id: WR-02
    severity: warning
    disposition: fixed
    title: "음수인 \"가린 줄\" 이 `0` 으로 찍힌다"
  - id: WR-05
    severity: warning
    disposition: fixed
    title: "`example/README.md` 의 줄 수 · 파일 표가 이 phase 의 샘플을 반영하지 않았다"
  - id: WR-06
    severity: warning
    disposition: fixed
    title: "기반 세트 YAML 에서 규칙을 하나도 읽지 못해도 겹침 검사가 통과한다"
open: 18
total: 24
recorded: 2026-10-13T09:13:21.137Z
---

# Phase 04: Code Review Disposition

| Finding | Severity | Disposition | Source |
|---------|----------|-------------|--------|
| CR-03 | critical | deferred | v2 (RULES-13) 의 선행 작업으로 미룸 — 지금 커밋된 R1 값에는 영향이 없고(R1 때 lib/base.yaml 은 6개), 다음 재측정(lints 7 · Dart 3.14) 전에 기준선 설계부터 정한다; REQUIREMENTS.md RULES-13 옆에 메모 (소유자 결정 2026-10-13) |
| WR-01 | warning | open | - |
| WR-03 | warning | open | - |
| WR-04 | warning | open | - |
| WR-07 | warning | open | - |
| WR-08 | warning | open | - |
| WR-09 | warning | open | - |
| WR-10 | warning | open | - |
| IN-01 | info | open | - |
| IN-02 | info | open | - |
| IN-03 | info | open | - |
| IN-04 | info | open | - |
| IN-05 | info | open | - |
| IN-06 | info | open | - |
| IN-07 | info | open | - |
| IN-08 | info | open | - |
| IN-09 | info | open | - |
| IN-10 | info | open | - |
| IN-11 | info | open | - |
| CR-01 | critical | fixed | 04-11-PLAN.md Task 1 (b567100) — valueAreas · 단언 (7) · --recount; 재리뷰(4397888) 고쳐짐 확인 (not in the current review) |
| CR-02 | critical | fixed | 04-11-PLAN.md Task 2 (c06d8d5) — declaredRuleNames 가 주석 · 빈 줄을 건너뜀, README M26; 재리뷰(4397888) 고쳐짐 확인 (not in the current review) |
| WR-02 | warning | fixed | 04-11-PLAN.md Task 1 (b567100) — countCell 이 부호째 찍음 (-48 · -12); 재리뷰(4397888) 고쳐짐 확인 (not in the current review) |
| WR-05 | warning | fixed | 04-12-PLAN.md Task 3 (9eb8ee5) — README 줄 수 · 파일 표를 정답지에서 다시 셈; 재리뷰(4397888) 고쳐짐 확인 (not in the current review) |
| WR-06 | warning | fixed | 04-11-PLAN.md Task 2 (c06d8d5) — 두 도구가 0규칙이면 FormatException; 재리뷰(4397888) 고쳐짐 확인 (not in the current review) |

Dispositions: `open` (recorded, not yet triaged), `fixed`, `skipped`, `deferred`.
Set `deferred` by hand and put the reason in the Source cell; both are preserved. A `|` in the reason is kept as prose and escaped on the next run.
Re-running the gate keeps every row it can. A row the current review no longer reports is kept and its Source cell flagged, so a finding does not leave this record silently. ONE exception: when a finding id is REUSED by a different finding, the earlier decision cannot keep a row — the id is taken — and it is dropped. A RECORDED decision (anything but `open`) is named on the console when that happens; a row still at `open` is replaced silently, because `open` records no decision to lose.
