import 'cell.dart';

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
    return Wall(
      Cell(a[0].toInt(), a[1].toInt()),
      Cell(b[0].toInt(), b[1].toInt()),
    );
  }

  Map<String, dynamic> toJson() => {'a': a.toList(), 'b': b.toList()};
}
