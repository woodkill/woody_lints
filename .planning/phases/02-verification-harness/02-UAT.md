---
status: complete
phase: 02-verification-harness
source: [02-VERIFICATION.md]
started: 2026-10-12T01:49:55Z
updated: 2026-10-12T02:54:33.313Z
---

## Current Test

[testing complete]

## Tests

### 1. 통과 화면과 실패 화면이 안내로 읽히는가
expected: 방법 — `fvm dart run tool/verify.dart` 를 한 번 돌리고, `lib/analysis_options.yaml` 의 `- prefer_final_locals` 줄을 잠시 주석 처리한 뒤 한 번 더 돌려 두 화면을 `02-CONTEXT.md` 의 미리보기와 나란히 본다. 끝나면 `git checkout -- lib/analysis_options.yaml`. 기대 — 통과 화면은 버전 3줄, 단계 4줄, `점검 통과 (4개 중 4개)`. 실패 화면은 `[4/4] … 실패` 아래 `정답지에는 있는데 나오지 않은 경고 (1)` 과 그 줄, `--update` 안내, `점검 실패 (4개 중 1개)`. 화면만 보고 무엇이 달라졌고 다음에 무엇을 하면 되는지 안다. (02-02 Task 2 의 human-check, D-13 — 문자열과 순서는 실행으로 확인됐고, 안내로 읽히는가는 소유자의 판단이다)
result: pass

### 2. M1 ~ M9 기록이 읽히는가
expected: 방법 — `example/README.md` 의 `## 검증이 실제로 잡아내는지 확인한 기록` 절(M1 ~ M9 표와 읽는 법)을 읽는다. 기대 — 표만 보고 규칙 하나를 지우면 어느 줄이 빠지는지, include 를 지우면 16줄이 사라지고 다른 warning 이 나타나 종료 코드가 그대로라는 점, deprecated 규칙은 규칙 이름 검사가 잡는다는 점이 읽힌다. (02-03 Task 2 의 human-check, VERIFY-08 — 기록의 사실은 M1 · M2 · M6 을 다시 만들어 확인됐다)
result: pass

### 3. 추가 실측 M10 ~ M14 소절이 읽히는가
expected: 방법 — `example/README.md` 의 `### 추가 실측 — 건수 비교 · --update 안전장치 · 규칙 0개 (gap 닫기 02-05)` 소절(M10 ~ M14 표와 불릿 다섯)을 읽는다. 기대 — 같은 줄이 두 번 나오는 입력에서 어느 쪽 목록에 한 줄이 잡히는지, 다른 단계가 실패한 실행에서 `--update` 가 쓰지 않고 무엇을 찍는지, 규칙을 하나도 읽지 못하면 `[2/4]` 가 실패하고 Phase 3 이 규칙 파일을 옮길 때 무엇을 함께 옮겨야 하는지가 읽힌다. (02-05 Task 3 의 human-check — 표의 다섯 행과 불릿의 사실은 다시 실행해 확인됐다)
result: pass

### 4. PR 을 열면 verify 가 도는가
expected: 방법 — 이 저장소에 PR 이 처음 열릴 때 GitHub 의 Actions 탭에 `verify` 실행이 `pull_request` event 로 생기는지 본다. 기대 — PR 의 커밋에서 `verify` 가 실행되고 단계 4개가 통과한다. (성공 기준 5, VERIFY-04 — `pull_request:` 는 선언되어 있지만 PR 이 한 번도 열리지 않았고 D-10 이 점검용 PR 을 미리 열지 않기로 했다)
result: skipped
reason: "Deferred follow-up: 나중에"

### 5. 다음 push 뒤 그 커밋의 verify 실행이 성공하는가
expected: 방법 — 다음에 작업 브랜치를 올린 뒤(D-09 대로 소유자 확인 후) 그 커밋의 `verify` 실행을 본다. 기대 — `completed` / `success`, 로그에 `점검 통과 (4개 중 4개)`. (GitHub 에서 성공한 실행은 `1f06c55` 의 것 하나다. 02-05 가 바꾼 `tool/verify.dart` 는 올라가지 않아 Linux runner 에서 돈 적이 없다 — 로컬에서는 같은 SDK 로 통과한다)
result: pass

### 6. 수동 실행 버튼이 동작하는가
expected: 방법 — workflow 파일이 `main` 에 들어간 뒤 GitHub 의 Actions → verify 화면에서 `Run workflow` 버튼을 눌러 본다. 기대 — 버튼이 보이고, 누르면 `workflow_dispatch` event 의 실행이 생겨 통과한다. (버튼은 기본 브랜치에 workflow 파일이 있어야 나타난다. 릴리스 전에는 볼 수 없다 — D-06)
result: skipped
reason: "Deferred follow-up: 나중에"

### 7. 겹치는 실행이 취소되는가
expected: 방법 — 같은 브랜치에 커밋을 연달아 두 번 올린다 (앞선 실행이 약 2분 도는 동안). 기대 — 앞선 실행이 `cancelled` 로 끝나고 뒤 실행만 끝까지 돈다. (`concurrency` 블록은 파일에 있지만 실행이 지금까지 1건이라 취소가 일어난 적이 없다 — behavior-unverified)
result: pass

### 8. 금지 사항 P1 ~ P16 확정
expected: 방법 — `02-VERIFICATION.md` 의 `Prohibitions` 표 P1 ~ P16 을 증거와 함께 읽고 건마다 확정한다. 기대 — P1 · P2 · P4 ~ P9 · P13 ~ P16 은 증거가 분명하다. P3 (돌리지 않았다는 증명 불가) · P10 (입력된 명령은 기록뿐) · P11 (해당 상황 없음) 은 소유자의 판단이 들어간다. P12 의 tag 쪽은 2026-10-12 소유자 결정(D-10 덧붙임)으로 정리됐다. (16건 모두 계획이 `verification: judgment` 로 둔 것이라 검증기의 판정은 참고용이다)
result: pass

### 9. 남은 --update 경로와 README 문구를 Phase 4 전에 닫을지 정한다
expected: 방법 — `02-VERIFICATION.md` 의 `다음 phase 가 알아야 할 것` 1 · 2 를 읽고 닫을지 그대로 둘지 정한다 — (a) `[2/4]` 가 통과로 잘못 찍히는 세 입력에서 `--update` 가 망가진 정답지를 쓰고 종료 코드 0 으로 끝난다, (b) `example/README.md` 80행과 `[2/4]` 의 실패 문구가 "`rules:` 목록이 비어 있거나 없으면" 이라고 말하지만 코드는 `rules:` 키를 보지 않는다. 기대 — 닫는다면 gap 닫기 plan 을 하나 더 세운다. 두면 README 80행 · 30행의 문장을 코드가 실제로 보는 것에 맞출지 정한다. (이 phase 의 성공 기준은 깨지지 않는다 — 보통 실행은 세 입력 모두 종료 코드 1 이다. 남은 위험을 받아들일지는 소유자의 결정이다)
result: pass

## Summary

total: 9
passed: 7
issues: 0
pending: 0
skipped: 2
blocked: 0

## Gaps

## Deferred Follow-Ups

- test: 4
  idea: "나중에 — (기록자 풀이) PR 에서 `verify` 가 도는지는 이 저장소에 PR 이 처음 열릴 때 본다. `.github/workflows/verify.yml` 에 `pull_request:` 가 조건 없이 선언되어 있지만 PR 이 열린 적이 없고 (2026-10-12 `gh pr list --state all` 0건), D-10 이 점검용 PR 을 미리 열지 않기로 했다. 처음 열릴 만한 때는 Phase 6 의 `main` 병합이다 — 그때 Actions 탭에 `pull_request` event 의 `verify` 실행이 생기고 단계 4개가 통과하는지 본다"
  deferred_at: 2026-10-12

- test: 6
  idea: "나중에 — (기록자 풀이) 수동 실행 버튼은 workflow 파일이 `main` 에 들어간 뒤에 본다. `.github/workflows/verify.yml` 에 `workflow_dispatch:` 가 선언되어 있지만 `main` (`90a2736`) 에는 `.github/workflows/` 가 없고, GitHub 은 기본 브랜치에 workflow 파일이 있어야 버튼을 보여 준다 (D-06). `main` 병합은 Phase 6 이다 — 릴리스 뒤 Actions → verify 화면에서 `Run workflow` 버튼이 보이는지, 누르면 `workflow_dispatch` event 의 실행이 생겨 통과하는지 본다"
  deferred_at: 2026-10-12

- test: 9
  idea: "3에서 — (기록자 풀이) 9번은 결정 항목이고 답은 'Phase 3 에서 닫는다' 다 (선택지: 3에서 / 지금 / 문구만 / 그대로). Phase 3 이 정답지를 새로 쓰거나 fixture 를 더하기 전에 가장 먼저 한다: (1) `[2/4]` 가 통과로 잘못 찍히는 세 입력(닫지 않은 따옴표로 깨진 YAML, `rules:` 키의 오타, 겹친 규칙 + 없는 진단 코드)에서 `--update` 가 망가진 결과를 정답지로 쓰고 종료 코드 0 으로 끝나는 경로를 닫는다 — 02-05 가 일부러 넣지 않은 WR-03 의 다른 절반(세 코드 밖의 진단도 실패로 치기)을 뒤집는 결정이다 (2) `example/README.md` 80행 · 30행과 `[2/4]` 의 실패 문구를 코드가 실제로 보는 것에 맞춘다. 근거: 02-VERIFICATION.md 의 '다음 phase 가 알아야 할 것' 1 · 2 (검증기가 셋 다 재현), 2026-10-12 UAT 에서 `rules:` → `rulez:` 를 복사본에서 다시 재현 — 보통 실행 exit 1, `--update` 는 `정답지를 썼다` + `점검 통과 (4개 중 4개)` + exit 0, 그 뒤의 보통 실행도 exit 0"
  deferred_at: 2026-10-12
