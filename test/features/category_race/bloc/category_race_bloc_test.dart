import 'dart:async';
import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:brain_zip/domain/entities/word_category.dart';
import 'package:brain_zip/domain/usecases/fetch_categories.dart';
import 'package:brain_zip/domain/usecases/submit_score.dart';
import 'package:brain_zip/features/category_race/bloc/category_race_bloc.dart';
import 'package:brain_zip/features/category_race/bloc/category_race_event.dart';
import 'package:brain_zip/features/category_race/bloc/category_race_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_analytics_repository.dart';

class _MockFetchCategories extends Mock implements FetchCategories {}

class _MockSubmitScore extends Mock implements SubmitScore {}

class _FakeRandom implements Random {
  _FakeRandom(this._values);

  final List<int> _values;
  var _i = 0;

  @override
  int nextInt(int max) {
    final v = _values[_i % _values.length];
    _i++;
    return v % max;
  }

  @override
  bool nextBool() => nextInt(2) == 0;

  @override
  double nextDouble() => nextInt(1000) / 1000.0;
}

void main() {
  late _MockFetchCategories fetchCategories;
  late _MockSubmitScore submitScore;
  late StreamController<int> ticks;

  final animals = WordCategory(
    id: 'animals',
    name: 'Animals',
    words: const ['cat', 'cow'],
  );
  final fruits = WordCategory(
    id: 'fruits',
    name: 'Fruits',
    words: const ['apple', 'banana'],
  );

  late MockAnalyticsRepository analytics;

  setUp(() {
    analytics = MockAnalyticsRepository();
    stubAnalytics(analytics);
    fetchCategories = _MockFetchCategories();
    submitScore = _MockSubmitScore();
    ticks = StreamController<int>.broadcast();
  });

  tearDown(() async {
    await ticks.close();
  });

  blocTest<CategoryRaceBloc, CategoryRaceState>(
    'fetchCategories loads and picks category/letter (Random injected)',
    build: () {
      when(() => fetchCategories()).thenAnswer((_) async => [animals, fruits]);
      return CategoryRaceBloc(
        fetchCategories: fetchCategories,
        submitScore: submitScore,
        analytics: analytics,
        random: _FakeRandom([
          1,
          1,
        ]), // category index 1, viable letter index 1 => 'B'
      );
    },
    act: (b) => b.add(const CategoryRaceEvent.fetchCategories()),
    expect: () => [
      isA<CategoryRaceState>().having(
        (s) => s.status,
        'status',
        CategoryRaceStatus.loading,
      ),
      isA<CategoryRaceState>()
          .having((s) => s.status, 'status', CategoryRaceStatus.ready)
          .having((s) => s.category?.id, 'category.id', 'fruits')
          .having((s) => s.letter, 'letter', 'B'),
    ],
    verify: (_) => verify(() => fetchCategories()).called(1),
  );

  blocTest<CategoryRaceBloc, CategoryRaceState>(
    'AnswerSubmitted validates and sets feedback on invalid letter',
    build: () {
      when(() => fetchCategories()).thenAnswer((_) async => [fruits]);
      return CategoryRaceBloc(
        fetchCategories: fetchCategories,
        submitScore: submitScore,
        analytics: analytics,
        random: _FakeRandom([0]), // viable letters [A, B] => pick A
        roundSeconds: 2,
        ticker: () => ticks.stream,
      );
    },
    act: (b) async {
      b.add(const CategoryRaceEvent.fetchCategories());
      await pumpEventQueue();
      b.add(const CategoryRaceEvent.started());
      await pumpEventQueue();
      b.add(const CategoryRaceEvent.answerSubmitted('banana'));
    },
    expect: () => [
      isA<CategoryRaceState>().having(
        (s) => s.status,
        'status',
        CategoryRaceStatus.loading,
      ),
      isA<CategoryRaceState>()
          .having((s) => s.status, 'status', CategoryRaceStatus.ready)
          .having((s) => s.letter, 'letter', 'A'),
      isA<CategoryRaceState>()
          .having((s) => s.status, 'status', CategoryRaceStatus.playing)
          .having((s) => s.remainingSeconds, 'remainingSeconds', 2),
      isA<CategoryRaceState>().having(
        (s) => s.feedback,
        'feedback',
        'Must start with A',
      ),
    ],
  );

  blocTest<CategoryRaceBloc, CategoryRaceState>(
    'valid answer adds to list; finish submits score with race_<id>',
    build: () {
      when(() => fetchCategories()).thenAnswer((_) async => [fruits]);
      when(
        () => submitScore(modeKey: 'race_fruits', points: 50, timeSeconds: 2),
      ).thenAnswer((_) async => true);

      return CategoryRaceBloc(
        fetchCategories: fetchCategories,
        submitScore: submitScore,
        analytics: analytics,
        random: _FakeRandom([0]), // viable letters [A, B] => pick A
        roundSeconds: 2,
        ticker: () => ticks.stream,
      );
    },
    act: (b) async {
      b.add(const CategoryRaceEvent.fetchCategories());
      await pumpEventQueue();
      b.add(const CategoryRaceEvent.started());
      await pumpEventQueue();
      b.add(const CategoryRaceEvent.answerSubmitted('apple'));
      await pumpEventQueue();
      ticks.add(0);
      ticks.add(1);
      await pumpEventQueue();
    },
    expect: () => [
      isA<CategoryRaceState>().having(
        (s) => s.status,
        'status',
        CategoryRaceStatus.loading,
      ),
      isA<CategoryRaceState>().having(
        (s) => s.status,
        'status',
        CategoryRaceStatus.ready,
      ),
      isA<CategoryRaceState>().having(
        (s) => s.status,
        'status',
        CategoryRaceStatus.playing,
      ),
      isA<CategoryRaceState>()
          .having((s) => s.answers, 'answers', ['apple'])
          .having((s) => s.feedback, 'feedback', isNull),
      isA<CategoryRaceState>().having(
        (s) => s.remainingSeconds,
        'remainingSeconds',
        1,
      ),
      isA<CategoryRaceState>().having(
        (s) => s.remainingSeconds,
        'remainingSeconds',
        0,
      ),
      isA<CategoryRaceState>().having(
        (s) => s.status,
        'status',
        CategoryRaceStatus.submitting,
      ),
      isA<CategoryRaceState>()
          .having((s) => s.status, 'status', CategoryRaceStatus.navigating)
          .having((s) => s.resultsExtra?.title, 'title', 'Round over')
          .having((s) => s.resultsExtra?.improved, 'improved', isTrue)
          .having((s) => s.resultsExtra?.points, 'points', 50),
    ],
    verify: (_) {
      verify(
        () => submitScore(modeKey: 'race_fruits', points: 50, timeSeconds: 2),
      ).called(1);
    },
  );

  test('close() cancels ticker subscription', () async {
    when(() => fetchCategories()).thenAnswer((_) async => [fruits]);
    final bloc = CategoryRaceBloc(
      fetchCategories: fetchCategories,
      submitScore: submitScore,
      analytics: analytics,
      random: Random(0),
      roundSeconds: 2,
      ticker: () => ticks.stream,
    );

    bloc.add(const CategoryRaceEvent.fetchCategories());
    await pumpEventQueue();
    bloc.add(const CategoryRaceEvent.started());
    await pumpEventQueue();
    expect(ticks.hasListener, isTrue);

    await bloc.close();
    expect(ticks.hasListener, isFalse);
  });
}
