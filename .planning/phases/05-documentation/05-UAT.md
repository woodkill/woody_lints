---
status: complete
phase: 05-documentation
source: [05-VERIFICATION.md]
started: 2026-10-14T22:35:00Z
updated: 2026-10-14T23:17:24.203Z
---

## Current Test

[testing complete]

## Tests

### 1. README 만 열고 처음부터 끝까지 따라 해 본다 — 설치(dev_dependencies 블록 + flutter pub get), 「프리셋 고르기」 에서 하나 고르기, 「규칙 · plugin 진단 끄기」 의 세 층, 「버전 올리기」 의 세 갈래(tag · ref: main · main → tag)
expected: 다른 문서를 열지 않고 순서대로 따라 할 수 있고, 막히는 단계나 앞뒤가 맞지 않는 안내가 없다
result: pass
note: "소유자 답 '6에서' (2026-10-15) — 통과로 적고, 읽다가 걸릴 수 있는 곳 둘(`flutter create` 템플릿의 기존 `include` · `analyzer:` · `linter:` 와 합치라는 안내 없음, `base.yaml` 만 받는 사람이 「프로젝트 전체」 의 `plugins:` 블록을 붙이면 plugin 이 켜질 수 있음 — 추론)은 Phase 6 smoke test 에서 확인한다. `ref: v2.0.0` tag 가 아직 없는 것은 Phase 6 몫 (VERIFICATION Deferred 1)"

### 2. README 의 「규칙 · plugin 진단 끄기」 · 「생성 파일 제외」 · 「버전 올리기」 · 「문제 해결」 의 단정형 문장마다 spike · fixture 출처, SDK 따라 다른 동작의 SDK 버전 · 날짜, 읽은 것 · 추론 · 추정 표시를 본다
expected: 출처 없는 단정이 없다
result: pass
note: "소유자 답 '6에서' (2026-10-15) — 216 ~ 374행을 RESEARCH §4 와 대조. 355행(Analysis Server 재시작)만 출처 표시가 없다 — spike 기록에 재시작 실측 없음, 1.3.0 주석에서 옮긴 문장. 295행(1.3.0 도 같다)은 아래 불릿의 spike 012 · 016 이 받치고, 373행(caret 범위)은 pub 일반 동작으로 RESEARCH §4 가 단정 분류"
coverage_id: 05-03 D4

### 3. CHANGELOG 1.1.0 ~ 1.2.5 복원 일곱 항목마다 적힌 커밋을 `git show` 로 열어 적힌 변경과 대조한다
expected: 항목의 문장이 diff 의 변경만 말하고 커밋 메시지를 옮기지 않았다 (CHANGELOG 는 `e46cff4` 뒤로 바뀌지 않았다)
result: pass
note: "2026-10-15 커밋 13개(dbcd20b · 212365d · a97fd20 · 9451f6b · 1693a97 · 31c8cb1 · 7b7455e · 21c5689 · 9950fd1 · ec66e3f · 2249a0b · 126aa43 · 9bf0d86)를 git show 로 다시 열어 일곱 항목과 대조 — 어긋남 없음. 1.2.1 은 커밋 메시지('포맷터 부분 추가')가 아닌 diff(포맷터 절을 규칙 목록의 한 항목으로) 쪽대로 적혔다. 적지 않은 것: 212365d 의 include 앞 빈 줄 삭제. git diff --quiet e46cff4 HEAD -- CHANGELOG.md 통과"
coverage_id: 05-04 D2

### 4. README 의 외부 링크 넷을 브라우저로 연다 — flutter#191151 (googlesource 커밋), dart-lang/sdk#64549, dart.dev/tools/pub/workspaces (인용문), pub.dev 의 riverpod_lint 설치 안내
expected: 링크가 열리고, 인용문과 요약이 페이지 내용과 같다
result: pass
note: "소유자 답 '6에서' (2026-10-15) — 넷 모두 열림. sdk#64549 (OPEN · type-bug · P1), Pub workspaces 인용문(글자 그대로, analysis_options.yaml 언급 없음), pub.dev riverpod_lint 3.1.9 (plugins: 만 안내, README 에는 링크 없이 문장만)은 맞다. flutter#191151 은 어긋남 — 2026-08-19 master 병합, stable 판 #191530 (aff2b56c3dc) 이 3.47.2 부터 들어 있다(로컬 SDK git tag --contains). 바뀐 것은 있는 플랫폼 폴더만 제외 · Flutter 아닌 패키지 건너뜀이고 build/** 는 그대로 — README 34행 '고치는 변경이 있다 (병합 여부는 확인하지 않았다)' 가 사실과 다름"

### 5. 검사 범위를 말하는 문장(README 378 · 379 · 380 · 382행, `example/README.md` 11 · 116 · 395 · 436 · 549행, (05-14) 소절의 읽는 법)을 읽고, 검사가 실제로 보는 범위를 오해 없이 전하는지 본다
expected: 문장이 말하는 범위와 지워 보기 기록이 같고, 읽는 사람이 받지 않는 보호를 기대하지 않는다
result: pass
note: "소유자 답 '6에서' (2026-10-15) — 문장의 범위가 지워 보기 기록 · 05-VERIFICATION 판정과 맞다. 걸린 곳 셋: (1) (05-14) 읽는 법 'package:yaml — analyzer · pub 과 같은 해석기' 는 판이 같은지 재지 않았다(VERIFICATION 재지 않은 것), (2) 같은 읽는 법 '깨진 YAML 도 블록 하나로 실패한다' 가 IN-14 (!!float i → 255) 와 다름 — 이미 Phase 6 의 IN-14, (3) README 379행의 '어긋나면 실패' 는 표시 구역 안의 목록 — WR-12 한계는 example/README.md 116 · 549행에만 (그대로 둔다)"
coverage_id: 05-10 D6

### 6. 05-14 · 05-15 의 금지 사항(prohibitions, judgment 등급 — 모두 `flagged: true`)을 05-VERIFICATION.md 「금지 사항 확인」 의 비권위 판정과 견주어 받아들일지 정한다
expected: 기계로 가를 수 있는 부분(고정 커밋 diff 0, 지운 코드 줄 0, push 범위 · 원격 상태)은 검증자가 확인했다 — 남는 것은 '복제본에서만 실험했다' 같은 과정 주장의 수용
result: pass
note: "plan 의 prohibitions 를 세면 10건 (05-14: 6, 05-15: 4). 2026-10-15 읽기 전용 근거 명령을 다시 돌려 모두 맞음 — tool/verify.dart 지운 코드 줄 0, yaml 은 dev_dependencies 만, lib/*.dart 0, pubspec 지운 줄 0, 고정 파일 여덟 diff 0, M1 ~ M85 · README 378 · 379행 불변, WR-06 deferred, skill 1/1 ×3, README hunk 2, 누출 꼴 0, fast-forward · main 90a2736 · tag v1.3.0 하나 · 원격 브랜치 2336ba0 · PR 0, 2336ba0 은 처리 기록 하나만(WR-15 · WR-16 · IN-10 · IN-11 행). 남는 과정 주장(복제본에서만 실험, --force 안 씀)은 반하는 흔적 없음 — 소유자가 pass"

### 7. 배포 YAML 다섯(`lib/base.yaml` · `lib/codegen.yaml` · `lib/riverpod.yaml` · `lib/recommended.yaml` · `lib/analysis_options.yaml`)의 머리 주석을 읽는다
expected: 머리 주석이 읽기 쉽고(어투 · 길이) 파일이 실제로 담은 것과 맞다
result: pass
note: "2026-10-15 다섯 머리 주석을 파일 내용과 대조 — 모두 맞고 '~한다' 체 3 ~ 4줄. 걸린 곳 둘(riverpod.yaml 5행 줄 끝 주석 187자, '옛 analyzer: plugins: 는 아무것도 로드하지 않는다' 에 버전 · 날짜 없음 — 근거는 CHANGELOG 1.3.0)은 배포 파일을 바꾸게 되어 그대로 둔다 — 소유자가 pass"
coverage_id: 05-02 D4

### 8. `example/README.md` 113행(종료 코드 70 의 경우) · 116행(단계 설명)과 실측 소절 다섯 (05-01 · 05-06 · 05-07 · 05-08 · 05-09) 을 읽는다
expected: 기록과 읽는 법 불릿이 '돌린 것' 과 '코드에서 읽은 것 · 따져 본 것' 을 구분해 적고, 표가 깨지지 않고 보인다
result: pass
note: "2026-10-15 읽는 법 불릿이 '코드에서 읽은 것' · '따져 본 것' · '다시 재지는 않았다' 를 일관되게 표시하고, 뒤 소절이 앞 문장을 '그때의 기록' 으로 잇는다(387 · 394 · 440 · 470행 등). 표 여섯(소절 다섯 + 종료 코드 표)은 GFM 칸 수가 머리 줄과 모두 같다. 걸린 곳(400행 '지금의 fencedLines' 에 그때의 표시 없음 — 앞 문장이 05-08 을 가리킴, 116행 한 문단 3,412자, 113행 칸 506자)은 그대로 둔다 — 소유자가 pass"
coverage_id: 05-01 D7, 05-06 D2, 05-07 D5, 05-08 D5, 05-09 D7

## Summary

total: 8
passed: 8
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

## Deferred Follow-Ups

- test: 1
  idea: "6에서 — README 설치 · 「생성 파일 제외」 · 「프로젝트 전체」 블록이 `flutter create` 템플릿의 기존 `include: package:flutter_lints/flutter.yaml` · `analyzer: exclude:` · `linter: rules:` 와 겹친다 — 기존 줄은 바꾸고 같은 키는 합친다는 한 문장을 넣을지, `base.yaml` 만 받는 사람이 `plugins:` 블록을 붙이면 plugin 이 켜지는지를 smoke test 에서 README 대로 따라 하며 확인"
  deferred_at: 2026-10-15
  moved_to: "ROADMAP Phase 6 Notes"
  closed_in: "Phase 6 — 06-02-PLAN.md Task 1 (c9a3225: 「설치」 · 「프로젝트 전체」 · 「생성 파일 제외」 의 합치기 문장), 06-04-PLAN.md Task 3 (D-14 측정 — base.yaml 만 받고 plugins: 블록을 붙이면 plugin 이 켜짐), 06-05-PLAN.md Task 2 (orchestrator 가 README 를 대신 따라 하고 소유자가 화면을 봄 — 막힌 자리 없음)"

- test: 2
  idea: "6에서 — README 355행 'plugins: 를 바꾼 뒤 … Analysis Server 를 재시작해야 반영된다' 에 '(1.3.0 주석에서 옮긴 것, 재 보지 않았다)' 표시를 1번과 같은 README 커밋에서 붙인다"
  deferred_at: 2026-10-15
  moved_to: "ROADMAP Phase 6 Notes"
  closed_in: "Phase 6 — 06-02-PLAN.md Task 1 (c9a3225: 355행 출처 표시)"

- test: 4
  idea: "6에서 — README 34행을 고친다: flutter#191151 은 병합됐고 stable 판 #191530 이 Flutter 3.47.2 부터 들어 있다(3.47.5 가 이미 이 동작). 바뀐 것은 '있는 플랫폼 폴더만 제외 · Flutter 아닌 패키지는 건너뜀' 이고 build/** 는 여전히 덧붙이며 끄는 옵션은 없다 — '고치는 변경 · 병합 여부 확인 안 함' 구절을 뺀다"
  deferred_at: 2026-10-15
  moved_to: "ROADMAP Phase 6 Notes"
  closed_in: "Phase 6 — 06-02-PLAN.md Task 1 (c9a3225: 34행 사실대로)"

- test: 5
  idea: "6에서 — example/README.md (05-14) 소절 읽는 법의 'YAML (package:yaml — analyzer · pub 과 같은 해석기)' 에 '(판이 같은지는 재지 않았다)' 를 덧붙인다. 같은 읽는 법의 '깨진 YAML 도 블록 하나로 실패한다' 는 IN-14 와 함께 고친다. README 379행은 그대로"
  deferred_at: 2026-10-15
  moved_to: "ROADMAP Phase 6 Notes"
  closed_in: "Phase 6 — 06-01-PLAN.md Task 2 (971a6f2: (05-14) 읽는 법 — 판이 같은지는 재지 않았다 · 255 의 범위)"
