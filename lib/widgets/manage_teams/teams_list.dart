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

            if (userIds.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No users in this team'),
              );
            }

            return ExpansionTile(
              key: PageStorageKey(teamId),
              title: Text(
                teamName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: expanded,
              onExpansionChanged: (_) => toggleTeamExpansion(teamId),
              children: [
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
                      children: users
                        .map((userDoc) {
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
