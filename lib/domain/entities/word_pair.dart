class WordPair {
  const WordPair({required this.a, required this.b});

  final String a;
  final String b;

  factory WordPair.fromJson(Map<String, dynamic> json) =>
      WordPair(a: json['a'] as String, b: json['b'] as String);

  Map<String, dynamic> toJson() => {'a': a, 'b': b};

  bool matches(String left, String right) {
    final l = left.toLowerCase();
    final r = right.toLowerCase();
    return (a.toLowerCase() == l && b.toLowerCase() == r) ||
        (a.toLowerCase() == r && b.toLowerCase() == l);
  }
}
