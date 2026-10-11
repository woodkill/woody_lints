# GitHub Actions CI

검증 명령을 GitHub 의 Linux runner 에서 돌리는 workflow 다. 캐시가 하나도 없는 새 가상 머신에서도 plugin 진단이 로컬과 똑같이 나오는지, 얼마나 걸리는지를 쟀다.

모든 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, `ubuntu-latest` (4 cores), 2026-10-11 실측이다. 새 가상 머신 10대에서 분석 60번.

## Requirements

MANIFEST.md 의 `verify-harness-tool-behavior` 에서 이 영역에 걸리는 것.

- CI 는 `actions/checkout@v7` + `subosito/flutter-action@v2` (`flutter-version-file: .fvmrc`) 로 SDK 를 맞추고, `~/.dartServer` 는 캐시하지 않는다. 정상 job 은 약 2분, 첫 분석은 약 43초다 (006)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 한다
- 검증에는 네트워크가 필요하다 (002)
- `example/` 의 패키지는 `dart pub get` 으로 받는다 (004)
- `dart analyze` 는 사용 통계 전송을 끈 채 실행한다 (001)

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

spike 의 원본은 `sources/006-github-runner-cold-plugin/spike-006-cold-plugin.yml` 이다 (`timeout-minutes: 15`, `matrix.sample: [1..5]`, `fail-fast: false`).

- **Flutter 버전 숫자를 workflow 에 적지 않는다.** `flutter-version-file: .fvmrc` 하나로 로컬과 같은 Flutter 3.47.5 / Dart 3.13.4 가 설치됐다.
- **`timeout-minutes` 는 10** 이면 넉넉하다 (정상 약 2분). pub 서버에 닿지 못해도 plugin 준비는 약 30초 뒤 실패로 끝나므로, 멈춰 있는 경우만 막으면 된다.
- **`~/.dartServer` 는 캐시하지 않는다.** 캐시 없이도 43초이고, 캐시하면 plugin 준비 실패가 가려질 수 있다 (PITFALLS.md Pitfall 12).
- 검증 명령은 `--suppress-analytics` 를 항상 붙인다. runner 에서는 없어도 되지만 로컬과 같은 방식으로 돌도록 맞춘다.

### 2. job 하나의 시간

| 단계 | 시간 |
|---|---|
| checkout | 1초 |
| Flutter 설치 (`flutter-action`, 캐시 없음) | 약 66초 |
| `dart pub get` (빈 pub cache) | 2~4초 |
| `dart analyze` 첫 실행 | 약 43초 (27~53초) |
| 합계 | **약 2분** |

같은 프로젝트를 한 번 더 분석하면 약 8초(5.5~10.6초)가 더 든다. 규칙 검사(→ rule-status-check.md)가 저장소 루트를 분석하는 시간은 runner 에서 재지 않았다.

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
- **CI 에서 `flutter pub get` / `flutter analyze` 를 쓰는 것.** 앞의 것은 `example/analysis_options.yaml` 을 고치고(→ example-project-and-expected-file.md), 뒤의 것은 plugin 진단을 내지 않는다.
- **"runner 에서는 사용 통계가 자동으로 꺼지니 플래그를 빼도 된다"로 정리하는 것.** 로컬에서 같은 검증 명령이 255 로 죽는다.

## Constraints

- **cold 실행에서 plugin 진단이 빠지지 않는다.** 60번 모두 기대 진단 파일과 한 줄도 다르지 않았다 (빠진 줄 0, 남는 줄 0, 종료 코드도 기대대로). stderr 는 60번 모두 비어 있었다.
- 종료 코드 255 는 60번 중 0번이었다. 그중 40번은 사용 통계를 끄는 인자를 주지 않은 cold 실행이다 (로컬에서는 같은 조건이 24번 중 7번 죽었다).
- "진짜 첫 실행"(pub cache 도 비어 있음)과 "상태 폴더만 비운 cold"의 시간이 거의 같다. plugin 이 기대는 패키지를 내려받는 시간은 작고 대부분이 plugin 컴파일이다. 로컬(약 17초)보다 2.5배쯤 느리다.
- 실제로 풀린 plugin 은 10대 모두 `riverpod_lint` 3.1.9 였다.
- action 버전: `actions/checkout` v7.0.1 (2026-07-20), `subosito/flutter-action` v2.23.0 (2026-03-25). 둘 다 major tag(`v7`, `v2`)가 있다. `flutter-action` 의 `cache` 기본값은 `false` 다.
- push 로 도는 workflow 는 올라간 브랜치의 workflow 파일을 쓴다. 기본 브랜치에 파일이 없어도 돈다.
- 작업 브랜치(`gsd/v2.0-package-rework`)는 이미 원격에 올라가 있다 (D-08, D-09). `.planning/` 이 공개된다는 뜻이므로 결과 파일에는 로컬 절대 경로를 남기지 않는다.
- 확인하지 않은 것: macOS / Windows runner (CI 는 Linux 만 쓴다), SDK 캐시(`cache: true`)를 켰을 때의 시간 (약 66초를 줄여 주지만 넣을지는 계획 때 정한다), GitHub 나 pub.dev 에 장애가 있을 때의 모습 (spike 002 의 로컬 재현으로 갈음).

## Origin

Synthesized from spikes: 006
Source files available in: sources/006-github-runner-cold-plugin/
원본 결과: `.planning/spikes/006-github-runner-cold-plugin/results/run-38136362920.json`, `run-38136362920-attempt2.json`
