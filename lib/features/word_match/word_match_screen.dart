import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/word_match_deck.dart';
import 'game/word_match_game.dart';

class WordMatchScreen extends ConsumerStatefulWidget {
  const WordMatchScreen({super.key, required this.deckId});

  final String deckId;

  @override
  ConsumerState<WordMatchScreen> createState() => _WordMatchScreenState();
}

class _WordMatchScreenState extends ConsumerState<WordMatchScreen> {
  WordMatchGame? _game;
  WordMatchDeck? _deck;
  int _matched = 0;
  int _total = 0;
  int _remaining = 60;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final decks = await ref.read(wordMatchRepositoryProvider).fetchDecks();
    final deck = decks.where((d) => d.id == widget.deckId).firstOrNull;
    if (!mounted) return;
    if (deck == null) {
      setState(() {
        _loading = false;
        _error = 'Deck not found';
      });
      return;
    }
    _remaining = deck.seconds;
    _game = WordMatchGame(
      deck: deck,
      onWin: _onWin,
      onProgress: (m, t) {
        if (!mounted) return;
        setState(() {
          _matched = m;
          _total = t;
        });
      },
    );
    setState(() {
      _deck = deck;
      _total = deck.pairs.length;
      _loading = false;
    });
    _tick();
  }

  Future<void> _tick() async {
    while (mounted && _remaining > 0 && _matched < _total) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0 && _matched < _total) {
        _onFail();
        return;
      }
    }
  }

  Future<void> _onWin(int points, int elapsedSeconds) async {
    final improved = await ref.read(scoreRepositoryProvider).submitScore(
          modeKey: 'match_${widget.deckId}',
          points: points,
          timeSeconds: elapsedSeconds,
        );
    if (!mounted) return;
    context.pushReplacement(
      '/results',
      extra: {
        'title': 'All matched!',
        'points': points,
        'timeSeconds': elapsedSeconds,
        'improved': improved,
        'subtitle': _deck?.title ?? widget.deckId,
      },
    );
  }

  void _onFail() {
    if (!mounted) return;
    context.pushReplacement(
      '/results',
      extra: {
        'title': 'Time up',
        'points': _matched * 25,
        'timeSeconds': _deck?.seconds ?? 60,
        'improved': false,
        'subtitle': 'Matched $_matched / $_total',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Word Match')),
        body: Center(child: Text(_error ?? 'Unable to load deck')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_deck!.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_remaining}s',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _remaining <= 10
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
            child: Text('Matched $_matched / $_total · drag word to its pair'),
          ),
          Expanded(child: GameWidget(game: _game!)),
        ],
      ),
    );
  }
}
