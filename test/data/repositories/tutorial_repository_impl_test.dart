import 'package:brain_zip/data/repositories/tutorial_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to unseen and marks seen per gameId', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = TutorialRepositoryImpl(prefs);

    expect(await repo.hasSeen('zip'), isFalse);
    expect(await repo.hasSeen('path_words'), isFalse);

    await repo.markSeen('zip');

    expect(await repo.hasSeen('zip'), isTrue);
    expect(await repo.hasSeen('path_words'), isFalse);
  });

  test('isolates seen flags across gameIds', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = TutorialRepositoryImpl(prefs);

    await repo.markSeen('path_words');

    expect(await repo.hasSeen('path_words'), isTrue);
    expect(await repo.hasSeen('zip'), isFalse);
  });
}
