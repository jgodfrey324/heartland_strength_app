// Firebase logic for programs
import 'package:cloud_firestore/cloud_firestore.dart';

/// Fetches assigned teams, manually assigned users, and users belonging to those teams.
/// Returns a map with keys: 'teams', 'users' (manually assigned), 'teamMembers' (users from assigned teams but not manually assigned).
Future<Map<String, List<String>>> fetchAssignedNamesWithTeamMembers(Map<String, dynamic> assignedTo) async {

  final assignedUserIds = Set<String>.from(assignedTo['users'] ?? []);
  final assignedTeamIds = List<String>.from(assignedTo['teams'] ?? []);

  // Fetch assigned teams docs
  final teamsSnapshot = assignedTeamIds.isNotEmpty
      ? await FirebaseFirestore.instance
          .collection('teams')
          .where(FieldPath.documentId, whereIn: assignedTeamIds)
          .get()
      : null;

  // Extract team names
  final teamNames = teamsSnapshot?.docs
        .map((doc) => doc.data()['name']?.toString() ?? 'Unnamed Team')
        .toList()
        .cast<String>() ?? [];

  // Extract all users in those teams
  final teamUserIds = <String>{};
  if (teamsSnapshot != null) {
    for (final doc in teamsSnapshot.docs) {
      final List<dynamic> userIdsDynamic = doc.data()['userIds'] ?? [];
      teamUserIds.addAll(userIdsDynamic.map((e) => e.toString()));
    }
  }

  // Exclude manually assigned users from team members to avoid duplicates
  final teamOnlyUserIds = teamUserIds.difference(assignedUserIds);

  // Helper function to fetch user full name by userId
  Future<String> fetchUserName(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userDoc.exists) return 'Unknown User';

    final data = userDoc.data();
    if (data == null) return 'Unknown User';

    final firstName = data['firstName'] ?? '';
    final lastName = data['lastName'] ?? '';
    final fullName = ('$firstName $lastName').trim();
    return fullName.isNotEmpty ? fullName : 'Unnamed User';
  }

  // Fetch manually assigned user names
  final manuallyAssignedUserNames = (await Future.wait(assignedUserIds.map(fetchUserName))).cast<String>();

  // Fetch team member names
  final teamMemberNames = (await Future.wait(teamOnlyUserIds.map(fetchUserName))).cast<String>();

  return {
    'teams': teamNames,
    'users': manuallyAssignedUserNames,
    'teamMembers': teamMemberNames,
  };
}


Set<String> computeAssignedUserIds({
  required List<Map<String, dynamic>> allUsers,
  required Set<String> selectedTeamIds,
  required Set<String> manuallyAssignedUserIds,
}) {
  final teamDerivedUserIds = <String>{};

  for (var user in allUsers) {
    final userTeams = List<String>.from(user['teamIds'] ?? []);
    final userId = user['id'];

    if (userTeams.any((teamId) => selectedTeamIds.contains(teamId))) {
      teamDerivedUserIds.add(userId);
    }
  }

  return {...teamDerivedUserIds, ...manuallyAssignedUserIds};
}

/// Computes selected user IDs from selected teams and manually assigned users.
/// `allTeams` must be a list of maps each containing 'id' and 'userIds' (List<String>).
Set<String> computeSelectedUserIds({
  required List<Map<String, Object>> allTeams,
  required Set<String> selectedTeamIds,
  required Set<String> manuallyAssignedUserIds,
}) {
  final userIdsFromTeams = <String>{};

  for (final teamId in selectedTeamIds) {
    final team = allTeams.firstWhere(
      (t) => t['id'] == teamId,
      orElse: () => <String, Object>{'userIds': <String>[]},
    );

    final List<dynamic>? usersInTeamDynamic = team['userIds'] as List<dynamic>?;
    final usersInTeam = usersInTeamDynamic?.map((e) => e.toString()).toList() ?? [];

    userIdsFromTeams.addAll(usersInTeam);
  }

  return userIdsFromTeams.union(manuallyAssignedUserIds);
}

Future<Map<String, List<String>>> fetchAssignedNames(Map<String, dynamic> assignedTo) async {
  final usersIds = List<String>.from(assignedTo['users'] ?? []);
  final teamsIds = List<String>.from(assignedTo['teams'] ?? []);

  final userFutures = usersIds.map((id) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    if (!doc.exists) return 'Unknown User';

    final data = doc.data();
    if (data == null) return 'Unknown User';

    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final fullName = ('$firstName $lastName').trim();
    return fullName.isNotEmpty ? fullName : 'Unnamed User';
  });

  final teamFutures = teamsIds.map((id) async {
    final doc = await FirebaseFirestore.instance.collection('teams').doc(id).get();
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
