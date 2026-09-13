import 'package:bloc_test/bloc_test.dart';
import 'package:brain_zip/domain/usecases/submit_score.dart';
import 'package:brain_zip/features/zip/bloc/zip_bloc.dart';
import 'package:brain_zip/features/zip/bloc/zip_event.dart';
import 'package:brain_zip/features/zip/bloc/zip_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubmitScore extends Mock implements SubmitScore {}

void main() {
  late _MockSubmitScore submitScore;

  setUp(() {
    submitScore = _MockSubmitScore();
  });

  blocTest<ZipBloc, ZipState>(
    'ZipStarted loads daily level for date',
    build: () =>
        ZipBloc(submitScore: submitScore, now: DateTime.utc(2026, 9, 13)),
    act: (b) => b.add(ZipEvent.started(date: DateTime.utc(2026, 9, 14))),
    expect: () => [
      isA<ZipState>().having((s) => s.level.id, 'level.id', 'daily_20260914'),
    ],
  );

  blocTest<ZipBloc, ZipState>(
    'ZipCompleted submits score and signals navigation',
    build: () {
      when(
        () => submitScore(
          modeKey: 'zip_daily_20260913',
          points: 900,
          timeSeconds: 12,
        ),
      ).thenAnswer((_) async => true);

      return ZipBloc(submitScore: submitScore, now: DateTime.utc(2026, 9, 13));
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
          .having((s) => s.resultsExtra?.replayDaily, 'replayDaily', isTrue),
    ],
    verify: (_) {
      verify(
        () => submitScore(
          modeKey: 'zip_daily_20260913',
          points: 900,
          timeSeconds: 12,
        ),
      ).called(1);
    },
  );
}
