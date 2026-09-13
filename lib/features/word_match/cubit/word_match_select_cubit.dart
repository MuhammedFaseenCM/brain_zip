import 'package:bloc/bloc.dart';

import '../../../domain/usecases/fetch_word_match_decks.dart';
import '../../../domain/usecases/get_best_points.dart';
import 'word_match_select_state.dart';

class WordMatchSelectCubit extends Cubit<WordMatchSelectState> {
  WordMatchSelectCubit({
    required this.fetchWordMatchDecks,
    required this.getBestPoints,
  }) : super(const WordMatchSelectState());

  final FetchWordMatchDecks fetchWordMatchDecks;
  final GetBestPoints getBestPoints;

  Future<void> load() async {
    if (state.status == WordMatchSelectStatus.loading) return;
    emit(state.copyWith(status: WordMatchSelectStatus.loading, error: null));

    try {
      final decks = await fetchWordMatchDecks();
      final items = decks
          .map(
            (d) => WordMatchSelectItem(
              deck: d,
              bestPoints: getBestPoints('match_${d.id}'),
            ),
          )
          .toList(growable: false);

      emit(state.copyWith(status: WordMatchSelectStatus.ready, items: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: WordMatchSelectStatus.failure,
          error: '$e',
        ),
      );
    }
  }
}

