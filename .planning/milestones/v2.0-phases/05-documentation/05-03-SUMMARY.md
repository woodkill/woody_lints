---
phase: 05-documentation
plan: 03
subsystem: docs
tags: [readme, verify, analysis_options, riverpod_lint, git-dependency]

requires:
  - phase: 05-documentation
    provides: "05-01 의 readShippedPluginConstraint (줄 끝 주석 · 맵 형식) · declaredRuleNames(shownAs:) · [3/10] (b′)"
  - phase: 05-documentation
    provides: "05-02 의 배포 YAML 머리 주석 — 「문제 해결」 · 「생성 파일 제외」 절 이름을 가리킨다"
  - phase: 03-preset-split
    provides: "fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides} 옵션 파일과 lib/suppress 샘플 (README 블록의 원본)"
provides:
  - "README.md 전문 — 절 열 개, 표시 구역 woody:readme-rules (규칙 81개, 분류 넷), 코드 블록 안의 ref: v2.0.0 (2곳) · version/riverpod_lint: ^3.1.9 (2곳)"
  - "tool/verify.dart [3/10] (d) ~ (g) — README 규칙 목록 · 프리셋 주소 · plugin 버전 · ref 를 lib/base.yaml · lib/ · lib/riverpod.yaml · pubspec.yaml 과 견주고 0개면 실패"
  - "새 심볼: readmeFile · readmeRulesBlock · readBulletBlock · fencedLines · pubspecReleaseVersion"
affects: [05-04, 05-05, 05-06, 06-release]

actuals:
  tokens: 7651
  tasks: 2
  commits: 2
plan_head_before: fd56dc970a3b5f713b01bf992791bec079240446
plan_head_after: 84f937ad6e3c22a1a144f63b46ce35f11960e8c7

tech-stack:
  added: []
  patterns:
    - "README 의 복사해 쓰는 값(include 주소 · version: · ref:)은 코드 블록 안에, 옛 값 · 역사는 산문에 — 검사 (f) · (g) 가 블록 안만 읽는다"
    - "README 표시 구역은 불릿 꼴(- `이름`) + backtick 없는 굵은 분류 소제목 — readBulletBlock 이 구역 안 불릿만 읽는다"

key-files:
  created: []
  modified:
    - README.md
    - tool/verify.dart

key-decisions:
  - "pub workspace 문단은 공식 문서에 멤버 패키지의 analysis_options.yaml 해석을 말하는 문장이 없어(2026-10-14 읽음), 분석에 관한 문장 하나를 옮기고 그 문서가 해석은 말하지 않는다고 적었다"
  - "README 「한 줄」 절에 document_ignores 가 무시 주석에 info 를 붙인다는 한 줄을 더했다 — overrides 정답지의 document_ignores 줄에서 읽은 것, 끄기 예시를 그대로 따라 쓴 사람이 놀라지 않게"
  - "복구 안내는 이 프로젝트의 .plugin_manager/<hash>/ (또는 그 안의 bin/plugin.aot) 로 범위를 좁히고, <hash> 를 고르는 법은 spike 001 · 008 에서 읽은 것(경로의 md5)으로만 적었다"

patterns-established:
  - "README 를 고치면 fvm dart run tool/verify.dart 의 [3/10] 이 README 를 함께 본다 — 규칙 · 프리셋 주소 · plugin 하한 · 릴리스 버전을 바꾸는 커밋에서 README 도 고친다"

requirements-completed: [DOCS-01, DOCS-02, DOCS-03, DOCS-04, DOCS-05, DOCS-06, VERIFY-06]

coverage:
  - id: D1
    description: "README 절 열 개 — 설치(ref: v2.0.0 · flutter pub get) · 프리셋 2 × 2 표와 include 블록 넷 · 표시 구역 81개 · 끄기 세 층 × 둘과 함정 셋 · 생성 파일 제외 · 버전 올리기 넷 · 문제 해결 넷 · 고치는 사람에게, 금지 문구 0줄, 절대 경로 0줄"
    requirement: "DOCS-01"
    verification:
      - kind: integration
        ref: "05-03-PLAN.md Task 1 <automated> (커밋 전 rc 0, 커밋 3a248d0 뒤 rc 0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "README include 블록 넷 · 끄기 블록이 fixtures 옵션 파일과 글자가 같고, 주석으로 끄는 줄이 fixtures/overrides/lib/suppress 의 줄과 같다"
    requirement: "DOCS-02"
    verification:
      - kind: other
        ref: "diff <(README 블록) fixtures/*/analysis_options.yaml 다섯 · suppress 세 조각 — 모두 같음 (사람 대조 보조)"
        status: pass
    human_judgment: false
  - id: D3
    description: "[3/10] (d) ~ (g) 가 지금 README 에서 통과하고, start 마커를 지운 README 에서 rc 1 · [3/10] 실패 · 구역이 없다 · 점검 실패 (10개 중 1개)"
    requirement: "VERIFY-06"
    verification:
      - kind: integration
        ref: "05-03-PLAN.md Task 2 <automated> (커밋 전 rc 0, 커밋 84f937a 뒤 rc 0)"
        status: pass
    human_judgment: false
  - id: D4
    description: "README 문장마다 단정 / 출처와 함께가 05-RESEARCH.md § 4 표대로 갈렸는지, 읽기 쉬운지"
    requirement: "DOCS-05"
    verification: []
    human_judgment: true
    rationale: "자동 단언은 문구의 존재와 금지 문구만 본다 — 단정 수준과 문장의 질은 사람이 읽어야 한다 (PLAN 의 human-check)"

duration: 13min
completed: 2026-10-14
status: complete
---

# Phase 5 Plan 03: README 전면 재작성과 [3/10] README 검사 Summary

**README 를 tag(`ref: v2.0.0`) 설치 · 프리셋 2 × 2 표와 include 블록 넷 · 표시 구역 `woody:readme-rules` 의 규칙 81개 · 끄기 · 생성 파일 제외 · 버전 올리기 · 문제 해결의 절 열 개로 다시 썼다. 그 위에 `tool/verify.dart` 의 `[3/10]` 이 README 의 규칙 목록 · 프리셋 주소 · plugin 버전 · `ref:` 를 `lib/base.yaml` · `lib/` · `lib/riverpod.yaml` · `pubspec.yaml` 과 견주게 했다. 값을 하나도 읽지 못하면 실패다.**

## Performance

- **Duration:** 약 13분 (작업 시작 기록 이후. 필수 문서 읽기는 그 전)
- **Started:** 2026-10-13T17:16:39Z
- **Completed:** 2026-10-13T17:29:47Z (KST 2026-10-14)
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- `README.md` 95행 → 382행. 옛 1 ~ 12행 HTML 주석, 「핵심가치」 절, `ref: main` 설치, 옛 규칙 목록(불일치 2건 포함)을 지웠다. 옛 README 에서 남긴 사실은 lock 으로 설치를 확인하는 방법 하나다.
- 표시 구역 안의 이름 81개는 손으로 치지 않았다. 05-RESEARCH.md 의 `awk` 한 줄로 `lib/base.yaml` 에서 만들었다. 분류는 성능 10 · 가독성 및 스타일 44 · 버그 방지 25 · strict 2 이다.
- `tool/verify.dart` 에 (d) ~ (g) 를 더했다 (+180 −1). import 는 `dart:convert` · `dart:io` 둘 그대로이고, `fvm dart analyze` 결과는 No issues found, `fvm dart format` 의 종료 코드는 0 이다.

## README 의 절 (줄 수 — 제목 줄과 뒤 빈 줄 포함)

| 절 | 줄 |
|---|---|
| `# woody_lints` + 소개 | 4 |
| `## 요구 SDK` | 4 |
| `## 설치` | 27 |
| `## 프리셋 고르기` | 53 |
| `## 받는 규칙` (표시 구역 포함) | 127 |
| `## 규칙 · plugin 진단 끄기` | 66 |
| `## 생성 파일 제외` | 22 |
| `## 버전 올리기` | 41 |
| `## 문제 해결` | 31 |
| `## 이 저장소를 고치는 사람에게` | 7 |

표시 구역 이름은 `woody:readme-rules` 하나다. 구역 안에는 불릿 81개와 굵은 분류 소제목 넷이 있다.

## pub workspace 문장 (옮긴 그대로)

> "Using workspaces for large repositories reduces the amount of memory required for analysis, hence improving performance."

- 출처: https://dart.dev/tools/pub/workspaces (`curl` 로 HTTP 200, 2026-10-14 읽음. 페이지 꼬리는 "reflects Dart 3.13.3. Page last updated on 2026-05-15")
- 이 페이지에는 멤버 패키지의 `analysis_options.yaml` 이 어떻게 풀리는지를 말하는 문장이 없다. 그래서 README 에는 분석과 관련된 위 문장을 옮기고, 그 문서가 해석은 말하지 않는다는 것과 "이 패키지로는 돌려 보지 않았다" 를 함께 적었다.

## 검사 넷이 읽은 값 (커밋 `84f937a` 의 README)

| 검사 | 읽은 값 | 기준값 |
|---|---|---|
| (d) 표시 구역 | 이름 81개, malformed 0 | `lib/base.yaml` 81개 — 같음 |
| (e) 주소 | `analysis_options.yaml`(1) · `base.yaml`(3) · `codegen.yaml`(1) · `recommended.yaml`(2) · `riverpod.yaml`(1) → 집합 다섯 | `expectedLibYamls` 다섯 — 모두 있음 |
| (f) plugin 버전 | 블록 안 두 줄: 198행 `  riverpod_lint: ^3.1.9` (조각마다의 설정), 234행 `    version: ^3.1.9` (끄기 예시) | `^3.1.9` |
| (g) ref | 블록 안 두 줄: 18행 · 333행 `ref: v2.0.0` (설치 · tag 로 옮기기) | `2.0.0-dev` → `2.0.0` |

## 지워 보기 (확인만 — 기록은 05-06 의 M38 ~ M42)

start 마커 줄을 지운 README (Task 2 `<automated>` 와 같은 꼴, 출력을 따로 받아 둠). sanity `GP=0`, 실행 rc 1:

```
[3/10] 배포 파일의 구성 ................ 실패
`README.md` 의 `woody:readme-rules` 구역이 없다 — 05-CONTEXT.md D-01
`<!-- woody:readme-rules:start -->` 와 `<!-- woody:readme-rules:end -->` 사이에 `- `규칙이름`` 불릿을 둔다.
점검 실패 (10개 중 1개)
```

검사가 헛돌지 않는지 넷을 더 돌려 봤다. 매번 README 를 `git checkout -- README.md` 로 되돌렸고, 모두 rc 1 이며 실패한 단계는 `[3/10]` 하나다.

| 바꾼 것 | 화면 |
|---|---|
| 표시 구역에서 `prefer_single_quotes` 불릿 삭제 | `+ prefer_single_quotes  (base.yaml 에만)` |
| `  - package:woody_lints/codegen.yaml` → `codgen.yaml` | `README.md 가 가리키는 프리셋 주소가 lib/ 에 없다 (1):` / `package:woody_lints/codgen.yaml` |
| 끄기 블록 `version: ^3.1.9` → `^3.1.3` | `… lib/riverpod.yaml 의 선언(^3.1.9)과 다르다:` / `^3.1.3` |
| 버전 올리기 블록 `ref: v2.0.0` → `v1.3.0` | `… pubspec.yaml 의 version (2.0.0) 과 다르다:` / `ref: v1.3.0` |

모든 실험 뒤 `git status --porcelain -- README.md lib` 는 비었고 `build/woody_rule_check` 도 남지 않았다.

## fixture 와 README 블록 대조 (D-02 의 사람 대조)

눈으로 대조했다. 보조로 블록을 뽑아 `diff` 도 돌렸다.

- include 블록 넷 = `fixtures/recommended` · `base_only` · `base_riverpod` · `base_codegen` 의 `analysis_options.yaml`: 네 개 모두 같다.
- 프로젝트 전체 끄기 블록 = `fixtures/overrides/analysis_options.yaml` 1 ~ 12행: 주석 줄까지 같다.
- 파일 끄기 두 줄 = `lint_file.dart` 1행 + `plugin_file_prefixed.dart` 1행: 같다.
- 한 줄 끄기 = `lint_line.dart` 2 ~ 3행, `plugin_line.dart` 8 · 9 · 12행: 같다.
- 안 꺼지는 대조 `// ignore: provider_parameters` · `// ignore_for_file: provider_parameters` 는 산문에 적었다. 정답지의 남는 줄 `plugin_line.dart:11` · `plugin_file_unprefixed.dart:8` 은 `fixtures/overrides/expected_diagnostics.txt` 와 대조했다.

외부 링크 셋을 `curl` 로 열었다. flutter#191151 (googlesource), sdk#64549, pub workspace 문서 모두 HTTP 200 이다.

## Task Commits

1. **Task 1: README 전면 재작성** — `3a248d0` `docs(readme): README 전면 재작성 — tag 설치 · 프리셋 표 · 받는 규칙 표시 구역 · 끄기 · 생성 파일 · 버전 올리기 · 문제 해결 (DOCS-01 ~ 06)` (+350 −63, `README.md` 만)
2. **Task 2: [3/10] (d) ~ (g)** — `84f937a` `feat(tool): [3/10] 이 README 의 규칙 목록 · 프리셋 주소 · plugin 버전 · ref 를 배포 파일 · pubspec 과 견줌 (VERIFY-06)` (+180 −1, `tool/verify.dart` 만)

## `<automated>` 결과

PLAN 에서 `grep '<automated>' | sed -n Np` 로 뽑아 `bash <파일>` 로 돌렸다.

| Task | 그대로 돌린 rc | 고친 사본 rc | 무엇을 왜 고쳤나 |
|------|----------------|--------------|------------------|
| 1 | 0 (커밋 전), 0 (커밋 `3a248d0` 뒤, Task 2 시작 전) | — | — |
| 2 | 0 (커밋 전), 0 (커밋 `84f937a` 뒤) | — | — |

## Files Created/Modified

- `README.md` — 전문 재작성 (절 열 개, 표시 구역, 코드 블록 안의 복사해 쓰는 값)
- `tool/verify.dart` — 상수 `readmeFile` · `readmeRulesBlock`, 함수 `fencedLines` · `pubspecReleaseVersion` · `readBulletBlock`, `checkShippedComposition` 의 (d) ~ (g) 와 문서 주석 불릿 넷, 파일 머리 6행

## Decisions Made

- pub workspace: 위 절을 보라. 공식 문서에 멤버 패키지 옵션 해석 문장이 없어 분석에 관한 문장을 옮겼다.
- README 「한 줄」 절에 `document_ignores` 한 줄을 더했다. 이 패키지가 켠 규칙이 무시 주석에 info 를 붙인다는 내용이다. `fixtures/overrides` 정답지의 `document_ignores` 줄에서 읽었다. PLAN 이 적지 않은 문장이지만, 정답지가 받치는 사실이라 끄기 예시를 따라 한 사람이 놀라지 않게 넣었다.
- 복구 안내: `<hash>` 폴더 또는 그 안의 `bin/plugin.aot` 만 지우라고 적었다 (spike 008 — `plugin.aot` 만 지워도 통과). 기본 자리 전체를 지우는 명령은 없다. 어느 `<hash>` 인지는 폴더 내용이나 파일 시각으로 고를 수 없었다(008)는 것과, 경로의 md5 라는 것(001 · 008 에서 읽은 것)을 적었다.
- (d) 의 "README.md 에만" 항목 문구는 PLAN 의 grep 이 글자를 찾으므로 `$readmeFile` 대신 글자 `README.md` 로 적었다. 같은 블록의 다른 줄은 상수를 쓴다.
- (f) · (g) 는 다른 값을 중복 없이 정렬해 보인다. 두 값 모두 0개면 일치로 보지 않고 실패로 본다.

## Deviations from Plan

None - plan executed exactly as written. 위 "Decisions Made" 의 `document_ignores` 한 줄은 PLAN 이 정한 절 안에서 더한 문장이다. 사실 근거는 저장소의 정답지다.

## Issues Encountered

- 이 셸(zsh)에서 `set -- $p` 는 단어로 나뉘지 않는다. 그래서 첫 블록 대조 루프가 빈 이름으로 돌았다. `bash -c` 로 다시 돌려 다섯 모두 같음을 확인했다. 작업물과는 무관하다.
- 마커 삭제와 지워 보기 넷은 모두 되돌렸다. `README.md` · `lib` 는 HEAD 와 같다.

## Known Stubs

없음.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 05-04 (CHANGELOG): 2.0.0 「올리기 전에」 가 가리킬 README 절 이름은 `## 버전 올리기` 의 `### 1.3.0 → 2.0.0 에서 권하는 일` 이다.
- 05-06 (M38 ~ M42): 위 지워 보기 다섯이 같은 꼴로 실패함을 확인했다. 기록은 05-06 의 일이다.
- 05-05 (push 전 비공개 훑기): `README.md` · `tool/verify.dart` · 이 SUMMARY 의 절대 경로 grep 결과는 0줄이다. 비공개 사용 프로젝트의 이름 · 경로 · 메시지는 README 에 없다 ("사용 프로젝트 하나" 로만 적었다).
- VERIFY-06 은 05-05 · 05-06 도 선언한다. 이 plan 에서는 완료 표시하지 않는다 (마지막 plan 이 한다).

## Self-Check: PASSED

- `README.md` · `tool/verify.dart` 가 있고, 커밋 `3a248d0` · `84f937a` 는 HEAD 의 조상이다.
- `README.md` · `tool/verify.dart` 의 절대 경로 grep 결과는 0줄이다.

---
*Phase: 05-documentation*
*Completed: 2026-10-14*
