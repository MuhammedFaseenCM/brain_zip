import 'package:brain_zip/domain/entities/game_streak.dart';
import 'package:brain_zip/domain/repositories/streak_repository.dart';
import 'package:brain_zip/domain/usecases/get_streak.dart';
import 'package:brain_zip/domain/usecases/record_daily_clear.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  late _MockStreakRepository repo;

  setUp(() {
    repo = _MockStreakRepository();
    registerFallbackValue(const GameStreak(gameId: 'zip'));
  });

  test('GetStreak persists when lazy decay resets current', () async {
    when(() => repo.getStreak('zip')).thenAnswer(
      (_) async => const GameStreak(
        gameId: 'zip',
        current: 3,
        longest: 3,
        lastClearedDateId: '20260912',
        freezeAvailable: false,
      ),
    );
    when(() => repo.saveStreak(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as GameStreak,
    );

    final result = await GetStreak(repo)(
      gameId: 'zip',
      now: DateTime(2026, 9, 15),
    );

    expect(result.current, 0);
    expect(result.longest, 3);
    verify(() => repo.saveStreak(any())).called(1);
  });

  test('RecordDailyClear saves updated streak', () async {
    when(() => repo.getStreak('zip')).thenAnswer(
      (_) async => const GameStreak(
        gameId: 'zip',
        current: 2,
        longest: 2,
        lastClearedDateId: '20260914',
      ),
    );
    when(() => repo.saveStreak(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as GameStreak,
    );

    final result = await RecordDailyClear(repo)(
      gameId: 'zip',
      dateId: '20260915',
    );

    expect(result.current, 3);
    expect(result.lastClearedDateId, '20260915');
    verify(() => repo.saveStreak(any())).called(1);
  });
}
