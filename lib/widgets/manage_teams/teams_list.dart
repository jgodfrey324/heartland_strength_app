// Widget for handling the teams list, expansion logic and displaying users
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamsList extends StatelessWidget {
  final Map<String, bool> expandedTeams;
  final Function(String) toggleTeamExpansion;

  const TeamsList({
    super.key,
    required this.expandedTeams,
    required this.toggleTeamExpansion,
  });

  void _deleteTeam(BuildContext context, String teamId, String teamName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "$teamName"?'),
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
      await FirebaseFirestore.instance.collection('teams').doc(teamId).delete();
      // Optionally: remove team reference from users or handle cleanup
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('teams').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No teams found.'));
        }

        final teams = snapshot.data!.docs;

        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final teamDoc = teams[index];
            final teamId = teamDoc.id;
            final teamName = teamDoc['name'] ?? 'Unnamed Team';
            final List<dynamic> userIds = teamDoc['userIds'] ?? [];

            final expanded = expandedTeams[teamId] ?? false;

            return ExpansionTile(
              key: PageStorageKey(teamId),
              title: Text(
                teamName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              initiallyExpanded: expanded,
              onExpansionChanged: (_) => toggleTeamExpansion(teamId),

              // Custom trailing with arrow + delete button
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                  const SizedBox(width: 24), // 👈 Adjust this value as needed
                  Tooltip(
                    message: 'Delete team',
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTeam(context, teamId, teamName),
                    ),
                  ),
                ],
              ),

              children: [
                if (userIds.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No users in this team'),
                  )
                else
                  FutureBuilder<QuerySnapshot>(
                    future: firestore
                        .collection('users')
                        .where(FieldPath.documentId, whereIn: userIds)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No users in this team'),
                        );
                      }

                      final users = userSnapshot.data!.docs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: users.map((userDoc) {
                          final firstName = userDoc['firstName'] ?? '';
                          final lastName = userDoc['lastName'] ?? '';
                          final fullName = ('$firstName $lastName').trim();
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Text(fullName.isNotEmpty ? fullName : 'Unnamed User'),
                          );
                        }).toList(),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
