import '../entities/game_streak.dart';

abstract class StreakRepository {
  Future<GameStreak> getStreak(String gameId);

  Future<GameStreak> saveStreak(GameStreak streak);
}
