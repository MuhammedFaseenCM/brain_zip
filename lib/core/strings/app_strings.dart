abstract final class AppStrings {
  static const appTitle = 'Winklo';

  // Home
  static const homeTagline = 'Quick solo mini-games.';
  static const zipTitle = 'Zip';
  static const zipTagline =
      'Start at 1. Fill every cell. Finish on the last number.';
  static const playTodaysZip = "Play today's Zip";
  static const playAgain = 'Play again';
  static const today = 'TODAY';
  static const wordMatch = 'Word Match';
  static const categoryRace = 'Category Race';
  static const streakProtectedLabel = 'Streak protected';
  static const cleared = 'Cleared';
  static String bestTimeLabel(String formatted) => 'Best $formatted';

  // Path Words
  static const pathWordsTitle = 'Path Words';
  static const pathWordsTagline = 'Trace every word across the grid.';
  static const playTodaysPathWords = "Play today's Path Words";
  static const pathWordsUndo = 'Undo';
  static const pathWordsHint = 'Hint';
  static String pathWordsHintWithCount(int n) => 'Hint ($n)';
  static const pathWordsHowToPlayTitle = 'How to play';
  static const pathWordsHowToPlayBody =
      'Start from any letter and drag a path. Lift your finger anytime—the path stays so you can continue from the last cell. Paths move up, down, left, or right—not diagonally. A word counts only when you release on its exact path. Undo backs up. Hint reveals more of the current word, keeping earlier hinted letters connected.';
  static const pathWordsHowToPlayGotIt = 'Got it';
  static String pathWordsUnfoundWordLabel(int letterCount) =>
      '$letterCount-letter word, not found yet';
  static String pathWordsTracingWordLabel(String letters) =>
      'Tracing ${letters.toUpperCase()}';
  static const pathWordsClearedTitle = 'Puzzle cleared!';
  static const pathWordsLoading = 'Building today’s puzzle…';
  static const pathWordsFailed = 'Could not load today’s puzzle.';
  static const retry = 'Retry';

  // Results
  static const newPersonalBest = 'New personal best';

  // Zip game branding (feature, not app title)
  static const zipBrand = 'ZIP';

  static String streakLabel(int days) {
    if (days == 1) return '1-day streak';
    return '$days-day streak';
  }

  static String longestStreakLabel(int days) {
    return 'Best: $days';
  }
}
