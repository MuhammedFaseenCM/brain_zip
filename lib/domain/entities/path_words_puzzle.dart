import 'cell.dart';

/// A stroke released onto the board. [targetId] is set only when it matches
/// a remaining solution path.
class PathWordsStroke {
  const PathWordsStroke({
    required this.cells,
    required this.colorIndex,
    this.targetId,
  });

  final List<Cell> cells;
  final int colorIndex;
  final String? targetId;

  bool get isCorrect => targetId != null;

  @override
  bool operator ==(Object other) {
    if (other is! PathWordsStroke) return false;
    if (colorIndex != other.colorIndex || targetId != other.targetId) {
      return false;
    }
    if (cells.length != other.cells.length) return false;
    for (var i = 0; i < cells.length; i++) {
      if (cells[i] != other.cells[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(colorIndex, targetId, Object.hashAll(cells));
}

/// Letters shown in one word-list row for a live or incorrect stroke.
class PathWordsListFill {
  const PathWordsListFill({
    required this.letters,
    required this.colorIndex,
    required this.slotLength,
  });

  final List<String> letters;
  final int colorIndex;
  final int slotLength;

  int get overflowCount {
    final extra = letters.length - slotLength;
    return extra > 0 ? extra : 0;
  }
}

class PathWordsTarget {
  const PathWordsTarget({
    required this.id,
    required this.word,
    required this.start,
    required this.path,
    required this.colorIndex,
  });

  final String id;
  final String word;
  final Cell start;
  final List<Cell> path;
  final int colorIndex;
}

class PathWordsPuzzle {
  const PathWordsPuzzle({
    required this.id,
    required this.day,
    required this.size,
    required this.letters,
    required this.targets,
  });

  final String id;
  final DateTime day;
  final int size;

  /// Row-major, length `size * size`. Lowercase letters, or empty for unused cells.
  final List<String> letters;
  final List<PathWordsTarget> targets;

  String letterAt(Cell cell) => letters[cell.row * size + cell.col];

  bool hasLetter(Cell cell) => letterAt(cell).isNotEmpty;
}
