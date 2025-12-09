import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/player.dart';
import '../models/match_summary.dart';

class RiotApiService {
  final String _apiKey = "RGAPI-3b801004-4cec-44e2-a3d0-b5c6e320d524";
  final String _accountBaseUrl = 'https://americas.api.riotgames.com/riot';
  final String _lolBaseUrl = 'https://br1.api.riotgames.com/lol';
  final String _matchBaseUrl = 'https://americas.api.riotgames.com/lol';
  final String _dDragonUrl =
      'https://ddragon.leagueoflegends.com/cdn/14.23.1/data/pt_BR/champion.json';

  static Map<String, String>? _championIdToNameMap;

  Future<Player> fetchPlayerBySummonerName(String riotId, String role) async {
    try {
      if (!riotId.contains('#')) {
        throw Exception('Formato inválido. Use "Nome#TAG" (ex: Nick#BR1)');
      }

      final parts = riotId.split('#');
      final gameName = parts[0];
      final tagLine = parts[1];

      final accountUrl = Uri.parse(
        '$_accountBaseUrl/account/v1/accounts/by-riot-id/$gameName/$tagLine?api_key=$_apiKey',
      );

      final accountResponse = await http.get(accountUrl);

      if (accountResponse.statusCode != 200) _handleError(accountResponse);

      final Map<String, dynamic> accountData = json.decode(
        accountResponse.body,
      );

      final String puuid = accountData['puuid']?.toString() ?? "";
      final String realName = accountData['gameName']?.toString() ?? gameName;
      final String realTag = accountData['tagLine']?.toString() ?? tagLine;

      if (puuid.isEmpty) {
        throw Exception('PUUID não encontrado para este jogador.');
      }

      final summonerUrl = Uri.parse(
        '$_lolBaseUrl/summoner/v4/summoners/by-puuid/$puuid?api_key=$_apiKey',
      );

      final summonerResponse = await http.get(summonerUrl);

      if (summonerResponse.statusCode != 200) _handleError(summonerResponse);

      final Map<String, dynamic> summonerData = json.decode(
        summonerResponse.body,
      );

      final String summonerId = summonerData['id']?.toString() ?? "";
      final int level = (summonerData['summonerLevel'] as num?)?.toInt() ?? 0;

      final rank = await _getRank(summonerId);

      final topChampions = await _getTopChampions(puuid);

      return Player(
        summonerName: '$realName#$realTag',
        role: role,
        level: level,
        rank: rank,
        topChampions: topChampions,
      );
    } catch (e) {
      debugPrint("Erro ao conectar a API: $e");
      rethrow;
    }
  }

  Future<List<MatchSummary>> getRecentMatches(String riotId) async {
    try {
      final parts = riotId.split('#');
      final accountUrl = Uri.parse(
        '$_accountBaseUrl/account/v1/accounts/by-riot-id/${parts[0]}/${parts[1]}?api_key=$_apiKey',
      );
      final accountRes = await http.get(accountUrl);
      if (accountRes.statusCode != 200) return [];

      final puuid = json.decode(accountRes.body)['puuid'];

      final idsUrl = Uri.parse(
        '$_matchBaseUrl/match/v5/matches/by-puuid/$puuid/ids?start=0&count=5&api_key=$_apiKey',
      );
      final idsRes = await http.get(idsUrl);
      if (idsRes.statusCode != 200) return [];

      final List<dynamic> matchIds = json.decode(idsRes.body);
      List<MatchSummary> matches = [];

      for (String matchId in matchIds) {
        final matchUrl = Uri.parse(
          '$_matchBaseUrl/match/v5/matches/$matchId?api_key=$_apiKey',
        );
        final matchRes = await http.get(matchUrl);

        if (matchRes.statusCode == 200) {
          final data = json.decode(matchRes.body);
          final info = data['info'];
          final List<dynamic> participants = info['participants'];

          final me = participants.firstWhere(
            (p) => p['puuid'] == puuid,
            orElse: () => null,
          );

          if (me != null) {
            matches.add(
              MatchSummary(
                isWin: me['win'],
                kills: me['kills'],
                deaths: me['deaths'],
                assists: me['assists'],
                championName: me['championName'],
                mode: info['gameMode'],
              ),
            );
          }
        }
      }

      return matches;
    } catch (e) {
      debugPrint("Erro ao buscar partidas: $e");
      return [];
    }
  }

  Future<String> _getRank(String summonerId) async {
    if (summonerId.isEmpty) return "Unranked";

    final url = Uri.parse(
      '$_lolBaseUrl/league/v4/entries/by-summoner/$summonerId?api_key=$_apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final soloQueue = data.firstWhere(
        (entry) => entry['queueType'] == 'RANKED_SOLO_5x5',
        orElse: () => null,
      );

      if (soloQueue != null) {
        return "${soloQueue['tier']} ${soloQueue['rank']}";
      }
    }
    return "Unranked";
  }

  Future<List<String>> _getTopChampions(String puuid) async {
    final url = Uri.parse(
      '$_lolBaseUrl/champion-mastery/v4/champion-masteries/by-puuid/$puuid/top?count=3&api_key=$_apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) return ["Desconhecido"];

    final List<dynamic> masteries = json.decode(response.body);
    if (masteries.isEmpty) return ["Nenhum"];

    if (_championIdToNameMap == null) {
      await _loadChampionData();
    }

    List<String> championNames = [];
    for (var mastery in masteries) {
      final championId = mastery['championId'];
      final String name =
          _championIdToNameMap?[championId.toString()] ?? "ID:$championId";
      championNames.add(name);
    }

    return championNames;
  }

  Future<void> _loadChampionData() async {
    try {
      final response = await http.get(Uri.parse(_dDragonUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> champions = data['data'];

        _championIdToNameMap = {};

        champions.forEach((key, value) {
          final String id = value['key'].toString();
          final String name = value['name'].toString();
          _championIdToNameMap![id] = name;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar Data Dragon: $e");
      _championIdToNameMap = {};
    }
  }

  void _handleError(http.Response response) {
    if (response.statusCode == 404) throw Exception('Não encontrado.');
    if (response.statusCode == 403) throw Exception('Chave API expirada.');
    if (response.statusCode == 429) {
      throw Exception('Limite de requisições excedido.');
    }
    throw Exception('Erro na API (${response.statusCode})');
  }
}
