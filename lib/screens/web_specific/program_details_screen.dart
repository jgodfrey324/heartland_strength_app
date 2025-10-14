// Entry point for program details screen where program can be updated
// Entry point for program details screen where program can be updated
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/program_utils.dart';
import '../../widgets/program_details/assigned_selectors.dart';
import '../../widgets/program_details/week_schedule.dart';
import '../../services/train_service.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
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
    _loadProgramDataAndSchedule();
  }

  Future<void> _loadProgramDataAndSchedule() async {
    try {
      final programData = await fetchCompleteProgramData(widget.programId, _trainService);

      setState(() {
        title = programData.title;
        description = programData.description;
        durationWeeks = programData.durationWeeks;

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
    await FirebaseFirestore.instance.collection('programs').doc(widget.programId).update({
      'assignedTo': {
        'teams': selectedTeamIds.toList(),
        'users': manuallyAssignedUserIds.toList(),
      },
    });
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
              programId: widget.programId,
              schedule: schedule,
              workoutsById: workoutsById,
            ),
          ],
        ),
      ),
    );
  }
}
