# Phase 1: Baseline and Toolchain - Research

**Researched:** 2026-10-11
**Domain:** Git tag 릴리스 기준점, FVM 툴체인 고정, pub SDK 제약(constraint), 버전 정책 / CHANGELOG 문서
**Confidence:** HIGH — 계획에 필요한 도구 동작은 전부 이 머신에서 스크래치 디렉터리에 저장소 복사본·클론을 만들어 직접 실행해 확인했다. 저장소 안의 파일은 이 문서 하나만 만들었고, tag·commit·branch·push 는 실제 저장소에서 하지 않았다 (리허설은 스크래치의 가짜 원격에 했다).

**근거 표기**

| 표기 | 뜻 |
|------|-----|
| `[VERIFIED: local <경로/명령>]` | 2026-10-11 이 머신에서 직접 실행하거나 파일을 열어 확인. 출력은 본문에 그대로 붙였다 |
| `[CITED: url]` | 공식 문서 / 원본 소스에서 읽음 |
| `[ASSUMED]` | 확인하지 않은 추정. "Assumptions Log" 에 모았다 |

실험은 모두 `/private/tmp/claude-501/-Users-woody-dv-woody-woody-lints/6408338e-0e0c-4b43-be80-84e7ddc08d26/scratchpad/research-p1/` 아래에서 했다 (`pkg-copy/` 저장소 복사본, `repo-clone/` + `fake-remote.git` tag 리허설, `consumer/`, `consumer-git/` 가짜 사용 프로젝트).

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### 이전에 확정되어 그대로 따르는 것

다시 논의하지 않았다. 출처는 ROADMAP.md / REQUIREMENTS.md / PROJECT.md 다.

- `.fvmrc` 는 3.47.5 다 (3.47.7 아님). 실측 대상 `flutter_starter_kit` 과 같은 버전이어야 한다
- SDK 하한은 `^3.13.0` 이고 milestone 브랜치에만 둔다. `main` 의 `lib/` 와 `pubspec.yaml` 은 릴리스 전까지 1.3.0 이다
- `v1.3.0` 은 commit `90a2736` 에 annotated tag 로 붙인다. push 한 tag 는 옮기지 않는다
- 원격에 남는 작업은 실행 시점에 소유자의 명시적 확인을 받는다
- 문서는 한국어로 쓰고 규칙명·키는 영어 원문을 쓴다

#### 버전 정책 (ROADMAP 의 D8 확정)

- **D-01:** 판단 축은 "이 버전을 받는 쪽이 겪는 일"이다. semver 범위가 기계적으로 평가되지 않으므로(사용 프로젝트는 정확한 tag 하나에 고정한다) 버전 번호는 사람에게 보내는 신호다.
- **D-02:** 규칙 추가는 **minor** 다. 조건으로, CHANGELOG 의 해당 버전에 "새로 생기는 경고" 칸을 반드시 둔다. major 는 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하는 변경에만 쓴다. (Dart 공식 `lints` / `flutter_lints` 는 규칙 추가를 major 로 내지만, 그쪽은 caret 범위로 자동 유입되는 구조라 사정이 다르다고 보았다.)
- **D-03:** 규칙 제거도 **minor** 다. "규칙을 넣든 빼든 규칙 목록이 바뀌면 minor" 로 통일한다. patch 는 규칙 목록이 그대로인 변경에만 쓴다. `unnecessary_ignore` 채택 여부(Phase 4)와 무관하게 성립한다.
  - 조사 문서 두 편의 안을 모두 대체한다. `research/ARCHITECTURE.md` 는 "규칙 제거 = PATCH", `research/PITFALLS.md` 는 "PATCH, 단 `unnecessary_ignore` 채택 시 MINOR" 였다. 통일안은 조사 결과가 아니라 논의 중 Claude 가 제안한 것이고, 그 점을 밝힌 뒤 소유자가 골랐다.
- **D-04:** 규칙의 심각도를 info 에서 warning 이상으로 올리는 변경은 **major** 다. 받는 프로젝트의 `dart analyze` 가 통과에서 실패로 바뀔 수 있다. (`research/ARCHITECTURE.md` 의 "심각도 상향 = MINOR" 를 대체한다.) 이번 릴리스에는 해당 변경이 없다.
- **D-05:** 조사 문서 두 편을 합친 기준표는 아래 한 장이다. VERSIONING.md 의 기준표는 이 내용을 그대로 담는다.

  | 변경 | 등급 | 받는 쪽이 겪는 일 |
  |------|------|-------------------|
  | 기존 URI 를 없애거나 이름·뜻을 바꿈 | major | 설정 파일을 고쳐야 한다 |
  | 지원 SDK 하한을 올림 | major | SDK 를 올려야 한다 |
  | `flutter_lints` 를 다음 major 로 올림 (6 → 7) | major | 기반 규칙이 통째로 바뀐다 |
  | `riverpod_lint` 를 다음 major 로 올림 (3 → 4) | major | plugin 규칙이 통째로 바뀐다 |
  | 규칙 심각도를 warning 이상으로 올림 | major | 자동 검사가 막힐 수 있다 |
  | 규칙을 넣거나 뺌 | minor | 경고가 달라진다. CHANGELOG 를 확인한다 |
  | `analyzer.exclude` / `analyzer.errors` 설정을 바꿈 | minor | 경고가 달라질 수 있다 |
  | 새 프리셋 파일을 추가함 | minor | 고르지 않으면 영향이 없다 |
  | `riverpod_lint` 하한을 같은 major 안에서 올림 (`^3.1.3` → `^3.1.9`) | minor | plugin 경고가 달라질 수 있다 |
  | 주석·README·CHANGELOG·사유 문구만 고침 | patch | 달라지는 것이 없다 |
  | 저장소 안쪽만 바뀜 (`.fvmrc`, CI, `example/`, 검증 스크립트) | 올리지 않음 | 받는 것이 없다 |

  - "exclude / errors 설정 = minor" 와 "저장소 안쪽 = 올리지 않음" 두 줄은 조사 문서에 없던 것을 Claude 가 덧붙였고, 그 점을 밝힌 뒤 소유자가 표 전체를 확정했다.
- **D-06:** 다음 릴리스는 **2.0.0** 이다. 이번 릴리스에 들어가는 변경 중 가장 큰 등급이 SDK 하한 상향(major)이다.
- **D-07:** milestone 브랜치의 `pubspec.yaml` `version` 을 이 phase 에서 `2.0.0-dev` 로 바꾼다. `sdk` 하한을 올리는 변경과 함께 한다. 릴리스 때 `-dev` 를 뗀다 (Phase 6). `main` 의 `version` 은 1.3.0 그대로다.
  - 이유: 하한을 올린 순간부터 "version 은 1.3.0 인데 내용은 1.3.0 이 아닌" 상태가 릴리스까지 이어지는 것을 피한다. 완성 전에 tag 를 붙이려 하면 Phase 6 의 일치 검사(REL-03)가 `-dev` 때문에 막는다.

#### 기준 문서의 위치와 구성

- **D-08:** 버전 정책과 CHANGELOG 형식을 저장소 루트의 **`VERSIONING.md`** 한 파일에 함께 적는다. milestone 브랜치에 둔다.
  - 고르지 않은 안: README 의 한 절(Phase 5 재작성 때 두 번 손본다), CHANGELOG 머리말(변경 기록이 아래로 밀린다), `docs/` 폴더, `CONTRIBUTING.md`.
- **D-09:** VERSIONING.md 는 세 부분으로 쓴다.
  1. **판정 순서** — 위에서부터 물어 내려가다 처음 "예"가 나오는 곳에서 멈춘다.
     - ① 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하나, 자동 검사가 막힐 수 있나 → major
     - ② 규칙 목록이나 exclude / errors 설정, plugin 버전이 바뀌었나 → minor
     - ③ `lib/` 나 `pubspec.yaml` 이 바뀌긴 했나 → patch
     - ④ 아니면 → 버전을 올리지 않는다
  2. **기준표** — D-05 의 표
  3. **실제 사례 대입 예시** — 최소한 1.3.0("그때까지 로드되지 않던 `riverpod_lint` 를 처음 켰다 → minor")과 2.0.0("SDK 하한을 올렸다 → major")
- **D-10:** VERSIONING.md 는 쉬운 말을 함께 적는다. "맨 앞자리(major)", "가운데 자리(minor)", "맨 뒷자리(patch)" 처럼 풀이를 병기한다. 독자는 몇 달 뒤의 소유자 본인이다.
- **D-11:** README 는 이 phase 에서 건드리지 않는다. VERSIONING.md 로 가는 링크나 요약은 Phase 5 재작성 때 넣는다.

#### CHANGELOG 항목 형식 (BASE-04)

- **D-12:** 항목의 뼈대는 "필수 두 칸 + 해당 칸만" 이다.
  - 제목: `## X.Y.Z - YYYY-MM-DD`
  - 제목 바로 아래 한 줄: `지원 SDK: …` — **항상** 적는다. 바뀌지 않았으면 `(변경 없음)`, 바뀌었으면 `(이전: …)` 을 붙인다
  - `### 올리기 전에` — 받는 쪽이 고쳐야 하는 것. 해당할 때만
  - `### 추가한 규칙` — 해당할 때만. 불릿 형식은 `` `rule_name` — 켠 이유 한 줄 ``
  - `### 뺀 규칙` — 해당할 때만. 불릿 형식은 `` `rule_name` — 뺀 이유 한 줄 ``
  - `### 그 밖의 변경` — 해당할 때만
  - `### 새로 생기는 경고` — **항상** 적는다. 없으면 `없음`
- **D-13:** "새로 생기는 경고" 는 4열 표와 그 아래 실측 조건 한 줄로 쓴다.
  - 열: `규칙` / `강도` / `실측` / `dart fix`
  - `dart fix` 열은 가능 여부가 아니라 고쳐지는 건수다
  - 표 아래 한 줄: `실측: flutter_starter_kit (Dart 파일 N개), Flutter X.Y.Z, YYYY-MM-DD`
  - 자세한 회차 기록은 Phase 4 의 근거 문서에 둔다. CHANGELOG 만 읽어도 숫자의 뜻이 보이게 하는 것이 이 한 줄의 목적이다
- **D-14:** 이 phase 에서 CHANGELOG 맨 위에 **`## 2.0.0 - 미출시`** 항목을 만든다. 날짜 자리에 "미출시" 를 적고 릴리스 때 날짜로 바꾼다. Phase 1 이 적는 내용은 다음과 같다.
  - `지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)`
  - `### 올리기 전에` — Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다
  - `### 새로 생기는 경고` — Phase 4 실측 후 채운다는 자리 표시
- **D-15:** 이후 phase 는 자기 변경을 같은 2.0.0 항목에 적어 나간다 (Phase 3 의 프리셋 분리, Phase 4 의 규칙 변경과 실측 표). Phase 5 의 DOCS-07 / DOCS-09 는 처음부터 쓰는 일이 아니라 다듬고 빠진 것을 점검하는 일이 된다.
  - 로드맵 원안("Phase 1 은 형식만, 항목은 Phase 5 에서")에서 바뀐 부분이다. 이유: 변경과 기록이 같은 커밋에 남고, 형식을 실제로 써 보므로 허점이 Phase 4 전에 드러난다.
- **D-16:** 새 형식은 2.0.0 부터 적용한다. 지금 있는 1.3.0 / 1.0.0 항목은 불릿 형식 그대로 두고 이 phase 에서 고치지 않는다. 실측 수치가 없어 필수 칸을 채울 수 없다. 1.0.0 과 1.3.0 사이 보완은 Phase 5 (DOCS-08) 의 일이다.

#### `v1.3.0` tag 와 원격 작업 (ROADMAP 의 D4 확정)

- **D-17:** 이 phase 에서 원격에 올리는 것은 **`v1.3.0` tag 하나뿐**이다. milestone 브랜치는 올리지 않는다 (Phase 2 에서 CI 를 돌릴 때 다시 확인받는다). 로컬 `main` 의 `.planning/` 커밋 7개도 올리지 않는다.
- **D-18:** tag 는 이 phase 의 **첫 작업**이다. 작업 브랜치에서 무엇이든 바꾸기 전에 한다. 순서:
  1. 로컬에서 `90a2736` 에 annotated tag `v1.3.0` 을 만든다
  2. 점검한다 — tag 가 `90a2736` 을 가리키고, 그 커밋이 `origin/main` 과 같으며, `git show v1.3.0:pubspec.yaml` 의 version 이 1.3.0 이다
  3. 소유자의 확인을 받는다
  4. tag 이름만 지정해 push 한다
  5. `git ls-remote --tags origin` 으로 원격에 보이는지 확인한다

  — **Reversibility:** one-way — push 한 tag 는 옮기지 않기로 했고, 사용 프로젝트의 `pubspec.lock` 이 tag 가 가리키는 commit 을 `resolved-ref` 로 기록한다. 잘못 붙이면 이름을 다시 쓸 수 없다.
- **D-19:** 확인을 받은 뒤 push 명령은 **Claude(실행 에이전트)가 실행**하고 결과를 확인해 보고한다. 확인 요청에는 올릴 것의 목록, 실행할 명령, 되돌릴 수 없다는 점을 쉬운 말로 적는다.
- **D-20:** push 는 tag 이름 하나만 지정한다 (`git push origin v1.3.0`). `--tags`, `--follow-tags`, 브랜치를 함께 올리는 형태는 쓰지 않는다.

### Claude's Discretion

소유자에게 묻지 않고 조사·계획 단계에 맡긴 것.

- tag 메시지의 문구. 논의에서 제시한 기본값은 한국어 두 줄이다: "woody_lints 1.3.0" / "2.0.0 작업 전 기준점. Dart 3.13 미만 프로젝트는 이 tag 에 머문다"
- VERSIONING.md 의 절 순서, 문장, 예시 개수 (D-09 의 세 부분은 반드시 들어간다)
- `fvm use 3.47.5` 의 실행 방식. Flutter 프로젝트가 아닌 저장소 루트에서 `--force` 가 필요한지는 확인된 적이 없다
- `.vscode/settings.json` 의 SDK 경로를 맞추는 방법
- "Dart 3.13 미만에서 `pub get` 이 실패한다"를 확인하는 방법과 그 증거를 남길 자리. 로컬 FVM 에 3.41.2 / 3.41.4 / 3.41.9 가 설치되어 있다
- `sdk` 하한 변경, `version` 변경, CHANGELOG 항목 추가를 몇 개의 커밋으로 나눌지
- GitHub 의 Releases 페이지는 만들지 않는다. 요구사항(REL-01)은 tag 까지다

### Deferred Ideas (OUT OF SCOPE)

논의 중에 나왔지만 다른 phase 의 일인 것.

- **milestone 브랜치를 올리면 `.planning/` 이 공개된다** — 이 저장소는 공개 저장소다. Phase 2 에서 CI 를 위해 브랜치 push 확인을 받을 때 이 점을 소유자에게 다시 알린다. 민감 정보는 없고 조사 내용, 로드맵, 사용 프로젝트 이름이 들어 있다
- **일치 검사가 "미출시" 를 거부하게 할지** — CHANGELOG 최상단 제목의 날짜 자리가 "미출시" 인 채로 tag 를 붙이면 실패하도록 REL-03 검사를 넓힐 수 있다. Phase 6 계획 때 검토한다
- **릴리스 절차 문서** — 번호를 붙인 단계(버전·CHANGELOG 커밋 → CI 확인 → annotated tag → push → 확인 → smoke test)를 어디에 둘지. VERSIONING.md 에 덧붙일 수도 있다. Phase 6 에서 정한다
- **Phase 4 근거 문서의 자리** — 규칙 근거 문서(DOCS-11)와 미채택 목록(RULES-08)을 루트에 둘지 `docs/` 를 만들지. Phase 4 에서 정한다
- **옛 CHANGELOG 제목에 날짜 붙이기** — 1.3.0 이전 항목의 날짜는 git 이력에서 알 수 있다. Phase 5 의 DOCS-08 에서 검토한다
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| BASE-01 | 저장소가 고정하는 SDK 가 Flutter 3.47.5 / Dart 3.13.4 다 (`.fvmrc`, `.vscode/settings.json`) | § "조사 1·2 — `fvm use 3.47.5` 실측": `--force` 없이 성공, `.fvmrc` 와 `.vscode/settings.json` 두 파일만 3.47.5 로 바뀜. 검증 명령은 § Validation Architecture |
| BASE-02 | `pubspec.yaml` 의 SDK 하한이 `^3.13.0` 이어서, 지원하지 않는 SDK 를 쓰는 프로젝트는 `pub get` 단계에서 버전 불일치로 명확히 실패한다 | § "조사 3 — Dart 3.13 미만 `pub get` 실패 확인 절차": 3.41.2 / 3.41.4 / 3.41.9 세 SDK 에서 `path:` 와 `git:` 두 방식 모두 실패하는 정확한 오류 문구와 재현 절차. § "조사 4" 의 `origin/main` 불변 검사 명령 |
| BASE-03 | 어떤 변경이 major / minor / patch 인지 정한 버전 정책이 문서로 남아 있다 | § "VERSIONING.md 작성 재료": D-09 세 부분의 뼈대, git 이력에서 뽑은 실제 사례 11건(버전별 날짜·내용), 쉬운 말 풀이 문구 |
| BASE-04 | CHANGELOG 항목의 형식이 정해져 있다 (추가·삭제 규칙, 지원 SDK, 새로 생기는 진단) | § "CHANGELOG 2.0.0 항목": D-12~D-14 를 그대로 옮긴 초안과 REL-03 파싱 규칙(` - ` 앞 토큰), 형식 설명이 VERSIONING.md 에 들어가는 위치 |
| REL-01 | 1.3.0 내용의 커밋에 `v1.3.0` tag 가 있고 원격에 올라가 있다 | § "조사 5 — tag 사실 확인과 명령": `90a2736` = `origin/main`, `version: 1.3.0`, tag 0개 확인. annotated tag 생성·점검·push·확인 명령을 스크래치 클론에서 리허설한 출력 포함 |
</phase_requirements>

---

## Summary

이 phase 는 코드가 아니라 **저장소의 출발선**을 만든다: (1) 지금 배포된 1.3.0 에 이름표(`v1.3.0` tag)를 붙여 GitHub 에 올리고, (2) 저장소가 쓰는 Flutter 를 3.47.5 로 올리고, (3) milestone 브랜치의 `pubspec.yaml` 에 "Dart 3.13 이상만" 이라는 하한을 적고 `version` 을 `2.0.0-dev` 로 바꾸고, (4) 버전 번호를 정하는 규칙과 CHANGELOG 쓰는 법을 `VERSIONING.md` 에 적고, (5) CHANGELOG 맨 위에 `## 2.0.0 - 미출시` 자리를 만든다. 무엇을 할지는 CONTEXT.md 가 D-01~D-20 으로 전부 정했고, 이 조사는 "어떻게 실행하고 어떻게 확인하는가"의 빈칸을 이 머신에서 실측해 채웠다.

실측 결과 요약: `fvm use 3.47.5` 는 Flutter 프로젝트가 아닌 이 저장소 루트에서도 **`--force` 없이** 성공하며, `.fvmrc` 와 `.vscode/settings.json` 을 함께 3.47.5 로 고쳐 준다 (손으로 고칠 것이 없다). `sdk: ^3.13.0` 으로 올린 패키지를 `path:` 또는 `git:` 로 의존하는 프로젝트는 Dart 3.11.x (Flutter 3.41.2 / 3.41.4 / 3.41.9) 에서 `pub get` 이 종료 코드 1 과 `Because … depends on woody_lints from path which requires SDK version ^3.13.0, version solving failed.` 로 끝나고, 같은 프로젝트가 `ref: v1.3.0` 을 가리키면 3.41.9 에서도 정상 해석된다 — CHANGELOG 의 "올리기 전에" 안내가 실제로 성립한다. `version: 2.0.0-dev` 는 pub 이 받아들이는 pre-release 형식이고, `ref:` 로 받는 사용 프로젝트에는 lockfile 의 `version: "2.0.0-dev"` 기록 외에 부작용이 없다. tag 는 `git tag -a v1.3.0 90a2736 -m … -m …` 으로 만들고 `git push origin v1.3.0` 으로 그 이름 하나만 올린다; 리허설에서 `git ls-remote --tags origin` 은 annotated tag 를 두 줄(tag 객체 + `^{}` 커밋)로 보여 주었다.

**Primary recommendation:** 작업 순서는 D-18 대로 tag 먼저. `fvm use 3.47.5` 를 그대로 실행하고 결과 diff 가 두 파일뿐임을 확인한다. `sdk` 하한·`version`·CHANGELOG 2.0.0 항목은 한 커밋(`feat!:`)으로, VERSIONING.md 는 그 앞에 별도 `docs:` 커밋으로, 툴체인 두 파일은 `chore:` 커밋으로 나눈다 (3 커밋). BASE-02 의 "3.13 미만에서 실패" 증거는 아래 절차를 실행 시점에 다시 돌려 그 출력을 plan SUMMARY 에 그대로 붙인다.

## Architectural Responsibility Map

이 phase 에는 실행 코드 계층이 없다. "tier" 를 저장소 안의 책임 위치로 읽는다.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 1.3.0 기준점 (`v1.3.0` tag) | Git 원격 (`origin` refs/tags) | 로컬 git | 사용 프로젝트의 `ref: v1.3.0` 이 원격 tag 를 읽는다. 로컬 tag 는 중간 산물 |
| 저장소 SDK 고정 | `.fvmrc` (FVM) | `.vscode/settings.json`, `.fvm/` (gitignore) | FVM 이 `.fvmrc` 를 읽고 나머지를 파생시킨다. CI 도 `.fvmrc` 를 읽을 예정(Phase 2) |
| 지원 SDK 하한 강제 | `pubspec.yaml` `environment.sdk` | 사용 프로젝트의 `pub get` | 하한 검사는 pub 의 version solver 가 수행한다. 이 저장소는 선언만 한다 |
| 버전 정책 / CHANGELOG 형식 | `VERSIONING.md` (저장소 루트) | `CHANGELOG.md` 2.0.0 항목 (형식의 첫 적용) | D-08. Phase 6 의 REL-03 검사가 CHANGELOG 최상단 제목을 읽는다 |
| `main` 불변 보장 | 브랜치 전략 (milestone 브랜치) | 검증 명령 (`git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml`) | 이 phase 는 `main` 에 커밋하지 않고 push 도 tag 만 한다 |

## Standard Stack

이 phase 는 새 패키지를 설치하지 않는다. 쓰는 것은 이미 설치된 도구다.

### Core

| Tool | Version (실측) | Purpose | 근거 |
|------|----------------|---------|------|
| git | 2.56.0 | annotated tag, push, diff 검사 | `[VERIFIED: local git --version]` |
| FVM | 4.3.1 (`/opt/homebrew/bin/fvm`) | `.fvmrc` 갱신, `.vscode/settings.json` 갱신, SDK 심링크 | `[VERIFIED: local fvm --version]` |
| Flutter 3.47.5 / Dart 3.13.4 | FVM 캐시 `/Users/woody/fvm/versions/3.47.5` | 저장소 고정 SDK. `dart pub get`, `dart analyze` | `[VERIFIED: local fvm api list]` |
| Flutter 3.41.2 / 3.41.4 / 3.41.9 (Dart 3.11.0 / 3.11.1 / 3.11.5) | FVM 캐시 | BASE-02 의 "3.13 미만" 대조 SDK | `[VERIFIED: local fvm api list]` — 셋 다 `isSetup: true` |

FVM 캐시에는 `stable` 채널(3.41.4 / Dart 3.11.1)도 있다. 저장소는 채널이 아니라 고정 버전(`3.47.5`)을 쓴다.

### Supporting

| 항목 | 용도 |
|------|------|
| `flutter_lints 6.0.0`, `lints 6.1.0` | 이 패키지의 유일한 의존성. 3.47.5 에서 `dart pub get` 이 오프라인 캐시로 해석됨 `[VERIFIED: local, pkg-copy pubspec.lock]` |
| `gh` CLI | 쓰지 않는다. Releases 페이지는 만들지 않는다 (Claude's Discretion 마지막 항목) |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `fvm use 3.47.5` (`.fvmrc` + VS Code 설정 자동 갱신) | 두 파일을 손으로 편집 | 결과는 같다. `fvm use` 는 `.fvm/` 심링크도 3.47.5 로 바꿔 주고 `~/fvm/projects.json` 에 저장소를 등록한다. 손 편집은 `.fvm/flutter_sdk` 심링크가 3.41.2 를 가리킨 채 남는다 |
| `fvm use 3.47.5` (pub get 실행) | `fvm use 3.47.5 --skip-pub-get` | 기본 동작은 끝에 `flutter pub get` 을 돌려 `pubspec.lock` / `.dart_tool/` 을 다시 쓴다. 둘 다 gitignore 대상이라 어느 쪽이든 커밋 diff 는 같다. 기본 동작을 권한다 — 새 SDK 에서 의존성 해석이 되는지 덤으로 확인된다 |
| `path:` 의존으로 BASE-02 확인 | `git: url: file://…` 로컬 bare 저장소 | 둘 다 같은 오류를 낸다 (아래 실측). `path:` 가 단계가 적다. `git:` 은 "`ref: v1.3.0` 으로 물러서면 된다"까지 함께 보여 준다 |
| `git tag -a … -m … -m …` (명령줄 메시지) | `git tag -a v1.3.0 90a2736` (편집기) | 에이전트 실행에는 편집기가 없으므로 `-m` 을 쓴다. `-m` 두 번이면 두 단락이 된다 `[VERIFIED: local git tag -n99]` |

**Installation:** 없음. 모든 도구가 설치되어 있다.

## Package Legitimacy Audit

> 이 phase 는 외부 패키지를 설치하지 않는다 (`pubspec.yaml` 의 `dependencies` 는 `flutter_lints ^6.0.0` 그대로이고, 바뀌는 것은 `environment.sdk` 와 `version` 뿐이다). 감사 대상 없음.

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```text
[소유자 확인] ──(예)──> git push origin v1.3.0 ──> GitHub origin refs/tags/v1.3.0 ──> 사용 프로젝트 ref: v1.3.0 (Dart 3.11 도 OK)
       ^
       │ 점검 결과(tag→90a2736, =origin/main, version 1.3.0)
       │
git tag -a v1.3.0 90a2736 ──> 로컬 refs/tags/v1.3.0
                                                        ┌─> .fvmrc 3.47.5 ─┐
fvm use 3.47.5 (저장소 루트) ──> VerifyProject(pubspec 있음→통과) ─┼─> .vscode/settings.json ─┼─> 커밋 chore:
                                                        ├─> .fvm/ 심링크 (gitignore)
                                                        └─> flutter pub get → pubspec.lock (gitignore)

pubspec.yaml: sdk ^3.13.0, version 2.0.0-dev ──┐
CHANGELOG.md: ## 2.0.0 - 미출시 (D-14 내용)    ─┼─> 커밋 feat!: (milestone 브랜치만)
                                                │
                     ┌──────────────────────────┘
                     v
   사용 프로젝트(Dart 3.11.x) pub get ──> "requires SDK version ^3.13.0, version solving failed" (exit 1)   ← BASE-02 증거
   사용 프로젝트(Dart 3.13.4) pub get ──> OK, lock version "2.0.0-dev"

VERSIONING.md (판정 순서 → 기준표 → 사례) ──> 커밋 docs:  ──> Phase 4 실측 표 / Phase 6 REL-03 이 읽는다
```

### Recommended Project Structure

이 phase 가 끝난 뒤 milestone 브랜치의 추적 파일 (새로 생기는 것은 `VERSIONING.md` 하나):

```text
woody_lints/
├── .fvmrc                    # "flutter": "3.47.5"           (수정)
├── .vscode/settings.json     # dart.flutterSdkPath: .fvm/versions/3.47.5 (수정)
├── .gitignore                # 변경 없음 (.fvm/, pubspec.lock, .dart_tool/ 이미 있음)
├── analysis_options.yaml     # 변경 없음 (lib/analysis_options.yaml exclude 유지)
├── pubspec.yaml              # version: 2.0.0-dev, sdk: ^3.13.0 (수정)
├── CHANGELOG.md              # 맨 위에 ## 2.0.0 - 미출시 (수정)
├── VERSIONING.md             # 새 파일
├── README.md                 # 변경 없음 (D-11)
├── lib/analysis_options.yaml # 변경 없음
└── .planning/…               # GSD 문서
```

`main` 과 `origin/main` 은 어느 파일도 바뀌지 않는다. 원격에는 tag 하나가 늘어난다.

### Pattern 1: tag 를 "이름표" 로만 쓰고 한 번 붙이면 옮기지 않는다

**What:** annotated tag `vX.Y.Z` 를 `pubspec.yaml` 의 `version` 이 X.Y.Z 인 commit 에 붙이고, push 뒤에는 절대 옮기지 않는다. (쉬운 말: tag 는 특정 커밋에 붙이는 이름표다. 사용 프로젝트는 그 이름표를 보고 내려받고, 받은 커밋 번호를 `pubspec.lock` 에 적어 둔다. 이름표를 다른 커밋으로 옮기면 "같은 이름인데 내용이 다른" 상태가 생긴다.)
**When to use:** 이 phase 의 `v1.3.0`, Phase 6 의 `v2.0.0`.
**근거:** `flutter_starter_kit/pubspec.lock` 의 실제 기록 `[VERIFIED: local /Users/woody/dv/woody/flutter_starter_kit/pubspec.lock]`:

```yaml
  woody_lints:
    dependency: "direct dev"
    description:
      path: "."
      ref: main
      resolved-ref: "90a2736b8d998c84467faf562a0fec720b797eaf"
      url: "https://github.com/woodkill/woody_lints.git"
    source: git
    version: "1.3.0"
```

`resolved-ref` 가 `90a2736` — 지금 `origin/main` 이 가리키는 바로 그 커밋이다. `v1.3.0` 을 여기에 붙이면 이 프로젝트는 `ref: main` → `ref: v1.3.0` 으로 바꿔도 받는 내용이 같다.

### Pattern 2: `fvm use` 를 그대로 쓰고 결과를 diff 로 검사한다

**What:** `fvm use 3.47.5` 한 번으로 `.fvmrc` 와 `.vscode/settings.json` 을 함께 바꾸고, `git diff --stat` 으로 바뀐 추적 파일이 그 둘뿐임을 확인한다.
**When to use:** BASE-01.
**Example:** `[VERIFIED: local, pkg-copy]` — § 조사 1·2 참조.

### Pattern 3: 변경과 기록을 같은 커밋에 둔다

**What:** `pubspec.yaml` 의 `sdk` / `version` 변경과 CHANGELOG 2.0.0 항목을 한 커밋에 넣는다 (D-15 의 이유: "변경과 기록이 같은 커밋에 남고"). VERSIONING.md 는 그 형식의 근거이므로 **그 앞** 커밋이다.
**When to use:** § "조사 7 — 커밋 분할" 참조.

### Anti-Patterns to Avoid

- **인자 없는 `git push`:** 현재 브랜치(`gsd/v2.0-package-rework`)를 원격에 만든다. 리허설 `git push --dry-run origin` 출력이 `* [new branch] gsd/v2.0-package-rework -> gsd/v2.0-package-rework` 였다 `[VERIFIED: local repo-clone]`. D-17 위반. 이 phase 의 push 는 `git push origin v1.3.0` 한 줄만.
- **`-a` 없는 `git tag v1.3.0`:** lightweight tag 가 된다. 메시지·작성자·날짜가 없고, `git ls-remote` 에 `^{}` 줄이 나오지 않는다. 조사 문서(ARCHITECTURE.md Pattern 5, Dart 3.11 의 lightweight tag 버그 이력)가 annotated 를 권한 이유다.
- **`git push --tags` / `--follow-tags`:** 로컬에 있는 다른 tag 까지 간다 (지금은 tag 가 없어 결과는 같지만 D-20 이 금지했다).
- **`sdk: ^3.13.0` 커밋을 `main` 에 올리기:** `ref: main` 인 학습용 프로젝트 4개가 Flutter 를 고정하지 않았다면 다음 `pub get` 이 바로 깨진다 (ROADMAP Notes). milestone 브랜치에만 둔다.
- **CHANGELOG 제목에 ` - ` 를 두 번 쓰기:** REL-03 이 ` - ` 앞 토큰을 버전으로 읽는다 (CONTEXT Integration Points). `## 2.0.0 - 미출시` 처럼 한 번만.
- **`.fvmrc` 를 손으로 바꾸고 `.vscode/settings.json` 을 잊기:** CLAUDE.md 관례 위반. `fvm use` 가 둘을 같이 바꾸므로 그 길을 쓴다.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SDK 고정 파일 3종(`.fvmrc`, `.vscode/settings.json`, `.fvm/` 심링크) 동기화 | 손 편집 + 심링크 재생성 | `fvm use 3.47.5` | FVM 4.3.1 이 셋을 한 번에 갱신함을 실측 `[VERIFIED: local]` |
| "3.13 미만에서 실패" 판정 | 버전 문자열 비교 스크립트 | 실제 3.41.x SDK 로 `dart pub get` 실행 | pub 의 version solver 가 판정 주체다. 오류 문구와 종료 코드를 그대로 증거로 쓴다 |
| tag 가 가리키는 커밋 확인 | `git show v1.3.0` 출력 눈으로 읽기 | `git rev-parse 'v1.3.0^{commit}'` 과 `git rev-parse origin/main` 비교 | 셸 조건문으로 PASS / FAIL 이 나온다 |
| `main` 이 1.3.0 과 같은지 확인 | 파일별 `diff` | `git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` | 종료 코드 0 = 같음. 리허설에서 양성·음성 대조 모두 확인 `[VERIFIED: local repo-clone]` |

**Key insight:** 이 phase 의 모든 "확인" 은 도구가 이미 내는 종료 코드와 출력으로 끝난다. 새 스크립트를 만들 이유가 없다 (검증 스크립트는 Phase 2 의 일이다).

## Runtime State Inventory

> 이 phase 는 이름 변경이 아니라 버전·SDK 변경이지만, "파일을 고친 뒤에도 옛 값을 쥐고 있는 것"이 있어 다섯 범주를 모두 답한다.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | 없음 — 데이터베이스·캐시 키 없음. 사용 프로젝트 5개의 `pubspec.lock` 은 `resolved-ref: 90a2736` 을 쥐고 있지만 그것이 바로 `v1.3.0` 이 될 커밋이라 바뀔 것이 없다 `[VERIFIED: local flutter_starter_kit/pubspec.lock]` (다른 4개는 열어 보지 않음 `[ASSUMED]`) | 없음 |
| Live service config | GitHub 원격 `origin` 에 tag 0개, 브랜치 `main` 하나 (`git ls-remote --heads origin` → `90a2736 refs/heads/main`) `[VERIFIED: local]` | tag `v1.3.0` push (소유자 확인 후) |
| OS-registered state | FVM 전역 레지스트리 `~/fvm/projects.json` 이 `/Users/woody/dv/woody/woody_lints` 를 프로젝트로 등록해 둠 `[VERIFIED: local]`. `fvm use` 가 다시 쓴다. **이번 조사의 부작용:** 스크래치 `pkg-copy` 경로도 등록됐다. 스크래치가 지워지면 죽은 항목으로 남는다 — `fvm list` 가 "Projects" 수를 셀 때만 쓰이는 정보라 동작 영향은 없다 | 없음 (원하면 소유자가 `fvm cleanup` 또는 `projects.json` 에서 줄 삭제) |
| Secrets/env vars | 없음 — `.env`, API 키 없음 `[VERIFIED: local git ls-files]` | 없음 |
| Build artifacts | `.fvm/flutter_sdk → /Users/woody/fvm/versions/3.41.2`, `.fvm/version` = `3.38.9`(옛 FVM 3 흔적), `.fvm/release` = `3.41.2`, `.dart_tool/version` = `3.41.2`, `pubspec.lock` `sdks: dart: ">=3.10.4 <4.0.0"` `[VERIFIED: local]`. 전부 gitignore 대상 | `fvm use 3.47.5` 가 `.fvm/*` 를 3.47.5 로 다시 쓴다 (실측). `pubspec.lock` 은 `fvm use` 끝의 `flutter pub get` 이, `sdk` 하한 커밋 뒤 다시 `dart pub get` 하면 `>=3.13.0 <4.0.0` 으로 바뀐다 (실측). `.dart_tool/version` 은 `flutter pub get` 만 쓴다 — `dart pub get` 은 만들지 않음 (실측). 커밋 대상이 아니므로 작업 없음 |

**문서 쪽 옛 값 (추적 파일):** `.claude/CLAUDE.md` 가 `3.41.2` 를 9곳, caret 붙은 `^3.10.4` 를 4곳, caret 없는 평문 `3.10.4` 를 1곳에 적고 있다 `[VERIFIED: local grep]` (40, 74, 75, 79, 100, 101, 209, 210, 238행 / 39, 166, 262, 314행 / 83행). 이 파일은 `/gsd-map-codebase` 가 생성한 저장소 설명이라 이 phase 뒤에 사실과 어긋난다. § Open Questions 1 참조.

## 조사 결과 — 계획이 답해야 할 8가지

### 조사 1 — `fvm use 3.47.5`: `--force` 필요 여부, 바뀌는 파일

**명령과 출력** (저장소 복사본 `pkg-copy/` 에서, `.git`·`.dart_tool`·`pubspec.lock` 제외하고 복사) `[VERIFIED: local]`:

```text
$ fvm --version
4.3.1
$ fvm use 3.47.5
Dependencies resolved offline.
✓ Updated VSCode folder Flutter SDK path setting.
✓ Project now uses Flutter SDK : SDK Version : 3.47.5
rc=0
```

**`--force` 는 필요 없었다.** 이유 (FVM 4.3.1 소스) `[CITED: raw.githubusercontent.com/leoafarias/fvm/4.3.1/lib/src/workflows/verify_project.workflow.dart]`: 검증은 "Flutter 프로젝트인가"가 아니라 **`pubspec.yaml` 이 있는가** 다 — `if (project.hasPubspec || force) return;`. 없을 때만 `No pubspec.yaml detected in this directory` 경고와 `Would you like to continue?` 프롬프트가 나온다. 이 저장소는 `pubspec.yaml` 이 있으므로 프롬프트 없이 지나간다. ROADMAP Notes / STACK.md 의 "`--force` 가 필요할 수 있다 (미검증)" 은 **불필요** 로 닫힌다. 에이전트가 실행할 때 입력 대기에 걸리지 않는다.

**바뀐 추적 파일 — 정확히 둘** (원본 저장소와 `diff -u`) `[VERIFIED: local]`:

```diff
--- .fvmrc
-  "flutter": "3.41.2"
+  "flutter": "3.47.5"
\ No newline at end of file
--- .vscode/settings.json
-  "dart.flutterSdkPath": ".fvm/versions/3.41.2"
+  "dart.flutterSdkPath": ".fvm/versions/3.47.5"
\ No newline at end of file
.gitignore: no diff
```

둘 다 기존처럼 파일 끝 개행 없이 쓰였다 (diff 노이즈 없음). `.gitignore` 는 `.fvm/` 줄이 이미 있어 건드리지 않았다 (FVM 은 정확히 `.fvm/` 줄이 있으면 쓰지 않음 `[CITED: …/setup_gitignore.workflow.dart]` — `if (lines.any((line) => line.trim() == kFvmPathToAdd))`).

**바뀐 비추적(gitignore) 파일** `[VERIFIED: local]`:

```text
.fvm/flutter_sdk -> /Users/woody/fvm/versions/3.47.5     (이전 3.41.2)
.fvm/versions/3.47.5 -> /Users/woody/fvm/versions/3.47.5  (새 심링크)
.fvm/fvm_config.json  {"flutterSdkVersion": "3.47.5"}
.fvm/release          3.47.5
.fvm/version          3.47.5                               (이전 3.38.9)
pubspec.lock          다시 생성 (flutter_lints 6.0.0, lints 6.1.0, sdks dart ">=3.10.4 <4.0.0")
.dart_tool/           다시 생성
```

**끝에 `flutter pub get` 을 돌린다** ("Dependencies resolved offline"). 건너뛰려면 `--skip-pub-get` `[VERIFIED: local fvm use --help]`. 기본 동작을 권한다 — 3.47.5 에서 의존성 해석이 되는지 덤으로 확인된다.

**실행 뒤 확인** `[VERIFIED: local]`:

```text
$ fvm flutter --version
Flutter 3.47.5 • channel stable • git@github.com:flutter/flutter.git
Framework • revision 6a19cca564 (3주 전) • 2026-09-17 14:13:22 -0400
Engine • hash ab598368592da0064197e2bc15c7f5b0a2c6bb1f (revision af7e796e16) (24 days ago) • 2026-09-16 18:35:09.000Z
Tools • Dart 3.13.4 • DevTools 2.60.0
$ fvm dart --version
Dart SDK version: 3.13.4 (stable) (Tue Sep 15 01:01:15 2026 -0700) on "macos_arm64"
```

ROADMAP success criterion 2 의 `fvm flutter --version` 문구와 정확히 맞는다.

**실제 저장소에서 다른 점 (예상):** `.git` 이 있다는 것뿐이다. FVM 은 `.git` 을 읽지 않으므로 결과는 같을 것이다 `[ASSUMED — 복사본에는 .git 이 없었다]`. 실행 뒤 `git status --short` 로 바뀐 추적 파일이 ` M .fvmrc`, ` M .vscode/settings.json` 둘뿐인지 확인하는 단계를 plan 에 넣으면 이 가정이 그 자리에서 검증된다.

### 조사 2 — `.vscode/settings.json` 의 SDK 경로

**손으로 고칠 것이 없다.** `fvm use` 가 `.vscode/` 디렉터리가 있으면 `dart.flutterSdkPath` 를 `.fvm/versions/<버전>` 상대 경로로 다시 쓴다 `[VERIFIED: local]` `[CITED: …/update_vscode_settings.workflow.dart — 조건 if (!isVsCode() && !_hasVsCodeFiles(project)) return; 설정 updateVscodeSettings: false 로 끌 수 있음]`. 값은 `.fvm/versions/3.47.5` 로, 현재 형식과 같다 (`.fvm/flutter_sdk` 가 아니다).

**검증 명령 (PASS / FAIL):**

```bash
grep -q '"dart.flutterSdkPath": ".fvm/versions/3.47.5"' .vscode/settings.json && echo PASS || echo FAIL
grep -q '"flutter": "3.47.5"' .fvmrc && echo PASS || echo FAIL
```

**대비책:** `fvm use` 가 VS Code 설정을 건드리지 않았다면(예: 전역 FVM 설정에 `updateVscodeSettings: false` — 지금은 `fvm config` 가 "No settings have been configured" `[VERIFIED: local]`) 파일을 직접 아래 내용으로 쓴다. 파일 끝 개행 없음은 유지하지 않아도 된다 (JSON 으로서 같다).

```json
{
  "dart.flutterSdkPath": ".fvm/versions/3.47.5"
}
```

### 조사 3 — "Dart 3.13 미만에서 `pub get` 이 실패한다" 를 보이는 절차

**핵심 사실:** `sdk: ^3.13.0` 은 이 저장소에서 아직 **커밋되지 않았고 원격에도 없다.** 그래서 사용 프로젝트 역할의 임시 패키지는 GitHub URL 이 아니라 **`path:`** 로 이 저장소(또는 복사본)를 가리켜야 한다. 실행 시점에는 milestone 브랜치의 작업 트리에 `^3.13.0` 이 있으므로 `path: /Users/woody/dv/woody/woody_lints` 로 바로 가리킬 수 있다 (읽기만 한다 — pub 은 `path:` 대상 디렉터리에 아무것도 쓰지 않는다; 조사에서 `pkg-copy` 에 새 파일이 생기지 않았다 `[VERIFIED: local]`).

**재현 절차** (스크래치 디렉터리에서; 실측에 쓴 그대로) `[VERIFIED: local]`:

```bash
# 1) 임시 사용 프로젝트 (자기 자신은 Dart 3.10 이상이면 되게 둔다 — 3.41.x 에서도 해석되도록)
mkdir -p "$SCRATCH/consumer" && cd "$SCRATCH/consumer"
cat > pubspec.yaml <<'EOF'
name: consumer_probe
version: 0.0.1
publish_to: 'none'
environment:
  sdk: ^3.10.0
dev_dependencies:
  woody_lints:
    path: /Users/woody/dv/woody/woody_lints     # milestone 브랜치가 체크아웃된 작업 트리
EOF
mkdir -p lib && printf 'int add(int a, int b) => a + b;\n' > lib/consumer_probe.dart

# 2) Dart 3.13 미만 (실패해야 한다). FVM 캐시의 SDK 를 직접 지정한다
for v in 3.41.2 3.41.4 3.41.9; do
  rm -rf .dart_tool pubspec.lock
  /Users/woody/fvm/versions/$v/bin/dart pub get; echo "rc=$?"
done

# 3) Dart 3.13.4 (성공해야 한다)
rm -rf .dart_tool pubspec.lock
/Users/woody/fvm/versions/3.47.5/bin/dart pub get; echo "rc=$?"
grep -A8 '^  woody_lints' pubspec.lock
```

**실제 출력 — 실패 쪽 (3.41.2 / 3.41.4 / 3.41.9 세 번 모두 같은 형태, Dart 버전 숫자만 다름):**

```text
$ /Users/woody/fvm/versions/3.41.2/bin/dart pub get
Resolving dependencies...
The current Dart SDK version is 3.11.0.

Because consumer_probe depends on woody_lints from path which requires SDK version ^3.13.0, version solving failed.


You can try the following suggestion to make the pubspec resolve:
* Try using the Dart SDK version: 3.13.5. See https://dart.dev/get-dart.
rc=1
```

(3.41.4 → `The current Dart SDK version is 3.11.1.`, 3.41.9 → `… 3.11.5.`; 나머지 문구 동일.) `* Try using the Dart SDK version: 3.13.5` 는 pub 이 추천하는 **최신** 버전이지 이 패키지의 하한이 아니다 — 하한은 `^3.13.0` 이고 3.13.4 에서 성공한다.

`flutter pub get` (3.41.9) 도 같은 본문이며 추천 줄만 `* Try using the Flutter SDK version: 3.47.7.` 로 바뀌고 끝에 `Failed to update packages.` 가 붙는다 (rc=1). 앞에 "A new version of Flutter is available!" 상자가 출력되지만 판정과 무관하다.

**실제 출력 — 성공 쪽 (3.47.5 / Dart 3.13.4):**

```text
Resolving dependencies...
Downloading packages...
+ flutter_lints 6.0.0
+ lints 6.1.0
+ woody_lints 2.0.0-dev from path ../pkg-copy
Changed 3 dependencies!
rc=0
  woody_lints:
    dependency: "direct dev"
    description:
      path: "../pkg-copy"
      relative: true
    source: path
    version: "2.0.0-dev"
sdks:
  dart: ">=3.13.0 <4.0.0"
```

**`git:` 방식도 같다** (스크래치 bare 저장소 `fake-remote.git` 의 `probe` 브랜치에 `^3.13.0` 커밋을 두고 `git: url: file://…, ref: probe`) `[VERIFIED: local]`: 3.41.9 에서 `Because consumer_git_probe depends on woody_lints from git which requires SDK version ^3.13.0, version solving failed.` rc=1; 3.47.5 에서 `+ woody_lints 2.0.0-dev from git ../fake-remote.git at 10b4a4`, lock 에 `ref: probe`, `resolved-ref: "10b4a4…"`, `version: "2.0.0-dev"`.

**CHANGELOG "올리기 전에" 가 성립하는지 — `ref: v1.3.0` 으로 물러서기** `[VERIFIED: local]`: 같은 가짜 사용 프로젝트가 `ref: v1.3.0` 을 가리키면 **3.41.9 (Dart 3.11.5) 에서 성공**한다:

```text
+ woody_lints 1.3.0 from git ../fake-remote.git at 90a273
Changed 3 dependencies!
rc=0
      ref: "v1.3.0"
      resolved-ref: "90a2736b8d998c84467faf562a0fec720b797eaf"
    version: "1.3.0"
```

**패키지 자신의 루트에서도 같은 오류** `[VERIFIED: local pkg-copy]`: `/Users/woody/fvm/versions/3.41.2/bin/dart pub get` → `Because woody_lints requires SDK version ^3.13.0, version solving failed.` rc=1. 저장소 루트에서 3.41.x 로 `dart pub get` 을 치면 깨진다는 뜻이기도 하다 — 저장소를 3.47.5 로 고정(BASE-01)해야 BASE-02 와 모순이 없다. **그래서 BASE-01 커밋이 BASE-02 커밋보다 앞서야 한다.**

**증거를 남길 자리 (권고):** 두 곳.
1. **plan 의 SUMMARY.md** (`.planning/phases/01-baseline-and-toolchain/01-0N-SUMMARY.md`) 에 실행 시점의 명령·SDK 버전·오류 문구·종료 코드·날짜를 **그대로** 붙인다. 이 증거는 "그날 그 머신" 의 관찰이라 저장소 산출물이 아니라 planning 기록에 맞다. Phase 6 의 smoke test(REL-04)가 같은 형식을 재사용할 수 있다.
2. **CHANGELOG 2.0.0 항목의 `### 올리기 전에`** 에는 사람이 읽을 결론만 적는다 (D-14 문구 그대로). 숫자·명령은 넣지 않는다.
   - 선택: VERSIONING.md 의 2.0.0 사례 줄에 "(Dart 3.11.5 에서 `pub get` 이 `version solving failed` 로 끝나는 것을 2026-10-XX 확인)" 한 구절을 덧붙이면 정책 문서 안에서 근거가 보인다. 필수는 아니다.

스크립트를 저장소에 커밋하지는 않는다 — `tool/` 은 Phase 2 가 만든다.

### 조사 4 — "`origin/main` 의 `lib/` 와 `pubspec.yaml` 이 `v1.3.0` 과 같다" 검사

**명령 (PASS / FAIL 한 줄):**

```bash
git fetch origin --quiet                                   # origin/main 을 최신으로
git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml && echo PASS || echo FAIL
```

- `--quiet` 는 차이가 없으면 0, 있으면 1 로 끝난다. `-- lib pubspec.yaml` 로 범위를 그 둘로 좁힌다 (`.planning/` 등 다른 경로의 차이는 무시).
- tag 가 아직 없을 때(이 phase 시작 전)는 `v1.3.0` 자리에 `90a2736` 을 쓴다. 지금 실제 저장소에서 `git diff --quiet origin/main HEAD -- lib pubspec.yaml` → rc=0 `[VERIFIED: local]` (현재 브랜치 HEAD 조차 `lib/`·`pubspec.yaml` 은 1.3.0 과 같다).
- 추가로 `git rev-parse origin/main` 이 `90a2736b8d998c84467faf562a0fec720b797eaf` 인지도 본다 — 이 phase 는 `main` 에 아무것도 올리지 않으므로 바뀌어 있으면 다른 데서 push 가 있었다는 신호다.

**리허설 결과 (스크래치 클론)** `[VERIFIED: local repo-clone]`:

```text
$ git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml; echo "rc=$?"
rc=0 (0 = same)
$ git diff --quiet v1.3.0 HEAD; echo "rc=$?"                   # 음성 대조: .planning 포함 전체
rc=1 (1 = differ)   20 files changed, 5610 insertions(+)
$ git diff --quiet v1.3.0 HEAD -- lib pubspec.yaml; echo "rc=$?"  # 범위 좁히면 다시 0
rc=0
$ (probe 브랜치에 sdk ^3.13.0 커밋 후) git diff --quiet v1.3.0 probe -- lib pubspec.yaml; echo "rc=$?"
rc=1   # ← sdk 하한을 올린 브랜치는 정상적으로 FAIL
```

양성(같음 → 0)과 음성(다름 → 1)이 모두 기대대로 나왔다.

### 조사 5 — tag 사실 확인과 명령

**사실 확인 (실제 저장소, 읽기 전용)** `[VERIFIED: local]`:

| 확인 항목 | 명령 | 결과 |
|-----------|------|------|
| `90a2736` 이 1.3.0 커밋이다 | `git show -s --format='%H %s' 90a2736` | `90a2736b8d998c84467faf562a0fec720b797eaf feat: riverpod_lint 를 최상위 plugins: 방식으로 전환 (1.3.0)` (2026-09-20, Woody Moon; CHANGELOG·README·analysis_options.yaml·lib/analysis_options.yaml·pubspec.yaml 변경) |
| `90a2736` = `origin/main` | `git rev-parse origin/main 90a2736` | 둘 다 `90a2736b8d998c84467faf562a0fec720b797eaf` |
| 그 커밋의 version | `git show 90a2736:pubspec.yaml \| grep '^version:'` | `version: 1.3.0` |
| 로컬 tag | `git tag -l` | (없음) |
| 원격 tag | `git ls-remote --tags origin` | (없음, rc=0) |
| 원격 브랜치 | `git ls-remote --heads origin` | `90a2736… refs/heads/main` 하나 |
| 로컬 `main` | `git rev-parse main` | `271114a` — `origin/main` 보다 `.planning/` 커밋 7개 앞. `lib/`·`pubspec.yaml` 차이 없음 |
| 현재 브랜치 | `git branch --show-current` | `gsd/v2.0-package-rework` (HEAD `b35150a`, 원격에 없음) |
| 작업 트리 | `git status --short` | `?? .planning/research/.cache/` 만 (조사 캐시, 추적 안 됨) |
| git 설정 | `git config push.default`, `push.followTags`, `tag.gpgSign` | 셋 다 unset → 기본값. 서명 프롬프트 없음, `--follow-tags` 자동 동작 없음 |

**D-18 단계별 명령** (스크래치 클론 + 가짜 bare 원격에서 그대로 실행해 확인) `[VERIFIED: local repo-clone]`:

```bash
# 1) 로컬에서 annotated tag 만들기 (메시지 두 단락 = -m 두 번)
git tag -a v1.3.0 90a2736 \
  -m "woody_lints 1.3.0" \
  -m "2.0.0 작업 전 기준점. Dart 3.13 미만 프로젝트는 이 tag 에 머문다"

# 2) 점검 — 셋 다 PASS 여야 push 로 간다
test "$(git cat-file -t v1.3.0)" = tag                                     && echo "PASS annotated" || echo "FAIL lightweight"
test "$(git rev-parse 'v1.3.0^{commit}')" = 90a2736b8d998c84467faf562a0fec720b797eaf && echo "PASS -> 90a2736" || echo "FAIL wrong commit"
git fetch origin --quiet && test "$(git rev-parse 'v1.3.0^{commit}')" = "$(git rev-parse origin/main)" && echo "PASS = origin/main" || echo "FAIL != origin/main"
git show v1.3.0:pubspec.yaml | grep -qx 'version: 1.3.0'                 && echo "PASS version 1.3.0" || echo "FAIL version"
git tag -n99 v1.3.0                                                         # 메시지 눈으로 확인

# 3) 소유자 확인 (D-19) — 아래 "확인 요청 문안" 참조

# 4) tag 이름 하나만 push (D-20)
git push origin v1.3.0

# 5) 원격 확인
git ls-remote --tags origin
```

**리허설 출력:**

```text
$ git tag -a v1.3.0 90a2736 -m "woody_lints 1.3.0" -m "2.0.0 작업 전 기준점. Dart 3.13 미만 프로젝트는 이 tag 에 머문다"
rc=0
$ git cat-file -t v1.3.0
tag
$ git rev-parse 'v1.3.0^{commit}'
90a2736b8d998c84467faf562a0fec720b797eaf
$ git show v1.3.0:pubspec.yaml | grep '^version:'
version: 1.3.0
$ git tag -n99 v1.3.0
v1.3.0          woody_lints 1.3.0

    2.0.0 작업 전 기준점. Dart 3.13 미만 프로젝트는 이 tag 에 머문다
$ git for-each-ref refs/tags --format='%(objecttype) %(refname:short) -> %(*objectname:short) %(taggerdate:short)'
tag v1.3.0 -> 90a2736 2026-10-11
$ git push origin v1.3.0
To /…/fake-remote.git
 * [new tag]         v1.3.0 -> v1.3.0
rc=0
$ git ls-remote --tags origin
9b0596ed192a28fb914c9cc52aba8767c5c98d1e	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
```

**`ls-remote` 읽는 법:** annotated tag 는 **두 줄**로 나온다. 첫 줄은 tag 객체 자체의 SHA(여기서는 `9b0596…`, 실제 저장소에서는 다른 값이 된다 — tag 를 만든 시각이 들어가므로), 둘째 줄 `v1.3.0^{}` 이 tag 가 가리키는 **커밋** 이다 `[CITED: git-scm.com/docs/git-ls-remote — "two such lines are shown … The <oid> on the latter line shows the name of the object the tag points at"]`. Success criterion 1 의 판정은 **둘째 줄이 `90a2736…`** 인지로 한다:

```bash
git ls-remote --tags origin 'v1.3.0^{}' | grep -q '^90a2736b8d998c84467faf562a0fec720b797eaf' && echo PASS || echo FAIL
```

**리허설에서 "FAIL != origin/main" 이 난 이유 (실제 저장소와 다름):** 클론은 원본 저장소의 로컬 브랜치를 원격 ref 로 받기 때문에 클론의 `origin/main` 이 **로컬** `main` (`271114a`) 이었다. 실제 저장소의 `origin/main` 은 `90a2736` 이므로 PASS 가 나야 한다. 점검 2단계는 실제 저장소에서 반드시 다시 돌린다 (복사본 결과를 믿지 않는다).

**push 전 실수 되돌리기:** push 하기 **전**이라면 `git tag -d v1.3.0` 으로 지우고 다시 만들면 된다 (로컬 전용, 흔적 없음). push **후**에는 D-18 Reversibility 대로 옮기지 않는다.

**D-19 확인 요청 문안 (초안, 쉬운 말):**

> 지금 GitHub 에 올리려는 것은 **tag `v1.3.0` 하나**입니다. tag 는 커밋에 붙이는 이름표입니다.
> - 붙이는 커밋: `90a2736` — 지난 9월 20일의 "riverpod_lint 를 최상위 plugins: 방식으로 전환 (1.3.0)". 지금 GitHub 의 `main` 이 가리키는 바로 그 커밋이고, `pubspec.yaml` 의 version 은 1.3.0 입니다.
> - 실행할 명령: `git push origin v1.3.0` (이 이름표 하나만 올립니다. 브랜치나 다른 파일은 올라가지 않습니다.)
> - 되돌릴 수 없는 점: 한 번 올린 이름표는 다른 커밋으로 옮기지 않기로 했습니다. 사용 프로젝트의 `pubspec.lock` 이 이 이름표가 가리키는 커밋 번호를 기억하기 때문입니다. 잘못 붙이면 `v1.3.0` 이라는 이름은 다시 쓸 수 없고 `v1.3.1` 같은 새 이름을 써야 합니다.
> - 위 점검(이름표가 `90a2736` 을 가리킴, GitHub `main` 과 같음, version 1.3.0)은 모두 통과했습니다.
> 올릴까요? (예 / 아니오)

**tag 메시지 (Claude's Discretion):** 논의의 기본값 두 줄을 그대로 쓰는 것을 권한다. 두 번째 줄은 `-m` 을 한 번 더 써서 별도 단락으로 둔다 (`git tag -n99` 출력에서 제목과 본문이 구분된다 — 위 출력 참조).

### 조사 6 — `version: 2.0.0-dev` 의 유효성과 부작용

- **유효하다.** dart.dev pubspec 문서: "A version number is three numbers separated by dots, like `0.2.43`. It can also optionally have a build (`+1`, `+2`, `+hotfix.oopsie`) or prerelease (`-dev.4`, `-alpha.12`, `-beta.7`, `-rc.5`) suffix." `[CITED: dart.dev/tools/pub/pubspec#version, via Context7 /dart-lang/site-www]`. pub 은 semver 2.0.0-rc.1 을 따른다 `[CITED: dart.dev/tools/pub/dependencies]`. `-dev` (점·숫자 없이) 도 semver 상 유효한 pre-release 식별자다.
- **실측:** `version: 2.0.0-dev` 인 패키지 루트에서 `dart pub get` 경고 없음 (3.47.5). `path:` 와 `git:` 로 의존한 사용 프로젝트도 경고 없이 해석되며 lock 에 `version: "2.0.0-dev"` 로 적힌다 `[VERIFIED: local]` (조사 3 출력).
- **git 의존 사용 프로젝트에 미치는 영향:** `ref:` 방식에서 pub 은 가리킨 커밋의 pubspec 을 그대로 읽는다. 버전 범위 비교가 없으므로 pre-release 여부는 해석에 영향을 주지 않고, lockfile 의 `version:` 표시 값만 `"2.0.0-dev"` 가 된다. `ref: main` 인 프로젝트 5개는 milestone 브랜치를 보지 않으므로 아무 영향이 없다.
- **의도한 부작용 (D-07):** Phase 6 의 일치 검사(REL-03)가 `v2.0.0` tag 와 `2.0.0-dev` 를 다르다고 보고 막는다 — 완성 전 tag 를 막는 안전장치로 작동한다.
- **주의 (해당 없음, 기록만):** 나중에 `tag_pattern: v{{version}}` + `version: ^2.0.0` 방식으로 옮긴다면 pre-release 는 `^2.0.0` 범위에 들지 않는다. 이번 마일스톤은 `ref:` 방식이라 무관하다 `[ASSUMED — pub 의 pre-release 범위 규칙은 이 세션에서 실행해 보지 않았다]`.

### 조사 7 — 커밋 분할 권고

Conventional Commits (prefix 영어, 제목 한국어, 기존 `feat: … (1.3.0)` 처럼 버전은 괄호) 를 따른다. **3 커밋 + tag** 를 권한다.

| 순서 | 종류 | 포함 파일 | 제목 (예) | 이유 |
|------|------|-----------|-----------|------|
| 0 | tag (커밋 아님) | — | `v1.3.0` on `90a2736` | D-18: 무엇이든 바꾸기 전에. push 는 소유자 확인 후 |
| 1 | `chore:` | `.fvmrc`, `.vscode/settings.json` | `chore: 저장소 고정 Flutter 를 3.47.5 (Dart 3.13.4) 로 올림` | 받는 쪽에 영향 없음(D-05 "저장소 안쪽 = 올리지 않음"). `fvm use` 한 번의 산출물이라 한 커밋. **2번보다 먼저** — 조사 3 에서 보았듯 하한을 올린 뒤에는 3.41.x 로는 저장소 루트의 `pub get` 이 안 된다 |
| 2 | `docs:` | `VERSIONING.md` (새 파일) | `docs: 버전 정책과 CHANGELOG 형식 문서(VERSIONING.md) 추가` | 3번 커밋의 CHANGELOG 항목이 이 문서의 형식을 따르므로 **앞**에 둔다. 정책 자체는 받는 쪽에 영향 없음 |
| 3 | `feat!:` | `pubspec.yaml` (`sdk`, `version`), `CHANGELOG.md` (2.0.0 항목) | `feat!: 지원 SDK 하한을 Dart 3.13 으로 올림 (2.0.0-dev)` | D-07 "`sdk` 하한을 올리는 변경과 함께 한다" + D-15 "변경과 기록이 같은 커밋". `!` 는 breaking(major) 표시 — VERSIONING.md 의 판정과 일치시킨다. 본문에 "Dart 3.13 미만은 `ref: v1.3.0` 에 머문다" 와 BASE-02 실측 요약 한 줄 |

**4 커밋 대안** (CHANGELOG 항목을 3번에서 떼어 `docs:` 로): 커밋 단위가 "한 파일 = 한 커밋" 으로 더 잘게 되지만 D-15 의 이유(변경과 기록이 같은 커밋)와 어긋난다. 소유자가 커밋을 더 잘게 보고 싶다는 뜻을 밝히지 않았으므로 3 커밋을 권한다.

`gsd_run query commit` (GSD 커밋 도구) 을 쓰든 `git commit` 을 쓰든 결과는 같다. 모든 커밋은 **milestone 브랜치 `gsd/v2.0-package-rework`** 에 쌓고 push 하지 않는다 (D-17).

### 조사 8 — SDK 버전을 읽는 저장소 안의 다른 것들

| 항목 | 지금 값 | 이 phase 에서 | 근거 |
|------|---------|---------------|------|
| 루트 `analysis_options.yaml` | `analyzer.exclude: [lib/analysis_options.yaml]` | **변경 없음.** 버전 의존 없음. 3.47.5 에서 `dart analyze` / `dart analyze --fatal-infos` 모두 `No issues found!` rc=0 | `[VERIFIED: local pkg-copy, sdk ^3.13.0 상태에서]` |
| `.gitignore` | `.dart_tool/`, `pubspec.lock`, `.DS_Store`, `.fvm/` | **변경 없음.** `fvm use` 가 건드리지 않음 | `[VERIFIED: local]` |
| `pubspec.lock` (gitignore) | `sdks: dart: ">=3.10.4 <4.0.0"` | `fvm use` 끝의 `flutter pub get` 과, 하한 커밋 뒤 `dart pub get` 으로 `">=3.13.0 <4.0.0"` 이 된다. 커밋하지 않는다 | `[VERIFIED: local]` |
| `.dart_tool/version` (gitignore) | `3.41.2` | `flutter pub get` 이 쓰는 파일. `fvm use` 가 돌리는 `flutter pub get` 으로 3.47.5 가 될 것 `[ASSUMED — 복사본에서는 dart pub get 만 따로 돌려 파일이 생기지 않았다]`. 커밋 대상 아님 | |
| `.fvm/` (gitignore) | 3.41.2 심링크, `version` 3.38.9 | `fvm use` 가 전부 3.47.5 로 다시 쓴다 | `[VERIFIED: local]` |
| `dart pub get` at root on 3.47.5 | — | 현재 `^3.10.4` 로도, `^3.13.0` 으로도 성공 (`flutter_lints 6.0.0`, `lints 6.1.0`, 오프라인 캐시) | `[VERIFIED: local]` |
| `lib/analysis_options.yaml`, `README.md`, `CHANGELOG.md` 의 "Flutter 3.47.5 / 3.41.9 실측" 주석 | 서술문 | **변경 없음** — 저장소 고정 버전이 아니라 관찰 기록이다. CONCERNS.md 의 "FVM 고정 버전과 문서상 검증 버전의 불일치" 는 `.fvmrc` 가 3.47.5 가 되는 순간 해소된다 | `[VERIFIED: local grep]` |
| `.claude/CLAUDE.md` | `3.41.2` 9곳, `^3.10.4` 4곳 + 평문 `3.10.4` 1곳(83행) | 이 phase 뒤 **사실과 어긋난다.** § Open Questions 1 | `[VERIFIED: local grep]` |
| CI | 없음 (Phase 2) | 해당 없음. Phase 2 의 `subosito/flutter-action` 이 `.fvmrc` 를 읽을 예정이라 이 phase 의 `.fvmrc` 값이 그대로 CI SDK 가 된다 | STACK.md |

## VERSIONING.md 작성 재료

D-09 의 세 부분은 CONTEXT 에 확정돼 있다. 여기서는 **세 번째 부분(실제 사례)** 의 재료와 **쉬운 말 풀이(D-10)** 문구를 준다.

### git 이력에서 뽑은 version 변경 11건 `[VERIFIED: local git log/show -- pubspec.yaml]`

| 커밋 | 날짜 | version | 커밋 제목 | 지금 정책(D-05/D-09)으로 다시 판정하면 |
|------|------|---------|-----------|------------------------------------------|
| `d98b45a` | 2025-12-22 | 1.0.0 | Initial Commit: Woody's lint rules | 첫 릴리스 |
| `126aa43` | 2025-12-22 | 1.0.0 | flutter lints로 변경 (기반 세트 `lints` → `flutter_lints`) | 기반 규칙이 통째로 바뀜 → **major** 였어야 함 (당시엔 올리지 않음) |
| `2249a0b` | 2025-12-22 | 1.1.0 | 버전 숫자 변경 | (내용 변경 없이 번호만) |
| `ec66e3f` | 2025-12-24 | 1.2.0 | `formatter:` 에 `trailing_commas: preserve` 추가 | 설정 변경, 받는 쪽 포맷 결과가 달라짐 → minor 이상. (지금은 Out of Scope — 기본 프리셋에 `formatter:` 를 넣지 않는다) |
| `21c5689` | 2025-12-30 | 1.2.1 | Update pubspec.yaml | 상세 미확인 |
| `31c8cb1` | 2026-01-03 | 1.2.2 | Update pubspec.yaml | 상세 미확인 |
| `9451f6b` | 2026-01-28 | 1.2.3 | `slash_for_doc_comments` 추가 | 규칙 추가 → **minor** (당시 patch 로 냄) |
| `212365d` | 2026-02-27 | 1.2.4 | `public_member_api_docs` 추가, `analyzer:` 추가 | 규칙 추가 + exclude/errors 변경 → **minor** (당시 patch) |
| `dbcd20b` | 2026-03-23 | 1.2.5 | bump version to 1.2.5 and update analysis options | 상세 미확인 |
| `90a2736` | 2026-09-20 | 1.3.0 | riverpod_lint 를 최상위 `plugins:` 방식으로 전환 (1.3.0) | 그때까지 로드되지 않던 plugin 이 처음 켜짐 → **minor** (일치) |
| (이번) | 미출시 | 2.0.0 | SDK 하한 `^3.10.4` → `^3.13.0` | **major** (D-06) |

CHANGELOG 는 `1.0.0` 과 `1.3.0` 사이가 비어 있다 (`2249a0b`, `dbcd20b` 시점의 CHANGELOG 도 `## 1.0.0` 만 `[VERIFIED: local git show]`). 그 보완은 Phase 5 (DOCS-08) 이고, 이 표는 그때도 재료가 된다.

D-09 가 요구하는 최소 두 사례(1.3.0 → minor, 2.0.0 → major)에 `9451f6b`(규칙 추가인데 patch 로 냈던 것 → 지금 정책이면 minor) 하나를 더 넣으면 "옛 판정과 새 정책이 다른 경우" 를 보여 줄 수 있다. 예시 개수는 Claude's Discretion 이다.

### 쉬운 말 풀이 문구 (D-10, 논의에서 통한 표현 사용)

- 버전 번호 `2.0.0` 은 세 자리다: **맨 앞자리(major)** 는 "받는 쪽이 뭔가 고쳐야 한다", **가운데 자리(minor)** 는 "경고가 달라진다, CHANGELOG 를 본다", **맨 뒷자리(patch)** 는 "달라지는 게 없다". 책의 판수 비유: 개정판(major) / 증보판(minor) / 오탈자 수정(patch).
- tag 는 커밋에 붙이는 **이름표**다. 사용 프로젝트는 이름표 이름(`v1.3.0`)으로 받는다. push 는 "GitHub 에 올린다".
- "받는 쪽" = 이 패키지를 `include` 하는 Flutter 프로젝트.
- `pubspec.lock` 은 "그때 실제로 받은 커밋 번호를 적어 두는 영수증".

### REL-03 이 읽을 형식

CHANGELOG 최상단 제목 `## 2.0.0 - 미출시` 에서 버전 토큰은 ` - ` **앞** (CONTEXT Integration Points). VERSIONING.md 의 CHANGELOG 형식 절에 "제목의 ` - ` 는 한 번만 쓴다" 를 명시한다. 날짜 자리 "미출시" 를 검사가 거부하게 할지는 Deferred (Phase 6).

## CHANGELOG 2.0.0 항목

CONTEXT `<specifics>` 의 초안을 그대로 쓴다 (`CHANGELOG.md` 맨 위, 기존 `## 1.3.0` 위에 삽입):

```markdown
## 2.0.0 - 미출시

지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)

### 올리기 전에

- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.

### 새로 생기는 경고

(Phase 4 실측 후 채움)

## 1.3.0
```

- "올리기 전에" 문장은 조사 3 에서 **사실로 확인**됐다 (3.41.9 에서 `ref: v1.3.0` 해석 성공, 하한 올린 커밋은 실패).
- 기존 `## 1.3.0`, `## 1.0.0` 항목은 건드리지 않는다 (D-16).
- 현재 `CHANGELOG.md` 는 11행, 두 항목, 날짜 없음 `[VERIFIED: local cat -n]`.

## Common Pitfalls

### Pitfall 1: `.fvmrc` 보다 `sdk` 하한을 먼저 올린다
**What goes wrong:** 저장소가 아직 3.41.2 를 가리키는데 `pubspec.yaml` 이 `^3.13.0` 이면 저장소 루트의 `fvm dart pub get` 이 `Because woody_lints requires SDK version ^3.13.0, version solving failed.` 로 깨진다 `[VERIFIED: local]`.
**Why it happens:** 두 변경이 서로 다른 파일이라 순서를 의식하지 않는다.
**How to avoid:** 커밋 1(`.fvmrc`) → 커밋 3(`sdk`) 순서를 plan 에 고정한다.
**Warning signs:** `fvm dart --version` 이 3.11.x 를 보고한다.

### Pitfall 2: 인자 없는 `git push` 로 브랜치가 올라간다
**What goes wrong:** `gsd/v2.0-package-rework` 가 공개 저장소에 생기고 `.planning/` 이 공개된다 (Deferred 항목이 Phase 2 로 미룬 결정을 선취하게 됨).
**Why it happens:** `push.default` 가 기본(simple)이라 현재 브랜치가 간다 `[VERIFIED: local git config]`, 리허설 dry-run 이 `[new branch]` 를 보였다.
**How to avoid:** 이 phase 의 push 는 `git push origin v1.3.0` 한 줄만. GSD 커밋 도구가 자동 push 를 하지 않는지 plan 에서 확인한다 (`commit_docs: true` 는 커밋만이다).
**Warning signs:** `git ls-remote --heads origin` 에 `main` 외의 줄이 보인다.

### Pitfall 3: 복사본 리허설의 `origin/main` 을 믿는다
**What goes wrong:** 스크래치 클론에서는 `origin/main` 이 로컬 `main`(`271114a`) 이라 "= origin/main" 점검이 FAIL 로 보였다.
**Why it happens:** 로컬 경로를 clone 하면 원본의 로컬 브랜치가 원격 ref 가 된다.
**How to avoid:** D-18 2단계는 실제 저장소에서 `git fetch origin` 후 돌린다. 실제 `origin/main` 은 `90a2736` 이다 `[VERIFIED: local]`.

### Pitfall 4: `ls-remote` 의 첫 줄 SHA 를 커밋으로 읽는다
**What goes wrong:** annotated tag 의 첫 줄은 tag 객체 SHA 라 `90a2736` 과 다르다. "엉뚱한 커밋에 붙었다" 고 오판한다.
**How to avoid:** `refs/tags/v1.3.0^{}` 줄(둘째 줄)을 본다 `[CITED: git-scm.com/docs/git-ls-remote]`. 판정 명령은 조사 5 참조.

### Pitfall 5: `pub` 의 추천 문구를 하한으로 적는다
**What goes wrong:** 오류 메시지의 `* Try using the Dart SDK version: 3.13.5` 를 보고 "3.13.5 이상 필요" 라고 문서에 쓴다.
**Why it happens:** pub 은 자기가 아는 최신 stable 을 추천할 뿐이다.
**How to avoid:** 하한은 `pubspec.yaml` 의 `^3.13.0` 이고 3.13.4 에서 성공한다 `[VERIFIED: local]`. CHANGELOG 는 "Dart 3.13 이상" 으로 쓴다 (D-14).

### Pitfall 6: tag 메시지 두 줄을 `-m` 하나에 `\n` 으로 넣는다
**What goes wrong:** 셸에 따라 `\n` 이 그대로 들어가거나 한 줄로 붙는다.
**How to avoid:** `-m` 을 두 번 쓴다 (단락 구분). 리허설 `git tag -n99` 출력이 제목/본문으로 나뉘었다 `[VERIFIED: local]`.

### Pitfall 7: `fvm use` 뒤 추적 파일 diff 를 확인하지 않는다
**What goes wrong:** FVM 설정이나 버전이 달랐다면 `.gitignore` 에 줄이 추가되거나 다른 파일이 바뀔 수 있다 (이번 실측에서는 아니었다).
**How to avoid:** `git status --short` 가 ` M .fvmrc`, ` M .vscode/settings.json` 두 줄(+ 기존 `?? .planning/research/.cache/`)인지 확인하는 단계를 둔다.

## Code Examples

### 전체 검증 묶음 (phase 끝에 한 번에 돌려 5개 success criteria 판정)

```bash
# SC1: 원격 tag v1.3.0 이 90a2736 을 가리킨다
git ls-remote --tags origin 'v1.3.0^{}' | grep -q '^90a2736b8d998c84467faf562a0fec720b797eaf' && echo "SC1 PASS" || echo "SC1 FAIL"
git show v1.3.0:pubspec.yaml | grep -qx 'version: 1.3.0' && echo "SC1b PASS" || echo "SC1b FAIL"

# SC2: 저장소 SDK 고정
fvm flutter --version 2>/dev/null | grep -q '^Flutter 3.47.5 ' && fvm dart --version 2>&1 | grep -q 'version: 3.13.4 ' && echo "SC2 PASS" || echo "SC2 FAIL"
grep -q '"dart.flutterSdkPath": ".fvm/versions/3.47.5"' .vscode/settings.json && echo "SC2b PASS" || echo "SC2b FAIL"

# SC3: milestone 브랜치 pubspec + origin/main 불변
grep -qx '  sdk: \^3.13.0' pubspec.yaml && grep -qx 'version: 2.0.0-dev' pubspec.yaml && echo "SC3a PASS" || echo "SC3a FAIL"
git fetch origin --quiet && git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml && echo "SC3b PASS" || echo "SC3b FAIL"
# SC3c: Dart 3.13 미만에서 pub get 실패 — 조사 3 의 임시 사용 프로젝트에서
#   /Users/woody/fvm/versions/3.41.9/bin/dart pub get ; test $? -ne 0  → PASS  (출력에 "requires SDK version ^3.13.0" 포함)

# SC4 / SC5: 문서 존재와 구조 (내용 판정은 소유자 읽기)
test -f VERSIONING.md && grep -q '판정 순서' VERSIONING.md && grep -q '기준표' VERSIONING.md && echo "SC4 PASS" || echo "SC4 FAIL"
head -1 CHANGELOG.md | grep -qx '## 2.0.0 - 미출시' && grep -q '^지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)$' CHANGELOG.md && grep -q '^### 새로 생기는 경고$' CHANGELOG.md && echo "SC5 PASS" || echo "SC5 FAIL"
```

(`grep -q '판정 순서'` 같은 문구 검사는 VERSIONING.md 의 실제 절 제목에 맞춰 plan 에서 확정한다. 위는 D-09 의 용어를 그대로 가정한 것이다.)

### `pubspec.yaml` 변경 (커밋 3)

```yaml
version: 2.0.0-dev          # 1.3.0 에서. 릴리스 때 -dev 를 뗀다 (Phase 6)

environment:
  sdk: ^3.13.0              # ^3.10.4 에서. Dart 3.13 미만은 pub get 단계에서 거부된다
```

다른 줄(`publish_to: 'none'`, `dependencies: flutter_lints: ^6.0.0`, 주석)은 그대로 둔다 `[VERIFIED: local cat -n pubspec.yaml]`.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| FVM 3 (`.fvm/fvm_config.json`, `.fvm/version`) | FVM 4 (`.fvmrc` 가 단일 출처; `.fvm/` 은 파생) | FVM 4.x | 저장소의 `.fvm/version` = 3.38.9 는 FVM 3 흔적. `fvm use` 가 덮어쓴다. `.fvmrc` 만 커밋한다 |
| "`fvm use` 는 Flutter 프로젝트에서만, 아니면 `--force`" (추정) | FVM 4.3.1 은 `pubspec.yaml` 존재만 본다 | 소스 확인 `[CITED: verify_project.workflow.dart]` | 이 저장소에서 `--force` 불필요 |
| `ref: main` 으로 받기 | `ref: vX.Y.Z` annotated tag 로 받기 | 이 마일스톤 | `v1.3.0` 이 첫 tag. README 안내는 Phase 5 |

**Deprecated/outdated:** 이 phase 범위 안에서는 없음.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `.git` 이 있는 실제 저장소에서도 `fvm use 3.47.5` 가 복사본과 같은 두 파일만 바꾼다 | 조사 1 | 낮음 — 실행 직후 `git status --short` 확인 단계가 잡는다. 다르면 손으로 되돌리거나 추가 변경을 커밋에서 뺀다 |
| A2 | `.dart_tool/version` 이 `fvm use` 의 `flutter pub get` 으로 3.47.5 로 바뀐다 | 조사 8 | 없음 — gitignore 대상이고 아무 판정에도 쓰지 않는다 |
| A3 | `flutter_starter_kit` 외 사용 프로젝트 4개의 `pubspec.lock` 도 `resolved-ref: 90a2736` 이다 | Runtime State Inventory | 낮음 — 다른 커밋이어도 `v1.3.0` 의 뜻(1.3.0 내용의 커밋)은 바뀌지 않는다. 그 프로젝트가 `ref: v1.3.0` 으로 옮기면 받는 내용은 같다 |
| A4 | `tag_pattern` + `^2.0.0` 방식에서 pre-release `2.0.0-dev` 가 범위에 들지 않는다 | 조사 6 | 없음 — 이번 마일스톤은 `ref:` 방식이다. 기록용 |

## Open Questions (RESOLVED)

1. **`.claude/CLAUDE.md` 의 `3.41.2` / `^3.10.4` 서술을 이 phase 에서 고칠까?**
   - What we know: 14줄이 이 phase 뒤 사실과 어긋난다 `[VERIFIED: local grep]`. CONTEXT 는 README 만 "건드리지 않는다" 고 했고 CLAUDE.md 는 언급이 없다. 이 파일은 `/gsd-map-codebase` 산출물이다.
   - What's unclear: 소유자가 이 파일을 손으로 유지하길 원하는지, 다음 map-codebase 때 재생성되길 원하는지.
   - Recommendation: 커밋 1 또는 별도 `docs:` 커밋으로 해당 줄의 버전 숫자만 고친다 (작업 5분). 혹은 Phase 5 문서 단계로 미루되 CONCERNS 에 적어 둔다. planner 가 택한다 — 어느 쪽도 success criteria 에 영향 없다.
   - RESOLVED: 이 phase 에서는 고치지 않는다. 소유자 후속 작업으로 기록한다 — 01-01-PLAN.md / 01-03-PLAN.md 의 "알려진 후속 작업" 절, 01-03 Task 3 4단계(실행 시점 줄 번호 재계수 → SUMMARY). 손으로 고칠지 `/gsd-map-codebase` 로 재생성할지는 소유자가 정한다. 개수 정정: caret 붙은 `^3.10.4` 는 4줄(39, 166, 262, 314행)이고 83행은 caret 없는 평문 `3.10.4` 다 (합계 14줄은 그대로).
2. **BASE-02 증거의 임시 사용 프로젝트를 어디서 만들까?**
   - What we know: 스크래치 디렉터리에서 `path: /Users/woody/dv/woody/woody_lints` 로 가리키면 되고, pub 은 대상에 쓰지 않는다.
   - Recommendation: `/private/tmp/claude-501/…/scratchpad/` 아래 새 디렉터리. 저장소 안에 두면 루트 `dart analyze` 범위에 들어가고 커밋 위험이 있다.
   - RESOLVED: 저장소 밖에 `mktemp -d` 로 만든다 — 01-03-PLAN.md Task 2 D 단계(`path:` 의존)와 Task 3 2단계(`git:` + `ref: v1.3.0`). 계획 세션의 scratchpad 경로에는 의존하지 않는다.
3. **`VERSIONING.md` 의 실제 절 제목** — SC4 의 grep 문구는 plan 이 제목을 정한 뒤 맞춘다.
   - RESOLVED: `## 판정 순서`, `## 기준표`, `## 실제 사례`, `## CHANGELOG 항목 형식` 네 절 제목으로 고정했다 (01-02-PLAN.md must_haves 와 Task 1 · Task 2). SC4 는 01-03-PLAN.md Task 3 3단계가 이 네 제목으로 바꿔 돌린다.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| git | REL-01, BASE-02 검사 | ✓ | 2.56.0 | — |
| FVM | BASE-01 | ✓ | 4.3.1 (`/opt/homebrew/bin/fvm`) | 두 파일 손 편집 (조사 2) |
| Flutter 3.47.5 / Dart 3.13.4 | BASE-01, 루트 `pub get`/`analyze` | ✓ | FVM 캐시, `isSetup: true` | — |
| Flutter 3.41.2 / 3.41.4 / 3.41.9 (Dart 3.11.0 / 3.11.1 / 3.11.5) | BASE-02 대조 | ✓ | FVM 캐시, `isSetup: true` | 하나만 있어도 충분 |
| GitHub `origin` (SSH `git@github.com:woodkill/woody_lints.git`) | tag push | ✓ (`git ls-remote` 성공) | — | 없음 — push 는 소유자 확인 뒤 |
| pub.dev 네트워크 | 루트 `dart pub get` | 불필요 — `flutter_lints 6.0.0`, `lints 6.1.0` 오프라인 캐시로 해석됨 `[VERIFIED: local]` | — | — |

**Missing dependencies with no fallback:** 없음.
**Missing dependencies with fallback:** 없음.

## Validation Architecture

> `.planning/config.json` `workflow.nyquist_validation: true` `[VERIFIED: local]`.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | 없음 — Dart 코드가 없는 설정 전용 패키지. 검증은 셸 명령의 종료 코드와 출력 비교 |
| Config file | none — 이 phase 는 `tool/` 을 만들지 않는다 (Phase 2 의 일) |
| Quick run command | 아래 요구사항별 한 줄 명령 (각 1초 이내; SC3c 만 `dart pub get` 수초) |
| Full suite command | § Code Examples "전체 검증 묶음" 블록 |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| BASE-01 | `.fvmrc` 3.47.5, VS Code 경로 일치, `fvm flutter --version` 3.47.5 / Dart 3.13.4 | smoke (shell) | `grep -q '"flutter": "3.47.5"' .fvmrc && grep -q '".fvm/versions/3.47.5"' .vscode/settings.json && fvm dart --version 2>&1 \| grep -q '3.13.4'` | ✅ 도구 내장 |
| BASE-02 | `sdk: ^3.13.0`; Dart 3.11.x 사용 프로젝트의 `pub get` 이 rc≠0 + "requires SDK version ^3.13.0" | integration (shell, 임시 프로젝트) | 조사 3 절차. 판정: `/Users/woody/fvm/versions/3.41.9/bin/dart pub get 2>&1 \| grep -q 'requires SDK version ^3.13.0, version solving failed'` 그리고 rc=1 | ✅ (스크래치에서 생성) |
| BASE-02 (불변) | `origin/main` 의 `lib/`, `pubspec.yaml` = `v1.3.0` | smoke (shell) | `git fetch origin --quiet && git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` | ✅ |
| BASE-03 | VERSIONING.md 에 판정 순서·기준표·사례 세 부분 | 구조 검사 + manual-only (판정 가능성은 소유자가 읽어 확인 — SC4 문구상 "소유자가 … 판정할 수 있다") | `test -f VERSIONING.md && grep -c '^## ' VERSIONING.md` (절 3개 이상) | ✅ |
| BASE-04 | CHANGELOG 최상단 `## 2.0.0 - 미출시`, `지원 SDK:` 줄, `### 새로 생기는 경고` 존재 | smoke (shell) | SC5 명령 (Code Examples) | ✅ |
| REL-01 | 원격 `v1.3.0^{}` = `90a2736`, `git show v1.3.0:pubspec.yaml` version 1.3.0 | smoke (shell, 읽기 전용 네트워크) | SC1 / SC1b 명령 | ✅ |

### Sampling Rate

- **Per task commit:** 해당 요구사항의 한 줄 명령 (위 표).
- **Per wave merge:** "전체 검증 묶음" 블록 전체 (SC3c 는 임시 프로젝트가 남아 있을 때만).
- **Phase gate:** 묶음 전체 PASS + 소유자가 VERSIONING.md 를 읽고 2.0.0 / 1.3.0 사례의 판정에 동의 → `/gsd-verify-work`.

### Wave 0 Gaps

None — 모든 검사가 이미 설치된 git / FVM / Dart SDK 로 돈다. 임시 사용 프로젝트는 BASE-02 task 안에서 만들고 그 출력을 SUMMARY 에 붙인다.

## Security Domain

> `security_enforcement: true` (ASVS level 1) `[VERIFIED: local config.json]`. 실행 코드·네트워크 서비스가 없어 대부분 해당 없음. 해당하는 것은 공급망(supply chain)과 원격 쓰기 작업이다.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (GitHub SSH 키는 소유자 머신의 기존 설정) | — |
| V3 Session Management | no | — |
| V4 Access Control | yes (원격 쓰기) | D-17~D-20: push 는 tag 하나, 소유자 명시 확인 뒤 에이전트가 실행. 브랜치·`--tags` 금지 |
| V5 Input Validation | yes (설정 값) | `pubspec.yaml` 값은 `dart pub get` 이 검증 (3.47.5 에서 성공 확인). CHANGELOG 제목 형식은 REL-03 (Phase 6) |
| V6 Cryptography | no | tag 서명 안 함 (`tag.gpgSign` unset). 요구사항에 없음 |
| V14 Configuration | yes | `.fvmrc` 단일 출처, `.gitignore` 로 `pubspec.lock` / `.fvm/` / `.dart_tool/` 제외 유지 |

### Known Threat Patterns for this phase

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| tag 를 잘못된 커밋에 붙여 push (사용 프로젝트가 다른 내용을 "1.3.0" 으로 받음) | Tampering | push 전 3중 점검(annotated / `^{commit}` = `90a2736` / = `origin/main` / version 1.3.0), 소유자 확인, push 후 `ls-remote ^{}` 확인 |
| 의도치 않은 브랜치 push 로 `.planning/` 공개 | Information Disclosure | `git push origin v1.3.0` 만. 인자 없는 push 금지. 사후 `git ls-remote --heads origin` 확인 |
| `sdk: ^3.13.0` 이 `main` 에 들어가 `ref: main` 프로젝트 `pub get` 파손 | Denial of Service (사용 프로젝트) | milestone 브랜치에만 커밋. `git diff --quiet v1.3.0 origin/main -- lib pubspec.yaml` 로 불변 확인 |
| `fvm use` 가 예상 밖 파일 변경 | Tampering | 실행 후 `git status --short` 두 파일 확인 (실측에서는 두 파일만 변경) |
| 비밀 정보 | — | 없음. `.env`·키 파일 없음 `[VERIFIED: local git ls-files]` |

## Project Constraints (from CLAUDE.md)

`/Users/woody/dv/woody/woody_lints/.claude/CLAUDE.md` 에서 이 phase 에 걸리는 지시:

- **SDK:** Flutter 3.47.x / Dart 3.13 이상만 지원. (BASE-01/02 가 이를 저장소에 반영)
- **Release channel:** 릴리스 전까지 `main` 의 `lib/` 와 `pubspec.yaml` 은 1.3.0 유지 — 이 phase 의 `pubspec.yaml` 변경은 milestone 브랜치에만.
- **Distribution:** Git 의존성 + git tag 로만. pub.dev 에 올리지 않음 (`publish_to: 'none'` 유지).
- **Safety:** 실측은 `flutter_starter_kit` 복사본에서. (이 phase 는 starter kit 을 쓰지 않는다; 임시 사용 프로젝트는 스크래치에)
- **Verification:** plugin 진단 확인은 `dart analyze` — 이 phase 는 `dart analyze` 를 루트 자체 검사에만 쓴다.
- **Dependencies:** `flutter_lints` 는 `dependencies` 에 유지. `dev_dependencies` 로 옮기지 않는다. `riverpod_lint` 는 `pubspec.yaml` 에 넣지 않는다.
- **Documentation:** 한국어, 규칙명·키는 영어 원문. 문서 파일은 대문자 이름 (`VERSIONING.md` 가 관례에 맞음). 한국어 문장에서 영어 식별자 뒤 조사는 한 칸 띄움 ("tag 를", "`.fvmrc` 가").
- **Comments:** 설정의 "왜" 를 적는다. 실측 동작은 버전과 날짜를 함께 적는다 (예: "Flutter 3.47.5 … 2026-09-20 실측") — BASE-02 증거 기록 형식도 이에 맞춘다.
- **도구 버전 고정:** `.fvmrc` 를 바꾸면 `.vscode/settings.json` 도 함께 바꾼다 — `fvm use` 가 둘을 같이 바꿈을 확인했다.
- **버전·CHANGELOG:** `version:` 은 `major.minor.patch`; CHANGELOG 는 최신이 위, `## x.y.z` 제목. (새 형식 `## X.Y.Z - YYYY-MM-DD` 는 D-12 가 확장) 사용 프로젝트에 영향 없는 변경은 "사용하는 프로젝트에는 영향 없음" 명시.
- **Git 커밋:** Conventional Commits, prefix 영어 + 제목 한국어, 버전은 괄호. 커밋 전 린터 실행 (여기서는 `fvm dart analyze` 가 해당; 3.47.5 에서 `No issues found!` 확인).
- **GSD Workflow Enforcement:** 파일 변경은 GSD 명령(`/gsd-execute-phase`)을 통해서만.
- **Anti-patterns (유지):** `analyzer: plugins:` 선언 금지, `include:` 대상 패키지를 `dev_dependencies` 에 두지 않음, 루트 `analysis_options.yaml` 에 공유 규칙 추가 금지, 문서와 설정의 불일치 금지.
- **글로벌 CLAUDE.md:** 한국어 응답·기술 용어 영어 병기, 불확실한 것은 모른다고 말할 것, `.env` 커밋 금지(해당 없음), 커밋 메시지 Conventional Commits.

## Sources

### Primary (HIGH confidence — 이 머신 실측, 2026-10-11)
- `fvm --version`, `fvm use --help`, `fvm api list`, `fvm config`; 저장소 복사본 `pkg-copy/` 에서 `fvm use 3.47.5` 전후 `diff -u`, `fvm flutter --version`, `fvm dart --version`
- `pkg-copy/` 에 `sdk: ^3.13.0` / `version: 2.0.0-dev` 적용 후 Dart 3.13.4 / 3.11.0 `dart pub get`, `dart analyze [--fatal-infos]`
- `consumer/` (`path:`), `consumer-git/` (`git: file://…`, `ref: probe` / `ref: v1.3.0`) 에서 Dart 3.11.0 / 3.11.1 / 3.11.5 / 3.13.4 `dart pub get`, Flutter 3.41.9 `flutter pub get`
- `repo-clone/` + `fake-remote.git` 에서 `git tag -a … -m … -m …`, `git cat-file -t`, `git rev-parse '^{commit}'`, `git show v1.3.0:pubspec.yaml`, `git tag -n99`, `git for-each-ref`, `git push origin v1.3.0`, `git ls-remote --tags`, `git diff --quiet … -- lib pubspec.yaml` 양성·음성 대조, `git push --dry-run origin`
- 실제 저장소(읽기 전용): `git rev-parse origin/main 90a2736 main HEAD`, `git ls-remote --tags/--heads origin`, `git show 90a2736:pubspec.yaml`, `git log -- pubspec.yaml` + 커밋별 `version:`, `git diff --quiet origin/main HEAD -- lib pubspec.yaml`, `git config push.default/push.followTags/tag.gpgSign`, `git ls-files`, `grep -n '3\.41|3\.47|3\.10\.4|3\.13'`, `cat -n` of `pubspec.yaml`, `.fvmrc`, `.vscode/settings.json`, `.gitignore`, `analysis_options.yaml`, `CHANGELOG.md`, `.fvm/*`, `.dart_tool/version`, `pubspec.lock`
- `/Users/woody/dv/woody/flutter_starter_kit/pubspec.lock`, `.fvmrc`, `pubspec.yaml` (읽기 전용)
- `~/fvm/projects.json`, `.planning/config.json`

### Secondary (MEDIUM confidence — 공식 문서 / 원본 소스)
- Context7 `/dart-lang/site-www` → dart.dev/tools/pub/pubspec (version 필드: build / prerelease 접미사), dart.dev/tools/pub/dependencies (semver 2.0.0-rc.1)
- https://git-scm.com/docs/git-ls-remote — annotated tag 의 `^{}` 두 줄 출력, `--refs`
- FVM 4.3.1 소스: `lib/src/commands/use_command.dart`, `lib/src/workflows/use_version.workflow.dart`, `verify_project.workflow.dart` (`if (project.hasPubspec || force) return;`), `setup_gitignore.workflow.dart`, `update_vscode_settings.workflow.dart` (raw.githubusercontent.com/leoafarias/fvm/4.3.1/…)

### Tertiary (LOW confidence)
- https://fvm.app/documentation/guides/basic-commands — `fvm use` 개요, `--skip-pub-get`, `--force` 설명 (실측으로 교차 확인됨)

## Metadata

**Confidence breakdown:**
- 툴체인 (`fvm use`, 파일 변경): HIGH — 복사본 실측 + 소스 확인. `.git` 유무 차이만 `[ASSUMED]` (즉시 검증 가능)
- BASE-02 절차와 오류 문구: HIGH — 세 SDK × 두 의존 방식 실측, 성공 대조 포함
- tag 명령과 점검: HIGH — 가짜 원격에 리허설. 실제 `origin/main` 사실은 읽기 전용으로 확인
- 버전 정책 / CHANGELOG: HIGH — CONTEXT 가 확정; 이 문서는 사례 재료(git 이력)만 보탬
- Pitfalls: HIGH — 대부분 실측에서 직접 관찰

**Research date:** 2026-10-11
**Valid until:** 2026-11-10 (30일). FVM 이나 Dart SDK 를 올리면 `fvm use` 동작·오류 문구를 다시 확인한다. `origin/main` 이 움직였다면 조사 5 의 사실 표를 다시 확인한다.
