import 'package:mason_logger/mason_logger.dart';
import '../models/project_config.dart';
import 'terminal_selector.dart';

class InteractivePrompts {
  final Logger logger;
  late final TerminalSelector _selector;

  InteractivePrompts(this.logger) {
    _selector = TerminalSelector(logger);
  }

  ProjectConfig promptUser({String? initialName}) {
    logger.info('');
    logger.info(lightCyan.wrap('🚀 Welcome to Lazy Flutter CLI!')!);
    logger.info('');

    // 1. Project Name
    String name = initialName ?? '';
    while (name.trim().isEmpty) {
      name = logger.prompt(
        '✔ What is your project named?',
        defaultValue: 'my_awesome_app',
      );
    }
    name = name.trim().replaceAll('-', '_');

    // 2. Architecture Selection
    final archIndex = _selector.selectOne(
      message: 'Which architecture pattern would you like to use?',
      choices: [
        'Clean Architecture (Data / Domain / Presentation)',
        'MVVM (Model - View - ViewModel)',
        'Feature-First (Modular)',
      ],
      defaultValue: 'Clean Architecture (Data / Domain / Presentation)',
    );

    final architecture = archIndex.startsWith('Clean')
        ? Architecture.clean
        : archIndex.startsWith('MVVM')
            ? Architecture.mvvm
            : Architecture.featureFirst;

    // 3. State Management Selection
    final stateIndex = _selector.selectOne(
      message: 'Which state management solution would you like to use?',
      choices: [
        'Flutter BLoC / Cubit',
        'Riverpod',
        'Provider',
        'GetX',
      ],
      defaultValue: 'Flutter BLoC / Cubit',
    );

    final stateManagement = stateIndex.contains('BLoC')
        ? StateManagement.bloc
        : stateIndex.contains('Riverpod')
            ? StateManagement.riverpod
            : stateIndex.contains('Provider')
                ? StateManagement.provider
                : StateManagement.getx;

    // 4. Routing Solution Selection
    final routerChoice = _selector.selectOne(
      message: 'Which routing solution would you like to use?',
      choices: [
        'GoRouter',
        'AutoRoute',
        'Standard Navigator 2.0',
      ],
      defaultValue: 'GoRouter',
    );

    final router = routerChoice.contains('GoRouter')
        ? AppRouter.goRouter
        : routerChoice.contains('AutoRoute')
            ? AppRouter.autoRoute
            : AppRouter.standard;

    // 5. Feature Toggles
    final useDio = _selector.confirm(
      message: 'Would you like to include Dio network client & interceptors?',
      defaultValue: true,
    );

    final useLazyAssetGenerator = _selector.confirm(
      message: 'Would you like to include lazy_asset_generator for type-safe assets?',
      defaultValue: true,
    );

    final useGetIt = _selector.confirm(
      message: 'Would you like to include GetIt dependency injection?',
      defaultValue: true,
    );

    final useStrictLints = _selector.confirm(
      message: 'Would you like to enable strict Flutter lints?',
      defaultValue: true,
    );

    return ProjectConfig(
      projectName: name,
      architecture: architecture,
      stateManagement: stateManagement,
      router: router,
      useDio: useDio,
      useLazyAssetGenerator: useLazyAssetGenerator,
      useGetIt: useGetIt,
      useStrictLints: useStrictLints,
    );
  }
}
