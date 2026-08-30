import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// The two UI styles the app can render.
enum UiStyle { material, cupertino }

/// Single source of truth for deciding which widget style to use.
///
/// Priority:
///  1. Web → always Material (no native platform chrome).
///  2. iOS / macOS → Cupertino.
///  3. Everything else → Material.
UiStyle resolveUiStyle() {
  if (kIsWeb) return UiStyle.material;
  if (Platform.isIOS || Platform.isMacOS) return UiStyle.cupertino;
  return UiStyle.material;
}
