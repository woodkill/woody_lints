// Spike 021 ~ 023 이 함께 쓰는 조각 — 사용 프로젝트(`flutter_starter_kit`)의 복사본을 만들고,
// `woody_lints` 를 작업 중인 저장소 자체로 돌려 분석한다.
//
// 019 의 `Consumer` 를 바탕으로 했다. 다른 점은 셋이다.
//   - replica 를 만들지 않고 `pubspec_overrides.yaml` 의 `path:` 가 작업 중인 저장소를 가리킨다
//     (프리셋을 나눈 뒤라 019 의 `Shipped` 로 자를 한 파일이 없다).
//   - 받은 자리가 저장소가 아니면 그 실행을 버린다 (`ensureRepoSource` — 019 는 기록만 했다).
//   - 저장소의 지문(`Repo.fingerprint`)을 실행 전후로 견줄 수 있다.
//
// 비공개 프로젝트의 결과에는 경로 · 메시지 · 코드 조각을 남기지 않는다. 진단 줄은
// `<작업 폴더>/private/` 에만 쓰고, 결과 파일에는 규칙 · 자리별 건수와 줄 목록의 해시만 남긴다.
// `dart:io`, `dart:convert` 만 쓴다.
import 'dart:convert';
import 'dart:io';

/// 작업 중인 저장소.
class Repo {
  Repo(this.root);

  /// 링크를 푼 절대 경로.
  final String root;

  /// 이 파일이 있는 spike 폴더에서 저장소 루트를 찾는다 (`.planning/spikes/<spike>/`).
  static Repo fromSpikeDir(String spikeDir) =>
      Repo(Directory('$spikeDir/../../..').resolveSymbolicLinksSync());

  /// 저장소가 바뀌었는지 보는 지문 — git 이 보는 변경, 무시되는 `.dart_tool/` 의 맨 위 이름들,
  /// 루트 `package_config.json` · `pubspec.lock` 의 해시.
  Future<String> fingerprint() async {
    final status = await Process.run('git', ['status', '--porcelain'], workingDirectory: root);
    String fileDigest(String rel) {
      final f = File('$root/$rel');
      return f.existsSync() ? digest(f.readAsBytesSync()) : '-';
    }

    final tool = Directory('$root/.dart_tool');
    final top = tool.existsSync()
        ? (tool.listSync().map((e) => e.path.split('/').last).toList()..sort()).join(',')
        : '-';
    return [
      '${status.stdout}',
      top,
      fileDigest('.dart_tool/package_config.json'),
      fileDigest('pubspec.lock'),
    ].join('|');
  }
}

/// 정답지 형식 한 줄 (`상대경로:줄  강도  규칙이름`) 과 그 자리.
class Diag {
  Diag(this.path, this.line, this.severity, this.code);
  final String path;
  final int line;
  final String severity;
  final String code;

  static const markerDir = 'lib/woody_probe_marker/';

  /// marker / generated / lib / test / bin / 그 밖의 파일 이름.
  String get area {
    if (path.startsWith(markerDir)) return 'marker';
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) return 'generated';
    final slash = path.indexOf('/');
    return slash < 0 ? path : path.substring(0, slash);
  }

  String get text => '$path:$line  $severity  $code';
}

/// 분석 한 번의 결과.
class Shot {
  Shot(this.id);
  final String id;
  int exitCode = -1;
  int elapsedMs = 0;
  bool jsonOk = false;
  bool pluginHeader = false;
  int pluginFolders = -1;
  String pluginVersion = '?';
  String woodySource = '?';
  final diags = <Diag>[];

  Iterable<Diag> get marker => diags.where((d) => d.area == 'marker');
  Iterable<Diag> get project => diags.where((d) => d.area != 'marker');

  /// 자리 → 규칙 → 건수.
  Map<String, Map<String, int>> countByAreaCode([Iterable<Diag>? only]) {
    final out = <String, Map<String, int>>{};
    for (final d in only ?? diags) {
      final m = out.putIfAbsent(d.area, () => <String, int>{});
      m.update(d.code, (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }

  /// 결과 파일에 쓰는 모양 — 사용 프로젝트의 경로와 메시지가 없다. 표식의 줄은 이 저장소의
  /// 샘플이라 전문을 남긴다.
  Map<String, Object> toJson() => {
        'id': id,
        'exitCode': exitCode,
        'elapsedMs': elapsedMs,
        'jsonOk': jsonOk,
        'pluginHeader': pluginHeader,
        'pluginFolders': pluginFolders,
        'pluginVersion': pluginVersion,
        'woodySource': woodySource,
        'lines': {'all': diags.length, 'marker': marker.length, 'project': project.length},
        'countByAreaCode': countByAreaCode(),
        'projectDigest': digest(utf8.encode((project.map((d) => d.text).toList()..sort()).join('\n'))),
        'markerLines': (marker.map((d) => d.text).toList()..sort()),
      };
}

/// 사용 프로젝트의 복사본.
class Consumer {
  Consumer({required this.work, required this.repo, required this.source}) : dir = '$work/consumer';

  final String work;
  final Repo repo;

  /// 원본의 경로 — 인자로 받는다. 스크립트에 적지 않는다.
  final String source;
  final String dir;

  late final String originalPubspec;
  late final String originalLock;
  late final String originalOptions;
  int copiedFiles = 0;

  String get _dart => Platform.resolvedExecutable;

  /// 분석에 필요한 것만 옮긴다 (019 와 같은 목록). 원본은 읽기만 한다.
  void copy() {
    final d = Directory(dir);
    if (d.existsSync()) d.deleteSync(recursive: true);
    d.createSync(recursive: true);
    for (final name in ['pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml', 'l10n.yaml']) {
      final file = File('$source/$name');
      if (!file.existsSync()) continue;
      file.copySync('$dir/$name');
      copiedFiles++;
    }
    for (final name in ['lib', 'test', 'bin', 'assets']) {
      final from = Directory('$source/$name');
      if (!from.existsSync()) continue;
      for (final f in from.listSync(recursive: true, followLinks: false).whereType<File>()) {
        final to = File('$dir/$name${f.path.substring(from.path.length)}');
        to.parent.createSync(recursive: true);
        f.copySync(to.path);
        copiedFiles++;
      }
    }
    originalPubspec = File('$dir/pubspec.yaml').readAsStringSync();
    originalLock = File('$dir/pubspec.lock').readAsStringSync();
    originalOptions = File('$dir/analysis_options.yaml').readAsStringSync();
    if (!originalOptions.contains('include: package:woody_lints/analysis_options.yaml')) {
      throw const FormatException('복사본의 옵션 파일이 옛 주소를 include 하지 않는다 — 사용 프로젝트가 바뀌었다');
    }
  }

  /// `woody_lints` 를 작업 중인 저장소로 돌리고 패키지를 받는다.
  Future<void> pointToRepo() async {
    File('$dir/pubspec_overrides.yaml')
        .writeAsStringSync('dependency_overrides:\n  woody_lints:\n    path: ${repo.root}\n');
    await pubGet();
  }

  Future<void> pubGet() async {
    final r = await Process.run(_dart, ['--suppress-analytics', 'pub', 'get', '--no-example'],
        workingDirectory: dir);
    if (r.exitCode != 0) {
      throw ProcessException(_dart, ['pub', 'get'], scrubText('${r.stderr}'), r.exitCode);
    }
  }

  /// `package_config.json` 의 `woody_lints` 가 가리키는 자리 — `repo` / `git` / `?`.
  String woodySource() {
    final config = File('$dir/.dart_tool/package_config.json');
    if (!config.existsSync()) return '?';
    final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
    final p = (json['packages'] as List)
        .cast<Map<String, dynamic>>()
        .where((p) => p['name'] == 'woody_lints')
        .toList();
    if (p.length != 1) return '?';
    final uri = '${p.single['rootUri']}';
    if (uri.contains('/git/woody_lints-')) return 'git';
    final resolved = uri.startsWith('file:')
        ? Directory.fromUri(Uri.parse(uri)).path
        : Directory('$dir/.dart_tool/$uri').absolute.path;
    final d = Directory(resolved);
    if (!d.existsSync()) return '?';
    return d.resolveSymbolicLinksSync() == repo.root ? 'repo' : '?';
  }

  /// 받은 자리가 작업 중인 저장소가 아니면 그 회차를 버린다.
  void ensureRepoSource(Shot shot) {
    if (shot.woodySource != 'repo') {
      throw StateError('${shot.id}: woody_lints 가 작업 중인 저장소를 가리키지 않는다 (${shot.woodySource}) — 이 회차를 쓰지 않는다');
    }
  }

  void setOptions(String text) => File('$dir/analysis_options.yaml').writeAsStringSync(text);
  void setPubspec(String text) => File('$dir/pubspec.yaml').writeAsStringSync(text);

  /// 원본 옵션 파일에 규칙을 더 켜고(맵 문법), 필요하면 `analyzer.language` 를 더한 문자열.
  String optionsWith({List<String> rules = const [], Map<String, bool> language = const {}}) {
    var text = originalOptions;
    if (rules.isNotEmpty) {
      text = replaceOnce(text, '\n  rules:\n',
          '\n  rules:\n${rules.map((r) => '    $r: true\n').join()}');
    }
    if (language.isNotEmpty) {
      text = replaceOnce(text, '\nanalyzer:\n',
          '\nanalyzer:\n  language:\n${language.entries.map((e) => '    ${e.key}: ${e.value}\n').join()}');
    }
    return text;
  }

  /// 원본 `pubspec.yaml` 의 SDK 하한만 바꾼 문자열.
  String pubspecWithSdk(String constraint) =>
      replaceOnce(originalPubspec, '\n  sdk: ^3.11.1\n', '\n  sdk: $constraint\n');

  /// 표식 — 이 저장소 `example/lib` 의 샘플을 `lib/woody_probe_marker/` 로.
  void addExampleMarkers() {
    final from = Directory('${repo.root}/example/lib');
    for (final f in from.listSync(recursive: true).whereType<File>()) {
      final to = File('$dir/${Diag.markerDir}${f.path.substring(from.path.length + 1)}');
      to.parent.createSync(recursive: true);
      f.copySync(to.path);
    }
  }

  /// 표식을 더한다 — `lib/woody_probe_marker/<상대 경로>`.
  void addMarkers(Map<String, String> files) {
    for (final e in files.entries) {
      final to = File('$dir/${Diag.markerDir}${e.key}');
      to.parent.createSync(recursive: true);
      to.writeAsStringSync(e.value);
    }
  }

  void removeMarkers(Iterable<String> relPaths) {
    for (final rel in relPaths) {
      final f = File('$dir/${Diag.markerDir}$rel');
      if (f.existsSync()) f.deleteSync();
    }
  }

  /// 복사본을 작업 디렉터리로 두고 인자 없이 분석한다. 실행마다 빈 상태 폴더를 준다.
  Future<Shot> analyze(String id) async {
    final shot = Shot(id)..woodySource = woodySource();
    final state = Directory('$work/state/$id');
    if (state.existsSync()) state.deleteSync(recursive: true);
    state.createSync(recursive: true);
    final watch = Stopwatch()..start();
    final r = await Process.run(_dart, ['--suppress-analytics', 'analyze', '--format=json'],
        workingDirectory: dir, environment: {'ANALYZER_STATE_LOCATION_OVERRIDE': state.path});
    shot.elapsedMs = watch.elapsedMilliseconds;
    shot.exitCode = r.exitCode;
    shot.pluginHeader = '${r.stderr}'.contains('An error occurred while executing an analyzer plugin:');
    final manager = Directory('${state.path}/.plugin_manager');
    final folders = manager.existsSync() ? manager.listSync().whereType<Directory>().toList() : <Directory>[];
    shot.pluginFolders = folders.length;
    if (folders.length == 1) {
      final lock = File('${folders.single.path}/pubspec.lock');
      if (lock.existsSync()) {
        final m = RegExp(r'\n  riverpod_lint:\n(?:    .*\n)*?    version: "([^"]+)"').firstMatch(lock.readAsStringSync());
        shot.pluginVersion = m?.group(1) ?? '?';
      }
    }
    final jsonLine = '${r.stdout}'.split('\n').lastWhere((l) => l.startsWith('{'), orElse: () => '');
    if (jsonLine.isNotEmpty) {
      shot.jsonOk = true;
      final decoded = jsonDecode(jsonLine) as Map<String, dynamic>;
      for (final d in (decoded['diagnostics'] as List).cast<Map<String, dynamic>>()) {
        final loc = d['location'] as Map<String, dynamic>;
        var file = '${loc['file']}';
        if (file.startsWith('$dir/')) file = file.substring(dir.length + 1);
        final line = ((loc['range'] as Map)['start'] as Map)['line'] as int;
        shot.diags.add(Diag(file, line, '${d['severity']}'.toLowerCase(), '${d['code']}'));
      }
    }
    // 줄 단위 기록은 저장소 밖에만 둔다.
    final private = Directory('$work/private')..createSync(recursive: true);
    File('${private.path}/$id.txt').writeAsStringSync((shot.diags.map((d) => d.text).toList()..sort()).join('\n'));
    return shot;
  }

  /// 결과에 쓸 문자열에서 로컬 경로를 가린다 (원본의 경로가 가장 먼저).
  String scrubText(String text) {
    final home = Platform.environment['HOME'] ?? '/nonexistent-home';
    return text
        .replaceAll(source, '<consumer-source>')
        .replaceAll(work, '<work>')
        .replaceAll(repo.root, '<repo>')
        .replaceAll(home, '~');
  }
}

/// [from] 이 정확히 한 번 나오는지 확인하고 바꾼다 — 사용 프로젝트가 바뀌면 조용히 엉뚱한 것을 재지 않고 멈춘다.
String replaceOnce(String text, String from, String to) {
  final count = from.allMatches(text).length;
  if (count != 1) throw FormatException('바꿀 자리가 $count번 나온다: ${jsonEncode(from)}');
  return text.replaceFirst(from, to);
}

/// 64비트 FNV-1a (019 와 같다). 빈 목록은 `cbf29ce484222325`.
String digest(List<int> bytes) {
  var hash = 0xcbf29ce484222325;
  for (final unit in bytes) {
    hash = (hash ^ unit) * 0x100000001b3;
  }
  String half(int v) => (v & 0xffffffff).toRadixString(16).padLeft(8, '0');
  return half(hash >> 32) + half(hash);
}

/// 정답지 파일에서 진단 줄만 (`#` 머리 주석과 `exit N` 줄을 뺀다).
List<String> expectedLines(String path) => File(path)
    .readAsLinesSync()
    .where((l) => l.trim().isNotEmpty && !l.startsWith('#') && !l.startsWith('exit '))
    .toList();
