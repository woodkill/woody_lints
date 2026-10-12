---
spike: 015
idea: preset-split-include-behavior
name: git-dependency-preset-load
type: standard
validates: "Given 나눈 구조를 커밋한 로컬 git 저장소를 사용 프로젝트가 git 의존성으로 받을 때(패키지가 pub cache 에 놓인다), when 옛 주소와 묶음 주소로 분석하면, then plugin 이 로드되고 둘 다 지금의 정답지(exit 2 + 16줄)와 같으며 생성 파일 제외의 모양이 path: 때와 같다"
verdict: VALIDATED
related: [009, 010, 012]
tags: [git-dependency, pub-cache, include, analyzer-plugin, lockfile]
---

# Spike 015: 나눈 구조를 git 의존성으로 받기

## What This Validates

spike 009 ~ 014 는 모두 `path:` 의존성(옆 폴더를 직접 가리키는 방식)으로 쟀다. 실제 사용 프로젝트 5개는 전부 git 의존성으로 받고, 그때 패키지는 프로젝트 옆이 아니라 pub cache 에 놓인다. 로드맵은 이 차이를 Phase 6 의 smoke test 에서 처음 확인하게 되어 있었다 — tag 를 올린 뒤에 실패를 알면 patch 릴리스로만 고칠 수 있다. 구조를 짓기 전에 당겨서 쟀다 (010 × 012 가 맞물리는 자리, 소유자 선택 2026-10-12).

- **Given** 나눈 구조(조각 셋 + 묶음 + 옛 주소의 별칭)를 커밋한 **로컬** git 저장소와, 그것을 `git:` 의존성으로 받는 사용 프로젝트
- **When** `example/` 의 샘플을 옛 주소 한 줄로, 또 묶음 주소 한 줄로 분석하면
- **Then** `riverpod_lint` plugin 이 로드되고 둘 다 지금의 정답지(`exit 2` + 16줄)와 한 줄도 다르지 않으며, 생성 파일 제외가 규칙 / plugin 에 통하는 모양이 `path:` 때와 같다

통과하지 못하면 009 ~ 011 과 같은 급의 멈춤 조건이다 (옛 주소를 쓰는 프로젝트가 plugin 을 잃는다). **통과했다.**

## Research

- dart.dev/tools/pub/dependencies § Git packages: "The `dart pub` command calls `git clone` as a subprocess, so all you need to provide is a `<url>` that works when `git clone <url>` is executed." — 로컬 폴더 경로도 `git clone` 이 받으므로 GitHub 에 올리지 않고 잴 수 있다. `ref` 는 "anything that Git allows to identify a commit" (브랜치, tag, 커밋).
- dart.dev/tools/pub/cmd/pub-get: "If a lockfile already exists, `dart pub get` uses the versions of dependencies locked in it if possible." git 의존성의 커밋이 lock 에 어떻게 적히는지, `pub get` 과 `pub upgrade` 중 무엇이 그것을 옮기는지는 두 문서에 적혀 있지 않았다 → 실행으로 쟀다 (아래 2 · 4번).
- 같은 문서: pub cache 의 자리는 `PUB_CACHE` 환경변수로 바꾼다. git 과 pub.dev 에서 받은 패키지가 그 안에 놓인다.
- spike 012 가 남긴 추정: "패키지가 pub cache 에 놓여도 '패턴을 적은 파일의 폴더' 는 사용 프로젝트 밖이므로 같은 결과일 것이다."

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 로컬 git 저장소를 `git: url:` 로 받는다 | `git`, `dart pub get` | 아무것도 올리지 않는다. 커밋 · 브랜치 · tag 를 마음대로 만들어 lock 의 움직임까지 본다 | 받아 오는 길(https)은 재지 않는다 — 받은 뒤의 모양은 같다 | **채택** |
| 작업 브랜치를 GitHub 에 올리고 `ref:` 로 받는다 | `git push` | 실제와 가장 같다 | 나눈 구조는 아직 저장소에 없다. 올리는 것은 소유자 확인이 필요한 일이다 | 쓰지 않음 (Phase 6) |
| pub cache 의 git 폴더에 손으로 복사한다 | — | git 이 필요 없다 | pub 이 만든 모양이 아니다 | 쓰지 않음 |

**Chosen approach:** replica 를 git 저장소로 만들어 커밋 셋(A 한 파일 구조 → B 나눈 구조, 브랜치의 C)과 tag 하나를 두고, replica **밖**에 둔 사용 프로젝트가 그것을 받는다. `PUB_CACHE` 를 작업 폴더 안으로 돌려 `~/.pub-cache` 의 git 폴더를 건드리지 않는다. 같은 사용 프로젝트를 `path:` 로 받는 짝을 같은 스크립트에 두어 나란히 견준다.

## How to Run

```bash
# 저장소의 파일은 읽기만 한다 (약 2분, 네트워크 필요). GitHub 에는 아무것도 올리지 않는다.
fvm dart run .planning/spikes/015-git-dependency-preset-load/probe.dart <작업 폴더>
```

## What to Expect

`pub` 실행마다 종료 코드와 lock 의 `woody_lints` 항목(출처, `ref`, `resolved-ref`)을, 분석마다 `exit` · 시간 · 진단 수 · plugin 폴더 수를 한 줄로 찍는다. 5부의 표가 git 과 path 를 나란히 보여 주고, 끝의 `# 판정` 29건이 모두 `✓` 이면 통과다.

## Investigation Trail

모두 Dart 3.13.4, `riverpod_lint` 3.1.9 (plugin 쪽 `analyzer` 14.5.0, `analysis_server_plugin` 0.3.24), git 2.56.0, macOS arm64, 2026-10-12. 두 번 돌려 판정 29건이 두 번 모두 같았다 (`results/probe-run1.*` 이 첫 실행). 첫 실행은 tag 를 가벼운(lightweight) tag 로, 둘째 실행은 릴리스 tag 와 같은 annotated tag 로 만들었다.

### 1. 받은 패키지가 놓이는 자리

| 의존성 | `package_config.json` 의 `woody_lints` 자리 | lock 의 항목 |
|---|---|---|
| `git: {url: <replica>, ref: main}` | `<PUB_CACHE>/git/replica-<커밋 해시>/` | `source: git`, `ref: main`, `resolved-ref: <커밋 해시>` |
| `path: ../replica` | `../../replica` (프로젝트 옆) | `source: path` |

- 폴더 이름은 **저장소 이름 + 커밋 해시**다. 실제 사용 프로젝트에서는 `~/.pub-cache/git/woody_lints-<해시>/` 가 된다. 커밋마다 폴더가 따로 생긴다 (이번 실행에서 A · B · C 셋).
- `pubspec.yaml` 의 `dependencies` 에 둔 `flutter_lints` 는 git 의존성에서도 사용 프로젝트로 전달됐다 — 기반 세트의 `prefer_is_empty` 줄이 그대로 나온다.

### 2. 기준 — git 의존성 + 한 파일 구조

| id | 받은 커밋 | 옵션 | exit | 진단 | plugin 폴더 | 정답지와 |
|---|---|---|---|---|---|---|
| G-old | A (한 파일 구조) | 옛 주소 한 줄 | 2 | 16줄 | 1 | **같음** |

사용 프로젝트가 지금(1.3.0) 받고 있는 모양이다. 이 줄이 뒤의 비교의 출발점이다.

### 3. git 의존성 + 나눈 구조

| id | 옵션 | 단 | exit | 진단 | plugin 폴더 | 기대와 |
|---|---|---|---|---|---|---|
| G-alias | 옛 주소 한 줄 | 3 | 2 | 16줄 | 1 | **정답지와 같음** |
| G-bundle | 묶음 주소 한 줄 | 2 | 2 | 16줄 | 1 | **정답지와 같음** |
| G-base-riverpod | `base.yaml` + `riverpod.yaml` | 1 | 2 | 21줄 | 1 | 009 의 예상과 같음 |
| G-base-only | `base.yaml` 만 | 1 | 2 | 18줄 | 0 | 009 의 예상과 같음 |
| P-alias | (`path:` 로 받은 짝) 옛 주소 한 줄 | 3 | 2 | 16줄 | 1 | 정답지와 같음 |

- **pub cache 에 놓인 조각의 `plugins:` 가 3단 include 를 거쳐 로드된다.** 서버가 만든 plugin 패키지에 `riverpod.yaml` 의 선언(`^3.1.3`)이 그대로 적혔고 3.1.9 로 풀렸다.
- 처음 실행은 14.8 ~ 15.2초로 `path:` 때(010 의 14.9 ~ 15.1초)와 같다.

### 4. lock 은 언제 따라가는가

같은 사용 프로젝트에서 `main` 을 A → B 로 나아가게 하고 차례로 돌렸다.

| 순서 | 한 일 | 명령 | 종료 코드 | lock 의 `resolved-ref` |
|---|---|---|---|---|
| pub-1 | 처음 받는다 (`ref: main`, `main` = A) | `dart pub get` | 0 | A |
| — | 저장소의 `main` 이 B 로 나아간다 | — | — | — |
| pub-2 | 그대로 다시 받는다 | `dart pub get` | 0 | **A (그대로)** |
| pub-3 | 같은 상태에서 | `dart pub get --enforce-lockfile` | 0 | A |
| pub-4 | 올린다 | `dart pub upgrade woody_lints` | 0 | **B** |
| pub-5 | `pubspec.yaml` 의 `ref:` 를 브랜치 `no-riverpod` 로 고친 직후 | `dart pub get --enforce-lockfile` | **65** | B (그대로) |
| pub-6 | 같은 상태에서 | `dart pub get` | 0 | **C** |
| pub-7 | `ref:` 를 annotated tag `v9.9.9` (B 를 가리킨다) 로 고친 뒤 | `dart pub get` | 0 | **B** |

- **`ref: main` 을 따르는 프로젝트는 `pub get` 으로는 새 커밋을 받지 않는다.** lock 이 커밋을 못박고 있어서다. 새 버전은 `pub upgrade woody_lints` 를 해야 들어온다. `main` 에 병합한 순간 다섯 프로젝트가 곧바로 바뀌는 것이 아니라, 각 프로젝트에서 upgrade 를 하거나 lock 없이 새로 받을 때 바뀐다.
- **`ref:` 를 고친 프로젝트는 `pub get` 만으로 그 ref 의 커밋으로 옮긴다.** tag 로 고정한 프로젝트가 버전을 올리는 방법이 이것이다 (`ref: vX.Y.Z` 를 고치고 `pub get`).
- annotated tag 를 적어도 lock 의 `resolved-ref` 에는 tag 자신의 해시가 아니라 **그 tag 가 가리키는 커밋의 해시**가 적힌다 (둘째 실행: tag 는 `d111dd2…`, `resolved-ref` 는 B 인 `483fccc…`). 받은 폴더도 커밋 B 의 것 그대로다.
- `ref:` 만 고치고 lock 을 그대로 둔 채 `--enforce-lockfile` 을 돌리면 종료 코드 65 로 멈춘다 — stderr 는 ``Unable to satisfy `pubspec.yaml` using `pubspec.lock`.`` 이다. lock 을 커밋하는 프로젝트의 CI 가 이 모양으로 알려 준다.
- N-ref: `ref: no-riverpod` (묶음에서 `riverpod.yaml` 을 뺀 커밋 C)를 받으면 `exit 0` · 13줄 · plugin 폴더 0개다. 사용 프로젝트는 `ref:` 가 가리키는 커밋의 내용을 그대로 따른다 — 이 실험이 작업 폴더가 아니라 받은 커밋을 읽고 있다는 대조이기도 하다.

### 5. 생성 파일 제외 — git 과 path 를 나란히

spike 012 의 샘플(`lib/generated/riverpod_violation.g.dart` — 한 줄에 규칙 위반과 plugin 위반)을 두 사용 프로젝트에 똑같이 뒀다.

| `**/*.g.dart` 제외를 적은 곳 | git: 규칙 | git: plugin | path: 규칙 | path: plugin |
|---|---|---|---|---|
| 없음 (`base.yaml` + `riverpod.yaml`) | 나옴 | 나옴 | 나옴 | 나옴 |
| 패키지의 `codegen.yaml` (묶음으로 받음) | 안 나옴 | **나옴** | 안 나옴 | **나옴** |
| 묶음 + 사용 프로젝트의 옵션 파일에 직접 | 안 나옴 | 안 나옴 | 안 나옴 | 안 나옴 |

- 세 경우 모두 git 실행과 path 실행이 **줄 단위로 같았다** (23줄 / 17줄 / 16줄).
- 012 가 추정으로 남긴 것이 실행으로 확인됐다 — 패키지가 pub cache 에 놓여도 `codegen.yaml` 의 제외는 규칙 진단만 막고 plugin 진단은 막지 못한다. 사용 프로젝트가 자기 옵션 파일에 직접 적은 제외는 둘 다 막는다.

## Results

**Verdict: VALIDATED** — 29건 모두 성립했다. 멈춤 조건에 해당하지 않는다.

1. 나눈 구조를 git 의존성으로 받아도 `riverpod_lint` plugin 이 로드되고, 옛 주소 한 줄과 묶음 주소 한 줄이 지금의 정답지와 한 줄도 다르지 않다.
2. `path:` 로 잰 009 ~ 012 의 결과는 git 의존성에서도 그대로다 — 조합별 진단, 처음 실행 시간, 생성 파일 제외의 모양이 같다.
3. 한 파일 구조(A)에서 나눈 구조(B)로 옮겨 간 프로젝트는 옛 주소 한 줄을 그대로 둔 채 같은 16줄을 받는다 (G-old → G-alias). 성공 기준 1 의 "분리 전과 똑같은 구성" 이 실제로 받는 길에서 성립한다.

Phase 3 의 계획이 가져갈 것:

- 구조에 관해 바꿀 것은 없다. `path:` 의존성으로 만든 연습용 프로젝트 여섯의 정답지는 git 으로 받는 사용 프로젝트가 보게 될 것과 같다.
- 연습용 프로젝트를 git 의존성으로 하나 더 둘 필요는 없다 — 두 방식의 결과가 줄 단위로 같았고, git 으로 받는 길은 Phase 6 의 smoke test 가 실제 주소로 한 번 본다.

Phase 5 (README) 로 넘길 것:

- **버전 올리기 안내는 받는 방식에 따라 다르다.** tag 로 고정한 프로젝트는 `ref:` 를 고치고 `pub get`, `ref: main` 을 따르는 프로젝트는 `pub upgrade woody_lints` 다. 로드맵의 Phase 5 Notes 는 "`pub upgrade` 가 아니라 `ref:` 수정과 `pub get`" 이라고 적었는데 이것은 tag 로 고정한 쪽의 말이다 — `ref: main` 쪽은 `pub get` 으로는 아무것도 바뀌지 않는다.
- `ref: main` 에서 tag 로 옮길 때: `ref:` 를 고치고 `pub get` 이면 된다 (pub-7 과 같은 모양).
- lock 을 커밋하고 CI 에서 `--enforce-lockfile` 을 쓰는 프로젝트는 `ref:` 를 고친 뒤 `pub get` 으로 lock 을 함께 갱신해 커밋해야 한다. 아니면 종료 코드 65 다.
- 생성 파일 제외를 사용 프로젝트의 옵션 파일에도 직접 적으라는 안내(012)는 git 으로 받는 실제 사용 프로젝트에 그대로 해당한다.

Phase 6 로 넘길 것:

- smoke test 가 처음 보는 것은 이제 "받아 오는 길"(GitHub 주소, 실제 tag) 하나로 줄었다. 받은 뒤의 include · plugin 로드는 여기서 쟀다.
- `main` 병합은 `ref: main` 프로젝트에 **곧바로** 닿지 않는다. 각 프로젝트가 `pub upgrade` 를 하거나, lock 이 없는 상태에서 `pub get` 을 할 때 닿는다 (학습용 프로젝트가 lock 을 커밋하는지는 확인하지 않았다).

확인하지 않은 것:

- 받아 오는 길 자체 — `https://github.com/…` 주소, 실제 tag, 인증. 로컬 경로를 `git clone` 한 것으로 쟀다.
- lock 이 없는 새 프로젝트가 처음 받는 경우. 여기서는 `example/` 의 lock 을 복사해 두고 `woody_lints` 항목만 pub 이 다시 쓰게 했다.
- 사용 프로젝트의 `dev_dependencies` 에 `riverpod_lint` 가 따로 적힌 경우 (`flutter_starter_kit` 이 그렇다 — lock 은 3.1.3). 받는 방식과 무관한 질문이라 넣지 않았다.
- 다음 SDK 에서의 같은 실행. spike 016 이 베타(Dart 3.14.0-211.1.beta)에서 `path:` 로 쟀다.
- SDK 하한이 다른 커밋으로 옮길 때 (A 와 B 의 `pubspec.yaml` 은 같다). Dart 3.13 미만에서 받지 못하는 것은 Phase 1 이 쟀다.
- GitHub Linux runner 에서의 같은 실행.

원본: `results/probe.log`, `results/probe.json`.
