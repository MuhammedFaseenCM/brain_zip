import '../entities/game_streak.dart';
import '../repositories/streak_repository.dart';
import '../streak_calculator.dart';

class RecordDailyClear {
  RecordDailyClear(this._repo);

  final StreakRepository _repo;

  Future<GameStreak> call({
    required String gameId,
    required String dateId,
  }) async {
    final stored = await _repo.getStreak(gameId);
    final updated = StreakCalculator.applyDailyClear(
      streak: stored,
      todayId: dateId,
    );
    return _repo.saveStreak(updated);
  }
}
