import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// dispose 에서 읽을 provider.
final disposeTargetProvider = Provider<int>((ref) => 0);

/// `avoid_ref_inside_state_dispose` 를 일으키는 위젯.
class DisposeWidget extends ConsumerStatefulWidget {
  /// 위젯을 만든다.
  const DisposeWidget({super.key});

  @override
  ConsumerState<DisposeWidget> createState() => _DisposeWidgetState();
}

class _DisposeWidgetState extends ConsumerState<DisposeWidget> {
  @override
  void dispose() {
    ref.read(disposeTargetProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
