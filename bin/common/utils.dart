/*
 * utils.dart
 *
 * Copyright (c) 2022 Hiroki Nomura.
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

import 'package:interact/interact.dart' as interact;

bool promptBool(
  String message, {
  bool defaultValue = true,
}) {
  return interact.Confirm(
    prompt: message,
    defaultValue: defaultValue,
  ).interact();
}
