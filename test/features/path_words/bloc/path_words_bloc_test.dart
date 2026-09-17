import 'package:bloc_test/bloc_test.dart';
import 'package:brain_zip/domain/entities/cell.dart';
import 'package:brain_zip/domain/entities/game_streak.dart';
import 'package:brain_zip/domain/entities/path_words_puzzle.dart';
import 'package:brain_zip/domain/game_ids.dart';
import 'package:brain_zip/domain/usecases/generate_daily_path_words.dart';
import 'package:brain_zip/domain/usecases/record_daily_clear.dart';
import 'package:brain_zip/domain/usecases/submit_score.dart';
import 'package:brain_zip/features/path_words/bloc/path_words_bloc.dart';
import 'package:brain_zip/features/path_words/bloc/path_words_event.dart';
import 'package:brain_zip/features/path_words/bloc/path_words_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGenerateDailyPathWords extends Mock
    implements GenerateDailyPathWords {}

class _MockSubmitScore extends Mock implements SubmitScore {}

class _MockRecordDailyClear extends Mock implements RecordDailyClear {}

class _FakeClock {
  _FakeClock(this._times);

  final List<DateTime> _times;
  var _i = 0;

  DateTime call() {
    final idx = _i < _times.length ? _i : _times.length - 1;
    _i++;
    return _times[idx];
  }
}

PathWordsPuzzle _tinyPuzzle({required DateTime day}) {
  return PathWordsPuzzle(
    id: 't',
    day: day,
    size: 2,
    letters: const ['a', 'b', 'c', 'd'],
    targets: const [
      PathWordsTarget(
        id: 't0',
        word: 'ab',
        start: Cell(0, 0),
        path: [Cell(0, 0), Cell(0, 1)],
        colorIndex: 0,
      ),
      PathWordsTarget(
        id: 't1',
        word: 'cd',
        start: Cell(1, 0),
        path: [Cell(1, 0), Cell(1, 1)],
        colorIndex: 1,
      ),
    ],
  );
}

PathWordsPuzzle _linePuzzle3({required DateTime day}) {
  // 3x3, single target along top row.
  return PathWordsPuzzle(
    id: 'line3',
    day: day,
    size: 3,
    letters: const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'],
    targets: const [
      PathWordsTarget(
        id: 't0',
        word: 'abc',
        start: Cell(0, 0),
        path: [Cell(0, 0), Cell(0, 1), Cell(0, 2)],
        colorIndex: 0,
      ),
    ],
  );
}

void main() {
  late _MockGenerateDailyPathWords generateDaily;
  late _MockSubmitScore submitScore;
  late _MockRecordDailyClear recordDailyClear;

  setUp(() {
    generateDaily = _MockGenerateDailyPathWords();
    submitScore = _MockSubmitScore();
    recordDailyClear = _MockRecordDailyClear();
  });

  blocTest<PathWordsBloc, PathWordsState>(
    'started loads daily puzzle and becomes ready',
    build: () {
      when(() => generateDaily(day: any(named: 'day'))).thenAnswer(
        (inv) async => _tinyPuzzle(day: inv.namedArguments[#day] as DateTime),
      );
      return PathWordsBloc(
        generateDailyPathWords: generateDaily,
        submitScore: submitScore,
        recordDailyClear: recordDailyClear,
        now: () => DateTime(2026, 9, 17, 0, 0, 0),
      );
    },
    act: (b) => b.add(PathWordsEvent.started(date: DateTime(2026, 9, 17))),
    expect: () => [
      isA<PathWordsState>()
          .having((s) => s.status, 'status', PathWordsStatus.loading)
          .having((s) => s.day, 'day', DateTime(2026, 9, 17)),
      isA<PathWordsState>()
          .having((s) => s.status, 'status', PathWordsStatus.ready)
          .having((s) => s.puzzle?.id, 'puzzle.id', 't')
          .having((s) => s.startedAt, 'startedAt', isNotNull)
          .having((s) => s.hintsRemaining, 'hintsRemaining', 3)
          .having((s) => s.completedTargetIds, 'completedTargetIds', isEmpty)
          .having((s) => s.activePath, 'activePath', isEmpty),
    ],
    verify: (_) =>
        verify(() => generateDaily(day: DateTime(2026, 9, 17))).called(1),
  );

  blocTest<PathWordsBloc, PathWordsState>(
    'completing all targets submits score, records streak, and navigates',
    build: () {
      when(() => generateDaily(day: any(named: 'day'))).thenAnswer(
        (inv) async => _tinyPuzzle(day: inv.namedArguments[#day] as DateTime),
      );
      when(
        () => submitScore(
          modeKey: 'path_words_20260917',
          points: 940,
          timeSeconds: 12,
        ),
      ).thenAnswer((_) async => true);
      when(
        () => recordDailyClear(gameId: GameIds.pathWords, dateId: '20260917'),
      ).thenAnswer(
        (_) async => const GameStreak(
          gameId: GameIds.pathWords,
          current: 3,
          longest: 5,
          lastClearedDateId: '20260917',
        ),
      );

      final clock = _FakeClock([
        DateTime(2026, 9, 17, 0, 0, 0),
        DateTime(2026, 9, 17, 0, 0, 12),
      ]);

      return PathWordsBloc(
        generateDailyPathWords: generateDaily,
        submitScore: submitScore,
        recordDailyClear: recordDailyClear,
        now: clock.call,
      );
    },
    act: (b) async {
      b.add(PathWordsEvent.started(date: DateTime(2026, 9, 17)));
      await pumpEventQueue();

      // target t0: (0,0) -> (0,1)
      b.add(const PathWordsEvent.pointerDown(Cell(0, 0)));
      b.add(const PathWordsEvent.pointerEnter(Cell(0, 1)));
      await pumpEventQueue();

      // target t1: (1,0) -> (1,1)
      b.add(const PathWordsEvent.pointerDown(Cell(1, 0)));
      b.add(const PathWordsEvent.pointerEnter(Cell(1, 1)));
      await pumpEventQueue();
    },
    expect: () => [
      isA<PathWordsState>().having(
        (s) => s.status,
        'status',
        PathWordsStatus.loading,
      ),
      isA<PathWordsState>().having(
        (s) => s.status,
        'status',
        PathWordsStatus.ready,
      ),
      isA<PathWordsState>()
          .having((s) => s.status, 'status', PathWordsStatus.playing)
          .having((s) => s.activePath, 'activePath', [const Cell(0, 0)]),
      isA<PathWordsState>()
          .having(
            (s) => s.completedTargetIds,
            'completedTargetIds',
            contains('t0'),
          )
          .having((s) => s.activePath, 'activePath', isEmpty),
      isA<PathWordsState>()
          .having((s) => s.status, 'status', PathWordsStatus.playing)
          .having((s) => s.activePath, 'activePath', [const Cell(1, 0)]),
      isA<PathWordsState>()
          .having(
            (s) => s.completedTargetIds,
            'completedTargetIds',
            containsAll(['t0', 't1']),
          )
          .having((s) => s.activePath, 'activePath', isEmpty),
      isA<PathWordsState>()
          .having((s) => s.status, 'status', PathWordsStatus.submitting)
          .having((s) => s.finished, 'finished', isTrue)
          .having((s) => s.points, 'points', 940)
          .having((s) => s.timeSeconds, 'timeSeconds', 12),
      isA<PathWordsState>()
          .having((s) => s.status, 'status', PathWordsStatus.navigating)
          .having((s) => s.improved, 'improved', isTrue)
          .having((s) => s.resultsExtra?.title, 'title', 'Puzzle cleared!')
          .having((s) => s.resultsExtra?.points, 'points', 940)
          .having((s) => s.resultsExtra?.timeSeconds, 'timeSeconds', 12)
          .having((s) => s.resultsExtra?.replayDaily, 'replayDaily', isTrue)
          .having((s) => s.resultsExtra?.currentStreak, 'currentStreak', 3)
          .having((s) => s.resultsExtra?.longestStreak, 'longestStreak', 5),
    ],
    verify: (_) {
      verify(
        () => submitScore(
          modeKey: 'path_words_20260917',
          points: 940,
          timeSeconds: 12,
        ),
      ).called(1);
      verify(
        () => recordDailyClear(gameId: GameIds.pathWords, dateId: '20260917'),
      ).called(1);
    },
  );

  blocTest<PathWordsBloc, PathWordsState>(
    'undo shortens active path only',
    build: () {
      when(() => generateDaily(day: any(named: 'day'))).thenAnswer(
        (inv) async => _linePuzzle3(day: inv.namedArguments[#day] as DateTime),
      );
      return PathWordsBloc(
        generateDailyPathWords: generateDaily,
        submitScore: submitScore,
        recordDailyClear: recordDailyClear,
        now: () => DateTime(2026, 9, 17, 0, 0, 0),
      );
    },
    act: (b) async {
      b.add(PathWordsEvent.started(date: DateTime(2026, 9, 17)));
      await pumpEventQueue();

      b.add(const PathWordsEvent.pointerDown(Cell(0, 0)));
      b.add(const PathWordsEvent.pointerEnter(Cell(0, 1)));
      await pumpEventQueue();

      b.add(const PathWordsEvent.undo());
    },
    expect: () => [
      isA<PathWordsState>().having(
        (s) => s.status,
        'status',
        PathWordsStatus.loading,
      ),
      isA<PathWordsState>().having(
        (s) => s.status,
        'status',
        PathWordsStatus.ready,
      ),
      isA<PathWordsState>().having((s) => s.activePath, 'activePath', [
        const Cell(0, 0),
      ]),
      isA<PathWordsState>().having((s) => s.activePath, 'activePath', [
        const Cell(0, 0),
        const Cell(0, 1),
      ]),
      isA<PathWordsState>().having((s) => s.activePath, 'activePath', [
        const Cell(0, 0),
      ]),
    ],
  );

  blocTest<PathWordsBloc, PathWordsState>(
    'hint decrements and sets hintFlashCell',
    build: () {
      when(() => generateDaily(day: any(named: 'day'))).thenAnswer(
        (inv) async => _tinyPuzzle(day: inv.namedArguments[#day] as DateTime),
      );
      return PathWordsBloc(
        generateDailyPathWords: generateDaily,
        submitScore: submitScore,
        recordDailyClear: recordDailyClear,
        now: () => DateTime(2026, 9, 17, 0, 0, 0),
      );
    },
    act: (b) async {
      b.add(PathWordsEvent.started(date: DateTime(2026, 9, 17)));
      await pumpEventQueue();
      b.add(const PathWordsEvent.hint());
    },
    expect: () => [
      isA<PathWordsState>().having(
        (s) => s.status,
        'status',
        PathWordsStatus.loading,
      ),
      isA<PathWordsState>().having(
        (s) => s.status,
        'status',
        PathWordsStatus.ready,
      ),
      isA<PathWordsState>()
          .having((s) => s.hintsRemaining, 'hintsRemaining', 2)
          .having((s) => s.hintFlashCell, 'hintFlashCell', const Cell(0, 0)),
    ],
  );

  blocTest<PathWordsBloc, PathWordsState>(
    'reset clears progress but preserves startedAt',
    build: () {
      when(() => generateDaily(day: any(named: 'day'))).thenAnswer(
        (inv) async => _tinyPuzzle(day: inv.namedArguments[#day] as DateTime),
      );
      final fixedNow = DateTime(2026, 9, 17, 0, 0, 0);
      return PathWordsBloc(
        generateDailyPathWords: generateDaily,
        submitScore: submitScore,
        recordDailyClear: recordDailyClear,
        now: () => fixedNow,
      );
    },
    act: (b) async {
      b.add(PathWordsEvent.started(date: DateTime(2026, 9, 17)));
      await pumpEventQueue();

      b.add(const PathWordsEvent.pointerDown(Cell(0, 0)));
      b.add(const PathWordsEvent.pointerEnter(Cell(0, 1)));
      await pumpEventQueue();

      b.add(const PathWordsEvent.reset());
    },
    expect: () => [
      isA<PathWordsState>().having(
        (s) => s.status,
        'status',
        PathWordsStatus.loading,
      ),
      isA<PathWordsState>().having(
        (s) => s.status,
        'status',
        PathWordsStatus.ready,
      ),
      isA<PathWordsState>().having(
        (s) => s.status,
        'status',
        PathWordsStatus.playing,
      ),
      isA<PathWordsState>().having(
        (s) => s.completedTargetIds,
        'completedTargetIds',
        contains('t0'),
      ),
      isA<PathWordsState>()
          .having((s) => s.completedTargetIds, 'completedTargetIds', isEmpty)
          .having((s) => s.activePath, 'activePath', isEmpty)
          .having((s) => s.hintsRemaining, 'hintsRemaining', 3)
          .having(
            (s) => s.startedAt,
            'startedAt',
            DateTime(2026, 9, 17, 0, 0, 0),
          ),
    ],
  );
}
