---
phase: "4"
slug: "rule-reselection"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: "2026-10-13"
---

# Phase 4 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.
>
> 출처: `04-01-PLAN.md` ~ `04-12-PLAN.md` 의 `<threat_model>` (계획 단계에서 작성됨 — 04-11 · 04-12 는 gap 수정 계획). ASVS level 1, block on `high`.
> 이 phase 가 바꾼 실행 코드는 로컬 스크립트 둘이다 — `tool/verify.dart` (새 단계 `[3/10]`) 와 새 측정 도구 `tool/measure_rules.dart`. 배포 산출물은 `lib/base.yaml` 하나가 바뀌었다 (켠 규칙 6 → 80, gap 수정 04-12 에서 81). 사용자 입력 · 인증 · 저장 데이터가 없다. 해당 범주는 비공개 사용 프로젝트(`flutter_starter_kit`)의 정보가 공개 저장소로 새는 것, 측정 도구가 저장소 · 원본을 바꾸는 것, 결정 기록의 출처, 원격 쓰기, 공급망이다.
> 아래 "확인" 은 2026-10-13 phase 실행 뒤(HEAD `5f5ff57`) 이 저장소에서 명령을 다시 돌리거나 파일을 직접 읽어 얻은 결과다. 실측 task (04-04 · 04-08) 처럼 비공개 원본이 있어야 도는 확인은 그 plan 의 SUMMARY 에 남은 실행 기록을 근거로 적었다.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| 로컬 저장소 → 공개 원격 (GitHub) | 이 phase 의 모든 파일과 `.planning/` 이 공개 저장소에 올라간다. 04-10 에서 `79f27e5..0db0fdd` (64커밋) 를 올렸다 — 되돌릴 수 없다 (D-07 · D-22) | 문서 · 결과 JSON · 코드 |
| 측정 도구 → 원본 사용 프로젝트 | 원본은 복사의 원본 인자로만 읽는다. 경로는 환경변수와 Bash 명령으로만 전달된다 | 비공개 프로젝트 파일 (읽기) |
| 측정 도구 → 작업 중인 저장소 | 복사본이 `path:` 로 저장소를 받는다 — `pub get` · 분석 · `dart fix` 가 저장소를 바꾸면 회차가 깨진다 | 생성 파일 |
| 측정 도구 → 결과 JSON · 터미널 · `RULES.md` | 회차 기록이 `tool/measurements/` 로 커밋되고 `--summary` · `--report --write` 가 사람과 공개 문서에 옮긴다 | 건수 · 규칙 이름 · 회차 조건 |
| 측정 도구 → 상류 (raw.githubusercontent.com) | tag 고정 URL 에서 `messages.yaml` 을 받아 읽기만 한다 | 공개 YAML |
| CLI 인자 → 측정 도구 | `--source` · `--work` · `--rules` · `--stage` 가 경로와 명령 인자로 쓰인다 | 경로 문자열 |
| Claude 의 권고 → 소유자의 결정 → 배포 파일 | 권고는 입력이고 결정은 사람의 응답이다. 결정만 `lib/base.yaml` · `RULES.md` 에 들어가야 한다 | 결정 기록 |
| 배포 파일 → 사용 프로젝트 | `lib/base.yaml` 의 변경이 `include:` 한 줄로 사용 프로젝트 5개에 닿는다 (`main` 은 이 phase 에서 바뀌지 않았다) | YAML 설정 |
| 상류 pub cache → 검증 명령 (로컬 · GitHub runner) · 측정 도구 | `[3/10]` (b) 와 측정 도구의 `readUpstreamSets` 가 `package_config.json` 이 가리키는 `lints` · `flutter_lints` YAML 을 읽는다 — 형식이 바뀌면 빈 집합이 된다 (04-11 이 0규칙 `FormatException` 으로 막음) | 공개 YAML |
| 커밋된 회차(원자료) → 행(파생값) → `RULES.md` | `--recount` 가 R1 JSON 의 `runs` 에서 행을 다시 세고 `--report --write` 가 문서를 만든다 — 원자료는 바뀌면 안 된다 (04-11) | 건수 · 규칙 이름 |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-04-01 | Tampering | `lib/base.yaml` 의 겹침 삭제가 사용 프로젝트의 진단을 바꾼다 | medium | mitigate | 04-01 Task 1 의 `--update` 가 `바뀐 정답지가 없다`. 확인: 04-01-T1 `<automated>` 를 자기 커밋 `2956e2a` 의 복제본에서 적힌 그대로 rc 0; 지금 상태의 복제본에서 `verify.dart --update` rc 0 · `바뀐 정답지가 없다` · 작업 트리 변경 0 | closed |
| T-04-02 | Repudiation | `RULES.md` 와 `lib/base.yaml` 이 다른 커밋에서 어긋난다 | medium | mitigate | `[3/10]` (c). 확인: `verify.dart` rc 0 · `점검 통과 (10개 중 10개)`; M21 · M22 기록 (`example/README.md`, 04-01-T2 는 M21 기호만 고친 판 rc 0 — `04-01-SUMMARY.md`) | closed |
| T-04-03 | Information disclosure | README 의 M 기록 · SUMMARY 에 절대 경로 · 사용 프로젝트 정보 | high | mitigate | 비공개 점검 (1). 확인: 04-10-T1 의 점검 (1) 0줄; push 범위 전체 점검에서 실제 홈 폴더 경로 · 임시 폴더 경로 0 (아래 T-04-26) | closed |
| T-04-04 | Tampering | 측정 도구가 작업 중인 저장소를 바꾼다 | high | mitigate | 단계마다 지문 비교 (`tool/measure_rules.dart` 3070행, 다르면 `exit(1)`), `--work` 가 저장소 안이면 64. 확인: `--work ./val_probe_work` → rc 64, 폴더 만들지 않음; 실측 세 실행 모두 지문 불변 (`04-04-SUMMARY.md`) | closed |
| T-04-05 | Tampering | 측정 도구가 원본 사용 프로젝트를 바꾼다 | high | mitigate | 원본은 `copySync` 의 원본 인자로만, 복원은 `<work>/pristine/` 에서. 확인: 원본 `git status --porcelain` 이 실측 전후 0줄 (`04-04-SUMMARY.md`, 04-08 재측정도 같음) | closed |
| T-04-06 | Information disclosure | 결과 JSON · 화면 · 예외에 사용 프로젝트의 경로 · 메시지 | high | mitigate | JSON 구조에 메시지 · 경로 필드 없음, 예외는 `scrub` (`main` 4852행 → `scrubPaths`). 확인: `tool/measurements/*.json` 의 `"message"` 0; `--report` · `--summary` 여덟 묶음 · `--audit` 출력의 절대 경로 꼴 0 | closed |
| T-04-07 | Tampering | 받은 `messages.yaml` 이 바뀌어 상태가 틀린다 | low | mitigate | tag 고정 URL (`sdkTag = '3.13.4'`, 50행), 읽기만, `LinterLintCode:` 없으면 `FormatException` (2763행) | closed |
| T-04-08 | Elevation of privilege | `--source` · `--work` · `--rules` · `--stage` 가 검증 없이 쓰인다 | medium | mitigate | 확인: `--stage bogus` → rc 64, `--rules not_a_rule_zz` → rc 64, `--summary` 의 모르는 묶음 → rc 64 (허용 목록 출력); 앞의 둘은 `--work` 로 준 폴더를 만들지 않음 | closed |
| T-04-09 | Information disclosure | `--summary` · `--report` 출력이 경로 · 메시지를 옮긴다 | high | mitigate | 출력은 건수 · 규칙 이름 · 회차 조건만 읽는다. 확인: T-04-06 과 같은 출력 점검 0 | closed |
| T-04-10 | Repudiation | `valid` 가 아닌 회차의 수치가 표에 들어간다 | medium | mitigate | `--report` 단언 (5). 확인: `--report` rc 0; R1 JSON 회차 52개 모두 `valid: true`, 행 133개가 참조하는 회차 모두 유효, `invalidRuns` 가 있는 행 0 | closed |
| T-04-11 | Information disclosure | 커밋되는 JSON · SUMMARY · 커밋 메시지에 사용 프로젝트 정보 | high | mitigate | 경로는 환경변수로만, 커밋 전 점검 (1) ~ (4). 확인: 04-04-T3 은 (3b) 범위만 바꾼 판 rc 0 (`04-04-SUMMARY.md`); 지금 점검 (1) 0 · (2) `LEAK?` 없음 · (3) `"message"` 0 | closed |
| T-04-12 | Tampering | 실측 중 저장소에 파일이 생기거나 원본이 바뀐다 | medium | mitigate | T-04-04 · T-04-05 와 같은 장치. 확인: 같은 기록 | closed |
| T-04-13 | Denial of service | 실측이 Bash 10분 제한에 끊긴다 | medium | mitigate | 백그라운드 실행 · 단계별 저장 · `--stage` 로 이어 돌리기. 확인: R1 JSON 이 회차 52개를 담고 모두 유효 (끊긴 회차는 다시 돌려 `valid: false` 가 남지 않음) | closed |
| T-04-14 | Repudiation | 결정의 출처를 따라갈 수 없다 / 권고가 결정으로 둔갑한다 | high | mitigate | `04-DECISIONS.md` 의 `권고` 칸(패널 표)과 `결정` 칸(`## 결정` 표, `\| 규칙 \| 묶음 \| 권고 \| 결정 \| 사유 \|`)이 나뉨; 초안 `0362628` 과 결정 `cd02f89` · `e42e984` · `479ad21` 이 다른 커밋. 소유자가 사유를 따로 쓰지 않은 행은 `권고 이유 승인 — …` 로 적었다 | closed |
| T-04-15 | Information disclosure | 패널 · 결정 표 · SUMMARY 에 사용 프로젝트 정보 | high | mitigate | 패널은 `--summary` 출력만 옮김. 확인: 단계 폴더 전체에 점검 (1) 0줄 · (2) `LEAK?` 없음 | closed |
| T-04-16 | Tampering | 묶음 커밋의 정답지 변화가 결정과 1:1 이 아니다 | medium | mitigate | 묶음 커밋의 python 단언. 확인: 04-06 의 세 단언은 적힌 그대로 rc 1 (단언 결함 ① ~ ④ — `04-VALIDATION.md` 감사 기록), 고친 판 rc 0 (`04-06-SUMMARY.md`); 지금 `verify.dart` 의 정답지 다섯 모두 통과 | closed |
| T-04-17 | Repudiation | `RULES.md` · `lib/base.yaml` · CHANGELOG 가 어긋난다 / 켠 이유 ≠ 사유 주석 | medium | mitigate | 확인: `[3/10]` 통과; python 대조로 켠 규칙 80 = `base.yaml` 80 (같은 집합), 켠 이유 ↔ 사유 주석 불일치 0; `grep -c '성능 향상' lib/base.yaml` 0 | closed |
| T-04-18 | Tampering | `prefer_final_locals` 를 빼면 `fixtures/overrides` 의 끄기 시연이 거짓이 된다 | medium | mitigate | 확인: `lib/base.yaml` 에 `prefer_final_locals` 1줄, `fixtures/overrides/analysis_options.yaml` 에 `prefer_final_locals: false` 1줄; `[10/10] overrides (끄는 설정)` 통과 | closed |
| T-04-19 | Denial of service | `strict-inference` 의 warning 이 사용 프로젝트의 `dart analyze` 를 막는다 | high | mitigate | 소유자가 실측(`test` 106줄, warning)을 보고 `안 켬` 으로 결정 (04-05). 확인: `lib/base.yaml` 에 `strict-inference` 0 — 위협이 생기지 않았다 | closed |
| T-04-20 | Tampering | 묶음 커밋의 정답지 변화가 결정과 1:1 이 아니다 (반영 B) | medium | mitigate | 확인: 04-07-T1 · T2 는 적힌 그대로 rc 1 (`relative_imports_rule.dart` 의 `diff -rq` 만), 고친 판 rc 0 (`04-07-SUMMARY.md`); 04-07-T3 은 자기 커밋 `ba58060` 에서 적힌 그대로 rc 0 | closed |
| T-04-21 | Repudiation | 켜지 않은 규칙의 사유가 빠지거나 접두사가 없다 | medium | mitigate | 확인: `--audit` rc 0 · `감사 통과 — 켠 80 · 옵션 0 · 켜지 않음 91 · 보류 0` | closed |
| T-04-22 | Repudiation | 재측정의 기준선이 없어 `UI` 값의 뜻을 따라갈 수 없다 | medium | mitigate | 확인: R1 JSON 의 회차에 `UI-base` 와 `UI` 가 함께 있고 둘 다 유효 | closed |
| T-04-23 | Information disclosure | `unnecessaryIgnoreNames` 에 주석 원문이 들어간다 | high | mitigate | 코드 이름만 센다. 확인: 04-08-T2 `<automated>` (키에 `/` · 공백 없음 단언 포함) 적힌 그대로 rc 0 (HEAD = `9a5176b`, `04-08-SUMMARY.md`); 지금 `"message"` 0 | closed |
| T-04-24 | Repudiation | CHANGELOG 표의 수치가 `RULES.md` · JSON 과 어긋난다 | medium | mitigate | 확인: 04-09-T1 의 python 단언은 평가표 정규식만 고친 판 rc 0 (`04-09-SUMMARY.md`); `RULES.md` 실측 기록은 `--report --write` 가 생성 (생성 절 표식) | closed |
| T-04-25 | Information disclosure | 마무리 문서에 절대 경로 · 사용 프로젝트 정보 | high | mitigate | 확인: 04-09-T2 를 자기 커밋 `2b2b475` 에서 적힌 그대로 rc 0 (점검 포함); 지금 단계 폴더 점검 (1) 0 | closed |
| T-04-26 | Information disclosure | 비공개 정보가 든 커밋이 공개 저장소에 올라간다 | critical | mitigate | 04-10 Task 1 의 점검 (1) ~ (3) + 소유자 확인. 확인: (3b) 계획 문서 자기 패턴만 뺀 판 rc 0; orchestrator 가 push 범위 **전체**(계획 범위 밖 포함)를 더 점검해 `03-04-SUMMARY.md` 1줄(홈 폴더 경로 접두어 · 소유자 이메일 앞부분)을 찾았고, 소유자 결정으로 `0db0fdd` 에서 말로 고친 뒤 올렸다 — 올린 범위의 추가된 줄에서 실제 홈 폴더 경로 · 임시 폴더 경로 · 이메일 · 토큰 값 0. 옛 커밋 `f1b4ed9` 의 변경 내역에는 남는다 (홈 폴더 접두어는 이미 원격의 Phase 1 문서 11개에 있었고, 이메일 앞부분만으로는 주소가 드러나지 않는다 — 기록을 다시 쓰지 않기로 한 소유자 결정) | closed |
| T-04-27 | Tampering | `main` · tag 를 건드리거나 덮어쓰는 push | high | mitigate | 확인: push 는 `git push origin gsd/v2.0-package-rework` 한 번 (fast-forward); 지금 원격 head 둘 — `main` `90a2736`, 작업 브랜치 `0db0fdd`; tag `v1.3.0` 하나; PR 0 | closed |
| T-04-28 | Denial of service | `[3/10]` 이 runner 에서 상류 YAML 을 못 읽어 CI 가 빨갛다 | medium | mitigate | 확인: run 38351171683 `completed success`, 로그에 `[3/10] 배포 파일의 구성 ... 통과`, job 210초 (`timeout-minutes: 10` 안) — 위협이 생기지 않아 둘째 push 없음; `.github/workflows/verify.yml` 은 `79f27e5` 와 같다 | closed |
| T-04-29 | Tampering | `--recount --write` 가 회차(`runs`)나 다른 행의 값을 바꾼다 | high | mitigate | `recountRows` 는 `counts` · `counts313` · `ignored` · `fixSkipped` 와 `conditions.recount` 만 쓴다. 확인: 지금 R1 JSON 의 `runs` 가 `bcc8c91` 과 `jq -S` diff 0; 04-11-T1 `<automated>` (다른 조건 · 다른 칸 · 다른 행의 값을 `bcc8c91` 과 견줌)를 자기 커밋 `b567100` 의 복제본에서 적힌 그대로 rc 0; 지금 `--recount --in …` → `바뀐 행이 없다` | closed |
| T-04-30 | Repudiation | 다시 센 값의 출처를 따라갈 수 없다 (RULES-05) | medium | mitigate | 확인: `conditions.recount` = `{date: 2026-10-13, changedRows: [sort_pub_dependencies]}`, 행의 `fixSkipped` 문자열; `RULES.md` 각주 `dart fix 를 재지 않은 행` 1; CHANGELOG 의 `--recount` 불릿 1; `04-DECISIONS.md` 의 재결정 행 · 머리 문단 · 메모 (04-12) | closed |
| T-04-31 | Information disclosure | 탐침 · README 기록 · SUMMARY 에 절대 경로나 사용 프로젝트 정보 | high | mitigate | 04-11 은 비공개 프로젝트를 돌리지 않았다 (출력 모드만). 확인: `268b823..HEAD` 의 추가된 줄에 실제 홈 폴더 경로 · 임시 폴더 경로 · 이메일 꼴 0; 사용 프로젝트 이름이 든 추가 줄 2개는 기존 문장(요구사항 RULES-03 의 체크 표시, 실측 기록 끝 줄의 덧붙임)이고 경로 · 메시지 · 코드 없음; `.dart_tool/woody_gap_probe/` 없음; R1 JSON `"message"` 0 | closed |
| T-04-32 | Tampering | pubspec 순서 변경이 lock · `pub get` 을 깨거나 fixture 의 다른 진단을 바꾼다 | medium | mitigate | 확인: `268b823..HEAD` 에서 바뀐 `*.lock` 0개; 연습용 프로젝트 여섯의 `pubspec.yaml` diff 는 `flutter_riverpod: ^3.0.0` 줄의 자리 이동뿐 (−6 · +6); 정답지 다섯의 `944ca1c..HEAD` 진단 줄 변화는 각각 `+pubspec.yaml:11  info  sort_pub_dependencies` 하나; `verify.dart` 10/10; 04-12-T1 `<automated>` (헛통과 확인 포함) 자기 커밋 `6d64bee` 복제본에서 rc 0 | closed |
| T-04-33 | Repudiation | `lib/base.yaml` · `RULES.md` · CHANGELOG · `04-DECISIONS.md` 가 다른 값 · 다른 사유를 적는다 | medium | mitigate | 확인: `sort_pub_dependencies` 사유 문장이 `RULES.md` 1 · CHANGELOG 1 에 글자 그대로; python 대조로 켠 규칙 81 = `base.yaml` 81, 켠 이유 ↔ 사유 주석 불일치 0; `--audit` `켠 81 · 옵션 0 · 켜지 않음 90 · 보류 0`; 04-12-T2 `<automated>` (결정 표의 다른 행 == `479ad21`) 자기 커밋 `fb6386a` 복제본에서 rc 0 | closed |
| T-04-34 | Information disclosure | 결정 기록 · README · REQUIREMENTS 에 사용 프로젝트의 경로 · 메시지나 절대 경로 | high | mitigate | 적은 수치는 2줄 · 2곳 같은 건수뿐. 확인: T-04-31 과 같은 범위 점검 0; 04-12-T3 의 비공개 점검 구간은 적힌 그대로 판에서도 통과 (실패 구간은 `REQUIREMENTS.md` 고정 커밋 비교 — `04-VALIDATION.md` 감사 기록) | closed |
| T-04-SC | Tampering | npm/pip/cargo installs (pub 의존성) | high | mitigate | 확인: `git diff 79f27e5..HEAD -- pubspec.yaml` 0줄; 두 스크립트의 실제 import 는 `dart:convert` · `dart:io` 뿐 (`tool/measure_rules.dart` 703행 이후의 `import` 줄은 표식 샘플을 담은 문자열 리터럴 안이다). gap 수정 뒤(04-11 · 04-12): 루트 `pubspec.yaml` 은 `268b823..HEAD` 에서 그대로, 바뀐 `*.lock` 0개, 연습용 프로젝트의 `pubspec.yaml` 은 항목 순서만 바뀜 (항목 · 버전 그대로) | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

No accepted risks.

T-04-26 의 "옛 커밋 `f1b4ed9` 의 변경 내역에 남는 1줄" 은 위협을 받아들인 것이 아니라, 올리기 전에 소유자가 정한 처리 방식(새 커밋으로 고침, 기록은 다시 쓰지 않음)이다 — `04-10-SUMMARY.md` Task 2 에 질문과 답이 있다.

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-10-13 | 29 | 29 | 0 | orchestrator (secure-phase State B, ASVS L1 — 계획 위협 목록, 감사 에이전트 생략) |
| 2026-10-13 (gap 수정 뒤) | 35 | 35 | 0 | orchestrator (secure-phase State A, ASVS L1 — 04-11 · 04-12 의 계획 위협 6개 추가, 감사 에이전트 생략) |

감사 메모 (2026-10-13):

- **실제로 올라간 범위.** `79f27e5..0db0fdd`, 64커밋, 133개 파일 (+66,396 / −213줄). 폴더별 파일 수는 다음과 같다: `.planning/phases` 33 · `.planning/spikes` 24 · `.claude/skills` 17 · `fixtures/` 39 · `example/` 9 · `tool/` 3 · `lib/base.yaml` · `RULES.md` · `CHANGELOG.md` · `.planning/` 의 `PROJECT.md` · `REQUIREMENTS.md` · `ROADMAP.md` · `STATE.md` · `WINDOWS.md`. 계획 문장의 점검 범위(Phase 4 문서 · 도구 · 결과)보다 넓다. 그래서 orchestrator 가 범위 전체의 추가된 줄을 따로 점검했다.
- **추가로 본 것.** 단계 폴더 밖에서 `lib/` · `test/` 꼴 경로 후보를 찾았다. 모두 이 저장소의 표식 파일, 상류 SDK 의 공개 경로, spike 의 합성 프로젝트 경로였다. spike 결과 JSON 의 `"message"` 164개는 spike 020 의 probe 옵션 파일에 대한 SDK 규칙 상태 메시지("… was removed", "isn't a recognized lint rule")다. 사용 프로젝트의 진단이 아니다.
- **gap 수정 실행(04-11 · 04-12)에는 push 가 없다.** 점검 범위는 `268b823..HEAD` (gap 계획 커밋 뒤부터)의 추가된 줄이다. 원격 작업 브랜치는 여전히 `0db0fdd` 다.
- **마무리 커밋은 원격에 없다.** `432c7fe` 와 그 뒤의 검증 문서 커밋들이다. 다음 push 는 D-22 대로 다음 phase 의 첫 push 때 다시 묻는다.

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-10-13 (gap 수정 뒤 다시 확인 — threats_open 0)

## Security Audit 2026-10-13

| Metric | Count |
|---|---|
| Threats found | 29 |
| Closed | 29 |
| Open | 0 |

## Security Audit 2026-10-13

| Metric | Count |
|---|---|
| Threats found | 35 |
| Closed | 35 |
| Open | 0 |
