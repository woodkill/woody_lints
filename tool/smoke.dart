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
//   (2′) 어느 주소든 `analysis_options.yaml` 에 include 사슬이 끊긴 진단(`include_file_not_found` ·
//       `included_file_warning` · `included_file_parse_error`)이 있으면 실패 — 위반 두 줄이 그대로
//       나와도 (06-REVIEW.md WR-01 · WR-04, 소유자 결정 G6-Q2 · G7-Q2).
//   (2″) 어느 주소든 `dart analyze` 의 종료 코드가 3 (error 있음) 인데 JSON 진단에 `error` 줄이 하나도
//       없으면 실패 — 옵션 파일 쪽 error 는 JSON 에 오지 않고 종료 코드만 3 이다 (2026-10-16 실측,
//       Dart 3.13.4; 06-REVIEW.md WR-04, 소유자 결정 G7-Q2).
//   (3) 받은 프로젝트의 pubspec.lock 에서 woody_lints 항목이 source git, url 이 README 와 같고,
//       resolved-ref 가 기대 커밋과 같다.
//
// 저장소의 파일은 읽기만 한다 — 저장소 안에는 아무것도 만들지 않고 GitHub 에는 아무것도 올리지 않는다
// (받기만 한다). 화면에는 임시 폴더 경로를 찍지 않는다 (하위 명령의 출력은 `<임시 폴더>` 로 가린다).
// 어떻게 끝나도(예외 · 시간 초과 · Ctrl-C) 임시 폴더는 지운다 — `--keep` 때만 남기고 그때만 경로를 찍는다.
//
// 하위 명령의 SDK: 임시 프로젝트는 저장소 밖이라 .fvmrc 가 없다 — 그곳에서 fvm 이나 PATH 의
// flutter · dart 를 부르면 전역 SDK 로 풀린다. 그래서 이 스크립트를 띄운 SDK(.fvmrc 와 같은지 먼저
// 확인한다)만 쓴다 — `flutter create` · `flutter pub get` 은 그 SDK 의 bin/flutter, `dart analyze` 는
// 실행 중인 dart 다. PATH 의 이름으로 부르는 것은 저장소에서 돌리는 git 하나뿐이다 (하위 명령을 끊을 때
// 자손 프로세스를 찾는 ps 는 절대 경로 /bin/ps 로 부른다).
//
// 종료 코드: 0 통과 / 1 판정 실패 / 64 사용법 오류
//            / 69 하위 명령 실패 (git rev-parse · flutter create · flutter pub get) 또는 단계의 시간 제한
//                 초과 (create 2분 · pub get 5분 · dart analyze 주소마다 5분 — 넘으면 그 프로세스를 끊고
//                 임시 폴더를 지운다; 06-REVIEW.md WR-03, 소유자 결정 G6-Q2). 제한은 종료 코드와
//                 출력 수집 전체에 걸린다 (06-REVIEW.md WR-06)
//            / 70 예외로 끝남 / 78 실행 중인 SDK 가 .fvmrc 와 다름
//            / 130 Ctrl-C (SIGINT) — 도는 하위 명령을 끊고 임시 폴더를 지운 뒤 끝낸다 (06-REVIEW.md IN-01)
//            / 255 세 예외 밖의 처리되지 않은 예외 (동기 흐름) — 임시 폴더는 finally 가 지운다; 하위 명령
//                  출력의 UTF-8 아닌 바이트는 U+FFFD 로 받아 이 경로로 가지 않는다 (06-REVIEW.md IN-04)
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

/// include 사슬이 끊겼을 때 `analysis_options.yaml` 에 나는 진단의 코드 셋.
///
/// 06-REVIEW.md WR-01 — 복제본에서 `lib/recommended.yaml` 의 include 하나를 없는 파일로 바꿔 확인한
/// 코드다. 템플릿이 내는 다른 진단(예: 규칙 이름의 오타)과 섞이지 않게 좁힌다. 셋째는 include 받는
/// 파일이 YAML 로 읽히지 않을 때의 코드 — 사람용 출력에만 나오고 `--format=json` 의 `diagnostics` 에는
/// 오지 않는다 (2026-10-16 실측, Dart 3.13.4; 06-REVIEW.md WR-04) — 그래서 (c″) 가 종료 코드로 잡는다.
const includeErrorCodes = {
  'include_file_not_found',
  'included_file_warning',
  'included_file_parse_error',
};

/// `flutter create` 의 시간 제한.
///
/// 단계별 제한 셋의 근거: 정상은 create 수 초 · pub get 약 10초 · analyze 주소마다 약 15 ~ 20초다
/// (06-03 · 06-04 실측). 06-04 예행 1회차는 `pub get` 70분 · plugin 받기 41분 동안 멈춰 사람이 끊었다.
/// 값은 06-REVIEW.md WR-03 의 제안 값이다 (소유자 결정 G6-Q2 — 값은 planner 재량, Round 2 에서 보임).
const createTimeout = Duration(minutes: 2);

/// `flutter pub get` 의 시간 제한 — GitHub · pub.dev 에 닿지 못하면 여기서 멈춘다 ([createTimeout] 의 근거).
const pubGetTimeout = Duration(minutes: 5);

/// 주소마다의 `dart analyze` 시간 제한 — plugin 준비가 pub.dev 에 닿지 못하면 여기서 멈춘다 ([createTimeout] 의 근거).
const analyzeTimeout = Duration(minutes: 5);

/// SIGINT 처리기가 끊을, 지금 도는 하위 명령 ([runProcess] 가 띄운 동안만 값이 있다).
Process? runningChild;

/// SIGINT 처리기가 끝내는 중인지 — 그 뒤로 본 흐름은 [haltIfInterrupted] 에서 멈춘다.
var interrupted = false;

/// [quit] 가 이미 끝내는 중인지 — 처리기와 본 흐름이 둘 다 부르면 먼저 부른 쪽의 종료 코드로 끝낸다.
var quitting = false;

/// 빈 프로젝트의 `dependencies:` 에 더하는 줄 — `example/pubspec.yaml` 과 같은 선언.
const riverpodDependency = '  flutter_riverpod: ^3.0.0';

/// 위반 파일의 첫 줄 — 출처 주석.
const violationsHeader =
    '// 출처: example/lib/added_rules.dart 의 prefer_single_quotes 와 '
    'example/lib/riverpod_rules.dart 의 provider_parameters 를 글자 그대로 옮겼다 '
    '(woody_lints 의 tool/smoke.dart).';

/// 위반 파일의 import 줄 (`example/lib/riverpod_rules.dart` 1행).
///
/// 아래 본문 안에 두지 않는 것은 줄 머리의 `import` 가 이 스크립트 자신의 import 로 읽히지 않게
/// 하려는 것이다 (import 를 줄 단위로 세는 검사가 있다).
const violationsImport =
    "import 'package:flutter_riverpod/flutter_riverpod.dart';";

/// 위반 파일의 본문 — example 의 샘플 두 곳을 글자 그대로 옮겼다.
///
/// `example/lib/added_rules.dart` 28 ~ 29행 (`prefer_single_quotes`) 과
/// `example/lib/riverpod_rules.dart` 12 ~ 18행 (`provider_parameters`).
/// [writeViolations] 가 [violationsHeader] · [violationsImport] 뒤에 붙인다.
const violationsBody = r'''

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
///
/// 두 번째 호출은 끝나지 않는 future 에서 멈춘다 — 비우는 중의 stdout 에 다른 쪽이 쓰거나 다시 비우면
/// `StateError` 가 나고, 늦게 부른 쪽의 종료 코드가 먼저 부른 쪽을 덮지 않게 한다.
Future<Never> quit(int code) async {
  if (quitting) await Future.any(const <Future<Never>>[]);
  quitting = true;
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

/// SIGINT 처리기가 끝내는 중이면 끝나지 않는 future 에서 멈춘다.
///
/// 처리기가 하위 명령을 끊으면 그 명령을 기다리던 본 흐름이 깨어난다 — 지운 임시 폴더 위에서 다음
/// 단계로 가거나 처리기가 비우는 중의 stdout 에 쓰지 않게, 본 흐름의 await 뒤마다 부른다.
Future<void> haltIfInterrupted() async {
  if (interrupted) await Future.any(const <Future<Never>>[]);
}

/// 지금 도는 프로세스의 표 (pid → ppid, `/bin/ps` 에서). 읽지 못하면 null.
Map<int, int>? processTable() {
  final ProcessResult listed;
  try {
    listed = Process.runSync('/bin/ps', ['-A', '-o', 'pid=', '-o', 'ppid=']);
  } on ProcessException {
    return null;
  }
  if (listed.exitCode != 0) return null;
  final table = <int, int>{};
  for (final row in '${listed.stdout}'.split('\n')) {
    final cells = row.trim().split(RegExp(r'\s+'));
    if (cells.length != 2) continue;
    final pid = int.tryParse(cells[0]);
    final parent = int.tryParse(cells[1]);
    if (pid == null || parent == null) continue;
    table[pid] = parent;
  }
  return table;
}

/// [pid] 아래의 모든 자손 프로세스 번호. 표를 읽지 못하면 빈 목록.
List<int> descendantsOf(int pid) {
  final table = processTable();
  if (table == null) return const [];
  final children = <int, List<int>>{};
  for (final MapEntry(key: child, value: parent) in table.entries) {
    children.putIfAbsent(parent, () => []).add(child);
  }
  final found = <int>[];
  final queue = [pid];
  while (queue.isNotEmpty) {
    for (final child in children[queue.removeLast()] ?? const <int>[]) {
      found.add(child);
      queue.add(child);
    }
  }
  return found;
}

/// [process] 와 그 자손을 모두 SIGKILL 로 끊고, 자손이 표에서 사라질 때까지(최대 약 5초) 기다린다.
///
/// `flutter` 는 dart 를 exec 하지만 그 dart 가 다시 자식을 띄운다 — `dart analyze` 는 analysis server
/// (`dartaotruntime`) 를 자식으로 둔다 (2026-10-16 실측). 부모만 끊으면 멈춘 받기가 남는다. 그래서 먼저
/// 얼린다(SIGSTOP): 멈춘 프로세스는 새 자식을 띄우지 못하고 부모와의 연결도 그대로라, 새로 보이는 자손이
/// 없을 때까지 표를 다시 읽어 얼린 뒤 한꺼번에 끊는다. 표를 한 번만 읽고 끊었을 때는 그 사이에 뜬
/// 자식이 남아, 지운 임시 폴더에 `pub-cache/_temp` 를 다시 만들었다 (2026-10-16 SIGINT 실험).
Future<void> killTree(Process process) async {
  process.kill(ProcessSignal.sigstop);
  final frozen = <int>{};
  for (var round = 0; round < 20; round++) {
    final fresh = descendantsOf(process.pid).where((p) => !frozen.contains(p));
    if (fresh.isEmpty) break;
    for (final pid in fresh.toList()) {
      Process.killPid(pid, ProcessSignal.sigstop);
      frozen.add(pid);
    }
  }
  process.kill(ProcessSignal.sigkill);
  for (final pid in frozen) {
    Process.killPid(pid, ProcessSignal.sigkill);
  }
  await process.exitCode;
  for (var i = 0; i < 50; i++) {
    final table = processTable();
    if (table == null || !frozen.any(table.containsKey)) break;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

/// [executable] 을 [args] 로 돌리고 결과 · 걸린 시간 · 시간 초과 여부를 돌려준다.
///
/// [environment] 는 물려받은 환경 위에 더한다. [timeout] 을 넘기면 그 프로세스와 자손을 SIGKILL 로
/// 끊고 `(result: null, elapsed, timedOut: true)` 다 — SIGKILL 은 SIGTERM 을 무시하는 상태(멈춘 받기)에서도
/// 끊는다 (06-REVIEW.md WR-03). `Process.run` 은 제한을 둘 수 없어 `Process.start` 로 띄우고, stdout ·
/// stderr 는 기다리기 전에 함께 모으기 시작한다 — 한쪽 파이프가 차면 하위 명령이 멈춰 교착한다.
///
/// 출력은 `Utf8Decoder(allowMalformed: true)` 로 받는다 — 엄격한 decoder 는 아무도 듣지 않는 future 에서
/// `FormatException` 을 내어 처리되지 않은 비동기 예외(255)가 되고 `main` 의 `finally` 를 건너뛰어, 새
/// pub cache 가 든 임시 폴더가 남았다 (06-VERIFICATION.md 2회차 둘째 gap — 하네스 재현, 06-REVIEW.md
/// IN-04). 출력은 화면 표시와 JSON 판정에만 쓰이므로 깨진 바이트를 U+FFFD 로 바꿔도 뜻이 같다 (소유자
/// 결정 G7-Q2).
///
/// 제한은 종료 코드만이 아니라 출력 수집에도 걸린다 (`Future.wait` 의 셋). 하위 명령이 끝나도 파이프를
/// 물려받은 자손이 살아 있으면 `out` · `err` 가 끝나지 않아 제한 없이 기다렸다 (06-REVIEW.md WR-06 —
/// `sleep 20 & echo hi` 에서 20초). 제한 뒤 늦게 끝나는 원래 future 의 오류는 `timeout` 이 버린다. 이 꼴의
/// 자손(부모가 먼저 끝나 pid 1 로 옮겨 간 것)은 [killTree] 가 끊지 못한다 — 머리 주석의 범위 문장
/// (06-REVIEW.md IN-06 (b)).
Future<({ProcessResult? result, Duration elapsed, bool timedOut})> runProcess(
  String executable,
  List<String> args, {
  String? workingDirectory,
  Map<String, String>? environment,
  required Duration timeout,
}) async {
  final watch = Stopwatch()..start();
  final process = await Process.start(
    executable,
    args,
    workingDirectory: workingDirectory,
    environment: environment,
  );
  runningChild = process;
  if (interrupted) {
    // 띄우는 사이에 SIGINT 가 왔다 — 처리기는 이 프로세스를 보지 못했으므로 여기서 끊는다.
    await killTree(process);
    await haltIfInterrupted();
  }
  try {
    const decoder = Utf8Decoder(allowMalformed: true);
    final out = decoder.bind(process.stdout).join();
    final err = decoder.bind(process.stderr).join();
    final done = await Future.wait<Object>([process.exitCode, out, err])
        .then<List<Object>?>((v) => v)
        .timeout(timeout, onTimeout: () => null);
    if (done == null) {
      await killTree(process);
      watch.stop();
      await haltIfInterrupted();
      return (result: null, elapsed: watch.elapsed, timedOut: true);
    }
    final result = ProcessResult(process.pid, done[0] as int, done[1], done[2]);
    watch.stop();
    await haltIfInterrupted();
    return (result: result, elapsed: watch.elapsed, timedOut: false);
  } finally {
    runningChild = null;
  }
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
  file.writeAsStringSync(
    '$violationsHeader\n$violationsImport\n$violationsBody',
  );
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
///
/// [analyzeTimeout] 을 넘기면 끊고 stderr 에 안내를 적은 뒤 null 을 돌려준다 (부르는 쪽이 69 로 끝낸다).
Future<AnalyzeOutcome?> analyzeOnce({
  required String name,
  required String address,
  required String appDir,
  required String stateDir,
  required String pubCache,
  required Map<String, String> scrubNames,
}) async {
  setInclude(appDir, address);
  final run = await runProcess(
    Platform.resolvedExecutable,
    ['--suppress-analytics', 'analyze', '--format=json'],
    workingDirectory: appDir,
    environment: {
      'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir,
      'PUB_CACHE': pubCache,
    },
    timeout: analyzeTimeout,
  );
  if (run.timedOut) {
    stderr.writeln(
      'dart analyze ($name): 시간 제한 ${analyzeTimeout.inMinutes}분을 넘겨 끊었다 '
      '(plugin 준비가 pub.dev 에 닿지 못하면 여기서 멈춘다)',
    );
    return null;
  }
  final result = run.result!;
  final elapsed = run.elapsed;
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

/// 주소 하나의 결과를 판정해 사유 목록과 화면의 `판정:` 문구를 함께 돌려준다 (D-09 (2)).
///
/// 순서는 tool/verify.dart 의 정답지 비교와 같은 배타 순서에 include 사슬을 더한 것이다 —
/// (a) plugin 준비 실패의 머리말, (b) 도구가 죽음 (종료 코드가 0 · 2 · 3 밖이거나 JSON 아님),
/// (c′) `analysis_options.yaml` 의 [includeErrorCodes] 줄마다 사유 하나, (c″) 종료 코드 3 인데 JSON 에
/// `error` 줄이 하나도 없으면 사유 하나, (c) 위반 두 줄의 존재. (a) · (b) 가 걸리면 뒤는 보지 않는다.
///
/// (c″) 를 보는 까닭: 종료 코드 3 은 error 가 있다는 뜻인데 옵션 파일 쪽 error(include 받는 파일의 깨진
/// YAML — `included_file_parse_error`)는 JSON 에 오지 않는다. 받는 쪽에서 `lib/codegen.yaml` 이 깨지면
/// 생성 파일 제외 · `invalid_annotation_target: ignore` 가 통째로 빠지는데도 통과했다 (06-REVIEW.md
/// WR-04, 소유자 결정 G7-Q2).
///
/// (c′) 를 보는 까닭: 두 주소 모두 `lib/recommended.yaml` 을 거쳐 조각 셋을 받으므로 `codegen.yaml` 이
/// 풀리지 않아도 위반 두 줄은 그대로 나온다 — CLAUDE.md Compatibility 의 codegen 부분이 받는 쪽에서
/// 깨져도 통과하던 자리다 (06-REVIEW.md WR-01, 소유자 결정 G6-Q2). outcome 하나를 보므로 두 주소
/// (`recommended` · `alias`) 각각 같은 길을 지난다.
///
/// 돌려주는 값: `reasons` 는 요약의 사유 목록이고 비어 있으면 통과다. `shown` 은 그 주소의 `판정:`
/// 줄 — (a) · (b) 면 사유에서 주소 이름을 뗀 글자, 아니면 `… 있음 · … 없음` 에 include 사유가 있을 때
/// ` · include 사슬 끊김 N줄` 을, (c″) 면 ` · 종료 코드 3 인데 error 없음` 을 잇는다. 조건과 문구를 여기 한 곳에만 두어 runSmoke 가 다시 적지
/// 않게 한다 (06-REVIEW.md IN-02).
({List<String> reasons, String shown}) judge(AnalyzeOutcome outcome) {
  ({List<String> reasons, String shown}) fatal(String what) =>
      (reasons: ['${outcome.name}: $what'], shown: what);

  if (outcome.hasPluginHeader) {
    return fatal('plugin 준비 실패 (stderr 의 머리말)');
  }
  final lines = outcome.lines;
  if (lines == null || !analyzeExitCodes.contains(outcome.exitCode)) {
    final what = lines == null ? 'JSON 아님' : 'exit ${outcome.exitCode}';
    return fatal('도구가 죽었다 ($what)');
  }

  final reasons = <String>[];
  // (c′) include 사슬 — 첫 칸(`:` 앞의 파일)이 프로젝트의 옵션 파일이고 끝 칸(규칙 이름)이 include 오류.
  var includeBroken = 0;
  for (final line in lines) {
    final file = line.split(':').first;
    final code = line.split('  ').last;
    if (file == 'analysis_options.yaml' && includeErrorCodes.contains(code)) {
      reasons.add('${outcome.name}: include 사슬이 끊겼다 ($line)');
      includeBroken++;
    }
  }

  // (c″) 종료 코드 3 (error 있음) 인데 JSON 에 error 줄이 없다 — 둘째 칸(강도)이 `error` 인 줄을 찾는다.
  bool isErrorLine(String line) {
    final cells = line.split('  ');
    return cells.length >= 2 && cells[1] == 'error';
  }

  var exitWithoutError = false;
  if (outcome.exitCode == 3 && !lines.any(isErrorLine)) {
    reasons.add(
      '${outcome.name}: 종료 코드 3 인데 JSON 에 error 가 없다 (옵션 파일의 error — include 사슬)',
    );
    exitWithoutError = true;
  }

  // (c) 위반 두 줄.
  final file = RegExp.escape(violationsFile);
  final missing = <String>{};
  for (final (rule, severity) in [
    (expectedBaseRule, 'info'),
    (expectedPluginRule, 'warning'),
  ]) {
    final pattern = RegExp('^$file:\\d+  $severity  $rule\$');
    if (!lines.any(pattern.hasMatch)) {
      missing.add(rule);
      reasons.add('${outcome.name}: $rule 없음');
    }
  }

  String mark(String rule) => '$rule ${missing.contains(rule) ? '없음' : '있음'}';
  final include = includeBroken > 0 ? ' · include 사슬 끊김 $includeBroken줄' : '';
  final noError = exitWithoutError ? ' · 종료 코드 3 인데 error 없음' : '';
  return (
    reasons: reasons,
    shown:
        '${mark(expectedBaseRule)} · ${mark(expectedPluginRule)}$include$noError',
  );
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
  await haltIfInterrupted();
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
  final create = await runProcess(
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
    timeout: createTimeout,
  );
  if (create.timedOut) {
    stderr.writeln(
      'flutter create: 시간 제한 ${createTimeout.inMinutes}분을 넘겨 끊었다 '
      '(네트워크 · 디스크 상태를 보고 다시 실행)',
    );
    return 69;
  }
  final created = create.result!;
  final createTime = create.elapsed;
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
  final get = await runProcess(
    sdk.flutterExecutable,
    ['--suppress-analytics', 'pub', 'get'],
    workingDirectory: appDir,
    environment: {'PUB_CACHE': pubCache},
    timeout: pubGetTimeout,
  );
  if (get.timedOut) {
    stderr.writeln(
      'flutter pub get: 시간 제한 ${pubGetTimeout.inMinutes}분을 넘겨 끊었다 '
      '(GitHub · pub.dev 에 닿지 못하면 여기서 멈춘다 — 네트워크를 보고 다시 실행)',
    );
    return 69;
  }
  final got = get.result!;
  final getTime = get.elapsed;
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
    if (outcome == null) return 69;
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
    final verdict = judge(outcome);
    reasons.addAll(verdict.reasons);
    stdout.writeln('   판정: ${verdict.shown}');
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

/// 임시 폴더 [work] 를 정리하고 (지웠는지, 화면에 찍을 문구) 를 돌려준다.
///
/// [keep] 이면 지우지 않고 그 경로를 문구에 담는다 — 경로가 화면에 나오는 것은 이때뿐이다 (06-CONTEXT
/// 묻지 않고 잡은 것). 지우지 못하면 이유만 담는다.
({bool deleted, String message}) cleanupWork(
  Directory work, {
  required bool keep,
}) {
  if (keep) return (deleted: false, message: '임시 폴더를 남겼다: ${work.path}');
  try {
    work.deleteSync(recursive: true);
    return (deleted: true, message: '임시 폴더를 지웠다');
  } on FileSystemException catch (e) {
    return (deleted: false, message: '임시 폴더를 지우지 못했다: ${e.message}');
  }
}

/// 진입점 — 인자 → SDK 확인 → 기대 커밋 → 임시 폴더에서 smoke → 정리 → 종료 코드.
///
/// 정리는 `finally` 에서 한다 — 세 예외 밖의 throw 에서도 지운 뒤 처리되지 않은 예외(255)로 끝난다.
/// Ctrl-C (SIGINT) 는 도는 하위 명령과 자손을 끊고 같은 정리를 한 뒤 130 으로 끝낸다 (06-REVIEW.md IN-01).
Future<void> main(List<String> args) async {
  final (ref, keep) = await parseArgs(args);
  final repoRoot = File.fromUri(Platform.script).parent.parent.path;
  Directory? work;
  var cleaned = false;
  void cleanup() {
    final dir = work;
    if (dir == null || cleaned) return;
    cleaned = true;
    final done = cleanupWork(dir, keep: keep);
    // --keep 의 "남겼다" 는 지금처럼 stdout 의 마지막 줄이고, 지우지 못한 경우만 stderr 다.
    (done.deleted || keep ? stdout : stderr).writeln(done.message);
  }

  final interrupts = ProcessSignal.sigint.watch().listen((_) async {
    if (interrupted || quitting) return;
    interrupted = true;
    final child = runningChild;
    if (child != null) {
      await killTree(child);
    }
    cleanup();
    stderr.writeln('중단됨 (SIGINT) — 임시 폴더를 정리하고 끝낸다');
    await quit(130);
  });
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
  } finally {
    await interrupts.cancel();
    cleanup();
  }
  await quit(code);
}
