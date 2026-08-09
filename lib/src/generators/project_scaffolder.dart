import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import '../models/project_config.dart';

class ProjectScaffolder {
  final Logger logger;

  ProjectScaffolder(this.logger);

  Future<void> scaffold(ProjectConfig config, {String? targetDir}) async {
    final rootPath = targetDir ?? p.join(Directory.current.path, config.projectName);
    final projectDir = Directory(rootPath);

    if (projectDir.existsSync() && projectDir.listSync().isNotEmpty) {
      logger.err('Target directory "${config.projectName}" is not empty!');
      return;
    }

    final progress = logger.progress('Creating Flutter project "${config.projectName}"...');

    try {
      // 1. Create root directory & base folders
      projectDir.createSync(recursive: true);

      // 2. Create assets directories
      _createDir(p.join(rootPath, 'assets', 'images'));
      _createDir(p.join(rootPath, 'assets', 'icons'));
      _createDir(p.join(rootPath, 'assets', 'json'));
      _createFile(p.join(rootPath, 'assets', 'json', 'config.json'), '{\n  "appName": "${config.projectName}"\n}\n');

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

      progress.complete('Scaffolded project "${config.projectName}" successfully!');

      logger.info('');
      logger.info(lightGreen.wrap('🎉 Success! Created ${config.projectName} at $rootPath')!);
      logger.info('');
      logger.info('Architecture: ${config.architectureName}');
      logger.info('State Management: ${config.stateManagementName}');
      logger.info('Router: ${config.routerName}');
      logger.info('');
      logger.info('Inside that directory, you can run:');
      logger.info(cyan.wrap('  cd ${config.projectName}')!);
      logger.info(cyan.wrap('  flutter pub get')!);
      logger.info(cyan.wrap('  lazy g feature authentication')!);
      logger.info('');
    } catch (e, stack) {
      progress.fail('Failed to scaffold project: $e');
      logger.err(stack.toString());
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
    buffer.writeln('description: A new Flutter project created with lazy_flutter_cli.');
    buffer.writeln('publish_to: "none"');
    buffer.writeln('version: 1.0.0+1\n');
    buffer.writeln('environment:');
    buffer.writeln('  sdk: ">=3.0.0 <4.0.0"\n');
    buffer.writeln('dependencies:');
    buffer.writeln('  flutter:');
    buffer.writeln('    sdk: flutter');
    buffer.writeln('  cupertino_icons: ^1.0.8');

    if (config.stateManagement == StateManagement.bloc) {
      buffer.writeln('  flutter_bloc: ^8.1.6');
    } else if (config.stateManagement == StateManagement.riverpod) {
      buffer.writeln('  flutter_riverpod: ^2.5.1');
    } else if (config.stateManagement == StateManagement.provider) {
      buffer.writeln('  provider: ^6.1.2');
    } else if (config.stateManagement == StateManagement.getx) {
      buffer.writeln('  get: ^4.6.6');
    }

    if (config.router == AppRouter.goRouter) {
      buffer.writeln('  go_router: ^14.2.0');
    } else if (config.router == AppRouter.autoRoute) {
      buffer.writeln('  auto_route: ^9.0.0');
    }

    if (config.useDio) {
      buffer.writeln('  dio: ^5.5.0');
    }
    if (config.useGetIt) {
      buffer.writeln('  get_it: ^7.7.0');
    }
    if (config.useLazyAssetGenerator) {
      buffer.writeln('  lazy_asset_generator: ^1.4.1');
    }

    buffer.writeln('\ndev_dependencies:');
    buffer.writeln('  flutter_test:');
    buffer.writeln('    sdk: flutter');
    buffer.writeln('  flutter_lints: ^5.0.0');

    if (config.useLazyAssetGenerator) {
      buffer.writeln('  build_runner: ^2.4.13');
    }

    buffer.writeln('\nflutter:');
    buffer.writeln('  uses-material-design: true');
    buffer.writeln('  assets:');
    buffer.writeln('    - assets/images/');
    buffer.writeln('    - assets/icons/');
    buffer.writeln('    - assets/json/');

    _createFile(p.join(rootPath, 'pubspec.yaml'), buffer.toString());
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
    File(path).writeAsStringSync(content);
  }
}
