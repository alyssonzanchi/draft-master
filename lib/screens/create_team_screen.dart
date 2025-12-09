import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../services/riot_api_service.dart';

class CreateTeamScreen extends StatefulWidget {
  final Team? initialTeam;
  const CreateTeamScreen({super.key, this.initialTeam});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final RiotApiService _apiService = RiotApiService();

  late List<Player> _players;
  late String _teamName;

  @override
  void initState() {
    super.initState();
    if (widget.initialTeam != null) {
      _players = List.from(widget.initialTeam!.players);
      _teamName = widget.initialTeam!.name;
      _teamNameController.text = _teamName;
    } else {
      _players = [];
      _teamName = '';
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _addPlayer() async {
    final Player? newPlayer = await _showAddPlayerDialog();

    if (newPlayer != null && mounted) {
      setState(() {
        _players.add(newPlayer);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newPlayer.summonerName} adicionado!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<Player?> _showAddPlayerDialog() async {
    final dialogFormKey = GlobalKey<FormState>();
    final summonerNameController = TextEditingController();
    String? selectedRole;
    bool isLoading = false;

    const List<String> roles = ['TOP', 'JUNGLE', 'MID', 'ADC', 'SUPPORT'];

    final result = await showDialog<Player?>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext sbContext, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Adicionar novo jogador"),
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: summonerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Riot ID (Nome#TAG)',
                        hintText: 'Ex: Faker#BR1',
                        border: OutlineInputBorder(),
                        helperText: 'Não esqueça da TAG (ex: #BR1)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira o Riot ID';
                        }
                        if (!value.contains('#')) {
                          return 'Use o formato Nome#Tag';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      hint: const Text('Função (Role)'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: roles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setDialogState(() {
                          selectedRole = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione uma função';
                        }
                        return null;
                      },
                    ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Buscando na Riot Games...',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(null);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Adicionar'),
                    onPressed: () async {
                      if (dialogFormKey.currentState!.validate()) {
                        final summonerName = summonerNameController.text;
                        final role = selectedRole!;

                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          final player = await _apiService
                              .fetchPlayerBySummonerName(summonerName, role);

                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(player);
                          }
                        } catch (e) {
                          if (sbContext.mounted) {
                            setDialogState(() {
                              isLoading = false;
                            });
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Erro ao buscar jogador! Verifique o Nome#TAG.',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
    );

    summonerNameController.dispose();
    return result;
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _saveTeam() {
    if (_formKey.currentState!.validate()) {
      final newTeam = Team(
        id: widget.initialTeam?.id,
        userId: widget.initialTeam?.userId ?? '',
        name: _teamNameController.text,
        players: _players,
      );
      Navigator.of(context).pop(newTeam);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialTeam != null ? 'Editar Time' : 'Criar Novo Time',
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Time',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group_work),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome para o time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Jogadores (${_players.length}/5)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.person_add, color: Colors.green),
                    onPressed: _addPlayer,
                    tooltip: 'Adicionar Jogador',
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                          child: Text(player.role.substring(0, 1)),
                        ),
                        title: Text(player.summonerName),
                        subtitle: Text(player.rank),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _removePlayer(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTeam,
                  child: const Text('Salvar Time'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
