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

  test('tryBegin only on unfinished starts', () {
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

  test('completedTarget matches full solution path', () {
    final path = [const Cell(0, 0), const Cell(0, 1)];
    expect(
      PathWordsRules.completedTarget(
        puzzle: puzzle,
        path: path,
        completedTargetIds: {},
      )?.id,
      't0',
    );
  });

  test('nextHintCell returns start then next along first unfinished', () {
    expect(
      PathWordsRules.nextHintCell(
        puzzle: puzzle,
        activePath: const [],
        completedTargetIds: {},
      ),
      const Cell(0, 0),
    );
    expect(
      PathWordsRules.nextHintCell(
        puzzle: puzzle,
        activePath: const [Cell(0, 0)],
        completedTargetIds: {},
      ),
      const Cell(0, 1),
    );
  });

  test('undoActive pops last', () {
    expect(PathWordsRules.undoActive(const [Cell(0, 0), Cell(0, 1)]), [
      const Cell(0, 0),
    ]);
  });
}
