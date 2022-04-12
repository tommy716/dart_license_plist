/*
 * string_extension.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */
extension StringExt on String {
  bool isGitHubUrl() {
    return contains("github.com");
  }

  bool isGitHubRawUrl() {
    return contains("raw.githubusercontent.com");
  }
}
