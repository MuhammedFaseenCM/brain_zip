import 'package:bloc_test/bloc_test.dart';
import 'package:brain_zip/domain/entities/game_streak.dart';
import 'package:brain_zip/domain/game_ids.dart';
import 'package:brain_zip/domain/usecases/get_best_points.dart';
import 'package:brain_zip/domain/usecases/get_best_time_seconds.dart';
import 'package:brain_zip/domain/usecases/get_streak.dart';
import 'package:brain_zip/features/home/cubit/home_cubit.dart';
import 'package:brain_zip/features/home/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetBestPoints extends Mock implements GetBestPoints {}

class _MockGetBestTimeSeconds extends Mock implements GetBestTimeSeconds {}

class _MockGetStreak extends Mock implements GetStreak {}

void main() {
  late _MockGetBestPoints pts;
  late _MockGetBestTimeSeconds time;
  late _MockGetStreak getStreak;

  setUp(() {
    pts = _MockGetBestPoints();
    time = _MockGetBestTimeSeconds();
    getStreak = _MockGetStreak();
  });

  blocTest<HomeCubit, HomeState>(
    'loads bests and streak for daily zip',
    build: () {
      when(() => pts(any())).thenReturn(42);
      when(() => time(any())).thenReturn(11);
      when(
        () => getStreak(
          gameId: GameIds.zip,
          now: any(named: 'now'),
        ),
      ).thenAnswer(
        (_) async => const GameStreak(
          gameId: GameIds.zip,
          current: 4,
          longest: 7,
          lastClearedDateId: '20260913',
        ),
      );

      return HomeCubit(
        getBestPoints: pts,
        getBestTimeSeconds: time,
        getStreak: getStreak,
        now: DateTime.utc(2026, 9, 13),
      );
    },
    act: (c) => c.load(),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.bestPoints, 'bestPoints', 42)
          .having((s) => s.bestTimeSeconds, 'bestTimeSeconds', 11)
          .having((s) => s.currentStreak, 'currentStreak', 4)
          .having((s) => s.longestStreak, 'longestStreak', 7),
    ],
    verify: (_) {
      verify(() => pts('zip_daily_20260913')).called(1);
      verify(() => time('zip_daily_20260913')).called(1);
      verify(
        () => getStreak(
          gameId: GameIds.zip,
          now: any(named: 'now'),
        ),
      ).called(1);
    },
  );
}
