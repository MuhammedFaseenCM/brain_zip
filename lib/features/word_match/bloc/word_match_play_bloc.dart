import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../domain/usecases/fetch_word_match_deck_by_id.dart';
import '../../../domain/usecases/submit_score.dart';
import 'word_match_play_event.dart';
import 'word_match_play_state.dart';

class WordMatchPlayBloc extends Bloc<WordMatchPlayEvent, WordMatchPlayState> {
  WordMatchPlayBloc({
    required this.fetchDeckById,
    required this.submitScore,
    Stream<int> Function()? ticker,
  })  : _ticker = ticker ??
            (() => Stream<int>.periodic(
                  const Duration(seconds: 1),
                  (i) => i,
                )),
        super(const WordMatchPlayState()) {
    on<WordMatchPlayStarted>(_onStarted);
    on<WordMatchPlayTick>(_onTick);
    on<WordMatchPlayProgressChanged>(_onProgressChanged);
    on<WordMatchPlayWon>(_onWon);
  }

  final FetchWordMatchDeckById fetchDeckById;
  final SubmitScore submitScore;
  final Stream<int> Function() _ticker;

  StreamSubscription<int>? _tickerSub;

  Future<void> _onStarted(
    WordMatchPlayStarted event,
    Emitter<WordMatchPlayState> emit,
  ) async {
    await _tickerSub?.cancel();
    _tickerSub = null;

    emit(
      state.copyWith(
        status: WordMatchPlayStatus.loading,
        deckId: event.deckId,
        deck: null,
        remainingSeconds: 0,
        matched: 0,
        total: 0,
        finished: false,
        error: null,
        resultsExtra: null,
      ),
    );

    try {
      final deck = await fetchDeckById(event.deckId);
      if (emit.isDone) return;

      if (deck == null) {
        emit(
          state.copyWith(
            status: WordMatchPlayStatus.failure,
            error: 'Deck not found',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: WordMatchPlayStatus.playing,
          deck: deck,
          remainingSeconds: deck.seconds,
          total: deck.pairs.length,
        ),
      );

      _tickerSub = _ticker().listen((_) {
        add(const WordMatchPlayEvent.tick());
      });
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(status: WordMatchPlayStatus.failure, error: '$e'));
    }
  }

  Future<void> _onTick(WordMatchPlayTick event, Emitter<WordMatchPlayState> emit) async {
    if (state.status != WordMatchPlayStatus.playing || state.finished) return;
    if (state.remainingSeconds <= 0) return;

    final next = state.remainingSeconds - 1;
    emit(state.copyWith(remainingSeconds: next));

    if (next <= 0 && state.matched < state.total) {
      await _tickerSub?.cancel();
      _tickerSub = null;
      emit(
        state.copyWith(
          status: WordMatchPlayStatus.navigating,
          finished: true,
          resultsExtra: <String, dynamic>{
            'title': 'Time up',
            'points': state.matched * 25,
            'timeSeconds': state.deck?.seconds ?? 60,
            'improved': false,
            'subtitle': 'Matched ${state.matched} / ${state.total}',
          },
        ),
      );
    }
  }

  void _onProgressChanged(
    WordMatchPlayProgressChanged event,
    Emitter<WordMatchPlayState> emit,
  ) {
    if (state.status != WordMatchPlayStatus.playing || state.finished) return;
    emit(state.copyWith(matched: event.matched, total: event.total));
  }

  Future<void> _onWon(WordMatchPlayWon event, Emitter<WordMatchPlayState> emit) async {
    if (state.status != WordMatchPlayStatus.playing || state.finished) return;
    final deckId = state.deckId;
    final deck = state.deck;
    if (deckId == null || deck == null) return;

    emit(
      state.copyWith(
        finished: true,
        status: WordMatchPlayStatus.submitting,
      ),
    );

    await _tickerSub?.cancel();
    _tickerSub = null;

    final improved = await submitScore(
      modeKey: 'match_$deckId',
      points: event.points,
      timeSeconds: event.elapsedSeconds,
    );

    if (emit.isDone) return;

    emit(
      state.copyWith(
        status: WordMatchPlayStatus.navigating,
        resultsExtra: <String, dynamic>{
          'title': 'All matched!',
          'points': event.points,
          'timeSeconds': event.elapsedSeconds,
          'improved': improved,
          'subtitle': deck.title,
        },
      ),
    );
  }

  @override
  Future<void> close() async {
    await _tickerSub?.cancel();
    _tickerSub = null;
    return super.close();
  }
}

