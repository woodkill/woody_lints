// spike 001 후속 — 같은 `dart analyze` 가 가끔 종료 코드 255 로 죽는 현상을 세어 본다.
//
// 실행: fvm dart run .planning/spikes/001-analyze-invocation-form/flaky.dart <상태 폴더> [반복 횟수] [cold]
//
// 세 번째 인자로 `cold` 를 주면 실행마다 빈 상태 폴더에서 시작한다 (plugin 을 매번 새로 준비).
//
// 세 가지 방식을 번갈아 돌린다 (시간대에 따른 치우침을 줄이려고 섞는다).
//   1) 기본:  dart analyze --format=json
//   2) 환경변수: DASH__SUPPRESS_ANALYTICS=true dart analyze --format=json
//   3) 플래그: dart --suppress-analytics analyze --format=json
import 'dart:convert';
import 'dart:io';

/// 비교할 실행 방식 하나.
class Mode {
  /// [label] 은 표에 찍을 이름, [globalArguments] 는 `analyze` 앞에 붙는 전역 인자,
  /// [environment] 는 더할 환경변수다.
  const Mode(this.label, this.globalArguments, this.environment);

  /// 표에 찍을 이름.
  final String label;

  /// `dart` 와 `analyze` 사이에 넣을 전역 인자.
  final List<String> globalArguments;

  /// 추가로 넘길 환경변수.
  final Map<String, String> environment;
}

/// 방식 하나의 누적 결과.
class Tally {
  /// 종료 코드별 횟수.
  final Map<int, int> exitCodes = {};

  /// 진단 4건이 모두 나온 횟수.
  int complete = 0;

  /// 종료 코드 255 일 때 stderr 의 첫 줄들 (중복 제거).
  final Set<String> crashHeads = {};
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('사용법: dart run flaky.dart <상태 폴더> [반복 횟수] [cold]');
    exit(64);
  }
  final stateDir = Directory(args[0]);
  final repeat = args.length > 1 ? int.tryParse(args[1]) ?? 20 : 20;
  final cold = args.length > 2 && args[2] == 'cold';

  final spikeDir = File.fromUri(Platform.script).parent;
  final fixtureDir = Directory('${spikeDir.path}/fixture').absolute.path;
  if (!File('$fixtureDir/.dart_tool/package_config.json').existsSync()) {
    stderr.writeln('연습용 프로젝트에 패키지가 없다. 먼저 실행: (cd $fixtureDir && fvm dart pub get)');
    exit(66);
  }
  try {
    stateDir.createSync(recursive: true);
  } on FileSystemException catch (e) {
    stderr.writeln('상태 폴더를 만들지 못했다: ${e.message}');
    exit(73);
  }

  const modes = [
    Mode('기본', [], {}),
    Mode('환경변수 DASH__SUPPRESS_ANALYTICS=true', [], {'DASH__SUPPRESS_ANALYTICS': 'true'}),
    Mode('플래그 --suppress-analytics', ['--suppress-analytics'], {}),
  ];
  final tallies = {for (final m in modes) m.label: Tally()};
  const expectedDiagnostics = 4;

  var runIndex = 0;
  for (var n = 1; n <= repeat; n++) {
    for (final mode in modes) {
      runIndex++;
      // cold 면 실행마다 새 폴더를 쓴다. 아니면 하나를 계속 쓴다 (warm).
      final runState = cold ? Directory('${stateDir.path}/run-$runIndex') : stateDir;
      final ProcessResult result;
      try {
        if (cold) {
          if (runState.existsSync()) runState.deleteSync(recursive: true);
          runState.createSync(recursive: true);
        }
        result = await Process.run(
          Platform.resolvedExecutable,
          [...mode.globalArguments, 'analyze', '--format=json'],
          workingDirectory: fixtureDir,
          environment: {
            'ANALYZER_STATE_LOCATION_OVERRIDE': runState.path,
            ...mode.environment,
          },
        );
      } on ProcessException catch (e) {
        stderr.writeln('프로세스를 띄우지 못했다: $e');
        exit(70);
      } on FileSystemException catch (e) {
        stderr.writeln('상태 폴더를 준비하지 못했다: ${e.message}');
        exit(73);
      }
      final tally = tallies[mode.label]!;
      tally.exitCodes.update(result.exitCode, (v) => v + 1, ifAbsent: () => 1);

      var count = -1;
      try {
        final decoded = jsonDecode((result.stdout as String).trim());
        count = ((decoded as Map<String, dynamic>)['diagnostics'] as List).length;
      } on FormatException {
        // 죽은 실행은 JSON 을 내지 않는다. count 는 -1 로 둔다.
      }
      if (count == expectedDiagnostics) tally.complete++;
      if (result.exitCode == 255) {
        final lines = (result.stderr as String).trim().split('\n');
        tally.crashHeads.add(lines.take(2).join(' / '));
      }
      stdout.writeln('#$n ${mode.label}: exit=${result.exitCode} 진단=$count');
    }
  }

  stdout.writeln('');
  stdout.writeln('상태: ${cold ? 'cold (실행마다 빈 상태 폴더)' : 'warm (상태 폴더 하나를 계속 사용, 첫 실행만 cold)'}');
  stdout.writeln('');
  stdout.writeln('| 방식 | 실행 | 진단 4건 모두 | 종료 코드별 횟수 | 죽었을 때 stderr 첫 줄 |');
  stdout.writeln('|---|---|---|---|---|');
  for (final mode in modes) {
    final t = tallies[mode.label]!;
    final codes = (t.exitCodes.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
        .map((e) => 'exit ${e.key} × ${e.value}')
        .join(', ');
    final heads = t.crashHeads.isEmpty ? '-' : t.crashHeads.join(' ; ');
    stdout.writeln('| ${mode.label} | $repeat | ${t.complete} | $codes | $heads |');
  }
}
