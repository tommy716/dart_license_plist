/*
 * logger.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'dart:io';

class Logger {
  Logger._();
  static final share = Logger._();
  bool _isVerbose = false;

  static void setIsVerbose(bool isVerbose) {
    share._isVerbose = isVerbose;
  }

  static void debug(String message) {
    if (share._isVerbose) {
      stdout.writeln("[DEBUG] $message");
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    stderr.writeln("[ERROR] $message");
    if (error != null) stderr.writeln(error);
    if (stackTrace != null) stderr.writeln(stackTrace);
  }

  static void info(String message) {
    stdout.writeln("[INFO] $message");
  }
}
