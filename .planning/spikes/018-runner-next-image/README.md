---
spike: 018
idea: verify-harness-tool-behavior
name: runner-next-image
type: standard
validates: "Given GitHub 이 `ubuntu-latest` 를 2026-10-19 부터 Ubuntu 26.04 로 옮긴다고 예고했을 때, when 지금의 검증 명령과 연습용 프로젝트 여섯을 `ubuntu-26.04` 를 직접 지정해 돌리면, then `ubuntu-24.04` 와 진단이 한 줄도 다르지 않고 plugin 준비가 실패하지 않는다"
verdict: PENDING
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

PENDING — runner 의 결과를 받은 뒤 적는다.

## Results

PENDING
