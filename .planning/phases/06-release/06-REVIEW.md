---
phase: 06-release
reviewed: 2026-10-16T11:22:30Z
depth: standard
files_reviewed: 7
files_reviewed_list:
  - .claude/skills/spike-findings-woody-lints/SKILL.md
  - .claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md
  - .claude/skills/spike-findings-woody-lints/references/rule-status-check.md
  - example/README.md
  - pubspec.yaml
  - tool/smoke.dart
  - tool/verify.dart
findings:
  critical: 0
  warning: 4
  info: 6
  total: 10
status: issues_found
---

# Phase 6: Code Review Report

**Reviewed:** 2026-10-16T11:22:30Z
**Depth:** standard
**Files Reviewed:** 7
**Status:** issues_found

## Summary

범위는 `git diff e880cb0..HEAD` 의 일곱 파일, 곧 gap 수정 06-08 (`tool/verify.dart` 의 `[3/10]` (h) · (i), `pubspec.yaml` 의 `markdown` 개발용 의존성, `example/README.md` 의 M98 ~ M106, skill 세 줄) 과 06-09 (`tool/smoke.dart` 의 include 사슬 판정, 단계별 시간 제한, `finally` · SIGINT 정리, `killTree`) 이다.

실험은 모두 저장소 밖 임시 폴더 하나에서 했다. `git clone --local` 복제본에서 `fvm dart pub get --no-example` 을 먼저 돌렸다. 복제본 밖의 하네스 Dart 파일이 복제본의 `tool/verify.dart` · `tool/smoke.dart` 를 import 해 함수를 직접 불렀다. Markdown 의 기준값은 GitHub 의 렌더 API(`POST /markdown`, `mode: markdown`)에 합성한 머리 조각을 보내 얻었다. include 진단의 코드는 고정 SDK(Dart 3.13.4)의 `dart analyze` 를 작은 프로젝트 둘에 돌려 쟀다. 작업 트리는 건드리지 않았다. 복제본 파일은 실험마다 되돌렸고(`git status --porcelain` 빈 출력) 끝에 임시 폴더를 지웠다. `tool/smoke.dart` 전체 실행과 `tool/verify.dart` 전체 실행은 하지 않았다.

pubspec 쪽은 닫혔다. CR-01 의 입력(겹따옴표 여러 줄 스칼라 안의 열 0 `version: 2.0.0` + 실제 `version: 2.0.0-dev`)을 넣으면 지금은 평소 모드에서 (h) 블록 하나, `v2.0.0` 에서 (h) · (i) 블록 둘이 난다. (i) 는 YAML 값만 쓰고 (h) 는 원문 전체를 견주므로, 줄 단위 reader 가 YAML 과 다르게 읽으면 늘 (h) 가 블록을 낸다. YAML 과 같은 값이면 (i) 의 판정과 갈리지 않는다.

CHANGELOG 쪽은 "같은 꼴의 다른 입력" 이 둘 남았다. `package:markdown` 7.3.1 과 GitHub 화면이 갈리는 꼴 54개를 견주었고, 두 갈래에서 갈렸다.
- 한 글자 `-` 밑줄의 setext 제목: GitHub 은 h2 로 그리는데 해석기는 h2 로 보지 않는다. 평소 모드가 아래의 옛 항목과 견주어 통과한다 (WR-02, 아직 해당).
- 인용 · 목록 · 단락 안에서 연 `<!--`: GitHub 화면에서는 그 뒤가 모두 주석으로 삼켜진다. 그런데 해석기는 그 안의 `## ` 를 첫 h2 로 읽는다. 그래서 `[3/10]` 이 tag 모드 `v2.0.1` 에서 통과한다 (WR-05).

smoke 쪽에는 새 발견 셋이 있다.
- include 받는 파일이 깨진 YAML 이면 `dart analyze` 가 JSON 에 진단 없이 종료 코드 3 만 낸다. 판정은 이것을 통과로 본다 (WR-04).
- 시간 제한이 하위 명령의 종료에만 걸린다. 출력 파이프를 붙든 자손이 있으면 제한을 넘겨 기다린다 (WR-06).
- UTF-8 이 아닌 출력은 처리되지 않은 비동기 예외(255)를 낸다. 이때 `finally` 의 정리를 건너뛴다 (IN-04).

`killTree` 의 SIGSTOP 뒤 오류 경로는 찾지 못했다. SIGSTOP 부터 SIGKILL 까지가 동기 코드이고, 그 사이의 `ps` 실패는 `null` 로 잡힌다. 그래서 "얼린 채 남는" 경우는 없다. 대신 조용히 덜 끊는 경우가 있다 (IN-06).

## 지난 리뷰의 발견 7건 — 지금 상태

| ID | 제목 | 지금 상태 | 근거 |
|----|------|-----------|------|
| CR-01 | tag 모드가 정확히 견주는 version 원문을 YAML 과 견주는 확인이 없어, `-dev` 가 남은 pubspec 이 `--tag` 검사를 통과한다 | 닫힘 | 같은 입력을 복제본에서 다시 넣었다. `checkShippedComposition` 이 평소 `passed=false` ((h) `줄 단위 reader: 2.0.0` · `YAML: 2.0.0-dev`), `v2.0.0` 에서 `passed=false` ((h) + (i) `-dev 꼬리가 남아 있다`) 를 냈다 (직접 재현) |
| WR-01 | smoke 가 include 사슬의 끊김(`include_file_not_found`)을 보고도 통과한다 — 두 주소의 codegen 부분은 판정에 없다 | 닫힘 | `judge` 의 (c′) (`tool/smoke.dart:683-692`) 가 두 주소 각각에서 `include_file_not_found` · `included_file_warning` 줄을 사유로 더한다. 같은 꼴의 다른 입력(깨진 YAML)은 WR-04 로 따로 적었다 |
| WR-02 | `changelogTop` 이 들여 쓴 ATX 제목 · setext 제목 · U+FEFF 머리를 제목으로 보지 않아, 평소 모드가 아래의 옛 항목과 견주어 통과한다 | 아직 해당 (좁아짐) | 들여 쓴 ATX · `--` 이상의 setext · U+FEFF 는 닫혔다. 한 글자 `-` 밑줄의 setext 는 GitHub 이 h2 로 그리는데 해석기가 보지 않는다. 그래서 평소 · `v2.0.0` 모두 `passed=true` 다 (직접 재현) |
| WR-03 | smoke 의 하위 명령에 시간 제한이 없어, 받기 · plugin 준비가 멈추면 끝없이 기다린다 | 닫힘 | `runProcess` 가 `Process.start` + `exitCode.timeout` 을 쓰고, 넘으면 `killTree` 뒤 69 다. 종료 뒤 출력 수집에 제한이 없는 남은 자리는 WR-06 으로 따로 적었다 |
| IN-01 | smoke 의 임시 폴더 정리가 `finally` 밖이라, 세 예외 밖의 throw · 중단 신호에서 폴더가 남는다 | 닫힘 | 정리가 `main` 의 `finally` (`:997-1000`) 와 SIGINT 처리기 (`:961-971`) 로 옮겨졌다. 처리되지 않은 비동기 예외가 `finally` 를 건너뛰는 남은 자리는 IN-04 로 따로 적었다 |
| IN-02 | `runSmoke` 가 `judge` 의 앞 두 조건을 다시 적는다 | 닫힘 | `judge` 가 `({List<String> reasons, String shown})` 을 돌려주고, `runSmoke` (`:888-890`) 는 그 값만 쓴다. `analyzeExitCodes.contains(` 는 `judge` 한 곳뿐이다 |
| IN-03 | `pubspecVersionText` 가 `pubspecReleaseVersion` 의 줄 찾기를 따로 다시 짠다 | 닫힘 | `pubspecReleaseVersion` 이 `releaseHead(pubspecVersionText(repoRoot))` 한 줄이다 (`tool/verify.dart:1621-1623`). 줄 정규식 · 순회는 `pubspecVersionText` 한 곳에만 있다 |

## Narrative Findings (AI reviewer)

## Warnings

### WR-02: `changelogTop` 이 들여 쓴 ATX 제목 · setext 제목 · U+FEFF 머리를 제목으로 보지 않아, 평소 모드가 아래의 옛 항목과 견주어 통과한다

**File:** `tool/verify.dart:1709-1732` (`changelogTop`), `tool/verify.dart:1686-1702` (문서 주석), `example/README.md:704-705`, `pubspec.yaml:21`
**Issue:** 06-08 이 고친 입력(1 ~ 3칸 들여 쓴 ATX, `---` setext, U+FEFF 머리, 인용 · 목록 안의 h2)은 닫혔다. 그런데 setext 제목 하나가 남았다. 밑줄이 한 글자 `-` 인 꼴이다. CommonMark 에서 빈 목록 항목은 단락을 끊지 못하므로, 단락 바로 아래의 `-` 줄은 setext 밑줄이다. GitHub 은 이 꼴을 h2 로 그린다. `package:markdown` 7.3.1 (`ExtensionSet.gitHubFlavored`) 은 이것을 h2 로 보지 않는다. 그래서 `firstElement(nodes, 'h2')` 가 그 아래의 옛 항목을 고른다.

같은 머리 조각을 두 쪽에 넣고 견준 결과 (2026-10-16):

| 밑줄 줄 | GitHub API 의 첫 h2 | `changelogTop` |
|---------|---------------------|----------------|
| `-` | `2.1.0 - 미출시` | `2.0.0` |
| `- ` (뒤 공백) · `-` + 탭 · ` -` (앞 공백 1칸) | `2.1.0 - 미출시` | `2.0.0` |
| 인용 안 `> -` · 목록 안 `  -` | `2.0.1 - 2026-10-16` | `2.0.0` |
| `--` · `-- ` · `   --` · `---` (대조) | `2.1.0 - 미출시` | `2.1.0` |

복제본에서 `CHANGELOG.md` 맨 앞에 `2.1.0 - 미출시` / `-` / 빈 줄을 넣었다. `pubspec.yaml` 은 `2.0.0` 그대로 두었다. 이 상태에서 `checkShippedComposition` 이 평소 모드 `passed=true`, `--tag v2.0.0` 도 `passed=true` 였다. GitHub 화면의 최상단은 `2.1.0 - 미출시` 이므로, D-04 (1) 의 "준비 중의 어긋남을 평소 push 에서 잡는다" 가 이 입력에서 뒤집힌다. 지난 WR-02 와 같은 결과다. `v2.1.0` 으로 돌리면 옛 버전을 읽어 실패하므로, 새 tag 의 gate 는 이 입력으로 뚫리지 않는다.

문서도 사실과 다르다. 두 문장이 GitHub 화면과 같다고 말한다.
- `changelogTop` 문서 주석과 `pubspec.yaml` 21행 주석: "GitHub 화면이 그리는 제목과 같다" · "GitHub 화면과 같게"
- `tool/verify.dart:1700-1701` · `example/README.md:705`: raw `<h2>` 가 "렌더된 화면과 다를 수 있는 유일한 꼴" 이라고 한다

이 셋은 이 꼴과 WR-05 의 꼴에서 틀린다.
**Fix:** 해석기가 GitHub 과 갈리는 꼴이면 조용히 다른 제목을 고르지 말고 실패로 알린다. 한 글자 `-` 밑줄 줄을 `--` 로 바꾼 사본을 한 번 더 해석한다. 두 결과의 첫 h2 가 다르면 `FormatException` 이다. 아래 꼴은 하네스에서 54개 꼴 가운데 갈리는 일곱만 잡았고, 지금 `CHANGELOG.md` 는 그대로 통과했다.

```dart
  final lines = splitYamlLines(text);
  List<md.Node> parse(List<String> ls) => md.Document(
        extensionSet: md.ExtensionSet.gitHubFlavored,
        encodeHtml: false,
      ).parseLines(ls);
  final heading = firstElement(parse(lines), 'h2');
  // package:markdown 7.3.1 은 한 글자 `-` setext 밑줄을 제목으로 보지 않는다 (GitHub 은 본다).
  final oneDash = RegExp(r'^([ \t>]*)-[ \t]*$');
  final widened = [
    for (final l in lines) l.replaceFirstMapped(oneDash, (m) => '${m[1]}--'),
  ];
  final check = firstElement(parse(widened), 'h2');
  if (check?.textContent != heading?.textContent) {
    throw FormatException(
      'CHANGELOG.md 의 첫 제목을 GitHub 과 다르게 읽을 수 있는 꼴이다 (한 글자 `-` 밑줄): '
      '${check?.textContent.trim()}',
    );
  }
```

문서 주석 · `pubspec.yaml` 21행 · `example/README.md` (3) 의 "유일한 꼴" 문장을 고친다. M 기록에 한 글자 밑줄 꼴을 더한다.

### WR-04: smoke 가 include 받는 파일의 깨진 YAML(`included_file_parse_error`)을 보지 못한다 — JSON 에 진단이 없고 종료 코드 3 만 남는다

**File:** `tool/smoke.dart:97` (`includeErrorCodes`), `tool/smoke.dart:676-692` (`judge` 의 (b) · (c′)), `tool/smoke.dart:91` (`analyzeExitCodes`)
**Issue:** WR-01 의 고침은 JSON 진단 줄 가운데 `include_file_not_found` · `included_file_warning` 둘만 찾는다. 같은 "include 사슬의 끊김" 가운데 include 받는 파일이 YAML 로 읽히지 않는 경우가 있다. 고정 SDK(Dart 3.13.4)에서 재 보니, 이 경우는 사람용 출력에만 `error - analysis_options.yaml:1:10 - While parsing a flow sequence … - included_file_parse_error` 를 찍는다. `--format=json` 의 `diagnostics` 에는 이 진단이 없고, 종료 코드만 3 이다.

두 꼴에서 쟀다.
- 작은 프로젝트의 `include: mid.yaml` → `include: leaf.yaml` 의 leaf 를 깨진 YAML 로 둔 꼴
- path 의존성 패키지의 `lib/rec.yaml` 이 `include:` 목록(`base.yaml` · `codegen.yaml`)을 두고, `codegen.yaml` 만 `exclude: [` 로 깨뜨린 꼴

둘 다 JSON 에는 `prefer_single_quotes` 한 줄뿐이었고 종료 코드는 3 이었다. 같은 측정에서 순환 include 와 없는 규칙 이름은 `included_file_warning`, 없는 파일은 `include_file_not_found` 로 JSON 에 나왔다.

`judge` 는 3 을 정상 종료(`analyzeExitCodes = [0, 2, 3]`)로 받는다. 그래서 이 출력에서 사유가 0개다. 하네스로 `judge` 에 종료 코드 3 · 위반 두 줄 · `analysis_options.yaml` 줄 없음을 주었더니 `reasons=0`, `shown=prefer_single_quotes 있음 · provider_parameters 있음` 이었다. 받는 쪽에서 `lib/codegen.yaml` 이 깨지면 생성 파일 제외 · `invalid_annotation_target: ignore` 가 통째로 빠진다. 그래도 smoke 는 통과한다. 머리 주석 (2′) 이 말하는 "include 사슬이 끊긴 진단이 있으면 실패" 의 빈자리다. 같은 커밋의 `verify.dart` `[2/10]` 가 깨진 조각 YAML 을 잡기는 한다. 하지만 smoke 는 "GitHub 에서 받은 그대로" 를 보는 gate 다.
**Fix:** 진단 줄과 종료 코드가 맞는지 본다. 종료 코드 3 은 error 가 있다는 뜻이므로, JSON 에 `error` 줄이 하나도 없으면 실패로 둔다. 코드 목록에도 셋째 코드를 더한다.

```dart
const includeErrorCodes = {
  'include_file_not_found',
  'included_file_warning',
  'included_file_parse_error',
};
...
  // (c″) 종료 코드 3 (error 있음) 인데 JSON 에 error 줄이 없다 — 옵션 파일 쪽 error 는 JSON 에 오지 않는다
  // (2026-10-16 실측, Dart 3.13.4: include 받는 파일의 깨진 YAML).
  if (outcome.exitCode == 3 && !lines.any((l) => l.split('  ')[1] == 'error')) {
    reasons.add('${outcome.name}: 종료 코드 3 인데 JSON 에 error 가 없다 (옵션 파일의 error — include 사슬)');
  }
```

머리 주석 (2′) 과 06-09 의 하네스 입력에 이 꼴을 더한다.

### WR-05: 인용 · 목록 · 단락 안에서 연 `<!--` 뒤의 `## ` 를 `changelogTop` 이 최상단으로 읽는다 — GitHub 화면에는 제목이 없는데 tag 모드가 통과한다

**File:** `tool/verify.dart:1709-1732` (`changelogTop`), `tool/verify.dart:1671-1682` (`firstElement`)
**Issue:** M100 (열 0 에서 연 HTML 주석 블록)은 닫혔다. 해석기가 HTML 블록으로 묶어 그 안의 `## ` 를 제목으로 보지 않는다. 그런데 `<!--` 를 줄 머리의 HTML 블록이 아닌 자리에서 열면 갈린다. 그런 자리는 셋이다.
- 인용 안 `> <!--`
- 목록 항목 안 `- <!--`
- 단락 중간 `<!-- a --> x <!--`

이 꼴에서는 CommonMark 블록 구조상 다음 줄의 `## 2.0.1 - …` 가 h2 다. 그래서 `package:markdown` 은 그것을 첫 h2 로 읽는다. 그러나 GitHub 은 닫히지 않은 `<!--` 를 출력 HTML 에 그대로 둔다. 그 뒤의 HTML 정리 단계가 그 자리부터 문서 끝까지를 주석으로 삼킨다.

GitHub 렌더 API 의 결과는 이렇다.
- 인용 꼴: `<blockquote>\n</blockquote>` 뿐이다
- 목록 꼴: 빈 `<li>` 뿐이다
- 단락 꼴: ` x` 뿐이다

셋 모두 h2 가 하나도 없다. 아래의 옛 `## 2.0.0 - 2026-10-15` 도 사라진다.

복제본에서 상태 C (M100 과 같은 준비 — `pubspec.yaml` `version: 2.0.1`, README 의 `ref: v2.0.0` 둘을 `v2.0.1` 로)를 만들었다. 그리고 `CHANGELOG.md` 맨 앞에 `> <!--` / `## 2.0.1 - 2026-10-16` / `-->` / 빈 줄을 넣었다. 이 상태에서 `checkShippedComposition` 이 `--tag v2.0.1` 과 평소 모드 모두 `passed=true` 였다. 목록 꼴(`- <!--`)도 `v2.0.1` 에서 `passed=true` 였다. 전체 실행은 M100 처럼 lock 여섯을 다시 받아야 하므로 하지 않았다. `GITHUB_REF_NAME` 경로는 `main` 이 같은 값을 `checkVersionAgreement` 에 넘기므로 판정이 같다 (`tool/verify.dart:3063-3066`).

결과는 릴리스 gate 의 거짓 통과다. GitHub 의 CHANGELOG 화면이 비어 있고 2.0.1 항목도 보이지 않는데, tag `v2.0.1` 검사가 통과한다. 받는 쪽 패키지(규칙 · 버전)에는 영향이 없고 문서 화면만 틀리므로 WARNING 으로 둔다. 문서 주석이 말하는 "HTML 주석 안의 열 0 `## ` 줄은 제목이 아니다" 와 같은 꼴(주석 뒤에 숨은 제목)이 다른 입력으로 남은 것이다.
**Fix:** 첫 h2 앞의 글자(raw HTML 포함)를 문서 순서로 모은다. 닫히지 않은 `<!--` 가 있으면 실패로 알린다. 아래 꼴은 하네스에서 54개 꼴 가운데 갈리는 셋만 잡았고, 지금 `CHANGELOG.md` 는 그대로 통과했다. 인라인 코드 안의 `<!--` 도 잡는 쪽으로 틀리지만(실패 방향), 최상단 제목 앞에 그런 글자가 올 일은 드물다.

```dart
/// 문서 순서로 [target] 앞의 글자(raw HTML 포함)를 [out] 에 모은다. [target] 을 만나면 true.
bool collectTextBefore(List<md.Node> nodes, md.Node target, StringBuffer out) {
  for (final node in nodes) {
    if (identical(node, target)) return true;
    if (node is md.Text) out.write(node.text);
    if (node is md.Element && node.children != null &&
        collectTextBefore(node.children!, target, out)) {
      return true;
    }
  }
  return false;
}
...
  final before = StringBuffer();
  collectTextBefore(nodes, heading, before);
  final s = before.toString();
  if (s.lastIndexOf('<!--') > s.lastIndexOf('-->')) {
    throw const FormatException(
      'CHANGELOG.md 의 첫 h2 앞에 닫히지 않은 `<!--` 가 있다 — GitHub 화면에서는 그 뒤가 주석으로 사라진다',
    );
  }
```

`example/README.md` 의 M 기록에 세 꼴(인용 · 목록 · 단락)을 더한다.

### WR-06: smoke 의 시간 제한이 하위 명령의 종료에만 걸려, 출력 파이프를 붙든 자손이 있으면 제한을 넘겨 기다린다

**File:** `tool/smoke.dart:419-433` (`runProcess`)
**Issue:** 제한은 `process.exitCode.then<int?>(…).timeout(timeout, …)` 에만 걸린다. 종료 코드를 받은 뒤의 `await out` · `await err` 에는 제한이 없다. 이 둘은 stdout · stderr 파이프의 쓰는 쪽이 모두 닫혀야 끝난다. 그래서 하위 명령이 끝나도, 파이프를 물려받은 자손이 살아 있으면 그 자손이 끝날 때까지 기다린다.

하네스에서 `runProcess('/bin/sh', ['-c', 'sleep 20 & echo hi'], timeout: 2초)` 를 불렀다. 결과는 `timedOut=false`, `exit=0`, `elapsed=20s` 였다. 제한 2초를 넘겨 20초를 기다렸다.

같은 상태에서 Ctrl-C 를 누르면 처리기의 `killTree(runningChild)` 가 이미 끝난 부모의 표를 읽는다. 자손은 부모가 끝날 때 pid 1 로 옮겨 가므로 표에 없다. 그래서 그 자손을 끊지 못한다. 머리 주석의 "넘으면 그 프로세스를 끊고" (`:42-43`) 와 WR-03 의 "멈추면 끝없이 기다린다" 를 막는다는 목적이 이 경로에서는 성립하지 않는다. 지금의 세 명령(`flutter create` · `pub get` · `dart analyze`)에서 이런 자손이 생긴 실측은 없다. 그래서 위험은 "모르는 멈춤" 의 한 갈래로 남는다.
**Fix:** 제한을 종료와 출력 수집 전체에 건다. 넘으면 지금처럼 `killTree` 뒤 `timedOut: true` 다.

```dart
    final all = Future.wait<Object>([process.exitCode, out, err])
        .then<List<Object>?>((v) => v)
        .timeout(timeout, onTimeout: () => null);
    final done = await all;
    if (done == null) {
      await killTree(process);
      watch.stop();
      await haltIfInterrupted();
      return (result: null, elapsed: watch.elapsed, timedOut: true);
    }
    final result = ProcessResult(process.pid, done[0] as int, done[1], done[2]);
```

## Info

### IN-04: 하위 명령의 출력이 UTF-8 이 아니면 처리되지 않은 비동기 예외(255)로 끝나 `finally` 의 정리를 건너뛴다

**File:** `tool/smoke.dart:419-420` (`utf8.decoder.bind(…).join()`), `tool/smoke.dart:46` (머리 주석의 255)
**Issue:** `out` · `err` future 는 `exitCode` 를 기다리는 동안 아무도 듣지 않는다. 시간 초과 경로에서는 끝까지 아무도 듣지 않는다. 이 사이에 디코더가 `FormatException` 을 내면 그 오류는 처리되지 않은 비동기 예외가 된다. isolate 가 바로 죽으므로 `main` 의 `finally` 도 돌지 않는다.

하네스에서 `runProcess('/bin/sh', ['-c', r'printf "\377\n"; sleep 1'])` 를 `try { … } finally { print(…) }` 안에서 불렀다. 결과는 종료 코드 255, `Unhandled exception: FormatException: Invalid UTF-8 byte (at offset 0)` 였고, `finally` 의 출력은 없었다. smoke 에서는 새 pub cache 가 든 임시 폴더가 남는다. 머리 주석의 "255 … 임시 폴더는 finally 가 지운다" 가 이 경로에서 틀린다. 세 명령이 UTF-8 이 아닌 바이트를 낼 일은 드물다.
**Fix:** `const Utf8Decoder(allowMalformed: true)` 로 디코딩한다. 그러면 출력은 화면 표시와 JSON 판정에만 쓰이고, 깨진 바이트는 `U+FFFD` 로 바뀐다. 아니면 두 future 에 띄우는 즉시 `.catchError` 를 붙인다.

### IN-05: SIGINT 처리기의 경합 창 둘 — 띄우는 중의 하위 명령을 기다리지 않고 끝내고, `finally` 는 처리기를 정리 전에 내린다

**File:** `tool/smoke.dart:406-417` (`runProcess` 의 띄우기), `tool/smoke.dart:961-971` (처리기), `tool/smoke.dart:997-1000` (`finally`)
**Issue:** 읽기로만 판정했다 (경합 시점을 재현하지 못했다).
1. `runningChild` 는 `await Process.start(…)` 가 돌아온 뒤에야 정해진다. 그 await 사이에 SIGINT 가 오면 처리기는 `runningChild == null` 을 본다. 그래서 끊을 것 없이 `cleanup()` 으로 임시 폴더를 지우고 `quit(130)` 에 들어간다. 본 흐름의 "띄우는 사이의 SIGINT" 분기(`:413-417`)는 `Process.start` 가 돌아온 뒤에야 돈다. 처리기의 `stdout.flush` · `stderr.flush` 가 먼저 끝나면, `exit(130)` 이 그 분기보다 먼저 일어난다. 그러면 이미 띄운 `flutter` · `dart` 는 끊기지 않은 채 남아, 지운 폴더를 다시 만든다. 06-09 Deviations 3 이 본 "지운 폴더가 다시 생김" 과 같은 결과다. 처리기가 본 흐름의 정리를 기다리는 장치가 없다.
2. `finally` 는 `await interrupts.cancel()` 을 `cleanup()` 앞에 둔다. 처리기를 내린 뒤의 SIGINT 는 기본 동작으로 프로세스를 바로 끝낸다. 그래서 새 pub cache 를 지우는 `deleteSync` 도중의 Ctrl-C 는 폴더를 반쯤 남긴다.

**Fix:**
1. 처리기에서 `runningChild` 가 없으면 진행 중인 띄우기를 기다린다. 예를 들어 `runProcess` 가 띄우기 전에 `Completer` 를 전역에 두고, 처리기가 그것을 기다린 뒤 `killTree` 한다.
2. `finally` 의 순서를 `cleanup(); await interrupts.cancel();` 로 바꾼다.

### IN-06: `killTree` 가 자손을 놓쳐도 알리지 않는다 — `/bin/ps` 실패 · 먼저 끝난 부모의 자손 · pid 재사용

**File:** `tool/smoke.dart:323-341` (`processTable`), `tool/smoke.dart:344-360` (`descendantsOf`), `tool/smoke.dart:369-390` (`killTree`)
**Issue:** 읽기로만 판정했다. SIGSTOP 부터 SIGKILL 까지는 동기 코드다(`Process.runSync` · `killPid`). 그 사이의 `ps` 실패는 `ProcessException` · 0 아닌 종료 코드에서 `null` 로 잡힌다. 그래서 프로세스가 얼린 채 남는 경로는 없다. 대신 아래 셋에서 조용히 덜 끊는다.
- (a) `/bin/ps` 가 없거나 실패하면 표가 `null` 이다. 그러면 부모 하나만 끊고 자손은 얼리지도 끊지도 않는다. 06-09 가 이 장치를 만든 이유가 그 자손(analysis server)이다. 그런데 화면에는 아무 말도 없다.
- (b) 부모가 이미 끝났으면(WR-06 의 경우, 또는 제한과 종료가 겹친 경우) 자손은 pid 1 아래로 옮겨 가 표의 나무에서 빠진다.
- (c) 표를 읽은 뒤 SIGSTOP 전에 끝난 자손의 pid 가 재사용되면, 남의 프로세스를 얼리고 끊는다. 가능성은 아주 낮다.

`ps` 출력 파싱(`trim` · 공백 나누기 · 두 칸 · `int.tryParse`)은 macOS · procps 의 `pid= ppid=` 꼴에서 문제없다.
**Fix:** (a) 는 `processTable()` 이 `null` 이면 stderr 에 "자손 프로세스를 찾지 못했다 — 부모만 끊었다" 한 줄을 남긴다. (b) 는 하위 명령을 새 프로세스 그룹으로 띄울 수 없으므로(`dart:io` 제약), 머리 주석에 "부모가 먼저 끝난 자손은 끊지 못한다" 를 적어 범위를 밝힌다. (c) 는 SIGKILL 직전에 표를 한 번 더 읽어, 부모 사슬이 여전히 `process.pid` 로 이어지는 pid 만 끊는다.

### IN-07: `main` 의 예외 안내가 SDK 경로 · 홈 폴더를 가리지 않는다

**File:** `tool/smoke.dart:990-995`
**Issue:** 읽기로만 판정했다. `runSmoke` 의 `scrubNames` (`:785-790`) 는 임시 폴더 · SDK root · 저장소 · 홈 넷을 가린다. 그러나 `main` 의 `FileSystemException` · `ProcessException` 안내는 임시 폴더 · 저장소 둘만 가린다. `ProcessException` 의 글자에는 실행 파일 경로(`<SDK root>/bin/flutter`)가 들어간다. SDK root 는 `Platform.resolvedExecutable` 에서 링크를 푼 경로라 보통 홈 폴더 아래다. 그래서 `flutter` 를 띄우지 못하면 절대 경로가 stderr 에 그대로 나온다. 머리 주석의 "화면에는 임시 폴더 경로를 찍지 않는다" 는 지켜지지만, `runSmoke` 와 가리는 범위가 다르다.
**Fix:** `scrubNames` 를 만드는 함수를 하나 두고(`work` 가 null 이면 그 항목만 뺀다), `runSmoke` 와 `main` 의 두 안내가 같이 쓴다.

### IN-08: `markdown` · `yaml` 의 범위 제약(`^`)과 커밋하지 않는 루트 lock 때문에, CI 가 받는 해석기 판이 고정되지 않는다

**File:** `pubspec.yaml:24-25`
**Issue:** 읽기로만 판정했다. 루트 `pubspec.lock` 은 `.gitignore` 대상이다 (라이브러리 관례). 그래서 새 복제본(CI)은 그때의 최신 `markdown` 7.x · `yaml` 3.x 를 받는다. `[3/10]` (i) 의 CHANGELOG 판정은 "GitHub 화면과 같게 읽는다" 를 `markdown` 7.3.1 에서 잰 결과(M100 ~ M106, 이 리뷰의 WR-02 · WR-05 표)에 기댄다. `package:markdown` 은 마이너 판에서 CommonMark 적합성을 바꿔 왔다. 그래서 같은 커밋이 다른 날 다른 판정을 낼 수 있고, 기록의 "7.3.1 실측" 도 CI 실행과 이어지지 않는다. `dev_dependencies` 이므로 판을 고정해도 받는 쪽에는 영향이 없다.
**Fix:** `markdown: 7.3.1` · `yaml: 3.1.4` 처럼 판을 고정한다. 판을 올릴 때 M 기록의 갈림 입력을 다시 재는 절차를 `example/README.md` 에 한 줄 적는다.

### IN-09: 의존성 문장이 "`package:yaml` 은 YAML 대조에만" 이라고 하나, (i) 는 YAML 값을 직접 쓴다

**File:** `.claude/skills/spike-findings-woody-lints/SKILL.md:52`, `.claude/skills/spike-findings-woody-lints/references/analyze-run-and-verdict.md:13`, `.claude/skills/spike-findings-woody-lints/references/rule-status-check.md:14`, `pubspec.yaml:19`, `tool/verify.dart:34-36`
**Issue:** 06-08 뒤의 `checkVersionAgreement` 는 `pubspecYamlVersion` 의 YAML 값을 판정의 값 자체로 쓴다. 줄 단위 reader 와 견주는 데 쓰는 것이 아니다. 그런데 같은 diff 에서 고친 skill 세 줄은 "`package:yaml` 은 YAML 대조에만" 이라고 한다. `pubspec.yaml` 19행과 `tool/verify.dart` 머리 주석도 "줄 단위로 읽은 값을 YAML 해석 결과와 견줄 때만 쓴다" 라고 한다. 다음 사람이 이 문장을 규칙으로 읽으면, (i) 의 YAML 직접 사용을 규칙 위반으로 되돌릴 수 있다. CR-01 이 다시 열리는 방향이다.
**Fix:** 다섯 자리의 문장을 "`package:yaml` 은 YAML 대조와 `pubspec.yaml` 의 version 읽기에만" 으로 고친다.

## 범위 밖으로 둔 것 (ID 없음)

- `.claude/CLAUDE.md` 의 "루트 `analysis_options.yaml` 의 exclude 가 반드시 유지되어야 한다" 줄은 낡았다. 같은 뜻의 `SKILL.md` 49행 "루트 `analysis_options.yaml` 은 기존 exclude 항목(`lib/analysis_options.yaml`)을 그대로 둔다" 도 같다. 소유자가 05 WR-06 으로 미뤘으므로 발견으로 적지 않았다.
- 계획 파일(`*-PLAN.md`)의 `<automated>` 단언 결함(`)\" =` 따옴표 등)은 알려진 것이고 리뷰 범위가 아니다.
- 머리말이 front matter(`---` / `title: …` / `---`)인 CHANGELOG 는 해석기가 h2 `title: …` 로 읽는다. GitHub 파일 화면은 front matter 를 표로 그린다고 알려져 있다. 그러나 렌더 API 는 그 처리를 하지 않아 파일 화면을 재지 못했다. 그래서 발견으로 적지 않았다. 이 꼴은 ` - ` 가 없으면 `FormatException` (70), 있으면 버전 글자가 `title: …` 가 되어 실패 쪽으로 간다.

---

_Reviewed: 2026-10-16T11:22:30Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
