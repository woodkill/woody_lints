// spike 003 — riverpod_lint 규칙 15개의 강도 / JSON 표기 / 종료 코드를 표로 찍는다.
//
// 실행: fvm dart run .planning/spikes/003-riverpod-lint-severity-matrix/severity_matrix.dart <상태 폴더>
//
// 1) 배포 파일을 include 한 그대로 한 번 돌려 15개 규칙의 강도와 표기를 읽는다.
// 2) 규칙 하나만 남기고 나머지 14개를 끈 설정으로 15번 돌려, 그 규칙 하나가 만드는 종료 코드를 본다.
// 3) 15개를 모두 끈 설정으로 한 번 돌린다 (plugin 진단이 0건이어야 한다).
//
// 경우마다 fixture/analysis_options.yaml 을 바꿔 쓰고, 끝나면 원래 내용으로 되돌린다.
import 'dart:convert';
import 'dart:io';

/// riverpod_lint 3.1.9 의 `lib/main.dart` 가 등록하는 규칙 15개.
const ruleNames = [
  'async_value_nullable_pattern',
  'avoid_build_context_in_providers',
  'avoid_public_notifier_properties',
  'avoid_ref_inside_state_dispose',
  'functional_ref',
  'missing_provider_scope',
  'notifier_build',
  'notifier_extends',
  'only_use_keep_alive_inside_keep_alive',
  'protected_notifier_properties',
  'provider_dependencies',
  'provider_parameters',
  'riverpod_syntax_error',
  'scoped_providers_should_specify_dependencies',
  'unsupported_provider_value',
];

/// 배포 파일을 include 한 줄로 받는 정상 설정.
const okOptions = 'include: package:woody_lints/analysis_options.yaml\n';

/// 진단 한 건.
class Diagnostic {
  /// JSON 의 한 항목에서 필요한 값만 꺼내 담는다.
  const Diagnostic(this.file, this.line, this.severity, this.type, this.code);

  /// fixture 기준 상대 경로.
  final String file;

  /// 줄 번호.
  final int line;

  /// JSON `severity` (INFO / WARNING / ERROR).
  final String severity;

  /// JSON `type`.
  final String type;

  /// JSON `code`.
  final String code;

  /// `riverpod_lint/` 접두사를 뗀 규칙 이름.
  String get bareCode => code.contains('/') ? code.split('/').last : code;

  /// plugin 규칙의 진단인지.
  bool get isPlugin => ruleNames.contains(bareCode);
}

/// 실행 한 번의 결과.
class Outcome {
  /// 종료 코드, 진단 목록, stderr 를 담는다.
  const Outcome(this.exitCode, this.diagnostics, this.stderrText, this.jsonOk);

  /// `dart analyze` 의 종료 코드.
  final int exitCode;

  /// 읽어 낸 진단.
  final List<Diagnostic> diagnostics;

  /// stderr 원문.
  final String stderrText;

  /// stdout 이 JSON 으로 읽혔는지.
  final bool jsonOk;

  /// plugin 진단만 고른다.
  List<Diagnostic> get plugin => diagnostics.where((d) => d.isPlugin).toList();
}

/// [keep] 에 든 규칙만 남기고 나머지 plugin 진단을 끄는 설정을 만든다.
String buildOptions(Set<String> keep) {
  final buffer = StringBuffer(okOptions)
    ..writeln()
    ..writeln('plugins:')
    ..writeln('  riverpod_lint:')
    ..writeln('    version: ^3.1.3')
    ..writeln('    diagnostics:');
  for (final name in ruleNames) {
    if (!keep.contains(name)) buffer.writeln('      $name: false');
  }
  return buffer.toString();
}

/// fixture 에서 `dart analyze --format=json` 을 한 번 실행한다.
Future<Outcome> runAnalyze(String fixtureDir, Directory stateDir) async {
  final result = await Process.run(
    Platform.resolvedExecutable,
    ['analyze', '--format=json'],
    workingDirectory: fixtureDir,
    environment: {
      'ANALYZER_STATE_LOCATION_OVERRIDE': stateDir.path,
      // spike 001 에서 본 종료 코드 255 (분석 통계 전송 중 서버 종료)를 피한다.
      'DASH__SUPPRESS_ANALYTICS': 'true',
    },
  );
  final jsonLine = (result.stdout as String)
      .split('\n')
      .lastWhere((l) => l.trimLeft().startsWith('{'), orElse: () => '');
  final diagnostics = <Diagnostic>[];
  var jsonOk = false;
  try {
    final decoded = jsonDecode(jsonLine) as Map<String, dynamic>;
    final prefix = '$fixtureDir/';
    for (final d in decoded['diagnostics'] as List) {
      final location = (d as Map<String, dynamic>)['location'] as Map<String, dynamic>;
      final file = location['file'] as String;
      diagnostics.add(Diagnostic(
        file.startsWith(prefix) ? file.substring(prefix.length) : file,
        ((location['range'] as Map)['start'] as Map)['line'] as int,
        d['severity'] as String,
        d['type'] as String,
        d['code'] as String,
      ));
    }
    jsonOk = true;
  } on FormatException {
    // JSON 이 아니면 진단 없이 돌려준다. jsonOk 가 false 로 남는다.
  }
  return Outcome(result.exitCode, diagnostics, (result.stderr as String).trim(), jsonOk);
}

/// 상태 폴더에서 실제로 해석된 plugin 버전을 읽는다. 찾지 못하면 '?'.
String readResolvedPluginVersion(Directory stateDir) {
  final manager = Directory('${stateDir.path}/.plugin_manager');
  if (!manager.existsSync()) return '?';
  for (final entity in manager.listSync()) {
    final lock = File('${entity.path}/pubspec.lock');
    if (!lock.existsSync()) continue;
    final lines = lock.readAsLinesSync();
    final start = lines.indexOf('  riverpod_lint:');
    if (start < 0) continue;
    for (final line in lines.skip(start + 1)) {
      if (!line.startsWith('    ')) break;
      final match = RegExp(r'^\s+version: "(.+)"$').firstMatch(line);
      if (match != null) return match.group(1)!;
    }
  }
  return '?';
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('사용법: dart run severity_matrix.dart <상태 폴더>');
    exit(64);
  }
  final stateDir = Directory(args[0]);
  final spikeDir = File.fromUri(Platform.script).parent;
  final fixtureDir = Directory('${spikeDir.path}/fixture').absolute.path;
  final optionsFile = File('$fixtureDir/analysis_options.yaml');
  if (!File('$fixtureDir/.dart_tool/package_config.json').existsSync()) {
    stderr.writeln('연습용 프로젝트에 패키지가 없다. 먼저 실행: (cd $fixtureDir && fvm dart pub get)');
    exit(66);
  }

  final original = optionsFile.readAsStringSync();
  final record = <String, Object?>{};
  try {
    stateDir.createSync(recursive: true);

    // 1) 전체 실행
    optionsFile.writeAsStringSync(okOptions);
    final all = await runAnalyze(fixtureDir, stateDir);
    final pluginVersion = readResolvedPluginVersion(stateDir);
    stdout.writeln('Dart ${Platform.version.split(' ').first}, riverpod_lint $pluginVersion');
    stdout.writeln('');
    stdout.writeln('전체 실행: exit ${all.exitCode}, 진단 ${all.diagnostics.length}건 '
        '(plugin ${all.plugin.length}건), stderr ${all.stderrText.isEmpty ? '없음' : '있음'}');
    final others = all.diagnostics.where((d) => !d.isPlugin).toList();
    for (final d in others) {
      stdout.writeln('  plugin 밖 진단: ${d.file}:${d.line} ${d.severity} ${d.code}');
    }
    final missing = ruleNames.where((n) => !all.plugin.any((d) => d.bareCode == n)).toList();
    stdout.writeln('  나오지 않은 규칙: ${missing.isEmpty ? '없음' : missing.join(', ')}');
    stdout.writeln('');

    // 2) 규칙 하나씩
    stdout.writeln('| 규칙 | severity | type | code 표기 | 위치 | 이 규칙만 켰을 때 exit | 그때 plugin 진단 |');
    stdout.writeln('|---|---|---|---|---|---|---|');
    final perRule = <String, Object?>{};
    for (final name in ruleNames) {
      final hits = all.plugin.where((d) => d.bareCode == name).toList();
      optionsFile.writeAsStringSync(buildOptions({name}));
      final solo = await runAnalyze(fixtureDir, stateDir);
      final soloCodes = solo.plugin.map((d) => d.bareCode).toSet().join(', ');
      final first = hits.isEmpty ? null : hits.first;
      stdout.writeln('| `$name` | ${first?.severity ?? '-'} | ${first?.type ?? '-'} | '
          '`${first?.code ?? '-'}` | ${first == null ? '-' : '${first.file}:${first.line}'} | '
          '${solo.exitCode} | ${soloCodes.isEmpty ? '(없음)' : soloCodes} |');
      perRule[name] = {
        'severity': first?.severity,
        'type': first?.type,
        'code': first?.code,
        'location': first == null ? null : '${first.file}:${first.line}',
        'hitsInFullRun': hits.length,
        'soloExitCode': solo.exitCode,
        'soloPluginCodes': solo.plugin.map((d) => d.code).toList(),
        'soloStderr': solo.stderrText,
      };
    }

    // 3) 전부 끔
    optionsFile.writeAsStringSync(buildOptions(const {}));
    final none = await runAnalyze(fixtureDir, stateDir);
    stdout.writeln('');
    stdout.writeln('15개 모두 끔: exit ${none.exitCode}, 진단 ${none.diagnostics.length}건 '
        '(plugin ${none.plugin.length}건)');

    record
      ..['dart'] = Platform.version.split(' ').first
      ..['riverpodLint'] = pluginVersion
      ..['fullRun'] = {
        'exitCode': all.exitCode,
        'stderr': all.stderrText,
        'lines': [
          for (final d in all.diagnostics)
            '${d.file}:${d.line}  ${d.severity.toLowerCase()}  ${d.code}',
        ]..sort(),
      }
      ..['perRule'] = perRule
      ..['allDisabled'] = {
        'exitCode': none.exitCode,
        'pluginDiagnostics': none.plugin.length,
        'diagnostics': none.diagnostics.length,
      };
    final resultsFile = File('${spikeDir.path}/results/severity_matrix.json');
    resultsFile.parent.createSync(recursive: true);
    resultsFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(record)}\n');
    stdout.writeln('');
    stdout.writeln('원본 결과: ${resultsFile.path}');
  } on FileSystemException catch (e) {
    stderr.writeln('파일 작업 실패: ${e.message} (${e.path})');
    exitCode = 74;
  } on ProcessException catch (e) {
    stderr.writeln('프로세스를 띄우지 못했다: $e');
    exitCode = 70;
  } finally {
    // 어떤 경우에도 연습용 프로젝트의 옵션 파일을 원래대로 돌려놓는다.
    optionsFile.writeAsStringSync(original);
  }
}
