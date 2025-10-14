import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartlandstrengthapp/services/train_service.dart';

/// Fetch assigned teams, manually assigned users, and users from those teams (excluding manually assigned users).
/// Returns a map with keys: 'teams' (List<String> team names), 'users' (List<String> manually assigned user names), 'teamMembers' (List<String> user names from teams excluding manually assigned).
Future<Map<String, List<String>>> fetchAssignedNamesWithTeamMembers(Map<String, dynamic> assignedTo) async {
  final assignedUserIds = Set<String>.from(assignedTo['users'] ?? []);
  final assignedTeamIds = List<String>.from(assignedTo['teams'] ?? []);

  final teamsSnapshot = assignedTeamIds.isNotEmpty
      ? await FirebaseFirestore.instance
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

  final manuallyAssignedUserNames = (await Future.wait(assignedUserIds.map(fetchUserName))).cast<String>();

  final teamMemberNames = (await Future.wait(teamOnlyUserIds.map(fetchUserName))).cast<String>();

  return {
    'teams': teamNames,
    'users': manuallyAssignedUserNames,
    'teamMembers': teamMemberNames,
  };
}

/// Computes combined assigned user IDs from allUsers based on selected teams and manually assigned users.
Set<String> computeAssignedUserIds({
  required List<Map<String, dynamic>> allUsers,
  required Set<String> selectedTeamIds,
  required Set<String> manuallyAssignedUserIds,
}) {
  final teamDerivedUserIds = <String>{};

  for (var user in allUsers) {
    final userTeams = List<String>.from(user['teamIds'] ?? []);
    final userId = user['id']?.toString() ?? '';

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

/// Fetch user and team names by their IDs.
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

/// Adds a workout ID to the schedule array in Firestore for a given week and day.
Future<void> addWorkoutToSchedule({
  required String programId,
  required int weekIndex,
  required int dayIndex,
  required String workoutId,
}) async {
  final scheduleField = 'schedule.week$weekIndex.day$dayIndex';
  final programRef = FirebaseFirestore.instance.collection('programs').doc(programId);

  await programRef.update({
    scheduleField: FieldValue.arrayUnion([workoutId]),
  });
}

class ProgramData {
  final String title;
  final String description;
  final int durationWeeks;

  final List<Map<String, Object>> allUsers;
  final List<Map<String, Object>> allTeams;

  final Set<String> selectedTeamIds;
  final Set<String> manuallyAssignedUserIds;
  final Set<String> selectedUserIds;

  final Map<String, Map<String, List<String>>> schedule; // week -> day -> workouts
  final Map<String, Workout> workoutsById;

  ProgramData({
    required this.title,
    required this.description,
    required this.durationWeeks,
    required this.allUsers,
    required this.allTeams,
    required this.selectedTeamIds,
    required this.manuallyAssignedUserIds,
    required this.selectedUserIds,
    required this.schedule,
    required this.workoutsById,
  });
}

/// Fetch all program-related data, including assignments and schedule
/// Returns a [ProgramData] object encapsulating everything needed for the UI.
Future<ProgramData> fetchCompleteProgramData(
  String programId,
  TrainService trainService,
) async {
  final progDoc = await FirebaseFirestore.instance.collection('programs').doc(programId).get();
  final prog = progDoc.data();

  if (prog == null) {
    throw Exception('Program not found');
  }

  final teamSnap = await FirebaseFirestore.instance.collection('teams').get();
  final userSnap = await FirebaseFirestore.instance.collection('users').get();

  final allUsers = userSnap.docs.map((doc) {
    final data = doc.data();
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final fullName = ('$firstName $lastName').trim();

    return <String, Object>{
      'id': doc.id,
      'name': fullName.isNotEmpty ? fullName : 'Unnamed User',
      'teamIds': List<String>.from(data['teamIds'] ?? []),
    };
  }).toList();

  final allTeams = teamSnap.docs.map((doc) {
    final data = doc.data();
    final teamId = doc.id;

    final List<dynamic> userIdsFromTeam = data['userIds'] ?? [];

    return {
      'id': teamId,
      'name': data['name'] as String? ?? 'Unnamed Team',
      'userIds': userIdsFromTeam.map((e) => e.toString()).toList(),
    };
  }).toList();

  final selectedTeamIds = Set<String>.from(prog['assignedTo']?['teams'] ?? []);
  final manuallyAssignedUserIds = Set<String>.from(prog['assignedTo']?['users'] ?? []);

  final selectedUserIds = computeSelectedUserIds(
    allTeams: allTeams,
    selectedTeamIds: selectedTeamIds,
    manuallyAssignedUserIds: manuallyAssignedUserIds,
  );

  final durationWeeks = prog['durationWeeks'] as int? ?? 0;
  final title = prog['title'] as String? ?? '';
  final description = prog['description'] as String? ?? '';

  // Fetch schedule & workouts via trainService
  final schedule = await trainService.fetchProgramSchedule(programId);

  final workoutIds = <String>{};
  schedule.forEach((_, dayMap) {
    dayMap.forEach((_, workouts) {
      workoutIds.addAll(workouts);
    });
  });

  final workoutsByIdRaw = await trainService.fetchWorkoutsByIds(workoutIds.toList());

  // Convert Map<String, Workout> directly using Workout.fromFirestore
  // Since trainService.fetchWorkoutsByIds returns Map<String, Workout> already, no need to convert
  // But if trainService returns Map<String, Map<String,dynamic>>, convert here:

  // If trainService returns Map<String, Workout>, assign directly:
  final workoutsById = workoutsByIdRaw;

  return ProgramData(
    title: title,
    description: description,
    durationWeeks: durationWeeks,
    allUsers: allUsers,
    allTeams: allTeams,
    selectedTeamIds: selectedTeamIds,
    manuallyAssignedUserIds: manuallyAssignedUserIds,
    selectedUserIds: selectedUserIds,
    schedule: schedule,
    workoutsById: workoutsById,
  );
}
