import 'cell.dart';

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
