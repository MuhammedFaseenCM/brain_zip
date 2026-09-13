import 'package:bloc/bloc.dart';

import '../../../domain/usecases/submit_score.dart';
import '../logic/daily_puzzle_generator.dart';
import 'zip_event.dart';
import 'zip_state.dart';

class ZipBloc extends Bloc<ZipEvent, ZipState> {
  ZipBloc({required SubmitScore submitScore, DateTime? now})
    : _submitScore = submitScore,
      super(ZipState.initial(now ?? DateTime.now())) {
    on<ZipStarted>(_onStarted);
    on<ZipCompleted>(_onCompleted);
    on<ZipNavigationHandled>(_onNavigationHandled);
  }

  final SubmitScore _submitScore;

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

    final improved = await _submitScore(
      modeKey: 'zip_${state.level.id}',
      points: event.points,
      timeSeconds: event.timeSeconds,
    );

    emit(
      state.copyWith(
        improved: improved,
        status: ZipStatus.navigating,
        resultsExtra: <String, dynamic>{
          'title': 'Puzzle cleared!',
          'timeSeconds': event.timeSeconds,
          'improved': improved,
          'replayDaily': true,
        },
      ),
    );
  }

  void _onNavigationHandled(
    ZipNavigationHandled event,
    Emitter<ZipState> emit,
  ) {
    if (state.status != ZipStatus.navigating) return;
    emit(state.copyWith(status: ZipStatus.ready, resultsExtra: null));
  }
}
