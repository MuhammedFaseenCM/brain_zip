import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brain_zip/data/repositories/category_repository_impl.dart';
import 'package:brain_zip/data/repositories/score_repository_impl.dart';
import 'package:brain_zip/data/repositories/streak_repository_impl.dart';
import 'package:brain_zip/data/repositories/word_match_repository_impl.dart';
import 'package:brain_zip/data/repositories/zip_level_repository_impl.dart';
import 'package:brain_zip/domain/repositories/category_repository.dart';
import 'package:brain_zip/domain/repositories/score_repository.dart';
import 'package:brain_zip/domain/repositories/streak_repository.dart';
import 'package:brain_zip/domain/repositories/word_match_repository.dart';
import 'package:brain_zip/domain/repositories/zip_level_repository.dart';
import 'package:brain_zip/domain/usecases/fetch_categories.dart';
import 'package:brain_zip/domain/usecases/fetch_word_match_deck_by_id.dart';
import 'package:brain_zip/domain/usecases/fetch_word_match_decks.dart';
import 'package:brain_zip/domain/usecases/fetch_zip_levels.dart';
import 'package:brain_zip/domain/usecases/get_best_points.dart';
import 'package:brain_zip/domain/usecases/get_best_time_seconds.dart';
import 'package:brain_zip/domain/usecases/get_streak.dart';
import 'package:brain_zip/domain/usecases/record_daily_clear.dart';
import 'package:brain_zip/domain/usecases/submit_score.dart';

List<SingleChildWidget> buildRepositoryProviders({
  required SharedPreferences prefs,
}) {
  return [
    RepositoryProvider<SharedPreferences>.value(value: prefs),
    RepositoryProvider<ScoreRepository>(
      create: (context) =>
          ScoreRepositoryImpl(context.read<SharedPreferences>()),
    ),
    RepositoryProvider<StreakRepository>(
      create: (context) =>
          StreakRepositoryImpl(context.read<SharedPreferences>()),
    ),
    RepositoryProvider<ZipLevelRepository>(
      create: (_) => ZipLevelRepositoryImpl(),
    ),
    RepositoryProvider<WordMatchRepository>(
      create: (_) => WordMatchRepositoryImpl(),
    ),
    RepositoryProvider<CategoryRepository>(
      create: (_) => CategoryRepositoryImpl(),
    ),
    RepositoryProvider<SubmitScore>(
      create: (context) => SubmitScore(context.read<ScoreRepository>()),
    ),
    RepositoryProvider<GetBestPoints>(
      create: (context) => GetBestPoints(context.read<ScoreRepository>()),
    ),
    RepositoryProvider<GetBestTimeSeconds>(
      create: (context) => GetBestTimeSeconds(context.read<ScoreRepository>()),
    ),
    RepositoryProvider<GetStreak>(
      create: (context) => GetStreak(context.read<StreakRepository>()),
    ),
    RepositoryProvider<RecordDailyClear>(
      create: (context) => RecordDailyClear(context.read<StreakRepository>()),
    ),
    RepositoryProvider<FetchZipLevels>(
      create: (context) => FetchZipLevels(context.read<ZipLevelRepository>()),
    ),
    RepositoryProvider<FetchWordMatchDecks>(
      create: (context) =>
          FetchWordMatchDecks(context.read<WordMatchRepository>()),
    ),
    RepositoryProvider<FetchWordMatchDeckById>(
      create: (context) =>
          FetchWordMatchDeckById(context.read<WordMatchRepository>()),
    ),
    RepositoryProvider<FetchCategories>(
      create: (context) => FetchCategories(context.read<CategoryRepository>()),
    ),
  ];
}
