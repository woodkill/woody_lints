# GitHub Actions CI

검증 명령을 GitHub 의 Linux runner 에서 돌리는 workflow 다. 캐시가 하나도 없는 새 가상 머신에서도 plugin 진단이 로컬과 똑같이 나오는지, 얼마나 걸리는지, 연습용 프로젝트가 여섯으로 늘면 얼마나 걸리는지, runner 의 운영체제가 Ubuntu 26.04 로 바뀌어도 같은 결과가 나오는지를 쟀다.

따로 적지 않은 수치는 Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, `ubuntu-latest` (4 cores), 2026-10-11 실측이다 (006 — 새 가상 머신 10대에서 분석 60번). 3번과 4번은 2026-10-12 에 임시 workflow 한 번(run `38216842742`, job 15개)과 같은 push 의 `verify` 한 번으로 쟀다 (017, 018 — 이미지 `ubuntu-24.04` 20261004.327.1 과 `ubuntu-26.04` 20260927.149.1, 둘 다 코어 4개 · 메모리 약 16GB). 다음 SDK 에 관한 줄은 016 (로컬의 베타, 2026-10-12) 의 것이다.

**3번과 4번이 돌린 것은 spike 의 스크립트(`runner_probe.dart`)와 지금의 검증 명령이다.** 여섯으로 늘린 `tool/verify.dart` 는 아직 없다 — 그것을 runner 에서 돌린 값이 아니다.

## Requirements

MANIFEST.md 의 `verify-harness-tool-behavior` 에서 이 영역에 걸리는 것.

- CI 는 `actions/checkout@v7` + `subosito/flutter-action@v2` (`flutter-version-file: .fvmrc`) 로 SDK 를 맞추고, `~/.dartServer` 는 캐시하지 않는다. 정상 job 은 약 2분, 첫 분석은 약 43초다 (006)
- 실측은 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 한다
- 검증에는 네트워크가 필요하다 (002)
- `example/` 의 패키지는 `dart pub get` 으로 받는다 (004)
- `dart analyze` 는 사용 통계 전송을 끈 채 실행한다 (001)
- 검증 명령은 `example/` 을 분석할 때 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 저장소 안의 전용 상태 폴더를 준다 (008)
- workflow 의 `runs-on: ubuntu-latest` 는 그대로 둔다. `ubuntu-latest` 는 2026-10-19 ~ 11-19 에 Ubuntu 26.04 로 옮겨 가고(actions/runner-images#14748), 그 이미지(`ubuntu-26.04` — 26.04.1 LTS · glibc 2.43 · 버전 20260927.149.1)에서 지금의 검증 명령 세 번과 연습용 프로젝트 여섯의 점검 여섯 번이 `ubuntu-24.04` 와 같은 결과였다. 옮겨 간 뒤 CI 가 실패하면 로그의 `Image` · `Version` 줄을 이 값과 견준다 (018)

MANIFEST.md 의 `preset-split-include-behavior` 에서 이 영역에 걸리는 것.

- 연습용 프로젝트는 폴더마다 따로 두고 상태 폴더도 프로젝트마다 따로 준다 (지금 검증 명령의 방식 그대로). 여섯이 로컬에서 처음 66초, 재실행 20 ~ 21초다. 상태 폴더를 하나로 합치면 plugin 폴더가 넷이 되어 버전을 읽지 못한다. plugin 준비는 경로가 다르면 나눠 쓰지 못한다 (014)
- 시간이 문제가 되면 상태 폴더를 따로 둔 채 동시에 띄우는 것을 먼저 본다 — 로컬에서 여섯이 23초이고 결과가 같았다. GitHub runner 에서의 여섯은 014 가 재지 않았다 (추정 약 4분 20 ~ 30초 — 그 뒤 017 이 쟀다) (014)
- 연습용 프로젝트 여섯을 지금의 방식(차례로, 상태 폴더는 프로젝트마다 따로)으로 돌려도 GitHub runner 의 `timeout-minutes: 10` 안에 넉넉히 든다. 처음 실행의 분석이 146 ~ 191초이고, 재실행을 뺀 job 이 약 3분 20초 ~ 4분 20초다 (spike 의 스크립트를 돌린 값이고 여섯으로 늘린 `tool/verify.dart` 가 아니다. 코어 4개, 표본 여섯, 2026-10-12). 014 의 추정(약 4분 20 ~ 30초)을 대신한다 (017)
- 한꺼번에 띄우면 runner 에서 분석이 69 ~ 95초로 약 절반이 된다 (로컬처럼 3분의 1 이 되지는 않는다). plugin 을 쓰는 넷이 plugin 쪽 패키지(`riverpod_lint`, `analyzer` 등)를 새 가상 머신의 pub cache 에 동시에 처음 받는 경우를 포함해 여섯 번 모두 결과가 같았다. 표본이 적어 "드물게 깨지는지" 는 알 수 없다. 차례로 돌려도 시간 제한에 여유가 있으므로 넣을지는 계획이 정한다 (017)

위 목록에서 014 의 추정은 그 뒤의 017 두 줄이 대신한다 (→ 3번).

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
- **`timeout-minutes` 는 10** 이면 넉넉하다 (정상 약 2분). pub 서버에 닿지 못해도 plugin 준비는 약 30초 뒤 실패로 끝나므로, 멈춰 있는 경우만 막으면 된다. 연습용 프로젝트를 여섯으로 늘려 차례로 돌려도 가장 느린 표본이 258초(spike 의 스크립트, 재실행을 뺀 셈)라 10분의 절반이 안 된다 (017 → 3번).
- **`runs-on: ubuntu-latest` 는 그대로 둔다.** 2026-10-19 부터 이 이름이 가리키는 이미지가 Ubuntu 26.04 로 바뀌는데, 그 이미지를 직접 지정해 미리 돌린 결과가 지금과 같았다 (018 → 4번). `ubuntu-24.04` 로 못박는 줄은 넣지 않는다.
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

같은 프로젝트를 한 번 더 분석하면 약 8초(5.5~10.6초)가 더 든다. 규칙 검사(→ rule-status-check.md)는 로컬에서 0.5초다 (spike 007). runner 에서 규칙 검사만 따로 잰 값은 없다.

지금의 `verify` job (프로젝트 하나)을 2026-10-12 에 다시 본 값: 같은 push 의 `verify` 가 88초 (Flutter 설치 46초, 검증 step 36초 — `ubuntu-latest` = `ubuntu-24.04`), 이미지만 `ubuntu-26.04` 로 바꾼 세 번이 70 / 70 / 58초다 (018 → 4번). 위 표의 "약 2분" 보다 짧다 — Flutter 설치와 검증 step 이 둘 다 그날 더 짧았다 (24.04 쪽은 표본 하나다).

### 3. 연습용 프로젝트가 여섯일 때 (017)

나눈 구조의 replica 에 03-CONTEXT.md D-03 의 여섯 조합을 만들어(→ fixtures-after-split.md 1번) runner 에서 돌렸다. runner 의 job 은 매번 새 가상 머신이라 상태 폴더가 비어 있으므로 plugin 을 쓰는 프로젝트 넷이 각각 plugin 을 받아 컴파일한다 — 폴더가 다르면 plugin 준비를 나눠 쓰지 못한다 (014).

방식(차례로 / 한꺼번에)마다 job 을 따로 두고 표본을 셋씩, 이미지 둘에서 돌렸다 (job 12개). 초 단위이고 `첫째 / 둘째 / 셋째 표본` 이다.

| 이미지 | 방식 | 처음 실행의 분석 | 재실행 | Flutter 설치 | job 전체 (재실행 포함) | 재실행을 뺀 job |
|---|---|---|---|---|---|---|
| `ubuntu-24.04` | 차례로 | 145.8 / 186.4 / 166.1 | 43.1 / 50.1 / 50.7 | 46 / 62 / 64 | 245 / 308 / 293 | 202 / 258 / 242 |
| `ubuntu-24.04` | 한꺼번에 | 68.8 / 93.6 / 79.5 | 20.2 / 26.9 / 22.7 | 49 / 56 / 49 | 146 / 185 / 159 | 126 / 158 / 136 |
| `ubuntu-26.04` | 차례로 | 191.2 / 165.5 / 178.4 | 48.3 / 47.9 / 49.4 | 34 / 39 / 33 | 282 / 263 / 269 | 234 / 215 / 220 |
| `ubuntu-26.04` | 한꺼번에 | 94.9 / 94.0 / 78.4 | 30.2 / 29.8 / 22.2 | 33 / 32 / 28 | 166 / 163 / 136 | 136 / 133 / 114 |

- **spike 의 job 은 처음 실행 뒤에 재실행을 한 번 더 했다.** 실제 `verify` job 은 처음 실행만 하므로 마지막 칸이 실제 job 에 가까운 값이다 — 잰 job 시간에서 재실행 시간을 뺀 **셈**이고 따로 잰 것은 아니다. 이 값에는 Flutter 설치, 스크립트를 띄우는 시간, 루트와 프로젝트 여섯의 `pub get` 이 들어 있고, 규칙 검사와 화면 출력은 들어 있지 않다. 지금의 `verify` 에서 분석 말고 남는 몫은 몇 초다 — run 38158088016 에서 검증 명령 47초 가운데 `example/` 분석이 약 44초였다 (규칙 검사만의 시간은 따로 찍히지 않는다).
- **차례로 (지금의 방식을 그대로 늘린 것): 분석 145.8 ~ 191.2초 (평균 172초), 재실행을 뺀 job 은 202 ~ 258초 — 약 3분 20초 ~ 4분 20초다.** 014 가 셈한 분석 시간(약 3분 15초 = 195초)보다 조금 짧았고, 014 의 job 추정(약 4분 20 ~ 30초 = 260 ~ 270초)은 가장 느린 표본(258초)보다 조금 길었다.
- **한꺼번에: 분석 68.8 ~ 94.9초 (평균 85초), 재실행을 뺀 job 은 114 ~ 158초 — 약 1분 55초 ~ 2분 40초다.** 차례 실행의 약 절반이다. 로컬(프로세서 10개)에서는 66초가 23초로 3분의 1 이 됐지만 코어 4개에서는 그만큼 줄지 않는다.
- 표본 사이가 많이 벌어진다. 같은 이미지 · 같은 방식의 세 표본에서 가장 느린 것이 가장 빠른 것보다 16 ~ 36% 길었다 (칸마다 28% · 36% · 16% · 21%). 이미지 사이의 평균 차이(7 ~ 10%)는 그 안에 든다. 017 · 018 의 README 는 이 벌어짐을 "20 ~ 30%" 로 적었다 — 위는 원본 JSON 으로 다시 센 값이다.

프로젝트 하나씩의 시간 (차례로 돈 job 여섯의 범위, 초).

| 프로젝트 | 처음 실행 | 재실행 |
|---|---|---|
| `example` (옛 주소) | 34.7 ~ 45.1 | 6.4 ~ 8.3 |
| `recommended` | 34.0 ~ 44.8 | 6.5 ~ 8.3 |
| `overrides` | 34.2 ~ 44.7 | 6.5 ~ 8.4 |
| `base_riverpod` | 30.4 ~ 40.7 | **9.8 ~ 14.0** |
| `base_only` — plugin 없음 | 6.2 ~ 8.1 | 5.7 ~ 7.5 |
| `base_codegen` — plugin 없음 | 6.2 ~ 8.0 | 6.1 ~ 7.7 |

- plugin 을 쓰는 프로젝트는 처음 실행에 30 ~ 45초다. 006 이 잰 "약 43초 (27~53초)" 와 같은 자리다. plugin 쪽 패키지를 처음 받는 첫째 프로젝트와 둘째부터의 시간이 같았다 — 받는 시간보다 컴파일 시간이 대부분이라고 읽었다 (시간이 같다는 것까지가 잰 것이다. 006 의 "진짜 첫 실행과 상태 폴더만 비운 cold 의 시간이 거의 같다" 와 맞는다).
- plugin 을 쓰지 않는 프로젝트는 6 ~ 8초다 (014 의 셈은 약 9초였다).
- `base_riverpod` 의 재실행만 다른 프로젝트보다 3 ~ 6초 길었다. 차례로 돈 여섯 job 모두에서 그랬고 로컬에서는 보이지 않았다. 까닭은 가르지 않았다 — 결과(21줄, `exit 2`)는 예상과 같았고 CI 는 재실행을 하지 않는다.
- `pub get` 은 루트가 0.06 ~ 0.15초, 첫째 프로젝트가 1.2 ~ 3.5초, 둘째부터 0.1초 이하다 (새 가상 머신에서 시작한 job 열둘의 범위. 스크립트는 루트 → 프로젝트 여섯의 차례로 받는다). 014 가 재지 않고 남긴 "pub cache 가 빈 상태의 `pub get`" 에 가장 가까운 값이 첫째 프로젝트의 것이다 — pub cache 의 내용을 들여다본 것은 아니다.

결과가 같았는가.

- **job 12개 × 확인 24건 = 288건이 모두 성립했다.** 확인은 프로젝트마다 둘이다 — 진단이 예상한 줄과 줄 단위로 같고 종료 코드가 같은가(`Checks.same`), plugin 준비가 예상과 같은가(plugin 을 쓰는 넷은 plugin 폴더 1개 · `plugin.aot` 있음 · 실패 머리말 없음, 쓰지 않는 둘은 0개). 처음 실행과 재실행에서 각각 봤다.
- 줄 수와 종료 코드는 열두 job 모두 `example` 16 · `recommended` 16 · `base_only` 18 · `overrides` 15 · `base_riverpod` 21 · `base_codegen` 13줄, `exit` 2 / 2 / 2 / 2 / 2 / 0 이다. 로컬의 예상과 같다. stderr 는 열두 job 모두 비어 있었다 (원본 JSON 의 `stderrHeads` 가 비어 있다).
- **한꺼번에 띄운 처음 실행 여섯 번이 모두 통과했다.** 이 실행에서 plugin 을 쓰는 넷은 `riverpod_lint` · `analyzer` 등 plugin 쪽 패키지를 같은 pub cache 에 동시에 처음 받는다. 로컬의 동시 실행(014)은 pub cache 가 채워진 상태라 이 경우를 지나지 않았다. 동시에 분석을 띄우기 전에 프로젝트 여섯의 `pub get` 은 차례로 끝나 있었다 — 동시에 받는 것은 분석 서버가 plugin 을 준비하며 받는 패키지다. 새 가상 머신이라 그 패키지가 pub cache 에 없었을 것으로 읽었고, pub cache 를 들여다본 것은 아니다.
- plugin 쪽에서 풀린 버전은 열두 job 모두 `riverpod_lint` 3.1.9 / `analyzer` 14.5.0 / `analysis_server_plugin` 0.3.24 다 (로컬과 같다).
- 여기의 `overrides` 는 014 와 같은 가벼운 옵션이다 — 묶음에 `provider_parameters` 하나를 껐다 (15줄). 실제 끄는 설정용 프로젝트는 샘플이 더 많다.

Phase 3 의 계획이 가져갈 것.

- **`tool/verify.dart` 를 차례로 돌리는 지금의 구조 그대로 여섯으로 늘려도 된다.** 시간 제한 때문에 구조를 바꿀 까닭이 없다.
- 한꺼번에 띄우는 것은 "자동 점검 한 번에 약 1분 30초를 줄이는" 선택지다. 넣는다면 상태 폴더는 지금처럼 따로 주고, 화면은 여섯이 다 끝난 뒤에 정해진 순서로 찍는다 (014 → fixtures-after-split.md 7번). 표본이 여섯 번이라 드물게 깨지는지는 알 수 없다. 넣을지는 계획이 정한다.
- 03-CONTEXT.md D-03 이 소유자에게 밝힌 "자동 점검이 약 2분에서 약 4분 15초로 늘 것" 은 잰 범위(3분 20초 ~ 4분 20초) 안에 있다.
- 03-CONTEXT.md D-09 의 "phase 를 끝내기 전에 fixture 여섯으로 늘어난 검증이 GitHub runner 에서 통과하고 시간 제한 안에 끝나는 것을 본다" 는 그대로 남는다. 여기서 돌린 것은 spike 의 스크립트이고 실제 `tool/verify.dart` 가 아니다.

작업 폴더 하나에서 옵션 파일만 바꿔 가며 돌리는 방식(014 의 B)은 runner 에서 재지 않았다. 014 의 셈으로는 분석 약 1분 15초 · job 약 2분 25초인데, 같은 셈법이 차례 실행을 약간 길게 잡았다는 것만 안다.

### 4. 다음 runner 이미지 — Ubuntu 26.04 (018)

GitHub 이 `ubuntu-latest` 가 가리키는 이미지를 바꾼다. `verify` 의 2026-10-12 실행에 예고가 붙어 있었다 — "The ubuntu-latest label will migrate to Ubuntu 26 beginning October 19, 2026".

- 예고의 원문은 actions/runner-images#14748 이다 (2026-09-17 에 열림, 2026-10-12 읽음). 2026-10-19 부터 몇 주에 걸쳐 옮겨 가고 2026-11-19 까지 끝난다. 문제가 생기면 `ubuntu-24.04` 를 지정해 되돌리고, 미리 시험하려면 `ubuntu-26.04` 를 지정하라고 안내한다.
- 2026-10-12 에 `ubuntu-latest` 는 아직 `ubuntu-24.04` 였다 (같은 push 의 `verify` 로그에 `Image: ubuntu-24.04`, `Version: 20261004.327.1`).

이미지가 실제로 달랐는가 (대조).

| | `ubuntu-24.04` | `ubuntu-26.04` |
|---|---|---|
| `/etc/os-release` | Ubuntu 24.04.5 LTS | Ubuntu 26.04.1 LTS |
| glibc (`ldd --version`) | 2.39 | 2.43 |
| 이미지 버전 | 20261004.327.1 | 20260927.149.1 |
| 코어 / 메모리 | 4 / 약 16GB | 4 / 약 16GB |

지금의 검증 명령 (`dart run tool/verify.dart` — `verify.yml` 과 같은 step, 이미지만 바꿨다).

| job | 이미지 | 결과 | Flutter 설치 | 검증 step | job 전체 |
|---|---|---|---|---|---|
| `verify · ubuntu-26.04 · 1` | 26.04 | `점검 통과 (4개 중 4개)` | 27초 | 37초 | 70초 |
| `verify · ubuntu-26.04 · 2` | 26.04 | `점검 통과 (4개 중 4개)` | 27초 | 38초 | 70초 |
| `verify · ubuntu-26.04 · 3` | 26.04 | `점검 통과 (4개 중 4개)` | 24초 | 29초 | 58초 |
| `verify` (같은 push, 기준) | `ubuntu-latest` = 24.04 | `점검 통과 (4개 중 4개)` | 46초 | 36초 | 88초 |

- 화면의 버전 세 줄이 네 job 모두 같다 — `SDK  Flutter 3.47.5 / Dart 3.13.4`, `기반 세트  flutter_lints 6.0.0 / lints 6.1.0`, `plugin  riverpod_lint 3.1.9`.
- 검증 명령은 정답지와 한 줄이라도 다르면 실패한다. 통과했다는 것은 26.04 에서 `example/` 의 진단 16줄과 `exit 2` 가 정답지와 같았다는 뜻이다.
- 연습용 프로젝트 여섯(3번의 스크립트)도 26.04 의 job 여섯에서 확인 144건이 모두 성립했고, 줄 수와 종료 코드가 24.04 의 job 여섯과 같다.
- plugin 준비(받기 · AOT 컴파일)는 glibc 2.43 의 이미지에서 실패하지 않았다 — 아홉 job 에서 plugin 을 처음부터 준비한 실행이 27번이다 (검증 3 + 여섯 프로젝트 점검 6 job × plugin 을 쓰는 넷의 처음 실행). 준비된 plugin 을 다시 쓴 재실행 24번도 모두 통과했다 (018 의 README 는 둘을 합쳐 51번으로 적었다).
- 시간은 표본 차이 안에서 같다 (3번의 표). Flutter 설치는 26.04 에서 24 ~ 39초, 24.04 에서 46 ~ 64초였다. 까닭은 가르지 않았다.

그래서.

- **workflow 는 바꾸지 않는다.** `runs-on: ubuntu-latest` 를 그대로 두면 2026-10-19 ~ 11-19 사이에 이미지가 26.04 로 바뀐다.
- **옮겨 간 뒤 CI 가 실패하면 그때의 이미지 버전을 로그의 `Image:` · `Version:` 줄에서 읽어 위의 값과 견준다.** 버전이 `20260927.149.1` 이면 그 이미지에서 통과한 기록이 있는 것이다 — 다만 통과한 것은 프로젝트 하나짜리 지금의 검증 명령 세 번과 spike 의 여섯 프로젝트 점검이고, 여섯으로 늘린 `tool/verify.dart` 는 그 이미지에서 잰 적이 없다. 이미지는 매주 새로 나오므로 실제로는 버전이 다를 것이고, 그 버전은 재지 않은 것이다. 어느 쪽이든 `ubuntu-24.04` 를 한 번 지정해 돌려 보면 이미지 탓인지 갈린다.
- STATE.md 의 "그 뒤 CI 가 처음 실패하면 저장소 변경보다 runner 이미지 변경을 먼저 의심한다" 는 이 결과로 약해졌다 — 위의 견주기를 먼저 한다. (STATE.md 의 그 줄은 이 wrap-up 이 고치지 않았다.)
- 이 저장소가 runner 에서 기대는 것은 Flutter SDK 의 Linux x64 바이너리, 그 안의 Dart 가 plugin 을 AOT 로 컴파일하는 단계, pub.dev 에서 받는 패키지다. 시스템의 컴파일러나 패키지 관리자에는 기대지 않는다 — 소스를 읽은 것이 아니라 workflow 의 step 을 본 것이다.

### 5. runner 의 환경

```text
Flutter 3.47.5 • channel stable
Dart SDK version: 3.13.4 (stable) on "linux_x64"
Dart 3.13.4 on linux (4 cores)
GITHUB_ACTIONS=true CI=true DASH__SUPPRESS_ANALYTICS=true
첫 실행 전 상태 폴더: 없음 (/home/runner/.dartServer)
```

- `DASH__SUPPRESS_ANALYTICS=true` 는 workflow 에서 설정하지 않았다. `dart run` 이 CI 환경임을 알아채고 하위 도구에 넘긴 값이다.
- `~/.dartServer` 가 없는 진짜 처음 상태에서 시작한다.
- 위는 2026-10-11 의 `ubuntu-latest` 다 (006 — 그날의 이미지 이름과 버전은 기록하지 않았다. 2026-10-12 의 `ubuntu-latest` 는 24.04 였다). 2026-10-12 에 본 두 이미지는 모두 코어 4개 · 메모리 약 16GB 였다 (`Platform.numberOfProcessors`, `/proc/meminfo` — 017).
- runner 가 실제로 어느 이미지였는지는 job 로그 첫머리 "Set up job" 의 `Image:` · `Version:` 줄에 있다. 스크립트 안에서는 환경변수 `ImageOS` · `ImageVersion` 으로 읽는다.

### 6. 결과를 로그와 요약에 남기는 방법

- 로그에서 한 줄로 집어낼 수 있게 표시를 붙여 JSON 을 찍는다: `SPIKE006_RESULT {…}` → `gh run view <run id> --log | grep SPIKE006_RESULT`.
- job 이 여럿이면 job 별 시간과 그 한 줄을 한꺼번에 모은다. `sources/017-runner-six-fixtures/collect.py <run id> <출력 파일>` 이 GitHub API 로 job 목록(시작 · 끝 시각, step 별 시각)과 job 별 로그를 읽어 JSON 하나로 쓴다. job 로그는 `gh api --allow-escape-sequences repos/<저장소>/actions/jobs/<job id>/logs` 로 읽는다 — 로그에 색을 입히는 제어 문자가 들어 있어 그 인자가 없으면 `gh` 가 내주지 않는다 (gh 2.102.0).
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

### 7. 실행을 확인하는 명령

```bash
gh run list --workflow <workflow 파일 이름> --limit 5
gh run view <run id> --log
# 실행에 붙은 예고 (runner 이미지가 바뀐다는 알림 등)
gh api repos/<저장소>/check-runs/<job id>/annotations
```

## What to Avoid

- **결과를 보지 않고 `runs-on` 을 `ubuntu-24.04` 로 못박는 것.** 26.04 에서 같은 결과가 나왔다 (018). 24.04 이미지도 언젠가 내려가므로 미룰 뿐이다.
- **이미지가 바뀐 뒤의 첫 실패를 곧바로 이미지 탓으로 읽는 것, 반대로 "018 이 통과했으니 이미지 탓일 리 없다" 로 읽는 것.** 로그의 이미지 버전을 018 이 잰 값(20260927.149.1)과 견준다. 그 뒤의 버전은 재지 않았다.
- **3번의 시간을 "여섯으로 늘린 `tool/verify.dart` 의 시간" 으로 적는 것.** spike 의 스크립트를 돌린 값이다. 실제 값은 Phase 3 을 끝내기 전에 본다 (03-CONTEXT.md D-09).
- **3번 표의 "job 전체 (재실행 포함)" 칸을 그대로 CI 시간으로 옮기는 것.** 마지막 칸(재실행을 뺀 job)을 쓴다 — 그것도 잰 job 시간에서 재실행 시간을 뺀 셈이다.
- **한 job 안에서 차례 실행과 동시 실행을 이어 돌려 견주는 것.** 뒤의 것은 pub cache 가 채워진 상태가 되어 "처음 받는 경우" 를 보지 못한다. 방식마다 job 을 따로 둔다 (017).
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
- action 버전: `actions/checkout` v7.0.1 (2026-07-20), `subosito/flutter-action` v2.23.0 (2026-03-25). 둘 다 major tag(`v7`, `v2`)가 있다 (006 때 확인한 값이다. 017 · 018 의 실행에서 그 tag 가 어느 버전으로 풀렸는지는 기록하지 않았다). `flutter-action` 의 `cache` 기본값은 `false` 다.
- push 로 도는 workflow 는 올라간 브랜치의 workflow 파일을 쓴다. 기본 브랜치에 파일이 없어도 돈다.
- 작업 브랜치(`gsd/v2.0-package-rework`)는 이미 원격에 올라가 있다 (02-CONTEXT.md D-08, D-09). `.planning/` 이 공개된다는 뜻이므로 결과 파일에는 로컬 절대 경로를 남기지 않는다.
- **017 · 018 은 push 한 번으로 쟀다** (2026-10-12, 소유자 확인 뒤 작업 브랜치를 `ead9573` → `0d20c10` 으로). 그 push 가 실행 둘을 시작했다 — 임시 workflow (run `38216842742`, job 15개: 여섯 프로젝트 점검 12 + 26.04 의 검증 3) 와 원래의 `verify` (run `38216842619`). 16개 job 이 모두 `success` 였고 가장 오래 걸린 job 이 5분 8초다 (처음 실행과 재실행을 함께 돈 값). 임시 workflow 는 결과를 기록한 뒤 저장소에서 지웠다 (사본: `sources/017-runner-six-fixtures/spike-017-018-runner.yml`).
- 3번의 표본은 칸마다 셋, 방식마다 여섯이다. 한꺼번에 띄운 실행이 **드물게** 깨지는지는 처음 여섯 번 · 재실행 여섯 번으로는 알 수 없다 (008 에서 빈 상태 폴더를 **함께** 쓴 실패는 40번 중 1번이었다. 여기서는 상태 폴더를 따로 줬다).
- 3번의 로컬 연습(`results/local-seq.json`, `local-par.json`)은 스크립트가 도는지를 본 것이다. 차례 실행 92.7초는 다른 스크립트의 컴파일을 같은 기계에서 겹쳐 돌린 값이라 쓰지 않는다 — 로컬의 시간은 014 의 값(66초 / 23초)을 쓴다. 재실행을 한꺼번에 띄운 6.4초도 그 연습의 한 번이다.
- 확인하지 않은 것: macOS / Windows runner 와 arm64 runner (CI 는 Linux x64 만 쓴다), SDK 캐시(`cache: true`)를 켰을 때의 시간 (Flutter 설치 시간을 줄여 주지만 넣을지는 계획 때 정한다), GitHub 나 pub.dev 에 장애가 있을 때의 모습 (spike 002 의 로컬 재현으로 갈음), spike 007(루트의 `example/**` 제외, 규칙 검사의 실행 형태)과 008(상태 폴더를 함께 쓸 때, 깨진 뒤의 회복)의 실험을 runner 에서 한 것, spike 010 ~ 013 · 015 · 016 · 019 의 실험을 runner 에서 한 것 (로컬 macOS 에서 쟀다 — runner 에서 돈 것은 017 의 여섯 조합이다), **여섯으로 늘린 실제 `tool/verify.dart` 의 job 시간과 그것을 26.04 에서 돌린 것**, 26.04 이미지의 뒤 버전, runner 에서 규칙 검사만의 시간, 작업 폴더 하나를 돌려 쓰는 방식(014 의 B)을 runner 에서, `base_riverpod` 의 재실행이 긴 까닭, Flutter 설치가 26.04 에서 빨랐던 까닭, 다음 SDK 에서의 job (베타는 로컬에서만 돌렸고 CI 의 SDK 는 `.fvmrc` 를 따른다).

## Origin

Synthesized from spikes: 006, 017, 018 (전용 상태 폴더와 규칙 검사 시간에 관한 두 줄은 007, 008 의 결과를, `.fvmrc` 를 올릴 때의 주의는 016 의 결과를 덧붙인 것이다. 014 의 추정은 017 의 실측으로 바꿨다)
Source files available in: sources/006-github-runner-cold-plugin/, sources/014-multi-fixture-plugin-cost/, sources/017-runner-six-fixtures/ (`runner_probe.dart`, `collect.py`, `spike-017-018-runner.yml`), sources/018-runner-next-image/
원본 결과: `.planning/spikes/006-github-runner-cold-plugin/results/run-38136362920.json`, `run-38136362920-attempt2.json`, `.planning/spikes/017-runner-six-fixtures/results/run-38216842742.json` (임시 workflow 의 job 15개 — 018 의 것은 이름에 `ubuntu-26.04` 가 든 아홉), `.planning/spikes/018-runner-next-image/results/run-38216842619-verify.json` (같은 push 의 `verify`)
