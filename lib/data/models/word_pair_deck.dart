class WordPair {
  const WordPair({required this.a, required this.b});

  final String a;
  final String b;

  factory WordPair.fromJson(Map<String, dynamic> json) => WordPair(
        a: json['a'] as String,
        b: json['b'] as String,
      );

  Map<String, dynamic> toJson() => {'a': a, 'b': b};

  bool matches(String left, String right) {
    final l = left.toLowerCase();
    final r = right.toLowerCase();
    return (a.toLowerCase() == l && b.toLowerCase() == r) ||
        (a.toLowerCase() == r && b.toLowerCase() == l);
  }
}

class WordMatchDeck {
  const WordMatchDeck({
    required this.id,
    required this.title,
    required this.pairs,
    this.seconds = 60,
    this.order = 0,
  });

  final String id;
  final String title;
  final List<WordPair> pairs;
  final int seconds;
  final int order;

  factory WordMatchDeck.fromJson(Map<String, dynamic> json, {String? id}) {
    return WordMatchDeck(
      id: id ?? json['id'] as String,
      title: json['title'] as String,
      seconds: (json['seconds'] as num?)?.toInt() ?? 60,
      order: (json['order'] as num?)?.toInt() ?? 0,
      pairs: (json['pairs'] as List)
          .map((e) => WordPair.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'seconds': seconds,
        'order': order,
        'pairs': pairs.map((p) => p.toJson()).toList(),
      };
}
