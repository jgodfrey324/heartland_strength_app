// Custom reaction bar
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ReactionBar extends StatefulWidget {
  final String messageId;
  const ReactionBar({super.key, required this.messageId});

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _toggleReaction(String emoji) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final reactionDoc = _firestore
        .collection('announcements')
        .doc(widget.messageId)
        .collection('reactions')
        .doc(emoji);

    final docSnapshot = await reactionDoc.get();

    if (!docSnapshot.exists) {
      await reactionDoc.set({
        'userIds': [userId],
      });
    } else {
      List<dynamic> userIds = docSnapshot.data()?['userIds'] ?? [];
      if (userIds.contains(userId)) {
        userIds.remove(userId);
      } else {
        userIds.add(userId);
      }
      await reactionDoc.update({'userIds': userIds});
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('announcements')
          .doc(widget.messageId)
          .collection('reactions')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final reactions = snapshot.data!.docs;

        return Row(
          children: reactions.map((reactionDoc) {
            final emoji = reactionDoc.id;
            final userIds = reactionDoc['userIds'] as List<dynamic>;
            return GestureDetector(
              onTap: () => _toggleReaction(emoji),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: userIds.contains(_auth.currentUser!.uid)
                      ? Colors.blue.shade100
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(emoji),
                    const SizedBox(width: 4),
                    Text(userIds.length.toString()),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
