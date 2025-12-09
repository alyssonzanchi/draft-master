class Player {
  final String summonerName;
  final String role;
  final String rank;
  final int level;
  final List<String> topChampions;

  Player({
    required this.summonerName,
    required this.role,
    required this.rank,
    required this.level,
    required this.topChampions,
  });

  Map<String, dynamic> toMap() {
    return {
      'summonerName': summonerName,
      'role': role,
      'rank': rank,
      'level': level,
      'topChampions': topChampions,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      summonerName: map['summonerName'] ?? '',
      role: map['role'] ?? '',
      rank: map['rank'] ?? 'Unranked',
      level: (map['level'] ?? 0).toInt(),
      topChampions: List<String>.from(map['topChampions'] ?? []),
    );
  }
}
