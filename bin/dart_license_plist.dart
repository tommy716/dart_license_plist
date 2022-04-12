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

import 'common/logger.dart';
import 'common/utils.dart' as utils;
import 'common/consts.dart';
import 'entity/license_info.dart';
import 'entity/package_info.dart';
import 'client/http_client.dart' as client;
import 'extension/string_extension.dart';
import 'manager/plist_manager.dart';
import 'parser/html_parser.dart' as parser;

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

  // package name list from pubspec.yamll
  final List<dynamic> packageNameList = client.HttpClient.fetchPluginNameList();
  // package info list
  final List<PackageInfo> packageInfoList = [];
  // package name list of can not create plist
  final List<String> errorPackageNameList = [];

  /// create packageInfo from package name
  for (var packageName in packageNameList) {
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
