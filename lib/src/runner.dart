import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'commands/create_command.dart';
import 'commands/generate_command.dart';

class LazyCliRunner extends CommandRunner<int> {
  final Logger logger;

  LazyCliRunner({Logger? logger})
      : logger = logger ?? Logger(),
        super(
          'lazy',
          'An interactive CLI tool for Flutter developers to scaffold projects and generate features.',
        ) {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the current version of lazy_flutter_cli.',
    );

    addCommand(CreateCommand(this.logger));
    addCommand(GenerateCommand(this.logger));
  }

  @override
  Future<int?> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);
      if (argResults['version'] == true) {
        logger.info('lazy_flutter_cli version 1.0.0');
        return ExitCode.success.code;
      }
      return await runCommand(argResults);
    } on UsageException catch (e) {
      logger.err(e.message);
      logger.info('');
      logger.info(e.usage);
      return ExitCode.usage.code;
    } catch (e) {
      logger.err(e.toString());
      return ExitCode.software.code;
    }
  }
}
