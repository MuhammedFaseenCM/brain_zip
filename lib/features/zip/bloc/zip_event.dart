import 'package:freezed_annotation/freezed_annotation.dart';

part 'zip_event.freezed.dart';

@freezed
sealed class ZipEvent with _$ZipEvent {
  const factory ZipEvent.started({DateTime? date}) = ZipStarted;

  const factory ZipEvent.completed({
    required int points,
    required int timeSeconds,
  }) = ZipCompleted;
}
