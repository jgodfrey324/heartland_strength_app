// List of current libraries. Can delete from list. Clicking to get to library details screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/widgets/libraries/assigned_to_dialog.dart';
import '../../screens/web_specific/library_details_screen.dart';
import '../../utils/library_utils.dart';

class LibrariesList extends StatelessWidget {
  const LibrariesList({super.key});

  Future<void> _showAssignedDialog(BuildContext context, Map<String, dynamic>? assignedTo) async {
    assignedTo ??= {'users': [], 'teams': []};
    final assignedNames = await fetchAssignedNamesWithTeamMembers(assignedTo);

    showDialog(
      context: context,
      builder: (_) => AssignedToDialog(assignedNames: assignedNames),
    );
  }

  Future<void> _deleteLibrary(BuildContext context, String libraryId, String libraryTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Library'),
        content: Text('Are you sure you want to delete "$libraryTitle"?'),
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
      await FirebaseFirestore.instance.collection('libraries').doc(libraryId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('libraries')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No libraries available.'));
        }

        final libraries = snapshot.data!.docs;

        return ListView.builder(
          itemCount: libraries.length,
          itemBuilder: (context, index) {
            final doc = libraries[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['description'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LibraryDetailsScreen(libraryId: doc.id),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'Library assigned to',
                      child: IconButton(
                        icon: const Icon(Icons.group),
                        onPressed: () => _showAssignedDialog(context, data['assignedTo']),
                      ),
                    ),
                    Tooltip(
                      message: 'Delete Library',
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteLibrary(context, doc.id, data['title'] ?? 'Untitled Library'),
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
