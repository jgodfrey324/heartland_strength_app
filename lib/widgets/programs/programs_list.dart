// List of current programs. Can delete from list. Clicking to get to program details screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/widgets/programs/assigned_to_dialog.dart';
import '../../screens/web_specific/program_details_screen.dart';
import '../../utils/program_utils.dart';

class ProgramsList extends StatelessWidget {
  const ProgramsList({super.key});

  Future<void> _showAssignedDialog(BuildContext context, Map<String, dynamic>? assignedTo) async {
    assignedTo ??= {'users': [], 'teams': []};
    final assignedNames = await fetchAssignedNamesWithTeamMembers(assignedTo);

    showDialog(
      context: context,
      builder: (_) => AssignedToDialog(assignedNames: assignedNames),
    );
  }

  Future<void> _deleteProgram(BuildContext context, String programId, String programTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Program'),
        content: Text('Are you sure you want to delete "$programTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('programs').doc(programId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('programs')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No programs available.'));
        }

        final programs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: programs.length,
          itemBuilder: (context, index) {
            final doc = programs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['description'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProgramDetailsScreen(programId: doc.id),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'Program assigned to',
                      child: IconButton(
                        icon: const Icon(Icons.group),
                        onPressed: () => _showAssignedDialog(context, data['assignedTo']),
                      ),
                    ),
                    Tooltip(
                      message: 'Delete Program',
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteProgram(context, doc.id, data['title'] ?? 'Untitled Program'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
