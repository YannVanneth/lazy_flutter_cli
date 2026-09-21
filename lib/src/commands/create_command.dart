import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import '../generators/project_scaffolder.dart';
import '../interactive/prompts.dart';
import '../models/project_config.dart';

class CreateCommand extends Command<int> {
  final Logger logger;

  @override
  final String name = 'create';

  @override
  final String description = 'Scaffold a new Flutter project interactively or with flags.';

  CreateCommand(this.logger) {
    argParser
      ..addOption(
        'arch',
        abbr: 'a',
        help: 'Architecture pattern (clean, mvvm, feature_first).',
        allowed: ['clean', 'mvvm', 'feature_first'],
      )
      ..addOption(
        'state',
        abbr: 's',
        help: 'State management solution (bloc, riverpod, provider, getx).',
        allowed: ['bloc', 'riverpod', 'provider', 'getx'],
      )
      ..addOption(
        'router',
        abbr: 'r',
        help: 'Routing solution (go_router, auto_route, standard).',
        allowed: ['go_router', 'auto_route', 'standard'],
      )
      ..addFlag('dio', help: 'Include Dio network client.', defaultsTo: true)
      ..addFlag('lazy-assets', help: 'Include lazy_asset_generator.', defaultsTo: true)
      ..addFlag('getit', help: 'Include GetIt dependency injection.', defaultsTo: true)
      ..addFlag('lints', help: 'Include strict Flutter lints.', defaultsTo: true);
  }

  @override
  Future<int> run() async {
    final args = argResults?.rest ?? [];
    final initialName = args.isNotEmpty ? args.first : null;

    final archArg = argResults?['arch'] as String?;
    final stateArg = argResults?['state'] as String?;
    final routerArg = argResults?['router'] as String?;

    ProjectConfig config;

    if (archArg != null || stateArg != null || routerArg != null) {
      // Flag-driven mode
      final name = initialName ?? 'my_app';
      final arch = archArg == 'mvvm'
          ? Architecture.mvvm
          : archArg == 'feature_first'
              ? Architecture.featureFirst
              : Architecture.clean;

      final state = stateArg == 'riverpod'
          ? StateManagement.riverpod
          : stateArg == 'provider'
              ? StateManagement.provider
              : stateArg == 'getx'
                  ? StateManagement.getx
                  : StateManagement.bloc;

      final router = routerArg == 'auto_route'
          ? AppRouter.autoRoute
          : routerArg == 'standard'
              ? AppRouter.standard
              : AppRouter.goRouter;

      config = ProjectConfig(
        projectName: name,
        architecture: arch,
        stateManagement: state,
        router: router,
        useDio: argResults?['dio'] as bool? ?? true,
        useLazyAssetGenerator: argResults?['lazy-assets'] as bool? ?? true,
        useGetIt: argResults?['getit'] as bool? ?? true,
        useStrictLints: argResults?['lints'] as bool? ?? true,
      );
    } else {
      // Next.js style interactive prompt mode
      final prompts = InteractivePrompts(logger);
      config = prompts.promptUser(initialName: initialName);
    }

    final scaffolder = ProjectScaffolder(logger);
    final didScaffold = await scaffolder.scaffold(config);
    return didScaffold ? ExitCode.success.code : ExitCode.software.code;
  }
}
