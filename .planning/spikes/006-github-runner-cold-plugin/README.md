---
spike: 006
idea: verify-harness-tool-behavior
name: github-runner-cold-plugin
type: standard
validates: "Given 캐시가 하나도 없는 GitHub Linux runner, when 연습용 프로젝트에서 `dart analyze --format=json` 을 돌리면, then plugin 진단이 로컬과 똑같이 나오고 첫 실행 시간이 측정된다"
verdict: PENDING
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

### 2. GitHub runner

(push 뒤에 채운다.)

## Results

**Verdict: PENDING** — 작업 브랜치의 첫 push 에 소유자 확인이 필요하다 (02-CONTEXT.md D-09).
