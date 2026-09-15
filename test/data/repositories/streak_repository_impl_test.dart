import 'package:brain_zip/data/repositories/streak_repository_impl.dart';
import 'package:brain_zip/domain/entities/game_streak.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('round-trips streak fields per gameId', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = StreakRepositoryImpl(prefs);

    final empty = await repo.getStreak('zip');
    expect(empty.current, 0);
    expect(empty.longest, 0);
    expect(empty.lastClearedDateId, isNull);
    expect(empty.freezeAvailable, isTrue);

    await repo.saveStreak(
      const GameStreak(
        gameId: 'zip',
        current: 3,
        longest: 5,
        lastClearedDateId: '20260915',
        freezeAvailable: false,
      ),
    );

    final loaded = await repo.getStreak('zip');
    expect(loaded.current, 3);
    expect(loaded.longest, 5);
    expect(loaded.lastClearedDateId, '20260915');
    expect(loaded.freezeAvailable, isFalse);
  });

  test('isolates streaks across gameIds', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = StreakRepositoryImpl(prefs);

    await repo.saveStreak(
      const GameStreak(
        gameId: 'zip',
        current: 4,
        longest: 4,
        lastClearedDateId: '20260915',
      ),
    );
    await repo.saveStreak(
      const GameStreak(
        gameId: 'word_match',
        current: 1,
        longest: 2,
        lastClearedDateId: '20260914',
        freezeAvailable: false,
      ),
    );

    final zip = await repo.getStreak('zip');
    final match = await repo.getStreak('word_match');
    expect(zip.current, 4);
    expect(zip.freezeAvailable, isTrue);
    expect(match.current, 1);
    expect(match.longest, 2);
    expect(match.freezeAvailable, isFalse);
  });
}
