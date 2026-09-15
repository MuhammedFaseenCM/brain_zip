import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/zip_ui.dart';
import '../../../domain/usecases/get_best_points.dart';
import '../../../domain/usecases/get_best_time_seconds.dart';
import '../../../domain/usecases/get_streak.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatBestTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        getBestPoints: context.read<GetBestPoints>(),
        getBestTimeSeconds: context.read<GetBestTimeSeconds>(),
        getStreak: context.read<GetStreak>(),
      )..load(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final bestPoints = state.bestPoints;
          final bestTime = state.bestTimeSeconds;
          final cleared = bestPoints > 0 || bestTime != null;

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
                                    AppStrings.appTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          color: ZipColors.onInk,
                                          height: 1,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.homeTagline,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: ZipColors.inkSoft),
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
                            color: ZipColors.wall,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: ZipColors.outlineQuiet),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
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
                                      AppStrings.today,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: ZipColors.ember),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (state.currentStreak > 0) ...[
                                    ZipHudPill(
                                      icon: Icons.local_fire_department_rounded,
                                      label: AppStrings.streakLabel(
                                        state.currentStreak,
                                      ),
                                      emphasize: true,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
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
                                          AppStrings.cleared,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: ZipColors.success,
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              if (state.isOnFreeze) ...[
                                const SizedBox(height: 10),
                                Text(
                                  AppStrings.streakProtectedLabel,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(color: ZipColors.ember),
                                ),
                              ],
                              if (state.longestStreak > 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.longestStreakLabel(
                                    state.longestStreak,
                                  ),
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(color: ZipColors.inkSoft),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Text(
                                cleared ? 'Nice work' : 'Ready when you are',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              if (cleared && bestTime != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Best time ${_formatBestTime(bestTime)}',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(color: ZipColors.inkSoft),
                                ),
                              ],
                              const SizedBox(height: 22),
                              ZipPrimaryButton(
                                label: cleared
                                    ? 'Play again'
                                    : AppStrings.playTodaysZip,
                                icon: Icons.play_arrow_rounded,
                                onPressed: () => context.push('/zip'),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Start at 1 · fill every cell · finish on the last number.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: ZipColors.inkSoft),
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
                      label: AppStrings.wordMatch,
                    ),
                    const SizedBox(height: 8),
                    const _ParkedRow(
                      icon: Icons.keyboard_alt_outlined,
                      label: AppStrings.categoryRace,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
          border: Border.all(color: ZipColors.outlineQuiet),
          color: ZipColors.paper.withValues(alpha: 0.55),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: ZipColors.inkSoft),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ZipColors.inkSoft),
              ),
            ),
            Text(
              'Soon',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: ZipColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
