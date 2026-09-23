import 'package:winklo/domain/entities/word_match_deck.dart';

abstract class WordMatchRepository {
  Future<List<WordMatchDeck>> fetchDecks();

  Future<WordMatchDeck?> fetchDeckById(String id);
}
