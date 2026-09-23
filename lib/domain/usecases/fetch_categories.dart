import 'package:winklo/domain/entities/word_category.dart';
import 'package:winklo/domain/repositories/category_repository.dart';

class FetchCategories {
  FetchCategories(this._repo);
  final CategoryRepository _repo;

  Future<List<WordCategory>> call() => _repo.fetchCategories();
}
