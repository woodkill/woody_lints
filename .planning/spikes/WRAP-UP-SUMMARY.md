# Spike Wrap-Up Summary

**Date:** 2026-10-12 (wrap-up 네 번 — 2026-10-11 에 001 ~ 006 과 007 ~ 008, 2026-10-12 에 009 ~ 014 와 015 ~ 016)
**Spikes processed:** 16 (이번 2개, 앞선 wrap-up 14개)
**Feature areas:** `dart analyze` 실행과 결과 판정, `example/` 프로젝트와 정답지, deprecated / removed / 없는 규칙 검사, GitHub Actions CI, 프리셋 나누기 (조각 · 묶음 · 별칭), 나눈 뒤의 연습용 프로젝트 여섯, 진단 끄기와 생성 파일 제외, git 의존성으로 받기와 버전 올리기, 다음 SDK (Dart 3.14 베타) 와 SDK 올리기
**Skill output:** `./.claude/skills/spike-findings-woody-lints/`

idea key 는 셋이다.

- `verify-harness-tool-behavior` (001 ~ 008) — 001 ~ 006 은 ROADMAP.md Phase 2 의 "Spike first" 6가지이고, 007 과 008 은 그 6개가 재지 않고 남긴 두 가지다. 8개 모두 VALIDATED 이고 02-CONTEXT.md D-15 의 멈춤 조건에 해당한 것은 없다.
- `preset-split-include-behavior` (009 ~ 015) — 009 ~ 012 는 ROADMAP.md Phase 3 의 "Spike first" 이고, 013 과 014 는 앞선 spike 끼리 맞물리는 자리다. 015 는 Phase 6 의 smoke test 가 처음 볼 예정이던 것(git 의존성으로 받았을 때의 모양)을 구조를 짓기 전에 당겨 잰 것이다 (소유자 선택 2026-10-12). 여섯이 VALIDATED, 012 가 PARTIAL 이다. 멈춤 조건(009 ~ 011 중 하나라도 실패, 015 도 같은 급)에 해당한 것은 없다. 012 는 결과가 어느 쪽이든 기록하고 계속하는 항목이었다 (03-CONTEXT.md D-07).
- `next-sdk-forward-compat` (016) — 조사 문서가 "이번 마일스톤에서 확인하지 않아도 되는 항목" 으로 둔 다음 SDK 의 동작을, 베타가 공개되어 실행으로 잴 수 있게 되자 미리 잰 것이다 (소유자 선택 2026-10-12). PARTIAL 이다 — 구조를 바꿔야 한다는 결과(멈춤 조건)는 나오지 않았고, 생성 파일 제외 하나가 달라졌다.

실측 조건: Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64 와 GitHub `ubuntu-latest` (006 만). 009 ~ 014 는 저장소의 모양을 작업 폴더에 복사한 replica 에서 `path:` 의존성으로 쟀다. 015 는 그 replica 를 로컬 git 저장소로 만들어 git 의존성으로 받았고(GitHub 에는 올리지 않았다), 016 은 같은 스크립트를 고정 SDK 와 베타(Flutter 3.49.0-0.2.pre / Dart 3.14.0-211.1.beta)로 각각 돌렸다.

## Processed Spikes

| # | Name | Type | Verdict | Feature Area |
|---|------|------|---------|--------------|
| 001 | analyze-invocation-form | standard | ✓ VALIDATED (조건: 사용 통계 전송을 끈다) | `dart analyze` 실행과 결과 판정 |
| 002 | plugin-setup-failure-exit | standard | ✓ VALIDATED | `dart analyze` 실행과 결과 판정 |
| 003 | riverpod-lint-severity-matrix | standard | ✓ VALIDATED | `example/` 프로젝트와 정답지 |
| 004 | fixture-pub-get | standard | ✓ VALIDATED | `example/` 프로젝트와 정답지 |
| 005 | initial-file-rule-status | standard | ✓ VALIDATED | deprecated / removed / 없는 규칙 검사 |
| 006 | github-runner-cold-plugin | standard | ✓ VALIDATED | GitHub Actions CI |
| 007 | root-analysis-with-example | standard | ✓ VALIDATED | `example/` 프로젝트와 정답지 (루트 제외), deprecated / removed / 없는 규칙 검사 (실행 형태) |
| 008 | state-folder-placement | standard | ✓ VALIDATED | `dart analyze` 실행과 결과 판정 |
| 009 | preset-plugin-via-include | standard | ✓ VALIDATED | 프리셋 나누기, 나눈 뒤의 연습용 프로젝트 여섯 (정답지의 모양) |
| 010 | alias-three-level-include | standard | ✓ VALIDATED | 프리셋 나누기 |
| 011 | root-analysis-after-split | standard | ✓ VALIDATED | 프리셋 나누기 (루트 옵션 파일), 나눈 뒤의 연습용 프로젝트 여섯 (루트 제외) |
| 012 | plugin-suppression-matrix | standard | ⚠ PARTIAL (여섯 칸은 성립. 묶음이 주는 생성 파일 제외는 plugin 진단에 통하지 않는다) | 진단 끄기와 생성 파일 제외 |
| 013 | rule-check-after-split | standard | ✓ VALIDATED | deprecated / removed / 없는 규칙 검사 |
| 014 | multi-fixture-plugin-cost | standard | ✓ VALIDATED | 나눈 뒤의 연습용 프로젝트 여섯, `dart analyze` 실행과 결과 판정 (상태 폴더), GitHub Actions CI (시간 추정) |
| 015 | git-dependency-preset-load | standard | ✓ VALIDATED | git 의존성으로 받기와 버전 올리기, 프리셋 나누기 · 나눈 뒤의 연습용 프로젝트 여섯 · 진단 끄기와 생성 파일 제외 (git 으로 받아도 같다는 한두 줄) |
| 016 | next-sdk-forward-compat | standard | ⚠ PARTIAL (plugin 로드와 규칙 12개는 그대로. 이 패키지가 주는 생성 파일 제외는 베타에서 규칙 진단에도 통하지 않는다 — 상류에서 되돌리는 중) | 다음 SDK (Dart 3.14 베타) 와 SDK 올리기, 그리고 기존 설계도 일곱 편의 SDK 에 따라 달라지는 자리 |

## 이번 wrap-up 에서 달라진 것 (015 ~ 016)

설계도 둘을 새로 만들었다 — `git-dependency-and-upgrade.md` (015), `next-sdk-forward-compat.md` (016). 기존 설계도 일곱 편은 바뀐 뒤의 결론으로 제자리에서 고쳐 썼다. 016 은 앞선 결론을 뒤집지 않았다 — 011 과 012 의 결론은 Dart 3.13.4 의 사실로 맞고, **범위**가 생겼다.

앞선 결론 중 달라지거나 좁혀진 것.

| 무엇 | 앞선 결론 | 지금의 결론 |
|---|---|---|
| git 의존성으로 받았을 때 | 재지 않았다. "같은 결과일 것" 이라는 추정(012), Phase 6 의 smoke test 가 처음 확인하는 자리 | `path:` 때와 줄 단위로 같다. smoke test 가 처음 보는 것은 받아 오는 길 하나다 (015) |
| 루트 분석의 plugin 준비 | 준비하지 않는다 (011) | Dart 3.13.x 의 사실이다. 베타에서는 `lib/analysis_options.yaml` 이 `plugins:` 에 닿는 한 준비하고 루트의 제외로 막지 못한다 (016) |
| `plugins_in_inner_options` | 한 파일 구조에서 루트의 제외를 먼저 지우면 난다 (011) | Dart 3.13.x 에서만 난다. 베타에서는 나오지 않는다 (016) |
| 프리셋의 생성 파일 제외 — 규칙 진단 | 통한다 (012) | Dart 3.13.x 의 사실이다. 베타에서는 통하지 않는다. 상류가 되돌리는 중이다 (016) |
| README 의 생성 파일 안내 | 사용 프로젝트의 옵션 파일에**도** 직접 적는다 (012) | 직접 적으라고 안내한다. "프리셋의 제외가 통하지 않는다" 를 굳은 사실로 적지 않는다 (016) |
| 버전 올리기 안내 | "`pub upgrade` 가 아니라 `ref:` 수정과 `pub get`" (ROADMAP.md Phase 5 Notes) | 받는 방식에 따라 다르다. `ref: main` 은 `pub upgrade woody_lints` 다 (015) |
| `flutter analyze` | plugin 진단을 내지 않는다 | Flutter 3.47.5 의 사실이다. 베타는 내지만 규칙 진단을 겹쳐 센다 (016) |

**MANIFEST.md 와 016 의 README 를 한 군데 고쳤다.** "SDK 를 올릴 때 `≠` 가 0칸이면 되돌리는 변경이 들어간 것" 이라는 문장이 원본 로그와 맞지 않았다. 베타의 `≠` 10칸을 로그에서 세면 8칸이 생성 파일 제외에서 온 것이고 2칸(R1 · R2)은 plugin 을 적는 자리의 변경(sdk#63627)에서 온 것이다. 되돌리려는 것은 앞의 것뿐이라, 되돌려져도 2칸은 남을 것이다 — "8칸이 `=` 로 돌아오는지를 본다" 로 고쳤다. "2칸이 남는다" 는 잰 것이 아니라 어느 칸이 어느 상류 변경에서 왔는지를 읽은 것이다.

커밋 전에 skill 폴더만 읽은 별도 에이전트에게 Phase 3 · Phase 5 · 릴리스 · SDK 올리기를 맡은 사람의 질문 12개를 던지고 흠을 찾게 했다. 끊긴 참조는 없었다. 어긋난 서술 9곳 · 근거보다 넓게 적힌 서술 10곳 · 어느 SDK 의 사실인지 빠진 문장 6곳 · 헷갈리는 서술 10곳이 나왔고, 사본 · 원본 로그 · `tool/verify.dart` 와 대조해 고쳤다. 그 가운데 **016 의 README 자체가 잰 것보다 넓게 적은 것**이 넷이다 (README 는 고치지 않고 skill 에서 범위를 좁혀 적었다).

- **"베타에서도 루트 분석은 0줄" 은 Dart 파일이 없는 replica 의 값이다.** 016 의 replica 에는 `tool/verify.dart` 가 없었다 (011 의 replica 에는 있었다). 실제 저장소의 루트를 베타로 분석했을 때 `tool/verify.dart` 에 진단이 나는지, 준비된 plugin 이 그 파일을 보는지는 재지 않았다. "성공 기준 4 가 두 SDK 에서 성립한다" 는 고정 SDK 에서만 확인된 말이다.
- **"루트의 제외로 막지 못한다" 에서 잰 제외는 파일 하나(`lib/analysis_options.yaml`)다.** `lib/**` 처럼 폴더째 제외한 경우는 재지 않았다 — 폴더 패턴 `example/**` 는 그 폴더의 plugin 준비를 막았다.
- **"막는 방법은 이것 하나" 는 README 의 안내를 하나로 한다는 뜻이다.** 실측에서 두 SDK 모두 막은 자리는 둘이다 (사용 프로젝트의 옵션 파일에 직접 적은 것, 사용 프로젝트 루트에 둔 파일을 include 로 부른 것).
- **기반 세트에 대한 "경고가 없었다" 는 "없어진 규칙이 없다" 까지만 말한다.** 기반 세트는 include 로 받고, include 로 받은 규칙은 없는 규칙만 보고된다.

계획이 알아야 할 것 다섯.

- **생성 파일 제외에는 축이 둘이다.** 규칙 진단 쪽은 SDK 에 든 analyzer 를, plugin 진단 쪽은 분석할 때마다 pub.dev 에서 풀리는 `analyzer` 를 따른다. 016 이 SDK 를 바꿔 달라진 것은 규칙 쪽뿐이다. 그래서 생성 파일의 **plugin 진단**을 연습용 프로젝트의 정답지에 고정하면(03-CONTEXT.md D-07 이 계획에 맡긴 자리), 저장소도 `.fvmrc` 도 그대로인데 pub.dev 의 `analyzer` 릴리스로 그 줄이 빠져 CI 가 깨질 수 있다. 추론이고, 그런 릴리스는 2026-10-12 에 없었다.
- **SDK 를 올릴 때는 `≠` 의 칸 수가 아니라 칸의 내용을 읽는다.** 10칸은 규칙 쪽만 담은 5칸, 규칙 쪽과 plugin 쪽을 한 문자열에 담은 3칸, 루트 분석의 2칸이다. 되돌리는 변경이 SDK 에만 들어가면 앞의 8칸이 돌아오고, pub.dev 쪽으로도 나오면 섞인 3칸이 다른 값으로 다시 `≠` 가 된다 (`next-sdk-forward-compat.md` 9번).
- **"SDK 를 올리기 전에 016 의 두 스크립트를 돌린다" 는 그때 그대로 되지 않을 수 있다.** 009 ~ 016 의 스크립트는 저장소의 `lib/analysis_options.yaml` 이 한 파일 구조일 때 돈다 (`Shipped.read` 가 그 파일을 잘라 조각을 만든다). Phase 3 이 저장소를 나눈 뒤에는 종료 코드 65 로 멈출 것이고, 스크립트를 고치거나 나누기 전의 커밋을 따로 꺼낸 자리에서 돌려야 한다. `pubspec.yaml` 의 SDK 하한 줄, 규칙 목록의 한 줄, `example/lib` 의 샘플, plugin 쪽 버전에도 기댄다. 스크립트를 읽은 것이고 돌려 보지는 않았다.
- **MANIFEST 의 "정답지 셋" 은 016 이 잰 칸 셋이다.** 연습용 프로젝트 여섯으로 치면 codegen 조각을 받는 넷(`example`, `recommended`, `overrides`, `base_codegen`)이 해당하고, `overrides` 는 재지 않았다.
- **ROADMAP.md 의 Phase 5 Notes · Phase 6 Notes 에 015 보다 앞서 적힌 문구가 그대로 있다** (버전 올리기 한 문장, "`main` 병합이 곧 배포", "smoke test 가 git 의존성의 plugin 로드를 처음 확인"). 이 wrap-up 은 로드맵을 고치지 않았다.

015 에서도 잰 것과 읽은 것을 갈랐다. 버전 올리기의 "tag → 새 tag", "`main` → tag" 는 그 전환 자체를 돌린 것이 아니라 "`ref:` 를 고친 뒤의 `pub get` 은 그 ref 의 커밋으로 옮긴다" (`main` → 브랜치, 브랜치 → tag 로 쟀다)에서 읽은 것이다. 잰 명령은 `dart pub …` 이고 `flutter pub …` 로는 재지 않았다.

## 앞선 wrap-up 에서 달라진 것 (009 ~ 014)

설계도 셋을 새로 만들었다 — `preset-split-structure.md` (009, 010, 011), `fixtures-after-split.md` (009, 011, 014), `suppression-and-exclude.md` (012). 013 은 기존 `rule-status-check.md` 에 들어갔고, 기존 설계도 넷은 바뀐 뒤의 결론으로 고쳐 썼다.

앞선 결론 중 달라지거나 좁혀진 것.

| 무엇 | 앞선 결론 | 지금의 결론 |
|---|---|---|
| 루트의 `lib/analysis_options.yaml` 제외 | 그대로 둔다 (Phase 2 의 요구 사항) | 파일을 나누는 커밋과 같은 커밋이거나 그 뒤에 지운다 (011) |
| 연습용 프로젝트가 늘 때의 루트 제외 | 폴더마다 제외 줄이 필요할 것이다 (007 의 예상) | 한 폴더 아래에 모으면 한 줄이다 (011) |
| 규칙 검사의 대상 | 배포 파일 하나 (005, 007) | 조각 셋을 하위 폴더에 복사해 한 번에 (013) |
| 규칙 검사의 통과 조건 | 세 코드가 없으면 통과 (005, 007) | exit 0 이고 복사본의 진단이 0건. "규칙 0개" 확인은 `base.yaml` 에만 (013) |
| `plugins:` 를 빼는 단계 | 섹션을 찾지 못하면 실패한다 (007) | 있으면 뺀다. `base.yaml` 은 그대로 복사한다 (013) |
| 종료 코드 3 | error 가 하나라도 있다 (003) | 깨진 YAML 도 3 이고 그때는 JSON 의 진단이 0건이다 (013) |
| plugin 진단을 프로젝트 전체에서 끄기 | 같은 이름으로 다시 선언해 덮어쓴다 (003) | `version` 을 함께 적어야 한다. 빼면 경고 없이 무시된다 (012) |
| JSON 의 `type` | 전부 `STATIC_WARNING` (003) | 그대로 맞다. 다만 주석의 `type=warning` 은 plugin 진단을 끄지 못하고 `type=lint` 가 끈다 (012) |
| 생성 파일 제외 | 프리셋의 제외가 생성 파일의 진단을 막는다 (잰 적 없는 전제) | 규칙 진단에만 통한다. plugin 진단에는 통하지 않고 1.3.0 도 같다 (012) |
| plugin 폴더가 0개 | 버전을 `?` 로 찍는다 (008) | plugin 을 선언하지 않는 조합에서는 정상이다 (009, 014) |
| 상태 폴더 | 저장소 안의 전용 폴더를 준다 (008) | 프로젝트가 여럿이면 프로젝트마다 따로 준다. 합치면 버전을 읽지 못한다 (014) |

MANIFEST.md 의 둘째 idea 요구 사항은 03-CONTEXT.md · ROADMAP.md 와 한 줄씩 대조했고 고칠 곳이 없었다.

커밋 전에 skill 폴더만 읽은 별도 에이전트에게 Phase 3 구현자의 질문 10개를 던졌다. 끊긴 참조는 없었고, 어긋난 서술 4곳 · 헷갈리는 서술 11곳 · 근거보다 넓게 적힌 서술 6곳을 사본과 대조해 고쳤다. 그 가운데 계획이 알아야 할 것 둘:

- **끄는 방법 여섯 칸은 한 프로젝트에 그대로 담기지 않는다.** 012 는 같은 규칙 · 같은 진단으로 옵션 파일을 바꿔 가며 따로 쟀다. 프로젝트 전체에서 끈 진단은 주석 칸의 대조 줄까지 지우므로, 프로젝트 전체에서 끄는 것과 주석으로 끄는 것을 다른 규칙 · 진단으로 고르거나 프로젝트를 둘로 나눠야 한다 (03-CONTEXT.md D-04 가 계획에 맡긴 자리다).
- **규칙 검사의 "조각 셋을 하위 폴더에" 는 문제 규칙을 넣은 두 폴더로만 쟀다.** 깨끗한 조각 셋을 하위 폴더에 두고 exit 0 · 0건이 나오는 실행은 구현하면서 처음 확인하게 된다.

## Key Findings

### 계획을 바꾸는 것

조사 문서의 추정과 달랐거나, 조사 문서에 없던 것이다.

Phase 2 (001 ~ 008).

1. **같은 `dart analyze` 가 가끔 종료 코드 255 로 죽는다 (001).** Analysis Server 가 사용 통계를 보내는 도중에 분석이 끝나면 죽는다. 이 컴퓨터에서 기본 방식 65번 중 8번이었다. `--suppress-analytics` 를 붙인 66번은 모두 정상이었다. 검증 명령은 이 플래그를 항상 붙인다.
2. **`riverpod_lint` 규칙은 "전부 warning"이 아니다 (003).** info 3 / warning 11 / error 1 이다. `registerWarningRule` 은 강도가 아니라 "기본으로 켠다"는 뜻이다.
3. **코드 생성 없이 뜨는 규칙 후보는 6개가 아니라 5개다 (003).** `protected_notifier_properties` 는 `@riverpod` 가 붙은 class 에서만 보고한다.
4. **deprecated / removed 보고는 pubspec 의 SDK 하한에 달려 있다 (005).** 배포 파일 복사본을 저장소 밖 임시 폴더에 두면 "없는 규칙"만 잡히고 나머지를 놓친다. 복사본은 저장소 안에 둔다.
5. **SDK tag 의 `rules.json` 은 실제 동작과 어긋날 수 있다 (005).** `unnecessary_await_in_return` 은 `rules.json` 에 stable 로 적혀 있지만 Dart 3.13.0 부터 deprecated 다.
6. **이미 준비된 plugin 도 네트워크가 없으면 쓰지 못한다 (002).** Analysis Server 는 뜰 때마다 `dart pub upgrade` 를 돌린다. 검증에는 네트워크가 필요하다.
7. **`dart:io` / `dart:convert` 만으로는 기본 자리(`~/.dartServer`)에서 자기 plugin 폴더를 고를 수 없다 (008).** 폴더 이름은 md5 인데 md5 가 없고, 폴더 안에 프로젝트 경로가 없고, 재실행은 어느 파일의 시각도 바꾸지 않는다. 전용 상태 폴더를 주면 plugin 폴더가 하나만 생긴다.
8. **컴파일된 plugin 파일이 잘린 채 남으면 서버는 스스로 회복하지 않는다 (008).** `plugin.aot` 이나 상태 폴더를 지울 때까지 계속 실패한다 (exit 0, plugin 진단 없음). 이때 머리말은 stderr 의 셋째 줄에 온다.
9. **같은 빈 상태 폴더를 처음 실행 둘이 동시에 쓰면 드물게 깨진다 (008).** 20쌍 중 1쌍(실행으로는 40번 중 1번)이었다. plugin 폴더에는 잠금이 없다.

Phase 3 (009 ~ 014).

10. **프리셋이 주는 생성 파일 제외는 plugin 진단에 통하지 않는다 (012).** plugin 이 쓰는 `analyzer` (14.5.0) 가 제외 패턴을 그것을 적은 파일의 폴더 기준으로 풀어서다. SDK 의 analyzer(14.1.0-dev)는 사용 프로젝트 루트 기준으로 푼다. 나눠서 생긴 일이 아니라 1.3.0 이 이미 이렇게 동작한다. 성공 기준 3 은 규칙 진단에 대한 말로 읽고, README 는 사용 프로젝트의 옵션 파일에도 제외를 적으라고 안내해야 한다.
11. **`version` 을 뺀 plugin 끄기 설정은 경고 없이 무시된다 (012).** 끄지 않은 실행과 25줄이 한 줄도 다르지 않았다. 주석으로 끌 때는 `riverpod_lint/` 접두사가 없으면 꺼지지 않는다.
12. **`// ignore_for_file: type=lint` 가 plugin 진단을 끄고 `type=warning` 은 끄지 못한다 (012).** 소스를 읽고 세운 추정과 반대였다. `riverpod_generator` 4.0.9 의 산출물은 `type=lint` 를 달고 나온다.
13. **깨진 YAML 은 JSON 에 아무것도 남기지 않는다 (013).** exit 3 인데 진단이 0건이고 stderr 도 비어 있다. `linter:` 키의 오타는 종료 코드조차 0 이다. 규칙 검사의 통과 조건은 "exit 0 이고 진단 0건" 이어야 하고 "규칙 0개" 확인을 남겨야 한다.
14. **규칙 검사의 대상이 `base.yaml` 하나면 다른 조각에 적힌 문제 규칙을 놓친다 (013).** 정답지 비교도 없는 규칙만 잡고 deprecated 와 removed 는 놓친다. 조각 셋을 모두 대상으로 둔다.
15. **폴더를 인자로 준 분석은 include 로 닿은 `plugins:` 도 준비한다 (013).** 묶음이나 별칭을 규칙 검사의 대상에 넣으면 10초와 네트워크가 든다. 루트에서 인자 없이 돌릴 때는 준비하지 않는다 (011).
16. **"기본만" 을 받는 연습용 프로젝트의 정답지는 `exit 0` 이 아니라 `exit 2` 다 (009).** `invalid_annotation_target` 이 warning 이다. 종료 코드가 0 인 것은 "기본 + codegen" 하나뿐이다.
17. **plugin 준비는 폴더가 다르면 나눠 쓰지 못하고, 상태 폴더를 합치면 버전을 읽지 못한다 (014).** plugin 을 쓰는 프로젝트 넷이 각각 컴파일한다. 상태 폴더는 프로젝트마다 따로 둔다.
18. **한 파일 구조에서 루트의 제외를 먼저 지우면 루트 분석이 exit 2 가 된다 (011).** 지우는 것은 나누는 커밋이거나 그 뒤다.

받는 방식과 다음 SDK (015 ~ 016).

19. **`ref: main` 을 따르는 프로젝트는 `pub get` 으로는 새 커밋을 받지 않는다 (015).** lock 이 커밋을 못박고 있다. `pub upgrade woody_lints` 를 해야 들어온다. `main` 병합이 다섯 프로젝트에 곧바로 닿는 것이 아니고, 로드맵의 "버전 올리기는 `ref:` 수정과 `pub get`" 은 tag 로 고정한 쪽의 말이다.
20. **`ref:` 만 고치고 lock 을 그대로 둔 채의 `--enforce-lockfile` 은 종료 코드 65 다 (015).** lock 을 커밋하는 프로젝트는 `ref:` 를 고친 뒤 `pub get` 으로 lock 을 함께 갱신해 커밋한다.
21. **프리셋이 주는 생성 파일 제외는 다음 SDK 의 베타에서 규칙 진단에도 통하지 않는다 (016).** 옛 주소 · 묶음의 정답지가 16줄 → 20줄, 기본 + codegen 이 13줄 → 17줄이 된다. 한 파일 구조(1.3.0)도 같다 — 나눠서 생기는 일이 아니다. 상류가 `P1` 버그(sdk#64549)로 다루며 되돌리는 변경을 리뷰하고 있어(2026-10-11) 정식 3.14 에서 어느 쪽일지는 모른다. README 는 "사용 프로젝트의 옵션 파일에 직접 적는다" 를 안내하고 "통하지 않는다" 를 굳은 사실로 적지 않는다.
22. **베타에서는 저장소 루트의 분석이 plugin 을 준비한다 (016).** `lib/analysis_options.yaml` 이 `plugins:` 에 닿는 한 그렇고(한 파일 구조든 별칭이든), 그 파일을 루트에서 제외해도 막지 못했다 (`lib/**` 로는 재지 않았다). Dart 파일이 없는 replica 에서 진단은 0줄이고 시간이 0.5초에서 10초가 된다. `plugins_in_inner_options` 는 나오지 않는다. 루트 옵션 파일의 주석에 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다.
23. **고정 SDK 를 올리는 날 정답지가 깨질 수 있고, 그것은 저장소의 변경 때문이 아니다 (016).** `.fvmrc` 를 올리기 전에 016 의 두 스크립트를 그 SDK 로 돌려 생성 파일 제외의 8칸이 돌아왔는지 본다.

### 예상대로 확인된 것

1. `example/` 을 작업 디렉터리로 두고 인자 없이 실행하면 plugin 진단이 처음 실행과 재실행 모두에서 빠짐없이 나온다 (001). 하위 폴더를 인자로 주면 전부 잃는다.
2. plugin 준비가 실패해도 종료 코드는 남은 진단의 강도만 따른다 (002). 4 는 진단이 하나도 없을 때만 나온다. stdout 은 멀쩡한 JSON 이고, stderr 에 `An error occurred while executing an analyzer plugin:` 이 찍힌다.
3. `dart pub get` 은 Flutter 프로젝트에서 되고 옵션 파일을 건드리지 않는다 (004). `flutter pub get` 은 옵션 파일 맨 위에 `build/**` 제외를 써넣는다.
4. 캐시 없는 GitHub Linux runner 에서 plugin 진단이 빠지지 않는다 (006). 새 가상 머신 10대, 분석 60번이 모두 로컬의 기대 진단과 같았다.
5. 루트에 점으로 시작하지 않는 `example/` 이 생기면 루트 분석에 섞인다 (007). `pub get` 전에는 error 6건(exit 3), 후에는 별도 context root 가 되어 plugin 까지 준비한다(exit 2, 15초). 루트에 `example/**` 를 제외하면 두 상태 모두 0건이고, 그 제외는 `example/` 안에서의 분석을 건드리지 않는다.
6. 상태 폴더의 자리(프로젝트 밖 / 안의 점 폴더 / 안의 평범한 폴더)는 진단도 시간도 바꾸지 않는다 (008).
7. 준비된 상태 폴더를 함께 쓰는 것, 오래 떠 있는 서버(`dart language-server`) 옆에서 쓰는 것, 분석 도중의 Ctrl-C 는 문제가 없었다 (008).
8. 이름이 `analysis_options.yaml` 이 아닌 조각(`riverpod.yaml`)의 `plugins:` 가 include 로 로드된다 (009). 조각 조합 넷이 같은 내용을 한 파일에 둔 것과 진단 · 종료 코드가 같다. include 순서는 결과를 바꾸지 않는다.
9. 옛 주소 → 묶음 → 조각의 3단 include 에서 plugin 이 로드되고, 옛 주소와 묶음 주소가 둘 다 지금의 정답지와 한 줄도 다르지 않다 (010). 6단까지 늘려도 같다. `package:` 주소와 상대 경로의 결과가 같다.
10. `riverpod_lint` 선언을 `^3.1.9` 로 올려도 정답지는 바뀌지 않는다 (010).
11. 나눈 구조에서는 루트의 `lib/analysis_options.yaml` 제외를 걷어내도 루트 분석이 0건이고 plugin 을 준비하지 않는다 (011). 걷어낸 뒤의 루트 분석은 별칭 사슬이 풀리는지를 함께 본다.
12. 끄는 방법 여섯 칸(프로젝트 전체 / 파일 하나 / 한 줄 × 규칙 / plugin)이 모두 끈 것만 사라지게 한다 (012).
13. `base.yaml` 을 그대로 복사한 규칙 검사는 문제 규칙 셋을 원본과 같은 줄 번호로 잡는다 (013).
14. 지금 검증 명령의 방식(폴더마다 따로, 상태 폴더도 따로)을 여섯으로 그대로 늘려도 된다 (014).
15. 나눈 구조를 git 의존성으로 받아도(패키지가 pub cache 에 놓여도) plugin 이 로드되고, 옛 주소와 묶음 주소가 지금의 정답지와 한 줄도 다르지 않다 (015). 한 파일 구조에서 나눈 구조로 옮겨 간 프로젝트는 옛 주소 한 줄을 그대로 둔 채 같은 16줄을 받는다.
16. 생성 파일 제외의 모양은 git 의존성과 `path:` 가 줄 단위로 같다 (015). 012 가 추정으로 남긴 것이다.
17. include 로 받는 `plugins:` 는 베타에서도 한 파일 구조 · 3단 별칭 · 묶음 · 조각 조합에서 모두 로드되고, 생성 파일의 4줄을 빼면 진단의 내용 · 강도 · 줄 번호가 같다 (016). 구조는 그대로 간다.
18. 지금 규칙 12개는 베타에서 deprecated / removed 가 아니다 — pubspec 의 SDK 하한을 `^3.14.0` · `^3.99.0` 으로 올려도 0건이다. 규칙 검사의 형태는 베타에서도 0.5초이고 plugin 을 준비하지 않는다 (016).
19. 연습용 프로젝트 폴더를 루트에서 제외하는 방식은 베타에서도 통한다 (016).
20. plugin 진단 확인을 `dart analyze` 로 한다는 제약은 베타에서도 둔다 (016). 베타의 `flutter analyze` 는 plugin 진단을 내지만 규칙 진단을 겹쳐 세어 37건, 다시 돌리면 47건이었다.

### 확정된 값

| 무엇 | 값 | 출처 |
|---|---|---|
| 정답지 맨 위 줄 | `exit 2` (`missing_provider_scope` + `avoid_public_notifier_properties`) | 003 |
| plugin 준비 실패를 알아채는 문구 | `An error occurred while executing an analyzer plugin:` (`contains` 로 찾는다) | 002, 008 |
| 처음 실행 / 재실행 (로컬) | 약 15~18초 / 약 3.6~6초 | 001, 002, 006, 008 |
| 처음 실행 / 재실행 (GitHub runner) | 약 43초 (27~53초) / 약 8초 | 006 |
| plugin 을 다시 컴파일만 할 때 (로컬) | 약 13초 | 008 |
| CI job 하나 | 약 2분. `timeout-minutes: 10` | 006 |
| pub 서버에 닿지 못할 때 | 26~31초 뒤 plugin 진단 없이 끝남 | 002 |
| `--enforce-lockfile` 이 어긋날 때 | 종료 코드 65 | 004 |
| 지금 선언된 규칙 12개 | deprecated / removed / 없는 규칙 없음 | 005, 007, 013 |
| 루트 분석 (`example/**` 제외가 있을 때) / 규칙 검사 | 0.5초 / 0.5초 | 007 |
| 루트 옵션 파일에 더할 줄 | `example/**` (`example` 만 적어도 같았다) | 007 |
| 전용 상태 폴더의 plugin 폴더 수 | 1 (plugin 을 선언하지 않는 조합은 0) | 008, 014 |
| 지금의 `example/` 정답지 | `exit 2` · 16줄 | 009 ~ 014 의 대조 기준 |
| 조합별 정답지 | 기본만 `exit 2` · 18줄 / 기본 + Riverpod `exit 2` · 21줄 / 기본 + codegen `exit 0` · 13줄 | 009 |
| 조각의 자리 (지금 파일 기준) | `base.yaml` 1 ~ 41행과 59 ~ 64행, `codegen.yaml` 42 ~ 48행, `riverpod.yaml` 49 ~ 58행 | 009 의 `Shipped` |
| 묶음과 별칭의 주소 | `package:woody_lints/…` | 009, 010, 011 |
| 나눈 뒤의 루트 분석 | exit 0, 0건, 0.6초, plugin 준비 없음 | 011 |
| 새 연습용 프로젝트의 루트 제외 | `'<폴더>/**'` 한 줄 (`fixtures/**` 로 쟀다) | 011 |
| 규칙 검사의 복사본 (나눈 뒤) | `build/woody_rule_check/<조각 이름>/analysis_options.yaml` | 013 |
| 깨진 YAML 의 신호 | exit 3, JSON 의 진단 0건, stderr 없음 | 013 |
| 연습용 프로젝트 여섯 (로컬, 차례로) | 처음 66초, 재실행 20 ~ 21초 | 014 |
| 연습용 프로젝트 여섯 (로컬, 동시에) | 처음 23초 | 014 |
| 연습용 프로젝트 여섯의 CI job | 약 4분 20 ~ 30초 — **추정**, 재지 않았다 | 014 |
| plugin 쪽에서 풀린 `analyzer` / `analysis_server_plugin` | 14.5.0 / 0.3.24 (2026-10-12. 베타에서도 같은 값) | 012, 015, 016 |
| git 으로 받은 패키지의 자리 | `<PUB_CACHE>/git/<저장소 이름>-<커밋 해시>/`. lock 은 `source: git`, `ref`, `resolved-ref: <커밋 해시>` | 015 |
| annotated tag 를 `ref:` 에 적었을 때 lock 의 `resolved-ref` | tag 자신의 해시가 아니라 그 tag 가 가리키는 커밋의 해시 | 015 |
| `ref:` 만 고친 직후의 `pub get --enforce-lockfile` | 종료 코드 65, ``Unable to satisfy `pubspec.yaml` using `pubspec.lock`.`` | 015 |
| git 의존성에서의 처음 실행 | 14.8 ~ 15.2초 (`path:` 와 같다) | 015 |
| 베타에서의 정답지 | 옛 주소 · 묶음 `exit 2` · 20줄, 기본 + codegen `exit 0` · 17줄, 기본만 18줄 · 기본 + Riverpod 21줄은 그대로 | 016 |
| 베타에서 더해지는 4줄 | `lib/generated/sample.freezed.dart:4` 와 `lib/generated/sample.g.dart:4` 의 `avoid_print` · `prefer_single_quotes` (모두 info) | 016 |
| 베타의 루트 분석 (한 파일 구조 · 나눈 구조의 replica — `tool/` 없음) | exit 0, 0줄, plugin 폴더 1, 10초 (고정 SDK 는 plugin 폴더 0, 0.5초) | 016 |
| 베타의 `probe.dart` 에서 기준과 다른 칸 | 26칸 중 10칸 — 생성 파일 제외 8칸(규칙 쪽만 담은 5칸, 규칙 · plugin 을 함께 담은 3칸), 루트 분석 2칸 | 016 |
| 견줌용 SDK | Flutter 3.49.0-0.2.pre / Dart 3.14.0-211.1.beta (fvm 캐시에만 설치, `.fvmrc` 는 3.47.5 그대로) | 016 |

### 다음 phase 로 넘긴 것

- **Phase 3 (계획):** 03-CONTEXT.md 가 계획에 맡긴 항목 가운데 spike 가 근거를 준 것 — 연습용 프로젝트의 폴더 배치(한 폴더 아래, 폴더마다 따로), 샘플 소스를 나눠 쓰는 방법(복사본을 커밋), plugin 준비를 나눠 쓸 수 있는지(없다), plugin 을 선언하지 않는 프로젝트의 `plugin` 줄("해당 없음"), 규칙 검사를 모든 조각으로 넓히는 방법, 루트 옵션 파일의 새 모양. 생성 파일의 plugin 위반을 연습용 프로젝트에 있는 그대로 고정할지는 계획이 정한다 (012, D-07).
- **Phase 4:** 프리셋에 `build/**` 와 플랫폼 폴더 제외를 넣을지 (004). 규칙 후보는 `rules.json` 이 아니라 "옵션 파일에 적고 고정 SDK 로 분석"하는 방식으로 걸러야 한다 (005). 규칙을 바꿀 때 살필 정답지가 다섯 개다.
- **Phase 3 (계획) 에 더해진 것:** 루트 옵션 파일의 주석에 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다. 성공 기준 3 의 "생성 파일의 진단이 보고되지 않는다" 는 Dart 3.13.x 의 사실이다. 성공 기준 4 의 "루트 분석이 경고 없이 통과한다" 는 고정 SDK 에서 확인됐고, 베타에서는 Dart 파일이 없는 replica 의 루트만 0줄로 확인됐다. `example/README.md` 에 "SDK 를 올리면 4줄이 생길 수 있다" 를 적어 둘지는 계획이 정한다 (016). git 의존성용 연습 프로젝트는 두지 않는다 (015).
- **Phase 5:** README 에 "include 하면 종료 코드 2" 라고 단정하지 않는다 (003). 생성 파일 제외는 사용 프로젝트의 옵션 파일에 직접 적으라고 안내하고, "프리셋의 제외가 통하지 않는다" 를 굳은 사실로 적지 않고 SDK 버전에 따라 다르다고 적는다 (012, 016). plugin 진단을 끌 때의 `version` 과 `riverpod_lint/` 접두사, `diagnostics:` 로 강도를 바꾸는 방법을 적는다 (012). include 순서는 강제하지 않는다 (009). 버전 올리기는 받는 방식에 따라 두 갈래로 적는다 — tag 고정은 `ref:` 수정과 `pub get`, `ref: main` 은 `pub upgrade woody_lints` (015). `flutter analyze` 에 대한 문장은 "Flutter 3.47.5 에서는 plugin 진단을 내지 않는다" 까지만 단정한다 (016).
- **Phase 6:** smoke test 가 처음 보는 것은 받아 오는 길(GitHub 주소, 실제 tag, 인증) 하나로 줄었다. 받은 뒤의 include 와 plugin 로드는 015 가 쟀다. `main` 병합은 `ref: main` 프로젝트에 곧바로 닿지 않고, 각 프로젝트가 `pub upgrade` 를 하거나 lock 없이 받을 때 닿는다 (015).
- **SDK 를 올릴 때 (Phase 6 이후):** `.fvmrc` 를 Dart 3.14 계열로 올리기 전에 016 의 두 스크립트를 그 SDK 로 돌린다. 저장소가 나뉜 뒤에는 스크립트가 그대로 돌지 않을 것이다 (위의 "계획이 알아야 할 것").

### 확인하지 않은 것

Phase 2 (001 ~ 008).

- plugin 이 뜬 뒤 분석 도중에 죽는 경우 (002)
- pub 서버가 느리게 응답만 하고 끝나지 않는 경우의 시간 (002)
- generator 계열 규칙 6개가 생성 코드 없이도 뜨는지 (003)
- macOS / Windows runner, SDK 캐시를 켰을 때의 CI 시간 (006)
- 하위 폴더 인자 문제가 Dart 3.14 에서 고쳐졌는지 (001, sdk#62710)
- 루트를 IDE 로 열었을 때 example 의 진단이 보이지 않게 되는지 (007)
- 007 과 008 의 실험을 GitHub Linux runner 에서 한 것. 다만 빈 폴더를 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 준 cold 실행은 006 이 runner 에서 30번 돌려 모두 통과했다
- 동시 실행의 실패가 폴더에 잘린 `plugin.aot` 을 남기는지 (008)
- 실제 IDE(VS Code)와 상태 폴더를 함께 쓸 때 (008). `dart language-server` 로 흉내 냈다
- `ANALYZER_STATE_LOCATION_OVERRIDE` 가 사용자 문서에 있는 공식 설정인지 (008). 소스의 문서 주석에는 적혀 있다
- 판정 순서(머리말 → 도구가 죽음 → 정답지 비교)를 한 스크립트로 묶어 돌린 것. 각 조건은 따로 쟀다
- 전용 상태 폴더를 실제 저장소 안의 자리에 둔 것 (008). 작업 폴더에 복사한 연습용 프로젝트의 밖 / 안의 점 폴더 / 안의 평범한 폴더 세 자리를 쟀고 결과가 같았다
- 규칙 검사(폴더를 인자로 준 형태)를 `example/` 의 패키지를 받기 전 상태와, 루트의 패키지를 받지 않은 상태(CI 가 저장소를 새로 받은 직후)에서 돌린 것 (007). 잰 것은 두 패키지가 모두 받아진 상태다
- plugin 준비가 실패한 뒤 전용 상태 폴더에 남는 폴더 수와 `pubspec.lock` 의 유무 (002, 008)

Phase 3 (009 ~ 014).

- 009 ~ 014 의 실험을 GitHub Linux runner 에서 한 것. 연습용 프로젝트 여섯의 job 시간은 추정이다 (014)
- (그 뒤 확인됨) git 의존성으로 받았을 때의 include, plugin 로드, 제외 패턴의 기준 폴더 (009, 010, 012) — 015 가 로컬 git 저장소로 쟀고 `path:` 때와 같았다
- (그 뒤 베타로 확인됨) Dart 3.14 의 분석 서버 — 016 이 베타 한 빌드로 쟀고, 012 의 추정(규칙 진단에도 `codegen.yaml` 의 제외가 통하지 않게 된다)대로였다. 정식 3.14 는 재지 않았다
- `riverpod_lint` 3.1.9 보다 새 버전이 나온 뒤의 하한 상향 (010)
- freezed · json_serializable 의 실제 산출물이 어떤 머리 주석을 다는지, `**/*.freezed.dart` 의 제외 (012)
- 규칙과 plugin 진단을 한 옵션 파일에서 함께 끄는 것, 끄는 방법 여섯 칸을 한 프로젝트에 함께 담은 것 (012). 따로 돌렸다
- 깨끗한 조각 셋을 `build/woody_rule_check/<조각 이름>/` 에 두고 한 번에 돌린 것 (013). 깨끗한 `base.yaml` · `codegen.yaml` 은 하나씩, 하위 폴더는 문제 규칙을 넣은 둘로 쟀다
- plugin 진단 말고도 warning 이 남는 조합(`base.yaml` + `riverpod.yaml`)에서 plugin 준비가 실패했을 때의 모양. `exit` 줄은 2 그대로일 것이고 빠진 줄과 stderr 의 머리말로 드러날 것이다 (추론)
- `tool/verify.dart` 를 실제로 고쳐 돌린 것 (013, 014). spike 는 같은 형태의 실행을 흉내 냈다
- `plugins:` 를 뺀 깨끗한 `riverpod.yaml` 의 규칙 검사, `plugins:` 를 빈 줄로 바꿔 줄 번호를 지키는 형태 (013)
- 프로세서가 적은 기계에서의 동시 실행, Windows 와 Linux 에서의 심볼릭 링크, 작업 폴더 하나를 돌려 쓰는 방식을 실제 검증 명령으로 옮긴 것 (014)
- 루트를 IDE 로 열었을 때의 모습, 연습용 프로젝트를 `example/` 안에 두는 배치 (011)
- 프로젝트가 여럿일 때 `--update` 의 쓰기 순서와 화면 (014 는 분석만 쟀다)

받는 방식과 다음 SDK (015 ~ 016).

- 받아 오는 길 자체 — `https://github.com/…` 주소, 실제 tag, 인증 (015 는 로컬 경로를 `git clone` 한 것으로 쟀다)
- lock 파일이 없는 새 프로젝트가 처음 받는 경우, `flutter pub …` 로 돌린 같은 순서, 사용 프로젝트의 `dev_dependencies` 에 `riverpod_lint` 가 따로 적힌 경우 (015)
- 끄는 방법 여섯 칸(012)을 git 의존성으로, 베타로 (015 와 016 은 생성 파일 제외만 다시 쟀다)
- Dart 3.14 정식 버전, 되돌리는 변경(CL 562741)이 들어간 빌드, 그 변경이 pub.dev 의 `analyzer` 로 나온 뒤 plugin 쪽의 동작 (016)
- 베타에서 git 의존성으로 받은 경우, 끄는 설정용 프로젝트(`overrides`)의 정답지, 조각 셋을 하위 폴더에 둔 규칙 검사, 루트 옵션 파일이 `base.yaml` 을 include 하는 선택지 (016)
- **베타에서 `tool/verify.dart` 가 있는 루트의 분석** — 016 의 replica 루트에는 Dart 파일이 없었다. 준비된 plugin 이 Dart 파일을 보는지도 재지 않았다 (016)
- 베타에서 `lib/**` 처럼 폴더째 제외했을 때 루트 분석이 plugin 을 준비하는지 (016 이 잰 제외는 `lib/analysis_options.yaml` 과 `example/**` 다)
- 베타의 루트 분석에서 plugin 준비가 실패했을 때의 모양, `flutter analyze` 가 규칙 진단을 겹쳐 세는 원인 (016)
- 버전 올리기의 tag → 새 tag, `main` → tag 전환 그 자체 (015 는 `main` → 브랜치, 브랜치 → tag 로 쟀다)
- 하위 폴더 인자 문제(sdk#62710)와 종료 코드 255 (001) 가 베타에서 어떤지 — 016 은 채택한 실행 형태로만 돌렸다
- `tool/verify.dart` 를 베타로 돌린 것 (SDK 확인 단계가 종료 코드 78 로 막는다), 저장소가 나뉜 뒤에 016 의 스크립트를 돌린 것
- 015 와 016 의 실험을 GitHub Linux runner 에서 한 것

위의 Phase 2 목록은 spike 가 재지 않은 것이다. 그 뒤 Phase 2 의 구현과 검증(`02-VERIFICATION.md`)이 실제 저장소에서 확인한 것은 여기에 옮기지 않았다.
