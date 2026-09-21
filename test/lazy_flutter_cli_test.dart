import 'dart:io';
import 'package:lazy_flutter_cli/lazy_flutter_cli.dart';
import 'package:lazy_flutter_cli/src/generators/feature_generator.dart';
import 'package:lazy_flutter_cli/src/generators/project_scaffolder.dart';
import 'package:lazy_flutter_cli/src/package_resolver.dart';
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
      final scaffolder = ProjectScaffolder(
        logger,
        packageResolver: PackageResolver(
          processRunner: (executable, arguments, {workingDirectory}) async {
            return ProcessResult(1, 0, '', '');
          },
        ),
      );
      final config = const ProjectConfig(
        projectName: 'demo_app',
        architecture: Architecture.clean,
        stateManagement: StateManagement.bloc,
        router: AppRouter.goRouter,
      );

      final didScaffold =
          await scaffolder.scaffold(config, targetDir: tempDir.path);

      expect(didScaffold, isTrue);
      expect(File(p.join(tempDir.path, 'pubspec.yaml')).existsSync(), isTrue);
      expect(
          File(p.join(tempDir.path, 'lib', 'main.dart')).existsSync(), isTrue);
      expect(
          Directory(p.join(tempDir.path, 'lib', 'features', 'home', 'data'))
              .existsSync(),
          isTrue);
      expect(
          Directory(p.join(tempDir.path, 'lib', 'features', 'home', 'domain'))
              .existsSync(),
          isTrue);
      expect(
          Directory(p.join(
                  tempDir.path, 'lib', 'features', 'home', 'presentation'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(tempDir.path, 'analysis_options.yaml'))
              .readAsStringSync(),
          contains('package:flutter_lints/flutter.yaml'));
      expect(
          File(p.join(tempDir.path, 'test', 'widget_test.dart')).existsSync(),
          isTrue);
      expect(
          File(p.join(tempDir.path, '.vscode', 'settings.json')).existsSync(),
          isTrue);
      expect(File(p.join(tempDir.path, '.vscode', 'launch.json')).existsSync(),
          isTrue);
      expect(File(p.join(tempDir.path, '.gitignore')).existsSync(), isTrue);
      expect(
        File(p.join(tempDir.path, 'tool', 'verify.dart')).readAsStringSync(),
        contains('Process.run(check.\$1, check.\$2)'),
      );
    });

    test('resolves selected packages with flutter pub add', () async {
      final logger = Logger(level: Level.quiet);
      final commands = <List<String>>[];
      final parentDir =
          Directory.systemTemp.createTempSync('lazy_cli_resolution_');
      addTearDown(() => parentDir.deleteSync(recursive: true));
      final projectDir = p.join(parentDir.path, 'demo_app');
      final scaffolder = ProjectScaffolder(
        logger,
        packageResolver: PackageResolver(
          processRunner: (executable, arguments, {workingDirectory}) async {
            commands.add([executable, ...arguments]);
            return ProcessResult(1, 0, '', '');
          },
        ),
      );

      final didScaffold = await scaffolder.scaffold(
        const ProjectConfig(
          projectName: 'demo_app',
          architecture: Architecture.clean,
          stateManagement: StateManagement.riverpod,
          router: AppRouter.standard,
          useDio: false,
          useLazyAssetGenerator: false,
          useGetIt: false,
        ),
        targetDir: projectDir,
      );

      expect(didScaffold, isTrue);
      expect(
        commands,
        equals([
          ['flutter', 'pub', 'add', 'cupertino_icons'],
          ['flutter', 'pub', 'add', 'flutter_riverpod'],
          ['flutter', 'pub', 'add', 'dev:flutter_lints'],
        ]),
      );
    });

    test('cleans up a newly created project when package resolution fails',
        () async {
      final logger = Logger(level: Level.quiet);
      final parentDir =
          Directory.systemTemp.createTempSync('lazy_cli_cleanup_');
      addTearDown(() => parentDir.deleteSync(recursive: true));
      final projectDir = Directory(p.join(parentDir.path, 'demo_app'));
      final scaffolder = ProjectScaffolder(
        logger,
        packageResolver: PackageResolver(
          processRunner: (executable, arguments, {workingDirectory}) async {
            return ProcessResult(1, 1, '', 'network unavailable');
          },
        ),
      );

      final didScaffold = await scaffolder.scaffold(
        const ProjectConfig(
          projectName: 'demo_app',
          architecture: Architecture.clean,
          stateManagement: StateManagement.bloc,
          router: AppRouter.goRouter,
        ),
        targetDir: projectDir.path,
      );

      expect(didScaffold, isFalse);
      expect(projectDir.existsSync(), isFalse);
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

      final featurePath =
          p.join(tempDir.path, 'lib', 'features', 'authentication');
      expect(Directory(featurePath).existsSync(), isTrue);
      expect(
          File(p.join(featurePath, 'domain', 'usecases',
                  'get_authentication_usecase.dart'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(featurePath, 'presentation', 'pages',
                  'authentication_page.dart'))
              .existsSync(),
          isTrue);
    });
  });
}
