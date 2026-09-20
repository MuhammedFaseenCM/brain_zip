import 'package:bloc/bloc.dart';

import '../../../domain/game_ids.dart';
import '../../../domain/streak_calculator.dart';
import '../../../domain/usecases/get_best_points.dart';
import '../../../domain/usecases/get_best_time_seconds.dart';
import '../../../domain/usecases/get_streak.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetBestPoints getBestPoints,
    required GetBestTimeSeconds getBestTimeSeconds,
    required GetStreak getStreak,
    DateTime? now,
  }) : _getBestPoints = getBestPoints,
       _getBestTimeSeconds = getBestTimeSeconds,
       _getStreak = getStreak,
       _now = now,
       super(HomeState.initial(now ?? DateTime.now()));

  final GetBestPoints _getBestPoints;
  final GetBestTimeSeconds _getBestTimeSeconds;
  final GetStreak _getStreak;
  final DateTime? _now;

  Future<void> load() async {
    final zipKey = 'zip_${state.dailyLevel.id}';
    final pathWordsKey =
        'path_words_${StreakCalculator.dateId(_now ?? DateTime.now())}';
    final zipStreak = await _getStreak(gameId: GameIds.zip, now: _now);
    final pathWordsStreak = await _getStreak(
      gameId: GameIds.pathWords,
      now: _now,
    );
    emit(
      state.copyWith(
        bestPoints: _getBestPoints(zipKey),
        bestTimeSeconds: _getBestTimeSeconds(zipKey),
        currentStreak: zipStreak.current,
        longestStreak: zipStreak.longest,
        isOnFreeze: zipStreak.isOnFreeze,
        freezeAvailable: zipStreak.freezeAvailable,
        pathWordsBestPoints: _getBestPoints(pathWordsKey),
        pathWordsBestTimeSeconds: _getBestTimeSeconds(pathWordsKey),
        pathWordsCurrentStreak: pathWordsStreak.current,
        pathWordsLongestStreak: pathWordsStreak.longest,
        pathWordsIsOnFreeze: pathWordsStreak.isOnFreeze,
        pathWordsFreezeAvailable: pathWordsStreak.freezeAvailable,
      ),
    );
  }
}
