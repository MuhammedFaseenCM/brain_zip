import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/usecases/fetch_categories.dart';
import '../../../domain/usecases/submit_score.dart';
import '../bloc/category_race_bloc.dart';
import '../bloc/category_race_event.dart';
import '../bloc/category_race_state.dart';

class CategoryRaceScreen extends StatefulWidget {
  const CategoryRaceScreen({super.key});

  @override
  State<CategoryRaceScreen> createState() => _CategoryRaceScreenState();
}

class _CategoryRaceScreenState extends State<CategoryRaceScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  late final CategoryRaceBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CategoryRaceBloc(
      fetchCategories: context.read<FetchCategories>(),
      submitScore: context.read<SubmitScore>(),
    )..add(const CategoryRaceEvent.fetchCategories());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _bloc.close();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text;
    _controller.clear();
    _bloc.add(CategoryRaceEvent.answerSubmitted(raw));
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<CategoryRaceBloc, CategoryRaceState>(
            listenWhen: (p, c) =>
                p.status != c.status && c.status == CategoryRaceStatus.navigating,
            listener: (context, state) {
              context.pushReplacement('/results', extra: state.resultsExtra);
            },
          ),
          BlocListener<CategoryRaceBloc, CategoryRaceState>(
            listenWhen: (p, c) =>
                p.status != c.status && c.status == CategoryRaceStatus.playing,
            listener: (context, state) => _focus.requestFocus(),
          ),
        ],
        child: BlocBuilder<CategoryRaceBloc, CategoryRaceState>(
          builder: (context, state) {
            if (state.status == CategoryRaceStatus.initial ||
                state.status == CategoryRaceStatus.loading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.status == CategoryRaceStatus.failure) {
              return Scaffold(
                appBar: AppBar(title: const Text('Category Race')),
                body: Center(child: Text(state.error ?? 'Unable to load categories')),
              );
            }

            final category = state.category;
            if (category == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Category Race')),
                body: const Center(child: Text('No categories available')),
              );
            }

            final started = state.status == CategoryRaceStatus.playing;
            final remaining = state.remainingSeconds;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Category Race'),
                actions: [
                  if (started)
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
                              category.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Letter: ${state.letter}',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Type words that fit the category and start with ${state.letter}',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!started)
                      FilledButton(
                        onPressed: () => _bloc.add(const CategoryRaceEvent.started()),
                        child: Text('Start ${state.totalSeconds}s'),
                      )
                    else ...[
                      TextField(
                        controller: _controller,
                        focusNode: _focus,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Your word',
                          border: const OutlineInputBorder(),
                          errorText: state.feedback,
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(onPressed: _submit, child: const Text('Submit')),
                      const SizedBox(height: 16),
                      Text('Accepted (${state.answers.length})'),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final word in state.answers) Chip(label: Text(word)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

