import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/player.dart';
import 'create_team_screen.dart';
import '../widgets/player_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Team? _currentTeam;

  void _updateTeam(Team newTeam) {
    setState(() {
      _currentTeam = newTeam;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Time'), centerTitle: true),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTeam = await Navigator.push<Team>(
            context,
            MaterialPageRoute(builder: (context) => const CreateTeamScreen()),
          );
          if (newTeam != null) {
            _updateTeam(newTeam);
          }
        },
        tooltip: 'Criar ou Editar Time',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_currentTeam == null || _currentTeam!.players.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum time criado.\nClique em "+" para adicionar um time.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _currentTeam!.players.length,
      itemBuilder: (context, index) {
        final Player player = _currentTeam!.players[index];
        return PlayerCard(player: player);
      },
    );
  }
}
