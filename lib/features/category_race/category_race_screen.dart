import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/word_category.dart';
import '../../../domain/repositories/score_repository.dart';
import '../../../domain/usecases/fetch_categories.dart';

class CategoryRaceScreen extends StatefulWidget {
  const CategoryRaceScreen({super.key});

  @override
  State<CategoryRaceScreen> createState() => _CategoryRaceScreenState();
}

class _CategoryRaceScreenState extends State<CategoryRaceScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _answers = <String>[];
  WordCategory? _category;
  String _letter = 'A';
  int _remaining = 60;
  bool _started = false;
  bool _loading = true;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    final categories = await context.read<FetchCategories>()();
    if (!mounted) return;
    if (categories.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final rng = Random();
    final category = categories[rng.nextInt(categories.length)];
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    // Prefer a letter that has at least one word in the category.
    final viable = letters.where((l) {
      return category.normalizedWords.any((w) => w.startsWith(l.toLowerCase()));
    }).toList();
    setState(() {
      _category = category;
      _letter = viable.isEmpty ? 'A' : viable[rng.nextInt(viable.length)];
      _loading = false;
    });
  }

  void _start() {
    setState(() => _started = true);
    _focus.requestFocus();
    _tick();
  }

  Future<void> _tick() async {
    while (mounted && _remaining > 0 && _started) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || !_started) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        await _finish();
        return;
      }
    }
  }

  void _submit() {
    final raw = _controller.text.trim();
    _controller.clear();
    if (raw.isEmpty || _category == null) return;
    final word = raw.toLowerCase();
    if (!word.startsWith(_letter.toLowerCase())) {
      setState(() => _feedback = 'Must start with $_letter');
      return;
    }
    if (!_category!.normalizedWords.contains(word)) {
      setState(() => _feedback = 'Not in ${_category!.name}');
      return;
    }
    if (_answers.contains(word)) {
      setState(() => _feedback = 'Already used');
      return;
    }
    setState(() {
      _answers.insert(0, word);
      _feedback = null;
    });
  }

  Future<void> _finish() async {
    _started = false;
    final points = _answers.length * 50;
    final improved = await context.read<ScoreRepository>().submitScore(
          modeKey: 'race_${_category?.id ?? 'unknown'}',
          points: points,
        );
    if (!mounted) return;
    context.pushReplacement(
      '/results',
      extra: {
        'title': 'Round over',
        'points': points,
        'timeSeconds': 60,
        'improved': improved,
        'subtitle': '${_category?.name} · $_letter · ${_answers.length} words',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category Race')),
        body: const Center(child: Text('No categories available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Race'),
        actions: [
          if (_started)
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      _category!.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Letter: $_letter',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type words that fit the category and start with $_letter',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_started)
              FilledButton(
                onPressed: _start,
                child: const Text('Start 60s'),
              )
            else ...[
              TextField(
                controller: _controller,
                focusNode: _focus,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Your word',
                  border: const OutlineInputBorder(),
                  errorText: _feedback,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: _submit, child: const Text('Submit')),
              const SizedBox(height: 16),
              Text('Accepted (${_answers.length})'),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final word in _answers) Chip(label: Text(word)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

