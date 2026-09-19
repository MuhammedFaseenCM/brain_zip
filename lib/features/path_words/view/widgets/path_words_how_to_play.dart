import 'package:flutter/material.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

class PathWordsHowToPlayButton extends StatelessWidget {
  const PathWordsHowToPlayButton({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ZipColors.wall,
          surfaceTintColor: Colors.transparent,
          title: Text(
            AppStrings.pathWordsHowToPlayTitle,
            style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
              color: ZipColors.onInk,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            AppStrings.pathWordsHowToPlayBody,
            style: Theme.of(
              dialogContext,
            ).textTheme.bodyMedium?.copyWith(color: ZipColors.inkSoft),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.pathWordsHowToPlayGotIt),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppStrings.pathWordsHowToPlayTitle,
      onPressed: () => show(context),
      icon: const Icon(Icons.help_outline_rounded),
    );
  }
}
