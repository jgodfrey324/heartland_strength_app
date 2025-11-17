// Entry point for program details screen where a program can be updated and viewed in a calendar format
import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/widgets/library_details/assigned_selectors.dart';
import '../../utils/program_utils.dart';
import '../../widgets/program_details/month_schedule.dart';
import '../../services/program_services.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  String title = '';
  String description = '';
  bool isLoading = true;

  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, Object>> allTeams = [];

  Set<String> selectedTeamIds = {};
  Set<String> manuallyAssignedUserIds = {};
  Set<String> selectedUserIds = {};

  /// Schedule is date string (YYYY-MM-DD) → list of workoutIds
  Map<String, dynamic> schedule = {};
  Map<String, dynamic> workoutsById = {};

  @override
  void initState() {
    super.initState();
    _loadProgramDataAndSchedule();
  }

  Future<void> _loadProgramDataAndSchedule() async {
    setState(() => isLoading = true);

    try {
      // Fetch the full program data using the util function
      final programData = await fetchCompleteProgramData(widget.programId);

      setState(() {
        title = programData.title;
        description = programData.description;

        allUsers = programData.allUsers;
        allTeams = programData.allTeams;

        selectedTeamIds = programData.selectedTeamIds;
        manuallyAssignedUserIds = programData.manuallyAssignedUserIds;
        selectedUserIds = programData.selectedUserIds;

        schedule = programData.schedule;
        workoutsById = programData.workoutsById;

        isLoading = false;
      });
    } catch (e, stack) {
      print('❌ Error loading program data and schedule: $e');
      print(stack);
      setState(() => isLoading = false);
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
    await assignProgramToTeamsAndUsers(
      programId: widget.programId,
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

            // Assigned team/user selectors
            AssignedSelectors(
              allTeams: allTeams,
              allUsers: allUsers,
              selectedTeamIds: selectedTeamIds,
              selectedUserIds: selectedUserIds,
              onTeamToggle: _onTeamToggle,
              onUserToggle: _onUserToggle,
            ),
            const SizedBox(height: 32),

            // Month calendar schedule view
            SizedBox(
              height: 500, // or MediaQuery.of(context).size.height * 0.65
              child: MonthSchedule(
                programId: widget.programId,
                schedule: schedule.map(
                  (key, value) => MapEntry(key, List<String>.from(value)),
                ),
                workoutsById: workoutsById,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
