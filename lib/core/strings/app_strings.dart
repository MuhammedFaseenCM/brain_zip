abstract final class AppStrings {
  static const appTitle = 'Winklo';

  // Home
  static const homeTagline = 'Quick solo mini-games.';
  static const playTodaysZip = "Play today's Zip";
  static const today = 'TODAY';
  static const wordMatch = 'Word Match';
  static const categoryRace = 'Category Race';
  static const streakProtectedLabel = 'Streak protected';
  static const cleared = 'Cleared';

  // Path Words
  static const pathWordsTitle = 'Path Words';
  static const pathWordsTagline = 'Trace every word across the grid.';
  static const playTodaysPathWords = "Play today's Path Words";
  static const pathWordsUndo = 'Undo';
  static const pathWordsHint = 'Hint';
  static String pathWordsHintWithCount(int n) => 'Hint ($n)';
  static const pathWordsHowToPlayTitle = 'How to play';
  static const pathWordsHowToPlayBody =
      'Drag a path from each marked start letter. Paths move up, down, left, or right—not diagonally. Find every listed word to clear the board. Undo backs up your current path. Hint reveals the next correct cell.';
  static const pathWordsClearedTitle = 'Puzzle cleared!';
  static const pathWordsLoading = 'Building today’s puzzle…';
  static const pathWordsFailed = 'Could not load today’s puzzle.';

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
