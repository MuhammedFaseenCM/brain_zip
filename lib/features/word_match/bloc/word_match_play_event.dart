import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_match_play_event.freezed.dart';

@freezed
sealed class WordMatchPlayEvent with _$WordMatchPlayEvent {
  const factory WordMatchPlayEvent.started({required String deckId}) =
      WordMatchPlayStarted;

  const factory WordMatchPlayEvent.tick() = WordMatchPlayTick;

  const factory WordMatchPlayEvent.progressChanged({
    required int matched,
    required int total,
  }) = WordMatchPlayProgressChanged;

  const factory WordMatchPlayEvent.won({
    required int points,
    required int elapsedSeconds,
  }) = WordMatchPlayWon;
}

