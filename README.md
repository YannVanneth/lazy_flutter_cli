# 🚀 Lazy Flutter CLI

[![pub package](https://img.shields.io/pub/v/lazy_flutter_cli.svg)](https://pub.dev/packages/lazy_flutter_cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Maintained with Antigravity](https://img.shields.io/badge/Maintained%20with-Google%20Antigravity-4285F4?style=flat&logo=google)](https://github.com/google/antigravity)

An interactive, Next.js-style command-line tool (`lazy` / `lazy_flutter` / `flutter_lazy`) for Flutter developers to scaffold production-ready Flutter apps with **Clean Architecture**, **MVVM**, **Feature-First**, **BLoC**, **Riverpod**, **Provider**, **GetX**, and **GoRouter**.

> 🚀 **Maintained with [Google Antigravity](https://github.com/google/antigravity)**

---

## ✨ Features

- 🎨 **Clack-Style In-Place Interactive UI**: Clean terminal questionnaire with smooth in-place option redrawing (`lazy create`).
- 🏗️ **Multiple Architectures**: Clean Architecture (Data / Domain / Presentation), MVVM, or Feature-First.
- ⚡ **State Management**: BLoC / Cubit, Riverpod, Provider, or GetX with versions resolved at creation time.
- 🛣️ **Modern Routing**: GoRouter, AutoRoute, or Standard Navigator 2.0 with versions resolved at creation time.
- 🧩 **Instant Feature Generation**: `lazy g feature <name>` generates data, domain, and presentation layers in seconds.
- 🛠️ **Pre-Configured Stack**: Integrates Dio, `lazy_asset_generator`, GetIt, and strict lints using the latest SDK-compatible versions.
- 🧑‍💻 **Developer-Ready Projects**: Generates linting, starter tests, VS Code settings, `.gitignore`, and a one-command quality check.
- 💡 **Flexible Executable Aliases**: Run using `lazy`, `lazy_flutter`, `flutter_lazy`, `flutter-lazy`, or set up `flutter lazy`.

---

## 📦 Installation

Activate the CLI globally using Dart:

```bash
dart pub global activate lazy_flutter_cli
```

Ensure `~/.pub-cache/bin` (or `%LOCALAPPDATA%\Pub\Cache\bin` on Windows) is added to your `PATH`:

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

---

## 🧩 Usage

### 1. Executable Names

You can run the CLI using any of the following command names:

- `lazy`
- `lazy_flutter`
- `flutter_lazy`
- `flutter-lazy`

#### Optional: Enable `flutter lazy` command

Add this shell wrapper to your `~/.bashrc` or `~/.zshrc`:

```bash
flutter() {
  if [ "$1" = "lazy" ]; then
    shift
    lazy "$@"
  elif command -v flutter >/dev/null 2>&1; then
    command flutter "$@"
  else
    echo "Flutter SDK binary not found. Running lazy CLI:"
    lazy "$@"
  fi
}
```

Then reload your shell (`source ~/.bashrc`) to run `flutter lazy create my_app`!

---

### 2. Scaffold a New Project (`create`)

#### Interactive Terminal Mode:

```bash
lazy create
# OR
flutter_lazy create
```

##### In-Place Terminal Experience:

```text
🚀 Welcome to Lazy Flutter CLI!

✔ What is your project named? › my_awesome_app
✔ Which architecture pattern would you like to use? › Clean Architecture (Data / Domain / Presentation)
✔ Which state management solution would you like to use? › Flutter BLoC / Cubit
✔ Which routing solution would you like to use? › GoRouter
✔ Would you like to include Dio network client & interceptors? › Yes
✔ Would you like to include lazy_asset_generator for type-safe assets? › Yes
✔ Would you like to include GetIt dependency injection? › Yes
✔ Would you like to enable strict Flutter lints? › Yes
```

#### Non-Interactive / CI-CD Mode (Flags):

```bash
lazy create my_app --arch clean --state bloc --router go_router --dio --lazy-assets --get-it --strict-lints
```

#### Command Flags:

| Flag                  | Options                                | Description                           | Default     |
| :-------------------- | :------------------------------------- | :------------------------------------ | :---------- |
| `--arch`              | `clean`, `mvvm`, `feature-first`       | Architecture pattern                  | `clean`     |
| `--state`             | `bloc`, `riverpod`, `provider`, `getx` | State management solution             | `bloc`      |
| `--router`            | `go_router`, `auto_route`, `standard`  | Routing solution                      | `go_router` |
| `--[no-]dio`          | boolean                                | Include Dio network client            | `true`      |
| `--[no-]lazy-assets`  | boolean                                | Include `lazy_asset_generator`        | `true`      |
| `--[no-]get-it`       | boolean                                | Include `get_it` dependency injection | `true`      |
| `--[no-]strict-lints` | boolean                                | Enable strict Flutter lints           | `true`      |

---

### 3. Generate a Feature Module (`g feature`)

Navigate inside any Flutter project directory and run:

```bash
lazy g feature authentication
# OR
flutter_lazy g feature authentication
```

#### Generated Structure:

```text
lib/features/authentication/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/authentication_repository_impl.dart
├── domain/
│   ├── entities/
│   ├── repositories/authentication_repository.dart
│   └── usecases/get_authentication_usecase.dart
└── presentation/
    ├── controllers/
    ├── pages/authentication_page.dart
    └── widgets/
```

---

## 🏗️ Generated Project Structure

```text
my_awesome_app/
├── assets/
│   ├── icons/
│   ├── images/
│   └── json/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── network/
│   │   ├── router/
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   │   └── home/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   └── main.dart
├── analysis_options.yaml
├── test/widget_test.dart
├── tool/verify.dart
├── .vscode/
├── pubspec.yaml
└── README.md
```

Run `dart run tool/verify.dart` inside the generated project to format, analyze,
and test it in one command.

---

## 🤝 Contributing

Contributions are welcome! Submit PRs or open issues on [GitHub](https://github.com/YannVanneth/lazy_flutter_cli).

---

## 📄 License

[MIT License](LICENSE)
