import 'player.dart';

class Team {
  final String? id;
  final String userId;
  final String name;
  final List<Player> players;

  Team({
    this.id,
    this.userId = '',
    required this.name,
    required this.players,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'players': players.map((player) => player.toMap()).toList(),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map, String documentId) {
    return Team(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      players: map['players'] != null
          ? List<Player>.from(
              (map['players'] as List<dynamic>).map(
                (x) => Player.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }
}