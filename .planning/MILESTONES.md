# Milestones

## v2.0 Package Rework (Shipped: 2026-10-17)

**Delivered:** 1.3.0 을 다시 다듬은 2.0.0 을 git tag `v2.0.0` 으로 릴리스했다. 켠 규칙 81개마다 근거가 `RULES.md` 에 남고, 문서와 설정의 일치를 `tool/verify.dart` 가 로컬과 CI 에서 지킨다.

**Phases completed:** 6 phases (1 ~ 6), 56 plans, 136 tasks

**Stats:**

- Timeline: 7일 (2026-10-11 → 2026-10-17), 커밋 447개 (`v1.3.0..b3abc46`)
- 코드 변경 (`v1.3.0` → `main` `3418989`, `.planning/` 제외): 파일 227개, +60,121줄 / −138줄
- 배포 파일 `lib/`: YAML 5개 120줄 (1.3.0 은 `lib/analysis_options.yaml` 하나)
- 저장소 도구: `tool/verify.dart` 3,223줄 · `tool/smoke.dart` 1,143줄 · `tool/measure_rules.dart` 5,188줄 (Dart, 받는 쪽에 가지 않음)
- 릴리스: tag `v1.3.0` (`90a2736`, 기준점) · `v2.0.0` (`704bf56`), `main` 병합 PR #1 · #2 · #3 (merge commit)

**Key accomplishments:**

1. **기준점과 버전 정책 (Phase 1)** — 1.3.0 에 tag `v1.3.0` 을 달아 옛 SDK 프로젝트가 머물 자리를 만들고, 저장소 SDK 를 Flutter 3.47.5 (Dart 3.13.4) 로 올렸다. 버전 등급 판정과 CHANGELOG 형식을 `VERSIONING.md` 한 파일에 정했다
2. **검증 명령과 CI (Phase 2 · 3)** — `tool/verify.dart` 가 연습용 프로젝트 여섯(`example/` + `fixtures/` 다섯)의 `dart analyze` 결과를 정답지와 줄 · 건수로 견주고, GitHub Actions 가 push · PR · 수동 실행에서 같은 명령을 돈다. 틀린 상태를 일부러 만들어 실패하는 단계를 확인한 기록이 `example/README.md` 에 있다
3. **프리셋 나누기 (Phase 3)** — 조각 `base.yaml` · `riverpod.yaml` · `codegen.yaml`, 묶음 `recommended.yaml`, 옛 주소 별칭 `analysis_options.yaml`. 옛 주소 · 묶음의 진단이 나누기 전과 줄 단위로 같고, 3단 include 에서도 `riverpod_lint` plugin 이 로드된다
4. **규칙 재선정 (Phase 4)** — `flutter_starter_kit` 복사본에서 후보 133개를 실측(회차 R1)하고 소유자가 하나씩 정했다 — 켠 규칙 81개(새로 75개, 모두 info). 켜지 않은 규칙과 사유까지 `RULES.md` 에 있고, 검증 `[3/10]` 이 `lib/base.yaml` · `RULES.md` · README 표시 구역의 일치를 지킨다
5. **문서 (Phase 5)** — README 를 "몇 달 뒤의 내가 그대로 따라 하면 되는" 안내로 다시 쓰고 (설치 · 프리셋 · 끄기 세 층 · 생성 파일 제외 · 버전 올리기), CHANGELOG 1.1.0 ~ 1.2.5 를 git 이력으로 복원했다. README 의 주소 · 버전 · 규칙 목록을 검증이 배포 파일과 견준다
6. **릴리스 (Phase 6)** — 빈 프로젝트가 `ref: v2.0.0` 으로 받아 두 주소 모두에서 규칙 · `riverpod_lint` 진단이 나오는 것을 `tool/smoke.dart` 로 확인한 뒤 tag 를 달고 PR 로 `main` 에 합쳤다. tag · `pubspec.yaml` version · CHANGELOG 최상단이 다르면 CI 가 실패한다

**Closeout:** `override_closeout`

- 감사 `tech_debt` (`.planning/milestones/v2.0-MILESTONE-AUDIT.md`) — 요구사항 43/43 · phase 6/6 · 연결 14/14 · 흐름 7/7, 막는 문제 0, 받는 쪽 영향 0. 소유자가 부채를 기록하고 마감하기로 정했다 (2026-10-17)
- Known verification overrides: Phase 1 ~ 5 의 검증 지문 `stale` — 각 phase 검증 때는 `passed` 였고, 뒤 phase 가 그 phase 의 covered 파일(`CHANGELOG.md` · `VERSIONING.md` · `pubspec.yaml` · `tool/verify.dart` · `README.md` 등)을 고쳐 지문이 낡았다. 소유자 결정으로 다시 돌리지 않았다. Phase 6 은 `passed`
- Open artifact audit: 0 newly acknowledged, 0 carried forward (열린 조사 기록 1건은 마감 전에 resolved 로 정리, `23cd6ca`)
- 마감 때 기록 정리: 닫혔는데 `open` 이던 리뷰 지적 4건(02:WR-02 · WR-03 · WR-08, 03:WR-03)과 장부 `WINDOWS.md` id 1 · 2 를 `fixed` 로 (`585813e`)

**Tech debt carried forward (받는 쪽 영향 0):**

- `VERSIONING.md` 판정 순서 · 기준표 문구 (01:WR-03 · 06 ~ 10, Backlog 999.1 · 999.3) — 다음 릴리스 등급을 매기기 전에
- `.claude/CLAUDE.md` 의 1.3.0 시절 서술 (05:WR-06) — `/gsd-map-codebase` 로 다시 만든다
- `tool/verify.dart` 안내 · 가드 (02:WR-01 · 04 · 05 · 06, 03:WR-04 · 06), workflow action SHA 고정 (03:WR-08), Backlog 999.2
- `tool/measure_rules.dart` 기준선 · 안전장치 (04:CR-03 · WR-01 · 03 · 04 · 07 · 08 · 09) — v2 RULES-13 재측정 전에
- 검증이 `04-DECISIONS.md` · CHANGELOG 표를 `lib/base.yaml` 과 견주지 않음 (cross-phase)
- CI `ubuntu-latest` 가 2026-10-19 부터 Ubuntu 26

**Archives:** `.planning/milestones/v2.0-ROADMAP.md` · `v2.0-REQUIREMENTS.md` · `v2.0-MILESTONE-AUDIT.md` · `v2.0-phases/`

---
