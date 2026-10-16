# Spike Conventions

spike 세션에서 굳어진 도구 선택과 방식이다. 새 spike 는 질문이 다른 방식을 요구하지 않는 한 이를 따른다. 두 개 이상의 spike 에서 반복된 것만 적었다.

spike 가 확인한 사실 자체는 `.claude/skills/spike-findings-woody-lints/` 에 묶여 있다 (wrap-up 다섯 번 — 2026-10-11 에 spike 001~006 과 007~008, 2026-10-12 에 Phase 3 의 사전 확인인 009~014, 받는 방식 · 다음 SDK 를 잰 015~016, GitHub runner 와 실제 사용 프로젝트를 잰 017~019).

## Stack

- **실측 스크립트는 Dart 로 쓴다.** `dart:io`, `dart:convert` 만 쓰고 패키지 의존성을 두지 않는다 (001, 002, 003, 006). 실제 검증 명령(`tool/verify.dart`, 02-CONTEXT.md D-11)과 같은 조건이라 스크립트의 조각을 그대로 옮겨 갈 수 있다.
- Dart 스크립트가 하위 `dart` 를 부를 때는 `Platform.resolvedExecutable` 을 쓴다 (001, 002, 003, 006). `fvm dart run …` 으로 띄운 그 SDK 가 그대로 쓰인다.
- 명령을 차례로 돌리고 파일을 견주는 일은 `bash` + `python3` 으로 쓴다 (004, 005). Dart 로 하기 번거로운 일(프로세스 그룹에 신호 보내기, 견줄 md5 계산)도 `python3` 에 맡긴다 (008).
- **저장소의 모양을 복사해 실험하는 일은 `009-preset-plugin-via-include/replica.dart` 를 import 해 쓴다** (009~017, 019). 복사본 만들기(`Replica`), 배포 파일을 조각으로 자르기(`Shipped`), 정답지 읽기와 조합별 예상 셈하기(`Expected`), 분석 한 번(`Replica.analyze`), 확인 모으기(`Checks`)가 들어 있다. 스크립트는 `import '../009-preset-plugin-via-include/replica.dart';` 한 줄로 받는다. `Shipped` 는 저장소의 `lib/analysis_options.yaml` 이 한 파일 구조일 때 그것을 잘라 조각을 만든다 — Phase 3 이 저장소를 나눈 뒤의 spike 는 이 조각을 나눈 파일을 읽게 고쳐 쓰거나 나누기 전의 커밋을 꺼낸 자리에서 돌린다 (스크립트를 읽은 것이고 돌려 보지는 않았다).
- SDK 는 저장소 고정 버전이다 (Flutter 3.47.5 / Dart 3.13.4). 저장소 안에서는 `fvm dart …`, 저장소 밖 작업 폴더에서는 `<저장소>/.fvm/flutter_sdk/bin/dart` 를 직접 부른다 (`fvm` 이 `.fvmrc` 를 찾지 못하므로).
- **다른 SDK 로 견줄 때는 같은 스크립트를 SDK 마다 한 번씩 돌린다** (016). 저장소 밖을 작업 디렉터리로 두고 `<SDK>/bin/cache/dart-sdk/bin/dart <스크립트의 절대 경로> <작업 폴더>` 로 띄운다 — 저장소 루트에서 `dart run` 을 하면 그 SDK 가 루트의 패키지를 다시 풀어 `.dart_tool/` 과 lock 을 바꿀 수 있다. 실행 뒤 루트 `.dart_tool/package_config.json` 의 `generatorVersion` 과 `git status` 로 저장소가 그대로인지 본다. 결과 파일 이름에 Dart 버전을 넣는다 (`results/probe-<버전>.json`).
- **사용 프로젝트의 복사본을 재는 spike 는 `021-new-rules-language-gate/consumer.dart` 를 import 해 쓴다** (021, 022, 023). 복사(`Consumer.copy`), 작업 중인 저장소에 물리기(`pointToRepo` — `pubspec_overrides.yaml` 의 `path:` 가 저장소 자체를 가리킨다. replica 를 만들지 않는다), 받은 자리 확인과 회차 버리기(`ensureRepoSource`), SDK 하한 바꾸기(`useSdk` — `pub get` 까지 한다), 소스 되돌리기(`refreshSources`), 분석 한 번(`analyze` → `Shot`), 저장소 지문(`Repo.fingerprint`)이 들어 있다. 019 의 `Consumer` 와 이름만 같은 다른 클래스다.
- **규칙의 상태나 언어 버전을 볼 때는 저장소 밖에 `sdk:` 하한을 적은 순수 Dart 패키지를 만든다** (020, 021, 022 의 1부). deprecated / removed 는 pubspec 의 하한을 따르므로(005) 하한을 적은 pubspec 만 있으면 저장소 안에 둘 필요가 없다. 하한만 다른 두 벌(`^3.11.1` · `^3.13.0`)을 같은 내용으로 만들어 견준다.
- **GitHub runner 에서만 잴 수 있는 것은 작업 브랜치를 올리고 임시 workflow 로 돌린다** (006, 017, 018). 차례는 준비 커밋(`docs(spike-NNN): PENDING — …` — 스크립트와 `.github/workflows/spike-NNN-….yml`) → 소유자 확인 → `git push origin <작업 브랜치>` → 결과 기록 → `ci: spike NNN 임시 workflow 제거` 다. 스크립트는 로그에 `SPIKENNN_RESULT {…}` 한 줄을 찍고, `017-runner-six-fixtures/collect.py <run id> <출력 파일>` 이 job 별 시간과 그 줄을 모은다. 임시 workflow 의 사본은 spike 폴더에 남긴다 (`.github/` 밖이라 돌지 않는다).

## Structure

```text
.planning/spikes/NNN-name/
  README.md        질문, 조사, 실행법, 조사 경과, 결과
  fixture/         연습용 프로젝트 (복사해 써야 하면 template/)
  <script>         저장소 루트에서 실행한다
  results/         원본 로그와 JSON
```

- 연습용 프로젝트는 Flutter 패키지이고, `woody_lints` 를 `path: ../../../..` 로 받으며, 옵션 파일은 `include: package:woody_lints/analysis_options.yaml` 한 줄이다. 사용 프로젝트와 같은 모양으로 둔다.
- 연습용 프로젝트의 `.dart_tool/` 과 `pubspec.lock` 은 루트 `.gitignore` 에 걸려 커밋되지 않는다. 실행 전에 `fvm dart pub get` 을 한다.
- `.planning/` 은 점(`.`)으로 시작하므로 저장소 루트의 분석에 연습용 프로젝트의 위반 코드가 섞이지 않는다.
- 저장소의 파일을 바꿔 봐야 하는 실험은 작업 폴더에 복사본을 만들어 한다 (004 의 `template/`, 007 의 replica, 008 의 `fx`, 009~014 의 `Replica`). 연습용 프로젝트가 새로 필요하지 않으면 spike 001 의 것을 복사하고 의존성 경로만 바꾼다 (006, 007, 008).
- 저장소에 `example/` 이 생긴 뒤의 spike 는 연습용 프로젝트를 따로 두지 않는다. 저장소 `example/` 의 샘플과 `pubspec.lock` 을 복사본 안에 복사하고 의존성 경로만 깊이에 맞춘다 (`Replica.addFixture`, 009~017). spike 에만 필요한 샘플은 스크립트 안에 문자열로 두고 실행할 때 쓴다 (012, 015, 016). 사용 프로젝트가 패키지를 **받는 방식**이 질문이면 연습용 프로젝트를 replica 밖(`<작업 폴더>/consumer-*`)에 두고 replica 를 로컬 git 저장소로 만든다 (015).
- 실행을 두 번 이상 남길 때는 앞의 것을 `results/<이름>-run1.*` 로 옮겨 둔다. 원본 로그는 고치지 않는다 (014, 015, 016).
- **실제 사용 프로젝트를 재는 spike 는 원본의 경로를 인자로 받고, 분석에 필요한 것(`pubspec.yaml` · `pubspec.lock` · 옵션 파일 · `lib` · `test` · `bin` · `assets`)만 `<작업 폴더>/consumer` 로 복사한다** (019). 스크립트에 원본의 경로를 적지 않는다. 원본은 읽기만 한다 (PROJECT.md 의 Safety).

## Patterns

- **`dart analyze` 는 패키지 루트를 작업 디렉터리로 두고 인자 없이 실행한다.** 하위 폴더를 인자로 주면 plugin 진단을 잃는다 (001). 폴더를 인자로 주는 것은 plugin 진단이 필요 없는 규칙 검사뿐이다 — 저장소 루트에서 `dart analyze build/woody_rule_check` (007).
- **사용 통계 전송을 끄고 실행한다** — `dart --suppress-analytics analyze …` 또는 `DASH__SUPPRESS_ANALYTICS=true`. 끄지 않으면 가끔 종료 코드 255 로 죽는다 (001). GitHub runner 에서는 `dart` 가 스스로 끄지만(006) 로컬과 같은 방식으로 돌도록 항상 붙인다.
- **`~/.dartServer` 를 건드리지 않는다.** 스크립트의 첫 인자로 상태 폴더를 받아 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 넘긴다. 빈 폴더를 주면 cold 실행이 된다. 기본 자리를 쓰는 것은 runner 에서 "평범한 CI job 이 겪는 그대로"를 볼 때뿐이고, 그 모드는 GitHub Actions 밖에서 실행을 거부한다 (006). 실행을 겹쳐 띄울 때는 그것이 실험 대상이 아닌 한 실행마다 폴더를 따로 준다 — 빈 폴더를 함께 쓰면 드물게 깨진다 (008).
- 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 정규화하고 정렬해 견준다 (D-04). 강도는 JSON 의 `severity` 를 소문자로 쓴다.
- 연습용 프로젝트의 파일을 바꿔 쓰는 스크립트는 끝날 때 반드시 되돌린다 (Dart 는 `finally`, bash 는 `trap`). 저장소 안에 임시 폴더를 만들면 같은 자리에서 지운다.
- 종료 코드, stdout(JSON), stderr 를 따로 기록한다. 하나만 보고 판정하지 않는다 (002).
- plugin 준비 실패의 머리말(`An error occurred while executing an analyzer plugin:`)은 stderr 에서 `contains` 로 찾는다. 첫 줄이 아닐 수 있다 (008).
- stdout 에서 `{` 로 시작하는 마지막 줄을 JSON 으로 읽는다. 읽지 못하면 "진단 0건"이 아니라 "JSON 없음"으로 따로 기록한다 (002, 003, 005, 006).
- 스크립트는 시작할 때 준비 상태(인자, SDK 경로, 연습용 프로젝트의 `.dart_tool/package_config.json`)를 확인하고, 빠진 것이 있으면 할 일을 알려 주고 끝낸다. 스크립트 자신의 종료 코드는 sysexits 관례를 따른다: 64 사용법, 65 형식 오류, 66 입력 없음, 69 하위 명령 실패, 70 프로세스를 띄우지 못함, 73 폴더를 만들지 못함, 74 파일 작업 실패 (002~008).
- "plugin 을 준비했는가"는 실행마다 빈 상태 폴더를 주고 `.plugin_manager` 아래 폴더 수로 본다 (005, 007).
- 실제로 풀린 plugin 버전은 그 실행에 준 상태 폴더의 `.plugin_manager/*/pubspec.lock` 에서 읽는다 (003, 006, 008).
- 오래 걸리는 실험은 부(part)나 경우 id 로 나눠 인자로 골라 돌릴 수 있게 하고, 결과 JSON 은 덮어쓰지 않고 합쳐 쓴다 (002, 008).
- 결과 파일에서는 로컬 절대 경로를 `<repo>`, `<scratch>`, `~/` 로 가린다. 작업 브랜치가 공개 저장소에 올라가기 때문이다 (D-08).
- 실측한 사실에는 버전과 날짜를 함께 적는다.
- 도구의 소스를 읽어 세운 추정은 실행으로 확인하고, 읽은 소스의 버전을 적는다 (001, 005, 007, 008). 읽는 대상은 SDK tag 3.13.4 의 소스와 pub cache 의 `analyzer` 14.5.0 이다. 읽은 것과 실행 결과가 어긋나면 실행 결과를 따른다 — `rules.json` 과 실제 규칙 상태(005), "`example/**` 가 폴더 자체에는 맞지 않을 수 있다"는 의문(007)이 그랬다.
- 연습용 프로젝트의 패키지는 `dart pub get` 으로 받는다. `flutter pub get` 은 옵션 파일을 고친다 (004).
- **배포 파일을 나눈 모양이 필요하면 손으로 쓰지 않고 저장소의 파일을 잘라 만든다** (`Shipped` — 조각을 이으면 원본과 같은지 확인한다). 구조만 바꾼 것과 내용까지 바뀐 것이 섞이지 않는다 (009~014).
- **대조를 같은 스크립트에 둔다.** "사라졌다" 나 "0건" 을 볼 때는 사라지지 않는 것을 함께 본다 — 같은 내용을 한 파일에 둔 기준 실행(009), 사슬을 일부러 끊은 실행(010), 지금의 구조에서 경고가 나는 실행(011 R1), 끈 자리 옆의 끄지 않은 같은 위반(012), 규칙이 실제로 적용됐는지 가르는 표식 파일(011 G4), 같은 프로젝트를 `path:` 로 받는 짝(015), 저장소 고정 SDK 로 돌린 같은 스크립트(016).
- 확인할 것을 스크립트에 적어 두고(`Checks`) 끝에 `# 판정` 표로 찍는다. 반드시 성립해야 하는 확인이 깨지면 스크립트의 종료 코드를 1 로 낸다. 소스를 읽어 세운 추정과 실제가 달라도 되는 칸은 판정에 넣지 않고 `≠` 로 따로 표시한다 (012). SDK 를 바꿔 견줄 때도 같다 — 칸마다 고정 SDK 에서의 값을 적어 두고 `=` / `≠` 로 찍으며, 판정에는 스크립트가 믿을 만한지를 보는 대조만 넣는다 (016).
- **진단의 메시지에도 로컬 경로가 들어 있다** (`include_file_not_found` 등). 줄뿐 아니라 메시지도 가려서 결과에 쓴다. 커밋 전에 그 spike 폴더를 `grep -rn -E '/Users/|/private/tmp'` 로 훑고, 걸리면 커밋하지 않는다 (010 에서 한 번 샜다).
- **소스를 읽을 때 어느 쪽의 analyzer 인지 가른다.** 분석 서버(규칙, 옵션 파일의 진단)는 SDK 에 든 analyzer 를 쓰고, plugin 은 pub.dev 에서 풀린 analyzer 를 쓴다 — 버전은 전용 상태 폴더의 `.plugin_manager/*/pubspec.lock` 에 있다. 2026-10-12 에는 둘이 달라(14.1.0-dev 와 14.5.0) 제외 패턴의 기준 폴더가 서로 달랐다 (010, 012).
- 폴더를 인자로 준 분석은 그 폴더가 분석의 루트가 된다. 복사본이 include 로 `plugins:` 에 닿기만 해도 plugin 을 준비한다 (013 의 K4 · K5). 루트에서 인자 없이 돌릴 때는 하위 옵션 파일의 `plugins:` 를 쓰지 않는다 (011 의 R2).
- **생성 파일 제외를 볼 때는 한 줄에 규칙 위반과 plugin 위반을 함께 둔 샘플을 쓴다** — `lib/generated/riverpod_violation.g.dart` 의 `ref.watch(generatedFamily(["g1"]))` 한 줄이 `prefer_single_quotes` 와 `provider_parameters` 를 함께 낸다. 제외를 적은 자리를 바꿔 가며 두 진단이 각각 나오는지를 본다 (012, 015, 016).
- 상류(dart-lang/sdk)의 이슈를 근거로 적을 때는 `gh issue view <번호> --repo dart-lang/sdk` 로 상태 · 라벨 · 댓글을 직접 읽고 읽은 날짜를 적는다. 요약 도구가 옮긴 인용은 그대로 쓰지 않는다 (016).
- 빈 상태 폴더는 plugin 뿐 아니라 분석 캐시도 비운다. plugin 을 쓰지 않는 프로젝트도 빈 상태 폴더에서는 약 3초, 채워진 상태 폴더에서는 약 0.7초다 (014). 시간을 견줄 때는 상태 폴더가 비었는지를 함께 적는다.
- **runner 의 job 하나는 새 가상 머신 하나다.** "처음 받는 경우" 가 질문이면 방식마다 job 을 따로 두고 표본은 matrix 로 늘린다 (006 의 표본 다섯, 017 의 방식 둘 × 표본 셋). 한 job 안에서 이어 돌리면 뒤의 것은 pub cache 가 채워진 상태다.
- runner 이미지를 견줄 때는 `/etc/os-release`, glibc(`ldd --version`), `ImageVersion` 을 함께 남겨 이미지가 실제로 달랐음을 대조로 둔다 (018). `ubuntu-latest` 가 실제로 무엇이었는지는 로그의 `Image:` · `Version:` 줄에 있다.
- **비공개 저장소의 프로젝트를 잰 결과에는 그 프로젝트의 경로 · 진단 메시지 · 코드 조각을 남기지 않는다** — 건수, 규칙 이름, 줄 목록의 해시만 남긴다 (019. `flutter_starter_kit` 은 비공개다). 줄 단위 기록은 `<작업 폴더>/private/` 에 쓰고, 화면 기록(`results/*.log`)은 스크립트가 적어도 되는 줄만 골라 쓴다 (stdout 을 그대로 저장하지 않는다). 커밋 전 점검에 `grep -rn -o -E '(lib|test|bin|assets)/[A-Za-z0-9_./-]+\.(dart|json|arb|yaml)' <spike 폴더>/results | grep -v woody_probe_marker` 를 더한다 (처음 적은 패턴 `(lib|test)/[a-z_/]+\.dart` 는 `bin/`, 숫자 · 대문자가 든 이름, `*.g.dart` 를 잡지 못했다 — 2026-10-12 의 wrap-up 에서 넓혔고 019 의 결과는 넓힌 패턴으로도 0줄이었다).
- **0줄은 그것만으로 "깨끗하다" 가 아니다.** 같은 실행에 일부러 넣은 위반(표식 파일 — 이 저장소 `example/lib` 의 샘플을 복사본의 `lib/woody_probe_marker/` 에 넣는다)을 두어 규칙이 켜졌는지를 가른다. 019 에서 `public_member_api_docs` 가 0줄이었고, 처음 세운 추정(`publish_to: 'none'` 탓)은 문서 주석 없는 표식 둘이 2줄을 내면서 틀린 것으로 드러났다 — 그 프로젝트의 `lib/` 가 실제로 전부 문서화되어 있었다. "같다" 를 볼 때도 0줄 = 0줄 이 되지 않게, 줄이 많이 나오는 규칙(`always_specify_types`)을 양쪽에 더 켠 짝을 둔다.
- 사용 프로젝트의 `woody_lints` 를 작업 중인 파일로 돌릴 때는 복사본에 `pubspec_overrides.yaml` (`dependency_overrides:` 아래 `woody_lints:` 의 `path:`)을 두고 `dart pub get` 을 한다. `pubspec.yaml` 은 고치지 않는다. 받은 자리는 `.dart_tool/package_config.json` 의 `rootUri` 로 확인한다 (019). 프리셋을 나눈 뒤에는 `path:` 가 작업 중인 저장소 자체를 가리키고, 받은 자리가 저장소가 아니면 그 회차를 버린다 (021 ~ 023).
- **저장소의 지문을 실행 전후로 견주는 스크립트가 도는 동안에는 저장소 안에 파일을 만들지 않는다** (022). 022 의 실행 중에 다음 spike 의 스크립트를 저장소 안에 만들어 `git status` 가 바뀌었고, "저장소가 그대로다" 확인이 깨졌다. 원인을 가르려고 단계마다 지문을 견주는 짧은 대조(`022-dart-fix-dry-run-count/repo_guard.dart`)를 따로 돌려야 했다. 기다리는 동안 쓰는 다음 스크립트는 scratchpad 에 쓰고 실행이 끝난 뒤 옮긴다. 지문은 `git status --porcelain`, `.dart_tool/` 의 맨 위 이름, 루트 `package_config.json` · `pubspec.lock` 의 해시다 (021 ~ 023).
- **복사본의 SDK 하한을 바꿀 때는 `pubspec.yaml` 을 고친 뒤 `pub get` 까지 한다** (021, 022). `pubspec.yaml` 만 되돌리면 `package_config.json` 의 `languageVersion` 이 앞의 값으로 남아 다음 분석이 다른 언어 버전으로 돈다 (021 의 끝에서 그랬다).
- **켜는 규칙마다 그 규칙을 어기는 표식을 둔다** (021, 023 — 019 의 방식을 규칙 단위로 넓혔다). 막는 조건이 있는 규칙은 표식까지 0줄이 나온다 (021 의 언어 버전). 무시 주석의 효과를 볼 때는 같은 위반을 가린 표식 하나를 더 둔다 (023).

## Tools & Libraries

실제로 풀린 버전 (2026-10-11, 아래 세 줄은 2026-10-12). `riverpod_lint` 는 2026-10-12 에도 3.1.9 로 풀렸다.

| 패키지 | 버전 | 쓰인 곳 |
|---|---|---|
| `riverpod_lint` (plugin, `^3.1.3` 이 풀린 값) | 3.1.9 | 001, 002, 003, 006, 008 |
| `flutter_riverpod` / `riverpod` | 3.4.3 | 001, 002, 003, 004 |
| `flutter_lints` / `lints` | 6.0.0 / 6.1.0 | 전부 |
| `riverpod_annotation` | 4.0.7 | 003 |
| `riverpod_generator` / `build_runner` | 4.0.9 / 2.16.2 | 003 만 (실제 `example/` 에는 붙이지 않는다) |
| `actions/checkout` / `subosito/flutter-action` | `v7` / `v2` | 006 |
| `python3` (macOS 기본) | 3.9.6 | 004, 005, 008 — 3.10 문법(`X \| None`)을 쓰지 않는다 |
| `analysis_server_plugin` / `analyzer` (plugin 쪽에서 풀린 값, 2026-10-12) | 0.3.24 / 14.5.0 | 009~017, 019 — 012 가 이 버전의 소스를 읽었다. 베타 SDK 에서도(016), GitHub runner 의 두 이미지에서도(017) 같은 값으로 풀렸다 |
| `git` (macOS) | 2.56.0 | 015 — 전역 설정을 끄고(`GIT_CONFIG_GLOBAL=/dev/null`) 커밋의 이름 · 시각을 환경변수로 고정한다 |
| Flutter 베타 / Dart (견줌용, fvm 캐시에만 설치) | 3.49.0-0.2.pre / 3.14.0-211.1.beta | 016 — `.fvmrc` 는 3.47.5 그대로다 |
| GitHub runner 이미지 | `ubuntu-24.04` 20261004.327.1 / `ubuntu-26.04` 20260927.149.1 | 017, 018 — 둘 다 코어 4개 · 약 16GB. `ubuntu-latest` 는 2026-10-12 에 24.04 였다 |
| `gh` | 2.102.0 | 017, 018 — job 로그는 `gh api --allow-escape-sequences …/jobs/<id>/logs` 로 읽는다 (그 인자가 없으면 내주지 않는다) |
| SDK 소스 (tag 3.13.4, raw.githubusercontent.com) | `pkg/linter/messages.yaml`, `pkg/linter/lib/src/rules/*.dart`, `pkg/analysis_server/lib/src/services/correction/fix_internal.dart`, `CHANGELOG.md` | 020 ~ 022 — 규칙 상태, 언어 기능의 막는 조건(`Feature.primary_constructors`), 일괄 수정 여부(`nonBulk` / `bulkFixable`) |

쓰지 않는 것:

- `flutter analyze` — Flutter 3.47.5 에서 plugin 진단을 내지 않는다 (PROJECT.md).
- `dart analyze <하위 폴더>` — plugin 진단을 잃는다 (001). 규칙 검사의 복사본 폴더만 예외다 (007).
- plugin 버전을 기본 자리(`~/.dartServer`)에서 읽는 것 — 다른 프로젝트의 폴더가 섞여 있고 자기 폴더를 고를 방법이 없다 (008).
- 연습용 프로젝트에서의 `flutter pub get` — 옵션 파일을 고친다 (004).
- `--format=json` / `--format=machine` 의 출력만으로 옵션 파일이 멀쩡하다고 보는 것 — 깨진 YAML 은 둘 다 아무것도 찍지 않고 종료 코드만 3 이다 (013).
- JSON 의 `type` 으로 `// ignore_for_file: type=…` 의 효과를 미루어 보는 것 — plugin 진단은 JSON 에 `STATIC_WARNING` 으로 나오지만 `type=lint` 가 끈다 (012).
- `~/.pub-cache` 의 git 폴더에 실험용 패키지를 받는 것 — git 의존성을 잴 때는 `PUB_CACHE` 를 작업 폴더 안으로 준다 (015).
- 저장소 루트에서 다른 SDK 의 `dart run` — 그 SDK 가 루트의 패키지를 다시 푼다 (016).
- `fvm install --setup` 만 한 SDK 로 Flutter 프로젝트의 `dart pub get` — `sky_engine` 을 찾지 못해 실패한다. `flutter precache --universal` 로 공통 구성물을 먼저 받는다 (016).
- 고정 SDK 에서 잰 "루트 분석이 plugin 을 준비하지 않는다" · "프리셋의 제외가 규칙 진단에 통한다" 를 SDK 와 무관한 사실로 적는 것 — 베타(Dart 3.14.0-211.1.beta)에서는 둘 다 달랐다 (016).
- 한 job 안에서 방식을 이어 돌려 "처음 실행" 을 견주는 것 — 뒤의 방식은 pub cache 가 채워진 상태다 (017).
- 0줄을 근거로 "이 규칙은 이 프로젝트에 적용되지 않는다" 나 "이 프로젝트는 깨끗하다" 를 적는 것 — 일부러 넣은 위반 없이 세운 추정이 틀렸다 (019).
- 사용 프로젝트 원본에서 `dart analyze` 나 `pub get` 을 돌리는 것, 비공개 프로젝트의 진단 줄을 `results/` 에 그대로 쓰는 것 (019).
- SDK 의 `pkg/linter/tool/machine/rules.json` 을 규칙 상태 · 상류 세트 · fix 여부의 근거로 삼는 것 — 상류가 "unsupported and deprecated" 라고 적었고 tag 3.13.4 의 그 파일은 상태 하나가 틀렸으며 `sets` 가 모두 비어 있다. 상태는 tag 의 `pkg/linter/messages.yaml` 과 실제 분석, 상류 세트는 pub cache 의 YAML 에서 읽는다 (005 가 어긋난 규칙 하나를 먼저 찾았고, 020 · 022 가 이름 전부로 넓혔다).
- 비호환 쌍을 한 옵션 파일에 모두 켜고 `incompatible_lint` 를 세는 것 — 규칙 한 줄에 하나만 붙어 일부가 가려진다. 쌍마다 둘만 켠다 (020).
- 규칙을 모두 켠 한 번의 `dart fix --dry-run` 이나 `--dry-run --code=` 의 수를 "고칠 수 있는 진단 수" 로 쓰는 것 — 앞의 것은 규칙끼리 섞이고 뒤의 것은 수정 수다. 소스를 되돌리고 `--apply --code=` 한 뒤 다시 분석한다 (022).
- 메시지를 남기지 않는 결과에서 진단이 가리킨 무시 주석을 다시 읽을 때 주석 뒤의 설명 글까지 옮기는 것 — 코드 이름만 뽑는다 (023).
