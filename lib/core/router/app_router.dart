import 'package:go_router/go_router.dart';

import '../../features/category_race/view/category_race_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/path_words/view/path_words_screen.dart';
import '../../features/results/results_args.dart';
import '../../features/results/results_screen.dart';
import '../../features/word_match/view/word_match_screen.dart';
import '../../features/word_match/view/word_match_select_screen.dart';
import '../../features/zip/view/zip_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/zip', builder: (context, state) => const ZipScreen()),
      GoRoute(
        path: '/path-words',
        builder: (context, state) => const PathWordsScreen(),
      ),
      GoRoute(
        path: '/word-match',
        builder: (context, state) => const WordMatchSelectScreen(),
      ),
      GoRoute(
        path: '/word-match/:deckId',
        builder: (context, state) =>
            WordMatchScreen(deckId: state.pathParameters['deckId']!),
      ),
      GoRoute(
        path: '/category-race',
        builder: (context, state) => const CategoryRaceScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is ResultsArgs
              ? extra
              : const ResultsArgs(
                  title: 'Results',
                  subtitle: '',
                  timeSeconds: 0,
                  improved: false,
                );
          return ResultsScreen(args: args);
        },
      ),
    ],
  );
}
