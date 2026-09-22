import 'package:brain_zip/core/strings/app_strings.dart';
import 'package:brain_zip/core/widgets/game_tutorial_overlay.dart';
import 'package:brain_zip/domain/game_ids.dart';
import 'package:brain_zip/domain/repositories/tutorial_repository.dart';
import 'package:brain_zip/features/path_words/view/widgets/path_words_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTutorialRepository extends Mock implements TutorialRepository {}

void main() {
  testWidgets('PathWordsTutorial.show marks seen on dismiss', (tester) async {
    final repo = _MockTutorialRepository();
    when(() => repo.markSeen(GameIds.pathWords)).thenAnswer((_) async {});

    await tester.pumpWidget(
      RepositoryProvider<TutorialRepository>.value(
        value: repo,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => PathWordsTutorial.show(context),
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
    expect(find.text(AppStrings.pathWordsTutorialDrag), findsOneWidget);

    await tester.tap(find.text(AppStrings.tutorialGotIt));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    verify(() => repo.markSeen(GameIds.pathWords)).called(1);
  });
}
