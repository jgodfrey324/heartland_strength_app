// Widget for assigned teams and athletes to libraries
import 'package:flutter/material.dart';

class AssignedSelectors extends StatelessWidget {
  final List<Map<String, dynamic>> allTeams;
  final List<Map<String, dynamic>> allUsers;
  final Set<String> selectedTeamIds;
  final Set<String> selectedUserIds;
  final Function(String teamId) onTeamToggle;
  final Function(String userId) onUserToggle;

  const AssignedSelectors({
    super.key,
    required this.allTeams,
    required this.allUsers,
    required this.selectedTeamIds,
    required this.selectedUserIds,
    required this.onTeamToggle,
    required this.onUserToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assigned Teams', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allTeams.map((team) {
            final tId = team['id'] as String;
            final selected = selectedTeamIds.contains(tId);
            return FilterChip(
              label: Text(team['name'] ?? 'Unnamed'),
              selected: selected,
              onSelected: (_) => onTeamToggle(tId),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('Assigned Athletes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allUsers.map((user) {
            final uId = user['id'] as String;
            final selected = selectedUserIds.contains(uId);
            return FilterChip(
              label: Text(user['name'] ?? 'Unnamed'),
              selected: selected,
              onSelected: (_) => onUserToggle(uId),
            );
          }).toList(),
        ),
      ],
    );
  }
}
