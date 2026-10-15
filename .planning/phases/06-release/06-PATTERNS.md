# Phase 6: Release - Pattern Map

**Mapped:** 2026-10-15
**Files analyzed:** 15 (새 파일 1 · 고치는 파일 13 · 원격 ref 1)
**Analogs found:** 14 / 15 (exact 10 · role-match 4 · 없음 1)

이 phase 의 새 코드는 둘뿐이다 — `tool/verify.dart` `[3/10]` 안의 **버전 일치 확인 (i)** 와 새 파일 **`tool/smoke.dart`**. 나머지는 릴리스 커밋(version · CHANGELOG 날짜 · lock 여섯 · IN-13 주석), 문서 손질(README · `example/README.md` · `VERSIONING.md` 새 절), 처리 기록 갱신, 그리고 사람 확인이 끼는 원격 작업(tag push · PR 병합)이다. 그래서 analog 는 대부분 **고치는 파일 자신 또는 같은 파일의 이웃 함수 · 이웃 절**이고, `tool/smoke.dart` 만 다른 파일(spike 015 `probe.dart` 와 `tool/verify.dart` 의 subprocess 함수들)에서 옮긴다. 모든 analog 경로는 `git ls-files` 로 추적을 확인했다 (2026-10-15, 18개 모두 출력됨). 경로는 모두 저장소 루트 기준이다. 비공개 사용 프로젝트의 경로 · 기능 이름은 넣지 않았다 (04-CONTEXT D-07 · 05-CONTEXT D-21).

줄 번호는 HEAD `33ab771` 기준이다. `tool/verify.dart` 는 2,927행이며 이 문서가 인용한 범위는 1 ~ 52 · 465 ~ 512 · 526 ~ 621 · 640 ~ 707 · 1583 ~ 1614 · 1866 ~ 1912 · 1985 ~ 1992 · 2135 ~ 2150 · 2457 ~ 2508 · 2541 ~ 2560 · 2754 ~ 2777 · 2802 ~ 2927 행이다. 06-RESEARCH.md 의 prototype (§ Code Examples) 이 이미 복제본에서 D-06 다섯 입력을 통과 · 실패시켰으므로, 이 문서는 "그 prototype 을 저장소의 어떤 꼴에 맞춰 옮기는가" 를 적는다.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `tool/verify.dart` — 새 reader `pubspecVersionText` · `changelogTop` | utility (값 읽기) | file-I/O → 문자열 | 같은 파일 `pubspecReleaseVersion` 1597-1614 (`splitYamlLines` 로 한 줄씩 · `unquotedScalar` · 못 읽으면 `FormatException`) | exact |
| `tool/verify.dart` — `[3/10]` (i) 버전 일치 확인 (REL-03) | utility (검증 단계 안의 블록) | file-I/O → 비교 | 같은 함수 (g) 2457-2498 (`addBlock` 머리 줄 + 들여 쓴 값 + 빈 줄 + 안내 줄) · (h) 호출 2500-2501 (넣을 자리) | exact |
| `tool/verify.dart` — `main` 의 `--tag` 인자 · CI 환경변수 · stderr 모드 줄 | config (인자 읽기) | request-response (인자 → 종료 코드) | 같은 파일 `main` 2807-2814 (`unknown` → `quit(64)`), 2824-2828 (`Platform.environment` 의 CI 판별) | exact |
| `tool/verify.dart` — `keysSeenByLineReader` (IN-12) | utility (전처리) | transform | 자기 자신 1879-1912 + 06-RESEARCH.md § Code Examples 의 diff (8줄 추가 · 1줄 삭제, 함수 단위로 확인됨) | exact |
| `tool/verify.dart` — 머리 주석 종료 코드 목록 (25-26) · `compareLineReadersWithYaml` 문서 주석 (1986) · 6 · 11행 사용법 (IN-14 · (i) 설명) | 문서 주석 | — | 자기 자신 (고칠 문장은 06-RESEARCH.md § 6 표에 있다) | exact |
| `tool/smoke.dart` (새 파일, REL-04) | script (실측 도구) | 프로세스 실행 → 파일 읽기 → 판정 | spike 015 `.claude/skills/spike-findings-woody-lints/sources/015-git-dependency-preset-load/probe.dart` 의 `Consumer` (36-120) · `git()` (125-142) · `pub()` 기록 (173-198); `tool/verify.dart` 의 `readFlutterVersion` 532-545 · `runPubGet` 598-621 · `analyzeFixture` 688-707 · `pluginFolders` · `readPluginVersion` 641-672 · `normalizeDiagnostics` 470-504 · `quit` 508-512 · 머리 주석 1-33 | role-match (저장소에 "밖에서 받아 오는" 스크립트는 없다 — spike 가 로컬 git 으로 잰 것을 GitHub 주소 · `flutter create` 로 바꾼다) |
| `pubspec.yaml` — `version:` 3행 · 13-15행 주석 (IN-13) | config (매니페스트) | — | 자기 자신 (13-15행 주석의 꼴은 그대로, 파일 이름만 `lib/base.yaml` 로) | exact |
| `CHANGELOG.md` — 1행 `## 2.0.0 - 미출시` → 날짜 | 문서 | — | `VERSIONING.md` 81-82 (제목 형식 · ` - ` 한 번) · 같은 파일의 옛 제목 꼴 | exact |
| `README.md` — 34 · 355 · 381행, 「설치」 29행 뒤 · 「프로젝트 전체」 222행 · 「생성 파일 제외」 284행의 한 문장씩 (UAT 2 · 4, D-11, D-14) | 문서 (검사 `[3/10]` (d) ~ (g) 가 읽는 파일) | — | 같은 파일의 이웃 산문 — 33행 (출처 · "추론" 표시 문장), 27행 (`resolved-ref` 설명), 357행 ("읽은 것 — … 이 자리에서 잰 것은 아니다") | exact |
| `VERSIONING.md` — 새 절 `## 릴리스 절차` (끝, 126행 뒤) · 82행 현재형 | 문서 (절차) | — | 같은 파일 「CHANGELOG 항목 형식」 77-101 (번호 없는 불릿 + 이유 문장 + 펜스 예시) · 06-RESEARCH.md § 7 의 10단계 뼈대 | role-match (번호 붙은 절차 절은 이 저장소에 없다 — README 「이 저장소를 고치는 사람에게」 376-382 가 가장 가깝다) |
| `example/README.md` — 116행 `[3/10]` 설명 끝에 (i), 종료 코드 표 (107-114) 의 64 · 70 · 새 255 행, 620행 (UAT 5 · IN-14), 새 소절 `### 추가 실측 — … (06-NN)` M92 ~ M97 | 문서 (지워 보기 기록) | — | 같은 파일 594-629 의 05-14 소절 (실측 조건 줄 · "실행한 명령" 문단 · 6열 표 · 함수 단위 기록 꼴 · 회귀 불릿 · "읽는 법" · 되돌림 확인 · 걸린 시간) | exact |
| `example/pubspec.lock`, `fixtures/{base_codegen,base_only,base_riverpod,overrides,recommended}/pubspec.lock` | 생성 파일 (lock) | — | 자기 자신 267-273 — `fvm dart pub get` 이 `version: "2.0.0-dev"` 한 줄만 바꾼다 (06-RESEARCH.md § 5 실측) | exact |
| `.planning/phases/02-verification-harness/02-UAT.md` 4 · 6번, `.planning/phases/05-documentation/05-UAT.md` 1 · 2 · 4 · 5번, `.planning/phases/05-documentation/05-REVIEW-DISPOSITION.md` IN-12 ~ 14 행 | planning 데이터 (처리 기록) | — | `05-REVIEW-DISPOSITION.md` 의 `fixed` 행 꼴 (WR-15 행: `05-14-PLAN.md Task 1 (77e0b88) — …`), `05-UAT.md` Deferred Follow-Ups 의 `moved_to` 항목 (71-91) | exact |
| 원격 ref — annotated tag `v2.0.0`, PR → `main` merge commit (REL-02) | 원격 상태 (git ref) | one-way 쓰기 | `.planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md` 93-102 (시각 순서 표) · 345-375 (push 출력 + `ls-remote` 원문 + 읽는 법) | exact |
| push 전 비공개 점검 (D-21) | 점검 명령 | — | `.planning/phases/05-documentation/05-05-PLAN.md` 90행 Task 1 `<automated>` (아래에 원문 인용) | exact |
| `.github/workflows/verify.yml` 5-7행 주석 (선택) | config (CI) | — | 자기 자신 — 고치지 않아도 된다 (06-RESEARCH.md § 1). 고친다면 주석 한 줄을 현재형으로 | 없음 (코드 변경 없음) |

## Pattern Assignments

### `tool/verify.dart` — 새 reader `pubspecVersionText` · `changelogTop`

**Analog:** 같은 파일 `pubspecReleaseVersion` (1597-1614). 06-RESEARCH.md § Code Examples 의 prototype 두 함수가 이 꼴을 이미 따르고 있다 — 그대로 옮기되 문서 주석을 아래 1589-1596 의 꼴(무엇을 돌려주는지 · 따옴표 · 줄 끝 주석 · `splitYamlLines` 를 쓰는 이유 · 못 읽으면 70)로 쓴다.

**따를 꼴** (1589-1614):
```dart
/// `pubspec.yaml` 의 `version:` 에서 `major.minor.patch` 만 돌려준다 (`2.0.0-dev` → `2.0.0`).
///
/// `-pre` · `+build` 꼬리는 떨어진다. 값의 바깥 따옴표(`version: "2.0.0-dev"`)와 줄 끝
/// `# 주석` 은 벗겨 읽는다 — YAML 에서 따옴표 값은 같은 값이다 (05-REVIEW.md IN-01,
/// [unquotedScalar]). …
/// 읽지 못하면 [FormatException] (main 이 종료 코드 70 으로 끝낸다).
String pubspecReleaseVersion(String repoRoot) {
  final versionLine = RegExp(r'^version:[ \t]*(.*?)(?:[ \t]+#.*)?[ \t]*$');
  final lines = splitYamlLines(
    File('$repoRoot/pubspec.yaml').readAsStringSync(),
  );
  String? raw;
  for (final line in lines) {
    raw = versionLine.firstMatch(line)?.group(1);
    if (raw != null) break;
  }
  final match = raw == null
      ? null
      : RegExp(r'^(\d+\.\d+\.\d+)(?:[-+].*)?$').firstMatch(unquotedScalar(raw));
  if (match == null) {
    throw const FormatException('pubspec.yaml 에서 version: 을 읽지 못했다');
  }
  return match.group(1)!;
}
```

**지킬 것:**
- `pubspecReleaseVersion` 의 **동작은 바꾸지 않는다** — (h) 가 이 값을 YAML 과 견주고 M87 이 그 동작을 기록한다 (06-RESEARCH.md § 1). `pubspecVersionText` 는 같은 `versionLine` 정규식 + `unquotedScalar` 로 원문(`2.0.0-dev`)을 돌려주는 별도 함수다.
- `changelogTop` 은 `splitYamlLines` (836행 `const LineSplitter().convert`) 로 나눠 첫 `## ` 줄을 잡는다 — CR 줄 나누기 처리를 공짜로 얻는다. ` - ` 가 없으면 `FormatException('CHANGELOG.md 최상단 제목에 ` - ` 가 없다: $heading')` 처럼 **파일 이름과 원문을 문구에 넣는다** (05-PATTERNS 의 "예외 문구에는 파일 이름" 과 같은 규칙, `example/README.md` 113행의 70 설명에 그 경우를 더한다).
- 돌려주는 꼴은 record `({String version, String dateSlot})` — 1878행 `({List<String> topLevel, Map<String, List<String>> children})` 처럼 이 파일이 이미 record 반환을 쓴다.

---

### `tool/verify.dart` — `[3/10]` (i) 버전 일치 확인

**Analog:** 같은 함수 (g) 2457-2498 의 블록 꼴과 (h) 호출 자리 2500-2501. 넣을 자리는 2501행과 2503행 `return StepResult(` 사이다.

**블록 꼴** (2486-2497 — 머리 줄 · 들여 쓴 값 · 빈 줄 · 안내 줄):
```dart
  if (refs.isEmpty && unreadableRefs.isEmpty) {
    addBlock(['`$readmeFile` 의 코드 블록에 `ref: vX.Y.Z` 줄이 하나도 없다.']);
  } else {
    final wrong = refs.where((v) => v != release).toSet().toList()..sort();
    if (wrong.isNotEmpty) {
      addBlock([
        '`$readmeFile` 의 `ref: vX.Y.Z` 예시가 `pubspec.yaml` 의 version ($release) 과 다르다:',
        ...wrong.map((v) => '  ref: v$v'),
        '',
        '릴리스 버전을 올릴 때 `$readmeFile` 의 `ref:` 예시도 같은 커밋에서 고친다.',
      ]);
    }
  }

  // (h) 줄 단위 reader 가 읽은 값 == YAML 이 읽은 값 (05-VERIFICATION.md 4회차 gap, 소유자 결정 G4-Q1).
  compareLineReadersWithYaml(repoRoot).forEach(addBlock);

  return StepResult(
    label: shippedCompositionLabel,
    passed: details.isEmpty,
    detailLines: details,
  );
```

**옮길 것:** 06-RESEARCH.md prototype `checkVersionAgreement` 의 `out.add('…')` 한 줄들을 각각 `addBlock([머리 줄, '', 안내 줄])` 로 바꾼다. 주석은 (g) 2457-2460 처럼 `// (i) tag · pubspec.yaml 의 version · CHANGELOG 최상단 버전 (D-04 · D-05). …` 로 시작하고 출처(06-CONTEXT D-04 ~ D-06)를 괄호에 적는다. 안내 줄 예: `'릴리스 커밋에서 `-dev` 를 떼고 CHANGELOG 제목의 `미출시` 를 날짜로 바꾼다 — VERSIONING.md 「릴리스 절차」.'`

**서명:** `checkShippedComposition(String repoRoot)` 2145행에 이름 있는 선택 인자 `{String? tag}` 를 더한다. 기존 호출(`main` 2849행, `example/README.md` 가 적은 함수 단위 하네스)은 그대로 동작한다 (06-RESEARCH.md Open Questions 2).

**문서 주석:** 2140-2142 의 (g) · (h) 줄 뒤에 (i) 한 줄을 같은 꼴로 — `/// - (i) tag 가 없으면 [pubspecReleaseVersion] == CHANGELOG 최상단 버전 ([changelogTop]); tag 가 있으면 `^v(\d+\.\d+\.\d+)$` 꼴 · [pubspecVersionText] 와 꼬리 없이 정확히 · CHANGELOG 버전 · 날짜 자리 `YYYY-MM-DD` (REL-03, 06-CONTEXT.md D-04 ~ D-06)`. 2144행처럼 "보지 않는 것" (README 의 `ref:` 는 (g) 가 본다, tag 날짜와의 일치는 보지 않는다) 을 한 문단 더한다.

---

### `tool/verify.dart` — `main` 의 `--tag` 인자 · CI 환경변수 · stderr 모드 줄

**Analog:** `main` 2807-2814 (인자 검사) · 2824-2828 (환경변수).

**지금 코드** (2807-2814):
```dart
Future<void> main(List<String> args) async {
  final unknown = args.where((a) => a != '--update').toList();
  if (unknown.isNotEmpty) {
    stderr.writeln('모르는 인자: ${unknown.join(' ')}');
    stderr.writeln('사용법: $runCommand [--update]');
    await quit(64);
  }
  final update = args.contains('--update');
```

**고칠 꼴:** `--tag <값>` 둘을 인자 목록에서 먼저 떼어 낸 뒤 나머지를 `unknown` 으로 본다. `--tag` 가 마지막이라 값이 없으면 같은 `사용법:` 줄과 `quit(64)` (06-RESEARCH.md Validation — `--tag` 값 없음 rc 64). 사용법 줄은 `'사용법: $runCommand [--update] [--tag vX.Y.Z]'` 로, 머리 주석 11행 `// 실행: fvm dart run tool/verify.dart [--update]` 도 같은 글자로 고친다 (`runCommand` 233행은 그대로).

**환경변수** (2824-2825 의 꼴을 그대로):
```dart
    final env = Platform.environment;
    if (update && (env['CI'] == 'true' || env['GITHUB_ACTIONS'] == 'true')) {
```
→ 같은 `env` 로 `final ciTag = env['GITHUB_REF_TYPE'] == 'tag' ? env['GITHUB_REF_NAME'] : null;` 와 `final effectiveTag = tagArg ?? ciTag;` (인자가 우선 — 06-RESEARCH.md § 1 권고).

**모드 줄은 stderr 로:** 2802-2806 의 문서 주석이 "화면은 전부 stdout 이고 첫 줄은 늘 `SDK` 줄, 준비 단계의 안내 · 진행 표시는 stderr" 라고 못 박는다. 모드 줄 `버전 일치 검사: 평소 (pubspec 꼬리 뗀 값 ↔ CHANGELOG)` / `버전 일치 검사: tag v2.0.0 (--tag)` / `(GITHUB_REF_NAME)` 는 **stderr** 에 찍는다 (06-RESEARCH.md Pattern 2 · Pitfall 2 — CI 로그에서 tag 모드가 돌았는지 가르는 유일한 줄). stdout 의 첫 줄이 `SDK` 가 아니게 되면 05-05-PLAN 의 `<automated>` 류 단언(`점검 통과` grep)은 살아도 "첫 줄은 SDK" 문서 주석이 거짓이 된다.

---

### `tool/verify.dart` — `keysSeenByLineReader` (IN-12)

**Analog:** 자기 자신 1879-1912. 고친 판은 06-RESEARCH.md § Code Examples 의 diff 그대로다 (함수 단위로 IN-12 입력 통과 · M78 회귀 유지 확인됨).

**지금 코드** (1884 · 1901-1910):
```dart
  final listItemPattern = RegExp(r'^-(?:[ \t]|$)');
  …
  for (final MapEntry(key: parent, value: lines) in nested.entries) {
    for (final shown in lines) {
      final text = textOf(shown).trim();
      if (listItemPattern.hasMatch(text)) continue;
      children
          .putIfAbsent(parent, () => [])
          .add(keyPattern.firstMatch(text)?.group(1) ?? text);
    }
  }
```

**고칠 꼴:** `listItemPattern` 아래에 `keyLikePattern` (`^(?:"[^"]*"|'[^']*'|[^\s#'"][^#]*?)[ \t]*:(?:[ \t]|$)`) 을 더하고 `if (listItemPattern.hasMatch(text) || !keyLikePattern.hasMatch(text)) { continue; }`. 주석은 이 파일의 관례대로 **왜**를 적는다 — "`package:…` 처럼 콜론 뒤에 공백 · 줄 끝이 없는 스칼라 값 줄은 키가 아니다 (05-REVIEW.md IN-12)". 문서 주석 1874-1875 의 "줄이 키 꼴(`<이름>:`)이면 키 이름을, 아니면 원문을 담는다" 를 "아래 줄은 키 꼴일 때만 담는다" 로.

**지킬 것:** `keyPattern` (1880) 과 `valueLessKeyPattern` (1881-1883) 은 건드리지 않는다 — M78 의 (h) 블록(`줄 단위 reader 에만: "zz_quoted_plugin": ^0.1.0`)이 그대로여야 한다. 따옴표 키는 `keyLikePattern` 이 받으므로 원문 그대로 담긴다.

---

### `tool/verify.dart` — 주석 · 문장만 고치는 자리 (IN-14, (i) 설명)

**Analog:** 자기 자신. 고칠 글자는 06-RESEARCH.md § 6 표에 있다.

**종료 코드 목록** (25-26):
```dart
// 종료 코드: 0 모두 통과 / 1 단계 실패 / 64 사용법 오류 / 69 pub get 실패 / 70 예외로 끝남
//            / 78 실행 중인 SDK 가 .fvmrc 와 다름
```
→ 같은 들여쓰기로 `/ 255 …` 한 줄을 더한다 (package:yaml 이 `YamlException` 밖의 `Error` 를 던진 경우 — main 이 받지 않는다, 05-REVIEW.md IN-14, 코드는 D-13 으로 그대로).

**`compareLineReadersWithYaml` 문서 주석** (1985-1986):
```dart
/// (같은 키 두 번, 깨진 YAML — [YamlException])은 블록 하나로 알리고 그 파일의 다른 비교는
/// 건너뛴다. [YamlException] 만 잡는다 — 그 밖의 예외는 지금처럼 main 이 받는다.
```
→ 둘째 문장을 "`FormatException` 등은 main 이 받고(70), `RangeError` 같은 `Error` 는 main 도 받지 않아 처리되지 않은 예외(255)로 끝난다 (05-REVIEW.md IN-14 — 코드는 고치지 않았다, 06-CONTEXT.md D-13)" 로. `main` 의 catch 셋 (2915-2926) 이 `FormatException` · `FileSystemException` · `ProcessException` 만 잡는 것이 그 근거다.

**6행 `[3/N]` 설명 끝**에 "tag · pubspec 의 version · CHANGELOG 최상단 버전이 같은지" 를 잇는다 (5행처럼 한 줄로 길게 쓰는 것이 이 머리 주석의 꼴).

---

### `tool/smoke.dart` (새 파일)

**Analog 1 — 받는 쪽 만들기 · lock 읽기:** spike 015 `probe.dart` 의 `Consumer` (36-120). 저장소 안 유일한 "git 의존성으로 받는 프로젝트" 코드다.

**`PUB_CACHE` 를 따로 준 pub 실행** (87-93):
```dart
  /// 이 프로젝트에서 `dart pub [args]` 를 실험용 pub cache 로 돌린다.
  Future<ProcessResult> pub(List<String> args) => Process.run(
        Platform.resolvedExecutable,
        ['pub', ...args],
        workingDirectory: dir,
        environment: {'PUB_CACHE': pubCache},
      );
```
→ smoke 는 README 의 명령 `flutter pub get` 을 쓰므로 실행 파일을 `<flutterRoot>/bin/flutter` 로 바꾼다 (아래 Analog 2 의 `readFlutterVersion`). `PUB_CACHE` 는 임시 폴더 아래 (06-CONTEXT "묻지 않고 잡은 것").

**lock 의 `woody_lints` 항목** (95-107 — `resolved-ref` · `source` · `url` 을 읽는 유일한 reader):
```dart
  /// `pubspec.lock` 의 `woody_lints` 항목 (키 → 값). 없으면 빈 map.
  Map<String, String> lockEntry() {
    final lines = File('$dir/pubspec.lock').readAsLinesSync();
    final start = lines.indexOf('  woody_lints:');
    final out = <String, String>{};
    if (start < 0) return out;
    for (final line in lines.skip(start + 1)) {
      if (!line.startsWith('    ')) break;
      final match = RegExp(r'^\s+([a-z-]+): "?([^"]*)"?$').firstMatch(line);
      if (match != null && match.group(2)!.isNotEmpty) out[match.group(1)!] = match.group(2)!;
    }
    return out;
  }
```
→ 그대로 옮긴다. 판정 (3) 은 `entry['source'] == 'git'`, `entry['url'] == 'https://github.com/woodkill/woody_lints.git'`, `entry['resolved-ref'] == <git rev-parse '<ref>^{commit}'>` (015 의 243-244 · 322-326 이 같은 비교를 했다).

**`git` 실행과 실패 처리** (125-142 — `Process.run('git', …)` 뒤 rc≠0 이면 stderr 와 `exit(69)`):
```dart
Future<String> git(Replica replica, List<String> args) async {
  final result = await Process.run('git', args, workingDirectory: replica.root, environment: {…});
  if (result.exitCode != 0) {
    stderr.writeln('git ${args.join(' ')} 실패: exit ${result.exitCode}\n'
        '${replica.scrub('${result.stderr}')}');
    exit(69);
  }
  return (result.stdout as String).trim();
}
```
→ smoke 는 커밋을 만들지 않으므로 `GIT_*` 환경변수는 빼고, 저장소 루트(`File.fromUri(Platform.script).parent.parent.path` — `verify.dart` 2817행)에서 `rev-parse '<ref>^{commit}'` 만 돌린다. `<ref>` 가 `-` 로 시작하면 64 로 거부한다 (06-RESEARCH.md Security V5).

**단계마다 한 줄 요약 + 종료 코드 · 시간 · lock 값** (179-181):
```dart
      stdout.writeln('## $id — ${consumer.name}: dart pub ${pubArgs.join(' ')}');
      stdout.writeln('   exit ${result.exitCode}, ${seconds}s, lock: source ${entry['source']}, '
          'ref ${entry['ref'] ?? '-'}, resolved-ref ${entry['resolved-ref'] ?? '-'}');
```
→ smoke 의 출력 꼴로 쓴다. 임시 폴더 경로는 015 처럼 `scrub` 하거나 아예 찍지 않는다 (SUMMARY 에 옮길 때 비공개 점검 (1) 에 걸린다 — 06-RESEARCH.md Pitfall 7).

**Analog 2 — subprocess · 상태 폴더 · 판정은 `tool/verify.dart`.**

**Flutter root 찾기** (532-545 — dart 실행 파일에서 다섯 단계 위, 2순위 `FLUTTER_ROOT`):
```dart
Map<String, dynamic>? readFlutterVersion() {
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 4; i++) {
    dir = dir.parent;
  }
  final nearby = readVersionFile(dir.path);
  if (nearby != null) return nearby;

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null || flutterRoot.isEmpty) return null;
  …
}
```
→ 같은 걷기로 `<root>` 를 얻어 `<root>/bin/flutter` 를 `flutter create` · `flutter pub get` 에 쓴다. `ensurePinnedSdk` (559-582) 처럼 `.fvmrc` 와 다르면 안내 + `quit(78)` (06-RESEARCH.md § 3 흐름 1). 06-RESEARCH.md § Alternatives 가 권한 대로 **복사**한다 — `verify.dart` 를 import 하면 `main` 이 둘인 파일이 묶인다.

**`dart analyze` 실행과 상태 폴더** (688-707):
```dart
Future<AnalyzeOutcome> analyzeFixture({
  required String fixtureDir,
  required String stateDir,
}) async {
  final cwd = Directory(fixtureDir).absolute.path;
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['--suppress-analytics', 'analyze', '--format=json'],
    workingDirectory: cwd,
    environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir},
  );
  return AnalyzeOutcome(
    exitCode: result.exitCode,
    lines: normalizeDiagnostics(result.stdout as String, [
      cwd,
      Directory(cwd).resolveSymbolicLinksSync(),
    ]),
    stderrText: (result.stderr as String).trim(),
  );
}
```
→ 주소마다(`recommended` · `alias`) **상태 폴더를 따로** 준다 (49행 주석 · spike 014 — 합치면 plugin 폴더가 둘이 되어 버전을 못 읽는다). `environment` 에 `PUB_CACHE` 도 함께 넣는다 (받은 패키지가 그 cache 에 있다). 경로 인자는 주지 않는다 (686행 주석 — 하위 폴더를 주면 plugin 진단을 잃는다, spike 001).

**JSON → 정답지 꼴 줄** (470-504 `normalizeDiagnostics`): stdout 의 마지막 `{` 줄만 JSON 으로 읽고, 못 읽으면 `null` (진단 0건 `[]` 과 구별), 줄은 `'$file:$line  $severity  ${diagnostic['code']}'`. smoke 의 판정 (2) 는 이 줄 목록에 `lib/smoke_violations.dart:<n>  info  prefer_single_quotes` 와 `lib/smoke_violations.dart:<m>  warning  provider_parameters` 가 **둘 다 있는지**다 (줄 번호는 스크립트가 쓴 파일에서 세므로 고정할 수 있다).

**plugin 준비 실패의 판정** (42-43 상수 · 2547-2560):
```dart
const pluginFailureHeader =
    'An error occurred while executing an analyzer plugin:';
…
  // 1) plugin 준비 실패 — 종료 코드로는 알 수 없고 stderr 의 머리말로만 드러난다.
  if (outcome.hasPluginHeader) {
    return StepResult(
      label: label,
      passed: false,
      …
      detailLines: [
        '${fixture.path}/ — plugin 준비 실패 — $pluginPackage 진단 없이 끝났다 '
            '(dart analyze exit ${outcome.exitCode}). stderr:',
```
→ 순서도 같게: (a) stderr 에 머리말 `contains` → 실패, (b) 종료 코드가 0 · 2 · 3 밖이거나 JSON 이 아니면 실패, (c) 줄 비교. `pluginFolders(stateDir).length == 1` 과 `readPluginVersion` (641-672) 로 `riverpod_lint 3.1.9` 를 화면에 찍는다 — 06-RESEARCH.md § 3 흐름 10 (d).

**종료 코드 · 끝내기** (508-512 `quit`, 598-621 `runPubGet` 의 69): `pub get` 실패는 69 + stderr, 판정 실패는 1, 사용법은 64, SDK 불일치는 78 — `example/README.md` 107-114 표와 같은 숫자를 쓴다. `quit` 은 `stdout.flush()` · `stderr.flush()` 뒤 `exit`.

**머리 주석** (1-33 의 꼴): 첫 줄 "무엇을 하는가", `// 실행: fvm dart run tool/smoke.dart <ref> [--keep]`, 무엇을 만들고 어디에(저장소 밖 임시 폴더 — 저장소 안에는 아무것도 만들지 않는다), 종료 코드 목록, 의존성(`dart:io` · `dart:convert` 만). 015 의 1-8행도 같은 모양이다 ("저장소의 파일은 읽기만 한다 … GitHub 에는 아무것도 올리지 않는다").

**위반 두 줄의 출처:** `example/lib/added_rules.dart` 28-29 와 `example/lib/riverpod_rules.dart` 12-18 을 글자 그대로 옮기고 파일 머리에 출처 주석을 둔다:
```dart
/// `prefer_single_quotes` — 겹따옴표 문자열.
const String doubleQuoted = "b";
```
```dart
/// 인자를 받는 provider.
final familyProvider = Provider.family<int, Object?>((ref, value) => 0);

/// `provider_parameters` (riverpod_lint, warning) — `==` 를 재정의하지 않는 non-const 리터럴을 family 인자로 넘긴다.
final consumerProvider = Provider<int>(
  (ref) => ref.watch(familyProvider([42])),
);
```
기반 세트의 규칙(`example/lib/base_rules.dart` 의 `avoid_print` 등)은 쓰지 않는다 — 템플릿이 이미 `flutter_lints` 를 include 하므로 include 가 깨져도 나온다 (06-RESEARCH.md Pitfall 5).

**검증 범위:** 루트 `analysis_options.yaml` 이 `tool/` 을 제외하지 않으므로 `fvm dart analyze` → `No issues found`, `fvm dart format --output=none --set-exit-if-changed tool` 을 커밋 전에 돌린다 (Phase 5 관례). `tool/verify.dart` 는 `tool/` 의 다른 파일을 읽지 않는다.

---

### `pubspec.yaml` — `version:` · 13-15행 주석 (IN-13)

**Analog:** 자기 자신.

**지금** (1-17):
```yaml
name: woody_lints
description: Woody's custom lint rules for Flutter projects.
version: 2.0.0-dev
…
# lib/analysis_options.yaml 이 `include: package:flutter_lints/flutter.yaml` 을
# 쓰므로 사용하는 프로젝트에 전달되는 dependencies 에 둔다
# (dev_dependencies 는 사용하는 쪽 의존성 그래프에 포함되지 않는다).
dependencies:
  flutter_lints: ^6.0.0
```
→ 3행 `version: 2.0.0`, 13행의 파일 이름만 `lib/base.yaml` 로 (05-REVIEW IN-13 의 Fix 세 줄). 둘 다 **릴리스 커밋**에서 (06-CONTEXT "정한 대로 고치는 다섯" IN-13). `[3/10]` (h) 가 `pubspecReleaseVersion` 을 YAML 과 견주고 (g) 가 README `ref: v2.0.0` 둘(18 · 333행)과 견주므로 README 는 고칠 것이 없다.

---

### `CHANGELOG.md` — 1행

**Analog:** `VERSIONING.md` 81-82 (제목 규칙):
```markdown
- 제목은 `## X.Y.Z - YYYY-MM-DD` 다. 아직 릴리스하지 않은 항목은 날짜 자리에 `미출시` 를 쓰고 릴리스 때 날짜로 바꾼다.
  - 제목의 ` - ` (앞뒤에 공백이 하나씩 있는 붙임표)는 **한 번만** 쓴다. Phase 6 에서 만드는 일치 검사(REL-03 — …)가 ` - ` 앞 토큰을 버전으로 읽는다.
```
→ 1행 `## 2.0.0 - 미출시` → `## 2.0.0 - YYYY-MM-DD` (릴리스 커밋을 만드는 날 — 06-RESEARCH.md § 8 권고; 예행 뒤 날이 바뀌어도 그대로 둔다, D-05 는 꼴만 본다). 같은 커밋에서 `VERSIONING.md` 82행의 "Phase 6 에서 만드는" 을 "검증 명령 `[3/10]` 의" 로 현재형 처리하면 좋다 (06-RESEARCH.md § 7). 본문 9행이 이미 "받는 때" 를 적고 있으므로 2.0.0 항목의 내용은 건드리지 않는다.

---

### `README.md` — 산문 한 문장씩 (UAT 2 · 4, D-11, D-14)

**Analog:** 같은 파일의 이웃 산문. 세 꼴을 따른다.

**출처 · 추론 표시 문장** (33행):
```markdown
- 이 문서의 설치 · 버전 올리기 실측(spike 015)은 `dart pub get` / `dart pub upgrade` 로 했다. 두 명령(`dart pub` 과 `flutter pub`)이 같은 `pubspec.lock` 과 패키지 목록을 만든 것은 확인했다(spike 004). "같은 pub 이 돈다" 는 그 일치에서 읽은 추론이다.
```
→ UAT 2 (355행 끝에 "(1.3.0 의 배포 파일 주석에서 옮긴 문장이다 — spike 에서 재시작 자체를 재 보지는 않았다)"), D-14 의 「프로젝트 전체」 측정 문장 ("… `riverpod_lint` 가 켜진다 (Flutter 3.47.5, 2026-10-15 실측)") 이 이 꼴이다. 357행 "(읽은 것 — … 이 자리에서 잰 것은 아니다)" 도 같은 관례.

**UAT 4 (34행)** — 지금 문장의 뒷부분 "상류에 이 동작을 고치는 변경이 있다 — [flutter#191151](…) (병합 여부는 확인하지 않았다)." 를 06-RESEARCH.md § 6 표의 문장으로 바꾼다. 링크는 그대로 둔다 (05-UAT 4번이 링크 자체는 열어 봤다).

**D-14 의 문장 셋** — 「설치」 29행 뒤, 「프로젝트 전체」 222행 뒤, 「생성 파일 제외」 284행 뒤에 산문 한 줄씩: "`flutter create` 가 만든 `analysis_options.yaml` 에는 이미 `include:` · `analyzer: exclude:` · `linter: rules:` 가 있다 — 기존 `include` 줄은 바꾸고, 이미 있는 `analyzer:` · `linter:` 키에는 합친다 (같은 키를 두 번 적으면 YAML 이 받지 않는다)". **새 펜스 블록을 더하지 않는다** — (e) · (f) · (g) 가 펜스 안의 `package:woody_lints/…` · `version:` · `ref:` 를 읽는다 (06-RESEARCH.md § 6). 산문은 (d′) 의 "표시 구역이 든 절" 밖이므로 목록 줄로 써도 걸리지 않지만, 「받는 규칙」 절에는 아무것도 더하지 않는다.

**D-11 (381행)**:
```markdown
- 버전 등급과 CHANGELOG 항목 형식은 [`VERSIONING.md`](VERSIONING.md) 를 따른다.
```
→ "버전 등급 · CHANGELOG 항목 형식 · 릴리스 절차는 …". 380행의 검증 안내는 그대로 (절차 문서가 그 명령을 품는다).

고친 뒤 `fvm dart run tool/verify.dart` 10/10 (README 는 `[3/10]` 이 읽는다).

---

### `VERSIONING.md` — 새 절 `## 릴리스 절차`

**Analog:** 같은 파일 「CHANGELOG 항목 형식」 77-101 (절의 짜임 — 한 줄 요약 → 불릿 규칙 → 이유 문단 → 펜스 예시 → "새 형식은 2.0.0 부터" 식 적용 시점) 과 README 「이 저장소를 고치는 사람에게」 376-382 (명령 · 종료 코드 · "같은 커밋에서" 를 한 불릿에 넣는 꼴).

**절의 자리와 제목:** 파일 끝 126행 뒤, `## 릴리스 절차` (기존 `## ` 넷 — 판정 순서 · 기준표 · 실제 사례 · CHANGELOG 항목 형식 — 과 같은 등급). 1-4행의 톤("읽는 사람은 몇 달 뒤의 작성자 본인이다 … 쉬운 말로") 을 지킨다.

**담을 것 (06-RESEARCH.md § 7 뼈대, D-12):** 번호 1 ~ 10 (등급 → 릴리스 커밋 → push · CI → 예행 `tool/smoke.dart <커밋>` → **(직전 확인)** tag → CI tag 실행 → `smoke.dart vX.Y.Z` → `ls-remote` → **(직전 확인)** PR merge commit → 다음 `-dev`). 명령은 README 380행처럼 백틱 안에 그대로 (`fvm dart run tool/verify.dart --tag vX.Y.Z`, `git tag -a vX.Y.Z -m "…" <커밋>`, `gh pr merge <번호> --merge`). 2번 안에 **"lock 여섯은 `fvm dart pub get` 으로만 — `pub upgrade` 는 하지 않는다"** 와 "루트 version 만 바꾸고 돌린 검증이 69 로 `example/` 을 가리키는 것이 이 경우" (06-RESEARCH.md § 5 의 stderr 원문) 를 넣는다. 끝에 "plugin 새 버전 때문에 정답지가 저절로 깨졌을 때" 한 단락 — 화면 셋째 줄 `plugin     riverpod_lint <버전>` (`formatVersionLines` 2764-2776 이 찍는 줄) 을 정답지 머리 주석과 견주어 가르고, 다른 단계가 모두 통과할 때만 `--update`, 별도 커밋, 버전은 올리지 않음 (§ 7 둘째 불릿).

**지킬 것:** `[3/10]` 은 `VERSIONING.md` 를 읽지 않으므로 검사 걱정은 없다. 비공개 점검 (2) 의 정규식 `(lib|test|bin|assets)/…\.(dart|json|arb|yaml)` 에 걸릴 저장소 밖 경로(`lib/smoke_violations.dart`)는 이 절에 적지 않거나 제외 목록에 더한다. 101 · 121행처럼 비공개 프로젝트 이름이 든 기존 줄은 건드리지 않는다 (Backlog 999.1 은 이 phase 밖).

---

### `example/README.md` — (i) 설명 · 종료 코드 표 · 620행 · 새 소절 M92 ~ M97

**Analog:** 같은 파일 05-14 소절 (594-629). 새 소절은 이 소절의 짜임을 그대로 쓴다.

**소절 머리** (594-598):
```markdown
### 추가 실측 — 여러 줄 문자열 안의 줄 (05-14)

실측 (05-14): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-15

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 10개). 05-12 소절과 같은 절차로 **복제본(`git clone --local`)에서** 했다 — … 변경은 한 번에 하나씩, 줄 번호가 아니라 글자로 자리를 잡았다 — … M90 · M91 은 전체 실행이 아니라 함수 단위다 — 복제본 밖의 임시 폴더에 둔 Dart 파일 하나가 `tool/verify.dart` 를 import 해 `checkShippedComposition` 을 직접 부르고 `passed=` 와 블록 줄을 찍었다. … 부르는 법만 `fvm dart run --packages=<복제본의 .dart_tool/package_config.json> <하네스> <복제본>` 으로 …
```
→ 새 소절 `### 추가 실측 — tag · pubspec · CHANGELOG 의 버전 일치 (06-NN)`. "실행한 명령" 문단에 (1) 복제본을 릴리스 상태로 만든 `sed` 둘 (06-RESEARCH.md § Code Examples), (2) 함수 단위 하네스가 `checkShippedComposition(root, tag: 'v2.0.0')` 을 부른다는 것, (3) M93 하나만 전체 실행 (`fvm dart run tool/verify.dart --tag v2.0.0`, 복제본에서 lock 여섯도 다시 받은 뒤) 을 적는다.

**표의 6열과 함수 단위 행의 꼴** (600 · 606):
```markdown
| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M90 | `lib/riverpod.yaml` 5행(…)을 맵 꼴 여덟 줄 … 으로 (5 ~ 12행) — … | 함수 단위 (`checkShippedComposition`) | `passed=false`. 낸 블록 둘:<br>`` `lib/riverpod.yaml` 의 최상위 키 — … ``<br>`줄 단위 reader 에만: plugins` · `YAML 에만: (없음)`<br>… | 함수 단위 | VERIFY-06 — 05-VERIFICATION.md 4회차 gap (함수 단위, 검증자의 R3, 소유자 결정 G4-Q1) |
```
→ M92 ~ M96 은 "변경" 칸에 D-06 의 입력(`--tag v2.0.1` / `pubspec.yaml` 3행 `-dev` 남김 / CHANGELOG 1행 `## 2.1.0 - …` / 1행 `미출시` / `--tag 2.0.0`), "정답지와의 차이" 칸에 (i) 블록의 머리 줄 원문을 `` `…` `` 로, "항목" 칸에 `REL-03 — 06-CONTEXT.md D-04 · D-05 · D-06`. M93 (전체 실행) 행은 `[3/10]` 만. 나머지는 통과` · `1` · 화면 요약 `점검 실패 (10개 중 1개)` 로 M87 행의 꼴. M97 (IN-12) 은 "고치기 전 `passed=false` → 고친 뒤 `passed=true`" — M32 · M33 (WR-02 의 거짓 실패 해소) 이 "통과로 바뀐 입력" 의 선례.

**회귀 불릿과 되돌림 확인** (609-615 · 627-629): M78 (IN-12 회귀 — (a′) 줄과 (h) 블록 그대로), 지금 상태(`2.0.0-dev` · `미출시`)의 평소 모드 통과를 회귀 불릿으로. 끝에 "변경은 모두 … 복제본에서 되돌렸다 (`git status --porcelain` 빈 출력) … 복제본은 끝에 지웠다" 와 "걸린 시간" 문단.

**116행:** 3,412자 한 문단의 끝에 "(i) tag · `pubspec.yaml` 의 version · CHANGELOG 최상단 버전의 일치 (tag 가 없으면 꼬리를 뗀 version 과 CHANGELOG 버전만, tag 가 있으면 `vX.Y.Z` 꼴 · 꼬리 없이 정확히 · 날짜 자리 `YYYY-MM-DD` — 2026-10-15 에 더함, 아래 M92 ~ M96)" 을 잇는다. 문단을 쪼개지 않는다 (05-UAT 8번).

**종료 코드 표** (107-114): 64 행에 `--tag` 의 값 없음, 70 행 괄호 안 목록에 "CHANGELOG 최상단 `## ` 제목이 없거나 ` - ` 가 없는 경우", 새 255 행 (IN-14). 105행 "정답지의 `exit N` 과는 다른 숫자다" 는 그대로.

**620행** (UAT 5 · IN-14): "YAML (package:yaml — analyzer · pub 과 같은 해석기)" 뒤에 "(판이 같은지는 재지 않았다)", 마지막 문장 "YAML 로 읽지 못하는 파일(같은 키 두 번 · 깨진 YAML)도 블록 하나로 실패한다 (소유자 결정 G4-Q1)" 을 06-RESEARCH.md § 6 표의 문장(`YamlException` 은 블록 하나, `Error` 는 255)으로.

---

### lock 여섯

**Analog:** 자기 자신 `example/pubspec.lock` 267-273:
```yaml
  woody_lints:
    dependency: "direct dev"
    description:
      path: ".."
      relative: true
    source: path
    version: "2.0.0-dev"
```
→ 손으로 고치지 않는다. 여섯 폴더에서 `fvm dart pub get` (06-RESEARCH.md § Code Examples 의 for 루프) — 각 lock 에서 `version: "2.0.0"` 한 줄만 바뀐다 (`git diff --stat` 7 files · 7/7, 06-RESEARCH.md § 5 실측). `pub upgrade` 는 쓰지 않는다 (D-12). 루트 `fvm dart pub get` 도 먼저 한 번 (README 380행).

---

### 처리 기록 — `02-UAT.md` 4 · 6번, `05-UAT.md` 1 · 2 · 4 · 5번, `05-REVIEW-DISPOSITION.md` IN-12 ~ 14

**Analog:** `05-REVIEW-DISPOSITION.md` 의 `fixed` 행 (WR-15):
```markdown
| WR-15 | warning | fixed | 05-14-PLAN.md Task 1 (77e0b88) — tool/verify.dart 의 [3/10] (h) compareLineReadersWithYaml 이 pubspecReleaseVersion 의 값을 package:yaml 이 읽은 version 과 견줌, pubspec.yaml 의 dev_dependencies 에 yaml, M87 (소유자 결정 G4-Q1 — 05-VERIFICATION 4회차 gap) (not in the current review) |
```
→ IN-12 · IN-13 · IN-14 행의 `deferred` 를 `fixed` 로, Source 칸을 `06-NN-PLAN.md Task N (<sha>) — <무엇을 어떻게>` 꼴로. frontmatter 의 같은 id 항목도 함께. `02-UAT.md` 4 · 6번과 `05-UAT.md` 1 · 2 · 4 · 5번은 각 테스트의 `status` 와 `note` 에 결과와 근거(실행 id · 커밋)를 적고, 71-91 의 Deferred Follow-Ups 항목에 닫은 phase 를 남긴다 (05-UAT 가 `moved_to: "ROADMAP Phase 6 Notes"` 로 적은 꼴의 역방향).

---

### 원격 ref — tag push · `ls-remote` · PR 병합의 증거 형식 (REL-02)

**Analog:** `.planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md`.

**시각 순서 표** (93-102 — 소유자 확인이 push 보다 앞섰다는 기록):
```markdown
시각 순서 (소유자 확인이 push 보다 앞섰다는 기록):

| 시각 (UTC) | 한국 시각 | 일 |
|------------|-----------|----|
| 2026-10-11T04:21:51Z | 13:21:51 | 로컬 tag 생성 (Task 1) |
| 2026-10-11T04:22:01Z | 13:22:01 | 4중 점검 PASS (Task 1) |
| 2026-10-11T04:25:38Z | 13:25:38 | 소유자 응답 `push` (Task 2) |
| 2026-10-11T04:27:05Z | 13:27:05 | push 직전 재확인 — 원격에 tag 없음, Task 1 verify rc=0 |
| 2026-10-11T04:27:13Z ~ 04:27:16Z | 13:27:13 ~ 13:27:16 | `git push origin v1.3.0` (Task 3) |
| 2026-10-11T04:27:23Z | 13:27:23 | 원격 확인 (Task 3) |
```

**push 출력 + `ls-remote` 원문 + 읽는 법** (345-375):
```text
$ git push origin v1.3.0
To github.com:woodkill/woody_lints.git
 * [new tag]         v1.3.0 -> v1.3.0
rc=0
```
```text
$ git ls-remote --tags origin
80e2112578b7a9870e43476a2893bc4972d4a3a9	refs/tags/v1.3.0
90a2736b8d998c84467faf562a0fec720b797eaf	refs/tags/v1.3.0^{}
rc=0
$ git ls-remote --heads origin
90a2736b8d998c84467faf562a0fec720b797eaf	refs/heads/main
rc=0
$ git show v1.3.0:pubspec.yaml | grep -nx 'version: 1.3.0'
3:version: 1.3.0
```
> 읽는 법: annotated tag 는 `ls-remote` 에 두 줄로 나온다. 첫 줄 `80e2112…` 는 tag 객체 자체의 SHA 이고 (로컬 `git rev-parse v1.3.0` 과 같다), 둘째 줄 `refs/tags/v1.3.0^{}` 이 tag 가 가리키는 **커밋**이다. 판정은 둘째 줄로 한다.

→ 2.0.0 은 같은 꼴에 (a) `git show v2.0.0:CHANGELOG.md | head -1` 한 줄, (b) `ls-remote --tags` 에 `v1.3.0` 두 줄 + `v2.0.0` 두 줄 = 4줄, (c) `ls-remote --heads` 가 `main` · 작업 브랜치 둘 (Phase 5 이후 작업 브랜치가 원격에 있다 — 05-05-PLAN 의 `HEADS … = 2` 단언), (d) 병합 뒤 `git log -1 --format=%P origin/main` (부모 둘) · `git merge-base --is-ancestor v2.0.0 origin/main` 을 더한다. 4중 점검 (01-01 의 27-28행 기록: `git cat-file -t` = `tag`, `rev-parse 'vX.Y.Z^{commit}'`, `show …:pubspec.yaml`, 원격에 아직 없음) 을 checkpoint **앞**에, push 는 tag 이름 하나만 (`git push origin v2.0.0`). smoke 결과도 같은 꼴로 — 명령 줄 · 요약 줄 · `resolved-ref` · `rev-parse` 값 · rc, 임시 폴더 경로는 `<임시 폴더>` 로.

---

## Shared Patterns

### push 전 비공개 점검 — 05-05-PLAN Task 1 `<automated>` 원문
**Source:** `.planning/phases/05-documentation/05-05-PLAN.md` 90행. 이 phase 는 phase 폴더(`05-documentation` → `06-release`), 자기 패턴 줄 정규식(`05-` → `06-`), 점검 (2) 의 제외 목록(`lib/smoke_violations\.dart$` 추가), 원격 상태 단언(작업 브랜치 push 뒤 · tag push 뒤 · 병합 뒤에 `HEADS` 수 · `TAGS` 내용 · `main` 의 SHA 가 달라진다)만 바꿔 쓴다. (06-RESEARCH.md § 8 · Pitfall 7)
**Apply to:** 브랜치 push 전 (범위 = `git diff --name-only origin/gsd/v2.0-package-rework..HEAD` 전체), tag push 전, PR 전. 커밋마다는 (1) · (2) 만.

```sh
git fetch origin --quiet && test "$(git rev-parse --abbrev-ref HEAD)" = gsd/v2.0-package-rework && git merge-base --is-ancestor origin/gsd/v2.0-package-rework HEAD && test "$(git rev-list --count origin/gsd/v2.0-package-rework..HEAD)" -ge 1 && HEADS=$(git ls-remote --heads origin) && test "$(printf '%s\n' "$HEADS" | wc -l | tr -d ' ')" = 2 && printf '%s\n' "$HEADS" | grep -qF "$(printf '90a2736b8d998c84467faf562a0fec720b797eaf\trefs/heads/main')" && TAGS=$(git ls-remote --tags origin) && printf '%s\n' "$TAGS" | grep -qF 'refs/tags/v1.3.0' && gh auth status >/dev/null 2>&1 && test -z "$(git status --porcelain)" && FILES=$(git diff --name-only origin/gsd/v2.0-package-rework..HEAD) && test -n "$FILES" && OTHER=$(printf '%s\n' "$FILES" | grep -vE '^\.planning/phases/05-documentation/(05-[0-9]+-PLAN\.md|05-RESEARCH\.md)$') && test "$( [ -n "$OTHER" ] && printf '%s\n' "$OTHER" | xargs git grep -n -E '/Users/[A-Za-z]|/private/tmp[/]|/var/folders[/]|/home/[a-z]+[/]' HEAD -- 2>/dev/null | wc -l | tr -d ' ')" = 0 && SELF=$(printf '%s\n' "$FILES" | grep -E '^\.planning/phases/05-documentation/(05-[0-9]+-PLAN\.md|05-RESEARCH\.md)$') && test "$( [ -n "$SELF" ] && printf '%s\n' "$SELF" | xargs git grep -n -E '/Users/[A-Za-z]|/private/tmp[/]|/var/folders[/]|/home/[a-z]+[/]' HEAD -- 2>/dev/null | grep -v -F -e '/Users/[A-Za-z]' -e '/home/[a-z]+[/]' | wc -l | tr -d ' ')" = 0 && LEAK2=$(grep -rh -o -E '(lib|test|bin|assets)/[A-Za-z0-9_./-]+\.(dart|json|arb|yaml)' README.md CHANGELOG.md lib tool/verify.dart example/README.md .claude/CLAUDE.md .planning/phases/05-documentation 2>/dev/null | sort -u | grep -v -E '^(lib/woody_probe_marker/|lib/a\.dart$|lib/core\.yaml$|lib/recommended\.yaml$|lib/flutter\.yaml$|lib/woody_lints\.dart$|bin/cache/flutter\.version\.json$|lib/bug_prevention_rules\.dart$|lib/strict_rules\.dart$|lib/performance_rules\.dart$|lib/style_rules\.dart$|lib/_probe\.dart$|lib/dup_probe\.dart$|lib/_probe_rules\.yaml$)' | while read -r p; do [ -e "$p" ] || [ -e "example/$p" ] || [ -e "fixtures/base_only/$p" ] || [ -e "fixtures/overrides/$p" ] || echo "LEAK? $p"; done) && test -z "$LEAK2" && test "$(grep -rn -E 'fixes? made in|proposed fixes in' README.md CHANGELOG.md .planning/phases/05-documentation 2>/dev/null | grep -v -E '05-[0-9]+-PLAN\.md|05-RESEARCH\.md' | wc -l | tr -d ' ')" = 0 && fvm dart analyze 2>&1 | grep -q 'No issues found' && { OUT=$(fvm dart run tool/verify.dart 2>/dev/null); RC=$?; } && test "$RC" = 0 && printf '%s\n' "$OUT" | grep -qxF '점검 통과 (10개 중 10개)' && printf '%s\n' "$OUT" | grep -qE '^\[3/10\] 배포 파일의 구성 \.+ 통과$' && test -z "$(git status --porcelain)"
```

이 phase 에서 바꿀 자리: `.planning/phases/05-documentation` → `.planning/phases/06-release` (세 곳), `05-[0-9]+-PLAN\.md|05-RESEARCH\.md` → `06-[0-9]+-PLAN\.md|06-RESEARCH\.md` (네 곳), 점검 (2) 의 대상에 `tool/smoke.dart` · `VERSIONING.md` 를 더하고 제외 목록 끝에 `|lib/smoke_violations\.dart$`, 릴리스 커밋 뒤에는 `fvm dart run tool/verify.dart` 를 `--tag v2.0.0` 으로도 한 번. 원격 단언(`HEADS … = 2`, `main` = `90a2736…`, `v1.3.0`)은 그 시점의 사실로 — tag push 뒤에는 `TAGS` 에 `refs/tags/v2.0.0^{}` 줄이 `git rev-parse 'v2.0.0^{commit}'` 와 같은지, 병합 뒤에는 `main` 이 merge commit 인지로 바뀐다.

### 값의 어긋남은 단계 실패 1, 파일 모양이 예상과 다르면 `FormatException` → 70
**Source:** `tool/verify.dart` 1610-1612 (던지는 쪽) · 2909-2917 (받는 쪽) · `example/README.md` 107-114 (표)
**Apply to:** (i) 의 모든 어긋남(블록 → 1), `changelogTop` 의 `## ` 없음 · ` - ` 없음 (70), `pubspecVersionText` 의 `version:` 없음 (70). tag 이름이 `vX.Y.Z` 꼴이 아닌 것은 **1** 이다 (D-06 다섯째 — "일부러 어긋나게 만든 입력에서 실패" 의 하나이므로 사용법 64 가 아니라 단계 실패). `--tag` 에 값이 없는 것만 64.
```dart
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    exitCode = 70;
```

### subprocess 는 `Process.run(Platform.resolvedExecutable, …)` + 상태 폴더 환경변수, 경로는 화면에 남기지 않는다
**Source:** `tool/verify.dart` 603-608 (`pub get`) · 693-698 (`analyze`) · 584-586 `relativize` · 675-682 `scrubPaths`; spike 015 `probe.dart` 88-93 (`PUB_CACHE`)
**Apply to:** `tool/smoke.dart` 전부. `shownAs:` 인자(597 · 651행 문서 주석 "화면에 절대 경로를 남기지 않는다") 의 관례를 따라 임시 폴더는 `<임시 폴더>` 로 가리거나 찍지 않는다. `--keep` 때만 경로를 찍고, SUMMARY 에는 옮기지 않는다.

### 실측 문장 — 버전 · 날짜 · "재지 않았다" 표시
**Source:** `example/README.md` 596 (`실측 (05-14): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-15`), `README.md` 33 ("… 그 일치에서 읽은 추론이다") · 357 ("읽은 것 — … 이 자리에서 잰 것은 아니다"), `tool/verify.dart` 595 (`(Dart 3.13.4, 2026-10-12 실측)`)
**Apply to:** README 의 D-14 · UAT 2 · UAT 4 문장, `VERSIONING.md` 새 절의 "69 의 문구" · "lock 한 줄만 바뀐다" (2026-10-15 실측), `example/README.md` 새 소절, smoke 결과의 기록. 재지 않은 것(`GITHUB_SHA` 의 값, Linux runner 에서의 smoke)은 "재지 않았다" 로.

### 지워 보기는 `git clone --local` 복제본에서, 한 번에 하나씩, 되돌림 확인까지
**Source:** `example/README.md` 598 · 629 ("변경은 모두 … 복제본에서 되돌렸다 (복제본의 `git status --porcelain` 이 빈 출력 …) … 복제본은 끝에 지웠다")
**Apply to:** M92 ~ M97. 함수 단위 하네스는 **복제본 밖 임시 폴더**의 Dart 파일 하나 (`--packages=<복제본의 .dart_tool/package_config.json>`) — 저장소 · 복제본에 파일을 남기지 않는다.

### "같은 커밋에서" 안내 문구
**Source:** `tool/verify.dart` 2495 (`'릴리스 버전을 올릴 때 `$readmeFile` 의 `ref:` 예시도 같은 커밋에서 고친다.'`), `README.md` 379 · 382
**Apply to:** (i) 블록의 안내 줄 ("`-dev` 를 떼는 커밋에서 CHANGELOG 제목의 날짜와 lock 여섯도 같은 커밋에서"), `VERSIONING.md` 절차 2 · 10번 (version 과 CHANGELOG 제목은 같은 커밋에서 — 검사 (1) 이 둘을 견준다).

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `.github/workflows/verify.yml` 5-7행 주석 | config (CI) | — | 고치지 않아도 된다 — `GITHUB_REF_TYPE` · `GITHUB_REF_NAME` 은 모든 step 에 기본으로 있고 필터 없는 `push:` 가 tag 에서도 돈다 (06-RESEARCH.md § 1). 고친다면 7행 "Phase 6 (REL-03) 이 tag 전용 검사를 더할 때" 를 현재형 한 줄로 바꾸는 것뿐이며 선례가 필요 없다 |

`tool/smoke.dart` 는 "없음" 이 아니라 role-match 다 — 받는 쪽 만들기 · lock 읽기 · 분석 · 판정의 네 부품이 모두 spike 015 와 `tool/verify.dart` 에 있고, 새로 짜는 것은 `flutter create` 호출 · 템플릿 파일 고치기 · 두 주소 반복뿐이다. 그 셋은 06-RESEARCH.md § 3 · § 4 의 실측 절차(명령 · 결과 6줄 · 시간)가 사실상의 사양이다.

## Metadata

**Analog search scope:** `tool/verify.dart` (범위 읽기 12곳, 2,927행), `.claude/skills/spike-findings-woody-lints/sources/015-git-dependency-preset-load/probe.dart` 전문 (432행), `.planning/phases/01-baseline-and-toolchain/01-01-SUMMARY.md` 83-110 · 345-380 과 `ls-remote` · `git tag` grep, `.planning/phases/05-documentation/05-05-PLAN.md` 73-92, `example/README.md` 100-118 · 558-562 · 590-631, `VERSIONING.md` 1-12 · 60-127, `pubspec.yaml` 전문, `CHANGELOG.md` 1-12, `README.md` 9-36 · 218-226 · 280-288 · 353-357 · 374-382, `example/pubspec.lock` 267-273, `example/lib/added_rules.dart` 25-32, `example/lib/riverpod_rules.dart` 1-20, `.github/workflows/verify.yml` 1-37, `02-UAT.md` · `05-UAT.md` 의 제목 · Deferred Follow-Ups, `05-REVIEW-DISPOSITION.md` frontmatter 와 IN-12 ~ 14 · WR-15 행, `.planning/phases/05-documentation/05-PATTERNS.md` 1-80 · 520-585 (형식 선례)
**Files scanned:** 18 (모두 `git ls-files` 로 추적 확인, 2026-10-15)
**Pattern extraction date:** 2026-10-15
