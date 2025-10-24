// Modal to show assigned teams and users (for libraries)
import 'package:flutter/material.dart';

class AssignedToDialog extends StatelessWidget {
  final Map<String, List<String>> assignedNames;

  const AssignedToDialog({super.key, required this.assignedNames});

  @override
  Widget build(BuildContext context) {
    final users = assignedNames['users'] ?? [];
    final teamMembers = assignedNames['teamMembers'] ?? [];
    final teams = assignedNames['teams'] ?? [];

    return AlertDialog(
      title: const Text('Assigned To'),
      content: (users.isEmpty && teamMembers.isEmpty && teams.isEmpty)
          ? const Text('No users or teams assigned.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (teams.isNotEmpty) ...[
                  const Text('Teams:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...teams.map((name) => Text(name)),
                  const SizedBox(height: 12),
                ],
                if (users.isNotEmpty) ...[
                  const Text('Users:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...users.map((name) => Text(name)),
                  const SizedBox(height: 12),
                ],
                if (teamMembers.isNotEmpty) ...[
                  const Text('Team Members:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...teamMembers.map((name) => Text(name)),
                ],
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
