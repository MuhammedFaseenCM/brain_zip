// Temporary switches for local playtesting. Keep these off for shipping.
import 'package:flutter/foundation.dart';

import '../domain/play_period.dart';

abstract final class DevFlags {
  /// Home shows only Zip, and today's Zip can be played again.
  static const zipOnlyTesting = false;

  /// Widget tests run in debug; keep the daily keyspace stable there.
  static bool useDailyPlayPeriodInTests = false;

  /// Debug builds rotate a new puzzle and unlock every minute.
  static bool get minutePlayPeriod => kDebugMode && !useDailyPlayPeriodInTests;

  static Duration get playPeriod =>
      minutePlayPeriod ? PlayPeriod.minute : PlayPeriod.daily;
}
