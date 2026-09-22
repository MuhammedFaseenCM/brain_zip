import 'package:bloc/bloc.dart';

import '../../../core/strings/app_strings.dart';
import '../../../domain/game_ids.dart';
import '../../../domain/play_period.dart';
import '../../../domain/path_words/path_words_rules.dart';
import '../../../domain/path_words/path_words_scoring.dart';
import '../../../domain/repositories/analytics_repository.dart';
import '../../../domain/streak_calculator.dart';
import '../../../domain/usecases/generate_daily_path_words.dart';
import '../../../domain/usecases/get_best_points.dart';
import '../../../domain/usecases/get_best_time_seconds.dart';
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
    required this.getBestPoints,
    required this.getBestTimeSeconds,
    required this.analytics,
    DateTime Function()? now,
    Future<void> Function(Duration duration)? wait,
    this.celebrationDuration = const Duration(seconds: 2),
    this.playPeriod = PlayPeriod.daily,
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
  final GetBestPoints getBestPoints;
  final GetBestTimeSeconds getBestTimeSeconds;
  final AnalyticsRepository analytics;
  final Duration celebrationDuration;
  final Duration playPeriod;
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

    final modeKey = 'path_words_${PlayPeriod.id(seed, playPeriod)}';
    final alreadyCleared =
        getBestPoints(modeKey) > 0 || getBestTimeSeconds(modeKey) != null;

    try {
      final puzzle = await generateDailyPathWords(
        day: PlayPeriod.bucket(seed, playPeriod),
      );
      if (emit.isDone) return;

      if (alreadyCleared) {
        emit(
          state.copyWith(
            status: PathWordsStatus.locked,
            puzzle: puzzle,
            finished: true,
            completedTargetIds: {
              for (final target in puzzle.targets) target.id,
            },
            activePath: const [],
            hintRevealLength: 0,
            hintFlashCell: null,
            errorMessage: null,
          ),
        );
        return;
      }

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
          ruleTip: null,
          finished: false,
          points: null,
          timeSeconds: null,
          improved: null,
          resultsExtra: null,
        ),
      );
      await analytics.logGameStarted(gameId: GameIds.pathWords);
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
      if (state.hintFlashCell == null && state.ruleTip == null) return;
      emit(state.copyWith(hintFlashCell: null, ruleTip: null));
      return;
    }

    emit(
      state.copyWith(
        status: PathWordsStatus.playing,
        activePath: begun,
        hintFlashCell: null,
        ruleTip: null,
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
      final failedAttempt = PathWordsRules.looksLikeFailedWordAttempt(
        puzzle: puzzle,
        path: state.activePath,
        completedTargetIds: state.completedTargetIds,
      );
      final tip = failedAttempt ? AppStrings.pathWordsTipMatchList : null;
      if (state.hintFlashCell == null && tip == null && state.ruleTip == null) {
        return;
      }
      emit(state.copyWith(hintFlashCell: null, ruleTip: tip));
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
        ruleTip: null,
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

    final remaining = state.hintsRemaining - 1;
    emit(
      state.copyWith(
        hintsRemaining: remaining,
        hintFlashCell: path.last,
        hintRevealLength: path.length,
      ),
    );
    analytics.logHintUsed(gameId: GameIds.pathWords, hintsRemaining: remaining);
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
        ruleTip: null,
        finished: false,
        points: null,
        timeSeconds: null,
        improved: null,
        resultsExtra: null,
      ),
    );
    analytics.logGameReset(gameId: GameIds.pathWords);
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
    final playId = PlayPeriod.id(
      PlayPeriod.isSubDaily(playPeriod)
          ? (state.startedAt ?? state.day)
          : state.day,
      playPeriod,
    );
    final improved = await submitScore(
      modeKey: 'path_words_$playId',
      points: points,
      timeSeconds: elapsed,
    );

    final streak = await recordDailyClear(
      gameId: GameIds.pathWords,
      dateId: dateId,
    );

    await analytics.logGameCompleted(
      gameId: GameIds.pathWords,
      points: points,
      timeSeconds: elapsed,
      streak: streak.current,
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
          gameId: GameIds.pathWords,
        ),
      ),
    );
  }
}
