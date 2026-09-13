import 'package:brain_zip/domain/entities/zip_level.dart';

abstract class ZipLevelRepository {
  Future<List<ZipLevel>> fetchLevels();
}
