// Entry point for library details screen where library can be updated
import 'package:flutter/material.dart';
import '../../utils/library_utils.dart';
import '../../widgets/library_details/assigned_selectors.dart';
import '../../widgets/library_details/week_schedule.dart';
import '../../services/train_service.dart';

class LibraryDetailsScreen extends StatefulWidget {
  final String libraryId;

  const LibraryDetailsScreen({super.key, required this.libraryId});

  @override
  State<LibraryDetailsScreen> createState() => _LibraryDetailsScreenState();
}

class _LibraryDetailsScreenState extends State<LibraryDetailsScreen> {
  String title = '';
  String description = '';
  int durationWeeks = 0;
  bool isLoading = true;

  List<Map<String, Object>> allUsers = [];
  List<Map<String, Object>> allTeams = [];

  Set<String> selectedTeamIds = {};
  Set<String> manuallyAssignedUserIds = {};
  Set<String> selectedUserIds = {};

  Map<String, Map<String, List<String>>> schedule = {};
  Map<String, Workout> workoutsById = {};

  final TrainService _trainService = TrainService();

  @override
  void initState() {
    super.initState();
    _loadLibraryDataAndSchedule();
  }

  Future<void> _loadLibraryDataAndSchedule() async {
    try {
      final libraryData = await fetchCompleteLibraryData(widget.libraryId);

      // Convert schedule safely
      final convertedSchedule = <String, Map<String, List<String>>>{};
      (libraryData.schedule).forEach((weekKey, dayMap) {
        convertedSchedule[weekKey] = (dayMap as Map<String, dynamic>).map(
          (dayKey, workoutsDynamic) => MapEntry(
            dayKey,
            List<String>.from(workoutsDynamic),
          ),
        );
      });

      // Convert raw workout data to Map<String, Workout> (forEach style)
      final convertedWorkoutsById = <String, Workout>{};
      (libraryData.workoutsById as Map<String, dynamic>? ?? {}).forEach((key, value) {
        final mapValue = value as Map<String, dynamic>;
        convertedWorkoutsById[key] = Workout.fromMap(mapValue, id: key);
      });


      setState(() {
        title = libraryData.title;
        description = libraryData.description;
        durationWeeks = libraryData.durationWeeks;

        allUsers = libraryData.allUsers.cast<Map<String, Object>>();
        allTeams = libraryData.allTeams.cast<Map<String, Object>>();

        selectedTeamIds = libraryData.selectedTeamIds;
        manuallyAssignedUserIds = libraryData.manuallyAssignedUserIds;
        selectedUserIds = libraryData.selectedUserIds;

        schedule = convertedSchedule;
        workoutsById = convertedWorkoutsById;

        isLoading = false;
      });
    } catch (e, stack) {
      print('❌ Error loading library data and schedule: $e');
      print(stack);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onTeamToggle(String teamId) {
    setState(() {
      if (selectedTeamIds.contains(teamId)) {
        selectedTeamIds.remove(teamId);
      } else {
        selectedTeamIds.add(teamId);
      }

      selectedUserIds = computeSelectedUserIds(
        allTeams: allTeams,
        selectedTeamIds: selectedTeamIds,
        manuallyAssignedUserIds: manuallyAssignedUserIds,
      );
    });
    _saveAssignment();
  }

  void _onUserToggle(String userId) {
    setState(() {
      if (manuallyAssignedUserIds.contains(userId)) {
        manuallyAssignedUserIds.remove(userId);
      } else {
        manuallyAssignedUserIds.add(userId);
      }

      selectedUserIds = computeSelectedUserIds(
        allTeams: allTeams,
        selectedTeamIds: selectedTeamIds,
        manuallyAssignedUserIds: manuallyAssignedUserIds,
      );
    });
    _saveAssignment();
  }

  Future<void> _saveAssignment() async {
    await _trainService.assignLibraryToTeamsAndUsers(
      libraryId: widget.libraryId,
      teamIds: selectedTeamIds.toList(),
      userIds: manuallyAssignedUserIds.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty)
              Text(
                description,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 24),
            AssignedSelectors(
              allTeams: allTeams,
              allUsers: allUsers,
              selectedTeamIds: selectedTeamIds,
              selectedUserIds: selectedUserIds,
              onTeamToggle: _onTeamToggle,
              onUserToggle: _onUserToggle,
            ),
            const SizedBox(height: 32),
            WeekSchedule(
              durationWeeks: durationWeeks,
              libraryId: widget.libraryId,
              schedule: schedule,
              workoutsById: workoutsById,
            ),
          ],
        ),
      ),
    );
  }
}
