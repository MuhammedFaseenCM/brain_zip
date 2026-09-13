import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../data/models/zip_level.dart';

class ZipLevelSelectScreen extends ConsumerWidget {
  const ZipLevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(zipLevelsProvider);
    final scores = ref.watch(scoreRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zip levels')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (levels) {
          if (levels.isEmpty) {
            return const Center(child: Text('No levels found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: levels.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final ZipLevel level = levels[i];
              final best = scores.getBestPoints('zip_${level.id}');
              return Card(
                child: ListTile(
                  title: Text('Level ${level.order} · ${level.size}×${level.size}'),
                  subtitle: Text(
                    'Numbers 1–${level.maxNumber}'
                    '${best > 0 ? ' · best $best' : ''}',
                  ),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => context.push('/zip/${level.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
