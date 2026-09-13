import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/word_category.dart';
import '../../../domain/usecases/fetch_categories.dart';
import '../../../domain/usecases/submit_score.dart';
import 'category_race_event.dart';
import 'category_race_state.dart';

class CategoryRaceBloc extends Bloc<CategoryRaceEvent, CategoryRaceState> {
  CategoryRaceBloc({
    required FetchCategories fetchCategories,
    required SubmitScore submitScore,
    Random? random,
    int roundSeconds = 60,
    Stream<int> Function()? ticker,
  })  : _fetchCategories = fetchCategories,
        _submitScore = submitScore,
        _rng = random ?? Random(),
        _roundSeconds = roundSeconds,
        _ticker = ticker ??
            (() => Stream<int>.periodic(const Duration(seconds: 1), (i) => i)),
        super(
          CategoryRaceState(
            totalSeconds: roundSeconds,
            remainingSeconds: roundSeconds,
          ),
        ) {
    on<CategoryRaceFetchCategories>(_onFetchCategories);
    on<CategoryRaceStarted>(_onStarted);
    on<CategoryRaceTick>(_onTick);
    on<CategoryRaceAnswerSubmitted>(_onAnswerSubmitted);
    on<CategoryRaceFinishRequested>(_onFinishRequested);
  }

  final FetchCategories _fetchCategories;
  final SubmitScore _submitScore;
  final Random _rng;
  final int _roundSeconds;
  final Stream<int> Function() _ticker;

  StreamSubscription<int>? _tickerSub;

  Future<void> _onFetchCategories(
    CategoryRaceFetchCategories event,
    Emitter<CategoryRaceState> emit,
  ) async {
    await _tickerSub?.cancel();
    _tickerSub = null;

    emit(
      state.copyWith(
        status: CategoryRaceStatus.loading,
        category: null,
        letter: 'A',
        totalSeconds: _roundSeconds,
        remainingSeconds: _roundSeconds,
        answers: const [],
        feedback: null,
        error: null,
        improved: null,
        resultsExtra: null,
        finished: false,
      ),
    );

    try {
      final categories = await _fetchCategories();
      if (emit.isDone) return;

      if (categories.isEmpty) {
        emit(state.copyWith(status: CategoryRaceStatus.ready));
        return;
      }

      final category = categories[_rng.nextInt(categories.length)];
      final letter = _pickLetter(category);

      emit(
        state.copyWith(
          status: CategoryRaceStatus.ready,
          category: category,
          letter: letter,
        ),
      );
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(status: CategoryRaceStatus.failure, error: '$e'));
    }
  }

  Future<void> _onStarted(CategoryRaceStarted event, Emitter<CategoryRaceState> emit) async {
    final category = state.category;
    if (category == null || state.finished) return;

    await _tickerSub?.cancel();
    _tickerSub = null;
    emit(
      state.copyWith(
        status: CategoryRaceStatus.playing,
        totalSeconds: _roundSeconds,
        remainingSeconds: _roundSeconds,
        answers: const [],
        feedback: null,
        error: null,
        improved: null,
        resultsExtra: null,
        finished: false,
      ),
    );

    _tickerSub = _ticker().listen((_) {
      add(const CategoryRaceEvent.tick());
    });
  }

  Future<void> _onTick(CategoryRaceTick event, Emitter<CategoryRaceState> emit) async {
    if (state.status != CategoryRaceStatus.playing || state.finished) return;
    if (state.remainingSeconds <= 0) return;

    final next = state.remainingSeconds - 1;
    emit(state.copyWith(remainingSeconds: next));

    if (next <= 0) {
      await _onFinishRequested(const CategoryRaceFinishRequested(), emit);
    }
  }

  void _onAnswerSubmitted(
    CategoryRaceAnswerSubmitted event,
    Emitter<CategoryRaceState> emit,
  ) {
    if (state.status != CategoryRaceStatus.playing || state.finished) return;
    final category = state.category;
    if (category == null) return;

    final raw = event.raw.trim();
    if (raw.isEmpty) return;

    final word = raw.toLowerCase();
    final letterLower = state.letter.toLowerCase();

    if (!word.startsWith(letterLower)) {
      emit(state.copyWith(feedback: 'Must start with ${state.letter}'));
      return;
    }

    if (!category.normalizedWords.contains(word)) {
      emit(state.copyWith(feedback: 'Not in ${category.name}'));
      return;
    }

    if (state.answers.contains(word)) {
      emit(state.copyWith(feedback: 'Already used'));
      return;
    }

    emit(
      state.copyWith(
        answers: [word, ...state.answers],
        feedback: null,
      ),
    );
  }

  Future<void> _onFinishRequested(
    CategoryRaceFinishRequested event,
    Emitter<CategoryRaceState> emit,
  ) async {
    if (state.status != CategoryRaceStatus.playing || state.finished) return;
    final category = state.category;
    if (category == null) return;

    emit(state.copyWith(finished: true, status: CategoryRaceStatus.submitting));

    await _tickerSub?.cancel();
    _tickerSub = null;

    final points = state.answers.length * 50;
    final improved = await _submitScore(
      modeKey: 'race_${category.id}',
      points: points,
      timeSeconds: state.totalSeconds,
    );

    if (emit.isDone) return;

    emit(
      state.copyWith(
        status: CategoryRaceStatus.navigating,
        improved: improved,
        resultsExtra: <String, dynamic>{
          'title': 'Round over',
          'points': points,
          'timeSeconds': state.totalSeconds,
          'improved': improved,
          'subtitle':
              '${category.name} · ${state.letter} · ${state.answers.length} words',
        },
      ),
    );
  }

  String _pickLetter(WordCategory category) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final viable = <String>[];
    final words = category.normalizedWords;
    for (var i = 0; i < letters.length; i++) {
      final l = letters[i];
      final lower = l.toLowerCase();
      if (words.any((w) => w.startsWith(lower))) viable.add(l);
    }
    if (viable.isEmpty) return 'A';
    return viable[_rng.nextInt(viable.length)];
  }

  @override
  Future<void> close() async {
    await _tickerSub?.cancel();
    _tickerSub = null;
    return super.close();
  }
}

