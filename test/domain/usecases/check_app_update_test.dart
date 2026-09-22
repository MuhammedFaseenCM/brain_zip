import 'package:brain_zip/domain/entities/app_update_decision.dart';
import 'package:brain_zip/domain/repositories/app_update_repository.dart';
import 'package:brain_zip/domain/usecases/check_app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppUpdateRepository extends Mock implements AppUpdateRepository {}

void main() {
  late _MockAppUpdateRepository repo;
  late CheckAppUpdate check;

  setUp(() {
    repo = _MockAppUpdateRepository();
    check = CheckAppUpdate(repo);
  });

  test('returns none when minVersion is 0.0.0', () async {
    when(() => repo.getPolicy()).thenAnswer(
      (_) async => const AppUpdatePolicy(
        minVersion: '0.0.0',
        minBuildNumber: 5,
        forceUpdate: true,
        playStoreUrl:
            'https://play.google.com/store/apps/details?id=com.winklo.faseencm',
      ),
    );
    when(() => repo.getInstallInfo()).thenAnswer(
      (_) async => const AppInstallInfo(version: '1.0.0', buildNumber: 1),
    );

    final result = await check();
    expect(result.status, AppUpdateStatus.none);
  });

  test('returns soft when behind and forceUpdate false', () async {
    when(() => repo.getPolicy()).thenAnswer(
      (_) async => const AppUpdatePolicy(
        minVersion: '1.0.0',
        minBuildNumber: 2,
        forceUpdate: false,
        playStoreUrl:
            'https://play.google.com/store/apps/details?id=com.winklo.faseencm',
      ),
    );
    when(() => repo.getInstallInfo()).thenAnswer(
      (_) async => const AppInstallInfo(version: '1.0.0', buildNumber: 1),
    );

    final result = await check();
    expect(result.status, AppUpdateStatus.soft);
    expect(result.currentLabel, '1.0.0+1');
    expect(result.requiredLabel, '1.0.0+2');
    expect(result.storeUrl, contains('com.winklo.faseencm'));
  });

  test('returns forced when behind and forceUpdate true', () async {
    when(() => repo.getPolicy()).thenAnswer(
      (_) async => const AppUpdatePolicy(
        minVersion: '2.0.0',
        minBuildNumber: 0,
        forceUpdate: true,
        playStoreUrl:
            'https://play.google.com/store/apps/details?id=com.winklo.faseencm',
      ),
    );
    when(() => repo.getInstallInfo()).thenAnswer(
      (_) async => const AppInstallInfo(version: '1.0.0', buildNumber: 10),
    );

    final result = await check();
    expect(result.status, AppUpdateStatus.forced);
  });

  test('returns none when playStoreUrl empty', () async {
    when(() => repo.getPolicy()).thenAnswer(
      (_) async => const AppUpdatePolicy(
        minVersion: '9.0.0',
        minBuildNumber: 0,
        forceUpdate: true,
        playStoreUrl: '',
      ),
    );
    when(() => repo.getInstallInfo()).thenAnswer(
      (_) async => const AppInstallInfo(version: '1.0.0', buildNumber: 1),
    );

    final result = await check();
    expect(result.status, AppUpdateStatus.none);
  });

  test('returns none when repository throws', () async {
    when(() => repo.getPolicy()).thenThrow(Exception('offline'));
    final result = await check();
    expect(result.status, AppUpdateStatus.none);
  });
}
