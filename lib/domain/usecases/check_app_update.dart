import '../app_version.dart';
import '../entities/app_update_decision.dart';
import '../repositories/app_update_repository.dart';

class CheckAppUpdate {
  CheckAppUpdate(this._repo);

  final AppUpdateRepository _repo;

  Future<AppUpdateDecision> call() async {
    try {
      final policy = await _repo.getPolicy();
      final install = await _repo.getInstallInfo();

      final minVersion = policy.minVersion.trim();
      if (minVersion.isEmpty || minVersion == '0.0.0') {
        return AppUpdateDecision.none;
      }

      final storeUrl = policy.playStoreUrl.trim();
      if (storeUrl.isEmpty) {
        return AppUpdateDecision.none;
      }

      final needed = isAppUpdateRequired(
        currentVersion: install.version,
        currentBuild: install.buildNumber,
        minVersion: minVersion,
        minBuild: policy.minBuildNumber,
      );
      if (!needed) return AppUpdateDecision.none;

      return AppUpdateDecision(
        status: policy.forceUpdate
            ? AppUpdateStatus.forced
            : AppUpdateStatus.soft,
        storeUrl: storeUrl,
        currentLabel: '${install.version}+${install.buildNumber}',
        requiredLabel: '$minVersion+${policy.minBuildNumber}',
      );
    } catch (_) {
      return AppUpdateDecision.none;
    }
  }
}
