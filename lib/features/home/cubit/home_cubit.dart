import 'package:bloc/bloc.dart';

import '../../../domain/usecases/get_best_points.dart';
import '../../../domain/usecases/get_best_time_seconds.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetBestPoints getBestPoints,
    required GetBestTimeSeconds getBestTimeSeconds,
    DateTime? now,
  })  : _getBestPoints = getBestPoints,
        _getBestTimeSeconds = getBestTimeSeconds,
        super(HomeState.initial(now ?? DateTime.now()));

  final GetBestPoints _getBestPoints;
  final GetBestTimeSeconds _getBestTimeSeconds;

  void load() {
    final key = 'zip_${state.dailyLevel.id}';
    emit(
      state.copyWith(
        bestPoints: _getBestPoints(key),
        bestTimeSeconds: _getBestTimeSeconds(key),
      ),
    );
  }
}

