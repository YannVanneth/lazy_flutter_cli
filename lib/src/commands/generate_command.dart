import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import '../generators/feature_generator.dart';

class GenerateCommand extends Command<int> {
  final Logger logger;

  @override
  final String name = 'generate';

  @override
  final List<String> aliases = ['g'];

  @override
  final String description = 'Generate features or models inside your Flutter project.';

  GenerateCommand(this.logger) {
    addSubcommand(GenerateFeatureSubCommand(logger));
  }
}

class GenerateFeatureSubCommand extends Command<int> {
  final Logger logger;

  @override
  final String name = 'feature';

  @override
  final String description = 'Generate a new feature module (e.g. lazy g feature auth).';

  GenerateFeatureSubCommand(this.logger);

  @override
  Future<int> run() async {
    final args = argResults?.rest ?? [];
    if (args.isEmpty) {
      logger.err('Please provide a feature name (e.g. lazy g feature user_profile).');
      return ExitCode.usage.code;
    }

    final featureName = args.first;
    final generator = FeatureGenerator(logger);
    generator.generate(featureName);

    return ExitCode.success.code;
  }
}
