/*
 * yaml_parser.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'package:yaml/yaml.dart';

import '../entity/license_info.dart';
import '../entity/package_info.dart';

class YamlParser {
  static const String _excludeKey = "exclude";
  static const String _packagesKey = 'packages';
  static const String _licenseKey = 'license';

  /// get exclude packages name section
  static YamlMap? getExcludePackages(YamlMap yamlMap) {
    return yamlMap[_excludeKey];
  }

  /// get packages section
  static YamlMap? getPackagesValue(YamlMap yamlMap) {
    return yamlMap[_packagesKey];
  }

  /// parse custom license yaml
  static List<PackageInfo> parseCustomLicenseYaml(YamlMap yamlMap) {
    final List<PackageInfo> packageInfoList = [];

    for (final packageName in yamlMap[_packagesKey].keys.toList()) {
      final String license = yamlMap[_packagesKey][packageName][_licenseKey];
      final packageInfo = PackageInfo(
        name: packageName,
        licenseInfo: LicenseInfo(
          license: license,
        ),
      );
      packageInfoList.add(packageInfo);
    }

    return packageInfoList;
  }
}
