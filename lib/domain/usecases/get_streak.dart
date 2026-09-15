import '../entities/game_streak.dart';
import '../repositories/streak_repository.dart';
import '../streak_calculator.dart';

class GetStreak {
  GetStreak(this._repo);

  final StreakRepository _repo;

  Future<GameStreak> call({required String gameId, DateTime? now}) async {
    final todayId = StreakCalculator.dateId(now ?? DateTime.now());
    final stored = await _repo.getStreak(gameId);
    final result = StreakCalculator.applyLazyDecay(
      streak: stored,
      todayId: todayId,
    );
    if (result.shouldPersist) {
      await _repo.saveStreak(result.streak);
    }
    return result.streak;
  }
}
