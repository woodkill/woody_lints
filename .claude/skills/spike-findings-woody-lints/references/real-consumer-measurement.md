# 실제 사용 프로젝트의 복사본에서 재기

이 패키지를 실제로 쓰는 프로젝트(`flutter_starter_kit`)의 복사본에 작업 중인 프리셋을 물려 분석하는 부분이다. 두 가지를 다룬다. 하나는 결과 — 프리셋을 나눠도 실제 프로젝트의 진단이 줄 단위로 같다 (Phase 3 의 성공 기준 1 이 연습용 프로젝트 밖에서도 성립한다). 다른 하나는 그 실측에서 굳어진 방법이다 — 복사본 만들기, `woody_lints` 를 작업 중인 파일로 돌리기, 일부러 넣은 위반(표식 파일), 비공개 프로젝트의 결과를 기록하는 법. Phase 4 의 규칙 후보 실측이 이 방법을 쓴다 (019 의 스크립트 자체는 프리셋을 나눈 뒤에 그대로 돌지 않는다 → 2번). 그 뒤 021 ~ 023 이 이 방법을 나눈 뒤의 저장소에 맞게 고친 공용 조각(`sources/021-new-rules-language-gate/consumer.dart`)으로 Phase 4 의 "Spike first" 를 쟀다 — 고친 점은 2번 · 3번 · 7번에, 열마다의 값은 rule-evaluation-table.md 에 있다.

따로 적지 않은 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9 (plugin 쪽 `analyzer` 14.5.0, `analysis_server_plugin` 0.3.24), macOS arm64, 2026-10-12 실측이다 (019). 대상은 `flutter_starter_kit` **하나**이고, 그날의 그 프로젝트 모양(Dart 파일 468개)에서 잰 것이다. 같은 날 021 ~ 023 의 복사본은 469개였다 — 세는 범위(`lib` · `test` · `bin` 의 `.dart`)는 같고, 그 사이 프로젝트가 바뀌었는지는 확인하지 않았다. 다음 SDK 의 베타에서는 돌리지 못했다 (→ Constraints).

이 문서에서 쓰는 말.

- **사용 프로젝트** — `flutter_starter_kit`. **원본**은 그 프로젝트의 실제 폴더, **복사본**은 작업 폴더의 `consumer/` 다.
- **replica** — 이 저장소의 모양(`pubspec.yaml`, `lib/`)을 작업 폴더에 복사한 것. 복사본이 `woody_lints` 를 받는 자리다. 사용 프로젝트의 복사본과 다른 것이다.
- **표식 파일** — 일부러 넣은 위반. 019 는 이 저장소 `example/lib` 의 샘플을 복사본의 `lib/woody_probe_marker/` 에 넣었다 (기본 표식). 021 ~ 023 은 후보 규칙마다의 표식을 같은 폴더 아래에 더했다.
- **프로젝트의 줄** — 진단 가운데 표식 파일의 것이 아닌 줄. 사용 프로젝트 자신의 코드에서 나온 것이다.
- 분석 한 번을 "실행" 이라 부르고 번호가 아니라 id 로 가리킨다 (`V0`, `V1`, `N1u` … → 5번의 표). 다른 spike 의 비슷한 이름 — 016 의 `X1` · `R1`, 015 의 `G-old` · `P-alias`, 014 의 방식 `P` — 과는 다른 실험이고, `D` 는 결정 번호 `D-NN` 이 아니라 실행 하나의 id 다. 스크립트를 처음부터 끝까지 한 번 돌린 것은 "스크립트를 돌렸다" 로 적는다.

"N번" 은 아래의 절 번호다. "성공 기준" 은 ROADMAP.md 의 것이고 phase 를 함께 적었다.

## Requirements

MANIFEST.md 의 `preset-split-include-behavior` 에서 이 영역에 걸리는 것.

소유자가 이전에 확정한 것 (출처는 03-CONTEXT.md, ROADMAP.md).

- 나누는 것은 구조 변경이다. 규칙 목록 · 주석 처리된 줄 · 사유 주석은 옮기기만 한다 — spike 의 조각 파일은 저장소의 배포 파일을 **잘라서** 만들고 손으로 다시 쓰지 않는다
- 실측은 저장소 복사본에서 한다. 저장소의 `lib/`, `pubspec.yaml`, 루트 `analysis_options.yaml`, `example/` 은 바꾸지 않는다
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 하고, 스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다

spike 에서 나와 실제 구현과 실측이 지켜야 하는 것.

- 실제 사용 프로젝트(`flutter_starter_kit` 의 복사본, Dart 파일 468개)에서도 나누기 전후가 줄 단위로 같다 — 지금 받는 그대로(git, 1.3.0) = 한 파일 구조 = 나눈 구조(옛 주소) = 나눈 구조(묶음 주소). 프로젝트 자신의 코드는 지금 0줄(무시 주석이 있는 채의 값 — 그 뒤 023)이라 표식 파일(정답지 16줄)과, `always_specify_types` 를 더 켠 짝(9,398줄이 줄 단위로 같다)으로 확인했다 (019)
- 사용 프로젝트를 재는 실측은 복사본에 `pubspec_overrides.yaml` 로 `woody_lints` 를 작업 중인 파일의 경로로 돌리고, 같은 실행에 일부러 넣은 위반(표식 파일)을 둔다. 0줄을 표식 없이 해석하지 않는다 — `public_member_api_docs` 의 0줄은 규칙이 꺼져서가 아니었다. 그 규칙을 어기는 표식 둘이 같은 실행에서 2줄로 잡혔다 (019)
- `flutter_starter_kit` 의 진짜 생성 파일 62개는 제외가 하나도 없어도 진단이 0줄이다 (2026-10-12, Dart 3.13.4. 57개가 머리에 `ignore_for_file: type=lint` 를 달고 있고, 머리 없는 5개도 지금의 규칙에 걸리지 않는다. 머리를 단 57개의 0줄이 그 머리 때문인지는 가르지 않았다). 012 · 016 의 "프리셋의 제외가 통하지 않는 경우" 는 이 프로젝트에 지금 새 줄을 만들지 않는다. 규칙이 늘면 머리 없는 5개에서 줄이 날 수 있다 (019)
- 사용 프로젝트의 `dev_dependencies` 에 따로 적힌 `riverpod_lint` 줄은 `dart analyze` 의 진단에 영향이 없었다 — 있을 때와 뺐을 때가 같고, plugin 은 어느 쪽에서도 3.1.9 로 풀렸다 (2026-10-12, `flutter_starter_kit` 하나. 그 줄은 프리셋의 선언과 같은 `^3.1.3` 이고 lock 은 3.1.3 이다) (019)
- 비공개인 사용 프로젝트를 잰 기록에는 그 프로젝트의 경로 · 진단 메시지 · 코드 조각을 남기지 않고 건수와 규칙 이름만 남긴다. 소유자가 정한 것이 아니라 spike 가 스스로 건 조건이다 — Phase 4 의 근거 문서가 공개 저장소에 들어가므로 그 논의에서 확인한다 (019)

MANIFEST.md 의 `rule-reselection-measurement` 에서 이 영역(실측의 틀)에 걸리는 것. 나머지는 rule-evaluation-table.md 의 Requirements 에 있다.

- 복사본의 `pubspec_overrides.yaml` 은 `path:` 로 작업 중인 저장소 자체를 가리킨다 — replica 를 만들지 않는다. 받은 자리(`package_config.json` 의 `rootUri`)가 저장소가 아니면 그 회차를 버리고, 실행 전후로 저장소의 지문(`git status`, `.dart_tool/` 의 맨 위 이름, 루트 `package_config.json` · `pubspec.lock`)을 견준다. 두 번의 `pub get` 과 세 번의 분석 뒤에도 저장소는 그대로였다. 이 방법은 `021-new-rules-language-gate/consumer.dart` 에 있다 (021). `dart fix --dry-run` 한 번과 `--apply --code=use_primary_constructors` 한 번도 저장소를 바꾸지 않았다 (022 의 `repo_guard.dart` — 022 의 본 실행은 지문 확인이 깨져 이것으로 다시 확인했다)
- 복사본의 SDK 하한을 바꿀 때는 `pubspec.yaml` 을 고친 뒤 `pub get` 을 한다 (`Consumer.useSdk`). `pubspec.yaml` 만 고치면 `package_config.json` 의 `languageVersion` 이 앞의 값으로 남는다 (022)
- 비공개 프로젝트를 잰 결과에는 건수와 규칙 이름만 남긴다 — 경로 · 진단 메시지 · 코드 조각을 남기지 않는다. 원본의 경로는 스크립트에 적지 않고 인자로 준다 (spike 가 스스로 건 조건, 019 를 잇는다)

"원본 프로젝트는 수정하지 않는다" 는 MANIFEST 가 아니라 PROJECT.md 의 Constraints (Safety) 와 ROADMAP.md Phase 4 Notes 에 적힌 소유자의 조건이다. 019 는 원본을 읽기만 했다.

019 의 README 는 `public_member_api_docs` 의 0줄을 "`lib` 의 공개 선언에 문서 주석이 빠진 곳이 없다" 로 풀었다. 잰 것은 `lib/` 아래에 둔 표식 둘이 2줄로 잡히는데 프로젝트의 줄은 0 이라는 데까지이고, 선언을 하나씩 읽어 확인한 것은 아니다 (→ 3번).

## How to Build It

### 1. 복사본 — 분석에 필요한 것만 옮긴다

원본의 경로는 스크립트에 적지 않고 인자로 받는다. 복사하는 것은 파일 넷(`pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `l10n.yaml` — 있는 것만)과 폴더 넷(`lib`, `test`, `bin`, `assets`)이다. 플랫폼 폴더, `.dart_tool/`, `build/` 는 옮기지 않는다.

```dart
// sources/019-real-consumer-split-invariance/probe.dart 의 Consumer.copy 에서
for (final name in ['pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml', 'l10n.yaml']) {
  final file = File('$source/$name');
  if (!file.existsSync()) continue;
  file.copySync('$dir/$name');
  copied++;
}
for (final name in ['lib', 'test', 'bin', 'assets']) {
  final from = Directory('$source/$name');
  if (!from.existsSync()) continue;
  // 링크는 따라가지 않는다.
  for (final f in from.listSync(recursive: true, followLinks: false).whereType<File>()) {
    final to = File('$dir/$name${f.path.substring(from.path.length)}');
    to.parent.createSync(recursive: true);
    f.copySync(to.path);
    copied++;
  }
}
```

위의 `// 링크는 …` 줄은 여기서 붙인 설명이다.

- 복사본은 작업 폴더의 `consumer/`, replica 는 그 옆의 `replica/` 다 (019 — 나눈 뒤의 021 ~ 023 에는 replica 가 없다 → 2번). 작업 폴더는 저장소 밖에 둔다.
- 스크립트는 시작할 때 복사본의 모양이 예상과 같은지 본다 — 옵션 파일이 옛 주소를 include 하는지, 생성 파일 제외 두 줄이 있는지, `dev_dependencies` 에 `riverpod_lint` 줄이 있는지. 하나라도 다르면 `FormatException` 으로 멈춘다. 옵션 파일을 고칠 때도 바꿀 자리가 **정확히 한 번** 나오는지 확인한다 (`Consumer.replaceOnce`). 사용 프로젝트가 바뀌면 조용히 엉뚱한 것을 재지 않고 멈춘다.
- 원본은 실행 전후로 `git status` 가 깨끗했다. 이 저장소 루트의 `.dart_tool/package_config.json` 도 그대로였다 (`generatorVersion` 3.13.4).

2026-10-12 의 사용 프로젝트에 관해 읽은 것 (수와 설정값뿐이다).

| 무엇 | 값 |
|---|---|
| Dart 파일 | `lib` 에 손으로 쓴 것 172개 + 생성 파일 62개, `test` 233개, `bin` 1개 (합 468개) |
| 생성 파일의 머리 | `*.g.dart` 50개가 `// ignore_for_file: type=lint, type=warning`, `*.g.dart` 5개는 머리 없음, `*.freezed.dart` 7개가 `// ignore_for_file: type=lint` |
| SDK 제약 | `^3.11.1` (Flutter 3.47.5 고정) |
| `woody_lints` | git 의존성 `ref: main`. lock 의 커밋은 `90a2736` (= `v1.3.0`) |
| 옵션 파일 | 옛 주소 한 줄(`include: package:woody_lints/analysis_options.yaml`) + 자기 `analyzer.exclude` (생성 파일 두 줄 `"**/*.g.dart"` · `"**/*.freezed.dart"` 와 플랫폼 폴더들) + 주석뿐인 `linter: rules:` |
| `dev_dependencies` | `riverpod_lint: ^3.1.3` 이 따로 적혀 있다 (lock 은 3.1.3) |

- 머리 주석의 수는 스크립트가 센 것이다 (`Consumer.facts`). "50개는 `riverpod_generator`, 머리 없는 5개는 `json_serializable` 의 산출물" 이라는 갈래는 019 가 원본을 읽어 적은 것이고, 세 생성기의 버전은 기록하지 않았다.
- 프로젝트 자신의 옵션 파일은 규칙을 더 켜지 않는다 (`linter: rules:` 아래가 주석뿐이다). ROADMAP.md Phase 4 의 "Spike first" 둘째 항목 가운데 "프로젝트 자체 옵션이 기준선에 섞이는지" 의 절반이 이것이다. 나머지 절반 — 프로젝트가 직접 적은 `// ignore` 주석이 가리는 줄 — 은 019 가 재지 않았고 그 뒤 023 이 쟀다 (→ rule-evaluation-table.md 7번: 손으로 쓴 파일 다섯 개의 `ignore_for_file: type=lint` 가 lint 26줄을 가린다).

### 2. `woody_lints` 를 작업 중인 파일로 돌린다

복사본의 `pubspec.yaml` 은 고치지 않는다. 옆에 `pubspec_overrides.yaml` 을 두고 `dart pub get` 을 한다. 아래의 `path: ../replica` 는 019 의 모양이다 — 나눈 뒤에는 `path:` 가 작업 중인 저장소 자체를 가리킨다 (이 절 끝의 "나눈 뒤에는").

```yaml
# <작업 폴더>/consumer/pubspec_overrides.yaml
dependency_overrides:
  woody_lints:
    path: ../replica
```

```dart
// sources/019-real-consumer-split-invariance/probe.dart 의 Consumer.ensurePub 에서
if (want == PubState.asReceived) {
  if (overrides.existsSync()) overrides.deleteSync();
  File('$dir/pubspec.yaml').writeAsStringSync(pubspec);
  File('$dir/pubspec.lock').writeAsStringSync(lock);
  // 원본이 받고 있는 그대로 — lock 을 고치지 않고 받는다. 다른 SDK 에서는 통하지 않을 수 있다.
  var result = await pub(['get', '--enforce-lockfile', '--no-example']);
  lockEnforced = result.exitCode == 0;
  if (!lockEnforced!) result = await pub(['get', '--no-example']);
  if (result.exitCode != 0) _fail('원본 그대로의 pub get', result);
} else {
  overrides.writeAsStringSync('dependency_overrides:\n  woody_lints:\n    path: ../replica\n');
  // … pubspec.yaml 은 원본 그대로 (D 에서만 riverpod_lint 줄을 뺀다)
  final result = await pub(['get', '--no-example']);
  if (result.exitCode != 0) _fail('경로를 돌린 pub get', result);
}
```

**받은 자리를 실행마다 읽는다.** `.dart_tool/package_config.json` 에서 `woody_lints` 의 `rootUri` 를 읽는다 — ROADMAP.md Phase 4 의 "Spike first" 셋째 항목("lockfile 이 1.3.0 커밋을 가리키면 엉뚱한 것을 잰다")을 막으려는 것이다. **019 의 스크립트는 이 값을 화면과 결과 파일에 적기만 하고 판정에 넣지 않았다** — `?` 가 나와도 멈추지 않는다. 021 의 `consumer.dart` 가 "작업 중인 저장소를 가리키지 않으면 그 회차를 버린다" 를 코드의 조건으로 적었다 (아래).

```dart
// sources/019-real-consumer-split-invariance/probe.dart 의 Consumer.woodySource 에서
final uri = '${p['rootUri']}';
if (uri.contains('/git/woody_lints-')) return 'git';
final resolved = uri.startsWith('file:')
    ? File.fromUri(Uri.parse(uri)).path
    : Directory('$dir/.dart_tool/$uri').absolute.path;
final real = Directory(resolved).existsSync() ? Directory(resolved).resolveSymbolicLinksSync() : '';
return real == replica.root ? 'replica' : '?';
```

| 실행 | `pub get` | 받은 자리 |
|---|---|---|
| V0 | 원본의 `pubspec.yaml` 과 lock 그대로, `--enforce-lockfile` 이 통했다 | `git` — pub cache 의 `git/woody_lints-<해시>/` |
| V1 ~ D (열두 번) | `pubspec_overrides.yaml` 을 둔 `dart pub get --no-example` | `replica` |

- 경로를 돌린 `pub get` 은 복사본의 `pubspec.lock` 을 고친다. 복사본이라 상관없다. V0 으로 돌아갈 때는 원본의 `pubspec.yaml` 과 lock 을 다시 써넣는다.
- replica 의 `lib/` 는 실행마다 한 파일 구조나 나눈 구조로 바꿔 쓴다 (`Replica.writeLibUnsplit` / `writeLibSplit`). 경로 의존성이라 `pub get` 을 다시 하지 않아도 다음 분석이 바뀐 파일을 읽는다.
- **V0 은 "받아 오는 길" 을 잰 것이 아니다.** 스크립트는 `PUB_CACHE` 를 따로 주지 않았다 — 평소의 pub cache 를 썼고, 그 커밋의 폴더가 이미 받아져 있었는지 그 실행에서 GitHub 에서 받았는지는 기록하지 않았다 (스크립트를 읽은 것이다). 본 것은 받은 **뒤**의 자리가 `git/woody_lints-<해시>/` 라는 것까지다.
- **나눈 뒤(Phase 3 이후)에는 `probe.dart` 가 그대로 돌지 않을 것이다.** `main` 이 `Shipped.read` 로 저장소의 한 파일을 잘라 replica 를 만든다 (스크립트를 읽은 것이고 돌려 보지 않았다 → next-sdk-forward-compat.md 9번). `Consumer` 클래스는 `Replica` 에서 작업 폴더 · replica 의 자리 · 저장소 루트 · 경로 가리기(`scrub`)만 쓰므로 그 부분은 구조와 무관하다.

**나눈 뒤에는 `path:` 가 작업 중인 저장소 자체를 가리킨다 (021).** 021 의 `consumer.dart` 는 019 의 `Consumer` 를 바탕으로 replica 를 없앴다 — 나눈 뒤라 `Shipped` 로 자를 한 파일이 없다. 021 ~ 023 에서 `dart pub get --no-example` 을 여러 번 한 뒤에도 저장소의 지문이 그대로였다 (021 은 두 번 — 물릴 때와 하한을 바꾼 뒤, 022 의 `repo_guard.dart` 는 하한을 바꾼 `pub get` · `dart analyze` · `dart fix --dry-run` · `--apply` 를 한 단계씩 견줬다).

```dart
// sources/021-new-rules-language-gate/consumer.dart 에서
Future<void> pointToRepo() async {
  File('$dir/pubspec_overrides.yaml')
      .writeAsStringSync('dependency_overrides:\n  woody_lints:\n    path: ${repo.root}\n');
  await pubGet();      // dart --suppress-analytics pub get --no-example
}

/// 받은 자리가 작업 중인 저장소가 아니면 그 회차를 버린다.
void ensureRepoSource(Shot shot) {
  if (shot.woodySource != 'repo') {
    throw StateError('${shot.id}: woody_lints 가 작업 중인 저장소를 가리키지 않는다 (${shot.woodySource}) — 이 회차를 쓰지 않는다');
  }
}

/// 저장소가 바뀌었는지 보는 지문 — git 이 보는 변경, 무시되는 `.dart_tool/` 의 맨 위 이름들,
/// 루트 `package_config.json` · `pubspec.lock` 의 해시.
Future<String> fingerprint() async { /* Repo.fingerprint */ }
```

- **"그 회차를 버린다" 는 스크립트 전체가 멈추는 것으로 구현되어 있다.** `ensureRepoSource` 가 `StateError` 를 던지고 021 ~ 023 의 스크립트는 잡지 않아 결과 파일도 쓰지 않는다. 021 ~ 023 의 본 실행은 저장소 지문을 처음과 끝에서만 견줬다 (단계마다 본 것은 `repo_guard.dart`).
- `woodySource()` 는 링크를 푼 `rootUri` 가 저장소 루트와 같으면 `repo`, pub cache 의 `git/woody_lints-` 면 `git`, 그 밖은 `?` 를 돌려준다. `Consumer.analyze` 가 분석마다 이 값을 `Shot` 에 담는다.
- 복사본의 SDK 하한을 바꿀 때는 `useSdk` 로 `pubspec.yaml` 을 고치고 `pub get` 까지 한다. `pubspec.yaml` 만 되돌리면 `package_config.json` 의 `languageVersion` 이 앞의 값으로 남는다 (021 의 끝에서 그랬다 — 측정 뒤라 결과와는 상관없다. 022 가 찾아 고쳤다). `pubspecWithSdk` 는 원본의 `\n  sdk: ^3.11.1\n` 줄을 정확히 한 번 찾아 바꾼다 — 사용 프로젝트의 하한이 바뀌면 `FormatException` 으로 멈춘다.
- `dart fix --apply` 로 고친 소스는 `refreshSources` 로 원본의 것으로 되돌린다 (표식은 다시 넣는다 — 022).
- 저장소의 지문을 견주는 실측이 도는 동안에는 저장소 안에 파일을 만들지 않는다. 022 의 첫 실행에서 다음 spike 의 폴더를 저장소 안에 만들어 "저장소가 그대로다" 가 깨졌다 (`.planning/spikes/CONVENTIONS.md`).

### 3. 표식 파일 — 0줄을 해석하기 전에 둔다

이 저장소 `example/lib` 의 위반 샘플 일곱 개를 복사본의 `lib/woody_probe_marker/` 에 넣는다. 표식 파일은 사용 프로젝트의 옵션 파일을 거쳐 분석되므로, 그 줄이 `example/` 의 정답지 16줄과 같으면(경로의 `lib/` 를 `lib/woody_probe_marker/` 로 바꿔 견준다) 규칙과 plugin 이 실제 프로젝트의 설정 위에서 그대로 적용된 것이다.

```dart
// sources/019-real-consumer-split-invariance/probe.dart 의 Consumer.addMarkers 에서
final from = Directory('${replica.repoRoot}/example/lib');
for (final f in from.listSync(recursive: true).whereType<File>()) {
  final to = File('$dir/$markerRel${f.path.substring(from.path.length)}');
  to.parent.createSync(recursive: true);
  f.copySync(to.path);
}
```

표식이 없었다면 틀린 결론을 적었을 자리가 019 에 있었다.

| 순서 | 한 것 | 나온 것 |
|---|---|---|
| 1 | 구조를 바꿔 가며 네 번 분석 | 네 번 모두 16줄. 전부 표식 파일의 줄이고 **프로젝트의 줄은 0** 이다 |
| 2 | 프로젝트의 줄을 내려고 `public_member_api_docs` 를 더 켬 | 여전히 0줄. "`publish_to: 'none'` 인 앱이라 규칙이 적용되지 않는다" 는 추정을 세웠다 |
| 3 | `publish_to` 줄을 뺀 실행을 더함 | 그래도 0줄 — 추정대로라면 줄이 나와야 했다 |
| 4 | 문서 주석이 없는 공개 선언 둘을 표식으로 더함 | `publish_to` 가 있든 없든 **2줄** (표식 2, 프로젝트 0) |

- **`public_member_api_docs` 는 앱 프로젝트에서도 켜진다.** `publish_to: 'none'` 과 상관없다. 2의 추정은 틀렸다.
- 프로젝트의 0줄은 "규칙이 `lib/` 아래에서 켜져 있는데도 0줄" 이다. 이 저장소의 샘플 일곱 개도 모두 문서 주석이 달려 있어 2 · 3에서 표식의 줄이 0 이었다 — **기본 표식이 그 규칙을 어기지 않으면 표식이 있어도 가르지 못한다.**
- 그래서 후보 규칙마다 그 규칙을 어기는 표식이 있는지 본다. 없으면 그 실행에만 두는 표식을 더한다 (`extraMarker` — `lib/woody_probe_marker/extra_marker.dart` 에 쓰고 분석이 끝나면 지운다. 남겨 두면 다른 실행의 표식 줄이 정답지 16줄과 달라진다). `extraMarker` 는 `main` 안의 지역 함수 `shoot` 의 인자다 — import 로 받지 못하고 옮겨 적는다.
- **019 의 스크립트에서 표식이 판정에 들어간 자리는 둘뿐이다** — V0 과 V2 의 표식 줄이 정답지 16줄과 같은가. P0 · P1 의 표식 2줄은 화면과 결과 파일에 적은 기록이고 판정이 아니다. Phase 4 의 성공 기준 2 를 채우려면 "그 규칙을 어기는 표식이 보고되지 않으면 그 회차의 수치를 쓰지 않는다" 를 판정으로 넣는다. 023 은 후보마다 그 규칙을 어기는 표식이 걸리는지를 판정에 넣었다. 021 은 대조 셋만 판정이고 규칙별 표식 수는 결과 파일에 기록했다 (`perRule`). 022 는 규칙마다의 표식이 없다 (→ rule-evaluation-table.md 9번).

```dart
// sources/019-real-consumer-split-invariance/probe.dart 에서
/// [appBlindRule] 이 실제로 켜졌는지 가르는 표식 — 문서 주석이 없는 공개 선언 둘.
/// 이것마저 0줄이면 "코드가 깨끗해서" 가 아니라 "규칙이 이 프로젝트에 적용되지 않아서" 다.
const undocumentedSample = 'class UndocumentedPublicClass {}\n\nvoid undocumentedPublicFunction() {}\n';
```

ROADMAP.md Phase 4 의 성공 기준 2 ("일부러 넣은 위반이 보고되지 않은 회차의 수치는 쓰이지 않았다") 가 막으려는 것이 이 경우다. "Spike first" 첫째 항목(Dart 3.13 신규 규칙이 language version 3.11 프로젝트에서 보고되는지)은 019 가 재지 않았다 — 켜 본 두 규칙은 새 규칙이 아니다. 그 뒤 021 이 같은 방식(그 규칙을 어기는 표식)으로 갈랐다 — 새 규칙 6개는 지금 하한(`^3.11.1`)에서 표식까지 0줄이었다 (→ rule-evaluation-table.md 6번).

### 4. 사용 프로젝트의 옵션 파일을 바꿔 가며

복사본의 옵션 파일을 실행마다 고쳐 쓰고 끝나면 원본의 내용으로 되돌린다 (`Consumer.optionsWith` → `setOptions`).

| 바꾸는 것 | 방법 |
|---|---|
| include 주소 | 옛 주소 한 줄을 묶음 주소 · `base.yaml` · 조각의 목록으로 바꾼다 |
| 규칙을 하나 더 켬 | `  rules:` 줄 바로 아래에 `    <규칙 이름>: true` 를 끼운다 (맵 문법) |
| 직접 적은 생성 파일 제외 | 두 줄을 뺀다 |
| `pubspec.yaml` 의 `publish_to` | 그 줄만 빼고 분석한 뒤 되돌린다 (받은 패키지는 그대로라 `pub get` 을 다시 하지 않는다) |

- 사용 프로젝트가 맵 문법으로 더 켠 규칙은 옛 주소 → 묶음 → 조각의 3단 include 위에 그대로 얹힌다 (N1u = N1s). 프리셋은 목록 문법이다 — 두 문법이 include 를 사이에 두고 합쳐지는 것을 본 것이고, 한 파일 안에서 섞은 것은 아니다.
- 분석은 복사본을 작업 디렉터리로 두고 인자 없이, `--suppress-analytics` 를 붙이고, 실행마다 빈 상태 폴더를 준다 (`Replica.analyze` — analyze-run-and-verdict.md 의 실행 형태 그대로다).

### 5. 결과 — 나누기 전후가 줄 단위로 같다

분석 열세 번(합계 277초), 판정에 넣은 확인 20건이 모두 성립했다.

| id | `woody_lints` 를 받는 방식 | 사용 프로젝트의 옵션 | 줄 | 표식 | 프로젝트 | `exit` | 시간 | plugin 폴더 |
|---|---|---|---|---|---|---|---|---|
| V0 | git, lock 그대로 (1.3.0) | 원본 그대로 | 16 | 16 | 0 | 2 | 22.1초 | 1 |
| V1 | replica, 한 파일 구조 | 원본 그대로 | 16 | 16 | 0 | 2 | 22.1초 | 1 |
| V2 | replica, 나눈 구조 | 원본 그대로 (옛 주소) | 16 | 16 | 0 | 2 | 23.7초 | 1 |
| V3 | replica, 나눈 구조 | include 를 묶음 주소로 | 16 | 16 | 0 | 2 | 22.1초 | 1 |
| X1 | replica, 나눈 구조 | include 를 `base.yaml` 로 (대조) | 14 | 14 | 0 | 2 | 6.8초 | 0 |
| G2u | replica, 한 파일 구조 | 직접 적은 제외 두 줄을 뺌 | 16 | 16 | 0 | 2 | 22.2초 | 1 |
| G2s | replica, 나눈 구조 | 직접 적은 제외 두 줄을 뺌 | 16 | 16 | 0 | 2 | 25.0초 | 1 |
| G3 | replica, 나눈 구조 | 제외 두 줄을 빼고 `base` + `riverpod` 만 (대조) | 21 | 21 | 0 | 2 | 23.4초 | 1 |
| N1u | replica, 한 파일 구조 | `always_specify_types` 를 더 켬 | 9,398 | 24 | 9,374 | 2 | 22.7초 | 1 |
| N1s | replica, 나눈 구조 | `always_specify_types` 를 더 켬 | 9,398 | 24 | 9,374 | 2 | 21.6초 | 1 |
| P0 | replica, 나눈 구조 | `public_member_api_docs` 를 더 켬 + 표식 둘 | 18 | 18 | 0 | 2 | 22.3초 | 1 |
| P1 | replica, 나눈 구조 | 같음, `publish_to` 줄도 뺌 | 18 | 18 | 0 | 2 | 21.7초 | 1 |
| D | replica, 나눈 구조 | 원본 그대로. `pubspec.yaml` 에서 `riverpod_lint` 줄을 뺌 | 16 | 16 | 0 | 2 | 21.5초 | 1 |

- **V0 = V1 = V2 = V3.** 지금 받는 그대로와 한 파일 구조, 나눈 구조의 옛 주소와 묶음 주소가 16줄 · `exit 2` 로 같고, 표식 파일의 줄이 `example/` 의 정답지 16줄과 같다. 멈춤 조건(V2 ≠ V1)에 해당하지 않았다.
- **대조가 달라졌다 (X1).** `base.yaml` 만 받으면 표식 파일에서 plugin 3줄이 빠지고 `invalid_annotation_target` 1줄이 생겨 14줄이 되고, plugin 을 준비하지 않는다. fixtures-after-split.md 2번의 "기본만 18줄" 보다 4줄 적은 것은 사용 프로젝트가 직접 적은 제외가 표식 파일의 생성 파일 샘플 4줄을 막아서다.
- **프로젝트의 줄이 나올 때도 같다 (N1u = N1s).** 9,398줄이 줄 단위로 같다. 그중 9,374줄이 프로젝트의 줄이고 (`lib` 1,524 · `test` 7,739 · `bin` 111, 전부 info) 24줄이 표식 파일의 줄이다. "0줄 = 0줄" 로 헛통과한 것이 아니다. 다만 프로젝트의 줄을 낸 것은 이 규칙 하나(info)이고, 이 짝으로 견준 것은 한 파일 구조와 나눈 구조의 옛 주소다 (묶음 주소로는 이 짝을 돌리지 않았다). 프로젝트의 코드에서 나온 plugin 진단은 모든 실행에서 0 이라, plugin 쪽의 "같다" 는 표식 파일의 3줄로 본 것이다.
- 나눈 구조는 저장소의 한 파일을 자른 것이라 `riverpod_lint` 선언이 `^3.1.3` 이다. Phase 3 이 올릴 `^3.1.9` 로 본 것은 아니다 (둘 다 3.1.9 로 풀리는 동안에는 결과가 같다 — 010).
- **옆 폴더(`path:`)로 받은 것이 git 으로 받은 것과 같다 (V1 = V0).** 015 가 연습용 프로젝트에서 본 것이 실제 프로젝트에서도 성립한다 (한 파일 구조, 1.3.0 의 커밋으로 본 것이다 — 나눈 구조를 git 으로 받은 실제 프로젝트는 아직 없다). 두 실행은 받는 방식과 함께 패키지의 `pubspec.yaml` 두 줄도 다르다 — V0 은 1.3.0 의 것(`version: 1.3.0`, `sdk: ^3.10.4`), V1 은 작업 브랜치의 것(`version: 2.0.0-dev`, `sdk: ^3.13.0`)이다. `lib/analysis_options.yaml` 의 내용은 같다 (`git diff 90a2736 HEAD -- lib/` 가 비어 있었다 — 2026-10-12 의 다섯째 wrap-up(017 ~ 019)에서 확인. 그 뒤 Phase 3 이 `lib/` 를 나눴다).
- **직접 적은 제외를 빼도 나누기 전후가 같다 (G2s = G2u).** 표식 파일의 생성 파일 샘플에는 규칙 위반 4줄이 있는데, 프리셋의 제외만으로 그 4줄이 막혀 16줄 그대로다 (Dart 3.13.4 — suppression-and-exclude.md 6번의 "규칙 진단에는 통한다").
- **제외가 어디에도 없어도 진짜 생성 파일 62개에서는 0줄이다 (G3).** 표식 파일에서는 예상대로 5줄이 더 나와 21줄이 됐고(생성 파일 샘플 4 + `invalid_annotation_target` 1), 프로젝트의 줄은 규칙 0 · plugin 0 이다. **0줄의 까닭은 가르지 않았다** — 57개는 `type=lint` 머리를 달고 있지만 그 머리가 막은 것인지 애초에 걸릴 코드가 없는 것인지는 이 실행으로 알 수 없다 (머리 없는 5개는 머리 없이 0줄이다).
- `invalid_annotation_target` 은 codegen 조각을 받지 않는 G3 에서도 프로젝트의 줄이 0 이다 (표식 파일의 1줄만 나온다). 03-CONTEXT.md 가 "Phase 4 의 실측에 더할 수 있다" 로 미뤄 둔 질문("이 설정을 풀면 경고가 몇 건 나오나")의 값이다. 지울지를 정한 것은 아니다.
- **`dev_dependencies` 의 `riverpod_lint` 줄은 진단에 영향이 없다 (D = V2).** plugin 은 옵션 파일의 `plugins:` 로 받는다. plugin 을 쓰는 열두 실행 모두 `riverpod_lint` 3.1.9 / `analyzer` 14.5.0 / `analysis_server_plugin` 0.3.24 로 풀렸고, 서버가 받은 선언은 `^3.1.3` 이다. 사용 프로젝트의 lock 에 적힌 3.1.3 과 무관하다.
- 시간: plugin 을 쓰는 실행이 21.5 ~ 25.0초, 쓰지 않는 X1 이 6.8초다. 실행마다 빈 상태 폴더를 줬으므로 plugin 준비가 들어 있다. 상태 폴더를 이어 쓰면 더 짧을 것이다 (재지 않았다).

### 6. 비공개 프로젝트의 결과를 기록하는 법

`flutter_starter_kit` 은 비공개 저장소이고 이 저장소의 작업 브랜치는 공개된다. 요구 사항의 "건수와 규칙 이름만 남긴다" 는 **진단에 관해** 남기는 것을 줄여 말한 것이다. 스크립트가 결과 파일(`results/*.json`, `*.log`)에 실제로 쓰는 것은 아래 표의 왼쪽이다.

| 남기는 것 | 남기지 않는 것 |
|---|---|
| 줄 수 (전체 / 표식 / 프로젝트), `exit`, 시간, plugin 폴더 수와 풀린 버전 | 사용 프로젝트의 파일 경로 |
| 프로젝트의 줄을 자리(`lib` / `test` / `bin`) · 강도 · 규칙 이름으로 묶어 센 수 | 진단 메시지 |
| 프로젝트의 줄 목록의 해시 (64비트 FNV-1a) | 코드 조각 |
| 표식 파일의 줄 전문 (이 저장소의 샘플이다) | stdout 을 그대로 저장한 화면 기록 |
| 사용 프로젝트에 관한 수와 설정값 (`Consumer.facts` — Dart 파일 수, 생성 파일의 머리별 수, SDK 제약, lock 의 `woody_lints` 커밋, 옵션 파일과 `dev_dependencies` 가 예상한 모양인지) | |

```dart
// sources/019-real-consumer-split-invariance/probe.dart 에서
/// 64비트 FNV-1a. 경로를 드러내지 않고 "줄 목록이 같다" 를 견줄 수 있게 한다.
String digest(Iterable<String> lines) {
  var hash = 0xcbf29ce484222325;
  for (final unit in utf8.encode(lines.join('\n'))) {
    hash = (hash ^ unit) * 0x100000001b3;
  }
  String half(int v) => (v & 0xffffffff).toRadixString(16).padLeft(8, '0');
  return half(hash >> 32) + half(hash);
}
```

- 줄 단위 기록(실행별 진단 줄, 두 실행의 차이)은 `<작업 폴더>/private/` 에만 쓴다. 저장소 밖이고 커밋하지 않는다.
- 두 실행이 다를 때 화면에 찍는 것은 `+` / `-` 와 규칙 이름별 건수다. 어느 파일의 어느 줄인지는 `private/` 에서 읽는다.
- 프로젝트의 줄이 0 이면 해시는 `cbf29ce484222325` (빈 목록의 값)다. 결과 파일에서 이 값이 보이면 견준 줄이 없었다는 뜻이다.
- 커밋 전에 결과 폴더를 로컬 경로 점검과 함께 `grep -rn -o -E '(lib|test|bin|assets)/[A-Za-z0-9_./-]+\.(dart|json|arb|yaml)' <폴더>/results | grep -v woody_probe_marker` 로 훑는다 (`.planning/spikes/CONVENTIONS.md`). 보조 점검이다 — 스크립트가 애초에 경로를 쓰지 않는 것이 먼저다. 019 의 결과 폴더는 이 패턴으로 0줄이었다 (2026-10-12).
- **이 조건은 소유자가 정한 것이 아니다.** 019 가 스스로 건 것이고, Phase 4 의 근거 문서(DOCS-11)가 공개 저장소에 들어가므로 그 논의에서 확인한다. **"수와 설정값" 까지 남겨도 되는지도 확인할 범위에 든다** — 019 의 README 와 결과 파일에는 이미 그 값들(파일 468개, SDK 제약 `^3.11.1`, lock 의 커밋 `90a2736`, `riverpod_lint: ^3.1.3` 줄이 있다는 것, 생성 파일의 머리별 수)이 적혀 있다.

### 7. Phase 4 의 실측이 가져갈 것

- **기준선은 "무시 주석이 있는 채로" 0줄이다.** 2026-10-12 의 `flutter_starter_kit` 은 1.3.0 의 규칙 12개 · 기반 세트 · `riverpod_lint` 에 걸리는 줄이 없다 (019). 다만 손으로 쓴 파일 다섯 개가 `ignore_for_file: type=lint` 를 달아 lint 26줄(이 패키지의 `prefer_final_locals` 4줄 포함)을 가리고 있다 (023 — 그 파일들의 `riverpod_lint` 진단도 가려져 있을 것이다. `type=lint` 가 plugin 진단을 끈다는 012 의 결과를 옮긴 추론이다). ROADMAP.md Phase 4 Notes 의 "기준선(1.3.0) 대비 차이만 규칙의 값으로 쓴다" 에서, 지금 하한의 복사본으로 잰 후보 규칙의 값은 그 규칙의 줄 수 그대로가 된다. **복사본의 하한을 올려 잴 때는 기준선을 다시 잰다** — 하한을 `^3.13.0` 으로 올리는 것만으로 기반 세트의 `prefer_initializing_formals` 가 27줄을 냈다 (021 → rule-evaluation-table.md 6번 · 7번).
- **회차마다 일부러 넣은 위반을 둔다** (3번). 그 규칙을 어기는 표식이 보고되지 않은 회차의 0줄은 쓰지 않는다 — 019 의 스크립트에는 이 문턱이 판정으로 들어 있지 않다. 023 의 스크립트에는 후보마다 들어 있고, 021 은 대조 셋만이다.
- **받은 자리를 회차마다 확인하고, 다르면 그 회차를 버린다** — 019 의 `woodySource` 는 값을 돌려줄 뿐이었고, 021 의 `consumer.dart` 의 `ensureRepoSource` 가 버리는 조건이다 (2번).
- `lib` 와 `test` 를 나눠 세는 것은 `Diag.area` 가 한다 (경로의 첫 폴더로 가른다).
- 켜 본 규칙 둘의 값: `always_specify_types` 는 9,374줄 (`lib` 1,524 · `test` 7,739 · `bin` 111), `public_member_api_docs` 는 0줄이다 (그 규칙을 어기는 표식 둘은 2줄로 잡혔다. `type=lint` 를 단 손으로 쓴 파일 다섯은 보지 못한 채의 값이다 — 023). 뒤의 것은 프리셋에 주석 처리되어 있는 줄을 다시 볼 때의 값이다.
- 분석 한 번이 약 22초다 (빈 상태 폴더, plugin 준비 포함). 열세 번에 277초, 스크립트 전체로 약 5분이다.
- 결과에 사용 프로젝트의 경로 · 메시지 · 코드 조각을 남기지 않는다 (6번 — 논의에서 확인할 조건이다).

### 8. Phase 5 의 README 가 가져갈 것

- **"`dev_dependencies` 의 `riverpod_lint` 는 진단에 필요 없다" 는 실측으로 받쳐진다** (D = V2). 그 줄을 지우라고 안내할지는 Phase 5 가 정한다 — 그 줄이 다른 용도(IDE, 다른 도구)로 쓰이는지는 보지 않았다. 본 것은 프로젝트 하나, `dart analyze`, 그 줄의 제약이 프리셋의 선언과 같은 `^3.1.3` 인 경우다.
- "생성 파일 제외는 사용 프로젝트의 옵션 파일에 직접 적는다" 는 안내(→ suppression-and-exclude.md 7번)는 `flutter_starter_kit` 이 이미 하고 있는 모양이다. 그 두 줄을 지워도 2026-10-12 에는 진단이 달라지지 않았다 (G2u · G2s · G3 에서 프로젝트의 줄이 0). 다만 규칙이 늘면 머리 없는 생성 파일 5개에서 줄이 날 수 있고, 제외는 분석할 파일 수도 줄인다 (시간은 재지 않았다).

## What to Avoid

- **표식 없이 0줄을 "깨끗하다" 나 "이 규칙은 이 프로젝트에 적용되지 않는다" 로 적는 것.** 019 에서 표식 없이 세운 추정(`publish_to: 'none'` 탓)이 틀렸다.
- **기본 표식(정답지 16줄)이 있으니 어느 규칙이든 가를 수 있다고 보는 것.** 이 저장소의 샘플은 `public_member_api_docs` 를 어기지 않았다. 후보 규칙을 어기는 표식이 따로 필요하다.
- **"같다" 를 0줄끼리 견줘 확인하는 것.** 줄이 많이 나오는 규칙을 양쪽에 더 켠 짝(N1u / N1s)을 둔다.
- **복사본의 `pubspec.yaml` 에서 `woody_lints` 줄을 직접 고치는 것.** 원본과 달라진 자리가 늘어난다. `pubspec_overrides.yaml` 을 쓴다.
- **`pub get` 만 하고 받은 자리를 확인하지 않는 것.** lock 이 1.3.0 의 커밋을 가리킨 채면 작업 중인 파일이 아니라 옛 것을 잰다.
- **원본에서 `dart analyze` 나 `pub get` 을 돌리는 것.** 원본은 읽기만 한다 (PROJECT.md).
- **복사본의 의존성을 고쳐 가며 다른 SDK 에서 돌리는 것.** 베타에서 `pub get` 이 풀리지 않았을 때 019 는 거기서 멈췄다 — 고친 프로젝트는 실제 프로젝트가 아니다.
- **사용 프로젝트의 진단 줄을 `results/` 에 그대로 쓰는 것, stdout 을 그대로 저장하는 것.** 경로와 메시지가 공개 저장소에 들어간다.
- **G3 의 0줄을 "`type=lint` 머리가 진단을 막았다" 의 근거로 쓰는 것.** 까닭을 가르지 않았다 (5번).
- **V0 을 "GitHub 에서 받아 오는 길을 확인했다" 로 읽는 것.** 평소의 pub cache 를 썼다 (2번).
- **한 프로젝트의 값을 사용 프로젝트 다섯의 값으로 적는 것.** 잰 것은 `flutter_starter_kit` 하나다.

## Constraints

- 사용 프로젝트 하나, SDK 하나, 하루의 값이다. 사용 프로젝트는 계속 바뀌므로 파일 수 · 줄 수는 2026-10-12 의 것이다 (lock 의 `woody_lints` 커밋 `90a2736`).
- 스크립트를 네 번 돌렸다. 첫째(분석 아홉 번, 확인 17건 성립), 둘째(`public_member_api_docs` 를 더 켬 — "프로젝트의 줄이 나온다" 는 확인이 실패해 스크립트가 종료 코드 1), 셋째(`always_specify_types` 로 바꾸고 `publish_to` 를 뺀 실행을 더함), 넷째(표식 둘을 넣고 처음부터 — 위 5번의 표). 5번의 수치는 넷째의 것이다.
- **다음 SDK 의 베타(Flutter 3.49.0-0.2.pre / Dart 3.14.0-211.1.beta)에서는 돌리지 못했다.** 복사본의 첫 `pub get` 에서 의존성 풀이가 실패해 스크립트가 종료 코드 69 로 끝났다. 까닭은 이 패키지가 아니라 사용 프로젝트의 의존성이다 — 베타의 `flutter_test` 가 고정하는 `matcher` · `test_api` 와 프로젝트가 적어 둔 `test` · `freezed` 의 제약이 함께 풀리지 않았다 (`pub` 은 `freezed` 를 다음 major 로 올리라고 제안했다). 결과 파일은 없다. 연습용 프로젝트 수준의 베타 결과는 next-sdk-forward-compat.md 에 있다.
- 사용 프로젝트의 SDK 제약은 `^3.11.1` 이다. language version 이 낮은 프로젝트에서 Dart 3.13 의 새 규칙이 보고되는지는 019 가 재지 않았고 그 뒤 021 이 쟀다 — 6개는 돌지 않는다 (→ rule-evaluation-table.md 6번).
- `pubspec_overrides.yaml` 의 동작은 019 가 실행으로 본 것이다 — 그 파일을 둔 `dart pub get` 이 통하고 `rootUri` 가 replica 를 가리켰다. 공식 문서의 문장은 인용하지 않았다.
- `Consumer` 와 `Diag` · `digest` 는 `dart:io`, `dart:convert` 만 쓴다. `probe.dart` 는 `../009-preset-plugin-via-include/replica.dart` 를 import 한다 (`Replica`, `Run`, `Shipped`, `Expected`, `Checks`, `diffLines`, `annotationLine`, `guard`).
- 확인하지 않은 것: 다음 SDK 에서의 실제 프로젝트, 학습용 프로젝트 넷(`webtoon`, `toonflix`, `pomodoro`, `state` — Riverpod 과 코드 생성을 쓰지 않는 작은 프로젝트다), 규칙을 더 켠 상태에서 생성 파일의 제외를 뺀 경우 (`always_specify_types` 의 짝은 직접 적은 제외가 있는 채로 쟀다), 상태 폴더를 이어 썼을 때의 시간, 생성 파일을 제외했을 때와 아닐 때의 분석 시간, `freezed` · `json_serializable` · `riverpod_generator` 의 버전과 다른 버전이 내는 머리, 나눈 뒤의 저장소에서 019 의 스크립트를 돌린 것, IDE 에서의 모습, GitHub Linux runner 에서의 같은 실행.
- 019 가 확인하지 않고 남긴 것 가운데 그 뒤 잰 것: 사용 프로젝트가 직접 적은 `// ignore` 주석이 가리는 줄의 수 (023), Dart 3.13 의 새 규칙이 이 프로젝트에서 보고되는지 (021), `dart fix` 로 고쳐지는 건수 (022), `path:` 가 작업 중인 저장소 자체를 가리킬 때 (021, 022), 나눈 뒤의 저장소에서 이 방법을 쓴 것 (021 ~ 023 의 `consumer.dart` — 019 의 스크립트 자체는 아니다). 값은 rule-evaluation-table.md 에 있다.

## Origin

Synthesized from spikes: 019 (대조 기준은 009 의 조합별 예상과 `example/` 의 정답지, 012 · 016 의 생성 파일 제외 표, 015 의 "git 과 `path:` 가 같다" 다). 나눈 뒤의 방법(`path:` 가 저장소 자체, `ensureRepoSource`, 저장소 지문, `useSdk`)은 021 · 022 에서 덧붙였다
Source files available in: sources/019-real-consumer-split-invariance/ (`probe.dart`), sources/009-preset-plugin-via-include/ (`replica.dart`), sources/021-new-rules-language-gate/ (`consumer.dart`), sources/022-dart-fix-dry-run-count/ (`repo_guard.dart`)
원본 로그와 JSON: `.planning/spikes/019-real-consumer-split-invariance/results/` — `probe-3.13.4.{json,log}` 이 넷째(마지막) 실행, `-run1` · `-run2` · `-run3` 이 그 앞의 세 실행이다. 사용 프로젝트의 경로와 메시지는 들어 있지 않다
