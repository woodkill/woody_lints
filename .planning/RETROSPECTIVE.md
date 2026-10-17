# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v2.0 — Package Rework

**Shipped:** 2026-10-17 (패키지 릴리스 `v2.0.0`)
**Phases:** 6 | **Plans:** 56 | **Sessions:** 약 68 (이 프로젝트의 대화 기록 파일 수, 2026-10-11 ~ 10-17)

### What Was Built

- `v1.3.0` 기준점 tag 와 `VERSIONING.md` (등급 판정 · CHANGELOG 형식 · 릴리스 절차)
- `tool/verify.dart` 10단계 + GitHub Actions — 연습용 프로젝트 여섯의 정답지 비교, 배포 파일 구성 · 문서 일치 검사
- 조각 셋 · 묶음 `recommended.yaml` · 옛 주소 별칭으로 프리셋 나누기 (진단 불변)
- `flutter_starter_kit` 복사본 실측(R1, 후보 133개)으로 고른 켠 규칙 81개와 근거 문서 `RULES.md`
- "몇 달 뒤의 내가 따라 하는" README, 복원한 CHANGELOG, 릴리스 확인 `tool/smoke.dart`

### What Worked

- **Spike first:** analyzer · plugin 의 문서화되지 않은 동작(종료 코드, plugin 준비 실패, include 로 받는 `plugins:`, 3단 include)을 spike 23개로 먼저 재고 skill(`spike-findings-woody-lints`)로 묶어 둔 덕에, 계획 단계에서 추측이 줄었다
- **정답지(golden) 비교:** lint 가 info 라 종료 코드로는 증명이 안 되는 것을 줄 · 건수 비교로 풀었다. 프리셋 나누기(구조 변경)와 규칙 재선정(내용 변경)을 갈라, 바뀐 정답지 줄만 리뷰하면 되었다
- **일부러 깨 보기(M1 ~ M115):** 검사를 더할 때마다 틀린 입력을 만들어 그 단계가 실패하는지 실제로 돌리고 `example/README.md` 에 표로 남겼다 — 거짓 통과를 여러 번 잡았다
- **원격 작업 전 확인:** tag push · 브랜치 push · `main` 병합을 실행 직전에 묻고 merge commit 만 써서, tag 를 단 커밋이 `main` 이력에 그대로 남았다
- **쉬운 말 + 권고 한 줄:** 결정을 묻는 자리마다 용어 풀이 · 비교표 · `권고:` 를 두자 되묻는 일이 사라졌다

### What Was Inefficient

- **gap 수정 wave 10개** — Phase 5 가 4회차, Phase 4 · 6 이 2회차. Phase 5 의 회차는 모두 "줄 단위 reader 가 보는 것 ≠ analyzer · pub 이 보는 것" 의 다른 입력이었다. 꼴 하나씩 막다가 4회차에야 `package:yaml` 대조로 종류를 닫았다
- **같은 꼴이 Phase 6 에서 다시 났다** — CHANGELOG 최상단 reader 와 GitHub 화면의 어긋남. "첫 줄 규칙" 으로 종류를 닫기까지 gap 2회차가 들었다
- **기록 동기화 비용:** 뒤 phase 가 앞 phase 의 covered 파일을 고쳐 Phase 1 ~ 5 의 검증 지문이 모두 `stale` 로 끝났고, 닫힌 리뷰 지적이 처리 기록에 `open` 으로 남아 마감 때 손으로 고쳤다
- **측정 도구가 일회성으로 굳음:** `tool/measure_rules.dart` 가 1.3.0 기준선을 박아 두어, 다음 재측정 전에 다시 손봐야 한다 (04:CR-03)

### Patterns Established

- 배포 파일 · 문서를 고치면 `tool/verify.dart` 를 돌리고, 검사를 더할 때는 일부러 깬 입력(Mnn)을 함께 돌려 기록한다
- 규칙은 `lib/base.yaml` · `RULES.md` · README 표시 구역 · CHANGELOG 를 같은 커밋에서 고친다 (`[3/10]` 이 셋을 묶는다)
- reader 가 공식 해석기와 갈릴 수 있으면 꼴을 막지 말고 공식 해석기 값과 견준다 (`[3/10]` (h), CHANGELOG 첫 줄 규칙)
- `main` 은 릴리스 채널 — milestone 브랜치에 쌓고 merge commit PR 로만 합친다
- 사용 프로젝트 실측은 복사본에서, 결과는 건수만 커밋한다 (비공개 프로젝트의 경로 · 메시지 금지)

### Key Lessons

1. 같은 꼴의 gap 이 두 번 나면 입력을 하나 더 막지 말고 그 꼴의 **종류**를 닫는 설계로 바꾼다 — 그럴듯한 틀린 구현과 같은 꼴의 다른 입력을 함께 돌려 확인한다
2. 뒤 phase 가 앞 phase 의 파일을 고치는 계획이면, 검증 지문이 낡는다는 것을 미리 알고 마일스톤 끝에 한 번 정리할 자리를 둔다
3. 측정 도구처럼 "다시 쓸" 도구는 기준선을 하드코딩하지 말고 저장소 상태에서 읽는다
4. 문서의 지시(`.claude/CLAUDE.md`)는 산출물과 함께 낡는다 — 에이전트가 읽는 문서는 phase 마다, 늦어도 마일스톤 끝에 다시 만든다

### Cost Observations

- Model mix: 정확한 비율은 기록하지 않았다. 설정상 planner · plan-checker · researcher · pattern-mapper · debugger 계열은 `fable`, 나머지(executor · verifier · reviewer 등)는 세션 모델(`inherit`)
- Sessions: 약 68
- Notable: gap 수정 wave 10개가 plan 56개의 큰 몫을 차지했다 — 다음 마일스톤에서는 reader · 검사를 설계할 때 Key Lesson 1 을 먼저 적용한다

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v2.0 | 약 68 | 6 | 첫 GSD 마일스톤 — spike first, 정답지 비교, 원격 작업 전 확인 |

### Cumulative Quality

| Milestone | Tests | Coverage | Zero-Dep Additions |
|-----------|-------|----------|-------------------|
| v2.0 | `tool/verify.dart` 10단계 · 연습용 프로젝트 6 · 깨 보기 M1 ~ M115 | 해당 없음 (설정 패키지) | 받는 쪽 의존성 추가 0 (`yaml` · `markdown` 은 `dev_dependencies`) |

### Top Lessons (Verified Across Milestones)

1. (다음 마일스톤에서 다시 확인되면 올린다)
