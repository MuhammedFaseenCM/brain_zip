import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class BrainZipApp extends ConsumerStatefulWidget {
  const BrainZipApp({super.key});

  @override
  ConsumerState<BrainZipApp> createState() => _BrainZipAppState();
}

class _BrainZipAppState extends ConsumerState<BrainZipApp> {
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
