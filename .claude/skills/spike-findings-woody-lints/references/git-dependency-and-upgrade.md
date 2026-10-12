# git 의존성으로 받기와 버전 올리기

사용 프로젝트가 이 패키지를 **받는 방식**에 관한 부분이다. 나눈 구조를 `path:` 가 아니라 git 의존성으로 받았을 때의 모양, 받은 쪽의 `pubspec.lock` 이 새 커밋을 언제 따라가는지, 그래서 README 의 "버전 올리기" 안내(Phase 5)와 릴리스 · smoke test(Phase 6)가 무엇을 적고 무엇을 봐야 하는지를 다룬다.

따로 적지 않은 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9 (plugin 쪽 `analyzer` 14.5.0, `analysis_server_plugin` 0.3.24), git 2.56.0, macOS arm64, 2026-10-12 실측이다 (015). replica 를 **로컬 git 저장소**로 만들어 커밋하고, replica 밖에 둔 사용 프로젝트가 그것을 `git:` 의존성으로 받았다. GitHub 에는 아무것도 올리지 않았다. 두 번 돌려 판정 29건이 두 번 모두 성립했다.

"실제 사용 프로젝트" 라고 적은 줄은 019 가 같은 날 `flutter_starter_kit` 의 복사본으로 잰 것이다 — 그 프로젝트가 지금 받고 있는 그대로(git 의존성 `ref: main`, lock 의 커밋 = 1.3.0)와 옆 폴더(`path:`)로 돌려 받은 것을 견줬다 (→ real-consumer-measurement.md).

이 문서에서 "받는 쪽" 은 사용 프로젝트, "학습용 프로젝트" 는 사용 프로젝트 5개 가운데 `flutter_starter_kit` 을 뺀 넷, "A · B · C" 는 실험용 저장소의 커밋이다 — A 는 한 파일 구조(1.3.0 의 모양), B 는 나눈 구조, C 는 브랜치 `no-riverpod` 에 둔 "묶음에서 `riverpod.yaml` 을 뺀" 커밋이다.

## Requirements

MANIFEST.md 의 `preset-split-include-behavior` 에서 이 영역에 걸리는 것.

소유자가 이전에 확정한 것 (출처는 03-CONTEXT.md, ROADMAP.md).

- 파일 이름은 `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml` 이고, `lib/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 한 줄짜리 별칭이다
- 실측은 저장소 복사본에서 한다. 저장소의 `lib/`, `pubspec.yaml`, 루트 `analysis_options.yaml`, `example/` 은 바꾸지 않는다
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 하고, 스크립트는 Dart 이며 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다

spike 에서 나와 실제 구현과 문서가 지켜야 하는 것.

- `path:` 의존성으로 잰 009 ~ 012 의 결과는 git 의존성(패키지가 pub cache 의 `git/<저장소 이름>-<커밋 해시>/` 에 놓인다)에서도 줄 단위로 같다 — 3단 include 의 plugin 로드, 옛 주소 · 묶음 주소의 정답지 일치, 조합별 진단, 생성 파일 제외의 모양. 연습용 프로젝트를 git 의존성으로 따로 두지 않는다. 받아 오는 길(GitHub 주소, 실제 tag)은 Phase 6 의 smoke test 가 본다 (015)
- 버전 올리기 안내는 받는 방식에 따라 다르게 적는다. tag 로 고정한 프로젝트는 `ref:` 를 고치고 `pub get`, `ref: main` 을 따르는 프로젝트는 `pub upgrade woody_lints` 다 — `ref: main` 의 `pub get` 은 lock 의 커밋에 머문다. `ref:` 만 고치고 `--enforce-lockfile` 을 돌리면 종료 코드 65 다 (015)
- 사용 프로젝트의 `dev_dependencies` 에 따로 적힌 `riverpod_lint` 줄은 `dart analyze` 의 진단에 영향이 없었다 — 있을 때와 뺐을 때가 같고, plugin 은 어느 쪽에서도 3.1.9 로 풀렸다 (2026-10-12, `flutter_starter_kit` 하나. 그 줄은 프리셋의 선언과 같은 `^3.1.3` 이고 lock 은 3.1.3 이다) (019)

첫 줄의 "009 ~ 012 의 결과" 가운데 git 으로 **다시 잰 칸**은 아래 2번의 표에 있는 것이다. 다시 재지 않은 것은 Constraints 에 적었다.

## How to Build It

### 1. 받은 패키지가 놓이는 자리

| 의존성 | `.dart_tool/package_config.json` 의 `woody_lints` 자리 | `pubspec.lock` 의 항목 |
|---|---|---|
| `git: {url: <저장소>, ref: main}` | `<PUB_CACHE>/git/<저장소 이름>-<커밋 해시>/` | `source: git`, `ref: main`, `resolved-ref: <커밋 해시>` |
| `path: ../replica` | `../../replica` (프로젝트 옆) | `source: path` |

- 폴더 이름은 **저장소 이름 + 커밋 해시**다. 실험에서는 `replica-<해시>` 였다. 실제 사용 프로젝트의 복사본에서는 `package_config.json` 의 `rootUri` 가 pub cache 의 `git/woody_lints-…` 를 가리켰다 (019 — 원본의 `pubspec.yaml` 과 lock 그대로 `--enforce-lockfile` 로 받은 실행). 그 실행은 평소의 pub cache 를 썼고, 그 폴더가 이미 있었는지 그때 GitHub 에서 받았는지는 기록하지 않았다 — 받아 오는 길을 잰 것은 아니다.
- 커밋마다 폴더가 따로 생긴다. 실험이 끝났을 때 A · B · C 셋이 있었다.
- `pubspec.yaml` 의 `dependencies` 에 둔 `flutter_lints` 는 git 의존성에서도 받는 쪽으로 전달됐다 — 기반 세트의 `prefer_is_empty` 줄이 그대로 나온다.

### 2. 나눈 구조는 git 으로 받아도 같다

`example/` 의 샘플을 받는 쪽에 복사하고 옵션 파일만 바꿔 가며 분석했다.

| id | 받은 커밋 | 받는 쪽의 옵션 | 단 | exit | 진단 | plugin 폴더 | 기대와 |
|---|---|---|---|---|---|---|---|
| G-old | A (한 파일 구조) | 옛 주소 한 줄 | 1 | 2 | 16줄 | 1 | 정답지와 같음 |
| G-alias | B (나눈 구조) | 옛 주소 한 줄 | 3 | 2 | 16줄 | 1 | **정답지와 같음** |
| G-bundle | B | 묶음 주소 한 줄 | 2 | 2 | 16줄 | 1 | **정답지와 같음** |
| G-base-riverpod | B | `base.yaml` + `riverpod.yaml` | 1 | 2 | 21줄 | 1 | 009 가 셈한 예상과 같음 |
| G-base-only | B | `base.yaml` 만 | 1 | 2 | 18줄 | 0 | 009 가 셈한 예상과 같음 |
| N-ref | C (묶음 = `base` + `codegen`) | 옛 주소 한 줄 | 3 | 0 | 13줄 | 0 | "기본 + codegen" 의 예상과 같음 |
| P-alias | B 와 같은 내용을 `path:` 로 | 옛 주소 한 줄 | 3 | 2 | 16줄 | 1 | 정답지와 같음 (같은 스크립트의 대조) |

- **pub cache 에 놓인 조각의 `plugins:` 가 3단 include 를 거쳐 로드된다.** 서버가 만든 plugin 패키지에 `riverpod.yaml` 의 선언(`^3.1.3`)이 그대로 적혔고 3.1.9 로 풀렸다.
- G-old → G-alias 가 "한 파일 구조에서 나눈 구조로 옮겨 간 프로젝트" 의 모습이다. 옛 주소 한 줄을 그대로 둔 채 같은 16줄을 받는다 (ROADMAP.md Phase 3 성공 기준 1 의 "분리 전과 똑같은 구성").
- N-ref 는 대조다. `ref:` 가 가리키는 커밋의 내용을 그대로 따른다는 것 — 이 실험이 작업 폴더가 아니라 **받은 커밋**을 읽고 있다는 것 — 을 보인다.
- 처음 실행은 14.8 ~ 15.2초로 `path:` 때(010 의 14.9 ~ 15.1초)와 같다.

생성 파일 제외의 모양도 같다. 생성 파일 샘플(`lib/generated/riverpod_violation.g.dart` — 한 줄에 규칙 위반과 plugin 위반)을 git 으로 받는 프로젝트와 `path:` 로 받는 프로젝트에 똑같이 두고 나란히 돌렸다.

| `**/*.g.dart` 제외를 적은 곳 | git: 규칙 | git: plugin | path: 규칙 | path: plugin | 진단 |
|---|---|---|---|---|---|
| 없음 (`base.yaml` + `riverpod.yaml`) | 나옴 | 나옴 | 나옴 | 나옴 | 23줄 |
| 패키지의 `codegen.yaml` (묶음으로 받음) | 안 나옴 | **나옴** | 안 나옴 | **나옴** | 17줄 |
| 묶음 + 받는 쪽의 옵션 파일에 직접 | 안 나옴 | 안 나옴 | 안 나옴 | 안 나옴 | 16줄 |

- 세 경우 모두 git 실행과 path 실행이 **한 줄도 다르지 않았다.**
- spike 012 가 추정으로 남긴 것이 실행으로 확인됐다 — 패키지가 pub cache 에 놓여도 `codegen.yaml` 의 제외는 규칙 진단만 막고 plugin 진단은 막지 못한다. 이것은 Dart 3.13.4 에서의 모양이다 (다음 SDK 에서는 → next-sdk-forward-compat.md 3번).

그래서 **연습용 프로젝트를 git 의존성으로 하나 더 두지 않는다.** `path:` 의존성으로 만든 연습용 프로젝트의 정답지가 git 으로 받는 사용 프로젝트가 보게 될 것과 같다.

**실제 사용 프로젝트에서도 git 과 `path:` 가 같았다 (019).** `flutter_starter_kit` 의 복사본을 두 방식으로 분석했다.

| 받는 방식 | 구조 | 줄 | `exit` | plugin 폴더 |
|---|---|---|---|---|
| git 의존성, 원본의 lock 그대로 (커밋 `90a2736` = 1.3.0) | 한 파일 구조 | 16 (표식 파일 16, 프로젝트 0) | 2 | 1 |
| `pubspec_overrides.yaml` 로 옆 폴더(`path:`)를 가리킴 | 한 파일 구조 | 16 — 위와 줄 단위로 같다 | 2 | 1 |
| 같음 | 나눈 구조, 옛 주소 | 16 — 줄 단위로 같다 | 2 | 1 |

- git 으로 받은 것은 한 파일 구조(1.3.0)다. 두 방식의 패키지는 `lib/` 의 내용이 같고 `pubspec.yaml` 의 두 줄(`version`, SDK 하한)만 다르다. **나눈 구조를 git 으로 받은 실제 프로젝트는 아직 없다** — 그 조합은 위의 연습용 프로젝트(G-alias)로 본 것이다.
- 16줄은 모두 복사본에 일부러 넣은 표식 파일의 줄이고 프로젝트 자신의 줄은 0 이다. 프로젝트의 줄이 나오는 짝(9,398줄)은 `path:` 끼리 견준 것이다 (→ real-consumer-measurement.md 5번).

### 3. lock 은 언제 따라가는가

같은 받는 쪽 프로젝트에서 저장소의 `main` 을 A → B 로 나아가게 하고 차례로 돌렸다.

| 순서 | 한 일 | 명령 | 종료 코드 | lock 의 `resolved-ref` |
|---|---|---|---|---|
| pub-1 | 처음 받는다 (`ref: main`, `main` = A) | `dart pub get` | 0 | A |
| — | 저장소의 `main` 이 B 로 나아간다 | — | — | — |
| pub-2 | 그대로 다시 받는다 | `dart pub get` | 0 | **A (그대로)** |
| pub-3 | 같은 상태에서 | `dart pub get --enforce-lockfile` | 0 | A |
| pub-4 | 올린다 | `dart pub upgrade woody_lints` | 0 | **B** |
| pub-5 | `pubspec.yaml` 의 `ref:` 를 브랜치 `no-riverpod` 로 고친 직후 | `dart pub get --enforce-lockfile` | **65** | B (그대로) |
| pub-6 | 같은 상태에서 | `dart pub get` | 0 | **C** |
| pub-7 | `ref:` 를 annotated tag `v9.9.9` (B 를 가리킨다) 로 고친 뒤 | `dart pub get` | 0 | **B** |

- **`ref: main` 을 따르는 프로젝트는 `pub get` 으로는 새 커밋을 받지 않는다.** lock 이 커밋을 못박고 있어서다. 새 버전은 `pub upgrade woody_lints` 를 해야 들어온다.
- **`ref:` 를 고친 프로젝트는 `pub get` 만으로 그 ref 의 커밋으로 옮긴다.** tag 로 고정한 프로젝트가 버전을 올리는 방법이고(pub-7 과 같은 모양), `ref: main` 에서 tag 로 옮기는 방법이기도 하다.
- annotated tag 를 적어도 lock 의 `resolved-ref` 에는 tag 자신의 해시가 아니라 **그 tag 가 가리키는 커밋의 해시**가 적힌다. 받은 폴더도 그 커밋의 것이다.
- `ref:` 만 고치고 lock 을 그대로 둔 채 `--enforce-lockfile` 을 돌리면 종료 코드 65 로 멈춘다. stderr 는 ``Unable to satisfy `pubspec.yaml` using `pubspec.lock`.`` 이다. lock 을 커밋하는 프로젝트의 CI 가 이 모양으로 알려 준다.
- `main` 이 나아갔을 뿐 `pubspec.yaml` 을 고치지 않은 상태의 `--enforce-lockfile` 은 통과한다 (pub-3). lock 이 여전히 맞는 풀이여서다.
- 실험의 명령에는 모두 `--no-example` 이 붙어 있었다. 받는 쪽 프로젝트에 `example/` 폴더는 없었다.

### 4. README 의 "버전 올리기" 안내 (Phase 5)

받는 방식에 따라 **두 갈래로** 적는다.

| 받는 방식 | 새 버전을 받는 방법 | 근거 |
|---|---|---|
| tag 로 고정 (`ref: vX.Y.Z`) | `pubspec.yaml` 의 `ref:` 를 새 tag 로 고치고 `pub get` | pub-6 · pub-7 과 같은 모양 |
| `ref: main` | `pub upgrade woody_lints` | pub-2, pub-4 |
| `ref: main` → tag 로 옮기기 | `ref:` 를 tag 로 고치고 `pub get` | pub-6 · pub-7 과 같은 모양 |

- **첫째 줄과 셋째 줄의 전환 자체를 돌린 것은 아니다.** 잰 것은 "`ref:` 를 다른 것으로 고친 뒤의 `pub get` 은 그 ref 의 커밋으로 옮긴다" 이고, 실제로 돌린 전환은 `main` → 브랜치 `no-riverpod` (pub-6) 와 그 브랜치 → tag `v9.9.9` (pub-7) 다. tag → 새 tag, `main` → tag 는 같은 동작으로 읽은 것이다.
- lock 을 커밋하고 CI 에서 `--enforce-lockfile` 을 쓰는 프로젝트는 `ref:` 를 고친 뒤 `pub get` 으로 lock 을 함께 갱신해 커밋한다. 아니면 종료 코드 65 다.
- 생성 파일 제외를 받는 쪽의 옵션 파일에 직접 적으라는 안내(→ suppression-and-exclude.md 7번)는 git 으로 받는 실제 사용 프로젝트에 그대로 해당한다.
- **사용 프로젝트의 `dev_dependencies` 에 `riverpod_lint` 를 따로 적지 않아도 진단은 같다 (019).** `flutter_starter_kit` 은 그 줄(`riverpod_lint: ^3.1.3`, lock 은 3.1.3)을 갖고 있는데, 뺀 실행과 둔 실행이 16줄 · `exit 2` 로 같았고 plugin 은 양쪽 모두 3.1.9 로 풀렸다. plugin 은 옵션 파일의 `plugins:` 로 받는다 — 프로젝트의 lock 에 적힌 3.1.3 을 따르지 않았다. "진단에 필요 없다" 까지가 실측으로 받쳐진다. 지우라고까지 안내할지는 Phase 5 가 정한다 — 그 줄이 다른 용도(IDE, 다른 도구)로 쓰이는지는 보지 않았고, 본 것은 프로젝트 하나 · `dart analyze` · 그 줄의 제약이 프리셋의 선언과 같은 `^3.1.3` 인 경우다.
- 잰 명령은 `dart pub get` / `dart pub upgrade woody_lints` 다. 2026-10-12 의 README 가 안내하는 `flutter pub get` / `flutter pub upgrade woody_lints` 로는 재지 않았다. README 가 어느 쪽으로 안내할지는 Phase 5 가 정한다 — 정할 때 알아 둘 것은 `flutter pub get` 이 Flutter 프로젝트의 옵션 파일에 제외 줄을 덧붙인다는 점이다 (004 → example-project-and-expected-file.md 의 Constraints).

**ROADMAP.md 의 문구 가운데 이 결과보다 앞서 적힌 것** (2026-10-12 현재 그대로 있다).

- Phase 5 Notes 의 "버전 올리기는 `pub upgrade` 가 아니라 `ref:` 수정과 `pub get` 이다" 는 **tag 로 고정한 쪽**의 말이다. `ref: main` 쪽은 `pub get` 으로는 아무것도 바뀌지 않고 `pub upgrade woody_lints` 가 맞다. Phase 5 성공 기준 2 의 "버전 올리기(`ref:` 수정과 `pub get`)" 도 같다.
- Phase 6 Notes 의 "`main` 병합은 `ref: main` 을 따르는 사용 프로젝트 5개에 새 버전이 배포되는 순간" 은 **곧바로 닿는다는 뜻이 아니다.** 각 프로젝트가 `pub upgrade woody_lints` 를 할 때 닿는다 (pub-4). lock 에 `woody_lints` 의 git 항목이 없는 프로젝트의 `pub get` 도 그때의 `main` 을 받는다 (pub-1 — lock 파일 자체가 없는 경우는 재지 않았고, 같을 것으로 읽는다). 병합이 원격에 남는 작업이고 소유자 확인을 받는다는 점은 달라지지 않는다.

### 5. 릴리스와 smoke test 가 볼 것 (Phase 6)

- smoke test 가 **처음** 보는 것은 "받아 오는 길" 하나로 줄었다 — `https://github.com/…` 주소, 실제 tag, 인증. 받은 뒤의 include 와 plugin 로드는 여기서 쟀다. smoke test 를 lock 이 없는 빈 프로젝트로 한다면 "lock 없이 처음 받는 경우" 와 "나눈 구조를 실제 주소에서 git 으로 받은 프로젝트" 도 거기서 처음 보게 된다 (둘 다 Constraints 의 재지 않은 목록에 있다).
- ROADMAP.md Phase 6 Notes 의 "git 의존성으로 받은 프리셋의 `plugins:` 로드는 지금까지 `path:` 의존성으로만 확인되어 있고, smoke test 가 이를 처음 확인하는 자리다" 는 이 spike 이전의 문구다. "tag 를 달기 전에 milestone 브랜치를 `ref:` 로 받는 빈 프로젝트에서 먼저 확인할지" 는 여전히 계획이 정한다 — 그 확인이 보는 것은 받아 오는 길이다.
- 사용 프로젝트는 `ref:` 가 가리키는 커밋의 내용을 그대로 따른다 (N-ref). tag 를 받는 프로젝트는 그 tag 의 커밋에 든 `lib/` 를 받는다.
- 학습용 프로젝트가 lock 을 커밋하는지는 확인하지 않았다. lock 에 `woody_lints` 의 git 항목이 없는 상태의 `pub get` 은 그때의 `main` 을 받았다 (pub-1). lock 파일 자체가 없는 프로젝트의 처음 받기는 재지 않았다.

### 6. 올리지 않고 git 의존성을 재는 방법

`dart pub` 은 `git clone` 을 하위 프로세스로 부르므로 로컬 폴더 경로도 `url:` 로 쓸 수 있다. replica 를 git 저장소로 만들고, 받는 쪽은 replica **밖**에 두고, pub cache 를 작업 폴더 안으로 돌린다.

```dart
// sources/015-git-dependency-preset-load/probe.dart 에서 (발췌)

/// replica 에서 `git [args]` 를 돌린다. 사용자의 git 설정(서명, hook)에 기대지 않도록
/// 전역 설정을 끄고, 커밋의 이름과 시각을 고정한다.
final result = await Process.run('git', args, workingDirectory: replica.root, environment: {
  'GIT_CONFIG_GLOBAL': '/dev/null',
  'GIT_CONFIG_NOSYSTEM': '1',
  'GIT_AUTHOR_NAME': 'spike',
  'GIT_AUTHOR_EMAIL': 'spike@example.invalid',
  'GIT_COMMITTER_NAME': 'spike',
  'GIT_COMMITTER_EMAIL': 'spike@example.invalid',
  'GIT_AUTHOR_DATE': '2026-10-12T00:00:00Z',
  'GIT_COMMITTER_DATE': '2026-10-12T00:00:00Z',
});

/// 받는 쪽에서 `dart pub [args]` 를 실험용 pub cache 로 돌린다.
Future<ProcessResult> pub(List<String> args) => Process.run(
      Platform.resolvedExecutable,
      ['pub', ...args],
      workingDirectory: dir,
      environment: {'PUB_CACHE': pubCache},
    );

/// git 의존성 선언 — [ref] 를 따른다 (`woody_lints:` 아래, 들여쓰기 4칸).
String gitDependency(String ref) =>
    '    git:\n      url: ${replica.root}\n      ref: $ref\n';
```

- 받는 쪽의 `pubspec.yaml` 은 `example/pubspec.yaml` 의 `    path: ..\n` 한 줄을 위의 선언으로 바꿔 만들었고, `example/pubspec.lock` 을 복사해 두어 `woody_lints` 항목만 pub 이 다시 쓰게 했다.
- lock 의 항목은 `Consumer.lockEntry` (`  woody_lints:` 아래의 `키: 값` 을 읽는다), 패키지의 자리는 `Consumer.packageRoot` (`package_config.json` 의 `rootUri`) 로 읽었다. 전문은 사본에 있다.
- 릴리스 tag 와 같은 모양을 보려면 annotated tag 로 만든다 (`git tag -a v9.9.9 -m … <커밋>`). 첫 실행은 가벼운(lightweight) tag 였고 둘째 실행이 annotated tag 였다 — 판정은 같았다.

## What to Avoid

- **`ref: main` 프로젝트에 "`pub get` 을 다시 하면 된다" 고 안내하는 것.** lock 의 커밋에 머문다.
- **버전 올리기를 한 문장으로 뭉뚱그리는 것** ("`pub upgrade` 가 아니라 `ref:` 수정과 `pub get`"). tag 로 고정한 쪽만의 말이다.
- **`ref:` 만 고치고 lock 을 갱신하지 않은 채 커밋하는 것.** `--enforce-lockfile` 을 쓰는 CI 가 종료 코드 65 로 멈춘다.
- **"`main` 에 병합하면 다섯 프로젝트가 곧바로 바뀐다" 로 적는 것.** 각 프로젝트가 `pub upgrade woody_lints` 를 할 때 바뀐다 (lock 없이 새로 받을 때도 그럴 것이다 — 그 경우는 재지 않았다).
- **git 의존성으로 받는 연습용 프로젝트를 저장소에 하나 더 두는 것.** 두 방식의 결과가 줄 단위로 같았다.
- **"받은 뒤의 모양을 쟀으니 smoke test 는 건너뛰어도 된다" 로 읽는 것.** 받아 오는 길(https 주소, 실제 tag, 인증)은 재지 않았다.
- **실험용 패키지를 `~/.pub-cache` 의 git 폴더에 받는 것.** `PUB_CACHE` 를 작업 폴더 안으로 준다.
- **실험용 커밋을 사용자의 git 설정으로 만드는 것.** 서명이나 hook 이 끼어든다. 전역 설정을 끄고 이름과 시각을 환경변수로 준다.
- **받는 쪽 프로젝트를 replica 안에 두는 것.** 받는 방식이 질문일 때는 replica 밖(`<작업 폴더>/consumer-*`)에 둔다 — 스크립트가 `git add -A` 로 replica 전체를 커밋하므로 안에 두면 받는 쪽의 파일이 커밋에 섞인다.

## Constraints

- dart.dev/tools/pub/dependencies § Git packages: "The `dart pub` command calls `git clone` as a subprocess, so all you need to provide is a `<url>` that works when `git clone <url>` is executed." `ref` 는 "anything that Git allows to identify a commit" 이다. dart.dev/tools/pub/cmd/pub-get: "If a lockfile already exists, `dart pub get` uses the versions of dependencies locked in it if possible." git 의존성의 커밋이 lock 에 어떻게 적히고 무엇이 그것을 옮기는지는 두 문서에 적혀 있지 않아 실행으로 쟀다 (2026-10-12 읽음).
- pub cache 의 자리는 `PUB_CACHE` 환경변수로 바꾼다. git 과 pub.dev 에서 받은 패키지가 그 안에 놓인다.
- 2번의 표에서 git 으로 다시 잰 것은 옛 주소 · 묶음 주소 · `base.yaml` + `riverpod.yaml` · `base.yaml` 만 · (묶음에서 Riverpod 조각을 뺀) 기본 + codegen, 그리고 생성 파일 제외의 세 자리다. **다시 재지 않은 것:** 끄는 방법 여섯 칸(012 의 주석 · `diagnostics:`), `base.yaml` + `codegen.yaml` 을 받는 쪽이 목록으로 직접 부른 조합, 010 의 가장자리(6단, 상대 경로), 사슬을 끊었을 때의 모양. 저장소 루트의 분석(011)은 받는 방식과 무관한 질문이라 대상이 아니다.
- A 와 B 의 `pubspec.yaml` 은 같다. SDK 하한이 다른 커밋으로 옮길 때의 모양은 재지 않았다 (Dart 3.13 미만에서 받지 못하는 것은 Phase 1 이 쟀다).
- 019 가 실제 사용 프로젝트에서 본 것은 git(한 파일 구조, 1.3.0) 대 `path:` 의 진단과 `dev_dependencies` 의 `riverpod_lint` 줄 둘이다. 3번의 lock 동작(`pub get` 이 lock 의 커밋에 머무는 것, `pub upgrade`, 종료 코드 65)은 실제 프로젝트에서 다시 돌리지 않았다 — 원본은 읽기만 했다.
- 확인하지 않은 것: 받아 오는 길 자체 (`https://github.com/…` 주소, 실제 tag, 인증 — 015 는 로컬 경로를 `git clone` 한 것으로 쟀고, 019 의 git 실행은 평소의 pub cache 를 써서 그때 받아 왔는지가 기록에 없다), 나눈 구조를 git 으로 받은 실제 프로젝트, lock 이 없는 새 프로젝트가 처음 받는 경우, `flutter pub …` 로 돌린 같은 순서, 다음 SDK 에서 git 으로 받는 것 (016 은 베타에서 `path:` 로 쟀다), GitHub Linux runner 에서의 같은 실행.

## Origin

Synthesized from spikes: 015 (대조 기준은 009 · 010 의 `path:` 결과와 012 의 생성 파일 제외 표다. 실제 사용 프로젝트에서의 git 대 `path:` 와 `dev_dependencies` 의 `riverpod_lint` 줄은 019 의 결과를 덧붙인 것이다)
Source files available in: sources/015-git-dependency-preset-load/, sources/019-real-consumer-split-invariance/, sources/009-preset-plugin-via-include/ (`replica.dart`)
원본 로그와 JSON: `.planning/spikes/015-git-dependency-preset-load/results/` (`probe-run1.*` 이 첫 실행, `probe.*` 이 둘째 실행이다), `.planning/spikes/019-real-consumer-split-invariance/results/`
