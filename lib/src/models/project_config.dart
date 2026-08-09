enum Architecture { clean, mvvm, featureFirst }

enum StateManagement { bloc, riverpod, provider, getx }

enum AppRouter { goRouter, autoRoute, standard }

class ProjectConfig {
  final String projectName;
  final Architecture architecture;
  final StateManagement stateManagement;
  final AppRouter router;
  final bool useDio;
  final bool useLazyAssetGenerator;
  final bool useGetIt;
  final bool useStrictLints;

  const ProjectConfig({
    required this.projectName,
    required this.architecture,
    required this.stateManagement,
    required this.router,
    this.useDio = true,
    this.useLazyAssetGenerator = true,
    this.useGetIt = true,
    this.useStrictLints = true,
  });

  String get architectureName {
    switch (architecture) {
      case Architecture.clean:
        return 'Clean Architecture';
      case Architecture.mvvm:
        return 'MVVM';
      case Architecture.featureFirst:
        return 'Feature-First';
    }
  }

  String get stateManagementName {
    switch (stateManagement) {
      case StateManagement.bloc:
        return 'Flutter BLoC / Cubit';
      case StateManagement.riverpod:
        return 'Riverpod';
      case StateManagement.provider:
        return 'Provider';
      case StateManagement.getx:
        return 'GetX';
    }
  }

  String get routerName {
    switch (router) {
      case AppRouter.goRouter:
        return 'GoRouter';
      case AppRouter.autoRoute:
        return 'AutoRoute';
      case AppRouter.standard:
        return 'Standard Navigator 2.0';
    }
  }
}
