import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({super.key, required this.player});

  Widget _getRoleIcon(String role) {
    final icons = {
      'TOP': Icons.landscape,
      'JUNGLE': Icons.park,
      'MID': Icons.square_foot,
      'ADC': Icons.adjust,
      'SUPPORT': Icons.favorite_border,
    };
    return Icon(
      icons[role.toUpperCase()] ?? Icons.person,
      color: const Color(0xFFC89B3C),
      size: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0x990A323C),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFC89B3C), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getRoleIcon(player.role),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.summonerName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF0E6D2),
                      ),
                    ),
                    Text(
                      player.role,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFC89B3C)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Nível', player.level.toString()),
                _buildStat('Elo', player.rank),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Melhores Campeões:',
              style: TextStyle(color: Color(0xFFF0E6D2), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: player.topChampions
                  .map(
                    (champion) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(champion),
                        backgroundColor: const Color(0x4D000000),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF0E6D2),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
