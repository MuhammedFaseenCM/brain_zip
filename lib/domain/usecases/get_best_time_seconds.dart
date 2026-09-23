import 'package:winklo/domain/repositories/score_repository.dart';

class GetBestTimeSeconds {
  GetBestTimeSeconds(this._repo);
  final ScoreRepository _repo;

  int? call(String modeKey) => _repo.getBestTimeSeconds(modeKey);
}
