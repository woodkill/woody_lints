---
spike: 009
idea: preset-split-include-behavior
name: preset-plugin-via-include
type: standard
validates: "Given 저장소의 배포 파일을 조각 셋(base / riverpod / codegen)으로 잘라 둔 복사본, when 연습용 프로젝트가 조각을 골라 include 해 분석하면, then riverpod.yaml 의 plugins: 가 로드되고 조합 넷이 한 파일로 둔 같은 내용과 같은 진단을 낸다"
verdict: VALIDATED
related: [001, 003, 007, 010, 011]
tags: [include, analyzer-plugin, preset, list-include]
---

# Spike 009: 조각 파일의 plugin 이 include 로 들어오는가

## What This Validates

ROADMAP.md Phase 3 "Spike first" 의 첫 항목 (a) 다. 조사는 scratch 패키지에서만 확인했다 (`research/SUMMARY.md` § Gaps to Address).

- **Given** 저장소의 배포 파일(`lib/analysis_options.yaml`)을 `base.yaml` / `riverpod.yaml` / `codegen.yaml` 로 잘라 둔 복사본
- **When** 연습용 프로젝트가 조각을 골라 include 해 `dart analyze` 를 돌리면
- **Then** 이름이 `analysis_options.yaml` 이 아닌 `riverpod.yaml` 의 `plugins:` 가 로드되고, 조합 넷(기본만 / 기본 + Riverpod / 기본 + codegen / 전부)이 한 파일에 둔 같은 내용과 같은 진단을 낸다

통과하지 못하면 phase 를 멈추고 소유자에게 돌아간다 (03-CONTEXT.md). **통과했다.**

## Research

- 문서: dart.dev/tools/analysis 는 `include:` 에 목록을 줄 수 있고 목록 순서대로 병합한다고 적는다. dart.dev/tools/analyzer-plugins 는 plugin 을 "패키지 루트의 `analysis_options.yaml`" 에서 켠다고만 적는다 — include 한 파일의 `plugins:` 가 로드된다고 직접 말한 문장은 없다 (`research/ARCHITECTURE.md` § A · B 가 원문을 옮겨 두었다).
- 소스 (`analyzer` 14.5.0, pub cache): `analysis_options_include_walker.dart` 의 `_walk` 가 include 를 재귀로 따라가며 파일마다 같은 병합을 적용한다. plugin 설정은 context root 의 옵션 파일을 include 까지 병합한 결과에서 읽는다 (`driver.dart` 의 `pluginsOptions`, ARCHITECTURE.md § B).
- 이 저장소에서 이미 확인된 것: include 로 받은 `plugins:` 선언을 사용 프로젝트가 같은 이름으로 다시 선언해 덮어쓸 수 있다 (spike 003). 그때 `plugins:` 는 `analysis_options.yaml` 이름의 파일에 있었다.

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 조각 셋 + 목록 include (ARCHITECTURE.md § C 의 1안) | `include:` 목록, 최상위 `plugins:` | 조합이 자유롭고 plugin 버전이 한 곳에 있다 | include 경유 plugin 로드가 문서에 직접 적혀 있지 않다 | **확정안 — 이번에 잼** |
| 조각이 서로를 include (2안) | 같음 | 사용 프로젝트가 한 줄만 쓴다 | 조합 수만큼 파일이 는다 | 쓰지 않음 (ROADMAP Notes) |
| plugin 을 패키지에서 빼고 README 로 안내 (3안) | 사용 프로젝트의 `plugins:` | 문서가 말하는 자리 그대로다 | 옛 주소의 뜻이 바뀐다 | 이 spike 가 실패했을 때의 대안. 필요 없어졌다 |

**Chosen approach:** 조각을 손으로 쓰지 않고 저장소의 배포 파일을 **잘라서** 만든다 (`replica.dart` 의 `Shipped` — 이으면 원본과 같은지 확인한다). 조합마다 "같은 내용을 한 파일에 그대로 둔 모양" 을 대조 기준으로 따로 돌려, 조각으로 받은 결과와 한 줄씩 견준다.

## How to Run

```bash
# 저장소의 파일은 읽기만 한다. <작업 폴더>/replica 에 복사해 실험한다 (약 2분 30초, 네트워크 필요).
fvm dart run .planning/spikes/009-preset-plugin-via-include/probe.dart /tmp/spike009-work
```

`replica.dart` 는 spike 009 ~ 014 가 함께 쓰는 조각이다 (복사본 만들기, 배포 파일 자르기, 분석 한 번 돌리기, 견주기).

## What to Expect

실행마다 `exit`, 걸린 시간, 진단 수, plugin 준비 폴더 수와 풀린 버전을 한 줄로 찍고 그 아래에 진단을 정답지 형식으로 늘어놓는다. 끝의 `# 판정` 이 23건 모두 `✓` 이면 통과다. 하나라도 `✗` 이면 스크립트의 종료 코드가 1 이다.

## Investigation Trail

모두 Dart 3.13.4, `riverpod_lint` 3.1.9 (선언 `^3.1.3`), macOS arm64, 2026-10-12. 실행마다 빈 상태 폴더를 줬다.

### 1. 대조 기준 — 나누지 않은 한 파일, 연습용 프로젝트는 옛 주소 한 줄

| id | 한 파일에 둔 내용 | exit | 진단 | plugin 폴더 | 시간 |
|---|---|---|---|---|---|
| U-base | 규칙만 | 2 | 18줄 | 0 | 3.4초 |
| U-base+riverpod | 규칙 + `plugins:` | 2 | 21줄 | 1 | 15.3초 |
| U-base+codegen | 규칙 + `analyzer:` | 0 | 13줄 | 0 | 3.1초 |
| U-all | 원본 그대로 | 2 | 16줄 | 1 | 15.3초 |

- U-all 이 저장소의 정답지(`exit 2` + 16줄)와 한 줄도 다르지 않았다. 복사본이 저장소를 재현한다.
- 네 결과가 정답지에서 셈한 예상과 같았다 — 예상은 "정답지 − `riverpod_lint` 3줄(Riverpod 을 받지 않을 때) + 생성 파일 4줄과 `invalid_annotation_target` 1줄(codegen 을 받지 않을 때)" 이다. 더하는 줄은 Phase 2 의 지워 보기 M3 ~ M5 에서 나온 것이다.

### 2. 조각 셋으로 나눈 모양 — 연습용 프로젝트가 조각을 골라 include

| id | include 한 것 | exit | 진단 | `riverpod_lint` | plugin 폴더 | 한 파일 기준과 |
|---|---|---|---|---|---|---|
| S-base | `base.yaml` | 2 | 18줄 | 0줄 | 0 | 같음 |
| S-base+riverpod | `base.yaml` + `riverpod.yaml` | 2 | 21줄 | **3줄** | **1** | 같음 |
| S-base+codegen | `base.yaml` + `codegen.yaml` | 0 | 13줄 | 0줄 | 0 | 같음 |
| S-all | 셋 다 | 2 | 16줄 | **3줄** | **1** | 같음. 저장소의 정답지와도 같음 |

- **`riverpod.yaml` 의 `plugins:` 가 include 경유로 로드된다.** 서버가 만든 plugin 패키지의 `pubspec.yaml` 에 `riverpod_lint: ^3.1.3` 이 그대로 적혔고 3.1.9 로 풀렸다. stderr 는 비어 있었다.
- Riverpod 조각을 받지 않은 두 조합은 plugin 을 **준비조차 하지 않았다** (빈 상태 폴더에 `.plugin_manager` 가 생기지 않음). "plugin 은 딸려 오지 않는다" 가 진단 0줄보다 강하게 확인됐다.
- codegen 조각을 받지 않은 두 조합에는 생성 파일 샘플의 4줄과 `lib/should_not_appear.dart:5  warning  invalid_annotation_target` 이 나왔다. D-02 가 예상한 그대로다.

### 3. 가장자리

| id | 무엇 | 결과 |
|---|---|---|
| S-all-warm | S-all 을 같은 상태 폴더로 한 번 더 | 같은 16줄, 3.5초 |
| S-order | include 순서를 뒤집음 (`codegen` → `riverpod` → `base`) | 같은 16줄 |
| S-list-of-one | `base.yaml` 하나를 목록 문법(`- …`)으로 | 한 줄 문법과 같은 18줄 |
| S-riverpod-only | `riverpod.yaml` 만 (기본 조각 없이) | plugin 3줄 + `invalid_annotation_target` 1줄, plugin 폴더 1 |
| S-none | 옵션 파일이 비어 있음 | `invalid_annotation_target` 1줄뿐, plugin 폴더 0 |

- 조각끼리 겹치는 키가 없으므로 순서는 결과를 바꾸지 않는다. README 가 순서를 강제할 이유가 없다.
- `riverpod.yaml` 은 기본 조각 없이도 혼자 동작한다. 조각이 서로 기대지 않는다는 설계(ROADMAP Notes)가 실행으로 성립한다.
- `invalid_annotation_target` 은 아무것도 include 하지 않아도 warning 으로 나온다 — analyzer 의 기본 동작이다.

## Results

**Verdict: VALIDATED** — 23건 모두 성립했다. 멈춤 조건에 해당하지 않는다.

1. 이름이 `analysis_options.yaml` 이 아닌 파일(`lib/riverpod.yaml`)의 최상위 `plugins:` 는 이 저장소의 구조에서 include 경유로 로드된다.
2. 조각 조합 넷은 같은 내용을 한 파일에 둔 것과 진단 · 종료 코드가 같다. 나누는 것만으로는 아무것도 달라지지 않는다.
3. 조각 셋을 모두 받은 결과는 지금의 정답지와 한 줄도 다르지 않다.

Phase 3 의 계획이 가져갈 것 — 연습용 프로젝트별 정답지의 모양 (D-03 의 3 · 5 · 6번).

| 연습용 프로젝트 | 맨 위 줄 | 줄 수 | 지금의 정답지에서 달라지는 것 |
|---|---|---|---|
| 기본만 (`base.yaml`) | `exit 2` | 18 | `riverpod_lint` 3줄이 빠지고, 생성 파일 4줄 + `invalid_annotation_target` 1줄이 더해진다 |
| 기본 + Riverpod | `exit 2` | 21 | 생성 파일 4줄 + `invalid_annotation_target` 1줄이 더해진다 |
| 기본 + codegen | **`exit 0`** | 13 | `riverpod_lint` 3줄이 빠진다 |

- **"기본만" 의 맨 위 줄은 `exit 0` 이 아니라 `exit 2` 다.** 규칙 진단은 전부 info 지만 `invalid_annotation_target` 이 warning 이라서다. 종료 코드가 0 인 것은 "기본 + codegen" 하나뿐이다.
- 시간: plugin 을 쓰는 조합은 처음 실행 15.2 ~ 15.7초, 재실행 3.5초. 쓰지 않는 조합은 3.1 ~ 4.3초.
- `replica.dart` 의 `Shipped` (배포 파일을 세 조각으로 자르고 이어 붙여 원본과 같은지 확인) 는 실제로 파일을 나눌 때 "옮기기만 했다" 를 확인하는 방법으로 쓸 수 있다.

확인하지 않은 것:

- 묶음과 옛 주소를 거친 3단 include (spike 010).
- 이 구조에서의 저장소 루트 분석 (spike 011).
- GitHub Linux runner 에서의 같은 실행. include 병합은 운영체제와 무관한 코드다.
- git 의존성으로 받았을 때. 여기서는 `path:` 의존성이다 (Phase 6 의 smoke test).

원본: `results/probe.log`, `results/probe.json`.
