import 'dart:math' as math;

import 'package:brain_zip/data/repositories/word_list_repository_impl.dart';
import 'package:brain_zip/domain/entities/cell.dart';
import 'package:brain_zip/domain/entities/path_words_puzzle.dart';
import 'package:brain_zip/domain/path_words/path_words_generator.dart';
import 'package:brain_zip/domain/play_period.dart';
import 'package:flutter_test/flutter_test.dart';

int _turnCount(List<Cell> path) {
  var turns = 0;
  for (var i = 2; i < path.length; i++) {
    final d1Row = path[i - 1].row - path[i - 2].row;
    final d1Col = path[i - 1].col - path[i - 2].col;
    final d2Row = path[i].row - path[i - 1].row;
    final d2Col = path[i].col - path[i - 1].col;
    if (d1Row != d2Row || d1Col != d2Col) {
      turns++;
    }
  }
  return turns;
}

bool _rowHasLetter(PathWordsPuzzle puzzle, int row) {
  for (var col = 0; col < puzzle.size; col++) {
    if (puzzle.hasLetter(Cell(row, col))) return true;
  }
  return false;
}

bool _colHasLetter(PathWordsPuzzle puzzle, int col) {
  for (var row = 0; row < puzzle.size; row++) {
    if (puzzle.hasLetter(Cell(row, col))) return true;
  }
  return false;
}

bool _isOrthogonal(Cell a, Cell b) {
  return ((a.row - b.row).abs() + (a.col - b.col).abs()) == 1;
}

void main() {
  late List<String> words;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    words = await WordListRepositoryImpl().loadEnglishWords(
      minLen: 3,
      maxLen: 5,
    );
    expect(words.length, greaterThan(200));
  });

  test('UTC instant uses local calendar date for seed', () {
    final utcLate = DateTime.utc(2026, 9, 17, 23, 0);
    final local = utcLate.toLocal();
    final localCalendarDay = DateTime(local.year, local.month, local.day);
    final fromUtc = PathWordsGenerator.generate(day: utcLate, words: words);
    final fromLocal = PathWordsGenerator.generate(
      day: localCalendarDay,
      words: words,
    );
    expect(fromUtc.id, fromLocal.id);
    expect(fromUtc.letters, fromLocal.letters);
  });

  test('same day is deterministic', () {
    final a = PathWordsGenerator.generate(
      day: DateTime(2026, 9, 17),
      words: words,
    );
    final b = PathWordsGenerator.generate(
      day: DateTime(2026, 9, 17),
      words: words,
    );
    expect(a.letters, b.letters);
    expect(
      a.targets.map((t) => t.word).toList(),
      b.targets.map((t) => t.word).toList(),
    );
  });

  test('minute period gives a new puzzle id each minute', () {
    final a = PathWordsGenerator.generate(
      day: DateTime(2026, 9, 20, 14, 31),
      words: words,
      period: PlayPeriod.minute,
    );
    final b = PathWordsGenerator.generate(
      day: DateTime(2026, 9, 20, 14, 32),
      words: words,
      period: PlayPeriod.minute,
    );
    expect(a.id, 'path_words_202609201431');
    expect(b.id, 'path_words_202609201432');
    expect(a.id, isNot(b.id));
  });

  test('sizes the grid to the packed words', () {
    final p = PathWordsGenerator.generate(
      day: DateTime(2026, 1, 1),
      words: words,
    );
    expect(p.size, inInclusiveRange(3, 6));
    expect(p.letters.length, p.size * p.size);
    expect(p.targets.length, inInclusiveRange(3, 6));

    final seen = <Cell>{};
    for (final t in p.targets) {
      expect(t.word.length, inInclusiveRange(3, 5));
      expect(t.path.first, t.start);
      expect(t.path.length, t.word.length);
      expect(
        _turnCount(t.path),
        greaterThanOrEqualTo(t.word.length <= 3 ? 1 : 2),
      );
      for (var i = 0; i < t.path.length; i++) {
        final c = t.path[i];
        expect(seen.add(c), isTrue);
        expect(p.hasLetter(c), isTrue);
        expect(p.letterAt(c), t.word[i]);
        if (i > 0) {
          expect(_isOrthogonal(t.path[i - 1], c), isTrue);
        }
      }
    }
    final minSize = seen.isEmpty ? 3 : math.sqrt(seen.length).ceil();
    expect(p.size, inInclusiveRange(minSize, math.min(6, minSize + 1)));
    expect(seen.length, lessThanOrEqualTo(p.size * p.size));
    expect(_rowHasLetter(p, 0), isTrue);
    expect(_rowHasLetter(p, p.size - 1), isTrue);
    expect(_colHasLetter(p, 0), isTrue);
    expect(_colHasLetter(p, p.size - 1), isTrue);
    for (var row = 0; row < p.size; row++) {
      for (var col = 0; col < p.size; col++) {
        final cell = Cell(row, col);
        if (seen.contains(cell)) continue;
        expect(p.hasLetter(cell), isFalse);
        expect(p.letterAt(cell), isEmpty);
      }
    }
  });

  test('generates for 30 consecutive days', () {
    final start = DateTime(2026, 9, 1);
    final counts = <int, int>{};
    for (var i = 0; i < 30; i++) {
      final day = start.add(Duration(days: i));
      final puzzle = PathWordsGenerator.generate(day: day, words: words);
      expect(puzzle.targets.length, inInclusiveRange(3, 6));
      expect(puzzle.size, inInclusiveRange(3, 6));
      expect(puzzle.letters.length, puzzle.size * puzzle.size);
      expect(
        puzzle.targets.every((t) => t.word.length >= 3 && t.word.length <= 5),
        isTrue,
      );
      counts[puzzle.targets.length] = (counts[puzzle.targets.length] ?? 0) + 1;
    }
    expect(counts.keys, containsAll([3, 4]));
  });
}
