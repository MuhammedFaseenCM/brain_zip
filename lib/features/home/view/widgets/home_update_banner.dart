import 'package:flutter/material.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/zip_ui.dart';

class HomeUpdateBanner extends StatelessWidget {
  const HomeUpdateBanner({
    super.key,
    required this.currentLabel,
    required this.requiredLabel,
    required this.onUpdate,
  });

  final String currentLabel;
  final String requiredLabel;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasVersions = currentLabel.isNotEmpty || requiredLabel.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZipColors.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ZipColors.outlineQuiet),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.updateAvailableTitle,
              style: textTheme.titleMedium?.copyWith(color: ZipColors.ember),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.updateAvailableBody,
              style: textTheme.bodyMedium?.copyWith(color: ZipColors.onInk),
            ),
            if (hasVersions) ...[
              const SizedBox(height: 10),
              Text(
                AppStrings.updateVersionRow(currentLabel, requiredLabel),
                style: textTheme.labelMedium?.copyWith(
                  color: ZipColors.inkSoft,
                ),
              ),
            ],
            const SizedBox(height: 14),
            ZipPrimaryButton(label: AppStrings.updateNow, onPressed: onUpdate),
          ],
        ),
      ),
    );
  }
}
