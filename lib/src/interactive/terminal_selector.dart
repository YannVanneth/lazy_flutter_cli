import 'dart:io';
import 'package:mason_logger/mason_logger.dart';

enum _Key { up, down, left, right, enter, space, tab, y, n, number, other }

class TerminalSelector {
  final Logger logger;

  TerminalSelector(this.logger);

  String selectOne({
    required String message,
    required List<String> choices,
    String? defaultValue,
  }) {
    if (!stdin.hasTerminal) {
      return logger.chooseOne<String>(
        message,
        choices: choices,
        defaultValue: defaultValue,
      );
    }

    int selectedIndex = 0;
    if (defaultValue != null) {
      final defaultIdx = choices.indexOf(defaultValue);
      if (defaultIdx != -1) {
        selectedIndex = defaultIdx;
      }
    }

    // Hide cursor during selection
    stdout.write('\x1b[?25l');

    final originalLineMode = stdin.lineMode;
    final originalEchoMode = stdin.echoMode;

    try {
      stdin.lineMode = false;
      stdin.echoMode = false;

      void renderPrompt({bool isInitial = false}) {
        if (!isInitial) {
          final totalLines = choices.length + 1;
          stdout.write('\x1b[${totalLines}A\x1b[0J');
        }

        stdout.writeln('${cyan.wrap('?')} ${styleBold.wrap(message)}');

        for (int i = 0; i < choices.length; i++) {
          if (i == selectedIndex) {
            stdout.writeln('  ${cyan.wrap('❯')} ${cyan.wrap(choices[i])}');
          } else {
            stdout.writeln('    ${darkGray.wrap(choices[i])}');
          }
        }
      }

      renderPrompt(isInitial: true);

      while (true) {
        final keyInfo = _readKey();
        if (keyInfo.key == _Key.up) {
          selectedIndex = (selectedIndex - 1 + choices.length) % choices.length;
          renderPrompt();
        } else if (keyInfo.key == _Key.down) {
          selectedIndex = (selectedIndex + 1) % choices.length;
          renderPrompt();
        } else if (keyInfo.key == _Key.enter) {
          final totalLines = choices.length + 1;
          stdout.write('\x1b[${totalLines}A\x1b[0J');
          stdout.writeln(
            '${green.wrap('✔')} ${styleBold.wrap(message)} ${darkGray.wrap('›')} ${cyan.wrap(choices[selectedIndex])}',
          );
          break;
        } else if (keyInfo.key == _Key.number) {
          final num = keyInfo.number;
          if (num >= 1 && num <= choices.length) {
            selectedIndex = num - 1;
            final totalLines = choices.length + 1;
            stdout.write('\x1b[${totalLines}A\x1b[0J');
            stdout.writeln(
              '${green.wrap('✔')} ${styleBold.wrap(message)} ${darkGray.wrap('›')} ${cyan.wrap(choices[selectedIndex])}',
            );
            break;
          }
        }
      }
    } finally {
      try {
        stdin.lineMode = originalLineMode;
        stdin.echoMode = originalEchoMode;
      } catch (_) {}
      // Show cursor again
      stdout.write('\x1b[?25h');
    }

    return choices[selectedIndex];
  }

  bool confirm({
    required String message,
    bool defaultValue = true,
  }) {
    if (!stdin.hasTerminal) {
      return logger.confirm(message, defaultValue: defaultValue);
    }

    bool value = defaultValue;

    stdout.write('\x1b[?25l');

    final originalLineMode = stdin.lineMode;
    final originalEchoMode = stdin.echoMode;

    try {
      stdin.lineMode = false;
      stdin.echoMode = false;

      void renderPrompt({bool isInitial = false}) {
        if (!isInitial) {
          stdout.write('\x1b[1A\x1b[0J');
        }
        final yesStr = value ? cyan.wrap('Yes')! : darkGray.wrap('Yes')!;
        final noStr = !value ? cyan.wrap('No')! : darkGray.wrap('No')!;
        final hint = value ? '(${styleBold.wrap('Y')}/n)' : '(y/${styleBold.wrap('N')})';
        stdout.writeln(
          '${cyan.wrap('?')} ${styleBold.wrap(message)} ${darkGray.wrap(hint)} $yesStr / $noStr',
        );
      }

      renderPrompt(isInitial: true);

      while (true) {
        final keyInfo = _readKey();
        if (keyInfo.key == _Key.left ||
            keyInfo.key == _Key.right ||
            keyInfo.key == _Key.space ||
            keyInfo.key == _Key.tab) {
          value = !value;
          renderPrompt();
        } else if (keyInfo.key == _Key.y) {
          value = true;
          renderPrompt();
          _clearAndFinishConfirm(message, value);
          break;
        } else if (keyInfo.key == _Key.n) {
          value = false;
          renderPrompt();
          _clearAndFinishConfirm(message, value);
          break;
        } else if (keyInfo.key == _Key.enter) {
          _clearAndFinishConfirm(message, value);
          break;
        }
      }
    } finally {
      try {
        stdin.lineMode = originalLineMode;
        stdin.echoMode = originalEchoMode;
      } catch (_) {}
      stdout.write('\x1b[?25h');
    }

    return value;
  }

  String promptText({
    required String message,
    required String defaultValue,
  }) {
    final response = logger.prompt(
      '${green.wrap('✔')} $message',
      defaultValue: defaultValue,
    );
    return response;
  }

  void _clearAndFinishConfirm(String message, bool value) {
    stdout.write('\x1b[1A\x1b[0J');
    final valStr = value ? green.wrap('Yes')! : red.wrap('No')!;
    stdout.writeln(
      '${green.wrap('✔')} ${styleBold.wrap(message)} ${darkGray.wrap('›')} $valStr',
    );
  }

  _KeyInfo _readKey() {
    final char = stdin.readByteSync();
    if (char == 13 || char == 10) return const _KeyInfo(_Key.enter);
    if (char == 32) return const _KeyInfo(_Key.space);
    if (char == 9) return const _KeyInfo(_Key.tab);
    if (char == 121 || char == 89) return const _KeyInfo(_Key.y);
    if (char == 110 || char == 78) return const _KeyInfo(_Key.n);
    if (char >= 49 && char <= 57) {
      return _KeyInfo(_Key.number, number: char - 48);
    }
    if (char == 27) {
      final next1 = stdin.readByteSync();
      if (next1 == 91) {
        final next2 = stdin.readByteSync();
        if (next2 == 65) return const _KeyInfo(_Key.up);
        if (next2 == 66) return const _KeyInfo(_Key.down);
        if (next2 == 67) return const _KeyInfo(_Key.right);
        if (next2 == 68) return const _KeyInfo(_Key.left);
      }
    }
    return const _KeyInfo(_Key.other);
  }
}

class _KeyInfo {
  final _Key key;
  final int number;

  const _KeyInfo(this.key, {this.number = -1});
}
