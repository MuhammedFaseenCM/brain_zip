import 'package:winklo/core/strings/app_strings.dart';
import 'package:winklo/core/theme/app_theme.dart';
import 'package:winklo/features/results/results_args.dart';
import 'package:winklo/features/results/results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Daily clear sends the player home, not back into the puzzle', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/results',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/path-words',
          builder: (_, _) => const Text('path-words'),
        ),
        GoRoute(path: '/zip', builder: (_, _) => const Text('zip')),
        GoRoute(
          path: '/results',
          builder: (_, _) => const ResultsScreen(
            args: ResultsArgs(
              title: 'Puzzle cleared!',
              subtitle: '',
              timeSeconds: 12,
              improved: false,
              replayDaily: true,
              replayRoute: '/path-words',
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.playAgain), findsNothing);
    expect(find.text(AppStrings.newPuzzleUnlocksTomorrow), findsOneWidget);

    await tester.tap(find.text(AppStrings.backHome));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(find.text('path-words'), findsNothing);
    expect(find.text('zip'), findsNothing);
  });

  testWidgets('Non-daily Play again still opens the finished game', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/results',
      routes: [
        GoRoute(
          path: '/word-match/animals',
          builder: (_, _) => const Text('word-match'),
        ),
        GoRoute(
          path: '/results',
          builder: (_, _) => const ResultsScreen(
            args: ResultsArgs(
              title: 'Puzzle cleared!',
              subtitle: '',
              timeSeconds: 12,
              improved: false,
              replayRoute: '/word-match/animals',
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.playAgain));
    await tester.pumpAndSettle();

    expect(find.text('word-match'), findsOneWidget);
  });
}
