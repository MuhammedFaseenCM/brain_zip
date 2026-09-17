import '../../../domain/entities/cell.dart';
import '../../../domain/entities/path_words_puzzle.dart';

class PathWordsBoardView {
  const PathWordsBoardView({
    required this.puzzle,
    required this.activePath,
    required this.completedPathsByTargetId,
    required this.hintFlashCell,
    required this.inputEnabled,
  });

  final PathWordsPuzzle puzzle;
  final List<Cell> activePath;
  final Map<String, List<Cell>> completedPathsByTargetId;
  final Cell? hintFlashCell;
  final bool inputEnabled;
}
