class HighScore {
  const HighScore({
    required this.modeKey,
    required this.bestPoints,
    this.bestTimeSeconds,
  });

  final String modeKey;
  final int bestPoints;
  final int? bestTimeSeconds;
}
