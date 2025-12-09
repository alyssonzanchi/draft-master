import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/team.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get _teamsRef => _db.collection('teams');

  Future<void> addTeam(Team team) async {
    if (currentUserId == null) {
      throw Exception('Usuário não está logado!');
    }

    final teamData = {
      ...team.toMap(),
      'userId': currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _teamsRef.add(teamData);
  }

  Stream<List<Team>> getUserTeams() {
    if (currentUserId == null) {
      return const Stream.empty();
    }

    return _teamsRef
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Team.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  Future<void> updateTeam(Team team) async {
    if (team.id == null) return;

    await _teamsRef.doc(team.id).update({
      'name': team.name,
      'players': team.players.map((p) => p.toMap()).toList(),
    });
  }

  Future<void> deleteTeam(String teamId) async {
    await _teamsRef.doc(teamId).delete();
  }
}
