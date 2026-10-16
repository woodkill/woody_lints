---
phase: 06-release
reviewed: 2026-10-16T05:16:21Z
depth: standard
files_reviewed: 14
files_reviewed_list:
  - .github/workflows/verify.yml
  - CHANGELOG.md
  - README.md
  - VERSIONING.md
  - example/README.md
  - example/pubspec.lock
  - fixtures/base_codegen/pubspec.lock
  - fixtures/base_only/pubspec.lock
  - fixtures/base_riverpod/pubspec.lock
  - fixtures/overrides/pubspec.lock
  - fixtures/recommended/pubspec.lock
  - pubspec.yaml
  - tool/smoke.dart
  - tool/verify.dart
findings:
  critical: 1
  warning: 3
  info: 3
  total: 7
status: issues_found
---

# Phase 6: Code Review Report

**Reviewed:** 2026-10-16T05:16:21Z
**Depth:** standard
**Files Reviewed:** 14
**Status:** issues_found

## Summary

범위는 `git diff d926186..HEAD` 의 14개 파일이다. 중심은 `tool/verify.dart` 의 `[3/10]` 확인 (i) (`checkVersionAgreement` · `pubspecVersionText` · `changelogTop` · `--tag` 인자 · `GITHUB_REF_TYPE` / `GITHUB_REF_NAME` · stderr 모드 줄), IN-12 의 `keysSeenByLineReader` 고침, 새 파일 `tool/smoke.dart` 전체다. lock 여섯은 `woody_lints` 항목의 `version` 한 줄(`2.0.0-dev` → `2.0.0`)만 바뀌어 `pubspec.yaml` 과 맞다. `pubspec.yaml` 13행 주석 · `verify.yml` 7행 주석 · CHANGELOG 날짜도 결정(D-04 · D-13 · IN-13)대로다.

실험은 모두 `git archive HEAD` 로 만든 복사본에서 했다. `tool/verify.dart` 를 import 하는 탐침 파일로 함수를 직접 불렀고, 필요한 경우 전체 실행까지 했다. 작업 트리는 건드리지 않았고 복사본은 끝에 지웠다. `tool/smoke.dart` 자체는 돌리지 않았다(네트워크). WR-01 의 진단은 연습용 프로젝트 `fixtures/recommended` 복사본에서 `dart analyze` 로 확인했다.

가장 무거운 것은 CR-01 이다. tag 모드는 `pubspec.yaml` 의 version 을 꼬리까지 정확히 견주는데, 그 원문을 읽는 줄 단위 reader 를 YAML 이 읽은 값과 견주는 확인이 없다. (h) 는 꼬리를 뗀 값만 견준다. 그래서 YAML(=pub)이 `2.0.0-dev` 로 읽는 `pubspec.yaml` 에서 `verify.dart --tag v2.0.0` 이 끝까지 통과했다(종료 코드 0, `점검 통과 (10개 중 10개)`). 지금 HEAD 의 파일은 이 꼴이 아니다 — YAML · 줄 단위 reader 둘 다 `2.0.0` 이고, 이미 올린 `v2.0.0` 은 이 결함의 영향을 받지 않았다.

## Critical Issues

### CR-01: tag 모드가 정확히 견주는 version 원문을 YAML 과 견주는 확인이 없어, `-dev` 가 남은 pubspec 이 `--tag` 검사를 통과한다

**File:** `tool/verify.dart:1633-1647` (`pubspecVersionText`), `tool/verify.dart:2169-2183` ((h) 의 `pubspec.yaml` version 비교), `tool/verify.dart:2236-2243` (tag 모드의 `text != tagVersion`)
**Issue:** tag 모드(D-04 (2) · (3))는 `pubspecVersionText` 가 돌려준 원문을 tag 의 버전과 꼬리 없이 정확히 견준다. 그런데 이 reader 는 열 0 에서 `version:` 으로 시작하는 첫 줄을 잡는 줄 단위 reader 이고, YAML 과의 대조는 (h) 의 `pubspecReleaseVersion ↔ version` 뿐이다. 이 비교는 양쪽 다 `major.minor.patch` 만 남기고 견주므로 꼬리 차이(`-dev`)를 보지 못한다. 그래서 "줄 단위 reader 는 `2.0.0`, YAML 은 `2.0.0-dev`" 인 파일에서 (h) 와 (i) 가 함께 통과한다.

재현(복사본, 2026-10-16) — `pubspec.yaml` 2 ~ 5행을 아래처럼 바꿨다 (겹따옴표 여러 줄 스칼라 안에 열 0 의 `version:` 줄이 든다):

```yaml
description: "Woody's custom lint rules for Flutter projects.
version: 2.0.0
  end"
version: 2.0.0-dev
```

- `loadYaml` 의 `version` = `2.0.0-dev`, `pubspecVersionText` = `2.0.0`, `pubspecReleaseVersion` = `2.0.0`
- `compareLineReadersWithYaml` = 블록 없음, `checkVersionAgreement(tag: 'v2.0.0')` = 블록 없음
- lock 여섯을 `fvm dart pub get` 으로 다시 받은 뒤(모두 `version: "2.0.0-dev"` 로 바뀜) 돌린 전체 실행 `fvm dart run tool/verify.dart --tag v2.0.0` 은 종료 코드 0, `점검 통과 (10개 중 10개)` 였고 stderr 는 `버전 일치 검사: tag v2.0.0 (--tag)` 였다

릴리스 gate 의 거짓 통과다. 같은 일이 CI 의 tag 실행(`GITHUB_REF_NAME`)에서도 생긴다. 앞 phase 들에서 gap 이 된 "여러 줄 스칼라 안의 줄" 과 같은 꼴이다. (h) 는 phase 5 에서 (g) 를 위해 꼬리 뗀 값만 견주도록 만든 것이다. 이번 phase 에서 그 원문을 정확히 견주는 소비자 (i) 가 생겼으므로 그 전제가 깨졌다. `example/README.md` 621행의 (h) 설명도 `pubspecReleaseVersion ↔ version` 만 적고 있다.
**Fix:** (h) 의 `pubspec.yaml` 비교를 원문 기준으로 바꾼다. 그러면 꼬리 뗀 값의 일치는 그 결과로 따라온다.

```dart
  final pubspec = load('pubspec.yaml');
  if (pubspec != null) {
    final lineReader = pubspecVersionText(repoRoot); // 원문 (꼬리 포함)
    final root = pubspec.root;
    final version = root is YamlMap ? root['version'] : null;
    final yaml = version == null ? '(없음)' : '$version';
    if (yaml != lineReader) {
      addValueBlock(
        '`pubspec.yaml` 의 version — $disagree (pubspecVersionText ↔ version)',
        lineReader,
        yaml,
      );
    }
  }
```

(또는 (i) 의 tag 모드가 `pubspecVersionText` 대신 YAML 의 `version` 을 직접 쓰게 한다.) `example/README.md` 의 (h) 설명과 M 기록에 이 입력을 한 줄 더한다.

## Warnings

### WR-01: smoke 가 include 사슬의 끊김(`include_file_not_found`)을 보고도 통과한다 — 두 주소의 codegen 부분은 판정에 없다

**File:** `tool/smoke.dart:497-518` (`judge`)
**Issue:** 판정은 위반 파일의 `prefer_single_quotes` (base) 와 `provider_parameters` (riverpod) 두 줄만 찾는다. 두 주소(`recommended.yaml` · 옛 주소 `analysis_options.yaml`)는 모두 `lib/recommended.yaml` 을 거쳐 조각 셋을 받는다. 그 가운데 `codegen.yaml` 이 풀리지 않아도 위 두 줄은 그대로 나온다. 복사본에서 `lib/recommended.yaml` 의 셋째 include 를 없는 파일로 바꾸고 `fixtures/recommended` 를 분석해 보았다. JSON 에 `analysis_options.yaml` 의 `WARNING include_file_not_found` 가 나왔고, 다른 진단은 그대로였다. smoke 는 이 줄을 화면에 찍기만 하고 실패로 보지 않는다. 그러니 "옛 주소가 기본 + Riverpod + codegen 뜻을 유지한다" (CLAUDE.md Compatibility) 의 codegen 부분이 받는 쪽에서 깨져도 smoke 는 통과한다. 같은 커밋의 `verify.dart` `[5/10]` 이후 단계가 정답지 비교로 이를 잡기는 한다. 하지만 smoke 는 "GitHub 에서 받은 그대로" 를 보는 gate 이고, 실패 신호가 출력에 이미 있는데도 버려진다.
**Fix:** 판정 (c) 앞에 include 오류 줄이 없는지 보는 조건을 더한다. 템플릿이 내는 다른 진단과 섞이지 않게 코드 이름으로 좁힌다.

```dart
  const includeErrors = {'include_file_not_found', 'included_file_warning'};
  for (final line in lines) {
    final code = line.split('  ').last;
    if (line.startsWith('analysis_options.yaml:') && includeErrors.contains(code)) {
      reasons.add('${outcome.name}: include 사슬이 끊겼다 ($line)');
    }
  }
```

### WR-02: `changelogTop` 이 들여 쓴 ATX 제목 · setext 제목 · U+FEFF 머리를 제목으로 보지 않아, 평소 모드가 아래의 옛 항목과 견주어 통과한다

**File:** `tool/verify.dart:1657-1677`
**Issue:** 최상단 제목은 "`## ` 로 시작하는 첫 줄" 이다. Markdown 에서는 앞에 공백 1 ~ 3칸을 둔 ` ## 2.1.0 - 미출시` 도 h2 이고, `2.1.0 - 미출시` 아래 `---` 줄을 둔 setext 꼴도 h2 다. reader 는 이런 제목을 건너뛰고 그 아래 옛 항목(`## 2.0.0 - 2026-10-15`)을 최상단으로 읽는다. 복사본에서 CHANGELOG 맨 앞에 ` ## 2.1.0 - 미출시` 와 빈 줄을 넣고 `pubspec.yaml` 은 `2.0.0` 으로 두었다. 이 상태에서 평소 모드와 `--tag v2.0.0` 이 모두 블록 없이 통과했다. 실제 최상단은 2.1.0 이므로, D-04 (1) 의 "준비 중의 어긋남을 평소 push 에서 잡는다" 가 이 입력에서 뒤집힌다(거짓 통과). 다만 tag 모드에서 새 tag(`v2.1.0`)로 돌리면 옛 버전을 읽어 실패하므로 릴리스 gate 는 뚫리지 않는다. 파일 맨 앞의 U+FEFF 는 반대로 첫 줄을 놓쳐 거짓 실패나 같은 거짓 통과를 낸다.
**Fix:** 제목 후보를 넓게 잡은 뒤, 첫 후보가 엄격한 꼴이 아니면 실패로 알린다. 조용히 건너뛰지 않는다.

```dart
  final text = File('$repoRoot/$changelogFile').readAsStringSync()
      .replaceFirst('\uFEFF', '');
  final lines = splitYamlLines(text);
  // 공백 0 ~ 3칸 + `#` 하나 이상 + 공백 — 첫 제목 꼴의 줄 (h1 은 건너뛴다)
  final anyHeading = RegExp(r'^ {0,3}#{2,6}[ \t]');
  final idx = lines.indexWhere(anyHeading.hasMatch);
  if (idx < 0 || !lines[idx].startsWith('## ')) {
    throw FormatException('CHANGELOG.md 의 첫 제목이 `## X.Y.Z - …` 꼴이 아니다: ${idx < 0 ? '(없음)' : lines[idx]}');
  }
  // setext: 다음 줄이 `---` 면 그 앞 줄도 제목이다 — 첫 `## ` 줄보다 앞에 있으면 실패로 알린다.
```

### WR-03: smoke 의 하위 명령에 시간 제한이 없어, 받기 · plugin 준비가 멈추면 끝없이 기다린다

**File:** `tool/smoke.dart:274-289` (`runProcess`), `:596-608`, `:622-627`, `:467-475`
**Issue:** `Process.run` 을 시간 제한 없이 부른다. `flutter pub get` (GitHub clone) 이나 `dart analyze` 안의 plugin 준비(pub.dev)가 네트워크 문제로 멈추면 스크립트도 멈춘다. 그러면 사람이 끊어야 하고, 이때 임시 폴더(새 pub cache 포함)가 남는다(IN-01). orchestrator 메모에도 "받기 단계가 5분 넘게 멈추면 네트워크 문제로 보고 중단" 이 있다. 이 판단이 사람 몫으로 남아 있다는 뜻이다. 머리 주석의 종료 코드 목록에도 이 경우가 없다.
**Fix:** `Process.start` + `.timeout(...)` 으로 단계마다 제한을 둔다(예: create 2분, pub get 5분, analyze 5분). 넘으면 프로세스를 `kill` 하고 69 로 끝낸 뒤 임시 폴더를 지운다. 종료 코드 표에 "시간 초과 → 69" 를 적는다.

## Info

### IN-01: smoke 의 임시 폴더 정리가 `finally` 밖이라, 세 예외 밖의 throw · 중단 신호에서 폴더가 남는다

**File:** `tool/smoke.dart:724-760`
**Issue:** `main` 은 `FormatException` · `FileSystemException` · `ProcessException` 만 받는다. 정리는 그 뒤 일반 흐름에 있다. 그 밖의 throw(`StateError` · `TypeError` 등)나 Ctrl-C(SIGINT)에서는 정리를 지나쳐, 새 pub cache 와 받은 저장소가 든 임시 폴더가 시스템 임시 폴더에 남는다. 앞의 경우는 종료 코드도 머리 주석의 "70 예외로 끝남" 이 아니라 255 다.
**Fix:** 정리를 `try { … } finally { … }` 로 옮기고, `ProcessSignal.sigint.watch()` 에서 같은 정리를 한 뒤 끝낸다.

### IN-02: `runSmoke` 가 `judge` 의 앞 두 조건을 다시 적는다

**File:** `tool/smoke.dart:672-675` (`judge` 의 `:498-505` 와 같은 조건)
**Issue:** 판정 줄을 고를 때 `hasPluginHeader || lines == null || !analyzeExitCodes.contains(exitCode)` 를 다시 쓴다. 그리고 `found.first.substring(target.name.length + 2)` 로 `judge` 가 만든 문구의 머리 길이에 기댄다. 한쪽 조건이나 문구 꼴만 바뀌면 `found.first` 가 빈 목록에서 `StateError` 를 내거나 문구가 잘린다(DRY).
**Fix:** `judge` 가 `(fatal: bool, reasons: List<String>)` 또는 사유와 표시 문구를 함께 돌려주게 하고, `runSmoke` 는 그 값만 쓴다.

### IN-03: `pubspecVersionText` 가 `pubspecReleaseVersion` 의 줄 찾기를 따로 다시 짠다

**File:** `tool/verify.dart:1606-1647`
**Issue:** 같은 `versionLine` 정규식 · `splitYamlLines` 순회를 두 함수가 따로 가진다. 빈 값 처리도 다르다(한쪽은 `break` 뒤 throw, 다른 쪽은 꼴 검사 실패로 throw). 두 reader 의 뜻이 갈라질 자리가 둘로 늘었고, CR-01 도 "꼬리 뗀 값만 YAML 과 견준 reader" 와 "원문을 쓰는 reader" 가 갈라진 데서 생겼다.
**Fix:** `pubspecReleaseVersion` 을 `pubspecVersionText` 위에 짠다 — 원문을 받은 뒤 `^(\d+\.\d+\.\d+)(?:[-+].*)?$` 로 머리만 떼게 한다. 그러면 reader 는 하나이고, CR-01 의 고침 하나로 두 쪽이 모두 YAML 과 맞춰진다.

---

_Reviewed: 2026-10-16T05:16:21Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
