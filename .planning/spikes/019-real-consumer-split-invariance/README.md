---
spike: 019
idea: preset-split-include-behavior
name: real-consumer-split-invariance
type: standard
validates: "Given 실제 사용 프로젝트(`flutter_starter_kit`)의 복사본이 지금 받는 그대로(git, 1.3.0) · 한 파일 구조 · 나눈 구조(옛 주소) · 나눈 구조(묶음 주소)를 받을 때, when 각각 프로젝트 폴더에서 `dart analyze` 를 돌리면, then 네 실행의 진단이 줄 단위로 같다"
verdict: VALIDATED
related: [009, 010, 012, 015, 016]
tags: [real-consumer, include, analyzer-plugin, exclude, generated-files]
---

# Spike 019: 실제 사용 프로젝트에서의 나누기 전후

## What This Validates

spike 001 ~ 018 은 모두 이 저장소 안에 만든 작은 연습용 프로젝트로 쟀다 (지금의 `example/` 은 샘플 파일 일곱 개다). 이 패키지를 실제로 쓰는 프로젝트에 나눈 구조를 물려 본 적은 없다. 실제 프로젝트는 자기 옵션 파일에 제외 목록과 `linter:` 블록을 따로 갖고 있고, 진짜 생성기의 산출물이 수십 개 있다.

- **Given** `flutter_starter_kit` 의 복사본이 ① 지금 받는 그대로(git 의존성, lock 의 커밋 = 1.3.0) ② 한 파일 구조를 옆 폴더에서 ③ 나눈 구조를 옛 주소로 ④ 나눈 구조를 묶음 주소로 받을 때
- **When** 각각 프로젝트 폴더에서 `dart analyze` 를 돌리면
- **Then** 네 실행의 진단이 줄 단위로 같다

②와 ③이 다르면 009 ~ 011 과 같은 급의 멈춤 조건이다 (03-CONTEXT.md — "나누는 것은 구조 변경이다"). 함께 기록하는 것(진짜 생성 파일에서의 제외, `dev_dependencies` 의 `riverpod_lint` 줄, 다음 SDK)은 결과가 어느 쪽이든 기록하고 계속한다.

## Research

**사용 프로젝트에 관해 읽은 것** (2026-10-12, 원본을 읽기만 했다. 수와 설정값만 적는다 — 아래 "적지 않는 것" 참조).

- Dart 파일: `lib` 에 손으로 쓴 것 172개와 생성 파일 62개(`*.g.dart` 55, `*.freezed.dart` 7), `test` 233개, `bin` 1개.
- SDK 제약 `^3.11.1`, Flutter 3.47.5 고정. `woody_lints` 는 git 의존성 `ref: main` 이고 lock 의 커밋은 `90a2736` (= `v1.3.0`)이다.
- 옵션 파일: 옛 주소 한 줄(`include: package:woody_lints/analysis_options.yaml`) + 자기 `analyzer.exclude` (생성 파일 두 줄 `"**/*.g.dart"` · `"**/*.freezed.dart"` 와 플랫폼 폴더들) + 주석뿐인 `linter: rules:`.
- `dev_dependencies` 에 `riverpod_lint: ^3.1.3` 이 따로 적혀 있다 (lock 은 3.1.3). 015 가 재지 않고 남긴 항목이다.
- 생성 파일의 머리: `*.g.dart` 50개가 `// ignore_for_file: type=lint, type=warning` (`riverpod_generator`), 5개는 머리 없음(`json_serializable`), `*.freezed.dart` 7개가 `// ignore_for_file: type=lint`. 012 가 "다른 생성기는 확인하지 않았다" 로 남긴 것이 이것이다.

**적지 않는 것.** `flutter_starter_kit` 은 비공개 저장소이고 이 저장소의 작업 브랜치는 공개된다. 그 프로젝트의 파일 경로 · 진단 메시지 · 코드 조각은 결과 파일과 화면 기록에 남기지 않는다. 스크립트는 건수와 규칙 이름, 줄 목록의 해시(FNV-1a)만 쓰고, 줄 단위 기록은 작업 폴더의 `private/` 에만 둔다.

| 방식 | 장점 | 단점 | 채택 |
|---|---|---|---|
| 복사본 + `pubspec_overrides.yaml` 로 `woody_lints` 를 replica 의 경로로 돌린다 | 복사본의 `pubspec.yaml` 도 원본 그대로다. 구조만 바꿔 가며 같은 프로젝트를 분석한다 | `pub get` 이 복사본의 lock 을 고친다 (복사본이라 상관없다) | **채택** |
| 복사본의 `pubspec.yaml` 에서 의존성 줄을 직접 고친다 | 파일이 하나 준다 | 원본과 달라진 자리가 늘어난다 | 쓰지 않음 |
| 원본에서 직접 돌린다 | 복사가 없다 | "원본 프로젝트는 수정하지 않는다" (PROJECT.md) 에 닿는다 | 쓰지 않음 |

**Chosen approach:** 분석에 필요한 것(`pubspec.yaml` · `pubspec.lock` · 옵션 파일 · `l10n.yaml` · `lib` · `test` · `bin` · `assets`)만 복사한다. 구조는 spike 009 의 `replica.dart` 가 저장소의 배포 파일을 **잘라서** 만든다. 실행마다 빈 상태 폴더를 준다.

**표식 파일.** 이 저장소 `example/lib` 의 위반 샘플 일곱 개를 복사본의 `lib/woody_probe_marker/` 에 넣는다. 사용 프로젝트 자신의 코드가 0줄이면 "네 실행이 같다" 가 0줄 = 0줄 이 되기 때문이다. 표식 파일은 사용 프로젝트의 옵션 파일을 거쳐 분석되므로, 그 줄이 정답지 16줄과 같으면 "실제 프로젝트의 설정 위에서 규칙과 plugin 이 그대로 적용된다" 가 된다.

## How to Run

```bash
# 저장소 고정 SDK
fvm dart run .planning/spikes/019-real-consumer-split-invariance/probe.dart <작업 폴더> <사용 프로젝트 원본>

# 다른 SDK (저장소 밖을 작업 디렉터리로 둔다 — CONVENTIONS.md)
<SDK>/bin/cache/dart-sdk/bin/dart <저장소>/.planning/spikes/019-real-consumer-split-invariance/probe.dart <작업 폴더> <사용 프로젝트 원본>

# 일부만: 셋째 인자에 id 를 쉼표로
… probe.dart <작업 폴더> <사용 프로젝트 원본> P0,P1
```

- 작업 폴더는 저장소 밖에 둔다. 복사본은 `<작업 폴더>/consumer`, 줄 단위 기록은 `<작업 폴더>/private/` 다.
- 분석 열세 번에 약 5분이다 (분석만 277초).

## What to Expect

| id | `woody_lints` 를 받는 방식 | 사용 프로젝트의 옵션 파일 | 보는 것 |
|---|---|---|---|
| V0 | git 의존성, lock 그대로 (1.3.0) | 원본 그대로 | 기준 |
| V1 | replica 의 경로, 한 파일 구조 | 원본 그대로 | V0 과 같은가 |
| V2 | replica 의 경로, 나눈 구조 | 원본 그대로 (옛 주소) | **V1 과 같은가** |
| V3 | 같음 | include 를 묶음 주소로 | V2 와 같은가 |
| X1 | 같음 | include 를 `base.yaml` 로 | 대조 — 달라야 한다 |
| G2u / G2s | 한 파일 / 나눈 구조 | 직접 적은 생성 파일 제외 두 줄을 뺌 | 둘이 같은가. 진짜 생성 파일에서 몇 줄이 나오나 |
| G3 | 나눈 구조 | 제외 두 줄을 빼고 `base` + `riverpod` 만 | 대조 — 어디에도 제외가 없을 때 |
| N1u / N1s | 한 파일 / 나눈 구조 | `always_specify_types` 를 더 켬 | 실제 코드에서 줄이 나올 때도 같은가 |
| P0 / P1 | 나눈 구조 | `public_member_api_docs` 를 더 켬 (P1 은 `publish_to` 줄도 뺌) | 0줄의 까닭 |
| D | 나눈 구조 | 원본 그대로, `pubspec.yaml` 에서 `riverpod_lint` 줄을 뺌 | V2 와 같은가 |

## Investigation Trail

### 1. 첫 실행 — 네 실행이 같다. 그런데 프로젝트 자신의 줄이 0줄이다

분석 아홉 번(V0 ~ V3, X1, G2u, G2s, G3, D), 확인 17건이 모두 성립했다 (`results/probe-3.13.4-run1.*`).

- V0 ~ V3 가 모두 16줄 · `exit 2` 이고 그 16줄이 전부 표식 파일의 것이다. **사용 프로젝트 자신의 코드는 0줄이다** — 1.3.0 의 규칙 12개 · 기반 세트 · `riverpod_lint` 에 걸리는 것이 없다.
- X1 (대조)은 14줄로 달라졌다 — 표식 파일에서 plugin 3줄이 빠지고 annotation 경고 1줄이 생겼다. plugin 폴더 0개.
- 프로젝트 자신의 줄이 0줄이라 "같다" 의 근거가 표식 파일뿐이었다. 실제 코드에서 줄이 나오는 조건을 더하기로 했다.

### 2. 둘째 실행 — `public_member_api_docs` 를 켰는데 0줄

실제 코드에서 줄이 나오도록 프리셋에 주석 처리되어 있는 `public_member_api_docs` 를 사용 프로젝트의 옵션 파일에 더 켰다 (`results/probe-3.13.4-run2.*`). 한 파일 구조와 나눈 구조 모두 16줄 그대로였다 — 그 규칙의 줄이 하나도 없다. "0줄 = 0줄 의 헛통과가 아니다" 를 보려던 확인이 실패했다 (스크립트의 종료 코드 1).

- 나누기 전후의 차이는 아니다. 두 구조가 똑같이 0줄이다.
- 추정을 세웠다: 사용 프로젝트의 `pubspec.yaml` 에 `publish_to: 'none'` 이 있어 "공개 API 가 없는 패키지" 로 취급되고 규칙이 적용되지 않는다.

### 3. 셋째 실행 — 규칙을 바꾸고, 추정을 시험한다

- 줄을 내는 규칙을 `always_specify_types` 로 바꿨다. **한 파일 구조와 나눈 구조가 둘 다 9,398줄 (표식 24 + 프로젝트 9,374) 이고 줄 단위로 같다.** 프로젝트의 줄은 `lib` 1,524 · `test` 7,739 · `bin` 111 이다.
- 추정을 시험하려고 `public_member_api_docs` 를 켠 채 `publish_to` 줄을 뺀 실행(P1)을 더했다. **P1 도 0줄이었다.** 추정대로라면 줄이 나와야 했다 (`results/probe-3.13.4-run3.*`).

### 4. 일부러 넣은 위반으로 가른다 — 추정이 틀렸다

P0 · P1 에만 문서 주석이 없는 공개 선언 둘(`class UndocumentedPublicClass {}`, `void undocumentedPublicFunction() {}`)을 표식 파일로 더했다.

| 실행 | `pubspec.yaml` | `public_member_api_docs` 줄 |
|---|---|---|
| P0 | 원본 그대로 (`publish_to: 'none'`) | **2줄** — 표식 2, 프로젝트 0 |
| P1 | `publish_to` 줄을 뺌 | **2줄** — 표식 2, 프로젝트 0 |

- **규칙은 앱 프로젝트에서도 켜진다.** `publish_to: 'none'` 과 상관없다. 2번의 추정은 틀렸다.
- 프로젝트의 0줄은 진짜 0줄이다 — `lib` 의 공개 선언에 문서 주석이 빠진 곳이 없다. 표식 파일(이 저장소의 샘플)도 모두 문서 주석이 달려 있어 2 · 3번에서 0줄이었다.
- **표식 없이는 "규칙이 동작하지 않는다" 와 "코드가 깨끗하다" 를 가르지 못한다.** ROADMAP 의 Phase 4 성공 기준 2 ("일부러 넣은 위반이 보고되지 않은 회차의 수치는 쓰이지 않았다") 가 막으려는 것이 이 경우다.

### 5. 마지막 실행 (2026-10-12, Dart 3.13.4)

4번의 표식을 넣은 스크립트로 처음부터 다시 돌렸다. 분석 열세 번(합계 277초), 확인 20건이 모두 성립했다 (`results/probe-3.13.4.json` · `.log`).

| id | 줄 | 표식 | 프로젝트 | `exit` | 시간 | plugin 폴더 |
|---|---|---|---|---|---|---|
| V0 지금 받는 그대로 (git, 1.3.0) | 16 | 16 | 0 | 2 | 22.1초 | 1 |
| V1 한 파일 구조 (path) | 16 | 16 | 0 | 2 | 22.1초 | 1 |
| V2 나눈 구조, 옛 주소 | 16 | 16 | 0 | 2 | 23.7초 | 1 |
| V3 나눈 구조, 묶음 주소 | 16 | 16 | 0 | 2 | 22.1초 | 1 |
| X1 대조 — `base.yaml` 만 | 14 | 14 | 0 | 2 | 6.8초 | 0 |
| G2u 한 파일, 직접 적은 제외를 뺌 | 16 | 16 | 0 | 2 | 22.2초 | 1 |
| G2s 나눈 구조, 직접 적은 제외를 뺌 | 16 | 16 | 0 | 2 | 25.0초 | 1 |
| G3 대조 — 제외가 어디에도 없음 | 21 | 21 | 0 | 2 | 23.4초 | 1 |
| N1u 한 파일 + `always_specify_types` | 9,398 | 24 | 9,374 | 2 | 22.7초 | 1 |
| N1s 나눈 구조 + `always_specify_types` | 9,398 | 24 | 9,374 | 2 | 21.6초 | 1 |
| P0 `public_member_api_docs` | 18 | 18 | 0 | 2 | 22.3초 | 1 |
| P1 같음, `publish_to` 줄을 뺌 | 18 | 18 | 0 | 2 | 21.7초 | 1 |
| D `dev_dependencies` 의 `riverpod_lint` 줄을 뺌 | 16 | 16 | 0 | 2 | 21.5초 | 1 |

- V0 의 `pub get` 은 원본의 lock 그대로(`--enforce-lockfile`) 통했다. 복사본이 받은 자리는 V0 에서 pub cache 의 git 폴더, V1 부터 replica 였다 (`.dart_tool/package_config.json` 의 `rootUri` 로 확인).
- plugin 쪽에서 풀린 버전은 plugin 을 쓰는 열두 실행 모두 `riverpod_lint` 3.1.9 / `analyzer` 14.5.0 / `analysis_server_plugin` 0.3.24 다. 사용 프로젝트의 lock 에 적힌 `riverpod_lint` 3.1.3 과 무관하다.
- 실행마다 빈 상태 폴더를 줬으므로 시간에는 plugin 준비(약 15초)가 들어 있다. plugin 을 쓰지 않는 X1 은 6.8초다.
- 원본은 실행 전후로 `git status` 가 깨끗했다. 저장소 루트의 `.dart_tool/package_config.json` 도 그대로다 (`generatorVersion` 3.13.4).

### 6. 다음 SDK (베타) — 돌리지 못했다

같은 스크립트를 Flutter 베타 3.49.0-0.2.pre (Dart 3.14.0-211.1.beta) 로 띄웠다. **첫 `pub get` 에서 의존성 풀이가 실패해 분석까지 가지 못했다** (스크립트의 종료 코드 69).

- 까닭은 이 패키지가 아니라 사용 프로젝트의 의존성이다. 베타의 `flutter_test` 가 고정하는 `matcher` · `test_api` 버전과, 프로젝트가 적어 둔 `test` · `freezed` 의 제약이 함께 풀리지 않는다 (`pub` 은 `freezed` 를 다음 major 로 올리라고 제안했다).
- 복사본의 의존성을 고쳐 가며 돌리면 "실제 프로젝트를 쟀다" 가 아니게 되므로 여기서 멈췄다. 결과 파일은 없다.
- 표식 파일 수준의 답은 016 에 있다 — 사용 프로젝트가 옵션 파일에 직접 적은 제외는 두 SDK 에서 규칙과 plugin 을 모두 막는다.

## Results

**Verdict: VALIDATED** — 실제 사용 프로젝트의 복사본에서 지금 받는 그대로 · 한 파일 구조 · 나눈 구조(옛 주소) · 나눈 구조(묶음 주소)의 진단이 줄 단위로 같다. 멈춤 조건(V2 = V1)에 해당하지 않는다.

1. **나누는 것은 실제 프로젝트에도 보이지 않는다.** V0 = V1 = V2 = V3 (16줄, `exit 2`). 표식 파일이 사용 프로젝트의 옵션 파일(자기 제외 목록, 비어 있는 `linter: rules:`)을 거쳐 정답지 16줄을 그대로 낸다. 대조(X1)는 예상한 대로 달라졌다.
2. **실제 코드에서 줄이 나올 때도 같다.** `always_specify_types` 를 더 켠 짝이 둘 다 9,398줄이고 줄 단위로 같다 — 그중 9,374줄이 사용 프로젝트 자신의 코드(`lib` 1,524 · `test` 7,739 · `bin` 111)다. 사용 프로젝트가 맵 문법으로 더 켠 규칙이 3단 include 위에 그대로 얹힌다.
3. **옆 폴더(`path:`)로 받은 것이 git 으로 받은 것과 같다** (V1 = V0). 015 가 연습용 프로젝트에서 본 것이 실제 프로젝트에서도 성립한다. `pubspec_overrides.yaml` 로 돌리면 복사본의 `pubspec.yaml` 을 고치지 않아도 된다.
4. **사용 프로젝트 자신의 코드는 지금 0줄이다** (1.3.0 의 규칙 12개 · 기반 세트 · `riverpod_lint`). Phase 4 의 기준선이 0 이다.
5. **진짜 생성 파일 62개는 제외가 하나도 없어도 0줄이다** (G3). 57개가 머리에 `ignore_for_file: type=lint` 를 달고 있고, 머리 없는 `json_serializable` 산출물 5개도 지금의 규칙에 걸리지 않는다. 012 · 016 이 찾은 "프리셋의 제외가 통하지 않는 경우" 는 이 프로젝트에 지금 새 줄을 만들지 않는다. 직접 적은 제외를 빼도 나누기 전후가 같다 (G2s = G2u).
6. **`dev_dependencies` 의 `riverpod_lint` 줄은 진단에 영향이 없다** (D = V2). plugin 은 옵션 파일의 `plugins:` 로 받고, 어느 쪽에서도 3.1.9 로 풀렸다.
7. **`public_member_api_docs` 는 앱 프로젝트에서도 켜지고, 이 프로젝트의 `lib` 에서는 0줄이다.** 일부러 넣은 미문서 선언 둘이 2줄로 잡혔다. "`publish_to: 'none'` 이면 적용되지 않는다" 는 처음의 추정은 틀렸다.

재려던 것 밖에서 나온 것:

- `invalid_annotation_target` 은 codegen 조각을 받지 않는 G3 에서도 사용 프로젝트에 0줄이다 (표식 파일의 1줄만 나온다). 03-CONTEXT.md 가 "Phase 4 의 실측에 더할 수 있다" 로 미뤄 둔 질문("이 설정을 풀면 경고가 몇 건 나오나")의 값이다. 지울지를 정한 것은 아니다.
- `flutter_starter_kit` 은 지금의 의존성 그대로는 Flutter 베타 3.49 에서 `pub get` 이 되지 않는다 (6번). 이 패키지의 일은 아니지만 소유자가 알아야 할 것이다.

Phase 3 의 계획이 가져갈 것:

1. 구조는 그대로 간다. 성공 기준 1 ("옛 URI 한 줄만 쓰는 `example/` 의 정답지가 분리 전후로 한 줄도 바뀌지 않는다") 이 실제 사용 프로젝트에서도 성립한다는 것이 미리 확인됐다.
2. 새로 더할 것은 없다. 연습용 프로젝트 여섯의 구성(D-03)을 바꿀 까닭이 나오지 않았다.

Phase 4 가 가져갈 것 ("Spike first" 의 셋째 항목과 맞닿는다):

1. **복사본이 작업 중인 파일을 가리키게 하는 방법이 정해졌다** — 복사본에 `pubspec_overrides.yaml` (`dependency_overrides:` 의 `woody_lints:` 에 `path:`)을 두고 `dart pub get`, 받은 자리는 `.dart_tool/package_config.json` 으로 확인한다. `Consumer.copy` · `ensurePub` · `woodySource` 를 그대로 옮겨 쓸 수 있다.
2. **기준선은 0줄이다.** 후보 규칙의 값은 "기준선 대비 차이" 가 아니라 그 규칙의 줄 수 그대로가 된다 (프로젝트가 직접 적은 `// ignore` 주석에 가려진 것은 별개다 — "Spike first" 의 둘째 항목).
3. **회차마다 일부러 넣은 위반을 둔다.** 표식 파일 방식(`lib/woody_probe_marker/`)이 성공 기준 2 를 채운다. 0줄을 표식 없이 해석하지 않는다.
4. `public_member_api_docs` 는 이 프로젝트의 `lib` 에서 0줄이다 — 프리셋에 주석 처리되어 있는 그 줄을 다시 볼 때의 값이다.
5. 분석 한 번이 약 22초다 (빈 상태 폴더, plugin 준비 포함). 상태 폴더를 이어 쓰면 더 짧을 것이다 (재지 않았다).
6. 결과에 사용 프로젝트의 경로 · 메시지 · 코드 조각을 남기지 않는다. 건수와 규칙 이름만 남긴다 — spike 가 스스로 건 조건이고, Phase 4 의 근거 문서(DOCS-11)가 공개 저장소에 들어가므로 논의에서 확인한다.

Phase 5 가 가져갈 것:

1. README 의 "`dev_dependencies` 의 `riverpod_lint` 는 필요 없다" 는 실측으로 받쳐진다 (6번).
2. "생성 파일 제외는 사용 프로젝트의 옵션 파일에 직접 적는다" 는 안내는 `flutter_starter_kit` 이 이미 하고 있는 모양이다. 그 줄을 지워도 지금은 진단이 달라지지 않는다 — 다만 규칙이 늘면 머리 없는 생성 파일에서 줄이 날 수 있고, 제외는 분석 시간도 줄인다 (시간은 재지 않았다).

확인하지 않은 것:

- 다음 SDK 에서의 실제 프로젝트 (6번 — 의존성이 풀리지 않았다).
- 학습용 프로젝트 넷 (`webtoon`, `toonflix`, `pomodoro`, `state`). Riverpod 과 코드 생성을 쓰지 않는 작은 프로젝트다.
- 규칙을 더 켠 상태에서 생성 파일의 제외를 뺀 경우. `always_specify_types` 의 짝은 직접 적은 제외가 있는 채로 쟀다.
- 사용 프로젝트가 직접 적은 `// ignore` 주석이 가리고 있는 줄의 수.
- IDE 에서의 모습.
- `freezed` · `json_serializable` · `riverpod_generator` 의 다른 버전이 내는 머리.

원본: `results/probe-3.13.4.json` · `.log` (마지막 실행), `results/probe-3.13.4-run1.*` (1번), `-run2.*` (2번), `-run3.*` (3번). 결과 파일에는 사용 프로젝트의 경로와 메시지가 없다 — 건수, 규칙 이름, 줄 목록의 해시뿐이다.
