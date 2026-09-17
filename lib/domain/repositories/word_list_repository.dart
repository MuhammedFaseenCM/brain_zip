abstract class WordListRepository {
  Future<List<String>> loadEnglishWords({int minLen = 4, int maxLen = 10});
}
