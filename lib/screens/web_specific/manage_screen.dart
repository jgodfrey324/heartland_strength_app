// Main entry point for manage screen --> managing teams
import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/services/user_services.dart';
import '../../widgets/manage_teams/add_team_sidebar.dart';
import '../../widgets/manage_teams/teams_list.dart';
import '../../widgets/custom_button.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final UserService _userService = UserService();

  final Map<String, bool> _expandedTeams = {}; // teamId => expanded or not
  bool _isSidebarOpen = false;

  // Data for sidebar form
  List<Map<String, dynamic>> _allUsers = [];
  List<String> _selectedUserIds = [];
  final TextEditingController _teamNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    final users = await _userService.fetchAllUsers();
    setState(() {
      _allUsers = users;
    });
  }

  Future<void> _addTeam() async {
    final teamName = _teamNameController.text.trim();
    try {
      await _userService.addTeam(teamName: teamName, userIds: _selectedUserIds);
      _closeSidebar();
    } catch (e) {
      // Show error to user here (optional)
      print('Error adding team: $e');
    }
  }

  void _toggleTeamExpansion(String teamId) {
    setState(() {
      _expandedTeams[teamId] = !(_expandedTeams[teamId] ?? false);
    });
  }

  void _openSidebar() {
    setState(() {
      _isSidebarOpen = true;
      _teamNameController.clear();
      _selectedUserIds = [];
    });
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Teams'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: CustomButton(
                  text: '+ Team',
                  onPressed: _openSidebar,
                ),
              ),
            ],
          ),
          body: TeamsList(
            expandedTeams: _expandedTeams,
            toggleTeamExpansion: _toggleTeamExpansion,
          ),
        ),
        if (_isSidebarOpen)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: MediaQuery.of(context).size.width * 0.35,
            child: AddTeamSidebar(
              teamNameController: _teamNameController,
              allUsers: _allUsers,
              selectedUserIds: _selectedUserIds,
              onToggleUserSelection: (userId) {
                setState(() {
                  if (_selectedUserIds.contains(userId)) {
                    _selectedUserIds.remove(userId);
                  } else {
                    _selectedUserIds.add(userId);
                  }
                });
              },
              onCancel: _closeSidebar,
              onAdd: () async {
                await _addTeam();
              },
            ),
          ),
      ],
    );
  }
}
