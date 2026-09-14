import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/strings/app_strings.dart';
import 'core/theme/app_theme.dart';

class WinkloApp extends StatefulWidget {
  const WinkloApp({super.key});

  @override
  State<WinkloApp> createState() => _WinkloAppState();
}

class _WinkloAppState extends State<WinkloApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appTitle,
      theme: buildAppTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
