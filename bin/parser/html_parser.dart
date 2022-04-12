/*
 * html_parser.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'package:collection/collection.dart';
import 'package:html/dom.dart';

/// A class that html parser.
class HtmlParser {
  static Element? parseLicenseDom(Document html) {
    return html.querySelectorAll("a").firstWhereOrNull(
          (dom) => dom.text == "LICENSE" || dom.text == "LICENSE.md",
        );
  }

  static Element? parseLicenseTextDom(Document html) {
    final Element? preLicense = html.querySelectorAll("pre").firstOrNull;
    if (preLicense != null) {
      return preLicense;
    }

    final Element? markdownLicenseContent =
        html.getElementsByClassName("detail-tab-license-content").firstOrNull;
    if (markdownLicenseContent == null) {
      return null;
    }

    final List<Element> licenseTextNodeList = markdownLicenseContent.children
        .where(
          (element) => !element.localName!.contains(RegExp(r'^h\d{1}$')),
        )
        .toList();

    return Element.tag("p")
      ..text = licenseTextNodeList
          .map(
            (element) => element.text,
          )
          .toList()
          .join("\n");
  }
}
