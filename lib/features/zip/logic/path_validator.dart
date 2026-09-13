import '../../../domain/entities/zip_level.dart';

class PathValidator {
  PathValidator(this.level);

  final ZipLevel level;

  int get _cellCount => level.size * level.size;

  Cell? get endCell {
    for (final e in level.numbers.entries) {
      if (e.value == level.maxNumber) return e.key;
    }
    return null;
  }

  bool inBounds(Cell cell) =>
      cell.row >= 0 &&
      cell.row < level.size &&
      cell.col >= 0 &&
      cell.col < level.size;

  bool isBlocked(Cell from, Cell to) {
    for (final wall in level.walls) {
      if (wall.blocks(from, to)) return true;
    }
    return false;
  }

  bool isOrthogonalNeighbor(Cell a, Cell b) {
    final dr = (a.row - b.row).abs();
    final dc = (a.col - b.col).abs();
    return (dr + dc) == 1;
  }

  /// Returns next path after attempting to add [candidate], or null if invalid.
  List<Cell>? tryExtend({
    required List<Cell> path,
    required Cell candidate,
    required int nextRequiredNumber,
  }) {
    if (path.isEmpty) {
      final startNum = level.numbers[candidate];
      if (startNum == 1) return [candidate];
      return null;
    }

    // Path already finished on the last number — no further extension.
    if (level.numbers[path.last] == level.maxNumber) {
      return null;
    }

    final tip = path.last;
    if (!isOrthogonalNeighbor(tip, candidate)) return null;
    if (!inBounds(candidate)) return null;
    if (path.contains(candidate)) return null;
    if (isBlocked(tip, candidate)) return null;

    final number = level.numbers[candidate];
    if (number != null && number != nextRequiredNumber) {
      return null;
    }

    // Last number must be the final drawn cell (full board).
    if (number == level.maxNumber) {
      if (path.length + 1 != _cellCount) return null;
    }

    return [...path, candidate];
  }

  /// If [candidate] is earlier on the path, return the truncated path ending there.
  List<Cell>? tryBacktrack({
    required List<Cell> path,
    required Cell candidate,
  }) {
    if (path.length < 2) return null;
    final index = path.indexOf(candidate);
    if (index < 0 || index >= path.length - 1) return null;
    return path.sublist(0, index + 1);
  }

  int nextRequiredAfter(List<Cell> path) {
    var next = 1;
    for (final cell in path) {
      final n = level.numbers[cell];
      if (n != null && n == next) {
        next++;
      }
    }
    return next;
  }

  bool isWon(List<Cell> path) {
    if (path.length != _cellCount) return false;
    if (nextRequiredAfter(path) != level.maxNumber + 1) return false;
    return level.numbers[path.last] == level.maxNumber;
  }
}
