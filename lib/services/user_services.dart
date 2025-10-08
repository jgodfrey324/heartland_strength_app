// Firebase logic to grab data related to users and their organization
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final usersSnapshot = await _firestore.collection('users').get();

    return usersSnapshot.docs.map((doc) {
      final firstName = doc['firstName'] ?? '';
      final lastName = doc['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim();
      return {
        'id': doc.id,
        'name': fullName.isNotEmpty ? fullName : 'Unnamed',
      };
    }).toList();
  }

  Future<void> addTeam({
    required String teamName,
    required List<String> userIds,
  }) async {
    if (teamName.isEmpty || userIds.isEmpty) {
      throw Exception('Team name and user list cannot be empty.');
    }

    await _firestore.collection('teams').add({
      'name': teamName,
      'userIds': userIds,
    });
  }
}
