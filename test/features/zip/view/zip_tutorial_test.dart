import 'package:brain_zip/core/strings/app_strings.dart';
import 'package:brain_zip/core/widgets/game_tutorial_overlay.dart';
import 'package:brain_zip/domain/game_ids.dart';
import 'package:brain_zip/domain/repositories/tutorial_repository.dart';
import 'package:brain_zip/features/zip/view/widgets/zip_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTutorialRepository extends Mock implements TutorialRepository {}

void main() {
  testWidgets('ZipTutorial.show marks seen on dismiss', (tester) async {
    final repo = _MockTutorialRepository();
    when(() => repo.markSeen(GameIds.zip)).thenAnswer((_) async {});

    await tester.pumpWidget(
      RepositoryProvider<TutorialRepository>.value(
        value: repo,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => ZipTutorial.show(context),
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(GameTutorialOverlay), findsOneWidget);
    expect(find.text(AppStrings.zipTutorialStart), findsOneWidget);

    await tester.tap(find.text(AppStrings.tutorialGotIt));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    verify(() => repo.markSeen(GameIds.zip)).called(1);
  });
}
