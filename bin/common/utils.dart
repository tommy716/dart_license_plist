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
