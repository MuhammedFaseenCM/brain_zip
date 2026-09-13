import 'package:go_router/go_router.dart';

import '../../features/category_race/category_race_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/results/results_screen.dart';
import '../../features/word_match/word_match_screen.dart';
import '../../features/word_match/word_match_select_screen.dart';
import '../../features/zip/zip_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/zip',
        builder: (context, state) => const ZipScreen(),
      ),
      GoRoute(
        path: '/word-match',
        builder: (context, state) => const WordMatchSelectScreen(),
      ),
      GoRoute(
        path: '/word-match/:deckId',
        builder: (context, state) => WordMatchScreen(
          deckId: state.pathParameters['deckId']!,
        ),
      ),
      GoRoute(
        path: '/category-race',
        builder: (context, state) => const CategoryRaceScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) {
          final extra = state.extra;
          final data = extra is Map<String, dynamic>
              ? extra
              : <String, dynamic>{};
          return ResultsScreen(data: data);
        },
      ),
    ],
  );
}
