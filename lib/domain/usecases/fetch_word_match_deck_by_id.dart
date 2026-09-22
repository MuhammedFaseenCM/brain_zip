import 'package:brain_zip/domain/entities/word_match_deck.dart';
import 'package:brain_zip/domain/repositories/word_match_repository.dart';

class FetchWordMatchDeckById {
  FetchWordMatchDeckById(this._repo);
  final WordMatchRepository _repo;

  Future<WordMatchDeck?> call(String deckId) => _repo.fetchDeckById(deckId);
}
