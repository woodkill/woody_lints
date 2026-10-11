---
phase: "1"
slug: "baseline-and-toolchain"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-11"
---

# Phase 1 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
>
> 출처: `01-01-PLAN.md`, `01-02-PLAN.md`, `01-03-PLAN.md` 의 `<threat_model>` (계획 단계에서 작성됨). ASVS level 1, block on `high`.
> 이 phase 는 실행 코드·네트워크 서비스·비밀 정보가 없다. 해당 범주는 원격 쓰기 접근 제어(V4)와 구성(V5, V14)뿐이다.
> 아래 "확인" 은 2026-10-11 phase 실행 뒤 이 저장소에서 명령을 다시 돌려 얻은 결과다.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| 로컬 git → GitHub origin (쓰기) | 이 phase 에서 유일한 원격 쓰기. 공개 저장소이며 사용 프로젝트 5개가 `ref: main` 으로 읽는다 | tag `v1.3.0` 하나 (공개 정보) |
| GitHub origin → 사용 프로젝트 `pub get` | 사용 프로젝트가 `ref: v1.3.0` 으로 받을 내용이 이 tag 가 가리키는 커밋으로 고정된다 | 패키지 내용 (공개 정보) |
| 정책 문서 → 미래의 판정 | 몇 달 뒤 소유자가 `VERSIONING.md` 만 보고 버전 등급을 정한다 | 문서 (공개 정보) |
| 형식 문서 → CHANGELOG 파서 (Phase 6 REL-03) | 제목 형식이 ` - ` 한 번 규칙을 어기면 일치 검사가 버전을 잘못 읽는다 | 문서 (공개 정보) |
| milestone 브랜치 → `main` / 사용 프로젝트 `ref: main` | `sdk: ^3.13.0` 이 `main` 에 들어가면 Flutter 를 고정하지 않은 사용 프로젝트의 다음 `pub get` 이 깨진다 | `pubspec.yaml` 의 SDK 하한 |
| 저장소 → 임시 사용 프로젝트 (`path:` / `git:`) | pub 은 `path:` 대상에 쓰지 않는다. `git:` 은 공개 저장소를 HTTPS 로 읽기만 한다 | 패키지 내용 (공개 정보) |
| FVM → 저장소 추적 파일 | `fvm use` 가 바꾸는 추적 파일은 둘이어야 한다 | `.fvmrc`, `.vscode/settings.json` |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-01-01 | Tampering | `refs/tags/v1.3.0` → 커밋 | high | mitigate | push 전 4중 점검, push 뒤 `ls-remote` 의 `^{}` 줄 재확인. 확인: `git cat-file -t v1.3.0` = `tag`, `git rev-parse 'v1.3.0^{commit}'` = `90a2736b8d998c84467faf562a0fec720b797eaf` = `origin/main`, `git show v1.3.0:pubspec.yaml` 에 `version: 1.3.0`, `git ls-remote --tags origin` 의 `refs/tags/v1.3.0^{}` = `90a2736…` | closed |
| T-01-02 | Information Disclosure | `git push` (브랜치 `gsd/v2.0-package-rework` 와 `.planning/` 공개) | high | mitigate | push 명령은 `git push origin v1.3.0` 한 줄만. 확인: `git ls-remote --heads origin` 이 `refs/heads/main` 한 줄이고, `git ls-remote origin` 전체가 `HEAD` / `refs/heads/main` / tag 두 줄뿐이다. 작업 브랜치에 upstream 이 없다 | closed |
| T-01-03 | Repudiation | tag 객체 (작성자·날짜·메시지 없는 lightweight tag) | medium | mitigate | `git tag -a` 로만 만든다. 확인: 객체 종류 `tag`, tagger `Woody Moon`, 날짜 2026-10-11, 메시지 두 단락 (`git tag -n99 v1.3.0`) | closed |
| T-01-04 | Tampering | `VERSIONING.md` § 기준표 (D-05 와의 불일치, 행 누락·변형) | medium | mitigate | 기준표 등급 행 수 = 11, 문구 대조. 확인: `01-CONTEXT.md` 43-55행의 표 12줄(머리 1 + 등급 11)이 `VERSIONING.md` 에 글자 그대로 있다 (`grep -qxF` 12/12). 계획이 함께 둔 소유자 읽기 검증은 phase 끝 UAT 에서 한다 | closed |
| T-01-05 | Information Disclosure | `VERSIONING.md` 의 사용 프로젝트 이름(`flutter_starter_kit`) — milestone 브랜치가 공개 저장소에 올라가는 시점에 노출 | low | accept | Accepted Risks Log AR-01 | closed |
| T-01-06 | Denial of Service | `pubspec.yaml` `environment.sdk` 가 `main` 에 들어가 `ref: main` 사용 프로젝트의 `pub get` 파손 | high | mitigate | 커밋은 milestone 브랜치에만, push 없음. 확인: `git rev-parse origin/main` = `90a2736…`, `git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` rc=0, 원격 브랜치는 `main` 하나 | closed |
| T-01-07 | Tampering | `fvm use 3.47.5` 가 예상 밖 추적 파일(`.gitignore` 등)을 바꿈 | low | mitigate | 바뀐 추적 파일이 둘인지 확인한다. 확인: 커밋 `3a15da8` 의 파일이 `.fvmrc`, `.vscode/settings.json` 둘이고 numstat 이 각각 `1 1` 이다. `.gitignore` 는 `90a2736` 과 같다 | closed |
| T-01-08 | Tampering | 임시 사용 프로젝트가 저장소 안에 생기거나 `pubspec.lock` / `.dart_tool/` 이 커밋됨 | low | mitigate | 임시 프로젝트는 `mktemp -d` 로 저장소 밖에 둔다. 확인: `git ls-files pubspec.lock .fvm .dart_tool` 이 비어 있고, `git status --short -- . ':(exclude).planning'` 이 비어 있다 | closed |
| T-01-09 | Information Disclosure | Task 3 의 `git:` 의존 해석이 GitHub 에서 공개 저장소를 clone (`~/.pub-cache/git/`) | low | accept | Accepted Risks Log AR-02 | closed |
| T-01-SC | Tampering | npm/pip/cargo/pub installs (plan 01-01, 01-02, 01-03 공통) | low | accept | Accepted Risks Log AR-03 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-01 | T-01-05 | D-13 이 실측 한 줄 형식에 사용 프로젝트 이름을 두기로 확정했다. 비밀 정보가 아니다. 브랜치를 원격에 올리는 일은 Phase 2 에서 소유자 확인을 받는다 | 계획 단계 처분 (`01-02-PLAN.md` threat_model) | 2026-10-11 |
| AR-02 | T-01-09 | 공개 저장소를 HTTPS 로 읽기만 한다. 비밀 정보·인증 정보가 오가지 않는다 (`.env`·키 파일 없음) | 계획 단계 처분 (`01-03-PLAN.md` threat_model) | 2026-10-11 |
| AR-03 | T-01-SC | 이 phase 는 새 패키지를 설치하지 않았다. 01-01 은 git 명령만, 01-02 는 Markdown 파일 하나, 01-03 의 `dart pub get` 은 이미 `pubspec.yaml` 에 있던 `flutter_lints 6.0.0` / 전이 `lints 6.1.0` 만 해석했다 | 계획 단계 처분 (세 plan 의 threat_model) | 2026-10-11 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-11 | 10 | 10 | 0 | Claude (orchestrator, `/gsd-secure-phase 1`, ASVS L1) |

2026-10-11 감사 메모:

- 위협 목록은 계획 단계에서 작성되었고(`register_authored_at_plan_time: true`), ASVS level 1 이며, 열린 위협이 0 이어서 별도 감사 에이전트 없이 명령 재실행 수준으로 확인했다 (workflow 의 L1 short-circuit).
- 세 SUMMARY 에 `## Threat Flags` 절이 없고, 실행자 셋 모두 새 위협 표면이 없다고 보고했다.
- 이 phase 에서 원격에 쓴 것은 `git push origin v1.3.0` 한 번이며, 소유자가 확인 패널에 `push` 로 답한 뒤(2026-10-11T04:25:38Z) 실행되었다(04:27:13Z). 패널 원문은 `01-01-SUMMARY.md` 에 있다.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-11
