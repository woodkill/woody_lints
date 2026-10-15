# Phase 6: Release - Research

**Researched:** 2026-10-15
**Domain:** 설정 전용 패키지의 릴리스 — annotated tag `v2.0.0` 로 git 의존성 고정, tag · `pubspec.yaml` · CHANGELOG 버전 일치 검사(REL-03)를 기존 검증 명령 `[3/10]` 에 넣기, 저장소 밖 빈 프로젝트에서 GitHub 주소로 받는 smoke test 스크립트(REL-04), 릴리스 절차 문서, 앞 phase 에서 미룬 손질 다섯과 IN-12 · IN-14
**Confidence:** HIGH — 조사 대상의 거의 전부가 이 저장소 안의 파일(`tool/verify.dart`, `pubspec.yaml`, `CHANGELOG.md`, `VERSIONING.md`, `README.md`, `example/README.md`, `.github/workflows/verify.yml`, spike references)이고 이 세션에서 `Read` · `sed` · `grep` 으로 직접 읽었다. 핵심 동작 넷 — (1) 일치 검사 다섯 입력의 실패, (2) IN-12 고친 판, (3) version 변경 뒤 종료 코드 69 와 lock 여섯 다시 받기, (4) `flutter create` 빈 프로젝트가 GitHub 주소에서 작업 브랜치 커밋을 새 pub cache 로 받아 두 주소로 분석 — 는 저장소 밖 복제본 · 임시 폴더에서 실제로 돌렸다 (Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, 2026-10-15). 바깥에서 가져온 것은 GitHub Actions 환경변수 문서(이 세션에서 읽음 — `[CITED]`)와 CONTEXT 가 이미 읽은 외부 문서(merge methods, workflow_dispatch, firehose — 다시 열지 않았다)다.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### 이전에 확정되어 그대로 따르는 것

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

#### 릴리스 순서 · `main` 병합

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

#### 버전 일치 검사 (REL-03)

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

#### smoke test (REL-04)

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

#### 릴리스 절차 문서

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

#### 미룬 손질 (release tag 전에 닫는다)

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

#### 묻지 않고 잡은 것

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

### Deferred Ideas (OUT OF SCOPE)

- **Backlog 999.1** — `VERSIONING.md` 30행에 "plugin · 기반 세트 하한을 올릴 때 새 하한이 요구하는 Dart 버전을 본다" 전제 한 문장. D-11 로 같은 파일을 고치지만 이 phase 에 끼우지 않았다 (backlog 그대로)
- **`.claude/CLAUDE.md` 의 낡은 줄** (05-REVIEW WR-06 · 261행) — 마일스톤 끝 `/gsd-map-codebase` (D-09)
- **GitHub tag ruleset** (tag 의 수정 · 삭제를 막는 저장소 설정) — 조사 중에 본 것이고 논의하지 않았다. "올린 tag 는 옮기지 않는다" 를 사람의 약속에서 저장소 설정으로 옮기는 새 기능이다. GitHub 문서는 ruleset 을 Team · Enterprise 플랜 기준으로 적고 있어, 공개 저장소의 Free 플랜에서 되는지는 확인하지 않았다
- **CI 의 tag push 때 도는 smoke job** — D-10 에서 고르지 않았다. GitHub Linux runner 에서 받아 오는 길은 이번에도 재지 않는다 (`git-dependency-and-upgrade.md` Constraints 의 "GitHub Linux runner 에서의 같은 실행")
- **측정 도구의 재측정 전 수정** (RULES-13 의 CR-03 · WR-09) — v2
- **고정 SDK 를 Dart 3.14 계열로 올리기** — Phase 6 이후. 올리기 전에 spike 016 의 두 스크립트를 그 SDK 로 돌린다 (`next-sdk-forward-compat.md`)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| REL-02 | 새 버전의 annotated tag 가 원격에 있어, 사용 프로젝트가 `ref: vX.Y.Z` 로 버전을 고정할 수 있다 | § 8 (tag 명령 · `ls-remote` 증거 형식 · PR 병합 · 직전 확인 자리), § 5 (version 변경 → lock 여섯), § 1 (3) 로컬 tag 검사 |
| REL-03 | tag, `pubspec.yaml` 의 version, CHANGELOG 최상단 버전이 서로 다르면 CI 가 실패한다 | § 1 (`[3/10]` 안의 자리 · CHANGELOG 읽기 · tag 이름을 받는 법 · workflow 는 그대로), § 2 (D-06 다섯 입력의 실제 실패 — 복제본에서 돌림), Code Examples 의 prototype |
| REL-04 | 릴리스 직후 빈 프로젝트에서 새 tag 를 git 의존성으로 받아, 기본 규칙 진단과 `riverpod_lint` plugin 진단이 보고됨을 확인한다 | § 3 (smoke 스크립트 설계 — GitHub 주소 · 새 pub cache 로 실제로 돌린 결과), § 4 (`flutter create` 템플릿과 README 따라 하기, D-14 측정) |
</phase_requirements>

## Summary

이 phase 의 새 코드는 둘뿐이다 — `tool/verify.dart` `[3/10]` 에 붙는 **버전 일치 확인 (i)** 와 **`tool/smoke.dart`**. 나머지는 릴리스 커밋(version · CHANGELOG 날짜 · lock 여섯 · IN-13 주석), 문서 손질(README 셋 · `example/README.md` 둘 · `VERSIONING.md` 새 절), 그리고 사람 확인이 끼는 원격 작업(브랜치 push → tag push → PR 병합)이다. 조사에서 네 가지를 실제로 돌려 확인했다 (모두 저장소 밖 복제본 · 임시 폴더, Flutter 3.47.5 / Dart 3.13.4, 2026-10-15).

1. **일치 검사의 prototype** (`pubspecReleaseVersion` 과 같은 줄 읽기 + CHANGELOG 첫 `## ` 줄을 ` - ` 로 한 번 나누기) 이 D-06 의 다섯 입력 모두에서 실패하고, 지금 상태(`2.0.0-dev` · `미출시`)의 평소 모드와 릴리스 상태의 tag 모드에서 통과한다. tag 이름은 명령 인자 `--tag <이름>` (로컬 (3)) 과 `GITHUB_REF_TYPE == tag` 일 때의 `GITHUB_REF_NAME` (CI (2)) 에서 읽고, workflow 는 고치지 않아도 된다 — 두 변수는 모든 step 에 기본으로 주어진다 `[CITED: docs.github.com variables]`.
2. **IN-12 고친 판** (`keysSeenByLineReader` 의 아래 줄 가운데 키 꼴이 아닌 줄을 담지 않음 — 8줄 추가 · 1줄 삭제) 이 함수 단위에서 IN-12 입력을 통과시키고 M78 · (a′) 회귀를 그대로 둔다. `dart format` · `dart analyze` 깨끗.
3. **version 을 `2.0.0` 으로 바꾸면 검증이 종료 코드 69** (`pub get 실패 (example/): exit 65`, 안내가 `cd example && fvm dart pub get` 을 가리킨다). 여섯 폴더에서 `fvm dart pub get` 을 돌리면 **lock 마다 `version: "2.0.0-dev"` → `"2.0.0"` 한 줄만** 바뀌고(`7 files changed, 7 insertions(+), 7 deletions(-)`), 그 뒤 검증이 10/10 (새 pub cache 의 첫 실행 74초).
4. **`flutter create` 빈 프로젝트가 GitHub 주소에서 작업 브랜치 커밋 `2336ba0` 을 새 `PUB_CACHE` 로 받아** (`flutter pub get` 6.2초, lock 에 `source: git` · `resolved-ref` = 그 커밋), `recommended.yaml` 과 `analysis_options.yaml` 두 주소에서 `prefer_single_quotes` (info) 와 `provider_parameters` (warning) 가 둘 다 보고됐다 (각 첫 실행 17 ~ 18초, plugin 폴더 1, `riverpod_lint` 3.1.9, 실패 머리말 없음). D-14 의 질문도 같은 프로젝트에서 쟀다 — `base.yaml` 만 받고 「프로젝트 전체」 의 `plugins:` 블록을 붙이면 **plugin 이 켜진다**.

**Primary recommendation:** 커밋을 넷으로 나눈다 — ① 검사 + IN-12 + IN-14 문장 + `example/README.md` 의 M92 ~ 기록 (`fix(tool)`), ② README 셋 · `VERSIONING.md` 「릴리스 절차」 (`docs`), ③ `tool/smoke.dart` (`feat(tool)`), ④ 릴리스 커밋 (`chore(release)`: version · CHANGELOG 날짜 · lock 여섯 · IN-13) — ④ 에서 `fvm dart run tool/verify.dart --tag v2.0.0` 10/10 을 본 뒤 push 하고, 예행 `fvm dart run tool/smoke.dart <④의 커밋>` → checkpoint → tag → push → `smoke.dart v2.0.0` → `ls-remote` → checkpoint → PR merge commit 의 순서로 간다.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 버전 일치 검사 (REL-03) | 검증 명령 `tool/verify.dart` `[3/10]` (로컬 · CI 공통) | GitHub Actions (tag push 때 같은 명령을 돌리는 자리) | 판정 로직은 스크립트 하나에 두고 CI 는 환경변수만 준다 — workflow 를 고치지 않는다 |
| tag 이름의 출처 | 명령 인자 (로컬 (3)) / `GITHUB_REF_TYPE` · `GITHUB_REF_NAME` (CI (2)) | — | 환경변수는 모든 step 에 기본으로 있다 `[CITED]` |
| smoke test (REL-04) | `tool/smoke.dart` (로컬, 저장소 밖 임시 폴더) | GitHub (받아 오는 길), pub.dev (plugin) | CI job 으로 두지 않는다 (D-10) |
| 릴리스 상태 (version · CHANGELOG · lock) | 저장소 파일 (릴리스 커밋) | — | lock 여섯은 `fvm dart pub get` 으로만 |
| tag · PR · `main` | git 원격 (GitHub) | `gh` CLI | one-way — 직전 확인 (D-01 5 · D-02) |
| 절차 문서 | `VERSIONING.md` | README 381행의 안내 줄 | `[3/10]` 이 `VERSIONING.md` 는 읽지 않는다 |

## Standard Stack

### Core

새로 설치하는 패키지는 없다. 쓰는 것은 모두 저장소가 이미 기대는 도구다.

| Library / Tool | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter / Dart (FVM 고정) | 3.47.5 / 3.13.4 `[VERIFIED: fvm flutter --version, 2026-10-15]` | 검증 명령 · smoke 스크립트 · `flutter create` | `.fvmrc` 와 CI 가 같은 SDK |
| `package:yaml` | 3.1.4 (`dev_dependencies`) `[VERIFIED: pubspec.yaml:22-23]` | `[3/10]` (h) 가 이미 쓴다 | 일치 검사는 줄 단위 reader 만으로 충분하다 — 새 의존성 없음 |
| git | 로컬 설치본 | annotated tag, `ls-remote`, `clone --local` | Phase 1 의 선례 |
| `gh` | 2.102.0, `woodkill` 로 로그인 `[VERIFIED: gh auth status, 2026-10-15]` | PR 열기 · merge commit · 실행 확인 · `workflow_dispatch` | Phase 5 가 `gh run view` 로 CI 증거를 남겼다 |
| GitHub Actions 기본 환경변수 | `GITHUB_REF_TYPE` (`branch` / `tag`), `GITHUB_REF_NAME` (짧은 이름, 화면에 보이는 tag 이름 그대로) `[CITED: https://docs.github.com/en/actions/reference/workflows-and-actions/variables]` | CI 의 tag 모드 판별 | workflow 수정 없이 읽힌다 |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `dart:io` · `dart:convert` | SDK | `tool/smoke.dart` 전부 (spike 015 `probe.dart` 와 같은 범위) | smoke 스크립트는 `package:yaml` 을 쓰지 않는다 — lock 항목은 정규식으로 읽는다 (`Consumer.lockEntry`) |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `GITHUB_REF_TYPE` / `GITHUB_REF_NAME` | `GITHUB_REF` 의 `refs/tags/` 접두사 자르기 | 같은 정보다. `REF_TYPE` 이 `branch` / `tag` 두 값으로 명시되어 더 단순 |
| `--tag <이름>` 인자 | 환경변수를 로컬에서 흉내 내기 (`GITHUB_REF_TYPE=tag …`) | 인자가 절차 문서에 적기 쉽고 `사용법` 줄에 보인다. prototype 은 둘 다 받고 인자를 우선했다 |
| `tool/smoke.dart` 가 `verify.dart` 를 import | 작은 helper 를 복사 | import 는 `main` 이 둘인 파일을 묶는다. 복사하는 것은 네 함수(flutter 경로, lock 항목, 진단 정규화, 머리말 검사)뿐 — 복사를 권한다 |

**Installation:** 없음.

## Package Legitimacy Audit

이 phase 는 외부 패키지를 설치하지 않는다. `example/` · `fixtures/` 의 lock 은 `fvm dart pub get` 으로 `woody_lints` 의 `version` 줄만 바뀐다 (§ 5 — 실측). smoke 프로젝트가 받는 `flutter_riverpod ^3.0.0` 은 `example/pubspec.yaml` 이 이미 쓰는 선언이고 임시 폴더에만 놓인다.

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```text
[작업 트리]                                   [GitHub]                              [저장소 밖 임시 폴더]
 ① fix(tool) 검사(i)+IN-12+IN-14+M92~ ─┐
 ② docs README·VERSIONING             ├─ git push origin gsd/v2.0-package-rework ─▶ verify (push, branch 모드: (1) 평소 검사)
 ③ feat(tool) smoke.dart              │                                               │ 통과
 ④ chore(release) 2.0.0·날짜·lock×6·IN-13 ┘                                           ▼
     │ fvm dart run tool/verify.dart --tag v2.0.0  ((3) 로컬 tag 검사, 10/10)   fvm dart run tool/smoke.dart <④ sha> ──▶ flutter create → README 대로 → PUB_CACHE 새로
     │                                                                                                                 → flutter pub get (https://github.com/…)
     ▼                                                                                                                 → dart analyze ×2 (recommended / 옛 주소)
 [checkpoint: tag push 직전 확인]                                                                                      → lock resolved-ref == sha ?
     │ git tag -a v2.0.0 -m … <④ sha> ; git push origin v2.0.0 ──▶ verify (push, GITHUB_REF_TYPE=tag → (2) tag 검사) ── 로그의 tag 모드 줄
     │ git ls-remote --tags origin (peeled ^{} 줄 = sha)            fvm dart run tool/smoke.dart v2.0.0 (같은 판정, resolved-ref == rev-parse 'v2.0.0^{commit}')
     ▼
 [checkpoint: main 병합 직전 확인]
     │ gh pr create --base main --head gsd/v2.0-package-rework ──▶ verify (pull_request) — 02-UAT 4번
     │ gh pr merge <n> --merge                                 ──▶ main = merge commit, v2.0.0 커밋이 main 의 조상
     └ gh workflow run verify --ref main                      ──▶ verify (workflow_dispatch) — 02-UAT 6번
```

### Recommended Project Structure

```text
tool/
├── verify.dart        # [3/10] 에 (i) 버전 일치 확인, main 에 --tag 인자, 머리 주석의 종료 코드 목록 (IN-14), keysSeenByLineReader (IN-12)
├── smoke.dart         # 새 파일 — tool/smoke.dart <ref> : 저장소 밖 임시 폴더에서 flutter create → README 대로 → 새 PUB_CACHE 로 받기 → 두 주소로 dart analyze → D-09 판정
└── measure_rules.dart # 그대로
VERSIONING.md          # 끝에 새 절 「릴리스 절차」 (D-11 · D-12)
README.md              # 34 · 355 · 381행, 「설치」 · 「프로젝트 전체」 · 「생성 파일 제외」 의 한 문장씩 (D-14)
example/README.md      # 116행 ([3/10] 설명에 (i)), 620행 (UAT 5 · IN-14), 종료 코드 70 표 행, 새 소절 M92 ~
pubspec.yaml           # version 2.0.0, 13 ~ 15행 주석 (IN-13)
CHANGELOG.md           # 1행 날짜
example/pubspec.lock, fixtures/{base_codegen,base_only,base_riverpod,overrides,recommended}/pubspec.lock  # version 줄 하나씩
```

### Pattern 1: 검사는 `[3/10]` 의 블록 하나, 읽지 못하는 입력은 70

**What:** `checkShippedComposition` 의 (g) 와 (h) 사이(또는 (h) 뒤, `return StepResult` 앞 — `tool/verify.dart` 2501 ~ 2507행 `[VERIFIED]`)에 (i) 블록을 더한다. 어긋남마다 한 블록(머리 줄 + 안내 줄)을 `addBlock` 으로 넣어 `[3/10]` 실패(종료 코드 1). CHANGELOG 에 `## ` 제목이 없거나 ` - ` 가 없으면 `FormatException` (70) — `pubspecReleaseVersion` 이 `version:` 을 읽지 못할 때와 같은 등급.
**When to use:** 값의 어긋남은 1, 파일 모양이 예상과 다르면 70 — `example/README.md` 103 ~ 116행의 종료 코드 표가 이미 그렇게 가른다 `[VERIFIED]`.

### Pattern 2: 모드 줄을 stderr 에 남긴다

**What:** 준비 단계에서 `버전 일치 검사: 평소 (pubspec 꼬리 뗀 값 ↔ CHANGELOG)` 또는 `버전 일치 검사: tag v2.0.0 (GITHUB_REF_NAME)` / `(--tag)` 한 줄을 stderr 에 찍는다 (stdout 첫 줄은 늘 `SDK` 줄이어야 한다 — `main` 의 문서 주석 `[VERIFIED: tool/verify.dart:2801-2806]`).
**Why:** D-06 은 "CI 의 tag 트리거가 이 검사를 실제로 부르는지는 진짜 `v2.0.0` push 의 실행 로그(통과 쪽)로 확인한다" 고 했다. 통과한 단계는 내용 줄이 없으므로(`[3/10] 배포 파일의 구성 … 통과` 뿐) 이 줄이 없으면 로그에서 tag 모드가 돌았는지 평소 모드가 돌았는지 가를 수 없다.

### Pattern 3: smoke 스크립트는 spike 015 `probe.dart` 의 `Consumer` 를 그대로 옮긴다

**What:** `Process.run(Platform.resolvedExecutable, ['pub', …], environment: {'PUB_CACHE': …})`, `lockEntry()` (`  woody_lints:` 아래 `키: 값` 정규식), `packageRoot()` (`package_config.json` 의 `rootUri`), 상태 폴더 `environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': …}`, `--suppress-analytics analyze --format=json`, stdout 의 마지막 `{` 줄을 JSON 으로 읽어 `상대경로:줄  강도  규칙이름`, stderr 의 머리말 `contains` — 모두 `analyze-run-and-verdict.md` 1 · 3 · 4번과 `git-dependency-and-upgrade.md` 6번에 있다 `[VERIFIED: 읽음]`.
**Example:** Code Examples § "smoke 스크립트 뼈대".

### Anti-Patterns to Avoid

- **일치 검사를 새 단계 `[11/11]` 로 두는 것** — `example/README.md` 의 `[n/10]` · `10개 중` · `/10` 표기가 410곳이다 `[VERIFIED: grep -o … | wc -l = 410, 2026-10-15]`.
- **workflow 에 `tags:` 필터를 더하는 것** — `tags:` 만 적으면 브랜치 push 에서 돌지 않는다 (workflow 5 ~ 7행 주석 `[VERIFIED]`). 필터 없는 `push:` 는 그대로 둔다. tag push 의 실행은 concurrency group 이 `verify-refs/tags/v2.0.0` 이라 브랜치 실행과 따로 돈다 (19 ~ 20행 `[VERIFIED]`).
- **`-dev` 를 뗀 값으로 tag 검사를 하는 것** — (2) · (3) 은 `pubspec.yaml` 의 값을 **꼬리 없이 정확히** 견준다 (D-04). `pubspecReleaseVersion` 은 꼬리를 떼므로 (1) 에만 쓰고, tag 모드에는 원문을 돌려주는 reader 가 하나 더 필요하다 (prototype 의 `pubspecVersionText`).
- **lock 을 `pub upgrade` 로 다시 받는 것** — D-12 (2). `fvm dart pub get` 은 `version` 줄만 바꿨다 (§ 5).
- **smoke 프로젝트를 저장소 안에 만들거나 평소 pub cache · `~/.dartServer` 를 쓰는 것** — 묻지 않고 잡은 것 두 줄. `Directory.systemTemp.createTempSync` + `PUB_CACHE` + 상태 폴더 둘(주소마다 따로 — 상태 폴더를 합치면 plugin 폴더가 둘이 되어 버전을 읽지 못한다, spike 014).
- **기반 세트의 규칙(`avoid_print` 등 `base_rules.dart` 의 7개)을 smoke 의 "기본 규칙 위반" 으로 쓰는 것** — `flutter create` 템플릿이 이미 `flutter_lints` 를 include 하므로 `woody_lints` 의 include 가 통째로 실패해도 그 줄은 나온다. 이 패키지만 켜는 규칙(`example/lib/added_rules.dart` 의 `prefer_single_quotes`)을 쓴다 (§ 3).
- **`git tag` 를 CI 통과 전 · 예행 전에 만드는 것** — D-01 의 순서. tag 는 옮기지 않는다.
- **`gh pr merge --squash` / `--rebase`** — D-02. `--merge` 만.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| pubspec 의 `version:` 읽기 | 새 정규식 | `pubspecReleaseVersion` 의 `versionLine` · `unquotedScalar` · `splitYamlLines` (1597 ~ 1615행) 를 같은 꼴로 | 따옴표 · 줄 끝 주석 · CR 줄 나누기가 이미 처리되어 있고 (h) 가 YAML 과 견준다 |
| lock 의 `resolved-ref` 읽기 | YAML 해석 | spike 015 `Consumer.lockEntry` (정규식 `^\s+([a-z-]+): "?([^"]*)"?$`) | `dart:io` 만으로 되고 실측에서 통했다 |
| `dart analyze` 결과 판정 | 종료 코드만 보기 | 머리말 `contains` → 종료 코드 0/2/3 이 아니거나 JSON 아님 → 줄 비교 (`analyze-run-and-verdict.md` 4번) | plugin 이 죽어도 0 / 2 가 나온다 |
| 원격 tag 의 커밋 확인 | `git show v2.0.0` 의 출력 파싱 | `git ls-remote --tags origin` 의 peeled 줄(`refs/tags/v2.0.0^{}`) 과 `git rev-parse 'v2.0.0^{commit}'` | 01-01-SUMMARY 의 패턴 `[VERIFIED]` |
| PR 병합 방식 | GitHub 웹 버튼 | `gh pr merge <n> --merge` | 세 방식이 `-m` / `-s` / `-r` 로 명시된다 `[VERIFIED: gh pr merge --help]` |

**Key insight:** 이 phase 의 모든 읽기(버전 · 제목 · lock · 진단)는 이미 저장소나 spike 에 검증된 reader 가 있다. 새로 짜는 것은 "무엇과 무엇을 견주는가" 뿐이다.

## 1. REL-03 — `[3/10]` 안의 자리, CHANGELOG 읽기, tag 이름의 출처, workflow (planner 질문 1)

### 지금의 코드 (2026-10-15 `[VERIFIED: tool/verify.dart]`)

| 자리 | 행 | 내용 |
|---|---|---|
| 머리 주석의 종료 코드 목록 | 25 ~ 26 | `// 종료 코드: 0 모두 통과 / 1 단계 실패 / 64 사용법 오류 / 69 pub get 실패 / 70 예외로 끝남` / `//            / 78 실행 중인 SDK 가 .fvmrc 와 다름` |
| `pubspecReleaseVersion` | 1597 ~ 1615 | `version:` 줄을 `splitYamlLines` 로 한 줄씩 보고 첫 일치의 값을 `unquotedScalar` 로 벗긴 뒤 `^(\d+\.\d+\.\d+)(?:[-+].*)?$` 로 꼬리를 뗀다. 못 읽으면 `FormatException` (70) |
| `keysSeenByLineReader` | 1879 ~ 1913 | IN-12 자리 (§ 6) |
| `compareLineReadersWithYaml` 문서 주석 | 1986 | `/// 건너뛴다. [YamlException] 만 잡는다 — 그 밖의 예외는 지금처럼 main 이 받는다.` (IN-14 자리) |
| `[3/10]` 문서 주석의 (g) · (h) | 2140 ~ 2142 | (i) 설명을 이 뒤에 더한다 |
| `checkShippedComposition` | 2145 | (g) 의 `final release = pubspecReleaseVersion(repoRoot);` 가 2461행, (h) 호출 `compareLineReadersWithYaml(repoRoot).forEach(addBlock);` 가 2501행, `return StepResult(…)` 가 2503 ~ 2507행 |
| `main` 의 인자 읽기 | 2807 ~ 2814 | `final unknown = args.where((a) => a != '--update').toList();` → 모르는 인자면 `사용법: $runCommand [--update]` 와 `quit(64)`. `final update = args.contains('--update');` |
| CI 판별 | 2824 ~ 2825 | `env['CI'] == 'true' \|\| env['GITHUB_ACTIONS'] == 'true'` (이미 `Platform.environment` 를 읽는다) |

### 넣을 자리와 모양 (권고)

- **(i) 의 자리:** (h) 호출 바로 뒤, `return` 앞 (2501 ~ 2503행 사이). `checkShippedComposition(String repoRoot)` 의 서명에 tag 이름을 넘겨야 하므로 `checkShippedComposition(repoRoot, tag: tagName)` 처럼 이름 있는 선택 인자를 더하고, `main` 의 2849행 호출에서 넘긴다.
- **읽기 둘 (새 함수):**
  - `pubspecVersionText(repoRoot)` — `pubspecReleaseVersion` 과 같은 줄 읽기이되 꼬리를 떼지 않은 원문 (`2.0.0-dev`). `pubspecReleaseVersion` 을 이 함수로 다시 짜면(원문을 읽고 꼬리를 뗀다) reader 가 하나로 남는다 — 다만 `[3/10]` (h) 가 `pubspecReleaseVersion` 을 YAML 과 견주고 M87 이 그 동작을 기록하므로 **동작은 바꾸지 않는다**.
  - `changelogTop(repoRoot)` — `CHANGELOG.md` 를 `splitYamlLines` 로 나눠 첫 `## ` 줄을 잡고, `## ` 뒤를 첫 ` - ` 에서 한 번 나눈다 → `(version, dateSlot)`. `## ` 줄이 없거나 ` - ` 가 없으면 `FormatException`. 지금 1행은 `## 2.0.0 - 미출시` `[VERIFIED: head -1 CHANGELOG.md]`, `## ` 제목은 `2.0.0 → 1.3.0 → 1.2.5 → … → 1.0.0` 순이고 파일 첫 줄이 곧 최상단 제목이다.
- **판정 (D-04 · D-05 그대로, prototype 으로 확인 `[VERIFIED: § 2]`):**
  - tag 없음 (평소 (1)): `pubspecReleaseVersion` == `changelogTop.version`. 아니면 블록 하나.
  - tag 있음 ((2) · (3)): tag 가 `^v(\d+\.\d+\.\d+)$` 가 아니면 블록 하나로 끝 (나머지는 보지 않는다). 아니면 셋을 각각 본다 — tag 버전 ≠ `pubspecVersionText` (꼬리 포함 정확히; 값이 `<tag 버전>-dev` 이면 "`-dev` 꼬리가 남아 있다" 를 덧붙인다), tag 버전 ≠ `changelogTop.version`, `dateSlot` 이 `^\d{4}-\d{2}-\d{2}$` 가 아님. 어긋남마다 블록 하나 — 입력 "tag 이름만 다르다" 는 pubspec 과 CHANGELOG 둘 다에서 블록 둘이 난다 (§ 2 표).
- **tag 이름의 출처 (권고 — Discretion):** `main` 에서 `--tag <이름>` 인자를 받고 (`args` 에서 `--tag` 다음 값; 값이 없으면 64), 인자가 없을 때만 `env['GITHUB_REF_TYPE'] == 'tag' ? env['GITHUB_REF_NAME'] : null`. 인자가 우선 (prototype 이 그렇게 했고 둘 다 있을 때 인자 쪽으로 판정했다). `사용법` 줄을 `[--update] [--tag vX.Y.Z]` 로.
  - `GITHUB_REF_TYPE`: "The type of ref that triggered the workflow run. Valid values are `branch` or `tag`." `GITHUB_REF_NAME`: "The short ref name of the branch or tag that triggered the workflow run. This value matches the branch or tag name shown on GitHub." `[CITED: https://docs.github.com/en/actions/reference/workflows-and-actions/variables]` — `pull_request` · `workflow_dispatch` 에서는 `branch` 이므로 평소 모드로 돈다.
  - annotated tag 와 lightweight tag 의 차이는 문서에 없다 (`events-that-trigger-workflows` 의 `push` 표는 `GITHUB_SHA` 를 "Tip commit pushed to the ref" 로만 적는다) `[CITED: 같은 사이트 events-that-trigger-workflows]`. `actions/checkout` 이 받는 내용은 tag 가 가리키는 커밋의 트리이고 검증 명령은 그 파일만 읽으므로 tag 객체의 해시가 어느 변수에 들어가든 판정에 영향이 없다 `[ASSUMED — A1]`.
- **workflow:** 고치지 않는다. 필터 없는 `push:` 가 tag push 에서도 돌고(5 ~ 7행 주석 `[VERIFIED]`), concurrency group 이 `${{ github.workflow }}-${{ github.ref }}` 라 tag 실행(`refs/tags/v2.0.0`)은 브랜치 실행과 다른 그룹이다 (18 ~ 20행 `[VERIFIED]`). 5 ~ 7행 주석의 "Phase 6 (REL-03) 이 tag 전용 검사를 더할 때: `tags:` 만 적으면 …" 문장은 그대로 두어도 틀리지 않으나, "더했다 — 검사는 `tool/verify.dart` 가 `GITHUB_REF_TYPE` 으로 가른다" 로 현재형으로 고쳐 두면 읽는 사람이 workflow 에서 찾지 않는다 (선택).
- **문서에 같이 고칠 것:** `tool/verify.dart` 6행(`[3/N]` 설명)과 15행(`실행:` 줄의 사용법), `example/README.md` 116행의 `[3/10]` 설명 끝에 (i) 한 문장, 같은 파일 종료 코드 표의 70 행에 "CHANGELOG 최상단 `## ` 제목이 없거나 ` - ` 가 없는 경우", 64 행에 `--tag` 의 값 없음. README 「이 저장소를 고치는 사람에게」 380행의 검증 안내에는 절차 문서(`VERSIONING.md`)를 가리키는 것으로 충분하다 (D-11 이 381행을 고친다).

## 2. D-06 다섯 입력 — 재현 방법과 실제 결과 (planner 질문 2)

prototype (`checkVersionAgreement`, Code Examples) 을 저장소 복제본에서 돌린 결과다 `[VERIFIED: 복제본, Dart 3.13.4, 2026-10-15]`. 릴리스 상태는 `version: 2.0.0` · `## 2.0.0 - 2026-10-15` 로 만들었다.

| 번호 (권고) | 입력 | 모드 | 결과 |
|---|---|---|---|
| — | 지금 상태 `2.0.0-dev` · `미출시` | 평소 (1) · CI branch 흉내 | 통과 (fails=0) |
| — | 지금 상태에 tag `v2.0.0` | tag (3) | 실패 둘 — `-dev` 꼬리, 날짜 자리 `미출시` |
| — | 릴리스 상태 | CI tag 흉내 (`GITHUB_REF_TYPE=tag GITHUB_REF_NAME=v2.0.0`) · `--tag v2.0.0` | 통과 |
| M92 | tag 이름만 다르다 (`v2.0.1`) | tag | 실패 둘 — pubspec (2.0.0), CHANGELOG (2.0.0) 과 다르다 |
| M93 | `pubspec.yaml` 에 `-dev` 가 남았다 | tag | 실패 하나 — "`-dev` 꼬리가 남아 있다" |
| M94 | CHANGELOG 버전만 다르다 (`## 2.1.0 - …`) | tag · **평소에서도** | 실패 하나씩 — tag 모드 "CHANGELOG 최상단 버전 (2.1.0)", 평소 모드 "pubspec (2.0.0) 과 CHANGELOG (2.1.0)" |
| M95 | 날짜 자리 `미출시` | tag | 실패 하나 — "`YYYY-MM-DD` 꼴이 아니다: `미출시`" |
| M96 | tag 이름이 `v` + 버전 꼴이 아니다 (`2.0.0`, `release-2.0.0`) | tag | 실패 하나 — "`vX.Y.Z` 꼴이 아니다" (나머지 셋은 보지 않는다) |
| (가장자리) | 제목에 ` - ` 둘 (`## 2.0.0 - 2026-10-15 - 추가`) | tag | 날짜 자리 `2026-10-15 - 추가` 로 실패 — ` - ` 한 번 규칙이 지켜진다 |

- **재현 방법:** Phase 5 의 선례대로 `git clone --local` 복제본에서 한 번에 하나씩 `sed` 로 바꾸고 `fvm dart run tool/verify.dart --tag v2.0.0` (M96 은 `--tag 2.0.0`) 을 돌려 종료 코드 1 · `[3/10]` 실패 · 블록 문구를 적는다. 복제본의 전체 실행은 plugin 이 준비된 뒤 약 22초 (`example/README.md` 627행의 M90 · M91 은 함수 단위라 1초 이하). **다섯 모두 함수 단위(`checkShippedComposition`) 로 돌리고 하나(M93)만 전체 실행**으로 돌리면 기록 형식이 M90 · M91 과 같다 — `tool/_harness.dart` 같은 임시 파일을 복제본에만 두고 `checkShippedComposition(root, tag: …)` 를 불러 `passed` 와 `detailLines` 를 찍는다 (이번 조사가 그 방식을 썼다).
- **릴리스 상태로 만드는 명령:** `sed -i '' 's/^version: 2\.0\.0-dev$/version: 2.0.0/' pubspec.yaml`, `sed -i '' '1s/^## 2\.0\.0 - 미출시$/## 2.0.0 - 2026-10-15/' CHANGELOG.md`. 전체 실행이면 복제본에서 lock 여섯도 다시 받아야 한다 (§ 5 — 아니면 69 에서 멈춘다). 함수 단위면 lock 과 무관하다.
- **IN-12 의 기록 (권고 M97):** `lib/base.yaml` 5행을 `include:` / `  package:flutter_lints/flutter.yaml` 로 → 고치기 전 `passed=false` 블록 "`lib/base.yaml` 의 `include:` 바로 아래 키 — 줄 단위 reader 에만: package:flutter_lints/flutter.yaml · YAML 에만: (없음)", 고친 뒤 `passed=true` (따옴표 값 `"package:…"` 도 통과). 회귀 — M78 입력(`"zz_quoted_plugin": ^0.1.0`)은 (a′) 줄과 (h) 블록(`줄 단위 reader 에만: "zz_quoted_plugin": ^0.1.0 · YAML 에만: zz_quoted_plugin`)이 그대로 `[VERIFIED: 함수 단위, 2026-10-15]`. M32 · M33 (WR-02 의 거짓 실패 해소) 이 "통과로 바뀐 입력" 의 기록 선례다.
- 마지막 번호는 M91 `[VERIFIED: example/README.md:607, M92 이상 0건]`. 새 소절 제목 꼴은 `### 추가 실측 — <무엇> (06-NN)`, 첫 줄 `실측 (06-NN): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, YYYY-MM-DD` (594 ~ 596행 `[VERIFIED]`).

## 3. smoke 스크립트 (D-10) — 설계와 실측 (planner 질문 3)

### 실제로 돌린 것 `[VERIFIED: 저장소 밖 임시 폴더, Flutter 3.47.5 / Dart 3.13.4, 2026-10-15]`

빈 프로젝트가 GitHub 의 작업 브랜치 커밋 `2336ba0e3e193e70b2c328c77594b3173b53defc` (origin 의 `gsd/v2.0-package-rework`, 나눈 구조 + Phase 5 README) 를 받았다. 받은 주소는 README 의 `https://github.com/woodkill/woody_lints.git`, 인증 없음, `PUB_CACHE` 는 임시 폴더 안.

| 단계 | 명령 | 결과 |
|---|---|---|
| 빈 프로젝트 | `flutter create --platforms=android --project-name smoke_app app` | 2.1초. 옵션 파일(주석 뺀 것): `include: package:flutter_lints/flutter.yaml` / `analyzer: exclude: [build/**, android/**]` / `linter: rules:` (빈 값). `dev_dependencies` 에 `flutter_test` · `flutter_lints: ^6.0.0` |
| README 「설치」 | `dev_dependencies` 에 `woody_lints: git: url: … ref: <sha>`, `dependencies` 에 `flutter_riverpod: ^3.0.0` | — |
| 옵션 파일 | `include:` 줄만 `package:woody_lints/recommended.yaml` 로 바꾸고 `analyzer:` · `linter:` 는 그대로 (D-14 문장대로) | — |
| 위반 둘 | `lib/smoke_violations.dart` — `prefer_single_quotes` (`added_rules.dart` 29행 `const String doubleQuoted = "b";`) 와 `provider_parameters` (`riverpod_rules.dart` 13 ~ 18행의 `familyProvider` · `consumerProvider`) | — |
| 받기 | `flutter pub get` (README 의 명령) | 6.2초, `+ woody_lints 2.0.0-dev from git https://github.com/woodkill/woody_lints.git at 2336ba`. lock: `source: git`, `ref:` = `resolved-ref:` = 그 sha, `url: "https://github.com/woodkill/woody_lints.git"`. 옵션 파일은 바뀌지 않았다 (이미 `build/**` · 플랫폼 제외가 있다). 패키지 자리 `<PUB_CACHE>/git/woody_lints-<sha>/`, 옆에 `git/cache/woody_lints-<다른 해시>` (bare 저장소 캐시). `git/` 전체 17MB |
| 분석 1 (`recommended.yaml`) | `dart --suppress-analytics analyze --format=json`, 상태 폴더 `state-recommended` | exit 2, 18.0초, 머리말 0, plugin 폴더 1, `riverpod_lint` 3.1.9. 6줄: `lib/main.dart:4 warning missing_provider_scope`, `lib/smoke_violations.dart:11 warning provider_parameters`, `:4 info prefer_single_quotes`, `:7 info specify_nonobvious_property_types`, `pubspec.yaml:37 · :44 info sort_pub_dependencies` |
| 분석 2 (`analysis_options.yaml` 옛 주소) | 같음, 상태 폴더 `state-alias` | exit 2, 16.9초, **같은 6줄**, plugin 폴더 1, 3.1.9 |
| D-09 (3) | lock `resolved-ref` == 준 sha | 같다 |

- `pubspec.yaml` 의 `sort_pub_dependencies` 두 줄은 조사 스크립트가 `flutter_riverpod` 를 `flutter:` 바로 뒤에, `woody_lints` 를 `dev_dependencies` 맨 앞에 끼운 탓이다. **`flutter_riverpod` 는 `cupertino_icons` 뒤, `woody_lints` 는 `flutter_lints` 뒤(끝)에** 넣으면 안 난다 (알파벳순 — 추론, 그 배치로는 돌리지 않았다 `[ASSUMED — A2]`). 판정은 어차피 두 줄의 **존재**로 하므로 결과에 영향이 없다.
- `lib/main.dart:4 missing_provider_scope` 는 템플릿의 `runApp(const MyApp())` 에 `flutter_riverpod` 가 더해져 나온 plugin warning 이다 — 덤으로 plugin 증거가 하나 더 생긴다. `specify_nonobvious_property_types` 는 `example/expected_diagnostics.txt` 의 `lib/riverpod_rules.dart:13` 과 같은 자리(`final familyProvider = …`)다 `[VERIFIED]`.

### 스크립트 설계 (권고 — Discretion)

- **이름 · 인자:** `tool/smoke.dart <ref>` — `<ref>` 는 커밋 번호(예행) 또는 `v2.0.0` (tag). 인자가 없거나 둘 이상이면 64. 선택 `--keep` (임시 폴더를 지우지 않음) 정도면 충분하다.
- **의존성:** `dart:io` · `dart:convert` 만 (spike 와 같은 범위). 루트 `pubspec.yaml` 은 그대로.
- **흐름:**
  1. SDK 확인 — `verify.dart` 의 `readFlutterVersion` 과 같은 방식(실행 파일에서 다섯 단계 위가 Flutter root, `.fvmrc` 와 같은지) 을 복사. flutter 실행 파일은 `<root>/bin/flutter`.
  2. `Directory.systemTemp.createTempSync('woody_smoke_')` 아래 `app/`, `pub-cache/`, `state-recommended/`, `state-alias/`. 저장소 안에는 아무것도 만들지 않는다.
  3. `flutter create --platforms=android --project-name smoke_app app` (플랫폼 하나로 줄여도 템플릿의 옵션 파일 모양은 같다 — § 4).
  4. `pubspec.yaml` 고치기 — README 「설치」 블록 그대로 (`url` 은 README 의 글자, `ref:` 는 인자) + `flutter_riverpod: ^3.0.0`.
  5. `analysis_options.yaml` — `include:` 줄을 `package:woody_lints/recommended.yaml` 로 바꾸고 나머지(`analyzer: exclude:`, `linter: rules:`)는 그대로.
  6. `lib/smoke_violations.dart` 를 쓴다 (위 두 샘플 그대로 옮김, 파일 머리에 출처 주석).
  7. `flutter pub get` (README 의 명령, `PUB_CACHE` 를 임시 폴더로). 실패면 69 와 stderr.
  8. lock 의 `woody_lints` 항목을 읽어 `source == git`, `url == https://github.com/woodkill/woody_lints.git`, `resolved-ref` 를 화면에 찍는다.
  9. (3) 판정 — `resolved-ref` 를 저장소 루트에서 돌린 `git rev-parse '<ref>^{commit}'` 과 견준다 (tag 이면 그 tag 가 가리키는 커밋, 커밋이면 자기 자신). 원격의 값도 함께 찍으면 좋다 — `git ls-remote origin 'refs/tags/<ref>^{}'` (annotated tag 의 peeled 줄) / 커밋이면 생략.
  10. 분석 두 번 — 상태 폴더를 따로, `--suppress-analytics analyze --format=json`. 각 실행에서 (a) stderr 에 머리말 없음, (b) 종료 코드가 0/2/3 이고 stdout 이 JSON, (c) 정규화한 줄에 `lib/smoke_violations.dart:<n>  info  prefer_single_quotes` 와 `lib/smoke_violations.dart:<m>  warning  provider_parameters` 가 둘 다 있음, (d) `.plugin_manager` 폴더 1 개와 그 `pubspec.lock` 의 `riverpod_lint` 버전. 나온 줄 전체를 정답지 꼴로 찍는다 (판정은 두 줄의 존재).
  11. 요약 — `smoke 통과 (ref <ref> → <sha>, recommended 6줄 / 옛 주소 6줄, riverpod_lint 3.1.9)` 또는 `smoke 실패` 와 어긋난 항목, 종료 코드 0 / 1. 끝에 임시 폴더를 지운다 (`--keep` 이면 경로를 찍고 둔다 — SUMMARY 에는 경로를 적지 않는다).
- **시간:** 이번 실측 합계 약 45초 (create 2 + pub get 6 + 분석 18 + 17). 네트워크 필요.
- **검증 범위:** 루트 `analysis_options.yaml` 은 `include: package:flutter_lints/flutter.yaml` 에 `example/**` · `fixtures/**` 제외뿐이라 `tool/smoke.dart` 는 `fvm dart analyze` 에 들어간다 (기반 세트만, `[VERIFIED: analysis_options.yaml:1-13]`). `tool/verify.dart` 는 `tool/` 의 다른 파일을 보지 않는다 (`[1/10]` 은 `lib/` 의 `.dart` 만). Phase 5 의 커밋 전 관례 `fvm dart analyze` → `No issues found`, `fvm dart format --output=none --set-exit-if-changed tool` 을 그대로 쓴다 (05-RESEARCH § 6 `[VERIFIED]`). CI 는 `dart run tool/verify.dart` 만 돌리므로 smoke 스크립트는 CI 에 닿지 않는다 (D-10).
- **비공개 점검의 거짓 양성:** 점검 (2) 의 정규식 `(lib|test|bin|assets)/[A-Za-z0-9_./-]+\.(dart|json|arb|yaml)` 이 `lib/smoke_violations.dart` (스크립트 · 계획 · 이 문서에 적힌 이름, 저장소에 없는 경로) 를 `LEAK?` 로 잡는다. 05-05 의 제외 목록(`lib/woody_lints\.dart$` 등)에 `lib/smoke_violations\.dart$` 를 더한다. 템플릿의 테스트 파일 경로(`test/…`)는 문서에 적지 않는다 (§ 8).

## 4. Flutter 3.47.5 `flutter create` 템플릿과 README 따라 하기 (planner 질문 4)

- 템플릿 원본 `packages/flutter_tools/templates/app/analysis_options.yaml.tmpl` (고정 SDK 의 설치본에서 읽음 `[VERIFIED: 2026-10-15]`): `include: package:flutter_lints/flutter.yaml`, `analyzer: exclude:` 에 `build/**` 와 `{{#android}}` 등 만든 플랫폼 폴더, `{{^withEmptyMain}}` 일 때 주석 많은 `linter: rules:` (값 없음). 실제 `flutter create --platforms=android` 의 산출물은 `build/**` · `android/**` 둘만 제외하고 `linter: rules:` 가 있다 (§ 3 표).
- README 를 따라 하는 사람(과 스크립트)이 템플릿 옵션 파일에 할 일은 **`include:` 한 줄을 바꾸는 것**이 전부다. `analyzer: exclude:` 는 「생성 파일 제외」 블록을 붙일 때 같은 `analyzer:` 키 아래 `exclude:` 목록에 두 줄을 **더하는** 꼴이 되고, 「프로젝트 전체」 의 `linter: rules:` 는 템플릿의 빈 `rules:` 아래에 `이름: false` 를 넣는 꼴이 된다 — D-14 의 문장 "기존 `include` 줄은 바꾸고, 이미 있는 `analyzer:` · `linter:` 키에는 합친다" 가 세 절에 각각 맞다. 같은 키를 두 번 적으면 (h) 와 같은 이유로 analyzer 가 받지 않는다 (YAML duplicate key — `example/README.md` 620행 근처의 `Duplicate mapping key` 기록 `[VERIFIED]`).
- README 34행이 말하는 `flutter pub get` 의 옵션 파일 덧붙임은 템플릿 프로젝트에서 **일어나지 않았다** (이미 제외되어 있어서) `[VERIFIED: § 3]` — README 문장 "이미 제외되어 있으면 덧붙이지 않는다" 와 맞다.
- **D-14 의 측정 (예행에서 다시 재되, 결과는 이미 있다):** 같은 빈 프로젝트에서 옵션 파일을 `include: package:woody_lints/base.yaml` + 템플릿의 `analyzer: exclude:` + README 「프로젝트 전체」 의 `plugins: riverpod_lint: version: ^3.1.9 diagnostics: missing_provider_scope: false` 로 바꿔 분석했다 `[VERIFIED: 2026-10-15, 커밋 2336ba0 을 GitHub 에서 받은 프로젝트]` — exit 2, 15.4초, 머리말 0, plugin 폴더 1 (가상 패키지의 `pubspec.yaml` 에 `riverpod_lint: ^3.1.9`, lock 3.1.9), 줄: `provider_parameters` (warning) · `prefer_single_quotes` · `specify_nonobvious_property_types` · `sort_pub_dependencies` ×2. `missing_provider_scope` 는 껐으므로 없다. **`base.yaml` 만 받는 프로젝트가 「프로젝트 전체」 의 `plugins:` 블록을 붙이면 plugin 이 켜진다.** 「프로젝트 전체」 에 달 문장(권고): "`plugins:` 블록은 그 프로젝트의 plugin 선언 자체다 — `riverpod.yaml` 을 받지 않는 프로젝트(`base.yaml` 만)에 이 블록을 붙이면 `riverpod_lint` 가 켜진다 (Flutter 3.47.5, 2026-10-15 실측)." 계획은 예행 때 같은 측정을 한 번 더 하는 task 를 둔다 (D-14).

## 5. lock 여섯 다시 받기 (planner 질문 5) `[VERIFIED: 복제본, 2026-10-15]`

- 복제본에서 `version: 2.0.0-dev` → `2.0.0` 으로 바꾼 뒤 `fvm dart run tool/verify.dart`: **종료 코드 69**, stderr
  ```text
  `example/pubspec.yaml` 을 바꿨으면 `cd example && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요.
  pub get 실패 (example/): exit 65
  Unable to satisfy `pubspec.yaml` using `pubspec.lock`.
  ```
  (준비 4 의 `--enforce-lockfile` 이 첫 fixture 인 `example/` 에서 멈춘다 — 안내 문구가 루트 `pubspec.yaml` 의 version 변경을 말하지 않는다. 02-VERIFICATION 7번 그대로. 절차 문서에 "루트 version 을 바꾼 뒤 보는 69 는 이것" 이라고 적어 둔다.)
- 명령 (폴더마다): `cd example && fvm dart pub get`, `cd fixtures/base_codegen && fvm dart pub get`, `… base_only`, `… base_riverpod`, `… overrides`, `… recommended`. 여섯 모두 rc 0.
- `git diff --stat`: `7 files changed, 7 insertions(+), 7 deletions(-)` — lock 여섯은 각각 `woody_lints` 항목의 `version: "2.0.0-dev"` → `version: "2.0.0"` **한 줄**, 나머지 패키지 · `sdks:` 그대로 (D-12 (2) 의 근거). `example/pubspec.lock` 의 diff:
  ```diff
  @@ -270,7 +270,7 @@ packages:
         path: ".."
         relative: true
       source: path
  -    version: "2.0.0-dev"
  +    version: "2.0.0"
  ```
- 그 뒤 `fvm dart run tool/verify.dart`: 종료 코드 0, `점검 통과 (10개 중 10개)`, 버전 줄 `SDK Flutter 3.47.5 / Dart 3.13.4` · `기반 세트 flutter_lints 6.0.0 / lints 6.1.0` · `plugin riverpod_lint 3.1.9`. 새 pub cache · 빈 상태 폴더의 첫 실행 1분 14초.
- 루트 `fvm dart pub get` 도 먼저 한 번 (README 380행 — `pubspec.yaml` 이 바뀌면). 릴리스 커밋의 파일 목록: `pubspec.yaml` (version + IN-13 주석), `CHANGELOG.md` 1행, lock 여섯. README 의 `ref: v2.0.0` 은 이미 맞다 ((g) 가 `2.0.0` 을 읽는다).

## 6. 손질 다섯 · IN-12 · IN-14 — 현재 행과 고친 판 (planner 질문 6) `[VERIFIED: 2026-10-15 읽음]`

| 항목 | 파일 · 행 | 지금 | 고칠 모양 |
|---|---|---|---|
| IN-12 | `tool/verify.dart` 1879 ~ 1913 (`keysSeenByLineReader`) — 1884행 `listItemPattern`, 1907 ~ 1912행 아래 줄 담기 `if (listItemPattern.hasMatch(text)) continue;` 뒤 `keyPattern.firstMatch(text)?.group(1) ?? text` | 값 없는 최상위 키 아래의 모든 줄(목록 항목 제외)을 담는다 — 스칼라 값 줄도 | `keyLikePattern` (`^(?:"[^"]*"\|'[^']*'\|[^\s#'"][^#]*?)[ \t]*:(?:[ \t]\|$)`) 을 더하고 `\|\| !keyLikePattern.hasMatch(text)` 면 `continue`. 05-REVIEW IN-12 의 Fix 그대로 — 8줄 추가 · 1줄 삭제 (Code Examples 의 diff). 함수 문서 주석(1870 ~ 1878행)의 "줄이 키 꼴이면 키 이름을, 아니면 원문을 담는다" 도 "아래 줄은 키 꼴일 때만" 으로 |
| IN-14 | `tool/verify.dart` 25 ~ 26행 종료 코드 목록, 1986행 문서 주석 | `70 예외로 끝남`; "그 밖의 예외는 지금처럼 main 이 받는다" | 25 ~ 26행에 `/ 255 package:yaml 이 YamlException 밖의 Error 를 던진 경우 (한 글자 !!float 값의 RangeError, 아주 깊은 flow 중첩의 StackOverflowError — main 이 받지 않는다)`; 1986행을 "`YamlException` 만 잡는다 — `FormatException` 등은 main 이 받고(70), `RangeError` 같은 `Error` 는 main 도 받지 않아 처리되지 않은 예외(255)로 끝난다 (05-REVIEW.md IN-14, 코드는 고치지 않았다 — D-13)" 로 |
| IN-14 · UAT 5 | `example/README.md` 620행 (`- **`[3/10]` 의 마지막 확인 (h) 가 …` 불릿) | "YAML (package:yaml — analyzer · pub 과 같은 해석기)" / "YAML 로 읽지 못하는 파일(같은 키 두 번 · 깨진 YAML)도 블록 하나로 실패한다 (소유자 결정 G4-Q1)" | 앞에 "(판이 같은지는 재지 않았다)" 를, 뒤를 "… `YamlException` 으로 읽지 못하는 파일은 블록 하나로 실패하고, package:yaml 이 `Error` 를 던지는 입력(한 글자 `!!float` 값, 아주 깊은 flow 중첩)은 종료 코드 255 로 멈춘다 (05-REVIEW.md IN-14)" 로. 종료 코드 표(105 ~ 114행)에 255 행 하나 |
| IN-13 | `pubspec.yaml` 13 ~ 15행 | `# lib/analysis_options.yaml 이 \`include: package:flutter_lints/flutter.yaml\` 을` | `lib/base.yaml 이 …` (05-REVIEW IN-13 의 Fix 세 줄). 릴리스 커밋에서 |
| UAT 2 | `README.md` 355행 | "`plugins:` 를 바꾼 뒤(…)에는 IDE 의 Dart Analysis Server 를 재시작해야 반영된다." | 끝에 " (1.3.0 의 배포 파일 주석에서 옮긴 문장이다 — spike 에서 재시작 자체를 재 보지는 않았다)" |
| UAT 4 | `README.md` 34행 | "… 상류에 이 동작을 고치는 변경이 있다 — [flutter#191151](…) (병합 여부는 확인하지 않았다)." | "… 끄는 옵션은 없으며, 이미 제외되어 있으면 덧붙이지 않는다 (2026-10-15 의 빈 프로젝트에서 그랬다). 상류 변경 [flutter#191151](…) 은 2026-08-19 에 병합됐고 stable 판 #191530 이 Flutter 3.47.2 부터 들어 있다 — 바뀐 것은 '있는 플랫폼 폴더만 제외 · Flutter 가 아닌 패키지는 건너뜀' 이고 `build/**` 는 그대로 덧붙인다." (링크는 그대로) |
| D-11 | `README.md` 381행 | "버전 등급과 CHANGELOG 항목 형식은 `VERSIONING.md` 를 따른다." | "버전 등급 · CHANGELOG 항목 형식 · 릴리스 절차는 …" |
| D-14 | `README.md` 「설치」 29행 뒤 · 「프로젝트 전체」 222행 · 「생성 파일 제외」 284행 | — | 한 문장씩 (§ 4). 「프로젝트 전체」 에는 측정 문장도 |

- **`[3/10]` 을 지나는 README 손질:** 34 · 355 · 381행과 「설치」 · 「생성 파일 제외」 의 문장은 펜스 밖 산문이라 (d) ~ (g) 에 걸리지 않는다. 「프로젝트 전체」 의 문장도 산문이면 같다 — 단 (d′) 는 **표시 구역이 든 절(「받는 규칙」)** 의 목록 줄만 본다 `[VERIFIED: 2130 ~ 2135행 문서 주석]`. 새 펜스 블록을 더하면 (e) · (f) · (g) 의 후보가 된다(`package:woody_lints/<이름>.yaml` 꼴, `version:` · `ref:` 줄) — 새 블록을 더하지 않고 문장만 넣는 것이 안전하다. 고친 뒤 `fvm dart run tool/verify.dart` 10/10.
- **`example/README.md` 116행:** `[3/10]` 설명 한 문단(3,412자)이다. 끝에 "(i) tag · `pubspec.yaml` 의 version · CHANGELOG 최상단 버전의 일치 (…, 2026-10-15 에 더함, 아래 M92 ~ M96)" 를 잇는다. 05-UAT 8번이 이 문단의 길이를 그대로 두기로 했으므로 문단을 쪼개지 않는다.

## 7. `VERSIONING.md` 「릴리스 절차」 (D-11 · D-12) (planner 질문 7)

- **자리:** 파일 끝(126행 뒤), 「CHANGELOG 항목 형식」 다음에 `## 릴리스 절차` `[VERIFIED: VERSIONING.md 1 ~ 126행 — 절은 판정 순서 · 기준표 · 실제 사례 · CHANGELOG 항목 형식의 넷]`. 81 ~ 82행의 "Phase 6 에서 만드는 일치 검사(REL-03 …)" 는 "검증 명령 `[3/10]` 의 일치 검사(REL-03 …)" 처럼 현재형으로 고친다. `[3/10]` 은 `VERSIONING.md` 를 읽지 않는다 (CONTEXT Integration Points).
- **번호 붙은 단계 (권고 문안의 뼈대 — 이번에 밟는 순서 그대로, D-12 (1)):**
  1. 등급을 정한다 (위 「판정 순서」). 준비 중에는 `pubspec.yaml` 의 `version` 이 `X.Y.Z-dev`, CHANGELOG 최상단이 `## X.Y.Z - 미출시` 다 — 둘의 버전이 다르면 평소 push 의 검증이 `[3/10]` 에서 실패한다.
  2. 릴리스 커밋 — `version` 의 `-dev` 를 뗀다, CHANGELOG 제목의 `미출시` 를 날짜(`YYYY-MM-DD`)로, 루트 `fvm dart pub get`, **lock 여섯을 `fvm dart pub get` 으로만** 다시 받는다 (`example/`, `fixtures/` 다섯 — `pub upgrade` 는 하지 않는다; 루트 version 만 바꾸고 돌린 검증은 종료 코드 69 로 `example/` 을 가리킨다), `fvm dart run tool/verify.dart --tag vX.Y.Z` 10/10.
  3. 작업 브랜치 push, GitHub `verify` 통과 (`gh run list --workflow verify --limit 3`).
  4. 예행 — `fvm dart run tool/smoke.dart <릴리스 커밋>` 통과. README 를 따라 하다 막히면 README 를 고친 커밋으로 2 ~ 4 를 다시.
  5. **(직전 확인)** annotated tag — `git tag -a vX.Y.Z -m "<메시지>" <릴리스 커밋>`, `git cat-file -t vX.Y.Z` → `tag`, `git push origin vX.Y.Z` (tag 이름 하나만).
  6. CI 의 tag 실행 — `gh run list --workflow verify --branch vX.Y.Z` (또는 `gh api repos/woodkill/woody_lints/actions/runs --jq '.workflow_runs[] | select(.head_branch=="vX.Y.Z")'`) 가 success, 로그에 tag 모드 줄 `[ASSUMED — A3: tag 실행의 `--branch` 필터]`.
  7. `fvm dart run tool/smoke.dart vX.Y.Z` 통과 (`resolved-ref` == `git rev-parse 'vX.Y.Z^{commit}'`).
  8. `git ls-remote --tags origin` — `refs/tags/vX.Y.Z^{}` 줄이 릴리스 커밋. `git ls-remote --heads origin` 으로 브랜치가 따라 올라가지 않았는지.
  9. **(직전 확인)** `main` 병합 — `gh pr create --base main --head gsd/… --title … --body …` → `pull_request` 의 `verify` 통과 → `gh pr merge <번호> --merge` (squash · rebase 금지) → `git merge-base --is-ancestor vX.Y.Z origin/main`. 처음이면 `gh workflow run verify --ref main` 으로 수동 실행 버튼까지.
  10. 다음 작업을 시작할 때 `version: X.Y.(Z+1)-dev` (또는 정한 다음 버전) 와 `## <같은 버전> - 미출시` 를 **같은 커밋**에서 — 검사 (1) 이 둘의 버전을 견준다. 한 번 올린 tag 는 옮기지 않는다 (잘못이면 새 번호).
- **"plugin 새 버전 때문에 정답지가 저절로 깨졌을 때" 단락 (D-12 (3), 권고 문안의 재료):**
  - 가르는 법: 화면 셋째 줄 `plugin     riverpod_lint <버전>` (`formatVersionLines`, 2754 ~ 2776행 `[VERIFIED]`) 을 정답지 머리 주석 `# 실측: Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13` (`example/expected_diagnostics.txt` 1행 `[VERIFIED]`) 과 견준다. 버전이 다르고, 실패한 단계가 plugin 을 쓰는 넷(`example` · `recommended` · `base_riverpod` · `overrides`) 뿐이며, 다른 줄(`- ` · `+ `)의 규칙 이름이 `riverpod_lint` 의 진단(지금 정답지의 `missing_provider_scope` · `provider_parameters` · `avoid_public_notifier_properties`, 새 버전이 더한 이름)이면 저장소가 아니라 plugin 이 바뀐 것이다. 저장소 · `.fvmrc` 가 그대로인데 CI 가 깨진 경우가 이 모양이다 (README 「tag 를 고정해도 바뀌는 것」 — plugin 은 분석마다 pub.dev 에서 `^3.1.9` 안의 최신으로 풀린다).
  - 대응: (a) pub.dev 의 `riverpod_lint` CHANGELOG 에서 그 버전의 변경을 읽고, (b) 다른 단계가 모두 통과하는 상태에서 `fvm dart run tool/verify.dart --update` 로 정답지를 다시 쓴다 (다른 단계가 실패하면 쓰지 않는다 — 2815 ~ 2900행의 안전장치, `example/README.md` 21 ~ 26행 `[VERIFIED]`), (c) `git diff` 로 생기거나 사라진 줄을 읽고 `test(fixtures): riverpod_lint <버전> 으로 정답지 갱신` 꼴의 **별도 커밋**으로 — 버전은 올리지 않는다 (기준표 "저장소 안쪽만 바뀜 → 올리지 않음"; 받는 쪽의 plugin 은 tag 와 무관하게 이미 바뀌어 있다). (d) 새 진단이 받는 쪽을 막을 만하면(warning 이상) README 「tag 를 고정해도 바뀌는 것」 에 한 줄.
  - `--update` 를 쓰지 않는 경우: plugin 버전이 그대로인데 정답지가 다르면 저장소의 변경(규칙 · 샘플 · SDK)이 원인이다 — 그 변경을 되짚는다. SDK 가 바뀐 경우는 `ci-workflow.md` 1번의 `.fvmrc` 주의(생성 파일 샘플 4줄).

## 8. 릴리스 작업의 명령과 증거 · 직전 확인 자리 · 비공개 점검 (planner 질문 8)

- **저장소 상태 (2026-10-15 `[VERIFIED: git ls-remote, git log]`):** 로컬 `HEAD` = `1c0558a` (작업 브랜치), origin 의 작업 브랜치 = `2336ba0`, origin `main` = `90a2736`, tag `v1.3.0` (객체 `80e2112` → `90a2736`) 하나, PR 0건, 저장소 PUBLIC, 기본 브랜치 `main`. remote 는 ssh (`git@github.com:woodkill/woody_lints.git`). 최근 `verify` 실행 5건 모두 success (push, 3 ~ 4분).
- **tag 명령 (Phase 1 의 패턴 `[VERIFIED: 01-01-SUMMARY.md]`):** `git tag -a v2.0.0 -m "woody_lints 2.0.0" -m "<한 줄>" <릴리스 커밋>` → 4중 점검 `git cat-file -t v2.0.0` = `tag`, `git rev-parse 'v2.0.0^{commit}'` = 릴리스 커밋, `git show v2.0.0:pubspec.yaml | grep -nx 'version: 2.0.0'`, `git show v2.0.0:CHANGELOG.md | head -1` = `## 2.0.0 - YYYY-MM-DD` → **checkpoint (blocking-human)** → `git push origin v2.0.0` → 증거: push 출력 원문 + `git ls-remote --tags origin` (두 줄: `<tag 객체>\trefs/tags/v2.0.0`, `<커밋>\trefs/tags/v2.0.0^{}`) + `git ls-remote --heads origin` + UTC 시각. 01-01 의 "시각 순서" 표(확인 응답 < push) 를 다시 쓴다.
- **CI 의 tag 실행:** `gh run list --workflow verify --event push --limit 5` 에서 tag 실행을 찾고 `gh run view <id> --log | grep -n '버전 일치 검사\|점검 통과'`. 실행이 둘 생긴다 (브랜치 push 의 것과 tag push 의 것 — concurrency 그룹이 다르다).
- **PR 과 병합:** `gh pr create --base main --head gsd/v2.0-package-rework --title "release: 2.0.0" --body "…"` → `gh run list --workflow verify --event pull_request` (02-UAT 4번) → **checkpoint (blocking-human)** → `gh pr merge <번호> --merge` (`--delete-branch` 는 쓰지 않는다 — "Keep branches") → `git fetch origin && git merge-base --is-ancestor v2.0.0 origin/main && git log -1 --format=%P origin/main` (부모 둘 = merge commit) → `gh workflow run verify --ref main` → `gh run list --workflow verify --event workflow_dispatch` (02-UAT 6번 — 버튼이 보이는지는 사람이 Actions 화면에서 본다). `gh pr merge` 의 `-m, --merge` 는 "Merge the commits with the base branch" `[VERIFIED: gh 2.102.0 --help]`. `gh workflow run` 은 "The given workflow file must support an `on.workflow_dispatch` trigger" `[VERIFIED: --help]` — 기본 브랜치 요건은 CONTEXT 의 GitHub Docs `[CITED]`.
- **checkpoint 가 필요한 자리:** (a) tag push 직전 (D-01 5), (b) `main` 병합 직전 (D-02), (c) D-10 의 "README 를 사람이 그대로 따라 해 보는 확인" (예행 때 한 번 — `checkpoint:human-verify`), (d) 02-UAT 6번의 `Run workflow` 버튼이 보이는지 (화면 확인). 브랜치 push 는 실행 뒤 보고 (D-21).
- **비공개 점검 (push 전 범위 전체):** 05-05-PLAN Task 1 의 `<automated>` 를 그대로 쓰되 `.planning/phases/05-documentation` → `.planning/phases/06-release`, PLAN · RESEARCH 의 자기 패턴 줄 제외는 `06-[0-9]+-PLAN\.md|06-RESEARCH\.md`, 점검 (2) 의 제외 목록에 `lib/smoke_violations\.dart$` 를 더한다 `[VERIFIED: 05-05-PLAN.md:85-90 읽음]`. 세 점검 — (1) 절대 경로 · 홈 · 임시 폴더 `git grep -n -E '/Users/[A-Za-z]|/private/tmp[/]|/var/folders[/]|/home/[a-z]+[/]'`, (2) `(lib|test|bin|assets)/…` 꼴 가운데 저장소 · `example/` · `fixtures/base_only/` · `fixtures/overrides/` 에 없는 경로 0개, (3) `fixes? made in|proposed fixes in` 0줄. 이번 범위에는 `tool/smoke.dart` · `VERSIONING.md` 도 든다 — 임시 폴더 경로를 화면에 찍는 스크립트의 **출력**을 SUMMARY 에 옮길 때 경로를 지운다.
- **CHANGELOG 날짜 (Discretion, 권고):** 릴리스 커밋을 만드는 날로 적고, 예행 · 확인이 날을 넘겨 tag 가 다음 날 달려도 그대로 둔다 (D-05 는 꼴만 본다). SUMMARY 에 "CHANGELOG 날짜 = 릴리스 커밋 날, tag 는 YYYY-MM-DD" 로 적는다. 날짜를 고치면 릴리스 커밋이 바뀌어 예행을 다시 해야 한다 (D-07).
- **커밋 나누기 (Discretion, 권고):** ① `fix(tool): [3/10] 에 tag · pubspec · CHANGELOG 버전 일치 확인 (i) 과 --tag 인자, IN-12 · IN-14 (REL-03)` — `example/README.md` 116 · 620행 · 종료 코드 표 · M92 ~ M97 포함; ② `docs: README 손질 (UAT 2 · 4, D-14 문장 셋) 과 VERSIONING.md 「릴리스 절차」 (D-11 · D-12)`; ③ `feat(tool): tool/smoke.dart — 빈 프로젝트가 GitHub 에서 받아 두 주소로 분석하는 smoke test (REL-04)`; ④ `chore(release): 2.0.0 — version · CHANGELOG 날짜 · lock 여섯 · pubspec 주석 (IN-13)`. ①~③ 은 지금 상태(`2.0.0-dev` · `미출시`)에서 10/10 이어야 한다 ((1) 평소 모드가 통과한다 — § 2). ④ 가 tag 를 달 커밋이다. 이 넷과 origin 에 아직 없는 14 커밋을 한 push 로 올린다.

## 9. Validation Architecture 의 재료 (planner 질문 9) — 아래 `## Validation Architecture` 절

## Runtime State Inventory

> 이름 바꾸기 · 리팩터링 phase 가 아니라 생략한다. 릴리스가 남기는 바깥 상태는 둘뿐이다 — 원격의 tag `v2.0.0` 과 `main` 의 merge commit (둘 다 one-way, D-01 · D-02). 사용 프로젝트의 pub cache · lock 은 각 프로젝트가 `pub upgrade` 할 때까지 바뀌지 않는다 (spike 015).

## Common Pitfalls

### Pitfall 1: 평소 모드가 깨지는 검사
**What goes wrong:** (i) 를 tag 모드만 생각하고 짜면 지금 상태(`2.0.0-dev` · `미출시`)의 push 에서 CI 가 빨개진다.
**How to avoid:** 평소 모드는 꼬리를 뗀 값과 CHANGELOG 버전만 견준다 (D-04 (1)). prototype 이 지금 상태에서 fails=0 (§ 2). ① 커밋 뒤 `fvm dart run tool/verify.dart` (tag 없이) 10/10 을 먼저 본다.

### Pitfall 2: 로그에서 tag 모드를 가를 수 없다
**What goes wrong:** 통과한 `[3/10]` 은 내용 줄이 없어 진짜 `v2.0.0` push 의 실행 로그로 "tag 검사가 돌았다" 를 보일 수 없다 (D-06 의 확인 방법이 막힌다).
**How to avoid:** stderr 에 모드 줄 (Pattern 2). `gh run view <id> --log | grep '버전 일치 검사'`.

### Pitfall 3: `version` 만 바꾸고 push
**What goes wrong:** 종료 코드 69 — `example/` 의 lock 이 어긋난다 (§ 5).
**How to avoid:** 릴리스 커밋에 lock 여섯을 넣는다. `git diff --stat` 이 `7 files changed` 인지 본다.

### Pitfall 4: 예행과 다른 커밋에 tag
**What goes wrong:** 예행 뒤 README 를 고치면 커밋이 바뀐다. 먼저 커밋에 tag 를 달면 예행이 본 것과 받는 것이 다르다.
**How to avoid:** `smoke.dart` 의 `resolved-ref` 출력과 `git rev-parse 'v2.0.0^{commit}'` 이 같은 값인지 tag 를 만들기 전에 적어 둔다 (D-07). tag 는 CI 통과 · 예행 통과 뒤에만.

### Pitfall 5: smoke 의 "기본 규칙" 을 기반 세트에서 고름
**What goes wrong:** 템플릿이 `flutter_lints` 를 이미 include 하므로 include 가 실패해도 그 규칙은 나온다 — 거짓 통과.
**How to avoid:** `prefer_single_quotes` (이 패키지가 더하는 규칙, `lib/base.yaml`) 를 쓴다. 더 세게 하려면 기반 세트만 있는 상태(템플릿 그대로)에서 한 번 분석해 그 줄이 **없음**을 대조로 찍는다 (선택).

### Pitfall 6: 상태 폴더를 두 주소가 함께 씀
**What goes wrong:** `.plugin_manager` 폴더가 둘이 되어 버전을 읽지 못한다 (spike 014).
**How to avoid:** 주소마다 상태 폴더를 따로 (이번 실측도 그렇게 했고 각 1개).

### Pitfall 7: 비공개 점검의 거짓 양성
**What goes wrong:** `lib/smoke_violations.dart` 가 저장소에 없는 경로라 `LEAK?` 로 잡힌다. 임시 폴더 경로를 SUMMARY 에 붙이면 (1) 에 걸린다.
**How to avoid:** 제외 목록에 더하고(§ 8), 스크립트 출력의 경로는 `<임시 폴더>` 로 바꿔 옮긴다.

### Pitfall 8: `gh pr merge` 의 기본 방식
**What goes wrong:** 플래그 없이 돌리면 대화형으로 방식을 묻거나 저장소 기본값을 쓴다. 저장소는 merge · squash · rebase 셋 다 허용이다 (CONTEXT).
**How to avoid:** `--merge` 를 명시. 병합 뒤 `git log -1 --format=%P origin/main` 으로 부모 둘을 확인.

### Pitfall 9: `GITHUB_REF_TYPE` 이 없는 환경
**What goes wrong:** 로컬에는 없다 → `null` → 평소 모드. 문제없다. 반대로 로컬에서 환경변수를 흉내 내다 남겨 두면 다음 실행이 tag 모드로 돈다.
**How to avoid:** 로컬은 `--tag` 인자만 쓰도록 절차에 적는다.

### Pitfall 10: `[n/10]` 표기
**What goes wrong:** 단계를 더하면 `example/README.md` 410곳이 어긋난다.
**How to avoid:** (i) 는 `[3/10]` 안 (묻지 않고 잡은 것).

## Code Examples

### REL-03 prototype (복제본에서 돌려 § 2 의 결과를 낸 코드 — `tool/verify.dart` 에 옮길 때 블록 문구 · `addBlock` 꼴로 바꾼다)

```dart
// 출처: 이번 조사의 prototype (저장소 밖 복제본, Dart 3.13.4, 2026-10-15). import 'verify.dart' 의 splitYamlLines · unquotedScalar · pubspecReleaseVersion 을 썼다.

/// `pubspec.yaml` 의 `version:` 값 글자 그대로 (`2.0.0-dev`). 따옴표 · 줄 끝 주석은 벗긴다.
String pubspecVersionText(String repoRoot) {
  final versionLine = RegExp(r'^version:[ \t]*(.*?)(?:[ \t]+#.*)?[ \t]*$');
  for (final line in splitYamlLines(File('$repoRoot/pubspec.yaml').readAsStringSync())) {
    final raw = versionLine.firstMatch(line)?.group(1);
    if (raw != null) return unquotedScalar(raw);
  }
  throw const FormatException('pubspec.yaml 에서 version: 을 읽지 못했다');
}

/// CHANGELOG 최상단 제목 `## X.Y.Z - <날짜 자리>` — ` - ` 앞 토큰이 버전, 뒤가 날짜 자리 (VERSIONING.md 81 ~ 82행).
({String version, String dateSlot}) changelogTop(String repoRoot) {
  final lines = splitYamlLines(File('$repoRoot/CHANGELOG.md').readAsStringSync());
  final heading = lines.firstWhere((l) => l.startsWith('## '), orElse: () => '');
  if (heading.isEmpty) throw const FormatException('CHANGELOG.md 에 `## ` 제목이 없다');
  final body = heading.substring(3).trim();
  final cut = body.indexOf(' - ');
  if (cut < 0) throw FormatException('CHANGELOG.md 최상단 제목에 ` - ` 가 없다: $heading');
  return (version: body.substring(0, cut).trim(), dateSlot: body.substring(cut + 3).trim());
}

/// [tag] 가 null 이면 평소 push (1), 아니면 tag 검사 (2)(3). 어긋남마다 한 줄.
List<String> checkVersionAgreement(String repoRoot, {String? tag}) {
  final out = <String>[];
  final pubspec = pubspecVersionText(repoRoot);
  final release = pubspecReleaseVersion(repoRoot);
  final top = changelogTop(repoRoot);
  if (tag == null) {
    if (release != top.version) {
      out.add('`pubspec.yaml` 의 version ($pubspec → $release) 과 CHANGELOG 최상단 버전 (${top.version}) 이 다르다.');
    }
    return out;
  }
  final tagVersion = RegExp(r'^v(\d+\.\d+\.\d+)$').firstMatch(tag)?.group(1);
  if (tagVersion == null) {
    out.add('tag 이름 `$tag` 이 `vX.Y.Z` 꼴이 아니다 — 이 저장소의 `v` tag 는 패키지 릴리스 전용이다.');
    return out;
  }
  if (pubspec != tagVersion) {
    out.add('tag `$tag` 의 버전 ($tagVersion) 과 `pubspec.yaml` 의 version ($pubspec) 이 다르다'
        '${pubspec == '$tagVersion-dev' ? ' — `-dev` 꼬리가 남아 있다.' : '.'}');
  }
  if (top.version != tagVersion) {
    out.add('tag `$tag` 의 버전 ($tagVersion) 과 CHANGELOG 최상단 버전 (${top.version}) 이 다르다.');
  }
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(top.dateSlot)) {
    out.add('CHANGELOG 최상단 제목의 날짜 자리가 `YYYY-MM-DD` 꼴이 아니다: `${top.dateSlot}` (릴리스 때 날짜로 바꾼다).');
  }
  return out;
}

// main 쪽 — 인자가 우선, 없으면 CI 의 tag push.
final env = Platform.environment;
final ciTag = env['GITHUB_REF_TYPE'] == 'tag' ? env['GITHUB_REF_NAME'] : null;
final effective = tagArg ?? ciTag;
```

### IN-12 고친 판 (`keysSeenByLineReader`, 함수 단위로 확인 — `dart format` 0 changed, `dart analyze` No issues)

```diff
   final listItemPattern = RegExp(r'^-(?:[ \t]|$)');
+  // 아래 줄 가운데 키처럼 보이는 줄 — `이름:` · `"이름":` · `'이름':` · `이름 :`.
+  // `package:…` 처럼 콜론 뒤에 공백 · 줄 끝이 없는 스칼라 값 줄은 키가 아니다 (05-REVIEW.md IN-12).
+  final keyLikePattern = RegExp(
+    r'''^(?:"[^"]*"|'[^']*'|[^\s#'"][^#]*?)[ \t]*:(?:[ \t]|$)''',
+  );
   // findUnexpectedKeys 가 돌려준 `<줄 번호>행: <원문>` 에서 원문만 뗀다.
@@
       final text = textOf(shown).trim();
-      if (listItemPattern.hasMatch(text)) continue;
+      if (listItemPattern.hasMatch(text) || !keyLikePattern.hasMatch(text)) {
+        continue;
+      }
```

### 릴리스 커밋의 명령 (§ 5 실측 그대로)

```sh
sed -i '' 's/^version: 2\.0\.0-dev$/version: 2.0.0/' pubspec.yaml
sed -i '' '1s/^## 2\.0\.0 - 미출시$/## 2.0.0 - YYYY-MM-DD/' CHANGELOG.md
fvm dart pub get
for d in example fixtures/base_codegen fixtures/base_only fixtures/base_riverpod fixtures/overrides fixtures/recommended; do (cd "$d" && fvm dart pub get); done
git diff --stat            # 7 files changed, 7 insertions(+), 7 deletions(-)  (+ pubspec 주석 IN-13 만큼)
fvm dart run tool/verify.dart --tag v2.0.0   # 10/10, 종료 코드 0
```

### smoke 스크립트 뼈대 (실측 절차를 Dart 로 옮긴 꼴 — spike 015 `probe.dart` 의 함수 이름)

```dart
// tool/smoke.dart <ref> — dart:io · dart:convert 만.
final work = Directory.systemTemp.createTempSync('woody_smoke_');
final app = '${work.path}/app';
final pubCache = '${work.path}/pub-cache';
final flutter = '${flutterRoot(Platform.resolvedExecutable)}/bin/flutter'; // dart 에서 다섯 단계 위
await run(flutter, ['create', '--platforms=android', '--project-name', 'smoke_app', app]);
// pubspec.yaml: dev_dependencies 끝에 README 설치 블록(ref: <인자>), dependencies 의 cupertino_icons 뒤에 flutter_riverpod: ^3.0.0
// analysis_options.yaml: include 줄만 package:woody_lints/recommended.yaml 로
// lib/smoke_violations.dart: added_rules.dart 29행 + riverpod_rules.dart 12 ~ 18행
await run(flutter, ['pub', 'get'], cwd: app, env: {'PUB_CACHE': pubCache});   // README 의 명령
final lock = lockEntry('$app/pubspec.lock');                                   // source · url · resolved-ref
final expectedSha = await git(['rev-parse', '$ref^{commit}'], cwd: repoRoot);
for (final (name, include) in [('recommended', 'package:woody_lints/recommended.yaml'), ('alias', 'package:woody_lints/analysis_options.yaml')]) {
  // include 줄 바꾸기 → 상태 폴더 '${work.path}/state-$name' 로
  final r = await Process.run(Platform.resolvedExecutable, ['--suppress-analytics', 'analyze', '--format=json'],
      workingDirectory: app, environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': '${work.path}/state-$name', 'PUB_CACHE': pubCache});
  // 머리말 contains → 종료 코드 0/2/3 + JSON → normalizeDiagnostics(stdout, app) 에 두 줄이 있는가 → pluginFolders == 1, readPluginVersion
}
```

### tag · 원격 증거 (01-01 의 꼴)

```sh
git tag -a v2.0.0 -m "woody_lints 2.0.0" -m "SDK 하한 ^3.13.0, 프리셋 분리, 규칙 재선정 — CHANGELOG 2.0.0" <릴리스 커밋>
git cat-file -t v2.0.0 && git rev-parse 'v2.0.0^{commit}'
git show v2.0.0:pubspec.yaml | grep -nx 'version: 2.0.0' && git show v2.0.0:CHANGELOG.md | head -1
# (checkpoint) 뒤
git push origin v2.0.0
git ls-remote --tags origin        # <tag 객체>\trefs/tags/v2.0.0 와 <커밋>\trefs/tags/v2.0.0^{}
git ls-remote --heads origin       # 브랜치 둘 그대로
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| 검증 명령이 `example/pubspec.lock` 만 커밋 (Phase 2) | lock 여섯 (`fixtures/` 다섯 포함) | Phase 3 | version 변경 때 여섯 폴더의 `pub get` |
| README `ref:` ↔ pubspec 만 견줌 ((g), Phase 5) | + tag ↔ pubspec ↔ CHANGELOG ((i), 이 phase) | 이 phase | tag push 의 CI 와 로컬 `--tag` |
| smoke 는 spike 015 의 로컬 git 경로 | 실제 GitHub 주소 · 새 pub cache (이번 조사에서 처음 돌림) | 2026-10-15 | "받아 오는 길" 이 더는 재지 않은 항목이 아니다 — 단 tag 로 받는 것은 아직 (v2.0.0 이 없다) |

**Deprecated/outdated:** workflow 5 ~ 7행 주석의 "Phase 6 이 tag 전용 검사를 더할 때" 는 더한 뒤 현재형으로 (선택). `VERSIONING.md` 82행의 "Phase 6 에서 만드는 일치 검사" 도 같다.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | annotated tag push 에서 `GITHUB_SHA` 가 tag 객체인지 커밋인지는 문서에 없지만, checkout 되는 파일은 그 tag 의 커밋 트리라 검사 판정에 영향이 없다 | § 1 | 영향 없음 — 검사는 `GITHUB_REF_NAME` 과 파일만 읽는다. 진짜 tag 실행의 로그로 확인된다 (D-06) |
| A2 | `flutter_riverpod` 를 `cupertino_icons` 뒤, `woody_lints` 를 `dev_dependencies` 끝에 두면 `sort_pub_dependencies` 가 나지 않는다 | § 3 | 두 줄이 더 나올 뿐 판정(두 위반의 존재)은 그대로 |
| A3 | `gh run list --branch v2.0.0` 이 tag push 의 실행을 거른다 (`head_branch` 에 tag 이름) | § 7 · § 8 | `gh api …/actions/runs` 의 `head_branch` 로 고르면 된다 — 대안을 적어 두었다 |
| A4 | `flutter create` 를 플랫폼 하나(`android`)로 만든 템플릿이 README 따라 하기의 대표로 충분하다 (옵션 파일 모양은 플랫폼 수와 무관) | § 4 | 템플릿 원본의 `{{#android}}` 등은 제외 줄 수만 바꾼다 — 판정과 무관 |
| A5 | `pull_request` 이벤트의 `GITHUB_REF_TYPE` 은 `branch` 다 (문서는 `branch` / `tag` 두 값만 적는다) | § 1 | tag 모드로 잘못 돌면 PR 실행이 `-dev` 로 실패 — PR 을 여는 단계에서 바로 보인다 (02-UAT 4번 확인과 같은 자리) |

## Open Questions

1. **tag 실행을 `gh` 로 고르는 정확한 필터** — A3. 추천: 실행 id 를 Actions 화면에서 읽고 `gh run view <id> --log`.
2. **`checkShippedComposition` 의 서명 변경이 `example/README.md` 의 "함수 단위" 기록과 충돌하는가** — 선택 인자이므로 기존 호출은 그대로다. 기록 문구(`checkShippedComposition`)는 바뀌지 않는다.
3. **CHANGELOG 날짜와 tag 날짜가 다를 때의 기록** — 권고는 § 8 (그대로 두고 SUMMARY 에 적는다). 계획이 확정한다.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter / Dart (FVM) | 검증 · smoke · `flutter create` | ✓ | 3.47.5 / 3.13.4 `[VERIFIED]` | — |
| git (ssh remote) | tag · push · ls-remote · clone --local | ✓ | 로컬 설치본 (`ls-remote` 성공) | — |
| `gh` | PR · 실행 확인 · `workflow run` | ✓ 로그인 `woodkill` | 2.102.0 `[VERIFIED]` | GitHub 웹 화면 |
| 네트워크 (GitHub · pub.dev) | smoke (받기 · plugin), 검증(plugin) | ✓ (이번 조사의 `flutter pub get` 이 GitHub 에서 받음) | — | 없음 — smoke 는 네트워크 없이 못 돈다 |
| python3 등 다른 런타임 | 없음 | — | — | — |

**Missing dependencies with no fallback:** 없음.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | 없음 (테스트 패키지 · `test/` 없음). 하네스는 `tool/verify.dart` 단계 10개 (`[3/10]` 에 (i)), `tool/smoke.dart`, 루트 `fvm dart analyze`, `fvm dart format --output=none --set-exit-if-changed tool`, 05-RESEARCH § 6 의 grep 셋, `example/README.md` 의 지워 보기 기록 (M92 ~), git · gh 의 읽기 명령 |
| Config file | `tool/verify.dart` 의 상수 · `.fvmrc` · `example/expected_diagnostics.txt` 등 정답지 다섯 |
| Quick run command | `fvm dart analyze && fvm dart run tool/verify.dart` (plugin 준비된 상태 약 22초) |
| Full suite command | 위 + `fvm dart format --output=none --set-exit-if-changed tool` + `fvm dart run tool/verify.dart --tag v2.0.0` (릴리스 커밋 뒤) + 비공개 점검 (1) ~ (3) + `fvm dart run tool/smoke.dart <ref>` (약 45초, 네트워크) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| REL-03 | 평소 모드: 지금 상태 통과 | 실행 | `fvm dart run tool/verify.dart` rc 0, `점검 통과 (10개 중 10개)`, stderr 에 `버전 일치 검사: 평소` | ❌ (i) — Wave 0 |
| REL-03 | tag 모드: 릴리스 커밋 통과 | 실행 | `fvm dart run tool/verify.dart --tag v2.0.0` rc 0 | ❌ |
| REL-03 | D-06 다섯 입력에서 실패 | 지워 보기 (복제본, 함수 단위 + 전체 1회) | M92 ~ M96: `passed=false` 와 § 2 의 블록 문구; M93 전체 실행 rc 1 · `[3/10]` 실패 · `점검 실패 (10개 중 1개)` | ❌ |
| REL-03 | 사용법 — `--tag` 값 없음 · 모르는 인자 | 실행 | `fvm dart run tool/verify.dart --tag` rc 64, `--bogus` rc 64 | ❌ |
| REL-03 | CI 의 tag 트리거가 검사를 부른다 | 원격 (사람 + gh) | `gh run view <tag 실행 id> --log \| grep -n '버전 일치 검사: tag v2.0.0'` 과 `점검 통과` | 원격 — tag push 뒤 |
| (IN-12) | `include:` 값을 다음 줄에 — 통과로 | 지워 보기 | M97: 고친 뒤 `passed=true`; M78 회귀 블록 그대로 | ❌ |
| (IN-14 · UAT 5) | 문장 · 주석 | grep | `grep -n '255' tool/verify.dart \| head -3`, `grep -c '판이 같은지는 재지 않았다' example/README.md` = 1, `sed -n 1986p tool/verify.dart` 가 "main 도 받지 않아" 를 담음 | ❌ |
| (IN-13 · UAT 2 · 4 · D-11 · D-14) | README · pubspec 문장 | grep + `[3/10]` | `grep -n 'lib/base.yaml 이' pubspec.yaml`, `! grep -q '병합 여부는 확인하지 않았다' README.md`, `grep -c '3.47.2' README.md` ≥ 1, `grep -c '재시작 자체를' README.md` = 1, `grep -c '릴리스 절차' README.md` ≥ 1, `grep -c '기존 .include' README.md` ≥ 3; `fvm dart run tool/verify.dart` 10/10 | ❌ |
| (D-11 · D-12) | `VERSIONING.md` 새 절 | grep | `grep -n '^## 릴리스 절차' VERSIONING.md`; 절 안에 `fvm dart pub get` · `pub upgrade` (하지 않는다) · `--update` · `--tag` · `smoke.dart` · `ls-remote` · `--merge` 가 각 1회 이상 | ❌ |
| REL-02 | lock 여섯이 version 과 같다 | 실행 + diff | 릴리스 커밋에서 `git diff --stat HEAD~1 -- example/pubspec.lock fixtures/*/pubspec.lock` 이 6 파일 · 각 `1 +/1 -`; `grep -c 'version: "2.0.0"' example/pubspec.lock fixtures/*/pubspec.lock` 각 1; 검증 10/10 | ❌ (릴리스 커밋) |
| REL-02 | annotated tag 가 원격에 있고 내용이 맞다 | git (원격 읽기) | `git ls-remote --tags origin \| grep -F "$(git rev-parse 'v2.0.0^{commit}')$(printf '\t')refs/tags/v2.0.0^{}"`; `git cat-file -t v2.0.0` = `tag`; `git show v2.0.0:pubspec.yaml \| grep -qx 'version: 2.0.0'`; `git show v2.0.0:CHANGELOG.md \| head -1 \| grep -qE '^## 2\.0\.0 - [0-9]{4}-[0-9]{2}-[0-9]{2}$'` | 원격 — push 뒤 |
| REL-02 | `main` 병합이 merge commit 이고 tag 커밋이 조상 | git · gh | `git merge-base --is-ancestor v2.0.0 origin/main`; `test "$(git log -1 --format=%P origin/main \| wc -w)" = 2`; `gh pr view <n> --json mergedAt,mergeCommit` | 원격 — 병합 뒤 |
| REL-04 | 예행 — 릴리스 커밋을 GitHub 에서 받아 두 주소 둘 다 보고 | 실행 (네트워크) | `fvm dart run tool/smoke.dart <sha>` rc 0, 화면에 `prefer_single_quotes` · `provider_parameters` 각 2회, `resolved-ref` = sha | ❌ 스크립트 — Wave 0 |
| REL-04 | tag 로 같은 판정 | 실행 (네트워크) | `fvm dart run tool/smoke.dart v2.0.0` rc 0, `resolved-ref` = `git rev-parse 'v2.0.0^{commit}'` | 원격 — tag 뒤 |
| REL-04 | README 를 사람이 따라 한다 (D-10) · D-14 측정 | 사람 (checkpoint) | 예행 때 한 번 — 결과를 SUMMARY 와 README 「프로젝트 전체」 문장에 | — |
| (02-UAT 4 · 6) | PR 실행 · 수동 실행 | gh + 화면 | `gh run list --workflow verify --event pull_request --limit 1` success; `gh workflow run verify --ref main` 뒤 `gh run list --workflow verify --event workflow_dispatch --limit 1` success; 버튼은 사람이 | 원격 |
| (D-20 · D-21) | 비공개 정보 없음 | grep | 05-05 Task 1 의 점검 (1) ~ (3) (phase 폴더 · 제외 목록만 바꿈) 0줄 | ✓ 명령만 |

### Sampling Rate

- **Per task commit:** `fvm dart analyze` + `fvm dart format --output=none --set-exit-if-changed tool` + `fvm dart run tool/verify.dart` (rc 0, 10/10) + 비공개 점검 (1) · (2).
- **Per wave merge:** 위 + 그 wave 의 M 기록을 복제본에서 실제로 만들어 돌리고 되돌림 (`git status --porcelain` 빈 출력); 릴리스 커밋 wave 는 `--tag v2.0.0` 10/10 과 `git diff --stat` 7 파일.
- **Phase gate:** 브랜치 push 뒤 GitHub `verify` success, 예행 smoke 통과, tag push 뒤 tag 실행 success (로그의 tag 모드 줄), `smoke.dart v2.0.0` 통과, `ls-remote` 증거, PR 실행 · 병합 · `workflow_dispatch` 실행 success, 비공개 점검 범위 전체 0줄, `02-UAT.md` 4 · 6번과 `05-UAT.md` 1 · 2 · 4 · 5번 · 05-REVIEW IN-12 ~ 14 의 처리 기록 갱신.

### Wave 0 Gaps

- [ ] `tool/verify.dart` — (i) `checkVersionAgreement` + `pubspecVersionText` + `changelogTop`, `main` 의 `--tag`, stderr 모드 줄, IN-12, IN-14 주석 (wave 1)
- [ ] `tool/smoke.dart` (wave 1 — 예행 전에 있어야 한다)
- [ ] `example/README.md` 새 소절 (06-NN) M92 ~ M97 (wave 1)
- 프레임워크 설치: 없음

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (공개 저장소, 받기는 인증 없음; `gh` · ssh 는 소유자의 기존 자격) | — |
| V3 Session Management | no | — |
| V4 Access Control | yes (원격 쓰기) | tag push · `main` 병합은 blocking-human checkpoint 뒤에만, 명령은 이름 하나만 (`git push origin v2.0.0`), `--force` 없음 |
| V5 Input Validation | yes | `--tag` 값은 `^v\d+\.\d+\.\d+$` 만 받는다 (D-06 다섯째); smoke 의 `<ref>` 는 git 에 그대로 넘기므로 `-` 로 시작하는 값은 거부 (인자 주입) |
| V6 Cryptography | no | — |

### Known Threat Patterns for this phase

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| 비공개 프로젝트의 경로 · 이름이 공개 저장소에 실림 | Information disclosure | push 전 비공개 점검 (1) ~ (3) 범위 전체 (§ 8), smoke 출력의 임시 폴더 경로 제거 |
| 잘못된 커밋에 tag → 옮길 수 없다 | Tampering / Repudiation | 예행이 본 sha 와 tag 대상 sha 비교, 4중 점검, checkpoint |
| `main` 을 squash 로 합쳐 tag 커밋이 이력에서 빠짐 | Tampering | `gh pr merge --merge`, 병합 뒤 `merge-base --is-ancestor` |
| smoke 가 평소 pub cache · `~/.dartServer` 를 써서 "받았다" 가 거짓 | Spoofing (증거) | `PUB_CACHE` · 상태 폴더를 임시 폴더로, lock 의 `url` · `resolved-ref` 를 찍는다 |
| 일치 검사를 평소 push 에서 우회 (`-dev` 와 `미출시` 로 tag) | Tampering | tag 모드는 꼬리 없이 정확히 · 날짜 꼴 (D-04 · D-05) — M93 · M95 |

## Sources

### Primary (HIGH confidence)
- 저장소 파일 (이 세션에서 읽음): `tool/verify.dart` (1 ~ 80, 525 ~ 575, 1585 ~ 1625, 1860 ~ 1935, 1965 ~ 2175, 2440 ~ 2520, 2754 ~ 2800, 2800 ~ 2927행), `.github/workflows/verify.yml`, `pubspec.yaml`, `CHANGELOG.md` 1 ~ 12행, `VERSIONING.md`, `README.md` (1 ~ 60, 215 ~ 382행), `example/README.md` (1 ~ 60, 105 ~ 130, 594 ~ 630행), `example/expected_diagnostics.txt`, `example/lib/{added_rules,base_rules,riverpod_rules,main}.dart`, `example/pubspec.yaml`, lock 여섯의 `woody_lints` 항목, `lib/*.yaml`, `analysis_options.yaml`, `.gitignore`, `.fvmrc`
- 실행 (저장소 밖, Flutter 3.47.5 / Dart 3.13.4, 2026-10-15): REL-03 prototype 과 D-06 다섯 입력, IN-12 고친 판과 회귀 둘, version 변경 → 69 → lock 여섯 `pub get` → 10/10, `flutter create` 빈 프로젝트의 GitHub 받기 · 두 주소 분석 · D-14 측정
- spike references: `git-dependency-and-upgrade.md`, `analyze-run-and-verdict.md`, `ci-workflow.md`, `suppression-and-exclude.md`, `sources/015-git-dependency-preset-load/probe.dart`
- 앞 phase 문서: `06-CONTEXT.md`, `01-01-SUMMARY.md`, `02-UAT.md` 4 · 6번, `02-VERIFICATION.md` 7번, `05-REVIEW.md` IN-12 ~ 14, `05-REVIEW-DISPOSITION.md`, `05-UAT.md`, `05-05-PLAN.md` Task 1, `05-RESEARCH.md` § 6 · Validation Architecture, `01/02/03-CONTEXT.md` Deferred
- GitHub Actions 문서 (2026-10-15 읽음): https://docs.github.com/en/actions/reference/workflows-and-actions/variables (`GITHUB_REF_TYPE` · `GITHUB_REF_NAME` · `GITHUB_SHA`), https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows (`push` 의 `GITHUB_SHA` "Tip commit pushed to the ref", `tags:` 필터)
- `gh` 2.102.0 `--help` (pr merge · pr create · workflow run · run list), Flutter 3.47.5 설치본의 `templates/app/analysis_options.yaml.tmpl`

### Secondary (MEDIUM confidence)
- CONTEXT 가 2026-10-15 에 읽은 외부 문서 (이 세션에서 다시 열지 않음): GitHub merge methods, workflow_dispatch 와 기본 브랜치 (community #178194), firehose, dart.dev Git packages · pub get

### Tertiary (LOW confidence)
- A1 ~ A5 (Assumptions Log)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 새 의존성 없음, 도구 버전을 실행으로 확인
- Architecture: HIGH — 검사 · IN-12 · lock · smoke 의 네 동작을 실제로 돌렸다; 남는 추정은 tag 실행의 `gh` 필터와 `GITHUB_SHA` 의 값뿐이고 판정에 영향이 없다
- Pitfalls: HIGH — 대부분 이번 실측(69 의 문구, `sort_pub_dependencies`, LEAK 거짓 양성)과 앞 phase 의 기록에서 나왔다

**Research date:** 2026-10-15
**Valid until:** 2026-11-14 (저장소 안의 사실 — 행 번호는 ① 커밋 뒤 바뀐다; GitHub 문서 · `gh` 플래그는 안정적)
