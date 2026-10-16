---
spike: 016
idea: next-sdk-forward-compat
name: next-sdk-forward-compat
type: standard
validates: "Given Flutter 베타 3.49.0-0.2.pre (Dart 3.14.0-211.1.beta) 와 저장소의 복사본, when 고정 SDK 에서 돌린 것과 같은 스크립트를 베타로 돌리면, then include 로 받는 plugins: 가 로드되는지 · codegen.yaml 의 제외가 규칙 진단에 여전히 통하는지 · 지금 규칙 12개 중 새로 deprecated 된 것이 있는지가 확정된다"
verdict: PARTIAL
related: [009, 010, 011, 012, 013, 015]
tags: [beta-sdk, forward-compat, include, analyzer-plugin, exclude, deprecated-lint, plugins-in-inner-options]
---

# Spike 016: 다음 SDK (Flutter 베타) 에서의 프리셋 구조

## What This Validates

지금까지의 spike 는 모두 저장소 고정 SDK (Flutter 3.47.5 / Dart 3.13.4) 에서 쟀다. 조사 문서는 "include 된 파일의 `plugins:` 가 다음 SDK 에서도 허용되는가" 와 "Dart 3.14 의 `analyzer.exclude` 기준 디렉터리 변경" 을 소스만 읽고 "이번 마일스톤에서 확인하지 않아도 되는 항목" 으로 남겼다 (`research/SUMMARY.md` § Gaps to Address). 2026-10-01 에 Flutter 베타가 공개되어 실행으로 잴 수 있게 됐고, 구조를 짓기 전에 재기로 했다 (소유자 선택 2026-10-12).

- **Given** Flutter 베타 `3.49.0-0.2.pre` (Dart `3.14.0-211.1.beta`) 와 저장소의 복사본
- **When** 고정 SDK 에서 돌린 것과 **같은 스크립트**를 베타로 돌리면
- **Then** (a) include 로 받는 `plugins:` 가 로드되는지, (b) `codegen.yaml` 의 제외가 규칙 진단에 여전히 통하는지, (c) 지금 규칙 12개 중 새로 deprecated / removed 가 된 것이 있는지가 확정된다

**(a) 와 (c) 는 지금과 같다. (b) 는 달라졌다 — 이 패키지가 주는 생성 파일 제외는 베타에서 규칙 진단에도 통하지 않는다.** 재지 않으려던 곳에서 하나가 더 나왔다 — 베타에서는 저장소 루트의 분석이 `plugins_in_inner_options` 를 내지 않고 plugin 을 준비한다.

이 결과는 베타의 것이다. 정식 버전에서 달라질 수 있고, (b) 는 Dart 팀이 되돌리려는 중이다 (아래 Research).

## Research

모두 2026-10-12 에 읽었다. 이슈의 상태와 댓글은 `gh issue view` 로 직접 확인했다.

- **plugin 을 적을 수 있는 자리** — sdk#63627 "Allow analyzer plugins to be specified in any analysis options file" (srawlins, 2026-06-20 열림, 2026-08-19 닫힘). 닫으며 남긴 말: "This is now available in the latest Dart 3.14 beta release." Dart 3.13 까지는 분석의 루트에 있는 옵션 파일의 `plugins:` 만 쓰였고 안쪽 옵션 파일의 것은 `plugins_in_inner_options` 경고를 냈다 (sdk#61481, 2026-08-25 에 "resolved as per the design in #63627" 로 닫힘). dart.dev 의 `plugins_in_inner_options` 문서는 아직 옛 설명 그대로다 (Dart 3.13.3 기준이라고 적혀 있다).
- **제외 패턴의 기준 폴더** — sdk commit 7c44c48 "AO. Use AnalysisOptionsExcludePattern, with declaringFile." 이 `context_locator.dart` 의 기준을 "옵션 파일이 있는 폴더" 에서 "그 패턴을 적은 파일이 있는 폴더" 로 바꿨다. sdk#63864 (workspace 에서 include 한 파일의 제외 경로가 예상과 다르게 풀린다, 2026-07-21) 를 고친 변경이다. pub.dev 의 `analyzer` 에는 14.4.0 부터 들어 있다 (spike 012 가 소스로 확인).
- **그 변경은 되돌려질 수 있다** — sdk#64549 "Files excluded by an included analysis_options.yaml are analyzed with analyzer 14" (2026-10-09 열림, 열려 있음, 라벨 `P1` · `type-bug`). 신고 내용이 이 패키지의 경우와 같다: 공유 lint 패키지가 주는 `exclude` 가 `analyzer` 14.5.0 에서 통하지 않고, "Declaring the same `exclude` section directly in `app/analysis_options.yaml` makes it work again." 담당자(scheglov)가 2026-10-11 에 sdk#63864 를 다시 열며 적었다: "The fix causes #64549. I consider reverting the fix and restore anchoring globs to the folder with the selected analysis options file." 되돌리는 변경(CL 562741)이 리뷰에 올라와 있다. **3.14 정식 버전이나 다음 `analyzer` 릴리스에 들어갈지는 정해진 것이 없다.**
- SDK 의 `CHANGELOG.md` 3.14.0 절(미출시)에는 위 두 변경이 적혀 있지 않다. 분석기 항목은 `js_interop` 진단 하나뿐이다.

| Approach | Tool/Library | Pros | Cons | Status |
|----------|-------------|------|------|--------|
| 같은 스크립트를 SDK 둘로 돌려 칸마다 견준다 | `fvm install`, 두 SDK 의 `dart` | 다른 것은 SDK 뿐이다. 기준 실행이 "스크립트가 맞다" 를 보인다 | 베타 SDK 를 받아야 한다 (1.6 GB) | **채택** |
| 009 ~ 013 의 스크립트를 베타로 그대로 다시 돌린다 | — | 새로 쓸 것이 없다 | 그 spike 들의 `results/` 를 덮어쓴다. 5개를 돌려야 한다 | 쓰지 않음 |
| SDK main 의 소스를 읽는다 | — | 받을 것이 없다 | 조사가 이미 했고 추정으로 남았다 | 쓰지 않음 |

**Chosen approach:** 009 · 010 · 011 · 012 · 013 의 핵심 칸을 한 스크립트(`probe.dart`)에 모으고, 칸마다 "고정 SDK 에서의 값" 을 적어 두어 실제와 `=` / `≠` 로 견준다. 고정 SDK 의 실행에서 26칸이 모두 `=` 인 것이 대조다. 루트 분석에서 나온 예상 밖의 결과는 둘째 스크립트(`root_probe.dart`)로 원인을 떼어 봤다.

## How to Run

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

끝난 뒤 베타를 지우려면 `fvm remove 3.49.0-0.2.pre`.

## What to Expect

칸마다 `=` (기준과 같다) 또는 `≠` (다르다, 기준값을 함께 찍는다) 를 찍고 끝에 `# 기준 SDK (Dart 3.13.4) 의 값과 견줌` 표로 모은다. 고정 SDK 에서는 26칸이 모두 `=`, 베타에서는 10칸이 `≠` 다. `# 판정` 2건은 스크립트 자신이 믿을 만한지를 보는 대조다 (없는 규칙이 보고된다 / 제외가 없으면 생성 파일의 진단이 나온다).

## Investigation Trail

고정 SDK: Flutter 3.47.5 / Dart 3.13.4. 베타: Flutter 3.49.0-0.2.pre / Dart 3.14.0-211.1.beta (framework revision `38ec981bad`, 2026-09-30). macOS arm64, 2026-10-12. plugin 쪽에서 풀린 버전은 두 SDK 에서 같았다 — `riverpod_lint` 3.1.9 / `analyzer` 14.5.0 / `analysis_server_plugin` 0.3.24. 두 스크립트를 SDK 마다 두 번씩 돌렸고 결과가 두 번 모두 같았다 (`results/*-run1.*` 이 첫 실행).

### 0. 베타를 돌릴 수 있게 하기까지

- `fvm install … --setup` 만으로는 `dart pub get` 이 Flutter 프로젝트에서 실패했다: `could not find package sky_engine in the Flutter SDK` (`results/probe-3.14.0-211.1.beta-attempt1.log`). `flutter precache --universal` 로 공통 구성물을 받은 뒤에 됐다. 고정 SDK 는 그동안의 `flutter` 실행으로 이미 받아져 있었다.
- 베타의 `dart` 는 저장소 밖을 작업 디렉터리로 두고 띄웠다. 실행 뒤 저장소 루트의 `.dart_tool/package_config.json` 은 `generatorVersion: 3.13.4` 그대로이고 `example/pubspec.lock` 도 바뀌지 않았다.

### 1. include 로 받는 `plugins:` — 지금과 같다

| id | 구조 · 옵션 | 3.13.4 | 베타 |
|---|---|---|---|
| U-old | 한 파일 구조 (1.3.0), 옛 주소 | plugin 폴더 1, plugin 진단 3줄 | 같음 |
| S-alias | 나눈 구조, 옛 주소 (3단) | plugin 폴더 1, plugin 진단 3줄 | 같음 |
| S-bundle | 나눈 구조, 묶음 주소 | plugin 폴더 1, plugin 진단 3줄 | 같음 |
| S-base-riverpod | `base.yaml` + `riverpod.yaml` | 21줄, `exit 2` | **한 줄도 다르지 않음** |
| S-base-only | `base.yaml` 만 | 18줄, `exit 2`, plugin 폴더 0 | **한 줄도 다르지 않음** |

- 이름이 `analysis_options.yaml` 이 아닌 조각의 `plugins:` 가 베타에서도 3단 include 를 거쳐 로드된다. 처음 실행은 14.8 ~ 16.7초로 고정 SDK 와 같다.
- 규칙 진단과 plugin 진단의 내용 · 강도 · 줄 번호는 달라지지 않았다. 달라진 것은 아래 2번의 생성 파일 4줄뿐이다.

### 2. 생성 파일 제외 — 달라졌다

`example/` 의 샘플을 그대로 분석한 결과.

| id | 옵션 | 3.13.4 | 베타 |
|---|---|---|---|
| U-old | 한 파일 구조, 옛 주소 | `exit 2` · 16줄 (정답지와 같음) | `exit 2` · **20줄** |
| S-alias | 나눈 구조, 옛 주소 | `exit 2` · 16줄 | `exit 2` · **20줄** |
| S-bundle | 나눈 구조, 묶음 주소 | `exit 2` · 16줄 | `exit 2` · **20줄** |
| S-base-codegen | `base.yaml` + `codegen.yaml` | `exit 0` · 13줄 | `exit 0` · **17줄** |

더해진 4줄은 네 경우 모두 같다.

```text
+ lib/generated/sample.freezed.dart:4  info  avoid_print
+ lib/generated/sample.freezed.dart:4  info  prefer_single_quotes
+ lib/generated/sample.g.dart:4  info  avoid_print
+ lib/generated/sample.g.dart:4  info  prefer_single_quotes
```

생성 파일 샘플(`lib/generated/riverpod_violation.g.dart` — 한 줄에 규칙 위반과 plugin 위반, spike 012 · 015 의 것)로 "어디에 적은 제외가 통하는가" 를 봤다.

| id | `**/*.g.dart` 제외를 적은 곳 | 3.13.4 규칙 | 3.13.4 plugin | 베타 규칙 | 베타 plugin |
|---|---|---|---|---|---|
| X-none | 없음 | 나옴 | 나옴 | 나옴 | 나옴 |
| X-bundle | 패키지의 `codegen.yaml` (묶음으로 받음) | 안 나옴 | 나옴 | **나옴** | 나옴 |
| X-old | 패키지의 한 파일 구조 (1.3.0 의 모양) | 안 나옴 | 나옴 | **나옴** | 나옴 |
| X-own | 사용 프로젝트의 옵션 파일에 직접 | 안 나옴 | 안 나옴 | 안 나옴 | 안 나옴 |
| X-local-root | 사용 프로젝트 루트의 `local_excludes.yaml` (include 로 부름) | 안 나옴 | 안 나옴 | 안 나옴 | 안 나옴 |
| X-local-sub | 사용 프로젝트의 `config/local_excludes.yaml` (include 로 부름) | 안 나옴 | 나옴 | **나옴** | 나옴 |

- **베타에서는 규칙 쪽도 plugin 쪽과 같은 기준을 쓴다** — 제외 패턴을 "그 패턴을 적은 파일의 폴더" 에서부터 찾는다. X-local-root 와 X-local-sub 는 같은 내용의 파일을 폴더만 달리 둔 것이고 베타에서는 규칙 진단도 갈렸다. 3.13.4 에서 규칙과 plugin 이 어긋나던 것(spike 012)이 베타에서는 "둘 다 통하지 않는다" 로 맞춰졌다.
- 그래서 패키지 안에 적힌 `**/*.g.dart` · `**/*.freezed.dart` 는 사용 프로젝트의 파일에 맞지 않는다. **나눠서 생기는 일이 아니다** — 한 파일 구조(1.3.0)도 같다 (U-old, X-old).
- 사용 프로젝트가 자기 옵션 파일에 직접 적은 제외는 두 SDK 에서 규칙과 plugin 을 모두 막는다 (X-own).
- 연습용 프로젝트별 정답지에서 달라지는 것: 옛 주소 · 묶음 16줄 → 20줄, 기본 + codegen 13줄 → 17줄 (`exit` 줄은 그대로). 기본만(18줄) · 기본 + Riverpod(21줄)은 원래 그 4줄을 담고 있어 그대로다.
- Research 에 적었듯 이 동작은 Dart 팀이 `P1` 버그로 다루고 있고 되돌리는 변경이 리뷰 중이다 (2026-10-11).

### 3. 저장소 루트의 분석 — 달라졌다 (재려던 것이 아니다)

`probe.dart` 의 두 칸이 베타에서 달랐다: 한 파일 구조에서 루트의 `lib/analysis_options.yaml` 제외를 걷어내도 `plugins_in_inner_options` 가 나오지 않았고(R1), 나눈 구조의 루트 분석이 plugin 을 준비했다(R2). `root_probe.dart` 로 `lib/` 와 `example/` 을 하나씩 넣고 빼며 원인을 갈랐다. 모두 저장소 루트에서 인자 없이 돌린 분석이다.

| id | `lib/` | `example/` | 루트의 제외 | 3.13.4 | 베타 |
|---|---|---|---|---|---|
| E0 | 비어 있음 | 없음 | 없음 | 0줄, plugin 0, 0.5초 | 같음 |
| U1 | 한 파일 구조 | 없음 | 없음 | `plugins_in_inner_options` 1줄, `exit 2`, plugin 0 | **0줄, `exit 0`, plugin 1, 10초** |
| U2 | 한 파일 구조 | 없음 | `lib/analysis_options.yaml` | 0줄, plugin 0 | **0줄, plugin 1, 10초** |
| S1 | 나눈 구조 | 없음 | 없음 | 0줄, plugin 0 | **0줄, plugin 1, 10초** |
| S2 | 나눈 구조 | 없음 | `lib/analysis_options.yaml` | 0줄, plugin 0 | **0줄, plugin 1, 10초** |
| S3 | 나눈 구조에서 별칭 파일만 뺌 | 없음 | 없음 | 0줄, plugin 0 | 0줄, plugin 0, 0.5초 |
| X3 | 별칭 없음 | 묶음을 부름 | `example/**` | 0줄, plugin 0 | 0줄, plugin 0, 0.5초 |
| X4 | 별칭 없음 | 묶음을 부름 | 없음 | example 의 16줄이 섞임, plugin 1 | example 의 20줄이 섞임, plugin 1 |
| T0 | 한 파일 구조 | 있음 | `lib/analysis_options.yaml` · `example/**` (지금의 저장소) | 0줄, plugin 0, 0.5초 | **0줄, plugin 1, 10초** |
| T1 | 나눈 구조 | 있음 | `example/**` (Phase 3 이 지을 모양) | 0줄, plugin 0, 0.5초 | **0줄, plugin 1, 10초** |
| T2 | 나눈 구조 | 있음 | `lib/analysis_options.yaml` · `example/**` | 0줄, plugin 0 | **0줄, plugin 1, 10초** |

- **원인은 `lib/` 에 있는 `analysis_options.yaml` 이라는 이름의 파일이다.** 그 파일이 `plugins:` 에 닿으면(직접 담든, 별칭으로 묶음을 부르든) 베타의 루트 분석이 plugin 을 준비한다. 그 이름의 파일이 없으면(S3) 준비하지 않는다. sdk#63627 의 변경 — 안쪽 옵션 파일의 `plugins:` 를 쓰게 됐다 — 과 맞는다.
- **루트 옵션 파일에서 그 파일을 제외해도 막지 못한다** (U2, S2, T0, T2). 제외는 진단을 낼 파일을 고르는 것이고, 어느 폴더가 어느 옵션 파일을 따르는지는 바꾸지 않는다.
- 제외한 `example/` 은 베타에서도 plugin 을 준비시키지 않는다 (X3). 연습용 프로젝트 폴더를 루트에서 제외하는 방식(spike 007 · 011)은 그대로 통한다.
- **진단은 두 SDK 에서 모두 0줄이다.** `lib/` 에는 Dart 파일이 없어 준비된 plugin 이 볼 것이 없다. 달라지는 것은 시간(0.5초 → 10초)과, 루트 분석에도 네트워크가 필요해진다는 점이다.
- 검증 명령(`tool/verify.dart`)은 루트에서 인자 없이 분석하지 않는다 — 규칙 검사는 복사본 폴더를 인자로 주고, 그 실행은 베타에서도 0.5초 · plugin 0 이다 (아래 4번). 영향을 받는 것은 커밋 전에 손으로 돌리는 루트 분석과 IDE 다.

### 4. 규칙 검사 — 지금과 같다

| id | 대상 | pubspec 의 SDK 하한 | 3.13.4 | 베타 |
|---|---|---|---|---|
| K-base | `base.yaml` 그대로 | `^3.13.0` (저장소의 것) | `exit 0`, 0줄 | 같음 |
| K-base | `base.yaml` 그대로 | `^3.14.0` | `exit 0`, 0줄 | 같음 |
| K-base | `base.yaml` 그대로 | `^3.99.0` | `exit 0`, 0줄 | 같음 |
| K-problem | 문제 규칙 셋을 끼움 | `^3.13.0` | `deprecated_lint` · `removed_lint` · `undefined_lint` | 같음 |

- 지금 규칙 12개 중 베타에서 deprecated / removed 가 된 것은 없다. deprecated 는 pubspec 의 SDK 하한이 그 버전 이상일 때만 보고되므로(spike 005) 하한을 `^3.14.0` 과 `^3.99.0` 으로 올린 pubspec 으로도 봤다. 기반 세트(`flutter_lints` 6.0.0 / `lints` 6.1.0)의 규칙에서 올라오는 경고도 없었다.
- 규칙 검사의 형태(복사본 폴더를 인자로)는 베타에서도 0.5초이고 plugin 을 준비하지 않는다.

### 5. 함께 본 것 — `flutter analyze`

`dart analyze` 가 아니라 `flutter analyze --no-pub` 를 같은 연습용 프로젝트(한 파일 구조, 옛 주소)에서 돌렸다. 고정 SDK 한 번, 베타 두 번이다.

| SDK | 전체 | plugin 진단 | 비고 |
|---|---|---|---|
| Flutter 3.47.5 | 13건 | **0건** | plugin 은 준비됐지만(폴더 1) 진단이 화면에 없다 — PROJECT.md 의 제약 그대로 |
| Flutter 3.49.0-0.2.pre | 37건, 다시 돌리면 47건 | **3건** | 규칙 진단이 줄마다 두 번 이상 찍혔다. 같은 폴더의 `dart analyze` 는 20건 |

베타의 `flutter analyze` 는 plugin 진단을 내지만 규칙 진단을 겹쳐 세고 그 수가 실행마다 달랐다. **plugin 진단 확인을 `dart analyze` 로 한다는 제약은 베타에서도 그대로 둔다.** 겹치는 원인은 보지 않았다.

## Results

**Verdict: PARTIAL** — 세 가지가 모두 확정됐고, 둘은 지금과 같고 하나는 달라졌다. 구조를 바꿔야 하는 결과는 없다 (멈춤 조건에 해당하지 않는다).

1. **(a) 그대로다.** include 로 받는 `plugins:` 는 베타에서도 한 파일 구조 · 3단 별칭 · 묶음 · 조각 조합에서 모두 로드되고, 진단의 내용이 같다.
2. **(b) 달라졌다.** 이 패키지가 주는 생성 파일 제외(`**/*.g.dart`, `**/*.freezed.dart`)는 베타에서 규칙 진단에도 통하지 않는다. 3.13.4 에서는 plugin 진단에만 통하지 않았다(spike 012). 1.3.0 의 한 파일 구조도 같다. Dart 팀이 `P1` 버그(sdk#64549)로 다루며 되돌리는 변경을 리뷰하고 있어, 정식 3.14 에서 어느 쪽일지는 모른다.
3. **(c) 그대로다.** 지금 규칙 12개 중 베타에서 deprecated / removed 가 된 것은 없다.
4. **재려던 것 밖에서 나온 것.** 베타에서는 `plugins_in_inner_options` 가 나오지 않고, `lib/analysis_options.yaml` 이 `plugins:` 에 닿는 한 저장소 루트의 분석이 plugin 을 준비한다 (0.5초 → 10초, 진단은 0줄). 루트의 제외로는 막지 못한다.

Phase 3 의 계획이 가져갈 것:

- **구조는 그대로 간다.** 조각 셋 · 묶음 · 별칭의 설계를 바꿀 이유가 나오지 않았다.
- **성공 기준 3 의 "`codegen.yaml` 을 include 한 구성에서 생성 파일의 진단이 보고되지 않는다" 는 Dart 3.13.x 에서의 사실이다.** 고정 SDK 를 다음 정식 버전으로 올리는 날, 되돌리는 변경이 들어가 있지 않다면 정답지 셋(`example/`, 묶음, 기본 + codegen)에 위의 4줄이 생긴다. 그때 깨지는 것은 저장소의 변경 때문이 아니다 — `example/README.md` 에 이 경우를 적어 둘 만하다.
- 성공 기준 4 (PRESET-06) 의 "루트 분석이 경고 없이 통과한다" 는 두 SDK 에서 모두 성립한다. spike 011 이 적은 "plugin 을 준비하지 않는다" 는 3.13.x 의 사실이고 베타에서는 준비한다. `plugins_in_inner_options` 를 피하려고 두었던 루트의 제외는 3.13.x 에서만 뜻이 있다.
- 루트 옵션 파일의 주석을 다시 쓸 때 "plugin 을 준비하지 않도록" 을 이유로 적지 않는다. 다음 SDK 에서는 사실이 아니게 된다.

Phase 5 (README) 로 넘길 것:

- 생성 파일 제외는 **사용 프로젝트의 옵션 파일에 직접 적으라고 안내한다.** 3.13.x 에서는 plugin 진단 때문에, 베타에서는 규칙 진단까지 그렇다. 두 SDK 에서 모두 통하는 방법은 이것 하나다. `flutter_starter_kit` 은 이미 그렇게 적어 두었다 (2026-10-12 읽음).
- "프리셋의 제외가 통하지 않는다" 를 굳은 사실로 적지 않는다. 상류에서 버그로 다루고 있으므로 "SDK 버전에 따라 다르다" 로 적고 sdk#64549 를 가리킨다.
- `flutter analyze` 에 대한 문장은 "Flutter 3.47.5 에서는 plugin 진단을 내지 않는다" 까지만 단정한다. 베타에서는 내지만 규칙 진단이 겹쳐 찍혔다.

SDK 를 올릴 때 (Phase 6 이후) 다시 볼 것:

- `.fvmrc` 를 Dart 3.14 계열로 올리기 전에 이 spike 의 두 스크립트를 그 SDK 로 한 번 돌린다. `probe.dart` 의 `≠` 10칸 중 8칸이 생성 파일 제외에서 온 것이고, 2칸(R1 · R2)은 plugin 을 적는 자리의 변경(sdk#63627)에서 온 것이다. 그 8칸이 `=` 로 돌아오면 되돌리는 변경이 들어간 것이고 (R1 · R2 는 다른 변경에서 온 것이라 `≠` 로 남을 것이다), 지금처럼 10칸이면 정답지 셋을 갱신하고 CHANGELOG 에 "SDK 가 바뀌어 생긴 줄" 로 적는다. (2026-10-12 wrap-up 에서 고침 — 처음에는 "`≠` 가 0칸이면" 이라고 적었다.)
- 고정 SDK 를 올리지 않아도, Flutter 버전을 고정하지 않은 사용 프로젝트는 정식 버전이 나오는 날 이 동작을 먼저 겪는다. 학습용 프로젝트 넷은 코드 생성을 쓰지 않아(03-CONTEXT.md D-08 의 확인) 생성 파일 4줄과는 무관하다.

spike 011 · 012 의 결론에서 달라지는 것: 없다 (둘 다 3.13.4 의 사실로 맞다). 범위가 생겼다 — "루트 분석이 plugin 을 준비하지 않는다" (011) 와 "프리셋의 제외는 규칙 진단에 통한다" (012) 는 Dart 3.13.x 에 한한 말이다.

확인하지 않은 것:

- Dart 3.14 정식 버전. 베타 하나(`3.14.0-211.1.beta`)에서 쟀다. 되돌리는 변경(CL 562741)이 들어간 빌드는 없었다.
- 되돌리는 변경이 pub.dev 의 `analyzer` 로 나온 뒤 plugin 쪽의 동작. 그때는 프리셋의 제외가 plugin 진단에도 통하게 될 수 있다 (추정).
- 끄는 방법 여섯 칸(spike 012 의 1 · 2부)을 베타에서. 이 spike 는 제외만 다시 쟀다.
- 베타에서 루트 분석이 준비한 plugin 이 `lib/` 아래의 Dart 파일을 실제로 보는지. 이 패키지의 `lib/` 에는 Dart 파일이 없다.
- 베타의 루트 분석에서 plugin 준비가 실패했을 때(네트워크 없음)의 종료 코드와 stderr.
- 베타의 `flutter analyze` 가 규칙 진단을 겹쳐 세는 원인.
- `tool/verify.dart` 자체를 베타로 돌린 것. SDK 확인 단계가 종료 코드 78 로 막는다 (설계대로).
- git 의존성으로 받은 경우를 베타에서. spike 015 가 3.13.4 에서 "`path:` 와 줄 단위로 같다" 를 봤다.
- GitHub Linux runner 에서의 같은 실행.

원본: `results/probe-<Dart 버전>.{log,json}`, `results/root-<Dart 버전>.{log,json}`, `results/flutter-analyze-<Flutter 버전>.log`. 이름 끝이 `-run1` 인 것이 첫 실행이고, `-attempt1` 은 `sky_engine` 이 없어 멈춘 실행이다.
