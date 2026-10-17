# Phase 3: Preset Split - Pattern Map

**Mapped:** 2026-10-12
**Files analyzed:** 17 묶음 (새로 만드는 파일 묶음 11, 고치는 파일 6)
**Analogs found:** 16 / 17

이 저장소는 설정 전용 패키지라 Dart 라이브러리 코드가 없다. 이 phase 가 만들거나 고치는 파일의 analog 는 거의 전부 **저장소 안에 이미 있는 같은 종류의 파일**이다 — 나누는 대상 `lib/analysis_options.yaml` (64행), 검증 명령 `tool/verify.dart` (1099행), 연습용 프로젝트 `example/` 과 그 README, 루트 `analysis_options.yaml`, `.gitignore`, `CHANGELOG.md`. 끄는 설정용 샘플과 `[2/N]` 의 새 판정만은 spike 012 · 013 의 실행된 스크립트(`.planning/spikes/…`, git 추적 대상)를 analog 로 쓴다. `.claude/skills/spike-findings-woody-lints/sources/` 는 같은 파일의 읽기용 사본이라 이 문서는 원본 경로(`.planning/spikes/…`)만 가리킨다.

모든 analog 경로는 `git ls-files` 로 추적 대상임을 확인했다 (2026-10-12). 줄 번호는 디스크의 파일에서 다시 읽은 것이다 — `tool/verify.dart` 는 `40776b5`, `example/README.md` 는 `008ea3f`, `lib/analysis_options.yaml` 은 `90a2736` 의 것과 같다.

**읽는 순서:** planner 는 § File Classification 으로 파일을 plan 에 배정하고, § Pattern Assignments 의 "복사할 것 / 바꿀 것" 을 plan 의 action 에 옮긴다. § Shared Patterns 는 여러 plan 에 걸친다. 03-RESEARCH.md 의 § "계획이 정해야 할 것 — 근거와 권고" 1 ~ 11 과 § "Code Examples" 1 ~ 8 이 **무엇을** 만들지를 정했고, 이 문서는 **어느 기존 코드의 모양을 따라** 만들지를 정한다. 둘이 다른 곳은 각 항목의 "차이와 권고" 에 적었다.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `lib/base.yaml` (new) | config (프리셋 조각 — 규칙) | — | `lib/analysis_options.yaml` 1 ~ 41행 + 59 ~ 64행 (잘라서 옮긴다) | exact (내용이 그대로다) |
| `lib/codegen.yaml` (new) | config (프리셋 조각 — analyzer errors / exclude) | — | `lib/analysis_options.yaml` 42 ~ 48행 | exact |
| `lib/riverpod.yaml` (new) | config (프리셋 조각 — plugin) | — | `lib/analysis_options.yaml` 49 ~ 58행 | exact |
| `lib/recommended.yaml` (new) | config (묶음 — include 목록) | — | 루트 `analysis_options.yaml` 1 ~ 6행 (한국어 머리 주석 + `include:` 꼴), 전문은 RESEARCH § Code Examples 2 | role-match (include 목록 꼴은 저장소에 선례 없음) |
| `lib/analysis_options.yaml` (modify → 별칭) | config (옛 주소의 별칭) | — | `example/analysis_options.yaml` (include 한 줄) + 루트 `analysis_options.yaml` 1 ~ 2행 (머리 주석) | exact |
| 루트 `analysis_options.yaml` (modify) | config (자체 분석) | — | 자기 자신 (1 ~ 15행), 새 전문은 RESEARCH § 권고 7 | exact |
| `fixtures/<이름>/pubspec.yaml` (new, 5개) | config (fixture manifest) | — | `example/pubspec.yaml` (16행) | exact (`name` 과 `path` 만 다름) |
| `fixtures/<이름>/pubspec.lock` (new, 5개) | config (생성물, 커밋) | — | `example/pubspec.lock` (270행 `path: ".."`) | exact (복사 뒤 `path` 한 줄) |
| `fixtures/<이름>/analysis_options.yaml` (new, 5개) | config (fixture options) | — | `example/analysis_options.yaml` (1줄), 전문은 RESEARCH § Code Examples 3 | exact |
| `fixtures/<이름>/lib/**` (new, 5 × 7파일) | fixture (위반 샘플 복사본) | — | `example/lib/**` 7파일 (`74fafb2`) | exact (`cp -R`) |
| `fixtures/overrides/lib/suppress/*.dart` (new, 5개) | fixture (끄는 설정 샘플) | — | `.planning/spikes/012-plugin-suppression-matrix/probe.dart` 27 ~ 67행 (샘플 본문), `example/lib/riverpod_rules.dart` 1 ~ 12행 (주석 관례) | exact (전문은 RESEARCH § Code Examples 4) |
| `fixtures/<이름>/expected_diagnostics.txt` (new, 4개) | test (정답지) | file-I/O | `example/expected_diagnostics.txt` (머리 주석 2줄 + `exit N` + 진단 줄) | exact (`--update` 가 만든다 — 손으로 쓰지 않는다) |
| `tool/verify.dart` (modify — C1 · C2 · C3) | script (검증 명령) | batch (프로세스 실행 → JSON 정규화 → 파일 비교) | 자기 자신 (아래 함수별 줄 범위) + `.planning/spikes/013-rule-check-after-split/probe.dart` 150 ~ 164행 · 205 ~ 221행 | exact |
| `example/README.md` (modify — C1 · C3) | doc (fixture 설명 + 지워 보기 기록) | — | 자기 자신 (30행, 81행, 91 ~ 101행 · 144 ~ 150행의 M 표, 154 ~ 158행의 "읽는 법") | exact |
| `.gitignore` (modify — C3) | config | — | 자기 자신 8 ~ 9행 | exact |
| `CHANGELOG.md` (modify — C2 · C4) | doc | — | 자기 자신 9 ~ 11행 (`### 그 밖의 변경`), 23행 (1.3.0 의 "사용하는 프로젝트에는 영향 없음" 선례) | exact |
| `.github/workflows/verify.yml` (modify — phase 끝의 docs 커밋, 25행 주석 한 줄만) | config (CI) | event-driven | 자기 자신 25행 | exact |

## Pattern Assignments

### `lib/base.yaml` · `lib/codegen.yaml` · `lib/riverpod.yaml` (config, 프리셋 조각)

**Analog:** `lib/analysis_options.yaml` (`90a2736`, 64행). 손으로 쓰지 않고 **줄 범위를 잘라** 만든다 (RESEARCH § 권고 8 의 대응표, Pattern 1).

**잘라 옮기는 명령 (C2 의 action 에 그대로):**
```bash
# 저장소 루트에서. 옛 파일은 아직 64행짜리 원본이어야 한다 (git diff --quiet 90a2736 -- lib 로 먼저 확인).
{ sed -n '1,41p' lib/analysis_options.yaml; sed -n '59,64p' lib/analysis_options.yaml; } > lib/base.yaml     # 47줄
sed -n '42,48p' lib/analysis_options.yaml > lib/codegen.yaml                                                   # 7줄
sed -n '49,58p' lib/analysis_options.yaml > lib/riverpod.yaml                                                  # 10줄
```

**조각의 경계 — 옛 파일의 실제 줄 (디스크에서 읽음):**
```yaml
# 13행 — base.yaml 13행. 조각 가운데 이 줄만 flutter_lints 를 include 한다
include: package:flutter_lints/flutter.yaml
# 20 ~ 21행 — base.yaml 20 ~ 21행. [2/N] 의 countDeclaredRules 가 이 블록을 센다
linter:
  rules:
# 40 ~ 41행 — base.yaml 40 ~ 41행. 마지막 규칙 + 빈 줄 (sed 1,41p 가 빈 줄까지 가져간다)
    - control_flow_in_finally # finally 블록 내 제어문 사용 금지

# 42 ~ 47행 — codegen.yaml 1 ~ 6행 (D-02: errors 한 줄과 exclude 두 패턴을 함께 옮긴다)
analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - '**/*.freezed.dart'
    - '**/*.g.dart'
# 48행 — codegen.yaml 7행 (빈 줄)

# 49 ~ 58행 — riverpod.yaml 1 ~ 10행. 설명 주석 8줄 + plugins: 2줄
# analyzer plugin (Dart 3.10+ analysis_server_plugin 방식) — 최상위 키.
# …(50 ~ 56행 그대로)…
plugins:
  riverpod_lint: ^3.1.3
# 59 ~ 64행 — base.yaml 42 ~ 47행 (빈 줄 + 템플릿 영어 주석 5줄)
```

**이어 붙여 원본과 견주는 단언 (C2 의 verify 에 그대로):**
```bash
{ sed -n '1,41p' lib/base.yaml; cat lib/codegen.yaml lib/riverpod.yaml; sed -n '42,47p' lib/base.yaml; } \
  | diff - <(git show 90a2736:lib/analysis_options.yaml)     # 출력 없음 = 옮기기만 했다
wc -l lib/base.yaml lib/codegen.yaml lib/riverpod.yaml        # 47 / 7 / 10
```

**지키는 것:**
- 조각 셋에는 **머리 주석을 더하지 않는다** (RESEARCH Pitfall 11). `base.yaml` 앞에 줄이 붙으면 규칙의 줄 번호가 밀려 `[2/N]` 의 안내 "복사본의 줄 번호는 원본과 같다" (`tool/verify.dart` 737행) 와 위 diff 단언이 깨진다.
- `riverpod.yaml` 10행만 C4 에서 `^3.1.9` 로 바뀐다. 1 ~ 8행의 설명 주석(낡은 문장 포함)은 Phase 5 의 일이다.
- `codegen.yaml` 의 두 패턴은 plugin 진단에는 통하지 않는다 (spike 012). 성공 기준 3 은 "Dart 3.13.4 의 규칙 진단 기준" 으로 범위를 적는다 — 새 주석 · 문서에 "전부 막는다" 로 옮기지 않는다 (RESEARCH Pitfall 8).

---

### `lib/recommended.yaml` (config, 묶음) · `lib/analysis_options.yaml` (config, 별칭)

**Analog (머리 주석 꼴):** 루트 `analysis_options.yaml` 1 ~ 2행
```yaml
# 이 저장소 자체를 분석할 때만 쓰는 설정 (사용하는 프로젝트에는 전달되지 않는다 —
# 프로젝트는 lib/analysis_options.yaml 을 include 한다).
```
— "이 파일이 무엇이고 누가 받는가" 를 한국어 두 줄로 파일 맨 위에 적는 꼴. 영어 식별자 뒤 조사는 한 칸 띄운다 (`lib/analysis_options.yaml 을`).

**Analog (include 한 줄):** `example/analysis_options.yaml` 1행
```yaml
include: package:woody_lints/analysis_options.yaml
```

**전문 (RESEARCH § Code Examples 2 — 이 주석을 단 채로 재어 정답지 16줄 그대로였다):**
```yaml
# lib/recommended.yaml
# woody_lints 묶음 — 기본 규칙 + Riverpod plugin + 코드 생성 설정을 한 번에 받는다.
# 조각을 골라 받으려면 아래 셋 가운데 필요한 것만 include 한다.
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml
  - package:woody_lints/codegen.yaml
```
```yaml
# lib/analysis_options.yaml (3줄 — 주석 2 + include 1)
# 옛 주소 (package:woody_lints/analysis_options.yaml) 의 별칭 — 묶음(recommended.yaml) 과 같다.
# 새 프로젝트는 package:woody_lints/recommended.yaml 을 include 한다.
include: package:woody_lints/recommended.yaml
```

**지키는 것:** include 는 `package:` 주소로 쓴다 (상대 경로도 통하지만 선례가 `package:` 다 — skill 요구 사항). 조각은 서로를 include 하지 않는다. 묶음 · 별칭은 `[2/N]` 의 대상에 넣지 않는다 (plugin 을 준비한다 — spike 013 K4 · K5).

**차이와 권고:** 02-PATTERNS.md 는 fixture 옵션 파일에 "주석도 두지 않는다" 고 했다. 그것은 `[3/N]` 이 견주는 **fixture 쪽** 파일의 말이고, 배포 파일인 묶음 · 별칭에는 RESEARCH 가 주석을 단 채로 쟀으므로 주석을 단다.

---

### 루트 `analysis_options.yaml` (config, 자체 분석)

**Analog:** 자기 자신 (15행). 지금 모양:
```yaml
# 1 ~ 6행 — 머리 주석 + include (include 는 그대로 둔다)
include: package:flutter_lints/flutter.yaml
# 8 ~ 15행 — 지금의 exclude 둘
analyzer:
  exclude:
    - lib/analysis_options.yaml      # 14행 — C2 에서 지운다 (PRESET-06). C1 에서 지우면 exit 2 (spike 011)
    - 'example/**'                   # 15행 — 그대로. C3 에서 'fixtures/**' 를 아래에 더한다
```

**새 전문:** RESEARCH § 권고 7 의 YAML 을 그대로 쓴다 (C2 시점에는 `fixtures/**` 줄 없이, C3 에서 더한다). 4 ~ 5행 · 8 ~ 10행의 지금 주석은 나눈 뒤 사실이 아니거나 SDK 에 묶인 말이라 권고 7 의 문장으로 바꾼다 — "plugin 을 준비하지 않도록" 을 이유로 적지 않는다 (spike 016).

**단언:** C2 뒤 `fvm dart analyze` (루트) → exit 0 · 0건 · `.dart_tool/` 아래 plugin 폴더 없음.

---

### `fixtures/<이름>/pubspec.yaml` (config, fixture manifest) × 5

**Analog:** `example/pubspec.yaml` (16행 전문)
```yaml
name: woody_lints_example
description: woody_lints 검증용 연습 프로젝트 — 일부러 규칙을 어긴 코드로 기대 진단을 고정한다.
publish_to: 'none'
version: 0.0.0

environment:
  sdk: ^3.13.0

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.0

dev_dependencies:
  # 저장소 루트의 woody_lints 를 그대로 받는다 (사용 프로젝트의 git 의존성 자리).
  woody_lints:
    path: ..
```

**바꿀 것 (RESEARCH § 권고 1 — scratch 에서 다섯 모두 `--enforce-lockfile` exit 0):** 1행 `name: woody_lints_fixture_<이름>`, 2행 `description` 에 그 fixture 가 증명하는 것 한 줄 (D-03 표의 "증명하는 것"), 17행 `path: ../..`. 나머지는 글자 그대로. `flutter_riverpod` 은 plugin 을 쓰지 않는 fixture(`base_only`, `base_codegen`)에도 둔다 — 샘플 `lib/riverpod_rules.dart` · `lib/main.dart` 가 import 하므로 빼면 error 가 섞인다. workspace 멤버로 만들지 않는다 (`resolution: workspace` 를 적지 않는다).

---

### `fixtures/<이름>/pubspec.lock` (config, 커밋하는 생성물) × 5

**Analog:** `example/pubspec.lock` — `woody_lints` 항목의 경로 줄 (270행):
```yaml
      path: ".."
```
**만드는 법:** `cp example/pubspec.lock fixtures/<이름>/pubspec.lock` 뒤 270행만 `path: "../.."` 로. lock 에는 루트 패키지 이름이 없어 `name:` 변경과 어긋나지 않는다 (RESEARCH § 권고 1). 그 뒤 `fvm dart pub get --no-example --enforce-lockfile` 이 fixture 폴더에서 exit 0 이어야 한다 (`tool/verify.dart` 의 준비 4 가 같은 명령으로 돈다, 1012 ~ 1018행).

---

### `fixtures/<이름>/analysis_options.yaml` (config, fixture options) × 5

**Analog:** `example/analysis_options.yaml` (1줄, 주석 없음)
```yaml
include: package:woody_lints/analysis_options.yaml
```
**전문:** RESEARCH § Code Examples 3. `recommended` · `base_only` 는 한 줄, `base_riverpod` · `base_codegen` 은 `include:` 목록 셋 줄, `overrides` 는 묶음 + `linter: rules: prefer_final_locals: false` + `plugins: riverpod_lint: {version: ^3.1.3, diagnostics: {missing_provider_scope: false}}` (C4 에서 `^3.1.9`).

**지키는 것:** `[3/N]` 이 "주석 · 빈 줄을 뺀 줄" 을 `trim()` 해 견주므로 (`tool/verify.dart` 757 ~ 766행) 목록 항목의 들여쓰기는 자유지만, `overrides` 의 한국어 주석은 `#` 줄로만 둔다. `flutter pub get` 을 돌리지 않는다 (`build/**` 제외가 써넣어진다 — `example/README.md` 32행).

---

### `fixtures/<이름>/lib/**` (fixture, 샘플 복사본) × 5

**Analog:** `example/lib/` 7파일 (`added_rules.dart`, `base_rules.dart`, `main.dart`, `riverpod_rules.dart`, `should_not_appear.dart`, `generated/sample.g.dart`, `generated/sample.freezed.dart`, 마지막 변경 `74fafb2`).

**만드는 법:** `cp -R example/lib fixtures/<이름>/lib` — 글자 그대로 복사해야 정답지의 줄 번호가 `example/` 과 같다 (RESEARCH § 권고 11 의 전문이 그 전제다). `recommended` 는 `example/` 의 결과와 견주므로 복사본이 어긋나면 `[5/9]` 가 잡는다. 나머지 넷은 처음 `--update` 로 쓴 정답지를 § 권고 11 의 전문과 눈으로 견준다 (C3 의 verify).

---

### `fixtures/overrides/lib/suppress/*.dart` (fixture, 끄는 설정 샘플) × 5

**Analog (본문):** `.planning/spikes/012-plugin-suppression-matrix/probe.dart` 27 ~ 67행 — spike 가 실제로 돌려 여섯 칸을 잰 샘플 문자열. 전문은 RESEARCH § Code Examples 4 (`lint_line.dart`, `lint_file.dart`, `plugin_line.dart`, `plugin_file_prefixed.dart`, `plugin_file_unprefixed.dart`). 줄 번호(`lint_line.dart:6`, `plugin_line.dart:11` · `:13`, `plugin_file_unprefixed.dart:8`)는 그 전문 기준이므로 글자 그대로 옮긴다.

**Analog (주석 관례):** `example/lib/riverpod_rules.dart` 1 ~ 12행
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `avoid_public_notifier_properties` (riverpod_lint, info) — Notifier 에 public 필드를 둔다.
class PublicFieldNotifier extends Notifier<int> {
  /// 바깥에서 보이는 필드.
  int publicField = 0;
```
— 선언마다 `///` 문서 주석으로 "어느 규칙을 어떻게 어기는가" 를 한국어로 적는다 (`slash_for_doc_comments` 가 켜져 있어 `/** */` 는 쓰지 않는다).

**지키는 것 (D-04, RESEARCH Pitfall 5):** 주석으로 끄는 칸의 규칙(`prefer_single_quotes`)과 plugin 진단(`provider_parameters`)은 프로젝트 전체에서 끄는 것(`prefer_final_locals`, `missing_provider_scope`)과 **다른 것**이어야 대조 줄이 남는다. 접두사 없는 `// ignore: provider_parameters` · `// ignore_for_file: provider_parameters` 는 꺼지지 않는 모양을 정답지에 고정하는 샘플이다 — "버그" 로 고치지 않는다.

---

### `fixtures/<이름>/expected_diagnostics.txt` (test, 정답지) × 4

**Analog:** `example/expected_diagnostics.txt` 1 ~ 5행
```text
# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12
# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: fvm dart run tool/verify.dart --update
exit 2
lib/added_rules.dart:13  info  prefer_const_literals_to_create_immutables
lib/added_rules.dart:18  info  always_declare_return_types
```

**만드는 법:** 손으로 쓰지 않는다. C3 에서 `fvm dart run tool/verify.dart --update` 가 넷을 한 번에 쓴다 (`writeExpected`, `tool/verify.dart` 532 ~ 560행 — 정답지가 없으면 `# 실측:` 과 `# 형식:` 두 줄을 넣는다, 540 ~ 543행). plugin 을 쓰지 않는 `base_only` · `base_codegen` 의 머리 주석은 `riverpod_lint 해당 없음` (RESEARCH § 권고 4). 쓴 결과는 RESEARCH § 권고 11 의 전문(18 / 21 / 13 / 18줄)과 견준다. `recommended` 는 파일을 두지 않는다 (RESEARCH Pitfall 12).

---

### `tool/verify.dart` (script, batch) — C1 · C2 · C3 에서 고친다

analog 는 자기 자신이다. 아래는 **지금 코드의 자리와 바꾸는 방향**이다. 함수의 모양(`StepResult` 를 돌려주고 `detailLines` 에 "무엇이 틀렸나 + 다음에 할 일" 을 적는 꼴)은 그대로 둔다.

#### C1 — `[2/N]` 의 판정 넓히기 (checkRuleNames, 648 ~ 745행)

**지금의 판정 순서 (669 ~ 722행):**
```dart
    if (lines == null || !analyzeExitCodes.contains(result.exitCode)) {   // 669행 — 도구 사망 (그대로)
      …
    final unresolved = lines                                                // 687 ~ 701행 — include_file_not_found (그대로)
        .where((l) => l.endsWith('  $includeNotFoundCode'))
    …
    if (countDeclaredRules(copy) == 0) {                                    // 705 ~ 717행 — 규칙 0개 (문구만 바꾼다)
      …
          '`$shippedOptionsPath` 에서 규칙을 하나도 읽지 못했다 — '
              '최상위 `linter:` 아래 `rules:` 목록이 비어 있거나 없다.',       // 710 ~ 711행 — 코드는 rules: 를 보지 않으므로
                                                                             //   "`linter:` 블록 안에서 `- 규칙이름` 줄을 하나도 세지 못했다" 로
    final problems = lines                                                  // 719 ~ 722행 — 세 코드만 고른다 → 여기가 구멍
        .where((l) => ruleProblemCodes.any((code) => l.endsWith('  $code')))
        .toList();
    if (problems.isEmpty) return StepResult(label: label, passed: true);
```

**끼워 넣을 가지 둘 (RESEARCH § 권고 6, § Code Examples 5):**
1. 669행의 도구 사망 가지 **바로 뒤**에 "깨진 옵션 파일" 가지 — `result.exitCode == 3 && lines.isEmpty` 이면 실패. 원인 줄은 같은 폴더를 형식 인자 없이 한 번 더 돌려 `parse_error` 를 담은 줄만 고른다. 재실행의 모양은 spike 013 `probe.dart` 208 ~ 220행 (아래) — 거기서는 `--format=machine` 이었고, RESEARCH 는 형식 인자 없이 돌린 출력(`error - analysis_options.yaml:47:8 - While parsing a block collection, expected '-'. - parse_error`)을 보였다. 어느 쪽이든 `parse_error` 문자열을 담은 줄을 고르면 된다.
   ```dart
   // .planning/spikes/013-rule-check-after-split/probe.dart 208 ~ 220행
   if (run.exitCode == 3 && run.lines.isEmpty) {
     // JSON 에 아무것도 없는데 exit 3 이다 — 같은 입력을 기계용 출력으로 한 번 더 돌려 본다.
     …
     final machine = await Process.run(
       Platform.resolvedExecutable,
       ['--suppress-analytics', 'analyze', '--format=machine', ruleCheckDir],
       workingDirectory: root,
       …
     final out = replica.scrub('${machine.stdout}${machine.stderr}'.trim());
   ```
   검증 명령에서는 `scrubPaths(…, repoRoot)` (436 ~ 443행) 로 경로를 가리고, 상태 폴더 환경변수는 주지 않는다 (규칙 검사는 plugin 을 준비하지 않는다, 657행 주석).
2. 722행의 `if (problems.isEmpty) return passed` 를 **`if (lines.isNotEmpty) return failed`** 로 — 세 코드는 지금처럼 `readRuleNameAt` (607 ~ 615행) 로 `(규칙이름)` 을 덧붙이고, 그 밖의 코드(`unsupported_option`, `duplicate_rule`, `unrecognized_error_code`)는 줄 그대로 "배포 파일의 옵션 경고" 로 보인다. 통과는 "exit 0 이고 진단 0건" 하나다.

**단언 (C1 의 verify):** 입력 A · B · C (RESEARCH § 권고 6 의 표) 를 `lib/analysis_options.yaml` 에 하나씩 넣고 `--update` → 셋 다 exit 1, `[2/4] 실패`, `다른 단계가 실패해 정답지를 쓰지 않았다`, `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt` 통과. 되돌린 뒤 보통 실행 exit 0. 이 결과를 `example/README.md` 의 M15 ~ M17 로 적는다.

#### C2 — 규칙 검사 대상을 조각 셋으로 (상수 38 · 53행, stripPlugins 595 ~ 604행, checkRuleNames 650 ~ 663행)

**지금:**
```dart
/// 규칙이 적힌 배포 파일 (저장소 루트 기준). 읽기만 한다.
const shippedOptionsPath = 'lib/analysis_options.yaml';          // 38행 → ruleCheckTargets 셋 + rulesFile = 'lib/base.yaml'

String stripPlugins(String options) {                             // 595 ~ 604행
  final stripped = options.replaceAll(
    RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true),
    '',
  );
  if (stripped == options) {                                      // 600행 — "못 찾으면 예외" → 별칭에서 exit 70 (scratch 실측)
    throw const FormatException('$shippedOptionsPath 에서 `plugins:` 섹션을 찾지 못했다');
  }
  return stripped;
}

  final copy = stripPlugins(                                      // 650 ~ 652행 — 파일 하나를 복사
    File('$repoRoot/$shippedOptionsPath').readAsStringSync(),
  );
    File('${checkDir.path}/analysis_options.yaml').writeAsStringSync(copy);   // 656행
```

**바꾸는 방향 (RESEARCH § 권고 5, § Code Examples 6):**
- `stripPlugins` 는 "있으면 뺀다" 로 — `stripped == options` 검사를 지우고, 뺀 뒤에도 `^plugins:` 가 남아 있을 때만 `FormatException` (패턴이 섹션을 놓친 경우를 조용히 넘기지 않는다). `shownAs` 인자를 받아 예외 문구에 파일 이름을 적는다.
- 복사는 `build/woody_rule_check/{base,codegen,riverpod}/analysis_options.yaml` 셋 (spike 013 `probe.dart` 150 ~ 155행의 K7 모양):
  ```dart
  final k7 = await ruleCheck('K7', '조각마다 하위 폴더에 복사해 한 번에 (base/, riverpod/ — plugins: 는 뺌)', {
    'base/analysis_options.yaml': withProblems,
    'riverpod/analysis_options.yaml': strippedRiverpod,
  });
  ```
  폴더 인자(`ruleCheckDir`, 662행)는 그대로 — 하위 폴더 셋이 한 번에 분석된다. 진단의 경로에 조각 이름이 들어가므로 (`build/woody_rule_check/riverpod/analysis_options.yaml:12`) `readRuleNameAt` 은 그 조각의 복사본 줄 목록을 봐야 한다 (지금은 `copyLines` 하나, 724행).
- `countDeclaredRules == 0` 확인은 `base.yaml` 복사본에만 (705행). 실패 문구의 `$shippedOptionsPath` (710 · 736행) 는 `lib/base.yaml` 로.
- 집합 확인 하나를 더한다: `lib/*.yaml` 이 정확히 `{analysis_options, base, codegen, recommended, riverpod}` 인지. `checkLibHasNoDart` (565 ~ 588행) 의 `listSync` + `relativize` 꼴을 그대로 쓴다.
- 이 변경은 `lib/` 를 나누는 커밋과 **같은 커밋**이어야 한다 — 따로 두면 그 사이에서 exit 70 (RESEARCH § 권고 9).

#### C3 — fixture 표 · 단계 9개 · `--update` 일괄 (상수 35행, checkFixtureOptions 751 ~ 785행, compareFixture 794 ~ 924행, readPluginVersion 413 ~ 433행, main 1012 ~ 1078행)

**fixture 목록 (35행) → 레코드 표:**
```dart
/// 정답지와 견줄 연습용 프로젝트 폴더들 (저장소 루트 기준).
const fixtures = ['example'];                                     // 35행 → RESEARCH § Code Examples 1 의 `Fixture` 레코드 목록
```
`Fixture(path, label, optionsLines, usesPlugin, expectedPath)` 는 `StepResult` (166 ~ 202행) 와 같은 꼴 — 생성자 인자마다 `///` 한 줄. 순서는 example → recommended → base_only → base_riverpod → base_codegen → overrides (`recommended` 는 `example` 뒤).

**옵션 파일 검사 (751 ~ 785행) — 한 줄 상수에서 줄 목록으로:**
```dart
const fixtureIncludeLine = 'include: package:woody_lints/analysis_options.yaml';   // 53행 → Fixture.optionsLines 로 옮긴다

  final rest = file.existsSync()                                   // 757 ~ 763행 — 주석·빈 줄 제거는 그대로
      ? file
            .readAsLinesSync()
            .map((l) => l.trimRight())
            .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'))
            .toList()
      : null;
  if (rest != null &&
      rest.length == 1 &&
      rest.single.trim() == fixtureIncludeLine) {                  // 764 ~ 766행 → rest.map(trim) 과 optionsLines 를 통째로 견준다
```
`[3/9]` 는 여섯 파일을 한 단계에서 보고, 실패하면 파일별로 "어떻게 다른지" 를 `detailLines` 에 적는다 (776 ~ 782행의 안내 꼴 — "되돌린다: … / `flutter pub get` 을 돌렸다면: git checkout -- …").

**정답지 비교 (794 ~ 924행) — 그대로 두는 것과 바꾸는 것:**
```dart
  final stateDir = '$repoRoot/.dart_tool/woody_verify/$fixture';  // 802행 — 그대로. fixture = 'fixtures/base_only' 면
                                                                   //   .dart_tool/woody_verify/fixtures/base_only/ (createSync recursive)
  final plugin = readPluginVersion(stateDir, shownAs: shownStateDir);   // 813행 → usesPlugin 이 false 면 부르지 않고
                                                                         //   PluginVersion.notApplicable (text '해당 없음')
  if (outcome.hasPluginHeader) {                                   // 816행 — 판정 1 (그대로)
  if (actual == null || !analyzeExitCodes.contains(outcome.exitCode)) {   // 838행 — 판정 2 (그대로)
  final expectedFile = File('$fixtureDir/$expectedFileName');      // 858행 → expectedPath 가 null 이면 (recommended) example 단계의
  final expected = expectedFile.existsSync() ? Expected.read(expectedFile) : null;   //   실제 결과(lines + exitCode)를 기대값으로 쓴다
  if (update) {                                                    // 865 ~ 894행 — 갱신 가지. detailLines 의 '- ' / '+ ' 꼴과
                                                                   //   applyUpdate 지연 쓰기는 그대로. recommended 는 applyUpdate 를 두지 않는다
      passed: true,                                                // 872행 — 갱신 모드의 "늘 통과" 는 그대로 (안전장치는 다른 단계의 실패가 맡는다)
```
`recommended` 가 `example` 의 결과를 받으려면 `compareFixture` 가 `AnalyzeOutcome` (또는 `actual` + `exitCode`) 을 돌려주는 자리가 필요하다 — `StepResult` 에 필드를 하나 더하거나(`plugin` 처럼, 188행), `main` 의 루프에서 직전 결과를 넘긴다. 둘 중 어느 쪽이든 `StepResult` 의 `///` 주석 꼴을 따른다.

**plugin 버전 (148 ~ 163행, 413 ~ 433행):**
```dart
class PluginVersion {
  PluginVersion.resolved(String this.version) : reason = null;    // 150행
  PluginVersion.unknown(String this.reason) : version = null;     // 153행 → notApplicable 생성자를 더한다. text 는 '해당 없음'
  String get text => version ?? '?';                              // 162행
```
`readPluginVersion` 의 "폴더 0개 → `?` + 이유" (415 ~ 420행) 는 `usesPlugin: true` 인 fixture 에서만 돈다. 화면 맨 위 `plugin` 줄은 `main` 1044 ~ 1046행 (`firstOrNull`) 을 "plugin 을 쓰는 fixture 의 값이 모두 같으면 그 값" 으로 바꾼다 (RESEARCH § 권고 4). 1041 ~ 1042행 주석이 이미 "fixture 가 늘어 값이 갈릴 수 있게 되면 … Phase 3" 라고 적어 두었다.

**단계 목록과 화면 (1022 ~ 1034행, 1055 ~ 1057행):**
```dart
    final steps = <Future<StepResult> Function()>[
      () async => checkLibHasNoDart(repoRoot),                     // [1/9]
      () => checkRuleNames(repoRoot),                              // [2/9]
      for (final fixture in fixtures) ...[                         // → [3/9] 옵션 파일 여섯을 한 단계로, [4/9] ~ [9/9] fixture 마다 한 줄
        () async => checkFixtureOptions('$repoRoot/$fixture'),
        () => compareFixture(…),
      ],
    ];
    …
      stdout.writeln(formatStepLine(i + 1, results.length, results[i]));   // 1056행 — 결과 단어는 formatStepLine (942 ~ 947행) 의
                                                                           //   '통과' / '실패'. --update 의 정답지 단계만 '바뀐 줄 없음' / '갱신'
```
`formatStepLine` 의 `resultColumn` (76행, 40) 은 CONTEXT 미리보기의 점 자리와 맞는지 라벨이 가장 긴 `overrides (끄는 설정)` 로 확인한다 (`measureWidth` 가 한글을 2칸으로 센다, 927 ~ 939행).

**`--update` 일괄 쓰기 (1063 ~ 1078행) — 이미 여럿을 받는 꼴이다:**
```dart
    final failed = results.where((r) => !r.passed).toList();
    final updaters = results.where((r) => r.applyUpdate != null).toList();
    if (updaters.isNotEmpty) {
      stdout.writeln('');
      if (failed.isNotEmpty) {
        stdout.writeln('다른 단계가 실패해 정답지를 쓰지 않았다 — 실패를 먼저 고친 뒤 다시 실행하세요.');
      } else {
        for (final result in updaters) {
          result.applyUpdate!();
          stdout.writeln('정답지를 썼다: ${result.updateTarget}');   // → 미리보기의 "정답지를 썼다 (N개):" + 목록 꼴로
        }
      }
    }
```
D-05 의 "하나라도 이상하면 어느 정답지도 쓰지 않는다" 는 이 코드가 이미 그렇게 돈다 — `failed` 가 비어 있을 때만 전부 쓴다. 바꾸는 것은 화면 꼴("썼다 (2개):" + 경로 목록)과 "바뀐 줄 없음" 인 fixture 는 쓰지 않는 선택이다 (지금은 같아도 머리 주석의 날짜를 새로 쓴다, 868행 · 884행 — 미리보기의 `바뀐 줄 없음` 과 `정답지를 썼다 (2개)` 가 "바뀐 것만 쓴다" 를 뜻하므로 그쪽으로 맞춘다).

**파일 머리 주석 (1 ~ 22행):** 단계 목록(3 ~ 6행)과 `--update` 설명(9행 `정답지(example/expected_diagnostics.txt)`)을 9단계 · 정답지 다섯으로 고친다. 종료 코드 줄(21 ~ 22행)은 그대로.

---

### `example/README.md` (doc) — C1 · C3

**Analog:** 자기 자신. 고칠 자리와 지금 문장 (디스크에서 읽음):

- **30행** (`--update` 안전장치): `- 같은 실행에서 다른 단계(`[1/4]` ~ `[3/4]`)가 실패했으면 정답지를 쓰지 않고 …` → 번호를 박지 않고 "다른 단계가 실패했으면" 으로 (C1). 끝의 "(아래 M12)" 꼴로 새 기록 번호를 단다.
- **81행** (단계 설명): `단계는 네 개다: `[1/4]` … `[2/4]` 는 배포 파일에서 규칙을 하나도 읽지 못하면(최상위 `linter:` 아래 `rules:` 목록이 비어 있거나 없으면) 실패한다 — …` → C1 에서 `[2/4]` 의 실제 판정("복사본의 종료 코드가 0 이 아니거나 진단이 하나라도 있으면 실패. 깨진 YAML 은 exit 3 + 진단 0건으로 따로 알린다. `base.yaml` 에서 규칙을 하나도 세지 못해도 실패") 으로, C3 에서 "단계는 아홉 개다" 로.
- **3행 · 5행** (`lib/analysis_options.yaml` 을 배포 파일로 부르는 문장): C2 뒤에는 규칙이 `lib/base.yaml` 에 있다 — "배포 파일 `lib/analysis_options.yaml` 을 고쳤을 때" 를 "배포 파일(`lib/base.yaml` 등)을" 로.
- **36 ~ 47행** (파일 표): `lib/generated/…` 행의 "배포 파일이 분석에서 빼므로 **나오면 안 된다**" 는 그대로 맞다 (규칙 위반만 담은 샘플). C3 에서 "연습용 프로젝트 여섯" 표를 D-03 의 표(폴더 · include · plugin 유무 · 정답지 · 줄 수 · 증명하는 것)로 더한다.
- **74행** (종료 코드 표의 `0 | 단계 4개 모두 통과`): 9개로.

**지워 보기 기록 — 표 한 행의 꼴 (M12 · M13, 148 ~ 149행):**
```markdown
| M12 | `example/analysis_options.yaml` 을 빈 파일로 두고 `--update` 로 실행 | `[3/4]`. `[4/4]` 는 갱신 모드라 통과로 찍힌다 | 정답지를 쓰지 않았다 (파일의 git hash 가 실행 전과 같다). 화면: `다른 단계가 실패해 정답지를 쓰지 않았다 — 실패를 먼저 고친 뒤 다시 실행하세요.` | 1 | D-14 — 망가진 실행의 `--update` (WR-01 case 1) |
| M13 | `lib/analysis_options.yaml` 의 `linter:` 를 `lintr:` 로 바꿈 | `[2/4]` 과 `[4/4]` | `[2/4]` 가 낸 줄: `` `lib/analysis_options.yaml` 에서 규칙을 하나도 읽지 못했다 — … `` <br>`[4/4]`: `- ` 이 패키지가 추가하는 규칙 6줄 | 1 | VERIFY-02 — 규칙 0개 (WR-03 의 절반) |
```
열은 `# | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목` (91 · 144행). 새 소절은 138 ~ 142행의 꼴 — `### 추가 실측 — <무엇> (gap 닫기 NN)` 제목, `실측 (NN): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12` 한 줄, `실행한 명령:` 한 줄, 표, 그 아래 "읽는 법" 불릿 (154 ~ 158행 — **굵은 첫 문장** + 근거), 끝에 "변경은 모두 커밋하지 않고 되돌렸다 (`git status` … 로 확인)" (160행).

- C1: M15 ~ M17 (입력 A · B · C — "고치기 전: `--update` exit 0 · 정답지 씀 / 고친 뒤: `[2/4]` 실패 · exit 1 · 정답지 불변"). 155행의 "M12 도 고치기 전에는 정답지를 덮어썼다" 가 같은 꼴의 선례다.
- C3: M18 (`lib/recommended.yaml` 에서 `- package:woody_lints/riverpod.yaml` 을 지우면 `example` 과 `recommended` 가 함께 실패), M19 (`fixtures/overrides/analysis_options.yaml` 의 `version:` 줄을 지우면 `missing_provider_scope` 가 되살아나 `overrides` 가 실패). 둘 다 실행해 적는다 — 예측을 실측처럼 적지 않는다.

---

### `.gitignore` (config) — C3

**Analog:** 자기 자신 5 ~ 9행 — "이유 주석 + 패턴" 꼴
```gitignore
# Avoid committing pubspec.lock for library packages; see
# https://dart.dev/guides/libraries/private-files#pubspeclock.
pubspec.lock
# example/ 은 검증용 앱이라 lock 을 커밋한다 — 로컬과 CI 가 같은 패키지 버전으로 판정한다.
!example/pubspec.lock
```
**더하는 줄 (9행 바로 아래, RESEARCH § Code Examples 8):**
```gitignore
# fixtures/ 의 연습용 프로젝트도 example/ 과 같은 이유로 lock 을 커밋한다.
!fixtures/*/pubspec.lock
```
**단언:** `git check-ignore -v fixtures/base_only/pubspec.lock` 이 `.gitignore:11:!fixtures/*/pubspec.lock` 꼴을 찍는다 (scratch 에서 확인된 동작).

---

### `CHANGELOG.md` (doc) — C2 · C4

**Analog:** 자기 자신 9 ~ 11행 (`### 그 밖의 변경` — 이 phase 는 규칙을 넣고 빼지 않으므로 여기에 적는다) 과 23행 (1.3.0 의 "사용하는 프로젝트에는 영향 없음" 꼴):
```markdown
### 그 밖의 변경

- 저장소 안에 검증용 `example/` 프로젝트, 검증 명령 `tool/verify.dart`, GitHub Actions workflow 를 추가. 사용하는 프로젝트에는 영향 없음.
```
```markdown
- 저장소 자체 분석용 루트 `analysis_options.yaml` 추가 — `lib/analysis_options.yaml` 의 `plugins:` 가 … 경고를 제외한다. 사용하는 프로젝트에는 영향 없음.
```
**더하는 불릿 (RESEARCH § "CHANGELOG 2.0.0 항목"):** C2 에 둘 — 프리셋을 `base.yaml` / `riverpod.yaml` / `codegen.yaml` / `recommended.yaml` 로 나눔(minor) · 옛 주소 `analysis_options.yaml` 은 묶음의 별칭이라 받는 구성이 같음. C4 에 하나 — `riverpod_lint` 하한 `^3.1.3` → `^3.1.9` (같은 major 안이라 minor. 2026-10-12 에 두 선언 모두 3.1.9 로 풀려 경고가 달라지지 않음). 불릿 뒤에 "사용하는 프로젝트에는 영향 없음" 또는 "달라지는 것 없음" 을 명시한다. `### 올리기 전에` (5 ~ 7행) 에 "옛 주소 한 줄을 쓰는 프로젝트는 고칠 것이 없다" 한 줄을 더할 수 있다. `### 새로 생기는 경고` (13 ~ 15행) 는 Phase 4 의 자리 — 건드리지 않는다.

---

### `.github/workflows/verify.yml` (config, CI) — phase 끝의 docs 커밋만

**Analog:** 자기 자신 25 ~ 26행
```yaml
    # 정상 약 2분 (spike 006). 멈춰 있는 경우만 막는다.
    timeout-minutes: 10
```
YAML 은 바꾸지 않는다 (`git diff --quiet 008ea3f -- .github/workflows/verify.yml`). C3 push 뒤 첫 `verify` 실행의 실제 job 시간을 보고 25행 주석만 "정상 약 N분 (연습용 프로젝트 여섯, 2026-10-12 실측 run <id>)" 로 고친다 (RESEARCH § 권고 10). 6분을 넘으면 그때 `timeout-minutes` 를 올린다.

## Shared Patterns

### 한국어 "왜" 주석 (모든 YAML · Dart · Markdown)
**Source:** `pubspec.yaml` 13 ~ 15행, 루트 `analysis_options.yaml` 1 ~ 6행, `tool/verify.dart` 40 ~ 44행
**Apply to:** 새 YAML 파일(묶음 · 별칭 · 루트 · fixture 옵션), `tool/verify.dart` 의 새 상수 · 함수, `.gitignore`
```dart
/// 규칙 검사용 복사본을 두는 폴더 (저장소 루트 기준).
///
/// 저장소 안이어야 루트 `pubspec.yaml` 의 SDK 하한이 적용되어 deprecated / removed
/// 규칙이 보고된다. 점으로 시작하는 폴더는 분석되지 않는다 (spike 005).
const ruleCheckDir = 'build/woody_rule_check';
```
— "무엇" 이 아니라 "왜 이 자리 · 이 방식인가" 를 적고, 근거가 실측이면 `(spike NNN)` 또는 `(2026-10-12 실측)` 을 붙인다. 영어 식별자 뒤 조사는 한 칸 띄운다. 추정은 추정이라고 적는다. SDK 에 묶인 사실(루트 분석의 plugin 준비, 생성 파일 제외의 범위)은 SDK 와 무관한 사실로 옮기지 않는다 (spike 016).

### 단계 결과의 꼴 — `StepResult`
**Source:** `tool/verify.dart` 165 ~ 202행 (클래스), 578 ~ 587행 (실패 예)
**Apply to:** `[2/N]` 의 새 가지, `[3/9]` 의 파일별 차이, 집합 확인, `recommended` 의 비교
```dart
  return StepResult(
    label: label,
    passed: false,
    detailLines: [
      'lib/ 에 .dart 파일이 있다 (${found.length})',
      ...found.map((p) => '  $p'),
      '',
      '`lib/` 에는 YAML 만 둔다 — 스크립트는 `tool/`, 연습용 코드는 `example/` 에 둔다.',
    ],
  );
```
— `detailLines` 는 "무엇이 틀렸나 (건수)" → 두 칸 들여쓴 줄들 → 빈 줄 → "다음에 할 일" 의 세 토막이다. 단계는 하나가 실패해도 나머지를 모두 돌린다 (1020 ~ 1038행). 종료 코드 규약(0 / 1 / 64 / 69 / 70 / 78, 21 ~ 22행)은 바꾸지 않는다.

### `dart analyze` 실행 형태
**Source:** `tool/verify.dart` 449 ~ 468행 (fixture), 658 ~ 663행 (규칙 검사)
**Apply to:** fixture 여섯의 분석, `[2/N]` 의 `parse_error` 재실행
```dart
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['--suppress-analytics', 'analyze', '--format=json'],
    workingDirectory: cwd,
    environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir},
  );
```
— fixture 는 폴더를 작업 디렉터리로, 경로 인자 없이, 상태 폴더는 fixture 마다 따로 (`.dart_tool/woody_verify/<fixture 경로>/`). 규칙 검사는 저장소 루트에서 `ruleCheckDir` 을 인자로, 상태 폴더 없이. 차례로 돌린다 (1020 ~ 1021행 주석). `flutter analyze` 는 쓰지 않는다.

### 정답지 비교 — 건수까지, `- ` / `+ `
**Source:** `tool/verify.dart` 475 ~ 515행 (`subtractLines`, `findDifference`), 877 ~ 883행 (화면 꼴)
**Apply to:** fixture 여섯 (recommended 는 example 의 실제 결과를 `Expected` 대신 쓴다)
```dart
        if (difference.isEmpty)
          '정답지와 같다 — 바뀐 줄 없음'
        else ...[
          ?exitNote,
          ...difference.missing.map((l) => '- $l'),
          ...difference.unexpected.map((l) => '+ $l'),
        ],
```

### 기준 커밋 단언 — `git diff --quiet <커밋> -- <경로>`
**Source:** RESEARCH § "계획이 고정할 기준 커밋" (HEAD `190c433` 에서 `git log -1 -- <경로>` 로 읽음)
**Apply to:** 모든 커밋의 verify
```bash
git diff --quiet 19ae5ec -- example/expected_diagnostics.txt   # C1 ~ C4 모두 — 정답지 불변 (성공 기준 1)
git diff --quiet 968a5bb -- pubspec.yaml                        # 모두 — version · dependencies 불변
git diff --quiet 90a2736 -- lib                                 # C1 만 — lib/ 를 아직 건드리지 않았다
git diff --quiet 008ea3f -- .github/workflows/verify.yml        # C1 ~ C4 — workflow YAML 불변
git diff --quiet 74fafb2 -- example/lib                         # 모두 — 샘플 7파일 불변
```
— 더 오래된 커밋을 기준으로 삼으면 헛실패한다. C4 의 "정답지 다섯이 C3 그대로" 는 C3 의 해시를 그때 읽어 넣는다.

### 지워 보기 기록 (헛통과가 아님을 보이는 M 표)
**Source:** `example/README.md` 91 ~ 101행 (M1 ~ M9), 144 ~ 150행 (M10 ~ M14), 154 ~ 158행 (읽는 법)
**Apply to:** C1 (M15 ~ M17), C3 (M18 ~ M19)
— 변경은 한 번에 하나, 바로 되돌리고, 끝에 검증이 다시 exit 0 인 것을 본다. "고치기 전" 의 결과를 함께 적을 때는 155행 꼴("M12 도 고치기 전에는 정답지를 덮어썼다. … (종료 코드 1, 쓴 파일은 되돌렸다)").

### Markdown 커밋 메시지와 커밋 전 린터
**Source:** CLAUDE.md § Git 커밋 규칙, RESEARCH § 권고 9 의 제목(안)
**Apply to:** C1 ~ C4 와 docs 커밋
— `fix(03-01): …` / `feat(03-02): …` 처럼 prefix 는 영어, 제목은 한국어. 커밋 전 루트에서 `fvm dart analyze` 0건 (C1 은 지금 파일로, C2 부터는 새 루트 파일로).

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `lib/recommended.yaml` 의 `include:` **목록** 꼴 | config | — | 저장소의 어느 옵션 파일도 include 를 목록으로 쓰지 않는다. RESEARCH § Code Examples 2 의 전문(주석을 단 채로 scratch 에서 정답지 16줄 확인)을 글자 그대로 쓴다. 머리 주석의 꼴만 루트 `analysis_options.yaml` 1 ~ 2행을 따른다 |

## Metadata

**Analog search scope:** `lib/`, `tool/`, `example/` (lib · README · 옵션 · lock · 정답지), 루트 `analysis_options.yaml` · `.gitignore` · `CHANGELOG.md` · `.github/workflows/`, `.planning/spikes/012-plugin-suppression-matrix/probe.dart`, `.planning/spikes/013-rule-check-after-split/probe.dart`, `.planning/spikes/014-multi-fixture-plugin-cost/probe.dart`, `.planning/phases/02-verification-harness/02-PATTERNS.md` (형식 선례)
**Files scanned:** 19 (git 추적 여부는 `git ls-files` 로 확인)
**Pattern extraction date:** 2026-10-12
**기준 커밋:** `tool/verify.dart` `40776b5`, `example/README.md` `008ea3f`, `lib/analysis_options.yaml` `90a2736`, HEAD `190c433` (+ 로컬 커밋 `759bddf`, `66a1753`)
