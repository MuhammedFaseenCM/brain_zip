import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:brain_zip/domain/entities/word_match_deck.dart';
import 'package:brain_zip/domain/entities/word_pair.dart';
import 'package:brain_zip/domain/usecases/fetch_word_match_deck_by_id.dart';
import 'package:brain_zip/domain/usecases/submit_score.dart';
import 'package:brain_zip/features/word_match/bloc/word_match_play_bloc.dart';
import 'package:brain_zip/features/word_match/bloc/word_match_play_event.dart';
import 'package:brain_zip/features/word_match/bloc/word_match_play_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFetchWordMatchDeckById extends Mock implements FetchWordMatchDeckById {}

class _MockSubmitScore extends Mock implements SubmitScore {}

void main() {
  late _MockFetchWordMatchDeckById fetchDeckById;
  late _MockSubmitScore submitScore;
  late StreamController<int> ticks;

  setUp(() {
    fetchDeckById = _MockFetchWordMatchDeckById();
    submitScore = _MockSubmitScore();
    ticks = StreamController<int>.broadcast();
  });

  tearDown(() async {
    await ticks.close();
  });

  WordMatchDeck _deck({required int seconds}) => WordMatchDeck(
        id: 'animals',
        title: 'Animals',
        seconds: seconds,
        pairs: const [
          WordPair(a: 'cat', b: 'meow'),
          WordPair(a: 'cow', b: 'moo'),
        ],
      );

  blocTest<WordMatchPlayBloc, WordMatchPlayState>(
    'started loads deck and begins playing',
    build: () {
      when(() => fetchDeckById(any())).thenAnswer((_) async => _deck(seconds: 3));
      return WordMatchPlayBloc(
        fetchDeckById: fetchDeckById,
        submitScore: submitScore,
        ticker: () => ticks.stream,
      );
    },
    act: (b) => b.add(const WordMatchPlayEvent.started(deckId: 'animals')),
    expect: () => [
      isA<WordMatchPlayState>()
          .having((s) => s.status, 'status', WordMatchPlayStatus.loading)
          .having((s) => s.deckId, 'deckId', 'animals'),
      isA<WordMatchPlayState>()
          .having((s) => s.status, 'status', WordMatchPlayStatus.playing)
          .having((s) => s.remainingSeconds, 'remainingSeconds', 3)
          .having((s) => s.total, 'total', 2)
          .having((s) => s.deck?.title, 'deck.title', 'Animals'),
    ],
    verify: (_) {
      verify(() => fetchDeckById('animals')).called(1);
    },
  );

  blocTest<WordMatchPlayBloc, WordMatchPlayState>(
    'ticks down and navigates on timeout without submit',
    build: () {
      when(() => fetchDeckById(any())).thenAnswer((_) async => _deck(seconds: 2));
      return WordMatchPlayBloc(
        fetchDeckById: fetchDeckById,
        submitScore: submitScore,
        ticker: () => ticks.stream,
      );
    },
    act: (b) async {
      b.add(const WordMatchPlayEvent.started(deckId: 'animals'));
      await pumpEventQueue();
      b.add(const WordMatchPlayEvent.progressChanged(matched: 1, total: 2));
      await pumpEventQueue();
      ticks.add(0);
      ticks.add(1);
      await pumpEventQueue();
    },
    expect: () => [
      isA<WordMatchPlayState>().having((s) => s.status, 'status', WordMatchPlayStatus.loading),
      isA<WordMatchPlayState>()
          .having((s) => s.status, 'status', WordMatchPlayStatus.playing)
          .having((s) => s.remainingSeconds, 'remainingSeconds', 2),
      isA<WordMatchPlayState>()
          .having((s) => s.matched, 'matched', 1)
          .having((s) => s.total, 'total', 2),
      isA<WordMatchPlayState>().having((s) => s.remainingSeconds, 'remainingSeconds', 1),
      isA<WordMatchPlayState>().having((s) => s.remainingSeconds, 'remainingSeconds', 0),
      isA<WordMatchPlayState>()
          .having((s) => s.status, 'status', WordMatchPlayStatus.navigating)
          .having((s) => s.resultsExtra?['title'], 'title', 'Time up')
          .having((s) => s.resultsExtra?['points'], 'points', 25)
          .having((s) => s.resultsExtra?['improved'], 'improved', false),
    ],
    verify: (_) {
      verifyNever(
        () => submitScore(modeKey: any(named: 'modeKey'), points: any(named: 'points'), timeSeconds: any(named: 'timeSeconds')),
      );
    },
  );

  blocTest<WordMatchPlayBloc, WordMatchPlayState>(
    'won submits score then navigates',
    build: () {
      when(() => fetchDeckById(any())).thenAnswer((_) async => _deck(seconds: 10));
      when(
        () => submitScore(modeKey: 'match_animals', points: 500, timeSeconds: 7),
      ).thenAnswer((_) async => true);

      return WordMatchPlayBloc(
        fetchDeckById: fetchDeckById,
        submitScore: submitScore,
        ticker: () => ticks.stream,
      );
    },
    act: (b) async {
      b.add(const WordMatchPlayEvent.started(deckId: 'animals'));
      await pumpEventQueue();
      b.add(const WordMatchPlayEvent.won(points: 500, elapsedSeconds: 7));
    },
    expect: () => [
      isA<WordMatchPlayState>().having((s) => s.status, 'status', WordMatchPlayStatus.loading),
      isA<WordMatchPlayState>().having((s) => s.status, 'status', WordMatchPlayStatus.playing),
      isA<WordMatchPlayState>().having((s) => s.status, 'status', WordMatchPlayStatus.submitting),
      isA<WordMatchPlayState>()
          .having((s) => s.status, 'status', WordMatchPlayStatus.navigating)
          .having((s) => s.resultsExtra?['title'], 'title', 'All matched!')
          .having((s) => s.resultsExtra?['improved'], 'improved', isTrue),
    ],
    verify: (_) {
      verify(() => submitScore(modeKey: 'match_animals', points: 500, timeSeconds: 7)).called(1);
    },
  );

  test('close() cancels ticker subscription', () async {
    when(() => fetchDeckById(any())).thenAnswer((_) async => _deck(seconds: 3));
    final bloc = WordMatchPlayBloc(
      fetchDeckById: fetchDeckById,
      submitScore: submitScore,
      ticker: () => ticks.stream,
    );

    bloc.add(const WordMatchPlayEvent.started(deckId: 'animals'));
    await pumpEventQueue();
    expect(ticks.hasListener, isTrue);

    await bloc.close();
    expect(ticks.hasListener, isFalse);
  });
}

