enum AppUpdateStatus { none, soft, forced }

class AppUpdateDecision {
  const AppUpdateDecision({
    required this.status,
    this.storeUrl = '',
    this.currentLabel = '',
    this.requiredLabel = '',
  });

  static const none = AppUpdateDecision(status: AppUpdateStatus.none);

  final AppUpdateStatus status;
  final String storeUrl;
  final String currentLabel;
  final String requiredLabel;
}

class AppUpdatePolicy {
  const AppUpdatePolicy({
    required this.minVersion,
    required this.minBuildNumber,
    required this.forceUpdate,
    required this.playStoreUrl,
  });

  final String minVersion;
  final int minBuildNumber;
  final bool forceUpdate;
  final String playStoreUrl;
}

class AppInstallInfo {
  const AppInstallInfo({required this.version, required this.buildNumber});

  final String version;
  final int buildNumber;
}
