import 'package:winklo/domain/entities/game_streak.dart';
import 'package:winklo/domain/repositories/streak_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static String _currentKey(String gameId) => 'streak_current_$gameId';
  static String _longestKey(String gameId) => 'streak_longest_$gameId';
  static String _lastKey(String gameId) => 'streak_last_$gameId';
  static String _freezeKey(String gameId) => 'streak_freeze_$gameId';

  @override
  Future<GameStreak> getStreak(String gameId) async {
    return GameStreak(
      gameId: gameId,
      current: _prefs.getInt(_currentKey(gameId)) ?? 0,
      longest: _prefs.getInt(_longestKey(gameId)) ?? 0,
      lastClearedDateId: _prefs.getString(_lastKey(gameId)),
      freezeAvailable: _prefs.getBool(_freezeKey(gameId)) ?? true,
    );
  }

  @override
  Future<GameStreak> saveStreak(GameStreak streak) async {
    await _prefs.setInt(_currentKey(streak.gameId), streak.current);
    await _prefs.setInt(_longestKey(streak.gameId), streak.longest);
    final last = streak.lastClearedDateId;
    if (last == null) {
      await _prefs.remove(_lastKey(streak.gameId));
    } else {
      await _prefs.setString(_lastKey(streak.gameId), last);
    }
    await _prefs.setBool(_freezeKey(streak.gameId), streak.freezeAvailable);
    return streak;
  }
}
