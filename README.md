# 🚀 Lazy Flutter CLI

[![pub package](https://img.shields.io/pub/v/lazy_flutter_cli.svg)](https://pub.dev/packages/lazy_flutter_cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Maintained with Antigravity](https://img.shields.io/badge/Maintained%20with-Google%20Antigravity-4285F4?style=flat&logo=google)](https://github.com/google/antigravity)

An interactive, Next.js-style command-line tool (`lazy`) for Flutter developers to scaffold production-ready Flutter apps with **Clean Architecture**, **MVVM**, **Feature-First**, **BLoC**, **Riverpod**, **Provider**, and **GoRouter**.

> 🚀 **Maintained with [Google Antigravity](https://github.com/google/antigravity)**

---

## ✨ Features

- 🎨 **Next.js-Style Interactive Terminal UI**: Step-by-step questionnaire in your terminal (`lazy create`).
- 🏗️ **Multiple Architectures**: Clean Architecture (Data / Domain / Presentation), MVVM, or Feature-First.
- ⚡ **State Management**: BLoC / Cubit, Riverpod, Provider, or GetX.
- 🧩 **Instant Feature Generation**: `lazy g feature <name>` generates data, domain, and presentation layers in seconds.
- 🛠️ **Pre-Configured Stack**: Integrates `Dio`, `lazy_asset_generator`, `GetIt`, and strict linting.

---

## 📦 Installation

Activate the CLI globally using Dart:

```bash
dart pub global activate lazy_flutter_cli
```

Ensure `~/.pub-cache/bin` (or `%LOCALAPPDATA%\Pub\Cache\bin` on Windows) is in your `PATH`.

---

## 🧩 Usage

### 1. Scaffold a New Project (`lazy create`)

Run interactive mode:

```bash
lazy create
```

Or specify the project name directly:

```bash
lazy create my_awesome_app
```

#### Interactive Terminal Experience:

```text
  🚀 Welcome to Lazy Flutter CLI!

  ✔ What is your project named? … my_awesome_app
  ✔ Which architecture pattern would you like to use?
    ❯ Clean Architecture (Data / Domain / Presentation)
      MVVM (Model - View - ViewModel)
      Feature-First (Modular)
  ✔ Which state management solution would you like to use?
    ❯ Flutter BLoC / Cubit
      Riverpod
      Provider
      GetX
  ✔ Which routing solution would you like to use?
    ❯ GoRouter
      AutoRoute
      Standard Navigator 2.0
  ✔ Would you like to include Dio network client & interceptors? › Yes / No
  ✔ Would you like to include lazy_asset_generator for type-safe assets? › Yes / No
  ✔ Would you like to include GetIt dependency injection? › Yes / No
  ✔ Would you like to enable strict Flutter lints? › Yes / No
```

#### Flag-Driven Mode (Non-Interactive / CI-CD):

```bash
lazy create my_app --arch clean --state bloc --router go_router --dio --lazy-assets
```

---

### 2. Generate a Feature Module (`lazy g feature`)

Navigate inside your Flutter project directory and run:

```bash
lazy g feature authentication
```

Generates:
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

## 🤝 Contributing

Contributions are welcome! Submit PRs or open issues on [GitHub](https://github.com/YannVanneth/lazy_flutter_cli).

---

## 📄 License

[MIT License](LICENSE)
