---
spike: 013
idea: preset-split-include-behavior
name: rule-check-after-split
type: standard
validates: "Given 규칙이 base.yaml 로 옮겨 간 복사본, when 검증 명령의 규칙 검사와 같은 실행(복사본 폴더를 인자로 준 dart analyze)에 문제 규칙 셋과 깨진 입력을 넣으면, then 세 코드가 같은 줄 번호로 나오고 깨진 입력이 각각 어떤 종료 코드와 진단으로 드러나는지가 확정된다"
verdict: VALIDATED
related: [005, 007, 009, 011]
tags: [linter-rules, deprecated-lint, rule-check, broken-yaml]
---

# Spike 013: 나눈 뒤의 규칙 검사

## What This Validates

spike 005 (규칙 상태는 직접 분석되는 옵션 파일에서만 온전히 보고된다) 와 007 (복사본 폴더를 인자로 준다) 이 맞물리는 자리를 나눈 구조에서 다시 잰다. ROADMAP Notes 의 "규칙이 `base.yaml` 로 옮겨 가므로 deprecated / removed 검사가 새 위치를 대상으로 계속 실패를 잡는지 확인한다" 와, 03-CONTEXT.md 의 "가장 먼저 할 일"(세 코드 밖의 진단도 `[2/4]` 의 실패로 친다)이 기댈 사실이다.

- **Given** 규칙이 `lib/base.yaml` 로 옮겨 간 복사본
- **When** `tool/verify.dart` 의 규칙 검사와 같은 실행(대상 파일을 `build/woody_rule_check/` 에 `analysis_options.yaml` 이름으로 복사하고 루트에서 그 폴더를 인자로 분석)에 문제 규칙 셋과 깨진 입력을 넣으면
- **Then** 세 코드가 같은 줄 번호로 나오고, 깨진 입력이 각각 어떤 종료 코드와 진단으로 드러나는지가 확정된다

## Research

- spike 005: `deprecated_lint` / `removed_lint` 는 직접 분석되는 옵션 파일에 적힌 규칙에만 보고된다. include 로 닿은 파일에서는 없는 규칙(`undefined_lint`)만 `included_file_warning` 으로 보고된다. `dart analyze` 는 옵션 파일의 **error** 진단을 JSON 에서 빠뜨린다.
- spike 007: 복사본 폴더를 인자로 주면 그 폴더의 진단만 나오고, 복사본이 `plugins:` 를 담고 있으면 plugin 을 준비한다.
- `02-VERIFICATION.md` 의 "다음 phase 가 알아야 할 것" 1 ~ 4: 지금의 `[2/4]` 는 세 코드와 "규칙 0개" 만 본다. 깨진 YAML · `rules:` 오타 · 겹친 규칙에서 통과로 찍히고(`c04` ~ `c06`), 대상 파일에 규칙이 하나라도 있으면 include 뒤의 파일에 넣은 deprecated 규칙은 어느 단계도 잡지 못한다(`c12`), 별칭으로 바꾸면 `stripPlugins` 가 exit 70 을 낸다(`c13`).

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 대상 경로만 `lib/base.yaml` 로 바꾼다 | 지금의 `[2/4]` | 변경이 가장 작다 | 다른 조각에 적힌 규칙을 보지 못한다 (K6) | 부족 |
| 조각마다 하위 폴더에 복사해 한 번에 돌린다 | `build/woody_rule_check/<이름>/analysis_options.yaml` | 한 번의 실행(0.5초)으로 모든 조각을 본다. 진단의 경로로 어느 조각인지 안다 | `plugins:` 를 담은 조각은 빼고 복사해야 한다 | **잼 — 성립 (K7)** |
| 묶음이나 별칭을 대상으로 둔다 | 같음 | 사슬 전체를 한 번에 | include 를 거쳐 plugin 까지 준비한다 (10초, 네트워크). 규칙 상태는 include 뒤라 어차피 보고되지 않는다 | 쓰지 않음 (K4 · K5) |

**Chosen approach:** 검증 명령과 같은 형태의 실행을 replica 에서 흉내 내고, 대상 파일 · 숨은 규칙 · 깨진 입력을 바꿔 가며 종료 코드와 JSON 을 따로 기록한다 (CONVENTIONS.md — 하나만 보고 판정하지 않는다).

## How to Run

```bash
# 저장소의 파일은 읽기만 한다 (약 1분, 네트워크 필요).
fvm dart run .planning/spikes/013-rule-check-after-split/probe.dart /tmp/spike013-work
```

## What to Expect

경우마다 `exit`, 시간, 진단 수, plugin 준비 폴더 수를 찍고 진단을 메시지와 함께 늘어놓는다. 깨진 입력에는 "지금의 판정으로는 통과로 찍힌다 / 실패로 잡힌다" 가 붙는다.

## Investigation Trail

모두 Dart 3.13.4, macOS arm64, 2026-10-12. 두 번 돌려 두 번 모두 같았다. 실행은 replica 루트에서 `dart --suppress-analytics analyze --format=json build/woody_rule_check` 이고 실행마다 빈 상태 폴더를 줬다.

### 1. 대상이 `base.yaml`

| id | 복사본 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|
| K0 | `base.yaml` 그대로 | 0 | 0건 | 없음 | 0.5초 |
| K1 | 문제 규칙 셋을 끼움 | 2 | 3건 | 없음 | 0.5초 |

```text
build/woody_rule_check/analysis_options.yaml:41  warning  deprecated_lint   (unnecessary_await_in_return)
build/woody_rule_check/analysis_options.yaml:42  warning  removed_lint      (avoid_returning_null)
build/woody_rule_check/analysis_options.yaml:43  warning  undefined_lint    (no_such_rule_zz9)
```

- `base.yaml` 에는 `plugins:` 가 없으므로 **빼는 단계 없이 그대로 복사한다.** 복사본의 줄 번호가 `lib/base.yaml` 의 줄 번호와 늘 같다 (마지막 규칙이 40행, 끼운 것이 41 ~ 43행). spike 007 이 적은 "순서가 바뀌면 줄 번호가 달라진다" 는 걱정이 없어진다.
- 검증 명령의 규칙 셈(`countDeclaredRules`)은 `base.yaml` 에서 12 다.

### 2. 다른 파일을 대상으로 두면

| id | 복사본 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|
| K2 | `codegen.yaml` 그대로 | 0 | 0건 | 없음 | 0.5초 |
| K3 | `riverpod.yaml` 그대로 (`plugins:` 를 담은 채) | 0 | 0건 | **있음** | 10초 |
| K4 | `recommended.yaml` 그대로 | 0 | 0건 | **있음** | 10초 |
| K5 | 별칭(`lib/analysis_options.yaml`) 그대로 | 0 | 0건 | **있음** | 10초 |

폴더를 인자로 주면 그 폴더가 분석의 루트가 되므로, 복사본이 include 로 `plugins:` 에 닿기만 해도 plugin 을 준비한다 (spike 011 의 R2 — 저장소 루트에서 인자 없이 돌릴 때는 준비하지 않는다 — 와 다른 점이다).

### 3. 다른 조각에 숨은 규칙

`riverpod.yaml` 끝에 `linter: rules:` 블록과 문제 규칙 셋을 뒀다.

| id | 검사 | exit | 진단 |
|---|---|---|---|
| K6 | 대상은 `base.yaml` 하나 | 0 | **0건 — 하나도 잡히지 않는다** |
| K7 | `base/` 와 `riverpod/` 하위 폴더에 나눠 복사 (`riverpod` 는 `plugins:` 를 뺌), 한 번에 | 2 | 6건 — 두 파일의 세 코드가 모두, plugin 준비 없음, 0.5초 |
| K8 | 같은 상태에서 `example/` 을 옛 주소로 분석 (정답지 비교가 보는 것) | 2 | 정답지와 1줄 다름 |

K8 의 한 줄: `analysis_options.yaml:1  warning  included_file_warning` — 메시지에 `'no_such_rule_zz9' isn't a recognized lint rule.` 정답지 비교는 **없는 규칙만** 잡고 deprecated 와 removed 는 놓친다 (spike 005 의 3부가 3단 구조에서 재현됐다).

K7 의 진단은 경로에 조각 이름이 들어 있어 어느 파일의 몇 행인지 그대로 읽힌다 (`build/woody_rule_check/riverpod/analysis_options.yaml:12`). 다만 `plugins:` 를 뺀 조각은 뺀 줄만큼 줄 번호가 원본과 어긋난다.

### 4. 깨진 입력 — 세 코드 밖의 신호

| id | 입력 | exit | JSON 의 진단 | 규칙 셈 | 지금의 `[2/4]` |
|---|---|---|---|---|---|
| B1 | 닫지 않은 따옴표 (깨진 YAML) | **3** | **0건** | 12 | 통과로 찍힌다 |
| B5 | 목록과 맵을 섞음 (`이름: false` 한 줄) | **3** | **0건** | 12 | 통과로 찍힌다 |
| B2 | `rules:` 의 오타 (`ruels:`) | 2 | `…:21  warning  unsupported_option` | 12 | 통과로 찍힌다 |
| B3 | 겹친 규칙 (`avoid_print` 를 한 번 더) | 2 | `…:41  warning  duplicate_rule` | 13 | 통과로 찍힌다 |
| B4 | `linter:` 의 오타 (`lintr:`) | **0** | **0건** | **0** | 실패로 잡힌다 (규칙 0개) |
| B6 | `codegen.yaml` 의 진단 코드 오타 | 2 | `…:3  warning  unrecognized_error_code` | 0 | — (지금은 대상이 아니다) |

- **깨진 YAML 은 JSON 에 아무것도 남기지 않는다.** B1 과 B5 는 `{"version":1,"diagnostics":[]}` 에 exit 3 이고 stderr 도 비어 있다. `--format=machine` 도 출력이 없다. 형식 인자 없이 돌린 기본 출력에만 원인이 찍힌다.

  ```text
  Errors were found in 'pubspec.yaml' and/or 'analysis_options.yaml' which might result in either invalid diagnostics being produced or valid diagnostics being missed.

    error - analysis_options.yaml:49:1 - Unexpected end of file. - parse_error
  ```

- **`linter:` 의 오타는 진단도 종료 코드도 남기지 않는다** (B4 — exit 0, 0건). 모르는 최상위 키는 조용히 무시된다. 이것을 잡는 것은 지금도 "규칙 0개" 확인뿐이다.
- `rules:` 의 오타와 겹친 규칙은 세 코드 밖의 warning 으로 나온다. "세 코드 밖의 진단도 실패로 친다" 면 그 단계에서 잡힌다.
- `codegen.yaml` 을 대상에 넣으면 `analyzer.errors` 의 오타도 잡힌다 (B6). 다만 `codegen.yaml` 에는 규칙이 없으므로 **"규칙 0개" 확인을 모든 대상에 걸면 깨끗한 `codegen.yaml` 이 실패한다.**

## Results

**Verdict: VALIDATED** — 14건 모두 성립했다.

1. `base.yaml` 을 그대로 복사한 규칙 검사는 문제 규칙 셋을 원본과 같은 줄 번호로 잡는다. plugin 을 준비하지 않고 0.5초다.
2. 대상이 `base.yaml` 하나뿐이면 다른 조각에 적힌 문제 규칙은 잡히지 않는다. 조각마다 하위 폴더에 복사해 한 번에 돌리면 모두 잡힌다.
3. 깨진 입력의 신호가 확정됐다 — 깨진 YAML 은 "exit 3 인데 JSON 의 진단이 0건", `rules:` 오타와 겹친 규칙은 세 코드 밖의 warning, `linter:` 오타는 아무 신호도 없다.

Phase 3 의 계획이 가져갈 것 — 규칙 검사 단계의 모양:

1. **대상은 `base.yaml` 과 `codegen.yaml`, 그리고 `plugins:` 를 뺀 `riverpod.yaml` 이다.** `build/woody_rule_check/<조각 이름>/analysis_options.yaml` 로 복사하고 지금처럼 폴더를 인자로 한 번 돌린다. 묶음과 별칭은 대상에 넣지 않는다 (plugin 을 준비한다 — 사슬이 풀리는지는 루트 분석이 본다, spike 011 의 R5).
2. **통과 조건은 "exit 0 이고 복사본의 진단이 0건" 이다.** 깨끗한 `base.yaml` 과 `codegen.yaml` 이 그렇다 (K0, K2). `plugins:` 를 뺀 깨끗한 `riverpod.yaml` 은 따로 재지 않았다 — 주석만 남는 파일이다. 이 한 조건이 세 코드, 세 코드 밖의 warning(B2 · B3 · B6), 깨진 YAML(B1 · B5 — exit 3)을 모두 실패로 만든다.
3. **"규칙 0개" 확인은 `base.yaml` 에만 건다.** `linter:` 오타(B4)를 잡는 유일한 수단이고, 다른 조각에 걸면 헛실패한다.
4. exit 3 에 JSON 의 진단이 0건이면 실패 문구에 "YAML 이 깨졌을 수 있다" 를 적고, 원인은 형식 인자 없이 돌린 출력의 `parse_error` 줄로 안내한다 (스크립트가 그 실행을 한 번 더 해서 보여 줄 수도 있다 — 0.5초).
5. `base.yaml` 에는 `stripPlugins` 가 필요 없다. 지금의 `stripPlugins` 는 `plugins:` 가 없으면 `FormatException` 을 던지므로 (`c13` 의 exit 70) "있으면 뺀다" 로 바꿔야 한다.
6. `base.yaml` 의 진단은 줄 번호가 원본과 같다. `plugins:` 를 뺀 `riverpod.yaml` 은 어긋나므로 실패 문구에 그 사실을 적거나, 빼지 않고 빈 줄로 바꿔 줄 번호를 지킨다.

spike 005 · 007 의 결론에서 달라지는 것:

- 005 의 "복사할 때 `plugins:` 섹션을 뺀다" 는 `base.yaml` 에는 해당하지 않는다 (005 가 예고한 대로다). `plugins:` 를 담은 조각을 대상에 넣을 때만 필요하다.
- 007 의 "복사본의 줄 번호는 원본과 같다 — `plugins:` 가 규칙 목록 뒤에 있어서" 는 `base.yaml` 에서 조건 없이 참이 된다.

확인하지 않은 것:

- `tool/verify.dart` 를 실제로 고쳐 돌린 것. 여기서는 같은 형태의 실행을 흉내 냈다.
- 맵 문법(`이름: true`)으로만 적은 규칙 목록. 지금의 `countDeclaredRules` 는 0 으로 센다 (`02-VERIFICATION.md` 2번이 적어 둔 가정). 배포 파일은 목록 문법이다.
- 깨진 입력을 사용 프로젝트 쪽(include 로 받는 쪽)에서 봤을 때의 진단. Phase 2 의 검증이 한 파일 구조에서 재현해 뒀다 (`included_file_warning`, 정답지의 `exit` 줄이 3).
- GitHub Linux runner 에서의 같은 실행.

원본: `results/probe.log`, `results/probe.json`.
