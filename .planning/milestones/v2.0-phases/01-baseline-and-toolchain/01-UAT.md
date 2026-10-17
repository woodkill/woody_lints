---
status: complete
phase: 01-baseline-and-toolchain
source: [01-VERIFICATION.md]
started: 2026-10-11T05:26:27Z
updated: 2026-10-11T09:29:40.926Z
---

## Current Test

[testing complete]

## Tests

### 1. VERSIONING.md 의 판정 순서(25-28행)를 1.3.0 사례와 2.0.0 사례에 직접 대입한다. 1.3.0 은 1번의 두 조건(설정 파일·SDK 를 고쳐야 하나 / 자동 검사가 막힐 수 있나)을 둘 다 따진다

expected: 2.0.0 은 1번에서 예 → major 로 나온다(검증자 확인: 문서 어느 곳을 읽어도 같은 답). 1.3.0 은 문서가 minor (2번에서 멈춤) 라고 적었지만, 검증자가 문자 그대로 대입하면 1번의 둘째 조건이 예 로 읽힌다 — riverpod_lint 3.1.3 의 규칙 11개가 WARNING, 1개가 ERROR 이고 dart analyze 는 warning 을 기본으로 실패 처리한다. 소유자가 (가) 지금 문서대로 판정할 수 있다고 받아들이거나 (나) 문서를 고치기로 정한다
result: issue
reported: "권고대로 할께"
severity: major

### 2. v1.3.0 tag 를 GitHub 에 올리기 전에 확인 패널(올릴 것 · 실행할 명령 · 되돌릴 수 없는 점 · 점검 결과)을 보았고, push 라고 답한 뒤에 push 가 실행되었는지 소유자가 확인한다

expected: 소유자가 패널을 보고 push 를 택한 기억과 01-01-SUMMARY.md 의 기록(응답 04:25:38Z, push 04:27:13Z)이 일치한다
result: pass

### 3. prohibition (01-01) — 이 phase 에서 origin 에 올린 것이 tag v1.3.0 하나뿐인지 확인한다

expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. git ls-remote origin 은 HEAD, refs/heads/main (90a2736), refs/tags/v1.3.0 두 줄만 보이고, milestone 브랜치에는 upstream 이 없다
result: pass

### 4. prohibition (01-01) — push 한 tag v1.3.0 을 옮기거나 지우지 않았는지 확인한다

expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 원격 tag 객체 SHA 80e2112… 가 로컬과 같고 tagger 시각이 최초 생성 시각 2026-10-11T04:21:51Z 그대로다
result: pass

### 5. prohibition (01-02) — 이 phase 에서 README.md, lib/, 루트 analysis_options.yaml 을 바꾸지 않았는지 확인한다

expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. git diff --quiet v1.3.0 HEAD -- lib README.md analysis_options.yaml .gitignore 가 rc=0 이다
result: pass

### 6. prohibition (01-03) — main / origin/main 의 lib/ 와 pubspec.yaml 이 1.3.0 그대로이고, sdk ^3.13.0 / version 2.0.0-dev 가 milestone 브랜치에만 있으며 어디로도 push 되지 않았는지 확인한다

expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 원격 main 은 90a2736 (= v1.3.0 의 커밋), 로컬 main 대 v1.3.0 의 lib/ · pubspec.yaml diff 는 rc=0, 커밋 968a5bb 는 main 과 origin/main 의 조상이 아니다
result: pass

### 7. prohibition (01-03) — CHANGELOG 의 기존 1.3.0 / 1.0.0 항목을 한 글자도 고치지 않았는지 확인한다

expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. git diff --numstat 90a2736 -- CHANGELOG.md 가 12 추가 / 0 삭제이고 마지막 11행이 git show 90a2736:CHANGELOG.md 와 같다
result: pass

### 8. VERSIONING.md 를 다시 읽고 판정 순서의 네 질문(25-28행)에 네 가지 변경을 직접 대 본다. (1) 1.3.0 — 그때까지 꺼져 있던 riverpod_lint 규칙을 처음 켰다. 1번 질문의 세 조건을 모두 따진다 (2) 2.0.0 — 지원하는 Dart 최저 버전을 올렸다 (3) 맨 앞자리가 바뀌는 큰 업그레이드 — 기준표의 flutter_lints 6 → 7 줄과 riverpod_lint 3 → 4 줄 (4) 맨 앞자리가 같은 작은 업그레이드 — 기준표의 riverpod_lint ^3.1.3 → ^3.1.9 줄

expected: (1) 1번의 세 조건이 모두 아니오 → 2번 예 → minor. 새로 켜진 규칙 가운데 warning 등급이 있었다는 사실이 적혀 있고, 그것이 왜 1번이 아니라 2번인지 문서만 읽고 납득된다 (2) 1번의 첫째 조건이 예 → major (3) 1번의 둘째 조건이 예 → major (4) 1번 아니오 → 2번 예 → minor. 네 답이 실제 사례 절(63-70행)과 기준표(40-50행)에 적힌 등급과 같다. 검증자가 계산으로 확인한 것 — 두 사례와 기준표 여덟 줄은 문서에 적힌 등급과 같은 답이 나온다. 검증자가 찾은 참고 사항 — (4)의 예시 riverpod_lint 3.1.9 는 그 자체가 Dart 3.13 이상을 요구한다 (3.1.3 은 3.10 이상). 2.0.0 은 Dart 최저 버전을 3.13 으로 함께 올리므로 (4)의 답은 아니오 가 맞다. 다만 문서에는 올리려는 버전이 더 높은 Dart 를 요구하는지 보라는 말이 없다. 이대로 받아들일지 한 문장을 더할지 소유자가 정한다
result: pass

### 9. 리뷰 지적 처리 기록표(01-REVIEW-DISPOSITION.md)의 WR-03 줄에 실행자가 적었던 메모가 지금은 그 표에 없다는 점을 받아들일지 정한다. 메모 내용은 major 행 누락만 닫았고 README/CHANGELOG 만 고침과 새 프리셋 추가는 남았다 는 것이다. 실행이 끝난 뒤 코드 리뷰 도구가 표를 다시 만들면서 그 칸을 비웠다

expected: 둘 중 하나를 고른다. (가) 받아들인다 — 같은 내용이 01-04-SUMMARY.md 243-250행, 새 리뷰 보고서 01-REVIEW.md 의 WR-03 본문, 이 파일(01-UAT.md) Gaps 절 G-01-1 의 마지막 "범위 밖" 줄에 남아 있으므로 표에는 없어도 된다. 이 경우 이 보고서 본문의 overrides 문안을 frontmatter 에 적는다 (나) 표에 다시 적는다 — 다만 열림(open) 상태인 줄의 메모는 리뷰 도구를 다시 돌리면 또 지워진다
result: pass

### 10. prohibition (01-04) — 이번 수정에서 받는 쪽에 전달되는 파일을 건드리지 않았는지 확인한다. 대상은 lib/, README.md, 루트 analysis_options.yaml, pubspec.yaml, .fvmrc, .vscode/, CHANGELOG.md, .gitignore 이고, 버전을 올리지 않았는지와 GitHub 에 아무것도 올리지 않았는지도 본다

expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 23d2674 뒤로 .planning/ 밖에서 바뀐 파일은 VERSIONING.md 하나다. pubspec.yaml 의 version 은 2.0.0-dev 그대로다. GitHub 에는 main (90a2736) 과 이름표 v1.3.0 만 있고, 내 컴퓨터의 main 은 01-04 실행 전(10:28)에 마지막으로 바뀌었다. 작업 브랜치에는 올릴 곳(upstream)이 설정되어 있지 않다
result: pass

### 11. prohibition (01-04) — 확정된 결정 셋(D-04 심각도 상향은 major, D-05 기준표 11줄, D-09 3. 의 1.3.0 = minor · 2.0.0 = major)을 바꾸지 않았는지, 리뷰 지적 WR-03 을 닫지 않고 열어 두었는지 확인한다

expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. VERSIONING.md 의 기준표 13줄은 23d2674 와 같고 01-CONTEXT.md 의 D-05 표와도 같다. 실제 사례의 머리 줄은 minor (2번에서 멈춤) 과 major (1번에서 멈춤) 그대로다. 판정 순서 2 ~ 4번 문장은 바뀌지 않았다. 처리 기록표의 WR-03 은 open 이다
result: pass

### 12. prohibition (01-04) — 결정 기록(01-CONTEXT.md)의 기존 줄을 지우거나 고치지 않고 주석 줄만 덧붙였는지 확인한다

expected: unverified-prohibition — human review recommended. 검증자 판단(비권위): 위반 없음. 23d2674 와 비교하면 추가 2줄, 삭제 0줄이다. 덧붙은 두 줄은 38행(D-02 아래)과 70행(D-09 ① 아래)이고 D-02 와 D-09 ① 의 원문은 글자 그대로 남아 있다
result: pass

## Summary

total: 12
passed: 11
issues: 1
pending: 0
skipped: 0
blocked: 0

## Gaps

- gap_id: G-01-1
  truth: "VERSIONING.md 의 판정 순서(25-28행)를 1.3.0 사례와 2.0.0 사례에 문자 그대로 대입하면 '실제 사례' 절이 적은 등급과 같은 답이 나온다 (1.3.0 은 1번의 두 조건을 모두 따진다)"
  status: resolved
  resolved_by: 01-04-PLAN.md
  resolved_at: 2026-10-11
  reason: "User reported: 권고대로 할께 — 직전에 제시한 권고는 (나) 문서를 고친다 였다. 1.3.0 사례가 1번의 둘째 조건(자동 검사가 막힐 수 있나)을 따지지 않아, 문서가 적은 답(minor)과 문자 그대로 대입한 답(major)이 갈린다"
  severity: major
  test: 1
  root_cause: "판정 순서 1번(VERSIONING.md 25행, 원문 01-CONTEXT.md 68행 D-09 ①)의 둘째 조건 '자동 검사가 막힐 수 있나' 가 기준표 42행의 결과 칸만 질문으로 옮기고 변경 종류 칸('규칙 심각도를 warning 이상으로 올림')을 빠뜨렸다. 기준표와 D-02 는 변경 종류로 등급을 매겨 '처음부터 warning 이상인 규칙을 새로 켬' 을 minor 로 두는데, 결과로 묻는 1번은 같은 변경을 major 로 읽는다. 1.3.0 사례(60-62행)는 변경 종류 기준으로 쓰여 둘째 조건을 답하지 않았다. 구현이 결정 원문에서 벗어난 것이 아니라 확정 결정 문구(D-02, D-04, D-09 ①) 사이의 문구 결함이다"
  artifacts:
    - path: "VERSIONING.md"
      issue: "25행 — 1번 둘째 조건이 결과 기준이라 기준표 42행보다 넓다 (1차 결함 지점)"
    - path: "VERSIONING.md"
      issue: "60-62행 — 1.3.0 사례가 1번의 둘째 조건을 따지지 않는다 (증상 지점)"
    - path: "VERSIONING.md"
      issue: "52행, 54행 — major 의 범위를 각각 좁게('에만')·넓게(결과 기준) 적어 서로 어긋난다 (리뷰 WR-04, 같은 뿌리)"
    - path: ".planning/phases/01-baseline-and-toolchain/01-CONTEXT.md"
      issue: "37행(D-02), 40행(D-04), 68행(D-09 ①), 73행(D-09 3.) — 결함의 원천 문구"
  missing:
    - "판정 순서 1번의 둘째 조건과 기준표 42행의 범위를 일치시킨다"
    - "1.3.0 사례가 1번의 두 조건을 모두 답하고, 그 답이 적힌 등급과 맞는다"
    - "52행과 54행의 major 범위를 25행과 같은 기준으로 맞춘다 (WR-04)"
    - "'자동 검사' 가 어느 명령을 뜻하는지 적는다 (WR-02, 같은 뿌리)"
    - "소유자 결정 (2026-10-11, UAT 뒤 질문): 진단 기록의 방향 (나) '변경 종류 기준으로 좁힘' 을 택했다 — 1번 둘째 조건을 '이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나' 로 좁힌다. 새 규칙을 켜는 것은 warning 등급이어도 minor 이고 1.3.0 사례는 minor 그대로다. 다듬는 결정은 D-09 ① 과 D-02 셋째 문장의 문구이고, D-04 · D-05 · D-09 3. 은 그대로 둔다"
    - "소유자 결정 (2026-10-11, 계획 검토 뒤 질문): 1번 둘째 조건을 좁히면 기준표의 major 행 가운데 `flutter_lints` 다음 major 상향(6 → 7)과 `riverpod_lint` 다음 major 상향(3 → 4)이 판정 순서로는 minor 로 읽히게 된다. 이 두 경우도 1번 질문에 넣어 1번이 기준표의 major 다섯 행을 모두 묻게 한다. 등급 정책(D-05 기준표)은 그대로다"
    - "범위 밖: 리뷰 WR-03 의 나머지 경우(README / CHANGELOG 만 고친 변경, 새 프리셋 파일 추가)는 이 gap 에서 고치지 않는다. WR-03 가운데 major 행 누락만 위 결정으로 함께 고친다"
  debug_session: .planning/debug/versioning-decision-order-1-3-0-mismatch.md

## Deferred Follow-Ups

- test: 8
  idea: "pass, 문장은 나중에 — (기록자 풀이) 8번은 통과이고, VERSIONING.md 30행에 전제 한 문장을 더하는 일만 나중으로 미룬다. 더할 내용: plugin 이나 기반 세트의 하한을 올릴 때는 새 하한 버전이 요구하는 Dart 버전을 보고, 그것이 이 패키지의 SDK 하한보다 높으면 판정 순서 1번의 첫째 조건(SDK 를 고쳐야 하나)이 예 다. 근거: riverpod_lint 3.1.9 는 Dart 3.13 이상, 3.1.3 은 3.10 이상을 요구한다 (01-VERIFICATION.md 의 coincidental_reliance_items)"
  deferred_at: 2026-10-11
