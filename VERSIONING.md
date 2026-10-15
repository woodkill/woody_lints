# 버전 정책 (Versioning)

이 문서는 `woody_lints` 의 버전 번호를 언제 얼마나 올리는지와 `CHANGELOG.md` 항목을 어떤 형식으로 쓰는지를 정한다. 읽는 사람은 몇 달 뒤의 작성자 본인이다. 그때 다시 찾아보지 않아도 되도록 용어를 쉬운 말로 풀어 적는다.

"받는 쪽" 은 이 패키지를 `include` 하는 Flutter 프로젝트다. 받는 쪽은 `ref: vX.Y.Z` 처럼 정확한 tag 하나에 고정해서 받는다. `^2.0.0` 같은 범위를 도구가 계산해서 새 버전을 골라 주는 일이 없으므로, 버전 번호는 도구가 읽는 값이 아니라 **사람에게 보내는 신호**다. 그래서 등급을 정하는 기준은 하나다 — "이 버전을 받는 쪽이 겪는 일".

버전 번호는 `2.0.0` 처럼 세 자리다.

- **맨 앞자리(major)** 는 "받는 쪽이 뭔가 고쳐야 한다" 는 뜻이다.
- **가운데 자리(minor)** 는 "경고가 달라진다, CHANGELOG 를 본다" 는 뜻이다.
- **맨 뒷자리(patch)** 는 "달라지는 게 없다" 는 뜻이다.

책의 판수에 빗대면 개정판(major), 증보판(minor), 오탈자 수정(patch)이다.

이 문서에 나오는 다른 말도 풀어 둔다.

- tag 는 커밋에 붙이는 **이름표**다. 받는 쪽은 이름표 이름(`v1.3.0`)으로 받는다.
- push 는 "GitHub 에 올린다" 는 뜻이다.
- `pubspec.lock` 은 "그때 실제로 받은 커밋 번호를 적어 두는 영수증" 이다. 이름표를 다른 커밋으로 옮기면 영수증과 어긋나므로, 한 번 올린 tag 는 옮기지 않는다.

## 판정 순서

위에서부터 물어 내려가다 처음 "예"가 나오는 곳에서 멈춘다.

1. 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하나, `flutter_lints` 나 `riverpod_lint` 를 다음 major 로 올리나 (6 → 7, 3 → 4 처럼 맨 앞자리가 바뀜), 이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나 → major. 맨 앞자리(major) 를 올린다.
2. 규칙 목록이나 exclude / errors 설정, plugin 버전이 바뀌었나 → minor. 가운데 자리(minor) 를 올린다.
3. `lib/` 나 `pubspec.yaml` 이 바뀌긴 했나 → patch. 맨 뒷자리(patch) 를 올린다.
4. 아니면 → 버전을 올리지 않는다.

1번의 세 조건은 기준표의 major 다섯 행을 그대로 옮긴 것이다. 둘째 조건은 맨 앞자리가 바뀌는 상향(`flutter_lints` 6 → 7, `riverpod_lint` 3 → 4)만 가리킨다 — 같은 major 안에서 하한만 올리는 것(`^3.1.3` → `^3.1.9`)은 2번의 "plugin 버전이 바뀌었나" 다. 셋째 조건은 **이미 켜져 있던** 규칙에만 해당한다 — 규칙을 새로 켜는 것은 그 규칙이 처음부터 warning 이나 error 등급이어도 2번(minor)이다. 왜 이렇게 나누는지는 기준표 아래에 적었다.

한 릴리스에 변경이 여러 개 들어가면 변경마다 따로 물어서 가장 큰 등급을 쓴다. 올린 자리의 뒷자리는 0 으로 돌린다 (`1.3.0` 에서 맨 앞자리를 올리면 `2.0.0`).

## 기준표

판정 순서의 질문을 변경 종류별로 풀어 놓은 표다. 답이 바로 나오지 않을 때 여기서 찾는다.

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

등급을 이렇게 나눈 이유는 다음과 같다.

- 규칙 추가가 minor 인 조건은 CHANGELOG 의 그 버전에 "새로 생기는 경고" 칸을 반드시 두는 것이다. major 는 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하는 변경, `flutter_lints` 나 `riverpod_lint` 를 다음 major 로 올리는 변경, 이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가는 변경에 쓴다 (판정 순서 1번과 같은 범위 — 기준표의 major 다섯 행). 규칙이 새로 켜져 경고가 생기는 것은 그 규칙이 처음부터 warning 등급이어도 여기에 들지 않는다. Dart 공식 `lints` / `flutter_lints` 는 규칙 추가를 major 로 내지만, 그쪽은 caret 범위(`^6.0.0`)로 새 버전이 자동으로 들어오는 구조라 사정이 다르다.
- 규칙을 넣든 빼든 규칙 목록이 바뀌면 minor 로 통일한다. patch 는 규칙 목록이 그대로인 변경에만 쓴다.
- 이미 켜져 있던 규칙의 심각도를 info 에서 warning 이상으로 올리는 변경은 major 다. 규칙 목록은 그대로여서 "새로 생기는 경고" 표에 잡히지 않는데도, 받는 프로젝트의 `dart analyze` 가 통과에서 실패로 바뀔 수 있기 때문이다. 반대로 규칙을 새로 켜는 것은 처음부터 warning 등급이어도 minor 다 — 받는 쪽이 올리기 전에 그 표의 `강도` 열에서 미리 볼 수 있다.
- 기준표의 "자동 검사가 막힐 수 있다" 는 받는 쪽이 겪는 일을 풀어 쓴 것이고, 등급은 왼쪽 칸의 변경 종류로 매긴다. 여기서 자동 검사는 받는 쪽이 CI 등에서 돌리는 분석 명령이다. `dart analyze` 는 옵션 없이 돌리면 warning 이상이 하나라도 있을 때 실패하고 info 만 있으면 통과한다 (`--fatal-warnings` 기본 켜짐, `--fatal-infos` 기본 꺼짐 — Dart 3.13.4, 2026-10-11 확인). `flutter analyze` 는 둘 다 기본으로 켜져 있어 info 한 건에도 실패한다 (Flutter 3.47.5, 2026-10-11 확인). 그래서 규칙이 새로 켜지는 minor 릴리스에서도 받는 쪽의 자동 검사는 막힐 수 있다 — 받는 쪽은 올리기 전에 "새로 생기는 경고" 표를 보고 올리는 시점을 고른다.

## 실제 사례

판정 순서를 실제 버전에 대입한 것이다. 꼴은 "버전 — 무엇이 바뀌었나 → 등급 (멈춘 곳)" 이다.

- `1.3.0` (2026-09-20, `90a2736`) — 그때까지 로드되지 않던 `riverpod_lint` 를 처음 켰다 → minor (2번에서 멈춤).
  - 1번은 세 조건 모두 "아니오" 다. 받는 쪽이 설정 파일이나 SDK 를 고칠 것이 없었다 (`include` 경로와 SDK 하한 `^3.10.4` 가 그대로였다). 다음 major 로 올린 것도 없다 — `flutter_lints` 는 `^6.0.0` 그대로였고(선언 위치만 `dev_dependencies` 에서 `dependencies` 로 옮겼다), `riverpod_lint` 는 그때까지 로드되던 plugin 이 없었으므로 쓰던 plugin 을 올린 것이 아니라 처음 켠 것이다. 이미 켜져 있던 규칙의 심각도가 올라간 것도 없다 — `analyzer.errors` 는 그대로였고, `riverpod_lint` 규칙은 그때까지 하나도 켜져 있지 않았다.
  - 새로 켜진 `riverpod_lint` 3.1.3 규칙 15개 가운데 11개가 warning, 1개가 error 등급이라 받는 쪽의 `dart analyze` 가 막힐 수 있었다. 그래도 1번은 "아니오" 다 — 새로 켠 규칙은 처음부터 warning 등급이어도 2번에서 다룬다.
  - 2번은 "예" 다. plugin 규칙이 처음 켜지므로 경고가 달라진다.
- `2.0.0` (미출시, 다음 릴리스) — 지원 SDK 하한을 `^3.10.4` 에서 `^3.13.0` 으로 올린다 → major (1번에서 멈춤).
  - 1번의 첫째 조건(SDK 를 고쳐야 하나)이 바로 "예" 다. Dart 3.13 미만을 쓰는 프로젝트는 SDK 를 올리거나 `v1.3.0` 에 머물러야 한다. 처음 "예" 에서 멈추므로 나머지 두 조건은 따지지 않는다.
  - 그래서 다음 릴리스는 **2.0.0** 이다. 이번 릴리스에 들어가는 변경 중 가장 큰 등급이 SDK 하한 상향(major)이기 때문이다.
  - 2.0.0 을 준비하는 동안(milestone 브랜치)에는 `pubspec.yaml` 의 `version` 을 `2.0.0-dev` 로 두고, 릴리스 때 `-dev` 를 뗀다. 내용은 이미 1.3.0 이 아닌데 번호만 1.3.0 인 상태를 피하려는 것이다.

이 정책을 정하기 전에 낸 버전 중에는 옛 판정과 지금 정책이 다른 것도 있다.

- `1.2.3` (2026-01-28, `9451f6b`) — `slash_for_doc_comments` 규칙을 추가했는데 당시에는 patch 로 냈다 → 지금 정책이면 minor (2번에서 멈춤).
- `1.2.4` (2026-02-27, `212365d`) — `public_member_api_docs` 규칙을 추가하고 `analyzer:` 의 exclude / errors 설정을 넣었는데 당시에는 patch 로 냈다 → 지금 정책이면 minor (2번에서 멈춤).

## CHANGELOG 항목 형식

`CHANGELOG.md` 의 버전 항목은 "필수 두 칸 + 해당 칸만" 으로 쓴다. `지원 SDK:` 줄과 "새로 생기는 경고" 칸은 항상 적고, 나머지 칸은 해당하는 변경이 있을 때만 둔다.

- 제목은 `## X.Y.Z - YYYY-MM-DD` 다. 아직 릴리스하지 않은 항목은 날짜 자리에 `미출시` 를 쓰고 릴리스 때 날짜로 바꾼다.
  - 제목의 ` - ` (앞뒤에 공백이 하나씩 있는 붙임표)는 **한 번만** 쓴다. 검증 명령 `[3/10]` 의 일치 검사(REL-03 — tag, `pubspec.yaml` 의 `version`, CHANGELOG 최상단 버전이 같은지 본다)가 ` - ` 앞 토큰을 버전으로 읽는다.
- 제목 바로 아래 한 줄 `지원 SDK: …` 는 **항상** 적는다. 바뀌지 않았으면 `(변경 없음)`, 바뀌었으면 `(이전: …)` 을 붙인다.
- `### 올리기 전에` — 받는 쪽이 고쳐야 하는 것을 적는다. 해당할 때만 둔다.
- `### 추가한 규칙` — 해당할 때만 둔다. 불릿은 `` - `rule_name` — 켠 이유 한 줄 `` 꼴이다.
- `### 뺀 규칙` — 해당할 때만 둔다. 불릿은 `` - `rule_name` — 뺀 이유 한 줄 `` 꼴이다.
- `### 그 밖의 변경` — 해당할 때만 둔다.
- `### 새로 생기는 경고` — **항상** 적는다. 없으면 `없음` 이라고 적는다.

칸은 위 순서대로 둔다. 칸 이름은 한국어로 쓰고, 영어 칸 이름(Added / Removed)은 쓰지 않는다.

"새로 생기는 경고" 칸을 항상 두는 것은 기준표와 이어져 있다. 규칙 추가를 major 가 아니라 minor 로 내는 조건이 바로 이 칸이다 — 받는 쪽은 올리기 전에 여기서 경고가 몇 건 생기는지 본다.

"새로 생기는 경고" 칸은 4열 표와 그 아래 실측 조건 한 줄로 쓴다. 표의 헤더는 `| 규칙 | 강도 | 실측 | dart fix |` 다.

- `규칙` — 규칙 이름.
- `강도` — 진단의 심각도 (info / warning / error).
- `실측` — 실측 프로젝트에서 그 규칙이 낸 경고 건수.
- `dart fix` — `dart fix` 로 고칠 수 있는지 여부가 아니라 **고쳐지는 건수**.

표 아래 한 줄은 `실측: flutter_starter_kit (Dart 파일 N개), Flutter X.Y.Z, YYYY-MM-DD` 꼴로 쓴다. 자세한 회차 기록은 Phase 4 의 규칙 근거 문서에 두고, 이 한 줄은 CHANGELOG 만 읽어도 숫자의 뜻(어느 프로젝트를, 어느 Flutter 로, 언제 쟀는지)이 보이게 하려고 둔다.

아래는 규칙 하나를 추가한 가상의 minor 릴리스다.

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

새 형식은 2.0.0 부터 적용한다.

- 2.0.0 항목은 `## 2.0.0 - 미출시` 로 먼저 만들어 두고, 이후 phase 가 자기 변경(프리셋 분리, 규칙 변경과 실측 표)을 같은 항목에 적어 나간다. 변경과 기록이 같은 커밋에 남고, 형식을 실제로 써 보므로 허점이 Phase 4 의 실측 전에 드러난다.
- 지금 있는 1.3.0 / 1.0.0 항목은 옛 불릿 형식 그대로 두고 고치지 않는다. 실측 수치가 없어 필수 칸을 채울 수 없다. 1.0.0 과 1.3.0 사이의 빠진 버전을 보완하는 것은 Phase 5 의 일이다.

## 릴리스 절차

이 절은 2.0.0 릴리스(2026-10)에서 실제로 밟는 순서를 번호로 적은 것이다. 다음 릴리스도 이 순서를 그대로 밟는다. 원격(GitHub)에 남아 되돌리기 어려운 두 작업 — tag push 와 `main` 병합 — 은 실행 바로 앞에서 사람이 한 번 더 확인한다 (아래 **(직전 확인)**). 한 번 올린 tag 는 옮기지 않는다 — 잘못 올렸으면 새 번호를 쓴다 (위 용어 풀이의 "영수증" 과 같은 이유).

이 절에 나오는 말도 풀어 둔다.

- annotated tag 는 만든 사람 · 시각 · 메시지를 함께 담는 tag 다. 이름만 붙이는 tag 와 달리 tag 자체가 하나의 기록이 된다.
- 예행은 tag 를 달기 전에, tag 를 달 커밋 번호로 받는 쪽의 설치를 한 번 해 보는 것이다.
- merge commit 은 두 브랜치를 합쳤다는 기록을 남기는 커밋이다. 합치는 쪽의 커밋 번호가 그대로 남는다.

1. 등급을 정한다 (위 「판정 순서」). 준비 중에는 `pubspec.yaml` 의 `version` 이 `X.Y.Z-dev`, CHANGELOG 최상단이 `## X.Y.Z - 미출시` 다 — 둘의 버전이 다르면 평소 push 의 검증이 `[3/10]` 에서 실패한다.
2. 릴리스 커밋을 만든다. `version` 의 `-dev` 를 떼고, CHANGELOG 제목의 `미출시` 를 날짜(`YYYY-MM-DD`)로 바꾼다 — 날짜는 릴리스 커밋을 만드는 날이다. 예행 · 확인이 날을 넘겨 tag 가 다음 날 달려도 그대로 둔다 (검사는 날짜의 꼴만 본다). 루트에서 `fvm dart pub get` 을 돌리고, **lock 여섯은 `fvm dart pub get` 으로만** 다시 받는다 — `example/` 과 `fixtures/` 의 다섯 폴더(`base_codegen` · `base_only` · `base_riverpod` · `overrides` · `recommended`)에서 각각 돌리고, `pub upgrade` 는 하지 않는다 (lock 마다 `woody_lints` 항목의 `version` 줄 하나만 바뀐다 — 2026-10-15 실측). 루트 `version` 만 바꾸고 lock 을 다시 받지 않은 채 돌린 검증은 종료 코드 69 로 끝나며 `example/` 의 lock 을 가리킨다 — stderr 의 안내는 `example/` 의 `pubspec.yaml` 을 바꾼 경우처럼 읽히지만, 원인은 루트 `version` 이고 이 단계의 lock 다시 받기가 답이다. 그 뒤 `fvm dart run tool/verify.dart --tag vX.Y.Z` 가 종료 코드 0 · `점검 통과 (10개 중 10개)` 인지 본다 (달려는 tag 이름으로 로컬에서 먼저 돌리는 일치 검사 — stderr 에 `버전 일치 검사: tag vX.Y.Z (--tag)` 줄이 남는다). `version` · CHANGELOG 제목 · lock 여섯 · README 의 `ref:` 예시는 같은 커밋에서 고친다.
3. 작업 브랜치를 push 하고 GitHub 의 `verify` 가 통과하는지 본다 (`gh run list --workflow verify.yml --limit 3`). push 전에는 올릴 범위 전체에 절대 경로 · 홈 폴더 · 비공개 사용 프로젝트의 이름이 들어가지 않았는지 점검한다.
4. 예행 — `fvm dart run tool/smoke.dart <릴리스 커밋>` 이 통과하는지 본다 (빈 Flutter 프로젝트가 GitHub 주소에서 그 커밋을 받아 두 주소 `recommended.yaml` · `analysis_options.yaml` 로 분석한다). README 를 따라 하다 막히면 README 를 고친 커밋으로 2 ~ 4 를 다시 한다 — tag 를 달 커밋이 바뀌기 때문이다.
5. **(직전 확인)** annotated tag 를 단다 — `git tag -a vX.Y.Z -m "woody_lints X.Y.Z" -m "<한 줄>" <릴리스 커밋>`. `git cat-file -t vX.Y.Z` 가 `tag`, `git rev-parse 'vX.Y.Z^{commit}'` 이 릴리스 커밋, `git show vX.Y.Z:pubspec.yaml` 의 `version`, `git show vX.Y.Z:CHANGELOG.md` 의 첫 줄 — 넷을 본 뒤 사람이 확인하고 `git push origin vX.Y.Z` 로 tag 이름 하나만 올린다.
6. CI 의 tag 실행을 본다 — `gh run list --workflow verify.yml --event push --json databaseId,headBranch,headSha,conclusion` 에서 `headBranch` 가 tag 이름인 실행이 success 이고, `gh run view <id> --log` 에 `버전 일치 검사: tag vX.Y.Z (GITHUB_REF_NAME)` 줄과 `점검 통과` 가 있다 (tag push 의 실행은 브랜치 push 의 실행과 따로 돈다).
7. `fvm dart run tool/smoke.dart vX.Y.Z` 가 통과하는지 본다 — 받은 lock 의 `resolved-ref` 가 `git rev-parse 'vX.Y.Z^{commit}'` 과 같다.
8. `git ls-remote --tags origin` 에서 `refs/tags/vX.Y.Z^{}` 줄이 릴리스 커밋인지 본다 (annotated tag 는 두 줄로 나온다 — 첫 줄은 tag 기록, 둘째 줄 `^{}` 가 커밋). `git ls-remote --heads origin` 으로 브랜치가 따라 올라가지 않았는지도 본다.
9. **(직전 확인)** `main` 에 병합한다 — `gh pr create --base main --head <작업 브랜치>` → `pull_request` 의 `verify` 통과 → 사람이 확인하고 `gh pr merge <번호> --merge` → `git merge-base --is-ancestor vX.Y.Z origin/main`. squash · rebase 는 쓰지 않는다 — 커밋 번호가 바뀌어 tag 를 단 커밋이 `main` 의 이력에서 빠진다. 병합은 `ref: main` 을 따르는 프로젝트에 곧바로 닿지 않는다 — 각 프로젝트가 `pub upgrade woody_lints` 를 할 때 닿는다. 처음이면 `gh workflow run verify.yml --ref main` 으로 수동 실행까지 본다.
10. 다음 작업을 시작할 때 `version: <다음 버전>-dev` 와 `## <같은 버전> - 미출시` 를 **같은 커밋**에서 넣는다 — 검사가 둘의 버전을 견준다. 한 번 올린 tag 는 옮기지 않는다 (잘못이면 새 번호).

### plugin 새 버전 때문에 정답지가 저절로 깨졌을 때

`riverpod_lint` plugin 은 분석할 때마다 pub.dev 에서 선언 범위 안의 최신으로 풀린다 (README 「tag 를 고정해도 바뀌는 것」). 그래서 저장소 · `.fvmrc` 가 그대로인데 CI 가 깨질 수 있다. 가르는 법 — 검증 화면 셋째 줄 `plugin     riverpod_lint <버전>` 을 정답지 머리 주석의 `riverpod_lint <버전>` 과 견준다. 버전이 다르고, 실패한 단계가 plugin 을 쓰는 연습용 프로젝트 넷(`example` · `recommended` · `base_riverpod` · `overrides`)뿐이며, 다른 줄의 규칙 이름이 `riverpod_lint` 의 진단이면 저장소가 아니라 plugin 이 바뀐 것이다.

대응은 다음 순서다.

- (a) pub.dev 의 `riverpod_lint` CHANGELOG 에서 그 버전의 변경을 읽는다.
- (b) 다른 단계가 모두 통과하는 상태에서 `fvm dart run tool/verify.dart --update` 로 정답지를 다시 쓴다. 다른 단계가 실패하면 쓰지 않는다 — 안전장치가 막는다.
- (c) `git diff` 로 생기거나 사라진 줄을 읽고 `test(fixtures): riverpod_lint <버전> 으로 정답지 갱신` 꼴의 **별도 커밋**으로 남긴다. 버전은 올리지 않는다 (기준표 "저장소 안쪽만 바뀜 → 올리지 않음" — 받는 쪽의 plugin 은 tag 와 상관없이 이미 바뀌어 있다).
- (d) 새 진단이 받는 쪽을 막을 만하면(warning 이상) README 「tag 를 고정해도 바뀌는 것」 에 한 줄 더한다.

`--update` 를 쓰지 않는 경우도 있다. plugin 버전이 그대로인데 정답지가 다르면 저장소의 변경(규칙 · 샘플 · SDK)이 원인이다 — 그 변경을 되짚는다. `.fvmrc` 를 올린 커밋에서 생성 파일 샘플 4줄이 더해지면 SDK 가 바뀐 것이다.
