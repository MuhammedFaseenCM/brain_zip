class GameStreak {
  const GameStreak({
    required this.gameId,
    this.current = 0,
    this.longest = 0,
    this.lastClearedDateId,
    this.freezeAvailable = true,
    this.isOnFreeze = false,
  });

  final String gameId;
  final int current;
  final int longest;
  final String? lastClearedDateId;
  final bool freezeAvailable;

  /// Display-only: true when the streak is protected by an unused freeze.
  final bool isOnFreeze;

  GameStreak copyWith({
    String? gameId,
    int? current,
    int? longest,
    String? lastClearedDateId,
    bool? freezeAvailable,
    bool? isOnFreeze,
    bool clearLastClearedDateId = false,
  }) {
    return GameStreak(
      gameId: gameId ?? this.gameId,
      current: current ?? this.current,
      longest: longest ?? this.longest,
      lastClearedDateId: clearLastClearedDateId
          ? null
          : (lastClearedDateId ?? this.lastClearedDateId),
      freezeAvailable: freezeAvailable ?? this.freezeAvailable,
      isOnFreeze: isOnFreeze ?? this.isOnFreeze,
    );
  }
}
