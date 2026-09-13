import 'package:brain_zip/domain/entities/word_match_deck.dart';
import 'package:brain_zip/domain/repositories/word_match_repository.dart';

class FetchWordMatchDecks {
  FetchWordMatchDecks(this._repo);
  final WordMatchRepository _repo;

  Future<List<WordMatchDeck>> call() => _repo.fetchDecks();
}
