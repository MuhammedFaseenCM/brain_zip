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
