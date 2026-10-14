---
status: testing
phase: 05-documentation
source: [05-VERIFICATION.md]
started: 2026-10-14T22:35:00Z
updated: 2026-10-14T22:35:00Z
---

## Current Test

number: 1
name: README 만 열고 처음부터 끝까지 따라 해 본다 — 설치(dev_dependencies 블록 + flutter pub get), 「프리셋 고르기」 에서 하나 고르기, 「규칙 · plugin 진단 끄기」 의 세 층, 「버전 올리기」 의 세 갈래(tag · ref: main · main → tag)
expected: |
  다른 문서를 열지 않고 순서대로 따라 할 수 있고, 막히는 단계나 앞뒤가 맞지 않는 안내가 없다
awaiting: user response

## Tests

### 1. README 만 열고 처음부터 끝까지 따라 해 본다 — 설치(dev_dependencies 블록 + flutter pub get), 「프리셋 고르기」 에서 하나 고르기, 「규칙 · plugin 진단 끄기」 의 세 층, 「버전 올리기」 의 세 갈래(tag · ref: main · main → tag)
expected: 다른 문서를 열지 않고 순서대로 따라 할 수 있고, 막히는 단계나 앞뒤가 맞지 않는 안내가 없다
result: [pending]

### 2. README 의 「규칙 · plugin 진단 끄기」 · 「생성 파일 제외」 · 「버전 올리기」 · 「문제 해결」 의 단정형 문장마다 spike · fixture 출처, SDK 따라 다른 동작의 SDK 버전 · 날짜, 읽은 것 · 추론 · 추정 표시를 본다
expected: 출처 없는 단정이 없다
result: [pending]

### 3. CHANGELOG 1.1.0 ~ 1.2.5 복원 일곱 항목마다 적힌 커밋을 `git show` 로 열어 적힌 변경과 대조한다
expected: 항목의 문장이 diff 의 변경만 말하고 커밋 메시지를 옮기지 않았다 (CHANGELOG 는 `e46cff4` 뒤로 바뀌지 않았다)
result: [pending]

### 4. README 의 외부 링크 넷을 브라우저로 연다 — flutter#191151 (googlesource 커밋), dart-lang/sdk#64549, dart.dev/tools/pub/workspaces (인용문), pub.dev 의 riverpod_lint 설치 안내
expected: 링크가 열리고, 인용문과 요약이 페이지 내용과 같다
result: [pending]

### 5. 검사 범위를 말하는 문장(README 378 · 379 · 380 · 382행, `example/README.md` 11 · 116 · 395 · 436 · 549행, (05-14) 소절의 읽는 법)을 읽고, 검사가 실제로 보는 범위를 오해 없이 전하는지 본다
expected: 문장이 말하는 범위와 지워 보기 기록이 같고, 읽는 사람이 받지 않는 보호를 기대하지 않는다
result: [pending]

### 6. 05-14 · 05-15 의 금지 사항(prohibitions, judgment 등급 — 모두 `flagged: true`)을 05-VERIFICATION.md 「금지 사항 확인」 의 비권위 판정과 견주어 받아들일지 정한다
expected: 기계로 가를 수 있는 부분(고정 커밋 diff 0, 지운 코드 줄 0, push 범위 · 원격 상태)은 검증자가 확인했다 — 남는 것은 '복제본에서만 실험했다' 같은 과정 주장의 수용
result: [pending]

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0
blocked: 0

## Gaps
