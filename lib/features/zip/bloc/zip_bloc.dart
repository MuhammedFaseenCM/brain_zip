import 'package:bloc/bloc.dart';

import '../../../domain/game_ids.dart';
import '../../../domain/streak_calculator.dart';
import '../../../domain/usecases/record_daily_clear.dart';
import '../../../domain/usecases/submit_score.dart';
import '../../results/results_args.dart';
import '../logic/daily_puzzle_generator.dart';
import 'zip_event.dart';
import 'zip_state.dart';

class ZipBloc extends Bloc<ZipEvent, ZipState> {
  ZipBloc({
    required this.submitScore,
    required this.recordDailyClear,
    DateTime? now,
  }) : super(ZipState.initial(now ?? DateTime.now())) {
    on<ZipStarted>(_onStarted);
    on<ZipCompleted>(_onCompleted);
  }

  final SubmitScore submitScore;
  final RecordDailyClear recordDailyClear;

  void _onStarted(ZipStarted event, Emitter<ZipState> emit) {
    final seed = event.date ?? DateTime.now();
    final day = DateTime(seed.year, seed.month, seed.day);
    final level = DailyPuzzleGenerator.forDate(day);
    emit(ZipState(day: day, level: level, status: ZipStatus.ready));
  }

  Future<void> _onCompleted(ZipCompleted event, Emitter<ZipState> emit) async {
    if (state.finished || state.status == ZipStatus.submitting) return;

    emit(
      state.copyWith(
        finished: true,
        status: ZipStatus.submitting,
        points: event.points,
        timeSeconds: event.timeSeconds,
      ),
    );

    final improved = await submitScore(
      modeKey: 'zip_${state.level.id}',
      points: event.points,
      timeSeconds: event.timeSeconds,
    );

    final streak = await recordDailyClear(
      gameId: GameIds.zip,
      dateId: StreakCalculator.dateId(state.day),
    );

    if (emit.isDone) return;

    emit(
      state.copyWith(
        improved: improved,
        status: ZipStatus.navigating,
        resultsExtra: ResultsArgs(
          title: 'Puzzle cleared!',
          subtitle: '',
          timeSeconds: event.timeSeconds,
          improved: improved,
          points: event.points,
          replayDaily: true,
          currentStreak: streak.current,
          longestStreak: streak.longest,
        ),
      ),
    );
  }
}
