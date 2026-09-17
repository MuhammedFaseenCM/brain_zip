import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/cell.dart';
import '../../../domain/entities/path_words_puzzle.dart';
import '../../results/results_args.dart';

part 'path_words_state.freezed.dart';

enum PathWordsStatus { loading, ready, playing, submitting, navigating, failed }

@freezed
sealed class PathWordsState with _$PathWordsState {
  const factory PathWordsState({
    required DateTime day,
    PathWordsPuzzle? puzzle,
    @Default(PathWordsStatus.loading) PathWordsStatus status,
    @Default(<Cell>[]) List<Cell> activePath,
    @Default(<String>{}) Set<String> completedTargetIds,
    @Default(3) int hintsRemaining,
    DateTime? startedAt,
    Cell? hintFlashCell,
    String? errorMessage,
    @Default(false) bool finished,
    int? points,
    int? timeSeconds,
    bool? improved,
    ResultsArgs? resultsExtra,
  }) = _PathWordsState;

  factory PathWordsState.initial(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    return PathWordsState(day: day);
  }
}
