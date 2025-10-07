// Handles Firebase Notification and Messaging logic
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // setting message stream
  Stream<QuerySnapshot> getAnnouncementsStream() {
    return _firestore
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // post message
  Future<void> postMessage({
    required String text,
    required String userName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged in user');

    if (text.trim().isEmpty) return;

    await _firestore.collection('announcements').add({
      'text': text.trim(),
      'userId': user.uid,
      'userName': userName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

   // Toggle a reaction for the current user on a message or comment
   // Each user gets one reaction
   // Can add, remove and update reaciton here
  Future<void> toggleReaction({
    required String messageId,
    required String emoji,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final reactionRef = _firestore
        .collection('announcements')
        .doc(messageId)
        .collection('reactions')
        .doc(emoji);

    final snapshot = await reactionRef.get();

    if (!snapshot.exists) {
      // First time someone reacts with this emoji
      await reactionRef.set({
        'userIds': [user.uid],
      });
    } else {
      final data = snapshot.data();
      final List<dynamic> userIds = data?['userIds'] ?? [];

      if (userIds.contains(user.uid)) {
        // Remove reaction
        userIds.remove(user.uid);
      } else {
        // Add reaction
        userIds.add(user.uid);
      }

      await reactionRef.update({
        'userIds': userIds,
      });

      if (userIds.isEmpty) {
        await reactionRef.delete(); // Remove empty emoji doc
      } else {
        await reactionRef.update({'userIds': userIds});
      }
    }
  }

  // Stream of all reactions on a message
  Stream<List<Map<String, dynamic>>> reactionStream(String messageId) {
    return _firestore
        .collection('announcements')
        .doc(messageId)
        .collection('reactions')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }
}
