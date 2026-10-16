// spike 009 ~ 014 가 함께 쓰는 조각.
//
// 저장소의 모양을 작업 폴더에 복사하고(replica), 배포 파일(`lib/analysis_options.yaml`)을
// Phase 3 이 나눌 모양대로 **잘라서** 넣고, 그 안에서 `dart analyze` 를 돌린다.
// 조각 파일을 손으로 다시 쓰지 않는 이유: 나누는 것은 구조 변경이라 내용이 한 글자도
// 달라지면 안 되고(03-CONTEXT.md), 잘라 붙인 조각을 이으면 원본과 같다는 것을 확인할 수 있다.
//
// 저장소의 파일은 읽기만 한다. `dart:io`, `dart:convert` 만 쓴다 (CONVENTIONS.md).
// 실행마다 상태 폴더를 `ANALYZER_STATE_LOCATION_OVERRIDE` 로 넘긴다 — `~/.dartServer` 는
// 건드리지 않고, 빈 폴더를 주면 "이 실행이 plugin 을 준비했는가" 를 폴더 수로 볼 수 있다.
import 'dart:convert';
import 'dart:io';

/// `example/` 의 샘플이 내는 plugin(`riverpod_lint`) 진단의 규칙 이름.
const pluginCodes = [
  'missing_provider_scope',
  'provider_parameters',
  'avoid_public_notifier_properties',
];

/// plugin 준비 실패를 알리는 stderr 의 머리말 (spike 002, 008). `contains` 로 찾는다.
const pluginFailureHeader = 'An error occurred while executing an analyzer plugin:';

/// codegen 조각을 받지 않으면 나와야 하는 줄 — 생성 파일 샘플의 진단 (Phase 2 의 M4 · M5).
const generatedLines = [
  'lib/generated/sample.freezed.dart:4  info  avoid_print',
  'lib/generated/sample.freezed.dart:4  info  prefer_single_quotes',
  'lib/generated/sample.g.dart:4  info  avoid_print',
  'lib/generated/sample.g.dart:4  info  prefer_single_quotes',
];

/// codegen 조각을 받지 않으면 나와야 하는 줄 — annotation 샘플의 진단 (Phase 2 의 M3).
const annotationLine = 'lib/should_not_appear.dart:5  warning  invalid_annotation_target';

/// 저장소의 배포 파일을 Phase 3 이 나눌 모양대로 자른 조각.
class Shipped {
  Shipped._(this.original, this.basePart, this.codegenPart, this.riverpodPart, this.tailPart);

  /// [repoRoot] 의 `lib/analysis_options.yaml` 을 읽어 자른다. 모양이 다르면 [FormatException].
  factory Shipped.read(String repoRoot) {
    final original = File('$repoRoot/lib/analysis_options.yaml').readAsStringSync();
    final raw = original.split('\n');
    final lines = [
      for (var i = 0; i < raw.length - 1; i++) '${raw[i]}\n',
      if (raw.last.isNotEmpty) raw.last,
    ];
    final analyzerAt = lines.indexOf('analyzer:\n');
    final commentAt = lines.indexWhere((l) => l.startsWith('# analyzer plugin'));
    final pluginsAt = lines.indexOf('plugins:\n');
    if (analyzerAt < 0 || commentAt < analyzerAt || pluginsAt < commentAt) {
      throw const FormatException('배포 파일의 analyzer: / plugins: 자리가 예상과 다르다');
    }
    var afterPlugins = pluginsAt + 1;
    while (afterPlugins < lines.length && lines[afterPlugins].startsWith(' ')) {
      afterPlugins++;
    }
    final shipped = Shipped._(
      original,
      lines.sublist(0, analyzerAt).join(),
      lines.sublist(analyzerAt, commentAt).join(),
      lines.sublist(commentAt, afterPlugins).join(),
      lines.sublist(afterPlugins).join(),
    );
    final rejoined =
        shipped.basePart + shipped.codegenPart + shipped.riverpodPart + shipped.tailPart;
    if (rejoined != original) {
      throw const FormatException('자른 조각을 이은 것이 원본과 다르다');
    }
    if (!shipped.basePart.contains('\nlinter:\n') || shipped.basePart.contains('plugins:')) {
      throw const FormatException('기본 조각에 linter: 가 없거나 plugins: 가 섞였다');
    }
    return shipped;
  }

  /// 원본 전문.
  final String original;

  /// 처음부터 규칙 목록 끝까지 (`include: flutter_lints`, 주석 처리된 `formatter:`, `linter.rules`).
  final String basePart;

  /// `analyzer:` 블록 (`errors` 와 `exclude`).
  final String codegenPart;

  /// plugin 설명 주석과 `plugins:` 블록.
  final String riverpodPart;

  /// 맨 끝의 템플릿 영어 주석.
  final String tailPart;

  /// `lib/base.yaml` 로 쓸 내용.
  String get baseYaml => basePart + tailPart;

  /// `lib/codegen.yaml` 로 쓸 내용.
  String get codegenYaml => codegenPart;

  /// `lib/riverpod.yaml` 로 쓸 내용. [constraint] 를 주면 버전 제약만 바꾼다.
  String riverpodYaml({String? constraint}) {
    if (constraint == null) return riverpodPart;
    const from = '  riverpod_lint: ^3.1.3\n';
    if (!riverpodPart.contains(from)) {
      throw const FormatException('plugins: 블록에서 riverpod_lint 선언 줄을 찾지 못했다');
    }
    return riverpodPart.replaceAll(from, '  riverpod_lint: $constraint\n');
  }

  /// 나누지 않은 한 파일로 둔 같은 내용 — 조각 조합의 대조 기준이다.
  String combined({required bool riverpod, required bool codegen}) =>
      basePart + (codegen ? codegenPart : '') + (riverpod ? riverpodPart : '') + tailPart;

  /// 기본 조각에 적힌(주석 처리되지 않은) 규칙 수.
  int get declaredRuleCount =>
      RegExp(r'^    - \w+', multiLine: true).allMatches(basePart).length;
}

/// 저장소의 정답지 (`example/expected_diagnostics.txt`).
class Expected {
  Expected._(this.exitCode, this.lines);

  /// [repoRoot] 의 정답지를 읽는다. 형식이 다르면 [FormatException].
  factory Expected.read(String repoRoot) {
    final body = File('$repoRoot/example/expected_diagnostics.txt')
        .readAsLinesSync()
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();
    final head = body.isEmpty ? null : RegExp(r'^exit (\d+)$').firstMatch(body.first);
    if (head == null) throw const FormatException('정답지의 첫 줄이 exit N 이 아니다');
    return Expected._(int.parse(head.group(1)!), body.sublist(1)..sort());
  }

  /// 정답지의 `exit N`.
  final int exitCode;

  /// 정답지의 진단 줄 (정렬됨).
  final List<String> lines;

  /// 그 조합이 내야 하는 줄 — 정답지에서 빼고 더해 만든다 (03-CONTEXT.md D-02 · D-03).
  List<String> predicted({required bool riverpod, required bool codegen}) {
    final out = [
      for (final l in lines)
        if (riverpod || !pluginCodes.any((c) => l.endsWith('  $c'))) l,
      if (!codegen) ...generatedLines,
      if (!codegen) annotationLine,
    ];
    return out..sort();
  }
}

/// `dart analyze` 한 번의 기록.
class Run {
  /// [lines] 는 작업 디렉터리 기준 상대 경로로 정규화한 진단 줄이다.
  Run({
    required this.id,
    required this.title,
    required this.exitCode,
    required this.elapsed,
    required this.lines,
    required this.messages,
    required this.jsonOk,
    required this.stderrText,
    required this.pluginFolders,
    required this.pluginSnapshot,
    required this.pluginVersion,
    required this.pluginConstraint,
  });

  /// 짧은 이름.
  final String id;

  /// 표에 찍을 설명.
  final String title;

  /// `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 걸린 시간.
  final Duration elapsed;

  /// 정답지 형식으로 정규화한 진단 줄 (정렬됨).
  final List<String> lines;

  /// [lines] 와 같은 순서의 진단 메시지.
  final List<String> messages;

  /// stdout 이 JSON 으로 읽혔는지. false 면 "진단 0건" 이 아니라 "JSON 없음" 이다.
  final bool jsonOk;

  /// stderr 원문 (경로를 가린 것).
  final String stderrText;

  /// 상태 폴더의 `.plugin_manager` 아래 폴더 수. 빈 상태 폴더로 시작했다면 0 은 "준비하지 않았다" 다.
  final int pluginFolders;

  /// 컴파일된 plugin(`plugin.aot`)이 있는지.
  final bool pluginSnapshot;

  /// plugin 폴더의 `pubspec.lock` 에서 읽은 `riverpod_lint` 버전. 폴더가 하나가 아니면 null.
  final String? pluginVersion;

  /// 서버가 만든 `pubspec.yaml` 에 적힌 `riverpod_lint` 제약. 폴더가 하나가 아니면 null.
  final String? pluginConstraint;

  /// plugin 진단 줄.
  List<String> get pluginLines =>
      lines.where((l) => pluginCodes.any((c) => l.endsWith('  $c'))).toList();

  /// stderr 에 plugin 준비 실패의 머리말이 있는지.
  bool get pluginFailed => stderrText.contains(pluginFailureHeader);

  /// 걸린 시간(초, 소수 한 자리).
  String get seconds => (elapsed.inMilliseconds / 1000).toStringAsFixed(1);

  /// 결과 파일에 쓸 map.
  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'exitCode': exitCode,
        'elapsedMs': elapsed.inMilliseconds,
        'jsonOk': jsonOk,
        'pluginFolders': pluginFolders,
        'pluginSnapshot': pluginSnapshot,
        'pluginVersion': pluginVersion,
        'pluginConstraint': pluginConstraint,
        'lines': lines,
        'messages': messages,
        'stderr': stderrText,
      };
}

/// stdout 의 JSON 을 (정답지 형식 줄, 메시지) 목록으로 바꾼다. 읽지 못하면 null.
List<(String, String)>? normalizeDiagnostics(String stdoutText, List<String> bases) {
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
  if (decoded is! Map<String, dynamic> || decoded['diagnostics'] is! List) return null;
  final out = <(String, String)>[];
  for (final d in decoded['diagnostics'] as List) {
    final location = (d as Map<String, dynamic>)['location'] as Map<String, dynamic>;
    var file = location['file'] as String;
    for (final base in bases) {
      if (file.startsWith('$base/')) {
        file = file.substring(base.length + 1);
        break;
      }
    }
    final line = ((location['range'] as Map)['start'] as Map)['line'];
    out.add((
      '$file:$line  ${(d['severity'] as String).toLowerCase()}  ${d['code']}',
      '${d['problemMessage'] ?? ''}',
    ));
  }
  return out..sort((a, b) => a.$1.compareTo(b.$1));
}

/// 두 줄 목록의 차이를 건수까지 세어 돌려준다 (`- ` 는 [want] 에만, `+ ` 는 [got] 에만 있는 줄).
List<String> diffLines(List<String> want, List<String> got) {
  final rest = [...got];
  final out = <String>[];
  for (final l in want) {
    if (!rest.remove(l)) out.add('- $l');
  }
  return [...out, for (final l in rest) '+ $l'];
}

/// 확인 한 건의 결과를 모아 끝에 표로 찍는다.
class Checks {
  final _items = <(String, bool, String)>[];

  /// [label] 이 성립했는지([ok]) 적는다. [note] 는 표에 함께 찍는다.
  void add(String label, bool ok, [String note = '']) {
    _items.add((label, ok, note));
    stdout.writeln('   ${ok ? '✓' : '✗'} $label${note.isEmpty ? '' : ' — $note'}');
  }

  /// [run] 의 줄과 종료 코드가 [want] / [wantExit] 와 같은지 적고, 다르면 차이를 찍는다.
  void same(String label, Run run, List<String> want, int wantExit) {
    final diff = diffLines(want, run.lines);
    final ok = run.jsonOk && diff.isEmpty && run.exitCode == wantExit;
    add(label, ok, ok ? '${run.lines.length}줄, exit ${run.exitCode}' : 'exit ${run.exitCode} (기대 $wantExit), 차이 ${diff.length}줄');
    for (final d in diff) {
      stdout.writeln('       $d');
    }
  }

  /// 모두 성립했는지.
  bool get allOk => _items.every((i) => i.$2);

  /// 성립하지 않은 확인의 이름.
  List<String> get failed => [for (final i in _items) if (!i.$2) i.$1];

  /// 결과 파일에 쓸 목록.
  List<Map<String, Object?>> toJson() =>
      [for (final i in _items) {'label': i.$1, 'ok': i.$2, 'note': i.$3}];

  /// 끝에 찍는 요약.
  void printSummary() {
    stdout.writeln('');
    stdout.writeln('# 판정');
    for (final i in _items) {
      stdout.writeln('${i.$2 ? '✓' : '✗'} ${i.$1}${i.$3.isEmpty ? '' : ' — ${i.$3}'}');
    }
    stdout.writeln(allOk ? '모두 성립 (${_items.length}건)' : '성립하지 않음: ${failed.join(' / ')}');
  }
}

/// replica 를 만들고 고치고 분석하는 일을 맡는다.
class Replica {
  Replica._({required this.repoRoot, required this.spikeDir, required this.work});

  /// [script] 의 자리에서 저장소 루트를 찾고 [args] 의 첫 인자를 작업 폴더로 쓴다.
  ///
  /// 준비가 안 되어 있으면 할 일을 알리고 끝낸다 (64 사용법, 66 입력 없음, 73 폴더를 만들지 못함).
  static Replica open(List<String> args, Uri script) {
    final spikeDir = File.fromUri(script).parent.absolute.path;
    final name = spikeDir.split('/').last;
    if (args.isEmpty) {
      stderr.writeln('사용법: fvm dart run .planning/spikes/$name/<스크립트> <작업 폴더> [부 …]');
      exit(64);
    }
    final repoRoot = Directory(spikeDir).parent.parent.parent.absolute.path;
    for (final need in ['lib/analysis_options.yaml', 'example/pubspec.lock', 'example/expected_diagnostics.txt']) {
      if (!File('$repoRoot/$need').existsSync()) {
        stderr.writeln('저장소에서 $need 을 찾지 못했다: $repoRoot');
        exit(66);
      }
    }
    try {
      final workDir = Directory(args[0])..createSync(recursive: true);
      return Replica._(
        repoRoot: repoRoot,
        spikeDir: spikeDir,
        work: workDir.resolveSymbolicLinksSync(),
      );
    } on FileSystemException catch (e) {
      stderr.writeln('작업 폴더를 만들지 못했다: ${e.message} (${e.path})');
      exit(73);
    }
  }

  /// 저장소 루트의 절대 경로. 읽기만 한다.
  final String repoRoot;

  /// 이 스크립트가 든 spike 폴더.
  final String spikeDir;

  /// 작업 폴더의 절대 경로 (심볼릭 링크를 푼 것).
  final String work;

  /// 지금까지의 실행 기록.
  final runs = <Run>[];

  /// 저장소의 모양을 복사한 폴더.
  String get root => '$work/replica';

  /// 결과에 남지 않도록 로컬 경로를 가린다 (작업 브랜치가 공개 저장소에 올라간다).
  String scrub(String text) {
    final home = Platform.environment['HOME'] ?? '';
    var out = text
        .replaceAll(root, '<replica>')
        .replaceAll(work, '<work>')
        .replaceAll(repoRoot, '<repo>');
    if (home.isNotEmpty) out = out.replaceAll(home, '~');
    return out;
  }

  /// replica 를 비우고 저장소의 `pubspec.yaml` 과 루트 옵션 파일을 복사한다. `lib/` 는 비어 있다.
  void create() {
    final dir = Directory(root);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    Directory('$root/lib').createSync(recursive: true);
    for (final name in ['pubspec.yaml', 'analysis_options.yaml']) {
      File('$repoRoot/$name').copySync('$root/$name');
    }
  }

  /// `lib/` 의 YAML 을 모두 지우고 [files] (이름 → 내용)로 다시 쓴다.
  void writeLib(Map<String, String> files) {
    final lib = Directory('$root/lib');
    for (final f in lib.listSync().whereType<File>()) {
      if (f.path.endsWith('.yaml')) f.deleteSync();
    }
    files.forEach((name, body) => File('$root/lib/$name').writeAsStringSync(body));
  }

  /// 나누지 않은 모양 — `lib/analysis_options.yaml` 하나에 [body] 를 둔다.
  void writeLibUnsplit(String body) => writeLib({'analysis_options.yaml': body});

  /// 나눈 모양 — 조각 셋, 묶음, 옛 주소의 별칭.
  ///
  /// [relative] 가 참이면 묶음과 별칭이 `package:` 주소 대신 상대 경로로 부른다.
  /// [constraint] 는 `riverpod.yaml` 의 버전 제약을 바꾼다. [extra] 는 더 쓰거나 덮어쓸 파일이다.
  void writeLibSplit(
    Shipped shipped, {
    bool relative = false,
    String? constraint,
    Map<String, String> extra = const {},
  }) {
    final prefix = relative ? '' : 'package:woody_lints/';
    writeLib({
      'base.yaml': shipped.baseYaml,
      'riverpod.yaml': shipped.riverpodYaml(constraint: constraint),
      'codegen.yaml': shipped.codegenYaml,
      'recommended.yaml': includeList(['base', 'riverpod', 'codegen'], prefix: prefix),
      'analysis_options.yaml': 'include: ${prefix}recommended.yaml\n',
      ...extra,
    });
  }

  /// [names] 의 조각을 목록으로 부르는 옵션 파일 내용.
  static String includeList(List<String> names, {String prefix = 'package:woody_lints/'}) =>
      'include:\n${names.map((n) => '  - $prefix$n.yaml\n').join()}';

  /// 저장소 `example/` 의 샘플 소스와 lock 을 [rel] 에 복사해 연습용 프로젝트를 만든다.
  ///
  /// 의존성 경로만 [rel] 의 깊이에 맞춘다. 옵션 파일은 [options] 로 쓴다.
  void addFixture(String rel, {required String options}) {
    final dir = '$root/$rel';
    final source = Directory('$repoRoot/example/lib');
    for (final f in source.listSync(recursive: true).whereType<File>()) {
      final target = File('$dir/lib${f.path.substring(source.path.length)}');
      target.parent.createSync(recursive: true);
      f.copySync(target.path);
    }
    final up = List.filled(rel.split('/').length, '..').join('/');
    final pubspec = File('$repoRoot/example/pubspec.yaml').readAsStringSync();
    final lock = File('$repoRoot/example/pubspec.lock').readAsStringSync();
    if (!pubspec.contains('    path: ..\n') || !lock.contains('      path: ".."\n')) {
      throw const FormatException('example 의 pubspec.yaml / pubspec.lock 에서 path 줄을 찾지 못했다');
    }
    File('$dir/pubspec.yaml')
        .writeAsStringSync(pubspec.replaceAll('    path: ..\n', '    path: $up\n'));
    File('$dir/pubspec.lock')
        .writeAsStringSync(lock.replaceAll('      path: ".."\n', '      path: "$up"\n'));
    setOptions(rel, options);
  }

  /// [rel] 연습용 프로젝트의 옵션 파일을 [body] 로 다시 쓴다.
  void setOptions(String rel, String body) =>
      File('$root/$rel/analysis_options.yaml').writeAsStringSync(body);

  /// [dir] 에서 `dart pub get --no-example` 을 돌린다. 실패하면 프로그램을 끝낸다 (69).
  Future<void> getPackages(String dir) async {
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['pub', 'get', '--no-example'],
      workingDirectory: dir,
    );
    if (result.exitCode != 0) {
      stderr.writeln(
          'pub get 실패 (${scrub(dir)}): exit ${result.exitCode}\n${scrub('${result.stderr}')}');
      exit(69);
    }
  }

  /// 이름이 [name] 인 빈 상태 폴더를 만들어 그 경로를 돌려준다.
  String freshState(String name) {
    final dir = Directory('$work/state/$name');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    return dir.path;
  }

  /// 상태 폴더의 `.plugin_manager` 아래 폴더들.
  static List<Directory> pluginFolders(String stateDir) {
    final manager = Directory('$stateDir/.plugin_manager');
    if (!manager.existsSync()) return const [];
    return manager.listSync().whereType<Directory>().toList();
  }

  /// plugin 폴더의 `pubspec.lock` 에서 [package] 의 풀린 버전을 읽는다. 없으면 null.
  static String? lockedVersion(Directory pluginFolder, String package) {
    final lock = File('${pluginFolder.path}/pubspec.lock');
    if (!lock.existsSync()) return null;
    final lines = lock.readAsLinesSync();
    final start = lines.indexOf('  $package:');
    if (start < 0) return null;
    for (final line in lines.skip(start + 1)) {
      if (!line.startsWith('    ')) break;
      final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
      if (match != null) return match.group(1);
    }
    return null;
  }

  /// 서버가 만든 `pubspec.yaml` 에서 `riverpod_lint` 의 제약을 읽는다. 없으면 null.
  static String? declaredConstraint(Directory pluginFolder) {
    final pubspec = File('${pluginFolder.path}/pubspec.yaml');
    if (!pubspec.existsSync()) return null;
    final match =
        RegExp(r'^  riverpod_lint: (.+)$', multiLine: true).firstMatch(pubspec.readAsStringSync());
    return match?.group(1);
  }

  /// [cwd] 에서 `dart --suppress-analytics analyze --format=json [arguments]` 를 한 번 돌린다.
  ///
  /// [stateDir] 를 주지 않으면 실행마다 빈 상태 폴더를 쓴다 (plugin 을 처음부터 준비한다).
  /// [quiet] 이 참이면 진단 줄을 화면에 늘어놓지 않는다.
  Future<Run> analyze({
    required String id,
    required String title,
    required String cwd,
    List<String> arguments = const [],
    String? stateDir,
    bool quiet = false,
  }) async {
    final state = stateDir ?? freshState(id);
    final watch = Stopwatch()..start();
    final result = await Process.run(
      Platform.resolvedExecutable,
      ['--suppress-analytics', 'analyze', '--format=json', ...arguments],
      workingDirectory: cwd,
      environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state},
    );
    watch.stop();

    final folders = pluginFolders(state);
    final one = folders.length == 1 ? folders.single : null;
    final diagnostics = normalizeDiagnostics(result.stdout as String, [cwd]);
    final run = Run(
      id: id,
      title: title,
      exitCode: result.exitCode,
      elapsed: watch.elapsed,
      lines: [for (final d in diagnostics ?? const <(String, String)>[]) d.$1],
      messages: [for (final d in diagnostics ?? const <(String, String)>[]) scrub(d.$2)],
      jsonOk: diagnostics != null,
      stderrText: scrub((result.stderr as String).trim()),
      pluginFolders: folders.length,
      pluginSnapshot: folders.any((f) => File('${f.path}/bin/plugin.aot').existsSync()),
      pluginVersion: one == null ? null : lockedVersion(one, 'riverpod_lint'),
      pluginConstraint: one == null ? null : declaredConstraint(one),
    );
    runs.add(run);
    printRun(run, quiet: quiet);
    return run;
  }

  /// [run] 을 화면에 한 덩어리로 찍는다.
  void printRun(Run run, {bool quiet = false}) {
    final plugin = run.pluginFolders == 0
        ? 'plugin 폴더 0개'
        : 'plugin 폴더 ${run.pluginFolders}개'
            '${run.pluginVersion == null ? '' : ' (riverpod_lint ${run.pluginVersion}, 선언 ${run.pluginConstraint})'}';
    stdout.writeln('## ${run.id} — ${run.title}');
    stdout.writeln('   exit ${run.exitCode}, ${run.seconds}s, '
        '진단 ${run.jsonOk ? '${run.lines.length}건 (plugin ${run.pluginLines.length})' : 'JSON 없음'}, '
        '$plugin');
    if (!quiet) {
      for (final l in run.lines) {
        stdout.writeln('     $l');
      }
    }
    if (run.stderrText.isNotEmpty) {
      stdout.writeln('   stderr: ${run.stderrText.split('\n').take(3).join(' / ')}');
    }
  }

  /// 실행 기록과 [extra] 를 `results/[name].json` 에 쓴다.
  void writeResults(String name, {Map<String, Object?> extra = const {}}) {
    final file = File('$spikeDir/results/$name.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert({
          'dart': Platform.version.split(' ').first,
          'os': Platform.operatingSystem,
          ...extra,
          'runs': [for (final r in runs) r.toJson()],
        })}\n');
    stdout.writeln('');
    stdout.writeln('원본 결과: ${scrub(file.path)}');
  }
}

/// [body] 를 돌리고, 스크립트가 다루는 예외를 sysexits 종료 코드로 바꾼다 (CONVENTIONS.md).
Future<void> guard(Replica replica, Future<void> Function() body) async {
  try {
    await body();
  } on FormatException catch (e) {
    stderr.writeln('파일 모양이 예상과 다르다: ${e.message}');
    exitCode = 65;
  } on FileSystemException catch (e) {
    stderr.writeln('파일 작업 실패: ${e.message} (${replica.scrub(e.path ?? '')})');
    exitCode = 74;
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: ${replica.scrub('$e')}');
    exitCode = 70;
  }
}
