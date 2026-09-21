## 1.1.0
- Resolve the latest Flutter/Dart SDK-compatible package versions during `lazy create`.
- Show dependency progress and actionable errors when package resolution fails.
- Clean up incomplete newly-created projects after failed setup.
- Generate linting, starter widget tests, VS Code configuration, `.gitignore`, and `tool/verify.dart`.
- Add a one-command developer workflow for formatting, analysis, and tests.

## 1.0.0
- Initial release of `lazy_flutter_cli`.
- Interactive Next.js-style project creation (`lazy create`).
- Feature module code generator (`lazy g feature`).
- Support for Clean Architecture, MVVM, Feature-First, BLoC, Riverpod, Provider, GetX, GoRouter, Dio, and `lazy_asset_generator`.
- Multiple executable command aliases (`lazy`, `lazy_flutter`, `flutter_lazy`, `flutter-lazy`).
- Smooth in-place terminal option rendering without redundant newlines (`TerminalSelector`).
- Upgraded dependencies (`flutter_bloc ^9.0.0`, `flutter_riverpod ^2.6.1`, `go_router ^14.8.0`, `dio ^5.8.0`, `get_it ^8.0.3`, `flutter_lints ^6.0.0`).
