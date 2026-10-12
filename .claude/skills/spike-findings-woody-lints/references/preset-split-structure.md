# 프리셋 나누기 — 조각 · 묶음 · 별칭과 루트 옵션 파일

한 파일(`lib/analysis_options.yaml`)을 조각 셋(`base.yaml` / `riverpod.yaml` / `codegen.yaml`), 묶음(`recommended.yaml`), 옛 주소의 한 줄짜리 별칭으로 나누는 부분이다. 나눈 구조에서 include 가 어떻게 풀리는지, plugin 하한을 올리는 커밋, 사슬이 끊겼을 때 드러나는 자리, 그리고 저장소 루트의 `analysis_options.yaml` 을 어떻게 바꾸는지를 다룬다.

따로 적지 않은 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64, 2026-10-12 실측이다. 실험은 저장소의 모양을 작업 폴더에 복사한 replica 에서 했고, 연습용 프로젝트는 `woody_lints` 를 `path:` 의존성으로 받았다 (009 ~ 011).

같은 구조를 두 조건에서 더 쟀다. git 의존성으로 받은 것(015)은 `path:` 때와 줄 단위로 같았다 (→ git-dependency-and-upgrade.md). 다음 SDK 의 베타(Dart 3.14.0-211.1.beta, 016)에서는 include 와 plugin 로드가 그대로였고 **저장소 루트의 분석이 달라졌다** — 이 문서의 6번에서 "plugin 준비 없음" 이라고 적은 것은 Dart 3.13.4 의 사실이다 (→ next-sdk-forward-compat.md). 베타에서 다시 잰 것은 3번의 조합과 6번의 루트 분석까지다. 4번(하한 상향), 5번(사슬이 끊겼을 때), Constraints 의 "루트 `pub get` 전" 은 Dart 3.13.4 의 값이고 베타에서 재지 않았다.

그 뒤 두 자리에서 더 봤다 (둘 다 Dart 3.13.4, 2026-10-12). GitHub Linux runner 에서 나눈 구조의 여섯 조합이 로컬의 예상과 줄 단위로 같았고(017), 실제 사용 프로젝트 `flutter_starter_kit` 의 복사본에서 나누기 전후가 줄 단위로 같았다(019 → real-consumer-measurement.md). 둘 다 3번의 조합을 다시 본 것이고 5번 · 6번은 다시 재지 않았다.

날짜 없이 적은 "지금" 은 2026-10-12 의, 나누기 전의 저장소다.

## Requirements

MANIFEST.md 의 `preset-split-include-behavior` 에서 이 영역에 걸리는 것.

소유자가 이전에 확정한 것 (출처는 03-CONTEXT.md, ROADMAP.md).

- 파일 이름은 `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml` 이고, `lib/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 한 줄짜리 별칭이다
- 조각은 서로를 include 하지 않는다. `base.yaml` 만 `flutter_lints` 를 include 하고 조합은 include 하는 쪽이 한다
- 나누는 것은 구조 변경이다. 규칙 목록 · 주석 처리된 줄 · 사유 주석은 옮기기만 한다 — spike 의 조각 파일은 저장소의 배포 파일을 **잘라서** 만들고 손으로 다시 쓰지 않는다
- `invalid_annotation_target: ignore` 와 생성 파일 제외 두 줄은 `codegen.yaml` 에 둔다 (D-02). `riverpod_lint` 선언은 범위 지정이다 (D-01)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 하고, 스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다
- pub workspace 와 Riverpod major 차이는 재지 않는다 (D-08)

spike 에서 나와 실제 구현이 지켜야 하는 것.

- 묶음(`recommended.yaml`)은 조각 셋을 `package:woody_lints/…` 주소의 목록으로 부르고, 옛 주소 파일은 `include: package:woody_lints/recommended.yaml` 한 줄이다. 이 3단 구조에서 plugin 이 로드되고 옛 주소 · 묶음 주소 둘 다 지금의 정답지(`exit 2` + 16줄)와 한 줄도 다르지 않다. 상대 경로로 불러도 결과가 같으므로 선례대로 `package:` 를 쓴다 (009, 010, 011)
- `riverpod_lint` 선언을 `^3.1.9` 로 올리는 커밋에서 정답지는 바뀌지 않는다 — 2026-10-12 에 `^3.1.3` 과 `^3.1.9` 가 둘 다 3.1.9 로 풀리는 동안의 사실이다 (010)
- 루트 `analysis_options.yaml` 의 `lib/analysis_options.yaml` 제외는 파일을 나누는 커밋과 **같은 커밋이거나 그 뒤**에 지운다. 한 파일 구조에서 먼저 지우면 `lib/analysis_options.yaml:58  warning  plugins_in_inner_options` 로 루트 분석이 exit 2 가 된다 (011)
- 새 연습용 프로젝트는 한 폴더 아래에 모으고 루트에서 `'<폴더>/**'` 한 줄로 제외한다. 기존 `example/**` 줄은 그대로 둔다. 제외하지 않으면 루트 분석에 그 폴더들의 진단이 섞이고 plugin 까지 준비한다 (011)
- 루트 옵션 파일은 묶음을 include 하지 않는다 — 분석마다 plugin 을 준비한다. `base.yaml` 은 include 해도 plugin 을 준비하지 않고 지금의 `tool/verify.dart` 에 새 진단이 0건이다 (011)
- `path:` 의존성으로 잰 009 ~ 012 의 결과는 git 의존성(패키지가 pub cache 의 `git/<저장소 이름>-<커밋 해시>/` 에 놓인다)에서도 줄 단위로 같다 — 3단 include 의 plugin 로드, 옛 주소 · 묶음 주소의 정답지 일치, 조합별 진단, 생성 파일 제외의 모양. 연습용 프로젝트를 git 의존성으로 따로 두지 않는다. 받아 오는 길(GitHub 주소, 실제 tag)은 Phase 6 의 smoke test 가 본다 (015)
- 실제 사용 프로젝트(`flutter_starter_kit` 의 복사본, Dart 파일 468개)에서도 나누기 전후가 줄 단위로 같다 — 지금 받는 그대로(git, 1.3.0) = 한 파일 구조 = 나눈 구조(옛 주소) = 나눈 구조(묶음 주소). 프로젝트 자신의 코드는 지금 0줄이라 표식 파일(정답지 16줄)과, `always_specify_types` 를 더 켠 짝(9,398줄이 줄 단위로 같다)으로 확인했다 (019)

MANIFEST.md 의 `next-sdk-forward-compat` 에서 이 영역에 걸리는 것 (베타 `3.14.0-211.1.beta` 한 빌드의 결과이고 정식 버전에서 달라질 수 있다).

- 구조(조각 셋 · 묶음 · 별칭)는 바꾸지 않는다. include 로 받는 `plugins:` 는 베타에서도 한 파일 구조 · 3단 별칭 · 묶음 · 조각 조합에서 모두 로드되고 진단의 내용이 같다 (016)
- 루트 옵션 파일의 주석과 문서에 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다. 베타에서는 `lib/analysis_options.yaml` 이 `plugins:` 에 닿는 한 루트 분석이 plugin 을 준비하고(0.5초 → 10초, 진단은 0줄) 루트의 제외로 막지 못한다. `plugins_in_inner_options` 는 베타에서 나오지 않는다 (016)
- 연습용 프로젝트 폴더를 루트에서 제외하는 방식은 베타에서도 통한다 — 제외한 폴더는 plugin 을 준비시키지 않는다 (016)

위 `preset-split-include-behavior` 목록의 "plugin 까지 준비한다" · "plugin 을 준비하지 않고" (011) 는 Dart 3.13.4 에서 잰 말이다. 고정 SDK 에서 일하는 동안에는 그대로 맞고, 주석과 문서에 이유로 옮겨 적지는 않는다.

## How to Build It

### 1. 나눈 뒤의 `lib/`

```text
lib/
  base.yaml              flutter_lints include + linter.rules
  codegen.yaml           analyzer.errors + analyzer.exclude
  riverpod.yaml          plugins: riverpod_lint
  recommended.yaml       조각 셋을 부르는 목록 (묶음)
  analysis_options.yaml  묶음을 부르는 한 줄 (옛 주소의 별칭)
```

묶음과 별칭의 include 는 spike 가 쓴 그대로다 (`sources/009-preset-plugin-via-include/replica.dart` 의 `Replica.writeLibSplit`). 아래 두 코드 블록의 첫 줄(`# lib/…`)은 여기서 붙인 파일 이름이고 spike 의 파일에는 없었다.

```yaml
# lib/recommended.yaml
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml
  - package:woody_lints/codegen.yaml
```

```yaml
# lib/analysis_options.yaml
include: package:woody_lints/recommended.yaml
```

조각 셋은 지금의 `lib/analysis_options.yaml` (64행) 을 아래 자리에서 자른 것이다.

| 조각 | 지금 파일의 줄 | 담는 것 |
|---|---|---|
| `base.yaml` | 1 ~ 41행, 그리고 59 ~ 64행 | 템플릿 영어 주석, `include: package:flutter_lints/flutter.yaml`, 주석 처리된 `formatter:`, `linter.rules` (규칙 12개 + 주석 처리된 2개). 맨 끝의 템플릿 영어 주석(59 ~ 64행)도 여기에 붙였다 |
| `codegen.yaml` | 42 ~ 48행 | `analyzer.errors` 의 `invalid_annotation_target: ignore`, `analyzer.exclude` 의 두 패턴 |
| `riverpod.yaml` | 49 ~ 58행 | plugin 설명 주석 8줄, `plugins:` 와 `  riverpod_lint: ^3.1.3` |

- 이렇게 자르면 `base.yaml` 의 마지막 규칙이 40행이고, 규칙의 줄 번호가 지금 파일과 같다.
- 템플릿 영어 주석을 어느 조각에 둘지, 새 파일에 머리 주석을 달지는 계획이 정한다 (03-CONTEXT.md). 위 표는 spike 가 자른 자리이지 정해진 배치가 아니다. `base.yaml` 앞에 줄을 더하면 규칙의 줄 번호가 그만큼 밀린다.
- spike 의 묶음과 별칭에는 주석이 한 줄도 없었다. 주석을 단 파일로는 재지 않았다.

### 2. "옮기기만 했다" 를 확인한다

spike 는 조각을 손으로 쓰지 않고 배포 파일을 잘라 만들었고, 자른 조각을 다시 이으면 원본과 글자 하나 다르지 않은지를 확인한 뒤에만 실험을 시작했다.

```dart
// sources/009-preset-plugin-via-include/replica.dart 의 Shipped.read 에서 (발췌)
final analyzerAt = lines.indexOf('analyzer:\n');
final commentAt = lines.indexWhere((l) => l.startsWith('# analyzer plugin'));
final pluginsAt = lines.indexOf('plugins:\n');
if (analyzerAt < 0 || commentAt < analyzerAt || pluginsAt < commentAt) {
  throw const FormatException('배포 파일의 analyzer: / plugins: 자리가 예상과 다르다');
}
var afterPlugins = pluginsAt + 1;
while (afterPlugins < lines.length && lines[afterPlugins].startsWith(' ')) {
  afterPlugins++;
}
// … 여기서 `shipped` 를 만든다 (생성자 호출 7줄 생략). 조각의 범위는
// base = [0, analyzerAt), codegen = [analyzerAt, commentAt),
// riverpod = [commentAt, afterPlugins), tail = [afterPlugins, 끝) 이다.
final rejoined =
    shipped.basePart + shipped.codegenPart + shipped.riverpodPart + shipped.tailPart;
if (rejoined != original) {
  throw const FormatException('자른 조각을 이은 것이 원본과 다르다');
}
if (!shipped.basePart.contains('\nlinter:\n') || shipped.basePart.contains('plugins:')) {
  throw const FormatException('기본 조각에 linter: 가 없거나 plugins: 가 섞였다');
}
```

- `lines` 는 줄 끝의 `\n` 을 붙인 채로 나눈 목록이다 (전문은 사본에 있다).
- 실제로 파일을 나누는 커밋에서도 같은 확인을 할 수 있다 — 나눈 세 파일을 이은 것이 나누기 전의 파일(`git show <나누기 전 커밋>:lib/analysis_options.yaml`)과 같은지 본다. 009 가 "쓸 수 있다" 고 적은 방법이고, 그 형태로 돌린 것은 아니다. 새 파일에 머리 주석을 달면 그 줄을 빼고 견줘야 한다.
- 가장 센 확인은 따로 있다: 나눈 뒤에도 `example/` 의 정답지가 한 줄도 바뀌지 않는다 (아래 3번).

### 3. 나눈 구조가 실제로 내는 결과

이름이 `analysis_options.yaml` 이 아닌 파일(`riverpod.yaml`)의 최상위 `plugins:` 가 include 를 거쳐 로드된다. 조각 조합 넷이 같은 내용을 한 파일에 둔 것과 진단 · 종료 코드가 같았다 (009).

| 연습용 프로젝트가 include 한 것 | exit | 진단 | `riverpod_lint` | plugin 폴더 | 한 파일에 둔 같은 내용과 |
|---|---|---|---|---|---|
| `base.yaml` | 2 | 18줄 | 0줄 | 0 | 같음 |
| `base.yaml` + `riverpod.yaml` | 2 | 21줄 | 3줄 | 1 | 같음 |
| `base.yaml` + `codegen.yaml` | 0 | 13줄 | 0줄 | 0 | 같음 |
| 셋 다 | 2 | 16줄 | 3줄 | 1 | 같음. 저장소의 정답지와도 같음 |

옛 주소 → 묶음 → 조각의 3단에서도 같다 (010).

| 연습용 프로젝트의 옵션 | 묶음 · 별칭의 주소 | 단 | exit | 진단 | plugin 폴더 | 정답지와 |
|---|---|---|---|---|---|---|
| 옛 주소 한 줄 | `package:` | 3 | 2 | 16줄 | 1 | 같음 |
| 묶음 주소 한 줄 | `package:` | 2 | 2 | 16줄 | 1 | 같음 |
| 옛 주소 한 줄 | 상대 경로 | 3 | 2 | 16줄 | 1 | 같음 |
| 묶음 주소 한 줄 | 상대 경로 | 2 | 2 | 16줄 | 1 | 같음 |
| 옛 주소 한 줄 | 별칭만 상대 경로 | 3 | 2 | 16줄 | 1 | 같음 |

- 서버가 만든 plugin 패키지의 `pubspec.yaml` 에 `riverpod.yaml` 의 선언(`^3.1.3`)이 세 단계를 거쳐 그대로 적혔고 3.1.9 로 풀렸다. stderr 는 비어 있었다.
- Riverpod 조각을 받지 않은 조합은 plugin 을 **준비조차 하지 않는다** (빈 상태 폴더에 `.plugin_manager` 가 생기지 않는다).
- 처음 실행은 plugin 을 쓰는 조합이 14.9 ~ 15.7초, 쓰지 않는 조합이 3.1 ~ 4.3초다. 단 수와는 무관하다. 재실행은 3.5초다.

가장자리에서 본 것.

| 무엇 | 결과 | 근거 |
|---|---|---|
| include 순서를 뒤집음 (`codegen` → `riverpod` → `base`) | 같은 16줄. 조각끼리 겹치는 키가 없다 | 009 |
| 조각 하나를 목록 문법(`- …`)으로 | 한 줄 문법과 같은 18줄 | 009 |
| `riverpod.yaml` 만 (기본 조각 없이) | plugin 3줄 + `invalid_annotation_target` 1줄, plugin 폴더 1. 조각이 서로 기대지 않는다 | 009 |
| 옵션 파일이 비어 있음 | `invalid_annotation_target` 1줄뿐 | 009 |
| 별칭 앞에 징검다리 파일 셋 (6단) | 정답지와 같음, plugin 폴더 1. 깊이 제한이 없다 | 010 |
| 옛 주소 + `riverpod.yaml` + `base.yaml` 을 한 목록에 | 정답지와 같음. 같은 조각에 두 길로 닿아도 진단이 두 번 나오지 않는다 | 010 |

git 의존성, 다음 SDK, GitHub runner, 실제 사용 프로젝트에서 다시 본 것.

| 조건 | 다시 잰 칸 | 결과 | 근거 |
|---|---|---|---|
| git 의존성 (패키지가 pub cache 에 놓인다), Dart 3.13.4 | 옛 주소 · 묶음 주소 · `base.yaml` + `riverpod.yaml` · `base.yaml` 만 | 정답지 · 009 의 예상과 같음. 선언 `^3.1.3` 이 3단을 거쳐 전해짐. 처음 실행 14.8 ~ 15.2초 | 015 |
| 베타 (Dart 3.14.0-211.1.beta), `path:` | 한 파일 구조 · 옛 주소 · 묶음 주소 · `base.yaml` + `riverpod.yaml` · `base.yaml` 만 · `base.yaml` + `codegen.yaml` | plugin 로드와 plugin 폴더 수가 같음. 진단은 codegen 조각을 받는 칸에만 생성 파일 샘플의 4줄이 더 나옴 (16 → 20줄, 13 → 17줄) | 016 |
| GitHub Linux runner (`ubuntu-24.04` · `ubuntu-26.04`, 코어 4개), Dart 3.13.4, `path:` | 옛 주소 · 묶음 주소 · `base.yaml` 만 · 묶음 + `provider_parameters` 를 끔 · `base.yaml` + `riverpod.yaml` · `base.yaml` + `codegen.yaml` | job 12개에서 여섯 조합의 진단이 로컬의 예상과 줄 단위로 같음 (16 / 16 / 18 / 15 / 21 / 13줄). plugin 을 쓰는 넷은 plugin 폴더 1, 쓰지 않는 둘은 0 | 017 |
| 실제 사용 프로젝트의 복사본 (`flutter_starter_kit`, Dart 파일 468개), Dart 3.13.4 | 지금 받는 그대로(git, 1.3.0) · 한 파일 구조 · 옛 주소 · 묶음 주소 · `base.yaml` 만(대조) | 앞의 넷이 줄 단위로 같음 (표식 파일 16줄, 프로젝트의 줄 0). `always_specify_types` 를 더 켠 한 파일 구조와 나눈 구조가 9,398줄로 같음. 대조는 14줄로 달라짐 | 019 |

- 베타의 4줄은 include 나 plugin 로드가 아니라 **생성 파일 제외**가 달라져 생긴 것이고, 한 파일 구조(1.3.0)에서도 똑같이 생긴다 (→ next-sdk-forward-compat.md 3번).
- "가장자리에서 본 것" 의 실험(순서 뒤집기, 6단, 상대 경로 등)은 git 의존성으로도 베타로도, runner 에서도 실제 프로젝트에서도 다시 재지 않았다.
- 실제 프로젝트의 줄은 사용 프로젝트 자신의 옵션 파일(자기 `analyzer.exclude`, 주석뿐인 `linter: rules:`)을 거친 결과다. 사용 프로젝트가 맵 문법으로 규칙을 하나 더 켜도 3단 include 위에 그대로 얹혔다 (019). 표식 파일이 무엇이고 "프로젝트의 줄" 을 어떻게 세는지는 real-consumer-measurement.md 에 있다.

조각별 연습용 프로젝트의 정답지 모양은 fixtures-after-split.md 2번에 있다.

### 4. plugin 하한을 `^3.1.9` 로 올리는 커밋 (PRESET-05)

파일을 나누는 커밋과 **다른 커밋**이다 (03-CONTEXT.md). 정답지가 바뀐다면 이 커밋에서만 바뀌어야 하는데, 지금은 바뀌지 않는다.

| `riverpod.yaml` 의 선언 | 서버가 받은 선언 | 풀린 버전 | 진단 |
|---|---|---|---|
| `^3.1.3` | `^3.1.3` | 3.1.9 | 16줄 |
| `^3.1.9` | `^3.1.9` | 3.1.9 | 같은 16줄 |

- 화면의 `plugin` 줄도 3.1.9 그대로다. 선언이 바뀐 것은 전용 상태 폴더의 `.plugin_manager/*/pubspec.yaml` 에서 볼 수 있다.
- 선언이 바뀌면 서버는 plugin 을 다시 준비한다 (15.8초). 올린 뒤의 첫 검증은 처음 실행과 같은 시간이 든다.

```dart
// sources/009-preset-plugin-via-include/replica.dart
/// 서버가 만든 `pubspec.yaml` 에서 `riverpod_lint` 의 제약을 읽는다. 없으면 null.
static String? declaredConstraint(Directory pluginFolder) {
  final pubspec = File('${pluginFolder.path}/pubspec.yaml');
  if (!pubspec.existsSync()) return null;
  final match =
      RegExp(r'^  riverpod_lint: (.+)$', multiLine: true).firstMatch(pubspec.readAsStringSync());
  return match?.group(1);
}
```

### 5. 사슬이 끊기면 어디서 드러나는가

| 실수 | 드러나는 자리 | 모양 | 근거 |
|---|---|---|---|
| 묶음에서 `riverpod.yaml` 을 뺌 | 옛 주소를 쓰는 연습용 프로젝트의 정답지 비교 | `riverpod_lint` 3줄이 빠지고 종료 코드가 2 → 0, plugin 폴더 0 | 010 |
| 별칭이 없는 파일을 부름 | 옛 주소를 쓰는 연습용 프로젝트의 정답지 비교 | 아래 2줄만 남는다. 규칙 진단 13줄이 전부 사라진다 | 010 |
| 묶음이 없는 조각을 부름 | 저장소 루트의 분석 (6번의 제외를 걷어낸 뒤) | `lib/analysis_options.yaml:1  warning  include_file_not_found`, exit 2 | 011 |

별칭이 깨졌을 때 사용 프로젝트에 나오는 2줄.

```text
analysis_options.yaml:1  warning  include_file_not_found
lib/should_not_appear.dart:5  warning  invalid_annotation_target
```

- 옛 주소는 묶음이 부르는 것을 그대로 따른다. 그래서 **옛 주소를 쓰는 연습용 프로젝트(`example/`)를 남겨 두면** 위 표의 첫 두 실수를 둘 다 잡는다.
- 별칭의 include 가 깨져도 조용히 통과하지 않는다. 사용 프로젝트의 옵션 파일 1행에 warning 이 붙고 메시지에 깨진 파일의 경로가 적힌다.
- 루트 분석에서 진단이 붙는 파일은 묶음이 아니라 **별칭**이다. 직접 분석되는 것은 `analysis_options.yaml` 이름의 파일뿐이다. 메시지가 깨진 자리를 알려 준다: `The URI 'package:woody_lints/no_such_fragment.yaml' included in '<저장소>/lib/recommended.yaml' can't be found …`.
- 진단의 **메시지에 로컬 절대 경로가 들어 있다.** 화면이나 기록에 메시지를 그대로 옮기면 경로가 샌다.
- 루트 분석에 `lib/analysis_options.yaml:1  warning  include_file_not_found` 가 나오는 경우는 둘을 쟀다 — 묶음이 없는 조각을 부를 때(위 표), 그리고 루트의 `pub get` 을 하기 전(→ Constraints. 이때는 루트 옵션 파일에도 한 건이 함께 나온다). 별칭이 없는 파일을 부를 때의 루트 분석은 재지 않았다 (사용 프로젝트 쪽의 모양만 쟀다).

### 6. 루트 `analysis_options.yaml`

나누는 커밋(또는 그 뒤)에서 `lib/analysis_options.yaml` 제외를 지운다 (PRESET-06). 저장소 루트에서 인자 없이 `dart analyze` 를 돌렸을 때 (커밋 전 린터와 같은 실행). **이 절의 표 둘은 Dart 3.13.4 의 것이다** — 다음 SDK 에서 달라지는 칸은 절 끝에 있다.

| `lib/` 의 구조 | 루트의 `lib/analysis_options.yaml` 제외 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|
| 한 파일 (지금) | 있음 | 0 | 0건 | 없음 | 0.7초 |
| 한 파일 (지금) | **없음** | **2** | **1건** | 없음 | 0.6초 |
| 나눔, `package:` 주소 | **없음** | **0** | **0건** | 없음 | 0.6초 |
| 나눔 | 있음 (남겨 둠) | 0 | 0건 | 없음 | 0.6초 |
| 나눔, 상대 경로 | 없음 | 0 | 0건 | 없음 | 0.6초 |

한 파일 구조에서 먼저 지웠을 때의 한 건.

```text
lib/analysis_options.yaml:58  warning  plugins_in_inner_options
  Plugins can only be specified in the root of a pub workspace or the root of a package that isn't in a workspace.
```

- 나눈 구조에서 0건인 이유: `lib/analysis_options.yaml` 이 include 한 줄뿐이고 `plugins:` 는 `riverpod.yaml` 에 있다. `riverpod.yaml` 은 이름이 달라 옵션 파일로 직접 분석되지 않는다.
- Dart 3.13.4 의 루트 분석은 plugin 을 준비하지 않는다. `lib/` 의 별칭이 include 로 `plugins:` 를 받아도 그것은 하위 옵션 파일의 설정이라 이 SDK 의 서버가 쓰지 않는다.
- 제외를 걷어낸 뒤의 루트 분석(0.6초)은 "옛 주소에서 조각까지의 사슬이 풀리는가" 를 덤으로 본다 (5번의 셋째 줄).

나눈 뒤의 루트 옵션 파일 (011 이 돌린 모양. 폴더 이름 `fixtures` 는 예시다). `include` 줄은 지금과 같다 — 바뀌는 것은 exclude 뿐이다. `lib/analysis_options.yaml` 줄은 나누는 커밋이나 그 뒤에 지우고, `fixtures/**` 줄은 그 폴더를 만드는 변경에서 함께 넣는다 (나누는 커밋에 폴더가 아직 없으면 그때의 exclude 는 `example/**` 한 줄이다).

```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  exclude:
    - 'example/**'
    - 'fixtures/**'
```

루트 옵션 파일이 이 패키지의 조각을 include 한다면.

| 루트의 include | 표식 파일 | exit | 진단 | plugin 준비 | 시간 |
|---|---|---|---|---|---|
| `flutter_lints` (지금) | 없음 | 0 | 0건 | 없음 | 0.5초 |
| `package:woody_lints/base.yaml` | 없음 | 0 | 0건 | 없음 | 0.5초 |
| `flutter_lints` | 겹따옴표 한 줄 | 0 | 0건 | 없음 | 0.5초 |
| `package:woody_lints/base.yaml` | 겹따옴표 한 줄 | 0 | 1건 — `tool/quote_marker.dart:2  info  prefer_single_quotes` | 없음 | 0.5초 |
| `package:woody_lints/recommended.yaml` | 없음 | 0 | 0건 | **있음** | 10 ~ 11초 |

- `base.yaml` 을 include 하면 이 패키지의 규칙이 `tool/` 에 실제로 적용되고(넷째 줄), 지금의 `tool/verify.dart` 는 그 규칙으로도 0건이다(둘째 줄). 하고 말고는 계획의 재량이다 (03-CONTEXT.md).
- 묶음은 include 하지 않는다. 분석마다 plugin 을 준비해 10 ~ 11초와 네트워크가 든다.
- 연습용 프로젝트 폴더의 제외(표와 실측)는 fixtures-after-split.md 4번에 있다.

**다음 SDK 에서 달라지는 칸 (016, 베타 Dart 3.14.0-211.1.beta).** 같은 실행을 두 SDK 로 돌렸다.

| `lib/` 의 구조 | `example/` | 루트의 제외 | Dart 3.13.4 | 베타 |
|---|---|---|---|---|
| 한 파일 | 없음 | 없음 | `plugins_in_inner_options` 1줄, exit 2, plugin 준비 없음 | **0줄, exit 0, plugin 준비, 10초** |
| 한 파일 | 있음 | `lib/analysis_options.yaml` · `example/**` (지금의 저장소) | 0줄, plugin 준비 없음, 0.5초 | **0줄, plugin 준비, 10초** |
| 나눔 | 있음 | `example/**` (나눈 뒤에 지을 모양) | 0줄, plugin 준비 없음, 0.5초 | **0줄, plugin 준비, 10초** |
| 나눔 | 있음 | `lib/analysis_options.yaml` · `example/**` (제외를 남겨 둠) | 0줄, plugin 준비 없음 | **0줄, plugin 준비, 10초** |
| 나눔에서 별칭 파일만 뺌 | 없음 | 없음 | 0줄, plugin 준비 없음 | 0줄, plugin 준비 없음, 0.5초 |

- **이 표의 replica 에는 루트의 Dart 파일이 없다** — `lib/` 는 YAML 뿐이고 `tool/verify.dart` 를 복사하지 않았다 (위의 Dart 3.13.4 표 둘을 잰 011 의 replica 에는 있었다. 같은 구성의 시간이 0.6 ~ 0.7초와 0.5초로 다른 것이 그 차이다). 그 replica 에서 진단은 두 SDK 모두 0줄이다. PRESET-06 의 "루트 분석이 경고 없이 통과한다" 는 고정 SDK 에서 `tool/verify.dart` 까지 넣어 확인됐고(011), **베타에서 `tool/verify.dart` 가 있는 루트는 재지 않았다.** 달라진 것으로 확인된 것은 plugin 준비 · 시간(0.5초 → 10초) · 네트워크다.
- 베타가 plugin 을 준비하는 까닭은 `lib/` 에 있는 `analysis_options.yaml` 이라는 이름의 파일이 `plugins:` 에 닿기 때문이다 (직접 담든, 별칭으로 묶음을 부르든). 그 이름의 파일이 없으면 준비하지 않는다. **루트에서 그 파일을 제외해도 막지 못했다.** 잰 제외는 파일 하나를 가리키는 `lib/analysis_options.yaml` 이고, `lib/**` 처럼 폴더째 제외한 경우는 재지 않았다.
- `plugins_in_inner_options` 는 베타에서 나오지 않는다. "한 파일 구조에서 제외를 먼저 지우면 exit 2" 는 Dart 3.13.4 에서만 일어나는 일이고, 고정 SDK 가 3.13.4 인 동안 "나누는 커밋이거나 그 뒤에 지운다" 는 그대로 지킨다.
- **루트 옵션 파일의 주석에 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다.** 연습용 프로젝트 폴더의 제외는 "그 폴더의 진단이 루트 분석에 섞이지 않게" 가 두 SDK 에서 모두 맞는 이유다.
- **"묶음을 include 하지 않는다" 는 결정의 근거와 주석에 적을 말은 다르다.** 근거는 011 이 Dart 3.13.4 에서 잰 것(묶음을 include 하면 루트 분석마다 plugin 을 준비해 10 ~ 11초가 든다)이고 고정 SDK 에서 일하는 동안 그대로 맞다. 그것을 include 줄의 주석에 이유로 옮기면 다음 SDK 에서 틀린 말이 된다 — 베타의 루트 분석은 묶음을 include 하지 않아도 plugin 을 준비한다. 주석을 단다면 SDK 와 무관한 이유로 단다 (예: 루트에는 Riverpod 코드도 생성 파일도 없어 그 조각들이 줄 것이 없다 — 이것은 제안이고 spike 가 정한 문구가 아니다. 무엇을 적을지는 계획이 정한다).
- 루트 옵션 파일이 `base.yaml` · 묶음을 include 하는 위의 표는 베타에서 재지 않았다. 경우를 하나씩 넣고 빼며 원인을 가른 표는 next-sdk-forward-compat.md 4번에 있다.

## What to Avoid

- **한 파일 구조인 채로 루트의 `lib/analysis_options.yaml` 제외를 먼저 지우는 것.** 루트 분석이 `plugins_in_inner_options` 로 exit 2 가 된다. 지우는 것은 나누는 커밋이거나 그 뒤다.
- **조각을 손으로 다시 쓰는 것.** 구조만 바꾼 것과 내용까지 바뀐 것이 섞인다. 잘라서 옮기고 이어 붙여 원본과 견준다.
- **루트 옵션 파일이 묶음을 include 하는 것.** 분석마다 plugin 을 준비한다. 별칭(`lib/analysis_options.yaml`)을 include 하는 것도 그 별칭이 묶음을 부르므로 같을 것이다 — 별칭으로는 재지 않았다. 지금의 루트 옵션 파일이 한 파일 구조에서 같은 이유로 `lib/analysis_options.yaml` 을 include 하지 않는다.
- **`plugins:` 를 `analysis_options.yaml` 이름의 패키지 파일에 남겨 두는 것.** 지금(Dart 3.13.4) 루트에 제외가 필요한 이유가 바로 그것이다 — 그 이름의 파일은 `lib/` 의 옵션 파일로 직접 분석된다.
- **루트 옵션 파일의 주석이나 문서에 "루트 분석이 plugin 을 준비하지 않도록" 을 이유로 적는 것.** Dart 3.13.4 의 사실이다. 베타에서는 나눈 구조의 루트 분석도 plugin 을 준비하고 루트의 제외로 막지 못한다 (016).
- **git 의존성으로 받는 연습용 프로젝트를 구조 확인용으로 하나 더 두는 것.** `path:` 때와 줄 단위로 같았다 (015).
- **상대 경로로 부르면 `pub get` 전의 루트 분석이 깨끗해질 것이라는 기대.** 별칭 → 묶음 → `base.yaml` 까지는 풀리지만 `base.yaml` 이 부르는 `flutter_lints` 가 풀리지 않아 warning 수가 같다. 주소 방식을 고를 근거가 되지 못한다.
- **README 가 include 순서를 강제하는 것.** 조각끼리 겹치는 키가 없어 순서는 결과를 바꾸지 않는다. 조각에 겹치는 키가 생기면 다시 재야 한다.
- **"제외를 걷어냈으니 루트 분석이 규칙의 상태도 본다" 는 가정.** 루트 분석이 직접 보는 것은 한 줄짜리 별칭이다. deprecated / removed 는 직접 분석되는 옵션 파일에 적힌 규칙에만 보고되므로(005, 013) 규칙 검사는 그대로 필요하다 (→ rule-status-check.md). 이 구조의 루트 분석에 문제 규칙을 넣어 직접 잰 것은 아니다.
- **별칭이 조각 셋을 직접 부르게 하는 것.** 같은 목록이 두 파일에 생겨 어긋날 수 있다 (PROJECT.md Key Decisions). 재지 않았다.

## Constraints

- include 한 파일의 `plugins:` 가 로드된다고 직접 말한 공식 문서 문장은 없다. dart.dev/tools/analyzer-plugins 는 plugin 을 "패키지 루트의 `analysis_options.yaml`" 에서 켠다고만 적는다. 근거는 소스(`analyzer` 14.5.0 의 `analysis_options_include_walker.dart` — include 를 재귀로 따라가며 파일마다 같은 병합을 적용하고, 깊이를 세는 코드가 없다)와 이번 실행이다. Dart 3.13.4 에 든 analyzer 는 그보다 앞선 14.1.0-dev 다.
- `plugins_in_inner_options` 는 `file.parent != contextRoot && isInitialFile` 이고 그 파일 **자신**이 `plugins:` 를 가질 때만 보고된다 (SDK tag 3.13.4). include 로 닿은 파일은 대상이 아니다.
- pub.dev 의 `analyzer` 14.4.0 / 14.5.0 에서는 `PLUGINS_IN_INNER_OPTIONS` 가 "제거된 진단 코드" 목록에 들어 있다. 한 파일 구조에서 제외를 지웠을 때의 경고는 베타(Dart 3.14.0-211.1.beta)에서 실제로 나오지 않았다 (016). 나눈 구조가 0건이라는 결과는 베타에서도 같다 — 대신 루트 분석이 plugin 을 준비한다 (6번 끝).
- `plugins_in_inner_options` 의 조건(그 파일 자신이 `plugins:` 를 가질 때만 보고되고 include 로 닿은 파일은 대상이 아니다)은 SDK tag 3.13.4 의 것이다. 베타에서는 이 진단이 나오지 않고, 안쪽 옵션 파일의 `plugins:` 가 include 로 닿은 것까지 쓰인다 (sdk#63627 → next-sdk-forward-compat.md 의 Constraints).
- 하한 상향의 결과는 `^3.1.3` 과 `^3.1.9` 가 같은 버전으로 풀리는 동안의 것이다. `riverpod_lint` 3.1.9 보다 새 버전이 나온 뒤에는 다시 본다.
- `invalid_annotation_target` 은 아무것도 include 하지 않아도 warning 으로 나온다. analyzer 의 기본 동작이다.
- **루트의** `pub get` 을 하기 전(저장소를 새로 받은 직후)의 루트 분석은 지금도 exit 2 다 — 루트 옵션 파일의 `include_file_not_found` (`flutter_lints`) 1건. 나누고 제외를 걷어낸 뒤에는 `lib/analysis_options.yaml:1` 에 1건이 더 붙어 2건이 된다. 검증 명령과 CI 는 루트 `pub get` 을 먼저 돌리므로 이 상태를 지나지 않는다.
- 009 ~ 011 의 판정은 각각 23건, 23건, 20건이 모두 성립했다. 011 은 두 번 돌려 두 번 모두 같았다.
- git 의존성으로 받았을 때의 include 와 plugin 로드는 015 가 로컬 git 저장소로 쟀다 (009 ~ 011 은 `path:` 다). 남은 것은 받아 오는 길 — 실제 GitHub 주소와 tag — 이고 Phase 6 의 smoke test 가 본다.
- Dart 3.14 는 베타 한 빌드로 쟀다 (016). 정식 버전은 재지 않았다.
- GitHub Linux runner 에서는 3번의 여섯 조합만 다시 봤다 (017). 사슬이 끊겼을 때(5번)와 저장소 루트의 분석(6번)은 runner 에서 재지 않았다 — include 병합과 context root 를 다루는 코드는 운영체제와 무관하다고 읽었다. 검증 명령(`tool/verify.dart`)은 루트를 인자 없이 분석하지 않으므로(→ next-sdk-forward-compat.md 4번) 지금의 `verify` job 도 6번의 실행을 지나지 않는다.
- 확인하지 않은 것: 5번 · 6번을 GitHub Linux runner 에서 한 것, 루트를 IDE 로 열었을 때의 모습 (베타에서는 IDE 도 루트에서 plugin 을 준비할 것이다 — 추정), 순환 include (`recursive_include_file` — 이 구조에는 생기지 않는다), Dart 3.14 정식 버전, 주석을 단 묶음 · 별칭 파일, 루트 옵션 파일이 `base.yaml` 을 include 하는 선택지를 베타에서, 실제 사용 프로젝트를 베타에서 (019 는 그 프로젝트의 `pub get` 이 베타에서 풀리지 않아 돌리지 못했다), 학습용 프로젝트 넷.

## Origin

Synthesized from spikes: 009, 010, 011 (015 의 git 의존성 결과와 016 의 베타 결과는 달라지는 자리에, 017 의 runner 결과와 019 의 실제 사용 프로젝트 결과는 3번의 표에 덧붙인 것이다)
Source files available in: sources/009-preset-plugin-via-include/, sources/010-alias-three-level-include/, sources/011-root-analysis-after-split/, sources/015-git-dependency-preset-load/, sources/016-next-sdk-forward-compat/, sources/017-runner-six-fixtures/, sources/019-real-consumer-split-invariance/
원본 로그와 JSON: `.planning/spikes/009-preset-plugin-via-include/results/`, `.planning/spikes/010-alias-three-level-include/results/`, `.planning/spikes/011-root-analysis-after-split/results/`, `.planning/spikes/015-git-dependency-preset-load/results/`, `.planning/spikes/016-next-sdk-forward-compat/results/`
