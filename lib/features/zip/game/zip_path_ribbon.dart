import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Warm Zip ribbon: hue shifts every [period] cells along the path.
abstract final class ZipPathRibbon {
  static const period = 4;

  static const stops = [
    ZipColors.ember,
    Color(0xFFFFC53D),
    Color(0xFFFF4D6D),
    Color(0xFFE879F9),
  ];

  static Color colorAt(int index) {
    if (index <= 0) return stops.first;
    final t = index / period;
    final wrapped = t % stops.length;
    final i = wrapped.floor() % stops.length;
    final next = (i + 1) % stops.length;
    return Color.lerp(stops[i], stops[next], wrapped - wrapped.floor())!;
  }
}
