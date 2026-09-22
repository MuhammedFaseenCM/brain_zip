import 'package:flutter_test/flutter_test.dart';

import 'package:brain_zip/domain/entities/zip_level.dart';
import 'package:brain_zip/features/zip/logic/path_validator.dart';

void main() {
  late PathValidator validator;
  late ZipLevel level;

  setUp(() {
    level = ZipLevel(
      id: 't',
      size: 3,
      numbers: {const Cell(0, 0): 1, const Cell(1, 1): 2, const Cell(2, 2): 3},
      walls: const [],
    );
    validator = PathValidator(level);
  });

  test('starts only on number 1', () {
    expect(validator.tryExtend(path: const [], candidate: const Cell(0, 0)), [
      const Cell(0, 0),
    ]);
    expect(
      validator.tryExtend(path: const [], candidate: const Cell(1, 1)),
      isNull,
    );
  });

  test('LIFO backtrack only pops when revisiting the previous cell', () {
    final path = [const Cell(0, 0), const Cell(0, 1), const Cell(0, 2)];
    expect(
      validator.tryLifoBacktrack(path: path, candidate: const Cell(0, 1)),
      [const Cell(0, 0), const Cell(0, 1)],
    );
    expect(
      validator.tryLifoBacktrack(path: path, candidate: const Cell(0, 0)),
      isNull,
    );
  });

  test('tap backtrack truncates to any earlier cell', () {
    final path = [const Cell(0, 0), const Cell(0, 1), const Cell(0, 2)];
    expect(validator.tryBacktrack(path: path, candidate: const Cell(0, 1)), [
      const Cell(0, 0),
      const Cell(0, 1),
    ]);
  });

  test('allows drawing through numbered cells out of order', () {
    final path = [
      const Cell(0, 0),
      const Cell(1, 0),
      const Cell(2, 0),
      const Cell(2, 1),
    ];
    expect(validator.tryExtend(path: path, candidate: const Cell(2, 2)), [
      ...path,
      const Cell(2, 2),
    ]);
  });

  test('can keep drawing after visiting the last number early', () {
    final path = [
      const Cell(0, 0),
      const Cell(1, 0),
      const Cell(2, 0),
      const Cell(2, 1),
      const Cell(2, 2),
    ];
    expect(validator.tryExtend(path: path, candidate: const Cell(1, 2)), [
      ...path,
      const Cell(1, 2),
    ]);
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

  test('cannot extend onto a cell already in the path', () {
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
      validator.tryExtend(path: full, candidate: const Cell(2, 1)),
      isNull,
    );
  });

  test('cannot enter an already drawn neighbor except the previous cell', () {
    final path = [
      const Cell(0, 0),
      const Cell(0, 1),
      const Cell(0, 2),
      const Cell(1, 2),
      const Cell(1, 1),
    ];
    expect(validator.canEnter(path: path, candidate: const Cell(1, 1)), isTrue);
    expect(validator.canEnter(path: path, candidate: const Cell(1, 2)), isTrue);
    expect(validator.canEnter(path: path, candidate: const Cell(2, 1)), isTrue);
    expect(
      validator.canEnter(path: path, candidate: const Cell(0, 1)),
      isFalse,
    );
  });

  test('live reach stops at already drawn cells except LIFO previous', () {
    final path = [
      const Cell(0, 0),
      const Cell(0, 1),
      const Cell(0, 2),
      const Cell(1, 2),
      const Cell(1, 1),
    ];
    expect(validator.liveReachCells(path: path, dRow: -1, dCol: 0), 0);
    expect(validator.liveReachCells(path: path, dRow: 0, dCol: 1), 1);
    expect(validator.liveReachCells(path: path, dRow: 1, dCol: 0), 1.5);
    expect(validator.liveReachCells(path: path, dRow: 0, dCol: -1), 1.5);
  });
}
