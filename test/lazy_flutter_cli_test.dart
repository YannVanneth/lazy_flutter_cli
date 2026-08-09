import 'dart:io';
import 'package:lazy_flutter_cli/lazy_flutter_cli.dart';
import 'package:lazy_flutter_cli/src/generators/feature_generator.dart';
import 'package:lazy_flutter_cli/src/generators/project_scaffolder.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('LazyCliRunner', () {
    test('prints version when --version flag is provided', () async {
      final runner = LazyCliRunner();
      final code = await runner.run(['--version']);
      expect(code, equals(0));
    });
  });

  group('ProjectScaffolder', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('lazy_cli_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('scaffolds Clean Architecture project successfully', () async {
      final logger = Logger(level: Level.quiet);
      final scaffolder = ProjectScaffolder(logger);
      final config = const ProjectConfig(
        projectName: 'demo_app',
        architecture: Architecture.clean,
        stateManagement: StateManagement.bloc,
        router: AppRouter.goRouter,
      );

      await scaffolder.scaffold(config, targetDir: tempDir.path);

      expect(File(p.join(tempDir.path, 'pubspec.yaml')).existsSync(), isTrue);
      expect(File(p.join(tempDir.path, 'lib', 'main.dart')).existsSync(), isTrue);
      expect(Directory(p.join(tempDir.path, 'lib', 'features', 'home', 'data')).existsSync(), isTrue);
      expect(Directory(p.join(tempDir.path, 'lib', 'features', 'home', 'domain')).existsSync(), isTrue);
      expect(Directory(p.join(tempDir.path, 'lib', 'features', 'home', 'presentation')).existsSync(), isTrue);
    });
  });

  group('FeatureGenerator', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('lazy_cli_feature_');
      Directory(p.join(tempDir.path, 'lib')).createSync(recursive: true);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('generates feature folders and files', () {
      final logger = Logger(level: Level.quiet);
      final generator = FeatureGenerator(logger);

      generator.generate('authentication', targetDir: tempDir.path);

      final featurePath = p.join(tempDir.path, 'lib', 'features', 'authentication');
      expect(Directory(featurePath).existsSync(), isTrue);
      expect(File(p.join(featurePath, 'domain', 'usecases', 'get_authentication_usecase.dart')).existsSync(), isTrue);
      expect(File(p.join(featurePath, 'presentation', 'pages', 'authentication_page.dart')).existsSync(), isTrue);
    });
  });
}
