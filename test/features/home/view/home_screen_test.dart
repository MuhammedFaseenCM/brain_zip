import 'package:brain_zip/core/di/app_repositories.dart';
import 'package:brain_zip/core/strings/app_strings.dart';
import 'package:brain_zip/core/theme/app_theme.dart';
import 'package:brain_zip/domain/play_period.dart';
import 'package:brain_zip/features/home/view/home_screen.dart';
import 'package:brain_zip/features/zip/logic/daily_puzzle_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('reloads cleared state after returning from a daily game', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final levelId = DailyPuzzleGenerator.dateId(
      DateTime.now(),
      period: PlayPeriod.daily,
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/zip',
          builder: (context, _) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    await prefs.setInt('best_time_zip_$levelId', 42);
                    if (context.mounted) context.pop();
                  },
                  child: const Text('finish-zip'),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: '/path-words',
          builder: (_, _) => const Scaffold(body: Text('path-words')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: buildRepositoryProviders(prefs: prefs),
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text(AppStrings.playTodaysZip), findsOneWidget);
    expect(find.text(AppStrings.result), findsNothing);

    await tester.tap(find.text(AppStrings.playTodaysZip));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('finish-zip'), findsOneWidget);
    await tester.tap(find.text('finish-zip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text(AppStrings.result), findsOneWidget);
    expect(find.text(AppStrings.playTodaysZip), findsNothing);
  });

  testWidgets('reloads after results replaces the game and returns home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final levelId = DailyPuzzleGenerator.dateId(
      DateTime.now(),
      period: PlayPeriod.daily,
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/zip',
          builder: (context, _) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    await prefs.setInt('best_time_zip_$levelId', 42);
                    if (context.mounted) {
                      context.pushReplacement('/results');
                    }
                  },
                  child: const Text('finish-zip'),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: '/results',
          builder: (context, _) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(AppStrings.backHome),
                ),
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: buildRepositoryProviders(prefs: prefs),
        child: MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.text(AppStrings.playTodaysZip));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('finish-zip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text(AppStrings.backHome), findsOneWidget);
    await tester.tap(find.text(AppStrings.backHome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text(AppStrings.result), findsOneWidget);
    expect(find.text(AppStrings.playTodaysZip), findsNothing);
  });
}
