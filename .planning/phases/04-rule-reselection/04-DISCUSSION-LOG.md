# Phase 4: Rule Reselection - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-13
**Phase:** 4-Rule Reselection
**Areas discussed:** 평가표의 모양, 채택 기준과 검토 순서, 근거 문서와 공개 범위, 정답지와 검증 장치

논의 전에 보인 사실 (모두 읽기 전용으로 확인):

- `woodkill/woody_lints` 는 GitHub 에서 공개, `flutter_starter_kit` 은 비공개다
- `flutter_starter_kit` 에 2026-10-13 커밋이 있어 spike 의 수치(2026-10-12)는 최종값으로 쓸 수 없다
- spike 023 이 "소유자에게 물을 일" 로 남긴 `type=lint` 파일 다섯은 다른 도구가 만든 파일이다 (이름이 `*.g.dart` · `*.freezed.dart` 꼴이 아니다)

사전 검색(`workflow.research_before_questions: true`)은 항목 선택 직후 한 번에 돌렸다 — `lints` README 의 세트 기준, very_good_analysis README 의 "Excluded rules", lint 기본 심각도 (검색 요약이 얇아 SDK tag 3.13.4 의 `messages.yaml` 을 직접 받아 심각도 표기 0건을 셈), spike 020 의 결과 JSON 과 FEATURES.md 의 대조 (기반 세트 밖 stable 규칙 129개 모두 FEATURES.md 에 있음).

---

## 평가표의 모양

### 표에 어떤 규칙을 올리나

| Option | Description | Selected |
|--------|-------------|----------|
| A. 전부 잰다 | 버그 방지·성능·스타일 후보, strict 3개, 제외 권장 목록, 지금 켜 둔 6개. v2 로 미룬 규칙은 숫자만 참고로. 약 120줄 | ✓ |
| B. 제외 권장은 재지 않는다 | 제외 권장 목록(약 30개)은 이유만 | |
| C. 좁힌 후보만 | 조사 문서가 "채택 많음" 으로 본 규칙 위주 몇십 개 | |

**User's choice:** A (권고안)

### 평가표의 칸

| Option | Description | Selected |
|--------|-------------|----------|
| A. 고쳐서 쓴다 | `fixStatus` 를 없애고 "dart fix 로 사라진 줄" · "고친 뒤 새로 생긴 error" 를 두며, "무시 주석이 가린 줄" · "함께 쓸 수 없는 규칙" 칸을 더하고 실측 건수는 lib/test 로 나눈다. 로드맵 문구도 고친다 | ✓ |
| B. 로드맵 여섯 칸 그대로 | `fixStatus` 는 "수정 방법이 등록되어 있다" 는 뜻이라고 적고, 가린 줄과 깨진 코드는 비고에 | |

**User's choice:** A (권고안)

### 0줄인 규칙을 어떻게 믿나

| Option | Description | Selected |
|--------|-------------|----------|
| A. 0줄인 후보에만 표식 | 회차마다 공통 표식 + 0줄 후보에만 규칙별 위반 코드 | ✓ |
| B. 모든 후보에 표식 | 약 120개 규칙마다 위반 코드 | |
| C. 공통 표식만 | 정답지 16줄 샘플로 회차가 돌았는지만 | |

**User's choice:** A (권고안)
**Notes:** 항목 끝 확인에서 "다음 항목"

---

## 채택 기준과 검토 순서

### 120개 가까운 규칙을 어떻게 결정하나 (로드맵 D13)

| Option | Description | Selected |
|--------|-------------|----------|
| A. 권고 + 묶음 승인 | Claude 가 규칙마다 권고와 이유, 소유자는 분류 묶음마다 승인·예외 지정. D13 이 이름 붙인 것과 함께 못 쓰는 쌍은 하나씩 | ✓ |
| B. 하나씩 묻기 | 규칙마다 질문 (약 120번) | |
| C. 기준만 정하고 맡기기 | Claude 가 기준을 적용하고 소유자는 결과 목록만 확인 | |

**User's choice:** A (권고안)

### 권고를 만드는 잣대

| Option | Description | Selected |
|--------|-------------|----------|
| A. 분류마다 다르게 | 공통 제외(experimental · 함께 못 씀 · 코드를 깨뜨리는 자동 수정 · v2), 버그 방지·strict 는 실제 문제면 건수 무관, 성능·스타일은 dart fix 가 거의 다 고치거나 손으로 고칠 줄 50 이하, 상태 출처가 갈리면 하나씩 | ✓ |
| B. 숫자 하나 | 분류 무관, 손으로 고칠 줄 N 이하면 켬 | |
| C. 최소한만 | 버그 방지만 더하고 스타일은 지금 것 외에 더하지 않음 | |

**User's choice:** A (권고안)
**Notes:** 50은 추정으로 잡은 값이라고 밝혔다

### 검토할 때 표를 어디서 보나

| Option | Description | Selected |
|--------|-------------|----------|
| A. 터미널 요약 + 파일 | 묶음마다 좁은 표를 터미널에, 전체 표는 저장소 파일 | ✓ |
| B. A + 비공개 웹 페이지 | claude.ai 비공개 페이지로도 띄워 정렬·거르기 | |

**User's choice:** A (권고안)
**Notes:** 항목 끝 확인에서 "다음 항목"

---

## 근거 문서와 공개 범위

### 공개 저장소에 비공개 프로젝트의 무엇까지 적나

| Option | Description | Selected |
|--------|-------------|----------|
| A. 이름 + 건수 | 이름, 규칙별 건수(lib/test), 회차 조건. 경로·메시지·dart fix 화면은 저장소 밖에만. `.planning/` 도 같은 규칙 | ✓ |
| B. 파일별 건수까지 | A + 파일 경로별 건수 | |
| C. 이름도 가림 | "작성자의 앱 프로젝트" 로만. 이미 공개된 문서도 고쳐야 함 | |

**User's choice:** A (권고안)

### 근거 문서의 자리와 모양

| Option | Description | Selected |
|--------|-------------|----------|
| A. 루트 RULES.md 한 파일 | 켠 규칙 표, 켜지 않은 규칙 표, 실측 기록(전체 평가표 + 회차 조건) | ✓ |
| B. 결정과 숫자를 나눔 | RULES.md 에는 결정만, 평가표와 회차 기록은 `.planning/` | |
| C. `.planning/` 에만 | 루트 문서 없음 | |

**User's choice:** A (권고안)

### 측정 도구를 저장소에 남기나

| Option | Description | Selected |
|--------|-------------|----------|
| A. `tool/` 에 커밋 | `tool/measure_rules.dart`, 경로는 인자, 저장소에는 건수만 | ✓ |
| B. 저장소 밖에서만 | spike 처럼, 표와 회차 기록만 커밋 | |
| C. 기록용으로만 커밋 | `.planning/` 에 남기되 실행 도구로 관리하지 않음 | |

**User's choice:** A (권고안)
**Notes:** 항목 끝 확인에서 "다음 항목"

---

## 정답지와 검증 장치

### 새로 켠 규칙을 정답지에 남기나

| Option | Description | Selected |
|--------|-------------|----------|
| A. 켠 규칙마다 샘플 | 규칙마다 위반 샘플 하나 이상, 실수로 지우면 검증이 잡음 | ✓ |
| B. 분류마다 대표 몇 개 | | |
| C. 샘플을 더하지 않음 | 정답지 16줄 그대로 | |

**User's choice:** A (권고안)

### 정답지가 잡지 못하는 두 가지

| Option | Description | Selected |
|--------|-------------|----------|
| A. 둘 다 검사로 | (1) base.yaml 의 규칙이 기반 세트와 겹치면 실패, (2) RULES.md 의 켠 규칙 표와 base.yaml 이 다르면 실패 | ✓ |
| B. 겹침만 검사로 | (1)만, 일치는 실행 기록으로 한 번 | |
| C. 더하지 않음 | 둘 다 실행 기록으로 한 번 | |

**User's choice:** A (권고안)

### Phase 3 이 남긴 검증 빈틈 셋

| Option | Description | Selected |
|--------|-------------|----------|
| A. WR-01 만 닫는다 | 거짓 통과인 WR-01 을 위 검사와 함께. WR-02 는 Phase 5 첫 일, WR-03 은 열어 둠 | ✓ |
| B. 셋 다 닫는다 | 이번 phase 의 첫 일로 | |
| C. 그대로 둔다 | 밟을 때 고침 | |

**User's choice:** A (권고안)
**Notes:** 마지막 항목의 확인은 최종 질문과 합쳤다

---

## 묻지 않고 잡은 것 (마지막 질문 앞에 목록으로 보임)

마지막 질문 "정한 것과 묻지 않고 잡은 것을 그대로 CONTEXT.md 로 적을까요?" 에 소유자가 "CONTEXT 작성" 을 골랐다. 반대는 없었다. CONTEXT 의 D-13 ~ D-23 이다 — `formatter:` 를 넣지 않음, 최종 숫자는 다시 잼, 기본값은 지금 하한의 값, `type=lint` 파일 다섯은 그대로, `unnecessary_ignore` 는 마지막에, 지금 6개도 묶음 검토 + 사유 주석 고침, `strict-inference` 는 warning 임을 알림, 삭제 커밋 먼저, `invalid_annotation_target` 그대로, push 는 Phase 3 방식, 로드맵 정리.

## Claude's Discretion

- 후보의 그룹 나누기, 규칙별 표식의 문법과 자리
- `tool/measure_rules.dart` 의 인자 · 출력 형식, 회차 기록 데이터 파일의 커밋 여부
- apply 를 돌릴 규칙의 범위
- 새 검사를 `tool/verify.dart` 의 어느 단계에 넣을지, 지워 보기 기록의 범위
- 묶음 승인 요약의 분량, CHANGELOG 문구, 측정 원문을 둘 저장소 밖 폴더

## Deferred Ideas

- 평가표의 비공개 웹 페이지 (D-06 에서 고르지 않음 — 필요하면 검토 때 더함)
- WR-02 → Phase 5 첫 일, WR-03 은 열어 둠
- `invalid_annotation_target: ignore` 를 지울지 — 이번에도 다시 재지 않음
- 학습용 프로젝트 넷의 실측 — 하지 않음
- primary constructor 전환 규칙, `migrate_design_widgets`, API 문서 규칙 — v2 (RULES-09 ~ 11)
