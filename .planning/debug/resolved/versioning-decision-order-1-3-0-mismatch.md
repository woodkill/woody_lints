---
status: resolved
trigger: "UAT gap G-01-1 — VERSIONING.md 의 판정 순서(25-28행)를 1.3.0 사례에 문자 그대로 대입하면 major 가 나오는데 '실제 사례' 절은 minor 라고 적었다. 2.0.0 사례는 일치한다. 소유자는 UAT 에서 '문서를 고친다'를 택했다."
created: 2026-10-11T06:09:39Z
updated: 2026-10-16T23:46:09Z
mode: find_root_cause_only
symptoms_prefilled: true
bug_class: Bohrbug (결정적 — 같은 문서를 읽으면 항상 같은 두 답이 나온다)
---

## Current Focus
<!-- OVERWRITE on each update - reflects NOW -->

hypothesis: (확정) 판정 순서 1번(`VERSIONING.md` 25행 = `01-CONTEXT.md` D-09 ①, 68행)의 둘째 조건 "자동 검사가 막힐 수 있나" 는 기준표 42행의 **결과 칸**("받는 쪽이 겪는 일: 자동 검사가 막힐 수 있다")만 떼어 온 문구다. 기준표는 **변경 종류 칸**("규칙 심각도를 warning 이상으로 올림")으로 등급을 매기는데, 질문에서는 변경 종류 한정이 빠졋다. 그래서 "결과가 같은 다른 변경" — 처음부터 warning 등급인 규칙을 새로 켜는 것(1.3.0 의 `riverpod_lint` 첫 활성화, 기준표 43행·46행) — 도 1번에 "예" 로 걸린다. 1.3.0 사례(60-62행)는 기준표·D-02 의 변경 종류 기준(규칙/plugin 추가 = minor)으로 썼기 때문에 이 조건을 따지지 않았다. 분류: **(a) 문구 결함** — D-02 의 채택 근거(`research/ARCHITECTURE.md` 388행: "규칙 추가는 `--fatal-infos` CI 를 깨뜨릴 수 있어 엄밀히 breaking 이지만 tag 고정이라 MINOR 로 둔다")가 "자동 검사가 막힐 수 있다" 를 이미 minor 로 받아들였으므로, 그 결과를 major 질문으로 쓴 것은 정책 의도와 어긋나는 문구다.
test: 완료 — 문장 대조, 연구 문서 추적, 사실 재확인
expecting: 해당 없음
next_action: 없음 — 소유자가 방향 (나) 를 택했고 01-04 에서 고쳤다 (Resolution.fix 참조). v2.0 마감 전 점검(2026-10-16 UTC)에서 소유자 확인으로 resolved 처리
known_pattern_candidate: 없음 (`.planning/debug/knowledge-base.md` 부재)

reasoning_checkpoint:
  hypothesis: "판정 순서 1번 둘째 조건이 기준표 42행의 결과 칸만 옮긴 것이어서 변경 종류 한정이 빠졌고, 그 결과 기준표가 minor 로 두는 'warning 등급 규칙의 신규 활성화'(1.3.0) 까지 major 로 읽힌다"
  confirming_evidence:
    - "VERSIONING.md 25행 둘째 조건 '자동 검사가 막힐 수 있나' == 기준표 42행 3열 '자동 검사가 막힐 수 있다' (글자 단위). 42행 1열의 변경 종류 '규칙 심각도를 warning 이상으로 올림' 은 25행에 없다"
    - "VERSIONING.md 43행 '규칙을 넣거나 뺌 → minor', 46행 'riverpod_lint 하한 상향 → minor', 93행 강도 열 '(info / warning / error)' — 정책은 warning 등급 규칙이 minor 릴리스에 들어오는 것을 전제한다"
    - "research/ARCHITECTURE.md 388행 (D-02 의 근거): 규칙 추가가 CI 를 깨뜨릴 수 있음을 인정하면서도 MINOR 로 둔다. research/PITFALLS.md 539-540행 (D-04 의 근거): major 는 '기본 심각도를 WARNING 이상으로 올리는 변경'(변경 종류), minor 는 'plugin 추가' 포함"
    - "01-02-SUMMARY.md 308행: 실행자가 같은 빈칸('처음부터 warning 인 규칙을 새로 켜는 경우는 표에 없고 1번에 예 로 읽힐 수 있다')을 보고 D-09 3. 이 1.3.0 = minor 를 확정했다는 이유로 그대로 적었다"
    - "사실 재확인: riverpod_lint 3.1.3 LintCode 15개 중 WARNING 11, ERROR 1, 명시 없음(기본 INFO) 3. fvm dart analyze --help (Dart 3.13.4): --[no-]fatal-warnings (defaults to on)"
  falsification_test: "25행 둘째 조건을 42행 1열의 변경 종류('이미 켜진 규칙의 심각도가 warning 이상으로 올라가나')로 바꿔 두 사례에 다시 대입했을 때 1.3.0 이 여전히 major 로 나오면 가설은 틀렸다. 실제: 1.3.0 → 1번 아니오(심각도 상향 없음) → 2번 예 → minor. 2.0.0 → 1번 예 → major. 둘 다 문서와 일치한다"
  fix_rationale: "(diagnose only) 어느 방향이든 25행·61행·52행은 함께 움직여야 한다. 방향은 소유자 결정 — Suggested Fix Direction 참조"
  blind_spots: "소유자의 실제 의도가 '결과 기준'(CI 가 막히면 major) 쪽일 가능성. 문서·연구·결정 원문은 전부 '변경 종류 기준' 을 가리키지만 소유자에게 직접 묻지 않았다. 또 사용 프로젝트 5개의 CI 가 dart analyze 인지 flutter analyze 인지 이 저장소에서는 알 수 없다 (WR-02)"
  candidate_causes:
    - "config(정책 문구): D-09 ① 둘째 조건이 결과 기반으로 쓰여 변경 종류 한정이 없다 — 1차 원인"
    - "data(plugin 사실): riverpod_lint 3.1.3 규칙 12/15 가 warning 이상 — 둘째 조건이 '예' 가 되는 필요조건"
    - "environment(도구 기본값): dart analyze 는 warning 을 기본 fatal, flutter analyze 는 info 까지 기본 fatal — 둘째 조건의 폭을 더 넓힌다 (WR-02)"
    - "process: 01-02 실행자가 빈칸을 인지하고도 D-09 3. 의 확정을 이유로 미뤘다. 검증은 절 제목 grep 과 결정 원문 diff 라서 결정 원문 사이의 모순은 잡을 수 없었다"
  and_gate: "yes — 결함이 드러나려면 (1) 둘째 조건이 결과 기반 문구일 것 AND (2) 새로 켠 규칙에 warning 이상이 있을 것(또는 자동 검사가 flutter analyze 일 것) 이 동시에 참이어야 한다. (2) 가 거짓(전부 info, dart analyze 기준)이면 같은 문구로도 1.3.0 은 minor 로 나온다. 그러나 (2) 는 외부 사실이라 고칠 수 없으므로 수정 지점은 (1) 이다"

## Symptoms
<!-- Written during gathering, then IMMUTABLE -->

expected: `VERSIONING.md` 의 판정 순서(25-28행)를 1.3.0 사례와 2.0.0 사례에 문자 그대로 대입하면 '실제 사례' 절이 적은 등급과 같은 답이 나온다 (1.3.0 은 1번의 두 조건을 모두 따진다).
actual: 1.3.0 사례(60-62행)는 1번의 첫째 조건(설정 파일·SDK 를 고쳐야 하나)만 답하고 둘째 조건(자동 검사가 막힐 수 있나)을 건너뛴다. 둘째 조건을 따지면 "예"로 읽힌다 — riverpod_lint 3.1.3 의 규칙 11개가 WARNING, 1개가 ERROR 이고 `dart analyze` 는 warning 을 기본으로 실패 처리한다. 소유자는 UAT 에서 "문서를 고친다"를 택했다.
errors: 없음 (문서 일관성 결함, 코드 없음)
reproduction: `.planning/phases/01-baseline-and-toolchain/01-UAT.md` Test 1
started: UAT (2026-10-11) 에서 발견. 코드 리뷰 WR-01 이 먼저 지적했고 phase 검증자가 재확인했다

## Eliminated
<!-- APPEND only - prevents re-investigating -->

- hypothesis: `VERSIONING.md` 가 `01-CONTEXT.md` 의 결정을 옮기다 틀렸다 (구현 결함)
  evidence: 25행 == CONTEXT 68행, 기준표 36-48행 == CONTEXT 43-55행, 52행 == D-02(CONTEXT 37행), 54행 == D-04(CONTEXT 40행), 60행 요지 == D-09 3.(CONTEXT 73행). 검증자(01-VERIFICATION 137행)의 `diff` 도 차이 없음
  timestamp: 2026-10-11T06:12:00Z
- hypothesis: 1.3.0 사례가 1번 첫째 조건을 잘못 답했다 (받는 쪽이 실제로 설정을 고쳐야 했다)
  evidence: `CHANGELOG.md` 15-19행 — 1.3.0 은 `lib/analysis_options.yaml` 안의 `plugins:` 위치만 바꿨고 SDK 하한은 `^3.10.4` 그대로. 받는 쪽은 `include` 한 줄만 유지하면 됐다. 첫째 조건 "아니오" 는 맞다
  timestamp: 2026-10-11T06:13:00Z
- hypothesis: 둘째 조건을 정직하게 따져도 1.3.0 은 "아니오" 다 (riverpod_lint 규칙이 전부 info)
  evidence: `~/.pub-cache/hosted/pub.dev/riverpod_lint-3.1.3/lib/src/lints/*.dart` — `severity: DiagnosticSeverity.WARNING` 11개, `ERROR` 1개(`riverpod_syntax_error`), 미지정 3개(`protected_notifier_properties`, `avoid_build_context_in_providers`, `avoid_public_notifier_properties` → analyzer `LintCode` 기본값 INFO, analyzer-14.5.0 `lint_codes.dart:61` 확인). `fvm dart analyze --help` → `--[no-]fatal-warnings (defaults to on)`. 따라서 "막힐 수 있나" 는 "예"
  timestamp: 2026-10-11T06:14:00Z
- hypothesis: (b) D-02 와 D-04 가 정책 수준에서 모순이어서 어느 한쪽을 버려야만 한다
  evidence: D-02 의 근거(ARCHITECTURE 388행)는 "규칙 추가가 CI 를 깨뜨릴 수 있지만 tag 고정이라 minor + CHANGELOG '새로 생기는 경고' 로 충분" 이고, D-04 의 근거(PITFALLS 539행)는 변경 종류 "기본 심각도를 WARNING 이상으로 올리는 변경" 이다. 둘은 변경 종류로 나누면 공존한다(추가 = minor, 기존 규칙 심각도 상향 = major). 모순으로 보이는 것은 D-04 를 옮긴 54행과 D-09 ① 이 변경 종류 대신 **결과**("dart analyze 가 통과에서 실패로", "자동 검사가 막힐 수 있나")로 쓰였기 때문이다. 즉 정책 모순이 아니라 문구가 결과 기준으로 미끄러진 것. 단, 소유자가 결과 기준을 원한다면 정책 변경으로 해결할 수도 있다 (Suggested Fix Direction 가)
  timestamp: 2026-10-11T06:16:00Z

## Evidence
<!-- APPEND only - facts discovered -->

- timestamp: 2026-10-11T06:09:39Z
  checked: `VERSIONING.md` 전문, `01-CONTEXT.md` 전문, `01-UAT.md`, `STATE.md`
  found: 판정 순서 1번(25행)은 D-09 ①(CONTEXT 68행)과 글자 단위로 같다. 기준표(36-48행)는 D-05 표(CONTEXT 43-55행)와 같다. 사유 54행("규칙 심각도를 info 에서 warning 이상으로 올리는 변경은 major")은 D-04(CONTEXT 40행)와 같다. 사유 52행("major 는 받는 쪽이 설정 파일이나 SDK 를 고쳐야 하는 변경에만 쓴다")은 D-02(CONTEXT 37행)와 같다
  implication: `VERSIONING.md` 는 결정을 충실히 옮겼다. 어긋남은 결정 문구 자체 사이에 있다
- timestamp: 2026-10-11T06:10:00Z
  checked: `.planning/debug/` 디렉터리 (Phase 0 knowledge base)
  found: `knowledge-base.md` 없음 (첫 debug 세션)
  implication: 알려진 패턴 후보 없음. 일반 조사로 진행
- timestamp: 2026-10-11T06:11:00Z
  checked: 25행의 두 조건을 기준표의 열과 대조
  found: 첫째 조건 "설정 파일이나 SDK 를 고쳐야 하나" = 38행·39행의 3열("설정 파일을 고쳐야 한다" / "SDK 를 올려야 한다"). 둘째 조건 "자동 검사가 막힐 수 있나" = 42행의 3열("자동 검사가 막힐 수 있다"). 즉 1번은 major 행 중 세 행의 **3열(결과)** 을 질문으로 바꾼 것이고, 40행·41행(기반 세트·plugin major 상향)은 빠졌다(이것이 WR-03 의 셋째 경우). 42행의 **1열(변경 종류)** "규칙 심각도를 warning 이상으로 올림" 은 질문에 들어가지 않았다
  implication: 결과(3열)는 변경 종류(1열)보다 넓다. 43행 "규칙을 넣거나 뺌" 과 46행 "riverpod_lint 하한 상향" 도 새 규칙이 warning 등급이면 결과는 "자동 검사가 막힐 수 있다" 로 같다. 기준표는 이 둘을 minor 로 두므로, 결과로 묻는 1번과 변경 종류로 매기는 표가 바로 이 지점에서 갈린다
- timestamp: 2026-10-11T06:12:30Z
  checked: 1.3.0 사례 60-62행의 논리 구조
  found: 60행 "그때까지 로드되지 않던 riverpod_lint 를 처음 켰다 → minor (2번에서 멈춤)" = D-09 3.(CONTEXT 73행)의 확정 문구. 61행은 1번의 첫째 조건만 답한다. 62행은 2번 "plugin 규칙이 처음 켜지므로 경고가 달라진다" = 43행 3열의 문구
  implication: 사례는 "규칙/plugin 추가 = minor"(D-02, 43행) 로 추론한 것이다. 변경 종류 기준에서는 1번 둘째 조건이 해당 사항이 없어 건너뛴 것이지만, 25행의 문구는 그 한정을 담고 있지 않아 문자 그대로 읽는 독자는 "예" 로 답하게 된다
- timestamp: 2026-10-11T06:13:30Z
  checked: `~/.pub-cache/hosted/pub.dev/riverpod_lint-3.1.3/lib` — `grep -rn "Severity\." --include='*.dart'`, `grep -rn "LintCode("`
  found: `LintCode(` 생성 15개. `severity: DiagnosticSeverity.WARNING` 11개 (`missing_provider_scope`, `provider_parameters`, `scoped_providers_should_specify_dependencies`, `provider_dependencies`, `only_use_keep_alive_inside_keep_alive`, `notifier_build`, `async_value_nullable_pattern`, `unsupported_provider_value`, `avoid_ref_inside_state_dispose`, `notifier_extends`, `functional_ref`). `DiagnosticSeverity.ERROR` 1개 (`riverpod_syntax_error`). 미지정 3개 (`protected_notifier_properties`, `avoid_build_context_in_providers`, `avoid_public_notifier_properties`) — analyzer `LintCode` 생성자 기본값 `this.severity = DiagnosticSeverity.INFO` (analyzer-14.5.0 `lib/src/dart/error/lint_codes.dart:61`). 3.1.9 도 pub cache 에 있다 (검증자 보고와 같음)
  implication: 보고서의 "WARNING 11 / ERROR 1" 재확인. 1.3.0 은 warning 이상 규칙 12개를 처음 켠 변경이다
- timestamp: 2026-10-11T06:14:30Z
  checked: `fvm dart analyze --help` (fvm 4.3.1, Dart SDK 3.13.4), `fvm flutter analyze --help` (Flutter 3.47.5)
  found: `dart analyze`: `--fatal-infos` (기본 off), `--[no-]fatal-warnings … (defaults to on)`. `flutter analyze`: `--[no-]fatal-infos (defaults to on)`, `--[no-]fatal-warnings (defaults to on)`
  implication: `dart analyze` 기준으로 warning 규칙 1개만 걸려도 종료 코드가 0 이 아니다 → 1.3.0 은 "자동 검사가 막힐 수 있다". `flutter analyze` 기준이면 info 규칙 추가도 막는다 → 둘째 조건의 폭은 "자동 검사" 가 어느 명령인지(WR-02)에 따라 더 넓어진다
- timestamp: 2026-10-11T06:15:30Z
  checked: 결정 문구의 출처 — `.planning/research/ARCHITECTURE.md` 380-389행, `.planning/research/PITFALLS.md` 535-541행, `.planning/ROADMAP.md` 64·87행
  found: ARCHITECTURE 387행은 "규칙 추가, 심각도 상향, plugin minor 상향, 새 프리셋 → MINOR" 였고 388행에 "규칙 추가는 `--fatal-infos` CI 를 깨뜨릴 수 있으므로 엄밀히는 breaking 이다. 그러나 tag 고정 방식에서는 올리는 시점을 사용자가 고르므로 MINOR 로 두고 CHANGELOG '새로 생기는 진단' 절을 반드시 넣는다" 고 적었다 (→ D-02 의 근거). PITFALLS 539행은 major 에 "기본 심각도를 WARNING 이상으로 올리는 변경"(변경 종류 문구) 을, 540행은 minor 에 "plugin 추가, plugin 하한 상승" 을 둔다 (→ D-04 / D-05 의 근거). ROADMAP 87행: 15개 규칙의 심각도는 "조사 문서끼리 info 와 warning 으로 어긋나 있고 실측된 것은 규칙 1개뿐" (Phase 2 spike 항목)
  implication: 채택된 정책의 근거는 일관되게 **변경 종류** 기준이고, "CI 가 막힐 수 있다" 는 결과는 규칙 추가에서도 생긴다는 것을 알면서 minor 로 받아들였다. D-04 가 PITFALLS 의 변경 종류 문구를 옮기면서 결과("dart analyze 가 통과에서 실패로 바뀔 수 있다")를 이유로 덧붙였고, D-09 ① 은 그 결과만 질문으로 삼았다. 결정 당시 riverpod_lint 심각도가 미확인이었으므로 "warning 규칙을 새로 켜는 경우" 가 실제 사례(1.3.0)에 해당한다는 것이 보이지 않았다
- timestamp: 2026-10-11T06:16:30Z
  checked: `.planning/phases/01-baseline-and-toolchain/01-02-SUMMARY.md` 307-308행, 326행
  found: 실행자가 "정책의 빈칸 하나 (해결하지 않고 남긴다)" 로 정확히 이 지점을 적었다 — "처음부터 warning 인 규칙을 새로 켜는 경우는 표에 없고, 판정 순서 1번의 '자동 검사가 막힐 수 있나' 에 '예' 로 읽힐 수 있다. D-09 는 1.3.0 을 minor 로 확정했으므로 그대로 적었다. Phase 2 의 spike 에서 riverpod_lint 에 warning 규칙이 확인되면 … 소유자가 정해야 한다. UAT 에서 1.3.0 사례를 대입할 때 걸릴 수 있는 지점이다"
  implication: 결함은 실행 시점에 인지되었고, 잠긴 결정(D-09 3.)과 미확인 사실(심각도) 때문에 소유자 결정으로 미뤄졌다. 리뷰(WR-01)와 검증(SC4 상세 1)과 UAT(Test 1)가 차례로 같은 지점을 올렸다. 왜 못 잡았나: 검증 게이트가 "결정 원문과 일치하는가"(diff, grep -qx) 였고 "결정 원문끼리 일치하는가" 를 보는 게이트는 없었다
- timestamp: 2026-10-11T06:17:00Z
  checked: 리뷰 WR-02 / WR-03 / WR-04 (01-REVIEW.md 81-159행) 와 이 뿌리의 관계
  found: WR-02 — 25행 같은 조건의 "자동 검사" 가 어느 명령인지 미정의. WR-03 — 판정 순서가 기준표 40·41행(major 상향), 45행(새 프리셋), 47행(README/CHANGELOG 만) 을 빠뜨려 셋에서 표와 다른 답. WR-04 — 52행 "에만"(D-02) 이 54행(D-04)·40-42행과 모순
  implication: WR-02 와 WR-04 는 같은 뿌리의 다른 얼굴이다 — 둘 다 "CI 가 막힐 수 있다" 는 결과를 major 의 경계로 쓸 것인지가 미정이어서 생긴다. 특히 61행의 1.3.0 추론은 52행의 좁은 major(설정·SDK 만)를 따르고, 25행은 54행의 넓은 major(결과)를 따른다 — WR-01 과 WR-04 는 같은 긴장을 사례 수준과 사유 수준에서 각각 드러낸 것. WR-03 은 구조적 원인(D-09 가 D-05 를 행 단위로 옮기지 않았다)은 같지만 방향이 반대(누락 → 너무 좁음)이고 다른 행(40·41·45·47)에 걸리며 1.3.0 사례와 무관하다 — 별개 결함

## Resolution
<!-- OVERWRITE as understanding evolves -->

root_cause: |
  판정 순서 1번(`VERSIONING.md` 25행 ← `01-CONTEXT.md` D-09 ① 68행)의 둘째 조건 "자동 검사가 막힐 수 있나" 는 기준표 42행(← D-05, CONTEXT 49행)의 **결과 칸**(3열 "자동 검사가 막힐 수 있다")을 그대로 질문으로 바꾼 것이고, 같은 행의 **변경 종류 칸**(1열 "규칙 심각도를 warning 이상으로 올림" ← D-04, CONTEXT 40행 ← PITFALLS 539행)은 빠졌다. 기준표는 변경 종류로 등급을 매기므로 "결과는 같지만 변경 종류가 다른" 경우 — 처음부터 warning 이상인 규칙을 새로 켬(43행 규칙 추가, 46행 plugin 하한 상향, 그리고 1.3.0 의 `riverpod_lint` 첫 활성화) — 를 minor 로 두는데, 결과로 묻는 1번은 이들을 major 로 읽는다. 1.3.0 사례(60-62행 ← D-09 3., CONTEXT 73행)는 변경 종류 기준(D-02 "규칙 추가 = minor", CONTEXT 37행)으로 썼기 때문에 둘째 조건을 따지지 않았고, 문자 그대로 읽는 독자는 riverpod_lint 3.1.3 의 WARNING 11 / ERROR 1 규칙과 `dart analyze` 의 `--fatal-warnings` 기본값(on) 때문에 "예" 로 답하게 된다.
  분류: **(a) 문구 결함** — 1번 둘째 조건이 기준표·D-02 가 뜻하는 범위보다 넓다. (b) 정책 모순은 아니다: D-02 의 채택 근거(`research/ARCHITECTURE.md` 388행)는 규칙 추가가 CI 를 깨뜨릴 수 있음을 인정한 채 minor 로 두었고, D-04 의 근거(PITFALLS 539행)는 변경 종류("심각도를 올리는 변경")로 쓰여 있어 둘은 공존한다. 모순처럼 보이는 것은 D-04 의 **이유**(54행 "dart analyze 가 통과에서 실패로 바뀔 수 있다")와 D-09 ① 이 변경 종류 대신 결과로 쓰였기 때문이다. 같은 결과 문구가 52행 "에만"(D-02) 과도 충돌한다(WR-04).
  AND-gate: 결함이 드러나는 데는 (1) 결과 기반 문구 AND (2) 새로 켠 규칙에 warning 이상이 있음(riverpod_lint 사실) + `dart analyze` 기본값 이 함께 필요하다. (2) 는 외부 사실이라 수정 지점은 (1) 이다. 결정 당시 (2) 가 미확인(ROADMAP 87행)이어서 1.3.0 이 이 경우에 해당함이 보이지 않았다.
related_findings: |
  - WR-02 (자동 검사 미정의): **같은 뿌리.** 같은 조건의 측정 기준이다. 둘째 조건을 변경 종류로 좁히면 "자동 검사" 는 등급 경계가 아니게 되어 참고 문구로 내려가고, 결과 기준을 유지하면 반드시 정의해야 한다(flutter analyze 기준이면 규칙 추가 전부가 major 가 되어 D-02 가 무너진다).
  - WR-04 (52행 "에만" vs 54행): **같은 뿌리.** D-02 의 major 범위(설정·SDK 만)와 D-04 의 결과 기반 이유 사이의 긴장을 사유 절에서 드러낸 것. 61행은 52행의 범위를, 25행은 54행의 범위를 따른다. 어느 방향을 택해도 52행·54행은 25행과 함께 고쳐야 한다.
  - WR-03 (판정 순서 vs 기준표 세 경우): **별개 결함.** 구조적 원인(D-09 가 D-05 를 행 단위로 옮기지 않음)은 같지만 방향이 반대(40·41·45·47행 누락 → 판정 순서가 너무 좁음)이고 1.3.0 사례와 무관하다. WR-01 의 방향 선택과 독립적으로 고칠 수 있다. 단 README/CHANGELOG 만 고친 변경(47행 patch vs 4번 올리지 않음)은 D-05 를 건드리는 소유자 결정이다.
fix: |
  소유자가 UAT 에서 방향 (나) 변경 종류 기준을 택했고 01-04 gap plan 이 고쳤다 (01-UAT.md G-01-1 `status: resolved`, `resolved_by: 01-04-PLAN.md`).
  `VERSIONING.md` 판정 순서 1번이 기준표의 major 다섯 행을 모두 묻게 되었고, 셋째 조건은 "이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나" 로 좁혔다 — 처음부터 warning 이상인 규칙을 새로 켜는 것은 2번(minor) 이라고 본문에 적었다 (`6b9eec8`). 같은 문구 수정을 `01-CONTEXT.md` D-02 · D-09 ① 에 주석으로 남겼다 (`83f9768`). 같은 뿌리인 WR-01 · WR-02 · WR-04 는 `01-REVIEW-DISPOSITION.md` 에 01-04 로 fixed 처리되었다.
fix_directions: |
  (가) 결과 기준 유지 — 1.3.0 을 재분류. 25행 그대로. 60-62행을 68-71행의 "옛 판정과 지금 정책이 다른 것" 목록으로 옮겨 "당시 minor → 지금 정책이면 major (1번에서 멈춤)" 로 쓰고, 1번이 "아니오" 인 새 minor 사례를 둔다. 52행 "에만" 제거, 43·46행에 심각도 조건 추가(info 면 minor, warning 이상이면 major), 판정 순서 아래에 "자동 검사 = dart analyze 옵션 없이" 정의 추가(WR-02 필수). 바꾸는 결정: D-02(major 범위 확대), D-05(43·46행 수정), D-09 3.(1.3.0 = minor 사례 폐기). D-04·D-09 ① 유지. 가장 큰 변경이며 Phase 3/4 의 riverpod_lint 하한 상향·warning 규칙 추가가 major 로 바뀐다.
  (나) 변경 종류 기준으로 좁힘 — 25행 둘째 조건을 "이미 켜져 있던 규칙의 심각도가 warning 이상으로 올라가나" 로 바꾼다. 61행에 둘째 조건의 답("기존 규칙의 심각도는 바뀌지 않았다. 새로 켜진 riverpod_lint 규칙 중 warning 등급이 있지만 새로 켠 규칙은 2번에서 다룬다")을 덧붙인다. 52행 "에만" 을 "설정 파일·SDK 를 고쳐야 하거나 기존 규칙의 심각도가 warning 이상으로 올라가는 변경" 으로, 54행의 이유를 변경 종류와 맞게("새로 생기는 경고 표에 잡히지 않는 채로 기존 진단이 실패로 바뀐다" 등) 고친다. 바꾸는 결정: D-09 ①(문구), D-02 셋째 문장(문구 — 정책 "규칙 추가 = minor" 는 유지). D-04·D-05·D-09 3. 유지. **가장 작은 변경**이며 결정 원문의 채택 근거(ARCHITECTURE 388행, PITFALLS 539-540행)와 같은 방향이다. WR-02 는 참고 문구로 축소된다.
  (다) 빠진 경우를 기준표에 명시 — 01-02-SUMMARY 308행의 제안대로 D-05 표에 "처음부터 warning 이상인 규칙을 새로 켬 (plugin 첫 활성화 포함)" 행을 추가해 등급을 적고(minor 면 (나) 와 같은 결론, major 면 (가) 와 같은 결론), 25행 둘째 조건을 그 행과 42행을 가리키는 문구로 바꾸고, 61행에 그 행에 따른 답을 덧붙인다. 바꾸는 결정: D-05(행 추가), D-09 ①(문구). 등급을 minor 로 적으면 D-02·D-09 3. 유지, major 로 적으면 (가) 와 같이 D-02·D-09 3. 변경. 빈칸을 표에 드러낸다는 점에서 (나) 보다 설명이 명확하지만 변경은 더 크다.
verification: "01-04 실행 뒤 Phase 1 검증(01-VERIFICATION.md)이 G-01-1 을 계산으로 확인했고(1.3.0 minor, 2.0.0 major), 01-UAT.md 의 G-01-1 은 resolved. 2026-10-16 (UTC) 에 `VERSIONING.md` 25행에 셋째 조건(이미 켜져 있던 규칙) 이 있는 것을 다시 확인했다"
files_changed:
  - "VERSIONING.md (6b9eec8)"
  - ".planning/phases/01-baseline-and-toolchain/01-CONTEXT.md (83f9768)"
files_involved:
  - "VERSIONING.md:25 — 판정 순서 1번 둘째 조건이 결과 기반이라 기준표 42행보다 넓다 (1차 결함 지점)"
  - "VERSIONING.md:60-62 — 1.3.0 사례가 25행 둘째 조건을 따지지 않는다 (증상 지점)"
  - "VERSIONING.md:52, 54 — major 범위를 각각 좁게(에만)·넓게(결과) 적어 서로 모순 (WR-04, 같은 뿌리)"
  - "VERSIONING.md:42-43, 46, 93 — 기준표는 변경 종류 기준이고 강도 열은 warning 규칙의 minor 유입을 전제 (의도의 증거)"
  - ".planning/phases/01-baseline-and-toolchain/01-CONTEXT.md:37 (D-02), :40 (D-04), :49-50 (D-05 42·43행), :68 (D-09 ①), :73 (D-09 3.) — 결함의 원천 문구"
specialist_hint: general
