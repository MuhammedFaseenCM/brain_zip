import 'package:brain_zip/domain/entities/cell.dart';
import 'package:brain_zip/domain/entities/path_words_puzzle.dart';
import 'package:brain_zip/domain/path_words/path_words_rules.dart';
import 'package:flutter_test/flutter_test.dart';

PathWordsPuzzle tinyPuzzle() {
  // 2x2: "ab" along row0, "cd" along row1
  return PathWordsPuzzle(
    id: 't',
    day: DateTime(2026, 9, 17),
    size: 2,
    letters: const ['a', 'b', 'c', 'd'],
    targets: [
      PathWordsTarget(
        id: 't0',
        word: 'ab',
        start: const Cell(0, 0),
        path: const [Cell(0, 0), Cell(0, 1)],
        colorIndex: 0,
      ),
      PathWordsTarget(
        id: 't1',
        word: 'cd',
        start: const Cell(1, 0),
        path: const [Cell(1, 0), Cell(1, 1)],
        colorIndex: 1,
      ),
    ],
  );
}

void main() {
  final puzzle = tinyPuzzle();

  test('tryBegin allows any letter cell that is not locked', () {
    expect(
      PathWordsRules.tryBegin(
        puzzle: puzzle,
        cell: const Cell(0, 0),
        locked: {},
        completedTargetIds: {},
      ),
      [const Cell(0, 0)],
    );
    expect(
      PathWordsRules.tryBegin(
        puzzle: puzzle,
        cell: const Cell(0, 1),
        locked: {},
        completedTargetIds: {},
      ),
      [const Cell(0, 1)],
    );
    expect(
      PathWordsRules.tryBegin(
        puzzle: puzzle,
        cell: const Cell(0, 1),
        locked: {const Cell(0, 1)},
        completedTargetIds: {'t0'},
      ),
      isNull,
    );
  });

  test('tryExtend rejects blank unused cells', () {
    final sparse = PathWordsPuzzle(
      id: 'sparse',
      day: DateTime(2026, 9, 17),
      size: 2,
      letters: const ['a', 'b', '', ''],
      targets: const [
        PathWordsTarget(
          id: 't0',
          word: 'ab',
          start: Cell(0, 0),
          path: [Cell(0, 0), Cell(0, 1)],
          colorIndex: 0,
        ),
      ],
    );
    expect(
      PathWordsRules.tryBegin(
        puzzle: sparse,
        cell: const Cell(1, 0),
        locked: {},
        completedTargetIds: {},
      ),
      isNull,
    );
    expect(
      PathWordsRules.tryExtend(
        puzzle: sparse,
        path: const [Cell(0, 0)],
        candidate: const Cell(1, 0),
        locked: {},
      ),
      isNull,
    );
  });

  test('tryExtend rejects diagonal and locked', () {
    final path = [const Cell(0, 0)];
    expect(
      PathWordsRules.tryExtend(
        puzzle: puzzle,
        path: path,
        candidate: const Cell(1, 1),
        locked: {},
      ),
      isNull,
    );
    expect(
      PathWordsRules.tryExtend(
        puzzle: puzzle,
        path: path,
        candidate: const Cell(0, 1),
        locked: {const Cell(0, 1)},
      ),
      isNull,
    );
  });

  test('completedTarget matches the official path only, not reverse', () {
    expect(
      PathWordsRules.completedTarget(
        puzzle: puzzle,
        path: const [Cell(0, 0), Cell(0, 1)],
        completedTargetIds: {},
      )?.id,
      't0',
    );
    expect(
      PathWordsRules.completedTarget(
        puzzle: puzzle,
        path: const [Cell(0, 1), Cell(0, 0)],
        completedTargetIds: {},
      ),
      isNull,
    );
  });

  test('hintedPath grows connected cells on the unsolved word', () {
    expect(
      PathWordsRules.hintedPath(
        puzzle: puzzle,
        completedTargetIds: {},
        revealedLength: 1,
      ),
      [const Cell(0, 0)],
    );
    expect(
      PathWordsRules.hintedPath(
        puzzle: puzzle,
        completedTargetIds: {},
        revealedLength: 2,
      ),
      [const Cell(0, 0), const Cell(0, 1)],
    );
    expect(
      PathWordsRules.hintedPath(
        puzzle: puzzle,
        completedTargetIds: {},
        revealedLength: 3,
      ),
      [const Cell(0, 0), const Cell(0, 1)],
    );
  });

  test(
    'hintedPath moves to the next word only after the current one is solved',
    () {
      expect(
        PathWordsRules.hintedPath(
          puzzle: puzzle,
          completedTargetIds: {'t0'},
          revealedLength: 1,
        ),
        [const Cell(1, 0)],
      );
      expect(
        PathWordsRules.hintedPath(
          puzzle: puzzle,
          completedTargetIds: {'t0'},
          revealedLength: 2,
        ),
        [const Cell(1, 0), const Cell(1, 1)],
      );
    },
  );

  test('undoActive pops last', () {
    expect(PathWordsRules.undoActive(const [Cell(0, 0), Cell(0, 1)]), [
      const Cell(0, 0),
    ]);
  });

  test('activeTarget matches a word from either end, else the live drag', () {
    expect(
      PathWordsRules.activeTarget(
        puzzle: puzzle,
        activePath: const [Cell(1, 0), Cell(1, 1)],
        completedTargetIds: {},
      )?.id,
      't1',
    );
    expect(
      PathWordsRules.activeTarget(
        puzzle: puzzle,
        activePath: const [Cell(0, 1)],
        completedTargetIds: {},
      )?.id,
      't0',
    );
    expect(
      PathWordsRules.activeTarget(
        puzzle: puzzle,
        activePath: const [Cell(0, 0)],
        completedTargetIds: {'t0'},
      )?.id,
      't1',
    );
  });
}
