---
status: testing
phase: 06-release
source: [06-VERIFICATION.md]
started: 2026-10-16T21:32:14Z
updated: 2026-10-16T21:32:14Z
---

## Current Test

number: 1
name: GitHub 의 Actions → `verify` 화면을 열어 `Run workflow` 버튼이 보이는지 본다
expected: |
  기본 브랜치 `main` 에 `.github/workflows/verify.yml` 이 있으므로 버튼이 보인다 (실행 자체는 `workflow_dispatch` run 38850984674 가 success — 06-06)
awaiting: user response

## Tests

### 1. GitHub 의 Actions → `verify` 화면을 열어 `Run workflow` 버튼이 보이는지 본다 (02-UAT 6번 · D-03 (6) — 06-06 Task 3 의 `<human-check>`, 첫 회차부터 열려 있음)
expected: 기본 브랜치 `main` 에 `.github/workflows/verify.yml` 이 있으므로 버튼이 보인다 (실행 자체는 `workflow_dispatch` run 38850984674 가 success — 06-06)
result: [pending]

### 2. 판정 등급 prohibition 49건(06-01 ~ 06-07 의 25건 + 06-08 ~ 06-11 의 12건 + gap 수정 2회차 06-12 ~ 06-15 의 12건, PLAN frontmatter 의 `MUST NOT`)의 LLM 판정을 06-VERIFICATION.md 「Prohibitions」 표와 지난 회차 표에서 훑어본다
expected: 표의 판정(모두 「지켜짐」 또는 「지켜진 것으로 보임」 — 비권위)에 동의하거나, 다르게 보는 항목을 적는다
result: [pending]

## Summary

total: 2
passed: 0
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps
