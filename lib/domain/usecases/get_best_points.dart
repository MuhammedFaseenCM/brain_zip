import 'package:winklo/domain/repositories/score_repository.dart';

class GetBestPoints {
  GetBestPoints(this._repo);
  final ScoreRepository _repo;

  int call(String modeKey) => _repo.getBestPoints(modeKey);
}
