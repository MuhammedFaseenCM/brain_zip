import 'package:flutter/material.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/cell.dart';
import '../../../../domain/entities/path_words_puzzle.dart';
import '../../../../domain/path_words/path_words_rules.dart';

class PathWordsWordList extends StatelessWidget {
  const PathWordsWordList({
    super.key,
    required this.puzzle,
    required this.activePath,
    required this.completedTargetIds,
    required this.palette,
  });

  final PathWordsPuzzle puzzle;
  final List<Cell> activePath;
  final Set<String> completedTargetIds;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    final tracing = PathWordsRules.liveFillTarget(
      puzzle: puzzle,
      activePath: activePath,
      completedTargetIds: completedTargetIds,
    );
    final orderedTargets = PathWordsRules.orderedTargets(puzzle);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: ZipColors.wall,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ZipColors.outlineQuiet),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < orderedTargets.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _WordRow(
              target: orderedTargets[i],
              color: palette[orderedTargets[i].colorIndex % palette.length],
              done: completedTargetIds.contains(orderedTargets[i].id),
              filledLetters: _filledLetters(
                target: orderedTargets[i],
                tracing: tracing,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _filledLetters({
    required PathWordsTarget target,
    required PathWordsTarget? tracing,
  }) {
    if (completedTargetIds.contains(target.id)) {
      return [
        for (var i = 0; i < target.word.length; i++)
          target.word[i].toUpperCase(),
      ];
    }
    if (tracing?.id != target.id) {
      return const [];
    }
    return [
      for (final cell in activePath.take(target.word.length))
        puzzle.letterAt(cell).toUpperCase(),
    ];
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({
    required this.target,
    required this.color,
    required this.done,
    required this.filledLetters,
  });

  final PathWordsTarget target;
  final Color color;
  final bool done;
  final List<String> filledLetters;

  @override
  Widget build(BuildContext context) {
    final word = target.word.toUpperCase();
    final semanticsLabel = done
        ? word
        : filledLetters.isEmpty
        ? AppStrings.pathWordsUnfoundWordLabel(target.word.length)
        : AppStrings.pathWordsTracingWordLabel(filledLetters.join());

    return Semantics(
      key: Key('pathWordsWord_${target.id}'),
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < target.word.length; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            _LetterCell(
              letter: i < filledLetters.length ? filledLetters[i] : null,
              color: color,
              done: done,
            ),
          ],
          const SizedBox(width: 6),
          SizedBox(
            width: 18,
            height: 18,
            child: done
                ? Icon(
                    key: Key('pathWordsCheck_${target.id}'),
                    Icons.check_circle_rounded,
                    size: 18,
                    color: ZipColors.success,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _LetterCell extends StatelessWidget {
  const _LetterCell({
    required this.letter,
    required this.color,
    required this.done,
  });

  final String? letter;
  final Color color;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final shownLetter = letter;
    return Container(
      width: 22,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done
            ? ZipColors.success.withValues(alpha: 0.14)
            : shownLetter != null
            ? color.withValues(alpha: 0.22)
            : ZipColors.paper.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: done
              ? ZipColors.success.withValues(alpha: 0.55)
              : shownLetter != null
              ? color.withValues(alpha: 0.7)
              : ZipColors.outlineQuiet,
        ),
      ),
      child: shownLetter == null
          ? null
          : Text(
              shownLetter,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: ZipColors.onInk,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                height: 1,
              ),
            ),
    );
  }
}
