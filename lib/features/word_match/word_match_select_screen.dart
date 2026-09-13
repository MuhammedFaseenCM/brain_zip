import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

class WordMatchSelectScreen extends ConsumerWidget {
  const WordMatchSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wordMatchDecksProvider);
    final scores = ref.watch(scoreRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Word Match decks')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (decks) {
          if (decks.isEmpty) {
            return const Center(child: Text('No decks found'));
          }
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
