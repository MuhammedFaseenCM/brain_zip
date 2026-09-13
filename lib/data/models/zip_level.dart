class Cell {
  const Cell(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is Cell && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '$row,$col';

  static Cell parse(String key) {
    final parts = key.split(',');
    return Cell(int.parse(parts[0]), int.parse(parts[1]));
  }

  List<int> toList() => [row, col];
}

class Wall {
  const Wall(this.a, this.b);

  final Cell a;
  final Cell b;

  bool blocks(Cell from, Cell to) {
    return (from == a && to == b) || (from == b && to == a);
  }

  factory Wall.fromJson(Map<String, dynamic> json) {
    final a = (json['a'] as List).cast<num>();
    final b = (json['b'] as List).cast<num>();
    return Wall(Cell(a[0].toInt(), a[1].toInt()), Cell(b[0].toInt(), b[1].toInt()));
  }

  Map<String, dynamic> toJson() => {
        'a': a.toList(),
        'b': b.toList(),
      };
}

class ZipLevel {
  const ZipLevel({
    required this.id,
    required this.size,
    required this.numbers,
    required this.walls,
    this.order = 0,
  });

  final String id;
  final int size;
  final Map<Cell, int> numbers;
  final List<Wall> walls;
  final int order;

  int get maxNumber {
    if (numbers.isEmpty) return 0;
    return numbers.values.reduce((a, b) => a > b ? a : b);
  }

  factory ZipLevel.fromJson(Map<String, dynamic> json, {String? id}) {
    final rawNumbers = Map<String, dynamic>.from(json['numbers'] as Map);
    final numbers = <Cell, int>{};
    for (final entry in rawNumbers.entries) {
      numbers[Cell.parse(entry.key)] = (entry.value as num).toInt();
    }
    final walls = (json['walls'] as List? ?? [])
        .map((e) => Wall.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return ZipLevel(
      id: id ?? json['id'] as String,
      size: (json['size'] as num).toInt(),
      numbers: numbers,
      walls: walls,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'size': size,
        'order': order,
        'numbers': {
          for (final e in numbers.entries) e.key.toString(): e.value,
        },
        'walls': walls.map((w) => w.toJson()).toList(),
      };
}
