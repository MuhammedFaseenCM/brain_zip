import 'package:flutter/material.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

class PathWordsHowToPlay extends StatelessWidget {
  const PathWordsHowToPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZipColors.wall,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ZipColors.outlineQuiet),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: ZipColors.inkSoft,
          iconColor: ZipColors.inkSoft,
          title: Text(
            AppStrings.pathWordsHowToPlayTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ZipColors.onInk,
              fontWeight: FontWeight.w800,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              AppStrings.pathWordsHowToPlayBody,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ZipColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
