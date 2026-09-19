import 'package:brain_zip/core/theme/app_theme.dart';
import 'package:brain_zip/features/results/results_args.dart';
import 'package:brain_zip/features/results/results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Play again opens the game that just finished', (tester) async {
    final router = GoRouter(
      initialLocation: '/results',
      routes: [
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

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();

    expect(find.text('path-words'), findsOneWidget);
    expect(find.text('zip'), findsNothing);
  });
}
