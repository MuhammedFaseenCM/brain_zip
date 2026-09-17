import 'package:brain_zip/data/repositories/word_list_repository_impl.dart';
import 'package:brain_zip/domain/entities/cell.dart';
import 'package:brain_zip/domain/path_words/path_words_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> words;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    words = await WordListRepositoryImpl().loadEnglishWords();
    expect(words.length, greaterThan(200));
  });

  test('same day is deterministic', () {
    final a = PathWordsGenerator.generate(
      day: DateTime(2026, 9, 17),
      words: words,
    );
    final b = PathWordsGenerator.generate(
      day: DateTime(2026, 9, 17),
      words: words,
    );
    expect(a.letters, b.letters);
    expect(
      a.targets.map((t) => t.word).toList(),
      b.targets.map((t) => t.word).toList(),
    );
  });

  test('covers 8x8 exactly once and paths spell words', () {
    final p = PathWordsGenerator.generate(
      day: DateTime(2026, 1, 1),
      words: words,
    );
    expect(p.size, 8);
    expect(p.letters.length, 64);

    final seen = <Cell>{};
    for (final t in p.targets) {
      expect(t.path.first, t.start);
      expect(t.path.length, t.word.length);
      for (var i = 0; i < t.path.length; i++) {
        final c = t.path[i];
        expect(seen.add(c), isTrue);
        expect(p.letterAt(c), t.word[i]);
      }
    }
    expect(seen.length, 64);
  });

  test('generates for 30 consecutive days', () {
    final start = DateTime(2026, 9, 1);
    for (var i = 0; i < 30; i++) {
      final day = start.add(Duration(days: i));
      expect(
        () => PathWordsGenerator.generate(day: day, words: words),
        returnsNormally,
      );
    }
  });
}
