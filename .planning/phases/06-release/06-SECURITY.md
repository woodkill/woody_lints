---
phase: "6"
slug: "release"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-16"
---

# Phase 6 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
>
> 출처: `06-01-PLAN.md` ~ `06-11-PLAN.md` 의 STRIDE 등록부 (계획 단계에서 작성됨 — `T-06-01` ~ `T-06-28`, gap 수정 06-08 ~ 06-11 의 `T-06-29` ~ `T-06-42`, plan 마다 둔 `T-06-SC`). ASVS level 1, block on `high`. SUMMARY 의 `## Threat Flags` 는 열한 plan 모두 없다.
> 이 phase 가 바꾼 실행 코드는 로컬 검증 스크립트 `tool/verify.dart` (`[3/10]` 의 (i) · `--tag` · IN-12) 와 새 스크립트 `tool/smoke.dart` 둘이다. 배포 산출물 `lib/*.yaml` 은 바꾸지 않았다. 원격 쓰기가 여섯 있었다 — 작업 브랜치 push 셋(06-04 · 06-06 · 06-10, 실행 뒤 보고 — D-21, 06-10 은 G6-Q3), tag `v2.0.0` push (06-05, 소유자 `tag` 뒤), `main` 병합 둘 (06-06 PR #1 · 06-11 PR #2, 각각 소유자 `merge` 뒤). gap 수정(06-08 ~ 06-11)은 `[3/10]` (i) 의 reader 를 YAML · Markdown 해석기 값으로 바꾸고 (개발용 의존성 `markdown` 추가), `tool/smoke.dart` 에 include 사슬 판정 · 단계별 시간 제한 · `finally` / SIGINT 정리를 더했다 — 받는 쪽 규칙 · 버전은 그대로다.
> 아래 "확인" 은 2026-10-16 phase 실행 뒤(T-06-01 ~ 28 은 HEAD `4841371`, T-06-29 ~ 42 와 T-06-SC 의 06-08 부분은 HEAD `ccf1b8f`) 이 저장소에서 명령을 다시 돌리거나 파일 · 원격을 직접 읽어 얻은 결과다. "복제본 rc 0" 은 `06-VALIDATION.md` 「감사 기록」 두 절의 실행 — task 마다 자기 커밋으로 되돌린 로컬 복제본에서 계획의 `<automated>` 를 적힌 그대로 돌린 결과 — 를 가리킨다.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| 로컬 저장소 → 공개 원격 (GitHub) | 06-04 에서 `2336ba0..704bf56` (35커밋), 06-06 에서 `704bf56..ad09d6e` (2커밋) 가 작업 브랜치에 올라갔다 — 합쳐 37커밋 · 파일 43개 (`.planning/phases/06-release` 18, `05-documentation` 7, `fixtures` 5, `tool` 2, `example` 2, `README.md` · `VERSIONING.md` · `CHANGELOG.md` · `pubspec.yaml` · `STATE` · `ROADMAP` · `REQUIREMENTS` 각 1), 더해진 줄 6,832. 그 위에 tag `v2.0.0` (tag 객체 `753f520` → `704bf56`) 과 `main` 의 병합 커밋 `5ee5a12` (`90a2736` 위에 392커밋) 이어서 06-10 에서 `ad09d6e..75f102f` (18커밋 · 파일 25개 · 더해진 줄 3,201 — `.planning/phases/06-release` 13, `tool` 2, `.claude/skills` 3, `05-documentation` 2, `02-verification-harness` 1, `example` · `pubspec.yaml` · `STATE` · `ROADMAP` 각 1) 가 올라갔고 PR #2 로 `main` 의 병합 커밋 `0038572` (부모 `5ee5a12` · `75f102f`) 가 생겼다. | 파일 내용 · tag 메시지 · PR 본문 · 병합 메시지 (공개) |
| 로컬 → GitHub Actions | push · tag · PR · 병합 · 수동 실행이 `verify` workflow 를 돌린다 — 권한은 `contents: read` 뿐 (`.github/workflows/verify.yml` 14 ~ 15행, 저장소 기본 workflow 권한도 `read`) | 저장소 내용 (읽기) |
| GitHub → 임시 빈 프로젝트 | `tool/smoke.dart` 가 공개 주소에서 커밋 · tag 를 받아 저장소 밖 임시 폴더에서 분석한다 | 이 패키지 · `flutter_riverpod` · plugin (읽기) |
| 사람의 결정 → 실행 | tag push 와 `main` 병합은 소유자의 `tag` · `merge` 뒤에만 — auto-mode 에서도 멈춘다 (`gate="blocking-human"`) | 결정 |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-06-01 | Tampering | (i) 가 `-dev` · `미출시` 인 채로 tag 를 통과시키거나 꼬리를 뗀 값으로 tag 를 견준다 | high | mitigate | tag 모드는 `pubspecVersionText`(원문)와 정확히 견주고 날짜 꼴을 본다. 확인: `if (text != tagVersion)` 1곳; 06-01-T1 복제본(`d2aaf7c`) rc 0 — 지금 상태의 `--tag v2.0.0` 이 블록 둘(`-dev` · `미출시`); 실패 방향 (가) — 그 줄을 `release` 로 바꾼 판은 rc 1 로 잡혔다; 06-01-T3 복제본(`b0ff2d2`) rc 0 — M93 · M95 재현 | closed |
| T-06-02 | Denial of service | 평소 push 에서 (i) 가 거짓 실패해 CI 가 빨개진다 | high | mitigate | 평소 모드 · `GITHUB_REF_TYPE=branch` 를 단언. 확인: 06-01-T1 복제본 rc 0; 실제 실행 넷(브랜치 push `38690710677` · `38845719589`, `pull_request` `38845784725`, `main` push `38850611790`, `workflow_dispatch` `38850984674`)이 모두 `버전 일치 검사: 평소` · 10/10 | closed |
| T-06-03 | Repudiation | CI 로그에서 tag 모드가 돌았는지 가를 수 없다 | medium | mitigate | stderr 모드 줄. 확인: tag 실행 `38844667011` (`headBranch` `v2.0.0`) 로그에 `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` 1줄 — orchestrator 가 `gh run view --log` 로 다시 셈 | closed |
| T-06-04 | Tampering | 지워 보기가 작업 트리를 바꾼 채 남거나 기록에 임시 폴더 경로가 들어간다 | medium | mitigate | 복제본에서만, 하네스는 복제본 밖. 확인: 06-01-T2 · T3 복제본 rc 0 (작업 트리 고정 파일 diff 0 · `build/woody_rule_check` 없음 · `example/README.md` 절대 경로 꼴 0 단언 포함); 지금 `example/README.md` 의 절대 경로 꼴 0 | closed |
| T-06-25 | Tampering | workflow 의 주석 한 줄 변경이 trigger · permission · action 버전을 함께 바꾼다 | high | mitigate | 7행을 뺀 나머지 md5 · 줄 수 == `79f27e5`. 확인: 06-01-T1 복제본 rc 0; 지금 `push:` · `pull_request:` · `workflow_dispatch:` 그대로, `branches:` · `tags:` 키 0, `permissions: contents: read` | closed |
| T-06-05 | Denial of service | README 손질이 `[3/10]` (d′) · (e) · (f) · (g) 를 깨뜨린다 | medium | mitigate | 산문만. 확인: 06-02-T1 복제본(`c9a3225`) rc 0 — 펜스 줄 수 · 다른 패키지 주소 수 · 마커 수 불변, `verify.dart` 10/10; 지금 HEAD 의 `verify.dart` 10/10 | closed |
| T-06-06 | Repudiation | 측정 문장이 추론을 실측처럼 적거나 절차가 재지 않은 필터를 단정한다 | low | mitigate | 측정 문장에 버전 · 날짜 · 조건, 06-04 예행이 다시 잼. 확인: 06-04-T3 의 D-14 측정이 README 문장과 같은 결과 (06-04-SUMMARY); 절차 6번의 필터(`headBranch` 가 tag 이름)는 06-05 의 실제 tag 실행에서 `headBranch` = `v2.0.0` 으로 맞았다 | closed |
| T-06-07 | Spoofing | "GitHub 에서 받았다" 가 거짓 — 평소 pub cache · 준비된 plugin 을 썼다 | high | mitigate | 새 `PUB_CACHE` · 상태 폴더 둘, lock 의 `source git` · `url` · `resolved-ref` 를 찍어 견줌. 확인: `tool/smoke.dart` 에 `PUB_CACHE` · `ANALYZER_STATE_LOCATION_OVERRIDE`; 06-03-T1 복제본(`0a53fd5`) rc 0 — `resolved-ref 2336ba0…` · `source git` · README 의 url 단언 | closed |
| T-06-08 | Tampering | 기반 세트 규칙을 골라 include 가 깨져도 통과하거나 한 주소만 본다 | high | mitigate | `prefer_single_quotes` · `provider_parameters`, 두 주소 각각. 확인: 06-03-T2 의 `v1.3.0` 실행 — 지금 다시 돈 판(작업 브랜치 sha 만 바꿈) rc 0, `recommended` 쪽만 사유 둘 | closed |
| T-06-26 | Spoofing | `^{commit}` 없이 tag 를 벗기지 않거나 하위 명령이 전역 SDK 로 풀린다 | medium | mitigate | `'$ref^{commit}'`, stdout 첫 줄 `SDK Flutter <.fvmrc>`, 하위 프로세스에 `fvm` 없음. 확인: 실패 방향 (나) — `^{commit}` 을 뺀 판은 `v1.3.0` 실행에서 rc 1 (`기대 커밋: 90a2736…` 단언); 06-03-T1 복제본 rc 0 (`'fvm'` 0 · SDK 첫 줄); 실제 `smoke.dart v2.0.0` 이 `기대 커밋` = `resolved-ref` = `704bf56` | closed |
| T-06-09 | Elevation of privilege | `<ref>` 를 통한 인자 주입 | medium | mitigate | `-` 로 시작하는 ref 는 64, `rev-parse --verify --quiet <ref>^{commit}`. 확인: `tool/smoke.dart` 565행 `arg.startsWith('-')`, 540 · 541행 `'--verify'` · `'--quiet'`; 06-03-T1 복제본 rc 0 — `-x` · `--bogus` 가 64 | closed |
| T-06-10 | Information disclosure | 임시 폴더 · 홈 경로가 화면 · SUMMARY · 커밋에 들어간다 | medium | mitigate | 경로를 `<임시 폴더>` 로 가림, `--keep` 때만 마지막 줄. 확인: 06-03-T1 복제본 rc 0 · 06-03-T2 판 rc 0 (세 화면의 경로 꼴 0 단언); 06-01 ~ 06-07 SUMMARY 의 절대 경로 꼴 0 | closed |
| T-06-11 | Information disclosure | push 범위에 비공개 정보가 들어가 공개된다 · 점검이 실패해 0 으로 읽힌다 · 상태 파일이 범위에 든다 | high | mitigate | push gate (fail-closed) 가 push 전에 범위의 더해진 줄 전부를 본다. 확인: 06-04 의 gate rc 0 (06:07:26Z) → push 06:07:30Z; 지금 같은 gate 를 범위 `2336ba0..HEAD` 로 다시 돌려 rc 0; orchestrator 가 공개 범위 `2336ba0..ad09d6e` 를 더 넓게 훑음 — 절대 경로 꼴 0, 이메일 꼴은 Flutter 저장소 주소 하나뿐, 측정 작업 폴더 이름 0, 비공개 사용 프로젝트 **이름** 2줄 (06-CONTEXT · 06-RESEARCH 의 "그 프로젝트의 경로 · 기능 이름을 올리지 않는다" 규칙 문장 — 이름은 허용, origin 에 이미 있던 이름), 상태 파일 0 | closed |
| T-06-27 | Denial of service | 저장소 밖 측정이 전역 SDK 로 풀려 거짓 결론이 난다 | high | mitigate | 저장소 루트의 `fvm flutter --version --machine` 으로 고정 SDK 를 찾아 그 dart 로. 확인: 06-04-T3 의 `<automated>` rc 0 (2회차) — `frameworkVersion` == `.fvmrc`, dart 버전 일치, D-14 측정 exit 2 · plugin 폴더 1 · `provider_parameters` 있음 · `missing_provider_scope` 없음 | closed |
| T-06-12 | Tampering | lock 을 `pub upgrade` 로 받거나 손으로 고친다 | medium | mitigate | `fvm dart pub get` 만, lock 마다 1/1. 확인: 06-04-T1 복제본(`704bf56`) rc 0 — lock 여섯 각 1/1 · `version: "2.0.0"` 1줄, 연습용 `pubspec.yaml` 불변; `git diff --stat 272c0b4 704bf56` = 9 files, 11/11 | closed |
| T-06-13 | Tampering | `main` · tag 를 건드리는 push, 예행과 다른 커밋에 tag 를 달 준비 | high | mitigate | 브랜치 이름 하나의 push. 확인: 06-04 push 출력 `2336ba0..704bf56  gsd/v2.0-package-rework -> gsd/v2.0-package-rework`; 그 뒤 `main` `90a2736` · tag `v1.3.0` 하나 · PR 0 (executor 의 Task 2 둘째 `<automated>` rc 0); 06-04-SUMMARY 의 `예행 통과 커밋: 704bf56…` | closed |
| T-06-14 | Spoofing | 예행이 캐시 · 다른 커밋을 본 것 | medium | mitigate | `resolved-ref == sha`, 새 `PUB_CACHE`. 확인: 예행 2회차 rc 0 · `resolved-ref 704bf56…` (06-04-SUMMARY); 1회차는 네트워크 정지로 무효 처리 — 저장소 문제가 아니었고 결과를 근거로 쓰지 않았다 | closed |
| T-06-15 | Tampering | 예행이 본 커밋과 다른 커밋에 tag 를 단다 | high | mitigate | 4중 점검을 checkpoint 앞에. 확인: `git rev-parse 'v2.0.0^{commit}'` = `704bf56` = 06-04-SUMMARY 의 예행 통과 커밋; `ls-remote` 의 `refs/tags/v2.0.0^{}` = `704bf56`; orchestrator 가 checkpoint 전에 직접 다시 확인 | closed |
| T-06-16 | Repudiation | checkpoint 자동 승인, README 따라 하기 생략 | high | mitigate | `gate="blocking-human"`. 확인: 소유자 `tag` (2026-10-16T03:15:24Z) < push (03:16:07Z); README 따라 하기는 소유자가 "Claude 가 대신 따라 하고 화면을 보인다" 를 골라 orchestrator 가 돌리고 소유자가 화면을 봄 — 생략이 아니라 대신 실행이라고 06-05-SUMMARY 에 그대로 적혀 있다 | closed |
| T-06-28 | Repudiation | 전역 SDK 로 따라 해 SDK 조건을 README 의 막힘으로 오인한다 | medium | mitigate | 고정 SDK 의 두 실행 파일로 따라 하게 안내. 확인: 손 따라 하기가 Flutter 3.47.5 / Dart 3.13.4 의 실행 파일로 돌았다 (화면 첫 줄); 06-05-SUMMARY 에는 경로 대신 `<고정 SDK 의 …>` | closed |
| T-06-17 | Information disclosure | tag push 가 브랜치 · 다른 tag 를 함께 올리거나 SUMMARY 에 경로 | high | mitigate | `git push origin v2.0.0` 한 줄. 확인: push 출력 `* [new tag] v2.0.0 -> v2.0.0`; 그 직후 `--heads` 둘(작업 브랜치 `704bf56` 그대로) · `--tags` 4줄 (06-05-SUMMARY, orchestrator 재확인); tag 메시지 두 단락에 경로 0 | closed |
| T-06-18 | Denial of service | tag 실행 · tag smoke 가 실패해도 tag 를 옮길 수 없다 | medium | accept | 아래 Accepted Risks AR-06-01. 실제로는 일어나지 않았다 — tag 실행 `38844667011` success, `smoke.dart v2.0.0` rc 0 (63초) | closed |
| T-06-19 | Tampering | squash · rebase 로 합쳐 tag 커밋이 `main` 이력에서 빠지거나 브랜치가 지워진다 | high | mitigate | `gh pr merge 1 --merge`. 확인: `origin/main` `5ee5a12` 의 부모 둘(`90a2736` · `ad09d6e`), `merge-base --is-ancestor v2.0.0 origin/main` 참, 원격 head 둘 — orchestrator 가 직접 다시 확인; 06-06-T3 지금 rc 0 | closed |
| T-06-20 | Repudiation | checkpoint 자동 승인으로 소유자 확인 없이 합친다 | high | mitigate | `gate="blocking-human"`. 확인: 소유자 `merge` (04:25:06Z) < 병합 (`mergedAt` 04:26:05Z) | closed |
| T-06-21 | Information disclosure | 남은 커밋 push · PR 본문 · 병합 메시지에 비공개 정보 | medium | mitigate | push gate 뒤에만, 본문은 CHANGELOG 와 run id 만. 확인: 06-06 gate rc 0 (03:28:44Z) → push 03:28:46Z; 공개된 PR #1 본문 28줄에 경로 · 비공개 이름 · 이메일 꼴 0 (orchestrator 가 `gh pr view --json body` 로 다시 셈) | closed |
| T-06-22 | Denial of service | PR 실행이 tag 모드로 잘못 돌아 실패한다 | low | mitigate | PR 로그의 평소 모드 단언. 확인: `pull_request` run `38845784725` success, 로그에 `버전 일치 검사: 평소` | closed |
| T-06-23 | Repudiation | 기록이 없는 커밋 · run 을 가리키거나 닫히지 않은 항목을 닫힌 것처럼 적는다 | medium | mitigate | 제목 머리 · Phase 6 범위로 찾은 sha, `git cat-file -e`. 확인: 06-07-T1 · T2 지금 rc 0; 02-UAT 6번 note 는 `Run workflow` 버튼의 화면 확인을 06-UAT 로 넘긴다고 적었다; 05-UAT 1번 `closed_in` 은 "orchestrator 가 대신 따라 하고 소유자가 화면을 봄" 으로 사실대로 | closed |
| T-06-24 | Tampering | 처리 기록 밖의 줄을 바꾼다 | low | mitigate | 지운 줄 수 · `deferred` 단언. 확인: 06-07 numstat — 02-UAT 8/6, 05-UAT 4/0, DISPOSITION 6/6; `deferred` 는 WR-06 하나 | closed |
| T-06-29 | Tampering | `[3/10]` (i) 가 해석기와 갈리는 입력(여러 줄 스칼라 · HTML 주석 · 펜스 · 들여 쓴 ATX · setext · 인용 · 목록)에서 거짓 통과한다 | high | mitigate | (i) 의 version 은 `package:yaml` 값, CHANGELOG 최상단은 GitHub Flavored 해석의 첫 h2 (깊이 무관), (h) 는 줄 단위 reader 의 원문 전체를 YAML 과 견줌. 확인: `tool/verify.dart` 2271행 `pubspecYamlVersion(repoRoot)`, 1713 ~ 1717행 `md.Document(… gitHubFlavored …)` · `firstElement(nodes, 'h2')`; 06-08-T2 복제본(`c6187cd`) 고친 판 rc 0 — M98 ~ M106 이 고친 판에서 실패, 고치기 전 판에서 통과; 실패 방향 (가) — 최상위만 보는 `firstElement` 는 인용 안 h2 에서 rc 1 | closed |
| T-06-30 | Denial of service | 해석기 기반 reader 가 올바른 CHANGELOG · pubspec 에서 거짓 실패해 평소 CI 가 빨개진다 | high | mitigate | 릴리스 상태의 세 모드 10/10 단언, 대조 입력. 확인: HEAD 에서 평소 · `--tag v2.0.0` · `GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v2.0.0` 모두 rc 0 · 10/10 과 각 모드 줄 (orchestrator 재실행); `# Changelog` · U+FEFF · 4칸 · `===` · raw `<h2>` 대조가 두 판 모두 `passed=true` (06-08-T2 고친 판 rc 0); 실제 실행 셋(브랜치 push `38887002394`, `pull_request` `38887576984`, `main` push `38888830252`) 모두 10/10 | closed |
| T-06-31 | Tampering | 개발용 의존성 `markdown` 이 받는 쪽 lock 여섯에 들어가거나 `dependencies` 에 놓인다 | medium | mitigate | `dev_dependencies` 에만. 확인: `pubspec.yaml` 24행 `  markdown: ^7.3.1` 이 23행 `dev_dependencies:` 아래; lock 여섯은 06-08 전(`97848cd`)과 diff 0 · `markdown` 글자 0 | closed |
| T-06-32 | Information disclosure | 기록 · 커밋 · SUMMARY 에 복제본 · 하네스의 임시 폴더 경로나 비공개 정보 | medium | mitigate | 경로는 말로, Task 2 의 절대 경로 0 단언, 06-10 push gate. 확인: `example/README.md` · 06-08 ~ 06-11 SUMMARY 의 절대 경로 꼴 0; 공개 범위 재점검 0 (감사 메모) | closed |
| T-06-33 | Denial of service | 하위 명령이 네트워크로 멈춰 smoke 가 끝없이 기다린다 | high | mitigate | 단계별 제한, 넘으면 자손까지 끊고 69. 확인: `tool/smoke.dart` 104 · 107 · 110행 (create 2분 · pub get 5분 · analyze 5분), 369행 `killTree` (SIGSTOP → 자손 표 → SIGKILL — 계획의 "자식 하나" 가정과 달리 `dart analyze` 가 자식을 두어 06-09 executor 가 더함); 06-09-T2 복제본(`4286d48`) 고친 판 rc 0 — `sleep 7331` 이 2초에 끊기고 남은 프로세스 0 | closed |
| T-06-34 | Tampering | 예외 · Ctrl-C 로 끝난 smoke 가 새 pub cache 가 든 임시 폴더를 남긴다 | medium | mitigate | `finally` 와 SIGINT 처리기가 같은 `cleanupWork`. 확인: 434 · 997행 `finally`, 961행 `ProcessSignal.sigint.watch()`, 970행 `quit(130)`; 06-09-T2 고친 판의 SIGINT 실행 rc 130 · `woody_smoke_*` 0 · 자식 0 (executor 실행 다섯 회차도 같음) | closed |
| T-06-35 | Repudiation | include 사슬이 끊긴 진단을 찍고도 smoke 가 통과로 끝난다 | high | mitigate | `judge` 가 두 주소 각각에서 코드 둘을 사유로. 확인: 97행 `includeErrorCodes`; 06-09-T1 복제본(`2c5b73b`) 고친 판 rc 0 — 두 주소 각각 사유 1, 다른 `analysis_options.yaml` 진단 사유 0; 실패 방향 (나) — 코드 하나만 보는 판은 rc 1 | closed |
| T-06-36 | Information disclosure | 정리 문구 · 시간 초과 안내가 임시 폴더 경로를 찍는다 | medium | mitigate | `--keep` 때만 경로. 확인: 06-09-T2 하네스 `nokeep … hasPath=false` · `keep … hasPath=true`; SIGINT 실행과 `v2.0.0` smoke (06-09-T3 고친 판 rc 0) 의 stdout · stderr 에 임시 경로 0 단언 | closed |
| T-06-37 | Information disclosure | push 범위에 임시 폴더 경로 · 절대 경로 · 비공개 사용 프로젝트 정보가 들어가 공개된다 | high | mitigate | push gate (fail-closed) 뒤에만 한 줄 push. 확인: 06-10 gate rc 0 → push 10:24:13Z; orchestrator 가 공개 범위 `ad09d6e..75f102f` 를 더 넓게 훑음 — 절대 경로 · 홈 · 비공개 프로젝트 이름 · 측정 폴더 이름 · `~/` 경로 0, 이메일 꼴은 커밋 attribution 주소 하나 | closed |
| T-06-38 | Repudiation | 처리 기록이 실재하지 않거나 다른 task 의 커밋을 가리킨다 | medium | mitigate | 제목 머리로 찾은 task 커밋과 발견별 대조. 확인: 06-10-T1 복제본(`75f102f`) 적힌 그대로 rc 0 — `6aa78fe` · `2c5b73b` · `4286d48`, `cat-file -e`, `01419f9` 자손 | closed |
| T-06-39 | Denial of service | runner 가 `package:markdown` 을 받지 못하거나 PR 실행이 tag 모드로 돈다 | low | mitigate | 두 실행의 success 와 평소 모드 줄 단언. 확인: `38887002394` · `38887576984` success, 로그에 `버전 일치 검사: 평소` · `점검 통과 (10개 중 10개)` (`package:markdown` 을 import 하는 스크립트가 컴파일됨) | closed |
| T-06-40 | Tampering | squash · rebase 로 고침 · tag 커밋이 `main` 이력에서 빠지거나 브랜치 삭제 · 새 tag | high | mitigate | `gh pr merge 2 --merge` 만. 확인: `origin/main` `0038572` 의 부모 `5ee5a12` · `75f102f`; `6aa78fe` · `2c5b73b` · `4286d48` · `75f102f` · `v2.0.0` 모두 조상; 원격 head 둘 · tag 4줄 (orchestrator 직접 확인); 06-11-T2 적힌 그대로 rc 0 | closed |
| T-06-41 | Repudiation | 무인 실행이 checkpoint 를 자동 승인해 소유자 확인 없이 합친다 | high | mitigate | `gate="blocking-human"`. 확인: orchestrator 가 dispatch 전에 물음 — 소유자 `merge` 10:38:32Z < `mergedAt` 10:40:54Z | closed |
| T-06-42 | Information disclosure | 병합 메시지 · SUMMARY 에 임시 폴더 경로 · 비공개 정보 | low | mitigate | 확인: merge commit 메시지에 홈 · 임시 경로 · 개인 이메일 꼴 0; 06-11-SUMMARY 절대 경로 꼴 0 | closed |
| T-06-SC | Tampering | 패키지 설치 (npm/pip/cargo) | high (06-01 ~ 04 · 06-08) / low (06-05 ~ 07 · 06-09 ~ 11) | mitigate / accept | 06-01 ~ 06-07 은 저장소에 패키지를 더하지 않았다 — `pubspec.yaml` 의 변경은 version · 주석 두 줄 (06-04-T1, numstat 2/2), lock 여섯은 `woody_lints` 의 `version` 줄 하나씩; smoke 가 받는 `flutter_riverpod ^3.0.0` 은 `example/pubspec.yaml` 이 이미 쓰는 선언이고 저장소 밖 임시 폴더에만 놓였다. **06-08 이 `dev_dependencies` 에 `markdown: ^7.3.1` 을 더했다** (소유자 결정 G6-Q1). 확인: pub.dev API 의 publisher `tools.dart.dev`, 최신 7.3.1, 의존성 `args` · `meta` (orchestrator 가 06-08 dispatch 전과 이 감사 때 다시 읽음); 루트 lock 은 `direct dev` · hosted pub.dev · 7.3.1; 받는 쪽 그래프 밖 (T-06-31). 06-09 ~ 06-11 은 설치 없음 (AR-06-03) | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-06-01 | T-06-18 | 올린 tag 는 옮기지 않기로 했다 (PROJECT.md Key Decisions, D-01) — tag 실행이나 tag smoke 가 실패하면 고치는 길은 `v2.0.1` 이다. 같은 코드 · 같은 커밋으로 브랜치 CI · 예행이 먼저 통과해 남은 위험은 runner 환경 차이뿐이었고, 실제 실행은 둘 다 통과했다 | 계획 단계의 등록부 (06-05-PLAN.md) — 소유자가 tag push 를 승인함 (2026-10-16) | 2026-10-16 |
| AR-06-02 | T-06-SC (06-05 · 06-06 · 06-07) | 이 세 plan 은 git · gh 명령과 문서만 다룬다 — 설치할 패키지가 없다 | 계획 단계의 등록부 | 2026-10-16 |
| AR-06-03 | T-06-SC (06-09 · 06-10 · 06-11) | 이 세 plan 은 패키지를 설치하지 않는다 — 06-09 는 `dart:io` · `dart:convert` 만, 06-10 · 06-11 은 git · gh 명령과 기록뿐. runner 가 받는 `markdown` 은 06-08 이 publisher 를 확인한 그 선언이다 | 계획 단계의 등록부 (06-09 · 06-10 · 06-11-PLAN.md) | 2026-10-16 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-16 | 29 | 29 | 0 | orchestrator (secure-phase, ASVS L1 — 계획 단계 등록부라 감사 에이전트 생략) |
| 2026-10-16 (gap 수정 뒤) | 43 | 43 | 0 | orchestrator (secure-phase, ASVS L1 — 계획 단계 등록부라 감사 에이전트 생략) |

감사 메모 (2026-10-16):
- 공개된 범위는 위 「Trust Boundaries」 첫 행과 같다. 아직 올리지 않은 `.planning/` 기록 커밋이 이 감사 시점에 다섯 있다 (`6265265` · `41785ad` · `5ceead2` · `970b9fc` · `4841371`). 06-06 의 push gate 를 그 범위로 다시 돌린 결과는 rc 0 이다 (`06-VALIDATION.md` 감사 기록). 이 커밋들을 언제 올릴지는 phase 끝에 소유자에게 묻는다.
- runner 이미지: 이 phase 의 실행 여섯 가운데 다섯(tag · 06-06 의 넷)은 `ubuntu-24.04` / `20261012.334.1`, 06-04 의 브랜치 실행 하나는 `20261004.327.1` 이었다. tag 실행에 "`ubuntu-latest` 가 2026-10-19 부터 Ubuntu 26 으로 옮겨진다" 는 GitHub 안내가 붙었다. 다음 push 의 CI 가 그 뒤에 돌면 이미지가 바뀐다 — 보안 위협은 아니고, 다음 phase 가 알아 둘 사실이다.


감사 메모 (2026-10-16, gap 수정 06-08 ~ 06-11 뒤):
- 새로 공개된 범위는 `ad09d6e..75f102f` (위 「Trust Boundaries」 첫 행). 06-10 의 push gate 와 orchestrator 의 넓은 재점검 모두 0 이었다. 이어서 `main` 에 PR #2 의 병합 커밋 `0038572` 이 생겼다 — 병합은 새 파일을 올리지 않는다.
- 아직 올리지 않은 기록 커밋이 이 감사 시점에 넷 있다 (`fd7bcce` · `3a51efa` · `0251731` · `ccf1b8f`, 이 감사의 커밋은 그 뒤). validate 감사에서 같은 push gate 를 그 범위로 돌리자 `06-10-SUMMARY.md` 108행이 gate 의 자기 점검이 심는 가짜 경로를 글자 그대로 적어 `LEAK?` 로 걸렸다 — 실제 누출은 아니지만 fail-closed gate 라 다음 push 를 막는 자리였다. `0251731` 이 그 줄을 말로 바꿨고 gate 는 rc 0 이 되었다. 이 커밋들을 올릴지는 phase 끝에 소유자에게 묻는다.
- 06-09 의 `killTree` 는 계획에 없던 구현이다 (자손까지 얼린 뒤 끊음, `/bin/ps` 를 절대 경로 · `Process.runSync` 로). 하위 프로세스에 사용자 입력이 들어가지 않고 pid 만 다루므로 새 위협으로 보지 않았다 — 동작 판정은 code review 와 verifier 에 맡긴다.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-16

## Security Audit 2026-10-16

| Metric | Count |
|---|---|
| Threats found | 29 |
| Closed | 29 |
| Open | 0 |

## Security Audit 2026-10-16

| Metric | Count |
|---|---|
| Threats found | 43 |
| Closed | 43 |
| Open | 0 |
