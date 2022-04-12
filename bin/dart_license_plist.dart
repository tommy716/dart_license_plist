/*
 * dart_license_plist.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:yaml/yaml.dart';

import 'common/logger.dart';
import 'common/utils.dart' as utils;
import 'common/consts.dart';
import 'entity/license_info.dart';
import 'entity/package_info.dart';
import 'client/http_client.dart' as client;
import 'extension/string_extension.dart';
import 'manager/plist_manager.dart';
import 'manager/yaml_manager.dart';
import 'parser/html_parser.dart' as parser;
import 'parser/yaml_parser.dart';

/*
 * Takes the following arguments:
 * --version, -v                      show the current version and check updates.
 * --verbose                          print debug messages.
 * --custom_license_yaml=<file.yaml>  The path to the custom license yaml file.
 */
Future<void> main(List<String> arguments) async {
  // print library version and check library updates.
  if (arguments.contains("--version") || arguments.contains("-v")) {
    Logger.info(packageVersion);

    // check updates.
    final pubUpdater = PubUpdater();
    final isUpToDate = await pubUpdater.isUpToDate(
      packageName: packageName,
      currentVersion: packageVersion,
    );

    // exists New Version.
    if (!isUpToDate) {
      final latestVersion = await pubUpdater.getLatestVersion(packageName);
      final shouldUpdate = utils.promptBool(
        "There is a newer version of $packageName available ($latestVersion).\nWould you like to update? (y/n, default: y)",
      );

      if (shouldUpdate) {
        await pubUpdater.update(packageName: packageName);
      }
    }

    return;
  }

  // set print debug log.
  if (arguments.contains("--verbose")) {
    Logger.setIsVerbose(true);
    Logger.debug("Verbose Mode Enabled.");
  }

  // valid arguments with values
  const ignoredParseArguments = ["--version", "-v", "--verbose"];
  const validArgsWithValue = ['--custom_license_yaml'];
  // argument-value map
  final Map<String, String> argsMap = Map<String, String>();
  // package name list from pubspec.yamll
  final List<dynamic> packageNameList = client.HttpClient.fetchPluginNameList();
  // custom license package name list
  final List<String> customLicensePackageNameList = [];
  // package info list
  final List<PackageInfo> packageInfoList = [];
  // package name list of can not create plist
  final List<String> errorPackageNameList = [];

  /// parse arguments
  for (final argument in arguments) {
    // parse skip if argument is ignored.
    if (ignoredParseArguments.contains(argument)) continue;
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
    // add argument-value map
    argsMap[argumentSplit[0].substring(2)] = argumentSplit[1];
  }

  // parse custom license yaml
  if (argsMap.containsKey("custom_license_yaml")) {
    final String customLicenseYamlPath = argsMap["custom_license_yaml"]!;
    final YamlMap customLicenseYamlMap = YamlManager.getYamlMap(customLicenseYamlPath);
    customLicensePackageNameList.addAll(
      YamlManager.getYamlMapKeys(customLicenseYamlMap),
    );

    final List<PackageInfo> customLicensePckageInfoList = YamlParser.parseCustomLicenseYaml(customLicenseYamlMap);
    packageInfoList.addAll(customLicensePckageInfoList);
  }

  /// create packageInfo from package name
  for (var packageName in packageNameList) {
    // skip custom license package name
    if (customLicensePackageNameList.contains(packageName)) {
      Logger.info("$packageName exsits in custom license yaml. Fetch Skipping...");
      continue;
    }

    try {
      // package site url on pub.dev
      final String packageSiteUrl = "$pubDevUrl/packages/$packageName";
      Logger.info("-----");
      Logger.info("Fetching $packageName data... (URL: $packageSiteUrl)");
      // get package page in pub.dev
      final String siteHtmlString = await client.HttpClient.fetchHtml(
        packageSiteUrl,
        packageName: packageName,
      );
      // package page html string to package page html document
      final Document siteHtml = parse(siteHtmlString);
      // get license link dom from html document
      final Element? licenseDom = parser.HtmlParser.parseLicenseDom(siteHtml);

      /// go next loop if license dom is null or license link is not found
      if (licenseDom == null || licenseDom.attributes["href"] == null) {
        Logger.error("$packageName's license not found. Skipping...");
        continue;
      }

      // license page url
      String licenseUrl = licenseDom.attributes["href"]!;
      // true if license url is in github
      final bool isGitHubRepositoryLicense = licenseUrl.isGitHubUrl() || licenseUrl.isGitHubRawUrl();

      // parsed license text
      String licenseText = "";

      if (isGitHubRepositoryLicense) {
        // replace url path if url is in github
        licenseUrl = licenseUrl
            .replaceAll(
              "github.com",
              "raw.githubusercontent.com",
            )
            .replaceAll(
              "raw/",
              "",
            )
            .replaceAll(
              "blob/",
              "",
            );
        Logger.info("$packageName's license url: $licenseUrl");
        // fetch license text from LICENSE file in library's repository
        licenseText = await client.HttpClient.fetchHtml(
          licenseUrl,
          packageName: packageName,
        );
      } else {
        licenseUrl = "$pubDevUrl$licenseUrl";
        Logger.info("$packageName's license url: $licenseUrl");
        // fetch license page html string from pub.dev
        final String licenseHtmlString = await client.HttpClient.fetchHtml(
          licenseUrl,
          packageName: packageName,
        );
        // license html string to license html document
        final Document licenseHtml = parse(licenseHtmlString);
        // get license text dom from license html document
        final Element? licenseTextDom = parser.HtmlParser.parseLicenseTextDom(licenseHtml);

        // go next loop if license text dom is null
        if (licenseTextDom == null) {
          Logger.error(
            "$packageName's license text not found but license page($licenseHtmlString) is found.",
          );
          continue;
        }

        licenseText = licenseTextDom.text.replaceAll("\n", "\n");
      }

      // add packageInfo to List if licenseText can get
      packageInfoList.add(
        PackageInfo(
          name: packageName,
          licenseInfo: LicenseInfo(
            license: licenseText,
          ),
        ),
      );
    } catch (e, stackTrace) {
      // add error package list and go next loop if cause some error
      errorPackageNameList.add(packageName);
      Logger.error(
        "Failed to generate $packageName.plist.",
        error: e,
        stackTrace: stackTrace,
      );
      continue;
    }
  }

  try {
    // initialize Root.plist in Settings.bundle
    await PlistManager.initializeSettingsBudleRootPlist();
    // sorting packageInfoList by package name
    packageInfoList.sort((a, b) => a.name.compareTo(b.name));
    // create library's license plist and dart_license_plist's plist.
    await PlistManager.createDartLicensePlist(packageInfoList);
    if (errorPackageNameList.isNotEmpty) {
      Logger.error("-------------------------------------------");
      Logger.error("Failed to generate following packages:");
      Logger.error(errorPackageNameList.join("\n"));
      Logger.error("-------------------------------------------");
    }
  } catch (e, stackTrace) {
    Logger.error(
      "Failed to generate license plist.",
      error: e,
      stackTrace: stackTrace,
    );
    return;
  }

  Logger.info("Generate Finished.");
}
