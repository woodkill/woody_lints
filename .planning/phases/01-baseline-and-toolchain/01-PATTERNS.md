# Phase 1: Baseline and Toolchain - Pattern Map

**Mapped:** 2026-10-11
**Files analyzed:** 5개 파일 + git tag 1개 (수정 4, 신규 1, tag 1)
**Analogs found:** 6 / 6

이 저장소는 Dart 코드가 없는 설정 전용 패키지(configuration-only package)다. 여기서 "analog" 는 코드 모듈이 아니라 **새 파일 또는 바뀌는 파일이 따라야 할 형식·문체의 기존 본보기(파일 또는 구절)** 다. 모든 analog 경로는 `git ls-files` 로 추적 상태를 확인했다 (gitignore 미러 경로 없음).

파일 내용 인용은 2026-10-11 작업 트리(`gsd/v2.0-package-rework`, HEAD `afed829`)에서 `cat -n` 으로 확인한 것이다. `lib/`, `pubspec.yaml`, `CHANGELOG.md`, `.fvmrc`, `.vscode/settings.json` 은 `origin/main`(`90a2736`) 과 차이가 없다.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.fvmrc` (수정) | config (FVM 버전 고정) | 선언 → FVM 이 읽음 | 자기 자신 (현재 내용), 수정은 `fvm use 3.47.5` 산출물 | exact (self) |
| `.vscode/settings.json` (수정) | config (편집기 SDK 경로) | 선언 → VS Code Dart 확장이 읽음 | 자기 자신, `.fvmrc` 와 같은 값을 가리킴 | exact (self) |
| `pubspec.yaml` (수정: `version`, `environment.sdk`) | config (패키지 매니페스트) | 선언 → pub version solver 가 읽음 | 자기 자신 — 13-15행 한국어 "왜" 주석이 주석 문체 패턴 | exact (self) |
| `CHANGELOG.md` (수정: 맨 위 `## 2.0.0 - 미출시` 항목 삽입) | doc (변경 이력) | 사람 + Phase 6 REL-03 검사가 읽음 | `CHANGELOG.md` 1.3.0 항목 (1-7행) — 하위 불릿 문체. 뼈대는 CONTEXT D-12~D-14 가 확정 | role-match (문체만; 형식은 새 것) |
| `VERSIONING.md` (신규, 저장소 루트) | doc (정책 문서) | 사람(몇 달 뒤 소유자)이 읽음 | `README.md` (제목·목록 구조), `CHANGELOG.md` (하위 불릿 문체), `lib/analysis_options.yaml` 49-56행 (실측 기록 문체), `.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md` 43-55행 (기준표 그대로 복사) | role-match |
| git tag `v1.3.0` (파일 아님, annotated tag 메시지) | release marker | git 원격 refs/tags | 커밋 `90a2736` 의 메시지 (Conventional Commits, 제목 한국어, 버전 괄호) | partial (메시지 문체) |

## Pattern Assignments

### `.fvmrc` (config, 선언)

**Analog:** 자기 자신 — `/Users/woody/dv/woody/woody_lints/.fvmrc` (tracked)

**현재 내용 전체 (1-3행):**
```json
{
  "flutter": "3.41.2"
}
```

**바뀌는 것:** 2행의 값 `"3.41.2"` → `"3.47.5"` 한 곳. 3.47.7 이 아니다 (CONTEXT "이전에 확정").

**바이트 단위로 보존할 것:**
- 파일 끝 개행 **없음** (마지막 바이트 `0x7d` = `}`). RESEARCH.md 조사 1 에서 `fvm use` 도 개행 없이 다시 쓰는 것을 확인했으므로 `fvm use 3.47.5` 로 바꾸면 diff 는 2행 한 줄만 난다
- 2칸 들여쓰기, 큰따옴표 키·값, 키 이름 `flutter`
- 손으로 고칠 경우에도 위 형식을 그대로 두고 값만 바꾼다. 개행을 덧붙이면 diff 에 `\ No newline at end of file` 노이즈가 생기지만 동작 차이는 없다

**검증 (RESEARCH.md 조사 2):**
```bash
grep -q '"flutter": "3.47.5"' .fvmrc && echo PASS || echo FAIL
```

---

### `.vscode/settings.json` (config, 선언)

**Analog:** 자기 자신 — `/Users/woody/dv/woody/woody_lints/.vscode/settings.json` (tracked)

**현재 내용 전체 (1-3행):**
```json
{
  "dart.flutterSdkPath": ".fvm/versions/3.41.2"
}
```

**바뀌는 것:** 2행의 값 `.fvm/versions/3.41.2` → `.fvm/versions/3.47.5`. `.fvm/flutter_sdk` 형태로 바꾸지 않는다 — 현재 형식(`.fvm/versions/<버전>` 상대 경로)을 유지하며, `fvm use` 가 쓰는 값도 이 형식이다 (RESEARCH.md 조사 2).

**바이트 단위로 보존할 것:**
- 파일 끝 개행 **없음** (마지막 바이트 `0x7d`)
- 2칸 들여쓰기, 큰따옴표, 키 이름 `dart.flutterSdkPath`

**함께 지켜야 할 관례 (CLAUDE.md "도구 버전 고정"):** `.fvmrc` 의 버전과 이 파일의 경로 끝 버전은 항상 같다. 두 파일을 **한 커밋**(`chore:`)에 넣는다.

**검증:**
```bash
grep -q '"dart.flutterSdkPath": ".fvm/versions/3.47.5"' .vscode/settings.json && echo PASS || echo FAIL
```

---

### `pubspec.yaml` (config, 패키지 매니페스트)

**Analog:** 자기 자신 — `/Users/woody/dv/woody/woody_lints/pubspec.yaml` (tracked). 주석 문체의 본보기는 13-15행.

**현재 내용 전체 (1-17행):**
```yaml
name: woody_lints
description: Woody's custom lint rules for Flutter projects.
version: 1.3.0

# pub.dev에 올리지 않고 개인적으로 사용
publish_to: 'none'

repository: https://github.com/woodkill/woody_lints.git

environment:
  sdk: ^3.10.4

# lib/analysis_options.yaml 이 `include: package:flutter_lints/flutter.yaml` 을
# 쓰므로 사용하는 프로젝트에 전달되는 dependencies 에 둔다
# (dev_dependencies 는 사용하는 쪽 의존성 그래프에 포함되지 않는다).
dependencies:
  flutter_lints: ^6.0.0
```

**바뀌는 것 (정확히 두 줄):**
- 3행 `version: 1.3.0` → `version: 2.0.0-dev` (D-07)
- 11행 `  sdk: ^3.10.4` → `  sdk: ^3.13.0` (BASE-02)

**바이트 단위로 보존할 것:**
- 1-2행, 5-8행, 13-17행 전부 그대로. 특히 `publish_to: 'none'` (홑따옴표), `flutter_lints: ^6.0.0`, 13-15행 주석
- 2칸 들여쓰기 (`  sdk:`, `  flutter_lints:`)
- 파일 끝 개행 **있음** (마지막 바이트 `0x0a`). `.fvmrc` 와 다르다
- `riverpod_lint` 를 추가하지 않는다. `flutter_lints` 를 `dev_dependencies` 로 옮기지 않는다 (CLAUDE.md 의존성 선언 규칙)

**주석 문체 패턴 (13-15행) — 새 주석을 덧붙일 경우 따를 것:**
- "무엇" 이 아니라 "왜" 를 적는다 ("… 쓰므로 … 에 둔다", 괄호로 반대 선택지가 안 되는 이유)
- 한국어 문장, 영어 식별자 뒤 조사는 한 칸 띄움 (`lib/analysis_options.yaml 이`, `dependencies 에`)
- 설정 키 바로 위 줄에 `#` 주석, 들여쓰기는 키와 같게
- RESEARCH.md "Code Examples" 가 제시한 줄 끝 주석(`version: 2.0.0-dev  # 1.3.0 에서. …`) 형식은 이 파일에 선례가 없다. 주석을 넣는다면 13-15행처럼 **윗줄 주석** 으로 넣는 것이 기존 관례에 맞다. 주석 없이 값만 바꾸는 것도 허용된다 — 이유는 CHANGELOG 2.0.0 항목과 커밋 본문에 남는다

**검증 (RESEARCH.md SC3a):**
```bash
grep -qx '  sdk: \^3.13.0' pubspec.yaml && grep -qx 'version: 2.0.0-dev' pubspec.yaml && echo PASS || echo FAIL
```

---

### `CHANGELOG.md` (doc, 변경 이력)

**Analog:** `/Users/woody/dv/woody/woody_lints/CHANGELOG.md` 1-7행의 1.3.0 항목 (tracked) — **문장 문체** 의 본보기. 항목의 **뼈대(제목·칸 이름·표)** 는 기존 파일에 선례가 없고 CONTEXT D-12~D-14 와 `<specifics>` 의 예시가 확정한 것이다.

**현재 내용 전체 (1-11행):**
```markdown
## 1.3.0

- riverpod_lint 를 최상위 `plugins:` (analysis_server_plugin) 방식으로 전환.
  - 옛 `analyzer: plugins: - riverpod_lint` 선언은 riverpod_lint 3.x 에서 아무것도 로드하지 않아 규칙이 실행된 적이 없었다 → 이번 버전부터 riverpod_lint 규칙이 처음으로 켜진다.
  - Dart 3.13 (Flutter 3.47) 의 `included_file_warning` (legacy plugin deprecated) 해소.
- `flutter_lints` 를 `dev_dependencies` → `dependencies` 로 이동. `include: package:flutter_lints/flutter.yaml` 이 사용하는 프로젝트의 직접 의존 여부와 무관하게 해석된다.
- 저장소 자체 분석용 루트 `analysis_options.yaml` 추가 — `lib/analysis_options.yaml` 의 `plugins:` 가 이 저장소 안에서는 inner 옵션으로 취급되어 나는 `plugins_in_inner_options` 경고를 제외한다. 사용하는 프로젝트에는 영향 없음.

## 1.0.0

- Initial version.
```

**바뀌는 것:** 1행 `## 1.3.0` **앞에** 새 항목을 삽입한다. 1-11행은 한 글자도 바꾸지 않는다 (D-16). 새 항목과 `## 1.3.0` 사이는 빈 줄 하나.

**삽입할 내용 (CONTEXT `<specifics>` 231-245행, RESEARCH.md 692-706행 — 그대로 쓴다):**
```markdown
## 2.0.0 - 미출시

지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)

### 올리기 전에

- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.

### 새로 생기는 경고

(Phase 4 실측 후 채움)

```

**형식 규칙 (D-12, D-13 — VERSIONING.md 에도 같은 내용을 적는다):**
- 제목 `## X.Y.Z - YYYY-MM-DD`. ` - ` 는 **한 번만** — Phase 6 REL-03 이 ` - ` 앞 토큰을 버전으로 읽는다. 미출시일 때 날짜 자리는 `미출시`
- 제목 바로 아래 `지원 SDK: …` 줄은 항상. `(변경 없음)` 또는 `(이전: …)`
- 칸은 `### 올리기 전에` / `### 추가한 규칙` / `### 뺀 규칙` / `### 그 밖의 변경` 은 해당할 때만, `### 새로 생기는 경고` 는 항상 (없으면 `없음`)
- 규칙 불릿: `` - `rule_name` — 켠 이유 한 줄 `` (em dash `—`, 양쪽 한 칸)
- "새로 생기는 경고" 표: 4열 `규칙` / `강도` / `실측` / `dart fix`, 아래 한 줄 `실측: flutter_starter_kit (Dart 파일 N개), Flutter X.Y.Z, YYYY-MM-DD`
- 영어 칸 이름(Added / Removed)은 쓰지 않는다

**기존 1.3.0 항목에서 재사용할 문체 (하위 불릿·문장):**
- 불릿 끝에 마침표 `.` 를 찍는다 (3, 5, 6, 7행). 새 항목의 "올리기 전에" 불릿도 마침표로 끝난다 (`… 에 머문다.`)
- 원인 → 결과를 `→` 로 잇는다 (4행). 한 불릿 안에서 보충은 ` — ` (em dash) 로 잇는다 (7행)
- 규칙명·키·파일명은 백틱으로 감싼다 (`` `plugins:` ``, `` `flutter_lints` ``, `` `analysis_options.yaml` ``)
- 영어 식별자 뒤 조사는 한 칸 띄움 (`riverpod_lint 를`, `` `flutter_lints` 를 ``, `` `plugins:` 가 ``)
- 받는 쪽에 영향이 없으면 "사용하는 프로젝트에는 영향 없음." 을 명시 (7행, CLAUDE.md 관례). 2.0.0 항목에서는 "올리기 전에" 칸이 그 반대 역할을 한다
- Dart / Flutter 버전 쌍 표기: `Dart 3.13 (Flutter 3.47)` (5행). 새 항목의 `Dart 3.13 미만(Flutter 3.47 미만)` 과 같은 계열

**바이트 단위로 보존할 것:** 1-11행 전체, 파일 끝 개행 **있음** (`0x0a`). 1.3.0 / 1.0.0 제목에 날짜를 붙이지 않는다 (Deferred, Phase 5 DOCS-08).

**검증 (RESEARCH.md SC5):**
```bash
head -1 CHANGELOG.md | grep -qx '## 2.0.0 - 미출시' && grep -q '^지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)$' CHANGELOG.md && grep -q '^### 새로 생기는 경고$' CHANGELOG.md && echo PASS || echo FAIL
```

---

### `VERSIONING.md` (doc, 정책 문서 — 신규)

**Analog (복합):**

| 가져올 것 | 출처 | 비고 |
|-----------|------|------|
| 파일 이름·위치 | `README.md`, `CHANGELOG.md` (루트, 대문자 이름) | `docs/` 를 만들지 않는다 (D-08) |
| 제목 구조 (`##` 절, `-` 불릿, 들여쓴 하위 불릿) | `README.md` 16-21행, 70-89행 | 문서 최상위 `#` 제목은 README 에 없다. VERSIONING.md 는 `# ` 제목 하나를 두어도 되나 RESEARCH.md SC4 의 `grep -c '^## '` 가 **`##` 절 3개 이상** 을 가정하므로 세 부분은 `##` 로 둔다 |
| 기준표 내용 | `01-CONTEXT.md` 43-55행 (D-05 표) | **그대로 담는다** (D-05: "VERSIONING.md 의 기준표는 이 내용을 그대로 담는다"). 열 이름 `변경` / `등급` / `받는 쪽이 겪는 일` |
| 판정 순서 ①~④ | `01-CONTEXT.md` 67-71행 (D-09) | 순서와 문구 유지 |
| 사례 재료 | `01-RESEARCH.md` 657-675행 (version 변경 11건 표) | 최소 1.3.0(minor) + 2.0.0(major). `9451f6b`(규칙 추가를 patch 로 냈던 것) 추가 권고 |
| 쉬운 말 풀이 (D-10) | `01-RESEARCH.md` 677-682행 | "맨 앞자리(major)", "가운데 자리(minor)", "맨 뒷자리(patch)", 책의 판수 비유, tag = 이름표, push = GitHub 에 올린다 |
| 실측 기록 문체 | `lib/analysis_options.yaml` 55-56행 | "… 않았다 (3.41.9 는 표시, 2026-09-20 실측)." — 확인한 동작은 **버전 + 날짜** 를 함께 적는다 |
| CHANGELOG 형식 설명 | 이 문서 위 `CHANGELOG.md` 절의 "형식 규칙" + CONTEXT `<specifics>` 210-227행의 2.1.0 가상 예시 | 예시를 그대로 옮겨 "이렇게 쓴다" 를 보인다 |

**README.md 구조 패턴 (16-21행) — 절 제목과 불릿:**
```markdown
## 핵심가치

이 규칙 세트는 다음 세 가지 핵심 가치에 집중:
- 성능(Performance): 불필요한 리빌드를 방지. 메모리 효율 최적화.
- 안정성(Bug Prevention): 런타임 에러와 논리적 오류를 컴파일 단계에서 포착.
- 가독성(Readability): 누구나 쉽게 읽을 수 있는 명확한 코드 지향.
```
- `##` 절 제목은 한국어 명사구. 영어 용어는 괄호로 병기 `성능(Performance)` — D-10 의 "맨 앞자리(major)" 와 같은 꼴
- README 70-92행의 하위 불릿은 4칸 들여쓰기와 탭(92행)이 섞여 있다 — **따르지 않는다**. `CHANGELOG.md` 4-5행의 2칸 들여쓰기를 쓴다
- README 는 Phase 5 에서 통째로 다시 쓰므로 템플릿 주석(1-12행)이나 "…됨..." 같은 구어체는 본보기가 아니다

**표 패턴 — `01-CONTEXT.md` 43-55행 (복사해 넣을 기준표):**
```markdown
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
```
CONTEXT.md 에서는 불릿 안에 2칸 들여쓴 표였다. VERSIONING.md 에서는 들여쓰기 없이 절 본문에 둔다.

**실측 기록 문체 — `lib/analysis_options.yaml` 49-56행:**
```yaml
# analyzer plugin (Dart 3.10+ analysis_server_plugin 방식) — 최상위 키.
# riverpod_lint 3.x 는 이 방식만 지원한다. 옛 `analyzer: plugins:` 선언은
# 아무것도 로드하지 않았고, Dart 3.13 부터 legacy plugin 경고를 낸다.
# plugin 은 프로젝트 pubspec.lock 과 별도로 Dart Analysis Server 의 plugin 캐시
# (~/.dartServer/.plugin_manager)에서 해석된다.
# 이 섹션을 바꾼 뒤에는 Dart Analysis Server 를 재시작해야 반영된다.
# 결과 확인은 `dart analyze` 로 한다 — Flutter 3.47.5 의 `flutter analyze` 는
# plugin 진단을 표시하지 않았다 (3.41.9 는 표시, 2026-09-20 실측).
```
2.0.0 사례 줄에 BASE-02 증거를 덧붙일 때(RESEARCH.md 496행, 선택 사항) 이 꼴을 따른다: "(Dart 3.11.5 에서 `pub get` 이 `version solving failed` 로 끝나는 것을 2026-10-XX 확인)".

**권고 절 구성 (Claude's Discretion 범위, D-09 세 부분 필수):**
```markdown
# 버전 정책 (Versioning)

(한 단락: 누가 읽는 문서인가, 버전 번호는 "받는 쪽이 겪는 일" 을 알리는 신호라는 D-01, 세 자리 풀이 D-10)

## 판정 순서

1. … → major (맨 앞자리)
2. … → minor (가운데 자리)
3. … → patch (맨 뒷자리)
4. … → 올리지 않는다

## 기준표

(D-05 표 그대로)

## 실제 사례

- 1.3.0 — …  → minor
- 2.0.0 — …  → major
- (1.2.3 — `slash_for_doc_comments` 추가를 patch 로 냈다. 지금 정책이면 minor)

## CHANGELOG 항목 형식

(D-12 뼈대, D-13 표, ` - ` 한 번 규칙, 2.1.0 가상 예시 그대로)
```
절 제목은 plan 이 확정한 뒤 RESEARCH.md SC4 의 grep 문구(`판정 순서`, `기준표`)와 맞춘다.

**문체 규칙 (CLAUDE.md Conventions, 전 문서 공통):**
- 한국어. 규칙명·키·파일명·명령은 영어 원문을 백틱으로
- 영어 식별자 뒤 조사 한 칸 띄움: `tag 를`, `` `pubspec.yaml` 의 ``, `major 는`
- 파일 끝 개행 있음 (README.md, CHANGELOG.md 와 같게)
- README / VERSIONING 사이 링크는 넣지 않는다 (D-11, Phase 5)

---

### git tag `v1.3.0` (release marker — 파일 아님)

**Analog:** 커밋 `90a2736` 의 메시지 (`git log -1 --format=%B 90a2736`) — Conventional Commits, 제목 한국어, 버전은 괄호. 이 저장소에는 tag 가 하나도 없어 tag 메시지 선례는 없다.

**커밋 메시지 패턴 (`90a2736`, 제목과 본문 첫 부분):**
```text
feat: riverpod_lint 를 최상위 plugins: 방식으로 전환 (1.3.0)

- lib/analysis_options.yaml: 옛 `analyzer: plugins: - riverpod_lint` 를 최상위
  `plugins: riverpod_lint: ^3.1.3` 으로 교체
  …
검증 (flutter_riverpod 사용 임시 프로젝트, path 의존):
- Flutter 3.47.5 dart analyze: missing_provider_scope 검출 · legacy 경고 0
…
```
- 제목: `<type>: <한국어 제목> (<버전>)`. 본문은 `-` 불릿, 끝에 `검증 (…)` 절로 실측을 적는다
- 이전 커밋들(`dbcd20b chore: bump version to 1.2.5 …`, `9451f6b slash_for_doc_comments 추가`)은 자유 형식이라 본보기가 아니다

**tag 메시지 (Claude's Discretion 기본값, RESEARCH.md 조사 5 — 그대로 권고):**
```bash
git tag -a v1.3.0 90a2736 \
  -m "woody_lints 1.3.0" \
  -m "2.0.0 작업 전 기준점. Dart 3.13 미만 프로젝트는 이 tag 에 머문다"
```
- `-m` 두 번 = 제목 단락 + 본문 단락. 하나의 `-m` 에 `\n` 을 넣지 않는다 (RESEARCH.md Pitfall 6)
- 제목에 Conventional Commits prefix 는 붙이지 않는다 (tag 는 커밋이 아니다). 패키지명 + 버전 형태
- 본문의 "`tag 에`" 처럼 영어 식별자 뒤 조사 띄어쓰기 유지
- `-a` 필수 (annotated). `-s` 는 쓰지 않는다 (`tag.gpgSign` unset, 요구사항 없음)

**이 phase 의 커밋 메시지 (RESEARCH.md 조사 7 권고, `90a2736` 패턴 적용):**

| 순서 | 제목 (예) | 포함 파일 |
|------|-----------|-----------|
| 1 | `chore: 저장소 고정 Flutter 를 3.47.5 (Dart 3.13.4) 로 올림` | `.fvmrc`, `.vscode/settings.json` |
| 2 | `docs: 버전 정책과 CHANGELOG 형식 문서(VERSIONING.md) 추가` | `VERSIONING.md` |
| 3 | `feat!: 지원 SDK 하한을 Dart 3.13 으로 올림 (2.0.0-dev)` | `pubspec.yaml`, `CHANGELOG.md` |

커밋 3 본문에는 `90a2736` 처럼 `검증 (…)` 절을 두고 BASE-02 실측(SDK 버전·오류 문구·rc·날짜)을 적는다. 커밋 끝에는 세션의 attribution 줄을 붙인다.

## Shared Patterns

### 한국어 문서 문체 (전 파일 공통)
**Source:** `.claude/CLAUDE.md` § Conventions "Comments"; 실례 `CHANGELOG.md` 3-7행, `pubspec.yaml` 13-15행, `lib/analysis_options.yaml` 49-56행
**Apply to:** `CHANGELOG.md` 2.0.0 항목, `VERSIONING.md`, `pubspec.yaml` 주석(넣는 경우), tag 메시지, 커밋 메시지
- 한국어 문장, 규칙명·키·파일명·명령은 영어 원문 (백틱)
- 영어 식별자 뒤 조사는 한 칸 띄움: `riverpod_lint 를`, `` `plugins:` 가 ``, `tag 에`
- "무엇" 보다 "왜" 를 적는다
- 실측으로 확인한 동작은 버전과 날짜를 함께: `(3.41.9 는 표시, 2026-09-20 실측)`
- 받는 쪽 영향이 없으면 "사용하는 프로젝트에는 영향 없음" 명시

### 파일 끝 개행 상태 (파일별로 다르다 — 바꾸지 않는다)
**Source:** `tail -c 1 | xxd` 실측 (2026-10-11)
**Apply to:** 수정하는 모든 파일

| 파일 | 끝 개행 | 비고 |
|------|---------|------|
| `.fvmrc` | 없음 (`0x7d`) | `fvm use` 가 같은 상태로 다시 씀 |
| `.vscode/settings.json` | 없음 (`0x7d`) | 같음 |
| `pubspec.yaml` | 있음 (`0x0a`) | |
| `CHANGELOG.md` | 있음 (`0x0a`) | |
| `README.md` | 있음 (`0x0a`) | 이 phase 는 건드리지 않음 |
| `.gitignore` | 없음 (`0x2f`) | 이 phase 는 건드리지 않음. `fvm use` 도 `.fvm/` 줄이 있어 건드리지 않음 |
| `VERSIONING.md` (신규) | 있음으로 만든다 | Markdown 문서 관례 (README / CHANGELOG 와 같게) |

### 들여쓰기·인용 부호
**Source:** `pubspec.yaml`, `.fvmrc`, `.vscode/settings.json`, `CHANGELOG.md`
**Apply to:** 수정하는 모든 파일
- YAML / JSON: 2칸 들여쓰기. JSON 은 큰따옴표, YAML 의 `publish_to: 'none'` 은 홑따옴표 유지
- Markdown 하위 불릿: 2칸 들여쓰기 (`CHANGELOG.md` 4-5행). README 70-92행의 4칸/탭 혼용은 따르지 않는다

### "같은 커밋에 변경과 기록" + 순서 제약
**Source:** CONTEXT D-15, D-18; RESEARCH.md 조사 7, Pitfall 1
**Apply to:** plan 의 task 순서
- tag 가 첫 작업 (어떤 파일도 바꾸기 전)
- `.fvmrc` 커밋이 `pubspec.yaml` 커밋보다 **앞** — 하한을 올린 뒤에는 3.41.x 로 저장소 루트 `pub get` 이 깨진다
- `VERSIONING.md` 커밋이 `CHANGELOG.md` 커밋보다 앞 — CHANGELOG 항목이 그 형식을 따른다
- `pubspec.yaml` 과 `CHANGELOG.md` 2.0.0 항목은 한 커밋

### 변경 후 diff 범위 검사
**Source:** RESEARCH.md 조사 1, Pitfall 7
**Apply to:** `fvm use 3.47.5` 직후, 각 커밋 직전
```bash
git status --short      # 기대: ' M .fvmrc', ' M .vscode/settings.json' (+ 기존 '?? .planning/research/.cache/')
git diff --stat         # 바뀐 추적 파일이 의도한 것뿐인지
```

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| (없음) | | | 모든 대상에 형식·문체 본보기가 있다. 단, `CHANGELOG.md` 2.0.0 항목의 **뼈대(제목 날짜, `지원 SDK:` 줄, `###` 칸, 4열 표)** 와 `VERSIONING.md` 의 **정책 표 구조** 는 저장소 안에 선례가 없고 CONTEXT D-05 / D-09 / D-12 / D-13 과 `<specifics>` 예시가 유일한 출처다. planner 는 그 문구를 그대로 옮긴다 |

## Metadata

**Analog search scope:** 저장소 루트 추적 파일 전부 (`.fvmrc`, `.vscode/settings.json`, `pubspec.yaml`, `CHANGELOG.md`, `README.md`, `.gitignore`, `analysis_options.yaml`, `lib/analysis_options.yaml`), `git log` 20건 (`90a2736`, `dbcd20b` 본문), `.claude/CLAUDE.md` Conventions, `01-CONTEXT.md`, `01-RESEARCH.md`
**Files scanned:** 추적 파일 8개 + 기획 문서 3개
**Tracked-source gate:** 인용한 모든 저장소 경로는 `git ls-files` 로 추적 확인 (gitignore 미러 없음; `.fvm/`, `.dart_tool/`, `pubspec.lock` 은 인용하지 않음)
**Pattern extraction date:** 2026-10-11
