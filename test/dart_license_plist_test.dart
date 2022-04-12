/*
 * dart_license_plist_text.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'dart:io';

import "package:test/test.dart";
import 'package:yaml/yaml.dart';

import "../bin/manager/yaml_manager.dart";
import "../bin/parser/yaml_parser.dart";
import "../bin/entity/package_info.dart";
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
  });
}
