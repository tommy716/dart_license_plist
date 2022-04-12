/*
 * plist_manager.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xml/xml.dart' as xml;

import '../common/logger.dart';
import '../common/consts.dart';
import '../entity/package_info.dart';

class PlistManager {
  static Future<void> initializeSettingsBudleRootPlist() async {
    final Map<String, String> environment = Platform.environment;
    final String settingBundlePath =
        "${environment["PWD"]}/ios/Runner/Settings.bundle";

    if (!Directory(settingBundlePath).existsSync()) {
      throw AssertionError(
        "Settings.bundle not found. Please create New File(Settings Bundle) on Xcode.",
      );
    }

    final File settingBundleRootPlistFile =
        File("$settingBundlePath/Root.plist");
    final String settingBundleRootPlistString =
        settingBundleRootPlistFile.readAsStringSync();
    final xml.XmlDocument settingBundleRootPlist = xml.XmlDocument.parse(
      settingBundleRootPlistString,
    );
    final xml.XmlElement? arrayNode = settingBundleRootPlist
        .getElement("plist")
        ?.getElement("dict")
        ?.getElement("array");

    if (arrayNode == null) {
      throw AssertionError(
        "Failed to find array node in Settings.bundle/Root.plist.",
      );
    }

    if (arrayNode.children.firstWhereOrNull(
          (node) => node
              .findElements("string")
              .where(
                (stringProperty) => stringProperty.text.contains(
                  "dev.nomunomu0504.dart_license_plist",
                ),
              )
              .isNotEmpty,
        ) !=
        null) {
      Logger.info(
          "dart_license_plist already exists in Settings.bundle/Root.plist.");
      return;
    }

    final xml.XmlBuilder xmlBuilder = xml.XmlBuilder();
    xmlBuilder.element("dict", nest: () {
      xmlBuilder
        ..element("key", nest: "File")
        ..element("string", nest: "dev.nomunomu0504.dart_license_plist")
        ..element("key", nest: "Title")
        ..element("string", nest: "謝辞")
        ..element("key", nest: "Type")
        ..element("string", nest: "PSChildPaneSpecifier");
    });
    final xml.XmlDocumentFragment dartLicensePlistNode =
        xmlBuilder.buildFragment();
    Logger.info(dartLicensePlistNode.toXmlString(pretty: true));
    arrayNode.children.insert(0, dartLicensePlistNode);

    final modifiedSettingBundleRootPlistString =
        settingBundleRootPlist.toXmlString(pretty: true);

    settingBundleRootPlistFile
        .writeAsStringSync(modifiedSettingBundleRootPlistString, flush: true);
  }

  static Future<void> createDartLicensePlist(
      List<PackageInfo> packageInfoList) async {
    Logger.info("Generating license plist...");
    final Map<String, String> environment = Platform.environment;

    final String libraryLicensePlistDirPath =
        "${environment["PWD"]}/ios/Runner/Settings.bundle/dev.nomunomu0504.dart_license_plist/";
    await Directory(libraryLicensePlistDirPath).create(recursive: true);
    Logger.info("dart_license_plist folder path: $libraryLicensePlistDirPath");

    final String dartLicensePlistPath =
        "${environment["PWD"]}/ios/Runner/Settings.bundle/dev.nomunomu0504.dart_license_plist.plist";
    final File dartLicensePlistFile = File(dartLicensePlistPath);
    final List<xml.XmlBuilder> dartLicensePlistDictBuilderList = [];
    final xml.XmlBuilder dartLicensePlistBuilder = xml.XmlBuilder();
    dartLicensePlistBuilder.declaration(version: "1.0", encoding: "UTF-8");
    dartLicensePlistBuilder.xml(
      '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
    );

    for (var packageInfo in packageInfoList) {
      Logger.info("Generating ${packageInfo.name}.plist...");
      final xml.XmlBuilder libraryLicensePlistBuilder = xml.XmlBuilder();
      libraryLicensePlistBuilder.declaration(version: "1.0", encoding: "UTF-8");
      libraryLicensePlistBuilder.xml(
        '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
      );

      libraryLicensePlistBuilder.element(
        "plist",
        attributes: {"version": "1.0"},
        nest: () {
          libraryLicensePlistBuilder.element("dict", nest: () {
            libraryLicensePlistBuilder
              ..element("key", nest: "PreferenceSpecifiers")
              ..element("array", nest: () {
                libraryLicensePlistBuilder.element("dict", nest: () {
                  libraryLicensePlistBuilder
                    ..element("key", nest: "FooterText")
                    ..element("string",
                        nest: packageInfo.licenseInfo.license
                            .replaceAll("\n", "<br>"))
                    ..element("Type", nest: "PSGroupSpecifier");
                });
              });
          });
        },
      );

      final String licensePlistText = libraryLicensePlistBuilder
          .buildDocument()
          .toXmlString(pretty: true)
          .replaceAll("&amp;", "&")
          .replaceAll("&lt;", "<")
          .replaceAll("&gt;", ">")
          .replaceAll("<br>", "\n");
      Logger.debug(licensePlistText);
      final File licensePlistFile =
          File("$libraryLicensePlistDirPath/${packageInfo.name}.plist");
      licensePlistFile.writeAsStringSync(licensePlistText);

      final xml.XmlBuilder dartLicensePlistDictBuilder = xml.XmlBuilder();
      dartLicensePlistDictBuilder
        ..element("key", nest: "File")
        ..element("string", nest: "$packageScheme/${packageInfo.name}")
        ..element("key", nest: "Title")
        ..element("string", nest: packageInfo.name)
        ..element("key", nest: "Type")
        ..element("string", nest: "PSChildPaneSpecifier");
      dartLicensePlistDictBuilderList.add(dartLicensePlistDictBuilder);
    }

    dartLicensePlistBuilder.element(
      "plist",
      attributes: {"version": "1.0"},
      nest: () {
        dartLicensePlistBuilder.element("dict", nest: () {
          dartLicensePlistBuilder
            ..element("key", nest: "PreferenceSpecifiers")
            ..element("array", nest: () {
              for (xml.XmlBuilder dartLicensePlistDictBuilder
                  in dartLicensePlistDictBuilderList) {
                dartLicensePlistBuilder.element(
                  "dict",
                  nest: dartLicensePlistDictBuilder.buildFragment(),
                );
              }
            });
        });
      },
    );

    final String dartLicensePlistString = dartLicensePlistBuilder
        .buildDocument()
        .toXmlString(pretty: true)
        .replaceAll("&amp;", "&")
        .replaceAll("&lt;", "<")
        .replaceAll("&gt;", ">")
        .replaceAll("<br>", "\n");
    Logger.debug(dartLicensePlistString);
    dartLicensePlistFile.writeAsStringSync(dartLicensePlistString, flush: true);
  }
}
