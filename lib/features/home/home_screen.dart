import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/zip_ui.dart';
import '../zip/logic/daily_puzzle_generator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final level = DailyPuzzleGenerator.forDate(today);
    final scores = ref.watch(scoreRepositoryProvider);
    final bestPoints = scores.getBestPoints('zip_${level.id}');
    final bestTime = scores.getBestTimeSeconds('zip_${level.id}');
    final cleared = bestPoints > 0;

    return Scaffold(
      body: ZipAtmosphere(
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            children: [
              Row(
                children: [
                  const ZipMark(size: 56)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ZIP',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: ZipColors.ink,
                                height: 1,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'One fresh puzzle every day.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: ZipColors.inkSoft,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 450.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutCubic),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: ZipColors.paper,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFD8E0EB)),
                  boxShadow: [
                    BoxShadow(
                      color: ZipColors.ember.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ZipColors.emberSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'TODAY',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: ZipColors.emberDeep,
                                ),
                          ),
                        ),
                        const Spacer(),
                        if (cleared)
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: ZipColors.success,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cleared',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: ZipColors.success),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      cleared ? 'Nice work' : 'Ready when you are',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (cleared) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Best $bestPoints pts'
                        '${bestTime != null ? ' · ${bestTime}s' : ''}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: ZipColors.inkSoft,
                            ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    ZipPrimaryButton(
                      label: cleared ? 'Play again' : "Play today's Zip",
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => context.push('/zip'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start at 1 · fill every cell · finish on the last number.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ZipColors.inkSoft,
                          ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 450.ms)
                  .slideY(begin: 0.1, curve: Curves.easeOutCubic),
              const SizedBox(height: 32),
              Text(
                'Parked for later',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: ZipColors.inkSoft,
                    ),
              ),
              const SizedBox(height: 10),
              const _ParkedRow(
                icon: Icons.link_rounded,
                label: 'Word Match',
              ),
              const SizedBox(height: 8),
              const _ParkedRow(
                icon: Icons.keyboard_alt_outlined,
                label: 'Category Race',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParkedRow extends StatelessWidget {
  const _ParkedRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD0D8E4)),
          color: ZipColors.paper.withValues(alpha: 0.55),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: ZipColors.inkSoft),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ZipColors.inkSoft,
                    ),
              ),
            ),
            Text(
              'Soon',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ZipColors.inkSoft,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
