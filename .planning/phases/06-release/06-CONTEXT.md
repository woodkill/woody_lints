# Phase 6: Release - Context

**Gathered:** 2026-10-15
**Status:** Ready for planning

<domain>
## Phase Boundary

2.0.0 을 annotated tag `v2.0.0` 으로 GitHub 에 올려 사용 프로젝트가 `ref: v2.0.0` 으로 고정할 수 있게 한다. 그 tag 를 실제 GitHub 주소에서 git 의존성으로 받은 빈 프로젝트에서 규칙 진단과 `riverpod_lint` 진단이 둘 다 보고됨을 확인한다. tag 이름 · `pubspec.yaml` 의 version · CHANGELOG 최상단 버전이 어긋나면 CI 가 실패하게 한다. 이 phase 가 끝나면 다음이 참이다 (ROADMAP 성공 기준 1 ~ 3).

1. tag 이름, `pubspec.yaml` 의 version, CHANGELOG 최상단 버전이 서로 다르면 실패하는 검사가 CI 의 tag 트리거에 걸려 있고, 일부러 어긋나게 만든 입력에서 실제로 실패함이 확인되어 있다 (REL-03)
2. `git ls-remote --tags origin` 에 새 버전의 annotated tag 가 보이고, 그 tag 의 `pubspec.yaml` version 과 CHANGELOG 최상단 버전이 tag 이름과 같다 (REL-02)
3. 빈 프로젝트가 새 tag 를 git 의존성(`ref: vX.Y.Z`)으로 받아 `dart analyze` 를 돌리면 기본 규칙 진단과 `riverpod_lint` plugin 진단이 둘 다 보고된다 (REL-04)

이 phase 안에서 함께 닫는 것 (앞 phase 에서 이 phase 로 넘긴 것):

- Phase 2 에서 미룬 확인 둘 (`02-UAT.md` 4번 · 6번) — PR 에서 `verify` 가 도는지, 수동 실행 버튼 (D-03)
- Phase 5 에서 미룬 리뷰 경고 셋 (`05-REVIEW.md` IN-12 · IN-13 · IN-14) 과 UAT 문서 손질 넷 (`05-UAT.md` 1 · 2 · 4 · 5번) — release tag 전에 닫는다 (D-13, D-14, "정한 대로 고치는 다섯")
- Phase 1 · 2 · 3 이 "Phase 6 의 릴리스 절차 문서에서 검토한다" 고 미룬 것 — 절차 문서의 자리, `미출시` 거부, `example/` lock 을 새로 받는 단계, plugin 새 버전에 정답지가 깨졌을 때의 절차 (D-05, D-11, D-12)

이 phase 가 하지 않는 것: 사용 프로젝트에 2.0.0 을 적용하고 경고를 정리하는 일(Out of Scope), 규칙 · 프리셋 내용의 변경, pub.dev 게시, `.claude/CLAUDE.md` 의 낡은 줄 정리(05-REVIEW WR-06 · 261행 — D-09 로 마일스톤 끝의 `/gsd-map-codebase`), Backlog 999.1 (`VERSIONING.md` 30행의 전제 한 문장).

</domain>

<decisions>
## Implementation Decisions

### 이전에 확정되어 그대로 따르는 것

다시 논의하지 않았다. 출처는 ROADMAP.md / REQUIREMENTS.md / PROJECT.md / 01 ~ 05-CONTEXT.md / `VERSIONING.md` / `spike-findings-woody-lints` skill 이다.

- 릴리스 버전은 **2.0.0** 이고 tag 는 annotated `v2.0.0` 이다. 가장 큰 등급이 SDK 하한 상향(`^3.10.4` → `^3.13.0`, major)이다 (Phase 1 D8, `VERSIONING.md` 실제 사례)
- GSD 는 tag 를 만들지 않는다 (`git.create_tag: false`, D9). release tag 는 이 phase 에서 직접 만든다. 이 저장소의 `v` tag 는 패키지 릴리스(`vX.Y.Z`)에만 쓴다
- 한 번 올린 tag 는 옮기거나 지우지 않는다. 잘못이 발견되면 새 이름(`v2.0.1`)을 쓴다 (PROJECT.md Key Decisions — `v1.3.0` 의 선례)
- 릴리스 커밋에서 `pubspec.yaml` 의 `version: 2.0.0-dev` 를 `2.0.0` 으로, CHANGELOG 제목 `## 2.0.0 - 미출시` 의 `미출시` 를 날짜로 바꾼다 (01-CONTEXT.md D-07, 05-CONTEXT.md 의 하지 않는 것)
- CHANGELOG 제목은 `## X.Y.Z - YYYY-MM-DD` 이고 ` - ` 는 한 번만 쓴다. 일치 검사는 ` - ` 앞 토큰을 버전으로 읽는다 (`VERSIONING.md` 81 ~ 82행, 01-CONTEXT.md)
- tag push 와 `main` 병합은 원격에 남는 작업이라 **실행하기 직전에** 소유자 확인을 받는다 (ROADMAP 모든 phase 에 걸친 제약, Phase 6 Decision points). 같은 작업 브랜치의 push 는 지금까지처럼 실행한 뒤 보고한다 (05-CONTEXT.md D-21)
- push 하기 전에 그 범위 전체에 비공개 점검을 돌린다 — 비공개 `flutter_starter_kit` 의 파일 경로 · 기능 이름이 공개 저장소에 들어가지 않는다 (04-CONTEXT.md D-07, 05-CONTEXT.md D-21)
- 받은 뒤의 모양(3단 include 의 plugin 로드, 옛 주소 · 묶음 주소, 조합별 진단, 생성 파일 제외)은 git 의존성에서도 `path:` 와 줄 단위로 같다 (spike 015). smoke test 가 처음 보는 것은 "받아 오는 길"(실제 `https://github.com/…` 주소, 실제 tag, 인증)과 "lock 없이 처음 받는 경우", "나눈 구조를 실제 주소에서 받은 프로젝트" 다 (`git-dependency-and-upgrade.md` 5번 · Constraints)
- `main` 병합은 `ref: main` 프로젝트에 곧바로 닿지 않는다. 각 프로젝트가 `pub upgrade woody_lints` 를 할 때 닿는다 (spike 015 pub-4, `git-dependency-and-upgrade.md` 4번)
- 루트 `pubspec.yaml` 의 `version` 을 바꾸면 커밋된 lock 여섯(`example/` · `fixtures/` 의 다섯)이 어긋나 검증이 종료 코드 69 로 멈춘다. lock 을 다시 받아 같은 커밋에 넣는다 (02-VERIFICATION.md 7번, 02-REVIEW.md WR-06)
- `pubspec.yaml` 이 바뀐 뒤에는 `fvm dart pub get` 을 먼저 돌리고 `fvm dart run tool/verify.dart` 10/10 을 본다 (README 380행, 05 Round 2 G4-R2-Q2)
- plugin 진단 확인은 `dart analyze` 로 한다 (PROJECT.md Constraints)
- 지워 보기(일부러 깨뜨려 실패를 확인)는 `git clone --local` 복제본에서 하고 M-번호로 `example/README.md` 에 기록한다 (Phase 5 의 D-01 · D-02 · D-20). 마지막 번호는 M91 이다 (2026-10-15 확인)
- smoke test 는 `flutter create` 로 만든 빈 프로젝트에서 README 를 그대로 따라 한다 (`05-UAT.md` 1번, ROADMAP Phase 6 Notes)
- 문서 · 주석은 한국어로 쓰고 규칙명 · 키 · 명령은 영어 원문을 쓴다 (PROJECT.md Constraints)

### 릴리스 순서 · `main` 병합

- **D-01:** release tag 는 **작업 브랜치(`gsd/v2.0-package-rework`)의 릴리스 커밋**에 단다. 순서는 다음과 같다.
  1. 릴리스 커밋 — `-dev` 떼기 · CHANGELOG 날짜 · lock 여섯 · 미룬 손질
  2. 브랜치 push 와 CI 통과
  3. 로컬 일치 검사 (D-04)
  4. 예행 smoke test (D-07)
  5. annotated tag `v2.0.0` 을 만들고 push 한다 (직전 확인)
  6. CI 의 tag 실행을 확인한다
  7. tag 로 smoke test 를 한다
  8. `git ls-remote --tags origin` 로 확인한다
  9. `main` 병합 (D-02)
  — **Reversibility:** one-way — tag 를 push 하면 사용 프로젝트가 `ref: v2.0.0` 으로 그 커밋을 받을 수 있게 되고, 한 번 올린 tag 는 옮기지 않는다는 약속(공개 계약)이 걸린다
  - 이유: tag 를 달아 받아 보는 확인을 마친 뒤에 `main` 을 옮기므로, 문제가 보여도 `ref: main` 프로젝트 5개는 1.3.0 에 머문 채 `v2.0.1` 로 고칠 수 있다
  - 고르지 않은 안: `main` 에 먼저 합치고 병합 커밋에 tag. `pub upgrade` 한 프로젝트가 문제를 그대로 받는다
- **D-02:** `main` 병합은 **이 phase 안에서** tag 와 smoke test 뒤에 한다. `main` ← 작업 브랜치의 **PR 을 열어 merge commit (`--no-ff`) 으로** 합친다. squash 와 rebase 는 쓰지 않는다. — **Reversibility:** one-way — 합친 뒤에는 `ref: main` 프로젝트가 `pub upgrade` 때 2.0.0 을 받고, 되돌리려면 `main` 을 강제로 되감아야 한다
  - 이유: GitHub 의 "Squash and merge" 와 "Rebase and merge" 는 커밋 번호를 새로 만든다. 그러면 tag 를 단 커밋이 `main` 의 이력에 남지 않는다. merge commit 은 브랜치의 커밋을 그대로 남긴다 (GitHub Docs — about merge methods, 2026-10-15 읽음). 지금 origin 의 `main` (`90a2736`) 은 작업 브랜치의 조상이다
  - 고르지 않은 안: PR 없이 로컬 fast-forward + push (PR 확인을 "해당 없음" 으로 닫게 된다). 병합을 `/gsd-complete-milestone` 에 맡기기 (Phase 2 의 미룬 확인 둘이 마일스톤 끝으로 밀리고, 그 단계의 권고는 squash 다)
- **D-03:** Phase 2 에서 미룬 확인 둘을 이 phase 에서 닫는다.
  - (4번) PR 을 연 직후 Actions 탭에 `pull_request` event 의 `verify` 실행이 생기고 통과하는지 본다
  - (6번) 병합으로 workflow 파일이 `main` 에 들어간 뒤 Actions → verify 화면에 `Run workflow` 버튼이 보이고, 누르면 `workflow_dispatch` event 의 실행이 생겨 통과하는지 본다
  - 수동 실행 버튼은 workflow 파일이 기본 브랜치에 있어야 동작한다 (GitHub Docs, community discussion #178194)

### 버전 일치 검사 (REL-03)

- **D-04:** 검사는 세 자리에서 돈다.
  - (1) **평소 push** — `pubspec.yaml` 의 version 에서 `-dev` 같은 꼬리를 뗀 값이 CHANGELOG 최상단 제목의 버전과 같은지 본다
  - (2) **tag push (CI)** — tag 이름에서 `v` 를 뗀 값, `pubspec.yaml` 의 version(꼬리 없이 정확히), CHANGELOG 최상단 버전 셋이 같은지 본다
  - (3) **tag 를 달기 전 로컬** — (2) 와 같은 검사에 달 tag 이름을 주고 먼저 돌린다. 릴리스 절차의 한 단계다
  - 이유: CI 의 tag 실행은 tag 가 공개된 **뒤**에 돈다. 그때의 실패는 경보일 뿐이고 고치는 길은 `v2.0.1` 뿐이다. (3) 이 공개 전에 막는다. (1) 은 다음 버전을 준비할 때 CHANGELOG 의 `미출시` 항목을 빠뜨린 것을 바로 잡는다. Dart 팀의 firehose 가 같은 짜임이다 — PR 마다 changelog 버전 = pubspec 버전, tag push 때 tag 의 꼴 (pub.dev/documentation/firehose, 2026-10-15 읽음)
  - 지금 상태(`2.0.0-dev` · `## 2.0.0 - 미출시`)는 (1) 을 통과한다
  - 고르지 않은 안: tag push 와 로컬만 (준비 중의 어긋남이 릴리스 때에야 보인다). tag push 의 CI 만 (공개 뒤의 경보뿐)
- **D-05:** tag 검사((2) · (3))는 CHANGELOG 최상단 제목의 날짜 자리가 `YYYY-MM-DD` 꼴이 아니면 실패로 본다. `미출시` 도 여기서 걸린다. 날짜가 tag 를 단 날과 같은지는 보지 않는다.
  - 이유: 01-CONTEXT.md 가 미룬 "`미출시` 를 거부할지" 의 답이다. tag 날짜와의 일치는 시간대 때문에 하루가 어긋날 수 있다
  - 고르지 않은 안: tag 날짜와도 견주기. 날짜 자리를 보지 않기 (`미출시` 인 채로 tag 를 달 수 있다)
- **D-06:** "일부러 어긋나게 만든 입력에서 실패" (성공 기준 1)는 **로컬 복제본의 지워 보기**로 보인다. 입력은 다섯이다.
  - tag 이름만 다르다
  - `pubspec.yaml` 에 `-dev` 가 남았다
  - CHANGELOG 버전만 다르다
  - CHANGELOG 날짜 자리가 `미출시` 다
  - tag 이름이 `v` + 버전 꼴이 아니다

  각각 검사 명령의 실패를 M92 부터의 번호로 `example/README.md` 에 기록한다. CI 의 tag 트리거가 이 검사를 실제로 부르는지는 진짜 `v2.0.0` push 의 실행 로그(통과 쪽)로 확인한다.
  - 이유: 원격에 시험용 tag 를 올리는 길은 "올린 tag 는 옮기거나 지우지 않는다" 와 부딪치고, 공개 저장소에 흔적이 남는다
  - 고르지 않은 안: 원격 시험 tag. 둘 다

### smoke test (REL-04)

- **D-07:** **예행을 한다.** 릴리스 커밋을 브랜치 push 한 뒤, 빈 프로젝트가 `ref: <그 커밋의 번호>` 로 GitHub 에서 받아 D-09 의 판정을 먼저 본다. 통과하면 **바로 그 커밋**에 tag 를 달고, `ref: v2.0.0` 으로 한 번 더 본다.
  - 이유: 처음 재는 길(실제 주소)을 되돌릴 수 없는 일(tag) 앞에서 먼저 본다. pub 은 `ref:` 에 커밋 번호 · 브랜치 · tag 를 모두 받고, annotated tag 도 lock 에는 그 tag 가 가리키는 커밋의 번호를 적는다 (dart.dev — Git packages, spike 015 pub-7, pub 변경 #4707). 그래서 예행과 tag 실행은 같은 커밋을 받는다
  - 예행에서 README 를 따라 하다 막히는 자리가 나오면, README 를 고친 커밋으로 예행을 다시 하고 그 커밋에 tag 를 단다
  - 고르지 않은 안: tag 뒤에 한 번만 (실패하면 `v2.0.1` 로만 고친다)
- **D-08:** 받을 주소는 **둘 다**다 — 정식 이름 `package:woody_lints/recommended.yaml` (README 가 새 프로젝트에 안내하는 이름) 과 옛 이름 `package:woody_lints/analysis_options.yaml` (사용 프로젝트 5개가 지금 쓰는 이름). 같은 빈 프로젝트에서 옵션 파일의 include 만 바꿔 두 번 분석한다.
  - 고르지 않은 안: `recommended.yaml` 만. 다섯 주소 모두 (나머지 조합은 015 가 로컬 git 으로 쟀다)
- **D-09:** 통과 기준은 세 가지가 모두 성립하는 것이다.
  - (1) `flutter create` 로 만든 빈 프로젝트에 README 를 그대로 따라 한다
  - (2) `example/` 의 샘플에서 옮긴 일부러 넣은 위반(기본 규칙 위반 하나, `riverpod_lint` 위반 하나)이 두 주소 각각에서 둘 다 보고된다
  - (3) 받은 프로젝트의 `pubspec.lock` 에 적힌 `woody_lints` 의 `resolved-ref` 가 tag 가 가리키는 커밋(`git rev-parse 'v2.0.0^{commit}'`)과 같다
  - 이유: 커밋이 같으면 내용은 git 이 보장한다. 정답지 93줄을 다시 견주는 것은 015 가 본 것의 되풀이다. `example/` 의 정답지에는 `pubspec.yaml` · `lib/main.dart` 줄이 있어 `flutter create` 프로젝트에서는 그대로 나오지 않는다
  - 고르지 않은 안: `example/` 을 통째로 받는 쪽으로 복사해 정답지 93줄과 줄 단위로 견주기 (README 따라 하기가 아니다). 둘 다
- **D-10:** smoke test 는 **`tool/` 아래 스크립트 하나로 커밋**한다. ref 를 받아 저장소 밖 임시 폴더에서 다음을 하고 판정한다.
  - `flutter create`
  - README 대로 고치기
  - 새 pub cache 로 받기
  - 두 주소로 `dart analyze`

  `tool/verify.dart` (평소 CI 의 검증 명령)에는 넣지 않고, CI job 도 더하지 않는다. 이번 예행 때 README 를 사람이 그대로 따라 해 보는 확인(05-UAT 1번)은 한 번 손으로 하고, 그 결과로 스크립트의 단계를 맞춘다.
  - 이유: 이번에만 두 번(예행, tag), 앞으로 릴리스마다 돌리는 확인이다. smoke test 는 GitHub 과 네트워크에 기대므로 평소 push 마다 돌 일이 아니다. 판정은 D-09 하나로 좁혀 코드를 작게 둔다
  - 알고 고른 대가: 새 코드라 리뷰 · 검증 대상이 늘어난다. 스크립트가 README 의 단계를 코드로 옮겨 적은 것이라 README 가 바뀌어도 스스로 알아채지 못한다
  - 고르지 않은 안: 손으로 돌리고 기록만. CI 에 tag push 때 도는 job (tag 공개 뒤의 경보)

### 릴리스 절차 문서

- **D-11:** 번호를 붙인 릴리스 절차는 **`VERSIONING.md` 의 새 절 「릴리스 절차」** 에 적는다. README 「이 저장소를 고치는 사람에게」 의 `VERSIONING.md` 안내 줄(381행)에 "릴리스 절차" 를 덧붙인다.
  - 이유: 첫 단계(등급 정하기)와 CHANGELOG 형식이 이미 같은 파일에 있어, 릴리스 때 열 파일이 하나다. 01-CONTEXT.md 가 미룬 "절차 문서의 자리" 의 답이다
  - 고르지 않은 안: 새 `RELEASING.md`. README 「이 저장소를 고치는 사람에게」 에 단계 목록 (`[3/10]` 이 README 를 읽어 검사 범위에도 걸린다)
- **D-12:** 절차에 담는 범위는 다음과 같다.
  - (1) 이번에 실제로 밟는 단계 전부 (D-01 의 순서, 직전 확인 두 자리 포함)
  - (2) **lock 은 `fvm dart pub get` 으로만** 다시 받는다 — `example/` 과 `fixtures/` 다섯, `pub upgrade` 는 하지 않는다
  - (3) "plugin 새 버전 때문에 정답지가 저절로 깨졌을 때" 의 대응 한 단락

  릴리스마다 `example/` · 연습용 프로젝트의 `pub upgrade` 를 하는 단계는 넣지 않는다.
  - 이유: `pub get` 은 lock 에 적힌 버전을 가능한 한 쓰므로 woody_lints 항목만 바뀌고 다른 패키지는 그대로라 정답지가 흔들리지 않는다 (dart.dev — pub get). (2) 는 02-CONTEXT.md 가 미룬 "릴리스 절차에 `example/` 의 `pub upgrade` 단계를 넣을지" 의 답, (3) 은 03-CONTEXT.md 가 미룬 것의 답이다
  - 고르지 않은 안: 위 + 릴리스마다 `pub upgrade` (정답지 변경이 릴리스와 섞인다). 단계 + lock 만 (plugin 대응을 다시 미룬다)

### 미룬 손질 (release tag 전에 닫는다)

- **D-13:** IN-14 (`loadYaml` 이 `x: !!float i` 같은 한 글자 `!!float` 값에서 `RangeError`, 아주 깊은 flow 중첩에서 `StackOverflowError` 를 던져 main 을 지나 종료 코드 255) 는 **주석 · 문장만** 고친다.
  - `compareLineReadersWithYaml` 문서 주석(`tool/verify.dart` 1986행 "그 밖의 예외는 지금처럼 main 이 받는다")과 머리 주석의 종료 코드 목록(25행)에 이 경우를 적는다
  - `example/README.md` 620행의 "…깨진 YAML)도 블록 하나로 실패한다" 를 실제 범위로 좁힌다
  - 코드는 그대로 둔다
  - 이유: 이미 막는 쪽이다(통과로 끝나지 않는다). PROJECT.md Key Decision "검사가 보지 않는 꼴은 검사를 넓히지 않고 문장을 실제 범위로 좁힌다" 와 같은 길이다. `Error` 를 잡는 catch 는 이 패키지가 사용 프로젝트에 켜는 `avoid_catching_errors` 의 취지와 어긋난다
  - 고르지 않은 안: catch 를 더해 그 오류도 (h) 실패 블록으로
- **D-14:** 05-UAT 1번은 **문장 + 한 번 재기**로 닫는다.
  - README 「설치」 · 「생성 파일 제외」 · 「프로젝트 전체」 에 "기존 `include` 줄은 바꾸고, 이미 있는 `analyzer:` · `linter:` 키에는 합친다" 는 뜻의 문장을 넣는다. Flutter 3.47.5 앱 템플릿(`packages/flutter_tools/templates/app/analysis_options.yaml.tmpl`, 2026-10-15 읽음)의 옵션 파일에 이미 `include: package:flutter_lints/flutter.yaml`, `analyzer: exclude:` (`build/**` 와 플랫폼 폴더), 빈 `linter: rules:` 가 있다
  - `base.yaml` 만 받는 프로젝트가 「프로젝트 전체」 의 `plugins:` 블록을 붙였을 때 plugin 이 켜지는지는 예행(D-07) 때 한 번 재고, 결과대로 「프로젝트 전체」 에 한 문장을 단다. 지금은 추론이다 — spike 012 가 묶음을 받은 프로젝트에서 잰 "같은 이름의 선언이 통째로 바뀐다" (`suppression-and-exclude.md` 2번)에서 읽은 것이고, `riverpod.yaml` 을 받지 않는 프로젝트에서는 재지 않았다
  - 고르지 않은 안: 문장만 (`plugins:` 쪽은 재지도 적지도 않음). 예행 결과만 (미리 넣지 않음)
- **정한 대로 고치는 다섯** (ROADMAP Phase 6 Notes, 소유자 결정 2026-10-15 — 다시 묻지 않았다)
  - IN-12: `lib/base.yaml` 의 `include:` 값을 다음 줄에 쓰면 `[3/10]` (h) 만 거짓 실패한다. 고칠 자리는 `tool/verify.dart` 1879행 `keysSeenByLineReader` 하나다 — 값 없는 최상위 키 아래의 스칼라 값 줄을 "아래 키" 로 담지 않게 한다 (05-REVIEW-DISPOSITION 의 "길 B 안")
  - IN-13: `pubspec.yaml` 13 ~ 15행의 `dependencies` 주석이 기반 세트를 include 하는 파일을 `lib/analysis_options.yaml` 로 적는다. `lib/base.yaml` 로 고치고, version 을 바꾸는 커밋에서 함께 한다
  - 05-UAT 2번: README 355행 "`plugins:` 를 바꾼 뒤 … Analysis Server 를 재시작해야 반영된다" 에 출처를 표시한다 — 1.3.0 의 주석에서 옮긴 문장이고 spike 에 재시작 실측이 없다
  - 05-UAT 4번: README 34행을 사실대로 고친다 — flutter#191151 은 2026-08-19 에 병합됐고 stable 판 #191530 이 Flutter 3.47.2 부터 들어 있다 (3.47.5 의 동작이 이미 이것). 바뀐 것은 "있는 플랫폼 폴더만 제외 · Flutter 가 아닌 패키지는 건너뜀" 이고 `build/**` 는 그대로 덧붙이며 끄는 옵션은 없다. "(병합 여부는 확인하지 않았다)" 구절을 뺀다
  - 05-UAT 5번: `example/README.md` 620행의 "YAML (package:yaml — analyzer · pub 과 같은 해석기)" 에 "(판이 같은지는 재지 않았다)" 를 덧붙인다
  - `tool/verify.dart` · `pubspec.yaml` · README · `example/README.md` 를 고친 뒤에는 `fvm dart run tool/verify.dart` 10/10 과 고친 자리의 실패 방향을 다시 본다

### 묻지 않고 잡은 것

항목마다 질문 앞에 보였고, 소유자가 항목 끝 확인에서 "다음 항목" · "CONTEXT 를 써 주세요" 를 골랐다. 소유자가 반대하지 않았다. 명시적으로 고른 선택지는 아니다 (02-CONTEXT.md D-12 의 선례와 같은 표기).

- tag 커밋에는 `.planning/` 이 그대로 실린다. 2026-10-15 의 추적 파일은 약 12MB 이고 그중 `.planning/` 이 약 8.5MB 다. git 의존성은 저장소 전체를 받으므로 사용 프로젝트의 pub cache 에도 들어간다. 빼려면 사본 브랜치가 필요한데 Phase 2 D-10 이 그 길을 고르지 않았다
- 아직 origin 에 없는 커밋(2026-10-15 에 14개)과 릴리스 커밋은 같은 작업 브랜치에 push 하고 실행한 뒤 보고한다 (D-21). tag push 와 `main` 병합만 직전 확인이다
- D-02 로 합친 뒤 `/gsd-complete-milestone` 이 병합을 다시 제안하면 "Keep branches" 로 넘긴다. 이미 합친 브랜치를 squash 로 또 합치지 않는다
- 일치 검사는 검증 단계를 새로 더하지 않고 기존 `[3/10]` 안의 확인으로 넣는다. 새 단계를 더하면 `example/README.md` 의 `[n/10]` · `10/10` 표기 약 410곳이 바뀐다 (2026-10-15 grep)
- tag 이름이 `v` + 버전 꼴이 아니면 tag 검사는 실패로 본다. 이 저장소의 `v` tag 는 패키지 릴리스 전용이고 (D9), 다른 tag 는 쓰지 않는다
- README 의 `ref: v2.0.0` 은 `[3/10]` (g) 가 이미 pubspec 의 버전(꼬리를 뗀 값)과 견주므로, tag = pubspec 이 성립하면 README 도 맞는다. 일치 검사가 README 를 따로 보지 않는다
- smoke test 는 새 pub cache(`PUB_CACHE`)와 새 analyzer 상태 폴더(`ANALYZER_STATE_LOCATION_OVERRIDE`)로 돌린다. 평소 cache 를 쓰면 GitHub 에서 실제로 받았는지 알 수 없다 (019 의 교훈, `git-dependency-and-upgrade.md` 1번)
- 받는 주소는 README 의 `https://github.com/woodkill/woody_lints.git` 그대로이고 인증 없이 받는다 (공개 저장소)
- 빈 프로젝트와 pub cache 는 저장소 밖 임시 폴더에 만든다. 저장소 안에 아무것도 만들지 않는다
- 결정이 끝난 손질 다섯(IN-12 · IN-13 · UAT 2 · 4 · 5번)은 위 "정한 대로 고치는 다섯" 대로 고친다
- `.claude/CLAUDE.md` 의 낡은 줄(05-REVIEW WR-06 · 261행)은 계속 마일스톤 끝 `/gsd-map-codebase` 로 미룬다 (D-09). 그 파일의 "루트 exclude 를 유지해야 한다" 지시는 이미 걷어낸 것이므로 따르지 않는다 (STATE.md Blockers)
- Backlog 999.1 은 이 phase 에 끼우지 않는다 (D-11 로 같은 `VERSIONING.md` 를 고치게 되어 소유자에게 끼울 수 있다고 알렸고, 끼우라는 답은 없었다)

### Claude's Discretion

- smoke 스크립트의 이름 · 인자 · 출력 모양 (예: `tool/smoke.dart <ref>`), 위반 두 줄을 어느 샘플에서 옮길지 (`example/lib/base_rules.dart` · `example/lib/riverpod_rules.dart` 후보)
- `tool/verify.dart` 가 tag 이름을 받는 방식 — 명령 인자(로컬 (3))와 GitHub 의 `GITHUB_REF_TYPE` · `GITHUB_REF_NAME` (CI (2)) 중 무엇을 어떻게 쓸지, workflow 를 고칠지. 고친다면 `push:` 의 필터 없음(모든 브랜치와 tag)은 그대로 둔다 (workflow 5 ~ 7행 주석의 경고)
- 커밋 나누기 — 릴리스 커밋(version · CHANGELOG 날짜 · lock 여섯 · IN-13)과 손질 · 검사 · 스크립트 커밋의 순서. 단, tag 를 달 커밋은 예행이 통과한 커밋이어야 한다 (D-07)
- smoke 결과 · tag push · ls-remote 증거의 기록 형식 — Phase 1 의 tag 증거 형식(push 출력 + `ls-remote --tags` / `--heads` 원문 + 날짜, `01-01-SUMMARY.md`)을 다시 쓸 수 있다
- 「릴리스 절차」 절의 문장과 "plugin 새 버전에 정답지가 깨졌을 때" 단락의 내용 — 화면의 `plugin` 줄로 원인을 가르는 법, `--update` 를 쓰는 조건 등은 연구 · 계획이 정한다
- CHANGELOG 2.0.0 의 날짜 — tag 를 다는 날로 적되, 예행 뒤 날짜가 바뀌면 릴리스 커밋을 다시 만드는 대신 그 날짜 그대로 둘지는 계획이 정한다 (D-05 는 꼴만 본다)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 범위와 요구사항
- `.planning/ROADMAP.md` § "Phase 6: Release" (311 ~ 345행) — 목표, 성공 기준 1 ~ 3, Decision points, Notes (Phase 2 · 5 에서 미룬 것)
- `.planning/REQUIREMENTS.md` — REL-02 · REL-03 · REL-04 (69 ~ 71행), Out of Scope
- `.planning/PROJECT.md` — Constraints, Key Decisions (tag 정책, milestone 브랜치, IN-12 ~ 14 · UAT 손질은 tag 전에)
- `.planning/STATE.md` § Blockers/Concerns — `[Phase 6]` 세 줄, `[Phase 5]` 의 CLAUDE.md 지시 무시

### 앞 phase 에서 넘어온 것
- `.planning/phases/01-baseline-and-toolchain/01-CONTEXT.md` — D-07 (`-dev`), Deferred 의 "`미출시` 를 거부할지" · "릴리스 절차 문서" (267 ~ 268행)
- `.planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md` — tag push 증거 형식 (smoke test 가 재사용)
- `.planning/phases/02-verification-harness/02-CONTEXT.md` — D-06 (수동 실행 버튼), D-10 과 덧붙임 (tag push 에서도 도는 `push:`), Deferred 276 ~ 277행
- `.planning/phases/02-verification-harness/02-VERIFICATION.md` — "다음 phase 가 알아야 할 것" 7번 (version 을 올리면 exit 69), 사람 확인 4 · 6 (384 · 398행 부근)
- `.planning/phases/02-verification-harness/02-UAT.md` — 4번 · 6번 (Phase 6 로 미룬 확인)
- `.planning/phases/03-preset-split/03-CONTEXT.md` — Deferred 281행 (plugin 새 버전에 정답지가 깨졌을 때의 절차)
- `.planning/phases/05-documentation/05-REVIEW.md` — IN-12 · IN-13 · IN-14 (349행부터가 IN-14)
- `.planning/phases/05-documentation/05-REVIEW-DISPOSITION.md` — IN-12 ~ 14 deferred 의 결정 문구 (144 ~ 146행)
- `.planning/phases/05-documentation/05-UAT.md` — 1 · 2 · 4 · 5번 (문서 손질 넷)
- `.planning/phases/05-documentation/05-CONTEXT.md` — D-02 (4) README `ref:` 비교, D-20 지워 보기, D-21 push 규칙

### 실측 근거 (spike)
- `.claude/skills/spike-findings-woody-lints/SKILL.md` — 전체 요약. 특히 "받는 쪽 / 받아 오는 길" 의 구분
- `.claude/skills/spike-findings-woody-lints/references/git-dependency-and-upgrade.md` — 5번 "릴리스와 smoke test 가 볼 것", 6번 "올리지 않고 git 의존성을 재는 방법" (`PUB_CACHE`, 받는 쪽은 replica 밖), Constraints 의 재지 않은 목록
- `.claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md` — `dart analyze` 실행 형태, plugin 준비 실패 판정, 상태 폴더
- `.claude/skills/spike-findings-woody-lints/references/ci-workflow.md` — workflow 의 trigger · action 버전 · 수동 실행 버튼의 조건
- `.claude/skills/spike-findings-woody-lints/references/suppression-and-exclude.md` — 2번 78행 ("같은 이름의 선언이 통째로 바뀐다. 적은 값이 그 프로젝트의 plugin 버전 선언이 된다" — D-14 의 추론 근거, 묶음을 받은 프로젝트에서 잰 것), 7번 (README 에 적을 것)
- `.claude/skills/spike-findings-woody-lints/sources/015-git-dependency-preset-load/probe.dart` — git 의존성 받는 쪽 만들기 · lock 항목 읽기 (`Consumer.lockEntry`) · 실험용 pub cache

### 고칠 파일과 검증 명령
- `tool/verify.dart` — `[3/10]` (g) README `ref:` ↔ `pubspecReleaseVersion` (1597행), (h) `compareLineReadersWithYaml` (1975 ~ 2040행), `keysSeenByLineReader` (1879행), 머리 주석의 종료 코드 목록 (25행), main (2807행)
- `.github/workflows/verify.yml` — 필터 없는 `push:` · `pull_request:` · `workflow_dispatch:`, 5 ~ 7행의 Phase 6 경고 주석
- `pubspec.yaml` — `version: 2.0.0-dev` (3행), 13 ~ 15행 주석 (IN-13)
- `CHANGELOG.md` — 1행 `## 2.0.0 - 미출시`
- `VERSIONING.md` — 81 ~ 82행 (제목 형식과 REL-03), 67 ~ 70행 (2.0.0 실제 사례), 새 「릴리스 절차」 절의 자리
- `README.md` — 「설치」 (9 ~ 35행, 34행 = UAT 4번), 「프로젝트 전체」 (220행), 「생성 파일 제외」 (282행), 355행 (UAT 2번), 「이 저장소를 고치는 사람에게」 (376 ~ 382행)
- `example/README.md` — 116행 (단계 목록), 620행 (UAT 5번 · IN-14 문장), 지워 보기 표 (마지막 M91)
- `example/pubspec.lock`, `fixtures/{base_codegen,base_only,base_riverpod,overrides,recommended}/pubspec.lock` — version 을 바꾸면 다시 받는 lock 여섯

### 지시문
- `.claude/CLAUDE.md` — 프로젝트 지시. 단, 루트 `analysis_options.yaml` exclude 를 유지하라는 줄(70 · 173 · 313행)과 `.fvmrc` 3.41.2 기재는 낡았다 (05-REVIEW WR-06, D-09)

### 논의에서 참고한 외부 문서 (2026-10-15 읽음)
- https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/about-merge-methods-on-github — merge commit 은 `--no-ff`, rebase and merge 는 항상 새 커밋 번호, 순수 fast-forward 버튼 없음 (D-02)
- https://help.github.com/articles/configuring-a-workflow · https://github.com/orgs/community/discussions/178194 — `workflow_dispatch` 는 workflow 가 기본 브랜치에 있어야 함 (D-03)
- https://pub.dev/documentation/firehose/latest/ — PR 마다 changelog = pubspec, tag push 때 tag 꼴 (D-04)
- https://dart.dev/go/automated-publishing — tag 의 버전과 pubspec version 이 같아야 함 (D-04)
- https://dart.dev/tools/pub/dependencies (Git packages) · https://dart.googlesource.com/pub.git/+/65e289b95%5E%21 — `ref:` 는 커밋을 가리키는 무엇이든, tag 는 가리키는 커밋의 번호로 풂 (D-07)
- https://dart.dev/tools/pub/cmd/pub-get — lock 이 있으면 적힌 버전을 가능한 한 씀 (D-12)
- https://git.phyllo.me/devops/action-gh-release/src/tag/v3/RELEASE.md · https://chromium.googlesource.com/external/github.com/google/benchmark/+show/8aae0a4/docs/releasing.md — 번호 붙은 릴리스 절차 예시 (D-11)

</canonical_refs>

<code_context>
## Existing Code Insights

### 논의 시점의 저장소 상태 (2026-10-15 확인)
- origin: `main` = `90a2736` (1.3.0), 작업 브랜치 `gsd/v2.0-package-rework` = `2336ba0`, tag 는 `v1.3.0` 하나 (`80e2112` → `90a2736`). PR 0건, `main` 보호 설정 없음, merge / squash / rebase 셋 다 허용 (`gh repo view`, `gh api …/branches/main/protection` 404)
- 로컬 `HEAD` = `d926186`, origin 의 작업 브랜치보다 14커밋 앞 (Phase 5 마무리 기록). `origin/main` 은 `HEAD` 의 조상이다
- `pubspec.yaml`: `version: 2.0.0-dev`, `sdk: ^3.13.0`, `dependencies: flutter_lints ^6.0.0`, `dev_dependencies: yaml ^3.1.4`
- CHANGELOG 1행 `## 2.0.0 - 미출시`. README 의 `ref: v2.0.0` 은 18행 · 333행
- `example/expected_diagnostics.txt` 는 머리 주석 뒤 `exit 2` + 93줄이다 (그중 `pubspec.yaml` 1줄, `lib/main.dart` 1줄, `riverpod_lint` 3줄)
- `example/pubspec.yaml` 은 `flutter_riverpod: ^3.0.0` 을 받고 woody_lints 는 `dev_dependencies` 의 `path: ..` 다

### Reusable Assets
- `tool/verify.dart` 의 `pubspecReleaseVersion` (1597행 — 꼬리를 뗀 major.minor.patch) 과 `[3/10]` (g) — 일치 검사가 pubspec 쪽 값을 이미 읽는다. `splitYamlLines` (줄 나누기 도우미), (h) 의 `package:yaml` 대조
- spike 015 의 `probe.dart` — 받는 쪽 `pubspec.yaml` 에 git 의존성 선언 넣기, `PUB_CACHE` 를 작업 폴더로, lock 의 `woody_lints` 항목(`resolved-ref`) 읽기
- spike 공용 `replica.dart` (`sources/009-preset-plugin-via-include/`) — 저장소 모양을 작업 폴더에 복사
- `example/lib/base_rules.dart` · `example/lib/riverpod_rules.dart` — smoke test 의 일부러 넣은 위반을 옮길 후보
- Flutter 3.47.5 의 `packages/flutter_tools/templates/app/analysis_options.yaml.tmpl` — `flutter create` 가 만드는 옵션 파일의 원본

### Established Patterns
- 지워 보기: `git clone --local` 복제본에서 깨뜨리고, 종료 코드 · 화면 줄을 M-번호 표로 `example/README.md` 에 기록 (M1 ~ M91)
- 검증 명령의 종료 코드: 0 통과 / 1 단계 실패 / 64 사용법 / 69 pub get 실패 / 70 예외 (머리 주석 25행). 규칙 · 버전 같은 값의 어긋남은 단계 실패(1)로 낸다
- 원격 작업: 같은 브랜치 push 는 실행 뒤 보고(D-21), tag push · `main` 병합은 직전 확인, push 전 범위 전체 비공개 점검
- 실측 문장에는 SDK 버전과 날짜를 붙이고, 재지 않은 것은 "재지 않았다" 고 적는다

### Integration Points
- `.github/workflows/verify.yml` 은 필터 없는 `push:` 라 tag push 에서도 `dart run tool/verify.dart` 가 돈다. concurrency group 이 `github.ref` 라 tag 실행은 브랜치 실행과 따로 돈다. tag 검사는 이 실행 안에서 tag 인지 알아야 한다
- `[3/10]` 이 README 를 읽으므로, D-14 · UAT 2 · 4번의 README 손질은 표시 구역과 (d) ~ (g) 의 검사 범위를 지나간다 — 고친 뒤 10/10
- `VERSIONING.md` 의 새 절은 `[3/10]` 이 읽지 않는다 (2026-10-15 기준 README · `RULES.md` · 배포 YAML · pubspec 만 읽음)

</code_context>

<specifics>
## Specific Ideas

### Flutter 3.47.5 앱 템플릿의 옵션 파일 (D-14 의 재료 — 2026-10-15 읽음)

주석 줄을 뺀 내용이다. `{{…}}` 는 템플릿 조건이다.

```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  exclude:
    - build/**
    - android/**   # {{#android}} 등 플랫폼별 조건
    - ios/**
    - web/**
    - windows/**
    - macos/**
    - linux/**
linter:            # {{^withEmptyMain}} 일 때
  rules:
```

### 소유자와 소통하는 방식
- 질문마다 용어 풀이 → 찾아본 것(출처) → 비교표 → 굵은 `권고:` 를 두었고, 소유자는 결정 질문 12개 모두에서 권고안을 골랐다
- 항목 끝 확인은 그 항목의 마지막 질문과 같은 호출에 묶었다. 네 번 모두 "다음 항목" · "CONTEXT 를 써 주세요" 였다

</specifics>

<deferred>
## Deferred Ideas

- **Backlog 999.1** — `VERSIONING.md` 30행에 "plugin · 기반 세트 하한을 올릴 때 새 하한이 요구하는 Dart 버전을 본다" 전제 한 문장. D-11 로 같은 파일을 고치지만 이 phase 에 끼우지 않았다 (backlog 그대로)
- **`.claude/CLAUDE.md` 의 낡은 줄** (05-REVIEW WR-06 · 261행) — 마일스톤 끝 `/gsd-map-codebase` (D-09)
- **GitHub tag ruleset** (tag 의 수정 · 삭제를 막는 저장소 설정) — 조사 중에 본 것이고 논의하지 않았다. "올린 tag 는 옮기지 않는다" 를 사람의 약속에서 저장소 설정으로 옮기는 새 기능이다. GitHub 문서는 ruleset 을 Team · Enterprise 플랜 기준으로 적고 있어, 공개 저장소의 Free 플랜에서 되는지는 확인하지 않았다
- **CI 의 tag push 때 도는 smoke job** — D-10 에서 고르지 않았다. GitHub Linux runner 에서 받아 오는 길은 이번에도 재지 않는다 (`git-dependency-and-upgrade.md` Constraints 의 "GitHub Linux runner 에서의 같은 실행")
- **측정 도구의 재측정 전 수정** (RULES-13 의 CR-03 · WR-09) — v2
- **고정 SDK 를 Dart 3.14 계열로 올리기** — Phase 6 이후. 올리기 전에 spike 016 의 두 스크립트를 그 SDK 로 돌린다 (`next-sdk-forward-compat.md`)

</deferred>

---

*Phase: 06-release*
*Context gathered: 2026-10-15*
