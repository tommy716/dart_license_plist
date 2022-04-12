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
  if (arguments.contains("--version") || arguments.contains("-v")) {
    print(packageVersion);

    // Check updates.
    final pubUpdater = PubUpdater();
    final isUpToDate = await pubUpdater.isUpToDate(
      packageName: packageName,
      currentVersion: packageVersion,
    );

    // Exists New Version.
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

  if (arguments.contains("--verbose")) {
    Logger.setIsVerbose(true);
  }

  final List<dynamic> packageNameList = client.HttpClient.fetchPluginNameList();
  final List<PackageInfo> packageInfoList = [];
  final List<String> errorPackageNameList = [];

  for (var packageName in packageNameList) {
    try {
      final String packageSiteUrl = "$pubDevUrl/packages/$packageName";
      Logger.info("-----");
      Logger.info("Fetching $packageName data... (URL: $packageSiteUrl)");
      final String siteHtmlString = await client.HttpClient.fetchHtml(packageSiteUrl, packageName: packageName);
      final Document siteHtml = parse(siteHtmlString);
      final Element? licenseDom = parser.HtmlParser.parseLicenseDom(siteHtml);

      if (licenseDom == null || licenseDom.attributes["href"] == null) {
        Logger.error("$packageName's license not found. Skipping...");
        continue;
      }

      String licenseUrl = licenseDom.attributes["href"]!;
      final bool isGitHubRepositoryLicense = licenseUrl.isGitHubUrl() || licenseUrl.isGitHubRawUrl();

      String licenseText = "";
      if (isGitHubRepositoryLicense) {
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
        licenseText = await client.HttpClient.fetchHtml(licenseUrl, packageName: packageName);
      } else {
        licenseUrl = "$pubDevUrl$licenseUrl";
        Logger.info("$packageName's license url: $licenseUrl");
        final String licenseHtmlString = await client.HttpClient.fetchHtml(licenseUrl, packageName: packageName);
        final Document licenseHtml = parse(licenseHtmlString);
        final Element? licenseTextDom = parser.HtmlParser.parseLicenseTextDom(licenseHtml);

        if (licenseTextDom == null) {
          Logger.error(
            "$packageName's license text not found but license page($licenseHtmlString) is found.",
          );
          continue;
        }

        licenseText = licenseTextDom.text.replaceAll("\n", "\n");
      }

      packageInfoList.add(
        PackageInfo(
          name: packageName,
          licenseInfo: LicenseInfo(
            license: licenseText,
          ),
        ),
      );
    } catch (e, stackTrace) {
      errorPackageNameList.add(packageName);
      Logger.error("Failed to generate $packageName.plist.", error: e, stackTrace: stackTrace);
      continue;
    }
  }

  try {
    await PlistManager.initializeSettingsBudleRootPlist();
    await PlistManager.createDartLicensePlist(packageInfoList);
    if (errorPackageNameList.isNotEmpty) {
      Logger.error("-------------------------------------------");
      Logger.error("Failed to generate following packages:");
      Logger.error(errorPackageNameList.join("\n"));
      Logger.error("-------------------------------------------");
    }
  } catch (e, stackTrace) {
    Logger.error("Failed to generate license plist.", error: e, stackTrace: stackTrace);
    return;
  }

  Logger.info("Generate Finished.");
}
