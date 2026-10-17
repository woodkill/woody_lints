# Phase 5: Documentation - Pattern Map

**Mapped:** 2026-10-13
**Files analyzed:** 13 (새 파일 0 · 고치는 파일 13)
**Analogs found:** 12 / 13 (exact 9 · role-match 3 · 없음 1)

이 phase 는 새 파일을 만들지 않는다 — 산출물은 전부 문서(README · CHANGELOG · YAML 머리 주석 · `.claude/CLAUDE.md` 두 줄 · 처리 기록 셋 · `example/README.md` 의 M 기록)와 `tool/verify.dart` 의 검사 코드다. 그래서 analog 는 거의 모두 **고치는 파일 자신 또는 같은 파일의 이웃 함수 · 이웃 절**이다. 모든 analog 경로는 `git ls-files` 로 추적을 확인했다 (2026-10-13). 경로는 모두 저장소 루트 기준이다. 사용 프로젝트의 경로 · 진단 메시지 · 코드 조각은 넣지 않았다 (05-CONTEXT.md D-20).

줄 번호는 HEAD `e76e5ec` 기준이다. `tool/verify.dart` 는 1,859행이며 이 문서가 인용한 범위는 110 ~ 178 · 665 ~ 684 · 785 ~ 802 · 867 ~ 922 · 999 ~ 1013 · 1087 ~ 1101 · 1141 ~ 1225 · 1296 ~ 1440 · 1840 ~ 1859 행이다.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `tool/verify.dart` — `stripPlugins` (WR-02) | utility (전처리) | transform (문자열 → 문자열) | 같은 파일 `declaredRuleNames` 885-922 (줄 단위 걷기 · `^\S` 로 블록 닫기 · `FormatException`) + 05-RESEARCH.md § Code Examples 의 고친 판 (복제본에서 입력 10가지 확인) | exact |
| `tool/verify.dart` — `readShippedPluginConstraint` (WR-02 · (f) 가 재사용) | utility (값 읽기) | file-I/O → 문자열 | 자기 자신 1187-1203 (문구 · 예외 꼴 유지) + `declaredRuleNames` 의 "다음 줄 읽기" 꼴 | exact |
| `tool/verify.dart` — `declaredRuleNames(..., {required String shownAs})` · `countDeclaredRules` (IN-14) | utility | transform | 같은 파일 `stripPlugins` 793 의 `{required String shownAs}` 시그니처와 문구 `'$shownAs 의 …'` | exact |
| `tool/verify.dart` — `fragmentLineHint` 문구 (WR-02 와 같은 커밋) | config (상수 문구) | — | 자기 자신 169-172 | exact |
| `tool/verify.dart` — `[3/10]` (b′) 다른 조각에 규칙 없음 (WR-11 B안) | utility (검증 단계) | transform | 같은 함수 (b) 1369-1382 의 `addBlock` 꼴 + 04-REVIEW.md WR-11 의 Fix 코드 (05-RESEARCH.md § 2 에 인용) | exact |
| `tool/verify.dart` — `[3/10]` (d) README 표시 구역 ↔ `lib/base.yaml` | utility (검증 단계) | file-I/O → 비교 | 같은 함수 (c) `compareBlock` 1386-1424 + `readRulesMdBlock` 1302-1327 | exact |
| `tool/verify.dart` — `[3/10]` (e) · (f) · (g) README 의 주소 · plugin 버전 · `ref:` | utility (검증 단계) | file-I/O → 비교 | `checkFixtureOptions` 1149-1185 (`readShippedPluginConstraint` 를 기준값으로 쓰는 선례), `expectedLibYamls` 157-163, `checkRuleNames` 1087-1101 ("0개면 실패"), `significantLines` 1218-1225 | role-match (README 를 읽는 검사는 선례 없음 — 블록 안만 읽는 `fencedLines` 는 새 함수) |
| `README.md` (전면 재작성) | 문서 (사용 안내 + 검사가 읽는 표시 구역 · 코드 블록) | — | 표시 구역: `RULES.md` 5-14 · 93-104; include 블록: `fixtures/{recommended,base_only,base_riverpod,base_codegen,overrides}/analysis_options.yaml`; 끄는 주석: `fixtures/overrides/lib/suppress/*.dart`; 문제 해결 문장: 지금 `lib/riverpod.yaml` 4-8 · `README.md` 95 | role-match |
| `lib/base.yaml` · `lib/riverpod.yaml` · `lib/codegen.yaml` 머리 주석 (`recommended.yaml` · `analysis_options.yaml` 은 거의 그대로) | config (배포 조각) | — (선언) | `lib/analysis_options.yaml` 1-2 · `lib/recommended.yaml` 1-2 (지금 있는 2줄 한국어 머리 주석 — 무엇을 주는지 + 어느 주소를 쓰는지) | exact |
| `CHANGELOG.md` — 1.1.0 ~ 1.2.5 복원 7항목 | 문서 (옛 불릿 형식) | — | 같은 파일 `## 1.3.0` 187-193 (제목 꼴 · 불릿 · 하위 불릿 · "사용하는 프로젝트에는 영향 없음") + `VERSIONING.md` 74-75 의 `(날짜, 커밋)` 표기 | exact |
| `CHANGELOG.md` — 2.0.0 의 `### 올리기 전에` (D-06) · `### 그 밖의 변경` (D-07) | 문서 | — | 같은 항목 5-8 · 88-99 (고치는 자리 자신) + `VERSIONING.md` § "CHANGELOG 항목 형식" 77-85 | exact |
| `example/README.md` — 116행 `[3/10]` 설명 덧붙임, 소절 `### 추가 실측 — … (05-NN)` M32 ~ | 문서 (지워 보기 기록) | — | 같은 파일 289-310 의 04-13 소절 (실측 조건 줄 · 명령 줄 · 표 6열 · "읽는 법" · 되돌림 확인) | exact |
| `.planning/phases/{01,03,04}-*/0N-REVIEW-DISPOSITION.md` — WR-05 · WR-02 · WR-11 · IN-14 행 | planning 데이터 (frontmatter + 표) | — | `04-REVIEW-DISPOSITION.md` 148행 (`fixed` 행의 Source 꼴) · `03-REVIEW-DISPOSITION.md` 10행 (frontmatter `note:`) | exact |
| `.claude/CLAUDE.md` 71 · 181행 | 지시문 | — | 자기 자신 (두 줄만 바꾼다 — D-09) | 없음 (바꿔 쓸 선례 없음, 고칠 문구는 05-RESEARCH.md § 5 에 있다) |

## Pattern Assignments

### `tool/verify.dart` — `stripPlugins` (WR-02)

**Analog:** 같은 파일 `declaredRuleNames` (885-922) 의 줄 단위 걷기. 고친 판 전체는 05-RESEARCH.md § Code Examples "고친 `stripPlugins`" 에 있다 — 그대로 옮긴다.

**지금 코드** (793-802) — 정규식 한 번으로 섹션을 **지운다**. 줄 끝 주석 · 마지막 줄바꿈 없음 · CRLF · 섹션 안 빈 줄에서 `FormatException`(70) 이 난다:
```dart
String stripPlugins(String options, {required String shownAs}) {
  final stripped = options.replaceAll(
    RegExp(r'^plugins:\n(?:[ \t]+.*\n)+', multiLine: true),
    '',
  );
  if (RegExp(r'^plugins:', multiLine: true).hasMatch(stripped)) {
    throw FormatException('$shownAs 의 `plugins:` 섹션을 빼지 못했다');
  }
  return stripped;
}
```

**따를 꼴** — `declaredRuleNames` 의 블록 걷기 (896-906). 같은 방식으로 `plugins:` 줄에서 열고 `^\S` 비주석 줄에서 닫되, 섹션의 줄은 **빈 줄로 바꾼다** (줄 번호 보존):
```dart
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    // 주석 줄과 빈 줄은 블록을 닫지 않는다 — YAML 에서 열 0 주석은 블록 밖이 아니다 (04-REVIEW.md CR-02)
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    if (RegExp(r'^linter:').hasMatch(line)) {
      inLinter = true;
    } else if (RegExp(r'^\S').hasMatch(line)) {
      // 들여쓰기 없는 줄(다른 최상위 키)이 블록을 닫는다.
      inLinter = false;
    }
```

**지킬 것:** 뺀 뒤 `^plugins:` 가 남으면 같은 문구로 `FormatException` (마지막 안전장치는 유지). 문서 주석 785-792 의 "지운다" 를 "빈 줄로 바꾼다" 로. 부르는 자리는 `checkRuleNames` 1005-1011 하나다 (`shownAs: target`).

**함께 고칠 상수** — `fragmentLineHint` (169-172). 둘째 문장이 거짓이 된다:
```dart
const fragmentLineHint =
    '진단 줄의 폴더 이름이 조각 이름이다 — `lib/<이름>.yaml` 에서 그 줄을 고친다. '
    '복사본의 줄 번호는 원본과 같다 (`riverpod.yaml` 은 `plugins:` 섹션을 빼고 복사하므로 '
    '그 섹션 뒤에 적은 줄만 뺀 줄 수만큼 앞당겨진다).';
```
→ "복사본의 줄 번호는 원본과 같다 (`plugins:` 섹션은 빈 줄로 바꿔 복사한다)" 한 문장으로 (05-RESEARCH.md § 1 "함께 고칠 것").

---

### `tool/verify.dart` — `readShippedPluginConstraint` (WR-02, (f) 가 재사용)

**Analog:** 자기 자신 (1187-1203). 고친 판 전체는 05-RESEARCH.md § Code Examples 에 있다.

**지금 코드** — `^\s+riverpod_lint:\s*(\S+)\s*$` 라 줄 끝 주석과 맵 형식(`riverpod_lint:` / `version: ^3.1.9`)에서 "찾지 못했다" 로 70:
```dart
String readShippedPluginConstraint(String repoRoot) {
  final text = File('$repoRoot/lib/riverpod.yaml').readAsStringSync();
  final match = RegExp(
    r'^\s+riverpod_lint:\s*(\S+)\s*$',
    multiLine: true,
  ).firstMatch(text);
  if (match == null) {
    throw const FormatException(
      'lib/riverpod.yaml 에서 riverpod_lint 선언을 찾지 못했다',
    );
  }
  return match.group(1)!;
}
```

**지킬 것:** 돌려주는 값은 `^3.1.9` 꼴 그대로 (부르는 `checkFixtureOptions` 1151 이 `pluginConstraintToken` 자리에 글자 그대로 끼운다 — `fixtures/overrides/analysis_options.yaml:10` `version: ^3.1.9` 와 견준다). 실패 문구 "riverpod_lint 선언을 찾지 못했다" 는 유지 (M34 가 이 문구를 기대한다). 문서 주석 1187-1190 에 받는 꼴(줄 끝 주석 · 맵 형식)을 적는다. (f) 는 이 함수를 그대로 부른다 — 함수 하나를 `[4/10]` 과 `[3/10]` 이 함께 쓴다.

---

### `tool/verify.dart` — `declaredRuleNames(options, {required String shownAs})` (IN-14)

**Analog:** `stripPlugins` 793 의 시그니처 `String stripPlugins(String options, {required String shownAs})` 와 문구 `'$shownAs 의 …'`.

**지금 예외 문구** (911-917) — 파일 이름이 없다:
```dart
      if (match == null) {
        throw FormatException(
          '`linter:` 블록의 ${i + 1}행을 읽지 못했다 — '
          '목록 항목(`- 이름` · `- \'이름\'` · `- "이름"`, 뒤에 `# 주석` 가능)과 '
          '`rules:` 만 받는다 (04-REVIEW.md WR-10): $trimmed',
        );
      }
```
→ `'$shownAs 의 \`linter:\` 블록의 ${i + 1}행을 읽지 못했다 — …'`. 참조는 `04-REVIEW.md WR-10` 을 남는 기록 `04-REVIEW-DISPOSITION.md WR-10` 으로 (05-RESEARCH.md § 2 IN-14). M29 ~ M31 의 기록(`example/README.md` 297-301)이 옛 문구를 글자로 담고 있다 — 역사 기록이라 고치지 않는다.

**부르는 자리 셋 (모두 바꾼다):**
- `countDeclaredRules` 870: `int countDeclaredRules(String options) => declaredRuleNames(options).length;` → 같은 `shownAs` 인자를 받아 넘긴다. 부르는 1089행 `countDeclaredRules(rulesCopy)` → `shownAs: rulesFile`.
- `checkShippedComposition` 1371: `final declared = declaredRuleNames(baseText);` → `shownAs: rulesFile`.
- 새 (b′) — `shownAs: target`.

문서 주석 867-870 · 977-983 에 "읽지 못하는 줄이 있으면 `FormatException` (main 이 70)" 을 더한다.

---

### `tool/verify.dart` — `[3/10]` (b′) 다른 조각에 규칙 없음 (WR-11 B안)

**Analog:** 같은 함수의 (b) 블록 (1369-1382) — 읽기 → 목록 → `addBlock([머리 한 줄, ...항목 두 칸 들여쓰기])`:
```dart
  // (b) 기반 세트와의 겹침.
  final baseText = File('$repoRoot/$rulesFile').readAsStringSync();
  final declared = declaredRuleNames(baseText);
  final upstream = readUpstreamRules(repoRoot);
  final overlapping = [
    for (final rule in declared)
      if (upstream.containsKey(rule.toLowerCase())) rule,
  ]..sort();
  if (overlapping.isNotEmpty) {
    addBlock([
      '`$rulesFile` 의 규칙이 기반 세트와 겹친다 (${overlapping.length}) — 기반 세트가 이미 켜므로 지운다.',
      ...overlapping.map((r) => '  $r  (${upstream[r.toLowerCase()]})'),
    ]);
  }
```

**넣을 자리:** (a) 뒤, (b) 앞. 대상은 `ruleCheckTargets` (142-146) 에서 `rulesFile` (151) 을 뺀 둘 (`lib/codegen.yaml` · `lib/riverpod.yaml`). 코드는 04-REVIEW.md WR-11 의 Fix 그대로이고 05-RESEARCH.md § 2 에 인용되어 있다 (`'\`$target\` 에 규칙이 있다 (${extra.length}) — 규칙은 \`$rulesFile\` 에만 적는다.'`). `riverpod.yaml` 의 `plugins:` 는 `declaredRuleNames` 가 `linter:` 블록만 보므로 그대로 넘겨도 된다.

**문서 주석:** `checkShippedComposition` 의 머리 (1329-1338) 는 확인 항목을 `- (a)` · `- (b)` · `- (c)` 불릿으로 적는다 — (b′) · (d) ~ (g) 를 같은 꼴로 더한다. `includeOnlyFiles` 120행 "규칙은 `lib/base.yaml` 에만 적는다" 와 (a) 실패 문구 1365행 `'규칙은 \`lib/base.yaml\` 에만 적는다 (03-REVIEW.md WR-01).'` 이 같은 관례를 말한다 — (b′) 의 문구도 이 둘과 같은 어투로.

---

### `tool/verify.dart` — `[3/10]` (d) README 표시 구역 ↔ `lib/base.yaml`

**Analog:** 같은 함수의 `compareBlock` (1386-1424) 과 `readRulesMdBlock` (1302-1327).

**마커 읽기** (1302-1327) — 마커 두 줄을 `indexOf` 로 찾고, 사이의 `|` 줄 첫 칸에서 backtick 이름 하나를 읽는다. 파일이나 마커가 없으면 `null`, 첫 칸에 이름이 둘 이상이면 `malformed`:
```dart
RulesMdBlock? readRulesMdBlock(File rulesMd, String name) {
  if (!rulesMd.existsSync()) return null;
  final lines = rulesMd.readAsLinesSync();
  final start = lines.indexOf('<!-- woody:$name:start -->');
  final end = lines.indexOf('<!-- woody:$name:end -->');
  if (start < 0 || end < 0 || end < start) return null;
  final names = <String>[];
  final malformed = <String>[];
  final namePattern = RegExp(r'`([a-z0-9_-]+)`');
  for (final line in lines.sublist(start + 1, end)) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('|')) continue;
    final cellEnd = trimmed.indexOf('|', 1);
    final cell = cellEnd < 0
        ? trimmed.substring(1)
        : trimmed.substring(1, cellEnd);
    final found = namePattern.allMatches(cell).map((m) => m.group(1)!).toList();
    if (found.isEmpty) continue;
    if (found.length > 1) {
      malformed.add(trimmed);
    } else {
      names.add(found.single);
    }
  }
  return RulesMdBlock(names, malformed);
}
```
README 목록을 **표**로 쓰면 이 함수를 그대로 `readRulesMdBlock(File('$repoRoot/README.md'), 'readme-rules')` 로 부른다. **불릿**으로 쓰면 `trimmed.startsWith('|')` → `startsWith('- ')` 와 "첫 칸" 대신 줄 전체에서 `namePattern` 을 읽는 10줄 변형 하나를 둔다 (05-RESEARCH.md Open Question 2 는 불릿을 권한다). 반환 타입 `RulesMdBlock`(이름 · malformed) 은 그대로 재사용한다.

**비교와 실패 문구** (1386-1424) — 구역 없음 / malformed / 정렬 뒤 `subtractLines` 양방향 `+`/`-`:
```dart
  void compareBlock({
    required String block,
    required List<String> shipped,
    required String mismatchLine,
  }) {
    final listed = readRulesMdBlock(rulesMd, block);
    if (listed == null) {
      addBlock([
        '`$rulesMdFile` 의 `woody:$block` 구역이 없다 — 04-CONTEXT.md D-08',
        '',
        '`<!-- woody:$block:start -->` 와 `<!-- woody:$block:end -->` 사이에 표를 둔다.',
      ]);
      return;
    }
    if (listed.malformed.isNotEmpty) {
      addBlock([ /* … 첫 칸의 이름이 둘 이상인 행 … */ ]);
    }
    final a = [...shipped]..sort();
    final b = [...listed.names]..sort();
    if (sameLines(a, b)) return;
    addBlock([
      mismatchLine,
      ...subtractLines(a, b).map((r) => '  + $r  (base.yaml 에만)'),
      ...subtractLines(b, a).map((r) => '  - $r  ($rulesMdFile 에만)'),
      '',
      '`$rulesMdFile` 의 표와 `$rulesFile` 을 같은 커밋에서 고친다.',
    ]);
  }

  compareBlock(
    block: 'enabled-rules',
    shipped: declared,
    mismatchLine: '`$rulesMdFile` 의 켠 규칙 표와 `$rulesFile` 의 규칙 목록이 다르다.',
  );
```
(d) 는 `compareBlock` 에 "읽을 파일" 매개변수를 더하거나(`rulesMd` 가 지역 변수로 고정되어 있다) 같은 꼴을 README 용으로 한 번 더 쓴다. `+ x  (base.yaml 에만)` / `- x  (README.md 에만)` 기호를 지키면 M37 의 기록이 M21 · M27 과 같은 화면이 된다. 마지막 안내 줄은 세 곳 — `` `README.md` 의 목록 · `RULES.md` 의 표 · `lib/base.yaml` 을 같은 커밋에서 고친다. ``

**상수 자리:** `rulesMdFile` (135) 옆에 `readmeFile = 'README.md'` · `readmeRulesBlock = 'readme-rules'` 를 같은 문서 주석 꼴(`/// … (저장소 루트 기준). \`[3/N]\` 이 …`)로 둔다.

---

### `tool/verify.dart` — `[3/10]` (e) · (f) · (g) README 의 주소 · plugin 버전 · `ref:`

**Analog (기준값을 조각에서 읽어 견주는 선례):** `checkFixtureOptions` (1149-1159):
```dart
StepResult checkFixtureOptions(String repoRoot, List<Fixture> fixtures) {
  // 조각의 plugin 선언 — optionsLines 의 [pluginConstraintToken] 자리에 넣어 견준다.
  final shippedConstraint = readShippedPluginConstraint(repoRoot);
  final details = <String>[];
  for (final fixture in fixtures) {
    final optionsPath = '${fixture.path}/analysis_options.yaml';
    final file = File('$repoRoot/$optionsPath');
    final expected = [
      for (final line in fixture.optionsLines)
        line.replaceAll(pluginConstraintToken, shippedConstraint),
    ];
```
(f) 도 `readShippedPluginConstraint(repoRoot)` 를 기준값으로 쓴다. 다른 값이 있으면 그 값들을 나열한다 — 실패 문구 안은 05-RESEARCH.md § 2 의 표.

**Analog (집합 기준):** `expectedLibYamls` (157-163) — (e) 가 README 의 `package:woody_lints/<이름>.yaml` 이름을 이 집합과 `difference` 로 견준다:
```dart
const expectedLibYamls = {
  'analysis_options.yaml',
  'base.yaml',
  'codegen.yaml',
  'recommended.yaml',
  'riverpod.yaml',
};
```

**Analog ("0개면 실패" — 헛통과 방지):** `checkRuleNames` (1087-1101):
```dart
    // 규칙을 하나도 읽지 못했으면 아래의 "문제 0건" 은 본 것이 없다는 뜻이다 —
    // `linter:` 키의 오타, 규칙을 include 뒤의 다른 파일로 옮긴 경우.
    if (countDeclaredRules(rulesCopy) == 0) {
      return StepResult(
        label: label,
        passed: false,
        detailLines: [
          '`$rulesFile` 의 최상위 `linter:` 블록 안에서 '
              '`- 규칙이름` 줄을 하나도 세지 못했다.',
```
(e) · (f) · (g) 모두 README 에서 읽은 값이 0개면 `addBlock` 으로 실패한다 — "일치" 가 아니다.

**Analog (읽을 수 없는 입력 → 70):** `main` 의 예외 처리 (1847-1849) — 새 `pubspecReleaseVersion` 이 `version:` 을 못 읽으면 `FormatException` 을 던지면 이 자리가 받는다:
```dart
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    exitCode = 70;
```
`README.md` 가 없으면 `readAsLinesSync` 의 `FileSystemException` 이 1850-1854 에서 70 으로 끝난다 — 별도 처리 불필요.

**새 함수 둘** (`fencedLines` · `pubspecReleaseVersion`) 은 선례가 없다 — 05-RESEARCH.md § Code Examples 의 뼈대를 쓰고, 문서 주석은 `significantLines` (1214-1217) 의 꼴("무엇을 돌려주는가 · 어느 단계가 쓰는가 · 없으면 무엇인가") 로 적는다. `pubspec.yaml` 3행은 `version: 2.0.0-dev` 라 `^version:\s*(\d+\.\d+\.\d+)` 가 `2.0.0` 을 준다.

**README 를 쓸 때의 규칙 (검사가 읽는 자리):** (f) · (g) 는 ``` 블록 **안**의 `version:` · `riverpod_lint:` · `ref: v…` 줄만 읽는다 — 끄기 예시의 `version: ^3.1.9` 와 설치 블록의 `ref: v2.0.0` 은 블록 안에, "1.3.0 → 2.0.0" · "`ref: v1.3.0` 에 머문다" 같은 역사 문장은 산문에 둔다 (05-RESEARCH.md Pattern 2). (e) 는 파일 전체에서 읽으므로 옛 주소 `package:woody_lints/analysis_options.yaml` 을 산문에 적어도 `lib/` 에 실재해 통과한다.

---

### `README.md` (전면 재작성)

**Analog 1 — 표시 구역:** `RULES.md` 5-14 · 93-104. 머리 문장 → 마커 → 내용 → 마커. 마커 이름은 `woody:<이름>:start` / `:end` 한 줄씩, 앞뒤에 다른 글자 없음 (`readRulesMdBlock` 이 `indexOf` 로 **글자 그대로** 찾는다 — 들여쓰기 · 뒤 공백도 안 된다):
```markdown
## 켠 규칙

`lib/base.yaml` 의 `linter: rules:` 에 적힌 규칙이다. "켠 이유" 는 `lib/base.yaml` 의 사유 주석과 같은 문장이다.

<!-- woody:enabled-rules:start -->
| 규칙 | 분류 | 켠 이유 | 실측 (lib · test · bin) | dart fix | 회차 |
|---|---|---|---|---|---|
| `prefer_const_constructors` | 성능 | … | 0 · 0 · 0 (표식 검출) | 해당 없음 | R1-B0 · R1-B0-strip |
…
<!-- woody:enabled-rules:end -->
```
README 는 구역 이름을 `readme-rules` 로 (RULES.md 와 다르게 — grep 이 갈린다), 내용은 분류 소제목 넷(`lib/base.yaml` 19 · 31 · 77 · 103행의 `# 성능` · `# 가독성 및 스타일` · `# 버그 방지` · `# strict — …`) 아래 `` - `rule_name` `` 불릿 (D-01 · D-16). 81개는 손으로 치지 않고 05-RESEARCH.md § Code Examples 의 `awk` 로 생성한다. 구역 안에는 **이름 외의 backtick 식별자를 두지 않는다** — reader 가 `` `[a-z0-9_-]+` `` 를 모두 이름으로 읽는다.

**Analog 2 — include 블록 넷 (글자 그대로):**
```yaml
# fixtures/recommended/analysis_options.yaml
include: package:woody_lints/recommended.yaml
```
```yaml
# fixtures/base_only/analysis_options.yaml
include: package:woody_lints/base.yaml
```
```yaml
# fixtures/base_riverpod/analysis_options.yaml
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/riverpod.yaml
```
```yaml
# fixtures/base_codegen/analysis_options.yaml
include:
  - package:woody_lints/base.yaml
  - package:woody_lints/codegen.yaml
```
2 × 2 표는 `example/README.md` 56-66 의 "연습용 프로젝트 여섯" 표와 05-CONTEXT.md `<specifics>` 의 표를 따른다.

**Analog 3 — 프로젝트 전체에서 끄기:** `fixtures/overrides/analysis_options.yaml` 1-12 (주석은 fixture 의 것):
```yaml
include: package:woody_lints/recommended.yaml

# 프로젝트 전체에서 끄기 — 규칙 하나 (맵 문법) 와 plugin 진단 하나 (version 을 함께 적는다).
linter:
  rules:
    prefer_final_locals: false

plugins:
  riverpod_lint:
    version: ^3.1.9
    diagnostics:
      missing_provider_scope: false
```
`version: ^3.1.9` 는 (f) 가 읽는 값 — 블록 안에 둔다.

**Analog 4 — 파일 · 한 줄 주석으로 끄기:** `fixtures/overrides/lib/suppress/`
- `lint_file.dart:1` `// ignore_for_file: prefer_single_quotes`
- `lint_line.dart:2` `// ignore: prefer_single_quotes` (3행 `const String lintLineOff = "a";` 의 윗줄)
- `plugin_file_prefixed.dart:1` `// ignore_for_file: riverpod_lint/provider_parameters`
- `plugin_line.dart:8` `// ignore: riverpod_lint/provider_parameters` (윗줄 꼴), `:12` `final c = ref.watch(lineFamily([3])); // ignore: riverpod_lint/provider_parameters` (줄 끝 꼴)
- 안 꺼지는 대조: `plugin_file_unprefixed.dart:1` `// ignore_for_file: provider_parameters`, `plugin_line.dart:10` `// ignore: provider_parameters` — README 의 "함정" 예시

**Analog 5 — 문제 해결 절로 옮길 문장 (출처 그대로):** 지금 `lib/riverpod.yaml` 4-8:
```yaml
# plugin 은 프로젝트 pubspec.lock 과 별도로 Dart Analysis Server 의 plugin 캐시
# (~/.dartServer/.plugin_manager)에서 해석된다.
# 이 섹션을 바꾼 뒤에는 Dart Analysis Server 를 재시작해야 반영된다.
# 결과 확인은 `dart analyze` 로 한다 — Flutter 3.47.5 의 `flutter analyze` 는
# plugin 진단을 표시하지 않았다 (3.41.9 는 표시, 2026-09-20 실측).
```
와 `README.md:95` 의 plugin 문단. "버전과 날짜를 붙인 실측 문장" 의 꼴(`Flutter 3.47.5 의 … (3.41.9 는 표시, 2026-09-20 실측)`)을 D-14 의 다른 문장(베타 3.14, spike 016)에도 그대로 쓴다.

**설치 블록의 값:** `pubspec.yaml:8` `repository: https://github.com/woodkill/woody_lints.git` 이 `url:` 과 글자 같아야 한다. `ref: v2.0.0` 은 `pubspec.yaml:3` `version: 2.0.0-dev` 의 꼬리 뗀 값 — (g) 가 견준다. 지금 README 25-30 의 `dev_dependencies:` 아래 `woody_lints: git: url:` 들여쓰기 꼴은 그대로 쓸 수 있다 (`ref: main` 만 `ref: v2.0.0` 으로).

**지울 것:** README 1-12 템플릿 HTML 주석, 16-21 `## 핵심가치`, 70-95 의 옛 목록 (81행 `require_trailing_commas`, 91-92 `formatter:` 가 불일치 2건) — 05-RESEARCH.md § 4 "지울 줄" 표.

---

### `lib/base.yaml` · `lib/riverpod.yaml` · `lib/codegen.yaml` 머리 주석 (D-08)

**Analog:** 이미 D-08 꼴(2줄, 한국어, 무엇을 주는지 + 주소)인 두 파일:
```yaml
# lib/analysis_options.yaml:1-2
# 옛 주소 (package:woody_lints/analysis_options.yaml) 의 별칭 — 묶음(recommended.yaml) 과 같다.
# 새 프로젝트는 package:woody_lints/recommended.yaml 을 include 한다.
```
```yaml
# lib/recommended.yaml:1-2
# woody_lints 묶음 — 기본 규칙 + Riverpod plugin + 코드 생성 설정을 한 번에 받는다.
# 조각을 골라 받으려면 아래 셋 가운데 필요한 것만 include 한다.
```
세 파일도 같은 어투로 2 ~ 4줄: 무엇을 주는지 → include 주소 → **왜 이 모양인지 한 줄** → "자세한 것은 README / `RULES.md`".

**`lib/riverpod.yaml`** — 1-3행의 "왜 최상위 `plugins:` 인가" 는 줄여 남기고 4-8행은 README 로 (위 Analog 5). 9-10행 `plugins:` / `  riverpod_lint: ^3.1.9` 는 그대로 — 줄 끝 주석을 달려면 **WR-02 를 먼저 닫는다** (지금은 70).

**`lib/codegen.yaml`** — 1-6행 `analyzer:` / `errors:` / `invalid_annotation_target: ignore` / `exclude:` / `'**/*.freezed.dart'` / `'**/*.g.dart'` 위에 머리 주석 신설. 제외가 SDK 에 따라 사용 프로젝트에 닿지 않을 수 있다는 안내는 README 에 (주석에는 한 줄 참조만).

**`lib/base.yaml`** — 지울 줄은 1-12 (템플릿 영어) · 15 (`# Uncomment the following section…`) · 108-112 (`# For more information …` · `# For additional information …`). 13행 `include: package:flutter_lints/flutter.yaml`, 17-18 `linter:` / `rules:`, 분류 주석 19 · 31 · 77 · 103, 규칙 81줄의 줄 끝 사유 주석은 그대로.

**지킬 것 — `[3/10]` (a) 와 정답지:** `lib/recommended.yaml` · `lib/analysis_options.yaml` 은 `includeOnlyFiles` (122-132) 가 주석 · 빈 줄을 뺀 줄을 글자 그대로 고정한다 — `#` 줄만 바꾼다. 규칙 줄을 건드리지 않으므로 커밋 뒤 `fvm dart run tool/verify.dart --update` 는 `바뀐 정답지가 없다 — 쓰지 않았다` 여야 한다.

---

### `CHANGELOG.md` — 1.1.0 ~ 1.2.5 복원 7항목 (D-05)

**Analog:** 같은 파일 `## 1.3.0` (187-193) — 옛 불릿 형식. 제목은 `## X.Y.Z` (날짜 없음), 불릿 → 하위 불릿(원인 · 영향), 저장소 안쪽 변경은 "사용하는 프로젝트에는 영향 없음" 으로 끝맺는다:
```markdown
## 1.3.0

- riverpod_lint 를 최상위 `plugins:` (analysis_server_plugin) 방식으로 전환.
  - 옛 `analyzer: plugins: - riverpod_lint` 선언은 riverpod_lint 3.x 에서 아무것도 로드하지 않아 규칙이 실행된 적이 없었다 → 이번 버전부터 riverpod_lint 규칙이 처음으로 켜진다.
  - Dart 3.13 (Flutter 3.47) 의 `included_file_warning` (legacy plugin deprecated) 해소.
- `flutter_lints` 를 `dev_dependencies` → `dependencies` 로 이동. `include: package:flutter_lints/flutter.yaml` 이 사용하는 프로젝트의 직접 의존 여부와 무관하게 해석된다.
- 저장소 자체 분석용 루트 `analysis_options.yaml` 추가 — … 사용하는 프로젝트에는 영향 없음.
```

**날짜 · 커밋 표기의 선례:** `VERSIONING.md` 74-75:
```markdown
- `1.2.3` (2026-01-28, `9451f6b`) — `slash_for_doc_comments` 규칙을 추가했는데 당시에는 patch 로 냈다 → 지금 정책이면 minor (2번에서 멈춤).
- `1.2.4` (2026-02-27, `212365d`) — `public_member_api_docs` 규칙을 추가하고 `analyzer:` 의 exclude / errors 설정을 넣었는데 당시에는 patch 로 냈다 → 지금 정책이면 minor (2번에서 멈춤).
```
복원 항목은 `## 1.2.3` 제목 아래 첫 줄에 `2026-01-28, 커밋 \`9451f6b\` (tag 없음)` 꼴 한 줄 → 불릿 (05-RESEARCH.md § 3 권고). 제목에 ` - 날짜` 를 붙이는 2.0.0 꼴은 쓰지 않는다 (REL-03 은 최상단만 읽어 어느 쪽이든 영향 없음). 내용은 05-RESEARCH.md § 3 의 버전별 diff 표만 — 1.2.4 의 옛 방식 `analyzer: plugins: - riverpod_lint` 를 빠뜨리지 않고, 1.2.1 · 1.2.2 는 "설정 변경 없음 (같은 날 README 수정)". 1.0.0 항목(195-197 `- Initial version.`)은 건드리지 않는다. 새 항목 7개는 `## 1.3.0` 과 `## 1.0.0` 사이에 내림차순으로.

---

### `CHANGELOG.md` — 2.0.0 의 `### 올리기 전에` (D-06) · `### 그 밖의 변경` (D-07)

**Analog:** 고치는 자리 자신.

**`### 올리기 전에`** (5-8) — 지금 두 줄:
```markdown
### 올리기 전에

- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.
- 옛 주소 한 줄을 쓰는 프로젝트는 고칠 것이 없다. 새 프로젝트는 `package:woody_lints/recommended.yaml` 을 include 한다.
```
두 줄 유지 + "받는 때" 한 문단(`ref: main` 은 `main` 병합 뒤 `pub upgrade woody_lints` 때 — `pub get` 으로는 받지 않는다, spike 015) + README "버전 올리기" 절 링크. `VERSIONING.md` 82행이 이 칸을 "받는 쪽이 고쳐야 하는 것" 으로 정한다.

**`### 그 밖의 변경`** (88-99) — 불릿 10개. 남길 것: 91 (프리셋 분리) · 92 (별칭) · 94 (plugin 하한) · 95 (겹침 6 · 주석 3 삭제) · 96 앞부분 (`RULES.md` 추가 — 따로 한 줄) · 98 (사유 주석 셋). 합칠 것 → "저장소 안쪽: … — 사용하는 프로젝트에는 영향 없음" 한 줄: 90 · 93 · 96 뒷부분(`[3/10]` 단계 추가) · 97 · 99. 합친 줄의 꼴은 지금 불릿의 끝맺음 `사용하는 프로젝트에는 영향 없음.` 을 그대로 쓴다. 이 phase 의 README · YAML 주석 정리는 새 불릿 하나 (받는 쪽에 보이는 문서 변경).

**건드리지 않는 것:** 1행 `## 2.0.0 - 미출시`, 3행 `지원 SDK: …`, `### 추가한 규칙` 75 불릿, `### 새로 생기는 경고` 표 74행 + 실측 한 줄 (D-17 — 확인만: 05-RESEARCH.md § 3 의 `sed | grep -c` 명령).

---

### `example/README.md` — `[3/10]` 설명 덧붙임 · M32 ~ 기록

**Analog:** 같은 파일 289-310 의 `### 추가 실측 — 따옴표로 감싼 규칙 이름 · 읽지 못하는 줄 (04-13)` 소절. 꼴은 다섯 조각 — (1) 제목 `### 추가 실측 — <무엇> (05-NN)`, (2) 조건 줄, (3) 명령 · 변경 자리 · 되돌림 방법 한 문단, (4) 6열 표, (5) "읽는 법" 불릿 + 되돌림 확인 문장:
```markdown
### 추가 실측 — 따옴표로 감싼 규칙 이름 · 읽지 못하는 줄 (04-13)

실측 (04-13): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13

실행한 명령: `fvm dart run tool/verify.dart` (연습용 프로젝트 여섯 · 단계 10개). 변경은 한 번에 하나만 만들고, …

| # | 변경 | 실패한 단계 | 정답지와의 차이 | 종료 코드 | 항목 |
|---|------|-------------|-----------------|-----------|------|
| M27 | 한 줄 `    - 'avoid_print' # …` | `[3/10]` 만. `[2/10]` 과 `[5/10]` ~ `[10/10]` 은 통과 | 차이 없음. `[3/10]` 이 낸 줄:<br>`` `lib/base.yaml` 의 규칙이 기반 세트와 겹친다 (1) — … ``<br>`+ avoid_print  (base.yaml 에만)` | 1 | RULES-01 · RULES-06 · D-11 — 04-REVIEW.md WR-10 |
| M29 | 한 줄 `    - avoid_print: true # 읽지 못하는 꼴 (맵 항목)` | 단계를 돌리지 못했다 — 예외는 `[2/10]` 이 … | 화면 없음 (stdout 비어 있음). stderr 한 줄:<br>`` 파일 모양이 예상과 다르다: … `` | 70 | D-11 — WR-10 |

읽는 법은 다음과 같다.

- **M27 은 고치기 전에는 열 단계를 모두 통과했다.** …

변경은 모두 커밋하지 않고 되돌렸다 (`git status` 와 `lib/base.yaml` 을 HEAD 와 견준 `git diff` 로 확인). 끝에 검증 명령이 다시 종료 코드 0, `점검 통과 (10개 중 10개)` 인 것을 봤다.
```
다음 번호는 **M32** (301행이 M31). 통과 행(M32 · M33 — 고치기 전 70 이었던 입력)은 같은 표에 "실패 없음 · 차이 없음 · 0" 으로 두고 읽는 법에 적는다 (05-RESEARCH.md Open Question 3). `실패한 단계` 칸의 표기 `` `[3/10]` 만. `[2/10]` 과 `[5/10]` ~ `[10/10]` 은 통과 `` 와 `종료 코드` 70 행의 `화면 없음 (stdout 비어 있음). stderr 한 줄:` 꼴을 그대로 쓴다. 마지막 각주 문단(312행)의 "0N-NN 소절의 `D-NN` 은 `…/0N-CONTEXT.md` 의 결정 번호다" 에 05 를 한 문장 더한다.

**116행 (단계 설명 전체)** — `[3/10]` 괄호 안의 열거(`묶음 … 담는지, … 겹치지 않는지, … 같은지.`) 에 (b′) · (d) ~ (g) 를 같은 어투로 덧붙이고, 109행 종료 코드 70 의 괄호에 "`pubspec.yaml` 에서 `version:` 을 읽지 못한 경우" 를 더한다. M20 ~ M31 과 `10개 중 10개` 는 그때의 실행 기록이라 고치지 않는다.

---

### `.planning/phases/{01,03,04}-*/0N-REVIEW-DISPOSITION.md` — 처리 기록 행 넷 (D-19)

**Analog:** `04-REVIEW-DISPOSITION.md` 148행 — `fixed` 행의 Source 꼴 `<plan> Task N (<커밋>) — <한 줄>; <재리뷰 메모>`:
```markdown
| WR-10 | warning | fixed | 04-13-PLAN.md Task 1 (67d1bc7) — declaredRuleNames 가 따옴표 이름을 읽고 linter: 블록 안의 읽지 못하는 줄에서 FormatException (70), README M27 ~ M31; 재리뷰 고쳐짐 확인 (같은 꼴의 다른 조각 파일은 새 발견 WR-11) (not in the current review) |
```
frontmatter 는 `03-REVIEW-DISPOSITION.md` 10-15 의 `disposition:` + `note:` 쌍을 함께 고친다:
```yaml
  - id: WR-02
    severity: warning
    disposition: deferred
    title: "`lib/riverpod.yaml` 을 YAML 로 문제없게 고쳐도 검증이 종료 코드 70 으로 멈춘다 (재현함)"
    note: "Phase 5 의 첫 일 — YAML 머리 주석(DOCS-10)을 고치기 전에 닫는다 (04-CONTEXT.md D-12, ROADMAP Phase 5 Notes)"
```
고칠 행과 지금 상태: `01-REVIEW-DISPOSITION.md` WR-05 (frontmatter 10-13 `open`, 표 80행 `| WR-05 | warning | open | - |`) → `fixed`, Source 는 CHANGELOG D-06 의 커밋; `03-REVIEW-DISPOSITION.md` WR-02 (11-15 `deferred`, 표 75행) → `fixed` + M32 ~ M34; `04-REVIEW-DISPOSITION.md` WR-11 (34-37 `deferred`, 표 134행) → `fixed` + M35, IN-14 (86-89 `open`, 표 147행 `| IN-14 | info | open | - |`) → `fixed` + M36. frontmatter 의 `open:` 수(04 는 `open: 18`)도 같이 줄인다 — 01 · 03 파일의 같은 키를 확인해서 고친다.

---

### `.claude/CLAUDE.md` 71 · 181행 (D-09)

**Analog:** 없음 — 지금 줄을 바꾸는 것이고 선례가 필요하지 않다. 바꿀 두 줄은 05-RESEARCH.md § 5 에 전문이 있다:
- 71행 `- 규칙은 \`lib/analysis_options.yaml\` 의 분류 주석(성능 / 가독성 및 스타일 / 버그 방지) 아래에 추가하고, \`README.md\` 의 "포함된 규칙 목록" 과 \`CHANGELOG.md\`, \`pubspec.yaml\` 의 \`version\` 을 함께 갱신한다.` → `lib/base.yaml` 의 분류 주석(… / strict) 아래에 더하고, `RULES.md` 켠 규칙 표 · README 표시 구역 · CHANGELOG 를 같은 커밋에서 고친다 (검증 명령 `[3/10]` 이 셋의 일치를 본다).
- 181행 `- YAML 주석은 한국어로 쓴다. 템플릿에서 온 영어 주석(\`lib/analysis_options.yaml\` 1-12행, 60-64행)은 그대로 둔다.` → 템플릿에서 온 영어 주석은 두지 않는다 (2.0.0 에서 지웠다).

같은 절차를 적은 다른 줄은 없다 (`grep -n "포함된 규칙 목록\|템플릿에서 온 영어 주석\|분류 주석.*아래에 추가"` → 71 · 181 둘뿐). 69 · 70 · 182-183행의 낡은 서술은 손대지 않는다.

## Shared Patterns

### 실패 블록의 모양 — `addBlock([머리 한 줄, ...항목 두 칸 들여쓰기, '', 안내 한 줄])`
**Source:** `tool/verify.dart` `checkShippedComposition` 1341-1344 · 1355-1366 · 1411-1417
**Apply to:** (b′) · (d) ~ (g) 전부
```dart
  final details = <String>[];
  void addBlock(List<String> lines) {
    if (details.isNotEmpty) details.add('');
    details.addAll(lines);
  }
  // …
    addBlock([
      mismatchLine,
      ...subtractLines(a, b).map((r) => '  + $r  (base.yaml 에만)'),
      ...subtractLines(b, a).map((r) => '  - $r  ($rulesMdFile 에만)'),
      '',
      '`$rulesMdFile` 의 표와 `$rulesFile` 을 같은 커밋에서 고친다.',
    ]);
```
머리 줄은 backtick 경로 + 건수 `(N)`, 항목은 두 칸, 마지막은 "무엇을 고치면 되는가" 한 줄. 단계 하나가 모든 확인을 돌리고 끝에 `StepResult(label: shippedCompositionLabel, passed: details.isEmpty, detailLines: details)` 로 돌려준다 (1435-1439).

### 집합 비교 — 정렬 뒤 `sameLines` · 양방향 `subtractLines`
**Source:** `tool/verify.dart` 670-684 · 1206-1212 · 1408-1414
**Apply to:** (d), (e) 의 "README 에 있고 `lib/` 에 없는 이름"
```dart
List<String> subtractLines(List<String> from, List<String> remove) {
  final remaining = <String, int>{};
  for (final line in remove) {
    remaining[line] = (remaining[line] ?? 0) + 1;
  }
  final rest = <String>[];
  for (final line in from) {
    final left = remaining[line] ?? 0;
    if (left > 0) {
      remaining[line] = left - 1;
    } else {
      rest.add(line);
    }
  }
  return rest;
}
```
건수 보존 — 같은 이름이 README 에 두 번 적히면 `- x  (README.md 에만)` 으로 잡힌다.

### 읽을 수 없는 입력은 `FormatException` → `main` 이 70, 문서 · 파일 모양의 어긋남은 단계 실패 1
**Source:** `tool/verify.dart` 911-917 (던지는 쪽) · 1847-1858 (받는 쪽) · 1841-1846 (단계 실패 → 1)
**Apply to:** `stripPlugins` · `readShippedPluginConstraint` · `declaredRuleNames` · 새 `pubspecReleaseVersion` (70); (b′) · (d) ~ (g) 의 어긋남과 "0개" (1)
```dart
    if (failed.isEmpty) {
      stdout.writeln('점검 통과 (${results.length}개 중 ${results.length}개)');
    } else {
      stdout.writeln('점검 실패 (${results.length}개 중 ${failed.length}개)');
      exitCode = 1;
    }
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    exitCode = 70;
```
예외 문구에는 **파일 이름을 넣는다** (`'$shownAs 의 …'`, `'lib/riverpod.yaml 에서 …'`, `'pubspec.yaml 에서 version: 을 읽지 못했다'`) — IN-14 가 요구하는 것이고 M34 · M36 이 stderr 에서 그 이름을 찾는다.

### `shownAs` 로 원본 경로를 문구에 넘기기
**Source:** `tool/verify.dart` 793 `String stripPlugins(String options, {required String shownAs})`, 부르는 1007-1010 `stripPlugins(File('$repoRoot/$target').readAsStringSync(), shownAs: target)`
**Apply to:** `declaredRuleNames` · `countDeclaredRules` (IN-14), 새 (b′)

### 상수의 문서 주석 — "(저장소 루트 기준). `[N/N]` 이 …"
**Source:** `tool/verify.dart` 134-135 · 148-151 · 153-163
**Apply to:** 새 상수 `readmeFile` · `readmeRulesBlock`
```dart
/// 규칙 근거 문서 (저장소 루트 기준). `[3/N]` 이 켠 규칙 표를 `lib/base.yaml` 과 견준다.
const rulesMdFile = 'RULES.md';
```
단계 번호는 `[3/N]` 처럼 N 으로 둔다 (고정 번호를 박지 않는다 — 05-RESEARCH.md § 2 의 표).

### 실측 문장 — 버전 · 날짜 · 추론 표시
**Source:** `lib/riverpod.yaml` 7-8 (`Flutter 3.47.5 의 \`flutter analyze\` 는 plugin 진단을 표시하지 않았다 (3.41.9 는 표시, 2026-09-20 실측)`), `CHANGELOG.md` 94 (`2026-10-12 에 두 선언 모두 3.1.9 로 풀려 …`), `example/README.md` 291 (`실측 (04-13): Flutter 3.47.5 / Dart 3.13.4, riverpod_lint 3.1.9, 2026-10-13`)
**Apply to:** README 문제 해결 절 · 버전 올리기 절 · 생성 파일 절, CHANGELOG 2.0.0 의 새 문장, M32 ~ 기록. 추론은 "추론이다" 로, 읽은 것은 "읽은 것" 으로 (D-03 의 `flutter pub` / `dart pub`, 문제 해결 2 의 `~/.dartServer`).

### "같은 커밋에서 고친다" 안내 문구
**Source:** `RULES.md:3` (`… 서로 같은지 견준다 — 둘은 같은 커밋에서 고친다.`), `tool/verify.dart:1416` (`'\`$rulesMdFile\` 의 표와 \`$rulesFile\` 을 같은 커밋에서 고친다.'`)
**Apply to:** README 의 "이 저장소를 고치는 사람에게" 절, (d) 의 마지막 안내 줄, `.claude/CLAUDE.md` 71행의 새 문장 — 세 곳(`lib/base.yaml` · `RULES.md` · README 표시 구역)으로 늘린다.

### 비공개 점검
**Source:** 05-RESEARCH.md § 6 의 `git grep` (1) · (2) (04-RESEARCH § 8 재사용)
**Apply to:** 커밋마다 README · CHANGELOG · `lib/` · `tool/verify.dart` · `example/README.md` · `.claude/CLAUDE.md` · `.planning/phases/05-documentation`; push 전 범위 전체. 허용은 `flutter_starter_kit` 이름과 CHANGELOG 의 실측 한 줄만 (D-20).

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `.claude/CLAUDE.md` 71 · 181행 | 지시문 | — | 두 줄의 문구 교체 — 선례가 필요 없고, 바꿀 문장은 05-RESEARCH.md § 5 에 있다 |
| `tool/verify.dart` 새 함수 `fencedLines` · `pubspecReleaseVersion` | utility | transform | README 코드 블록 · `pubspec.yaml` 을 읽는 코드는 저장소에 없다 — 05-RESEARCH.md § Code Examples 의 뼈대를 쓰고 문서 주석 · 예외 꼴만 위 Shared Patterns 를 따른다 |

## Metadata

**Analog search scope:** `tool/verify.dart` (범위 읽기 9곳), `lib/*.yaml` 다섯 전문, `RULES.md` 1-14 · 93-104 와 마커 줄, `example/README.md` 56-66 · 103-118 · 286-312 와 소절 제목, `CHANGELOG.md` 1-10 · 86-100 · 185-197, `VERSIONING.md` 70-85, `README.md` 1-30 · 70-95, `fixtures/overrides/analysis_options.yaml`, `fixtures/overrides/lib/suppress/*.dart` 다섯, `pubspec.yaml` 3 · 8 · 11행, `.claude/CLAUDE.md` 69-72 · 179-184, `0N-REVIEW-DISPOSITION.md` 셋의 frontmatter 와 표 행, `.planning/phases/04-rule-reselection/04-PATTERNS.md` 1-80 (형식 선례)
**Files scanned:** 24 (모두 `git ls-files` 로 추적 확인)
**Pattern extraction date:** 2026-10-13
