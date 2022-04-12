/*
 * license_info.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

class LicenseInfo {
  const LicenseInfo({
    required String license,
  }) : _license = license;

  final String _license;
  String get license => _license;
}
