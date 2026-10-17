# Phase 1: Baseline and Toolchain - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-11
**Phase:** 1-Baseline and Toolchain
**Areas discussed:** 버전 번호 올리는 기준, 기준 문서를 둘 곳, CHANGELOG 항목의 모양, GitHub 에 올릴 범위

소유자가 네 영역을 모두 골랐다. `workflow.research_before_questions` 가 켜져 있어 영역마다 웹 검색으로 참고 사례를 먼저 확인했다.

---

## 버전 번호 올리는 기준

참고 사례: Dart 공식 `lints` / `flutter_lints` 는 규칙 추가를 major 에서만 모아서 낸다. ESLint 는 새 규칙을 minor 로 낸다(검색에 잡힌 것은 README 사본들이라 정확한 문구는 미확인). 이 저장소의 조사 문서 두 편은 큰 틀이 같고 세부 네 곳이 엇갈렸다.

### 규칙을 새로 켜는 변경

| Option | Description | Selected |
|--------|-------------|----------|
| 가운데 자리 (권고) | 2.0.0 → 2.1.0. tag 하나에 고정하고 올리는 시점을 직접 고르므로 예고 없이 받지 않는다. CHANGELOG 에 "새로 생기는 경고" 칸을 반드시 둔다 | ✓ |
| 맨 앞자리 | 2.0.0 → 3.0.0. Dart 공식 묶음의 관례. 규칙 하나마다 앞자리가 올라 SDK 하한 변경과 구별되지 않는다 | |

**User's choice:** 가운데 자리 (권고)

### 규칙을 빼는 변경

| Option | Description | Selected |
|--------|-------------|----------|
| 가운데로 통일 (권고) | 넣든 빼든 규칙 목록이 바뀌면 가운데. 맨 뒷자리는 규칙 목록이 그대로인 변경에만. 조건문이 없고 Phase 4 결과와 무관 | ✓ |
| 조건부 | 기본은 맨 뒤, `unnecessary_ignore` 가 켜져 있는 동안은 가운데. `research/PITFALLS.md` 의 안 | |
| 맨 뒤로 통일 | 항상 맨 뒤. `unnecessary_ignore` 로 생기는 경고는 감수. `research/ARCHITECTURE.md` 의 안 | |

**User's choice:** 가운데로 통일 (권고)
**Notes:** 이 안은 조사 문서에 없던 것으로, Claude 의 판단임을 선택지와 본문에 밝혔다. 근거로 든 것은 "규칙 목록이 바뀌었나 하나만 보면 판정된다"와 "맨 뒷자리가 받아도 아무것도 안 달라진다는 강한 약속이 된다"였다.

### 강도를 warning 이상으로 올리는 변경

| Option | Description | Selected |
|--------|-------------|----------|
| 맨 앞자리 (권고) | 받는 프로젝트의 `dart analyze` 가 통과에서 실패로 바뀔 수 있다. `research/PITFALLS.md` 의 안 | ✓ |
| 가운데 자리 | 규칙 추가와 같은 급. `research/ARCHITECTURE.md` 의 안 | |

**User's choice:** 맨 앞자리 (권고)
**Notes:** 이번 릴리스에는 해당 변경이 없다는 점을 함께 알렸다.

### 다음 버전 번호와 작업 브랜치의 version 표기

| Option | Description | Selected |
|--------|-------------|----------|
| 지금 2.0.0-dev 로 (권고) | Phase 1 에서 SDK 하한을 올리면서 함께 표기. 완성 전 tag 실수를 Phase 6 검사가 막는다 | ✓ |
| 릴리스 직전에 2.0.0 으로 | 그때까지 1.3.0 표기 유지. 단순하지만 version 과 내용이 어긋난다 | |

**User's choice:** 지금 2.0.0-dev 로 (권고)
**Notes:** 2.0.0 이라는 번호는 방금 정한 기준을 이번 릴리스의 변경에 대입해 보였다(SDK 하한 상향이 major).

### 마무리 확인

합친 기준표 11줄을 보였다. "exclude / errors 설정 = minor" 와 "저장소 안쪽만 = 올리지 않음" 두 줄은 Claude 가 덧붙인 것임을 밝혔다.

| Option | Description | Selected |
|--------|-------------|----------|
| 다음 영역으로 | 기준표를 그대로 확정 | ✓ |
| 더 질문하기 | 고치고 싶은 줄이나 표에 없는 경우를 더 다룸 | |

**User's choice:** 다음 영역으로

---

## 기준 문서를 둘 곳

참고 사례: ESLint 와 `dart_flutter_team_lints` 는 정책을 README 에 둔다. Keep a Changelog 는 CHANGELOG 머리말에 형식을 적는다. 이 저장소는 README 를 Phase 5 에서 통째로 다시 쓴다는 사정이 있다.

### 어디에 적을지

| Option | Description | Selected |
|--------|-------------|----------|
| 별도 파일 하나 (권고) | 버전 기준과 CHANGELOG 형식을 한 파일에. Phase 1 에서 완결, README 는 Phase 5 에서 링크만 | ✓ |
| README 의 한 절 | 가장 눈에 띄지만 README 가 길어지고 두 번 손본다 | |
| CHANGELOG 머리말 | 형식 설명이 그 파일 안에 있지만 변경 기록이 아래로 밀린다 | |

**User's choice:** 별도 파일 하나 (권고)

### 파일 위치와 이름

| Option | Description | Selected |
|--------|-------------|----------|
| 맨 위에 VERSIONING.md (권고) | README.md, CHANGELOG.md 와 나란히. 이름이 내용을 말해 준다 | ✓ |
| docs/ 폴더 안에 | Phase 4 의 근거 문서도 같은 폴더에 모을 수 있다 | |
| 맨 위에 CONTRIBUTING.md | 릴리스 절차까지 모을 수 있지만 이름만으로는 버전 기준이 들어 있는지 모른다 | |

**User's choice:** 맨 위에 VERSIONING.md (권고)

### 문서의 깊이

| Option | Description | Selected |
|--------|-------------|----------|
| 판정 순서 + 표 + 예시 (권고) | 차례로 묻는 판정 순서, 전체 기준표, 실제 사례 대입. 쉬운 말 병기 | ✓ |
| 기준표만 | 한눈에 들어오는 짧은 문서 | |
| Claude 가 정하기 | 구성은 계획 단계에 맡김 | |

**User's choice:** 판정 순서 + 표 + 예시 (권고)

### 마무리 확인

| Option | Description | Selected |
|--------|-------------|----------|
| 다음 영역으로 | 확정 | ✓ |
| 더 질문하기 | 위치나 구성을 더 다룸 | |

**User's choice:** 다음 영역으로

---

## CHANGELOG 항목의 모양

참고 사례: Keep a Changelog 1.1.0 (고정 칸, 빈 칸 생략, ISO 날짜, 미출시 칸), Dart `lints` (추가 / 제거 + 최소 SDK), 이 저장소의 기존 형식(자유 불릿, 날짜 없음).

**진행 중 실수:** 이 영역의 첫 질문이 영역 소개와 참고 사례 없이 먼저 나갔다. 답을 받은 뒤 소개와 참고 사례를 붙이고, 고른 안이 참고 사례와 맞는다는 점을 알렸다.

### 칸 구성

| Option | Description | Selected |
|--------|-------------|----------|
| 필수 두 칸 + 해당 칸만 (권고) | "지원 SDK"와 "새로 생기는 경고"는 항상, 나머지 네 칸은 해당 시에만. 제목에 날짜 | ✓ |
| 여섯 칸 항상 다 적기 | 해당 없으면 "없음". 작은 변경에도 항목이 길어진다 | |
| 지금처럼 불릿 + 경고 표 | 자유 불릿에 경고 표만 덧붙임. 버전마다 모양이 달라지기 쉽다 | |

**User's choice:** 필수 두 칸 + 해당 칸만 (권고)
**Notes:** 세 안을 가상의 2.1.0 예시로 나란히 보였다. 고른 예시는 CONTEXT.md 의 Specific Ideas 에 옮겼다.

### 실측 조건을 남기는 방법

| Option | Description | Selected |
|--------|-------------|----------|
| 표 아래 한 줄 (권고) | 잰 대상, Flutter 버전, 날짜를 한 줄로. 자세한 회차 기록은 근거 문서에 | ✓ |
| 표만 | 조건은 Phase 4 의 근거 문서에서만 찾음 | |

**User's choice:** 표 아래 한 줄 (권고)

### 2.0.0 항목을 쓰기 시작하는 때

| Option | Description | Selected |
|--------|-------------|----------|
| 지금 만들어 채워 나감 (권고) | Phase 1 에서 "미출시" 자리를 만들고 phase 마다 자기 변경을 적음. Phase 5 는 다듬기와 점검 | ✓ |
| Phase 5 에서 한 번에 | 로드맵 원안. CHANGELOG 는 Phase 5 까지 그대로 | |

**User's choice:** 지금 만들어 채워 나감 (권고)
**Notes:** 로드맵 원안에서 바뀐 부분이다. Phase 5 의 DOCS-07 / DOCS-09 가 "작성"에서 "다듬기와 점검"으로 바뀐다.

### 마무리 확인

Claude 가 기본값으로 잡은 세 가지를 밝혔다: 날짜 형식 `YYYY-MM-DD` 와 릴리스 전 "미출시" 표기 / `dart fix` 열은 건수 / 새 형식은 2.0.0 부터, 이전 항목은 그대로.

| Option | Description | Selected |
|--------|-------------|----------|
| 다음 영역으로 | 기본값을 포함해 확정 | ✓ |
| 더 질문하기 | 기본값을 바꾸거나 더 다룸 | |

**User's choice:** 다음 영역으로

---

## GitHub 에 올릴 범위

참고 사례: 릴리스 tag 는 이름을 지정해 하나만 push 하는 것이 권장된다. `--tags` 는 의도하지 않은 tag 까지 보낸다. 브랜치와 tag 는 따로 움직인다.

논의 전에 확인한 사실: 로컬에만 있는 것은 (1) 아직 만들지 않은 `v1.3.0` tag (2) `main` 의 `.planning/` 커밋 7개 (3) milestone 브랜치다. tag 는 이미 원격에 있는 commit 에 붙으므로 tag 만 올릴 수 있다. 저장소는 공개 저장소이고 기획 문서에 민감 정보는 없다.

### 올릴 범위

| Option | Description | Selected |
|--------|-------------|----------|
| 이름표만 (권고) | `v1.3.0` tag 하나만. 작업 브랜치는 Phase 2 에서 다시 확인받고 올림 | ✓ |
| 이름표 + 작업 브랜치 | 작업 사본이 GitHub 에 생기지만 기획 문서가 지금부터 공개된다 | |
| 전부 (main 포함) | `ref: main` 사용 프로젝트 5개가 다음 `pub upgrade` 때 기획 문서가 딸린 새 commit 을 받는다 | |

**User's choice:** 이름표만 (권고)

### 올리는 시점

| Option | Description | Selected |
|--------|-------------|----------|
| 맨 처음에 (권고) | 무엇이든 바꾸기 전에 기준점부터 확보. 조사 문서의 권고 | ✓ |
| 맨 끝에 | 다른 작업이 확인된 뒤 원격 작업을 마지막에 한 번 | |

**User's choice:** 맨 처음에 (권고)

### push 명령의 실행 주체

| Option | Description | Selected |
|--------|-------------|----------|
| 확인 후 Claude 가 실행 | 올릴 것, 명령, 되돌릴 수 없다는 점을 보이고 "예"를 받은 뒤 실행하고 결과를 확인해 보고 | ✓ |
| 직접 실행 | Claude 는 점검까지만. 명령 한 줄을 소유자가 직접 입력 | |

**User's choice:** 확인 후 Claude 가 실행
**Notes:** 이 질문에는 권고안을 붙이지 않았다. 원격에 남는 동작을 어디까지 맡길지는 소유자의 선호라고 보았다.

### 마무리 확인

네 영역 전체의 결정을 표 한 장으로 요약하고, 이 영역에서 Claude 가 기본값으로 잡은 것(tag 메시지 두 줄, tag 이름만 지정해 push, GitHub Releases 페이지는 만들지 않음)을 밝혔다.

| Option | Description | Selected |
|--------|-------------|----------|
| 정리 문서 작성으로 | 결정을 CONTEXT.md 로 정리하고 커밋 | ✓ |
| GitHub 범위 더 질문하기 | 이 영역의 기본값을 바꾸거나 더 다룸 | |
| 다른 부분 더 살펴보기 | 네 영역 밖의 미정 사항을 더 찾아 제시 | |

**User's choice:** 정리 문서 작성으로

---

## Claude's Discretion

소유자에게 묻지 않고 조사·계획 단계에 맡긴 것.

- tag 메시지의 문구 (기본값 제시: 한국어 두 줄)
- VERSIONING.md 의 절 순서, 문장, 예시 개수
- `fvm use 3.47.5` 의 실행 방식과 `--force` 필요 여부
- `.vscode/settings.json` 의 SDK 경로를 맞추는 방법
- "Dart 3.13 미만에서 `pub get` 이 실패한다"를 확인하는 방법과 증거를 남길 자리
- `sdk` 하한 변경, `version` 변경, CHANGELOG 항목 추가의 커밋 분할

## Deferred Ideas

- milestone 브랜치를 올리면 `.planning/` 이 공개된다는 점을 Phase 2 의 push 확인 때 다시 알린다
- REL-03 일치 검사가 CHANGELOG 제목의 "미출시" 를 거부하게 할지 — Phase 6
- 릴리스 절차 문서의 자리 — Phase 6
- Phase 4 근거 문서의 자리 (루트 / `docs/`) — Phase 4
- 1.3.0 이전 CHANGELOG 제목에 날짜를 붙일지 — Phase 5 (DOCS-08)
