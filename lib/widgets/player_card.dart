import 'package:flutter/material.dart';
import '../models/player.dart';
import '../screens/player_details_screen.dart';

class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({super.key, required this.player});

  String _getChampionImageUrl(String championName) {
    String cleanName = championName
        .replaceAll(' ', '')
        .replaceAll("'", "")
        .replaceAll(".", "");

    if (cleanName == "Wukong") cleanName = "MonkeyKing";
    if (cleanName == "RenataGlasc") cleanName = "Renata";
    if (cleanName == "Nunu&Willump") cleanName = "Nunu";

    return "https://ddragon.leagueoflegends.com/cdn/14.23.1/img/champion/$cleanName.png";
  }

  Widget _getRoleIcon(String role, ColorScheme colors) {
    IconData icon;
    switch (role.toUpperCase()) {
      case 'TOP':
        icon = Icons.shield_outlined;
        break;
      case 'JUNGLE':
        icon = Icons.park;
        break;
      case 'MID':
        icon = Icons.flash_on;
        break;
      case 'ADC':
        icon = Icons.adjust;
        break;
      case 'SUPPORT':
        icon = Icons.favorite;
        break;
      default:
        icon = Icons.help_outline;
    }
    return Icon(icon, color: colors.primary, size: 28);
  }

  Color _getRankColor(String rank) {
    final r = rank.toUpperCase();
    if (r.contains("IRON")) return const Color(0xFF534D49);
    if (r.contains("BRONZE")) return const Color(0xFF8C523A);
    if (r.contains("SILVER")) return const Color(0xFF80989D);
    if (r.contains("GOLD")) return const Color(0xFFCD8837);
    if (r.contains("PLATINUM")) return const Color(0xFF4E9996);
    if (r.contains("EMERALD")) return const Color(0xFF2BAC76);
    if (r.contains("DIAMOND")) return const Color(0xFF576BCE);
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withAlpha(80), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerDetailsScreen(player: player),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _getRoleIcon(player.role, colorScheme),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.summonerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRankColor(player.rank),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            player.rank,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "NÍVEL",
                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                      ),
                      Text(
                        "${player.level}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: Colors.grey[800]),
              const SizedBox(height: 8),

              Text(
                'Melhores Campeões',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: player.topChampions.map((champion) {
                  if (champion == "Desconhecido" || champion == "Nenhum") {
                    return const SizedBox();
                  }
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey[900],
                          backgroundImage: NetworkImage(
                            _getChampionImageUrl(champion),
                          ),
                          onBackgroundImageError: (_, __) {},
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        champion,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
