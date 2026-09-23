import 'package:winklo/domain/entities/cell.dart';
import 'package:winklo/domain/entities/zip_level.dart';
import 'package:winklo/features/zip/logic/path_validator.dart';
import 'package:winklo/features/zip/logic/zip_rule_tip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PathValidator validator;

  setUp(() {
    final level = ZipLevel(
      id: 't',
      size: 3,
      numbers: {const Cell(0, 0): 1, const Cell(1, 1): 2, const Cell(2, 2): 3},
      walls: const [],
    );
    validator = PathValidator(level);
  });

  test('tips fill every cell when ending on last without full board', () {
    final path = [
      const Cell(0, 0),
      const Cell(1, 0),
      const Cell(2, 0),
      const Cell(2, 1),
      const Cell(2, 2),
    ];
    expect(validator.ruleTipAfterStroke(path), ZipRuleTip.fillEveryCell);
  });

  test('tips finish on last when board is full but tip is not last number', () {
    final notOnLast = [
      const Cell(0, 0),
      const Cell(0, 1),
      const Cell(0, 2),
      const Cell(1, 2),
      const Cell(2, 2),
      const Cell(2, 1),
      const Cell(2, 0),
      const Cell(1, 0),
      const Cell(1, 1),
    ];
    expect(validator.ruleTipAfterStroke(notOnLast), ZipRuleTip.finishOnLast);
  });

  test('no tip for empty or winning paths', () {
    expect(validator.ruleTipAfterStroke(const []), isNull);
    final winning = [
      const Cell(0, 0),
      const Cell(0, 1),
      const Cell(0, 2),
      const Cell(1, 2),
      const Cell(1, 1),
      const Cell(1, 0),
      const Cell(2, 0),
      const Cell(2, 1),
      const Cell(2, 2),
    ];
    expect(validator.ruleTipAfterStroke(winning), isNull);
  });
}
