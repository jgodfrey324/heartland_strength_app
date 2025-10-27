// Firebase logic to grab data related to users and their organization
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all users as a list of maps with id and full name
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

  /// Add a team to Firestore
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

  /// Fetch the full name of a user by ID
  Future<String> fetchUserName(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return 'Unknown User';

    final data = userDoc.data();
    if (data == null) return 'Unknown User';

    final firstName = data['firstName'] ?? '';
    final lastName = data['lastName'] ?? '';
    final fullName = ('$firstName $lastName').trim();
    return fullName.isNotEmpty ? fullName : 'Unnamed User';
  }

  /// Fetch user and team names by their IDs
  Future<Map<String, List<String>>> fetchAssignedNames(Map<String, dynamic> assignedTo) async {
    final usersIds = List<String>.from(assignedTo['users'] ?? []);
    final teamsIds = List<String>.from(assignedTo['teams'] ?? []);

    final userFutures = usersIds.map(fetchUserName);

    final teamFutures = teamsIds.map((id) async {
      final doc = await _firestore.collection('teams').doc(id).get();
      if (!doc.exists) return 'Unknown Team';

      final data = doc.data();
      if (data == null) return 'Unknown Team';

      return data['name'] as String? ?? 'Unnamed Team';
    });

    final userNames = await Future.wait(userFutures);
    final teamNames = await Future.wait(teamFutures);

    return {
      'users': userNames,
      'teams': teamNames,
    };
  }

  /// Fetch assigned teams, manually assigned users, and users from those teams (excluding manually assigned users)
  /// Returns a map with keys: 'teams', 'users', 'teamMembers'
  Future<Map<String, List<String>>> fetchAssignedNamesWithTeamMembers(Map<String, dynamic> assignedTo) async {
    final assignedUserIds = Set<String>.from(assignedTo['users'] ?? []);
    final assignedTeamIds = List<String>.from(assignedTo['teams'] ?? []);

    final teamsSnapshot = assignedTeamIds.isNotEmpty
        ? await _firestore
            .collection('teams')
            .where(FieldPath.documentId, whereIn: assignedTeamIds)
            .get()
        : null;

    final teamNames = teamsSnapshot?.docs
            .map((doc) => doc.data()['name']?.toString() ?? 'Unnamed Team')
            .toList()
            .cast<String>() ??
        [];

    final teamUserIds = <String>{};
    if (teamsSnapshot != null) {
      for (final doc in teamsSnapshot.docs) {
        final List<dynamic> userIdsDynamic = doc.data()['userIds'] ?? [];
        teamUserIds.addAll(userIdsDynamic.map((e) => e.toString()));
      }
    }

    final teamOnlyUserIds = teamUserIds.difference(assignedUserIds);

    final manuallyAssignedUserNames = (await Future.wait(assignedUserIds.map(fetchUserName))).cast<String>();
    final teamMemberNames = (await Future.wait(teamOnlyUserIds.map(fetchUserName))).cast<String>();

    return {
      'teams': teamNames,
      'users': manuallyAssignedUserNames,
      'teamMembers': teamMemberNames,
    };
  }

  /// Fetch all teams from Firestore
  Future<List<Map<String, Object>>> fetchAllTeams() async {
    final teamsSnapshot = await _firestore.collection('teams').get();

    return teamsSnapshot.docs.map((doc) {
      final teamData = doc.data();
      return <String, Object>{
        'id': doc.id,
        'name': teamData['name'] ?? 'Unnamed Team',
        'userIds': List<String>.from(teamData['userIds'] ?? []),
      };
    }).toList();
  }
}
