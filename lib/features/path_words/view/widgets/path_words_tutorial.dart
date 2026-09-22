import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/game_tutorial_overlay.dart';
import '../../../../core/widgets/tutorial_mini_board.dart';
import '../../../../domain/entities/cell.dart';
import '../../../../domain/game_ids.dart';
import '../../../../domain/repositories/analytics_repository.dart';
import '../../../../domain/repositories/tutorial_repository.dart';

/// Canned Path Words tutorial: drag → lift/continue → list checkoff.
abstract final class PathWordsTutorial {
  static const size = 3;

  static final labels = <Cell, String>{
    const Cell(0, 0): 'C',
    const Cell(0, 1): 'A',
    const Cell(0, 2): 'T',
    const Cell(1, 0): 'O',
    const Cell(1, 1): 'G',
    const Cell(1, 2): 'S',
    const Cell(2, 0): 'R',
    const Cell(2, 1): 'U',
    const Cell(2, 2): 'N',
  };

  static const wordPath = <Cell>[Cell(0, 0), Cell(0, 1), Cell(0, 2)];

  static const word = 'CAT';

  static const captions = <String>[
    AppStrings.pathWordsTutorialDrag,
    AppStrings.pathWordsTutorialLift,
    AppStrings.pathWordsTutorialMatchList,
  ];

  static Future<void> show(BuildContext context, {bool isFirstRun = false}) {
    final repo = context.read<TutorialRepository>();
    final analytics = context.read<AnalyticsRepository>();
    return GameTutorialOverlay.show(
      context: context,
      title: AppStrings.pathWordsHowToPlayTitle,
      captions: captions,
      onDismissed: () async {
        if (isFirstRun) {
          await analytics.logTutorialDismissed(gameId: GameIds.pathWords);
        }
        await repo.markSeen(GameIds.pathWords);
      },
      demoBuilder: (context, beat, beatT) {
        late final double pathProgress;
        late final bool fingerLifted;
        late final bool wordComplete;

        switch (beat) {
          case 0:
            pathProgress = Curves.easeInOut.transform(beatT);
            fingerLifted = false;
            wordComplete = false;
          case 1:
            // Draw first half, lift mid-way, then finish.
            if (beatT < 0.35) {
              pathProgress = (beatT / 0.35) * 0.45;
              fingerLifted = false;
            } else if (beatT < 0.55) {
              pathProgress = 0.45;
              fingerLifted = true;
            } else {
              pathProgress =
                  0.45 + ((beatT - 0.55) / 0.45).clamp(0.0, 1.0) * 0.55;
              fingerLifted = false;
            }
            wordComplete = pathProgress >= 0.98;
          default:
            pathProgress = 1;
            fingerLifted = false;
            wordComplete = true;
        }

        final pulse = 0.55 + 0.45 * math.sin(beatT * math.pi * 2);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TutorialMiniBoard(
              size: size,
              labels: labels,
              path: wordPath,
              pathProgress: pathProgress,
              drawnFill: true,
              pathColor: ZipColors.sky,
              showFinger: beat < 2 || !wordComplete,
              fingerLifted: fingerLifted,
              highlightCells: wordComplete ? wordPath.toSet() : const {},
              highlightPulse: wordComplete ? pulse : 0,
            ),
            const SizedBox(height: 12),
            _MiniWordListRow(complete: wordComplete, pulse: pulse),
          ],
        );
      },
    );
  }

  static Future<void> maybeShow(BuildContext context) async {
    final repo = context.read<TutorialRepository>();
    if (await repo.hasSeen(GameIds.pathWords)) return;
    if (!context.mounted) return;
    final analytics = context.read<AnalyticsRepository>();
    await analytics.logTutorialShown(gameId: GameIds.pathWords);
    if (!context.mounted) return;
    await show(context, isFirstRun: true);
  }
}

class _MiniWordListRow extends StatelessWidget {
  const _MiniWordListRow({required this.complete, required this.pulse});

  final bool complete;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: complete ? ZipColors.skySoft : ZipColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: complete
              ? ZipColors.sky.withValues(alpha: 0.5 + 0.4 * pulse)
              : ZipColors.outlineQuiet,
        ),
      ),
      child: Row(
        children: [
          Icon(
            complete ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: complete ? ZipColors.sky : ZipColors.inkSoft,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            complete ? PathWordsTutorial.word : '• • •',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ZipColors.onInk,
              fontWeight: FontWeight.w700,
              letterSpacing: complete ? 2 : 4,
            ),
          ),
        ],
      ),
    );
  }
}
