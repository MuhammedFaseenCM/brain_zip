import 'package:winklo/data/repositories/score_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('submitScore improves points and time', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = ScoreRepositoryImpl(prefs);

    expect(repo.getBestPoints('zip_x'), 0);
    expect(repo.getBestTimeSeconds('zip_x'), isNull);

    final improved = await repo.submitScore(
      modeKey: 'zip_x',
      points: 100,
      timeSeconds: 20,
    );
    expect(improved, isTrue);
    expect(repo.getBestPoints('zip_x'), 100);
    expect(repo.getBestTimeSeconds('zip_x'), 20);

    final notImproved = await repo.submitScore(
      modeKey: 'zip_x',
      points: 50,
      timeSeconds: 25,
    );
    expect(notImproved, isFalse);
  });
}
