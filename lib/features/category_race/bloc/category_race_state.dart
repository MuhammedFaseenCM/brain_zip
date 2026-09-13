import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/word_category.dart';

part 'category_race_state.freezed.dart';

enum CategoryRaceStatus { initial, loading, ready, playing, submitting, navigating, failure }

@freezed
sealed class CategoryRaceState with _$CategoryRaceState {
  const factory CategoryRaceState({
    @Default(CategoryRaceStatus.initial) CategoryRaceStatus status,
    WordCategory? category,
    @Default('A') String letter,
    @Default(60) int totalSeconds,
    @Default(60) int remainingSeconds,
    @Default(<String>[]) List<String> answers,
    String? feedback,
    String? error,
    bool? improved,
    Map<String, dynamic>? resultsExtra,
    @Default(false) bool finished,
  }) = _CategoryRaceState;
}

