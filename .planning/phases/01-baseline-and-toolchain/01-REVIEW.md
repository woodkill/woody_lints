---
phase: 01-baseline-and-toolchain
reviewed: 2026-10-11T05:14:35Z
depth: standard
files_reviewed: 5
files_reviewed_list:
  - .fvmrc
  - .vscode/settings.json
  - CHANGELOG.md
  - pubspec.yaml
  - VERSIONING.md
findings:
  critical: 0
  warning: 6
  info: 4
  total: 10
status: issues_found
---

# Phase 1: Code Review Report

**Reviewed:** 2026-10-11T05:14:35Z
**Depth:** standard
**Files Reviewed:** 5
**Status:** issues_found

## Narrative Findings (AI reviewer)

## Summary

검토 대상은 설정 파일 3개(`.fvmrc`, `.vscode/settings.json`, `pubspec.yaml`)와 문서 2개(`CHANGELOG.md`, `VERSIONING.md`)다. 실행 코드가 없으므로 "버그" 는 (1) 설정 값이 서로 어긋나는 것, (2) 문서가 저장소의 실제 상태나 자기 자신과 어긋나는 것으로 보았다.

**설정 파일 3개에서는 결함을 찾지 못했다.** 다음을 직접 확인했다.

- `.fvmrc` 의 `"flutter": "3.47.5"` 와 `.vscode/settings.json` 의 `.fvm/versions/3.47.5` 가 같은 버전을 가리킨다. 그 SDK 의 Dart 는 3.13.4 다 (`dart --version` 실행 결과).
- `git diff 90a2736 HEAD -- pubspec.yaml lib/` 는 `pubspec.yaml` 의 두 줄(`version`, `sdk`)만 보여 준다. `lib/` 는 그대로다.
- `git diff v1.3.0 main -- lib pubspec.yaml` 과 `git diff v1.3.0 origin/main -- lib pubspec.yaml` 은 비어 있다. `main` 은 1.3.0 상태다.
- `VERSIONING.md` 36-48행의 기준표는 `01-CONTEXT.md` D-05 와 한 글자도 다르지 않다 (`diff` 로 확인). 102-117행의 예시와 `CHANGELOG.md` 1-12행도 `01-CONTEXT.md` 의 원문과 같다.
- `VERSIONING.md` 가 인용한 커밋·날짜·버전(`90a2736` 1.3.0 2026-09-20, `9451f6b` 1.2.3 2026-01-28, `212365d` 1.2.4 2026-02-27)과 "SDK 하한은 `^3.10.4` 그대로였다" 는 git 이력과 맞다.
- 하드코딩된 비밀 값, 위험한 패턴은 없다.

**결함은 전부 `VERSIONING.md` 에 있고, `CHANGELOG.md` 한 줄이 그중 하나에 걸린다.** 성격은 하나로 모인다 — 문서가 "판정 순서", "기준표", "이유", "실제 사례" 네 군데에서 같은 정책을 말하는데, 네 군데가 서로 다른 답을 내는 경우가 있다. 가장 무거운 것은 WR-01 이다. 필수 사례인 1.3.0 이 문서 자신의 1번 질문을 끝까지 적용하지 않았고, 끝까지 적용하면 답이 minor 가 아니라 major 가 된다.

Critical 로 분류한 것은 없다. 이유: 다섯 파일 중 어느 것도 사용 프로젝트에 잘못된 설정을 전달하지 않고(`main` 과 `lib/` 는 그대로다), 다음 릴리스 번호 2.0.0 은 아래 결함과 무관하게 major 로 맞다. 다만 WR-01 ~ WR-04 는 2.0.0 이후의 릴리스 등급을 잘못 매기게 만드는 결함이므로 Phase 3 / 4 가 이 문서를 기준으로 쓰기 전에 고쳐야 한다.

**수정할 때 주의할 점:** WR-01, WR-03, WR-04, WR-06 이 가리키는 문장은 `01-CONTEXT.md` 의 확정 결정(D-02, D-05, D-09, 소유자가 고른 예시)을 그대로 옮긴 것이다. 즉 결함의 뿌리는 구현이 아니라 명세에 있다. 문구만 고치면 되는 것과 소유자의 판단이 필요한 것을 각 항목의 **Fix** 에 나눠 적었다.

`CHANGELOG.md` 11행의 `(Phase 4 실측 후 채움)` 은 의도된 자리 표시이므로 결함으로 세지 않았다.

## Warnings

### WR-01: 1.3.0 사례가 판정 순서 1번의 둘째 조건을 건너뛴다 — 끝까지 적용하면 major 다

**File:** `VERSIONING.md:60-62` (근거: `VERSIONING.md:25`, `VERSIONING.md:54`)

**Issue:** 판정 순서 1번(25행)은 조건이 둘이다 — "받는 쪽이 설정 파일이나 SDK 를 고쳐야 하나, **자동 검사가 막힐 수 있나** → major". 그런데 1.3.0 사례(61행)는 첫째 조건만 따진다.

> 1번은 "아니오" 다. 받는 쪽이 설정 파일이나 SDK 를 고칠 것이 없었다 (SDK 하한은 `^3.10.4` 그대로였다).

둘째 조건("자동 검사가 막힐 수 있나")에 대한 답이 없다. 그리고 그 답은 "예" 다.

- 1.3.0 은 그때까지 로드되지 않던 `riverpod_lint` 규칙을 처음 켰다 (60행).
- 로컬 pub 캐시의 `riverpod_lint-3.1.3` 과 `riverpod_lint-3.1.9` 에서 규칙 정의를 확인했다. 규칙 파일 15개 중 **11개가 `DiagnosticSeverity.WARNING`, 1개(`riverpod_syntax_error`)가 `DiagnosticSeverity.ERROR`** 다. WARNING 인 것: `provider_parameters`, `missing_provider_scope`, `only_use_keep_alive_inside_keep_alive`, `unsupported_provider_value`, `scoped_providers_should_specify_dependencies`, `provider_dependencies`, `notifier_build`, `functional_ref`, `async_value_nullable_pattern`, `notifier_extends`, `avoid_ref_inside_state_dispose`.
- `dart analyze --help` (Dart 3.13.4): `--[no-]fatal-warnings ... (defaults to on)`. warning 하나만 나와도 `dart analyze` 는 실패한다.

따라서 1.3.0 은 받는 프로젝트의 `dart analyze` 를 통과에서 실패로 바꿀 수 있었다. 이것은 54행이 major 의 이유로 든 것과 똑같은 상황이다 ("받는 프로젝트의 `dart analyze` 가 통과에서 실패로 바뀔 수 있다"). 문서의 규칙을 문서의 사례에 그대로 대입하면 1.3.0 은 **1번에서 멈춰 major** 이고, 사례에 적힌 "minor (2번에서 멈춤)" 와 어긋난다.

영향: 이 사례는 D-09 가 "최소한 들어가야 한다" 고 정한 두 사례 중 하나이고, 앞으로의 판정이 따라 할 선례다. Phase 3 / 4 에서 plugin 을 새 프리셋에 넣거나 `riverpod_lint` 하한을 올릴 때(기준표 46행은 minor), warning 등급 진단이 새로 생기는데도 이 선례를 따라 minor 로 매기게 된다.

**Fix:** 문구만 고쳐서는 해결되지 않는다. 소유자가 둘 중 하나를 골라야 한다.

- (가) 정책을 그대로 두고 사례를 고친다 — 1.3.0 을 "당시에는 minor 로 냈다 → 지금 정책이면 major (1번에서 멈춤)" 로 바꿔 68-71행의 "옛 판정과 지금 정책이 다른 것" 목록으로 옮긴다. minor 사례가 비게 되므로 1번이 "아니오" 인 다른 사례를 든다.
- (나) 1번의 둘째 조건을 좁힌다 — "자동 검사가 막힐 수 있나" 를 "**이미 켜져 있던 규칙의** 심각도가 warning 이상으로 올라가나" 처럼 기준표 42행과 같은 범위로 다시 쓰고, 새로 켠 규칙·plugin 이 처음부터 warning 인 경우는 minor 이며 CHANGELOG "새로 생기는 경고" 표의 `강도` 열로 알린다고 명시한다. 그리고 61행에 둘째 조건을 따진 문장을 덧붙인다:

```markdown
  - 1번은 "아니오" 다. 받는 쪽이 설정 파일이나 SDK 를 고칠 것이 없었고 (SDK 하한은 `^3.10.4` 그대로였다), 이미 켜져 있던 규칙의 심각도도 바뀌지 않았다. 새로 켜진 `riverpod_lint` 규칙 가운데 warning 등급이 있지만, 새로 켠 규칙은 2번에서 다룬다.
```

어느 쪽이든 WR-02 와 함께 정한다.

### WR-02: "자동 검사가 막힐 수 있나" 의 뜻이 정해져 있지 않아 minor 와 major 의 경계가 무너진다

**File:** `VERSIONING.md:25` (관련: `VERSIONING.md:42-43`, `VERSIONING.md:52`, `VERSIONING.md:54`)

**Issue:** major 와 minor 를 가르는 문턱이 "자동 검사가 막힐 수 있나" 인데, 어떤 명령을 어떤 옵션으로 돌린 것을 "자동 검사" 로 보는지 문서에 없다. 54행이 `dart analyze` 를 예로 들 뿐이다. 받는 쪽은 전부 Flutter 프로젝트이고, Flutter 의 기본 분석 명령은 기본값이 다르다.

고정 SDK(Flutter 3.47.5)의 `flutter analyze --help` 출력:

```text
--[no-]fatal-infos        Treat info level issues as fatal.
                          (defaults to on)
--[no-]fatal-warnings     Treat warning level issues as fatal.
                          (defaults to on)
```

`flutter analyze` 는 info 한 건만 나와도 실패한다. 받는 프로젝트의 CI 가 `flutter analyze` 를 옵션 없이 돌리면, 기준표 43행의 "규칙을 넣음 = minor" 도 1번 질문에 "예"(자동 검사가 막힐 수 있다)가 되어 major 가 된다. 그러면 43행(minor)과 25행(major)이 같은 변경에 다른 등급을 준다. 42행 "심각도를 warning 이상으로 올림 = major" 를 따로 둔 의미도 `flutter analyze` 기준에서는 사라진다 — info 일 때 이미 막혔기 때문이다.

같은 모호함이 다른 행에도 번진다. `analyzer.exclude` 에서 `**/*.g.dart` 를 빼는 변경은 44행으로는 minor 지만, 생성 코드가 분석 대상에 들어와 warning 이 나올 수 있으므로 1번 질문으로는 "예" 다.

**Fix:** 판정 순서 바로 아래에 "자동 검사" 의 정의를 한 문단 넣는다. 예:

```markdown
여기서 "자동 검사" 는 `dart analyze` 를 옵션 없이 돌린 것이다. `dart analyze` 는 warning 이상이 하나라도 있으면 실패하고 info 만 있으면 통과한다. `flutter analyze` 는 기본값이 달라 info 한 건으로도 실패한다 (`--fatal-infos` 가 기본으로 켜져 있다, Flutter 3.47.5 확인). `flutter analyze` 를 CI 에 쓰는 프로젝트는 minor 릴리스에서도 검사가 막힐 수 있으므로, 올리기 전에 CHANGELOG 의 "새로 생기는 경고" 표를 본다.
```

정의를 `dart analyze` 로 둘지 `flutter analyze` 로 둘지는 소유자가 정한다 (사용 프로젝트 5개의 CI 가 어느 명령을 쓰는지에 달려 있고, 이 저장소에서는 확인할 수 없다).

### WR-03: 판정 순서와 기준표가 같은 변경에 다른 등급을 낸다 (세 가지 경우)

**File:** `VERSIONING.md:25-28` (어긋나는 행: `VERSIONING.md:40-41`, `VERSIONING.md:45`, `VERSIONING.md:47`)

**Issue:** 34행은 기준표를 "판정 순서의 질문을 변경 종류별로 풀어 놓은 표" 라고 소개한다. 그런데 판정 순서를 23행의 지시("처음 '예'가 나오는 곳에서 멈춘다")대로 따라가면 표와 다른 답이 나오는 변경이 셋 있다.

| 변경 | 판정 순서를 따라가면 | 기준표 |
|------|----------------------|--------|
| README 나 CHANGELOG 만 고침 | 3번 "`lib/` 나 `pubspec.yaml` 이 바뀌긴 했나" 가 "아니오" → 4번 **올리지 않음** | 47행 **patch** |
| 새 프리셋 파일을 추가함 | 2번이 묻는 것(규칙 목록, exclude / errors, plugin 버전)은 기존 파일에서 하나도 안 바뀜 → 3번 `lib/` 가 바뀜 → **patch** | 45행 **minor** |
| `riverpod_lint` 를 3 → 4 로 올림 | 1번은 받는 쪽이 고칠 것이 없으면 "아니오" → 2번 "plugin 버전이 바뀌었나" 가 "예" → **minor** | 41행 **major** |

셋째 경우는 `flutter_lints` 6 → 7 (40행)도 같다. 1번 질문에는 "의존하는 규칙 세트의 major 가 바뀌나" 에 해당하는 조건이 없고, 2번의 "규칙 목록이 바뀌었나" 에 먼저 걸린다.

첫째 경우는 이 저장소에서 바로 일어난다. README 는 Phase 5 에서 통째로 다시 쓰고, 그 뒤 README 오탈자만 고친 커밋이 patch 인지 "올리지 않음" 인지 문서가 두 가지로 답한다. `VERSIONING.md` 자신을 고친 경우도 48행의 "저장소 안쪽" 예시(`.fvmrc`, CI, `example/`, 검증 스크립트)에 없어서 어느 쪽인지 알 수 없다.

판정 순서(D-09)와 기준표(D-05)는 둘 다 `01-CONTEXT.md` 에서 그대로 옮긴 것이므로, 어긋남은 명세에서 온 것이다.

**Fix:** 기준표(D-05)는 "그대로 담는다" 고 확정된 것이므로 판정 순서 쪽 문장을 표에 맞춘다.

```markdown
1. 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하나, 자동 검사가 막힐 수 있나, `flutter_lints` 나 `riverpod_lint` 의 맨 앞자리가 바뀌었나 → major. 맨 앞자리(major) 를 올린다.
2. 규칙 목록이나 exclude / errors 설정, plugin 버전이 바뀌었나, 프리셋 파일이 새로 생겼나 → minor. 가운데 자리(minor) 를 올린다.
3. `lib/` 나 `pubspec.yaml`, 받는 쪽이 읽는 문서(README, CHANGELOG)가 바뀌긴 했나 → patch. 맨 뒷자리(patch) 를 올린다.
4. 아니면 → 버전을 올리지 않는다.
```

그리고 48행의 "저장소 안쪽" 예시에 `VERSIONING.md` 를 넣을지 정한다. README 만 고친 경우를 "올리지 않음" 으로 하고 싶다면 반대로 47행에서 README·CHANGELOG 를 빼야 하는데, 그것은 D-05 를 바꾸는 일이므로 소유자 확인이 필요하다.

### WR-04: 52행 "major 는 … 고쳐야 하는 변경에만 쓴다" 가 25행, 40-42행, 54행과 모순된다

**File:** `VERSIONING.md:52`

**Issue:** 52행은 major 의 범위를 이렇게 한정한다.

> major 는 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하는 변경에**만** 쓴다.

그런데 두 줄 아래 54행은 받는 쪽이 설정 파일도 SDK 도 고칠 필요가 없는 변경을 major 라고 한다.

> 규칙 심각도를 info 에서 warning 이상으로 올리는 변경은 major 다.

기준표 40행(`flutter_lints` 6 → 7), 41행(`riverpod_lint` 3 → 4), 42행(심각도 상향)도 "받는 쪽이 겪는 일" 칸이 "설정 파일을 고쳐야 한다" 나 "SDK 를 올려야 한다" 가 아니다. 25행의 판정 순서 1번도 "자동 검사가 막힐 수 있나" 를 major 조건에 넣는다. "에만" 이라는 한정은 같은 문서의 다섯 군데와 맞지 않는다.

52행은 D-02 의 문장을 옮긴 것이다. D-02 는 D-04(심각도 상향 = major)와 D-05 의 표가 나오기 전의 결정이라 그 한정이 뒤의 결정에 덮였는데, 문서에는 덮이기 전 문장이 남았다.

**Fix:** "에만" 을 빼고 major 의 범위를 25행과 같게 쓴다.

```markdown
- 규칙 추가가 minor 인 조건은 CHANGELOG 의 그 버전에 "새로 생기는 경고" 칸을 반드시 두는 것이다. major 는 받는 쪽이 뭔가 고쳐야 하거나(설정 파일, SDK) 손대지 않은 프로젝트의 자동 검사가 막힐 수 있는 변경에 쓴다. 규칙이 하나 늘어 경고가 몇 건 생기는 정도는 여기에 들지 않는다. Dart 공식 `lints` / `flutter_lints` 는 …
```

"자동 검사가 막힐 수 있는" 의 뜻은 WR-02 에서 정한 정의를 따른다.

### WR-05: "받는 쪽은 tag 하나에 고정해서 받는다" 는 전제가 지금 사실이 아니고, CHANGELOG 의 "올리기 전에" 가 그 전제 위에 쓰여 있다

**File:** `VERSIONING.md:5`, `VERSIONING.md:52`, `CHANGELOG.md:7`

**Issue:** `VERSIONING.md` 5행은 정책 전체의 출발점을 현재형 사실로 적는다.

> 받는 쪽은 `ref: vX.Y.Z` 처럼 정확한 tag 하나에 고정해서 받는다. `^2.0.0` 같은 범위를 도구가 계산해서 새 버전을 골라 주는 일이 없으므로 …

저장소의 실제 상태는 다르다.

- `README.md:31`, `README.md:42` 는 `ref: main` 으로 설치하라고 안내한다 (이 phase 에서 README 는 고치지 않는다).
- `.claude/CLAUDE.md` 의 Constraints 와 `.planning/PROJECT.md:66` 은 사용 프로젝트 5개가 **전부 `ref: main`** 이라고 적는다.
- tag 로 고정하는 것은 `.planning/PROJECT.md:36`, `:97` 에서 아직 "Pending" 인 목표다.

`ref: main` 을 따르는 프로젝트는 `flutter pub upgrade woody_lints` 한 번으로 `main` 의 최신 커밋을 받는다. 이것은 52행이 "그쪽은 사정이 다르다" 며 구분한 "caret 범위로 새 버전이 자동으로 들어오는 구조" 와 같은 구조다. 즉 "규칙 추가 = minor" 의 근거가 지금의 사용 프로젝트 5개에는 성립하지 않는다.

`CHANGELOG.md` 7행이 같은 전제에 기대어 있다.

> Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.

"머문다" 는 이미 `v1.3.0` 에 고정되어 있다는 뜻인데, 지금 `v1.3.0` 에 고정한 프로젝트는 하나도 없다. Dart 3.13 미만인 프로젝트가 실제로 해야 하는 일은 `pubspec.yaml` 의 `ref: main` 을 `ref: v1.3.0` 으로 **바꾸는** 것이다. 바꾸지 않은 채 2.0.0 이 `main` 에 합쳐지면 다음 `pub upgrade` 에서 SDK 불일치로 의존성 해석이 실패한다. `VERSIONING.md` 80행은 이 칸을 "받는 쪽이 고쳐야 하는 것을 적는다" 로 정의하는데, 7행에는 고칠 것이 적혀 있지 않다.

**Fix:**

`VERSIONING.md` 5행 — 전제가 2.0.0 부터의 약속임을 밝힌다.

```markdown
"받는 쪽" 은 이 패키지를 `include` 하는 Flutter 프로젝트다. 2.0.0 부터 받는 쪽은 `ref: vX.Y.Z` 처럼 정확한 tag 하나에 고정해서 받는다 (그 전까지는 전부 `ref: main` 을 따랐다). tag 에 고정하면 `^2.0.0` 같은 범위를 도구가 계산해서 새 버전을 골라 주는 일이 없으므로, …
```

그리고 52행 끝에 한 문장을 덧붙인다: "`ref: main` 을 그대로 두는 프로젝트에는 이 구분이 통하지 않는다 — `pub upgrade` 때마다 최신 커밋이 들어온다."

`CHANGELOG.md` 7행 — 문구가 D-14 의 확정 원문이므로 바꾸지 않고 바로 아래에 하위 불릿을 덧붙인다 (D-15 가 이후 phase 의 추가 기입을 허용한다. 기존 1.3.0 항목의 하위 불릿 문체와 같다).

```markdown
- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.
  - 지금 `ref: main` 을 따르는 프로젝트는 2.0.0 이 `main` 에 합쳐지기 전에 `pubspec.yaml` 의 `ref: main` 을 `ref: v1.3.0` 으로 바꾼다. 바꾸지 않으면 다음 `pub upgrade` 가 SDK 불일치로 실패한다.
```

### WR-06: 형식의 기준 예시가 자기 설명과 어긋난다 — "규칙 하나를 추가" 인데 경고 표에는 규칙이 둘이다

**File:** `VERSIONING.md:99-117`

**Issue:** 99행은 예시를 "규칙 하나를 추가한 가상의 minor 릴리스" 라고 소개하고, `### 추가한 규칙` (106-108행)에는 `rule_a` 하나만 있다. 그런데 `### 새로 생기는 경고` 표(112-115행)에는 `rule_a` 와 `rule_b` 두 행이 있다.

`rule_b` 가 왜 새 경고를 내는지 예시 안에 설명이 없다. 추가한 규칙이 아니라면 다른 변경(예: plugin 하한 상향, exclude 변경) 때문이어야 하는데, 그런 변경을 적는 `### 그 밖의 변경` 칸이 예시에 없다. 이 예시는 Phase 4 가 실측 표를 채울 때 그대로 따라 할 본보기다. 표의 행이 "추가한 규칙" 과 일대일이어야 하는지, 아니면 경고가 새로 생긴 규칙이면 무엇이든 들어가는지 예시만으로는 판단할 수 없다.

예시는 `01-CONTEXT.md` 의 "소유자가 고른 CHANGELOG 예시 (그대로 따른다)" 와 글자 단위로 같다. 어긋남은 명세에서 온 것이다.

**Fix:** 둘 중 하나. 어느 쪽이든 확정 예시를 바꾸는 것이므로 소유자에게 알린다.

- 예시를 설명에 맞춘다 — 115행(`rule_b`)을 지운다.
- 설명을 예시에 맞춘다 — 99행을 "규칙 두 개를 추가한" 으로 바꾸고 108행 아래에 `` - `rule_b` — 켠 이유 한 줄 `` 을 넣는다. `dart fix` 열이 0건인 행을 보여 주려는 의도라면 이쪽이 맞다.

그리고 90행 근처에 표의 행 규칙을 한 문장으로 적는다: "표에는 이 버전에서 경고가 새로 생기는 규칙을 전부 적는다. `추가한 규칙` 의 규칙은 건수가 0 이어도 한 행씩 둔다."

## Info

### IN-01: "옛 판정과 지금 정책이 다른 것" 목록에 규칙을 뺀 유일한 사례 1.2.5 가 없다

**File:** `VERSIONING.md:68-71`

**Issue:** 목록은 1.2.3 과 1.2.4 두 건, 둘 다 규칙을 **추가** 한 사례다. git 이력에는 규칙을 **뺀** 사례가 하나 있다 — `dbcd20b` (2026-03-23, 1.2.4 → 1.2.5)가 `require_trailing_commas` 와 `public_member_api_docs` 를 주석 처리하고 `formatter: trailing_commas: preserve` 를 껐다. 당시에는 patch 로 냈고, 지금 정책(53행 "규칙을 넣든 빼든 규칙 목록이 바뀌면 minor")이면 minor 다.

68행이 "다른 것**도** 있다" 라고 썼으므로 목록이 틀린 것은 아니다. 다만 53행의 통일 규칙(D-03)은 조사 문서 두 편의 안을 뒤집고 새로 정한 것인데, 이 규칙을 보여 주는 사례가 문서에 하나도 없다.

**Fix:** 71행 아래에 한 줄을 넣는다.

```markdown
- `1.2.5` (2026-03-23, `dbcd20b`) — `require_trailing_commas` 와 `public_member_api_docs` 규칙을 껐는데 당시에는 patch 로 냈다 → 지금 정책이면 minor (2번에서 멈춤). 규칙을 빼는 것도 규칙 목록이 바뀌는 것이다.
```

### IN-02: `` ` - ` `` 는 렌더링하면 앞뒤 공백이 사라진다

**File:** `VERSIONING.md:78`

**Issue:** 78행은 "앞뒤에 공백이 하나씩 있는 붙임표" 를 code span `` ` - ` `` 로 두 번 보여 준다. CommonMark 는 code span 의 내용이 공백으로 시작하고 공백으로 끝나면(전부 공백인 경우 제외) 앞뒤에서 공백을 하나씩 떼어 낸다. GitHub 에서 이 줄은 `-` 로 보인다. 공백이 요점인 문장에서 공백이 보이지 않는다. 괄호 안의 풀이가 뜻을 지켜 주므로 오독 위험은 낮다.

**Fix:** 따옴표를 code span 안에 넣어 공백을 보이게 한다 — `` `" - "` ``. 두 군데 모두 고친다.

### IN-03: 오래 남을 문서가 작업 계획의 내부 이름에 기대고, 아직 없는 검사를 현재형으로 적는다

**File:** `VERSIONING.md:78`, `VERSIONING.md:97`, `VERSIONING.md:122`, `VERSIONING.md:123`

**Issue:** 3행은 독자를 "몇 달 뒤의 작성자 본인" 으로, 목표를 "그때 다시 찾아보지 않아도 되도록" 으로 잡는다. 그런데 본문이 `.planning/` 안에서만 뜻이 통하는 이름을 쓴다.

- 78행: "Phase 6 에서 만드는 일치 검사(REL-03 …)가 … 버전으로 읽는다" — 검사는 아직 없는데 "읽는다" 로 적혀 있고, 어디에 있는 무엇인지(스크립트 경로)가 없다.
- 97행: "자세한 회차 기록은 Phase 4 의 규칙 근거 문서에 두고" — 파일 이름도 경로도 없다 (`01-CONTEXT.md` 의 Deferred 에서 위치가 미정이다).
- 122행: "이후 phase 가 자기 변경을 …", "Phase 4 의 실측 전에".
- 123행: "Phase 5 의 일이다".

milestone 이 끝나 phase 디렉터리가 정리되면 "Phase 4", "Phase 6", "REL-03" 은 찾아갈 곳이 없는 이름이 된다.

**Fix:** phase 번호 대신 일의 이름을 쓰고, 산출물이 생기면 경로로 바꾼다. 예: 78행 "릴리스 전 일치 검사(tag, `pubspec.yaml` 의 `version`, CHANGELOG 최상단 버전이 같은지 본다 — 2.0.0 릴리스 준비 때 만든다)가 … 읽게 된다". 97행은 근거 문서가 생기는 phase 에서 실제 경로로 고친다. 120-123행의 진행 메모는 2.0.0 릴리스 때 지우거나 과거형으로 바꾼다.

### IN-04: 준비 중 버전에 `-dev` 를 붙이는 규칙이 2.0.0 사례의 하위 불릿에만 있다

**File:** `VERSIONING.md:66`

**Issue:** "준비하는 동안에는 `version` 을 `X.Y.Z-dev` 로 두고 릴리스 때 `-dev` 를 뗀다" 는 2.0.0 에만 해당하는 사실이 아니라 앞으로의 릴리스마다 적용할 규칙이다 (D-07). 문서에는 "실제 사례" 절의 2.0.0 불릿 아래 셋째 하위 불릿으로만 있어서, 다음 릴리스를 준비할 때 "판정 순서" 나 "기준표" 를 읽어서는 찾을 수 없다. `-dev` 가 붙은 채로 tag 를 붙이면 안 된다는 점도 적혀 있지 않다.

**Fix:** "판정 순서" 절 끝(30행 아래)에 일반 규칙으로 올린다.

```markdown
다음 버전을 준비하는 동안에는 `pubspec.yaml` 의 `version` 을 `2.1.0-dev` 처럼 `-dev` 를 붙여 두고, 릴리스 때 `-dev` 를 뗀다. `-dev` 가 붙은 커밋에는 tag 를 붙이지 않는다.
```

66행은 "2.0.0 도 이 규칙대로 `2.0.0-dev` 로 두었다" 정도로 줄인다.

---

_Reviewed: 2026-10-11T05:14:35Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
