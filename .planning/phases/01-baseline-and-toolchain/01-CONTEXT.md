# Phase 1: Baseline and Toolchain - Context

**Gathered:** 2026-10-11
**Status:** Ready for planning

<domain>
## Phase Boundary

본격적인 수정에 들어가기 전의 출발선을 만든다. 이 phase 가 끝나면 다음 다섯 가지가 참이다.

1. 1.3.0 내용의 커밋(`90a2736`)에 `v1.3.0` annotated tag 가 붙어 원격에 있다 (REL-01)
2. 저장소 고정 SDK 가 Flutter 3.47.5 / Dart 3.13.4 다 — `.fvmrc`, `.vscode/settings.json` (BASE-01)
3. milestone 브랜치의 `pubspec.yaml` 이 `sdk: ^3.13.0` 을 선언하고, Dart 3.13 미만에서 `pub get` 이 SDK 불일치로 실패한다. `origin/main` 의 `lib/` 와 `pubspec.yaml` 은 `v1.3.0` 과 같다 (BASE-02)
4. 버전 정책이 문서로 있고 다음 릴리스 번호가 정해져 있다 (BASE-03)
5. CHANGELOG 항목의 형식이 문서로 정해져 있다 (BASE-04)

이 phase 는 `lib/` 를 바꾸지 않는다. README 도 바꾸지 않는다 (Phase 5 에서 통째로 다시 쓴다). 검증 하네스, 프리셋 분리, 규칙 변경은 뒤 phase 의 일이다.

</domain>

<decisions>
## Implementation Decisions

### 이전에 확정되어 그대로 따르는 것

다시 논의하지 않았다. 출처는 ROADMAP.md / REQUIREMENTS.md / PROJECT.md 다.

- `.fvmrc` 는 3.47.5 다 (3.47.7 아님). 실측 대상 `flutter_starter_kit` 과 같은 버전이어야 한다
- SDK 하한은 `^3.13.0` 이고 milestone 브랜치에만 둔다. `main` 의 `lib/` 와 `pubspec.yaml` 은 릴리스 전까지 1.3.0 이다
- `v1.3.0` 은 commit `90a2736` 에 annotated tag 로 붙인다. push 한 tag 는 옮기지 않는다
- 원격에 남는 작업은 실행 시점에 소유자의 명시적 확인을 받는다
- 문서는 한국어로 쓰고 규칙명·키는 영어 원문을 쓴다

### 버전 정책 (ROADMAP 의 D8 확정)

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

### 기준 문서의 위치와 구성

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

### CHANGELOG 항목 형식 (BASE-04)

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

### `v1.3.0` tag 와 원격 작업 (ROADMAP 의 D4 확정)

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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 범위와 요구사항

- `.planning/ROADMAP.md` § "Phase 1: Baseline and Toolchain" — goal, success criteria 5개, decision point D4 / D8, notes (`fvm use --force` 미확인 등)
- `.planning/ROADMAP.md` § "모든 phase 에 걸친 제약" — `main` 은 1.3.0 유지, 원격 작업은 소유자 확인
- `.planning/REQUIREMENTS.md` — BASE-01, BASE-02, BASE-03, BASE-04, REL-01. Out of Scope 표
- `.planning/PROJECT.md` § Constraints, § Key Decisions — 릴리스 채널, milestone 브랜치 전략, `v` tag 의 뜻

### 버전 정책과 CHANGELOG 형식의 근거

- `.planning/research/SUMMARY.md` § "해당 phase 계획 때 정하면 되는 결정" (D8, D12), § "문서 사이에 어긋나는 지점" 9번
- `.planning/research/ARCHITECTURE.md` § "lint 패키지에서 semver 가 뜻하는 것" — 권장 정책 표와 선례. **주의:** 이 표의 "규칙 제거 = PATCH" 와 "심각도 상향 = MINOR" 는 D-03 / D-04 로 대체되었다
- `.planning/research/PITFALLS.md` § "Pitfall 18" — 유효 규칙 집합의 네 층, 권장 정책, CHANGELOG 의 "새로 생길 수 있는 진단" 절. **주의:** "규칙 제거 = patch(조건부 minor)" 는 D-03 으로 대체되었다
- `.planning/research/FEATURES.md` — CHANGELOG 를 `lints` 형식(added / removed + 지원 SDK)으로 두라는 권고

### tag 와 원격 작업

- `.planning/research/PITFALLS.md` § "Pitfall 16" (tag 이동·push 누락·엉뚱한 커밋), § "Pitfall 17" (`main` 이 곧 배포, `v1.3.0` 을 맨 앞으로)
- `.planning/research/ARCHITECTURE.md` § "Pattern 5: tag 가 곧 릴리스, 이동 금지" — `resolved-ref`, annotated tag 를 쓰는 이유, tag 이름을 `v` + pubspec `version` 에 맞추는 이유

### 툴체인

- `.planning/research/STACK.md` — Flutter 3.47.5 / Dart 3.13.4 선택 근거, `sdk: ^3.13.0`, FVM 4.3.1 과 `fvm use` 의 `--force` 미검증 메모
- `.planning/codebase/CONCERNS.md` § "FVM 고정 버전과 문서상 검증 버전의 불일치", § "CHANGELOG 누락", § "릴리스 tag 부재"

### 관례

- `.claude/CLAUDE.md` § Conventions — 문서는 한국어, 영어 식별자 뒤 조사는 한 칸 띄움, 문서 파일은 대문자 이름, Conventional Commits, `.fvmrc` 를 바꾸면 `.vscode/settings.json` 도 함께 바꿈

### 고치거나 새로 만드는 파일

- `.fvmrc`, `.vscode/settings.json` — 지금 3.41.2
- `pubspec.yaml` — 지금 `version: 1.3.0`, `sdk: ^3.10.4`
- `CHANGELOG.md` — 지금 1.3.0 과 1.0.0 두 항목, 날짜 없음
- `VERSIONING.md` — 새로 만든다

</canonical_refs>

<code_context>
## Existing Code Insights

### 논의 시점의 저장소 상태 (2026-10-11 확인)

- tag 는 로컬에도 원격에도 하나도 없다
- `origin/main` 은 `90a2736` (1.3.0) 이다
- 로컬 `main` 은 `origin/main` 보다 커밋 7개 앞선다. 전부 `.planning/` 문서이고 `lib/` 와 `pubspec.yaml` 은 `90a2736` 과 차이가 없다
- 현재 브랜치 `gsd/v2.0-package-rework` 는 로컬 `main` 보다 커밋 1개(roadmap) 앞서며 원격에 없다
- `origin` 은 `git@github.com:woodkill/woody_lints.git` (SSH), 공개 저장소다
- FVM 캐시에 3.47.5 (Dart 3.13.4) 가 설치되어 있다. 3.41.2 / 3.41.4 / 3.41.9 (Dart 3.11.x) 도 있어 "3.13 미만에서 실패" 확인에 쓸 수 있다
- `docs/` 폴더는 없다

### Reusable Assets

- `CHANGELOG.md` 의 1.3.0 항목 — 하위 불릿으로 원인과 영향을 적는 기존 문체. 새 형식의 "올리기 전에" / "그 밖의 변경" 칸 문장에 그대로 쓸 수 있다
- git 이력의 version 변경 커밋들 (`dbcd20b` 1.2.5, `90a2736` 1.3.0 등) — VERSIONING.md 의 사례 대입 예시 재료

### Established Patterns

- `.fvmrc` 와 `.vscode/settings.json` 의 `dart.flutterSdkPath` 는 같은 버전을 가리켜야 한다
- `pubspec.lock` 과 `.fvm/` 은 `.gitignore` 대상이다. 커밋하지 않는다
- 루트 `analysis_options.yaml` 의 `lib/analysis_options.yaml` exclude 는 이 phase 에서 그대로 둔다 (제거는 Phase 3 의 PRESET-06)
- 문서 파일은 대문자 이름이다 (`README.md`, `CHANGELOG.md`) — `VERSIONING.md` 가 이 관례를 따른다

### Integration Points

- CHANGELOG 의 최상단 제목은 Phase 6 의 일치 검사(REL-03: tag = pubspec `version` = CHANGELOG 최상단 버전)가 읽는다. 제목이 `## X.Y.Z - 날짜` 형식이므로 버전은 ` - ` 앞의 토큰이다
- CHANGELOG 의 "새로 생기는 경고" 표는 Phase 4 의 실측 결과가 들어갈 자리다. Phase 4 평가표의 열(심각도, 실측 건수, `dart fix` 가능 건수)과 대응한다
- `pubspec.yaml` 의 `version: 2.0.0-dev` 는 Phase 6 에서 `2.0.0` 이 된다

</code_context>

<specifics>
## Specific Ideas

### 소유자가 고른 CHANGELOG 예시 (그대로 따른다)

규칙 하나를 추가한 가상의 minor 릴리스:

```markdown
## 2.1.0 - 2026-12-01

지원 SDK: Dart 3.13 이상 (변경 없음)

### 추가한 규칙

- `rule_a` — 켠 이유 한 줄

### 새로 생기는 경고

| 규칙     | 강도 | 실측 | dart fix |
|----------|------|------|----------|
| `rule_a` | info | 12건 | 12건     |
| `rule_b` | info | 3건  | 0건      |

실측: flutter_starter_kit (Dart 파일 169개), Flutter 3.47.5, 2026-11-20
```

Phase 1 이 만드는 2.0.0 자리:

```markdown
## 2.0.0 - 미출시

지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)

### 올리기 전에

- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.

### 새로 생기는 경고

(Phase 4 실측 후 채움)

## 1.3.0
```

### 소유자와 소통하는 방식

- 소유자는 git 과 도구 용어를 쉬운 말로 풀어 주기를 원한다. tag push 확인 요청(D-19)과 VERSIONING.md(D-10)에 이 점이 직접 걸린다. 논의에서 통한 표현: tag 는 "이름표", major / minor / patch 는 "맨 앞 / 가운데 / 맨 뒷자리" 와 책의 판수 비유, push 는 "GitHub 에 올린다"
- 선택을 요청할 때는 용어 풀이와 "이렇게 하면 / 저렇게 하면" 비교를 먼저 보이고, 권고안과 그 이유를 함께 준다

### 참고한 외부 형식

- Keep a Changelog 1.1.0 (https://keepachangelog.com/en/1.1.0/) — 빈 칸 생략, ISO 날짜, 미출시 칸. 영어 칸 이름(Added / Removed)은 쓰지 않고 한국어 칸 이름을 쓴다
- Dart `lints` CHANGELOG — "추가 / 제거 + 최소 SDK" 구성

</specifics>

<deferred>
## Deferred Ideas

논의 중에 나왔지만 다른 phase 의 일인 것.

- **milestone 브랜치를 올리면 `.planning/` 이 공개된다** — 이 저장소는 공개 저장소다. Phase 2 에서 CI 를 위해 브랜치 push 확인을 받을 때 이 점을 소유자에게 다시 알린다. 민감 정보는 없고 조사 내용, 로드맵, 사용 프로젝트 이름이 들어 있다
- **일치 검사가 "미출시" 를 거부하게 할지** — CHANGELOG 최상단 제목의 날짜 자리가 "미출시" 인 채로 tag 를 붙이면 실패하도록 REL-03 검사를 넓힐 수 있다. Phase 6 계획 때 검토한다
- **릴리스 절차 문서** — 번호를 붙인 단계(버전·CHANGELOG 커밋 → CI 확인 → annotated tag → push → 확인 → smoke test)를 어디에 둘지. VERSIONING.md 에 덧붙일 수도 있다. Phase 6 에서 정한다
- **Phase 4 근거 문서의 자리** — 규칙 근거 문서(DOCS-11)와 미채택 목록(RULES-08)을 루트에 둘지 `docs/` 를 만들지. Phase 4 에서 정한다
- **옛 CHANGELOG 제목에 날짜 붙이기** — 1.3.0 이전 항목의 날짜는 git 이력에서 알 수 있다. Phase 5 의 DOCS-08 에서 검토한다

</deferred>

---

*Phase: 1-Baseline and Toolchain*
*Context gathered: 2026-10-11*
