import '../entities/app_update_decision.dart';

abstract class AppUpdateRepository {
  Future<AppUpdatePolicy> getPolicy();
  Future<AppInstallInfo> getInstallInfo();
  Future<bool> openStore(String storeUrl);
}
