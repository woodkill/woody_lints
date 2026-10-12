---
spike: 018
idea: verify-harness-tool-behavior
name: runner-next-image
type: standard
validates: "Given GitHub 이 `ubuntu-latest` 를 2026-10-19 부터 Ubuntu 26.04 로 옮긴다고 예고했을 때, when 지금의 검증 명령과 연습용 프로젝트 여섯을 `ubuntu-26.04` 를 직접 지정해 돌리면, then `ubuntu-24.04` 와 진단이 한 줄도 다르지 않고 plugin 준비가 실패하지 않는다"
verdict: VALIDATED
related: [006, 017]
tags: [github-actions, ci, runner-image, ubuntu-26, forward-compat]
---

# Spike 018: 다음 runner 이미지 (Ubuntu 26.04)

## What This Validates

GitHub 자동 점검이 빌려 쓰는 컴퓨터의 운영체제가 바뀐다. `verify` 의 2026-10-12 실행에 예고가 붙어 있었다 — "The ubuntu-latest label will migrate to Ubuntu 26 beginning October 19, 2026". spike 006 과 지금까지의 `verify` 실행은 모두 Ubuntu 24.04 에서 돌았다.

- **Given** GitHub 이 `ubuntu-latest` 를 2026-10-19 부터 Ubuntu 26.04 로 옮긴다고 예고했을 때
- **When** 지금의 검증 명령(`dart run tool/verify.dart`)과 spike 017 의 연습용 프로젝트 여섯을 `ubuntu-26.04` 를 직접 지정해 돌리면
- **Then** `ubuntu-24.04` 와 진단이 한 줄도 다르지 않고 plugin 준비가 실패하지 않는다

결과의 처리 기준은 02-CONTEXT.md D-15 다. 통과하면 아무것도 바꾸지 않는다. 통과하지 못하면 "정답지 비교로 판정한다" 는 그대로이고 workflow 의 `runs-on` 을 `ubuntu-24.04` 로 못박는 한 줄이 Phase 3 의 계획에 들어간다 — 값이나 세부가 달라지는 결과이므로 기록하고 계속한다.

## Research

- **예고의 원문** (actions/runner-images#14748, 2026-09-17 에 열림, 2026-10-12 읽음): `ubuntu-latest` 는 2026-10-19 부터 몇 주에 걸쳐 Ubuntu 26.04 로 옮겨 가고 2026-11-19 까지 끝난다. 영향받을 수 있는 것으로 "Ubuntu 24.04 에 고유한 소프트웨어, 패키지 버전, 시스템 라이브러리, 컴파일러, 미리 빌드된 바이너리" 를 든다. 문제가 생기면 `ubuntu-24.04` 를 지정해 되돌리고, 미리 시험하려면 `ubuntu-26.04` 를 지정하라고 안내한다.
- 같은 글의 비교표: 운영체제 24.04.5 → 26.04.1, kernel 6.17 → 7.0, systemd 255 → 259.
- **이 저장소가 기대는 것:** Flutter SDK 의 Linux x64 바이너리(`subosito/flutter-action@v2` 가 받는다), 그 안의 Dart 가 plugin 을 AOT 로 컴파일하는 단계(`plugin.aot`), pub.dev 에서 받는 패키지. 시스템의 컴파일러나 패키지 관리자에는 기대지 않는다 — 소스를 읽은 것이 아니라 workflow 의 step 을 본 것이다.

| 방식 | 장점 | 단점 | 채택 |
|---|---|---|---|
| `ubuntu-26.04` 를 직접 지정해 지금 돌려 본다 | 옮겨 가기 전에 결과를 안다. Phase 3 도중에 점검이 깨졌을 때 "컴퓨터가 바뀌어서" 를 미리 지울 수 있다 | GitHub 에 올려야 한다 (spike 017 과 같은 한 번) | **채택** |
| 옮겨 간 뒤 실패하면 그때 본다 | 할 일이 없다 | Phase 3 의 변경과 이미지 변경이 한 실행에 섞인다 | 쓰지 않음 |
| 결과를 보지 않고 `ubuntu-24.04` 로 못박는다 | 확실하다 | 24.04 이미지도 언젠가 내려간다. 미룰 뿐이다 | 쓰지 않음 |

**Chosen approach:** spike 017 의 임시 workflow 에 job 을 둘 더한다 — (1) `verify.yml` 과 같은 step 을 `runs-on: ubuntu-26.04` 로 세 번, (2) 017 의 여섯 프로젝트 점검을 `ubuntu-24.04` 와 `ubuntu-26.04` 에서 나란히. 같은 push 에서 원래의 `verify` (`ubuntu-latest`) 도 한 번 돌므로 그것이 24.04 쪽의 기준이 된다.

## How to Run

```bash
# runner: .github/workflows/spike-017-018-runner.yml 이 브랜치 push 때 돌린다
gh run list --workflow spike-017-018-runner.yml --limit 3
```

스크립트와 임시 workflow 의 사본은 spike 017 의 폴더에 있다 (`../017-runner-six-fixtures/runner_probe.dart`, `spike-017-018-runner.yml`).

## What to Expect

- `verify · ubuntu-26.04` job 셋이 `점검 통과 (4개 중 4개)` 로 끝난다.
- `six · ubuntu-26.04 · …` job 여섯의 확인 24건이 모두 성립하고, 시간이 `ubuntu-24.04` 의 같은 방식과 비슷하다.
- 로그 첫머리의 `/etc/os-release` 와 glibc 버전이 두 이미지에서 다르게 찍힌다 (이미지가 실제로 달랐다는 대조).

## Investigation Trail

### 1. 올리기와 실행 (2026-10-12)

spike 017 과 같은 한 번의 push 다 (`ead9573` → `0d20c10`, 소유자 확인 뒤). 임시 workflow 의 run `38216842742` 에 이 spike 의 job 이 아홉 개 들어 있다 — `verify · ubuntu-26.04` 셋, `six · ubuntu-26.04` 여섯. 같은 push 의 원래 `verify` (run `38216842619`) 가 기준이다.

### 2. 이미지가 실제로 달랐는가 (대조)

| | `ubuntu-24.04` | `ubuntu-26.04` |
|---|---|---|
| `/etc/os-release` | Ubuntu 24.04.5 LTS | Ubuntu 26.04.1 LTS |
| glibc (`ldd --version`) | 2.39 | 2.43 |
| 이미지 버전 (`ImageVersion`) | 20261004.327.1 | 20260927.149.1 |
| 코어 / 메모리 | 4 / 약 16GB | 4 / 약 16GB |

- `ubuntu-latest` 는 2026-10-12 에 아직 `ubuntu-24.04` 였다. 같은 push 의 `verify` 로그에 `Image: ubuntu-24.04`, `Version: 20261004.327.1` 이 찍혔다.

### 3. 지금의 검증 명령 (`dart run tool/verify.dart`)

| job | 이미지 | 결과 | Flutter 설치 | 검증 step | job 전체 |
|---|---|---|---|---|---|
| `verify · ubuntu-26.04 · 1` | 26.04 | `점검 통과 (4개 중 4개)` | 27초 | 37초 | 70초 |
| `verify · ubuntu-26.04 · 2` | 26.04 | `점검 통과 (4개 중 4개)` | 27초 | 38초 | 70초 |
| `verify · ubuntu-26.04 · 3` | 26.04 | `점검 통과 (4개 중 4개)` | 24초 | 29초 | 58초 |
| `verify` (기준) | `ubuntu-latest` = 24.04 | `점검 통과 (4개 중 4개)` | 46초 | 36초 | 88초 |

- 화면의 버전 세 줄이 네 job 모두 같다 — `SDK  Flutter 3.47.5 / Dart 3.13.4`, `기반 세트  flutter_lints 6.0.0 / lints 6.1.0`, `plugin  riverpod_lint 3.1.9`.
- 검증 명령은 정답지와 한 줄이라도 다르면 실패한다. 통과했다는 것은 26.04 에서 `example/` 의 진단 16줄과 `exit 2` 가 정답지와 같았다는 뜻이다.

### 4. 연습용 프로젝트 여섯 (spike 017 의 스크립트)

- `ubuntu-26.04` 의 job 여섯(차례 셋, 한꺼번에 셋) × 확인 24건 = **144건이 모두 성립했다.** 줄 수와 종료 코드가 `ubuntu-24.04` 의 job 여섯과 같다 — 16 / 16 / 18 / 15 / 21 / 13 줄, `exit` 2 / 2 / 2 / 2 / 2 / 0.
- plugin 을 쓰는 넷은 plugin 폴더가 하나씩이고 실패 머리말이 없다. plugin 쪽에서 풀린 버전도 같다 (`riverpod_lint` 3.1.9 / `analyzer` 14.5.0 / `analysis_server_plugin` 0.3.24).

| 방식 | `ubuntu-24.04` 처음 실행 | `ubuntu-26.04` 처음 실행 |
|---|---|---|
| 차례로 | 145.8 / 186.4 / 166.1초 (평균 166) | 191.2 / 165.5 / 178.4초 (평균 178) |
| 한꺼번에 | 68.8 / 93.6 / 79.5초 (평균 81) | 94.9 / 94.0 / 78.4초 (평균 89) |

- 26.04 의 평균이 7 ~ 10% 길지만 같은 이미지 안의 표본 차이(20 ~ 30%)보다 작다. 표본 셋으로는 "느려졌다" 고 말할 수 없다.
- Flutter 설치(`subosito/flutter-action@v2`)는 26.04 에서 24 ~ 39초, 24.04 에서 46 ~ 64초였다. 까닭은 가르지 않았다.

## Results

**Verdict: VALIDATED** — `ubuntu-26.04` 에서 지금의 검증 명령 세 번과 연습용 프로젝트 여섯의 점검 여섯 번이 모두 `ubuntu-24.04` 와 같은 결과를 냈다.

1. **workflow 는 바꾸지 않는다.** `runs-on: ubuntu-latest` 를 그대로 두면 2026-10-19 ~ 11-19 사이에 이미지가 26.04 로 바뀌고, 그 이미지에서 검증은 지금과 같은 진단 · 같은 버전으로 통과한다.
2. plugin 준비(받기 · AOT 컴파일)는 glibc 2.43 의 이미지에서 실패하지 않았다 — 아홉 job, plugin 을 쓰는 실행 51번 (검증 3 + 여섯 프로젝트 점검 6 job × 넷 × 처음 · 재실행).
3. 시간은 표본 차이 안에서 같다.

Phase 3 의 계획이 가져갈 것:

1. `ubuntu-24.04` 로 못박는 줄은 넣지 않는다.
2. STATE.md 의 "그 뒤 CI 가 처음 실패하면 저장소 변경보다 runner 이미지 변경을 먼저 의심한다" 는 이 결과로 약해진다 — 이미지 20260927.149.1 에서는 통과했다. 옮겨 간 뒤 실패하면 **그때의 이미지 버전**을 로그의 `Image` · `Version` 줄에서 읽어 이 값과 견준다. 버전이 같으면 이미지 탓이 아니다.

확인하지 않은 것:

- 26.04 이미지의 뒤 버전. 이미지는 매주 새로 나온다.
- Phase 3 이 바꿀 `tool/verify.dart` (여섯으로 늘린 것)를 26.04 에서 — 여기서 돌린 것은 지금의 검증 명령과 spike 의 스크립트다.
- arm64 runner, macOS / Windows runner.
- Flutter 설치가 26.04 에서 빨랐던 까닭.

원본: `../017-runner-six-fixtures/results/run-38216842742.json` (임시 workflow 의 job 15개 — 이 spike 의 것은 이름에 `ubuntu-26.04` 가 든 아홉), `results/run-38216842619-verify.json` (같은 push 의 `verify`).
