import 'package:flutter_test/flutter_test.dart';

import 'package:brain_zip/data/models/zip_level.dart';
import 'package:brain_zip/features/zip/logic/path_validator.dart';

void main() {
  late PathValidator validator;
  late ZipLevel level;

  setUp(() {
    level = ZipLevel(
      id: 't',
      size: 3,
      numbers: {
        const Cell(0, 0): 1,
        const Cell(1, 1): 2,
        const Cell(2, 2): 3,
      },
      walls: const [],
    );
    validator = PathValidator(level);
  });

  test('starts only on number 1', () {
    expect(
      validator.tryExtend(
        path: const [],
        candidate: const Cell(0, 0),
        nextRequiredNumber: 1,
      ),
      [const Cell(0, 0)],
    );
    expect(
      validator.tryExtend(
        path: const [],
        candidate: const Cell(1, 1),
        nextRequiredNumber: 1,
      ),
      isNull,
    );
  });

  test('backtracks when revisiting earlier cell', () {
    final path = [
      const Cell(0, 0),
      const Cell(0, 1),
      const Cell(0, 2),
    ];
    expect(
      validator.tryBacktrack(path: path, candidate: const Cell(0, 1)),
      [const Cell(0, 0), const Cell(0, 1)],
    );
  });

  test('rejects last number before the board is full', () {
    final path = [
      const Cell(0, 0),
      const Cell(0, 1),
      const Cell(1, 1), // 2
      const Cell(1, 2),
    ];
    expect(
      validator.tryExtend(
        path: path,
        candidate: const Cell(2, 2), // 3 too early
        nextRequiredNumber: 3,
      ),
      isNull,
    );
  });

  test('wins only when path ends on last number with full board', () {
    final winning = [
      const Cell(0, 0), // 1
      const Cell(1, 0),
      const Cell(2, 0),
      const Cell(2, 1),
      const Cell(1, 1), // 2
      const Cell(0, 1),
      const Cell(0, 2),
      const Cell(1, 2),
      const Cell(2, 2), // 3 last
    ];
    expect(validator.isWon(winning), isTrue);

    final altWin = [
      const Cell(0, 0),
      const Cell(0, 1),
      const Cell(0, 2),
      const Cell(1, 2),
      const Cell(1, 1),
      const Cell(1, 0),
      const Cell(2, 0),
      const Cell(2, 1),
      const Cell(2, 2),
    ];
    expect(validator.isWon(altWin), isTrue);

    // Same cells but ends before last number — incomplete path
    expect(validator.isWon(winning.sublist(0, 8)), isFalse);
  });

  test('cannot extend after landing on last number', () {
    final full = [
      const Cell(0, 0),
      const Cell(1, 0),
      const Cell(2, 0),
      const Cell(2, 1),
      const Cell(1, 1),
      const Cell(0, 1),
      const Cell(0, 2),
      const Cell(1, 2),
      const Cell(2, 2),
    ];
    expect(
      validator.tryExtend(
        path: full,
        candidate: const Cell(2, 1),
        nextRequiredNumber: 4,
      ),
      isNull,
    );
  });
}
