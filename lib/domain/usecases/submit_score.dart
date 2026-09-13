import 'package:brain_zip/domain/repositories/score_repository.dart';

class SubmitScore {
  SubmitScore(this._repo);
  final ScoreRepository _repo;

  Future<bool> call({
    required String modeKey,
    required int points,
    int? timeSeconds,
  }) => _repo.submitScore(
    modeKey: modeKey,
    points: points,
    timeSeconds: timeSeconds,
  );
}
