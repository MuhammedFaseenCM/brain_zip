import 'package:shared_preferences/shared_preferences.dart';

class ScoreRepository {
  ScoreRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'best_';

  int getBestPoints(String modeKey) => _prefs.getInt('${_prefix}pts_$modeKey') ?? 0;

  int? getBestTimeSeconds(String modeKey) =>
      _prefs.getInt('${_prefix}time_$modeKey');

  Future<bool> submitScore({
    required String modeKey,
    required int points,
    int? timeSeconds,
  }) async {
    var improved = false;
    final prevPts = getBestPoints(modeKey);
    if (points > prevPts) {
      await _prefs.setInt('${_prefix}pts_$modeKey', points);
      improved = true;
    }
    if (timeSeconds != null) {
      final prevTime = getBestTimeSeconds(modeKey);
      if (prevTime == null || timeSeconds < prevTime) {
        await _prefs.setInt('${_prefix}time_$modeKey', timeSeconds);
        improved = true;
      }
    }
    return improved;
  }
}
