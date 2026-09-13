import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brain_zip/app.dart';
import 'package:brain_zip/core/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Home shows daily Zip CTA without puzzle picker', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const BrainZipApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('ZIP'), findsOneWidget);
    expect(find.text("Play today's Zip"), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Choose a puzzle'), findsNothing);
    expect(find.text('Word Match'), findsOneWidget);
  });
}
