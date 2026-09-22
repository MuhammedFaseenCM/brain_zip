import 'package:brain_zip/features/zip/game/zip_stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const a = Offset(0, 0);
  const b = Offset(0, 10);
  const c = Offset(0, 20);

  test('without a live tip, the stroke is the cell centers', () {
    expect(ZipStroke.points(cellCenters: const [a, b, c]), const [a, b, c]);
  });

  test('a live tip on the first cell stretches from the start', () {
    expect(
      ZipStroke.points(cellCenters: const [a], liveTip: const Offset(4, 3)),
      const [a, Offset(4, 0)],
    );
  });

  test('continuing straight replaces the last center with the railed tip', () {
    expect(
      ZipStroke.points(
        cellCenters: const [a, b, c],
        liveTip: const Offset(1, 28),
      ),
      const [a, b, Offset(0, 28)],
    );
  });

  test('turning keeps the last center as a corner', () {
    expect(
      ZipStroke.points(
        cellCenters: const [a, b, c],
        liveTip: const Offset(12, 21),
      ),
      const [a, b, c, Offset(12, 20)],
    );
  });

  test('rail stays inside the allowed bounds', () {
    expect(
      ZipStroke.railWithin(
        origin: const Offset(10, 10),
        finger: const Offset(0, 8),
        bounds: const Rect.fromLTRB(10, 10, 20, 20),
      ),
      const Offset(10, 10),
    );
  });
}
