import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/zip_ui.dart';

class HomeForceUpdateOverlay extends StatelessWidget {
  const HomeForceUpdateOverlay({
    super.key,
    required this.currentLabel,
    required this.requiredLabel,
    required this.onUpdate,
  });

  final String currentLabel;
  final String requiredLabel;
  final Future<void> Function() onUpdate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasVersions = currentLabel.isNotEmpty || requiredLabel.isNotEmpty;

    return Positioned.fill(
      child: BlockSemantics(
        blocking: true,
        child: Material(
          color: Colors.black54,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ZipColors.wall,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: ZipColors.outlineQuiet),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.updateRequiredTitle,
                          style: textTheme.titleLarge?.copyWith(
                            color: ZipColors.ember,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.updateRequiredBody,
                          style: textTheme.bodyMedium?.copyWith(
                            color: ZipColors.onInk,
                          ),
                        ),
                        if (hasVersions) ...[
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.updateVersionRow(
                              currentLabel,
                              requiredLabel,
                            ),
                            style: textTheme.labelMedium?.copyWith(
                              color: ZipColors.inkSoft,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.updateCantSkip,
                          style: textTheme.labelMedium?.copyWith(
                            color: ZipColors.inkSoft,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ZipPrimaryButton(
                          label: AppStrings.updateNow,
                          onPressed: () {
                            unawaited(onUpdate());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
