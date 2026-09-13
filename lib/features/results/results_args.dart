class ResultsArgs {
  const ResultsArgs({
    required this.title,
    required this.subtitle,
    required this.timeSeconds,
    required this.improved,
    this.points,
    this.replayDaily = false,
    this.replayLevelId,
    this.nextLevelId,
  });

  final String title;
  final String subtitle;
  final int timeSeconds;
  final bool improved;
  final int? points;
  final bool replayDaily;
  final String? replayLevelId;
  final String? nextLevelId;
}
