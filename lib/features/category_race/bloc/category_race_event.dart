import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_race_event.freezed.dart';

@freezed
sealed class CategoryRaceEvent with _$CategoryRaceEvent {
  const factory CategoryRaceEvent.fetchCategories() = CategoryRaceFetchCategories;

  const factory CategoryRaceEvent.started() = CategoryRaceStarted;

  const factory CategoryRaceEvent.tick() = CategoryRaceTick;

  const factory CategoryRaceEvent.answerSubmitted(String raw) =
      CategoryRaceAnswerSubmitted;

  const factory CategoryRaceEvent.finishRequested() = CategoryRaceFinishRequested;
}

