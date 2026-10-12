# Phase 3: Preset Split - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-10-12
**Phase:** 3-Preset Split
**Areas discussed:** plugin 버전 묶기 (D6), annotation 경고 무시 (D7), 연습용 프로젝트 구성, 추가 조사와 올리기

---

## 논의할 항목 고르기

| Option | Description | Selected |
|--------|-------------|----------|
| plugin 버전 묶기 (D6) | `riverpod_lint` 를 "3.1.9 이상이면 최신" 으로 둘지 "정확히 3.1.9" 로 못박을지 | ✓ |
| annotation 경고 무시 (D7) | `invalid_annotation_target: ignore` 를 codegen 조각으로 옮길지 지울지 | ✓ |
| 연습용 프로젝트 구성 | 조각별로 "받으면 나온다 / 안 받으면 안 나온다" 를 증명할 프로젝트를 몇 개 둘지, 화면과 `--update` 가 여러 개를 어떻게 다룰지 | ✓ |
| 추가 조사와 올리기 | 로드맵이 남긴 조사 둘을 할지, GitHub 에 올릴 때 확인을 어떻게 받을지 | ✓ |

**User's choice:** 넷 모두 (권고: 넷 모두)
**Notes:** 고르기 전에 이미 정해져 그대로 따르는 것 8가지를 표로 보였다 (파일 이름과 별칭, 조각끼리 include 하지 않음, 커밋 분리, spike 선행, `--update` 경로 먼저 닫기, 옛 주소 fixture 유지, CHANGELOG 2.0.0 항목, `main` 불변).

---

## plugin 버전 묶기 (D6)

질문 전에 찾아본 것: 분석 서버는 plugin 을 `dart pub upgrade` 로 풀고 SDK 가 `analysis_server_plugin` 버전을 스스로 정한다 (공식 문서 `using_plugins.md`). `riverpod_lint` 3.x 는 최근 넉 달에 다섯 번 나왔고 최신은 3.1.9 다 (pub.dev API 조회, 2026-10-12).

| Option | Description | Selected |
|--------|-------------|----------|
| `^3.1.9` 범위 지정 (Recommended) | 3.1.9 이상 4.0 미만의 그때 최신을 받는다. 요구사항 문구 그대로다. plugin 새 버전 때문에 정답지가 깨질 수 있지만 점검 화면의 plugin 줄로 원인이 보인다 | ✓ |
| `3.1.9` 정확 고정 | 딱 3.1.9 만 받는다. 경고가 바뀌는 시점을 직접 정하지만 plugin 새 버전마다 다시 릴리스해야 하고 PRESET-05 등의 문구도 고쳐야 한다 | |

**User's choice:** `^3.1.9` 범위 지정
**Notes:** 비교표에서 "못박은 옛 버전이 새 SDK 와 안 맞으면 plugin 경고가 통째로 사라질 수 있다" 는 공식 문서 내용에서 나온 추정이고 실측이 아니라고 밝혔다. 이어서 "더 이야기 / 다음 항목" 을 물었고 소유자는 다음 항목을 골랐다.

---

## annotation 경고 무시 (D7)

질문 전에 찾아본 것: freezed 공식 문서는 지금도 json_serializable 과 함께 쓸 때 이 경고를 끄라고 안내한다. 조사 실측으로는 이 설정이 필요한 경우가 "factory 생성자에 붙인 `@JsonSerializable`" 하나였다. Phase 2 의 M3 는 이 줄을 지우면 정답지에 warning 한 줄이 생김을 보였다.

| Option | Description | Selected |
|--------|-------------|----------|
| `codegen.yaml` 로 옮긴다 (Recommended) | 정답지가 바뀌지 않고 옛 주소가 받는 구성도 그대로다. 코드 생성을 쓰는 프로젝트만 받는 조각에 들어가 freezed 공식 안내와 자리가 맞는다 | ✓ |
| 옮기고, 지울지는 Phase 4 에서 다시 본다 | 이번에는 옮겨서 정답지를 지킨다. Phase 4 가 "이 설정을 풀면 경고가 몇 건 나오나" 를 함께 재고 그때 정한다 | |
| 지금 지운다 | 잘못 붙인 꼬리표가 어디서나 보인다. 정답지에 warning 한 줄이 생기고 PRESET-04 와 완료 기준 문구를 고쳐야 한다 | |

**User's choice:** `codegen.yaml` 로 옮긴다
**Notes:** 이어서 "더 이야기 / 다음 항목" 을 물었고 소유자는 다음 항목을 골랐다.

---

## 연습용 프로젝트 구성

질문 전에 찾아본 것: plugin 은 workspace 의 루트나 workspace 밖 패키지의 루트 옵션 파일에서만 지정할 수 있다 (dart.dev). `include:` 는 목록을 받고 순서대로 합쳐지며 받는 쪽 파일이 이긴다. 규칙을 끄려면 맵 문법이어야 한다 (dart.dev). Phase 2 실측으로 GitHub runner 에서 plugin 을 쓰는 프로젝트 하나의 첫 분석이 약 44초였다.

### 조합 범위

| Option | Description | Selected |
|--------|-------------|----------|
| 여섯 모두 (Recommended) | 필수 넷 + "기본 + Riverpod" + "기본 + codegen". 조각을 따로 받는 네 경우를 전부 돌려 본다. 자동 점검 약 4분 15초(추정), 정답지 5개 | ✓ |
| 필수 넷만 | 옛 주소, 묶음, 기본만, 끄는 설정. 성공 기준은 모두 채운다. 자동 점검 약 3분 30초(추정), 정답지 3개 | |
| 필수 넷 + "기본 + Riverpod" | README 가 가장 먼저 안내할 조합 하나만 더한다. 정답지 4개 | |

**User's choice:** 여섯 모두
**Notes:** 권고의 근거로 "README 에 싣는 조합 = 실제로 돌려 보는 조합" 원칙을 댔다. 자동 점검 시간은 추정값이라고 적어 보였다.

### 끄는 방법의 확인 범위

| Option | Description | Selected |
|--------|-------------|----------|
| 주석으로 끄기까지 (Recommended) | 프로젝트 전체 + 파일 하나 + 한 줄. README 가 안내할 방법을 전부 돌려 본다. plugin 주석의 `riverpod_lint/` 접두사 같은 함정이 정답지에 고정된다 | ✓ |
| 프로젝트 전체 둘만 | 옵션 파일에서 규칙 하나, plugin 경고 하나를 끄는 것만 확인한다. 성공 기준 5 그대로다 | |

**User's choice:** 주석으로 끄기까지
**Notes:** 끄는 대상 규칙의 선택과 프로젝트를 하나로 둘지 둘로 나눌지는 계획 단계에 맡긴다고 밝혔다 (기본값 하나).

### 정답지가 여러 개일 때의 `--update`

| Option | Description | Selected |
|--------|-------------|----------|
| 전부 한 번에 (Recommended) | `--update` 한 번으로 모든 정답지를 새로 쓰고 바뀐 줄을 프로젝트별로 보여 준다 | ✓ |
| 이름을 줘서 하나씩 | `--update=이름` 으로 고른 프로젝트의 정답지만 새로 쓴다. 규칙 하나를 바꾸면 명령을 여러 번 쳐야 한다 | |

**User's choice:** 전부 한 번에 (화면 미리보기를 함께 골랐다 — 03-CONTEXT.md 의 `<specifics>`)
**Notes:** 어느 쪽이든 "하나라도 이상하면 어느 정답지도 쓰지 않는다" 는 안전장치를 따른다고 밝혔다. 이어서 "더 이야기 / 다음 항목" 을 물었고 소유자는 다음 항목을 골랐다.

---

## 추가 조사와 올리기

### 로드맵이 남긴 조사 둘

질문 전에 찾아본 것: 공식 문서가 workspace 에서의 plugin 지정 자리를 정해 두었다 (dart.dev, dart-lang/sdk#61481). 사용 프로젝트 5개를 읽기 전용으로 확인했다 — `flutter_starter_kit` 은 workspace 가 아니고 Riverpod 3.3.1, 학습용 4개는 workspace 가 아니고 Riverpod 과 코드 생성을 쓰지 않는다.

| Option | Description | Selected |
|--------|-------------|----------|
| 둘 다 하지 않는다 (Recommended) | 해당하는 사용 프로젝트가 없다. README 는 돌려 본 범위만 단정형으로 적고 workspace 는 공식 문서 문장을 출처와 함께 옮긴다 | ✓ |
| workspace 만 한다 | 사전 확인에 작은 workspace 하나를 더해 실제로 돌려 본다 | |
| 둘 다 한다 | workspace 와 Riverpod 2 프로젝트를 모두 만들어 돌려 본다 | |

**User's choice:** 둘 다 하지 않는다

### GitHub 에 올릴 때의 확인

| Option | Description | Selected |
|--------|-------------|----------|
| Phase 2 와 같게 (Recommended) | 이 phase 의 첫 올리기 때 한 번 확인받고, 그 뒤 같은 브랜치의 추가 커밋은 묻지 않고 올린 뒤 알린다. 덮어쓰는 push, `main`, tag, 다른 브랜치는 늘 확인받는다 | ✓ |
| 올릴 때마다 확인 | 매번 올릴 것의 목록과 명령을 보여 주고 확인받는다 | |
| 끝에 한 번만 | 중간에는 올리지 않고 마지막에 확인받아 한 번 올린다 | |

**User's choice:** Phase 2 와 같게

---

## 마무리

| Option | Description | Selected |
|--------|-------------|----------|
| CONTEXT 작성으로 (Recommended) | 정한 것의 표와 "묻지 않고 이렇게 잡은 것" 그대로 결정 문서를 쓴다 | ✓ |
| 다른 항목을 더 살펴본다 | 계획 단계에 맡긴 세부 중에서 직접 정하고 싶은 것을 더 고른다 | |
| 추가 조사와 올리기를 더 이야기 | 마지막 항목에 대해 더 묻거나 정한다 | |

**User's choice:** CONTEXT 작성으로
**Notes:** 이 질문 앞에 "묻지 않고 이렇게 잡은 것" 셋을 보였고 소유자는 고치지 않았다 — (1) spike 넷째 항목은 결과가 어느 쪽이든 기록하고 계속한다, (2) 계획 단계에 맡기는 세부의 목록, (3) `VERSIONING.md` 의 남은 어긋남(WR-03)은 이 phase 에서 다루지 않는다.

## Claude's Discretion

- spike 의 실행 형식과 기록 자리
- fixture 의 폴더 자리와 이름, 샘플 소스를 나눠 쓰는 방법, plugin 준비를 나눠 쓸 수 있는지, fixture 의 `pubspec.lock`
- 끄는 대상으로 고를 규칙과 plugin 진단, 4번 fixture 를 하나로 둘지 둘로 나눌지
- plugin 을 선언하지 않는 fixture 에서의 `plugin` 줄과 `--update` 머리 주석
- `[2/4]` 를 모든 규칙 파일로 넓히는 방법, 단계의 개수와 번호, "가장 먼저 할 일" 의 구현
- 루트 `analysis_options.yaml` 이 `base.yaml` 을 include 할지
- 옛 파일의 템플릿 주석과 주석 처리된 줄의 자리, 새 파일의 머리 주석
- `CHANGELOG.md` 2.0.0 항목의 문구, `example/README.md` 의 갱신 범위, 커밋 분할, CI 의 `timeout-minutes`

## Deferred Ideas

- `invalid_annotation_target: ignore` 를 지울지 (Phase 4 실측에 더할 수 있다)
- workspace 와 Riverpod major 차이 조사 (그런 프로젝트가 생기면)
- README 의 호환 범위 문구, 학습용 프로젝트 4개가 "기본만" 후보라는 점, `flutter_starter_kit` 의 `dev_dependencies` 에 따로 적힌 `riverpod_lint` (Phase 5)
- plugin 새 버전으로 정답지가 저절로 깨졌을 때의 절차 문서
- `VERSIONING.md` 의 남은 어긋남 (Phase 1 리뷰 WR-03)
- `--update=이름` 으로 하나만 갱신하기
