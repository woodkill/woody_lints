---
phase: "3"
slug: "preset-split"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-12"
---

# Phase 3 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
>
> 출처: `03-01-PLAN.md` ~ `03-04-PLAN.md` 의 `<threat_model>` (계획 단계에서 작성됨). ASVS level 1, block on `high`.
> 이 phase 가 바꾼 실행 코드는 로컬 스크립트 `tool/verify.dart` 하나다. 배포 산출물은 `lib/` 의 YAML 다섯이고, 연습용 프로젝트 다섯(`fixtures/`)이 더해졌다. 사용자 입력 · 인증 · 저장 데이터가 없다. 해당 범주는 저장소 오염(정답지 · 배포 파일), 공급망(pub.dev 의 plugin), 원격 쓰기, 공개 범위다.
> 아래 "확인" 은 2026-10-12 phase 실행 뒤(HEAD `7e0962d`) 이 저장소에서 명령을 다시 돌리거나 파일을 직접 읽어 얻은 결과다. `tool/verify.dart` 의 줄 번호는 이 시점의 번호다.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| 배포 파일 → 정답지 (`--update`) | 저장소의 `lib/*.yaml` 상태가 그대로 정답지로 굳는 경로. 깨진 상태도 통과하던 것을 03-01 이 닫았다 | 진단 목록 (생성 파일) |
| 스크립트 → 외부 프로세스 (`dart analyze` 재실행) | 형식 인자 없는 재실행의 stdout · stderr 를 화면에 옮긴다 — 로컬 절대 경로가 섞일 수 있다 | 진단 문자열 |
| 저장소 → 사용 프로젝트 (include 체인) | 옛 주소 → 묶음 → 조각의 3단 include 로 사용 프로젝트가 규칙 · plugin 선언 · exclude 를 받는다. 사용 프로젝트 5개는 `main` 을 따르고 `main` 은 이 phase 에서 바뀌지 않았다 | YAML 설정 |
| `tool/verify.dart` → `build/woody_rule_check/` | 조각 셋의 복사본을 저장소 안에 만들어 분석한다 | 생성 파일 |
| 루트 분석 (커밋 전 린터) | 루트 옵션 파일의 제외 목록이 분석 범위를 정한다 (`example/**`, `fixtures/**`) | Dart 소스 |
| fixture → Analysis Server → pub.dev | plugin 을 쓰는 연습용 프로젝트 넷(`example`, `recommended`, `base_riverpod`, `overrides`)이 각각 `riverpod_lint` 를 받아 컴파일해 실행한다 | plugin 코드 (공개 정보, 로컬 · runner 에서 실행됨) |
| `--update` → 정답지 다섯 | 한 번에 다시 쓰는 경로 | 생성 파일 |
| 로컬 git → GitHub origin (쓰기) | 작업 브랜치 push. 공개 저장소이며 되돌릴 수 없다 | 브랜치 `gsd/v2.0-package-rework` 의 커밋 25개 |
| GitHub runner → pub.dev | runner 가 lock 에 고정된 패키지와 plugin 을 받는다. `GITHUB_TOKEN` 은 읽기 권한뿐 | 패키지 코드 (공개 정보) |
| 선언(`^3.1.9`) → pub.dev 의 새 릴리스 | 범위 지정이라 새 `riverpod_lint` 가 나오면 저장소 변경 없이 풀리는 버전이 바뀐다 (D-01 의 대가) | plugin 버전 |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-03-01 | Tampering | `tool/verify.dart` `--update` — 망가진 배포 파일의 결과가 정답지로 굳음 | high | mitigate | `[2/9]` 통과 조건이 "복사본의 `dart analyze` 가 exit 0 이고 진단 0건" 하나다 (`tool/verify.dart` 894-895 · 961 · 1041행), 깨진 YAML(exit 3, 진단 0건)은 `readParseErrorLines` (873행) 로 원인 줄을 보여 준다; 실패한 단계가 있으면 어느 정답지도 쓰지 않는다 (1513-1514행). 확인: 03-01-T1 의 세 입력을 지금 구조(`codegen.yaml` 5행 따옴표, `base.yaml` 21행 `ruels:`, 겹친 규칙 + 없는 진단 코드)로 다시 일으켜 `--update` 셋 모두 exit 1 · `[2/9]` 실패 · 정답지 hash 불변 (`03-VALIDATION.md` 감사 기록, 변형 rc=0) | closed |
| T-03-02 | Information Disclosure | `readParseErrorLines` 의 출력과 README 의 M15 ~ M17 기록 | medium | mitigate | 재실행 줄은 `scrubPaths(line.trim(), repoRoot)` 를 거친 뒤에만 화면에 낸다 (882행, `scrubPaths` 607행). 확인: `example/README.md` 의 비주석 줄에 `/Users/` 0건, `gho_` · `ghp_` · `github_pat_` 0건; 03-01-T2 의 `<automated>` (기준 커밋만 바꾼 변형) rc=0 | closed |
| T-03-03 | Denial of Service | `readParseErrorLines` 의 재실행 — 깨진 입력마다 `dart analyze` 를 한 번 더 띄움 | low | accept | 수용 (아래 AR-03-01) | closed |
| T-03-04 | Tampering | 조각 셋의 내용 — 손으로 다시 쓰다 사용 프로젝트가 받는 구성이 바뀜 | high | mitigate | 조각은 `sed` 줄 범위로만 잘랐다 (03-02-SUMMARY). 확인: `{ sed -n '1,41p' lib/base.yaml; cat lib/codegen.yaml lib/riverpod.yaml; sed -n '42,47p' lib/base.yaml; }` 가 `git show 90a2736:lib/analysis_options.yaml` 과 다른 줄은 `riverpod.yaml` 10행 `^3.1.3` → `^3.1.9` 한 줄뿐이다 (03-04 의 계획된 변경, 03-04-T1 의 `<automated>` 가 이 한 줄 diff 를 단언 — rc=0); `example/expected_diagnostics.txt` 가 `19ae5ec` 와 같다 | closed |
| T-03-05 | Tampering | 규칙 검사의 사각 — `base.yaml` 밖의 조각에 숨은 deprecated / removed 규칙 | medium | mitigate | `ruleCheckTargets` 가 조각 셋 모두 (`tool/verify.dart` 118-122행), `expectedLibYamls` (133-139행) 집합 확인이 새 YAML 을 잡는다. 확인: 03-02-T1 변형이 `riverpod.yaml` 끝의 `unnecessary_await_in_return` 을 `[2/9]` 실패(`build/woody_rule_check/riverpod/analysis_options.yaml:11 … deprecated_lint`)로, 빈 `lib/_probe_extra.yaml` 을 `[2/9]` 실패로 잡고 되돌림 (rc=0) | closed |
| T-03-06 | Denial of Service | 규칙 검사가 plugin 을 준비함 (묶음 · 별칭을 대상에 넣거나 `plugins:` 를 남긴 경우) | low | mitigate | 대상은 조각 셋뿐이고 묶음 · 별칭은 없다 (118-122행). `stripPlugins` (769행)는 섹션을 뺀 뒤 `^plugins:` 가 남으면 `FormatException` 을 던진다 (774-775행). 확인은 코드 읽기로만 했고 실패 가지는 실행해 보지 않았다 | closed |
| T-03-07 | Information Disclosure | 루트 옵션 파일 · CHANGELOG 주석에 SDK 에 묶인 사실을 굳은 사실로 적음 | low | mitigate | 루트 `analysis_options.yaml` 에 "준비하지 않" · `plugins_in_inner_options` 문자열 0건; CHANGELOG 15행 불릿이 `(Dart 3.13.4)` 를 붙인다. 03-02-T2 변형 rc=0 | closed |
| T-03-08 | Tampering | 정답지 다섯 — `--update` 가 망가진 실행의 결과를 정답지로 굳힘 | high | mitigate | `failed.isNotEmpty` 면 `다른 단계가 실패해 정답지를 쓰지 않았다` 를 찍고 쓰지 않는다 (1513-1514행). 확인: 03-01-T1 변형(세 입력)과 03-03-T1 변형(바뀐 것 없는 `--update` → `바뀐 정답지가 없다`, hash 불변) rc=0; 03-04 Task 1 이 하한 상향 앞뒤로 정답지 다섯의 `git hash-object` 가 같음을 기록 (03-04-SUMMARY) | closed |
| T-03-09 | Spoofing | `recommended` 의 헛통과 — 자기 정답지 없이 `example` 과 견줌 | medium | accept | 수용 (아래 AR-03-02). M18 실측: 묶음에서 `riverpod.yaml` 을 빼면 `[4/9] example` 만 실패하고 `recommended` · `overrides` 는 통과한다 — 이 경우를 잡는 것은 `example` 정답지 하나다 (03-03-SUMMARY; 계획은 `overrides` 도 실패할 것으로 예상했다) | closed |
| T-03-10 | Tampering | `overrides` 의 끄는 설정이 조각의 선언과 어긋남 | medium | mitigate | `[3/9]` 가 `version: {riverpod_lint}` 토큰(`pluginConstraintToken`, 108행)을 `lib/riverpod.yaml` 의 선언으로 바꿔 견준다 (1056행). 확인: 03-04 가 `version: ^3.1.8` 로 바꾼 실행에서 `[3/9]` 만 실패, M19 (`version:` 줄 제거) 에서 `[3/9]` · `[9/9]` 실패 (03-03 · 03-04 SUMMARY); 03-04-T1 변형 rc=0 | closed |
| T-03-11 | Denial of Service | plugin 을 쓰는 fixture 넷의 준비 시간 | low | accept | 수용 (아래 AR-03-03). 실측: 로컬 첫 실행 69초, 재실행 20 ~ 23초 (03-03); runner job 247초 · 213초 (03-04) | closed |
| T-03-12 | Information Disclosure | 새 파일(README 표 · 기록, 정답지 머리 주석, 스크립트 화면)에 로컬 절대 경로 | low | mitigate | 정답지는 상대 경로만 (`normalizeDiagnostics`, 402행), 화면은 `scrubPaths` (1177 · 1191행). 확인: push 한 범위 `0d20c10..79f27e5` 의 추가 줄에서 실제 홈 폴더 경로(`/Users/` 다음에 계정 이름이 오는 꼴) · 임시 폴더 경로 0건 (아래 감사 메모); `example/README.md` 비주석 줄의 `/Users/` 0건 | closed |
| T-03-13 | Tampering | fixture 의 `pubspec.lock` 이 `.gitignore` 에 걸려 빠짐 | medium | mitigate | `.gitignore` 11행 `!fixtures/*/pubspec.lock`. 확인: `git ls-files 'fixtures/*/pubspec.lock'` 5개, 커밋 `91bbeec` (recommended · base_only) 와 `9ed0fe5` (base_riverpod · base_codegen · overrides) 에 lock 다섯이 들어 있다; `git check-ignore -v --no-index fixtures/base_only/pubspec.lock` 이 부정 패턴을 가리킨다 (03-03-T1 변형 rc=0) | closed |
| T-03-14 | Tampering | 잘못된 push (`--force`, `main`, tag, 다른 브랜치, 인자 없는 `git push`) | high | mitigate | 03-04 Task 2 의 `checkpoint:decision` (gate blocking-human) 에서 소유자가 명령 한 줄 · 커밋 24개 · 폴더별 파일 수 · 패턴 검사 결과를 보고 `push` 를 골랐다 (2026-10-12, orchestrator 가 직접 물음). 실행된 publishing 명령은 `git push origin gsd/v2.0-package-rework` 두 번 (`0d20c10..166d0be` 12:12:44Z, `166d0be..79f27e5` 12:18:00Z, 둘 다 fast-forward). 확인 (직접 조회): `git ls-remote --heads origin` 두 줄 — 작업 브랜치 `79f27e5…`, `main` `90a2736…`; tag 는 `v1.3.0` 뿐; 03-04-T3 의 `<automated>` 를 글자 그대로 돌려 rc=0 (PR 0건 포함) | closed |
| T-03-15 | Information Disclosure | 브랜치 push 로 `.planning/` 의 Phase 3 문서와 skill 폴더가 공개됨 | medium | accept | 수용 (아래 AR-03-04). 실제로 올라간 범위는 아래 감사 메모 | closed |
| T-03-16 | Denial of Service | runner 시간이 `timeout-minutes: 10` 에 가까워짐 | low | mitigate | `timeout-minutes: 10` (workflow 26행), `cancel-in-progress: true` (20행). 확인: 두 run 의 job 247초 (run 38247615476) · 213초 (run 38248171220) 가 600초 안이고, 360초 이하라 상한은 올리지 않았다 (권고 10) | closed |
| T-03-17 | Tampering | plugin 버전의 떠다님 — `^3.1.9` 범위 지정 | medium | accept | 수용 (아래 AR-03-05). 드러나게 하는 장치: 화면 셋째 줄 `plugin     riverpod_lint 3.1.9` 와 정답지 머리 주석 | closed |
| T-03-18 | Elevation of Privilege | workflow 의 `GITHUB_TOKEN` 권한 | high | mitigate | `permissions:` 아래 `contents: read` 한 줄 (14-15행). 확인: workflow 에 `write` · `secrets.` · `pull_request_target` 문자열 0건; PyYAML 로 읽은 설정이 `008ea3f` 와 같다 (03-04 가 바꾼 것은 25행 주석뿐) | closed |
| T-03-SC | Tampering | npm/pip/cargo/pub installs | low | accept | 수용 (아래 AR-03-06). 확인: `git diff --quiet 968a5bb -- pubspec.yaml` 통과; fixture 다섯의 `pubspec.yaml` 은 `example/pubspec.yaml` 과 이름 · 설명 · `path` 줄 밖에서 같다 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-03-01 | T-03-03 | 재실행은 exit ≠ 0 이고 진단 0건일 때만, plugin 준비가 없는 복사본 폴더 하나에 대해 한 번이다 (로컬 약 0.5초, spike 013). 정상 경로의 시간은 늘지 않는다 | 계획 단계에서 accept 로 정함 (`03-01-PLAN.md` threat model) | 2026-10-12 |
| AR-03-02 | T-03-09 | "옛 주소와 묶음이 같다" 를 구조로 묶는 설계상 의도다 (D-03). 둘이 같이 깨지는 경우는 `example` 의 정답지가 잡는다 — M18 이 그 모양을 실측해 README 에 적었다 | 계획 단계에서 accept 로 정함 (`03-03-PLAN.md` threat model) | 2026-10-12 |
| AR-03-03 | T-03-11 | `timeout-minutes: 10` 안이고 (실측 247초 · 213초), 동시 실행은 넣지 않는다 (RESEARCH Open Question 2) | 계획 단계에서 accept 로 정함 (`03-03-PLAN.md` threat model) | 2026-10-12 |
| AR-03-04 | T-03-15 | 공개 범위는 02-CONTEXT.md D-08 로 소유자가 수용했다. 이번 push 전 확인 요청이 올라갈 커밋 24개 · 폴더별 파일 118개 · 패턴 검사 9줄을 다시 보여 주었고 소유자가 `push` 를 골랐다 | 소유자 — D-08 + 03-04 Task 2 의 `push` 응답 | 2026-10-12 |
| AR-03-05 | T-03-17 | 정확 고정의 대가(사용 프로젝트마다 plugin 버전을 따로 올려야 함)가 더 크다고 본 소유자 결정이다. 버전이 바뀌면 화면과 정답지 머리 주석에서 드러나고, 그때의 절차는 CONTEXT 의 Deferred 에 있다 | 소유자 — D-01 (`03-CONTEXT.md`) | 2026-10-12 |
| AR-03-06 | T-03-SC | 저장소 `pubspec.yaml` 에 새 의존성을 더하지 않는다. fixture 의 `pubspec.yaml` · lock 은 `example/` 의 복사본이고, runner 가 받는 것은 lock 에 고정된 패키지와 `riverpod_lint` (범위 `^3.1.9`) 뿐이다 (RESEARCH Package Legitimacy Audit) | 계획 단계에서 accept 로 정함 (네 plan 공통) | 2026-10-12 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-12 | 19 | 19 | 0 | orchestrator (`/gsd-execute-phase 3` 의 검증 단계, L1 — 명령 재실행과 파일 대조) |

2026-10-12 감사 메모 (HEAD `7e0962d`):

- 위협 목록은 계획 단계에서 작성되었고(`register_authored_at_plan_time: true`), ASVS level 1 이며, 열린 위협이 0 이어서 별도 감사 에이전트 없이 명령 재실행 수준으로 확인했다 (workflow 의 L1 short-circuit). T-03-SC 는 네 plan 공통 항목이라 한 번만 셌다 — 합계 19 (T-03-01 ~ T-03-18 + T-03-SC). mitigate 13, accept 6.
- 네 SUMMARY 에 `## Threat Flags` 절이 없다 (파일에 "threat" 문자열 자체가 없다).
- 여러 행의 확인은 검증 표 감사(`03-VALIDATION.md` 의 "감사 기록")에서 돌린 `<automated>` 변형에 기댄다. 그 변형은 뒤 plan 이 계획대로 바꾼 줄만 지금 모양으로 바꾼 것이고, plan 파일은 고치지 않았다.
- **T-03-15 의 실제 공개 범위.** push 한 범위 `0d20c10..79f27e5` 는 커밋 25개, 파일 119개다. 확인 요청 때 보인 118개에 두 번째 push 의 `.github/workflows/verify.yml` 하나가 더해졌다.
  - 폴더별 구성:
    - `fixtures` 59
    - `.planning/spikes` 18
    - `.claude/skills` 18
    - `.planning/phases` 10
    - `lib` 5
    - 그 밖에 각 1개: `tool/verify.dart`, `example/README.md`, `CHANGELOG.md`, `analysis_options.yaml`, `.gitignore`, `.github/workflows`, `.planning/STATE.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`
  - 추가 줄의 패턴 검사:
    - `/Users/` 가 든 줄 9개. 모두 계획 · 검증 문서 안의 규칙 문장이나 grep 패턴 문자열이다. 실제 홈 폴더 경로(`/Users/` 다음에 계정 이름이 오는 꼴)와 임시 폴더 경로는 0건이다.
    - 토큰 접두사 패턴 2줄. 둘 다 계획의 `<automated>` 안 `grep -qi 'gho_'` 문자열이고, 토큰 값은 없다.
    - 개인 키 머리말 0건, 이메일 주소 0건(`noreply@anthropic.com` 제외), 커밋 메시지 밖의 세션 주소 0건.
    - 다른 프로젝트 이름(`flutter_starter_kit`)이 든 줄 75개. 주로 `.planning/spikes` 와 skill 폴더의 기록이다. D-08 의 공개 표가 "다른 프로젝트 이름" 을 포함했고, 그 프로젝트를 잰 기록은 건수와 규칙 이름만 남기는 관례를 따른다.
    - 의심 파일 이름(`.env`, 키 파일) 없음.
- 이 phase 에서 원격에 쓴 것은 `git push origin gsd/v2.0-package-rework` 두 번이다. 첫 push 는 소유자 확인 뒤에 했고, 두 번째는 D-09 ("첫 번째만 확인, 같은 phase 안의 같은 브랜치 추가 push 는 묻지 않고 실행 후 보고") 에 따른 것이다. 두 번째 push 뒤에 생긴 커밋(`f1b4ed9` 이후 — 03-04 SUMMARY, 검증 표 감사, 이 문서)은 origin 에 없다. Phase 4 부터의 push 는 다시 묻는다.
- 03-04 가 적은 관찰: `[3/9]` 실패 화면의 "정해진 내용:" 아래 줄은 들여쓰기가 빠진 채 찍힌다. 판정에는 영향이 없는 표시 문제라 위협 목록에 넣지 않고 기록만 한다.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-12 (위협 19 / 닫힘 19 / 열림 0)

## Security Audit 2026-10-12

| Metric | Count |
|---|---|
| Threats found | 19 |
| Closed | 19 |
| Open | 0 |
