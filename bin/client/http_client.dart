/*
 * http_client.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:yaml/yaml.dart';

import '../common/consts.dart';

class HttpClient {
  /// get package name list from pubspec.lock
  static List<dynamic> fetchPluginNameList() {
    Map<String, String> environment = Platform.environment;
    final pubspecPath = "${environment["PWD"]}/pubspec.lock";

    if (!File(pubspecPath).existsSync()) {
      throw AssertionError(
        "pubspec.lock not found. Please run the command on the root directory of your project.",
      );
    }

    final pubspecString = File(pubspecPath).readAsStringSync();
    final pubspecYaml = loadYaml(pubspecString);

    final packageMap = pubspecYaml["packages"] as YamlMap;
    return packageMap.keys.toList();
  }

  /// get html string
  static Future<String> fetchHtml(
    String url, {
    required String packageName,
    bool shouldRedirect = true,
  }) async {
    final Uri uri = Uri.parse(url);
    final client = http.Client();
    final request = http.Request("GET", uri)..followRedirects = false;
    final response = await client.send(request);
    var responseString = await response.stream.bytesToString();

    if (response.isRedirect || shouldRedirect) {
      final String? location = response.headers["localtion"];
      if (location != null && location.contains("api.flutter.dev")) {
        final redirectUrl = "$flutterApiUrl/$packageName/$packageName-library.html";
        return await fetchHtml(
          redirectUrl,
          packageName: packageName,
          shouldRedirect: false,
        );
      }
    }

    if (response.statusCode != 200) {
      throw AssertionError(
        "Failed to fetch the url($url) (response status is ${response.statusCode}).",
      );
    }

    if (responseString.isEmpty) {
      throw AssertionError(
        "Failed to fetch the url($url) (response body is empty). ",
      );
    }

    return responseString;
  }
}
