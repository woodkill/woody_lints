# deprecated / removed / 없는 규칙 검사

배포 파일에 적힌 규칙 중 deprecated 됐거나, 삭제됐거나, 존재하지 않는 것이 있으면 검증을 실패시키는 부분이다 (VERIFY-02). 프리셋을 나눈 뒤에는 조각 셋이 모두 대상이고, 깨진 옵션 파일도 이 단계가 잡는다.

모든 수치는 Dart 3.13.4 실측이다. 복사본을 저장소 안에 두는 이유와 실행 형태는 2026-10-11 (005, 007), 나눈 뒤의 대상 · 통과 조건 · 깨진 입력은 2026-10-12 (013) 에 쟀다.

## Requirements

MANIFEST.md 의 `verify-harness-tool-behavior` 에서 이 영역에 걸리는 것.

- deprecated / removed 규칙 검사에 쓰는 배포 파일 복사본은 **저장소 안**에 둔다. `deprecated_lint` / `removed_lint` 는 그 파일이 속한 패키지의 pubspec SDK 하한이 해당 버전 이상일 때만 보고되고, pubspec 이 없는 임시 폴더에서는 보고되지 않는다 (005)
- 규칙 검사는 저장소 루트에서 **복사본 폴더를 인자로** 준다 (`dart analyze build/woody_rule_check`). 그 폴더의 진단만 나오고 plugin 을 준비하지 않으며 `example/` 의 상태에 기대지 않는다. 005 의 "루트에서 인자 없이"를 대신한다 (007)
- `lib/`, `pubspec.yaml` 은 바꾸지 않는다. 루트 `analysis_options.yaml` 은 기존 exclude 항목(`lib/analysis_options.yaml`)을 그대로 둔다 (`lib/` 는 읽기만 한다)
- 검증 스크립트는 Dart 이고 `dart:io`, `dart:convert` 만 쓴다 (D-11)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 한다

MANIFEST.md 의 `preset-split-include-behavior` 에서 이 영역에 걸리는 것.

- 파일 이름은 `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml` 이고, `lib/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 한 줄짜리 별칭이다
- 규칙 검사는 `base.yaml` · `codegen.yaml` · (`plugins:` 를 뺀) `riverpod.yaml` 을 `build/woody_rule_check/<조각 이름>/analysis_options.yaml` 로 복사해 한 번에 돌린다. 통과 조건은 "exit 0 이고 복사본의 진단이 0건" 이다. "규칙 0개" 확인은 `base.yaml` 에만 건다. 묶음과 별칭은 대상에 넣지 않는다 — 폴더를 인자로 준 분석에서는 include 를 거쳐 plugin 까지 준비한다 (013)
- 깨진 YAML 은 exit 3 인데 JSON 의 진단이 0건이고 stderr 도 비어 있다. 원인(`parse_error`)은 형식 인자 없이 돌린 출력에만 찍힌다. `linter:` 키의 오타는 아무 신호도 남기지 않는다 (013)

위 `verify-harness-tool-behavior` 목록의 "`lib/` 는 바꾸지 않는다 · 루트의 제외를 그대로 둔다" 는 Phase 2 의 범위였다. 이 검사가 `lib/` 를 **읽기만 한다**는 점은 나눈 뒤에도 같다.

## How to Build It

analyzer 는 규칙의 상태를 **`analysis_options.yaml` 이라는 이름의 파일에 직접 적힌 규칙**에 대해서만 온전히 보고한다. include 로 받은 파일에 적힌 규칙은 "없는 규칙"만 보고된다. 그래서 대상 파일을 그 이름으로 복사해 놓고 분석한다.

### 1. 대상을 저장소 안에 복사한다

| 구조 | 대상 | 복사할 때 | 복사본 |
|---|---|---|---|
| 한 파일 (Phase 2 의 `tool/verify.dart`) | `lib/analysis_options.yaml` | `plugins:` 를 뺀다 | `build/woody_rule_check/analysis_options.yaml` |
| 나눈 뒤 | `lib/base.yaml` | 그대로 | `build/woody_rule_check/base/analysis_options.yaml` |
| | `lib/codegen.yaml` | 그대로 | `build/woody_rule_check/codegen/analysis_options.yaml` |
| | `lib/riverpod.yaml` | `plugins:` 를 뺀다 | `build/woody_rule_check/riverpod/analysis_options.yaml` |

- 자리는 **점으로 시작하지 않는** 폴더다. 점으로 시작하면 분석되지 않는다.
- **나눈 뒤에는 조각 셋이 모두 대상이다.** 대상이 `base.yaml` 하나뿐이면 다른 조각에 적힌 문제 규칙은 한 건도 잡히지 않는다 (→ 6번).
- **묶음(`recommended.yaml`)과 별칭(`lib/analysis_options.yaml`)은 대상에 넣지 않는다.** 폴더를 인자로 준 분석에서는 그 폴더가 분석의 루트가 되어, 복사본이 include 로 `plugins:` 에 닿기만 해도 plugin 을 준비한다 (10초, 네트워크). 규칙의 상태는 include 뒤라 어차피 보고되지 않는다. 사슬이 풀리는지는 루트 분석이 본다 (→ preset-split-structure.md 5번).
- `base.yaml` 에는 `plugins:` 가 없으므로 **빼는 단계 없이 그대로 복사한다.** 복사본의 줄 번호가 `lib/base.yaml` 의 줄 번호와 늘 같다.

`plugins:` 는 **있으면** 뺀다.

```dart
// sources/013-rule-check-after-split/probe.dart 의 K7 에서.
// hiddenRules 는 실험으로 끼운 문제 규칙이다 — 빼는 패턴은 replaceAll 한 줄이다.
final strippedRiverpod = (shipped.riverpodYaml() + hiddenRules)
    .replaceAll(RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true), '');
```

- Phase 2 의 `stripPlugins` 는 섹션을 찾지 못하면 `FormatException` 을 던진다 (007 의 형태 — `sources/007-root-analysis-with-example/probe.dart`). `plugins:` 가 없는 파일(`base.yaml`, 한 줄짜리 별칭)을 넘기면 던진다는 뜻이고, 대상을 별칭으로 바꿨을 때 검증 명령이 exit 70 으로 끝나는 것은 Phase 2 의 검증이 봤다 (`02-VERIFICATION.md` 의 `c13`). 나눈 뒤에는 "있으면 뺀다" 로 바꿔야 한다.
- 던지지 않게 바꾸면 "`plugins:` 가 있는데 패턴이 놓친 경우" 가 조용해진다. 빼고 난 복사본에 `^plugins:` 줄이 남아 있지 않은지 확인하면 그 경우를 막을 수 있다 (추론이고 spike 가 돌린 것은 아니다. 남은 채 분석하면 plugin 준비로 10초가 드는 것은 쟀다).
- 이 패턴은 `plugins:` 줄과 그 바로 아래에 이어지는 들여쓴 줄들만 지운다. 지금은 `plugins:` 아래가 `  riverpod_lint: ^3.1.3` 한 줄이다. 섹션 안에 빈 줄이 끼는 모양으로 바뀌면 그 뒤가 남는다.
- `plugins:` 를 뺀 조각은 섹션 뒤의 줄 번호가 뺀 줄만큼 원본과 어긋난다. 실패 문구에 그 사실을 적거나, 빼지 않고 빈 줄로 바꿔 줄 번호를 지킨다 (013 의 제안이고 빈 줄로 바꾼 형태는 돌리지 않았다). spike 가 자른 `riverpod.yaml` 은 `plugins:` 가 맨 끝이라 지금은 어긋날 줄이 없다.

### 2. 저장소 루트에서 복사본 폴더를 인자로 주고 분석한다

```bash
# 저장소 루트에서
dart --suppress-analytics analyze --format=json build/woody_rule_check
```

- 그 폴더의 진단만 나온다. `example/` 을 훑지 않고 plugin 을 준비하지 않는다. 0.5초다.
- 하위 폴더 여럿을 한 번에 본다. 조각마다 하위 폴더에 복사해 두고 한 번 돌리면 두 파일의 진단이 모두 나왔고(0.5초, plugin 준비 없음), 진단의 경로에 조각 이름이 들어 있어 어느 파일의 몇 행인지 그대로 읽힌다 (`build/woody_rule_check/riverpod/analysis_options.yaml:12`).
- 루트 `pubspec.yaml` 의 SDK 하한(`^3.13.0`)이 복사본에 적용된다. 이것이 저장소 안에 두는 이유다. 폴더를 인자로 주어도 그대로 적용된다 (deprecated 와 removed 가 보고됐다).
- `example/` 이 있고 그 패키지를 받은 상태에서, 루트 옵션 파일에 `example/**` 제외가 있든 없든 결과가 같았다 (007 의 R2b, R3b). `example/` 의 패키지를 받기 전 상태는 이 형태로 재지 않았다.

### 3. 판정 — exit 0 이고 복사본의 진단이 0건

통과 조건은 하나다: **종료 코드가 0 이고 복사본의 진단이 0건.** 깨끗한 `base.yaml` 과 `codegen.yaml` 이 그렇다.

| 복사본에 넣은 것 | exit | JSON 의 진단 | 이 조건으로 | 근거 |
|---|---|---|---|---|
| 깨끗한 `base.yaml` / `codegen.yaml` | 0 | 0건 | 통과 | 013 (K0, K2) |
| deprecated / removed / 없는 규칙 | 2 | `deprecated_lint` / `removed_lint` / `undefined_lint` | 실패 | 005, 007, 013 (K1) |
| `rules:` 의 오타 (`ruels:`) | 2 | `…:21  warning  unsupported_option` | 실패 | 013 (B2) |
| 겹친 규칙 (`avoid_print` 를 한 번 더) | 2 | `…:41  warning  duplicate_rule` | 실패 | 013 (B3) |
| `codegen.yaml` 의 진단 코드 오타 | 2 | `…:3  warning  unrecognized_error_code` | 실패 | 013 (B6) |
| 닫지 않은 따옴표 (깨진 YAML) | **3** | **0건** | 실패 (종료 코드로) | 013 (B1) |
| 목록과 맵을 섞음 (`이름: false` 한 줄) | **3** | **0건** | 실패 (종료 코드로) | 013 (B5) |
| `linter:` 의 오타 (`lintr:`) | **0** | **0건** | **통과해 버린다** — 아래의 "규칙 0개" 확인이 잡는다 | 013 (B4) |

규칙의 상태를 알리는 세 코드. 셋 다 warning 이라 JSON 에 나오고, 줄 번호는 그 규칙을 적은 줄이다.

| `code` | 뜻 | 메시지 예 |
|---|---|---|
| `deprecated_lint` | deprecated 된 규칙 | "The lint rule 'unnecessary_await_in_return' is deprecated and shouldn't be enabled." |
| `removed_lint` | 삭제된 규칙 | — |
| `undefined_lint` | 없는 규칙 | — |

`base.yaml` 의 규칙 목록 끝에 문제 규칙 셋을 끼웠을 때 (마지막 규칙이 40행, 끼운 것이 41 ~ 43행):

```text
build/woody_rule_check/analysis_options.yaml:41  warning  deprecated_lint   (unnecessary_await_in_return)
build/woody_rule_check/analysis_options.yaml:42  warning  removed_lint      (avoid_returning_null)
build/woody_rule_check/analysis_options.yaml:43  warning  undefined_lint    (no_such_rule_zz9)
```

**이 표와 출력의 경로는 하위 폴더가 없는 평평한 모양이다.** 013 은 위 표의 입력을 복사본 하나(`build/woody_rule_check/analysis_options.yaml`)로 두고 하나씩 쟀다. 하위 폴더에 나눠 두고 한 번에 돌린 것은 문제 규칙을 넣은 `base/` + `riverpod/` 한 번이고, 그때의 경로는 `build/woody_rule_check/base/analysis_options.yaml:41` 처럼 조각 이름이 끼어 있다. **깨끗한 조각 셋을 하위 폴더에 두고 한 번에 돌려 exit 0 · 0건이 나오는 실행은 하지 않았다** — 1번의 "나눈 뒤" 배치를 구현하면서 처음 확인하게 된다.

**"규칙 0개" 확인은 `base.yaml` 에만 건다.** `linter:` 의 오타는 진단도 종료 코드도 남기지 않는다 — 모르는 최상위 키는 조용히 무시된다. 이것을 잡는 수단은 본문에서 규칙 수를 세는 확인뿐이다 (`countDeclaredRules`, `base.yaml` 에서 12). `codegen.yaml` 에는 규칙이 없으므로 모든 대상에 걸면 깨끗한 `codegen.yaml` 이 실패한다.

**exit 3 인데 JSON 의 진단이 0건이면 YAML 이 깨진 것이다.** stdout 은 `{"version":1,"diagnostics":[]}` 이고 stderr 도 비어 있다. `--format=machine` 도 출력이 없다. 원인은 형식 인자 없이 돌린 기본 출력에만 찍힌다.

```text
Errors were found in 'pubspec.yaml' and/or 'analysis_options.yaml' which might result in either invalid diagnostics being produced or valid diagnostics being missed.

  error - analysis_options.yaml:49:1 - Unexpected end of file. - parse_error
```

- 실패 문구에 "YAML 이 깨졌을 수 있다" 를 적고 원인은 형식 인자 없이 돌린 출력의 `parse_error` 줄로 안내한다. 스크립트가 그 실행을 한 번 더 해서 보여 줄 수도 있다 (0.5초).
- Phase 2 의 판정은 세 코드와 "규칙 0개" 만 본다. 그래서 위 표의 B1 · B2 · B3 · B5 가 통과로 찍힌다 (`02-VERIFICATION.md` 의 "다음 phase 가 알아야 할 것" 1번). Phase 3 이 가장 먼저 닫을 경로가 이것이다 (03-CONTEXT.md).
- 013 은 이 입력들을 `base.yaml` 에 (B6 은 `codegen.yaml` 에) 넣어 쟀다. 한 파일 구조의 복사본에 새 통과 조건을 건 실행은 하지 않았다.
- `plugins:` 를 뺀 깨끗한 `riverpod.yaml` 은 따로 재지 않았다. 주석만 남는 파일이다.

### 4. 끝나면 반드시 지운다

- Dart 는 `finally`, bash 는 `trap` 으로 어떤 경우에도 지운다.

```bash
# sources/005-initial-file-rule-status/probe.sh
cleanup() {
  rm -rf "$IN_REPO_CHECK"
  rmdir "$REPO_ROOT/build" 2>/dev/null || true
}
trap cleanup EXIT
```

- `.gitignore` 에 `build/` 가 들어 있다 (Phase 2). 남더라도 커밋되지 않는다.

### 5. 지금 상태

현재 선언된 규칙 12개는 깨끗하다. `plugins:` 를 뺀 한 파일 복사본도(005, 007), 나눈 뒤의 `base.yaml` 과 `codegen.yaml` 도(013) 0건, exit 0 이다.

### 6. 정답지 비교가 대신 잡아 주지 않는다

`riverpod.yaml` 끝에 `linter: rules:` 블록과 문제 규칙 셋(deprecated, removed, 없는 규칙)을 숨겼을 때:

| 검사 | exit | 진단 |
|---|---|---|
| 규칙 검사, 대상은 `base.yaml` 하나 | 0 | **0건 — 하나도 잡히지 않는다** |
| 규칙 검사, `base/` 와 `riverpod/` 하위 폴더에 나눠 복사 | 2 | 6건 — 두 파일의 세 코드가 모두 |
| 같은 상태의 `example/` 을 옛 주소로 분석 (정답지 비교가 보는 것) | 2 | 정답지와 1줄 다름 |

정답지 비교에 나타나는 한 줄은 `analysis_options.yaml:1  warning  included_file_warning` 이고 메시지는 `'no_such_rule_zz9' isn't a recognized lint rule.` 이다. **없는 규칙만** 잡고 deprecated 와 removed 는 놓친다. 그래서 규칙이 적힐 수 있는 조각은 모두 이 검사의 대상이어야 한다.

### 7. 규칙 후보를 거르는 데에도 같은 방식을 쓴다 (Phase 4)

후보 규칙을 옵션 파일에 적고 고정 SDK 로 분석해 한 번 거른다. 규칙만 담은 순수 Dart 패키지를 만드는 함수가 `sources/005-initial-file-rule-status/probe.sh` 의 `make_rules_package` 에 있다 (`pubspec.yaml` 에 `sdk: ^3.13.0` 을 적는 것이 핵심이다).

## What to Avoid

- **복사본을 저장소 밖 임시 폴더(`Directory.systemTemp`)에 두는 것.** deprecated 와 removed 를 놓치고 `undefined_lint` 만 잡힌다. 검사가 도는 것처럼 보이는데 반만 본다. 임시 폴더에는 pubspec 이 없어 SDK 하한이 없기 때문이다. `--packages` 로 패키지 설정을 넘겨도 같다.
- **나눈 뒤 대상의 경로만 `lib/base.yaml` 로 바꾸는 것.** 다른 조각에 적힌 규칙을 보지 못한다.
- **묶음이나 별칭을 대상에 넣는 것, `riverpod.yaml` 을 `plugins:` 를 담은 채 복사하는 것.** 셋 다 0건 · exit 0 으로 끝나지만 plugin 을 준비해 10초와 네트워크가 든다.
- **세 코드만 골라 판정하는 것.** `rules:` 의 오타, 겹친 규칙, 깨진 YAML 이 통과로 찍힌다.
- **JSON 의 진단이 0건이면 옵션 파일이 멀쩡하다고 보는 것.** 깨진 YAML 은 `--format=json` 에도 `--format=machine` 에도 아무것도 찍지 않는다. 종료 코드를 함께 본다.
- **"규칙 0개" 확인을 모든 대상에 거는 것.** 규칙이 없는 `codegen.yaml` 이 헛실패한다. 반대로 이 확인을 없애면 `linter:` 의 오타를 잡을 수단이 없다.
- **루트에서 인자 없이 분석하고 복사본의 진단만 골라내는 것** (005 가 골랐던 방식). 루트 옵션 파일에 `example/**` 제외가 없으면 `example/` 의 진단이 섞이고 plugin 까지 준비해 15초와 네트워크가 든다. 제외가 있으면 결과는 같지만 그 제외에 기대게 된다.
- **include 로 받은 파일을 그대로 검사하는 것.** 문제 규칙 4개를 `shared.yaml` 에 적고 include 하면 `undefined_lint` 하나만 나온다 (`included_file_warning` 으로 include 줄에 보고된다). deprecated 와 removed 는 보고되지 않는다.
- **SDK tag 의 `rules.json` 을 규칙 상태의 근거로 삼는 것.** tag 3.13.4 의 `rules.json` 은 `unnecessary_await_in_return` 을 `stable` 로 적었지만 같은 tag 의 규칙 소스는 `state: .deprecated(since: .new(3, 13, 0))` 이고, 실제 동작은 규칙 소스를 따른다.
- **`plugins:` 를 담은 채 루트에서 인자 없이 분석하는 것.** `plugins_in_inner_options` 가 섞여 나온다 (005).
- **폴더 이름을 점으로 시작하게 짓는 것** (`.woody_rule_check/` 등). 분석되지 않는다.
- **error 강도의 옵션 파일 진단을 JSON 에서 찾는 것.** `dart analyze` 는 옵션 파일의 error 진단만 JSON 에서 빠뜨린다. 세 코드와 위 표의 warning 들은 해당하지 않는다. 깨진 YAML 의 `parse_error` (error) 가 JSON 에 나오지 않은 것이 이와 맞는다.

## Constraints

- **`deprecated_lint` / `removed_lint` 는 옵션 파일이 속한 패키지의 `pubspec.yaml` 이 선언한 SDK 하한이, 그 규칙이 deprecated / removed 된 버전 이상일 때만 보고된다.** pubspec 이 없으면 보고되지 않는다. `undefined_lint` 는 SDK 하한과 상관없이 보고된다.

  | 규칙 (상태가 바뀐 버전) | pubspec 의 `sdk` | 진단 |
  |---|---|---|
  | `unnecessary_await_in_return` (deprecated, 3.13.0) | `^3.12.0` | 없음 |
  | | `^3.13.0` | `deprecated_lint` |
  | `prefer_final_parameters` (deprecated, 3.11.0) | `^3.10.0` | 없음 |
  | | `^3.11.0` | `deprecated_lint` |
  | `avoid_returning_null` (removed, 3.3.0) | `^3.2.0` | 없음 |
  | | `^3.3.0` | `removed_lint` |
  | `unnecessary_await_in_return` | pubspec 없음 | 없음 |

- 그래서 이 검사의 민감도는 루트 `pubspec.yaml` 의 SDK 하한을 따른다. 하한이 `^3.13.0` 인 동안에는 3.14 에서 deprecated 될 규칙을 3.14 SDK 로 돌려도 잡지 못한다. 하한을 올리는 릴리스에서 새로 잡히는 규칙이 생길 수 있다.
- `unnecessary_await_in_return` 은 Dart 3.13.0 부터 deprecated 다. 규칙 후보에서 제외한 판정이 맞다.
- Dart 3.13.4 의 deprecated 규칙은 6개다: `avoid_null_checks_in_equality_operators`, `avoid_private_typedef_functions`, `one_member_abstracts`, `prefer_final_parameters`, `use_if_null_to_convert_nulls_to_bools`, `unnecessary_await_in_return`.
- **폴더를 인자로 준 분석은 그 폴더가 분석의 루트가 된다.** 복사본이 `plugins:` 를 직접 담든 include 로 닿든 plugin 을 준비한다 (`riverpod.yaml` 그대로, `recommended.yaml`, 별칭 — 셋 다 plugin 폴더 1, 10초). 저장소 루트에서 인자 없이 돌릴 때는 하위 옵션 파일의 `plugins:` 를 쓰지 않는다 (011) — 두 실행의 다른 점이다.
- 이것은 analyze-run-and-verdict.md 의 "하위 폴더를 인자로 주면 plugin 을 준비조차 하지 않는다" (001) 와 부딪치는 말이 아니다. 001 이 인자로 준 폴더(`lib`, `lib/src`)에는 옵션 파일이 없었고 옵션 파일은 그 위의 패키지 루트에 있었다. 여기서 인자로 준 폴더에는 `analysis_options.yaml` 이 **직접** 들어 있다. 두 실험에서 달랐던 조건을 적은 것이고, 그 조건 하나만 바꿔 원인을 가른 실험은 아니다.
- "규칙 0개" 확인(`countDeclaredRules`)은 글자를 센다. 최상위 `linter:` 블록 안의 `- 이름` 줄 수이고 analyzer 가 실제로 읽은 규칙 수가 아니다. 맵 문법(`이름: true`)으로만 적은 목록은 0 으로 센다 (`02-VERIFICATION.md` 가 적어 둔 가정이고 일으켜 보지 않았다). 배포 파일은 목록 문법이다.
- 복사 위치와 실행 형태별 결과 (한 파일 구조의 배포 파일에 문제 규칙 4개를 끼운 복사본):

  | 복사 위치와 실행 | 결과 | 근거 |
  |---|---|---|
  | 저장소 안, `plugins:` 를 뺌, **그 폴더를 인자로** | **4건만.** plugin 준비 없음, 0.5초. 루트 제외가 있든 없든 같다 (채택). `example/` 이 있고 그 패키지를 받은 상태에서 쟀다 | 007 (R2b, R3b) |
  | 저장소 안, `plugins:` 를 뺌, 루트에서 인자 없이 | 루트에 `example/**` 제외가 있으면 4건만, 0.5초. 없으면 `example/` 의 4건이 섞이고 plugin 을 준비한다 (15초) | 005, 007 (R3a, R2a) |
  | 저장소 안, `plugins:` 를 담은 채, 그 폴더를 인자로 | 4건만. 다만 plugin 을 준비한다 (11초, 네트워크) | 005 (4-6) |
  | 저장소 안, `plugins:` 를 담은 채, 루트에서 인자 없이 | 4건 + `plugins_in_inner_options` | 005 (4-3) |
  | 저장소 밖 임시 폴더 | `undefined_lint` 1건뿐 | 005 |

- 007 과 013 은 실행마다 빈 상태 폴더를 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 주고 쟀다. Phase 2 의 검증 명령은 규칙 검사에 상태 폴더를 주지 않는다 (plugin 을 준비하지 않으므로 버전을 읽을 일이 없다).
- 007 과 013 의 실험은 저장소의 모양을 작업 폴더에 복사한 replica 에서 했다. 실제 저장소에서 같은 명령을 돌린 것은 005 다 (4-2: `plugins:` 를 담은 원본 그대로의 복사본을 폴더 인자로 → 0건, exit 0). 013 은 `tool/verify.dart` 를 고쳐 돌린 것이 아니라 같은 형태의 실행을 흉내 낸 것이다.
- 요구 사항의 "`example/` 의 상태에 기대지 않는다"가 실측으로 받쳐지는 범위: `example/` 이 없을 때(005 의 4-2)와 `example/` 이 있고 그 패키지를 받았을 때(007). `example/` 은 있는데 패키지를 받기 전인 상태에서 폴더를 인자로 준 실행은 재지 않았다.
- 규칙 검사 전에 **루트의 패키지가 받아져 있었다.** 007 과 013 은 replica 루트에서 `dart pub get` 을 먼저 했고, 005 는 루트의 `.dart_tool/package_config.json` 이 이미 있는 상태였다. 루트의 패키지를 받지 않은 상태(CI 가 저장소를 새로 받은 직후)에서의 규칙 검사는 재지 않았다. 복사본의 `include: package:flutter_lints/flutter.yaml` 을 풀려면 루트의 패키지 설정이 있어야 할 것이다 (추정).
- 013 은 두 번 돌려 두 번 모두 같았고 판정 14건이 모두 성립했다.
- 확인하지 않은 것: GitHub Linux runner 에서 규칙 검사에 걸리는 시간, 위 두 항목의 재지 않은 상태, 깨진 입력을 사용 프로젝트 쪽(include 로 받는 쪽)에서 봤을 때의 진단을 나눈 구조에서 (한 파일 구조에서는 Phase 2 의 검증이 재현했다 — `included_file_warning`, 정답지의 `exit` 줄이 3).

## Origin

Synthesized from spikes: 005, 007, 013
Source files available in: sources/005-initial-file-rule-status/, sources/007-root-analysis-with-example/, sources/013-rule-check-after-split/
원본 로그: `.planning/spikes/005-initial-file-rule-status/results/probe.log`, `.planning/spikes/007-root-analysis-with-example/results/probe.log`, `.planning/spikes/013-rule-check-after-split/results/probe.log`
