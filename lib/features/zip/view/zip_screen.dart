import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/zip_ui.dart';
import '../../../domain/usecases/submit_score.dart';
import '../bloc/zip_bloc.dart';
import '../bloc/zip_event.dart';
import '../bloc/zip_state.dart';
import '../game/zip_game.dart';

class ZipScreen extends StatefulWidget {
  const ZipScreen({super.key, this.date});

  final DateTime? date;

  @override
  State<ZipScreen> createState() => _ZipScreenState();
}

class _ZipScreenState extends State<ZipScreen> {
  late final ZipBloc _bloc;
  ZipGame? _game;

  bool _ensureGame(ZipState state) {
    final current = _game;
    if (current != null && current.level.id == state.level.id) return false;
    _game = ZipGame(
      level: state.level,
      onWin: (points, elapsedSeconds) {
        _bloc.add(
          ZipEvent.completed(points: points, timeSeconds: elapsedSeconds),
        );
      },
      onStatsChanged: (_, _) {},
    );
    return true;
  }

  @override
  void initState() {
    super.initState();
    _bloc = ZipBloc(submitScore: context.read<SubmitScore>(), now: widget.date);
    _ensureGame(_bloc.state);
  }

  @override
  void dispose() {
    final game = _game;
    _game = null;
    game?.pauseEngine();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ZipBloc, ZipState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status &&
                curr.status == ZipStatus.navigating,
            listener: (context, state) {
              context.pushReplacement('/results', extra: state.resultsExtra);
            },
          ),
          BlocListener<ZipBloc, ZipState>(
            listenWhen: (prev, curr) => prev.level.id != curr.level.id,
            listener: (context, state) {
              if (_ensureGame(state)) setState(() {});
            },
          ),
        ],
        child: BlocBuilder<ZipBloc, ZipState>(
          builder: (context, state) {
            final finished = state.finished;
            final game = _game;

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
                            child: game == null
                                ? const SizedBox.shrink()
                                : GameWidget(game: game),
                          ),
                        ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: finished
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: finished
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
          },
        ),
      ),
    );
  }
}
