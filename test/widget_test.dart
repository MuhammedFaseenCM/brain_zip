import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brain_zip/app.dart';
import 'package:brain_zip/core/di/app_repositories.dart';
import 'package:brain_zip/core/strings/app_strings.dart';

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
    expect(find.text(AppStrings.playTodaysZip), findsOneWidget);
    expect(find.text(AppStrings.playTodaysPathWords), findsOneWidget);
    expect(find.text(AppStrings.today), findsOneWidget);
    expect(find.text('Choose a puzzle'), findsNothing);
    expect(find.text(AppStrings.wordMatch), findsOneWidget);
  });
}
