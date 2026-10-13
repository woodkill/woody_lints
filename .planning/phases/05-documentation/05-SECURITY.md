---
phase: "5"
slug: "documentation"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-14"
---

# Phase 5 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
>
> 출처: `05-01-PLAN.md` ~ `05-06-PLAN.md` 의 `<threat_model>` (계획 단계에서 작성됨). ASVS level 1, block on `high`.
> 이 phase 가 바꾼 실행 코드는 로컬 검증 스크립트 `tool/verify.dart` 하나다 (reader 둘 고침, `[3/10]` 에 (b′) · (d) ~ (g) 추가). 배포 산출물 `lib/*.yaml` 다섯은 주석만 바뀌었다. 나머지는 문서(README · CHANGELOG · `example/README.md` · `.claude/CLAUDE.md` · 처리 기록)다. 사용자 입력 · 인증 · 저장 데이터가 없다. 해당 범주는 공개 저장소로 비공개 정보가 새는 것, 배포 설정이 주석 정리 중에 바뀌는 것, 검증 명령의 reader 가 거짓 실패 · 거짓 통과를 내는 것, 문서가 실측되지 않은 동작을 단정하는 것, 원격 쓰기다.
> 아래 "확인" 은 2026-10-14 phase 실행 뒤(HEAD `85ae036`) 이 저장소에서 명령을 다시 돌리거나 파일을 직접 읽어 얻은 결과다. "복제본 rc 0" 은 `05-VALIDATION.md` 「감사 결과 (2026-10-14)」 의 실행 — task 마다 자기 커밋으로 되돌린 로컬 복제본에서 계획의 `<automated>` 를 적힌 그대로 돌린 결과 — 를 가리킨다.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| 로컬 저장소 → 공개 원격 (GitHub) | 이 phase 의 모든 파일과 `.planning/` 이 05-05 에서 공개 저장소에 올라갔다 — `0db0fdd..92d478a` (65커밋, Phase 4 의 38 + Phase 5 의 27). 되돌릴 수 없다 (D-20 · D-21) | 문서 · 검증 스크립트 · 배포 YAML 주석 |
| 로컬 → GitHub Actions | push 가 `verify` workflow 를 돌린다 — 권한은 `contents: read` 뿐 | 저장소 내용 (읽기) |
| 배포 파일 → 검증 명령 | `tool/verify.dart` 가 `lib/*.yaml` · `README.md` · `pubspec.yaml` 을 읽어 판정한다 — reader 가 틀리면 거짓 실패(70) 또는 거짓 통과 | YAML · Markdown 문자열 |
| 검증 명령 → 네트워크 | `[2/10]` 복사본에 `plugins:` 가 남으면 분석이 plugin 을 준비한다 (pub 서버) | plugin 패키지 |
| 사람의 결정 → 실행 | push 는 소유자의 "push" 뒤에만 — auto-mode 에서도 멈춘다 (`gate="blocking-human"`) | 결정 |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-05-01 | Tampering | `stripPlugins` 가 `plugins:` 섹션을 놓쳐 복사본 분석이 plugin 을 준비한다 | medium | mitigate | 빈 줄 치환 뒤에도 `^plugins:` 가 남으면 `FormatException`. 확인: `tool/verify.dart` 에 `섹션을 빼지 못했다` 1곳; 05-01-T1 복제본(`1831c04`) rc 0 — M32 · M33 뒤 분석이 열 단계 통과 | closed |
| T-05-02 | Repudiation | `readShippedPluginConstraint` 가 느슨해져 없는 선언을 만들어 내거나 다른 줄의 값을 읽는다 | medium | mitigate | 스칼라 · 맵 두 꼴만 받고 그 밖은 70. 확인: `에서 riverpod_lint 선언을 찾지 못했다` 1곳; 05-01-T1 복제본 rc 0 — M34 (선언 삭제) 가 종료 코드 70 · 빈 stdout | closed |
| T-05-03 | Repudiation | 다른 조각에 적힌 규칙이 (b) · (c) 를 지나쳐 README 비교에도 같은 빈자리가 생긴다 | medium | mitigate | `[3/10]` (b′). 확인: `에 규칙이 있다 (${extra.length})` 1곳; 05-01-T2 복제본(`dc42790`) rc 0 — M35 `[3/10]` 만 실패, M37 이 `lib/riverpod.yaml` 도 잡음 | closed |
| T-05-04 | Information disclosure | M 기록 · 처리 기록 · SUMMARY 에 절대 경로나 사용 프로젝트 정보가 섞인다 | high | mitigate | 저장소 경로만. 확인: 05-01-T3 복제본(`2be345e`) rc 0 (절대 경로 grep 포함); push 범위 전체 점검 0 (T-05-17) | closed |
| T-05-05 | Tampering | 주석 정리 중 규칙 줄 · `analyzer:` 블록 · include 줄이 바뀌어 사용 프로젝트의 진단이 바뀐다 | high | mitigate | 비주석 줄 고정 + `--update`. 확인: 지금 `lib/base.yaml` 의 비주석 줄(줄 끝 사유 주석 제외)이 `6d64bee` 와, `codegen` · `recommended` · `analysis_options` 가 `89d6073` 과, `riverpod` 이 `166d0be` 와 같다; 정답지 다섯이 `6d64bee` 와 같다; 05-02-T1 복제본(`209e3af`) rc 0 — `바뀐 정답지가 없다` | closed |
| T-05-06 | Tampering | `lib/riverpod.yaml` 10행의 줄 끝 주석이 reader 를 깨뜨려 CI 가 70 으로 멈춘다 | medium | mitigate | 05-01 이 먼저 WR-02 를 닫음 (depends_on). 확인: 10행에 줄 끝 주석이 달린 채 로컬 `verify.dart` rc 0 · `점검 통과 (10개 중 10개)`; GitHub run 38460138720 `success` | closed |
| T-05-07 | Information disclosure | YAML 주석 · CLAUDE.md 에 홈 경로나 비공개 프로젝트 정보가 섞인다 | high | mitigate | 절대 경로 grep. 확인: 05-02-T1 · T2 의 grep 단언 통과(T2 는 고친 판 — 결함은 다른 단언); `lib/*.yaml` · `.claude/CLAUDE.md` 절대 경로 0줄; push 범위 점검 0 | closed |
| T-05-08 | Tampering | `.claude/CLAUDE.md` 의 두 줄 밖을 고친다 | low | mitigate | `cd76cc8` 과의 diff 고정. 확인: `git diff --numstat cd76cc8 -- .claude/CLAUDE.md` = `2 2`; 05-02-T2 고친 판 rc 0 (적힌 그대로 rc 1 은 정규식 결함 — `05-VALIDATION.md`) | closed |
| T-05-09 | Tampering | README 설치 블록의 `url:` 오타가 다른 저장소를 가리킨다 | high | mitigate | 글자 단언. 확인: README 의 `url: https://github.com/woodkill/woody_lints.git` 2줄이 `pubspec.yaml` 8행 `repository:` 와 같다; 05-03-T1 복제본(`3a248d0`) rc 0 | closed |
| T-05-10 | Tampering | 복구 안내가 `~/.dartServer` 전체 삭제를 권해 IDE · 다른 프로젝트의 상태를 지운다 | medium | mitigate | 범위를 좁힌 안내. 확인: README 에 `rm -rf ~/.dartServer` 0줄, `.plugin_manager/<hash>` 1곳; 문장 읽기는 `/gsd-verify-work 5` 의 수동 확인 | closed |
| T-05-11 | Repudiation | README 의 규칙 목록 · 주소 · plugin 버전 · `ref:` 가 배포 파일 · pubspec 과 어긋나도 CI 가 통과한다 | high | mitigate | `[3/10]` (d) ~ (g), 0개면 실패. 확인: 05-03-T2 복제본(`84f937a`) rc 0 (마커 삭제 → 실패); 05-06-T1 복제본(`1d28346`) rc 0 — M38 ~ M42 다섯 모두 `[3/10]` 실패; GitHub run 에서 `[3/10] … 통과` | closed |
| T-05-12 | Spoofing | README 산문이 실측되지 않은 도구 동작을 사실처럼 단정한다 | medium | mitigate | 단정 / 출처 구분, SDK 버전 · 날짜. 확인: README 에 날짜 표기 7곳, workspace 문장은 URL · 읽은 날짜와 함께 인용 (05-03-SUMMARY); 05-03-T1 의 금지 문구 단언 통과. 문장마다의 판정은 Manual-Only (`05-VALIDATION.md`) — `/gsd-verify-work 5` | closed |
| T-05-13 | Information disclosure | README · SUMMARY 에 사용 프로젝트의 경로 · 메시지 · 절대 경로가 섞인다 | high | mitigate | 절대 경로 grep, fixture 경로만 인용. 확인: README · `tool/verify.dart` · 05-03-SUMMARY 절대 경로 0줄, README 에 비공개 프로젝트 이름 0회; push 범위 점검 0 | closed |
| T-05-14 | Repudiation | 복원 항목이 diff 가 아닌 커밋 메시지 · 기억으로 쓰인다 | medium | mitigate | 커밋마다 `git show`. 확인: 05-04-T1 복제본(`024a36c`) rc 0 (`Update pubspec` 0줄 단언 포함); orchestrator 가 1.2.4 항목을 `git show 212365d -- lib/analysis_options.yaml` 과 대조 — 일치. 나머지 항목의 대조는 Manual-Only | closed |
| T-05-15 | Tampering | 2.0.0 의 표 수치나 1.3.0 · 1.0.0 항목이 바뀐다 | medium | mitigate | `fb6386a` 와 diff. 확인: 05-04-T2 복제본(`6abea40`) rc 0 — `### 추가한 규칙` · `### 새로 생기는 경고` · 1 ~ 3행이 `fb6386a` 와 같고 75 == 75 | closed |
| T-05-16 | Information disclosure | CHANGELOG 에 비공개 프로젝트의 경로 · `dart fix` 화면 문구가 섞인다 | high | mitigate | 절대 경로 · `fixes? made in` grep. 확인: 05-04-T2 복제본 rc 0; CHANGELOG 의 비공개 프로젝트 언급은 기존 허용 줄 `실측: flutter_starter_kit …` 하나 | closed |
| T-05-17 | Information disclosure | push 범위에 비공개 사용 프로젝트의 경로 · 메시지 · 절대 경로가 섞인다 | high | mitigate | push 전 범위 전체 점검. 확인: executor 의 05-05-T1 점검 (1) ~ (3) 모두 0 (`05-05-SUMMARY.md`); orchestrator 가 묻기 전에 `0db0fdd..92d478a` 의 추가된 줄 전체를 다시 훑음 — 절대 경로 꼴 0줄, 이메일 꼴 0개, 커밋 메시지 65개 0줄, 비공개 프로젝트는 이름만 35줄(경로 꼴 0) | closed |
| T-05-18 | Tampering | `main` · tag 를 건드리거나 덮어쓰는 push | high | mitigate | 브랜치 이름 하나만 준 push. 확인: push 출력 `0db0fdd..92d478a`(fast-forward); 지금 원격 head 둘 — `main` `90a2736b8d99…`, 작업 브랜치 `92d478a`; tag `v1.3.0` 하나; PR 0 | closed |
| T-05-19 | Elevation of privilege | workflow 가 쓰기 권한을 얻어 저장소를 바꾼다 | low | accept | 아래 Accepted Risks Log. 확인: `.github/workflows/verify.yml` 14 ~ 15행 `permissions:` / `contents: read`; 이 phase 에서 `.github` 변경 0커밋 | closed |
| T-05-20 | Repudiation | 무인 실행이 checkpoint 를 자동 승인해 소유자 확인 없이 올린다 | high | mitigate | `gate="blocking-human"`, `autonomous: false`. 확인: 05-05-PLAN 에 둘 다 있음; executor 는 Task 1 뒤 push 없이 돌아왔고, 소유자가 AskUserQuestion 에서 "올린다" 를 고른 뒤에만 push (2026-10-14, `05-05-SUMMARY.md`) | closed |
| T-05-21 | Tampering | 변형한 `README.md` 가 커밋되거나 더러운 채 남는다 | medium | mitigate | 되돌린 뒤 판정. 확인: 05-06-T1 복제본 rc 0 · 실행 뒤 복제본 `git status` 0줄; 커밋 `1d28346` 은 `example/README.md` 하나만 담음 | closed |
| T-05-22 | Repudiation | 틀린 (e)(첫 주소만) · 틀린 (f)(g)(파일 전체) 가 지워 보기를 지나친다 | medium | mitigate | M39 는 뒤쪽 주소를 바꿈; 블록 한정은 코드를 읽은 것으로 적음. 확인: README 의 `codegen.yaml` 주소는 78행(첫 주소는 50행), M39 실패 기록; `example/README.md` 가 `fencedLines` 를 코드에서 읽은 것으로 적음 (P-02) | closed |
| T-05-23 | Information disclosure | 기록 · SUMMARY 에 절대 경로가 섞인다 | high | mitigate | 절대 경로 grep. 확인: 05-06-T1 복제본 rc 0 (grep 포함); push 범위 점검 0 | closed |
| T-05-SC | Tampering | npm/pip/cargo installs (공급망) | high | mitigate | 이 phase 는 pub 의존성을 더하지 않는다. 확인: `2c026dd..HEAD` 에서 `pubspec.yaml` · `example/pubspec.yaml` · `fixtures/*/pubspec.yaml` 변경 0; `tool/verify.dart` 의 import 는 `dart:convert` · `dart:io` 둘뿐 (05-01 · 05-03 의 `<automated>` 단언) | closed |

*Status: open · closed*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-05-01 | T-05-19 | `verify` workflow 의 권한은 Phase 2 가 정한 `contents: read` 뿐이고 이 phase 는 `.github` 를 바꾸지 않았다. GitHub Actions 런타임 자체가 권한을 넘는 경우는 이 저장소가 막을 수 없는 범위다 (low) | 계획 단계 결정 (`05-05-PLAN.md` threat register, disposition accept) | 2026-10-14 |

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-14 | 24 | 24 | 0 | orchestrator (secure-phase State B, ASVS L1 — 계획 위협 목록, 감사 에이전트 생략) |

감사 메모 (2026-10-14):

- **실제로 올라간 범위.** `0db0fdd..92d478a`, 65커밋, 59개 파일 (+9,236 / −714줄, 삭제 0). 폴더별로 `.planning/phases` 31 (01 · 03 처리 기록 각 1, 04 13, 05 16), `.planning/` 최상위 4, `fixtures/` 9, `lib/` 5, `example/` 3, `tool/` 3, `README.md` · `CHANGELOG.md` · `RULES.md` · `.claude/CLAUDE.md`. 계획 문장(Phase 5 파일)보다 넓다 — Phase 4 의 gap 수정 04-11 ~ 04-13 과 재검증 문서가 지난 push(`0db0fdd`) 뒤에 쌓여 함께 올라갔다. 그래서 점검은 범위 전체의 추가된 줄로 했다 (T-05-17).
- **마무리 커밋은 원격에 없다.** `ce245a5` · `72d7015` (05-05 SUMMARY · 메타데이터) 와 그 뒤의 검증 문서 커밋들이다. 다음 push 는 D-21 대로 소유자에게 다시 묻는다.
- **수동 확인으로 남긴 것.** README 문장마다의 단정 / 출처 구분(T-05-12), 복구 안내 문장(T-05-10), CHANGELOG 복원 항목 여섯의 diff 대조(T-05-14)는 grep 깊이(ASVS L1)로는 가를 수 없다 — `05-VALIDATION.md` Manual-Only 와 `/gsd-verify-work 5` 로 넘긴다. 완화책 자체(날짜 · 범위를 좁힌 안내 · 커밋 번호)는 있다.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-14

## Security Audit 2026-10-13

| Metric | Count |
|---|---|
| Threats found | 24 |
| Closed | 24 |
| Open | 0 |
