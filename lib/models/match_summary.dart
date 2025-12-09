class MatchSummary {
  final bool isWin;
  final int kills;
  final int deaths;
  final int assists;
  final String championName;
  final String mode;

  MatchSummary({
    required this.isWin,
    required this.kills,
    required this.deaths,
    required this.assists,
    required this.championName,
    required this.mode,
  });

  String get kda {
    if (deaths == 0) return "Perfeito";
    double ratio = (kills + assists) / deaths;
    return "${ratio.toStringAsFixed(2)} KDA";
  }
}
