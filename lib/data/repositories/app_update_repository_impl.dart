import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/app_update_decision.dart';
import '../../domain/repositories/app_update_repository.dart';
import '../clients/remote_config_client.dart';

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  AppUpdateRepositoryImpl({RemoteConfigClient? remoteConfig})
    : _remoteConfig = remoteConfig ?? RemoteConfigClient.instance;

  final RemoteConfigClient _remoteConfig;

  @override
  Future<AppUpdatePolicy> getPolicy() async {
    await _remoteConfig.refresh();
    return AppUpdatePolicy(
      minVersion: _remoteConfig.appVersion,
      minBuildNumber: _remoteConfig.minBuildNumber,
      forceUpdate: _remoteConfig.forceUpdate,
      playStoreUrl: _remoteConfig.playStoreUrl,
    );
  }

  @override
  Future<AppInstallInfo> getInstallInfo() async {
    final info = await PackageInfo.fromPlatform();
    return AppInstallInfo(
      version: info.version,
      buildNumber: int.tryParse(info.buildNumber) ?? 0,
    );
  }

  @override
  Future<bool> openStore(String storeUrl) async {
    try {
      final uri = Uri.parse(storeUrl);
      if (!await canLaunchUrl(uri)) return false;
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
