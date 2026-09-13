import 'package:brain_zip/domain/entities/word_category.dart';

abstract class CategoryRepository {
  Future<List<WordCategory>> fetchCategories();
}
