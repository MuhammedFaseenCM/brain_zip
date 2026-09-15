import 'package:bloc/bloc.dart';

import '../../../domain/game_ids.dart';
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
    final key = 'zip_${state.dailyLevel.id}';
    final streak = await _getStreak(gameId: GameIds.zip, now: _now);
    emit(
      state.copyWith(
        bestPoints: _getBestPoints(key),
        bestTimeSeconds: _getBestTimeSeconds(key),
        currentStreak: streak.current,
        longestStreak: streak.longest,
        isOnFreeze: streak.isOnFreeze,
        freezeAvailable: streak.freezeAvailable,
      ),
    );
  }
}
