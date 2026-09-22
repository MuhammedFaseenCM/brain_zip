import 'package:brain_zip/data/clients/remote_config_client.dart';
import 'package:brain_zip/data/repositories/app_update_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteConfigClient extends Mock implements RemoteConfigClient {}

void main() {
  test(
    'getPolicy refreshes then maps remote config into AppUpdatePolicy',
    () async {
      final remote = _MockRemoteConfigClient();
      when(() => remote.refresh()).thenAnswer((_) async => true);
      when(() => remote.appVersion).thenReturn('1.2.0');
      when(() => remote.minBuildNumber).thenReturn(5);
      when(() => remote.forceUpdate).thenReturn(true);
      when(() => remote.playStoreUrl).thenReturn(
        'https://play.google.com/store/apps/details?id=com.winklo.faseencm',
      );

      final repo = AppUpdateRepositoryImpl(remoteConfig: remote);
      final policy = await repo.getPolicy();

      verify(() => remote.refresh()).called(1);
      expect(policy.minVersion, '1.2.0');
      expect(policy.minBuildNumber, 5);
      expect(policy.forceUpdate, isTrue);
      expect(
        policy.playStoreUrl,
        'https://play.google.com/store/apps/details?id=com.winklo.faseencm',
      );
    },
  );
}
