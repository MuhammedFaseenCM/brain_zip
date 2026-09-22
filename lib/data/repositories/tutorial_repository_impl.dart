import 'package:brain_zip/domain/repositories/tutorial_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialRepositoryImpl implements TutorialRepository {
  TutorialRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String gameId) => 'tutorial_seen_$gameId';

  @override
  Future<bool> hasSeen(String gameId) async {
    return _prefs.getBool(_key(gameId)) ?? false;
  }

  @override
  Future<void> markSeen(String gameId) async {
    await _prefs.setBool(_key(gameId), true);
  }
}
