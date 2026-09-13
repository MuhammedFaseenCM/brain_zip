import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/zip_level.dart';
import '../../zip/logic/daily_puzzle_generator.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    required ZipLevel dailyLevel,
    required String dateId,
    @Default(0) int bestPoints,
    int? bestTimeSeconds,
  }) = _HomeState;

  factory HomeState.initial(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    final level = DailyPuzzleGenerator.forDate(day);
    return HomeState(
      dailyLevel: level,
      dateId: DailyPuzzleGenerator.dateId(day),
    );
  }
}

