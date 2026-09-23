import 'package:winklo/domain/entities/app_update_decision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('none factory has empty labels and none status', () {
    const d = AppUpdateDecision.none;
    expect(d.status, AppUpdateStatus.none);
    expect(d.storeUrl, isEmpty);
    expect(d.currentLabel, isEmpty);
    expect(d.requiredLabel, isEmpty);
  });
}
