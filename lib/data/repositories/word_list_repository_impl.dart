import 'package:winklo/domain/repositories/word_list_repository.dart';
import 'package:flutter/services.dart';

class WordListRepositoryImpl implements WordListRepository {
  WordListRepositoryImpl({this.assetPath = 'assets/words/en_words.txt'});

  final String assetPath;
  List<String>? _cache;

  @override
  Future<List<String>> loadEnglishWords({
    int minLen = 4,
    int maxLen = 10,
  }) async {
    final all = await _loadAll();
    return all
        .where((w) => w.length >= minLen && w.length <= maxLen)
        .toList(growable: false);
  }

  Future<List<String>> _loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(assetPath);
    final parsed =
        raw
            .split(RegExp(r'\r?\n'))
            .map((l) => l.trim().toLowerCase())
            .where((w) => RegExp(r'^[a-z]+$').hasMatch(w))
            .toSet()
            .toList()
          ..sort();
    _cache = parsed;
    return parsed;
  }
}
