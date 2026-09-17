import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/path_words_puzzle.dart';

class PathWordsWordList extends StatelessWidget {
  const PathWordsWordList({
    super.key,
    required this.targets,
    required this.completedTargetIds,
    required this.palette,
  });

  final List<PathWordsTarget> targets;
  final Set<String> completedTargetIds;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final target in targets) ...[
            _WordRow(
              color: palette[target.colorIndex % palette.length],
              word: target.word,
              done: completedTargetIds.contains(target.id),
            ),
            if (target != targets.last)
              Divider(color: ZipColors.outlineQuiet.withValues(alpha: 0.7)),
          ],
        ],
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({required this.color, required this.word, required this.done});

  final Color color;
  final String word;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final label = word.toUpperCase();
    final base = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: ZipColors.onInk,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? ZipColors.success.withValues(alpha: 0.95)
                  : color.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: done
                  ? base?.copyWith(
                      color: ZipColors.inkSoft,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: ZipColors.inkSoft.withValues(alpha: 0.7),
                    )
                  : base,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            done ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 18,
            color: done ? ZipColors.success : ZipColors.outline,
          ),
        ],
      ),
    );
  }
}
