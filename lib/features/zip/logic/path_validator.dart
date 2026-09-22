import '../../../domain/entities/zip_level.dart';
import 'zip_rule_tip.dart';

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
  List<Cell>? tryExtend({required List<Cell> path, required Cell candidate}) {
    if (path.isEmpty) {
      final startNum = level.numbers[candidate];
      if (startNum == 1) return [candidate];
      return null;
    }

    final tip = path.last;
    if (!isOrthogonalNeighbor(tip, candidate)) return null;
    if (!inBounds(candidate)) return null;
    if (path.contains(candidate)) return null;
    if (isBlocked(tip, candidate)) return null;

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

  /// Pop only the last cell when [candidate] is the previous cell (LIFO).
  List<Cell>? tryLifoBacktrack({
    required List<Cell> path,
    required Cell candidate,
  }) {
    if (path.length < 2) return null;
    if (candidate != path[path.length - 2]) return null;
    return path.sublist(0, path.length - 1);
  }

  /// Drag may stay on the tip, pop LIFO, or enter an empty neighbor.
  bool canEnter({required List<Cell> path, required Cell candidate}) {
    if (path.isEmpty) {
      return level.numbers[candidate] == 1;
    }
    if (candidate == path.last) return true;
    if (tryLifoBacktrack(path: path, candidate: candidate) != null) {
      return true;
    }
    return tryExtend(path: path, candidate: candidate) != null;
  }

  /// How far a live stroke may stretch from the tip, in cells.
  /// Occupied cells are blocked except the LIFO previous cell.
  double liveReachCells({
    required List<Cell> path,
    required int dRow,
    required int dCol,
  }) {
    if (path.isEmpty) return 0;
    var cell = path.last;
    var empty = 0;
    final previous = path.length >= 2 ? path[path.length - 2] : null;
    while (true) {
      final next = Cell(cell.row + dRow, cell.col + dCol);
      if (!inBounds(next) || isBlocked(cell, next)) {
        return empty == 0 ? 0 : empty + 0.5;
      }
      if (path.contains(next)) {
        if (next == previous) return empty + 1;
        return empty == 0 ? 0 : empty + 0.5;
      }
      empty++;
      cell = next;
    }
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

  /// Tip when a stroke ends without winning, or when start is invalid.
  ZipRuleTip? ruleTipAfterStroke(List<Cell> path) {
    if (path.isEmpty || isWon(path)) return null;

    final lastNum = level.numbers[path.last];
    final endsOnLast = lastNum == level.maxNumber;
    final isFull = path.length == _cellCount;
    final orderComplete = nextRequiredAfter(path) == level.maxNumber + 1;

    if (endsOnLast && !isFull) return ZipRuleTip.fillEveryCell;
    if (isFull && !endsOnLast) return ZipRuleTip.finishOnLast;
    if (isFull && endsOnLast && !orderComplete) return ZipRuleTip.visitInOrder;

    // Landed on a checkpoint early / skipped order without filling the board.
    if (lastNum != null && lastNum > 1 && !orderComplete && !isFull) {
      final expected = nextRequiredAfter(path.sublist(0, path.length - 1));
      if (lastNum != expected) return ZipRuleTip.visitInOrder;
    }

    return null;
  }
}
