---
spike: 017
idea: preset-split-include-behavior
name: runner-six-fixtures
type: standard
validates: "Given 캐시 없는 GitHub Linux runner 에 나눈 구조의 복사본과 03-CONTEXT.md D-03 의 연습용 프로젝트 여섯이 있을 때, when 차례로 한 번 · 한꺼번에 한 번 돌리면, then 진단이 로컬과 같고 차례 실행이 시간 제한 10분 안에 끝나며 한꺼번에 띄운 실행의 시간과 실패 여부가 기록된다"
verdict: PENDING
related: [006, 008, 014, 018]
tags: [github-actions, ci, timing, fixture-layout, concurrency]
---

# Spike 017: GitHub runner 에서의 연습용 프로젝트 여섯

## What This Validates

spike 006 (runner 에서 프로젝트 하나의 첫 분석 약 43초) 과 014 (로컬에서 여섯이 차례로 66초, 한꺼번에 23초) 가 맞물리는 자리다. Phase 3 이 끝나면 자동 점검이 연습용 프로젝트 하나가 아니라 여섯을 돈다. 그 시간은 지금까지 셈한 값(약 4분 20 ~ 30초)뿐이고, 한꺼번에 띄운 값은 추정도 없다.

- **Given** 캐시 없는 GitHub Linux runner 에 나눈 구조의 복사본과 D-03 의 연습용 프로젝트 여섯이 있을 때
- **When** 차례로 한 번, 한꺼번에 한 번 돌리면
- **Then** 진단이 로컬과 같고, 차례 실행이 시간 제한 10분 안에 끝나며, 한꺼번에 띄운 실행의 시간과 실패 여부가 기록된다

결과의 처리 기준은 03-CONTEXT.md D-07 과 같다 — 값이 어느 쪽이든 기록하고 계속한다. Phase 3 의 계획이 `tool/verify.dart` 를 차례로 짤지 한꺼번에 띄울지, `timeout-minutes` 를 얼마로 둘지를 이 값으로 정한다.

## Research

- **spike 014 (로컬, 프로세서 10개):** 차례로 처음 66초 · 재실행 20 ~ 21초, 한꺼번에 처음 23초. 한꺼번에 띄운 20건이 모두 예상과 같았다. 이때 pub cache 는 **채워진 상태**였다.
- **spike 006 (runner, 코어 4개):** 프로젝트 하나의 첫 분석 약 43초, 재실행 약 8초. 실제 `verify` job 은 1분 54초 ~ 2분이다 (Flutter 설치 약 60초).
- **spike 008:** 빈 상태 폴더를 여러 실행이 **함께** 쓰면 드물게 깨진다. 상태 폴더를 따로 주면 문제가 없었다.
- **처음 보는 조건:** runner 의 job 은 새 가상 머신이라 pub cache 에 plugin 쪽 패키지(`riverpod_lint`, `analyzer` 등)가 없다. 한꺼번에 띄우면 plugin 을 쓰는 프로젝트 넷이 **같은 패키지를 같은 pub cache 에 동시에 처음 받는다.** 로컬의 동시 실행은 이 경우를 지나지 않았다.

| 방식 | 도구 | 장점 | 단점 | 채택 |
|---|---|---|---|---|
| 작업 브랜치를 올리고 임시 workflow 로 잰다 | `git push` + 임시 workflow | spike 006 의 선례 그대로다. Phase 3 을 짓기 전에 값이 나온다 | GitHub 에 올려야 한다 (소유자 확인) | **채택** |
| Phase 3 을 끝낼 때 처음 본다 | 03-CONTEXT.md D-09 | 올리기가 한 번 줄어든다 | 차례 / 동시의 설계가 추정 위에 선다 | 쓰지 않음 |
| 로컬에서 코어 수를 줄여 흉내 낸다 | `taskset` 류 | 올리지 않는다 | macOS 에 같은 도구가 없고 빈 pub cache 를 흉내 내지 못한다 | 쓰지 않음 |

**Chosen approach:** 방식(차례 `seq` / 한꺼번에 `par`)마다 job 을 따로 둔다. 한 job 안에서 둘을 이어 돌리면 뒤의 것은 pub cache 가 채워진 상태가 되어 "동시에 처음 받는" 경우를 보지 못한다. job 마다 표본 셋, 이미지 둘(`ubuntu-24.04`, `ubuntu-26.04` — 뒤의 것은 spike 018 의 질문이다)이다.

## How to Run

```bash
# 로컬 연습 (작업 폴더는 저장소 밖에 둔다)
fvm dart run .planning/spikes/017-runner-six-fixtures/runner_probe.dart <작업 폴더> seq
fvm dart run .planning/spikes/017-runner-six-fixtures/runner_probe.dart <작업 폴더> par

# runner: .github/workflows/spike-017-018-runner.yml 이 브랜치 push 때 돌린다
gh run list --workflow spike-017-018-runner.yml --limit 3
```

임시 workflow 의 내용은 이 폴더의 `spike-017-018-runner.yml` 에 참고용으로 남긴다 (`.github/` 밖이라 돌지 않는다).

## What to Expect

- 방식마다 처음 실행과 재실행의 벽시계 시간, 프로젝트별 시간.
- 프로젝트 여섯의 진단이 예상과 같은지 (옛 주소 · 묶음 16줄 `exit 2`, 기본만 18줄 `exit 2`, 끄는 설정 15줄 `exit 2`, 기본 + Riverpod 21줄 `exit 2`, 기본 + codegen 13줄 `exit 0`).
- plugin 을 쓰는 넷은 그 실행의 상태 폴더에 plugin 폴더가 하나, 쓰지 않는 둘은 0개.
- 로그의 `SPIKE017_RESULT {…}` 한 줄이 그 job 의 결과다.

## Investigation Trail

### 1. 로컬 연습 (2026-10-12, Dart 3.13.4, macOS, 프로세서 10개)

스크립트가 도는지 보려고 방식마다 한 번 돌렸다. 두 방식 모두 확인 24건이 성립했다 (`results/local-seq.json`, `results/local-par.json`).

| 방식 | 처음 실행 | 재실행 |
|---|---|---|
| 차례로 | 92.7초 | 23.1초 |
| 한꺼번에 | 24.5초 | 6.4초 |

- 차례 실행의 92.7초는 014 의 66초보다 길다. 이 실행 도중에 다른 스크립트(spike 019)의 컴파일을 같은 기계에서 겹쳐 돌렸다 — 그 무렵의 두 프로젝트가 24초씩 걸렸다. **로컬의 시간은 014 의 값을 쓰고, 이 표는 스크립트가 도는지를 본 것으로만 읽는다.**
- 재실행을 한꺼번에 띄우면 6.4초다 (014 는 재지 않은 칸이다).

## Results

PENDING — runner 의 결과를 받은 뒤 적는다.
