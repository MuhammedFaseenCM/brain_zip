import 'package:winklo/domain/entities/zip_level.dart';
import 'package:winklo/domain/repositories/zip_level_repository.dart';

class FetchZipLevels {
  FetchZipLevels(this._repo);
  final ZipLevelRepository _repo;

  Future<List<ZipLevel>> call() => _repo.fetchLevels();
}
