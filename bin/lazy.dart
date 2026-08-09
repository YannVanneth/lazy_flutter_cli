import 'dart:io';
import 'package:lazy_flutter_cli/lazy_flutter_cli.dart';

Future<void> main(List<String> args) async {
  final runner = LazyCliRunner();
  final exitCode = await runner.run(args) ?? 0;
  exit(exitCode);
}
