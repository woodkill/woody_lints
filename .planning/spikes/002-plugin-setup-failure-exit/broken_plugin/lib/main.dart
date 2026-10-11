// spike 002 — 일부러 문법을 틀린 plugin 진입점. 컴파일 단계에서 실패하게 만든다.
import 'package:analysis_server_plugin/plugin.dart';

final plugin = this is not dart;
