import 'package:bloc/bloc.dart';

import '../../../core/strings/app_strings.dart';
import '../../../domain/game_ids.dart';
import '../../../domain/path_words/path_words_rules.dart';
import '../../../domain/path_words/path_words_scoring.dart';
import '../../../domain/streak_calculator.dart';
import '../../../domain/usecases/generate_daily_path_words.dart';
import '../../../domain/usecases/record_daily_clear.dart';
import '../../../domain/usecases/submit_score.dart';
import '../../results/results_args.dart';
import 'path_words_event.dart';
import 'path_words_state.dart';

class PathWordsBloc extends Bloc<PathWordsEvent, PathWordsState> {
  PathWordsBloc({
    required this.generateDailyPathWords,
    required this.submitScore,
    required this.recordDailyClear,
    DateTime Function()? now,
    Future<void> Function(Duration duration)? wait,
    this.celebrationDuration = const Duration(seconds: 2),
  }) : _now = now ?? DateTime.now,
       _wait = wait ?? ((duration) => Future<void>.delayed(duration)),
       super(PathWordsState.initial((now ?? DateTime.now)())) {
    on<PathWordsStarted>(_onStarted);
    on<PathWordsPointerDown>(_onPointerDown);
    on<PathWordsPointerEnter>(_onPointerEnter);
    on<PathWordsPointerUp>(_onPointerUp);
    on<PathWordsUndo>(_onUndo);
    on<PathWordsHint>(_onHint);
    on<PathWordsReset>(_onReset);
  }

  final GenerateDailyPathWords generateDailyPathWords;
  final SubmitScore submitScore;
  final RecordDailyClear recordDailyClear;
  final Duration celebrationDuration;
  final DateTime Function() _now;
  final Future<void> Function(Duration duration) _wait;

  Future<void> _onStarted(
    PathWordsStarted event,
    Emitter<PathWordsState> emit,
  ) async {
    final seed = event.date ?? _now();
    final day = DateTime(seed.year, seed.month, seed.day);

    emit(
      state.copyWith(
        status: PathWordsStatus.loading,
        day: day,
        puzzle: null,
        activePath: const [],
        completedTargetIds: const {},
        hintsRemaining: 3,
        hintRevealLength: 0,
        startedAt: null,
        hintFlashCell: null,
        errorMessage: null,
        finished: false,
        points: null,
        timeSeconds: null,
        improved: null,
        resultsExtra: null,
      ),
    );

    try {
      final puzzle = await generateDailyPathWords(day: day);
      if (emit.isDone) return;

      emit(
        state.copyWith(
          status: PathWordsStatus.ready,
          puzzle: puzzle,
          startedAt: _now(),
          hintsRemaining: 3,
          hintRevealLength: 0,
          activePath: const [],
          completedTargetIds: const {},
          hintFlashCell: null,
          errorMessage: null,
          finished: false,
          points: null,
          timeSeconds: null,
          improved: null,
          resultsExtra: null,
        ),
      );
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(status: PathWordsStatus.failed, errorMessage: '$e'));
    }
  }

  void _onPointerDown(
    PathWordsPointerDown event,
    Emitter<PathWordsState> emit,
  ) {
    if (state.finished) return;
    if (state.status != PathWordsStatus.ready &&
        state.status != PathWordsStatus.playing) {
      return;
    }
    final puzzle = state.puzzle;
    if (puzzle == null) return;

    final locked = PathWordsRules.lockedCells(puzzle, state.completedTargetIds);
    final begun = PathWordsRules.tryBegin(
      puzzle: puzzle,
      cell: event.cell,
      locked: locked,
      completedTargetIds: state.completedTargetIds,
    );

    if (begun == null) {
      if (state.hintFlashCell == null) return;
      emit(state.copyWith(hintFlashCell: null));
      return;
    }

    emit(
      state.copyWith(
        status: PathWordsStatus.playing,
        activePath: begun,
        hintFlashCell: null,
      ),
    );
  }

  void _onPointerEnter(
    PathWordsPointerEnter event,
    Emitter<PathWordsState> emit,
  ) {
    if (state.finished) return;
    if (state.status != PathWordsStatus.ready &&
        state.status != PathWordsStatus.playing) {
      return;
    }
    final puzzle = state.puzzle;
    if (puzzle == null) return;
    if (state.activePath.isEmpty) return;

    final locked = PathWordsRules.lockedCells(puzzle, state.completedTargetIds);
    final next = PathWordsRules.tryExtend(
      puzzle: puzzle,
      path: state.activePath,
      candidate: event.cell,
      locked: locked,
    );
    if (next == null) return;

    emit(
      state.copyWith(
        status: PathWordsStatus.playing,
        activePath: next,
        hintFlashCell: null,
      ),
    );
  }

  Future<void> _onPointerUp(
    PathWordsPointerUp event,
    Emitter<PathWordsState> emit,
  ) async {
    if (state.finished) return;
    if (state.status != PathWordsStatus.ready &&
        state.status != PathWordsStatus.playing) {
      return;
    }
    final puzzle = state.puzzle;
    if (puzzle == null) return;
    if (state.activePath.isEmpty) return;

    final completed = PathWordsRules.completedTarget(
      puzzle: puzzle,
      path: state.activePath,
      completedTargetIds: state.completedTargetIds,
    );

    if (completed == null) {
      if (state.hintFlashCell == null) return;
      emit(state.copyWith(hintFlashCell: null));
      return;
    }

    final updatedCompleted = {...state.completedTargetIds, completed.id};
    emit(
      state.copyWith(
        status: PathWordsStatus.playing,
        activePath: const [],
        completedTargetIds: updatedCompleted,
        hintFlashCell: null,
        hintRevealLength: 0,
      ),
    );

    if (updatedCompleted.length >= puzzle.targets.length) {
      await _finish(emit);
    }
  }

  void _onUndo(PathWordsUndo event, Emitter<PathWordsState> emit) {
    if (state.finished) return;
    if (state.status != PathWordsStatus.ready &&
        state.status != PathWordsStatus.playing) {
      return;
    }
    if (state.activePath.isEmpty) return;

    final undone = PathWordsRules.undoActive(state.activePath);
    emit(
      state.copyWith(
        status: PathWordsStatus.playing,
        activePath: undone,
        hintFlashCell: null,
      ),
    );
  }

  void _onHint(PathWordsHint event, Emitter<PathWordsState> emit) {
    if (state.finished) return;
    final puzzle = state.puzzle;
    if (puzzle == null) return;
    if (state.hintsRemaining <= 0) return;

    final nextLength = state.hintRevealLength + 1;
    final path = PathWordsRules.hintedPath(
      puzzle: puzzle,
      completedTargetIds: state.completedTargetIds,
      revealedLength: nextLength,
    );
    if (path.isEmpty || path.length <= state.hintRevealLength) {
      return;
    }

    emit(
      state.copyWith(
        hintsRemaining: state.hintsRemaining - 1,
        hintFlashCell: path.last,
        hintRevealLength: path.length,
      ),
    );
  }

  void _onReset(PathWordsReset event, Emitter<PathWordsState> emit) {
    if (state.finished) return;
    if (state.status != PathWordsStatus.ready &&
        state.status != PathWordsStatus.playing) {
      return;
    }
    if (state.puzzle == null) return;

    emit(
      state.copyWith(
        status: PathWordsStatus.ready,
        activePath: const [],
        completedTargetIds: const {},
        hintsRemaining: 3,
        hintRevealLength: 0,
        hintFlashCell: null,
        errorMessage: null,
        finished: false,
        points: null,
        timeSeconds: null,
        improved: null,
        resultsExtra: null,
      ),
    );
  }

  Future<void> _finish(Emitter<PathWordsState> emit) async {
    if (state.finished ||
        state.status == PathWordsStatus.celebrating ||
        state.status == PathWordsStatus.submitting ||
        state.status == PathWordsStatus.navigating) {
      return;
    }
    final startedAt = state.startedAt;
    if (startedAt == null) return;

    final elapsed = _now().difference(startedAt).inSeconds;
    final points = PathWordsScoring.pointsForElapsed(elapsed);

    emit(
      state.copyWith(
        finished: true,
        status: PathWordsStatus.celebrating,
        points: points,
        timeSeconds: elapsed,
        hintFlashCell: null,
      ),
    );

    await _wait(celebrationDuration);
    if (emit.isDone) return;

    emit(state.copyWith(status: PathWordsStatus.submitting));

    final dateId = StreakCalculator.dateId(state.day);
    final improved = await submitScore(
      modeKey: 'path_words_$dateId',
      points: points,
      timeSeconds: elapsed,
    );

    final streak = await recordDailyClear(
      gameId: GameIds.pathWords,
      dateId: dateId,
    );

    if (emit.isDone) return;

    emit(
      state.copyWith(
        improved: improved,
        status: PathWordsStatus.navigating,
        resultsExtra: ResultsArgs(
          title: AppStrings.pathWordsClearedTitle,
          subtitle: '',
          timeSeconds: elapsed,
          improved: improved,
          points: points,
          replayDaily: true,
          replayRoute: '/path-words',
          currentStreak: streak.current,
          longestStreak: streak.longest,
        ),
      ),
    );
  }
}
