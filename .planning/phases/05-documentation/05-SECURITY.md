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
> 출처: `05-01-PLAN.md` ~ `05-11-PLAN.md` 의 `<threat_model>` (계획 단계에서 작성됨 — 05-07 ~ 05-09 는 gap 수정 계획, 05-10 · 05-11 은 2회차 gap 수정 계획). ASVS level 1, block on `high`.
> 이 phase 가 바꾼 실행 코드는 로컬 검증 스크립트 `tool/verify.dart` 하나다 (reader 둘 고침, `[3/10]` 에 (b′) · (d) ~ (g) 추가). 배포 산출물 `lib/*.yaml` 다섯은 주석만 바뀌었다. 나머지는 문서(README · CHANGELOG · `example/README.md` · `.claude/CLAUDE.md` · 처리 기록)다. 사용자 입력 · 인증 · 저장 데이터가 없다. 해당 범주는 공개 저장소로 비공개 정보가 새는 것, 배포 설정이 주석 정리 중에 바뀌는 것, 검증 명령의 reader 가 거짓 실패 · 거짓 통과를 내는 것, 문서가 실측되지 않은 동작을 단정하는 것, 원격 쓰기다.
> 아래 "확인" 은 2026-10-14 phase 실행 뒤(HEAD `85ae036`) 이 저장소에서 명령을 다시 돌리거나 파일을 직접 읽어 얻은 결과다. "복제본 rc 0" 은 `05-VALIDATION.md` 「감사 결과 (2026-10-14)」 의 실행 — task 마다 자기 커밋으로 되돌린 로컬 복제본에서 계획의 `<automated>` 를 적힌 그대로 돌린 결과 — 를 가리킨다.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| 로컬 저장소 → 공개 원격 (GitHub) | 이 phase 의 모든 파일과 `.planning/` 이 05-05 에서 공개 저장소에 올라갔다 — `0db0fdd..92d478a` (65커밋, Phase 4 의 38 + Phase 5 의 27), gap 수정 뒤 05-09 에서 `92d478a..8789cfe` (25커밋), 2회차 gap 수정 뒤 05-11 에서 `8789cfe..b8519d4` (19커밋). 되돌릴 수 없다 (D-20 · D-21) | 문서 · 검증 스크립트 · 배포 YAML 주석 |
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
| T-05-24 | Tampering | 변형한 `README.md` · `lib/codegen.yaml` 이 작업 트리에 남거나 커밋된다 (05-07) | medium | mitigate | 지워 보기는 `git clone --local` 복제본에서만, 되돌린 뒤 판정. 확인: 05-07-T1 ~ T3 복제본(`5f43726` · `057bef2` · `73f1c66`) rc 0 — 각 단언이 `git diff --quiet HEAD -- README.md lib RULES.md` · `test ! -e build/woody_rule_check`; 본 작업 폴더에 `build/woody_rule_check` 없음, `git status` 는 GSD 상태 넷뿐 | closed |
| T-05-25 | Repudiation | README 표시 구역 reader 가 `- ` 줄만 거르고 backtick 없는 줄 · 이름 꼴이 아닌 불릿을 건너뛴다 | medium | mitigate | 받는 줄을 닫힌 목록으로, 그 밖은 `[3/10]` 실패. 확인: 05-07-T1 복제본(`5f43726`) rc 0 — M43 `(1)` · M44 `(2)`, 이름 비교 블록 없음 | closed |
| T-05-26 | Information disclosure | 복제본의 임시 폴더 절대 경로가 `example/README.md` · SUMMARY 에 섞인다 (05-07) | high | mitigate | 절대 경로 grep. 확인: 05-07-T1 ~ T3 복제본 rc 0 (grep 포함); `example/README.md` · 05-07-SUMMARY 절대 경로 0줄; push 범위 점검 0 (T-05-33) | closed |
| T-05-27 | Repudiation | `RULES.md` 표 reader 가 backtick 없는 행을 머리 줄로 받거나 표 행이 아닌 줄을 건너뛰거나 대소문자를 무시한다 | medium | mitigate | 머리 줄 · 구분 줄 · backtick 이름 행 밖은 `[3/10]` 실패. 확인: 05-08-T1 복제본(`812c477`) rc 0 — M51 · M52 `(1)`, M53 `(2)`, 표 비교 블록 없음 | closed |
| T-05-28 | Repudiation | README 주소 검사 (e) 가 확장자만 넓히거나 패키지 이름을 보지 않는다 | medium | mitigate | 후보를 모두 모아 꼴 · 패키지 이름을 따로 판정. 확인: 05-08-T2 복제본(`63fe3d9`) rc 0 — M54 `꼴이 아닌 것이 있다 (1)`, M55 다른 패키지 주소 `(2)` | closed |
| T-05-29 | Tampering | 코드 블록 값 (f) · (g) 가 한쪽 따옴표만 벗기거나 맞는 값의 따옴표 · 주석까지 거부한다 | medium | mitigate | `unquotedScalar` 와 꼴 판정. 확인: 05-07-T3 복제본(`73f1c66`) rc 0 — M47 · M48 벗긴 값 줄, M49 읽지 못하는 줄 `(1)`, M50 (맞는 값에 따옴표 · 주석) 10/10 | closed |
| T-05-30 | Information disclosure | 복제본의 임시 폴더 절대 경로가 `example/README.md` · SUMMARY 에 섞인다 (05-08) | high | mitigate | 절대 경로 grep. 확인: 05-08-T1 ~ T3 복제본 rc 0 (grep 포함); 05-08-SUMMARY 절대 경로 0줄; push 범위 점검 0 | closed |
| T-05-31 | Repudiation | plugin 선언 reader 가 범위 제약을 조용히 받거나 따옴표 · 맵 순서에서 거짓 실패한다 | medium | mitigate | `^X.Y.Z` · `X.Y.Z` 만 받고 범위 제약은 원인을 말하는 70. 확인: 05-09-T1 복제본(`644897f`) rc 0 — M63 · M67 10/10, M64 · M65 70 아님, M66 rc 70 · `꼴만 받는다` · `선언을 찾지 못했다` 없음 | closed |
| T-05-32 | Tampering | `lib/riverpod.yaml` 5행 주석을 고치다 선언 값이 바뀌어 사용 프로젝트의 plugin 버전이 바뀐다 | medium | mitigate | 비주석 내용 고정. 확인: `lib/riverpod.yaml` 의 비주석 내용이 `209e3af` 와 같다(diff 1 · 1, 주석만); 나머지 배포 YAML 넷은 `209e3af` 와, 정답지 · fixtures 는 `e69470e` 와 같다; 05-09-T2 복제본(`e46cff4`) rc 0 | closed |
| T-05-33 | Information disclosure | push 범위(`92d478a..HEAD`)에 비공개 경로 · 이메일 · 사용 프로젝트 정보가 섞인다 | high | mitigate | push 전 범위 전체 점검이 0 일 때만 push. 확인: executor 가 push 전에 05-09-T3 첫째 `<automated>` rc 0 (`05-09-SUMMARY.md`); 복제본(`8789cfe`) rc 0; orchestrator 가 dispatch 전 · 뒤 `92d478a..8789cfe` 의 추가된 줄 전체를 다시 훑음 — 절대 경로 꼴 0줄, 이메일 꼴 0줄, 비공개 프로젝트는 이미 있던 "실측: …" 줄의 인용 3줄(경로 꼴 0) | closed |
| T-05-34 | Tampering | `main` · tag 를 건드리거나 덮어쓰는 push (05-09) | high | mitigate | 브랜치 이름 하나만 준 push. 확인: push `92d478a..8789cfe` fast-forward (25커밋); 지금 원격 head 둘 — `main` `90a2736b8d99…`, 작업 브랜치 `8789cfe`; tag `v1.3.0` 하나; PR 0; 05-09-T3 둘째를 `8789cfe` 로 고정한 판 rc 0 | closed |
| T-05-35 | Repudiation | 처리 기록이 커밋 없이 `fixed` 를 적거나 다른 커밋을 가리킨다 | low | mitigate | 해시마다 조상 · 파일 확인 (`chk`). 확인: 05-09-T3 첫째 복제본(`8789cfe`) rc 0 — fixed 12 행 모두 `e69470e` 뒤의 커밋이고 정해진 파일을 바꿈, WR-06 deferred (D-09) | closed |
| T-05-36 | Information disclosure | 복제본의 임시 폴더 절대 경로가 `example/README.md` · SUMMARY 에 섞인다 (05-09) | high | mitigate | 절대 경로 grep. 확인: 05-09-T1 · T2 복제본 rc 0 (grep 포함); 05-09-SUMMARY · `05-REVIEW-DISPOSITION.md` 절대 경로 0줄; push 범위 점검 0 | closed |
| T-05-37 | Elevation of privilege | workflow 가 쓰기 권한을 얻어 저장소를 바꾼다 (05-09 push) | low | accept | 아래 Accepted Risks Log (AR-05-02). 확인: `.github/workflows/verify.yml` 14 ~ 15행 `permissions:` / `contents: read`; `e69470e..HEAD` 에서 `.github` 변경 0 | closed |
| T-05-38 | Repudiation | `enabledLanguageOptions` 가 `language:` 의 flow 표기나 읽지 못하는 옵션 줄을 건너뛴다 | medium | mitigate | `analyzer:` · `language:` 줄에 붙은 값과 읽지 못하는 줄은 70. 확인: 05-08-T3 복제본(`a14be4f`) rc 0 — M59 ~ M61 rc 70 · 파일 이름 · 행, M62 (블록 꼴 + 줄 끝 주석) rc 1 `+ strict-casts` (과잉 수정 아님) | closed |
| T-05-39 | Tampering | `tool/measure_rules.dart` 의 문서 주석을 고치다 `readRulesTable` 코드가 바뀐다 | low | mitigate | `///` 줄만. 확인: `git diff -U0 c06d8d5 -- tool/measure_rules.dart` 의 바뀐 줄이 모두 `///` (비주석 0줄); 05-08-T1 복제본 rc 0 | closed |
| T-05-40 | Tampering | 다른 철자의 `linter` 키 · `formatter:` · codegen 의 `language:` · 열 0 밖의 최상위 키로 규칙 · 옵션이 검사 없이 사용 프로젝트에 닿는다 (2회차 gap · WR-10) | high | mitigate | `[3/10]` (a′) 닫힌 목록 (`allowedTopLevelKeys` · `allowedChildKeys` · `findUnexpectedKeys`). 확인: `tool/verify.dart` 에 `최상위에 받지 않는 줄이 있다` 있음; 05-10-T1 복제본(`02966c4`) rc 0 — M68 ~ M73 각각 종료 코드 1 · `[3/10]` 만 실패 · 정해진 블록; 아래 키 목록을 늘 비게 한 판은 rc 1 | closed |
| T-05-41 | Repudiation | 철자를 더 받는 정규식으로 "고쳐" 다음 철자에서 같은 모양이 남는다 | medium | mitigate | `declaredRuleNames` 는 그대로. 확인: 그 함수의 코드 줄 38줄이 `644897f` 와 HEAD 에서 같음 (python 대조); `RegExp(r'^linter:').hasMatch(line)` 1곳 그대로; 05-10-T1 복제본 rc 0 — M68 ~ M70 화면에 `에 규칙이 있다` 블록 없음 | closed |
| T-05-42 | Tampering | 닫힌 목록이 70 을 던지거나 (b′) · (c) · (f) 를 건너뛰게 해 앞 기록의 70 · 실패가 바뀐다 | medium | mitigate | (a′) 는 블록만 더함. 확인: 05-10-T1 복제본 rc 0 — 회귀 입력 11개(M45 · M36 · M34 · M60 · M59 · M61 · M66 → 70 과 같은 stderr, M46 · M62 → 실패, M65 · M63 → 통과)가 앞 기록과 같음 | closed |
| T-05-43 | Denial of service | 닫힌 목록 · 절 검사가 올바른 지금 파일에서 거짓 실패를 내 검증이 늘 빨갛다 | low | mitigate | 확인: 작업 트리 `verify.dart` 10개 중 10개 (05-10 뒤 · 05-11 뒤), GitHub run 38522962086 `success` · `[3/10] … 통과`; M62 · M65 · M76 통과 (05-10-T1 · T2 복제본) | closed |
| T-05-44 | Repudiation | 절의 경계를 잘못 잡아 구역 밖 목록 줄을 놓치거나(펜스 안 `#` 을 제목으로) 다른 절까지 실패시킨다 | medium | mitigate | `findListLinesOutsideMarkers` · `markFencedLines`. 확인: 05-10-T2 복제본(`204e401`) rc 0 — M77 `(1)` · 펜스 안 줄 제외, M76 통과, M75 `(5)`, M74 `(1)` | closed |
| T-05-45 | Tampering | G2-Q2 · G2-Q5 를 넘어 (e) · (f) · (g) · `fencedLines` 의 코드를 바꾼다 (승인 밖) | medium | mitigate | 코드 줄 대조. 확인: 05-10-T3 복제본(`d2d74c4`) rc 0 — 파일 전체 코드 줄(주석 줄을 뺀 줄)이 Task 2 커밋과 같고 그 구간이 `644897f` 와 같음; 작업 트리에서 다시 돌려 rc 0 | closed |
| T-05-46 | Information disclosure | 복제본의 임시 폴더 절대 경로가 `example/README.md` · SUMMARY 에 적힌다 (05-10) | high | mitigate | 경로는 변수로만. 확인: 05-10 세 task 복제본 rc 0 (절대 경로 grep 포함); `1b49c74..HEAD` 의 추가된 줄에 절대 경로 · 이메일 · 비공개 사용 프로젝트 이름 0줄 | closed |
| T-05-47 | Repudiation | 지워 보기 기록(M68 ~ M78)의 결과가 실제 실행과 다르다 | low | mitigate | 자동 검증이 기록한 입력을 다시 돈다. 확인: 05-10-T1 · T2 복제본 rc 0 (task 커밋 시점, 실행자와 따로) | closed |
| T-05-54 | Tampering | `lib/riverpod.yaml` 의 `plugins:` 아래 다른 plugin 이 검사 없이 사용 프로젝트에 닿는다 | high | mitigate | `allowedChildKeys` 의 `plugins` → `riverpod_lint`. 확인: 05-10-T1 복제본 rc 0 — M78 이 `plugins:` 바로 아래 블록 `(2)` · 항목 줄 둘, M65 · M63 통과; 아래 키 목록을 늘 비게 한 판은 rc 1 | closed |
| T-05-48 | Repudiation | 처리 기록이 커밋 없이 `fixed` 를 적거나, 이유 없이 `skipped` 를 적거나, 세 자리 가운데 하나만 고친다 (05-11) | low | mitigate | `dsp` · `hs` 단언. 확인: 05-11-T1 복제본(`b8519d4`) rc 0 · 작업 트리 rc 0 — fixed 13 · skipped 4 · deferred 1 · `open: 0`, WR-10 → `02966c4`, 넷 → `d2d74c4`; 실행자의 고치기 전 파일 판 rc 1 | closed |
| T-05-49 | Information disclosure | push 범위(`8789cfe..HEAD`)에 비공개 사용 프로젝트의 경로 · 절대 경로가 들어가 공개된다 (05-11, 되돌릴 수 없음) | high | mitigate | push 전 범위 전체 점검. 확인: 05-11-T2 첫째 — dispatch 전 작업 트리(`c7b3211`) rc 0, 실행자의 push 직전(`b8519d4`) rc 0, 복제본(`b8519d4`) rc 0; 실제로 올라간 `8789cfe..b8519d4` 의 추가된 줄 · 커밋 메시지에 절대 경로 · 이메일 · 비공개 사용 프로젝트 이름 0 | closed |
| T-05-50 | Information disclosure | 누출 점검이 거짓 양성으로 늘 멈추거나 아무것도 보지 않아 헛통과한다 | medium | mitigate | `.claude/CLAUDE.md` 불변 단언 + 심은 경로를 `LEAK?` 로 잡는 단언. 확인: 05-11-T2 첫째 rc 0 (같은 명령 안에서 심은 경로가 잡힘) | closed |
| T-05-51 | Tampering | `main` · tag 를 건드리거나 덮어쓰는 push (05-11) | high | mitigate | `git push origin gsd/v2.0-package-rework` 한 줄. 확인: 05-11-T2 둘째 작업 트리 rc 0 (메타데이터 커밋 뒤) — origin 작업 브랜치 `b8519d4` 는 `8789cfe` 의 자손, head 둘(`main` = `90a2736`), tag `v1.3.0` 하나, PR 0 | closed |
| T-05-52 | Repudiation | push 뒤 단언이 HEAD 에 묶여 메타데이터 커밋 뒤 사후 감사에서 거짓 실패한다 | low | mitigate | "처리 기록 커밋 ⊆ origin 머리 ⊆ HEAD" 로 단언. 확인: 메타데이터 커밋 `b7d8215` 뒤 작업 트리에서 05-11-T2 둘째를 적힌 그대로 돌려 rc 0 | closed |
| T-05-53 | Elevation of privilege | workflow 가 쓰기 권한을 얻어 저장소를 바꾼다 (05-11 push) | low | accept | 아래 Accepted Risks Log (AR-05-03). 확인: `.github/workflows/verify.yml` `permissions:` / `contents: read`; `8789cfe..b8519d4` 에서 `.github` 변경 0 | closed |
| T-05-SC | Tampering | npm/pip/cargo installs (공급망) | high | mitigate | 이 phase 는 pub 의존성을 더하지 않는다. 확인: `8789cfe..b8519d4` 에서도 `pubspec.yaml` · `example/pubspec.yaml` · `fixtures` 변경 0; `2c026dd..HEAD` 에서 `pubspec.yaml` · `example/pubspec.yaml` · `fixtures/*/pubspec.yaml` 변경 0; `tool/verify.dart` 의 import 는 `dart:convert` · `dart:io` 둘뿐 (05-01 · 05-03 의 `<automated>` 단언) | closed |

*Status: open · closed*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-05-03 | T-05-53 | 2회차 gap 수정 push(05-11)도 같은 `verify` workflow 를 돌린다 — 권한은 `contents: read` 그대로이고 `.github` 는 바뀌지 않았다. 런타임 자체의 권한 문제는 AR-05-01 과 같은 범위다 (low) | 계획 단계 결정 (`05-11-PLAN.md` threat register, disposition accept) | 2026-10-14 |
| AR-05-02 | T-05-37 | gap 수정 push(05-09)도 같은 `verify` workflow 를 돌린다 — 권한은 `contents: read` 그대로이고 `.github` 는 바뀌지 않았다. 런타임 자체의 권한 문제는 AR-05-01 과 같은 범위다 (low) | 계획 단계 결정 (`05-09-PLAN.md` threat register, disposition accept) | 2026-10-14 |
| AR-05-01 | T-05-19 | `verify` workflow 의 권한은 Phase 2 가 정한 `contents: read` 뿐이고 이 phase 는 `.github` 를 바꾸지 않았다. GitHub Actions 런타임 자체가 권한을 넘는 경우는 이 저장소가 막을 수 없는 범위다 (low) | 계획 단계 결정 (`05-05-PLAN.md` threat register, disposition accept) | 2026-10-14 |

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-14 | 24 | 24 | 0 | orchestrator (secure-phase State B, ASVS L1 — 계획 위협 목록, 감사 에이전트 생략) |
| 2026-10-14 (gap 수정 뒤) | 40 | 40 | 0 | orchestrator (secure-phase State A, ASVS L1 — 05-07 ~ 05-09 의 위협 목록 16개 추가, 감사 에이전트 생략) |
| 2026-10-14 (2회차 gap 수정 뒤) | 55 | 55 | 0 | orchestrator (secure-phase State A, ASVS L1 — 05-10 · 05-11 의 위협 목록 15개 추가, 감사 에이전트 생략) |

감사 메모 (2026-10-14):

- **실제로 올라간 범위.** `0db0fdd..92d478a`, 65커밋, 59개 파일 (+9,236 / −714줄, 삭제 0). 폴더별로 `.planning/phases` 31 (01 · 03 처리 기록 각 1, 04 13, 05 16), `.planning/` 최상위 4, `fixtures/` 9, `lib/` 5, `example/` 3, `tool/` 3, `README.md` · `CHANGELOG.md` · `RULES.md` · `.claude/CLAUDE.md`. 계획 문장(Phase 5 파일)보다 넓다 — Phase 4 의 gap 수정 04-11 ~ 04-13 과 재검증 문서가 지난 push(`0db0fdd`) 뒤에 쌓여 함께 올라갔다. 그래서 점검은 범위 전체의 추가된 줄로 했다 (T-05-17).
- **마무리 커밋은 원격에 없다.** `ce245a5` · `72d7015` (05-05 SUMMARY · 메타데이터) 와 그 뒤의 검증 문서 커밋들이다. 다음 push 는 D-21 대로 소유자에게 다시 묻는다.
- **수동 확인으로 남긴 것.** README 문장마다의 단정 / 출처 구분(T-05-12), 복구 안내 문장(T-05-10), CHANGELOG 복원 항목 여섯의 diff 대조(T-05-14)는 grep 깊이(ASVS L1)로는 가를 수 없다 — `05-VALIDATION.md` Manual-Only 와 `/gsd-verify-work 5` 로 넘긴다. 완화책 자체(날짜 · 범위를 좁힌 안내 · 커밋 번호)는 있다.

감사 메모 (2026-10-14, gap 수정 05-07 ~ 05-09 뒤):

- **둘째로 올라간 범위.** `92d478a..8789cfe`, 25커밋, 20개 파일 (+2,851 / −211줄). 폴더별로 `.planning/phases/05-documentation` 11, `.planning/` 최상위 3, `tool/` 2, `README.md` · `CHANGELOG.md` · `example/README.md` · `lib/riverpod.yaml` 각 1. 05-05 의 마무리 커밋 · 검증 문서 · gap 계획 문서가 함께 올라갔다 — 점검은 범위 전체의 추가된 줄과 `git log -p` 로 했다 (T-05-33). push 는 D-21 대로 실행한 뒤 보고했다 (소유자 결정).
- **원격에 없는 커밋.** `c42dc33` · `c401d82` (05-09 SUMMARY · 메타데이터), `445ce22` (ROADMAP · STATE), `d3ef67c` (검증 감사)와 그 뒤의 검증 문서 커밋들이다.
- 이 등록부의 "확인" 은 HEAD `d3ef67c` 시점이다. 뒤따르는 code review 가 처리 기록을 다시 만들면 T-05-35 의 근거(처리 기록의 행)는 그 커밋 시점(`8789cfe`)으로 읽는다.

감사 메모 (2026-10-14, 2회차 gap 수정 05-10 · 05-11 뒤):

- **셋째로 올라간 범위.** `8789cfe..b8519d4`, 19커밋, 15개 파일 (+2,040 / −375줄, 삭제 0). 폴더별로 `.planning/phases/05-documentation` 9, `.planning/` 최상위 3, `tool/` · `example/` · `README.md` 각 1. 앞 회차의 검증 문서 · 2회차 gap 계획 문서가 함께 올라갔다 — 점검은 범위 전체의 추가된 줄 · 커밋 메시지로 했다 (T-05-49). `.github` · `pubspec.yaml` · `fixtures` · `lib` 은 범위에서 바뀌지 않았다. push 는 D-21 대로 실행한 뒤 보고했다.
- **원격에 없는 커밋.** `b7d8215` (05-11 SUMMARY · 메타데이터)와 그 뒤의 검증 문서 커밋들이다.
- 이 회차 행의 "복제본 rc" 는 `05-VALIDATION.md` 「감사 결과 — 2회차 gap 수정 05-10 · 05-11」 의 실행이다. 뒤따르는 code review 가 처리 기록을 다시 만들면 T-05-48 의 근거는 그 커밋 시점(`b8519d4`)으로 읽는다.

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

## Security Audit 2026-10-14

| Metric | Count |
|---|---|
| Threats found | 40 |
| Closed | 40 |
| Open | 0 |

## Security Audit 2026-10-14

| Metric | Count |
|---|---|
| Threats found | 55 |
| Closed | 55 |
| Open | 0 |
