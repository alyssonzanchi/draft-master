import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../models/app_user.dart';
import '../providers/auth_notifier.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'create_team_screen.dart';
import '../widgets/player_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _handleSaveTeam(Team teamData) async {
    try {
      if (teamData.id != null) {
        await _firestoreService.addTeam(teamData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time atualizado!'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        await _firestoreService.addTeam(teamData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time criado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _logout() async {
    await signOutFromGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? appUser = Provider.of<AuthNotifier>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Times'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              accountName: Text(appUser?.displayName ?? 'Coach'),
              accountEmail: Text(appUser?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: appUser?.photoURL != null
                    ? NetworkImage(appUser!.photoURL!)
                    : null,
                child: appUser?.photoURL == null
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Team>>(
        stream: _firestoreService.getUserTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ocorreu um erro ao carregar:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Verifique se o Índice foi criado no Console do Firebase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final teams = snapshot.data ?? [];

          if (teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_esports, size: 64, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum time encontrado.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie o seu primeiro time clicando em +',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return _buildTeamCard(team);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newTeam = await Navigator.push<Team>(
            context,
            MaterialPageRoute(builder: (context) => const CreateTeamScreen()),
          );
          if (newTeam != null) {
            _handleSaveTeam(newTeam);
          }
        },
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: ExpansionTile(
        title: Text(
          team.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${team.players.length} Jogadores'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () async {
                final updatedTeam = await Navigator.push<Team>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTeamScreen(initialTeam: team),
                  ),
                );

                if (updatedTeam != null) {
                  _handleSaveTeam(updatedTeam);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                try {
                  await _firestoreService.deleteTeam(team.id!);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Time removido com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao remover time: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        children: team.players
            .map((player) => PlayerCard(player: player))
            .toList(),
      ),
    );
  }
}
