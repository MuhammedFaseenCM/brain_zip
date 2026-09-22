import 'package:brain_zip/core/theme/app_theme.dart';
import 'package:brain_zip/features/zip/game/zip_path_ribbon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts on ember', () {
    expect(ZipPathRibbon.colorAt(0), ZipColors.ember);
    expect(ZipPathRibbon.colorAt(-1), ZipColors.ember);
  });

  test('shifts hue across each period of cells', () {
    expect(ZipPathRibbon.colorAt(ZipPathRibbon.period), ZipPathRibbon.stops[1]);
    expect(
      ZipPathRibbon.colorAt(ZipPathRibbon.period * 2),
      ZipPathRibbon.stops[2],
    );
  });

  test('interpolates between stops inside a period', () {
    final mid = ZipPathRibbon.colorAt(2);
    expect(mid, isNot(ZipPathRibbon.colorAt(0)));
    expect(mid, isNot(ZipPathRibbon.colorAt(4)));
  });
}
