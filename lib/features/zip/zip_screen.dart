import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/zip_ui.dart';
import '../../data/models/zip_level.dart';
import 'game/zip_game.dart';
import 'logic/daily_puzzle_generator.dart';

class ZipScreen extends ConsumerStatefulWidget {
  const ZipScreen({super.key, this.date});

  final DateTime? date;

  @override
  ConsumerState<ZipScreen> createState() => _ZipScreenState();
}

class _ZipScreenState extends ConsumerState<ZipScreen> {
  ZipGame? _game;
  late final DateTime _day;
  late final ZipLevel _level;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final now = widget.date ?? DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
    _level = DailyPuzzleGenerator.forDate(_day);
    _game = ZipGame(
      level: _level,
      onWin: _onWin,
      onStatsChanged: (_, _) {},
    );
  }

  Future<void> _onWin(int points, int elapsedSeconds) async {
    if (_finished) return;
    _finished = true;
    final improved = await ref.read(scoreRepositoryProvider).submitScore(
          modeKey: 'zip_${_level.id}',
          points: points,
          timeSeconds: elapsedSeconds,
        );

    if (!mounted) return;
    context.pushReplacement(
      '/results',
      extra: {
        'title': 'Puzzle cleared!',
        'timeSeconds': elapsedSeconds,
        'improved': improved,
        'replayDaily': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZipAtmosphere(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        'Zip',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: GameWidget(game: _game!),
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _finished
                            ? null
                            : () {
                                _game?.undo();
                                setState(() {});
                              },
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Undo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          backgroundColor: ZipColors.ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _finished
                            ? null
                            : () {
                                _game?.clearPath();
                                setState(() {});
                              },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
