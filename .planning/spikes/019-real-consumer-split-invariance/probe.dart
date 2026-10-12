// spike 019 — 실제 사용 프로젝트의 복사본에 나눈 구조를 물려도 진단이 같은가.
//
// 실행:      fvm dart run .planning/spikes/019-real-consumer-split-invariance/probe.dart <작업 폴더> <사용 프로젝트 원본> [id,id,…]
// 다른 SDK:  <SDK>/bin/cache/dart-sdk/bin/dart <이 파일의 절대 경로> <작업 폴더> <사용 프로젝트 원본>   (저장소 밖에서 띄운다)
//
// 원본은 읽기만 한다 — 분석에 필요한 것만 <작업 폴더>/consumer 로 복사하고 실험은 복사본에서 한다.
//
// 사용 프로젝트(`flutter_starter_kit`)는 비공개 저장소다. 그 프로젝트의 파일 경로 · 진단 메시지 ·
// 코드 조각은 화면 기록과 결과 파일(results/)에 남기지 않고 **건수와 규칙 이름만** 남긴다.
// 줄 단위의 자세한 내용은 <작업 폴더>/private/ 에만 쓴다 (커밋하지 않는 자리).
//
// "같다" 가 "0건 = 0건" 으로 헛통과하지 않도록, 이 저장소 `example/lib` 의 위반 샘플을
// 복사본의 `lib/woody_probe_marker/` 에 넣는다 (표식 파일). 표식 파일의 줄은 이 저장소의 것이라 그대로 적는다.
import 'dart:convert';
import 'dart:io';

import '../009-preset-plugin-via-include/replica.dart';

/// `riverpod_lint` 3.1.9 의 진단 이름 15개 (spike 003). plugin 진단을 규칙 진단과 가르는 데 쓴다.
const riverpodCodes = {
  'missing_provider_scope',
  'provider_parameters',
  'avoid_public_notifier_properties',
  'avoid_ref_inside_state_dispose',
  'async_value_nullable_pattern',
  'functional_ref',
  'notifier_extends',
  'notifier_build',
  'riverpod_syntax_error',
  'protected_notifier_properties',
  'avoid_build_context_in_providers',
  'provider_dependencies',
  'scoped_providers_should_specify_dependencies',
  'unsupported_provider_value',
  'only_use_keep_alive_inside_keep_alive',
};

/// 표식 파일을 두는 자리 (복사본 기준).
const markerRel = 'lib/woody_probe_marker';

/// 사용 프로젝트의 옵션 파일에 있어야 하는 include 줄.
const oldInclude = 'include: package:woody_lints/analysis_options.yaml\n';

/// 사용 프로젝트가 옵션 파일에 직접 적어 둔 생성 파일 제외 두 줄.
const directExcludes = ['    - "**/*.g.dart"\n', '    - "**/*.freezed.dart"\n'];

/// 사용 프로젝트의 옵션 파일에서 규칙을 적는 자리 (맵 문법, 지금은 주석뿐이다).
const rulesKey = '  rules:\n';

/// 실제 코드에서 줄이 나오도록 더 켜 보는 규칙. 타입을 생략한 선언마다 걸리므로 어느 프로젝트에서나 줄이 많다.
const noisyRule = 'always_specify_types';

/// 처음에 [noisyRule] 로 골랐다가 이 프로젝트에서 0줄이 나온 규칙 (프리셋에는 주석 처리되어 있다).
/// pubspec 의 `publish_to: 'none'` 때문인지를 따로 본다.
const appBlindRule = 'public_member_api_docs';

/// [appBlindRule] 이 실제로 켜졌는지 가르는 표식 — 문서 주석이 없는 공개 선언 둘.
/// 이것마저 0줄이면 "코드가 깨끗해서" 가 아니라 "규칙이 이 프로젝트에 적용되지 않아서" 다.
const undocumentedSample = 'class UndocumentedPublicClass {}\n\nvoid undocumentedPublicFunction() {}\n';

/// 사용 프로젝트의 `dev_dependencies` 에 따로 적힌 plugin 패키지 줄.
const devLintLine = '  riverpod_lint: ^3.1.3\n';

/// 정답지 형식 한 줄을 풀어 읽은 것.
class Diag {
  /// [text] 는 `상대경로:줄  강도  규칙이름` 이다.
  Diag(this.text) {
    final parts = text.split('  ');
    final location = parts.first;
    path = location.substring(0, location.lastIndexOf(':'));
    severity = parts.length > 1 ? parts[1] : '?';
    code = parts.length > 2 ? parts[2] : '?';
  }

  /// 원문.
  final String text;

  /// 파일 경로 (복사본 기준 상대 경로. 복사본 밖의 파일이면 절대 경로다).
  late final String path;

  /// 강도.
  late final String severity;

  /// 규칙 이름.
  late final String code;

  /// 표식 파일의 줄인지.
  bool get marker => path.startsWith('$markerRel/');

  /// 생성 파일의 줄인지.
  bool get generated => path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

  /// plugin(`riverpod_lint`) 진단인지.
  bool get plugin => riverpodCodes.contains(code);

  /// 줄이 속한 자리. 경로를 남기지 않고 건수를 나눠 세는 데 쓴다.
  String get area {
    if (marker) return 'marker';
    for (final top in ['lib', 'test', 'bin']) {
      if (path.startsWith('$top/')) return top;
    }
    return 'other';
  }
}

/// [items] 를 [key] 로 묶어 센다 (이름순).
Map<String, int> countBy(Iterable<Diag> items, String Function(Diag) key) {
  final out = <String, int>{};
  for (final d in items) {
    out[key(d)] = (out[key(d)] ?? 0) + 1;
  }
  return {for (final k in out.keys.toList()..sort()) k: out[k]!};
}

/// 64비트 FNV-1a. 경로를 드러내지 않고 "줄 목록이 같다" 를 견줄 수 있게 한다.
String digest(Iterable<String> lines) {
  var hash = 0xcbf29ce484222325;
  for (final unit in utf8.encode(lines.join('\n'))) {
    hash = (hash ^ unit) * 0x100000001b3;
  }
  String half(int v) => (v & 0xffffffff).toRadixString(16).padLeft(8, '0');
  return half(hash >> 32) + half(hash);
}

/// 분석 한 번과 그 줄을 풀어 읽은 것.
class Shot {
  /// [run] 의 줄을 [Diag] 로 푼다. [stateDir] 는 그 실행에 준 상태 폴더다.
  Shot(this.run, this.stateDir) : diags = [for (final l in run.lines) Diag(l)];

  /// 실행 기록.
  final Run run;

  /// 그 실행의 상태 폴더.
  final String stateDir;

  /// 풀어 읽은 줄.
  final List<Diag> diags;

  /// 표식 파일의 줄 (이 저장소의 샘플이라 그대로 적어도 된다).
  List<String> get markerLines => [for (final d in diags) if (d.marker) d.text];

  /// 사용 프로젝트 자신의 줄.
  List<Diag> get project => [for (final d in diags) if (!d.marker) d];

  /// 사용 프로젝트의 생성 파일에서 나온 줄.
  List<Diag> get generated => [for (final d in project) if (d.generated) d];

  /// plugin 쪽에서 풀린 [package] 의 버전. plugin 폴더가 하나가 아니면 null.
  String? pluginSide(String package) {
    final folders = Replica.pluginFolders(stateDir);
    return folders.length == 1 ? Replica.lockedVersion(folders.single, package) : null;
  }

  /// 화면과 결과 파일에 적어도 되는 한 줄 요약.
  String get brief => 'exit ${run.exitCode}, ${run.seconds}s, '
      '${run.jsonOk ? '${diags.length}줄 (표식 ${markerLines.length} + 프로젝트 ${project.length}, '
          '그중 plugin ${project.where((d) => d.plugin).length} · 생성 파일 ${generated.length})' : 'JSON 없음'}, '
      'plugin 폴더 ${run.pluginFolders}개'
      '${run.pluginVersion == null ? '' : ' (riverpod_lint ${run.pluginVersion})'}'
      '${run.pluginFailed ? ', plugin 실패 머리말 있음' : ''}';

  /// 결과 파일에 쓸 map. 사용 프로젝트의 경로와 메시지는 넣지 않는다.
  Map<String, Object?> toJson() => {
        'id': run.id,
        'title': run.title,
        'exitCode': run.exitCode,
        'elapsedMs': run.elapsed.inMilliseconds,
        'jsonOk': run.jsonOk,
        'pluginFolders': run.pluginFolders,
        'pluginSnapshot': run.pluginSnapshot,
        'pluginFailed': run.pluginFailed,
        'stderrLines': run.stderrText.isEmpty ? 0 : run.stderrText.split('\n').length,
        'pluginSide': {
          for (final p in ['riverpod_lint', 'analyzer', 'analysis_server_plugin']) p: pluginSide(p),
        },
        'pluginConstraint': run.pluginConstraint,
        'total': diags.length,
        'markerLines': markerLines,
        'project': {
          'total': project.length,
          'digest': digest([for (final d in project) d.text]),
          'byArea': countBy(project, (d) => d.area),
          'bySeverity': countBy(project, (d) => d.severity),
          'ruleByCode': countBy(project.where((d) => !d.plugin), (d) => d.code),
          'pluginByCode': countBy(project.where((d) => d.plugin), (d) => d.code),
          'generated': {
            'rule': generated.where((d) => !d.plugin).length,
            'plugin': generated.where((d) => d.plugin).length,
            'byCode': countBy(generated, (d) => d.code),
          },
        },
      };
}

/// 복사본에서 `pub get` 이 어떤 상태로 끝나 있는지.
enum PubState {
  /// 원본의 `pubspec.yaml` 과 lock 그대로 (git 의존성, lock 의 커밋).
  asReceived,

  /// `pubspec_overrides.yaml` 로 `woody_lints` 를 replica 의 경로로 돌린 상태.
  pathOverride,

  /// 위에서 `dev_dependencies` 의 `riverpod_lint` 줄까지 뺀 상태.
  pathOverrideNoDevLint,
}

/// 사용 프로젝트의 복사본.
class Consumer {
  /// [source] 는 원본의 절대 경로다. 읽기만 한다.
  Consumer(this.replica, this.source) : dir = '${replica.work}/consumer';

  /// replica 와 작업 폴더.
  final Replica replica;

  /// 원본의 자리.
  final String source;

  /// 복사본의 자리.
  final String dir;

  /// 원본의 옵션 파일 · pubspec · lock 내용.
  late final String options, pubspec, lock;

  /// 지금 `pub get` 이 끝나 있는 상태. 아직 받지 않았으면 null.
  PubState? pubState;

  /// 원본 그대로의 lock 으로 받았는지 (`--enforce-lockfile` 이 통했는지).
  bool? lockEnforced;

  /// 분석에 필요한 것만 복사한다 (링크는 따라가지 않는다). 복사한 파일 수를 돌려준다.
  int copy() {
    final target = Directory(dir);
    if (target.existsSync()) target.deleteSync(recursive: true);
    target.createSync(recursive: true);
    var copied = 0;
    for (final name in ['pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml', 'l10n.yaml']) {
      final file = File('$source/$name');
      if (!file.existsSync()) continue;
      file.copySync('$dir/$name');
      copied++;
    }
    for (final name in ['lib', 'test', 'bin', 'assets']) {
      final from = Directory('$source/$name');
      if (!from.existsSync()) continue;
      for (final f in from.listSync(recursive: true, followLinks: false).whereType<File>()) {
        final to = File('$dir/$name${f.path.substring(from.path.length)}');
        to.parent.createSync(recursive: true);
        f.copySync(to.path);
        copied++;
      }
    }
    options = File('$dir/analysis_options.yaml').readAsStringSync();
    pubspec = File('$dir/pubspec.yaml').readAsStringSync();
    lock = File('$dir/pubspec.lock').readAsStringSync();
    return copied;
  }

  /// 이 저장소 `example/lib` 의 위반 샘플을 표식 파일로 넣는다.
  void addMarkers() {
    final from = Directory('${replica.repoRoot}/example/lib');
    for (final f in from.listSync(recursive: true).whereType<File>()) {
      final to = File('$dir/$markerRel${f.path.substring(from.path.length)}');
      to.parent.createSync(recursive: true);
      f.copySync(to.path);
    }
  }

  /// 옵션 파일을 [body] 로 다시 쓴다.
  void setOptions(String body) => File('$dir/analysis_options.yaml').writeAsStringSync(body);

  /// [from] 이 정확히 한 번 나오는지 확인하고 [to] 로 바꾼다. 아니면 [FormatException].
  static String replaceOnce(String text, String from, String to, String what) {
    if (from.allMatches(text).length != 1) {
      throw FormatException('$what 을(를) 정확히 한 번 찾지 못했다');
    }
    return text.replaceFirst(from, to);
  }

  /// include 줄을 [include] 로 바꾼 옵션 파일 내용.
  String optionsWith({String? include, bool dropDirectExcludes = false, String? addRule}) {
    var out = options;
    if (include != null) out = replaceOnce(out, oldInclude, include, '옵션 파일의 include 줄');
    if (addRule != null) {
      out = replaceOnce(out, rulesKey, '$rulesKey    $addRule: true\n', '옵션 파일의 rules: 줄');
    }
    if (dropDirectExcludes) {
      for (final line in directExcludes) {
        out = replaceOnce(out, line, '', '옵션 파일의 생성 파일 제외 줄');
      }
    }
    return out;
  }

  /// 복사본에서 `dart pub [args]` 를 돌린다.
  Future<ProcessResult> pub(List<String> args) =>
      Process.run(Platform.resolvedExecutable, ['pub', ...args], workingDirectory: dir);

  /// 복사본의 `pub get` 을 [want] 상태로 맞춘다. 실패하면 프로그램을 끝낸다 (69).
  Future<void> ensurePub(PubState want) async {
    if (pubState == want) return;
    final overrides = File('$dir/pubspec_overrides.yaml');
    if (want == PubState.asReceived) {
      if (overrides.existsSync()) overrides.deleteSync();
      File('$dir/pubspec.yaml').writeAsStringSync(pubspec);
      File('$dir/pubspec.lock').writeAsStringSync(lock);
      // 원본이 받고 있는 그대로 — lock 을 고치지 않고 받는다. 다른 SDK 에서는 통하지 않을 수 있다.
      var result = await pub(['get', '--enforce-lockfile', '--no-example']);
      lockEnforced = result.exitCode == 0;
      if (!lockEnforced!) result = await pub(['get', '--no-example']);
      if (result.exitCode != 0) _fail('원본 그대로의 pub get', result);
    } else {
      overrides.writeAsStringSync('dependency_overrides:\n  woody_lints:\n    path: ../replica\n');
      File('$dir/pubspec.yaml').writeAsStringSync(want == PubState.pathOverrideNoDevLint
          ? replaceOnce(pubspec, devLintLine, '', 'pubspec 의 riverpod_lint 줄')
          : pubspec);
      final result = await pub(['get', '--no-example']);
      if (result.exitCode != 0) _fail('경로를 돌린 pub get', result);
    }
    pubState = want;
  }

  Never _fail(String what, ProcessResult result) {
    stderr.writeln('$what 실패: exit ${result.exitCode}\n${replica.scrub('${result.stderr}')}');
    exit(69);
  }

  /// 복사본이 `woody_lints` 를 어디서 받고 있는지 — `git` (pub cache), `replica` (경로), 그 밖은 `?`.
  String woodySource() {
    final config = File('$dir/.dart_tool/package_config.json');
    if (!config.existsSync()) return '?';
    final packages = (jsonDecode(config.readAsStringSync()) as Map<String, dynamic>)['packages'] as List;
    for (final p in packages) {
      if ((p as Map<String, dynamic>)['name'] != 'woody_lints') continue;
      final uri = '${p['rootUri']}';
      if (uri.contains('/git/woody_lints-')) return 'git';
      final resolved = uri.startsWith('file:')
          ? File.fromUri(Uri.parse(uri)).path
          : Directory('$dir/.dart_tool/$uri').absolute.path;
      final real = Directory(resolved).existsSync() ? Directory(resolved).resolveSymbolicLinksSync() : '';
      return real == replica.root ? 'replica' : '?';
    }
    return '?';
  }

  /// 원본에 관해 적어도 되는 사실 — 수와 설정값뿐이다.
  Map<String, Object?> facts() {
    int dartFiles(String top, bool Function(String) keep) {
      final d = Directory('$dir/$top');
      if (!d.existsSync()) return 0;
      return d
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && !f.path.contains('/$markerRel/') && keep(f.path))
          .length;
    }

    bool generated(String p) => p.endsWith('.g.dart') || p.endsWith('.freezed.dart');
    final headers = <String, int>{};
    final lib = Directory('$dir/lib');
    for (final f in lib.listSync(recursive: true).whereType<File>()) {
      if (!generated(f.path) || f.path.contains('/$markerRel/')) continue;
      final kind = f.path.endsWith('.g.dart') ? 'g' : 'freezed';
      final line = f.readAsLinesSync().firstWhere((l) => l.contains('ignore_for_file'), orElse: () => '');
      final header = line.isEmpty
          ? '머리 없음'
          : (line.contains('type=lint') ? 'type=lint' : '다른 ignore_for_file') +
              (line.contains('type=warning') ? ' + type=warning' : '');
      headers['$kind: $header'] = (headers['$kind: $header'] ?? 0) + 1;
    }
    String? firstMatch(String text, String pattern) =>
        RegExp(pattern, multiLine: true).firstMatch(text)?.group(1);
    return {
      'dartFiles': {
        'lib (생성 파일 제외)': dartFiles('lib', (p) => !generated(p)),
        'lib 의 생성 파일': dartFiles('lib', generated),
        'test': dartFiles('test', (_) => true),
        'bin': dartFiles('bin', (_) => true),
      },
      'generatedHeaders': {for (final k in headers.keys.toList()..sort()) k: headers[k]},
      'sdkConstraint': firstMatch(pubspec, r'^  sdk: (\S+)$'),
      'includesOldAddress': options.contains(oldInclude),
      'directGeneratedExcludes': directExcludes.every(options.contains),
      'devDependencyRiverpodLint': pubspec.contains(devLintLine),
      'lockedWoodyLintsRef':
          firstMatch(lock, r'^  woody_lints:\n(?:    .*\n)*?      resolved-ref: "?([0-9a-f]{7})'),
    };
  }
}

Future<void> main(List<String> args) async {
  final replica = Replica.open(args, Platform.script);
  if (args.length < 2 || !File('${args[1]}/pubspec.yaml').existsSync()) {
    stderr.writeln('둘째 인자로 사용 프로젝트 원본의 경로를 준다 (pubspec.yaml 이 있는 폴더)');
    exit(args.length < 2 ? 64 : 66);
  }
  final only = args.length > 2 ? args[2].split(',').toSet() : null;
  final dartVersion = Platform.version.split(' ').first;
  final log = StringBuffer();
  void say([String line = '']) {
    stdout.writeln(line);
    log.writeln(line);
  }

  final checks = Checks();
  final notes = <Map<String, Object?>>[];
  final shots = <String, Shot>{};
  final privateDir = Directory('${replica.work}/private')..createSync(recursive: true);

  await guard(replica, () async {
    final shipped = Shipped.read(replica.repoRoot);
    final expected = Expected.read(replica.repoRoot);
    final consumer = Consumer(replica, Directory(args[1]).resolveSymbolicLinksSync());
    List<String> onMarker(List<String> lines) =>
        [for (final l in lines) l.replaceFirst('lib/', '$markerRel/')]..sort();

    say('Dart $dartVersion on ${Platform.operatingSystem}');
    final copied = consumer.copy();
    consumer.addMarkers();
    final facts = consumer.facts();
    say('복사한 파일 $copied개. 원본에 관한 사실: ${jsonEncode(facts)}');
    say();
    for (final need in {
      '옵션 파일이 옛 주소를 include 한다': facts['includesOldAddress'],
      '옵션 파일에 생성 파일 제외 두 줄이 있다': facts['directGeneratedExcludes'],
      'dev_dependencies 에 riverpod_lint 줄이 있다': facts['devDependencyRiverpodLint'],
    }.entries) {
      if (need.value != true) throw FormatException('사용 프로젝트의 모양이 예상과 다르다 — ${need.key}');
    }
    replica.create();

    /// 조건을 맞추고 분석을 한 번 돌린다. [only] 에 없으면 건너뛴다.
    Future<void> shoot(
      String id,
      String title, {
      required PubState pub,
      required bool split,
      String? include,
      bool dropDirectExcludes = false,
      String? addRule,
      bool dropPublishTo = false,
      String? extraMarker,
    }) async {
      if (only != null && !only.contains(id)) return;
      await consumer.ensurePub(pub);
      if (pub != PubState.asReceived) {
        if (split) {
          replica.writeLibSplit(shipped);
        } else {
          replica.writeLibUnsplit(shipped.original);
        }
      }
      consumer.setOptions(consumer.optionsWith(
          include: include, dropDirectExcludes: dropDirectExcludes, addRule: addRule));
      final source = consumer.woodySource();
      // pubspec 의 publish_to 줄만 빼고 본다 — 받은 패키지는 그대로라 pub get 을 다시 하지 않는다.
      final pubspecFile = File('${consumer.dir}/pubspec.yaml');
      final pubspecNow = pubspecFile.readAsStringSync();
      if (dropPublishTo) {
        final line = RegExp(r'^publish_to:.*\n', multiLine: true);
        if (line.allMatches(pubspecNow).length != 1) {
          throw const FormatException('pubspec 의 publish_to 줄을 정확히 한 번 찾지 못했다');
        }
        pubspecFile.writeAsStringSync(pubspecNow.replaceFirst(line, ''));
      }
      // 이 실행에만 두는 표식 파일 — 다른 실행의 표식 줄(정답지 16줄)에 섞이지 않게 끝나면 지운다.
      final extraFile = File('${consumer.dir}/$markerRel/extra_marker.dart');
      if (extraMarker != null) extraFile.writeAsStringSync(extraMarker);
      final run = await replica.analyze(id: id, title: title, cwd: consumer.dir, quiet: true);
      if (extraMarker != null) extraFile.deleteSync();
      if (dropPublishTo) pubspecFile.writeAsStringSync(pubspecNow);
      consumer.setOptions(consumer.options);
      final shot = shots[id] = Shot(run, '${replica.work}/state/$id');
      File('${privateDir.path}/$id.txt').writeAsStringSync('${run.lines.join('\n')}\n\n${run.stderrText}\n');
      say('## $id — $title');
      say('   받는 곳 $source · ${shot.brief}');
      notes.add({'id': id, 'woodySource': source});
    }

    /// 두 실행의 줄이 건수까지 같은지 본다. 다르면 규칙 이름별 건수만 적고 자세한 것은 private 에 쓴다.
    void same(String label, String a, String b, {bool judged = true}) {
      final x = shots[a], y = shots[b];
      if (x == null || y == null) return;
      final diff = diffLines(x.run.lines, y.run.lines);
      final ok = x.run.jsonOk && y.run.jsonOk && diff.isEmpty && x.run.exitCode == y.run.exitCode;
      File('${privateDir.path}/diff-$a-$b.txt').writeAsStringSync('${diff.join('\n')}\n');
      final byCode = <String, int>{};
      for (final d in diff) {
        final key = '${d.substring(0, 1)}${Diag(d.substring(2)).code}';
        byCode[key] = (byCode[key] ?? 0) + 1;
      }
      final note = ok
          ? '${x.diags.length}줄, exit ${x.run.exitCode}'
          : 'exit ${x.run.exitCode} / ${y.run.exitCode}, 차이 ${diff.length}줄 $byCode';
      if (judged) {
        checks.add(label, ok, note);
      } else {
        say('   ${ok ? '=' : '≠'} $label — $note');
        notes.add({'label': label, 'same': ok, 'note': note});
      }
    }

    /// [id] 의 표식 파일 줄이 [want] 와 같은지 본다 (이 저장소의 샘플이라 차이를 그대로 찍어도 된다).
    void marker(String label, String id, List<String> want, {bool judged = true}) {
      final shot = shots[id];
      if (shot == null) return;
      final diff = diffLines(onMarker(want), shot.markerLines);
      final note = diff.isEmpty ? '${shot.markerLines.length}줄' : '차이 ${diff.length}줄: ${diff.join(' | ')}';
      if (judged) {
        checks.add(label, shot.run.jsonOk && diff.isEmpty, note);
      } else {
        say('   ${diff.isEmpty ? '=' : '≠'} $label — $note');
        notes.add({'label': label, 'same': diff.isEmpty, 'note': note});
      }
    }

    say('# 1. 받는 방식과 구조를 바꿔 가며 (옵션 파일은 원본 그대로)');
    await shoot('V0', '지금 받는 그대로 — git 의존성, lock 의 커밋(1.3.0)', pub: PubState.asReceived, split: false);
    if (shots.containsKey('V0')) {
      say('   원본의 lock 그대로 받았는가(--enforce-lockfile): ${consumer.lockEnforced}');
      notes.add({'label': 'V0 을 원본의 lock 그대로 받았다', 'value': consumer.lockEnforced});
    }
    await shoot('V1', '한 파일 구조를 옆 폴더(path)에서', pub: PubState.pathOverride, split: false);
    await shoot('V2', '나눈 구조를 옛 주소로', pub: PubState.pathOverride, split: true);
    await shoot('V3', '나눈 구조를 묶음 주소로',
        pub: PubState.pathOverride, split: true, include: 'include: package:woody_lints/recommended.yaml\n');
    await shoot('X1', '대조 — 나눈 구조에서 base.yaml 만',
        pub: PubState.pathOverride, split: true, include: 'include: package:woody_lints/base.yaml\n');

    say();
    say('# 2. 프로젝트가 직접 적은 생성 파일 제외 두 줄을 뺐을 때');
    await shoot('G2u', '한 파일 구조 — 프리셋의 제외만 남음',
        pub: PubState.pathOverride, split: false, dropDirectExcludes: true);
    await shoot('G2s', '나눈 구조(옛 주소) — 프리셋의 제외만 남음',
        pub: PubState.pathOverride, split: true, dropDirectExcludes: true);
    await shoot('G3', '대조 — base + riverpod 만 받아 어디에도 제외가 없음',
        pub: PubState.pathOverride,
        split: true,
        include: Replica.includeList(['base', 'riverpod']),
        dropDirectExcludes: true);

    say();
    say('# 3. 프로젝트 옵션에 규칙 하나를 더 켰을 때 — 실제 코드에서 줄이 나오게 한다');
    await shoot('N1u', '한 파일 구조 + $noisyRule',
        pub: PubState.pathOverride, split: false, addRule: noisyRule);
    await shoot('N1s', '나눈 구조(옛 주소) + $noisyRule',
        pub: PubState.pathOverride, split: true, addRule: noisyRule);
    await shoot('P0', "나눈 구조 + $appBlindRule (pubspec 은 원본 그대로 — publish_to: 'none')",
        pub: PubState.pathOverride, split: true, addRule: appBlindRule, extraMarker: undocumentedSample);
    await shoot('P1', '나눈 구조 + $appBlindRule, pubspec 에서 publish_to 줄을 뺌',
        pub: PubState.pathOverride,
        split: true,
        addRule: appBlindRule,
        dropPublishTo: true,
        extraMarker: undocumentedSample);

    say();
    say('# 4. dev_dependencies 의 riverpod_lint 줄을 뺐을 때 (나눈 구조, 옛 주소)');
    await shoot('D', 'pubspec 에서 riverpod_lint 줄을 뺌', pub: PubState.pathOverrideNoDevLint, split: true);

    say();
    say('# 확인');
    marker('V0 표식 파일이 정답지 16줄을 그대로 낸다 (지금 받는 그대로)', 'V0', expected.lines);
    same('V1 = V0 — 옆 폴더에서 받아도 git 으로 받은 것과 같다', 'V0', 'V1');
    same('V2 = V1 — 나눠도 한 줄도 달라지지 않는다 (멈춤 조건)', 'V1', 'V2');
    same('V3 = V2 — 묶음 주소와 옛 주소가 같다', 'V2', 'V3');
    marker('V2 표식 파일이 정답지 16줄을 그대로 낸다 (나눈 구조)', 'V2', expected.lines);
    final x1 = shots['X1'], v2 = shots['V2'];
    if (x1 != null && v2 != null) {
      // 대조: base.yaml 만 받으면 plugin 진단이 빠지고 annotation 경고가 되살아나야 한다.
      // 생성 파일 샘플은 프로젝트가 직접 적은 제외에 걸려 여전히 나오지 않는다.
      final want = [
        for (final l in expected.lines)
          if (!riverpodCodes.any((c) => l.endsWith('  $c'))) l,
        annotationLine,
      ];
      marker('X1 대조가 다르게 나온다 — 표식 파일에서 plugin 3줄이 빠지고 annotation 1줄이 생긴다', 'X1', want);
      checks.add('X1 대조에서 plugin 을 준비하지 않는다', x1.run.pluginFolders == 0, 'plugin 폴더 ${x1.run.pluginFolders}개');
    }
    for (final id in ['V0', 'V1', 'V2', 'V3', 'G2u', 'G2s', 'G3', 'N1u', 'N1s', 'D']) {
      final s = shots[id];
      if (s == null) continue;
      checks.add('$id 에서 plugin 이 준비됐다',
          s.run.pluginFolders == 1 && s.run.pluginSnapshot && !s.run.pluginFailed,
          'plugin 폴더 ${s.run.pluginFolders}개, riverpod_lint ${s.run.pluginVersion ?? '?'}');
    }
    same('G2s = G2u — 직접 적은 제외를 빼도 나누기 전후가 같다', 'G2u', 'G2s');
    final n1u = shots['N1u'];
    if (n1u != null) {
      // 프로젝트 자신의 코드는 지금 진단이 0줄이라, 줄이 실제로 나오는 조건을 따로 만들어 견준다.
      checks.add('N1u 에서 프로젝트 자신의 코드에 줄이 나온다 (0줄 = 0줄 의 헛통과가 아니다)',
          n1u.project.isNotEmpty, '프로젝트 ${n1u.project.length}줄 ${countBy(n1u.project, (d) => d.area)}');
    }
    same('N1s = N1u — 프로젝트 자신의 코드에서 나온 줄까지 나누기 전후가 같다', 'N1u', 'N1s');

    say();
    say('# 기록 (판정에 넣지 않는다)');
    // 표식 파일의 생성 파일 샘플에는 규칙 위반 4줄이 있다 — 프리셋의 제외가 규칙 진단에 통하면 16줄 그대로다 (Dart 3.13.x).
    marker('G2s 표식 파일 — 프리셋의 제외만으로 생성 파일 샘플의 규칙 진단이 막힌다 (Dart 3.13.4 에서 =)', 'G2s',
        expected.lines,
        judged: false);
    marker('G3 표식 파일 — 제외가 없으면 생성 파일 샘플 4줄과 annotation 1줄이 생긴다 (대조)', 'G3',
        expected.predicted(riverpod: true, codegen: false),
        judged: false);
    same('D = V2 — dev_dependencies 의 riverpod_lint 줄은 진단에 영향이 없다', 'V2', 'D', judged: false);
    for (final id in ['V2', 'G2u', 'G2s', 'G3']) {
      final s = shots[id];
      if (s == null) continue;
      final g = s.generated;
      say('   $id 프로젝트의 생성 파일에서 나온 줄: 규칙 ${g.where((d) => !d.plugin).length}, '
          'plugin ${g.where((d) => d.plugin).length} ${countBy(g, (d) => d.code)}');
    }
    for (final id in ['P0', 'P1']) {
      final s = shots[id];
      if (s == null) continue;
      final hits = s.diags.where((d) => d.code == appBlindRule).toList();
      say('   $id 의 $appBlindRule: ${hits.length}줄 '
          '(표식 파일 ${hits.where((d) => d.marker).length}, 프로젝트 ${hits.where((d) => !d.marker).length} '
          '${countBy(hits.where((d) => !d.marker), (d) => d.area)})');
      notes.add({'label': '$id 의 $appBlindRule 줄 수', 'value': hits.length});
    }
    final g3 = shots['G3'];
    if (g3 != null && v2 != null) {
      final count = g3.project.where((d) => d.code == 'invalid_annotation_target').length;
      say('   G3 프로젝트의 invalid_annotation_target (codegen 조각을 받지 않을 때): $count줄');
      notes.add({'label': 'G3 의 invalid_annotation_target', 'value': count});
    }

    say();
    say('# 판정');
    for (final c in checks.toJson()) {
      say('${c['ok'] == true ? '✓' : '✗'} ${c['label']}${'${c['note']}'.isEmpty ? '' : ' — ${c['note']}'}');
    }
    say(checks.allOk
        ? '모두 성립 (${checks.toJson().length}건)'
        : '성립하지 않음: ${checks.failed.join(' / ')}');

    final results = Directory('${replica.spikeDir}/results')..createSync(recursive: true);
    final suffix = only == null ? '' : '-partial';
    File('${results.path}/probe-$dartVersion$suffix.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert({
          'dart': dartVersion,
          'os': Platform.operatingSystem,
          'consumer': facts,
          'lockEnforced': consumer.lockEnforced,
          'runs': [for (final s in shots.values) s.toJson()],
          'checks': checks.toJson(),
          'notes': notes,
        })}\n');
    File('${results.path}/probe-$dartVersion$suffix.log').writeAsStringSync(log.toString());
    stdout.writeln('');
    stdout.writeln('결과: ${replica.scrub(results.path)}/probe-$dartVersion$suffix.{json,log}');
    stdout.writeln('줄 단위 기록(커밋하지 않는다): ${replica.scrub(privateDir.path)}');
    if (!checks.allOk) exitCode = 1;
  });
}
