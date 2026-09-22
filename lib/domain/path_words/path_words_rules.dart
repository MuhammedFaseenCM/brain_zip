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
    if (!puzzle.hasLetter(cell)) {
      return null;
    }
    return [cell];
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
    if (!puzzle.hasLetter(candidate)) {
      return null;
    }
    if (path.contains(candidate)) {
      return null;
    }
    return [...path, candidate];
  }

  static PathWordsTarget? activeTarget({
    required PathWordsPuzzle puzzle,
    required List<Cell> activePath,
    required Set<String> completedTargetIds,
  }) {
    if (activePath.isEmpty) {
      return null;
    }
    final start = activePath.first;
    PathWordsTarget? fallback;
    for (final target in puzzle.targets) {
      if (completedTargetIds.contains(target.id)) {
        continue;
      }
      fallback ??= target;
      final reversed = target.path.reversed.toList();
      if (start == target.start ||
          start == reversed.first ||
          _isPrefix(activePath, target.path) ||
          _isPrefix(activePath, reversed)) {
        return target;
      }
    }
    return fallback;
  }

  /// Empty word-list row to fill while dragging, without revealing the official word.
  static PathWordsTarget? liveFillTarget({
    required PathWordsPuzzle puzzle,
    required List<Cell> activePath,
    required Set<String> completedTargetIds,
  }) {
    if (activePath.isEmpty) return null;
    final empty = [
      for (final target in orderedTargets(puzzle))
        if (!completedTargetIds.contains(target.id)) target,
    ];
    if (empty.isEmpty) return null;

    final n = activePath.length;
    final exact = [
      for (final t in empty)
        if (t.word.length == n) t,
    ];
    if (exact.isNotEmpty) {
      return exact[_stablePick(activePath, exact.length)];
    }
    final longer = [
      for (final t in empty)
        if (t.word.length > n) t,
    ];
    if (longer.isNotEmpty) return longer.first;
    return empty.last;
  }

  static List<PathWordsTarget> orderedTargets(PathWordsPuzzle puzzle) {
    return [...puzzle.targets]..sort((a, b) {
      final byLength = a.word.length.compareTo(b.word.length);
      if (byLength != 0) return byLength;
      return a.id.compareTo(b.id);
    });
  }

  static int _stablePick(List<Cell> path, int count) {
    final first = path.first;
    return (first.row * 31 + first.col * 17 + path.length * 13).abs() % count;
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

  /// True when the released path is the same length as an unfinished word
  /// but does not match any remaining target (user thought they finished).
  static bool looksLikeFailedWordAttempt({
    required PathWordsPuzzle puzzle,
    required List<Cell> path,
    required Set<String> completedTargetIds,
  }) {
    if (path.length < 2) return false;
    if (completedTarget(
          puzzle: puzzle,
          path: path,
          completedTargetIds: completedTargetIds,
        ) !=
        null) {
      return false;
    }
    for (final target in puzzle.targets) {
      if (completedTargetIds.contains(target.id)) continue;
      if (target.path.length == path.length) return true;
    }
    return false;
  }

  static List<Cell> hintedPath({
    required PathWordsPuzzle puzzle,
    required Set<String> completedTargetIds,
    required int revealedLength,
  }) {
    if (revealedLength <= 0) {
      return const [];
    }
    for (final target in puzzle.targets) {
      if (completedTargetIds.contains(target.id)) {
        continue;
      }
      final end = revealedLength < target.path.length
          ? revealedLength
          : target.path.length;
      return target.path.sublist(0, end);
    }
    return const [];
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
