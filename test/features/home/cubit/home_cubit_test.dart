import 'package:bloc_test/bloc_test.dart';
import 'package:brain_zip/domain/usecases/get_best_points.dart';
import 'package:brain_zip/domain/usecases/get_best_time_seconds.dart';
import 'package:brain_zip/features/home/cubit/home_cubit.dart';
import 'package:brain_zip/features/home/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetBestPoints extends Mock implements GetBestPoints {}

class _MockGetBestTimeSeconds extends Mock implements GetBestTimeSeconds {}

void main() {
  late _MockGetBestPoints pts;
  late _MockGetBestTimeSeconds time;

  setUp(() {
    pts = _MockGetBestPoints();
    time = _MockGetBestTimeSeconds();
  });

  blocTest<HomeCubit, HomeState>(
    'loads bests for daily mode key',
    build: () {
      when(() => pts(any())).thenReturn(42);
      when(() => time(any())).thenReturn(11);

      return HomeCubit(
        getBestPoints: pts,
        getBestTimeSeconds: time,
        now: DateTime.utc(2026, 9, 13),
      );
    },
    act: (c) => c.load(),
    expect: () => [
      isA<HomeState>()
          .having((s) => s.bestPoints, 'bestPoints', 42)
          .having((s) => s.bestTimeSeconds, 'bestTimeSeconds', 11),
    ],
    verify: (_) {
      verify(() => pts('zip_daily_20260913')).called(1);
      verify(() => time('zip_daily_20260913')).called(1);
    },
  );
}

