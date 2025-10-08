// Widget to handle right side bar form to add team
import 'package:flutter/material.dart';

class AddTeamSidebar extends StatelessWidget {
  final TextEditingController teamNameController;
  final List<Map<String, dynamic>> allUsers;
  final List<String> selectedUserIds;
  final Function(String) onToggleUserSelection;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const AddTeamSidebar({
    super.key,
    required this.teamNameController,
    required this.allUsers,
    required this.selectedUserIds,
    required this.onToggleUserSelection,
    required this.onCancel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Add Team', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onCancel,
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: teamNameController,
              decoration: const InputDecoration(labelText: 'Team Name'),
            ),

            const SizedBox(height: 20),
            const Text('Athletes:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),

            Expanded(
              child: SingleChildScrollView(
                child: allUsers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allUsers.map((user) {
                          final selected = selectedUserIds.contains(user['id']);
                          return FilterChip(
                            label: Text(user['name']),
                            selected: selected,
                            onSelected: (val) => onToggleUserSelection(user['id']),
                          );
                        }).toList(),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onAdd,
                  child: const Text('Add'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
