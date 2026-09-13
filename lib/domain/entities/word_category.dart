class WordCategory {
  const WordCategory({
    required this.id,
    required this.name,
    required this.words,
    this.order = 0,
  });

  final String id;
  final String name;
  final List<String> words;
  final int order;

  Set<String> get normalizedWords =>
      words.map((w) => w.trim().toLowerCase()).toSet();

  factory WordCategory.fromJson(Map<String, dynamic> json, {String? id}) {
    return WordCategory(
      id: id ?? json['id'] as String,
      name: json['name'] as String,
      order: (json['order'] as num?)?.toInt() ?? 0,
      words: (json['words'] as List).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'order': order,
        'words': words,
      };
}
