import 'package:brain_zip/core/strings/app_strings.dart';
import 'package:brain_zip/core/widgets/game_tutorial_overlay.dart';
import 'package:brain_zip/core/widgets/tutorial_mini_board.dart';
import 'package:brain_zip/domain/entities/cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GameTutorialOverlay cycles captions and Got it dismisses', (
    tester,
  ) async {
    var gotIt = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameTutorialOverlay(
            title: AppStrings.zipHowToPlayTitle,
            captions: const [
              AppStrings.zipTutorialStart,
              AppStrings.zipTutorialFinish,
            ],
            beatDuration: const Duration(milliseconds: 400),
            onGotIt: () => gotIt = true,
            demoBuilder: (context, beat, beatT) {
              return TutorialMiniBoard(
                size: 2,
                labels: {const Cell(0, 0): '1', const Cell(1, 1): '2'},
                path: const [Cell(0, 0), Cell(0, 1), Cell(1, 1)],
                pathProgress: beat == 0 ? 0 : beatT,
                drawnFill: beat > 0,
              );
            },
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.zipHowToPlayTitle), findsOneWidget);
    expect(find.text(AppStrings.zipTutorialStart), findsOneWidget);
    expect(find.byType(TutorialMiniBoard), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text(AppStrings.zipTutorialFinish), findsOneWidget);

    await tester.tap(find.text(AppStrings.tutorialGotIt));
    await tester.pump();
    expect(gotIt, isTrue);
  });
}
