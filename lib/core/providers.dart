import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brain_zip/data/repositories/score_repository_impl.dart';
import 'package:brain_zip/data/repositories/category_repository_impl.dart';
import 'package:brain_zip/data/repositories/word_match_repository_impl.dart';
import 'package:brain_zip/data/repositories/zip_level_repository_impl.dart';
import 'package:brain_zip/domain/repositories/category_repository.dart';
import 'package:brain_zip/domain/repositories/score_repository.dart';
import 'package:brain_zip/domain/repositories/word_match_repository.dart';
import 'package:brain_zip/domain/repositories/zip_level_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

final zipLevelRepositoryProvider =
    Provider<ZipLevelRepository>((ref) => ZipLevelRepositoryImpl());
final wordMatchRepositoryProvider =
    Provider<WordMatchRepository>((ref) => WordMatchRepositoryImpl());
final categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) => CategoryRepositoryImpl());
final scoreRepositoryProvider = Provider<ScoreRepository>(
  (ref) => ScoreRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);

final zipLevelsProvider = FutureProvider((ref) {
  return ref.watch(zipLevelRepositoryProvider).fetchLevels();
});

final wordMatchDecksProvider = FutureProvider((ref) {
  return ref.watch(wordMatchRepositoryProvider).fetchDecks();
});

final categoriesProvider = FutureProvider((ref) {
  return ref.watch(categoryRepositoryProvider).fetchCategories();
});
