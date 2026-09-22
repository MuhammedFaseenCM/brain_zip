abstract class TutorialRepository {
  Future<bool> hasSeen(String gameId);

  Future<void> markSeen(String gameId);
}
