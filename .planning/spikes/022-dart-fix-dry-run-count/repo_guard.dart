// Spike 022 의 K5 (저장소가 그대로다) 가 깨진 원인을 가르는 대조.
//
// probe.dart 를 돌리는 동안 저장소 안에 다른 spike 의 폴더(023)를 새로 만들었다 — 그것이 `git status`
// 를 바꿨는지, 복사본의 `pub get` · `dart analyze` · `dart fix` 가 저장소를 바꿨는지를 가른다.
// 이 스크립트가 도는 동안에는 저장소를 건드리지 않는다.
//
// 실행 (저장소 루트에서):
//   fvm dart .planning/spikes/022-dart-fix-dry-run-count/repo_guard.dart <작업 폴더> <사용 프로젝트 원본>
import 'dart:convert';
import 'dart:io';

import '../021-new-rules-language-gate/consumer.dart';

Future<void> main(List<String> args) async {
  final spikeDir = File.fromUri(Platform.script).parent.path;
  final repo = Repo.fromSpikeDir(spikeDir);
  final work = Directory(args[0]).absolute.path;
  final consumer = Consumer(work: work, repo: repo, source: Directory(args[1]).resolveSymbolicLinksSync());
  final steps = <String, bool>{};
  var last = await repo.fingerprint();
  Future<void> step(String name, Future<void> Function() body) async {
    await body();
    final now = await repo.fingerprint();
    steps[name] = now == last;
    stdout.writeln('- $name: 저장소 ${now == last ? '그대로' : '**바뀜**'}');
    last = now;
  }

  final dart = Platform.resolvedExecutable;
  await step('복사와 pub get (path: 저장소)', () async {
    consumer.copy();
    await consumer.pointToRepo();
    consumer.addExampleMarkers();
  });
  await step('SDK 하한 ^3.13.0 으로 pub get', () => consumer.useSdk('^3.13.0'));
  await step('dart analyze', () async {
    consumer.setOptions(consumer.optionsWith(rules: ['use_primary_constructors', 'always_put_required_named_parameters_first']));
    await consumer.analyze('guard-analyze');
  });
  await step('dart fix --dry-run', () async {
    await Process.run(dart, ['--suppress-analytics', 'fix', '--dry-run'], workingDirectory: consumer.dir);
  });
  await step('dart fix --apply --code=use_primary_constructors', () async {
    await Process.run(dart, ['--suppress-analytics', 'fix', '--apply', '--code=use_primary_constructors'],
        workingDirectory: consumer.dir);
  });
  await step('원래 하한으로 pub get', () => consumer.useSdk(null));
  final ok = steps.values.every((v) => v);
  stdout.writeln(ok ? '모든 단계에서 저장소가 그대로였다.' : '저장소를 바꾼 단계가 있다.');
  final results = Directory('$spikeDir/results')..createSync(recursive: true);
  File('${results.path}/repo_guard-${Platform.version.split(' ').first}.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({'date': DateTime.now().toUtc().toIso8601String(), 'steps': steps}));
  exit(ok ? 0 : 1);
}
