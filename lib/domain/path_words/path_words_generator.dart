import 'dart:math';

import '../entities/cell.dart';
import '../entities/path_words_puzzle.dart';
import '../streak_calculator.dart';

abstract final class PathWordsGenerator {
  static const generatorVersion = 1;

  static const int _size = 8;

  static PathWordsPuzzle generate({
    required DateTime day,
    required List<String> words,
  }) {
    final local = day.toLocal();
    final localDay = DateTime(local.year, local.month, local.day);
    final dateId = StreakCalculator.dateId(localDay);
    final seed = Object.hash(dateId, generatorVersion);
    final rng = Random(seed);

    final normalizedWords =
        words
            .map((w) => w.trim().toLowerCase())
            .where((w) => w.isNotEmpty)
            .where((w) => RegExp(r'^[a-z]+$').hasMatch(w))
            .where((w) => w.length >= 4 && w.length <= 10)
            .toSet()
            .toList()
          ..sort();

    final buckets = <int, List<String>>{};
    for (final word in normalizedWords) {
      (buckets[word.length] ??= <String>[]).add(word);
    }

    final viableCompositions = _preferredLengthCompositions
        .where((c) => _compositionIsPossible(c, buckets))
        .toList();

    if (viableCompositions.isEmpty) {
      throw StateError('PathWordsGenerator failed for $dateId');
    }

    const maxAttempts = 80;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final composition =
          viableCompositions[attempt % viableCompositions.length];
      final puzzle = _tryPack(
        rng: rng,
        day: localDay,
        dateId: dateId,
        buckets: buckets,
        composition: composition,
      );
      if (puzzle != null) {
        return puzzle;
      }
    }

    throw StateError('PathWordsGenerator failed for $dateId');
  }

  static PathWordsPuzzle? _tryPack({
    required Random rng,
    required DateTime day,
    required String dateId,
    required Map<int, List<String>> buckets,
    required List<int> composition,
  }) {
    final lengths = [...composition]..shuffle(rng);

    final availableByLength = <int, List<String>>{};
    final chosenWords = <String>[];

    for (final len in lengths) {
      final pool = (availableByLength[len] ??= [...?buckets[len]]
        ..shuffle(rng));
      if (pool.isEmpty) return null;
      chosenWords.add(pool.removeLast());
    }

    final occupied = <Cell>{};
    final letters = List<String?>.filled(_size * _size, null);
    final targets = <PathWordsTarget>[];

    final fullPath = _buildFullCoverPath(rng);
    var cursor = 0;

    for (var i = 0; i < chosenWords.length; i++) {
      final word = chosenWords[i];
      final len = word.length;
      final path = fullPath.sublist(cursor, cursor + len);
      cursor += len;

      for (var j = 0; j < path.length; j++) {
        final cell = path[j];
        occupied.add(cell);
        letters[cell.row * _size + cell.col] = word[j];
      }

      targets.add(
        PathWordsTarget(
          id: 'path_words_${dateId}_$i',
          word: word,
          start: path.first,
          path: path,
          colorIndex: i,
        ),
      );
    }

    if (occupied.length != _size * _size || letters.any((c) => c == null)) {
      return null;
    }

    return PathWordsPuzzle(
      id: 'path_words_$dateId',
      day: day,
      size: _size,
      letters: letters.cast<String>(),
      targets: targets,
    );
  }

  static List<Cell> _buildFullCoverPath(Random rng) {
    final base = _snakePath();
    final rotation = rng.nextInt(4);
    final reflect = rng.nextBool();
    final reverse = rng.nextBool();

    final max = _size - 1;
    Cell transform(Cell cell) {
      var r = cell.row;
      var c = cell.col;

      switch (rotation) {
        case 0:
          break;
        case 1:
          (r, c) = (c, max - r);
          break;
        case 2:
          (r, c) = (max - r, max - c);
          break;
        case 3:
          (r, c) = (max - c, r);
          break;
      }

      if (reflect) {
        c = max - c;
      }

      return Cell(r, c);
    }

    final transformed = base.map(transform).toList(growable: false);
    if (reverse) {
      return transformed.reversed.toList(growable: false);
    }
    return transformed;
  }

  static List<Cell> _snakePath() {
    final path = <Cell>[];
    for (var row = 0; row < _size; row++) {
      if (row.isEven) {
        for (var col = 0; col < _size; col++) {
          path.add(Cell(row, col));
        }
      } else {
        for (var col = _size - 1; col >= 0; col--) {
          path.add(Cell(row, col));
        }
      }
    }
    return path;
  }

  static bool _compositionIsPossible(
    List<int> composition,
    Map<int, List<String>> buckets,
  ) {
    final counts = <int, int>{};
    for (final len in composition) {
      counts[len] = (counts[len] ?? 0) + 1;
    }
    for (final entry in counts.entries) {
      final available = buckets[entry.key]?.length ?? 0;
      if (available < entry.value) return false;
    }
    return composition.fold<int>(0, (sum, n) => sum + n) == _size * _size;
  }

  static const List<List<int>> _preferredLengthCompositions = [
    // Primary.
    [10, 9, 8, 7, 6, 6, 5, 5, 4, 4],

    // Backups.
    [10, 10, 10, 10, 8, 6, 5, 5],
    [10, 10, 9, 8, 7, 6, 5, 5, 4],
    [10, 9, 9, 8, 6, 6, 6, 5, 5],
    [10, 9, 8, 8, 7, 7, 5, 5, 5],
    [9, 9, 9, 9, 7, 7, 7, 7],
    [9, 9, 8, 8, 8, 8, 7, 7],
    [8, 8, 8, 8, 8, 8, 8, 8],
    [7, 7, 7, 7, 7, 7, 7, 7, 8],
    [6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5],
    [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
  ];
}
