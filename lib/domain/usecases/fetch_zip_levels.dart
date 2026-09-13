import 'package:brain_zip/domain/entities/zip_level.dart';
import 'package:brain_zip/domain/repositories/zip_level_repository.dart';

class FetchZipLevels {
  FetchZipLevels(this._repo);
  final ZipLevelRepository _repo;

  Future<List<ZipLevel>> call() => _repo.fetchLevels();
}
