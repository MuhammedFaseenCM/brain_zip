import 'dart:async';

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
  int _pathLength = 0;
  int _elapsed = 0;
  Timer? _ticker;
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
      onStatsChanged: (len, next) {
        if (!mounted || _finished) return;
        setState(() => _pathLength = len);
      },
    );
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished || _game?.startedAt == null) return;
      setState(() {
        _elapsed = DateTime.now().difference(_game!.startedAt!).inSeconds;
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _livePoints => (1000 - _elapsed * 5).clamp(50, 1000);

  Future<void> _onWin(int points, int elapsedSeconds) async {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();
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
        'points': points,
        'timeSeconds': elapsedSeconds,
        'improved': improved,
        'replayDaily': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _level.size * _level.size;
    final progress = total == 0 ? 0.0 : _pathLength / total;
    final urgent = _elapsed >= 60;

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
                    ZipHudPill(
                      icon: Icons.schedule_rounded,
                      label: _formatTime(_elapsed),
                      emphasize: urgent,
                    ),
                    const SizedBox(width: 8),
                    ZipHudPill(
                      icon: Icons.bolt_rounded,
                      label: '$_livePoints',
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: ZipColors.mistDeep,
                        color: ZipColors.ember,
                      );
                    },
                  ),
                ),
              ),
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

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
