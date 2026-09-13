import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class BrainZipApp extends StatefulWidget {
  const BrainZipApp({super.key});

  @override
  State<BrainZipApp> createState() => _BrainZipAppState();
}

class _BrainZipAppState extends State<BrainZipApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Zip',
      theme: buildAppTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
