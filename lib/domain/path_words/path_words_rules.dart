import '../entities/cell.dart';
import '../entities/path_words_puzzle.dart';

class PathWordsRules {
  PathWordsRules._();

  static Set<Cell> lockedCells(
    PathWordsPuzzle puzzle,
    Set<String> completedTargetIds,
  ) {
    final locked = <Cell>{};
    for (final target in puzzle.targets) {
      if (completedTargetIds.contains(target.id)) {
        locked.addAll(target.path);
      }
    }
    return locked;
  }

  static List<Cell>? tryBegin({
    required PathWordsPuzzle puzzle,
    required Cell cell,
    required Set<Cell> locked,
    required Set<String> completedTargetIds,
  }) {
    if (locked.contains(cell)) {
      return null;
    }
    for (final target in puzzle.targets) {
      if (completedTargetIds.contains(target.id)) {
        continue;
      }
      if (target.start == cell) {
        return [cell];
      }
    }
    return null;
  }

  static List<Cell>? tryExtend({
    required PathWordsPuzzle puzzle,
    required List<Cell> path,
    required Cell candidate,
    required Set<Cell> locked,
  }) {
    if (path.isEmpty) {
      return null;
    }
    final last = path.last;
    if (!_isOrthogonal(last, candidate)) {
      return null;
    }
    if (!_inBounds(puzzle, candidate)) {
      return null;
    }
    if (locked.contains(candidate)) {
      return null;
    }
    if (path.contains(candidate)) {
      return null;
    }
    return [...path, candidate];
  }

  static PathWordsTarget? completedTarget({
    required PathWordsPuzzle puzzle,
    required List<Cell> path,
    required Set<String> completedTargetIds,
  }) {
    for (final target in puzzle.targets) {
      if (completedTargetIds.contains(target.id)) {
        continue;
      }
      if (_pathsEqual(path, target.path)) {
        return target;
      }
    }
    return null;
  }

  static Cell? nextHintCell({
    required PathWordsPuzzle puzzle,
    required List<Cell> activePath,
    required Set<String> completedTargetIds,
  }) {
    PathWordsTarget? firstUnfinished;
    for (final target in puzzle.targets) {
      if (!completedTargetIds.contains(target.id)) {
        firstUnfinished = target;
        break;
      }
    }
    if (firstUnfinished == null) {
      return null;
    }
    if (_isPrefix(activePath, firstUnfinished.path)) {
      if (activePath.length >= firstUnfinished.path.length) {
        return null;
      }
      return firstUnfinished.path[activePath.length];
    }
    return firstUnfinished.start;
  }

  static List<Cell> undoActive(List<Cell> path) {
    if (path.isEmpty) {
      return path;
    }
    return path.sublist(0, path.length - 1);
  }

  static bool _isOrthogonal(Cell from, Cell to) {
    final dr = (to.row - from.row).abs();
    final dc = (to.col - from.col).abs();
    return dr + dc == 1;
  }

  static bool _inBounds(PathWordsPuzzle puzzle, Cell cell) {
    return cell.row >= 0 &&
        cell.row < puzzle.size &&
        cell.col >= 0 &&
        cell.col < puzzle.size;
  }

  static bool _pathsEqual(List<Cell> a, List<Cell> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  static bool _isPrefix(List<Cell> prefix, List<Cell> full) {
    if (prefix.length > full.length) {
      return false;
    }
    for (var i = 0; i < prefix.length; i++) {
      if (prefix[i] != full[i]) {
        return false;
      }
    }
    return true;
  }
}
