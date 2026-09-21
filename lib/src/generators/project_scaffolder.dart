import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import '../models/project_config.dart';
import '../package_resolver.dart';

class ProjectScaffolder {
  final Logger logger;
  final PackageResolver packageResolver;

  ProjectScaffolder(this.logger, {PackageResolver? packageResolver})
      : packageResolver = packageResolver ?? PackageResolver();

  Future<bool> scaffold(ProjectConfig config, {String? targetDir}) async {
    final rootPath =
        targetDir ?? p.join(Directory.current.path, config.projectName);
    final projectDir = Directory(rootPath);

    if (projectDir.existsSync() && projectDir.listSync().isNotEmpty) {
      logger.err('Target directory "${config.projectName}" is not empty!');
      return false;
    }

    final createdProjectDirectory = !projectDir.existsSync();
    final progress =
        logger.progress('Creating Flutter project "${config.projectName}"...');

    try {
      // 1. Create root directory & base folders
      projectDir.createSync(recursive: true);

      // 2. Create assets directories
      _createDir(p.join(rootPath, 'assets', 'images'));
      _createDir(p.join(rootPath, 'assets', 'icons'));
      _createDir(p.join(rootPath, 'assets', 'json'));
      _createFile(p.join(rootPath, 'assets', 'json', 'config.json'),
          '{\n  "appName": "${config.projectName}"\n}\n');

      // 3. Create architecture folders under lib/
      final libPath = p.join(rootPath, 'lib');
      _createDir(libPath);

      if (config.architecture == Architecture.clean) {
        _scaffoldCleanArch(libPath, config);
      } else if (config.architecture == Architecture.mvvm) {
        _scaffoldMVVM(libPath, config);
      } else {
        _scaffoldFeatureFirst(libPath, config);
      }

      // 4. Create pubspec.yaml
      _generatePubspec(rootPath, config);

      // 5. Create README.md
      _generateReadme(rootPath, config);

      // 6. Create main.dart & app.dart
      _generateMainApp(libPath, config);

      // 7. Add project quality-of-life files.
      _generateDeveloperTooling(rootPath, config);

      // 8. Resolve the newest compatible package versions from pub.dev.
      progress.update('Resolving latest compatible package versions...');
      await packageResolver.resolve(
        config,
        rootPath,
        onPackageResolving: (package, dev) {
          progress
              .update('Resolving ${dev ? 'dev ' : ''}dependency: $package...');
        },
      );

      progress
          .complete('Scaffolded project "${config.projectName}" successfully!');

      logger.info('');
      logger.info(lightGreen
          .wrap('🎉 Success! Created ${config.projectName} at $rootPath')!);
      logger.info('');
      logger.info('Architecture: ${config.architectureName}');
      logger.info('State Management: ${config.stateManagementName}');
      logger.info('Router: ${config.routerName}');
      logger.info('Dependencies: latest SDK-compatible versions');
      logger.info('');
      logger.info('Inside that directory, you can run:');
      logger.info(cyan.wrap('  cd ${config.projectName}')!);
      logger.info(cyan.wrap('  flutter analyze')!);
      logger.info(cyan.wrap('  flutter test')!);
      logger.info(cyan.wrap('  dart run tool/verify.dart')!);
      logger.info(cyan.wrap('  lazy g feature authentication')!);
      logger.info('');
      return true;
    } catch (e, stack) {
      if (createdProjectDirectory && projectDir.existsSync()) {
        try {
          projectDir.deleteSync(recursive: true);
        } catch (cleanupError) {
          logger.err(
              'Could not clean up the incomplete project directory: $cleanupError');
        }
      }
      progress.fail('Failed to scaffold project: $e');
      if (e is PackageResolutionException) {
        logger.err(
            '${e.message}\nCheck that Flutter is installed and that pub.dev is reachable.');
      } else {
        logger.err(stack.toString());
      }
      return false;
    }
  }

  void _scaffoldCleanArch(String libPath, ProjectConfig config) {
    _createDir(p.join(libPath, 'core', 'constants'));
    _createDir(p.join(libPath, 'core', 'network'));
    _createDir(p.join(libPath, 'core', 'theme'));
    _createDir(p.join(libPath, 'core', 'utils'));
    _createDir(p.join(libPath, 'features', 'home', 'data', 'models'));
    _createDir(p.join(libPath, 'features', 'home', 'data', 'repositories'));
    _createDir(p.join(libPath, 'features', 'home', 'domain', 'repositories'));
    _createDir(p.join(libPath, 'features', 'home', 'domain', 'usecases'));
    _createDir(p.join(libPath, 'features', 'home', 'presentation', 'pages'));
    _createDir(p.join(libPath, 'features', 'home', 'presentation', 'widgets'));

    if (config.useDio) {
      _createFile(
        p.join(libPath, 'core', 'network', 'api_client.dart'),
        '''import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
}
''',
      );
    }
  }

  void _scaffoldMVVM(String libPath, ProjectConfig config) {
    _createDir(p.join(libPath, 'models'));
    _createDir(p.join(libPath, 'views'));
    _createDir(p.join(libPath, 'viewmodels'));
    _createDir(p.join(libPath, 'services'));
  }

  void _scaffoldFeatureFirst(String libPath, ProjectConfig config) {
    _createDir(p.join(libPath, 'src', 'features', 'home'));
    _createDir(p.join(libPath, 'src', 'common_widgets'));
    _createDir(p.join(libPath, 'src', 'constants'));
  }

  void _generatePubspec(String rootPath, ProjectConfig config) {
    final buffer = StringBuffer();
    buffer.writeln('name: ${config.projectName}');
    buffer.writeln(
        'description: A new Flutter project created with lazy_flutter_cli.');
    buffer.writeln('publish_to: "none"');
    buffer.writeln('version: 1.0.0+1\n');
    buffer.writeln('environment:');
    buffer.writeln('  sdk: ">=3.0.0 <4.0.0"\n');
    buffer.writeln('dependencies:');
    buffer.writeln('  flutter:');
    buffer.writeln('    sdk: flutter');

    buffer.writeln('\ndev_dependencies:');
    buffer.writeln('  flutter_test:');
    buffer.writeln('    sdk: flutter');

    buffer.writeln('\nflutter:');
    buffer.writeln('  uses-material-design: true');
    buffer.writeln('  assets:');
    buffer.writeln('    - assets/images/');
    buffer.writeln('    - assets/icons/');
    buffer.writeln('    - assets/json/');

    _createFile(p.join(rootPath, 'pubspec.yaml'), buffer.toString());
  }

  void _generateDeveloperTooling(String rootPath, ProjectConfig config) {
    _generateAnalysisOptions(rootPath, config);
    _generateStarterTest(rootPath, config);
    _generateVsCodeFiles(rootPath, config);
    _generateGitignore(rootPath);
    _generateVerificationScript(rootPath);
  }

  void _generateAnalysisOptions(String rootPath, ProjectConfig config) {
    final content = config.useStrictLints
        ? '''include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - .dart_tool/**
'''
        : '''analyzer:
  exclude:
    - build/**
    - .dart_tool/**

linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
    prefer_const_declarations: true
''';
    _createFile(p.join(rootPath, 'analysis_options.yaml'), content);
  }

  void _generateStarterTest(String rootPath, ProjectConfig config) {
    _createFile(
      p.join(rootPath, 'test', 'widget_test.dart'),
      '''import 'package:flutter_test/flutter_test.dart';
import 'package:${config.projectName}/main.dart';

void main() {
  testWidgets('shows the welcome screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome to ${config.projectName}!'), findsOneWidget);
  });
}
''',
    );
  }

  void _generateVsCodeFiles(String rootPath, ProjectConfig config) {
    _createFile(
      p.join(rootPath, '.vscode', 'settings.json'),
      '''{
  "editor.formatOnSave": true,
  "dart.lineLength": 100,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true
  }
}
''',
    );
    _createFile(
      p.join(rootPath, '.vscode', 'launch.json'),
      '''{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "${config.projectName}",
      "type": "dart",
      "request": "launch"
    }
  ]
}
''',
    );
  }

  void _generateGitignore(String rootPath) {
    _createFile(
      p.join(rootPath, '.gitignore'),
      '''.dart_tool/
.packages
.pub/
build/
coverage/
*.log

.idea/
*.iml

android/.gradle/
android/local.properties
ios/Pods/

macos/Pods/
''',
    );
  }

  void _generateVerificationScript(String rootPath) {
    _createFile(
      p.join(rootPath, 'tool', 'verify.dart'),
      '''import 'dart:io';

Future<void> main() async {
  final checks = [
    ('dart', ['format', '--set-exit-if-changed', 'lib', 'test']),
    ('flutter', ['analyze']),
    ('flutter', ['test']),
  ];

  for (final check in checks) {
    stdout.writeln('\\n> \${check.\$1} \${check.\$2.join(' ')}');
    final result = await Process.run(check.\$1, check.\$2);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      exit(result.exitCode);
    }
  }

  stdout.writeln('\\nAll checks passed.');
}
''',
    );
  }

  void _generateReadme(String rootPath, ProjectConfig config) {
    _createFile(
      p.join(rootPath, 'README.md'),
      '''# ${config.projectName}

A new Flutter project scaffolded using **`lazy_flutter_cli`**.

- **Architecture**: ${config.architectureName}
- **State Management**: ${config.stateManagementName}
- **Router**: ${config.routerName}

## Getting Started

```bash
flutter pub get
flutter run
```

Dependencies were resolved to the latest versions compatible with the installed
Flutter/Dart SDK during project creation.

## Developer Workflow

Format, analyze, and test the project together:
```bash
dart run tool/verify.dart
```

The project includes strict lint rules, a starter widget test, and VS Code
format-on-save settings.

Generate new feature modules:
```bash
lazy g feature <feature_name>
```
''',
    );
  }

  void _generateMainApp(String libPath, ProjectConfig config) {
    _createFile(
      p.join(libPath, 'main.dart'),
      '''import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${config.projectName}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to ${config.projectName}!'),
        ),
      ),
    );
  }
}
''',
    );
  }

  void _createDir(String path) {
    Directory(path).createSync(recursive: true);
  }

  void _createFile(String path, String content) {
    File(path).parent.createSync(recursive: true);
    File(path).writeAsStringSync(content);
  }
}
