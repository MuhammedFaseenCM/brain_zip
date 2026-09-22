import 'package:brain_zip/domain/play_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily ids stay YYYYMMDD', () {
    expect(
      PlayPeriod.id(DateTime(2026, 9, 20, 14, 31), PlayPeriod.daily),
      '20260920',
    );
    expect(
      PlayPeriod.bucket(DateTime(2026, 9, 20, 14, 31), PlayPeriod.daily),
      DateTime(2026, 9, 20),
    );
  });

  test('minute ids include hour and minute', () {
    expect(
      PlayPeriod.id(DateTime(2026, 9, 20, 14, 31, 59), PlayPeriod.minute),
      '202609201431',
    );
    expect(
      PlayPeriod.bucket(DateTime(2026, 9, 20, 14, 31, 59), PlayPeriod.minute),
      DateTime(2026, 9, 20, 14, 31),
    );
  });

  test('adjacent minutes get different ids', () {
    expect(
      PlayPeriod.id(DateTime(2026, 9, 20, 14, 31), PlayPeriod.minute),
      isNot(PlayPeriod.id(DateTime(2026, 9, 20, 14, 32), PlayPeriod.minute)),
    );
  });
}
