# deprecated / removed / 없는 규칙 검사

배포 파일에 적힌 규칙 중 deprecated 됐거나, 삭제됐거나, 존재하지 않는 것이 있으면 검증을 실패시키는 부분이다 (VERIFY-02).

모든 수치는 Dart 3.13.4, 2026-10-11 실측이다.

## Requirements

MANIFEST.md 의 `verify-harness-tool-behavior` 에서 이 영역에 걸리는 것.

- deprecated / removed 규칙 검사에 쓰는 배포 파일 복사본은 **저장소 안**에 둔다. `deprecated_lint` / `removed_lint` 는 그 파일이 속한 패키지의 pubspec SDK 하한이 해당 버전 이상일 때만 보고되고, pubspec 이 없는 임시 폴더에서는 보고되지 않는다 (005)
- `lib/`, `pubspec.yaml`, 루트 `analysis_options.yaml` 은 바꾸지 않는다 (`lib/` 는 읽기만 한다)
- 검증 스크립트는 Dart 이고 `dart:io`, `dart:convert` 만 쓴다 (D-11)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 한다

## How to Build It

analyzer 는 규칙의 상태를 **`analysis_options.yaml` 이라는 이름의 파일에 직접 적힌 규칙**에 대해서만 온전히 보고한다. include 로 받은 파일에 적힌 규칙은 "없는 규칙"만 보고된다. 그래서 배포 파일을 그 이름으로 복사해 놓고 분석한다.

### 1. 복사본을 저장소 안에 만든다

- 자리: `build/woody_rule_check/analysis_options.yaml` 처럼 **점으로 시작하지 않는** 폴더. 점으로 시작하면 분석되지 않는다.
- 복사할 때 **`plugins:` 섹션을 뺀다.**

```python
# sources/005-initial-file-rule-status/probe.sh 의 4-4 에서 쓴 방식 (python3)
stripped = re.sub(r"(?m)^plugins:\n(?:[ \t]+.*\n)+", "", text)
assert stripped != text, "plugins: 섹션을 찾지 못했다"
```

spike 는 이 부분을 python3 으로 돌렸다. 검증 스크립트는 Dart 여야 하므로(D-11) 같은 패턴을 Dart 로 옮겨야 하고, 옮긴 형태는 아직 실행해 보지 않았다.

### 2. 저장소 루트에서 인자 없이 분석한다

```bash
# 저장소 루트에서
dart --suppress-analytics analyze --format=json
```

루트 `pubspec.yaml` 의 SDK 하한(`^3.13.0`)이 복사본에 적용된다. 이것이 저장소 안에 두는 이유다.

### 3. 복사본에 대한 진단만 골라 판정한다

JSON 의 `location.file` 이 복사본 경로인 진단 중 아래 셋이 하나라도 있으면 실패다.

| `code` | 뜻 | 강도 | 메시지 예 |
|---|---|---|---|
| `deprecated_lint` | deprecated 된 규칙 | warning | "The lint rule 'unnecessary_await_in_return' is deprecated and shouldn't be enabled." |
| `removed_lint` | 삭제된 규칙 | warning | — |
| `undefined_lint` | 없는 규칙 | warning | — |

줄 번호는 그 규칙을 적은 줄이다. 셋 다 warning 이라 JSON 에 나온다.

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

- 저장소에 `build/` 가 남지 않도록 `.gitignore` 에도 넣는다 (지금의 `.gitignore` 에는 없다).

### 5. 지금 상태

현재 배포 파일에 선언된 규칙 12개는 깨끗하다. 원본 그대로 복사해 분석하면 규칙 문제는 0건이고 `plugins_in_inner_options` 1건만 나온다 (`plugins:` 를 빼지 않았을 때).

### 6. 규칙 후보를 거르는 데에도 같은 방식을 쓴다 (Phase 4)

후보 규칙을 옵션 파일에 적고 고정 SDK 로 분석해 한 번 거른다. 규칙만 담은 순수 Dart 패키지를 만드는 함수가 `probe.sh` 의 `make_rules_package` 에 있다 (`pubspec.yaml` 에 `sdk: ^3.13.0` 을 적는 것이 핵심이다).

## What to Avoid

- **복사본을 저장소 밖 임시 폴더(`Directory.systemTemp`)에 두는 것.** deprecated 와 removed 를 놓치고 `undefined_lint` 만 잡힌다. 검사가 도는 것처럼 보이는데 반만 본다. 임시 폴더에는 pubspec 이 없어 SDK 하한이 없기 때문이다. `--packages` 로 패키지 설정을 넘겨도 같다.
- **include 로 받은 파일을 그대로 검사하는 것.** 문제 규칙 4개를 `shared.yaml` 에 적고 include 하면 `undefined_lint` 하나만 나온다 (`included_file_warning` 으로 include 줄에 보고된다). deprecated 와 removed 는 보고되지 않는다.
- **SDK tag 의 `rules.json` 을 규칙 상태의 근거로 삼는 것.** tag 3.13.4 의 `rules.json` 은 `unnecessary_await_in_return` 을 `stable` 로 적었지만 같은 tag 의 규칙 소스는 `state: .deprecated(since: .new(3, 13, 0))` 이고, 실제 동작은 규칙 소스를 따른다.
- **`plugins:` 를 담은 채 복사하는 것.** 둘 중 하나가 생긴다.
  - 루트에서 인자 없이 분석하면 `plugins_in_inner_options` 가 섞여 나온다 (걸러 내야 한다).
  - 그 폴더를 인자로 주면 plugin 을 준비한다 (11초 + 네트워크).
- **폴더 이름을 점으로 시작하게 짓는 것** (`.woody_rule_check/` 등). 분석되지 않는다.
- **error 강도의 옵션 파일 진단을 JSON 에서 찾는 것.** `dart analyze` 는 옵션 파일의 error 진단만 JSON 에서 빠뜨린다. 위 셋은 warning 이라 해당하지 않는다.

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
- Phase 3 에서 규칙이 `plugins:` 없는 `base.yaml` 로 옮겨 가면 `plugins:` 를 빼는 단계는 필요 없어진다.
- 복사 위치별 결과 (배포 파일에 문제 규칙 4개를 끼운 복사본):

  | 복사 위치와 실행 | 결과 |
  |---|---|
  | 저장소 안, 루트에서 인자 없이 | 4건 + `plugins_in_inner_options` |
  | 저장소 안, `plugins:` 를 뺌, 루트에서 인자 없이 | **4건만** (채택) |
  | 저장소 안, 그 폴더를 인자로 | 4건만. 다만 plugin 을 준비한다 (11초, 네트워크) |
  | 저장소 밖 임시 폴더 | `undefined_lint` 1건뿐 |

## Origin

Synthesized from spikes: 005
Source files available in: sources/005-initial-file-rule-status/
원본 로그: `.planning/spikes/005-initial-file-rule-status/results/probe.log`
