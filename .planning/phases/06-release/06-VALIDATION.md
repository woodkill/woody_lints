---
phase: "6"
slug: "release"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-15"
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> 출처: `06-RESEARCH.md` § "Validation Architecture", § 1 (REL-03 검사 (i) 의 자리 · tag 이름의 출처), § 2 (D-06 다섯 입력), § 3 (smoke 스크립트), § 5 (lock 여섯), § 6 (손질 다섯 · IN-12 · IN-14), § 8 (릴리스 명령 · 비공개 점검). 시간 값은 조사 단계의 값이다 (`verify.dart` 는 plugin 준비된 상태 약 22초, smoke 는 약 45초 · 네트워크). `[3/10]` 의 (i), `--tag` 인자, `tool/smoke.dart` 는 아직 없으므로 아래 명령 가운데 그것들을 가리키는 것은 이 phase 가 만든 뒤에야 돈다. 아래 명령은 조사 문서의 초안이며, 정확한 명령은 계획(`06-NN-PLAN.md`)의 `<automated>` 가 정한다.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 없음 — Dart 테스트 패키지를 두지 않는다 (02-CONTEXT.md D-11). 검증 명령 `tool/verify.dart` (단계 10개 — `[3/10]` 에 (i) 버전 일치 검사가 더해진다), 새 `tool/smoke.dart`, 루트 `fvm dart analyze`, `fvm dart format --output=none --set-exit-if-changed tool`, 비공개 점검 (1) ~ (3), `example/README.md` 의 지워 보기 기록(M92 ~), git · gh 의 읽기 명령이 하네스다 |
| **Config file** | `tool/verify.dart` 의 상수, `.fvmrc`, 정답지 다섯 (`example/expected_diagnostics.txt` 등) |
| **Quick run command** | `fvm dart analyze && fvm dart run tool/verify.dart` |
| **Full suite command** | 위 둘 + `fvm dart format --output=none --set-exit-if-changed tool` + (릴리스 커밋 뒤) `fvm dart run tool/verify.dart --tag v2.0.0` + 비공개 점검 (1) ~ (3) + `fvm dart run tool/smoke.dart <ref>` (네트워크) |
| **Estimated runtime** | ~25 seconds (루트 분석 약 1초 + `verify.dart` plugin 준비된 상태 약 22초). smoke 는 약 45초 (GitHub 에서 받기 · `flutter create` · 두 주소 분석) |

---

## Sampling Rate

- **After every task commit:** `fvm dart analyze` + `fvm dart format --output=none --set-exit-if-changed tool` + `fvm dart run tool/verify.dart` (종료 코드 0, `점검 통과 (10개 중 10개)`) + 비공개 점검 (1) · (2)
- **After every plan wave:** 위 + 그 wave 의 지워 보기(M 번호)를 복제본에서 실제로 만들어 돌리고 되돌림 (`git status --porcelain` 빈 출력). 릴리스 커밋 wave 는 `--tag v2.0.0` 10/10 과 lock 여섯 · `pubspec.yaml` 의 `git diff --stat`
- **Before `/gsd-verify-work`:** 브랜치 push 뒤 GitHub `verify` 성공, 예행 smoke 통과, tag push 뒤 tag 실행 성공 (로그의 tag 모드 줄), `smoke.dart v2.0.0` 통과, `ls-remote` 증거, PR 실행 · 병합 · `workflow_dispatch` 실행 성공, push 범위 전체 비공개 점검 0줄
- **Max feedback latency:** 30 seconds (로컬 `verify` 재실행). smoke 는 네트워크라 wave 단위로만 돌린다

---

## Per-Task Verification Map

계획(`06-01-PLAN.md` ~ `06-07-PLAN.md`, 2026-10-15)이 확정한 task 마다 한 행이다. Automated Command 는 각 plan 의 `<automated>` 를 요약한 것이고 정확한 명령은 plan 이 정한다.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 06-01-T1 | 06-01 | 1 | REL-03 | T-06-01 · T-06-02 · T-06-03 · T-06-25 | workflow 는 7행 주석만 — trigger · permission · action 버전 그대로 | 실행 (작업 트리 — 파일을 바꾸지 않는 입력만) + grep | workflow 7행 = 새 주석 글자 그대로 · 7행을 뺀 나머지 md5 · 줄 수 == `79f27e5` · `  push:` `  pull_request:` `  workflow_dispatch:` 그대로 · `branches:`/`tags:` 키 0 (R2-Q2); 평소 `fvm dart run tool/verify.dart` rc 0 · `점검 통과 (10개 중 10개)` · stderr `버전 일치 검사: 평소`; `--tag v2.0.0` rc 1 · `[3/10]` 만 · (i) 블록 둘(`-dev` 꼬리 · `미출시`) · stderr `(--tag)`; `--tag 2.0.0` 꼴 블록 하나; `GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v2.0.0` → tag 모드 `(GITHUB_REF_NAME)`; `GITHUB_REF_TYPE=branch` → 평소; 인자 우선; `--tag` 값 없음 · `--bogus` → 64 | ✅ | ✅ green — 복제본 `d2aaf7c` rc 0 (213초); 실패 방향 (가) 꼬리 뗀 값으로 견줌 → rc 1 (`-dev` 꼬리 블록 단언) |
| 06-01-T2 | 06-01 | 1 | (IN-12 · IN-14 · 05-UAT 5) | T-06-04 | N/A | 복제본 전체 실행 + 함수 단위 하네스 | `lib/base.yaml` 의 `include:` 값을 다음 줄에 → 복제본 전체 실행 rc 0 · 10/10 (M97 의 고친 뒤); `lib/riverpod.yaml` 의 `  riverpod_lint: ` 줄 바로 뒤에(글자로 자리 — 파일은 5줄) `"zz_quoted_plugin": ^0.1.0` 을 끼운 M78 입력 함수 단위 `passed=false` · 그 글자 2줄 · `YAML 에만: zz_quoted_plugin`; `keyLikePattern` · `/ 255 ` · `main 도 받지 않아` · `example/README.md` 의 255 행 · `(판이 같은지는 재지 않았다)` grep | ✅ | ✅ green — 복제본 `971a6f2` rc 0 (79초) |
| 06-01-T3 | 06-01 | 1 | REL-03 | T-06-01 · T-06-04 | 복제본에서만 깨뜨리고 되돌림 | 지워 보기 (복제본) + 함수 단위 하네스 + grep | M92 ~ M97 행 여섯 · 소절 제목 · 실측 줄 · 각주 · 116행 (i) 구절 · 64 · 70 행 grep; 작업 트리 `--tag 2.0.0` rc 1 · 꼴 블록; 새 복제본에서 CHANGELOG 날짜만 바꾼 `--tag v2.0.0` 전체 실행 rc 1 · `[3/10]` · `-dev` 블록 하나 · `점검 실패 (10개 중 1개)` (M93); 릴리스 상태의 새 복제본에서 하네스 — `v2.0.0` · tag 없음 `passed=true`, M92 블록 둘, M96 꼴 블록 하나, M94 tag · 평소 블록, 날짜 자리 `미출시` · `TBD` · `2026-1-5` · `2026-10-15 - 추가` 블록, `# Changelog` 머리 줄 `passed=true` (D-05 · D-06 — `미출시` 글자만 거부 · ` - ` 를 모두 나눔 · 첫 줄만 읽음 구현이 걸린다); 평소 10/10 | ✅ | ✅ green — 복제본 `b0ff2d2` rc 0 (132초) |
| 06-02-T1 | 06-02 | 1 | (D-14 · 05-UAT 2 · 4 · D-11) | T-06-05 | N/A | grep + `[3/10]` | README `두 번 적으면 YAML 이 받지 않는다` 3줄 · 측정 문장 · `3.47.2` · `2026-08-19` · 355행 출처 구절 · 381행 새 줄, 옛 구절 0, 펜스 줄 수 · 다른 패키지 `.yaml` 주소 수 · 마커 수 불변, numstat 지운 3 · 더한 9 ~ 12, `fvm dart run tool/verify.dart` 10/10 | ✅ | ✅ green — 복제본 `c9a3225` rc 0 (23초) |
| 06-02-T2 | 06-02 | 1 | (D-11 · D-12) | T-06-06 | N/A | grep | `## 릴리스 절차`; `^## ` 줄 수 = base(이 task 커밋의 부모, 커밋 전이면 HEAD — 5줄: 절 넷 + 106행 펜스 안 예시) + 1; 새 절이 base 의 마지막 127행 뒤 · 빈 줄 하나 다음; 번호 항목 10 이상, `fvm dart pub get` · `pub upgrade` · `tool/verify.dart --tag vX.Y.Z` · `tool/smoke.dart` · `ls-remote --tags origin` · `gh pr merge` · `--merge` · `squash` · `--update` · `직전 확인` 2 이상 · `-dev` · `미출시` · `69` · tag 모드 줄 · `resolved-ref` · `같은 커밋`; 82행 현재형; 1 ~ 81 · 83 ~ 127행 md5 == base | ✅ | ✅ green — 복제본 `f95d482` rc 0 (1초) |
| 06-03-T1 | 06-03 | 1 | REL-04 | T-06-07 · T-06-08 · T-06-09 · T-06-10 · T-06-26 | 새 `PUB_CACHE` · 새 analyzer 상태 폴더 · 저장소 밖 임시 폴더만 쓴다; 하위 명령은 고정 SDK 의 `bin/flutter` · `Platform.resolvedExecutable` 로만 | 실행 (네트워크) | 분석 · 포맷, import 둘, 하위 프로세스에 `fvm` 없음, 상수 · 플래그 · 위반 두 줄 grep; 사용법 넷 → 64; `fvm dart run tool/smoke.dart 2336ba0e3e193e70b2c328c77594b3173b53defc` rc 0 · 첫 줄 `SDK Flutter <.fvmrc> / Dart …` · `기대 커밋:` · `resolved-ref 2336ba0e…` · `source git` · 두 주소 각각 위반 두 줄 · `riverpod_lint 3.x.y` · `smoke 통과 (…)` · `임시 폴더를 지웠다` · 경로 꼴 0; 저장소 안 `app` · `pub-cache` 없음 | ✅ | ✅ green — 복제본 `0a53fd5` rc 0 (44초, GitHub 에서 받기) |
| 06-03-T2 | 06-03 | 1 | REL-04 | T-06-08 · T-06-09 · T-06-26 | 같음 | 실패 방향 (네트워크) | `no-such-ref-06-03` → 69 (느린 단계 전); annotated tag `v1.3.0` (객체 ≠ 커밋) → rc 1 · `기대 커밋: 90a2736…` · `resolved-ref 90a2736…` · `smoke 실패 (ref v1.3.0 → 90a2736…)` · 사유 정확히 2줄 (`recommended:` 둘, alias 0) · plugin 위반 1줄 — tag 경로를 tag push 전에; `gsd/v2.0-package-rework` → rc 1 · `resolved-ref 2336ba0e… 가 기대 커밋 <로컬 sha> 과 다르다` 사유 하나 · plugin 위반 2줄 | ✅ | ✅ green — executor 실행 rc 0 (`0a53fd5` 뒤); 지금 적힌 그대로 rc 1 (상태 고정 — 원격 작업 브랜치가 `2336ba0` → `ad09d6e`), 그 sha 만 바꾼 판 rc 0 (68초); 실패 방향 (나) `^{commit}` 없이 → rc 1 (`기대 커밋: 90a2736…` 단언) |
| 06-04-T1 | 06-04 | 2 | REL-02 | T-06-12 | lock 여섯은 `fvm dart pub get` 으로만; orchestrator 상태 파일은 stage · commit 하지 않음 | 실행 + diff | `version: 2.0.0` · `# lib/base.yaml 이 …` · pubspec numstat 2/2, CHANGELOG 1행 날짜 제목 · 1/1, `VERSIONING.md` 67행 `` - `2.0.0` (<같은 날짜>, tag `v2.0.0`) — … `` · 69행 `그래서 **2.0.0** 으로 냈다.` (grep -x) · 70 · 126행 · `## 릴리스 절차` 그대로 · numstat 2/2 (R2-Q1), `.planning/` 밖에서 바뀐 파일 9, lock 여섯 각 1/1 · `version: "2.0.0"` 1줄, 연습용 `pubspec.yaml` 여섯 불변; 평소 · `--tag v2.0.0` 둘 다 rc 0 · 10/10 · 모드 줄; README `ref: v2.0.0` 2줄 | ✅ | ✅ green — 복제본 `704bf56` rc 0 (47초) |
| 06-04-T2 | 06-04 | 2 | (04 D-07 · 05 D-20 · D-21) | T-06-11 · T-06-13 | push gate (첫 `<automated>`) 가 push 전에 0 일 때만, `git push origin gsd/v2.0-package-rework` 한 줄 | grep (push 전, fail-closed) + gh (push 뒤) | (1) push gate: 브랜치 · fast-forward · `.planning/` 밖 트리 청결 · 범위에 orchestrator 상태 파일 없음 · `git diff -U0 2336ba0…HEAD` rc 0 · 더해진 줄 전부(06 밖 `.planning` 포함)에서 점검 (1) 0줄 · (2) `LEAK?` 0 (제외에 `lib/_probe_extra\.yaml$` · `lib/smoke_violations\.dart$`) · (3) 0줄 (정규식 원문 글자만 지우고); (2) push 뒤: origin == HEAD · head 둘(`main` `90a2736`) · tag `v1.3.0` 하나 · PR 0; HEAD 의 run `completed` · `success` · 로그 `점검 통과 (10개 중 10개)` · `[3/10] … 통과` · `버전 일치 검사: 평소` | ✅ | ✅ green — 첫째(push gate) 지금 본 작업 폴더 rc 0 (범위 `2336ba0..HEAD` 전체); 둘째는 executor 실행 rc 0 (2026-10-15 06:13Z), 지금 상태 고정 rc 1 (origin ≠ HEAD — 뒤 기록 커밋) |
| 06-04-T3 | 06-04 | 2 | REL-04 (D-07 · D-14) | T-06-14 · T-06-27 | 같음 (새 cache · 상태 폴더); 저장소 밖 측정은 고정 SDK 의 dart 로 | 실행 (네트워크) | HEAD == origin 머리 · 릴리스 상태 · `git ls-remote` 성공 · 원격에 `v2.0.0` 없음; 저장소 루트 `fvm flutter --version --machine` 의 `frameworkVersion` == `.fvmrc` · `<flutterRoot>/bin/cache/dart-sdk/bin/dart --version` == `dartSdkVersion`; `--tag v2.0.0` rc 0 · 10/10; `smoke.dart <sha> --keep` rc 0 · 첫 줄 `SDK Flutter <.fvmrc>` · `resolved-ref <sha>` · 두 주소 각각 두 줄 · `smoke 통과 (ref <sha> → <sha>, `; 남긴 폴더에서 `base.yaml` + 템플릿 `analyzer: exclude:` + 「프로젝트 전체」 블록 → 고정 SDK 의 dart 로 `analyze --format=json` rc 2 · 머리말 0 · plugin 폴더 1 · `provider_parameters` · `prefer_single_quotes` 있음 · `missing_provider_scope` 0; 폴더 삭제 | ✅ | ✅ green — executor 실행 rc 0 (2회차, 2026-10-15 08:08 ~ 08:10Z — 1회차는 네트워크 정지로 무효, 06-04-SUMMARY Issues); 지금 상태 고정 rc 1 (origin ≠ HEAD) |
| 06-05-T1 | 06-05 | 3 | REL-02 | T-06-15 | 예행 통과 커밋에만 tag | git (로컬) + gh (읽기) | 06-04-SUMMARY 의 `예행 통과 커밋` == `origin/gsd/v2.0-package-rework` · HEAD 의 조상 · `.planning/` 밖 diff 0 · 릴리스 상태; `git ls-remote` 성공 · 원격에 `refs/tags/v2.0.0` 없음 (실패는 닫힌다); `git cat-file -t v2.0.0` = `tag` · `rev-parse 'v2.0.0^{commit}'` = sha · tag 의 `pubspec.yaml` `version: 2.0.0` · CHANGELOG 날짜 제목 · `tag -n99` 두 단락; 그 커밋의 run success; `--tag v2.0.0` rc 0 · 10/10 | ✅ | ✅ green — executor 실행 rc 0 (2026-10-15 08:17Z); 지금 상태 고정 rc 1 (원격 작업 브랜치가 tag 커밋 뒤로 옮겨 감) |
| 06-05-T2 | 06-05 | 3 | REL-02 (D-01 5 · D-09 (1) · D-10) | T-06-16 · T-06-28 | `gate="blocking-human"` — 자동 승인 없음 | checkpoint:decision (사람) | 확인 요청 다섯 가지(올릴 것 · 명령 · 되돌릴 수 없음 · 점검 결과 · README 따라 하기 여섯 단계 — 저장소 루트에서 찾은 고정 SDK 의 `bin/flutter` · dart 로, 저장소 밖 `fvm` 은 전역 SDK) · 손으로 한 단계와 `tool/smoke.dart` 단계의 대조 표 · 응답(`tag` / `readme` / `script` / `hold`) · 시각이 SUMMARY 에 | — | ✅ 사람 — 소유자 `tag` (2026-10-16T03:15:24Z); README 손 따라 하기는 orchestrator 가 대신 돌리고 소유자가 화면을 봄 — 막힌 자리 없음 (06-05-SUMMARY) |
| 06-05-T3 | 06-05 | 3 | REL-02 · REL-03 · REL-04 | T-06-17 · T-06-18 | `git push origin v2.0.0` 한 줄; 올린 tag 는 옮기지 않음 | git · gh (원격 읽기) + 실행 (네트워크) | `ls-remote --tags` 4줄 · `<sha>\trefs/tags/v2.0.0^{}` · `v1.3.0^{}`; `--heads` 둘 · 작업 브랜치 = sha; tag 의 pubspec · CHANGELOG; 릴리스 커밋의 push 실행 가운데 브랜치 실행이 아닌 것 `success` · 로그 `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` · `점검 통과 (10개 중 10개)` · `[3/10] … 통과`; `smoke.dart v2.0.0` rc 0 · `기대 커밋: <sha>` · `resolved-ref <sha>` · 두 주소 각각 두 줄 · `smoke 통과 (ref v2.0.0 → <sha>, ` | ✅ | ✅ green — executor 실행 rc 0 (03:20:58Z); 지금 적힌 그대로 rc 1 (`main` · 작업 브랜치 sha 가 06-06 뒤 바뀜), 두 sha 만 바꾼 판 rc 0 (50초, tag smoke 포함) |
| 06-06-T1 | 06-06 | 4 | REL-02 (D-03 (4)) | T-06-21 · T-06-22 | push gate (첫 `<automated>`, 범위 `v2.0.0^{commit}..HEAD`) 가 push 전에 0 일 때만 한 줄 push | grep (push 전, fail-closed) + gh (원격) | (1) push gate: 06-04-T2 의 것과 같은 꼴 — 범위의 더해진 줄 전부에 점검 (1) ~ (3), `git diff` 실패는 닫힘, 상태 파일 없음; (2) origin == HEAD · `v2.0.0` 조상; `main` 으로 열린 PR 하나 · head == HEAD · base `main` · `MERGEABLE`; HEAD 의 `pull_request` run `completed` · `success` · 로그 `점검 통과 (10개 중 10개)` · `[3/10] … 통과` · `버전 일치 검사: 평소`; head 둘 · `main` 아직 `90a2736` | ✅ | ✅ green — 첫째(push gate) 지금 rc 0 (범위 `v2.0.0^{commit}..HEAD` — 아직 올리지 않은 기록 커밋 넷 포함); 둘째는 executor 실행 rc 0 (03:34Z), 지금 상태 고정 rc 1 (PR 병합됨 · origin ≠ HEAD) |
| 06-06-T2 | 06-06 | 4 | REL-02 (D-02) | T-06-20 | `gate="blocking-human"` — 자동 승인 없음 | checkpoint:decision (사람) | 확인 요청 다섯 가지(합칠 것 · 명령과 squash · rebase 를 쓰지 않는 이유 · 되돌릴 수 없음 · 점검 결과 · 합친 뒤에 할 일) · 응답(`merge` / `hold`) · 시각이 SUMMARY 에 | — | ✅ 사람 — 소유자 `merge` (2026-10-16T04:25:06Z) |
| 06-06-T3 | 06-06 | 4 | REL-02 (D-02 · D-03 (6)) | T-06-19 | `gh pr merge <번호> --merge` 만, `main` 을 되감지 않음, 브랜치 유지 | git · gh (원격) + `<human-check>` | `origin/main` ≠ `90a2736` · 부모 둘 · 첫 부모 `90a2736` · `merge-base --is-ancestor v2.0.0 origin/main` · 작업 브랜치도 조상 · `main` 의 pubspec `2.0.0` · CHANGELOG 날짜; 병합된 PR `MERGED` · mergeCommit == `origin/main`; head 둘 · tag 4줄 그대로; `main` push run success; `workflow_dispatch` run (`headBranch` main) success · 로그 `점검 통과 (10개 중 10개)` · `버전 일치 검사: 평소`; `Run workflow` 버튼은 human-check (06-UAT) | ✅ | ✅ green — 지금 본 작업 폴더 rc 0 (12초); `Run workflow` 버튼은 06-UAT |
| 06-07-T1 | 06-07 | 5 | (D-03 · 05-UAT 1 · 2 · 4 · 5 · D-14) | T-06-23 · T-06-24 | N/A | grep + git | 02-UAT 4 · 6 블록 `result: pass` · `reason:` 0 · note 의 06-06 task · event; `total: 9` · `passed: 9` · `skipped: 0`; 02-UAT `closed_in` 2 · 05-UAT `closed_in` 4 (06-05 T2 · 06-04 T3); 적힌 sha 가 Phase 6 범위(`5c141cb..HEAD`)에서 제목 머리로 찾은 06-02 T1 (세 항목) · 06-01 T2 의 앞 7자와 같고 `5c141cb` 의 자손 · `git cat-file -e`; base(이 task 커밋의 부모) 대비 05-UAT 지운 줄 0; 절대 경로 0 | ✅ | ✅ green — 지금 rc 0 |
| 06-07-T2 | 06-07 | 5 | (IN-12 · IN-13 · IN-14 · D-13) | T-06-23 · T-06-24 | N/A | grep + git | DISPOSITION frontmatter IN-12 ~ 14 `disposition: fixed`; 표 세 행 `fixed` · `06-0N-PLAN.md Task N (<sha>) — ` 의 sha 가 Phase 6 범위에서 찾은 06-01 T2 (IN-12 · IN-14) · 06-04 T1 (IN-13) 의 앞 7자 · `5c141cb` 의 자손; `keyLikePattern` · `lib/base.yaml` · `D-13`; `deferred` 는 WR-06 하나(frontmatter · 표); `open: 0` · `total: 30`; base 대비 지운 줄 6; 절대 경로 0 | ✅ | ✅ green — 지금 rc 0 |
| 06-08-T1 | 06-08 | 6 | REL-03 | T-06-29 · T-06-30 · T-06-31 · T-06-SC | `markdown` 은 dev_dependencies 에만 — pub.dev publisher `tools.dart.dev` 를 API 로 재확인; (i) 의 version 은 YAML 값 · (h) 는 원문 전체 · CHANGELOG 는 Markdown 첫 h2 | 실행 (작업 트리 — 파일을 바꾸지 않는 입력만) + grep | 루트 `pub get` · 분석 · 포맷; pubspec 더한 줄만 · 루트 lock `direct dev` 7.3.x · publisher; import 넷 · 새 심볼 · 옛 `## ` 줄 찾기 없음 · (i) 가 줄 단위 reader 를 안 부름 · `version:` 정규식 한 곳; 평소 · `--tag v2.0.0` · 환경변수 10/10 과 모드 줄; `--tag v2.0.1` 블록 둘 · 안내 2; lock 여섯 불변 | ✅ | ⬜ pending |
| 06-08-T2 | 06-08 | 6 | REL-03 | T-06-29 · T-06-30 · T-06-32 | 복제본에서만 변형 · 되돌림(toplevel 단언), 기록에 경로 없음 | 지워 보기 (복제본, 고치기 전 판 대조) + 함수 단위 하네스 + 전체 실행 세 경로 + grep | 새 소절 · M98 ~ M106 아홉 행 · 621 · 70 · 117행 구절 · 절대 경로 0; 상태 A(ATX 1 · 3 · 4칸 · setext `---` · `===` · BOM · 인용 · 목록 · `# Changelog` · `**2.0.0**` · raw `<h2>` · 회귀 M92 · M93 꼴 · M95 · M96 — 전 · 후) · B(CR-01 전체 실행 세 경로 · 홑따옴표 하네스) · C(HTML 주석 전체 실행 세 경로 · 펜스 둘); 되돌림; 작업 트리 평소 10/10 | ✅ | ⬜ pending |
| 06-09-T1 | 06-09 | 6 | REL-04 | T-06-35 | include 오류 코드 둘로 좁힘, 두 주소 각각 | 오프라인 하네스 (judge) + grep | 상수 · 서명 · `runSmoke` 세 줄 · 중복 제거(`analyzeExitCodes.contains(` 한 곳); 하네스 여덟 입력 글자 그대로 (두 주소의 include 사유, 다른 진단 0, fatal 문구) | ✅ | ⬜ pending |
| 06-09-T2 | 06-09 | 6 | REL-04 | T-06-33 · T-06-34 · T-06-36 | 단계별 제한 · SIGKILL · finally · SIGINT 130 · 경로는 `--keep` 때만 | 오프라인 하네스 (runProcess · cleanupWork) + SIGINT 끝에서 끝까지 (`flutter create` 중, 네트워크 전) | `sleep 7331` 2초에 끊김 · 프로세스 없음; `echo` 정상; cleanupWork 둘(경로 유무); SIGINT 실행 rc 130 · `woody_smoke_*` 0 · 출력에 경로 없음 · 자식 없음; `Process.run(` 한 곳 | ✅ | ⬜ pending |
| 06-09-T3 | 06-09 | 6 | REL-04 | T-06-33 · T-06-36 | 전체 smoke 는 한 번, 바깥 제한 18분 | 실행 (네트워크) | `smoke.dart v2.0.0` rc 0 · 첫 줄 SDK · `기대 커밋` = `resolved-ref` = `rev-parse` · 두 주소 위반 두 줄씩 · `판정:` 둘 · include 글자 0 · `smoke 통과` · `임시 폴더를 지웠다` · 폴더 0 · 경로 없음 | ✅ | ⬜ pending |
| 06-10-T1 | 06-10 | 7 | REL-03 · REL-04 | T-06-38 | 기록의 sha 는 범위 `01419f9..HEAD` 에서 제목 머리로 찾은 커밋 | grep + git | frontmatter fixed 7 · open 0 · total 7; 표 일곱 행의 plan · task · sha 발견별 일치 · `cat-file -e` · `01419f9` 자손; 재료 글자; 지운 줄 15; 제목 · recorded · 형식 설명 불변; 저장소 파일 불변 | ✅ | ⬜ pending |
| 06-10-T2 | 06-10 | 7 | REL-03 · REL-04 (D-21 · G6-Q3) | T-06-37 · T-06-39 | push gate (첫 `<automated>`) 0 일 때만 한 줄 push; workflow 는 고치지 않음 | grep (push 전, fail-closed) + gh (push 뒤) | (1) gate: 브랜치 · `origin/main` 5ee5a12 · fast-forward · 트리 청결 · 상태 파일 없음 · 더해진 줄의 점검 (1) ~ (3) 0; (2) origin == HEAD · 처리 기록 커밋 포함 · push 실행 success 로그 세 줄 · PR 하나 head == HEAD `MERGEABLE` · `pull_request` 실행 success 로그 세 줄 · head 둘 · tag 4줄 · pubspec · CHANGELOG · VERSIONING 불변 | ✅ | ⬜ pending |
| 06-11-T1 | 06-11 | 8 | REL-03 · REL-04 (G6-Q3) | T-06-41 | `gate="blocking-human"` — 자동 승인 없음 | checkpoint:decision (사람) | 확인 요청 여섯 가지 · 응답(`merge` / `hold`) · 시각이 SUMMARY 에 | — | ⬜ pending |
| 06-11-T2 | 06-11 | 8 | REL-03 · REL-04 (D-02) | T-06-40 · T-06-42 | `gh pr merge <번호> --merge` 만, `main` 되감지 않음, 브랜치 · tag 유지 | git · gh (원격) | `origin/main` ≠ 5ee5a12 · 부모 둘 · 첫 부모 5ee5a12 · 둘째 = 작업 브랜치 머리 · 고침 커밋 셋 · 작업 브랜치 · `v2.0.0` 조상 · `main` 의 pubspec 2.0.0 + markdown · CHANGELOG 1행 · 고침 글자; PR MERGED · mergeCommit; head 둘 · tag 4줄; `main` push 실행 success 로그 두 줄 | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `tool/verify.dart` — `[3/10]` (i) 버전 일치 검사, `main` 의 `--tag` 인자와 CI 환경변수 읽기, stderr 모드 줄, IN-12 고친 판, IN-14 주석
- [x] `tool/smoke.dart` — 예행(D-07) 전에 있어야 한다
- [x] `example/README.md` 의 새 소절 — M92 ~ 의 지워 보기 기록
- 프레임워크 설치: 없음

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| README 를 사람이 그대로 따라 한다 (`flutter create` 빈 프로젝트) | REL-04 (D-09 (1), D-10, 05-UAT 1번) | "따라 할 수 있다" 는 스크립트로 가를 수 없다. 스크립트는 README 단계를 옮겨 적은 것이라 README 가 바뀌어도 스스로 알아채지 못한다 | 예행 때 한 번 손으로 따라 하고, 막힌 자리와 결과를 SUMMARY 에 적는다. 막히면 README 를 고친 커밋으로 예행을 다시 한다 |
| `base.yaml` 만 받는 프로젝트에 「프로젝트 전체」 의 `plugins:` 블록을 붙이면 plugin 이 켜지는가 | (D-14) | 예행 때 한 번 재는 항목 | 결과대로 README 「프로젝트 전체」 에 한 문장을 단다 |
| tag push 직전 확인 | REL-02 (D-01 5번) | 되돌릴 수 없는 원격 작업 (one-way) | 로컬 `--tag v2.0.0` 10/10 · 예행 통과 · 비공개 점검 0줄을 보인 뒤 소유자의 승인을 받는다 |
| `main` 병합 직전 확인 | REL-02 (D-02) | `ref: main` 프로젝트 5개에 닿는 원격 작업 (one-way) | tag smoke · `ls-remote` · PR 실행 성공을 보인 뒤 소유자의 승인을 받는다 |
| Actions → verify 화면의 `Run workflow` 버튼 | (02-UAT 6번, D-03) | GitHub 웹 화면의 버튼은 gh 로 볼 수 없다 | 병합 뒤 소유자가 화면에서 버튼을 확인한다 (실행 자체는 `gh workflow run` 으로도 만든다) |

결과 (2026-10-16 감사 때): README 따라 하기는 소유자가 "Claude 가 대신 따라 하고 화면을 보인다" 를 골라 orchestrator 가 고정 SDK 로 여섯 단계를 돌렸고 소유자가 화면을 보았다 — 막힌 자리 없음, 작은 점 둘(넣는 자리에 따른 `sort_pub_dependencies` info, 「설치」 블록의 `dev_dependencies:` 머리 줄)은 나중에 문서만 (06-05-SUMMARY). D-14 는 06-04 Task 3 의 `<automated>` 가 재어 README 문장과 같았다. tag push · `main` 병합 직전 확인은 소유자가 각각 `tag` · `merge` 로 답했다. `Run workflow` 버튼은 아직 — 06-UAT 에서 본다.

---

## 감사 기록 (2026-10-16, validate-phase)

- 방법: 각 task 의 `<verify>` 안 `<automated>` 를 계획 파일에서 글자 그대로 뽑아(python `-I`, 바이트 수가 executor 보고와 같음) 돌렸다. 커밋이 있는 task 는 `git clone --local` 복제본을 그 task 커밋으로 `checkout --detach` 하고 루트 `fvm dart pub get --no-example` 뒤 `bash -x` 로; 원격 상태를 보는 task 는 본 작업 폴더에서. 두 쪽을 같은 시각에 돌리지 않았다 (한 스크립트 안에서 차례로, 2026-10-16 04:45 ~ 05:03Z).
- 복제본 7개 (06-01 T1 · T2 · T3, 06-02 T1 · T2, 06-03 T1, 06-04 T1): 적힌 그대로 모두 rc 0.
- 본 작업 폴더 5개 (06-04 T2 첫째 · 06-06 T1 첫째 — push gate 둘, 06-06 T3, 06-07 T1 · T2): 모두 rc 0. push gate 둘은 지금 범위(아직 올리지 않은 `.planning/` 기록 커밋 넷 포함)에서 비공개 점검 (1) ~ (3) 0.
- 상태 고정 6개 (06-03 T2, 06-04 T2 둘째, 06-04 T3, 06-05 T1, 06-05 T3, 06-06 T1 둘째): 적힌 그대로 rc 1 — 모두 뒤 plan 이 원격을 옮긴 자리(origin ≠ HEAD, `main` 의 sha, 원격 작업 브랜치 머리)에서 걸렸고 executor 의 그 시점 실행은 rc 0 이었다. 옮겨 간 sha 만 바꾼 판 둘(06-03 T2 · 06-05 T3)은 rc 0 — 실패 방향 셋 · tag smoke 가 지금도 같은 판정을 낸다.
- 실패 방향 (그럴듯하게 틀린 구현, 복제본에서만): (가) `checkVersionAgreement` 의 tag 모드가 `pubspec.yaml` 원문 대신 꼬리 뗀 값으로 견줌 (`text` → `release`, 한 줄) → 06-01 T1 의 `<automated>` rc 1 (`-dev` 꼬리 블록 단언); (나) `tool/smoke.dart` 가 `'<ref>^{commit}'` 대신 `<ref>` 로 기대 커밋을 구함 (한 줄) → `v1.3.0` 실행의 동작 부분 rc 1 (`기대 커밋: 90a2736…` 단언). 두 판 모두 분석 경고 없이 돌았다.
- 남은 것: smoke 임시 폴더 0, 본 작업 폴더는 orchestrator 상태 파일 넷만.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 30s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** validated 2026-10-16 (validate-phase 감사 — 위 「감사 기록」)

## Validation Audit 2026-10-16

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
