# Phase 5: Documentation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-13
**Phase:** 5-Documentation
**Areas discussed:** README 규칙 목록과 자동 검사, README 안내의 모양, CHANGELOG 채우기, YAML 머리 주석

논의 전에 보인 사실 (모두 읽기 전용으로 확인):

- 앞 phase 에서 정해져 다시 묻지 않은 것 — 정식 이름 `recommended.yaml`, README 의 조합은 돌려 본 여섯뿐 (03 D-03), 끄는 방법 세 층 (03 D-04), 생성 파일 제외는 사용 프로젝트에 직접 (Phase 3 UAT 1번), 버전 올리기 두 갈래 (spike 015), `RULES.md` 가 이미 있음 (04 D-08), WR-02 를 가장 먼저 (04 D-12), WR-11 은 VERIFY-06 과 함께, `invalid_annotation_target` 의 기본 강도는 warning (spike 009), `ref:` 예시는 `v2.0.0`
- git 이력의 `pubspec.yaml` 버전 — 1.0.0 과 1.3.0 사이에 1.1.0 · 1.2.0 ~ 1.2.5 의 7개가 있고 tag 는 없다
- `.claude/CLAUDE.md` 181행이 "템플릿 영어 주석은 그대로 둔다" 고 적어 DOCS-10 과 부딪친다

사전 검색(`workflow.research_before_questions: true`)은 항목 선택 직후 한 번에 돌렸다 — very_good_analysis README (켠 규칙은 YAML 링크, 켜지 않은 규칙 표만 표시 구역), `riverpod_lint` 3.1.9 의 pub.dev 설치 안내 (`plugins:` 뿐, `dev_dependencies` 언급 없음), dart.dev 의 git 의존성 문서 (`ref:` 만, `pub get` / `pub upgrade` 차이는 없음 — spike 015 가 쟀다), Keep a Changelog 1.1.0 (버전마다 항목, 커밋 기록은 잡음), `lints` 의 `recommended.yaml` 머리 주석 (8줄, 규칙 줄 주석 없음), `flutter pub get` 이 옵션 파일에 제외 줄을 덧붙이는 동작 (flutter#191151, spike 004).

---

## README 규칙 목록과 자동 검사

### README 에 규칙 목록을 어떤 모양으로 둘까

| Option | Description | Selected |
|--------|-------------|----------|
| 이름만 목록 + 링크 | 분류별로 켠 규칙 이름만 표시 구역 안에 적고, 이유·건수는 RULES.md 로 링크. 검증 명령이 이 목록을 YAML 과 견줌. 요구사항 문구 그대로 | ✓ |
| RULES.md 링크만 | README 에는 분류별 개수와 링크만. 고칠 곳이 하나 줄지만 VERIFY-06 · 성공 기준 3 의 문구를 고쳐야 함 | |
| 이름 + 이유 표 전부 | RULES.md 의 켠 규칙 표를 README 에도 그대로. 이유 문장이 세 곳에 생김 | |

**User's choice:** 이름만 목록 + 링크 (권고안)

### README 자동 검사가 어디까지 볼까

| Option | Description | Selected |
|--------|-------------|----------|
| 목록 + 가리키는 값 셋 | 규칙 이름 목록 + README 의 프리셋 주소가 lib/ 에 있는지 + riverpod_lint 버전 표기 + ref: 예시 버전이 pubspec 과 같은지 | ✓ |
| 규칙 목록만 | 요구사항(VERIFY-06)의 최소. 버전 · 주소가 낡아도 통과 | |
| 값 셋 + 예시 블록 통째 | README 의 include · 끄는 예시를 연습용 프로젝트 옵션 파일과 글자 그대로 견줌. 둘이 묶임 | |

**User's choice:** 목록 + 가리키는 값 셋 (권고안)

**항목 끝 확인:** 다음 항목

---

## README 안내의 모양

질문 전에 "이 항목에서 묻지 않고 잡을 것" 여섯을 보였다 — tag 만 설치 안내 (`ref: main` 은 옮기는 절에서), 2 × 2 표 + include 블록 넷, "핵심가치" 절을 소개 + RULES.md 링크로 교체, 생성 파일 안내는 짧게, SDK 에 따라 다른 동작에 버전 · 날짜, `woody_lints` 는 `dev_dependencies`. 항목 끝 확인에서 "다음 항목" 을 골라 반대하지 않았다.

### README 의 명령을 무엇으로 적을까

| Option | Description | Selected |
|--------|-------------|----------|
| flutter pub … | Flutter 프로젝트의 평소 명령. 잰 것은 dart pub 이라는 점과 제외 줄이 덧붙는다는 메모 한 줄 | ✓ |
| dart pub … | 실측한 명령 그대로 | |
| 둘 다 | 명령 줄마다 두 가지를 나란히 | |

**User's choice:** flutter pub … (권고안)
**Notes:** "같은 pub 이 돈다" 는 spike 004 의 lock 일치에서 읽은 추론이라고 밝혔다.

### 사용 프로젝트 dev_dependencies 의 riverpod_lint 줄을 README 가 어떻게 다룰까

| Option | Description | Selected |
|--------|-------------|----------|
| 필요 없다·지워도 됨 | 진단에 영향 없고 plugin 버전도 정하지 못한다는 실측까지만 적고, 지울지는 읽는 사람이 정함 | ✓ |
| 지우라고 안내 | 업그레이드 절차의 할 일로 넣음 | |
| 언급하지 않음 | README 에서 다루지 않음 | |

**User's choice:** 필요 없다·지워도 됨 (권고안)

**항목 끝 확인:** 다음 항목

---

## CHANGELOG 채우기

### 빠진 버전 7개(1.1.0 ~ 1.2.5)를 어떻게 복원할까

| Option | Description | Selected |
|--------|-------------|----------|
| 버전마다 항목 | 옛 불릿 형식, 날짜 · 커밋 번호, diff 로 확인한 것만. 1.2.1 · 1.2.2 는 "설정 변경 없음" | ✓ |
| 한 항목으로 묶기 | "1.1.0 ~ 1.2.5 (git 이력에서 복원)" 아래 버전별 불릿 | |
| 설정이 바뀐 버전만 | 1.2.1 · 1.2.2 를 뺀다 | |

**User's choice:** 버전마다 항목 (권고안)

### 2.0.0 항목의 "올리기 전에" 에 무엇을 둘까

| Option | Description | Selected |
|--------|-------------|----------|
| 꼭 할 것 + 받는 때 | SDK 조건과 "ref: main 은 pub upgrade 때 받는다" 한 줄. 권하는 일은 README "버전 올리기" 절로 링크 | ✓ |
| 권하는 일까지 여기에 | "꼭 할 것 / 하면 좋은 것" 을 이 칸에 모두 | |
| 지금 두 줄 그대로 | 고치지 않음 | |

**User's choice:** 꼭 할 것 + 받는 때 (권고안)
**Notes:** Phase 1 리뷰 WR-05 (tag 고정 전제)가 이 칸에 걸려 있음을 함께 보였다.

### 2.0.0 항목 "그 밖의 변경" 의 저장소 안쪽 줄을 어떻게 할까

| Option | Description | Selected |
|--------|-------------|----------|
| 한 줄로 합침 | 받는 쪽에 보이는 줄은 그대로, 저장소 안쪽 줄은 "영향 없음" 한 줄로 | ✓ |
| 그대로 둠 | phase 마다 적은 10줄을 모두 남김 | |
| 지움 | 저장소 안쪽 줄을 모두 지움 | |

**User's choice:** 한 줄로 합침 (권고안)

**항목 끝 확인:** 다음 항목

---

## YAML 머리 주석

### 배포 YAML 다섯의 머리 주석을 얼마나 쓸까

| Option | Description | Selected |
|--------|-------------|----------|
| 짧게 | 파일마다 2 ~ 4줄: 주는 것, include 주소, "왜 이 모양인가" 한 줄, README / RULES.md 링크. 사용법·문제 해결은 README 로 | ✓ |
| 자세히 | 사용법·주의점까지 YAML 에도. README 와 같은 내용을 검사 없이 두 곳에 | |
| 템플릿만 지우기 | 나머지는 지금 그대로, codegen.yaml 은 주석 없음 | |

**User's choice:** 짧게 (권고안)

### .claude/CLAUDE.md 의 낡은 서술을 어떻게 할까

| Option | Description | Selected |
|--------|-------------|----------|
| 부딪치는 줄만 | 템플릿 주석 줄과 규칙 추가 절차 줄만 고침. 전체는 마일스톤 끝에 /gsd-map-codebase 로 | ✓ |
| 전부 고치기 | 지금 저장소에 맞게 손으로 다시 씀 | |
| 손대지 않음 | 마일스톤 끝에 한 번에 | |

**User's choice:** 부딪치는 줄만 (권고안)

### 마지막 확인

마지막 질문 앞에 "이번 논의 전체에서 묻지 않고 잡은 것" 일곱을 보였다 — WR-11 을 닫는 방법은 계획에, README 목록의 분류는 `base.yaml` 분류 주석 + "켜지 않은 규칙" 링크, CHANGELOG 의 새로 생기는 경고 표는 그대로 (DOCS-09 는 확인만), README "버전 올리기" 절에 1.3.0 → 2.0.0 의 권하는 일, Phase 1 WR-05 를 닫고 처리 기록에 적음, README · CHANGELOG 에도 비공개 정보 금지, push 는 Phase 4 와 같은 방식(첫 push 만 확인).

**User's choice:** CONTEXT 작성 — 반대 없음 (CONTEXT 에는 "명시적으로 고른 선택지는 아니다" 로 구분해 적었다)

---

## Claude's Discretion

- WR-11 을 닫는 방법 (배포 YAML 다섯에서 규칙을 모으기 / "규칙은 `base.yaml` 에만" 을 검사로 고정)
- README 표시 구역의 이름과 목록의 모양, 검사의 단계 위치 · 번호 · 실패 문구, D-02 (2) ~ (4) 의 읽는 방법
- 새 검사의 지워 보기 기록 (M32 이후)
- README 의 절 순서와 제목, 문제 해결 절의 항목 구성, plugin 준비 실패 복구 안내의 문구
- CHANGELOG 복원 항목의 제목 꼴과 문구
- YAML 머리 주석의 정확한 문구, WR-02 를 닫는 방법, 커밋 나누기

## Deferred Ideas

- 프리셋에 `build/**` 와 플랫폼 폴더 제외를 넣을지 (배포 설정의 내용 변경 — 문서 phase 밖)
- `.claude/CLAUDE.md` 전체 갱신과 `.planning/codebase/` 지도 다시 만들기 (마일스톤 끝 `/gsd-map-codebase`)
- `VERSIONING.md` 30행의 전제 문장 (Backlog `Phase 999.1`)
- Phase 1 리뷰 WR-03 (`VERSIONING.md` 판정 순서와 기준표)
- README 예시 블록을 연습용 프로젝트 옵션 파일과 자동으로 견주기
