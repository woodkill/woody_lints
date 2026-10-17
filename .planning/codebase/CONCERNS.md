---
last_mapped_commit: 8ac96b71e9d394c5d1dfb132814ee87379519c69
last_mapped_at: 2026-10-17
---
# Codebase Concerns

**Analysis Date:** 2026-10-17

출발 목록은 `.planning/milestones/v2.0-MILESTONE-AUDIT.md` 의 `tech_debt` (29 ~ 69행) · 「기술 부채」 절 (227 ~ 254행), `.planning/ROADMAP.md` 의 `## Backlog` (999.1 ~ 999.3), `.planning/milestones/v2.0-REQUIREMENTS.md` 의 RULES-13 메모 (103 ~ 105행) 다. 항목마다 지금 파일에서 다시 본 결과를 "확인함(파일:행)" / "확인하지 못함" 으로 붙였다. 도구는 실행하지 않았다 (읽기 전용) — 동작에 관한 주장은 "재현하지 않음 — 근거: 기록" 으로 적는다.

분류 표시: **[받는 쪽]** = 사용 프로젝트에 닿는 것, **[안쪽]** = 저장소 안쪽(버전 판정 문구, 검증 · 측정 · smoke 도구, CI). 시점 표시: **(릴리스 전)** 다음 릴리스 전에 정할 것, **(손댈 때)** 그 파일을 다음에 손댈 때, **(v2)** v2 요구사항과 함께.

## Tech Debt

**`VERSIONING.md` 판정 순서와 기준표의 엇갈림 [안쪽] (릴리스 전):**
- Issue: 판정 순서 2번 목록이 닫혀 있고(목록 밖 설정 변경은 3번 patch 로 떨어짐), 3번은 "`lib/` 나 `pubspec.yaml` 이 바뀌긴 했나 → patch" 라서 `dev_dependencies` · 도구용 주석만 바뀐 변경도 글자대로는 patch 가 된다. README · CHANGELOG 만 고친 변경, 새 프리셋 파일 추가도 판정 순서와 기준표가 다른 등급을 낸다. 같은 major 안 하한 상향(`^3.1.3` → `^3.1.9`) 예시가 그 자체로 Dart 3.13 을 요구한다는 전제 문장이 없다
- Files: `VERSIONING.md:25-28` (판정 순서 1 ~ 4번), `VERSIONING.md:30` (하한 상향 문단 — 확인함, 새 하한의 SDK 요구를 보라는 문장 없음), `pubspec.yaml:20-25` (2.0.0 뒤 더한 `dev_dependencies` 와 주석)
- 묶이는 기록: 01:WR-03 · 06 · 07 · 08 · 09 · 10, Backlog 999.1 (`.planning/ROADMAP.md:29-35`), Backlog 999.3 (`.planning/ROADMAP.md:46-52`). 01:WR-06(CHANGELOG 형식 예시의 규칙 수)·WR-08·WR-10 의 개별 문구는 행 단위로 다시 확인하지 못함
- Impact: 다음 minor / patch 의 등급이 사람마다 흔들린다. 받는 쪽은 `ref:` tag 이름으로 변경 크기를 짐작하므로 등급이 틀리면 간접적으로 닿는다
- Fix approach: 판정 순서를 한 번에 다시 쓴다 — 2번을 "받는 쪽이 include 로 받는 값" 으로 열린 정의로, 3번 앞에 "저장소 안쪽만 바뀜(`dev_dependencies` · 도구용 주석 포함) → 올리지 않음" 을 두고, 30행에 "새 하한 버전이 요구하는 Dart 가 `environment.sdk` 하한보다 높으면 1번" 을 더한다

**`.claude/CLAUDE.md` 의 낡은 지시 [안쪽] (릴리스 전):**
- Issue: Technology Stack · Conventions · Architecture 절이 1.3.0 시절 서술(Flutter 3.41.2, `^3.10.4`, `riverpod_lint ^3.1.3`, "`lib/analysis_options.yaml` 이 유일한 산출물", 루트 exclude 유지)을 지시로 남긴다. 실제는 `.fvmrc` 3.47.5, `pubspec.yaml:11` `^3.13.0`, `lib/riverpod.yaml:4` `^3.1.9`, 프리셋 다섯 파일, 루트 `analysis_options.yaml:11-13` 는 `example/**` · `fixtures/**` 만 뺀다 — 확인함
- Files: `.claude/CLAUDE.md` (05:WR-06)
- Fix approach: 이번 `/gsd-map-codebase` 결과로 다시 만든다

**측정 도구의 기준선이 1.3.0 에 박힘 [안쪽] (v2, RULES-13 선행):**
- Issue: `currentRules` 가 1.3.0 의 규칙 6개다. 지금 `lib/base.yaml` (81개)에서 다시 재면 2.0.0 에서 켠 규칙이 기준선 B0 에 섞여 0줄로 나온다 (04:CR-03). `--recount` 가 `fixSkipped` 사유를 확인 없이 R1 전용 문장으로 적고, `fixCell` 이 `fixRemoved` 보다 `fixSkipped` 를 먼저 본다 (04:WR-09)
- Files: `tool/measure_rules.dart:273` (`const currentRules`, 확인함), `:415`, `:451`, `:496`; `tool/measure_rules.dart:4159-4165` (`fixSkipped` 를 먼저 보는 분기, 확인함), `:4222`
- Impact: RULES-13 (`lints` 7 / `flutter_lints` 7 대응) 재측정 결과가 틀린다. 지금 커밋된 R1 값에는 영향 없음 (`.planning/milestones/v2.0-REQUIREMENTS.md:104-105`)
- Fix approach: 기준선을 "`lib/base.yaml` 에서 읽은 지금 규칙" 으로 바꿀지 설계부터 정한 뒤 CR-03 · WR-09 를 함께 고친다. 04:WR-01 · 03 · 04 · 07 · 08 (회차 덮어쓰기 추적, `--out` · `--work` 검사, sdkTag 대조, 예외 때 지문 비교)도 같은 정비 범위 — 개별 행은 확인하지 못함

**검사가 보지 않는 문서 [안쪽] (손댈 때):**
- Issue: `tool/verify.dart` 는 `lib/base.yaml` · `RULES.md` · README 표시 구역을 견주지만 `04-DECISIONS.md` 와 `CHANGELOG.md` 의 추가 규칙 · 경고 표는 견주지 않는다 (`.planning/milestones/v2.0-MILESTONE-AUDIT.md:97`)
- Files: `CHANGELOG.md`, `tool/verify.dart`
- Fix approach: 다음 규칙 변경 때 CHANGELOG 표를 검사 대상에 넣을지 정한다

**`.planning/` 처리 기록의 상태 [안쪽]:**
- Issue: 감사가 짚은 처리 기록 4건 · 장부 2건은 커밋 `585813e` 에서 `fixed` 로 정리되었다 (git log). 각 phase 의 `*-REVIEW-DISPOSITION.md` 에는 `open` 줄이 남아 있다(grep 으로 20건 셈 — 판정하지 않은 IN 항목 포함, 개별 판정은 확인하지 못함)
- Files: `.planning/milestones/v2.0-phases/*/*-REVIEW-DISPOSITION.md`

## Known Bugs

**lock 불일치 안내가 틀린 경로를 알림 [안쪽] (손댈 때):**
- Symptoms: 연습용 프로젝트의 lock 이 어긋나면(`pub get --enforce-lockfile` 이 65, 검증은 69 로 끝남 — `tool/verify.dart:625-635`) "`cd $name && fvm dart pub get`" 을 안내하는데, `fixtures/` 아래 프로젝트에서는 `fixtures/` 접두가 빠진 이름이 들어간다 (03:WR-04). 루트 `version` 을 바꿨을 때도 안내가 `example/pubspec.yaml` 쪽을 가리킨다 (02:WR-06)
- Files: `tool/verify.dart:625-630` (확인함 — `$name` 사용), `VERSIONING.md:141` (확인함 — 「릴리스 절차」 2번의 완화 문장: 루트 `version` 만 바꾸고 lock 을 다시 받지 않은 검증은 종료 코드 69 로 끝나며 안내가 `example/` 을 가리키지만 원인은 루트 `version` 이다)
- Trigger: `fixtures/*/pubspec.lock` 이 `pubspec.yaml` 과 어긋난 채 `tool/verify.dart` 실행 — 재현하지 않음, 근거: 03-REVIEW
- Workaround: 저장소 루트 기준 경로(`fixtures/<이름>`)로 직접 이동해 `pub get`

**`killTree` 가 얼린 자손을 살려 둘 수 있음 [안쪽] (손댈 때, Backlog 999.2):**
- Symptoms: P → A → B 사슬에서 A 가 첫 표 직후 끝나면 B 가 SIGCONT 로 풀려 남는다 (06:IN-11)
- Files: `tool/smoke.dart:428` (사슬 밖 pid 는 SIGCONT 로 푼다는 머리 주석, 확인함), `:434` (`killTree`), `:495`, `:532`, `:1094`
- Trigger: 재현하지 않음 — 근거: `.planning/ROADMAP.md:44` (reviewer · verifier 재현 기록)
- Workaround: smoke 뒤 남은 `dart` 프로세스를 손으로 확인

**`example/README.md` 의 낡은 읽는 법 [안쪽] (손댈 때, Backlog 999.2):**
- Symptoms: 읽는 법 (4) · (5) 와 11행 괄호가 CHANGELOG 첫 줄 규칙 뒤의 동작과 다르다 — `# Changelog` 머리말이 통과한다고 현재형으로 말한다 (06:IN-10)
- Files: `example/README.md:11` (확인함 — 개발용 의존성 둘을 설명하는 괄호), 소절 (4) · (5) 의 정확한 행은 grep 으로 찾지 못함 (확인하지 못함)

**`--update` 가 plugin 미준비 결과를 정답지로 쓸 수 있음 [안쪽] (손댈 때):**
- Symptoms: plugin 버전이 `?` 이거나 plugin 준비가 실패한 실행의 결과를 `--update` 가 정답지(`expected_diagnostics.txt`)로 쓰는 것을 막는 장치가 없다 (02:WR-01 = 03:WR-07)
- Files: `tool/verify.dart:11-12` (`--update` 설명), `:259-264`, `example/expected_diagnostics.txt`, `fixtures/*/expected_diagnostics.txt`
- Trigger: 재현하지 않음 — 근거: 02-REVIEW / 감사 42행. 가드 유무는 코드 전부를 읽지 않아 확인하지 못함
- Workaround: `--update` 뒤 정답지 diff 에 `riverpod_lint` 진단 줄이 사라졌는지 사람이 본다

## Security Considerations

**CI 로그의 절대 경로 [안쪽]:**
- Risk: 정답지 첫 줄이 `exit N` 꼴이 아니면 `FormatException` 메시지가 파일의 전체 경로를 담고 exit 70 으로 끝난다. 공개 저장소의 CI 로그에 runner 경로가, 로컬 실행 출력에는 홈 폴더 경로가 남을 수 있다. `--update` 로도 고칠 수 없다 (02:WR-05 = 03:WR-05)
- Files: `tool/verify.dart:328` (`throw FormatException('... ${file.path}')`, 확인함), `:493`
- Current mitigation: 없음 (정답지를 손으로 고치지 않는 관례뿐)
- Recommendations: 메시지에 저장소 기준 상대 경로를 쓰고, 첫 줄이 깨진 정답지는 `--update` 가 다시 쓰게 한다

**workflow action 이 움직이는 tag [안쪽] (손댈 때):**
- Risk: `actions/checkout@v7` · `subosito/flutter-action@v2` 를 SHA 가 아닌 tag 로 받는다 (03:WR-08). tag 가 옮겨지면 다른 코드가 돈다
- Files: `.github/workflows/verify.yml:28`, `:31` (확인함)
- Current mitigation: `permissions: contents: read` (`.github/workflows/verify.yml:13-14`), 비밀값 사용 없음
- Recommendations: 커밋 SHA 고정 + 주석으로 tag 이름

**머리말 없는 stderr 가 찍히지 않음 [안쪽] (손댈 때):**
- Risk: 보안이라기보다 진단 손실 — plugin 실패 머리말(`tool/verify.dart:51`)이 없는 stderr 는 출력되지 않아 원인 파악이 늦다 (02:WR-04). 재현하지 않음 — 근거: 02-REVIEW
- Files: `tool/verify.dart:51`, `:363-373`

## Performance Bottlenecks

**CI 의 연습용 프로젝트 여섯 차례 분석 [안쪽]:**
- Problem: 정상 약 4분 7초, `timeout-minutes: 10` (`.github/workflows/verify.yml:25-26`). 프로젝트마다 cold plugin 준비가 든다
- Files: `tool/verify.dart`, `fixtures/` 다섯 + `example/`
- Cause: 상태 폴더를 캐시하지 않는 설계(`.claude/skills/spike-findings-woody-lints/SKILL.md:214`)
- Improvement path: 동시에 띄우면 분석이 약 절반이라는 실측(spike 017)이 있다. fixture 가 더 늘면 timeout 과 함께 다시 본다

**도구 파일 크기 [안쪽]:**
- Problem: `tool/measure_rules.dart` 5188줄, `tool/verify.dart` 3223줄, `tool/smoke.dart` 1143줄 (wc). 한 파일에 단계 · 파서 · 안내 문장이 모두 있다
- Improvement path: 다음 대규모 수정 때 reader · 단계별로 파일을 나눌지 정한다 (대규모 리팩터링은 소유자 확인 먼저)

## Fragile Areas

**줄 단위 reader 와 YAML 해석기의 이중 읽기 [안쪽]:**
- Files: `tool/verify.dart`, `pubspec.yaml:20-21` (`yaml` · `markdown` 을 둘째 reader 로 쓴다는 주석)
- Why fragile: 배포 YAML · README · CHANGELOG 를 줄 단위로 읽고 해석기 결과와 견준다. 목록 형식(`- rule`)이 아닌 맵 형식, 펜스 모양 변화, CHANGELOG 첫 줄 규칙 같은 글자 꼴에 묶인다. `markdown` 판이 바뀌면 거짓 실패가 날 수 있다 (06:IN-08 — 거짓 실패 쪽뿐)
- Safe modification: `lib/base.yaml` 은 목록 형식과 분류 주석을 유지한다. README 의 `woody:readme-rules` 구역 밖에 규칙 목록 줄을 두지 않는다
- Test coverage: `example/README.md` 의 M 표(깨기 실험)가 경우를 기록한다

**정답지 갱신 [안쪽]:**
- Files: `example/expected_diagnostics.txt`, `fixtures/*/expected_diagnostics.txt`, `tool/verify.dart:262` (머리 형식)
- Why fragile: 규칙 · SDK · plugin 이 바뀔 때마다 여섯 파일을 `--update` 로 다시 쓴다. plugin 미준비 결과가 섞여도 막지 않는다(위 Known Bugs)
- Safe modification: `--update` 뒤 `git diff` 로 plugin 진단 줄 수를 확인한다

**fixture `lib/` 복사본 [안쪽] (손댈 때):**
- Files: `fixtures/*/lib`, `example/lib`
- Why fragile: `fixtures/*/lib` 가 `example/lib` 복사본인지 보는 자동 검사가 없다. 문서화된 예외는 `relative_imports_rule.dart` 하나 (03:WR-06 — 검사 부재는 감사 기록 근거, 코드 전부를 읽지 않아 확인하지 못함)
- Safe modification: `example/lib` 를 고치면 `fixtures/*/lib` 에 같은 변경을 넣는다

**plugin 버전의 세 자리 동기화 [안쪽 → 받는 쪽]:**
- Files: `lib/riverpod.yaml:4`, `fixtures/overrides/analysis_options.yaml:9-10` (`version: ^3.1.9`, 확인함), README 의 plugin 버전 예시
- Why fragile: 하한을 올릴 때 세 곳을 같은 커밋에서 고쳐야 한다 (`lib/riverpod.yaml:4` 주석). 검증 `[3/10]` · `[4/10]` 이 견준다

**생성 파일 제외의 SDK 별 차이 [받는 쪽]:**
- Files: `lib/codegen.yaml:3` (확인함 — "SDK 에 따라 사용 프로젝트의 plugin 진단(베타에서는 규칙 진단에도)에 닿지 않을 수 있다"), README 「생성 파일 제외」
- Why fragile: include 로 받은 `analyzer.exclude` 가 받는 쪽 루트 기준으로 통하는지가 SDK 판에 따라 다르다 (spike reference `suppression-and-exclude.md`)
- Safe modification: `.fvmrc` 를 올릴 때 README 의 직접 적는 방법이 여전히 필요한지 다시 잰다

**옛 주소 별칭 [받는 쪽]:**
- Files: `lib/analysis_options.yaml:4` (`include: package:woody_lints/recommended.yaml`, 확인함), `lib/recommended.yaml:4-7`
- Why fragile: 사용 프로젝트 다수가 옛 주소를 쓴다(CLAUDE.md Constraints). 파일명 · 위치 변경이나 별칭 내용 변경은 곧 breaking

**`avoid_final_parameters` 의 언어 버전 조건 [받는 쪽]:**
- Files: `lib/base.yaml` 의 `avoid_final_parameters` 줄 주석 (확인함 — "언어 버전 3.13 의 라이브러리에서는 돌지 않는다")
- Why fragile: 받는 쪽의 언어 버전에 따라 켜져도 진단이 없다. 사용자가 "적용된다" 고 오해할 수 있다

## Scaling Limits

**연습용 프로젝트 수와 CI 시간 [안쪽]:**
- Current capacity: 여섯 프로젝트, 약 4분 (`.github/workflows/verify.yml:25`)
- Limit: `timeout-minutes: 10`
- Scaling path: 병렬 실행 또는 timeout 상향

## Dependencies at Risk

**`ubuntu-latest` → Ubuntu 26.04 (2026-10-19 ~ 11-19) [안쪽] (릴리스 전 — 다음 CI 실행):**
- Risk: runner 이미지가 바뀐다. `ubuntu-26.04` 20260927.149.1 하나에서만 같은 결과를 확인했다 (`.claude/skills/spike-findings-woody-lints/SKILL.md:68`, `:186`)
- Files: `.github/workflows/verify.yml:24` (`runs-on: ubuntu-latest`, 확인함)
- Impact: 다음 CI 가 이미지 탓으로 실패할 수 있다
- Migration plan: 실패하면 로그의 `Image` · `Version` 줄을 위 값과 견준다 (`.claude/skills/spike-findings-woody-lints/references/ci-workflow.md` 4번). 급하면 `runs-on: ubuntu-24.04` 로 고정

**`lints` 7 / `flutter_lints` 7 [받는 쪽] (v2, RULES-13):**
- Risk: 기반 세트에 새로 들어오는 규칙이 `lib/base.yaml` 의 선언과 겹친다. `flutter_lints` 를 7 로 올리는 것은 `VERSIONING.md:25` 기준 major
- Files: `pubspec.yaml:17` (`flutter_lints: ^6.0.0`, 확인함), `lib/base.yaml`
- Migration plan: 측정 도구 기준선(위 Tech Debt)부터 고친 뒤 재측정, 겹친 선언 제거, CHANGELOG 칸 배치를 `VERSIONING.md` 에 적을지 정한다

**`riverpod_lint` 새 버전 [받는 쪽]:**
- Risk: plugin 은 pub 의존성이 아니라 Analysis Server plugin 캐시에서 `^3.1.9` 범위로 해석되므로, 받는 쪽마다 다른 3.x 가 돌 수 있다. 하한 상향은 Dart 요구를 함께 올릴 수 있다 (3.1.9 → Dart 3.13, `.planning/ROADMAP.md:35`)
- Files: `lib/riverpod.yaml:4`
- Migration plan: 하한을 올릴 때 새 버전의 SDK 요구를 `pubspec.yaml:11` 과 견주고, 정답지 여섯을 다시 쓴다

**Flutter / Dart 3.14 계열 [안쪽 → 받는 쪽]:**
- Risk: `.fvmrc` 를 올리는 커밋이 CI SDK 를 올린다. 베타에서는 codegen exclude 가 규칙 진단에도 닿지 않았다는 기록이 있다 (`lib/codegen.yaml:3`)
- Files: `.fvmrc` (`3.47.5`)
- Migration plan: spike reference `next-sdk-forward-compat.md` 를 먼저 읽는다

## Missing Critical Features

**CHANGELOG · 결정 표 자동 대조:**
- Problem: 규칙 목록의 근거 문서 중 `CHANGELOG.md` 표와 `04-DECISIONS.md` 는 검사 밖이다
- Blocks: 규칙 변경 시 문서 불일치가 자동으로 잡히지 않는다

## Test Coverage Gaps

**측정 도구 [안쪽]:**
- What's not tested: `tool/measure_rules.dart` 의 기준선 · `--recount` · 회차 덮어쓰기 방지
- Files: `tool/measure_rules.dart`
- Risk: RULES-13 재측정 값이 틀려도 모른다
- Priority: High (v2 착수 전)

**smoke 도구의 프로세스 정리 [안쪽]:**
- What's not tested: `killTree` 의 중간 프로세스가 먼저 끝나는 경우
- Files: `tool/smoke.dart:434`
- Risk: 남은 분석 프로세스
- Priority: Low

**README 검사의 범위 한계 [안쪽]:**
- What's not tested: 05:WR-07 · 08 · 09 · 12 · 13 · 14 · IN-08 · IN-10 — 소유자가 범위 밖으로 둠 (감사 64행). 개별 내용은 확인하지 못함
- Files: `tool/verify.dart`, `README.md`
- Priority: Low

**fixture 복사본 일치:**
- What's not tested: `fixtures/*/lib` 와 `example/lib` 의 일치
- Files: `fixtures/`, `example/lib`
- Priority: Medium

---

*Concerns audit: 2026-10-17*
