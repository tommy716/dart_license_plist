/*
 * yaml_manager.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'dart:io';

import 'package:yaml/yaml.dart';

class YamlManager {
  static YamlMap getYamlMap(String yamlPath) {
    final String yamlString = File(yamlPath).readAsStringSync();
    return loadYaml(yamlString);
  }

  static List<String> getYamlMapKeys(YamlMap yamlMap) {
    return yamlMap.keys.map<String>((key) => key.toString()).toList();
  }
}
