---
status: complete
phase: 03-preset-split
source: [03-VERIFICATION.md]
started: 2026-10-12T13:25:00Z
updated: 2026-10-12T13:34:37.235Z
---

## Current Test

[testing complete]

## Tests

### 1. 성공 기준 3 후반의 범위를 확인한다 — codegen.yaml 을 받아도 생성 파일(*.g.dart)의 riverpod_lint (plugin) 진단은 보고된다
expected: 소유자가 '생성 파일의 진단이 보고되지 않는다' 를 Dart 3.13.4 의 규칙 진단에 대한 말로 받아들인다 (spike 012 의 읽기, 03-03 계획의 범위 문구). 받아들이지 않으면 ROADMAP 성공 기준 3 의 문구를 고치거나 Phase 5 README 에서 범위를 밝히는 일을 정한다
result: pass
note: "소유자 답 '메모' — 규칙 진단 범위로 읽고 통과. Phase 5 README 의 범위 안내를 ROADMAP Phase 5 Notes 에 옮겼다 (아래 Deferred Follow-Ups)"

### 2. 판단형(judgment-tier) 금지 사항 17건의 검증자 판정을 훑어본다 (03-VERIFICATION.md 의 '금지 사항' 표)
expected: 17건 모두 '어기지 않음' 판정에 동의한다
result: pass
note: "plan 의 prohibitions 를 세면 16건 (03-01: 3, 03-02: 4, 03-03: 5, 03-04: 4) 이고 검증 보고서의 표도 16줄이다 — '17건' 은 수 착오. 2026-10-12 근거 명령 16개를 다시 돌려 모두 통과한 뒤 소유자가 pass"
also_covers: 03-04-SUMMARY coverage D3 (push 순서 — 소유자 확인 뒤 한 줄, 두 번째는 묻지 않고)

### 3. CHANGELOG 2.0.0 항목이 나눈 구조를 읽히게 말한다
expected: '## 2.0.0 - 미출시' 의 '올리기 전에' 와 '그 밖의 변경' 불릿(연습 프로젝트 여섯, 조각 셋 · 묶음, 옛 주소 별칭, 루트 제외 걷어냄, 하한 상향)이 몇 달 뒤 소유자가 읽어도 무엇이 바뀌었고 사용 프로젝트가 할 일이 있는지 알 수 있다
result: pass
coverage_id: 03-02 D5, 03-03 D7 (CHANGELOG 쪽)

### 4. example/README.md 가 나눈 구조와 연습용 프로젝트 여섯을 읽히게 설명한다
expected: 3 · 5행의 소개, '## 연습용 프로젝트 여섯' 표, 단계 9개 설명(110행), '추가 실측 (03-03)' 의 M18 · M19 기록이 몇 달 뒤 소유자가 읽어도 각 연습용 프로젝트가 무엇을 증명하고 검증이 무엇을 잡는지 알 수 있다
result: pass
coverage_id: 03-02 D5 (5행), 03-03 D7

## Summary

total: 4
passed: 4
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

## Deferred Follow-Ups

- test: 1
  idea: "메모 — Phase 5 README 가 생성 파일 제외의 범위(Dart 3.13.x 의 규칙 진단만, plugin 진단은 사용 프로젝트 옵션 파일에 직접 적어야 막힘)를 밝힌다"
  deferred_at: 2026-10-12
  moved_to: "ROADMAP.md Phase 5 Notes"
