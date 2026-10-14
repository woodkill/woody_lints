// woody_lints 검증 명령 — 배포 설정이 기대한 대로 적용되는지를 단계 N 개로 확인한다
// (N = 4 + 연습용 프로젝트 수. 연습용 프로젝트는 아래 `fixtures` 표가 정한다).
//
//   [1/N] lib/ 에 .dart 파일이 없는지
//   [2/N] 조각 파일 셋(lib/base.yaml · codegen.yaml · riverpod.yaml)의 복사본을 분석해 진단이 하나도 없는지 (deprecated / removed / 없는 규칙, 겹친 규칙 · 모르는 키 같은 옵션 경고, 깨진 YAML)
//   [3/N] 배포 파일의 구성 — 묶음 · 별칭은 include 만 담는지, lib/base.yaml 의 규칙이 기반 세트와 겹치지 않는지, RULES.md 의 켠 규칙 표와 같은지, 다른 조각에 규칙이 없는지, 조각 셋의 최상위 키(와 그 바로 아래 키 — lib/codegen.yaml 의 analyzer:, lib/riverpod.yaml 의 plugins:)가 정해진 목록 안인지, README 의 표시 구역이 든 절에 구역 밖 목록 줄이 없는지, README 의 규칙 목록(표시 구역) · package: 로 시작하는 프리셋 주소 · 펜스 코드 블록 안 블록 꼴의 plugin 버전 · ref 가 배포 파일 · pubspec 과 같은지, 줄 단위로 읽은 규칙 · 키 · analyzer 옵션 · plugin 선언 · version 이 YAML (package:yaml) 이 같은 파일에서 읽은 값과 같은지
//   [4/N] 연습용 프로젝트 전부의 analysis_options.yaml 이 정해진 내용인지 (주석 · 빈 줄을 뺀 내용을 통째로 견준다)
//   [5/N] ~ [N/N] 연습용 프로젝트마다 `dart analyze` 로 분석한 결과가 정답지와 같은지
//         (`fixtures` 표의 순서. recommended 는 자기 정답지 없이 같은 실행의 example 결과와 견준다)
//
// 실행: fvm dart run tool/verify.dart [--update]
//   --update  정답지 전부를 한 번에 실제 결과로 다시 쓴다 — 바뀐 것만 쓰고, 연습용 프로젝트마다
//             바뀐 줄을 먼저 화면에 보여 준 뒤 끝에 쓴 정답지의 목록을 찍는다.
//             CI 에서는 동작하지 않는다. 같은 실행에서 한 단계라도 실패했으면 어느 정답지도
//             쓰지 않는다 (종료 코드 1).
//
// 단계에 앞서 준비를 한다: 실행 중인 SDK 가 .fvmrc 와 같은지 확인하고, 저장소 루트와
// 연습용 프로젝트 전부의 패키지를 받는다. 준비가 실패하면 검증을 시작하지 않는다.
//
// lib/ 는 읽기만 한다. 규칙 검사 동안 build/woody_rule_check/ 를 만들었다가 지운다.
// .dart_tool/woody_verify/ 를 만들고 지우지 않는다 — Analysis Server 가 plugin 을 받아
// 컴파일해 두는 전용 상태 폴더라, 지우면 다음 실행이 처음부터 다시 준비한다 (약 15초).
// 지우는 것은 plugin 준비 실패 뒤의 복구 수단이다.
//
// 종료 코드: 0 모두 통과 / 1 단계 실패 / 64 사용법 오류 / 69 pub get 실패 / 70 예외로 끝남
//            / 78 실행 중인 SDK 가 .fvmrc 와 다름
//
// 의존성은 루트 pubspec.yaml 의 dev_dependencies 에 둔 yaml (package:yaml) 하나다 —
// [3/N] 이 줄 단위로 읽은 값을 YAML 해석 결과와 견줄 때만 쓴다 (analyzer · pub 과 같은
// 해석기). Phase 2 의 "dart:io · dart:convert 만" (02-CONTEXT.md D-11) 을 이 목적에 한해
// 다시 정했다 (05-VERIFICATION.md 4회차 gap, 소유자 결정 G4-Q1). .dart_tool/ 이 없는 새
// 복제본(CI)은 `dart run` 이 패키지를 먼저 받지만, 이미 받은 작업 트리는 pubspec.yaml 이
// 바뀐 뒤 `fvm dart pub get` 을 한 번 돌려야 컴파일된다 (2026-10-15 실측, Dart 3.13.4).
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

/// plugin 준비가 실패했을 때 stderr 에 찍히는 머리말 (spike 002).
///
/// 첫 줄이 아닐 수 있으므로 `contains` 로 찾는다 (spike 008).
const pluginFailureHeader =
    'An error occurred while executing an analyzer plugin:';

/// 연습용 프로젝트(fixture) 표 — 단계 수 · 옵션 파일 · 정답지 · 상태 폴더 · 화면 라벨을 모두 정한다.
///
/// 순서가 곧 화면 순서이고, `recommended` 는 반드시 `example` 뒤여야 한다 — 자기 정답지가
/// 없어 같은 실행의 `example` 결과를 받아 견준다. fixture 마다 상태 폴더를 따로 주고
/// 차례로 분석한다 (상태 폴더를 합치면 plugin 폴더가 여럿이 되어 버전을 읽지 못한다 — spike 014).
const fixtures = <Fixture>[
  Fixture(
    path: 'example',
    label: 'example (옛 주소)',
    optionsLines: ['include: package:woody_lints/analysis_options.yaml'],
    usesPlugin: true,
    expectedPath: expectedFileName,
  ),
  Fixture(
    path: 'fixtures/recommended',
    label: 'recommended (묶음)',
    optionsLines: ['include: package:woody_lints/recommended.yaml'],
    usesPlugin: true,
  ),
  Fixture(
    path: 'fixtures/base_only',
    label: 'base_only (기본만)',
    optionsLines: ['include: package:woody_lints/base.yaml'],
    usesPlugin: false,
    expectedPath: expectedFileName,
  ),
  Fixture(
    path: 'fixtures/base_riverpod',
    label: 'base_riverpod',
    optionsLines: [
      'include:',
      '- package:woody_lints/base.yaml',
      '- package:woody_lints/riverpod.yaml',
    ],
    usesPlugin: true,
    expectedPath: expectedFileName,
  ),
  Fixture(
    path: 'fixtures/base_codegen',
    label: 'base_codegen',
    optionsLines: [
      'include:',
      '- package:woody_lints/base.yaml',
      '- package:woody_lints/codegen.yaml',
    ],
    usesPlugin: false,
    expectedPath: expectedFileName,
  ),
  Fixture(
    path: 'fixtures/overrides',
    label: 'overrides (끄는 설정)',
    optionsLines: [
      'include: package:woody_lints/recommended.yaml',
      'linter:',
      'rules:',
      'prefer_final_locals: false',
      'plugins:',
      'riverpod_lint:',
      'version: $pluginConstraintToken',
      'diagnostics:',
      'missing_provider_scope: false',
    ],
    usesPlugin: true,
    expectedPath: expectedFileName,
  ),
];

/// [Fixture.optionsLines] 에서 조각의 plugin 선언이 들어갈 자리.
///
/// `[4/N]` 이 `lib/riverpod.yaml` 에서 읽은 값([readShippedPluginConstraint])으로 바꿔 견준다.
/// 끄는 설정용 프로젝트는 `plugins:` 에 `version` 을 다시 적어야 끄기가 듣는데, 그 값이 그
/// 프로젝트의 plugin 선언을 통째로 대신한다 (spike 012) — 조각과 어긋나면 그 프로젝트만 다른
/// 버전 범위를 받게 되므로 같아야 한다.
const pluginConstraintToken = '{riverpod_lint}';

/// [4/N] 단계의 화면 이름.
const fixtureOptionsLabel = '연습용 프로젝트 옵션 파일';

/// [3/N] 단계의 화면 이름.
const shippedCompositionLabel = '배포 파일의 구성';

/// 규칙을 담으면 안 되는 배포 파일 — include 줄만 (03-REVIEW.md WR-01).
///
/// 저장소 루트 기준 경로 → 주석 · 빈 줄을 뺀 뒤 `trim()` 한 줄의 정해진 목록이다.
/// 규칙은 `lib/base.yaml` 에만 적는다 (조각 쪽은 [3/N] (b′) 가 본다). 묶음이나 별칭에 적힌 규칙은 `[2/N]` 의 규칙 검사
/// 대상([ruleCheckTargets])이 아니라서 다른 단계가 잡지 못한다.
const includeOnlyFiles = <String, List<String>>{
  'lib/analysis_options.yaml': [
    'include: package:woody_lints/recommended.yaml',
  ],
  'lib/recommended.yaml': [
    'include:',
    '- package:woody_lints/base.yaml',
    '- package:woody_lints/riverpod.yaml',
    '- package:woody_lints/codegen.yaml',
  ],
};

/// 규칙 근거 문서 (저장소 루트 기준). `[3/N]` 이 켠 규칙 표를 `lib/base.yaml` 과 견준다.
const rulesMdFile = 'RULES.md';

/// 사용 안내 문서 (저장소 루트 기준). `[3/N]` 이 표시 구역의 규칙 목록, `package:` 로 시작하는 프리셋 주소, 펜스 코드 블록 안 블록 꼴의 plugin 버전 · `ref:` 를 배포 파일 · `pubspec.yaml` 과 견준다 (VERIFY-06, 05-CONTEXT.md D-01 · D-02).
const readmeFile = 'README.md';

/// README 의 규칙 이름 목록을 감싸는 표시 구역 이름 — `RULES.md` 의 `enabled-rules` 와 다르게 두어 grep 이 갈린다.
const readmeRulesBlock = 'readme-rules';

/// 규칙 검사의 대상 — 규칙이 적힐 수 있는 조각 셋 (저장소 루트 기준). 읽기만 한다.
///
/// 묶음(`lib/recommended.yaml`)과 별칭(`lib/analysis_options.yaml`)은 넣지 않는다 —
/// 폴더를 인자로 준 분석에서는 include 를 거쳐 plugin 까지 준비한다 (spike 013).
/// 새 조각이 생기면 [expectedLibYamls] · [allowedTopLevelKeys] 와 함께 고친다.
const ruleCheckTargets = [
  'lib/base.yaml',
  'lib/codegen.yaml',
  'lib/riverpod.yaml',
];

/// "규칙 0개" 확인을 거는 조각 (저장소 루트 기준).
///
/// 이 조각에만 건다 — `codegen.yaml` 과 `plugins:` 를 뺀 `riverpod.yaml` 에는 규칙이 없다.
const rulesFile = 'lib/base.yaml';

/// `lib/` 에 있어야 하는 YAML 의 전부 (파일 이름).
///
/// 조각 셋 + 묶음 + 별칭이다. 새 조각이 생기면 이 집합과 [ruleCheckTargets] · [allowedTopLevelKeys] 를 함께 고친다 —
/// 규칙 검사 대상에서 빠진 조각에 숨은 문제 규칙은 어느 단계도 잡지 못한다 (spike 013).
const expectedLibYamls = {
  'analysis_options.yaml',
  'base.yaml',
  'codegen.yaml',
  'recommended.yaml',
  'riverpod.yaml',
};

/// 조각마다 받는 최상위 키의 닫힌 목록 (저장소 루트 기준 경로 → 키 이름).
///
/// 그 밖의 최상위 줄(다른 키, 철자가 다른 키 `linter :` · `"linter":`, 열 0 에서 시작하지
/// 않는 최상위 키)은 `[3/N]` (a′) 가 실패로 알린다 — 검사가 모르는 키는 검증 없이 사용
/// 프로젝트에 닿는다. `lib/base.yaml` 은 지금 검사가 읽는 키를 모두 받는다 (`include` 는
/// 기반 세트, `linter` 는 (b) · (c) · (d), `analyzer` 는 (c) 의 [enabledLanguageOptions] 가
/// 읽는 `language:`). 새 조각이 생기면 [ruleCheckTargets] · [expectedLibYamls] 와 함께 고친다
/// (05-REVIEW.md WR-10, 소유자 결정 G2-Q1).
const allowedTopLevelKeys = <String, Set<String>>{
  'lib/base.yaml': {'include', 'linter', 'analyzer'},
  'lib/codegen.yaml': {'analyzer'},
  'lib/riverpod.yaml': {'plugins'},
};

/// 최상위 키 바로 아래에서 받는 키의 닫힌 목록 (저장소 루트 기준 경로 → 최상위 키 → 키 이름).
///
/// `lib/codegen.yaml` 의 `analyzer:` 아래는 `errors` · `exclude` 뿐이다 (소유자 결정 G2-Q1 —
/// `language:` 같은 다른 analyzer 옵션은 실패). `lib/riverpod.yaml` 의 `plugins:` 아래는
/// `riverpod_lint` 하나다 (소유자 결정 G2-Q4 — 다른 plugin 키는 사용 프로젝트가 그 plugin 을
/// 받는다). `lib/base.yaml` 의 `analyzer:` 아래는 목록을 두지 않는다 (소유자 결정 G2-Q1 의
/// 범위 밖 — [enabledLanguageOptions] 가 `language:` 만 읽는 지금 그대로).
const allowedChildKeys = <String, Map<String, Set<String>>>{
  'lib/codegen.yaml': {
    'analyzer': {'errors', 'exclude'},
  },
  'lib/riverpod.yaml': {
    'plugins': {'riverpod_lint'},
  },
};

/// `[2/N]` 단계의 화면 이름.
const ruleCheckLabel = '배포 파일의 규칙 이름';

/// `[2/N]` 실패 문구의 마지막 안내 — 진단 줄에서 고칠 파일과 줄을 찾는 법.
const fragmentLineHint =
    '진단 줄의 폴더 이름이 조각 이름이다 — `lib/<이름>.yaml` 에서 그 줄을 고친다. '
    '복사본의 줄 번호는 원본과 같다 (`plugins:` 섹션은 빈 줄로 바꿔 복사한다).';

/// 규칙 검사용 복사본을 두는 폴더 (저장소 루트 기준).
///
/// 저장소 안이어야 루트 `pubspec.yaml` 의 SDK 하한이 적용되어 deprecated / removed
/// 규칙이 보고된다. 점으로 시작하는 폴더는 분석되지 않는다 (spike 005).
const ruleCheckDir = 'build/woody_rule_check';

/// 깨진 YAML 의 원인 줄에 붙는 진단 코드 (spike 013).
///
/// `--format=json` 출력에는 나오지 않고 형식 인자 없이 돌린 출력에만 찍힌다.
const parseErrorCode = 'parse_error';

/// 복사본의 `include:` 가 풀리지 않았을 때의 진단 코드 — 루트 `pub get` 이 안 된 상태다.
const includeNotFoundCode = 'include_file_not_found';

/// 이 스크립트를 올바른 SDK 로 실행하는 명령 (안내 문구에 쓴다).
const runCommand = 'fvm dart run tool/verify.dart';

/// `dart analyze` 가 진단의 강도에 따라 내는 종료 코드 (0 info 이하 / 2 warning / 3 error).
///
/// 이 밖의 값은 "도구가 죽었다" 로 본다 (spike 001, 002).
const analyzeExitCodes = [0, 2, 3];

/// 정답지 파일 이름 (fixture 폴더 바로 아래에 둔다).
const expectedFileName = 'expected_diagnostics.txt';

/// 정답지를 다시 만드는 명령 (안내 문구에 쓴다).
const updateCommand = '$runCommand --update';

/// 처음 만드는 정답지에 넣는 형식 설명 줄.
const formatHeaderLine = '# 형식: 상대경로:줄  강도  규칙이름 (문자열 정렬). 갱신: $updateCommand';

/// `# 실측:` 머리 주석의 접두사. `--update` 가 이 줄만 새로 쓴다.
const measuredPrefix = '# 실측:';

/// 단계 줄에서 결과 단어(통과 / 실패)가 오는 열.
const resultColumn = 40;

/// 버전 줄에서 값이 시작하는 열 (라벨 `기반 세트` 의 폭 9칸 + 공백 2칸).
const versionColumn = 11;

/// 배포 파일이 최상위 `plugins:` 에 선언한 analyzer plugin 의 패키지 이름.
const pluginPackage = 'riverpod_lint';

/// 연습용 프로젝트 하나 — [fixtures] 표의 한 행.
///
/// [path] 하나가 pub get 대상, `[4/N]` 의 옵션 파일, 정답지 자리, 상태 폴더를 정한다.
class Fixture {
  /// [expectedPath] 가 null 이면 자기 정답지 없이 `example` 의 같은 실행 결과와 견준다.
  const Fixture({
    required this.path,
    required this.label,
    required this.optionsLines,
    required this.usesPlugin,
    this.expectedPath,
  });

  /// 저장소 기준 폴더. 상태 폴더는 `.dart_tool/woody_verify/<path>/` 이고, pub get ·
  /// 옵션 파일 · 정답지의 자리다.
  final String path;

  /// 화면의 단계 이름 (예: `base_only (기본만)`).
  final String label;

  /// `[4/N]` 이 견주는, 주석 · 빈 줄을 뺀 옵션 파일의 줄 — 앞뒤 공백을 `trim()` 해 견준다.
  final List<String> optionsLines;

  /// plugin 을 쓰는지. false 면 화면의 `plugin` 줄과 정답지 머리 주석에 `해당 없음` 이다.
  final bool usesPlugin;

  /// 정답지 (fixture 폴더 기준). null 이면 자기 정답지가 없다.
  final String? expectedPath;
}

/// 정답지 파일 (`#` 머리 주석 + `exit N` 한 줄 + 진단 줄들).
class Expected {
  /// 파일을 읽어 머리 주석, 종료 코드, 진단 줄로 나눈다.
  ///
  /// `#` 줄은 [headerLines] 에 보관하고 빈 줄은 버린다. 첫 비주석 줄이
  /// `exit N` 이 아니면 [FormatException] 을 던진다.
  factory Expected.read(File file) {
    final headerLines = <String>[];
    final body = <String>[];
    for (final raw in file.readAsLinesSync()) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#')) {
        headerLines.add(line);
      } else {
        body.add(line);
      }
    }
    final code = body.isNotEmpty && body.first.startsWith('exit ')
        ? int.tryParse(body.first.substring('exit '.length))
        : null;
    if (code == null) {
      throw FormatException('첫 줄이 `exit N` 이 아니다: ${file.path}');
    }
    return Expected._(headerLines, code, body.skip(1).toList()..sort());
  }

  /// 같은 실행의 다른 fixture 결과([outcome])를 기대값으로 삼는다 (머리 주석 없음).
  ///
  /// `recommended` 처럼 자기 정답지 없이 `example` 의 결과와 견줄 때 쓴다.
  /// [outcome] 의 `lines` 가 null 이면(도구가 죽음) [StateError] 다 — 부르는 쪽이 먼저 거른다.
  factory Expected.fromOutcome(AnalyzeOutcome outcome) {
    final lines = outcome.lines;
    if (lines == null) {
      throw StateError('견줄 결과에 진단 줄이 없다 (도구가 죽은 결과)');
    }
    return Expected._(const [], outcome.exitCode, [...lines]..sort());
  }

  Expected._(this.headerLines, this.exitCode, this.lines);

  /// `#` 로 시작하는 줄 (순서 보존).
  final List<String> headerLines;

  /// 기대한 `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 기대한 진단 줄 (정렬됨).
  final List<String> lines;
}

/// `dart analyze` 한 번의 결과.
class AnalyzeOutcome {
  /// [lines] 는 정답지 형식으로 정규화한 진단 줄이다. stdout 에 JSON 이 없으면 null.
  AnalyzeOutcome({
    required this.exitCode,
    required this.lines,
    required this.stderrText,
  });

  /// `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 정규화한 진단 줄 (정렬됨). null 이면 stdout 에 JSON 이 없었다 (도구가 죽음).
  final List<String>? lines;

  /// stderr 원문.
  final String stderrText;

  /// plugin 준비 실패의 머리말이 stderr 에 들어 있는지.
  bool get hasPluginHeader => stderrText.contains(pluginFailureHeader);
}

/// 전용 상태 폴더에서 읽은 plugin(`riverpod_lint`) 버전.
///
/// 읽었으면 [version] 이, 못 읽었으면 그 이유 [reason] 이 있다. plugin 을 쓰지 않는
/// fixture 는 [applicable] 이 false 다.
class PluginVersion {
  /// 읽은 버전.
  PluginVersion.resolved(String this.version)
    : reason = null,
      applicable = true;

  /// 읽지 못했다. [reason] 은 화면에 그대로 찍는 한 줄이다.
  PluginVersion.unknown(String this.reason) : version = null, applicable = true;

  /// plugin 을 쓰지 않는 fixture — plugin 폴더 0개가 정상이라 읽지 않는다 (spike 009, 014).
  PluginVersion.notApplicable()
    : version = null,
      reason = null,
      applicable = false;

  /// 풀린 버전 (예: `3.1.9`). 못 읽었거나 해당 없으면 null.
  final String? version;

  /// 못 읽은 이유. 읽었거나 해당 없으면 null.
  final String? reason;

  /// 이 fixture 가 plugin 을 쓰는지. false 면 버전을 읽지 않았다.
  final bool applicable;

  /// 화면과 정답지 머리 주석에 쓰는 값. 해당 없으면 `해당 없음`, 못 읽었으면 `?` 다.
  String get text => !applicable ? '해당 없음' : (version ?? '?');
}

/// 검사 단계 하나의 결과. `main` 이 모아 화면에 찍고 종료 코드를 정한다.
class StepResult {
  /// [detailLines] 는 단계 줄들 아래에 그대로 찍을 줄이다.
  StepResult({
    required this.label,
    required this.passed,
    this.detailLines = const [],
    this.plugin,
    this.pluginFailed = false,
    this.applyUpdate,
    this.updateTarget,
    this.outcome,
    this.resultWord,
  });

  /// 단계 이름 (예: `base_only (기본만)`).
  final String label;

  /// 통과했는지.
  final bool passed;

  /// 화면에 그대로 찍을 줄 — 실패의 내용과 다음에 할 일, `--update` 가 바꾸는 줄.
  final List<String> detailLines;

  /// 이 단계의 분석 뒤에 읽은 plugin 버전. 정답지 비교 단계만 채운다.
  final PluginVersion? plugin;

  /// 이 단계의 분석에서 plugin 준비 실패의 머리말을 봤는지.
  final bool pluginFailed;

  /// `--update` 의 정답지 쓰기. `main` 이 [detailLines] 를 화면에 내보낸 뒤에 부른다.
  ///
  /// 같은 실행에서 다른 단계가 실패했으면 `main` 은 이것을 부르지 않는다.
  final void Function()? applyUpdate;

  /// `--update` 가 쓰는 정답지의 저장소 기준 상대 경로.
  ///
  /// 정답지 비교 단계의 update 가지만 채운다 (화면의 "썼다" 목록에 쓴다).
  final String? updateTarget;

  /// 정답지 비교 단계의 분석 결과 — `recommended` 가 같은 실행의 `example` 것을 받는다.
  final AnalyzeOutcome? outcome;

  /// 갱신 모드의 단계 줄 결과 단어 (`바뀐 줄 없음` / `갱신`). null 이면 `통과` / `실패`.
  final String? resultWord;
}

/// 정답지와 실제 결과의 차이.
class Difference {
  /// [exitNote] 는 종료 코드가 어긋났을 때만 채운다.
  Difference({
    required this.missing,
    required this.unexpected,
    required this.exitNote,
  });

  /// 정답지에는 있는데 나오지 않은 줄. 같은 줄이 여러 건이면 건수 차이만큼 들어 있다.
  final List<String> missing;

  /// 정답지에 없는데 나온 줄. 같은 줄이 여러 건이면 건수 차이만큼 들어 있다.
  final List<String> unexpected;

  /// 종료 코드가 어긋났을 때의 한 줄. 같으면 null.
  final String? exitNote;

  /// 어긋난 것이 하나도 없는지.
  bool get isEmpty => missing.isEmpty && unexpected.isEmpty && exitNote == null;
}

/// stdout 의 JSON 을 정답지 형식 줄 목록으로 바꾼다.
///
/// JSON 을 읽지 못하면 null 을 돌려준다 (진단 0건인 `[]` 과 구별한다).
/// [bases] 중 하나로 시작하는 경로는 그 뒤만 남긴다 — 심볼릭 링크를 거쳐
/// 들어간 폴더는 준 경로와 링크를 푼 경로가 다 올 수 있어 목록으로 받는다.
List<String>? normalizeDiagnostics(String stdoutText, List<String> bases) {
  final jsonLine = stdoutText
      .split('\n')
      .lastWhere((l) => l.trimLeft().startsWith('{'), orElse: () => '');
  if (jsonLine.isEmpty) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(jsonLine);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic> || decoded['diagnostics'] is! List) {
    return null;
  }
  final lines = <String>[];
  try {
    for (final d in decoded['diagnostics'] as List) {
      final diagnostic = d as Map<String, dynamic>;
      final location = diagnostic['location'] as Map<String, dynamic>;
      var file = location['file'] as String;
      for (final base in bases) {
        if (file.startsWith('$base/')) {
          file = file.substring(base.length + 1);
          break;
        }
      }
      final line = ((location['range'] as Map)['start'] as Map)['line'];
      final severity = (diagnostic['severity'] as String).toLowerCase();
      lines.add('$file:$line  $severity  ${diagnostic['code']}');
    }
  } on TypeError {
    // JSON 이기는 하지만 진단의 모양이 아니다 — 읽지 못한 것으로 친다.
    return null;
  }
  return lines..sort();
}

/// stdout 과 stderr 를 비운 뒤 [code] 로 끝낸다 (준비 단계에서만 쓴다).
Future<Never> quit(int code) async {
  await stdout.flush();
  await stderr.flush();
  exit(code);
}

/// 실행 중인 SDK 의 버전 (Flutter / Dart).
class SdkInfo {
  /// [flutter] 는 `frameworkVersion`, [dart] 는 `dartSdkVersion` 이다.
  SdkInfo({required this.flutter, required this.dart});

  /// Flutter 버전 (예: `3.47.5`).
  final String flutter;

  /// Dart 버전 (예: `3.13.4`).
  final String dart;
}

/// 실행 중인 dart 가 속한 Flutter SDK 의 `bin/cache/flutter.version.json` 을 읽는다.
///
/// 1순위는 실행 파일에서 다섯 단계 위다 (`<root>/bin/cache/dart-sdk/bin/dart` → `<root>`).
/// 2순위는 환경변수 `FLUTTER_ROOT` 다 — 설치본의 배치가 다른 경우(GitHub runner)의
/// 대비이고, 그 SDK 의 `dartSdkVersion` 이 실행 중인 Dart 와 같을 때만 받아들인다
/// (다른 SDK 를 가리키는 환경변수로 확인을 통과하지 않게). 못 찾으면 null 을 돌려준다.
Map<String, dynamic>? readFlutterVersion() {
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 4; i++) {
    dir = dir.parent;
  }
  final nearby = readVersionFile(dir.path);
  if (nearby != null) return nearby;

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null || flutterRoot.isEmpty) return null;
  final fallback = readVersionFile(flutterRoot);
  final runningDart = Platform.version.split(' ').first;
  return fallback?['dartSdkVersion'] == runningDart ? fallback : null;
}

/// [flutterRoot] 아래의 `bin/cache/flutter.version.json` 을 읽는다. 없으면 null.
Map<String, dynamic>? readVersionFile(String flutterRoot) {
  final file = File('$flutterRoot/bin/cache/flutter.version.json');
  if (!file.existsSync()) return null;
  final decoded = jsonDecode(file.readAsStringSync());
  return decoded is Map<String, dynamic> ? decoded : null;
}

/// 실행 중인 SDK 가 `.fvmrc` 와 같은지 확인하고 그 버전을 돌려준다 (D-12).
///
/// Flutter SDK 의 dart 가 아니거나 버전이 다르면 올바른 명령을 안내하고 exit 78 로
/// 끝낸다 (검증을 시작하지 않는다). `.fvmrc` 의 모양이 틀리면 [FormatException] 이다.
Future<SdkInfo> ensurePinnedSdk(String repoRoot) async {
  final version = readFlutterVersion();
  final running = version?['frameworkVersion'];
  if (version == null || running is! String) {
    stderr.writeln('Flutter SDK 의 dart 가 아니다.');
    stderr.writeln('저장소 루트에서 `$runCommand` 로 실행하세요.');
    await quit(78);
  }
  final pinned = jsonDecode(File('$repoRoot/.fvmrc').readAsStringSync());
  final expected = pinned is Map<String, dynamic> ? pinned['flutter'] : null;
  if (expected is! String) {
    throw const FormatException('`.fvmrc` 에 `flutter` 값이 없다');
  }
  if (running != expected) {
    stderr.writeln('실행 중인 SDK 는 Flutter $running 인데 .fvmrc 는 $expected 다.');
    stderr.writeln('저장소 루트에서 `$runCommand` 로 실행하세요.');
    await quit(78);
  }
  final dart = version['dartSdkVersion'];
  return SdkInfo(
    flutter: running,
    dart: dart is String ? dart : Platform.version.split(' ').first,
  );
}

/// [path] 가 [repoRoot] 아래면 저장소 기준 상대 경로로 바꾼다 (화면에 절대 경로를 남기지 않는다).
String relativize(String path, String repoRoot) =>
    path.startsWith('$repoRoot/') ? path.substring(repoRoot.length + 1) : path;

/// [dir] 에서 `dart pub get` 을 돌린다.
///
/// [enforceLockfile] 이면 `--enforce-lockfile` 을 붙여 커밋된 `pubspec.lock`
/// 그대로 받는다. 실패하면 안내를 적고 exit 69 로 끝낸다 (검증을 시작하지 않는다).
///
/// 늘 `--no-example` 을 붙인다. 기본값대로 두면 저장소 루트의 `pub get` 이 `example/` 도
/// 함께 풀어 어긋난 `example/pubspec.lock` 을 조용히 다시 쓰고, 그 뒤의
/// `--enforce-lockfile` 이 통과해 버린다 (Dart 3.13.4, 2026-10-12 실측).
///
/// [shownAs] 는 실패 안내에 [dir] 대신 적을 이름이다 (화면에 절대 경로를 남기지 않는다).
Future<void> runPubGet(
  String dir, {
  required bool enforceLockfile,
  String? shownAs,
}) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    'pub',
    'get',
    '--no-example',
    if (enforceLockfile) '--enforce-lockfile',
  ], workingDirectory: dir);
  if (result.exitCode == 0) return;
  if (enforceLockfile && result.exitCode == 65) {
    // 65 = pubspec.yaml 과 pubspec.lock 이 어긋났다 (spike 004).
    final name = dir.split('/').last;
    stderr.writeln(
      '`$name/pubspec.yaml` 을 바꿨으면 '
      '`cd $name && fvm dart pub get` 으로 lock 을 다시 받고 커밋하세요.',
    );
  }
  stderr.writeln('pub get 실패 (${shownAs ?? dir}): exit ${result.exitCode}');
  stderr.writeln('${result.stderr}'.trimRight());
  await quit(69);
}

/// `pubspec.lock` 형식의 [lockFile] 에서 [package] 의 풀린 버전을 읽는다. 없으면 null.
///
/// `example/pubspec.lock` 의 `flutter_lints` / `lints` 와, 상태 폴더의
/// `.plugin_manager/<hash>/pubspec.lock` 의 `riverpod_lint` 를 같은 파서로 읽는다.
String? readLockVersion(File lockFile, String package) {
  if (!lockFile.existsSync()) return null;
  final lines = lockFile.readAsLinesSync();
  final start = lines.indexOf('  $package:');
  if (start < 0) return null;
  for (final line in lines.skip(start + 1)) {
    if (!line.startsWith('    ')) break;
    final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}

/// 상태 폴더 [stateDir] 의 `.plugin_manager` 아래 폴더들 (Analysis Server 가 plugin 을 받아 둔 곳).
List<Directory> pluginFolders(String stateDir) {
  final manager = Directory('$stateDir/.plugin_manager');
  if (!manager.existsSync()) return const [];
  return manager.listSync().whereType<Directory>().toList();
}

/// 전용 상태 폴더 [stateDir] 에서 실제로 풀린 plugin 버전을 읽는다 (D-07).
///
/// 분석이 끝난 뒤에 부른다 — 처음 실행에서는 분석 전에 폴더가 없다. plugin 폴더가
/// 정확히 하나일 때만 읽는다. 폴더 이름은 분석 대상 경로의 해시라 어느 것이 자기
/// 폴더인지 고를 방법이 없다 (spike 008). [shownAs] 는 안내에 적을 상태 폴더 경로다.
PluginVersion readPluginVersion(String stateDir, {required String shownAs}) {
  final folders = pluginFolders(stateDir);
  if (folders.isEmpty) {
    // 서버가 plugin 준비에 이르기 전에 죽었을 때도 이 모양이다 (2026-10-12 실측).
    return PluginVersion.unknown(
      '이 상태 폴더에 plugin 이 준비되지 않았다 — 상태 폴더 환경변수가 듣지 않았을 수 있다',
    );
  }
  if (folders.length > 1) {
    return PluginVersion.unknown(
      '저장소 경로가 바뀐 적 있다 — 상태 폴더 `$shownAs` 를 지우고 다시 실행',
    );
  }
  final version = readLockVersion(
    File('${folders.single.path}/pubspec.lock'),
    pluginPackage,
  );
  return version == null
      ? PluginVersion.unknown('plugin 을 받지 못했다')
      : PluginVersion.resolved(version);
}

/// 다른 도구가 낸 [text] 안의 저장소 절대 경로를 `<repo>` 로 가린다 (CI 로그에 runner 경로를 남기지 않는다).
String scrubPaths(String text, String repoRoot) {
  var scrubbed = text;
  final roots = {repoRoot, Directory(repoRoot).resolveSymbolicLinksSync()};
  for (final root in roots) {
    scrubbed = scrubbed.replaceAll(root, '<repo>');
  }
  return scrubbed;
}

/// [fixtureDir] 에서 `dart --suppress-analytics analyze --format=json` 을 돌린다.
///
/// 경로 인자를 주지 않는다 — 하위 폴더를 인자로 주면 plugin 진단을 잃는다 (spike 001).
/// [stateDir] 는 이 fixture 만 쓰는 Analysis Server 상태 폴더이고 미리 만들어 둔다.
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

/// [from] 에서 [remove] 의 줄을 건수만큼 뺀 나머지를 돌려준다.
///
/// 같은 줄이 여러 번 있을 수 있다 — 정답지 한 줄에는 열(column)이 없어서 한 줄에 같은
/// 규칙이 두 번 걸리면 똑같은 줄 둘이 된다. [remove] 에 n 번 있는 줄은 [from] 에서
/// 정확히 n 번만 빼고, [from] 의 순서를 지킨다.
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

/// 정답지([expected])와 실제 결과를 견준다. 정답지가 없으면(null) 전부 "남는 줄" 이다.
///
/// 줄의 있고 없음이 아니라 건수를 견준다 — 같은 줄이 정답지에 두 번, 실제에 한 번이면
/// 한 줄이 "나오지 않은 줄" 이다 ([subtractLines]).
Difference findDifference(
  Expected? expected,
  List<String> actual,
  int actualExit,
) {
  final expectedLines = expected?.lines ?? const <String>[];
  final String? exitNote;
  if (expected == null) {
    exitNote = '종료 코드: 정답지 없음, 실제 $actualExit';
  } else if (expected.exitCode != actualExit) {
    exitNote = '종료 코드: 정답지 ${expected.exitCode}, 실제 $actualExit';
  } else {
    exitNote = null;
  }
  return Difference(
    missing: subtractLines(expectedLines, actual),
    unexpected: subtractLines(actual, expectedLines),
    exitNote: exitNote,
  );
}

/// 오늘 날짜를 `YYYY-MM-DD` 로 만든다.
String formatDate(DateTime date) {
  String pad(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${pad(date.month)}-${pad(date.day)}';
}

/// 정답지 머리의 `# 실측:` 줄을 만든다 — 어떤 SDK · plugin 버전으로 언제 잰 결과인지.
String formatMeasuredLine(SdkInfo sdk, PluginVersion plugin, DateTime date) =>
    '$measuredPrefix Flutter ${sdk.flutter} / Dart ${sdk.dart}, '
    '$pluginPackage ${plugin.text}, ${formatDate(date)}';

/// 정답지 [file] 을 실제 결과로 다시 쓴다.
///
/// `# 실측:` 줄만 [measured] 로 새로 쓰고 나머지 `#` 줄은 그대로 둔다. 정답지가
/// 없었으면 ([previous] 가 null) 형식 설명 줄도 함께 넣는다.
void writeExpected(
  File file,
  Expected? previous,
  List<String> actual,
  int actualExit,
  String measured,
) {
  final header = <String>[];
  if (previous == null) {
    header
      ..add(measured)
      ..add(formatHeaderLine);
  } else {
    var replaced = false;
    for (final line in previous.headerLines) {
      if (!line.startsWith(measuredPrefix)) {
        header.add(line);
      } else if (!replaced) {
        header.add(measured);
        replaced = true;
      }
    }
    if (!replaced) header.insert(0, measured);
  }
  final sorted = [...actual]..sort();
  file.writeAsStringSync(
    [...header, 'exit $actualExit', ...sorted].map((l) => '$l\n').join(),
  );
}

/// `[1/N]` `lib/` 아래에 `.dart` 파일이 없는지 본다 (VERIFY-07).
///
/// 모든 깊이를 본다. `lib/` 가 없으면 통과다 — 배포 파일이 없는 상태는 규칙 검사가 잡는다.
StepResult checkLibHasNoDart(String repoRoot) {
  const label = 'lib/ 에 .dart 파일 없음';
  final lib = Directory('$repoRoot/lib');
  if (!lib.existsSync()) return StepResult(label: label, passed: true);
  final found =
      lib
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => relativize(f.path, repoRoot))
          .where((p) => p.endsWith('.dart'))
          .toList()
        ..sort();
  if (found.isEmpty) return StepResult(label: label, passed: true);
  return StepResult(
    label: label,
    passed: false,
    detailLines: [
      'lib/ 에 .dart 파일이 있다 (${found.length})',
      ...found.map((p) => '  $p'),
      '',
      '`lib/` 에는 YAML 만 둔다 — 스크립트는 `tool/`, 연습용 코드는 `example/` 에 둔다.',
    ],
  );
}

/// YAML 텍스트 [text] 를 줄로 나눈다 — CR 하나 · LF · CRLF 가 모두 줄을 나눈다.
///
/// YAML 1.2 와 같다 — analyzer 가 쓰는 package:yaml 은 CR 하나도 줄바꿈으로 읽는다.
/// 같은 파일의 `readAsLinesSync()` 와 같은 규칙(`LineSplitter`)이다. 옵션 파일 · `pubspec.yaml`
/// 을 줄로 나누는 자리는 모두 이것을 쓴다 — `split` 이나 `replaceAll` 로 줄을 나누지 않는다.
/// `\n` 으로만 나누면 주석 줄 끝의 CR 뒤에 숨긴 규칙 · 키 · 옵션을 건너뛴다
/// (05-VERIFICATION.md 3회차 gap · 05-REVIEW.md WR-11 · 소유자 결정 G3-Q1).
List<String> splitYamlLines(String text) => const LineSplitter().convert(text);

/// 옵션 파일 내용에서 최상위 `plugins:` 섹션이 있으면 뺀다 (spike 007, 013).
///
/// 줄 단위로 걸으며 `plugins:` 줄부터 다음 최상위 키(들여쓰기 없는 비주석 줄) 앞까지를
/// 지우지 않고 빈 줄로 바꾼다 (줄 번호 보존) — 복사본의 줄 번호가 원본과 같다 (끝의 빈 줄은 빠질 수 있다 — 05-REVIEW.md IN-11, 소유자 결정 G4-Q2).
/// 없으면 그대로 돌려준다 — 조각 셋 가운데 `plugins:` 가 있는 것은 `riverpod.yaml` 뿐이다.
/// 받는 꼴: 줄 끝 주석, `plugins:` 뒤의 주석 · 공백, 섹션 안의 빈 줄 · 열 0 주석,
/// CR 하나 · CRLF 줄바꿈 ([splitYamlLines] — YAML 과 같다), 마지막 줄바꿈 없음
/// (03-REVIEW.md WR-02, 2026-10-13 복제본에서 입력 10가지 확인).
///
/// 바꾼 뒤에도 `plugins:` 줄이 남아 있으면 섹션을 놓친 것이라 [FormatException] 을
/// 던진다 ([shownAs] 는 문구에 쓸 원본 경로). `plugins:` 를 담은 채 분석하면 plugin 을
/// 준비한다 (10초 + 네트워크) — 조용히 넘기지 않는다.
String stripPlugins(String options, {required String shownAs}) {
  final lines = splitYamlLines(options);
  var inPlugins = false;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (RegExp(r'^plugins:[ \t]*(#.*)?$').hasMatch(line)) {
      inPlugins = true;
    } else if (inPlugins &&
        RegExp(r'^\S').hasMatch(line) &&
        !line.startsWith('#')) {
      // 들여쓰기 없는 비주석 줄(다른 최상위 키)이 섹션을 닫는다.
      inPlugins = false;
    }
    // 지우지 않고 빈 줄로 — 줄 번호 보존 (03-REVIEW.md WR-02)
    if (inPlugins) lines[i] = '';
  }
  final stripped = lines.join('\n');
  if (RegExp(r'^plugins:', multiLine: true).hasMatch(stripped)) {
    throw FormatException('$shownAs 의 `plugins:` 섹션을 빼지 못했다');
  }
  return stripped;
}

/// 조각 경로(`lib/base.yaml`)에서 조각 이름(`base`)을 뗀다 — 복사본의 하위 폴더 이름이다.
String fragmentName(String target) {
  final file = target.split('/').last;
  return file.endsWith('.yaml')
      ? file.substring(0, file.length - '.yaml'.length)
      : file;
}

/// 규칙 검사 진단 줄의 경로(`build/woody_rule_check/<이름>/analysis_options.yaml:N`)에서
/// 조각 이름을 읽는다. 못 읽으면 null.
String? fragmentNameOfLine(String line) =>
    RegExp('^${RegExp.escape(ruleCheckDir)}/([^/]+)/analysis_options\\.yaml:')
        .firstMatch(line)
        ?.group(1);

/// `lib/` 의 YAML 이 정확히 [expectedLibYamls] 인지 본다 (`[2/N]` 의 첫 확인).
///
/// 같으면 null, 다르면 실패한 [StepResult] 를 돌려준다. 더 있는 파일은 규칙 검사 대상
/// ([ruleCheckTargets])에서 빠졌을 수 있는 새 조각이고, 없는 파일은 지웠거나 이름을 바꾼
/// 조각이다. `lib/` 가 없으면 다섯이 모두 없는 것으로 본다.
StepResult? checkLibYamlSet(String repoRoot) {
  final lib = Directory('$repoRoot/lib');
  final present = lib.existsSync()
      ? {
          for (final entity in lib.listSync().whereType<File>())
            if (entity.path.endsWith('.yaml'))
              relativize(entity.path, '$repoRoot/lib'),
        }
      : <String>{};
  final extra = present.difference(expectedLibYamls).toList()..sort();
  final missing = expectedLibYamls.difference(present).toList()..sort();
  if (extra.isEmpty && missing.isEmpty) return null;
  return StepResult(
    label: ruleCheckLabel,
    passed: false,
    detailLines: [
      '`lib/` 의 YAML 이 정해진 다섯과 다르다.',
      if (extra.isNotEmpty) ...[
        '더 있는 것 (${extra.length})',
        ...extra.map((n) => '  lib/$n'),
      ],
      if (missing.isNotEmpty) ...[
        '없는 것 (${missing.length})',
        ...missing.map((n) => '  lib/$n'),
      ],
      '',
      '새 조각을 더했으면 tool/verify.dart 의 ruleCheckTargets 와 expectedLibYamls 에 함께 적는다. '
          '지웠으면 두 상수에서 뺀다.',
    ],
  );
}

/// 복사본의 진단 줄 [line] 이 가리키는 줄에서 규칙 이름을 읽는다. 못 읽으면 null.
String? readRuleNameAt(String line, List<String> copyLines) {
  final number = int.tryParse(
    RegExp(r':(\d+)  ').firstMatch(line)?.group(1) ?? '',
  );
  if (number == null || number < 1 || number > copyLines.length) return null;
  return RegExp(r'^\s*-\s*([A-Za-z0-9_]+)')
      .firstMatch(copyLines[number - 1])
      ?.group(1);
}

/// 옵션 파일 본문([options])의 최상위 `linter:` 블록에 적힌 규칙의 수를 센다.
///
/// [declaredRuleNames] 의 길이다. 블록이 없으면 0 이다. 읽지 못하는 줄이 있으면
/// [FormatException] — main 이 종료 코드 70 으로 끝낸다 (문구에 [shownAs] 의 파일 이름이
/// 들어간다).
int countDeclaredRules(String options, {required String shownAs}) =>
    declaredRuleNames(options, shownAs: shownAs).length;

/// 옵션 파일 본문([options])의 최상위 `linter:` 블록에 적힌 규칙 이름을 적힌 순서대로 돌려준다.
///
/// 블록은 `linter:` 로 시작하는 줄부터 그 다음의 들여쓰기 없는 비주석 줄 앞까지다 (주석 줄과
/// 빈 줄은 건너뛴다). 그 안에서 받는 줄은 둘뿐이다 — 들여쓴 `rules:` 키 줄과, 목록 항목
/// `- 이름` · `- '이름'` · `- "이름"` (뒤에 공백과 `# 주석` 가능). 주석 처리된 줄(`# - …`)과
/// 블록 밖의 목록 항목(`analyzer.exclude` 의 glob)은 읽지 않는다.
///
/// 블록 안의 그 밖의 줄(이름 없는 `-`, `- 이름: true`, 맵 형식 `이름: true`, 이름 뒤에 다른
/// 것이 붙은 줄)은 건너뛰지 않고 [FormatException] 을 던진다 — main 이 종료 코드 70 으로
/// 끝낸다 (04-REVIEW.md WR-10). 문구의 머리에 [shownAs] (문구에 쓸 원본 경로)가 들어가
/// 어느 조각의 줄인지 알린다 (04-REVIEW.md IN-14). `linter:` 줄에 `#` 주석 밖의 값이 붙어
/// 있으면(flow 표기 `linter: {rules: [...]}`) 건너뛰지 않고 [FormatException] — 다른 조각에서는
/// (b′) 가 0개로 읽어 통과시켰던 입력이다 (05-REVIEW.md WR-04, 05-VERIFICATION.md gaps 2).
/// 블록이 없으면 빈 목록이다. 같은 이름이 두 번 적혀 있으면 두 번 들어간다 (`[3/N]` 이 중복을
/// 잡는다). 철자가 다른 `linter` 키(`linter :` · `"linter":`)의 블록은 이 함수가 읽지 않고
/// (a′) 가 받지 않는 최상위 줄로 실패시킨다 (소유자 결정 G2-Q1).
List<String> declaredRuleNames(String options, {required String shownAs}) {
  // 목록 항목 — 여는 따옴표와 닫는 따옴표가 같아야 하고(없어도 된다), 이름 뒤에는 공백 하나
  // 이상과 `# 주석` 만 올 수 있다. 그 밖의 꼴은 아래에서 멈춘다 (04-REVIEW.md WR-10)
  final rulePattern = RegExp(
    r'''^\s*-\s+(['"]?)([A-Za-z0-9_]+)\1(?:\s+#.*)?\s*$''',
  );
  // 들여쓴 `rules:` 키 줄 — 블록 안에서 이름 없이 받는 유일한 줄
  final rulesKeyPattern = RegExp(r'^\s+rules:\s*(?:#.*)?$');
  var inLinter = false;
  final names = <String>[];
  final lines = splitYamlLines(options);
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    // 주석 줄과 빈 줄은 블록을 닫지 않는다 — YAML 에서 열 0 주석은 블록 밖이 아니다 (04-REVIEW.md CR-02)
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    if (RegExp(r'^linter:').hasMatch(line)) {
      // `linter:` 줄에 값이 붙은 꼴(flow 표기)은 블록 줄이 없어 규칙 0개로 읽힌다 — 건너뛰지
      // 않고 멈춘다. 줄 끝 `# 주석` 은 값이 아니다 (05-REVIEW.md WR-04)
      if (!RegExp(r'^linter:[ \t]*(?:#.*)?$').hasMatch(line)) {
        throw FormatException(
          '$shownAs 의 ${i + 1}행: `linter:` 줄에 값이 붙어 있다 — '
          'flow 표기(`linter: {rules: [...]}`)는 읽지 않는다. '
          '블록 목록(`linter:` / `  rules:` / `    - 이름`)으로 적는다 (05-REVIEW.md WR-04): $trimmed',
        );
      }
      inLinter = true;
    } else if (RegExp(r'^\S').hasMatch(line)) {
      // 들여쓰기 없는 줄(다른 최상위 키)이 블록을 닫는다.
      inLinter = false;
    } else if (inLinter) {
      if (rulesKeyPattern.hasMatch(line)) continue;
      final match = rulePattern.firstMatch(line);
      // 블록 안에서 읽지 못하는 줄은 건너뛰지 않고 멈춘다 — 건너뛰면 겹침 검사 (b) 와
      // `RULES.md` 일치 검사 (c) 가 그 규칙을 보지 못한 채 통과한다 (04-REVIEW.md WR-10)
      if (match == null) {
        throw FormatException(
          '$shownAs 의 `linter:` 블록의 ${i + 1}행을 읽지 못했다 — '
          '목록 항목(`- 이름` · `- \'이름\'` · `- "이름"`, 뒤에 `# 주석` 가능)과 '
          '`rules:` 만 받는다 (04-REVIEW-DISPOSITION.md WR-10): $trimmed',
        );
      }
      names.add(match.group(2)!);
    }
  }
  return names;
}

/// 옵션 파일 본문([options])에서 닫힌 목록 밖의 줄을 찾는다 — `[3/N]` (a′) 가 쓴다.
///
/// [allowed] 는 그 조각이 받는 최상위 키([allowedTopLevelKeys]), [childKeys] 는 최상위 키
/// 바로 아래에서 받는 키([allowedChildKeys])다. 돌려주는 항목은 `<줄 번호>행: <원문>` (뒤
/// 공백만 뗀다 — 들여쓰기는 살린다)이고, `topLevel` 은 받지 않는 최상위 줄, `nested` 는
/// 최상위 키마다 그 바로 아래에서 받지 않는 줄이다. 빈 줄과 `#` 줄은 건너뛴다.
///
/// 줄 규칙:
/// - 키 줄은 열 0 에서 `<이름>:` 뒤에 공백 · 탭이나 줄 끝이 오는 줄이고(이름은
///   `[A-Za-z_][A-Za-z0-9_-]*`), 이름이 [allowed] 안이어야 한다. 이 꼴이 아닌 열 0 의 비주석 줄
///   — 콜론 앞 공백(`linter :`), 따옴표 키(`"linter":`), `? ` 키, 앵커 · 병합 키, `- ` 항목,
///   `---`, flow 맵 — 은 모두 받지 않는 줄이다 ("명단에 없으면 모두 막는다").
/// - [childKeys] 에 있는 키는 그 줄에 값이 붙으면(`# 주석` 만은 된다) 아래 키를 읽을 수 없으므로
///   받지 않는 줄이다. [childKeys] 에 없는 키의 값(`include: …`)은 보지 않는다 — 값을 읽는
///   검사([declaredRuleNames] · [enabledLanguageOptions] · [readShippedPluginConstraint])의
///   몫이고, 그 검사들의 종료 코드 70 은 그대로 남는다.
/// - 첫 비주석 줄이 들여 쓴 줄이면(최상위 키가 열 0 에서 시작하지 않는 파일 — YAML 로는 같은
///   최상위 맵이다) 그 줄 하나를 `topLevel` 에 담고, 같은 들여쓴 최상위의 나머지 줄은 그 아래로
///   보아 다시 담지 않는다.
/// - [childKeys] 에 있는 키 아래에서는 그 키 다음 첫 비주석 줄의 들여쓰기를 "바로 아래" 로
///   기억한다. 같은 들여쓰기에서 이름을 읽지 못했거나 목록 밖인 줄과 그보다 얕은 줄은
///   `nested` 에 담고, 더 깊은 줄(`errors:` 의 진단 이름, `exclude:` 의 glob, `riverpod_lint:`
///   맵 꼴의 `diagnostics:` · `version:`)은 보지 않는다.
/// - 여러 줄에 걸친 flow 표기는 받지 않는다 — 조각은 블록 꼴로 적는다.
///
/// 예외를 던지지 않는다. 받지 않는 키는 YAML 로 올바르고 analyzer 도 받는, 읽을 수 있는 정책
/// 위반이라 종료 코드 70 ("파일 모양을 읽지 못했다") 이 아니라 `[3/N]` 실패로 알린다 — 그래야
/// 뒤의 (b′) · (b) · (c) 가 지금처럼 돌아 앞 기록의 70 (flow `linter: {…}`, 읽지 못하는 블록 줄)
/// 과 `[3/N]` 실패가 그대로 남고, 나머지 단계도 끝까지 돈다 (05-VERIFICATION.md 2회차 gap,
/// 05-REVIEW.md WR-10, 소유자 결정 G2-Q1).
({List<String> topLevel, Map<String, List<String>> nested}) findUnexpectedKeys(
  String options, {
  required Set<String> allowed,
  Map<String, Set<String>> childKeys = const {},
}) {
  final keyPattern = RegExp(r'^([A-Za-z_][A-Za-z0-9_-]*):(?:[ \t]|$)');
  final topLevel = <String>[];
  final nested = <String, List<String>>{};
  final lines = splitYamlLines(options);
  // 열 0 의 비주석 줄을 이미 봤는지 — 못 본 채 들여쓴 줄이 오면 최상위가 열 0 밖이다.
  var seenTopLevel = false;
  // 아래 키를 보는 최상위 키 — null 이면 그 아래 줄은 보지 않는다.
  String? currentKey;
  // currentKey 의 "바로 아래" 들여쓰기 — 그 키 다음 첫 비주석 줄에서 정한다.
  int? childIndent;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final shown = '${i + 1}행: ${line.trimRight()}';
    final indent = line.length - line.trimLeft().length;
    if (indent == 0) {
      seenTopLevel = true;
      childIndent = null;
      currentKey = null;
      final key = keyPattern.firstMatch(line)?.group(1);
      if (key == null || !allowed.contains(key)) {
        topLevel.add(shown);
      } else if (childKeys.containsKey(key) &&
          !RegExp('^${RegExp.escape(key)}:[ \\t]*(?:#.*)?\$').hasMatch(line)) {
        // 아래 키 목록이 있는 키에 값이 붙으면 아래 키를 읽을 수 없다.
        topLevel.add(shown);
      } else {
        currentKey = key;
      }
      continue;
    }
    if (!seenTopLevel) {
      topLevel.add(shown);
      seenTopLevel = true;
      continue;
    }
    final children = currentKey == null ? null : childKeys[currentKey];
    if (children == null) continue;
    childIndent ??= indent;
    if (indent > childIndent) continue;
    final key = keyPattern.firstMatch(trimmed)?.group(1);
    if (indent < childIndent || key == null || !children.contains(key)) {
      nested.putIfAbsent(currentKey!, () => []).add(shown);
    }
  }
  return (topLevel: topLevel, nested: nested);
}

/// 옵션 파일 본문([options])의 최상위 `analyzer:` → `language:` 아래 `<이름>: true|false` 를 읽는다.
///
/// `RULES.md` 의 켠 analyzer 옵션 표(`woody:enabled-options`)와 견줄 값이다. 블록이 없으면
/// 빈 맵이다. 들여쓰기로 블록을 가른다 — `analyzer:` 는 들여쓰기 없는 줄, `language:` 는
/// 그 아래 한 단계, 옵션은 `language:` 보다 깊은 줄이다. 빈 줄과 `#` 줄은 건너뛴다.
///
/// 받는 꼴은 블록 꼴 하나다 — `analyzer:` / `  language:` / `    <이름>: true|false`, 세 줄
/// 모두 줄 끝 `# 주석` 가능. `analyzer:` 아래의 `language:` 가 아닌 키(`errors:` ·
/// `exclude:` 와 그 아래)는 읽지 않는다. 다음 셋은 건너뛰지 않고 [FormatException] 을 던진다
/// — main 이 종료 코드 70 으로 끝낸다 (문구에 [shownAs] 의 파일 이름과 행이 들어간다).
///
/// - `analyzer:` 줄에 `#` 주석 밖의 값이 붙어 있다 (`analyzer: {language: {…}}`).
/// - `language:` 줄에 `#` 주석 밖의 값이 붙어 있다 (`language: {strict-casts: true}`).
/// - `language:` 블록 안의 줄이 `<이름>: true|false` 가 아니다 (`strict-casts: yes` 등).
///
/// 건너뛰면 `RULES.md` 의 켠 옵션 표와의 비교 (c) 가 켠 옵션을 보지 못한 채 통과한다 (소유자
/// 확인 2026-10-14 — `language: {…}` · `analyzer: {language: {…}}` 가 `{}` 로 읽혔다;
/// 05-VERIFICATION.md gaps 2 와 같은 원칙, 소유자 결정 R2-Q2).
Map<String, bool> enabledLanguageOptions(
  String options, {
  required String shownAs,
}) {
  final result = <String, bool>{};
  final optionPattern = RegExp(
    r'^([A-Za-z0-9_-]+):[ \t]*(true|false)[ \t]*(?:#.*)?$',
  );
  var inAnalyzer = false;
  int? languageIndent;
  final lines = splitYamlLines(options);
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final indent = line.length - line.trimLeft().length;
    if (indent == 0) {
      languageIndent = null;
      if (RegExp(r'^analyzer:').hasMatch(line)) {
        if (!RegExp(r'^analyzer:[ \t]*(?:#.*)?$').hasMatch(line)) {
          throw FormatException(
            '$shownAs 의 ${i + 1}행: `analyzer:` 줄에 값이 붙어 있다 — '
            'flow 표기는 읽지 않는다. '
            '블록(`analyzer:` / `  language:` / `    <이름>: true|false`)으로 적는다: $trimmed',
          );
        }
        inAnalyzer = true;
      } else {
        inAnalyzer = false;
      }
      continue;
    }
    if (!inAnalyzer) continue;
    if (languageIndent != null && indent > languageIndent) {
      final match = optionPattern.firstMatch(trimmed);
      if (match == null) {
        throw FormatException(
          '$shownAs 의 `language:` 블록의 ${i + 1}행을 읽지 못했다 — '
          '`<이름>: true|false` (뒤에 `# 주석` 가능) 만 받는다: $trimmed',
        );
      }
      result[match.group(1)!] = match.group(2) == 'true';
      continue;
    }
    if (RegExp(r'^language:').hasMatch(trimmed)) {
      if (!RegExp(r'^language:[ \t]*(?:#.*)?$').hasMatch(trimmed)) {
        throw FormatException(
          '$shownAs 의 ${i + 1}행: `language:` 줄에 값이 붙어 있다 — '
          'flow 표기는 읽지 않는다. '
          '블록(`analyzer:` / `  language:` / `    <이름>: true|false`)으로 적는다: $trimmed',
        );
      }
      languageIndent = indent;
    } else {
      languageIndent = null;
    }
  }
  return result;
}

/// 규칙 검사 복사본 폴더([ruleCheckDir])를 형식 인자 없이 한 번 더 분석해
/// [parseErrorCode] 를 담은 줄만 돌려준다 (경로는 [scrubPaths] 로 가린다).
///
/// 왜 두 번 돌리는가: `--format=json` 출력에는 옵션 파일의 error 강도 진단이 나오지 않는다.
/// 깨진 YAML 은 exit 3 인데 JSON 의 진단이 0건이고 stderr 도 비어 있어, 원인 줄
/// (`… - parse_error`)은 형식 인자 없이 돌린 출력에서만 볼 수 있다 (spike 013).
/// 규칙 검사는 plugin 을 준비하지 않으므로 상태 폴더 환경변수는 주지 않는다.
/// 복사본이 아직 있을 때(즉 [checkRuleNames] 의 `try` 안에서) 불러야 한다.
Future<List<String>> readParseErrorLines(String repoRoot) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    '--suppress-analytics',
    'analyze',
    ruleCheckDir,
  ], workingDirectory: repoRoot);
  final text = '${result.stdout}\n${result.stderr}';
  return [
    for (final line in text.split('\n'))
      if (line.contains(parseErrorCode)) scrubPaths(line.trim(), repoRoot),
  ];
}

/// `[2/N]` 조각 셋([ruleCheckTargets])의 복사본을 분석해 진단이 하나도 없는지 본다 (VERIFY-02).
///
/// 첫 확인은 `lib/` 의 YAML 집합이다 ([checkLibYamlSet]) — 대상에서 빠진 새 조각이 있으면
/// 복사본을 만들기 전에 실패한다.
///
/// [rulesFile] 에서 규칙을 하나도 읽지 못하면([countDeclaredRules] 가 0) 실패다 — 검사가
/// 본 것이 없는데 "문제 없음" 으로 넘기지 않는다. 그 `linter:` 블록에 읽지 못하는 줄이
/// 있으면 [FormatException] — main 이 종료 코드 70 으로 끝낸다 (문구에 [rulesFile] 의 파일
/// 이름이 들어간다).
///
/// 통과는 복사본의 `dart analyze` 가 exit 0 이고 진단 0건일 때 하나다. 깨진 YAML 은
/// exit 3 에 진단 0건으로 나오므로 형식 인자 없이 한 번 더 돌려 원인 줄을 보여 준다 (spike 013).
///
/// deprecated / removed / 없는 규칙의 세 코드만 고르지 않는다 — 복사본의 진단이 하나라도
/// 있으면 실패다. 세 코드만 고르던 때는 `rules:` 키의 오타, 겹친 규칙, 없는 진단 코드,
/// 깨진 YAML 이 이 단계를 통과해 `--update` 가 망가진 결과를 정답지로 썼다.
/// 2026-10-12 에 고쳤다 (CONTEXT '가장 먼저 할 일').
///
/// analyzer 는 규칙의 상태를 `analysis_options.yaml` 이라는 이름의 파일에 직접 적힌
/// 규칙에 대해서만 온전히 보고한다 (include 경유로는 없는 규칙만). 그래서 조각마다
/// `plugins:` 를 뺀 뒤 [ruleCheckDir]`/<조각 이름>/analysis_options.yaml` 로 복사하고,
/// 저장소 루트에서 [ruleCheckDir] 폴더 하나를 인자로 한 번 분석한다 — 하위 폴더 셋이 함께
/// 분석되고 진단 경로에 조각 이름이 들어간다 (spike 013 K7). 복사본은 어떤 경우에도
/// 지운다. 조각은 읽기만 한다.
Future<StepResult> checkRuleNames(String repoRoot) async {
  const label = ruleCheckLabel;
  final setProblem = checkLibYamlSet(repoRoot);
  if (setProblem != null) return setProblem;

  // 조각 이름(`base` 등) → plugins: 를 뺀 복사본 내용.
  final copies = <String, String>{
    for (final target in ruleCheckTargets)
      fragmentName(target): stripPlugins(
        File('$repoRoot/$target').readAsStringSync(),
        shownAs: target,
      ),
  };
  final rulesCopy = copies[fragmentName(rulesFile)]!;
  final checkDir = Directory('$repoRoot/$ruleCheckDir');
  try {
    for (final MapEntry(key: name, value: content) in copies.entries) {
      final dir = Directory('${checkDir.path}/$name')
        ..createSync(recursive: true);
      File('${dir.path}/analysis_options.yaml').writeAsStringSync(content);
    }
    // plugin 을 준비하지 않으므로 상태 폴더는 주지 않는다. 폴더 인자는 이 검사에서만 쓴다.
    final result = await Process.run(Platform.resolvedExecutable, [
      '--suppress-analytics',
      'analyze',
      '--format=json',
      ruleCheckDir,
    ], workingDirectory: repoRoot);
    final lines = normalizeDiagnostics(result.stdout as String, [
      repoRoot,
      Directory(repoRoot).resolveSymbolicLinksSync(),
    ]);

    if (lines == null || !analyzeExitCodes.contains(result.exitCode)) {
      final stderrHead = (result.stderr as String)
          .trim()
          .split('\n')
          .take(2)
          .join(' / ');
      return StepResult(
        label: label,
        passed: false,
        detailLines: [
          '도구가 죽었다 — 규칙 검사의 dart analyze 가 exit ${result.exitCode} 로 끝났다'
              '${lines == null ? ' (stdout 에 JSON 없음)' : ''}.',
          '  stderr: ${stderrHead.isEmpty ? '(비어 있음)' : stderrHead}',
        ],
      );
    }

    // 종료 코드는 0 이 아닌데 JSON 에 진단이 없다 — 옵션 파일 자체가 깨진 경우다.
    // 원인 줄은 JSON 에 나오지 않으므로 형식 인자 없이 한 번 더 돌려 찾는다 (spike 013).
    // 복사본을 지우는 finally 보다 먼저 불러야 한다.
    if (result.exitCode != 0 && lines.isEmpty) {
      final parseErrors = await readParseErrorLines(repoRoot);
      return StepResult(
        label: label,
        passed: false,
        detailLines: [
          '규칙 검사의 dart analyze 가 exit ${result.exitCode} 로 끝났는데 JSON 에 진단이 없다 — '
              '배포 파일의 YAML 이 깨졌을 수 있다 (닫지 않은 따옴표, 잘못된 들여쓰기 등).',
          if (parseErrors.isEmpty)
            '  (원인 줄을 찾지 못했다 — 같은 폴더를 형식 인자 없이 직접 분석해 보세요)'
          else
            ...parseErrors.map((l) => '  $l'),
          '',
          fragmentLineHint,
        ],
      );
    }

    // include 가 풀리지 않으면 규칙을 보지 못한 것이다 — "문제 없음" 으로 넘기지 않는다.
    final unresolved = lines
        .where((l) => l.endsWith('  $includeNotFoundCode'))
        .toList();
    if (unresolved.isNotEmpty) {
      return StepResult(
        label: label,
        passed: false,
        detailLines: [
          '루트 `pub get` 이 안 되어 규칙 검사를 하지 못했다 — 복사본의 include 가 풀리지 않았다.',
          ...unresolved.map((l) => '  $l'),
          '',
          '저장소 루트에서 `fvm dart pub get` 을 돌린 뒤 다시 실행하세요.',
        ],
      );
    }

    // 규칙을 하나도 읽지 못했으면 아래의 "문제 0건" 은 본 것이 없다는 뜻이다 —
    // `linter:` 키의 오타, 규칙을 include 뒤의 다른 파일로 옮긴 경우.
    if (countDeclaredRules(rulesCopy, shownAs: rulesFile) == 0) {
      return StepResult(
        label: label,
        passed: false,
        detailLines: [
          '`$rulesFile` 의 최상위 `linter:` 블록 안에서 '
              '`- 규칙이름` 줄을 하나도 세지 못했다.',
          '',
          '`linter:` / `rules:` 키와 들여쓰기를 확인하세요. '
              '규칙을 다른 조각으로 옮겼으면 tool/verify.dart 의 rulesFile 을 그 조각으로 바꿉니다.',
        ],
      );
    }

    // 진단이 하나라도 있으면 실패다 — 세 코드 밖의 옵션 경고(겹친 규칙, 모르는 키,
    // 없는 진단 코드 등)도 사용 프로젝트에 `included_file_warning` 으로 나타난다.
    if (lines.isNotEmpty) {
      // 진단 줄마다 그 줄이 가리키는 조각의 복사본에서 규칙 이름을 읽는다.
      // 복사본은 [stripPlugins] 가 [splitYamlLines] 로 나눠 LF 로 이은 것이라 analyzer 가
      // 말하는 줄 번호와 같다.
      final copyLines = {
        for (final MapEntry(key: name, value: content) in copies.entries)
          name: splitYamlLines(content),
      };
      return StepResult(
        label: label,
        passed: false,
        detailLines: [
          '배포 파일에 쓸 수 없는 규칙이나 옵션 경고가 있다 (${lines.length})',
          for (final line in lines)
            switch (readRuleNameAt(
              line,
              copyLines[fragmentNameOfLine(line)] ?? const [],
            )) {
              final name? => '  $line  ($name)',
              null => '  $line',
            },
          '',
          fragmentLineHint,
          'deprecated / removed / 없는 규칙은 지우거나 바꾸고, 그 밖의 옵션 경고'
              '(겹친 규칙, 모르는 키, 없는 진단 코드 등)는 그 줄을 고친다.',
        ],
      );
    }

    // 여기까지 왔으면 exit 0 이고 진단 0건이다.
    return StepResult(label: label, passed: true);
  } finally {
    if (checkDir.existsSync()) checkDir.deleteSync(recursive: true);
    final parent = checkDir.parent;
    if (parent.existsSync() && parent.listSync().isEmpty) parent.deleteSync();
  }
}

/// [4/N] 연습용 프로젝트 전부([fixtures])의 옵션 파일이 정해진 내용인지 한 단계로 본다.
///
/// 파일마다 주석과 빈 줄을 뺀 나머지를 `trim()` 한 줄 목록이 [Fixture.optionsLines] 와
/// 통째로 같아야 한다. `flutter pub get` 이 써넣는 `build/**` 제외, include 삭제,
/// 끄는 설정의 어긋남을 잡는다 (spike 004). 틀린 파일만 파일별로 적는다.
///
/// 견주기 전에 [pluginConstraintToken] 을 `lib/riverpod.yaml` 의 선언으로 바꾼다 —
/// 끄는 설정용 프로젝트의 `version:` 이 조각과 다르면 이 단계가 실패한다.
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
    // 판정은 앞뒤 공백을 뗀 줄로 하고, 화면에는 들여쓰기를 살린 줄을 보여 준다.
    final rest = significantLines(file);
    if (rest != null &&
        sameLines(rest.map((l) => l.trim()).toList(), expected)) {
      continue;
    }
    if (details.isNotEmpty) details.add('');
    details.addAll([
      if (rest == null)
        '`$optionsPath` 이 없다.'
      else ...[
        '`$optionsPath` 이 정해진 내용이 아니다 — 주석·빈 줄을 뺀 내용 (${rest.length}줄):',
        if (rest.isEmpty) '  (없음)' else ...rest.map((l) => '  $l'),
      ],
      '  정해진 내용:',
      ...expected.map((l) => '    $l'),
      '',
      '`flutter pub get` 을 돌렸다면: git checkout -- $optionsPath',
    ]);
  }
  return StepResult(
    label: fixtureOptionsLabel,
    passed: details.isEmpty,
    detailLines: details,
  );
}

/// `lib/riverpod.yaml` 의 `riverpod_lint:` 선언(예: `^3.1.9`)을 읽는다.
///
/// 받는 꼴:
/// - 스칼라 — 들여쓴 줄 `riverpod_lint: <값>` (줄 끝 `# 주석` 가능).
/// - 맵 — 값 없는 키 줄 `riverpod_lint:` (줄 끝 `# 주석` 가능 — 주석은 값이 아니다) 아래에서,
///   키 줄보다 깊이 들여쓴 줄이 이어지는 동안 그 가운데 `version: <값>` 줄 (끄는 설정의 모양 —
///   `fixtures/overrides/analysis_options.yaml`). 맵 안의 키 순서는 가리지 않는다 —
///   `diagnostics:` 가 먼저 와도 된다. 키 줄과 같거나 얕은 줄에서 맵이 끝난다.
/// - 값은 [unquotedScalar] 로 바깥 따옴표를 벗긴다 (`"^3.1.9"` 와 `^3.1.9` 는 analyzer 에게
///   같은 선언이다). 벗긴 값이 `^X.Y.Z` 나 고정 버전 `X.Y.Z` 이면 그 글자를 돌려준다.
///
/// 받지 않는 꼴: 범위 제약(`">=3.1.9 <4.0.0"`) 등 그 밖의 값 — `꼴만 받는다` 를 담은 문구로
/// [FormatException] 을 던진다 (선언은 있으나 읽지 못한 것이라 원인과 값을 말한다). 키 줄이
/// 없거나 맵에서 `version:` 을 찾지 못하면 `선언을 찾지 못했다` 다 (05-01 의 M34).
/// 어느 쪽이든 조각의 모양이 바뀐 것이라 견줄 기준이 없다 — main 이 종료 코드 70 으로 끝낸다.
///
/// 경위: 03-REVIEW.md WR-02 로 줄 끝 주석 · 맵 형식을 받게 고쳤고, 05-REVIEW.md WR-05 로
/// 따옴표를 벗기고 맵 안의 키 순서를 보지 않으며 범위 제약은 원인을 말하고 멈추게 고쳤다
/// (고정 버전을 받는 것은 소유자 결정 R2-Q1 — 지금의 동작 유지).
/// `[4/N]` 이 쓰고, `[3/N]` 의 README 검사 (f) 도 같은 값을 쓴다.
String readShippedPluginConstraint(String repoRoot) {
  const shownAs = 'lib/riverpod.yaml';
  final lines = splitYamlLines(File('$repoRoot/$shownAs').readAsStringSync());
  final keyLine = RegExp(
    r'^([ \t]+)riverpod_lint:[ \t]*(.*?)(?:[ \t]+#.*)?[ \t]*$',
  );
  final versionLine = RegExp(
    r'^[ \t]+version:[ \t]*(.*?)(?:[ \t]+#.*)?[ \t]*$',
  );
  final acceptedValue = RegExp(r'^\^?\d+\.\d+\.\d+$');
  // 게으른 값 그룹은 키 뒤에 주석만 있으면 `# 주석` 을 값으로 잡는다 — 그 값은 빈 값이다.
  String valueOf(String raw) => raw.startsWith('#') ? '' : raw;
  // 줄 앞의 공백 · 탭 수 — 맵 안의 줄인지 가른다.
  int indentOf(String line) => line.length - line.trimLeft().length;

  String? declared;
  for (var i = 0; i < lines.length && declared == null; i++) {
    final key = keyLine.firstMatch(lines[i]);
    if (key == null) continue;
    final scalarValue = valueOf(key.group(2)!);
    if (scalarValue.isNotEmpty) {
      declared = scalarValue;
      break;
    }
    // 맵 꼴 — 키 줄보다 깊은 줄이 이어지는 동안 `version:` 을 찾는다.
    final keyIndent = key.group(1)!.length;
    for (var j = i + 1; j < lines.length; j++) {
      final trimmed = lines[j].trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      if (indentOf(lines[j]) <= keyIndent) break;
      final version = versionLine.firstMatch(lines[j]);
      if (version == null) continue;
      final versionValue = valueOf(version.group(1)!);
      if (versionValue.isNotEmpty) {
        declared = versionValue;
        break;
      }
    }
  }
  if (declared == null) {
    throw const FormatException('$shownAs 에서 riverpod_lint 선언을 찾지 못했다');
  }
  final value = unquotedScalar(declared);
  if (!acceptedValue.hasMatch(value)) {
    throw FormatException(
      '$shownAs 의 riverpod_lint 선언 `$value` 을 읽지 못했다 — `^X.Y.Z` 나 `X.Y.Z` 꼴만 받는다 (범위 제약은 받지 않는다, 05-REVIEW.md WR-05)',
    );
  }
  return value;
}

/// 두 줄 목록이 순서와 내용까지 같은지 본다.
bool sameLines(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// [file] 에서 주석과 빈 줄을 뺀 줄을 돌려준다 (뒤 공백만 뗀다 — 들여쓰기는 살린다).
///
/// 판정은 이 줄들을 `trim()` 해 견주고, 화면에는 들여쓰기를 살린 줄을 보여 준다.
/// 파일이 없으면 null 이다. `[3/N]` 의 include-만 확인과 `[4/N]` 이 함께 쓴다.
List<String>? significantLines(File file) {
  if (!file.existsSync()) return null;
  return file
      .readAsLinesSync()
      .map((l) => l.trimRight())
      .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'))
      .toList();
}

/// [lines] 가운데 코드 블록(펜스 블록) 안의 줄만 돌려준다 (펜스 줄 자체는 뺀다).
///
/// 블록 밖에서 `trimLeft()` 한 줄이 백틱 셋 이상 또는 `~` 셋 이상의 연속으로 시작하면 블록이
/// 열린다 — 그 문자와 연속 길이를 기억한다 (뒤의 info string, 예 `yaml`, 은 보지 않는다).
/// 블록 안에서는 `trim()` 한 줄이 기억한 문자만으로 이루어지고 길이가 기억한 길이 이상일
/// 때만 닫힌다 — 다른 문자의 펜스, 더 짧은 펜스, 펜스 뒤에 글자가 붙은 줄은 블록 안의 줄이다
/// (CommonMark 의 `~~~` 펜스와 닫는 펜스 규칙, 05-REVIEW.md WR-03). 닫히지 않은 블록은 파일
/// 끝까지다. 들여쓰기는 `trimLeft()` 로 받는다 (목록 안 블록을 놓치지 않게).
///
/// `[3/N]` 의 README 검사 (f) · (g) 가 쓴다 — 복사해 쓰는 값은 블록 안에 있고, 산문은 옛
/// 값(`ref: v1.3.0` 등)을 인용할 수 있어서다 (05-RESEARCH.md Pattern 2). 블록이 없으면 빈
/// 목록이다.
///
/// 펜스가 아닌 코드 블록(네 칸 들여 쓴 블록 · 인용(`>`) 안의 펜스)은 보지 않는다 (05-REVIEW.md WR-09 — 소유자 결정 G2-Q2 · G2-Q5, 검사는 넓히지 않았다).
/// 닫는 줄의 들여쓰기는 보지 않는다 — 펜스 안에서 네 칸 이상 들여 쓴 펜스 문자 줄(백틱 셋 이상 · `~~~`)도 그 펜스를 닫는 것으로 보아 그 뒤의 같은 블록 줄은 돌려주지 않는다 (CommonMark 의 닫는 펜스는 세 칸까지다 — 05-REVIEW.md IN-10, 소유자 결정 G4-Q2 로 검사는 고치지 않았다).
List<String> fencedLines(List<String> lines) {
  final out = <String>[];
  final openPattern = RegExp(r'^(`{3,}|~{3,})');
  // 열린 블록의 펜스 문자 — null 이면 블록 밖이다.
  String? fenceChar;
  var fenceLength = 0;
  for (final line in lines) {
    if (fenceChar == null) {
      final open = openPattern.firstMatch(line.trimLeft());
      if (open != null) {
        fenceChar = open.group(1)![0];
        fenceLength = open.group(1)!.length;
      }
      continue;
    }
    final trimmed = line.trim();
    final closes =
        trimmed.length >= fenceLength &&
        trimmed.split('').every((c) => c == fenceChar);
    if (closes) {
      fenceChar = null;
      continue;
    }
    out.add(line);
  }
  return out;
}

/// [lines] 의 줄마다 펜스 코드 블록 안인지(여는 줄 · 닫는 줄 포함) 표시한다.
///
/// 규칙은 [fencedLines] 와 같다 — 블록 밖에서 `trimLeft()` 한 줄이 백틱 셋 이상 또는 `~` 셋
/// 이상의 연속으로 시작하면 열리고 그 문자와 길이를 기억하며, 블록 안에서는 `trim()` 한 줄이
/// 기억한 문자만으로 되고 길이가 같거나 길 때 닫힌다. 닫히지 않으면 파일 끝까지다.
/// 같은 규칙을 줄 번호로 쓰려고 따로 둔다 — [fencedLines] 는 소유자 결정 G2-Q2 로 이번에 바꾸지
/// 않았다. 펜스 규칙을 고칠 때는 둘을 함께 고친다. `[3/N]` (d′) 의
/// [findListLinesOutsideMarkers] 가 쓴다.
List<bool> markFencedLines(List<String> lines) {
  final marks = List<bool>.filled(lines.length, false);
  final openPattern = RegExp(r'^(`{3,}|~{3,})');
  // 열린 블록의 펜스 문자 — null 이면 블록 밖이다.
  String? fenceChar;
  var fenceLength = 0;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (fenceChar == null) {
      final open = openPattern.firstMatch(line.trimLeft());
      if (open != null) {
        fenceChar = open.group(1)![0];
        fenceLength = open.group(1)!.length;
        marks[i] = true;
      }
      continue;
    }
    marks[i] = true;
    final trimmed = line.trim();
    if (trimmed.length >= fenceLength &&
        trimmed.split('').every((c) => c == fenceChar)) {
      fenceChar = null;
    }
  }
  return marks;
}

/// YAML 스칼라 값 [raw] 에서 바깥 따옴표 한 쌍을 벗긴다.
///
/// `trim()` 한 값이 같은 문자의 따옴표(`'…'` 또는 `"…"`)로 열리고 닫히면 그 안을, 아니면
/// `trim()` 한 값을 그대로 돌려준다. 한쪽만 있거나 짝이 다른 따옴표는 벗기지 않는다 — 그
/// 값은 부르는 쪽의 꼴 검사에서 실패한다. YAML 에서 `"^3.1.9"` 와 `^3.1.9` 는 같은 값이라
/// analyzer 에게 같은 선언이므로, 검사도 같은 값으로 읽는다 (05-REVIEW.md WR-02 · WR-05).
/// `[3/N]` 의 README 검사 (f) · (g) 가 펜스 코드 블록 안에서 키가 줄 머리에 오는 줄의 값을 읽을 때 쓴다 (plugin 선언 · pubspec reader 도 쓴다).
String unquotedScalar(String raw) {
  final trimmed = raw.trim();
  final quoted = RegExp(r'''^(['"])(.*)\1$''').firstMatch(trimmed);
  return quoted == null ? trimmed : quoted.group(2)!;
}

/// `pubspec.yaml` 의 `version:` 에서 `major.minor.patch` 만 돌려준다 (`2.0.0-dev` → `2.0.0`).
///
/// `-pre` · `+build` 꼬리는 떨어진다. 값의 바깥 따옴표(`version: "2.0.0-dev"`)와 줄 끝
/// `# 주석` 은 벗겨 읽는다 — YAML 에서 따옴표 값은 같은 값이다 (05-REVIEW.md IN-01,
/// [unquotedScalar]). `[3/N]` 의 README 검사 (g) 가 README 펜스 코드 블록 안에서 키가 줄 머리에 오는 `ref: vX.Y.Z` 줄의 값과 견준다.
/// 줄은 [splitYamlLines] 로 나눠 한 줄씩 본다 — 여러 줄 정규식은 U+2028 · U+2029 도 줄
/// 경계로 보아 주석 줄 안에 숨긴 `version:` 을 읽을 수 있었다 (소유자 결정 G3-R2-Q1).
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

/// 저장소 루트가 받은 기반 세트(`lints` · `flutter_lints`)가 켜는 규칙을 읽는다.
///
/// 돌려주는 맵은 소문자로 바꾼 규칙 이름 → `<패키지 폴더 이름> <파일 이름>`
/// (예: `flutter_lints-6.0.0 flutter.yaml`) 이다. 상류 YAML 은 `prefer_iterable_whereType`
/// 처럼 대문자가 섞인 이름을 쓰므로 소문자로 맞춰 견준다 (spike 020).
/// 한 규칙이 여러 파일에 있으면 먼저 읽은 파일(core → recommended → flutter)을 적는다.
///
/// `.dart_tool/package_config.json` 의 `rootUri` 를 그 파일 기준으로 푼다 — `file:` 절대
/// URI 면 그대로, 상대 경로면 `.dart_tool/` 기준이다. 저장소 루트의 `pub get` (준비 3) 뒤에
/// 부른다. 패키지가 없으면 [FormatException] (main 이 종료 코드 70 으로 끝낸다).
/// 파일마다 규칙을 하나도 읽지 못하면 [FormatException] (70) — 겹침 검사가 `겹침 0` 으로
/// 통과하지 않게 (04-REVIEW.md WR-06).
///
/// measure_rules.dart 의 `readUpstreamSets` 와 같다 — 두 파일은 서로 import 하지 않는다.
Map<String, String> readUpstreamRules(String repoRoot) {
  final configFile = File('$repoRoot/.dart_tool/package_config.json');
  final config =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  final packages = (config['packages'] as List).cast<Map<String, dynamic>>();
  Directory rootOf(String package) {
    final entry = packages.firstWhere(
      (p) => p['name'] == package,
      orElse: () => throw FormatException(
        '.dart_tool/package_config.json 에 $package 가 없다 — 저장소 루트에서 pub get',
      ),
    );
    var rootUri = entry['rootUri'] as String;
    if (!rootUri.endsWith('/')) rootUri = '$rootUri/';
    return Directory.fromUri(configFile.absolute.uri.resolve(rootUri));
  }

  final rules = <String, String>{};
  void readSet(String package, String fileName) {
    final root = rootOf(package);
    final folder = root.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final file = File.fromUri(root.uri.resolve('lib/$fileName'));
    var read = 0;
    for (final line in file.readAsLinesSync()) {
      final name = RegExp(r'^    - (\w+)').firstMatch(line)?.group(1);
      if (name == null) continue;
      read++;
      rules.putIfAbsent(name.toLowerCase(), () => '$folder $fileName');
    }
    if (read == 0) {
      throw FormatException(
        '$folder $fileName 에서 규칙을 하나도 읽지 못했다 — 상류 YAML 의 형식이 바뀌었다 (04-REVIEW.md WR-06)',
      );
    }
  }

  readSet('lints', 'core.yaml');
  readSet('lints', 'recommended.yaml');
  readSet('flutter_lints', 'flutter.yaml');
  return rules;
}

/// 마커 구역 하나에서 읽은 결과 — 이름과 읽지 못한 줄.
///
/// [readRulesMdBlock] (표) 과 [readBulletBlock] (불릿) 이 돌려준다.
class MarkerBlock {
  /// [names] 는 구역에서 읽은 이름, [malformed] 는 읽지 못한 줄(원문)이다.
  MarkerBlock(this.names, this.malformed);

  /// 구역의 줄 순서대로 읽은 이름 (backtick 을 뗀 것).
  final List<String> names;

  /// 그 reader 의 줄 규칙에 맞지 않아 읽지 못한 줄 (`trim()` 한 원문).
  final List<String> malformed;
}

/// [file] 에서 `<!-- woody:<name>:start -->` 와 `<!-- woody:<name>:end -->` 사이의 줄
/// 목록(마커 줄 제외)을 돌려준다.
///
/// 마커는 글자 그대로 — 들여쓰기 · 뒤 공백도 안 된다. 파일이 없거나 마커 둘 중 하나를
/// 찾지 못하거나 end 가 start 앞이면 null 이다. [readRulesMdBlock] (표) · [readBulletBlock]
/// (불릿) 이 이 줄 목록에 각자의 줄 규칙을 적용한다 (05-REVIEW.md IN-06). 마커의 자리는
/// [findMarkerRange] 로 찾는다.
List<String>? readMarkerBlock(File file, String name) {
  if (!file.existsSync()) return null;
  final lines = file.readAsLinesSync();
  final range = findMarkerRange(lines, name);
  if (range == null) return null;
  final (start, end) = range;
  return lines.sublist(start + 1, end);
}

/// [lines] 에서 `<!-- woody:<name>:start -->` 와 `<!-- woody:<name>:end -->` 의 자리(0 부터)를
/// 찾는다.
///
/// 마커는 글자 그대로 — 들여쓰기 · 뒤 공백도 안 된다. 마커 둘 중 하나를 찾지 못하거나 end 가
/// start 앞이면 null 이다. 마커 문자열은 이 함수 한 곳에만 둔다 — [readMarkerBlock] 과
/// [findListLinesOutsideMarkers] 가 쓴다.
(int, int)? findMarkerRange(List<String> lines, String name) {
  final start = lines.indexOf('<!-- woody:$name:start -->');
  final end = lines.indexOf('<!-- woody:$name:end -->');
  if (start < 0 || end < 0 || end < start) return null;
  return (start, end);
}

/// [rulesMd] 의 마커 구역 [name] (`enabled-rules` 등) 에서 표 첫 칸의 이름을 읽는다.
///
/// 구역의 줄은 [readMarkerBlock] 으로 받고, 줄마다 `trim()` 한 값과 구역 안의 자리(0 부터)로
/// 다음 넷만 받는다. 첫 칸은 첫 `|` 와 두 번째 `|` 사이를 `trim()` 한 값이다.
///
/// - 머리 줄 — 0번째 줄이고 `|` 로 시작하며 첫 칸에 backtick 이 없다. 건너뛴다.
/// - 구분 줄 — 1번째 줄이고 0번째 줄이 머리 줄로 받아졌으며 `|---|---|` 꼴이다. 건너뛴다.
/// - 데이터 행 — `|` 로 시작하고 첫 칸이 backtick 으로 감싼 `[a-z0-9_-]+` 하나다. 이름을
///   [MarkerBlock.names] 에 담는다.
/// - 행이 없는 표의 줄 — `없음 — ` 으로 시작하는 줄. 구역에 데이터 행이 하나도 없고 이런
///   줄이 하나뿐일 때만 받는다 (지금 `woody:enabled-options` 의 꼴).
///
/// 그 밖의 줄(0번째가 아닌 backtick 없는 행, 대문자 이름, 첫 칸에 이름이 둘, 불릿, 평문,
/// 빈 줄, 1번째가 아닌 구분 줄, 데이터 행과 함께 있는 `없음 — …`)은 건너뛰지 않고
/// [MarkerBlock.malformed] 에 담아 `[3/N]` (c) 가 실패로 알린다 (05-REVIEW.md 와 같은 모양 —
/// 05-VERIFICATION.md gaps 1 의 원칙을 `RULES.md` 표에도, 소유자 결정 2026-10-14).
/// 파일이나 마커가 없으면 null 이다.
MarkerBlock? readRulesMdBlock(File rulesMd, String name) {
  final lines = readMarkerBlock(rulesMd, name);
  if (lines == null) return null;
  final names = <String>[];
  // 읽지 못한 줄은 구역 안의 자리와 함께 모아, 끝에 줄 순서대로 돌려준다.
  final rejected = <(int, String)>[];
  final emptyTableLines = <(int, String)>[];
  final separatorPattern = RegExp(r'^\|(?:[ \t]*:?-{3,}:?[ \t]*\|)+$');
  final namePattern = RegExp(r'^`([a-z0-9_-]+)`$');
  var headerAccepted = false;
  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trim();
    if (trimmed.startsWith('|')) {
      final cellEnd = trimmed.indexOf('|', 1);
      final cell =
          (cellEnd < 0 ? trimmed.substring(1) : trimmed.substring(1, cellEnd))
              .trim();
      if (i == 0 && !cell.contains('`')) {
        headerAccepted = true;
        continue;
      }
      if (i == 1 && headerAccepted && separatorPattern.hasMatch(trimmed)) {
        continue;
      }
      final match = namePattern.firstMatch(cell);
      if (match != null) {
        names.add(match.group(1)!);
        continue;
      }
    } else if (trimmed.startsWith('없음 — ')) {
      emptyTableLines.add((i, trimmed));
      continue;
    }
    rejected.add((i, trimmed.isEmpty ? '(빈 줄)' : trimmed));
  }
  // `없음 — …` 은 행이 없는 표를 말하는 줄 하나일 때만 받는다 — 행과 함께 있거나 둘 이상이면
  // 읽지 못하는 줄이다.
  if (names.isNotEmpty || emptyTableLines.length > 1) {
    rejected.addAll(emptyTableLines);
  }
  rejected.sort((a, b) => a.$1.compareTo(b.$1));
  return MarkerBlock(names, [for (final r in rejected) r.$2]);
}

/// [file] 의 마커 구역 [name] (`readme-rules`) 에서 불릿 줄의 이름을 읽는다.
///
/// 구역의 줄은 [readMarkerBlock] 으로 받고, 줄마다 `trim()` 한 값으로 다음 셋만 받는다.
///
/// - 빈 줄 — 건너뛴다.
/// - 분류 소제목 `**…**` (backtick 없는 굵은 글씨 한 줄) — 건너뛴다.
/// - 불릿 `- `이름`` (정확히 `- ` + backtick 으로 감싼 `[a-z0-9_-]+` 하나, 뒤에 아무것도
///   없음) — 이름을 [MarkerBlock.names] 에 담는다.
///
/// 그 밖의 줄(backtick 없는 불릿, 대문자 이름, 이름이 둘인 불릿, `*` · `+` · `1.` 불릿,
/// 평문)은 건너뛰지 않고 [MarkerBlock.malformed] 에 담아 `[3/N]` (d) 가 실패로 알린다
/// (05-VERIFICATION.md gaps 1 — Phase 4 WR-10 의 원칙을 README reader 에도). 마커 밖의
/// 줄은 보지 않는다 — 같은 절의 구역 밖 목록 줄은 [findListLinesOutsideMarkers] 가 본다 ((d′)).
/// 파일이나 마커가 없으면 null 이다.
MarkerBlock? readBulletBlock(File file, String name) {
  final lines = readMarkerBlock(file, name);
  if (lines == null) return null;
  final names = <String>[];
  final malformed = <String>[];
  final headingPattern = RegExp(r'^\*\*[^`]+\*\*$');
  final bulletPattern = RegExp(r'^- `([a-z0-9_-]+)`$');
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || headingPattern.hasMatch(trimmed)) continue;
    final bullet = bulletPattern.firstMatch(trimmed);
    if (bullet != null) {
      names.add(bullet.group(1)!);
    } else {
      malformed.add(trimmed);
    }
  }
  return MarkerBlock(names, malformed);
}

/// [lines] (README 의 줄) 에서 표시 구역 [name] 이 든 절의, 구역 밖 목록 줄을 찾는다 — `[3/N]`
/// (d′) 가 쓴다.
///
/// - 절은 마커로 찾는다 — start 마커 앞에서 가장 가까운 제목 줄의 다음 줄(없으면 파일 처음)부터,
///   end 마커 뒤의 첫 제목 줄 앞(없으면 파일 끝)까지. 제목 이름에 기대지 않아 제목을 바꿔도
///   같은 절을 본다.
/// - 제목 줄은 펜스 코드 블록 밖에서 `^ {0,3}#{1,6}(?:[ \t]|$)` 에 맞는 줄이다 — 수준을 가리지
///   않는다. 펜스 안의 `# …` 줄(YAML 주석)은 제목이 아니다 ([markFencedLines]). setext 제목
///   (`===` · `---` 밑줄)은 제목으로 보지 않는다 — 절이 길어져 더 많은 줄을 볼 뿐이다.
/// - 목록 줄은 펜스 밖에서 `^[ \t]*(?:>[ \t]*)*(?:[-*+]|\d{1,9}[.)])(?:[ \t]|$)` 에 맞는 줄
///   이다 — `-` · `*` · `+` · `1.` · `1)` 과 인용(`>`) 안의 목록. `**굵은 글씨**` · `---`
///   구분선은 기호 뒤가 공백이 아니라 걸리지 않는다.
/// - 마커 둘 사이(마커 줄 포함)는 보지 않는다 — 구역 안은 (d) 의 [readBulletBlock] 몫이다.
///
/// 돌려주는 항목은 `<줄 번호>행: <trim 한 원문>` 이고 줄 순서대로다. 마커가 하나라도 없으면
/// null 이다 — (d) 가 `구역이 없다` 로 이미 실패한다 (소유자 결정 G2-Q3).
List<String>? findListLinesOutsideMarkers(List<String> lines, String name) {
  final range = findMarkerRange(lines, name);
  if (range == null) return null;
  final (start, end) = range;
  final fenced = markFencedLines(lines);
  final headingPattern = RegExp(r'^ {0,3}#{1,6}(?:[ \t]|$)');
  final listPattern = RegExp(
    r'^[ \t]*(?:>[ \t]*)*(?:[-*+]|\d{1,9}[.)])(?:[ \t]|$)',
  );
  bool isHeading(int i) => !fenced[i] && headingPattern.hasMatch(lines[i]);
  var from = 0;
  for (var i = start - 1; i >= 0; i--) {
    if (isHeading(i)) {
      from = i + 1;
      break;
    }
  }
  var to = lines.length;
  for (var i = end + 1; i < lines.length; i++) {
    if (isHeading(i)) {
      to = i;
      break;
    }
  }
  return [
    for (var i = from; i < to; i++)
      if ((i < start || i > end) &&
          !fenced[i] &&
          listPattern.hasMatch(lines[i]))
        '${i + 1}행: ${lines[i].trim()}',
  ];
}

/// `[3/N]` (h) 블록의 마지막 안내 줄 — 줄 단위 reader 와 YAML 이 다르게 읽었을 때 고칠 곳을 말한다.
const yamlAgreementHint =
    '줄 단위로 읽은 값과 YAML (package:yaml — analyzer · pub 과 같은 해석기) 이 읽은 값이 '
    '다르면 검사는 그 값을 믿지 않는다 — 여러 줄 문자열(따옴표 · `|` · `>`) 안에 구조처럼 '
    '보이는 줄, 같은 키 두 번, 철자가 다른 키를 두지 않는다 '
    '(05-VERIFICATION.md 4회차 gap, 소유자 결정 G4-Q1).';

/// 줄 단위 reader [findUnexpectedKeys] 가 옵션 파일 본문([options])에서 본 키를 돌려준다 — `[3/N]` (h) 가 YAML 과 견준다.
///
/// [findUnexpectedKeys] 의 본문을 바꾸지 않고, 받는 키를 비워 두 번 부른다. 먼저
/// `allowed: const {}` 로 불러 모든 최상위 줄을 `topLevel` 로 받는다. 다음에는 그 이름을 모두
/// 받고 값 없는 최상위 키마다 받는 아래 키를 빈 집합으로 두어, 그 바로 아래 줄(첫 자식 줄의
/// 들여쓰기와 그보다 얕은 줄)을 모두 `nested` 로 받는다 — 그래서 결과는 reader 가 실제로 쓰는
/// 들여쓰기 · 블록 경계 규칙 그대로다 (같은 규칙을 다시 짜지 않는다).
///
/// 줄이 키 꼴(`<이름>:`)이면 키 이름을, 아니면 원문(`topLevel` 은 들여쓰기를 살린 원문,
/// `children` 은 trim 한 원문)을 담는다. 아래 줄의 목록 항목(`- …`)은 키가 아니라 담지 않는다.
/// 같은 키가 두 번 보이면 두 번 담는다 — YAML 은 같은 키를 두 번 받지 않으므로 reader 쪽에만
/// 두 번 보이는 키는 여러 줄 문자열 안의 줄이다 (05-VERIFICATION.md 4회차 gap, 소유자 결정 G4-Q1).
({List<String> topLevel, Map<String, List<String>> children})
keysSeenByLineReader(String options) {
  final keyPattern = RegExp(r'^([A-Za-z_][A-Za-z0-9_-]*):(?:[ \t]|$)');
  final valueLessKeyPattern = RegExp(
    r'^([A-Za-z_][A-Za-z0-9_-]*):[ \t]*(?:#.*)?$',
  );
  final listItemPattern = RegExp(r'^-(?:[ \t]|$)');
  // findUnexpectedKeys 가 돌려준 `<줄 번호>행: <원문>` 에서 원문만 뗀다.
  String textOf(String shown) => shown.substring(shown.indexOf('행: ') + 3);

  final topLevel = <String>[];
  final valueLessKeys = <String>{};
  for (final shown in findUnexpectedKeys(options, allowed: const {}).topLevel) {
    final text = textOf(shown);
    topLevel.add(keyPattern.firstMatch(text)?.group(1) ?? text);
    final valueLess = valueLessKeyPattern.firstMatch(text)?.group(1);
    if (valueLess != null) valueLessKeys.add(valueLess);
  }
  final nested = findUnexpectedKeys(
    options,
    allowed: topLevel.toSet(),
    childKeys: {for (final key in valueLessKeys) key: const <String>{}},
  ).nested;
  final children = <String, List<String>>{};
  for (final MapEntry(key: parent, value: lines) in nested.entries) {
    for (final shown in lines) {
      final text = textOf(shown).trim();
      if (listItemPattern.hasMatch(text)) continue;
      children
          .putIfAbsent(parent, () => [])
          .add(keyPattern.firstMatch(text)?.group(1) ?? text);
    }
  }
  return (topLevel: topLevel, children: children);
}

/// YAML 해석 결과([root] — [loadYaml] 이 돌려준 값)의 최상위 맵 키와, 값이 맵인 키마다 그 아래 키를 돌려준다.
///
/// [keysSeenByLineReader] 와 견줄 값이다. [root] 가 null(빈 문서)이면 둘 다 비고, 맵이 아니면
/// `topLevel` 에 `(맵이 아닌 문서)` 하나다. 키는 YAML 이 읽은 글자(따옴표를 벗긴 이름)다.
({List<String> topLevel, Map<String, List<String>> children}) keysSeenByYaml(
  Object? root,
) {
  if (root == null) return (topLevel: const [], children: const {});
  if (root is! YamlMap) {
    return (topLevel: const ['(맵이 아닌 문서)'], children: const {});
  }
  final children = <String, List<String>>{};
  for (final MapEntry(:key, :value) in root.entries) {
    if (value is YamlMap) children['$key'] = [for (final k in value.keys) '$k'];
  }
  return (topLevel: [for (final key in root.keys) '$key'], children: children);
}

/// YAML 해석 결과([root])의 `linter.rules` 를 글자로 돌려준다 — [declaredRuleNames] 와 견줄 값이다.
///
/// 목록이면 항목마다 그 글자, 맵이면 `<키>: <값>`, 그 밖의 값이면 그 글자 하나, 없으면 빈 목록이다.
List<String> yamlRuleNames(Object? root) {
  final linter = root is YamlMap ? root['linter'] : null;
  final rules = linter is YamlMap ? linter['rules'] : null;
  if (rules is YamlList) return [for (final rule in rules) '$rule'];
  if (rules is YamlMap) {
    return [for (final MapEntry(:key, :value) in rules.entries) '$key: $value'];
  }
  return rules == null ? const [] : ['$rules'];
}

/// YAML 해석 결과([root])의 `analyzer.language` 를 `<이름>: <값>` 글자로 돌려준다 — [enabledLanguageOptions] 와 견줄 값이다.
///
/// 켠 것만이 아니라 맵 전체다 (bool 은 `true` · `false`, 그 밖의 값은 그 글자라 다르게 나온다).
/// 맵이 아닌 값이면 `language: <값>` 하나, 없으면 빈 목록이다.
List<String> yamlLanguageOptions(Object? root) {
  final analyzer = root is YamlMap ? root['analyzer'] : null;
  final language = analyzer is YamlMap ? analyzer['language'] : null;
  if (language is YamlMap) {
    return [
      for (final MapEntry(:key, :value) in language.entries) '$key: $value',
    ];
  }
  return language == null ? const [] : ['language: $language'];
}

/// YAML 해석 결과([root])의 `plugins.riverpod_lint` 선언을 돌려준다 — [readShippedPluginConstraint] 와 견줄 값이다.
///
/// 스칼라면 그 값, 맵이면 그 `version` 의 값이다. 없으면 `(없음)` 이다.
String yamlPluginConstraint(Object? root) {
  final plugins = root is YamlMap ? root['plugins'] : null;
  final declared = plugins is YamlMap ? plugins[pluginPackage] : null;
  final value = declared is YamlMap ? declared['version'] : declared;
  return value == null ? '(없음)' : '$value';
}

/// `[3/N]` (h) — 줄 단위 reader 가 읽은 값을 YAML (package:yaml) 이 같은 파일에서 읽은 값과 견주어, 다른 것마다 블록 하나(줄 목록)를 돌려준다.
///
/// 견주는 것은 다섯 가지다.
/// - 조각 셋([ruleCheckTargets])의 규칙 — [declaredRuleNames] ↔ `linter.rules` ([yamlRuleNames]).
///   다른 조각에 규칙이 없다는 (b′) 의 판정도 여기서 YAML 과 맞는지 본다.
/// - 조각 셋의 최상위 키와 그 바로 아래 키 — [keysSeenByLineReader] ([findUnexpectedKeys]) ↔
///   최상위 맵의 키와 값이 맵인 키마다 그 아래 키 ([keysSeenByYaml]). 아래 키는 값 없는 최상위
///   키 모두에서 견준다.
/// - `lib/base.yaml` 의 analyzer 옵션 — [enabledLanguageOptions] ↔ `analyzer.language` ([yamlLanguageOptions]).
/// - `lib/riverpod.yaml` 의 riverpod_lint 선언 — [readShippedPluginConstraint] ↔ `plugins.riverpod_lint`
///   ([yamlPluginConstraint]).
/// - `pubspec.yaml` 의 version — [pubspecReleaseVersion] ↔ `version` 의 major.minor.patch
///   (블록에는 YAML 쪽의 원래 글자를 보인다).
///
/// 목록은 순서 없이 건수까지 견준다 ([subtractLines] 를 양쪽으로). YAML 로 읽지 못하는 파일
/// (같은 키 두 번, 깨진 YAML — [YamlException])은 블록 하나로 알리고 그 파일의 다른 비교는
/// 건너뛴다. [YamlException] 만 잡는다 — 그 밖의 예외는 지금처럼 main 이 받는다.
///
/// reader 는 바꾸지 않고 다시 부른다 — 앞의 확인이 같은 reader 를 이미 불러 그 [FormatException]
/// (종료 코드 70)은 여기까지 오지 않는다. 다른 것은 YAML 로 올바르고 analyzer 도 받는 파일에서
/// 검사가 본 값이 YAML 과 다른 정책 위반이라 70 이 아니라 `[3/N]` 실패다 (05-VERIFICATION.md
/// 4회차 gap, 05-REVIEW.md WR-15 · WR-16, 소유자 결정 G4-Q1).
List<List<String>> compareLineReadersWithYaml(String repoRoot) {
  const disagree = '줄 단위 reader 와 YAML 이 다르게 읽었다';
  const pluginFragment = 'lib/riverpod.yaml';
  final blocks = <List<String>>[];

  // 목록 둘을 건수까지 견준다 (순서 무시) — 다르면 블록 하나.
  void compareLists(String head, List<String> lineReader, List<String> yaml) {
    final onlyLineReader = subtractLines(lineReader, yaml)..sort();
    final onlyYaml = subtractLines(yaml, lineReader)..sort();
    if (onlyLineReader.isEmpty && onlyYaml.isEmpty) return;
    String joined(List<String> items) =>
        items.isEmpty ? '(없음)' : items.join(' · ');
    blocks.add([
      head,
      '  줄 단위 reader 에만: ${joined(onlyLineReader)}',
      '  YAML 에만: ${joined(onlyYaml)}',
      '',
      yamlAgreementHint,
    ]);
  }

  // 값 둘이 다를 때의 블록.
  void addValueBlock(String head, String lineReader, String yaml) {
    blocks.add([
      head,
      '  줄 단위 reader: $lineReader',
      '  YAML: $yaml',
      '',
      yamlAgreementHint,
    ]);
  }

  // 파일을 YAML 로 읽는다 — 읽지 못하면 블록 하나를 더하고 null 을 돌려준다.
  ({String text, Object? root})? load(String path) {
    final text = File('$repoRoot/$path').readAsStringSync();
    try {
      final Object? root = loadYaml(text, sourceUrl: Uri.file(path));
      return (text: text, root: root);
    } on YamlException catch (e) {
      final span = e.span;
      final at = span == null ? '' : '${span.start.line + 1}행: ';
      blocks.add([
        '`$path` 을 YAML 로 읽지 못했다 — $at${e.message}',
        '',
        yamlAgreementHint,
      ]);
      return null;
    }
  }

  for (final path in ruleCheckTargets) {
    final loaded = load(path);
    if (loaded == null) continue;
    final (:text, :root) = loaded;
    compareLists(
      '`$path` 의 규칙 — $disagree (declaredRuleNames ↔ linter.rules)',
      declaredRuleNames(text, shownAs: path),
      yamlRuleNames(root),
    );
    final lineReaderKeys = keysSeenByLineReader(text);
    final yamlKeys = keysSeenByYaml(root);
    compareLists(
      '`$path` 의 최상위 키 — $disagree (findUnexpectedKeys ↔ 최상위 맵)',
      lineReaderKeys.topLevel,
      yamlKeys.topLevel,
    );
    // reader 쪽 키 먼저, 그다음 YAML 에만 있는 키.
    for (final key in {
      ...lineReaderKeys.children.keys,
      ...yamlKeys.children.keys,
    }) {
      compareLists(
        '`$path` 의 `$key:` 바로 아래 키 — $disagree (findUnexpectedKeys ↔ $key 맵)',
        lineReaderKeys.children[key] ?? const [],
        yamlKeys.children[key] ?? const [],
      );
    }
    if (path == rulesFile) {
      compareLists(
        '`$path` 의 analyzer 옵션 — $disagree (enabledLanguageOptions ↔ analyzer.language)',
        [
          for (final MapEntry(:key, :value) in enabledLanguageOptions(
            text,
            shownAs: path,
          ).entries)
            '$key: $value',
        ],
        yamlLanguageOptions(root),
      );
    }
    if (path == pluginFragment) {
      final lineReader = readShippedPluginConstraint(repoRoot);
      final yaml = yamlPluginConstraint(root);
      if (lineReader != yaml) {
        addValueBlock(
          '`$path` 의 riverpod_lint 선언 — $disagree (readShippedPluginConstraint ↔ plugins.riverpod_lint)',
          lineReader,
          yaml,
        );
      }
    }
  }

  final pubspec = load('pubspec.yaml');
  if (pubspec != null) {
    final lineReader = pubspecReleaseVersion(repoRoot);
    final root = pubspec.root;
    final version = root is YamlMap ? root['version'] : null;
    final yaml = version == null ? '(없음)' : '$version';
    final release = RegExp(r'^(\d+\.\d+\.\d+)(?:[-+].*)?$')
        .firstMatch(yaml)
        ?.group(1);
    if (release != lineReader) {
      addValueBlock(
        '`pubspec.yaml` 의 version — $disagree (pubspecReleaseVersion ↔ version)',
        lineReader,
        yaml,
      );
    }
  }
  return blocks;
}

/// [3/N] 배포 파일의 구성 — 저장소 안의 파일끼리 어긋나지 않는지 한 단계로 본다 (D-11, D-12).
///
/// 확인을 모두 돌리고 실패를 모아 한 [StepResult] 로 돌려준다. analyzer 는 돌리지 않는다.
///
/// - (a) 묶음 · 별칭([includeOnlyFiles])은 include 줄만 담는다 (03-REVIEW.md WR-01).
/// - (a′) 조각([ruleCheckTargets])마다 최상위 키가 [allowedTopLevelKeys] 안이고, 그 바로 아래
///   키가 [allowedChildKeys] 안이다 ([findUnexpectedKeys]) — 철자가 다른 `linter` 키 ·
///   `formatter:` · `lib/codegen.yaml` 의 `analyzer: language:` · `lib/riverpod.yaml` 의 다른
///   plugin 도 실패. 예외를 던지지 않는다 (05-REVIEW.md WR-10, 소유자 결정 G2-Q1 · G2-Q4).
/// - (b′) `lib/base.yaml` 밖 조각([ruleCheckTargets] 에서 [rulesFile] 을 뺀 것)의 `linter:`
///   블록에 규칙이 없다 — "규칙은 `lib/base.yaml` 에만" 을 검사로 굳힌다 (04-REVIEW.md WR-11).
///   (b) · (c) 가 `lib/base.yaml` 하나만 읽어도 빈자리가 없다.
/// - (b) `lib/base.yaml` 의 규칙이 기반 세트([readUpstreamRules])와 겹치지 않는다 — 겹친
///   규칙은 정답지가 잡지 못한다 (기반 세트가 여전히 켜므로 진단이 그대로다).
/// - (c) `RULES.md` 의 켠 규칙 표 == `lib/base.yaml` 의 규칙 목록 (둘 다 정렬해 견준다 —
///   같은 이름이 두 번 적혀도 잡는다), 켠 analyzer 옵션 표 == `analyzer: language:` 의
///   `true` 키 (RULES-06) — 표 구역 안의 읽지 못하는 줄도 실패
/// - (d) README 의 표시 구역 `woody:readme-rules` 의 규칙 이름 == `lib/base.yaml` (D-01)
///   — 구역 안의 읽지 못하는 줄도 실패
/// - (d′) 그 표시 구역이 든 절(구역 앞의 제목부터 구역 뒤의 다음 제목 앞까지, 펜스 밖)에
///   구역 밖의 목록 줄이 없다 ([findListLinesOutsideMarkers], 소유자 결정 G2-Q3)
/// - (e) README 에서 `package:woody_lints/` 로 정확히 시작하는 주소가 모두 [expectedLibYamls] 에 있다
///   — `<이름>.yaml` 꼴이 아닌 `woody_lints` 주소, `.yaml` · `.yml` 로 끝나는 다른 패키지의 주소도 실패 (확장자가 `.yaml` · `.yml` 이 아닌 다른 패키지의 주소는 보지 않는다 — 05-REVIEW.md WR-14)
/// - (f) README 의 펜스 코드 블록 안에서 키가 줄 머리에 오는 `version:` · `riverpod_lint:` 줄의 값 == [readShippedPluginConstraint]
///   — 값의 따옴표 · 줄 끝 주석을 벗겨 읽고, 꼴이 틀린 값도 실패 (키는 따옴표 · 콜론 앞 공백 없이 글자 그대로인 줄만 후보 — 05-REVIEW.md WR-13)
/// - (g) README 의 펜스 코드 블록 안에서 키가 줄 머리에 오는 `ref: vX.Y.Z` 줄의 값 == [pubspecReleaseVersion] — 읽은 값이 0개면 실패 (VERIFY-06, D-02)
///   — 값의 따옴표 · 줄 끝 주석을 벗겨 읽고, 꼴이 틀린 값도 실패 (키는 따옴표 · 콜론 앞 공백 없이 글자 그대로인 줄만 후보 — 05-REVIEW.md WR-13)
/// - (h) 줄 단위 reader 가 읽은 값 == YAML (package:yaml) 이 같은 파일에서 읽은 값 ([compareLineReadersWithYaml]) — 조각 셋의 규칙과 최상위 키 · 그 바로 아래 키, `lib/base.yaml` 의 analyzer 옵션, `lib/riverpod.yaml` 의 riverpod_lint 선언, `pubspec.yaml` 의 version. YAML 로 읽지 못하는 파일(같은 키 두 번 · 깨진 YAML)도 실패 (05-VERIFICATION.md 4회차 gap, 소유자 결정 G4-Q1)
///
/// (e) 는 `package:` 로 시작하지 않는 scheme 오타 · `package:` 뒤의 공백 · `.yaml` · `.yml` 로 끝나지 않는 다른 패키지의 주소를 보지 않고, 주소 바로 뒤에 `,` · `.` 같은 문장 부호가 붙으면 `woody_lints` 주소는 꼴이 아닌 것으로 실패하고 다른 패키지의 주소는 후보가 되지 않는다. (f) · (g) 는 따옴표로 감싼 키 · 콜론 앞에 공백이 든 키(`"ref":` · `ref :`), flow 표기(`{…}`) 안의 키와 펜스가 아닌 코드 블록(네 칸 들여 쓴 블록 · 인용 안의 펜스)을 보지 않고, 펜스 안에서 네 칸 이상 들여 쓴 펜스 문자 줄(백틱 셋 이상 · `~~~`)은 그 펜스를 닫는 것으로 보아 그 뒤의 같은 블록 값은 견주지 않는다 (05-REVIEW.md WR-07 ~ WR-09 · WR-13 · WR-14 · IN-08 · IN-10 — 소유자 결정 G2-Q2 · G2-Q5 · G3-Q2 · G4-Q2, 검사는 넓히지 않았다).
StepResult checkShippedComposition(String repoRoot) {
  final details = <String>[];
  void addBlock(List<String> lines) {
    if (details.isNotEmpty) details.add('');
    details.addAll(lines);
  }

  // (a) 묶음 · 별칭은 include 만.
  for (final entry in includeOnlyFiles.entries) {
    final path = entry.key;
    final expected = entry.value;
    final rest = significantLines(File('$repoRoot/$path'));
    if (rest != null &&
        sameLines(rest.map((l) => l.trim()).toList(), expected)) {
      continue;
    }
    addBlock([
      if (rest == null)
        '`$path` 이 없다.'
      else ...[
        '`$path` 는 include 만 담아야 한다 — 주석 · 빈 줄을 뺀 내용 (${rest.length}줄):',
        if (rest.isEmpty) '  (없음)' else ...rest.map((l) => '  $l'),
      ],
      '  정해진 내용:',
      ...expected.map((l) => '    $l'),
      '',
      '규칙은 `lib/base.yaml` 에만 적는다 (03-REVIEW.md WR-01).',
    ]);
  }

  // (a′) 조각마다 받는 최상위 키(와 그 바로 아래 키)의 닫힌 목록 — 목록 밖의 줄은 블록으로
  // 알리고, 예외를 던지지 않으며 뒤의 (b′) 이하를 건너뛰게 하지 않는다 (05-VERIFICATION.md
  // 2회차 gap, 05-REVIEW.md WR-10, 소유자 결정 G2-Q1 · G2-Q4).
  const allowedKeysHint =
      '조각마다 받는 키는 tool/verify.dart 의 allowedTopLevelKeys · allowedChildKeys 가 정한다 — '
      '키는 열 0 에서 따옴표 · 콜론 앞 공백 없이 적고, 규칙은 `lib/base.yaml` 에만 적는다 '
      '(05-REVIEW.md WR-10, 소유자 결정 G2-Q1).';
  for (final target in ruleCheckTargets) {
    final allowed = allowedTopLevelKeys[target];
    if (allowed == null) {
      addBlock([
        '`$target` 이 받는 최상위 키가 정해져 있지 않다 — tool/verify.dart 의 allowedTopLevelKeys 에 적는다.',
      ]);
      continue;
    }
    final childKeys = allowedChildKeys[target] ?? const {};
    final unexpected = findUnexpectedKeys(
      File('$repoRoot/$target').readAsStringSync(),
      allowed: allowed,
      childKeys: childKeys,
    );
    if (unexpected.topLevel.isNotEmpty) {
      addBlock([
        '`$target` 의 최상위에 받지 않는 줄이 있다 (${unexpected.topLevel.length}) — 받는 키: ${allowed.join(' · ')}',
        ...unexpected.topLevel.map((l) => '  $l'),
        '',
        allowedKeysHint,
      ]);
    }
    for (final MapEntry(key: key, value: lines) in unexpected.nested.entries) {
      addBlock([
        '`$target` 의 `$key:` 바로 아래에 받지 않는 줄이 있다 (${lines.length}) — 받는 키: ${childKeys[key]!.join(' · ')}',
        ...lines.map((l) => '  $l'),
        '',
        allowedKeysHint,
      ]);
    }
  }

  // (b′) rulesFile 밖의 조각은 규칙을 담지 않는다 — 03-REVIEW.md WR-01 의 관례를 검사로
  // (04-REVIEW.md WR-11). 그래야 (b) · (c) 가 rulesFile 하나만 읽어도 빈자리가 없다.
  // riverpod.yaml 의 plugins: 는 declaredRuleNames 가 linter: 블록만 보므로 그대로 넘긴다.
  for (final target in ruleCheckTargets.where((t) => t != rulesFile)) {
    final extra = declaredRuleNames(
      File('$repoRoot/$target').readAsStringSync(),
      shownAs: target,
    );
    if (extra.isNotEmpty) {
      addBlock([
        '`$target` 에 규칙이 있다 (${extra.length}) — 규칙은 `$rulesFile` 에만 적는다.',
        ...extra.map((r) => '  $r'),
        '',
        '그 규칙을 `$rulesFile` 로 옮기고 `$rulesMdFile` 의 켠 규칙 표에 적는다 '
            '(03-REVIEW.md WR-01 의 관례, 04-REVIEW.md WR-11).',
      ]);
    }
  }

  // (b) 기반 세트와의 겹침.
  final baseText = File('$repoRoot/$rulesFile').readAsStringSync();
  final declared = declaredRuleNames(baseText, shownAs: rulesFile);
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

  // (c) RULES.md 와의 일치 — 켠 규칙, 켠 analyzer 옵션.
  final rulesMd = File('$repoRoot/$rulesMdFile');
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
      addBlock([
        '`$rulesMdFile` 의 `woody:$block` 구역에 읽지 못하는 줄이 있다 (${listed.malformed.length}):',
        ...listed.malformed.map((l) => '  $l'),
        '',
        '구역 안에는 표 머리 줄 · 구분 줄 · 첫 칸이 backtick 이름 하나인 행만 둔다 (행이 없는 표는 `없음 — …` 한 줄).',
      ]);
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
  final enabledOptions = enabledLanguageOptions(baseText, shownAs: rulesFile);
  compareBlock(
    block: 'enabled-options',
    shipped: [
      for (final entry in enabledOptions.entries)
        if (entry.value) entry.key,
    ],
    mismatchLine:
        '`$rulesMdFile` 의 켠 analyzer 옵션 표와 `$rulesFile` 의 `analyzer: language:` 가 다르다.',
  );

  // (d) ~ (g) README 가 가리키는 값 (각 검사가 보는 범위는 아래 주석) — 규칙 목록 · 프리셋 주소 · plugin 버전 · ref (VERIFY-06,
  // 05-CONTEXT.md D-01 · D-02). README 가 없으면 FileSystemException → main 이 70.
  final readme = File('$repoRoot/$readmeFile');
  final readmeLines = readme.readAsLinesSync();

  // (d) 표시 구역의 규칙 이름 == lib/base.yaml.
  final readmeListed = readBulletBlock(readme, readmeRulesBlock);
  if (readmeListed == null) {
    addBlock([
      '`$readmeFile` 의 `woody:$readmeRulesBlock` 구역이 없다 — 05-CONTEXT.md D-01',
      '',
      '`<!-- woody:$readmeRulesBlock:start -->` 와 `<!-- woody:$readmeRulesBlock:end -->` '
          '사이에 `- `규칙이름`` 불릿을 둔다.',
    ]);
  } else {
    if (readmeListed.malformed.isNotEmpty) {
      addBlock([
        '`$readmeFile` 의 `woody:$readmeRulesBlock` 구역에 읽지 못하는 줄이 있다 (${readmeListed.malformed.length}):',
        ...readmeListed.malformed.map((l) => '  $l'),
        '',
        '구역 안에는 빈 줄 · `**분류**` 소제목 · `- `규칙이름`` 불릿만 둔다 (05-VERIFICATION.md gaps 1).',
      ]);
    }
    final a = [...declared]..sort();
    final b = [...readmeListed.names]..sort();
    if (!sameLines(a, b)) {
      addBlock([
        '`$readmeFile` 의 규칙 목록과 `$rulesFile` 의 규칙 목록이 다르다.',
        ...subtractLines(a, b).map((r) => '  + $r  (base.yaml 에만)'),
        ...subtractLines(b, a).map((r) => '  - $r  (README.md 에만)'),
        '',
        '`$readmeFile` 의 목록 · `$rulesMdFile` 의 표 · `$rulesFile` 을 같은 커밋에서 고친다.',
      ]);
    }

    // (d′) 표시 구역이 든 절의 구역 밖 목록 줄 — 렌더링된 README 에서는 목록의 항목처럼 보이지만
    // (d) 는 구역 안만 읽는다 (소유자 결정 G2-Q3).
    final outside = findListLinesOutsideMarkers(readmeLines, readmeRulesBlock);
    if (outside != null && outside.isNotEmpty) {
      addBlock([
        '`$readmeFile` 의 `woody:$readmeRulesBlock` 표시 구역이 든 절에 구역 밖의 목록 줄이 있다 (${outside.length}):',
        ...outside.map((l) => '  $l'),
        '',
        '규칙 이름의 목록은 표시 구역 안에만 둔다 — 그 절(구역 앞의 제목부터 구역 뒤의 다음 제목 앞까지, '
            '펜스 코드 블록 밖)에는 목록 줄(`-` · `*` · `+` · `1.` · `1)`)을 두지 않는다 (소유자 결정 G2-Q3).',
      ]);
    }
  }

  // (e) README 에서 `package:woody_lints/` 로 정확히 시작하는 주소가 모두 lib/ 에 있다 — 파일 전체에서 `package:woody_lints/` 뒤의
  // 후보를 모두 모으고, `<이름>.yaml` 꼴이 아닌 것은 건너뛰지 않고 실패한다 (05-REVIEW.md
  // WR-01). 꼴이 맞는 후보만 lib/ 와 견준다.
  final readmeText = readmeLines.join('\n');
  final candidates = RegExp(
    r'''package:woody_lints/(\S+?)(?=[`\s)"']|$)''',
    multiLine: true,
  ).allMatches(readmeText).map((m) => m.group(1)!).toSet();
  final addressPattern = RegExp(r'^[A-Za-z0-9_]+\.yaml$');
  final malformedAddresses = [
    for (final c in candidates)
      if (!addressPattern.hasMatch(c)) c,
  ]..sort();
  final addresses = candidates.where(addressPattern.hasMatch).toSet();
  if (malformedAddresses.isNotEmpty) {
    addBlock([
      '`$readmeFile` 의 `package:woody_lints/` 주소 가운데 `<이름>.yaml` 꼴이 아닌 것이 있다 (${malformedAddresses.length}):',
      ...malformedAddresses.map((c) => '  package:woody_lints/$c'),
      '',
      '주소는 `package:woody_lints/<이름>.yaml` 로 적는다 — 이름은 영문 · 숫자 · `_`, 하위 폴더 없이, 확장자는 `.yaml` (05-REVIEW.md WR-01).',
    ]);
  }
  // (e) 다른 패키지의 `.yaml` 주소 — 이름 자리는 `/` · 공백이 아닌 글자 전부라 hyphen 이 든
  // 오타(`woody-lints`)도 후보다. 이 README 의 include 주소는 모두 woody_lints 다
  // (05-VERIFICATION.md W1, 소유자 결정 2026-10-14 R2-Q3). 주소 바로 뒤에 `,` · `.` 같은 문장 부호가 붙으면 후보가 되지 않는다 (05-REVIEW.md IN-08).
  final otherPackages = [
    ...RegExp(
          r'''package:([^/\s]+)/(\S+?\.ya?ml)(?=[`\s)"']|$)''',
          multiLine: true,
        )
        .allMatches(readmeText)
        .where((m) => m.group(1) != 'woody_lints')
        .map((m) => 'package:${m.group(1)}/${m.group(2)}')
        .toSet(),
  ]..sort();
  if (otherPackages.isNotEmpty) {
    addBlock([
      '`$readmeFile` 에 `woody_lints` 가 아닌 패키지의 `.yaml` 주소가 있다 (${otherPackages.length}):',
      ...otherPackages.map((a) => '  $a'),
      '',
      '이 README 의 include 주소는 모두 `package:woody_lints/<이름>.yaml` 이다 — 패키지 이름을 고친다 (05-VERIFICATION.md W1).',
    ]);
  }
  if (candidates.isEmpty) {
    addBlock(['`$readmeFile` 에 `package:woody_lints/<이름>.yaml` 주소가 하나도 없다.']);
  } else {
    final missing = addresses.difference(expectedLibYamls).toList()..sort();
    if (missing.isNotEmpty) {
      addBlock([
        '`$readmeFile` 가 가리키는 프리셋 주소가 `lib/` 에 없다 (${missing.length}):',
        ...missing.map((n) => '  package:woody_lints/$n'),
        '',
        '`lib/` 의 파일 이름과 `$readmeFile` 의 주소를 같은 커밋에서 고친다.',
      ]);
    }
  }

  // (f) · (g) 는 펜스 코드 블록 안의 줄만 본다 — 산문의 옛 값, 네 칸 들여 쓴 코드 블록 · 인용 안의 펜스는 세지 않는다 (05-REVIEW.md WR-09).
  final fenced = fencedLines(readmeLines);

  // (f) 코드 블록의 plugin 버전 == lib/riverpod.yaml. 줄 머리에 `version:` · `riverpod_lint:` 키가 오는 줄을 모두
  // 후보로 잡고, 따옴표와 줄 끝 `# 주석` 을 벗긴 값의 꼴을 본다 — 꼴이 틀린 값은 건너뛰지 않고
  // 실패한다 (05-REVIEW.md WR-02). 값 없는 맵 키 줄(`  riverpod_lint:`)과 주석만 붙은 키 줄은
  // 후보가 아니다. `version:` 은 `riverpod_lint:` 맵 아래로 좁히지 않는다 — README 에 pubspec
  // 예시 블록을 넣으면 그 `version:` 도 후보가 된다. flow 표기(`{…}`) 안의 키는 후보가 아니다 (05-REVIEW.md WR-08).
  // 키는 따옴표 · 콜론 앞 공백 없이 `version:` · `riverpod_lint:` 글자 그대로인 줄만 후보다 — `"version":` · `'riverpod_lint':` · `version :` 꼴은 후보가 아니다 (05-REVIEW.md WR-13 — 소유자 결정 G3-Q2).
  final shipped = readShippedPluginConstraint(repoRoot);
  final versionKeyPattern = RegExp(
    r'^\s*(?:version|riverpod_lint):[ \t]*(.*?)(?:[ \t]+#.*)?[ \t]*$',
  );
  final versionValuePattern = RegExp(r'^\^?\d+\.\d+\.\d+$');
  final versions = <String>[];
  final unreadableVersions = <String>[];
  for (final line in fenced) {
    final value = versionKeyPattern.firstMatch(line)?.group(1);
    // 게으른 그룹은 키 뒤에 주석만 있으면 `# 주석` 을 값으로 잡는다 — 그 줄도 값이 없는 줄이다.
    if (value == null || value.isEmpty || value.startsWith('#')) continue;
    final unquoted = unquotedScalar(value);
    if (versionValuePattern.hasMatch(unquoted)) {
      versions.add(unquoted);
    } else {
      unreadableVersions.add(line.trim());
    }
  }
  if (unreadableVersions.isNotEmpty) {
    addBlock([
      '`$readmeFile` 의 코드 블록에 읽지 못하는 `version:` · `riverpod_lint:` 줄이 있다 (${unreadableVersions.length}):',
      ...unreadableVersions.map((l) => '  $l'),
      '',
      '값은 `^X.Y.Z` 로 적는다 — 따옴표와 줄 끝 `# 주석` 은 받는다 (05-REVIEW.md WR-02).',
    ]);
  }
  if (versions.isEmpty && unreadableVersions.isEmpty) {
    addBlock([
      '`$readmeFile` 의 코드 블록에 `version:` · `riverpod_lint:` 줄이 하나도 없다.',
    ]);
  } else {
    final wrong = versions.where((v) => v != shipped).toSet().toList()..sort();
    if (wrong.isNotEmpty) {
      addBlock([
        '`$readmeFile` 의 코드 블록에 적힌 riverpod_lint 버전이 `lib/riverpod.yaml` 의 선언($shipped)과 다르다:',
        ...wrong.map((v) => '  $v'),
        '',
        '`$readmeFile` 의 끄기 예시 · `lib/riverpod.yaml` · `fixtures/overrides/analysis_options.yaml` 을 같은 커밋에서 고친다.',
      ]);
    }
  }

  // (g) 코드 블록의 `ref: vX.Y.Z` == pubspec.yaml 의 version (꼬리를 뗀 값). 줄 머리에 `ref:` 키가 오는 줄을 모두
  // 후보로 잡고 (f) 와 같이 따옴표와 줄 끝 `# 주석` 을 벗긴다. `ref: main` 은 세지 않고, 그 밖의
  // 꼴(값 없음 포함)은 실패한다 (05-REVIEW.md WR-02). flow 표기(`{…}`) 안의 키는 후보가 아니다 (05-REVIEW.md WR-08).
  // 키는 따옴표 · 콜론 앞 공백 없이 `ref:` 글자 그대로인 줄만 후보다 — `"ref":` · `ref :` 꼴은 후보가 아니다 (05-REVIEW.md WR-13 — 소유자 결정 G3-Q2).
  final release = pubspecReleaseVersion(repoRoot);
  final refKeyPattern = RegExp(r'^\s*ref:[ \t]*(.*?)(?:[ \t]+#.*)?[ \t]*$');
  final refValuePattern = RegExp(r'^v(\d+\.\d+\.\d+)$');
  final refs = <String>[];
  final unreadableRefs = <String>[];
  for (final line in fenced) {
    final value = refKeyPattern.firstMatch(line)?.group(1);
    if (value == null) continue;
    final unquoted = unquotedScalar(value.startsWith('#') ? '' : value);
    if (unquoted == 'main') continue;
    final match = refValuePattern.firstMatch(unquoted);
    if (match != null) {
      refs.add(match.group(1)!);
    } else {
      unreadableRefs.add(line.trim());
    }
  }
  if (unreadableRefs.isNotEmpty) {
    addBlock([
      '`$readmeFile` 의 코드 블록에 읽지 못하는 `ref:` 줄이 있다 (${unreadableRefs.length}):',
      ...unreadableRefs.map((l) => '  $l'),
      '',
      '`ref:` 는 `vX.Y.Z` 나 `main` 으로 적는다 — 따옴표와 줄 끝 `# 주석` 은 받는다 (05-REVIEW.md WR-02).',
    ]);
  }
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
}

/// [5/N] ~ [N/N] 연습용 프로젝트 하나([fixture])를 분석해 정답지와 견준다 (VERIFY-01).
///
/// 판정 순서는 바꾸지 않는다: plugin 준비 실패 → 도구가 죽음 → 정답지 비교.
/// 정답지 비교는 둘로 갈린다 — [Fixture.expectedPath] 가 없으면(`recommended`) 같은 실행의
/// `example` 결과([reference])와 견주고 갱신 모드에서도 쓸 것이 없다. 있으면 그 정답지와 견준다.
///
/// [update] 이면 바뀌는 줄을 `detailLines` 에 담고 정답지 쓰기를 `applyUpdate` 로
/// 돌려준다 — 쓰는 것은 `main` 이 그 줄을 화면에 내보낸 뒤다. 바뀐 것이 없으면 쓰지 않는다
/// (머리 주석의 날짜도 다시 쓰지 않는다). 앞의 두 실패에서는 [update] 여도 정답지를 건드리지
/// 않는다. 다른 단계가 실패한 실행에서는 `main` 이 쓰기 직전에 막는다. [sdk] 는 정답지
/// 머리 주석에 적는다.
Future<StepResult> compareFixture({
  required String repoRoot,
  required Fixture fixture,
  required bool update,
  required SdkInfo sdk,
  AnalyzeOutcome? reference,
}) async {
  final label = fixture.label;
  final fixtureDir = '$repoRoot/${fixture.path}';
  // fixture 경로를 그대로 붙인다 — `fixtures/base_only` 면 하위 폴더까지 만든다 (권고 2).
  final stateDir = '$repoRoot/.dart_tool/woody_verify/${fixture.path}';
  final shownStateDir = relativize(stateDir, repoRoot);
  Directory(stateDir).createSync(recursive: true);

  // 기다리는 동안의 진행 표시. 화면(stdout)에는 섞지 않는다.
  stderr.writeln('${fixture.path}/ 분석 중…');
  final outcome = await analyzeFixture(
    fixtureDir: fixtureDir,
    stateDir: stateDir,
  );
  // 버전은 분석이 끝난 뒤에 읽는다 (처음 실행에서는 분석 전에 plugin 폴더가 없다).
  // plugin 을 쓰지 않는 fixture 는 plugin 폴더 0개가 정상이라 읽지 않는다.
  final plugin = fixture.usesPlugin
      ? readPluginVersion(stateDir, shownAs: shownStateDir)
      : PluginVersion.notApplicable();

  // 1) plugin 준비 실패 — 종료 코드로는 알 수 없고 stderr 의 머리말로만 드러난다.
  if (outcome.hasPluginHeader) {
    return StepResult(
      label: label,
      passed: false,
      plugin: plugin,
      pluginFailed: true,
      outcome: outcome,
      detailLines: [
        '${fixture.path}/ — plugin 준비 실패 — $pluginPackage 진단 없이 끝났다 '
            '(dart analyze exit ${outcome.exitCode}). stderr:',
        ...scrubPaths(
          outcome.stderrText,
          repoRoot,
        ).split('\n').map((l) => '  $l'),
        '',
        '네트워크를 확인하세요.',
        '전용 상태 폴더 `$shownStateDir` 를 지우고 다시 실행하세요 (약 15초).',
      ],
    );
  }

  // 2) 도구가 죽음 — 정답지와 "다르다" 가 아니라 결과 자체가 없다.
  final actual = outcome.lines;
  if (actual == null || !analyzeExitCodes.contains(outcome.exitCode)) {
    final stderrHead = scrubPaths(
      outcome.stderrText,
      repoRoot,
    ).split('\n').take(2).join(' / ');
    return StepResult(
      label: label,
      passed: false,
      plugin: plugin,
      outcome: outcome,
      detailLines: [
        '${fixture.path}/ — 도구가 죽었다 — dart analyze 가 exit ${outcome.exitCode} 로 끝났다'
            '${actual == null ? ' (stdout 에 JSON 없음)' : ''}.',
        '  stderr: ${stderrHead.isEmpty ? '(비어 있음)' : stderrHead}',
        '',
        '다시 실행해 보세요. 되풀이되면 위의 stderr 를 확인하세요.',
      ],
    );
  }

  // 3a) 자기 정답지가 없다 — 같은 실행의 example 결과와 견준다 (D-03, Pitfall 12).
  // 파일과 견주지 않으므로 갱신 모드에서도 쓸 것이 없다.
  final expectedPath = fixture.expectedPath;
  if (expectedPath == null) {
    if (reference == null || reference.lines == null) {
      return StepResult(
        label: label,
        passed: false,
        plugin: plugin,
        outcome: outcome,
        detailLines: [
          '${fixture.path}/ — 견줄 결과가 없다 — example 의 분석이 끝나지 않았거나 죽었다.',
        ],
      );
    }
    final difference = findDifference(
      Expected.fromOutcome(reference),
      actual,
      outcome.exitCode,
    );
    if (difference.isEmpty) {
      return StepResult(
        label: label,
        passed: true,
        plugin: plugin,
        outcome: outcome,
      );
    }
    final exitNote = difference.exitNote;
    return StepResult(
      label: label,
      passed: false,
      plugin: plugin,
      outcome: outcome,
      detailLines: [
        '${fixture.path}/ — 같은 실행의 example 결과와 다르다.',
        if (exitNote != null) ...[exitNote.replaceFirst('정답지', 'example'), ''],
        'example 에는 있는데 여기서 나오지 않은 경고 (${difference.missing.length})',
        ...difference.missing.map((l) => '  $l'),
        '',
        'example 에 없는데 여기서 나온 경고 (${difference.unexpected.length})',
        ...difference.unexpected.map((l) => '  $l'),
        '',
        '묶음(lib/recommended.yaml)과 별칭(lib/analysis_options.yaml)이 같은 것을 받는지 확인하세요.',
      ],
    );
  }

  // 3b) 자기 정답지와 견준다.
  final expectedFile = File('$fixtureDir/$expectedPath');
  final expected = expectedFile.existsSync()
      ? Expected.read(expectedFile)
      : null;
  final difference = findDifference(expected, actual, outcome.exitCode);
  final exitNote = difference.exitNote;

  if (update) {
    // 조용히 덮어쓰지 않는다 — 무엇이 바뀌는지 보여 주고, 그 뒤에 쓴다.
    // 이 가지는 늘 통과다 — 실패로 세면 `--update` 가 자기가 쓰려는 차이에 막힌다.
    if (expected != null && difference.isEmpty) {
      // 바뀐 것이 없으면 쓰지 않는다 — 머리 주석의 날짜만 바뀌는 커밋을 만들지 않는다.
      return StepResult(
        label: label,
        passed: true,
        plugin: plugin,
        outcome: outcome,
        resultWord: '바뀐 줄 없음',
      );
    }
    final measured = formatMeasuredLine(sdk, plugin, DateTime.now());
    final target = '${fixture.path}/$expectedPath';
    return StepResult(
      label: label,
      passed: true,
      plugin: plugin,
      outcome: outcome,
      updateTarget: target,
      resultWord: '갱신',
      detailLines: [
        '정답지 갱신 대상: $target',
        ?exitNote,
        ...difference.missing.map((l) => '- $l'),
        ...difference.unexpected.map((l) => '+ $l'),
        '머리 주석: $measured',
      ],
      applyUpdate: () => writeExpected(
        expectedFile,
        expected,
        actual,
        outcome.exitCode,
        measured,
      ),
    );
  }

  if (expected == null) {
    return StepResult(
      label: label,
      passed: false,
      plugin: plugin,
      outcome: outcome,
      detailLines: ['${fixture.path}/ — 정답지가 없다. 처음이면 `$updateCommand` 로 만든다.'],
    );
  }
  if (difference.isEmpty) {
    return StepResult(
      label: label,
      passed: true,
      plugin: plugin,
      outcome: outcome,
    );
  }

  return StepResult(
    label: label,
    passed: false,
    plugin: plugin,
    outcome: outcome,
    detailLines: [
      '${fixture.path}/$expectedPath 와 다르다.',
      if (exitNote != null) ...[exitNote, ''],
      '정답지에는 있는데 나오지 않은 경고 (${difference.missing.length})',
      ...difference.missing.map((l) => '  $l'),
      '',
      '정답지에 없는데 나온 경고 (${difference.unexpected.length})',
      ...difference.unexpected.map((l) => '  $l'),
      '',
      '일부러 바꾼 것이면 정답지를 갱신하세요:',
      '  $updateCommand',
    ],
  );
}

/// 터미널에서 [text] 가 차지하는 칸 수를 센다 (한글 등 전각 문자는 2칸).
int measureWidth(String text) {
  var width = 0;
  for (final rune in text.runes) {
    final wide =
        (rune >= 0x1100 && rune <= 0x115F) ||
        (rune >= 0x2E80 && rune <= 0xA4CF) ||
        (rune >= 0xAC00 && rune <= 0xD7A3) ||
        (rune >= 0xF900 && rune <= 0xFAFF) ||
        (rune >= 0xFF00 && rune <= 0xFF60);
    width += wide ? 2 : 1;
  }
  return width;
}

/// 단계 줄 `[n/N] <label> ..... 통과|실패` 를 만든다. 결과 단어가 같은 열에 오도록 점으로 채운다.
///
/// 갱신 모드의 정답지 단계는 [StepResult.resultWord] (`바뀐 줄 없음` / `갱신`) 를 찍는다.
String formatStepLine(int index, int total, StepResult result) {
  final head = '[$index/$total] ${result.label} ';
  final room = resultColumn - measureWidth(head);
  final dots = '.' * (room < 3 ? 3 : room);
  return '$head$dots ${result.resultWord ?? (result.passed ? '통과' : '실패')}';
}

/// 화면 맨 위의 버전 세 줄(SDK / 기반 세트 / plugin)을 만든다 (D-07).
///
/// 정답지가 깨졌을 때 원인이 저장소 변경인지 새 버전인지 화면에서 바로 보이게 한다.
/// [pluginFailed] 이면 plugin 줄에 덧말을 붙인다 — 그 실행에서 읽힌 버전은 앞선
/// 실행이 남긴 값일 수 있다.
List<String> formatVersionLines({
  required SdkInfo sdk,
  required String? flutterLints,
  required String? lints,
  required PluginVersion plugin,
  required bool pluginFailed,
}) {
  String formatRow(String label, String value) =>
      '$label${' ' * (versionColumn - measureWidth(label))}$value';
  final reason = plugin.reason;
  return [
    formatRow('SDK', 'Flutter ${sdk.flutter} / Dart ${sdk.dart}'),
    formatRow(
      '기반 세트',
      'flutter_lints ${flutterLints ?? '?'} / lints ${lints ?? '?'}',
    ),
    formatRow(
      'plugin',
      '$pluginPackage ${plugin.text}'
          '${reason == null ? '' : ' ($reason)'}'
          '${pluginFailed ? ' (이번 실행에서는 plugin 이 뜨지 않았다)' : ''}',
    ),
  ];
}

/// 정답지 비교 단계들이 읽은 plugin 버전을 화면의 `plugin` 줄 하나로 요약한다 (권고 4).
///
/// plugin 을 쓰는 fixture 의 값만 본다 — 쓰지 않는 fixture 의 `해당 없음` 은 섞지 않는다.
/// 하나도 없으면 "돌리지 못했다", 하나라도 못 읽었으면 그 첫 이유, 서로 다른 값이 둘 이상이면
/// "fixture 마다 다름" 이고, 아니면 그 값이다. 같은 실행에서 값이 갈릴 길은 없지만 막아 둔다.
PluginVersion summarizePluginVersion(List<StepResult> results) {
  final applicable = results
      .map((r) => r.plugin)
      .nonNulls
      .where((p) => p.applicable)
      .toList();
  if (applicable.isEmpty) {
    return PluginVersion.unknown('정답지 비교를 돌리지 못했다');
  }
  final unknown = applicable.where((p) => p.version == null).firstOrNull;
  if (unknown != null) return unknown;
  final versions = applicable.map((p) => p.version!).toSet();
  if (versions.length > 1) {
    return PluginVersion.unknown('fixture 마다 다름: ${versions.join(', ')}');
  }
  return PluginVersion.resolved(versions.single);
}

/// 인자를 읽고, 준비(SDK 확인 · pub get)를 한 뒤, 단계를 모두 돌리고 화면을 한 번에 찍는다.
///
/// 화면(버전 3줄 · 단계 줄 · 실패의 내용 · 요약)은 전부 stdout 이고 첫 줄은 늘 `SDK`
/// 줄이다 — plugin 버전은 분석이 끝나야 읽히므로 단계를 모두 돌린 뒤에 찍는다.
/// 사용법 오류, 준비 단계의 안내, 진행 표시는 stderr 다.
Future<void> main(List<String> args) async {
  final unknown = args.where((a) => a != '--update').toList();
  if (unknown.isNotEmpty) {
    stderr.writeln('모르는 인자: ${unknown.join(' ')}');
    stderr.writeln('사용법: $runCommand [--update]');
    await quit(64);
  }
  final update = args.contains('--update');

  // tool/ 의 부모가 저장소 루트다. 어느 폴더에서 실행해도 같은 파일을 본다.
  final repoRoot = File.fromUri(Platform.script).parent.parent.path;

  try {
    // 준비 1 — 실행 중인 SDK 가 .fvmrc 와 다르면 검증을 시작하지 않는다 (D-12).
    final sdk = await ensurePinnedSdk(repoRoot);

    // 준비 2 — 정답지 갱신은 로컬에서 사람이 diff 를 보고 커밋한다 (D-14).
    final env = Platform.environment;
    if (update && (env['CI'] == 'true' || env['GITHUB_ACTIONS'] == 'true')) {
      stderr.writeln('CI 에서는 --update 를 쓰지 않는다 — 로컬에서 갱신해 커밋하세요.');
      await quit(64);
    }

    // 준비 3 — 저장소 루트의 패키지. 규칙 검사의 복사본이 `flutter_lints` 를 include 하므로
    // 루트의 package_config 가 있어야 한다 (없으면 include 가 풀리지 않아 규칙을 못 본다).
    await runPubGet(repoRoot, enforceLockfile: false, shownAs: '저장소 루트');

    // 준비 4 — fixture 의 패키지는 커밋된 lock 그대로 받는다.
    for (final fixture in fixtures) {
      await runPubGet(
        '$repoRoot/${fixture.path}',
        enforceLockfile: true,
        shownAs: '${fixture.path}/',
      );
    }

    // 단계는 하나가 실패해도 나머지를 모두 돌린다. fixture 는 표의 순서대로 차례로 분석한다
    // (빈 상태 폴더에 처음 실행 둘을 동시에 띄우면 드물게 깨진다 — spike 008).
    // recommended 는 같은 실행의 example 결과를 받아 견주므로 example 뒤에 돈다.
    final results = <StepResult>[
      checkLibHasNoDart(repoRoot),
      await checkRuleNames(repoRoot),
      checkShippedComposition(repoRoot),
      checkFixtureOptions(repoRoot, fixtures),
    ];
    AnalyzeOutcome? exampleOutcome;
    for (final fixture in fixtures) {
      final result = await compareFixture(
        repoRoot: repoRoot,
        fixture: fixture,
        update: update,
        sdk: sdk,
        reference: fixture.expectedPath == null ? exampleOutcome : null,
      );
      if (fixture.path == 'example') exampleOutcome = result.outcome;
      results.add(result);
    }

    // 화면 — 버전 3줄, 단계 줄, 단계별 내용, 요약 순으로 한 번에 찍는다.
    // 기반 세트는 첫 fixture 의 lock 에서, plugin 은 plugin 을 쓰는 fixture 들의 상태 폴더에서
    // 읽은 값을 하나로 요약한 것이다 (summarizePluginVersion).
    final baseLock = File('$repoRoot/${fixtures.first.path}/pubspec.lock');
    final plugin = summarizePluginVersion(results);
    formatVersionLines(
      sdk: sdk,
      flutterLints: readLockVersion(baseLock, 'flutter_lints'),
      lints: readLockVersion(baseLock, 'lints'),
      plugin: plugin,
      pluginFailed: results.any((r) => r.pluginFailed),
    ).forEach(stdout.writeln);
    stdout.writeln('');
    for (var i = 0; i < results.length; i++) {
      stdout.writeln(formatStepLine(i + 1, results.length, results[i]));
    }
    for (final result in results.where((r) => r.detailLines.isNotEmpty)) {
      stdout.writeln('');
      result.detailLines.forEach(stdout.writeln);
    }

    // `--update` 의 쓰기는 바뀌는 줄을 화면에 내보낸 뒤에 한다 (D-14).
    // 다른 단계가 실패한 실행의 결과는 정답지로 쓰지 않는다 — 망가진 실행이 정답으로 굳는다.
    await stdout.flush();
    final failed = results.where((r) => !r.passed).toList();
    final updaters = results.where((r) => r.applyUpdate != null).toList();
    if (update) {
      stdout.writeln('');
      if (updaters.isEmpty) {
        stdout.writeln('바뀐 정답지가 없다 — 쓰지 않았다');
      } else if (failed.isNotEmpty) {
        stdout.writeln('다른 단계가 실패해 정답지를 쓰지 않았다 — 실패를 먼저 고친 뒤 다시 실행하세요.');
      } else {
        for (final result in updaters) {
          result.applyUpdate!();
        }
        stdout.writeln('정답지를 썼다 (${updaters.length}개):');
        for (final result in updaters) {
          stdout.writeln('  ${result.updateTarget}');
        }
      }
    }

    stdout.writeln('');
    if (failed.isEmpty) {
      stdout.writeln('점검 통과 (${results.length}개 중 ${results.length}개)');
    } else {
      stdout.writeln('점검 실패 (${results.length}개 중 ${failed.length}개)');
      exitCode = 1;
    }
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    exitCode = 70;
  } on FileSystemException catch (e) {
    stderr.writeln(
      '파일 작업 실패: ${e.message} (${relativize(e.path ?? '', repoRoot)})',
    );
    exitCode = 70;
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: $e');
    exitCode = 70;
  }
}
