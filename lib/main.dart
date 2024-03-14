import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/src/app.dart';
import 'package:portfolio/src/localization/app_localizations.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  setPathUrlStrategy();
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: AppLocalizations.supportedLocales,
        path: AppLocalizations.path,
        fallbackLocale: AppLocalizations.fallbackLocale,
        child: const MyApp(),
      ),
    ),
  );
}
