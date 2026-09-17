import 'package:brain_zip/data/repositories/word_list_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and filters 4–10 letter words', () async {
    final repo = WordListRepositoryImpl();
    final words = await repo.loadEnglishWords();
    expect(words, isNotEmpty);
    expect(words.every((w) => w.length >= 4 && w.length <= 10), isTrue);
    expect(words.every((w) => w == w.toLowerCase()), isTrue);
  });
}
