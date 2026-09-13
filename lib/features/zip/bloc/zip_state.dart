import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/zip_level.dart';
import '../../results/results_args.dart';
import '../logic/daily_puzzle_generator.dart';

part 'zip_state.freezed.dart';

enum ZipStatus { initial, ready, submitting, navigating }

@freezed
sealed class ZipState with _$ZipState {
  const factory ZipState({
    required DateTime day,
    required ZipLevel level,
    @Default(ZipStatus.ready) ZipStatus status,
    @Default(false) bool finished,
    bool? improved,
    int? points,
    int? timeSeconds,
    ResultsArgs? resultsExtra,
  }) = _ZipState;

  factory ZipState.initial(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    final level = DailyPuzzleGenerator.forDate(day);
    return ZipState(day: day, level: level, status: ZipStatus.ready);
  }
}
