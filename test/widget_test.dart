import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brain_zip/app.dart';
import 'package:brain_zip/core/di/app_repositories.dart';
import 'package:brain_zip/core/strings/app_strings.dart';
import 'package:brain_zip/domain/game_ids.dart';
import 'package:brain_zip/domain/streak_calculator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Home shows Winklo brand and daily CTAs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: buildRepositoryProviders(prefs: prefs),
        child: const WinkloApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text(AppStrings.appTitle), findsOneWidget);
    expect(find.text(AppStrings.homeTagline), findsOneWidget);
    expect(find.text(AppStrings.zipTitle), findsOneWidget);
    expect(find.text(AppStrings.pathWordsTitle), findsOneWidget);
    expect(find.text(AppStrings.playTodaysZip), findsOneWidget);
    expect(find.text(AppStrings.playTodaysPathWords), findsOneWidget);
    expect(find.text(AppStrings.today), findsNWidgets(2));
    expect(find.text('Choose a puzzle'), findsNothing);
    expect(find.text('Parked for later'), findsNothing);
    expect(find.text(AppStrings.wordMatch), findsNothing);
    expect(find.text(AppStrings.categoryRace), findsNothing);
  });

  testWidgets('Home shows Path Words streak independently of Zip', (
    tester,
  ) async {
    final todayId = StreakCalculator.dateId(DateTime.now());
    SharedPreferences.setMockInitialValues({
      'streak_current_${GameIds.pathWords}': 3,
      'streak_longest_${GameIds.pathWords}': 5,
      'streak_last_${GameIds.pathWords}': todayId,
      'best_pts_path_words_$todayId': 18,
      'best_time_path_words_$todayId': 29,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: buildRepositoryProviders(prefs: prefs),
        child: const WinkloApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text(AppStrings.streakLabel(3)), findsOneWidget);
    expect(find.textContaining(AppStrings.longestStreakLabel(5)), findsOneWidget);
    expect(find.text(AppStrings.cleared), findsOneWidget);
    expect(find.text(AppStrings.playAgain), findsOneWidget);
    expect(find.text(AppStrings.playTodaysPathWords), findsNothing);
    expect(find.text(AppStrings.playTodaysZip), findsOneWidget);
  });
}
