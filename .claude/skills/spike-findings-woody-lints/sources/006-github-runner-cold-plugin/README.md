---
spike: 006
idea: verify-harness-tool-behavior
name: github-runner-cold-plugin
type: standard
validates: "Given 캐시가 하나도 없는 GitHub Linux runner, when 연습용 프로젝트에서 `dart analyze --format=json` 을 돌리면, then plugin 진단이 로컬과 똑같이 나오고 첫 실행 시간이 측정된다"
verdict: VALIDATED
related: [001, 002, 003, 004]
tags: [github-actions, ci, cold-start, analyzer-plugin, riverpod_lint, timing]
---

# Spike 006: GitHub runner 의 cold 실행

## What This Validates

Given 캐시가 하나도 없는 GitHub Linux runner (새 가상 머신, `~/.dartServer` 없음, pub cache 비어 있음),
when `.fvmrc` 로 Flutter 를 설치하고 연습용 프로젝트에서 `dart analyze --format=json` 을 돌리면,
then plugin 진단이 로컬과 똑같이 나오고, 첫 실행에 걸리는 시간이 측정된다.

02-CONTEXT.md D-15 의 멈춤 조건("GitHub runner 의 cold 실행에서 plugin 진단이 빠진다")에 해당하는지를 판정하는 spike 다. workflow 전체를 GitHub 에서 돌려 본 적이 없었다 (STACK.md 미검증 항목).

## Research

- `subosito/flutter-action@v2` (v2.23.0, 2026-03-25): `flutter-version-file` 에 `.fvmrc` 를 줄 수 있다 (`action.yaml` 의 입력 설명: "The pubspec.yaml or FVM config file"). `cache` 의 기본값은 `false` 다.
- `actions/checkout@v7` (v7.0.1, 2026-07-20). 두 action 모두 major tag(`v7`, `v2`)가 있다 (GitHub API 로 확인, 2026-10-11).
- `dart` 는 CI 환경이면(`CI` 나 `GITHUB_ACTIONS` 환경변수가 있으면) 사용 통계를 스스로 끄고 `DASH__SUPPRESS_ANALYTICS=true` 를 하위 도구에 넘긴다 (`pkg/dartdev/lib/src/unified_analytics.dart` 의 `_isRunningOnBot`, tag 3.13.4). spike 001 에서 본 종료 코드 255 가 runner 에서는 나지 않을 것으로 본다 — 이 spike 에서 센다.
- push 로 도는 workflow 는 올라간 브랜치의 workflow 파일을 쓴다. 기본 브랜치(`main`)에 파일이 없어도 된다. 수동 실행 버튼(`workflow_dispatch`)은 기본 브랜치에 파일이 있어야 보이므로 이 spike 에서는 쓰지 않는다 (D-06).

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 작업 브랜치를 그대로 올린다 | `git push origin gsd/v2.0-package-rework` | D-08 의 결정 그대로. 이후 Phase 2 의 CI 도 같은 브랜치에서 돈다 | `.planning/` 이 공개된다 (소유자가 D-08 에서 받아들임) | **채택** |
| spike 파일만 담은 별도 브랜치를 올린다 | orphan 브랜치 | 공개 범위가 작다 | D-08 이 고르지 않은 안. 로컬과 원격 이력이 갈린다 | 쓰지 않음 |

**Chosen approach:** 작업 브랜치를 올리고, job 다섯 개(= 새 가상 머신 다섯 대)가 같은 점검을 돌린다. cold 표본을 한 번의 push 로 여러 개 얻으려는 것이다.

## How to Run

```bash
# 로컬 연습 (상태 폴더를 꼭 준다. 주지 않으면 GitHub Actions 밖에서는 실행을 거부한다)
fvm dart run .planning/spikes/006-github-runner-cold-plugin/ci_probe.dart /tmp/spike006-state

# runner: .github/workflows/spike-006-cold-plugin.yml 이 브랜치 push 때 돌린다
gh run list --workflow spike-006-cold-plugin.yml --limit 5
gh run view <run id> --log | grep SPIKE006_RESULT
```

`ci_probe.dart` 가 job 하나에서 하는 일:

| 실행 | 무엇 | 방식 |
|---|---|---|
| A1 | 기본 fixture(spike 001) 의 진짜 첫 실행 — 상태 폴더도 pub cache 도 비어 있다 | 기본 (`dart analyze --format=json`) |
| A2 | 같은 상태로 재실행 (warm) | `--suppress-analytics` |
| C1~C3 | 상태 폴더만 비운 cold 세 번 | 기본 |
| B1 | 규칙 15개 fixture(spike 003) 의 첫 실행 | `--suppress-analytics` |

실행마다 `expected_001.txt` / `expected_003.txt` (정답지 형식: `exit N` + `경로:줄  강도  규칙`)와 견줘 빠진 줄과 남는 줄을 찍는다. 하나라도 다르면 job 이 실패한다.

## What to Expect

- job 다섯 개가 모두 초록이고, 각 job 의 로그에 "기대와 같은 실행: 6/6", "종료 코드 255: 6번 중 0번" 이 찍힌다.
- 로그의 `SPIKE006_RESULT {…}` 한 줄에 실행별 시간과 결과가 JSON 으로 들어 있다.

## Investigation Trail

### 1. 로컬 연습 (Dart 3.13.4, macOS arm64, 2026-10-11)

runner 에 올리기 전에 같은 스크립트를 격리된 상태 폴더로 돌렸다.

```text
통과  A1 첫 실행 (기본 방식): exit 2 (기대 2), 16.9s, 진단 4건, 빠진 줄 0, 남는 줄 0
통과  A2 재실행 (--suppress-analytics): exit 2 (기대 2), 3.8s, 진단 4건, 빠진 줄 0, 남는 줄 0
통과  C1 상태 폴더만 비움 (기본 방식): exit 2 (기대 2), 16.9s, 진단 4건, 빠진 줄 0, 남는 줄 0
통과  C2 상태 폴더만 비움 (기본 방식): exit 2 (기대 2), 16.9s, 진단 4건, 빠진 줄 0, 남는 줄 0
통과  C3 상태 폴더만 비움 (기본 방식): exit 2 (기대 2), 17.0s, 진단 4건, 빠진 줄 0, 남는 줄 0
통과  B1 15개 fixture 첫 실행 (--suppress-analytics): exit 3 (기대 3), 13.5s, 진단 15건, 빠진 줄 0, 남는 줄 0
riverpod_lint 실제 버전: 3.1.9
```

로컬의 pub cache 는 채워져 있었으므로 A1 은 "상태 폴더만 비운 cold"다. runner 의 A1 은 plugin 이 기대는 패키지를 내려받는 시간이 더해진다.

### 2. 첫 push 와 실행 (2026-10-11)

- 소유자 확인을 받은 뒤 `git push origin gsd/v2.0-package-rework` 를 실행했다 (D-09 의 첫 push). 원격 브랜치가 로컬과 같은 커밋(`9450731`)을 가리키고 `origin/main` 은 `90a2736` 그대로다.
- push 가 workflow 를 바로 시작했다 (run `38136362920`). 기본 브랜치에 workflow 파일이 없어도 push 로는 돈다.
- job 다섯 개가 모두 성공했다. 표본을 늘리려고 같은 run 을 한 번 다시 돌렸고(attempt 2) 다시 다섯 개 모두 성공했다. **새 가상 머신 10대, 분석 60번.**

### 3. runner 의 환경

```text
Flutter 3.47.5 • channel stable
Dart SDK version: 3.13.4 (stable) on "linux_x64"
Dart 3.13.4 on linux (4 cores)
GITHUB_ACTIONS=true CI=true DASH__SUPPRESS_ANALYTICS=true
첫 실행 전 상태 폴더: 없음 (/home/runner/.dartServer)
```

- `subosito/flutter-action@v2` 가 `flutter-version-file: .fvmrc` 만으로 로컬과 같은 Flutter 3.47.5 / Dart 3.13.4 를 설치했다. 캐시 없이 약 66초 걸렸다.
- `DASH__SUPPRESS_ANALYTICS=true` 가 찍혔다. `dart run` 이 CI 환경임을 알아채고 하위 도구에 넘긴 값이다. workflow 에서 따로 설정하지 않았다.
- `~/.dartServer` 가 없는 진짜 cold 상태에서 시작했다.

### 4. 결과 (`results/run-38136362920.json`, `results/run-38136362920-attempt2.json`)

| 실행 | 10대의 시간 (최소 ~ 최대, 중앙값) | 기대와 같았는가 |
|---|---|---|
| A1 기본 fixture 의 진짜 첫 실행 (기본 방식) | 27.5 ~ 53.0초, 43초 | 10/10 |
| A2 재실행 | 5.5 ~ 10.6초, 8초 | 10/10 |
| C1~C3 상태 폴더만 비운 cold (기본 방식) | 27.0 ~ 52.6초 | 30/30 |
| B1 규칙 15개 fixture 의 첫 실행 | 23.8 ~ 44.0초, 37초 | 10/10 |
| `dart pub get` (기본 fixture, 빈 pub cache) | 1.6 ~ 3.8초 | — |

- **60번 모두 기대 진단 파일과 한 줄도 다르지 않았다.** 빠진 줄 0, 남는 줄 0, 종료 코드도 기대대로(2 / 3). plugin 진단은 cold 에서도 빠지지 않는다.
- 규칙 15개 fixture 에서 15개가 모두 로컬과 같은 강도로 나왔다 (spike 003 의 표가 Linux 에서도 같다).
- **종료 코드 255 는 60번 중 0번**이었다. 그중 40번은 사용 통계를 끄는 인자를 주지 않은 cold 실행이다. 로컬에서는 같은 조건이 24번 중 7번 죽었다 (spike 001). runner 에서는 `dart` 가 스스로 끈다.
- stderr 는 60번 모두 비어 있었다.
- 실제로 풀린 plugin 은 10대 모두 `riverpod_lint` 3.1.9 였다 (`~/.dartServer/.plugin_manager/*/pubspec.lock` 에서 읽음).
- "진짜 첫 실행"(A1)과 "상태 폴더만 비운 cold"(C1~C3)의 시간이 거의 같다. plugin 이 기대는 패키지를 내려받는 시간은 작고, 대부분이 plugin 컴파일이다. 로컬(약 17초)보다 2.5배쯤 느리다.

### 5. job 하나의 시간

이 spike 의 job 은 분석을 여섯 번 해서 3분 14초 ~ 5분 37초 걸렸다. 실제 CI job 은 분석을 한두 번 하므로:

| 단계 | 시간 |
|---|---|
| checkout | 1초 |
| Flutter 설치 (`flutter-action`, 캐시 없음) | 약 66초 |
| `dart pub get` | 2~4초 |
| `dart analyze` 첫 실행 | 약 43초 (최대 53초) |
| 합계 | **약 2분** |

## Results

**Verdict: VALIDATED** — GitHub Linux runner 의 cold 실행에서 plugin 진단이 빠짐없이 나온다. D-15 의 멈춤 조건에 해당하지 않는다.

- 새 가상 머신 10대에서 60번 분석해 60번 모두 로컬의 기대 진단과 같았다.
- 첫 실행은 약 43초(27~53초), 재실행은 약 8초다.
- `.fvmrc` 하나로 로컬과 CI 의 SDK 가 맞는다.
- runner 에서는 사용 통계가 자동으로 꺼져 종료 코드 255 가 나지 않았다.

Phase 2 의 CI workflow 가 가져갈 것:

1. `actions/checkout@v7` + `subosito/flutter-action@v2` (`channel: stable`, `flutter-version-file: .fvmrc`) 로 충분하다. workflow 에 Flutter 버전 숫자를 적지 않는다.
2. `timeout-minutes` 는 **10** 이면 넉넉하다 (정상 약 2분). pub 서버에 닿지 못해도 plugin 준비는 약 30초 뒤 실패로 끝나므로(spike 002) 멈춰 있는 경우만 막으면 된다.
3. `~/.dartServer` 는 캐시하지 않는다. 캐시 없이도 43초이고, 캐시하면 plugin 준비 실패가 가려질 수 있다 (PITFALLS.md Pitfall 12). SDK 캐시(`cache: true`)는 약 66초를 줄여 주지만 넣을지는 계획 때 정한다.
4. 검증 명령이 `--suppress-analytics` 를 항상 붙이면 로컬과 CI 가 같은 방식으로 돈다 (CI 에서는 없어도 되지만 맞춰 둔다).
5. push 로 도는 workflow 는 기본 브랜치에 파일이 없어도 된다. `workflow_dispatch` 만 `main` 에 들어간 뒤에 쓸 수 있다 (D-06).

정리:

- 임시 workflow(`.github/workflows/spike-006-cold-plugin.yml`)는 결과를 기록한 뒤 지웠다. 내용은 이 폴더의 `spike-006-cold-plugin.yml` 에 참고용으로 남겼다 (`.github/` 밖이라 돌지 않는다).

확인하지 않은 것:

- macOS / Windows runner. CI 는 Linux 만 쓴다.
- SDK 캐시를 켰을 때의 시간.
- GitHub 쪽 장애나 pub.dev 장애가 있을 때의 모습 (spike 002 의 로컬 재현으로 갈음).
