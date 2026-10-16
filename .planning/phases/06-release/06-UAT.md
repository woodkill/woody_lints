---
status: complete
phase: 06-release
source: [06-VERIFICATION.md]
started: 2026-10-16T21:32:14Z
updated: 2026-10-16T23:27:37.651Z
---

## Current Test

[testing complete]

## Tests

### 1. GitHub 의 Actions → `verify` 화면을 열어 `Run workflow` 버튼이 보이는지 본다 (02-UAT 6번 · D-03 (6) — 06-06 Task 3 의 `<human-check>`, 첫 회차부터 열려 있음)
expected: 기본 브랜치 `main` 에 `.github/workflows/verify.yml` 이 있으므로 버튼이 보인다 (실행 자체는 `workflow_dispatch` run 38850984674 가 success — 06-06)
result: pass

### 2. 판정 등급 prohibition 49건(06-01 ~ 06-07 의 25건 + 06-08 ~ 06-11 의 12건 + gap 수정 2회차 06-12 ~ 06-15 의 12건, PLAN frontmatter 의 `MUST NOT`)의 LLM 판정을 06-VERIFICATION.md 「Prohibitions」 표와 지난 회차 표에서 훑어본다
expected: 표의 판정(모두 「지켜짐」 또는 「지켜진 것으로 보임」 — 비권위)에 동의하거나, 다르게 보는 항목을 적는다
result: pass
note: "PLAN 에서 다시 세어 49건 (25 + 12 + 12). 근거 명령을 읽기 전용으로 다시 돌림 — tag 704bf56 그대로, 소유자 응답 뒤 tag push · 병합 넷, merge commit 셋 부모 둘, v2.0.0..main 에서 lib/ · CHANGELOG · version · lock · workflow · .claude/CLAUDE.md 변경 0, gap 수정 커밋 13개가 계획된 파일만, 실제 홈 경로 0. expected 의 '모두 지켜짐/지켜진 것으로 보임' 은 부정확 — 1회차 표에 '판정 불가 (과정)' 4줄; 셋은 이번에 근거 생김, 06-01 '복제본에서만' 하나는 증명 불가 · 흔적 없음"

### 3. VERSIONING.md 「릴리스 절차」 1 ~ 10 단계가 이번 v2.0.0 릴리스에서 실제로 밟은 순서와 맞는지 본다 (SUMMARY 의 사람 판단 중 UAT 에 없던 것)
coverage_id: 06-02 D2
expected: 단계마다 06-04 ~ 06-06 (과 gap 수정 뒤 06-15 의 두 번째 병합)에서 실제로 한 일과 견준 표에 어긋난 단계가 없다 — 다음 릴리스 때 이 절만 보고 따라 할 수 있다
result: pass
note: "1 ~ 10 단계는 실제와 모두 맞음 (6단계 로그 줄 · 2단계 numstat · 9단계 PR #1 을 다시 확인; 10단계는 아직 해당 없음). 짚은 것 둘 — (1) 릴리스 뒤 main 의 pubspec.yaml 이 dev_dependencies markdown · 주석 3줄로 바뀌었는데 version 2.0.0 그대로: 판정 순서 3번 · 기준표 '주석만 고침 → patch' 를 글자대로 읽으면 2.0.1, 계획서는 '저장소 안쪽만 바뀜 → 올리지 않음' 으로 판단했으나 그 행에 pubspec.yaml 이 없음 (받는 쪽에 닿지 않아 버전은 그대로 둠); (2) README ref: 예시는 2단계와 달리 Phase 5 에서 미리 바뀜 — 다음 릴리스부터 문서대로, 고칠 것 없음"

### 4. smoke 도구의 남은 위험 둘을 알려진 한계로 받아들일지 정한다 (SUMMARY 의 사람 판단 중 UAT 에 없던 것)
coverage_id: 06-13 D5
expected: 하네스로 일으킬 수 없어 소스로만 본 두 경우 — (i) 임시 폴더를 지우는 도중 다시 누른 Ctrl-C, (ii) 끊으려던 자손 프로세스 번호(pid)가 그새 다른 프로세스에 재사용됨 — 가 릴리스 때 손으로 돌리는 smoke 에서만 생기는 드문 일임을 보고 받아들이거나, 고칠 것을 적는다
result: pass
note: "알려진 한계로 받아들임 — (i) finally 가 cleanup() 뒤에 처리기를 내림 (1139 → 1140행), 지우는 도중의 Ctrl-C 는 지우기 뒤 130; (ii) 얼린 뒤 끊기 직전 표 재확인, 사슬 밖은 SIGCONT 만 (428행). smoke 는 릴리스 때 소유자만 돌림 (README 언급 0). 재현된 비슷한 구멍 IN-11 은 ROADMAP Backlog 999.2 에 이미 있음"

## Summary

total: 4
passed: 4
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

## Deferred Follow-Ups

- test: 3
  idea: "VERSIONING.md 「판정 순서」 3번과 기준표에 'pubspec.yaml 의 dev_dependencies · 저장소 도구용 주석만 바뀐 것은 받는 쪽에 닿지 않으므로 저장소 안쪽(올리지 않음)' 을 정리한다 — 2.0.0 뒤 gap 수정(markdown dev 의존성 · 주석 3줄)이 버전을 올리지 않은 근거를 문서가 그대로 뒷받침하게"
  deferred_at: 2026-10-17
  moved_to: "ROADMAP Backlog 999.3"
