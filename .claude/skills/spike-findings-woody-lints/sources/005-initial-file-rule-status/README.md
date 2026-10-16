---
spike: 005
idea: verify-harness-tool-behavior
name: initial-file-rule-status
type: standard
validates: "Given 규칙을 `analysis_options.yaml` 이름의 파일에 직접 적은 패키지, when `dart analyze` 로 분석하면, then `unnecessary_await_in_return` 이 Dart 3.13.4 에서 deprecated 로 보고되는지가 확정된다"
verdict: VALIDATED
related: [002]
tags: [linter-rules, deprecated-lint, removed-lint, undefined-lint, analysis-options, sdk-constraint]
---

# Spike 005: initial file 에서의 규칙 상태 보고

## What This Validates

Given 규칙 이름을 `analysis_options.yaml` 이라는 이름의 파일에 직접 적은 패키지 (analyzer 가 그 파일을 "처음 읽는 옵션 파일(initial file)"로 다루는 상황),
when `dart analyze --format=json` 을 돌리면,
then `unnecessary_await_in_return` 이 Dart 3.13.4 에서 deprecated 로 보고되는지와, deprecated / removed / 없는 규칙이 각각 어떤 진단으로 나오는지가 확정된다.

조사 문서끼리 어긋나 있던 항목이다 (SUMMARY.md "문서 사이에 어긋나는 지점" 1번): STACK.md / FEATURES.md 는 "deprecated, 6개"로 실측했고 PITFALLS.md 는 `rules.json` 을 근거로 "stable, 5개"라고 적었다. VERIFY-02 (deprecated / removed / 없는 규칙이 있으면 검증 실패)의 구현이 이 동작에 기댄다.

## Research

| 출처 | `unnecessary_await_in_return` 의 상태 |
|---|---|
| `pkg/linter/tool/machine/rules.json` (SDK tag 3.13.4) | `stable`. deprecated 는 5개 |
| `pkg/linter/lib/src/rules/unnecessary_await_in_return.dart` (같은 tag) | `state: .deprecated(since: .new(3, 13, 0))` |

같은 tag 안에서 두 파일이 다르다. `rules.json` 은 규칙 소스에서 만들어 내는 파일인데 이 규칙에 대해서는 다시 만들어지지 않은 채 tag 가 찍힌 것으로 보인다 (추정). 실제 동작은 규칙 소스를 따른다.

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| `rules.json` 을 읽어 판정 | SDK 저장소 | 실행이 필요 없다 | tag 의 파일이 실제 동작과 어긋난다 (이번에 확인) | 쓰지 않음 |
| 규칙을 옵션 파일에 적고 analyzer 를 돌린다 | `dart analyze` | 그 SDK 의 실제 판정 | 파일을 놓는 자리에 따라 결과가 달라진다 (아래) | **채택** |

**Chosen approach:** analyzer 를 돌린다. 판정의 근거는 저장소 고정 SDK 의 실제 출력이다.

## How to Run

```bash
# 저장소 안에는 build/woody_rule_check/ 만 잠깐 만들었다가 지운다 (trap). lib/ 는 읽기만 한다.
bash .planning/spikes/005-initial-file-rule-status/probe.sh /tmp/spike005-work
```

## What to Expect

1부~5부로 나눠, 경우마다 `exit N — 진단 N건` 과 진단을 `경로:줄  강도  code — 메시지` 로 찍는다.

## Investigation Trail

모두 Dart 3.13.4, 2026-10-11. 원본은 `results/probe.log`.

### 1부. 규칙 하나씩 (pubspec 의 `sdk: ^3.13.0`)

| 적은 규칙 | 진단 | 강도 | exit |
|---|---|---|---|
| `unnecessary_await_in_return` | `deprecated_lint` | warning | 2 |
| `prefer_final_parameters` (deprecated 대조) | `deprecated_lint` | warning | 2 |
| `avoid_returning_null` (removed 대조) | `removed_lint` | warning | 2 |
| `no_such_rule_zz9` (없는 규칙) | `undefined_lint` | warning | 2 |
| `avoid_print` (정상 대조) | 없음 | — | 0 |

**`unnecessary_await_in_return` 은 Dart 3.13.4 에서 deprecated 다.** 메시지: "The lint rule 'unnecessary_await_in_return' is deprecated and shouldn't be enabled."

세 진단 모두 warning 이고, JSON 에 나오며, `location.file` 이 그 `analysis_options.yaml`, 줄 번호가 그 규칙을 적은 줄이다.

### 2부. deprecated 규칙은 6개

`rules.json` 이 deprecated 라고 적은 5개(`avoid_null_checks_in_equality_operators`, `avoid_private_typedef_functions`, `one_member_abstracts`, `prefer_final_parameters`, `use_if_null_to_convert_nulls_to_bools`)에 `unnecessary_await_in_return` 을 더해 적으면 `deprecated_lint` 가 6건 나온다. STACK.md / FEATURES.md 의 "6개"가 맞다.

### 3부. include 한 파일에 적으면

네 가지 문제 규칙을 `shared.yaml` 에 적고 `analysis_options.yaml` 이 그것을 include 하게 하면, 나오는 것은 **`undefined_lint` 하나뿐**이다 (`included_file_warning` 으로 include 줄에 보고된다). deprecated 와 removed 는 보고되지 않는다. ROADMAP Notes 의 실측이 재현됐다.

### 4부. 실제 배포 파일을 initial file 로 (어디에 복사하느냐)

| 경우 | 복사 위치와 실행 | 결과 |
|---|---|---|
| 4-1 | 저장소 안 `build/woody_rule_check/`, 루트에서 인자 없이 | `plugins_in_inner_options` 1건 (exit 2). 규칙 문제는 없음 = **지금의 12개는 깨끗하다** |
| 4-2 | 같은 복사본, 루트에서 그 폴더를 인자로 | 0건 (exit 0). `plugins_in_inner_options` 도 없다 |
| 4-3 | 문제 규칙 4개를 끼운 복사본, 루트에서 인자 없이 | 4건 모두 + `plugins_in_inner_options` |
| 4-4 | 4-3 에서 `plugins:` 를 뺀 것 | 4건만 |
| 4-6 | 문제 규칙 4개를 끼운 복사본(`plugins:` 포함), 그 폴더를 인자로 | 4건만. 다만 **plugin 을 준비한다** (11초, 네트워크 필요) |
| 4-5 | 저장소 **밖** 임시 폴더에 원본, `--packages` 로 패키지 설정을 넘김 | 0건 |
| 4-7 | 저장소 **밖** 임시 폴더에 문제 규칙 4개를 끼운 복사본 | **`undefined_lint` 1건뿐.** deprecated 2건과 removed 1건이 빠진다 |
| 4-8 | 4-7 에 Dart 파일을 하나 둔 것 | 4-7 과 같음 |

4-7 이 예상 밖이었다. 같은 파일인데 저장소 밖에 두면 deprecated / removed 가 보고되지 않는다. 원인은 5부.

### 5부. 보고 여부는 그 패키지의 SDK 하한에 달려 있다

| 규칙 (상태가 바뀐 버전) | pubspec 의 `sdk` | 진단 |
|---|---|---|
| `unnecessary_await_in_return` (deprecated, 3.13.0) | `^3.12.0` | 없음 |
| | `^3.13.0` | `deprecated_lint` |
| `prefer_final_parameters` (deprecated, 3.11.0) | `^3.10.0` | 없음 |
| | `^3.11.0` | `deprecated_lint` |
| `avoid_returning_null` (removed, 3.3.0) | `^3.2.0` | 없음 |
| | `^3.3.0` | `removed_lint` |
| `unnecessary_await_in_return` | pubspec 없음 | 없음 |

**`deprecated_lint` / `removed_lint` 는 옵션 파일이 속한 패키지의 `pubspec.yaml` 이 선언한 SDK 하한이, 그 규칙이 deprecated / removed 된 버전 이상일 때만 보고된다.** pubspec 이 없으면 보고되지 않는다. `undefined_lint` 는 SDK 하한과 상관없이 보고된다.

이것으로 설명되는 것:

- 4-7 에서 빠진 이유: 저장소 밖 임시 폴더에는 pubspec 이 없다.
- 4-1 / 4-3 / 4-6 에서 나온 이유: 저장소 안에 두면 루트 `pubspec.yaml` 의 `sdk: ^3.13.0` 이 적용된다.
- 조사 문서가 어긋난 이유의 절반: Phase 1 에서 하한을 `^3.10.4` → `^3.13.0` 으로 올리기 전의 이 저장소에서는 `unnecessary_await_in_return` 이 보고되지 않았을 것이다 (나머지 절반은 `rules.json` 이 tag 에서 낡은 것).

## Results

**Verdict: VALIDATED** — `unnecessary_await_in_return` 은 Dart 3.13.4 에서 deprecated 이고 (3.13.0 부터), initial file 검사에서 warning 인 `deprecated_lint` 로 드러난다. 규칙 후보에서 제외한 판정(SUMMARY.md 1번)이 맞다.

VERIFY-02 구현이 가져갈 것:

1. **복사본은 저장소 안에 둔다** (루트 `pubspec.yaml` 의 SDK 하한이 적용되는 자리). 저장소 밖 임시 폴더(`Directory.systemTemp`)에 두면 deprecated / removed 를 놓친다. 4-7 처럼 `undefined_lint` 만 잡히므로 "검사가 도는 것처럼 보이는데 반만 본다".
2. 판정: 그 복사본 파일에 대한 진단 중 `deprecated_lint`, `removed_lint`, `undefined_lint` 가 하나라도 있으면 실패. 셋 다 warning 이라 JSON 에 나온다 (`dart analyze` 는 옵션 파일의 **error** 진단만 JSON 에서 빠뜨린다).
3. `plugins:` 를 담은 채 복사하면 둘 중 하나가 생긴다 — 루트에서 인자 없이 돌리면 `plugins_in_inner_options`(걸러 내야 함), 그 폴더를 인자로 주면 plugin 준비(11초 + 네트워크). 복사할 때 `plugins:` 섹션을 빼면 둘 다 없다 (4-4). Phase 3 에서 규칙이 `plugins:` 없는 `base.yaml` 로 옮겨 가면 이 문제는 사라진다.
4. 폴더 이름이 점(`.`)으로 시작하면 분석되지 않는다 (STACK.md). `build/…` 처럼 평범한 이름을 쓰고 끝나면 지운다. 저장소에 `build/` 가 남지 않도록 `.gitignore` 에도 넣는다.
5. 이 검사의 "민감도"는 루트 `pubspec.yaml` 의 SDK 하한을 따른다. 하한이 `^3.13.0` 인 동안에는 3.14 에서 deprecated 될 규칙을 3.14 SDK 로 돌려도 잡지 못한다. 하한을 올리는 릴리스에서 새로 잡히는 규칙이 생길 수 있다.

Phase 4 로 넘길 것: 규칙 메타데이터는 tag 의 `rules.json` 도 그대로 믿을 수 없다. 후보 규칙은 이 spike 의 방식(옵션 파일에 적고 고정 SDK 로 분석)으로 한 번 걸러야 한다. 지금 선언된 12개는 깨끗하다 (4-1).

원본: `results/probe.log`.
