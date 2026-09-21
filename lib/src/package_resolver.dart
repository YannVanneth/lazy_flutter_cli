import 'dart:io';

import 'models/project_config.dart';

typedef ProcessRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
});

class PackageResolver {
  final String flutterExecutable;
  final ProcessRunner _runProcess;

  PackageResolver({
    this.flutterExecutable = 'flutter',
    ProcessRunner? processRunner,
  }) : _runProcess = processRunner ?? _defaultProcessRunner;

  Future<void> resolve(
    ProjectConfig config,
    String projectRoot, {
    void Function(String package, bool dev)? onPackageResolving,
  }) async {
    final dependencies = <String>[
      'cupertino_icons',
      _stateManagementPackage(config.stateManagement),
    ];

    final routerPackage = _routerPackage(config.router);
    if (routerPackage != null) {
      dependencies.add(routerPackage);
    }
    if (config.useDio) {
      dependencies.add('dio');
    }
    if (config.useGetIt) {
      dependencies.add('get_it');
    }
    if (config.useLazyAssetGenerator) {
      dependencies.add('lazy_asset_generator');
    }

    for (final dependency in dependencies) {
      onPackageResolving?.call(dependency, false);
      await _add(dependency, projectRoot);
    }

    final devDependencies = <String>[];
    if (config.useStrictLints) {
      devDependencies.add('flutter_lints');
    }
    if (config.useLazyAssetGenerator) {
      devDependencies.add('build_runner');
    }

    for (final dependency in devDependencies) {
      onPackageResolving?.call(dependency, true);
      await _add(dependency, projectRoot, dev: true);
    }
  }

  Future<void> _add(String package, String projectRoot,
      {bool dev = false}) async {
    final arguments = ['pub', 'add'];
    arguments.add(dev ? 'dev:$package' : package);

    final result = await _runProcess(
      flutterExecutable,
      arguments,
      workingDirectory: projectRoot,
    );

    if (result.exitCode != 0) {
      final details = result.stderr.toString().trim();
      throw PackageResolutionException(
        package,
        details.isEmpty
            ? 'flutter pub add exited with code ${result.exitCode}.'
            : details,
      );
    }
  }

  String _stateManagementPackage(StateManagement stateManagement) {
    switch (stateManagement) {
      case StateManagement.bloc:
        return 'flutter_bloc';
      case StateManagement.riverpod:
        return 'flutter_riverpod';
      case StateManagement.provider:
        return 'provider';
      case StateManagement.getx:
        return 'get';
    }
  }

  String? _routerPackage(AppRouter router) {
    switch (router) {
      case AppRouter.goRouter:
        return 'go_router';
      case AppRouter.autoRoute:
        return 'auto_route';
      case AppRouter.standard:
        return null;
    }
  }

  static Future<ProcessResult> _defaultProcessRunner(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );
  }
}

class PackageResolutionException implements Exception {
  final String package;
  final String message;

  const PackageResolutionException(this.package, this.message);

  @override
  String toString() => 'Failed to resolve latest version of $package: $message';
}
