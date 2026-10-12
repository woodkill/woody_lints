# Spike Wrap-Up Summary

**Date:** 2026-10-12 (wrap-up 여섯 번 — 2026-10-11 에 001 ~ 006 과 007 ~ 008, 2026-10-12 에 009 ~ 014, 015 ~ 016, 017 ~ 019, 020 ~ 023)
**Spikes processed:** 23 (이번 4개, 앞선 wrap-up 19개)
**Feature areas:** `dart analyze` 실행과 결과 판정, `example/` 프로젝트와 정답지, deprecated / removed / 없는 규칙 검사, GitHub Actions CI, 프리셋 나누기 (조각 · 묶음 · 별칭), 나눈 뒤의 연습용 프로젝트 여섯, 진단 끄기와 생성 파일 제외, git 의존성으로 받기와 버전 올리기, 다음 SDK (Dart 3.14 베타) 와 SDK 올리기, 실제 사용 프로젝트의 복사본에서 재기, Phase 4 의 평가표 — 열마다 값을 얻는 법
**Skill output:** `./.claude/skills/spike-findings-woody-lints/`

idea key 는 넷이다.

- `verify-harness-tool-behavior` (001 ~ 008, 018) — 001 ~ 006 은 ROADMAP.md Phase 2 의 "Spike first" 6가지이고, 007 과 008 은 그 6개가 재지 않고 남긴 두 가지다. 018 은 Phase 2 가 끝난 뒤에 붙은 예고(`ubuntu-latest` 가 2026-10-19 부터 Ubuntu 26.04 로 옮겨 간다)를 미리 잰 것이다 (소유자 선택 2026-10-12). 9개 모두 VALIDATED 이고 02-CONTEXT.md D-15 의 멈춤 조건에 해당한 것은 없다.
- `preset-split-include-behavior` (009 ~ 015, 017, 019) — 009 ~ 012 는 ROADMAP.md Phase 3 의 "Spike first" 이고, 013 과 014 는 앞선 spike 끼리 맞물리는 자리다. 015 는 Phase 6 의 smoke test 가 처음 볼 예정이던 것(git 의존성으로 받았을 때의 모양)을 구조를 짓기 전에 당겨 잰 것이다 (소유자 선택 2026-10-12). 017 은 006 × 014 가 맞물리는 자리(연습용 프로젝트 여섯의 runner 시간), 019 는 앞선 spike 가 한 번도 닿지 않은 대상(실제 사용 프로젝트)이다 (둘 다 소유자 선택 2026-10-12). 여덟이 VALIDATED, 012 가 PARTIAL 이다. 멈춤 조건(009 ~ 011 중 하나라도 실패, 015 와 019 의 "나누기 전후가 다르다" 도 같은 급)에 해당한 것은 없다. 012 와 017 은 결과가 어느 쪽이든 기록하고 계속하는 항목이었다 (03-CONTEXT.md D-07).
- `next-sdk-forward-compat` (016) — 조사 문서가 "이번 마일스톤에서 확인하지 않아도 되는 항목" 으로 둔 다음 SDK 의 동작을, 베타가 공개되어 실행으로 잴 수 있게 되자 미리 잰 것이다 (소유자 선택 2026-10-12). PARTIAL 이다 — 구조를 바꿔야 한다는 결과(멈춤 조건)는 나오지 않았고, 생성 파일 제외 하나가 달라졌다.
- `rule-reselection-measurement` (020 ~ 023) — 021 ~ 023 은 ROADMAP.md Phase 4 의 "Spike first" 가운데 019 가 재지 않은 셋과 셋째 항목의 나머지이고, 020 은 로드맵 문구(`rules.json` 을 기준으로)와 005 가 부딪치는 자리다. Phase 4 의 논의보다 먼저 돌렸다 (소유자 선택 2026-10-12). 넷 모두 VALIDATED 이고, spike 가 스스로 건 멈춤 조건(복사본의 `pub get` 이나 분석이 저장소를 바꾸면 멈춘다)에 해당한 것은 없다.

실측 조건: Flutter 3.47.5 / Dart 3.13.4, `riverpod_lint` 3.1.9, macOS arm64 와 GitHub Linux runner (006, 017, 018). 009 ~ 014 는 저장소의 모양을 작업 폴더에 복사한 replica 에서 `path:` 의존성으로 쟀다. 015 는 그 replica 를 로컬 git 저장소로 만들어 git 의존성으로 받았고(GitHub 에는 올리지 않았다), 016 은 같은 스크립트를 고정 SDK 와 베타(Flutter 3.49.0-0.2.pre / Dart 3.14.0-211.1.beta)로 각각 돌렸다. 017 과 018 은 작업 브랜치를 한 번 올려(소유자 확인 뒤) 임시 workflow 로 쟀다 — 이미지 `ubuntu-24.04` 20261004.327.1 과 `ubuntu-26.04` 20260927.149.1, 둘 다 코어 4개. 019 는 `flutter_starter_kit` 의 복사본을 로컬에서 쟀고 원본은 읽기만 했다. 020 ~ 023 도 로컬이다 — 020 은 저장소 밖의 규칙만 적은 패키지와 SDK tag 3.13.4 의 상류 파일을, 021 ~ 023 은 `flutter_starter_kit` 의 복사본(Dart 파일 469개)에 프리셋을 나눈 뒤의 작업 중인 저장소를 `path:` 로 물려 쟀다.

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
| 017 | runner-six-fixtures | standard | ✓ VALIDATED | GitHub Actions CI (여섯일 때의 시간), 나눈 뒤의 연습용 프로젝트 여섯 (runner 의 값), `dart analyze` 실행과 결과 판정 (시간 표) |
| 018 | runner-next-image | standard | ✓ VALIDATED | GitHub Actions CI (다음 runner 이미지) |
| 019 | real-consumer-split-invariance | standard | ✓ VALIDATED | 실제 사용 프로젝트의 복사본에서 재기, 그리고 프리셋 나누기 · 진단 끄기와 생성 파일 제외 · git 의존성으로 받기와 버전 올리기 (실제 프로젝트에서 다시 본 한두 줄) |
| 020 | rule-state-vs-rules-json | standard | ✓ VALIDATED (`rules.json` 을 그대로 옮기면 안 된다 — 열마다 출처를 바꾼다) | Phase 4 의 평가표, deprecated / removed / 없는 규칙 검사 (`rules.json` 과 7번) |
| 021 | new-rules-language-gate | standard | ✓ VALIDATED (새 규칙 6개는 언어 버전 3.11 에서 돌지 않는다) | Phase 4 의 평가표, 실제 사용 프로젝트의 복사본에서 재기 (나눈 뒤의 방법 — `consumer.dart`) |
| 022 | dart-fix-dry-run-count | standard | ✓ VALIDATED (규칙 하나씩 apply 해 사라진 줄로 센다) | Phase 4 의 평가표, 실제 사용 프로젝트의 복사본에서 재기 (`repo_guard.dart`, `useSdk`), `dart analyze` 실행과 결과 판정 (dart fix 와 plugin 한 줄) |
| 023 | existing-ignore-comments | standard | ✓ VALIDATED (기준선 0줄 안에 `type=lint` 파일 다섯이 lint 26줄을 가린다) | Phase 4 의 평가표, 실제 사용 프로젝트의 복사본에서 재기 (기준선), 진단 끄기와 생성 파일 제외 (한 줄) |

## 이번 wrap-up 에서 달라진 것 (020 ~ 023)

설계도 하나를 새로 만들었다 — `rule-evaluation-table.md` (020 ~ 023). 넷이 다룬 일(Phase 4 의 평가표의 열마다 어느 출처의 어느 숫자를 적는가)이 기존 열 편 어디에도 자리가 없었다. 실측의 틀이 바뀐 자리 — `path:` 가 저장소 자체, 받은 자리가 다르면 회차를 버림, 저장소 지문, `useSdk` — 는 `real-consumer-measurement.md` 를 제자리에서 고쳤다. `rule-status-check.md` (`rules.json` 의 서술, 7번, deprecated 목록), `suppression-and-exclude.md` · `analyze-run-and-verdict.md` (한두 줄)도 고쳤다.

| 무엇 | 앞선 결론 | 지금의 결론 |
|---|---|---|
| 규칙 메타데이터의 출처 | "SDK tag 고정 `rules.json` 을 기준으로" (ROADMAP.md Phase 4 Notes). `rules.json` 은 상태 하나가 틀렸다 (005) | 열마다 출처를 바꾼다 — 분석 · `messages.yaml` · `lints` YAML · `rules.json` 의 `incompatible`. 상류가 `rules.json` 을 "믿지 말라" 고 적었다 (020) |
| 비호환 쌍 | "한쪽씩 나눠 돌린다" (로드맵, 잰 적 없음) | 쌍마다 둘만 켠다. 전부 켜면 둘이 가려진다 (020) |
| `path:` 가 가리킬 자리 | 계획이 정한다, 저장소 자체는 재지 않았다 (019) | 저장소 자체. 저장소는 그대로였다 (021, 022) |
| 기준선 | 0줄, 후보의 값은 그 규칙의 줄 수 그대로 (019) | 무시 주석이 있는 채의 0줄 (023). 하한을 올린 복사본은 기준선을 다시 잰다 (021) |
| 새 규칙과 언어 버전 3.11 | 재지 않았다 | 6개는 돌지 않는다 — 값을 둘 적는다 (021) |
| `dart fix` 건수 | 재지 않았다 (로드맵은 `--dry-run` 으로) | apply 해 사라진 줄 (022) |
| 사용 프로젝트의 `// ignore` | 경위를 보지 않았다 (019) | `cast_nullable_to_non_nullable` 56건은 생성 파일의 freezed 주석. 후보 가운데 가려지는 것은 `lines_longer_than_80_chars` 260 · `discarded_futures` 2 (023) |

**gather 직후에 네 README 의 수치를 원본 JSON 으로 다시 셌다.** 거의 모두 맞았고, 고친 것은 둘이다.

| 무엇 | 앞서 적은 것 | 고친 것 | 고친 곳 |
|---|---|---|---|
| 021 의 `pub get` 횟수 | "`dart pub get --no-example` 을 세 번(물릴 때, B2 의 하한을 바꾼 뒤)" / MANIFEST "세 번의 `pub get` 과 분석 뒤에도" | 두 번 — 스크립트가 복사본에서 `pub get` 을 부르는 자리는 `pointToRepo` 와 B2 앞의 `pubGet` 둘이다 (1부의 연습용 패키지 넷은 복사본이 아니다) | README (고친 날짜를 남겼다) · MANIFEST · 사본 |
| 021 의 하한 범위 | MANIFEST "하한을 3.12 이상으로 올리는 것만으로 … 27줄이 생긴다" | "복사본의 하한을 `^3.13.0` 으로 올리는 것만으로 … (하한 3.12 에서도 생길 것이다 — CHANGELOG 와 규칙 소스를 읽은 추정이고, 3.12 하한은 재지 않았다)" — 021 이 잰 하한은 `^3.13.0` 하나다. README 는 출처를 밝혀 적어 그대로 두었다 | MANIFEST · skill 의 사본 셋 |

README 를 두고 skill 에서만 좁혀 적은 것.

- **020 의 "core 35, recommended 58, flutter 10, 합 102개"** — `no_wildcard_variable_uses` 가 core 와 recommended 에 모두 적혀 있어 합집합이 102개다 (pub cache 의 `lints` 6.1.0 YAML 로 확인).
- **022 의 표에서 "진단" 칸은 표식 줄을 포함한다** (`prefer_double_quotes` 20,353 = 프로젝트 20,345 + 표식 8). 프로젝트의 줄만 보면 019 · 021 · 023 의 값과 같다.
- **022 의 K3 · K4 ("2부의 모든 분석에서" 정답지 16줄 · plugin 준비)는 그룹 분석 넷만 본다.** apply 뒤의 분석 아홉은 받은 자리만 확인했다 (`ensureRepoSource`). apply 뒤 증감에 plugin 의 코드가 없어 표식의 plugin 3줄은 그대로였다 (간접 확인).
- **022 의 `sort_pub_dependencies` 는 apply 하지 않았다.** 스크립트가 apply 목록에 넣으려 했지만 `take(maxApply + 1)` 에 밀렸다. "고쳐지지 않는다" 의 근거는 단독 dry 0 과 `fix_internal.dart` 의 등록 없음이다.
- **022 의 "단독 dry 가 0 이면 apply 할 것이 없다" 는 dry-run 의 결과를 옮긴 추론이다** — 단독 dry 0 인 규칙은 apply 하지 않았다.
- **022 의 "36개를 apply 하면 20분 남짓"** 은 규칙 하나 약 30초로 셈하면 약 18분이다 (추정).
- **`flutter_starter_kit` 의 Dart 파일이 019 는 468개, 021 은 469개다** (같은 날, 세는 범위 같음). 그 사이 프로젝트가 바뀌었는지는 확인하지 않았다. 022 · 023 의 README 의 469 는 021 의 값을 옮긴 것이다 — 023 의 스크립트에는 Dart 파일을 세는 코드가 없다.

커밋 전에 skill 폴더만 읽은 별도 에이전트에게 Phase 4 구현자의 질문 11개를 던지고 흠을 찾게 했다 (약 16분). 어긋남 6 · 근거보다 넓음 6 · 잰 것과 추론의 혼재 7 · SDK · 날짜 · 프로젝트 누락 6 · 판정과 기록의 혼동 7 · 용어 5 · 남은 옛 결론 5 · 헷갈리는 서술 5 · 끊긴 참조 1 이 나왔다. 사본 · 스크립트 · 결과 JSON 으로 하나씩 확인했고 확인한 것은 모두 맞았다. 고친 것 가운데 계획에 걸리는 것.

- **"6개 … `flutter_starter_kit` 에서 표식까지 0줄" 은 넷만 맞다.** 복사본의 지금 하한 회차(`B1`)에 넣은 표식은 3.11 문법으로 쓸 수 있는 넷이고, `initialize_in_field_declaration` · `use_declaring_parameters` 의 표식은 3.13 문법이라 `B2` 에서야 넣었다 (그 둘이 3.11 에서 돌지 않는 것은 연습용 패키지에서 봤다). "3.13 미만" 도 잰 것은 3.11 이다.
- **"그 회차를 버린다" 는 스크립트 전체가 멈추는 것으로 구현되어 있다** (`ensureRepoSource` 가 던지고 결과 파일을 쓰지 않는다). "저장소를 바꾸면 그 자리에서 멈춘다" 도 지문을 처음과 끝에서만 견주는 것이다.
- **021 의 "후보 규칙마다 표식을 판정에 넣었다" 는 틀렸다.** 021 의 판정은 대조 셋뿐이고 규칙별 표식 수는 기록이다. 후보마다 판정한 것은 023 이다.
- **`dart fix` 가 저장소를 바꾸지 않는다는 근거는 `repo_guard.dart` 의 두 번(`--dry-run` 하나, `--apply --code=use_primary_constructors` 하나)이다.** 022 의 본 실행의 dart fix (2부만 74번 — 그룹 dry 4 · 단독 dry 61 · apply 9)는 지문 확인이 깨져 이것으로 다시 본 것이다.
- **`sort_pub_dependencies` 와 "`hasFix` 인데 고치지 않는 다섯" 의 근거는 단독 dry 0 이다.** apply 는 하지 않았다.
- **"묶음" 이 두 뜻으로 쓰였다** — 이 skill 의 `recommended.yaml` 과 022 의 G1 ~ G4. 새 문서에서는 G1 ~ G4 를 "그룹" 으로 바꿨다 (README 는 그대로 "묶음 dry").
- **023 의 주석 출처 표에서 `implicit_dynamic_type` 1줄이 빠졌고, "원본을 읽어 센 것" 은 복사본을 센 `countIgnores` 였다.**
- **G4 는 "언어 버전 3.13 에서만 도는 7개" 가 아니라 막는 조건이 있는 6개 + `unnecessary_primary_constructor_body` 다.**
- **real-consumer-measurement.md 의 "`git diff 90a2736 HEAD -- lib/` 가 비어 있다 — 2026-10-12 의 wrap-up 에서 확인" 은 다섯째 wrap-up 의 일이다.** 그 뒤 Phase 3 이 `lib/` 를 나눴다.

이 점검으로 **MANIFEST.md 의 요구 사항에 치환 열둘을 더 걸었다** (gather 때의 두 줄과 합쳐 바뀐 줄은 열둘이다 — 한 줄에 두 번 걸린 자리가 있다) (판정은 바뀌지 않는다. skill 의 사본에도 같은 치환을 스크립트로 걸었다): 020 의 "저장소 하한의 pubspec 옆" → "저장소와 같은 하한을 적은 pubspec 옆 (020 은 저장소 밖에 따로 만들었다)", `sets` 에 tag 를 붙임, 비호환 쌍의 "가려진다" → "실행 하나에서 보이지 않았다 (한 줄에 하나만 알린다는 것은 해석)", 021 의 "3.13 미만 · 표식까지 0줄" → 위의 범위, `repo_guard` 의 두 번, 022 의 수치에 `flutter_starter_kit` 복사본과 "단독 dry → 사라진 줄" 을 붙임, "`hasFix` 인데 고치지 않는다" → "단독 dry 가 0", `sort_pub_dependencies` 의 근거를 "돌린 것 / 읽은 것" 으로 가름, 023 의 둘에 프로젝트와 "작업 브랜치의 프리셋" 을 붙임, 019 의 "프로젝트 자신의 코드는 지금 0줄" 에 "무시 주석이 있는 채 — 그 뒤 023" 을 붙임.

그대로 둔 것: 022 README 의 "분석 13번 · dart fix 75번" (dart fix 는 2부만 74번이고 1부가 따로 있다 — skill 에는 옮기지 않았다), rule-status-check.md 의 005 때 문장 "규칙 후보에서 제외한 판정이 맞다", 네 README 의 원문 표기.

계획이 알아야 할 것.

- **Phase 4 의 "Spike first" 넷이 모두 실행으로 확인됐다** (첫째 021, 둘째의 나머지 023, 셋째의 나머지 021, 넷째 022). 실측을 막는 것은 없다.
- **로드맵 문구와 부딪치는 곳이 둘이다.** "규칙 메타데이터는 SDK tag 고정 `rules.json` 을 기준으로 삼는다" 는 `state` · 상류 세트 열에서 성립하지 않는다 (020). Notes 가 고정한 `fixStatus` 열을 `rules.json` 에서 채우면 "등록이 있다" 는 뜻이 되고, 022 는 그 대신 apply 로 센 건수를 쓰라고 했다. 열을 그대로 둘지 뜻을 적어 둘지는 Phase 4 의 논의가 정한다. 심각도 열의 출처는 네 spike 가 정하지 않았다. 이 wrap-up 은 로드맵을 고치지 않았다.
- **새 규칙 6개는 채택하면 사용 프로젝트가 하한을 올리는 날 한꺼번에 줄이 생긴다** (`flutter_starter_kit` 에서 `use_primary_constructors` 968, `empty_container_bodies` 615, `unnecessary_type_name_in_constructor` 281 — 하한 `^3.13.0` 의 복사본). 지금 하한의 값은 0 (돌지 않음) 이다.
- **apply 가 코드를 깨뜨리는 규칙이 셋이다** (`diagnostic_describe_all_properties` error 148, `always_specify_types` · `specify_nonobvious_local_variable_types` 의 `ambiguous_import`). `prefer_double_quotes` · `unnecessary_final` 은 `base.yaml` 의 규칙과 비호환이라 프리셋의 규칙을 끄지 않고는 쓸 수 없다.
- **회차 기록에 기반 세트의 버전이 빠져 있다.** 021 ~ 023 의 결과 파일에는 SDK 와 plugin 버전은 있고 `lints` · `flutter_lints` 의 버전은 없다 (020 만 적었다). 성공 기준 2 는 셋을 함께 요구한다.
- **소유자에게 물을 것 둘.** 비공개 조건(건수와 규칙 이름만 — 수와 설정값까지 남겨도 되는지)은 여전히 spike 가 스스로 건 조건이다. `type=lint` 를 단 손으로 쓴 파일 다섯이 무엇이고 왜 그렇게 했는지는 경로를 남기지 않는 조건 때문에 spike 가 기록하지 않았다 — 그 파일들은 어떤 lint 후보에도 보이지 않는다.

## 앞선 wrap-up 에서 달라진 것 (017 ~ 019)

설계도 하나를 새로 만들었다 — `real-consumer-measurement.md` (019). 019 가 Phase 4 에 넘긴 방법(복사본, `pubspec_overrides.yaml`, 일부러 넣은 위반, 비공개 프로젝트의 기록)이 기존 아홉 편 어디에도 자리가 없었다. 017 과 018 은 `ci-workflow.md` 와 `fixtures-after-split.md` 에 들어갔고, 나머지 일곱 편은 "재지 않았다" 로 남아 있던 줄을 잰 값으로 고쳤다. 앞선 결론을 뒤집은 것은 없다 — 추정이 잰 값으로 바뀌었고, 빈칸이 채워졌다.

| 무엇 | 앞선 결론 | 지금의 결론 |
|---|---|---|
| 연습용 프로젝트 여섯의 CI 시간 | 재지 않았다. 추정 약 4분 20 ~ 30초 (014) | spike 의 스크립트로 재실행을 뺀 job 이 약 3분 20초 ~ 4분 20초. 추정(260 ~ 270초)은 가장 느린 표본(258초)보다 조금 길었다 (017) |
| 동시에 띄웠을 때 runner 에서의 이득 | 재지 않았다. 로컬에서는 3분의 1 (014) | 약 절반. plugin 쪽 패키지를 넷이 동시에 처음 받는 경우를 포함해 여섯 번 모두 통과 (017) |
| pub cache 가 빈 상태의 `pub get` | 재지 않았다 (014) | 새 가상 머신의 job 에서 루트 0.06 ~ 0.15초, 첫째 프로젝트 1.2 ~ 3.5초, 둘째부터 0.1초 이하 (017) |
| runner 이미지가 바뀐 뒤의 CI | 실패하면 이미지 변경을 먼저 의심한다 (STATE.md 의 메모) | `ubuntu-26.04` 20260927.149.1 에서 같았다. 실패하면 로그의 이미지 버전을 견준다 (018) |
| 실제 사용 프로젝트 | 닿은 적이 없다 | `flutter_starter_kit` 의 복사본에서 나누기 전후가 줄 단위로 같다 (019) |
| 생성기가 다는 머리 주석 | `riverpod_generator` 만 봤다 (012) | `*.freezed.dart` 는 `type=lint`, `json_serializable` 의 산출물은 머리 없음 (019) |
| `dev_dependencies` 의 `riverpod_lint` | 재지 않았다 (015) | 진단에 영향이 없다 (019) |

**017 의 README 를 한 군데 고쳤다.** "한꺼번에 띄운 job 은 재실행을 뺀 값이 126 ~ 158초" 가 원본 JSON 과 맞지 않았다. 126 ~ 158초는 `ubuntu-24.04` 의 표본 셋만의 범위였고 `ubuntu-26.04` 의 셋(136 / 133 / 114초)이 빠져 있었다 — 두 이미지를 합치면 114 ~ 158초(약 1분 55초 ~ 2분 40초)다. README 에 고친 날짜를 남기고 사본을 다시 복사했다. 그 밖의 수치(확인 288건, 분석 시간, 프로젝트별 범위, 019 의 열세 실행)는 원본 JSON 으로 다시 세어 README 와 같았다.

**MANIFEST.md 의 요구 사항 여섯 줄을 고쳤다.** 판정이 달라진 것은 없다. 그대로 옮겨 적히는 문장이라, 한 줄만 읽어도 잰 범위가 보이게 했다.

| 줄 | 앞서 적은 것 | 고친 것 |
|---|---|---|
| 014 | "GitHub runner 에서의 여섯은 재지 않았다 (추정 …)" | "014 가 재지 않았다 (추정 … — 그 뒤 017 이 쟀다)" |
| 017 (차례로) | "job 전체가 약 3분 20초 ~ 4분 20초다" | "재실행을 뺀 job 이 약 3분 20초 ~ 4분 20초다 (spike 의 스크립트를 돌린 값이고 여섯으로 늘린 `tool/verify.dart` 가 아니다 …)" |
| 017 (한꺼번에) | "같은 패키지를 빈 pub cache 에 동시에 처음 받는" | "plugin 쪽 패키지(`riverpod_lint`, `analyzer` 등)를 새 가상 머신의 pub cache 에 동시에 처음 받는" — 동시에 띄우기 전에 프로젝트의 `pub get` 은 차례로 끝나 있었다 |
| 019 (표식) | "0줄은 … 그 프로젝트의 `lib` 가 전부 문서화되어 있어서였다" | "0줄은 규칙이 꺼져서가 아니었다. 그 규칙을 어기는 표식 둘이 같은 실행에서 2줄로 잡혔다" |
| 019 (생성 파일) | "(57개가 머리에 … 를 달고, 머리 없는 … 5개도 지금의 규칙에 걸리지 않는다)" | 날짜와 SDK 를 붙이고 "머리를 단 57개의 0줄이 그 머리 때문인지는 가르지 않았다" 를 더했다 |
| 019 (`dev_dependencies`) | "진단에 영향이 없다 … 3.1.9 로 풀린다" | "`dart analyze` 의 진단에 영향이 없었다 … 풀렸다 (2026-10-12, `flutter_starter_kit` 하나. 그 줄은 프리셋의 선언과 같은 `^3.1.3` …)" |

커밋 전에 skill 폴더만 읽은 별도 에이전트에게 Phase 3 · 4 · 5 구현자의 질문 10개를 던지고 흠을 찾게 했다. 끊긴 참조는 없었다. 어긋난 서술 11곳 · 근거보다 넓게 적힌 서술 11곳 · 잰 것과 읽은 것이 섞인 문장 7곳 · 날짜나 버전이 빠진 문장 5곳 · 헷갈리는 서술 8곳 · 옛 결론이 남은 자리 4곳이 나왔고, 원본 JSON · 스크립트 · 저장소로 하나씩 확인해 고쳤다 (위의 MANIFEST 여섯 줄도 여기서 나왔다). README 원문의 표기에 관한 것 넷과 "정상 job 은 약 2분" 은 그대로 두었다. 그 가운데 계획이 알아야 할 것.

- **019 의 스크립트는 "받은 자리" 와 "그 규칙을 어기는 표식이 보고됐는가" 를 판정으로 걸지 않았다.** 받은 자리(`woodySource`)는 화면과 결과 파일에 적기만 하고, 표식이 판정에 들어간 자리는 V0 · V2 의 정답지 16줄 둘뿐이다. `Consumer` 를 그대로 옮겨 쓰면 ROADMAP.md Phase 4 성공 기준 2 의 문턱("일부러 넣은 위반이 보고되지 않은 회차의 수치는 쓰이지 않았다")이 코드에 없다 — 새로 적어야 한다.
- **"프로젝트의 줄이 나올 때도 같다" 는 규칙 하나(`always_specify_types`, info)로 본 것이다.** 프로젝트의 코드에서 나온 plugin 진단은 모든 실행에서 0 이고, 그 짝은 옛 주소로만 견줬고, 나눈 구조의 plugin 선언은 `^3.1.3` 이었다.
- **지금 받는 그대로(V0)와 옆 폴더로 받은 것(V1)은 받는 방식과 함께 패키지의 `pubspec.yaml` 두 줄도 다르다** (`version`, SDK 하한). `lib/analysis_options.yaml` 의 내용은 같다 (`git diff 90a2736 HEAD -- lib/` 가 비어 있다).
- **비공개 조건의 범위가 문서마다 다르게 읽혔다.** 스크립트가 실제로 남기는 것에는 진단의 건수 · 규칙 이름 · 해시 말고도 사용 프로젝트에 관한 수와 설정값(파일 수, SDK 제약, lock 의 커밋, `riverpod_lint` 줄이 있다는 것, 생성 파일의 머리별 수)이 있다. 이것까지 남겨도 되는지가 소유자에게 확인할 범위다. 019 의 README 와 결과 파일에 이미 적혀 있고, 그 커밋들은 2026-10-12 의 wrap-up 시점에 아직 올리지 않았다.
- 결과 폴더를 훑는 점검 패턴이 좁았다 (`bin/`, 숫자 · 대문자가 든 이름, `*.g.dart` 를 놓친다). CONVENTIONS.md 의 패턴을 넓혔고 019 의 결과는 넓힌 패턴으로도 0줄이다.

README 가 잰 것보다 넓게 적어 skill 에서 좁혀 적은 것 (README 는 그대로 두었다).

- **018 의 "plugin 을 쓰는 실행 51번" 가운데 plugin 을 처음부터 준비한(받기 · AOT 컴파일) 실행은 27번이다.** 나머지 24번은 준비된 plugin 을 다시 쓴 재실행이다. "glibc 2.43 에서 컴파일이 실패하지 않았다" 의 근거는 27번이다.
- **018 의 "버전이 같으면 이미지 탓이 아니다" 는 그 이미지에서 통과한 것의 범위만큼만 맞다** — 프로젝트 하나짜리 지금의 검증 명령 세 번과 spike 의 여섯 프로젝트 점검이다. 여섯으로 늘린 `tool/verify.dart` 는 그 이미지에서 잰 적이 없다.

- **019 의 "지금 받는 그대로(git, 1.3.0)" 는 받아 오는 길을 잰 것이 아니다.** 스크립트가 `PUB_CACHE` 를 따로 주지 않아 평소의 pub cache 를 썼고, 그 커밋의 폴더가 이미 있었는지 그때 GitHub 에서 받았는지는 기록에 없다 (스크립트를 읽은 것). 본 것은 받은 뒤의 자리가 `git/woody_lints-…` 라는 것까지다.
- **019 의 "진짜 생성 파일 62개는 제외가 없어도 0줄" 은 까닭을 가르지 않은 결과다.** 57개가 `type=lint` 머리를 달고 있다는 것과 0줄이라는 것은 각각 잰 사실이지만, 그 머리가 진단을 막은 것인지 걸릴 코드가 없었던 것인지는 그 실행으로 알 수 없다. spike 자신의 교훈("0줄을 표식 없이 해석하지 않는다")이 이 줄에도 해당한다.
- **019 의 "`lib` 가 전부 문서화되어 있어서" 는 결과를 읽은 것이다.** `lib/` 아래에 둔 표식 둘이 2줄로 잡히는데 프로젝트의 줄이 0 이라는 것까지가 잰 것이다.
- **017 의 "표본 사이에 20 ~ 30% 가 벌어진다" 는 칸마다 16 ~ 36% 다** (가장 느린 표본 ÷ 가장 빠른 표본 — 28% · 36% · 16% · 21%).
- **017 의 시간은 spike 의 스크립트를 돌린 값이다.** 여섯으로 늘린 `tool/verify.dart` 는 아직 없고, "job 전체" 에는 재실행이 들어 있다.

계획이 알아야 할 것 넷.

- **Phase 3:** 구조를 바꿀 까닭이 나오지 않았다. `tool/verify.dart` 는 지금처럼 차례로 돌리며 여섯으로 늘려도 `timeout-minutes: 10` 의 절반 안에 끝난다. 한꺼번에 띄우는 것은 약 1분 30초를 줄이는 선택지이고 넣을지는 계획이 정한다. workflow 의 `runs-on` 은 건드리지 않는다. 03-CONTEXT.md D-09 의 "여섯으로 늘어난 검증이 runner 에서 통과하고 시간 제한 안에 끝나는 것을 본다" 는 그대로 남는다.
- **Phase 4:** "Spike first" 넷 가운데 셋째(복사본이 작업 중인 파일을 가리키는지)의 방법이 정해졌고, 둘째는 절반만 닿았고, 첫째(Dart 3.13 의 새 규칙이 language version 3.11 프로젝트에서 보고되는지)와 넷째(`dart fix --dry-run`)는 재지 않았다. 기준선은 2026-10-12 에 0줄이었다. **019 의 스크립트는 Phase 3 이 저장소를 나눈 뒤에는 그대로 돌지 않을 것이다** (`Shipped.read` — 읽은 것). 옮겨 쓸 것은 `Consumer` 쪽이고, `path:` 가 가리킬 자리는 계획이 정한다.
- **비공개 조건:** "사용 프로젝트의 경로 · 메시지 · 코드 조각을 남기지 않는다" 는 소유자가 정한 것이 아니라 019 가 스스로 건 조건이다. Phase 4 의 근거 문서(DOCS-11)가 공개 저장소에 들어가므로 그 논의에서 확인한다.
- **이 패키지 밖의 것:** `flutter_starter_kit` 은 2026-10-12 의 의존성 그대로는 Flutter 베타 3.49.0-0.2.pre 에서 `pub get` 이 풀리지 않았다 (베타의 `flutter_test` 가 고정하는 `matcher` · `test_api` 와 프로젝트의 `test` · `freezed` 제약). 그래서 실제 프로젝트를 베타로 재지 못했다.

STATE.md 의 "그 뒤 CI 가 처음 실패하면 저장소 변경보다 runner 이미지 변경을 먼저 의심한다" 는 018 로 약해졌지만 이 wrap-up 은 STATE.md 를 고치지 않았다.

## 앞선 wrap-up 에서 달라진 것 (015 ~ 016)

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
5. **SDK tag 의 `rules.json` 은 실제 동작과 어긋날 수 있다 (005).** `unnecessary_await_in_return` 은 `rules.json` 에 stable 로 적혀 있지만 Dart 3.13.0 부터 deprecated 다. (그 뒤 020 이 이름 전부로 넓혔다 → 29)
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

runner 와 실제 사용 프로젝트 (017 ~ 019).

24. **0줄은 그 규칙을 어기는 표식 없이는 해석할 수 없다 (019).** `public_member_api_docs` 를 켰는데 0줄이 나오자 "`publish_to: 'none'` 인 앱이라 적용되지 않는다" 는 추정을 세웠고, 문서 주석 없는 선언 둘을 넣자 2줄이 잡혀 추정이 틀린 것으로 드러났다. 기본 표식(`example/lib` 의 샘플)은 그 규칙을 어기지 않아 가르지 못했다. Phase 4 의 회차마다 후보 규칙을 어기는 표식이 있어야 한다.
25. **`flutter_starter_kit` 의 기준선은 0줄이다 (019, 2026-10-12).** 1.3.0 의 규칙 12개 · 기반 세트 · `riverpod_lint` 에 걸리는 줄이 없다. "기준선 대비 차이" 가 그 규칙의 줄 수 그대로가 된다. (그 뒤 조건이 붙었다 — 무시 주석이 있는 채의 0줄이고, 하한을 올린 복사본은 기준선을 다시 잰다 → 32, 33)
26. **한꺼번에 띄운 이득은 runner 에서 3분의 1 이 아니라 절반이다 (017).** 코어 4개에서 분석 146 ~ 191초가 69 ~ 95초가 된다. 차례로 돌려도 시간 제한의 절반 안이라 넣어야 할 까닭은 없다.
27. **`flutter_starter_kit` 에서 `json_serializable` 의 산출물로 본 `*.g.dart` 5개에는 진단을 막는 머리 주석이 없었다 (019).** 지금은 0줄이지만 규칙이 늘면 여기서 줄이 날 수 있다. 사용 프로젝트의 옵션 파일에 제외를 직접 적으라는 안내의 이유가 된다.
28. **019 의 스크립트는 나눈 뒤의 저장소에서 그대로 돌지 않을 것이다.** Phase 4 는 Phase 3 뒤에 오므로, 옮겨 쓸 것은 `Consumer` (복사 · `pubspec_overrides.yaml` · 받은 자리 확인)와 `Diag` · `digest` 다. 스크립트를 읽은 것이고 돌려 보지는 않았다. (그 뒤 021 의 `consumer.dart` 가 그렇게 옮겨 나눈 뒤의 저장소에서 돌았다)

Phase 4 의 실측 방법 (020 ~ 023).

29. **평가표의 `state` · 상류 세트 열을 `rules.json` 에서 옮기면 안 된다 (020).** 상류가 같은 폴더의 README 에 "unsupported and deprecated, should not be relied on" 이라고 적었다. tag 3.13.4 의 그 파일은 deprecated 하나를 stable 로 적었고, 켜지는 규칙 둘(`migrate_design_widgets`, `erase_dart_type_extension_types`)을 빠뜨렸고, `sets` 가 262개 모두 비어 있다. deprecated / removed / 없는 이름은 저장소 하한의 패키지를 분석해서, stable / experimental / testing 은 tag 의 `messages.yaml` 에서 읽는다.
30. **비호환 쌍을 한 옵션 파일에 모두 켜면 일부가 가려진다 (020).** 규칙 한 줄에 `incompatible_lint` 가 하나만 붙어, 선언된 12쌍 가운데 `unnecessary_final` 이 낀 둘이 보이지 않았다. 쌍마다 둘만 켜면 12쌍 모두 보고된다.
31. **Dart 3.13 의 새 규칙 6개는 언어 버전 3.11 의 라이브러리에서 돌지 않는다 (021 — 3.12 는 재지 않았다).** 연습용 패키지에서 6개 모두, `flutter_starter_kit` (`^3.11.1`) 의 복사본에서 표식을 둔 넷이 그 규칙을 어기는 표식까지 0줄이고, 하한만 `^3.13.0` 으로 올린 복사본에서는 수백 줄이다. 지금 하한의 0 은 "돌지 않은 0" 이라 평가표에 값을 둘 적는다.
32. **하한을 올리는 것만으로 기반 세트의 규칙이 줄을 낸다 (021).** 복사본의 하한을 `^3.13.0` 으로 올리자 `prefer_initializing_formals` 가 27줄을 냈다 (Dart 3.12 의 private named parameters — CHANGELOG 와 규칙 소스로 읽은 것, 3.12 하한은 재지 않았다). 하한을 올린 복사본의 기준선은 다시 잰다.
33. **기준선 0줄은 무시 주석이 있는 채의 값이다 (023).** 손으로 쓴 파일 다섯 개가 `ignore_for_file: type=lint` 를 달아 lint 26줄(이 패키지의 `prefer_final_locals` 4줄 포함)을 가린다. 그 파일들은 어떤 lint 후보에도 보이지 않는다.
34. **"`dart fix` 로 고칠 수 있는 건수" 는 dry-run 의 수도 `hasFix` 도 아니다 (022).** 단독 dry 의 수는 수정 수라 사라지는 줄과 두 방향으로 다르고(16 → 32줄, 155 → 123줄), 그룹 dry (022 README 의 "묶음 dry") 는 규칙끼리 섞이고, `hasFix` 인데 dart fix 가 고치지 않는 규칙이 다섯이다. 그 규칙만 apply 한 뒤 다시 분석해 사라진 줄로 센다. apply 가 error 를 남기는 규칙이 셋이다.
35. **로드맵이 센 "`cast_nullable_to_non_nullable` 56건" 은 생성 파일 안의 freezed 주석이다 (023).** 생성 파일은 분석에서 빠지므로 아무것도 가리지 않는다. 그 규칙의 실제 줄은 5줄이다. 후보 가운데 주석이 가리는 것은 `lines_longer_than_80_chars` 260줄 · `discarded_futures` 2줄이다.
36. **`unnecessary_ignore` 는 켜져 있지 않은 규칙을 가리키는 주석도 보고한다 (023).** 값이 다른 후보의 채택에 묶인다 — 지금의 프리셋 기준 38줄, 세 후보를 함께 켜면 12줄.

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
21. 연습용 프로젝트 여섯을 지금의 방식(차례로, 상태 폴더는 프로젝트마다 따로)으로 GitHub runner 에서 돌려도 `timeout-minutes: 10` 안에 넉넉히 든다 (017). job 12개의 확인 288건이 모두 성립했고 여섯의 진단이 로컬의 예상과 줄 단위로 같았다.
22. GitHub runner 의 다음 이미지(`ubuntu-26.04` 20260927.149.1, glibc 2.43)에서 지금의 검증 명령 세 번이 `점검 통과 (4개 중 4개)` 였고 plugin 준비가 실패하지 않았다 (018 — plugin 을 처음부터 준비한 실행 27번). workflow 는 바꾸지 않는다.
23. 실제 사용 프로젝트의 복사본에서 지금 받는 그대로(git, 1.3.0) · 한 파일 구조 · 나눈 구조의 옛 주소 · 묶음 주소가 줄 단위로 같다 (019). 프로젝트의 줄이 9,374줄 나오는 조건(`always_specify_types`)에서도 나누기 전후가 같다.
24. 사용 프로젝트가 `dev_dependencies` 에 `riverpod_lint` 를 따로 적어 두어도 `dart analyze` 의 진단에 영향이 없었다 (019 — 프로젝트 하나, 그 줄의 제약이 프리셋과 같은 `^3.1.3` 인 경우). plugin 은 그 프로젝트의 lock(3.1.3)과 무관하게 3.1.9 로 풀렸다.
25. 사용 프로젝트가 맵 문법으로 더 켠 규칙은 3단 include 위에 그대로 얹힌다 (019).
26. `messages.yaml` 의 deprecated 6 · removed 14 는 실제 분석과 하나도 다르지 않다. deprecated / removed 는 pubspec 의 하한을 따른다 — 하한 `^3.11.1` 에서는 3.13 에 deprecated 된 셋이 보이지 않는다 (020, 005 와 같다).
27. 복사본의 `pubspec_overrides.yaml` 이 작업 중인 저장소 자체를 가리켜도 저장소는 그대로다 — `pub get` · 분석 · `dart fix --dry-run` · `--apply` 를 한 단계씩 견줬다 (021, 022 의 `repo_guard.dart`). replica 를 따로 만들 필요가 없다.
28. `no_raw_types` · `no_dynamic_casts` · `async_return_with_no_await` · `strict-inference` 는 언어 버전 3.11 에서도 돈다. `flutter_starter_kit` 에서 `no_raw_types` · `no_dynamic_casts` 는 표식이 걸린 진짜 0 이다 (021).
29. 하한을 `^3.13.0` 으로 올려도 기본 표식 16줄(이 패키지의 지금 규칙과 plugin 진단)은 한 줄도 달라지지 않았다 (021).
30. `dart fix` 는 plugin 을 준비하지 않아 `riverpod_lint` 진단을 고치지 않는다 (022).

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
| 연습용 프로젝트 여섯의 CI job (차례로) | 분석 145.8 ~ 191.2초 (평균 172초), 재실행을 뺀 job 202 ~ 258초 — 약 3분 20초 ~ 4분 20초 (spike 의 스크립트, 잰 job 시간에서 재실행을 뺀 셈, 표본 여섯). 014 의 추정은 약 4분 20 ~ 30초였다 | 017 |
| 연습용 프로젝트 여섯의 CI job (한꺼번에) | 분석 68.8 ~ 94.9초 (평균 85초), 재실행을 뺀 job 114 ~ 158초 — 약 1분 55초 ~ 2분 40초 (같은 조건) | 017 |
| runner 에서 프로젝트 하나 (여섯을 차례로 돌릴 때) | plugin 을 쓰는 넷 30 ~ 45초, 쓰지 않는 둘 6 ~ 8초. 새 가상 머신의 `pub get` 은 루트 0.06 ~ 0.15초, 첫째 프로젝트 1.2 ~ 3.5초, 둘째부터 0.1초 이하 | 017 |
| runner 이미지 | `ubuntu-24.04` 20261004.327.1 (24.04.5 LTS, glibc 2.39) / `ubuntu-26.04` 20260927.149.1 (26.04.1 LTS, glibc 2.43). 둘 다 코어 4개 · 약 16GB. `ubuntu-latest` 는 2026-10-12 에 24.04 였다 | 017, 018 |
| `ubuntu-latest` 가 옮겨 가는 때 | 2026-10-19 ~ 2026-11-19 (actions/runner-images#14748, 2026-10-12 읽음) | 018 |
| 지금의 `verify` job (2026-10-12) | 24.04 에서 88초, 26.04 에서 70 / 70 / 58초 | 018 |
| `flutter_starter_kit` (2026-10-12) | Dart 파일 468개 — `lib` 손으로 쓴 것 172 + 생성 파일 62, `test` 233, `bin` 1. SDK 제약 `^3.11.1`, `woody_lints` 는 `ref: main` · lock 의 커밋 `90a2736` | 019 |
| 실제 사용 프로젝트의 기준선 | 프로젝트의 줄 0 (표식 파일 16줄 · `exit 2`) | 019 |
| 실제 사용 프로젝트에서 켜 본 규칙 | `always_specify_types` 9,374줄 (`lib` 1,524 · `test` 7,739 · `bin` 111), `public_member_api_docs` 0줄 (표식 둘은 2줄) | 019 |
| 실제 사용 프로젝트의 분석 한 번 | plugin 을 쓰면 21.5 ~ 25.0초, 쓰지 않으면 6.8초 (빈 상태 폴더). 열세 번에 277초 | 019 |
| 생성 파일의 머리 (`flutter_starter_kit`) | `*.g.dart` 50개 `type=lint, type=warning` · 5개 머리 없음, `*.freezed.dart` 7개 `type=lint` | 019 |
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
| SDK tag 3.13.4 의 규칙 메타데이터 | `rules.json` 262개 (stable 232 · removed 14 · experimental 11 · deprecated 5, `sets` 전부 빔, `fixStatus` hasFix 165 · noFix 67 · needsFix 26 · needsEvaluation 4) / `messages.yaml` 275개 (stable 229 · removed 14 · internal 12 · experimental 12 · deprecated 6 · testing 2) | 020 |
| 규칙 이름 전부를 분석했을 때 (Dart 3.13.4) | 하한 `^3.13.0`: `removed_lint` 14 · `undefined_lint` 12 · `deprecated_lint` 6 · `incompatible_lint` 10, 0.47초 / 하한 `^3.11.1`: `deprecated_lint` 3 (나머지 같음) | 020 |
| 상류 세트 (`lints` 6.1.0 · `flutter_lints` 6.0.0) | 직접 적힌 규칙 core 35 · recommended 58 · flutter 10, 합집합 102 (`no_wildcard_variable_uses` 가 core · recommended 에 겹친다) | 020 |
| 선언된 비호환 쌍 | 12 (전부 켜면 10 이 보이고, 쌍마다 둘만 켜면 12 모두) | 020 |
| 새 규칙의 하한별 값 (`flutter_starter_kit`, 하한 `^3.13.0` 의 복사본) | `use_primary_constructors` 968 · `empty_container_bodies` 615 · `unnecessary_type_name_in_constructor` 281 · `unnecessary_const_in_enum_constructor` 2 — 지금 하한(`^3.11.1`)에서는 넷 다 0 (돌지 않음). `async_return_with_no_await` 30 · `strict-inference` 106 은 두 하한에서 같다 | 021 |
| 하한을 `^3.13.0` 으로 올리면 생기는 기반 세트의 줄 | `prefer_initializing_formals` 27 (`lib` 24 · `test` 3) | 021 |
| `dart fix` 의 시간 (복사본) | 그룹 dry 15 ~ 29초, 단독 dry 5.9 ~ 17.2초 (중앙값 6.9초), apply 한 번 7.5 ~ 17.7초, 규칙 하나의 apply 회 약 30초 | 022 |
| `hasFix` 인데 dart fix 가 고치지 않는 규칙 (진단이 있는 것) | `always_put_control_body_on_new_line` 398, `async_return_with_no_await` 30, `discarded_futures` 11, `prefer_foreach` 3, `unreachable_from_main` 2 | 022 |
| 사용 프로젝트의 무시 주석 | 손으로 쓴 파일 67줄 · 49개, 생성 파일 121줄 · 57개. 기준선 안에서 가린 줄: `type=lint` 파일 다섯의 lint 26 + 줄 단위 주석의 analyzer 경고 28 | 023 |
| 주석이 가린 후보의 줄 | `lines_longer_than_80_chars` 260 (107 → 367), `discarded_futures` 2 (11 → 13), `cast_nullable_to_non_nullable` 0 (5) | 023 |
| `unnecessary_ignore` (`flutter_starter_kit`) | 지금의 프리셋 기준 38, 세 후보를 함께 켜면 12 | 023 |
| `flutter_starter_kit` (2026-10-12, 021 ~ 023) | Dart 파일 469개, SDK 제약 `^3.11.1`. 분석 한 번 약 20 ~ 26초 (빈 상태 폴더) | 021 ~ 023 |

### 다음 phase 로 넘긴 것

- **Phase 3 (계획):** 03-CONTEXT.md 가 계획에 맡긴 항목 가운데 spike 가 근거를 준 것 — 연습용 프로젝트의 폴더 배치(한 폴더 아래, 폴더마다 따로), 샘플 소스를 나눠 쓰는 방법(복사본을 커밋), plugin 준비를 나눠 쓸 수 있는지(없다), plugin 을 선언하지 않는 프로젝트의 `plugin` 줄("해당 없음"), 규칙 검사를 모든 조각으로 넓히는 방법, 루트 옵션 파일의 새 모양. 생성 파일의 plugin 위반을 연습용 프로젝트에 있는 그대로 고정할지는 계획이 정한다 (012, D-07).
- **Phase 4:** 프리셋에 `build/**` 와 플랫폼 폴더 제외를 넣을지 (004). 규칙 후보는 `rules.json` 이 아니라 "옵션 파일에 적고 고정 SDK 로 분석"하는 방식으로 걸러야 한다 (005). 규칙을 바꿀 때 살필 정답지가 다섯 개다.
- **Phase 3 (계획) 에 더해진 것:** 루트 옵션 파일의 주석에 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다. 성공 기준 3 의 "생성 파일의 진단이 보고되지 않는다" 는 Dart 3.13.x 의 사실이다. 성공 기준 4 의 "루트 분석이 경고 없이 통과한다" 는 고정 SDK 에서 확인됐고, 베타에서는 Dart 파일이 없는 replica 의 루트만 0줄로 확인됐다. `example/README.md` 에 "SDK 를 올리면 4줄이 생길 수 있다" 를 적어 둘지는 계획이 정한다 (016). git 의존성용 연습 프로젝트는 두지 않는다 (015).
- **Phase 5:** README 에 "include 하면 종료 코드 2" 라고 단정하지 않는다 (003). 생성 파일 제외는 사용 프로젝트의 옵션 파일에 직접 적으라고 안내하고, "프리셋의 제외가 통하지 않는다" 를 굳은 사실로 적지 않고 SDK 버전에 따라 다르다고 적는다 (012, 016). plugin 진단을 끌 때의 `version` 과 `riverpod_lint/` 접두사, `diagnostics:` 로 강도를 바꾸는 방법을 적는다 (012). include 순서는 강제하지 않는다 (009). 버전 올리기는 받는 방식에 따라 두 갈래로 적는다 — tag 고정은 `ref:` 수정과 `pub get`, `ref: main` 은 `pub upgrade woody_lints` (015). `flutter analyze` 에 대한 문장은 "Flutter 3.47.5 에서는 plugin 진단을 내지 않는다" 까지만 단정한다 (016).
- **Phase 6:** smoke test 가 처음 보는 것은 받아 오는 길(GitHub 주소, 실제 tag, 인증) 하나로 줄었다. 받은 뒤의 include 와 plugin 로드는 015 가 쟀다. `main` 병합은 `ref: main` 프로젝트에 곧바로 닿지 않고, 각 프로젝트가 `pub upgrade` 를 하거나 lock 없이 받을 때 닿는다 (015).
- **SDK 를 올릴 때 (Phase 6 이후):** `.fvmrc` 를 Dart 3.14 계열로 올리기 전에 016 의 두 스크립트를 그 SDK 로 돌린다. 저장소가 나뉜 뒤에는 스크립트가 그대로 돌지 않을 것이다 (위의 "계획이 알아야 할 것").
- **Phase 3 에 더해진 것 (017 · 018 · 019):** 검증 명령은 차례로 돌리는 지금의 구조 그대로 여섯으로 늘린다. `timeout-minutes` 는 10 그대로, `runs-on` 은 `ubuntu-latest` 그대로다. 여섯으로 늘린 실제 `tool/verify.dart` 를 runner 에서 보는 일(03-CONTEXT.md D-09)은 남아 있다. 연습용 프로젝트 여섯의 구성을 바꿀 까닭은 실제 사용 프로젝트에서도 나오지 않았다.
- **Phase 4 에 더해진 것 (019):** 실측의 방법 — 복사본에 `pubspec_overrides.yaml`, 받은 자리를 `package_config.json` 으로 확인, 회차마다 그 규칙을 어기는 표식 파일, `lib` / `test` 를 나눠 세기, 결과에는 건수와 규칙 이름만. 기준선 0줄. `public_member_api_docs` 는 이 프로젝트에서 0줄이다. "Spike first" 의 첫째 · 넷째 항목과 `// ignore` 주석의 경위는 남아 있다 (그 뒤 021 ~ 023 이 쟀다 — 아래 020 ~ 023 의 줄).
- **Phase 5 에 더해진 것 (019):** "`dev_dependencies` 의 `riverpod_lint` 는 진단에 필요 없다" 가 실측으로 받쳐진다. 생성 파일 제외 안내의 이유를 "적지 않으면 진단이 쏟아진다" 로 적지 않는다 — `flutter_starter_kit` 에서는 제외가 어디에도 없어도 0줄이었다.
- **runner 이미지가 옮겨 간 뒤 (2026-10-19 ~):** CI 가 실패하면 로그의 `Image:` · `Version:` 줄을 018 의 값과 견준다.
- **Phase 4 에 더해진 것 (020 ~ 023):** 평가표의 열마다의 출처 — `state` 는 분석과 `messages.yaml`, 상류 세트는 `lints` YAML, 비호환은 쌍마다 둘만, 실측 건수는 주석을 둔 채로(가린 줄은 따로), 새 규칙 6개는 두 값, `dart fix` 건수는 apply 해 사라진 줄과 새 error. 실측의 틀은 021 의 `consumer.dart` (`path:` 가 저장소 자체, 받은 자리가 다르면 회차를 버림, 저장소 지문). 로드맵의 `rules.json` 문구와 `fixStatus` 열의 뜻, 심각도 열의 출처, 회차 기록의 기반 세트 버전, 비공개 조건의 범위, `type=lint` 를 단 손으로 쓴 파일 다섯은 논의에서 정한다.

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

- (그 뒤 일부 확인됨) 009 ~ 014 의 실험을 GitHub Linux runner 에서 한 것 — 017 이 여섯 조합과 그 시간을 runner 에서 쟀다. 사슬이 끊겼을 때(010), 루트 분석(011), 끄는 방법(012), 규칙 검사(013)는 runner 에서 재지 않았다
- (그 뒤 확인됨) git 의존성으로 받았을 때의 include, plugin 로드, 제외 패턴의 기준 폴더 (009, 010, 012) — 015 가 로컬 git 저장소로 쟀고 `path:` 때와 같았다
- (그 뒤 베타로 확인됨) Dart 3.14 의 분석 서버 — 016 이 베타 한 빌드로 쟀고, 012 의 추정(규칙 진단에도 `codegen.yaml` 의 제외가 통하지 않게 된다)대로였다. 정식 3.14 는 재지 않았다
- `riverpod_lint` 3.1.9 보다 새 버전이 나온 뒤의 하한 상향 (010)
- (그 뒤 일부 확인됨) freezed · json_serializable 의 실제 산출물이 어떤 머리 주석을 다는지 — 019 가 `flutter_starter_kit` 의 산출물에서 읽었다 (버전은 기록하지 않았다). `**/*.freezed.dart` 를 직접 적어 plugin 위반을 막는지는 여전히 재지 않았다 (012)
- 규칙과 plugin 진단을 한 옵션 파일에서 함께 끄는 것, 끄는 방법 여섯 칸을 한 프로젝트에 함께 담은 것 (012). 따로 돌렸다
- 깨끗한 조각 셋을 `build/woody_rule_check/<조각 이름>/` 에 두고 한 번에 돌린 것 (013). 깨끗한 `base.yaml` · `codegen.yaml` 은 하나씩, 하위 폴더는 문제 규칙을 넣은 둘로 쟀다
- plugin 진단 말고도 warning 이 남는 조합(`base.yaml` + `riverpod.yaml`)에서 plugin 준비가 실패했을 때의 모양. `exit` 줄은 2 그대로일 것이고 빠진 줄과 stderr 의 머리말로 드러날 것이다 (추론)
- `tool/verify.dart` 를 실제로 고쳐 돌린 것 (013, 014). spike 는 같은 형태의 실행을 흉내 냈다
- `plugins:` 를 뺀 깨끗한 `riverpod.yaml` 의 규칙 검사, `plugins:` 를 빈 줄로 바꿔 줄 번호를 지키는 형태 (013)
- (그 뒤 일부 확인됨) 프로세서가 적은 기계에서의 동시 실행 — 017 이 코어 4개의 runner 에서 쟀다. Windows 와 Linux 에서의 심볼릭 링크, 작업 폴더 하나를 돌려 쓰는 방식을 실제 검증 명령으로 옮긴 것은 여전히 재지 않았다 (014)
- 루트를 IDE 로 열었을 때의 모습, 연습용 프로젝트를 `example/` 안에 두는 배치 (011)
- 프로젝트가 여럿일 때 `--update` 의 쓰기 순서와 화면 (014 는 분석만 쟀다)

받는 방식과 다음 SDK (015 ~ 016).

- 받아 오는 길 자체 — `https://github.com/…` 주소, 실제 tag, 인증 (015 는 로컬 경로를 `git clone` 한 것으로 쟀다)
- lock 파일이 없는 새 프로젝트가 처음 받는 경우, `flutter pub …` 로 돌린 같은 순서 (015). 사용 프로젝트의 `dev_dependencies` 에 `riverpod_lint` 가 따로 적힌 경우는 그 뒤 019 가 쟀다 — 진단에 영향이 없다
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

runner 와 실제 사용 프로젝트 (017 ~ 019).

- **여섯으로 늘린 실제 `tool/verify.dart` 를 runner 에서 돌린 것** — 017 은 spike 의 스크립트다. 규칙 검사와 화면 출력의 시간은 들어 있지 않다. 그것을 `ubuntu-26.04` 에서 돌린 것도 아니다 (017, 018)
- runner 에서 한꺼번에 띄운 실행이 드물게 깨지는지 — 처음 여섯 번 · 재실행 여섯 번으로는 알 수 없다 (017)
- 작업 폴더 하나에서 옵션 파일만 바꿔 가며 돌리는 방식(014 의 B)을 runner 에서, runner 에서 `base_riverpod` 의 재실행만 3 ~ 6초 긴 까닭 (017)
- 26.04 이미지의 뒤 버전, arm64 · macOS · Windows runner, SDK 캐시(`cache: true`)를 켠 경우, Flutter 설치가 26.04 에서 빨랐던 까닭 (017, 018)
- **다음 SDK 에서의 실제 프로젝트** — `flutter_starter_kit` 의 `pub get` 이 베타에서 풀리지 않았다 (019)
- 학습용 프로젝트 넷(`webtoon`, `toonflix`, `pomodoro`, `state`), 나눈 구조를 git 으로 받은 실제 프로젝트, 받아 오는 길 (019 의 git 실행은 평소의 pub cache 를 썼다)
- (그 뒤 확인됨) Dart 3.13 의 새 규칙이 language version 3.11 프로젝트에서 보고되는지, `dart fix --dry-run` 으로 고쳐지는 건수, 사용 프로젝트가 직접 적은 `// ignore` 주석이 가리는 줄의 수 (ROADMAP.md Phase 4 의 "Spike first" — 019 는 셋째 항목만 답했고, 그 뒤 021 · 022 · 023 이 쟀다)
- 실제 프로젝트의 생성 파일 0줄의 까닭 (`type=lint` 머리가 막은 것인지 걸릴 코드가 없는 것인지), 규칙을 더 켠 상태에서 생성 파일의 제외를 뺀 경우, 세 생성기의 버전과 다른 버전이 내는 머리 (019)
- 상태 폴더를 이어 썼을 때의 실제 프로젝트 분석 시간, 생성 파일 제외가 분석 시간을 줄이는지, `path:` 가 작업 중인 저장소 자체를 가리킬 때 (그 뒤 021 이 쟀다), 나눈 뒤의 저장소에서 019 의 스크립트를 돌린 것, IDE 에서의 모습 (019)

Phase 4 의 실측 방법 (020 ~ 023).

- 심각도 열의 출처, stable / experimental 이 갈린 넷의 "진짜" 상태, `sinceDartSdk` 의 정확성, `messages.yaml` 의 `internal` 규칙이 왜 하나는 켜지고 나머지는 없는 이름인지 (020)
- 선언 밖의 비호환 쌍이 없다는 완전한 확인 — 전부 켠 실행 하나로 봤고 그 실행은 한 줄에 하나만 보인다 (020). 기반 세트(include)의 규칙과 후보의 충돌이 규칙 검사에 보이는지
- 3.12 하한(private named parameters 만 켜지고 primary constructor 는 꺼진 자리), `prefer_initializing_formals` 27줄의 자리 하나하나, 하한을 올린 복사본에서 이 패키지의 지금 규칙 12개가 표식 밖에서 달라지는지 (021)
- 아홉 규칙 밖의 apply (`sort_pub_dependencies` 포함), 진단도 그룹 dry 도 0 인 58개 규칙의 0 의 뜻 (규칙마다의 표식이 없다), dart fix 를 두 번 돌렸을 때 흔들리는지, IDE 의 빠른 수정 (022)
- `type=lint` 를 단 손으로 쓴 파일 다섯이 무엇이고 왜 그랬는지, 그 파일들의 plugin 진단, plugin 진단의 무시 주석과 `unnecessary_ignore`, 생성 파일을 분석에 넣었을 때 (023)
- 학습용 프로젝트 넷, 다음 SDK, GitHub runner 에서의 같은 실행 (020 ~ 023)

위의 Phase 2 목록은 spike 가 재지 않은 것이다. 그 뒤 Phase 2 의 구현과 검증(`02-VERIFICATION.md`)이 실제 저장소에서 확인한 것은 여기에 옮기지 않았다.
