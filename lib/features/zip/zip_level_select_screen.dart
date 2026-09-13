import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/zip_level.dart';
import '../../domain/repositories/score_repository.dart';
import '../../domain/usecases/fetch_zip_levels.dart';

class ZipLevelSelectScreen extends StatefulWidget {
  const ZipLevelSelectScreen({super.key});

  @override
  State<ZipLevelSelectScreen> createState() => _ZipLevelSelectScreenState();
}

class _ZipLevelSelectScreenState extends State<ZipLevelSelectScreen> {
  Future<List<ZipLevel>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<FetchZipLevels>()();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zip levels')),
      body: FutureBuilder<List<ZipLevel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final levels = snapshot.data ?? const <ZipLevel>[];
          if (levels.isEmpty) {
            return const Center(child: Text('No levels found'));
          }

          final scores = context.read<ScoreRepository>();
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

