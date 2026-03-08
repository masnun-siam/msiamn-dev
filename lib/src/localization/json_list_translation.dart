import 'dart:ui';

import 'package:portfolio/src/localization/generated/locale_json.g.dart';

List<Map<String, dynamic>> trList(Locale locale, String key) {
  final mapLocales = CodegenLoader.mapLocales[locale.languageCode];
  final mapValue = mapLocales?[key];
  if (mapValue == null) return [];
  return (mapValue as List).cast<Map>().map(Map<String, dynamic>.from).toList();
}
