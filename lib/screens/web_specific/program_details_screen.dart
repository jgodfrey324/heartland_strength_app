// Entry point for program details screen where program can be updated
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/program_utils.dart';
import '../../widgets/program_details/assigned_selectors.dart';
import '../../widgets/program_details/week_schedule.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProgramData();
  }

  Future<void> _loadProgramData() async {
    final progDoc = await FirebaseFirestore.instance
        .collection('programs')
        .doc(widget.programId)
        .get();
    final prog = progDoc.data();

    final teamSnap = await FirebaseFirestore.instance.collection('teams').get();
    final userSnap = await FirebaseFirestore.instance.collection('users').get();

    allUsers = userSnap.docs.map((doc) {
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

    allTeams = teamSnap.docs.map((doc) {
      final data = doc.data();
      final teamId = doc.id;

      final List<dynamic> userIdsFromTeam = data['userIds'] ?? [];

      return {
        'id': teamId,
        'name': data['name'] as String? ?? 'Unnamed Team',
        'userIds': userIdsFromTeam.map((e) => e.toString()).toList(),
      };
    }).toList();

    selectedTeamIds = Set<String>.from(prog?['assignedTo']?['teams'] ?? []);
    manuallyAssignedUserIds = Set<String>.from(prog?['assignedTo']?['users'] ?? []);

    selectedUserIds = computeSelectedUserIds(
      allTeams: allTeams,
      selectedTeamIds: selectedTeamIds,
      manuallyAssignedUserIds: manuallyAssignedUserIds,
    );

    setState(() {
      title = prog?['title'] as String? ?? '';
      description = prog?['description'] as String? ?? '';
      durationWeeks = prog?['durationWeeks'] as int? ?? 0;
      isLoading = false;
    });
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
            WeekSchedule(durationWeeks: durationWeeks),
          ],
        ),
      ),
    );
  }
}
