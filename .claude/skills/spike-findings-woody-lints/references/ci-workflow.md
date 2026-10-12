# GitHub Actions CI

검증 명령을 GitHub 의 Linux runner 에서 돌리는 workflow 다. 캐시가 하나도 없는 새 가상 머신에서도 plugin 진단이 로컬과 똑같이 나오는지, 얼마나 걸리는지를 쟀다.

따로 적지 않은 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, `ubuntu-latest` (4 cores), 2026-10-11 실측이다. 새 가상 머신 10대에서 분석 60번. 연습용 프로젝트가 여섯일 때의 셈에 쓴 로컬 값은 014 (macOS, 2026-10-12), 다음 SDK 에 관한 줄은 016 (로컬의 베타, 2026-10-12) 의 것이다.

## Requirements

MANIFEST.md 의 `verify-harness-tool-behavior` 에서 이 영역에 걸리는 것.

- CI 는 `actions/checkout@v7` + `subosito/flutter-action@v2` (`flutter-version-file: .fvmrc`) 로 SDK 를 맞추고, `~/.dartServer` 는 캐시하지 않는다. 정상 job 은 약 2분, 첫 분석은 약 43초다 (006)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 한다
- 검증에는 네트워크가 필요하다 (002)
- `example/` 의 패키지는 `dart pub get` 으로 받는다 (004)
- `dart analyze` 는 사용 통계 전송을 끈 채 실행한다 (001)
- 검증 명령은 `example/` 을 분석할 때 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 저장소 안의 전용 상태 폴더를 준다 (008)

MANIFEST.md 의 `preset-split-include-behavior` 에서 이 영역에 걸리는 것.

- 연습용 프로젝트는 폴더마다 따로 두고 상태 폴더도 프로젝트마다 따로 준다 (지금 검증 명령의 방식 그대로). 여섯이 로컬에서 처음 66초, 재실행 20 ~ 21초다. 상태 폴더를 하나로 합치면 plugin 폴더가 넷이 되어 버전을 읽지 못한다. plugin 준비는 경로가 다르면 나눠 쓰지 못한다 (014)
- 시간이 문제가 되면 상태 폴더를 따로 둔 채 동시에 띄우는 것을 먼저 본다 — 로컬에서 여섯이 23초이고 결과가 같았다. GitHub runner 에서의 여섯은 재지 않았다 (추정 약 4분 20 ~ 30초) (014)

MANIFEST.md 의 `next-sdk-forward-compat` 에서 이 영역에 걸리는 것.

- 고정 SDK 를 Dart 3.14 계열로 올리기 전에 016 의 두 스크립트를 그 SDK 로 돌린다. `probe.dart` 의 `≠` 10칸 중 생성 파일 제외에서 온 8칸이 `=` 로 돌아오면 되돌리는 변경이 들어간 것이고 (루트 분석의 2칸 R1 · R2 는 다른 변경(sdk#63627)에서 온 것이라 `≠` 로 남을 것이다), 10칸 그대로면 정답지 셋을 갱신하며 "SDK 가 바뀌어 생긴 줄" 로 기록한다 (016)
- plugin 진단 확인은 베타에서도 `dart analyze` 로 한다. 베타의 `flutter analyze` 는 plugin 진단을 내지만 규칙 진단을 겹쳐 세고 그 수가 실행마다 달랐다 (016)

위의 "8칸" · "2칸" 을 어떻게 읽는지와 "정답지 셋" 이 어느 파일인지는 next-sdk-forward-compat.md 9번 · 3번에 있다 — 칸의 수가 아니라 칸의 내용을 읽는다.

이 문서에서 문서 이름 없이 적은 D-NN 은 02-CONTEXT.md 의 것이다. 03-CONTEXT.md 의 결정은 문서 이름을 붙여 적었다.

## How to Build It

### 1. workflow 의 뼈대

spike 가 실제로 돌린 workflow 에서 표본용 `matrix` 를 걷어 낸 형태다. `name`, 실행 조건(`on:`), 마지막 step 의 명령은 Phase 2 계획에서 정한다.

```yaml
# 저장소를 읽기만 한다.
permissions:
  contents: read

# 같은 브랜치에 새로 올리면 앞선 실행은 취소한다.
concurrency:
  group: <이름>-${{ github.ref }}
  cancel-in-progress: true

jobs:
  verify:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v7

      # .fvmrc 를 읽어 로컬과 같은 Flutter 를 설치한다.
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: .fvmrc

      - name: 검증
        run: <검증 명령>
```

spike 의 원본은 `sources/006-github-runner-cold-plugin/spike-006-cold-plugin.yml` 이다 (`timeout-minutes: 15`, `matrix.sample: [1..5]`, `fail-fast: false`). Phase 2 가 이 뼈대로 `.github/workflows/verify.yml` 을 만들었다 — 마지막 step 은 `dart run tool/verify.dart`, `timeout-minutes` 는 10 이다.

- **Flutter 버전 숫자를 workflow 에 적지 않는다.** `flutter-version-file: .fvmrc` 하나로 로컬과 같은 Flutter 3.47.5 / Dart 3.13.4 가 설치됐다.
- 그래서 `.fvmrc` 를 올리는 커밋이 곧 CI 의 SDK 를 올리는 커밋이다. Dart 3.14 계열로 올리면 codegen 조각을 받는 연습용 프로젝트의 정답지에 4줄이 생겨 `verify` job 이 "정답지와 다름" 으로 실패할 수 있다 — 2026-10-12 의 베타에서는 그 4줄이 나왔고, 상류가 되돌리려는 중이다. 올리기 전에 016 의 두 스크립트를 그 SDK 로 돌려 본다 (→ next-sdk-forward-compat.md 9번). job 이 실패하는 모양 자체는 재지 않았다 (`tool/verify.dart` 를 베타로 돌리지 않았다).
- **`timeout-minutes` 는 10** 이면 넉넉하다 (정상 약 2분). pub 서버에 닿지 못해도 plugin 준비는 약 30초 뒤 실패로 끝나므로, 멈춰 있는 경우만 막으면 된다.
- **`~/.dartServer` 는 캐시하지 않는다.** 캐시 없이도 43초이고, 캐시하면 plugin 준비 실패가 가려질 수 있다 (PITFALLS.md Pitfall 12).
- 검증 명령이 쓰는 전용 상태 폴더(→ analyze-run-and-verdict.md 2번)도 같은 이유로 캐시하지 않는다. runner 는 매번 저장소를 새로 받으므로 그 폴더는 비어 있고 첫 분석은 늘 처음 실행이다. 빈 폴더를 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 준 cold 실행은 runner 에서 30번 돌려 30번 모두 통과했다 (27.0~52.6초, spike 006 의 C1~C3. 그때의 폴더는 저장소 밖 `RUNNER_TEMP` 아래였다).
- 검증 명령은 `--suppress-analytics` 를 항상 붙인다. runner 에서는 없어도 되지만 로컬과 같은 방식으로 돌도록 맞춘다.

### 2. job 하나의 시간

| 단계 | 시간 |
|---|---|
| checkout | 1초 |
| Flutter 설치 (`flutter-action`, 캐시 없음) | 약 66초 |
| `dart pub get` (빈 pub cache) | 2~4초 |
| `dart analyze` 첫 실행 | 약 43초 (27~53초) |
| 합계 | **약 2분** |

같은 프로젝트를 한 번 더 분석하면 약 8초(5.5~10.6초)가 더 든다. 규칙 검사(→ rule-status-check.md)는 로컬에서 0.5초다 (spike 007). runner 에서는 재지 않았다.

**연습용 프로젝트가 여섯으로 늘면 (추정이다. 올려야 잴 수 있다).** runner 는 매번 빈 상태 폴더에서 시작하므로 plugin 을 쓰는 프로젝트 넷이 각각 plugin 을 받아 컴파일한다 — 폴더가 다르면 plugin 준비를 나눠 쓰지 못한다 (014).

| 방식 | 셈 | 분석 | job 전체 |
|---|---|---|---|
| 폴더 · 상태 폴더를 프로젝트마다 따로 (채택) | plugin 넷 × 약 44초 + plugin 없는 둘 × 약 9초 | 약 3분 15초 | **약 4분 20 ~ 30초** |
| 작업 폴더 하나에서 옵션 파일만 바꿔 가며 | 44초 + 재실행 셋 × 약 8초 + plugin 없는 둘 × 약 2초 | 약 1분 15초 | 약 2분 25초 |

- 근거: 실제 `verify` job 이 1분 54초이고 그중 `example/` 분석이 약 44초, 그 밖이 약 70초다 (run 38158088016). plugin 없는 프로젝트의 9초는 로컬 3.2초에 runner / 로컬 비(약 2.9 — 014 가 쓴 값)를 곱한 값이다. 아래 Constraints 의 "2.5배쯤" (006) 은 로컬의 처음 실행을 약 17초로 본 값이고, 어느 쪽을 곱해도 이 항은 8 ~ 9초다.
- 추정대로라면 `timeout-minutes: 10` 안에 든다. Phase 3 을 끝내기 전에 여섯으로 늘어난 검증을 올려서 본다 (03-CONTEXT.md D-09).
- 동시에 띄우면 로컬(프로세서 10개)에서 여섯이 23초였다. runner(4 cores)에서의 값은 추정하지 않았다.

### 3. runner 의 환경

```text
Flutter 3.47.5 • channel stable
Dart SDK version: 3.13.4 (stable) on "linux_x64"
Dart 3.13.4 on linux (4 cores)
GITHUB_ACTIONS=true CI=true DASH__SUPPRESS_ANALYTICS=true
첫 실행 전 상태 폴더: 없음 (/home/runner/.dartServer)
```

- `DASH__SUPPRESS_ANALYTICS=true` 는 workflow 에서 설정하지 않았다. `dart run` 이 CI 환경임을 알아채고 하위 도구에 넘긴 값이다.
- `~/.dartServer` 가 없는 진짜 처음 상태에서 시작한다.

### 4. 결과를 로그와 요약에 남기는 방법

- 로그에서 한 줄로 집어낼 수 있게 표시를 붙여 JSON 을 찍는다: `SPIKE006_RESULT {…}` → `gh run view <run id> --log | grep SPIKE006_RESULT`.
- `GITHUB_STEP_SUMMARY` 환경변수가 가리키는 파일에 Markdown 을 덧붙이면 run 화면에 표로 보인다.

```dart
// sources/006-github-runner-cold-plugin/ci_probe.dart
final stepSummary = env['GITHUB_STEP_SUMMARY'];
if (stepSummary != null && stepSummary.isNotEmpty) {
  // … buffer 에 Markdown 표를 만든다
  try {
    File(stepSummary).writeAsStringSync(buffer.toString(), mode: FileMode.append);
  } on FileSystemException catch (e) {
    stderr.writeln('step summary 를 쓰지 못했다: ${e.message}');
  }
}
```

### 5. 실행을 확인하는 명령

```bash
gh run list --workflow <workflow 파일 이름> --limit 5
gh run view <run id> --log
```

## What to Avoid

- **`~/.dartServer` 를 캐시하는 것.** plugin 준비 실패가 가려질 수 있다. 캐시 없이도 첫 분석은 약 43초다. 캐시했을 때 얼마나 줄어드는지는 재지 않았다.
- **workflow 에 Flutter 버전을 숫자로 적는 것.** `.fvmrc` 와 어긋날 자리가 하나 더 생긴다.
- **수동 실행 버튼(`workflow_dispatch`)에 기대는 것.** 기본 브랜치(`main`)에 workflow 파일이 있어야 버튼이 보인다. `main` 에 들어가기 전에는 push 로만 돌릴 수 있다 (D-06).
- **CI 에서 `flutter pub get` / `flutter analyze` 를 쓰는 것.** 앞의 것은 `example/analysis_options.yaml` 을 고치고(→ example-project-and-expected-file.md), 뒤의 것은 Flutter 3.47.5 에서 plugin 진단을 내지 않는다. 베타(Flutter 3.49.0-0.2.pre)에서는 plugin 진단을 내지만 규칙 진단을 겹쳐 세고 건수가 실행마다 달랐다 (016).
- **`.fvmrc` 를 올린 커밋에서 깨진 정답지를 그 커밋의 다른 변경 탓으로 읽는 것.** 더해진 줄이 `lib/generated/sample.*.dart` 의 4줄이면 SDK 가 바뀌어 생긴 것이다 (016).
- **"runner 에서는 사용 통계가 자동으로 꺼지니 플래그를 빼도 된다"로 정리하는 것.** 로컬에서 같은 검증 명령이 255 로 죽는다.

## Constraints

- **cold 실행에서 plugin 진단이 빠지지 않는다.** 60번 모두 기대 진단 파일과 한 줄도 다르지 않았다 (빠진 줄 0, 남는 줄 0, 종료 코드도 기대대로). stderr 는 60번 모두 비어 있었다.
- 종료 코드 255 는 60번 중 0번이었다. 그중 40번은 사용 통계를 끄는 인자를 주지 않은 cold 실행이다 (로컬에서는 같은 조건이 24번 중 7번 죽었다).
- "진짜 첫 실행"(pub cache 도 비어 있음)과 "상태 폴더만 비운 cold"의 시간이 거의 같다. plugin 이 기대는 패키지를 내려받는 시간은 작고 대부분이 plugin 컴파일이다. 로컬(약 17초)보다 2.5배쯤 느리다.
- 실제로 풀린 plugin 은 10대 모두 `riverpod_lint` 3.1.9 였다.
- action 버전: `actions/checkout` v7.0.1 (2026-07-20), `subosito/flutter-action` v2.23.0 (2026-03-25). 둘 다 major tag(`v7`, `v2`)가 있다. `flutter-action` 의 `cache` 기본값은 `false` 다.
- push 로 도는 workflow 는 올라간 브랜치의 workflow 파일을 쓴다. 기본 브랜치에 파일이 없어도 돈다.
- 작업 브랜치(`gsd/v2.0-package-rework`)는 이미 원격에 올라가 있다 (02-CONTEXT.md D-08, D-09). `.planning/` 이 공개된다는 뜻이므로 결과 파일에는 로컬 절대 경로를 남기지 않는다.
- 확인하지 않은 것: macOS / Windows runner (CI 는 Linux 만 쓴다), SDK 캐시(`cache: true`)를 켰을 때의 시간 (약 66초를 줄여 주지만 넣을지는 계획 때 정한다), GitHub 나 pub.dev 에 장애가 있을 때의 모습 (spike 002 의 로컬 재현으로 갈음), spike 007(루트의 `example/**` 제외, 규칙 검사의 실행 형태)과 008(상태 폴더를 함께 쓸 때, 깨진 뒤의 회복)의 실험을 runner 에서 한 것, spike 009 ~ 016 의 실험을 runner 에서 한 것 (전부 로컬 macOS 에서 쟀다), 연습용 프로젝트 여섯의 실제 job 시간, 다음 SDK 에서의 job (베타는 로컬에서만 돌렸고 CI 의 SDK 는 `.fvmrc` 를 따른다).

## Origin

Synthesized from spikes: 006 (전용 상태 폴더와 규칙 검사 시간에 관한 두 줄은 007, 008 의 결과를, 여섯으로 늘 때의 추정은 014 의 결과를, `.fvmrc` 를 올릴 때의 주의는 016 의 결과를 덧붙인 것이다)
Source files available in: sources/006-github-runner-cold-plugin/, sources/014-multi-fixture-plugin-cost/
원본 결과: `.planning/spikes/006-github-runner-cold-plugin/results/run-38136362920.json`, `run-38136362920-attempt2.json`
