---
phase: "3"
slug: "preset-split"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-12"
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> 출처: `03-RESEARCH.md` § "Validation Architecture", § "계획이 정해야 할 것 — 근거와 권고" (권고 6, 9, 10, 11), § "spike 012 가 성공 기준 3 에 거는 조건". 시간 값은 spike 014 의 로컬 실측과 spike 017 의 GitHub runner 실측이다. 정답지 줄 수는 조사 단계의 scratch 복사본 실측(2026-10-12, Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9)이다. `fixtures/` 와 단계 9개는 아직 없으므로 아래 명령 가운데 새 fixture 를 가리키는 것은 이 phase 가 만든 뒤에야 돈다.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 없음 — Dart 테스트 패키지를 두지 않는다 (02-CONTEXT.md D-11). 검증 명령 `tool/verify.dart` 와 정답지가 테스트 하네스다 |
| **Config file** | `example/expected_diagnostics.txt` (바꾸지 않음, 기준 `19ae5ec`), 새 fixture 의 정답지 넷 (이 phase 가 만든다), `.github/workflows/verify.yml` (YAML 은 바꾸지 않음, 기준 `008ea3f`) |
| **Quick run command** | `fvm dart run tool/verify.dart` |
| **Full suite command** | 같은 명령 (단계 전부). CI 는 `dart run tool/verify.dart` |
| **Estimated runtime** | ~20 seconds (로컬 재실행. plugin 을 쓰는 fixture 넷 약 3.5초씩 + 쓰지 않는 둘 약 3초씩, spike 014). plugin 을 처음 준비하는 실행(첫 실행, 하한 상향 직후)은 fixture 마다 더 걸린다. GitHub runner 의 job 은 약 3분 20초 ~ 4분 20초 (spike 017) |

---

## Sampling Rate

- **After every task commit:** `fvm dart run tool/verify.dart` + 커밋 전 린터 `fvm dart analyze` (루트, 약 0.6초)
- **After every plan wave:** 같은 명령 + 그 커밋의 고정 단언 (`git diff --quiet <기준 커밋> -- <경로>`. 기준 커밋은 `03-RESEARCH.md` § "계획이 고정할 기준 커밋" 의 표를 따른다)
- **Before `/gsd-verify-work`:** 로컬 exit 0 · 모든 단계 통과, `example/expected_diagnostics.txt` 가 `19ae5ec` 그대로, GitHub 에서 성공한 `verify` 실행 1회 이상 (D-09), "가장 먼저 할 일" 의 세 입력이 모두 `--update` 에서 exit 1 로 재현됨, `example/README.md` 의 지워 보기 기록
- **Max feedback latency:** 30 seconds (로컬 재실행)

---

## Per-Task Verification Map

Task ID 는 `03-NN-TM` (plan NN 의 Task M) 이고 계획(`03-NN-PLAN.md`, 2026-10-12 확정)에서 채웠다. Automated Command 는 각 task 의 `<automated>` 를 요약한 것이다 — 전문은 plan 파일에 있다. Threat Ref 는 그 plan 의 `<threat_model>` 의 ID 다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-T1 | 03-01 | 1 | (가장 먼저 할 일) | T-03-01 | 망가진 배포 파일의 결과가 정답지로 굳지 않는다 — `[2/4]` 통과 조건이 "exit 0 이고 진단 0건" | integration (변경을 만들고 되돌림) | 세 입력(닫지 않은 따옴표 / `rules:` 오타 / 겹친 규칙 + 없는 진단 코드)을 `perl -pi` 로 하나씩 넣고 `fvm dart run tool/verify.dart --update` → exit 1, `[2/4] … 실패`, `다른 단계가 실패해 정답지를 쓰지 않았다`, 정답지 `git hash-object` 불변; 보통 실행은 `[2/4]` 와 `[4/4]` 실패 · `점검 실패 (4개 중 2개)`; 되돌린 뒤 exit 0. `git diff --quiet 90a2736 -- lib`, `19ae5ec -- example/expected_diagnostics.txt` | ✅ (`tool/verify.dart`) | ⬜ pending |
| 03-01-T2 | 03-01 | 1 | (가장 먼저 할 일) | T-03-02 | README 의 기록에 절대 경로 · 토큰이 없다 | doc + integration | `example/README.md` 의 30행 · 81행 · 158행 새 문구 grep, `| M15 |` ~ `| M17 |` 3행, `실측 (03-01):` 줄, `/Users/` 0건; `fvm dart run tool/verify.dart` exit 0 | ✅ (`example/README.md`) | ⬜ pending |
| 03-02-T1 | 03-02 | 2 | PRESET-04, PRESET-08 | T-03-04, T-03-05, T-03-06 | 조각은 잘라 옮긴다 — 손으로 다시 쓰지 않는다; 규칙 검사가 조각 셋을 모두 본다 | integration + git | `{ sed -n '1,41p' lib/base.yaml; cat lib/codegen.yaml lib/riverpod.yaml; sed -n '42,47p' lib/base.yaml; } \| diff -q - <(git show 90a2736:lib/analysis_options.yaml)`; `wc -l` 47 / 7 / 10; 별칭 · 묶음의 비주석 줄; `fvm dart run tool/verify.dart` → exit 0, `점검 통과 (4개 중 4개)`, `git diff --quiet 19ae5ec -- example/expected_diagnostics.txt`; `riverpod.yaml` 끝의 deprecated 규칙과 `lib/_probe_extra.yaml` 이 `[2/4]` 에서 실패 (되돌림) | ✅ (`lib/analysis_options.yaml` 64행 원본, `tool/verify.dart`) | ⬜ pending |
| 03-02-T2 | 03-02 | 2 | PRESET-06 | T-03-07 | 루트 옵션 파일의 주석에 SDK 에 묶인 이유를 적지 않는다 | integration | `! grep -q 'lib/analysis_options.yaml' analysis_options.yaml`, 비주석 제외 항목 1개(`'example/**'`), `fvm dart analyze` → exit 0 · `No issues found` · `plugins_in_inner_options` 없음; CHANGELOG 불릿 셋 + `올리기 전에` 줄, `###` 셋, 꼬리가 `90a2736` 과 같음 | ✅ (루트 `analysis_options.yaml`) | ⬜ pending |
| 03-03-T1 | 03-03 | 3 | PRESET-01, PRESET-08, VERIFY-05 | T-03-08, T-03-09, T-03-13 | `--update` 는 바뀐 것만 쓰고 한 단계라도 실패하면 쓰지 않는다; fixture 의 lock 이 커밋된다 | integration (대조군) | `fixtures/recommended` · `base_only` 구성 grep (`name` · `path: ../..` · lock 의 `"../.."` · `diff -rq example/lib`), `.gitignore` 의 `!fixtures/*/pubspec.lock` 과 `git check-ignore -v`, 루트 `'fixtures/**'`; `base_only` 정답지 머리 `riverpod_lint 해당 없음`, `exit 2` + 18줄, 생성 파일 4줄, `invalid_annotation_target` 1줄, plugin 0줄; `fvm dart run tool/verify.dart` → exit 0, `점검 통과 (6개 중 6개)`, `[5/6] recommended (묶음)` 통과; `--update` 재실행 → `바뀐 정답지가 없다`, hash 불변; plugin 폴더 1 / 0 | ❌ W0 (`fixtures/recommended/`, `fixtures/base_only/`) | ⬜ pending |
| 03-03-T2 | 03-03 | 3 | PRESET-02, PRESET-03, PRESET-07 | T-03-10, T-03-12 | `[3/9]` 가 `overrides` 의 `version:` 을 조각의 선언과 견준다; 생성 파일 샘플에 plugin 위반이 없다 | integration (대조군) | `base_riverpod` 정답지 `exit 2` + 21줄 (plugin 3줄, 생성 파일 4줄); `base_codegen` `exit 0` + 13줄 (생성 파일 0, `invalid_annotation_target` 0, 머리 `해당 없음`) — **범위: Dart 3.13.4 의 규칙 진단**; `overrides` `exit 2` + 18줄 (끈 줄 여섯 자리 없음, 대조 줄 `lint_line.dart:6` · `plugin_line.dart:13` · `plugin_line.dart:11` · `plugin_file_unprefixed.dart:8` 있음); `fvm dart run tool/verify.dart` → exit 0, `점검 통과 (9개 중 9개)`; `prefer_final_locals: true` 로 바꾼 실행이 `[3/9]` · `[9/9]` 실패 (되돌림); plugin 폴더 1 / 0 / 1 | ❌ W0 (`fixtures/base_riverpod/`, `fixtures/base_codegen/`, `fixtures/overrides/`) | ⬜ pending |
| 03-03-T3 | 03-03 | 3 | PRESET-07, PRESET-08, VERIFY-05 | T-03-09, T-03-12 | 새 fixture 가 헛통과가 아님을 실측으로 기록 | doc + integration (변경을 만들고 되돌림) | M18 (`lib/recommended.yaml` 의 `riverpod.yaml` 줄 제거) → `example` 실패, `recommended` 통과(같은 실행 비교), `overrides` 실패; M19 (`overrides` 의 `version:` 줄 제거) → `[3/9]` · `[9/9]` 실패; `git checkout` 으로 되돌림; README 의 `## 연습용 프로젝트 여섯` 표 6행 · `단계는 아홉 개다` · `| M18 |` `| M19 |`; `git diff --quiet HEAD -- lib fixtures tool`; `fvm dart run tool/verify.dart` exit 0 · 9개 통과 | ✅ (`example/README.md`) | ⬜ pending |
| 03-04-T1 | 03-04 | 4 | PRESET-05 | T-03-17 | plugin 선언은 범위 지정(`^`)이고 하한이 3.1.9 다; 두 선언이 같다 | static + integration | `grep -qxF '  riverpod_lint: ^3.1.9' lib/riverpod.yaml`, `grep -qxF '    version: ^3.1.9' fixtures/overrides/analysis_options.yaml`, `lib` · fixture 옵션 파일에 `^3.1.3` 없음; 이어 붙인 diff 가 10행 한 줄만; `G=$(git log -1 --format=%H -- fixtures/overrides/expected_diagnostics.txt); git diff --quiet "$G" -- <정답지 다섯>` (하한 상향 앞뒤로 정답지 불변), `19ae5ec -- example/expected_diagnostics.txt`; `fvm dart run tool/verify.dart` exit 0 · 9개 통과 · `plugin riverpod_lint 3.N.N`; `--update` → `바뀐 정답지가 없다`; `version: ^3.1.8` 로 바꾼 실행이 `[3/9]` 실패 (되돌림) | ✅ (`lib/riverpod.yaml`, 03-02 가 만듦) | ⬜ pending |
| 03-04-T2 | 03-04 | 4 | (D-09) | T-03-14 | 첫 push 는 소유자 확인 뒤에만 — `checkpoint:decision` gate blocking-human | manual (checkpoint) | 소유자의 `push` 응답 (아래 Manual-Only) | — | ⬜ pending |
| 03-04-T3 | 03-04 | 4 | (D-09), VERIFY-04 | T-03-14, T-03-16, T-03-18 | workflow 가 읽기 권한만 가진다 (`permissions: contents: read`, YAML 은 `008ea3f` 와 같음); push 는 브랜치 이름 하나만 | e2e (GitHub, 읽기 전용 조회) | `git push origin gsd/v2.0-package-rework` 둘; `gh run list --workflow verify.yml --branch gsd/v2.0-package-rework --json …` 에서 하한 상향 커밋(`git log -1 --format=%H -- lib/riverpod.yaml`)과 원격 tip 의 run 이 `completed success`; `gh run view <id> --json jobs` 의 job 시간 < `timeout-minutes × 60`; 첫 run 로그에 `점검 통과 (9개 중 9개)`; workflow 주석에 `연습용 프로젝트 여섯` · `run <id>` · 실측 날짜; python yaml 비교로 설정 불변 (timeout 15 면 예외); `ls-remote --heads` 2줄 · `main` = `90a2736` · tag `v1.3.0` 뿐 · PR 0 | ✅ (`.github/workflows/verify.yml`) | ⬜ pending |

요구사항 ID 는 없지만 같은 방식으로 확인하는 것: 파일 분리 커밋(03-02-T1)은 구조 변경만 한다 — 조각을 원래 줄 순서로 이어 붙이면 `git show 90a2736:lib/analysis_options.yaml` 과 같다 (`03-RESEARCH.md` Pattern 1). `pubspec.yaml` 은 모든 커밋에서 `git diff --quiet 968a5bb -- pubspec.yaml`, `example/lib` 는 `74fafb2`, workflow 는 `008ea3f` (03-04-T3 의 주석 한 줄만 예외). 하한 상향 전 커밋의 해시는 03-04-T1 이 실행 때 SUMMARY 에 적는다 (계획 시점에는 알 수 없다 — 정답지를 마지막으로 바꾼 커밋을 `git log -1 -- <정답지>` 로 읽어 쓴다).

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tool/verify.dart` — 규칙 이름 단계의 통과 조건("exit 0 이고 진단 0건"), 규칙 검사 대상을 조각 셋으로, `stripPlugins` 가 `plugins:` 없는 파일을 받아들이도록, fixture 표 · 단계 9개 · fixture 마다 한 줄 · plugin 없는 fixture 의 `해당 없음` · `--update` 일괄 쓰기
- [ ] `lib/base.yaml`, `lib/riverpod.yaml`, `lib/codegen.yaml`, `lib/recommended.yaml`, 별칭이 된 `lib/analysis_options.yaml` — PRESET-01 ~ 05, 08
- [ ] 루트 `analysis_options.yaml` — `lib/analysis_options.yaml` 제외 삭제, `fixtures/**` 제외 — PRESET-06
- [ ] `fixtures/{recommended,base_only,overrides,base_riverpod,base_codegen}/` 전체 + 정답지 넷 — PRESET-01 ~ 03, 07, 08, VERIFY-05
- [ ] `.gitignore` 의 `!fixtures/*/pubspec.lock`
- [ ] `example/README.md` — 30행 · 81행, 단계 설명, fixture 표, 지워 보기 기록 M15 ~ M19
- [ ] `CHANGELOG.md` 의 `## 2.0.0 - 미출시` 항목
- [ ] Framework install: 없음

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| "가장 먼저 할 일" 의 세 입력에서 `--update` 가 정답지를 쓰지 않는다 — 고치기 전과 뒤의 결과를 기록으로 남긴다 | (가장 먼저 할 일) | 배포 파일을 일부러 망가뜨려 실패를 본 뒤 커밋하지 않고 되돌리는 일이라 상시 도는 검사로 남지 않는다 | 입력마다 `fvm dart run tool/verify.dart --update` 의 종료 코드 · 실패한 단계 · 정답지 변경 여부를 `example/README.md` 의 지워 보기 표에 M15 ~ M17 로 적는다. 끝에 `git status` 로 남은 변경이 없음을 확인한다 |
| 새 fixture 가 헛통과가 아니다 — 묶음에서 Riverpod 조각을 빼면 `example` (과 `overrides`) 이 실패하고 (`recommended` 는 같은 실행의 `example` 결과와 견주므로 통과할 것으로 계획이 예상한다 — 03-03 A-03-2), `overrides` 에서 plugin 의 `version` 줄을 빼면 `[3/9]` 가 실패하고 끈 진단이 되살아난다 | PRESET-07, PRESET-08 | 위와 같다 (03-03-T3) | `lib/recommended.yaml` 의 `riverpod.yaml` include 줄, `fixtures/overrides/analysis_options.yaml` 의 `version:` 줄을 각각 임시로 지우고 같은 명령을 돌려 차이를 M18 · M19 로 기록한 뒤 되돌린다. 결과는 조사 단계의 예측(spike 010 · 012 의 모양)이므로 실제 값으로 적는다 |
| 이 phase 의 첫 push | (D-09) | 공개 저장소에 올리는 일은 되돌릴 수 없어 소유자 확인을 받는다 (03-04-T2 의 `checkpoint:decision`, gate blocking-human — 자동 승인 없음) | 확인 요청에 올릴 커밋 목록, 실행할 명령(브랜치 이름 하나만, `--force` · `--tags` · `--all` 없음), 되돌릴 수 없다는 점, `.planning/` 이 함께 올라간다는 점을 쉬운 말로 적는다. 같은 phase 의 뒤 push (03-04-T3 의 두 번째) 는 묻지 않고 실행한 뒤 보고한다 |
| GitHub 자동 점검의 실제 시간을 소유자에게 다시 알린다 | (D-09) | CONTEXT D-03 의 "약 4분 15초" 는 추정이었고 실측 값이 나오면 그 값으로 알리기로 했다 (CONTEXT `<specifics>`) | 03-04-T3 이 두 run 의 job 시간을 SUMMARY 머리와 최종 보고에 "추정 약 4분 15초 → 실측 N분 M초" 로 적는다 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
