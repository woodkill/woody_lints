---
status: testing
phase: 01-baseline-and-toolchain
source: [01-VERIFICATION.md]
started: 2026-10-11T05:26:27Z
updated: 2026-10-11T05:26:27Z
---

## Current Test

number: 1
name: VERSIONING.md 의 판정 순서(25-28행)를 1.3.0 사례와 2.0.0 사례에 직접 대입한다. 1.3.0 은 1번의 두 조건(설정 파일·SDK 를 고쳐야 하나 / 자동 검사가 막힐 수 있나)을 둘 다 따진다
expected: |
  2.0.0 은 1번에서 예 → major 로 나온다(검증자 확인: 문서 어느 곳을 읽어도 같은 답). 1.3.0 은 문서가 minor (2번에서 멈춤) 라고 적었지만, 검증자가 문자 그대로 대입하면 1번의 둘째 조건이 예 로 읽힌다 — riverpod_lint 3.1.3 의 규칙 11개가 WARNING, 1개가 ERROR 이고 dart analyze 는 warning 을 기본으로 실패 처리한다. 소유자가 (가) 지금 문서대로 판정할 수 있다고 받아들이거나 (나) 문서를 고치기로 정한다
awaiting: user response

## Tests

### 1. VERSIONING.md 의 판정 순서(25-28행)를 1.3.0 사례와 2.0.0 사례에 직접 대입한다. 1.3.0 은 1번의 두 조건(설정 파일·SDK 를 고쳐야 하나 / 자동 검사가 막힐 수 있나)을 둘 다 따진다
expected: 2.0.0 은 1번에서 예 → major 로 나온다(검증자 확인: 문서 어느 곳을 읽어도 같은 답). 1.3.0 은 문서가 minor (2번에서 멈춤) 라고 적었지만, 검증자가 문자 그대로 대입하면 1번의 둘째 조건이 예 로 읽힌다 — riverpod_lint 3.1.3 의 규칙 11개가 WARNING, 1개가 ERROR 이고 dart analyze 는 warning 을 기본으로 실패 처리한다. 소유자가 (가) 지금 문서대로 판정할 수 있다고 받아들이거나 (나) 문서를 고치기로 정한다
result: [pending]

### 2. v1.3.0 tag 를 GitHub 에 올리기 전에 확인 패널(올릴 것 · 실행할 명령 · 되돌릴 수 없는 점 · 점검 결과)을 보았고, push 라고 답한 뒤에 push 가 실행되었는지 소유자가 확인한다
expected: 소유자가 패널을 보고 push 를 택한 기억과 01-01-SUMMARY.md 의 기록(응답 04:25:38Z, push 04:27:13Z)이 일치한다
result: [pending]

### 3. prohibition (01-01) — 이 phase 에서 origin 에 올린 것이 tag v1.3.0 하나뿐인지 확인한다
expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. git ls-remote origin 은 HEAD, refs/heads/main (90a2736), refs/tags/v1.3.0 두 줄만 보이고, milestone 브랜치에는 upstream 이 없다
result: [pending]

### 4. prohibition (01-01) — push 한 tag v1.3.0 을 옮기거나 지우지 않았는지 확인한다
expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 원격 tag 객체 SHA 80e2112… 가 로컬과 같고 tagger 시각이 최초 생성 시각 2026-10-11T04:21:51Z 그대로다
result: [pending]

### 5. prohibition (01-02) — 이 phase 에서 README.md, lib/, 루트 analysis_options.yaml 을 바꾸지 않았는지 확인한다
expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. git diff --quiet v1.3.0 HEAD -- lib README.md analysis_options.yaml .gitignore 가 rc=0 이다
result: [pending]

### 6. prohibition (01-03) — main / origin/main 의 lib/ 와 pubspec.yaml 이 1.3.0 그대로이고, sdk ^3.13.0 / version 2.0.0-dev 가 milestone 브랜치에만 있으며 어디로도 push 되지 않았는지 확인한다
expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 원격 main 은 90a2736 (= v1.3.0 의 커밋), 로컬 main 대 v1.3.0 의 lib/ · pubspec.yaml diff 는 rc=0, 커밋 968a5bb 는 main 과 origin/main 의 조상이 아니다
result: [pending]

### 7. prohibition (01-03) — CHANGELOG 의 기존 1.3.0 / 1.0.0 항목을 한 글자도 고치지 않았는지 확인한다
expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. git diff --numstat 90a2736 -- CHANGELOG.md 가 12 추가 / 0 삭제이고 마지막 11행이 git show 90a2736:CHANGELOG.md 와 같다
result: [pending]

## Summary

total: 7
passed: 0
issues: 0
pending: 7
skipped: 0
blocked: 0

## Gaps
