// woody_lints 검증 명령 — 배포 설정이 기대한 대로 적용되는지를 단계 N 개로 확인한다
// (N = 3 + 연습용 프로젝트 수. 연습용 프로젝트는 아래 `fixtures` 표가 정한다).
//
//   [1/N] lib/ 에 .dart 파일이 없는지
//   [2/N] 조각 파일 셋(lib/base.yaml · codegen.yaml · riverpod.yaml)의 복사본을 분석해 진단이 하나도 없는지 (deprecated / removed / 없는 규칙, 겹친 규칙 · 모르는 키 같은 옵션 경고, 깨진 YAML)
//   [3/N] 연습용 프로젝트 전부의 analysis_options.yaml 이 정해진 내용인지 (주석 · 빈 줄을 뺀 내용을 통째로 견준다)
//   [4/N] ~ [N/N] 연습용 프로젝트마다 `dart analyze` 로 분석한 결과가 정답지와 같은지
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
import 'dart:convert';
import 'dart:io';

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
/// `[3/N]` 이 `lib/riverpod.yaml` 에서 읽은 값([readShippedPluginConstraint])으로 바꿔 견준다.
/// 끄는 설정용 프로젝트는 `plugins:` 에 `version` 을 다시 적어야 끄기가 듣는데, 그 값이 그
/// 프로젝트의 plugin 선언을 통째로 대신한다 (spike 012) — 조각과 어긋나면 그 프로젝트만 다른
/// 버전 범위를 받게 되므로 같아야 한다.
const pluginConstraintToken = '{riverpod_lint}';

/// [3/N] 단계의 화면 이름.
const fixtureOptionsLabel = '연습용 프로젝트 옵션 파일';

/// 규칙 검사의 대상 — 규칙이 적힐 수 있는 조각 셋 (저장소 루트 기준). 읽기만 한다.
///
/// 묶음(`lib/recommended.yaml`)과 별칭(`lib/analysis_options.yaml`)은 넣지 않는다 —
/// 폴더를 인자로 준 분석에서는 include 를 거쳐 plugin 까지 준비한다 (spike 013).
/// 새 조각이 생기면 [expectedLibYamls] 와 함께 고친다.
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
/// 조각 셋 + 묶음 + 별칭이다. 새 조각이 생기면 이 집합과 [ruleCheckTargets] 를 함께 고친다 —
/// 규칙 검사 대상에서 빠진 조각에 숨은 문제 규칙은 어느 단계도 잡지 못한다 (spike 013).
const expectedLibYamls = {
  'analysis_options.yaml',
  'base.yaml',
  'codegen.yaml',
  'recommended.yaml',
  'riverpod.yaml',
};

/// [2/4] 단계의 화면 이름.
const ruleCheckLabel = '배포 파일의 규칙 이름';

/// [2/4] 실패 문구의 마지막 안내 — 진단 줄에서 고칠 파일과 줄을 찾는 법.
const fragmentLineHint =
    '진단 줄의 폴더 이름이 조각 이름이다 — `lib/<이름>.yaml` 에서 그 줄을 고친다. '
    '복사본의 줄 번호는 원본과 같다 (`riverpod.yaml` 은 `plugins:` 섹션을 빼고 복사하므로 '
    '그 섹션 뒤에 적은 줄만 뺀 줄 수만큼 앞당겨진다).';

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
/// [path] 하나가 pub get 대상, `[3/N]` 의 옵션 파일, 정답지 자리, 상태 폴더를 정한다.
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

  /// `[3/N]` 이 견주는, 주석 · 빈 줄을 뺀 옵션 파일의 줄 — 앞뒤 공백을 `trim()` 해 견준다.
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

/// [1/4] `lib/` 아래에 `.dart` 파일이 없는지 본다 (VERIFY-07).
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

/// 옵션 파일 내용에서 최상위 `plugins:` 섹션이 있으면 뺀다 (spike 007, 013).
///
/// `plugins:` 줄과 그 바로 아래에 이어지는 들여쓴 줄만 지운다. 없으면 그대로 돌려준다 —
/// 조각 셋 가운데 `plugins:` 가 있는 것은 `riverpod.yaml` 뿐이다.
///
/// 뺀 뒤에도 `plugins:` 줄이 남아 있으면 패턴이 섹션을 놓친 것이라 [FormatException] 을
/// 던진다 ([shownAs] 는 문구에 쓸 원본 경로). `plugins:` 를 담은 채 분석하면 plugin 을
/// 준비한다 (10초 + 네트워크) — 조용히 넘기지 않는다.
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

/// `lib/` 의 YAML 이 정확히 [expectedLibYamls] 인지 본다 ([2/4] 의 첫 확인).
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
/// 블록은 `linter:` 로 시작하는 줄부터 그 다음의 들여쓰기 없는 줄 앞까지다. 그 안에서
/// `- 규칙이름` 꼴 줄만 센다 — 주석 처리된 줄(`# - …`)과 블록 밖의 목록 항목
/// (`analyzer.exclude` 의 glob)은 세지 않는다. 블록이 없으면 0 이다.
int countDeclaredRules(String options) {
  final rulePattern = RegExp(r'^\s*-\s*[A-Za-z0-9_]+');
  var inLinter = false;
  var count = 0;
  for (final line in options.split('\n')) {
    if (RegExp(r'^linter:').hasMatch(line)) {
      inLinter = true;
    } else if (RegExp(r'^\S').hasMatch(line)) {
      // 들여쓰기 없는 줄(다른 최상위 키나 주석)이 블록을 닫는다.
      inLinter = false;
    } else if (inLinter && rulePattern.hasMatch(line)) {
      count++;
    }
  }
  return count;
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

/// [2/4] 조각 셋([ruleCheckTargets])의 복사본을 분석해 진단이 하나도 없는지 본다 (VERIFY-02).
///
/// 첫 확인은 `lib/` 의 YAML 집합이다 ([checkLibYamlSet]) — 대상에서 빠진 새 조각이 있으면
/// 복사본을 만들기 전에 실패한다.
///
/// [rulesFile] 에서 규칙을 하나도 읽지 못하면([countDeclaredRules] 가 0) 실패다 — 검사가
/// 본 것이 없는데 "문제 없음" 으로 넘기지 않는다.
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
    if (countDeclaredRules(rulesCopy) == 0) {
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
      final copyLines = {
        for (final MapEntry(key: name, value: content) in copies.entries)
          name: content.split('\n'),
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

/// [3/N] 연습용 프로젝트 전부([fixtures])의 옵션 파일이 정해진 내용인지 한 단계로 본다.
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
    final rest = file.existsSync()
        ? file
              .readAsLinesSync()
              .map((l) => l.trimRight())
              .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'))
              .toList()
        : null;
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

/// `lib/riverpod.yaml` 의 `riverpod_lint:` 선언(예: `^3.1.3`)을 읽는다.
///
/// 들여쓴 `riverpod_lint: <값>` 줄의 첫 값이다. 없으면 [FormatException] — 조각의 모양이
/// 바뀐 것이라 `[3/N]` 이 견줄 기준이 없다 (main 이 종료 코드 70 으로 끝낸다).
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

/// 두 줄 목록이 순서와 내용까지 같은지 본다.
bool sameLines(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// [4/N] ~ [N/N] 연습용 프로젝트 하나([fixture])를 분석해 정답지와 견준다 (VERIFY-01).
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
