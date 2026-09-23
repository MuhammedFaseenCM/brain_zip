import 'package:winklo/domain/path_words/path_words_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pointsForElapsed clamps and scales', () {
    expect(PathWordsScoring.pointsForElapsed(0), 1000);
    expect(PathWordsScoring.pointsForElapsed(12), 940);
    expect(PathWordsScoring.pointsForElapsed(10000), 50);
  });
}
