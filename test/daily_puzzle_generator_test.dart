import 'package:flutter_test/flutter_test.dart';

import 'package:brain_zip/features/zip/logic/daily_puzzle_generator.dart';
import 'package:brain_zip/features/zip/logic/path_validator.dart';

void main() {
  test('same day always yields the same puzzle', () {
    final a = DailyPuzzleGenerator.forDate(DateTime(2026, 9, 13));
    final b = DailyPuzzleGenerator.forDate(DateTime(2026, 9, 13, 23, 59));
    expect(a.id, b.id);
    expect(a.size, b.size);
    expect(a.maxNumber, b.maxNumber);
    expect(a.numbers, b.numbers);
  });

  test('different days yield different ids', () {
    final a = DailyPuzzleGenerator.forDate(DateTime(2026, 9, 13));
    final b = DailyPuzzleGenerator.forDate(DateTime(2026, 9, 14));
    expect(a.id, isNot(b.id));
  });

  test('numbers stay within industrial cap of 15', () {
    for (var day = 1; day <= 40; day++) {
      final level = DailyPuzzleGenerator.forDate(DateTime(2026, 1, day));
      expect(level.maxNumber, lessThanOrEqualTo(DailyPuzzleGenerator.maxNumbers));
      expect(level.maxNumber, greaterThanOrEqualTo(2));
      expect(level.numbers.values.toSet().length, level.maxNumber);
      expect(level.numbers.values.contains(1), isTrue);
      expect(level.numbers.values.contains(level.maxNumber), isTrue);

      // Must end on last number cell.
      final end = level.numbers.entries
          .firstWhere((e) => e.value == level.maxNumber)
          .key;
      final start = level.numbers.entries.firstWhere((e) => e.value == 1).key;
      expect(start, isNot(end));

      final validator = PathValidator(level);
      expect(validator.endCell, end);
    }
  });

  test('grid sizes stay in the 6–8 band', () {
    for (var day = 1; day <= 20; day++) {
      final level = DailyPuzzleGenerator.forDate(DateTime(2026, 3, day));
      expect(level.size, anyOf(6, 7, 8));
    }
  });
}
