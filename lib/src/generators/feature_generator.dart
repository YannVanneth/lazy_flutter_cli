import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

class FeatureGenerator {
  final Logger logger;

  FeatureGenerator(this.logger);

  void generate(String rawFeatureName, {String? targetDir}) {
    final rc = ReCase(rawFeatureName);
    final featureName = rc.snakeCase;
    final className = rc.pascalCase;

    final projectRoot = targetDir ?? Directory.current.path;
    final libPath = p.join(projectRoot, 'lib');

    if (!Directory(libPath).existsSync()) {
      logger.err('No lib/ directory found in $projectRoot. Please run this command inside a Flutter project.');
      return;
    }

    final featurePath = p.join(libPath, 'features', featureName);
    final progress = logger.progress('Generating feature module "$featureName"...');

    try {
      // 1. Data Layer
      _createDir(p.join(featurePath, 'data', 'datasources'));
      _createDir(p.join(featurePath, 'data', 'models'));
      _createDir(p.join(featurePath, 'data', 'repositories'));

      // 2. Domain Layer
      _createDir(p.join(featurePath, 'domain', 'entities'));
      _createDir(p.join(featurePath, 'domain', 'repositories'));
      _createDir(p.join(featurePath, 'domain', 'usecases'));

      // 3. Presentation Layer
      _createDir(p.join(featurePath, 'presentation', 'controllers'));
      _createDir(p.join(featurePath, 'presentation', 'pages'));
      _createDir(p.join(featurePath, 'presentation', 'widgets'));

      // 4. Generate files
      _createFile(
        p.join(featurePath, 'domain', 'repositories', '${featureName}_repository.dart'),
        '''abstract class ${className}Repository {
  Future<void> get${className}Data();
}
''',
      );

      _createFile(
        p.join(featurePath, 'domain', 'usecases', 'get_${featureName}_usecase.dart'),
        '''import '../repositories/${featureName}_repository.dart';

class Get${className}UseCase {
  final ${className}Repository repository;

  Get${className}UseCase(this.repository);

  Future<void> execute() async {
    return repository.get${className}Data();
  }
}
''',
      );

      _createFile(
        p.join(featurePath, 'data', 'repositories', '${featureName}_repository_impl.dart'),
        '''import '../../domain/repositories/${featureName}_repository.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  @override
  Future<void> get${className}Data() async {
    // Implementation details
  }
}
''',
      );

      _createFile(
        p.join(featurePath, 'presentation', 'pages', '${featureName}_page.dart'),
        '''import 'package:flutter/material.dart';

class ${className}Page extends StatelessWidget {
  const ${className}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$className'),
      ),
      body: const Center(
        child: Text('$className Feature Page'),
      ),
    );
  }
}
''',
      );

      progress.complete('Generated feature "$featureName" successfully!');
      logger.info('');
      logger.info(lightGreen.wrap('✨ Feature "$featureName" created at lib/features/$featureName')!);
      logger.info('');
    } catch (e, stack) {
      progress.fail('Failed to generate feature: $e');
      logger.err(stack.toString());
    }
  }

  void _createDir(String path) {
    Directory(path).createSync(recursive: true);
  }

  void _createFile(String path, String content) {
    File(path).writeAsStringSync(content);
  }
}
