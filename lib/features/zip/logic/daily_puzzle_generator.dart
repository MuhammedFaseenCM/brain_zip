import 'dart:math';

import '../../../data/models/zip_level.dart';

/// Daily Zip puzzles in the style of popular path-fill games:
/// grids about 6–8, checkpoints from 1 up to at most 15.
class DailyPuzzleGenerator {
  DailyPuzzleGenerator._();

  static const int maxNumbers = 15;
  static const List<int> _gridSizes = [6, 6, 7, 7, 8];

  static String dateId(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return 'daily_$y$m$d';
  }

  static String displayDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final local = DateTime(date.year, date.month, date.day);
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  static int seedFor(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return local.year * 10000 + local.month * 100 + local.day;
  }

  /// Same calendar day → same puzzle for every player.
  static ZipLevel forDate(DateTime date) {
    final seed = seedFor(date);
    final rng = Random(seed);
    final size = _gridSizes[seed % _gridSizes.length];
    final path = _orientedSerpentine(size, rng);
    final numberCount = _numberCountFor(size, rng);
    final numbers = _placeNumbers(path, numberCount);
    final walls = _placeWalls(size, path, rng);

    return ZipLevel(
      id: dateId(date),
      size: size,
      numbers: numbers,
      walls: walls,
      order: seed,
    );
  }

  static ZipLevel today([DateTime? now]) => forDate(now ?? DateTime.now());

  static int _numberCountFor(int size, Random rng) {
    final cells = size * size;
    final minCount = size <= 6 ? 6 : 8;
    final maxCount = min(maxNumbers, cells);
    final lo = min(minCount, maxCount);
    return lo + rng.nextInt(maxCount - lo + 1);
  }

  static List<Cell> _orientedSerpentine(int size, Random rng) {
    var path = _serpentine(size);

    // Apply geometric transforms that preserve adjacency along the path.
    for (var i = 0; i < rng.nextInt(4); i++) {
      path = _rotate90(path, size);
    }
    if (rng.nextBool()) {
      path = path.map((c) => Cell(c.row, size - 1 - c.col)).toList();
    }
    if (rng.nextBool()) {
      path = path.reversed.toList();
    }
    return path;
  }

  static List<Cell> _serpentine(int size) {
    final path = <Cell>[];
    for (var r = 0; r < size; r++) {
      if (r.isEven) {
        for (var c = 0; c < size; c++) {
          path.add(Cell(r, c));
        }
      } else {
        for (var c = size - 1; c >= 0; c--) {
          path.add(Cell(r, c));
        }
      }
    }
    return path;
  }

  static List<Cell> _rotate90(List<Cell> path, int size) {
    return path.map((c) => Cell(c.col, size - 1 - c.row)).toList();
  }

  static Map<Cell, int> _placeNumbers(List<Cell> path, int count) {
    final numbers = <Cell, int>{};
    final span = path.length - 1;
    for (var n = 1; n <= count; n++) {
      final index = count == 1 ? 0 : ((span * (n - 1)) / (count - 1)).round();
      numbers[path[index]] = n;
    }
    return numbers;
  }

  static List<Wall> _placeWalls(int size, List<Cell> path, Random rng) {
    final onPath = <String>{};
    for (var i = 0; i < path.length - 1; i++) {
      onPath.add(_edgeKey(path[i], path[i + 1]));
    }

    final candidates = <Wall>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final a = Cell(r, c);
        if (c + 1 < size) {
          final b = Cell(r, c + 1);
          if (!onPath.contains(_edgeKey(a, b))) {
            candidates.add(Wall(a, b));
          }
        }
        if (r + 1 < size) {
          final b = Cell(r + 1, c);
          if (!onPath.contains(_edgeKey(a, b))) {
            candidates.add(Wall(a, b));
          }
        }
      }
    }

    candidates.shuffle(rng);
    final wallCount = min(candidates.length, 2 + rng.nextInt(size));
    return candidates.take(wallCount).toList();
  }

  static String _edgeKey(Cell a, Cell b) {
    final first = a.row < b.row || (a.row == b.row && a.col <= b.col) ? a : b;
    final second = first == a ? b : a;
    return '${first.row},${first.col}|${second.row},${second.col}';
  }
}
