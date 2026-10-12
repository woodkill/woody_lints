---
spike: 023
idea: rule-reselection-measurement
name: existing-ignore-comments
type: standard
validates: "Given flutter_starter_kit 의 // ignore 주석이 있고, when 복사본에서 주석을 둔 채와 걷어낸 채로 지금의 프리셋과 후보 규칙(lines_longer_than_80_chars, discarded_futures, cast_nullable_to_non_nullable, unnecessary_ignore)을 분석하면, then 주석이 숨기는 줄의 수와 주석의 출처(손으로 쓴 것 / 생성기)가 규칙별로 확정된다"
verdict: VALIDATED
related: [019, 021, 022]
tags: [ignore-comments, baseline, real-consumer, unnecessary-ignore, generated-files]
---

# Spike 023: existing-ignore-comments

## What This Validates

Given `flutter_starter_kit` 에 이미 있는 `// ignore` · `// ignore_for_file` 주석이 있고, when 복사본에서 주석을 둔 채와 걷어낸 채로 지금의 프리셋과 후보 규칙을 분석하면, then 주석이 숨기는 줄의 수와 주석의 출처(손으로 쓴 것 / 생성기)가 규칙별로 갈린다.

ROADMAP.md Phase 4 "Spike first" 의 둘째 항목이다 — "`flutter_starter_kit` 에 이미 있는 `// ignore` 주석(`cast_nullable_to_non_nullable` 56건, `discarded_futures` 2건 등)의 경위와, 프로젝트 자체 옵션이 기준선에 섞이는지." 뒤 절반(프로젝트 자체 옵션은 규칙을 더 켜지 않는다)은 019 가 봤다. 남은 것은 주석이다.

## Research

- 무시 주석의 문법: `// ignore: <코드>, <코드>` (그 줄 또는 다음 줄), `// ignore_for_file: <코드>`, 그리고 `type=lint` · `type=warning` (종류 전체). plugin 진단은 `riverpod_lint/<코드>` 접두사가 있어야 한다 (012). 이 프로젝트에는 plugin 진단의 무시 주석이 없다.
- `unnecessary_ignore` (Dart 3.8, tag 3.13.4 의 `messages.yaml` 은 experimental — 020): 무시 주석이 가리키는 진단이 그 자리에 나오지 않으면 보고한다. 규칙 소스(tag 3.13.4)는 검사를 analyzer 의 `IgnoreValidator` 에 맡긴다 (021 이 읽었다). ARCHITECTURE.md 는 "plugin 진단 코드에는 동작하지 않는다" 고 적었다 — 이 프로젝트에는 plugin 무시 주석이 없어 보지 않았다.
- 생성 파일(`*.g.dart`, `*.freezed.dart`)은 사용 프로젝트가 자기 옵션 파일에서 분석에서 뺀다 (019). 그 안의 주석은 어떤 실행에도 나오지 않는다 — 세기만 했다.

| 방법 | 장점 | 단점 | 고름 |
|---|---|---|---|
| 주석을 걷어낸 복사본과 견준다 | 주석이 가린 줄이 그대로 나온다 | 걷어낸 자리의 줄 번호가 바뀌면 줄 비교가 어긋난다 → 주석 부분만 지우고 줄은 남긴다 | ✓ |
| `unnecessary_ignore` 만 켠다 | 필요 없는 주석을 바로 센다 | 필요한 주석이 무엇을 가리는지는 모른다 | 함께 (I4) |
| 주석을 하나씩 읽는다 | 경위까지 안다 | 비공개 프로젝트의 코드를 기록에 옮기게 된다 | ✗ — 코드 이름과 건수만 |

## How to Run

```bash
# 저장소 루트에서. 작업 폴더는 저장소와 원본 밖에 둔다. 원본은 읽기만 한다.
fvm dart .planning/spikes/023-existing-ignore-comments/probe.dart <작업 폴더> <flutter_starter_kit 원본>
```

약 2분 (분석 다섯 번, 각 약 21 ~ 26초). 결과는 `results/probe-<Dart 버전>.{json,log}`. 공용 조각은 `../021-new-rules-language-gate/consumer.dart` 다. "주석을 걷어낸다" 는 손으로 쓴 Dart 파일(생성 파일과 표식 제외)과 이 spike 의 표식 폴더(`lib/woody_probe_marker/ignore_probe/`)에서 `//\s*(ignore_for_file|ignore)\s*:` 부터 줄 끝까지를 지우는 것이다 — 줄은 남겨 줄 번호를 지킨다.

| id | 주석 | 더 켠 규칙 |
|---|---|---|
| I0 | 그대로 | 없음 (지금 사용 프로젝트가 보는 것) |
| I1 | 걷어냄 | 없음 |
| I2 | 그대로 | `lines_longer_than_80_chars`, `discarded_futures`, `cast_nullable_to_non_nullable`, `unnecessary_ignore` |
| I3 | 걷어냄 | I2 와 같음 |
| I4 | 그대로 | `unnecessary_ignore` |

후보 셋은 손으로 쓴 파일이나 생성 파일의 무시 주석이 가리키는 규칙 가운데 지금 켜져 있지 않은 것이다.

## What to Expect

- I0 은 019 · 021 의 기준선과 같다 (프로젝트 0줄).
- I1 에서 프로젝트의 줄이 생긴다 — 주석이 가리고 있던 것.
- 후보 셋 가운데 `lines_longer_than_80_chars` 만 크게 달라진다.
- 판정 7건이 모두 성립한다.

## Investigation Trail

1. 원본을 읽기만 해서(Python, 건수만) 주석의 코드를 먼저 셌다 — 188줄 (손 67 · 생성 121). 로드맵의 "`cast_nullable_to_non_nullable` 56건" 이 전부 생성 파일에 있다는 것을 여기서 봤다. 그래서 생성 파일을 걷어내는 대상에서 빼고(어차피 분석되지 않는다), 손으로 쓴 파일 다섯 개에 붙은 `ignore_for_file: type=lint` 를 따로 가르도록 스크립트를 짰다.
2. 표식에 대조를 넣었다 — 후보마다 가리지 않은 위반 하나, `discarded_futures` · `lines_longer_than_80_chars` 는 주석으로 가린 위반 하나 더, 그리고 아무것도 가리지 않는 주석 하나(`// ignore: avoid_print` 를 `print` 없는 줄 위에). 가린 위반은 I2 에서 숨고 I3 에서 보여야 하고(K5), 빈 주석은 I4 에서 `unnecessary_ignore` 로 잡혀야 한다(K6).
3. `unnecessary_ignore` 가 어느 주석을 가리켰는지는 진단의 메시지를 남기지 않고, 진단이 가리킨 줄의 주석을 복사본에서 다시 읽어 **코드 이름만** 셌다 (주석 뒤에 붙은 설명 글은 버린다).
4. 첫 실행이 끝까지 갔다 (재실행 없음). 022 에서 겪은 일(실행 중 저장소 안에 파일을 만들어 저장소 불변 확인이 깨짐)이 없도록 이 실행 동안에는 저장소를 건드리지 않았다 — K7 성립.

## Results

**판정: VALIDATED** — 주석이 숨기는 줄과 출처가 규칙별로 갈렸다. 판정에 넣은 확인 7건이 모두 성립했다. Dart 3.13.4, `riverpod_lint` 3.1.9, 2026-10-12, `flutter_starter_kit` 의 복사본 (Dart 파일 469개).

| 확인 | 결과 |
|---|---|
| K1 모든 회차에서 `woody_lints` 가 작업 중인 저장소를 가리켰다 | 성립 |
| K2 모든 회차에서 `example/` 정답지 16줄이 표식의 줄에 들어 있다 | 성립 |
| K3 모든 회차에서 plugin 이 준비됐다 | 성립 |
| K4 대조: 후보 규칙마다 가리지 않은 표식이 I2 에서 걸린다 | 성립 |
| K5 대조: 가린 표식이 I2 에서 숨고 I3 에서 보인다 | 성립 |
| K6 대조: 아무것도 가리지 않는 표식 주석이 I4 에서 `unnecessary_ignore` 로 잡힌다 | 성립 |
| K7 저장소가 그대로다 | 성립 |

### 1. 주석의 출처 — 로드맵이 센 둘은 결이 다르다

| 자리 | 종류 | 코드 | 건수 |
|---|---|---|---|
| 생성 파일 | `ignore` | `cast_nullable_to_non_nullable` | **56** |
| 생성 파일 | `ignore_for_file` | `type=lint` 57, `type=warning` 50, 그 밖 11종 각 7 (`*.freezed.dart` 7개의 머리) | — |
| 생성 파일 | `ignore` | `implicit_dynamic_type` | 1 |
| 손으로 쓴 파일 | `ignore_for_file` | `lines_longer_than_80_chars` | **30** |
| 손으로 쓴 파일 | `ignore` / `ignore_for_file` | `subtype_of_sealed_class` | 18 / 3 |
| 손으로 쓴 파일 | `ignore_for_file` | `type=lint` | **5** (파일 5개 — 머리 5줄에 "GENERATED" 가 있는 것은 0) |
| 손으로 쓴 파일 | `ignore` | `unused_import` 4, `discarded_futures` **2**, `use_build_context_synchronously` 1, `argument_type_not_assignable` 1, `unnecessary_type_check` 1, `unused_element_parameter` 1 | — |
| 손으로 쓴 파일 | `ignore_for_file` | `avoid_print` | 1 |

- 주석이 있는 줄: 손으로 쓴 파일 67줄(49개 파일) · 생성 파일 121줄(57개 파일).
- **`cast_nullable_to_non_nullable` 56건은 생성기(freezed)가 단 것이고 모두 생성 파일 안에 있다.** 사용 프로젝트가 생성 파일을 분석에서 빼므로 어느 실행에도 영향이 없다. 이 규칙의 실제 줄은 5줄(`test`)이고 주석을 걷어내도 5줄이다.
- **`discarded_futures` 2건은 손으로 쓴 주석이다.** 규칙이 꺼져 있는 지금은 필요 없는 주석이고(I4), 켜면 2줄을 가린다(I3 − I2 = 2).

### 2. 기준선 0줄 가운데 주석 덕분인 부분 (I0 → I1)

| 새로 나온 줄 | 어디서 | 건수 |
|---|---|---|
| lint — `unnecessary_string_escapes` 8, `unnecessary_string_interpolations` 7, `prefer_final_locals` **4**, `no_leading_underscores_for_local_identifiers` 4, `use_super_parameters` 3 | `ignore_for_file: type=lint` 를 단 손으로 쓴 파일 5개 | 26 |
| lint 가 아닌 analyzer 경고 — `subtype_of_sealed_class` 27, `unnecessary_type_check` 1 | 그 밖의 손으로 쓴 파일 | 28 |

- **019 의 "기준선 0줄" 은 "주석이 있는 채로 0줄" 이다.** 이 패키지의 규칙(`prefer_final_locals`)과 기반 세트의 규칙이 `type=lint` 파일 다섯 개 안에서 26줄 가려져 있다. 그 파일들은 어떤 lint 후보에도 보이지 않는다.
- `avoid_print` (파일 단위 1) 와 `use_build_context_synchronously` (1) 의 주석은 지금 아무것도 가리지 않는다 — 걷어내도 그 규칙의 줄이 생기지 않았고, I4 에서 둘 다 `unnecessary_ignore` 로 잡혔다.

### 3. 후보 규칙의 값이 주석 때문에 적게 세어지는가 (I2 → I3)

| 규칙 | 주석 그대로 (I2) | 주석 걷어냄 (I3) | 주석이 가린 줄 | 가린 주석 |
|---|---|---|---|---|
| `lines_longer_than_80_chars` | 107 | 367 | **260** | 파일 단위 `lines_longer_than_80_chars` 131 + `type=lint` 파일 129 |
| `discarded_futures` | 11 | 13 | 2 | `ignore: discarded_futures` 2 |
| `cast_nullable_to_non_nullable` | 5 | 5 | 0 | (주석은 모두 생성 파일 안) |

표식으로 본 대조: 가리지 않은 표식은 두 실행 모두 걸렸고, 가린 표식은 I3 에서만 보였다 (`lines_longer_than_80_chars` 5 → 6, `discarded_futures` 1 → 2). 표식 줄의 수는 표식 파일에 긴 줄이 더 있어 1 보다 크다.

### 4. `unnecessary_ignore` 의 값은 다른 규칙의 채택에 따라 바뀐다 (I4, I2)

| 실행 | 프로젝트의 `unnecessary_ignore` | 필요 없다고 보고된 주석의 코드 |
|---|---|---|
| I4 (지금의 프리셋 + `unnecessary_ignore`) | **38** (`lib` 3 · `test` 34 · `bin` 1) | `lines_longer_than_80_chars` 30 (파일 단위), `discarded_futures` 2, `avoid_print` 1, `use_build_context_synchronously` 1, `subtype_of_sealed_class` 1, `unused_import` 1, `argument_type_not_assignable` 1, `unused_element_parameter` 1 |
| I2 (후보 셋도 켬) | **12** (`lib` 1 · `test` 10 · `bin` 1) | `lines_longer_than_80_chars` 6 (긴 줄이 없는 파일의 파일 단위 주석), `avoid_print` 1, `use_build_context_synchronously` 1, 그 밖 4종 각 1 |

- `unnecessary_ignore` 는 **켜져 있지 않은 규칙을 가리키는 주석도 필요 없다고 보고한다.** 그래서 이 규칙의 줄 수는 다른 후보를 함께 채택하느냐에 따라 38 과 12 사이에서 달라진다. 022 의 G1 (세 후보를 포함한 106개를 켬)에서 잰 12 도 I2 와 같은 수다.
- 진단의 `code` 는 줄 단위 · 파일 단위 주석 모두 `unnecessary_ignore` 하나였다.

### Phase 4 의 실측과 결정에 주는 것

- **평가표의 값은 주석을 둔 채로 잰다** — 채택했을 때 사용 프로젝트가 실제로 받는 줄이다. 주석이 가린 줄은 따로 한 칸으로 적는다 (지금은 `lines_longer_than_80_chars` 260, `discarded_futures` 2 만 해당).
- **기준선은 "주석이 있는 채로 0" 이라고 적는다.** `type=lint` 를 단 손으로 쓴 파일 다섯 개는 어떤 lint 후보에도 보이지 않는다 — 후보의 값에서 그 파일들은 늘 빠진다.
- 로드맵의 "`cast_nullable_to_non_nullable` 56건" 은 생성 파일 안의 생성기 주석이다. 그 규칙의 값은 5줄이다.
- `unnecessary_ignore` 의 값은 다른 후보의 채택이 정해진 뒤에 다시 잰다 (지금의 프리셋 기준 38, 세 후보를 함께 켜면 12). 채택하면 사용 프로젝트에 지금 있는 낡은 주석(`avoid_print`, `use_build_context_synchronously` 등)이 드러난다.
- 비공개 프로젝트의 기록은 코드 이름과 건수만이다 — 주석의 자리와 설명 글은 `<작업 폴더>/private/` 에도 남기지 않았다 (설명 글은 버렸다).

**놀란 것:** 기준선 0줄 안에 이 패키지의 규칙(`prefer_final_locals`)을 어기는 4줄이 `type=lint` 파일에 숨어 있었다는 것, 그리고 `unnecessary_ignore` 의 값이 다른 규칙의 채택에 묶여 있다는 것.

**재지 않은 것:** `type=lint` 를 단 손으로 쓴 파일 다섯이 무엇인지와 왜 그렇게 했는지(경로를 남기지 않는 조건 — 소유자에게 물을 일), plugin 진단의 무시 주석과 `unnecessary_ignore` (이 프로젝트에는 없다), 생성 파일을 분석에 넣었을 때, 학습용 프로젝트 넷, 다른 SDK.
