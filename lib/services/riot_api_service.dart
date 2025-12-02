import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';

class RiotApiService {
  final String _apiKey = "RGAPI-62d3748a-82a8-4da5-b675-217916141c75";
  final String _baseUrl =
      "[https://br1.api.riotgames.com/lol](https://br1.api.riotgames.com/lol)";

  Future<Player> fetchPlayerBySummonerName(
    String summonerName,
    String role,
  ) async {
    try {
      final summonerUrl = Uri.parse(
        '$_baseUrl/summoner/v4/summoners/by-name/$summonerName?api_key=$_apiKey',
      );

      print("Buscando dados em: $summonerUrl");

      final response = await http.get(summonerUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String puuid = data['puuid'];
        final int level = data['level'];
        final String summonerId = data['id'];

        final String rank =
            "Não implementado"; // TODO: Implementar busca de elo

        final List<String> topChampions = [
          "Garen",
          "Ashe",
        ]; // TODO: Implementar busca de campeões

        return Player(
          summonerName: data['name'],
          role: role,
          level: level,
          rank: rank,
          topChampions: topChampions,
        );
      } else {
        print("Erro na API da Riot: ${response.statusCode}");
        print("Corpo: ${response.body}");
        throw Exception("Falha ao buscar jogador: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Erro ao conectar a API: $e");
      throw Exception("Falha ao buscar dados do jogador: $e");
    }
  }

  // TODO: Implementar as outras funções de estatística
  Future<String> getBestChampionAgainst(
    String playerPuuid,
    String opponentPuuid,
  ) async {
    // TODO
    return "Jinx";
  }
}
