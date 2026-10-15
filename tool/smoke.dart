// woody_lints 릴리스 smoke test — "이 패키지를 처음 받는 사람" 을 흉내 내어, 빈 Flutter 프로젝트가
// GitHub 에서 <ref> 를 받아 두 주소로 분석했을 때 이 패키지의 규칙과 plugin 진단이 실제로 나오는지 본다.
//
// 실행: fvm dart run tool/smoke.dart <ref> [--keep]
//   <ref>   커밋 번호 · 브랜치 · tag (예행에서는 릴리스 커밋, tag 를 단 뒤에는 vX.Y.Z)
//   --keep  끝에 임시 폴더를 지우지 않는다 (그때만 마지막 줄에 그 경로를 찍는다)
//
// 하는 일 (06-CONTEXT.md D-07 · D-08 · D-10):
//   1. 저장소 루트에서 git rev-parse '<ref>^{commit}' 으로 기대 커밋을 정한다 — tag 는 커밋으로 벗긴다.
//      느린 단계 전에 하는 것은 잘못된 인자를 먼저 거르려는 것이다.
//   2. 저장소 밖 임시 폴더에 `flutter create` 로 빈 프로젝트를 만들고, README 「설치」 블록 그대로
//      git 의존성(url · ref)과 flutter_riverpod 를 pubspec.yaml 에 넣고, 옵션 파일의 include: 줄만 바꾼다.
//   3. 새 pub cache(PUB_CACHE 를 임시 폴더 아래로)로 `flutter pub get` — 평소 pub cache 의 옛 사본을
//      쓰지 않고 GitHub 에서 받는다.
//   4. 두 주소(package:woody_lints/recommended.yaml · 옛 주소 package:woody_lints/analysis_options.yaml)로
//      각각 새 analyzer 상태 폴더에서 `dart analyze --format=json` 을 돌린다 — 평소 상태 폴더에 준비된
//      plugin 을 쓰지 않고, 주소마다 따로 둔다 (합치면 plugin 폴더가 둘이 되어 버전을 못 읽는다, spike 014).
//
// 판정 (06-CONTEXT.md D-09 (2) · (3) — (1) 은 사람이 따라 하는 확인이다):
//   (2) 일부러 넣은 위반 둘 — prefer_single_quotes (info, 이 패키지가 더하는 규칙) 와
//       provider_parameters (warning, riverpod_lint) — 이 두 주소 각각의 결과에 둘 다 있다.
//       기반 세트의 규칙은 쓰지 않는다: 템플릿이 이미 flutter_lints 를 include 하므로 include 가
//       통째로 깨져도 그 줄은 나온다 (06-RESEARCH.md Pitfall 5).
//   (3) 받은 프로젝트의 pubspec.lock 에서 woody_lints 항목이 source git, url 이 README 와 같고,
//       resolved-ref 가 기대 커밋과 같다.
//
// 저장소의 파일은 읽기만 한다 — 저장소 안에는 아무것도 만들지 않고 GitHub 에는 아무것도 올리지 않는다
// (받기만 한다). 화면에는 임시 폴더 경로를 찍지 않는다 (하위 명령의 출력은 `<임시 폴더>` 로 가린다).
//
// 하위 명령의 SDK: 임시 프로젝트는 저장소 밖이라 .fvmrc 가 없다 — 그곳에서 fvm 이나 PATH 의
// flutter · dart 를 부르면 전역 SDK 로 풀린다. 그래서 이 스크립트를 띄운 SDK(.fvmrc 와 같은지 먼저
// 확인한다)만 쓴다 — `flutter create` · `flutter pub get` 은 그 SDK 의 bin/flutter, `dart analyze` 는
// 실행 중인 dart 다. PATH 의 이름으로 부르는 것은 저장소에서 돌리는 git 하나뿐이다.
//
// 종료 코드: 0 통과 / 1 판정 실패 / 64 사용법 오류 / 69 하위 명령 실패 (git rev-parse · flutter create ·
//            flutter pub get) / 70 예외로 끝남 / 78 실행 중인 SDK 가 .fvmrc 와 다름
//
// 의존성은 dart:io · dart:convert 뿐이다 (루트 pubspec.yaml 은 그대로). tool/verify.dart 를 import 하지
// 않는다 — main 이 둘인 파일이 묶이므로 쓰는 도우미(Flutter root 찾기 · lock 항목 읽기 · 진단 정규화 ·
// plugin 머리말 검사)는 같은 꼴로 옮겨 왔다. 네트워크가 필요하다 (GitHub · pub.dev, 약 1분).
import 'dart:convert';
import 'dart:io';

/// 받을 저장소 — README 「설치」 블록의 `url` 글자 그대로 (인증 없이 받는 공개 저장소).
const repoUrl = 'https://github.com/woodkill/woody_lints.git';

/// 빈 프로젝트의 이름 (`flutter create --project-name`).
const smokeAppName = 'smoke_app';

/// 일부러 넣은 위반을 쓰는 파일 — 빈 프로젝트 기준 상대 경로.
const violationsFile = 'lib/smoke_violations.dart';

/// 분석할 주소 둘 (D-08). [name] 은 화면의 머리 줄 · 상태 폴더 이름에 쓴다.
const includeTargets = [
  (name: 'recommended', address: 'package:woody_lints/recommended.yaml'),
  (name: 'alias', address: 'package:woody_lints/analysis_options.yaml'),
];

/// 이 패키지가 더하는 규칙 — include 가 풀려야만 나온다 (기반 세트에 없다).
const expectedBaseRule = 'prefer_single_quotes';

/// riverpod_lint 의 규칙 — plugin 이 떠야만 나온다.
const expectedPluginRule = 'provider_parameters';

/// analyzer plugin 패키지 이름 (상태 폴더의 lock 에서 버전을 읽는다).
const pluginPackage = 'riverpod_lint';

/// 이 스크립트를 띄우는 명령 (안내 문구에 쓴다).
const runCommand = 'fvm dart run tool/smoke.dart';

/// 사용법 줄.
const usage = '사용법: $runCommand <ref> [--keep]';

/// plugin 준비가 실패했을 때 stderr 에 찍히는 머리말 (spike 002).
///
/// 첫 줄이 아닐 수 있으므로 `contains` 로 찾는다 (spike 008).
const pluginFailureHeader =
    'An error occurred while executing an analyzer plugin:';

/// `dart analyze` 가 정상적으로 끝났을 때의 종료 코드 (진단 없음 / warning / error 까지).
const analyzeExitCodes = [0, 2, 3];

/// 빈 프로젝트의 `dependencies:` 에 더하는 줄 — `example/pubspec.yaml` 과 같은 선언.
const riverpodDependency = '  flutter_riverpod: ^3.0.0';

/// 위반 파일의 내용 — example 의 샘플 두 곳을 글자 그대로 옮겼다.
///
/// `example/lib/added_rules.dart` 28 ~ 29행 (`prefer_single_quotes`) 과
/// `example/lib/riverpod_rules.dart` 12 ~ 18행 (`provider_parameters`).
const violationsBody = r'''
// 출처: example/lib/added_rules.dart 의 prefer_single_quotes 와 example/lib/riverpod_rules.dart 의 provider_parameters 를 글자 그대로 옮겼다 (woody_lints 의 tool/smoke.dart).
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `prefer_single_quotes` — 겹따옴표 문자열.
const String doubleQuoted = "b";

/// 인자를 받는 provider.
final familyProvider = Provider.family<int, Object?>((ref, value) => 0);

/// `provider_parameters` (riverpod_lint, warning) — `==` 를 재정의하지 않는 non-const 리터럴을 family 인자로 넘긴다.
final consumerProvider = Provider<int>(
  (ref) => ref.watch(familyProvider([42])),
);
''';

/// 실행 중인 SDK — 버전과 Flutter root.
class SdkInfo {
  /// [flutter] 는 `frameworkVersion`, [dart] 는 `dartSdkVersion`, [root] 는 Flutter SDK 의 root 다.
  SdkInfo({required this.flutter, required this.dart, required this.root});

  /// Flutter 버전 (예: `3.47.5`).
  final String flutter;

  /// Dart 버전 (예: `3.13.4`).
  final String dart;

  /// Flutter SDK 의 root (그 아래 `bin/flutter` 를 하위 명령으로 쓴다).
  final String root;

  /// 하위 명령으로 쓰는 flutter 실행 파일.
  String get flutterExecutable => '$root/bin/flutter';
}

/// 주소 하나를 분석한 결과.
class AnalyzeOutcome {
  /// 한 번의 `dart analyze` 실행 결과를 담는다.
  AnalyzeOutcome({
    required this.name,
    required this.address,
    required this.exitCode,
    required this.lines,
    required this.stderrText,
    required this.elapsed,
    required this.pluginFolderCount,
    required this.pluginVersion,
  });

  /// 주소의 이름 (`recommended` · `alias`).
  final String name;

  /// include 한 주소.
  final String address;

  /// `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 정규화한 진단 줄 (`상대경로:줄  강도  규칙이름`). JSON 을 읽지 못했으면 null.
  final List<String>? lines;

  /// 가린 stderr.
  final String stderrText;

  /// 걸린 시간.
  final Duration elapsed;

  /// 상태 폴더의 `.plugin_manager` 아래 폴더 수.
  final int pluginFolderCount;

  /// 그 폴더가 하나일 때 읽은 riverpod_lint 버전. 못 읽으면 null.
  final String? pluginVersion;

  /// stderr 에 plugin 준비 실패의 머리말이 있는지.
  bool get hasPluginHeader => stderrText.contains(pluginFailureHeader);
}

/// stdout 과 stderr 를 비운 뒤 [code] 로 끝낸다.
Future<Never> quit(int code) async {
  await stdout.flush();
  await stderr.flush();
  exit(code);
}

/// [flutterRoot] 아래의 `bin/cache/flutter.version.json` 을 읽는다. 없으면 null.
Map<String, dynamic>? readVersionFile(String flutterRoot) {
  final file = File('$flutterRoot/bin/cache/flutter.version.json');
  if (!file.existsSync()) return null;
  final decoded = jsonDecode(file.readAsStringSync());
  return decoded is Map<String, dynamic> ? decoded : null;
}

/// 실행 중인 dart 가 속한 Flutter SDK 의 root 와 버전 파일 내용을 찾는다 (tool/verify.dart 의 readFlutterVersion 과 같은 순서).
///
/// 1순위는 실행 파일에서 다섯 단계 위다 (`<root>/bin/cache/dart-sdk/bin/dart` → `<root>`).
/// 2순위는 환경변수 `FLUTTER_ROOT` 이고, 그 SDK 의 `dartSdkVersion` 이 실행 중인 Dart 와 같을 때만
/// 받아들인다 (다른 SDK 를 가리키는 환경변수로 확인을 통과하지 않게). 못 찾으면 null.
({String root, Map<String, dynamic> version})? flutterRootOf() {
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 4; i++) {
    dir = dir.parent;
  }
  final nearby = readVersionFile(dir.path);
  if (nearby != null) return (root: dir.path, version: nearby);

  final envRoot = Platform.environment['FLUTTER_ROOT'];
  if (envRoot == null || envRoot.isEmpty) return null;
  final fallback = readVersionFile(envRoot);
  final runningDart = Platform.version.split(' ').first;
  if (fallback == null || fallback['dartSdkVersion'] != runningDart) {
    return null;
  }
  return (root: envRoot, version: fallback);
}

/// 실행 중인 SDK 가 `.fvmrc` 와 같은지 확인하고 그 정보를 돌려준다.
///
/// Flutter SDK 의 dart 가 아니거나 버전이 다르면 올바른 명령을 안내하고 exit 78 로 끝낸다
/// (임시 폴더를 만들기 전이다). `.fvmrc` 의 모양이 틀리면 [FormatException] 이다.
Future<SdkInfo> ensurePinnedSdk(String repoRoot) async {
  final found = flutterRootOf();
  final running = found?.version['frameworkVersion'];
  if (found == null || running is! String) {
    stderr.writeln('Flutter SDK 의 dart 가 아니다.');
    stderr.writeln('저장소 루트에서 `$runCommand <ref>` 로 실행하세요.');
    await quit(78);
  }
  final pinned = jsonDecode(File('$repoRoot/.fvmrc').readAsStringSync());
  final expected = pinned is Map<String, dynamic> ? pinned['flutter'] : null;
  if (expected is! String) {
    throw const FormatException('`.fvmrc` 에 `flutter` 값이 없다');
  }
  if (running != expected) {
    stderr.writeln('실행 중인 SDK 는 Flutter $running 인데 .fvmrc 는 $expected 다.');
    stderr.writeln('저장소 루트에서 `$runCommand <ref>` 로 실행하세요.');
    await quit(78);
  }
  final dart = found.version['dartSdkVersion'];
  return SdkInfo(
    flutter: running,
    dart: dart is String ? dart : Platform.version.split(' ').first,
    root: found.root,
  );
}

/// 다른 도구가 낸 [text] 안의 경로를 이름으로 가린다 (화면에 절대 경로를 남기지 않는다).
///
/// [names] 는 경로 → 바꿀 이름이다. 각 경로는 준 글자와 링크를 푼 글자를 둘 다 가리고, 긴 경로부터
/// 바꾼다 — 링크를 푼 경로가 준 경로를 품는 경우(앞에 폴더가 하나 더 붙는다) 짧은 쪽을 먼저 바꾸면
/// 앞부분이 남는다.
String scrub(String text, Map<String, String> names) {
  final pairs = <(String, String)>[];
  for (final MapEntry(key: path, value: name) in names.entries) {
    if (path.isEmpty) continue;
    pairs.add((path, name));
    try {
      final resolved = Directory(path).resolveSymbolicLinksSync();
      if (resolved != path) pairs.add((resolved, name));
    } on FileSystemException {
      // 이미 지웠거나 없는 경로 — 준 글자만 가린다.
    }
  }
  pairs.sort((a, b) => b.$1.length.compareTo(a.$1.length));
  var scrubbed = text;
  for (final (path, name) in pairs) {
    scrubbed = scrubbed.replaceAll(path, name);
  }
  return scrubbed;
}

/// [executable] 을 [args] 로 돌리고 결과와 걸린 시간을 돌려준다.
///
/// [environment] 는 물려받은 환경 위에 더한다.
Future<(ProcessResult, Duration)> runProcess(
  String executable,
  List<String> args, {
  String? workingDirectory,
  Map<String, String>? environment,
}) async {
  final watch = Stopwatch()..start();
  final result = await Process.run(
    executable,
    args,
    workingDirectory: workingDirectory,
    environment: environment,
  );
  watch.stop();
  return (result, watch.elapsed);
}

/// [elapsed] 를 `N.Ns` 꼴로.
String formatSeconds(Duration elapsed) =>
    '${(elapsed.inMilliseconds / 1000).toStringAsFixed(1)}s';

/// [lines] 에서 최상위 키 [block] 의 블록 안에 있는, [anchor] 로 시작하는 첫 줄의 번호. 없으면 -1.
int findInBlock(List<String> lines, String block, String anchor) {
  final start = lines.indexOf(block);
  if (start < 0) return -1;
  for (var i = start + 1; i < lines.length; i++) {
    final line = lines[i];
    // 들여쓰기 없이 시작하는 다른 키가 나오면 블록이 끝난 것이다 (주석 · 빈 줄은 블록 안으로 친다).
    if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#')) {
      return -1;
    }
    if (line.startsWith(anchor)) return i;
  }
  return -1;
}

/// 빈 프로젝트의 `pubspec.yaml` 에 README 「설치」 블록과 flutter_riverpod 를 넣는다.
///
/// `dependencies:` 의 `cupertino_icons` 뒤에 flutter_riverpod 를, `dev_dependencies:` 의
/// `flutter_lints` 뒤에 README 13 ~ 19행의 블록(url 은 [repoUrl], ref 는 [ref])을 넣는다 — 알파벳순
/// 자리라 sort_pub_dependencies 가 나지 않는다. 앵커 줄이 없으면 [FormatException] 이다 (템플릿이 바뀌었다).
void editPubspec(String appDir, String ref) {
  final file = File('$appDir/pubspec.yaml');
  final lines = file.readAsLinesSync();
  final cupertino = findInBlock(lines, 'dependencies:', '  cupertino_icons:');
  if (cupertino < 0) {
    throw const FormatException(
      '$smokeAppName 의 pubspec.yaml 에서 `  cupertino_icons:` 줄을 찾지 못했다 — flutter create 템플릿이 바뀌었다',
    );
  }
  lines.insert(cupertino + 1, riverpodDependency);
  final lints = findInBlock(lines, 'dev_dependencies:', '  flutter_lints:');
  if (lints < 0) {
    throw const FormatException(
      '$smokeAppName 의 pubspec.yaml 에서 `  flutter_lints:` 줄을 찾지 못했다 — flutter create 템플릿이 바뀌었다',
    );
  }
  lines.insertAll(lints + 1, [
    '  woody_lints:',
    '    git:',
    '      url: $repoUrl',
    '      ref: $ref',
  ]);
  file.writeAsStringSync('${lines.join('\n')}\n');
}

/// 빈 프로젝트의 `analysis_options.yaml` 에서 `include:` 로 시작하는 첫 줄만 `include: [address]` 로 바꾼다.
///
/// 나머지(`analyzer: exclude:` · 빈 `linter: rules:`)는 그대로 둔다 — README 의 "기존 include 줄은
/// 바꾸고 같은 키는 합친다" (D-14) 그대로. `include:` 줄이 없으면 [FormatException] 이다.
void setInclude(String appDir, String address) {
  final file = File('$appDir/analysis_options.yaml');
  final lines = file.readAsLinesSync();
  final index = lines.indexWhere((l) => l.startsWith('include:'));
  if (index < 0) {
    throw const FormatException(
      '$smokeAppName 의 analysis_options.yaml 에 `include:` 줄이 없다 — flutter create 템플릿이 바뀌었다',
    );
  }
  lines[index] = 'include: $address';
  file.writeAsStringSync('${lines.join('\n')}\n');
}

/// 빈 프로젝트에 위반 파일 [violationsFile] 을 쓴다.
void writeViolations(String appDir) {
  final file = File('$appDir/$violationsFile');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(violationsBody);
}

/// `pubspec.lock` 의 `woody_lints` 항목 (키 → 값). 파일이나 항목이 없으면 빈 map.
///
/// spike 015 probe.dart 의 `Consumer.lockEntry` 와 같은 꼴 — `  woody_lints:` 아래 네 칸 들여 쓴 줄의
/// `키: 값` (따옴표는 벗긴다).
Map<String, String> lockEntry(String lockPath) {
  final file = File(lockPath);
  final out = <String, String>{};
  if (!file.existsSync()) return out;
  final lines = file.readAsLinesSync();
  final start = lines.indexOf('  woody_lints:');
  if (start < 0) return out;
  final pattern = RegExp(r'^\s+([a-z-]+): "?([^"]*)"?$');
  for (final line in lines.skip(start + 1)) {
    if (!line.startsWith('    ')) break;
    final match = pattern.firstMatch(line);
    if (match != null && match.group(2)!.isNotEmpty) {
      out[match.group(1)!] = match.group(2)!;
    }
  }
  return out;
}

/// stdout 의 JSON 을 `상대경로:줄  강도  규칙이름` 줄 목록으로 바꾼다 (tool/verify.dart 와 같은 꼴).
///
/// JSON 을 읽지 못하면 null 을 돌려준다 (진단 0건인 `[]` 과 구별한다). [bases] 중 하나로 시작하는
/// 경로는 그 뒤만 남긴다 — 링크를 거친 폴더는 준 경로와 링크를 푼 경로가 다 올 수 있다.
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

/// 상태 폴더 [stateDir] 의 `.plugin_manager` 아래 폴더들 (Analysis Server 가 plugin 을 받아 둔 곳).
List<Directory> pluginFolders(String stateDir) {
  final manager = Directory('$stateDir/.plugin_manager');
  if (!manager.existsSync()) return const [];
  return manager.listSync().whereType<Directory>().toList();
}

/// 상태 폴더 [stateDir] 에서 실제로 풀린 riverpod_lint 버전을 읽는다. plugin 폴더가 정확히 하나가 아니면 null.
String? readPluginVersion(String stateDir) {
  final folders = pluginFolders(stateDir);
  if (folders.length != 1) return null;
  final lock = File('${folders.single.path}/pubspec.lock');
  if (!lock.existsSync()) return null;
  final lines = lock.readAsLinesSync();
  final start = lines.indexOf('  $pluginPackage:');
  if (start < 0) return null;
  for (final line in lines.skip(start + 1)) {
    if (!line.startsWith('    ')) break;
    final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}

/// 빈 프로젝트 [appDir] 를 [address] 로 include 하게 바꾼 뒤 `dart analyze` 를 한 번 돌린다.
///
/// 경로 인자를 주지 않는다 — 하위 폴더를 인자로 주면 plugin 진단을 잃는다 (spike 001).
/// [stateDir] 는 이 주소만 쓰는 Analysis Server 상태 폴더이고 미리 만들어 둔다.
/// [scrubNames] 는 stderr 를 가릴 때 쓰는 경로 → 이름이다.
Future<AnalyzeOutcome> analyzeOnce({
  required String name,
  required String address,
  required String appDir,
  required String stateDir,
  required String pubCache,
  required Map<String, String> scrubNames,
}) async {
  setInclude(appDir, address);
  final (result, elapsed) = await runProcess(
    Platform.resolvedExecutable,
    ['--suppress-analytics', 'analyze', '--format=json'],
    workingDirectory: appDir,
    environment: {
      'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir,
      'PUB_CACHE': pubCache,
    },
  );
  final lines = normalizeDiagnostics(result.stdout as String, [
    appDir,
    Directory(appDir).resolveSymbolicLinksSync(),
  ]);
  return AnalyzeOutcome(
    name: name,
    address: address,
    exitCode: result.exitCode,
    // 프로젝트 밖 파일의 진단이 섞여도 절대 경로가 화면에 남지 않게 가린다.
    lines: lines?.map((l) => scrub(l, scrubNames)).toList(),
    stderrText: scrub((result.stderr as String).trim(), scrubNames),
    elapsed: elapsed,
    pluginFolderCount: pluginFolders(stateDir).length,
    pluginVersion: readPluginVersion(stateDir),
  );
}

/// 주소 하나의 결과를 판정해 사유 목록을 돌려준다 (D-09 (2)). 비어 있으면 통과다.
///
/// 순서는 tool/verify.dart 의 정답지 비교와 같다 — (a) plugin 준비 실패의 머리말, (b) 도구가 죽음
/// (종료 코드가 0 · 2 · 3 밖이거나 JSON 아님), (c) 위반 두 줄의 존재. 앞이 걸리면 뒤는 보지 않는다.
List<String> judge(AnalyzeOutcome outcome) {
  if (outcome.hasPluginHeader) {
    return ['${outcome.name}: plugin 준비 실패 (stderr 의 머리말)'];
  }
  final lines = outcome.lines;
  if (lines == null || !analyzeExitCodes.contains(outcome.exitCode)) {
    final what = lines == null ? 'JSON 아님' : 'exit ${outcome.exitCode}';
    return ['${outcome.name}: 도구가 죽었다 ($what)'];
  }
  final file = RegExp.escape(violationsFile);
  final reasons = <String>[];
  for (final (rule, severity) in [
    (expectedBaseRule, 'info'),
    (expectedPluginRule, 'warning'),
  ]) {
    final pattern = RegExp('^$file:\\d+  $severity  $rule\$');
    if (!lines.any(pattern.hasMatch)) {
      reasons.add('${outcome.name}: $rule 없음');
    }
  }
  return reasons;
}

/// 하위 명령이 실패했을 때 가린 출력과 함께 안내를 stderr 에 적는다.
void reportFailure(
  String what,
  ProcessResult result,
  Map<String, String> scrubNames,
) {
  stderr.writeln('$what 실패: exit ${result.exitCode}');
  final err = scrub('${result.stderr}'.trimRight(), scrubNames);
  final out = scrub('${result.stdout}'.trimRight(), scrubNames);
  if (err.isNotEmpty) stderr.writeln(err);
  if (out.isNotEmpty) stderr.writeln(out);
}

/// 저장소 루트에서 `git rev-parse --verify --quiet '<ref>^{commit}'` 으로 기대 커밋을 구한다.
///
/// tag 는 가리키는 커밋으로 벗긴다 (pub 도 lock 에 커밋 번호를 적는다 — spike 015). 실패하면 안내를
/// 적고 exit 69 로 끝낸다 (임시 폴더를 만들기 전이다).
Future<String> expectedCommit(String repoRoot, String ref) async {
  final result = await Process.run('git', [
    'rev-parse',
    '--verify',
    '--quiet',
    '$ref^{commit}',
  ], workingDirectory: repoRoot);
  final sha = '${result.stdout}'.trim();
  if (result.exitCode != 0 || sha.isEmpty) {
    stderr.writeln(
      "git rev-parse '$ref^{commit}' 실패: exit ${result.exitCode} — 로컬에 없는 ref 다. "
      '커밋 번호 · 브랜치 · tag 를 확인하거나 `git fetch origin --tags` 뒤 다시 실행',
    );
    await quit(69);
  }
  return sha;
}

/// 인자를 읽어 (ref, keep) 을 돌려준다. 틀리면 사용법을 적고 exit 64 로 끝낸다.
///
/// ref 가 `-` 로 시작하면 거부한다 — git · pub 의 옵션으로 읽히지 않게 (06-RESEARCH.md Security V5).
Future<(String, bool)> parseArgs(List<String> args) async {
  var keep = false;
  final refs = <String>[];
  var bad = false;
  for (final arg in args) {
    if (arg == '--keep') {
      keep = true;
    } else if (arg.startsWith('-') || arg.isEmpty) {
      bad = true;
    } else {
      refs.add(arg);
    }
  }
  if (bad || refs.length != 1) {
    stderr.writeln(usage);
    await quit(64);
  }
  return (refs.single, keep);
}

/// 임시 폴더 [work] 안에서 빈 프로젝트를 만들고 받아 분석한 뒤 판정한다. 종료 코드를 돌려준다.
Future<int> runSmoke({
  required SdkInfo sdk,
  required String repoRoot,
  required String ref,
  required String expected,
  required Directory work,
}) async {
  final appDir = '${work.path}/app';
  final pubCache = '${work.path}/pub-cache';
  final scrubNames = {
    work.path: '<임시 폴더>',
    sdk.root: '<Flutter SDK>',
    repoRoot: '<repo>',
    Platform.environment['HOME'] ?? '': '<홈>',
  };

  // 빈 프로젝트 — 첫 받기는 README 의 `flutter pub get` 한 번으로 두려고 --no-pub.
  final (created, createTime) = await runProcess(
    sdk.flutterExecutable,
    [
      '--suppress-analytics',
      'create',
      '--no-pub',
      '--platforms=android',
      '--project-name',
      smokeAppName,
      appDir,
    ],
    environment: {'PUB_CACHE': pubCache},
  );
  if (created.exitCode != 0) {
    reportFailure('flutter create', created, scrubNames);
    return 69;
  }
  stdout.writeln(
    'flutter create: exit ${created.exitCode}, ${formatSeconds(createTime)}',
  );

  editPubspec(appDir, ref);
  setInclude(appDir, includeTargets.first.address);
  writeViolations(appDir);

  // README 의 명령 그대로. pub cache 는 임시 폴더 아래 — GitHub 에서 처음부터 받는다.
  final (got, getTime) = await runProcess(
    sdk.flutterExecutable,
    ['--suppress-analytics', 'pub', 'get'],
    workingDirectory: appDir,
    environment: {'PUB_CACHE': pubCache},
  );
  if (got.exitCode != 0) {
    reportFailure('flutter pub get', got, scrubNames);
    return 69;
  }
  final lock = lockEntry('$appDir/pubspec.lock');
  final source = lock['source'];
  final url = lock['url'];
  final resolved = lock['resolved-ref'];
  stdout.writeln(
    'flutter pub get: exit ${got.exitCode}, ${formatSeconds(getTime)} — '
    'lock: source ${source ?? '?'}, url ${url ?? '?'}, resolved-ref ${resolved ?? '?'}',
  );

  final reasons = <String>[];
  final outcomes = <AnalyzeOutcome>[];
  for (final target in includeTargets) {
    final stateDir = '${work.path}/state-${target.name}';
    Directory(stateDir).createSync(recursive: true);
    final outcome = await analyzeOnce(
      name: target.name,
      address: target.address,
      appDir: appDir,
      stateDir: stateDir,
      pubCache: pubCache,
      scrubNames: scrubNames,
    );
    outcomes.add(outcome);
    stdout.writeln('');
    stdout.writeln('## ${target.name} — ${target.address}');
    stdout.writeln(
      '   dart analyze exit ${outcome.exitCode}, ${formatSeconds(outcome.elapsed)}, '
      '머리말 ${outcome.hasPluginHeader ? '있음' : '없음'}, '
      'plugin 폴더 ${outcome.pluginFolderCount}, '
      '$pluginPackage ${outcome.pluginVersion ?? '?'}',
    );
    for (final line in outcome.lines ?? const <String>[]) {
      stdout.writeln('   $line');
    }
    if (outcome.hasPluginHeader) {
      stderr.writeln('${target.name}: plugin 준비 실패 — stderr:');
      stderr.writeln(outcome.stderrText);
    }
    final found = judge(outcome);
    reasons.addAll(found);
    if (outcome.hasPluginHeader ||
        outcome.lines == null ||
        !analyzeExitCodes.contains(outcome.exitCode)) {
      stdout.writeln('   판정: ${found.first.substring(target.name.length + 2)}');
    } else {
      String mark(String rule) =>
          '$rule ${found.any((r) => r.endsWith('$rule 없음')) ? '없음' : '있음'}';
      stdout.writeln(
        '   판정: ${mark(expectedBaseRule)} · ${mark(expectedPluginRule)}',
      );
    }
  }

  // (3) — 받은 것이 README 의 주소에서 온 기대 커밋인가.
  if (lock.isEmpty) {
    reasons.add('lock 에 woody_lints 항목이 없다');
  } else {
    if (source != 'git') {
      reasons.add('lock 의 source 가 git 이 아니다: ${source ?? '?'}');
    }
    if (url != repoUrl) {
      reasons.add('lock 의 url 이 README 와 다르다: ${url ?? '?'}');
    }
    if (resolved != expected) {
      reasons.add('resolved-ref ${resolved ?? '?'} 가 기대 커밋 $expected 과 다르다');
    }
  }

  stdout.writeln('');
  if (reasons.isEmpty) {
    final versions = {for (final o in outcomes) o.pluginVersion ?? '?'}
        .join(' / ');
    final counts = outcomes.map((o) => o.lines?.length ?? 0).toList();
    stdout.writeln(
      'smoke 통과 (ref $ref → $expected, recommended ${counts[0]}줄 / '
      '옛 주소 ${counts[1]}줄, $pluginPackage $versions)',
    );
    return 0;
  }
  stdout.writeln('smoke 실패 (ref $ref → $expected):');
  for (final reason in reasons) {
    stdout.writeln('  - $reason');
  }
  return 1;
}

/// 진입점 — 인자 → SDK 확인 → 기대 커밋 → 임시 폴더에서 smoke → 정리 → 종료 코드.
Future<void> main(List<String> args) async {
  final (ref, keep) = await parseArgs(args);
  final repoRoot = File.fromUri(Platform.script).parent.parent.path;
  Directory? work;
  var code = 70;
  try {
    final sdk = await ensurePinnedSdk(repoRoot);
    stdout.writeln('SDK Flutter ${sdk.flutter} / Dart ${sdk.dart}');
    final expected = await expectedCommit(repoRoot, ref);
    stdout.writeln("기대 커밋: $expected (git rev-parse '$ref^{commit}')");
    work = Directory.systemTemp.createTempSync('woody_smoke_');
    code = await runSmoke(
      sdk: sdk,
      repoRoot: repoRoot,
      ref: ref,
      expected: expected,
      work: work,
    );
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    code = 70;
  } on FileSystemException catch (e) {
    final names = {if (work != null) work.path: '<임시 폴더>', repoRoot: '<repo>'};
    stderr.writeln('파일 작업 실패: ${e.message} (${scrub(e.path ?? '', names)})');
    code = 70;
  } on ProcessException catch (e) {
    final names = {if (work != null) work.path: '<임시 폴더>', repoRoot: '<repo>'};
    stderr.writeln('프로세스를 띄우지 못했다: ${scrub('$e', names)}');
    code = 70;
  }
  if (work != null) {
    if (keep) {
      stdout.writeln('임시 폴더를 남겼다: ${work.path}');
    } else {
      try {
        work.deleteSync(recursive: true);
        stdout.writeln('임시 폴더를 지웠다');
      } on FileSystemException catch (e) {
        stderr.writeln('임시 폴더를 지우지 못했다: ${e.message}');
      }
    }
  }
  await quit(code);
}
