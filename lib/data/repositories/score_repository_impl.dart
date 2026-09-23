import 'package:winklo/domain/repositories/score_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  ScoreRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'best_';

  @override
  int getBestPoints(String modeKey) =>
      _prefs.getInt('${_prefix}pts_$modeKey') ?? 0;

  @override
  int? getBestTimeSeconds(String modeKey) =>
      _prefs.getInt('${_prefix}time_$modeKey');

  @override
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
