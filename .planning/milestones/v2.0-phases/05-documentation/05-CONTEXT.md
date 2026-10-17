# Phase 5: Documentation - Context

**Gathered:** 2026-10-13
**Status:** Ready for planning

<domain>
## Phase Boundary

README 를 "몇 달 뒤의 소유자가 그대로 따라 하는 사용 안내" 로 다시 쓰고, CHANGELOG 의 빈 곳을 채우고, 배포 YAML 다섯의 머리 주석을 실제 구성에 맞게 정리한다. README 의 규칙 목록과 README 가 가리키는 값이 실제 설정과 어긋나면 검증 명령이 실패하게 한다. 이 phase 가 끝나면 다음이 참이다 (ROADMAP 성공 기준 1 ~ 5).

1. 소유자가 README 의 설치 안내와 프로젝트 유형별 include 블록을 그대로 복사해 새 프로젝트에 `ref: vX.Y.Z` 로 이 패키지를 추가할 수 있다 (DOCS-01, DOCS-02)
2. README 에 규칙을 한 줄 / 파일 / 프로젝트 단위로 끄는 방법, plugin 진단을 끄는 방법, 버전 올리기, `ref: main` 에서 tag 로 옮기는 방법, 문제 해결 절이 있고, 재정의 방법은 Phase 3 의 fixture 가 확인한 것과 같다 (DOCS-03, DOCS-04, DOCS-05)
3. README 의 규칙·설정 설명이 실제 YAML 과 일치하고(지금의 불일치 2건 해소), 규칙 목록을 YAML 과 다르게 고치면 검증 명령이 실패한다 (DOCS-06, VERIFY-06)
4. CHANGELOG 최상단에 2.0.0 항목이 `VERSIONING.md` 의 형식으로 있고, 1.0.0 과 1.3.0 사이 항목이 git 이력으로 확인되는 범위에서 채워져 있다 (DOCS-07, DOCS-08, DOCS-09)
5. 배포 YAML 의 머리 주석이 실제 구성(조각 파일, 묶음, 옛 이름 별칭)을 설명하고, README 와 YAML 에 템플릿 보일러플레이트가 남아 있지 않다 (DOCS-10)

이 phase 가 하지 않는 것: 규칙을 넣거나 빼는 일과 `analyzer.exclude` · `analyzer.errors` · `plugins:` 의 값을 바꾸는 일 (배포 설정의 내용 변경), tag 와 `main` 병합(Phase 6), CHANGELOG 2.0.0 제목의 `미출시` 를 날짜로 바꾸기와 `pubspec.yaml` 의 `-dev` 떼기(Phase 6), 사용 프로젝트에 새 버전을 적용하는 일(Out of Scope). `main` 은 건드리지 않는다.

</domain>

<decisions>
## Implementation Decisions

### 이전에 확정되어 그대로 따르는 것

다시 논의하지 않았다. 출처는 ROADMAP.md / REQUIREMENTS.md / PROJECT.md / 01 ~ 04-CONTEXT.md / `spike-findings-woody-lints` skill 이다.

- **가장 먼저 할 일:** `tool/verify.dart` 의 WR-02 (거짓 실패 — `lib/riverpod.yaml` 의 plugin 줄 끝 주석 · 마지막 줄바꿈 없음에서 `stripPlugins` · `readShippedPluginConstraint` 가 종료 코드 70) 를 YAML 머리 주석(DOCS-10)을 고치기 전에 닫는다 (04-CONTEXT.md D-12, ROADMAP Phase 5 Notes, `03-REVIEW.md` WR-02)
- **VERIFY-06 과 함께 닫을 것:** `04-REVIEW.md` WR-11 — `[3/10]` 의 겹침 (b) · `RULES.md` 일치 (c) 가 `lib/base.yaml` 만 읽어, 다른 배포 YAML 에 적은 규칙을 지나친다. README 비교도 같은 빈자리를 갖지 않게 한다. `declaredRuleNames` 를 다른 파일에 쓰면 그 `FormatException` 문구에 파일 이름을 넣는다 (IN-14) (소유자 결정 2026-10-13, ROADMAP Phase 5 Notes)
- README 는 묶음의 정식 이름 `package:woody_lints/recommended.yaml` 을 안내하고, 옛 이름 `package:woody_lints/analysis_options.yaml` 은 "예전 이름" 으로만 적는다 (PROJECT.md Key Decisions)
- README 에 싣는 include 조합은 실제로 돌려 본 조합이다 — 연습용 프로젝트 여섯(옛 주소 · 묶음 · 기본만 · 기본 + Riverpod · 기본 + codegen · 끄는 설정)에서 나온다 (03-CONTEXT.md D-03)
- 끄는 방법은 Phase 3 의 fixture 가 확인한 세 층 × 규칙 / plugin 진단 그대로다 — 프로젝트 전체는 맵 문법(`규칙: false`)과 `plugins:` 의 `version` + `diagnostics:`, 파일은 `// ignore_for_file:`, 한 줄은 `// ignore:` (plugin 진단은 `riverpod_lint/` 접두사). plugin 진단을 프로젝트 전체에서 끌 때 `version` 을 빼면 경고 없이 무시되고, `analyzer.errors` 로는 plugin 진단을 끌 수 없다 (03-CONTEXT.md D-04, spike 012, `suppression-and-exclude.md` 7번)
- 생성 파일 제외는 **사용 프로젝트의 옵션 파일에 직접** 적으라고 안내한다. "프리셋의 제외가 통하지 않는다" 를 굳은 사실로 적지 않고 SDK 버전에 따라 다르다고 적는다 (Dart 3.13.x 에서 `codegen.yaml` 의 제외는 규칙 진단에만 통하고 plugin 진단에는 통하지 않는다. 베타 3.14 에서는 규칙 진단에도 통하지 않았다 — 상류 sdk#64549). "직접 적지 않으면 진단이 쏟아진다" 로 적지 않는다. "유일한 방법" 이라고 적지 않는다 (Phase 3 UAT 1번 · PROJECT.md Key Decisions, spike 012 · 016 · 019, `suppression-and-exclude.md` 7번)
- 버전 올리기는 받는 방식에 따라 두 갈래로 적는다 — tag 로 고정한 프로젝트는 `ref:` 를 새 tag 로 고치고 `pub get`, `ref: main` 을 따르는 프로젝트는 `pub upgrade woody_lints`. `ref: main` 에서 tag 로 옮기는 것은 `ref:` 를 고치고 `pub get`. ROADMAP Phase 5 Notes 의 "버전 올리기는 `pub upgrade` 가 아니라 `ref:` 수정과 `pub get` 이다" 는 tag 쪽의 말이다. lock 을 커밋하고 `--enforce-lockfile` 을 쓰는 프로젝트는 `ref:` 를 고친 뒤 lock 도 갱신해 커밋한다 (아니면 종료 코드 65) (spike 015, `git-dependency-and-upgrade.md` 3 · 4번)
- 호환 범위는 돌려 본 범위(Riverpod 3.x, workspace 가 아닌 프로젝트)만 단정형으로 적는다. workspace 는 공식 문서의 문장을 출처와 함께 옮기고 "이 패키지로는 돌려 보지 않았다" 고 적는다 (03-CONTEXT.md D-08)
- 도구 동작은 fixture · spike 로 뒷받침되는 것만 단정형으로 쓴다. SDK 에 따라 달라지는 동작은 SDK 버전과 날짜를 붙인다 (ROADMAP Phase 5 Notes, CLAUDE.md 의 주석 관례)
- `invalid_annotation_target` 을 `analyzer.errors` 로 되살리면 기본 심각도는 warning 이다 — ROADMAP Notes 의 "README 를 쓰기 전에 확인할 것" 은 이미 답이 있다 (spike 009 — `base_only` 정답지가 `exit 2` 인 이유, Phase 2 의 M3)
- README 의 `ref:` 예시는 Phase 6 에서 만들 tag `v2.0.0` 을 가리킨다 (PROJECT.md Key Decisions, `VERSIONING.md` 실제 사례)
- 규칙마다의 이유와 실측 건수는 `RULES.md` 에 있다. README 가 `RULES.md` 를 어떻게 안내할지가 이 phase 의 일이다 (04-CONTEXT.md D-08)
- CHANGELOG 의 2.0.0 항목은 `VERSIONING.md` § "CHANGELOG 항목 형식" 을 따르고, 1.3.0 · 1.0.0 항목은 옛 불릿 형식 그대로 두고 고치지 않는다 (`VERSIONING.md` 끝 문단)
- 문서 · 주석은 한국어로 쓰고 규칙명 · 키 · 명령은 영어 원문을 쓴다. 독자는 작성자 본인이다 (PROJECT.md Constraints)

### README 규칙 목록과 자동 검사 (로드맵 D10 · VERIFY-06)

- **D-01:** README 에는 켠 규칙의 **이름만** 분류별로 적고, 이유와 건수는 `RULES.md` 로 링크한다. 이름 목록은 표시 구역(`<!-- woody:…:start -->` / `<!-- woody:…:end -->`) 안에 두고 검증 명령이 그 안을 배포 YAML 의 규칙과 견준다.
  - 이유: VERIFY-06 과 성공 기준 3 의 문구("README 의 규칙 목록이 실제 YAML 과 다르면 실패")가 그대로 성립한다. `RULES.md` 가 이미 같은 방식(표시 구역 + `[3/10]` 의 `readRulesMdBlock`)으로 `lib/base.yaml` 과 일치를 지키고 있어 그 장치를 다시 쓴다 (04-CONTEXT.md D-11 이 예고). README 만 열어도 무엇이 켜지는지 보이고, 이유 문장은 `RULES.md` 한 곳에만 둔다
  - 따라 나오는 것: 규칙을 바꾸면 `lib/base.yaml` · `RULES.md` · README 목록 세 곳을 같은 커밋에서 고친다 (어긋나면 검증이 실패한다)
  - 참고: very_good_analysis 의 README 는 켠 규칙 전체를 싣지 않고 YAML 로 링크하며, 켜지 않은 규칙 표만 표시 구역(`<!-- start:excluded_rules_table -->`)으로 감싼다
  - 고르지 않은 안: `RULES.md` 링크만 (VERIFY-06 · 성공 기준 3 의 문구를 고쳐야 한다) / 이름 + 이유 표 전부 (이유 문장이 세 곳에 생긴다)
- **D-02:** README 자동 검사는 **규칙 목록 + README 가 가리키는 값 셋**을 본다.
  - (1) README 표시 구역의 규칙 이름 ↔ 배포 YAML 의 규칙 (WR-11 의 빈자리 없이)
  - (2) README 에 나온 `package:woody_lints/<이름>.yaml` 주소가 모두 `lib/` 에 실제로 있다
  - (3) README 에 적힌 `riverpod_lint` 버전 표기가 `lib/riverpod.yaml` 의 선언과 같다
  - (4) README 의 `ref: vX.Y.Z` 예시가 `pubspec.yaml` 의 `version` (`-dev` 같은 꼬리를 뗀 값)과 같다
  - 이유: phase 목표의 "그 일치가 검증으로 지켜진다" 에 맞고, 다음 릴리스(버전 올림, plugin 하한 상향, 프리셋 이름 변경) 때 실제로 생길 어긋남을 한 줄짜리 검사로 잡는다. Phase 6 의 REL-03 은 tag · `pubspec.yaml` · CHANGELOG 만 견주고 README 는 보지 않는다
  - README 의 include · 끄는 예시 블록을 연습용 프로젝트의 옵션 파일과 글자 그대로 견주지는 않는다 — 예시는 Phase 3 의 fixture 로 이미 확인되었고, README 에 옮길 때 사람이 한 번 대조한다
  - 고르지 않은 안: 규칙 목록만 / 값 셋 + 예시 블록 통째 비교 (연습용 프로젝트의 설명 주석까지 README 와 같아야 해서 둘이 묶인다)

### README 안내의 모양

- **D-03:** README 의 명령은 **`flutter pub …`** 로 적는다 (`flutter pub get`, `flutter pub upgrade woody_lints`).
  - 이유: 읽는 사람이 Flutter 프로젝트에서 실제로 칠 명령이고, IDE 가 `pubspec.yaml` 을 저장할 때 돌리는 것도 이쪽이다
  - README 에 한 줄로 밝힌다: 실측(spike 015)은 `dart pub get` / `dart pub upgrade` 로 했다. 두 명령은 같은 `pubspec.lock` 과 패키지 목록을 만들었다 (spike 004) — "같은 pub 이 돈다" 는 이 일치에서 읽은 **추론**이다
  - README 에 한 줄로 밝힌다: `flutter pub get` 은 Flutter 프로젝트의 옵션 파일에 `build/**` 와 있는 플랫폼 폴더(`android/**` 등) 제외 줄을 덧붙인다 (Flutter 3.47.5 의 `AnalysisOptionsMigration`, 끄는 옵션 없음, 이미 제외되어 있으면 덧붙이지 않음). 이 패키지의 문제가 아니다. 상류에 이 동작을 고치는 변경이 있다 (flutter#191151 — 병합 여부는 확인하지 않았다)
  - 고르지 않은 안: `dart pub …` (잰 명령 그대로) / 둘 다 나란히
- **D-04:** 사용 프로젝트의 `dev_dependencies` 에 따로 적힌 `riverpod_lint` 줄은 **"필요 없다 — 지워도 된다"** 로 안내하고 이유를 붙인다.
  - 실측이 받치는 데까지만 단정한다: 그 줄이 있을 때와 뺐을 때 `dart analyze` 의 진단이 같았고, plugin 은 양쪽 모두 3.1.9 로 풀렸다 — 그 줄의 lock 은 3.1.3 이었다. 그 줄은 plugin 버전을 정하지 못한다. plugin 은 옵션 파일의 `plugins:` 로 받는다 (spike 019, `git-dependency-and-upgrade.md` 4번)
  - 그 줄이 다른 용도(IDE, 다른 도구)에 쓰이는지는 보지 않았다고 적는다. 지울지는 읽는 사람이 정한다
  - 참고: `riverpod_lint` 3.1.9 의 공식 설치 안내(pub.dev)는 `analysis_options.yaml` 의 `plugins:` 하나만 말하고 `dev_dependencies` 를 말하지 않는다
  - 고르지 않은 안: 지우는 것을 할 일로 안내 / 언급하지 않음

### CHANGELOG 채우기

- **D-05:** 1.0.0 과 1.3.0 사이의 빠진 버전 7개(1.1.0 · 1.2.0 · 1.2.1 · 1.2.2 · 1.2.3 · 1.2.4 · 1.2.5)를 **버전마다 항목 하나씩** 복원한다.
  - 옛 불릿 형식(지금의 1.3.0 항목과 같은 모양)으로 쓰고, 항목마다 날짜(커밋 날짜)와 커밋 번호를 적으며, `git show` 의 diff 로 확인한 변경만 적는다. 커밋 메시지를 옮겨 적지 않는다
  - 버전 숫자만 바뀐 1.2.1 · 1.2.2 는 "설정 변경 없음" 으로 적는다 (같은 날 README 만 고쳤다)
  - 이 버전들에는 tag 가 없다 — 복원 항목은 커밋 번호로만 가리킨다
  - 근거: Keep a Changelog 는 "버전마다 항목이 있어야 한다" 고 하고, 커밋 기록을 그대로 옮기는 것은 잡음이라 권하지 않는다. git 이력에서 확인한 버전별 변경은 `<specifics>` 의 표
  - 고르지 않은 안: "1.1.0 ~ 1.2.5" 한 항목으로 묶기 (`## X.Y.Z` 제목 꼴에서 벗어난다) / 설정이 바뀐 버전만 (DOCS-08 이 일부 빈다)
- **D-06:** 2.0.0 항목의 `### 올리기 전에` 에는 **꼭 할 것과 받는 때**만 둔다.
  - 꼭 할 것: Dart 3.13 미만(Flutter 3.47 미만)이면 SDK 를 올리거나 `ref: v1.3.0` 에 머문다. 옛 주소 한 줄을 쓰는 프로젝트는 고칠 것이 없다 (지금의 두 줄)
  - 받는 때: `ref: main` 을 따르는 프로젝트는 `main` 병합 뒤 `pub upgrade woody_lints` 를 하는 순간 2.0.0 을 받는다 (pub get 으로는 받지 않는다 — spike 015). Phase 1 리뷰 WR-05("받는 쪽은 tag 에 고정한다" 는 전제가 지금 사실이 아니다)를 이것으로 닫는다
  - 권하는 일(tag 로 옮기기, 생성 파일 제외를 직접 적기, `riverpod_lint` 줄, 새 경고를 `dart fix --apply` 로 고치기)은 README 의 "버전 올리기" 절에 두고 이 칸에서 링크한다
  - 이유: `VERSIONING.md` 가 이 칸을 "받는 쪽이 고쳐야 하는 것" 으로 정했고, 안내는 검사가 지키는 README 한 곳에 둔다
  - 고르지 않은 안: 권하는 일까지 이 칸에 / 지금 두 줄 그대로
- **D-07:** 2.0.0 항목의 `### 그 밖의 변경` 에서 **받는 쪽에 보이지 않는 저장소 안쪽 줄은 한 줄로 합친다.**
  - 받는 쪽에 보이는 줄(프리셋 분리, 옛 주소 별칭, `riverpod_lint` 하한, 겹치는 6개 · 주석 처리된 3개 삭제, 1.3.0 규칙 6개의 사유 주석 등)은 그대로 둔다
  - 합칠 줄: 검증 명령 · 연습용 프로젝트 · CI, 루트 분석 설정, 측정 도구와 회차 기록, 측정 도구 · 검증 명령의 결함 수정 — "저장소 안쪽: … — 사용하는 프로젝트에는 영향 없음" 꼴의 한 줄. 근거 문서 `RULES.md` 는 받는 쪽이 읽는 문서라 따로 한 줄로 남긴다
  - 이 phase 의 README · YAML 주석 정리도 그 칸에 적는다 (받는 쪽에 보이는 문서 변경)
  - 이유: 몇 달 뒤 "올릴까" 를 판단할 때 읽는 칸이다. Keep a Changelog 의 "잡음" 기준. "영향 없음을 명시한다" 는 관례(CLAUDE.md)는 합친 한 줄이 지킨다
  - 고르지 않은 안: 그대로 둠 / 저장소 안쪽 줄을 모두 지움

### YAML 머리 주석 (DOCS-10)

- **D-08:** 배포 YAML 다섯의 머리 주석은 **짧게** 둔다 — 파일마다 2 ~ 4줄.
  - 담는 것: 이 파일이 무엇을 주는지, include 주소, **왜 이 모양인지 한 줄**(파일을 고칠 사람을 위한 경고 — 예: `riverpod.yaml` 은 `analyzer: plugins:` 가 아니라 최상위 `plugins:` 여야 한다), 자세한 것은 README / `RULES.md`
  - README 로 옮기는 것: 사용법과 문제 해결 — `riverpod.yaml` 의 plugin 캐시(`~/.dartServer`) · Analysis Server 재시작 · `flutter analyze` 실측(2026-09-20) 문장
  - 지우는 것: `lib/base.yaml` 의 템플릿 영어 주석 (위의 1 ~ 12행, 15행 `# Uncomment the following section…`, 끝의 주석 4줄 `# For more information …` · `# For additional information …`) — README 의 템플릿 HTML 주석(1 ~ 12행)도 지운다
  - 남기는 것: `lib/base.yaml` 의 분류 주석과 규칙 줄마다의 사유 주석 (Phase 4 의 RULES-07, `RULES.md` 와 같은 문장)
  - `lib/codegen.yaml` 에도 머리 주석을 둔다 (지금 0줄)
  - 이유: README 는 이제 검사가 지키지만 YAML 주석은 아무것도 지키지 않는다. 같은 안내를 두 곳에 두면 YAML 쪽이 먼저 낡는다. 참고로 `lints` 의 `recommended.yaml` 머리 주석은 8줄(무엇 위에 짓는지 + 문서 링크)이고 규칙 줄 주석이 없다
  - 순서: WR-02 를 먼저 닫은 뒤에 `lib/riverpod.yaml` 의 주석을 고친다
  - 고르지 않은 안: 자세히 (README 와 같은 내용을 검사 없이 두 곳에) / 템플릿만 지우기 (`codegen.yaml` 이 설명 없이 남는다)
- **D-09:** `.claude/CLAUDE.md` 는 **DOCS-10 · 이 phase 의 결정과 부딪치는 줄만** 고친다.
  - 고칠 줄 (2026-10-13 확인한 자리): 181행 "템플릿에서 온 영어 주석(`lib/analysis_options.yaml` 1-12행, 60-64행)은 그대로 둔다" — DOCS-10 과 정면으로 부딪친다. 71행 "규칙은 `lib/analysis_options.yaml` 의 분류 주석 … 아래에 추가하고, `README.md` 의 '포함된 규칙 목록' 과 …" — 지금은 `lib/base.yaml` 에 추가하고 `RULES.md` · README 목록(D-01) · CHANGELOG 를 함께 고친다. 같은 절차를 적은 다른 줄이 있으면 같이 고친다
  - 나머지 낡은 서술(Flutter 3.41.2, `riverpod_lint ^3.1.3`, "`lib/analysis_options.yaml` 이 유일한 배포 산출물" 등)은 이 phase 에서 고치지 않는다 — 그 절들은 GSD 가 `.planning/codebase/` 지도(2026-10-11, `90a2736` 기준)로 만든 것이라, 손으로 고쳐도 낡은 지도로 다시 만들면 되돌아간다. 전체 갱신은 마일스톤 끝에 `/gsd-map-codebase` 로 한다 (Deferred)
  - 이유: 이후의 계획 · 실행 단계가 매번 읽는 지시문이 DOCS-10 과 반대되는 지시를 담고 있으면 안 된다
  - 고르지 않은 안: 전부 손으로 고치기 / 손대지 않기

### 묻지 않고 잡은 것

논의 중에 목록으로 보였고 소유자가 반대하지 않았다 (항목 끝 확인에서 "다음 항목", 마지막에 "CONTEXT 작성" 을 골랐다). 명시적으로 고른 선택지는 아니다 (02-CONTEXT.md D-12, 03-CONTEXT.md D-07, 04-CONTEXT.md D-13 ~ D-23 의 표기와 같다).

- **D-10:** 설치 안내는 tag(`ref: v2.0.0`) 만 보인다. `ref: main` 은 "tag 로 옮기는 방법" 절에서 다루고, `ref: main` 을 따르면 언제 무엇이 들어오는지(`main` 병합 뒤 `pub upgrade` 때) 한 문단으로 적는다 (PROJECT.md Key Decisions "README 를 `ref: vX.Y.Z` 기준으로 안내", DOCS-04)
- **D-11:** 프리셋 고르기는 2 × 2 표(Riverpod 을 쓰나? × 코드 생성을 쓰나?)와 복사해 쓸 include 블록 넷(묶음 · 기본만 · 기본 + Riverpod · 기본 + codegen)으로 안내한다. 블록은 연습용 프로젝트의 옵션 파일과 같은 모양이다 (03-CONTEXT.md `<specifics>` 의 네 경우 표)
- **D-12:** README 맨 위의 "핵심가치" 절은 지우고 한두 문장 소개와 `RULES.md` 링크로 바꾼다 — 지금 문구의 "불필요한 리빌드를 방지 · 성능" 은 Phase 4 가 근거 부족으로 고친 주장이다 (04-CONTEXT.md D-18, dart-lang/lints#205)
- **D-13:** 생성 파일 안내는 짧게 쓴다 — 직접 적을 두 줄(`'**/*.g.dart'`, `'**/*.freezed.dart'`), 이유 한 줄("규칙이 늘거나 생성기가 `ignore_for_file` 머리를 달지 않는 파일에서 줄이 날 수 있다"), "SDK 버전에 따라 다르다", 상류 이슈 링크. 실측에서 직접 확인한 직접 제외는 `'**/*.g.dart'` 한 줄이다 (`suppression-and-exclude.md` 7번)
- **D-14:** 문제 해결 절에서 SDK 에 따라 달라지는 동작은 SDK 버전과 날짜를 붙인다 — `flutter analyze` 는 Flutter 3.47.5 에서 plugin 진단을 내지 않았다 (3.41.9 는 냈다, 2026-09-20), 베타 3.14 의 `flutter analyze` 는 plugin 진단을 내지만 규칙 진단을 겹쳐 셌다 (spike 016). plugin 진단 확인은 `dart analyze` 로 안내한다
- **D-15:** `woody_lints` 자체는 지금처럼 사용 프로젝트의 `dev_dependencies` 에 넣으라고 안내한다 (`example/` 이 같은 자리, very_good_analysis 도 dev dependency 로 안내). `flutter_lints` 가 이 패키지의 `dependencies` 에 있어야 하는 이유는 README 가 아니라 `pubspec.yaml` 주석의 일이다
- **D-16:** README 규칙 목록의 분류는 `lib/base.yaml` 의 분류 주석(성능 / 가독성 및 스타일 / 버그 방지 / strict)을 따르고, `RULES.md` 의 "켜지 않은 규칙" 절도 링크한다
- **D-17:** CHANGELOG 2.0.0 의 `### 새로 생기는 경고` 표(74행, 0건 행 포함)와 실측 한 줄은 Phase 4 가 채운 그대로 둔다. DOCS-09 는 이 phase 에서 형식과 수치를 확인만 한다
- **D-18:** README 의 "버전 올리기" 절에 1.3.0 → 2.0.0 에서 권하는 일을 둔다 — tag 로 옮기기, 생성 파일 제외를 사용 프로젝트에 직접 적기, `dev_dependencies` 의 `riverpod_lint` 줄(D-04), CHANGELOG 의 "새로 생기는 경고" 표를 보고 `dart fix --apply` 로 고치기. CHANGELOG `### 올리기 전에` 가 이 절을 가리킨다 (D-06)
- **D-19:** Phase 1 리뷰 WR-05 는 D-06 으로 닫고 `01-REVIEW-DISPOSITION.md` 의 그 행에 적는다. Phase 3 리뷰 WR-02 · Phase 4 리뷰 WR-11 · IN-14 도 닫으면 각자의 처리 기록에 적는다
- **D-20:** README · CHANGELOG · YAML 주석에도 비공개 사용 프로젝트의 파일 경로 · 진단 메시지 · 코드 조각 · 기능 이름을 적지 않는다. CHANGELOG 의 `실측: flutter_starter_kit (Dart 파일 474개), …` 한 줄은 허용된 범위다 (04-CONTEXT.md D-07)
- **D-21:** GitHub 에 올리기는 Phase 4 와 같은 방식이다 — 이 phase 의 **첫 push 만** 확인받고, 같은 브랜치(`gsd/v2.0-package-rework`)에 더 올리는 것은 실행한 뒤 보고한다. `main` · tag · 덮어쓰는 push(`--force` 계열)는 매번 확인받는다. push 는 브랜치 이름 하나만 지정한다. push 전에 범위 전체에 비공개 점검을 돌린다 (04-CONTEXT.md D-22) — **Reversibility:** one-way — `woodkill/woody_lints` 는 공개 저장소이고 `.planning/` 도 함께 올라가므로, 한 번 올린 내용은 브랜치를 지워도 복제본 · 캐시에 남는다

### Claude's Discretion

소유자에게 묻지 않고 조사 · 계획 단계에 맡긴 것.

- WR-11 을 닫는 방법 — 배포 YAML 다섯 전체에서 규칙을 모아 견주거나, "규칙은 `lib/base.yaml` 에만 둔다" 를 검사로 고정하거나. 어느 쪽이든 README 비교(D-02 (1))와 `[3/10]` 의 (b) · (c) 가 같은 규칙 집합을 본다
- README 표시 구역의 이름과 목록의 모양(분류마다 한 줄에 이름을 이어 쓸지, 목록으로 쓸지), README 검사를 `[3/10]` 에 넣을지 새 단계로 둘지, 단계 수와 번호, 실패 문구
- D-02 (2) ~ (4) 의 읽는 방법 — README 의 어느 자리에서 주소 · plugin 버전 · `ref:` 를 찾을지, `-dev` 꼬리를 떼는 규칙
- 새 검사가 헛통과가 아님을 보이는 지워 보기 기록 (`example/README.md` 의 M 번호, 지금 M31 까지) — 규칙 목록 어긋남, 없는 프리셋 주소, plugin 버전 어긋남, `ref:` 어긋남
- README 의 절 순서와 제목, 프리셋 표와 include 블록의 배치, 문제 해결 절의 항목 구성 (DOCS-05 가 이름을 든 넷 — plugin 경고가 안 보일 때, Analysis Server 재시작, `dart analyze` 와 `flutter analyze` 의 차이, tag 를 고정해도 바뀌는 것(plugin 버전 · 기반 세트의 caret 범위))
- plugin 준비 실패 복구 안내의 문구 — 잰 것(전용 상태 폴더에서 컴파일된 plugin 이 깨지면 지울 때까지 실패 — spike 008)은 단정하고, 기본 자리(`~/.dartServer/.plugin_manager`)에 옮겨 적는 것은 읽은 것으로 적는다
- CHANGELOG 복원 항목의 정확한 제목 꼴과 문구 (옛 형식에 맞추되 날짜와 커밋을 어디에 둘지), 1.2.3 · 1.2.4 에 "그때 patch 로 냈다" 를 적을지 (`VERSIONING.md` 실제 사례가 이미 적고 있다)
- YAML 머리 주석의 정확한 문구
- WR-02 를 닫는 방법 (`stripPlugins` · `readShippedPluginConstraint` 가 줄 끝 주석 · 마지막 줄바꿈 없음을 받게 하기)과 지워 보기 기록
- 커밋 나누기 — WR-02 를 먼저, 그다음 YAML 주석 · README · 검사 · CHANGELOG. README 목록과 검사는 같은 커밋이 자연스럽다 (검사만 먼저 넣으면 지금 README 에서 실패한다)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 범위와 요구사항

- `.planning/ROADMAP.md` § "Phase 5: Documentation" — goal, success criteria 5개, decision point D10, Notes (가장 먼저 할 일 WR-02, VERIFY-06 과 함께 닫을 WR-11, 빠지기 쉬운 내용, 생성 파일 제외의 범위)
- `.planning/ROADMAP.md` § "모든 phase 에 걸친 제약" — `main` 은 1.3.0 유지, 원격 작업은 소유자 확인
- `.planning/REQUIREMENTS.md` — DOCS-01 ~ DOCS-10, VERIFY-06. Out of Scope 표 (영어 README, pub.dev 게시)
- `.planning/PROJECT.md` § Constraints (Documentation — 한국어), § Key Decisions (README 를 `ref: vX.Y.Z` 기준으로, 묶음의 정식 이름, 성공 기준 3 의 읽는 법)

### README 에 옮길 사실 (실측 근거)

- `.claude/skills/spike-findings-woody-lints/SKILL.md` — "읽을 때 헷갈리기 쉬운 것" (고정 SDK 의 사실과 SDK 와 무관한 사실을 가르는 법)
- `.claude/skills/spike-findings-woody-lints/references/git-dependency-and-upgrade.md` 3 · 4번 — lock 이 언제 따라가는가, 버전 올리기 두 갈래 표, `dev_dependencies` 의 `riverpod_lint` 줄, `flutter pub` 로 재지 않았다는 점
- `.claude/skills/spike-findings-woody-lints/references/suppression-and-exclude.md` 1 · 2 · 4 · 5 · 6 · 7번 — 끄는 방법 여섯 칸, 꺼지지 않는 모양, `ignore_for_file: type=…`, `analyzer.exclude` 가 통하는 조건, "Phase 5 의 README 에 적을 것"
- `.claude/skills/spike-findings-woody-lints/references/next-sdk-forward-compat.md` — 베타에서 달라진 셋 (생성 파일 제외, `flutter analyze`, 루트 분석의 plugin 준비). README 에 SDK 따라 다른 동작을 적을 때
- `.claude/skills/spike-findings-woody-lints/references/example-project-and-expected-file.md` § Constraints — `flutter pub get` 의 `AnalysisOptionsMigration` (D-03 의 메모)
- `.claude/skills/spike-findings-woody-lints/references/real-consumer-measurement.md` 5번 — 사용 프로젝트에서 나누기 전후가 같다, `dev_dependencies` 의 `riverpod_lint` 줄
- `.claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md` — plugin 준비 실패의 신호와 복구 (문제 해결 절)
- `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/analysis_options.yaml`, `example/analysis_options.yaml` — README 의 include 블록과 끄는 예시가 따를 모양 (D-11, 03-CONTEXT.md D-03 · D-04)
- `fixtures/overrides/lib/suppress/` (`lint_file.dart` · `lint_line.dart` · `plugin_file_prefixed.dart` · `plugin_file_unprefixed.dart` · `plugin_line.dart`) — 주석으로 끄는 예시가 따를 모양

### 검증 명령

- `tool/verify.dart` — 아래 code_context 의 자리
- `RULES.md` — 표시 구역 넷 (`woody:enabled-rules` 9 ~ 93행, `woody:enabled-options` 99 ~ 103행, `woody:disabled-rules` 119 ~ 212행, `woody:measurements` 218 ~ 425행). README 표시 구역(D-01)의 선례
- `example/README.md` — 지워 보기 기록 M1 ~ M31 (새 검사의 기록을 같은 형식으로 더한다)
- `.planning/phases/03-preset-split/03-REVIEW.md` § WR-02, `03-REVIEW-DISPOSITION.md` (deferred — Phase 5 의 첫 일)
- `.planning/phases/04-rule-reselection/04-REVIEW.md` § WR-11 · IN-14, `04-REVIEW-DISPOSITION.md` (WR-11 deferred — VERIFY-06 과 함께)
- `.planning/phases/04-rule-reselection/04-CONTEXT.md` § D-11 (`RULES.md` 일치 검사 — VERIFY-06 이 이어 쓴다), § D-12 (WR-02 를 Phase 5 로)

### 버전 · 기록 정책

- `VERSIONING.md` § "CHANGELOG 항목 형식" (칸 순서, `### 올리기 전에` 의 정의, 제목의 ` - ` 한 번 — REL-03 이 읽는다), § "실제 사례" (1.2.3 · 1.2.4 의 옛 판정), 끝 문단 (1.3.0 · 1.0.0 은 옛 형식 그대로, 빠진 버전 보완은 Phase 5)
- `CHANGELOG.md` — 2.0.0 항목(1 ~ 185행), 1.3.0 (187 ~ 193행), 1.0.0 (195 ~ 197행)
- `.planning/phases/01-baseline-and-toolchain/01-REVIEW.md` § WR-05, `01-REVIEW-DISPOSITION.md` (D-06 이 닫는다)
- git 이력 `90a2736` 이전 — 빠진 버전의 출처 (`<specifics>` 의 표)

### 지시문

- `.claude/CLAUDE.md` 71행 · 181행 — D-09 가 고칠 줄 (2026-10-13 확인)

### 논의에서 참고한 외부 문서

- https://github.com/VeryGoodOpenSource/very_good_analysis/blob/main/README.md — 켠 규칙은 YAML 링크, 켜지 않은 규칙 표만 표시 구역, 끄는 방법 세 층, dev dependency 설치 (D-01, D-15)
- https://github.com/dart-lang/core/blob/main/pkgs/lints/lib/recommended.yaml — 머리 주석 8줄, 규칙 줄 주석 없음 (D-08)
- https://pub.dev/packages/riverpod_lint — 3.1.9 의 설치 안내는 `plugins:` 뿐 (D-04. 2026-10-13 읽음)
- https://keepachangelog.com/en/1.1.0/ — 버전마다 항목, 커밋 기록은 잡음 (D-05, D-07)
- https://flutter.googlesource.com/mirrors/flutter/+/c7a822e59b5b37c4fa74f0cc71e9d1f4e25ac7ff — flutter#191151, `flutter pub get` 의 제외 줄 덧붙이기를 고치는 변경 (D-03. 병합 여부 확인 안 함)
- https://github.com/dart-lang/sdk/issues/64549 — 생성 파일 제외가 SDK 에 따라 다른 원인 (spike 016, D-13)
- https://dart.dev/tools/pub/dependencies — git 의존성의 `ref:` (tag · branch · commit). `pub get` / `pub upgrade` 의 차이는 이 문서에 없고 spike 015 가 쟀다

</canonical_refs>

<code_context>
## Existing Code Insights

### 논의 시점의 저장소 상태 (2026-10-13 확인)

- `README.md` (95행): 1 ~ 12행 템플릿 HTML 주석, 14행 소개, 16 ~ 21행 "핵심가치", 23 ~ 68행 사용법 (`dev_dependencies` · `ref: main` · `flutter pub get` / `flutter pub upgrade woody_lints` · 옛 주소 include · lock 으로 설치 확인), 70 ~ 95행 "포함된 규칙 목록" (1.3.0 의 12개 — 81행 `require_trailing_commas` 와 91 ~ 92행 `formatter: trailing_commas` 가 실제와 다른 불일치 2건, `analyzer:` 설정은 적혀 있지 않음)
- `CHANGELOG.md` (197행): `## 2.0.0 - 미출시` 의 `### 올리기 전에` 5 ~ 8행(두 줄), `### 추가한 규칙` 10 ~ 86행(75개), `### 그 밖의 변경` 88 ~ 99행(10줄), `### 새로 생기는 경고` 101 ~ 185행(74행 표 + 실측 한 줄 + 설명 두 문단). `## 1.3.0` 187행, `## 1.0.0` 195행 — 사이 버전 없음
- `lib/base.yaml` (112행): 1 ~ 12행 · 15행 · 끝의 주석 4줄이 템플릿 영어 주석, 13행 `include: package:flutter_lints/flutter.yaml`, 분류 주석 19행 `# 성능` · 31행 `# 가독성 및 스타일` · 77행 `# 버그 방지` · 103행 `# strict — …`, 규칙 81개 (모두 줄 끝 사유 주석)
- `lib/riverpod.yaml` (10행): 1 ~ 8행 주석, 9 ~ 10행 `plugins: riverpod_lint: ^3.1.9`. `lib/codegen.yaml` (7행, 주석 없음). `lib/recommended.yaml` (6행, 주석 2줄). `lib/analysis_options.yaml` (3행, 주석 2줄)
- `pubspec.yaml` 의 `version: 2.0.0-dev` — D-02 (4) 의 비교 대상. Phase 6 이 `-dev` 를 뗀다
- `tool/verify.dart` 는 단계 10개이고 `[3/10]` 이 "배포 파일의 구성" 이다

### Reusable Assets

- `tool/verify.dart` (1,859행): `fixtures` 41행, `shippedCompositionLabel` 115행, `ruleCheckTargets` 142행, `expectedLibYamls` 157행 (배포 YAML 다섯의 집합 — D-02 (2) 가 견줄 대상), `stripPlugins` 793행, `declaredRuleNames` 885행, `checkRuleNames` 999행, `checkFixtureOptions` 1149행 (연습용 프로젝트의 `version:` 을 `lib/riverpod.yaml` 과 견주는 선례 — D-02 (3)), `readShippedPluginConstraint` 1191행 (WR-02 의 자리이자 D-02 (3) 이 쓸 값), `readRulesMdBlock` 1302행 (표시 구역 읽기 — D-01 이 다시 쓴다), `checkShippedComposition` 1339행 (`[3/10]`)
- `RULES.md` 의 표시 구역 꼴 `<!-- woody:<이름>:start -->` / `<!-- woody:<이름>:end -->`
- `fixtures/*/analysis_options.yaml` 다섯과 `example/analysis_options.yaml` — README include 블록의 원본

### Established Patterns

- 검증 명령의 종료 코드는 0 통과 / 1 단계 실패 / 64 사용법 오류 / 69 `pub get` 실패 / 70 예외 / 78 SDK 불일치다. 문서 · 파일 모양의 이상은 단계 실패(1), 읽을 수 없는 입력은 70 (WR-10 의 선례)
- 새 검사는 헛통과가 아님을 지워 보기(M 번호)로 실제로 만들어 확인하고 `example/README.md` 에 기록한다
- 실측으로 확인한 동작은 버전과 날짜를 함께 적고, 추정 · 추론은 그렇다고 적는다
- 커밋 메시지는 Conventional Commits, prefix 는 영어, 제목 · 본문은 한국어. 커밋 전에 `fvm dart analyze` 와 검증 명령을 돌린다
- 비공개 프로젝트의 기록은 건수와 규칙 이름만 (04-CONTEXT.md D-07)

### Integration Points

- **Phase 6:** README 의 `ref: v2.0.0` 은 Phase 6 이 만들 tag 를 가리킨다. Phase 6 이 `pubspec.yaml` 의 `-dev` 를 떼도 D-02 (4) 는 그대로 통과한다. 다음 릴리스(2.1.0 등)에서 버전을 올리면 README 예시를 함께 고쳐야 검증이 통과한다 — 의도한 동작이다. CHANGELOG 2.0.0 제목의 `미출시` 는 Phase 6 이 날짜로 바꾼다
- **Phase 6 의 REL-03:** CHANGELOG 최상단 제목의 ` - ` 앞 토큰을 읽는다. 복원 항목(D-05)은 최상단이 아니므로 영향이 없다
- **마일스톤 끝:** `/gsd-map-codebase` 로 `.planning/codebase/` 지도와 `.claude/CLAUDE.md` 의 낡은 절을 다시 만든다 (D-09)

</code_context>

<specifics>
## Specific Ideas

### git 이력으로 확인한 빠진 버전 (2026-10-13, `git show` 로 확인 — D-05 의 재료)

| 버전 | 날짜 | 버전 커밋 | diff 로 확인한 변경 |
|---|---|---|---|
| 1.1.0 | 2025-12-22 | `2249a0b` | 기반 세트를 `package:lints/recommended.yaml` 에서 `package:flutter_lints/flutter.yaml` 로 바꿈, 의존성 `lints` → `flutter_lints` (`126aa43`, 버전 숫자는 `2249a0b`) |
| 1.2.0 | 2025-12-24 | `ec66e3f` | `formatter: trailing_commas: preserve` 추가 |
| 1.2.1 | 2025-12-30 | `21c5689` | 버전 숫자만 (같은 날 README 수정 `9950fd1`) |
| 1.2.2 | 2026-01-03 | `31c8cb1` | 버전 숫자만 (같은 날 README 수정 `7b7455e`) |
| 1.2.3 | 2026-01-28 | `9451f6b` | `slash_for_doc_comments` 추가 |
| 1.2.4 | 2026-02-27 | `212365d` | `public_member_api_docs` 추가, `analyzer:` 의 exclude · errors 추가 (`.fvmrc` 도 바뀜) |
| 1.2.5 | 2026-03-23 | `dbcd20b` | `formatter:` · `require_trailing_commas` · `public_member_api_docs` 를 주석 처리 |

계획 단계는 각 커밋의 diff 를 다시 읽고 적는다 — 위 표는 바뀐 파일 목록과 일부 diff 로 만든 요약이다.

### 프리셋 고르기 표 (D-11 — 03-CONTEXT.md 의 네 경우)

| | 코드 생성을 쓴다 | 코드 생성을 쓰지 않는다 |
|---|---|---|
| **Riverpod 을 쓴다** | `recommended.yaml` (묶음) | `base.yaml` + `riverpod.yaml` |
| **Riverpod 을 쓰지 않는다** | `base.yaml` + `codegen.yaml` | `base.yaml` |

### 소유자와 소통하는 방식

- 결정을 요청할 때는 용어 풀이 → 찾아본 것(출처와 함께) → 비교표 → 굵은 `권고:` 한 줄 → 선택지 순서로 보였다. 소유자는 이번 논의의 선택 9건 모두에서 권고안을 골랐고, 항목 끝 확인 넷 모두 "다음 항목" 이었다
- 쉬운 말: 표시 구역(marker), 연습용 프로젝트(fixture), 정답지(golden), 받는 쪽(사용 프로젝트), "GitHub 에 올린다"(push)
- 추론(`flutter pub` 과 `dart pub` 이 같은 pub 을 돈다)은 추론이라고 적어 보였다

</specifics>

<deferred>
## Deferred Ideas

- **프리셋에 `build/**` 와 플랫폼 폴더 제외를 넣을지** — 넣으면 사용 프로젝트의 `flutter pub get` 이 옵션 파일에 제외 줄을 덧붙이지 않는다 (`example-project-and-expected-file.md` 의 "Phase 4 로 넘긴 것" — Phase 4 에서 정하지 않았다). 배포 설정의 내용 변경(minor)이라 문서 phase 밖이다. 이번 README 는 그 동작을 메모로만 적는다 (D-03)
- **`.claude/CLAUDE.md` 전체 갱신과 `.planning/codebase/` 지도 다시 만들기** — 마일스톤 끝에 `/gsd-map-codebase` 로 (D-09)
- **`VERSIONING.md` 30행에 "plugin · 기반 세트의 하한을 올릴 때는 새 하한이 요구하는 Dart 버전을 본다" 는 문장 더하기** — ROADMAP Backlog `Phase 999.1` 그대로. 이 phase 에서 다루지 않는다
- **Phase 1 리뷰 WR-03 (`VERSIONING.md` 판정 순서와 기준표가 다른 등급을 내는 경우)** — D-05(01-CONTEXT.md)를 건드리는 소유자 결정이 필요하고 이 phase 의 문서 일과 겹치지 않는다
- **README 예시 블록을 연습용 프로젝트 옵션 파일과 자동으로 견주기** — D-02 에서 고르지 않았다. README 예시가 틀어지는 일이 실제로 생기면 다시 본다

</deferred>

---

*Phase: 5-Documentation*
*Context gathered: 2026-10-13*
