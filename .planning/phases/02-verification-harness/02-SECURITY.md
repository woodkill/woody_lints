---
phase: "2"
slug: "verification-harness"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-12"
---

# Phase 2 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
>
> 출처: `02-01-PLAN.md` ~ `02-04-PLAN.md` 의 `<threat_model>` (계획 단계에서 작성됨). ASVS level 1, block on `high`.
> 이 phase 의 실행 코드는 로컬 스크립트 `tool/verify.dart` 하나와 GitHub Actions workflow 하나다. 사용자 입력 · 인증 · 저장 데이터가 없다. 해당 범주는 공급망(pub.dev, 서드파티 action), 원격 쓰기 접근 제어, 구성, 공개 범위다.
> 아래 "확인" 은 2026-10-12 phase 실행 뒤(HEAD `c2d2a50`) 이 저장소에서 명령을 다시 돌리거나 파일을 직접 읽어 얻은 결과다.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| pub.dev → `example/` 의존성 | `dart pub get` 이 `flutter_riverpod`, `flutter_lints`, `lints` 와 전이 의존성을 받는다. `example/pubspec.lock` 으로 고정한다 (D-05) | 패키지 코드 (공개 정보) |
| pub.dev → Analysis Server plugin | `dart analyze` 가 `riverpod_lint` 를 받아 컴파일해 실행한다. 전용 상태 폴더 `.dart_tool/woody_verify/example/` | plugin 코드 (공개 정보, 로컬에서 실행됨) |
| `example/` → 루트 분석 컨텍스트 | 일부러 규칙을 어긴 코드가 커밋 전 린터에 섞이면 안 된다 (`example/**` 제외) | Dart 소스 |
| `tool/verify.dart` 입력 | 인자(`--update`), 환경변수(`CI`, `GITHUB_ACTIONS`, `FLUTTER_ROOT`), 저장소 파일(`.fvmrc`, `lib/analysis_options.yaml`, `example/*`) | 로컬 설정값 |
| 스크립트 → 저장소 파일 시스템 | `build/woody_rule_check/` 생성 · 삭제, `.dart_tool/woody_verify/` 생성, `example/expected_diagnostics.txt` 덮어쓰기(`--update` 만) | 생성 파일 |
| 지워 보기 변경 → 커밋 | 배포 파일을 일부러 깨뜨린 상태가 커밋되면 `main` 병합 때 사용 프로젝트 5개에 전달된다 | `lib/analysis_options.yaml` |
| `example/README.md` → 공개 저장소 | 기록 파일이 push 로 공개된다 (D-08) | 문서 (공개 정보) |
| 로컬 git → GitHub origin (쓰기) | 작업 브랜치 push. 공개 저장소이며 사용 프로젝트 5개가 `main` 을 읽는다 (`main` 은 건드리지 않는다) | 브랜치 `gsd/v2.0-package-rework` 의 커밋 23개 |
| GitHub Actions runner | 서드파티 action 두 개가 checkout 과 Flutter 설치를 하고, 저장소의 스크립트가 pub.dev 에서 패키지와 plugin 을 받아 실행한다 | 저장소 내용 (공개 정보) |
| GitHub → `GITHUB_TOKEN` | workflow 의 권한 (`contents: read` 만) | 읽기 전용 토큰 |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-02-01 | Tampering | `example/pubspec.yaml` 의존성 (pub.dev 에서 받음) | medium | mitigate | `example/pubspec.lock` 커밋 + 스크립트의 `dart pub get --enforce-lockfile`. 확인: `git ls-files --error-unmatch example/pubspec.lock` 통과; `tool/verify.dart` 358-359행이 `--no-example` 과 `--enforce-lockfile` 을 붙인다; `example/pubspec.yaml` 의 직접 의존성은 `flutter` (sdk), `flutter_riverpod`, dev `woody_lints` (`path: ..`) 뿐. 02-02 가 실측으로 찾아 고친 것: 기본값의 루트 `pub get` 은 어긋난 `example/pubspec.lock` 을 다시 써 `--enforce-lockfile` 을 통과시켰다 → `--no-example` 로 막음 (`d707988`) | closed |
| T-02-02 | Tampering | 루트 분석 컨텍스트 (커밋 전 린터 `fvm dart analyze`) | medium | mitigate | 루트 `analysis_options.yaml` 15행 `'example/**'` 제외가 `example/` 과 같은 커밋(`ac5cced`)에 들어갔다. 확인: `git log -S"'example/**'" -- analysis_options.yaml` = `ac5cced`, `example/pubspec.yaml` 을 추가한 커밋도 `ac5cced`; 루트 `fvm dart analyze` → `No issues found!` (exit 0) | closed |
| T-02-03 | Tampering | `build/woody_rule_check/` 가 남아 저장소를 오염 | low | mitigate | 단계 2 의 `try … finally` 삭제(`tool/verify.dart` 665행) + `.gitignore` 18행 `build/`. 확인: 통과 실행 뒤와 문제 규칙을 넣어 실패한 실행 뒤(2026-10-12 감사 재현) 모두 `test ! -e build/woody_rule_check` | closed |
| T-02-04 | Elevation of Privilege | Analysis Server 가 pub.dev 에서 받은 `riverpod_lint` 를 로컬에서 실행 | medium | accept | 수용 (아래 AR-02-01). 드러나게 하는 장치: 실제로 풀린 버전이 화면 셋째 줄과 정답지 머리 주석에 찍힌다 (`plugin     riverpod_lint 3.1.9`, `# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-12`); 전용 상태 폴더로 IDE 와 분리 | closed |
| T-02-05 | Tampering | 스크립트 인자 · 환경변수 (잘못된 입력으로 엉뚱한 동작) | low | mitigate | 허용 인자는 `--update` 하나, 그 밖은 exit 64 (`tool/verify.dart` 906-910행). `Process.run` 세 곳(355 · 445 · 599행)이 모두 실행 파일 + 인자 배열이고 `runInShell` · 셸 문자열이 없다. `stripPlugins` (561-570행)는 섹션을 못 찾으면 `FormatException`. `FLUTTER_ROOT` 는 그 SDK 의 `dartSdkVersion` 이 실행 중인 Dart 와 같을 때만 받아들인다 (296행). 확인: `fvm dart run tool/verify.dart --bogus` → 64, `CI=true … --update` → 64 (감사 재실행). `stripPlugins` 의 실패 가지와 `FLUTTER_ROOT` 불일치 가지는 코드로만 확인했고 실행해 보지 않았다 | closed |
| T-02-06 | Denial of Service | plugin 준비가 멈춤 (pub 서버 무응답) | low | accept | 수용 (아래 AR-02-02). CI 쪽 상한은 `.github/workflows/verify.yml` 24행 `timeout-minutes: 10` | closed |
| T-02-07 | Tampering | `lib/analysis_options.yaml`, `example/analysis_options.yaml`, `.fvmrc` 의 임시 변경이 남아 커밋됨 | high | mitigate | 변경 하나마다 그 경로만 되돌리고 확인. 확인 (HEAD `c2d2a50`): `git diff --quiet 90a2736 -- lib` 통과, `example/analysis_options.yaml` 은 include 한 줄, `.fvmrc` 는 `3.47.5`, `lib/` 의 `.dart` 0개, `git status --short` 에 `lib` · `example` · `.fvmrc` · `tool` 변경 없음, 02-03-T1 의 `<automated>` rc=0. 02-03 의 task 커밋 `2a9725e` 에 든 파일은 `example/README.md` 와 `CHANGELOG.md` 둘뿐이다. 감사 때 다시 일으킨 세 건도 같은 방식으로 되돌렸다 | closed |
| T-02-08 | Information Disclosure | `example/README.md` 기록에 로컬 절대 경로 · 토큰 | medium | mitigate | 화면 출력은 상대 경로이고 다른 도구의 stderr 는 저장소 절대 경로를 `<repo>` 로 가린다 (`tool/verify.dart` 426-431행). 확인: `example/README.md` 와 `CHANGELOG.md` 에서 홈 폴더 경로 · 세션 주소 · 토큰 접두사 · 이메일 · 다른 프로젝트 이름(`flutter_starter_kit`)을 `grep` 으로 찾아 0건; 02-03-T2 의 `<automated>` rc=0 | closed |
| T-02-09 | Tampering | 서드파티 action 공급망 (`actions/checkout`, `subosito/flutter-action`) | medium | mitigate | workflow 의 `uses:` 는 `actions/checkout@v7`, `subosito/flutter-action@v2` 둘뿐 (26 · 29행). `permissions: contents: read`. 02-04 가 2026-10-11T17:01:58Z 에 릴리스와 major tag 의 커밋을 다시 조회했다 (`02-04-SUMMARY.md`). SHA 고정은 하지 않았다 — 계획이 major tag 로 정했다 | closed |
| T-02-10 | Elevation of Privilege | workflow 의 `GITHUB_TOKEN` 권한 | high | mitigate | `permissions:` 아래에 `contents: read` 한 줄만 있다 (12-13행). 확인: workflow 파일에 `write`, `secrets.`, `pull_request_target` 문자열이 없다; 02-04-T1 의 `<automated>` rc=0 | closed |
| T-02-11 | Denial of Service | runner 시간 소모 (멈춘 plugin 준비, 겹치는 실행) | low | mitigate | `timeout-minutes: 10` (24행), `cancel-in-progress: true` (18행). 실제 job 은 1분 54초 (run 38158088016) | closed |
| T-02-12 | Information Disclosure | 브랜치 push 로 `.planning/`, `.claude/CLAUDE.md`, 새 기록 파일이 공개됨 | medium | accept | 수용 (아래 AR-02-03). 확인: 올라간 범위 `1ed61cd..1f06c55` 의 추가 줄에서 토큰 · 개인 키 패턴 0건, 이메일 주소 0건, 의심 파일 이름(`.env`, 키 파일) 없음. **계획의 Component 문구에 열거되지 않은 폴더가 함께 올라갔다** — `.claude/skills/spike-findings-woody-lints/` 58개 파일 (아래 감사 메모) | closed |
| T-02-13 | Tampering | 잘못된 push (`--force`, `main`, tag, 다른 브랜치, 인자 없는 `git push`) | high | mitigate | 실행된 publishing 명령은 `git push origin gsd/v2.0-package-rework` 한 줄, 한 번 (`1ed61cd..1f06c55`, fast-forward). 확인 (직접 조회, 2026-10-12): `git ls-remote --heads origin` 이 두 줄 — 작업 브랜치 `1f06c55…`, `main` `90a2736…`; `git ls-remote --tags origin` 은 `v1.3.0` 뿐; `gh pr list --state all` 0건; 02-04-T2 의 `<automated>` rc=0 | closed |
| T-02-SC | Tampering | npm/pip/cargo/pub installs | low | accept | 수용 (아래 AR-02-04). 확인: `git diff --quiet 968a5bb -- pubspec.yaml` 통과 (저장소 `pubspec.yaml` 에 새 의존성 없음) | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-02-01 | T-02-04 | `riverpod_lint` 는 1.3.0 이 이미 선언한 plugin 이고 사용 프로젝트 5개가 같은 코드를 실행한다. 버전이 바뀌면 화면과 정답지 머리 주석에서 드러난다. 정확한 버전 고정은 Phase 3 (D6) 의 결정이다 | 계획 단계에서 accept 로 정함 (`02-02-PLAN.md` threat model) | 2026-10-11 |
| AR-02-02 | T-02-06 | 로컬은 Ctrl-C 로 끊어도 상태 폴더가 깨지지 않고 (spike 008), CI 는 `timeout-minutes: 10` 이 막는다. 닿지 못하는 경우는 약 30초 뒤 실패로 끝난다 (spike 002) | 계획 단계에서 accept 로 정함 (`02-02-PLAN.md` threat model) | 2026-10-11 |
| AR-02-03 | T-02-12 | 소유자가 공개될 내용의 표(`.planning/` 파일, 다른 프로젝트 이름, 로컬 절대 경로, 커밋 메시지의 Claude 세션 주소, 비밀번호 · 토큰 없음)를 보고 "그대로 올린다" 를 골랐다. 한 번 올린 것은 지워도 흔적이 남을 수 있다는 점을 들은 뒤의 선택이다 | 소유자 — D-08 (`02-CONTEXT.md` 71행, `02-DISCUSSION-LOG.md` 93-107행) | 2026-10-11 |
| AR-02-04 | T-02-SC | 저장소 `pubspec.yaml` 에 새 의존성을 더하지 않는다. `example/` 이 받는 패키지와 Analysis Server 가 받는 `riverpod_lint` 는 조사 문서의 Package Legitimacy Audit 에서 모두 OK | 계획 단계에서 accept 로 정함 (네 plan 공통) | 2026-10-11 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-12 | 14 | 14 | 0 | orchestrator (`/gsd-execute-phase 2` 의 검증 단계, L1 — 명령 재실행과 파일 대조) |

2026-10-12 감사 메모:

- 위협 목록은 계획 단계에서 작성되었고(`register_authored_at_plan_time: true`), ASVS level 1 이며, 열린 위협이 0 이어서 별도 감사 에이전트 없이 명령 재실행 수준으로 확인했다 (workflow 의 L1 short-circuit). T-02-SC 는 네 plan 공통 항목이라 한 번만 셌다 — 합계 14 (T-02-01 ~ T-02-13 + T-02-SC).
- 네 SUMMARY 에 `## Threat Flags` 절이 없다. 02-01 · 02-02 · 02-03 은 "계획의 threat model 에 없는 새 표면은 만들지 않았다", 02-04 는 "새로 생긴 표면은 계획의 threat model 이 든 것뿐이다" 라고 보고했다.
- **T-02-12 의 실제 공개 범위.** push 한 범위 `1ed61cd..1f06c55` (커밋 23개, 파일 107개)의 구성: `.claude/skills` 58, `.planning/spikes` 17, `example` 12, `.planning/phases` 11, 그 밖에 각 1개 (`.claude/CLAUDE.md`, `.github/workflows`, `.gitignore`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `analysis_options.yaml`, `CHANGELOG.md`, `tool`). `.claude/skills/spike-findings-woody-lints/` 는 D-08 논의 뒤 spike wrap-up 이 만든 폴더라 계획의 Component 문구와 논의 때 보인 표에 이름이 없다 (Dart 28, Markdown 13, YAML 10, 스크립트 · 기타 7). D-08 의 결정 문구가 "작업 브랜치를 `.planning/` 과 함께 **그대로** 올린다" 이므로 브랜치 전체가 수용 범위라고 보았다 — 이것은 감사자의 해석이고, 소유자가 이 폴더를 따로 보고 확인한 기록은 없다. 내용 종류는 논의 때의 표와 같다: 이 범위의 추가 줄 가운데 `/Users/` 가 든 줄은 4줄(`02-RESEARCH.md` 2, `02-03-PLAN.md` 1, `02-VALIDATION.md` 1 — 뒤의 둘은 검사 명령의 문자열이다), 다른 프로젝트 이름이 든 파일은 4개, 토큰 · 개인 키 패턴과 이메일 주소는 0건이다. phase 보고에서 소유자에게 알린다.
- 이 phase 에서 원격에 쓴 것은 `git push origin gsd/v2.0-package-rework` 한 번이다 (2026-10-11T17:04:05Z). 첫 push 는 spike 006 때 소유자 확인을 받았고, 이번 것은 D-09 ("첫 번째만 확인, 이 phase 안의 같은 브랜치 추가 push 는 묻지 않고 실행 후 보고") 에 따른 것이다. push 뒤에 생긴 커밋(`da31324` 이후)은 origin 에 없다. Phase 3 부터의 push 는 D-09 범위 밖이다.
- 02-04 가 적은 관찰 하나: `actions/checkout` 은 기본값대로 `persist-credentials: true` 로 돌았다 — 읽기 전용 토큰이 job 이 끝날 때까지 runner 의 git 설정에 남는다. 그 뒤에 도는 서드파티 step 은 `flutter-action` 하나이고 토큰 권한은 공개 저장소의 `contents: read` 다. 위협 목록에 없는 항목이라 상태를 매기지 않고 기록만 한다.
- 02-04 가 적은 관찰 또 하나: workflow 의 `push:` 에 필터가 없어 tag 를 올려도 이 workflow 가 돈다 (주석은 "tag 트리거는 Phase 6" 이라고 적혀 있다). 권한이 읽기뿐이라 보안상 영향은 없고, 주석 문구는 Phase 6 (REL-03) 에서 정리할 일이다.
- GitHub 가 run 에 붙인 예고: `ubuntu-latest` 가 2026-10-19 부터 Ubuntu 26 으로 옮겨 간다. 보안 항목은 아니지만 그 뒤 CI 가 처음 실패하면 runner 이미지 변경부터 본다.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-12 (위협 14 / 닫힘 14 / 열림 0)

## Security Audit 2026-10-11

| Metric | Count |
|---|---|
| Threats found | 14 |
| Closed | 14 |
| Open | 0 |
