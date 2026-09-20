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
          final bestTime = state.bestTimeSeconds;
          final zipCleared = state.bestPoints > 0 || bestTime != null;
          final pathWordsBestTime = state.pathWordsBestTimeSeconds;
          final pathWordsCleared =
              state.pathWordsBestPoints > 0 || pathWordsBestTime != null;

          return Scaffold(
            body: ZipAtmosphere(
              child: SafeArea(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  children: [
                    const _HomeHeader()
                        .animate()
                        .fadeIn(duration: 450.ms)
                        .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                    const SizedBox(height: 28),
                    _DailyGameTile(
                          accent: ZipColors.ember,
                          accentSoft: ZipColors.emberSoft,
                          icon: Icons.route_rounded,
                          title: AppStrings.zipTitle,
                          tagline: AppStrings.zipTagline,
                          playLabel: zipCleared
                              ? AppStrings.playAgain
                              : AppStrings.playTodaysZip,
                          onPlay: () => context.push('/zip'),
                          streak: state.currentStreak,
                          isOnFreeze: state.isOnFreeze,
                          longestStreak: state.longestStreak,
                          cleared: zipCleared,
                          bestTimeLabel: zipCleared && bestTime != null
                              ? AppStrings.bestTimeLabel(
                                  _formatBestTime(bestTime),
                                )
                              : null,
                        )
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 450.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                    const SizedBox(height: 16),
                    _DailyGameTile(
                          accent: ZipColors.sky,
                          accentSoft: ZipColors.skySoft,
                          icon: Icons.grid_view_rounded,
                          title: AppStrings.pathWordsTitle,
                          tagline: AppStrings.pathWordsTagline,
                          playLabel: pathWordsCleared
                              ? AppStrings.playAgain
                              : AppStrings.playTodaysPathWords,
                          playBackground: ZipColors.sky,
                          onPlay: () => context.push('/path-words'),
                          streak: state.pathWordsCurrentStreak,
                          isOnFreeze: state.pathWordsIsOnFreeze,
                          longestStreak: state.pathWordsLongestStreak,
                          cleared: pathWordsCleared,
                          bestTimeLabel:
                              pathWordsCleared && pathWordsBestTime != null
                              ? AppStrings.bestTimeLabel(
                                  _formatBestTime(pathWordsBestTime),
                                )
                              : null,
                        )
                        .animate()
                        .fadeIn(delay: 160.ms, duration: 450.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ZipMark(size: 56)
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appTitle,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: ZipColors.onInk,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.homeTagline,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: ZipColors.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyGameTile extends StatelessWidget {
  const _DailyGameTile({
    required this.accent,
    required this.accentSoft,
    required this.icon,
    required this.title,
    required this.tagline,
    required this.playLabel,
    required this.onPlay,
    this.playBackground,
    this.streak = 0,
    this.isOnFreeze = false,
    this.longestStreak = 0,
    this.cleared = false,
    this.bestTimeLabel,
  });

  final Color accent;
  final Color accentSoft;
  final IconData icon;
  final String title;
  final String tagline;
  final String playLabel;
  final VoidCallback onPlay;
  final Color? playBackground;
  final int streak;
  final bool isOnFreeze;
  final int longestStreak;
  final bool cleared;
  final String? bestTimeLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZipColors.wall,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ZipColors.outlineQuiet),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(color: accent, child: const SizedBox(width: 6)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
                              color: accentSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              AppStrings.today,
                              style: textTheme.labelLarge?.copyWith(
                                color: accent,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (streak > 0) ...[
                            ZipHudPill(
                              icon: Icons.local_fire_department_rounded,
                              label: AppStrings.streakLabel(streak),
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
                                  style: textTheme.labelLarge?.copyWith(
                                    color: ZipColors.success,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (isOnFreeze) ...[
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.streakProtectedLabel,
                          style: textTheme.labelMedium?.copyWith(color: accent),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: accentSoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(icon, color: accent, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: textTheme.headlineMedium),
                                const SizedBox(height: 4),
                                Text(
                                  tagline,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: ZipColors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (longestStreak > 0 || bestTimeLabel != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          [
                            ?bestTimeLabel,
                            if (longestStreak > 0)
                              AppStrings.longestStreakLabel(longestStreak),
                          ].join('  ·  '),
                          style: textTheme.labelMedium?.copyWith(
                            color: ZipColors.inkSoft,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      ZipPrimaryButton(
                        label: playLabel,
                        icon: Icons.play_arrow_rounded,
                        backgroundColor: playBackground,
                        onPressed: onPlay,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
