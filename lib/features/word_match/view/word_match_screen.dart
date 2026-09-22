import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/word_match_deck.dart';
import '../../../domain/repositories/analytics_repository.dart';
import '../../../domain/usecases/fetch_word_match_deck_by_id.dart';
import '../../../domain/usecases/submit_score.dart';
import '../bloc/word_match_play_bloc.dart';
import '../bloc/word_match_play_event.dart';
import '../bloc/word_match_play_state.dart';
import '../game/word_match_game.dart';

class WordMatchScreen extends StatefulWidget {
  const WordMatchScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<WordMatchScreen> createState() => _WordMatchScreenState();
}

class _WordMatchScreenState extends State<WordMatchScreen> {
  late final WordMatchPlayBloc _bloc;
  WordMatchGame? _game;

  WordMatchDeck? _deck;
  int _matched = 0;
  int _total = 0;

  bool _ensureGame(WordMatchPlayState state) {
    final deck = state.deck;
    if (deck == null) return false;

    final current = _game;
    if (current != null && _deck?.id == deck.id) return false;

    _deck = deck;
    _matched = state.matched;
    _total = state.total;
    _game = WordMatchGame(
      deck: deck,
      onWin: (points, elapsedSeconds) {
        _bloc.add(
          WordMatchPlayEvent.won(
            points: points,
            elapsedSeconds: elapsedSeconds,
          ),
        );
      },
      onProgress: (m, t) {
        if (!mounted) return;
        setState(() {
          _matched = m;
          _total = t;
        });
        _bloc.add(WordMatchPlayEvent.progressChanged(matched: m, total: t));
      },
    );
    return true;
  }

  @override
  void initState() {
    super.initState();
    _bloc = WordMatchPlayBloc(
      fetchDeckById: context.read<FetchWordMatchDeckById>(),
      submitScore: context.read<SubmitScore>(),
      analytics: context.read<AnalyticsRepository>(),
    )..add(WordMatchPlayEvent.started(deckId: widget.deckId));
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
          BlocListener<WordMatchPlayBloc, WordMatchPlayState>(
            listenWhen: (p, c) =>
                p.status != c.status &&
                c.status == WordMatchPlayStatus.navigating,
            listener: (context, state) {
              context.pushReplacement('/results', extra: state.resultsExtra);
            },
          ),
          BlocListener<WordMatchPlayBloc, WordMatchPlayState>(
            listenWhen: (p, c) => p.deck?.id != c.deck?.id,
            listener: (context, state) {
              if (_ensureGame(state)) setState(() {});
            },
          ),
        ],
        child: BlocBuilder<WordMatchPlayBloc, WordMatchPlayState>(
          builder: (context, state) {
            if (state.status == WordMatchPlayStatus.initial ||
                state.status == WordMatchPlayStatus.loading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.status == WordMatchPlayStatus.failure || _game == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Word Match')),
                body: Center(child: Text(state.error ?? 'Unable to load deck')),
              );
            }

            final remaining = state.remainingSeconds;
            final deck = _deck!;

            return Scaffold(
              appBar: AppBar(
                title: Text(deck.title),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        '${remaining}s',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: remaining <= 10
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Matched $_matched / $_total · drag word to its pair',
                    ),
                  ),
                  Expanded(child: GameWidget(game: _game!)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
