---
spike: 004
idea: verify-harness-tool-behavior
name: fixture-pub-get
type: standard
validates: "Given Flutter 프로젝트인 연습용 프로젝트, when `flutter pub get` 과 `dart pub get` 을 각각 돌리면, then `analysis_options.yaml` 이 바뀌는지와 `dart pub get` 이 되는지가 확정된다"
verdict: VALIDATED
related: [001, 006]
tags: [pub-get, flutter-tool, analysis-options, lockfile]
---

# Spike 004: 연습용 프로젝트에서의 `pub get`

## What This Validates

Given `flutter: sdk: flutter` 에 의존하고 옵션 파일이 include 한 줄뿐인 연습용 프로젝트,
when `flutter pub get` 과 `dart pub get` 을 각각 새 복사본에서 돌리면,
then (1) `analysis_options.yaml` 이 바뀌는지, (2) `dart pub get` 이 Flutter 프로젝트에서 되는지, (3) 두 명령의 결과가 같은지가 확정된다.

FEATURES.md 가 "`flutter pub get` 이 옵션 파일에 `build/**` exclude 를 추가했다"고 실측했고, `dart pub get` 은 순수 Dart 패키지로만 확인된 상태였다 (STACK.md 미검증 항목).

## Research

Flutter 3.47.5 도구의 소스(`packages/flutter_tools/lib/src/migrations/analysis_options_migration.dart`)를 읽었다.

- `AnalysisOptionsMigration` 이 `FlutterProject.ensureReadyForPlatformSpecificTooling` 에서 실행된다. `flutter pub get` 이 이 함수를 거친다.
- `flutter` 에 의존하는 프로젝트이고 `analysis_options.yaml` 이 있으면, `build/**` 와 **존재하는 플랫폼 폴더**(`android/**`, `ios/**`, `web/**`, `windows/**`, `macos/**`, `linux/**`)가 `analyzer.exclude` 에 있는지 본다.
- 이미 있는지를 볼 때 `include:` 를 따라간다 (상대 경로와 `package:` URI 모두). 어디에도 없으면 프로젝트의 옵션 파일에 덧붙이고 "Upgrading analysis_options.yaml to exclude build and platform directories." 를 찍는다.
- 끄는 옵션은 소스에 없다.

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| `example/` 에서 `dart pub get` 을 쓴다 | `dart pub get` | 옵션 파일을 건드리지 않는다. `dart` 하나로 끝난다 | Flutter 프로젝트에서 되는지 미확인이었다 | **채택 (됨)** |
| `build/**` 를 `example/analysis_options.yaml` 에 미리 적는다 | — | `flutter pub get` 을 써도 안 바뀐다 | 옵션 파일이 "include 한 줄"이 아니게 된다. 사용 프로젝트의 모습과 달라진다 | 대안 |
| 배포 프리셋이 `build/**` 를 제외한다 | `lib/` 수정 | 사용 프로젝트의 파일도 안 바뀐다 | 이 phase 는 `lib/` 를 바꾸지 않는다 | Phase 3·4 에서 검토 |

**Chosen approach:** `dart pub get`.

## How to Run

```bash
# 저장소 안의 파일은 바꾸지 않는다. template/ 을 작업 폴더에 경우마다 새로 복사해 쓴다.
bash .planning/spikes/004-fixture-pub-get/probe.sh /tmp/spike004-work
```

## What to Expect

경우 A~H 마다 `exit`, "analysis_options.yaml: 그대로 / 바뀜"(바뀌면 diff), 생긴 파일을 찍는다.

## Investigation Trail

### 결과 (Flutter 3.47.5 / Dart 3.13.4, `results/probe.log`)

| 경우 | 명령 | 옵션 파일 |
|---|---|---|
| A | `dart pub get` (Flutter SDK 의 `bin/dart`) | **그대로** |
| B | `flutter pub get` | **바뀜** — 맨 위에 `analyzer: exclude: - build/**` 가 들어간다 |
| B2 | `flutter pub get` 을 한 번 더 | 더 바꾸지 않음 |
| C | `build/**` 를 미리 적어 둔 뒤 `flutter pub get` | 그대로 |
| D | `android/` 폴더가 있는 프로젝트에서 `flutter pub get` | 바뀜 — `build/**` 와 `android/**` |
| E | `FLUTTER_ROOT` 없이 `bin/cache/dart-sdk/bin/dart pub get` | 그대로 (정상 동작) |
| G | `dart pub get --enforce-lockfile` | 그대로, `pubspec.lock` 도 그대로 |
| H | include 한 파일이 `build/**` 를 이미 제외 | 그대로 |

B 가 만든 파일 전문:

```yaml
analyzer:
  exclude:
    - build/**
include: package:woody_lints/analysis_options.yaml
```

F. `dart pub get` 과 `flutter pub get` 의 결과 비교: `.dart_tool/package_config.json` 의 패키지 35개가 같고 `pubspec.lock` 도 글자 하나 다르지 않았다. `flutter pub get` 만 `.dart_tool/version` 을 하나 더 만든다. 분석에 쓰이는 것은 `package_config.json` 이므로 차이가 없다.

### 읽는 법

1. **`dart pub get` 은 Flutter 프로젝트에서 된다.** `flutter` SDK 의존성을 스스로 찾는다. `FLUTTER_ROOT` 환경변수가 없어도, Flutter SDK 안의 `dart-sdk/bin/dart` 를 직접 불러도 됐다 (E). `tool/verify.dart` 가 `Platform.resolvedExecutable` 로 `pub get` 을 불러도 된다는 뜻이다.
2. **`flutter pub get` 은 옵션 파일을 고친다.** 한 번만 고치고 그 뒤로는 그대로다. 고친 내용(`build/**` 제외)은 `example/` 의 분석 결과를 바꾸지 않지만, CI 에서 작업 트리가 바뀌고 로컬에서는 커밋하지 않은 변경이 생긴다.
3. `--enforce-lockfile` 이 Flutter 프로젝트에서 동작한다 (G). `example/pubspec.lock` 을 커밋하기로 했으므로(D-05) 검증 명령과 CI 는 이 플래그로 "lock 에 적힌 버전 그대로"를 강제할 수 있다. lock 과 `pubspec.yaml` 이 어긋나면 종료 코드 65 로 실패하고 lock 은 바뀌지 않는다 (`flutter_riverpod` 제약을 lock 과 다른 버전으로 바꿔 확인: "Unable to satisfy `pubspec.yaml` using `pubspec.lock`.").
4. 사용 프로젝트에도 같은 일이 생긴다 (D). 플랫폼 폴더가 있는 실제 앱에서 `flutter pub get` 을 돌리면 `build/**`, `android/**`, `ios/**` 등이 그 프로젝트의 옵션 파일에 덧붙는다. Flutter 3.47 의 동작이며 이 패키지의 문제는 아니다. 프리셋이 이들을 제외해 두면 덧붙지 않는다 (H) — Phase 4 의 규칙·설정 재선정에서 검토할 거리다.

## Results

**Verdict: VALIDATED**

- `example/` 에서는 **`dart pub get`** 을 쓴다. 옵션 파일을 건드리지 않고, Flutter 프로젝트에서도 되고, 결과는 `flutter pub get` 과 같다.
- CI 와 검증 명령은 `dart pub get --enforce-lockfile` 을 쓸 수 있다.
- `example/` 에서 `flutter pub get` 을 실수로 돌리면 옵션 파일 맨 위에 세 줄이 생긴다. 검증 명령이 "`example/analysis_options.yaml` 이 include 한 줄인가"를 함께 보면 이 실수와 "include 줄을 지운 변경"(VERIFY-08)을 같은 자리에서 잡을 수 있다.

Phase 4 로 넘길 것: 프리셋에 `build/**` (그리고 플랫폼 폴더) 제외를 넣을지. 넣으면 사용 프로젝트의 `flutter pub get` 이 옵션 파일을 고치지 않는다.

원본: `results/probe.log`.
