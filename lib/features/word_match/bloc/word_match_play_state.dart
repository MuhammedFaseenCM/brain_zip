import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/word_match_deck.dart';
import '../../results/results_args.dart';

part 'word_match_play_state.freezed.dart';

enum WordMatchPlayStatus { initial, loading, playing, submitting, navigating, failure }

@freezed
sealed class WordMatchPlayState with _$WordMatchPlayState {
  const factory WordMatchPlayState({
    @Default(WordMatchPlayStatus.initial) WordMatchPlayStatus status,
    String? deckId,
    WordMatchDeck? deck,
    @Default(0) int remainingSeconds,
    @Default(0) int matched,
    @Default(0) int total,
    @Default(false) bool finished,
    ResultsArgs? resultsExtra,
    String? error,
  }) = _WordMatchPlayState;
}

