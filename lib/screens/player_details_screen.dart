import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/match_summary.dart';
import '../services/riot_api_service.dart';

class PlayerDetailsScreen extends StatefulWidget {
  final Player player;

  const PlayerDetailsScreen({super.key, required this.player});

  @override
  State<PlayerDetailsScreen> createState() => _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState extends State<PlayerDetailsScreen> {
  final RiotApiService _apiService = RiotApiService();
  late Future<List<MatchSummary>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _apiService.getRecentMatches(widget.player.summonerName);
  }

  String _getSplashArtUrl(String championName) {
    if (championName == "Desconhecido" || championName == "Nenhum") {
      return "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/Aatrox_0.jpg";
    }

    String cleanName = championName
        .replaceAll(' ', '')
        .replaceAll("'", "")
        .replaceAll(".", "");

    if (cleanName == "Wukong") cleanName = "MonkeyKing";
    if (cleanName == "RenataGlasc") cleanName = "Renata";
    if (cleanName == "Nunu&Willump") cleanName = "Nunu";

    return "https://ddragon.leagueoflegends.com/cdn/img/champion/splash/${cleanName}_0.jpg";
  }

  String _getChampionIconUrl(String championName) {
    String cleanName = championName
        .replaceAll(' ', '')
        .replaceAll("'", "")
        .replaceAll(".", "");
    if (cleanName == "Wukong") cleanName = "MonkeyKing";
    if (cleanName == "RenataGlasc") cleanName = "Renata";
    if (cleanName == "Nunu&Willump") cleanName = "Nunu";
    return "https://ddragon.leagueoflegends.com/cdn/14.23.1/img/champion/$cleanName.png";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mainChampion = widget.player.topChampions.isNotEmpty
        ? widget.player.topChampions.first
        : "Nenhum";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.player.summonerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _getSplashArtUrl(mainChampion),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey[900]);
                    },
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.shield,
                          widget.player.role,
                          colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        _buildInfoChip(
                          Icons.star,
                          "Nível ${widget.player.level}",
                          colorScheme.secondary,
                        ),
                        const SizedBox(width: 10),
                        _buildInfoChip(
                          Icons.emoji_events,
                          widget.player.rank,
                          _getRankColor(widget.player.rank),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Últimas 5 Partidas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    FutureBuilder<List<MatchSummary>>(
                      future: _matchesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text(
                            "Erro ao carregar histórico.",
                            style: TextStyle(color: Colors.red),
                          );
                        }
                        final matches = snapshot.data ?? [];
                        if (matches.isEmpty) {
                          return const Text(
                            "Nenhuma partida recente encontrada.",
                            style: TextStyle(color: Colors.grey),
                          );
                        }

                        return Column(
                          children: matches
                              .map((match) => _buildMatchTile(match))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchTile(MatchSummary match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: match.isWin ? const Color(0xFF1E2820) : const Color(0xFF281E1E),
        border: Border(
          left: BorderSide(
            color: match.isWin ? Colors.greenAccent : Colors.redAccent,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              _getChampionIconUrl(match.championName),
            ),
          ),
          const SizedBox(width: 12),
          // Resultado e Modo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.isWin ? "VITÓRIA" : "DERROTA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: match.isWin ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              Text(
                match.mode,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${match.kills} / ${match.deaths} / ${match.assists}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                match.kda,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(String rank) {
    final r = rank.toUpperCase();
    if (r.contains("GOLD")) return const Color(0xFFCD8837);
    if (r.contains("PLATINUM")) return const Color(0xFF4E9996);
    if (r.contains("EMERALD")) return const Color(0xFF2BAC76);
    if (r.contains("DIAMOND")) return const Color(0xFF576BCE);
    return Colors.grey;
  }
}
