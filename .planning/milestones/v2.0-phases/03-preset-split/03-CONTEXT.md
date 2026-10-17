# Phase 3: Preset Split - Context

**Gathered:** 2026-10-12
**Status:** Ready for planning

<domain>
## Phase Boundary

지금 한 파일(`lib/analysis_options.yaml`)에 들어 있는 설정을 조각 셋(`base.yaml` / `riverpod.yaml` / `codegen.yaml`)과 묶음(`recommended.yaml`)으로 나누고, 옛 URI 는 묶음을 include 하는 한 줄짜리 별칭으로 남긴다. 나누는 것은 구조 변경이다 — 옛 URI 를 쓰는 `example/` 의 정답지(`example/expected_diagnostics.txt`)가 한 줄도 바뀌지 않아야 한다. 이 phase 가 끝나면 다음이 참이다.

1. 옛 URI 한 줄만 쓰는 `example/` 의 정답지가 분리 전후로 같고, `package:woody_lints/recommended.yaml` 을 include 해도 같은 진단이 나온다 (PRESET-04, PRESET-08)
2. `base.yaml` 만 include 한 대조군에서 기본 규칙 진단은 나오고, `riverpod_lint` 진단은 나오지 않으며, codegen 설정이 적용되지 않는다 (PRESET-01, VERIFY-05)
3. `riverpod.yaml` 을 include 한 구성에서 `riverpod_lint` 진단이 나오고 plugin 하한이 `^3.1.9` 이며, `codegen.yaml` 을 include 한 구성에서 생성 파일의 진단이 나오지 않는다 (PRESET-02, PRESET-03, PRESET-05)
4. 루트 `analysis_options.yaml` 에서 배포 파일 exclude 를 걷어낸 상태로 루트 분석이 경고 없이 통과한다 (PRESET-06)
5. 규칙 하나를 끄는 설정과 plugin 진단 하나를 끄는 설정이 각각 그 진단만 사라지게 함이 fixture 로 확인되어 있다 (PRESET-07)

이 phase 가 하지 않는 것: 규칙을 넣거나 빼는 일, 중복 선언 6개와 주석 처리된 설정 3개의 정리, 사유 주석 고치기(Phase 4 의 RULES-01 · 02 · 07), README 재작성과 배포 YAML 머리 주석 정리(Phase 5), tag 와 `main` 병합(Phase 6). `main` 은 건드리지 않는다.

</domain>

<decisions>
## Implementation Decisions

### 이전에 확정되어 그대로 따르는 것

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

### plugin 버전 (ROADMAP 의 D6 확정)

- **D-01:** `lib/riverpod.yaml` 의 선언은 **`riverpod_lint: ^3.1.9`** (범위 지정)이다. 정확한 버전으로 고정하지 않는다. PRESET-05 와 성공 기준 3 의 문구는 그대로다.
  - 이유: 정확 고정은 `riverpod_lint` 가 나올 때마다 이 패키지를 다시 릴리스해야 받게 만들고(최근 넉 달에 다섯 번 — 3.1.4 6월 10일, 3.1.6 ~ 3.1.8 7월 26 ~ 28일, 3.1.9 9월 3일), 그래도 plugin 의 전이 의존성은 떠다닌다. 몇 달씩 손대지 않는 저장소에서는 못박은 버전이 낡아 plugin 이 빠지는 쪽이 더 위험하다고 보았다
  - 소유자에게 밝힌 대가: 사용 프로젝트가 tag 로 이 패키지를 고정해도 plugin 새 버전이 나온 날부터 경고가 달라질 수 있고, 저장소 변경 없이 정답지가 깨질 수 있다. 점검 화면의 `plugin` 줄이 원인을 보여 준다 (02-CONTEXT.md D-07)
  - "못박은 옛 버전이 새 SDK 와 맞지 않으면 plugin 진단이 통째로 사라질 수 있다" 는 공식 문서(SDK 가 `analysis_server_plugin` 버전을 스스로 정하고 릴리스마다 바뀔 수 있다)에서 나온 **추정**이고 실측이 아니다. 소유자에게 그렇게 밝혔다
  - 따라 나오는 사실: 지금 선언 `^3.1.3` 도 3.1.9 로 풀리고 있다 (pub.dev 최신이 3.1.9, 2026-10-12 조회). 하한 상향 커밋에서 정답지는 바뀌지 않을 것으로 예상한다. 3.1.9 는 Dart 3.13.0 이상을 요구하고 `pubspec.yaml` 의 `sdk: ^3.13.0` 과 맞는다
  - 고르지 않은 안: 정확 고정 `3.1.9`

### annotation 경고 무시 설정 (ROADMAP 의 D7 확정)

- **D-02:** `invalid_annotation_target: ignore` 는 **`lib/codegen.yaml` 로 옮긴다.** 지우지 않는다. `codegen.yaml` 은 이 `analyzer.errors` 한 줄과 `analyzer.exclude` 의 두 패턴(`**/*.freezed.dart`, `**/*.g.dart`)을 담는다.
  - 이유: 옛 URI 와 묶음이 받는 구성이 그대로이고(PRESET-04) 정답지가 바뀌지 않는다. 나눈 뒤에는 이 설정이 코드 생성을 쓰는 프로젝트만 받는 조각에 들어가므로, freezed 공식 문서가 json_serializable 과 함께 쓸 때 권하는 경우와 자리가 맞는다
  - 따라 나오는 사실: `codegen.yaml` 을 받지 않는 구성(기본만, 기본 + Riverpod)에서는 `lib/should_not_appear.dart:5  warning  invalid_annotation_target` 이 나와야 한다 (Phase 2 의 지워 보기 M3 실측)
  - 지우는 것은 내용 변경이라 이 phase 에서 하지 않는다. 옮긴 뒤에도 나중에 지울 수 있고 그때의 등급은 minor 다
  - 고르지 않은 안: 지금 지우기 (정답지에 warning 한 줄이 생기고 PRESET-04 문구를 고쳐야 한다) / 옮기되 지울지를 Phase 4 실측에서 다시 보기

### 연습용 프로젝트(fixture) 구성

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

### 조사 범위와 spike 결과의 처리

- **D-07:** spike 넷째 항목(plugin 이 `analyzer.exclude` 와 `// ignore_for_file` 을 존중하는지)은 결과가 어느 쪽이든 **기록하고 계속 진행한다.** 02-CONTEXT.md D-15 의 기준(값이나 세부만 달라지는 결과는 기록하고 진행)을 그대로 쓴다. 앞의 세 가지는 ROADMAP 대로 하나라도 실패하면 멈춘다.
  - 논의 끝의 요약에서 Claude 가 이렇게 잡았다고 밝혔고 소유자가 반대하지 않았다. 명시적으로 고른 선택지는 아니다
- **D-08:** ROADMAP 이 "이 phase 에서 정한다" 고 남긴 조사 둘 — pub workspace 멤버 패키지에서의 plugin 로드, plugin 내부 `riverpod` 버전과 사용 프로젝트 `riverpod` major 가 다를 때의 동작 — 은 **하지 않는다.**
  - 이유: 해당하는 사용 프로젝트가 없다. 2026-10-12 에 읽기 전용으로 확인한 결과 `flutter_starter_kit` 은 workspace 가 아니고 `flutter_riverpod` 3.3.1 이며, 학습용 4개(`webtoon`, `toonflix`, `pomodoro`, `state`)는 workspace 가 아니고 Riverpod 과 코드 생성을 쓰지 않는다. `~/dv` 아래(깊이 4)에 workspace 프로젝트는 없었다
  - workspace 는 공식 문서에 답이 있다 — plugin 은 workspace 의 루트나 workspace 에 속하지 않은 패키지의 루트에서만 지정할 수 있다
  - 따라 나오는 점: Phase 5 의 README 는 돌려 본 범위(Riverpod 3.x, workspace 가 아닌 프로젝트)만 단정형으로 적는다. workspace 는 공식 문서 문장을 출처와 함께 옮기고 "이 패키지로는 돌려 보지 않았다" 고 적는다
  - 고르지 않은 안: workspace 만 spike 에 넣기 / 둘 다 넣기

### GitHub 에 올리기

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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 범위와 요구사항

- `.planning/ROADMAP.md` § "Phase 3: Preset Split" — goal, success criteria 5개, Spike first 4개, decision points D6 · D7, Notes (가장 먼저 할 일 포함)
- `.planning/ROADMAP.md` § "모든 phase 에 걸친 제약" — `main` 은 1.3.0 유지, 구조 변경과 내용 변경을 섞지 않음, 확인되지 않은 도구 동작은 먼저 실행, 원격 작업은 소유자 확인
- `.planning/REQUIREMENTS.md` — PRESET-01 ~ PRESET-08, VERIFY-05. 이 phase 가 아닌 것: RULES-01 · 02 · 07 (Phase 4), DOCS-02 · 03 · 10 (Phase 5)
- `.planning/PROJECT.md` § Constraints, § Key Decisions — 옛 URI 는 공개 API, 묶음의 정식 이름 `recommended.yaml`, 조각 이름 `base.yaml`, milestone 브랜치 전략, `--update` 경로를 Phase 3 에서 먼저 닫는다는 결정

### 프리셋 구조의 근거

- `.planning/research/SUMMARY.md` § "Phase 3: 프리셋 분리", § "계획 전에 프로젝트 소유자가 결정할 것" 의 D6 · D7, § "문서 사이에 어긋나는 지점" 2번 · 13번, § "Gaps to Address" — scratch 실측으로 해소된 항목 표(이 저장소에서의 재현은 남아 있다)와 Phase 3 항목
- `.planning/research/ARCHITECTURE.md` § "A. 프리셋 파일 배치와 include 병합 규칙", § "B. include 된 파일 안의 최상위 `plugins:`", § "C. Riverpod opt-in 설계안" (1 안이 확정안, 3 안은 spike 실패 시의 대안이고 URI 결정을 바꾼다), § "D. 사용 프로젝트의 재정의 방법" (D-04 의 표가 여기서 나왔다)
- `.planning/research/ARCHITECTURE.md` § "Pattern 1", § "Pattern 2", § "Pattern 4: 대조군 fixture", § "Anti-Pattern 1" (조각이 서로를 include), § "Anti-Pattern 2" (`plugins:` 를 `analysis_options.yaml` 이름의 패키지 파일에 두기), § "Anti-Pattern 3" (workspace 멤버). **주의:** § "Recommended Project Structure" 의 fixture 2개 구성은 D-03 으로 대체되었다 (여섯)
- `.planning/research/PITFALLS.md` § "Pitfall 8" (`plugins_in_inner_options` 의 실제 조건 — 파일 이름과 initial file), § "Pitfall 9" (include 병합 규칙), § "Pitfall 10" (기존 URI 의 의미 변경), § "Pitfall 11" (plugin 버전 범위와 SDK), § "Pitfall 6" (exclude / ignore 의 위치)

### 검증 명령과 정답지

- `.claude/skills/spike-findings-woody-lints/SKILL.md` 와 `references/` 4편 — `dart analyze` 실행 형태, 전용 상태 폴더, plugin 준비 실패 판정, plugin 폴더가 패키지 루트 경로마다 생긴다는 점, 규칙 검사의 복사본 방식, 루트 exclude. `tool/verify.dart` · `example/` · 루트 `analysis_options.yaml` 을 고치기 전에 읽는다
- `.planning/phases/02-verification-harness/02-CONTEXT.md` § D-04 (정답지 형식), § D-05 (`example/pubspec.lock`), § D-07 (버전 줄), § D-09 (push 확인 방식 — D-09 가 그대로 따른다), § D-13 · D-14 (화면과 `--update`), § D-15 (spike 결과 처리 기준 — D-07 이 그대로 쓴다)
- `.planning/phases/02-verification-harness/02-VERIFICATION.md` § "다음 phase 가 알아야 할 것" 1 ~ 6, § "Human Verification Required" 9번 — "가장 먼저 할 일" 의 재현과 근거, `[2/4]` 가 include 뒤의 파일을 보지 못하는 경우(`c12`), 별칭으로 바꾸면 exit 70 이 나는 경우(`c13`), 대조군의 `plugin` 줄(`c09`)
- `example/README.md` — 단계 설명(81행), `--update` 안전장치(30행), 지워 보기 기록 M1 ~ M14. M3 ~ M5 가 D-02 와 D-03 의 "나와야 하는 줄" 의 근거다

### 버전 · 기록 정책

- `VERSIONING.md` § "기준표" — 새 프리셋 파일 추가 · plugin 하한 상향 · exclude / errors 변경 = minor. § "CHANGELOG 항목 형식"
- `.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md` § D-12 ~ D-15 (CHANGELOG 형식, 2.0.0 항목에 적어 나가기), § D-19 · D-20 (원격 작업의 확인 형식)

### 논의에서 참고한 외부 문서

- https://dart.googlesource.com/sdk/+show/stable/pkg/analysis_server_plugin/doc/using_plugins.md — plugin 버전은 분석 서버가 `dart pub upgrade` 로 푼다. SDK 가 `analysis_server_plugin` 버전을 정하며 릴리스마다 바뀔 수 있다 (D-01)
- https://pub.dev/packages/riverpod_lint — 3.x 출시 간격과 최신 버전, 3.1.9 의 SDK 요구 (D-01. 2026-10-12 에 pub.dev API 로 조회)
- https://pub.dev/documentation/freezed/latest/ — json_serializable 과 함께 쓸 때 `invalid_annotation_target` 을 끄라는 안내 (D-02)
- https://dart.dev/tools/analysis — `include:` 목록, 병합 순서, 규칙을 끄는 맵 문법 (D-03, D-04)
- https://dart.dev/tools/diagnostics/plugins_in_inner_options — plugin 을 지정할 수 있는 자리 (D-03, D-08)
- https://github.com/dart-lang/sdk/issues/61481 — 안쪽 옵션 파일의 plugin 설정은 받아들여지지만 아무 일도 하지 않는다는 설명 (D-08. 이슈가 닫혔는지는 확인하지 않았다)

### 고치거나 새로 만드는 파일

- `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml` — 새로 만든다
- `lib/analysis_options.yaml` — `recommended.yaml` 을 include 하는 한 줄짜리 별칭으로 바꾼다
- 루트 `analysis_options.yaml` — `lib/analysis_options.yaml` exclude 를 걷어낸다
- `tool/verify.dart` — `--update` 경로 닫기, fixture 여섯, `[2/4]` 의 대상 넓히기
- fixture 다섯 개와 그 정답지 — 새로 만든다 (자리와 이름은 계획에 맡김)
- `example/README.md`, `CHANGELOG.md`, `.gitignore`, `.github/workflows/verify.yml` — 필요한 만큼 고친다
- `example/` 의 샘플 소스와 `example/expected_diagnostics.txt`, `pubspec.yaml` 의 `version` 과 `dependencies`, `main` — **바꾸지 않는다**

</canonical_refs>

<code_context>
## Existing Code Insights

### 논의 시점의 저장소 상태 (2026-10-12 확인)

- `lib/` 에는 `analysis_options.yaml` 하나뿐이다 (64행). 13행 `include`, 20 ~ 40행 `linter.rules` (규칙 12개 + 주석 처리된 2개), 15 ~ 16행 주석 처리된 `formatter:`, 42 ~ 47행 `analyzer.errors` / `analyzer.exclude`, 49 ~ 58행 `plugins: riverpod_lint: ^3.1.3` 과 그 설명 주석, 1 ~ 12행 · 60 ~ 64행 템플릿 영어 주석
- 루트 `analysis_options.yaml` 은 `flutter_lints` 를 include 하고 `lib/analysis_options.yaml` 과 `example/**` 를 exclude 한다
- `example/analysis_options.yaml` 은 `include: package:woody_lints/analysis_options.yaml` 한 줄이다. 정답지는 `exit 2` + 16줄이다 (이 패키지 규칙 12줄, 기반 세트만 켜는 `prefer_is_empty` 1줄, `riverpod_lint` 3줄 — `missing_provider_scope` warning, `provider_parameters` warning, `avoid_public_notifier_properties` info)
- `example/lib/should_not_appear.dart` (annotation 샘플), `example/lib/generated/sample.g.dart` · `sample.freezed.dart` (생성 파일 샘플)가 이미 있다. 지금은 정답지에 줄이 없다
- `tool/verify.dart` 35행 `const fixtures = ['example'];`, 38행 `const shippedOptionsPath = 'lib/analysis_options.yaml';`, 595행 `stripPlugins` — `plugins:` 섹션을 찾지 못하면 `FormatException` 을 던진다 (별칭으로 바꾸면 exit 70)
- origin 의 작업 브랜치는 `ead9573` 이고 로컬이 커밋 4개 앞선다. `main` 은 `90a2736`, tag 는 `v1.3.0` 하나다
- `.github/workflows/verify.yml` 의 `timeout-minutes` 는 10 이다. 지금 job 은 약 2분이다

### Reusable Assets

- `example/` 의 샘플 소스 — 대조군이 "같은 소스를 다른 옵션 파일로" 분석하는 재료다 (`research/ARCHITECTURE.md` Pattern 4). `added_rules.dart`, `base_rules.dart`, `riverpod_rules.dart`, `main.dart`, `should_not_appear.dart`, `generated/`
- `tool/verify.dart` 의 fixture 반복 구조 (`fixtures` 목록을 도는 1012행 · 1025행), 정답지 읽기 · 쓰기, 건수까지 견주는 비교(`subtractLines`), 규칙 수 세기(`countDeclaredRules`)
- `example/README.md` 의 지워 보기 기록 형식 (M 번호 표) — 새 fixture 가 헛통과가 아님을 보이는 기록을 같은 형식으로 더할 수 있다
- `spike-findings-woody-lints` skill 의 `sources/` — 옮겨 쓸 수 있는 조각 (`stripPlugins`, `readPluginVersion`, `pluginFolders`)

### Established Patterns

- 검증 명령은 준비(SDK 확인 → CI 의 `--update` 거부 → 루트 pub get → fixture pub get) 뒤 단계를 모두 돌리고 화면을 한 번에 찍는다. 종료 코드는 0 / 1 / 64 / 69 / 70 / 78 이다
- `dart pub get` 은 늘 `--no-example` 과 `--enforce-lockfile` 로 돌린다. fixture 에서 `flutter pub get` 은 쓰지 않는다
- 규칙 검사는 배포 파일을 `plugins:` 를 뺀 채 `build/woody_rule_check/analysis_options.yaml` 로 복사하고 그 폴더를 인자로 분석한다. 복사본은 저장소 안에 둔다
- 실측으로 확인한 동작은 버전과 날짜를 함께 적는다. 추정은 추정이라고 적는다
- 소유자에게 하는 확인 요청과 화면 문구는 쉬운 말로 쓴다

### Integration Points

- **Phase 4:** 규칙을 바꾸는 곳이 `base.yaml` 이 되고, 규칙 결정마다 정답지 다섯 개가 함께 바뀐다. D-05 의 `--update` 가 그 기록을 만든다. D-02 로 옮긴 `invalid_annotation_target: ignore` 는 지울지 다시 볼 수 있다 (minor)
- **Phase 5:** README 의 조합별 include 블록(DOCS-02)은 D-03 의 여섯에서, 끄는 방법(DOCS-03)은 D-04 의 표에서 나온다. 호환 범위는 D-08 대로 돌려 본 범위만 단정형으로 적는다. README ↔ YAML 비교 검사(VERIFY-06)의 대상 파일이 `base.yaml` 로 바뀐다
- **Phase 6:** 릴리스 뒤 smoke test(REL-04)는 git 의존성으로 받은 프리셋의 `plugins:` 가 도는지를 본다 — `path:` 로만 확인한 것의 마지막 확인이다. 루트 `pubspec.yaml` 의 `version` 을 올리면 fixture 의 lock 이 모두 어긋난다 (`02-VERIFICATION.md` 7번 — fixture 가 여섯이면 여섯 곳이다)

</code_context>

<specifics>
## Specific Ideas

### 소유자가 고른 `--update` 화면 미리보기 (구성을 그대로 따른다)

파일 이름, 단계 수, 바뀐 줄은 예시다. 실제로는 `base.yaml` 의 규칙 하나를 바꾸면 그 규칙을 받는 fixture 가 모두 바뀐다.

```text
$ fvm dart run tool/verify.dart --update

SDK        Flutter 3.47.5 / Dart 3.13.4
기반 세트  flutter_lints 6.0.0 / lints 6.1.0
plugin     riverpod_lint 3.1.9

[1/9] lib/ 에 .dart 파일 없음 ...... 통과
[2/9] 배포 파일의 규칙 이름 ....... 통과
[3/9] 연습용 프로젝트 옵션 파일 .. 통과
[4/9] example (옛 주소) ........... 바뀐 줄 없음
[5/9] recommended (묶음) .......... 바뀐 줄 없음
[6/9] base_only (기본만) .......... 갱신
  - lib/added_rules.dart:24  info  prefer_final_locals
[7/9] base_riverpod ............... 갱신
  - lib/added_rules.dart:24  info  prefer_final_locals
[8/9] base_codegen ................ 바뀐 줄 없음
[9/9] overrides (끄는 설정) ....... 바뀐 줄 없음

정답지를 썼다 (2개):
  .../base_only/expected_diagnostics.txt
  .../base_riverpod/expected_diagnostics.txt
```

### 네 경우의 표 (D-03)

| | codegen 받음 | codegen 안 받음 |
|---|---|---|
| **Riverpod 받음** | 1 (옛 URI) · 2 (묶음) | 5 (기본 + Riverpod) |
| **Riverpod 안 받음** | 6 (기본 + codegen) | 3 (기본만) |

### 소유자와 소통하는 방식

- 이번 논의에서 통한 쉬운 말: fixture 는 "연습용 프로젝트", golden 은 "정답지", 대조군은 "안 나온다를 증명하려고 두는 짝", caret 은 "범위 지정", pin 은 "정확 고정 · 못박기", annotation 은 "코드 위에 붙이는 꼬리표", workspace 는 "패키지 여러 개를 한 저장소에 묶어 관리하는 프로젝트", push 는 "GitHub 에 올린다", CI 는 "GitHub 자동 점검"
- 결정을 요청할 때는 용어 풀이, 찾아본 것(출처와 함께), 비교표, `권고:` 한 줄을 차례로 보인다. 소유자는 이번 논의의 선택 8건 모두에서 권고안을 골랐다
- 추정한 숫자(자동 점검 시간)는 추정이라고 적어 보였다. 실제로 잰 값이 나오면 그 값으로 다시 알린다
- D-09 의 첫 push 확인 요청에는 올릴 것의 목록, 명령, 되돌릴 수 없다는 점을 다시 보여 준다

</specifics>

<deferred>
## Deferred Ideas

논의 중에 나왔지만 이 phase 의 일이 아닌 것.

- **`invalid_annotation_target: ignore` 를 지울지** — 이번에는 `codegen.yaml` 로 옮긴다 (D-02). `flutter_starter_kit` 복사본에서 "이 설정을 풀면 경고가 몇 건 나오나" 를 재어 다시 정하는 안은 고르지 않았다. 다시 보고 싶으면 Phase 4 의 실측에 더할 수 있다
- **workspace 와 Riverpod major 차이 조사** — 하지 않기로 했다 (D-08). 그런 사용 프로젝트가 실제로 생기면 그때 잰다
- **README 의 호환 범위 문구** — 돌려 본 범위만 단정형으로 적고 workspace 는 공식 문서를 출처와 함께 옮긴다 (D-08). Phase 5 의 일이다
- **학습용 프로젝트 4개는 "기본만" 받으면 되는 프로젝트다** — Riverpod 과 코드 생성을 쓰지 않는데 지금은 묶음을 받는다 (2026-10-12 확인). 사용 프로젝트에 새 버전을 적용하는 일은 이번 작업의 범위 밖이다 (REQUIREMENTS.md Out of Scope). Phase 5 의 README 가 "어느 조합을 고를까" 를 설명할 때 예로 쓸 수 있다
- **`flutter_starter_kit` 의 `pubspec.yaml` 에 `riverpod_lint: ^3.1.3` 이 `dev_dependencies` 로 따로 적혀 있다** (2026-10-12 확인) — plugin 은 옵션 파일의 `plugins:` 로 로드되므로 이 줄이 필요한지, README 의 설치 안내가 이 줄을 어떻게 다룰지는 Phase 5 에서 본다
- **plugin 새 버전 때문에 정답지가 저절로 깨졌을 때의 절차** — D-01 로 생기는 일이다. 화면의 `plugin` 줄로 원인은 보이지만 "그때 무엇을 하나" 를 적어 둔 곳은 없다. `example/README.md` 나 Phase 6 의 릴리스 절차 문서에서 검토한다
- **`VERSIONING.md` 의 남은 어긋남 (Phase 1 리뷰 WR-03)** — "새 프리셋 파일 추가" 가 기준표에서는 minor 인데 판정 순서의 문장에는 드러나 있지 않다. 2.0.0 의 등급(major)에는 영향이 없어 이 phase 에서 다루지 않는다. D-05(01-CONTEXT.md)를 건드리는 소유자 결정이 필요하다
- **`--update=이름` 으로 하나만 갱신하기** — 두지 않기로 했다 (D-05). 정답지가 더 늘어 한 번에 보기 어려워지면 다시 검토한다

</deferred>

---

*Phase: 3-Preset Split*
*Context gathered: 2026-10-12*
