import 'package:bloc_test/bloc_test.dart';
import 'package:brain_zip/domain/entities/word_match_deck.dart';
import 'package:brain_zip/domain/entities/word_pair.dart';
import 'package:brain_zip/domain/usecases/fetch_word_match_decks.dart';
import 'package:brain_zip/domain/usecases/get_best_points.dart';
import 'package:brain_zip/features/word_match/cubit/word_match_select_cubit.dart';
import 'package:brain_zip/features/word_match/cubit/word_match_select_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFetchWordMatchDecks extends Mock implements FetchWordMatchDecks {}

class _MockGetBestPoints extends Mock implements GetBestPoints {}

void main() {
  late _MockFetchWordMatchDecks fetchDecks;
  late _MockGetBestPoints bestPoints;

  setUp(() {
    fetchDecks = _MockFetchWordMatchDecks();
    bestPoints = _MockGetBestPoints();
  });

  blocTest<WordMatchSelectCubit, WordMatchSelectState>(
    'load() emits ready items with best points',
    build: () {
      when(() => fetchDecks()).thenAnswer(
        (_) async => [
          WordMatchDeck(
            id: 'animals',
            title: 'Animals',
            seconds: 30,
            pairs: const [WordPair(a: 'cat', b: 'meow')],
          ),
          WordMatchDeck(
            id: 'opposites',
            title: 'Opposites',
            seconds: 40,
            pairs: const [WordPair(a: 'hot', b: 'cold')],
          ),
        ],
      );
      when(() => bestPoints(any())).thenReturn(0);
      when(() => bestPoints('match_opposites')).thenReturn(77);

      return WordMatchSelectCubit(
        fetchWordMatchDecks: fetchDecks,
        getBestPoints: bestPoints,
      );
    },
    act: (c) => c.load(),
    expect: () => [
      isA<WordMatchSelectState>().having(
        (s) => s.status,
        'status',
        WordMatchSelectStatus.loading,
      ),
      isA<WordMatchSelectState>()
          .having((s) => s.status, 'status', WordMatchSelectStatus.ready)
          .having((s) => s.items.length, 'items.length', 2)
          .having((s) => s.items[1].bestPoints, 'items[1].bestPoints', 77),
    ],
    verify: (_) {
      verify(() => fetchDecks()).called(1);
      verify(() => bestPoints('match_animals')).called(1);
      verify(() => bestPoints('match_opposites')).called(1);
    },
  );

  blocTest<WordMatchSelectCubit, WordMatchSelectState>(
    'load() emits failure on exception',
    build: () {
      when(() => fetchDecks()).thenThrow(Exception('boom'));
      return WordMatchSelectCubit(
        fetchWordMatchDecks: fetchDecks,
        getBestPoints: bestPoints,
      );
    },
    act: (c) => c.load(),
    expect: () => [
      isA<WordMatchSelectState>().having(
        (s) => s.status,
        'status',
        WordMatchSelectStatus.loading,
      ),
      isA<WordMatchSelectState>()
          .having((s) => s.status, 'status', WordMatchSelectStatus.failure)
          .having((s) => s.error, 'error', isNotNull),
    ],
  );
}

