# Phase 5: Documentation - Research

**Researched:** 2026-10-13
**Domain:** 설정 전용 패키지의 사용 문서 — README 다시 쓰기, CHANGELOG 복원, 배포 YAML 머리 주석, 그리고 README ↔ 배포 YAML 일치를 지키는 검증 명령(`tool/verify.dart`)의 새 검사 (VERIFY-06) 와 먼저 닫을 결함 둘 (03-REVIEW WR-02, 04-REVIEW WR-11 · IN-14)
**Confidence:** HIGH — 조사 대상의 거의 전부가 이 저장소 안의 파일(`tool/verify.dart`, `lib/*.yaml`, `README.md`, `CHANGELOG.md`, `VERSIONING.md`, `example/README.md`, 리뷰 · 처리 기록, spike references)과 git 이력이고, 이 세션에서 `Read` · `git show` 로 직접 읽었다. WR-02 는 저장소 복제본(scratchpad)에서 실제로 재현했고, 제안하는 고친 판도 같은 복제본에서 함수 단위로 돌려 봤다. 바깥에서 가져온 것은 CONTEXT 가 이미 읽은 외부 문서(very_good_analysis README, lints `recommended.yaml`, pub.dev riverpod_lint, Keep a Changelog)이고 이 세션에서 다시 열지 않았다 — 그 인용은 `[CITED]` 다

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### 이전에 확정되어 그대로 따르는 것

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

#### README 규칙 목록과 자동 검사 (로드맵 D10 · VERIFY-06)

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

#### README 안내의 모양

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

#### CHANGELOG 채우기

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

#### YAML 머리 주석 (DOCS-10)

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

#### 묻지 않고 잡은 것

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

### Deferred Ideas (OUT OF SCOPE)

- **프리셋에 `build/**` 와 플랫폼 폴더 제외를 넣을지** — 넣으면 사용 프로젝트의 `flutter pub get` 이 옵션 파일에 제외 줄을 덧붙이지 않는다 (`example-project-and-expected-file.md` 의 "Phase 4 로 넘긴 것" — Phase 4 에서 정하지 않았다). 배포 설정의 내용 변경(minor)이라 문서 phase 밖이다. 이번 README 는 그 동작을 메모로만 적는다 (D-03)
- **`.claude/CLAUDE.md` 전체 갱신과 `.planning/codebase/` 지도 다시 만들기** — 마일스톤 끝에 `/gsd-map-codebase` 로 (D-09)
- **`VERSIONING.md` 30행에 "plugin · 기반 세트의 하한을 올릴 때는 새 하한이 요구하는 Dart 버전을 본다" 는 문장 더하기** — ROADMAP Backlog `Phase 999.1` 그대로. 이 phase 에서 다루지 않는다
- **Phase 1 리뷰 WR-03 (`VERSIONING.md` 판정 순서와 기준표가 다른 등급을 내는 경우)** — D-05(01-CONTEXT.md)를 건드리는 소유자 결정이 필요하고 이 phase 의 문서 일과 겹치지 않는다
- **README 예시 블록을 연습용 프로젝트 옵션 파일과 자동으로 견주기** — D-02 에서 고르지 않았다. README 예시가 틀어지는 일이 실제로 생기면 다시 본다
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DOCS-01 | 소유자는 README 만 보고 새 프로젝트에 이 패키지를 `ref: vX.Y.Z` 로 추가할 수 있다 | § 4 의 README 내용 목록 "설치" 행 — `dev_dependencies` 자리(D-15), `ref: v2.0.0`(D-10), `flutter pub get`(D-03). 지금 README 25 ~ 68행의 `ref: main` 설치 안내는 지운다. 검사 (4) 가 `ref:` 값을 `pubspec.yaml` 과 묶는다 (§ 2) |
| DOCS-02 | README 에 프로젝트 유형별로 복사해 쓸 include 블록이 있다 | § 4 "프리셋 고르기" — 2 × 2 표와 블록 넷의 원본은 `fixtures/{recommended,base_only,base_riverpod,base_codegen}/analysis_options.yaml` (이 세션에서 읽었다, 글자 그대로 인용). 검사 (2) 가 주소 오타를 잡는다 |
| DOCS-03 | 규칙을 한 줄 / 파일 / 프로젝트 단위로 끄는 방법과 plugin 진단을 끄는 방법 | § 4 "끄기" — 세 층 × 둘의 원본은 `fixtures/overrides/analysis_options.yaml` 과 `lib/suppress/` 다섯 파일 (인용). 함정 셋(`version` 없으면 무시, 접두사 없으면 안 꺼짐, `analyzer.errors` 로 안 꺼짐)은 spike 012 실측 |
| DOCS-04 | 버전 올리기(`ref:` 수정과 `pub get`)와 `ref: main` → tag 옮기기 | § 4 "버전 올리기" — spike 015 의 pub-1 ~ pub-7 표 (`git-dependency-and-upgrade.md` 3 · 4번). 두 갈래 + 전환 + `--enforce-lockfile` 65 |
| DOCS-05 | 문제 해결 절 (plugin 경고가 안 보일 때, Analysis Server 재시작, `dart analyze` 와 `flutter analyze` 의 차이, tag 를 고정해도 바뀌는 것) | § 4 "문제 해결" — 항목 넷의 근거와 단정 범위 (`analyze-run-and-verdict.md` 6 · 7번, `next-sdk-forward-compat.md` 6번, 지금 `lib/riverpod.yaml` 4 ~ 8행의 문장) |
| DOCS-06 | README 의 규칙 · 설정 설명이 실제 YAML 과 일치 (불일치 2건과 기재되지 않은 설정 해소) | § 4 "지울 줄" — README 81행 `require_trailing_commas`, 91 ~ 92행 `formatter:`, `analyzer:` 미기재. D-01 의 표시 구역(81개 이름)과 `codegen.yaml` 설명으로 해소. 검사 (1) 이 재발을 막는다 |
| DOCS-07 | CHANGELOG 에 새 릴리스 항목 (추가 · 삭제 규칙, 지원 SDK 변경) | 이미 있다 — `CHANGELOG.md` 1 ~ 185행 `## 2.0.0 - 미출시` (§ 3). 이 phase 는 D-06 (`### 올리기 전에`) · D-07 (`### 그 밖의 변경` 합치기) 만 고친다 |
| DOCS-08 | 1.0.0 과 1.3.0 사이 누락을 git 이력 범위로 보완 | § 3 — 커밋 10개를 `git show` 로 다시 읽은 버전별 diff 표. CONTEXT 표에서 빠진 것 1건(1.2.4 의 legacy `analyzer: plugins:`) 과 보탤 것 2건 |
| DOCS-09 | 새 릴리스 항목에 새로 생기는 진단 안내 (규칙별 실측 건수, `dart fix` 가능 여부) | 이미 있다 — `CHANGELOG.md` 101 ~ 185행 표 74행 + 실측 한 줄. D-17 대로 확인만 (§ 3 의 확인 명령) |
| DOCS-10 | 배포 YAML 머리 주석이 실제 구성을 설명하고, README · YAML 에 템플릿 보일러플레이트가 없다 | § 5 — 다섯 파일의 지금 머리 주석 전문과 지울 줄 번호 (`lib/base.yaml` 1 ~ 12 · 15 · 108 ~ 112행, `README.md` 1 ~ 12행). 순서 제약: WR-02 를 먼저 (§ 1) |
| VERIFY-06 | README 의 규칙 목록이 실제 YAML 과 다르면 검증이 실패한다 | § 2 — `[3/10]` 에 (d) ~ (g) 를 더하는 설계, 읽는 자리, 실패 문구, 종료 코드, 지워 보기 M32 ~ 의 안 |
</phase_requirements>

## Summary

이 phase 의 산출물은 전부 문서(README · CHANGELOG · YAML 주석 · `.claude/CLAUDE.md` 두 줄)와 `tool/verify.dart` 의 검사 코드이고, 새 외부 의존성 · 새 도구 · 네트워크가 없다. 사실의 출처는 세 겹이다 — (가) spike 실측(2026-10-11 ~ 12)이 skill references 에 정리되어 있고, (나) Phase 3 의 fixture 여섯이 그 사실을 저장소 안의 정답지로 고정하고 있으며, (다) git 이력이 1.0.0 ~ 1.3.0 의 버전별 변경을 담고 있다. 이 세션은 (나) 와 (다) 를 직접 읽고 (가) 는 references 의 절 단위로 읽었다. README 에 들어갈 문장마다 "어디서 왔고 단정형으로 써도 되는가" 를 § 4 의 표로 정리했다.

코드 쪽의 핵심은 셋이다. **첫째, WR-02 는 재현된다** — 저장소 복제본에서 `lib/riverpod.yaml` 의 plugin 줄 끝에 ` # 하한` 을 붙이면 `readShippedPluginConstraint` 가, 마지막 줄바꿈을 지우면 `stripPlugins` 가 `FormatException` 을 던져 둘 다 stdout 0 바이트 · 종료 코드 70 으로 끝난다 (§ 1, 2026-10-13 실측). 같은 복제본에서 03-REVIEW 가 제안한 줄 단위 `stripPlugins` 와 줄 끝 주석 · 맵 형식을 받는 선언 읽기를 함수 단위로 돌려 입력 10가지가 모두 통과하는 것을 봤다 — 고친 `stripPlugins` 는 섹션을 **빈 줄로 바꾸므로** 복사본의 줄 번호가 원본과 같아져 `fragmentLineHint` 의 "앞당겨진다" 문장을 함께 고쳐야 한다. **둘째, WR-11 은 "규칙은 `lib/base.yaml` 에만" 을 검사로 고정하는 쪽(B안)을 권한다** — `[3/10]` (a) 의 `includeOnlyFiles`, `rulesFile` 상수, `RULES.md` 의 "켠 규칙" 머리 문장, M20 ~ M31 의 `(base.yaml 에만)` 기호가 모두 그 관례 위에 있어, 다섯 파일에서 규칙을 모으는 A안은 이 자리를 전부 다시 쓰게 하면서 얻는 것이 없다. 코드는 (b) 앞에 7줄이다. **셋째, README 검사는 `[3/10]` 안에 (d) ~ (g) 로 넣는 쪽을 권한다** — 단계를 하나 더 두면 `example/README.md` 의 지워 보기 기록 M20 ~ M31 과 CHANGELOG 2.0.0 의 두 줄이 이미 `[3/10]` · `[5/10]` ~ `[10/10]` · `10개 중` 을 글자로 담고 있어(이 세션에서 셈한 자리 30곳 남짓, § 2 의 목록), 그 역사 기록을 고치거나 "그때는 10단계였다" 각주를 달아야 한다.

CHANGELOG 복원 재료는 CONTEXT 의 표가 거의 맞지만 **1.2.4 (`212365d`) 에서 빠진 것이 하나 있다** — `analyzer:` 블록에 exclude · errors 와 함께 옛 방식 `plugins: - riverpod_lint` 가 들어갔다 (1.3.0 항목이 "옛 `analyzer: plugins:` 선언은 아무것도 로드하지 않았다" 고 적은 그 선언의 출발점). `.vscode/settings.json` 도 같은 커밋에서 바뀌었고, 1.0.0 의 기반 세트는 `package:lints/recommended.yaml` 이었다 (§ 3).

**Primary recommendation:** 커밋을 다섯 묶음으로 나눈다 — ① `tool/verify.dart` WR-02 (+ `fragmentLineHint` 문구, M32 ~ M34 기록) → ② `tool/verify.dart` WR-11 · IN-14 (M35 · M36) → ③ YAML 머리 주석 다섯 + `.claude/CLAUDE.md` 71 · 181행 → ④ README 전면 재작성 + `[3/10]` (d) ~ (g) 같은 커밋 (M37 ~ M40) → ⑤ CHANGELOG (복원 7항목, D-06, D-07) + 처리 기록 넷(01 WR-05, 03 WR-02, 04 WR-11 · IN-14). 커밋마다 `fvm dart analyze` · `fvm dart format --output=none --set-exit-if-changed tool` · `fvm dart run tool/verify.dart` 와 § 6 의 비공개 점검을 돌린다.

## Architectural Responsibility Map

이 저장소에는 실행 코드가 없으므로 "tier" 는 산출물이 사는 자리로 읽는다.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 사용 안내 (설치 · 프리셋 · 끄기 · 버전 올리기 · 문제 해결) | `README.md` | `RULES.md` (이유 · 건수) | 독자가 읽는 한 곳. 검사가 지키는 문서는 README 하나 (D-08) |
| README ↔ 배포 YAML 일치 | `tool/verify.dart` `[3/10]` (d) ~ (g) | 정답지 비교 `[5/10]` ~ `[10/10]` 은 README 를 보지 않는다 | VERIFY-06. 표시 구역 + `readRulesMdBlock` 꼴의 재사용 (D-01) |
| 배포 YAML 의 자기 설명 | `lib/*.yaml` 머리 주석 2 ~ 4줄 | README · `RULES.md` 로 링크 | D-08 — 주석은 검사가 지키지 않으므로 짧게 |
| 버전 이력 | `CHANGELOG.md` | `VERSIONING.md` (형식 · 실제 사례), git 이력 | D-05 ~ D-07, REL-03 이 최상단 제목만 읽는다 |
| 검증 결함 닫기 (WR-02 · WR-11 · IN-14) | `tool/verify.dart` | `example/README.md` M 기록, 처리 기록 셋 | 문서보다 먼저 — YAML 주석을 고칠 때 밟는 자리 (D-12) |
| 지시문 정합 | `.claude/CLAUDE.md` 71 · 181행 | — | D-09 — 부딪치는 두 줄만 |
| 비공개 정보 차단 | 커밋 전 grep (§ 6) | — | D-20 · D-21, 04-RESEARCH § 8 의 패턴 재사용 |

## Standard Stack

이 phase 는 **외부 패키지를 하나도 새로 설치하지 않는다.** `tool/verify.dart` 는 `dart:io` · `dart:convert` 만 쓴다 `[VERIFIED: tool/verify.dart:27-28]` — `import 'dart:convert';` / `import 'dart:io';`. 03-REVIEW WR-02 의 "루트 `dev_dependencies` 에 `yaml` 을 두고 `loadYaml`" 대안은 쓰지 않는다 (02-CONTEXT.md D-11 의 제약, § Alternatives).

### Core

| Library / Tool | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Dart SDK (fvm, `.fvmrc` Flutter 3.47.5) | 3.13.4 `[VERIFIED: fvm dart --version, 2026-10-13]` | 검증 명령 실행 · 규칙 검사의 `dart analyze` | 저장소 고정 SDK. 검증 명령이 `.fvmrc` 와 다르면 78 로 멈춘다 |
| `tool/verify.dart` | 1,859행 (HEAD `d1b04de`) `[VERIFIED: wc -l]` | 단계 10개의 검증. 이 phase 가 `[3/10]` 을 넓히고 `stripPlugins` · `readShippedPluginConstraint` · `declaredRuleNames` 를 고친다 | 기존 장치 재사용 (D-01) |
| git | 2.56.0 `[VERIFIED: git --version]` | CHANGELOG 복원의 `git show`, 비공개 점검의 `git grep` | — |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `gh` | 2.102.0 `[VERIFIED: gh --version]` | 첫 push 뒤 GitHub `verify` 실행 확인 | D-21 의 push 뒤 |
| `fvm` | 4.3.1 `[VERIFIED: fvm --version]` | `fvm dart …` | 모든 명령 |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| 정규식 줄 읽기 (`readShippedPluginConstraint` 고침) | `package:yaml` 의 `loadYaml` (03-REVIEW WR-02 의 둘째 안) | 새 pub 의존성이 `dev_dependencies` 에 생긴다 — 02-CONTEXT.md D-11 "`dart:io` · `dart:convert` 만" 과 부딪친다. 줄 단위 정규식으로 입력 10가지가 모두 통과했다 (§ 1) |
| `[3/10]` 안에 README 검사 (d) ~ (g) | 새 단계 `[4/11]` "README 일치" | 화면이 더 읽기 쉽지만 번호가 밀려 `example/README.md` 의 역사 기록 30곳 남짓과 CHANGELOG 두 줄을 건드린다 (§ 2) |
| README 규칙 목록을 불릿 목록으로 | 표(`RULES.md` 와 같은 `\|` 행) | 표면 `readRulesMdBlock` 을 그대로 쓸 수 있다. 불릿이면 읽기 함수를 하나 더 둔다 — 둘 다 10줄 안이다 (§ 2) |

**Installation:** 없음.

## Package Legitimacy Audit

> 이 phase 는 외부 패키지를 설치하지 않는다. 검사 대상 없음.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| — | — | — | — | — | — | 설치하는 패키지 없음 |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```text
                  ┌────────────────────────────┐
  소유자가 고침 ──▶│ lib/base.yaml (규칙 81)     │◀──── RULES.md 켠 규칙 표 (이름 · 이유 · 건수)
                  │ lib/riverpod.yaml (plugin)  │
                  │ lib/codegen.yaml (exclude)  │        README.md
                  │ lib/recommended.yaml (묶음) │        ├ 표시 구역 woody:readme-rules (이름만)   ─┐
                  │ lib/analysis_options.yaml   │        ├ include 블록 (package:woody_lints/*.yaml) │ (d)~(g)
                  └──────────┬─────────────────┘        ├ 끄기 블록 (version: ^3.1.9)               │ 가 읽는 자리
                             │                           └ 설치 블록 (ref: v2.0.0)                   ─┘
                             ▼                                        ▲
   fvm dart run tool/verify.dart                                      │ pubspec.yaml version: 2.0.0-dev → "2.0.0"
   ├ 준비: SDK 확인(78) → CI 의 --update 거부(64) → pub get(69)        │
   ├ [1/10] lib/ 에 .dart 없음                                        │
   ├ [2/10] 조각 셋의 복사본 분석 ─── stripPlugins (WR-02 고침: 빈 줄로 바꿈, 줄 번호 보존)
   ├ [3/10] 배포 파일의 구성                                            │
   │   (a) 묶음 · 별칭은 include 만     (b) base.yaml ↔ 기반 세트 겹침    (c) RULES.md ↔ base.yaml
   │   (b′) base.yaml 밖 조각에 규칙 없음 (WR-11 B안)                    │
   │   (d) README 표시 구역 ↔ base.yaml  (e) README 의 package: 주소 ∈ lib/
   │   (f) README 코드 블록의 plugin 버전 == riverpod.yaml ── readShippedPluginConstraint (WR-02 고침)
   │   (g) README 코드 블록의 ref: vX.Y.Z == pubspec version 의 꼬리 뗀 값
   ├ [4/10] 연습용 프로젝트 옵션 파일 (version 토큰 치환 — 같은 reader)
   └ [5/10] ~ [10/10] 정답지 비교 (README 를 보지 않는다)
   종료 코드: 0 / 1 (단계 실패 — 문서 어긋남 포함) / 70 (읽을 수 없는 입력)
```

### Recommended Project Structure (이 phase 가 더하거나 고치는 파일)

```text
README.md                          # 전면 재작성 (§ 4) — 표시 구역 하나, 코드 블록은 fixture 의 모양
CHANGELOG.md                       # 2.0.0 의 두 칸 수정 (D-06 · D-07) + 1.1.0 ~ 1.2.5 복원 7항목 (§ 3)
lib/base.yaml                      # 1 ~ 12 · 15 · 108 ~ 112행 삭제, 머리 주석 2 ~ 4줄 (§ 5)
lib/riverpod.yaml                  # 1 ~ 8행 → 2 ~ 4줄 (WR-02 뒤에)
lib/codegen.yaml                   # 머리 주석 신설
lib/recommended.yaml, lib/analysis_options.yaml   # 지금 2줄 그대로거나 미세 수정
tool/verify.dart                   # stripPlugins · readShippedPluginConstraint · declaredRuleNames(shownAs) · [3/10] (b′)(d)~(g) · fragmentLineHint
example/README.md                  # 종료 코드 표 116행의 [3/10] 설명 덧붙임, 소절 "추가 실측 — … (05-xx)" M32 ~
.claude/CLAUDE.md                  # 71 · 181행
.planning/phases/01-…/01-REVIEW-DISPOSITION.md   # WR-05 fixed
.planning/phases/03-…/03-REVIEW-DISPOSITION.md   # WR-02 fixed
.planning/phases/04-…/04-REVIEW-DISPOSITION.md   # WR-11 · IN-14 fixed
```

### Pattern 1: 표시 구역 + 이름 비교 (D-01, `RULES.md` 의 선례 재사용)

**What:** `<!-- woody:<이름>:start -->` / `<!-- woody:<이름>:end -->` 사이의 이름을 모아 `lib/base.yaml` 의 `declaredRuleNames` 와 정렬해 견준다. 지금 `RULES.md` 의 네 구역 이름은 `enabled-rules` (9 ~ 93행) · `enabled-options` (99 ~ 103행) · `disabled-rules` (119 ~ 212행) · `measurements` (218 ~ 425행) `[VERIFIED: grep -n "woody:" RULES.md]`.
**When to use:** README 의 규칙 이름 목록 (d).
**Example:** § 2 의 코드.

### Pattern 2: 코드 블록(fenced block) 안의 값만 읽기 (D-02 (3) · (4))

**What:** README 에서 "복사해 쓰는 값" 은 ``` 로 감싼 블록 안에 있다. 산문은 옛 값을 인용할 수 있다 (예: "Dart 3.13 미만이면 `ref: v1.3.0` 에 머문다" — D-06 이 이 문장을 CHANGELOG 에 두고 README 가 링크로 받는다, D-18 의 "버전 올리기" 절도 1.3.0 → 2.0.0 을 말한다). 그래서 (3) · (4) 는 **코드 블록 안**의 `version:` · `riverpod_lint:` · `ref:` 줄만 읽고, (2) 의 주소는 파일 전체에서 읽는다 (옛 주소 별칭도 `lib/` 에 실재하므로 산문 인용이 걸리지 않는다).
**When to use:** (e) (f) (g).

### Pattern 3: 읽은 값이 0개면 실패 (헛통과 방지)

**What:** `checkRuleNames` 의 "규칙 0개면 실패" `[VERIFIED: tool/verify.dart:1087-1101]` 와 `readUpstreamRules` 의 "규칙 0개면 FormatException" `[VERIFIED: tool/verify.dart:1270-1274]` 을 따른다 — README 에서 주소 · plugin 버전 · `ref:` 를 하나도 읽지 못하면 "일치" 가 아니라 실패다 (표시 구역이 없으면 `compareBlock` 의 "구역이 없다" 블록과 같은 꼴).

### Anti-Patterns to Avoid

- **검사만 먼저 커밋:** 지금 README(81행에 `require_trailing_commas`, 표시 구역 없음)에서 (d) 가 바로 실패한다 — README 재작성과 같은 커밋 (CONTEXT Discretion 마지막 항목).
- **`stripPlugins` 를 "지우기" 로 두고 힌트 문장을 유지:** 섹션을 빈 줄로 바꾸면 줄 번호가 같아지므로 `fragmentLineHint` 170 ~ 172행의 "그 섹션 뒤에 적은 줄만 뺀 줄 수만큼 앞당겨진다" 가 거짓이 된다 `[VERIFIED: tool/verify.dart:169-172]`. 둘을 같은 커밋에서 고친다.
- **README 산문의 옛 값까지 비교:** (4) 를 파일 전체로 돌리면 "`ref: v1.3.0` 에 머문다" 류 문장이 걸린다 (Pattern 2).
- **YAML 머리 주석에 사용법 · 문제 해결을 다시 적기:** D-08. 검사가 지키지 않는 자리다.
- **역사 기록(M20 ~ M31, CHANGELOG 의 `[3/10]`)의 번호를 고치기:** 그때의 실행 결과다. 단계를 더한다면 "그때는 10단계" 각주로 남기고 고치지 않는다 (§ 2).
- **`.claude/CLAUDE.md` 의 낡은 절을 손으로 전부 고치기:** D-09 — 두 줄만.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| README 규칙 이름 읽기 | 새 Markdown 파서 | `readRulesMdBlock` (표) 또는 그 함수의 10줄 변형 (불릿) `[VERIFIED: tool/verify.dart:1302-1327]` | 마커 · 첫 칸 backtick · malformed 처리까지 이미 있다 |
| 규칙 이름 집합 비교와 `+`/`-` 출력 | 새 diff | `compareBlock` 의 `subtractLines` 꼴 `[VERIFIED: tool/verify.dart:1386-1418]` | M20 ~ M31 의 기호와 같은 화면이 나온다 |
| plugin 선언 읽기 | YAML 라이브러리 | 줄 단위 정규식 (§ 1 고친 판) | 의존성 0 유지, 입력 10가지 확인 |
| 주석 · 빈 줄 뺀 줄 목록 | 새 함수 | `significantLines` `[VERIFIED: tool/verify.dart:1218-1225]` | (a) · `[4/10]` 과 같은 기준 |
| 비공개 정보 점검 | 새 스크립트 | 04-RESEARCH § 8 의 grep (1) · (2) 를 대상 파일만 바꿔 재사용 (§ 6) | 패턴이 이미 검증됐다 |

**Key insight:** `tool/verify.dart` 에는 이 phase 가 필요로 하는 조각(마커 읽기, 집합 비교, 주석 제거, 0개면 실패, FormatException → 70)이 전부 있다. 새로 쓰는 것은 README 의 세 값을 뽑는 정규식 셋과 그것을 `[3/10]` 에 잇는 40 ~ 60줄이다.

## 1. WR-02 — 재현 · 고칠 범위 · 지워 보기 (planner 질문 1)

### 지금 코드

- `stripPlugins` `[VERIFIED: tool/verify.dart:793-802]` — 한 정규식 `^plugins:\n(?:[ \t]+.*\n)+` 로 섹션을 **지우고**, 남은 `^plugins:` 가 있으면 `FormatException('$shownAs 의 \`plugins:\` 섹션을 빼지 못했다')`.
- `readShippedPluginConstraint` `[VERIFIED: tool/verify.dart:1191-1203]` — `^\s+riverpod_lint:\s*(\S+)\s*$` (multiLine) 의 첫 그룹. 없으면 `FormatException('lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다')`.
- 부르는 자리: `stripPlugins` 는 `[2/10]` `checkRuleNames` 1007행, `readShippedPluginConstraint` 는 `[4/10]` `checkFixtureOptions` 1151행 `[VERIFIED: grep]`. 둘 다 `main` 의 `on FormatException` 으로 가서 stderr 한 줄 + 종료 코드 70 `[VERIFIED: tool/verify.dart:1847-1849]`.
- 지금 `lib/riverpod.yaml` 은 10행, 9 ~ 10행이 `plugins:` / `  riverpod_lint: ^3.1.9`, 마지막 바이트는 `\n` `[VERIFIED: cat -n · od -c, 2026-10-13]`.

### 재현 (저장소 복제본, Flutter 3.47.5 / Dart 3.13.4, 2026-10-13) `[VERIFIED: 실행]`

| 입력 (복제본의 `lib/riverpod.yaml`) | 결과 | stdout | stderr 마지막 줄 | 종료 코드 |
|---|---|---|---|---|
| 10행을 `  riverpod_lint: ^3.1.9 # 하한` 으로 | 준비 단계는 지나고 단계 줄은 하나도 안 찍힘 | 0 바이트 | `파일 모양이 예상과 다르다: lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다` | 70 |
| 마지막 줄바꿈 삭제 (`printf '%s'`) | 같음 | 0 바이트 | `파일 모양이 예상과 다르다: lib/riverpod.yaml 의 \`plugins:\` 섹션을 빼지 못했다` | 70 |

03-REVIEW WR-02 의 표와 글자 그대로 같다. 두 변경 모두 YAML 로는 올바르고 analyzer 의 동작도 같다 — 거짓 실패다.

함수 단위 확인 (같은 복제본의 `tool/verify.dart` 를 import 한 probe, 입력 10가지) `[VERIFIED: 실행]`:

| 입력 | 지금 `stripPlugins` | 지금 `readShippedPluginConstraint` | 고친 판 둘 |
|---|---|---|---|
| 원본 | ok | `^3.1.9` | ok · `^3.1.9` |
| plugin 줄 끝 주석 | ok | **FormatException** | ok · `^3.1.9` |
| 마지막 줄바꿈 없음 | **FormatException** | `^3.1.9` | ok · `^3.1.9` |
| `plugins: # 주석` | **FormatException** | `^3.1.9` | ok |
| `plugins: ` (뒤 공백) | **FormatException** | `^3.1.9` | ok |
| 섹션 안 빈 줄 | **FormatException** | `^3.1.9` | ok |
| 섹션 안 0열 주석 | **FormatException** | `^3.1.9` | ok |
| CRLF | **FormatException** | `^3.1.9` | ok |
| 맵 형식 (`riverpod_lint:` / `    version: ^3.1.9`) | ok | **FormatException** | ok · `^3.1.9` |
| 섹션 뒤 0열 꼬리 주석 | ok | `^3.1.9` | ok |

03-REVIEW 가 "추론" 으로 남긴 넷(`plugins:` 뒤 주석 · 공백, 섹션 안 빈 줄 · 0열 주석, CRLF, 맵 형식)이 모두 실제로 멈춘다.

### 고친 판이 받을 것 · 거부할 것

- **받는다:** 위 10가지 전부. `stripPlugins` 는 줄 단위로 걷되 섹션의 줄을 **빈 줄로 바꾼다** (03-REVIEW 의 제안 그대로) — 복사본의 줄 번호가 원본과 같아진다. `readShippedPluginConstraint` 는 `^[ \t]+riverpod_lint:[ \t]*([^\s#]+)[ \t]*(?:#.*)?$` 와, `riverpod_lint:` 만 있는 줄 다음의 첫 비주석 줄 `^[ \t]+version:[ \t]*([^\s#]+)` 를 받는다 (끄는 설정의 모양 — `fixtures/overrides` 가 이 꼴이다 `[VERIFIED: fixtures/overrides/analysis_options.yaml:8-11]` `version: ^3.1.9`).
- **거부한다 (여전히 70):** `plugins:` 가 있는데 빼지 못한 경우 (예: 들여쓰기가 탭 · 공백 아닌 글자로 시작), `riverpod_lint:` 선언이 없는 파일, 맵 형식인데 `version:` 이 없는 경우. "선언을 찾지 못했다" 문구는 유지.
- **함께 고칠 것:** `fragmentLineHint` 170 ~ 172행의 둘째 문장을 "복사본의 줄 번호는 원본과 같다 (`plugins:` 섹션은 빈 줄로 바꿔 복사한다)" 로. `stripPlugins` 문서 주석 785 ~ 792행의 "지운다" 를 "빈 줄로 바꾼다" 로. `readShippedPluginConstraint` 문서 주석 1187 ~ 1190행에 받는 꼴(줄 끝 주석 · 맵 형식)을 적는다.
- `readShippedPluginConstraint` 는 `[4/10]` 에서만 쓰이지만 (f) 도 같은 값을 쓴다 — 함수 하나를 둘이 부른다.

### 지워 보기 (M 번호 — 지금 M31 까지 `[VERIFIED: example/README.md:301]`, 다음은 **M32**)

WR-02 는 "거짓 실패가 사라졌다" 와 "그래도 reader 가 헛통과가 아니다" 둘을 보인다.

| # | 변경 | 기대 | 뜻 |
|---|---|---|---|
| M32 | `lib/riverpod.yaml` 10행 끝에 ` # 하한` | **열 단계 통과**, 종료 코드 0 (고치기 전 70) | 줄 끝 주석을 받는다 |
| M33 | 마지막 줄바꿈 삭제 | 열 단계 통과, 0 (고치기 전 70) | 줄바꿈 없음을 받는다 |
| M34 | 10행을 삭제 (`plugins:` 만 남음) | 단계를 돌리지 못함, stderr `riverpod_lint 선언을 찾지 못했다`, **70** | reader 가 no-op 이 아니다 — 없는 선언을 만들어 내지 않는다 |
| (선택) | `lib/riverpod.yaml` 끝에 deprecated 규칙 `linter: rules: - unnecessary_await_in_return` | `[2/10]` 실패, 진단 줄의 행 번호가 **원본과 같은 13행** (Phase 3 기록은 11행 — STATE "riverpod/analysis_options.yaml:11 로(원본 13행 …)") | 빈 줄 치환으로 줄 번호가 보존된다는 확인. WR-11 B안의 (b′) 도 함께 걸리므로 `[3/10]` 도 실패한다 |

기록 형식은 `example/README.md` 의 "추가 실측 — … (04-13)" 소절과 같다 (실측 조건 줄, 명령, 표 `| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |`, 읽는 법, 되돌림 확인) `[VERIFIED: example/README.md:289-310]`.

## 2. WR-11 · IN-14 · VERIFY-06 — `[3/10]` 의 설계 (planner 질문 2)

### WR-11 두 안의 코드 결과

| | A안: 다섯 YAML 전체에서 규칙을 모아 비교 | B안: "규칙은 `lib/base.yaml` 에만" 을 검사로 |
|---|---|---|
| (b) · (c) · (d) 의 비교 대상 | `declaredRuleNames` 를 `codegen.yaml` · `riverpod.yaml` 에도 돌려 합친 목록 (묶음 · 별칭은 (a) 가 include 만으로 막으니 제외) | 지금처럼 `rulesFile` 하나. 그 앞에 (b′) "다른 두 조각에 규칙 0개" 확인 |
| 코드 | 합집합 만들기 + 중복 처리 + 기호 `(base.yaml 에만)` 을 `(배포 YAML 에만)` 으로 + `rulesFile` 상수의 뜻 변경 + 문서 주석 다섯 곳 | (b) 앞 7줄 (04-REVIEW 의 코드 그대로) + `declaredRuleNames` 에 `shownAs` (IN-14) |
| `RULES.md` 머리 문장 "`lib/base.yaml` 의 `linter: rules:` 에 적힌 규칙" `[VERIFIED: RULES.md:7]` | 고쳐야 한다 | 그대로 |
| `includeOnlyFiles` 문서 "규칙은 `lib/base.yaml` 에만 적는다" `[VERIFIED: tool/verify.dart:120]`, (a) 실패 문구 1365행, 03-REVIEW WR-01 의 관례 | 관례가 사라진다 | 관례를 검사로 굳힌다 |
| 규칙이 `codegen.yaml` 에 적혔을 때 | 통과 (사용 프로젝트는 받는다 — 04-REVIEW 재현) → "어느 파일에 적어도 된다" 가 된다 | **실패** — "규칙은 `lib/base.yaml` 에만 적는다" 안내 |
| README · M 기록의 `(base.yaml 에만)` 기호 | 바뀐다 | 그대로 |

**권고: B안.** 04-REVIEW WR-11 의 Fix 코드가 그대로 쓰인다 `[VERIFIED: 04-REVIEW.md:178-189]`:

```dart
// (b) 앞 — rulesFile 밖의 조각은 규칙을 담지 않는다 (03-REVIEW.md WR-01 의 관례를 검사로, 04-REVIEW.md WR-11)
for (final target in ruleCheckTargets.where((t) => t != rulesFile)) {
  final extra = declaredRuleNames(
    File('$repoRoot/$target').readAsStringSync(),
    shownAs: target,                        // IN-14
  );
  if (extra.isNotEmpty) {
    addBlock([
      '`$target` 에 규칙이 있다 (${extra.length}) — 규칙은 `$rulesFile` 에만 적는다.',
      ...extra.map((r) => '  $r'),
    ]);
  }
}
```

`riverpod.yaml` 은 `plugins:` 를 담고 있지만 `declaredRuleNames` 는 `linter:` 블록만 보므로 그대로 넘겨도 된다 (`^\S` 줄이 블록을 닫는다 `[VERIFIED: tool/verify.dart:901-905]`).

### IN-14 — `declaredRuleNames(String options, {required String shownAs})`

- 문구: `'$shownAs 의 \`linter:\` 블록의 ${i + 1}행을 읽지 못했다 — …'` (912 ~ 916행). 참조는 `04-REVIEW.md WR-10` 대신 남는 기록(`04-REVIEW-DISPOSITION.md WR-10`) 으로.
- 부르는 자리 셋: `countDeclaredRules(rulesCopy)` 1089행 → `shownAs: rulesFile` (base.yaml 에 `plugins:` 가 없어 복사본 줄 번호 = 원본, § 1 의 빈 줄 치환 뒤에는 어느 조각이든 같다), `declaredRuleNames(baseText)` 1371행 → `shownAs: rulesFile`, 새 (b′). `countDeclaredRules` 도 같은 인자를 받는다.
- 문서 주석 867 ~ 870 · 977 ~ 983행에 "읽지 못하는 줄이 있으면 `FormatException` (main 이 70)" 을 더한다.

### D-02 (1) ~ (4) 의 읽는 자리와 방법

| 검사 | README 에서 읽는 자리 | 방법 | 기준값 | 실패 문구 (안) | 종료 코드 |
|---|---|---|---|---|---|
| (d) 규칙 이름 | 표시 구역 `woody:readme-rules` (이름은 Discretion — `RULES.md` 의 `enabled-rules` 와 다르게 두어 grep 이 갈린다) | 구역 안 **불릿 줄**(`- ` 로 시작) 의 backtick 이름 `` `[a-z0-9_]+` `` 를 모두 모은다. 표로 쓰면 `readRulesMdBlock` 그대로 | `declaredRuleNames(base.yaml)` 정렬 비교 (c 와 같은 `subtractLines`) | `` `README.md` 의 규칙 목록과 `lib/base.yaml` 의 규칙 목록이 다르다. `` + `  + x  (base.yaml 에만)` / `  - x  (README.md 에만)` + `` `README.md` 의 목록 · `RULES.md` 의 표 · `lib/base.yaml` 을 같은 커밋에서 고친다. `` | 1 (구역 없음도 1 — `compareBlock` 의 "구역이 없다" 꼴) |
| (e) 프리셋 주소 | 파일 전체 | `RegExp(r'package:woody_lints/([A-Za-z0-9_]+\.yaml)')` 의 모든 그룹 | 각 이름 ∈ `expectedLibYamls` `[VERIFIED: tool/verify.dart:157-163]` `{analysis_options.yaml, base.yaml, codegen.yaml, recommended.yaml, riverpod.yaml}`; 0개면 실패 | `` `README.md` 가 가리키는 프리셋 주소가 `lib/` 에 없다 (N): `` + `  package:woody_lints/x.yaml` | 1 |
| (f) plugin 버전 | 코드 블록(``` 사이) 안의 `version:` 줄과 `riverpod_lint: <값>` 줄 | 블록 안 줄에 `^\s*(?:version|riverpod_lint):\s*(\^?\d+\.\d+\.\d+)` 의 모든 그룹 | 전부 == `readShippedPluginConstraint` (지금 `^3.1.9`); 0개면 실패 | `` `README.md` 의 코드 블록에 적힌 riverpod_lint 버전이 `lib/riverpod.yaml` 의 선언(^3.1.9)과 다르다: `` + `  ^3.1.3` | 1 |
| (g) `ref:` | 코드 블록 안의 `ref: v…` 줄 | `^\s*ref:\s*v(\d+\.\d+\.\d+)\s*$`; `ref: main` 줄은 세지 않는다 | 전부 == `pubspec.yaml` `version:` 의 `^(\d+\.\d+\.\d+)` (지금 `2.0.0-dev` → `2.0.0` `[VERIFIED: pubspec.yaml:3]`); `ref: v` 가 0개면 실패 | `` `README.md` 의 `ref: vX.Y.Z` 예시가 `pubspec.yaml` 의 version (2.0.0) 과 다르다: `` + `  ref: v1.3.0` | 1 |
| 읽을 수 없는 입력 | `pubspec.yaml` 에 `version:` 줄이 없거나 꼴이 아님, `README.md` 없음 | `FormatException` | — | `파일 모양이 예상과 다르다: pubspec.yaml 에서 version: 을 읽지 못했다` | 70 (WR-10 선례) |

- `-dev` 떼기: Dart 의 버전은 `major.minor.patch` 뒤에 `-prerelease` · `+build` 가 붙는다 — `^(\d+)\.(\d+)\.(\d+)` 앞머리만 취하면 `2.0.0-dev` · `2.0.0+1` · `2.0.0` 이 모두 `2.0.0` 이다 `[ASSUMED — semver 문법은 훈련 지식, 이 저장소의 값은 2.0.0-dev 하나]`. Phase 6 이 `-dev` 를 떼도 통과하고(CONTEXT Integration Points), 2.1.0 으로 올리면 README 를 고쳐야 통과한다 — 의도한 동작.
- 코드 블록 판정: ``` 로 시작하는 줄에서 토글. README 안의 모든 블록을 본다 (설치 · 프리셋 넷 · 끄기 둘 · 생성 파일 제외 · 버전 올리기).
- (f) 가 산문의 "`^3.1.3` → `^3.1.9`" 같은 문장에 걸리지 않는 까닭이 Pattern 2 다. 역으로 끄기 예시 블록의 `version: ^3.1.9` 와 설치 안내가 적을 "`riverpod_lint` 는 `^3.1.9`" 는 블록 안에 두어야 검사에 든다 — README 를 쓸 때의 규칙으로 planner 가 적어 둔다.

### `[3/10]` 안에 넣을지, 새 단계로 둘지

**권고: `[3/10]` 안에 (b′) · (d) ~ (g).** 라벨 `배포 파일의 구성` `[VERIFIED: tool/verify.dart:115]` 은 그대로 두고, `checkShippedComposition` 문서 주석(1329 ~ 1338행)과 `example/README.md` 116행의 `[3/10]` 설명에 README 검사 넷을 덧붙인다. `RULES.md` 3행의 "배포 파일의 구성" 단계 언급도 그대로 맞다.

단계를 하나 더 두면 (예: `[4/11] README 일치`) 고치거나 각주를 달아야 하는 자리 — `git grep -n -E '\[[0-9]+/10\]|10개 중|열 개|10단계|단계 10'` (`.planning` · `tool/measurements` 제외) `[VERIFIED: 2026-10-13]`:

| 파일 | 자리 | 성격 |
|---|---|---|
| `example/README.md` | 69행 (`[5/10]` ~ `[10/10]`), 81 · 82행 (`[4/10]`), 109행 (`단계 10개`), 116행 (단계 설명 전체), 243 · 274 · 293행 (`단계 10개`), 247 ~ 261행 M20 ~ M25 와 읽는 법, 268 · 287 · 310행 (`10개 중 10개`), 278 ~ 285행 M26, 297 ~ 308행 M27 ~ M31 | 69 · 81 · 82 · 109 · 116 은 현재 설명 → 고친다. 나머지는 **그때의 실행 기록** → 고치지 않고 소절 머리에 "당시 단계 10개" 를 적는다 |
| `CHANGELOG.md` | 96행 (`[3/10]` 배포 파일의 구성 단계를 더함), 99행 (검증 명령 `[3/10]` 이 …) | 2.0.0 항목 — D-07 이 이 줄들을 "저장소 안쪽" 한 줄로 합치므로 번호가 사라진다 |
| `tool/verify.dart` | `[N/N]` 표기 (`[3/N]`, `[4/N]`, `[5/N] ~ [N/N]`) | 번호가 박히지 않아 그대로. 단, `[1/4]` · `[2/4]` 라벨 문서(757 · 165 · 168행)는 Phase 2 때의 표기가 남은 것 |
| `.github/workflows/verify.yml` | 단계 수 언급 없음 `[VERIFIED: 읽음]` | — |
| `.planning/` | 다수 | 역사 — 고치지 않는다 |

새 단계로 두는 쪽을 planner 가 고르면 라벨은 `README 일치`, `fixtures` 표 앞의 고정 단계 셋 → 넷이므로 `formatStepLine` 의 total 은 `results.length` 로 자동이다 `[VERIFIED: tool/verify.dart:1810-1812]`.

### 지워 보기 (M35 ~ M40 안)

| # | 변경 | 기대 | 항목 |
|---|---|---|---|
| M35 | `lib/codegen.yaml` 끝에 `linter:` / `  rules:` / `    - avoid_print # 기반 세트와 겹침` / `    - prefer_mixin # RULES.md 에 없음` (04-REVIEW WR-11 의 재현 입력 — 고치기 전 rc 0 `[VERIFIED: 04-REVIEW.md:164-167]`) | `[3/10]` 만 실패, `` `lib/codegen.yaml` 에 규칙이 있다 (2) ``, 1 | WR-11 (b′) |
| M36 | `lib/codegen.yaml` 끝에 `linter:` / `  rules:` / `    avoid_print: true` (읽지 못하는 꼴) | stderr `lib/codegen.yaml 의 \`linter:\` 블록의 N행을 읽지 못했다`, **70** — 파일 이름이 문구에 있다 | IN-14 |
| M37 | README 표시 구역에서 이름 하나 삭제 (예: `prefer_single_quotes`) | `[3/10]` 만 실패, `+ prefer_single_quotes  (base.yaml 에만)`, 1 | VERIFY-06 (d) |
| M38 | README 의 한 블록에서 `recommended.yaml` → `recomended.yaml` | `[3/10]` 실패, `package:woody_lints/recomended.yaml`, 1 | (e) |
| M39 | README 끄기 블록의 `version: ^3.1.9` → `^3.1.3` | `[3/10]` 실패, 1 | (f) |
| M40 | README 설치 블록의 `ref: v2.0.0` → `ref: v1.3.0` | `[3/10]` 실패, 1 | (g) |
| (선택) | README 표시 구역의 start 마커 삭제 | `[3/10]` 실패 "구역이 없다", 1 | 헛통과 아님 |

M37 은 Phase 4 M21 의 README 판이고 기호는 `+` 다 (M21 읽는 법 — 표에서 지우면 `base.yaml 에만` 쪽 `[VERIFIED: example/README.md:259]`).

## 3. CHANGELOG — 복원 재료와 2.0.0 의 두 칸 (planner 질문 3)

### 버전 커밋과 내용 커밋 (전부 `git show` 로 다시 읽음, 2026-10-13) `[VERIFIED: git show · git log -- pubspec.yaml]`

`90a2736` (1.3.0) 까지의 커밋은 18개이고 `pubspec.yaml` 의 `version:` 이 바뀐 커밋은 아래 9개다 (`126aa43` 과 그 앞은 1.0.0).

| 버전 | 날짜 | 버전 커밋 | 같은 버전의 다른 커밋 | diff 로 확인한 변경 |
|---|---|---|---|---|
| 1.0.0 | 2025-12-22 | `d98b45a` (초기) | `d525664` (`repository:` 추가), `9a6627e` (README 오타) | `lib/analysis_options.yaml`: `include: package:lints/recommended.yaml`, 규칙 12개 (성능 3 · 가독성 5 · 버그 방지 4 — 1.3.0 과 같은 이름), `analyzer:` 는 템플릿 주석. `pubspec.yaml`: `sdk: ^3.10.4`, `dev_dependencies: lints: ^6.0.0` |
| 1.1.0 | 2025-12-22 | `2249a0b` (숫자만) | `126aa43` (내용, 같은 날 — `lib/analysis_options.yaml` 1줄 · `pubspec.yaml` 1줄) | `include:` 를 `package:lints/recommended.yaml` → `package:flutter_lints/flutter.yaml`, `dev_dependencies` 의 `lints: ^6.0.0` → `flutter_lints: ^6.0.0` |
| 1.2.0 | 2025-12-24 | `ec66e3f` | (`423936c` README, 같은 날) | `formatter:` / `  trailing_commas: preserve` 2줄 추가 (include 와 `linter:` 사이). README 에 "포맷터" 절 |
| 1.2.1 | 2025-12-30 | `21c5689` (숫자만, 본문 "README.md 수정") | `9950fd1` README (설치 확인 방법 추가, 포맷터 절을 목록으로) | **설정 변경 없음** |
| 1.2.2 | 2026-01-03 | `31c8cb1` (숫자만, 본문 "README.md 수정으로 마이너 버전 올림") | `7b7455e` README (`dev_dependencies` 블록 분리, "복사해서 사용하기 좋게") | **설정 변경 없음** |
| 1.2.3 | 2026-01-28 | `9451f6b` | (`1693a97` `.gitignore` 의 `.DS_Store`, 같은 날) | `- slash_for_doc_comments # 문서 주석 슬래시 사용 통일` 추가 (가독성). README 1줄 |
| 1.2.4 | 2026-02-27 | `212365d` | (`a97fd20` 2026-01-30 "fvm 적용" — `.fvmrc` 3.38.9 · `.gitignore` · `.vscode/settings.json` 신설) | `- public_member_api_docs # 공개 API에 대한 문서화 권장` 추가; `analyzer:` 블록 신설 — **`plugins: - riverpod_lint` (옛 방식)**, `errors: invalid_annotation_target: ignore`, `exclude: '**/*.freezed.dart' · '**/*.g.dart'`; 템플릿 `# analyzer:` 주석 3줄 삭제; 머리 주석과 `include:` 사이 빈 줄 삭제. 저장소 안쪽: `.fvmrc` 3.38.9 → 3.41.2, `.vscode/settings.json` 경로 |
| 1.2.5 | 2026-03-23 | `dbcd20b` | — | `formatter:` 2줄, `- require_trailing_commas`, `- public_member_api_docs` 를 주석 처리 (삭제 아님) |
| 1.3.0 | 2026-09-20 | `90a2736` | — | (이미 CHANGELOG 에 있음) `analyzer: plugins: - riverpod_lint` → 최상위 `plugins: riverpod_lint: ^3.1.3` + 주석 8줄, `flutter_lints` 를 `dependencies` 로, 루트 `analysis_options.yaml` 신설 |

**CONTEXT `<specifics>` 표와 다른 곳:**

1. **1.2.4 에 `analyzer: plugins: - riverpod_lint` (옛 방식 선언) 추가가 빠졌다.** 1.3.0 항목의 "옛 `analyzer: plugins: - riverpod_lint` 선언은 riverpod_lint 3.x 에서 아무것도 로드하지 않아" 가 가리키는 선언이 여기서 생겼다. 복원 항목에 적을 때 "로드되지 않았다" 는 1.3.0 항목이 이미 밝혔으므로 "옛 방식 `analyzer: plugins:` 로 `riverpod_lint` 선언 추가 (1.3.0 항목 참고 — 이 방식은 로드되지 않았다)" 꼴로.
2. 1.2.4 는 `.vscode/settings.json` 도 바꿨다 (표는 `.fvmrc` 만). 둘 다 저장소 안쪽 — "사용하는 프로젝트에는 영향 없음" 으로 한 줄.
3. 1.1.0 의 "의존성 `lints` → `flutter_lints`" 는 맞지만 그때 자리는 `dev_dependencies` 다 (1.3.0 이 `dependencies` 로 옮겼다). 1.0.0 의 기반 세트가 `package:lints/recommended.yaml` 이었다는 것도 1.1.0 항목에 적을 수 있다.
4. 1.2.2 의 버전 커밋 본문은 "README.md 수정으로 마이너 버전 올림" 이다 — D-05 는 커밋 메시지를 옮기지 않으므로 그대로 "설정 변경 없음 (같은 날 README 수정)" 으로. 날짜는 모두 커밋 날짜(`%ad`, 한국 시간)와 같다.

### 옛 불릿 형식 (1.3.0 항목) `[VERIFIED: CHANGELOG.md:187-193]`

```markdown
## 1.3.0

- riverpod_lint 를 최상위 `plugins:` (analysis_server_plugin) 방식으로 전환.
  - 옛 `analyzer: plugins: - riverpod_lint` 선언은 … → 이번 버전부터 riverpod_lint 규칙이 처음으로 켜진다.
  - Dart 3.13 (Flutter 3.47) 의 `included_file_warning` (legacy plugin deprecated) 해소.
- `flutter_lints` 를 `dev_dependencies` → `dependencies` 로 이동. …
- 저장소 자체 분석용 루트 `analysis_options.yaml` 추가 — … 사용하는 프로젝트에는 영향 없음.
```

제목은 `## 1.3.0` (날짜 없음). 날짜 · 커밋을 둘 자리는 Discretion 이다 — `VERSIONING.md` 실제 사례의 꼴 `` `1.2.3` (2026-01-28, `9451f6b`) `` `[VERIFIED: VERSIONING.md:74-75]` 과 맞추려면 첫 줄 한 줄 `2026-01-28, 커밋 \`9451f6b\` (tag 없음)` 을 두고 그 아래 불릿. 제목에 ` - 날짜` 를 붙이는 2.0.0 꼴은 쓰지 않는다 — "1.3.0 · 1.0.0 은 옛 형식 그대로" 와 나란히 놓이고, REL-03 은 최상단만 읽어 어느 쪽이든 영향이 없다 `[VERIFIED: VERSIONING.md:82]`. 1.2.3 · 1.2.4 의 "당시 patch 로 냈다 → 지금 정책이면 minor" 는 `VERSIONING.md` 74 ~ 75행이 이미 적고 있으니 복원 항목은 "(당시 patch — `VERSIONING.md` 실제 사례 참고)" 한 토막이면 된다.

### 2.0.0 항목 (DOCS-07 · DOCS-09 는 이미 충족, 확인만)

- 구조 `[VERIFIED: CHANGELOG.md:1-185]`: 1행 `## 2.0.0 - 미출시`, 3행 `지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)`, 5 ~ 8행 `### 올리기 전에` (두 줄), 10 ~ 86행 `### 추가한 규칙` (75 불릿), 88 ~ 99행 `### 그 밖의 변경` (10 불릿), 101 ~ 185행 `### 새로 생기는 경고` (헤더 `| 규칙 | 강도 | 실측 | dart fix |`, 규칙 행 74, 실측 줄 `실측: flutter_starter_kit (Dart 파일 474개), Flutter 3.47.5, 2026-10-13`, 설명 두 문단).
- D-07 의 "저장소 안쪽" 으로 합칠 불릿: 90행(연습 프로젝트 · 검증 명령 · CI), 93행(루트 분석 설정), 96행의 뒷부분(`[3/10]` 단계 추가), 97행(측정 도구 · 회차 기록), 99행(측정 도구 · 검증 명령 결함 수정). 남길 불릿: 91(프리셋 분리) · 92(별칭) · 94(plugin 하한) · 95(겹침 6 · 주석 3 삭제) · 96 앞부분(`RULES.md` 추가 — 따로 한 줄) · 98(사유 주석 셋). 이 phase 의 README · YAML 주석 정리를 새 불릿으로.
- D-06 의 새 `### 올리기 전에`: 지금 두 줄 + "받는 때" 한 문단 (`ref: main` 은 `main` 병합 뒤 `pub upgrade woody_lints` 때 — spike 015 pub-2 · pub-4 `[VERIFIED: git-dependency-and-upgrade.md § 3]`) + README "버전 올리기" 절 링크.
- DOCS-09 확인 명령 (수치는 건드리지 않는다): `sed -n '/^### 새로 생기는 경고/,/^## 1.3.0/p' CHANGELOG.md | grep -c '^| `'` = 74, `grep -c '^- `' <(sed -n '/^### 추가한 규칙/,/^### 그 밖의/p' CHANGELOG.md)` = 75 (`sort_pub_dependencies` 가 추가 75 · 표 74 인 것은 04-12 의 결과 — 표 163행에 `재지 않음` 으로 있다 `[VERIFIED: CHANGELOG.md:163]`; 75 vs 74 의 차이는 planner 가 04-09 · 04-12 SUMMARY 로 한 번 확인한다 `[ASSUMED — 이 세션은 두 수를 셌을 뿐 차이의 원인 커밋을 읽지 않았다]`).
  - **정정 (계획 단계, 2026-10-14 셈):** HEAD `fb6386a` 의 CHANGELOG 에서 두 명령은 **둘 다 75** 다 — `fb6386a` (04-12) 가 `sort_pub_dependencies` 행을 표에 `재지 않음` 으로 더해 표의 규칙 행이 74 → 75 가 됐다. 위의 "표 74" 와 이 문서의 다른 74 (D-17 인용 · phase_requirements · Validation Architecture 의 DOCS-09 행) 는 그 전의 값이다. 계획(05-04 Task 2)은 수를 박지 않고 "`### 추가한 규칙` 불릿 수 == 표의 규칙 행 수" 와 `fb6386a` 와의 절 diff 로 단언한다. A2 도 이것으로 해소.

## 4. README 내용 목록 — 사실 · 출처 · 단정 여부 (planner 질문 4)

### 지울 줄 (지금 README 95행) `[VERIFIED: README.md 전문]`

| 행 | 내용 | 처리 |
|---|---|---|
| 1 ~ 12 | 템플릿 HTML 주석 (`<!-- This README describes the package …`) | 삭제 (DOCS-10) |
| 14 | "엄선된 최적의 린트 규칙 세트" 한 줄 | 한두 문장 소개로 교체 (D-12) |
| 16 ~ 21 | `## 핵심가치` (성능 — "불필요한 리빌드를 방지") | 삭제 (D-12, lints#205) |
| 25 ~ 43 | `ref: main` 설치 블록 둘 | `ref: v2.0.0` 하나로 (D-10) |
| 47 ~ 54 | `flutter pub get` / "혹은 업그레이드 `flutter pub upgrade woody_lints`" | `pub upgrade` 는 `ref: main` 쪽 절로 옮긴다 — tag 사용자에게 `pub upgrade` 를 안내하지 않는다 (spike 015) |
| 56 ~ 61 | 옛 주소 include (`# include: package:flutter_lints/flutter.yaml` 주석 포함) | 정식 이름으로, 옛 주소는 "예전 이름" |
| 63 ~ 68 | 설치 확인 (`pubspec.lock` 에 `woody_lints`) | 유지 가능 — 사실이다 (lock 에 `source: git` · `resolved-ref` 항목 `[VERIFIED: git-dependency-and-upgrade.md § 1]`) |
| 70 ~ 95 | 포함된 규칙 목록 12개 + 포맷터 + plugin | 표시 구역 81개 이름으로 교체. **불일치 2건** — 81행 `require_trailing_commas` (1.2.5 에서 주석 처리, 2.0.0 에서 삭제), 91 ~ 92행 `formatter: trailing_commas` (같음). `analyzer:` (`codegen.yaml`) 미기재 |
| 95 | plugin 문단 (plugin 캐시 · 재시작 · `flutter analyze` 실측) | 문제 해결 절로 옮긴다 (D-08) |

### 절마다의 사실

표기: **단정** = fixture 정답지나 spike 실행이 받친다 / **출처와 함께** = 읽은 것 · 추론 · SDK 조건부.

| 절 | 사실 | 근거 | 쓰는 법 |
|---|---|---|---|
| 소개 | 규칙 81개 (성능 10 · 가독성 및 스타일 44 · 버그 방지 25 · strict 2) `[VERIFIED: grep -c '^    - ' lib/base.yaml = 81; 분류별 awk]`, 기반 세트 `flutter_lints` 6.0.0 / `lints` 6.1.0 | `lib/base.yaml`, STATE | 단정. 수는 README 에 박지 말고 "분류별 이름은 아래, 이유 · 건수는 `RULES.md`" |
| 설치 | `dev_dependencies` 아래 `git: url: https://github.com/woodkill/woody_lints.git` / `ref: v2.0.0`, `flutter pub get` | `pubspec.yaml` 8행 `repository:` `[VERIFIED]`, D-10 · D-15, `example/pubspec.yaml` 이 `dev_dependencies` 자리 | 단정. `v2.0.0` 은 Phase 6 의 tag — "아직 없음" 을 적지 않는다 (검사 (g) 가 pubspec 과 묶는다) |
| 설치 — 명령 메모 | 실측은 `dart pub` 로 했다, `flutter pub get` 은 옵션 파일에 `build/**` · 플랫폼 폴더 제외를 덧붙인다 (Flutter 3.47.5, 한 번만, 이미 있으면 안 함) | `example-project-and-expected-file.md` § Constraints `[VERIFIED: 읽음]`, spike 004 | 출처와 함께 (D-03). flutter#191151 은 "병합 여부 확인 안 함" |
| 요구 SDK | Dart 3.13 이상 (Flutter 3.47 이상). 미만이면 `pub get` 이 SDK 불일치로 실패 | `pubspec.yaml` `sdk: ^3.13.0` `[VERIFIED]`, BASE-02 | 단정 |
| 프리셋 2 × 2 표 | Riverpod × 코드 생성 → `recommended.yaml` / `base.yaml` + `riverpod.yaml` / `base.yaml` + `codegen.yaml` / `base.yaml` | 03-CONTEXT D-03, `example/README.md` 56 ~ 66행의 같은 표 `[VERIFIED]` | 단정 |
| include 블록 넷 | 아래 인용 — fixture 옵션 파일 글자 그대로 | `fixtures/recommended` · `base_only` · `base_riverpod` · `base_codegen` 의 `analysis_options.yaml` `[VERIFIED: 읽음]` | 단정. 옛 주소 `include: package:woody_lints/analysis_options.yaml` 은 `example/` 의 것 — "예전 이름, 같은 구성" 한 줄 |
| 각 조합이 받는 것 | 기본만: `riverpod_lint` 진단 없음, `invalid_annotation_target` 이 warning 으로 나옴(`exit 2`), 생성 파일의 규칙 진단 나옴; 기본 + codegen: `exit 0`; 기본 + Riverpod: plugin 돌고 codegen 설정 없음 | 정답지 다섯 (`base_only` exit 2 · `base_codegen` exit 0 `[VERIFIED: example/README.md:62-66]`), spike 009 | 단정 (Dart 3.13.4 조건 — 생성 파일 제외는 SDK 조건부로 적는다) |
| 끄기 — 프로젝트 전체 | `linter: rules: prefer_final_locals: false` (맵 문법) / `plugins: riverpod_lint: version: ^3.1.9` + `diagnostics: missing_provider_scope: false` | `fixtures/overrides/analysis_options.yaml` `[VERIFIED: 인용 아래]` | 단정 |
| 끄기 — 파일 · 한 줄 | `// ignore_for_file: prefer_single_quotes`, `// ignore: prefer_single_quotes`, `// ignore_for_file: riverpod_lint/provider_parameters`, `// ignore: riverpod_lint/provider_parameters` (윗줄 · 줄 끝 모두) | `fixtures/overrides/lib/suppress/` 다섯 파일 `[VERIFIED: 읽음]` | 단정 |
| 끄기 — 함정 셋 | (1) `version` 없이 `diagnostics:` 만 → **경고 없이 무시**, (2) 접두사 없는 `// ignore: provider_parameters` → 안 꺼짐 (정답지에 남는 줄 `plugin_file_unprefixed.dart:8`, `plugin_line.dart:11`), (3) `analyzer: errors: {provider_parameters: ignore}` → 안 꺼지고 `unrecognized_error_code` | spike 012 `suppression-and-exclude.md` § 4 `[VERIFIED: 읽음]`, (2) 는 정답지 고정 | (1) · (2) 단정, (3) 은 spike 실행 — 단정 가능하나 fixture 에는 없음 |
| 끄기 — 덧붙임 | `version` 값이 그 프로젝트의 plugin 선언을 통째로 대신한다 → 프리셋과 같은 값(`^3.1.9`)을 적는다; `diagnostics:` 에 강도(`info`)를 적으면 강도가 바뀐다; 한 주석에 둘을 함께(`// ignore: a, riverpod_lint/b`) | § 2 · § 1 of `suppression-and-exclude.md` | 출처와 함께 |
| 끄기 — 한 `rules:` 에 목록 · 맵 섞으면 YAML 깨짐 (exit 3) | spike 013 | 출처와 함께 |
| `ignore_for_file: type=lint` 는 규칙 · plugin 둘 다 끔, `type=warning` 은 둘 다 못 끔 | `suppression-and-exclude.md` § 5 | 출처와 함께 (생성기 산출물 머리와 이어진다) |
| 생성 파일 제외 | 사용 프로젝트 옵션 파일에 직접 `analyzer: exclude: - '**/*.g.dart' - '**/*.freezed.dart'`. 이유: "규칙이 늘거나 생성기가 `ignore_for_file` 머리를 달지 않는 파일에서 줄이 날 수 있다". 프리셋의 제외는 SDK 에 따라 다르다 — Dart 3.13.x 규칙 진단에만, 베타 3.14 에는 규칙 진단에도 안 통함 (sdk#64549) | spike 012 · 015 · 016 · 019, `suppression-and-exclude.md` § 6, D-13 | 직접 제외 `'**/*.g.dart'` 는 단정(두 SDK 실측), `'**/*.freezed.dart'` 는 같은 꼴로 읽음. "유일한 방법" · "진단이 쏟아진다" 금지 |
| 버전 올리기 — tag | `ref:` 를 새 tag 로 고치고 `flutter pub get` | spike 015 pub-6 · pub-7 (전환 자체는 `main` → 브랜치 → tag 로 쟀고 tag → tag 는 같은 동작으로 읽음) `[VERIFIED: 읽음]` | 단정 (전환 꼴만 "같은 동작으로 읽은 것") |
| 버전 올리기 — `ref: main` | `flutter pub upgrade woody_lints` (`pub get` 은 lock 의 커밋에 머문다 — pub-2) | 같음 | 단정 |
| `ref: main` → tag | `ref:` 를 tag 로 고치고 `pub get`; lock 커밋 + `--enforce-lockfile` CI 는 lock 갱신 커밋 안 하면 종료 코드 65 | pub-5 ~ pub-7 | 단정 |
| `ref: main` 이 받는 때 | `main` 병합 뒤 각 프로젝트가 `pub upgrade` 할 때. lock 에 항목이 없는 첫 `pub get` 은 그때의 `main` | pub-1 · pub-4 (lock 파일 자체가 없는 경우는 재지 않음) | 출처와 함께 |
| 권하는 일 (D-18) | tag 로 옮기기, 생성 파일 제외 직접, `dev_dependencies` 의 `riverpod_lint` 줄, 새 경고는 CHANGELOG 표 보고 `dart fix --apply` | D-04 · D-13 · spike 022 (`dart fix` 는 plugin 진단을 고치지 않는다) | 출처와 함께 |
| `dev_dependencies` 의 `riverpod_lint` | 있을 때와 뺐을 때 진단 같음, plugin 은 둘 다 3.1.9 (그 줄의 lock 은 3.1.3). 다른 용도는 안 봤음. pub.dev 설치 안내도 `plugins:` 만 | spike 019 (`real-consumer-measurement.md` § 5 D = V2 `[VERIFIED: 읽음]`), pub.dev `[CITED: 05-CONTEXT.md D-04, 2026-10-13 읽음]` | 단정은 "진단에 필요 없다" 까지 (D-04) |
| 문제 해결 1 — plugin 경고가 안 보일 때 | (가) `flutter analyze` 로 보고 있다 → `dart analyze`; (나) plugin 준비 실패 — stderr 에 `An error occurred while executing an analyzer plugin:` 머리말, 종료 코드는 0/2 그대로일 수 있음; 네트워크(pub 서버) 필요; (다) 옵션 파일에 `version` 없이 `diagnostics:` 만 적어 조용히 무시 | spike 002 · 008 · 012, `analyze-run-and-verdict.md` § 6 `[VERIFIED: 읽음]` | 단정 |
| 문제 해결 2 — Analysis Server 재시작 | `plugins:` 를 바꾼 뒤 IDE 의 Dart Analysis Server 재시작. plugin 은 상태 폴더 `.plugin_manager/<hash>/` 에 받아 컴파일된다 — 기본 자리 `~/.dartServer`, 컴파일된 `plugin.aot` 이 깨진 채 남으면 지울 때까지 계속 실패 → 그 폴더를 지우고 다시 | 지금 `lib/riverpod.yaml` 4 ~ 6행의 문장, spike 008 `analyze-run-and-verdict.md` § 7 (전용 상태 폴더에서 잰 것) | "깨지면 지울 때까지 실패" 는 단정(전용 폴더), `~/.dartServer` 에 옮겨 적는 것은 읽은 것 (Discretion) |
| 문제 해결 3 — `dart analyze` vs `flutter analyze` | Flutter 3.47.5 의 `flutter analyze` 는 plugin 진단을 내지 않았다 (3.41.9 는 냄, 2026-09-20 실측); 베타 3.49.0-0.2.pre 는 내지만 규칙 진단을 겹쳐 셌다 (37 · 47건, 2026-10-12). `dart analyze` 는 `--fatal-warnings` 기본 켜짐 · `--fatal-infos` 꺼짐, `flutter analyze` 는 둘 다 켜짐 | `lib/riverpod.yaml` 7 ~ 8행 `[VERIFIED]`, spike 016 `next-sdk-forward-compat.md` § 6, `VERSIONING.md` 57행 | 단정 (버전 · 날짜 붙여서, D-14) |
| 문제 해결 4 — tag 를 고정해도 바뀌는 것 | plugin 은 분석마다 pub.dev 에서 `^3.1.9` 범위의 최신으로 풀린다 (2026-10-12 에 `^3.1.3` 도 3.1.9); 기반 세트 `flutter_lints: ^6.0.0` 도 caret 범위; plugin 쪽 `analyzer` 릴리스로 생성 파일 제외의 plugin 칸이 바뀔 수 있음 (추정) | spike 010, `example-project-and-expected-file.md` § Constraints 첫 항목, `next-sdk-forward-compat.md` § 3 "축이 둘" | 범위 풀림은 단정, `analyzer` 릴리스 영향은 "추정" 으로 |
| 호환 범위 | Riverpod 3.x · workspace 아닌 프로젝트만 돌려 봤다 | 03-CONTEXT D-08 | workspace 는 공식 문서 문장 + "돌려 보지 않았다" — 이 세션은 그 문장을 가져오지 않았다 (Open Question) |
| 규칙 목록 | 표시 구역, 분류 넷은 `lib/base.yaml` 19 · 31 · 77 · 103행의 주석 `# 성능` · `# 가독성 및 스타일` · `# 버그 방지` · `# strict — …` `[VERIFIED]` | D-16 | `RULES.md` 의 분류 칸은 `가독성·스타일` · `버그 방지 (strict)` 로 글자가 다르다 `[VERIFIED: awk 셈 — 성능 10 · 가독성·스타일 44 · 버그 방지 25 · 버그 방지 (strict) 2]` — 검사 (d) 는 이름만 보므로 영향 없음. README 는 D-16 대로 base.yaml 쪽 글자 |

### 인용 — README 블록의 원본 (글자 그대로) `[VERIFIED: 읽음, 2026-10-13]`

```yaml
# fixtures/recommended/analysis_options.yaml
include: package:woody_lints/recommended.yaml
```

```yaml
# fixtures/base_only/analysis_options.yaml
include: package:woody_lints/base.yaml
```

```yaml
# fixtures/base_riverpod/analysis_options.yaml
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml
```

```yaml
# fixtures/base_codegen/analysis_options.yaml
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/codegen.yaml
```

```yaml
# fixtures/overrides/analysis_options.yaml (주석은 fixture 의 것)
include: package:woody_lints/recommended.yaml

# 프로젝트 전체에서 끄기 — 규칙 하나 (맵 문법) 와 plugin 진단 하나 (version 을 함께 적는다).
linter:
  rules:
    prefer_final_locals: false

plugins:
  riverpod_lint:
    version: ^3.1.9
    diagnostics:
      missing_provider_scope: false
```

주석으로 끄는 다섯 파일의 핵심 줄: `lint_file.dart` 1행 `// ignore_for_file: prefer_single_quotes`, `lint_line.dart` 2행 `// ignore: prefer_single_quotes`, `plugin_file_prefixed.dart` 1행 `// ignore_for_file: riverpod_lint/provider_parameters`, `plugin_line.dart` 8행 `// ignore: riverpod_lint/provider_parameters` 와 12행의 줄 끝 꼴, `plugin_file_unprefixed.dart` 1행 `// ignore_for_file: provider_parameters` (안 꺼지는 대조).

### 절 순서 (권고 — Discretion)

1. 소개 (두 문장 + `RULES.md` 링크) → 2. 요구 SDK → 3. 설치 (`dev_dependencies` + `ref: v2.0.0` + `flutter pub get` + 확인) → 4. 프리셋 고르기 (2 × 2 표 + 블록 넷 + 옛 주소 한 줄) → 5. 받는 규칙 (표시 구역 — 분류 넷 아래 불릿 이름, `RULES.md` 의 켠 · 켜지 않은 절 링크) → 6. 규칙 · plugin 진단 끄기 (프로젝트 전체 / 파일 / 한 줄 × 둘, 함정 셋) → 7. 생성 파일 제외 (D-13) → 8. 버전 올리기 (tag 갈래 / `ref: main` 갈래 / `main` → tag / 1.3.0 → 2.0.0 에서 권하는 일) → 9. 문제 해결 (넷) → 10. 이 저장소를 고치는 사람에게 (규칙은 `lib/base.yaml` 에만, 세 곳을 같은 커밋에, 검증 명령 `fvm dart run tool/verify.dart`, `VERSIONING.md`).

## 5. YAML 머리 주석과 `.claude/CLAUDE.md` (planner 질문 5)

### 다섯 파일의 지금 머리 주석 `[VERIFIED: cat -n, 2026-10-13]`

| 파일 | 행 | 지금 주석 전문 | D-08 처리 |
|---|---|---|---|
| `lib/analysis_options.yaml` (3행) | 1 ~ 2 | `# 옛 주소 (package:woody_lints/analysis_options.yaml) 의 별칭 — 묶음(recommended.yaml) 과 같다.` / `# 새 프로젝트는 package:woody_lints/recommended.yaml 을 include 한다.` | 거의 그대로 (2줄). 3행 `include: package:woody_lints/recommended.yaml` |
| `lib/recommended.yaml` (6행) | 1 ~ 2 | `# woody_lints 묶음 — 기본 규칙 + Riverpod plugin + 코드 생성 설정을 한 번에 받는다.` / `# 조각을 골라 받으려면 아래 셋 가운데 필요한 것만 include 한다.` | 그대로거나 README 링크 한 줄 추가. 3 ~ 6행 `include:` 목록 셋 — (a) 가 고정하고 있어 **주석 이외의 줄은 바꾸면 `[3/10]` 실패** |
| `lib/riverpod.yaml` (10행) | 1 ~ 8 | 1 `# analyzer plugin (Dart 3.10+ analysis_server_plugin 방식) — 최상위 키.` 2 `# riverpod_lint 3.x 는 이 방식만 지원한다. 옛 \`analyzer: plugins:\` 선언은` 3 `# 아무것도 로드하지 않았고, Dart 3.13 부터 legacy plugin 경고를 낸다.` 4 `# plugin 은 프로젝트 pubspec.lock 과 별도로 Dart Analysis Server 의 plugin 캐시` 5 `# (~/.dartServer/.plugin_manager)에서 해석된다.` 6 `# 이 섹션을 바꾼 뒤에는 Dart Analysis Server 를 재시작해야 반영된다.` 7 `# 결과 확인은 \`dart analyze\` 로 한다 — Flutter 3.47.5 의 \`flutter analyze\` 는` 8 `# plugin 진단을 표시하지 않았다 (3.41.9 는 표시, 2026-09-20 실측).` | 1 ~ 3행의 "왜 최상위 `plugins:` 인가" 는 남긴다 (2 ~ 3줄로 줄임). 4 ~ 8행(캐시 · 재시작 · `flutter analyze`) 은 README 문제 해결 절로. **WR-02 를 닫은 뒤에** 고친다 — 9 ~ 10행 `plugins:` / `  riverpod_lint: ^3.1.9` 에 줄 끝 주석을 달 수 있게 된다 |
| `lib/codegen.yaml` (7행) | 없음 | (1 ~ 6행이 `analyzer:` / `errors:` / `invalid_annotation_target: ignore` / `exclude:` / `'**/*.freezed.dart'` / `'**/*.g.dart'`, 7행 빈 줄) | 신설 2 ~ 4줄: 무엇을 주는지(freezed / json_serializable 의 `invalid_annotation_target` 억제 + 생성 파일 제외), 제외는 SDK 에 따라 사용 프로젝트 파일에 닿지 않을 수 있으니 직접 적으라는 안내는 README 에 |
| `lib/base.yaml` (112행) | 1 ~ 12, 15, 108 ~ 112 | 1 ~ 12 템플릿 영어 (`# This file configures the static analysis results …` ~ `# The core lints are also what is used by pub.dev for scoring packages.`), 13 `include: package:flutter_lints/flutter.yaml`, 15 `# Uncomment the following section to specify additional rules.`, 106 ~ 107 빈 줄 둘, 108 `# For more information about the core and recommended set of lints, see`, 109 `# https://dart.dev/go/core-lints`, 110 빈 줄, 111 `# For additional information about configuring this file, see`, 112 `# https://dart.dev/guides/language/analysis-options` | 1 ~ 12 · 15 · 108 ~ 112 삭제 (04-REVIEW IN-05 도 15행을 짚었다). 새 머리 2 ~ 4줄: 기반 세트 위에 더하는 규칙, 규칙은 이 파일에만(검증이 지킨다), 이유는 `RULES.md`. 19 · 31 · 77 · 103행 분류 주석과 81개 줄 끝 사유 주석은 그대로 |

`lib/base.yaml` 의 규칙 줄은 건드리지 않으므로 정답지 다섯은 바뀌지 않는다 — 커밋 뒤 `fvm dart run tool/verify.dart --update` 가 `바뀐 정답지가 없다 — 쓰지 않았다` 여야 한다 (04-01 의 (i) 와 같은 확인).

### `.claude/CLAUDE.md` 의 두 줄 `[VERIFIED: sed -n, 2026-10-13]`

- 71행: `- 규칙은 \`lib/analysis_options.yaml\` 의 분류 주석(성능 / 가독성 및 스타일 / 버그 방지) 아래에 추가하고, \`README.md\` 의 "포함된 규칙 목록" 과 \`CHANGELOG.md\`, \`pubspec.yaml\` 의 \`version\` 을 함께 갱신한다.` → `lib/base.yaml` 의 분류 주석(성능 / 가독성 및 스타일 / 버그 방지 / strict) 아래에 더하고, `RULES.md` 켠 규칙 표 · README 표시 구역 · CHANGELOG 를 같은 커밋에서 고친다 (검증 명령 `[3/10]` 이 셋의 일치를 본다).
- 181행: `- YAML 주석은 한국어로 쓴다. 템플릿에서 온 영어 주석(\`lib/analysis_options.yaml\` 1-12행, 60-64행)은 그대로 둔다.` → "템플릿에서 온 영어 주석은 두지 않는다 (2.0.0 에서 지웠다)".
- 같은 절차를 적은 다른 줄: `grep -n "포함된 규칙 목록\|템플릿에서 온 영어 주석\|분류 주석.*아래에 추가"` 로 **71 · 181행 둘뿐** `[VERIFIED]`. 70행(주석 처리 항목) · 69행(`^3.1.3`) · 182 ~ 183행(`lib/analysis_options.yaml` 49-56행 · 55-56행 예시) 은 낡았지만 D-09 의 범위 밖 — 손대지 않는다.

## 6. 재사용할 검증 관례 (planner 질문 6)

### 비공개 점검 (04-RESEARCH § 8 의 (1) · (2) 를 이 phase 의 대상 파일로) `[VERIFIED: 04-RESEARCH.md:658-691]`

```sh
# (1) 절대 경로 · 홈 · 임시 폴더 — 0줄
git grep -n -E '/Users/[A-Za-z]|/private/tmp[/]|/var/folders[/]|/home/[a-z]+[/]' -- \
  README.md CHANGELOG.md lib tool/verify.dart example/README.md .claude/CLAUDE.md \
  .planning/phases/05-documentation .planning/ROADMAP.md .planning/STATE.md

# (2) 사용 프로젝트의 파일 경로 꼴 — 저장소에 실재하는 경로만
git grep -h -o -E '(lib|test|bin|assets)/[A-Za-z0-9_./-]+\.(dart|json|arb|yaml)' -- \
  README.md CHANGELOG.md lib tool/verify.dart example/README.md .planning/phases/05-documentation \
  | sort -u | while read -r p; do
      case "$p" in lib/woody_probe_marker/*|bin/cache/flutter.version.json) continue;; esac
      [ -e "$p" ] || [ -e "example/$p" ] || [ -e "fixtures/base_only/$p" ] || [ -e "fixtures/overrides/$p" ] || echo "LEAK? $p"
    done
```

- (3) (`"message"` 필드 · `dart fix` 화면 문구) 과 (4) (원본 상위 폴더 이름) 는 측정 도구 전용이다 — 이 phase 는 측정 결과를 만들지 않으므로 (3) 의 둘째 줄(`fixes? made in|proposed fixes in`)만 README · CHANGELOG 에 돌리면 된다 (README 가 `dart fix --apply` 를 안내하므로 화면 문구를 옮겨 적지 않았는지).
- `fixtures/overrides/lib/suppress/*.dart` 가 README 에 인용되므로 허용 경로에 `fixtures/overrides/$p` 를 더했다. `~/.dartServer` 는 (1) 에 걸리지 않는다 (`~` 꼴).
- `grep` 에 `-` 로 시작하는 고정 문자열은 `-e` (04-RESEARCH 메모). `.planning/phases/05-documentation` 의 PLAN · RESEARCH 자신이 패턴을 담으면 걸린다 — 04-04 와 같이 범위에서 빼고 셈한다.

### 종료 코드와 실행 관례

- 종료 코드 `[VERIFIED: tool/verify.dart:25-26 · example/README.md:105-114]`: 0 통과 / 1 단계 실패 / 64 사용법 / 69 `pub get` 실패 / 70 예외(`FormatException` · `FileSystemException` · `ProcessException`) / 78 SDK 불일치. 문서 어긋남은 1, 읽을 수 없는 입력은 70 (WR-10 선례 `[VERIFIED: STATE.md Phase 04 04-13 줄]`).
- 실행: `fvm dart run tool/verify.dart` (plugin 준비된 상태 약 20 ~ 23초, 처음 69초 — STATE Phase 03), `--update` 는 정답지 변화 확인용. 04 의 plan 은 `<automated>` 에서 `OUT=$(fvm dart run tool/verify.dart 2>/dev/null); RC=$?` 뒤 `grep -qxF '점검 통과 (10개 중 10개)'` 와 `grep -qE '^\[3/10\] 배포 파일의 구성 \.+ 통과$'` 로 판정했다 `[VERIFIED: 04-01-PLAN.md:163]`.
- 커밋 전: `fvm dart analyze` (`No issues found`), `fvm dart format --output=none --set-exit-if-changed tool`.
- M 기록의 다음 번호 **M32** (`example/README.md` 301행이 M31 `[VERIFIED]`). 소절 제목 꼴 `### 추가 실측 — <무엇> (05-NN)`, 첫 줄 `실측 (05-NN): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, YYYY-MM-DD`.
- 처리 기록 표 행 꼴 `[VERIFIED: 03-REVIEW-DISPOSITION.md:75 · 04-REVIEW-DISPOSITION.md:148]`: `| WR-02 | warning | fixed | 05-NN-PLAN.md Task N (<커밋>) — <한 줄> |` 와 YAML 머리의 `disposition:` · `note:` 둘을 함께 고친다. 01-REVIEW-DISPOSITION WR-05 는 지금 `open` `[VERIFIED: 01-REVIEW-DISPOSITION.md:10-13 · 80]`.

## Runtime State Inventory

> 이름 바꾸기 · 이전 phase 가 아니다. 다만 "README 가 안내하는 자리" 가 저장소 밖 상태를 가리키므로 한 줄씩 적는다.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | 없음 — 이 패키지는 데이터를 저장하지 않는다 (YAML 만) | 없음 |
| Live service config | 없음 — GitHub Actions workflow 는 git 안에 있고 바뀌지 않는다 | 없음 |
| OS-registered state | 없음 | 없음 |
| Secrets/env vars | 없음 (`.env` 없음, 검증 명령의 `ANALYZER_STATE_LOCATION_OVERRIDE` 는 스크립트가 스스로 준다) | 없음 |
| Build artifacts | 사용 프로젝트 쪽의 plugin 캐시(`~/.dartServer/.plugin_manager`) 와 pub cache 의 `git/woody_lints-<해시>/` — README 문제 해결 절이 **안내만** 한다 | 없음 (문서) |

## Common Pitfalls

### Pitfall 1: 검사 (d) 를 README 재작성보다 먼저 커밋
**What goes wrong:** 지금 README 에는 표시 구역이 없어 `[3/10]` 이 바로 실패하고, CI 가 빨간 커밋을 남긴다.
**How to avoid:** README 목록과 (d) ~ (g) 를 같은 커밋에 (Discretion 마지막 항목). 커밋 전 `fvm dart run tool/verify.dart` 종료 코드 0.

### Pitfall 2: (f) · (g) 를 파일 전체에 돌려 산문의 옛 값에 걸림
**What goes wrong:** D-06 · D-18 이 README 에 두는 "1.3.0 → 2.0.0", "`ref: v1.3.0` 에 머문다" 류 문장이 `ref: v1.3.0` 으로 읽혀 실패.
**How to avoid:** 코드 블록 안만 읽는다 (Pattern 2). README 를 쓸 때 "복사할 값은 블록 안, 역사는 산문" 을 지킨다.

### Pitfall 3: `stripPlugins` 를 고치고 `fragmentLineHint` 를 두기
**What goes wrong:** 빈 줄 치환 뒤에는 복사본 줄 번호 = 원본인데 힌트는 "앞당겨진다" 고 말한다 — `[2/10]` 실패 화면이 틀린 안내를 한다.
**How to avoid:** 같은 커밋에서 170 ~ 172행 문구 수정. 선택 M 기록(§ 1 끝)으로 13행 보존을 확인.

### Pitfall 4: `riverpod.yaml` 주석 정리를 WR-02 전에
**What goes wrong:** 9 ~ 10행에 줄 끝 사유 주석을 달거나 파일 끝을 정리하면 지금 코드가 70 으로 멈춘다 (§ 1 재현).
**How to avoid:** 커밋 순서 ① → ③ (Primary recommendation). D-08 의 "순서" 항목.

### Pitfall 5: `lib/recommended.yaml` · `lib/analysis_options.yaml` 의 include 줄을 주석 정리 중에 건드림
**What goes wrong:** (a) `includeOnlyFiles` 가 주석 · 빈 줄을 뺀 나머지를 글자 그대로 고정한다 (`- package:…` 세 줄, 한 줄) `[VERIFIED: tool/verify.dart:122-132]`. 들여쓰기는 trim 하지만 글자가 바뀌면 실패.
**How to avoid:** `#` 줄만 바꾼다. 커밋 전 검증.

### Pitfall 6: README · CHANGELOG 에 비공개 프로젝트의 경로 · 메시지
**What goes wrong:** 공개 저장소에 one-way 로 남는다 (D-20 · D-21).
**How to avoid:** § 6 의 (1) · (2) 를 커밋마다. 허용은 `flutter_starter_kit` 이름과 CHANGELOG 의 실측 한 줄.

### Pitfall 7: CHANGELOG 복원에 커밋 메시지를 옮김
**What goes wrong:** 1.2.1 의 메시지 "Update pubspec.yaml / README.md 수정" 류는 변경이 아니다 (D-05).
**How to avoid:** § 3 표의 "diff 로 확인한 변경" 열만. 1.2.4 의 옛 방식 `plugins:` 를 빠뜨리지 않는다.

### Pitfall 8: `.claude/CLAUDE.md` 의 낡은 절을 보고 전부 고치려 함
**What goes wrong:** `.planning/codebase/` 지도로 다시 만들면 되돌아간다 (D-09).
**How to avoid:** 71 · 181행만.

### Pitfall 9: README 규칙 목록을 손으로 치다 이름 오타
**What goes wrong:** 81개를 손으로 적으면 오타가 난다 — (d) 가 잡지만 반복 실패.
**How to avoid:** `grep -oE '^    - [a-z0-9_]+' lib/base.yaml | sed 's/^    - /- `/; s/$/`/'` 로 생성해 분류 주석 자리에 끼운다 (분류 경계는 19 · 31 · 77 · 103행).

### Pitfall 10: 2.0.0 `### 그 밖의 변경` 합치기에서 받는 쪽에 보이는 줄까지 지움
**What goes wrong:** D-07 이 남기라고 한 여섯 불릿(91 · 92 · 94 · 95 · 96 앞부분 · 98)이 사라진다.
**How to avoid:** § 3 의 행 번호 목록대로. `RULES.md` 추가는 따로 한 줄.

## Code Examples

### `[3/10]` 에 더하는 README 검사 (d) ~ (g) 의 뼈대

```dart
// Source: 이 저장소 tool/verify.dart 의 compareBlock · significantLines 꼴을 따름 (설계안)

/// README 의 마커 구역 이름 (D-01). RULES.md 의 `enabled-rules` 와 다르게 두어 grep 이 갈린다.
const readmeRulesBlock = 'readme-rules';

/// README 의 ``` 코드 블록 안 줄만 돌려준다 — 복사해 쓰는 값은 블록 안에 있다 (Pattern 2).
List<String> fencedLines(List<String> lines) {
  final out = <String>[];
  var inFence = false;
  for (final l in lines) {
    if (l.trimLeft().startsWith('```')) { inFence = !inFence; continue; }
    if (inFence) out.add(l);
  }
  return out;
}

/// `pubspec.yaml` 의 `version:` 에서 `major.minor.patch` 만 (`2.0.0-dev` → `2.0.0`). 없으면 FormatException (70).
String pubspecReleaseVersion(String repoRoot) {
  final text = File('$repoRoot/pubspec.yaml').readAsStringSync();
  final m = RegExp(r'^version:\s*(\d+\.\d+\.\d+)', multiLine: true).firstMatch(text);
  if (m == null) throw const FormatException('pubspec.yaml 에서 version: 을 읽지 못했다');
  return m.group(1)!;
}

// checkShippedComposition 안, (c) 뒤:
final readme = File('$repoRoot/README.md');
final readmeLines = readme.readAsLinesSync();              // 없으면 FileSystemException → 70
// (d) 마커 구역의 불릿 이름 — 표로 쓰면 readRulesMdBlock(readme, readmeRulesBlock) 그대로
// (e) 주소
final addresses = RegExp(r'package:woody_lints/([A-Za-z0-9_]+\.yaml)')
    .allMatches(readmeLines.join('\n')).map((m) => m.group(1)!).toSet();
if (addresses.isEmpty) addBlock(['`README.md` 에 `package:woody_lints/…yaml` 주소가 하나도 없다.']);
final missing = addresses.difference(expectedLibYamls).toList()..sort();
if (missing.isNotEmpty) addBlock(['`README.md` 가 가리키는 프리셋 주소가 `lib/` 에 없다 (${missing.length}):', ...missing.map((n) => '  package:woody_lints/$n')]);
// (f) plugin 버전 — 코드 블록 안의 version: · riverpod_lint: 줄
final shipped = readShippedPluginConstraint(repoRoot);
final versions = [for (final l in fencedLines(readmeLines))
  ...?RegExp(r'^\s*(?:version|riverpod_lint):\s*(\^?\d+\.\d+\.\d+)').firstMatch(l)?.groups([1])];
// 0개면 실패, shipped 와 다른 값이 있으면 그 값들을 적어 실패
// (g) ref: — 코드 블록 안의 `ref: vX.Y.Z` (ref: main 은 세지 않는다)
final release = pubspecReleaseVersion(repoRoot);
final refs = [for (final l in fencedLines(readmeLines))
  ...?RegExp(r'^\s*ref:\s*v(\d+\.\d+\.\d+)\s*$').firstMatch(l)?.groups([1])];
// 0개면 실패, release 와 다른 값이 있으면 실패
```

### 고친 `stripPlugins` (03-REVIEW WR-02 의 제안, 복제본에서 입력 10가지 확인)

```dart
// Source: .planning/phases/03-preset-split/03-REVIEW.md WR-02 Fix — 이 세션에서 함수 단위로 돌려 봄
String stripPlugins(String options, {required String shownAs}) {
  final lines = options.replaceAll('\r\n', '\n').split('\n');
  var inPlugins = false;
  for (var i = 0; i < lines.length; i++) {
    final l = lines[i];
    if (RegExp(r'^plugins:[ \t]*(#.*)?$').hasMatch(l)) {
      inPlugins = true;
    } else if (inPlugins && RegExp(r'^\S').hasMatch(l) && !l.startsWith('#')) {
      inPlugins = false;
    }
    if (inPlugins) lines[i] = '';          // 지우지 않고 빈 줄로 — 줄 번호 보존
  }
  final stripped = lines.join('\n');
  if (RegExp(r'^plugins:', multiLine: true).hasMatch(stripped)) {
    throw FormatException('$shownAs 의 `plugins:` 섹션을 빼지 못했다');
  }
  return stripped;
}
```

### 고친 `readShippedPluginConstraint` (스칼라 + 맵 형식, 줄 끝 주석)

```dart
// Source: 이 세션의 probe (복제본), 03-REVIEW WR-02 의 정규식을 바탕으로
String readShippedPluginConstraint(String repoRoot) {
  const shownAs = 'lib/riverpod.yaml';
  final lines = File('$repoRoot/$shownAs').readAsStringSync().replaceAll('\r\n', '\n').split('\n');
  final scalar = RegExp(r'^[ \t]+riverpod_lint:[ \t]*([^\s#]+)[ \t]*(?:#.*)?$');
  final mapKey = RegExp(r'^[ \t]+riverpod_lint:[ \t]*(?:#.*)?$');
  final version = RegExp(r'^[ \t]+version:[ \t]*([^\s#]+)[ \t]*(?:#.*)?$');
  for (var i = 0; i < lines.length; i++) {
    final m = scalar.firstMatch(lines[i]);
    if (m != null) return m.group(1)!;
    if (mapKey.hasMatch(lines[i])) {
      for (var j = i + 1; j < lines.length; j++) {
        final t = lines[j].trim();
        if (t.isEmpty || t.startsWith('#')) continue;
        final vm = version.firstMatch(lines[j]);
        if (vm != null) return vm.group(1)!;
        break;
      }
    }
  }
  throw const FormatException('$shownAs 에서 riverpod_lint 선언을 찾지 못했다');
}
```

### README 규칙 목록 생성 (한 번, 손 오타 방지)

```sh
# lib/base.yaml 의 분류 주석과 규칙 이름을 README 불릿으로 — 분류 주석은 소제목으로 바꿔 쓴다
awk '/^    # /{sub(/^    # /,""); print "\n**" $0 "**\n"; next} /^    - /{sub(/^    - /,""); sub(/ #.*/,""); print "- `" $0 "`"}' lib/base.yaml
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| README 가 `ref: main` 설치 + `flutter pub upgrade woody_lints` 안내 | tag 설치 (`ref: v2.0.0`) + 두 갈래 버전 올리기 | 이 phase (spike 015, 2026-10-12 근거) | `pub upgrade` 는 `ref: main` 쪽에만 |
| README 규칙 목록 12개 (1.3.0, 불일치 2건) | 표시 구역 81개 이름 + 검증 (d) | 이 phase | 어긋나면 CI 실패 |
| `lib/analysis_options.yaml` 한 파일 + 템플릿 주석 | 조각 셋 · 묶음 · 별칭 + 짧은 머리 주석 | Phase 3 (구조) · 이 phase (주석) | — |
| `plugins:` 섹션을 지워 복사 (줄 번호 어긋남, 꼴 하나만 허용) | 빈 줄 치환 (줄 번호 보존, 주석 · CRLF · 맵 형식 허용) | 이 phase (WR-02) | `fragmentLineHint` 단순화 |
| (b) · (c) 가 `lib/base.yaml` 만 | (b′) 로 "다른 조각에 규칙 없음" 을 먼저 확인 | 이 phase (WR-11) | 규칙을 다른 조각에 적는 실수를 CI 가 잡음 |

**Deprecated/outdated:**
- README 95행의 "최상위 `plugins:` 방식, Dart 3.10+" — SDK 하한이 3.13 이라 "3.10+" 문구는 뺀다.
- `.claude/CLAUDE.md` 69 ~ 70 · 73 ~ 75 · 182 ~ 183행의 1.3.0 시절 서술 — D-09 로 미룸 (손대지 않음).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Dart 버전 문자열의 꼴은 `major.minor.patch[-pre][+build]` 이고 앞머리 세 숫자만 취하면 `-dev` · `+N` 이 떨어진다 | § 2 (g) | 틀리면 (g) 가 `pubspec.yaml` 을 읽지 못해 70 — `2.0.0-dev` 하나에는 확인됐으므로 위험 낮음 |
| A2 | CHANGELOG 2.0.0 의 "추가한 규칙 75 vs 표 74" 차이는 04-12 (`sort_pub_dependencies`) 의 결과이고 의도된 것 | § 3 | 틀리면 DOCS-09 확인에서 planner 가 04-09 · 04-12 SUMMARY 로 되짚는다 |
| A3 | README 산문이 `ref: v1.3.0` · `^3.1.3` 같은 옛 값을 인용할 것이다 (D-06 · D-18 의 문장) | § 2 Pattern 2 | 틀려도 코드 블록만 읽는 설계는 안전 쪽 |
| A4 | Keep a Changelog · very_good_analysis README · lints `recommended.yaml` · pub.dev riverpod_lint 의 내용은 CONTEXT 가 2026-10-13 에 읽은 그대로다 | User Constraints 의 참고 | 이 세션은 다시 열지 않았다 — README 문구에 옮길 때 planner 가 인용을 CONTEXT 의 문장 범위로 한정하면 영향 없음 |
| A5 | 선택 M 기록(deprecated 규칙을 `riverpod.yaml` 끝에)에서 진단 행이 원본과 같은 13행으로 나온다 | § 1 | 복사본 줄 수가 같아지는 것은 probe 로 확인(10 → 10줄). analyzer 가 그 줄을 보고하는 행 번호까지는 돌리지 않았다 |

## Open Questions (RESOLVED)

세 질문은 계획 단계(05-01 ~ 05-06, 2026-10-14)가 답했다.

1. **pub workspace 문장의 출처** — RESOLVED
   - What we know: 03-CONTEXT D-08 — workspace 는 재지 않았고 README 는 공식 문서 문장을 출처와 함께 옮긴다.
   - What's unclear: 이 세션은 dart.dev 의 workspace 문서를 열지 않았다 — 옮길 문장과 URL 이 없다.
   - Recommendation: planner 가 "workspace 멤버 패키지에서는 이 패키지로 돌려 보지 않았다" 한 줄만 두고 공식 문서 링크(dart.dev/tools/pub/workspaces) 는 실행 때 열어 확인 `[ASSUMED — URL 은 훈련 지식]`.
   - RESOLVED: URL `https://dart.dev/tools/pub/workspaces` 는 2026-10-14 에 HTTP 200 으로 열렸다 (plan checker 확인). 05-03 Task 1 action B-4 는 D-08 글자대로 — 실행 때 그 문서를 열어 멤버 패키지의 `analysis_options.yaml` 해석에 관한 **문장 하나를 출처(URL · 읽은 날짜)와 함께 옮기고** "이 패키지로는 돌려 보지 않았다" 를 적는다 (링크만 두지 않는다). 위 Recommendation 의 "한 줄만" 은 결정보다 좁았다.
2. **README 표시 구역을 표로 할지 불릿으로 할지** — RESOLVED
   - What we know: 표면 `readRulesMdBlock` 재사용(코드 0줄), 불릿이면 10줄 변형. D-01 은 "이름만".
   - Recommendation: 불릿 (읽기 쉬움, 분류 소제목과 어울림) + 10줄 reader. 표를 고르면 `| 규칙 |` 한 열 표 네 개.
   - RESOLVED: 불릿 + 새 reader `readBulletBlock` (05-03 Task 2 action A-2). 분류 소제목은 backtick 없는 굵은 글씨, 구역 안에는 이름 외 backtick 없음.
3. **`example/README.md` 의 M 기록에 "거짓 실패가 사라졌다" (통과) 행을 넣는 꼴** — RESOLVED
   - What we know: 지금 표의 열은 `실패한 단계 | 정답지와의 차이 | 종료 코드` — 통과 행은 "실패 없음 · 차이 없음 · 0".
   - Recommendation: 같은 표에 두고 읽는 법에 "M32 · M33 은 고치기 전 70 이었던 입력" 을 적는다. M34 가 헛통과 아님을 받친다.
   - RESOLVED: 그대로 — 05-01 Task 1 action 4 (같은 표, 통과 행은 `실패 없음` · `차이 없음` · `0`, 읽는 법에 고치기 전 70 의 출처). § 1 의 "(선택)" M (riverpod.yaml 끝 deprecated 규칙) 은 05-01 Task 2 의 M37 로 필수가 됐다 — 줄 번호 보존과 (b′) 의 대상 범위를 가르는 유일한 실행이다 (plan checker 재현: 줄을 지우는 `stripPlugins` 는 `:11`, 바른 판은 `:13`).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| fvm + Flutter 3.47.5 / Dart 3.13.4 | 검증 명령 · `dart analyze` | ✓ | fvm 4.3.1, Dart 3.13.4 `[VERIFIED]` | — (78 로 멈춤) |
| git | `git show` · `git grep` · 커밋 | ✓ | 2.56.0 | — |
| gh | push 뒤 CI 확인 | ✓ | 2.102.0 | 웹 UI |
| 네트워크 (pub.dev) | 검증 명령의 plugin 준비 (처음 실행) | 이 세션에서 복제본의 `pub get` 이 통과 `[VERIFIED]` | — | 없음 — plugin 준비 실패는 단계 실패(1) |
| `flutter_starter_kit` 원본 | **필요 없음** — 이 phase 는 실측하지 않는다 | — | — | — |

**Missing dependencies with no fallback:** 없음.
**Missing dependencies with fallback:** 없음.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | 없음 (테스트 프레임워크 · `test/` 없음). 검증 장치는 `tool/verify.dart` 단계 10개 (`[3/10]` 에 (b′) · (d) ~ (g) 가 더해진다), 루트 `fvm dart analyze`, `fvm dart format --set-exit-if-changed tool`, § 6 의 grep, `example/README.md` 의 지워 보기 기록 |
| Config file | `tool/verify.dart` 의 상수 (`rulesFile` · `expectedLibYamls` · `includeOnlyFiles` · 새 `readmeRulesBlock`), `README.md` 의 마커, `RULES.md` 의 마커 |
| Quick run command | `fvm dart analyze && fvm dart run tool/verify.dart` (plugin 준비된 상태 약 20 ~ 23초) |
| Full suite command | 위 + `fvm dart format --output=none --set-exit-if-changed tool` + § 6 (1) · (2) grep + `fvm dart run tool/verify.dart --update` 가 `바뀐 정답지가 없다` (YAML 주석 커밋 뒤) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DOCS-01 | README 설치 블록에 `dev_dependencies` · `git:` · `ref: v2.0.0` · `flutter pub get` | grep + 검사 (g) | `grep -qxE '\s*ref: v2\.0\.0' README.md && ! grep -q 'ref: main' <(sed -n '/^## 설치/,/^## /p' README.md)`; `[3/10]` 통과 | ❌ README 재작성 |
| DOCS-02 | 블록 넷이 fixture 옵션 파일과 같다 | diff (사람 1회 + grep) | `for f in recommended base_only base_riverpod base_codegen; do grep -qF "$(sed -n '1p' fixtures/$f/analysis_options.yaml)" README.md || exit 1; done`; 검사 (e) | ❌ |
| DOCS-03 | 세 층 × 둘의 예시 | grep | `grep -c -E 'ignore_for_file: riverpod_lint/|ignore: riverpod_lint/|diagnostics:|: false' README.md` ≥ 4; `version:` 이 끄기 블록에 (검사 (f)) | ❌ |
| DOCS-04 | 두 갈래 + 전환 + 65 | grep | `grep -q 'flutter pub upgrade woody_lints' README.md && grep -q 'enforce-lockfile' README.md && grep -q '65' README.md` | ❌ |
| DOCS-05 | 문제 해결 넷 | grep | `grep -q 'An error occurred while executing an analyzer plugin' README.md && grep -q '3.47.5' README.md && grep -q '2026-09-20' README.md && grep -q 'plugin_manager' README.md` | ❌ |
| DOCS-06 | 불일치 2건 해소, `analyzer:` 설명 | grep + 검사 (d) | `! grep -q 'require_trailing_commas' README.md && ! grep -q 'trailing_commas' README.md && grep -q 'invalid_annotation_target' README.md`; `[3/10]` 통과; M37 실패 | ❌ |
| DOCS-07 | 2.0.0 항목 형식 | grep | `head -1 CHANGELOG.md` = `## 2.0.0 - 미출시`, `sed -n 3p` 가 `지원 SDK:` 로 시작, 칸 다섯 제목 순서 | ✓ (확인만) |
| DOCS-08 | 1.1.0 ~ 1.2.5 항목 7개 | grep | `for v in 1.1.0 1.2.0 1.2.1 1.2.2 1.2.3 1.2.4 1.2.5; do grep -qx "## $v" CHANGELOG.md || exit 1; done`; 커밋 번호 7개 `grep -c -E '2249a0b|ec66e3f|21c5689|31c8cb1|9451f6b|212365d|dbcd20b' CHANGELOG.md` ≥ 7; 순서 `grep -n '^## ' CHANGELOG.md` 가 내림차순 | ❌ |
| DOCS-09 | 표의 규칙 행 수 == `### 추가한 규칙` 불릿 수 (2026-10-14 셈 75 · 75 — 위 § 3 정정) + 실측 줄 | grep | `test "$(sed -n '/^### 새로 생기는 경고/,/^## 1.3.0/p' CHANGELOG.md \| grep '^| \`' \| wc -l)" = "$(sed -n '/^### 추가한 규칙/,/^### 그 밖의/p' CHANGELOG.md \| grep '^- \`' \| wc -l)"`; `grep -q '^실측: flutter_starter_kit' CHANGELOG.md` | ✓ (확인만) |
| DOCS-10 | 템플릿 없음, 머리 주석 | grep | `! grep -q 'This README describes' README.md && ! grep -q 'Uncomment the following' lib/base.yaml && ! grep -q 'dart.dev/go/core-lints' lib/base.yaml && head -1 lib/codegen.yaml \| grep -q '^#'`; 다섯 파일 `head -1` 이 `#`; `--update` → `바뀐 정답지가 없다` | ❌ |
| VERIFY-06 | README 목록 어긋남 → 실패 | 지워 보기 | M37 (이름 삭제) rc 1 · `[3/10]` 실패; M38 ~ M40; (선택) 마커 삭제 | ❌ `[3/10]` (d) ~ (g) |
| (WR-02) | 거짓 실패 해소 | 지워 보기 | M32 · M33 rc 0, M34 rc 70 | ❌ |
| (WR-11 · IN-14) | 다른 조각의 규칙 → 실패, 문구에 파일 이름 | 지워 보기 | M35 rc 1 (`lib/codegen.yaml 에 규칙이 있다`), M36 rc 70 (stderr 에 `lib/codegen.yaml`) | ❌ |
| (D-09) | CLAUDE.md 두 줄 | grep | `! grep -q '포함된 규칙 목록' .claude/CLAUDE.md && ! grep -q '템플릿에서 온 영어 주석.*그대로 둔다' .claude/CLAUDE.md` | ❌ |
| (D-19) | 처리 기록 넷 | grep | `grep -E '^\| (WR-05)' .planning/phases/01-*/01-REVIEW-DISPOSITION.md \| grep -q fixed` 등 넷 | ❌ |
| (D-20) | 비공개 정보 없음 | grep | § 6 (1) · (2) 0줄 | ✓ 명령만 |

### Sampling Rate

- **Per task commit:** `fvm dart analyze` + `fvm dart format --output=none --set-exit-if-changed tool` + `fvm dart run tool/verify.dart` (rc 0, `점검 통과 (10개 중 10개)`) + § 6 (1) · (2).
- **Per wave merge:** 위 + 그 wave 의 M 기록을 실제로 만들어 돌리고 되돌림 (`git status` · `git diff` 비어 있음) + YAML 주석 wave 는 `--update` 가 `바뀐 정답지가 없다`.
- **Phase gate:** 로컬 rc 0, 첫 push 뒤 GitHub `verify` 성공 1회, M32 ~ M40 기록, ROADMAP 성공 기준 1 ~ 5 를 `05-VERIFICATION.md` 가 명령으로 확인, § 6 범위 전체 0줄.

### Wave 0 Gaps

- [ ] `tool/verify.dart` — `stripPlugins` · `readShippedPluginConstraint` · `declaredRuleNames(shownAs)` · `fragmentLineHint` (wave 1), `[3/10]` (b′) (wave 2), (d) ~ (g) + `fencedLines` · `pubspecReleaseVersion` (wave 4, README 와 같은 커밋)
- [ ] `README.md` 마커 구역 `woody:readme-rules` (wave 4)
- [ ] `example/README.md` 소절 "추가 실측 — … (05-NN)" M32 ~ M40 (각 wave)
- 프레임워크 설치: 없음

## Security Domain

> `security_enforcement` 가 켜져 있다. 이 phase 에는 네트워크 서비스 · 인증 · 저장소가 없다. 위험은 **공개 저장소에 비공개 사용 프로젝트의 정보가 실리는 것** 하나와, README 가 안내하는 "폴더 지우기" 가 사용자의 다른 것을 건드리지 않게 적는 것이다.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | no | — |
| V5 Input Validation | yes — `tool/verify.dart` 가 README · pubspec 을 읽는다 | 읽지 못하면 `FormatException` → 70 (조용히 통과하지 않음); 읽은 값 0개 → 단계 실패 |
| V6 Cryptography | no | — |
| V8 Data Protection | **yes** — 비공개 프로젝트의 경로 · 메시지 · 코드 | § 6 grep 을 커밋마다, push 전 범위 전체 (D-20 · D-21) |
| V10 Supply chain | no — 새 의존성 0 | — |

### Known Threat Patterns for 이 stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| README · CHANGELOG · `.planning/` 에 비공개 경로 · 메시지 (one-way) | Information disclosure | § 6 grep (1) · (2), 허용 목록은 `flutter_starter_kit` 이름과 CHANGELOG 실측 한 줄만 |
| README 의 복구 안내가 `~/.dartServer` 전체 삭제를 권함 | Tampering (사용자 환경) | 잰 것은 **전용 상태 폴더**(spike 008). README 는 "`.plugin_manager/<hash>/` 가운데 이 프로젝트의 것" 또는 "검증 명령은 전용 폴더를 쓴다" 로 범위를 좁혀 적고, 기본 자리 삭제는 "IDE 와 다른 프로젝트가 함께 쓰는 자리" 라고 밝힌다 (`analyze-run-and-verdict.md` § 2) |
| README 설치 블록의 `url:` 오타 | Tampering (잘못된 저장소) | `pubspec.yaml` 8행 `repository:` 와 글자 비교 — 검사에 넣을지는 Discretion (한 줄 grep 으로 충분) |

## Sources

### Primary (HIGH confidence)

- 이 저장소의 파일 (이 세션에서 `Read` · `cat -n` · `sed -n` 으로 읽음): `.planning/phases/05-documentation/05-CONTEXT.md` 전문, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `.planning/ROADMAP.md` 7 ~ 13 · 239 ~ 265행, `README.md` 전문, `CHANGELOG.md` 전문, `VERSIONING.md` 전문, `RULES.md` 1 ~ 12 · 95 ~ 124행과 마커 줄, `example/README.md` 56 ~ 172 · 239 ~ 310행, `lib/*.yaml` 다섯 전문, `pubspec.yaml`, 루트 `analysis_options.yaml`, `.gitignore`, `.github/workflows/verify.yml`, `tool/verify.dart` 25 ~ 225 · 756 ~ 1460 · 1736 ~ 1859행과 최상위 선언 목록, `fixtures/*/analysis_options.yaml` 다섯, `example/analysis_options.yaml`, `fixtures/overrides/lib/suppress/*.dart` 다섯, `.claude/CLAUDE.md` 60 ~ 80 · 176 ~ 186행, `.planning/phases/03-preset-split/03-REVIEW.md` WR-02 ~ WR-04, `03-REVIEW-DISPOSITION.md`, `.planning/phases/04-rule-reselection/04-REVIEW.md` 155 ~ 294행, `04-REVIEW-DISPOSITION.md`, `04-RESEARCH.md` 1 ~ 12 · 155 ~ 200 · 655 ~ 693 · 930 ~ 1019행, `04-CONTEXT.md` D-08 · D-11 · D-12 · D-18, `04-01-PLAN.md` 163행, `04-13-PLAN.md` 발췌, `.planning/phases/01-baseline-and-toolchain/01-REVIEW.md` WR-05, `01-REVIEW-DISPOSITION.md`, `.planning/phases/03-preset-split/03-CONTEXT.md` 60 ~ 100행, `.planning/PROJECT.md` 발췌
- spike references (`.claude/skills/spike-findings-woody-lints/`): `SKILL.md` 1 ~ 172행, `references/git-dependency-and-upgrade.md` 전문, `references/suppression-and-exclude.md` § Requirements ~ § 6, `references/next-sdk-forward-compat.md` 1 ~ 30 · § 3 · § 6 ~ 8, `references/example-project-and-expected-file.md` § Constraints, `references/real-consumer-measurement.md` § 5, `references/analyze-run-and-verdict.md` § 6 ~ 7 과 grep 발췌
- git 이력 (`git show` · `git log`, 2026-10-13): `d98b45a` · `d525664` · `9a6627e` · `126aa43` · `2249a0b` · `9bf0d86` · `ec66e3f` · `423936c` · `9950fd1` · `21c5689` · `7b7455e` · `31c8cb1` · `1693a97` · `9451f6b` · `a97fd20` · `212365d` · `dbcd20b` · `90a2736` 의 stat 과 `lib/analysis_options.yaml` · `pubspec.yaml` · `.fvmrc` · `.vscode/settings.json` · `README.md` diff
- 실행 (저장소 복제본, Flutter 3.47.5 / Dart 3.13.4, 2026-10-13): WR-02 두 변경의 `fvm dart run tool/verify.dart` (둘 다 rc 70, stdout 0 바이트), 함수 단위 probe 입력 10가지 (지금 판 · 고친 판)
- 도구 버전: `fvm dart --version` 3.13.4, `fvm --version` 4.3.1, `git --version` 2.56.0, `gh --version` 2.102.0

### Secondary (MEDIUM confidence)

- 05-CONTEXT.md 가 2026-10-13 에 읽고 인용한 외부 문서 (이 세션은 다시 열지 않음): very_good_analysis README, dart-lang/core `pkgs/lints/lib/recommended.yaml`, pub.dev `riverpod_lint` 3.1.9 설치 안내, keepachangelog.com 1.1.0, flutter#191151, dart-lang/sdk#64549, dart.dev/tools/pub/dependencies `[CITED: 05-CONTEXT.md canonical_refs]`

### Tertiary (LOW confidence)

- Dart 버전 문자열 문법 (A1), dart.dev workspace 문서 URL (Open Question 1) — 훈련 지식 `[ASSUMED]`

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 새 의존성 없음, 도구 버전 실측
- Architecture (검사 설계 · WR-02 · WR-11): HIGH — 코드를 읽고 WR-02 를 재현 · 고친 판을 돌려 봤다. 설계안의 코드는 돌려 보지 않은 뼈대 (planner · executor 가 M 기록으로 확인)
- README 사실 목록: HIGH — fixture 와 references 를 읽음. workspace 문장과 외부 문서 재인용은 MEDIUM
- CHANGELOG 복원 재료: HIGH — 커밋 18개의 diff 를 직접 읽음
- Pitfalls: HIGH — 대부분 코드 · 기록에서 직접 확인

**Research date:** 2026-10-13
**Valid until:** 2026-11-12 (30일 — 저장소 안의 사실은 커밋이 바뀔 때까지 유효. plugin 이 `^3.1.9` 범위에서 3.1.9 로 풀린다는 값은 pub.dev 릴리스에 따라 달라질 수 있다)
