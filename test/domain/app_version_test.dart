import 'package:brain_zip/domain/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compareAppVersions', () {
    test('detects lower patch / minor / major', () {
      expect(compareAppVersions('1.0.0', '1.0.1'), lessThan(0));
      expect(compareAppVersions('1.0.8', '1.1.0'), lessThan(0));
      expect(compareAppVersions('1.9.0', '2.0.0'), lessThan(0));
    });

    test('equal or higher', () {
      expect(compareAppVersions('1.0.8', '1.0.8'), 0);
      expect(compareAppVersions('1.0.9', '1.0.8'), greaterThan(0));
    });

    test('pads missing segments as zero', () {
      expect(compareAppVersions('1.0', '1.0.1'), lessThan(0));
      expect(compareAppVersions('1.0.0', '1.0'), 0);
    });
  });

  group('isAppUpdateRequired', () {
    test('version behind', () {
      expect(
        isAppUpdateRequired(
          currentVersion: '1.0.0',
          currentBuild: 99,
          minVersion: '1.0.1',
          minBuild: 0,
        ),
        isTrue,
      );
    });

    test('same version, build behind', () {
      expect(
        isAppUpdateRequired(
          currentVersion: '1.0.0',
          currentBuild: 2,
          minVersion: '1.0.0',
          minBuild: 3,
        ),
        isTrue,
      );
    });

    test('same version, build ok', () {
      expect(
        isAppUpdateRequired(
          currentVersion: '1.0.0',
          currentBuild: 3,
          minVersion: '1.0.0',
          minBuild: 3,
        ),
        isFalse,
      );
    });

    test('current version higher ignores build', () {
      expect(
        isAppUpdateRequired(
          currentVersion: '1.1.0',
          currentBuild: 1,
          minVersion: '1.0.0',
          minBuild: 99,
        ),
        isFalse,
      );
    });
  });
}
