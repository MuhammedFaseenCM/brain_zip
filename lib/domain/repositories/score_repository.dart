abstract class ScoreRepository {
  int getBestPoints(String modeKey);
  int? getBestTimeSeconds(String modeKey);

  Future<bool> submitScore({
    required String modeKey,
    required int points,
    int? timeSeconds,
  });
}
