# Phase 3: Preset Split - Research

**Researched:** 2026-10-12
**Domain:** `lib/analysis_options.yaml` 한 파일을 조각 셋(`base.yaml` / `riverpod.yaml` / `codegen.yaml`) + 묶음(`recommended.yaml`) + 옛 주소의 별칭으로 나누기, 연습용 프로젝트(fixture) 여섯과 정답지 다섯으로 검증 명령(`tool/verify.dart`) 넓히기, `--update` 가 망가진 결과를 정답지로 쓰는 경로 닫기, 루트 `analysis_options.yaml` 의 exclude 정리, GitHub Actions 시간
**Confidence:** HIGH — 로드맵의 "Spike first" 네 항목은 spike 009 ~ 012 가, 그 뒤의 맞물리는 자리는 013 ~ 019 가 이미 실행으로 확정했다 (멈춤 조건에 해당한 것 없음). 계획에 남아 있던 세부 — "가장 먼저 할 일" 의 세 입력이 오늘 코드에서 내는 정확한 종료 코드와 화면, 나눈 구조에서 연습용 프로젝트 여섯의 정답지 전문(끄는 설정용 포함), 조각 셋을 한 번에 돌리는 규칙 검사, 제외를 걷어낸 루트 분석, `.gitignore` 의 부정 패턴 — 는 이 세션에서 scratch 복사본으로 직접 재어 확인했다. 저장소 안의 파일은 이 문서 하나만 만들었다.

**근거 표기**

| 표기 | 뜻 |
|------|-----|
| `[VERIFIED: spike NNN]` | `.planning/spikes/NNN-…/` 의 실측 기록. 요약은 `.claude/skills/spike-findings-woody-lints/references/` 에 있다 |
| `[VERIFIED: scratch <무엇>]` | 2026-10-12 이 머신에서 scratch 복사본으로 직접 실행해 확인 (Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64). 출력은 본문에 그대로 붙였다 |
| `[VERIFIED: local <경로/명령>]` | 2026-10-12 저장소의 파일을 열거나 읽기 전용 명령을 돌려 확인 |
| `[CITED: 문서]` | 공식 문서 / 저장소 안의 결정 문서에서 읽음 |
| `[ASSUMED]` | 확인하지 않은 추정. "Assumptions Log" 에 모았다 |

이 세션의 실험은 모두 `mktemp -d` 로 만든 scratch 복사본(세션 scratchpad 아래 `p3-A6MZBw/`, `git archive HEAD` 로 만든 사본)에서 했다. 저장소의 `lib/`, `example/`, `tool/`, `.github/`, 루트 `analysis_options.yaml`, `pubspec.yaml`, `CHANGELOG.md`, `README.md` 는 건드리지 않았고 (`git status` 는 시작할 때의 세 항목 그대로), `main` · 원격 · tag 도 손대지 않았다. 측정 시각은 모두 2026-10-12 다.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### 이전에 확정되어 그대로 따르는 것

다시 논의하지 않았다. 출처는 ROADMAP.md / REQUIREMENTS.md / PROJECT.md / 01-CONTEXT.md / 02-CONTEXT.md 다.

- 파일 이름은 `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml` 이다. `lib/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 한 줄짜리 별칭으로 남는다 (PROJECT.md Key Decisions, PRESET-04 · 08)
- 조각은 서로를 include 하지 않는다. `base.yaml` 만 `flutter_lints` 를 include 하고, 조합은 include 하는 쪽이 한다 (ROADMAP Notes)
- 구조 변경과 내용 변경을 섞지 않는다. 규칙 목록, 주석 처리된 줄, 사유 주석은 옮기기만 하고 고치거나 지우지 않는다 (ROADMAP 의 모든 phase 에 걸친 제약)
- 파일 분리와 `riverpod_lint` 하한 상향(PRESET-05)은 서로 다른 커밋이다. 정답지가 바뀐다면 하한 상향 커밋에서만 바뀌어야 한다 (ROADMAP Notes)
- ROADMAP 의 "Spike first" 는 이 phase 의 나머지를 계획하기 전에 실행으로 확인한다. plugin 로드에 관한 세 가지(다른 이름 파일의 `plugins:` 가 include 경유로 로드된다 / 그 구조에서 루트 분석의 `plugins_in_inner_options` 가 사라진다 / 3단 include 에서도 로드된다) 중 하나라도 통과하지 못하면 phase 를 멈추고 소유자에게 돌아간다
- **가장 먼저 할 일:** 정답지를 새로 쓰거나 fixture 를 더하기 전에, `tool/verify.dart` 의 `--update` 가 망가진 결과를 정답지로 쓰는 경로를 닫는다. `[2/4]` 가 통과로 잘못 찍히는 세 입력(닫지 않은 따옴표로 깨진 YAML, `rules:` 키의 오타, 겹친 규칙 + 없는 진단 코드)이 대상이고, 세 코드 밖의 진단도 `[2/4]` 의 실패로 친다. `example/README.md` 의 단계 설명 문단과 `--update` 안전장치 문단, `[2/4]` 의 실패 문구도 코드가 실제로 보는 것에 맞춘다 (소유자 결정 2026-10-12, ROADMAP Notes, `02-VERIFICATION.md` 의 "다음 phase 가 알아야 할 것" 1 ~ 5). ROADMAP 은 두 문단을 "80행 · 30행" 으로 적었는데, 2026-10-12 에 확인한 자리는 81행(`단계는 네 개다:` 로 시작)과 30행이다
- 옛 URI 를 쓰는 fixture 를 남긴다. 지금의 `example/` 이 그 역할이다 (ROADMAP Notes)
- 규칙이 `base.yaml` 로 옮겨 가므로 deprecated / removed 검사(`[2/4]`)가 새 위치를 대상으로 계속 실패를 잡아야 한다. 규칙이 적힌 **모든** 파일이 대상이다 (ROADMAP Notes, `02-VERIFICATION.md` 3번 · 4번)
- 판정은 정답지 비교가 주 수단이고 정답지 한 줄은 `상대경로:줄  강도  규칙이름`, 맨 위에 `exit N` 이다 (02-CONTEXT.md D-04). `dart analyze` 의 실행 형태, 전용 상태 폴더, plugin 준비 실패 판정은 `spike-findings-woody-lints` skill 을 따른다
- fixture 는 pub workspace 멤버로 만들지 않는다 (02-CONTEXT.md, `research/ARCHITECTURE.md` Anti-Pattern 3). 새로 만드는 fixture 에도 같이 적용한다
- 이 phase 의 변경은 `CHANGELOG.md` 의 `## 2.0.0 - 미출시` 항목에 적는다 (01-CONTEXT.md D-15). 등급은 `VERSIONING.md` 기준표대로다 — 새 프리셋 파일 추가, 같은 major 안의 plugin 하한 상향, `analyzer.exclude` / `analyzer.errors` 변경이 모두 minor 다
- 검증과 실측은 저장소 고정 SDK(Flutter 3.47.5 / Dart 3.13.4)에서 `fvm dart …` 로 한다. 문서와 주석은 한국어로 쓰고 규칙명 · 키 · 명령은 영어 원문을 쓴다

#### plugin 버전 (ROADMAP 의 D6 확정)

- **D-01:** `lib/riverpod.yaml` 의 선언은 **`riverpod_lint: ^3.1.9`** (범위 지정)이다. 정확한 버전으로 고정하지 않는다. PRESET-05 와 성공 기준 3 의 문구는 그대로다.
  - 이유: 정확 고정은 `riverpod_lint` 가 나올 때마다 이 패키지를 다시 릴리스해야 받게 만들고(최근 넉 달에 다섯 번 — 3.1.4 6월 10일, 3.1.6 ~ 3.1.8 7월 26 ~ 28일, 3.1.9 9월 3일), 그래도 plugin 의 전이 의존성은 떠다닌다. 몇 달씩 손대지 않는 저장소에서는 못박은 버전이 낡아 plugin 이 빠지는 쪽이 더 위험하다고 보았다
  - 소유자에게 밝힌 대가: 사용 프로젝트가 tag 로 이 패키지를 고정해도 plugin 새 버전이 나온 날부터 경고가 달라질 수 있고, 저장소 변경 없이 정답지가 깨질 수 있다. 점검 화면의 `plugin` 줄이 원인을 보여 준다 (02-CONTEXT.md D-07)
  - "못박은 옛 버전이 새 SDK 와 맞지 않으면 plugin 진단이 통째로 사라질 수 있다" 는 공식 문서(SDK 가 `analysis_server_plugin` 버전을 스스로 정하고 릴리스마다 바뀔 수 있다)에서 나온 **추정**이고 실측이 아니다. 소유자에게 그렇게 밝혔다
  - 따라 나오는 사실: 지금 선언 `^3.1.3` 도 3.1.9 로 풀리고 있다 (pub.dev 최신이 3.1.9, 2026-10-12 조회). 하한 상향 커밋에서 정답지는 바뀌지 않을 것으로 예상한다. 3.1.9 는 Dart 3.13.0 이상을 요구하고 `pubspec.yaml` 의 `sdk: ^3.13.0` 과 맞는다
  - 고르지 않은 안: 정확 고정 `3.1.9`

#### annotation 경고 무시 설정 (ROADMAP 의 D7 확정)

- **D-02:** `invalid_annotation_target: ignore` 는 **`lib/codegen.yaml` 로 옮긴다.** 지우지 않는다. `codegen.yaml` 은 이 `analyzer.errors` 한 줄과 `analyzer.exclude` 의 두 패턴(`**/*.freezed.dart`, `**/*.g.dart`)을 담는다.
  - 이유: 옛 URI 와 묶음이 받는 구성이 그대로이고(PRESET-04) 정답지가 바뀌지 않는다. 나눈 뒤에는 이 설정이 코드 생성을 쓰는 프로젝트만 받는 조각에 들어가므로, freezed 공식 문서가 json_serializable 과 함께 쓸 때 권하는 경우와 자리가 맞는다
  - 따라 나오는 사실: `codegen.yaml` 을 받지 않는 구성(기본만, 기본 + Riverpod)에서는 `lib/should_not_appear.dart:5  warning  invalid_annotation_target` 이 나와야 한다 (Phase 2 의 지워 보기 M3 실측)
  - 지우는 것은 내용 변경이라 이 phase 에서 하지 않는다. 옮긴 뒤에도 나중에 지울 수 있고 그때의 등급은 minor 다
  - 고르지 않은 안: 지금 지우기 (정답지에 warning 한 줄이 생기고 PRESET-04 문구를 고쳐야 한다) / 옮기되 지울지를 Phase 4 실측에서 다시 보기

#### 연습용 프로젝트(fixture) 구성

- **D-03:** fixture 는 **여섯 조합**이다.

  | # | include 하는 것 | 증명하는 것 | plugin |
  |---|---|---|---|
  | 1 | 옛 URI 한 줄 (지금의 `example/`) | 분리 전후로 정답지가 같다. 별칭이 plugin 을 잃지 않는다 | 씀 |
  | 2 | `recommended.yaml` | 옛 URI 와 같은 진단이 나온다 | 씀 |
  | 3 | `base.yaml` 만 | 기본 규칙 진단은 나오고 `riverpod_lint` 진단은 나오지 않는다. 생성 파일의 진단과 `invalid_annotation_target` 은 나온다 | 안 씀 |
  | 4 | 묶음 + 끄는 설정 | 끈 진단만 사라진다 (D-04) | 씀 |
  | 5 | `base.yaml` + `riverpod.yaml` | Riverpod 조각만 따로 받아도 plugin 이 돈다. codegen 설정은 딸려 오지 않는다 | 씀 |
  | 6 | `base.yaml` + `codegen.yaml` | codegen 조각만 따로 받아도 생성 파일이 빠진다. plugin 은 딸려 오지 않는다 | 안 씀 |

  - 3 · 5 · 6 과 1 · 2 를 합치면 "Riverpod 을 받나 / codegen 을 받나" 의 네 경우가 모두 채워진다
  - 원칙: **README 에 싣는 조합은 실제로 돌려 본 조합이다.** Phase 5 의 DOCS-02(프로젝트 유형별 include 블록)가 이 여섯에서 나온다
  - 2번은 자기 정답지를 따로 두지 않고 1번(`example/`)의 정답지와 견준다 — 성공 기준 1 의 "같은 진단" 을 구조로 묶는다. 정답지는 다섯 개가 된다 (소유자가 본 표와 미리보기에 그렇게 적혀 있었다. 따로 고른 선택지는 아니다)
  - `example/` 의 샘플 소스와 정답지는 이 phase 에서 바꾸지 않는다 (성공 기준 1). 다른 fixture 에만 필요한 샘플은 그 fixture 의 파일에 둔다
  - 소유자에게 밝힌 대가: GitHub 자동 점검이 지금 약 2분에서 약 4분 15초로 늘 것으로 **추정**했다 (plugin 을 쓰는 fixture 하나에 최대 약 44초라는 Phase 2 실측에서 셈한 값. 둘째부터 더 빠른지는 재지 않았다). Phase 4 에서 규칙을 바꿀 때 살필 정답지가 다섯 개다
  - 고르지 않은 안: 필수 넷만 (1 ~ 4) / 필수 넷 + 5번
- **D-04:** 4번 fixture 는 끄는 방법을 **세 층 모두** 확인한다 — 프로젝트 전체, 파일 하나, 한 줄.

  | 층 | 규칙 | plugin 진단 |
  |---|---|---|
  | 프로젝트 전체 | 옵션 파일의 `linter: rules:` 에 `규칙이름: false` (맵 문법) | 옵션 파일의 `plugins:` 에 `version` 과 `diagnostics: {이름: false}` |
  | 파일 하나 | `// ignore_for_file: 이름` | 같은 주석 (plugin 이 따르는지는 spike 넷째 항목) |
  | 한 줄 | `// ignore: 이름` | `// ignore: riverpod_lint/이름` |

  - 원칙은 D-03 과 같다. Phase 5 의 DOCS-03 이 적을 방법을 전부 돌려 본다
  - 조사가 임시 프로젝트에서 잰 함정 둘을 이 저장소의 fixture 로 고정한다 — plugin 진단을 프로젝트 전체에서 끌 때 `version` 을 다시 적지 않으면 꺼지지 않는다 / 주석으로 끌 때 `riverpod_lint/` 접두사가 없으면 꺼지지 않는다 (`research/SUMMARY.md` § Gaps to Address)
  - "꺼졌다" 가 헛통과가 아니어야 한다. 끈 자리 옆에 끄지 않은 같은 위반을 두어 정답지에 남는 줄로 대조한다
  - spike 넷째 항목이 "plugin 이 `// ignore_for_file` 을 따르지 않는다" 로 나오면 fixture 는 그 동작을 있는 그대로 고정한다 (D-07)
  - 4번을 하나로 둘지 둘로 나눌지, 어느 규칙과 어느 plugin 진단을 끌지는 계획에 맡긴다. 기본값은 하나다
  - 고르지 않은 안: 프로젝트 전체 둘만 (성공 기준 5 의 최소)
- **D-05:** `--update` 는 **모든 정답지를 한 번에** 새로 쓴다. 바뀐 줄을 fixture 별로 보여 주고 끝에 쓴 정답지의 목록을 찍는다. 이름을 줘서 하나만 갱신하는 인자는 두지 않는다.
  - 안전장치: 같은 실행에서 하나라도 이상하면(plugin 준비 실패, 도구 사망, 다른 단계 실패, "가장 먼저 할 일" 이 닫는 세 입력) **어느 정답지도 쓰지 않는다.** Phase 2 의 안전장치(02-05)를 fixture 여럿으로 넓힌 것이다
  - CI 에서 `--update` 를 거부하는 것(종료 코드 64)은 그대로다
  - 고르지 않은 안: `--update=이름` 으로 하나씩
- **D-06:** 화면은 fixture 마다 한 줄이다 — 02-CONTEXT.md D-13 의 "검사 단계별 통과 · 실패" 를 그대로 늘린다. `<specifics>` 의 미리보기를 따른다 (소유자가 `--update` 를 고르며 본 화면이다).

#### 조사 범위와 spike 결과의 처리

- **D-07:** spike 넷째 항목(plugin 이 `analyzer.exclude` 와 `// ignore_for_file` 을 존중하는지)은 결과가 어느 쪽이든 **기록하고 계속 진행한다.** 02-CONTEXT.md D-15 의 기준(값이나 세부만 달라지는 결과는 기록하고 진행)을 그대로 쓴다. 앞의 세 가지는 ROADMAP 대로 하나라도 실패하면 멈춘다.
  - 논의 끝의 요약에서 Claude 가 이렇게 잡았다고 밝혔고 소유자가 반대하지 않았다. 명시적으로 고른 선택지는 아니다
- **D-08:** ROADMAP 이 "이 phase 에서 정한다" 고 남긴 조사 둘 — pub workspace 멤버 패키지에서의 plugin 로드, plugin 내부 `riverpod` 버전과 사용 프로젝트 `riverpod` major 가 다를 때의 동작 — 은 **하지 않는다.**
  - 이유: 해당하는 사용 프로젝트가 없다. 2026-10-12 에 읽기 전용으로 확인한 결과 `flutter_starter_kit` 은 workspace 가 아니고 `flutter_riverpod` 3.3.1 이며, 학습용 4개(`webtoon`, `toonflix`, `pomodoro`, `state`)는 workspace 가 아니고 Riverpod 과 코드 생성을 쓰지 않는다. `~/dv` 아래(깊이 4)에 workspace 프로젝트는 없었다
  - workspace 는 공식 문서에 답이 있다 — plugin 은 workspace 의 루트나 workspace 에 속하지 않은 패키지의 루트에서만 지정할 수 있다
  - 따라 나오는 점: Phase 5 의 README 는 돌려 본 범위(Riverpod 3.x, workspace 가 아닌 프로젝트)만 단정형으로 적는다. workspace 는 공식 문서 문장을 출처와 함께 옮기고 "이 패키지로는 돌려 보지 않았다" 고 적는다
  - 고르지 않은 안: workspace 만 spike 에 넣기 / 둘 다 넣기

#### GitHub 에 올리기

- **D-09:** push 확인은 Phase 2 와 같은 방식이다 — **이 phase 의 첫 번째만** 받는다. — **Reversibility:** one-way — 공개 저장소에 올린 내용은 브랜치를 지워도 복제본 · 캐시에 남을 수 있어 사실상 되돌릴 수 없다
  - 첫 확인 요청에는 올릴 것의 목록, 실행할 명령, 되돌릴 수 없다는 점을 쉬운 말로 적는다 (01-CONTEXT.md D-19, 02-CONTEXT.md D-09 와 같은 형식). `.planning/` 이 함께 올라간다는 점(02-CONTEXT.md D-08)도 다시 적는다
  - 그 뒤 **Phase 3 안에서, 같은 브랜치(`gsd/v2.0-package-rework`)에 커밋을 더 올리는 것**은 묻지 않고 실행한 뒤 결과를 보고한다
  - 포함하지 않는 것: 이미 올린 것을 덮어쓰는 push(`--force` 계열), `main`, tag, 다른 브랜치. 이들은 매번 확인받는다. Phase 4 부터는 다시 묻는다
  - push 는 브랜치 이름 하나만 지정한다. `--force`, `--tags`, `--all` 을 쓰지 않는다
  - phase 를 끝내기 전에 fixture 여섯으로 늘어난 검증이 GitHub runner 에서 통과하고 시간 제한 안에 끝나는 것을 본다
  - 고르지 않은 안: 올릴 때마다 확인 / phase 끝에 한 번만 올리기

### Claude's Discretion

소유자에게 묻지 않고 조사 · 계획 단계에 맡긴 것. 논의 끝의 요약에서 목록을 보였고 소유자가 그대로 진행을 골랐다.

- spike 의 실행 형식과 기록 자리. Phase 2 는 `/gsd-spike` 로 따로 돌리고 `--wrap-up` 으로 `spike-findings-woody-lints` skill 을 만들었다. 로드맵은 "나머지를 계획하기 전에" 를 요구한다
- fixture 의 폴더 자리와 이름. `example/` 의 경로는 그대로 둔다. `<specifics>` 미리보기의 이름(`recommended`, `base_only`, `base_riverpod`, `base_codegen`, `overrides`)은 예시다
- 샘플 소스를 여섯 fixture 가 나눠 쓰는 방법 (복사본을 커밋할지, 실행할 때 복사할지). 2번은 1번과 같은 상대경로의 진단을 내야 한다
- plugin 을 쓰는 fixture 넷이 plugin 준비(받기 · 컴파일)를 나눠 쓸 수 있는지. plugin 폴더는 패키지 루트 경로마다 따로 생긴다 (spike 008)
- fixture 의 `pubspec.lock` 처리. 기본값은 02-CONTEXT.md D-05 를 그대로 따르는 것이다 (커밋하고 `.gitignore` 에 예외를 더한다)
- plugin 을 선언하지 않는 fixture(3 · 6번)에서 화면의 `plugin` 줄과 `--update` 가 쓰는 머리 주석을 어떻게 찍을지 (`02-VERIFICATION.md` 5번)
- `[2/4]` 를 규칙이 적힌 모든 파일로 넓히는 방법, `stripPlugins` 와 `shippedOptionsPath` 의 수정, 단계의 개수와 번호
- "가장 먼저 할 일" 의 구현 방법. 깨진 YAML 은 종료 코드와 JSON 의 어긋남을 따로 봐야 한다 (`02-VERIFICATION.md` 사람 확인 9번)
- 루트 `analysis_options.yaml` 의 새 모양. `lib/analysis_options.yaml` exclude 를 걷어내는 것은 필수다 (PRESET-06). fixture 폴더의 exclude 는 남기거나 더한다. `base.yaml` 을 include 해 `tool/` 에 이 패키지의 규칙을 적용할지는 맡긴다
- 옛 파일의 템플릿 영어 주석과 주석 처리된 줄을 어느 조각으로 옮길지, 새 파일의 머리 주석. 지우는 결정은 Phase 4 · 5 의 일이다
- `CHANGELOG.md` 2.0.0 항목의 문구, `example/README.md` 의 갱신 범위 (단계 수, 새 fixture 가 헛통과가 아님을 보이는 지워 보기 기록)
- 커밋을 몇 개로 나눌지 (파일 분리와 하한 상향을 가르는 것만 필수다), CI 의 `timeout-minutes` 값 (지금 10)

### Deferred Ideas (OUT OF SCOPE)

논의 중에 나왔지만 이 phase 의 일이 아닌 것.

- **`invalid_annotation_target: ignore` 를 지울지** — 이번에는 `codegen.yaml` 로 옮긴다 (D-02). `flutter_starter_kit` 복사본에서 "이 설정을 풀면 경고가 몇 건 나오나" 를 재어 다시 정하는 안은 고르지 않았다. 다시 보고 싶으면 Phase 4 의 실측에 더할 수 있다
- **workspace 와 Riverpod major 차이 조사** — 하지 않기로 했다 (D-08). 그런 사용 프로젝트가 실제로 생기면 그때 잰다
- **README 의 호환 범위 문구** — 돌려 본 범위만 단정형으로 적고 workspace 는 공식 문서를 출처와 함께 옮긴다 (D-08). Phase 5 의 일이다
- **학습용 프로젝트 4개는 "기본만" 받으면 되는 프로젝트다** — Riverpod 과 코드 생성을 쓰지 않는데 지금은 묶음을 받는다 (2026-10-12 확인). 사용 프로젝트에 새 버전을 적용하는 일은 이번 작업의 범위 밖이다 (REQUIREMENTS.md Out of Scope). Phase 5 의 README 가 "어느 조합을 고를까" 를 설명할 때 예로 쓸 수 있다
- **`flutter_starter_kit` 의 `pubspec.yaml` 에 `riverpod_lint: ^3.1.3` 이 `dev_dependencies` 로 따로 적혀 있다** (2026-10-12 확인) — plugin 은 옵션 파일의 `plugins:` 로 로드되므로 이 줄이 필요한지, README 의 설치 안내가 이 줄을 어떻게 다룰지는 Phase 5 에서 본다
- **plugin 새 버전 때문에 정답지가 저절로 깨졌을 때의 절차** — D-01 로 생기는 일이다. 화면의 `plugin` 줄로 원인은 보이지만 "그때 무엇을 하나" 를 적어 둔 곳은 없다. `example/README.md` 나 Phase 6 의 릴리스 절차 문서에서 검토한다
- **`VERSIONING.md` 의 남은 어긋남 (Phase 1 리뷰 WR-03)** — "새 프리셋 파일 추가" 가 기준표에서는 minor 인데 판정 순서의 문장에는 드러나 있지 않다. 2.0.0 의 등급(major)에는 영향이 없어 이 phase 에서 다루지 않는다. D-05(01-CONTEXT.md)를 건드리는 소유자 결정이 필요하다
- **`--update=이름` 으로 하나만 갱신하기** — 두지 않기로 했다 (D-05). 정답지가 더 늘어 한 번에 보기 어려워지면 다시 검토한다
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PRESET-01 | 사용 프로젝트는 `package:woody_lints/base.yaml` 만 include 해서, Riverpod plugin 과 codegen 설정 없이 기본 규칙만 받을 수 있다 | § 권고 1 (`fixtures/base_only/`), § 권고 11 의 `base_only` 정답지 전문 (`exit 2` · 18줄 — plugin 0줄, 생성 파일 4줄 + `invalid_annotation_target` 1줄이 **나온다**) `[VERIFIED: spike 009, 017; scratch]` |
| PRESET-02 | 사용 프로젝트는 `package:woody_lints/riverpod.yaml` 을 include 해서 `riverpod_lint` plugin 을 받을 수 있다 | § 권고 1 (`fixtures/base_riverpod/`), § 권고 11 의 `base_riverpod` 정답지 (`exit 2` · 21줄, plugin 3줄, plugin 폴더 1) `[VERIFIED: spike 009, 015, 017; scratch]` |
| PRESET-03 | 사용 프로젝트는 `package:woody_lints/codegen.yaml` 을 include 해서 코드 생성 관련 설정(생성 파일 제외 등)을 받을 수 있다 | § 권고 1 (`fixtures/base_codegen/`), § 권고 11 의 `base_codegen` 정답지 (`exit 0` · 13줄). **성공 기준 3 의 범위 한정**은 § "spike 012 가 성공 기준 3 에 거는 조건" `[VERIFIED: spike 009, 012, 016; scratch]` |
| PRESET-04 | 기존 `package:woody_lints/analysis_options.yaml` 한 줄만 쓰는 프로젝트는 프리셋 분리 전과 같은 구성(기본 + Riverpod + codegen)을 받는다 | § 권고 8 (줄 범위 → 조각 대응표, 이어 붙여 원본과 견주기), § 권고 11 — 나눈 뒤 `example/` 의 결과가 커밋된 정답지(`19ae5ec`)와 한 줄도 다르지 않다 `[VERIFIED: spike 010, 015, 019; scratch]` |
| PRESET-05 | `riverpod_lint` plugin 의 버전 하한이 `^3.1.9` 다 | § 권고 9 의 커밋 C4 — `lib/riverpod.yaml` 과 `fixtures/overrides/analysis_options.yaml` 의 `version` 을 함께 올리고 정답지 다섯이 그대로임을 단언 `[VERIFIED: spike 010 — `^3.1.3` 과 `^3.1.9` 가 둘 다 3.1.9 로 풀려 16줄 같음]` |
| PRESET-06 | 저장소 루트 분석이 배포 파일을 분석 대상에서 제외하지 않고도 경고 없이 통과한다 | § 권고 7 — 제외를 걷어내고 `fixtures/**` 를 더한 루트 파일로 `dart analyze` → exit 0 · 0건 · plugin 준비 없음 `[VERIFIED: spike 011; scratch (tool/verify.dart 포함)]` |
| PRESET-07 | 사용 프로젝트에서 규칙 하나를 끄는 방법과 plugin 진단 하나를 끄는 방법이 README 에 적힌 대로 동작함이 fixture 로 확인되어 있다 | § 권고 1 · 11 의 `fixtures/overrides/` — 여섯 칸을 한 프로젝트에 담은 옵션 파일과 샘플, 그 정답지 전문 (`exit 2` · 18줄) `[VERIFIED: spike 012; scratch]` |
| PRESET-08 | 사용 프로젝트는 묶음의 정식 이름 `package:woody_lints/recommended.yaml` 한 줄로 기본 + Riverpod + codegen 구성을 받을 수 있고, 옛 URI 로 받는 구성과 같다 | § 권고 1 (`fixtures/recommended/` 는 자기 정답지 없이 `example/` 의 같은 실행 결과와 견준다), § 권고 11 — 두 결과가 줄 단위로 같음 `[VERIFIED: spike 010, 017; scratch]` |
| VERIFY-05 | `base.yaml` 만 include 한 대조군 fixture 에서 Riverpod / codegen 설정이 적용되지 않음을 확인한다 | PRESET-01 과 같은 fixture. "적용되지 않음" 은 정답지에 **남는 줄**(plugin 0줄, 생성 파일 4줄, `invalid_annotation_target`)로 증명된다 — 헛통과가 아니다 `[VERIFIED: scratch]` |
</phase_requirements>

## Summary

로드맵이 "계획 전에 확인하라" 고 한 네 항목은 spike 009 ~ 012 가 답했고, 그 뒤에 맞물리는 자리(규칙 검사, 여러 fixture 의 plugin 준비, git 의존성, 다음 SDK, runner 시간, 다음 runner 이미지, 실제 사용 프로젝트)는 013 ~ 019 가 쟀다. 열한 개 가운데 아홉이 VALIDATED, 둘(012, 016)이 PARTIAL 이고 **멈춤 조건에 해당한 것은 없다** `[VERIFIED: .planning/spikes/MANIFEST.md]`. 계획이 기대는 핵심 사실은 넷이다. (1) 이름이 `analysis_options.yaml` 이 아닌 조각(`riverpod.yaml`)의 최상위 `plugins:` 는 include 를 거쳐 로드되고, 옛 주소 → 묶음 → 조각의 3단에서도 `example/` 의 정답지가 한 줄도 달라지지 않는다 — `path:` 로도, git 의존성으로도, GitHub runner 에서도, 실제 사용 프로젝트에서도 같다. (2) 나눈 구조에서 루트의 `lib/analysis_options.yaml` 제외를 걷어내면 `plugins_in_inner_options` 없이 0건이다 (한 파일 구조에서 먼저 걷어내면 exit 2). (3) 끄는 방법 여섯 칸은 성립하지만, **묶음이 주는 생성 파일 제외는 plugin 진단에 통하지 않는다** (1.3.0 도 같다) — 성공 기준 3 은 "Dart 3.13.x 의 규칙 진단" 으로 범위를 적어 검증한다. (4) 연습용 프로젝트 여섯을 차례로 돌려도 runner 의 job 은 약 3분 20초 ~ 4분 20초로 `timeout-minutes: 10` 안에 든다.

이 세션은 그 위에서 계획이 정해야 할 세부를 scratch 복사본으로 재어 확정했다. "가장 먼저 할 일" 의 세 입력(닫지 않은 따옴표 / `rules:` 오타 / 겹친 규칙 + 없는 진단 코드)은 오늘의 `tool/verify.dart` 에서 **셋 다 `--update` 가 `[2/4] 통과` · `정답지를 썼다` · `점검 통과 (4개 중 4개)` · 종료 코드 0** 으로 끝나고 망가진 정답지를 쓴다 (보통 실행은 셋 다 `[4/4]` 에서만 실패, 종료 코드 1). 규칙 검사 복사본을 직접 돌리면 각각 `exit 3 · 진단 0건` / `unsupported_option` / `duplicate_rule` + `unrecognized_error_code` 가 나오므로, `[2/N]` 의 통과 조건을 "exit 0 이고 진단 0건" 으로 바꾸면 세 입력이 모두 `[2/N]` 에서 잡히고 D-05 의 안전장치가 `--update` 를 알아서 막는다. 나눈 구조에서 여섯 조합의 정답지는 예상대로였고(16 / 16 / 18 / 18 / 21 / 13줄), 끄는 설정용 프로젝트는 프로젝트 전체에서 끄는 것(`prefer_final_locals`, `missing_provider_scope`)과 주석으로 끄는 것(`prefer_single_quotes`, `provider_parameters`)을 **다른 것**으로 골라 한 프로젝트에 담을 수 있었다. 조각 셋을 하위 폴더에 두고 한 번에 돌린 규칙 검사(exit 0 · 0건 · plugin 준비 없음)와 `tool/verify.dart` 가 있는 루트의 분석(exit 0 · 0건 · plugin 준비 없음)도 처음으로 돌려 봤다.

**Primary recommendation:** 커밋 넷으로 간다 — C1 `--update` 경로 닫기(`[2/N]` 을 "exit 0 · 진단 0건" 으로, 깨진 YAML 은 exit 3 + 진단 0건으로 따로 알림, README 30행 · 81행) → C2 `lib/` 나누기(줄 범위 그대로 잘라 옮김) + 루트 `lib/analysis_options.yaml` 제외 삭제 + 규칙 검사 대상을 조각 셋으로 → C3 `fixtures/{recommended,base_only,overrides,base_riverpod,base_codegen}/` + `fixtures/**` 제외 + `.gitignore` + `tool/verify.dart` 의 단계 9개 · fixture 별 한 줄 · `--update` 일괄 쓰기 → C4 `riverpod_lint: ^3.1.9` (조각과 `overrides` 의 `version` 을 함께). C2 와 C4 에서 `example/expected_diagnostics.txt` 가 `19ae5ec` 그대로임을 단언하고, C3 뒤의 첫 push 에서 runner 시간을 본다.

## Spike first 네 항목 — 어느 spike 가 답했고 결과는 무엇인가

ROADMAP Phase 3 의 "Spike first" 순서대로다. D-07 의 분류는 "기록하고 계속" 과 "멈추고 돌아옴" 둘이다.

| # | 로드맵의 질문 | 답한 spike | 결과 | 분류 | 남은 것 |
|---|---|---|---|---|---|
| a | 이름이 `analysis_options.yaml` 이 아닌 파일(`riverpod.yaml`)의 `plugins:` 가 include 경유로 로드된다 | 009 (+015, 017, 019) | **로드된다.** 조각 조합 넷이 같은 내용을 한 파일에 둔 것과 진단 · 종료 코드가 같았다 (23건 모두 성립). include 순서를 뒤집어도, 목록 문법으로 적어도 같다. git 의존성(015) · runner(017) · 실제 사용 프로젝트(019)에서도 줄 단위로 같다 `[VERIFIED: spike 009, 015, 017, 019]` | 기록하고 계속 (VALIDATED) | 공식 문서가 직접 말한 문장은 없다 — 근거는 소스(`analysis_options_include_walker.dart`)와 실행이다 |
| b | 그 구조에서 루트 분석의 `plugins_in_inner_options` 가 사라진다 | 011 | **사라진다.** 나눈 구조 + 제외 없음 → exit 0 · 0건 · plugin 준비 없음 · 0.6초 (`tool/verify.dart` 가 있는 replica). 한 파일 구조에서 먼저 지우면 `lib/analysis_options.yaml:58  warning  plugins_in_inner_options` 로 exit 2 `[VERIFIED: spike 011]`. 이 세션의 scratch 에서도 exit 0 · 0건 · plugin 폴더 0 `[VERIFIED: scratch]` | 기록하고 계속 (VALIDATED) | 베타(016)에서는 이 경고 자체가 나오지 않고 대신 루트 분석이 plugin 을 준비한다 — 주석에 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다 |
| — | 3단 include(옛 주소 → 묶음 → 조각)에서 plugin 이 로드된다 | 010 (+015, 016) | **로드된다.** 옛 주소 · 묶음 주소 둘 다 지금 정답지(`exit 2` + 16줄)와 한 줄도 다르지 않다. 서버가 만든 가상 패키지의 `pubspec.yaml` 에 `riverpod.yaml` 의 선언이 세 단계를 거쳐 그대로 적혔다. 6단에서도 같다 (깊이 제한 없음) `[VERIFIED: spike 010]` | 기록하고 계속 (VALIDATED) | 주석을 단 묶음 · 별칭 파일로는 재지 않았다 → 이 세션이 주석을 단 채로 재어 같은 16줄 `[VERIFIED: scratch]` |
| — | plugin 이 `analyzer.exclude` 와 `// ignore_for_file` 을 존중하는지 | 012 (+015, 016, 019) | **반반 — PARTIAL.** 끄는 방법 여섯 칸은 전부 성립 (주석은 `riverpod_lint/` 접두사가 있어야, 옵션 파일은 `version` 이 있어야 꺼진다. `analyzer.errors` 로는 못 끈다). **묶음이 주는 생성 파일 제외(`codegen.yaml` 의 두 패턴)는 규칙 진단에만 통하고 plugin 진단에는 통하지 않는다** — plugin 쪽 `analyzer` 14.4.0+ 가 패턴을 "그 패턴을 적은 파일의 폴더" 기준으로 풀기 때문. 1.3.0 도 같다. 사용 프로젝트가 자기 옵션 파일에 직접 적은 제외는 둘 다 막는다 `[VERIFIED: spike 012]` | 기록하고 계속 (D-07) | 아래 "spike 012 가 성공 기준 3 에 거는 조건" |

멈춤 조건(a · b · 3단 중 하나라도 실패)은 발동하지 않았다. 그 뒤의 spike 가 더한 것:

| spike | 잰 것 | 계획이 가져갈 결과 | 판정 |
|---|---|---|---|
| 013 rule-check-after-split | 규칙이 `base.yaml` 로 간 뒤의 규칙 검사 | 조각 셋을 `build/woody_rule_check/<조각>/analysis_options.yaml` 로 복사해 한 번에 돌린다. 통과 조건은 "exit 0 이고 복사본의 진단 0건". "규칙 0개" 확인은 `base.yaml` 에만. 묶음 · 별칭은 넣지 않는다 (plugin 을 준비한다). 깨진 YAML 은 exit 3 + JSON 진단 0건 + stderr 비어 있음, `linter:` 오타는 아무 신호 없음 `[VERIFIED: spike 013]` | VALIDATED |
| 014 multi-fixture-plugin-cost | plugin 을 쓰는 넷의 준비 비용 | 상태 폴더는 프로젝트마다 따로 (합치면 plugin 폴더 넷 → 버전을 못 읽음). plugin 준비는 경로가 다르면 나눠 쓰지 못한다. 샘플은 복사본 커밋을 기본으로 `[VERIFIED: spike 014]` | VALIDATED |
| 015 git-dependency-preset-load | git 의존성으로 받아도 같은가 | 줄 단위로 같다. 받아 오는 길(실제 GitHub 주소 · tag)만 Phase 6 의 smoke test 가 본다. git 의존성용 fixture 는 두지 않는다 `[VERIFIED: spike 015]` | VALIDATED |
| 016 next-sdk-forward-compat | Flutter 베타 3.49.0-0.2.pre (Dart 3.14.0-211.1.beta) | plugin 로드와 규칙 12개는 그대로. **프리셋의 생성 파일 제외가 베타에서는 규칙 진단에도 통하지 않아** codegen 조각을 받는 정답지에 4줄이 생긴다 (상류 sdk#64549 가 되돌리는 중). 베타의 루트 분석은 plugin 을 준비한다. 이 phase 의 고정 SDK 범위 밖이지만 **주석 · 문서에 SDK 와 무관한 사실로 옮기지 않는다** `[VERIFIED: spike 016]` | PARTIAL |
| 017 runner-six-fixtures | runner 에서 여섯을 차례로 · 한꺼번에 | 차례로: 분석 146 ~ 191초, 재실행을 뺀 job 202 ~ 258초 (약 3분 20초 ~ 4분 20초). 한꺼번에: 69 ~ 95초. 열두 job 의 288건 모두 성립. `timeout-minutes: 10` 안 `[VERIFIED: spike 017]` | VALIDATED |
| 018 runner-next-image | `ubuntu-26.04` 이미지 | 지금의 검증과 여섯 프로젝트 점검이 24.04 와 같은 결과. `runs-on: ubuntu-latest` 그대로 `[VERIFIED: spike 018]` | VALIDATED |
| 019 real-consumer-split-invariance | `flutter_starter_kit` 복사본 (Dart 파일 468개) | 지금 받는 그대로 = 한 파일 = 나눈 구조(옛 주소) = 나눈 구조(묶음). 비공개 프로젝트라 건수와 규칙 이름만 기록 `[VERIFIED: spike 019]` | VALIDATED |

### spike 012 가 성공 기준 3 에 거는 조건 (D-07 — 기록하고 계속)

성공 기준 3 의 뒷부분 "`codegen.yaml` 을 include 한 구성에서 생성 파일(`*.g.dart`, `*.freezed.dart`)의 진단이 보고되지 않는다" 는 **Dart 3.13.x 의 규칙 진단에 대해서만 참**이다 `[VERIFIED: spike 012, 016]`.

- `example/` 의 생성 파일 샘플에는 규칙 위반(`avoid_print`, `prefer_single_quotes`)만 있다 `[VERIFIED: local example/lib/generated/*.dart]`. 그래서 고정 SDK 에서 fixture 1 · 2 · 6 의 정답지에는 생성 파일 줄이 없고 fixture 3 · 5 에는 4줄이 있다 — 이것이 "codegen 설정이 적용된다 / 되지 않는다" 의 대조다.
- fixture 1 · 2 · 6 이 단언할 수 있는 것: "생성 파일 샘플의 **규칙** 진단 4줄이 정답지에 없다". 단언할 수 없는 것: "생성 파일의 plugin 진단이 막힌다" — 샘플에 plugin 위반을 넣으면 `codegen.yaml` 을 받아도 그 줄이 나온다 (012 의 `lib/generated/riverpod_violation.g.dart:5  warning  provider_parameters`).
- **권고:** 생성 파일 샘플에 plugin 위반을 **넣지 않는다** (성공 기준 1 이 `example/` 샘플을 바꾸지 못하게 하고, 넣으면 그 줄이 SDK 가 아니라 pub.dev 의 `analyzer` 릴리스에 묶여 저장소 변경 없이 깨진다). 성공 기준 3 은 계획과 VERIFICATION 에 "Dart 3.13.4 에서 규칙 진단 기준" 이라고 범위를 적어 검증한다. README (Phase 5) 는 생성 파일 제외를 사용 프로젝트의 옵션 파일에 직접 적으라고 안내한다 (suppression-and-exclude.md 7번).
- `example/README.md` 의 파일 표(`lib/generated/…` 행 "배포 파일이 분석에서 빼므로 나오면 안 된다")는 그대로 맞다 — 규칙 위반만 담은 샘플에 대한 말이다. 새 fixture 의 설명을 적을 때 같은 범위를 쓴다.

## CONTEXT.md 의 추정 가운데 뒤의 spike 가 실측으로 바꾼 것

| 어디에 적힌 추정 | 적힌 값 | 실측 | 근거 | 낡은 문구가 남아 있는 곳 |
|---|---|---|---|---|
| 03-CONTEXT.md D-03 "소유자에게 밝힌 대가" | 자동 점검 약 2분 → **약 4분 15초 (추정)**. plugin fixture 하나 최대 약 44초에서 셈함. "둘째부터 더 빠른지는 재지 않았다" | 차례로 돌린 job (재실행을 뺀 셈) **202 ~ 258초 = 약 3분 20초 ~ 4분 20초**, 표본 여섯. plugin 을 쓰는 프로젝트 하나 30 ~ 45초이고 **둘째부터도 같다** (준비를 나눠 쓰지 못함). 쓰지 않는 둘은 6 ~ 8초 | `[VERIFIED: spike 017]` | 03-CONTEXT.md D-03 (추정 그대로). 추정은 잰 범위 안에 든다 — 소유자에게 "잰 값은 3분 20초 ~ 4분 20초" 로 다시 알린다 (CONTEXT `<specifics>` 의 약속) |
| spike 014 README · MANIFEST 의 014 줄 · skill 의 014 줄 | runner 여섯 "추정 약 4분 20 ~ 30초" | 위와 같음. 014 의 추정은 가장 느린 표본(258초)보다 조금 길었다 | `[VERIFIED: spike 017]` | MANIFEST.md 와 skill 요구 사항의 014 줄 (바로 아래 017 줄이 대신한다고 적혀 있다) |
| `.github/workflows/verify.yml` 26행 주석 | "정상 약 2분 (spike 006)" | 프로젝트 하나일 때의 값. 여섯이면 약 3분 20초 ~ 4분 20초 (spike 의 스크립트 기준. 실제 `tool/verify.dart` 는 아직 재지 않았다) | `[VERIFIED: local .github/workflows/verify.yml; spike 017]` | workflow 주석 — C3 이후 첫 CI 실행의 실제 시간을 보고 고친다 (§ 권고 10) |
| 03-CONTEXT.md D-01 "지금 선언 `^3.1.3` 도 3.1.9 로 풀리고 있다" | 2026-10-12 pub.dev 조회 | scratch 의 모든 plugin fixture 가 3.1.9 로 풀렸다 | `[VERIFIED: scratch]` | 낡지 않았다 |
| 03-CONTEXT.md code_context "`tool/verify.dart` 35행 `fixtures`, 38행 `shippedOptionsPath`, 595행 `stripPlugins`" | — | 35 · 38 · 595행 그대로 | `[VERIFIED: local grep tool/verify.dart]` | 낡지 않았다 |
| 03-CONTEXT.md "`example/README.md` 81행(`단계는 네 개다:`)과 30행" | ROADMAP 은 80행 | 81행 `단계는 네 개다: …`, 30행 `- 같은 실행에서 다른 단계(`[1/4]` ~ `[3/4]`)가 실패했으면 …` | `[VERIFIED: local sed -n '30p;81p' example/README.md]` | ROADMAP Notes 의 "80행" (CONTEXT 가 이미 바로잡았다) |

## 원격 상태 (D-09 의 전제)

```text
$ git log --oneline -1                      → 190c433 docs(spike-wrap-up): spike 017 ~ 019 의 실측 결과를 프로젝트 skill 에 반영
$ git ls-remote --heads origin              → 0d20c10  refs/heads/gsd/v2.0-package-rework
                                              90a2736  refs/heads/main
$ git log --oneline 0d20c10..HEAD | wc -l   → 7 (58782d4 … 190c433, 모두 .planning/ · skill · 임시 workflow 제거)
$ gh run list --limit 3                     → 38216842742 spike-017-018-runner success 5m12s / 38216842619 verify success 1m31s (둘 다 0d20c10 의 push, 2026-10-12T07:16Z)
```
`[VERIFIED: local git ls-remote / gh run list, 2026-10-12]`

- 원격의 작업 브랜치는 `0d20c10` 이고 로컬이 7커밋 앞선다. **03-CONTEXT.md code_context 의 "origin 은 `ead9573`, 로컬이 4커밋 앞" 은 논의 뒤 spike 017 · 018 의 push 로 낡았다.** `main` 은 `90a2736`, tag 는 `v1.3.0` 하나, PR 0건 그대로다.
- 원격의 `tool/verify.dart` 는 `40776b5` 의 것이고 run 38216842619 의 `verify` 가 그 스크립트로 `점검 통과 (4개 중 4개)` 였다 (`02-VERIFICATION.md` 6번 "02-05 의 스크립트는 runner 에서 돈 적이 없다" 는 이 실행으로 닫혔다).
- 이 phase 의 첫 push 는 D-09 대로 소유자 확인을 받는다. 올라가는 것에는 위의 7커밋과 이 문서, 계획 문서가 포함된다.

## 계획이 고정할 기준 커밋 (`git diff --quiet <커밋> -- <경로>` 의 `<커밋>`)

HEAD `190c433` 에서 `git log --oneline -1 -- <경로>` 로 읽은 "그 경로를 마지막으로 바꾼 커밋" 이다 `[VERIFIED: local git log, 2026-10-12]`. 더 오래된 커밋을 기준으로 삼으면 단언이 헛실패한다.

| 경로 | 마지막으로 바꾼 커밋 | 이 phase 에서 |
|---|---|---|
| `lib/` (= `lib/analysis_options.yaml` 하나) | `90a2736` | C2 에서 바뀐다. C1 의 단언: `git diff --quiet 90a2736 -- lib`. `git show 90a2736:lib/analysis_options.yaml` 이 "나누기 전의 원본" 이다 (지금 디스크와 동일 `[VERIFIED: local diff]`) |
| `pubspec.yaml` | `968a5bb` | 바꾸지 않는다 (`version: 2.0.0-dev`, `sdk: ^3.13.0`, `flutter_lints: ^6.0.0`). 모든 커밋에서 `git diff --quiet 968a5bb -- pubspec.yaml` |
| `example/expected_diagnostics.txt` | `19ae5ec` | **바꾸지 않는다.** C1 ~ C4 모두에서 `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt` (지금 디스크와 동일 `[VERIFIED: local diff]`) |
| `example/lib/` (샘플 7파일) | `74fafb2` | 바꾸지 않는다 |
| `example/analysis_options.yaml`, `example/pubspec.yaml`, `example/pubspec.lock` | `ac5cced` | 바꾸지 않는다 |
| `tool/verify.dart` | `40776b5` | C1 · C2 · C3 에서 바뀐다 |
| 루트 `analysis_options.yaml` | `ac5cced` | C2 (제외 삭제), C3 (`fixtures/**`) |
| `.github/workflows/verify.yml` | `008ea3f` | 바꾸지 않는 것을 권고 (§ 권고 10). 주석 한 줄만 CI 실측 뒤에 |
| `example/README.md` | `008ea3f` | C1 (30행 · 81행 · 기록 M15 ~ M17), C3 (fixture 표 · 기록) |
| `.gitignore` | `ac5cced` | C3 (`!fixtures/*/pubspec.lock`) |
| `CHANGELOG.md` | `2a9725e` | C2 · C4 (2.0.0 항목) |
| `README.md` | `90a2736` | 바꾸지 않는다 (Phase 5) |
| `VERSIONING.md` | `6b9eec8` | 바꾸지 않는다 |
| `.fvmrc` | `3a15da8` | 바꾸지 않는다 |

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 조각 · 묶음 · 별칭의 include 해석과 병합 | Dart Analysis Server (`analysis_options_include_walker`) | pub 의존성 그래프 (`package:woody_lints/…` URI 해석) | 패키지가 할 수 있는 것은 파일 다섯의 내용뿐. 로드 여부는 서버가 정한다 (spike 009 ~ 011 이 그 동작을 확정) |
| `riverpod_lint` plugin 준비 · 실행 | Analysis Server 의 plugin manager (전용 상태 폴더) | pub.dev (매 실행 `dart pub upgrade`) | `riverpod.yaml` 의 선언이 3단을 거쳐 가상 패키지의 `pubspec.yaml` 에 적힌다. 네트워크 필요 |
| 정답지 비교 · 단계 판정 · `--update` | `tool/verify.dart` (Dart VM, `dart:io` / `dart:convert`) | analyzer 의 `--format=json` | 판정 주체는 스크립트. fixture 여섯을 차례로, 상태 폴더는 fixture 마다 |
| 규칙 이름 유효성 (deprecated / removed / undefined / 옵션 파일 경고) | analyzer 의 옵션 파일 검사 — `analysis_options.yaml` 이름으로 **직접** 분석될 때만 온전 | 스크립트의 복사 · 정리 단계 (`build/woody_rule_check/<조각>/`) | include 경유로는 `undefined_lint` 만 보고되므로 조각 셋을 모두 복사한다 |
| 끄는 설정의 동작 (PRESET-07) | Analysis Server (옵션 병합) + plugin 쪽 `analyzer` (주석 판정 `IgnoredDiagnosticName`) | `fixtures/overrides/` 의 샘플과 정답지 | 규칙 쪽과 plugin 쪽이 서로 다른 `analyzer` 를 쓴다 (14.1.0-dev vs 14.5.0) — 생성 파일 제외가 갈리는 원인 |
| 저장소 루트의 자체 분석 (PRESET-06, 커밋 전 린터) | 루트 `analysis_options.yaml` + Analysis Server 의 context root 결정 | 루트 `pub get` | 하위 폴더가 자기 `package_config.json` 을 가지면 별도 root 가 되므로 `example/**` · `fixtures/**` 를 제외한다 |
| CI 실행 | GitHub Actions `ubuntu-latest` | — | 로컬과 같은 명령 한 줄. 판정 로직은 넣지 않는다 |

## Project Constraints (from CLAUDE.md)

`.claude/CLAUDE.md` 의 "Technology Stack / Conventions / Architecture" 절은 commit `90a2736` 시점의 코드베이스 맵에서 생성되어 **낡았다** (`.fvmrc` 3.41.2, `sdk: ^3.10.4`, `version: 1.3.0`, `example/` · `tool/` · `.github/` 없음으로 적혀 있다). 디스크의 현재 값이 우선한다: `.fvmrc` = `3.47.5`, `pubspec.yaml` = `version: 2.0.0-dev` / `sdk: ^3.13.0`, `example/` · `tool/verify.dart` · `.github/workflows/verify.yml` 존재 `[VERIFIED: local]`. CLAUDE.md 의 "루트 `analysis_options.yaml` 의 `lib/analysis_options.yaml` exclude 는 유지" 는 Phase 2 까지의 규칙이고 **PRESET-06 이 이 phase 에서 뒤집는다** (CONTEXT 의 잠긴 결정이 CLAUDE.md 의 낡은 절보다 우선한다).

| 지시 | 출처 | 이 phase 에서의 적용 |
|---|---|---|
| `package:woody_lints/analysis_options.yaml` URI 는 공개 API, 뜻(기본 + Riverpod + codegen) 유지. 새 문서는 `recommended.yaml` 안내 | Constraints | 별칭은 `include: package:woody_lints/recommended.yaml` 한 줄 (+ 머리 주석). `example/` 은 옛 URI 그대로 |
| 릴리스 전까지 `main` 의 `lib/` 와 `pubspec.yaml` 은 1.3.0 유지 | Constraints, Release channel | 모든 변경은 `gsd/v2.0-package-rework` 에만. `main` · tag 를 건드리지 않는다 |
| Git 의존성 + tag 로만 배포 | Distribution | fixture 는 `path: ../..` 로 받는다 (git 의존성과 같은 결과 — spike 015) |
| 실측은 `flutter_starter_kit` 복사본에서, 원본 수정 금지 | Safety | 이 phase 는 사용 프로젝트를 쓰지 않는다 (019 가 이미 쟀다). 쓴다면 건수만 기록 |
| plugin 진단 확인은 `dart analyze` | Verification | 스크립트 · CI · 이 세션 모두 `dart analyze` |
| `include:` 대상 패키지는 `dependencies` 에 | Dependencies | `pubspec.yaml` 을 바꾸지 않는다. 조각이 include 하는 것은 `flutter_lints` 뿐 |
| YAML 주석 · README · CHANGELOG 는 한국어, 규칙명 · 키는 영어. 영어 식별자 뒤 조사는 한 칸 띄움 | Documentation, Comments | 새 파일의 머리 주석, fixture 의 Dart 주석, 화면 문구 |
| 규칙은 세 그룹 주석 아래 목록 형식, 끌 때는 `# - rule` 주석 처리, 맵 형식과 섞지 않음 | 규칙 추가/변경 방법 | 이 phase 는 규칙 줄을 **옮기기만** 한다. `fixtures/overrides/` 의 옵션 파일은 사용 프로젝트 쪽이라 맵 문법(`이름: false`)이다 — 다른 파일이므로 섞이지 않는다 (013: 같은 `rules:` 안에 섞으면 exit 3) |
| 실측으로 확인한 동작은 버전과 날짜를 함께 적음 | Comments | 정답지 머리 주석, README 기록, 이 문서 |
| 템플릿 영어 주석(1 ~ 12행, 60 ~ 64행)은 그대로 둔다 | Comments | `base.yaml` 로 옮긴다. 지우는 것은 Phase 5 (DOCS-10) |
| `plugins:` 를 바꾼 뒤 Analysis Server 재시작 | Platform Requirements | IDE 에서 이 저장소나 사용 프로젝트를 열어 둔 경우. 검증 명령은 전용 상태 폴더라 무관 |
| `pubspec.lock` 은 커밋하지 않음 (라이브러리 관례) | Runtime | 루트는 유지. fixture 는 `example/` 과 같은 예외 (`!fixtures/*/pubspec.lock`) |
| Conventional Commits (prefix 영어, 제목 · 본문 한국어), 커밋 전 린터 | Git 커밋 규칙, 글로벌 CLAUDE.md | 커밋 전 린터 = 루트 `fvm dart analyze` (0.6초). C2 뒤에는 `lib/analysis_options.yaml` 제외 없이도 0건이어야 한다 (PRESET-06) |
| 공개 함수에 Docstring, 함수명은 동사, 에러 핸들링 | 글로벌 CLAUDE.md | `tool/verify.dart` 의 새 함수 |
| GSD workflow 밖에서 직접 편집하지 않음 | GSD Workflow Enforcement | 계획 · 실행 단계가 따른다 |

## Standard Stack

이 phase 는 **외부 패키지를 새로 설치하지 않는다.** 쓰는 것은 지금 저장소에 있는 것뿐이다.

### Core

| 도구 | 버전 | 용도 | 근거 |
|---|---|---|---|
| Flutter / Dart (`.fvmrc`) | 3.47.5 / 3.13.4 | 모든 검증 · 실측 | `fvm dart --version` → `Dart SDK version: 3.13.4 (stable)`, `fvm flutter --version` → `Flutter 3.47.5 • channel stable` `[VERIFIED: local]` |
| `flutter_lints` / `lints` | 6.0.0 / 6.1.0 | `base.yaml` 이 include 하는 기반 세트 | `example/pubspec.lock`, 화면의 `기반 세트` 줄 `[VERIFIED: scratch]` |
| `riverpod_lint` (analyzer plugin) | 선언 `^3.1.3` → `^3.1.9` (C4), 풀린 버전 3.1.9 | `riverpod.yaml` 의 `plugins:` | scratch 의 plugin fixture 넷 모두 3.1.9 `[VERIFIED: scratch]`. pub 의존성이 아니라 Analysis Server 가 따로 받는다 |
| `flutter_riverpod` | `^3.0.0` (lock 3.4.3) | fixture 의 Riverpod 샘플 | `example/pubspec.yaml` `[VERIFIED: local]` |
| FVM | 4.3.1 | 로컬 `fvm dart …` | `[VERIFIED: local]` (02-RESEARCH 와 같다) |
| `gh` CLI | 2.102.0 | CI 결과 확인 | `[VERIFIED: local gh --version]` |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|---|---|---|
| fixture 마다 샘플 복사본 커밋 | 심볼릭 링크 (`fixtures/x/lib → ../../example/lib`) | macOS 에서는 같은 결과 (014). Windows / Linux 는 재지 않았고 runner 가 Linux 다 — 쓰지 않는다 |
| 차례로 분석 | `Future.wait` 로 한꺼번에 | runner 에서 약 1분 30초 절약 (017). 표본 여섯이라 드물게 깨지는지 모르고, 화면 순서를 따로 맞춰야 한다. 시간 제한에 여유가 있어 **이 phase 에서는 넣지 않는다** |
| 루트가 `flutter_lints` 를 include | `package:woody_lints/base.yaml` 을 include | 지금 `tool/verify.dart` 는 둘 다 0건 `[VERIFIED: spike 011; scratch]`. Phase 4 가 규칙을 바꾸면 `tool/` 에 새 진단이 생겨 phase 가 섞인다 — **이 phase 에서는 바꾸지 않는다** |

**Installation:** 없음. fixture 의 `pub get` 은 스크립트가 `dart pub get --no-example --enforce-lockfile` 로 한다.

## Package Legitimacy Audit

> 이 phase 는 외부 패키지를 설치하지 않는다. `pubspec.yaml` 과 `example/pubspec.yaml` 의 의존성은 그대로이고, 새 fixture 다섯의 `pubspec.yaml` 은 `example/pubspec.yaml` 의 복사본(`path:` 만 `../..`)이다. 따라서 Package Legitimacy Gate 를 돌릴 대상이 없다.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---|---|---|---|---|---|---|
| (새로 더하는 패키지 없음) | — | — | — | — | — | — |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```text
[사용 프로젝트 / fixture 의 analysis_options.yaml]
   │ include
   ├─ package:woody_lints/analysis_options.yaml  (옛 주소 = 별칭)  ──include──▶ recommended.yaml
   ├─ package:woody_lints/recommended.yaml        (묶음)           ──include──▶ [base.yaml, riverpod.yaml, codegen.yaml]
   ├─ package:woody_lints/base.yaml               (조각) ──include──▶ package:flutter_lints/flutter.yaml ──▶ lints
   ├─ package:woody_lints/riverpod.yaml           (조각) ── 최상위 plugins: riverpod_lint ──▶ Analysis Server plugin manager
   │                                                                      └─ 전용 상태 폴더 .plugin_manager/<hash>/ (pub.dev 에서 받아 AOT 컴파일)
   └─ package:woody_lints/codegen.yaml            (조각) ── analyzer.errors / analyzer.exclude (규칙 쪽에만 통함 — 012)
   ▼
Dart Analysis Server (dart --suppress-analytics analyze --format=json, fixture 폴더가 cwd, 인자 없음)
   ▼ JSON
tool/verify.dart ── 정규화(상대경로:줄  강도  code, 정렬) ── 판정: plugin 머리말 → 도구 사망 → 정답지 비교
   │
   ├─ [1/9] lib/ 에 .dart 없음
   ├─ [2/9] 규칙 이름: lib/{base,codegen,riverpod}.yaml → build/woody_rule_check/<조각>/analysis_options.yaml (plugins: 는 있으면 뺌)
   │        → dart analyze build/woody_rule_check  → 통과 = exit 0 이고 진단 0건 (+ base 의 규칙 수 > 0)
   ├─ [3/9] 연습용 프로젝트 여섯의 옵션 파일이 정해진 내용과 같은지
   └─ [4/9] ~ [9/9] fixture 마다: example / recommended / base_only / overrides / base_riverpod / base_codegen
            (recommended 는 example 의 같은 실행 결과와 견준다 — 자기 정답지 없음)
   ▼
화면 (버전 3줄 → 단계 9줄 → 실패 · 갱신 내용 → "정답지를 썼다 (N개)" → 요약) / 종료 코드 0 · 1 · 64 · 69 · 70 · 78
```

### Recommended Project Structure

C4 가 끝난 뒤의 모양이다. `example/` 은 그대로이고, 새 폴더는 `fixtures/` 하나다.

```text
lib/
├── analysis_options.yaml      # 별칭 — include: package:woody_lints/recommended.yaml (3줄: 주석 2 + include 1)
├── recommended.yaml           # 묶음 — 조각 셋의 목록 include (6줄)
├── base.yaml                  # 옛 파일 1~41행 + 59~64행 (47줄). 규칙 12개 + 주석 처리 2개, formatter 주석, 템플릿 영어 주석
├── codegen.yaml               # 옛 파일 42~48행 (7줄). analyzer.errors + analyzer.exclude
└── riverpod.yaml              # 옛 파일 49~58행 (10줄). plugin 설명 주석 8줄 + plugins: riverpod_lint: ^3.1.9
analysis_options.yaml          # 루트 — include flutter_lints, exclude 'example/**' · 'fixtures/**' (lib/analysis_options.yaml 줄 삭제)
example/                       # fixture 1 (옛 주소). 바꾸지 않는다
fixtures/
├── recommended/               # fixture 2 — 정답지 없음 (example 과 견줌)
├── base_only/                 # fixture 3 — expected_diagnostics.txt (exit 2 · 18줄)
├── overrides/                 # fixture 4 — lib/suppress/ 5파일 더 있음, expected (exit 2 · 18줄)
├── base_riverpod/             # fixture 5 — expected (exit 2 · 21줄)
└── base_codegen/              # fixture 6 — expected (exit 0 · 13줄)
    각 폴더: pubspec.yaml (path: ../..), pubspec.lock (커밋), analysis_options.yaml, lib/ (example/lib 의 복사본)
tool/verify.dart               # 단계 9개, fixture 표, --update 일괄
.dart_tool/woody_verify/       # 상태 폴더 — example/, fixtures/<이름>/ (gitignore)
```

### Pattern 1: 잘라서 옮기고 이어 붙여 원본과 견준다 (구조 변경의 증명)

**What:** 조각 셋은 `git show 90a2736:lib/analysis_options.yaml` 을 줄 범위로 자른 것이다. 자른 조각을 같은 순서로 이으면 원본과 글자 하나 다르지 않다.
**When to use:** C2 의 단언. 새 파일(묶음 · 별칭)의 머리 주석은 비교에서 뺀다 — 비교에 들어가는 것은 조각 셋뿐이다.
**Example:** `[VERIFIED: scratch — REJOIN: identical]`
```bash
# 저장소 루트에서. base.yaml 의 1~41행 = 옛 1~41행, base.yaml 의 42~47행 = 옛 59~64행
{ sed -n '1,41p' lib/base.yaml; cat lib/codegen.yaml lib/riverpod.yaml; sed -n '42,47p' lib/base.yaml; } \
  | diff - <(git show 90a2736:lib/analysis_options.yaml) && echo "옮기기만 했다"
```

### Pattern 2: 대조군은 "남는 줄" 로 증명한다

**What:** "적용되지 않는다" 는 정답지에 **있는** 줄로 증명한다. `base_only` 의 생성 파일 4줄 + `invalid_annotation_target` 1줄, `overrides` 의 끄지 않은 옆자리(`lint_line.dart:6`, `plugin_line.dart:13`)와 접두사 없는 주석의 줄(`plugin_line.dart:11`, `plugin_file_unprefixed.dart:8`) 이 그것이다.
**When to use:** 모든 새 fixture. 줄 수만 세지 않고 전체를 견준다 (D-04 "줄 수만 세지 않는다").

### Pattern 3: fixture 표 하나가 단계 · 상태 폴더 · 정답지 · 옵션 파일 · plugin 줄을 모두 정한다

**What:** `tool/verify.dart` 의 `const fixtures = ['example']` 을 레코드 목록으로 바꾼다 — 경로, 화면 이름, 옵션 파일의 정해진 내용, plugin 을 쓰는지, 정답지 자리(없으면 `example` 과 견줌). `[3/9]` 와 `[4/9]` ~ `[9/9]`, 상태 폴더, `--update` 의 대상 목록이 이 표에서 나온다.
**When to use:** C3. § Code Examples 1 에 모양이 있다.

### Pattern 4: 규칙 검사의 통과 조건은 "exit 0 이고 진단 0건"

**What:** 세 코드(`deprecated_lint` / `removed_lint` / `undefined_lint`)만 고르지 않는다. 복사본 폴더의 진단이 하나라도 있거나 종료 코드가 0 이 아니면 실패다. 깨진 YAML(exit 3 · 진단 0건)은 따로 알린다.
**When to use:** C1. 세 입력이 모두 `[2/N]` 에서 잡힌다 `[VERIFIED: scratch — 규칙 검사 복사본의 직접 실행 결과, § 권고 6]`.

### Anti-Patterns to Avoid

- **한 파일 구조인 채로 루트의 `lib/analysis_options.yaml` 제외를 먼저 지우는 것.** `plugins_in_inner_options` 로 exit 2 (011). 지우는 것은 C2 (나누는 커밋) 다.
- **조각을 손으로 다시 쓰는 것.** Pattern 1 의 비교가 깨진다. 머리 주석도 조각 셋에는 더하지 않는다 (더하면 `base.yaml` 의 규칙 줄 번호가 밀려 `[2/9]` 실패 문구의 줄 번호가 원본과 어긋난다).
- **묶음이나 별칭을 규칙 검사 대상에 넣는 것, `riverpod.yaml` 을 `plugins:` 를 담은 채 복사하는 것.** plugin 을 준비해 10초 + 네트워크 (013).
- **"규칙 0개" 확인을 모든 조각에 거는 것.** `codegen.yaml` 과 (`plugins:` 를 뺀) `riverpod.yaml` 에는 규칙이 없다 — `base.yaml` 에만 건다 (013).
- **상태 폴더를 하나로 합치는 것.** plugin 폴더가 넷이 되어 `plugin` 줄이 `?` (014).
- **새 fixture 폴더를 루트에서 제외하지 않는 것.** 커밋 전 린터에 39건이 섞이고 plugin 준비로 18 ~ 22초 (011).
- **`recommended` 에 자기 정답지를 두는 것.** "옛 주소와 묶음이 같다" 를 구조로 묶는 D-03 이 풀린다.
- **주석 칸의 대조에 쓰는 진단을 같은 프로젝트의 옵션 파일에서 끄는 것.** 대조 줄이 함께 사라진다 (012 의 8번). § 권고 1 의 `overrides` 설계가 이를 피한다.
- **생성 파일 샘플에 plugin 위반을 넣는 것.** `codegen.yaml` 을 받아도 그 줄이 나오고, 그 줄은 pub.dev 의 `analyzer` 릴리스에 묶인다.
- **루트 옵션 파일이나 README 에 "루트 분석이 plugin 을 준비하지 않도록" 을 이유로 적는 것.** Dart 3.13.4 의 사실이고 베타에서는 틀리다 (016). 이유는 "그 폴더의 진단이 루트 분석에 섞이지 않게" 로 적는다.
- **fixture 에서 `flutter pub get` 을 돌리는 것.** 옵션 파일 맨 위에 `build/**` 제외를 써넣어 `[3/9]` 가 실패한다 (004).

## 계획이 정해야 할 것 — 근거와 권고

CONTEXT 의 "Claude's Discretion" 열한 항목이다. 항목마다 근거와 권고 하나를 적는다.

### 권고 1 — fixture 는 `fixtures/<이름>/` 다섯 폴더, 샘플은 `example/lib` 의 복사본을 커밋한다

**근거**
- spike 011 · 014 · 017 이 모두 `fixtures/{recommended,base_only,overrides,base_riverpod,base_codegen}/` 이름으로 쟀고, 017 의 runner 결과(16 / 16 / 18 / 15 / 21 / 13줄)가 그 이름으로 기록되어 있다 `[VERIFIED: spike 014, 017]`. 같은 이름을 쓰면 skill 의 표와 이 저장소가 그대로 대응한다.
- 한 폴더 아래에 모으면 루트 제외가 `'fixtures/**'` 한 줄이다 (011). `example/` 안에 두는 것은 `example/` 의 분석에 섞일 것이라 재지 않았다.
- 샘플 복사본: 014 의 권고. `recommended` 는 `example/` 의 결과와 견주므로 복사본이 어긋나면 비교가 잡는다 — 나머지 넷은 자기 정답지와 견주어 어긋남이 잡히지 않지만, 정답지를 처음 쓸 때 § 권고 11 의 전문과 견주면 드러난다. 심볼릭 링크는 Linux 에서 재지 않았다.
- 이 세션: `cp -R example/lib fixtures/<이름>/lib`, `pubspec.yaml` 의 `path: ..` → `../..` 와 `name:` → `woody_lints_fixture_<이름>`, `pubspec.lock` 의 `path: ".."` → `"../.."` 로 다섯을 만들고 `dart pub get --no-example --enforce-lockfile` 이 다섯 모두 exit 0 `[VERIFIED: scratch]`. `name:` 을 바꿔도 lock 과 어긋나지 않는다 (lock 에는 루트 패키지 이름이 없다).

**권고**
- 폴더: `fixtures/recommended/`, `fixtures/base_only/`, `fixtures/overrides/`, `fixtures/base_riverpod/`, `fixtures/base_codegen/`. 화면 순서는 CONTEXT 미리보기대로 example → recommended → base_only → base_riverpod → base_codegen → overrides (D-03 의 번호 1 → 2 → 3 → 5 → 6 → 4). 단, `recommended` 는 `example` 의 결과와 견주므로 **반드시 example 뒤**에 둔다.
- 폴더마다 `pubspec.yaml` (`name: woody_lints_fixture_<이름>`, `path: ../..`), `pubspec.lock` (`example/` 의 것에서 `path` 만 바꿈), `analysis_options.yaml`, `lib/` (= `example/lib` 복사본 7파일). `overrides` 만 `lib/suppress/` 5파일을 더한다 (§ Code Examples 4).
- 옵션 파일 전문은 § Code Examples 3. `recommended` · `base_only` 는 한 줄, `base_riverpod` · `base_codegen` 은 목록 include, `overrides` 는 묶음 + 끄는 설정 두 블록.
- `overrides` 는 **하나**로 둔다 (D-04 기본값). 프로젝트 전체에서 끄는 것은 `prefer_final_locals` (규칙, `added_rules.dart:24` 가 사라진다) 와 `missing_provider_scope` (plugin, `main.dart:5` 가 사라진다. warning 이지만 `provider_parameters` 가 남아 `exit 2` 그대로). 주석으로 끄는 것은 spike 012 그대로 `prefer_single_quotes` 와 `provider_parameters`. 넷이 서로 다르므로 대조 줄이 사라지지 않는다 `[VERIFIED: scratch — overrides 18줄, § 권고 11]`.

### 권고 2 — plugin 준비는 나눠 쓰지 못한다. 상태 폴더는 `.dart_tool/woody_verify/<fixture 경로>/`

**근거**
- plugin 폴더 이름은 분석 대상 루트의 (링크를 푼) 경로의 md5 다 (008). 경로가 다르면 fixture 마다 따로 받아 컴파일한다 — 넷이 각각 13 ~ 15초 (로컬), 30 ~ 45초 (runner). 나눠 쓰는 길은 같은 경로에서 옵션 파일만 바꾸는 방식(014 의 B)뿐인데 "커밋된 폴더를 그대로 분석한다" 를 포기해야 하고 runner 에서 재지 않았다 `[VERIFIED: spike 014, 017]`.
- 상태 폴더를 함께 쓰면 plugin 폴더가 4개가 되어 버전을 읽지 못한다 (014). 지금 코드의 `'$repoRoot/.dart_tool/woody_verify/$fixture'` 에 `fixture = 'fixtures/base_only'` 를 넣으면 `.dart_tool/woody_verify/fixtures/base_only/` 가 되고 `createSync(recursive: true)` 라 그대로 된다. 이 세션이 그 자리로 여섯을 돌려 plugin 폴더 1 / 1 / 0 / 1 / 0 / 1 `[VERIFIED: scratch]`.

**권고:** 나눠 쓰지 않는다. 상태 폴더는 fixture 의 저장소 기준 경로를 그대로 붙인다 (`.dart_tool/woody_verify/example/`, `.dart_tool/woody_verify/fixtures/<이름>/`). 차례로 돌린다 (동시 실행은 Deferred).

### 권고 3 — `pubspec.lock` 은 커밋하고 `.gitignore` 에 `!fixtures/*/pubspec.lock` 한 줄

**근거**
- 02-CONTEXT.md D-05 를 그대로 따른다 (CONTEXT 의 기본값). lock 이 없으면 `--enforce-lockfile` 이 돌지 않는다.
- 부정 패턴에 `*` 를 쓴 한 줄이 다섯 폴더에 모두 걸리는지 이 세션이 `git check-ignore -v` 로 확인했다 `[VERIFIED: scratch]`:

```text
pubspec.lock                   -> .gitignore:1:pubspec.lock
example/pubspec.lock           -> .gitignore:2:!example/pubspec.lock
fixtures/base_only/pubspec.lock -> .gitignore:3:!fixtures/*/pubspec.lock
fixtures/overrides/pubspec.lock -> .gitignore:3:!fixtures/*/pubspec.lock
```

**권고:** `.gitignore` 의 `!example/pubspec.lock` 아래에 `!fixtures/*/pubspec.lock` 과 한국어 주석 한 줄을 더한다. 루트 `pubspec.lock` 은 그대로 커밋하지 않는다. 다섯 lock 은 `example/pubspec.lock` 에서 `path` 줄만 바꾼 복사본이다 (`pub get` 이 다시 쓰지 않았다 — 다섯 모두 `--enforce-lockfile` exit 0).

### 권고 4 — plugin 을 쓰지 않는 fixture 는 `plugin` 줄과 머리 주석에 `해당 없음`

**근거**
- plugin 을 선언하지 않는 조합에서 plugin 폴더 0개는 정상이다 (009, 014). 지금 코드는 0개면 `?` + "상태 폴더 환경변수가 듣지 않았을 수 있다" 를 찍고 `--update` 는 머리 주석에 `riverpod_lint ?` 를 쓴다 (`02-VERIFICATION.md` 5번). 그대로 두면 `base_only` · `base_codegen` 의 정답지가 늘 `?` 를 달고, "plugin 이 뜨지 않았다" 는 진짜 실패와 구별되지 않는다.
- 014 가 "해당 없음" 을 제안했다.

**권고**
- fixture 레코드에 `usesPlugin` 을 둔다. `false` 면 `readPluginVersion` 을 부르지 않고 `PluginVersion.notApplicable` (text `해당 없음`) 을 쓴다. `true` 인데 폴더 0개면 지금처럼 `?` 와 이유다.
- 정답지 머리 주석: plugin 을 쓰는 fixture 는 `# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12`, 쓰지 않는 fixture 는 `riverpod_lint 해당 없음`.
- 화면 맨 위의 `plugin` 줄은 하나다 — plugin 을 쓰는 fixture 넷이 읽은 값이 모두 같으면 그 값, 하나라도 `?` 면 `?` 와 그 fixture 의 이유, 둘 이상의 다른 값이면 `?` 와 "fixture 마다 다름" (같은 실행에서 다른 값이 나올 길은 없지만 막아 둔다). `(이번 실행에서는 plugin 이 뜨지 않았다)` 덧말은 지금처럼 `pluginFailed` 가 하나라도 있으면 붙인다.

### 권고 5 — 단계는 9개. `[2/9]` 는 조각 셋을 한 번에, `[3/9]` 는 옵션 파일 여섯을 한 번에

**근거**
- CONTEXT 미리보기가 9단계를 보였고 소유자가 그 화면을 보고 `--update` 를 골랐다 (D-06). `[1/9]` lib 검사, `[2/9]` 규칙 이름, `[3/9]` 옵션 파일, `[4/9]` ~ `[9/9]` fixture 여섯 — 지금 코드의 fixture 당 두 단계(옵션 파일 + 정답지)를 그대로 늘리면 2 + 12 = 14단계라 미리보기와 다르다.
- `[2/9]` 의 대상: `lib/base.yaml`, `lib/codegen.yaml`, `lib/riverpod.yaml` 을 `build/woody_rule_check/{base,codegen,riverpod}/analysis_options.yaml` 로 복사해 폴더 하나를 인자로 한 번에 돌린다. 이 세션이 깨끗한 조각 셋으로 처음 돌려 `exit 0`, `{"version":1,"diagnostics":[]}`, plugin 폴더 0 `[VERIFIED: scratch]` (013 은 문제 규칙을 넣은 둘만 한 번에 돌렸었다). 진단의 경로에 조각 이름이 들어가므로(`build/woody_rule_check/riverpod/analysis_options.yaml:12`) 어느 파일인지 그대로 읽힌다.
- `stripPlugins`: 지금은 섹션을 못 찾으면 `FormatException` (별칭으로 바꾸면 exit 70 — 이 세션도 나눈 구조에서 지금 스크립트를 돌려 `파일 모양이 예상과 다르다: lib/analysis_options.yaml 에서 `plugins:` 섹션을 찾지 못했다`, exit 70 `[VERIFIED: scratch]`). "있으면 뺀다" 로 바꾸고, 뺀 뒤에 `^plugins:` 줄이 남아 있으면 `FormatException` 을 던진다 (패턴이 섹션을 놓친 경우를 조용히 넘기지 않는다 — 013 의 추론). `riverpod.yaml` 에서 `plugins:` 를 빼면 주석 8줄만 남고, 이 세션의 정규식(`^plugins:\n(?:[ \t]+.*\n)+`)으로 뺀 뒤 `^plugins:` 가 남지 않았다 `[VERIFIED: scratch]`.
- `shippedOptionsPath` → `ruleCheckTargets = ['lib/base.yaml', 'lib/codegen.yaml', 'lib/riverpod.yaml']` 과 `rulesFile = 'lib/base.yaml'` ("규칙 0개" 확인은 여기에만). 묶음과 별칭을 넣지 않는 이유는 013 (plugin 준비).
- "규칙이 적힌 모든 파일" 을 미래에도 놓치지 않으려면 집합 확인을 하나 둔다: `lib/` 의 `*.yaml` 이 정확히 `{analysis_options, recommended, base, codegen, riverpod}` 다섯인지. 새 조각이 생기면 이 확인이 실패해 대상 목록을 손보게 한다 (`[1/9]` 에 붙이거나 `[2/9]` 의 첫 확인으로).
- `[3/9]`: fixture 레코드의 `optionsText` (주석 · 빈 줄을 뺀 정해진 줄들) 와 파일의 내용을 견준다. `flutter pub get` 이 써넣는 `build/**` 제외와 include 삭제를 여섯 파일에서 잡는다. 실패하면 어느 파일이 어떻게 다른지 파일별로 적는다.

**권고:** 위 그대로. 단계 줄의 결과 단어는 보통 실행에서 `통과 / 실패`, `--update` 에서는 정답지 단계만 `바뀐 줄 없음 / 갱신` (미리보기). 종료 코드 규약(0 / 1 / 64 / 69 / 70 / 78)은 그대로다.

### 권고 6 — "가장 먼저 할 일": `[2/N]` 의 통과 조건을 "exit 0 이고 진단 0건" 으로 바꾸고, 깨진 YAML 은 exit 3 + 진단 0건으로 따로 알린다

**오늘 코드(`40776b5`)의 모양 — 세 입력을 scratch 복사본에서 재현했다** `[VERIFIED: scratch, 2026-10-12, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9]`. 입력은 `lib/analysis_options.yaml` 에만 넣었고 한 번에 하나씩, 매번 원본과 정답지를 되돌렸다.

| 입력 | 바꾼 줄 | `--update` 실행 | 보통 실행 | 규칙 검사 복사본을 직접 돌리면 (`dart analyze --format=json build/woody_rule_check`) |
|---|---|---|---|---|
| A 닫지 않은 따옴표 | 46행 `- '**/*.freezed.dart'` → `- '**/*.freezed.dart` | **exit 0**. `[2/4] 통과`, `[4/4] 통과`(갱신 모드), `종료 코드: 정답지 2, 실제 3`, `- ` 16줄 전부, `+ lib/should_not_appear.dart:5  warning  invalid_annotation_target`, `정답지를 썼다`, `점검 통과 (4개 중 4개)`. 정답지가 `exit 3` + 1줄로 바뀜 | exit 1. `[4/4]` 만 실패 (16줄 빠짐 + 1줄 더해짐, 종료 코드 2 → 3) | **exit 3, `{"version":1,"diagnostics":[]}`**, stderr 비어 있음. 형식 인자 없이 돌리면 `error - analysis_options.yaml:47:8 - While parsing a block collection, expected '-'. - parse_error` |
| B `rules:` 오타 | 21행 `  rules:` → `  ruels:` | **exit 0**. `[2/4] 통과`, `- ` 이 패키지가 추가하는 6줄, `+ analysis_options.yaml:1  warning  included_file_warning`, `정답지를 썼다`, `점검 통과 (4개 중 4개)` | exit 1. `[4/4]` 만 실패 | exit 2, `analysis_options.yaml:21  warning  unsupported_option` ("The option 'ruels' isn't supported by 'linter'.") |
| C 겹친 규칙 + 없는 진단 코드 | 40행 뒤에 `    - avoid_print # 겹친 선언 (실험)`, 44행 뒤에 `    no_such_code_zz9: ignore` | **exit 0**. `[2/4] 통과`, `+ analysis_options.yaml:1  warning  included_file_warning` × 2, `정답지를 썼다`, `점검 통과 (4개 중 4개)` | exit 1. `[4/4]` 만 실패 (`+` 2줄) | exit 2, `:41  warning  duplicate_rule`, `:46  warning  unrecognized_error_code` |
| (대조) 원본 그대로 | — | exit 0, `정답지와 같다 — 바뀐 줄 없음`, 정답지의 md5 가 실행 전후 같음 | exit 0 | exit 0, `{"version":1,"diagnostics":[]}` |

- 세 입력 모두 `[2/4]` 는 세 코드(`deprecated_lint` / `removed_lint` / `undefined_lint`)만 고르므로 통과로 찍히고, `[4/4]` 는 갱신 모드에서 늘 통과로 찍히므로(코드 주석: "실패로 세면 `--update` 가 자기가 쓰려는 차이에 막힌다") 안전장치가 막을 "실패한 단계" 가 없다. ROADMAP Notes 와 `02-VERIFICATION.md` 1번의 재현과 같다.
- B 와 C 에서 `[4/4]` 의 `included_file_warning` 은 사용 프로젝트 쪽에 나타나는 모양이다 (옵션 파일 1행에 붙는다). A 는 include 자체가 깨져 규칙 16줄이 전부 사라지고 종료 코드가 3 이다.

**권고 (C1 의 내용)**
1. `[2/N]` 의 판정 순서: (1) 도구 사망 — exit 가 `{0, 2, 3}` 밖이거나 stdout 에 JSON 없음 (지금과 같음) → (2) **깨진 옵션 파일** — `exit 3` 이고 진단 0건 → 실패. 문구에 "조각의 YAML 이 깨졌을 수 있다" 와 원인을 보는 법을 적는다. 스크립트가 같은 폴더를 형식 인자 없이 한 번 더 돌려(0.5초) `parse_error` 줄을 찾아 보여 주는 것을 권한다 (013 의 제안. JSON 에는 error 강도의 옵션 파일 진단이 나오지 않는다 — `dart analyze` 의 알려진 동작) → (3) `include_file_not_found` → 루트 `pub get` 안내 (지금과 같음) → (4) `base.yaml` 의 `countDeclaredRules == 0` → 실패 (지금과 같음) → (5) **진단이 하나라도 있으면 실패** — 세 코드는 `(규칙이름)` 을 덧붙여 지금처럼, 그 밖의 코드(`unsupported_option`, `duplicate_rule`, `unrecognized_error_code`, …)는 줄을 그대로 보여 주고 "배포 파일의 옵션 경고" 라고 적는다 → (6) exit 0 이고 0건 → 통과.
2. 이렇게 하면 세 입력이 모두 `[2/N] 실패` 가 되고, D-05 의 안전장치("다른 단계가 실패하면 어느 정답지도 쓰지 않는다") 가 `--update` 를 막는다. **C1 뒤의 기대 결과**: 세 입력 모두 `--update` 가 exit 1, `[2/4] 실패`, `다른 단계가 실패해 정답지를 쓰지 않았다`, 정답지의 git hash 불변. 보통 실행도 `[2/4]` 와 `[4/4]` 둘 다 실패, exit 1.
3. 원본 그대로일 때 새 조건으로도 통과한다 — 한 파일 복사본(`plugins:` 뺌)의 직접 실행이 exit 0 · 0건 `[VERIFIED: scratch]`. 나눈 뒤의 조각 셋도 exit 0 · 0건 `[VERIFIED: scratch]`.
4. `example/README.md`: 30행의 "다른 단계(`[1/4]` ~ `[3/4]`)가 실패했으면" 을 "다른 단계가 실패했으면" 으로 (C3 에서 `[1/9]` ~ `[3/9]` 와 fixture 가 늘어나므로 번호를 박지 않는다), 81행의 단계 설명을 코드가 실제로 보는 것 — "`[2/4]` 는 복사본의 종료 코드가 0 이 아니거나 진단이 하나라도 있으면 실패한다. 깨진 YAML 은 exit 3 + 진단 0건으로 따로 알린다. `base.yaml` 에서 규칙을 하나도 읽지 못해도 실패한다" — 로 맞춘다. `[2/4]` 의 실패 문구 "최상위 `linter:` 아래 `rules:` 목록이 비어 있거나 없다" 는 코드가 `rules:` 키를 보지 않으므로(`02-VERIFICATION.md` 2번) "`linter:` 블록 안에서 `- 규칙이름` 줄을 하나도 세지 못했다" 로 바꾼다.
5. 기록: 위 표의 A · B · C 를 `example/README.md` 의 지워 보기 표에 **M15 ~ M17** 로 더한다 — "고치기 전: `--update` exit 0 · 정답지 씀 / 고친 뒤: `[2/4]` 실패 · exit 1 · 정답지 불변". M12 · M13 의 형식과 같다.
6. 이 커밋은 `lib/` 를 건드리지 않는다 — 단언 `git diff --quiet 90a2736 -- lib` 와 `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt`.

### 권고 7 — 루트 `analysis_options.yaml` 의 새 모양: include 는 그대로, exclude 는 `example/**` · `fixtures/**` 둘

**근거**
- 나눈 구조 + 제외 없음 → exit 0 · 0건 · plugin 준비 없음 (011, `tool/verify.dart` 포함 replica). 이 세션: 아래 파일로 저장소 복사본 루트(`tool/verify.dart` 있음, 루트 `pub get` 뒤)를 빈 상태 폴더와 함께 분석 → `exit 0`, `{"version":1,"diagnostics":[]}`, `.plugin_manager` 없음, 0초 `[VERIFIED: scratch]`.
- `fixtures/**` 를 빼면 `pub get` 뒤 39건 + plugin 준비 (011). 끄는 설정용 폴더가 `plugins:` 를 직접 적어도 제외되어 있으면 `plugins_in_inner_options` 가 나지 않는다 (011).
- 루트가 `package:woody_lints/base.yaml` 을 include 해도 지금 `tool/verify.dart` 는 0건이다 (011; 이 세션도 exit 0 · 0건 · plugin 폴더 0 `[VERIFIED: scratch]`). 그러나 Phase 4 의 규칙 변경이 `tool/` 에 새 진단을 내면 phase 가 섞인다.
- 지금 파일의 4 ~ 5행 주석 "lib/analysis_options.yaml 을 include 하면 plugins: 가 루트로 들어와 분석마다 plugin 을 준비하므로 쓰지 않는다" 와 8 ~ 10행의 `plugins_in_inner_options` 설명은 나눈 뒤 사실이 아니거나(별칭에는 `plugins:` 가 없다) SDK 에 묶인 말이다 (016).

**권고:** C2 에서 아래 전문으로 바꾸고, C3 에서 `fixtures/**` 줄을 더한다 (C2 시점에는 `fixtures/` 가 없으니 그때는 `example/**` 한 줄).

```yaml
# 이 저장소 자체를 분석할 때만 쓰는 설정 (사용하는 프로젝트에는 전달되지 않는다 —
# 프로젝트는 lib/ 의 프리셋을 include 한다).
#
# tool/ 의 스크립트에는 기반 세트 규칙만 적용한다. 이 패키지의 조각을 include 하지 않는 것은
# 규칙을 바꾸는 변경(Phase 4)이 검증 스크립트의 진단과 섞이지 않게 하려는 것이다.
include: package:flutter_lints/flutter.yaml

# example/ 과 fixtures/ 는 일부러 규칙을 어긴 연습용 프로젝트라 루트 분석에서 뺀다
# (tool/verify.dart 가 폴더마다 따로 분석한다). 빼지 않으면 그 폴더들의 진단이 섞인다.
analyzer:
  exclude:
    - 'example/**'
    - 'fixtures/**'
```

- `lib/analysis_options.yaml` 줄은 **C2 에서 지운다** (C1 에서 지우면 exit 2 — 011). 커밋 전 린터(루트 `fvm dart analyze`)가 C2 뒤에 0건이어야 PRESET-06 이다.
- `base.yaml` include 는 Phase 4 · 5 가 다시 볼 선택지로 남긴다 (Open Questions).

### 권고 8 — 옛 파일 64행의 줄 범위 → 조각 대응표. 옮기기만 한다

`lib/analysis_options.yaml` (`90a2736`, 64행 + 끝 개행) `[VERIFIED: local Read]`. spike 009 의 `Shipped.read` 가 자른 자리와 같다 `[VERIFIED: spike 009]`.

| 옛 파일의 줄 | 내용 | 가는 곳 | 새 파일에서의 줄 |
|---|---|---|---|
| 1 ~ 12 | 템플릿 영어 주석 ("This file configures … core lints are also what is used by pub.dev") | `base.yaml` | 1 ~ 12 |
| 13 | `include: package:flutter_lints/flutter.yaml` | `base.yaml` | 13 |
| 14 | 빈 줄 | `base.yaml` | 14 |
| 15 ~ 16 | 주석 처리된 `# formatter:` / `#   trailing_commas: preserve` | `base.yaml` | 15 ~ 16 |
| 17 ~ 19 | 빈 줄, `# Uncomment the following section to specify additional rules.`, 빈 줄 | `base.yaml` | 17 ~ 19 |
| 20 ~ 40 | `linter:` / `rules:` / 그룹 주석 셋 / 규칙 12개 / 주석 처리된 `# - require_trailing_commas` (31), `# - public_member_api_docs` (34) | `base.yaml` | **20 ~ 40 (줄 번호가 같다)** — 첫 규칙 `prefer_const_constructors` 23행, 마지막 `control_flow_in_finally` 40행 `[VERIFIED: scratch grep]` |
| 41 | 빈 줄 | `base.yaml` | 41 |
| 42 ~ 47 | `analyzer:` / `errors:` / `invalid_annotation_target: ignore` / `exclude:` / 두 패턴 | `codegen.yaml` | 1 ~ 6 |
| 48 | 빈 줄 | `codegen.yaml` | 7 |
| 49 ~ 56 | plugin 설명 주석 8줄 ("# analyzer plugin (Dart 3.10+ …" ~ "… 2026-09-20 실측).") | `riverpod.yaml` | 1 ~ 8 |
| 57 ~ 58 | `plugins:` / `  riverpod_lint: ^3.1.3` | `riverpod.yaml` | 9 ~ 10 (C4 에서 10행만 `^3.1.9`) |
| 59 | 빈 줄 | `base.yaml` | 42 |
| 60 ~ 64 | 템플릿 영어 주석 ("For more information about the core and recommended set … analysis-options") | `base.yaml` | 43 ~ 47 |

- 결과: `base.yaml` 47줄, `codegen.yaml` 7줄, `riverpod.yaml` 10줄 `[VERIFIED: scratch wc -l]`. 이어 붙이면 원본과 동일 (Pattern 1).
- **조각 셋에는 머리 주석을 더하지 않는다.** `base.yaml` 앞에 줄을 더하면 규칙의 줄 번호가 밀려 `[2/9]` 의 실패 문구 "(복사본의 줄 번호는 원본과 같다)" 가 그대로 성립하지 않게 되고, Pattern 1 의 비교에 예외가 생긴다. `riverpod.yaml` 의 설명 주석 8줄 가운데 낡은 문장("Flutter 3.47.5 의 `flutter analyze` 는 …" 등)을 고치는 것은 Phase 5 (DOCS-10) 다.
- **새 파일 둘(묶음 · 별칭)에는 한국어 머리 주석을 단다.** spike 010 은 주석 없는 파일로 쟀는데, 이 세션은 아래 주석을 단 채로 재어 옛 주소 · 묶음 주소 모두 정답지와 같은 16줄 `[VERIFIED: scratch]`. 전문은 § Code Examples 2.
- 옛 `analysis_options.yaml` 의 바뀐 뒤 모양: 3줄 (주석 2 + `include: package:woody_lints/recommended.yaml`). "한 줄짜리 별칭" 의 뜻은 include 가 한 줄이라는 것이다.

### 권고 9 — 커밋 넷. "가장 먼저 할 일" 이 첫째, 하한 상향이 마지막

| 커밋 | 제목(안) | 바꾸는 파일 | 단언 (실행 뒤) |
|---|---|---|---|
| **C1** | `fix(03-01): --update 가 망가진 배포 파일의 결과를 정답지로 쓰지 못하게 [2/4] 를 넓힌다` | `tool/verify.dart`, `example/README.md` (30행 · 81행 · M15 ~ M17) | `git diff --quiet 90a2736 -- lib` ✓, `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt` ✓, 보통 실행 exit 0, 세 입력에서 `--update` exit 1 · 정답지 불변 |
| **C2** | `feat(03-02): 배포 파일을 base / riverpod / codegen 조각과 recommended 묶음으로 나누고 옛 주소는 별칭으로 둔다` | `lib/{base,codegen,riverpod,recommended}.yaml` 새로, `lib/analysis_options.yaml` 별칭으로, 루트 `analysis_options.yaml` (제외 삭제 + 주석), `tool/verify.dart` (규칙 검사 대상 셋, `stripPlugins`), `CHANGELOG.md` | Pattern 1 의 이어 붙이기 ✓, `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt` ✓ (성공 기준 1 전반), 루트 `fvm dart analyze` 0건 (PRESET-06), `fvm dart run tool/verify.dart` exit 0 · `[2/4] 통과`, `grep -c '^3.1.3' lib/riverpod.yaml` = 1 (아직 올리지 않음) |
| **C3** | `feat(03-03): 연습용 프로젝트 다섯과 정답지 넷을 더하고 검증 명령을 단계 9개로 늘린다` | `fixtures/**` (5폴더), `.gitignore`, 루트 `analysis_options.yaml` (`fixtures/**`), `tool/verify.dart` (fixture 표, `[3/9]`, 화면, `--update` 일괄, `해당 없음`), `example/README.md` (fixture 표 · 기록) | `example/expected_diagnostics.txt` 가 `19ae5ec` 그대로 ✓, 새 정답지 넷이 § 권고 11 의 전문과 같음, `fvm dart run tool/verify.dart` exit 0 · `점검 통과 (9개 중 9개)`, 루트 `fvm dart analyze` 0건 |
| **C4** | `feat(03-04): riverpod_lint 하한을 ^3.1.9 로 올린다` | `lib/riverpod.yaml` (10행), `fixtures/overrides/analysis_options.yaml` (`version: ^3.1.9`), `CHANGELOG.md` | **정답지 다섯이 C3 그대로** — `git diff --quiet <C3> -- example/expected_diagnostics.txt fixtures/*/expected_diagnostics.txt` ✓, `fvm dart run tool/verify.dart` exit 0 (plugin 재준비로 처음 실행 시간), `grep -rn 'riverpod_lint: \^3.1.3\|version: \^3.1.3' lib fixtures` = 0건 |

- C1 이 첫째인 이유: C3 가 정답지 넷을 `--update` 로 처음 쓰는데, 그 전에 망가진 결과를 쓰는 길이 닫혀 있어야 한다 (CONTEXT "가장 먼저 할 일").
- C2 에 `tool/verify.dart` 의 규칙 검사 대상 변경이 **함께** 들어가야 한다 — 따로 두면 그 사이의 커밋에서 검증이 exit 70 이다 (`stripPlugins` 가 별칭에서 `plugins:` 를 못 찾는다 `[VERIFIED: scratch]`). 루트의 제외 삭제도 같은 커밋이거나 그 뒤여야 한다 (011).
- C4 가 마지막인 이유: 정답지 다섯이 모두 생긴 뒤에 올려야 "하한 상향 커밋에서 정답지가 바뀌지 않는다" 를 다섯 모두에서 단언한다. 010 의 결과(두 선언 모두 3.1.9 로 풀려 16줄 같음)와 012 의 결과(`overrides` 가 `^3.1.9` 를 적어도 같은 진단)가 근거다. `overrides` 의 `version` 을 함께 올리는 것은 "fixture 의 선언 = 조각의 선언" 을 grep 으로 지킬 수 있게 하려는 것이다 (012: 사용 프로젝트가 적은 값이 그 프로젝트의 선언이 된다).
- C3 를 fixture 생성과 스크립트 변경으로 둘로 가를 수도 있다 — 가른다면 스크립트(표 · 단계 · `해당 없음`)가 먼저, fixture 와 정답지가 뒤다 (스크립트 없이 폴더만 있으면 루트 제외 `fixtures/**` 만 필요하고 검증은 그 폴더를 모른다). 기본값은 하나다.
- push 는 C3 뒤(또는 C4 뒤) 한 번 — D-09 의 첫 확인. 그 뒤 C4 · 문서 커밋의 push 는 묻지 않는다.
- 각 커밋 전 커밋 전 린터 `fvm dart analyze` (루트). C1 은 지금 파일(제외 둘)로, C2 부터는 새 파일로 0건이어야 한다.

### 권고 10 — CI: `timeout-minutes: 10` 그대로, workflow 의 다른 변경 없음

**근거**
- runner 에서 여섯을 차례로 돌린 job 은 재실행을 뺀 셈으로 202 ~ 258초, 가장 느린 표본 258초 (017). 실제 `tool/verify.dart` 는 거기에 규칙 검사(로컬 0.5초)와 `[3/9]` · 화면(수 ms)이 더해질 뿐이다. 10분의 절반 아래다 `[VERIFIED: spike 017]`.
- workflow 는 `on` 셋 · `permissions: contents: read` · `concurrency` · checkout@v7 · flutter-action@v2 (`.fvmrc`) · `dart run tool/verify.dart` 한 step 이고 fixture 수를 모른다 `[VERIFIED: local .github/workflows/verify.yml]`. `runs-on: ubuntu-latest` 는 018 대로 그대로.
- 캐시(`cache: true`, `~/.dartServer`)는 넣지 않는다 (PITFALLS Pitfall 12, 006).

**권고:** `.github/workflows/verify.yml` 의 YAML 은 바꾸지 않는다 (`git diff --quiet 008ea3f -- .github/workflows/verify.yml`). 26행 주석 "정상 약 2분 (spike 006)" 은 C3 push 뒤 첫 `verify` 실행의 실제 job 시간을 보고 "정상 약 N분 (연습용 프로젝트 여섯, 2026-10-12 실측 run <id>)" 으로 고치는 docs 커밋 하나를 phase 끝에 둔다 — 그 값이 6분을 넘으면 그때 15 로 올린다 (지금은 올릴 근거가 없다). CONTEXT D-03 의 "약 4분 15초 (추정)" 는 그 실측 값으로 소유자에게 다시 알린다.

### 권고 11 — 정답지 다섯의 전문 (어느 줄이 실측이고 어느 줄이 예측인가)

아래는 이 세션이 scratch 복사본에서 § 권고 1 · 8 의 구성 그대로 만들어 **실제로 분석한 결과**다 `[VERIFIED: scratch, 2026-10-12, Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 상태 폴더는 fixture 마다 따로]`. spike 009 · 014 · 017 의 줄 수(16 / 16 / 18 / 21 / 13)와 같고, `overrides` 는 § 권고 1 의 설계로 처음 잰 것이다 (017 의 `overrides` 15줄은 `provider_parameters` 하나만 끈 다른 옵션이었다). 실제 저장소의 첫 `--update` 가 이와 다르면 그 출력으로 확정하되 다른 까닭을 적는다 (경로 · 샘플이 글자 그대로면 줄 번호가 같다 — 02-RESEARCH A4 와 같은 가정, 그때는 맞았다).

**fixture 1 `example/` 과 fixture 2 `fixtures/recommended/`** — 커밋된 `example/expected_diagnostics.txt` (`19ae5ec`) 그대로. 나눈 뒤 두 결과가 서로 같고 커밋된 파일과도 같았다 (`diff example.golden recommended.golden` → SAME, `exit 2` · 16줄). `recommended` 는 파일을 두지 않는다.

**fixture 3 `fixtures/base_only/expected_diagnostics.txt`** — `exit 2` · 18줄 (16줄에서 plugin 3줄이 빠지고 5줄이 더해짐)

```text
# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 해당 없음, 2026-10-12
# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: fvm dart run tool/verify.dart --update
exit 2
lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
lib/added_rules.dart:18  info  always_declare_return_types
lib/added_rules.dart:24  info  prefer_final_locals
lib/added_rules.dart:29  info  prefer_single_quotes
lib/added_rules.dart:33  info  unawaited_futures
lib/added_rules.dart:7  info  prefer_const_constructors
lib/base_rules.dart:12  info  sort_child_properties_last
lib/base_rules.dart:17  info  use_build_context_synchronously
lib/base_rules.dart:22  info  avoid_print
lib/base_rules.dart:30  info  control_flow_in_finally
lib/base_rules.dart:34  info  slash_for_doc_comments
lib/base_rules.dart:38  info  prefer_is_empty
lib/base_rules.dart:8  info  sized_box_for_whitespace
lib/generated/sample.freezed.dart:4  info  avoid_print
lib/generated/sample.freezed.dart:4  info  prefer_single_quotes
lib/generated/sample.g.dart:4  info  avoid_print
lib/generated/sample.g.dart:4  info  prefer_single_quotes
lib/should_not_appear.dart:5  warning  invalid_annotation_target
```

**fixture 5 `fixtures/base_riverpod/expected_diagnostics.txt`** — `exit 2` · 21줄 (16줄 + 위의 5줄). 머리 주석은 `riverpod_lint 3.1.9`. 진단 줄은 `base_only` 의 18줄에 아래 3줄을 더한 것 (정렬 자리: `lib/generated/…` 다음, `lib/should_not_appear.dart` 앞)

```text
lib/main.dart:5  warning  missing_provider_scope
lib/riverpod_rules.dart:17  warning  provider_parameters
lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties
```

**fixture 6 `fixtures/base_codegen/expected_diagnostics.txt`** — `exit 0` · 13줄 (16줄에서 plugin 3줄이 빠짐). 머리 주석은 `riverpod_lint 해당 없음`. 진단 줄은 `base_only` 의 첫 13줄(`lib/added_rules.dart` 6줄 + `lib/base_rules.dart` 7줄)과 같다. **종료 코드가 0 인 유일한 정답지**다 — warning 이 하나도 없다.

**fixture 4 `fixtures/overrides/expected_diagnostics.txt`** — `exit 2` · 18줄. 머리 주석은 `riverpod_lint 3.1.9`

```text
exit 2
lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
lib/added_rules.dart:18  info  always_declare_return_types
lib/added_rules.dart:29  info  prefer_single_quotes
lib/added_rules.dart:33  info  unawaited_futures
lib/added_rules.dart:7  info  prefer_const_constructors
lib/base_rules.dart:12  info  sort_child_properties_last
lib/base_rules.dart:17  info  use_build_context_synchronously
lib/base_rules.dart:22  info  avoid_print
lib/base_rules.dart:30  info  control_flow_in_finally
lib/base_rules.dart:34  info  slash_for_doc_comments
lib/base_rules.dart:38  info  prefer_is_empty
lib/base_rules.dart:8  info  sized_box_for_whitespace
lib/riverpod_rules.dart:17  warning  provider_parameters
lib/riverpod_rules.dart:5  info  avoid_public_notifier_properties
lib/suppress/lint_line.dart:6  info  prefer_single_quotes
lib/suppress/plugin_file_unprefixed.dart:8  warning  provider_parameters
lib/suppress/plugin_line.dart:11  warning  provider_parameters
lib/suppress/plugin_line.dart:13  warning  provider_parameters
```

`example/` 의 16줄과의 차이 — 이것이 D-04 여섯 칸의 증거다:

| 칸 | 끈 것 | 정답지에서 | 대조 (남는 줄) |
|---|---|---|---|
| 프로젝트 전체 · 규칙 | `linter: rules: prefer_final_locals: false` | `- lib/added_rules.dart:24  info  prefer_final_locals` | 다른 규칙 12줄 + `lib/suppress/lint_line.dart:6` 의 `prefer_single_quotes` 가 남음 |
| 프로젝트 전체 · plugin | `plugins: riverpod_lint: version + diagnostics: missing_provider_scope: false` | `- lib/main.dart:5  warning  missing_provider_scope` | `provider_parameters` · `avoid_public_notifier_properties` 가 남음 |
| 파일 · 규칙 | `lint_file.dart` 의 `// ignore_for_file: prefer_single_quotes` | 그 파일의 줄이 없음 | — (파일 전체라 옆자리 없음. `lint_line.dart:6` 이 같은 규칙의 대조) |
| 파일 · plugin | `plugin_file_prefixed.dart` 의 `// ignore_for_file: riverpod_lint/provider_parameters` | 그 파일의 줄이 없음 | `+ lib/suppress/plugin_file_unprefixed.dart:8  warning  provider_parameters` — **접두사 없는 파일 주석은 끄지 못한다** (고정) |
| 한 줄 · 규칙 | `lint_line.dart:3` 의 `// ignore: prefer_single_quotes` | 3행 없음 | `+ lib/suppress/lint_line.dart:6  info  prefer_single_quotes` |
| 한 줄 · plugin | `plugin_line.dart` 9행 · 12행의 `// ignore: riverpod_lint/provider_parameters` | 9 · 12행 없음 | `+ lib/suppress/plugin_line.dart:13` (끄지 않음), `+ lib/suppress/plugin_line.dart:11` — **접두사 없는 `// ignore: provider_parameters` 는 끄지 못한다** (고정) |

- `fixtures/overrides/` 의 `version` 은 C3 에서 `^3.1.3` (조각과 같게), C4 에서 `^3.1.9`. 두 값 모두 3.1.9 로 풀려 정답지가 같다 (012).
- plugin 폴더: `example` 1, `recommended` 1, `base_only` 0, `overrides` 1, `base_riverpod` 1, `base_codegen` 0. stderr 는 여섯 모두 비어 있음. 처음 실행은 plugin 을 쓰는 것이 15 ~ 16초, 쓰지 않는 것이 3 ~ 4초 `[VERIFIED: scratch]`.
- **예측으로 남는 것:** 실제 저장소 경로에서의 첫 `--update` (scratch 는 경로만 다르다), GitHub runner 에서 실제 `tool/verify.dart` 로 돌린 결과 (017 은 spike 의 스크립트였다 — D-09 가 본다).

### CHANGELOG 2.0.0 항목과 `example/README.md` 의 갱신 범위

- `CHANGELOG.md` 의 `## 2.0.0 - 미출시` 는 `지원 SDK:` 줄 · `### 올리기 전에` · `### 그 밖의 변경` · `### 새로 생기는 경고` 가 있다 `[VERIFIED: local CHANGELOG.md]`. `VERSIONING.md` 의 형식은 "필수 두 칸 + 해당 칸만" 이고 `### 추가한 규칙` / `### 뺀 규칙` 은 규칙 목록이 바뀔 때만 둔다 `[VERIFIED: local VERSIONING.md § CHANGELOG 항목 형식]`. 이 phase 는 규칙을 넣고 빼지 않으므로 **`### 그 밖의 변경`** 에 적는다. C2 에 두 불릿(프리셋 분리 · 옛 주소는 묶음의 별칭이라 받는 구성이 같음), C4 에 한 불릿(`riverpod_lint` 하한 `^3.1.3` → `^3.1.9`, 같은 major 안이라 minor 등급. 2026-10-12 에 두 선언 모두 3.1.9 로 풀려 경고가 달라지지 않음) 을 더한다. `### 올리기 전에` 에는 "옛 주소 한 줄을 쓰는 프로젝트는 고칠 것이 없다 — 새 프로젝트는 `recommended.yaml` 을 쓴다" 를 적을 수 있다 (Phase 5 의 README 가 자세히 쓴다). `### 새로 생기는 경고` 의 자리 표시는 Phase 4 의 것이라 건드리지 않는다.
- `example/README.md`: (C1) 30행 · 81행 · `[2/4]` 문구 · M15 ~ M17 (§ 권고 6). (C3) 단계 9개 설명, "연습용 프로젝트 여섯" 표 (폴더 · include · plugin 유무 · 정답지 자리 · 줄 수 · 증명하는 것 — D-03 의 표를 그대로 옮긴다), 새 fixture 가 헛통과가 아님을 보이는 지워 보기 둘 — (M18) `lib/recommended.yaml` 에서 `- package:woody_lints/riverpod.yaml` 을 지우면 `example` 과 `recommended` 가 함께 실패(plugin 3줄 빠짐, `exit 2 → 0`, 010 의 모양 — 예측), (M19) `fixtures/overrides/analysis_options.yaml` 에서 `version:` 줄을 지우면 `missing_provider_scope` 가 되살아나 `overrides` 가 실패 (012 의 "version 없으면 조용히 무시" — 예측). 둘 다 실행해 기록한다. `README.md` (루트) 는 Phase 5 까지 그대로다.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| 조각 조합의 병합 | 스크립트가 조각을 이어 붙인 임시 옵션 파일 | analyzer 의 `include:` 목록 (사용 프로젝트가 조합한다) | 그것이 PRESET-01 ~ 03 이 검증하려는 동작 자체다. 조각끼리 겹치는 키가 없어 순서도 무관 (009) |
| plugin 버전 읽기 | md5 구현, `~/.dartServer` 훑기 | 전용 상태 폴더 + `readLockVersion` (지금 코드) | 008. fixture 가 여럿이면 폴더만 fixture 별로 |
| 정답지 비교 | 줄 수 비교, 종료 코드만 | 지금의 `findDifference` / `subtractLines` (건수까지) | 02-05 가 닫은 Gap 1. `recommended` 는 같은 함수로 `example` 의 결과와 견준다 |
| 규칙 상태 검사 | include 된 파일의 진단 모으기, 세 코드만 고르기 | 조각 셋을 `analysis_options.yaml` 이름으로 복사하고 "exit 0 · 0건" | 005, 007, 013. include 경유로는 `undefined_lint` 만 보인다 |
| YAML 파싱 | `yaml` 패키지 추가 | analyzer 가 내는 `parse_error` (exit 3 + 진단 0건) 와 글자 세기(`countDeclaredRules`) | D-11 (`dart:io` / `dart:convert` 만). 깨진 YAML 은 종료 코드로 충분히 드러난다 |
| 끄는 설정의 판정 | 소스 읽고 추정 | `fixtures/overrides/` 의 정답지 | 012 에서 소스 추정 29칸 중 3칸이 틀렸다 |

**Key insight:** 이 phase 가 "만드는" 것은 YAML 다섯과 fixture 폴더 다섯이고, 동작은 전부 analyzer 와 plugin 쪽에 있다. 스크립트가 할 일은 그 동작을 **그대로 재어 정답지와 견주는 것**이지 흉내 내는 것이 아니다.

## Runtime State Inventory

파일 분리(rename / refactor)라서 채운다. "없음" 도 확인한 것이다.

| Category | Items Found | Action Required |
|---|---|---|
| Stored data | 없음 — 데이터베이스 · 저장소가 없다. 정답지는 git 의 파일이다 | 없음 |
| Live service config | GitHub Actions workflow `verify` — 저장소 안 파일(`.github/workflows/verify.yml`)이 전부이고 UI 설정은 없다 `[VERIFIED: local]`. `ubuntu-latest` 가 2026-10-19 부터 26.04 로 옮겨 간다 (018 — 바꿀 것 없음) | 없음 (주석 한 줄은 § 권고 10) |
| OS-registered state | 없음 — 스케줄러 · 서비스 등록 없음 | 없음 |
| Secrets / env vars | 없음. 스크립트가 읽는 환경변수는 `CI`, `GITHUB_ACTIONS`, `FLUTTER_ROOT`, 쓰는 것은 `ANALYZER_STATE_LOCATION_OVERRIDE` 뿐 `[VERIFIED: local tool/verify.dart]` | 없음 |
| Build artifacts / 캐시 | (1) 전용 상태 폴더 `.dart_tool/woody_verify/example/` — 이름이 분석 대상 **경로**의 해시라 `lib/` 를 나눠도 그대로 쓰인다. 다만 `riverpod_lint` 선언이 `^3.1.9` 로 바뀌는 C4 뒤 첫 실행은 plugin 을 다시 준비한다 (010: 15.8초) `[VERIFIED: spike 010]`. (2) IDE 의 Analysis Server (`~/.dartServer`) — 이 저장소나 사용 프로젝트를 열어 둔 IDE 는 `plugins:` 변경 뒤 재시작 (CLAUDE.md). (3) 사용 프로젝트 5개의 pub cache — `ref: main` 을 따르고 `main` 은 바뀌지 않으므로 영향 없음 (019: `pub get` 은 lock 의 커밋에 머문다). (4) `build/woody_rule_check/` — 검사 뒤 `finally` 로 지움, `.gitignore` 의 `build/` | (1) 지우지 않는다 — 스크립트가 알아서 다시 준비 (2) README 안내는 Phase 5 (3) 없음 (4) 없음 |

## Common Pitfalls

### Pitfall 1: `--update` 가 깨진 배포 파일의 결과를 정답지로 굳힌다
**What goes wrong:** 세 입력 모두 `--update` exit 0 · `정답지를 썼다` `[VERIFIED: scratch]`. **Why:** `[2/4]` 가 세 코드만 고르고 `[4/4]` 는 갱신 모드에서 늘 통과. **How to avoid:** § 권고 6 (C1 을 첫째로). **Warning signs:** 정답지의 `exit` 줄이 3 이 되거나 `analysis_options.yaml:1  warning  included_file_warning` 이 들어간다.

### Pitfall 2: 한 파일 구조에서 루트 제외를 먼저 지운다
**What goes wrong:** 루트 분석 exit 2 (`plugins_in_inner_options`) `[VERIFIED: spike 011]`. **How to avoid:** C2 에서 나누기와 함께. **Warning signs:** 커밋 전 린터가 `lib/analysis_options.yaml:58` 을 가리킨다.

### Pitfall 3: 규칙 검사 대상을 `base.yaml` 하나로만 바꾼다
**What goes wrong:** 다른 조각에 숨은 deprecated 규칙을 어느 단계도 못 잡는다 (013 — `riverpod.yaml` 끝에 숨긴 문제 규칙 셋이 0건, 정답지 비교는 `undefined_lint` 하나만 `included_file_warning` 으로). **How to avoid:** 조각 셋 모두 + `lib/*.yaml` 집합 확인 (§ 권고 5).

### Pitfall 4: 상태 폴더 하나에 fixture 여럿
**What goes wrong:** plugin 폴더가 넷 → `plugin` 줄 `?` (014). **How to avoid:** `.dart_tool/woody_verify/<fixture 경로>/`.

### Pitfall 5: 주석 칸의 대조 진단을 프로젝트 전체에서 끈다
**What goes wrong:** `provider_parameters` 를 옵션 파일에서 끄면 `plugin_line.dart:13` 등 대조 줄 7줄이 모두 사라져 주석 칸이 헛통과 (012 의 8번). **How to avoid:** § 권고 1 — 프로젝트 전체는 `prefer_final_locals` · `missing_provider_scope`, 주석은 `prefer_single_quotes` · `provider_parameters` `[VERIFIED: scratch — 대조 줄 4줄이 남았다]`.

### Pitfall 6: `base_only` 의 정답지를 `exit 0` 으로 예상한다
**What goes wrong:** `invalid_annotation_target` 이 warning 이라 `exit 2` 다 (009; scratch). `exit 0` 은 `base_codegen` 하나.

### Pitfall 7: 새 fixture 폴더를 루트에서 제외하지 않는다
**What goes wrong:** `pub get` 뒤 루트 분석에 39건 + plugin 준비 18 ~ 22초 (011). **How to avoid:** `'fixtures/**'` 한 줄을 폴더를 만드는 커밋(C3)에서.

### Pitfall 8: 생성 파일 제외를 "전부 막는다" 고 적는다
**What goes wrong:** Dart 3.13.x 에서 plugin 진단에는 통하지 않고, 베타에서는 규칙 진단에도 통하지 않는다 (012, 016). **How to avoid:** 성공 기준 3 의 범위를 "Dart 3.13.4, 규칙 진단" 으로 적는다 (§ spike 012 가 거는 조건).

### Pitfall 9: `riverpod.yaml` 을 `plugins:` 를 담은 채, 또는 묶음 · 별칭을 규칙 검사에 넣는다
**What goes wrong:** 0건 · exit 0 으로 끝나지만 plugin 을 준비해 10초 + 네트워크 (013). **Warning signs:** `[2/9]` 가 갑자기 10초 걸린다.

### Pitfall 10: fixture 의 `pubspec.lock` 에서 `path:` 를 고치지 않는다
**What goes wrong:** `pubspec.yaml` 만 `../..` 로 바꾸면 lock 의 `path: ".."` 와 어긋나 `--enforce-lockfile` 이 exit 65 (004, 014). **How to avoid:** 둘 다 바꾼다 (§ 권고 1).

### Pitfall 11: 조각 셋에 머리 주석을 더한다
**What goes wrong:** `base.yaml` 의 규칙 줄 번호가 밀리고 Pattern 1 의 비교에 예외가 생긴다. **How to avoid:** 주석은 묶음 · 별칭 두 파일에만.

### Pitfall 12: `recommended` 를 커밋된 파일과 견준다
**What goes wrong:** Phase 4 에서 `example` 의 정답지가 정당하게 바뀌는 `--update` 실행에서 `recommended` 가 "다르다" 로 막혀 갱신이 되지 않는다. **How to avoid:** `recommended` 는 **같은 실행의 `example` 결과**(줄 + 종료 코드)와 견준다. 보통 실행에서 `example` 이 통과하면 그것이 곧 파일과 같음을 뜻한다. `example` 이 죽었으면 `recommended` 는 "견줄 결과 없음" 으로 실패.

## Code Examples

### 1. fixture 표 (tool/verify.dart 의 `const fixtures = ['example']` 을 대신한다)

```dart
// 연습용 프로젝트 하나. [expectedPath] 가 null 이면 자기 정답지가 없고 example 의 같은 실행 결과와 견준다.
class Fixture {
  const Fixture({
    required this.path,          // 저장소 기준 폴더. 상태 폴더는 .dart_tool/woody_verify/<path>/
    required this.label,         // 화면의 단계 이름 (미리보기의 "base_only (기본만)")
    required this.optionsLines,  // [3/9] 가 견주는, 주석·빈 줄을 뺀 옵션 파일 줄
    required this.usesPlugin,    // false 면 plugin 줄과 머리 주석에 `해당 없음`
    this.expectedPath,           // 정답지 (fixture 폴더 기준). recommended 만 null
  });
  // …
}

const fixtures = <Fixture>[
  Fixture(path: 'example', label: 'example (옛 주소)',
      optionsLines: ['include: package:woody_lints/analysis_options.yaml'],
      usesPlugin: true, expectedPath: 'expected_diagnostics.txt'),
  Fixture(path: 'fixtures/recommended', label: 'recommended (묶음)',
      optionsLines: ['include: package:woody_lints/recommended.yaml'], usesPlugin: true),
  Fixture(path: 'fixtures/base_only', label: 'base_only (기본만)',
      optionsLines: ['include: package:woody_lints/base.yaml'],
      usesPlugin: false, expectedPath: 'expected_diagnostics.txt'),
  Fixture(path: 'fixtures/base_riverpod', label: 'base_riverpod',
      optionsLines: ['include:', '- package:woody_lints/base.yaml', '- package:woody_lints/riverpod.yaml'],
      usesPlugin: true, expectedPath: 'expected_diagnostics.txt'),
  Fixture(path: 'fixtures/base_codegen', label: 'base_codegen',
      optionsLines: ['include:', '- package:woody_lints/base.yaml', '- package:woody_lints/codegen.yaml'],
      usesPlugin: false, expectedPath: 'expected_diagnostics.txt'),
  Fixture(path: 'fixtures/overrides', label: 'overrides (끄는 설정)',
      optionsLines: [/* § Code Examples 3 의 overrides 파일에서 주석·빈 줄을 뺀 줄 */],
      usesPlugin: true, expectedPath: 'expected_diagnostics.txt'),
];
```

`optionsLines` 의 비교는 지금 `checkFixtureOptions` 처럼 `trim()` 한 줄로 한다 (목록 항목의 들여쓰기 차이를 무시).

### 2. 새 파일 둘의 전문 (이 세션이 이 주석을 단 채로 재어 정답지와 같았다)

```yaml
# lib/recommended.yaml
# woody_lints 묶음 — 기본 규칙 + Riverpod plugin + 코드 생성 설정을 한 번에 받는다.
# 조각을 골라 받으려면 아래 셋 가운데 필요한 것만 include 한다.
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml
  - package:woody_lints/codegen.yaml
```

```yaml
# lib/analysis_options.yaml
# 옛 주소 (package:woody_lints/analysis_options.yaml) 의 별칭 — 묶음(recommended.yaml) 과 같다.
# 새 프로젝트는 package:woody_lints/recommended.yaml 을 include 한다.
include: package:woody_lints/recommended.yaml
```

위 두 블록의 첫 줄(`# lib/…`)은 여기서 붙인 파일 이름이다. 조각 셋(`base.yaml` · `codegen.yaml` · `riverpod.yaml`)은 § 권고 8 의 줄 범위를 잘라 만든다 — 손으로 쓰지 않는다.

### 3. fixture 의 옵션 파일 (§ 권고 11 의 정답지를 낸 그대로)

```yaml
# fixtures/recommended/analysis_options.yaml
include: package:woody_lints/recommended.yaml
```
```yaml
# fixtures/base_only/analysis_options.yaml
include: package:woody_lints/base.yaml
```
```yaml
# fixtures/base_riverpod/analysis_options.yaml   (base_codegen 은 둘째 줄이 codegen.yaml)
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml
```
```yaml
# fixtures/overrides/analysis_options.yaml  (C3 에서는 version: ^3.1.3, C4 에서 ^3.1.9)
include: package:woody_lints/recommended.yaml

# 프로젝트 전체에서 끄기 — 규칙 하나 (맵 문법) 와 plugin 진단 하나 (version 을 함께 적는다).
linter:
  rules:
    prefer_final_locals: false

plugins:
  riverpod_lint:
    version: ^3.1.3
    diagnostics:
      missing_provider_scope: false
```

### 4. `fixtures/overrides/lib/suppress/` 의 샘플 5파일 (spike 012 의 `samples` 에서 D-04 의 네 칸 + 꺼지지 않는 모양 하나)

```dart
// lib/suppress/lint_line.dart
/// 한 줄 주석으로 규칙 끄기.
// ignore: prefer_single_quotes
const String lintLineOff = "a";

/// 끄지 않은 같은 위반 (대조).
const String lintLineOn = "b";
```
```dart
// lib/suppress/lint_file.dart
// ignore_for_file: prefer_single_quotes

/// 파일 주석으로 규칙 끄기.
const String lintFileOff = "c";
```
```dart
// lib/suppress/plugin_line.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final lineFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 한 줄 주석으로 plugin 진단 끄기 — 접두사 있음 / 없음 / 같은 줄 끝 / 끄지 않음.
final lineConsumer = Provider<int>((ref) {
  // ignore: riverpod_lint/provider_parameters
  final a = ref.watch(lineFamily([1]));
  // ignore: provider_parameters
  final b = ref.watch(lineFamily([2]));
  final c = ref.watch(lineFamily([3])); // ignore: riverpod_lint/provider_parameters
  final d = ref.watch(lineFamily([4]));
  return a + b + c + d;
});
```
```dart
// lib/suppress/plugin_file_prefixed.dart
// ignore_for_file: riverpod_lint/provider_parameters
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final prefixedFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 파일 주석(접두사 있음)으로 plugin 진단 끄기.
final prefixedConsumer = Provider<int>((ref) => ref.watch(prefixedFamily([5])));
```
```dart
// lib/suppress/plugin_file_unprefixed.dart
// ignore_for_file: provider_parameters
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인자를 받는 provider.
final unprefixedFamily = Provider.family<int, Object?>((ref, value) => 0);

/// 파일 주석(접두사 없음)으로 plugin 진단 끄기 — 꺼지지 않는 모양을 정답지에 고정한다.
final unprefixedConsumer = Provider<int>((ref) => ref.watch(unprefixedFamily([6])));
```

각 블록의 첫 줄(`// lib/suppress/…`)은 파일 이름이고 파일에는 없다. 줄 번호(`lint_line.dart:6`, `plugin_line.dart:11` · `:13`, `plugin_file_unprefixed.dart:8`)는 이 전문 기준이다.

### 5. `[2/N]` 의 판정 (§ 권고 6) — 뼈대

```dart
// 규칙 검사 복사본 폴더를 분석한 결과를 판정한다. 통과는 "exit 0 이고 진단 0건" 하나다.
StepResult judgeRuleCheck(int exitCode, List<String>? lines, String stderrText, String baseCopy) {
  if (lines == null || !analyzeExitCodes.contains(exitCode)) return died(...);            // 지금과 같음
  if (exitCode == 3 && lines.isEmpty) return failed(['조각의 YAML 이 깨졌을 수 있다 — …', ...parseErrorLines]); // 새 가지 (013)
  final unresolved = lines.where((l) => l.endsWith('  $includeNotFoundCode'));             // 지금과 같음
  if (unresolved.isNotEmpty) return failed([...]);
  if (countDeclaredRules(baseCopy) == 0) return failed(['`lib/base.yaml` 의 `linter:` 블록에서 `- 규칙이름` 줄을 하나도 세지 못했다 …']);
  if (lines.isNotEmpty) return failed(['배포 파일에 옵션 경고가 있다 (${lines.length})', ...lines.map(annotate)]); // 세 코드 밖도 실패
  return passed;
}
```

`parseErrorLines` 는 같은 폴더를 형식 인자 없이 한 번 더 돌려(`dart --suppress-analytics analyze build/woody_rule_check`) stdout 에서 `parse_error` 를 담은 줄을 고른 것이다 — 이 세션의 입력 A 에서 `error - analysis_options.yaml:47:8 - While parsing a block collection, expected '-'. - parse_error` `[VERIFIED: scratch]`.

### 6. `stripPlugins` — 있으면 뺀다

```dart
/// 옵션 파일 내용에서 최상위 `plugins:` 섹션을 뺀다. 없으면 그대로 돌려준다.
/// 뺀 뒤에도 `plugins:` 줄이 남아 있으면 패턴이 섹션을 놓친 것이라 [FormatException] 이다.
String stripPlugins(String options, {required String shownAs}) {
  final stripped = options.replaceAll(RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true), '');
  if (RegExp(r'^plugins:', multiLine: true).hasMatch(stripped)) {
    throw FormatException('$shownAs 의 `plugins:` 섹션을 빼지 못했다');
  }
  return stripped;
}
```

### 7. Pattern 1 의 단언 (C2)

```bash
{ sed -n '1,41p' lib/base.yaml; cat lib/codegen.yaml lib/riverpod.yaml; sed -n '42,47p' lib/base.yaml; } \
  | diff - <(git show 90a2736:lib/analysis_options.yaml)     # 출력 없음 = 옮기기만 했다
git diff --quiet 19ae5ec -- example/expected_diagnostics.txt  # 종료 0 = 정답지 불변
```

### 8. `.gitignore` 에 더하는 줄 (C3)

```gitignore
# fixtures/ 의 연습용 프로젝트도 example/ 과 같은 이유로 lock 을 커밋한다.
!fixtures/*/pubspec.lock
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|---|---|---|---|
| 배포 파일 하나(`lib/analysis_options.yaml`)에 규칙 · plugin · codegen 설정 | 조각 셋 + 묶음 + 별칭 | 이 phase (C2) | 옛 주소의 뜻은 그대로. 사용 프로젝트가 조각을 고른다 |
| `[2/4]` 는 세 코드 + 규칙 0개만 | exit 0 · 진단 0건 (깨진 YAML 은 exit 3 + 0건) | 이 phase (C1) | `rules:` 오타 · 겹친 규칙 · 깨진 YAML 이 `[2/N]` 에서 잡히고 `--update` 가 막힌다 |
| 규칙 검사 대상 파일 하나, `stripPlugins` 는 못 찾으면 예외 | 조각 셋을 하위 폴더에, 있으면 뺀다 | 이 phase (C2) | `riverpod.yaml` 에 숨은 문제 규칙도 잡힌다 (013) |
| fixture 하나, 단계 4개 | fixture 여섯, 단계 9개, `--update` 일괄 | 이 phase (C3) | CI 약 2분 → 약 3분 20초 ~ 4분 20초 (017) |
| 루트 exclude 에 `lib/analysis_options.yaml` | `example/**` · `fixtures/**` 만 | 이 phase (C2 · C3) | PRESET-06 |
| `riverpod_lint: ^3.1.3` | `^3.1.9` | 이 phase (C4) | 2026-10-12 기준 풀린 버전 3.1.9 그대로 |
| 02-RESEARCH 권고 10 "fixture 가 늘어 값이 갈릴 수 있게 되면 fixture 별로 찍는다" (plugin 줄) | `usesPlugin` 레코드 + `해당 없음` | 이 phase (C3) | 대조군의 `?` 가 사라진다 |
| 03-CONTEXT.md code_context "origin 은 `ead9573`, 로컬이 4커밋 앞" | origin 은 `0d20c10`, 로컬이 7커밋 앞 | 2026-10-12 spike 017 · 018 의 push | D-09 의 첫 push 목록이 달라진다 |

**Deprecated/outdated:** `02-CONTEXT.md` 의 "루트 `lib/analysis_options.yaml` exclude 는 유지" 와 CLAUDE.md 의 같은 문장 (PRESET-06 이 뒤집는다); `.planning/research/ARCHITECTURE.md` § Recommended Project Structure 의 fixture 2개 구성 (D-03 의 여섯으로 대체); 같은 문서 § E 의 "riverpod_lint 규칙은 모두 warning" (003 — info 3 / warning 11 / error 1); spike 014 의 runner 시간 추정 (017 이 쟀다); `example/README.md` 81행의 "`rules:` 목록이 비어 있거나 없으면" (코드는 `rules:` 를 보지 않는다 — C1 이 고친다).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| A1 | 실제 저장소 경로에서 처음 쓰는 정답지 넷이 scratch 복사본의 전문(§ 권고 11)과 줄 단위로 같다 (경로만 다르다) | 권고 11 | 다르면 그 출력으로 확정하되 까닭(샘플 글자 · 줄 번호)을 적는다. 02-RESEARCH A4 와 같은 가정이고 그때는 맞았다 |
| A2 | 여섯으로 늘린 실제 `tool/verify.dart` 의 runner job 이 017 의 범위(약 3분 20초 ~ 4분 20초)에 규칙 검사 · `[3/9]` · 화면의 몇 초를 더한 값 안에 든다 | 권고 10 | 6분을 넘기면 `timeout-minutes` 를 15 로. D-09 가 phase 끝에 본다 |
| A3 | `recommended` 를 "같은 실행의 `example` 결과" 와 견주는 설계가 Phase 4 의 `--update` 흐름(정답지가 정당하게 바뀜)을 막지 않는다 | Pitfall 12 | 막히면 `recommended` 비교를 갱신 모드에서만 "`example` 의 새 결과" 기준으로 바꾼다 — 같은 뜻이다 |
| A4 | `base.yaml` 의 규칙 줄 번호를 지키는 것(머리 주석 없음)이 `[2/9]` 실패 문구의 "(복사본의 줄 번호는 원본과 같다)" 를 그대로 성립시킨다. `riverpod.yaml` 은 `plugins:` 가 맨 끝이라 뺀 뒤 어긋날 줄이 없다 | 권고 8 | 조각 앞에 줄이 생기면 문구에 "조각 이름과 줄" 을 적도록 바꾼다 |
| A5 | 지워 보기 M18 (묶음에서 `riverpod.yaml` 제거) · M19 (`overrides` 의 `version` 제거) 의 결과가 010 · 012 의 모양 그대로다 | CHANGELOG · README 절 | 예측이다. C3 에서 실행해 기록한다 — 다르면 기록이 그 값이 된다 |
| A6 | `pubspec.yaml` 의 `name:` 을 fixture 마다 다르게 적어도 분석 · `pub get` 에 영향이 없다 | 권고 1 | scratch 에서 다섯 모두 `pub get` 과 분석이 예상대로였다 (`[VERIFIED: scratch]`). 다른 이름으로 돌린 spike 는 없다 |

## Open Questions (RESOLVED)

계획(2026-10-12, `03-01` ~ `03-04-PLAN.md`)이 셋 모두 권고대로 정했다.

1. **루트 옵션 파일이 `package:woody_lints/base.yaml` 을 include 할지**
   - What we know: 지금 `tool/verify.dart` 는 두 include 모두 0건이고 plugin 을 준비하지 않는다 (011; scratch).
   - What's unclear: Phase 4 의 규칙 변경이 `tool/` 에 새 진단을 낼 때 그 수정이 어느 phase 의 일인지.
   - Recommendation: 이 phase 는 `flutter_lints` 그대로 (§ 권고 7). Phase 5 (DOCS-10 — 루트 파일 주석 정리) 에서 다시 본다.
   - **Resolution:** 권고대로 — 03-02 Task 2 가 루트 파일을 권고 7 의 전문(`include: package:flutter_lints/flutter.yaml` 그대로)으로 쓴다. `base.yaml` include 는 Phase 5 의 DOCS-10 에서 다시 본다.
2. **동시 실행(`Future.wait`)을 넣을지**
   - What we know: runner 에서 약 1분 30초 절약, 여섯 번 모두 통과 (017). 로컬 23초.
   - What's unclear: 드물게 깨지는지 (표본 여섯). 화면 순서를 따로 맞춰야 한다.
   - Recommendation: 넣지 않는다. CI 가 6분을 넘기면 그때 (Deferred).
   - **Resolution:** 권고대로 넣지 않는다 — 03-03 Task 1 이 fixture 를 차례로 돌린다. 03-04 Task 3 이 runner 의 job 시간을 재어 6분을 넘기면 `timeout-minutes` 를 15 로 올리는 것까지만 하고, 동시 실행은 Deferred 로 남긴다.
3. **`example/README.md` 의 지워 보기 기록 M18 · M19 를 어느 커밋에서 돌릴지**
   - Recommendation: C3 의 마지막 task (정답지 넷이 있어야 "실패" 가 보인다). 변경은 커밋하지 않고 되돌린다 (Phase 2 의 방식).
   - **Resolution:** 권고대로 — 03-03 Task 3 (정답지 넷을 쓴 Task 2 뒤) 이 M18 · M19 를 돌려 README 에 적고 `git checkout` 으로 되돌린다. 한 가지 덧붙임: `recommended` 를 같은 실행의 `example` 결과와 견주는 설계(Pitfall 12)에서는 M18 에서 `recommended` 가 **통과**한다 (둘이 똑같이 깨진다) — 깨짐은 `example` 과 `overrides` 가 잡는다. 03-03 의 A-03-2 에 적었고 README 의 읽는 법에 그 까닭을 적게 했다. A5 의 예측("함께 실패") 은 이 점에서 바뀐다.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| FVM + Flutter / Dart (`.fvmrc`) | 모든 검증 · 실측 | ✓ | 3.47.5 / 3.13.4 (`fvm dart --version`, `fvm flutter --version`) | `~/fvm/versions/3.47.5/bin/dart` 직접 호출 |
| pub.dev 접근 (네트워크) | `pub get`, plugin 준비 | ✓ (이 세션의 plugin 준비 여섯 번 성공) | — | 없음 — 오프라인이면 plugin 실패로 보고된다 |
| `gh` CLI (로그인) | CI 결과 확인 (D-09) | ✓ | 2.102.0 | GitHub 웹 화면 |
| 원격 브랜치 `gsd/v2.0-package-rework` | push · CI | ✓ `0d20c10` | — | — |
| GitHub Actions | VERIFY-04 · D-09 | ✓ run 38216842619 success | — | — |
| Flutter 베타 3.49.0-0.2.pre | — (016 의 것, 이 phase 는 쓰지 않는다) | ✓ fvm 캐시 | — | — |
| `python3` | — (이 세션의 정규화에만 썼다. 스크립트는 D-11 대로 Dart) | 불필요 | — | — |

**Missing dependencies with no fallback:** none
**Missing dependencies with fallback:** none

## Validation Architecture

> `workflow.nyquist_validation` 은 `.planning/config.json` 에서 `true` `[VERIFIED: local]`.

### Test Framework

| Property | Value |
|---|---|
| Framework | 없음 (D-11 — `dart:io` / `dart:convert` 만). `tool/verify.dart` 와 정답지 다섯이 테스트 하네스다 |
| Config file | `example/expected_diagnostics.txt` (불변), `fixtures/{base_only,overrides,base_riverpod,base_codegen}/expected_diagnostics.txt` (Wave 0 · C3), `.github/workflows/verify.yml` (불변) |
| Quick run command | `fvm dart run tool/verify.dart` (재실행: plugin 을 쓰는 넷 약 3.5초씩 + 쓰지 않는 둘 약 3초씩 ≈ 20초, 014) |
| Full suite command | 같은 명령. CI: `dart run tool/verify.dart` (약 3분 20초 ~ 4분 20초, 017) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| PRESET-01 | `base.yaml` 만 → 규칙 진단 있음, plugin 0줄, 생성 파일 4줄 + `invalid_annotation_target` 있음 | integration | `fvm dart run tool/verify.dart` → `base_only (기본만)` 통과, 정답지 = § 권고 11 (exit 2 · 18줄) | ❌ Wave 0 (`fixtures/base_only/`) |
| PRESET-02 | `base` + `riverpod` → plugin 3줄, plugin 폴더 1 | integration | 같은 명령 → `base_riverpod` 통과 (exit 2 · 21줄) | ❌ Wave 0 |
| PRESET-03 | `base` + `codegen` → 생성 파일 규칙 진단 0줄, `invalid_annotation_target` 0줄, exit 0 | integration | 같은 명령 → `base_codegen` 통과 (exit 0 · 13줄) | ❌ Wave 0 |
| PRESET-04 | 옛 주소 → 분리 전후 정답지 불변 | integration + git | `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt && fvm dart run tool/verify.dart` → exit 0 | ✅ (`example/`) |
| PRESET-05 | `riverpod_lint: ^3.1.9` | static | `grep -c 'riverpod_lint: \^3.1.9' lib/riverpod.yaml` = 1; `grep -c 'version: \^3.1.9' fixtures/overrides/analysis_options.yaml` = 1; 정답지 다섯 불변 | ❌ C4 |
| PRESET-06 | 루트 분석이 제외 없이 경고 없음 | integration | `grep -c 'lib/analysis_options.yaml' analysis_options.yaml` = 0 && `fvm dart analyze` (루트) → `No issues found!`, exit 0 | ❌ C2 |
| PRESET-07 | 규칙 하나 · plugin 진단 하나를 끄면 그 진단만 사라짐 (세 층) | integration | 같은 명령 → `overrides (끄는 설정)` 통과, 정답지 = § 권고 11 의 18줄 (대조 줄 4줄 포함) | ❌ Wave 0 (`fixtures/overrides/`) |
| PRESET-08 | `recommended.yaml` = 옛 주소 | integration | 같은 명령 → `recommended (묶음)` 통과 (example 의 같은 실행 결과와 줄 · 종료 코드 동일) | ❌ Wave 0 |
| VERIFY-05 | 대조군에서 Riverpod / codegen 설정이 적용되지 않음 | integration | PRESET-01 과 같은 fixture · 같은 명령 | ❌ Wave 0 |
| (가장 먼저 할 일) | 세 입력에서 `--update` 가 정답지를 쓰지 않음 | integration (지워 보기) | 입력 A · B · C 를 넣고 `fvm dart run tool/verify.dart --update` → exit 1, `[2/N] 실패`, `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt` 통과. 되돌린다 | ❌ C1 (README M15 ~ M17) |
| (D-09) | runner 에서 여섯이 시간 제한 안에 통과 | e2e (GitHub) | push 뒤 `gh run list --workflow verify --limit 1` → `completed success`, job 시간 < 10분 | ✅ workflow 존재 |

### Sampling Rate
- **Per task commit:** `fvm dart run tool/verify.dart` (약 20초) + 루트 `fvm dart analyze` (커밋 전 린터, 0.6초)
- **Per wave merge:** 같은 명령 + § 권고 9 의 그 커밋의 단언(`git diff --quiet …`, Pattern 1 의 이어 붙이기)
- **Phase gate:** 로컬 exit 0 · `점검 통과 (9개 중 9개)`, 정답지 다섯 가운데 `example/` 은 `19ae5ec` 그대로, GitHub 에서 성공한 run 1회 이상 (D-09), `example/README.md` 의 M15 ~ M19, `/gsd-verify-work` 전에 "가장 먼저 할 일" 의 세 입력이 모두 exit 1 로 재현됨

### Wave 0 Gaps
- [ ] `tool/verify.dart` — `[2/N]` 판정 (C1), 규칙 검사 대상 셋 · `stripPlugins` (C2), fixture 표 · 단계 9개 · `[3/9]` · `해당 없음` · `--update` 일괄 (C3)
- [ ] `lib/{base,codegen,riverpod,recommended}.yaml`, 별칭 (C2)
- [ ] 루트 `analysis_options.yaml` (C2 · C3)
- [ ] `fixtures/{recommended,base_only,overrides,base_riverpod,base_codegen}/` 전체 + 정답지 넷 (C3)
- [ ] `.gitignore` 의 `!fixtures/*/pubspec.lock` (C3)
- [ ] `example/README.md` 의 30행 · 81행 · 단계 9개 · fixture 표 · M15 ~ M19 (C1 · C3)
- [ ] `CHANGELOG.md` 2.0.0 의 `### 그 밖의 변경` (C2 · C4)
- [ ] Framework install: 없음

## Security Domain

`security_enforcement: true`, ASVS level 1 `[VERIFIED: local .planning/config.json]`. 실행 코드는 로컬 스크립트와 CI workflow 뿐이고 사용자 입력 · 인증 · 저장 데이터가 없다. Phase 2 의 분석이 그대로 적용되고, 이 phase 가 더하는 면은 아래 둘이다.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | yes (CI 권한) | `permissions: contents: read` 그대로 (workflow 불변) |
| V5 Input Validation | yes (스크립트 입력) | 입력은 저장소 파일과 `--update` 뿐. `[2/N]` 이 깨진 옵션 파일(exit 3 + 0건)과 옵션 경고를 실패로 친다 — 이 phase 가 **넓히는** 검증. `[3/9]` 가 옵션 파일 여섯의 내용을 고정한다 |
| V6 Cryptography | no | md5 를 손으로 구현하지 않는다 (전용 상태 폴더) |
| V14 Configuration | yes | `.fvmrc` 단일 원천, lock 여섯 커밋, `~/.dartServer` 미캐시, `riverpod_lint` 는 범위 지정(D-01) — pub.dev 의 새 버전이 곧바로 들어온다는 점을 화면의 `plugin` 줄로 드러낸다 |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---|---|---|
| plugin(`riverpod_lint`)이 분석 시점에 pub.dev 에서 받아져 실행됨 — fixture 넷이 각각 받는다 | Tampering / Elevation | 1.3.0 부터 있던 것. 버전은 화면에, 강도 변화는 정답지 diff 에. 범위 지정은 D-01 의 소유자 결정 |
| 망가진 배포 파일이 정답지로 굳음 | Tampering (저장소 오염) | C1 의 `[2/N]` + D-05 안전장치 (세 입력 모두 scratch 에서 재현) |
| `.planning/` 공개로 인한 정보 노출 | Information Disclosure | D-08 로 수용. 이 문서와 정답지 · README 에 로컬 절대 경로를 적지 않는다 (scratch 경로는 폴더 이름까지만) |
| 서드파티 action 공급망 | Tampering | workflow 불변 (checkout@v7, flutter-action@v2 major tag) |
| CI 멈춤 | Denial of Service | `timeout-minutes: 10`, `concurrency.cancel-in-progress` (불변) |

## Sources

### Primary (HIGH confidence)
- `.planning/spikes/MANIFEST.md` (009 ~ 019 의 판정과 요구 사항), `.claude/skills/spike-findings-woody-lints/SKILL.md` 와 references 10편 (이 문서가 직접 인용한 것: preset-split-structure.md, fixtures-after-split.md, suppression-and-exclude.md, rule-status-check.md, ci-workflow.md, analyze-run-and-verdict.md, example-project-and-expected-file.md), `sources/012-plugin-suppression-matrix/probe.dart` (`samples`), `sources/014-multi-fixture-plugin-cost/probe.dart` (`Fx`, `overrides`)
- 이 세션의 scratch 실측 (세션 scratchpad 아래 `p3-A6MZBw/` — `git archive HEAD` 사본; `broken_inputs.sh`, `split_probe.sh`): 세 입력 × (`--update`, 보통 실행, 규칙 검사 직접 실행), 나눈 구조의 여섯 fixture 정답지, 조각 셋 규칙 검사, 루트 분석 둘, 지금 스크립트의 exit 70, `.gitignore` 부정 패턴, 한 파일 복사본의 새 조건 통과
- `tool/verify.dart` (`40776b5`, 1099행 — 35 · 38 · 595 · 622 · 648 · 751 · 794 · 1022 ~ 1034 · 1041 ~ 1046 · 1066 ~ 1078행), `lib/analysis_options.yaml` (`90a2736`, 64행), 루트 `analysis_options.yaml`, `.gitignore`, `.github/workflows/verify.yml`, `example/{analysis_options.yaml,pubspec.yaml,expected_diagnostics.txt,README.md}`, `example/lib/*.dart`, `pubspec.yaml`, `CHANGELOG.md`, `VERSIONING.md`, `.fvmrc`, `.planning/config.json`
- `.planning/phases/03-preset-split/03-CONTEXT.md`, `.planning/phases/02-verification-harness/02-VERIFICATION.md` (§ "다음 phase 가 알아야 할 것" 1 ~ 7, 사람 확인 9), `02-RESEARCH.md` (형식), `02-CONTEXT.md` (D-04 · D-05 · D-07 · D-13 · D-14), `.planning/ROADMAP.md` (§ Phase 3, § 모든 phase 에 걸친 제약), `REQUIREMENTS.md`, `STATE.md`
- `git log --oneline -1 -- <경로>` (기준 커밋 표), `git ls-remote --heads origin`, `gh run list --limit 3` (2026-10-12)

### Secondary (MEDIUM confidence)
- `.planning/research/ARCHITECTURE.md` § D (재정의 방법 — 012 가 실측으로 확정), § E, Pattern 1 · 2 · 4, Anti-Pattern 1 ~ 3; `.planning/research/PITFALLS.md` Pitfall 6 · 8 ~ 12 — 설계 배경 (spike 로 대체된 부분은 § State of the Art)
- CONTEXT 가 참고한 외부 문서 (D-01 · D-08 의 근거): https://dart.googlesource.com/sdk/+show/stable/pkg/analysis_server_plugin/doc/using_plugins.md, https://dart.dev/tools/analysis, https://dart.dev/tools/diagnostics/plugins_in_inner_options, https://github.com/dart-lang/sdk/issues/61481 — 이 세션은 다시 조회하지 않았다

### Tertiary (LOW confidence)
- 없음

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 새 패키지 없음. 버전은 전부 이 머신에서 오늘 확인
- Architecture: HIGH — include · plugin 로드 · 루트 분석 · 규칙 검사 · 상태 폴더는 spike 009 ~ 019, 정답지 전문 · 세 입력 · 조각 셋 규칙 검사 · 부정 패턴은 이 세션의 실측. 여섯으로 늘린 실제 `tool/verify.dart` 를 통째로 돌린 것은 아직 없다 (각 단계는 따로 실측됨)
- Pitfalls: HIGH — 모두 실측에서 나온 것
- CI: HIGH (017 · 018 의 실제 runner 실행) / 실제 스크립트의 job 시간은 미측정 (A2)

**Research date:** 2026-10-12
**Valid until:** SDK(Flutter 3.47.5 / Dart 3.13.4) 또는 `riverpod_lint` 3.1.9 가 바뀌기 전까지. plugin 쪽 `analyzer` (14.5.0) 가 pub.dev 에서 바뀌면 생성 파일 제외의 plugin 칸(§ spike 012 가 거는 조건)을 다시 본다. `ubuntu-latest` 가 26.04 로 옮겨 간 뒤(2026-10-19 ~ 11-19)의 CI 는 018 의 이미지 버전과 견준다
