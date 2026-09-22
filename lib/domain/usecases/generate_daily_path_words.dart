import 'package:brain_zip/domain/entities/path_words_puzzle.dart';
import 'package:brain_zip/domain/path_words/path_words_generator.dart';
import 'package:brain_zip/domain/play_period.dart';
import 'package:brain_zip/domain/repositories/word_list_repository.dart';

class GenerateDailyPathWords {
  GenerateDailyPathWords(this._words, {this.period = PlayPeriod.daily});
  final WordListRepository _words;
  final Duration period;

  Future<PathWordsPuzzle> call({required DateTime day}) async {
    final list = await _words.loadEnglishWords(minLen: 3, maxLen: 5);
    return PathWordsGenerator.generate(day: day, words: list, period: period);
  }
}
