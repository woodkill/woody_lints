# Phase 6: Release - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-15
**Phase:** 6-Release
**Areas discussed:** 릴리스 순서 · main 병합, 버전 일치 검사 (REL-03), smoke test 의 모양, 릴리스 절차 문서 · 미룬 손질

설정 `workflow.research_before_questions: true` 에 따라 항목마다 질문 전에 찾아본 것을 출처와 함께 보였다. 소유자는 결정 질문 12개 모두에서 권고안을 골랐고, 항목 끝 확인은 모두 "다음 항목" 또는 "CONTEXT 를 써 주세요" 였다.

---

## 릴리스 순서 · main 병합

### 릴리스 순서와 main 병합을 어떻게 할까요?

| Option | Description | Selected |
|--------|-------------|----------|
| A. tag → smoke → PR 병합 (권고) | 브랜치의 릴리스 커밋에 tag → smoke test → 이 phase 안에서 PR 을 열어 merge commit 으로 main 에 합침. PR 실행 · 수동 버튼 확인까지 여기서 닫음 | ✓ |
| B. tag → smoke → PR 없이 합침 | A 와 같은 순서, 병합은 로컬 fast-forward + push. PR 확인은 '해당 없음', 수동 버튼만 확인 | |
| C. 병합은 마일스톤 끝에 | 이 phase 는 tag 와 smoke test 까지. main 병합과 Phase 2 의 미룬 확인 둘은 /gsd-complete-milestone 에서 | |
| D. main 먼저, 병합 커밋에 tag | main 에 합친 뒤 그 커밋에 tag. 문제가 보이면 main 은 이미 2.0.0 | |

**User's choice:** A
**Notes:** 질문 앞에 보인 근거 — GitHub 의 "Rebase and merge" 는 항상 새 커밋 번호를 만들고 순수 fast-forward 버튼은 없다. `workflow_dispatch` 는 workflow 가 기본 브랜치에 있어야 동작한다. `/gsd-complete-milestone` 은 squash 를 권고안으로 제안한다. origin 의 `main` 은 작업 브랜치의 조상이다. 묻지 않고 잡은 셋을 보였고(`.planning/` 이 tag 커밋에 실림 · 약 8.5MB, 브랜치 push 는 D-21 · tag push 와 병합은 직전 확인, complete-milestone 의 병합 제안은 Keep branches), 항목 끝 확인에서 "다음 항목" 을 골랐다 — 반대 없음.

---

## 버전 일치 검사 (REL-03)

### 버전 일치 검사를 언제 돌릴까요?

| Option | Description | Selected |
|--------|-------------|----------|
| A. 평소 + tag + 로컬 먼저 (권고) | 평소 push 에서도 pubspec ↔ CHANGELOG 를 견주고, tag push 에서는 셋이 정확히 같은지 봄. tag 를 달기 전에 같은 검사를 로컬에서 먼저 | ✓ |
| B. tag + 로컬 먼저 | tag push 에서만 검사(요구사항 글자 그대로), tag 전에 로컬에서 먼저 돌림 | |
| C. tag push 만 | CI 의 tag 실행에서만. 실패해도 tag 는 이미 공개된 뒤 | |

**User's choice:** A

### tag 검사에서 CHANGELOG 제목의 날짜 자리도 볼까요?

| Option | Description | Selected |
|--------|-------------|----------|
| 날짜 꼴만 봄 (권고) | YYYY-MM-DD 꼴이 아니면(미출시 포함) 실패. tag 단 날과 같은지는 보지 않음 | ✓ |
| tag 날짜와도 견줌 | 날짜가 tag 를 단 날과 같아야 통과. 시간대 때문에 하루 어긋날 수 있음 | |
| 보지 않음 | 버전 숫자만 견줌. 미출시인 채로 tag 를 달 수 있음 | |

**User's choice:** 날짜 꼴만 봄

### '일부러 어긋난 입력에서 실패' 를 어떻게 보일까요?

| Option | Description | Selected |
|--------|-------------|----------|
| 로컬 복제본 지워 보기 (권고) | 어긋난 입력 다섯 가지를 복제본에서 만들어 실패를 M-번호로 기록. CI 연결은 진짜 v2.0.0 실행 로그로 | ✓ |
| 원격 시험 tag | 시험용 tag 를 올려 CI 실패를 직접 보고 지움. '올린 tag 는 지우지 않는다' 와 충돌 | |
| 둘 다 | 로컬 지워 보기 + 원격 시험 tag | |

**User's choice:** 로컬 복제본 지워 보기
**Notes:** 근거 — firehose 는 PR 마다 changelog = pubspec, tag push 때 tag 꼴을 본다. pub.dev 자동 게시도 tag 와 pubspec version 의 일치를 요구한다. 묻지 않고 잡은 셋(`[3/10]` 안의 확인으로 — 새 단계를 더하면 `example/README.md` 의 단계 표기 약 410곳이 바뀜, `v` + 버전 꼴이 아닌 tag 는 실패, README `ref:` 는 (g) 가 이미 견줌)에 반대 없음.

---

## smoke test 의 모양

### tag 를 달기 전에 커밋 번호로 먼저 받아 볼까요 (예행)?

| Option | Description | Selected |
|--------|-------------|----------|
| 한다 (권고) | 릴리스 커밋을 ref: <커밋 번호> 로 받아 같은 판정 → 통과하면 그 커밋에 tag → ref: v2.0.0 으로 한 번 더 | ✓ |
| tag 뒤에 한 번만 | 요구사항 글자 그대로. 실패하면 v2.0.1 로만 고침 | |

**User's choice:** 한다

### 어느 주소로 받아 볼까요?

| Option | Description | Selected |
|--------|-------------|----------|
| 둘 다 (권고) | recommended.yaml (새 프로젝트 안내) 과 옛 이름 analysis_options.yaml (사용 프로젝트 5개가 쓰는 이름). 옵션 파일만 바꿔 두 번 분석 | ✓ |
| recommended.yaml 만 | README 가 안내하는 정식 이름 하나 | |
| 다섯 주소 모두 | base 만 · base+riverpod 등 조합까지. 015 가 로컬 git 으로 잰 것을 다시 | |

**User's choice:** 둘 다

### 무엇을 통과로 볼까요?

| Option | Description | Selected |
|--------|-------------|----------|
| README 따라 하기 + 위반 두 줄 (권고) | flutter create 프로젝트에 README 그대로, 일부러 넣은 위반(기본 규칙 하나 · riverpod_lint 하나)이 둘 다 보고 + lock 의 resolved-ref 가 tag 의 커밋 | ✓ |
| 정답지 93줄 대조 | example/ 을 통째로 받는 쪽으로 복사해 git 의존성으로만 바꾸고 줄 단위 비교 (015 방식). README 따라 하기는 아님 | |
| 둘 다 | README 따라 하기 판정 + 정답지 93줄 대조 | |

**User's choice:** README 따라 하기 + 위반 두 줄

### smoke test 를 어떤 형태로 남길까요?

| Option | Description | Selected |
|--------|-------------|----------|
| 스크립트로 커밋 (권고) | tool/ 아래 스크립트 하나, ref 를 받아 임시 폴더에서 판정. 이번 예행 때 README 따라 하기는 한 번 손으로 | ✓ |
| 손으로 돌리고 기록 | 명령 · 출력 원문을 SUMMARY 에, 절차 문서에 명령 목록. 코드 없음 | |
| CI tag job 추가 | tag push 때 runner 에서 자동. 예행은 따로 손으로, tag 공개 뒤의 경보 | |

**User's choice:** 스크립트로 커밋
**Notes:** 근거 — `ref:` 는 커밋 번호 · 브랜치 · tag 를 모두 받고, annotated tag 도 lock 에는 가리키는 커밋의 번호가 적힌다 (spike 015 pub-7, pub 변경 #4707). 아직 재지 않은 것은 실제 GitHub 주소로 받는 길 · lock 없이 처음 받기 · 나눈 구조를 실제 주소에서 받은 프로젝트다. 019 의 git 실행은 평소 pub cache 를 써 받아 왔는지 기록이 없다. 정답지 93줄에는 `pubspec.yaml` · `lib/main.dart` 줄이 있어 `flutter create` 프로젝트에서 그대로 나오지 않는다. 스크립트의 대가(새 코드라 리뷰 대상 증가, README 가 바뀌어도 스스로 알아채지 못함)를 표로 보였다. 묻지 않고 잡은 넷(새 pub cache · 새 analyzer 상태 폴더, README 의 https 주소 · 인증 없음, 저장소 밖 임시 폴더 · `dart analyze`, 예행에서 막히면 README 를 고친 커밋으로 다시)에 반대 없음.

---

## 릴리스 절차 문서 · 미룬 손질

### 릴리스 절차를 어디에 적을까요?

| Option | Description | Selected |
|--------|-------------|----------|
| VERSIONING.md 에 절 (권고) | 기존 버전 등급 · CHANGELOG 형식 뒤에 「릴리스 절차」 절. README 안내 줄에 '릴리스 절차' 를 덧붙임 | ✓ |
| 새 RELEASING.md | 저장소 루트에 절차 전용 문서 | |
| README 의 고치는 사람 절 | 「이 저장소를 고치는 사람에게」 에 단계 목록 | |

**User's choice:** VERSIONING.md 에 절

### 절차에 무엇까지 담을까요?

| Option | Description | Selected |
|--------|-------------|----------|
| 단계 + lock + plugin 대응 (권고) | 이번에 밟는 단계 전부, lock 은 pub get 으로만 다시 받기, 'plugin 새 버전에 정답지가 깨졌을 때' 한 단락. pub upgrade 는 넣지 않음 | ✓ |
| 위 + 릴리스마다 pub upgrade | 릴리스마다 example · 연습용 프로젝트를 최신 의존성으로 올려 정답지 재확인 | |
| 단계 + lock 만 | plugin 정답지 대응은 다시 미룸 | |

**User's choice:** 단계 + lock + plugin 대응

### IN-14 (드문 YAML 입력에서 종료 코드 255) 를 어떻게 고칠까요?

| Option | Description | Selected |
|--------|-------------|----------|
| 주석 · 문장만 (권고) | 종료 코드 목록에 255 를 적고 example/README.md 의 문장을 실제 범위로 좁힘. 코드는 그대로 (Phase 5 의 같은 길) | ✓ |
| catch 를 더함 | 그 오류도 (h) 실패 블록으로. avoid_catching_errors 의 취지와 어긋남 | |

**User's choice:** 주석 · 문장만

### 05-UAT 1번 (README 설치 안내와 flutter create 템플릿의 기존 키) 을 어떻게 손질할까요?

| Option | Description | Selected |
|--------|-------------|----------|
| 문장 + 한 번 재기 (권고) | 세 절에 '기존 include 는 바꾸고 같은 키는 합친다' + base.yaml 만인 프로젝트의 plugins: 블록을 예행 때 재서 한 문장 | ✓ |
| 문장만 | 세 절의 문장만. plugins: 블록 쪽은 재지도 적지도 않음 | |
| 예행 결과만 | 미리 넣지 않고 예행에서 막힌 자리만 고침 | |

**User's choice:** 문장 + 한 번 재기

### 네 항목을 모두 이야기했습니다. 더 정할 것이 남았나요?

| Option | Description | Selected |
|--------|-------------|----------|
| CONTEXT 를 써 주세요 | '계획이 정하게 둘 것' 과 항목 4 의 '묻지 않고 잡을 것' 도 그대로 두고 06-CONTEXT.md 를 씀 | ✓ |
| 더 정할 것 있음 | 다른 회색 지대를 더 이야기함 | |

**User's choice:** CONTEXT 를 써 주세요
**Notes:** 근거 — 공개된 릴리스 절차 예시는 번호 붙은 단계(등급 → 버전 · changelog → 로컬 검증 → PR · CI → annotated tag → push)로 적는다. `pub get` 은 lock 의 버전을 가능한 한 쓴다. Flutter 3.47.5 앱 템플릿의 옵션 파일에 `include:` · `analyzer: exclude:` · `linter: rules:` 가 이미 있다 (템플릿 파일을 읽음). IN-14 는 이미 막는 쪽이고, PROJECT.md 의 "검사를 넓히지 않고 문장을 좁힌다" Key Decision 과 같은 길이다. 묻지 않고 잡은 것(결정이 끝난 손질 다섯은 정한 대로, CLAUDE.md 의 낡은 줄은 D-09 로 계속 미룸, Backlog 999.1 은 backlog 에 — 끼우고 싶으면 말하라고 알림)에 반대 없음.

---

## Claude's Discretion

- smoke 스크립트의 이름 · 인자 · 출력, 위반 두 줄을 옮길 샘플
- `tool/verify.dart` 가 tag 이름을 받는 방식(명령 인자 / GitHub 환경 변수)과 workflow 를 고칠지 — `push:` 의 필터 없음은 유지
- 커밋 나누기 (tag 를 달 커밋은 예행이 통과한 커밋)
- smoke · tag push · ls-remote 증거의 기록 형식 (Phase 1 의 형식 재사용 가능)
- 「릴리스 절차」 절의 문장과 plugin 정답지 대응 단락의 내용
- CHANGELOG 2.0.0 의 날짜를 예행 뒤 바꿀지

## Deferred Ideas

- Backlog 999.1 (`VERSIONING.md` 30행의 전제 한 문장) — backlog 그대로
- `.claude/CLAUDE.md` 의 낡은 줄 — 마일스톤 끝 `/gsd-map-codebase` (D-09)
- GitHub tag ruleset — 조사 중에 본 것, 논의하지 않음 (Free 플랜의 공개 저장소에서 되는지 확인하지 않음)
- CI 의 tag push 때 도는 smoke job — 고르지 않음
- 측정 도구의 재측정 전 수정 (RULES-13) — v2
- 고정 SDK 를 Dart 3.14 계열로 올리기 — Phase 6 이후 (spike 016)
