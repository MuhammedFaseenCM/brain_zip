import 'package:brain_zip/domain/entities/word_category.dart';
import 'package:brain_zip/domain/repositories/category_repository.dart';

class FetchCategories {
  FetchCategories(this._repo);
  final CategoryRepository _repo;

  Future<List<WordCategory>> call() => _repo.fetchCategories();
}
