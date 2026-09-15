import 'package:bloc_test/bloc_test.dart';
import 'package:brain_zip/domain/entities/game_streak.dart';
import 'package:brain_zip/domain/game_ids.dart';
import 'package:brain_zip/domain/usecases/record_daily_clear.dart';
import 'package:brain_zip/domain/usecases/submit_score.dart';
import 'package:brain_zip/features/zip/bloc/zip_bloc.dart';
import 'package:brain_zip/features/zip/bloc/zip_event.dart';
import 'package:brain_zip/features/zip/bloc/zip_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubmitScore extends Mock implements SubmitScore {}

class _MockRecordDailyClear extends Mock implements RecordDailyClear {}

void main() {
  late _MockSubmitScore submitScore;
  late _MockRecordDailyClear recordDailyClear;

  setUp(() {
    submitScore = _MockSubmitScore();
    recordDailyClear = _MockRecordDailyClear();
  });

  blocTest<ZipBloc, ZipState>(
    'ZipStarted loads daily level for date',
    build: () => ZipBloc(
      submitScore: submitScore,
      recordDailyClear: recordDailyClear,
      now: DateTime.utc(2026, 9, 13),
    ),
    act: (b) => b.add(ZipEvent.started(date: DateTime.utc(2026, 9, 14))),
    expect: () => [
      isA<ZipState>().having((s) => s.level.id, 'level.id', 'daily_20260914'),
    ],
  );

  blocTest<ZipBloc, ZipState>(
    'ZipCompleted submits score, records streak, and signals navigation',
    build: () {
      when(
        () => submitScore(
          modeKey: 'zip_daily_20260913',
          points: 900,
          timeSeconds: 12,
        ),
      ).thenAnswer((_) async => true);
      when(
        () => recordDailyClear(gameId: GameIds.zip, dateId: '20260913'),
      ).thenAnswer(
        (_) async => const GameStreak(
          gameId: GameIds.zip,
          current: 3,
          longest: 5,
          lastClearedDateId: '20260913',
        ),
      );

      return ZipBloc(
        submitScore: submitScore,
        recordDailyClear: recordDailyClear,
        now: DateTime.utc(2026, 9, 13),
      );
    },
    act: (b) => b.add(const ZipEvent.completed(points: 900, timeSeconds: 12)),
    expect: () => [
      isA<ZipState>()
          .having((s) => s.status, 'status', ZipStatus.submitting)
          .having((s) => s.finished, 'finished', isTrue)
          .having((s) => s.points, 'points', 900)
          .having((s) => s.timeSeconds, 'timeSeconds', 12),
      isA<ZipState>()
          .having((s) => s.status, 'status', ZipStatus.navigating)
          .having((s) => s.improved, 'improved', isTrue)
          .having((s) => s.resultsExtra?.title, 'title', 'Puzzle cleared!')
          .having((s) => s.resultsExtra?.timeSeconds, 'timeSeconds', 12)
          .having((s) => s.resultsExtra?.replayDaily, 'replayDaily', isTrue)
          .having((s) => s.resultsExtra?.currentStreak, 'currentStreak', 3)
          .having((s) => s.resultsExtra?.longestStreak, 'longestStreak', 5),
    ],
    verify: (_) {
      verify(
        () => submitScore(
          modeKey: 'zip_daily_20260913',
          points: 900,
          timeSeconds: 12,
        ),
      ).called(1);
      verify(
        () => recordDailyClear(gameId: GameIds.zip, dateId: '20260913'),
      ).called(1);
    },
  );
}
