import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartlandstrengthapp/services/user_services.dart';

final UserService _userService = UserService();

/// Fetch assigned teams, manually assigned users, and users from those teams (excluding manually assigned users)
/// Delegates to UserService.fetchAssignedNamesWithTeamMembers
Future<Map<String, List<String>>> fetchAssignedNamesWithTeamMembers(Map<String, dynamic> assignedTo) async {
  return _userService.fetchAssignedNamesWithTeamMembers(assignedTo);
}

/// Fetch user and team names by IDs using UserService
Future<Map<String, List<String>>> fetchAssignedNames(Map<String, dynamic> assignedTo) async {
  return _userService.fetchAssignedNames(assignedTo);
}

/// Computes combined assigned user IDs from allUsers based on selected teams and manually assigned users
Set<String> computeAssignedUserIds({
  required List<Map<String, dynamic>> allUsers,
  required Set<String> selectedTeamIds,
  required Set<String> manuallyAssignedUserIds,
}) {
  final teamDerivedUserIds = <String>{};

  for (var user in allUsers) {
    final userTeams = List<String>.from(user['teamIds'] ?? []);
    final userId = user['id']?.toString() ?? '';

    if (userTeams.any(selectedTeamIds.contains)) {
      teamDerivedUserIds.add(userId);
    }
  }

  return {...teamDerivedUserIds, ...manuallyAssignedUserIds};
}

/// Computes selected user IDs from selected teams and manually assigned users
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

/// Adds a workout ID to the program schedule for a specific date
Future<void> addWorkoutToProgramSchedule({
  required String programId,
  required String date, // e.g., '2025-10-27'
  required String workoutId,
}) async {
  final programRef = FirebaseFirestore.instance.collection('programs').doc(programId);

  // Use FieldValue.arrayUnion to add the workout ID to the array for that date
  await programRef.set({
    'schedule': {
      date: FieldValue.arrayUnion([workoutId]),
    },
  }, SetOptions(merge: true));
}

/// ProgramData class (similar to LibraryData but without durationWeeks)
class ProgramData {
  final String programId;
  final String title;
  final String description;
  final List<Map<String, dynamic>> allUsers;
  final List<Map<String, Object>> allTeams;
  final Set<String> selectedTeamIds;
  final Set<String> manuallyAssignedUserIds;
  final Set<String> selectedUserIds;
  final Map<String, dynamic> schedule;
  final Map<String, dynamic> workoutsById;
  final Map<String, List<String>> assignedNames;

  ProgramData({
    required this.programId,
    required this.title,
    required this.description,
    required this.allUsers,
    required this.allTeams,
    required this.selectedTeamIds,
    required this.manuallyAssignedUserIds,
    required this.selectedUserIds,
    required this.schedule,
    required this.workoutsById,
    required this.assignedNames,
  });
}

/// Fetch all program data including metadata and schedule
Future<ProgramData> fetchCompleteProgramData(String programId) async {
  final doc = await FirebaseFirestore.instance.collection('programs').doc(programId).get();
  if (!doc.exists) {
    throw Exception('Program not found');
  }

  final data = doc.data() ?? {};

  final assignedTo = data['assignedTo'] as Map<String, dynamic>? ?? {};
  final assignedNames = await _userService.fetchAssignedNamesWithTeamMembers(assignedTo);

  final allUsers = await _userService.fetchAllUsers();

  final allTeams = await _userService.fetchAllTeams();

  final selectedTeamIds = Set<String>.from(assignedTo['teams'] ?? []);
  final manuallyAssignedUserIds = Set<String>.from(assignedTo['users'] ?? []);

  final selectedUserIds = computeSelectedUserIds(
    allTeams: allTeams,
    selectedTeamIds: selectedTeamIds,
    manuallyAssignedUserIds: manuallyAssignedUserIds,
  );

  return ProgramData(
    programId: programId,
    title: data['title'] ?? 'Untitled Program',
    description: data['description'] ?? '',
    allUsers: allUsers,
    allTeams: allTeams,
    selectedTeamIds: selectedTeamIds,
    manuallyAssignedUserIds: manuallyAssignedUserIds,
    selectedUserIds: selectedUserIds,
    schedule: data['schedule'] ?? {},
    workoutsById: data['workoutsById'] ?? {},
    assignedNames: assignedNames,
  );
}
