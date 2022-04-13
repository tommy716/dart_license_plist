/*
 * dart_license_plist_text.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import "package:test/test.dart";
import 'package:yaml/yaml.dart';

import "../bin/manager/yaml_manager.dart";
import "../bin/parser/yaml_parser.dart";
import "../bin/entity/package_info.dart";
import "../bin/common/logger.dart";
import 'consts.dart';

Future<void> main() async {
  group("parse custom license yaml flow test", () {
    test("custom-license-yaml arguments", () {
      const validArgsWithValue = ['--custom-license-yaml'];
      const String argument =
          "--custom-license-yaml=./dummy/custom_license.yaml";
      // argument split by '='
      final List<String> argumentSplit = argument.split("=");
      // throw error if arguments is invalid.
      if (!validArgsWithValue.contains(argumentSplit[0])) {
        throw AssertionError(
          "Invalid argument: $argument",
        );
      }
      // throw error if argument has value.
      if (argumentSplit.length != 2) {
        throw AssertionError("Invalid argument: $argument, value is required.");
      }
    });
    test("getYamlMap()", () async {
      final YamlMap correctYamlMap = YamlMap.wrap(
        {
          "exclude": {
            "package_name1": null,
          },
          "packages": {
            "package_name": {
              "license": mitLicenseText,
            },
          },
        },
      );

      final YamlMap customLicenseYamlMap =
          YamlManager.getYamlMap("./test/assets/license.yaml");

      expect(
          correctYamlMap.toString() == customLicenseYamlMap.toString(), true);
    });

    test("parseCustomLicenseYaml()", () async {
      final YamlMap customLicenseYamlMap =
          YamlManager.getYamlMap("./test/assets/license.yaml");
      final List<PackageInfo> packageInfoList =
          YamlParser.parseCustomLicenseYaml(customLicenseYamlMap);

      expect(packageInfoList.length == 1, true);
      expect(packageInfoList[0].name == "package_name", true);
      expect(packageInfoList[0].licenseInfo.license == mitLicenseText, true);
    });

    test("test license_without_exclude", () {
      // get yaml object
      final YamlMap customLicenseYamlMap = YamlManager.getYamlMap(
        "./test/assets/license_without_exclude.yaml",
      );

      /// create exclude package info
      // parse exclude section from yaml object
      final YamlMap? excludePackageNameYamlList = YamlParser.getExcludePackages(
        customLicenseYamlMap,
      );

      final List<String> excludePackageNameList = [];
      if (excludePackageNameYamlList != null) {
        // get package name list from yaml object
        excludePackageNameList.addAll(YamlManager.getYamlMapKeys(
          excludePackageNameYamlList,
        ));
        Logger.info("-----");
        Logger.info("Exclude package name list");
        Logger.info(excludePackageNameList.join("\n"));
      }

      /// create custom license info
      // parse packages section from yaml object
      final YamlMap? customLicensePackagesYamlMap = YamlParser.getPackagesValue(
        customLicenseYamlMap,
      );

      final List<String> customLicensePackageNameList = [];
      if (customLicensePackagesYamlMap != null) {
        // get package name list from yaml object
        customLicensePackageNameList.addAll(YamlManager.getYamlMapKeys(
          customLicensePackagesYamlMap,
        ));
        Logger.info("-----");
        Logger.info("Custom license package name list");
        Logger.info(customLicensePackageNameList.join("\n"));
      }

      /// check both list
      final Set excludePackageNameListSet = excludePackageNameList.toSet();
      final Set customLicensePackageNameListSet =
          customLicensePackageNameList.toSet();
      final Set intersection = excludePackageNameListSet.intersection(
        customLicensePackageNameListSet,
      );

      expect(excludePackageNameList.isEmpty, true);
      expect(customLicensePackageNameList.length == 1, true);
      expect(customLicensePackageNameList.first == "package_name", true);
      expect(intersection.isNotEmpty, false);
    });

    test("test license_without_packages", () {
      // get yaml object
      final YamlMap customLicenseYamlMap = YamlManager.getYamlMap(
        "./test/assets/license_without_packages.yaml",
      );

      /// create exclude package info
      // parse exclude section from yaml object
      final YamlMap? excludePackageNameYamlList = YamlParser.getExcludePackages(
        customLicenseYamlMap,
      );

      final List<String> excludePackageNameList = [];
      if (excludePackageNameYamlList != null) {
        // get package name list from yaml object
        excludePackageNameList.addAll(YamlManager.getYamlMapKeys(
          excludePackageNameYamlList,
        ));
        Logger.info("-----");
        Logger.info("Exclude package name list");
        Logger.info(excludePackageNameList.join("\n"));
      }

      /// create custom license info
      // parse packages section from yaml object
      final YamlMap? customLicensePackagesYamlMap = YamlParser.getPackagesValue(
        customLicenseYamlMap,
      );

      final List<String> customLicensePackageNameList = [];
      if (customLicensePackagesYamlMap != null) {
        // get package name list from yaml object
        customLicensePackageNameList.addAll(YamlManager.getYamlMapKeys(
          customLicensePackagesYamlMap,
        ));
        Logger.info("-----");
        Logger.info("Custom license package name list");
        Logger.info(customLicensePackageNameList.join("\n"));
      }

      /// check both list
      final Set excludePackageNameListSet = excludePackageNameList.toSet();
      final Set customLicensePackageNameListSet =
          customLicensePackageNameList.toSet();
      final Set intersection = excludePackageNameListSet.intersection(
        customLicensePackageNameListSet,
      );

      expect(excludePackageNameList.length == 1, true);
      expect(excludePackageNameList.first == "package_name", true);
      expect(customLicensePackageNameList.isEmpty, true);
      expect(intersection.isNotEmpty, false);
    });
  });
}
