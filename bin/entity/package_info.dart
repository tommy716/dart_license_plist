/*
 * package_info.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'license_info.dart';

class PackageInfo {
  const PackageInfo({
    required String name,
    required LicenseInfo licenseInfo,
  })  : _name = name,
        _licenseInfo = licenseInfo;

  final String _name;
  String get name => _name;

  final LicenseInfo _licenseInfo;
  LicenseInfo get licenseInfo => _licenseInfo;
}
