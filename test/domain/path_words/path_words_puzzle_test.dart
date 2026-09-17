import 'package:brain_zip/domain/entities/cell.dart';
import 'package:brain_zip/domain/entities/path_words_puzzle.dart';
import 'package:brain_zip/domain/game_ids.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GameIds.pathWords is path_words', () {
    expect(GameIds.pathWords, 'path_words');
  });

  test('letterAt reads row-major grid', () {
    final puzzle = PathWordsPuzzle(
      id: 'path_words_20260917',
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
      ],
    );
    expect(puzzle.letterAt(const Cell(1, 0)), 'c');
  });
}
