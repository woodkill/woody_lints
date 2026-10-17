---
last_mapped_commit: 8ac96b71e9d394c5d1dfb132814ee87379519c69
last_mapped_at: 2026-10-17
---
# Codebase Structure

**Analysis Date:** 2026-10-17

## Directory Layout

```
woody_lints/
├── lib/                      # 배포 산출물 — 공개 URI 가 되는 YAML 다섯 (Dart 없음)
│   ├── analysis_options.yaml #   옛 주소 별칭 → recommended.yaml
│   ├── recommended.yaml      #   묶음: base + riverpod + codegen
│   ├── base.yaml             #   규칙 전부 + flutter_lints include
│   ├── riverpod.yaml         #   최상위 plugins: riverpod_lint
│   └── codegen.yaml          #   analyzer.errors / analyzer.exclude
├── tool/                     # 저장소 안쪽 도구 (받는 쪽에 안 감)
│   ├── verify.dart           #   검증 명령 [1/10]~[10/10]
│   ├── smoke.dart            #   릴리스 smoke test
│   ├── measure_rules.dart    #   규칙 실측 도구
│   └── measurements/         #   실측 결과 JSON
├── example/                  # 연습용 프로젝트 1 (옛 주소) + 정답지 + 검증 설명서
├── fixtures/                 # 연습용 프로젝트 2~6 (example/lib 복사본 + 다른 include)
│   ├── recommended/          #   묶음 (정답지 없음, example 결과와 대조)
│   ├── base_only/
│   ├── base_riverpod/
│   ├── base_codegen/
│   └── overrides/            #   끄는 설정 + lib/suppress/ 5파일
├── .github/workflows/verify.yml  # CI
├── .claude/                  # 프로젝트 지시 · spike skill (실측 근거)
├── .planning/                # GSD 계획 기록 (코드베이스 아님)
├── analysis_options.yaml     # 저장소 자체 분석 전용
├── pubspec.yaml              # 패키지 매니페스트 (version 2.0.0)
├── README.md                 # 사용법 (한국어)
├── RULES.md                  # 규칙 근거 · 실측 기록
├── VERSIONING.md             # 버전 정책 · 릴리스 절차
├── CHANGELOG.md              # 변경 이력
├── .fvmrc                    # Flutter 3.47.5 고정
├── .vscode/settings.json     # dart.flutterSdkPath → .fvm/versions/3.47.5
└── .gitignore
```

## Directory Purposes

**`lib/`:**
- Purpose: 받는 쪽이 `include` 하는 유일한 배포물
- Contains: YAML 만. `.dart` 가 있으면 `[1/10]` 실패 (`tool/verify.dart:4`)
- Key files: `lib/base.yaml` (규칙 95행), `lib/recommended.yaml`, `lib/analysis_options.yaml`

**`tool/`:**
- Purpose: 검증 · 릴리스 확인 · 실측 스크립트. 각각 단일 파일 — 공유 Dart 모듈을 두지 않는다 (`tool/measure_rules.dart:39-41`)
- Contains: `tool/verify.dart` (3223행), `tool/smoke.dart` (1143행), `tool/measure_rules.dart` (5188행), `tool/measurements/2026-10-13-R1.json`
- 의존성: 루트 `pubspec.yaml` 의 `dev_dependencies` (`yaml`, `markdown`)

**`example/`:**
- Purpose: 옛 주소 한 줄을 받는 연습용 Flutter 프로젝트 — 일부러 규칙을 어긴 샘플
- Contains: `example/lib/*_rules.dart` 샘플, `example/lib/should_not_appear.dart`, `example/lib/generated/sample.{g,freezed}.dart`, `example/expected_diagnostics.txt` (93줄), `example/pubspec.yaml` (`woody_lints: path: ..`), 커밋된 `example/pubspec.lock`
- Key files: `example/README.md` — 검증 단계 · 종료 코드 · 지워 보기 기록(M 번호) 의 설명서

**`fixtures/`:**
- Purpose: 같은 샘플을 다른 프리셋 조합으로 받는 연습용 프로젝트 다섯
- Contains: 폴더마다 `analysis_options.yaml`, `pubspec.yaml` (`path: ../..`), 커밋된 `pubspec.lock`, `lib/` (example 복사본), `expected_diagnostics.txt` (recommended 제외)
- Key files: `fixtures/overrides/analysis_options.yaml`, `fixtures/overrides/lib/suppress/`

**`.claude/skills/spike-findings-woody-lints/`:**
- Purpose: spike 001~023 실측 결과와 구현 설계도. 검증 · fixture · CI · 프리셋 구조를 바꾸기 전에 읽는다
- Key files: `.claude/skills/spike-findings-woody-lints/SKILL.md`, `.claude/skills/spike-findings-woody-lints/references/preset-split-structure.md`, `.claude/skills/spike-findings-woody-lints/references/ci-workflow.md`

## Key File Locations

**Entry Points:**
- `lib/recommended.yaml`: 새 프로젝트용 공개 주소
- `lib/analysis_options.yaml`: 옛 주소 (뜻 유지)
- `tool/verify.dart`: 검증 명령 (`fvm dart run tool/verify.dart`)
- `tool/smoke.dart`: 릴리스 확인 (`fvm dart run tool/smoke.dart <ref>`)

**Configuration:**
- `pubspec.yaml`: 이름 · 버전 · SDK `^3.13.0` · 의존성
- `analysis_options.yaml`: 루트 분석 (`flutter_lints` 만, `example/**` · `fixtures/**` exclude)
- `.fvmrc`, `.vscode/settings.json`: SDK 고정 (둘을 함께 바꾼다)
- `.github/workflows/verify.yml`: CI

**Core Logic:**
- `lib/base.yaml`: 규칙 목록
- `tool/verify.dart` 의 `const fixtures`: 연습용 프로젝트 정의

**Testing:**
- `example/expected_diagnostics.txt`, `fixtures/*/expected_diagnostics.txt`: 정답지
- `example/README.md`: 검증 설명서

## Naming Conventions

**Files:**
- 프리셋: 소문자 한 단어 `.yaml` (`lib/base.yaml`, `lib/codegen.yaml`); 파일 이름 = 공개 URI
- 문서: 대문자 `.md` (`RULES.md`, `VERSIONING.md`)
- 도구: snake_case 동사/명사 `.dart` (`tool/measure_rules.dart`)
- 연습용 샘플: `<분류>_rules.dart` / `<규칙>_rule.dart` (`example/lib/style_rules.dart`, `example/lib/final_parameters_rule.dart`)
- 정답지: 고정 이름 `expected_diagnostics.txt`
- 실측 결과: `<YYYY-MM-DD>-<run id>.json` (`tool/measurements/2026-10-13-R1.json`)

**Directories:**
- 연습용 프로젝트: 프리셋 조합을 snake_case 로 (`fixtures/base_riverpod/`)

## Where to Add New Code

**새 규칙:**
- Primary code: `lib/base.yaml` 의 해당 분류 주석 아래, 줄 끝 한국어 이유 주석
- 같은 커밋: `RULES.md` 켠 규칙 표, `README.md` 의 `woody:readme-rules` 구역, `CHANGELOG.md` (VERSIONING 기준 minor, "새로 생기는 경고" 칸)
- Tests: `example/lib/` 의 분류 샘플 파일에 위반 한 건 → `fixtures/*/lib/` 같은 파일에 복사 → `fvm dart run tool/verify.dart --update` 로 정답지 갱신 후 `git diff` 확인

**새 프리셋 조각:**
- Implementation: `lib/` 바로 아래 새 YAML (공개 URI 가 됨, minor). 조각끼리 include 하지 않고 필요하면 `lib/recommended.yaml` 의 include 목록에 더한다
- 검증: `tool/verify.dart` 의 허용 최상위 키 목록 · `const fixtures` 에 행 추가, 새 폴더를 `fixtures/` 아래에 example 복사본으로 (lock 커밋, `.gitignore:11` 이 `fixtures/*/pubspec.lock` 을 허용)

**새 연습용 샘플 파일:**
- `example/lib/` 에 만들고 다섯 `fixtures/*/lib/` 에 글자 그대로 복사 (`example/lib/relative_imports_rule.dart` 3행만 예외)

**도구 변경:**
- 해당 `tool/*.dart` 파일 안에. 새 공유 Dart 파일을 `tool/` 에 두지 않는다. 지워 보기 기록은 `example/README.md` 「검증이 실제로 잡아내는지 확인한 기록」 에 더한다

## Special Directories

**`.dart_tool/woody_verify/`:**
- Purpose: 연습용 프로젝트별 Analysis Server 상태 폴더 (plugin 컴파일 캐시)
- Generated: Yes
- Committed: No (`.gitignore:3`)

**`build/woody_rule_check/`:**
- Purpose: `[2/10]` 조각 복사본 (실행 후 삭제)
- Generated: Yes
- Committed: No (`.gitignore:20`)

**`.fvm/`:**
- Purpose: FVM SDK 캐시
- Generated: Yes
- Committed: No (`.gitignore:16`)

**`example/pubspec.lock`, `fixtures/*/pubspec.lock`:**
- Purpose: 로컬 · CI 가 같은 패키지 버전으로 판정. 릴리스 때 `pub get` 으로만 다시 받는다 (`VERSIONING.md` 릴리스 절차 2)
- Generated: Yes
- Committed: Yes (`.gitignore:9-11`). 루트 `pubspec.lock` 은 커밋하지 않는다 (`.gitignore:7`)

**`.planning/`:**
- Purpose: GSD 계획 기록 (milestone 보관 포함)
- Generated: No
- Committed: Yes

---

*Structure analysis: 2026-10-17*
