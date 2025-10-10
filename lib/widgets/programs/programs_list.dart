// List of current programs. Can delete from list. Clicking to get to program details screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../screens/web_specific/program_details_screen.dart';

class ProgramsList extends StatelessWidget {
  const ProgramsList({super.key});

  void _showAssignedDialog(BuildContext context, List assignedTo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assigned To'),
        content: assignedTo.isEmpty
            ? const Text('No users or teams assigned.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: assignedTo.map((e) => Text(e.toString())).toList(),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _deleteProgram(String id) async {
    await FirebaseFirestore.instance.collection('programs').doc(id).delete();
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
                      builder: (_) => ProgramDetailsScreen(
                        title: data['title'] ?? 'No Title',
                        description: data['description'] ?? '',
                        durationWeeks: data['durationWeeks'] ?? 0,
                      ),
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
                        onPressed: () => _showAssignedDialog(context, data['assignedTo'] ?? []),
                      ),
                    ),
                    Tooltip(
                      message: 'Delete Program',
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteProgram(doc.id),
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
