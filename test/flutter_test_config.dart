import 'package:winklo/core/dev_flags.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> testExecutable(Future<void> Function() testMain) async {
  DevFlags.useDailyPlayPeriodInTests = true;
  PackageInfo.setMockInitialValues(
    appName: 'Winklo',
    packageName: 'com.winklo.faseencm',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await testMain();
}
