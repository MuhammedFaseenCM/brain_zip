import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/usecases/fetch_word_match_decks.dart';
import '../../../domain/usecases/get_best_points.dart';
import '../cubit/word_match_select_cubit.dart';
import '../cubit/word_match_select_state.dart';

class WordMatchSelectScreen extends StatelessWidget {
  const WordMatchSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WordMatchSelectCubit(
        fetchWordMatchDecks: context.read<FetchWordMatchDecks>(),
        getBestPoints: context.read<GetBestPoints>(),
      )..load(),
      child: BlocBuilder<WordMatchSelectCubit, WordMatchSelectState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Word Match decks')),
            body: switch (state.status) {
              WordMatchSelectStatus.initial || WordMatchSelectStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              WordMatchSelectStatus.failure => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error ?? 'Unable to load decks'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          context.read<WordMatchSelectCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              WordMatchSelectStatus.ready => _DeckList(items: state.items),
            },
          );
        },
      ),
    );
  }
}

class _DeckList extends StatelessWidget {
  const _DeckList({required this.items});

  final List<WordMatchSelectItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No decks found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final item = items[i];
        final deck = item.deck;
        final best = item.bestPoints;
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
  }
}
