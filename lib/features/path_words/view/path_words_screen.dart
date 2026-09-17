import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/zip_ui.dart';
import '../../../domain/entities/cell.dart';
import '../../../domain/usecases/generate_daily_path_words.dart';
import '../../../domain/usecases/record_daily_clear.dart';
import '../../../domain/usecases/submit_score.dart';
import '../bloc/path_words_bloc.dart';
import '../bloc/path_words_event.dart';
import '../bloc/path_words_state.dart';
import '../game/path_words_board_view.dart';
import '../game/path_words_game.dart';
import 'widgets/path_words_how_to_play.dart';
import 'widgets/path_words_word_list.dart';

class PathWordsScreen extends StatefulWidget {
  const PathWordsScreen({super.key, this.date});

  final DateTime? date;

  @override
  State<PathWordsScreen> createState() => _PathWordsScreenState();
}

class _PathWordsScreenState extends State<PathWordsScreen> {
  late final PathWordsBloc _bloc;
  PathWordsGame? _game;

  PathWordsBoardView? _viewFor(PathWordsState state) {
    final puzzle = state.puzzle;
    if (puzzle == null) return null;

    final completedPaths = <String, List<Cell>>{};
    for (final target in puzzle.targets) {
      if (state.completedTargetIds.contains(target.id)) {
        completedPaths[target.id] = target.path;
      }
    }

    return PathWordsBoardView(
      puzzle: puzzle,
      activePath: state.activePath,
      completedPathsByTargetId: completedPaths,
      hintFlashCell: state.hintFlashCell,
      inputEnabled:
          !state.finished &&
          (state.status == PathWordsStatus.ready ||
              state.status == PathWordsStatus.playing),
    );
  }

  bool _ensureGame(PathWordsState state) {
    final view = _viewFor(state);
    if (view == null) return false;

    final current = _game;
    if (current != null && current.view.puzzle.id == view.puzzle.id) {
      current.applyView(view);
      return false;
    }

    _game = PathWordsGame(
      view: view,
      onPointerDown: (cell) => _bloc.add(PathWordsEvent.pointerDown(cell)),
      onPointerEnter: (cell) => _bloc.add(PathWordsEvent.pointerEnter(cell)),
      onPointerUp: () => _bloc.add(const PathWordsEvent.pointerUp()),
    );
    return true;
  }

  @override
  void initState() {
    super.initState();
    _bloc = PathWordsBloc(
      generateDailyPathWords: context.read<GenerateDailyPathWords>(),
      submitScore: context.read<SubmitScore>(),
      recordDailyClear: context.read<RecordDailyClear>(),
    )..add(PathWordsEvent.started(date: widget.date));
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
          BlocListener<PathWordsBloc, PathWordsState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status &&
                curr.status == PathWordsStatus.navigating,
            listener: (context, state) {
              context.pushReplacement('/results', extra: state.resultsExtra);
            },
          ),
          BlocListener<PathWordsBloc, PathWordsState>(
            listenWhen: (prev, curr) => prev.puzzle?.id != curr.puzzle?.id,
            listener: (context, state) {
              if (_ensureGame(state)) setState(() {});
            },
          ),
          BlocListener<PathWordsBloc, PathWordsState>(
            listenWhen: (prev, curr) {
              return prev.puzzle?.id == curr.puzzle?.id && prev != curr;
            },
            listener: (context, state) {
              final view = _viewFor(state);
              if (view == null) return;
              _game?.applyView(view);
            },
          ),
        ],
        child: BlocBuilder<PathWordsBloc, PathWordsState>(
          builder: (context, state) {
            final puzzle = state.puzzle;
            final finished = state.finished;
            final game = _game;

            final isReadyToPlay =
                !finished &&
                (state.status == PathWordsStatus.ready ||
                    state.status == PathWordsStatus.playing) &&
                puzzle != null;
            final canUndo = isReadyToPlay && state.activePath.isNotEmpty;
            final canHint = isReadyToPlay && state.hintsRemaining > 0;

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
                                AppStrings.pathWordsTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              onPressed: !isReadyToPlay
                                  ? null
                                  : () =>
                                        _bloc.add(const PathWordsEvent.reset()),
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: _BoardPane(
                                  game: game,
                                  status: state.status,
                                  errorMessage: state.errorMessage,
                                  onRetry: () => _bloc.add(
                                    PathWordsEvent.started(date: widget.date),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (puzzle != null) ...[
                              PathWordsWordList(
                                targets: puzzle.targets,
                                completedTargetIds: state.completedTargetIds,
                                palette: PathWordsGame.pathColors,
                              ),
                              const SizedBox(height: 14),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: canUndo
                                        ? () => _bloc.add(
                                            const PathWordsEvent.undo(),
                                          )
                                        : null,
                                    icon: const Icon(Icons.undo_rounded),
                                    label: const Text(AppStrings.pathWordsUndo),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.tonalIcon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: ZipColors.wall,
                                      foregroundColor: ZipColors.onInk,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: canHint
                                        ? () => _bloc.add(
                                            const PathWordsEvent.hint(),
                                          )
                                        : null,
                                    icon: const Icon(Icons.lightbulb_rounded),
                                    label: Text(
                                      AppStrings.pathWordsHintWithCount(
                                        state.hintsRemaining,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const PathWordsHowToPlay(),
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

class _BoardPane extends StatelessWidget {
  const _BoardPane({
    required this.game,
    required this.status,
    required this.errorMessage,
    required this.onRetry,
  });

  final PathWordsGame? game;
  final PathWordsStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final g = game;
    if (g != null) return GameWidget(game: g);

    if (status == PathWordsStatus.failed) {
      return Container(
        color: ZipColors.wall,
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.pathWordsFailed,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ZipColors.onInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: ZipColors.inkSoft),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: ZipColors.wall,
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              AppStrings.pathWordsLoading,
              textAlign: TextAlign.center,
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
