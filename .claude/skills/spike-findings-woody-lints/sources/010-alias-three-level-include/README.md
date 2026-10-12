---
spike: 010
idea: preset-split-include-behavior
name: alias-three-level-include
type: standard
validates: "Given 옛 주소 파일이 묶음(recommended.yaml)을 부르고 묶음이 조각 셋을 부르는 3단 구조, when example 의 샘플을 옛 주소로 또 묶음 주소로 분석하면, then 둘 다 plugin 이 로드되고 지금의 정답지(exit 2 + 16줄)와 한 줄도 다르지 않다"
verdict: VALIDATED
related: [009, 011, 003]
tags: [include, analyzer-plugin, alias, depth]
---

# Spike 010: 옛 주소 → 묶음 → 조각의 3단 include

## What This Validates

ROADMAP.md Phase 3 "Spike first" 의 둘째 항목이다. 조사의 실측은 2단까지였다.

- **Given** `lib/analysis_options.yaml` 이 `recommended.yaml` 을 부르는 한 줄이고, `recommended.yaml` 이 `base.yaml` · `riverpod.yaml` · `codegen.yaml` 을 목록으로 부르는 복사본
- **When** `example/` 의 샘플을 옛 주소 한 줄로, 또 묶음 주소 한 줄로 분석하면
- **Then** 둘 다 `riverpod_lint` plugin 이 로드되고 지금의 정답지(`exit 2` + 16줄)와 한 줄도 다르지 않다

로드되지 않으면 옛 주소를 쓰는 프로젝트가 plugin 을 소리 없이 잃는다. 통과하지 못하면 phase 를 멈춘다. **통과했다.**

## Research

- 소스 (`analyzer` 14.5.0, pub cache 의 `analysis_options_include_walker.dart`): `_walk` → `_walkInclude` → `_walkParsedInclude` → `_walk` 로 재귀하고, 멈추는 조건은 "처음 파일로 돌아왔다"(`recursive_include_file`)와 "이미 지나온 파일이다"(`included_file_warning`) 둘뿐이다. 깊이를 세는 코드는 없다. Dart 3.13.4 에 든 analyzer 는 이보다 앞선 14.1.0-dev 이므로 (PITFALLS.md Pitfall 8) 읽은 것을 실행으로 확인했다.
- 문서: dart.dev/tools/analysis 는 "첫 include 파일을 그것이 재귀로 include 하는 파일까지 포함해 평가한다" 고 적는다. include 한 파일의 주소는 `package:` 와 상대 경로 둘 다 된다.
- 선례: `lints` 의 `recommended.yaml` 이 `package:lints/core.yaml` 을, `flutter_lints` 가 `package:lints/recommended.yaml` 을 부른다 — 이 저장소의 옛 구조도 이미 3단이다 (`analysis_options.yaml` → `flutter_lints` → `lints` → `lints/core`). 다만 그 사슬에는 `plugins:` 가 없다.

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 묶음과 별칭이 `package:woody_lints/…` 로 부른다 | `include:` | `lints` · `very_good_analysis` 와 같은 방식 | 저장소 자신을 분석할 때는 패키지 설정이 있어야 풀린다 (spike 011 에서 본다) | **잼 — 통과** |
| 묶음과 별칭이 상대 경로(`recommended.yaml`)로 부른다 | `include:` | 패키지 설정 없이도 풀린다 | 선례가 적다 | **잼 — 통과** |
| 별칭이 조각 셋을 직접 부른다 (묶음을 거치지 않음) | `include:` 목록 | 2단이라 조사의 실측 범위 안 | 같은 목록이 두 파일에 있어 어긋날 수 있다 | 쓰지 않음 (PROJECT.md Key Decisions) |

**Chosen approach:** `lib/` 를 Phase 3 이 만들 모양 그대로 두고 저장소의 정답지와 직접 견준다. 주소 방식 둘, 깊이, 같은 파일에 두 길로 닿는 경우, 하한 상향, 그리고 "plugin 이 사라지면 드러나는가" 를 보는 대조 둘을 더했다.

## How to Run

```bash
# 저장소의 파일은 읽기만 한다 (약 2분 30초, 네트워크 필요).
fvm dart run .planning/spikes/010-alias-three-level-include/probe.dart /tmp/spike010-work
```

## What to Expect

경우마다 `exit`, 시간, 진단 수, plugin 준비 폴더 수, 풀린 버전과 서버가 받은 선언을 한 줄로 찍는다. 끝의 `# 판정` 이 23건 모두 `✓` 이면 통과다.

## Investigation Trail

모두 Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64, 2026-10-12. 실행마다 빈 상태 폴더를 줬다 (재실행 한 건만 예외).

### 1. 3단과 2단, 주소 방식 둘

| id | 연습용 프로젝트의 옵션 | 묶음 · 별칭의 주소 | 단 | exit | 진단 | plugin 폴더 | 정답지와 |
|---|---|---|---|---|---|---|---|
| A-alias | 옛 주소 한 줄 | `package:` | 3 | 2 | 16줄 | 1 | **같음** |
| A-bundle | 묶음 주소 한 줄 | `package:` | 2 | 2 | 16줄 | 1 | **같음** |
| A-alias-warm | 옛 주소 (재실행) | `package:` | 3 | 2 | 16줄 | 1 | 같음, 3.5초 |
| R-alias | 옛 주소 한 줄 | 상대 경로 | 3 | 2 | 16줄 | 1 | 같음 |
| R-bundle | 묶음 주소 한 줄 | 상대 경로 | 2 | 2 | 16줄 | 1 | 같음 |
| M-alias | 옛 주소 한 줄 | 별칭만 상대 경로 | 3 | 2 | 16줄 | 1 | 같음 |

- **3단에서 plugin 이 로드된다.** 서버가 만든 plugin 패키지의 `pubspec.yaml` 에 `riverpod.yaml` 의 선언(`^3.1.3`)이 세 단계를 거쳐 그대로 적혔다.
- 옛 주소와 묶음 주소의 결과가 같다 — 성공 기준 1 의 "같은 진단" 이 성립한다.
- 주소 방식(`package:` / 상대 경로 / 섞어 쓰기)은 사용 프로젝트 쪽 결과를 바꾸지 않는다. 처음 실행은 14.9 ~ 15.1초로 단 수와 무관하다.

### 2. 깊이와 겹침

| id | 무엇 | 결과 |
|---|---|---|
| D-six | 별칭 앞에 징검다리 파일 셋 (`hop1` → `hop2` → `hop3` → 별칭 → 묶음 → 조각, 6단) | 정답지와 같음, plugin 폴더 1 |
| P-twice | 옛 주소 + `riverpod.yaml` + `base.yaml` 을 한 목록에 (같은 조각에 두 길로 닿음) | 정답지와 같음. 진단이 두 번 나오지 않는다 |

깊이 제한은 없었다 (소스에서 읽은 대로). 조각으로 옮겨 가는 도중에 옛 주소와 조각을 함께 적어도 겹치지 않는다.

### 3. plugin 하한 상향 (PRESET-05)

| id | `riverpod.yaml` 의 선언 | 서버가 받은 선언 | 풀린 버전 | 진단 |
|---|---|---|---|---|
| A-alias | `^3.1.3` | `^3.1.3` | 3.1.9 | 16줄 |
| B-bump | `^3.1.9` | `^3.1.9` | 3.1.9 | **같은 16줄** |

03-CONTEXT.md D-01 의 "하한 상향 커밋에서 정답지는 바뀌지 않을 것으로 예상한다" 가 실행으로 확인됐다. 선언이 바뀌면 서버는 plugin 을 다시 준비한다 (15.8초).

### 4. 대조 — 사슬이 끊기면 드러나는가

| id | 바꾼 것 | exit | 진단 | plugin 폴더 |
|---|---|---|---|---|
| N-no-riverpod | 묶음에서 `riverpod.yaml` 을 뺌 | **0** | 13줄 (`riverpod_lint` 3줄이 빠짐) | 0 |
| N-missing | 별칭이 없는 파일(`no_such_bundle.yaml`)을 부름 | 2 | 2줄 | 0 |

N-missing 의 2줄:

```text
analysis_options.yaml:1  warning  include_file_not_found
lib/should_not_appear.dart:5  warning  invalid_annotation_target
```

- **옛 주소는 묶음이 부르는 것을 그대로 따른다.** 묶음에서 조각을 빼면 옛 주소를 쓰는 프로젝트에서도 빠진다. 정답지 비교가 이것을 잡는다 (3줄이 빠지고 종료 코드가 2 → 0).
- **별칭의 include 가 깨지면 조용히 통과하지 않는다.** 사용 프로젝트의 옵션 파일 1행에 `include_file_not_found` (warning)가 붙고 메시지에 깨진 파일의 경로가 적힌다. 규칙 진단 13줄은 전부 사라진다 — 별칭 아래가 통째로 적용되지 않는다.

## Results

**Verdict: VALIDATED** — 23건 모두 성립했다. 멈춤 조건에 해당하지 않는다.

1. 옛 주소 → 묶음 → 조각의 3단 include 에서 `riverpod_lint` plugin 이 로드된다. 6단까지 늘려도 같다.
2. 옛 주소 한 줄과 묶음 주소 한 줄은 지금의 정답지와 한 줄도 다르지 않은 같은 결과를 낸다.
3. 묶음과 별칭이 `package:` 주소로 부르든 상대 경로로 부르든 사용 프로젝트의 결과는 같다.
4. `riverpod_lint` 선언을 `^3.1.9` 로 올려도 정답지는 바뀌지 않는다 (2026-10-12 에 풀리는 버전이 3.1.9 인 동안).

Phase 3 의 계획이 가져갈 것:

- 별칭은 `include: package:woody_lints/recommended.yaml` 한 줄, 묶음은 조각 셋의 목록이면 된다. 주소 방식은 사용 프로젝트에서는 차이가 없으므로 저장소 루트 분석(spike 011)의 결과로 고른다.
- D-03 의 2번(묶음 주소) 연습용 프로젝트가 1번(`example/`)의 정답지와 견주는 구성은 성립한다 — 두 결과가 줄 단위로 같다.
- 하한 상향 커밋(PRESET-05)에서 정답지를 고칠 일은 없다. 화면의 plugin 줄도 3.1.9 그대로다. 서버가 받은 선언이 `^3.1.9` 로 바뀐 것은 전용 상태 폴더의 `.plugin_manager/*/pubspec.yaml` 에서 볼 수 있다.
- 옛 주소를 쓰는 연습용 프로젝트를 남겨 두면 (ROADMAP Notes) 묶음에서 조각이 빠지는 실수와 별칭이 깨지는 실수를 둘 다 잡는다. 앞의 것은 정답지의 3줄과 `exit` 줄로, 뒤의 것은 `analysis_options.yaml:1  warning  include_file_not_found` 줄로 드러난다.

확인하지 않은 것:

- git 의존성으로 받았을 때의 3단 include. 여기서는 `path:` 의존성이다 (Phase 6 의 smoke test).
- `riverpod_lint` 3.1.9 보다 새 버전이 나온 뒤의 하한 상향. `^3.1.3` 과 `^3.1.9` 가 같은 버전으로 풀리는 동안의 결과다.
- 순환 include (`recursive_include_file`). 이 구조에는 생기지 않는다.

원본: `results/probe.log`, `results/probe.json`.
