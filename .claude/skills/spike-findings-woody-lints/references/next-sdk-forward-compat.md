# 다음 SDK (Dart 3.14 베타) 에서 달라지는 것과 SDK 를 올릴 때

Phase 3 이 지을 구조(조각 셋 · 묶음 · 옛 주소의 별칭)와 지금의 한 파일 구조(1.3.0)를 **다음 SDK 의 베타**에서 미리 돌려 본 결과다. 무엇이 그대로이고 무엇이 달라지는지, 그래서 Phase 3 의 주석 · Phase 5 의 README 가 무엇을 단정하면 안 되는지, 저장소 고정 SDK 를 Dart 3.14 계열로 올릴 때 무엇을 먼저 돌리는지를 다룬다.

**이 문서의 "베타" 는 빌드 하나다** — Flutter `3.49.0-0.2.pre` / Dart `3.14.0-211.1.beta` (framework revision `38ec981bad`, 2026-09-30). "고정 SDK" 는 Flutter 3.47.5 / Dart 3.13.4 다. 같은 스크립트를 두 SDK 로 각각 돌려 칸마다 견줬고, 고정 SDK 의 실행이 기준이다. macOS arm64, 2026-10-12 실측. plugin 쪽에서 풀린 버전은 두 SDK 에서 같았다 — `riverpod_lint` 3.1.9 / `analyzer` 14.5.0 / `analysis_server_plugin` 0.3.24.

베타의 동작은 정식 버전에서 달라질 수 있고, 이 패키지가 고칠 수 있는 것이 아니다. 아래에서 "달라졌다" 고 적은 것 가운데 생성 파일 제외는 Dart 팀이 되돌리려는 중이다 (→ Constraints).

이 문서에서 "N번" 은 아래의 절 번호다. "성공 기준 3 · 4" 는 ROADMAP.md Phase 3 의 것이다. "지금의 저장소" 는 2026-10-12 의, 프리셋을 나누기 전의 저장소다.

실험의 칸은 번호가 아니라 id 로 부른다. id 의 모양은 스크립트에 따라 다르다.

- `probe.dart` 의 칸은 붙임표가 있는 이름이다 — `U-old`, `S-alias`, `K-base`, `X-none` … 예외가 루트 분석의 두 칸 `R1` · `R2` 다. `R1` 은 "한 파일 구조 + `example/` + 루트에 `example/**` 만 제외", `R2` 는 "나눈 구조 + `example/` + 루트에 `example/**` 만 제외" 에서의 루트 분석이다.
- `root_probe.dart` 의 경우는 글자 하나에 숫자다 — `E0`, `U1`, `S1`, `X1`, `T0` … `R2` 는 `T1` 과 같은 구성이다. `R1` 과 똑같은 구성의 경우는 없고 `example/` 이 없는 `U1` 이 가장 가깝다.
- `X-none` 과 `X3`, `U-old` 와 `U1`, `S-alias` 와 `S1` 은 글자만 같고 다른 실험이다.

**두 스크립트의 replica 에는 저장소 루트의 Dart 파일이 없다.** `lib/` 에는 YAML 만 있고 `tool/verify.dart` 는 복사하지 않았다. 아래에서 루트 분석이 "0줄" 이라고 적은 것은 그 replica 의 값이다 (→ 4번).

## Requirements

MANIFEST.md 의 `next-sdk-forward-compat` 의 것.

소유자가 확정한 것 (2026-10-12, `/gsd-spike` 의 후보 선택).

- 베타 SDK 는 fvm 캐시(`~/fvm/versions`)에만 설치한다. `.fvmrc`, `.vscode/settings.json`, 저장소의 파일은 바꾸지 않는다
- GitHub 에는 아무것도 올리지 않는다

spike 가 스스로 건 조건.

- 같은 스크립트를 저장소 고정 SDK (Dart 3.13.4) 와 베타에서 각각 돌려 견준다. 고정 SDK 의 실행이 기준이다
- 베타의 `dart` 는 저장소 밖을 작업 디렉터리로 두고 스크립트의 절대 경로를 주어 띄운다 — 저장소 루트에서 `dart run` 을 하면 베타가 루트의 패키지를 다시 풀 수 있다
- 스크립트는 Dart 이고 `dart:io`, `dart:convert` 만 쓴다. 진단은 정답지 형식 `상대경로:줄  강도  규칙이름` 으로 견준다

spike 에서 나와 실제 구현과 문서가 지켜야 하는 것 (베타 `3.14.0-211.1.beta` 한 빌드의 결과이고 정식 버전에서 달라질 수 있다).

- 구조(조각 셋 · 묶음 · 별칭)는 바꾸지 않는다. include 로 받는 `plugins:` 는 베타에서도 한 파일 구조 · 3단 별칭 · 묶음 · 조각 조합에서 모두 로드되고 진단의 내용이 같다 (016)
- "`codegen.yaml` 을 받으면 생성 파일의 진단이 보고되지 않는다" 는 Dart 3.13.x 의 사실로 적는다. 베타에서는 이 패키지가 주는 제외가 규칙 진단에도 통하지 않아 정답지 셋(옛 주소 · 묶음 16줄 → 20줄, 기본 + codegen 13줄 → 17줄)에 생성 파일 샘플의 4줄이 생긴다. 한 파일 구조(1.3.0)도 같다 (016)
- README 는 생성 파일 제외를 **사용 프로젝트의 옵션 파일에 직접** 적으라고 안내한다 — 두 SDK 에서 규칙과 plugin 을 모두 막는 방법은 이것 하나다. "프리셋의 제외가 통하지 않는다" 를 굳은 사실로 적지 않고 SDK 버전에 따라 다르다고 적는다. 상류가 `P1` 버그(sdk#64549)로 다루며 되돌리는 변경을 리뷰하고 있다 (2026-10-11) (016)
- 루트 옵션 파일의 주석과 문서에 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다. 베타에서는 `lib/analysis_options.yaml` 이 `plugins:` 에 닿는 한 루트 분석이 plugin 을 준비하고(0.5초 → 10초, 진단은 0줄) 루트의 제외로 막지 못한다. `plugins_in_inner_options` 는 베타에서 나오지 않는다 (016)
- 연습용 프로젝트 폴더를 루트에서 제외하는 방식은 베타에서도 통한다 — 제외한 폴더는 plugin 을 준비시키지 않는다 (016)
- 지금 규칙 12개는 베타에서 deprecated / removed 가 아니다 (pubspec 의 SDK 하한을 `^3.14.0` · `^3.99.0` 으로 올려도 0건) (016)
- plugin 진단 확인은 베타에서도 `dart analyze` 로 한다. 베타의 `flutter analyze` 는 plugin 진단을 내지만 규칙 진단을 겹쳐 세고 그 수가 실행마다 달랐다 (016)
- 고정 SDK 를 Dart 3.14 계열로 올리기 전에 016 의 두 스크립트를 그 SDK 로 돌린다. `probe.dart` 의 `≠` 10칸 중 생성 파일 제외에서 온 8칸이 `=` 로 돌아오면 되돌리는 변경이 들어간 것이고 (루트 분석의 2칸 R1 · R2 는 다른 변경(sdk#63627)에서 온 것이라 `≠` 로 남을 것이다), 10칸 그대로면 정답지 셋을 갱신하며 "SDK 가 바뀌어 생긴 줄" 로 기록한다 (016)

판정은 PARTIAL 이다 — 재려던 세 가지가 모두 확정됐고, 둘은 지금과 같고 하나(생성 파일 제외)가 달라졌다. 구조를 바꿔야 한다는 결과는 나오지 않았다 (멈춤 조건에 해당하지 않는다).

## How to Build It

### 1. 한눈에 — 그대로인 것과 달라진 것

| 무엇 | 고정 SDK (Dart 3.13.4) | 베타 (Dart 3.14.0-211.1.beta) | 어디에 |
|---|---|---|---|
| include 로 받는 `plugins:` 의 로드 | 로드됨 | **같음** | 2번 |
| 규칙 진단 · plugin 진단의 내용, 강도, 줄 번호 | — | **같음** (생성 파일 4줄만 다르다) | 2번, 3번 |
| 프리셋이 주는 생성 파일 제외 — 규칙 진단 | 통한다 | **통하지 않는다** | 3번 |
| 프리셋이 주는 생성 파일 제외 — plugin 진단 | 통하지 않는다 | 통하지 않는다 (같음) | 3번 |
| 사용 프로젝트가 직접 적은 제외 | 둘 다 막는다 | 둘 다 막는다 (같음) | 3번 |
| 저장소 루트의 분석 (한 파일 구조 · 나눈 구조의 replica — `tool/` 없음) | 0줄, plugin 준비 없음, 0.5초 | 0줄, **plugin 을 준비한다, 10초** | 4번 |
| `plugins_in_inner_options` | 한 파일 구조에서 루트의 제외를 걷어내면 1건 | **나오지 않는다** | 4번 |
| 연습용 프로젝트 폴더의 루트 제외 | 통한다 | 통한다 (같음) | 4번 |
| 지금 규칙 12개의 상태, 규칙 검사의 형태 | 0건, 0.5초, plugin 준비 없음 | **같음** | 5번 |
| `flutter analyze` 의 plugin 진단 | 내지 않는다 | 내지만 규칙 진단을 겹쳐 센다 | 6번 |

### 2. include 로 받는 `plugins:` — 그대로다

`example/` 의 샘플을 옵션 파일만 바꿔 가며 분석했다 (프로젝트 폴더를 작업 디렉터리로, 인자 없이, `--suppress-analytics`, 실행마다 전용 상태 폴더 — analyze-run-and-verdict.md 의 형태 그대로).

| id | 구조 · 옵션 | 고정 SDK | 베타 |
|---|---|---|---|
| U-old | 한 파일 구조 (1.3.0), 옛 주소 | plugin 폴더 1, plugin 진단 3줄 | 같음 |
| S-alias | 나눈 구조, 옛 주소 (3단) | plugin 폴더 1, plugin 진단 3줄 | 같음 |
| S-bundle | 나눈 구조, 묶음 주소 | plugin 폴더 1, plugin 진단 3줄 | 같음 |
| S-base-riverpod | `base.yaml` + `riverpod.yaml` | 21줄, `exit 2` | **한 줄도 다르지 않음** |
| S-base-only | `base.yaml` 만 | 18줄, `exit 2`, plugin 폴더 0 | **한 줄도 다르지 않음** |

- 이름이 `analysis_options.yaml` 이 아닌 조각의 `plugins:` 가 베타에서도 3단 include 를 거쳐 로드된다. 처음 실행은 14.8 ~ 16.7초로 고정 SDK 와 같다.
- plugin 준비를 따로 본 여섯 칸(위의 다섯과 S-base-codegen)이 베타에서 모두 기준과 같았다 — plugin 을 쓰는 칸은 폴더 1개 · `plugin.aot` 있음 · 실패 머리말 없음, 쓰지 않는 칸은 폴더 0개다.
- **그래서 구조는 그대로 간다.** 조각 셋 · 묶음 · 별칭의 설계를 바꿀 이유가 나오지 않았다 (→ preset-split-structure.md).

### 3. 생성 파일 제외 — 규칙 진단에도 통하지 않는다

`example/` 의 샘플을 그대로 분석한 결과.

| id | 옵션 | 고정 SDK | 베타 |
|---|---|---|---|
| U-old | 한 파일 구조, 옛 주소 | `exit 2` · 16줄 (정답지와 같음) | `exit 2` · **20줄** |
| S-alias | 나눈 구조, 옛 주소 | `exit 2` · 16줄 | `exit 2` · **20줄** |
| S-bundle | 나눈 구조, 묶음 주소 | `exit 2` · 16줄 | `exit 2` · **20줄** |
| S-base-codegen | `base.yaml` + `codegen.yaml` | `exit 0` · 13줄 | `exit 0` · **17줄** |

더해진 4줄은 네 경우 모두 같다. 전부 info 라 `exit` 줄은 바뀌지 않는다.

```text
+ lib/generated/sample.freezed.dart:4  info  avoid_print
+ lib/generated/sample.freezed.dart:4  info  prefer_single_quotes
+ lib/generated/sample.g.dart:4  info  avoid_print
+ lib/generated/sample.g.dart:4  info  prefer_single_quotes
```

"어디에 적은 제외가 통하는가" 는 생성 파일 샘플 `lib/generated/riverpod_violation.g.dart` (한 줄에 규칙 위반과 plugin 위반 — spike 012 · 015 의 것)로 봤다.

| id | `**/*.g.dart` 제외를 적은 곳 | 고정 SDK: 규칙 | 고정 SDK: plugin | 베타: 규칙 | 베타: plugin |
|---|---|---|---|---|---|
| X-none | 없음 | 나옴 | 나옴 | 나옴 | 나옴 |
| X-bundle | 패키지의 `codegen.yaml` (묶음으로 받음) | 안 나옴 | 나옴 | **나옴** | 나옴 |
| X-old | 패키지의 한 파일 구조 (1.3.0 의 모양) | 안 나옴 | 나옴 | **나옴** | 나옴 |
| X-own | 사용 프로젝트의 옵션 파일에 직접 | 안 나옴 | 안 나옴 | 안 나옴 | 안 나옴 |
| X-local-root | 사용 프로젝트 **루트**의 `local_excludes.yaml` (include 로 부름) | 안 나옴 | 안 나옴 | 안 나옴 | 안 나옴 |
| X-local-sub | 사용 프로젝트의 `config/local_excludes.yaml` (include 로 부름) | 안 나옴 | 나옴 | **나옴** | 나옴 |

- **베타에서는 규칙 쪽도 plugin 쪽과 같은 기준을 쓴다** — 제외 패턴을 "그 패턴을 적은 파일의 폴더" 에서부터 찾는다. X-local-root 와 X-local-sub 는 같은 내용의 파일을 폴더만 달리 둔 것이고, 베타에서는 규칙 진단도 갈렸다. 고정 SDK 에서 규칙과 plugin 이 어긋나던 것(012)이 베타에서는 "둘 다 통하지 않는다" 로 맞춰졌다.
- 그래서 패키지 안에 적힌 `**/*.g.dart` · `**/*.freezed.dart` 는 사용 프로젝트의 파일에 맞지 않는다. **나눠서 생기는 일이 아니다** — 한 파일 구조(1.3.0)도 같다 (U-old, X-old).
- 두 SDK 에서 규칙과 plugin 을 모두 막은 것은 X-own 과 X-local-root **둘**이다. 둘의 공통점은 패턴을 적은 파일이 **사용 프로젝트의 루트 폴더**에 있다는 것이다. 요구 사항의 "방법은 이것 하나" 는 README 가 안내할 방법을 X-own (자기 `analysis_options.yaml` 에 직접) 하나로 한다는 뜻이지, 통하는 자리가 하나뿐이라는 뜻이 아니다.
- **축이 둘이다.** 규칙 진단 쪽은 SDK 에 든 analyzer 를 따르고, plugin 진단 쪽은 분석할 때마다 pub.dev 에서 풀리는 `analyzer` 를 따른다 (두 SDK 에서 모두 14.5.0 이었다). 위 표에서 SDK 를 바꿔 달라진 것은 규칙 쪽 칸뿐이다. plugin 쪽 칸은 SDK 가 아니라 pub.dev 의 `analyzer` 릴리스로 바뀔 수 있다 — 되돌리는 변경이 그쪽으로 나오면 저장소도 `.fvmrc` 도 그대로인데 "plugin: 나옴" 이 "안 나옴" 이 될 수 있다 (추정. 그런 빌드는 2026-10-12 에 없었다). 생성 파일의 plugin 진단을 정답지에 고정하면 그날 그 줄이 "빠진 줄" 로 드러난다.

정답지에서 달라지는 것.

| 연습용 프로젝트 (fixtures-after-split.md 의 이름) | codegen 조각 | 고정 SDK | 베타 | 잰 칸 |
|---|---|---|---|---|
| `example` (옛 주소) | 받음 | `exit 2` · 16줄 | `exit 2` · 20줄 | S-alias |
| `recommended` (묶음) — `example/` 의 정답지를 함께 쓴다 | 받음 | `exit 2` · 16줄 | `exit 2` · 20줄 | S-bundle |
| `base_codegen` | 받음 | `exit 0` · 13줄 | `exit 0` · 17줄 | S-base-codegen |
| `base_only` | 안 받음 | `exit 2` · 18줄 | 그대로 | S-base-only |
| `base_riverpod` | 안 받음 | `exit 2` · 21줄 | 그대로 | S-base-riverpod |
| `overrides` (묶음 + 끄는 설정) | 받음 | — | **재지 않았다** | — |

- `base_only` 와 `base_riverpod` 는 원래 그 4줄을 담고 있어 그대로다.
- `overrides` 는 016 이 재지 않았다. 묶음을 받으므로, 그 프로젝트의 샘플에 `lib/generated/sample.*.dart` 가 들어 있다면 같은 4줄이 생길 것이다 (추론).
- MANIFEST 의 "정답지 셋" 은 잰 칸 셋(옛 주소, 묶음, 기본 + codegen)을 말한다. 정답지 **파일**로 세면 `example/` 의 것(`recommended` 가 함께 쓴다)과 `base_codegen` 의 것, 그리고 추론대로라면 `overrides` 의 것이다.

### 4. 저장소 루트의 분석 — plugin 을 준비한다

재려던 것이 아니라 `probe.dart` 의 두 칸(R1, R2)이 베타에서 달라 `root_probe.dart` 로 원인을 갈랐다. 모두 저장소 루트에서 인자 없이 돌린 분석이다 (커밋 전 린터와 같은 실행).

| id | `lib/` | `example/` | 루트의 제외 | 고정 SDK | 베타 |
|---|---|---|---|---|---|
| E0 | 비어 있음 | 없음 | 없음 | 0줄, plugin 0, 0.5초 | 같음 |
| U1 | 한 파일 구조 | 없음 | 없음 | `plugins_in_inner_options` 1줄, `exit 2`, plugin 0 | **0줄, `exit 0`, plugin 1, 10초** |
| U2 | 한 파일 구조 | 없음 | `lib/analysis_options.yaml` | 0줄, plugin 0 | **0줄, plugin 1, 10초** |
| S1 | 나눈 구조 | 없음 | 없음 | 0줄, plugin 0 | **0줄, plugin 1, 10초** |
| S2 | 나눈 구조 | 없음 | `lib/analysis_options.yaml` | 0줄, plugin 0 | **0줄, plugin 1, 10초** |
| S3 | 나눈 구조에서 별칭 파일만 뺌 | 없음 | 없음 | 0줄, plugin 0 | 0줄, plugin 0, 0.5초 |
| X1 | 비어 있음 | 옛 주소를 부름 | `example/**` | 0줄, plugin 0, 0.5초 | 같음 |
| X2 | 비어 있음 | 옛 주소를 부름 | 없음 | `include_file_not_found` 1줄 + `invalid_annotation_target` 1줄, `exit 2`, plugin 0, 3.4초 | 같음 (3.5초) |
| X3 | 별칭 없음 | 묶음을 부름 | `example/**` | 0줄, plugin 0 | 0줄, plugin 0, 0.5초 |
| X4 | 별칭 없음 | 묶음을 부름 | 없음 | example 의 16줄이 섞임, plugin 1 | example 의 20줄이 섞임, plugin 1 |
| T0 | 한 파일 구조 | 있음 | `lib/analysis_options.yaml` · `example/**` (**2026-10-12 의 저장소와 같은 제외**) | 0줄, plugin 0, 0.5초 | **0줄, plugin 1, 10초** |
| T1 | 나눈 구조 | 있음 | `example/**` (**Phase 3 이 지을 제외**) | 0줄, plugin 0, 0.5초 | **0줄, plugin 1, 10초** |
| T2 | 나눈 구조 | 있음 | `lib/analysis_options.yaml` · `example/**` | 0줄, plugin 0 | **0줄, plugin 1, 10초** |

- **원인은 `lib/` 에 있는 `analysis_options.yaml` 이라는 이름의 파일이다.** 그 파일이 `plugins:` 에 닿으면(직접 담든, 별칭으로 묶음을 부르든) 베타의 루트 분석이 plugin 을 준비한다. 그 이름의 파일이 없으면(S3) 준비하지 않는다. sdk#63627 의 변경 — 안쪽 옵션 파일의 `plugins:` 를 쓰게 됐다 — 과 맞는다.
- **루트 옵션 파일에서 그 파일을 제외해도 막지 못했다** (U2, S2, T0, T2). 잰 제외는 파일 하나를 가리키는 `lib/analysis_options.yaml` 이다. **`lib/**` 처럼 폴더째 제외한 경우는 재지 않았다** — 폴더 패턴 `example/**` 는 그 폴더의 plugin 준비를 막았다 (X3). "제외는 진단을 낼 파일을 고르는 것이고 어느 폴더가 어느 옵션 파일을 따르는지는 바꾸지 않는다" 는 016 이 이 결과에 붙인 해석이고 따로 확인한 것은 아니다.
- **제외한 `example/` 은 베타에서도 plugin 을 준비시키지 않았다** (X3). 연습용 프로젝트 폴더를 루트에서 제외하는 방식(007, 011)은 그대로 통한다. 제외하지 않으면 두 SDK 모두 그 폴더의 진단이 섞인다 (X4). 베타에서 이것을 본 칸은 X3 하나다 — 별칭이 없는 `lib/`, 패키지를 받은 `example/` 하나, 제외는 `example/**`. 프로젝트 여럿이 든 `fixtures/**`, `pub get` 전의 폴더, 옵션 파일에 `plugins:` 를 직접 적은 폴더는 베타에서 재지 않았다 (011 이 고정 SDK 에서 쟀다). 별칭이 있는 구성(T1)은 `lib/` 때문에 어차피 plugin 폴더가 1 이라 이것을 가려내지 못한다.
- **replica 에서 진단은 두 SDK 모두 0줄이다.** replica 의 루트에는 Dart 파일이 없었다. 실제 저장소의 루트 분석은 `tool/verify.dart` 도 본다 — 011 은 고정 SDK 에서 그 파일까지 넣어 0건을 봤다. **베타에서 `tool/verify.dart` 에 진단이 나는지, 준비된 plugin 이 그 파일을 보는지는 재지 않았다.** 달라진 것으로 확인된 것은 plugin 준비(폴더 0 → 1), 시간(0.5초 → 10초), 그리고 루트 분석에도 네트워크가 필요해진다는 점이다.
- 검증 명령(`tool/verify.dart`)은 루트에서 인자 없이 분석하지 않는다 — 규칙 검사는 복사본 폴더를 인자로 주고, 그 실행은 베타에서도 0.5초 · plugin 0 이다 (5번). 영향을 받는 것은 커밋 전에 손으로 돌리는 루트 분석이다. IDE 도 같을 것이다 (추정 — 재지 않았다).
- 한 파일 구조에서 루트의 제외를 먼저 지웠을 때의 `plugins_in_inner_options` (011) 는 고정 SDK 에서만 난다. "루트의 `lib/analysis_options.yaml` 제외는 나누는 커밋이거나 그 뒤에 지운다" 는 요구 사항은 고정 SDK 에서 일하는 동안 그대로 지킨다.

### 5. 규칙 검사 — 그대로다

| id | 대상 | pubspec 의 SDK 하한 | 고정 SDK | 베타 |
|---|---|---|---|---|
| K-base | `base.yaml` 그대로 | `^3.13.0` (저장소의 것) | `exit 0`, 0줄 | 같음 |
| K-base | `base.yaml` 그대로 | `^3.14.0` | `exit 0`, 0줄 | 같음 |
| K-base | `base.yaml` 그대로 | `^3.99.0` | `exit 0`, 0줄 | 같음 |
| K-problem | 문제 규칙 셋을 끼움 | `^3.13.0` | `exit 2`, `deprecated_lint` · `removed_lint` · `undefined_lint` | 같음 |

- 지금 규칙 12개 중 베타에서 deprecated / removed 가 된 것은 없다. deprecated 는 pubspec 의 SDK 하한이 그 버전 이상일 때만 보고되므로(005) 하한만 올린 pubspec 으로도 봤다.
- 기반 세트(`flutter_lints` 6.0.0 / `lints` 6.1.0)에서 올라오는 경고도 없었다. 다만 기반 세트는 include 로 받고, include 로 받은 규칙은 "없는 규칙" 만 보고된다 (rule-status-check.md). 그래서 이것이 말하는 것은 **기반 세트의 규칙 가운데 베타에서 없어진 것이 없다**는 데까지다. 기반 세트의 규칙이 deprecated 됐는지는 이 방식으로 알 수 없다.
- 규칙 검사의 형태(저장소 안의 복사본 폴더를 인자로 — rule-status-check.md 2번)는 베타에서도 0.5초이고 plugin 을 준비하지 않는다.
- 대상은 하위 폴더가 없는 평평한 복사본 하나(`build/woody_rule_check/analysis_options.yaml`)였다. 조각 셋을 하위 폴더에 둔 배치는 베타에서 재지 않았다.

### 6. `flutter analyze`

같은 연습용 프로젝트(한 파일 구조, 옛 주소)에서 `flutter analyze --no-pub` 를 돌렸다. 고정 SDK 한 번, 베타 두 번이다.

| SDK | 전체 | plugin 진단 | 비고 |
|---|---|---|---|
| Flutter 3.47.5 | 13건 | **0건** | plugin 은 준비됐지만(폴더 1) 진단이 화면에 없다 |
| Flutter 3.49.0-0.2.pre | 37건, 다시 돌리면 47건 | **3건** | 규칙 진단이 줄마다 두 번 이상 찍혔다. 같은 폴더의 `dart analyze` 는 20건 |

**plugin 진단 확인을 `dart analyze` 로 한다는 제약은 베타에서도 그대로 둔다.** 겹치는 원인은 보지 않았다.

- 이 표는 **손으로 돌린 것**이다. 두 스크립트에는 `flutter analyze` 실행이 없고 로그(`results/flutter-analyze-<Flutter 버전>.log`)만 남아 있다. 9번의 절차로는 다시 재지지 않는다.
- "실행마다 달랐다" 의 표본은 베타 두 번(37건, 47건)이다.

### 7. Phase 3 의 구현과 주석이 지킬 것

- **구조는 그대로 간다** (2번).
- **루트 옵션 파일의 주석을 다시 쓸 때 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다.** 다음 SDK 에서는 사실이 아니게 된다. 연습용 프로젝트 폴더의 제외는 "그 폴더의 진단이 루트 분석에 섞이지 않게" 가 두 SDK 에서 모두 맞는 이유다 (X3, X4).
- **성공 기준 3 의 "`codegen.yaml` 을 include 한 구성에서 생성 파일의 진단이 보고되지 않는다" 는 Dart 3.13.x 에서의 사실이다** (그 안에서도 규칙 진단에 대한 말이다 — suppression-and-exclude.md 6번).
- **성공 기준 4 (PRESET-06) 의 "루트 분석이 경고 없이 통과한다" 는 고정 SDK 에서 성립한다** (011 — `tool/verify.dart` 까지 넣은 replica 에서 0건). 베타에서는 Dart 파일이 없는 replica 의 루트가 0줄이었고, `tool/verify.dart` 가 있는 루트는 재지 않았다. 011 이 적은 "plugin 을 준비하지 않는다" 는 3.13.x 의 사실이다.
- 고정 SDK 를 올리는 날 되돌리는 변경이 들어가 있지 않다면 3번의 정답지들에 4줄이 생긴다. 그때 깨지는 것은 저장소의 변경 때문이 아니다. 016 은 `example/README.md` 에 이 경우를 적어 둘 만하다고 했다 — 넣을지는 계획이 정한다.

### 8. Phase 5 의 README 에 적을 것

- 생성 파일 제외는 **사용 프로젝트의 옵션 파일에 직접 적으라고 안내한다.** 3.13.x 에서는 plugin 진단 때문에, 베타에서는 규칙 진단까지 그렇다. `flutter_starter_kit` 은 이미 그렇게 적어 두었다 (2026-10-12 읽음).
- "프리셋의 제외가 통하지 않는다" 를 굳은 사실로 적지 않는다. "SDK 버전에 따라 다르다" 로 적고 sdk#64549 를 가리킨다. 더 정확히는 축이 둘이다 (3번) — 규칙 진단은 SDK 의 버전, plugin 진단은 plugin 이 쓰는 `analyzer` 의 버전을 따른다. README 가 어디까지 풀어 적을지는 Phase 5 가 정한다.
- 요구 사항의 "방법은 이것 하나" 를 README 에 "유일한 방법" 으로 옮기지 않는다. 실측에서 두 SDK 모두 막은 자리는 둘이었다 (3번).
- `flutter analyze` 에 대한 문장은 "Flutter 3.47.5 에서는 plugin 진단을 내지 않는다" 까지만 단정한다.
- 되돌리는 변경이 들어가지 않은 채 정식 버전이 나온다면, Flutter 버전을 고정하지 않은 사용 프로젝트가 이 동작을 먼저 겪는다 (들어갈지는 정해지지 않았다 → Constraints). 학습용 프로젝트 넷은 코드 생성을 쓰지 않아(03-CONTEXT.md D-08 의 확인) 생성 파일 4줄과는 무관하다.

### 9. 고정 SDK 를 Dart 3.14 계열로 올릴 때

`.fvmrc` 를 올리기 **전에** 016 의 두 스크립트를 그 SDK 로 한 번씩 돌린다 (10번의 방식).

**칸의 수가 아니라 칸의 내용을 읽는다.** 2026-10-12 의 베타에서 `probe.dart` 는 26칸 중 10칸이 `≠` 였다. 그 10칸은 세 무리다.

| 무리 | 칸 | 베타에서의 값 (기준값) | 무엇을 따르나 |
|---|---|---|---|
| 규칙 쪽만 담은 5칸 | U-old · S-alias · S-bundle 의 진단 수 | 20줄 (16줄) | SDK 에 든 analyzer |
| | S-base-codegen 의 진단 수 | 17줄 (13줄) | |
| | "X-bundle 에서 example 의 생성 파일 샘플 4줄" | 4줄 나옴 (0줄 나옴) | |
| 규칙 쪽과 plugin 쪽을 한 문자열에 담은 3칸 | X-bundle, X-local-sub, X-old | 규칙 나옴 / plugin 나옴 (규칙 안 나옴 / plugin 나옴) | 앞 절반은 SDK, 뒤 절반은 pub.dev 의 `analyzer` |
| 루트 분석의 2칸 | R1 | `plugins_in_inner_options` 0건, exit 0 (1건, exit 2) | sdk#63627 — 되돌리려는 변경이 아니다 |
| | R2 | plugin 폴더 1개 (0개) | |

| 새 SDK 에서 본 것 | 뜻 | 할 일 |
|---|---|---|
| 규칙 쪽 5칸이 그대로 `≠` (10칸 모두 2026-10-12 와 같다) | 되돌리는 변경이 그 SDK 에 들어가지 않았다 | 3번의 정답지들을 갱신하고 CHANGELOG 에 "SDK 가 바뀌어 생긴 줄" 로 적는다 |
| 규칙 쪽 5칸이 `=` 로 돌아왔다 | 되돌리는 변경이 그 SDK 에 들어갔다 | 정답지는 그대로다. R1 · R2 가 `≠` 로 남아 있으면 루트 분석의 plugin 준비(4번)도 남은 것이다 |
| 섞인 3칸이 "규칙 안 나옴 / plugin **안 나옴**" 으로 `≠` | 되돌리는 변경이 pub.dev 의 `analyzer` 로도 나왔다 — plugin 진단에도 프리셋의 제외가 통한다 | 생성 파일의 plugin 진단을 고정해 둔 정답지가 있으면 그 줄이 빠진다. suppression-and-exclude.md 6번을 다시 쓴다 |
| "plugin 쪽에서 풀린 버전" 칸이 `≠` | plugin 쪽 패키지의 새 버전이 나왔다 — SDK 와 무관하다 | 위의 칸들을 그 버전의 것으로 읽는다 |
| 그 밖 | 칸을 하나씩 읽는다 | — |

- 요구 사항의 "8칸" 은 위의 규칙 쪽 5칸과 섞인 3칸을 합친 것이다. 되돌리는 변경이 SDK 에만 들어가면 8칸이 모두 `=` 로 돌아오고 R1 · R2 의 2칸만 남는다. pub.dev 쪽으로도 나오면 섞인 3칸은 다른 값으로 다시 `≠` 가 되므로 "2칸만" 이 아니게 된다.
- **위의 둘째 ~ 넷째 줄은 잰 것이 아니다.** 어느 칸이 어느 상류 변경을 따르는지를 스크립트와 로그에서 읽은 것이다. 되돌리는 변경이 들어간 빌드는 2026-10-12 에 없었다. 10칸의 목록은 원본 로그 `results/probe-3.14.0-211.1.beta.log` 의 끝 표에서 셌다.
- `root_probe.dart` 는 `=` / `≠` 를 찍지 않고 표를 찍는다. 4번의 표(경우 13개가 모두 있다)와 줄마다 견준다.
- `flutter analyze` (6번)는 두 스크립트가 돌리지 않는다. 다시 보려면 손으로 돌린다.

**그때 스크립트가 그대로 돌지는 확인하지 않았다.** 스크립트를 읽어 찾은, 저장소의 2026-10-12 모양에 기대는 자리다 (다 찾았다고 보장하지 않는다).

| 기대는 것 | 자리 | 바뀌면 |
|---|---|---|
| `lib/analysis_options.yaml` 이 한 파일 구조다 — `analyzer:` 줄, `# analyzer plugin` 으로 시작하는 주석 줄, `plugins:` 줄이 그 순서로 있다 | `replica.dart` 의 `Shipped.read` | Phase 3 이 저장소를 나눈 뒤에는 멈출 것이다 (아래의 "멈추는 모양") |
| `lib/analysis_options.yaml`, `example/pubspec.lock`, `example/expected_diagnostics.txt` 가 있다 | `replica.dart` 의 `Replica.open` | 없으면 종료 코드 66 |
| `example/pubspec.yaml` 의 `    path: ..` 줄, `example/pubspec.lock` 의 `      path: ".."` 줄 | `replica.dart` 의 `Replica.addFixture` | 없으면 멈춘다 |
| `pubspec.yaml` 의 `  sdk: ^3.13.0` 줄 | `probe.dart` 의 `sdkLine` | 하한을 올리면 멈춘다 |
| 규칙 목록에 `    - control_flow_in_finally` 줄이 있다 | `probe.dart` 의 `lastRuleMarker` | 그 줄이 없어지면 멈춘다. **뒤에 규칙을 더하기만 하면 멈추지 않고**, 문제 규칙이 목록의 끝이 아니라 그 줄 바로 아래에 끼워진 채 돈다 |
| `example/lib` 의 샘플이 내는 줄 — 생성 파일 샘플의 4줄, `lib/should_not_appear.dart:5` 의 한 줄, plugin 진단 이름 셋 | `replica.dart` 의 `generatedLines` · `annotationLine` · `pluginCodes` (줄 번호까지 적혀 있다) | 멈추지 않는다. 샘플이 바뀌면 조합별 예상이 틀어져 SDK 와 무관한 `≠` 가 생긴다 |
| plugin 쪽 버전이 `riverpod_lint` 3.1.9 / `analyzer` 14.5.0 / `analysis_server_plugin` 0.3.24 | `probe.dart` 의 `baselinePluginVersions` | 새 버전이 나오면 그 칸이 SDK 와 무관하게 `≠` 가 된다 |

- **멈추는 모양:** 스크립트는 `FormatException` 을 그대로 보이지 않는다. `replica.dart` 의 `guard` 가 받아 stderr 에 `파일 모양이 예상과 다르다: …` 를 찍고 **종료 코드 65** 로 끝난다.
- 나눈 뒤에 돌리려면 스크립트를 나눈 파일을 읽게 고치거나, 나누기 전의 커밋을 따로 꺼낸 자리(예: `git worktree`)에서 그 안의 스크립트를 돌린다. 어느 쪽도 돌려 보지 않았다.
- 올린 **뒤**에는 검증 명령의 정답지 비교가 같은 4줄을 "남는 줄" 로 드러낼 것이다 (추론 — `tool/verify.dart` 를 베타로 돌린 것은 아니다). 검증 명령의 SDK 확인은 실행 중인 Flutter 버전을 `.fvmrc` 의 `flutter` 값과 견주고 다르면 종료 코드 78 로 끝난다 (2026-10-12 의 `tool/verify.dart` 를 읽은 것). 그래서 `.fvmrc` 를 올리기 전에는 새 SDK 로 검증 명령을 돌릴 수 없고, 올린 뒤에는 그 SDK 로 돌면 이 단계를 지난다.

### 10. 베타 SDK 를 저장소를 건드리지 않고 돌리는 방법

```bash
# 베타 SDK 를 fvm 캐시에만 받는다 (.fvmrc 는 바뀌지 않는다). 저장소 밖에서 한다.
fvm install 3.49.0-0.2.pre --setup
~/fvm/versions/3.49.0-0.2.pre/bin/flutter precache --universal \
  --no-android --no-ios --no-web --no-macos --no-linux --no-windows --no-fuchsia

# 저장소 밖을 작업 디렉터리로 두고, 스크립트의 절대 경로를 준다 (각각 약 2분, 네트워크 필요).
cd <저장소 밖의 폴더>
<저장소>/.fvm/flutter_sdk/bin/cache/dart-sdk/bin/dart <저장소>/.planning/spikes/016-next-sdk-forward-compat/probe.dart <작업 폴더 1>
~/fvm/versions/3.49.0-0.2.pre/bin/cache/dart-sdk/bin/dart <저장소>/.planning/spikes/016-next-sdk-forward-compat/probe.dart <작업 폴더 2>
# 루트 분석을 떼어 보는 실험도 같은 방식이다 (고정 SDK 약 25초, 베타 약 1분 30초).
#   … root_probe.dart <작업 폴더 3> / <작업 폴더 4>
```

- `fvm install … --setup` 만으로는 Flutter 프로젝트의 `dart pub get` 이 실패한다: `could not find package sky_engine in the Flutter SDK`. `flutter precache --universal` 로 공통 구성물을 받은 뒤에 됐다.
- 실행 뒤 저장소 루트의 `.dart_tool/package_config.json` 은 `generatorVersion: 3.13.4` 그대로였고 `example/pubspec.lock` 도 바뀌지 않았다. 다른 SDK 로 돌린 뒤에는 이 둘과 `git status` 로 저장소가 그대로인지 본다.
- 결과 파일 이름에 Dart 버전이 들어간다 (`results/probe-<Dart 버전>.json`, `results/root-<Dart 버전>.json`). 같은 버전으로 다시 돌리면 덮어쓴다.
- 끝난 뒤 베타를 지우려면 `fvm remove 3.49.0-0.2.pre`. 받는 크기는 1.6 GB 다.

칸마다 기준값을 적어 두고 견주는 코드.

```dart
// sources/016-next-sdk-forward-compat/probe.dart 의 Observations 에서
/// [label] 칸의 기준값 [baseline] 과 실제 [actual] 을 적는다.
void add(String label, String baseline, String actual) {
  _items.add((label, baseline, actual));
  stdout.writeln('   ${baseline == actual ? '=' : '≠'} $label — $actual'
      '${baseline == actual ? '' : ' (기준: $baseline)'}');
}
```

- `=` / `≠` 는 판정(통과 · 실패)이 아니다. 스크립트의 종료 코드를 정하는 `# 판정` 에는 스크립트 자신이 믿을 만한지를 보는 대조 2건만 넣었다 — 없는 규칙이 보고된다(K-problem), 제외가 없으면 생성 파일의 규칙 진단이 나온다(X-none).
- 고정 SDK 의 실행에서 26칸이 모두 `=` 인 것이 "스크립트가 맞다" 의 대조다.

## What to Avoid

- **고정 SDK 에서 잰 "루트 분석이 plugin 을 준비하지 않는다" 를 SDK 와 무관한 사실로 적는 것.** 베타에서는 준비한다.
- **"프리셋의 제외가 규칙 진단에 통한다" 를 SDK 와 무관한 사실로 적는 것**, 반대로 **"통하지 않는다" 를 굳은 사실로 적는 것.** 상류가 되돌리는 중이다.
- **루트의 제외로 루트 분석의 plugin 준비를 막으려는 것.** `lib/analysis_options.yaml` 을 제외해도 베타는 준비한다 (`lib/**` 로는 재지 않았다).
- **"베타에서도 루트 분석이 0줄" 을 실제 저장소의 사실로 옮기는 것.** Dart 파일이 없는 replica 의 값이다. `tool/verify.dart` 가 있는 루트는 베타로 돌리지 않았다.
- **`≠` 의 칸 수만 세어 판단하는 것.** 규칙 쪽과 plugin 쪽이 한 칸에 섞여 있고, plugin 쪽은 SDK 와 따로 움직인다 (9번).
- **생성 파일의 plugin 진단을 "SDK 를 올릴 때만 달라지는 줄" 로 보는 것.** pub.dev 의 `analyzer` 릴리스로도 달라질 수 있다 (3번).
- **베타의 결과를 보고 구조를 바꾸는 것.** 생성 파일 제외는 한 파일 구조(1.3.0)에서도 똑같이 달라졌다. 나눈 것과 무관하다.
- **`.fvmrc` 를 올린 뒤 깨진 정답지를 저장소의 변경 탓으로 읽는 것.** 4줄이 `lib/generated/sample.*.dart` 의 것이면 SDK 가 바뀌어 생긴 줄이다.
- **저장소 루트에서 다른 SDK 의 `dart run` 을 하는 것.** 그 SDK 가 루트의 패키지를 다시 풀어 `.dart_tool/` 과 lock 을 바꿀 수 있다.
- **`fvm install --setup` 만 한 SDK 로 Flutter 프로젝트의 `dart pub get` 을 돌리는 것.** `sky_engine` 을 찾지 못한다.
- **`.fvmrc` 나 `.vscode/settings.json` 을 바꿔 가며 견주는 것.** 베타는 fvm 캐시에만 두고 `dart` 의 경로를 직접 준다.
- **베타의 `flutter analyze` 건수를 근거로 쓰는 것.** 실행마다 달랐다 (37건, 47건).
- **상류 이슈를 요약만 보고 옮기는 것.** 상태 · 라벨 · 댓글을 `gh issue view <번호> --repo dart-lang/sdk` 로 직접 읽고 읽은 날짜를 적는다.

## Constraints

- **베타 하나(`3.14.0-211.1.beta`)의 결과다.** Dart 3.14 정식 버전은 재지 않았다. 되돌리는 변경(CL 562741)이 들어간 빌드는 2026-10-12 에 없었다.
- 상류의 상태 (모두 2026-10-12 에 `gh issue view` 로 읽었다).
  - **plugin 을 적을 수 있는 자리** — sdk#63627 "Allow analyzer plugins to be specified in any analysis options file" (2026-06-20 열림, 2026-08-19 닫힘). 닫으며 남긴 말: "This is now available in the latest Dart 3.14 beta release." Dart 3.13 까지는 분석의 루트에 있는 옵션 파일의 `plugins:` 만 쓰였고 안쪽 옵션 파일의 것은 `plugins_in_inner_options` 경고를 냈다 (sdk#61481, 2026-08-25 에 "resolved as per the design in #63627" 로 닫힘). dart.dev 의 `plugins_in_inner_options` 문서는 옛 설명 그대로였다 (Dart 3.13.3 기준이라고 적혀 있다).
  - **제외 패턴의 기준 폴더** — sdk commit 7c44c48 "AO. Use AnalysisOptionsExcludePattern, with declaringFile." 이 기준을 "옵션 파일이 있는 폴더" 에서 "그 패턴을 적은 파일이 있는 폴더" 로 바꿨다. sdk#63864 (workspace 에서 include 한 파일의 제외 경로가 예상과 다르게 풀린다, 2026-07-21) 를 고친 변경이고, pub.dev 의 `analyzer` 에는 14.4.0 부터 들어 있다 (012 가 소스로 확인).
  - **그 변경은 되돌려질 수 있다** — sdk#64549 "Files excluded by an included analysis_options.yaml are analyzed with analyzer 14" (2026-10-09 열림, 열려 있음, 라벨 `P1` · `type-bug`). 신고 내용이 이 패키지의 경우와 같다: "Declaring the same `exclude` section directly in `app/analysis_options.yaml` makes it work again." 담당자가 2026-10-11 에 sdk#63864 를 다시 열며 적었다: "The fix causes #64549. I consider reverting the fix and restore anchoring globs to the folder with the selected analysis options file." 되돌리는 변경(CL 562741)이 리뷰에 올라와 있다. **3.14 정식 버전이나 다음 `analyzer` 릴리스에 들어갈지는 정해진 것이 없다.**
  - SDK 의 `CHANGELOG.md` 3.14.0 절(미출시)에는 위 두 변경이 적혀 있지 않았다.
- 요구 사항의 "(2026-10-11)" 은 담당자가 댓글을 단 날이고, 이슈를 읽은 날은 2026-10-12 다.
- 루트 분석(4번, R1 · R2)의 replica 는 저장소의 `pubspec.yaml` 과 루트 옵션 파일, `lib/` 의 YAML, (경우에 따라) `example/` 로 이루어진다. `tool/` 은 없다. 011 의 replica 에는 `tool/verify.dart` 가 있었다 — 같은 구성의 고정 SDK 시간이 011 은 0.6 ~ 0.7초, 016 은 0.5초인 것이 그 차이다.
- 두 스크립트를 SDK 마다 두 번씩 돌렸다. 첫 실행은 `probe.dart` 24칸(베타에서 9칸이 `≠`), 둘째 실행은 칸을 더한 26칸(10칸이 `≠`)이고, 겹치는 24칸은 두 번이 같았다. 둘째 실행에서 더한 칸 — `probe.dart` 의 X-local-root · X-local-sub, `root_probe.dart` 의 X3 · X4 — 은 SDK 마다 **한 번씩** 잰 것이다.
- 연습용 프로젝트는 replica 안에서 `woody_lints` 를 `path:` 로 받았다. git 의존성으로 받은 경우는 베타에서 재지 않았다 (015 가 고정 SDK 에서 "`path:` 와 줄 단위로 같다" 를 봤다).
- 고정 SDK 를 올리지 않아도 루트 옵션 파일이 `package:woody_lints/base.yaml` 을 include 하는 선택지(011)는 베타에서 재지 않았다. 폴더를 인자로 준 분석에서 묶음 · 별칭이 plugin 을 준비하는 것(013)도 베타에서 재지 않았다.
- 확인하지 않은 것: 되돌리는 변경이 pub.dev 의 `analyzer` 로 나온 뒤 plugin 쪽의 동작 (그때는 프리셋의 제외가 plugin 진단에도 통하게 될 수 있다 — 추정), 끄는 방법 여섯 칸(012 의 주석 · `diagnostics:`)을 베타에서, 베타에서 루트 분석이 준비한 plugin 이 Dart 파일을 실제로 보는지 (replica 의 루트에는 Dart 파일이 없었다 — 실제 저장소에는 `tool/verify.dart` 가 있다), `lib/**` 처럼 폴더째 제외했을 때 베타의 루트 분석이 plugin 을 준비하는지, 베타의 루트 분석에서 plugin 준비가 실패했을 때(네트워크 없음)의 종료 코드와 stderr, 베타의 `flutter analyze` 가 규칙 진단을 겹쳐 세는 원인, `tool/verify.dart` 자체를 베타로 돌린 것, 하위 폴더를 인자로 주면 plugin 진단을 잃는 문제(001, sdk#62710)가 베타에서 고쳐졌는지, 사용 통계를 끄지 않았을 때의 종료 코드 255 (001) 가 베타에서도 나는지, GitHub Linux runner 에서의 같은 실행.

## Origin

Synthesized from spikes: 016 (기준이 되는 고정 SDK 의 값은 009 ~ 013 과 015 가 잰 것과 같다)
Source files available in: sources/016-next-sdk-forward-compat/ (`probe.dart`, `root_probe.dart`), sources/009-preset-plugin-via-include/ (`replica.dart`)
원본 로그와 JSON: `.planning/spikes/016-next-sdk-forward-compat/results/` — `probe-<Dart 버전>.{log,json}`, `root-<Dart 버전>.{log,json}`, `flutter-analyze-<Flutter 버전>.log`. 이름 끝이 `-run1` 인 것이 첫 실행이고, `-attempt1` 은 `sky_engine` 이 없어 멈춘 실행이다
