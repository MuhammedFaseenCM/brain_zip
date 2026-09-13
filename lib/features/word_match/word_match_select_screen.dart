import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/word_match_deck.dart';
import '../../domain/repositories/score_repository.dart';
import '../../domain/usecases/fetch_word_match_decks.dart';

class WordMatchSelectScreen extends StatefulWidget {
  const WordMatchSelectScreen({super.key});

  @override
  State<WordMatchSelectScreen> createState() => _WordMatchSelectScreenState();
}

class _WordMatchSelectScreenState extends State<WordMatchSelectScreen> {
  Future<List<WordMatchDeck>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<FetchWordMatchDecks>()();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Match decks')),
      body: FutureBuilder<List<WordMatchDeck>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final decks = snapshot.data ?? const <WordMatchDeck>[];
          if (decks.isEmpty) {
            return const Center(child: Text('No decks found'));
          }

          final scores = context.read<ScoreRepository>();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: decks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final deck = decks[i];
              final best = scores.getBestPoints('match_${deck.id}');
              return Card(
                child: ListTile(
                  title: Text(deck.title),
                  subtitle: Text(
                    '${deck.pairs.length} pairs · ${deck.seconds}s'
                    '${best > 0 ? ' · best $best' : ''}',
                  ),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => context.push('/word-match/${deck.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

